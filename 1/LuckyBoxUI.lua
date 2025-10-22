local LuckyBoxUI = {}
_G.LuckyBoxUI = LuckyBoxUI
local _gt = UILayout.NewGUIDUtilTable()

function LuckyBoxUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    local _Panel = GUI.WndCreateWnd("LuckyBoxUI", "LuckyBoxUI", 0, 0, eCanvasGroup.Normal)
    local _PanelCover = GUI.ImageCreate(_Panel, "PanelCover", "1800400220", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
    UILayout.SetAnchorAndPivot(_PanelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(_PanelCover, true)
    _PanelCover:RegisterEvent(UCE.PointerClick)

    local _PanelBg = GUI.GroupCreate(_Panel, "panelBg", 0, 20, 0, 0)
    _gt.BindName(_PanelBg, "panelBg")
    UILayout.SetAnchorAndPivot(_PanelBg, UIAnchor.Center, UIAroundPivot.Center)

    local _Bg_Left = GUI.ImageCreate(_PanelBg, "Bg_Left", "1801601010", -170, 10, false, 340, 600)
    UILayout.SetAnchorAndPivot(_Bg_Left, UIAnchor.Center, UIAroundPivot.Center)

    local _Bg_Right = GUI.ImageCreate(_PanelBg, "Bg_Right", "1801601010", 170, 10, false, 340, 600)
    UILayout.SetAnchorAndPivot(_Bg_Right, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetScale(_Bg_Right, Vector3.New(-1, 1, 1))

    local _TitleTxt = GUI.CreateStatic(_PanelBg,"TitleTxt","福源宝箱",0,-270,300,50,"201",true)
    UILayout.SetAnchorAndPivot(_TitleTxt, UIAnchor.Top, UIAroundPivot.Center)
    UILayout.StaticSetFontSizeColorAlignment(_TitleTxt, 40, Color.New(255/255,244/255,139/255,255/255),TextAnchor.MiddleCenter)
    	--设置颜色渐变
	GUI.StaticSetIsGradientColor(_TitleTxt,true)
	GUI.StaticSetGradient_ColorTop(_TitleTxt,Color.New(255/255,244/255,139/255,255/255))
	
	--设置描边
	GUI.SetIsOutLine(_TitleTxt,true)
	GUI.SetOutLine_Distance(_TitleTxt,3)
	GUI.SetOutLine_Color(_TitleTxt,Color.New(182/255,52/255,40/255,255/255))
	
	--设置阴影
	GUI.SetIsShadow(_TitleTxt,true)
	GUI.SetShadow_Distance(_TitleTxt,Vector2.New(0,-1))
	GUI.SetShadow_Color(_TitleTxt,UIDefine.BlackColor)
    _gt.BindName(_TitleTxt, "TitleTxt")

    local _Pic1 = GUI.ImageCreate(_PanelBg, "Pic1", "1801608030", -299, 200)
    UILayout.SetAnchorAndPivot(_Pic1, UIAnchor.Top, UIAroundPivot.Center)
    local _Pic2 = GUI.ImageCreate(_PanelBg, "Pic2", "1801608070", -258, -240)
    UILayout.SetAnchorAndPivot(_Pic2, UIAnchor.Top, UIAroundPivot.Center)
    local _Pic3 = GUI.ImageCreate(_PanelBg, "Pic3", "1801608080", 298, 108)
    UILayout.SetAnchorAndPivot(_Pic3, UIAnchor.Top, UIAroundPivot.Center)

    GUI.SetIsRaycastTarget(_Pic3, true)

    local _CloseBtn = GUI.ButtonCreate(_PanelBg, "CloseBtn", "1801602010", 333, -214, Transition.ColorTint)
    UILayout.SetAnchorAndPivot(_CloseBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(_CloseBtn, UCE.PointerClick, "LuckyBoxUI", "OnCloseWnd")

    LuckyBoxUI.CreateGoldBox()
    LuckyBoxUI.CreateSilverBox()

    -- local _TipsBtn = GUI.ButtonCreate(_PanelBg, "TipsBtn", "1800702030", 233, 214, Transition.ColorTint)
    -- GUI.RegisterUIEvent(_TipsBtn, UCE.PointerClick, "LuckyBoxUI", "OnTipsBtnClick")
end

function LuckyBoxUI.CreateGoldBox()
    local _PanelBg = _gt.GetUI("panelBg")
    local _GoldBoxPage = GUI.GroupCreate(_PanelBg, "GoldBoxPage", 0, 7, 0, 0)
    _gt.BindName(_GoldBoxPage, "GoldBoxPage")

    local itemScroll = GUI.LoopScrollRectCreate(_GoldBoxPage, "itemScroll", 0, -30, 600, 500,
            "LuckyBoxUI", "CreateItemIcon", "LuckyBoxUI", "RefreshItemIcon", 0, false, Vector2.New(88, 88), 5, UIAroundPivot.Center, UIAnchor.Center);
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(15, 10))
    GUI.ScrollRectSetVertical(itemScroll,false)
    _gt.BindName(itemScroll, "itemScroll");

    local _StopTurnBtn = GUI.ButtonCreate(_GoldBoxPage, "StopTurnBtn", "1800102090", 0, 210, Transition.ColorTint)
    GUI.RegisterUIEvent(_StopTurnBtn, UCE.PointerClick, "LuckyBoxUI", "OnStopTurnBtnClick")
    local _StopTurnText = GUI.CreateStatic(_StopTurnBtn, "StopTurnText", "停止", 0, 0, 200, 35);
    GUI.SetColor(_StopTurnText, UIDefine.WhiteColor);
    GUI.StaticSetFontSize(_StopTurnText, UIDefine.FontSizeM);
    UILayout.SetSameAnchorAndPivot(_StopTurnText, UILayout.Center);
    GUI.StaticSetAlignment(_StopTurnText, TextAnchor.MiddleCenter);
    GUI.SetIsOutLine(_StopTurnText, true);
    GUI.SetOutLine_Color(_StopTurnText, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(_StopTurnText, UIDefine.OutLineDistance);
end

function LuckyBoxUI.CreateSilverBox()
    local _PanelBg = _gt.GetUI("panelBg")
    local _SilverBoxPage = GUI.GroupCreate(_PanelBg, "SilverBoxPage", 0, 7, 0, 0)
    _gt.BindName(_SilverBoxPage, "SilverBoxPage")

    local turntable = GUI.ImageCreate(_SilverBoxPage, "turntable", "1800601080", 0, 0);
    _gt.BindName(turntable, "turntable")

    local shor = -67.5
    local radi = 150

    for i = 1, 8 do
        local hor = shor + (i - 1) * 45
        local x = radi * GlobalUtils.GetPreciseDecimal(math.cos(math.rad(hor)), 2)
        local y = radi * GlobalUtils.GetPreciseDecimal(math.sin(math.rad(hor)), 2)

        local turntableItem = ItemIcon.Create(turntable, "turntableItem" .. i, x, y)
        GUI.SetData(turntableItem, "Index", i);
        GUI.RegisterUIEvent(turntableItem, UCE.PointerClick, "LuckyBoxUI", "OnTurntableItemClick")
    end

    local turntablePointer = GUI.GroupCreate(turntable, "turntablePointer", 0, 0, 0, 0)
    UILayout.SetAnchorAndPivot(turntablePointer, UIAnchor.Center, UIAroundPivot.Bottom)
    local finger = GUI.ImageCreate(turntablePointer, "finger", "1800601090", 0, 50);
    --GUI.SetEulerAngles(pointer, Vector3.New(0, 0, -22.5));
    _gt.BindName(turntablePointer, "turntablePointer")

    local _StopTurnBtn = GUI.ButtonCreate(turntable, "StopTurnBtn", "1800602280", 3, 0, Transition.ColorTint, "");
    GUI.RegisterUIEvent(_StopTurnBtn, UCE.PointerClick, "LuckyBoxUI", "OnStopTurnBtnClick");
    local _StopTurnText = GUI.CreateStatic(_StopTurnBtn, "StopTurnText", "停止", 0, 28, 200, 35);
    GUI.SetColor(_StopTurnText, UIDefine.WhiteColor);
    GUI.StaticSetFontSize(_StopTurnText, UIDefine.FontSizeXXL);
    UILayout.SetSameAnchorAndPivot(_StopTurnText, UILayout.Center);
    GUI.StaticSetAlignment(_StopTurnText, TextAnchor.MiddleCenter);
    GUI.SetIsOutLine(_StopTurnText, true);
    GUI.SetOutLine_Color(_StopTurnText, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(_StopTurnText, UIDefine.OutLineDistance);
end

function LuckyBoxUI.CreateItemIcon()
    local itemScroll = _gt.GetUI("itemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll) + 1
    local itemIcon = ItemIcon.Create(turntable, "itemIcon" .. curCount, 0, 0)
    UILayout.SetSameAnchorAndPivot(itemIcon, UILayout.Center)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "LuckyBoxUI", "OnItemClick")
    local ItemSelected = GUI.ImageCreate(itemIcon,"ItemSelected", "1800400280", -1, -1, false, 100, 100)
    GUI.SetVisible(ItemSelected,false)
    return itemIcon
end

function LuckyBoxUI.RefreshItemIcon(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]) + 1
    local itemIcon = GUI.GetByGuid(guid)
    GUI.SetData(itemIcon,"Index",index)
    ItemIcon.SetEmpty(itemIcon)
    LuckyBoxUI.GoldBoxItemIconList[tonumber(index)] = {guid = guid}
    local ItemSelected = GUI.GetChild(itemIcon,"ItemSelected")
    GUI.SetVisible(ItemSelected,false)
    GUI.SetScale(itemIcon, Vector3.New(1, 1, 1))
end

function LuckyBoxUI.OpenGoldBox()
    local TitleTxt = _gt.GetUI("TitleTxt")
    GUI.StaticSetText(TitleTxt,"福源金箱")
    local GoldBoxPage = _gt.GetUI("GoldBoxPage")
    local StopTurnBtn = GUI.GetChild(GoldBoxPage,"StopTurnBtn")
    GUI.ButtonSetShowDisable(StopTurnBtn,true)
    -- 刷新图标
    LuckyBoxUI.GoldBoxItemIconList = {}
    local itemScroll = _gt.GetUI("itemScroll")
    GUI.LoopScrollRectSetTotalCount(itemScroll,20)
    GUI.LoopScrollRectRefreshCells(itemScroll)
    -- 依次翻转图标并显示物品，完成后选中光标依次流转
    LuckyBoxUI.TurnAllItemIcon()
end

-- 创建金箱图片翻转的方法
function LuckyBoxUI.CreateGoldTurnFunc()
    for i = 1, 20 do
        LuckyBoxUI["TurnItemIconFunc"..i] = function ()
            LuckyBoxUI["TurnItemIconScale"..i] = LuckyBoxUI["TurnItemIconScale"..i] + 2/20
            LuckyBoxUI["TurnItemIconCount"..i] = LuckyBoxUI["TurnItemIconCount"..i] + 1
            local guid = LuckyBoxUI.GoldBoxItemIconList[i].guid
            local itemIcon = GUI.GetByGuid(guid)
            GUI.SetScale(itemIcon, Vector3.New(LuckyBoxUI["TurnItemIconScale"..i], 1, 1))
            if LuckyBoxUI["TurnItemIconCount"..i] == 10 then
                local item = LuckyBoxUI.Reward[i]
                local itemKeyName = item[1]
                local ItemNum = item[2]
                local ItemIsBound = item[3]
                ItemIcon.BindItemKeyName(itemIcon,itemKeyName)
                GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.RightBottomNum,ItemNum)
                if ItemIsBound == 1 then
                    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,"1800707120")--是否为绑定
                else
                    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,"")--是否为绑定
                end
            end
        end
    end
end

function LuckyBoxUI.TurnAllItemIcon()
    LuckyBoxUI.TurnItemIconIndex = 1
    for i = 1, 20 do
        LuckyBoxUI["TurnItemIconCount"..i] = 0
        LuckyBoxUI["TurnItemIconScale"..i] = -1
    end
    LuckyBoxUI.TurnAllItemIconTimer = Timer.New(LuckyBoxUI.TurnAllItemIconFunc, 0.05, 20)
    LuckyBoxUI.TurnAllItemIconTimer:Start()
end

function LuckyBoxUI.TurnAllItemIconFunc()
    local index = LuckyBoxUI.TurnItemIconIndex
    LuckyBoxUI["TurnItemIconTimer" .. index] = Timer.New(LuckyBoxUI["TurnItemIconFunc" .. index], 0.01, 20)
    LuckyBoxUI["TurnItemIconTimer" .. index]:Start()
    LuckyBoxUI.TurnItemIconIndex = index + 1
    if LuckyBoxUI.TurnItemIconIndex > 20 then
        LuckyBoxUI.TurnSelectItemIcon()
    end
end

function LuckyBoxUI.TurnSelectItemIcon()
    LuckyBoxUI.SelectItemIconIndex = 0
    LuckyBoxUI.TurnSelectItemIconTimer = Timer.New(LuckyBoxUI.TurnSelectItemIconFunc, 0.2, -1)
    LuckyBoxUI.TurnSelectItemIconTimer:Start()
end

function LuckyBoxUI.TurnSelectItemIconFunc()
    local index1 = LuckyBoxUI.SelectItemIconIndex % 20
    local index2 = LuckyBoxUI.SelectItemIconIndex % 20 + 1
    if index1 == 0 then
        index1 = 20
    end
    local guid1 = LuckyBoxUI.GoldBoxItemIconList[index1].guid
    local guid2 = LuckyBoxUI.GoldBoxItemIconList[index2].guid
    local itemIcon1 = GUI.GetByGuid(guid1)
    local itemIcon2 = GUI.GetByGuid(guid2)
    local ItemSelected1 = GUI.GetChild(itemIcon1,"ItemSelected")
    local ItemSelected2 = GUI.GetChild(itemIcon2,"ItemSelected")
    GUI.SetVisible(ItemSelected1,false)
    GUI.SetVisible(ItemSelected2,true)
    if LuckyBoxUI.StopSelectFlag then
        if LuckyBoxUI.BeginSlowFlag then
            LuckyBoxUI.BeginSlowCount = LuckyBoxUI.BeginSlowCount - 1
            index1 = index1 - 1
            if LuckyBoxUI.BeginSlowCount < 0 then
                LuckyBoxUI.BeginSlowFlag = false
            end
        else
            LuckyBoxUI.BeginSlowFlag = true
            if LuckyBoxUI.SlowFlag then
                LuckyBoxUI.SlowCount = LuckyBoxUI.SlowCount + 1
                if LuckyBoxUI.SlowCount <= 2 then
                    LuckyBoxUI.BeginSlowCount = 2
                elseif LuckyBoxUI.SlowCount <= 5 then
                    LuckyBoxUI.BeginSlowCount = 1
                else
                    LuckyBoxUI.BeginSlowCount = 1
                end
                if index2 == LuckyBoxUI.RewardIndex then
                    if LuckyBoxUI.TurnSelectItemIconTimer then
                        LuckyBoxUI.TurnSelectItemIconTimer:Stop()
                        LuckyBoxUI.TurnSelectItemIconTimer = nil
                    end
                    LuckyBoxUI.StopRoll(0.5)
                end
            else
                LuckyBoxUI.BeginSlowCount = 0
                if index2 == LuckyBoxUI.BeginStopIndex then
                    LuckyBoxUI.SlowFlag = true
                    LuckyBoxUI.SlowCount = 0
                end
            end
        end
    end
    LuckyBoxUI.SelectItemIconIndex = index1 + 1
end

function LuckyBoxUI.OpenSilverBox()
    local TitleTxt = _gt.GetUI("TitleTxt")
    GUI.StaticSetText(TitleTxt,"福源银箱")
    local turntable = _gt.GetUI("turntable")
    local StopTurnBtn = GUI.GetChild(turntable,"StopTurnBtn")
    GUI.ButtonSetImageID(StopTurnBtn, "1800602280")
    GUI.ButtonSetShowDisable(StopTurnBtn,true)
    -- 刷新图标
    LuckyBoxUI.RefreshSilverItemIcon()
    -- 旋转中间指针
    LuckyBoxUI.BeginTurnWheel()
end

function LuckyBoxUI.RefreshSilverItemIcon()
    local turntable = _gt.GetUI("turntable")
    for i = 1, 8 do
        local itemIcon = GUI.GetChild(turntable,"turntableItem" .. i)
        local item = LuckyBoxUI.Reward[i]
        local itemKeyName = item[1]
        local ItemNum = item[2]
        local ItemIsBound = item[3]
        ItemIcon.BindItemKeyName(itemIcon,itemKeyName)
        GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.RightBottomNum,ItemNum)
        if ItemIsBound == 1 then
            GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,"1800707120")--是否为绑定
        else
            GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,"")--是否为绑定
        end
    end
