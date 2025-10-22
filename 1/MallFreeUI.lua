--商城免单获奖感言UI
MallFreeUI = {}

_G.MallFreeUI = MallFreeUI
local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot

-- 颜色
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorYellow = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorRed = Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255)
local colorGreen = Color.New(46 / 255, 218 / 255, 0 / 255, 255 / 255)
local colorOutline = Color.New(162 / 255, 75 / 255, 21 / 255)
local tipColor = Color.New(208 / 255, 140 / 255, 15 / 255, 255 / 255)
local contentColor = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorType_Input = Color.New(135 / 255, 135 / 255, 135 / 255)
------------------------------------ end缓存一下全局变量end --------------------------------

function MallFreeUI.OnShow(parameter)
end

--@@rs MallFreeUI
--创建基础界面
function MallFreeUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()

	local panel = GUI.WndCreateWnd("MallFreeUI", "MallFreeUI", 0, 0, eCanvasGroup.Normal)
	UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)
	MallFreeUI.Panel = panel
	--GUI.SetVisible(panel,false)
    local panelCover = GUI.ImageCreate( panel,"panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)

    -- 底图
    local panelBg = GUI.ImageCreate( panel,"PanelBg", "1800600182", 0, 0, false,500, 440)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)

    local rightBg = GUI.ImageCreate( panelBg,"RightBg", "1800600181", 0, -9.5, false, 175, 50)
    UILayout.SetSameAnchorAndPivot(rightBg, UILayout.TopRight)

    local leftBg = GUI.ImageCreate( panelBg,"LeftBg", "1800600180", 0, -9.5, false, 175, 50)
    UILayout.SetSameAnchorAndPivot(leftBg, UILayout.TopLeft)

    -- 标题底板
    local titleBg = GUI.ImageCreate( panelBg,"TitleBg", "1800600190", 0, -8, false, 220, 49)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)

    -- 标题
    local titleTxt = GUI.CreateStatic( titleBg,"TitleText", "获奖感言", 0, 0, 200, 35)
    UILayout.SetSameAnchorAndPivot(titleTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(titleTxt, 26, colorDark, TextAnchor.MiddleCenter)

    -- 功能名称
    --local NameTip = GUI.CreateStatic( panelBg,"NameTip", "[活动名称]", 30, 45, 200, 35)
    --UILayout.SetSameAnchorAndPivot(NameTip, UILayout.TopLeft)
    --UILayout.StaticSetFontSizeColorAlignment(NameTip, 24, tipColor, nil)

    local NameText = GUI.CreateStatic( panelBg,"NameText", "30", 35, 70, 440, 70)
    UILayout.SetSameAnchorAndPivot(NameText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(NameText, UIDefine.FontSizeM, contentColor, nil)
    _gt.BindName(NameText, "NameText")

    local RewardInfo = GUI.EditCreate(panelBg, "RewardInfo", "1800001040", "请输入文字", 30, 155, Transition.ColorTint, "system", 445, 218, 10)
    _gt.BindName(RewardInfo, "RewardInfo")
    SetAnchorAndPivot(RewardInfo, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.EditSetLabelAlignment(RewardInfo, TextAnchor.MiddleCenter)
    GUI.EditSetFontSize(RewardInfo,  UIDefine.FontSizeL)
    GUI.EditSetTextColor(RewardInfo, UIDefine.BrownColor)
    GUI.SetPlaceholderTxtColor(RewardInfo, colorType_Input)
    GUI.RegisterUIEvent(RewardInfo, UCE.PointerClick, "MallFreeUI", "OnInputFieldClick")
    --GUI.RichEditSetShowUnderline(RewardInfo, true)	
    --GUI.EditSetMultiLineEdit(RewardInfo, LineType.SingleLine)
    GUI.EditSetMaxCharNum(RewardInfo, 800) 
	GUI.EditSetMultiLineEdit(RewardInfo, LineType.MultiLineSubmit)
    
    
    -- 功能介绍
    --local InfoTip = GUI.CreateStatic( panelBg,"InfoTip", "[活动介绍]", 30, 120, 200, 35)
    --UILayout.SetSameAnchorAndPivot(InfoTip, UILayout.TopLeft)
    --UILayout.StaticSetFontSizeColorAlignment(InfoTip, 24, tipColor, nil)

	local InfoText_Scr = GUI.ScrollRectCreate(panelBg, "InfoText_Scr", 0, 150, 520, 80, 0, false, Vector2.New(0, 0), UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetAnchorAndPivot(InfoText_Scr, UIAnchor.Top, UIAroundPivot.Top)

    --发送按钮
    local GoBtn = GUI.ButtonCreate( panelBg,"GoBtn", "1800402080", 0, -44, Transition.ColorTint, "发表感言", 158, 46, false)
    UILayout.SetAnchorAndPivot(GoBtn, UIAnchor.Bottom, UIAroundPivot.Center)
    GUI.ButtonSetTextFontSize(GoBtn, 26)
    GUI.ButtonSetTextColor(GoBtn, colorWhite)
    GUI.SetIsOutLine(GoBtn, true)
    GUI.SetOutLine_Color(GoBtn, colorOutline)
    GUI.SetOutLine_Distance(GoBtn, 1)
    GUI.RegisterUIEvent(GoBtn, UCE.PointerClick, "MallFreeUI", "OnClickGoBtn")

    -- 关闭
    local closeBtn = GUI.ButtonCreate( panelBg,"ClosePanelBtn", "1800302120", 0, -6, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "MallFreeUI", "OnClickGoBtn")

    --CL.SendNotify(NOTIFY.SubmitForm, "FormMallFree", "GetData")
end

--刷新文字
function MallFreeUI.RefreshInfo()
    if MallFreeUI.ResInfo then
        GUI.EditSetTextM(_gt.GetUI("RewardInfo"), MallFreeUI.ResInfo)
    end
    if MallFreeUI.Info then
        GUI.StaticSetText(_gt.GetUI("NameText"), MallFreeUI.Info)
    end
end

--发送内容
function MallFreeUI.OnClickGoBtn(guid)
    local text = GUI.EditGetTextM(_gt.GetUI("RewardInfo"))
    test("=====================text"..text)
    if text then
        CL.SendChatMsg(8, text)
    else
        CL.SendChatMsg(8, MallFreeUI.ResInfo)
    end
    MallFreeUI.OnClosePanel(guid)
end


--关闭界面
function MallFreeUI.OnClosePanel(guid)
	GUI.DestroyWnd("MallFreeUI")
end
