local GlobalUtils = {}
_G.GlobalUtils = GlobalUtils

-- require的脚本 只会使用官方的
require("SkillItemUtil")

function GlobalUtils.ShowBoxMsg1Btn(title, msg, scriptName, name_1stBtn, method_1stBtn, method_closeBtn, customData)

    GlobalUtils.ShowBoxMsg(title, msg, scriptName, name_1stBtn, method_1stBtn, nil, nil,
            true, method_closeBtn, nil, nil, nil, customData);

end

function GlobalUtils.ShowBoxMsg2Btn(title, msg, scriptName, name_1stBtn, method_1stBtn, name_2ndBtn, method_2ndBtn, method_closeBtn, customData)

    GlobalUtils.ShowBoxMsg(title, msg, scriptName, name_1stBtn, method_1stBtn, name_2ndBtn, method_2ndBtn,
            true, method_closeBtn, nil, nil, nil, customData);

end

function GlobalUtils.ShowBoxMsg1BtnNoCloseBtn(title, msg, scriptName, name_1stBtn, method_1stBtn, customData)

    GlobalUtils.ShowBoxMsg(title, msg, scriptName, name_1stBtn, method_1stBtn, nil, nil,
            nil, nil, nil, nil, nil, customData);

end

function GlobalUtils.ShowBoxMsg2BtnNoCloseBtn(title, msg, scriptName, name_1stBtn, method_1stBtn, name_2ndBtn, method_2ndBtn, customData)

    GlobalUtils.ShowBoxMsg(title, msg, scriptName, name_1stBtn, method_1stBtn, name_2ndBtn, method_2ndBtn,
            nil, nil, nil, nil, nil, customData);
end

---@public
---@param title string 必填
---@param msg string 必填
---@param scriptName string 必填
---@param name_1stBtn string 必填
---@param method_1stBtn string 选填
---@param name_2ndBtn string 选填
---@param method_2ndBtn string 选填
---@param hasCloseBtn boolean 选填
---@param method_closeBtn string 选填
---@param timeType number 选填
---@param time number 选填
---@param isGreenBtn boolean 选填
---@param customData string 选填
function GlobalUtils.ShowBoxMsg(title, msg, scriptName, name_1stBtn, method_1stBtn, name_2ndBtn, method_2ndBtn, hasCloseBtn, method_closeBtn, timeType, time, isGreenBtn, customData)
    if not title or not msg or not name_1stBtn or title == "" or msg == "" then
        return ;
    end

    method_1stBtn = method_1stBtn or "";
    name_2ndBtn = name_2ndBtn or "";
    method_2ndBtn = method_2ndBtn or "";
    hasCloseBtn = hasCloseBtn or false;
    method_closeBtn = method_closeBtn or "";
    timeType = timeType or 0;
    time = time or 0;
    isGreenBtn = isGreenBtn or false;
    customData = customData or "";

    CL.SendNotify(NOTIFY.ShowBoxMsg, title, msg, scriptName, name_1stBtn, method_1stBtn, name_2ndBtn, method_2ndBtn, hasCloseBtn, method_closeBtn, timeType, time, isGreenBtn, customData);
end