end

function LuckyBoxUI.BeginTurnWheel()
    local turntablePointer = _gt.GetUI("turntablePointer");
    GUI.SetEulerAngles(turntablePointer, Vector3.New(0, 0, 0))

    LuckyBoxUI.TurnWheelTimer = Timer.New(LuckyBoxUI.TurnWheelFunc, 0.01, -1)
    LuckyBoxUI.TurnWheelTimer:Start()
end

function LuckyBoxUI.TurnWheelFunc()
    local turntablePointer = _gt.GetUI("turntablePointer")
    local curAngles = GUI.GetEulerAngles(turntablePointer)
    local step = 20
    if LuckyBoxUI.StopSelectFlag then
        if LuckyBoxUI.BeginSlowFlag then
            LuckyBoxUI.BeginSlowCount = LuckyBoxUI.BeginSlowCount - 1
            step = 15
            if LuckyBoxUI.BeginSlowCount < 0 then
                LuckyBoxUI.BeginSlowFlag = false
                LuckyBoxUI.StartSlowFlag = true
                step = 10
            elseif LuckyBoxUI.BeginSlowCount < 20 then
                step = 11
            elseif LuckyBoxUI.BeginSlowCount < 40 then
                step = 13
            end
        else
            if LuckyBoxUI.StartSlowFlag then
                step = 10
                if LuckyBoxUI.SlowFlag then
                    local endTag = -(22.5 + (LuckyBoxUI.RewardIndex- 1) * 45)
                    local curTag = curAngles.z
                    if endTag > curTag then
                        endTag = endTag + 360
                        curTag = curTag + 360
                    end
                    if endTag - curTag < 10 then
                        if LuckyBoxUI.TurnWheelTimer then
                            LuckyBoxUI.TurnWheelTimer:Stop()
                            LuckyBoxUI.TurnWheelTimer = nil
                        end
                        LuckyBoxUI.EndTurnWheel()
                    elseif endTag - curTag < 15 then
                        step = 1
                    elseif endTag - curTag < 30 then
                        step = 3
                    elseif endTag - curTag < 60 then
                        step = 5
                    elseif endTag - curTag < 90 then
                        step = 7
                    end
                else
                    local beginTag = -(22.5 + (LuckyBoxUI.BeginStopIndex - 1) * 45)
                    if curAngles.z + 5 > beginTag and curAngles.z - 5 < beginTag then
                        LuckyBoxUI.SlowFlag = true
                    end
                end
            else
                LuckyBoxUI.BeginSlowFlag = true
                LuckyBoxUI.BeginSlowCount = 60
            end
        end
    end
    curAngles.z = curAngles.z - step
    if curAngles.z <= -360 then
        curAngles.z = curAngles.z + 360
    end
    GUI.SetEulerAngles(turntablePointer, Vector3.New(0, 0, curAngles.z))
