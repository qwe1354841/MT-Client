local FactionFightBtnUI = {}

_G.FactionFightBtnUI = FactionFightBtnUI
local GuidCacheUtil = nil --UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local messageEventList = {
    { GM.FightStateNtf, "OnInFight" },
}

local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local outLineColor = Color.New(180 / 255, 92 / 255, 31 / 255, 255 / 255)
local defaultColor = Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255)

local GuardTypePic = --侍从类型标记
{ "1800607240", "1800607250", "1800607260", "1800607280", "1800607270", }

local GuardTypeName = { "物理型", "魔法型", "治疗型", "控制型", "辅助型" }

FactionFightBtnUI.WillStartFight = nil

function FactionFightBtnUI.Main(parameter)
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("FactionFightBtnUI", "FactionFightBtnUI", 0, 0, eCanvasGroup.Top)
    GUI.SetIgnoreChild_OnVisible(panel, true)
    -- -- 移动的按钮
    -- 	local moveGroup = GUI.GroupCreate( panel, "moveGroup", 0, -220, 1, 1)
    -- 	GUI.SetAnchor(moveGroup,UIAnchor.Center)
    -- 	GUI.SetPivot(moveGroup,UIAroundPivot.Center)
    -- 	GUI.StartGroupDrag(moveGroup)
    -- 	local factionFightBtn = GUI.ImageCreate( moveGroup,  "factionFightBtn" , "1800602300",0,0)
    -- 	GUI.SetAnchor(factionFightBtn,UIAnchor.Center)
    -- 	GUI.SetPivot(factionFightBtn,UIAroundPivot.Center)
    -- 	GUI.SetIsRaycastTarget(factionFightBtn,true)
    -- 	factionFightBtn:RegisterEvent(UCE.PointerClick)
    -- 	GUI.RegisterUIEvent(factionFightBtn , UCE.PointerClick , "FactionFightBtnUI", "OnFactionFightBtnClick")

    -- 组队成功提示
    local backGround2 = GUI.ImageCreate(panel, "backGround2", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    GuidCacheUtil.BindName(backGround2, "backGround2")
    SetAnchorAndPivot(backGround2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(backGround2, true)
    backGround2:RegisterEvent(UCE.PointerClick)
    GUI.SetVisible(backGround2, false)

    local backGround = GUI.ImageCreate(backGround2, "backGround", "1800400220", 0, 0, false, GUI.GetWidth(panel), 550)
    SetAnchorAndPivot(backGround, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(backGround, true)
    backGround:RegisterEvent(UCE.PointerClick)

    local startTipsSprite = GUI.ImageCreate(backGround, "startTipsSprite", "1800604780", 0, -280)
    SetAnchorAndPivot(startTipsSprite, UIAnchor.Center, UIAroundPivot.Center)

    local timeTipsSpriteBack = GUI.ImageCreate(backGround, "timeTipsSpriteBack", "1800601290", 0, 0)
    SetAnchorAndPivot(timeTipsSpriteBack, UIAnchor.Center, UIAroundPivot.Center)

    local timeTipsSprite = GUI.ImageCreate(backGround, "timeTipsSprite", "1800605213", 0, 0)
    GuidCacheUtil.BindName(timeTipsSprite, "timeTipsSprite")
    SetAnchorAndPivot(timeTipsSprite, UIAnchor.Center, UIAroundPivot.Center)

    local leftGroup = GUI.GroupCreate(backGround, "leftGroup", 0, 0, 1, 1)
    GuidCacheUtil.BindName(leftGroup, "leftGroup")
    SetAnchorAndPivot(leftGroup, UIAnchor.Center, UIAroundPivot.Center)

    local rightGroup = GUI.GroupCreate(backGround, "rightGroup", 0, 0, 1, 1)
    GuidCacheUtil.BindName(rightGroup, "rightGroup")
    SetAnchorAndPivot(rightGroup, UIAnchor.Center, UIAroundPivot.Center)

    for i = 1, 5 do
        local child = GUI.ImageCreate(leftGroup, "child_" .. i, "1800601280", -440 + i * 6, 110 * i - 330)
        SetAnchorAndPivot(child, UIAnchor.Center, UIAroundPivot.Center)

        child = GUI.GroupCreate(child, "child", 0, 0, 1, 1)
        SetAnchorAndPivot(child, UIAnchor.Center, UIAroundPivot.Center)

        local jobSp = GUI.ImageCreate(child, "jobSp", "1800903010", -115, -22)
        SetAnchorAndPivot(child, UIAnchor.Center, UIAroundPivot.Center)
        local playerName = GUI.CreateStatic(child, "playerName", "少侠尊姓大名", 10, -22, 210, 32, "system", false, false)
        FactionFightBtnUI.SetTextBasicInfo(playerName, defaultColor, TextAnchor.MiddleLeft, 24)
        local fightLogo = GUI.ImageCreate(child, "fightLogo", "1800407010", -140, 22)
        SetAnchorAndPivot(fightLogo, UIAnchor.Center, UIAroundPivot.Center)
        --fightLogo = GUI.ImageCreate(child, "fightLogo2", "1800404020", -61, 22)
        fightLogo = GUI.CreateStatic(child, "fightLogo2", "角色战力", -73, 20, 150, 40)
        GUI.StaticSetFontSize(fightLogo, UIDefine.FontSizeL)
        GUI.SetColor(fightLogo, UIDefine.Brown8Color)
        GUI.StaticSetAlignment(fightLogo, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(fightLogo, UIAnchor.Center, UIAroundPivot.Center)
        local fightValue = GUI.CreateStatic(child, "fightValue", "99999", 55, 20, 130, 32, "system", false, false)
        FactionFightBtnUI.SetTextBasicInfo(fightValue, defaultColor, TextAnchor.MiddleLeft, 22)
        local iconBack = GUI.ImageCreate(child, "iconBack", "1800600070", 160, 0, false, 80, 80)
        SetAnchorAndPivot(iconBack, UIAnchor.Center, UIAroundPivot.Center)
        local iconSp = GUI.ImageCreate(child, "iconSp", "1900300010", 160, 0, false, 70, 70)
        SetAnchorAndPivot(iconSp, UIAnchor.Center, UIAroundPivot.Center)

        HeadIcon.CreateVip(iconSp, 60, 60)

        local guardTypeName = GUI.CreateStatic(child, "guardTypeName", "HASAKI", -88, 22, 80, 32, "system", false, false)
        FactionFightBtnUI.SetTextBasicInfo(guardTypeName, defaultColor, TextAnchor.MiddleLeft, 24)
    end

    for i = 1, 5 do
        local child = GUI.ImageCreate(rightGroup, "child_" .. i, "1800601270", 440 - i * 6, 110 * i - 330)
        SetAnchorAndPivot(child, UIAnchor.Center, UIAroundPivot.Center)

        child = GUI.GroupCreate(child, "child", 0, 0, 1, 1)
        SetAnchorAndPivot(child, UIAnchor.Center, UIAroundPivot.Center)

        local jobSp = GUI.ImageCreate(child, "jobSp", "1800903010", -91, -22)
        SetAnchorAndPivot(child, UIAnchor.Center, UIAroundPivot.Center)
        local playerName = GUI.CreateStatic(child, "playerName", "少侠尊姓大名", 34, -22, 210, 32, "system", false, false)
        FactionFightBtnUI.SetTextBasicInfo(playerName, defaultColor, TextAnchor.MiddleLeft, 24)
        local fightLogo = GUI.ImageCreate(child, "fightLogo", "1800407010", -91, 22)
        SetAnchorAndPivot(fightLogo, UIAnchor.Center, UIAroundPivot.Center)
        --fightLogo = GUI.ImageCreate(child, "fightLogo2", "1800404020", -37, 22)
        fightLogo = GUI.CreateStatic(child, "fightLogo2", "角色战力", -24, 20, 150, 40)
        GUI.StaticSetFontSize(fightLogo, UIDefine.FontSizeL)
        GUI.SetColor(fightLogo, UIDefine.Brown8Color)
        GUI.StaticSetAlignment(fightLogo, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(fightLogo, UIAnchor.Center, UIAroundPivot.Center)
        SetAnchorAndPivot(fightLogo, UIAnchor.Center, UIAroundPivot.Center)
        local fightValue = GUI.CreateStatic(child, "fightValue", "99999", 100, 20, 130, 32, "system", false, false)
        FactionFightBtnUI.SetTextBasicInfo(fightValue, defaultColor, TextAnchor.MiddleLeft, 22)
        local iconBack = GUI.ImageCreate(child, "iconBack", "1800600070", -160, 0, false, 80, 80)
        SetAnchorAndPivot(iconBack, UIAnchor.Center, UIAroundPivot.Center)
        local iconSp = GUI.ImageCreate(child, "iconSp", "1900300010", -160, 0, false, 70, 70)
        SetAnchorAndPivot(iconSp, UIAnchor.Center, UIAroundPivot.Center)

        HeadIcon.CreateVip(iconSp, 60, 60)

        local guardTypeName = GUI.CreateStatic(child, "guardTypeName", "HASAKI", -64, 22, 80, 32, "system", false, false)
        FactionFightBtnUI.SetTextBasicInfo(guardTypeName, defaultColor, TextAnchor.MiddleLeft, 24)
    end

    FactionFightBtnUI.RegisterMessage()
end

function FactionFightBtnUI.SetTextBasicInfo(txt, color, TextAnchor, txtSize)
    SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txt, txtSize)
    GUI.SetColor(txt, color)
    GUI.StaticSetAlignment(txt, TextAnchor)
end

function FactionFightBtnUI.SetButtonBasicInfo(btn, fontSize, fontColor, functionName)
    SetAnchorAndPivot(btn, UIAnchor.Center, UIAroundPivot.Center)
    btn.FontSize = fontSize
    GUI.ButtonSetTextColor(btn, fontColor)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "FactionFightBtnUI", functionName)
end

-- 注册GM消息
function FactionFightBtnUI.RegisterMessage()
    for k, v in ipairs(messageEventList) do
        CL.UnRegisterMessage(v[1], "FactionFightBtnUI", v[2])
        CL.RegisterMessage(v[1], "FactionFightBtnUI", v[2])
    end
end

function FactionFightBtnUI.OnFactionFightBtnClick()
    if FactionFightBtnUI.WhetherCanStartAutoMove() then
        local FactionFight = 20068
        local factionFight = CFG.Get_GameGlobalConfig("FactionFight")
        if factionFight ~= nil then
            FactionFight = factionFight.Value
        end
        LD.StartAutoMove(tonumber(FactionFight))
    end
end

function FactionFightBtnUI.OnShow(scriptName)
    GUI.SetVisible(GUI.GetWnd("FactionFightBtnUI"), true)
end

function FactionFightBtnUI.OnClose(scriptName)
    GUI.SetVisible(GUI.GetWnd("FactionFightBtnUI"), false)
    local backGround2 = GuidCacheUtil.GetUI("backGround2")--GUI.Get("FactionFightBtnUI/backGround2")
    GUI.SetVisible(backGround2, false)
end

--id name role_id 等级 种族 vip等级 战力值
function FactionFightBtnUI.RefreshPlayersInfo(timer, leftListS, rightListS)
    test(timer, leftListS, rightListS)
    if FactionFightUI then
        FactionFightUI.OnClose()
    end

    local leftList = {}
    local rightList = {}
    local findSelf = false
    local selfNickName = CL.GetRoleName()
    if leftListS then
        for i, v in ipairs(leftListS) do
            local tempInfo = {}
            tempInfo.Id = v[1]
            tempInfo.Job = v[3]
            tempInfo.Level = v[4]
            tempInfo.Name = v[2]
            tempInfo.FightValue = v[7]
            tempInfo.Vip = v[6]
            table.insert(leftList, tempInfo)
            if tempInfo.Name == selfNickName then
                findSelf = true
            end
        end
    end

    if rightListS then
        for i, v in ipairs(rightListS) do
            local tempInfo = {}
            tempInfo.Id = v[1]
            tempInfo.Job = v[3]
            tempInfo.Level = v[4]
            tempInfo.Name = v[2]
            tempInfo.FightValue = v[7]
            tempInfo.Vip = v[6]
            table.insert(rightList, tempInfo)
        end
    end
    if findSelf then
        leftList, rightList = rightList, leftList
    end
    FactionFightBtnUI.RefreshPlayerList(leftList, rightList)
    FactionFightBtnUI.ShowTimeDown(tonumber(timer))
end

function FactionFightBtnUI.RefreshPlayerList(leftList, rightList)
    test("RefreshPlayerList: ", leftList, rightList)
    local leftGroup = GuidCacheUtil.GetUI("leftGroup") -- GUI.Get("FactionFightBtnUI/backGround2/backGround/leftGroup")
    local rightGroup = GuidCacheUtil.GetUI("rightGroup") -- GUI.Get("FactionFightBtnUI/backGround2/backGround/rightGroup")

    local lists = leftList
    local group = leftGroup
	
    for j = 1, 2 do
        if j == 2 then
            lists = rightList
            group = rightGroup
        end

        for i = 1, 5 do
            local child = GUI.GetChild(group, "child_" .. i)
            child = GUI.GetChild(child, "child")
            if child ~= nil then
                if lists[i] then
                    local info = lists[i]
                    local jobSp = GUI.GetChild(child, "jobSp")
                    local playerName = GUI.GetChild(child, "playerName")
                    local fightLogo = GUI.GetChild(child, "fightLogo")
                    local fightLogo2 = GUI.GetChild(child, "fightLogo2")
                    local fightValue = GUI.GetChild(child, "fightValue")
                    local iconSp = GUI.GetChild(child, "iconSp")
                    local guardTypeName = GUI.GetChild(child, "guardTypeName")
                    -- school值为0为侍从
					local school = DB.GetSchool(info.Job)
					if tostring(school.Icon) == "0" then
					--if tonumber(info.Id) > 12 then
                        local GuardConfig = DB.GetOnceGuardByKey1(info.Id)						
                        if GuardConfig ~= nil then
                            GUI.ImageSetImageID(jobSp, GuardTypePic[GuardConfig.Type])
                            GUI.StaticSetText(playerName, info.Name)
                            GUI.StaticSetText(guardTypeName, GuardTypeName[GuardConfig.Type])
                            GUI.ImageSetImageID(iconSp, tostring(GuardConfig.Head))
                        end
                        GUI.SetVisible(fightValue, false)
                        GUI.SetVisible(fightLogo, false)
                        GUI.SetVisible(fightLogo2, false)
                        GUI.SetVisible(guardTypeName, true)
                    else
                        if school ~= nil then
                            GUI.ImageSetImageID(jobSp, tostring(school.Icon))
                        end

                        local role = DB.GetRole(info.Id)
                        if role ~= nil then
                            GUI.ImageSetImageID(iconSp, tostring(role.Head))
                        end

                        GUI.StaticSetText(playerName, info.Name)
                        GUI.StaticSetText(fightValue, info.FightValue)

                        GUI.SetVisible(fightValue, true)
                        GUI.SetVisible(fightLogo, true)
                        GUI.SetVisible(fightLogo2, true)
                        GUI.SetVisible(guardTypeName, false)

                        HeadIcon.BindRoleVipLv(iconSp, info.Vip or 0)
                    end
                end
                GUI.SetVisible(child, lists[i] ~= nil)
            end
        end
    end

    local backGround2 = GuidCacheUtil.GetUI("backGround2") --GUI.Get("FactionFightBtnUI/backGround2")
    GUI.SetVisible(backGround2, true)
end

function FactionFightBtnUI.ShowTimeDown(remainTime)
    test("ShowTimeDown", remainTime)
    FactionFightBtnUI.StopTimeDown()

    local timeTipsSprite = GuidCacheUtil.GetUI("timeTipsSprite") -- GUI.Get("FactionFightBtnUI/backGround2/backGround/timeTipsSprite")
    local backGround2 = GuidCacheUtil.GetUI("backGround2") -- GUI.Get("FactionFightBtnUI/backGround2")
    GUI.SetVisible(backGround2, true)
    if timeTipsSprite ~= nil then
        local fun = function()
            remainTime = remainTime - 1
            if remainTime > 0 then
                GUI.ImageSetImageID(timeTipsSprite, "180060521" .. remainTime)
            else
                GUI.ImageSetImageID(timeTipsSprite, "1800605213")
                GUI.SetVisible(backGround2, false)
            end
        end

        FactionFightBtnUI.WillStartFight = Timer.New(fun, 1, 3, true)
        FactionFightBtnUI.WillStartFight:Start()
    end
end

function FactionFightBtnUI.OnDestroy()
    FactionFightBtnUI.StopTimeDown()
end

function FactionFightBtnUI.StopTimeDown()
    if FactionFightBtnUI.WillStartFight ~= nil then
        FactionFightBtnUI.WillStartFight:Stop()
        FactionFightBtnUI.WillStartFight = nil
    end
end

function FactionFightBtnUI.WhetherCanStartAutoMove()
    if LD.GetRoleInTeamState(0) == 3 then
        return false
    end
    return true
end

--进战斗关界面
function FactionFightBtnUI.OnInFight(isInfight)
    if isInfight then
        GUI.CloseWnd("FactionFightBtnUI")
    end
end
