PlayerMsgFeedBackUI = {}

_G.PlayerMsgFeedBackUI = PlayerMsgFeedBackUI
local _gt = UILayout.NewGUIDUtilTable()


--注： parameter =  "Title,Msg"  在OpenWnd时传过来

function PlayerMsgFeedBackUI.Main(parameter)
	if parameter == nil then
		return
	end
	
	_gt = UILayout.NewGUIDUtilTable()
	
	PlayerMsgFeedBackUI.SetData(parameter)
	
	local wnd = GUI.WndCreateWnd("PlayerMsgFeedBackUI", "PlayerMsgFeedBackUI", 0, 0)
	GUI.SetVisible(panel, true)
    UILayout.SetAnchorAndPivot(wnd, UIAnchor.Center, UIAroundPivot.Center)
	
	--阴影
	local panelCover = GUI.ImageCreate(wnd, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
	
	local panel = GUI.ImageCreate(wnd,"panel","1800001120",0,0,false,600,380)
	UILayout.SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
	--装饰花
	local flower = GUI.ImageCreate(panel,"flower","1800007060",-20,-20,true)
	UILayout.SetAnchorAndPivot(flower, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	
	--标题
	local TitleBg = GUI.ImageCreate(panel,"TitleBg","1800001030",0,15,true) 
	UILayout.SetAnchorAndPivot(TitleBg, UIAnchor.Top, UIAroundPivot.Top)
	local Title= GUI.CreateStatic(TitleBg, "Title",PlayerMsgFeedBackUI.Title, 0, 4, 150, 30);
	GUI.SetColor(Title, UIDefine.White2Color)
	GUI.StaticSetFontSize(Title, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(Title, TextAnchor.MiddleCenter)
	
	--右上角关闭
	local ExitBtn = GUI.ButtonCreate(panel,"ExitBtn","1800002050",-10,10,Transition.ColorTint,"",0,0,true)
	UILayout.SetAnchorAndPivot(ExitBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
	GUI.RegisterUIEvent(ExitBtn, UCE.PointerClick, "PlayerMsgFeedBackUI", "OnCloseBtnClick")
	
	--提交按钮
	local SubmitBtn = GUI.ButtonCreate(panel,"SubmitBtn","1800102090",198,146,Transition.ColorTint,"",160,46,false)
	UILayout.SetAnchorAndPivot(SubmitBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(SubmitBtn, UCE.PointerClick, "PlayerMsgFeedBackUI", "OnSubmitBtnClick")
	
    local SubmitBtnText = GUI.CreateStatic(SubmitBtn, "SubmitBtnText", "提交", 0, 0, 160, 80, "system", true)
    UILayout.SetAnchorAndPivot(SubmitBtnText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(SubmitBtnText,UIDefine.WhiteColor)
    GUI.StaticSetFontSize(SubmitBtnText, 26)
    GUI.StaticSetAlignment(SubmitBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(SubmitBtnText, true)
    GUI.SetOutLine_Color(SubmitBtnText,Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(SubmitBtnText,1)	
	
	--关闭按钮
	local CloseBtn = GUI.ButtonCreate(panel,"CloseBtn","1800102090",-192,146,Transition.ColorTint,"",160,46,false)
	UILayout.SetAnchorAndPivot(CloseBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(CloseBtn, UCE.PointerClick, "PlayerMsgFeedBackUI", "OnCloseBtnClick")

    local CloseBtnText = GUI.CreateStatic( CloseBtn, "CloseBtnText", "关闭", 0, 0, 160, 80, "system", true)
    UILayout.SetAnchorAndPivot(CloseBtnText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(CloseBtnText,UIDefine.WhiteColor)
    GUI.StaticSetFontSize(CloseBtnText,26)
    GUI.StaticSetAlignment(CloseBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(CloseBtnText, true)
    GUI.SetOutLine_Color(CloseBtnText,Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(CloseBtnText,1)	
	

    -- 输入框底图
    local InputMsgBg = GUI.ImageCreate( panel, "InputMsgBg", "1800400200", 0, -2, false, 550, 233)
    UILayout.SetAnchorAndPivot(InputMsgBg, UIAnchor.Center, UIAroundPivot.Center)

	-- Msg 标题
    local Msg = GUI.CreateStatic( InputMsgBg, "Msg", PlayerMsgFeedBackUI.Msg, 0, 0, 480, 80, "system", true)
    UILayout.SetAnchorAndPivot(Msg, UIAnchor.Top, UIAroundPivot.Top)
	GUI.SetColor(Msg,UIDefine.Brown4Color)
    GUI.StaticSetFontSize(Msg,24)
    GUI.StaticSetAlignment(Msg, TextAnchor.MiddleCenter)	

    local Input = GUI.EditCreate(InputMsgBg, "Input","1800001040", "", 0, 30, Transition.ColorTint, "system", 520, 145, 25, 10)
    GUI.EditSetMaxCharNum(Input, 800) 
	GUI.EditSetMultiLineEdit(Input, LineType.MultiLineSubmit)
    GUI.EditSetTextColor(Input, UIDefine.BrownColor)
    GUI.SetPlaceholderTxtColor(Input, UIDefine.GrayColor)
    GUI.EditSetLabelAlignment(Input, TextAnchor.UpperLeft)
    GUI.EditSetFontSize(Input, 22)
    _gt.BindName(Input,"Input")
end

function PlayerMsgFeedBackUI.OnShow(parameter)
	-- local wnd = GUI.GetWnd("PlayerMsgFeedBackUI")
    -- if wnd then
        -- GUI.SetVisible(wnd, true)
    -- end
	PlayerMsgFeedBackUI.Register()
end

function PlayerMsgFeedBackUI.Register() 
	CL.RegisterMessage(GM.LoginWebService, "PlayerMsgFeedBackUI", "LoginWebService")
end

function PlayerMsgFeedBackUI.SetData(parameter)
	parameter = string.split(parameter,",")
	PlayerMsgFeedBackUI.Title = parameter[1]
	PlayerMsgFeedBackUI.Msg = parameter[2]
	return
end

function PlayerMsgFeedBackUI.OnCloseBtnClick()
	GUI.DestroyWnd("PlayerMsgFeedBackUI")

end

function PlayerMsgFeedBackUI.OnSubmitBtnClick()
    local Input = _gt.GetUI("Input")
    if Input == nil then
        return
    end
	
	PlayerMsgFeedBackUI.NewMsg = ""
    PlayerMsgFeedBackUI.NewMsg = GUI.EditGetTextM(Input)
	
	if PlayerMsgFeedBackUI.NewMsg == "" then
	GlobalUtils.ShowBoxMsg1Btn("提示","输入不能为空","PlayerMsgFeedBackUI","确定")
	else
    test(PlayerMsgFeedBackUI.NewMsg)
		if not CL.IsHaveForbiddenWord(PlayerMsgFeedBackUI.NewMsg) then
			CL.RequestSuggestionApi(0, "联系GM", PlayerMsgFeedBackUI.NewMsg,"")
			test("提交成功")
			GUI.DestroyWnd("PlayerMsgFeedBackUI")
		else
			GlobalUtils.ShowBoxMsg1Btn("提示","您输入的内容包含敏感字","PlayerMsgFeedBackUI","确定")
		end
	end


end

function PlayerMsgFeedBackUI.LoginWebService(param0,param1)
	test("==========="..param0)
	test(param1)
	if param0 == 11 and param1 == 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"提交成功！")
	end
end