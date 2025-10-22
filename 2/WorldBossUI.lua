local WorldBossUI = {
    serverData = {},
    actId = 0
}
_G.WorldBossUI = WorldBossUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local guidt = UILayout.NewGUIDUtilTable()
local test = print
test = function()
end
function WorldBossUI.InitData()
    return {
        openState = 0,
        monsterHp = 0,
        monsterMaxHp = 0,
        lastFightCnt = 0,
        AwardNumMax = 0,
        lastCD = 0,
        lastTime = 0,
        activityId = 0,
        activityName = "",
        activityTimeInfo = "",
        activityRule = "",
        ---@type eqiupItem[]
        activityItem = {},
        bossName = "",
        bossIcon = "",
        bossDes = "",
        bossLevel = "",
        bgPic = "",
        teamId = 0,
        myRank = 0,
        myName = "",
        myDamage = 0,
        ---@type WorldBossRank[]
        rankingTable = {},
        delaytime = 0
    }
end
local data = WorldBossUI.InitData()

local iconGradeBg = UIDefine.ItemIconBg
local colorDark = UIDefine.BrownColor
local colorRed = UIDefine.RedColor
local colorWhite = UIDefine.WhiteColor
local oulineWhite = Color.New(186 / 255, 93 / 255, 18 / 255, 255 / 255)