function GlobalUtils.UseItem(guid)
    if not PetUI then
        require "PetUI"
    end
    if not QuikOpenConfig then
        require "QuikOpenConfig"
    end

    local itemId = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id, guid));
    if itemId == nil or itemId == 0 then
        itemId = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id, guid, item_container_type.item_container_gem_bag));
    end

    -- 如果无法获取到物品ID，则从侍从背包中看看能不能获取到
    if itemId == nil or itemId == 0 then
        itemId = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id, guid, item_container_type.item_container_guard_bag));
    end

    local itemDB = DB.GetOnceItemByKey1(itemId);

    local quickConfig = QuikOpenConfig.KeyNameConf[itemDB.KeyName]
    if quickConfig ~= nil then
        GetWay.Def[quickConfig.GuideType].jump(quickConfig.GuideCoef1, quickConfig.GuideCoef2, quickConfig.GuideCoef3, tostring(guid));
        return ;
    end

    local quickConfig = QuikOpenConfig.TypeConf[itemDB.Type .. "-" .. itemDB.Subtype .. "-" .. itemDB.Subtype2]
    if quickConfig ~= nil then
        GetWay.Def[quickConfig.GuideType].jump(quickConfig.GuideCoef1, quickConfig.GuideCoef2, quickConfig.GuideCoef3, tostring(guid));
        return ;
    end

    local quickConfig = QuikOpenConfig.KeyNameConf2[itemDB.KeyName]
    if quickConfig ~= nil then
        GetWay.Def[quickConfig.GuideType].jump(quickConfig.GuideCoef1, quickConfig.GuideCoef2, quickConfig.GuideCoef3, tostring(itemDB.KeyName));
        return ;
    end

    local quickConfig = QuikOpenConfig.TypeConf2[itemDB.Type .. "-" .. itemDB.Subtype .. "-" .. itemDB.Subtype2]
    if quickConfig ~= nil then
        GetWay.Def[quickConfig.GuideType].jump(quickConfig.GuideCoef1, quickConfig.GuideCoef2, quickConfig.GuideCoef3, tostring(guid));
        return ;
    end

    -----------------------------------------
    if itemDB.KeyName == "活动抽奖" then
        GUI.OpenWnd("ActivityCollectUI")
        return ;
    end
    -----------------------------------------

    --混元石
    if itemDB.Type == 3 and itemDB.Subtype == 7 and itemDB.Subtype2 == 26 then
        GUI.OpenWnd("PetEquipRepairUI")
        return
    end
    --神秘宝石
    if itemDB.Type == 3 and itemDB.Subtype == 9 and itemDB.Subtype2 == 9 then
        GUI.OpenWnd("LoadingTipUI", "2000#宝石鉴定中...#0")
        local func = function()
            CL.SendNotify(NOTIFY.UseItem, tostring(guid));
        end
        LoadingTipUI.SetEndFunc(func)
        return ;
    end

    -- (宠物蛋)Type="3" Subtype="15" Subtype2="1"
    -- (变异宠物蛋)Type="3" Subtype="15" Subtype2="2"
    -- (培养液)Type="3" Subtype="20" Subtype2="0"
    if (itemDB.Type == 3 and
            (itemDB.Subtype == 15 or itemDB.Subtype == 20) and
            (itemDB.Subtype2 == 0 or itemDB.Subtype2 == 1 or itemDB.Subtype2 == 2)) then

        GUI.OpenWnd("PetHatchUI", tostring(guid))
        return
    end

    -- 如果是喇叭，跳转到喇叭频道
    if itemDB.Type == 3 and itemDB.Subtype == 24 then
        GUI.OpenWnd('ChatUI', 'index:5')
        -- 关闭背包界面
        GUI.CloseWnd('BagUI')
        return
    end

    -- 如果是特技特效卷轴，跳转到特技，特效界面并选中其卷轴
    if itemDB.Type == 3 and (itemDB.Subtype == 27 or itemDB.Subtype == 28) then
        local index2 = 2
        if itemDB.Subtype == 28 then
            index2 = 3
        end
        GUI.OpenWnd('EquipUI', 'index:3,index2:' .. index2 .. ',itemGuid:' .. tostring(guid))
        return
    end
    -- 如果是翅膀进阶道具，跳转到羽翼成长界面
    if itemDB.Type == 3 and itemDB.Subtype == 30 then
        if BagUI then
            BagUI.OnWingTabBtnClick()
        end
        --GUI.OpenWnd('BagUI','index:4,index2:1')
        return
    end

    -- 如果是羽翼
    if itemDB.Type == 3 and (itemDB.Subtype == 30 or itemDB.Subtype == 29) then
        -- 判断包裹界面是否打开,如果已打开，则执行点击羽翼页签事件，执行点击羽翼界面中成长界面事件
        local bag_ui = GUI.GetWnd('BagUI')
        if GUI.GetVisible(bag_ui) then
            if BagUI.OnWingTabBtnClick() then
                WingUI.OnGrowingSubTabBtnClick()
            end
            return
        else
            -- 如果未打开包裹界面，则直接退出,不跳转到羽翼界面
            return
        end
    end
	
    -- 如果是坐骑
    if itemDB.Type == 2 and itemDB.Subtype == 48 then 
		if itemDB.Subtype2 == 4 then
			CL.StartMove("20037")
			return
		else
			-- 判断包裹界面是否打开,如果已打开，则执行点击羽翼页签事件，执行点击羽翼界面中成长界面事件
			local bag_ui = GUI.GetWnd('BagUI')
			if GUI.GetVisible(bag_ui) then
				GlobalProcessing.JumpTabIndexMountUI(itemDB.Id)
				BagUI.OnMountTabBtnClick()
				-- if BagUI.OnMountTabBtnClick() then
					-- WingUI.OnGrowingSubTabBtnClick()
				-- end
				return
			else
				-- 如果未打开包裹界面，则直接退出,不跳转到羽翼界面
				return
			end
		end
    end

    -- 如果是好感度材料
    if itemDB.Type == 3 and itemDB.Subtype == 25 then
        -- 跳转到赠送礼物界面
        GUI.OpenWnd("GivenPresentUI")
        -- 关闭背包界面
        -- GUI.CloseWnd('BagUI')
        return
    end

    -- 如果是修炼丹
    if itemDB.Type == 3 and itemDB.Subtype == 19 then
        GUI.OpenWnd('RoleSkillUI', 'index:3,index2:1')
        -- 关闭背包界面
        -- GUI.CloseWnd('BagUI')
        return
    end
    -- 如果是装备类材料
    if itemDB.Type == 3 and itemDB.Subtype == 7 then
        -- 打造类材料
        if itemDB.ShowType == "炼化材料" then
            GUI.OpenWnd('EquipUI', 'index:3,index2:1')
            -- 关闭背包界面
            -- GUI.CloseWnd('BagUI')
            return
        end
        -- 强化相关
        if itemDB.Subtype2 == 23 or itemDB.Subtype2 == 24 then
            GUI.OpenWnd('EquipUI', 'index:1,index2:3')
            -- GUI.CloseWnd('BagUI')
            return
        end
        -- 打造相关
        if itemDB.Subtype2 >= 0 and itemDB.Subtype2 <= 25 then
            GUI.OpenWnd('EquipUI', 'index:1,index2:2')
            -- GUI.CloseWnd('BagUI')
            return
        end
        -- 跳转到装备界面
        GUI.OpenWnd("EquipUI")
        -- 关闭背包界面
        -- GUI.CloseWnd('BagUI')
        return
    end

    -- 如果是染色类材料
    if itemDB.Type == 3 and itemDB.Subtype == 26 then
        -- 寻路染色NPC
        GetWay.Def[2].jump(20037)
        -- 关闭背包界面
        GUI.CloseWnd('BagUI')
        return
    end
    -- 天梯相关
    if itemDB.Type == 3 and itemDB.Subtype == 23 and itemDB.Subtype2 == 0 then
        GetWay.Def[2].jump(10220)
        -- 关闭背包界面
        GUI.CloseWnd('BagUI')
        return
    end
    -- 离婚物品
    if itemDB.ShowType == "离婚物品" then
        GetWay.Def[2].jump(20042)
        -- 关闭背包界面
        GUI.CloseWnd('BagUI')
        return
    end
    -- 结婚物品
    if itemDB.ShowType == "结婚物品" then
        GetWay.Def[2].jump(20043)
        -- 关闭背包界面
        GUI.CloseWnd('BagUI')
        return
    end
    -- 结婚红包
    if itemDB.ShowType == "结婚礼包" then
        GetWay.Def[2].jump(20041)
        -- 关闭背包界面
        GUI.CloseWnd('BagUI')
        return
    end

    -- 仙魂灵玉
    if itemDB.ShowType == "仙兽兑换" then
        GUI.OpenWnd("ShopStoreUI")
        GUI.CloseWnd('BagUI')
        return
    end

        -- 侍从命魂
    if itemDB.Type == 3 and itemDB.Subtype == 17 then
        if itemDB.KeyName == "命魂洗练" or itemDB.KeyName == "命魂洗练锁" then
            local wnd = GUI.GetWnd('GuardSoulUI')
            if GUI.GetVisible(wnd) then
                GuardSoulUI.on_reinforced_tab_btn_click('baptize')
            else
                GUI.OpenWnd('GuardSoulUI','index:2,index2:2')
            end
        end
        GUI.CloseWnd("BagUI")
        return 
    end

    --if itemDB.Type == 2 and itemDB.Subtype == 9 and itemDB.Subtype2== 0 then
    --    GUI.OpenWnd("BattleSeatUI")
    --    GUI.CloseWnd('BagUI')
    --    GUI.CloseWnd('CommerceUI')
    --    CL.SendNotify(NOTIFY.UseItem, tostring(guid));
    --    return
    --end

    CL.SendNotify(NOTIFY.UseItem, tostring(guid));
