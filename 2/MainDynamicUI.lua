--MainUI动态部分
local MainDynamicUI = {}

_G.MainDynamicUI = MainDynamicUI
local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local messageEventList = {
    { GM.PlayerEnterGame, "OnPlayerEnterGame" },
    { GM.FightStateNtf, "InFight" },
    { GM.MailUpdate, "OnMailUpdate" },
    { GM.LockScreenNotify, "OnLockScreenNotify" },
}

--
local enterGameOpenWind =
{
    "AttributeChangeTipUI"
}

local attributeEventList = {
    { RoleAttr.RoleAttrLevel, "OnSelfLevelChange" },
    { RoleAttr.RoleAttrFlyUp, "OnSelfFlyUpChange" },
}

function MainDynamicUI.CreateUI(panel)
    _gt = UILayout.NewGUIDUtilTable()
    _gt.BindName(panel, "panel")
    -- 天下会武按钮 1800602320
    local worldNoWarBtnMoveGroup = GUI.GroupCreate(panel, "worldNoWarBtnMoveGroup", -350, 130, 1, 1)
    _gt.BindName(worldNoWarBtnMoveGroup, "worldNoWarBtnMoveGroup")
    GUI.SetAnchor(worldNoWarBtnMoveGroup, UIAnchor.TopRight)
    GUI.SetPivot(worldNoWarBtnMoveGroup, UIAroundPivot.Center)
    GUI.StartGroupDrag(worldNoWarBtnMoveGroup)
    local worldNoWarBtn = GUI.ImageCreate(worldNoWarBtnMoveGroup, "worldNoWarBtn", "1800602320", 0, 0)
    GUI.SetAnchor(worldNoWarBtn, UIAnchor.Center)
    GUI.SetPivot(worldNoWarBtn, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(worldNoWarBtn, true)
    worldNoWarBtn:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(worldNoWarBtn, UCE.PointerClick, "MainDynamicUI", "OnWorldNoWarBtnClick")
    GUI.SetVisible(worldNoWarBtnMoveGroup, false)

    -- 天下第一按钮 1801202150
    local personalFightBtnMoveGroup = GUI.GroupCreate( panel, "personalFightBtnMoveGroup", -350, 130, 1, 1)
    _gt.BindName(personalFightBtnMoveGroup, "personalFightBtnMoveGroup")
    SetAnchorAndPivot(personalFightBtnMoveGroup, UIAnchor.TopRight, UIAroundPivot.Center)
    GUI.StartGroupDrag(personalFightBtnMoveGroup)
    local personalFightBtn = GUI.ImageCreate( personalFightBtnMoveGroup, "personalFightBtn", "1801202150", 0, 0);
    SetAnchorAndPivot(personalFightBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(personalFightBtn, true)
    personalFightBtn:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(personalFightBtn, UCE.PointerClick, "MainDynamicUI", "OnPersonalFightBtnClick")
    GUI.SetVisible(personalFightBtnMoveGroup,false)

    MainDynamicUI.RefreshFlyUpBtn(false)
    MainDynamicUI.CreateLeftDynamicUI(panel)
    MainDynamicUI.RefreshLeftDynamicUIVisible(CL.GetFightState())
    MainDynamicUI.EnterGameOpenWnd()
    MainDynamicUI.ClearInFightBtnList()
    MainDynamicUI.CreateBtnCenterInFight(panel)

    MainDynamicUI.RegisterMessage()
end

function MainDynamicUI.GetMoveGroupBtn()
	local worldNoWarBtnMoveGroup = _gt.GetUI("worldNoWarBtnMoveGroup")
	local personalFightBtnMoveGroup = _gt.GetUI("personalFightBtnMoveGroup")
	return worldNoWarBtnMoveGroup, personalFightBtnMoveGroup
end

-- 注册GM消息
function MainDynamicUI.RegisterMessage()
    for k, v in ipairs(messageEventList) do
        CL.UnRegisterMessage(v[1], "MainDynamicUI", v[2])
        CL.RegisterMessage(v[1], "MainDynamicUI", v[2])
    end
end

function MainDynamicUI.CreateLeftDynamicUI(panel)
    local list = MainUIBtnOpenDef.leftDynamicBtnList
    for i = 1, #list do
        local data = list[i]
        local func = MainDynamicUI[data[3]]
        if func then
            func(panel, data[2])
        end
    end
end

function MainDynamicUI.RefreshLeftDynamicUIVisible(inFight)
    if inFight == nil then
        inFight = CL.GetFightState()
    end
    inFight = inFight or CL.GetFightViewState() -- 观战也算在战斗中
    local list = MainUIBtnOpenDef.leftDynamicBtnList
    local idx = 1
    for i = 1, #list do
        local data = list[i]
        local group = _gt.GetUI(data[2])
        local visible = true
        if inFight then
            visible = false
            GUI.SetVisible(group, false)
        else
            local func = data[4] and MainDynamicUI[data[4]]
            if func then
                visible = func()
            end
            GUI.SetVisible(group, visible)
            if visible then
                local x, y = list.GetPos(idx)
                GUI.SetPositionX(group, x)
                GUI.SetPositionY(group, y)
                idx = idx + 1
            end
        end
        data.IsVisible = visible
    end
end

function MainDynamicUI.OnWorldNoWarBtnClick()
    GUI.OpenWnd("WorldNoWarUI")
end

function MainDynamicUI.OnPersonalFightBtnClick()
    GUI.OpenWnd("PersonalFightUI")
end

function MainDynamicUI.World_PVP_BtnRefresh(inFight)
    inFight = inFight ~= nil and inFight or CL.GetFightState()
    if MainDynamicUI.World_PVP_STATE == 1 and not inFight then
        local activity_data = DB.GetActivity(8)
        local show = CL.GetIntAttr(RoleAttr.RoleAttrLevel) >= activity_data.LevelMin
        MainDynamicUI.SetWorldNoWarBtnVisible(show)
    else
        MainDynamicUI.SetWorldNoWarBtnVisible(false)
    end

    if MainDynamicUI.Person_PVP_STATE == 1 and not inFight then
        test("判断后决定显示天下第一对战按钮")
        local activity_data = DB.GetActivity(22)
        local show = CL.GetIntAttr(RoleAttr.RoleAttrLevel) >= activity_data.LevelMin
        MainDynamicUI.SetPersonalFightBtnVisible(show)
    else
        MainDynamicUI.SetPersonalFightBtnVisible(false)
    end
end

function MainDynamicUI.SetWorldNoWarBtnVisible(canSee)
    local noWar = _gt.GetUI("worldNoWarBtnMoveGroup")
    if noWar then
        GUI.SetVisible(noWar, canSee)
		if TrackUI then
			local SumWidth = TrackUI.GetATWidth()
			if GUI.GetVisible(noWar) then
				GUI.SetPositionX(noWar, -SumWidth - 50)
			end
		end
    end
end

function MainDynamicUI.SetPersonalFightBtnVisible(canSee)
    local personalFightBtnMoveGroup = _gt.GetUI("personalFightBtnMoveGroup")
    if personalFightBtnMoveGroup then
        GUI.SetVisible(personalFightBtnMoveGroup, canSee)
		if TrackUI then
			local SumWidth = TrackUI.GetATWidth()
			if GUI.GetVisible(personalFightBtnMoveGroup) then
				GUI.SetPositionX(personalFightBtnMoveGroup, -SumWidth - 50)
			end
		end
    end
end

function MainDynamicUI.OnPlayerEnterGame()
    MainDynamicUI.RefreshWillOpenBtnState()
    CL.SendNotify(NOTIFY.SubmitForm, "FormLogin", "SyncSignState")
    for k, v in ipairs(attributeEventList) do
        if v[1] then
            CL.UnRegisterAttr(v[1], MainDynamicUI[v[2]])
            CL.RegisterAttr(v[1], MainDynamicUI[v[2]])
        end
    end
end

function MainDynamicUI.InFight(infight)
    MainDynamicUI.World_PVP_BtnRefresh(infight)
    MainDynamicUI.RefreshLeftDynamicUIVisible(infight)
    MainDynamicUI.RefreshFlyUpBtn(infight)
    if infight then
        MainDynamicUI.RefreshInFightBtnList()
    end
    MainDynamicUI.SetActiveBtnCenterInFight(infight)
end

function MainDynamicUI.OnSelfLevelChange(attrType, value)
    --MainDynamicUI.RefreshLeftDynamicUIVisible(CL.GetFightState())
    --MainDynamicUI.RefreshWillOpenBtnState()
    MainDynamicUI.StartActivityTimer(true)
    MainDynamicUI.GetForeShowTable()
    MainDynamicUI.RefreshFlyUpBtn(nil, nil, tonumber(tostring(value)))
end

function MainDynamicUI.OnSelfFlyUpChange(attrType, value)
    MainDynamicUI.RefreshFlyUpBtn(nil, tonumber(tostring(value)))
end

----------------------------------------------start 活动即将开启 start--------------------------------------
MainDynamicUI.WillOpenActivityIDList = nil
function MainDynamicUI.InitWillOpenActivityData()
    local temp = {}
    local configs = DB.GetActivityAllKeys()
    local count = configs.Count - 1
    for i = 0, count do
        local id = configs[i]
        local config = DB.GetActivity(id)
        if config.Show == 1 and config.Type == 1 then
            -- 只要限时活动
            temp[#temp + 1] = id
        end
    end
    MainDynamicUI.WillOpenActivityIDList = temp
end

local IsOpenActivityList = nil -- 已经开放的列表
local WillOpenActivityList = nil -- 即将开启的列表
local IsOpenActivity = nil -- 当前刚开启的活动
local WillOpenActivityStartTimeDis = -1 --下一个即将开启活动的间隔时间，如果隔天，则值为距离24点的倒计时
function MainDynamicUI.RefreshActivityData()
    IsOpenActivityList = {}
    WillOpenActivityList = {}
    IsOpenActivity = nil
    WillOpenActivityStartTimeDis = -1
    local curTickCount = CL.GetServerTickCount()
    local dateStr = string.split(os.date("!%d %w %H %M %S %m %Y", curTickCount), " ")
    local day = dateStr[1]
    local week = dateStr[2]
    local hour = dateStr[3]
    local minute = dateStr[4]
    local second = dateStr[5]
    local curTime = tonumber(hour) * 3600 + tonumber(minute) * 60 + tonumber(second)
    local curLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    local idList = MainDynamicUI.WillOpenActivityIDList or {}
    if #idList == 0 then
        WillOpenActivityStartTimeDis = 0
    end
    for i = 1, #idList do
        local id = idList[i]
        local config = DB.GetActivity(id)
        if config.LevelMin <= curLevel and config.LevelMax >= curLevel then
            if config.TimeType == 1 then
                -- 每天
                MainDynamicUI.SetActivityList(config.TimeStart, config.TimeEnd, curTime, id, config)
            elseif config.TimeType == 2 then
                -- 周循环
                if LogicDefine.CheckActivityDay(config.Time, week) then
                    MainDynamicUI.SetActivityList(config.TimeStart, config.TimeEnd, curTime, id, config)
                end
            end
        elseif config.TimeType == 3 then
            -- 月循环
            if LogicDefine.CheckActivityDay(config.Time, day) then
                MainDynamicUI.SetActivityList(config.TimeStart, config.TimeEnd, curTime, id, config)
            end
        end
    end
    table.sort(IsOpenActivityList, function(a, b)
        return a.StartTime < b.StartTime
    end)
    table.sort(WillOpenActivityList, function(a, b)
        return a.StartTime < b.StartTime
    end)
    if IsOpenActivity then
        table.insert(IsOpenActivityList, 1, IsOpenActivity)
    end
end

local internalTime = 600
function MainDynamicUI.SetActivityList(timestart, timeend, curTime, id, config)
    if timestart == "0" or timeend == "0" then
        IsOpenActivityList[#IsOpenActivityList + 1] = { ID = id, DBConfig = config, StartTime = 0 }
        return
    end
    local startStr = string.split(timestart, ":")
    local endstr = string.split(timeend, ":")
    if #startStr == 3 and #endstr == 3 then
        local s = tonumber(startStr[1]) * 3600 + tonumber(startStr[2]) * 60 + tonumber(startStr[3])
        local e = tonumber(endstr[1]) * 3600 + tonumber(endstr[2]) * 60 + tonumber(endstr[3])
        local temp = { ID = id, DBConfig = config, StartTime = s }
        if curTime < s then -- 未开启
            WillOpenActivityList[#WillOpenActivityList + 1] = temp

            --计算下一个活动开始的时间
            local timeDis = s - curTime
            if WillOpenActivityStartTimeDis == -1 then
                WillOpenActivityStartTimeDis = timeDis
            elseif timeDis < WillOpenActivityStartTimeDis then
                WillOpenActivityStartTimeDis = timeDis
            end
        elseif curTime <= e then -- 正在进行中
            if not IsOpenActivity and curTime - s < internalTime then
                IsOpenActivity = temp
            else
                IsOpenActivityList[#IsOpenActivityList + 1] = temp
            end
        end
    end
    if WillOpenActivityStartTimeDis == -1 then
        WillOpenActivityStartTimeDis = 86400-curTime
    end
    WillOpenActivityStartTimeDis = WillOpenActivityStartTimeDis<0 and 0 or WillOpenActivityStartTimeDis
end

local baseInfoColor = Color.New(255 / 255, 242 / 255, 208 / 255, 255 / 255)
-- 即将开启活动
function MainDynamicUI.CreateWillOpenActivityBtn(panel, name)
    local willOpenActivityGroup = _gt.GetUI(name) -- "willOpenActivityGroup"
    if not willOpenActivityGroup then
        MainDynamicUI.InitWillOpenActivityData()
        willOpenActivityGroup = GUI.GroupCreate(panel, name, 0, 0, 90, 90)
        _gt.BindName(willOpenActivityGroup, "willOpenActivityGroup")
        SetAnchorAndPivot(willOpenActivityGroup, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        local openActivityBtn = GUI.ButtonCreate(willOpenActivityGroup, "openActivityBtn", "1801401250", 68, 7, Transition.ColorTint)
        SetAnchorAndPivot(openActivityBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local icon = GUI.ButtonCreate(openActivityBtn, "icon", "1900000000", -51, 0, Transition.None, "", 70, 70, false)
        SetAnchorAndPivot(icon, UIAnchor.Left, UIAroundPivot.Left)
        GUI.SetIsRaycastTarget(icon, true)
        local effect = GUI.RichEditCreate(icon, "effect", "", 1, 22, 160, 185)
        SetAnchorAndPivot(effect, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(effect, 22)
        GUI.SetIsRaycastTarget(effect, false)
        GUI.SetScale(effect, Vector3.New(0.75, 0.75, 0.75))
        GUI.SetIsRaycastTarget(icon, true)
        GUI.RegisterUIEvent(icon, UCE.PointerClick, "MainDynamicUI", "OnWillOpenActivityListBtnClick")

        local name = GUI.CreateStatic(openActivityBtn, "name", "", 23, -12, 200, 50)
        SetAnchorAndPivot(name, UIAnchor.Left, UIAroundPivot.Left)
        GUI.SetColor(name, baseInfoColor)
        GUI.StaticSetFontSize(name, 22)

        local info = GUI.CreateStatic(openActivityBtn, "info", "", 23, 14, 100, 30, "system", true)
        SetAnchorAndPivot(info, UIAnchor.Left, UIAroundPivot.Left)
        GUI.SetColor(info, baseInfoColor)
        GUI.StaticSetFontSize(info, 20)
        GUI.RegisterUIEvent(openActivityBtn, UCE.PointerClick, "MainDynamicUI", "OnWillOpenActivityListBtnClick")

        GUI.SetVisible(willOpenActivityGroup, false)
    end
    MainDynamicUI.StartActivityTimer(true)
end

local importantInfoColor = Color.New(104 / 255, 70 / 255, 38 / 255, 255 / 255)
local importantInfoColor2 = Color.New(255 / 255, 242 / 255, 208 / 255, 255 / 255) -- Color HexNumber: fff2d0ff ，基础属性&基础信息
local willOpenActivityItemSize = Vector2.New(290, 103)
local allActicityBtnSize = Vector2.New(138, 50)
local willOpenBtnGuidList = nil
function MainDynamicUI.CreateWillOpenActivityBg()
    local parent = GUI.GetWnd("MainUI")--_gt.GetUI("willOpenActivityGroup")
    local tmpBg = GUI.ImageCreate(parent, "bgCover", "1800400220", 0, 0, false, GUI.GetWidth(parent), GUI.GetHeight(parent))
    GUI.SetIsRaycastTarget(tmpBg, true)
    tmpBg:RegisterEvent(UCE.PointerClick)
    GUI.SetColor(tmpBg, UIDefine.Transparent)
    local willOpenActivityBg = GUI.ImageCreate(tmpBg, "willOpenActivityBg", "1800400290", 250, 96, false, willOpenActivityItemSize.x + 20, allActicityBtnSize.y + 20)
    _gt.BindName(willOpenActivityBg, "willOpenActivityBg")
    SetAnchorAndPivot(willOpenActivityBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local willOpenBtn = GUI.ButtonCreate(willOpenActivityBg, "willOpenBtn", "1801302050", 10, -10, Transition.ColorTint, "", allActicityBtnSize.x, allActicityBtnSize.y, false)
    SetAnchorAndPivot(willOpenBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    GUI.ButtonSetTextFontSize(willOpenBtn, 22)
    GUI.ButtonSetText(willOpenBtn, "即将开启")
    GUI.ButtonSetTextColor(willOpenBtn, importantInfoColor)
    local btnSelectImage = GUI.ImageCreate(willOpenBtn, "btnSelectImage", "1801302051", 0, 0, false, GUI.GetWidth(willOpenBtn), GUI.GetHeight(willOpenBtn))
    SetAnchorAndPivot(btnSelectImage, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetDepth(btnSelectImage, 0)
    GUI.SetVisible(btnSelectImage, false)
    GUI.RegisterUIEvent(willOpenBtn, UCE.PointerClick, "MainDynamicUI", "OnIsOpenBtnClick")

    local isOpenBtn = GUI.ButtonCreate(willOpenActivityBg, "isOpenBtn", "1801302050", -10, -10, Transition.ColorTint, "", allActicityBtnSize.x, allActicityBtnSize.y, false)
    SetAnchorAndPivot(isOpenBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.ButtonSetTextFontSize(isOpenBtn, 22)
    GUI.ButtonSetText(isOpenBtn, "正在进行")
    GUI.ButtonSetTextColor(isOpenBtn, importantInfoColor)
    local btnSelectImage = GUI.ImageCreate(isOpenBtn, "btnSelectImage", "1801302051", 0, 0, false, GUI.GetWidth(willOpenBtn), GUI.GetHeight(willOpenBtn))
    GUI.SetDepth(btnSelectImage, 0)
    SetAnchorAndPivot(btnSelectImage, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(btnSelectImage, false)
    GUI.RegisterUIEvent(isOpenBtn, UCE.PointerClick, "MainDynamicUI", "OnIsOpenBtnClick")
    willOpenBtnGuidList = { GUI.GetGuid(willOpenBtn), GUI.GetGuid(isOpenBtn) }
    GUI.AddWhiteName(tmpBg, GUI.GetGuid(willOpenBtn))
    GUI.AddWhiteName(tmpBg, GUI.GetGuid(isOpenBtn))
    GUI.SetIsRemoveWhenClick(tmpBg, true)

    if not WillOpenActivityList or #WillOpenActivityList == 0 then
        GUI.ButtonSetShowDisable(willOpenBtn,false)
    elseif not IsOpenActivityList or #IsOpenActivityList == 0 then
        GUI.ButtonSetShowDisable(isOpenBtn,false)
    end
end

function MainDynamicUI.OnWillOpenActivityListBtnClick(guid)
    MainDynamicUI.CreateWillOpenActivityBg()
    if IsOpenActivity then
        MainDynamicUI.OnIsOpenBtnClick(willOpenBtnGuidList[2])
    else
        local index = #WillOpenActivityList > 0 and 1 or #IsOpenActivityList > 0 and 2 or 1
        MainDynamicUI.OnIsOpenBtnClick(willOpenBtnGuidList[index])
    end
end

function MainDynamicUI.OnIsOpenBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    if btn == nil then
        return
    end

    if willOpenBtnGuidList[1] == guid then
        MainDynamicUI.RefreshWillOpenActivity(WillOpenActivityList, true)
    else
        MainDynamicUI.RefreshWillOpenActivity(IsOpenActivityList, false)
    end

    for i = 1, #willOpenBtnGuidList do
        local btn = GUI.GetByGuid(willOpenBtnGuidList[i])
        if btn ~= nil then
            local btnSelectImage = GUI.GetChild(btn, "btnSelectImage")
            if willOpenBtnGuidList[i] == guid then
                GUI.SetVisible(btnSelectImage, true)
            else
                GUI.SetVisible(btnSelectImage, false)
            end
        end
    end
end

function MainDynamicUI.WillOpenActivityBtnVisible()
    if CL.GetFightState() then
        return false
    end
    if not WillOpenActivityList or not IsOpenActivityList or #WillOpenActivityList == 0 and #IsOpenActivityList == 0 then
        return false
    end
    return true
end

function MainDynamicUI.RefreshWillOpenBtnState()
    local wnd = GUI.GetWnd("MainUI")
    if not wnd then
        if MainDynamicUI.ActivityOpenTimer then
            MainDynamicUI.ActivityOpenTimer:Stop()
            MainDynamicUI.ActivityOpenTimer = nil
        end
        return
    else
        if not GUI.GetVisible(wnd) then
            return
        end
    end
    local inFight = CL.GetFightState()
    if inFight then
        return
    end

    --筛选出符合条件的活动数据
    MainDynamicUI.RefreshActivityData()

    --控制节点是否可见
    MainDynamicUI.RefreshLeftDynamicUIVisible(inFight)

    --设置正在进行的 或者 即将开启的 活动
    if IsOpenActivity then
        MainDynamicUI.RefreshWillOpenBtnInfo(IsOpenActivity.DBConfig)
    else
        local tmpActivity = #WillOpenActivityList > 0 and WillOpenActivityList[1].DBConfig or IsOpenActivityList[1] and IsOpenActivityList[1].DBConfig
        MainDynamicUI.RefreshWillOpenBtnInfo(tmpActivity)
    end
end

local itemGuid2ActivityId = nil
function MainDynamicUI.RefreshWillOpenActivity(tmpArr, isWill)
    local willOpenActivityBg = _gt.GetUI("willOpenActivityBg")
    local scr = GUI.GetChild(willOpenActivityBg, "scr")
    if scr then
        GUI.Destroy(scr)
    end
    itemGuid2ActivityId = {}
    local childCount = #tmpArr
    local internalY = 0
    local maxCount = 3
    local scrHeight = childCount > maxCount and maxCount * willOpenActivityItemSize.y + (maxCount - 1) * internalY or 3 * willOpenActivityItemSize.y + 2 * internalY
    local scr = GUI.ScrollRectCreate(willOpenActivityBg, "scr", 0, 10, willOpenActivityItemSize.x, scrHeight, 1, false, willOpenActivityItemSize, UIAroundPivot.Top, UIAnchor.Top)
    SetAnchorAndPivot(scr, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetHeight(willOpenActivityBg, 55 + 20 + scrHeight)
    for i = 1, #tmpArr do
        local child = GUI.ButtonCreate(scr, tostring(tmpArr[i].ID), "1801100010", 0, 0, Transition.ColorTint, "", willOpenActivityItemSize.x, willOpenActivityItemSize.y, false)
        SetAnchorAndPivot(child, UIAnchor.Top, UIAroundPivot.Top)
        itemGuid2ActivityId[GUI.GetGuid(child)] = tmpArr[i].ID
        local itemIcon = GUI.ItemCtrlCreate(child, "itemIcon", "1800400050", 16, 0, 80, 80, false)
        SetAnchorAndPivot(itemIcon, UIAnchor.Left, UIAroundPivot.Left)
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, tostring(tmpArr[i].DBConfig.Icon))
        GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, 0,70,70)

        local name = GUI.CreateStatic(child, "name", "", 100, -20, 200, 50)
        SetAnchorAndPivot(name, UIAnchor.Left, UIAroundPivot.Left)
        GUI.SetColor(name, importantInfoColor)
        GUI.StaticSetFontSize(name, 22)
        GUI.StaticSetText(name, tmpArr[i].DBConfig.Name)
        if isWill then
            local timeBg = GUI.ImageCreate(child, "timeBg", "1801401270", 100, 14, false, 96, 28)
            SetAnchorAndPivot(timeBg, UIAnchor.Left, UIAroundPivot.Left)
            local time = GUI.CreateStatic(timeBg, "time", "", 0, 0, 100, 30, "system", true)
            SetAnchorAndPivot(time, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetColor(time, importantInfoColor)
            GUI.StaticSetFontSize(time, 18)
            GUI.StaticSetText(time, "<color=#08af00>" .. MainDynamicUI.GetActivityStartTime(tmpArr[i].DBConfig) .. "</color> 开启")
            GUI.StaticSetAlignment(time, TextAnchor.MiddleCenter)
            GUI.RegisterUIEvent(child, UCE.PointerClick, "MainDynamicUI", "OnWillOpenActivityBtnClick")
        else
            if IsOpenActivity and IsOpenActivity.ID == tmpArr[i].ID then
                local effect = GUI.RichEditCreate(child, "effect", "", 5, 24, 330, 155)
                SetAnchorAndPivot(effect, UIAnchor.Center, UIAroundPivot.Center)
                GUI.StaticSetFontSize(effect, 22)
                GUI.StaticSetText(effect, "#IMAGE3409700000#")
                GUI.SetIsRaycastTarget(effect, false)
            end

            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, "1801507010")
            local leftTime = GUI.CreateStatic(child, "leftTime", "", 100, 14, 200, 30, "system", true)
            SetAnchorAndPivot(leftTime, UIAnchor.Left, UIAroundPivot.Left)
            GUI.SetColor(leftTime, importantInfoColor)
            GUI.StaticSetFontSize(leftTime, 18)
            local lastTotalTime = MainDynamicUI.GetActivityLastTime(tmpArr[i].DBConfig)
            local suffix = nil
            local lastTime = 0
            if lastTotalTime >= 60 then
                suffix = "小时"
                lastTime = math.floor(lastTotalTime / 60)
            else
                suffix = "分钟"
                lastTime = lastTotalTime < 0 and 0 or lastTotalTime
            end
            GUI.StaticSetText(leftTime, "<color=#08af00>立即参与(剩余" .. lastTime .. suffix .. ")</color> ")
            GUI.RegisterUIEvent(child, UCE.PointerClick, "MainDynamicUI", "OnJoinActivity")
        end
    end
end

function MainDynamicUI.RefreshWillOpenBtnInfo(activity)
    local willOpenActivityGroup = _gt.GetUI("willOpenActivityGroup")
    if activity == nil or willOpenActivityGroup == nil or GUI.GetVisible(willOpenActivityGroup) == false then
        return
    end
    local openActivityBtn = GUI.GetChild(willOpenActivityGroup, "openActivityBtn")
    local icon = GUI.GetChild(openActivityBtn, "icon")
    local name = GUI.GetChild(openActivityBtn, "name")
    local info = GUI.GetChild(openActivityBtn, "info")
    local effect = GUI.GetChild(icon, "effect")
    if #WillOpenActivityList > 0 then
        if IsOpenActivity then
            GUI.StaticSetText(effect, "#IMAGE3407700000#")
            GUI.SetVisible(effect, true)
        else
            GUI.SetVisible(effect, false)
        end
    else
        GUI.StaticSetText(effect, "#IMAGE3407700000#")
        GUI.SetVisible(effect, true)
    end

    GUI.ButtonSetImageID(icon, tostring(activity.Icon))
    GUI.StaticSetText(name, activity.Name)
    if IsOpenActivity and IsOpenActivity.ID == activity.Id then
        GUI.StaticSetText(info, "<color=#14fa09>立即参与</color>")
        GUI.SetData(openActivityBtn, "isOpen", "1")
        GUI.SetData(icon, "isOpen", "1")
    else
        if #WillOpenActivityList > 0 then
            GUI.StaticSetText(info, "<color=#14fa09>" .. MainDynamicUI.GetActivityStartTime(activity) .. "</color> 开启")
            GUI.SetData(openActivityBtn, "isOpen", "0")
            GUI.SetData(icon, "isOpen", "0")
        else
            GUI.StaticSetText(info, "<color=#14fa09>立即参与</color>")
            GUI.SetData(openActivityBtn, "isOpen", "1")
            GUI.SetData(icon, "isOpen", "1")
        end
    end
end

function MainDynamicUI.GetActivityStartTime(activity)
    if activity == nil then
        return "00:00"
    end
    if activity.TimeStart == "0" then
        return "00:00"
    else
        local timeStrArr = string.split(activity.TimeStart, ":")
        if #timeStrArr >= 2 then
            return timeStrArr[1] .. ":" .. timeStrArr[2]
        else
            return activity.TimeStart
        end
    end
end

function MainDynamicUI.GetActivityLastTime(activity)
    if activity == nil then
        return 0
    end
    local curTickCount = CL.GetServerTickCount()
    local dateStr = string.split(os.date("!%H %M %S", curTickCount), " ")
    local hour = tonumber(dateStr[1])
    local minute = tonumber(dateStr[2])
    local second = tonumber(dateStr[3])

    local activityEndHour = 24
    local activityEndMinute = 0
    if activity.TimeEnd ~= "0" then
        local timeStrArr = string.split(activity.TimeEnd, ":")
        if #timeStrArr >= 2 then
            activityEndHour = tonumber(timeStrArr[1])
            activityEndMinute = tonumber(timeStrArr[2])
        end
    end

    return activityEndHour * 60 + activityEndMinute - hour * 60 - minute
end

function MainDynamicUI.OnWillOpenActivityBtnClick(guid)
    GUI.OpenWnd("ActivityPanelUI", "index:2,index2:2")
end

function MainDynamicUI.OnJoinActivity(guid)
    local activityId = itemGuid2ActivityId[guid]
    if activityId then
        GlobalUtils.JoinActivity(activityId)
    end
end

function MainDynamicUI.StartActivityTimer(countOnce)
    ---if MainDynamicUI.ActivityOpenTimer == nil then
    ---    MainDynamicUI.ActivityOpenTimer = Timer.New(MainDynamicUI.RefreshWillOpenBtnState, 3, -1)
    ---    MainDynamicUI.ActivityOpenTimer:Start()
    ---end

    countOnce = countOnce or false
    if countOnce then
        WillOpenActivityStartTimeDis = 0
    end
    --3秒一次遍历整张活动表[3s,900K-69ms]？优化为：直到下一个新开启的活动时间才刷新数据即可
    if MainDynamicUI.ActivityOpenTimer then
        MainDynamicUI.ActivityOpenTimer:Stop()
        MainDynamicUI.ActivityOpenTimer = nil
    end
    if WillOpenActivityStartTimeDis ~= -1 then
        MainDynamicUI.ActivityOpenTimer = Timer.New(MainDynamicUI.OnActivityTimer, WillOpenActivityStartTimeDis + 3, 1)
        MainDynamicUI.ActivityOpenTimer:Start()
    end
end

function MainDynamicUI.OnActivityTimer()
    MainDynamicUI.RefreshWillOpenBtnState()
    MainDynamicUI.StartActivityTimer()
end
----------------------------------------------end 活动即将开启 end-------------------------------------

----------------------------------------------start 功能预览 start--------------------------------------
function MainDynamicUI.CreateFunctionPreviewBtn(panel, name)
    local functionPreviewGroup = _gt.GetUI(name)
    if not functionPreviewGroup then
        functionPreviewGroup = GUI.GroupCreate(panel, name, 0, 0, 90, 90)
        _gt.BindName(functionPreviewGroup, name)
        SetAnchorAndPivot(functionPreviewGroup, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        -- 创建功能预览按钮
        MainDynamicUI.CreateForeShow(functionPreviewGroup)
        MainDynamicUI.GetForeShowTable()
    end
end

function MainDynamicUI.FunctionPreviewBtnVisible()
    if not MainDynamicUI.GetPreviewState()  then
        return false
    end
    return true
end

function MainDynamicUI.GetPreviewState()
    MainDynamicUI.ConfigListShow = {}
    local ConfigOldList = {}
    if not GlobalProcessing.SwitchOnAwardData then
        return false
    end
    for key, config in pairs(GlobalProcessing.SwitchOnAwardData) do
        table.insert(ConfigOldList, config)
    end
    for i = 1, #ConfigOldList do
        if ConfigOldList[i].CanTake ~= 2 then
            table.insert(MainDynamicUI.ConfigListShow, ConfigOldList[i])
        end
    end
    return MainDynamicUI.ConfigListShow and #MainDynamicUI.ConfigListShow > 0
end

-- 创建主界面按钮UI
function MainDynamicUI.CreateForeShow(parentPanel)
    local previewBtnBg = GUI.ImageCreate(parentPanel, "PreviewBtnBg", "1801202060", 5, 0, false, 90, 90)
    _gt.BindName(previewBtnBg, "PreviewBtnBg")
    SetAnchorAndPivot(previewBtnBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(previewBtnBg, true)

    local previewBtn = GUI.ButtonCreate(previewBtnBg, "FunctionPreviewBtn", "1800202160", 0, 0, Transition.Animation, "", 0, 0, true)
    _gt.BindName(previewBtn, "FunctionPreviewBtn")
    SetAnchorAndPivot(previewBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.AddRedPoint(previewBtn, UIAnchor.TopLeft)

    previewBtn:RegisterEvent(UCE.PointerUp)
    previewBtn:RegisterEvent(UCE.PointerDown)
    local redPoint = GUI.GetChild(previewBtn, "redPoint")
    GUI.SetPositionX(redPoint, 6)
    GUI.SetPositionY(redPoint, 2)
    GUI.SetRedPointVisable(previewBtn, false)
    GUI.RegisterUIEvent(previewBtn, UCE.PointerDown, "MainDynamicUI", "BtnPointDown")
    GUI.RegisterUIEvent(previewBtn, UCE.PointerUp, "MainDynamicUI", "BtnPointUp")
    GUI.RegisterUIEvent(previewBtn, UCE.PointerClick, "MainDynamicUI", "OnClickPreviewBtn")

    local level = GUI.CreateStatic(previewBtn, "Level", "30级", 0, -22, 100, 35)
    SetAnchorAndPivot(level, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.StaticSetAlignment(level, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(level, 20)
    GUI.SetIsOutLine(level, true)
    GUI.SetOutLine_Setting(level,OutLineSetting.OUTLINE_BROWN6_1)
    GUI.SetOutLine_Color(level, UIDefine.Brown6Color)
    GUI.SetOutLine_Distance(level, 1)
    GUI.SetColor(level, UIDefine.WhiteColor)

    local name = GUI.CreateStatic(previewBtn, "Name", "内容名字", 0, 0, 100, 35)
    SetAnchorAndPivot(name, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(name, 20)
    GUI.SetIsOutLine(name, true)
    GUI.SetOutLine_Setting(name,OutLineSetting.OUTLINE_BROWN6_1)
    GUI.SetOutLine_Color(name, UIDefine.Brown6Color)
    GUI.SetOutLine_Distance(name, 1)
    GUI.SetColor(name, UIDefine.WhiteColor)

    -- TODO
    local giftBg = GUI.ImageCreate(previewBtnBg, "GiftBg", "1800400290", 125, 0, false, 168, 70)
    _gt.BindName(giftBg, "GiftBg")
    SetAnchorAndPivot(giftBg, UIAnchor.Center, UIAroundPivot.Center)
    local giftArrow = GUI.ImageCreate(giftBg, "GiftArrow", "1801401260", -91, 0)
    SetAnchorAndPivot(giftArrow, UIAnchor.Center, UIAroundPivot.Center)
    local giftLabel = GUI.CreateStatic(giftBg, "GiftLabel", "有未领取的预告奖励！", 2, 0, 150, 65, "system", true, false)
    SetAnchorAndPivot(giftLabel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(giftLabel, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(giftLabel, 24)
    GUI.SetColor(giftLabel, importantInfoColor2)
    GUI.SetVisible(giftBg, false)
end

function MainDynamicUI.GetForeShowTable()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGetAward", "GetData")
end

-- 初始化Config数据
function MainDynamicUI.InitConfig()
    MainDynamicUI.ConfigList = {}
    local ConfigOldList = {}
    for key, config in pairs(GlobalProcessing.SwitchOnAwardData) do
        table.insert(ConfigOldList, config)
    end
    for i = 1, #ConfigOldList do
        if ConfigOldList[i].CanTake ~= 2 then
            table.insert(MainDynamicUI.ConfigList, ConfigOldList[i])
        end
    end

    table.sort(MainDynamicUI.ConfigList, function(a, b)
        if a.LevelParam[1] ~= b.LevelParam[1] then
            return a.LevelParam[1] < b.LevelParam[1]
        end
        if a.LevelParam[2] ~= b.LevelParam[2] then
            return a.LevelParam[2] < b.LevelParam[2]
        end
        if a.Id ~= b.Id then
            return a.Id < b.Id
        end
        return false
    end)
end

function MainDynamicUI.RefreshForeShowTable()
    MainDynamicUI.InitConfig()
    local previewBtn = _gt.GetUI("FunctionPreviewBtn")
    if not previewBtn then return end

    local previewBtnBg = _gt.GetUI("PreviewBtnBg")
    if not MainDynamicUI.ConfigList or #MainDynamicUI.ConfigList == 0 then
        GUI.SetVisible(previewBtnBg, false)
        return
    end

    GUI.SetVisible(previewBtnBg, true)
    local rein = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
    local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    local config = MainDynamicUI.ConfigList[#MainDynamicUI.ConfigList]

    GUI.ButtonSetImageID(previewBtn, config.Icon or "1800202100")

    local level = GUI.GetChild(previewBtn, "Level")
    if level then
        local cfgRein = tonumber(config.LevelParam[1])
        local cfgLevel =  tonumber(config.LevelParam[2])
        if cfgRein ==0 then
            GUI.StaticSetText(level, string.format("%d级", cfgLevel))
        else
            GUI.StaticSetText(level, string.format("%d转%d级", cfgRein, cfgLevel))
        end
    end

    local name = GUI.GetChild(previewBtn, "Name")
    if name then
        GUI.StaticSetText(name, config.Title)
    end

    local index = 0
    for i = 1, #MainDynamicUI.ConfigList do
        if MainDynamicUI.ConfigList[i].LevelParam[2] <= roleLevel then
            index = i
        end
    end

    local vis = index > 0 or (rein >= config.LevelParam[1] and config.LevelParam[2] <= roleLevel);
    GUI.SetRedPointVisable(previewBtn, vis)
    local giftBg = _gt.GetUI("GiftBg")
    local IsShowNum = 0
    for i = 1, #MainDynamicUI.ConfigList do
        if tonumber(MainDynamicUI.ConfigList[i]["CanTake"]) == 1 then
            IsShowNum = IsShowNum + 1
        end
    end
    if IsShowNum > 0 then
        GUI.SetVisible(giftBg, true)
    else
        GUI.SetVisible(giftBg, false)
    end
end

function MainDynamicUI.BtnPointDown(guid)
    local btn = GUI.GetByGuid(guid)
    if btn ~= nil then
        MainDynamicUI.BtnDoTweenScale(btn, true)
    end
end

function MainDynamicUI.BtnPointUp(guid)
    local btn = GUI.GetByGuid(guid)
    if btn ~= nil then
        MainDynamicUI.BtnDoTweenScale(btn, false)
    end
end

function MainDynamicUI.BtnDoTweenScale(btn, bo)
    if bo then
        GUI.DOTween(btn, "6")
    else
        GUI.DOTween(btn, "7")
    end
end

-- 功能预告按钮被点击
function MainDynamicUI.OnClickPreviewBtn(guid)
    GUI.OpenWnd("FunctionPreviewUI")
end

----------------------------------------------end 功能预览 end-------------------------------------

----------------------------------------------start 飞升 start--------------------------------------
function MainDynamicUI.FlyUpServerData(data)
    MainDynamicUI.FlyUpData = data
    MainDynamicUI.RefreshFlyUpBtn()
    if NOTIFY.FlyUpEffectNtf then
        local effectList = data["FlyUpEffect"]
        local temp = {}
        for i = 1, #effectList do
            local effectID = effectList[i]
            if string.match(effectID, "[^0-9]") then
                effectList[i] = uint64.new("3000001447")
                temp[#temp + 1] = "3000001447"
            else
                effectList[i] = uint64.new(effectID)
                temp[#temp + 1] = effectID
            end
        end
        local par = table.concat(temp, "#")
        CL.SendNotify(NOTIFY.FlyUpEffectNtf, par)
    end
end

function MainDynamicUI.CheckFlyUpState(flyUp, level)
    if not MainDynamicUI.FlyUpData or not MainDynamicUI.FlyUpData.FlyUpLevel_Config then
        return false
    end
    local race = CL.GetIntAttr(RoleAttr.RoleAttrRace)
    local data = MainDynamicUI.FlyUpData.FlyUpLevel_Config["Race" .. race]
    if not data then
        return false
    end
    local curFlyUp = flyUp or RoleAttr.RoleAttrFlyUp and CL.GetIntAttr(RoleAttr.RoleAttrFlyUp) or 0
    local fuConfig = data["FlyUp" .. curFlyUp]
    if not fuConfig then
        return false
    end
    local nextFlyUp = curFlyUp + 1
    local nextConfig = data["FlyUp" .. nextFlyUp]
    -- 如果没有下一级飞升的配置，说明已经达到飞升的最高级
    if not nextConfig then
        return false
    end
    local rein = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
    level = level or CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    -- 只有转生次数，等级，飞升次数都相等时才能飞升
    return rein == fuConfig.Reincarnation and level == fuConfig.Level and curFlyUp == fuConfig.FlyUp
end

function MainDynamicUI.RefreshFlyUpBtn(inFight, flyUp, level)
    if inFight == nil then
        inFight = CL.GetFightState()
    end
    inFight = inFight or CL.GetFightViewState() -- 观战也算在战斗中
    local btn = _gt.GetUI("flyUpBtn")
    if inFight then
        if btn then
            GUI.SetVisible(btn, false)
        end
        return
    end
    local visible = MainDynamicUI.CheckFlyUpState(flyUp, level)
    if not visible then
        if btn then
            GUI.SetVisible(btn, false)
        end
        return
    end
    if not btn then
        local panel = _gt.GetUI("panel")
        btn = GUI.ButtonCreate(panel, "flyUpBtn", "1900801533", -293, 309, Transition.Animation, "", 66, 66, false)
        _gt.BindName(btn, "flyUpBtn")
        SetAnchorAndPivot(btn, UIAnchor.TopRight, UIAroundPivot.Center)
        btn:RegisterEvent(UCE.PointerUp)
        btn:RegisterEvent(UCE.PointerDown)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "MainDynamicUI", "OnClickFlyUpBtn")
        GUI.RegisterUIEvent(btn, UCE.PointerDown, "MainUI", "BtnPointDown")
        GUI.RegisterUIEvent(btn, UCE.PointerUp, "MainUI", "BtnPointUp")

        local txt = GUI.CreateStatic(btn, "flyUpBtnTxt", "飞升", 0, 15, 100, 50)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Bottom)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
        GUI.SetIsOutLine(txt, true)
        GUI.SetOutLine_Color(txt, UIDefine.Brown6Color)
        GUI.SetOutLine_Distance(txt, 1)
        GUI.SetColor(txt, UIDefine.WhiteColor)
        local effect = GUI.SpriteFrameCreate(btn, "effect", "", 0, 0)
        GUI.SetFrameId(effect, "3403700000")
        UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
        GUI.SpriteFrameSetIsLoop(effect, true)
        GUI.Play(effect)
    else
        GUI.SetVisible(btn, true)
    end
end

function MainDynamicUI.WhetherCanStartAutoMove()
    if LD.GetRoleInTeamState(0) == 3 then
        return false
    end
    return true
end

function MainDynamicUI.OnClickFlyUpBtn()
    if not MainDynamicUI.WhetherCanStartAutoMove() then
        return
    end
    local npcId = MainDynamicUI.FlyUpData and MainDynamicUI.FlyUpData.NPCID or 0
    LD.StartAutoMove(npcId)
end

function MainDynamicUI.GetFlyUpEffectID(flyUp)
    return MainDynamicUI.FlyUpData and MainDynamicUI.FlyUpData.FlyUpEffect[flyUp] or uint64.zero
end
----------------------------------------------end 飞升 end-------------------------------------
----------------------------------------------start 锁屏 start-------------------------------------
function MainDynamicUI.OnLockScreenNotify(isOpen)
    if CL.IsStoryMode() then
        return
    end
    local list = {"NpcDialogMovieUI", "NpcDialogFullUI"}
    for i = 1, #list do
        if GUI.GetVisible(GUI.GetWnd(list[i])) then
            return
        end
    end
    GUI.OpenWnd("ScreenLockUI")
end
----------------------------------------------end 锁屏 end-------------------------------------
----------------------------------------------start 战斗中系统功能按钮 start------------------------------------
local inFightBtnList = nil
function MainDynamicUI.CreateBtnCenterInFight(panel)
    local btnCenterInFight = GUI.GroupCreate(panel, "btnCenterInFight", 0, 0, GUI.GetWidth(panel), GUI.GetHeight(panel))
    SetAnchorAndPivot(btnCenterInFight, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(btnCenterInFight, "btnCenterInFight")

    local btn = GUI.ButtonCreate(btnCenterInFight, "btn", "1800202470", 20, 120, Transition.None, "", 0, 0, true);
    SetAnchorAndPivot(btn, UIAnchor.TopLeft, UIAroundPivot.Center)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "MainDynamicUI", "OpenBtnCenterInFight")

    local btnCenterBg = GUI.ImageCreate(btnCenterInFight, "btnCenterBg", "1800400290", 0, 85, false, 400, 400)
    SetAnchorAndPivot(btnCenterBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(btnCenterBg, "btnCenterBg")

    MainDynamicUI.SetActiveBtnCenterInFight(false);
end

function MainDynamicUI.RefreshInFightBtnList()
    local currentLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    local rein = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
    inFightBtnList = inFightBtnList or {}
    local tempBtnList = {}
    local data = MainUIBtnOpenDef.Data
    local temp = { MainUIBtnOpenDef.buttonLeftLst, MainUIBtnOpenDef.buttonLeftTopLst, MainUIBtnOpenDef.buttonRightBottomLst }
    for i = 1, #temp do
        local list = temp[i]
        for j = 1, #list do
            local d = list[j]
            local t = data[d[6]]
            if t.VisFun and t:VisFun(currentLevel, nil, rein) == 1 and d.priority then
                tempBtnList[#tempBtnList + 1] = d
            end
        end
    end

    if #tempBtnList == #inFightBtnList then
        return
    end
    inFightBtnList = tempBtnList
    table.sort(inFightBtnList, function(a, b)
        return a.priority < b.priority
    end)
    MainDynamicUI.RefreshBtnCenterInFight()
end

function MainDynamicUI.RefreshBtnCenterInFight()
    local btnScroll = _gt.GetUI("btnScroll")
    if btnScroll then
        GUI.Destroy(btnScroll)
    end
    local btnCenterBg = _gt.GetUI("btnCenterBg")
    local btnScroll = GUI.ScrollRectCreate(btnCenterBg, "btnScroll", 10, 10, 380, 380, 0, false, Vector2.New(70, 70), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 5);
    GUI.ScrollRectSetChildSpacing(btnScroll, Vector2.New(8, 8))
    _gt.BindName(btnScroll, "btnScroll")
    for i = 1, #inFightBtnList do
        local data = inFightBtnList[i]
        local btn = GUI.ButtonCreate(btnScroll, data[2], data[3], 0, 0, Transition.Animation, "", 0, 0, true)
        SetAnchorAndPivot(btn, UIAnchor.Center, UIAroundPivot.Center)
        btn:RegisterEvent(UCE.PointerUp)
        btn:RegisterEvent(UCE.PointerDown)
        if data.OnClick then
            GUI.RegisterUIEvent(btn, UCE.PointerClick, "MainUI", data.OnClick)
        else
            GUI.RegisterUIEvent(btn, UCE.PointerClick, "MainUI", "OnBtnClick")
        end
        GUI.RegisterUIEvent(btn, UCE.PointerDown, "MainUI", "BtnPointDown")
        GUI.RegisterUIEvent(btn, UCE.PointerUp, "MainUI", "BtnPointUp")

        if data[5] == "0" then
            local txt = GUI.CreateStatic(btn, data[2] .. "Txt", data[1], 0, 15, 100, 50)
            GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Bottom)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
            GUI.SetIsOutLine(txt, true)
            GUI.SetOutLine_Setting(txt, OutLineSetting.OUTLINE_BROWN6_1)
            GUI.SetOutLine_Color(txt, UIDefine.Brown6Color)
            GUI.SetOutLine_Distance(txt, 1)
            GUI.SetColor(txt, UIDefine.WhiteColor)
        else
            local showIcon = GUI.ImageCreate(btn, data[2] .. "Icon", data[5], 0, 0, false)
            SetAnchorAndPivot(showIcon, UIAnchor.Bottom, UIAroundPivot.Bottom)
        end
    end
end

function MainDynamicUI.ShowBtnCenterInFight(state)
    local btnCenterInFight = _gt.GetUI("btnCenterInFight")
    local btn = GUI.GetChild(btnCenterInFight, "btn")
    local btnCenterBg = GUI.GetChild(btnCenterInFight, "btnCenterBg")
    if state == true then
        local tweenScale = TweenData.New()
        tweenScale.Type = GUITweenType.DOScale
        tweenScale.From = Vector3.zero
        tweenScale.To = Vector3.one
        tweenScale.Duration = 0.3
        GUI.DOTween(btnCenterBg, tweenScale, "FightBtnBgScale")

        GUI.SetEulerAngles(btn, Vector3.New(0, 0, 90))
        local tween = TweenData.New()
        tween.Type = GUITweenType.DOLocalMove
        tween.From = Vector3.New(20, 120, 0)
        tween.To = Vector3.New(420, 120, 0)
        tween.Duration = 0.3;
        GUI.DOTween(btn, tween, "Temp")
        GUI.SetData(btn, "state", 1)
    elseif state == false then
        local tweenScale = TweenData.New()
        tweenScale.Type = GUITweenType.DOScale
        tweenScale.From = Vector3.one
        tweenScale.To = Vector3.zero
        tweenScale.Duration = 0.3
        GUI.DOTween(btnCenterBg, tweenScale, "FightBtnBgScale")
        GUI.SetEulerAngles(btn, Vector3.New(0, 0, -90));
        local tween = TweenData.New()
        tween.Type = GUITweenType.DOLocalMove
        tween.From = Vector3.New(420, 120, 0);
        tween.To = Vector3.New(20, 120, 0);
        tween.Duration = 0.3;
        GUI.DOTween(btn, tween, "Temp");
        GUI.SetData(btn, "state", 0);
    end
end

function MainDynamicUI.SetActiveBtnCenterInFight(active)
    local btnCenterInFight = _gt.GetUI("btnCenterInFight")
    local btn = GUI.GetChild(btnCenterInFight, "btn")
    local btnCenterBg = GUI.GetChild(btnCenterInFight, "btnCenterBg")
    if active == true then
        GUI.SetVisible(btnCenterInFight, true)
    elseif active == false then
        GUI.SetVisible(btnCenterInFight, false)
    end

    GUI.SetEulerAngles(btn, Vector3.New(0, 0, -90))
    GUI.SetPositionX(btn, 20);
    GUI.SetPositionY(btn, 120);
    GUI.SetScale(btnCenterBg, Vector3.New(0, 0, 0))
    GUI.SetData(btn, "state", 0);
end

function MainDynamicUI.OpenBtnCenterInFight(guid)
    local btn = GUI.GetByGuid(guid);
    local state = GUI.GetData(btn, "state");
    if state == "0" then
        MainDynamicUI.ShowBtnCenterInFight(true)
    elseif state == "1" then
        MainDynamicUI.ShowBtnCenterInFight(false)
    end
end

function MainDynamicUI.ClearInFightBtnList()
    inFightBtnList = nil
end
----------------------------------------------end 战斗中系统功能按钮 end------------------------------------


function MainDynamicUI.EnterGameOpenWnd()
    for i = 1, #enterGameOpenWind do
        GUI.OpenWnd(enterGameOpenWind[i])
    end
end

--- 服务端脚本调用，新手引导相关
function MainDynamicUI.GetDynamicBtnListIndex(name)
    local list = MainUIBtnOpenDef.leftDynamicBtnList
    local index = 0
    if list then
        for i = 1, #list do
            local data = list[i]
            if data and data.IsVisible then
                index = index + 1
                if data[2] == name then
                    return index
                end
            end
        end
    end
    return 0
end