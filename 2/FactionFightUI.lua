local FactionFightUI = {
}

_G.FactionFightUI = FactionFightUI
local _gt = UILayout.NewGUIDUtilTable()


-- local LabelList = {
-- }

--字体颜色
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)


function FactionFightUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("FactionFightUI", "FactionFightUI", 0, 0);
	GUI.SetVisible(panel, false)
    UILayout.SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "帮派竞技", "FactionFightUI", "OnClose", _gt)
    -- UILayout.CreateRightTab(LabelList, "FactionFightUI")
end

function FactionFightUI.OnShow(parameter)
	test("OnShowOnShowOnShowOnShowOnShowOnShowOnShow")
	local wnd = GUI.GetWnd("FactionFightUI")
	local FactionData = LD.GetGuildData()
    if FactionData.guild ~= nil and tostring(FactionData.guild.guid) ~= "0" then
		if wnd then
			GUI.SetVisible(wnd, true)
			CL.SendNotify(NOTIFY.SubmitForm, "FormBangZhan", "Get_Server_Data")
		end
    else
		CL.SendNotify(NOTIFY.ShowBBMsg, "您还没有帮派")		
        -- FactionFightUI.OnClose()
    end
end

function FactionFightUI.Register()
	CL.RegisterMessage(GM.FightStateNtf, "FactionFightUI", "OnClose")
end

function FactionFightUI.OnClose()
	GUI.Destroy("FactionFightUI")
	if FactionFightUI.FactionFightTimer  then
	test("FactionFightUI.FactionFightTimer")
	FactionFightUI.FactionFightTimer:Reset(FactionFightUI.OnFactionFightTime,1,-1)
	FactionFightUI.FactionFightTimer:Stop()
	end
end

function FactionFightUI.Refresh()
	FactionFightUI.CreateFactionFightPage()
	FactionFightUI.RefreshFactionFightPage()
	FactionFightUI.RefreshSearchStr()
end