local rankSprites = {"1800605110", "1800605120", "1800605130"}
function WorldBossUI.Main(parameter)
    WorldBossUI.actId = 0
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("DefUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("WorldBossUI", "WorldBossUI", 0, 0)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIgnoreChild_OnVisible(panel, true)

    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "世界BOSS", "WorldBossUI", "OnExit", guidt)

    local remainTimeDes =
        GUI.CreateStatic(panelBg, "remainTimeDes", "活动剩余时间：", 100, 85, 170, 35, "system", false, false)
    GUI.StaticSetFontSize(remainTimeDes, UIDefine.FontSizeL)
    GUI.SetColor(remainTimeDes, colorDark)
    SetAnchorAndPivot(remainTimeDes, UIAnchor.TopLeft, UIAroundPivot.Left)

    local remainTimeText =
        GUI.CreateStatic(panelBg, "remainTimeText", "00:30:00", 270, 85, 150, 35, "system", false, false)
    GUI.StaticSetFontSize(remainTimeText, UIDefine.FontSizeL)
    GUI.SetColor(remainTimeText, colorRed)
    SetAnchorAndPivot(remainTimeText, UIAnchor.TopLeft, UIAroundPivot.Left)

    local text2 = GUI.CreateStatic(panelBg, "text2", "剩余挑战次数：", 420, 85, 170, 35, "system", false, false)
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeL)
    GUI.SetColor(text2, colorDark)
    SetAnchorAndPivot(text2, UIAnchor.TopLeft, UIAroundPivot.Left)

    local remainCountText = GUI.CreateStatic(panelBg, "remainCountText", "0/0", 590, 85, 50, 35, "system", false, false)
    GUI.StaticSetFontSize(remainCountText, UIDefine.FontSizeL)
    GUI.SetColor(remainCountText, colorRed)
    SetAnchorAndPivot(remainCountText, UIAnchor.TopLeft, UIAroundPivot.Left)

    local hpBar =
        GUI.ScrollBarCreate(
        panelBg,
        "hpBar",
        "",
        -- "1800601330",
        -- "1800607090",
        "1800601330",
        "1800601340",
        85,
        125,
        905,
        45,
        1,
        false,
        Transition.None,
        0,
        1,
        Direction.RightToLeft,
        false
    )
    SetAnchorAndPivot(hpBar, UIAnchor.TopLeft, UIAroundPivot.Left)
    GUI.ScrollBarSetFillSize(hpBar, Vector2.New(905, 45))
    GUI.ScrollBarSetBgSize(hpBar, Vector2.New(905, 45))

    local hpText = GUI.CreateStatic(hpBar, "hpText", "99999/99999", 0, 0, 500, 35, "system", false, false)
    GUI.StaticSetFontSize(hpText, UIDefine.FontSizeL)
    GUI.SetColor(hpText, colorWhite)
    GUI.StaticSetAlignment(hpText, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(hpText, UIAnchor.Center, UIAroundPivot.Center)

    local iconBg = GUI.ImageCreate(panelBg, "iconBg", "1800201110", -95, 100, false, 100, 100)
    SetAnchorAndPivot(iconBg, UIAnchor.TopRight, UIAroundPivot.Right)

    local icon = GUI.ImageCreate(iconBg, "icon", "1900351610", 0, 0, false, 90, 90)
    SetAnchorAndPivot(icon, UIAnchor.Center, UIAroundPivot.Center)

    local levelBg = GUI.ImageCreate(iconBg, "levelBg", "1800608800", 10, -20, false, 40, 40)
    SetAnchorAndPivot(levelBg, UIAnchor.BottomRight, UIAroundPivot.Center)

    local level = GUI.CreateStatic(levelBg, "level", "1", 0, 0, 50, 35, "system", false, false)
    GUI.StaticSetFontSize(level, UIDefine.FontSizeM)
    GUI.SetColor(level, colorWhite)
    GUI.StaticSetAlignment(level, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(level, UIAnchor.Center, UIAroundPivot.Center)

    local group1 = GUI.ImageCreate(panelBg, "group1", "1800608780", -80, 260, false, 620, 240)
    SetAnchorAndPivot(group1, UIAnchor.TopRight, UIAroundPivot.Right)

    local nameBg = GUI.ImageCreate(group1, "nameBg", "1800601310", -130, -75, false, 205, 50)
    SetAnchorAndPivot(nameBg, UIAnchor.Center, UIAroundPivot.Center)

    local name = GUI.CreateStatic(nameBg, "name", "魔王大头怪", 0, 0, 180, 35, "system", false, false)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
    GUI.SetColor(name, colorDark)
    GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(name, UIAnchor.Center, UIAroundPivot.Center)

    local desBg = GUI.ImageCreate(group1, "desBg", "1800601320", -115, 28, false, 350, 160)
    SetAnchorAndPivot(desBg, UIAnchor.Center, UIAroundPivot.Center)

    local des = GUI.CreateStatic(desBg, "des", "描述", 0, 0, 310, 130, "system", false, false)
    GUI.StaticSetFontSize(des, UIDefine.FontSizeM)
    GUI.SetColor(des, colorDark)
    SetAnchorAndPivot(des, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(des, TextAnchor.UpperLeft)

    local group2 = GUI.ImageCreate(panelBg, "group2", "1800400010", -85, -176, false, 609, 170)
    SetAnchorAndPivot(group2, UIAnchor.BottomRight, UIAroundPivot.Right)

    local text1 = GUI.CreateStatic(group2, "text1", "开启条件:", -15, 30, 110, 35, "system", false, false)
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeL)
    GUI.SetColor(text1, colorDark)
    SetAnchorAndPivot(text1, UIAnchor.TopLeft, UIAroundPivot.Left)

    local timeInfo = GUI.CreateStatic(group2, "timeInfo", "每周三晚上19:30至20:30", -125, 30, 500, 35, "system", false, false)
    GUI.StaticSetFontSize(timeInfo, UIDefine.FontSizeL)
    GUI.SetColor(timeInfo, colorDark)
    SetAnchorAndPivot(timeInfo, UIAnchor.TopLeft, UIAroundPivot.Left)

    local text2 = GUI.CreateStatic(group2, "text2", "参与条件:", -15, 60, 110, 35, "system", false, false)
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeL)
    GUI.SetColor(text2, colorDark)
    SetAnchorAndPivot(text2, UIAnchor.TopLeft, UIAroundPivot.Left)

    local ruleInfo = GUI.CreateStatic(group2, "ruleInfo", "帮派成员单人或组队参与", -125, 60, 500, 35, "system", false, false)
    GUI.StaticSetFontSize(ruleInfo, UIDefine.FontSizeL)
    GUI.SetColor(ruleInfo, colorDark)
    SetAnchorAndPivot(ruleInfo, UIAnchor.TopLeft, UIAroundPivot.Left)

    local text3 = GUI.CreateStatic(group2, "text3", "活动奖励:", -15, 90, 110, 35, "system", false, false)
    GUI.StaticSetFontSize(text3, UIDefine.FontSizeL)
    GUI.SetColor(text3, colorDark)
    SetAnchorAndPivot(text3, UIAnchor.TopLeft, UIAroundPivot.Left)

    local itemScroll =
        GUI.ScrollRectCreate(
        group2,
        "itemScroll",
        -360,
        35,
        475,
        81,
        8,
        true,
        Vector2.New(80, 81),
        UIAroundPivot.TopLeft,
        UIAnchor.TopLeft,
        1
    )
    SetAnchorAndPivot(itemScroll, UIAnchor.Left, UIAroundPivot.Center)
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(5, 8))
    for i = 1, 8 do
        local item = ItemIcon.Create(itemScroll, "item" .. i, 0, 0)
        SetAnchorAndPivot(item, UIAnchor.Center, UIAroundPivot.Center)
        GUI.RegisterUIEvent(item, UCE.PointerClick, "WorldBossUI", "OnItemClick")
    end

    local rankingGroup = GUI.ImageCreate(panelBg, "rankingGroup", "1800400200", 85, 380, false, 400, 460)
    SetAnchorAndPivot(rankingGroup, UIAnchor.TopLeft, UIAroundPivot.Left)

    local titleBg = GUI.ImageCreate(rankingGroup, "titleBg", "1800700070", 0, -210, false, 397, 40)
    SetAnchorAndPivot(titleBg, UIAnchor.Center, UIAroundPivot.Center)

    local cutLine1 = GUI.ImageCreate(titleBg, "cutLine1", "1800600220", 110, 0)
    GUI.SetAnchor(cutLine1, UIAnchor.Left)

    local cutLine2 = GUI.ImageCreate(titleBg, "cutLine2", "1800600220", 280, 0)
    GUI.SetAnchor(cutLine2, UIAnchor.Left)

    local text1 = GUI.CreateStatic(titleBg, "text1", "排名", 60, 1, 80, 35, "system", false, false)
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeM)
    GUI.SetColor(text1, colorDark)
    GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text1, UIAnchor.Left)

    local text2 = GUI.CreateStatic(titleBg, "text2", "玩家名称", 195, 1, 150, 35, "system", false, false)
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeM)
    GUI.SetColor(text2, colorDark)
    GUI.StaticSetAlignment(text2, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text2, UIAnchor.Left)

    local text3 = GUI.CreateStatic(titleBg, "text3", "伤害", 335, 1, 150, 35, "system", false, false)
    GUI.StaticSetFontSize(text3, UIDefine.FontSizeM)
    GUI.SetColor(text3, colorDark)
    GUI.StaticSetAlignment(text3, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text3, UIAnchor.Left)

    local loopScroll =
        GUI.LoopScrollRectCreate(
        rankingGroup,
        "loopScrolls",
        2,
        225,
        397,
        375,
        "WorldBossUI",
        "CreatRankListPool",
        "WorldBossUI",
        "OnRefreshLoopScroll",
        7,
        false,
        Vector2.New(397, 45),
        1,
        UIAroundPivot.TopRight,
        UIAnchor.TopRight,
        false
    )
    guidt.BindName(loopScroll, "loopScroll")
    -- GUI.ScrollRectSetChildSpacing(loopScroll, Vector2.New(0, 0))

    local selfInfoBg = GUI.ImageCreate(rankingGroup, "selfInfoBg", "1800600250", 0, 206, false, 397, 50)
    SetAnchorAndPivot(selfInfoBg, UIAnchor.Center, UIAroundPivot.Center)

    local rank = GUI.CreateStatic(selfInfoBg, "rank", "排名", 60, 1, 80, 35, "system", false, false)
    GUI.StaticSetFontSize(rank, UIDefine.FontSizeM)
    GUI.SetColor(rank, colorDark)
    GUI.StaticSetAlignment(rank, TextAnchor.MiddleCenter)
    GUI.SetAnchor(rank, UIAnchor.Left)
    GUI.SetVisible(rank, false)

    local rankSp = GUI.ImageCreate(selfInfoBg, "rankSp", rankSprites[1], 60, 1)
    GUI.SetAnchor(rankSp, UIAnchor.Left)

    local name = GUI.CreateStatic(selfInfoBg, "name", "玩家名称", 195, 1, 180, 35, "system", false, false)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeM)
    GUI.SetColor(name, colorDark)
    GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)
    GUI.SetAnchor(name, UIAnchor.Left)

    local damage = GUI.CreateStatic(selfInfoBg, "damage", "伤害", 335, 1, 180, 35, "system", false, false)
    GUI.StaticSetFontSize(damage, UIDefine.FontSizeM)
    GUI.SetColor(damage, colorDark)
    GUI.StaticSetAlignment(damage, TextAnchor.MiddleCenter)
    GUI.SetAnchor(damage, UIAnchor.Left)

    local countDownBg = GUI.ImageCreate(panelBg, "countDownBg", "1800601300", -260, -55, false, 140, 45)
    SetAnchorAndPivot(countDownBg, UIAnchor.BottomRight, UIAroundPivot.Right)

    local text = GUI.CreateStatic(countDownBg, "text", "倒计时：", -95, 1, 0, 0, "system")
    GUI.StaticSetFontSize(text, UIDefine.FontSizeS)
    GUI.SetColor(text, colorDark)
    GUI.SetAnchor(text, UIAnchor.Left)

    local countDown = GUI.CreateStatic(countDownBg, "countDown", "30秒", 10, 1, 0, 0, "system")
    GUI.StaticSetFontSize(countDown, UIDefine.FontSizeS)
    GUI.SetColor(countDown, colorRed)
    GUI.SetAnchor(countDown, UIAnchor.Right)
    GUI.StaticSetAlignment(countDown, TextAnchor.MiddleRight)

    local teamBtn =
        GUI.ButtonCreate(panelBg, "teamBtn", "1800102090", -530, -65, Transition.ColorTint, "", 160, 50, false)
    SetAnchorAndPivot(teamBtn, UIAnchor.BottomRight, UIAroundPivot.Right)
    GUI.RegisterUIEvent(teamBtn, UCE.PointerClick, "WorldBossUI", "OnTeamBtnClick")

    local text = GUI.CreateStatic(teamBtn, "text", "便捷组队", 0, 0, 120, 35, "system", false, false)
    GUI.SetColor(text, colorWhite)
    GUI.StaticSetFontSize(text, 26)
    SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(text, true)
    GUI.SetOutLine_Distance(text, 1)
    GUI.SetOutLine_Color(text, oulineWhite)

    local battleBtn =
        GUI.ButtonCreate(panelBg, "battleBtn", "1800102090", -90, -65, Transition.ColorTint, "", 160, 50, false)
    SetAnchorAndPivot(battleBtn, UIAnchor.BottomRight, UIAroundPivot.Right)
    GUI.RegisterUIEvent(battleBtn, UCE.PointerClick, "WorldBossUI", "OnBattleBtnClick")

    local text = GUI.CreateStatic(battleBtn, "text", "进入挑战", 0, 0, 120, 35, "system", false, false)
    GUI.SetColor(text, colorWhite)
    GUI.StaticSetFontSize(text, 26)
    SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(text, true)
    GUI.SetOutLine_Distance(text, 1)
    GUI.SetOutLine_Color(text, oulineWhite)
