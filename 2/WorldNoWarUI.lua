--“天下会武” 活动界面，

-- 约定：所有从服务端拿来的数据， 1 为true ，其他为false
local WorldNoWarUI = {}

_G.WorldNoWarUI = WorldNoWarUI
local GuidCacheUtil = nil --UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
--侍从类型
local guardType = {
	{ "物理型", "1800607240" },
	{ "魔法型", "1800607250" },
	{ "治疗型", "1800607260" },
	{ "控制型", "1800607280" },
	{ "辅助型", "1800607270" },
	{ "全部", "" },
}
------------------------------------ end缓存一下全局变量end --------------------------------

WorldNoWarUI.SelfFactionName = nil
WorldNoWarUI.SelfNickName = nil
WorldNoWarUI.LeftRankList = {}

WorldNoWarUI.CurrentTeamInfo = {}
WorldNoWarUI.AwardInfoList = {}
WorldNoWarUI.RemainTimer = nil
WorldNoWarUI.GetMacthStateTimer = nil
WorldNoWarUI.HasTeam = false
WorldNoWarUI.TeamleaderGuid = 0

WorldNoWarUI.IsMatching = false
WorldNoWarUI.AutoMatchState = false
WorldNoWarUI.EasyMatchState = false
WorldNoWarUI.ReportInfos = {} --{"第一场","第二场","第三场","第四场"}

local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local outLineColor = Color.New(180 / 255, 92 / 255, 31 / 255, 255 / 255)
local defaultColor = Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255)

local messageEventList = {
    { GM.FightStateNtf, "OnInFight" },
}

function WorldNoWarUI.Main(parameter)
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    WorldNoWarUI.CreatePanel(parameter)
end