function FactionFightUI.CreateFactionFightPage()
	local panelBg = GUI.Get("FactionFightUI/panelBg")
	
	local FactionFightGroup = GUI.Get("FactionFightUI/panelBg/FactionFightGroup")
	if FactionFightGroup ~= nil then
		return
	end
	local FactionFightGroup = GUI.GroupCreate(panelBg, "FactionFightGroup", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
	_gt.BindName(FactionFightGroup,"FactionFightGroup")
	
	--上方时间小标题
	local FactionFightTimeTitle0 = GUI.CreateStatic(FactionFightGroup, "FactionFightTimeTitle0", "上次竞技排名", 0, 55, 300, 30, "system")
	UILayout.SetAnchorAndPivot(FactionFightTimeTitle0, UIAnchor.Top, UIAroundPivot.Top)
	GUI.SetColor(FactionFightTimeTitle0, colorDark)
	GUI.StaticSetFontSize(FactionFightTimeTitle0, 24)
	GUI.StaticSetAlignment(FactionFightTimeTitle0, TextAnchor.MiddleCenter)
	_gt.BindName(FactionFightTimeTitle0,"FactionFightTimeTitle0")
	
	
	local FactionFightTimeIcon = GUI.ImageCreate(FactionFightGroup,"FactionFightTimeIcon", "1800408710", -150, 60, false,19,22)
	UILayout.SetAnchorAndPivot(FactionFightTimeIcon, UIAnchor.Top, UIAroundPivot.Top)
	_gt.BindName(FactionFightTimeIcon,"FactionFightTimeIcon")
	
	local FactionFightTimeTitle1 = GUI.CreateStatic(FactionFightGroup, "FactionFightTimeTitle1", "剩余时间", -60, 55, 300, 30, "system")
	UILayout.SetAnchorAndPivot(FactionFightTimeTitle1, UIAnchor.Top, UIAroundPivot.Top)
	GUI.SetColor(FactionFightTimeTitle1, colorDark)
	GUI.StaticSetFontSize(FactionFightTimeTitle1, 24)
	GUI.StaticSetAlignment(FactionFightTimeTitle1, TextAnchor.MiddleCenter)
	_gt.BindName(FactionFightTimeTitle1,"FactionFightTimeTitle1")
	
	local FactionFightTime = GUI.CreateStatic(FactionFightGroup, "FactionFightTime", "21:00:00", 60, 55, 300, 30, "system")
	UILayout.SetAnchorAndPivot(FactionFightTime, UIAnchor.Top, UIAroundPivot.Top)
	GUI.SetColor(FactionFightTime, colorDark)
	GUI.StaticSetFontSize(FactionFightTime, 24)
	GUI.StaticSetAlignment(FactionFightTime, TextAnchor.MiddleCenter)
	_gt.BindName(FactionFightTime,"FactionFightTime")	
	
	--左侧帮派排名
	local FactionRankBg = GUI.ImageCreate(FactionFightGroup,"FactionRankBg", "1800400200", 75, 90, false, 515, 360)
    UILayout.SetAnchorAndPivot(FactionRankBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	
	--帮派排名标题背景
	local FactionTitleBg = GUI.ImageCreate(FactionRankBg,"FactionTitleBg", "1800700070", 0, 2,  false, 510, 35)
	UILayout.SetAnchorAndPivot(FactionTitleBg, UIAnchor.Top, UIAroundPivot.Top)
	
	--帮派排名名单
	local FactionRankScroll = GUI.LoopScrollRectCreate(FactionRankBg, "FactionRankScroll", 0, -1, 512, 283,
	"FactionFightUI", "CreateFactionRankItem", "FactionFightUI", "RefreshFactionRankScroll", 0, false, Vector2.New(506, 43), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetAnchorAndPivot(FactionRankScroll, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(FactionRankScroll, "FactionRankScroll")
	
	--帮派当前名次
	local FactionCurrentRank = GUI.ImageCreate(FactionRankBg,"FactionCurrentRank" , "1800600940", 0, -1,false,510,54)
	UILayout.SetAnchorAndPivot(FactionCurrentRank, UIAnchor.Bottom, UIAroundPivot.Bottom)
	
	local FactionCurrentRank_Sp=GUI.CreateStatic(FactionCurrentRank,"FactionCurrentRank_Sp","10",-35,0,200,50)
	UILayout.SetAnchorAndPivot(FactionCurrentRank_Sp, UIAnchor.Left, UIAroundPivot.Left)
	GUI.StaticSetAlignment(FactionCurrentRank_Sp, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(FactionCurrentRank_Sp, 22)
    GUI.SetColor(FactionCurrentRank_Sp,colorDark)
	_gt.BindName(FactionCurrentRank_Sp,"FactionCurrentRank_Sp")
	local FactionCurrentRank_Name=GUI.CreateStatic(FactionCurrentRank,"FactionCurrentRank_Name","啊啊啊啊",-40,0,200,50)
	UILayout.SetAnchorAndPivot(FactionCurrentRank_Name, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(FactionCurrentRank_Name, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(FactionCurrentRank_Name, 22)
    GUI.SetColor(FactionCurrentRank_Name,colorDark)
	_gt.BindName(FactionCurrentRank_Name,"FactionCurrentRank_Name")
	local FactionCurrentRank_Integral=GUI.CreateStatic(FactionCurrentRank,"FactionCurrentRank_Integral","6666",90,0,200,50)
	UILayout.SetAnchorAndPivot(FactionCurrentRank_Integral, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(FactionCurrentRank_Integral, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(FactionCurrentRank_Integral, 22)
    GUI.SetColor(FactionCurrentRank_Integral,colorDark)
	_gt.BindName(FactionCurrentRank_Integral,"FactionCurrentRank_Integral")
	local FactionCurrentRank_Rate=GUI.CreateStatic(FactionCurrentRank,"FactionCurrentRank_Rate","90%",200,0,200,50)
	UILayout.SetAnchorAndPivot(FactionCurrentRank_Rate, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(FactionCurrentRank_Rate, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(FactionCurrentRank_Rate, 22)
    GUI.SetColor(FactionCurrentRank_Rate,colorDark)	
	_gt.BindName(FactionCurrentRank_Rate,"FactionCurrentRank_Rate")
	
	
	
	
	-- 创建标题
    local FactionTitlesInfo =
    {
        {"帮派排名", -10, 150,128},
        {"帮派名称", 135, 150,290},
        {"积分", 270, 150,401},
		{"胜率", 380, 150}
    }

    for i = 1, #FactionTitlesInfo do
        local Title = GUI.CreateStatic(FactionTitleBg,"FactionTitle" .. i, FactionTitlesInfo[i][1], FactionTitlesInfo[i][2], 0,  FactionTitlesInfo[i][3], 35, "system", false, false)
		UILayout.SetAnchorAndPivot(Title, UIAnchor.Left, UIAroundPivot.Left)
        GUI.StaticSetAlignment(Title, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(Title, 22)
        GUI.SetColor(Title,colorDark)
    end
    for i = 1, #FactionTitlesInfo - 1 do
        local CutLine = GUI.ImageCreate(FactionTitleBg,"FactionTitleCut" .. i, "1800600220", FactionTitlesInfo[i][4], 1)
		UILayout.SetAnchorAndPivot(CutLine, UIAnchor.Left, UIAroundPivot.Left)
    end
	
	
	--右侧个人排名
	local PlayerRankBg = GUI.ImageCreate(FactionFightGroup,"PlayerRankBg", "1800400200", -75, 90, false, 515, 360)
	UILayout.SetAnchorAndPivot(PlayerRankBg, UIAnchor.TopRight, UIAroundPivot.TopRight)	
	
	--个人排名标题背景
	local PlayerRankTitleBg = GUI.ImageCreate(PlayerRankBg,"PlayerRankTitleBg", "1800700070", 0, 2,  false, 510, 35)
	UILayout.SetAnchorAndPivot(PlayerRankTitleBg, UIAnchor.Top, UIAroundPivot.Top)
	
	--个人排名名单
	local PlayerRankScroll = GUI.LoopScrollRectCreate(PlayerRankBg, "PlayerRankScroll", 0, -1, 512, 283,
	"FactionFightUI", "CreatePlayerRankItem", "FactionFightUI", "RefreshPlayerRankScroll", 0, false, Vector2.New(506, 43), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetAnchorAndPivot(PlayerRankScroll, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(PlayerRankScroll, "PlayerRankScroll")

	
	--个人当前名次
	local PlayerCurrentRank = GUI.ImageCreate(PlayerRankBg,"PlayerCurrentRank" , "1800600940", 0, -1,false,510,54)
	UILayout.SetAnchorAndPivot(PlayerCurrentRank, UIAnchor.Bottom, UIAroundPivot.Bottom)
	
	local PlayerCurrentRank_Sp=GUI.CreateStatic(PlayerCurrentRank,"PlayerCurrentRank_Sp","1",-35,0,200,50)
	UILayout.SetAnchorAndPivot(PlayerCurrentRank_Sp, UIAnchor.Left, UIAroundPivot.Left)
	GUI.StaticSetAlignment(PlayerCurrentRank_Sp, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(PlayerCurrentRank_Sp, 22)
    GUI.SetColor(PlayerCurrentRank_Sp,colorDark)	
	_gt.BindName(PlayerCurrentRank_Sp,"PlayerCurrentRank_Sp")
	local PlayerCurrentRank_Name=GUI.CreateStatic(PlayerCurrentRank,"PlayerCurrentRank_Name","美女一号",-40,0,200,50)
	UILayout.SetAnchorAndPivot(PlayerCurrentRank_Name, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(PlayerCurrentRank_Name, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(PlayerCurrentRank_Name, 22)
    GUI.SetColor(PlayerCurrentRank_Name,colorDark)
	_gt.BindName(PlayerCurrentRank_Name,"PlayerCurrentRank_Name")
	local PlayerCurrentRank_Integral=GUI.CreateStatic(PlayerCurrentRank,"PlayerCurrentRank_Integral","999",90,0,200,50)
	UILayout.SetAnchorAndPivot(PlayerCurrentRank_Integral, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(PlayerCurrentRank_Integral, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(PlayerCurrentRank_Integral, 22)
    GUI.SetColor(PlayerCurrentRank_Integral,colorDark)
	_gt.BindName(PlayerCurrentRank_Integral,"PlayerCurrentRank_Integral")
	local PlayerCurrentRank_Rate=GUI.CreateStatic(PlayerCurrentRank,"PlayerCurrentRank_Rate","50%",200,0,200,50)
	UILayout.SetAnchorAndPivot(PlayerCurrentRank_Rate, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(PlayerCurrentRank_Rate, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(PlayerCurrentRank_Rate, 22)
    GUI.SetColor(PlayerCurrentRank_Rate,colorDark)	
	_gt.BindName(PlayerCurrentRank_Rate,"PlayerCurrentRank_Rate")
	
	-- 创建标题
    local PlayerRankTitlesInfo =
    {
        {"个人排名", -10, 150,129},
        {"玩家名称", 135, 150,290},
        {"积分", 270, 150,402},
		{"胜率", 380, 150}
    }

    for i = 1, #PlayerRankTitlesInfo do
        local Title = GUI.CreateStatic(PlayerRankTitleBg,"PlayerRankTitle" .. i, PlayerRankTitlesInfo[i][1], PlayerRankTitlesInfo[i][2], 0,  PlayerRankTitlesInfo[i][3], 35, "system", false, false)
		UILayout.SetAnchorAndPivot(Title, UIAnchor.Left, UIAroundPivot.Left)
        GUI.StaticSetAlignment(Title, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(Title, 22)
        GUI.SetColor(Title,colorDark)
    end
    for i = 1, #PlayerRankTitlesInfo - 1 do
        local CutLine = GUI.ImageCreate(PlayerRankTitleBg,"PlayerRankTitleCut" .. i, "1800600220", PlayerRankTitlesInfo[i][4], 1)
		UILayout.SetAnchorAndPivot(CutLine, UIAnchor.Left, UIAroundPivot.Left)
    end	
	--左下角战斗信息显示
	local FightStrBg = GUI.ImageCreate(FactionFightGroup,"FightStrBg", "1800400200", 75, -43, false, 515, 164)
    UILayout.SetAnchorAndPivot(FightStrBg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
	
	-- local FightStrScroll = GUI.ScrollRectCreate(FightStrBg,"FightStrScroll",0,-1,512,164,0,false,Vector2.New(506, 43),UIAroundPivot.Top, UIAnchor.Top,1,false)
	-- UILayout.SetAnchorAndPivot(FightStrScroll, UIAnchor.Center, UIAroundPivot.Center)
	-- _gt.BindName(FightStrScroll, "FightStrScroll")	
	
	local FightStrScrollWnd = GUI.ScrollRectCreate(FightStrBg,"FightStrScrollWnd", 0, -1, 512, 125, 0, false, Vector2.New(420,30),  UIAroundPivot.Left, UIAnchor.Left,1)
    GUI.SetAnchor(FightStrScrollWnd, UIAnchor.Center)
    GUI.SetPivot(FightStrScrollWnd, UIAroundPivot.Center)
    GUI.ScrollRectSetChildAnchor(FightStrScrollWnd, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(FightStrScrollWnd, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(FightStrScrollWnd, Vector2.New(1, 1))
	_gt.BindName(FightStrScrollWnd,"FightStrScrollWnd")
	
	--右下角tip
	local FirstWinBtn = GUI.ButtonCreate(FactionFightGroup,"FirstWinBtn","1800601260",135,173,Transition.None,"",250,100,false)
	UILayout.SetAnchorAndPivot(FirstWinBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(FirstWinBtn, UCE.PointerClick, "FactionFightUI", "OnFirstWinClick")
	_gt.BindName(FirstWinBtn,"FirstWinBtn")

	local FirstWinIcon = GUI.ImageCreate( FirstWinBtn,"firstWinIcon","1900030700",-77,0,false,60,60)
	UILayout.SetAnchorAndPivot(FirstWinIcon, UIAnchor.Center, UIAroundPivot.Center)
	
	local FirstWinText=GUI.CreateStatic(FirstWinBtn,"FirstWinText","首胜奖励",15,0,130,50)
	UILayout.SetAnchorAndPivot(FirstWinText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(FirstWinText, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(FirstWinText, 22)
    GUI.SetColor(FirstWinText,colorDark)
	
	local ComboWinBtn = GUI.ButtonCreate(FactionFightGroup,"ComboWinBtn","1800601260",395,173,Transition.None,"",250,100,false)
	UILayout.SetAnchorAndPivot(ComboWinBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(ComboWinBtn, UCE.PointerClick, "FactionFightUI", "OnComboWinClick")
	_gt.BindName(ComboWinBtn,"ComboWinBtn")

	local ComboWinIcon = GUI.ImageCreate( ComboWinBtn,"ComboWinIcon","1900030690",-77,0,false,60,60)
	UILayout.SetAnchorAndPivot(ComboWinIcon, UIAnchor.Center, UIAroundPivot.Center)
	
	local ComboWinText=GUI.CreateStatic(ComboWinBtn,"ComboWinText","五连胜奖励",15,0,130,50)
	UILayout.SetAnchorAndPivot(ComboWinText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(ComboWinText, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(ComboWinText, 22)
    GUI.SetColor(ComboWinText,colorDark)
	
	--自动匹配的按钮
	local AutoMatchToggle = GUI.CheckBoxCreate (FactionFightGroup,"AutoMatchToggle", "1800607150", "1800607151", 30, 258,Transition.ColorTint, false,40,40)
	UILayout.SetAnchorAndPivot(AutoMatchToggle, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(AutoMatchToggle, UCE.PointerClick, "FactionFightUI", "OnAutoMatchToggleClick")
	_gt.BindName(AutoMatchToggle,"AutoMatchToggle")
	
	local AutoMatchText=GUI.CreateStatic(FactionFightGroup,"AutoMatchText","自动匹配",110,258,130,50)
	UILayout.SetAnchorAndPivot(AutoMatchText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(AutoMatchText, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(AutoMatchText, 22)
    GUI.SetColor(AutoMatchText,colorDark)
	
	--匹配按钮
	local StartMatchBtn = GUI.ButtonCreate(FactionFightGroup,"StartMatchBtn","1800602090",256,256, Transition.ColorTint,"",150,50,false)
	UILayout.SetAnchorAndPivot(StartMatchBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(StartMatchBtn, UCE.PointerClick, "FactionFightUI", "OnStartMatchBtnClick")
	_gt.BindName(StartMatchBtn,"StartMatchBtn")
	local StartMatchBtnText = GUI.CreateStatic(StartMatchBtn,"StartMatchBtnText", "开始匹配", 0, 0, 160, 47, "system", true)
	UILayout.SetAnchorAndPivot(StartMatchBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(StartMatchBtnText, 22)
    GUI.StaticSetAlignment(StartMatchBtnText, TextAnchor.MiddleCenter)
    GUI.SetColor(StartMatchBtnText,colorWhite)
    GUI.SetIsOutLine(StartMatchBtnText, true)
    GUI.SetOutLine_Color(StartMatchBtnText, colorOutline)
    GUI.SetOutLine_Distance(StartMatchBtnText, 1)
	_gt.BindName(StartMatchBtnText,"StartMatchBtnText")

	--便捷组队按钮
	local MakeTeamBtn = GUI.ButtonCreate(FactionFightGroup,"MakeTeamBtn","1800602090",448,256, Transition.ColorTint,"",150,50,false)
	UILayout.SetAnchorAndPivot(MakeTeamBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(MakeTeamBtn, UCE.PointerClick, "FactionFightUI", "OnMakeTeamBtnClick")
	_gt.BindName(MakeTeamBtn,"MakeTeamBtn")
	local MakeTeamBtnText = GUI.CreateStatic(MakeTeamBtn,"MakeTeamBtnText", "便捷组队", 0, 0, 160, 47, "system", true)
	UILayout.SetAnchorAndPivot(MakeTeamBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(MakeTeamBtnText, 22)
    GUI.StaticSetAlignment(MakeTeamBtnText, TextAnchor.MiddleCenter)
    GUI.SetColor(MakeTeamBtnText,colorWhite)
    GUI.SetIsOutLine(MakeTeamBtnText, true)
    GUI.SetOutLine_Color(MakeTeamBtnText, colorOutline)
    GUI.SetOutLine_Distance(MakeTeamBtnText, 1)
	
	
	local num = #(string.split(FactionFightUI.serverData.fight_str, ";"))-1
	-- test(num)
	for i = 1, num do
        FactionFightUI.CreateFightStrItem(i, FightStrScrollWnd)
    end

end


--便捷组队
function FactionFightUI.OnMakeTeamBtnClick()
	if FactionFightUI.serverData.act_id ~= nil  then
    	local teamSate = LD.GetRoleInTeamState(0)
    	if teamSate == 0 then
      		GUI.OpenWnd("TeamPlatformPersonalUI","teamId:"..tostring(FactionFightUI.serverData.act_id));
    	elseif teamSate == 2 then
      		GUI.OpenWnd("TeamPanelUI");
      		GUI.OpenWnd("TeamPlatformUI","teamId:"..tostring(FactionFightUI.serverData.act_id));
    	else
			CL.SendNotify(NOTIFY.ShowBBMsg, "只有队长才能发布招募信息")
    	end
  	end
end

function FactionFightUI.RefreshFactionFightPage()
	local FactionFightTimeTitle0 = _gt.GetUI("FactionFightTimeTitle0")
	local FactionFightTimeTitle1 = _gt.GetUI("FactionFightTimeTitle1")
	local FactionFightTimeIcon = _gt.GetUI("FactionFightTimeIcon")
	local FactionFightTime = _gt.GetUI("FactionFightTime")
	local FactionRankScroll = _gt.GetUI("FactionRankScroll")
	local PlayerRankScroll = _gt.GetUI("PlayerRankScroll")
	-- local AutoMatchToggle = _gt.GetUI("AutoMatchToggle")
	FactionFightUI.FactionFightTimer = Timer.New(FactionFightUI.OnFactionFightTime,1,-1)

	
	--时间显示
	if FactionFightUI.serverData.openState ==1 then
		GUI.SetVisible(FactionFightTimeTitle0,false)
		GUI.SetVisible(FactionFightTimeTitle1,true)
		GUI.SetVisible(FactionFightTimeIcon,true)
		GUI.SetVisible(FactionFightTime,true)
		
		FactionFightUI.FactionFightTimer:Start()

		-- test(FactionFightUI.serverData.end_time)
		-- test(CL.GetServerTickCount())
		-- test(type(CL.GetServerTickCount()))
	
	else
		FactionFightUI.FactionFightTimer:Stop()
		FactionFightUI.FactionFightTimer:Reset(FactionFightUI.OnFactionFightTime,1,-1)
		GUI.SetVisible(FactionFightTimeTitle0,true)
		GUI.SetVisible(FactionFightTimeTitle1,false)
		GUI.SetVisible(FactionFightTimeIcon,false)
		GUI.SetVisible(FactionFightTime,false)		
	end
	
	
	--给排名表存入一个名次
	for i = 1, #FactionFightUI.serverData.guild_rank_list do
		 FactionFightUI.serverData.guild_rank_list[i][1] = i
	end
	
	for i = 1, #FactionFightUI.serverData.player_rank_list do
		 FactionFightUI.serverData.player_rank_list[i][1] = i
	end
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(FactionFightUI.search_state[Act_BangZhan_Search_State]))
	
	
	--个人帮派当前排名
	local FactionCurrentRank_Sp = _gt.GetUI("FactionCurrentRank_Sp")
	local FactionCurrentRank_Name = _gt.GetUI("FactionCurrentRank_Name")
	local FactionCurrentRank_Integral = _gt.GetUI("FactionCurrentRank_Integral")
	local FactionCurrentRank_Rate = _gt.GetUI("FactionCurrentRank_Rate")
	
	GUI.StaticSetText(FactionCurrentRank_Sp,FactionFightUI.serverData.my_guild_rank[1])
	GUI.StaticSetText(FactionCurrentRank_Name,FactionFightUI.serverData.my_guild_rank[3])
	GUI.StaticSetText(FactionCurrentRank_Integral,FactionFightUI.serverData.my_guild_rank[2])
	GUI.StaticSetText(FactionCurrentRank_Rate,FactionFightUI.serverData.my_guild_rank[4])
	
	--个人当前排名
	local PlayerCurrentRank_Sp = _gt.GetUI("PlayerCurrentRank_Sp")
	local PlayerCurrentRank_Name = _gt.GetUI("PlayerCurrentRank_Name")
	local PlayerCurrentRank_Integral = _gt.GetUI("PlayerCurrentRank_Integral")
	local PlayerCurrentRank_Rate = _gt.GetUI("PlayerCurrentRank_Rate")
	
	GUI.StaticSetText(PlayerCurrentRank_Sp,FactionFightUI.serverData.my_rank[1])
	GUI.StaticSetText(PlayerCurrentRank_Name,FactionFightUI.serverData.my_rank[3])
	GUI.StaticSetText(PlayerCurrentRank_Integral,FactionFightUI.serverData.my_rank[2])
	GUI.StaticSetText(PlayerCurrentRank_Rate,FactionFightUI.serverData.my_rank[4])	
	
	
	--是否领取奖励
	local FirstWinBtn = _gt.GetUI("FirstWinBtn")
	local ComboWinBtn = _gt.GetUI("ComboWinBtn")
	if FactionFightUI.serverData.is_first_reward == 1 then
		GUI.ButtonSetShowDisable(FirstWinBtn,false)
	elseif FactionFightUI.serverData.is_first_reward == 0 then
		GUI.ButtonSetShowDisable(FirstWinBtn,true)
	end
	if FactionFightUI.serverData.is_fifth_reward  == 1 then
		GUI.ButtonSetShowDisable(ComboWinBtn,false)
	elseif FactionFightUI.serverData.is_fifth_reward  == 0 then
		GUI.ButtonSetShowDisable(ComboWinBtn,true)
	end
	
	--刷新排行榜
	local FactionRankNum = tonumber(#FactionFightUI.serverData.guild_rank_list)
	GUI.LoopScrollRectSetTotalCount(FactionRankScroll, FactionRankNum) 
	GUI.LoopScrollRectRefreshCells(FactionRankScroll)
	
	local PlayerRankNum = tonumber(#FactionFightUI.serverData.player_rank_list)
	GUI.LoopScrollRectSetTotalCount(PlayerRankScroll, PlayerRankNum) 
	GUI.LoopScrollRectRefreshCells(PlayerRankScroll)
	
	
	
	--刷新战报
	FactionFightUI.RefreshFightStrItem()
end

--时间显示
function FactionFightUI.OnFactionFightTime()
	local FactionFightTime = _gt.GetUI("FactionFightTime")
	-- test(FactionFightUI.serverData.end_time)
	-- test(type(FactionFightUI.serverData.end_time))
	local day,house,minute,second = GlobalUtils.Get_DHMS2_BySeconds(tonumber(FactionFightUI.serverData.end_time) - CL.GetServerTickCount())
	local Time = house..":"..minute..":"..second
	-- test(Time)
	GUI.StaticSetText(FactionFightTime,Time)
	
end

function FactionFightUI.CreateFactionRankItem()
	local FactionRankScroll = _gt.GetUI("FactionRankScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(FactionRankScroll);
	local FactionRankItem = GUI.ImageCreate(FactionRankScroll, "FactionRankItem" .. curCount, "1800600240", 0, 0, true)
	-- GUI.RegisterUIEvent(FactionRankItem, UCE.PointerClick, "FactionFightUI", "OnBreachSkillItemClick")
	local FactionRankSp = GUI.ImageCreate(FactionRankItem, "FactionRankSp", "1800605110", 50, 0, true)
	UILayout.SetAnchorAndPivot(FactionRankSp, UIAnchor.Left, UIAroundPivot.Left)
	local FactionRankSpText=GUI.CreateStatic(FactionRankItem,"FactionRankSpText","40",-35,0,200,50)
	UILayout.SetAnchorAndPivot(FactionRankSpText, UIAnchor.Left, UIAroundPivot.Left)
	GUI.StaticSetAlignment(FactionRankSpText, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(FactionRankSpText, 22)
    GUI.SetColor(FactionRankSpText,colorDark)
	local FactionName=GUI.CreateStatic(FactionRankItem,"FactionName","天下第二",-40,0,200,50)
	UILayout.SetAnchorAndPivot(FactionName, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(FactionName, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(FactionName, 22)
    GUI.SetColor(FactionName,colorDark)
	local FactionIntegral=GUI.CreateStatic(FactionRankItem,"FactionIntegral","5000",90,0,200,50)
	UILayout.SetAnchorAndPivot(FactionIntegral, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(FactionIntegral, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(FactionIntegral, 22)
    GUI.SetColor(FactionIntegral,colorDark)
	local FactionRate=GUI.CreateStatic(FactionRankItem,"FactionRate","100%",200,0,200,50)
	UILayout.SetAnchorAndPivot(FactionRate, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(FactionRate, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(FactionRate, 22)
    GUI.SetColor(FactionRate,colorDark)	
	return FactionRankItem;
end

function FactionFightUI.RefreshFactionRankScroll(parameter)
	parameter = string.split(parameter, "#")
	local guid = parameter[1];
	local index = tonumber(parameter[2])
	local item = GUI.GetByGuid(guid)
	local FactionRankSp = GUI.GetChild(item,"FactionRankSp")
	local FactionRankSpText = GUI.GetChild(item,"FactionRankSpText")
	local FactionName = GUI.GetChild(item,"FactionName")
	local FactionIntegral = GUI.GetChild(item,"FactionIntegral")
	local FactionRate = GUI.GetChild(item,"FactionRate")
	index = index+1
	--显示不同颜色的格子
	if index%2 ~= 0 then
	GUI.ImageSetImageID(item,"1800600230")
	else
	GUI.ImageSetImageID(item,"1800600240")
	end
	
	--显示帮派排名数据
	local Sp = FactionFightUI.serverData.guild_rank_list[index][1]
	if Sp == 1 then
		GUI.SetVisible(FactionRankSp,true)
		GUI.SetVisible(FactionRankSpText,false)
		GUI.ImageSetImageID(FactionRankSp,"1800605110")
	elseif Sp == 2 then
		GUI.SetVisible(FactionRankSp,true)
		GUI.SetVisible(FactionRankSpText,false)	
		GUI.ImageSetImageID(FactionRankSp,"1800605120")
	elseif Sp == 3 then
		GUI.SetVisible(FactionRankSp,true)
		GUI.SetVisible(FactionRankSpText,false)	
		GUI.ImageSetImageID(FactionRankSp,"1800605130")
	else
		GUI.SetVisible(FactionRankSp,false)
		GUI.SetVisible(FactionRankSpText,true)	
		GUI.StaticSetText(FactionRankSpText,tostring(Sp))
	end
	
	local Name =FactionFightUI.serverData.guild_rank_list[index][3]
	GUI.StaticSetText(FactionName,Name)
	
	local Integral = FactionFightUI.serverData.guild_rank_list[index][2]
	GUI.StaticSetText(FactionIntegral,Integral)
	
	local Rate = FactionFightUI.serverData.guild_rank_list[index][4] 
	GUI.StaticSetText(FactionRate,Rate)
	
	-- if index 
end

function FactionFightUI.CreatePlayerRankItem()
	local PlayerRankScroll = _gt.GetUI("PlayerRankScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(PlayerRankScroll)
	local PlayerRankItem = GUI.ImageCreate(PlayerRankScroll, "PlayerRankItem" .. curCount, "1800600240", 0, 0, true)
	-- GUI.RegisterUIEvent(FactionRankItem, UCE.PointerClick, "FactionFightUI", "OnBreachSkillItemClick")
	local PlayerRankSp = GUI.ImageCreate(PlayerRankItem, "PlayerRankSp", "1800605110", 50, 0, true)
	 UILayout.SetAnchorAndPivot(PlayerRankSp, UIAnchor.Left, UIAroundPivot.Left)
	local PlayerRankSpText=GUI.CreateStatic(PlayerRankItem,"PlayerRankSpText","40",-35,0,200,50)
	UILayout.SetAnchorAndPivot(PlayerRankSpText, UIAnchor.Left, UIAroundPivot.Left)
	GUI.StaticSetAlignment(PlayerRankSpText, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(PlayerRankSpText, 22)
    GUI.SetColor(PlayerRankSpText,colorDark)
	local PlayerName=GUI.CreateStatic(PlayerRankItem,"PlayerName","帅哥一号",-40,0,200,50)
	UILayout.SetAnchorAndPivot(PlayerName, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(PlayerName, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(PlayerName, 22)
    GUI.SetColor(PlayerName,colorDark)
	local PlayerIntegral=GUI.CreateStatic(PlayerRankItem,"PlayerIntegral","999",90,0,200,50)
	UILayout.SetAnchorAndPivot(PlayerIntegral, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(PlayerIntegral, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(PlayerIntegral, 22)
    GUI.SetColor(PlayerIntegral,colorDark)
	local PlayerRate=GUI.CreateStatic(PlayerRankItem,"PlayerRate","50%",200,0,200,50)
	UILayout.SetAnchorAndPivot(PlayerRate, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(PlayerRate, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(PlayerRate, 22)
    GUI.SetColor(PlayerRate,colorDark)	
	return PlayerRankItem;
end

function FactionFightUI.RefreshPlayerRankScroll(parameter)
	parameter = string.split(parameter, "#")
	local guid = parameter[1];
	local index = tonumber(parameter[2])
	local item = GUI.GetByGuid(guid)
	local PlayerRankSp = GUI.GetChild(item,"PlayerRankSp")
	local PlayerRankSpText = GUI.GetChild(item,"PlayerRankSpText")
	local PlayerName = GUI.GetChild(item,"PlayerName")
	local PlayerIntegral = GUI.GetChild(item,"PlayerIntegral")
	local PlayerRate = GUI.GetChild(item,"PlayerRate")
	index = index+1
	--显示不同颜色的格子
	if index%2 ~= 0 then
	GUI.ImageSetImageID(item,"1800600230")
	else
	GUI.ImageSetImageID(item,"1800600240")
	end
	
	--显示帮派排名数据
	local Sp = FactionFightUI.serverData.player_rank_list[index][1]
	if Sp == 1 then
		GUI.SetVisible(PlayerRankSp,true)
		GUI.SetVisible(PlayerRankSpText,false)
		GUI.ImageSetImageID(PlayerRankSp,"1800605110")
	elseif Sp == 2 then
		GUI.SetVisible(PlayerRankSp,true)
		GUI.SetVisible(PlayerRankSpText,false)	
		GUI.ImageSetImageID(PlayerRankSp,"1800605120")
	elseif Sp == 3 then
		GUI.SetVisible(PlayerRankSp,true)
		GUI.SetVisible(PlayerRankSpText,false)	
		GUI.ImageSetImageID(PlayerRankSp,"1800605130")
	else
		GUI.SetVisible(PlayerRankSp,false)
		GUI.SetVisible(PlayerRankSpText,true)	
		GUI.StaticSetText(PlayerRankSpText,tostring(Sp))
	end
	
	local Name =FactionFightUI.serverData.player_rank_list[index][3]
	GUI.StaticSetText(PlayerName,Name)
	
	local Integral = FactionFightUI.serverData.player_rank_list[index][2]
	GUI.StaticSetText(PlayerIntegral,Integral)
	
	local Rate = FactionFightUI.serverData.player_rank_list[index][4] 
	GUI.StaticSetText(PlayerRate,Rate)
end

--刷新按钮显示
function FactionFightUI.RefreshSearchStr()
	local StartMatchBtn = _gt.GetUI("StartMatchBtn")
	local MakeTeamBtn = _gt.GetUI("MakeTeamBtn")
	local StartMatchBtnText = _gt.GetUI("StartMatchBtnText")
	local AutoMatchToggle = _gt.GetUI("AutoMatchToggle")
	--自动匹配按钮刷新
	if FactionFightUI.search_state == 2 then
		GUI.CheckBoxSetCheck(AutoMatchToggle,true)
	else
		GUI.CheckBoxSetCheck(AutoMatchToggle,false)
	end
	
	if FactionFightUI.serverData.openState == 1 then
		GUI.ButtonSetShowDisable(StartMatchBtn,true)
		GUI.ButtonSetShowDisable(MakeTeamBtn,true)			
		if FactionFightUI.search_state == 2 then
			GUI.StaticSetText(StartMatchBtnText,"匹配中...")
			GUI.ButtonSetShowDisable(StartMatchBtn,false)
		else
			GUI.ButtonSetShowDisable(StartMatchBtn,true)
			if FactionFightUI.search_state == 0 then
				GUI.StaticSetText(StartMatchBtnText,"开始匹配")
			elseif FactionFightUI.search_state == 1 then
				GUI.StaticSetText(StartMatchBtnText,"取消匹配")
			end
		end
	else
		GUI.ButtonSetShowDisable(StartMatchBtn,false)
		GUI.ButtonSetShowDisable(MakeTeamBtn,false)			
	end
end
--创建战报
function FactionFightUI.CreateFightStrItem(index, parent)
    if parent == nil then
        return
    end
	
	FightStrText = GUI.CreateStatic( parent,"FightStrText"..index, "aaaaaa", 0, 0,130,50)
	GUI.StaticSetFontSize(FightStrText,22)
	GUI.SetColor(FightStrText,colorDark)
	
	FightWinStrText = GUI.CreateStatic( parent,"FightWinStrText"..index, "bbbbb", 0, 0,130,50)
	GUI.StaticSetFontSize(FightWinStrText,22)
	GUI.SetColor(FightWinStrText,colorDark)

end

--刷新战报
function FactionFightUI.RefreshFightStrItem()
	local FightStrScrollWnd = _gt.GetUI("FightStrScrollWnd")
	local fight_str = string.split(FactionFightUI.serverData.fight_str, ";")
	local Count = #fight_str -1
	for i= 1 , Count do
		local Fight_Str = string.split(fight_str[i], ",")
		local StrText1 = GUI.GetChild(FightStrScrollWnd,"FightStrText"..i)
		local StrText2 = GUI.GetChild(FightStrScrollWnd,"FightWinStrText"..i)
		local Name = tostring(Fight_Str[3])
		local WinIf = tostring(Fight_Str[1])
		-- test(Name)
		-- print(Fight_Str)
		if WinIf == "1" then
			local Num = Fight_Str[2]
			GUI.StaticSetText(StrText1,"你战胜了 "..Name.." 的队伍")
			GUI.StaticSetText(StrText2,"当前连胜 "..Num.." 次")
		elseif WinIf == "0" then
			GUI.StaticSetText(StrText1,"你输给了 "..Name.." 的队伍")
			GUI.StaticSetText(StrText2,"你的连胜被终结")
		end
	end
	

end
--当点击自动匹配
function FactionFightUI.OnAutoMatchToggleClick()
	if FactionFightUI.serverData.openState == 1 then
		CL.SendNotify(NOTIFY.SubmitForm, "FormBangZhan", "Search_Always")
	else
		CL.SendNotify(NOTIFY.ShowBBMsg, "活动未开始")
		FactionFightUI.RefreshSearchStr()
	end
end

--当点击匹配按钮
function FactionFightUI.OnStartMatchBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm, "FormBangZhan", "Search")
end

--当点击查看首胜奖励
function FactionFightUI.OnFirstWinClick()
	local Tips = GUI.TipsCreate(GUI.Get("FactionFightUI/panelBg"), "Tips", 205, 145, 420, 80)
	GUI.SetIsRemoveWhenClick(Tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(Tips),false)
	local level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	local num1 = assert(loadstring(" local level = "..level.." "..FactionFightUI.serverData.first_reward["Bind_Gold"]))()
	local num2 = assert(loadstring(""..FactionFightUI.serverData.first_reward["Contribution"]))()
	local num3 = assert(loadstring(""..FactionFightUI.serverData.first_reward["Exp"]))()
	local num4 = assert(loadstring(""..FactionFightUI.serverData.first_reward["GuildFund"]))()
	local item = FactionFightUI.serverData.first_reward["ItemList"][1]
	local itemDB = DB.GetOnceItemByKey2(item)
	local itemnum = FactionFightUI.serverData.first_reward["ItemList"][3]
	local tipstext = GUI.CreateStatic(Tips,"tipstext","当前奖励为：",35,-73,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext,22)
	local tipstext2 = GUI.CreateStatic(Tips,"tipstext2","银币 X "..num1,35,-45,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext2,22)
	local tipstext3 = GUI.CreateStatic(Tips,"tipstext3","帮贡 X "..num2,35,-17,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext3,22)
	local tipstext4 = GUI.CreateStatic(Tips,"tipstext4","经验 X "..num3,35,11,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext4,22)
	local tipstext5 = GUI.CreateStatic(Tips,"tipstext5","帮派资金 X "..num4,35,39,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext5,22)
	local tipstext6 = GUI.CreateStatic(Tips,"tipstext6",itemDB.Name.." X "..itemnum,35,67,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext6,22)
end

--当点击查看第五次的奖励
function FactionFightUI.OnComboWinClick()
	local Tips = GUI.TipsCreate(GUI.Get("FactionFightUI/panelBg"), "Tips", 205, 145, 420, 80)
	GUI.SetIsRemoveWhenClick(Tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(Tips),false)
	local level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	local num1 = assert(loadstring(" local level = "..level.." "..FactionFightUI.serverData.fifth_reward ["Bind_Gold"]))()
	local num2 = assert(loadstring(""..FactionFightUI.serverData.fifth_reward ["Contribution"]))()
	local num3 = assert(loadstring(""..FactionFightUI.serverData.fifth_reward ["Exp"]))()
	local num4 = assert(loadstring(""..FactionFightUI.serverData.fifth_reward ["GuildFund"]))()
	local item = FactionFightUI.serverData.fifth_reward ["ItemList"][1]
	local itemDB = DB.GetOnceItemByKey2(item)
	local itemnum = FactionFightUI.serverData.fifth_reward ["ItemList"][3]
	local tipstext = GUI.CreateStatic(Tips,"tipstext","当前奖励为：",35,-73,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext,22)
	local tipstext2 = GUI.CreateStatic(Tips,"tipstext2","银币 X "..num1,35,-45,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext2,22)
	local tipstext3 = GUI.CreateStatic(Tips,"tipstext3","帮贡 X "..num2,35,-17,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext3,22)
	local tipstext4 = GUI.CreateStatic(Tips,"tipstext4","经验 X "..num3,35,11,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext4,22)
	local tipstext5 = GUI.CreateStatic(Tips,"tipstext5","帮派资金 X "..num4,35,39,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext5,22)
	local tipstext6 = GUI.CreateStatic(Tips,"tipstext6",itemDB.Name.." X "..itemnum,35,67,440,120,"system", true)
	GUI.StaticSetFontSize(tipstext6,22)
end