AniPopUI = {}
local _gt = UILayout.NewGUIDUtilTable()

-- 图像列表
AniPopUI.PopList = {1900300010,1900300020,1900300030,1900300040,1900300050,1900300060,1900300070,1900300080,1900300090,1900300100,1900300110,1900300120}

function AniPopUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("AniPopUI","AniPopUI",0,0)
    _gt.BindName(wnd,"wnd")
end

function AniPopUI.CreateAniPopPanel()
    local wnd = _gt.GetUI("wnd")
    local AniPopPanel = GUI.GetChild(wnd,"AniPopPanel",false)
    if AniPopPanel then
        GUI.Destroy(AniPopPanel)
    end

    local _PanelBack = GUI.ImageCreate( wnd,"AniPopPanel", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetSameAnchorAndPivot(_PanelBack, UILayout.Center)
    GUI.SetIsRaycastTarget(_PanelBack, true)
    _PanelBack:RegisterEvent(UCE.PointerClick)
    _gt.BindName(_PanelBack,"AniPopPanel")

    local itemX = AniPopUI.PosX * (80 + 10)
    local itemY = AniPopUI.PosY * (80 + 10)
    local panelX = itemX + 40
    local panelY = itemY + 178

    local group = GUI.GroupCreate(_PanelBack,"PanelBack", 0, 0, panelX, panelY)
    UILayout.SetSameAnchorAndPivot(group, UILayout.Center)
    local panelBg = GUI.ImageCreate(group,"center", "1800600182", 0, 0, false, panelX, panelY - 54)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Bottom)

    local topBar_Width = panelX / 2

    local topBarLeft = GUI.ImageCreate(group,"topBarLeft", "1800600180", 0, 0, false, topBar_Width, 54)
    UILayout.SetSameAnchorAndPivot(topBarLeft, UILayout.TopLeft)

    local topBarRight = GUI.ImageCreate(group,"topBarRight", "1800600181", 0, 0, false, topBar_Width, 54)
    UILayout.SetSameAnchorAndPivot(topBarRight, UILayout.TopRight)

    local topBarCenter = GUI.ImageCreate(group,"topBarCenter", "1800600190", -6, 27, false, 267, 50)
    UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

    local closeBtn = GUI.ButtonCreate(group,"closeBtn", "1800302120", 0, 4, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "AniPopUI", "OnExit")

    local tipLabel = GUI.CreateStatic(group,"tipLabel", "西游对对碰", -6, 27, 150, 35)
    UILayout.StaticSetFontSizeColorAlignment(tipLabel, 24, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)

    local itemBg = GUI.ImageCreate(group, "itemBg", "1800400010", 10, 95, false, itemX + 20, panelY - 150)
    UILayout.SetSameAnchorAndPivot(itemBg, UILayout.TopLeft)
    _gt.BindName(itemBg,"itemBg")

    local sliderWidth = itemX - 20
    local aniPopSlider = GUI.ScrollBarCreate(itemBg, "aniPopSlider", "", "1800408160", "1800408110", 20, -20, sliderWidth, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    _gt.BindName(aniPopSlider, "aniPopSlider")
    local silderFillSize = Vector2.New(sliderWidth, 12)
    GUI.ScrollBarSetFillSize(aniPopSlider, silderFillSize)
    GUI.ScrollBarSetBgSize(aniPopSlider, silderFillSize)

    local aniPopSliderBack = GUI.ScrollBarCreate(itemBg, "aniPopSliderBack", "", "1800408120", "1800408110", 20, -20, sliderWidth, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    _gt.BindName(aniPopSliderBack, "aniPopSliderBack")
    GUI.ScrollBarSetFillSize(aniPopSliderBack, silderFillSize)
    GUI.ScrollBarSetBgSize(aniPopSliderBack, silderFillSize)
    GUI.SetVisible(aniPopSliderBack,false)

    local levelLabel = GUI.CreateStatic(itemBg,"levelLabel", "难  度：", 20, -45, 150, 35)
    UILayout.StaticSetFontSizeColorAlignment(levelLabel, 20, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local levelText = GUI.CreateStatic(itemBg,"levelText", "简单", 92, -45, 150, 35)
    UILayout.StaticSetFontSizeColorAlignment(levelText, 20, UIDefine.BrownColor, TextAnchor.MiddleLeft)
    _gt.BindName(levelText,"levelText")

    local countLabel = GUI.CreateStatic(itemBg,"countLabel", "次  数：", 30, -45, 150, 35)
    UILayout.StaticSetFontSizeColorAlignment(countLabel, 20, UIDefine.BrownColor, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(countLabel, UILayout.TopRight)

    local countText = GUI.CreateStatic(itemBg,"countText", "1000", 102, -45, 150, 35)
    UILayout.StaticSetFontSizeColorAlignment(countText, 20, UIDefine.BrownColor, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(countText, UILayout.TopRight)
    _gt.BindName(countText,"countText")

    local againGameBtn = GUI.ButtonCreate(itemBg, "againGameBtn", "1800402110", 30, 42, Transition.ColorTint,"切换难度", 120, 40,false)
    GUI.SetIsOutLine(againGameBtn, true);
    GUI.ButtonSetTextFontSize(againGameBtn, 20);
    GUI.ButtonSetTextColor(againGameBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(againGameBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(againGameBtn, UIDefine.OutLineDistance);
    UILayout.SetSameAnchorAndPivot(againGameBtn, UILayout.BottomLeft)
    GUI.RegisterUIEvent(againGameBtn, UCE.PointerClick, "AniPopUI", "OnAgainGameBtnClick")

    local rankBtn = GUI.ButtonCreate(itemBg, "rankBtn", "1800402110", -30, 42, Transition.ColorTint,"排行榜", 120, 40,false)
    GUI.SetIsOutLine(rankBtn, true);
    GUI.ButtonSetTextFontSize(rankBtn, 20);
    GUI.ButtonSetTextColor(rankBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(rankBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(rankBtn, UIDefine.OutLineDistance);
    UILayout.SetSameAnchorAndPivot(rankBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(rankBtn, UCE.PointerClick, "AniPopUI", "OnRankBtnClick")

    local itemScroll = GUI.LoopScrollRectCreate(itemBg, "itemScroll", 0, 20, itemX, itemY,
            "AniPopUI", "CreateItemIconPool", "AniPopUI", "RefreshItemScroll", 0, false, Vector2.New(80, 80), AniPopUI.PosX, UIAroundPivot.Top, UIAnchor.Top);
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(10, 10));
    GUI.ScrollRectSetVertical(itemScroll,false)
    UILayout.SetSameAnchorAndPivot(itemScroll, UILayout.Top)
    _gt.BindName(itemScroll, "itemScroll");
end

function AniPopUI.OnAgainGameBtnClick()
    local itemBg = _gt.GetUI("itemBg")
    local againGamePanel = GUI.ImageCreate(itemBg, "againGamePanel", "1800400290", 15, 0, false, 150, 0)
    GUI.SetIsRaycastTarget(againGamePanel, true)
    againGamePanel:RegisterEvent(UCE.PointerClick)
    UILayout.SetSameAnchorAndPivot(againGamePanel, UILayout.BottomLeft)
    GUI.SetIsRemoveWhenClick(againGamePanel, true)
    local posY = 10
    for i = 1, #AniPopUI.LevelList do
        local levelIndex = (#AniPopUI.LevelList + 1) - i
        local againBtn = GUI.ButtonCreate(againGamePanel, "againBtn", 1800402110, 15, posY, Transition.ColorTint, AniPopUI.LevelList[levelIndex], 120, 40, false);
        GUI.ButtonSetTextColor(againBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(againBtn, 20)
        GUI.SetData(againBtn,"levelIndex",levelIndex)
        GUI.RegisterUIEvent(againBtn,UCE.PointerClick,"AniPopUI","OnClickAgainBtn")
        GUI.AddWhiteName(againGamePanel,GUI.GetGuid(againBtn))
        posY = posY + 50
    end
    GUI.SetHeight(againGamePanel, posY)
end

function AniPopUI.CreateItemIconPool()
    local itemScroll = _gt.GetUI("itemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll) + 1
    local itemicon = GUI.ImageCreate(itemScroll, "itemIcon"..curCount, "1800600050", 0, 0)
    _gt.BindName(itemicon, "itemIcon"..curCount)
    GUI.SetIsRaycastTarget(itemicon, true)
    itemicon:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(itemicon, UCE.PointerClick, "AniPopUI", "OnItemClick");
    local itemInfo = GUI.ImageCreate(itemicon, "itemInfo", "1900000000", 0, 0, false, 72, 72)
    UILayout.SetSameAnchorAndPivot(itemInfo, UILayout.Center)
    GUI.SetVisible(itemInfo,false)
    local ItemSelected = GUI.ImageCreate(itemicon,"ItemSelected", "1800600160", -1, -1, false, 82, 82)
    GUI.SetVisible(ItemSelected,false)
    return itemicon
end

function AniPopUI.RefreshItemScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    GUI.SetData(item,"itemIndex",index)
    local ItemSelected = GUI.GetChild(item,"ItemSelected")
    GUI.SetVisible(ItemSelected,false)
end

function AniPopUI.OnItemClick(guid)
    local itemicon = GUI.GetByGuid(guid)
    local index = GUI.GetData(itemicon, "itemIndex")
    if AniPopUI.CanClick1 then
        AniPopUI.CanClick1 = false
        AniPopUI.CanClick2 = false
        CL.SendNotify(NOTIFY.SubmitForm, "FormAniPop", "RunPop", index)
    elseif AniPopUI.CanClick2 and AniPopUI.ItemIndex1 ~= tonumber(index) then
        AniPopUI.CanClick1 = false
        AniPopUI.CanClick2 = false
        CL.SendNotify(NOTIFY.SubmitForm, "FormAniPop", "RunPop", index)
    end
end

function AniPopUI.ItemIconTurn(msgIndex,clickNum,itemIndex)
    AniPopUI.MsgIndex = msgIndex
    AniPopUI.ClickNum = clickNum
    AniPopUI.ItemIndex = itemIndex
    if clickNum % 2 == 1 then
        AniPopUI.ItemIndex1 = itemIndex
    else
        AniPopUI.ItemIndex2 = itemIndex
    end
    AniPopUI.ItemIconTurnOver()
    AniPopUI.RefreshInfo()
end

function AniPopUI.ItemResult(isSame)
    if isSame then
        AniPopUI.EffaceItemTimer = Timer.New(AniPopUI.EffaceItem, 0.8, 1)
        AniPopUI.EffaceItemTimer:Start()
    else
        AniPopUI.TurnBackItemTimer = Timer.New(AniPopUI.ItemTurnBack, 0.8, 1)
        AniPopUI.TurnBackItemTimer:Start()
    end
end

function AniPopUI.ItemTurnBack()
    AniPopUI.ItemIconTurnScale = 1
    AniPopUI.ItemIconTurnCount = 0
    AniPopUI.ItemIconInfoShow = true
    AniPopUI.TurnBackItemIconTimer = Timer.New(AniPopUI.TurnBackItemIconFunc, 0.01, 20)
    AniPopUI.TurnBackItemIconTimer:Start()
end

function AniPopUI.EffaceItem()
    AniPopUI.EffaceItemTimer1 = Timer.New(AniPopUI.EffaceItemTimerFunc1, 0.1, 4)
    AniPopUI.EffaceItemTimer2 = Timer.New(AniPopUI.EffaceItemTimerFunc2, 0.6, 1)
    AniPopUI.EffaceItemTimer1:Start()
    AniPopUI.EffaceItemTimer2:Start()
    AniPopUI.AddEndTime()
end

function AniPopUI.ItemIconTurnOver()
    AniPopUI.ItemIconTurnScale = -1
    AniPopUI.ItemIconTurnCount = 0
    AniPopUI.ItemIconInfoShow = true
    AniPopUI.TurnItemIconTimer = Timer.New(AniPopUI.TurnItemIconFunc, 0.01, 20)
    AniPopUI.TurnItemIconTimer:Start()
end

function AniPopUI.TurnItemIconFunc()
    AniPopUI.ItemIconTurnScale = AniPopUI.ItemIconTurnScale + (2/20)
    AniPopUI.ItemIconTurnCount = AniPopUI.ItemIconTurnCount + 1
    local itemicon = _gt.GetUI("itemIcon" .. AniPopUI.ItemIndex)
    GUI.SetScale(itemicon,Vector3.New(AniPopUI.ItemIconTurnScale,1,1))
    if AniPopUI.ItemIconInfoShow and AniPopUI.ItemIconTurnScale > 0 then
        AniPopUI.ItemIconInfoShow = false
        local itemInfo = GUI.GetChild(itemicon,"itemInfo",false)
        local ItemSelected = GUI.GetChild(itemicon,"ItemSelected",false)
        GUI.ImageSetImageID(itemInfo,AniPopUI.PopList[AniPopUI.MsgIndex])
        GUI.SetVisible(itemInfo,true)
        GUI.SetVisible(ItemSelected,true)
    end
    if AniPopUI.ItemIconTurnCount > 19 then
        GUI.SetScale(itemicon,Vector3.New(1,1,1))
        if AniPopUI.ItemIndex ==  AniPopUI.ItemIndex1 then
            AniPopUI.CanClick2 = true
        end
    end
end

function AniPopUI.TurnBackItemIconFunc()
    AniPopUI.ItemIconTurnScale = AniPopUI.ItemIconTurnScale - (2/20)
    AniPopUI.ItemIconTurnCount = AniPopUI.ItemIconTurnCount + 1
    local itemicon1 = _gt.GetUI("itemIcon" .. AniPopUI.ItemIndex1)
    local itemicon2 = _gt.GetUI("itemIcon" .. AniPopUI.ItemIndex2)
    GUI.SetScale(itemicon1,Vector3.New(AniPopUI.ItemIconTurnScale,1,1))
    GUI.SetScale(itemicon2,Vector3.New(AniPopUI.ItemIconTurnScale,1,1))
    if AniPopUI.ItemIconInfoShow and AniPopUI.ItemIconTurnScale < 0 then
        AniPopUI.ItemIconInfoShow = false
        local itemInfo1 = GUI.GetChild(itemicon1,"itemInfo",false)
        local itemInfo2 = GUI.GetChild(itemicon2,"itemInfo",false)
        local ItemSelected1 = GUI.GetChild(itemicon1,"ItemSelected",false)
        local ItemSelected2 = GUI.GetChild(itemicon2,"ItemSelected",false)
        GUI.ImageSetImageID(itemInfo1,"1900000000")
        GUI.ImageSetImageID(itemInfo2,"1900000000")
        GUI.SetVisible(itemInfo1,false)
        GUI.SetVisible(itemInfo2,false)
        GUI.SetVisible(ItemSelected1,false)
        GUI.SetVisible(ItemSelected2,false)
    end
    if AniPopUI.ItemIconTurnCount > 19 then
        GUI.SetScale(itemicon1,Vector3.New(-1,1,1))
        GUI.SetScale(itemicon2,Vector3.New(-1,1,1))
        AniPopUI.ItemIndex1 = nil
        AniPopUI.ItemIndex2 = nil
        AniPopUI.CanClick1 = true
    end
end

function AniPopUI.EffaceItemTimerFunc1()
    local itemicon1 = _gt.GetUI("itemIcon" .. AniPopUI.ItemIndex1)
    local itemicon2 = _gt.GetUI("itemIcon" .. AniPopUI.ItemIndex2)
    local ItemSelected1 = GUI.GetChild(itemicon1,"ItemSelected",false)
    local ItemSelected2 = GUI.GetChild(itemicon2,"ItemSelected",false)
    GUI.SetVisible(ItemSelected1,not GUI.GetVisible(ItemSelected1))
    GUI.SetVisible(ItemSelected2,not GUI.GetVisible(ItemSelected2))
end

function AniPopUI.EffaceItemTimerFunc2()
    local itemicon1 = _gt.GetUI("itemIcon" .. AniPopUI.ItemIndex1)
    local itemicon2 = _gt.GetUI("itemIcon" .. AniPopUI.ItemIndex2)
    GUI.SetVisible(itemicon1,false)
    GUI.SetVisible(itemicon2,false)
    AniPopUI.CanClick1 = true
end

function AniPopUI.CountDownTimerFunc()
    AniPopUI.RefreshTimeSlider()
    local aniPopSliderBack = _gt.GetUI("aniPopSliderBack")
    if AniPopUI.EndTime/AniPopUI.RunTime < 0.5 then
        GUI.SetVisible(aniPopSliderBack,true)
        GUI.SetGroupAlpha(aniPopSliderBack, 0.1)
        AniPopUI.OnShowTimeBack = true
        if AniPopUI.SetTimeBackTimer == nil then
            AniPopUI.SetTimeBackTimer = Timer.New(AniPopUI.SetTimeBackFunc,0.05,-1)
        else
            AniPopUI.SetTimeBackTimer:Stop()
            AniPopUI.SetTimeBackTimer:Reset(AniPopUI.SetTimeBackFunc,0.05,-1)
        end
        AniPopUI.SetTimeBackTimer:Start()
    else
        GUI.SetVisible(aniPopSliderBack,false)
        if AniPopUI.SetTimeBackTimer ~= nil then
            AniPopUI.SetTimeBackTimer:Stop()
            AniPopUI.SetTimeBackTimer = nil
        end
    end
    AniPopUI.EndTime = AniPopUI.EndTime - 1
end

function AniPopUI.RefreshTimeSlider()
    local aniPopSlider = _gt.GetUI("aniPopSlider")
    local aniPopSliderBack = _gt.GetUI("aniPopSliderBack")

    GUI.ScrollBarSetPos(aniPopSlider, AniPopUI.EndTime/AniPopUI.RunTime)
    GUI.ScrollBarSetPos(aniPopSliderBack, AniPopUI.EndTime/AniPopUI.RunTime)
end

function AniPopUI.AddEndTime()
    if AniPopUI.EndTime + AniPopUI.AddTime <= AniPopUI.RunTime then
        AniPopUI.EndTime = AniPopUI.EndTime + AniPopUI.AddTime
    else
        AniPopUI.EndTime = AniPopUI.RunTime
    end
    AniPopUI.RefreshTimeSlider()
end

function AniPopUI.SetTimeBackFunc()
    if AniPopUI.OnShowTimeBack then
        local aniPopSliderBack = _gt.GetUI("aniPopSliderBack")
        local alpha = GUI.GetGroupAlpha(aniPopSliderBack)
        alpha = alpha + 0.1
        if alpha < 0.4 then
            GUI.SetGroupAlpha(aniPopSliderBack, alpha)
        else
            AniPopUI.OnShowTimeBack = false
        end
    end
    if AniPopUI.OnShowTimeBack == false then
        local aniPopSliderBack = _gt.GetUI("aniPopSliderBack")
        local alpha = GUI.GetGroupAlpha(aniPopSliderBack)
        alpha = alpha - 0.1
        if alpha > 0.1 then
            GUI.SetGroupAlpha(aniPopSliderBack, alpha)
        else
            GUI.SetVisible(aniPopSliderBack,false)
            AniPopUI.OnShowTimeBack = true
            AniPopUI.SetTimeBackTimer:Stop()
        end
    end
end

function AniPopUI.OnRankBtnClick()
    GUI.OpenWnd("RankUI","4,6")
end

function AniPopUI.OnClickAgainBtn(guid)
    local btn = GUI.GetByGuid(guid)
    local index =  tonumber(GUI.GetData(btn,"levelIndex"))
    local desc = "选中的是"..AniPopUI.LevelList[index] .."难度，是否开始新游戏"
    AniPopUI.LevelIndex = index
    GlobalUtils.ShowBoxMsg2Btn("游戏提示",desc,"AniPopUI","是","OnConfirmAgainBtnClick","否")
end

function AniPopUI.PopGameEndMsg(flag)
    local wnd = GUI.GetWnd("AniPopUI")
    if wnd == nil then
        return
    end
    AniPopUI.LevelIndex = AniPopUI.Lv
    AniPopUI.StopTimer()
    if flag then
        AniPopUI.GameFinishTimer = Timer.New(AniPopUI.PopGameFinishFunc, 1.6, 1)
        AniPopUI.GameFinishTimer:Start()
    else
        local desc = "时间已用完，" .. "是否开始新游戏\n新游戏难度为" ..AniPopUI.LevelList[AniPopUI.LevelIndex]
        GlobalUtils.ShowBoxMsg2Btn("游戏提示",desc,"AniPopUI","是","OnConfirmAgainBtnClick","否")
    end
end

function AniPopUI.PopGameFinishFunc()
    local desc = "游戏已完成，" .. "是否开始新游戏\n新游戏难度为" ..AniPopUI.LevelList[AniPopUI.LevelIndex]
    AniPopUI.LevelIndex = AniPopUI.Lv
    GlobalUtils.ShowBoxMsg2Btn("游戏提示",desc,"AniPopUI","是","OnConfirmAgainBtnClick","否")
end

function AniPopUI.OnConfirmAgainBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormAniPop", "GameAgain", AniPopUI.LevelIndex)
end

function AniPopUI.CloseAniPopPanel()
    local AniPopPanel = _gt.GetUI("AniPopPanel")
    GUI.SetVisible(AniPopPanel,false)
    AniPopUI.StopTimer()
end

function AniPopUI.OnExit()
    AniPopUI.StopTimer()
    GUI.DestroyWnd("AniPopUI")
end

function AniPopUI.StopTimer()
    if AniPopUI.CountDownTimer then
        AniPopUI.CountDownTimer:Stop()
        AniPopUI.CountDownTimer = nil
    end
    if AniPopUI.TimeBackTimer then
        AniPopUI.TimeBackTimer:Stop()
        AniPopUI.TimeBackTimer = nil
    end
end

function AniPopUI.OnShow()
    local wnd = GUI.GetWnd("AniPopUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd,true)
    -- CL.SendNotify(NOTIFY.SubmitForm, "FormAniPop", "StartGame ", 1)
end

function AniPopUI.InitData()
    AniPopUI.CanClick1 = true
    AniPopUI.CanClick2 = false
    AniPopUI.PosX = AniPopUI.Config.X
    AniPopUI.PosY = AniPopUI.Config.Y
    AniPopUI.ClickNum = 0
    AniPopUI.Lv = AniPopUI.Config.Lv
    AniPopUI.LevelList = AniPopUI.Config.Name

    AniPopUI.RunTime = AniPopUI.Config.T
    AniPopUI.EndTime = AniPopUI.RunTime
    AniPopUI.AddTime = AniPopUI.Config.TA
end

function AniPopUI.RefreshUI()
    AniPopUI.CloseAniPopPanel()
    AniPopUI.InitData()
    AniPopUI.CreateAniPopPanel()
    AniPopUI.RefreshInfo()
    AniPopUI.CountDownTimerFunc()

    local itemScroll = _gt.GetUI("itemScroll")
    GUI.LoopScrollRectSetTotalCount(itemScroll,AniPopUI.PosX * AniPopUI.PosY)
    GUI.LoopScrollRectRefreshCells(itemScroll)

    AniPopUI.CountDownTimer = Timer.New(AniPopUI.CountDownTimerFunc, 1, -1)
    AniPopUI.CountDownTimer:Start()
end

function AniPopUI.RefreshInfo()
    local countText = _gt.GetUI("countText")
    local levelText = _gt.GetUI("levelText")
    GUI.StaticSetText(countText,AniPopUI.ClickNum)
    GUI.StaticSetText(levelText,AniPopUI.LevelList[AniPopUI.Lv])
end