--组队平台
TeamPlatformPersonalUI = {}

-- 颜色
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorYellow = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorBlack = Color.New(0 / 255, 0 / 255, 0 / 255, 255 / 255)
local colorDefault = Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255)
local invisibilityColor = Color.New(255 / 255, 255 / 255, 255 / 255, 0 / 255)
local colorLevel = Color.New(169 / 255, 127 / 255, 85 / 255, 255 / 255)
local colorOutline = Color.New(162 / 255, 75 / 255, 21 / 255)
local colorAttr = Color.New(163 / 255, 117 / 255, 29 / 255, 255 / 255)
local colorBtnLabel = Color.New(146 / 255, 72 / 255, 43 / 255, 255 / 255)

TeamPlatformPersonalUI.RequestLstCount = 0
TeamPlatformPersonalUI.TeamTypes =nil
TeamPlatformPersonalUI.AllSubTypeID = {}
TeamPlatformPersonalUI.TotalCount = 0
TeamPlatformPersonalUI.SelectMissionI = 0
TeamPlatformPersonalUI.SelectMissionJ = -1
TeamPlatformPersonalUI.TargetMissionID = 0
TeamPlatformPersonalUI.TargetTeamGUID = 0
TeamPlatformPersonalUI.HaveSelectedMissionID = -1
TeamPlatformPersonalUI.HaveSelectedMissionI = -1
TeamPlatformPersonalUI.HaveSelectedMissionJ = -1
TeamPlatformPersonalUI.TeamInfos = nil
TeamPlatformPersonalUI.ParentItemH = 65
TeamPlatformPersonalUI.SonItemH = 74
TeamPlatformPersonalUI.LastSelectListBtn = nil

local _gt = UILayout.NewGUIDUtilTable()

function TeamPlatformPersonalUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
	
    print("TeamPlatformPersonalUI.Main...")
	
    local _Panel = GUI.WndCreateWnd("TeamPlatformPersonalUI", "TeamPlatformPersonalUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetIgnoreChild_OnVisible(_Panel,true)

    local _PanelBack = GUI.ImageCreate( _Panel,"GreyBack", "1800400220", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
    UILayout.SetSameAnchorAndPivot(_PanelBack, UILayout.Center)
    GUI.SetIsRaycastTarget(_PanelBack, true)
    _PanelBack:RegisterEvent(UCE.PointerClick)
    local group = GUI.GroupCreate(_PanelBack,"PanelBack", 0, 0, 928, 618)
    UILayout.SetSameAnchorAndPivot(group, UILayout.Center)
    local panelBg = GUI.ImageCreate( group,"center", "1800600182", 0, 0, false, 928, 564)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Bottom)

    local topBar_X = 232
    local topBar_Width = 464

    local topBarLeft = GUI.ImageCreate( group,"topBarLeft", "1800600180", topBar_X, 28, false, topBar_Width, 54)
    UILayout.SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

    local topBarRight = GUI.ImageCreate( group,"topBarRight", "1800600181", -topBar_X, 28, false, topBar_Width, 54)
    UILayout.SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

    local topBarCenter = GUI.ImageCreate( group,"topBarCenter", "1800600190", -6, 27, false, 267, 50)
    UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

    local closeBtn = GUI.ButtonCreate( group,"closeBtn", "1800302120", 0, 4, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "TeamPlatformPersonalUI", "OnClose")
    local tipLabel = GUI.CreateStatic( group,"tipLabel", "组队平台", -6, 27, 150, 35)
    UILayout.StaticSetFontSizeColorAlignment(tipLabel, 26, colorDark, TextAnchor.MiddleCenter)
    UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)

    --左侧任务列表底板
    local _MissionLstBack = GUI.ImageCreate( group,"MissionLstBack", "1800400200", 16, 58, false, 314, 540)
    _gt.BindName(_MissionLstBack, "MissionLstBack")
    UILayout.SetSameAnchorAndPivot(_MissionLstBack, UILayout.TopLeft)

    --显示列表
    TeamPlatformPersonalUI.ShowMissionTypeLst(true)

    --右侧申请列表底板
    local _RequestLstBack = GUI.ImageCreate( group,"RequestLstBack", "1800400200", 333, 58, false, 581, 478)
    UILayout.SetSameAnchorAndPivot(_RequestLstBack, UILayout.TopLeft)

    --滚动面板
    local _OnePanelSize = Vector2.New(564, 100)
    local _RequestScroll = GUI.ScrollRectCreate( _RequestLstBack,"RequestScroll", 1, 4, 578, 470, 0, false, _OnePanelSize, UIAroundPivot.Top, UIAnchor.Top, 1)
    _gt.BindName(_RequestScroll, "RequestScroll")
    UILayout.SetSameAnchorAndPivot(_RequestScroll, UILayout.TopLeft)
    GUI.ScrollRectSetChildSpacing(_RequestScroll, Vector2.New(4, 4))
    GUI.ScrollRectSetNormalizedPosition(_RequestScroll, Vector2.New(0, 0))

    --显示申请列表
    TeamPlatformPersonalUI.OnTeamInfoUpdate(4)

    --创建队伍
    local _CreateBtn = GUI.ButtonCreate( _RequestLstBack,"CreateBtn", "1800602030", 1, 62, Transition.ColorTint, "创建队伍")
    UILayout.SetSameAnchorAndPivot(_CreateBtn, UILayout.BottomLeft)
    GUI.ButtonSetTextFontSize(_CreateBtn, 26)
    GUI.ButtonSetTextColor(_CreateBtn, colorWhite)
    GUI.SetIsOutLine(_CreateBtn, true)
    GUI.SetOutLine_Color(_CreateBtn, colorOutline)
    GUI.SetOutLine_Distance(_CreateBtn, 1)
    GUI.RegisterUIEvent(_CreateBtn, UCE.PointerClick, "TeamPlatformPersonalUI", "OnCreateBtn")

    --申请全部
    local _RequestAllBtn = GUI.ButtonCreate( _RequestLstBack,"RequestAllBtn", "1800602030", 219, 62, Transition.ColorTint, "自动匹配")
    _gt.BindName(_RequestAllBtn, "RequestAllBtn")
    UILayout.SetSameAnchorAndPivot(_RequestAllBtn, UILayout.BottomLeft)
    GUI.ButtonSetTextFontSize(_RequestAllBtn, 26)
    GUI.ButtonSetTextColor(_RequestAllBtn, colorWhite)
    GUI.SetIsOutLine(_RequestAllBtn, true)
    GUI.SetOutLine_Color(_RequestAllBtn, colorOutline)
    GUI.SetOutLine_Distance(_RequestAllBtn, 1)
    GUI.RegisterUIEvent(_RequestAllBtn, UCE.PointerClick, "TeamPlatformPersonalUI", "OnRequestAllBtn")
    TeamPlatformPersonalUI.OnTeamInfoUpdate(5)

    --刷新
    local _RefreshBtn = GUI.ButtonCreate( _RequestLstBack,"RefreshBtn", "1800602030", 438, 62, Transition.ColorTint, "刷新")
    GUI.SetEventCD(_RefreshBtn,UCE.PointerClick,3)
    UILayout.SetSameAnchorAndPivot(_RefreshBtn, UILayout.BottomLeft)
    GUI.ButtonSetTextFontSize(_RefreshBtn, 26)
    GUI.ButtonSetTextColor(_RefreshBtn, colorWhite)
    GUI.SetIsOutLine(_RefreshBtn, true)
    GUI.SetOutLine_Color(_RefreshBtn, colorOutline)
    GUI.SetOutLine_Distance(_RefreshBtn, 1)
    GUI.RegisterUIEvent(_RefreshBtn, UCE.PointerClick, "TeamPlatformPersonalUI", "OnRefreshBtn")