end
function WorldBossUI.OnExitGame()
    data = WorldBossUI.InitData()
end
function WorldBossUI.OnExit()
    guidt = nil
    GUI.DestroyWnd("WorldBossUI")
end

function WorldBossUI.OnDestroy()
    WorldBossUI.OnClose()
end
function WorldBossUI.GetDate()
    CL.SendNotify(NOTIFY.SubmitForm, "FormWorldBoss", "get_server_data",WorldBossUI.actId)
end
function WorldBossUI.OnStartBattle()
    WorldBossUI.OnExit()
end
function WorldBossUI.Refresh()
    WorldBossUI.ClientRefresh()
end
function WorldBossUI.ClientRefresh()
    data.openState = WorldBossUI.serverData.openState
    if data.openState == 1 then
        data.monsterHp = WorldBossUI.serverData.monsterHp
        data.monsterMaxHp = WorldBossUI.serverData.monsterMaxHp
        data.lastFightCnt = WorldBossUI.serverData.lastFightCnt
        data.AwardNumMax = WorldBossUI.serverData.AwardNumMax
        data.lastCD = WorldBossUI.serverData.lastCD
        data.lastTime = WorldBossUI.serverData.lastTime
    else
        data.monsterHp = 0
        data.monsterMaxHp = 0
        data.lastFightCnt = 0
        data.lastCD = 0
        data.lastTime = 0
    end

    data.activityId = WorldBossUI.serverData.activityId
    data.activityName = WorldBossUI.serverData.activityName
    data.activityTimeInfo = WorldBossUI.serverData.activityTimeInfo
    data.activityRule = WorldBossUI.serverData.activityRule
    data.activityItem = LogicDefine.SeverReward2ClientItems(WorldBossUI.serverData.activityItem)
    data.bossName = WorldBossUI.serverData.bossName
    data.bossIcon = WorldBossUI.serverData.bossIcon
    data.bossDes = WorldBossUI.serverData.bossDes
    data.bossLevel = WorldBossUI.serverData.bossLevel
    data.bgPic = WorldBossUI.serverData.bgPic

    data.myRank = WorldBossUI.serverData.myRank
    data.myName = WorldBossUI.serverData.myName
    data.myDamage = WorldBossUI.serverData.myDamage

    data.rankingTable = {}
    if WorldBossUI.serverData.rankingTable then
        for i = 1, #WorldBossUI.serverData.rankingTable do
            local rank = WorldBossUI.serverData.rankingTable[i]
            local myDamages = rank[2]
            local guids = string.split(rank[3], ",")
            local names = string.split(rank[4], ",")
            for j = 1, #guids - 1 do
                ---@type WorldBossRank
                local tmp = {}
                tmp.rank = i
                tmp.damage = myDamages
                tmp.guid = guids[j]
                tmp.name = names[j]
                test(tmp.name)
                table.insert(data.rankingTable, tmp)
            end
        end
    end

    data.teamId = WorldBossUI.serverData.teamId
    test("teamId:" .. data.teamId)
    WorldBossUI.RefreshUI()
