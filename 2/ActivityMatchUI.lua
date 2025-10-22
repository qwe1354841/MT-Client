ActivityMatchUI = {}
local _gt = UILayout.NewGUIDUtilTable()
local ActBattleImg = {"1801208730","1801208740","1801208750","1801208760","1801208770","1801208780","1801208790","1801208800","1801208810","1801208820","1801208830","1801208840"}
ActivityMatchUI.ActIndex = 1
ActivityMatchUI.ActBarState = false
ActivityMatchUI.CurActLst = {}
ActivityMatchUI.LoopActLst = {}
ActivityMatchUI.RefreshActLst = {}
ActivityMatchUI.ActState = {}
function ActivityMatchUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    ActivityMatchUI.ActState = {}

    print("ActivityMatchUI.Main")

    local _Panel = GUI.WndCreateWnd("ActivityMatchUI", "ActivityMatchUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetIgnoreChild_OnVisible(_Panel,true)

    local _PanelBack = GUI.ImageCreate( _Panel,"GreyBack", "1800400220", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
    UILayout.SetSameAnchorAndPivot(_PanelBack, UILayout.Center)
    GUI.SetIsRaycastTarget(_PanelBack, true)
    _PanelBack:RegisterEvent(UCE.PointerClick)
    local group = GUI.GroupCreate(_PanelBack,"PanelBack", 0, 0, 928, 618)
    UILayout.SetSameAnchorAndPivot(group, UILayout.Center)
    local panelBg = GUI.ImageCreate( group,"center", "1800600182", 0, 0, false, 928, 564)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Bottom)

    local topBar_X = 232
    local topBar_Width = 464

    local topBarLeft = GUI.ImageCreate( group,"topBarLeft", "1800600180", topBar_X, 28, false, topBar_Width, 54)
    UILayout.SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

    local topBarRight = GUI.ImageCreate( group,"topBarRight", "1800600181", -topBar_X, 28, false, topBar_Width, 54)
    UILayout.SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

    local topBarCenter = GUI.ImageCreate( group,"topBarCenter", "1800600190", -6, 27, false, 267, 50)
    UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

    local closeBtn = GUI.ButtonCreate( group,"closeBtn", "1800302120", 0, 4, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "ActivityMatchUI", "OnExit")
    local tipLabel = GUI.CreateStatic( group,"tipLabel", "活动匹配", -6, 27, 150, 35)
    UILayout.StaticSetFontSizeColorAlignment(tipLabel, 26, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)

    --左侧活动列表底板
    local _ActNameTitle = GUI.CreateStatic( group,"ActNameTitle", "当前活动：", 20, 70, 150, 35)
    UILayout.SetSameAnchorAndPivot(_ActNameTitle, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_ActNameTitle, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.Left)
    _gt.BindName(_ActNameTitle, "ActNameTitle")

    local _ActName = GUI.CreateStatic( group,"ActName", "活动名称", 130, 70, 150, 35)
    UILayout.SetSameAnchorAndPivot(_ActName, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_ActName, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.Left)
    _gt.BindName(_ActName, "ActName")

    local _ActivityLstBack = GUI.ImageCreate( group,"ActivityLstBack", "1801720230", -290, 30, false,306,240)
    _gt.BindName(_ActivityLstBack, "ActivityLstBack")
    UILayout.SetSameAnchorAndPivot(_ActivityLstBack, UILayout.Center)
    GUI.SetColor(_ActivityLstBack,Color.New(150 / 255, 120 / 255, 120 / 255, 100 / 255))

    local _ActLoopScroll = GUI.LoopScrollRectCreate(_ActivityLstBack, "ActLoopScroll", 0, 0, 230, 230, "ActivityMatchUI", "CreatActListPool",
                        "ActivityMatchUI", "OnRefreshActLoopScroll", 10, false, Vector2.New(230, 230), 1, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(_ActLoopScroll, "ActLoopScroll")
    UILayout.SetSameAnchorAndPivot(_ActLoopScroll, UILayout.Center)
    GUI.ScrollRectSetChildSpacing(_ActLoopScroll, Vector2.New(0, 10))
    _ActLoopScroll:RegisterEvent(UCE.PointerClick)
    _ActLoopScroll:RegisterEvent(UCE.EndDrag)
    GUI.SetInertia(_ActLoopScroll,false)

    local _JumpToUpBtn = GUI.ButtonCreate(_ActivityLstBack, "JumpToUpBtn", "1801107010", 0, -180, Transition.ColorTint, "")
    GUI.SetEulerAngles(_JumpToUpBtn, Vector3.New(-180, -180, -90))
    GUI.SetEventCD(_JumpToUpBtn,UCE.PointerClick,0.5)
    _gt.BindName(_JumpToUpBtn, "JumpToUpBtn")

    local _JumpToDownBtn = GUI.ButtonCreate(_ActivityLstBack, "JumpToDownBtn", "1801107010", 0, 180, Transition.ColorTint, "")
    GUI.SetEulerAngles(_JumpToDownBtn, Vector3.New(-180, -180, 90))
    GUI.SetEventCD(_JumpToDownBtn,UCE.PointerClick,0.5)
    _gt.BindName(_JumpToDownBtn, "JumpToDownBtn")

    --右侧活动信息底板
    local _ActLstBack = GUI.ImageCreate( group,"ActLstBack", "1800400200", 333, 58, false, 581, 478)
    UILayout.SetSameAnchorAndPivot(_ActLstBack, UILayout.TopLeft)

    local _ActBattle1 = GUI.ImageCreate( _ActLstBack,"ActBattle1", "1801208730", 128, 30, false)
    UILayout.SetSameAnchorAndPivot(_ActBattle1, UILayout.Top)
    GUI.SetScale(_ActBattle1, Vector3.New(1.1,1.1,1.1))
    _gt.BindName(_ActBattle1, "ActBattle1")
    local _ActBattle2 = GUI.ImageCreate( _ActLstBack,"ActBattle2", "1801208730", -128, 30, false)
    UILayout.SetSameAnchorAndPivot(_ActBattle2, UILayout.Top)
    GUI.SetScale(_ActBattle2, Vector3.New(1.1,1.1,1.1))
    _gt.BindName(_ActBattle2, "ActBattle2")
    local _ActBattleImg = GUI.ImageCreate( _ActLstBack,"ActBattleImg", "1801720040", 0, 50, false)
    UILayout.SetSameAnchorAndPivot(_ActBattleImg, UILayout.Top)

    local _ActRuleTitleBack = GUI.ImageCreate( _ActLstBack,"ActRuleTitleBack", "1801401060", 10, 200, false)
    local _ActRuleTitle = GUI.CreateStatic( _ActLstBack,"ActRuleTitle", "活动简介", 20, 200, 150, 35)
    UILayout.StaticSetFontSizeColorAlignment(_ActRuleTitle, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.Left)

    --滚动面板
    local _OnePanelSize = Vector2.New(564, 120)
    local _ActRuleScroll = GUI.ScrollRectCreate( _ActLstBack,"ActRuleScroll", 10, 235, 578, 120, 0, false, _OnePanelSize,UIAroundPivot.TopLeft ,UIAnchor.TopLeft,1,false)
    _gt.BindName(_ActRuleScroll, "ActRuleScroll")

    local _ActRule = GUI.CreateStatic( _ActRuleScroll,"ActRule", "规则", 0, 5, 540, 120)
    UILayout.StaticSetFontSizeColorAlignment(_ActRule, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.TopLeft)
    _gt.BindName(_ActRule, "ActRule")

    local _ActCutLine = GUI.ImageCreate( _ActLstBack,"ActCutLine ", "1801401070", 10, 370, false,565,4)
    -- UILayout.SetSameAnchorAndPivot(_ActBattle2, UILayout.Top)
    --活动匹配
    local starMatchBtn = GUI.ButtonCreate(_ActLstBack, "starMatchBtn", "1800402080", 400, 400, Transition.ColorTint, "开始匹配", 150, 50, false)
    GUI.RegisterUIEvent(starMatchBtn, UCE.PointerClick, "ActivityMatchUI", "OnStarMatchBtnClick")
    GUI.ButtonSetTextColor(starMatchBtn,UIDefine.White2Color)
    GUI.ButtonSetTextFontSize(starMatchBtn,UIDefine.FontSizeM)
    GUI.ButtonSetOutLineArgs(starMatchBtn, true, UIDefine.Orange2Color, 1)
    _gt.BindName(starMatchBtn, "starMatchBtn")
    GUI.SetEventCD(starMatchBtn,UCE.PointerClick,0.5)

    local endMatchBtn = GUI.ButtonCreate(_ActLstBack, "endMatchBtn", "1800602090", 400, 400, Transition.ColorTint, "取消匹配", 150, 50, false)
    GUI.RegisterUIEvent(endMatchBtn, UCE.PointerClick, "ActivityMatchUI", "OnEndMatchBtnClick")
    GUI.ButtonSetTextColor(endMatchBtn,UIDefine.White2Color)
    GUI.ButtonSetTextFontSize(endMatchBtn,UIDefine.FontSizeM)
    GUI.ButtonSetOutLineArgs(endMatchBtn, true, UIDefine.Orange2Color, 1)
    _gt.BindName(endMatchBtn, "endMatchBtn")
    GUI.SetEventCD(endMatchBtn,UCE.PointerClick,0.5)
    -- GUI.SetVisible(endMatchBtn,false)

    --匹配倒计时底板
    local _MatchCountdownBack = GUI.ImageCreate( group,"MatchCountdownBack", "1800700310", 603, 548)
    UILayout.SetSameAnchorAndPivot(_MatchCountdownBack, UILayout.TopLeft)
    _gt.BindName(_MatchCountdownBack,"MatchCountdownBack")

    local _MatchCountdownText = GUI.CreateStatic( _MatchCountdownBack,"MatchCountdownText", "正在匹配", 10, 0, 200, 35)
    UILayout.SetSameAnchorAndPivot(_MatchCountdownText, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(_MatchCountdownText, UIDefine.FontSizeL, UIDefine.Brown7Color, TextAnchor.Left)

    local _MatchCountdownTime = GUI.CreateStatic( _MatchCountdownBack ,"MatchCountdownTime", "0:05", 120, 0, 200, 35)
    UILayout.SetSameAnchorAndPivot(_MatchCountdownTime, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(_MatchCountdownTime, UIDefine.FontSizeL, UIDefine.Brown7Color, TextAnchor.Left)
    _gt.BindName(_MatchCountdownTime,"MatchCountdownTime")
end

function ActivityMatchUI.OnClose()
    ActivityMatchUI.ActBarState = false
    ActivityMatchUI.ActData = {}
end

function ActivityMatchUI.OnExit()
    GUI.CloseWnd("ActivityMatchUI")
end

function ActivityMatchUI.OnShow(parameter)
    local wnd = GUI.GetWnd("ActivityMatchUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd,true)
    local index = tonumber(parameter)
    ActivityMatchUI.CurActLst = {}
    ActivityMatchUI.GetActInfo()
    -- ActivityMatchUI.Refresh()
end

function ActivityMatchUI.GetActInfo()
    CL.SendNotify(NOTIFY.SubmitForm,"FormPersonsActMatch","GetActData")
end

function ActivityMatchUI.RefreshMatchCountdownTime()
    local MatchCountdownTime = _gt.GetUI("MatchCountdownTime")
    if TrackUI.StarMatchTime == nil then
        TrackUI.StarMatchTime = CL.GetServerTickCount()
    end
    local timer = CL.GetServerTickCount() - TrackUI.StarMatchTime
    local str = UIDefine.LeftTimeFormatEx2(timer,1)
    GUI.StaticSetText(MatchCountdownTime,str)
end

function ActivityMatchUI.Refresh()
    local JumpToDownBtn = _gt.GetUI("JumpToDownBtn")
    local JumpToUpBtn = _gt.GetUI("JumpToUpBtn")
    local scroll = _gt.GetUI("ActLoopScroll")
    ActivityMatchUI.ActLst = {}
    math.randomseed(os.time())
    local inspect = require("inspect")
    if ActivityMatchUI.ActData then
        for ActID, config in pairs(ActivityMatchUI.ActData) do
            test(ActID,type(ActID))
            test(inspect(config))
            local index1,index2 = ActivityMatchUI.GetActImgIndex()
            local actDB = DB.GetActivity(ActID)
            local ActRule = "规则规则规则规则规则规则规则"
            local ActName = "活动名称"
            if actDB and actDB.Id and actDB.Id ~= 0 then
                ActRule = actDB.DesInfo
                ActName = actDB.Name
            end
            local curActInfo = {actIcon = config.ActIcon,actRule = ActRule,actId = ActID,actName = ActName,
                                actImage1 = ActBattleImg[index1],actImage2 = ActBattleImg[index2]}
            table.insert(ActivityMatchUI.ActLst,curActInfo)
        end
    end
    if #ActivityMatchUI.ActLst == 0 then
        local index1,index2 = ActivityMatchUI.GetActImgIndex()
        local curActInfo = {actIcon = "1801720060",actRule = "活动即将开启，敬请期待",actId = -1,actName = "活动即将开启",
                            actImage1 = ActBattleImg[index1],actImage2 = ActBattleImg[index2]}
        table.insert(ActivityMatchUI.ActLst,curActInfo)
    end
    if #ActivityMatchUI.ActLst == 1 then
        GUI.ScrollRectSetVertical(scroll,false)
        GUI.UnRegisterUIEvent(scroll, UCE.EndDrag, "ActivityMatchUI", "OnActLoopDragCallBack")
        GUI.UnRegisterUIEvent(JumpToUpBtn, UCE.PointerClick, "ActivityMatchUI", "JumpToUpAct")
        GUI.UnRegisterUIEvent(JumpToDownBtn, UCE.PointerClick, "ActivityMatchUI", "JumpToDownAct")
        GUI.RegisterUIEvent(JumpToUpBtn, UCE.PointerClick, "ActivityMatchUI", "NoMoreAct")
        GUI.RegisterUIEvent(JumpToDownBtn, UCE.PointerClick, "ActivityMatchUI", "NoMoreAct")
    else
        GUI.ScrollRectSetVertical(scroll,true)
        GUI.RegisterUIEvent(scroll, UCE.EndDrag, "ActivityMatchUI", "OnActLoopDragCallBack")
        GUI.UnRegisterUIEvent(JumpToUpBtn, UCE.PointerClick, "ActivityMatchUI", "NoMoreAct")
        GUI.UnRegisterUIEvent(JumpToDownBtn, UCE.PointerClick, "ActivityMatchUI", "NoMoreAct")
        GUI.RegisterUIEvent(JumpToUpBtn, UCE.PointerClick, "ActivityMatchUI", "JumpToUpAct")
        GUI.RegisterUIEvent(JumpToDownBtn, UCE.PointerClick, "ActivityMatchUI", "JumpToDownAct")
    end
    ActivityMatchUI.RefreshActLstMethod()
    ActivityMatchUI.RefreshActInfo()
    ActivityMatchUI.RefreshActScroll()
end

function ActivityMatchUI.NoMoreAct()
    CL.SendNotify(NOTIFY.ShowBBMsg,"当前没有更多的活动")
end

function ActivityMatchUI.GetActImgIndex()
    local index1 = math.random(1,#ActBattleImg)
    local index2 = math.random(1,#ActBattleImg)
    if index2 == index1 then
        index2 = index1 + 1
        if index2 > #ActBattleImg then
            index2 = 1
        end
    end
    return index1,index2
end

function ActivityMatchUI.OnStarMatchBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local actId = GUI.GetData(btn,"actId")
    if tonumber(actId) == -1 then
        ActivityMatchUI.NoMoreAct()
    else
        ActivityMatchUI.ActBarState = true
        CL.SendNotify(NOTIFY.SubmitForm,"FormPersonsActMatch","StartMatch",actId)
        TrackUI.StarMatchTime = CL.GetServerTickCount()
    end
    test("actId:" .. actId)
end

function ActivityMatchUI.OnEndMatchBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local actId = GUI.GetData(btn,"actId")
    CL.SendNotify(NOTIFY.SubmitForm,"FormPersonsActMatch","EndMatch",actId)
    test("actId:" .. actId)
end

function ActivityMatchUI.RefreshMatchState(state,actId)
    test(state,actId,type(actId))
    ActivityMatchUI.ActState[tostring(actId)] = state
    ActivityMatchUI.RefreshActInfo()
    if ActivityMatchUI.ActState[tostring(actId)] == 0 or ActivityMatchUI.ActState[tostring(actId)] == 2 then
        GUI.CloseWnd("ActivityMatchBar")
    elseif ActivityMatchUI.ActBarState then
        GUI.OpenWnd("ActivityMatchBar")
        ActivityMatchUI.OnExit()
    end
end

function ActivityMatchUI.RefreshActScroll()
    ActivityMatchUI.LoopActLst = {}
    for i = 1, #ActivityMatchUI.RefreshActLst, 1 do
        table.insert(ActivityMatchUI.LoopActLst,ActivityMatchUI.RefreshActLst[i])
    end
    local scroll = _gt.GetUI("ActLoopScroll")
    GUI.LoopScrollRectSetTotalCount(scroll, 0)
    GUI.LoopScrollRectSetTotalCount(scroll, #ActivityMatchUI.LoopActLst)
    GUI.LoopScrollRectRefreshCells(scroll)
    GUI.ScrollRectSetNormalizedPosition(scroll,Vector2.New(0,#ActivityMatchUI.CurActLst/#ActivityMatchUI.LoopActLst))
end

function ActivityMatchUI.RefreshActLstMethod()
    ActivityMatchUI.RefreshActLst = {}
    if #ActivityMatchUI.CurActLst == 0 then
        for i = 1, #ActivityMatchUI.ActLst, 1 do
            table.insert(ActivityMatchUI.CurActLst,ActivityMatchUI.ActLst[i])
        end
    else
        local middleLst = {}
        for i = 1, #ActivityMatchUI.CurActLst, 1 do
            table.insert(middleLst,ActivityMatchUI.CurActLst[i])
        end
        ActivityMatchUI.CurActLst = {}
        for i = ActivityMatchUI.ActIndex, #middleLst, 1 do
            table.insert(ActivityMatchUI.CurActLst,middleLst[i])
        end
        if ActivityMatchUI.ActIndex > 1 then
            for i = 1, ActivityMatchUI.ActIndex - 1, 1 do
                table.insert(ActivityMatchUI.CurActLst,middleLst[i])
            end
        end
    end
    for j = 1, 3, 1 do
        for i = 1, #ActivityMatchUI.CurActLst, 1 do
            table.insert(ActivityMatchUI.RefreshActLst,ActivityMatchUI.CurActLst[i])
        end
    end
    ActivityMatchUI.ActIndex = 1
end

function ActivityMatchUI.RefreshActInfo()
    local actInfo = ActivityMatchUI.RefreshActLst[1]
    if actInfo then
        local ActBattle1 = _gt.GetUI("ActBattle1")
        local ActBattle2 = _gt.GetUI("ActBattle2")
        local ActRuleScroll = _gt.GetUI("ActRuleScroll")
        local ActRule = _gt.GetUI("ActRule")
        local ActName = _gt.GetUI("ActName")
        local starMatchBtn = _gt.GetUI("starMatchBtn")
        local endMatchBtn = _gt.GetUI("endMatchBtn")
        local MatchCountdownBack = _gt.GetUI("MatchCountdownBack")
        GUI.ImageSetImageID(ActBattle1,actInfo.actImage1)
        GUI.ImageSetImageID(ActBattle2,actInfo.actImage2)
        GUI.StaticSetText(ActRule,actInfo.actRule)
        GUI.StaticSetText(ActName,actInfo.actName)
        local h = GUI.StaticGetLabelPreferHeight(ActRule)
        GUI.SetHeight(ActRule,h + 5)
        GUI.ScrollRectSetChildSize(ActRuleScroll,Vector2.New(564, h + 5))
        GUI.ScrollRectSetNormalizedPosition(ActRuleScroll,Vector2.New(0,1))
        GUI.SetData(starMatchBtn,"actId",actInfo.actId)
        GUI.SetData(endMatchBtn,"actId",actInfo.actId)
        if ActivityMatchUI.ActState[actInfo.actId] == 0 or ActivityMatchUI.ActState[actInfo.actId] == nil then
            GUI.SetVisible(starMatchBtn,true)
            GUI.SetVisible(endMatchBtn,false)
            GUI.SetVisible(MatchCountdownBack,false)
            if ActivityMatchUI.RefreshMatchCountdownTimer ~= nil then
                ActivityMatchUI.RefreshMatchCountdownTimer:Stop()
                ActivityMatchUI.RefreshMatchCountdownTimer = nil
            end
        elseif ActivityMatchUI.ActState[actInfo.actId] == 1 then
            GUI.SetVisible(starMatchBtn,false)
            GUI.SetVisible(endMatchBtn,true)
            GUI.SetVisible(MatchCountdownBack,true)
            ActivityMatchUI.RefreshMatchCountdownTime()
            if ActivityMatchUI.RefreshMatchCountdownTimer == nil then
                ActivityMatchUI.RefreshMatchCountdownTimer = Timer.New(ActivityMatchUI.RefreshMatchCountdownTime,1,-1)
            else
                ActivityMatchUI.RefreshMatchCountdownTimer:Stop()
                ActivityMatchUI.RefreshMatchCountdownTimer:Reset(ActivityMatchUI.RefreshMatchCountdownTime,1,-1)
            end
            ActivityMatchUI.RefreshMatchCountdownTimer:Start()
        elseif ActivityMatchUI.ActState[actInfo.actId] == 2 then
            GUI.SetVisible(starMatchBtn,true)
            GUI.SetVisible(endMatchBtn,false)
            GUI.SetVisible(MatchCountdownBack,false)
            if ActivityMatchUI.RefreshMatchCountdownTimer ~= nil then
                ActivityMatchUI.RefreshMatchCountdownTimer:Stop()
                ActivityMatchUI.RefreshMatchCountdownTimer = nil
            end
        end
    end
end

function ActivityMatchUI.CreatActListPool()
    local ActLoopScroll = _gt.GetUI("ActLoopScroll")
    local count = GUI.LoopScrollRectGetChildInPoolCount(ActLoopScroll) + 1
    local itemList = GUI.ImageCreate(ActLoopScroll, "itemList" .. count, "1801720050", 0, 0)
    return itemList
end

function ActivityMatchUI.OnRefreshActLoopScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemList = GUI.GetByGuid(guid)
    local actInfo = ActivityMatchUI.LoopActLst[index]
    GUI.SetData(itemList,"index",index)
    GUI.ImageSetImageID(itemList,actInfo.actIcon)
end

function ActivityMatchUI.OnActLoopDragCallBack(guid)
    local ActLoopScroll = GUI.GetByGuid(guid)
    ActivityMatchUI.JumpToAct(ActLoopScroll)
end

function ActivityMatchUI.JumpToUpAct()
    local ActLoopScroll = _gt.GetUI("ActLoopScroll")
    ActivityMatchUI.JumpToAct(ActLoopScroll,1)
    test("JumpToUpAct")
end

function ActivityMatchUI.JumpToDownAct()
    local ActLoopScroll = _gt.GetUI("ActLoopScroll")
    ActivityMatchUI.JumpToAct(ActLoopScroll,-1)
    test("JumpToDownAct")
end
local refresh_scroll_method = function ()
    ActivityMatchUI.RefreshActScroll()
end
function ActivityMatchUI.JumpToAct(ActLoopScroll,flag)
    local count = GUI.LoopScrollRectGetChildInPoolCount(ActLoopScroll)
    local posY = GUI.LoopScrollRectGetGridLayoutPosY(ActLoopScroll)
    local sorttype = 0
    local firstItem = 0
    for i = 1, count, 1 do
        local itemList = GUI.LoopScrollRectGetChildInPool(ActLoopScroll,"itemList" .. i)
        local itemIndex = GUI.ImageGetIndex(itemList)
        if itemIndex ~= -1 then
            if firstItem == 0 then
                firstItem = itemIndex
            elseif itemIndex < firstItem then
                firstItem = itemIndex
            end
        end
    end
    local jumpIndex = 0
    if posY <= 19 + 22 then
        jumpIndex = firstItem + 0
    elseif posY > 19 + 22 and posY <= 64 + 22 then
        jumpIndex = firstItem + 1
    elseif posY > 64 + 22 and posY <= 109 + 22 then
        jumpIndex = firstItem + 2
    elseif posY > 109 + 22 then
        jumpIndex = firstItem + 3
    end
    if flag then
        jumpIndex = jumpIndex + flag
    end
    ActivityMatchUI.ActIndex = jumpIndex + 1
    while ActivityMatchUI.ActIndex > #ActivityMatchUI.CurActLst do
        ActivityMatchUI.ActIndex = ActivityMatchUI.ActIndex - #ActivityMatchUI.CurActLst
    end
    if ActivityMatchUI.ActIndex == 0 then
        ActivityMatchUI.ActIndex = #ActivityMatchUI.CurActLst
    end
    GUI.LoopScrollRectSrollToCell(ActLoopScroll,jumpIndex,1000)
    ActivityMatchUI.RefreshActLstMethod()
    ActivityMatchUI.RefreshActInfo()
    if ActivityMatchUI.waitActTimer ~= nil then
        ActivityMatchUI.waitActTimer:Stop()
        ActivityMatchUI.waitActTimer:Reset(refresh_scroll_method,0.5,1)
    else
        ActivityMatchUI.waitActTimer = Timer.New(refresh_scroll_method,0.5,1)
    end
    ActivityMatchUI.waitActTimer:Start()
end