end

function LuckyBoxUI.EndTurnWheel()
    local turntablePointer = _gt.GetUI("turntablePointer")
    local curAngles = GUI.GetEulerAngles(turntablePointer)
    local tag = -(22.5 + (LuckyBoxUI.RewardIndex - 1) * 45)
    if tag == -22.5 then
        curAngles.z = 360 + curAngles.z
    end

    local data = TweenData.New();
    data.Type = GUITweenType.DOLocalRotate;
    data.Duration = 1;
    data.From = curAngles
    data.To = Vector3.New(0, 0, tag)
    data.LoopType = UITweenerStyle.Once;
    GUI.DOTween(turntablePointer, data);
    LuckyBoxUI.StopRoll(1)
end

function LuckyBoxUI.StopRoll(time)
    CL.SendNotify(NOTIFY.SubmitForm, "FormLuckyBox", "StopRoll",time)
    LuckyBoxUI.StopRollTimer = Timer.New(LuckyBoxUI.StopRollFunc, time, 1)
    LuckyBoxUI.StopRollTimer:Start()
end

function LuckyBoxUI.StopRollFunc()
    LuckyBoxUI.GetGiftFlag = true
end

function LuckyBoxUI.OnClose()
    LuckyBoxUI.StopTimer()
end

function LuckyBoxUI.StopTimer()
    if LuckyBoxUI.TurnAllItemIconTimer then
        LuckyBoxUI.TurnAllItemIconTimer:Stop()
        LuckyBoxUI.TurnAllItemIconTimer = nil
    end
    for i = 1, 20 do
        if LuckyBoxUI["TurnItemIconTimer" .. i] then
            LuckyBoxUI["TurnItemIconTimer" .. i]:Stop()
            LuckyBoxUI["TurnItemIconTimer" .. i] = nil
        end
    end
    if LuckyBoxUI.TurnSelectItemIconTimer then
        LuckyBoxUI.TurnSelectItemIconTimer:Stop()
        LuckyBoxUI.TurnSelectItemIconTimer = nil
    end
    if LuckyBoxUI.TurnWheelTimer then
        LuckyBoxUI.TurnWheelTimer:Stop()
        LuckyBoxUI.TurnWheelTimer = nil
    end