end
function WorldBossUI.OnShow(parameter)
    local wnd = GUI.GetWnd("WorldBossUI")
    if wnd == nil then
        test("no found WorldBossUI")
        return
    end

    GUI.SetVisible(wnd, true)
    WorldBossUI.actId = UIDefine.GetParameter1(parameter)
    WorldBossUI.GetDate()
    -- WorldBossUI.RefreshUI()
end

function WorldBossUI.OnClose()
    if GUI.GetWnd("WorldBossUI") == nil then
        return
    end
    if data.lastTimeTimer ~= nil then
        data.lastTimeTimer:Stop()
        data.lastTimeTimer = nil
    end

    if data.lastCDTimer ~= nil then
        data.lastCDTimer:Stop()
        data.lastCDTimer = nil
    end
end

function WorldBossUI.RefreshUI()
    local wnd = GUI.GetWnd("WorldBossUI")

    if wnd == nil or GUI.GetVisible(wnd) == false then
        -- GUI.SetVisible(wnd, false)
        return
    end

    WorldBossUI.UpdateActivityInfo()
    WorldBossUI.UpdateActivityState()
    WorldBossUI.UpdateRankingInfo()
end

function WorldBossUI.ReduceLastTime()
    local panelBg = guidt.GetUI("panelBg")
    local remainTimeText = GUI.GetChild(panelBg, "remainTimeText")
    local str, day, hour, minute, s = UIDefine.LeftTimeFormatEx(data.lastTime)
    GUI.StaticSetText(remainTimeText, str)

    if day == hour == minute == s == 0 then
        if data.lastTimeTimer ~= nil then
            data.lastTimeTimer:Stop()
            data.lastTimeTimer = nil

            local battleBtn = GUI.GetChild(panelBg, "battleBtn")
            GUI.ButtonSetShowDisable(battleBtn, false)
        end
    elseif day == hour == 0 and data.delaytime > 1 then
        data.delaytime = (day > 0 or hour > 0) and 60 or 1
        data.lastTimeTimer:Reset(WorldBossUI.ReduceLastTime, data.delaytime, -1)
    end
