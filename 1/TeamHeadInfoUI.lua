TeamHeadInfoUI = {}
TeamHeadInfoUI.ClickRoleGUID = 0
TeamHeadInfoUI.ClickRoleInTeamState = 0
local _gt = UILayout.NewGUIDUtilTable()

function TeamHeadInfoUI.Main( parameter )
	_gt = UILayout.NewGUIDUtilTable()
	local _Panel = GUI.WndCreateWnd("TeamHeadInfoUI", "TeamHeadInfoUI", 0 , 0,eCanvasGroup.Normal)
    UILayout.SetAnchorAndPivot(_Panel, UIAnchor.Right, UIAroundPivot.Center)

    local w = GUI.GetWidth(_Panel)
    local h = GUI.GetHeight(_Panel)
	local _BackCover = GUI.ImageCreate( _Panel, "BackCover" , "1800400220" , 0 , 0 ,false,w,h)
    UILayout.SetSameAnchorAndPivot(_BackCover, UILayout.Center)
	GUI.SetColor(_BackCover,UIDefine.Transparent)
	GUI.SetIsRaycastTarget(_BackCover,true)
	_BackCover:RegisterEvent(UCE.PointerClick)
	GUI.RegisterUIEvent(_BackCover , UCE.PointerClick , "TeamHeadInfoUI", "OnBackCoverClick")

	local _Node = GUI.ImageCreate( _BackCover, "Node" , "1800202270" , -274 , 0 )
	_gt.BindName(_Node, "Node")
    UILayout.SetAnchorAndPivot(_Node, UIAnchor.Right, UIAroundPivot.Center)

	local _InfoBack = GUI.ImageCreate(_Node, "InfoBack","1800400290",-170,-28,false,138,340)
	_gt.BindName(_InfoBack, "InfoBack")
    UILayout.SetAnchorAndPivot(_InfoBack, UIAnchor.Right, UIAroundPivot.TopLeft)

	TeamHeadInfoUI.ShowBtns(parameter)
end

function TeamHeadInfoUI.OnBackCoverClick()
	GUI.DestroyWnd("TeamHeadInfoUI")
end

local AllBtns = {"InfoBtn","AddFriBtn","TobeLeaderBtn","CallBackBtn","LetLeaveBtn","TempLeaveBtn","BackTeamBtn","LeaveBtn","AskForLeaderBtn"}
local LeaderBtns = {{"查看玩家",AllBtns[1]},{"加为好友",AllBtns[2]},{"升为队长",AllBtns[3]},{"召回",AllBtns[4]},{"请离玩家",AllBtns[5]}}
local TeamMateBtns = {{"查看玩家",AllBtns[1]},{"加为好友",AllBtns[2]}}
local SelfBtns = {{"申请队长",AllBtns[9]},{"暂离",AllBtns[6]},{"归队",AllBtns[7]},{"离开队伍",AllBtns[8]}}
function TeamHeadInfoUI.ShowBtns(roleGUID)
	TeamHeadInfoUI.ClickRoleGUID = TOOLKIT.Str2uLong(roleGUID)
	TeamHeadInfoUI.ClickRoleInTeamState = LD.GetRoleInTeamState(TeamHeadInfoUI.ClickRoleGUID)
	if TeamHeadInfoUI.ClickRoleInTeamState == 0 then return end

	local OrderIndex = LD.GetMemberOrder(TeamHeadInfoUI.ClickRoleGUID)
	local _Node = _gt.GetUI("Node")
	if _Node ~= nil then
		local PosY = TrackUI.GetTrackPanelOffsetY()
		GUI.SetPositionY(_Node, PosY+110+(OrderIndex-1)*80)
	end

	local _InfoBack = _gt.GetUI("InfoBack")
	--Type 1:自己，2，队长看他人，3，队员看他人
	local UIType = 3
	local LeaderGUID = LD.GetTeamInfo().leader_guid
    local IsSelfTeamMate = (TeamHeadInfoUI.ClickRoleGUID ~= LeaderGUID)
	if LD.GetSelfGUID()==TeamHeadInfoUI.ClickRoleGUID then
		UIType = 1
	elseif LD.GetSelfGUID() == LeaderGUID then
        UIType = 2
	end

	--先隐藏一遍
	for i=1, #AllBtns do
		local _Btn = _gt.GetUI(AllBtns[i])
		if _Btn ~= nil then
			GUI.SetVisible(_Btn, false)
		end
	end

	local PosY = 10
	local DistanceY = 48
	local ShowBtnCount = 0
	if UIType==1 then
		for i=1,#SelfBtns do
			local _Btn = TeamHeadInfoUI.CreateBtn(_InfoBack, SelfBtns[i][1], SelfBtns[i][2], PosY)
			local IsShow = true
			if SelfBtns[i][2] == AllBtns[9] then
				IsShow = (IsSelfTeamMate and TeamHeadInfoUI.ClickRoleInTeamState~=1)
			elseif SelfBtns[i][2] == AllBtns[6] then
				IsShow = (TeamHeadInfoUI.ClickRoleInTeamState~=1 and IsSelfTeamMate)
			elseif SelfBtns[i][2] == AllBtns[7] then
				IsShow = TeamHeadInfoUI.ClickRoleInTeamState==1
			end
			GUI.SetVisible(_Btn, IsShow)
			if IsShow then
				ShowBtnCount = ShowBtnCount+1
				PosY = PosY+DistanceY
			end
		end
	elseif UIType==3 then
		for i=1,#TeamMateBtns do
			local _ShowName = TeamMateBtns[i][1]
			if _ShowName == "加为好友" then
				_ShowName = LD.IsMyFriend(tostring(TeamHeadInfoUI.ClickRoleGUID)) and "删除好友" or "加为好友"
			end
			local _Btn = TeamHeadInfoUI.CreateBtn(_InfoBack, _ShowName, TeamMateBtns[i][2], PosY)
			--暂离/归队设置
			local IsShow = true
			GUI.SetVisible(_Btn, IsShow)
			if IsShow then
				PosY = PosY+DistanceY
				ShowBtnCount = ShowBtnCount+1
			end
		end
	elseif UIType==2 then
		local State = LD.GetRoleInTeamState(TeamHeadInfoUI.ClickRoleGUID)
		for i=1,#LeaderBtns do
			local _ShowName = LeaderBtns[i][1]
			if _ShowName == "加为好友" then
				_ShowName = LD.IsMyFriend(tostring(TeamHeadInfoUI.ClickRoleGUID)) and "删除好友" or "加为好友"
			end
			local _Btn = TeamHeadInfoUI.CreateBtn(_InfoBack, _ShowName, LeaderBtns[i][2], PosY)
			local IsShow = true
			if LeaderBtns[i][2] == AllBtns[3] then
				IsShow = (State~=1)
			elseif LeaderBtns[i][2] == AllBtns[4] then
				IsShow = (State==1)
			end

			GUI.SetVisible(_Btn, IsShow)
			if IsShow and i<=#LeaderBtns-1 then
				PosY = PosY+DistanceY
				ShowBtnCount = ShowBtnCount+1
			end
		end
        ShowBtnCount = ShowBtnCount + 1
	end
    --设置底框大小
    GUI.SetHeight(_InfoBack, ShowBtnCount * DistanceY + 14)