end

function LuckyBoxUI.OnShow(parameter)
    local wnd = GUI.GetWnd("LuckyBoxUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd,true)
    LuckyBoxUI.OnClose()
    LuckyBoxUI.CreateGoldTurnFunc()
    LuckyBoxUI.pageIndex = tonumber(parameter)
end

function LuckyBoxUI.OnCloseWnd()
    if LuckyBoxUI.GetGiftFlag then
        GUI.CloseWnd("LuckyBoxUI")
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,"请先完成抽奖")
    end
end

function LuckyBoxUI.OnStopTurnBtnClick()
    if LuckyBoxUI.StopSelectFlag == false then
        if LuckyBoxUI.pageIndex == 1 then
            local GoldBoxPage = _gt.GetUI("GoldBoxPage")
            local StopTurnBtn = GUI.GetChild(GoldBoxPage,"StopTurnBtn")
            GUI.ButtonSetShowDisable(StopTurnBtn,false)
            LuckyBoxUI.StopSelectFlag = true
            LuckyBoxUI.BeginSlowFlag = false
            LuckyBoxUI.SlowFlag = false
            LuckyBoxUI.BeginStopIndex = (LuckyBoxUI.RewardIndex - 7 + 20) % 20
            if LuckyBoxUI.BeginStopIndex == 0 then
                LuckyBoxUI.BeginStopIndex = 20
            end
        elseif LuckyBoxUI.pageIndex == 2 then
            local turntable = _gt.GetUI("turntable")
            local StopTurnBtn = GUI.GetChild(turntable,"StopTurnBtn")
            GUI.ButtonSetImageID(StopTurnBtn, "1800602283")
            LuckyBoxUI.StopSelectFlag = true
            LuckyBoxUI.BeginSlowFlag = false
            LuckyBoxUI.StartSlowFlag = false
            LuckyBoxUI.SlowFlag = false
            LuckyBoxUI.BeginStopIndex = (LuckyBoxUI.RewardIndex - 4 + 8) % 8
            if LuckyBoxUI.BeginStopIndex == 0 then
                LuckyBoxUI.BeginStopIndex = 8
            end
        end
    end