end

function WorldBossUI.ReducelastCD()
    data.lastCD = data.lastCD - 1

    local panelBg = GUI.Get("WorldBossUI/panelBg")
    local countDownBg = GUI.GetChild(panelBg, "countDownBg")
    local countDown = GUI.GetChild(countDownBg, "countDown")
    if data.lastCD ~= 0 then
        GUI.SetVisible(countDownBg, true)
        GUI.StaticSetText(countDown, data.lastCD)
    else
        GUI.SetVisible(countDownBg, false)
        if data.lastCDTimer ~= nil then
            data.lastCDTimer:Stop()
            data.lastCDTimer = nil
        end
    end
end

function WorldBossUI.UpdateActivityState()
    local panelBg = guidt.GetUI("panelBg")
    local remainTimeDes = GUI.GetChild(panelBg, "remainTimeDes")

    local remainTimeText = GUI.GetChild(panelBg, "remainTimeText")
    local str, day, hour, minute, s = UIDefine.LeftTimeFormatEx(data.lastTime)
    GUI.StaticSetText(remainTimeText, str)
    data.delaytime = (day > 0 or hour > 0) and 60 or 1
    if data.lastTime ~= 0 then
        if data.lastTimeTimer == nil then
            data.lastTimeTimer = Timer.New(WorldBossUI.ReduceLastTime, data.delaytime, -1)
        else
            data.lastTimeTimer:Stop()
            data.lastTimeTimer:Reset(WorldBossUI.ReduceLastTime, data.delaytime, -1)
        end
        data.lastTimeTimer:Start()
    else
        if data.lastTimeTimer ~= nil then
            data.lastTimeTimer:Stop()
            data.lastTimeTimer = nil
        end
    end

    local remainCountText = GUI.GetChild(panelBg, "remainCountText")

    GUI.StaticSetText(remainCountText, data.lastFightCnt .. "/" .. data.AwardNumMax)

    local hpBar = GUI.GetChild(panelBg, "hpBar")
    local hpText = GUI.GetChild(hpBar, "hpText")
    if data.monsterMaxHp==0 then
        GUI.StaticSetText(hpText, "???/???")
    else
        GUI.StaticSetText(hpText, data.monsterHp .. "/" .. data.monsterMaxHp)
    end
    local hpbarPos = 0.012
    if data.monsterMaxHp ~= 0 then
        hpbarPos = math.max(data.monsterHp / data.monsterMaxHp, hpbarPos)
    else
        hpbarPos = 1
    end
    GUI.ScrollBarSetPos(hpBar, hpbarPos)

    local countDownBg = GUI.GetChild(panelBg, "countDownBg")
    local countDown = GUI.GetChild(countDownBg, "countDown")
    if data.lastCD ~= 0 then
        GUI.SetVisible(countDownBg, true)
        GUI.StaticSetText(countDown, data.lastCD)
        if data.lastCDTimer == nil then
            data.lastCDTimer = Timer.New(WorldBossUI.ReducelastCD, 1, -1)
        else
            data.lastCDTimer:Stop()
            data.lastCDTimer:Reset(WorldBossUI.ReducelastCD, 1, -1)
        end
        data.lastCDTimer:Start()
    else
        GUI.SetVisible(countDownBg, false)
        if data.lastCDTimer ~= nil then
            data.lastCDTimer:Stop()
            data.lastCDTimer = nil
        end
    end

    local battleBtn = GUI.GetChild(panelBg, "battleBtn")
    if data.openState == 0 then
        GUI.ButtonSetShowDisable(battleBtn, false)
    elseif data.openState == 1 then
        GUI.ButtonSetShowDisable(battleBtn, true)
    end

    local teamBtn = GUI.GetChild(panelBg, "teamBtn")
    if data.teamId == nil or data.teamId == 0 or data.openState == 0 then
        GUI.SetVisible(teamBtn, false)
    else
        GUI.SetVisible(teamBtn, true)
    end
