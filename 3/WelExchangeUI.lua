local WelExchangeUI = {}
_G.WelExchangeUI = WelExchangeUI

local guidt = UILayout.NewGUIDUtilTable()
function WelExchangeUI.CreateSubPage(subBg)
    guidt = UILayout.NewGUIDUtilTable()
    local exchangeAwardBg = GUI.ImageCreate(subBg, "exchangeAwardBg", "1800608630", 100, 10, false, 830, 560)
    UILayout.SetSameAnchorAndPivot(exchangeAwardBg, UILayout.Center)

    local paint = GUI.ImageCreate(exchangeAwardBg, "paint", "1800608670", 10, -15)
    UILayout.SetSameAnchorAndPivot(paint, UILayout.BottomLeft)

    local image1 = GUI.ImageCreate(exchangeAwardBg, "image1", "1800608190", 170, -80)
    UILayout.SetSameAnchorAndPivot(image1, UILayout.Center)

    local text1 = GUI.CreateStatic(image1, "text1", "输入兑换码，兑换专属奖励！", 0, 0, 375, 35)
    GUI.SetColor(text1, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(text1, UILayout.Center)

    local codeInput =
        GUI.EditCreate(
        exchangeAwardBg,
        "codeInput",
        "1800001040",
        "请输入兑换码",
        170,
        0,
        Transition.ColorTint,
        "system",
        330,
        45,
        20,
        8,
        InputType.Standard
    )
    UILayout.SetSameAnchorAndPivot(codeInput, UILayout.Center)
    GUI.EditSetLabelAlignment(codeInput, TextAnchor.MiddleCenter)
    GUI.EditSetTextColor(codeInput, UIDefine.BrownColor)
    GUI.EditSetFontSize(codeInput, UIDefine.FontSizeM)
    GUI.SetPlaceholderTxtColor(codeInput, UIDefine.GrayColor)
    UILayout.SetSameAnchorAndPivot(codeInput, UILayout.Center)
    guidt.BindName(codeInput, "codeInput")

    local exchangeBtn =
        GUI.ButtonCreate(
        exchangeAwardBg,
        "exchangeBtn",
        "1800002110",
        170,
        70,
        Transition.ColorTint,
        "兑换",
        120,
        45,
        false
    )
    GUI.SetIsOutLine(exchangeBtn, true)
    GUI.ButtonSetTextFontSize(exchangeBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(exchangeBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(exchangeBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(exchangeBtn, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(exchangeBtn, UCE.PointerClick, "WelExchangeUI", "OnExchangeBtnClick")
    UILayout.SetSameAnchorAndPivot(exchangeBtn, UILayout.Center)
end
-- function WelExchangeUI.OnClose(WelfareUIGuidt)
--     local wnd = GUI.GetWnd("WelfareUI")
--     if wnd == nil then
--         return
--     end
--     GUI.SetVisible(WelfareUIGuidt.GetUI("rewardBg"), true)
-- end
function WelExchangeUI.OnShow(WelfareUIGuidt)
    local wnd = GUI.GetWnd("WelfareUI")
    if wnd == nil then
        return
    end
    local codeInput = guidt.GetUI("codeInput")
    GUI.EditSetTextM(codeInput, "")
    GUI.SetVisible(WelfareUIGuidt.GetUI("rewardBg"), false)
end

function WelExchangeUI.OnExchangeBtnClick()
    local codeInput = guidt.GetUI("codeInput")
    local content = GUI.EditGetTextM(codeInput)
    if content ~= "" then
        print("codeInput:" .. content)
        CL.SendNotify(NOTIFY.SubmitForm, "FormBonusExchange", "Main", content)
        GUI.EditSetTextM(codeInput, "")
    end
end