end

function TeamPlatformPersonalUI.RefreshRecruitList()
    --刷新信息
    CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "QueryAll")
end

function TeamPlatformPersonalUI.OnShow(parameter)
    if GUI.GetWnd("TeamPlatformPersonalUI") == nil then
        return
    end
    TeamPlatformPersonalUI.RefreshRecruitList()

    print("TeamPlatformPersonalUI.OnShow...")
    TeamPlatformPersonalUI.ShowMissionTypeLst(nil)

    local PreSelectIndexI = -1
    local PreSelectIndexJ = -1
    if parameter ~= nil then
        if string.find(parameter,"teamId:") then
            local matchrule = "teamId:(%d+)"
            local teamId = tonumber(string.match(parameter,matchrule))
            for i = 0, TeamPlatformPersonalUI.TeamTypes.Count-1 do
                local teamConfig = TeamPlatformPersonalUI.TeamTypes[i]
                for j = 0, teamConfig.MissionID.Count-1 do
                    if teamConfig.MissionID[j]==teamId then
                        PreSelectIndexI =i+1
                        PreSelectIndexJ= j
                    end
                end
            end
        else
            local Strs = string.split(parameter, "_")
            if #Strs == 2 then
                PreSelectIndexI = tonumber(Strs[1])
                PreSelectIndexJ = tonumber(Strs[2])
            end
        end
    end

    --注册消息
    CL.RegisterMessage(GM.TeamInfoUpdate, "TeamPlatformPersonalUI", "OnTeamInfoUpdate")

    --请求列表
    TeamPlatformPersonalUI.OnRefreshBtn(nil)
    --默认选中项
    if PreSelectIndexI ~= -1 then
        --首项默认已经选中
        if PreSelectIndexI ~= 0 then
            TeamPlatformPersonalUI.OnListTypeBtn(nil,"ListTypeBtn" .. PreSelectIndexI,true)
        end
    end
    if PreSelectIndexJ ~= -1 then
        TeamPlatformPersonalUI.OnListTypeSubBtn(nil, tostring(PreSelectIndexI * 100 + PreSelectIndexJ))
    end

    TeamPlatformPersonalUI.UpdateMatchBtnState()
end

function TeamPlatformPersonalUI.OnEnterFight(IsEnter)
    if IsEnter then
        TeamPlatformPersonalUI.OnClose(nil)
    end
end

