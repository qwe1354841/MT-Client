TeamPanelUI = {}

local ONCE_CLICK_TIME = 220
TeamPanelUI.RequestCount = 0
TeamPanelUI.ClickMemberIndex = -1 --点击选中角色以操作
TeamPanelUI.PressedMemberIndex = -1 --长按选中角色以更换位置
TeamPanelUI.RoleType = 0
TeamPanelUI.MemberInfos = nil
TeamPanelUI.StartPressRoleIndex = 0
TeamPanelUI.IsPressAction = false
TeamPanelUI.TeamUpdateTimer = nil
TeamPanelUI.LastClickTime = 0
TeamPanelUI.RoleModelLst = {}
TeamPanelUI.Requests = {}
TeamPanelUI.CheckCntTimer = nil
TeamPanelUI.IsRoleNumReachCnt = false
TeamPanelUI.toggleGroup = {}
TeamPanelUI.RoleEffectIDs = {-1,-1,-1,-1,-1}
TeamPanelUI.TabIndex = 1
local _gt = UILayout.NewGUIDUtilTable()

local tabList = {
	{ "队伍", "teamTabBtn", "OnTeamTabBtn","teamPage",""},
	{ "申请", "applyTabBtn", "OnApplyTabBtn","applyPage",""}
}

--侍从类型
local guardType = {
	{ "物理型", "1800607240" },
	{ "魔法型", "1800607250" },
	{ "治疗型", "1800607260" },
	{ "控制型", "1800607280" },
	{ "辅助型", "1800607270" },
	{ "全部", "" },
}
-- 人物特效表 从二星开始
local _RoleEffectTable = {
	10,11,12,13,14
}

function TeamPanelUI.Main( parameter )
	_gt = UILayout.NewGUIDUtilTable()

	test("TeamPanelUI lua ")
	local wnd = GUI.WndCreateWnd("TeamPanelUI" , "TeamPanelUI" , 0 , 0);
	local _PanelBG = UILayout.CreateFrame_WndStyle0(wnd, "队    伍","TeamPanelUI","OnClickCloseBtn",_gt);
	UILayout.CreateRightTab(tabList, "TeamPanelUI")

	--组队节点
	--local _TeamNode = GUI.ImageCreate( _PanelBG,"TeamNode", "", 0, 20, false, 0, 0)
	local _TeamNode = GUI.GroupCreate( _PanelBG,"TeamNode", 0, 20, 0, 0) 
	_gt.BindName(_TeamNode, "TeamNode")
	UILayout.SetSameAnchorAndPivot(_TeamNode, UILayout.TopLeft)
	GUI.SetVisible(_TeamNode, true)

	--申请节点
	--local _RequestNode = GUI.ImageCreate( _PanelBG,"RequestNode", "", 0, 20, false, 0, 0)
	local _RequestNode = GUI.GroupCreate( _PanelBG,"RequestNode", 0, 20, 0, 0)
	_gt.BindName(_RequestNode, "RequestNode")
	UILayout.SetSameAnchorAndPivot(_RequestNode, UILayout.TopLeft)
	GUI.SetVisible(_RequestNode, false)

	--队伍列表底板
    local _RoleLstBack = GUI.ImageCreate( _TeamNode,"RoleLstBack", "1800400200", 77, 96, false, 1040, 448)
	_gt.BindName(_RoleLstBack, "RoleLstBack")
    UILayout.SetSameAnchorAndPivot(_RoleLstBack, UILayout.TopLeft)

	--阵型选择按钮
	local _FormationBtn = GUI.ButtonCreate(_TeamNode,"FormationBtn", "1800602020",77,43, Transition.ColorTint, "普通阵", 156, 46, false)
	_gt.BindName(_FormationBtn, "FormationBtn")
    UILayout.SetSameAnchorAndPivot(_FormationBtn, UILayout.TopLeft)
    GUI.ButtonSetTextFontSize(_FormationBtn, 24)
    GUI.ButtonSetTextColor(_FormationBtn, UIDefine.Brown3Color)
	GUI.RegisterUIEvent(_FormationBtn , UCE.PointerClick , "TeamPanelUI", "OnFormation" )

	--显示阵型名称
	TeamPanelUI.UpdateCurSeatInfo()

	--组队目标信息
    local _TargetInfoBack = GUI.ImageCreate( _TeamNode,"TargetInfoBack", "1800600040", 240, 50, false, 748, 33)
    UILayout.SetSameAnchorAndPivot(_TargetInfoBack, UILayout.TopLeft)
	GUI.SetIsRaycastTarget(_TargetInfoBack, true)
	_TargetInfoBack:RegisterEvent(UCE.PointerClick)
	GUI.RegisterUIEvent(_TargetInfoBack , UCE.PointerClick , "TeamPanelUI", "OnChangeTargetBtn" )

    local _TargetInfoTxt = GUI.CreateStatic( _TargetInfoBack,"TargetInfoTxt", "请设置组队目标", 34, 0, 491, 35)
	_gt.BindName(_TargetInfoTxt, "TargetInfoTxt")
    UILayout.SetSameAnchorAndPivot(_TargetInfoTxt, UILayout.Left)
    GUI.StaticSetFontSize(_TargetInfoTxt, 22)
    GUI.SetColor(_TargetInfoTxt, UIDefine.Brown3Color)
	GUI.SetIsRaycastTarget(_TargetInfoTxt, false)

    local _TargetInfoLevel = GUI.CreateStatic( _TargetInfoBack,"TargetInfoLevel", "", -20, 0, 491, 35)
	_gt.BindName(_TargetInfoLevel, "TargetInfoLevel")
    UILayout.SetSameAnchorAndPivot(_TargetInfoLevel, UILayout.Right)
    GUI.StaticSetFontSize(_TargetInfoLevel, 22)
    GUI.SetColor(_TargetInfoLevel, UIDefine.Brown3Color)

	--招募
	local _MatchBtn = GUI.ButtonCreate(_TeamNode,"MatchBtn", "1800602020",996,43, Transition.ColorTint, "发布招募")
	_gt.BindName(_MatchBtn, "MatchBtn")
    UILayout.SetSameAnchorAndPivot(_MatchBtn, UILayout.TopLeft)
    GUI.ButtonSetTextFontSize(_MatchBtn, 24)
    GUI.ButtonSetTextColor(_MatchBtn, UIDefine.Brown3Color)
	GUI.RegisterUIEvent(_MatchBtn , UCE.PointerClick , "TeamPanelUI", "OnMatchBtn" )
	local TeamTargetInfo = LD.GetTeamTarget()
	if TeamTargetInfo.Count>=6 and TeamTargetInfo[0] ~= 0 then
		GUI.ButtonSetText(_MatchBtn, "取消招募")
	else
		GUI.ButtonSetText(_MatchBtn, "发布招募")
	end

	--显示目标
	TeamPanelUI.UpdateCurTeamTarget()

	--一键喊话
	local _YellBtn = GUI.ButtonCreate(_TeamNode,"YellBtn", "1800602020",994,43, Transition.ColorTint, "一键喊话")
    UILayout.SetSameAnchorAndPivot(_YellBtn, UILayout.TopLeft)
    GUI.ButtonSetTextFontSize(_YellBtn, 24)
    GUI.ButtonSetTextColor(_YellBtn, UIDefine.Brown3Color)
	GUI.RegisterUIEvent(_YellBtn , UCE.PointerClick , "TeamPanelUI", "OnYellBtn" )
	GUI.SetVisible(_YellBtn, false)

	--显示成员列表
	TeamPanelUI.ShowTeamLst()

	--申请列表底板
	local _RequestLstBack = GUI.ImageCreate( _RequestNode,"RequestLstBack", "1800400200", 77, 47, false, 1040, 545)
	_gt.BindName(_RequestLstBack, "RequestLstBack")
	UILayout.SetSameAnchorAndPivot(_RequestLstBack, UILayout.TopLeft)

	local _OneRequestPanelSize = Vector2.New(335,107)
	local _RequestScroll = GUI.ScrollRectCreate(_RequestLstBack,"RequestScroll",-1,5,1040,535,0,false,_OneRequestPanelSize,UIAroundPivot.Top,UIAnchor.Top, 3)
	_gt.BindName(_RequestScroll, "RequestScroll")
	UILayout.SetSameAnchorAndPivot(_RequestScroll, UILayout.TopLeft)
	GUI.ScrollRectSetChildSpacing(_RequestScroll,Vector2.New(7,4))
	GUI.ScrollRectSetNormalizedPosition(_RequestScroll,Vector2.New(0,0))

	--显示申请列表
	TeamPanelUI.ShowRequestLst()

	--注册消息
	CL.RegisterMessage(GM.TeamInfoUpdate,"TeamPanelUI" , "OnTeamInfoUpdate")
	CL.RegisterMessage(GM.ChangeName,"TeamPanelUI" , "OnRoleChangeName")
	--#CL.RegisterMessage(GM.TeamSeatInfoUpdate,"TeamPanelUI" , "OnTeamSeatInfoUpdate")
	TeamPanelUI.TeamUpdateTimer = Timer.New(TeamPanelUI.TeamRolePressListener,0.5, -1, true)

	TeamPanelUI.OnTeamInfoUpdate(0)

	-- 阵法小红点注册消息
	--CL.RegisterMessage(GM.AddNewItem,'TeamPanelUI','_when_update_seat_material')
	--CL.RegisterMessage(GM.RemoveItem,'TeamPanelUI','_when_update_seat_material')
	--CL.RegisterMessage(GM.UpdateItem,'TeamPanelUI','_when_update_seat_material')
