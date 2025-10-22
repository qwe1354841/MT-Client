ExchangeUI = {}
local test =print
local _gt = UILayout.NewGUIDUtilTable()
ExchangeUI.CurCoinType = 341        --当前货币类型
ExchangeUI.TargetCoinType = 344     --目标货币类型
ExchangeUI.Rate = 100              --兑换比例
ExchangeUI.CoinNum = 0              --默认兑换数量

local MoneyType = {
    [RoleAttr.RoleAttrIngot] = 1,
    [RoleAttr.RoleAttrBindIngot] = 2,
    [RoleAttr.RoleAttrGold] = 4,
    [RoleAttr.RoleAttrBindGold] = 5,
}

function ExchangeUI.Main(parameter)
    test("ExchangeUI lua ")
    _gt = UILayout.NewGUIDUtilTable()

    local panel = GUI.WndCreateWnd("ExchangeUI", "ExchangeUI", 0, 0, eCanvasGroup.Normal)
    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelCover = GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)

    local panelBg = GUI.ImageCreate(panel, "panelBg", "1800001120", 0, 0, false, 460, 330)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)

    --全屏关闭按钮
    local coverBtn = GUI.ButtonCreate(panelBg, "coverBtn", "1800002050", 0, 0, Transition.ColorTint, "", GUI.GetWidth(panelCover), GUI.GetHeight(panelCover), false)
    UILayout.SetSameAnchorAndPivot(coverBtn, UILayout.Center)
    local alpha0 = Color.New(0, 0, 0, 0)
    GUI.SetColor(coverBtn, alpha0)

    local flower = GUI.ImageCreate(panelBg, "flower", "1800007060", -25, -25, false)
    UILayout.SetSameAnchorAndPivot(flower, UILayout.TopLeft)

    local tipsBg = GUI.ImageCreate(panelBg, "tipsBg", "1800001030", 0, 20)
    UILayout.SetSameAnchorAndPivot(tipsBg, UILayout.Top)

    local tipLabel = GUI.CreateStatic(tipsBg, "tipLabel", "消费确认", 0, 2, 300, 30, "system", true)
    GUI.StaticSetFontSize(tipLabel, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(tipLabel, UILayout.Center)
    GUI.SetColor(tipLabel, UIDefine.White3Color)

    --我的元宝
    local myYuanBanLabel = GUI.CreateStatic(panelBg, "myYuanBanLabelLabel", "我的金元宝", -120, -30, 300, 30, "system", true)
    _gt.BindName(myYuanBanLabel,"curCoin")
    GUI.StaticSetFontSize(myYuanBanLabel, UIDefine.FontSizeS)
    UILayout.SetSameAnchorAndPivot(myYuanBanLabel, UILayout.Center)
    GUI.StaticSetAlignment(myYuanBanLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(myYuanBanLabel, UIDefine.BrownColor)
    --元宝兑换
    local exchangeYuanBaoLabel = GUI.CreateStatic(panelBg, "exchangeYuanBaoLabel", "金元宝兑换", -120, 14, 300, 30, "system", true)
    _gt.BindName(exchangeYuanBaoLabel,"curExchangeCoin")
    GUI.StaticSetFontSize(exchangeYuanBaoLabel, UIDefine.FontSizeS)
    UILayout.SetSameAnchorAndPivot(exchangeYuanBaoLabel, UILayout.Center)
    GUI.StaticSetAlignment(exchangeYuanBaoLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(exchangeYuanBaoLabel, UIDefine.BrownColor)
    --获得 金币/银币
    local getTargetCoinLabel = GUI.CreateStatic(panelBg, "getTargetCoinLabel", "获得金元宝", -120, 59, 300, 30, "system", true)
    _gt.BindName(getTargetCoinLabel,"targetCoin")
    GUI.StaticSetFontSize(getTargetCoinLabel, UIDefine.FontSizeS)
    UILayout.SetSameAnchorAndPivot(getTargetCoinLabel, UILayout.Center)
    GUI.StaticSetAlignment(getTargetCoinLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(getTargetCoinLabel, UIDefine.BrownColor)

    local haveBg = GUI.ImageCreate(myYuanBanLabel, "haveBg", "1800900040", 162, -5, false, 220, 36)
    UILayout.SetSameAnchorAndPivot(haveBg, UILayout.Center)

    local coinIcon = GUI.ImageCreate(haveBg, "coinIcon", "1800408250", 4, -2)
    _gt.BindName(coinIcon,"curCoinPic")
    UILayout.SetSameAnchorAndPivot(coinIcon, UILayout.Left)

    local have = GUI.CreateStatic(haveBg, "have", "0", 0, -2, 180, 40, "system", false)
    _gt.BindName(have,"curCoinNum")
    UILayout.SetSameAnchorAndPivot(have, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(have, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

    --输入框
    local exchangeYuanbaoBg = GUI.EditCreate(exchangeYuanBaoLabel, "TransferInputField", "1800001040", "0", 162, -1, Transition.ColorTint, "system", 224, 44, 30, 8, InputType.Standard, ContentType.IntegerNumber)
    _gt.BindName(exchangeYuanbaoBg,"curExchangeCoinNum")
    GUI.EditGetBNumber(exchangeYuanbaoBg)
    GUI.EditSetLabelAlignment(exchangeYuanbaoBg, TextAnchor.MiddleCenter)
    GUI.EditSetFontSize(exchangeYuanbaoBg, UIDefine.FontSizeM)
    GUI.EditSetMaxCharNum(exchangeYuanbaoBg, 8)
    GUI.EditSetTextColor(exchangeYuanbaoBg, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(exchangeYuanbaoBg, UCE.EndEdit, "ExchangeUI", "OnNumCountChange")

    local exchangeIcon = GUI.ImageCreate(exchangeYuanbaoBg, "exchangeIcon", "1800408250", 6, -2)
    _gt.BindName(exchangeIcon,"curExchangeCoinPic")
    UILayout.SetSameAnchorAndPivot(exchangeIcon, UILayout.Left)

    local getTargetCoinBg = GUI.ImageCreate(getTargetCoinLabel, "getTargetCoinBg", "1800900040", 162, 0, false, 220, 36)
    UILayout.SetSameAnchorAndPivot(getTargetCoinBg, UILayout.Center)

    local getIcon = GUI.ImageCreate(getTargetCoinBg, "getIcon", "1800408250", 4, -2)
    _gt.BindName(getIcon,"targetCoinPic")
    UILayout.SetSameAnchorAndPivot(getIcon, UILayout.Left)

    local get = GUI.CreateStatic(getTargetCoinBg, "get", "0", 20, -2, 180, 40, "system", false)
    _gt.BindName(get,"targetCoinNum")
    UILayout.SetSameAnchorAndPivot(get, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(get, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

    --兑换
    local exchangeButton = GUI.ButtonCreate(panelBg, "exchangeButton", "1800002060", 100, -20, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(exchangeButton, UILayout.Bottom)
    local allLabel = GUI.CreateStatic(exchangeButton, "allLabel", "兑换", 0, 0, 200, 30, "system", true)
    GUI.RegisterUIEvent(exchangeButton, UCE.PointerClick, "ExchangeUI", "OnClickExchangeBtn")
    GUI.StaticSetFontSize(allLabel, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(allLabel, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(allLabel, UILayout.Center)

    GUI.SetColor(allLabel, UIDefine.WhiteColor)
    GUI.SetIsOutLine(allLabel, true)
    GUI.SetOutLine_Color(allLabel, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(allLabel, 1)

    --取消
    local cancelButton = GUI.ButtonCreate(panelBg, "cancelButton", "1800002060", -100, -20, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(cancelButton, UILayout.Bottom)
    local cancelLabel = GUI.CreateStatic(cancelButton, "cancelLabel", "取消", 0, 0, 200, 30, "system", true)
    GUI.RegisterUIEvent(cancelButton, UCE.PointerClick, "ExchangeUI", "OnClickCancelBtn")
    GUI.StaticSetFontSize(cancelLabel, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(cancelLabel, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(cancelLabel, UILayout.Center)
    GUI.SetColor(cancelLabel, UIDefine.WhiteColor)
    GUI.SetIsOutLine(cancelLabel, true)
    GUI.SetOutLine_Color(cancelLabel, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(cancelLabel, 1)

    local tipsLabel = GUI.CreateStatic(panelBg, "tipsLabel", "1金砖可以兑换1金元宝", 0, -78, 420, 120, "system", true)
    _gt.BindName(tipsLabel,"tips")
    GUI.StaticSetFontSize(tipsLabel, UIDefine.FontSizeS)
    UILayout.SetSameAnchorAndPivot(tipsLabel, UILayout.Center)
    GUI.StaticSetAlignment(tipsLabel, TextAnchor.MiddleCenter)
    GUI.SetPositionX(tipsLabel, 0)
    GUI.SetColor(tipsLabel, UIDefine.BrownColor)

    --关闭
    local closeBtn = GUI.ButtonCreate(panelBg, "closeSmallBtn", "1800002050", -20, 20, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "ExchangeUI", "OnClickCancelBtn")
end

function ExchangeUI.OnShow(param)
    local vals = {}
    if string.find(param,"index") then
        vals[1], vals[2]= UIDefine.GetParameterStr(param)
        vals[1] = tonumber(vals[1])
        vals[2] = tonumber(vals[2])
    end
    if param ~= nil then
        if #vals == 0 then
            vals = string.split(param, ",")
        end
        if #vals >= 2 then
            ExchangeUI.CoinNum = 0
            --兑换货币，目标货币，比例，默认兑换数量
            ExchangeUI.CurCoinType = CL.ConvertAttr(tonumber(vals[1]))
            ExchangeUI.TargetCoinType = CL.ConvertAttr(tonumber(vals[2]))
            if #vals >= 3 then
                ExchangeUI.CoinNum = tonumber(vals[3])
            end
            --获取倍数比率
            CL.SendNotify(NOTIFY.SubmitForm, "FormMoneyChange", "GetData", MoneyType[ExchangeUI.CurCoinType], MoneyType[ExchangeUI.TargetCoinType])

            --标题
            local ctrl = _gt.GetUI("curCoin")
            if ctrl then
                GUI.StaticSetText(ctrl, "我的"..UIDefine.AttrName[ExchangeUI.CurCoinType])
            end
            ctrl = _gt.GetUI("curExchangeCoin")
            if ctrl then
                GUI.StaticSetText(ctrl, UIDefine.AttrName[ExchangeUI.CurCoinType].."兑换")
            end
            ctrl = _gt.GetUI("targetCoin")
            if ctrl then
                GUI.StaticSetText(ctrl, "获得"..UIDefine.AttrName[ExchangeUI.TargetCoinType])
            end
            --图标
            ctrl = _gt.GetUI("curCoinPic")
            if ctrl then
                GUI.ImageSetImageID(ctrl, UIDefine.AttrIcon[ExchangeUI.CurCoinType])
            end
            ctrl = _gt.GetUI("curExchangeCoinPic")
            if ctrl then
                GUI.ImageSetImageID(ctrl, UIDefine.AttrIcon[ExchangeUI.CurCoinType])
            end
            ctrl = _gt.GetUI("targetCoinPic")
            if ctrl then
                GUI.ImageSetImageID(ctrl, UIDefine.AttrIcon[ExchangeUI.TargetCoinType])
            end
            --数量
            ctrl = _gt.GetUI("curCoinNum")
            if ctrl then
                GUI.StaticSetText(ctrl, tostring(CL.GetAttr(ExchangeUI.CurCoinType)))
            end
            ctrl = _gt.GetUI("curExchangeCoinNum")
            if ctrl then
                GUI.EditSetTextM(ctrl, "")
                --tonumber(ExchangeUI.CoinNum)
            end
        end
    end
end

function ExchangeUI.Refresh()
    local ctrl = _gt.GetUI("targetCoinNum")
    if ctrl then
        GUI.StaticSetText(ctrl, tostring(ExchangeUI.CoinNum * ExchangeUI.Rate))
    end
    --兑换提示
    ctrl = _gt.GetUI("tips")
    if ctrl then
        GUI.StaticSetText(ctrl, "1"..UIDefine.AttrName[ExchangeUI.CurCoinType].."可以兑换"..ExchangeUI.Rate..UIDefine.AttrName[ExchangeUI.TargetCoinType])
    end
end

function ExchangeUI.OnNumCountChange()
    local curExchangeCoinNum = _gt.GetUI("curExchangeCoinNum")
    local CoinNum = math.ceil(tonumber(GUI.EditGetTextM(curExchangeCoinNum)))
    GUI.EditSetTextM(curExchangeCoinNum,CoinNum)
    local targetCoinNum = _gt.GetUI("targetCoinNum")
    if curExchangeCoinNum and targetCoinNum then
        ExchangeUI.CoinNum = CoinNum
        GUI.StaticSetText(targetCoinNum, tostring(ExchangeUI.CoinNum * ExchangeUI.Rate))
    end
end

function ExchangeUI.OnClickCancelBtn()
    GUI.DestroyWnd("ExchangeUI")
end

function ExchangeUI.OnClickExchangeBtn()
    local curExchangeCoinNumVal = 0
    local curExchangeCoinNum = _gt.GetUI("curExchangeCoinNum")
    if curExchangeCoinNum then
        curExchangeCoinNumVal = tonumber(GUI.EditGetTextM(curExchangeCoinNum))
    end
    if curExchangeCoinNumVal == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请输入需要兑换的数量")
        return
    end
    --执行兑换
    CL.SendNotify(NOTIFY.SubmitForm, "FormMoneyChange", "ExchangeMoney", curExchangeCoinNumVal, MoneyType[ExchangeUI.CurCoinType], MoneyType[ExchangeUI.TargetCoinType])
end