end

function TeamHeadInfoUI.OnShow()
end

function TeamHeadInfoUI.CreateBtn(parent, txtName, btnName, posY)
	local _Btn = _gt.GetUI(btnName)
	if _Btn == nil then
		_Btn = GUI.ButtonCreate(parent, btnName, "1800402110", 9,posY, Transition.Animation,txtName,120,45,false);
		_gt.BindName(_Btn, btnName)
    	UILayout.SetSameAnchorAndPivot(_Btn, UILayout.TopLeft)
		GUI.ButtonSetTextFontSize(_Btn, 20)
		GUI.ButtonSetTextColor(_Btn, UIDefine.Brown3Color)
		GUI.RegisterUIEvent(_Btn , UCE.PointerClick , "TeamHeadInfoUI", btnName)
	else
		GUI.SetPositionY(_Btn, posY)
		GUI.SetVisible(_Btn, true)
	end
	return _Btn
end

function TeamHeadInfoUI.AskForLeaderBtn(parameter)
	--CL.SendNotify(NOTIFY.ShowBBMsg,"申请队长请求已发送")
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "ApplyLeader")
	TeamHeadInfoUI.OnBackCoverClick()
end

function TeamHeadInfoUI.InfoBtn(parameter)
	CL.SendNotify(NOTIFY.SubmitForm, "FormContact", " QueryOfflinePlayer", TeamHeadInfoUI.ClickRoleGUID)
	TeamHeadInfoUI.OnBackCoverClick()
end

function TeamHeadInfoUI.AddFriBtn(parameter)
	if LD.IsMyFriend(tostring(TeamHeadInfoUI.ClickRoleGUID)) then
		local roleName = CL.GetRoleName(TeamHeadInfoUI.ClickRoleGUID)
		local msg = "您是否要删除您的好友<color=#0000ff>" .. roleName .. "</color>？"
		GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", msg, "TeamHeadInfoUI", "确定", "delete_friend", "取消")

	else
		CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyFriend", TeamHeadInfoUI.ClickRoleGUID)
	end
	TeamHeadInfoUI.OnBackCoverClick()
end

function TeamHeadInfoUI.delete_friend()
	CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "DeleteFriend", TeamHeadInfoUI.ClickRoleGUID)
end

function TeamHeadInfoUI.TobeLeaderBtn(parameter)
	local State = LD.GetRoleInTeamState(TeamHeadInfoUI.ClickRoleGUID)
	if State == 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"离队成员无法进行此操作")
	else
		CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "ChangeLeader", TeamHeadInfoUI.ClickRoleGUID)
	end
	TeamHeadInfoUI.OnBackCoverClick()
end

function TeamHeadInfoUI.CallBackBtn(parameter)
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "CallMember", TeamHeadInfoUI.ClickRoleGUID)
	TeamHeadInfoUI.OnBackCoverClick()
end

function TeamHeadInfoUI.LetLeaveBtn(parameter)
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "KickMember", TeamHeadInfoUI.ClickRoleGUID)
	TeamHeadInfoUI.OnBackCoverClick()
end

function TeamHeadInfoUI.TempLeaveBtn(parameter)
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "LeaveTeamTemporarily")
	TeamHeadInfoUI.OnBackCoverClick()
end

function TeamHeadInfoUI.BackTeamBtn(parameter)
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "RejoinTeam")
	TeamHeadInfoUI.OnBackCoverClick()
end

function TeamHeadInfoUI.LeaveBtn(parameter)
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "LeaveTeam")
	TeamHeadInfoUI.OnBackCoverClick()
end
