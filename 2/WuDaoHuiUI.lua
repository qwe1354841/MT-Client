local WuDaoHuiUI = {
FightInfo = {}
}

_G.WuDaoHuiUI = WuDaoHuiUI
local _gt = UILayout.NewGUIDUtilTable()

local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorGary = Color.New(200 / 255, 200 / 255, 200 / 255, 1)

function WuDaoHuiUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("WuDaoHuiUI", "WuDaoHuiUI", 0, 0);
	GUI.SetVisible(panel, false)
	local panelCover = GUI.ImageCreate(panel, "panelCover", "1800001060", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetIsRaycastTarget(panelCover, true)
    -- panelCover:RegisterEvent(UCE.PointerClick)
    -- MoneyBar.CreateDefault(panelCover, "WuDaoHuiUI")
    local panelBg = GUI.GroupCreate(panel, "panelBg", 0, 0, 1280, 660)
    UILayout.SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)
	local LeftPanel = GUI.ImageCreate(panelBg, "LeftPanel", "1800608080", 0, 0, true)
    UILayout.SetAnchorAndPivot(LeftPanel, UIAnchor.Left, UIAroundPivot.Left)	
	local RightPanel = GUI.ImageCreate(panelBg, "RightPanel", "1800608090", 0, 0, true)
    UILayout.SetAnchorAndPivot(RightPanel, UIAnchor.Right, UIAroundPivot.Right)	
	
	local TitleBg = GUI.ImageCreate(panelBg, "TitleBg", "1800608420", 0, -230, true)
    UILayout.SetAnchorAndPivot(TitleBg, UIAnchor.Center, UIAroundPivot.Center)	
	local Title = GUI.ImageCreate(TitleBg, "Title", "1800604370", 0, 15, true)
    UILayout.SetAnchorAndPivot(Title, UIAnchor.Center, UIAroundPivot.Center)	
	local CloseBtn = GUI.ButtonCreate(panelBg,"CloseBtn","1800602110",600,-180,Transition.ColorTint)
	UILayout.SetAnchorAndPivot(CloseBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(CloseBtn, UCE.PointerClick, "WuDaoHuiUI", "OnCloseBtnClick")
	
	--左侧朱雀
	local BePresentNumText1 = GUI.CreateStatic(LeftPanel, "BePresentNumText1", "在场：", -180, -180, 280, 30, "system")
	UILayout.SetAnchorAndPivot(BePresentNumText1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(BePresentNumText1,colorWhite)
	-- GUI.SetIsOutLine(BePresentNumTxet1, true)
    -- GUI.SetOutLine_Color(BePresentNumTxet1,colorWhite)
	GUI.StaticSetFontSize(BePresentNumText1, 22)
	GUI.StaticSetAlignment(BePresentNumText1, TextAnchor.MiddleCenter)
	
	local BePresentNum1 = GUI.CreateStatic(LeftPanel, "BePresentNum1", "0 / 0", -130, -180, 280, 30, "system")
	UILayout.SetAnchorAndPivot(BePresentNum1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(BePresentNum1,colorWhite)
	-- GUI.SetIsOutLine(BePresentNum1, true)
    -- GUI.SetOutLine_Color(BePresentNum1,colorWhite)
	GUI.StaticSetFontSize(BePresentNum1, 22)
	GUI.StaticSetAlignment(BePresentNum1, TextAnchor.MiddleCenter)
	_gt.BindName(BePresentNum1,"BePresentNum1")
	
	local IntegralTotalText1 = GUI.CreateStatic(LeftPanel, "IntegralTotalText1", "朱雀积分：", 170, -180, 280, 30, "system")
	UILayout.SetAnchorAndPivot(IntegralTotalText1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(IntegralTotalText1,colorWhite)
	GUI.StaticSetFontSize(IntegralTotalText1, 22)
	GUI.StaticSetAlignment(IntegralTotalText1, TextAnchor.MiddleCenter)	
	
	local IntegralTotal1 = GUI.CreateStatic(LeftPanel, "IntegralTotal1", "0", 260, -180, 280, 30, "system")
	UILayout.SetAnchorAndPivot(IntegralTotal1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(IntegralTotal1,colorWhite)
	GUI.StaticSetFontSize(IntegralTotal1, 22)
	GUI.StaticSetAlignment(IntegralTotal1, TextAnchor.MiddleCenter)	
	_gt.BindName(IntegralTotal1,"IntegralTotal1")

	local WinImg = GUI.ImageCreate(LeftPanel, "WinImg", "1800604280", 30, -190, true)
    UILayout.SetAnchorAndPivot(WinImg, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(WinImg,"WinImg")
	GUI.SetVisible(WinImg,false)

	
	local RankSpTitle1 = GUI.CreateStatic(LeftPanel, "RankSpTitle1", "排名", -240, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(RankSpTitle1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(RankSpTitle1,UIDefine.OrangeColor)
	-- GUI.SetIsOutLine(RankSpTitle1, true)
    -- GUI.SetOutLine_Color(RankSpTitle1,colorOutline)
	GUI.StaticSetFontSize(RankSpTitle1, 22)
	GUI.StaticSetAlignment(RankSpTitle1, TextAnchor.MiddleCenter)
	
	local PlayerNameTitle1 = GUI.CreateStatic(LeftPanel, "PlayerNameTitle1", "玩家名称", -125, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerNameTitle1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerNameTitle1,UIDefine.OrangeColor)
	-- GUI.SetIsOutLine(PlayerNameTitle1, true)
    -- GUI.SetOutLine_Color(PlayerNameTitle1,colorOutline)
	GUI.StaticSetFontSize(PlayerNameTitle1, 22)
	GUI.StaticSetAlignment(PlayerNameTitle1, TextAnchor.MiddleCenter)
	
	local OfficialRankTitle1 = GUI.CreateStatic(LeftPanel, "OfficialRankTitle1", "官衔", 0, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(OfficialRankTitle1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(OfficialRankTitle1,UIDefine.OrangeColor)
	-- GUI.SetIsOutLine(OfficialRankTitle1, true)
    -- GUI.SetOutLine_Color(OfficialRankTitle1,colorOutline)
	GUI.StaticSetFontSize(OfficialRankTitle1, 22)
	GUI.StaticSetAlignment(OfficialRankTitle1, TextAnchor.MiddleCenter)

	local IntegralTitle1 = GUI.CreateStatic(LeftPanel, "IntegralTitle1", "本场积分", 120, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(IntegralTitle1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(IntegralTitle1,UIDefine.OrangeColor)
	-- GUI.SetIsOutLine(IntegralTitle1, true)
    -- GUI.SetOutLine_Color(IntegralTitle1,colorOutline)
	GUI.StaticSetFontSize(IntegralTitle1, 22)
	GUI.StaticSetAlignment(IntegralTitle1, TextAnchor.MiddleCenter)

	local WinRateTitle1 = GUI.CreateStatic(LeftPanel, "WinRateTitle1", "本场胜率", 240, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(WinRateTitle1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(WinRateTitle1,UIDefine.OrangeColor)
	-- GUI.SetIsOutLine(WinRateTitle1, true)
    -- GUI.SetOutLine_Color(WinRateTitle1,colorOutline)
	GUI.StaticSetFontSize(WinRateTitle1, 22)
	GUI.StaticSetAlignment(WinRateTitle1, TextAnchor.MiddleCenter)	
	
	local PlayerCurrentRank1 = GUI.ImageCreate(LeftPanel,"PlayerCurrentRank1" , "1800600250", 0, -10,false,639,43)
	UILayout.SetAnchorAndPivot(PlayerCurrentRank1, UIAnchor.Bottom, UIAroundPivot.Bottom)
	_gt.BindName(PlayerCurrentRank1,"PlayerCurrentRank1")
	GUI.SetVisible(PlayerCurrentRank1,false)
	
	local PlayerCurrentRank1_Sp = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Sp", "1", -240, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Sp, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank1_Sp,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank1_Sp, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank1_Sp, TextAnchor.MiddleCenter)	
	
	local PlayerCurrentRank1_Name = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Name", "我是谁", -130, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Name, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank1_Name,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank1_Name, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank1_Name, TextAnchor.MiddleCenter)

	local PlayerCurrentRank1_Pos = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Pos", "无名小吏", 0, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Pos, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank1_Pos,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank1_Pos, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank1_Pos, TextAnchor.MiddleCenter)	

	local PlayerCurrentRank1_Integral = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Integral", "", 120, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Integral, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank1_Integral,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank1_Integral, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank1_Integral, TextAnchor.MiddleCenter)	

	local PlayerCurrentRank1_Rate = GUI.CreateStatic(PlayerCurrentRank1, "PlayerCurrentRank1_Rate", "100%", 240, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank1_Rate, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank1_Rate,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank1_Rate, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank1_Rate, TextAnchor.MiddleCenter)		

	--朱雀阵营排行榜
	local ZhuQueRankScroll = GUI.LoopScrollRectCreate(LeftPanel, "ZhuQueRankScroll", 0, 28, 640, 260,
	"WuDaoHuiUI", "CreateZhuQueRankItem", "WuDaoHuiUI", "RefreshZhuQueRankScroll", 0, false, Vector2.New(660, 42), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetAnchorAndPivot(ZhuQueRankScroll, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(ZhuQueRankScroll, "ZhuQueRankScroll")
	
	--右侧青龙
	local BePresentNumText2 = GUI.CreateStatic(RightPanel, "BePresentNumText2", "在场：", -100, -180, 280, 30, "system")
	UILayout.SetAnchorAndPivot(BePresentNumText2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(BePresentNumText2,colorWhite)
	-- GUI.SetIsOutLine(BePresentNumTxet2, true)
    -- GUI.SetOutLine_Color(BePresentNumTxet2,colorWhite)
	GUI.StaticSetFontSize(BePresentNumText2, 22)
	GUI.StaticSetAlignment(BePresentNumText2, TextAnchor.MiddleCenter)
	

	local BePresentNum2 = GUI.CreateStatic(RightPanel, "BePresentNum2", "0 / 0", -150, -180, 280, 30, "system") --比老版右移10
	UILayout.SetAnchorAndPivot(BePresentNum2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(BePresentNum2,colorWhite)
	-- GUI.SetIsOutLine(BePresentNum2, true)
    -- GUI.SetOutLine_Color(BePresentNum2,colorWhite)
	GUI.StaticSetFontSize(BePresentNum2, 22)
	GUI.StaticSetAlignment(BePresentNum2, TextAnchor.MiddleCenter)	
	_gt.BindName(BePresentNum2,"BePresentNum2")
	
	local IntegralTotalText2 = GUI.CreateStatic(RightPanel, "IntegralTotalText2", "青龙积分：", 230, -180, 280, 30, "system")
	UILayout.SetAnchorAndPivot(IntegralTotalText2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(IntegralTotalText2,colorWhite)
	GUI.StaticSetFontSize(IntegralTotalText2, 22)
	GUI.StaticSetAlignment(IntegralTotalText2, TextAnchor.MiddleCenter)	
	
	local IntegralTotal2 = GUI.CreateStatic(RightPanel, "IntegralTotal2", "0", 145, -180, 280, 30, "system")
	UILayout.SetAnchorAndPivot(IntegralTotal2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(IntegralTotal2,colorWhite)
	GUI.StaticSetFontSize(IntegralTotal2, 22)
	GUI.StaticSetAlignment(IntegralTotal2, TextAnchor.MiddleCenter)	
	_gt.BindName(IntegralTotal2,"IntegralTotal2")
	
	local LoseImg = GUI.ImageCreate(RightPanel, "LoseImg", "1800604270", 30, -190, true)
    UILayout.SetAnchorAndPivot(LoseImg, UIAnchor.Center, UIAroundPivot.Center)	
	_gt.BindName(LoseImg,"LoseImg")
	GUI.SetVisible(LoseImg,false)
	
	local RankSpTitle2 = GUI.CreateStatic(RightPanel, "RankSpTitle2", "排名", 240, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(RankSpTitle2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(RankSpTitle2,UIDefine.Blue4Color)
	-- GUI.SetIsOutLine(RankSpTitle2, true)
    -- GUI.SetOutLine_Color(RankSpTitle2, colorWhite)
	GUI.StaticSetFontSize(RankSpTitle2, 22)
	GUI.StaticSetAlignment(RankSpTitle2, TextAnchor.MiddleCenter)
	
	local PlayerNameTitle2 = GUI.CreateStatic(RightPanel, "PlayerNameTitle2", "玩家名称", 125, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerNameTitle2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerNameTitle2,UIDefine.Blue4Color)
	-- GUI.SetIsOutLine(PlayerNameTitle2, true)
    -- GUI.SetOutLine_Color(PlayerNameTitle2,colorWhite)
	GUI.StaticSetFontSize(PlayerNameTitle2, 22)
	GUI.StaticSetAlignment(PlayerNameTitle2, TextAnchor.MiddleCenter)
	
	local OfficialRankTitle2 = GUI.CreateStatic(RightPanel, "OfficialRankTitle2", "官衔", 0, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(OfficialRankTitle2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(OfficialRankTitle2,UIDefine.Blue4Color)
	-- GUI.SetIsOutLine(OfficialRankTitle2, true)
    -- GUI.SetOutLine_Color(OfficialRankTitle2,colorWhite)
	GUI.StaticSetFontSize(OfficialRankTitle2, 22)
	GUI.StaticSetAlignment(OfficialRankTitle2, TextAnchor.MiddleCenter)

	local IntegralTitle2 = GUI.CreateStatic(RightPanel, "IntegralTitle2", "本场积分", -120, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(IntegralTitle2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(IntegralTitle2,UIDefine.Blue4Color)
	-- GUI.SetIsOutLine(IntegralTitle2, true)
    -- GUI.SetOutLine_Color(IntegralTitle2,colorWhite)
	GUI.StaticSetFontSize(IntegralTitle2, 22)
	GUI.StaticSetAlignment(IntegralTitle2, TextAnchor.MiddleCenter)

	local WinRateTitle2 = GUI.CreateStatic(RightPanel, "WinRateTitle2", "本场胜率", -240, -130, 280, 30, "system")
	UILayout.SetAnchorAndPivot(WinRateTitle2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(WinRateTitle2,UIDefine.Blue4Color)
	-- GUI.SetIsOutLine(WinRateTitle2, true)
    -- GUI.SetOutLine_Color(WinRateTitle2,colorWhite)
	GUI.StaticSetFontSize(WinRateTitle2, 22)
	GUI.StaticSetAlignment(WinRateTitle2, TextAnchor.MiddleCenter)	

	local PlayerCurrentRank2 = GUI.ImageCreate(RightPanel,"PlayerCurrentRank2" , "1800600250", 0, -10,false,639,43)
	UILayout.SetAnchorAndPivot(PlayerCurrentRank2, UIAnchor.Bottom, UIAroundPivot.Bottom)
	_gt.BindName(PlayerCurrentRank2,"PlayerCurrentRank2")
	GUI.SetVisible(PlayerCurrentRank2,false)

	local PlayerCurrentRank2_Sp = GUI.CreateStatic(PlayerCurrentRank2, "PlayerCurrentRank2_Sp", "1", -240, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank2_Sp, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank2_Sp,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank2_Sp, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank2_Sp, TextAnchor.MiddleCenter)	
	
	local PlayerCurrentRank2_Name = GUI.CreateStatic(PlayerCurrentRank2, "PlayerCurrentRank2_Name", "我是谁", -130, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank2_Name, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank2_Name,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank2_Name, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank2_Name, TextAnchor.MiddleCenter)

	local PlayerCurrentRank2_Pos = GUI.CreateStatic(PlayerCurrentRank2, "PlayerCurrentRank2_Pos", "无名小吏", 0, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank2_Pos, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank2_Pos,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank2_Pos, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank2_Pos, TextAnchor.MiddleCenter)	

	local PlayerCurrentRank2_Integral = GUI.CreateStatic(PlayerCurrentRank2, "PlayerCurrentRank2_Integral", "600", 120, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank2_Integral, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank2_Integral,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank2_Integral, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank2_Integral, TextAnchor.MiddleCenter)	

	local PlayerCurrentRank2_Rate = GUI.CreateStatic(PlayerCurrentRank2, "PlayerCurrentRank2_Rate", "100%", 240, 1, 280, 30, "system")
	UILayout.SetAnchorAndPivot(PlayerCurrentRank2_Rate, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PlayerCurrentRank2_Rate,colorDark)
	GUI.StaticSetFontSize(PlayerCurrentRank2_Rate, 22)
	GUI.StaticSetAlignment(PlayerCurrentRank2_Rate, TextAnchor.MiddleCenter)	

	--青龙阵营排行榜
	local QingLongRankScroll = GUI.LoopScrollRectCreate(RightPanel, "QingLongRankScroll", 0, 28, 640, 260,
	"WuDaoHuiUI", "CreateQingLongRankItem", "WuDaoHuiUI", "RefreshQingLongRankScroll", 0, false, Vector2.New(660, 42), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetAnchorAndPivot(QingLongRankScroll, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(QingLongRankScroll, "QingLongRankScroll")
	

end


function WuDaoHuiUI.OnShow(parameter)
	local wnd = GUI.GetWnd("WuDaoHuiUI")
	
	WuDaoHuiUI.Register()
	
	if wnd then
		GUI.SetVisible(wnd, true)
	end
	
	CL.SendNotify(NOTIFY.SubmitForm, "FormWuDaoHui", "GetTeamPlayerData")
end

function WuDaoHuiUI.Register()
	CL.RegisterMessage(GM.FightStateNtf, "WuDaoHuiUI", "OnCloseBtnClick")
end


function  WuDaoHuiUI.OnCloseBtnClick()
	GUI.Destroy("WuDaoHuiUI")
end

function  WuDaoHuiUI.Refresh()
	-- local inspect = require("inspect")
	--CDebug.LogError(inspect(WuDaoHuiUI.FightInfo))
	
	local ZhuQueRankScroll = _gt.GetUI("ZhuQueRankScroll")
	local QingLongRankScroll = _gt.GetUI("QingLongRankScroll")
	
	local BePresentNum1 = _gt.GetUI("BePresentNum1")
	local BePresentNum2 = _gt.GetUI("BePresentNum2")
	local IntegralTotal1 = _gt.GetUI("IntegralTotal1")	
	local IntegralTotal2 = _gt.GetUI("IntegralTotal2")
	local PlayerCurrentRank1 = _gt.GetUI("PlayerCurrentRank1")
	local PlayerCurrentRank2 = _gt.GetUI("PlayerCurrentRank2")		
	
	local num1 = WuDaoHuiUI.FightInfo["RedTeam"]["InMapPlayerNum"]
	local num2 = WuDaoHuiUI.FightInfo["BlueTeam"]["InMapPlayerNum"]

	local SumNum1 = #WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"]
	local SumNum2 = #WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"]
	
	local WinImg = _gt.GetUI("WinImg")
	local LoseImg = _gt.GetUI("LoseImg")
	
	--胜负显示
	if WuDaoHuiUI.FightInfo["Win_Team"] ~= nil then
		if WuDaoHuiUI.FightInfo["Win_Team"] ==1  then
			GUI.SetVisible(WinImg,true)
			GUI.SetVisible(LoseImg,true)
			GUI.ImageSetImageID(WinImg,"1800604270")
			GUI.ImageSetImageID(LoseImg,"1800604280")
		elseif WuDaoHuiUI.FightInfo["Win_Team"] ==2  then
			GUI.SetVisible(WinImg,true)
			GUI.SetVisible(LoseImg,true)
			GUI.ImageSetImageID(WinImg,"1800604280")
			GUI.ImageSetImageID(LoseImg,"1800604270")
		elseif  WuDaoHuiUI.FightInfo["Win_Team"] ==3  then
			GUI.SetVisible(WinImg,false)
			GUI.SetVisible(LoseImg,false)
		end
	else
		GUI.SetVisible(WinImg,false)
		GUI.SetVisible(LoseImg,false)
	end
	
	--在场人数显示
	GUI.StaticSetText(BePresentNum1,num1.."/"..SumNum1)	
	GUI.StaticSetText(BePresentNum2,num2.."/"..SumNum2)		

	local TeamScore1 = WuDaoHuiUI.FightInfo["RedTeam"]["TeamScore"]	
	local TeamScore2 = WuDaoHuiUI.FightInfo["BlueTeam"]["TeamScore"]

	GUI.StaticSetText(IntegralTotal1,tostring(TeamScore1))
	GUI.StaticSetText(IntegralTotal2,tostring(TeamScore2))
	--TeamScore
	local BeCampSp1 = 0
	local BeCampSp2 = 0
	local MyName = CL.GetRoleName(0)
	for i =1 , SumNum1 do
		if BeCampSp1 ==0 then
			if MyName == WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][i].name then
				BeCampSp1 = i
			end
		else
			break
		end
	end
	if BeCampSp1 ==0 then
		for i =1 , SumNum2 do
			if BeCampSp2 ==0 then
				if MyName == WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][i].name then
					BeCampSp2 = i
				end
			else
				break
			end
		end	
	end

--个人的战况信息显示	
	if BeCampSp1 ==0 and BeCampSp2 ==0 then
		GUI.SetVisible(PlayerCurrentRank1,false)
		GUI.SetVisible(PlayerCurrentRank2,false)
	elseif BeCampSp1 ~= 0 then		
		local Sp = GUI.GetChild(PlayerCurrentRank1,"PlayerCurrentRank1_Sp")
		local Name = GUI.GetChild(PlayerCurrentRank1,"PlayerCurrentRank1_Name") 
		local Pos = GUI.GetChild(PlayerCurrentRank1,"PlayerCurrentRank1_Pos")
		local Integral = GUI.GetChild(PlayerCurrentRank1,"PlayerCurrentRank1_Integral")
		local Rate = GUI.GetChild(PlayerCurrentRank1,"PlayerCurrentRank1_Rate")

		GUI.StaticSetText(Sp,BeCampSp1)
		GUI.StaticSetText(Name,WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][BeCampSp1].name)
		GUI.StaticSetText(Pos,WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][BeCampSp1].officer)
		GUI.StaticSetText(Integral,WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][BeCampSp1].score)
		if WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][BeCampSp1].WinNum ~= nil then
			GUI.StaticSetText(Rate,WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][BeCampSp1].WinNum.."/"..WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][BeCampSp1].FightNum)
		else
			GUI.StaticSetText(Rate,"0/0")
		end
		
		GUI.SetVisible(PlayerCurrentRank1,true)
		GUI.SetVisible(PlayerCurrentRank2,false)
	
	elseif BeCampSp2 ~= 0 then		
		local Sp = GUI.GetChild(PlayerCurrentRank2,"PlayerCurrentRank2_Sp")
		local Name = GUI.GetChild(PlayerCurrentRank2,"PlayerCurrentRank2_Name") 
		local Pos = GUI.GetChild(PlayerCurrentRank2,"PlayerCurrentRank2_Pos")
		local Integral = GUI.GetChild(PlayerCurrentRank2,"PlayerCurrentRank2_Integral")
		local Rate = GUI.GetChild(PlayerCurrentRank2,"PlayerCurrentRank2_Rate")
		
		GUI.StaticSetText(Sp,BeCampSp2)
		GUI.StaticSetText(Name,WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][BeCampSp2].name)
		GUI.StaticSetText(Pos,WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][BeCampSp2].officer)
		GUI.StaticSetText(Integral,WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][BeCampSp2].score)
		if WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][BeCampSp2].WinNum ~= nil then
			GUI.StaticSetText(Rate,WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][BeCampSp2].WinNum.."/"..WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][BeCampSp2].FightNum)
		else
			GUI.StaticSetText(Rate,"0/0")
		end
		
		GUI.SetVisible(PlayerCurrentRank1,false)
		GUI.SetVisible(PlayerCurrentRank2,true)	
	end
	
--胜负显示
	
	
	
	
	GUI.LoopScrollRectSetTotalCount(ZhuQueRankScroll,SumNum1) 
	GUI.LoopScrollRectRefreshCells(ZhuQueRankScroll)
	
	GUI.LoopScrollRectSetTotalCount(QingLongRankScroll,SumNum2) 
	GUI.LoopScrollRectRefreshCells(QingLongRankScroll)
end

function WuDaoHuiUI.CreateZhuQueRankItem()
	local ZhuQueRankScroll = _gt.GetUI("ZhuQueRankScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(ZhuQueRankScroll);
	local ZhuQueRankItem = GUI.ItemCtrlCreate(ZhuQueRankScroll, "ZhuQueRankItem" .. curCount, "1800600640", 0, 0,660,42)
	local ZhuQue_Sp = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Sp", "1", -240, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(ZhuQue_Sp, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(ZhuQue_Sp,colorWhite)
	GUI.StaticSetFontSize(ZhuQue_Sp, 24)
	GUI.StaticSetAlignment(ZhuQue_Sp, TextAnchor.MiddleCenter)
	local ZhuQue_Name = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Name", "测试", -130, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(ZhuQue_Name, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(ZhuQue_Name,colorWhite)
	GUI.StaticSetFontSize(ZhuQue_Name, 24)
	GUI.StaticSetAlignment(ZhuQue_Name, TextAnchor.MiddleCenter)
	local ZhuQue_Officer = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Officer", "暂无", 0, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(ZhuQue_Officer, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(ZhuQue_Officer,colorWhite)
	GUI.StaticSetFontSize(ZhuQue_Officer, 24)
	GUI.StaticSetAlignment(ZhuQue_Officer, TextAnchor.MiddleCenter)
	local ZhuQue_Score = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Score", "0", 120, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(ZhuQue_Score, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(ZhuQue_Score,colorWhite)
	GUI.StaticSetFontSize(ZhuQue_Score, 24)
	GUI.StaticSetAlignment(ZhuQue_Score, TextAnchor.MiddleCenter)
	local ZhuQue_Rate = GUI.CreateStatic(ZhuQueRankItem, "ZhuQue_Rate", "0/0", 240, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(ZhuQue_Rate, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(ZhuQue_Rate,colorWhite)
	GUI.StaticSetFontSize(ZhuQue_Rate, 24)
	GUI.StaticSetAlignment(ZhuQue_Rate, TextAnchor.MiddleCenter)	
	
	local OffLine1 = GUI.ImageCreate(ZhuQueRankItem, "OffLine1", "1800604360", -290, 0, true)
    UILayout.SetAnchorAndPivot(OffLine1, UIAnchor.Center, UIAroundPivot.Center)
	
	return ZhuQueRankItem;	
end

function WuDaoHuiUI.RefreshZhuQueRankScroll(parameter)
	parameter = string.split(parameter, "#")
	local guid = parameter[1];
	local index = tonumber(parameter[2])
	local item = GUI.GetByGuid(guid)
	local Sp = GUI.GetChild(item,"ZhuQue_Sp")
	local Name = GUI.GetChild(item,"ZhuQue_Name")
	local Officer = GUI.GetChild(item,"ZhuQue_Officer")
	local Score = GUI.GetChild(item,"ZhuQue_Score")
	local Rate = GUI.GetChild(item,"ZhuQue_Rate")
	local Img = GUI.GetChild(item,"OffLine1")
	index = index +1 
	
	GUI.StaticSetText(Sp,tostring(index))
	GUI.StaticSetText(Name,WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][index].name)
	GUI.StaticSetText(Officer,WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][index].officer)
	GUI.StaticSetText(Score,WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][index].score)
	if WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][index].WinNum ~= nil then
		GUI.StaticSetText(Rate,WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][index].WinNum.."/"..WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][index].FightNum)
	else
		GUI.StaticSetText(Rate,"0/0")
	end
	
	if WuDaoHuiUI.FightInfo["RedTeam"]["PlayerList"][index].InMap == 1 then
		-- GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon,"1800600620")
		GUI.SetColor(Sp,colorWhite)
		GUI.SetColor(Name,colorWhite)
		GUI.SetColor(Officer,colorWhite)
		GUI.SetColor(Score,colorWhite)
		GUI.SetColor(Rate,colorWhite)
		GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon,0,0,700,42)		
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border,"1800600620")
		GUI.SetVisible(Img,false)
	else
		GUI.SetColor(Sp,colorGary)
		GUI.SetColor(Name,colorGary)
		GUI.SetColor(Officer,colorGary)
		GUI.SetColor(Score,colorGary)
		GUI.SetColor(Rate,colorGary)
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon,"1800600620")
		GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon,0,-2,700,40)	
		GUI.SetVisible(Img,true)
	
	end
	
end

function WuDaoHuiUI.CreateQingLongRankItem()
	local QingLongRankScroll = _gt.GetUI("QingLongRankScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(QingLongRankScroll);
	local QingLongRankItem = GUI.ItemCtrlCreate(QingLongRankScroll, "QingLongRankItem" .. curCount, "1800600640", 0, 0,660,42)	
	local QingLong_Sp = GUI.CreateStatic(QingLongRankItem, "QingLong_Sp", "1", -240, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(QingLong_Sp, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(QingLong_Sp,colorWhite)
	GUI.StaticSetFontSize(QingLong_Sp, 24)
	GUI.StaticSetAlignment(QingLong_Sp, TextAnchor.MiddleCenter)
	local QingLong_Name = GUI.CreateStatic(QingLongRankItem, "QingLong_Name", "测试", -130, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(QingLong_Name, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(QingLong_Name,colorWhite)
	GUI.StaticSetFontSize(QingLong_Name, 24)
	GUI.StaticSetAlignment(QingLong_Name, TextAnchor.MiddleCenter)
	local QingLong_Officer = GUI.CreateStatic(QingLongRankItem, "QingLong_Officer", "暂无", 0, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(QingLong_Officer, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(QingLong_Officer,colorWhite)
	GUI.StaticSetFontSize(QingLong_Officer, 24)
	GUI.StaticSetAlignment(QingLong_Officer, TextAnchor.MiddleCenter)
	local QingLong_Score = GUI.CreateStatic(QingLongRankItem, "QingLong_Score", "0", 120, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(QingLong_Score, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(QingLong_Score,colorWhite)
	GUI.StaticSetFontSize(QingLong_Score, 24)
	GUI.StaticSetAlignment(QingLong_Score, TextAnchor.MiddleCenter)
	local QingLong_Rate = GUI.CreateStatic(QingLongRankItem, "QingLong_Rate", "0/0", 240, 1, 150, 50, "system")
	UILayout.SetAnchorAndPivot(QingLong_Rate, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(QingLong_Rate,colorWhite)
	GUI.StaticSetFontSize(QingLong_Rate, 24)
	GUI.StaticSetAlignment(QingLong_Rate, TextAnchor.MiddleCenter)

	local OffLine2 = GUI.ImageCreate(QingLongRankItem, "OffLine2", "1800604360", -290, 0, true)
    UILayout.SetAnchorAndPivot(OffLine2, UIAnchor.Center, UIAroundPivot.Center)
	
	return QingLongRankItem;	
end

function WuDaoHuiUI.RefreshQingLongRankScroll(parameter)
	parameter = string.split(parameter, "#")
	local guid = parameter[1];
	local index = tonumber(parameter[2])
	local item = GUI.GetByGuid(guid)
	local Sp = GUI.GetChild(item,"QingLong_Sp")
	local Name = GUI.GetChild(item,"QingLong_Name")
	local Officer = GUI.GetChild(item,"QingLong_Officer")
	local Score = GUI.GetChild(item,"QingLong_Score")
	local Rate = GUI.GetChild(item,"QingLong_Rate")
	local Img = GUI.GetChild(item,"OffLine2")
	index = index +1 
	
	GUI.StaticSetText(Sp,tostring(index))
	GUI.StaticSetText(Name,WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][index].name)
	GUI.StaticSetText(Officer,WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][index].officer)
	GUI.StaticSetText(Score,WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][index].score)
	if WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][index].WinNum ~= nil then
		GUI.StaticSetText(Rate,WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][index].WinNum.."/"..WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][index].FightNum)
	else
		GUI.StaticSetText(Rate,"0/0")
	end
	
	if WuDaoHuiUI.FightInfo["BlueTeam"]["PlayerList"][index].InMap == 1 then
		-- GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon,"1800600620")
		GUI.SetColor(Sp,colorWhite)
		GUI.SetColor(Name,colorWhite)
		GUI.SetColor(Officer,colorWhite)
		GUI.SetColor(Score,colorWhite)
		GUI.SetColor(Rate,colorWhite)
		GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon,0,0,700,42)		
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border,"1800600620")
		GUI.SetVisible(Img,false)
	else
		GUI.SetColor(Sp,colorGary)
		GUI.SetColor(Name,colorGary)
		GUI.SetColor(Officer,colorGary)
		GUI.SetColor(Score,colorGary)
		GUI.SetColor(Rate,colorGary)
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon,"1800600620")
		GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon,0,-2,700,40)	
		GUI.SetVisible(Img,true)
	
	end
	
end