function TeamPlatformPersonalUI.OnTeamInfoUpdate(Type)
    if Type == 0 then
        --如果自己组队了，则关闭界面
        if LD.GetRoleInTeamState() ~= 0 then
            TeamPlatformPersonalUI.OnClose(nil)
        end
    elseif Type == 4 then
        local list = nil
        if TeamPlatformPersonalUI.SelectMissionI == 0 then
            if TeamPlatformPersonalUI.SelectMissionJ == -1 or TeamPlatformPersonalUI.SelectMissionJ == 0 then
                TeamPlatformPersonalUI.TargetMissionID = -1
			else
				TeamPlatformPersonalUI.TargetMissionID = TeamPlatformPersonalUI.AllSubTypeID[TeamPlatformPersonalUI.SelectMissionJ + 1] or -1
            end
        else
            if TeamPlatformPersonalUI.SelectMissionJ == -1 then
                list = TeamPlatformPersonalUI.TeamTypes[TeamPlatformPersonalUI.SelectMissionI - 1].MissionID
                TeamPlatformPersonalUI.TargetMissionID = list and list.Count > 0 and list[0] or -1 
            else
                TeamPlatformPersonalUI.TargetMissionID = TeamPlatformPersonalUI.TeamTypes[TeamPlatformPersonalUI.SelectMissionI - 1].MissionID[TeamPlatformPersonalUI.SelectMissionJ]
            end
        end
        TeamPlatformPersonalUI.ShowRequestLst(TeamPlatformPersonalUI.TargetMissionID, list)
    elseif Type == 5 then
        TeamPlatformPersonalUI.UpdateMatchBtnState()
    end
end

function TeamPlatformPersonalUI.UpdateMatchBtnState()
    --考虑到需要兼容多方逻辑，这里只做取消状态的更新
    if LD.GetRoleInTeamState() ~= 0 then
        return
    end

    --申请全部和取消申请（自动匹配和取消匹配）
    local RequestAllBtnName = "自动匹配"
    --默认都改为自动匹配，结合图标显示
    if TeamPlatformPersonalUI.HaveSelectedMissionI ~= -1 and TeamPlatformPersonalUI.HaveSelectedMissionI == TeamPlatformPersonalUI.SelectMissionI and TeamPlatformPersonalUI.HaveSelectedMissionJ == TeamPlatformPersonalUI.SelectMissionJ then
        RequestAllBtnName = "取消申请"
    end
    local _RequestAllBtn = _gt.GetUI("RequestAllBtn")
    if _RequestAllBtn ~= nil then
        GUI.ButtonSetText(_RequestAllBtn, RequestAllBtnName)
    end
end

