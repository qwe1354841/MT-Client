FactionPrizeUI = {}

local tabList = {
    { "赏功", "prizeTabBtn", "OnPrizeBtnClick"},
}

local JOB_SHOW_NAME = {
    "普通帮众",
    "飞龙堂成员",
    "卧虎堂成员",
    "飞龙堂堂主",
    "卧虎堂堂主",
    "左护法",
    "右护法",
    "副帮主",
    "帮主",
}

local _gt = UILayout.NewGUIDUtilTable()
local cntPerLine = 6

function FactionPrizeUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("FactionPrizeUI", "FactionPrizeUI", 0, 0)

    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "赏功堂", "FactionPrizeUI", "OnExit", _gt)

    --UILayout.CreateRightTab(tabList, "FactionPrizeUI")

    FactionPrizeUI.ShowPrizeWnd(panelBg)
end

function FactionPrizeUI.ShowPrizeWnd(panelBg)
    local title = GUI.ImageCreate(panelBg, "title", "1800400420", 260, -256)
    local text = GUI.CreateStatic(title, "text", "我的包裹", 0, 0, 150, 35)
    GUI.StaticSetFontSize(text, UIDefine.FontSizeM)
    GUI.SetColor(text, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)

    local rightBg = GUI.ImageCreate(panelBg, "rightBg", "1800400010", 265, 0, false, 515, 480)
    local itemScroll = GUI.LoopScrollRectCreate(panelBg, "itemScroll", 265, 0, 490, 450,
            "FactionPrizeUI", "CreateItemIconPool", "FactionPrizeUI", "RefreshItemScroll", 0, false, Vector2.New(80, 80), cntPerLine, UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(1, 1))
    _gt.BindName(itemScroll, "itemScroll")

    local title = GUI.ImageCreate(panelBg, "title", "1800400420", -260, -256)
    local text = GUI.CreateStatic(title, "text", "赏功奖池", 0, 0, 150, 35)
    GUI.StaticSetFontSize(text, UIDefine.FontSizeM)
    GUI.SetColor(text, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)

    local prizeRecordBtn = GUI.ButtonCreate(panelBg, "prizeRecordBtn", "1800402110", 460, -256, Transition.SpriteSwap, "", 120, 40, false)
    _gt.BindName(prizeRecordBtn, "prizeRecordBtn")
    UILayout.SetSameAnchorAndPivot(prizeRecordBtn, UILayout.Center)
    local btnTxt = GUI.CreateStatic(prizeRecordBtn, "btnTxt", "赏功记录", 0, 0, 150, 35)
    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeS, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    GUI.RegisterUIEvent(prizeRecordBtn, UCE.PointerClick, "FactionPrizeUI", "OnRecordBtnClick")

    local leftBg = GUI.ImageCreate(panelBg, "leftBg", "1800400010", -265, 0, false, 515, 480)
    local prizeScroll = GUI.LoopScrollRectCreate(panelBg, "prizeScroll", -265, 0, 490, 450,
            "FactionPrizeUI", "CreatePrizeItemPool", "FactionPrizeUI", "RefreshPrizeItemScroll", 0, false, Vector2.New(80, 80), cntPerLine, UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(prizeScroll, Vector2.New(1, 1))
    _gt.BindName(prizeScroll, "prizeScroll")

    local prizeBtn = GUI.ButtonCreate(panelBg, "prizeBtn", "1800402090", 0, 268, Transition.ColorTint, "抽奖!", 110, 47, false)
    GUI.SetIsOutLine(prizeBtn, true)
    GUI.ButtonSetTextFontSize(prizeBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(prizeBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(prizeBtn,UIDefine.OutLine_GreenColor)
    GUI.SetOutLine_Distance(prizeBtn, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(prizeBtn, UCE.PointerClick, "FactionPrizeUI", "OnFactionPrizeMoveNumConfirmClick")--"OnPrizeBtnClick")
    _gt.BindName(prizeBtn, "prizeBtn")

    local setBtn = GUI.ButtonCreate(panelBg, "setBtn", "1800202240", 502, 268, Transition.ColorTint, "", 24,24, false)
    GUI.SetColor(setBtn, Color.New(245 / 255, 217 / 255, 159 / 255, 1))
    GUI.SetIsOutLine(setBtn, true)
    GUI.ButtonSetTextFontSize(setBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(setBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(setBtn,UIDefine.OutLine_GreenColor)
    GUI.SetOutLine_Distance(setBtn, UIDefine.OutLineDistance)
    GUI.SetData(setBtn, "index", "1")
    GUI.RegisterUIEvent(setBtn, UCE.PointerClick, "FactionPrizeUI", "OnFactionPrizeCostSetClick")

    local capacityText = GUI.CreateStatic(panelBg, "capacityText", "剩余次数:0/0", 353, -60, 200, 35)
    GUI.SetColor(capacityText, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(capacityText, UIDefine.FontSizeM)
    UILayout.SetAnchorAndPivot(capacityText, UIAnchor.Bottom, UIAroundPivot.Left)
    _gt.BindName(capacityText, "capacityText")

    local costTip = GUI.CreateStatic(panelBg, "costTip", "消耗", 77, -43, 97, 30)
    _gt.BindName(costTip, "costTip")
    UILayout.SetSameAnchorAndPivot(costTip, UILayout.BottomLeft)
    UILayout.StaticSetFontSizeColorAlignment(costTip, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
    local bg = GUI.ImageCreate(costTip, "bg", "1800700010", 56, 0, false, 168, 34)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Left)
    local icon = GUI.ImageCreate(bg, "icon", "1801208040", 0, -1, false, 34, 34)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Left)
    local txt = GUI.CreateStatic(bg, "txt", "10000", 0, 0, 250, 30)
    _gt.BindName(txt, "costTxt")
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    local infoBtn = GUI.ButtonCreate(bg, "infoBtn", "1800702030", 178, 0, Transition.ColorTint, "", 30, 30, false)
    GUI.RegisterUIEvent(infoBtn, UCE.PointerClick, "FactionPrizeUI", "OnFactionPrizeCostInfoClick")

    local setBtn = GUI.ButtonCreate(bg, "setBtn", "1800202240", 216, 0, Transition.ColorTint, "", 24,24, false)
    GUI.SetColor(setBtn, Color.New(245 / 255, 217 / 255, 159 / 255, 1))
    GUI.SetIsOutLine(setBtn, true)
    GUI.ButtonSetTextFontSize(setBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(setBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(setBtn,UIDefine.OutLine_GreenColor)
    GUI.SetOutLine_Distance(setBtn, UIDefine.OutLineDistance)
    GUI.SetData(setBtn, "index", "2")
    GUI.RegisterUIEvent(setBtn, UCE.PointerClick, "FactionPrizeUI", "OnFactionPrizeCostSetClick")
end

function FactionPrizeUI.OnFactionPrizeCostInfoClick(guid)
    local factionInfoBg = _gt.GetUI("costTip")
    local tip = Tips.CreateHint("当前拥有战功："..UIDefine.ExchangeMoneyToStr(tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrGuildFightScore)))), factionInfoBg, 192, 55, UILayout.Center, nil, nil, true)
    GUI.SetIsRemoveWhenClick(tip, true)
end

function FactionPrizeUI.OnFactionPrizeCostSetClick(guid)
    local btn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(btn, "index"))
    local setBoardCover = _gt.GetUI("setBoardCover")
    if setBoardCover == nil then
        local panel = GUI.GetWnd("FactionPrizeUI")
        setBoardCover = GUI.ImageCreate(panel, "setBoardCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        _gt.BindName(setBoardCover, "setBoardCover")
        UILayout.SetSameAnchorAndPivot(setBoardCover, UILayout.Center)
        GUI.SetIsRaycastTarget(setBoardCover, true)

        local changeBoardBg = GUI.ImageCreate(setBoardCover, "changeBoardBg", "1800001120", 0, 0, false, 465, 275)
        UILayout.SetSameAnchorAndPivot(changeBoardBg, UILayout.Center)

        local closeBtn = GUI.ButtonCreate(changeBoardBg, "closeBtn", "1800002050", -11, 11, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionPrizeUI", "OnCloseBtnClick_CostSetPanel")

        local titleBg = GUI.ImageCreate(changeBoardBg, "titleBg", "1800001030", 0, 15, false, 265, 38)
        UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)
        local txt = GUI.CreateStatic(titleBg, "txt", "", 0, 0, 180, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        GUI.StaticSetText(txt, "抽奖次数设置")
        _gt.BindName(txt,"litWndTitleTxt")

        GUI.ImageCreate(changeBoardBg, "flower", "1800007060", -194, -125)
        GUI.ImageCreate(changeBoardBg, "bg", "1800400010", 0, -8, false, 414, 132)
        local inputField = GUI.EditCreate(changeBoardBg, "inputField0", "1800400390", "请输入要设置的抽奖次数(1-5)", 41, 106, Transition.ColorTint, "system", 382, 53, 10, 10)
        _gt.BindName(inputField, "litWndInputField0")
        UILayout.SetSameAnchorAndPivot(inputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(inputField, TextAnchor.MiddleCenter)
        GUI.EditSetFontSize(inputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(inputField, UIDefine.BrownColor)
        GUI.SetPlaceholderTxtColor(inputField, UIDefine.GrayColor)
        GUI.EditSetMaxCharNum(inputField, 1)
        GUI.RegisterUIEvent(inputField, UCE.EndEdit, "FactionPrizeUI", "OnTimesSetEdit")

        local inputField = GUI.EditCreate(changeBoardBg, "inputField1", "1800400390", "请输入单次抽奖所需战功", 41, 106, Transition.ColorTint, "system", 382, 53, 10, 10)
        _gt.BindName(inputField, "litWndInputField1")
        UILayout.SetSameAnchorAndPivot(inputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(inputField, TextAnchor.MiddleCenter)
        GUI.EditSetFontSize(inputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(inputField, UIDefine.BrownColor)
        GUI.SetPlaceholderTxtColor(inputField, UIDefine.GrayColor)
        GUI.EditSetMaxCharNum(inputField, 10)

        local concelBtn = GUI.ButtonCreate(changeBoardBg, "concelBtn", "1800602030", 25, -20, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(concelBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(concelBtn, "btnTxt", "关闭", 0, 0, 52, 32)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "FactionPrizeUI", "OnCloseBtnClick_ChangeBoardBg")

        local confirmBtn = GUI.ButtonCreate(changeBoardBg, "confirmBtn", "1800602030", -25, -20, Transition.ColorTint)
        _gt.BindName(confirmBtn, "confirmBtn")
        UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(confirmBtn, "btnTxt", "确定", 0, 0, 52, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "FactionPrizeUI", "OnConfirmBtnClick_CostSet")
    else
        GUI.SetVisible(setBoardCover, true)
    end

    local title = _gt.GetUI("litWndTitleTxt")
    if title then
        GUI.StaticSetText(title, index==1 and "抽奖次数设置" or "抽奖战功设置")
    end

    local litWndInputField0 = _gt.GetUI("litWndInputField0")
    if litWndInputField0 then
        GUI.SetVisible(litWndInputField0, index==1)
    end

    local litWndInputField1 = _gt.GetUI("litWndInputField1")
    if litWndInputField1 then
        GUI.SetVisible(litWndInputField1, index==2)
    end

    local confirmBtn = _gt.GetUI("confirmBtn")
    if confirmBtn then
        GUI.SetData(confirmBtn, "index", tostring(index))
    end
end

function FactionPrizeUI.OnTimesSetEdit()
    local litWndInputField0 = _gt.GetUI("litWndInputField0")
    if litWndInputField0 then
        local num = tonumber(GUI.EditGetTextM(litWndInputField0))
        num = num or 1
        num = math.max(1, num)
        num = math.min(5, num)
        GUI.EditSetTextM(litWndInputField0, tostring(num))
    end
end

function FactionPrizeUI.OnItemNumSetEdit()
    FactionPrizeUI.OnChangeNumConfirm(0)
end

--当移入道具时候，堆叠的话需要确认数量
function FactionPrizeUI.OnFactionPrizeMoveNumConfirmClick(guid)
    local numConfirmCover = _gt.GetUI("numConfirmCover")
    if numConfirmCover == nil then
        local panel = GUI.GetWnd("FactionPrizeUI")
        numConfirmCover = GUI.ImageCreate(panel, "numConfirmCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        _gt.BindName(numConfirmCover, "numConfirmCover")
        UILayout.SetSameAnchorAndPivot(numConfirmCover, UILayout.Center)
        GUI.SetIsRaycastTarget(numConfirmCover, true)

        local changeBoardBg = GUI.ImageCreate(numConfirmCover, "changeBoardBg", "1800001120", 0, 0, false, 465, 275)
        UILayout.SetSameAnchorAndPivot(changeBoardBg, UILayout.Center)

        local closeBtn = GUI.ButtonCreate(changeBoardBg, "closeBtn", "1800002050", -11, 11, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionPrizeUI", "OnCloseBtnClick_NumConfirmCover")

        local titleBg = GUI.ImageCreate(changeBoardBg, "titleBg", "1800001030", 0, 15, false, 265, 38)
        UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)
        local txt = GUI.CreateStatic(titleBg, "txt", "", 0, 0, 180, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        GUI.StaticSetText(txt, "奖池管理")
        _gt.BindName(txt,"litWndTitleTxt")

        GUI.ImageCreate(changeBoardBg, "flower", "1800007060", -194, -125)
        GUI.ImageCreate(changeBoardBg, "bg", "1800400010", 0, -8, false, 414, 132)
        local inputField = GUI.EditCreate(changeBoardBg, "inputField0", "1800400390", "1", 180, 121, Transition.ColorTint, "system", 106, 53, 10, 10)
        _gt.BindName(inputField, "numInputField")
        UILayout.SetSameAnchorAndPivot(inputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(inputField, TextAnchor.MiddleCenter)
        GUI.EditSetFontSize(inputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(inputField, UIDefine.BrownColor)
        GUI.SetPlaceholderTxtColor(inputField, UIDefine.BlackColor)
        GUI.EditSetMaxCharNum(inputField, 5)
        GUI.RegisterUIEvent(inputField, UCE.EndEdit, "FactionPrizeUI", "OnItemNumSetEdit")

        local minusBtn = GUI.ButtonCreate(inputField,"MinusBtn", "1800402140", -72,2, Transition.ColorTint, "")
        _gt.BindName(minusBtn, "MinusBtn")
        GUI.ButtonSetShowDisable(minusBtn, false)
        GUI.RegisterUIEvent(minusBtn, UCE.PointerClick, "FactionPrizeUI", "OnMinusBtn")
        local plusBtn = GUI.ButtonCreate(inputField,"PlusBtn", "1800402150", 128, 2, Transition.ColorTint, "")
        _gt.BindName(plusBtn, "PlusBtn")
        GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "FactionPrizeUI", "OnPlusBtn")

        local inputNameTips = GUI.CreateStatic(changeBoardBg, "inputNameTips", "", 25, 75, 400, 32)
        UILayout.SetSameAnchorAndPivot(inputNameTips, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(inputNameTips, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
        GUI.StaticSetText(inputNameTips, "请选择要放入奖池的道具数量")

        local concelBtn = GUI.ButtonCreate(changeBoardBg, "concelBtn", "1800602030", 25, -20, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(concelBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(concelBtn, "btnTxt", "关闭", 0, 0, 52, 32)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "FactionPrizeUI", "OnCloseBtnClick_NumConfirmCover")

        local confirmBtn = GUI.ButtonCreate(changeBoardBg, "confirmBtn", "1800602030", -25, -20, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(confirmBtn, "btnTxt", "确定", 0, 0, 52, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "FactionPrizeUI", "OnConfirmBtnClick_NumConfirmCover")
    else
        GUI.SetVisible(numConfirmCover, true)
    end
end

function FactionPrizeUI.CreateSmallMenuBgFree(name, panel, title, w, h)
    local panelCover = GUI.ImageCreate(panel, name, "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)

    local panelBg = GUI.ImageCreate(panelCover, "panelBg", "1800600182", 0, 0, false, w, h)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)
    --panelBg:RegisterEvent(UCE.PointerClick)

    local topBarLeft = GUI.ImageCreate(panelBg, "topBarLeft", "1800600180", w / 4, 21, false, w / 2 + 1, 54)
    UILayout.SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

    local topBarRight = GUI.ImageCreate(panelBg, "topBarRight", "1800600181", -w / 4, 21, false, w / 2 + 1, 54)
    UILayout.SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

    local topBarCenter = GUI.ImageCreate(panelBg, "topBarCenter", "1800600190", 0, 23, false, 267, 50)
    UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

    local tipLabel = GUI.CreateStatic(panelBg, "tipLabel", title, 0, 23, 150, 45)
    UILayout.StaticSetFontSizeColorAlignment(tipLabel, UIDefine.FontSizeXL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)

    return panelCover
end

function FactionPrizeUI.OnRecordBtnClick(guid)
    local recordPanel = _gt.GetUI("recordPanel")
    if recordPanel == nil then
        local panel = GUI.GetWnd("FactionPrizeUI")
        recordPanel = FactionPrizeUI.CreateSmallMenuBgFree("recordPanel", panel, "赏功记录", 725, 620)
        _gt.BindName(recordPanel, "recordPanel")

        local bg = GUI.ImageCreate(recordPanel, "bg", "1800600040", 300, 100, false, 680, 500)
        UILayout.SetSameAnchorAndPivot(bg, UILayout.TopLeft)

        local recordScroll = GUI.LoopScrollRectCreate(recordPanel, "recordScroll", -63, -11, 790, 496,
                "FactionPrizeUI", "CreateRecordPool", "FactionPrizeUI", "RefreshRecordScroll", 0, false, Vector2.New(680, 22), 1, UIAroundPivot.Top, UIAnchor.Top)
        GUI.ScrollRectSetChildSpacing(recordScroll, Vector2.New(0, 22))
        _gt.BindName(recordScroll, "recordScroll")

        local closeRecordBtn = GUI.ButtonCreate(recordPanel, "closeRecordBtn", "1800602020", 0, 270, Transition.ColorTint)
        _gt.BindName(closeRecordBtn, "prizeRecordBtn")
        UILayout.SetSameAnchorAndPivot(closeRecordBtn, UILayout.Center)
        local btnTxt = GUI.CreateStatic(closeRecordBtn, "btnTxt", "关闭日志", 0, 0, 150, 35)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.Brown3Color, TextAnchor.MiddleCenter)
        GUI.RegisterUIEvent(closeRecordBtn, UCE.PointerClick, "FactionPrizeUI", "OnCloseBtnClick_RecordPanel")
    else
        GUI.SetVisible(recordPanel, true)
    end

    local recordScroll = _gt.GetUI("recordScroll")
    if recordScroll then
        GUI.LoopScrollRectSetTotalCount(recordScroll, 20)
        GUI.LoopScrollRectRefreshCells(recordScroll)
    end
end

function FactionPrizeUI.OnCloseBtnClick_RecordPanel()
    local recordPanel = _gt.GetUI("recordPanel")
    if recordPanel ~= nil then
        GUI.SetVisible(recordPanel, false)
    end
end

function FactionPrizeUI.OnCloseBtnClick_CostSetPanel()
    local setBoardCover = _gt.GetUI("setBoardCover")
    if setBoardCover ~= nil then
        GUI.SetVisible(setBoardCover, false)
    end
end

--打开界面的时候调用
function FactionPrizeUI.OnShow(parameter)
    local wnd = GUI.GetWnd("FactionPrizeUI")
    if wnd == nil then
      return
    end

    FactionPrizeUI.Register()

    --TEST
    local capacity = LD.GetBagCapacity(FactionPrizeUI.GetCurBagType())
    local count = math.floor(capacity / cntPerLine) * cntPerLine + cntPerLine
    if count > LogicDefine.BagMaxLimit then
        count = LogicDefine.BagMaxLimit
    end

    local itemScroll = _gt.GetUI("itemScroll")
    if itemScroll then
        GUI.LoopScrollRectSetTotalCount(itemScroll, count)
        GUI.LoopScrollRectRefreshCells(itemScroll)
    end

    local prizeScroll = _gt.GetUI("prizeScroll")
    if prizeScroll then
        GUI.LoopScrollRectSetTotalCount(prizeScroll, count)
        GUI.LoopScrollRectRefreshCells(prizeScroll)
    end
end

--创建包裹道具列表
function FactionPrizeUI.CreateRecordPool()
    local recordScroll = _gt.GetUI("recordScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(recordScroll)

    local item = GUI.ImageCreate(recordScroll, "item"..curCount, "1800499999", 10, 0)
    local point = GUI.ImageCreate(item, "point", "1800408520", -235, 4)
    local record = GUI.CreateStatic(item, "record", "<color=white>[2020-01-01]</color> 帮主 <color=green>大浮动</color> 抽奖，获得道具 <color=purple>[无邪之剑]</color> ", 130, 4, 610, 35, "system", true)
    UILayout.SetSameAnchorAndPivot(record, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(record, UIDefine.FontSizeS, UIDefine.Brown3Color, TextAnchor.Left)
    return item
end

--刷新包裹道具列表
function FactionPrizeUI.RefreshRecordScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])

    local item = GUI.GetByGuid(guid)
    local oneLine = {time="2020-02-12", jobType=Mathf.Random(1,9), name="山东省", awardType=Mathf.Random(1,2), awardID=50000+Mathf.Random(1,52)}
    local record = GUI.GetChild(item, "record")
    local awardTypeName = ""
    local awardItemName = ""
    local awardColor = ""
    if oneLine.awardType == 1 then
        awardTypeName = "道具"
        awardColor = "purple"
        local config = DB.GetOnceItemByKey1(oneLine.awardID)
        if config then
            awardItemName = config.Name
        end
    elseif oneLine.awardType == 2 then
        awardTypeName = "宠物"
        awardColor = "yellow"
        local config = DB.GetOncePetByKey1(oneLine.awardID)
        if config then
            awardItemName = config.Name
        end
    end
    GUI.StaticSetText(record, "<color=white>["..oneLine.time.."]</color> "..JOB_SHOW_NAME[oneLine.jobType].."  <color=green>"..oneLine.name.."</color> 抽奖，获得"..awardTypeName.." <color="..awardColor..">["..awardItemName.."]</color>")
end

function FactionPrizeUI.OnPlusBtn()
    FactionPrizeUI.OnChangeNumConfirm(1)
end

function FactionPrizeUI.OnMinusBtn()
    FactionPrizeUI.OnChangeNumConfirm(-1)
end

function FactionPrizeUI.OnChangeNumConfirm(num)
    local numInputField = _gt.GetUI("numInputField")
    if numInputField then
        local numNow = tonumber(GUI.EditGetTextM(numInputField))
        numNow = numNow or 1
        local retNum = math.max(1,numNow+num)
        retNum = math.min(10,retNum)
        GUI.EditSetTextM(numInputField, tostring(retNum))

        local PlusBtn = _gt.GetUI("PlusBtn")
        if PlusBtn then
            GUI.ButtonSetShowDisable(PlusBtn, retNum<10)
        end
        local MinusBtn = _gt.GetUI("MinusBtn")
        if MinusBtn then
            GUI.ButtonSetShowDisable(MinusBtn, retNum>1)
        end
    end
end

function FactionPrizeUI.OnConfirmBtnClick_CostSet()

    FactionPrizeUI.OnCloseBtnClick_ChangeBoardBg()
end

function FactionPrizeUI.OnConfirmBtnClick_NumConfirmCover()

    FactionPrizeUI.OnCloseBtnClick_NumConfirmCover()
end

function FactionPrizeUI.OnCloseBtnClick_NumConfirmCover()
    local numConfirmCover = _gt.GetUI("numConfirmCover")
    if numConfirmCover then
        GUI.SetVisible(numConfirmCover, false)
    end
end

function FactionPrizeUI.OnCloseBtnClick_ChangeBoardBg()
    local setBoardCover = _gt.GetUI("setBoardCover")
    if setBoardCover then
        GUI.SetVisible(setBoardCover, false)
    end
    local litWndInputField0 = _gt.GetUI("litWndInputField0")
    if litWndInputField0 then
        GUI.EditSetTextM(litWndInputField0, "")
    end
    local litWndInputField1 = _gt.GetUI("litWndInputField1")
    if litWndInputField1 then
        GUI.EditSetTextM(litWndInputField1, "")
    end
end

--创建包裹道具列表
function FactionPrizeUI.CreateItemIconPool()
    local itemScroll = _gt.GetUI("itemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll)
    local itemicon = ItemIcon.Create(itemScroll, "itemIcon"..curCount, 0, 0)
    GUI.RegisterUIEvent(itemicon, UCE.PointerClick, "FactionPrizeUI", "OnItemClick")
    return itemicon
end

--刷新包裹道具列表
function FactionPrizeUI.RefreshItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local itemIcon = GUI.GetByGuid(guid)

    local curBagType = FactionPrizeUI.GetCurBagType()
    ItemIcon.BindIndexForBag(itemIcon, index, curBagType)
end

--创建包裹道具列表
function FactionPrizeUI.CreatePrizeItemPool()
    local prizeScroll = _gt.GetUI("prizeScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(prizeScroll)
    local itemicon = ItemIcon.Create(prizeScroll, "prizeItem"..curCount, 0, 0)
    GUI.RegisterUIEvent(itemicon, UCE.PointerClick, "FactionPrizeUI", "OnPrizeItemClick")
    return itemicon
end

--刷新包裹道具列表
function FactionPrizeUI.RefreshPrizeItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])

    local itemIcon = GUI.GetByGuid(guid)
    ItemIcon.SetEmpty(itemIcon)
end

function FactionPrizeUI.GetCurBagType()
    return item_container_type.item_container_bag
end

--退出界面
function FactionPrizeUI.OnExit()
    GUI.DestroyWnd("FactionPrizeUI")
end

function FactionPrizeUI.Register()
    CL.RegisterMessage(GM.RefreshBag, "FactionPrizeUI", "OnRefreshBag")
end

function FactionPrizeUI.UnRegister()
    CL.UnRegisterMessage(GM.RefreshBag, "FactionPrizeUI", "OnRefreshBag")
end

--刷新界面
function FactionPrizeUI.OnRefreshBag()
    for i = 1, #tabList do
      local page = _gt.GetUI("tabPage"..i)
      GUI.SetVisible(page, i == FactionPrizeUI.tabIndex)
    end

    UILayout.OnTabClick(FactionPrizeUI.tabIndex, tabList)

    FactionPrizeUI.RefreshBag()
end

function FactionPrizeUI.CancelSelectedItem()
    if FactionPrizeUI.selectedGuid ~= nil then
        GUI.ItemCtrlUnSelect(GUI.GetByGuid(FactionPrizeUI.selectedGuid))
        FactionPrizeUI.selectedGuid = nil
    end
end

function FactionPrizeUI.OnItemClick(guid)
    local itemIcon = GUI.GetByGuid(guid)
    local index = GUI.ItemCtrlGetIndex(itemIcon)
    local curBagType = FactionPrizeUI.GetCurBagType()
    local capacity = LD.GetBagCapacity(curBagType)
    if index >= capacity then
        --解锁
    else
        local itemData = LD.GetItemDataByIndex(index, curBagType)
        if itemData ~= nil then
            local itemDB = DB.GetOnceItemByKey1(itemData.id)
            if itemDB.Id == 0 then
                return 
            end

            if FactionPrizeUI.selectedGuid == guid then
                local itemTips = _gt.GetUI("itemTips")
                GUI.Destroy(itemTips)
                FactionPrizeUI.CancelSelectedItem()
                return
            end

            FactionPrizeUI.CancelSelectedItem()
            FactionPrizeUI.selectedGuid = guid
            FactionPrizeUI.selectedIndex = index
            GUI.ItemCtrlSelect(itemIcon)

            local panelBg = GUI.GetByGuid(_gt.panelBg)
            local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", -200, 0, 55)
            GUI.AddWhiteName(itemTips,guid)
            _gt.BindName(itemTips,"itemTips")

            local moveBtn = GUI.ButtonCreate(itemTips, "moveBtn", "1800402110", 0, -10, Transition.ColorTint, "", 168, 50, false)
            GUI.SetData(moveBtn, "index", tostring(index))
            UILayout.SetSameAnchorAndPivot(moveBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(moveBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(moveBtn, UIDefine.FontSizeL)
            GUI.ButtonSetText(moveBtn, "移入赏功堂")
            GUI.RegisterUIEvent(moveBtn, UCE.PointerClick, "FactionPrizeUI", "OnMoveToPrizePoolBtnClick")
        end
    end
end

function FactionPrizeUI.OnMoveToPrizePoolBtnClick()
    print("------------------------- index : "..FactionPrizeUI.selectedIndex)
end

function FactionPrizeUI.OnPrizeItemClick(guid)
    local itemIcon = GUI.GetByGuid(guid)
    local index = GUI.ItemCtrlGetIndex(itemIcon)
    local curBagType = FactionPrizeUI.GetCurBagType()
    local capacity = LD.GetBagCapacity(curBagType)
    if index >= capacity then
        --解锁
    else
        local itemData = LD.GetItemDataByIndex(index, curBagType)
        if itemData ~= nil then
            local itemDB = DB.GetOnceItemByKey1(itemData.id)
            if itemDB.Id == 0 then
                return
            end

            if FactionPrizeUI.selectedGuid == guid then
                local itemTips = _gt.GetUI("itemTips")
                GUI.Destroy(itemTips)
                FactionPrizeUI.CancelSelectedItem()
                return
            end

            FactionPrizeUI.CancelSelectedItem()
            FactionPrizeUI.selectedGuid = guid
            FactionPrizeUI.selectedIndex = index
            GUI.ItemCtrlSelect(itemIcon)

            local panelBg = GUI.GetByGuid(_gt.panelBg)
            local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", -200, 0, 55)
            GUI.AddWhiteName(itemTips,guid)
            _gt.BindName(itemTips,"itemTips")

            local moveBtn = GUI.ButtonCreate(itemTips, "moveBtn", "1800402110", 0, -10, Transition.ColorTint, "", 168, 50, false)
            UILayout.SetSameAnchorAndPivot(moveBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(moveBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(moveBtn, UIDefine.FontSizeL)
            GUI.ButtonSetText(moveBtn, "移入包裹")
            GUI.RegisterUIEvent(moveBtn, UCE.PointerClick, "FactionPrizeUI", "OnMoveToBagBtnClick")
        end
    end
end