end

function TeamPanelUI.OnTeamTabBtn(guid)
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(tabList[1][1])
	local Level = MainUI.MainUISwitchConfig["队伍"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		TeamPanelUI.TabIndex = 1
		UILayout.OnTabClick(1,tabList)

		TeamPanelUI.OnSwitchPage(true)
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(TeamPanelUI.TabIndex,tabList)
		return
	end
end

function TeamPanelUI.OnApplyTabBtn(guid)
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(tabList[2][1])
	local Level = MainUI.MainUISwitchConfig["队伍"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		TeamPanelUI.TabIndex = 2
		UILayout.OnTabClick(2,tabList)

		TeamPanelUI.OnSwitchPage(false)
		if LD.GetRoleInTeamState() == 2 then
			CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "QueryApplicants")
		end
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(TeamPanelUI.TabIndex,tabList)
		return
	end

end

function TeamPanelUI.OnSwitchPage(IsTeamPage)
	local _TeamPage = _gt.GetUI("TeamPage")
	GUI.CheckBoxSetCheck(_TeamPage, IsTeamPage)
	local _RequestPage = _gt.GetUI("RequestPage")
	GUI.CheckBoxSetCheck(_RequestPage, not IsTeamPage)
	local _TeamNode = _gt.GetUI("TeamNode")
	GUI.SetVisible(_TeamNode, IsTeamPage)
	local _RequestNode = _gt.GetUI("RequestNode")
	GUI.SetVisible(_RequestNode, not IsTeamPage)
end

function TeamPanelUI.ShowRequestLst()
	local _RequestNode = _gt.GetUI("RequestNode")
	if not GUI.GetVisible(_RequestNode) then
		return
	end

	TeamPanelUI.Requests = LD.GetTeamRequests()
	local Count = TeamPanelUI.Requests.Count
	if Count > TeamPanelUI.RequestCount then
		TeamPanelUI.RequestCount = Count
	end

	local _RequestScroll = _gt.GetUI("RequestScroll")
	for i=1,TeamPanelUI.RequestCount do
		local IsShow = i<=Count
		local _RequestLstNode = _gt.GetUI("RequestLstNode"..(i-1))
		if _RequestLstNode == nil then
			if IsShow then
				--底板
				_RequestLstNode = GUI.ImageCreate( _RequestScroll,"RequestLstNode"..(i-1), "1800600060", 0, 0, false, 336, 106)
				_gt.BindName(_RequestLstNode, "RequestLstNode"..(i-1))
				UILayout.SetSameAnchorAndPivot(_RequestLstNode, UILayout.TopLeft)
				GUI.SetIsRaycastTarget(_RequestLstNode, true)
				_RequestLstNode:RegisterEvent(UCE.PointerClick)
				GUI.RegisterUIEvent(_RequestLstNode , UCE.PointerClick , "TeamPanelUI", "OnRequestLstNode" )

				--头像背景框
				local _FaceBack = GUI.ImageCreate( _RequestLstNode,"FaceBack", "1800600050", 2, 6)
				_gt.BindName(_FaceBack,"RequestFaceBack"..(i-1))
				UILayout.SetSameAnchorAndPivot(_FaceBack, UILayout.TopLeft)
				GUI.SetIsRaycastTarget(_FaceBack,false)

				local _Group = GUI.GroupCreate(_FaceBack, "group", 95, 0, 1, 1)
				UILayout.SetSameAnchorAndPivot(_Group, UILayout.TopLeft)
				GUI.SetIsRaycastTarget(_Group,false)

				--红蓝条
				local _RoleHP = GUI.ScrollBarCreate(_Group,"RoleHP","","1800408120","1800408110",6,34,160,26,1,false,Transition.None,0,1)
				_gt.BindName(_RoleHP,"RequestRoleHP"..(i-1))
				local _RoleHPValue =Vector2.New(160,26)
				GUI.ScrollBarSetBgSize(_RoleHP, _RoleHPValue)
				UILayout.SetAnchorAndPivot(_RoleHP, UIAnchor.TopRight, UIAroundPivot.TopLeft)
				GUI.SetIsRaycastTarget(_RoleHP,false)

				local _RoleMP = GUI.ScrollBarCreate(_Group,"RoleMP","","1800408130","1800408110",6,65,160,26,1,false,Transition.None,0,1)
				_gt.BindName(_RoleMP,"RequestRoleMP"..(i-1))
				GUI.ScrollBarSetBgSize(_RoleMP, _RoleHPValue)
				UILayout.SetAnchorAndPivot(_RoleMP, UIAnchor.TopRight, UIAroundPivot.TopLeft)
				GUI.SetIsRaycastTarget(_RoleMP,false)

				--头像
				local _Face = GUI.ImageCreate( _FaceBack,"Face", "1800600050", 0, 0, false, 84, 84)
				_gt.BindName(_Face,"RequestFace"..(i-1))
				UILayout.SetSameAnchorAndPivot(_Face, UILayout.Center)
				GUI.SetIsRaycastTarget(_Face,false)

				--玩家名字
				local _RoleName = GUI.CreateStatic( _FaceBack,"RoleName", "谁是野猪怪呢", 6, 6, 200, 30, "system", false)
				_gt.BindName(_RoleName,"RequestRoleName"..(i-1))
				UILayout.SetAnchorAndPivot(_RoleName, UIAnchor.TopRight, UIAroundPivot.TopLeft)
				UILayout.StaticSetFontSizeColorAlignment(_RoleName, 24, UIDefine.BrownColor, TextAnchor.MiddleLeft)
				GUI.SetIsRaycastTarget(_RoleName,false)

				--等级
				local _RoleLevel = GUI.CreateStatic( _FaceBack,"RoleLevel", "69级", 198, 29, 200, 35)
				_gt.BindName(_RoleLevel,"RequestRoleLevel"..(i-1))
				UILayout.SetSameAnchorAndPivot(_RoleLevel, UILayout.TopLeft)
				UILayout.StaticSetFontSizeColorAlignment(_RoleLevel, 20, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
				GUI.SetIsOutLine(_RoleLevel,true)
				GUI.SetOutLine_Color(_RoleLevel,UIDefine.BlackColor)
				GUI.SetOutLine_Distance(_RoleLevel,1)
				GUI.SetIsRaycastTarget(_RoleLevel,false)

				--门派标记
				local _SchoolFlag = GUI.ImageCreate( _FaceBack,"SchoolFlag", "1800102030", 201, 29, false, 25, 24)
				_gt.BindName(_SchoolFlag,"RequestSchoolFlag"..(i-1))
				UILayout.SetAnchorAndPivot(_SchoolFlag, UIAnchor.Right, UIAroundPivot.Center)
				GUI.SetIsRaycastTarget(_SchoolFlag,false)
			end
		else
			GUI.SetVisible(_RequestLstNode, IsShow)
		end

		if IsShow then
			local _Face = _gt.GetUI("RequestFace"..(i-1))
			if _Face ~= nil then
				local _RoleDB = DB.GetRole(TeamPanelUI.GetAtts(TeamPanelUI.Requests[i-1].attrs,CL.ConvertFromAttr(RoleAttr.RoleAttrRole)))
				if _RoleDB ~= nil then
					GUI.ImageSetImageID(_Face, tostring(_RoleDB.Head))
				end
			end
			local _SchoolFlag = _gt.GetUI("RequestSchoolFlag"..(i-1))
			if _SchoolFlag then
				local _SchoolDB = DB.GetSchool(TeamPanelUI.GetAtts(TeamPanelUI.Requests[i-1].attrs,CL.ConvertFromAttr(RoleAttr.RoleAttrJob1)))
				if _SchoolDB ~= nil then
					GUI.ImageSetImageID(_SchoolFlag, tostring(_SchoolDB.Icon))
				end
			end

			local _RoleName = _gt.GetUI("RequestRoleName"..(i-1))
			if _RoleName ~= nil then
				GUI.StaticSetText(_RoleName,TeamPanelUI.Requests[i-1].name)
			end

			local _RoleLevel = _gt.GetUI("RequestRoleLevel"..(i-1))
			if _RoleLevel ~= nil then
				GUI.StaticSetText(_RoleLevel,TeamPanelUI.GetAtts(TeamPanelUI.Requests[i-1].attrs,CL.ConvertFromAttr(RoleAttr.RoleAttrLevel)).."级")
			end

			local _SelectFlag = _gt.GetUI("RequestSelectFlag"..(i-1))
			if _SelectFlag ~= nil then
				GUI.SetVisible(_SelectFlag, TeamPanelUI.Requests[i-1].name == TeamPanelUI.SelectMakeTeamRole)
			end
		end
	end
end

function TeamPanelUI.GetAtts(att, key)
	if att ~= nil then
		local _Count = att.Count
		for i = 0, _Count do
			if att[i].attr == key then
				return tostring(att[i].value)
			end
		end
	end
	return ""
end

function TeamPanelUI.OnRequestLstNode(guid)
	local btn = GUI.GetByGuid(guid)
	local Index = tonumber(string.sub(GUI.GetName(btn), 15))
	TeamPanelUI.SelectMakeTeamRole = TeamPanelUI.Requests[Index].guid
	GlobalUtils.ShowBoxMsg2Btn("提示","是否同意 <color=red>"..TeamPanelUI.Requests[Index].name.."</color> 加入队伍？","TeamPanelUI","同意","OnLeaderAgreeYes","拒绝", "OnLeaderAgreeNo")
end

function TeamPanelUI.OnLeaderAgreeYes()
	CL.SendNotify(NOTIFY.TeamOpeUpdate, 21, tostring(TeamPanelUI.SelectMakeTeamRole), 1)
end

function TeamPanelUI.OnLeaderAgreeNo()
	CL.SendNotify(NOTIFY.TeamOpeUpdate, 21, tostring(TeamPanelUI.SelectMakeTeamRole), 0)
end

function TeamPanelUI.OnEnterFight(IsEnter)
    if IsEnter then
        TeamPanelUI.OnClickCloseBtn(nil)
    end
end

function TeamPanelUI.OnShow(parameter)
	local _Wnd = GUI.GetWnd("TeamPanelUI")
	if _Wnd==nil then
		return
	end

	TeamPanelUI.RoleEffectIDs = {-1,-1,-1,-1,-1}
	GUI.SetVisible(_Wnd,true)

	--显示阵型名称
	TeamPanelUI.UpdateCurSeatInfo()

	--显示成员列表
	TeamPanelUI.ShowTeamLst()

	TeamPanelUI.OnTeamInfoUpdate(0)

	UILayout.OnTabClick(1, tabList)

	-- 阵法小红点
	--TeamPanelUI.get_battle_seat_red()
	TeamPanelUI.is_show_b_seat_red()
end

function TeamPanelUI.OnRoleHasTeamChange(parameter)
	--队伍属性发生变更
	TeamPanelUI.OnTeamInfoUpdate(0)
end

function TeamPanelUI.StopTimer()
	if TeamPanelUI.TeamUpdateTimer ~= nil then
		TeamPanelUI.TeamUpdateTimer:Stop()
		TeamPanelUI.TeamUpdateTimer:Reset(TeamPanelUI.TeamRolePressListener,0.5, -1, true)
	end
end

function TeamPanelUI.TeamRolePressListener()
	--达成长按操作
	TeamPanelUI.StopTimer()
	TeamPanelUI.IsPressAction = true
    --清除点击状态
    TeamPanelUI.ClickMemberIndex = -1
    TeamPanelUI.ChangeBtnByClickRoleState()
    --设置选中状态
	TeamPanelUI.OnPressedTeamRoleNode(TeamPanelUI.StartPressRoleIndex)
end

function TeamPanelUI.OnClickDownTeamRoleNode(guid)
	local _RoleLstNode = GUI.GetByGuid(guid)
	local _RoleLstNodeName = GUI.GetName(_RoleLstNode)
	TeamPanelUI.IsPressAction = false

	TeamPanelUI.StartPressRoleIndex = tonumber(string.sub(_RoleLstNodeName, 12))
	--CL.AddTimer("TeamRolePressTimer","TeamPanelUI","TeamRolePressListener",ONCE_CLICK_TIME,TimerEventType.Once)
	if TeamPanelUI.TeamUpdateTimer ~= nil then
		TeamPanelUI.TeamUpdateTimer:Start()
	end
	--print("开始长按操作:"..TeamPanelUI.StartPressRoleIndex)
end

function TeamPanelUI.OnClickUpTeamRoleNode(Key)
	--print("按键松开")
	--CL.DelTimer("TeamRolePressTimer")
	TeamPanelUI.StopTimer()
	TeamPanelUI.OnClickTeamRoleNode(TeamPanelUI.StartPressRoleIndex)
	TeamPanelUI.IsPressAction = false
end

function TeamPanelUI.OnPressedTeamRoleNode(Index)
	if (TeamPanelUI.IsPressAction or Index==-1) and TeamPanelUI.RoleType == 2 and TeamPanelUI.MemberInfos ~= nil then
		--print(" --- OnPressedTeamRoleNode  Index："..Index..",TeamPanelUI.RoleType:"..TeamPanelUI.RoleType)
		--test("TeamPanelUI.PressedMemberIndex : "..TeamPanelUI.PressedMemberIndex)
		if TeamPanelUI.PressedMemberIndex ~= Index then
			TeamPanelUI.PressedMemberIndex = Index
		else
			TeamPanelUI.PressedMemberIndex = -1
		end
		local Count = TeamPanelUI.MemberInfos.Length
		Count = Count + LD.GetTeamGuardList().Count
		Count = math.min(Count, 5)
		for i=0,Count-1 do
			local _RoleShelterNode = _gt.GetUI("RoleShelterNode"..i)
			local _ChangePosFlag = _gt.GetUI("ChangePosFlag"..i)
			if _ChangePosFlag == nil then
				_ChangePosFlag = GUI.ImageCreate( _RoleShelterNode,"ChangePosFlag"..i, "1800600080", 0, 0, false, 208, 440)
				_gt.BindName(_ChangePosFlag, "ChangePosFlag"..i)
    			UILayout.SetSameAnchorAndPivot(_ChangePosFlag, UILayout.Center)
				GUI.SetIsRaycastTarget(_ChangePosFlag,false)
				GUI.SetVisible(_ChangePosFlag, false)

				--门派标记
				local _Tip = GUI.ImageCreate( _ChangePosFlag,"Tip", "1800604020", 0, 0)
    			UILayout.SetSameAnchorAndPivot(_Tip, UILayout.Center)
			end

			GUI.SetVisible(_ChangePosFlag, i==TeamPanelUI.PressedMemberIndex and TeamPanelUI.PressedMemberIndex ~= 0)
		end
	end
end

function TeamPanelUI.OnClickTeamRoleNode(Index)
	--print("。。。。。。。。。。。。Index："..Index..",TeamPanelUI.RoleType:"..TeamPanelUI.RoleType)
	if TeamPanelUI.IsPressAction==false and TeamPanelUI.RoleType == 2 then
		if Index >= 0 then
			--print("OnClickTeamRoleNode === TeamPanelUI.PressedMemberIndex:"..TeamPanelUI.PressedMemberIndex)
			if TeamPanelUI.PressedMemberIndex ~= -1 then
                if Index==0 then
                    CL.SendNotify(NOTIFY.ShowBBMsg,"无法跟队长进行换位")
                    return
                end
				if TeamPanelUI.PressedMemberIndex == Index then
					TeamPanelUI.PressedMemberIndex = -1
					TeamPanelUI.OnPressedTeamRoleNode(TeamPanelUI.PressedMemberIndex)
				else
					--调换位置
					--隐藏选中
					local _ChangePosFlag = _gt.GetUI("ChangePosFlag"..TeamPanelUI.PressedMemberIndex)
					if _ChangePosFlag ~= nil then
						GUI.SetVisible(_ChangePosFlag, false)
					end
					--请求调换
					if TeamPanelUI.MemberInfos ~= nil then
						local MemberCount = TeamPanelUI.MemberInfos.Length
						local GuardList = LD.GetTeamGuardList()
						if TeamPanelUI.PressedMemberIndex <= MemberCount-1 and Index <= MemberCount-1  then
							--print("调换人物位置 "..TeamPanelUI.PressedMemberIndex..", "..Index)
							CL.SendNotify(NOTIFY.ShowBBMsg,"玩家位置交换成功")
							--待测试
							CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "SwapMember", TeamPanelUI.MemberInfos[TeamPanelUI.PressedMemberIndex].guid, TeamPanelUI.MemberInfos[Index].guid)
						elseif TeamPanelUI.PressedMemberIndex >= MemberCount and Index >= MemberCount then
							--print("调换侍从位置 "..TeamPanelUI.PressedMemberIndex..", "..Index)
							CL.SendNotify(NOTIFY.ShowBBMsg,"侍从位置交换成功")
							--调换侍从位置
							CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "SwapMember", GuardList[TeamPanelUI.PressedMemberIndex-MemberCount],  GuardList[Index-MemberCount])
						else
							CL.SendNotify(NOTIFY.ShowBBMsg,"玩家和侍从无法交换位置")
						end
                        TeamPanelUI.PressedMemberIndex = -1
					end
				end
				return
			end
            if Index>0 then
                if Index == TeamPanelUI.ClickMemberIndex then
                    TeamPanelUI.ClickMemberIndex = -1
                else
					--print("===================================================  TeamPanelUI.ClickMemberIndex = "..tostring(Index))
                    TeamPanelUI.ClickMemberIndex = Index
                end
                TeamPanelUI.ChangeBtnByClickRoleState()
            end
		end
	end