function WorldNoWarUI.CreatePanel(parameter)
    local panel = GUI.WndCreateWnd("WorldNoWarUI", "WorldNoWarUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetIgnoreChild_OnVisible(panel, true)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "天下会武", "WorldNoWarUI", "OnCloseBtnClick") --UILayout.CreateBg(panel,"天下会武")

    local timeGroup_1 = GUI.GroupCreate(panelBg, "timeGroup_1", -200, -315, 0, 0)
    local timeSprite = GUI.ImageCreate(timeGroup_1, "timeSprite", "1800408530", -145, 60)
    SetAnchorAndPivot(timeSprite, UIAnchor.Top, UIAroundPivot.Center)
    local timeTips = GUI.CreateStatic(timeGroup_1, "timeTips", "剩余时间", -60, 60, 150, 30)
    WorldNoWarUI.SetTextBasicInfo(timeTips, colorDark, TextAnchor.MiddleCenter, 22)
    GUI.SetAnchor(timeTips, UIAnchor.Top)
    local timeText = GUI.CreateStatic(timeGroup_1, "timeText", "24:00:00", 50, 60, 150, 30)
    GuidCacheUtil.BindName(timeText, "timeText")
    WorldNoWarUI.SetTextBasicInfo(timeText, colorDark, TextAnchor.MiddleCenter, 22)

    local leftBg = GUI.ImageCreate(panelBg, "leftBg", "1800400200", -180, -75, false, 686, 315)
    SetAnchorAndPivot(leftBg, UIAnchor.Center, UIAroundPivot.Center)
    local SubTitleBg = GUI.ImageCreate(leftBg, "subTitleBg", "1800700070", 0, -140, false, 683, 40)
    SetAnchorAndPivot(SubTitleBg, UIAnchor.Center, UIAroundPivot.Center)
    local subTitleList = { "排名", "角色名称", "角色战力", "活动积分", -197, -20, 145 }
    for i = 1, 4 do
        local txt = GUI.CreateStatic(SubTitleBg, "subTitleText" .. i, subTitleList[i], -450 + 170 * i, 0, 180, 30, "system", false, false)
        WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
        if i < 4 then
            local cutLine = GUI.ImageCreate(SubTitleBg, "cutLine" .. i, "1800600220", subTitleList[i + 4], 0)
            SetAnchorAndPivot(cutLine, UIAnchor.Center, UIAroundPivot.Center)
        end
    end
    local selfInfoBg = GUI.ImageCreate(leftBg, "leftSelfInfoBg", "1800600940", 0, 140, false, 683, 55)
    GuidCacheUtil.BindName(selfInfoBg, "leftSelfInfoBg")
    SetAnchorAndPivot(selfInfoBg, UIAnchor.Center, UIAroundPivot.Center)
    local txt = GUI.CreateStatic(selfInfoBg, "rank", "", -280, 0, 50, 30)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
    txt = GUI.CreateStatic(selfInfoBg, "str1", "", -110, 0, 150, 30)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
    txt = GUI.CreateStatic(selfInfoBg, "str2", "", 60, 0, 100, 30)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
    txt = GUI.CreateStatic(selfInfoBg, "str3", "", 230, 0, 100, 30)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
    --txt = GUI.CreateStatic(selfInfoBg, "str4", "", 270, 0, 100, 30)
    --WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)

    local rightBg = GUI.ImageCreate(panelBg, "rightBg", "1800400200", 350, -43, false, 340, 458)
    SetAnchorAndPivot(rightBg, UIAnchor.Center, UIAroundPivot.Center)
    local rightTitleBg = GUI.ImageCreate(rightBg, "rightTitleBg", "1800700070", 0, -210, false, 338, 40)
    SetAnchorAndPivot(rightTitleBg, UIAnchor.Center, UIAroundPivot.Center)
    local txt = GUI.CreateStatic(rightTitleBg, "rightTitle", "当前队伍", 0, 0, 300, 30, "system", false, false)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
    WorldNoWarUI.CreateRightList(rightBg)
    local rightCover = GUI.ImageCreate(rightBg, "rightCover", "1800200020", 0, 20, false, 340, 423)
    GuidCacheUtil.BindName(rightCover, "rightCover")
    SetAnchorAndPivot(rightCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(rightCover, true)
    local matchTip = GUI.ImageCreate(rightCover, "matchTip", "1800604040", 0, -20, false, 74, 22)
    SetAnchorAndPivot(matchTip, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(rightCover, false)

    local awardBg = GUI.ImageCreate(panelBg, "awardBg", "1800400200", -180, 170, false, 685, 140)
    SetAnchorAndPivot(awardBg, UIAnchor.Center, UIAroundPivot.Center)

    WorldNoWarUI.CreateLeftList(leftBg)
    WorldNoWarUI.CreateAwardList(awardBg)
    WorldNoWarUI.RefreshLeftLoopList(0)
    WorldNoWarUI.RefreshCurrentTeamLoopList(0)
    WorldNoWarUI.RefreshAwardLoopList(0)

    local buttomBg = GUI.GroupCreate(panelBg, "buttomBg", 0, 270, 0, 0)
    local winCountTip = GUI.CreateStatic(buttomBg, "winCountTip", "胜利次数", -475, 0, 100, 30, "system", false, false)
    WorldNoWarUI.SetTextBasicInfo(winCountTip, colorDark, TextAnchor.MiddleCenter, 22)
    local winCountBg = GUI.ImageCreate(buttomBg, "winCountBg", "1800900040", -390, 0, false, 70, 30)
    SetAnchorAndPivot(winCountBg, UIAnchor.Center, UIAroundPivot.Center)
    local winCountTxt = GUI.CreateStatic(buttomBg, "winCountTxt", "", -390, 0, 100, 30, "system", false, false)
    GuidCacheUtil.BindName(winCountTxt, "winCountTxt")
    WorldNoWarUI.SetTextBasicInfo(winCountTxt, defaultColor, TextAnchor.MiddleCenter, 22)
    local compWinCountTip = GUI.CreateStatic(buttomBg, "compWinCountTip", "最高连胜", -290, 0, 100, 30, "system", false, false)
    WorldNoWarUI.SetTextBasicInfo(compWinCountTip, colorDark, TextAnchor.MiddleCenter, 22)
    local compWinCountBg = GUI.ImageCreate(buttomBg, "compWinCountBg", "1800900040", -205, 0, false, 70, 30)
    SetAnchorAndPivot(compWinCountBg, UIAnchor.Center, UIAroundPivot.Center)
    local compWinCountTxt = GUI.CreateStatic(buttomBg, "compWinCountTxt", "", -205, 0, 60, 30, "system", false, false)
    GuidCacheUtil.BindName(compWinCountTxt, "compWinCountTxt")
    WorldNoWarUI.SetTextBasicInfo(compWinCountTxt, defaultColor, TextAnchor.MiddleCenter, 22)
    local fightCountTip = GUI.CreateStatic(buttomBg, "fightCountTip", "战斗次数", -105, 0, 100, 30, "system", false, false)
    WorldNoWarUI.SetTextBasicInfo(fightCountTip, colorDark, TextAnchor.MiddleCenter, 22)
    local fightCountBg = GUI.ImageCreate(buttomBg, "fightCountBg", "1800900040", -20, 0, false, 70, 30)
    SetAnchorAndPivot(fightCountBg, UIAnchor.Center, UIAroundPivot.Center)
    local fightCountTxt = GUI.CreateStatic(buttomBg, "fightCountTxt", "", -20, 0, 60, 30, "system", false, false)
    GuidCacheUtil.BindName(fightCountTxt, "fightCountTxt")
    WorldNoWarUI.SetTextBasicInfo(fightCountTxt, defaultColor, TextAnchor.MiddleCenter, 22)

    local matchBtn = GUI.ButtonCreate(panelBg, "matchBtn", "1800602090", 445, 265, Transition.ColorTint, "", 150, 50, false)
    GuidCacheUtil.BindName(matchBtn, "matchBtn")
    WorldNoWarUI.SetButtonBasicInfo(matchBtn, 24, colorDark, "OnMatchBtnClick")
    local matchBtnTxt = GUI.CreateStatic(matchBtn, "matchBtnTxt", "开始匹配", 0, 1, 150, 30, "system", true)
    GuidCacheUtil.BindName(matchBtnTxt, "matchBtnTxt")
    WorldNoWarUI.SetTextBasicInfo(matchBtnTxt, defaultColor, TextAnchor.MiddleCenter, 22)
    GUI.SetIsOutLine(matchBtnTxt, true)
    GUI.SetOutLine_Color(matchBtnTxt, outLineColor)
    GUI.SetOutLine_Distance(matchBtnTxt, 1)

    local easyMatchBtn = GUI.ButtonCreate(panelBg, "easyMatchBtn", "1800602090", 255, 265, Transition.ColorTint, "", 150, 50, false)
    WorldNoWarUI.SetButtonBasicInfo(easyMatchBtn, 24, colorDark, "OnEasyMatchBtnClick")
    local easyMatchBtnTxt = GUI.CreateStatic(easyMatchBtn, "easyMatchBtnTxt", "便捷组队", 0, 1, 150, 30, "system", true)
    WorldNoWarUI.SetTextBasicInfo(easyMatchBtnTxt, defaultColor, TextAnchor.MiddleCenter, 22)
    GUI.SetIsOutLine(easyMatchBtnTxt, true)
    GUI.SetOutLine_Color(easyMatchBtnTxt, outLineColor)
    GUI.SetOutLine_Distance(easyMatchBtnTxt, 1)

    local autoMatchBox = GUI.ImageCreate(panelBg, "autoMatchBox", "1800607150", 390, 215, false, 40, 40)
    GuidCacheUtil.BindName(autoMatchBox, "autoMatchBox")
    SetAnchorAndPivot(autoMatchBox, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(autoMatchBox, true)
    autoMatchBox:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(autoMatchBox, UCE.PointerClick, "WorldNoWarUI", "OnAutoMathcChenckBoxClick")
    local txt = GUI.CreateStatic(autoMatchBox, "autoMatchTips", "自动匹配", 80, 0, 150, 30)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)

    local reportBtn = GUI.ButtonCreate(panelBg, "reportBtn", "1800402110", 108, 270, Transition.ColorTint, "战况", 110, 40, false)
    WorldNoWarUI.SetButtonBasicInfo(reportBtn, 24, colorDark, "OnReportBtnClick")

    local exchangeBtn = GUI.ButtonCreate(panelBg, "exchangeBtn", "1800402110", -467, -255, Transition.ColorTint, "战功商店", 110, 40, false)
    WorldNoWarUI.SetButtonBasicInfo(exchangeBtn, 24, colorDark, "OnExchangeBtnClick")

    local helpTipBtn = GUI.ButtonCreate(panelBg, "helpTipBtn", "1800702030", 145, -255, Transition.ColorTint, "")
    SetAnchorAndPivot(helpTipBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(helpTipBtn, UCE.PointerClick, "WorldNoWarUI", "OnHelpTipBtnClick")

    local panelCover = GuidCacheUtil.GetUI("panelCover")
    local bgSp = UILayout.CreateFrame_WndStyle2(panelBg, "战况", 705, 580)
    local coverSp = GUI.GetChild(panelBg, "panelCover")
    GUI.SetWidth(coverSp, GUI.GetWidth(panelCover))
    GUI.SetHeight(coverSp, GUI.GetHeight(panelCover))
    GUI.SetPositionY(coverSp, -33)
    local closeBtn = GUI.GetChild(bgSp, "closeBtn")
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "WorldNoWarUI", "OnReportClose")
    local reportBg = GUI.ImageCreate(bgSp, "reportBg", "1800400200", 0, 20, false, 655, 500)
    SetAnchorAndPivot(reportBg, UIAnchor.Center, UIAroundPivot.Center)
    WorldNoWarUI.CreateReportList()
    WorldNoWarUI.RefreshReportLoopList(0)
    WorldNoWarUI.SetReportPageVisible(false)

    WorldNoWarUI.SelfNickName = CL.GetRoleName()
    WorldNoWarUI.RegisterMessage()
end

-- 注册GM消息
function WorldNoWarUI.RegisterMessage()
    for k, v in ipairs(messageEventList) do
        CL.UnRegisterMessage(v[1], "WorldNoWarUI", v[2])
        CL.RegisterMessage(v[1], "WorldNoWarUI", v[2])
    end
end

function WorldNoWarUI.SetTextBasicInfo(txt, color, TextAnchor, txtSize)
    SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txt, txtSize)
    GUI.SetColor(txt, color)
    GUI.StaticSetAlignment(txt, TextAnchor)
end

function WorldNoWarUI.SetButtonBasicInfo(btn, fontSize, fontColor, functionName)
    SetAnchorAndPivot(btn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.ButtonSetTextFontSize(btn, fontSize)
    GUI.ButtonSetTextColor(btn, fontColor)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "WorldNoWarUI", functionName)
end

--- 脚本调过来的刷新
function WorldNoWarUI.Refresh(id)
    WorldNoWarUI.RefreshAwardInfo()
	local id = tonumber(id)
    local config = DB.GetActivity(id)
    if config and config.Id ~= 0 then
        local strs = string.split(config.TimeEnd, " ")
        local remainTime = 0
        local nowtime = os.time()
        if strs and #strs == 2 then
            local temp = string.split(strs[1], "-")
            local temp1 = string.split(strs[2], ":")
            local time = os.time({ year = temp[1], month = temp[2], day = temp[3], hour = temp1[1], min = temp1[2], sec = temp1[3] })
            remainTime = time - nowtime
        elseif strs and #strs == 1  then
            local dateStrs = string.split(os.date("%H %M %S"), " ")
            local temp = string.split(strs[1], ":")
            remainTime = (tonumber(temp[1]) - tonumber(dateStrs[1])) * 3600 + (tonumber(temp[2]) - tonumber(dateStrs[2])) * 60 + (tonumber(temp[3]) - tonumber(dateStrs[3]))
        end
        WorldNoWarUI.RefreshTimetext(remainTime)
    end
end

function WorldNoWarUI.CreateLeftList(leftBg)
    local loopScroll = GUI.LoopScrollRectCreate(leftBg, "leftLoopScroll", 0, 37, 686, 230, "WorldNoWarUI", "CreatLeftListPool", "WorldNoWarUI", "OnRefreshLeftLoopScroll", 0, false, Vector2.New(680, 44), 1, UIAroundPivot.Top, UIAnchor.Top)
    GuidCacheUtil.BindName(loopScroll, "leftLoopScroll")
    SetAnchorAndPivot(loopScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(loopScroll, Vector2.New(0, 0))
end

function WorldNoWarUI.CreatLeftListPool()
    local loopScroll = GuidCacheUtil.GetUI("leftLoopScroll")
    local itemList = GUI.ItemCtrlCreate(loopScroll, "itemList", "1800600240", 0, 0, 680, 40, false)
    SetAnchorAndPivot(itemList, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(itemList, true)

    local rankSp = GUI.ImageCreate(itemList, "rankSp", "1800605110", -280, 0)
    SetAnchorAndPivot(rankSp, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(rankSp, false)

    local txt = GUI.CreateStatic(itemList, "str1", "", -280, 0, 50, 30)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
    txt = GUI.CreateStatic(itemList, "str2", "", -110, 0, 150, 30)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
    txt = GUI.CreateStatic(itemList, "str3", "", 60, 0, 80, 30)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
    txt = GUI.CreateStatic(itemList, "str4", "", 230, 0, 100, 30)
    WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)
    --txt = GUI.CreateStatic(itemList, "str5", "", 270, 0, 100, 30)
    --WorldNoWarUI.SetTextBasicInfo(txt, colorDark, TextAnchor.MiddleCenter, 22)

    return itemList
end

function WorldNoWarUI.OnRefreshLeftLoopScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemList = GUI.GetByGuid(guid)
    local currentItem = WorldNoWarUI.LeftRankList[index]
    if currentItem ~= nil then
        local str1 = GUI.GetChild(itemList, "str1")
        local str2 = GUI.GetChild(itemList, "str2")
        local str3 = GUI.GetChild(itemList, "str3")
        local str4 = GUI.GetChild(itemList, "str4")
        --local str5 = GUI.GetChild(itemList, "str5")
        local rankSp = GUI.GetChild(itemList, "rankSp")

        GUI.StaticSetText(str1, currentItem.Rankvalue)
        GUI.StaticSetText(str2, currentItem.Name)
        GUI.StaticSetText(str3, currentItem.FightValue)
        GUI.StaticSetText(str4, currentItem.WinCount)
        --GUI.StaticSetText(str5, currentItem.WinCount)
        if currentItem.Rankvalue < 4 then
            GUI.ImageSetImageID(rankSp, "18006051" .. currentItem.Rankvalue * 10)
            GUI.SetVisible(rankSp, true)
            GUI.SetVisible(str1, false)
        else
            GUI.SetVisible(rankSp, false)
            GUI.SetVisible(str1, true)
        end
        -- 奇偶数显示不同底图，
        GUI.ItemCtrlSetElementValue(itemList, eItemIconElement.Border,index % 2 == 0 and "1800600240" or "1800600230")
    end
end

-- GUID、Name、门派、战力、获胜场次5个参数用“,”隔开，每个成员之间再以“,”隔开
function WorldNoWarUI.RefreshRankList(leftInfos)
    test(leftInfos)
    WorldNoWarUI.LeftRankList = nil
    WorldNoWarUI.LeftRankList = {}
    if leftInfos ~= nil then
        for i, v in ipairs(leftInfos) do
            local tempInfo = {}
            tempInfo.Rankvalue = i
            tempInfo.Name = v[3]
            --local school = DB.GetSchool(v[4])
            tempInfo.Job = ""--school.Name
            tempInfo.FightValue = v[4]
            tempInfo.WinCount = v[2]
            table.insert(WorldNoWarUI.LeftRankList, tempInfo)
            if tempInfo.Name == WorldNoWarUI.SelfNickName then
                WorldNoWarUI.RefreshSelfInfo(tempInfo)
            end
        end
    end
    local leftCount = #WorldNoWarUI.LeftRankList
    WorldNoWarUI.RefreshLeftLoopList(leftCount > 50 and 50 or leftCount)
end

function WorldNoWarUI.RefreshLeftLoopList(count)
    local loopScroll = GuidCacheUtil.GetUI("leftLoopScroll")
    GUI.LoopScrollRectSetTotalCount(loopScroll, count)
    GUI.LoopScrollRectRefreshCells(loopScroll)
    GUI.ScrollRectSetNormalizedPosition(loopScroll, Vector2.New(0, 0))
end

function WorldNoWarUI.RefreshSelfInfo(leftSelfInfo)
    test("RefreshSelfInfo : ", leftSelfInfo)
    if leftSelfInfo ~= nil then
        local leftSelfInfoBg = GuidCacheUtil.GetUI("leftSelfInfoBg")
        if leftSelfInfoBg == nil then
            test("leftSelfInfoBg == nil ")
            return
        end
        local rank = GUI.GetChild(leftSelfInfoBg, "rank")
        local str1 = GUI.GetChild(leftSelfInfoBg, "str1")
        local str2 = GUI.GetChild(leftSelfInfoBg, "str2")
        local str3 = GUI.GetChild(leftSelfInfoBg, "str3")
        --local str4 = GUI.GetChild(leftSelfInfoBg, "str4")
        GUI.StaticSetText(rank, leftSelfInfo.Rankvalue)
        GUI.StaticSetText(str1, leftSelfInfo.Name)
        GUI.StaticSetText(str2, leftSelfInfo.FightValue)
        GUI.StaticSetText(str3, leftSelfInfo.WinCount)
        --GUI.StaticSetText(str4, leftSelfInfo.WinCount)
    end
end

function WorldNoWarUI.CreateRightList(rightBg)
    local loopScroll = GUI.LoopScrollRectCreate(rightBg, "rightLoopScroll", 5, 42, 330, 410, "WorldNoWarUI", "CreatRightListPool", "WorldNoWarUI", "OnRefreshRightLoopScroll", 10, false, Vector2.New(330, 82), 1, UIAroundPivot.Top, UIAnchor.Top)
    GuidCacheUtil.BindName(loopScroll, "rightLoopScroll")
    SetAnchorAndPivot(loopScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(loopScroll, Vector2.New(0, 0))
end

function WorldNoWarUI.CreatRightListPool()
    local loopScroll = GuidCacheUtil.GetUI("rightLoopScroll")
    local itemList = GUI.ItemCtrlCreate(loopScroll, "itemList", "1800400360", 0, 0, 330, 82, false)
    SetAnchorAndPivot(itemList, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(itemList, true)

    local jobSp = GUI.ImageCreate(itemList, "jobSp", "1800903010", -55, -20)
    SetAnchorAndPivot(itemList, UIAnchor.Center, UIAroundPivot.Center)
    local playerName = GUI.CreateStatic(itemList, "playerName", "", 68, -20, 210, 32, "system", false, false)
    WorldNoWarUI.SetTextBasicInfo(playerName, colorDark, TextAnchor.MiddleLeft, 24)
    local fightLogo = GUI.ImageCreate(itemList, "fightLogo", "1800407010", -55, 20)
    SetAnchorAndPivot(fightLogo, UIAnchor.Center, UIAroundPivot.Center)
    fightLogo = GUI.CreateStatic(itemList, "fightLogo2", "角色战力", 15, 20, 150, 40) --GUI.ImageCreate(itemList, "fightLogo2", "1801405360", 15, 20)
    GUI.StaticSetFontSize(fightLogo, UIDefine.FontSizeL)
    GUI.SetColor(fightLogo, UIDefine.Brown8Color)
    GUI.StaticSetAlignment(fightLogo, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(fightLogo, UIAnchor.Center, UIAroundPivot.Center)
    local fightValue = GUI.CreateStatic(itemList, "fightValue", "", 115, 20, 100, 32, "system", false, false)
    WorldNoWarUI.SetTextBasicInfo(fightValue, colorDark, TextAnchor.MiddleLeft, 22)
    local iconBack = GUI.ImageCreate(itemList, "iconBack", "1800600070", -120, 0, false, 80, 80)
    SetAnchorAndPivot(iconBack, UIAnchor.Center, UIAroundPivot.Center)
    local iconSp = GUI.ImageCreate(itemList, "iconSp", "1900300010", -120, 0, false, 70, 70)
    SetAnchorAndPivot(iconSp, UIAnchor.Center, UIAroundPivot.Center)
    HeadIcon.CreateVip(iconSp, 60, 60)
    local teamStateSp = GUI.ImageCreate(itemList, "teamStateSp", "1800607160", -120, 0, false, 70, 70)
    SetAnchorAndPivot(teamStateSp, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(teamStateSp, false)

    local teamLeader = GUI.ImageCreate(iconSp, "teamLeader", "1800607230", 0, 0, false, 40, 40)
    SetAnchorAndPivot(teamLeader, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    return itemList
end

function WorldNoWarUI.OnRefreshRightLoopScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemList = GUI.GetByGuid(guid)
    local currentItem = WorldNoWarUI.CurrentTeamInfo[index]
    if currentItem ~= nil then
        local jobSp = GUI.GetChild(itemList, "jobSp")
        local playerName = GUI.GetChild(itemList, "playerName")
        local fightValue = GUI.GetChild(itemList, "fightValue")
		local fightLogo = GUI.GetChild(itemList, "fightLogo")
        local fightLogo2 = GUI.GetChild(itemList, "fightLogo2")
        local iconSp = GUI.GetChild(itemList, "iconSp")
        local teamLeader = GUI.GetChild(iconSp, "teamLeader")
        local teamStateSp = GUI.GetChild(itemList, "teamStateSp")
        -- 1 正常，2 暂离，3离线
        if currentItem.TeamState == 1 then
            GUI.SetVisible(teamStateSp, false)
        elseif currentItem.TeamState == 2 then
            GUI.ImageSetImageID(teamStateSp, "1800607160")
            GUI.SetVisible(teamStateSp, true)
        elseif currentItem.TeamState == 3 then
            GUI.ImageSetImageID(teamStateSp, "1800607170")
            GUI.SetVisible(teamStateSp, true)
        end

        GUI.SetVisible(teamLeader, WorldNoWarUI.HasTeam and index == 1)

        GUI.StaticSetText(playerName, currentItem.Name)
        local school = DB.GetSchool(currentItem.Job)
        if school ~= nil then
			if tostring(school.Icon) == "0" then
				--侍从
				local GuardDB = DB.GetOnceGuardByKey1(currentItem.Id)
				if GuardDB ~= nil then
					GUI.ImageSetImageID(jobSp, guardType[tonumber(GuardDB.Type)][2])
					GUI.ImageSetImageID(iconSp, tostring(GuardDB.Head))
				end
				--GUI.StaticSetText(fightValue, guardType[tonumber(GuardDB.Type)][1])
				GUI.StaticSetText(fightLogo2, guardType[tonumber(GuardDB.Type)][1])
				GUI.SetPositionX(fightLogo2, 0)
				GUI.SetVisible(fightLogo, false)
				GUI.SetVisible(fightValue, false)
				GUI.SetVisible(GUI.GetChild(iconSp, "vipV"), false)
				GUI.SetVisible(GUI.GetChild(iconSp, "vipVNum1"), false)
				GUI.SetVisible(GUI.GetChild(iconSp, "vipVNum2"), false)
			else
				--玩家
				GUI.ImageSetImageID(jobSp, tostring(school.Icon))
				local role = DB.GetRole(currentItem.Id)
				if role ~= nil then
					GUI.ImageSetImageID(iconSp, tostring(role.Head))
				end
				GUI.StaticSetText(fightLogo2, "角色战力")
				GUI.SetPositionX(fightLogo2, 15)
				print("角色战力为："..currentItem.FightValue)
				GUI.StaticSetText(fightValue, currentItem.FightValue)
				GUI.StaticSetAlignment(fightValue, TextAnchor.MiddleCenter)
				if GUI.GetVisible(fightLogo) == false then
					GUI.SetVisible(fightLogo, true)
				end

				GUI.SetVisible(fightValue, true)
				GUI.SetVisible(GUI.GetChild(iconSp, "vipV"), true)
				GUI.SetVisible(GUI.GetChild(iconSp, "vipVNum1"), true)
				GUI.SetVisible(GUI.GetChild(iconSp, "vipVNum2"), true)
				HeadIcon.BindRoleVipLv(iconSp, currentItem.vip or 0)
			end
        end
    end
end

function WorldNoWarUI.RefreshCurrentTeamLoopList(count)
    local loopScroll = GuidCacheUtil.GetUI("rightLoopScroll")
    GUI.LoopScrollRectSetTotalCount(loopScroll, count)
    GUI.LoopScrollRectRefreshCells(loopScroll)
    GUI.ScrollRectSetNormalizedPosition(loopScroll, Vector2.New(0, 0))
end
-- 队员队伍状态， 1 在线  ， 2 暂离  ，3 离线
--队伍成员信息展示字符串（GUID、ID、Job、Level、Name 、fightValue  6个参数用“,”隔开，每个成员之间再以“,”隔开）
function WorldNoWarUI.RefreshCurrentTeamInfo(teamInfos)
    test("RefreshCurrentTeamInfo ： ", teamInfos)
    WorldNoWarUI.CurrentTeamInfo = {}
    if teamInfos then
        for k, v in ipairs(teamInfos) do
            local tempInfo = {}
            tempInfo.Guid = nil
            tempInfo.Id = v[1]
            tempInfo.Job = v[3]
            tempInfo.Level = v[4]
            tempInfo.Name = v[2]
            tempInfo.FightValue = v[7]
            tempInfo.vip = v[6]
            tempInfo.TeamState = 1
            table.insert(WorldNoWarUI.CurrentTeamInfo, tempInfo)
        end
    end
    print("WorldNoWarUI.RefreshCurrentTeamInfo(teamInfos): ", #WorldNoWarUI.CurrentTeamInfo)
    WorldNoWarUI.RefreshCurrentTeamLoopList(#WorldNoWarUI.CurrentTeamInfo)
end

function WorldNoWarUI.SortCurrentTeamInfo(a, b)
    if tonumber(a.IsTeamLeader) > tonumber(b.IsTeamLeader) then
        return true
    end
    return false
end

function WorldNoWarUI.CreateAwardList(awardBg)
    local loopScroll = GUI.LoopScrollRectCreate(awardBg, "awardLoopScroll", 3, 5, 680, 130, "WorldNoWarUI", "CreatAwardListPool", "WorldNoWarUI", "OnRefreshAwardLoopScroll", 10, false, Vector2.New(225, 80), 3, UIAroundPivot.Top, UIAnchor.Top)
    GuidCacheUtil.BindName(loopScroll, "awardLoopScroll")
    SetAnchorAndPivot(loopScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(loopScroll, Vector2.New(0, 0))
end

function WorldNoWarUI.CreatAwardListPool()
    local loopScroll = GuidCacheUtil.GetUI("awardLoopScroll")
    local itemList = GUI.ItemCtrlCreate(loopScroll, "itemList", "1801300060", 0, 0, 220, 80, false)
    SetAnchorAndPivot(itemList, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(itemList, true)
    GUI.RegisterUIEvent(itemList, UCE.PointerClick, "WorldNoWarUI", "OnAwardItemClick")

    local iconSp = GUI.ImageCreate(itemList, "iconSp", "1800601260", -60, 0, false, 70, 70)
    SetAnchorAndPivot(iconSp, UIAnchor.Center, UIAroundPivot.Center)
    local getSp = GUI.ImageCreate(itemList, "getSp", "1800604390", 80, -24, false, 56, 32)
    SetAnchorAndPivot(getSp, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetEulerAngles(getSp, Vector3.New(0, 0, -15))

    local effect = GUI.RichEditCreate(iconSp, "effect", "#IMAGE3403700000#", 15, 21, 130, 165)
    SetAnchorAndPivot(effect, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(effect, 24)
    GUI.SetIsRaycastTarget(effect, false)
    GUI.SetVisible(effect, false)
    local awardName = GUI.CreateStatic(itemList, "awardName", "", 40, 0, 140, 32, "system", false, false)
    WorldNoWarUI.SetTextBasicInfo(awardName, colorDark, TextAnchor.MiddleCenter, 22)

    return itemList
end

function WorldNoWarUI.OnRefreshAwardLoopScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemList = GUI.GetByGuid(guid)
    local currentItem = WorldNoWarUI.AwardInfoList[index]
    if currentItem ~= nil then
        local iconSp = GUI.GetChild(itemList, "iconSp")
        local awardName = GUI.GetChild(itemList, "awardName")
        local getSp = GUI.GetChild(itemList, "getSp")
        local effect = GUI.GetChild(iconSp, "effect")
        GUI.StaticSetText(awardName, currentItem.Name)
        GUI.ImageSetImageID(iconSp, tostring(currentItem.Icon))
        --GUI.SetVisible(effect, currentItem.AwardState == 0)
        GUI.SetVisible(getSp, currentItem.AwardState == 1)
        GUI.ImageSetGray(iconSp, currentItem.AwardState == 1)
    end
end

function WorldNoWarUI.RefreshAwardLoopList(count)
    local loopScroll = GuidCacheUtil.GetUI("awardLoopScroll")
    GUI.LoopScrollRectSetTotalCount(loopScroll, count)
    GUI.LoopScrollRectRefreshCells(loopScroll)
    GUI.ScrollRectSetNormalizedPosition(loopScroll, Vector2.New(0, 0))
end

-- 奖励展示字符串（index、name ,icon, 领取状态,  4个参数用“,”隔开，每个成员之间再以“,”隔开）
-- 领取状态 0 未领取  1，已领取
function WorldNoWarUI.RefreshAwardInfo()
    WorldNoWarUI.AwardInfoList = {}
    for k, v in ipairs(WorldNoWarUI.AwardInfo) do
        local tempInfo = {}
        tempInfo.Index = k --tonumber(infos[i])
        tempInfo.Name = (v.typ == "win" and "胜利" or "战斗") .. v.num .. "场"
        tempInfo.Icon = v.img--tonumber(infos[i+2])
        tempInfo.AwardState = v.isget--tonumber(infos[i+3])
        WorldNoWarUI.AwardInfoList[#WorldNoWarUI.AwardInfoList + 1] = tempInfo
    end
    table.sort(WorldNoWarUI.AwardInfoList, WorldNoWarUI.SortAwardInfos)
    WorldNoWarUI.RefreshAwardLoopList(#WorldNoWarUI.AwardInfoList)
end

function WorldNoWarUI.SortAwardInfos(a, b)
    if a.AwardState == b.AwardState then
        return a.Index < b.Index
    else
        return a.AwardState < b.AwardState
    end
end

function WorldNoWarUI.OnAwardItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local index = GUI.ItemCtrlGetIndex(item) + 1
    local award = WorldNoWarUI.AwardInfoList[index]
    test("OnAwardItemClick : ", index)
    if award ~= nil then
        if award.Detail == nil then
            test("Detail is nil ,index : ", award.Index)
            CL.SendNotify(NOTIFY.SubmitForm, "FormTianXiaHuiWu", "GetRewardInfo", award.Index)
        else
            test("award.Detail : ", award.Detail)
            WorldNoWarUI.OnClickRewardTip(award)
        end
    else
        test("award is nil ,index : ", index)
    end
end

function WorldNoWarUI.AddAwardDeatil(index, winCount, Detail)
    test("AddAwardDeatil : ", index)
    for i, v in pairs(WorldNoWarUI.AwardInfoList) do
        if v.Index == index then
            Detail = WorldNoWarUI.Unserialize(Detail)
            v.Detail = Detail
            WorldNoWarUI.OnClickRewardTip(v)
        end
    end
end

function WorldNoWarUI.OnClickRewardTip(reward)
    local panelBg = GUI.Get("WorldNoWarUI/panelBg")
    if not panelBg then
        return
    end

    local detail = reward.Detail
    if detail == nil then
        return
    end

    local tips = GUI.TipsCreate(panelBg, "Tip", 205, 140, 419, -60)  --"1800400290",
    GUI.SetIsRemoveWhenClick(tips, true)
    SetAnchorAndPivot(tips, UIAnchor.Center, UIAroundPivot.Center)
	
	GUI.SetPivot(tips,UIAroundPivot.Center);
	GUI.SetAnchor(tips,UIAnchor.Center)

    local startX = 25
    local sizeBig = 22
    GUI.SetHeight(tips, 150)

    GUI.TipsAddLabel(tips, startX, "<color=#ffffff>当前奖励为：</color>", defaultColor, true)
	local CutLine = GUI.GetChild(tips,"CutLine")
    local CutLinePositionY = GUI.GetPositionY(CutLine)
    GUI.SetPositionY(CutLine,CutLinePositionY + 200 + 26*3 + 13)
    local InfoScr = GUI.GetChild(tips,"InfoScr")

    local itemIcon = GUI.TipsGetItemIcon(tips)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, reward.Icon);
	GUI.SetVisible(itemIcon, false)
	GUI.SetVisible(CutLine, false)
	GUI.SetPositionY(InfoScr, 25)
	GUI.SetHeight(InfoScr, 200)
	

    if detail.Exp > 0 then
        GUI.TipsAddLabel(tips, startX, string.format("<color=#ffffff>经验 X %d</color>", detail.Exp), defaultColor, true)
    end

    if detail.MoneyVal > 0 then
        GUI.TipsAddLabel(tips, startX, string.format("<color=#ffffff>%s X %d</color>", UIDefine.AttrName[UIDefine.GetMoneyEnum(detail.MoneyType or 1)], detail.MoneyVal), defaultColor, true)
    end
    if detail.Contribution > 0 then
        GUI.TipsAddLabel(tips, startX, string.format("<color=#ffffff>帮贡 X %d</color>", detail.Contribution), defaultColor, true)
    end
    if detail.GuildGold > 0 then
        GUI.TipsAddLabel(tips, startX, string.format("<color=#ffffff>帮派资金 X %d</color>", detail.GuildGold), defaultColor, true)
    end

    for k, v in ipairs(detail.Item) do
        if type(v) == "string" then
            if v ~= "" then
                local item = DB.GetOnceItemByKey2(v)
                if item.Id ~= 0 then
                    local num = 1
                    if type(detail.Item[k + 1]) == "number" then
                        num = detail.Item[k + 1]
                    end
                    if item then
                        GUI.TipsAddLabel(tips, startX, string.format("<color=#ffffff>%s X %d</color>", item.Name, num), defaultColor, true)
                    end
                end
            end
        end
    end
end

function WorldNoWarUI.CreateReportList()
    local scrollBg = GUI.Get("WorldNoWarUI/panelBg/panelBg/reportBg")
    local loopScroll = GUI.LoopScrollRectCreate(scrollBg, "reportLoopScroll", 0, 10, 655, 480, "WorldNoWarUI", "CreatRReportListPool", "WorldNoWarUI", "OnRefreshReportLoopScroll", 10, false, Vector2.New(655, 82), 1, UIAroundPivot.Top, UIAnchor.Top)
    GuidCacheUtil.BindName(loopScroll, "reportLoopScroll")
    SetAnchorAndPivot(loopScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(loopScroll, Vector2.New(0, 8))
end

function WorldNoWarUI.CreatRReportListPool()
    local loopScroll = GuidCacheUtil.GetUI("reportLoopScroll")
    local itemList = GUI.ImageCreate(loopScroll, "reportItem", "1800600090", 0, 0, false, 655, 82)--GUI.ItemCtrlCreate(loopScroll, "itemList", "1800600950", 0, 0, 655, 82, false)
    SetAnchorAndPivot(itemList, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(itemList, true)

    local reportInfo = GUI.CreateStatic(itemList, "reportInfo", "第一场", 0, 0, 650, 70, "system", true, false)
    WorldNoWarUI.SetTextBasicInfo(reportInfo, colorDark, TextAnchor.MiddleCenter, 24)
    return itemList
end

function WorldNoWarUI.OnRefreshReportLoopScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local itemList = GUI.GetByGuid(guid)
    local currentItem = WorldNoWarUI.ReportInfos[#WorldNoWarUI.ReportInfos - index]
    if currentItem ~= nil then
        local reportInfo = GUI.GetChild(itemList, "reportInfo")
        --local infos = string.split(currentItem,"|")
        GUI.StaticSetText(reportInfo, currentItem)
    end
end

function WorldNoWarUI.RefreshReportLoopList(count)
    local loopScroll = GuidCacheUtil.GetUI("reportLoopScroll")
    if loopScroll ~= nil then
        GUI.LoopScrollRectSetTotalCount(loopScroll, count)
        GUI.LoopScrollRectRefreshCells(loopScroll)
        GUI.ScrollRectSetNormalizedPosition(loopScroll, Vector2.New(0, 0))
    end
end

--刷新时间
function WorldNoWarUI.RefreshTimetext(remainTime)
    test("RefreshTimetext : ", remainTime)
    WorldNoWarUI.StopTimerDown()
    local timeText = GuidCacheUtil.GetUI("timeText")
	if WorldNoWarUI.PVPActivity_IsOpening == "OFF" then
		 GUI.StaticSetText(timeText, "")
		 return
	end
    if remainTime <= 1 then
        GUI.StaticSetText(timeText, "")
        return
    end
    if timeText ~= nil then
        local fun = function()
            remainTime = remainTime - 1
            if remainTime < 1 then
                WorldNoWarUI.OnCloseBtnClick()
                local moveGroup = GUI.Get("MainUI/moveGroup")
                if moveGroup ~= nil then
                    GUI.SetVisible(moveGroup, false)
                end
            end

            local day, hour, min, sec = GlobalUtils.Get_DHMS2_BySeconds(remainTime)
            local timeString
            if day == "00" then
                if hour == "00" then
                    timeString = min .. ":" .. sec
                else
                    timeString = hour .. ":" .. min .. ":" .. sec
                end
            else
                timeString = day .. "天" .. hour .. ":" .. min .. ":" .. sec
            end
            GUI.StaticSetText(timeText, timeString)
            return nil
        end
        WorldNoWarUI.RemainTimer = Timer.New(fun, 1, remainTime, true)
        WorldNoWarUI.RemainTimer:Start()
    end
end

--刷新自动匹配状态
function WorldNoWarUI.RefreshAutoMatchState(autoState)
    test("WorldNoWarUI.RefreshAutoMatchState , autoState : ", autoState)
    if autoState ~= nil and tonumber(autoState) == 1 then
        WorldNoWarUI.AutoMatchState = true
    else
        WorldNoWarUI.AutoMatchState = false
    end
    WorldNoWarUI.RefreshAutoMatchBtn(WorldNoWarUI.AutoMatchState)
end

function WorldNoWarUI.RefreshAutoMatchBtn(isAutoMatch)
    test("WorldNoWarUI.RefreshAutoMatchBtn ,isAutoMatch : ", isAutoMatch)
    local autoMatchBox = GuidCacheUtil.GetUI("autoMatchBox")
    if autoMatchBox == nil then
        test("autoMatchBox is null")
        return
    end
    if isAutoMatch then
        WorldNoWarUI.SetMatchTipVisible(true)
        GUI.ImageSetImageID(autoMatchBox, "1800607151")
    else
        GUI.ImageSetImageID(autoMatchBox, "1800607150")
    end
end

--刷新匹配状态
function WorldNoWarUI.RefreshMatchState(matchState)
    test("WorldNoWarUI.RefreshMatchState ,matchState : ", matchState)
    if matchState ~= nil and tonumber(matchState) == 1 then
        WorldNoWarUI.IsMatching = true
    else
        WorldNoWarUI.IsMatching = false
    end
    WorldNoWarUI.RefreshMatchBtn(WorldNoWarUI.IsMatching)
end

function WorldNoWarUI.RefreshMatchBtn(matchState)
    local matchBtnTxt = GuidCacheUtil.GetUI("matchBtnTxt")
    if matchBtnTxt == nil then
        test("matchBtnTxt is null")
        return
    end
    if matchState then
        GUI.StaticSetText(matchBtnTxt, "取消匹配")
        WorldNoWarUI.SetMatchTipVisible(true)
    else
        GUI.StaticSetText(matchBtnTxt, "开始匹配")
        WorldNoWarUI.SetMatchTipVisible(false)
    end
end

function WorldNoWarUI.RefreshMatchBtnInteractable(canClick)
    local matchBtn = GUI.Get("WorldNoWarUI/panelBg/matchBtn")
    if matchBtn == nil then
        test("matchBtn is null")
        return
    end
    GUI.SetInteractable(matchBtn, canClick)
end

-- 匹配中的cover
function WorldNoWarUI.SetMatchTipVisible(canSee)
    local rightCover = GuidCacheUtil.GetUI("rightCover")
    if rightCover ~= nil then
        GUI.SetVisible(rightCover, canSee)
    end
end

--刷新战斗数据
function WorldNoWarUI.RefreshFightData(winCount, maxComboWin, totalFightCount)
    test("WorldNoWarUI.RefreshFightDat : ", winCount, maxComboWin, totalFightCount)
    local winCountTxt = GuidCacheUtil.GetUI("winCountTxt")
    if winCountTxt ~= nil then
        GUI.StaticSetText(winCountTxt, winCount)
    end
    local compWinCountTxt = GuidCacheUtil.GetUI("compWinCountTxt")
    if compWinCountTxt ~= nil then
        GUI.StaticSetText(compWinCountTxt, maxComboWin)
    end
    local fightCountTxt = GuidCacheUtil.GetUI("fightCountTxt")
    if fightCountTxt ~= nil then
        GUI.StaticSetText(fightCountTxt, totalFightCount)
    end
end

function WorldNoWarUI.OnMatchBtnClick()
    test("WorldNoWarUI.OnMatchBtnClick()")
	if WorldNoWarUI.PVPActivity_IsOpening == "ON" then
		if WorldNoWarUI.IsMatching then
			CL.SendNotify(NOTIFY.SubmitForm, "FormTianXiaHuiWu", "EndMatch")
			print("结束匹配")
		else
			CL.SendNotify(NOTIFY.SubmitForm, "FormTianXiaHuiWu", "StartMatch")
			print("开始匹配")
		end
	elseif WorldNoWarUI.PVPActivity_IsOpening == "OFF" then
		CL.SendNotify(NOTIFY.ShowBBMsg, "活动已结束，无法进行操作")
	else
		print("WorldNoWarUI Err")
	end
end

function WorldNoWarUI.OnEasyMatchBtnClick()
    test("OnEasyMatchBtnClick")
	 GUI.OpenWnd("TeamPlatformPersonalUI")
    --if WorldNoWarUI.WorldNoWarUI_TeamId ~= nil then
    --    local teamSate = LD.GetRoleInTeamState(0)
    --    if teamSate == 0 then
    --        GUI.OpenWnd("TeamPlatformPersonalUI", "teamId:" .. WorldNoWarUI.WorldNoWarUI_TeamId)
    --    elseif teamSate == 2 then
    --        GUI.OpenWnd("TeamPanelUI")
    --        GUI.OpenWndInTop("TeamPlatformUI", "teamId:" .. WorldNoWarUI.WorldNoWarUI_TeamId)
    --    else
    --        CL.SendNotify(NOTIFY.ShowBBMsg, "只有队长才能发布招募信息")
    --    end
    --end
end

function WorldNoWarUI.OnAutoMathcChenckBoxClick()
    test("WorldNoWarUI.OnAutoMathcChenckBoxClick()")
	if WorldNoWarUI.PVPActivity_IsOpening == "ON" then
		local teamState = LD.GetRoleInTeamState(0)
		if teamState == 3 then
			CL.SendNotify(NOTIFY.ShowBBMsg, "只有队长可以进行此操作")
			return
		end
		if WorldNoWarUI.AutoMatchState then
			CL.SendNotify(NOTIFY.SubmitForm, "FormTianXiaHuiWu", "EndAutoMatch")
		else
			CL.SendNotify(NOTIFY.SubmitForm, "FormTianXiaHuiWu", "StartAutoMatch")
		end
	elseif WorldNoWarUI.PVPActivity_IsOpening == "OFF" then
		CL.SendNotify(NOTIFY.ShowBBMsg, "活动已结束，无法进行操作")
	else
		print("WorldNoWarUI Err")
	end
end

function WorldNoWarUI.AddReport(str)
    CL.SendNotify(NOTIFY.ShowBBMsg, str)
    WorldNoWarUI.WorldPVPActivity_AddReport(str)
end

function WorldNoWarUI.WorldPVPActivity_AddReport(str)
    WorldNoWarUI.ReportInfos = WorldNoWarUI.ReportInfos or {}
    table.insert(WorldNoWarUI.ReportInfos, str)
end

function WorldNoWarUI.OnReportBtnClick()
    test("OnReportBtnClick")
    if WorldNoWarUI.ReportInfos then
        WorldNoWarUI.SetReportPageVisible(true)
        WorldNoWarUI.RefreshReportLoopList(#WorldNoWarUI.ReportInfos)
    else
        test(" GlobalProcessing.WorldPVPActivity_Report_Mine is nil ")
        WorldNoWarUI.SetReportPageVisible(true)
        WorldNoWarUI.RefreshReportLoopList(0)
    end
end

function WorldNoWarUI.OnReportClose()
    WorldNoWarUI.SetReportPageVisible(false)
end

function WorldNoWarUI.SetReportPageVisible(canSee)
    test(canSee)
    local reportPage = GUI.Get("WorldNoWarUI/panelBg/panelBg")
    if reportPage ~= nil then
        GUI.SetVisible(reportPage, canSee)
    end
    local reportCover = GUI.Get("WorldNoWarUI/panelBg/panelCover")
    if reportCover ~= nil then
        GUI.SetVisible(reportCover, canSee)
    end
end

function WorldNoWarUI.StopTimerDown()
    if WorldNoWarUI.RemainTimer ~= nil then
        WorldNoWarUI.RemainTimer:Stop()
        WorldNoWarUI.RemainTimer = nil
    end
end

function WorldNoWarUI.OnCloseBtnClick()
    WorldNoWarUI.StopTimerDown()
    WorldNoWarUI.StopGetMatchState()
    GUI.CloseWnd("WorldNoWarUI")
end

function WorldNoWarUI.OnShow(scriptName)
    GUI.SetVisible(GUI.GetWnd("WorldNoWarUI"), true)
    WorldNoWarUI.SelfNickName = CL.GetRoleName()
    --获得数据
    CL.SendNotify(NOTIFY.SubmitForm, "FormTianXiaHuiWu", "GetData")
    --WorldNoWarUI.StopGetMatchState()
    --WorldNoWarUI.GetMatchState()
end

--进战斗关界面
function WorldNoWarUI.OnInFight(isInfight)
    if isInfight then
        WorldNoWarUI.OnCloseBtnClick()
    end
end

function WorldNoWarUI.OnDestroy()
    WorldNoWarUI.StopTimerDown()
    WorldNoWarUI.StopGetMatchState()
end

--反编译字符串
function WorldNoWarUI.Unserialize(obj)
    return loadstring("return {" .. obj .. "}")()[1]
end

function WorldNoWarUI.OnTeamInfoUpdate(Type)
    test("刷新队伍数据，WorldNoWarUI ， type 为：", Type)
    if Type == 0 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormTianXiaHuiWu", "GetTeamInfo")
    end
end

function WorldNoWarUI.OnHelpTipBtnClick()
    WorldNoWarUI.RefreshHelpTip()
    --local helpTip = GuidCacheUtil.GetUI("helpTip")
    --if helpTip then
    --    GUI.SetVisible(helpTip, true)
    --    return
    --end
    --local panelBg = GUI.Get("WorldNoWarUI/panelBg")
    --if panelBg == nil then
    --    return
    --end
    --local helpTipCover = GUI.ImageCreate(panelBg, "helpTipCover", "1800400220", 0, 0, false, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
    --GuidCacheUtil.BindName(helpTipCover, "helpTip")
    --helpTipCover:RegisterEvent(UCE.PointerClick)
    --GUI.SetIsRaycastTarget(helpTipCover, true)
    --GUI.RegisterUIEvent(helpTipCover, UCE.PointerClick, "WorldNoWarUI", "OnCloseHelpTip")
    --GUI.SetColor(helpTipCover, UIDefine.Transparent)
    --
    --helpTip = GUI.ImageCreate(helpTipCover, "helpTip", "1800400290",-46, -145, false, 500, 300)
    --local str1 = GUI.CreateStatic(helpTip, "str1", "<color=#ffffff>1.战斗前十场可以获得战功牌</color>", 20, -110, 450, 30, "system", true)
    --GUI.StaticSetFontSize(str1, UIDefine.FontSizeS)
    --local str2 = GUI.CreateStatic(helpTip, "str2", "<color=#ffffff>2.通过战斗奖励可以获得战功牌</color>", 20, -75, 450, 30, "system", true)
    --GUI.StaticSetFontSize(str2, UIDefine.FontSizeS)
    --local str3 = GUI.CreateStatic(helpTip, "str3", "<color=#ffffff>3.每日通过战斗和胜利获得的战功牌最多70个</color>", 20, -37, 450, 30, "system", true)
    --GUI.StaticSetFontSize(str3, UIDefine.FontSizeS)
    --local str4 = GUI.CreateStatic(helpTip, "str4", "<color=#ffffff>获得排行榜前三还可通过邮件额外获得大量战功牌</color>", 20, 0, 450, 30, "system", true)
    --GUI.StaticSetFontSize(str4, UIDefine.FontSizeS)
    --local str5 = GUI.CreateStatic(helpTip, "str5", "<color=#ffffff>4.排行榜优先以胜利场数为判断，次要以胜率为判断</color>", 20, 39, 450, 30, "system", true)
    --GUI.StaticSetFontSize(str5, UIDefine.FontSizeS)
    --local str6 = GUI.CreateStatic(helpTip, "str6", "<color=#ffffff>5.战斗奖励及胜利奖励，达到条件后自动领取，包裹满时将以邮件发送。</color>", 20, 80, 450, 30, "system", true)
    --GUI.StaticSetFontSize(str6, UIDefine.FontSizeS)
end

function WorldNoWarUI.RefreshHelpTip(tip)
    local helpTip = GuidCacheUtil.GetUI("helpTip")
    if helpTip then
        GUI.SetVisible(helpTip, true)
        return
    elseif not tip then
        CL.SendNotify(NOTIFY.SubmitForm, "FormTianXiaHuiWu", "GetTips")
        return
    end
    local panelBg = GUI.Get("WorldNoWarUI/panelBg")
    if panelBg == nil then
        return
    end
    local helpTipCover = GUI.ImageCreate(panelBg, "helpTipCover", "1800400220", 0, 0, false, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
    GuidCacheUtil.BindName(helpTipCover, "helpTip")
    helpTipCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(helpTipCover, true)
    GUI.RegisterUIEvent(helpTipCover, UCE.PointerClick, "WorldNoWarUI", "OnCloseHelpTip")
    GUI.SetColor(helpTipCover, UIDefine.Transparent)

    helpTip = GUI.ImageCreate(helpTipCover, "helpTip", "1800400290",-46, -145, false, 500, 300)
    local strs = string.split(tip, "\n")
    for i = 1, #strs do
        local str1 = GUI.CreateStatic(helpTip, "str1", strs[i], 20, -150 + i * 40, 450, 30, "system", true)
        GUI.StaticSetFontSize(str1, UIDefine.FontSizeS)
    end
end

function WorldNoWarUI.OnCloseHelpTip()
    local helpTip = GuidCacheUtil.GetUI("helpTip")
    if helpTip then
        GUI.SetVisible(helpTip, false)
    end
end

function WorldNoWarUI.StopGetMatchState()
    if WorldNoWarUI.GetMacthStateTimer ~= nil then
        WorldNoWarUI.GetMacthStateTimer:Stop()
        WorldNoWarUI.GetMacthStateTimer = nil
    end
end

function WorldNoWarUI.GetMatchState()
    WorldNoWarUI.StopGetMatchState()
    local fun = function()
        test("GetMatchStatus")
        CL.SendNotify(NOTIFY.SubmitForm, "FormTianXiaHuiWu", "GetMatchStatus")
    end
    WorldNoWarUI.GetMacthStateTimer = Timer.New(fun, 15, -1, true)
    WorldNoWarUI.GetMacthStateTimer:Start()
end

function WorldNoWarUI.OnExchangeBtnClick()
    GUI.OpenWnd("ShopStoreUI", "5,-1")
end