end

function WorldBossUI.UpdateRankingInfo()
    local panelBg = GUI.Get("WorldBossUI/panelBg")
    local rankingGroup = GUI.GetChild(panelBg, "rankingGroup")

    local selfInfoBg = GUI.GetChild(rankingGroup, "selfInfoBg")
    local rank = GUI.GetChild(selfInfoBg, "rank")
    local rankSp = GUI.GetChild(selfInfoBg, "rankSp")
    local name = GUI.GetChild(selfInfoBg, "name")
    local damage = GUI.GetChild(selfInfoBg, "damage")

    if data.myRank <= 3 then
        if data.myRank == 0 then
            GUI.SetVisible(rank, true)
            GUI.SetVisible(rankSp, false)
            GUI.StaticSetText(rank, "未上榜")
        else
            GUI.SetVisible(rank, false)
            GUI.SetVisible(rankSp, true)
            GUI.ImageSetImageID(rankSp, rankSprites[data.myRank])
        end
    else
        GUI.SetVisible(rank, true)
        GUI.SetVisible(rankSp, false)
        GUI.StaticSetText(rank, data.myRank)
    end

    GUI.StaticSetText(name, data.myName)
    GUI.StaticSetText(damage, data.myDamage)

    local loopScroll = GUI.GetChild(rankingGroup, "loopScrolls")
    GUI.LoopScrollRectSetTotalCount(loopScroll, #data.rankingTable)
    GUI.LoopScrollRectRefreshCells(loopScroll)
end

function WorldBossUI.UpdateActivityInfo()
    local tipLabel = guidt.GetUI("titleText")
    GUI.StaticSetText(tipLabel, data.activityName)

    local panelBg = guidt.GetUI("panelBg")
    local iconBg = GUI.GetChild(panelBg, "iconBg")
    local levelBg = GUI.GetChild(iconBg, "levelBg")
    local level = GUI.GetChild(levelBg, "level")
    GUI.StaticSetText(level, data.bossLevel)

    local icon = GUI.GetChild(iconBg, "icon")

    GUI.ImageSetImageID(icon, tostring(data.bossIcon))
    if data.monsterHp == 0 then
        GUI.ImageSetGray(icon, true)
    else
        GUI.ImageSetGray(icon, false)
    end

    local group1 = GUI.GetChild(panelBg, "group1")
    GUI.ImageSetImageID(group1, data.bgPic)

    local nameBg = GUI.GetChild(group1, "nameBg")
    local name = GUI.GetChild(nameBg, "name")
    local desBg = GUI.GetChild(group1, "desBg")
    local des = GUI.GetChild(desBg, "des")

    GUI.StaticSetText(name, data.bossName)
    GUI.StaticSetText(des, data.bossDes)

    local group2 = GUI.GetChild(panelBg, "group2")
    local timeInfo = GUI.GetChild(group2, "timeInfo")
    local ruleInfo = GUI.GetChild(group2, "ruleInfo")

    GUI.StaticSetText(timeInfo, data.activityTimeInfo)
    GUI.StaticSetText(ruleInfo, data.activityRule)
    local itemScroll = GUI.GetChild(group2, "itemScroll")
    for i = 1, #data.activityItem do
        local item = GUI.GetChild(itemScroll, "item" .. i)
        GUI.SetVisible(item, true)
        local itemData = data.activityItem[i]
        if itemData ~= nil then
            GUI.SetData(item, "ItemId", itemData.id)
            ItemIcon.BindItemId(item, itemData.id)
        else
            ItemIcon.SetEmpty(item)
        end
    end

    for i = #data.activityItem + 1, 8 do
        local item = GUI.GetChild(itemScroll, "item" .. i)
        GUI.SetVisible(item, false)
    end
end

function WorldBossUI.CreatRankListPool()
    local loopScroll = guidt.GetUI("loopScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(loopScroll)
    local item = GUI.ImageCreate(loopScroll, "item" .. curCount, "1800600240", 0, 0, false, 397, 45)
    SetAnchorAndPivot(item, UIAnchor.Center, UIAroundPivot.Center)
    item:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "WorldBossUI", "OnRankItemClick")

    local rank = GUI.CreateStatic(item, "rank", "排名", 60, 1, 80, 35, "system", false, false)
    GUI.StaticSetFontSize(rank, UIDefine.FontSizeM)
    GUI.SetColor(rank, colorDark)
    GUI.StaticSetAlignment(rank, TextAnchor.MiddleCenter)
    GUI.SetAnchor(rank, UIAnchor.Left)
    GUI.SetVisible(rank, false)

    local rankSp = GUI.ImageCreate(item, "rankSp", rankSprites[1], 60, 1)
    GUI.SetAnchor(rankSp, UIAnchor.Left)

    local name = GUI.CreateStatic(item, "name", "玩家名称", 195, 1, 180, 35, "system", false, false)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeM)
    GUI.SetColor(name, colorDark)
    GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)
    GUI.SetAnchor(name, UIAnchor.Left)

    local damage = GUI.CreateStatic(item, "damage", "伤害", 335, 1, 180, 35, "system", false, false)
    GUI.StaticSetFontSize(damage, UIDefine.FontSizeM)
    GUI.SetColor(damage, colorDark)
    GUI.StaticSetAlignment(damage, TextAnchor.MiddleCenter)
    GUI.SetAnchor(damage, UIAnchor.Left)

    return item
