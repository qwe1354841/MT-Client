BattleRoyaleFightUI = {}
local _gt = UILayout.NewGUIDUtilTable()

function BattleRoyaleFightUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("BattleRoyaleFightUI","BattleRoyaleFightUI",0,0)

    local group = GUI.GroupCreate(wnd,"group",435, -18)
    UILayout.SetSameAnchorAndPivot(group, UILayout.BottomLeft)
    GUI.StartGroupDrag(group)
    local panelBg = GUI.ImageCreate( group,"panelBg", "1800200010", 0, 0, false, 250, 135)
    GUI.SetIsRaycastTarget(panelBg, true)
    _gt.BindName(panelBg,"panelBg")

    local battleBack = GUI.ImageCreate(panelBg,"battleBack","1800400200",0,0,false,250,135)
    GUI.SetColor(battleBack,Color.New(1,0,0.2,1))
    GUI.SetVisible(battleBack,false)
    _gt.BindName(battleBack, "battleBack")

    local name = "battlePollutionText"
    local battleBuffText = GUI.CreateStatic(panelBg, name, "污染值：", 10, 90, 200, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(battleBuffText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)

    local name = "battlePollutionValueText"
    local battlePollutionValueText = GUI.CreateStatic(panelBg, name, "5", 120, 90, 200, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(battlePollutionValueText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(battlePollutionValueText,name)

    local name = "battleBuffText"
    local battleBuffText = GUI.CreateStatic(panelBg, name, "战鸡祝福：", 10, 62, 200, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(battleBuffText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)

    local name = "battleBuffValueText"
    local battleBuffValueText = GUI.CreateStatic(panelBg, name, "5回合", 120, 62, 200, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(battleBuffValueText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(battleBuffValueText,name)

    local tipBtn = GUI.ButtonCreate(panelBg,"tipBtn", "1800702030", 200, 80, Transition.ColorTint, "")
    _gt.BindName(tipBtn, "tipBtn")
    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick, "BattleRoyaleFightUI", "OnIipBtnClick")

    local name = "battleValueText"
    local battleValueText = GUI.CreateStatic(panelBg, name, "鸡力值：", 10, 35, 100, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(battleValueText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    local name = "battleValueSlider"
    local battleValueSlider = GUI.ScrollBarCreate(panelBg, name, "", "1800408160", "1800408110", 16, -100, 220, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    _gt.BindName(battleValueSlider, name)
    local silderFillSize = Vector2.New(220, 24)
    GUI.ScrollBarSetFillSize(battleValueSlider, silderFillSize)
    GUI.ScrollBarSetBgSize(battleValueSlider, silderFillSize)
    UILayout.SetAnchorAndPivot(battleValueSlider, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local name = "battleValueSliderBack"
    local battleValueSliderBack = GUI.ScrollBarCreate(panelBg, name, "", "1800408120", "1800408110", 16, -100, 220, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    _gt.BindName(battleValueSliderBack, name)
    GUI.ScrollBarSetFillSize(battleValueSliderBack, silderFillSize)
    GUI.ScrollBarSetBgSize(battleValueSliderBack, silderFillSize)
    UILayout.SetAnchorAndPivot(battleValueSliderBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(battleValueSliderBack,false)
    local name = "battleValueSliderCurrentTxt"
    local battleValueSliderCurrentTxt = GUI.CreateStatic(panelBg, name, "95/100", 16, -100, 220, 25, "system", true)
    _gt.BindName(battleValueSliderCurrentTxt, name)
    UILayout.StaticSetFontSizeColorAlignment(battleValueSliderCurrentTxt, UIDefine.FontSizeS, UIDefine.WhiteColor,TextAnchor.MiddleCenter)
    UILayout.SetAnchorAndPivot(battleValueSliderCurrentTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
end

function BattleRoyaleFightUI.OnIipBtnClick()
    local panelBg = _gt.GetUI("panelBg")
    local tips = GUI.ImageCreate(panelBg, "Tip", "1800400290", 250, 0, false, 410, 250)
    GUI.SetIsRaycastTarget(tips, true)
    tips:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRemoveWhenClick(tips, true)
    local scr = GUI.ScrollRectCreate(tips,"msgBg",0,-10,410,230,1,false,Vector2.New(360,230),UIAroundPivot.Top, UIAnchor.Top,1)
    UILayout.SetSameAnchorAndPivot(scr, UILayout.TopLeft)
    GUI.ScrollRectSetVertical(scr, true)
    local str = [[
    1.战鸡祝福大于0回合时，可免除一次污染值带来的鸡力伤害
    2.进入战斗时神鸡祝福剩余时间越长，转化的战鸡祝福回合数会越多
    3.战斗中神鸡祝福的剩余时间不会随着时间流逝
    4.战斗胜利的话，还会额外增加神鸡祝福的时间]]
    local tipsMsg = GUI.CreateStatic(scr,"msg",str,20,5,360,230, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(tipsMsg, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
end

function BattleRoyaleFightUI.OnClose()
    CL.UnRegisterMessage(GM.CustomDataUpdate, "BattleRoyaleFightUI", "OnCustomDataUpdate")
    if BattleRoyaleFightUI.SetBattleBackTimer ~= nil then
        BattleRoyaleFightUI.SetBattleBackTimer:Stop()
        BattleRoyaleFightUI.SetBattleBackTimer = nil
    end
    if BattleRoyaleFightUI.SetBattleValueBackTimer ~= nil then
        BattleRoyaleFightUI.SetBattleValueBackTimer:Stop()
        BattleRoyaleFightUI.SetBattleValueBackTimer = nil
    end
    local battleBack = _gt.GetUI("battleBack")
    local battleValueBarBack = _gt.GetUI("battleValueSliderBack")
    GUI.SetVisible(battleBack,false)
    GUI.SetVisible(battleValueBarBack,false)
end

function BattleRoyaleFightUI.OnShow()
    local wnd = GUI.GetWnd("BattleRoyaleFightUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd,true)
    CL.UnRegisterMessage(GM.CustomDataUpdate, "BattleRoyaleFightUI", "OnCustomDataUpdate")
    CL.RegisterMessage(GM.CustomDataUpdate, "BattleRoyaleFightUI", "OnCustomDataUpdate")
end

function BattleRoyaleFightUI.OnCustomDataUpdate(type, key, val)
    if key == "Act_Chikings_Hp" then
        local Hp_Max = TrackUI.Act_Chickings_Attr.Hp_Max
        BattleRoyaleFightUI.RefreshBattleBuffValue(tonumber(tostring(val)), Hp_Max)
    end
    test(type, key, tonumber(tostring(val)))
end

function BattleRoyaleFightUI.Refresh(val1,val2)
    -- val1回合数
    -- val2污染值
    local battleBuffValueText = _gt.GetUI("battleBuffValueText")
    local battlePollutionValueText = _gt.GetUI("battlePollutionValueText")
    GUI.StaticSetText(battleBuffValueText,val1 .. "回合")
    GUI.StaticSetText(battlePollutionValueText,val2)
    local Hp_Max = TrackUI.Act_Chickings_Attr.Hp_Max
    local Hp = CL.GetIntCustomData("Act_Chikings_Hp")
    BattleRoyaleFightUI.RefreshBattleBuffValue(Hp ,Hp_Max)
end

function BattleRoyaleFightUI.RefreshBattleBuffValue(curNum ,maxValue)
    local battleValueBar = _gt.GetUI("battleValueSlider")
    local battleValueCurTxt = _gt.GetUI("battleValueSliderCurrentTxt")
    local battleBack = _gt.GetUI("battleBack")
    local battleValueBarBack = _gt.GetUI("battleValueSliderBack")
    GUI.ScrollBarSetPos(battleValueBar,curNum / maxValue)
    GUI.StaticSetText(battleValueCurTxt,curNum .. "/" .. maxValue)
    GUI.ScrollBarSetPos(battleValueBarBack,curNum / maxValue)
    if BattleRoyaleFightUI.curBattleValue ~= nil and BattleRoyaleFightUI.curBattleValue > curNum then
        GUI.SetVisible(battleValueBarBack,true)
        GUI.SetGroupAlpha(battleValueBarBack, 0.1)
        BattleRoyaleFightUI.OnShowBattleValueBarBack = true
        if BattleRoyaleFightUI.SetBattleValueBackTimer == nil then
            BattleRoyaleFightUI.SetBattleValueBackTimer = Timer.New(BattleRoyaleFightUI.SetBattleValueBack,0.05,-1)
        else
            BattleRoyaleFightUI.SetBattleValueBackTimer:Stop()
            BattleRoyaleFightUI.SetBattleValueBackTimer:Reset(BattleRoyaleFightUI.SetBattleValueBack,0.05,-1)
        end
        BattleRoyaleFightUI.SetBattleValueBackTimer:Start()
    else
        GUI.SetVisible(battleValueBarBack,false)
        if BattleRoyaleFightUI.SetBattleValueBackTimer ~= nil then
            BattleRoyaleFightUI.SetBattleValueBackTimer:Stop()
            BattleRoyaleFightUI.SetBattleValueBackTimer = nil
        end
    end
    if curNum < 30 then
        GUI.SetVisible(battleBack,true)
        GUI.SetGroupAlpha(battleBack, 0.1)
        BattleRoyaleFightUI.OnShowBattleBack = true
        if BattleRoyaleFightUI.SetBattleBackTimer == nil then
            BattleRoyaleFightUI.SetBattleBackTimer = Timer.New(BattleRoyaleFightUI.SetBattleBack,0.1,-1)
        else
            BattleRoyaleFightUI.SetBattleBackTimer:Stop()
            BattleRoyaleFightUI.SetBattleBackTimer:Reset(BattleRoyaleFightUI.SetBattleBack,0.1,-1)
        end
        BattleRoyaleFightUI.SetBattleBackTimer:Start()
    else
        GUI.SetVisible(battleBack,false)
        if BattleRoyaleFightUI.SetBattleBackTimer ~= nil then
            BattleRoyaleFightUI.SetBattleBackTimer:Stop()
            BattleRoyaleFightUI.SetBattleBackTimer = nil
        end
    end
    BattleRoyaleFightUI.curBattleValue = curNum
end

function BattleRoyaleFightUI.SetBattleValueBack()
    if BattleRoyaleFightUI.OnShowBattleValueBarBack then
        local battleValueBarBack = _gt.GetUI("battleValueSliderBack")
        local alpha = GUI.GetGroupAlpha(battleValueBarBack)
        alpha = alpha + 0.1
        if alpha < 0.4 then
            GUI.SetGroupAlpha(battleValueBarBack, alpha)
        else
            BattleRoyaleFightUI.OnShowBattleValueBarBack = false
        end
    end
    if BattleRoyaleFightUI.OnShowBattleValueBarBack == false then
        local battleValueBarBack = _gt.GetUI("battleValueSliderBack")
        local alpha = GUI.GetGroupAlpha(battleValueBarBack)
        alpha = alpha - 0.1
        if alpha > 0.1 then
            GUI.SetGroupAlpha(battleValueBarBack, alpha)
        else
            GUI.SetVisible(battleValueBarBack,false)
            BattleRoyaleFightUI.OnShowBattleValueBarBack = true
            BattleRoyaleFightUI.SetBattleValueBackTimer:Stop()
        end
    end
end

function BattleRoyaleFightUI.SetBattleBack()
    if BattleRoyaleFightUI.OnShowBattleBack then
        local battleBack = _gt.GetUI("battleBack")
        local alpha = GUI.GetGroupAlpha(battleBack)
        alpha = alpha + 0.1
        if alpha < 0.6 then
            GUI.SetGroupAlpha(battleBack, alpha)
        else
            BattleRoyaleFightUI.OnShowBattleBack = false
        end
    end
    if BattleRoyaleFightUI.OnShowBattleBack == false then
        local battleBack = _gt.GetUI("battleBack")
        local alpha = GUI.GetGroupAlpha(battleBack)
        alpha = alpha - 0.1
        if alpha > 0.1 then
            GUI.SetGroupAlpha(battleBack, alpha)
        else
            BattleRoyaleFightUI.OnShowBattleBack = true
        end
    end
end