end

function TeamPanelUI.UpdateCurSeatInfo()
    --队员，则取队长的阵法信息
	local CurSeatName = tostring(UIDefine.SeatName)
	if UIDefine.SeatLevel and UIDefine.SeatLevel > 0 then
		CurSeatName = CurSeatName..":"..tostring(UIDefine.SeatLevel).."级"
        -- 普通阵 默认0级 也得显示等级
	else
		CurSeatName = CurSeatName..":"..tostring(1).."级"
	end
	local _Btn = _gt.GetUI("FormationBtn")
	if _Btn ~= nil then
		GUI.ButtonSetText(_Btn,CurSeatName)

	end
end

function TeamPanelUI.UpdateCurTeamTarget()
	local _TargetInfoTxt = _gt.GetUI("TargetInfoTxt")
	local _TargetInfoLevel = _gt.GetUI("TargetInfoLevel")
	local TeamTargetInfo = LD.GetTeamTarget()

	if _TargetInfoTxt ~= nil and _TargetInfoLevel ~= nil then
		local Name = "请设置组队目标"
		local LevelInfo = ""
		if TeamTargetInfo.Count >= 6 and TeamTargetInfo[0] ~= 0 then
			local TeamConfig = DB.GetActivity(TeamTargetInfo[0])
			if TeamConfig ~= nil then
				Name = "目标："..TeamConfig.Name
			end
			LevelInfo = "（"..TeamTargetInfo[1].."级-"..TeamTargetInfo[2].."级）"
		end
		GUI.StaticSetText(_TargetInfoTxt,Name)
		GUI.StaticSetText(_TargetInfoLevel,LevelInfo)

		local _Btn = _gt.GetUI("MatchBtn")
		if _Btn ~= nil then
			if TeamTargetInfo.Count>=6 and TeamTargetInfo[0] ~= 0 then
				GUI.ButtonSetText(_Btn, "取消招募")
			else
				GUI.ButtonSetText(_Btn, "发布招募")
			end
		end
	end