function TeamPlatformPersonalUI.ShowMissionTypeLst(isFisrt)
    local _MissionLstBack =  _gt.GetUI("MissionLstBack")
    local _ListScroll = _gt.GetUI("ListScroll")
    if _ListScroll==nil then
        _ListScroll = GUI.ScrollListCreate(_MissionLstBack, "ListScroll", 0, 4, 314, 532, false, UIAroundPivot.Top, UIAnchor.Top)
        _gt.BindName(_ListScroll, "ListScroll")
        UILayout.SetSameAnchorAndPivot(_ListScroll, UILayout.TopLeft)
    end

    TeamPlatformPersonalUI.ScrollView = _ListScroll
    TeamPlatformPersonalUI.TeamTypes = LD.GetTeamTypes()

    TeamPlatformPersonalUI.TotalCount=0
    TeamPlatformPersonalUI.AllSubTypeID={}
    local Count = TeamPlatformPersonalUI.TeamTypes.Count
    local Index = 1
    for i = 1, Count do
        TeamPlatformPersonalUI.TotalCount = TeamPlatformPersonalUI.TotalCount + TeamPlatformPersonalUI.TeamTypes[i - 1].MissionID.Count
        for j = 1, TeamPlatformPersonalUI.TeamTypes[i - 1].MissionID.Count do
            TeamPlatformPersonalUI.AllSubTypeID[Index] = TeamPlatformPersonalUI.TeamTypes[i - 1].MissionID[j - 1]
            Index = Index + 1
        end
    end

    for i = 0, Count do
        local TypeName = "全部任务"
        if i > 0 then
            TypeName = TeamPlatformPersonalUI.TeamTypes[i - 1].TypeName
        end
        local _ListTypeBtn = GUI.GetChild(_ListScroll,"ListTypeBtn" .. i)
        local _ListTypeBtnSelectPic = _gt.GetUI("ListTypeBtn" .. i.."_SelectPic")
        if not _ListTypeBtn then
            _ListTypeBtn = GUI.ButtonCreate( _ListScroll,"ListTypeBtn" .. i, "1800002030", 0, 0, Transition.ColorTint, TypeName, 298, TeamPlatformPersonalUI.ParentItemH, false)
            _gt.BindName(_ListTypeBtn, "ListTypeBtn"..i)
            UILayout.SetSameAnchorAndPivot(_ListTypeBtn, UILayout.TopLeft)
            GUI.ButtonSetTextFontSize(_ListTypeBtn, 26)
            GUI.ButtonSetTextColor(_ListTypeBtn, colorDark)
            GUI.SetPreferredHeight(_ListTypeBtn, 74)
            GUI.RegisterUIEvent(_ListTypeBtn, UCE.PointerClick, "TeamPlatformPersonalUI", "OnListTypeBtn")

            --选中的标记小图
            _ListTypeBtnSelectPic = GUI.ImageCreate( _ListTypeBtn,"SelectPic", "1801208030", 28,10, false, 38, 38)
            _gt.BindName(_ListTypeBtnSelectPic, "ListTypeBtn"..i.."_SelectPic")
            UILayout.SetSameAnchorAndPivot(_ListTypeBtnSelectPic, UILayout.TopLeft)
        end

        GUI.SetVisible(_ListTypeBtn,true)
        GUI.ButtonSetText(_ListTypeBtn,TypeName)
        GUI.SetVisible(_ListTypeBtnSelectPic, i==TeamPlatformPersonalUI.HaveSelectedMissionI)
        if isFisrt then
            if i==0 then
                GUI.ButtonSetImageID(_ListTypeBtn,"1800002031")
                TeamPlatformPersonalUI.LastSelectListBtn=_ListTypeBtn
            else
                GUI.ButtonSetImageID(_ListTypeBtn,"1800002030")
            end
        end

        local _ListType = GUI.GetChild(_ListScroll,"ListType" .. i)
        if _ListType==nil and i ~= 0 then
            _ListType = GUI.ListCreate(_ListScroll,"ListType" .. i, 6, 6, 298, 532, false)
            _gt.BindName(_ListType, "ListType"..i)
            UILayout.SetSameAnchorAndPivot(_ListType, UILayout.TopLeft)
            GUI.SetVisible(_ListType, i == 0)
        end

        local SubCount = 0
        if i == 0 then
            SubCount = TeamPlatformPersonalUI.TotalCount
        else
            SubCount = TeamPlatformPersonalUI.TeamTypes[i - 1].MissionID.Count
        end
        for j = 1, SubCount do
            local Config = nil
            if i == 0 then
                Config = DB.GetActivity(TeamPlatformPersonalUI.AllSubTypeID[j])
            else
                Config = DB.GetActivity(TeamPlatformPersonalUI.TeamTypes[i - 1].MissionID[j - 1])
            end
            if Config ~= nil then
                local _ListTypeSubBtn = GUI.GetChild(_ListScroll,tostring(i * 100 + (j - 1)))
                local _ListTypeSubBtnSelectPic = _gt.GetUI(tostring(i * 100 + (j - 1)).."_SelectPic")
                if _ListTypeSubBtn==nil then
                    _ListTypeSubBtn = GUI.ButtonCreate( _ListType,tostring(i * 100 + (j - 1)), "1800602040", 0, 64, Transition.ColorTint, Config.Name, 298, TeamPlatformPersonalUI.SonItemH, false)
                    _gt.BindName(_ListTypeSubBtn, tostring(i * 100 + (j - 1)))
                    UILayout.SetSameAnchorAndPivot(_ListTypeSubBtn, UILayout.TopLeft)
                    GUI.ButtonSetTextFontSize(_ListTypeSubBtn, 24)
                    GUI.ButtonSetTextColor(_ListTypeSubBtn, colorDark)
                    GUI.RegisterUIEvent(_ListTypeSubBtn, UCE.PointerClick, "TeamPlatformPersonalUI", "OnListTypeSubBtn")

                    --选中的标记小图
                    _ListTypeSubBtnSelectPic = GUI.ImageCreate( _ListTypeSubBtn,"SelectPic", "1801208030", 30,19, false, 34, 34)
                    _gt.BindName(_ListTypeSubBtnSelectPic, tostring(i * 100 + (j - 1)).."_SelectPic")
                    UILayout.SetSameAnchorAndPivot(_ListTypeSubBtnSelectPic, UILayout.TopLeft)
                end
                if isFisrt then
                    TeamPlatformPersonalUI.SelectMissionJ = 0
                    if j == 1 then
                        GUI.ButtonSetImageID(_ListTypeSubBtn, 1800602041)
                    else
                        GUI.ButtonSetImageID(_ListTypeSubBtn, 1800602040)
                    end
                end

                GUI.SetVisible(_ListTypeSubBtn,true)
                GUI.ButtonSetText(_ListTypeSubBtn,Config.Name)
                GUI.SetVisible(_ListTypeSubBtnSelectPic, Config.Id==TeamPlatformPersonalUI.HaveSelectedMissionID)
            end
        end

        for j = SubCount+1, GUI.GetChildCount(_ListType) do
            local _ListTypeSubBtn = GUI.GetChild(_ListScroll,tostring(i * 100 + (j - 1)))
            GUI.SetVisible(_ListTypeSubBtn,false)
        end
    end

    for i = Count+1, GUI.GetChildCount(_ListScroll) do
        local _ListTypeBtn = GUI.GetChild(_ListScroll,"ListTypeBtn" .. i)
        GUI.SetVisible(_ListTypeBtn,false)
        local _ListType = GUI.GetChild(_ListScroll,"ListType" .. i)
        GUI.SetVisible(_ListType,false)
    end