end

function GlobalUtils.UseAllItem(guid)
    --local amount= tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, guid)) 
    --CL.SendNotify(NOTIFY.UseAllItem, tostring(guid),amount);
    CL.SendNotify(NOTIFY.UseAllItem, tostring(guid));
end

function GlobalUtils.CheckCanUseAll(itemDB)

    if itemDB.Type == 2 then

        local subtypes = { 1, 3,7, 14, 15, 25, 26, 40, 42, 43 };
        for i = 1, #subtypes do
            if itemDB.Subtype == subtypes[i] then
                return true;
            end
        end
    end

    return false

end

function GlobalUtils.CheckEqiupCanUse(itemDB, guardGuid)

    if itemDB.Id == 0 then
        return false;
    end

    if itemDB.Type ~= 1 then
        return false;
    end
    local itemAttDB = DB.GetItem_Att(itemDB.Id, itemDB.KeyName)
    for i = 1, #EquipLogic.attrT do
        if EquipLogic.attrT[i].IsShow(itemDB, itemAttDB) and not EquipLogic.attrT[i].CanUse(itemDB, itemAttDB, guardGuid) then
            return false
        end
    end
    return true
end

-- 获取锁屏的时间（单位：分钟）
---@public
---@return int
function GlobalUtils.GetScreenLockTime()
    return 3 -- 锁屏时间3分钟