end

-- function LuckyBoxUI.OnTipsBtnClick()
--     GUI.OpenWnd("RewardProbabilityUI")
--     RewardProbabilityUI.RefreshUI()
-- end

function LuckyBoxUI.OnTurntableItemClick(guid)
    local panelBg = _gt.GetUI("panelBg")
    local itemIcon = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(itemIcon,"Index"))
    local item = LuckyBoxUI.Reward[index]
    local posX = - 250
    if index / 4 > 1 then
        posX = 250
    end
    Tips.CreateByItemKeyName(item[1], panelBg, "itemtips", posX, 0)
end

function LuckyBoxUI.OnItemClick(guid)
    local panelBg = _gt.GetUI("panelBg")
    local itemIcon = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(itemIcon,"Index"))
    local item = LuckyBoxUI.Reward[index]
    local posX = 250
    if index % 5 > 3 or index % 5 == 0 then
        posX = - 250
    end
    Tips.CreateByItemKeyName(item[1], panelBg, "itemtips", posX, 0)
end

function LuckyBoxUI.RefreshUI()
    local GoldBoxPage = _gt.GetUI("GoldBoxPage")
    local SilverBoxPage = _gt.GetUI("SilverBoxPage")
    GUI.SetVisible(GoldBoxPage,LuckyBoxUI.pageIndex == 1)
    GUI.SetVisible(SilverBoxPage,LuckyBoxUI.pageIndex == 2)

    LuckyBoxUI.StopSelectFlag = false
    LuckyBoxUI.GetGiftFlag = false
    if LuckyBoxUI.pageIndex == 1 then
        LuckyBoxUI.OpenGoldBox()
    elseif LuckyBoxUI.pageIndex == 2 then
        LuckyBoxUI.OpenSilverBox()
    end
end