end

function TeamPlatformPersonalUI.OnListTypeBtn(guid,key,forceOpen)
	local btn = guid~=nil and GUI.GetByGuid(guid)
	key = btn ~= nil and GUI.GetName(btn) or key
	local Index = tonumber(string.sub(key, 12))
	local _ListType = _gt.GetUI("ListType" .. Index)
	local _ListBtn = _gt.GetUI("ListTypeBtn" .. Index)
	if TeamPlatformPersonalUI.LastSelectListBtn ~= _ListBtn then
        if TeamPlatformPersonalUI.LastSelectListBtn ~= nil then
            GUI.ButtonSetImageID(TeamPlatformPersonalUI.LastSelectListBtn,1800002030)
        end
        if _ListBtn ~= nil then
            GUI.ButtonSetImageID(_ListBtn,1800002031)
            TeamPlatformPersonalUI.LastSelectListBtn = _ListBtn
        end
    end

    local IsVisible = true
    if forceOpen==true then
        GUI.SetVisible(_ListType, true)
        IsVisible =false
    else
        if _ListType ~= nil then
            IsVisible = GUI.GetVisible(_ListType)
            GUI.SetVisible(_ListType, not IsVisible)
        end
    end

    local Count = TeamPlatformPersonalUI.TeamTypes.Count
    for i = 0, Count do
        if i ~= Index then
            _ListType = _gt.GetUI("ListType" .. i)
            GUI.SetVisible(_ListType, false)
        end
    end

    TeamPlatformPersonalUI.SelectMissionJ = 0
    if Index == 0 then
		TeamPlatformPersonalUI.SelectMissionI = 0
        if not IsVisible then
			TeamPlatformPersonalUI.OnListTypeSubBtn(nil, 0)
        else
			TeamPlatformPersonalUI.OnTeamInfoUpdate(4)
			--请求列表
			TeamPlatformPersonalUI.OnRefreshBtn(nil)
        end
        return
    end

    TeamPlatformPersonalUI.SelectMissionI = Index
    TeamPlatformPersonalUI.OnListTypeSubBtn(nil, (TeamPlatformPersonalUI.SelectMissionI * 100))

    --自动置顶
    --[[
    if TeamPlatformPersonalUI.SelectMissionI > 0 then
        local fun = function ()
            TeamPlatformPersonalUI.CalculateGridY(TeamPlatformPersonalUI.SelectMissionI, TeamPlatformPersonalUI.TeamTypes[TeamPlatformPersonalUI.SelectMissionI - 1].MissionID.Count)
        end
        if TeamPlatformPersonalUI.Timer  ~= nil then
            TeamPlatformPersonalUI.Timer:Stop()
            TeamPlatformPersonalUI.Timer = nil
        end 
        TeamPlatformPersonalUI.Timer = Timer.New(fun, 0.1)
        TeamPlatformPersonalUI.Timer:Start()
    end
    --]]
end

function TeamPlatformPersonalUI.CalculateGridY(index, sonCount)
    local per = (index - 1) * TeamPlatformPersonalUI.ParentItemH / (sonCount * TeamPlatformPersonalUI.SonItemH +
            TeamPlatformPersonalUI.TeamTypes.Count * TeamPlatformPersonalUI.ParentItemH - GUI.GetHeight(TeamPlatformPersonalUI.ScrollView))
    local value = math.min(1, math.max(0, 1 - per))
    GUI.ScrollRectSetNormalizedPosition(TeamPlatformPersonalUI.ScrollView, Vector2.New(0, value))
end

function TeamPlatformPersonalUI.OnListTypeSubBtn(guid, key)
	print("OnListTypeSubBtn")
	local btn = guid ~= nil and GUI.GetByGuid(guid) or nil
    key = btn ~= nil and GUI.GetName(btn) or key
    print("key = "..tostring(key))
	local Num = tonumber(key) + 1
    TeamPlatformPersonalUI.SelectMissionI = Num >= 0 and (Num - Num % 100) / 100 or 0
    TeamPlatformPersonalUI.SelectMissionJ = Num >= 0 and Num % 100 - 1 or -1

    local Count = 0
    if TeamPlatformPersonalUI.SelectMissionI == 0 then
        Count = #TeamPlatformPersonalUI.AllSubTypeID
    else
        Count = TeamPlatformPersonalUI.TeamTypes[TeamPlatformPersonalUI.SelectMissionI - 1].MissionID.Count
    end

    for m = 0, Count - 1 do
        local _ListTypeBtn = _gt.GetUI(tostring(TeamPlatformPersonalUI.SelectMissionI * 100 + m))
        if _ListTypeBtn ~= nil then
            if m == TeamPlatformPersonalUI.SelectMissionJ then
                GUI.ButtonSetImageID(_ListTypeBtn, 1800602041)
            else
                GUI.ButtonSetImageID(_ListTypeBtn, 1800602040)
            end
        end
    end

    TeamPlatformPersonalUI.OnTeamInfoUpdate(4)
    --请求列表
    TeamPlatformPersonalUI.OnRefreshBtn(nil)
    TeamPlatformPersonalUI.ChangeAutoMatchBtnState()