end

function WorldBossUI.OnRefreshLoopScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local rank = GUI.GetChild(item, "rank")
    local rankSp = GUI.GetChild(item, "rankSp")
    local name = GUI.GetChild(item, "name")
    local damage = GUI.GetChild(item, "damage")
    if item == nil then
        return
    end
    -- if index > #data.rankingTable then
    --     GUI.SetVisible(item, false)
    -- end

    -- GUI.SetVisible(item, true)
    GUI.ImageSetImageID(item, index % 2 == 0 and "1800600240" or "1800600230")

    local rankVal = data.rankingTable[index].rank

    if rankVal <= 3 then
        GUI.SetVisible(rank, false)
        GUI.SetVisible(rankSp, true)
        GUI.ImageSetImageID(rankSp, rankSprites[rankVal])
    else
        GUI.SetVisible(rank, true)
        GUI.SetVisible(rankSp, false)
        GUI.StaticSetText(rank, rankVal)
    end

    GUI.StaticSetText(name, data.rankingTable[index].name)
    local damageVal = data.rankingTable[index].damage
    damageVal = UIDefine.ExchangeMoneyToStr(damageVal)
    GUI.StaticSetText(damage, damageVal)
end

function WorldBossUI.OnItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local itemId = tonumber(GUI.GetData(item, "ItemId"))

    if itemId ~= 0 then
        local panelBg = guidt.GetUI("panelBg")
        Tips.CreateByItemId(itemId, panelBg, "tips", -170, 60)
    end
