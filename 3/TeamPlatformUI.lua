TeamPlatformUI = {}

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

TeamPlatformUI.TeamTypes = nil
TeamPlatformUI.LevelMinCount = 0
TeamPlatformUI.LevelMaxCount = 0
TeamPlatformUI.SelectConfig = nil
TeamPlatformUI.LastTypeIndex = 0
TeamPlatformUI.SelectLevelMin = 0
TeamPlatformUI.SelectLevelMax = 0
TeamPlatformUI.ScrollView = nil
TeamPlatformUI.ParentItemH = 65
TeamPlatformUI.SonItemH = 74
TeamPlatformUI.LevelMinScroll = nil
TeamPlatformUI.LevelMaxScroll = nil

local _gt = UILayout.NewGUIDUtilTable()

function TeamPlatformUI.Main(parameter)
    TeamPlatformUI.InitData()

    print("... TeamPlatformUI")
    local _Panel = GUI.WndCreateWnd("TeamPlatformUI", "TeamPlatformUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetIgnoreChild_OnVisible(_Panel,true)
    --创建背景
    local _GreyBack = GUI.ImageCreate( _Panel,"GreyBack", "1800400220", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
    UILayout.SetSameAnchorAndPivot(_GreyBack, UILayout.Center)
    GUI.SetIsRaycastTarget(_GreyBack, true)
    _GreyBack:RegisterEvent(UCE.PointerClick)

    local _PanelBack = GUI.ImageCreate( _Panel,"PanelBack", "1800600180", -166, -263, false, 330, 54)
    UILayout.SetSameAnchorAndPivot(_PanelBack, UILayout.Center)
    local _PanelBack3 = GUI.ImageCreate( _PanelBack,"PanelBack3", "1800600181", -1, 0, false, 331, 54)
    UILayout.SetAnchorAndPivot(_PanelBack3, UIAnchor.Right, UIAroundPivot.Left)
    local _PanelBack4 = GUI.ImageCreate( _PanelBack,"PanelBack4", "1800600182", 165, 0, false, 660, 526)
    UILayout.SetAnchorAndPivot(_PanelBack4, UIAnchor.Bottom, UIAroundPivot.Top)

    local _TitleBack = GUI.ImageCreate( _PanelBack,"TitleBack", "1800600190", 165, 29)
    UILayout.SetAnchorAndPivot(_TitleBack, UIAnchor.Top, UIAroundPivot.Center)

    local _TitleName = GUI.CreateStatic( _PanelBack,"TitleName", "发布招募", 165, 30, 150, 35)
    UILayout.SetAnchorAndPivot(_TitleName, UIAnchor.Top, UIAroundPivot.Center)
    UILayout.StaticSetFontSizeColorAlignment(_TitleName, 26, colorDark, nil)

    --左侧任务列表底板
    local _MissionLstBack = GUI.ImageCreate( _PanelBack,"MissionLstBack", "1800400200", 12, 61, false, 314, 452)
    _gt.BindName(_MissionLstBack, "MissionLstBack")
    UILayout.SetSameAnchorAndPivot(_MissionLstBack, UILayout.TopLeft)
    local _MissionLstTopBack = GUI.ImageCreate( _PanelBack,"MissionLstTopBack", "1800700070", 14, 61, false, 310, 36)
    UILayout.SetSameAnchorAndPivot(_MissionLstTopBack, UILayout.TopLeft)

    --显示列表
    TeamPlatformUI.ScrollView = GUI.ScrollListCreate(_MissionLstBack, "ListScroll", 8, 36, 298, 412, false , UIAroundPivot.Top, UIAnchor.Top)
    UILayout.SetSameAnchorAndPivot(TeamPlatformUI.ScrollView, UILayout.TopLeft)

    --右侧底板
    local _DetailBack = GUI.ImageCreate( _PanelBack,"DetailBack", "1800400200", 330, 61, false, 314, 300)
    _gt.BindName(_DetailBack, "DetailBack")
    UILayout.SetSameAnchorAndPivot(_DetailBack, UILayout.TopLeft)
    local _DetailTopBack = GUI.ImageCreate( _PanelBack,"DetailTopBack", "1800700070", 332, 61, false, 310, 36)
    UILayout.SetSameAnchorAndPivot(_DetailTopBack, UILayout.TopLeft)

    --白色底板
    local _WhiteBack = GUI.ImageCreate( _DetailBack,"WhiteBack", "1800600090", 10, 61)
    UILayout.SetSameAnchorAndPivot(_WhiteBack, UILayout.TopLeft)
    local txt = GUI.CreateStatic( _WhiteBack,"txt", "最低等级", 0, 0, 120, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, 24, colorDark, TextAnchor.MiddleCenter)

    --白色底板
    local _WhiteBack2 = GUI.ImageCreate( _DetailBack,"WhiteBack2", "1800600090", 10, 183)
    UILayout.SetSameAnchorAndPivot(_WhiteBack2, UILayout.TopLeft)
    local txt = GUI.CreateStatic( _WhiteBack2,"txt", "最高等级", 0, 0, 120, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, 24, colorDark, TextAnchor.MiddleCenter)

    --需求最低等级
    local _NeedLevelMin = GUI.CreateStatic( _WhiteBack,"NeedLevelMin", "", 0, 60, 200, 36)
    _gt.BindName(_NeedLevelMin, "NeedLevelMin")
    UILayout.SetSameAnchorAndPivot(_NeedLevelMin, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_NeedLevelMin, 28, colorDark, TextAnchor.MiddleCenter)

    --需求最高等级
    local _NeedLevelMax = GUI.CreateStatic( _WhiteBack2,"NeedLevelMax", "", 0, 56, 200, 36)
    _gt.BindName(_NeedLevelMax, "NeedLevelMax")
    UILayout.SetSameAnchorAndPivot(_NeedLevelMax, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_NeedLevelMax, 28, colorDark, TextAnchor.MiddleCenter)

    --右侧底板-下
    local _DetailBackDown = GUI.ImageCreate( _PanelBack,"DetailBackDown", "1800400200", 330, 365, false, 314, 147)
    _gt.BindName(_DetailBackDown, "DetailBackDown")
    UILayout.SetSameAnchorAndPivot(_DetailBackDown, UILayout.TopLeft)

    --描述信息
    local _Infos = GUI.CreateStatic( _DetailBackDown,"Infos", "", 2, 8, 290, 135, "system", true)
    _gt.BindName(_Infos, "Infos")
    UILayout.SetSameAnchorAndPivot(_Infos, UILayout.Top)
    UILayout.StaticSetFontSizeColorAlignment(_Infos, 22, colorDark, TextAnchor.UpperLeft)

    --勾选框
    local _AutoMatchCheck = GUI.CheckBoxCreate( _PanelBack,"AutoMatchCheck", "1800607150", "1800607151", 84, 492, Transition.ColorTint, true)
    _gt.BindName(_AutoMatchCheck, "AutoMatchCheck")
    UILayout.SetSameAnchorAndPivot(_AutoMatchCheck, UILayout.BottomLeft)
    local _Txt = GUI.CreateStatic( _AutoMatchCheck,"Txt", "自动入队", 105, 0, 150, 30)
    UILayout.SetSameAnchorAndPivot(_Txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_Txt, 22, colorDark, nil)

    --组队目标
    local _TargetTitleTxt = GUI.CreateStatic( _PanelBack,"TargetTitleTxt", "组队目标", 125, 67)
    UILayout.SetSameAnchorAndPivot(_TargetTitleTxt, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_TargetTitleTxt, 22, colorDark, nil)

    --等级限制
    local _LevelTitleTxt = GUI.CreateStatic( _PanelBack,"LevelTitleTxt", "等级限制", 445, 67)
    UILayout.SetSameAnchorAndPivot(_LevelTitleTxt, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_LevelTitleTxt, 22, colorDark, nil)

    --确认按钮
    local _OKBtn = GUI.ButtonCreate( _PanelBack,"OKBtn", "1800602030", 322, 512, Transition.ColorTint, "确认")
    UILayout.SetSameAnchorAndPivot(_OKBtn, UILayout.Bottom)
    GUI.ButtonSetTextFontSize(_OKBtn, 26)
    GUI.ButtonSetTextColor(_OKBtn, colorWhite)
    GUI.SetIsOutLine(_OKBtn, true)
    GUI.SetOutLine_Color(_OKBtn, colorOutline)
    GUI.SetOutLine_Distance(_OKBtn, 1)
    GUI.RegisterUIEvent(_OKBtn, UCE.PointerClick, "TeamPlatformUI", "OnOKBtn")

    --关闭按钮
    local _CloseBtn = GUI.ButtonCreate( _PanelBack,"CloseBtn", "1800302120", 340, 0, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(_CloseBtn, UILayout.TopRight)

    GUI.RegisterUIMessage(UM.OnEnhanceScrollViewSelectStateChange, "TeamPlatformUI", "OnEnhanceScrollViewSelectStateChange");
    GUI.RegisterUIEvent(_CloseBtn, UCE.PointerClick, "TeamPlatformUI", "OnClose")
end

function TeamPlatformUI.InitData()
    _gt = UILayout.NewGUIDUtilTable()
    TeamPlatformUI.TeamTypes = nil
    TeamPlatformUI.LevelMinCount = 0
    TeamPlatformUI.LevelMaxCount = 0
    TeamPlatformUI.SelectConfig = nil
    TeamPlatformUI.LastTypeIndex = 0
    TeamPlatformUI.SelectLevelMin = 0
    TeamPlatformUI.SelectLevelMax = 0
    TeamPlatformUI.ScrollView = nil
    TeamPlatformUI.ParentItemH = 65
    TeamPlatformUI.SonItemH = 74
    TeamPlatformUI.LevelMinScroll = nil
    TeamPlatformUI.LevelMaxScroll = nil
end

function TeamPlatformUI.OnShow(parameter)
    local _Wnd = GUI.GetWnd("TeamPlatformUI")
    if _Wnd == nil then
        return
    end
    GUI.SetVisible(_Wnd, true)

    print("... TeamPlatformUI OnShow")
    TeamPlatformUI.RefreshInfo()
    if parameter ~= nil then
        if string.find(parameter,"teamId:") then
            local matchrule = "teamId:(%d+)";
            local teamId = tonumber(string.match(parameter,matchrule));

            local index = 1
            local subIndex = 0
            for i = 0, TeamPlatformUI.TeamTypes.Count-1 do
                local teamConfig = TeamPlatformUI.TeamTypes[i];
                for j = 0, teamConfig.MissionID.Count-1 do
                    if teamConfig.MissionID[j]==teamId then
                        index =i+1;
                        subIndex= j;
                        local key = tostring((index-1)*100+subIndex)
                        TeamPlatformUI.OpenDefaultSubType(index,key)
                        return;
                    end
                end
            end
        end
    end
    TeamPlatformUI.SelectDefaultMissionType()
end

function TeamPlatformUI.OnEnhanceScrollViewSelectStateChange(ItemGUID, Valid)
    local TargetKey = GUI.GetName(GUI.GetByGuid(ItemGUID))
    local TargetSubKey = string.sub(TargetKey, 0, 8)
    local TargetItem = nil
    if TargetSubKey == "LevelMin" then
        TargetItem = GUI.GetChild(TeamPlatformUI.LevelMinScroll,TargetKey)
        if Valid and TargetItem ~= nil then
            local ItemTxt = GUI.StaticGetText(TargetItem)
            TeamPlatformUI.SelectLevelMin = tonumber(ItemTxt)
        end
    else
        TargetItem = GUI.GetChild(TeamPlatformUI.LevelMaxScroll,TargetKey)
        if Valid and TargetItem ~= nil then
            local ItemTxt = GUI.StaticGetText(TargetItem)
            TeamPlatformUI.SelectLevelMax = tonumber(ItemTxt)
        end
    end
end

function TeamPlatformUI.RefreshItems()
    if TeamPlatformUI.TeamTypes == nil then
        return
    end
    for i = 1,TeamPlatformUI.TeamTypes.Count do
        local _ListTypeBtn = _gt.GetUI("ListTypeBtn"..i)
        if _ListTypeBtn ~= nil then
            GUI.SetVisible(_ListTypeBtn,true)
            GUI.ButtonSetText(_ListTypeBtn,TeamPlatformUI.TeamTypes[i-1].TypeName)
            local _ListType = GUI.GetChildByPath(TeamPlatformUI.ScrollView,"ListType" .. i)
            local ChildCount = TeamPlatformUI.TeamTypes[i-1].MissionID.Count
            if _ListType ~= nil then
                --GUI.SetVisible(_ListType,true)
                for j=1,ChildCount do
                    local sonItem = GUI.GetChildByPath(TeamPlatformUI.ScrollView,"ListType" .. i.."/"..(100*(i-1)+(j-1)))
                    if sonItem ~= nil then
                        GUI.SetVisible(sonItem,true)
                        local Config = DB.GetActivity(TeamPlatformUI.TeamTypes[i - 1].MissionID[j - 1])
                        if Config ~= nil then
                            GUI.ButtonSetText(sonItem,Config.Name)
                        end
                    else
                        TeamPlatformUI.CreateSonItem(i,j,_ListType)
                    end
                end

                for j = ChildCount+1,  GUI.GetChildCount(_ListType) do
                    local sonItem = GUI.GetChildByPath(TeamPlatformUI.ScrollView,"ListType" .. i.."/"..(100*(i-1)+(j-1)))
                    GUI.SetVisible(sonItem,false)
                end
            end
        else
            TeamPlatformUI.CreateParentItem(i)
        end
    end

    for i = TeamPlatformUI.TeamTypes.Count+1, GUI.GetChildCount(TeamPlatformUI.ScrollView) do
        local _ListTypeBtn = _gt.GetUI("ListTypeBtn"..i)
        GUI.SetVisible(_ListTypeBtn,false);
        local _ListType = GUI.GetChildByPath(TeamPlatformUI.ScrollView,"ListType" .. i)
        GUI.SetVisible(_ListType,false);
    end
end

function TeamPlatformUI.CreateParentItem(i)
    local _ListTypeBtn = GUI.ButtonCreate( TeamPlatformUI.ScrollView,"ListTypeBtn" .. i, "1800002030", 0, 0, Transition.ColorTint, TeamPlatformUI.TeamTypes[i - 1].TypeName, 298, 65, false)
    _gt.BindName(_ListTypeBtn, "ListTypeBtn"..i)
    UILayout.SetSameAnchorAndPivot(_ListTypeBtn, UILayout.TopLeft)
    GUI.ButtonSetTextFontSize(_ListTypeBtn, 26)
    GUI.ButtonSetTextColor(_ListTypeBtn, colorDark)
    GUI.SetPreferredHeight(_ListTypeBtn, 74)
    GUI.RegisterUIEvent(_ListTypeBtn, UCE.PointerClick, "TeamPlatformUI", "OnListTypeBtn")

    --勾选框
    local _Check = GUI.CheckBoxCreate( _ListTypeBtn,"Check", "1800607150", "1800607151", 64, 34, Transition.ColorTint, true)
    UILayout.SetSameAnchorAndPivot(_Check, UILayout.TopLeft)
    GUI.CheckBoxSetCheck(_Check, i == 1)
    GUI.RegisterUIEvent(_Check, UCE.PointerClick, "TeamPlatformUI", "OnCheckBoxBtn")

    --方向箭头
    --local Arrow = GUI.ImageCreate( _ListTypeBtn,"Arrow", "1800607140", -50, 0)
    UILayout.SetAnchorAndPivot(Arrow, UIAnchor.Right, UIAroundPivot.Center)

    --子节点列表框
    local _ListType = GUI.ListCreate(TeamPlatformUI.ScrollView,"ListType" .. i, 6, 6, 298, 412, false)
    _gt.BindName(_ListType, "ListType"..i)
    UILayout.SetSameAnchorAndPivot(_ListType, UILayout.TopLeft)
    GUI.SetVisible(_ListType, i == 1)

    --子节点
    local SubCount = TeamPlatformUI.TeamTypes[i - 1].MissionID.Count
    for j = 1, SubCount do
        TeamPlatformUI.CreateSonItem(i,j,_ListType)
    end
end

function TeamPlatformUI.CreateSonItem(i,j,_ListType)
    local Config = DB.GetActivity(TeamPlatformUI.TeamTypes[i - 1].MissionID[j - 1])
    if Config ~= nil then
        local _ListTypeSubBtn = GUI.ButtonCreate( _ListType,tostring((i - 1) * 100 + (j - 1)), "1800602040", 0, 64, Transition.ColorTint, Config.Name, 298, 74, false)
        UILayout.SetSameAnchorAndPivot(_ListTypeSubBtn, UILayout.TopLeft)
        GUI.ButtonSetTextFontSize(_ListTypeSubBtn, 24)
        GUI.ButtonSetTextColor(_ListTypeSubBtn, colorDark)
        GUI.RegisterUIEvent(_ListTypeSubBtn, UCE.PointerClick, "TeamPlatformUI", "OnListTypeSubBtn")
    end
end

function TeamPlatformUI.OnfinalListTypeSubBtnCreate()
    if TeamPlatformUI.LastTypeIndex>0 and TeamPlatformUI.TeamTypes~=nil and TeamPlatformUI.TeamTypes.Count>0 then
        TeamPlatformUI.CalculateGridY(TeamPlatformUI.LastTypeIndex ,TeamPlatformUI.TeamTypes[TeamPlatformUI.LastTypeIndex -1].MissionID.Count)
    end
end

function TeamPlatformUI.ShowLevelSelectPanel(LevelMin, LevelMax, Desc)
    TeamPlatformUI.SelectLevelMin = LevelMin
    TeamPlatformUI.SelectLevelMax = LevelMax
    local NeedLevelMin = _gt.GetUI("NeedLevelMin")
    local NeedLevelMax = _gt.GetUI("NeedLevelMax")
    if NeedLevelMin and NeedLevelMax then
        GUI.StaticSetText(NeedLevelMin, tostring(LevelMin).."级")
        GUI.StaticSetText(NeedLevelMax, tostring(LevelMax).."级")
    end
    local Infos = _gt.GetUI("Infos")
    if Infos then
        GUI.StaticSetText(Infos, Desc)
    end
end

--在没有选择任务目标情况下的显示状态,即剧情任务-30级主线
function TeamPlatformUI.SelectDefaultMissionType()
    local TeamTargetInfo = LD.GetTeamTarget()
    if TeamTargetInfo.Count == 0 then--是默认选项
        TeamPlatformUI.OpenDefaultSubType(1,"0")
    else
        local index = 1
        local subIndex = 0
        for i=1,TeamPlatformUI.TeamTypes.Count do
            for j=1,TeamPlatformUI.TeamTypes[i-1].MissionID.Count do
                if TeamPlatformUI.TeamTypes[i-1].MissionID[j-1] == TeamTargetInfo[0] then
                    index = i
                    subIndex = j-1
                end
            end
        end
        local key = tostring((index-1)*100+subIndex)
        TeamPlatformUI.OpenDefaultSubType(index,key)
    end
end

function TeamPlatformUI.OpenDefaultSubType(Index,key)
    local _ListType = _gt.GetUI("ListType" .. Index)
    if _ListType ~= nil then
        GUI.SetVisible(_ListType, true)
    else
    end
    local Count = TeamPlatformUI.TeamTypes.Count
    for i = 1, Count do
        if i ~= Index then
            _ListType = _gt.GetUI("ListType" .. i)
            GUI.SetVisible(_ListType, false)
            local _Check = GUI.GetChildByPath(TeamPlatformUI.ScrollView,"ListTypeBtn" .. i .. "/Check")
            GUI.CheckBoxSetCheck(_Check, false)
        end
    end
    TeamPlatformUI.LastTypeIndex = Index
    local _Check = GUI.GetChildByPath(TeamPlatformUI.ScrollView,"ListTypeBtn" .. Index .. "/Check")
    GUI.CheckBoxSetCheck(_Check, true)
    TeamPlatformUI.OnListTypeSubBtn(nil, key);
    if Count > 0 then
        TeamPlatformUI.CalculateGridY(Index,TeamPlatformUI.TeamTypes[Index-1].MissionID.Count)
    end
end

--计算置顶ITEM百分比,分母需要减去listscroll本身的高度.
function TeamPlatformUI.CalculateGridY(index,sonCount)
    local per = 0
    if sonCount*TeamPlatformUI.SonItemH +
            TeamPlatformUI.TeamTypes.Count*TeamPlatformUI.ParentItemH-GUI.GetHeight(TeamPlatformUI.ScrollView) ~= 0 then
        per = (index-1)*TeamPlatformUI.ParentItemH / (sonCount*TeamPlatformUI.SonItemH +
                TeamPlatformUI.TeamTypes.Count*TeamPlatformUI.ParentItemH-GUI.GetHeight(TeamPlatformUI.ScrollView))
    end
    GUI.ScrollRectSetNormalizedPosition(TeamPlatformUI.ScrollView,Vector2.New(0,1-per));
end

function TeamPlatformUI.OnCheckBoxBtn(guid)
    local cb = GUI.GetByGuid(guid)
    local parent = GUI.GetParentElement(cb)
    TeamPlatformUI.OnListTypeBtn(GUI.GetGuid(parent))
end

function TeamPlatformUI.OnListTypeBtn(guid, key)
    local btn = guid ~= nil and GUI.GetByGuid(guid) or nil
    key = btn ~= nil and GUI.GetName(btn) or key
    local Index = tonumber(string.sub(key, 12))
    local _ListType = _gt.GetUI("ListType"..Index)
    if _ListType ~= nil then
        local IsVisible = GUI.GetVisible(_ListType)
        GUI.SetVisible(_ListType, IsVisible == false)
    end

    local Count = TeamPlatformUI.TeamTypes.Count
    for i = 1, Count do
        if i ~= Index then
            _ListType = _gt.GetUI("ListType"..i)
            GUI.SetVisible(_ListType, false)
            local _Check = GUI.GetChildByPath(TeamPlatformUI.ScrollView,"ListTypeBtn" .. i .. "/Check")
            GUI.CheckBoxSetCheck(_Check, false)
        end
    end

    local TeamTargetInfo = LD.GetTeamTarget()
    local upindex = 0
    local subIndex = 0
    if TeamTargetInfo.Count >= 6 then
        for i=1,TeamPlatformUI.TeamTypes.Count do
            for j=1,TeamPlatformUI.TeamTypes[i-1].MissionID.Count do
                if TeamPlatformUI.TeamTypes[i-1].MissionID[j-1] == TeamTargetInfo[0] then
                    upindex = i
                    subIndex = j-1
                end
            end
        end
    end
    if upindex == Index then
        local key = tostring((upindex-1)*100+subIndex)
        TeamPlatformUI.OnListTypeSubBtn(nil, key)
    else
        --默认选中此分类下的第一项
        if Index ~= TeamPlatformUI.LastTypeIndex then
            TeamPlatformUI.OnListTypeSubBtn(nil, tostring((Index - 1) * 100))
        end
    end
    TeamPlatformUI.LastTypeIndex = Index
    local _Check = GUI.GetChildByPath(TeamPlatformUI.ScrollView,"ListTypeBtn" .. Index .. "/Check")
    GUI.CheckBoxSetCheck(_Check, true)
end

function TeamPlatformUI.OnListTypeSubBtn(guid, key)
    local btn = guid ~= nil and GUI.GetByGuid(guid) or nil
    local Num = btn ~= nil and tonumber(GUI.GetName(btn)) or tonumber(key)
    local i = (Num - Num % 100) / 100
    local j = Num % 100
    if TeamPlatformUI.TeamTypes == nil or i<0 or i>= TeamPlatformUI.TeamTypes.Count then
        return
    end
    local Count = TeamPlatformUI.TeamTypes[i].MissionID.Count
    for m = 0, Count - 1 do
        local _ListTypeBtn = GUI.GetChildByPath(TeamPlatformUI.ScrollView,"ListType" .. (i + 1) .. "/" .. (i * 100 + m))
        if _ListTypeBtn ~= nil then
            if m == j then
                GUI.ButtonSetImageID(_ListTypeBtn, "1800602041")
            else
                GUI.ButtonSetImageID(_ListTypeBtn, "1800602040")
            end
        end
    end
    TeamPlatformUI.SelectConfig = DB.GetActivity(TeamPlatformUI.TeamTypes[i].MissionID[j])
    if TeamPlatformUI.SelectConfig  ~= nil then
        TeamPlatformUI.ShowLevelSelectPanel(TeamPlatformUI.SelectConfig.LevelMin, TeamPlatformUI.SelectConfig.LevelMax, TeamPlatformUI.SelectConfig.DesInfo)
    end
end

function TeamPlatformUI.OnOKBtn(key)
    --如果在非普通地图中，则提示无法招募
    local mapConfig = DB.GetOnceMapByKey1(CL.GetCurrentMapId())
    if mapConfig and (mapConfig.Type==2 or mapConfig.Type==3) then
        CL.SendNotify(NOTIFY.ShowBBMsg, "当前地图不可招募")
        return
    end

    --local SelfLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    -- 等级的下限不能超过自己的等级
    --暂移除此规则
    --TeamPlatformUI.SelectLevelMin = TeamPlatformUI.SelectLevelMin > SelfLevel and SelfLevel or TeamPlatformUI.SelectLevelMin
    --if TeamPlatformUI.SelectLevelMax >= TeamPlatformUI.SelectLevelMin then
        local _AutoMatchCheck = _gt.GetUI("AutoMatchCheck")
        if TeamPlatformUI.SelectConfig ~= nil and _AutoMatchCheck ~= nil then
            local AutoMatch = 0
            if GUI.CheckBoxGetCheck(_AutoMatchCheck) then
                AutoMatch = 1
            end
            local memberCnt = 0
            local _TeamInfo = LD.GetTeamInfo()
            if tostring(_TeamInfo.team_guid) ~= "0" and _TeamInfo.members ~= nil then
                memberCnt = _TeamInfo.members.Length
            end
            if memberCnt == 5 then
                CL.SendNotify(NOTIFY.ShowBBMsg, "队伍人满，无法进行匹配")
            else
                --如果没有加入帮派，则无法招募
                --if TeamPlatformUI.SelectConfig.Prestige9==2 and CL.GetIntAttr(RoleAttr.RoleAttrIsGuild)==0 then
                --    CL.SendNotify(NOTIFY.ShowBBMsg, "你没有帮派，无法招募")
                --    return
                --else
                    CL.SendNotify(NOTIFY.TeamOpeUpdate, 11, TeamPlatformUI.SelectConfig.Id, TeamPlatformUI.SelectLevelMin, TeamPlatformUI.SelectLevelMax, AutoMatch)
                --end
            end
            TeamPlatformUI.OnClose()
        end
    --else
    --    CL.SendNotify(NOTIFY.ShowBBMsg, "等级选择错误,请选择正确的等级范围")
    --end
end

function TeamPlatformUI.OnClose()
    TeamPlatformUI.LastTypeIndex = 0
    GUI.DestroyWnd("TeamPlatformUI")
end

function TeamPlatformUI.RefreshInfo()
    TeamPlatformUI.TeamTypes = LD.GetTeamTypes()
    TeamPlatformUI.RefreshItems()
    if TeamPlatformUI.SelectConfig then
        TeamPlatformUI.ShowLevelSelectPanel(TeamPlatformUI.SelectConfig.LevelMin, TeamPlatformUI.SelectConfig.LevelMax,TeamPlatformUI.SelectConfig.TurnMin, TeamPlatformUI.SelectConfig.TurnMax, TeamPlatformUI.SelectConfig.Info)
    end
end