end

function TeamPlatformPersonalUI.ShowRequestLst(TargetID, list)
    local _RequestScroll = _gt.GetUI("RequestScroll")
    if list then
		local num = list.Count - 1
        TeamPlatformPersonalUI.TeamInfos = nil
        for i = 0, num do
            if TeamPlatformPersonalUI.TeamInfos then
                TeamPlatformPersonalUI.TeamInfos:AddRange(LD.GetTeamApplyInfos(list[i]))
            else
                TeamPlatformPersonalUI.TeamInfos = LD.GetTeamApplyInfos(list[i])
            end
        end
    else
		TeamPlatformPersonalUI.TeamInfos = LD.GetTeamApplyInfos(TargetID)
    end

    local Count = TeamPlatformPersonalUI.TeamInfos and TeamPlatformPersonalUI.TeamInfos.Count or 0
    if Count > TeamPlatformPersonalUI.RequestLstCount then
        TeamPlatformPersonalUI.RequestLstCount = Count
    end
    for i = 1, TeamPlatformPersonalUI.RequestLstCount do
        local IsShow = (i <= Count) and TeamPlatformPersonalUI.TeamInfos[i - 1] and TeamPlatformPersonalUI.TeamInfos[i - 1].member_count and (TeamPlatformPersonalUI.TeamInfos[i - 1].member_count ~= 5)
        local _LstNode = _gt.GetUI("List" .. i)
        if _LstNode == nil then
            if IsShow then
                --底板
                _LstNode = GUI.ImageCreate( _RequestScroll,tostring(i), "1800600060", 0, 0, false, 0, 0)
                _gt.BindName(_LstNode, "List"..i)
                UILayout.SetSameAnchorAndPivot(_LstNode, UILayout.TopLeft)

                --名称
                local _Name = GUI.CreateStatic( _LstNode,"Name", "孙小了了了了", 21, 21, 240, 30, "system", false)
                UILayout.SetSameAnchorAndPivot(_Name, UILayout.TopLeft)
                UILayout.StaticSetFontSizeColorAlignment(_Name, 24, colorDark, nil)

                --等级
                local _Level = GUI.CreateStatic( _LstNode,"Level", "66级", 21, 56, 200, 35)
                UILayout.SetSameAnchorAndPivot(_Level, UILayout.TopLeft)
                UILayout.StaticSetFontSizeColorAlignment(_Level, 22, colorWhite, nil)
                GUI.SetIsOutLine(_Level, true)
                GUI.SetOutLine_Color(_Level, colorBlack)
                GUI.SetOutLine_Distance(_Level, 1)

                --门派图标
                local _RoleSchoolFlag = GUI.ImageCreate( _LstNode,"RoleSchoolFlag", "1800408020", 90, 52, false, 40, 40)
                UILayout.SetSameAnchorAndPivot(_RoleSchoolFlag, UILayout.TopLeft)

                --门派名称
                local _SchoolName = GUI.CreateStatic( _LstNode,"SchoolName", "西海龙宫", 137, 56, 200, 35)
                UILayout.SetSameAnchorAndPivot(_SchoolName, UILayout.TopLeft)
                UILayout.StaticSetFontSizeColorAlignment(_SchoolName, 22, colorDark, nil)

                --任务名称
                local _MissionName = GUI.CreateStatic( _LstNode,"MissionName", "剧情任务", 232, 21, 200, 35)
                UILayout.SetSameAnchorAndPivot(_MissionName, UILayout.TopLeft)
                UILayout.StaticSetFontSizeColorAlignment(_MissionName, 22, colorDark, nil)

                --进度条
                local _RequestBar = GUI.ScrollBarCreate( _LstNode,"RequestBar", "", "1800408160", "1800408110", 232, 58, 200, 26, 1, false, Transition.None, 0, 1, Direction.LeftToRight, true)
                GUI.ScrollBarSetBgSize(_RequestBar, Vector2.New(200, 26))
                UILayout.SetSameAnchorAndPivot(_RequestBar, UILayout.TopLeft)
                local _RequestBarExpTxt = GUI.CreateStatic( _RequestBar,"Value", "1/5", 0, 1, 150, 30)
                UILayout.SetSameAnchorAndPivot(_RequestBarExpTxt, UILayout.Center)
                UILayout.StaticSetFontSizeColorAlignment(_RequestBarExpTxt, 20, colorWhite, TextAnchor.MiddleCenter)

                --申请按钮
                local _RequestBtn = GUI.ButtonCreate( _LstNode,"RequestBtn" .. i, "1800402110", 450, 35, Transition.ColorTint, "申请", 102, 46, false)
                UILayout.SetSameAnchorAndPivot(_RequestBtn, UILayout.TopLeft)
                GUI.ButtonSetTextFontSize(_RequestBtn, 24)
                GUI.ButtonSetTextColor(_RequestBtn, colorDark)
                GUI.RegisterUIEvent(_RequestBtn, UCE.PointerClick, "TeamPlatformPersonalUI", "OnRequestBtn")
            end
        end

        _LstNode = _gt.GetUI("List" .. i)
        if _LstNode ~= nil then
            GUI.SetVisible(_LstNode, IsShow)
        end

        if IsShow then
            --名称
            local _Name = GUI.GetChild(_LstNode, "Name")
            if _Name ~= nil then
                GUI.StaticSetText(_Name, TeamPlatformPersonalUI.TeamInfos[i - 1].leader_data.name)
            end
            --等级
            local _Level = GUI.GetChild(_LstNode, "Level")
            if _Level ~= nil then
                GUI.StaticSetText(_Level, TeamPlatformPersonalUI.GetAtts(TeamPlatformPersonalUI.TeamInfos[i - 1].leader_data.attrs, CL.ConvertFromAttr(RoleAttr.RoleAttrLevel)).."级")
            end
            local _SchoolConfig = DB.GetSchool(TeamPlatformPersonalUI.GetAtts(TeamPlatformPersonalUI.TeamInfos[i - 1].leader_data.attrs, CL.ConvertFromAttr(RoleAttr.RoleAttrJob1)))
            if _SchoolConfig ~= nil then
                --门派名称
                local _SchoolName = GUI.GetChild(_LstNode, "SchoolName")
                if _SchoolName ~= nil then
                    GUI.StaticSetText(_SchoolName, _SchoolConfig.Name)
                end
				--门派图标
                local _RoleSchoolFlag = GUI.GetChild(_LstNode, "RoleSchoolFlag")
                if _RoleSchoolFlag ~= nil then
                    GUI.ImageSetImageID(_RoleSchoolFlag, tostring(_SchoolConfig.BigIcon))
                end
            end

            --任务名称
            local _MissionName = GUI.GetChild(_LstNode, "MissionName")
            if _MissionName ~= nil then
                local Config = DB.GetActivity(TeamPlatformPersonalUI.TeamInfos[i - 1].target)
                if Config ~= nil then
					GUI.StaticSetText(_MissionName, Config.Name)
                end
            end

            --进度条
            local _RequestBar = GUI.GetChild(_LstNode, "RequestBar")
            if _RequestBar ~= nil then
                GUI.ScrollBarSetPos(_RequestBar, TeamPlatformPersonalUI.TeamInfos[i - 1].member_count / 5)
            end

            --进度Txt
            local _RequestBarValue = GUI.GetChildByPath(_LstNode, "RequestBar/Value")
            if _RequestBarValue ~= nil then
                GUI.StaticSetText(_RequestBarValue, TeamPlatformPersonalUI.TeamInfos[i - 1].member_count .. "/5")
            end
        end
    end