end

function WorldBossUI.OnBattleBtnClick(guid)
    if data.monsterMaxHp>0 and data.monsterHp == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "boss已被击杀，无法进入战斗！")
        return
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormWorldBoss", "onjoin_worldboss_fight",WorldBossUI.actId)
end

-- function WorldBossUI.OnRankItemClick(guid)
--     local item = GUI.GetByGuid(guid)
--     local index = GUI.ItemCtrlGetIndex(item)
--     test("OnRankItemClick:" .. index + 1)
--     if index + 1 > #data.playerGuidTable then
--         return
--     end

--     local playerguid = data.playerGuidTable[index + 1]
--     CL.SendNotify(NOTIFY.SubmitForm, "FormList", "RankQueryEX", 1, playerguid)
-- end

function WorldBossUI.OnTeamBtnClick(guid)
    if data.teamId ~= 0 then
        local teamSate = LD.GetRoleInTeamState(0)
        if teamSate == 0 then
            GUI.OpenWnd("TeamPlatformPersonalUI", "teamId:" .. data.teamId)
        elseif teamSate == 2 then
            GUI.OpenWnd("TeamPanelUI")
            GUI.OpenWndInTop("TeamPlatformUI", "teamId:" .. data.teamId)
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "只有队长才能发布招募信息")
        end
    end
end
