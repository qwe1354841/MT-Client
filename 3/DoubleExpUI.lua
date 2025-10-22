DoubleExpUI = {}
local _gt = UILayout.NewGUIDUtilTable()

function DoubleExpUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("DoubleExpUI", "DoubleExpUI", 0, 0)

    local numConfirmCover = GUI.ImageCreate(wnd, "numConfirmCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetSameAnchorAndPivot(numConfirmCover, UILayout.Center)
    GUI.SetIsRaycastTarget(numConfirmCover, true)
    numConfirmCover:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(numConfirmCover, UCE.PointerClick, "DoubleExpUI", "OnExit")

    local changeBoardBg = GUI.ImageCreate(numConfirmCover, "changeBoardBg", "1800001120", 0, 0, false, 465, 275)
    UILayout.SetSameAnchorAndPivot(changeBoardBg, UILayout.Center)
    GUI.SetIsRaycastTarget(changeBoardBg, true)
    changeBoardBg:RegisterEvent(UCE.PointerClick)

    local closeBtn = GUI.ButtonCreate(changeBoardBg, "closeBtn", "1800002050", -11, 11, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "DoubleExpUI", "OnExit")

    local titleBg = GUI.ImageCreate(changeBoardBg, "titleBg", "1800001030", 0, 15, false, 265, 38)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)
    local txt = GUI.CreateStatic(titleBg, "txt", "", 0, 0, 180, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.StaticSetText(txt, "双倍经验")

    GUI.ImageCreate(changeBoardBg, "flower", "1800007060", -194, -125)
    GUI.ImageCreate(changeBoardBg, "bg", "1800400010", 0, -8, false, 414, 132)
    GUI.ImageCreate(changeBoardBg, "bg", "1800800010", 0, -31, false, 368, 38)
    GUI.ImageCreate(changeBoardBg, "bg", "1800800010", 0, 20, false, 368, 38)

    local FrozenNum = GUI.CreateStatic(changeBoardBg, "FrozenNum", "已冻结：0", 93, 90, 400, 32)
    _gt.BindName(FrozenNum, "FrozenNum")
    UILayout.SetSameAnchorAndPivot(FrozenNum, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(FrozenNum, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local CanGetNum = GUI.CreateStatic(changeBoardBg, "CanGetNum", "双倍点数：0", 72, 141, 400, 32)
    _gt.BindName(CanGetNum, "CanGetNum")
    UILayout.SetSameAnchorAndPivot(CanGetNum, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(CanGetNum, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local infoBtn = GUI.ButtonCreate(changeBoardBg, "infoBtn", "1800702030", -181, -93, Transition.ColorTint)
    GUI.RegisterUIEvent(infoBtn, UCE.PointerClick, "DoubleExpUI", "OnInfoBtn")

    local FrozenBtn = GUI.ButtonCreate(changeBoardBg, "FrozenBtn", "1800602030", -47, -146, Transition.ColorTint, "", 100, 47 ,false)
    UILayout.SetSameAnchorAndPivot(FrozenBtn, UILayout.BottomRight)
    local btnTxt = GUI.CreateStatic(FrozenBtn, "btnTxt", "冻结", 0, 0, 150, 45)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(btnTxt, 1)
    GUI.SetIsOutLine(btnTxt, true)
    GUI.RegisterUIEvent(FrozenBtn, UCE.PointerClick, "DoubleExpUI", "OnFrozenBtn")

    local GetBtn = GUI.ButtonCreate(changeBoardBg, "GetBtn", "1800602030", -47, -94, Transition.ColorTint, "", 100, 47 ,false)
    UILayout.SetSameAnchorAndPivot(GetBtn, UILayout.BottomRight)
    local btnTxt = GUI.CreateStatic(GetBtn, "btnTxt", "提取", 0, 0, 150, 45)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(btnTxt, 1)
    GUI.SetIsOutLine(btnTxt, true)
    GUI.RegisterUIEvent(GetBtn, UCE.PointerClick, "DoubleExpUI", "OnGetBtn")

    local FreeBuyBtn = GUI.ButtonCreate(changeBoardBg, "FreeBuyBtn", "1800602030", -259, -20, Transition.ColorTint)
    _gt.BindName(FreeBuyBtn, "FreeBuyBtn")
    UILayout.SetSameAnchorAndPivot(FreeBuyBtn, UILayout.BottomRight)
    local btnTxt = GUI.CreateStatic(FreeBuyBtn, "btnTxt", "每日领取", 0, 0, 150, 45)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(btnTxt, 1)
    GUI.SetIsOutLine(btnTxt, true)
    GUI.RegisterUIEvent(FreeBuyBtn, UCE.PointerClick, "DoubleExpUI", "OnFreeBuyBtn")

    local BuyBtn = GUI.ButtonCreate(changeBoardBg, "BuyBtn", "1800602030", -65, -20, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(BuyBtn, UILayout.BottomRight)
    local btnTxt = GUI.CreateStatic(BuyBtn, "btnTxt", "双倍购买", 0, 0, 150, 45)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(btnTxt, 1)
    GUI.SetIsOutLine(btnTxt, true)
    GUI.RegisterUIEvent(BuyBtn, UCE.PointerClick, "DoubleExpUI", "OnBuyBtn")

    CL.SendNotify(NOTIFY.SubmitForm, "FormDoubleExp", "GetData")
end

function DoubleExpUI.OnShow()
end

function DoubleExpUI.OnFreeBuyBtn()
    CL.SendNotify(NOTIFY.SubmitForm, "FormDoubleExp", "GetPoint")
end

function DoubleExpUI.OnFrozenBtn()
    CL.SendNotify(NOTIFY.SubmitForm, "FormDoubleExp", "Freeze")
end

function DoubleExpUI.OnGetBtn()
    CL.SendNotify(NOTIFY.SubmitForm, "FormDoubleExp", "Draw")
end

function DoubleExpUI.OnBuyBtn()
    CL.SendNotify(NOTIFY.SubmitForm, "FormDoubleExp", "Buy")
end

function DoubleExpUI.RefreshData()
    local FrozenNum = _gt.GetUI("FrozenNum")
    if FrozenNum then
        GUI.StaticSetText(FrozenNum, "已领取："..tostring(DoubleExpUI.DoublePoint))
    end
    local CanGetNum = _gt.GetUI("CanGetNum")
    if CanGetNum then
        GUI.StaticSetText(CanGetNum, "双倍点数："..tostring(DoubleExpUI.FrozenNum))
    end
    local FreeBuyBtn = _gt.GetUI("FreeBuyBtn")
    if FreeBuyBtn then
        GUI.ButtonSetShowDisable(FreeBuyBtn, DoubleExpUI.HaveGotFreePoint == 0)
    end
end

function DoubleExpUI.OnInfoBtn()
    local wnd = GUI.GetWnd("DoubleExpUI")
    local tip = Tips.CreateHint("每场战斗消耗1点双倍点数", wnd, -173, -32, UILayout.Center, nil, nil, true)
    GUI.SetIsRemoveWhenClick(tip, true)
end

function DoubleExpUI.OnExit()
    GUI.DestroyWnd("DoubleExpUI")
end