end

function TeamPanelUI.OnExitBtn(param)
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "LeaveTeam")
end

function TeamPanelUI.OnExitBtnYES(parameter)
	CL.SendNotify(NOTIFY.LeaveTeam)
end

function TeamPanelUI.OnExitBtnNO(parameter)
end

function TeamPanelUI.OnCreateBtn(param)
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "CreateTeam", 0,1,1,1)
end

function TeamPanelUI.OnFightCommandBtn(param)
	GUI.OpenWnd("InstructionsUI")
end

function TeamPanelUI.OnKickBtn(param)
	if TeamPanelUI.ClickMemberIndex == -1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请先选择一名队员")
		return
	end
	if TeamPanelUI.ClickMemberIndex > 0 and TeamPanelUI.MemberInfos ~= nil then
        if TeamPanelUI.ClickMemberIndex<TeamPanelUI.MemberInfos.Length then
			CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "KickMember", TeamPanelUI.MemberInfos[TeamPanelUI.ClickMemberIndex].guid)
        end
	end
end

function TeamPanelUI.OnInviteFriendBtn(param)
    GUI.OpenWnd("TeamInviteFriendUI")
end

function TeamPanelUI.OnToLeaderBtn(param)
	if TeamPanelUI.ClickMemberIndex == -1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请先选择一名队员")
		return
	end
	if TeamPanelUI.ClickMemberIndex > 0 and TeamPanelUI.MemberInfos ~= nil then
        if TeamPanelUI.ClickMemberIndex<TeamPanelUI.MemberInfos.Length then
			CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "ChangeLeader", TeamPanelUI.MemberInfos[TeamPanelUI.ClickMemberIndex].guid)
        end
	end
end

function TeamPanelUI.OnCallBackBtn(param)
	if TeamPanelUI.ClickMemberIndex == -1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请先选择一名队员")
		return
	end
	if TeamPanelUI.ClickMemberIndex > 0 and TeamPanelUI.MemberInfos ~= nil then
		CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "CallMember", TeamPanelUI.MemberInfos[TeamPanelUI.ClickMemberIndex].guid)
	end
end

--自己申请队长
function TeamPanelUI.OnVoteBtn(param)
	local State = LD.GetRoleInTeamState()
	if State == 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请先归队才能进行此操作")
	else
		CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "ApplyLeader")
	end
end


function TeamPanelUI.OnTempLeaveBtn(param)
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "LeaveTeamTemporarily")
end

function TeamPanelUI.OnGoBackTeamBtn(param)
	test("OnGoBackTeamBtn")
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "RejoinTeam")
end

function TeamPanelUI.OnTeamPlatformBtn(param)
	local _FuncOpen =DB.Get_function_open(17)
	if _FuncOpen~=nil then
		if _FuncOpen.Level>CL.GetIAttr(role_attr.role_level) then
			CL.SendNotify(NOTIFY.ShowBBMsg,_FuncOpen.LockedTips)
			return
		end
	end

	GUI.OpenWnd("TeamPlatformPersonalUI")
end

function TeamPanelUI.ChangeBtnByClickRoleState()
	--队长
	if TeamPanelUI.RoleType == 2 then
		local _ToLeadBtn = _gt.GetUI("ToLeadBtn")
		local _CallBackBtn = _gt.GetUI("CallBackBtn")
		local _KickBtn = _gt.GetUI("KickBtn")
		local IsTempLeave = TeamPanelUI.ClickMemberIndex>=0 and TeamPanelUI.MemberInfos ~= nil and TeamPanelUI.ClickMemberIndex<TeamPanelUI.MemberInfos.Length and LD.GetRoleInTeamState(TeamPanelUI.MemberInfos[TeamPanelUI.ClickMemberIndex].guid) == 1
		local IsRole = TeamPanelUI.ClickMemberIndex<TeamPanelUI.MemberInfos.Length
		GUI.SetVisible(_ToLeadBtn, IsRole and IsTempLeave==false)
		GUI.SetVisible(_CallBackBtn, IsRole and IsTempLeave)
		GUI.SetVisible(_KickBtn, IsRole)
	--队员
	elseif TeamPanelUI.RoleType == 3 then
		local State = LD.GetRoleInTeamState()
		local _TempLeaveBtn = _gt.GetUI("TempLeaveBtn")
		local _GoBackTeamBtn = _gt.GetUI("GoBackTeamBtn")
		GUI.SetVisible(_TempLeaveBtn, State~=1)
		GUI.SetVisible(_GoBackTeamBtn, State==1)
	end
	local Count = TeamPanelUI.MemberInfos.Length
	Count = math.min(Count + LD.GetTeamGuardList().Count, 5)

	for i=0,Count-1 do
		local _ClickedFlag = _gt.GetUI("ClickedFlag"..i)
		GUI.SetVisible(_ClickedFlag, i==TeamPanelUI.ClickMemberIndex)

		local _ChangePosFlag = _gt.GetUI("ChangePosFlag"..i)
		if _ChangePosFlag ~= nil then
			GUI.SetVisible(_ChangePosFlag, i==TeamPanelUI.PressedMemberIndex and TeamPanelUI.PressedMemberIndex ~= 0)
		end
	end
end

function TeamPanelUI.OnTeamSeatInfoUpdate(Key)
	--显示阵型名称
	TeamPanelUI.UpdateCurSeatInfo()

	--显示成员列表
	TeamPanelUI.ShowTeamLst()
end

function TeamPanelUI.CheackMemberCntDelay(_IsUpdate)
    if TeamPanelUI.IsRoleNumReachCnt == false then
        if _IsUpdate ~= nil and _IsUpdate == true then
            TeamPanelUI.IsRoleNumReachCnt = true

            --执行检查一次
            TeamPanelUI.CheackMemberCnt()

            TeamPanelUI.CheckCntTimer = Timer.New(TeamPanelUI.CheackMemberCntDelayTimer, 1, 1)
            TeamPanelUI.CheckCntTimer:Start()
        end
    end
end

function TeamPanelUI.CheackMemberCntDelayTimer()
    TeamPanelUI.IsRoleNumReachCnt = false
    if TeamPanelUI.CheckCntTimer ~= nil then
        TeamPanelUI.CheckCntTimer:Stop()
        TeamPanelUI.CheckCntTimer = nil
    end
end

--检查队员数量变更,是否需要取消招募
function TeamPanelUI.CheackMemberCnt()
	local info = LD.GetRoleInTeamState()
	--不是队长就返回
	if info ~= 2 then
		return
	end
	local _TeamInfo = LD.GetTeamInfo()
	if tostring(_TeamInfo.team_guid) ~= "0" and _TeamInfo.members.Length == 5 then
		local TeamTargetInfo = LD.GetTeamTarget()
		if TeamTargetInfo.Count >= 6 and TeamTargetInfo[0]~=0 then
			--取消招募信息
			--CL.SendNotify(NOTIFY.TeamOpeUpdate, 13, 0, 0)
			CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "CloseAutoMatch")
			CL.SendNotify(NOTIFY.ShowBBMsg,"队伍人满，取消招募")
		end
	end