end

function GlobalUtils.PairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0                 -- iterator variable
    local iter = function()
        -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

function GlobalUtils.PlayMapBgm()
    local mapid = "ID_" .. tostring(CL.GetCurrentMapId())
    CL.PlayBgm(mapid)
end

function GlobalUtils.GetSkillCost(skillId, level, skillDB)
    if not skillId or not level then
        return 0
    end
    skillDB = skillDB or DB.GetOnceSkillByKey1(skillId)
    local per = tonumber(tostring(skillDB.Cost1Coef2))
    if per > 0 then
        return per / 100, true
    end
    return skillDB.Cost1Coef3 + level * skillDB.Cost1Coef1 / 10000, false
end

function GlobalUtils.GetSkillCostStr(skillId, level, skillDB)
    skillDB = skillDB or DB.GetOnceSkillByKey1(skillId)
    local cost, isPercent = GlobalUtils.GetSkillCost(skillId, level, skillDB)
    cost = tostring(cost)
    if cost == "0" then
        cost = "无消耗"
    else
        local attrDB = DB.GetOnceAttrByKey1(skillDB.Cost1)
        if isPercent then
            cost = cost .. "%"
        end
        cost = cost .. attrDB.ChinaName
    end
    return cost
end

function GlobalUtils.GetSkillTargetNumTips(skillId, performance, skillConfig)
    performance = performance or 0
    skillConfig = skillConfig or DB.GetOnceSkillByKey1(skillId)
    local value, num = 1, skillConfig["Level1TargetNum"]
    for i = 1, 4 do
        local value1 = skillConfig["Level" .. i .. "Value"]
        local value2 = skillConfig["Level" .. (i + 1) .. "TargetNum"]
        if not value1 or not value2 then
            return nil
        end
        value = value1
        num = value2
        if value1 > performance then
            break
        end
    end
    if num <= 0 then
        return nil
    end
    return string.format("*熟练度达到%d，可对%d目标使用", value, num)
