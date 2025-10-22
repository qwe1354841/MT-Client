local ShiTuRegisterUI = {}

_G.ShiTuRegisterUI = ShiTuRegisterUI
local _gt = UILayout.NewGUIDUtilTable()

--颜色
local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)

ShiTuRegisterUI.CurSelectPage = 1
local TeacherRosterLastNum = 0
local PupilRosterLastNum = 0
function ShiTuRegisterUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("ShiTuRegisterUI", "ShiTuRegisterUI", 0, 0);
	GUI.SetVisible(panel, false)
    UILayout.SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "师徒登记", "ShiTuRegisterUI", "OnCloseBtnClick", _gt)
	local TeacherRosterBtn = GUI.ButtonCreate(panelBg,"TeacherRosterBtn","1800402180",80,62,Transition.ColorTint,"",155,46,false)
	UILayout.SetAnchorAndPivot(TeacherRosterBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.SetData(TeacherRosterBtn, "index", 1)
	GUI.RegisterUIEvent(TeacherRosterBtn, UCE.PointerClick, "ShiTuRegisterUI", "OnTabBtnClick")
	local BtnSprite1 = GUI.ImageCreate( TeacherRosterBtn, "BtnSprite1", "1800402181", 0, 0, false, 155, 46)
    UILayout.SetAnchorAndPivot(BtnSprite1, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(BtnSprite1,"BtnSprite1")
	GUI.SetVisible(BtnSprite1,true)
	local TeacherRosterText= GUI.CreateStatic(TeacherRosterBtn, "TeacherRosterText", "师父名册", 0, 0, 150, 30);
	GUI.SetColor(TeacherRosterText, UIDefine.BrownColor)
	GUI.StaticSetFontSize(TeacherRosterText, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(TeacherRosterText, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(TeacherRosterText, UILayout.Center)
	
	local StudentRosterBtn = GUI.ButtonCreate(panelBg,"StudentRosterBtn","1800402180",240,62,Transition.ColorTint,"",155,46,false)
	UILayout.SetAnchorAndPivot(StudentRosterBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.SetData(StudentRosterBtn, "index", 2)
	GUI.RegisterUIEvent(StudentRosterBtn, UCE.PointerClick, "ShiTuRegisterUI", "OnTabBtnClick")
	local BtnSprite2 = GUI.ImageCreate( StudentRosterBtn, "BtnSprite2", "1800402181", 0, 0, false, 155, 46)
    UILayout.SetAnchorAndPivot(BtnSprite2, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(BtnSprite2,"BtnSprite2")
	GUI.SetVisible(BtnSprite2,false)	
	local StudentRosterText= GUI.CreateStatic(StudentRosterBtn, "StudentRosterText", "徒弟名册", 0, 0, 150, 30);
	GUI.SetColor(StudentRosterText, UIDefine.BrownColor)
	GUI.StaticSetFontSize(StudentRosterText, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(StudentRosterText, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(StudentRosterText, UILayout.Center)
	
	local ListBg1 = GUI.ImageCreate(panelBg,"ListBg1" , "1800400200" , 0 , 30,false ,1035,500)
	UILayout.SetAnchorAndPivot(ListBg1, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(ListBg1,"ListBg1")
	GUI.SetVisible(ListBg1,true)

	local ListBg2 = GUI.ImageCreate(panelBg,"ListBg2" , "1800400200" , 0 , 30,false ,1035,500)
	UILayout.SetAnchorAndPivot(ListBg2, UIAnchor.Center, UIAroundPivot.Center)	
	GUI.SetVisible(ListBg2,false)
	_gt.BindName(ListBg2,"ListBg2")
	
	local TeacherScrollWnd = GUI.ScrollRectCreate(ListBg1, "TeacherScrollWnd", 0, 0, 1015, 480, 0, false, Vector2.New(500,110), UIAroundPivot.Top, UIAnchor.Top, 2)
	UILayout.SetAnchorAndPivot(TeacherScrollWnd, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ScrollRectSetChildAnchor(TeacherScrollWnd, UIAnchor.Top)
	GUI.ScrollRectSetChildPivot(TeacherScrollWnd, UIAroundPivot.Top)
	GUI.ScrollRectSetChildSpacing(TeacherScrollWnd, Vector2.New(10, 10))
	_gt.BindName(TeacherScrollWnd, "TeacherScrollWnd")		
	
	local StudentScrollWnd = GUI.ScrollRectCreate(ListBg2, "StudentScrollWnd", 0, 0, 1015, 480, 0, false, Vector2.New(500,110), UIAroundPivot.Top, UIAnchor.Top, 2)
	UILayout.SetAnchorAndPivot(StudentScrollWnd, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ScrollRectSetChildAnchor(StudentScrollWnd, UIAnchor.Top)
	GUI.ScrollRectSetChildPivot(StudentScrollWnd, UIAroundPivot.Top)
	GUI.ScrollRectSetChildSpacing(StudentScrollWnd, Vector2.New(10, 10))
	_gt.BindName(StudentScrollWnd, "StudentScrollWnd")
	
	--换一批
	local ChangeBtn = GUI.ButtonCreate(panelBg,"ChangeBtn","1800402180",-80,62,Transition.ColorTint,"",155,46,false)
	UILayout.SetAnchorAndPivot(ChangeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
	_gt.BindName(ChangeBtn,"ChangeBtn")
	GUI.RegisterUIEvent(ChangeBtn, UCE.PointerClick, "ShiTuRegisterUI", "OnChangeBtnClick")

	local ChangeText= GUI.CreateStatic(ChangeBtn, "ChangeText", "换 一 批", 0, 0, 150, 30);
	GUI.SetColor(ChangeText, UIDefine.BrownColor)
	GUI.StaticSetFontSize(ChangeText, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(ChangeText, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(ChangeText, UILayout.Center)
end

function ShiTuRegisterUI.OnChangeBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeacherPupilSystem", "RefreshData",ShiTuRegisterUI.CurSelectPage)
	CL.SendNotify(NOTIFY.ShowBBMsg,"刷新成功")
end

function ShiTuRegisterUI.OnShow(parameter)
    local Wnd = GUI.GetWnd("ShiTuRegisterUI")
    if Wnd then
        GUI.SetVisible(Wnd, true)
    end
end

function ShiTuRegisterUI.OnCloseBtnClick()
	GUI.DestroyWnd("ShiTuRegisterUI")
end

--摧毁掉原来的格子(后来适应后来更改的需求)
function ShiTuRegisterUI.ResetRosterItem()
	if ShiTuRegisterUI.CurSelectPage == 1 then
		if ShiTuRegisterUI.TeacherRoster then
			if TeacherRosterLastNum ~= 0 then
				for i =1 , TeacherRosterLastNum do
					local item = _gt.GetUI("TeaItem"..i)
					GUI.Destroy(item)
				end
			end
		end
	elseif  ShiTuRegisterUI.CurSelectPage == 2 then
		if ShiTuRegisterUI.PupilRoster then
			if PupilRosterLastNum ~= 0 then
				for i =1 , PupilRosterLastNum do
					local item = _gt.GetUI("StuItem"..i)
					GUI.Destroy(item)
				end
			end
		end	
	end

end

function ShiTuRegisterUI.OnTabBtnClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "index"))
	local BtnSprite1 = _gt.GetUI("BtnSprite1")
	local BtnSprite2 = _gt.GetUI("BtnSprite2")
	
	GUI.SetVisible(BtnSprite1, index == 1)
	GUI.SetVisible(BtnSprite2, index == 2)
	ShiTuRegisterUI.CurSelectPage = index
	
	ShiTuRegisterUI.Refresh()
end

function ShiTuRegisterUI.Refresh()
	test(ShiTuRegisterUI.CurSelectPage)
	
	ShiTuRegisterUI.ResetRosterItem()
	
	local ListBg1 = _gt.GetUI("ListBg1")
	local ListBg2 = _gt.GetUI("ListBg2")
	if ShiTuRegisterUI.CurSelectPage == 1 then
		local item = _gt.GetUI("TeaItem1")
		if not item and ShiTuRegisterUI.TeacherRoster then
			local Count = #ShiTuRegisterUI.TeacherRoster
			if Count ~= 0 then
				TeacherRosterLastNum = Count
				local Parent = _gt.GetUI("TeacherScrollWnd")
				ShiTuRegisterUI.CreateRosterItem(Parent,Count)
			end
		end
		GUI.SetVisible(ListBg1,true)
		GUI.SetVisible(ListBg2,false)
	elseif ShiTuRegisterUI.CurSelectPage == 2 then
		local item = _gt.GetUI("StuItem1")
		if not item and ShiTuRegisterUI.PupilRoster then
			local Count = #ShiTuRegisterUI.PupilRoster
			if Count ~= 0 then
				PupilRosterLastNum = Count
				local Parent = _gt.GetUI("StudentScrollWnd")
				ShiTuRegisterUI.CreateRosterItem(Parent,Count)
			end
		end
		GUI.SetVisible(ListBg1,false)
		GUI.SetVisible(ListBg2,true)
	end

	local BtnSprite1 = _gt.GetUI("BtnSprite1")
	local BtnSprite2 = _gt.GetUI("BtnSprite2")	
	GUI.SetVisible(BtnSprite1, ShiTuRegisterUI.CurSelectPage == 1)
	GUI.SetVisible(BtnSprite2, ShiTuRegisterUI.CurSelectPage == 2)
end

function ShiTuRegisterUI.CreateRosterItem(Parent,Count)
	for i = 1, Count do 
		local RosterItem = GUI.ItemCtrlCreate(Parent, "RosterItem" .. i, "1800800030", 0, 0,500,110)	
		
		local HeadIconBg = GUI.ImageCreate(RosterItem,"HeadIconBg"..i , "1800400200" , -190 , 0, false ,85,85)
		UILayout.SetAnchorAndPivot(HeadIconBg, UIAnchor.Center, UIAroundPivot.Center)
		
		local HeadIcon = GUI.ImageCreate(RosterItem, "HeadIcon"..i , "", -190 , 0, false , 75,75)
		UILayout.SetAnchorAndPivot(HeadIcon, UIAnchor.Center, UIAroundPivot.Center)
		
		local SchoolIcon = GUI.ImageCreate(RosterItem, "SchoolIcon"..i , "", -120 , -25)
		UILayout.SetAnchorAndPivot(SchoolIcon, UIAnchor.Center, UIAroundPivot.Center)
		
		local FightSp = GUI.ImageCreate(RosterItem, "FightSp" ..i, "1800407010" ,-120 , 20)
		UILayout.SetAnchorAndPivot(FightSp, UIAnchor.Center, UIAroundPivot.Center)
		local FightTipText = GUI.CreateStatic( RosterItem, "FightTipText"..i, "角色战力", -35, 22, 120, 50, "system", true)
		UILayout. SetAnchorAndPivot(FightTipText, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(FightTipText, 22)
		GUI.StaticSetAlignment(FightTipText, TextAnchor.MiddleCenter)
		GUI.SetIsOutLine(FightTipText, true)
		GUI.SetOutLine_Color(FightTipText, colorOutline)
		GUI.SetOutLine_Distance(FightTipText, 1)
		local FightValue= GUI.CreateStatic(RosterItem, "FightValue"..i, "", 90,22, 120, 30);
		GUI.SetColor(FightValue, UIDefine.BrownColor)
		GUI.StaticSetFontSize(FightValue,22)
		GUI.StaticSetAlignment(FightValue, TextAnchor.MiddleLeft)
		UILayout.SetSameAnchorAndPivot(FightValue, UILayout.Center)
		local Name= GUI.CreateStatic(RosterItem, "Name"..i,"", 13,-25, 210, 30);
		GUI.SetColor(Name, UIDefine.BrownColor)
		GUI.StaticSetFontSize(Name,22)
		GUI.StaticSetAlignment(Name, TextAnchor.MiddleLeft)
		UILayout.SetSameAnchorAndPivot(Name, UILayout.Center)	
		local SendMessageBtn = GUI.ButtonCreate(RosterItem,"SendMessageBtn"..i,"1800402110",160,20,Transition.ColorTint,"发送消息",120,45,false)
		UILayout.SetAnchorAndPivot(SendMessageBtn, UIAnchor.Center, UIAroundPivot.Center)
		GUI.RegisterUIEvent(SendMessageBtn, UCE.PointerClick, "ShiTuRegisterUI", "OnSendMessageBtnClick")
		GUI.ButtonSetTextColor(SendMessageBtn,UIDefine.BrownColor)
		GUI.ButtonSetTextFontSize(SendMessageBtn,24)
		GUI.SetData(SendMessageBtn, "SendMessageIndex",i)
		
		local PlayerInfoBtn = GUI.ButtonCreate(RosterItem,"PlayerInfoBtn"..i,"1800702030",200,-25,Transition.ColorTint)	
		UILayout.SetAnchorAndPivot(PlayerInfoBtn, UIAnchor.Center, UIAroundPivot.Center)
		GUI.RegisterUIEvent(PlayerInfoBtn, UCE.PointerClick, "ShiTuRegisterUI", "OnRoleInfoBtnClick")
		GUI.SetData(PlayerInfoBtn, "ChickInfoIndex",i)
		
		
		if ShiTuRegisterUI.CurSelectPage == 1 then
			_gt.BindName(RosterItem,"TeaItem"..i)
			local RoleDB = DB.GetRole(ShiTuRegisterUI.TeacherRoster[i].role_id)
			GUI.ImageSetImageID(HeadIcon,tostring(RoleDB.Head))
			local SchoolDB = DB.GetSchool(ShiTuRegisterUI.TeacherRoster[i].school)
			GUI.ImageSetImageID(SchoolIcon,tostring(SchoolDB.Icon))
			GUI.StaticSetText(FightValue,tostring(ShiTuRegisterUI.TeacherRoster[i].fight_value))
			GUI.StaticSetText(Name,ShiTuRegisterUI.TeacherRoster[i].name)
		elseif ShiTuRegisterUI.CurSelectPage == 2 then
			_gt.BindName(RosterItem,"StuItem"..i)
			local RoleDB = DB.GetRole(ShiTuRegisterUI.PupilRoster[i].role_id)
			GUI.ImageSetImageID(HeadIcon,tostring(RoleDB.Head))
			local SchoolDB = DB.GetSchool(ShiTuRegisterUI.PupilRoster[i].school)
			GUI.ImageSetImageID(SchoolIcon,tostring(SchoolDB.Icon))
			GUI.StaticSetText(FightValue,tostring(ShiTuRegisterUI.PupilRoster[i].fight_value))
			GUI.StaticSetText(Name,ShiTuRegisterUI.PupilRoster[i].name)
		end
	end
	
end



function ShiTuRegisterUI.OnRoleInfoBtnClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "ChickInfoIndex"))
	local RoleGuid = ""
	local ToName = "0"
	if ShiTuRegisterUI.CurSelectPage == 1 then
	RoleGuid = ShiTuRegisterUI.TeacherRoster[index].guid
	ToName = ShiTuRegisterUI.TeacherRoster[index].name
	elseif ShiTuRegisterUI.CurSelectPage == 2 then
	RoleGuid = ShiTuRegisterUI.PupilRoster[index].guid
	ToName = ShiTuRegisterUI.PupilRoster[index].name
	end
	local Name = CL.GetRoleName(0)
	if Name == ToName then
	CL.SendNotify(NOTIFY.ShowBBMsg, "无法查看自己的信息")
	else
	CL.SendNotify(NOTIFY.SubmitForm, "FormContact", " QueryOfflinePlayer",RoleGuid)
	end
end

function ShiTuRegisterUI.OnSendMessageBtnClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "SendMessageIndex"))
	local RoleGuid = 0
	local ToName = ""
	if ShiTuRegisterUI.CurSelectPage == 1 then
		RoleGuid = ShiTuRegisterUI.TeacherRoster[index].guid
		ToName = ShiTuRegisterUI.TeacherRoster[index].name
	elseif ShiTuRegisterUI.CurSelectPage == 2 then
		RoleGuid = ShiTuRegisterUI.PupilRoster[index].guid
		ToName = ShiTuRegisterUI.PupilRoster[index].name
	end
	
	if ToName ~= CL.GetRoleName(0) and RoleGuid ~= 0 then
		CL.SendNotify(NOTIFY.SubmitForm,"FormContact","AddStrangerList",RoleGuid)
		GUI.OpenWnd("FriendUI",RoleGuid.."#FriendShipRecommendData")
	else
		CL.SendNotify(NOTIFY.ShowBBMsg, "无法向自己发送消息")
	end
end
