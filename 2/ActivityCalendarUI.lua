local ActivityCalendarUI = {}

_G.ActivityCalendarUI = ActivityCalendarUI
local GuidCacheUtil = nil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local ColorType_FontColor3 = UIDefine.Brown4Color --Color.New(109 / 255, 60 / 255, 24 / 255)
local ColorType_FontColor2 = UIDefine.BrownColor --Color.New(102 / 255, 47 / 255, 22 / 255)
local ColorType_White = UIDefine.WhiteColor -- Color.New(255 / 255, 255 / 255, 255 / 255)
local ColorType_Red = UIDefine.RedColor --Color.New(255 / 255, 60 / 255, 60 / 255)
local btnColorOutline = UIDefine.Orange2Color --Color.New(162 / 255, 75 / 255, 21 / 255)        --按钮描边
local ColorType_Black = Color.New(0 / 255, 0 / 255, 0 / 255)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)

local ColorType_Yellow_ActivityTips = UIDefine.YellowColor -- Color.New(221 / 255, 210 / 255, 33 / 255)        --活动tips黄色文字
local ColorType_Blue_ActivityTips = UIDefine.Blue4Color -- Color.New(66 / 255, 210 / 177, 240 / 255)        --活动tips蓝色文字
local ColorType_YellowName_ActivityTips = UIDefine.Yellow4Color --Color.New(251 / 255, 222 / 177, 183 / 255)        --活动tips黄色名字文字

local fontSize = 22
local fontSize_BigOne = 24
local fontSize_BigTwo = 26

local ActivityType = {
    ALL = 1,
    LIMIT = 2,
    DAILY = 3,
    FESTIVAL = 4,
    LEVEL = 5,
    NO_OPEN = 6,
}

local toggleList = {
    { ActivityType.ALL, "AllActivity", "全部", "OnActivityTypeToggleClick" },
    { ActivityType.LIMIT, "LimitTimeActivity", "限时", "OnActivityTypeToggleClick" },
    { ActivityType.DAILY, "DailyActivity", "日常", "OnActivityTypeToggleClick" },
    { ActivityType.FESTIVAL, "FestivalActivity", "节日", "OnActivityTypeToggleClick" },
    { ActivityType.LEVEL, "CurrentLevelActivity", "对应等级", "OnActivityTypeToggleClick" },
    { ActivityType.NO_OPEN, "NotOpenActivity", "即将开启", "OnActivityTypeToggleClick" },
}
local toggleGuid2Type = {}

local activityInfo = {
    { 1, "活动时间", "time", 141, -390 },
    { 0, "活动名称", "name", 220, -210 },
    { 0, "活动类型", "type", 105, -48 },
    { 0, "等级限制", "level", 122, 65 },
    { 0, "人数限制", "num", 143, 197 },
    { -1, "奖励星级", "star", 192, 364 },
}

local leftBtnList = {
    { 1, "周一", "OnDayBtnClick" },
    { 2, "周二", "OnDayBtnClick" },
    { 3, "周三", "OnDayBtnClick" },
    { 4, "周四", "OnDayBtnClick" },
    { 5, "周五", "OnDayBtnClick" },
    { 6, "周六", "OnDayBtnClick" },
    { 7, "周日", "OnDayBtnClick" },
}
local leftBtnGuid2Day = {}

local Type2String = {
    [0] = "日常活动",
    [1] = "限时活动",
    [2] = "节日活动",
}
local defaultIcon = "1801109130"

local lastSelectActivityBtnGuid = nil
local AllActivityConfig = {}
local CurSelectDay = 1 -- 当前选中星期中的第几天
local CurSelectType = ActivityType.ALL

local QualityRes = UIDefine.ItemIconBg

local messageEventList = {
    { GM.FightStateNtf, "InFight" },
}