end

local DayToSecond = 24 * 60 * 60
local HourToSecond = 60 * 60
local MinsToSecond = 60
function GlobalUtils.GetTimeString(second)
    local format = "%02d:%02d:%02d"
    second = second >= 0 and second or 0
    local h = math.floor(second / HourToSecond)
    local m = math.floor((second % HourToSecond) / MinsToSecond)
    local s = second % MinsToSecond
    return string.format(format, h, m, s)
end

function GlobalUtils.GetPassTimeDesc(time)
    local day = math.floor(time / DayToSecond)
    local hour = math.floor((time % DayToSecond) / HourToSecond)
    local minute = math.floor((time % HourToSecond) / MinsToSecond)
    local second = time % MinsToSecond
    if day > 30 then
        return "大于30天"
    end
    if day > 0 and day < 30 then
        return day .. "天前"
    end

    if hour > 0 then
        return hour .. "小时前"
    end

    if minute > 0 then
        return minute .. "分钟前"
    end

    if second >= 0 then
        return "小于1分钟"
    end
end

--根据传过来的时间，返回日-小时-分钟-秒(保留一位）
function GlobalUtils.Get_DHMS1_BySeconds(time)
    time = tonumber(tostring(time));
    local day, hour, minute, second = 0, 0, 0, 0;
    if time <= 0 then
        return day, hour, minute, second;
    end
    day = math.floor(time / 24 / 60 / 60)
    hour = math.floor(time / 3600) % 24
    minute = math.floor(time / 60) % 60
    second = math.floor(time % 60)

    return day, hour, minute, second;
end

--根据传过来的时间，返回日-小时-分钟-秒(保留两位)
function GlobalUtils.Get_DHMS2_BySeconds(time)
    time = tonumber(tostring(time));
    local day, hour, minute, second = "00", "00", "00", "00";
    if time <= 0 then
        return day, hour, minute, second;
    end
    day = math.floor(time / DayToSecond)
    hour = math.floor(time / HourToSecond) % 24
    minute = math.floor(time / MinsToSecond) % 60
    second = math.floor(time % MinsToSecond)

    if day < 10 then
        day = "0" .. day;
    end

    if hour < 10 then
        hour = "0" .. hour;
    end

    if minute < 10 then
        minute = "0" .. minute;
    end

    if second < 10 then
        second = "0" .. second;
    end
    return tostring(day), tostring(hour), tostring(minute), tostring(second);
end

function GlobalUtils.ShowServerBoxMessage(msg, time)
	--print("ShowServerBoxMessage:" .. msg)
	if time == nil then
		GlobalUtils.ShowBoxMsg2Btn("提示", msg, "GlobalUtils", "确认", "ServerBoxMessageAck", "取消")
	else
		GlobalUtils.ShowBoxMsg("提示", msg, "GlobalUtils", "确认", "ServerBoxMessageAck", "取消", nil, true, nil, 1, time);
	end
end

function GlobalUtils.ShowServerBoxMessageEx(msg, time)
	--print("ShowServerBoxMessage:" .. msg)
	if time == nil then
		GlobalUtils.ShowBoxMsg2Btn("提示", msg, "GlobalUtils", "确认", "ServerBoxMessageAck", "取消", "ServerBoxMessageCancel","ServerBoxMessageCancel")
	else
		GlobalUtils.ShowBoxMsg("提示", msg, "GlobalUtils", "确认", "ServerBoxMessageAck", "取消", "ServerBoxMessageCancel", true, "ServerBoxMessageCancel", 1, time);
	end
end


function GlobalUtils.ServerBoxMessageAck()
	--print("ServerBoxMessageAck")
	CL.SendNotify(NOTIFY.SubmitForm, "FormConfirm", "Main")
end

function GlobalUtils.ServerBoxMessageCancel()
	--print("ServerBoxMessageAck")
	CL.SendNotify(NOTIFY.SubmitForm, "FormConfirm", "Cancel")
end

function GlobalUtils.ShowServerBoxMessage1Btn(msg, time)
	--print("ShowServerBoxMessage1Btn:" .. msg)
	if time == nil then
		GlobalUtils.ShowBoxMsg("提示", msg, "GlobalUtils", "确认", "ServerBoxMessageAck");
	else
		GlobalUtils.ShowBoxMsg("提示", msg, "GlobalUtils", "确认", "ServerBoxMessageAck", nil, nil, nil, nil, 1, time);
	end
end


--一掷千金
function GlobalUtils.ShowServerBoxMessage1HaveTitleBtn(title,msg,name_1stBtn,time)
    --print("ShowServerBoxMessage1Btn:" .. msg)
    if time == nil then
        GlobalUtils.ShowBoxMsg(title, msg, "GlobalUtils", name_1stBtn, "ServerBoxMessageAck");
    else
        GlobalUtils.ShowBoxMsg(title, msg, "GlobalUtils", name_1stBtn, "ServerBoxMessageAck", nil, nil, true, nil, 1, time);
    end
end




function GlobalUtils.StartRecord()
    if CL.StartRecord() then
        GUI.OpenWnd("RecordUI")
        return true
    end
    return false
end

function GlobalUtils.RecordBtnPointerHandle(isEnter)
    if RecordUI and RecordUI.InitRecordBg then
        RecordUI.InitRecordBg(isEnter and 0 or 1)
    end
end

local Min_Record_Time = 1 -- 最短语音时间
-- 录音结束处理
function GlobalUtils.RecordFinishHandle(giveup)
    GUI.CloseWnd("RecordUI")
    if not giveup then
        if CL.GetRecordTime() > Min_Record_Time then
            CL.EndRecord(true)
            return
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "语音时间太短")
        end
    end
    CL.EndRecord(false)