end

function TeamPanelUI.OnRoleChangeName(guid, name)
	if guid == LD.GetSelfGUID() then
		TeamPanelUI.UpdateTeamLstInfo()
	end
end

function TeamPanelUI.OnTeamInfoUpdate(Type, p0, p1, p2)
	--print("--->OnTeamInfoUpdate type:"..tostring(Type)..", p0:"..tostring(p0)..", p1:"..tostring(p1)..", p2:"..tostring(p2))
	if Type == 0 or Type == 7 then
		TeamPanelUI.UpdateTeamLstInfo()
	elseif Type == 1 then
		TeamPanelUI.UpdateRoleAtt(p0, p1, p2)
	elseif Type == 3 then
		TeamPanelUI.UpdateCurTeamTarget()
	elseif Type==6 then
		TeamPanelUI.ShowRequestLst()
	elseif Type == 8 then
		TeamPanelUI.ShowTeamLst()
	elseif Type == 9 then
		--自定义数据更新
		if p0 == "EquipRewardLevel" or p0 == "GemRewardLevel" then
			TeamPanelUI.UpdateRoleEquipGemEffect(p2)
		end
	end
end

function TeamPanelUI.UpdateRoleAtt(roleIndex, key, value)
	if key == 1 then
        --roleID
        local _RoleSchool = _gt.GetUI("RoleSchool"..roleIndex)
        if _RoleSchool ~= nil then
            local _RoleDB = DB.GetRole(value)
            if _RoleDB ~= nil then
                GUI.StaticSetText(_RoleSchool, UIDefine.GetRoleRace(value))
            end
        end
		--等级
	elseif key == 2 then
		local _RoleLevel = _gt.GetUI("RoleLevel"..roleIndex)
		if _RoleLevel ~= nil then
			GUI.StaticSetText(_RoleLevel,tostring(value).."级")
		end
	elseif key == 3 then
		local _SchoolFlag = _gt.GetUI("SchoolFlag"..roleIndex)
		if _SchoolFlag ~= nil then
			local _SchoolDB = DB.GetSchool(value)
			if _SchoolDB ~= nil then
				GUI.ImageSetImageID(_SchoolFlag,tostring(_SchoolDB.Icon))
			end
		end
	end
end

function TeamPanelUI.UpdateTeamLstInfo()
	TeamPanelUI.ClickMemberIndex = -1
	TeamPanelUI.PressedMemberIndex = -1
	TeamPanelUI.LastClickTime = 0

	local _TeamNode = _gt.GetUI("TeamNode")
	--底部按钮
	local BottomBtnNames = {"退出队伍","创建队伍","战斗指令","请离队员","邀请好友","升为队长","召回","申请队长","暂离","组队平台","归队"}
	local BottomBtnKeys = {"ExitBtn","CreateBtn","FightCommandBtn","KickBtn","InviteFriendBtn","ToLeadBtn","CallBackBtn","VoteBtn","TempLeaveBtn","TeamPlatformBtn","GoBackTeamBtn"}
	local BottomBtnFuns = {"OnExitBtn","OnCreateBtn","OnFightCommandBtn","OnKickBtn","OnInviteFriendBtn","OnToLeaderBtn","OnCallBackBtn","OnVoteBtn","OnTempLeaveBtn","OnTeamPlatformBtn","OnGoBackTeamBtn"}
	local BottomBtnPosX = {78, 78, 230, 820, 668, 972, 972, 972, 820, 972, 972}
	local TypeBtns = {
		[0]={2, 3},--{2,3,10}, --无队伍
		[1]={1,3,11},--{1,3,5,8,9,11} --暂离
		[2]={1,3,4,6,7},--{1,3,4,5,6,7}, --队长
		[3]={1,3,8,9,11}--{1,3,5,8,9,11} --队员
	}
	TeamPanelUI.RoleType = LD.GetRoleInTeamState() --0无队伍，1暂离，2队长，3队员
--print("------ TeamPanelUI.RoleType :"..tostring(TeamPanelUI.RoleType ))

	local nCount = 1
	for i=1,#BottomBtnNames do
		local IsShow = false
		if nCount <= #TypeBtns[TeamPanelUI.RoleType] and i == TypeBtns[TeamPanelUI.RoleType][nCount]  then
			IsShow = true
			nCount = nCount+1
		end

		local _BottomBtn = _gt.GetUI(BottomBtnKeys[i])
		if _BottomBtn == nil then
			_BottomBtn = GUI.ButtonCreate(_TeamNode,BottomBtnKeys[i], "1800602030",BottomBtnPosX[i],602, Transition.ColorTint, BottomBtnNames[i])
			_gt.BindName(_BottomBtn, BottomBtnKeys[i])
    		UILayout.SetSameAnchorAndPivot(_BottomBtn, UILayout.BottomLeft)
			GUI.ButtonSetTextFontSize(_BottomBtn, 26)
			GUI.ButtonSetTextColor(_BottomBtn, UIDefine.WhiteColor)
			GUI.SetIsOutLine(_BottomBtn,true)
			GUI.SetOutLine_Color(_BottomBtn,UIDefine.Orange2Color)
			GUI.SetOutLine_Distance(_BottomBtn,1)
			GUI.RegisterUIEvent(_BottomBtn , UCE.PointerClick , "TeamPanelUI", BottomBtnFuns[i] )
		end
		GUI.SetVisible(_BottomBtn, IsShow)
	end
	--根据选中的玩家，处理特定的按钮显示状态
	TeamPanelUI.ChangeBtnByClickRoleState()

	--刷新成员列表
	TeamPanelUI.ShowTeamLst()
	TeamPanelUI.UpdateCurSeatInfo()
	TeamPanelUI.UpdateCurTeamTarget()
	TeamPanelUI.CheackMemberCntDelay(true)
end

function TeamPanelUI.OnChangeTargetBtn(parameter)
	print("TeamPanelUI.OnChangeTargetBtn(parameter)")
	if LD.GetRoleInTeamState() == 2 then
		GUI.OpenWnd("TeamPlatformUI")
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,"只有队长才能发布招募信息")
	end
end

function TeamPanelUI.OnYellBtn(parameter)
	print("TeamPanelUI.OnYellBtn(parameter)")
	if LD.GetRoleInTeamState() ~= 2 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"只有队长才能发布招募信息")
	else
		CL.SendNotify(NOTIFY.TeamOpeUpdate, 17)
	end
end

function TeamPanelUI.OnMatchBtn(parameter)
	print("TeamPanelUI.OnMatchBtn(parameter)")
	if LD.GetRoleInTeamState() == 0 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请先创建队伍，再进行招募")
		return
	elseif LD.GetRoleInTeamState() == 3 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"只有队长才能发布招募信息")
		return
	elseif LD.GetRoleInTeamState() == 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"你已暂离，无法进行招募")
		return
	end

	local TeamTargetInfo = LD.GetTeamTarget()
	if TeamTargetInfo.Count >= 6 and TeamTargetInfo[0]~=0 then
		--取消招募信息
		CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "CloseAutoMatch")
	else
		local _TeamInfo = LD.GetTeamInfo()
		if _TeamInfo ~= nil and _TeamInfo.members.Length == 5 then
			CL.SendNotify(NOTIFY.ShowBBMsg,"队伍人满，无法进行招募")
		else
			--发布招募
			GUI.OpenWnd("TeamPlatformUI")
		end
	end
end