function ActivityCalendarUI.Main(parameter)
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("ActivityCalendarUI", "ActivityCalendarUI", 0, 0, eCanvasGroup.Normal)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)

    local w = 1090
    local h = 610
    local panelCover = GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    GuidCacheUtil.BindName(panelCover, "panelCover")
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)
    GUI.SetVisible(panelCover, false)
    local panelBg = GUI.GroupCreate(panel, "panelBg", 0, 6, w, h)
    GuidCacheUtil.BindName(panelBg, "panelBg")
    GUI.SetVisible(panelBg, false)
    local topBar_X = math.ceil(w / 4)
    local topBar_Width = math.ceil(w / 2)

    local topBarLeft = GUI.ImageCreate(panelBg, "topBarLeft", "1800600180", topBar_X, 28, false, topBar_Width, 54)
    SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

    local topBarRight = GUI.ImageCreate(panelBg, "topBarRight", "1800600181", -topBar_X, 28, false, topBar_Width, 54)
    SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

    local topBarCenter = GUI.ImageCreate(panelBg, "topBarCenter", "1800600190", -6, 27, false, 267, 50)
    SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

    local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800302120", 0, 4, Transition.ColorTint)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    local tipLabel = GUI.CreateStatic(panelBg, "tipLabel", "活动日历", -6, 27, 200, 40)
    GUI.StaticSetFontSize(tipLabel, 26)
    GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(tipLabel, colorDark)
    SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)

    local closeBtn = GUI.GetChild(panelBg, "closeBtn")
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "ActivityCalendarUI", "OnCloseBtnClick")

    local btnScr = GUI.ScrollRectCreate(panelBg,"btnScr", 12, 90, 132, 498, 50, false, Vector2.New(132,62),  UIAroundPivot.Top, UIAnchor.Top)
    GuidCacheUtil.BindName(btnScr, "btnScr")
    SetAnchorAndPivot(btnScr, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(btnScr, Vector2.New(0, 11))

    local activityBg = GUI.ImageCreate(panelBg, "activityBg", "1800400200", 65, 100, false, 923, 492)
    SetAnchorAndPivot(activityBg, UIAnchor.Top, UIAroundPivot.Top)

    local activityScr = GUI.LoopScrollRectCreate(activityBg,"activityScr", 0, 30, 920, 460,
            "ActivityCalendarUI", "CreatActivityListPool", "ActivityCalendarUI", "OnRefreshLoopScroll",
            10, false, Vector2.New(915, 46),  1,  UIAroundPivot.Top, UIAnchor.Top)
    GuidCacheUtil.BindName(activityScr, "activityScr")
    SetAnchorAndPivot(activityScr, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(activityScr, Vector2.New(0, 0))

    for i = 1, #activityInfo do
        local spName = nil
        if activityInfo[i][1] == 1 then
            spName = "1800800120"
        elseif activityInfo[i][1] == -1 then
            spName = "1800800140"
        else
            spName = "1800800130"
        end
        local sp = GUI.ImageCreate(activityBg, activityInfo[i][3], spName, activityInfo[i][5], -9, false, activityInfo[i][4], 36)
        SetAnchorAndPivot(sp, UIAnchor.Top, UIAroundPivot.Top)
        local txt = GUI.CreateStatic(sp, "txt", activityInfo[i][2], 0, 0, 100, 30, "system")
        GUI.StaticSetFontSize(txt, fontSize)
        GUI.SetColor(txt, ColorType_FontColor2)
        SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    end
    local childSize = Vector2.New(120, 32)
    toggleGuid2Type = {}
    for i = 1, #toggleList do

        local tmpGroup = GUI.CheckBoxExCreate(panelBg, "tmpGroup"..i, "1800001060", "1800001060",145 + (i - 1) * 145,55,false, childSize.x, childSize.y,false)
        SetAnchorAndPivot(tmpGroup, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local toggle = GUI.CheckBoxCreate(tmpGroup, toggleList[i][2], "1800208040", "1800208041", 0, 0, Transition.None, false)
        GuidCacheUtil.BindName(toggle, toggleList[i][2])
        SetAnchorAndPivot(toggle, UIAnchor.Left, UIAroundPivot.Left)
        local txt = GUI.CreateStatic(toggle, "txt", toggleList[i][3], 25, 0, 100, 30, "system")
        GUI.StaticSetFontSize(txt, fontSize_BigOne)
        GUI.SetColor(txt, ColorType_FontColor2)
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)

        toggleGuid2Type[GUI.GetGuid(toggle)] = toggleList[i][1]
        GUI.SetData(tmpGroup,"index",i)
        --toggleGuid2Type[GUI.GetGuid(tmpGroup)] = toggleList[i][1]
        GUI.RegisterUIEvent(toggle, UCE.PointerClick, "ActivityCalendarUI", toggleList[i][4])
        GUI.RegisterUIEvent(tmpGroup, UCE.PointerClick, "ActivityCalendarUI", "OnActivityTypeTmpGroupClick")
    end

    local center = GUI.ImageCreate(panelBg, "center", "1800600182", 0, 0, false, w, h - 54)
    SetAnchorAndPivot(center, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.SetDepth(center, 0)
    GUI.RegisterUIEvent(center, ULE.CreateFinsh, "ActivityCalendarUI", "OnCreate")

    ActivityCalendarUI.RegisterMessage()
end

function ActivityCalendarUI.OnActivityTypeTmpGroupClick(guid)
    local tmpGroup=GUI.GetByGuid(guid)
    local index=tonumber(GUI.GetData(tmpGroup,"index"))
    local toggleName=toggleList[index][2]
    local toggle=GUI.GetChild(tmpGroup,toggleName)
    local toggleGuid=GUI.GetGuid(toggle)
    ActivityCalendarUI.OnActivityTypeToggleClick(toggleGuid)
end


-- 注册GM消息
function ActivityCalendarUI.RegisterMessage()
    for k, v in ipairs(messageEventList) do
        CL.UnRegisterMessage(v[1], "ActivityCalendarUI", v[2])
        CL.RegisterMessage(v[1], "ActivityCalendarUI", v[2])
    end
end

function ActivityCalendarUI.OnCreate()
    --ActivityCalendarUI.InitData()
    --Timer.New(ActivityCalendarUI.OnCreateItemInfo, 0.3):Start()
    ActivityCalendarUI.OnCreateItemInfo()
end

function ActivityCalendarUI.OnCreateItemInfo()
    local btnScr = GuidCacheUtil.GetUI("btnScr")
    ActivityCalendarUI.CreateLeftBtnList(btnScr)
    --ActivityCalendarUI.CreateAllActivityList()
end

function ActivityCalendarUI.CreateSmallMenuBgFree(panel, title, w, h)
    local panelCover = GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)
    local group = GUI.GroupCreate(panel, "panelBg", -8, 6, w, h)
    local panelBg = GUI.ImageCreate(group, "center", "1800600182", 0, 0, false, w, h - 54)
    SetAnchorAndPivot(panelBg, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local topBar_X = math.ceil(w / 4)
    local topBar_Width = math.ceil(w / 2)

    local topBarLeft = GUI.ImageCreate(group, "topBarLeft", "1800600180", topBar_X, 28, false, topBar_Width, 54)
    SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

    local topBarRight = GUI.ImageCreate(group, "topBarRight", "1800600181", -topBar_X, 28, false, topBar_Width, 54)
    SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

    local topBarCenter = GUI.ImageCreate(group, "topBarCenter", "1800600190", -6, 27, false, 267, 50)
    SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

    local closeBtn = GUI.ButtonCreate(group, "closeBtn", "1800302120", 0, 4, Transition.ColorTint)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    local tipLabel = GUI.CreateStatic(group, "tipLabel", title, -6, 27, 30, 20)
    GUI.StaticSetFontSize(tipLabel, 26)
    GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(tipLabel, colorDark)
    SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)
    return group
end

function ActivityCalendarUI.OnShow()
    ActivityCalendarUI.InitData()
    GUI.SetVisible(GUI.GetWnd("ActivityCalendarUI"), true)
    ActivityCalendarUI.CreateAllActivityList()
end

local ActivityData = {}
function ActivityCalendarUI.InitRewardData()
    ActivityData = {}
    local dataList = LD.GetActivityList()
    if not dataList then
        return
    end
    local count = dataList.Count
    for i = 1, count do
        local data = dataList[i - 1]
        -- 1:2:1:10:61024,61025,21112:1:2,3,5
        -- 分别对应的是 当前参加次数， 次数上限，当前获得活跃值，活跃值上限，奖励List，活动状态，属于什么奖励类型的活动
        local custom = string.split(data.custom, ":")
        local t = {
            state = data.state,
            today = data.today,
            status = 2, --测试中，都认为可以参加 --ActivityPanelUI.GetActivityStatus(custom[6] and tonumber(custom[6]) or 0),
            count = custom[1] and tonumber(custom[1]) or 0,
            max_count = custom[2] and tonumber(custom[2]) or 1,
            point = custom[3] and tonumber(custom[3]) or 1,
            max_point = custom[4] and tonumber(custom[4]) or 1,
            rewards = custom[5] and string.split(custom[5], ",") or {},
        }
        ActivityData[data.id] = t
    end
end

function ActivityCalendarUI.InitData()
    ActivityCalendarUI.InitRewardData()
    local curTickCount = CL.GetServerTickCount()
    local dateStr = string.split(os.date("!%d %w %H %M %S", curTickCount), " ")
    --print(os.date("!%d %w %H %M %S", CL.GetServerTickCount()), "---------------------------------")
    local day = dateStr[1]
    local week = dateStr[2]
    if week == "0" then -- 周日是0 特殊处理一下
        week = "7"
    end
    --local hour = dateStr[3]
    --local minute = dateStr[4]
    --local second = dateStr[5]
    local weekStart = tonumber(day) - tonumber(week)
    local weekEnd = weekStart + 7
    --local curTime = tonumber(hour) * 3600 + tonumber(minute) * 60 + tonumber(second)
    local curLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    local configs = DB.GetActivityAllKeys()
    local count = configs.Count
    -- 初始化所有的活动数据
    AllActivityConfig = {}
    for i = 1, #leftBtnList do
        local dayActivity = {}
        for j = 1, #toggleList do
            dayActivity[toggleList[j][1]] = {}
        end
        AllActivityConfig[i] = dayActivity
    end
    for i = 1, count do
        local id = configs[i - 1]
        local config = DB.GetActivity(id)
        if config.Show == 1 then
            if config.TimeType == 1 then -- 每日循环
                local str, startTime = ActivityCalendarUI.GetActivityTime(config.TimeStart, config.TimeEnd)
                ActivityCalendarUI.AddActivity({1, 2, 3, 4, 5, 6, 7}, id, config, str, startTime, curLevel)
            elseif config.TimeType == 2 then -- 每周循环
                local str, startTime = ActivityCalendarUI.GetActivityTime(config.TimeStart, config.TimeEnd)
                local strs = string.split(config.Time, ",")
                for i = 1, #strs do
                    local w = tonumber(strs[i])
                    ActivityCalendarUI.AddActivity({w}, id, config, str, startTime, curLevel)
                end
            elseif config.TimeType == 3 then -- 每月循环
                local str, startTime
                local strs = string.split(config.Time, ",")
                for i = 1, #strs do
                    local needDay = tonumber(strs[i])
                    if needDay >= weekStart and needDay <= weekEnd  then
                        if not startTime then
                            str, startTime = ActivityCalendarUI.GetActivityTime(config.TimeStart, config.TimeEnd)
                        end
                        ActivityCalendarUI.AddActivity({needDay - weekStart}, id, config, str, startTime, curLevel)
                    end
                end
            end
        end
    end
    for i = 1, #leftBtnList do
        local dayActivity = AllActivityConfig[i]
        for j = 1, #toggleList do
            table.sort(dayActivity[toggleList[j][1]], function(a, b)
                return a.StartTime < b.StartTime
            end)
        end
    end
    CurSelectDay = tonumber(week)
end

function ActivityCalendarUI.GetActivityTime(TimeStart, TimeEnd)
    local str = ""
    local startTime = 0
    if TimeStart == "00:00:00" and TimeEnd == "23:59:59" then
        str = "全天开启"
        startTime = -1
    else
        str = string.sub(TimeStart, 1, -4) .. "-" .. string.sub(TimeEnd, 1, -4)
        local strs = string.split(TimeStart, ":")
        if #strs == 3 then
            startTime = tonumber(strs[1]) * 3600 + tonumber(strs[2]) * 60 + tonumber(strs[3])
        end
    end
    return str, startTime
end

function ActivityCalendarUI.AddActivity(idxTable, id, DBConfig, timestr, startTime, curLevel)
    local aType = DBConfig.Type
    local data = {
        ID = id,
        StartTime = startTime,
        Time = timestr,
        Name = DBConfig.Name,
        Type = Type2String[DBConfig.Type],
        Level = DBConfig.LevelMin <= 0 and "无限制" or DBConfig.LevelMin .. "级以上",
        ReceiveInfo = DBConfig.ReceiveInfo,
        Star = tonumber(DBConfig.Star),
    }
    for i = 1, #idxTable do
        local idx = idxTable[i]
        local dayActivity = AllActivityConfig[idx]
        table.insert(dayActivity[ActivityType.ALL], data) -- 添加到所有中
        if aType == 0 then
            table.insert(dayActivity[ActivityType.DAILY], data) -- 日常活动
        elseif aType == 1 then
            table.insert(dayActivity[ActivityType.LIMIT], data) -- 限时活动
        elseif aType == 2 then
            table.insert(dayActivity[ActivityType.FESTIVAL], data) -- 节日活动
        end
        if curLevel >= DBConfig.LevelMin then
            table.insert(dayActivity[ActivityType.LEVEL], data) -- 对应等级活动
        else
            table.insert(dayActivity[ActivityType.NO_OPEN], data) -- 即将开启活动
        end
    end
end

function ActivityCalendarUI.InFight(infight)
    GUI.CloseWnd("ActivityCalendarUI")
end

function ActivityCalendarUI.CreateLeftBtnList(parent)
    leftBtnGuid2Day = {}
    for i = 1, #leftBtnList do
        local btn = GUI.ButtonCreate(parent, leftBtnList[i][1], "1800002030", 0, 0, Transition.None, "", 132, 62, false)
        SetAnchorAndPivot(btn, UIAnchor.Top, UIAroundPivot.Top)
        local btnTxt = GUI.CreateStatic(btn, "btnTxt", leftBtnList[i][2], 0, 0, 100, 50)
        SetAnchorAndPivot(btnTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(btnTxt, fontSize_BigTwo)
        GUI.SetColor(btnTxt, ColorType_FontColor3)
        GUI.StaticSetAlignment(btnTxt, TextAnchor.MiddleCenter)

        leftBtnGuid2Day[GUI.GetGuid(btn)] = leftBtnList[i][1]
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "ActivityCalendarUI", leftBtnList[i][3])
    end
    --关闭活动面板
    -- GUI.CloseWnd("ActivityPanelUI")
    local panelBg = GuidCacheUtil.GetUI("panelBg")
    GUI.SetVisible(panelBg, true)
    local panelCover = GuidCacheUtil.GetUI("panelCover")
    GUI.SetVisible(panelCover, true)
end

function ActivityCalendarUI.CreateAllActivityList()
    local btnScr = GuidCacheUtil.GetUI("btnScr")
    local weekBtn = GUI.GetChild(btnScr, CurSelectDay)
    ActivityCalendarUI.OnDayBtnClick(GUI.GetGuid(weekBtn))
end

function ActivityCalendarUI.GetActivitySpriteName(index)
    local tmp = math.modf(index / 2)
    if tmp * 2 == index then
        return "1800600240"
    else
        return "1800600230"
    end
end

function ActivityCalendarUI.AddBtnOutline(uielement, color)
    GUI.SetIsOutLine(uielement, true)
    if color == nil then
        color = ColorType_Black
    end
    GUI.SetOutLine_Color(uielement, color)
    GUI.SetOutLine_Distance(uielement, 1)
end

function ActivityCalendarUI.OnDayBtnClick(guid)
    if guid == lastSelectActivityBtnGuid then
        return
    end
    if lastSelectActivityBtnGuid then
        local lastBtn = GUI.GetByGuid(lastSelectActivityBtnGuid)
        local btnTxt = GUI.GetChild(lastBtn, "btnTxt")
        GUI.SetColor(btnTxt, ColorType_FontColor3)
        GUI.SetIsOutLine(btnTxt, false)
        GUI.ButtonSetImageID(lastBtn, "1800002030")
    end
    local btn = GUI.GetByGuid(guid)
    GUI.ButtonSetImageID(btn, "1800002031")
    local btnTxt = GUI.GetChild(btn, "btnTxt")
    GUI.SetColor(btnTxt, ColorType_White)
    ActivityCalendarUI.AddBtnOutline(btnTxt, btnColorOutline)
    lastSelectActivityBtnGuid = guid
    CurSelectDay = leftBtnGuid2Day[guid]

    ActivityCalendarUI.OnActivityTypeToggleClick(GuidCacheUtil.GetGuid(toggleList[1][2]))
end

local starCount = 5
function ActivityCalendarUI.CreatActivityListPool()
    local activityScr = GuidCacheUtil.GetUI("activityScr")
    local childCount = GUI.LoopScrollRectGetChildInPoolCount(activityScr)
    --老方法用的是GUI.ItemCtrlCreate()
    local btn = GUI.ImageCreate(activityScr, "btn_" .. childCount, "1800600240", 0, 0, false,920, 46, false)
    SetAnchorAndPivot(btn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetIsRaycastTarget(btn, true)
    btn:RegisterEvent(UCE.PointerClick)
    for i = 1, #activityInfo do
        if activityInfo[i][3] ~= "star" then
            local txt = GUI.CreateStatic(btn, activityInfo[i][3], "", activityInfo[i][5], 0, activityInfo[i][4], 30, "system", false, false)
            SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetColor(txt, ColorType_FontColor2)
            GUI.StaticSetFontSize(txt, fontSize)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
            GUI.StaticSetFontSizeBestFit(txt)
        else
            local star = GUI.GroupCreate(btn, activityInfo[i][3], activityInfo[i][5], 0, activityInfo[i][4], 46)
            for i = 0, starCount - 1 do
                local st = GUI.ImageCreate(star, i, "1800607220", (i - 2) * 35, 0)
                SetAnchorAndPivot(st, UIAnchor.Center, UIAroundPivot.Center)
            end
        end
    end
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "ActivityCalendarUI", "OnActivityClick_Scr")
    return btn
end

function ActivityCalendarUI.OnRefreshLoopScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemList = GUI.GetByGuid(guid)

    local spName = ActivityCalendarUI.GetActivitySpriteName(index)
    --GUI.ItemCtrlSetElementValue(itemList, eItemIconElement.Selected, spName)
    GUI.ImageSetImageID(itemList,spName)
    local timeTxt = GUI.GetChild(itemList, "time")
    local nameTxt = GUI.GetChild(itemList, "name")
    local typeTxt = GUI.GetChild(itemList, "type")
    local levelTxt = GUI.GetChild(itemList, "level")
    local numTxt = GUI.GetChild(itemList, "num")
    local star = GUI.GetChild(itemList, "star")

    local activity = AllActivityConfig[CurSelectDay][CurSelectType][index]

    GUI.StaticSetText(timeTxt, activity.Time)
    GUI.StaticSetText(nameTxt, activity.Name)
    GUI.StaticSetText(typeTxt, activity.Type)
    GUI.StaticSetText(levelTxt, activity.Level)
    GUI.StaticSetText(numTxt, activity.ReceiveInfo)

    for i = 0, activity.Star - 1 do
        local st = GUI.GetChild(star, i)
        GUI.ImageSetImageID(st, "1800607221")
    end

    for i = activity.Star, starCount do
        local st = GUI.GetChild(star, i)
        GUI.ImageSetImageID(st, "1800607220")
    end

    GUI.SetData(itemList, "Index", index)
    GUI.SetData(itemList, "ActivityId", activity.ID)
end

function ActivityCalendarUI.OnActivityClick_Scr(guid)
    local activityTips = GuidCacheUtil.GetUI("activityTips")
    if activityTips ~= nil then
        return
    end

    local panelBg = GuidCacheUtil.GetUI("panelBg")
    local lastActivityClick_Scr_Guid = GUI.GetData(panelBg, "lastActivityClick_Scr_Guid")
    if lastActivityClick_Scr_Guid ~= nil and string.len(lastActivityClick_Scr_Guid) > 0 then
        local lastClick = GUI.GetByGuid(lastActivityClick_Scr_Guid)
        if GUI.GetVisible(lastClick) then
            local lastIndex = GUI.GetData(lastClick, "Index")
            if lastIndex ~= nil and string.len(lastIndex) > 0 then
                local spName = ActivityCalendarUI.GetActivitySpriteName(tonumber(lastIndex))
                --GUI.ItemCtrlSetElementValue(lastClick, eItemIconElement.Selected, spName)
                GUI.ImageSetImageID(lastClick,spName)
            end
        end
    end

    local btn = GUI.GetByGuid(guid)
    --GUI.ItemCtrlSetElementValue(btn, eItemIconElement.Selected,"1800600250")
    GUI.ImageSetImageID(btn,"1800600250")

    local activityId = GUI.GetData(btn, "ActivityId")
    GUI.SetData(panelBg, "lastActivityClick_Scr_Guid", tostring(guid))
    ActivityCalendarUI.CreateActivityTips(activityId)
end

local activityTips_AwardIconCount = 5
function ActivityCalendarUI.CreateActivityTips(activityId)
    local activityTips = GuidCacheUtil.GetUI("activityTips")
    local itemIcon = nil
    if not activityTips then
        local panelBg = GuidCacheUtil.GetUI("panelBg")
        activityTips = GUI.ImageCreate(panelBg, "activityTips", "1800400290", 0, 0, false, 450, 360)
        GuidCacheUtil.BindName(activityTips, "activityTips")
        SetAnchorAndPivot(activityTips, UIAnchor.Center, UIAroundPivot.Center)

        local cover = GUI.ButtonCreate(activityTips, "cover", "1800400290", 60, 50, Transition.None, "", 920, 460, false)
        SetAnchorAndPivot(cover, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(cover, Color.New(1, 1, 1, 0))

        local itemIcon = GUI.ItemCtrlCreate(activityTips, "itemIcon", "1800400050", 15, 15)
        SetAnchorAndPivot(itemIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1900000000")

        local name = ActivityCalendarUI.CreateStatic("name", activityTips, 105, 20, fontSize, ColorType_YellowName_ActivityTips, 300, 50)
        SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local time = ActivityCalendarUI.CreateStatic("time", activityTips, 15, 95, fontSize, ColorType_Yellow_ActivityTips, 115, 35)
        SetAnchorAndPivot(time, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(time, "活动时间：")
        local txt = GUI.CreateStatic(time, "txt", "", GUI.StaticGetLabelPreferWidth(time), 0, 310, 26, "system", true, false)
        GUI.SetColor(txt, ColorType_Blue_ActivityTips)
        GUI.StaticSetFontSize(txt, fontSize)
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)

        local limitNum = ActivityCalendarUI.CreateStatic("limitNum", activityTips, 15, 125, fontSize, ColorType_Yellow_ActivityTips, 115, 35)
        SetAnchorAndPivot(limitNum, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(limitNum, "人数限制：")
        local txt = ActivityCalendarUI.CreateStatic("txt", limitNum, GUI.StaticGetLabelPreferWidth(limitNum), 0, fontSize, ColorType_YellowName_ActivityTips, 310, 26)
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)

        local limitLevel = ActivityCalendarUI.CreateStatic("limitLevel", activityTips, 15, 155, fontSize, ColorType_Yellow_ActivityTips, 115, 35)
        SetAnchorAndPivot(limitLevel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(limitLevel, "等级限制：")
        local txt = ActivityCalendarUI.CreateStatic("txt", limitLevel, GUI.StaticGetLabelPreferWidth(limitLevel), 0, fontSize, ColorType_Red, 310, 26)
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)

        local receive = ActivityCalendarUI.CreateStatic("receive", activityTips, 15, 185, fontSize, ColorType_Yellow_ActivityTips, 115, 35)
        SetAnchorAndPivot(receive, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(receive, "任务领取：")
        local txt = GUI.CreateStatic(receive, "txt", "", GUI.StaticGetLabelPreferWidth(receive), 0, 310, 26, "system", true, false)
        GUI.SetColor(txt, ColorType_Blue_ActivityTips)
        GUI.StaticSetFontSize(txt, fontSize)
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)

        local des = ActivityCalendarUI.CreateStatic("des", activityTips, 15, 215, fontSize, ColorType_Yellow_ActivityTips, 115, 35)
        SetAnchorAndPivot(des, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(des, "活动描述：")
        local txt = GUI.CreateStatic(des, "txt", "", GUI.StaticGetLabelPreferWidth(des), 5, 310, 26, "system", true, false)
        GUI.SetColor(txt, ColorType_YellowName_ActivityTips)
        GUI.StaticSetFontSize(txt, fontSize)
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local award = ActivityCalendarUI.CreateStatic("award", activityTips, 15, 215, fontSize, ColorType_Yellow_ActivityTips,115,35)
        SetAnchorAndPivot(award, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(award, "活动奖励：")
        for i = 0, activityTips_AwardIconCount - 1 do
            local itemIcon = GUI.ItemCtrlCreate(award, "award_" .. i, "1800400050", 85 * i, 90)
            SetAnchorAndPivot(itemIcon, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1900000000")
            GUI.AddWhiteName(activityTips, GUI.GetGuid(itemIcon))
            GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "ActivityCalendarUI", "OnTipsAwardBtnClick")
        end

        GUI.SetIsRemoveWhenClick(activityTips, true)
        local activityScr = GuidCacheUtil.GetUI("activityScr")
        local scrChildCount = GUI.LoopScrollRectGetChildInPoolCount(activityScr)
        for i = 0, scrChildCount - 1 do
            local child = GUI.LoopScrollRectGetChildInPool(activityScr, "btn_" .. i)
            GUI.AddWhiteName(activityTips, GUI.GetGuid(child))
        end
        ActivityCalendarUI.OnRefreshActivityTipsInfo(activityId)
    else
        GUI.SetVisible(activityTips, true)
        itemIcon = GUI.GetChild(activityTips, "itemIcon")
    end
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1900000000")

    GUI.SetIsRemoveWhenClick(activityTips, true)
    ActivityCalendarUI.OnRefreshActivityTipsInfo(activityId)

    local activityScr = GuidCacheUtil.GetUI("activityScr")
    local scrChildCount = GUI.GetChildCount(activityScr)
    for i = 0, scrChildCount - 1 do
        local child = GUI.GetChildByIndex(activityScr, i)
        GUI.AddWhiteName(activityTips, GUI.GetGuid(child))
    end
end

function ActivityCalendarUI.OnTipsAwardBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local itemId = GUI.GetData(btn, "ItemId")
    if itemId == nil or string.len(itemId) == 0 then
        return
    end
    local activityTips = GuidCacheUtil.GetUI("activityTips")
    local tmpPosX = GUI.GetPositionX(activityTips) < 0 and 300 or -120
    local panelBg = GuidCacheUtil.GetUI("panelBg")
    -- 显示物品Tips
    local itemTips = Tips.CreateByItemId(itemId, panelBg, "itemTips", tmpPosX, 0)
end

function ActivityCalendarUI.OnRefreshActivityTipsInfo(activityId)
    local activityTips = GuidCacheUtil.GetUI("activityTips")
    activityId = tonumber(activityId)
    local activityConfig = DB.GetActivity(activityId)
    if activityConfig == nil then
        GUI.SetVisible(activityTips, false)
        test("activityConfig == nil,id = " .. activityId)
        return
    end

    local info = ActivityData[activityId]
    if not info then
        print("找不到activityInfo", CurSelectType, activityId)
        return
    end

    local itemIcon = GUI.GetChild(activityTips, "itemIcon")
    local name = GUI.GetChild(activityTips, "name")
    local count = GUI.GetChild(activityTips, "count")
    local time = GUI.GetChild(activityTips, "time")
    local timeTxt = GUI.GetChildByPath(activityTips, "time/txt")
    local limitNum = GUI.GetChild(activityTips, "limitNum")
    local limitLevel = GUI.GetChild(activityTips, "limitLevel")
    local receive = GUI.GetChild(activityTips, "receive")
    local limitNumTxt = GUI.GetChildByPath(activityTips, "limitNum/txt")
    local limitLevelTxt = GUI.GetChildByPath(activityTips, "limitLevel/txt")
    local receivetXT = GUI.GetChildByPath(activityTips, "receive/txt")
    local des = GUI.GetChild(activityTips, "des")
    local desTxt = GUI.GetChildByPath(activityTips, "des/txt")
    local award = GUI.GetChild(activityTips, "award")

    local iconId = activityConfig.Icon ~= uint64.zero and tostring(activityConfig.Icon) or defaultIcon
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, iconId)
    GUI.StaticSetText(name, activityConfig.Name)

    local roleLevel=CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    local activityLevelMin=activityConfig.LevelMin
    GUI.SetColor(limitLevelTxt,roleLevel>=activityLevelMin and ColorType_Blue_ActivityTips or ColorType_Red)

    local awardNumMax = tonumber(info.max_count)
    if awardNumMax == 0 then
        GUI.StaticSetText(count, "无限")
    else
        GUI.StaticSetText(count, info.count .. "/" .. info.max_count)
    end
    GUI.StaticSetText(timeTxt, activityConfig.TimeInfo)
    GUI.StaticSetText(limitNumTxt, activityConfig.ReceiveInfo)
    GUI.StaticSetText(limitLevelTxt, activityConfig.LevelInfo)
    GUI.StaticSetText(receivetXT, activityConfig.WayInfo)

    GUI.StaticSetText(desTxt, activityConfig.DesInfo)
    local desPreferHeight = GUI.StaticGetLabelPreferHeight(desTxt)
    GUI.SetHeight(desTxt, desPreferHeight)
    GUI.SetPositionY(award, 215 + desPreferHeight + 4)

    GUI.SetHeight(activityTips, 360 + desPreferHeight + 4)
    local timePreferHeight = GUI.StaticGetLabelPreferHeight(timeTxt)
    if timePreferHeight > 30 then
        local tmp = timePreferHeight - 30
        GUI.SetHeight(timeTxt, timePreferHeight)
        GUI.SetHeight(activityTips, 360 + desPreferHeight + 4 + tmp)
        GUI.SetPositionY(timeTxt,13)
        GUI.SetPositionY(limitNum, -(GUI.GetPositionY(time))+30 + tmp)
        GUI.SetPositionY(limitLevel, -(GUI.GetPositionY(limitNum))+30 )
        GUI.SetPositionY(receive, -(GUI.GetPositionY(limitLevel))+30 )
        GUI.SetPositionY(des, -(GUI.GetPositionY(receive))+30 )
        GUI.SetPositionY(award, -(GUI.GetPositionY(award)) + tmp)
    else
        GUI.SetPositionY(timeTxt,0)
        GUI.SetPositionY(limitNum, -(GUI.GetPositionY(time))+30 )
        GUI.SetPositionY(limitLevel, -(GUI.GetPositionY(limitNum))+30 )
        GUI.SetPositionY(receive, -(GUI.GetPositionY(limitLevel))+30 )
        GUI.SetPositionY(des, -(GUI.GetPositionY(receive))+30 )
        GUI.SetPositionY(award, -(GUI.GetPositionY(award)) )

    end

    local rewards = info.rewards
    -- 显示奖励
    local tmpCount = 0
    for i = 1, #rewards do
        local itemID = tonumber(rewards[i])
        if itemID ~= 0 then
            if tmpCount < activityTips_AwardIconCount then
                local awardItem = DB.GetOnceItemByKey1(itemID)
                if awardItem == nil then
                    test("awardItem == nil")
                    return
                end
                local child = GUI.GetChild(award, "award_" .. tmpCount)
                GUI.ItemCtrlSetElementValue(child, eItemIconElement.Icon, tostring(awardItem.Icon))
                GUI.SetData(child, "ItemId", itemID)
                GUI.ItemCtrlSetElementValue(child, eItemIconElement.Border, QualityRes[awardItem.Grade])
                GUI.SetVisible(child, true)
                tmpCount = tmpCount + 1
            end
        end
    end

    for i = tmpCount, activityTips_AwardIconCount - 1 do
        local child = GUI.GetChild(award, "award_" .. i)
        GUI.SetVisible(child, false)
    end
end

function ActivityCalendarUI.OnActivityTypeToggleClick(guid)
    local panelBg = GuidCacheUtil.GetUI("panelBg")
    local lastToggleGuid = GUI.GetData(panelBg, "lastSelectActivityToggleGuid")
    if lastToggleGuid ~= nil and string.len(lastToggleGuid) > 0 then
        local lastToggle = GUI.GetByGuid(lastToggleGuid)
        GUI.CheckBoxSetCheck(lastToggle, false)
    end

    local toggle = GUI.GetByGuid(guid)
    GUI.CheckBoxSetCheck(toggle, true)
    local activityScr = GuidCacheUtil.GetUI("activityScr")
    CurSelectType = toggleGuid2Type[guid]

    GUI.SetData(panelBg, "lastSelectActivityToggleGuid", tostring(guid))
    local count = #AllActivityConfig[CurSelectDay][CurSelectType]

    GUI.LoopScrollRectSetTotalCount(activityScr, count)
    GUI.LoopScrollRectRefreshCells(activityScr)
end

function ActivityCalendarUI.OnCloseBtnClick(guid)
    GUI.CloseWnd("ActivityCalendarUI")
    -- GUI.OpenWnd("ActivityPanelUI")
end

function ActivityCalendarUI.CreateStatic(key, parent, x, y, fontsize, color, w, h)
    color = color or ColorType_FontColor2
    x = x or 0
    y = y or 0
    fontsize = fontsize or fontSize
    w = w or 0
    h = h or 0
    local txt = GUI.CreateStatic(parent, key, "", x, y, w, h, "system", false)
    GUI.StaticSetFontSize(txt, fontsize)
    GUI.SetColor(txt, color)
    SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    return txt
end