end

-- 拼湊語音富文本
function GlobalUtils.MakeUpRecordMsg(fileName, time)
    return "#RECORDLINK<RecordName:" .. fileName .. ",Time:" .. time .. ">#"
end

--获取语音信息
function GlobalUtils.GetRecordInfo(msg)
    if msg then
        if string.find(msg, "#RECORDLINK<RecordName:(.-),Time:(.-)>#") ~= nil then
            local tmp1, tmp2, recordName, time = string.find(msg, "#RECORDLINK<RecordName:(.-),Time:(.-)>#")
            return recordName, time
        end
    end
    return nil, nil
end

function GlobalUtils.GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end

    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))

    return nRet;
end

function GlobalUtils.JoinActivity(activityID)
    if not activityID then
        return
    end
    --0无队伍，1暂离，2队长，3队员
    local teamState = LD.GetRoleInTeamState()
    if teamState == 3 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "操作失败，您不是队长无法使用该功能")
        return
    end
    CL.SendNotify(NOTIFY.JoinActivity, activityID)
end

function GlobalUtils.GetSkillIconTypeTipString(skillId)
    local skill = DB.GetOnceSkillByKey1(skillId);
    if skill == nil then
        test("skillIcon is null")
        return "";
    end
    local hurtTypeInfo = string.split(skill.DisplayDamageType, "|")
    if hurtTypeInfo ~= nil then
        return hurtTypeInfo[1];
    end
    return skill.Hurt;
end

-- 技能Icon 右上角技能类型角标  Hurt="治疗|1801507030"
function GlobalUtils.AddSkillIconTypeTipSp(skillIcon, skillId, x, y)
    if skillIcon == nil then
        test("skillIcon is null")
        return ;
    end

    x = x or 4
    y = y or 0

    local TypeTipSp = GUI.GetChild(skillIcon, "TypeTipSp");
    local skill = DB.GetOnceSkillByKey1(skillId);
    if skill == nil then
        test("skillIcon is null")
        if TypeTipSp then
            GUI.SetVisible(TypeTipSp, false);
        end
        return ;
    end

    local hurtTypeInfo = string.split(skill.DisplayDamageType, "|")
    if hurtTypeInfo ~= nil and #hurtTypeInfo > 1 then
        if not TypeTipSp then
            TypeTipSp = GUI.ImageCreate(skillIcon, "TypeTipSp", hurtTypeInfo[2], x, y);
            UILayout.SetAnchorAndPivot(TypeTipSp, UIAnchor.TopRight, UIAroundPivot.TopRight)
        else
            GUI.ImageSetImageID(TypeTipSp, hurtTypeInfo[2])
            GUI.SetVisible(TypeTipSp, true);
        end
        return ;
    end
    if TypeTipSp then
        GUI.SetVisible(TypeTipSp, false);
    end