function TeamPanelUI.ShowTeamLst()
	local _RoleLstBack = _gt.GetUI("RoleLstBack")
	local _TeamInfo = LD.GetTeamInfo()
	local _MemberNum = 0
    if tostring(_TeamInfo.team_guid) ~= "0" and _TeamInfo.members ~= nil then
        _MemberNum = _TeamInfo.members.Length
    end
	if _MemberNum == 0 then
        --玩家自己数据
		TeamPanelUI.MemberInfos =
		{
            Length = 1,
			[0]={
				role = CL.GetIntAttr(RoleAttr.RoleAttrRole),
				name = CL.GetRoleName(),
				reincarnation = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation),
				level = CL.GetIntAttr(RoleAttr.RoleAttrLevel),
				gender = CL.GetIntAttr(RoleAttr.RoleAttrGender),
				weapon = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId),
				job = CL.GetIntAttr(RoleAttr.RoleAttrJob1),
				guid = "0",
				color1 =  CL.GetIntAttr(RoleAttr.RoleAttrColor1),
				color2 =  CL.GetIntAttr(RoleAttr.RoleAttrColor2),
				effect =  CL.GetIntAttr(RoleAttr.RoleAttrEffect1),
			}
		}
	else
		TeamPanelUI.MemberInfos = _TeamInfo.members
	end

	local _ShowNum = _MemberNum
	--如果没有队伍，则显示玩家自己信息
	if _ShowNum == 0 then _ShowNum = 1 end


	local _GuardGUIDLst = LD.GetTeamGuardList()

	--侍从的数量
	local _GuardNum = _GuardGUIDLst.Count

	local RoleNumPic = {"1800605010","1800605020","1800605030","1800605040","1800605050"}
	--队长，队员，自己，暂离，离线
	local TeamRoleFlag = {"1800604010","1800604090","1800604080","1800604060","1800604050"}
	--队伍成员列表
	for i=1,5 do
		local _RoleNodei = _gt.GetUI("RoleLstNode"..(i-1))
		if _RoleNodei == nil then
			--底板
			_RoleNodei = GUI.ImageCreate( _RoleLstBack,"RoleLstNode"..(i-1), "1800700050", 4+(i-1)*206, 4, false, 208, 440)
			_gt.BindName(_RoleNodei, "RoleLstNode"..(i-1))
    		UILayout.SetSameAnchorAndPivot(_RoleNodei, UILayout.TopLeft)
			GUI.SetIsRaycastTarget(_RoleNodei, true)
			_RoleNodei:RegisterEvent(UCE.PointerDown);
			_RoleNodei:RegisterEvent(UCE.PointerUp);
			GUI.RegisterUIEvent(_RoleNodei , UCE.PointerDown , "TeamPanelUI", "OnClickDownTeamRoleNode" )
			GUI.RegisterUIEvent(_RoleNodei , UCE.PointerUp , "TeamPanelUI", "OnClickUpTeamRoleNode" )

			--龙纹
			local _BackLight = GUI.ImageCreate( _RoleNodei,"BackLight", "1800400230", 0, -50, false, 176, 176)
    		UILayout.SetSameAnchorAndPivot(_BackLight, UILayout.Center)
			GUI.SetIsRaycastTarget(_BackLight, false)

			--队长或其他标记
			local _CaptainFlag = GUI.ImageCreate( _RoleNodei,"CaptainFlag"..(i-1), "1800604010", 16, 15)
			_gt.BindName(_CaptainFlag, "CaptainFlag"..(i-1))
    		UILayout.SetSameAnchorAndPivot(_CaptainFlag, UILayout.TopLeft)
			GUI.SetIsRaycastTarget(_CaptainFlag, false)

			--序号
			local _Num = GUI.ImageCreate( _RoleNodei,"Num", RoleNumPic[i], 72, 11)
    		UILayout.SetSameAnchorAndPivot(_Num, UILayout.Top)
			GUI.SetIsRaycastTarget(_Num, false)

			--脚底阴影
			local _RoleShadow = GUI.ImageCreate( _RoleNodei,"RoleShadow", "1800400240", 0, 98, false, 291, 94)
			UILayout.SetSameAnchorAndPivot(_RoleShadow, UILayout.Center)
			GUI.SetIsRaycastTarget(_RoleShadow, false)

			--玩家名字
			local _RoleName = GUI.CreateStatic( _RoleNodei,"RoleName"..(i-1), "野猪怪", 0, 148, 190, 30, "system", false)
			_gt.BindName(_RoleName, "RoleName"..(i-1))
    		UILayout.SetSameAnchorAndPivot(_RoleName, UILayout.Center)
			GUI.StaticSetFontSize(_RoleName, 21)
			GUI.SetColor(_RoleName, UIDefine.BrownColor)
            GUI.StaticSetAlignment(_RoleName, TextAnchor.MiddleCenter)
			GUI.SetIsRaycastTarget(_RoleName, false)

			--门派
			local _RoleSchool = GUI.CreateStatic( _RoleNodei,"RoleSchool"..(i-1), "人族", -7, 182, 200, 35)
			_gt.BindName(_RoleSchool, "RoleSchool"..(i-1))
    		UILayout.SetSameAnchorAndPivot(_RoleSchool, UILayout.Center)
			GUI.StaticSetFontSize(_RoleSchool, 20)
			GUI.SetColor(_RoleSchool, UIDefine.BrownColor)
			GUI.StaticSetAlignment(_RoleSchool, TextAnchor.MiddleCenter)
			GUI.SetIsRaycastTarget(_RoleSchool, false)

			--门派标记
			local _SchoolFlag = GUI.ImageCreate( _RoleNodei,"SchoolFlag"..(i-1), "1800408020", 29, -27, false, 25, 24)
			_gt.BindName(_SchoolFlag, "SchoolFlag"..(i-1))
    		UILayout.SetSameAnchorAndPivot(_SchoolFlag, UILayout.BottomLeft)
			GUI.SetIsRaycastTarget(_SchoolFlag, false)

			--等级
			local _RoleLevel = GUI.CreateStatic( _RoleNodei,"RoleLevel"..(i-1), "69级", 90, 182, 100, 35)
			_gt.BindName(_RoleLevel, "RoleLevel"..(i-1))
    		UILayout.SetSameAnchorAndPivot(_RoleLevel, UILayout.Center)
			GUI.StaticSetFontSize(_RoleLevel, 20)
			GUI.SetColor(_RoleLevel, UIDefine.WhiteColor)
			GUI.SetIsOutLine(_RoleLevel,true)
			GUI.SetOutLine_Color(_RoleLevel,UIDefine.BlackColor)
			GUI.SetOutLine_Distance(_RoleLevel,1)
			GUI.StaticSetAlignment(_RoleLevel, TextAnchor.MiddleLeft)
			GUI.SetIsRaycastTarget(_RoleLevel, false)

			--选中框
			local _ClickedFlag = GUI.ImageCreate( _RoleNodei,"ClickedFlag"..(i-1), "1800600160", 0, 0, false, 208, 440)
			_gt.BindName(_ClickedFlag, "ClickedFlag"..(i-1))
    		UILayout.SetSameAnchorAndPivot(_ClickedFlag, UILayout.Center)
			GUI.SetIsRaycastTarget(_ClickedFlag,false)
			GUI.SetVisible(_ClickedFlag, false)

			--vip等级
            local VipV = GUI.ImageCreate(_RoleNodei, "vipV", "1801605010", 160,360, false, 18,15)
			local vipVNum1 = GUI.ImageCreate(_RoleNodei, "vipVNum1"..(i-1), "1801605020", 173, 356, false, 15,20)
			local vipVNum2 = GUI.ImageCreate(_RoleNodei, "vipVNum2"..(i-1), "1801605020", 185, 356, false, 15,20)
			GUI.SetVisible(vipVNum2,false)
		end
	end

	--模型节点
	local _RoleLstNodeModelParent = _gt.GetUI("RoleLstNodeModelParent")
	local _RoleLstNodeModel = _gt.GetUI("RoleLstNodeModel")
	if _RoleLstNodeModelParent == nil then
		_RoleLstNodeModelParent = GUI.ImageCreate( _RoleLstBack,"RoleLstNodeModelParent", "1800499999", -118, -85)
		_gt.BindName(_RoleLstNodeModelParent, "RoleLstNodeModelParent")
    	UILayout.SetSameAnchorAndPivot(_RoleLstNodeModelParent, UILayout.TopLeft)
		GUI.SetIsRaycastTarget(_RoleLstNodeModelParent, false)

		_RoleLstNodeModel=GUI.RawImageCreate(_RoleLstNodeModelParent,false,"RoleLstNodeModel","",0,0,4)
		_gt.BindName(_RoleLstNodeModel,"RoleLstNodeModel")
		_RoleLstNodeModel:RegisterEvent(UCE.Drag)
		GUI.SetIsRaycastTarget(_RoleLstNodeModel, false)
		GUI.AddToCamera(_RoleLstNodeModel)
		GUI.RawImageSetCameraConfig(_RoleLstNodeModel, "(0,0,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,10,0.01,6.0,0");
	end

	for i=1,5 do
		local IsShow = (i<=_ShowNum+_GuardNum)
		local _RoleNodei = _gt.GetUI("RoleLstNode"..(i-1))
		local RoleModel = _gt.GetUI("RoleModel"..i)
		if  _RoleNodei then
			GUI.SetVisible(_RoleNodei, IsShow)
		end
		if RoleModel then
			GUI.SetVisible(RoleModel, IsShow)
		end
		if IsShow then
			--显示模型
			local ModelRoleID = 0
			local RoleName = ""
			local RoleReincarnation = 0
			local RoleLevel = 1
			local RoleSchoolFlag = "0"
			local SchoolName = ""
			local WeaponID = 0
			local RoleGUID = "-1"
            local RoleDB = nil
			local Gender = 0
			local Color1 = 0
			local Color2 = 0
			local Job = 0
			local WeaponEffect = 0
			local ModelID = 0
			local GuardStarLevelEffect = -1

            --单人无队伍的情况
            if i==1 and _MemberNum == 0 then
                ModelRoleID = TeamPanelUI.MemberInfos[i-1].role
				RoleDB = DB.GetRole(ModelRoleID)
				if RoleDB then
					ModelID = RoleDB.Model
				end
                RoleName = TeamPanelUI.MemberInfos[i-1].name
				RoleReincarnation = TeamPanelUI.MemberInfos[i-1].reincarnation
                RoleLevel = TeamPanelUI.MemberInfos[i-1].level
                RoleGUID = TeamPanelUI.MemberInfos[i-1].guid
				WeaponID = TeamPanelUI.MemberInfos[i-1].weapon
				Gender = TeamPanelUI.MemberInfos[i-1].gender
				Color1 = TeamPanelUI.MemberInfos[i-1].color1
				Color2 = TeamPanelUI.MemberInfos[i-1].color2
				WeaponEffect = TeamPanelUI.MemberInfos[i-1].effect
				Job = TeamPanelUI.MemberInfos[i-1].job
				local schoolConfig = DB.GetSchool(Job)
				if schoolConfig then
					RoleSchoolFlag = tostring(schoolConfig.Icon)
					SchoolName =  schoolConfig.Name
				end
            --显示队伍成员
            elseif i <= _ShowNum then
                ModelRoleID = _TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrRole)
				RoleDB = DB.GetRole(ModelRoleID)
				if RoleDB then
					ModelID = RoleDB.Model
				end
                RoleName = TeamPanelUI.MemberInfos[i-1].name
				RoleReincarnation = _TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrReincarnation)
                RoleLevel = _TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrLevel)
				WeaponID = _TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrWeaponId)
                RoleGUID = tostring(TeamPanelUI.MemberInfos[i-1].guid)
				Gender = _TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrGender)
				Color1 = _TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrColor1)
				Color2 = _TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrColor2)
				WeaponEffect = _TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrEffect1)
				Job = _TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrJob1)
				local schoolConfig = DB.GetSchool(Job)
				if schoolConfig then
					RoleSchoolFlag = tostring(schoolConfig.Icon)
					SchoolName =  schoolConfig.Name
				end
			else
				local _GuardGuid = 0
				--没有队伍的话，i第二位置就是侍从
				if _MemberNum == 0 then
					_GuardGuid = _GuardGUIDLst[i-2]
					-- 如果侍从位置数据存在的话
					if TeamPanelUI.guardsPosition then
						_GuardGuid = TeamPanelUI.guardsPosition[i]
						_GuardNum = #TeamPanelUI.guardsPosition
					end
					--有队伍的话，_ShowNum后面就是侍从
				else
					_GuardGuid = _GuardGUIDLst[i-_ShowNum-1]
				end
				local _GuardID = LD.GetGuardIDByGUID(_GuardGuid)
				local _GuardConfig = DB.GetOnceGuardByKey1(_GuardID)
				if _GuardConfig then
					RoleName = _GuardConfig.Name
					ModelID = _GuardConfig.Model
					RoleReincarnation = 0
					RoleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
					WeaponID = 0
					RoleGUID = tostring(_GuardGuid)
					Gender = 0
					Color1 = 0
					Color2 = 0
					WeaponEffect = 0
					Job = 0
					RoleSchoolFlag = guardType[_GuardConfig.Type][2]
					SchoolName = guardType[_GuardConfig.Type][1]
					local starLevel = CL.GetIntCustomData("Guard_Star", _GuardGuid)
					if starLevel >= 2 then
						GuardStarLevelEffect = _RoleEffectTable[starLevel-1]
					end
				end
			end

			if ModelID ~= 0 then
				local _RoleModel = _gt.GetUI("RoleModel"..i)
				local _NowInfo = tostring(ModelID)..tostring(Color1)..tostring(Color2)..tostring(WeaponID)..tostring(Gender)..tostring(WeaponEffect)
				if _RoleModel ~= nil then
					local _RoleModelInfo = GUI.GetData(_RoleModel, "RoleModelID")
					GUI.SetVisible(_RoleModel, true)
					if _RoleModelInfo ~= _NowInfo then
						if TeamPanelUI.RoleEffectIDs[i] ~= -1 then
							GUI.DestroyRoleEffect(_RoleModel, TeamPanelUI.RoleEffectIDs[i])
							TeamPanelUI.RoleEffectIDs[i] = -1
						end
						ModelItem.BindRoleWithClothAndWind(_RoleModel, ModelID, Color1, Color2, eRoleMovement.STAND_W1, WeaponID, Gender, WeaponEffect, TOOLKIT.Str2uLong(RoleGUID))
						GUI.SetData(_RoleModel, "RoleModelID", _NowInfo)
						if GuardStarLevelEffect ~= -1 then
							TeamPanelUI.RoleEffectIDs[i] =  GUI.CreateRoleEffect(_RoleModel, GuardStarLevelEffect) -- 添加人物特效
						end
					end
					ModelItem.BindRoleEquipGemEffect(_RoleModel, TOOLKIT.Str2uLong(RoleGUID), _MemberNum>0)
				else
					_RoleModel=GUI.RawImageChildCreate(_RoleLstNodeModel, false, "RoleModel"..i,"", 0, 0)
					_gt.BindName(_RoleModel,"RoleModel"..i)
    				UILayout.SetSameAnchorAndPivot(_RoleModel, UILayout.TopLeft)
					GUI.SetIsRaycastTarget(_RoleModel, false)
					ModelItem.BindRoleWithClothAndWind(_RoleModel, ModelID, Color1, Color2, eRoleMovement.STAND_W1, WeaponID, Gender, WeaponEffect, TOOLKIT.Str2uLong(RoleGUID))
					ModelItem.BindRoleEquipGemEffect(_RoleModel, TOOLKIT.Str2uLong(RoleGUID), _MemberNum>0)
					GUI.SetData(_RoleModel, "RoleModelID", _NowInfo)
					if TeamPanelUI.RoleEffectIDs[i] ~= -1 then
						GUI.DestroyRoleEffect(_RoleModel, TeamPanelUI.RoleEffectIDs[i])
						TeamPanelUI.RoleEffectIDs[i] = -1
					end
					if GuardStarLevelEffect ~= -1 then
						TeamPanelUI.RoleEffectIDs[i] =  GUI.CreateRoleEffect(_RoleModel, GuardStarLevelEffect) -- 添加人物特效
					end
				end
				GUI.SetLocalPosition(_RoleModel, 4.65-1.208*(i-1),3.03,0)
				TeamPanelUI.RoleModelLst[i] = _RoleModel
				
				-- if _MemberNum ==0 and i ==1 or _MemberNum ~= 0 and i <= _ShowNum then
					-- test("================".._MemberNum)
					-- test("_ShowNum".._ShowNum)
					-- test("i为"..i)
					-- 人物染色矫正
					-- local clothes =  CL.GetIntCustomData("Model_Clothes",RoleGUID)
					-- local DynJson = CL.GetStrCustomData("Model_DynJson1",RoleGUID)
					-- if clothes ~= 0 then
						-- local config = DB.GetOnceIllusionByKey1(clothes)
						-- if config.Id ~= 0 then
							-- if config.Type == 0 then
								-- DynJson = ""
							-- end
						-- end
					-- end
					-- if DynJson and DynJson ~= "" then
						-- if UIDefine.IsFunctionOrVariableExist(GUI,"RefreshDyeSkinJson") then
							-- GUI.RefreshDyeSkinJson(_RoleModel, DynJson, "")
						-- end
					-- end	
				-- end
			end

			--成员类型标记
			local _CaptainFlag = _gt.GetUI("CaptainFlag"..(i-1))
			if _CaptainFlag ~= nil then
				local IsShowFlag = (_MemberNum+_GuardNum)>=i and _MemberNum>0
				GUI.SetVisible(_CaptainFlag, IsShowFlag)
				if IsShowFlag then
					local TargetFlagImg = ""
					if i==1 then
						TargetFlagImg = TeamRoleFlag[1] --队长
					else
						if i > _MemberNum then
							TargetFlagImg = "1800604070" --侍从
						else
							if LD.GetSelfGUID() == TeamPanelUI.MemberInfos[i-1].guid then
								TargetFlagImg = TeamRoleFlag[3] --自己
							elseif TeamPanelUI.MemberInfos[i-1].temp_leave==1 then
								TargetFlagImg = TeamRoleFlag[4] --暂离
							elseif TeamPanelUI.MemberInfos[i-1].temp_leave==2 then
								TargetFlagImg = TeamRoleFlag[5] --离线
							else
								TargetFlagImg = TeamRoleFlag[2] --队员
							end
						end
					end
					GUI.ImageSetImageID(_CaptainFlag,TargetFlagImg)
				end
			end

			--姓名
			local _RoleName = _gt.GetUI("RoleName"..(i-1))
			if _RoleName ~= nil then
				GUI.StaticSetText(_RoleName,RoleName)
			end

			--等级
			local _RoleLevel = _gt.GetUI("RoleLevel"..(i-1))
			if _RoleLevel ~= nil then
				GUI.StaticSetText(_RoleLevel, tostring(RoleLevel).."级")
			end
			--门派标记
			local _SchoolFlag = _gt.GetUI("SchoolFlag"..(i-1))
			if _SchoolFlag ~= nil then
				GUI.ImageSetImageID(_SchoolFlag,RoleSchoolFlag)
			end
			--门派名称
			local _RoleSchool = _gt.GetUI("RoleSchool"..(i-1))
			if _RoleSchool ~= nil then
				GUI.StaticSetText(_RoleSchool,SchoolName)
			end
			--vip等级
			local value = tonumber(CL.GetIntAttr)
			if i == 1 then
				local level = tonumber(CL.GetIntAttr(RoleAttr.RoleAttrVip, 0))
				local VipNum1 = GUI.GetChild(_RoleNodei,"vipVNum1"..(i-1),false)
				local VipNum2 = GUI.GetChild(_RoleNodei,"vipVNum2"..(i-1),false)
				if level >= 10 then
					if VipNum1 and VipNum2 then
						local l = math.floor(level / 10)
						if l > 9 then
							test("设置VIP等级出错，当前设置等级：" .. level)
							l = 9
						end
						local h = level % 10
						local tmp = { VipNum1, VipNum2 }
						local picNum = { l, h }
						local picbase = { 1801605020, 1801605020}
						for i = 1, 2 do
							local pic = picbase[i]
							if picNum[i] then
								pic = pic + picNum[i]
							end
							if i == 1 then
								GUI.SetVisible(tmp[i], true)
							elseif i == 2 then
								local b = h >= 0
								GUI.SetVisible(tmp[i], b)
							else
								GUI.SetVisible(tmp[i], true)
							end
							GUI.ImageSetImageID(tmp[i], tostring(pic))
						end
					end
				else
					GUI.ImageSetImageID(VipNum1, tostring(1801605020+level))
				end
			elseif i <= _ShowNum then
				print("shicong"..i)
				local level = tonumber(_TeamInfo:GetMemberAttr(i-1,RoleAttr.RoleAttrVip))
				local VipNum1 = GUI.GetChild(_RoleNodei,"vipVNum1"..(i-1),false)
				local VipNum2 = GUI.GetChild(_RoleNodei,"vipVNum2"..(i-1),false)
				if level >= 10 then
					if VipNum1 and VipNum2 then
						local l = math.floor(level / 10)
						if l > 9 then
							test("设置VIP等级出错，当前设置等级：" .. level)
							l = 9
						end
						local h = level % 10
						local tmp = { VipNum1, VipNum2 }
						local picNum = { l, h }
						local picbase = { 1801605020, 1801605020}
						for i = 1, 2 do
							local pic = picbase[i]
							if picNum[i] then
								pic = pic + picNum[i]
							end
							if i == 1 then
								GUI.SetVisible(tmp[i], true)
							elseif i == 2 then
								local b = h >= 0
								GUI.SetVisible(tmp[i], b)
							else
								GUI.SetVisible(tmp[i], true)
							end
							GUI.ImageSetImageID(tmp[i], tostring(pic))
						end
					end
				else
					GUI.ImageSetImageID(VipNum1, tostring(1801605020+level))
				end
			elseif i > _MemberNum then
				local VipV = GUI.GetChild(_RoleNodei,"vipV",false)
				local VipNum1 = GUI.GetChild(_RoleNodei,"vipVNum1"..(i-1),false)
				local VipNum2 = GUI.GetChild(_RoleNodei,"vipVNum2"..(i-1),false)
				GUI.SetVisible(VipV,false)
				GUI.SetVisible(VipNum1,false)
				GUI.SetVisible(VipNum2,false)
			end
		end
	end

	--选中角色时的遮挡面板节点
	for i=1,5 do
		local _RoleShelterNode = _gt.GetUI("RoleShelterNode"..(i-1))
		if _RoleShelterNode == nil then
			_RoleShelterNode = GUI.ImageCreate( _RoleLstBack,"RoleShelterNode"..(i-1), "1800499999", 4+(i-1)*206, 4, false, 208, 440)
			_gt.BindName(_RoleShelterNode, "RoleShelterNode"..(i-1))
    		UILayout.SetSameAnchorAndPivot(_RoleShelterNode, UILayout.TopLeft)
			GUI.SetIsRaycastTarget(_RoleShelterNode, false)
		end
	end