end

function TeamPlatformPersonalUI.GetAtts(att, key)
    if att ~= nil then
        local _Count = att.Length
        for i = 0, _Count do
            if att[i].attr == key then
                return tostring(att[i].value)
            end
        end
    end
    return ""
end

function TeamPlatformPersonalUI.OnRequestBtn(guid)
    local btn = GUI.GetByGuid(guid)
    local Index = tonumber(string.sub(GUI.GetName(btn), 11))

    TeamPlatformPersonalUI.TargetMissionID = TeamPlatformPersonalUI.TeamInfos[Index - 1].target
    TeamPlatformPersonalUI.TargetTeamGUID = TeamPlatformPersonalUI.TeamInfos[Index - 1].team_guid

    if TeamPlatformPersonalUI.HaveSelectedMissionI == -1 and TeamPlatformPersonalUI.HaveSelectedMissionJ == -1 then
        TeamPlatformPersonalUI.OnRequestOneTeamYes()
    else
        --询问是否替换
        GlobalUtils.ShowBoxMsg2Btn("提示","你已经匹配了一个活动，是否要改为申请匹配本活动的队伍？","TeamPlatformPersonalUI","确认","OnRequestOneTeamYes","取消")
    end
end

function TeamPlatformPersonalUI.OnRequestOneTeamYes(parameter)
    TeamPlatformPersonalUI.OnExcuteAutoMatch()
    --CL.SendNotify(NOTIFY.ShowBBMsg, "申请已发送")
    CL.SendNotify(NOTIFY.TeamOpeUpdate, 19, tostring(TeamPlatformPersonalUI.TargetTeamGUID), TeamPlatformPersonalUI.TargetMissionID)
end

function TeamPlatformPersonalUI.OnClose()
    --#CL.UnRegisterMessage(GM.TeamInfoUpdate, "TeamPlatformPersonalUI", "OnTeamInfoUpdate")
    --#CL.UnRegisterMessage(GM.InFight, "TeamPlatformPersonalUI", "OnEnterFight")
    if TeamPlatformPersonalUI.Timer  ~= nil then
        TeamPlatformPersonalUI.Timer:Stop()
        TeamPlatformPersonalUI.Timer = nil
    end
    GUI.DestroyWnd("TeamPlatformPersonalUI")
end

function TeamPlatformPersonalUI.OnDestroy()
    if TeamPlatformPersonalUI.Timer ~= nil then
        TeamPlatformPersonalUI.Timer:Stop()
        TeamPlatformPersonalUI.Timer = nil
    end
end