end

function GlobalUtils.GetEquipSuitConfig(config)
    print("GlobalUtils.GetEquipSuitConfig")

    if CL.GetMode() == 1 then
        local inspect = require("inspect")
        print(inspect(config))
    end

    GlobalUtils.suitConfig = config;
end

function GlobalUtils.ChangeByItem(config)
    print("GlobalUtils.ChangeByItem")
    if CL.GetMode() == 1 then
        local inspect = require("inspect")
        print(inspect(config))
    end

    GlobalUtils.suitChangeItemConfig = config;
end

function GlobalUtils.GetMainLineUpPetGuid()
	local list = UIDefine.NowLineupList
	return list and list[0] ~= "-1" and uint64.new(list[0]) or uint64.zero
end



function GlobalUtils.ItemToMall(key)

    --判断key是否为id，或为Keyname
    GlobalUtils.MallItemKey = tonumber(key)
    if GlobalUtils.MallItemKey ~= nil then
        local itemDB = DB.GetOnceItemByKey1(key)
        GlobalUtils.MallItemKey = itemDB.KeyName
    else
        GlobalUtils.MallItemKey = key
    end

    if GlobalUtils.MallItemData then
        test("已有商城数据")
        return GlobalUtils.RefreshMallData()
    else
        GlobalUtils.GetMallData()
    end

end

function GlobalUtils.GetMallData()
    CL.SendNotify(NOTIFY.SubmitForm, "FormMall", "GetAllData")
end

function GlobalUtils.RefreshMallData()
    --test("==============="..tostring(GlobalUtils.MallItemKey).."==================")
    local index1 = 0
    local index2 = 0
    local index3 = 0

    if GlobalUtils.MallItemKey ~= nil then
        local itemDB = DB.GetOnceItemByKey2(GlobalUtils.MallItemKey)
        if itemDB.FromItem ~= 0 then
            local CurItemDB = DB.GetOnceItemByKey1(itemDB.FromItem)
            GlobalUtils.MallItemKey = CurItemDB.KeyName
        end
        for i = 1, #GlobalUtils.MallItemType do
            if index1 == 0 then
				GlobalUtils.Type = (GlobalUtils.MallItemType[i]).Classify
                for j = 1, #GlobalUtils.Type do
                    if index1 == 0 then
                        for k = 1, #GlobalUtils.MallItemData[i][GlobalUtils.Type[j]] do
                            if index1 == 0 then
                                if GlobalUtils.MallItemData[i][GlobalUtils.Type[j]][k].keyname == GlobalUtils.MallItemKey then
                                    index1 = i
                                    index2 = j
                                    index3 = k
                                end
                            else
                                break
                            end
                        end
                    else
                        break
                    end
                end
            else
                break
            end
        end
        --test("=============="..index1.."================")
        --test("=============="..index2.."================")
        --test("=============="..index3.."================")
		GlobalUtils.MallItemKey = nil
        if index1 ~= 0 and index2 ~= 0 and index3 ~= 0 then
            if not MallUI then
                require 'MallUI'
            end
            MallUI._parameter = { index1, index2, index3 }
            return index1, index2, index3
        else
            return
        end
    else
        return
    end
end

function GlobalUtils.InitAnimationSoundConfig()
    require("Animation_Sounds_table")
    LD.ClearAnimationSoundConfig()
    if Animation_SoundsTable_Id then
        for i, v in pairs(Animation_SoundsTable_Id) do
            LD.AddAnimationSoundConfig(v.ModelID, v.AnimeName, v.SoundID, v.Probability)
        end
    end
end

