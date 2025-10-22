require "jsonUtil"
ClientUpdateNotice = {}
local guid = UILayout.NewGUIDUtilTable()
function ClientUpdateNotice.OpenUpdateUrl()
    if ClientUpdateNotice.UpdateParam.AkgUrl == "" then
        local version = ClientUpdateNotice.UpdateParam.ClientVersion
        local urls = string.split(version.AppUrl, ";")
        local web
        if version:IsSubPack() then
            -- 获取包名
            local pack = string.match(urls[1], "%/(%w+)%.apk$")
            print(urls[1])
            print(pack)
            -- 类似 https://oss.173uu.com/mtlist-m/{包名}/{推广员0}_{子包id}/{包名}.apk
            web = string.gsub(urls[1], pack.."/"..pack, pack.."/"..version.AgentID.."_"..version:GetSubPackageID().."/"..pack) 
        else
            -- 类似 https://oss.173uu.com/mtlist-m/{包名}/{包名}.apk
            web = urls[1]
        end
        print(web)
        CL.ShowWebExt(web)
        GUI.CloseWnd("ClientUpdateNotice")
        GUI.OpenWnd("ClientUpdateNotice", jsonUtil.encode({
            ["ForceUpdate"] = ClientUpdateNotice.UpdateParam.ForceUpdate,
            ["AkgUrl"] = ClientUpdateNotice.UpdateParam.AkgUrl,
        }))
    else
        print(ClientUpdateNotice.UpdateParam.AkgUrl)
        CL.ShowWebExt(ClientUpdateNotice.UpdateParam.AkgUrl) 
        GUI.CloseWnd("ClientUpdateNotice")
        GUI.OpenWnd("ClientUpdateNotice", jsonUtil.encode({
            ["ForceUpdate"] = ClientUpdateNotice.UpdateParam.ForceUpdate,
            ["AkgUrl"] = ClientUpdateNotice.UpdateParam.AkgUrl,
        }))
    end
end

function ClientUpdateNotice.Main(jsonParam)
    ClientUpdateNotice.UpdateParam = {
        ForceUpdate = false, -- 强制更新. true: 只有一个选项, 必须更新才能进入游戏, 请确保能成功进入游戏; false: 两个选项, 可以跳过更新
        AkgUrl = "", -- 填入指定下载url, 无法区分子包, 填空时通过CL.GetClientVersion自行获取(需要23年12月12日之后新包才支持)
    }
    local UpdateParam = ClientUpdateNotice.UpdateParam
    if jsonParam then
        local param = jsonUtil.decode(jsonParam)
        if param.AkgUrl ~= nil then
            UpdateParam.AkgUrl = param.AkgUrl
        end
        if param.ForceUpdate ~= nil then
            UpdateParam.ForceUpdate = param.ForceUpdate
        end
    end
    UpdateParam["BootVersion"] = CL.Version() -- 当前包内的版本 格式例如1.22.1201.54321
    UpdateParam["NetVersion"] = CL.GetPackageInfo("version") -- oss上packageinfo的version版本 类似https://oss.173uu.com/mtlist-m/{包名}/{推广员0}_{子包id}/Packageinfo.json中可以看到
    -- UpdateParam["AgentId"] = CL.GetAgentId() -- OEMServerList中agentid字段, 代理商id
    -- UpdateParam["Group"] = CL.GetGroup() -- OEMServerList中groupid字段
    UpdateParam["PlatformName"] = TOOLKIT.GetPlatformName() -- Android / iOS / WebGL / Windows / Platform

    -- 新包才有CL.GetClientVersion, 依据AppUrl和子母包信息自动获取apk地址
    if ClientUpdateNotice.UpdateParam.AkgUrl == "" then
        if UIDefine.IsFunctionOrVariableExist(CL,"GetClientVersion") then
            UpdateParam.ClientVersion = CL.GetClientVersion()    
            local version = UpdateParam.ClientVersion
            if version == nil or version.AppUrl == nil or version.AppUrl == "" or version.AppUrl == "0" then
                print("ClientVersion 或 ClientVersion.AppUrl为空")
                ClientUpdateNotice.Next() 
                return
            end
            print("ClientVersion:" .. jsonUtil.encode({
                ["IsSubPack"] = version:IsSubPack(),
                ["AgentID"] = version.AgentID,
                ["SubPackageID"] = version:GetSubPackageID(),
                ["PacakgeName"] = version.PacakgeName,
                ["AppUrl"] = version.AppUrl,
            }))
        else
            print("包太老")
            ClientUpdateNotice.Next() 
            return
        end
    end
    print("UpdateParam:" .. jsonUtil.encode(UpdateParam))
    if not ClientUpdateNotice.VersionBigThen(UpdateParam["NetVersion"], UpdateParam["BootVersion"]) then
        print("目标版本不大于包内版本")
        ClientUpdateNotice.Next() 
        return
    end

    if UpdateParam["PlatformName"] ~= "Android" then
        print("不是安卓平台, 不更新")
        ClientUpdateNotice.Next() 
        return
    end

    if UpdateParam["ForceUpdate"] then
        print("强制更新")
        GlobalUtils.ShowBoxMsg1BtnNoCloseBtn("更新提示", "发现客户端新版本"..UpdateParam["NetVersion"].."\n当前客户端版本"..UpdateParam["BootVersion"].."过低\n请更新替换后进入游戏", "ClientUpdateNotice", "立即更新", "OpenUpdateUrl")
    else
        print("可以跳过更新")
        GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("更新提示", "发现客户端新版本"..UpdateParam["NetVersion"].."\n当前客户端版本"..UpdateParam["BootVersion"].."较低", "ClientUpdateNotice", "立即更新", "OpenUpdateUrl", "跳过", "Next")
    end
end
function ClientUpdateNotice.OnShow(param)

end
function ClientUpdateNotice.Next() 
    print("ClientUpdateNotice.Next")
    GUI.CloseWnd("ClientUpdateNotice")
end

function ClientUpdateNotice.VersionBigThen(verA, verB) 
    if (not ClientUpdateNotice.IsVersion(verA)) or (not ClientUpdateNotice.IsVersion(verB)) then
        return false
    end
    local verAList = string.split(verA, ".")
    local verA1 =  tonumber(verAList[1]) or 0
    local verA2 =  tonumber(verAList[2]) or 0
    local verA3 = 0
    if #verAList > 2 then
        verA3 = tonumber(verAList[3]) or 0
    end
    local verA4 = 0
    if #verAList > 3 then
        verA4 = tonumber(verAList[4]) or 0
    end
    -- print(verA1, verA2, verA3, verA4)
    local verBList = string.split(verB, ".")
    local verB1 =  tonumber(verBList[1]) or 0
    local verB2 =  tonumber(verBList[2]) or 0
    local verB3 = 0
    if #verBList > 2 then
        verB3 = tonumber(verBList[3]) or 0
    end
    local verB4 = 0
    if #verBList > 3 then
        verB4 = tonumber(verBList[4]) or 0
    end
    
    -- print(verB1, verB2, verB3, verB4)
    if verA1 > verB1 then
        return true
    elseif verA1 < verB1 then
        return false
    end
    if verA2 > verB2 then
        return true
    elseif verA2 < verB2 then
        return false
    end
    if verA3 > verB3 then
        return true
    elseif verA3 < verB3 then
        return false
    end
    if verA4 > verB4 then
        return true
    else
        return false
    end

end

function ClientUpdateNotice.IsVersion(ver)
    local verArray = string.split(ver, ".")
    -- 按.分割, 长度在2-4之间
    if #verArray < 2 or #verArray > 4 then
        return false
    end
    return true
end