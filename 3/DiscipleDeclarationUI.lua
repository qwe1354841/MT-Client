DiscipleDeclarationUI = {}
DiscipleDeclarationUI.Data = ""
DiscipleDeclarationUI.Initial_Declaration = ""
local _gt = UILayout.NewGUIDUtilTable()

-- 大弟子宣言编辑界面
local colorDark = Color.New(102/255, 47/255, 22/255, 255/255)
local colorOutline = Color.New(175/255, 96/255, 19/255, 255/255)
local colorWhite = Color.New(255/255, 246/255, 232/255, 255/255)

function DiscipleDeclarationUI.Main(parameter)
	local panel = GUI.WndCreateWnd("DiscipleDeclarationUI", "DiscipleDeclarationUI", 0, 0)
    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelCover = GUI.ImageCreate(panel,"PanelCover", "1800400220", 0, 0, false, 2000, 2000)
    UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center)
    GUI.SetIsRaycastTarget(panelCover,true)

    local width = 465
    local height = 305

    -- 底图
    local panelBg = GUI.ImageCreate(panelCover, "PanelBg", "1800001120", 0, 0, false, width, height)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)

    -- 标题背景图
    local titleBg = GUI.ImageCreate(panelBg,"TitleBg", "1800001140", 0, 20, false, 267, 35)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)

    -- 玩家名字
    local titleTxt = GUI.CreateStatic(titleBg, "TitleText", "编辑竞选宣言", 0, 0, 160, 35)
    UILayout.SetSameAnchorAndPivot(titleTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(titleTxt, 26, colorWhite)

    -- 输入框底图
    local inputAreaBg = GUI.ImageCreate(panelBg, "inputAreaBg", "1800400200", 0, 0, false, 412, 136)
    UILayout.SetSameAnchorAndPivot(inputAreaBg, UILayout.Center)

    -- 输入框
    local input = GUI.EditCreate(panelBg, "Input", "1800001040", "", 0, 0, Transition.ColorTint, "system", 415, 158, 8, 8)
    GUI.EditSetLabelAlignment(input, TextAnchor.MiddleCenter)
    GUI.EditSetTextColor(input, colorDark)
    GUI.EditSetFontSize(input, 22)
    GUI.EditSetMaxCharNum(input, 60)
	_gt.BindName(input, "input")

    -- 确认
    local OKBtn = GUI.ButtonCreate(panelBg,"OKBtn", "1800402080", -26, -18, Transition.ColorTint, "")
    UILayout.SetSameAnchorAndPivot(OKBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(OKBtn, UCE.PointerClick , "DiscipleDeclarationUI", "OnClickSure")

    local OKBtnText = GUI.CreateStatic(OKBtn,"OKBtnText", "确认", 0, 0, 160, 47, "system", true)
    UILayout.SetSameAnchorAndPivot(OKBtnText, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(OKBtnText, 26, colorWhite, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(OKBtnText, true)
    GUI.SetOutLine_Color(OKBtnText, colorOutline)
    GUI.SetOutLine_Distance(OKBtnText, 1)

    -- 关闭
    local cancelBtn = GUI.ButtonCreate(panelBg,"cancelBtn", "1800402080", 26, -18, Transition.ColorTint, "")
    UILayout.SetSameAnchorAndPivot(cancelBtn, UILayout.BottomLeft)
    GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick , "DiscipleDeclarationUI", "OnCloseBtnClick")

    local cancelBtnText = GUI.CreateStatic(cancelBtn,"cancelBtnText", "取消", 0, 0, 160, 47, "system", true)
    UILayout.SetSameAnchorAndPivot(cancelBtnText, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(cancelBtnText, 26, colorWhite, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(cancelBtnText, true)
    GUI.SetOutLine_Color(cancelBtnText, colorOutline)
    GUI.SetOutLine_Distance(cancelBtnText, 1)

    -- 关闭
    local closeBtn = GUI.ButtonCreate(panelBg,"ClosePanelBtn", "1800302120", 3, -3, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick , "DiscipleDeclarationUI", "OnCloseBtnClick")

    --CL.RegisterMessage(GM.DiscipleDeclarationUpdate, "DiscipleDeclarationUI", "RefreshDeclarationData")

    --DiscipleDeclarationUI.RefreshDeclarationData()
end

function DiscipleDeclarationUI.RefreshDeclarationData()
    local input = _gt.GetUI("input")
    if not input then
        test("RefreshDeclarationData  没有input")
		return
    end
    local declaration = DiscipleDeclarationUI.Data
	if declaration then
		test("刷新declaration = "..declaration)
		GUI.EditSetTextM(input, declaration)
	else
		test("没有declaration")
	end
end

function DiscipleDeclarationUI.OnClickSure()
    local input = _gt.GetUI("input")
    if not input then
        test("没有input")
		return
    end

	--if not DiscipleDeclarationUI.Data or not DiscipleDeclarationUI.Initial_Declaration or DiscipleDeclarationUI.Data == "" or DiscipleDeclarationUI.Initial_Declaration == "" then
	--	test("没有DiscipleVoteUI.Data")
	--	return
	--end
	local SelfGUID = tostring(LD.GetSelfGUID())
    local declaration = GUI.EditGetTextM(input)
	test("输入declaration = "..tostring(declaration))
    local len = string.len(declaration)
	test("len = "..tostring(len))
    if len < 9 then
        declaration = DiscipleDeclarationUI.Initial_Declaration
		CL.SendNotify(NOTIFY.ShowBBMsg, "您输入的宣言过短")
		GUI.EditSetTextM(input, declaration)
		return
    elseif len > 60 then
		declaration = DiscipleDeclarationUI.Initial_Declaration
        CL.SendNotify(NOTIFY.ShowBBMsg, "您输入的宣言过长")
		GUI.EditSetTextM(input, declaration)
        return
    --elseif CL.CheckSensitiveWord(declaration) then
    --    declaration = DiscipleDeclarationUI.Initial_Declaration
	--	CL.SendNotify(NOTIFY.ShowBBMsg, "您编辑的内容含有敏感词汇，请重新编辑")
	--	GUI.EditSetTextM(input, declaration)
    --    return
    end
    test("确认declaration = "..declaration)
	CL.SendNotify(NOTIFY.SubmitForm, "FormFirstDisciple", "Modify_Declaration", declaration)
    --CL.SendNotify(NOTIFY.ShowBBMsg, "修改竞选宣言成功")
	--DiscipleDeclarationUI.RefreshDeclarationData()
    DiscipleDeclarationUI.OnCloseBtnClick()
end

function DiscipleDeclarationUI.OnShow(parameter)
	test("DiscipleDeclarationUI.OnShow")
	local wnd = GUI.GetWnd("DiscipleDeclarationUI")
    if wnd then
        GUI.SetVisible(wnd, true)
	end
	DiscipleDeclarationUI.RefreshDeclarationData()
end

function DiscipleDeclarationUI.OnCloseBtnClick(key)
    local wnd = GUI.GetWnd("DiscipleDeclarationUI")
    if wnd ~= nil then
        GUI.CloseWnd("DiscipleDeclarationUI")
    end
end