function GlobalUtils.ReloadSDKPlugin()
    if GameMessageCenter and GameMessageCenter.Main then
        require("SDKPluginCenter")
        SDKPluginCenter.Init()
    end
end
GlobalUtils.ReloadSDKPlugin()



-- 将颜色rgb十六进制转换为10进制
-- 将rgb16进制转换为10进制
function GlobalUtils.getRGBDecimal(RGBHexadecimal)
    if RGBHexadecimal == nil then
        test(" 转换rgb十六进制失败  传入参数为空")
        return
    end

    if string.sub(RGBHexadecimal,1,1) ~= "#" then
        test(" 转换rgb十六进制失败 传入参数不是以#开头")
        return
    end

    if string.len(RGBHexadecimal) < 7 then
        test("转换rgb十六进制失败 传入参数小于7个")
        return 
    end

    -- 取出值
    local hexR = string.sub(RGBHexadecimal,2,3)
    local hexG = string.sub(RGBHexadecimal,4,5)
    local hexB = string.sub(RGBHexadecimal,6,7)
    local hexLucency = nil
    if string.len(RGBHexadecimal) > 7 then
        hexLucency = string.sub(RGBHexadecimal,8,9)
    end

    -- 开始转换
    local r = tonumber(hexR,16)
    local g = tonumber(hexG,16)
    local b = tonumber(hexB,16)
    local l = nil
    if hexLucency then
        l = tonumber(hexLucency,16)
    end

    if r == nil or g == nil or b == nil then
        test("转换rgb十六进制失败 转换数值有空值")
        return 
    end

    return r,g,b,l
end


--长按短按触发事件，function不加()传进来
function GlobalUtils.ClickOrLongClick(item,FunClick,FunLongClick)

    if GlobalUtils.RefreshClickTimer == nil then

        GlobalUtils.RefreshClickTimer = {}

    end

    if GlobalUtils.RefreshNowTimer == nil then

        GlobalUtils.RefreshNowTimer = {}

    end

    if GlobalUtils.FunClick == nil then

        GlobalUtils.FunClick = {}

    end

    if GlobalUtils.FunLongClick == nil then

        GlobalUtils.FunLongClick = {}

    end

    local guid = GUI.GetGuid(item)

    GlobalUtils.FunClick[guid] = FunClick

    GlobalUtils.FunLongClick[guid] = FunLongClick

    item:RegisterEvent(UCE.PointerUp)
    item:RegisterEvent(UCE.PointerDown)
    GUI.RegisterUIEvent(item, UCE.PointerDown, "GlobalUtils", "BtnPointDown")
    GUI.RegisterUIEvent(item, UCE.PointerUp, "GlobalUtils", "BtnPointUp")


end






function GlobalUtils.BtnPointDown(guid)

    GlobalUtils.RefreshNowTimer[guid] = os.time()

    local fun = function()
        GlobalUtils.TimerClickCallBack(guid)
    end

    GlobalUtils.StopClickTimer(guid)
    GlobalUtils.RefreshClickTimer[guid] = Timer.New(fun , 1,-1)
    GlobalUtils.RefreshClickTimer[guid]:Start()

end

function GlobalUtils.BtnPointUp(guid)

    if GlobalUtils.RefreshClickTimer[guid] == nil then



    else

        local nowTime = os.time()

        if nowTime < GlobalUtils.RefreshNowTimer[guid] + 1 then

            GlobalUtils.FunClick[guid](guid)


        else

            GlobalUtils.FunLongClick[guid](guid)

        end

        GlobalUtils.StopClickTimer(guid)

    end



end

function GlobalUtils.TimerClickCallBack(guid)

    local nowTime = os.time()

    if nowTime >= GlobalUtils.RefreshNowTimer[guid] + 1 then

        GlobalUtils.FunLongClick[guid](guid)
        GlobalUtils.StopClickTimer(guid)

    end

end

--计时器停止
function GlobalUtils.StopClickTimer(guid)

    if GlobalUtils.RefreshClickTimer[guid] ~= nil then
        GlobalUtils.RefreshClickTimer[guid]:Stop()
        GlobalUtils.RefreshClickTimer[guid] = nil
    end

end