end

function TeamPanelUI.UpdateRoleEquipGemEffect(roleGUID)
	local _TeamInfo = LD.GetTeamInfo()
	local _MemberNum = 0
	if tostring(_TeamInfo.team_guid) ~= "0" and _TeamInfo.members ~= nil then
		_MemberNum = _TeamInfo.members.Length
	end
	if _MemberNum>0 then
		for i = 1, _MemberNum do
			local _RoleModel = _gt.GetUI("RoleModel"..i)
			if _RoleModel and roleGUID==TeamPanelUI.MemberInfos[i-1].guid then
				ModelItem.BindRoleEquipGemEffect(_RoleModel, TeamPanelUI.MemberInfos[i-1].guid, true)			
			end
		end
	end
end

function TeamPanelUI.SetRoleModelPos(_RoleModel, Index)
    local _PosX = {3.22, 1.92, 0.62, -0.68, -1.98}
    GUI.SetLocalPosition(_RoleModel,_PosX[Index],2.71,0)
end

function TeamPanelUI.OnFormation(key)
	GUI.OpenWnd("BattleSeatUI", tostring(UIDefine.NowLineup).."-"..tostring(UIDefine.SeatID))
end

function TeamPanelUI.OnClickCloseBtn(key)
	TeamPanelUI.StopTimer()
	GUI.DestroyWnd("TeamPanelUI")