function TeamPlatformPersonalUI.OnCreateBtn(param)
    TeamPlatformPersonalUI.OnClose()
    CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "CreateTeam", 0, 1, 1, 1)
end

function TeamPlatformPersonalUI.OnRequestAllBtn(parameter)
    if TeamPlatformPersonalUI.HaveSelectedMissionI ~= -1 and TeamPlatformPersonalUI.HaveSelectedMissionI == TeamPlatformPersonalUI.SelectMissionI and TeamPlatformPersonalUI.HaveSelectedMissionJ == TeamPlatformPersonalUI.SelectMissionJ then
        CL.SendNotify(NOTIFY.TeamOpeUpdate, 20, 0)

        TeamPlatformPersonalUI.OnUpdateSelectMissionFlag(-1,-1)
        TeamPlatformPersonalUI.ChangeAutoMatchBtnState()
    else
        if TeamPlatformPersonalUI.TargetMissionID <= 0 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "请先选择一个任务类型")
        else
            if TeamPlatformPersonalUI.TeamInfos == nil or TeamPlatformPersonalUI.TeamInfos.Count==0 then
                CL.SendNotify(NOTIFY.ShowBBMsg, "暂无队伍列表，无法自动匹配")
            else
                if TeamPlatformPersonalUI.HaveSelectedMissionI == -1 and TeamPlatformPersonalUI.HaveSelectedMissionJ == -1 then
                    CL.SendNotify(NOTIFY.TeamOpeUpdate, 20, TeamPlatformPersonalUI.TargetMissionID)
                    TeamPlatformPersonalUI.OnExcuteAutoMatch()
                else
                    --询问是否替换
                    GlobalUtils.ShowBoxMsg2Btn("提示","你已经匹配了一个活动，是否要改为申请匹配本活动的队伍？","TeamPlatformPersonalUI","确认","OnAskAutoMatchYes","取消")
                end
            end
        end
    end
end

function TeamPlatformPersonalUI.OnExcuteAutoMatch()
    TeamPlatformPersonalUI.HaveSelectedMissionID = TeamPlatformPersonalUI.TargetMissionID
    --亮起图标
    TeamPlatformPersonalUI.OnUpdateSelectMissionFlag(TeamPlatformPersonalUI.SelectMissionI, TeamPlatformPersonalUI.SelectMissionJ)
    TeamPlatformPersonalUI.ChangeAutoMatchBtnState()
end

function TeamPlatformPersonalUI.OnAskAutoMatchYes(parameter)
    CL.SendNotify(NOTIFY.TeamOpeUpdate, 20, TeamPlatformPersonalUI.TargetMissionID)
    TeamPlatformPersonalUI.OnExcuteAutoMatch()
end

function TeamPlatformPersonalUI.OnUpdateSelectMissionFlag(SelectI, SelectJ)
    if TeamPlatformPersonalUI.HaveSelectedMissionI ~= -1 and TeamPlatformPersonalUI.HaveSelectedMissionJ ~= -1 then
        --先处理隐藏之前的图标
        TeamPlatformPersonalUI.SetEnableSelectPic(TeamPlatformPersonalUI.HaveSelectedMissionI, TeamPlatformPersonalUI.HaveSelectedMissionJ, false)
    end
    TeamPlatformPersonalUI.HaveSelectedMissionI = SelectI
    TeamPlatformPersonalUI.HaveSelectedMissionJ = SelectJ
    --显示当下选择的图标
    TeamPlatformPersonalUI.SetEnableSelectPic(TeamPlatformPersonalUI.HaveSelectedMissionI, TeamPlatformPersonalUI.HaveSelectedMissionJ, true)
end

function TeamPlatformPersonalUI.SetEnableSelectPic(SelectI, SelectJ, IsShow)
    local _ListTypeBtnPic = _gt.GetUI("ListTypeBtn" .. SelectI.."_SelectPic")
    local _ListTypeSubBtnPic = _gt.GetUI(tostring(SelectI * 100 + SelectJ).."_SelectPic")
    if _ListTypeBtnPic ~= nil and _ListTypeSubBtnPic ~= nil then
        GUI.SetVisible(_ListTypeBtnPic, IsShow)
        GUI.SetVisible(_ListTypeSubBtnPic, IsShow)
    end
end

function TeamPlatformPersonalUI.OnRefreshBtn(parameter)
    TeamPlatformPersonalUI.RefreshRecruitList()
end

function TeamPlatformPersonalUI.ChangeAutoMatchBtnState()
    local RequestAllBtnName = "自动匹配"
    local _RequestAllBtn = _gt.GetUI("RequestAllBtn")
    if TeamPlatformPersonalUI.HaveSelectedMissionI ~= -1 and TeamPlatformPersonalUI.HaveSelectedMissionI == TeamPlatformPersonalUI.SelectMissionI and TeamPlatformPersonalUI.HaveSelectedMissionJ == TeamPlatformPersonalUI.SelectMissionJ then
        RequestAllBtnName = "取消申请"
    end
    if _RequestAllBtn ~= nil then
        GUI.ButtonSetText(_RequestAllBtn, RequestAllBtnName)
    end
end