end

function TeamPanelUI.OnCancelSelectState()
    TeamPanelUI.PressedMemberIndex = -1
    for i=0,4 do
        local _ChangePosFlag = _gt.GetUI("ChangePosFlag"..i)
        if _ChangePosFlag ~= nil then
            GUI.SetVisible(_ChangePosFlag, false)
        end
    end
end

function TeamPanelUI.OnDestroy()
	TeamPanelUI.StopTimer()
	CL.UnRegisterMessage(GM.TeamInfoUpdate,"TeamPanelUI" , "OnTeamInfoUpdate")
	CL.UnRegisterMessage(GM.ChangeName,"TeamPanelUI" , "OnRoleChangeName")

    -- 注销阵法小红点监听事件
	--CL.UnRegisterMessage(GM.AddNewItem,'TeamPanelUI','_when_update_seat_material')
	--CL.UnRegisterMessage(GM.RemoveItem,'TeamPanelUI','_when_update_seat_material')
	--CL.UnRegisterMessage(GM.UpdateItem,'TeamPanelUI','_when_update_seat_material')
end

-- 获取阵法按钮红点数据
--function TeamPanelUI.get_battle_seat_red()
--	-- 获取是否有未满级的阵法
--	-- 返回值 GlobalProcessing.battle_seat_red
--	-- 回调方法1 TeamPanelUI.is_show_b_seat_red()
--	-- 回调方法2 GlobalProcessing.is_show_battle_seat_red() -- 主界面小红点
--	CL.SendNotify(NOTIFY.SubmitForm, 'FormSeat', 'IsAllSeatMaxLevel')
--end

-- 是否显示阵法按钮小红点
function TeamPanelUI.is_show_b_seat_red()

	local _is_show = false
	-- 判断是否有未满级的阵法
    --if GlobalProcessing.battle_seat_red ~= nil and GlobalProcessing.battle_seat_red == true then
    --    -- 判断是否有阵法书或阵法书材料，有的话显示小红点
    --    _is_show = UIDefine.is_have_seat_material()
    --else
    --    -- 有学习阵法的材料，且阵法未学习
    --    if next(GlobalProcessing.learning_seat_list) ~= nil then
	--		_is_show = UIDefine.have_lean_seat(GlobalProcessing.learning_seat_list)
    --    end
    --end

	if GlobalProcessing['teamBtn'..'_Reds'] and GlobalProcessing['teamBtn'..'_Reds']['level_up'] ~= nil and GlobalProcessing['teamBtn'..'_Reds']['lean'] ~= nil then
		if GlobalProcessing['teamBtn'..'_Reds']['level_up'] == 1 or GlobalProcessing['teamBtn'..'_Reds']['lean'] == 1 then
			_is_show = true
		end
	end

	local _Btn = _gt.GetUI("FormationBtn")
	if _Btn then
		GlobalProcessing.SetRetPoint(_Btn, _is_show)
	end
end

-- 当阵法书材料变化时,监听事件调用函数
--function TeamPanelUI._when_update_seat_material(item_guid,item_id)
--	if not item_id then
--		item_id = LD.GetItemDataByGuid(item_guid).id
--	end
--	item_id = tonumber(item_id)
--
--	local material  =  UIDefine._seat_all_material or UIDefine.get_all_seat_material()
--
--	for i=1, #material do
--        -- 如果更新的物品是阵法材料, 执行刷新小红点
--		if  item_id == material[i] then
--			TeamPanelUI.get_battle_seat_red()
--			break
--		end
--	end
--
--end