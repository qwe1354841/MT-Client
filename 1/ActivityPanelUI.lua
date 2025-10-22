local ActivityPanelUI = {}
_G.ActivityPanelUI = ActivityPanelUI

-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local _gt = UILayout.NewGUIDUtilTable()
------------------------------------ end缓存一下全局变量end --------------------------------

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

local ColorType_FontColor3 = UIDefine.Brown4Color --Color.New(109 / 255, 60 / 255, 24 / 255)
local ColorType_FontColor2 = UIDefine.BrownColor --Color.New(102 / 255, 47 / 255, 22 / 255)
local ColorType_White = UIDefine.WhiteColor -- Color.New(255 / 255, 255 / 255, 255 / 255)
local sliderColorOutLine = UIDefine.OutLine_YellowColor -- Color.New(220 / 255, 104 / 255, 0 / 255)    --进度条描边
local ColorType_BlueLive = Color.New(89 / 255, 189 / 255, 253 / 255)            --活跃度文字
local ColorType_Yellow_ActivityTips = UIDefine.YellowColor -- Color.New(221 / 255, 210 / 255, 33 / 255)        --活动tips黄色文字
local ColorType_Blue_ActivityTips = UIDefine.Blue4Color -- Color.New(66 / 255, 210 / 177, 240 / 255)        --活动tips蓝色文字
local ColorType_YellowName_ActivityTips = UIDefine.Yellow4Color --Color.New(251 / 255, 222 / 177, 183 / 255)        --活动tips黄色名字文字
local colorRich_Live = "59bdfd"
local colorRich_Red2 = "fe4f20"

local fontSize = UIDefine.FontSizeM
local fontSize_LittleOne = UIDefine.FontSizeS
local fontSize_LittleTwo = UIDefine.FontSizeSS
local fontSize_BigOne = UIDefine.FontSizeL
local fontSize_BigTwo = UIDefine.FontSizeXL
local QualityRes = UIDefine.ItemIconBg

local OpeningSoonType = 100
local activityTypeBtnList = {
    { 0, "日常活动", "OnActivityBtnClick",true },
    { 1, "限时活动", "OnActivityBtnClick",true },
    { 2, "节日活动", "OnActivityBtnClick",false },
    { OpeningSoonType, "即将开启", "OnActivityBtnClick",true }
}

--1:表示是否是全部类型的 ，2：名字，3：是否是道具或者装备类型的，4：C#字段名,5:是否是装备类型
local activityAwardType = {
    [1] = { 0, "全部", false, "", "", false, "" },
    [2] = { 1, "元宝", false, "Gold", false, "金元宝" },
    [3] = { 1, "银币", false, "BindGold", false, "银币" },
    [4] = { 1, "经验", false, "Exp", false, "经验" },
    [5] = { 1, "装备", true, "Extra3", true, "" },
    [6] = { 1, "道具", true, "Extra2", false, "" },
}

--活动状态 0：未开始 1：已完成 2：待参与 3:正在参与 4:未开启 5：奖励已领取
local sortPriority =
{
    [0] = 4,
    [1] = 5,
    [2] = 2,
    [3] = 1,
    [4] = 3,
    [5] = 1,
}

-- 这些任务会有高光提示
local hotActivityList = {
    ["会试"]={1},["殿试"]={1},["武道会"]={1},["门派入侵"]={1},["天降宝箱"]={1},["十二星官"]={1},["长安保卫战"]={1},["帮派强盗（午）"]={1},["帮派摇钱树"]={1},
    ["公主的嫁妆"]={1},["天地大劫（早）"]={1},["天地大劫（晚）"]={1},["守卫粮仓（晚）"]={1},["帮派除魔"]={1},["宝阁大开"]={1},["魔神降临"]={1},["结婚巡礼（早）"]={1},
    ["结婚巡礼（晚）"]={1},["守卫粮仓（午）"]={1},["帮派强盗（晚）"]={1}
}

-- 这些任务会有必做角标
local mustToDoActivityList = {
    ["师门任务"]={1},["降妖任务"]={1},["帮派任务"]={1},["乡试"]={1},["会试"]={1},["殿试"]={1},["武道会"]={1},["长安保卫战"]={1},["帮派强盗（午）"]={1},
    ["门派入侵"]={1},["天梯挑战"]={1},["大雁塔"]={1},["沙城遗址"]={1},["水帘洞"]={1},["傲来秘宝"]={1},["梦回千古"]={1},["洞窟伏魔"]={1},["人鬼绝恋"]={1},
    ["守卫粮仓（晚）"]={1},["帮派除魔"]={1},["宝阁大开"]={1},["帮派竞技"]={1},["帮派竞技（报名）"]={1},["帮派竞技（战斗）"]={1},["魔神降临"]={1},["逃跑的丹灵（早）"]={1},
    ["逃跑的丹灵（晚）"]={1},["捣乱的器灵"]={1},["清理炉渣"]={1},["五一兑换"]={1},["天下会武（晚）"]={1},["伏魔任务"]={1},["大雁塔(困难)"]={1},["沙城遗址(困难)"]={1},
    ["水帘洞(困难)"]={1},["傲来秘宝(困难)"]={1},["梦回千古(困难)"]={1},["洞窟伏魔(困难)"]={1},["人鬼绝恋(困难)"]={1},["天下第一（晚）"]={1},["官职称号发放"]={1},
    ["天道赏金榜"]={1},["魔道赏金榜"]={1},["忏悔"]={1},["天下会武（午）"]={1},["天下第一（午）"]={1},["守卫粮仓（午）"]={1},["帮派强盗（晚）"]={1},
}

local LastBtnGuid = nil
local LastToggleGuid = nil
local ActivityIndex1 = nil
local ActivityIndex2 = nil
local ActivityIndex3 = nil
local RoleAttrActivation = {}
local RoleServerData = {}
local ActivityAllTable = {}
local ActivityTypeTable = {}
local LastInitDataTime = 0
local LastSelectActivityGuid = nil
local LastSelectActivityId = nil
local LastSelectIndex = nil
local LastActivityIndex2 = nil

function ActivityPanelUI.Main(parameter)
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = MainUI.MainUISwitchConfig["活动"].OpenLevel

    if CurLevel < Level then
        CL.SendNotify(NOTIFY.ShowBBMsg,"您需要达到"..tostring(Level).."级才能开启活动功能")
        return
    end
    GUI.PostEffect()
    local panel = GUI.WndCreateWnd("ActivityPanelUI", "ActivityPanelUI", 0, 0, eCanvasGroup.Normal)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)

    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "活  动", "ActivityPanelUI", "OnExit",_gt)
    _gt.BindName(panelBg, "panelBg")

    local scrBg = GUI.ImageCreate(panelBg, "scrBg", "1800400010", 97, 55, false, 850, 430)
    SetAnchorAndPivot(scrBg, UIAnchor.Top, UIAroundPivot.Top)

    -- btnScr曾经的父类是panelBg
    local btnScr = GUI.ScrollRectCreate(panelBg, "btnScr", 65, 60, 204, 380, 100, false, Vector2.New(190, 65), UIAroundPivot.Top, UIAnchor.Top)
    btnScr:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(btnScr, true)
    GUI.RegisterUIEvent(btnScr, UCE.PointerClick, "ActivityPanelUI", "OnBtnScrClick")
    _gt.BindName(btnScr, "btnScr")
    SetAnchorAndPivot(btnScr, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(btnScr, Vector2.New(0, 10))

    --左侧按钮
    for i = 1, #activityTypeBtnList do
        --处理是否显示按钮，用于后续操作
        if i <= 3 then
            if GlobalProcessing.ChangeActivityTypeBtnList ~= nil then
                activityTypeBtnList[i][4] = GlobalProcessing.ChangeActivityTypeBtnList[i][1]
            end
        else
            activityTypeBtnList[i][4] = CurLevel < 120
        end
        local btn = GUI.ButtonCreate(btnScr, "activityTypeBtn"..i, "1800002030", 0, 0, Transition.None, "", 190, 65, false)
        SetAnchorAndPivot(btn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        local btnTxt = GUI.CreateStatic(btn, "btnTxt", "", 0, 0, 180, 50)
        GUI.StaticSetAlignment(btnTxt, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(btnTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(btnTxt, fontSize_BigTwo)
        GUI.SetColor(btnTxt, ColorType_FontColor3)
        GUI.SetIsOutLine(btnTxt, false)
        GUI.StaticSetText(btnTxt, activityTypeBtnList[i][2])
        local effect = GUI.RichEditCreate(btn, "effect", "", 37, 15, 300, 200)
        SetAnchorAndPivot(effect, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(effect, 24)
        GUI.SetIsRaycastTarget(effect, false)
        GUI.SetData(btn,"BtnIndex",tostring(i))
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "ActivityPanelUI", activityTypeBtnList[i][3])
        _gt.BindName(btn,"activityTypeBtn"..i)
        GUI.SetVisible(btn, activityTypeBtnList[i][4])
    end

    --中间顶部选择控件
    for i = 1, #activityAwardType do
        local tmpGroup = GUI.CheckBoxExCreate(panelBg, "activityAwardType"..i,"1800001060", "1800001060",310+(i-1)*130,70, false, 90, 32,false)
        SetAnchorAndPivot(tmpGroup, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local toggle = GUI.CheckBoxCreate(tmpGroup, "toggle", "1800208040", "1800208041", 15, 0, Transition.ColorTint, false)
        SetAnchorAndPivot(toggle, UIAnchor.Left, UIAroundPivot.Left)


        local txt = GUI.CreateStatic(toggle, "txt", "", 25, -17, 55, 35)
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, fontSize_BigOne)
        GUI.StaticSetAlignment(txt,TextAnchor.MiddleLeft)
        GUI.SetColor(txt, ColorType_FontColor2)
        GUI.StaticSetText(txt, activityAwardType[i][2])
        GUI.SetData(toggle, "index", tostring(i))
        GUI.SetData(tmpGroup,"index",tostring(i))
        GUI.RegisterUIEvent(toggle, UCE.PointerClick, "ActivityPanelUI", "OnActivityAwardTypeToggleTxtClick")
        GUI.RegisterUIEvent(tmpGroup, UCE.PointerClick, "ActivityPanelUI", "OnActivityAwardTypeToggleTxtClick")
        _gt.BindName(tmpGroup,"activityAwardType"..i)

    end

    local activityScr = GUI.LoopScrollRectCreate(scrBg,
            "activityScr",
            0,
            53,
            845,
            367,
            "ActivityPanelUI",
            "CreateActivityCount",
            "ActivityPanelUI",
            "RefreshActivityCount",
            0,
            false,
            Vector2.New(417, 105),
            2,
            UIAroundPivot.Top,
            UIAnchor.Top,
            false
    )
    _gt.BindName(activityScr,"activityScr")
    -- 设置每个框的距离
    GUI.ScrollRectSetChildSpacing(activityScr, Vector2.New(5, 7))

    --活动日历
    local calendarBtn = GUI.ButtonCreate(panelBg, "calendarBtn", "1800602210", 106, -110, Transition.ColorTint)
    SetAnchorAndPivot(calendarBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    local calenderName = GUI.CreateStatic(calendarBtn, "btnTxt",  "",0, -35, 97, 35,"system",true,false)
    GUI.StaticSetFontSize(calenderName, fontSize_BigOne)
    SetAnchorAndPivot(calenderName, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.StaticSetText(calenderName, "活动日历")
    GUI.SetColor(calenderName, ColorType_FontColor2)
    GUI.RegisterUIEvent(calendarBtn, UCE.PointerClick, "ActivityPanelUI", "OnCalendarBtnClick")

    local tips = GUI.CreateStatic(panelBg, "tips",  "",101, -45,  134, 35,"system",true,false)
    GUI.StaticSetFontSize(tips, fontSize_BigOne)
    SetAnchorAndPivot(tips, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    local str = "每日<color=#" .. colorRich_Live .. ">0点</color>刷新"
    GUI.StaticSetText(tips, str)
    GUI.SetColor(tips, ColorType_FontColor2)

    local sliderBg = GUI.ImageCreate(panelBg, "sliderBg", "1800607190", 101, -63, false, 835, 18)
    _gt.BindName(sliderBg, "sliderBg")
    SetAnchorAndPivot(sliderBg, UIAnchor.Bottom, UIAroundPivot.Bottom)
    local fill = GUI.ImageCreate(sliderBg, "fill", "1800607200", 0, 1, false, 1, 18)
    SetAnchorAndPivot(fill, UIAnchor.Left, UIAroundPivot.Left)
    local handle = GUI.ImageCreate(fill, "handle", "1800607210", 17, 0)
    SetAnchorAndPivot(handle, UIAnchor.Right, UIAroundPivot.Right)
    local value = GUI.CreateStatic(handle, "txt", "", 0, 0, 30, 30, "system", false, false)
    GUI.StaticSetFontSize(value, fontSize)
    GUI.SetColor(value, ColorType_White)
    SetAnchorAndPivot(value, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(value, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(value, true)
    GUI.SetOutLine_Color(value, sliderColorOutLine)
    GUI.SetOutLine_Distance(value, 1)
    GUI.StaticSetFontSizeBestFit(value)

    --获得所有活动表单
    ActivityPanelUI.ProcessingAllTable()
end

function ActivityPanelUI.OnShow(parameter)
    local wnd = GUI.GetWnd("ActivityPanelUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
    ActivityPanelUI.Init()
    ActivityPanelUI.ShowActivity()
    --parameter = "index:1,index2:2"
    if parameter == nil then
        ActivityIndex1, ActivityIndex2, ActivityIndex3 = "1","1","nil"
    else
        if string.find(parameter, "index3") then
            ActivityIndex1, ActivityIndex2, ActivityIndex3 = UIDefine.get_parameter_str_3(parameter)
        else
            ActivityIndex1, ActivityIndex2 = UIDefine.GetParameterStr(parameter)
        end
    end

    if ActivityIndex1 == "0" or ActivityIndex1 == nil then ActivityIndex1 = "1" end
    if ActivityIndex2 == "0" or ActivityIndex1 == nil then ActivityIndex2 = "1" end
    ActivityPanelUI.Register()
    CL.SendNotify(NOTIFY.GetActivityList)
    CL.SendNotify(NOTIFY.SubmitForm, "FormActivity", "ActivitySystem_GetData") -- 请求数据
end

function ActivityPanelUI.ShowActivity()
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local activityTypeBtn = _gt.GetUI("activityTypeBtn4")
    GUI.SetVisible(activityTypeBtn,CurLevel < 120)
end

function ActivityPanelUI.Init()
    LastActivityIndex2 = nil
    LastSelectIndex = nil
    LastSelectActivityGuid = nil
    LastSelectActivityId = nil
    RoleAttrActivation = {}
    RoleServerData = {}
end

--服务器回调刷新
function ActivityPanelUI.Refresh()
    RoleAttrActivation = ActivityPanelUI.RoleAttrActivation
    RoleServerData = ActivityPanelUI.ServerData
    ActivityPanelUI.CreateBottomItem()
end

function ActivityPanelUI.CreateActivityCount()
    local activityScr = _gt.GetUI("activityScr")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(activityScr) + 1

    local btnBg = GUI.CheckBoxExCreate(activityScr, "btnBg_" .. curCount, "1801100010", "1801100010",0, 0, false, 417, 105)
    GUI.RegisterUIEvent(btnBg, UCE.PointerClick, "ActivityPanelUI", "OnActivityClick")

    local bgW = GUI.GetWidth(btnBg)
    local bgH = GUI.GetHeight(btnBg)
    local btnStateBg = GUI.ImageCreate(btnBg, "btnStateBg", "1801100010", 0, 0, false, bgW, bgH)
    SetAnchorAndPivot(btnStateBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(btnStateBg, true)

    --高光提示
    local effect = GUI.SpriteFrameCreate(btnBg, "effect", "", 0, 0,false,bgW+10,bgH+2)
    GUI.SetFrameId(effect, "3403900000")
    GUI.SetVisible(effect,false)
    UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
    GUI.Play(effect)

    --选择框图片
    local btnSelectImage = GUI.ImageCreate(btnStateBg, "btnSelectImage", "1800600160", -2, 0, false, bgW, bgH)
    SetAnchorAndPivot(btnSelectImage, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(btnSelectImage, false)

    --掉元宝图标
    local isIngot = GUI.ImageCreate(btnBg, "isIngot", "1801515040", 0, -1)
    SetAnchorAndPivot(isIngot, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetVisible(isIngot, false)

    local itemIcon = GUI.ItemCtrlCreate(btnBg, "itemIcon", "1800400050", 10, 0)
    GUI.SetScale(itemIcon, Vector3.New(0.875, 0.875, 0.875))
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "ActivityPanelUI", "OnActivityIconClick")
    SetAnchorAndPivot(itemIcon, UIAnchor.Left, UIAroundPivot.Left)

    local name = GUI.CreateStatic(btnBg, "name", "活动名字", 95, 20, 220, 30, "system", false, false)
    GUI.StaticSetFontSize(name, fontSize_BigOne)
    GUI.SetColor(name, ColorType_FontColor2)
    SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSizeBestFit(name)

    local num = GUI.CreateStatic(btnBg, "num", "次数", 95, -20, 50, 26,"system",true, false)
    SetAnchorAndPivot(num, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    GUI.StaticSetFontSize(num, fontSize_LittleOne)
    GUI.SetColor(num, ColorType_FontColor2)

    local txt = GUI.CreateStatic(num, "txt", "", 46, 0, 100, 26)
    GUI.StaticSetFontSize(txt, fontSize_LittleOne)
    GUI.SetColor(txt, ColorType_BlueLive)
    SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)

    local liveNum = GUI.CreateStatic(btnBg, "LiveActive", "活跃", 218, -20, 50, 26,"system",true, false)
    SetAnchorAndPivot(liveNum, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    GUI.StaticSetFontSize(liveNum, fontSize_LittleOne)
    GUI.SetColor(liveNum, ColorType_FontColor2)


    local txt = GUI.CreateStatic(liveNum, "txt", "", 45, 0, 120, 26, "system",false, false)
    SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(txt, fontSize_LittleOne)
    GUI.SetColor(txt, ColorType_BlueLive)

    local joinBtn = GUI.ButtonCreate(btnBg, "joinBtn", "1800402110", -15, 0, Transition.SpriteSwap, "", 82, 45, false)
    SetAnchorAndPivot(joinBtn, UIAnchor.Right, UIAroundPivot.Right)

    local btnTxt = GUI.CreateStatic(joinBtn, "btnTxt", "参加", 0, 0, 80, 30, "system",false)
    GUI.StaticSetAlignment(btnTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(btnTxt, fontSize_BigOne)
    GUI.SetColor(btnTxt, ColorType_FontColor2)
    GUI.RegisterUIEvent(joinBtn, UCE.PointerClick, "ActivityPanelUI", "OnJoinActivity")

    --限时任务和即将开启的显示时间或等级
    local notOpenSp = GUI.ImageCreate(btnBg, "notOpenSp", "1800600040", -10, 0, false, 90, 36)
    SetAnchorAndPivot(notOpenSp, UIAnchor.Right, UIAroundPivot.Right)
    GUI.SetVisible(notOpenSp, false)
    local txt = GUI.CreateStatic(notOpenSp, "txt", "", 0, 0, 180, 80, "system", true)
    SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.SetColor(txt, ColorType_FontColor2)
    GUI.StaticSetFontSize(txt, fontSize_LittleTwo)

    --必做角标
    local mustTodo = GUI.ImageCreate(btnBg, "mustTodo", "1800601110", 0, 0, false, 70, 70)
    SetAnchorAndPivot(mustTodo, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local mustTodoTxt = GUI.CreateStatic(mustTodo,"mustTodoTxt","必做", 0, 32,50, 30,"system",false)
    GUI.StaticSetAlignment(btnTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(mustTodoTxt, 20)
    GUI.SetColor(mustTodoTxt, ColorType_YellowName_ActivityTips)
    GUI.SetEulerAngles(mustTodoTxt, Vector3.New(0, 0, 45))

    return btnBg
end

function ActivityPanelUI.RefreshActivityCount(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]) + 1
    local Item = GUI.GetByGuid(guid)
    local Name = GUI.GetChild(Item,"name",false)
    local Icon = GUI.GetChild(Item,"itemIcon",false)
    local btnStateBg = GUI.GetChild(Item,"btnStateBg",false)
    local btnSelectImage = GUI.GetChild(btnStateBg,"btnSelectImage",false)
    local effect = GUI.GetChild(Item,"effect",false)
    local mustTodo = GUI.GetChild(Item,"mustTodo",false)
    local isIngot = GUI.GetChild(Item,"isIngot",false)
    local notOpenSp = GUI.GetChild(Item,"notOpenSp",false)
    local JoinNum = GUI.GetChild(Item,"num",false)
    local LiveActive = GUI.GetChild(Item,"LiveActive",false)
    local joinBtn = GUI.GetChild(Item,"joinBtn",false)
    local JoinTxt = GUI.GetChild(JoinNum,"txt",false)
    local ShowTxt = GUI.GetChild(notOpenSp,"txt",false)

    local ActiveTxt = GUI.GetChild(LiveActive,"txt",false)
    local table = ActivityTypeTable[index]

    if table.Data.max_count == nil then
        return
    end

    local startStrLength = string.split(table.TimeStart, " ")

    --参与按钮是否显示
    if table.IsShow == 1 and table.Status == 0 then
        GUI.SetVisible(joinBtn,false)--参与按钮
        GUI.SetVisible(notOpenSp,true)--显示开启时间或等级
        GUI.StaticSetText(ShowTxt, "<color=#" .. colorRich_Red2 .. ">" .. ActivityPanelUI.GetActivityTime(table) .. "</color>开启")

        if #startStrLength == 2 then

            GUI.SetWidth(notOpenSp,120)
            GUI.SetHeight(notOpenSp,46)
        else

            GUI.SetWidth(notOpenSp,90)
            GUI.SetHeight(notOpenSp,36)

        end
    elseif table.IsShow == 0 and table.Status ~= 2 then
        GUI.SetWidth(notOpenSp,90)
        GUI.SetHeight(notOpenSp,36)
        GUI.SetVisible(joinBtn,false)--参与按钮
        GUI.SetVisible(notOpenSp,true)--显示开启时间或等级
        GUI.StaticSetText(ShowTxt, "<color=#" .. colorRich_Red2 .. ">" .. tostring(table.LevelMin) .. "级</color>开启")
    elseif table.IsShow == 1 and table.Status == 1 then
        GUI.SetWidth(notOpenSp,90)
        GUI.SetHeight(notOpenSp,36)
        GUI.SetVisible(joinBtn,true)--参与按钮
        GUI.SetVisible(notOpenSp,false)--显示开启时间或等级
    end

    if hotActivityList[table.Name] ~= nil then
        if hotActivityList[table.Name][1] == 1 then
            GUI.SetVisible(effect,true)
        end
    else
        GUI.SetVisible(effect,false)
    end

    --必做是否显示
    if mustToDoActivityList[table.Name] ~= nil then
        if mustToDoActivityList[table.Name][1] == 1 then
            GUI.SetVisible(mustTodo,true)
        end
    else
        GUI.SetVisible(mustTodo,false)
    end

    --选择框刷新
    if LastSelectActivityId ~= nil then
        if table.Id == LastSelectActivityId then
            GUI.SetVisible(btnSelectImage,true)
            LastSelectActivityGuid = GUI.GetGuid(btnSelectImage)
            LastSelectActivityId = table.Id
        else
            GUI.SetVisible(btnSelectImage,false)
        end
    end

    --掉元宝图片是否显示
    if table.ShowMoney == 1 then
        GUI.SetVisible(isIngot,true)
    else
        GUI.SetVisible(isIngot,false)
    end

    GUI.ItemCtrlSetElementValue(Icon,eItemIconElement.Icon,tostring(table.Icon))
    GUI.ItemCtrlSetElementRect(Icon,eItemIconElement.Icon,0,-1,69,69)
    GUI.StaticSetText(Name,table.Name)

    --参与次数
    local awardNumMax = table.Data.max_count
    if awardNumMax == 0 then
        GUI.StaticSetText(JoinTxt, "无限")
    else
        GUI.StaticSetText(JoinTxt, table.Data.count .. "/" .. awardNumMax)
    end

    --活跃值
    local awardPoint = table.Data.max_point
    if awardPoint == 0 then
        GUI.StaticSetText(ActiveTxt, "无")
    else
        GUI.StaticSetText(ActiveTxt, table.Data.point .. "/" .. awardPoint)
    end

    GUI.SetData(Item,"ActivityId",table.Id)
    GUI.SetData(Icon,"ActivityId",table.Id)
    GUI.SetData(Item,"ItemIndex",index)
    GUI.SetData(Icon,"ItemIndex",index)
    GUI.SetData(joinBtn,"ActivityId",table.Id)

end

function ActivityPanelUI.RefreshAllActivityCount(index1, index2)

    if not index1 or not index2 then
        return
    end

    if index2 == "0" then
        index2 = "1"
    end

    local Btn = _gt.GetUI("activityTypeBtn"..index1)
    local BtnGuid = GUI.GetGuid(Btn)
    if tostring(BtnGuid) ~= LastBtnGuid then
        GUI.ButtonSetImageID(Btn,"1800002031")
        if LastBtnGuid ~= nil then
            GUI.ButtonSetImageID(GUI.GetByGuid(LastBtnGuid),"1800002030")
        end
    end
    LastBtnGuid = tostring(BtnGuid)

    local ToggleGroup = _gt.GetUI("activityAwardType"..index2)
    local ToggleCheck = GUI.GetChild(ToggleGroup,"toggle",false)
    local ToggleGuid = GUI.GetGuid(ToggleCheck)
    if tostring(ToggleGuid) ~= LastToggleGuid then
        GUI.CheckBoxSetCheck(ToggleCheck,true)
        if LastToggleGuid ~= nil then
            GUI.CheckBoxSetCheck(GUI.GetByGuid(LastToggleGuid),false)
        end
    end
    LastToggleGuid = tostring(ToggleGuid)
    ActivityIndex1 = tostring(index1)
    ActivityIndex2 = tostring(index2)

    --表单刷新
    ActivityPanelUI.ProcessingTypeTable(index1,index2)

    local activityScr = _gt.GetUI("activityScr")
    if #ActivityTypeTable > 0 and ActivityTypeTable ~= nil then
        GUI.LoopScrollRectSetTotalCount(activityScr, #ActivityTypeTable)
    else
        GUI.LoopScrollRectSetTotalCount(activityScr, #ActivityTypeTable)
    end
    GUI.LoopScrollRectRefreshCells(activityScr)

end

function ActivityPanelUI.GotoActivity(index)
    local activityScr = _gt.GetUI("activityScr")
    GUI.LoopScrollRectSrollToCell(activityScr,index,2000)
end

--获得所有表单数据处理
function ActivityPanelUI.ProcessingAllTable()
    ActivityAllTable = {}
    local configs = DB.GetActivityAllKeys()
    local count = configs.Count
    --local curLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    for i = 1, count do
        local id = configs[i - 1]
        local config = DB.GetActivity(id)

        local temp = {
            Id =  tonumber(config.Id),
            Index = config.Index,
            Icon = tostring(config.Icon),
            Name = config.Name,
            Type = config.Type, --0为日常活动,1为限时活动,2为节日活动
            IsShow = 0, --0为不显示,1为显示
            Status = 0, --0为不开启活动,1为开启活动
            Data = {},
            TimeInfo = config.TimeInfo,
            ReceiveInfo = config.ReceiveInfo,
            LevelInfo = config.LevelInfo,
            WayInfo = config.WayInfo,
            DesInfo = config.DesInfo,
            Show = config.Show,
            Time = config.Time,
            TimeType = config.TimeType,
            Time = config.Time,
            TimeStart = config.TimeStart,
            TimeEnd = config.TimeEnd,
            LevelMin = config.LevelMin,
            ShowMoney = 0,--掉元宝图片,0为不显示,1为显示
        }
        ActivityAllTable[tostring(config.Id)] = temp
    end
end

function ActivityPanelUI.ProcessingTypeTable(index1,index2)
    local index1 = tonumber(index1)
    local index2 = tonumber(index2)
    ActivityTypeTable = {}

    if index1 == "1" or index1 == 1 then--日常活动
        for k, v in pairs(ActivityAllTable) do
            if v.Type == 0 then
                if v.IsShow == 1 and v.Status == 1 then
                    if index2 == 1 then
                        ActivityTypeTable[#ActivityTypeTable + 1] = v
                    else
                        if v.Data.type then
                            for i = 1, #v.Data.type do
                                if v.Data.type[i] ~= "nil" and tonumber(v.Data.type[i]) == index2 - 1 then
                                    ActivityTypeTable[#ActivityTypeTable + 1] = v
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif index1 == "2" or index1 == 2 then --限时活动
        for k, v in pairs(ActivityAllTable) do
            if v.Type == 1 then
                if v.IsShow == 1 and v.Status ~= 2 then
                    if index2 == 1 then
                        ActivityTypeTable[#ActivityTypeTable + 1] = v
                    else
                        for i = 1, #v.Data.type do
                            if v.Data.type[i] ~= "nil" and tonumber(v.Data.type[i]) == index2 - 1 then
                                ActivityTypeTable[#ActivityTypeTable + 1] = v
                            end
                        end
                    end

                end
            end
        end
    elseif index1 == "3" or index1 == 3 then --节日活动(未有节日活动，没实测)
        for k, v in pairs(ActivityAllTable) do
            if v.Type == 2 then
                if v.IsShow == 1 and v.Status == 1 then
                    if index2 == 1 then
                        ActivityTypeTable[#ActivityTypeTable + 1] = v
                    else
                        for i = 1, #v.Data.type do
                            if v.Data.type[i] ~= "nil" and tonumber(v.Data.type[i]) == index2 - 1 then
                                ActivityTypeTable[#ActivityTypeTable + 1] = v
                            end
                        end
                    end

                end
            end
        end
    elseif index1 == "4" or index1 == 4 then --即将开启
        for k, v in pairs(ActivityAllTable) do
            if v.Type == 0 or v.Type == 1 then
                if v.IsShow == 0 and v.Status ~= 2 then
                    if v.Data.status ~= 4 then
                        if index2 == 1 then
                            ActivityTypeTable[#ActivityTypeTable + 1] = v
                        else
                            for i = 1, #v.Data.type do
                                if v.Data.type[i] ~= "nil" and tonumber(v.Data.type[i]) == index2 - 1 then
                                    ActivityTypeTable[#ActivityTypeTable + 1] = v
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(ActivityTypeTable, ActivityPanelUI.Sort)
end

function ActivityPanelUI.Sort(a, b)

    local pri1 = sortPriority[a.Data.status]
    local pri2 = sortPriority[b.Data.status]
    if pri1 == nil or pri2 == nil then
        return false
    end
    if pri1 == pri2 then
        if a.Data.startTime == b.Data.startTime then
            return a.Index > b.Index
        end
        return a.Data.startTime < b.Data.startTime
    end
    return pri1 < pri2
end

function ActivityPanelUI.GetActivityList()

    --配置活动是否显示状态
    local curTickCount = CL.GetServerTickCount()
    local dateStr = string.split(os.date("!%d %w %H %M %S", curTickCount), " ")
    local day = dateStr[1]
    local week = dateStr[2] == "0" and "7" or dateStr[2]    -- os.date()这个方法里星期天是0来着
    local hour = dateStr[3]
    local minute = dateStr[4]
    local second = dateStr[5]
    local curTime = tonumber(hour) * 3600 + tonumber(minute) * 60 + tonumber(second)
    LastInitDataTime = curTime
    local curLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    --IsShow : 0为不显示,1为显示
    --Status : 0为不开启活动,1为开启活动
    for k, v in pairs(ActivityAllTable) do
        if v.Show == 1 then
            v.IsShow = 0
            v.Status = 0
            if v.TimeType == 2 then
                --周循环
                if LogicDefine.CheckActivityDay(v.Time, week) then
                    local startStatus,endStatus = LogicDefine.CheckActivityTime2(v.TimeStart, v.TimeEnd, curTime)

                    if startStatus == true and endStatus == true then
                        v.IsShow = 1
                        v.Status = 1

                    elseif startStatus == false and endStatus == true then
                        v.IsShow = 1
                        v.Status = 0
                    elseif startStatus == true and endStatus == false then
                        v.IsShow = 1
                        v.Status = 2
                    end

                else
                    v.IsShow = 0
                    v.Status = 2
                end
            elseif v.TimeType == 3 then
                -- 月循环
                if LogicDefine.CheckActivityDay(v.Time, day) then
                    local startStatus,endStatus = LogicDefine.CheckActivityTime2(v.TimeStart, v.TimeEnd, curTime)
                    if startStatus == true and endStatus == true then
                        v.IsShow = 1
                        v.Status = 1

                    elseif startStatus == false and endStatus == true then
                        v.IsShow = 1
                        v.Status = 0
                    end
                else
                    v.IsShow = 0
                    v.Status = 2
                end
            elseif v.TimeType == 0 then

                local startStatus,endStatus = LogicDefine.CheckActivityDate2(v.TimeStart, v.TimeEnd, curTickCount)
                if startStatus == true and endStatus == true then
                    v.IsShow = 1
                    v.Status = 1

                elseif startStatus == false and endStatus == true then
                    v.IsShow = 1
                    v.Status = 0
                elseif startStatus == true and endStatus == false then
                    v.IsShow = 1
                    v.Status = 2
                end
            else
                v.IsShow = 1
                local startStatus,endStatus = LogicDefine.CheckActivityTime2(v.TimeStart, v.TimeEnd, curTime)
                if startStatus == true and endStatus == true then
                    v.IsShow = 1
                    v.Status = 1

                elseif startStatus == false and endStatus == true then
                    v.IsShow = 1
                    v.Status = 0
                elseif startStatus == true and endStatus == false then
                    v.IsShow = 1
                    v.Status = 2
                end
            end

            --最后根据等级判断
            if curLevel >= v.LevelMin then
                v.IsShow = 1
            else
                v.IsShow = 0
            end
        else
            v.Status = 2
        end
    end

    --活动详情表单
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
        local types = string.split(custom[7], ",")

        local Status = nil

        if ActivityAllTable[tostring(data.id)] == nil then
            Status = 0
        else
            Status = ActivityPanelUI.GetActivityStatus(tonumber(custom[6]),ActivityAllTable[tostring(data.id)].Status)
        end

        if ActivityAllTable[tostring(data.id)] == nil then
            return
        end

        local t = {
            startTime = ActivityPanelUI.GetActivityStartTime(ActivityAllTable[tostring(data.id)]), -- 活动开始的时间，用来排序
            status = Status,
            state = data.state,
            today = data.today,
            count = tonumber(custom[1]) or 0, -- 当前参加次数
            max_count = tonumber(custom[2]) or 0,--次数上限
            point = tonumber(custom[3]) or 0,
            max_point = tonumber(custom[4]) or 0,
            type = types,
        }
        ActivityAllTable[tostring(data.id)].ShowMoney = 0
        for i = 1, #types do
            if types[i] == 1 or types[i] == "1" then
                ActivityAllTable[tostring(data.id)].ShowMoney = 1
            end
        end

        ActivityAllTable[tostring(data.id)]["Data"] = t
    end
end

function ActivityPanelUI.GetActivityStatus(state, isOpen)
    --活动状态 0：未开始 1：已完成 2：待参与 3:正在参与 4:未开启 5：奖励已领取 99:非今日活动（客户端自己添加）
    -- 服务端脚本活动状态： 1:可参加，2:进行中, 3：已完成
    if state == nil then
        return 4
    end
    if state == 3 then
        return 1
    end
    if not isOpen then
        return 4
    end
    if state < 3 then
        return 2
    end
    return 0
end

function ActivityPanelUI.GetActivityStartTime(config)

    if config == nil then
        print("参数config为空！")
        return 0
    end

    local timeStart = config.TimeStart
    local timeEnd = config.TimeEnd
    if config.TimeType == 0 then
        local str = string.split(config.TimeStart, " ")
        local endStr = string.split(config.TimeEnd, " ")
        if #str == 2 then
            timeStart = str[2]
        else
            timeStart = "00:00:00"
            timeEnd = timeStart
            print("活动开始时间配置错误! ActivityID: ", config.Id)
        end
    end
    local startStr = string.split(timeEnd, ":")
    if tonumber(startStr[1]) ~= nil then
        local e = tonumber(startStr[1]) * 3600 + tonumber(startStr[2]) * 60 + tonumber(startStr[3])
        if e < LastInitDataTime then
            return 24 * 3600
        end
        startStr = string.split(timeStart, ":")
        return tonumber(startStr[1]) * 3600 + tonumber(startStr[2]) * 60 + tonumber(startStr[3])
    else
        return 0
    end
end

--滚动列表刷新调用
function ActivityPanelUI.GetActivityTime(activityConfig)

    if activityConfig.TimeType == 0 then
        local tmpStr = nil
        local temp1 = string.split(activityConfig.TimeStart, " ")
        if #temp1 == 2 then

            local str = string.split(temp1[2], ":")
            if #str >= 5 then
                tmpStr = str[4] .. ":" .. str[5]
            else
                tmpStr = str[1] .. ":" .. str[2]
            end
            return temp1[1].."\n".. tmpStr
        else
            local str = string.split(activityConfig.TimeStart, ":")
            if #str >= 5 then
                tmpStr = str[4] .. ":" .. str[5]
                return tmpStr
            end
        end

    else
        local tmpStr = nil
        local str = string.split(activityConfig.TimeStart, ":")
        if #str >= 2 then
            tmpStr = str[1] .. ":" .. str[2]
            return tmpStr
        end
    end

    return activityConfig.TimeStart
end

function ActivityPanelUI.OnActivityAwardTypeToggleTxtClick(guid)
    ActivityPanelUI.ShowSelectImage()
    local CheckBtn = GUI.GetByGuid(guid)
    local index2 = GUI.GetData(CheckBtn,"index")
    ActivityPanelUI.RefreshAllActivityCount(ActivityIndex1, index2)
end

function ActivityPanelUI.OnActivityBtnClick(guid)
    ActivityPanelUI.ShowSelectImage()
    local Btn = GUI.GetByGuid(guid)
    local index1 = GUI.GetData(Btn,"BtnIndex")
    ActivityPanelUI.RefreshAllActivityCount(index1,1)
end

function ActivityPanelUI.OnExit()
    ActivityPanelUI.ShowSelectImage()
    ActivityPanelUI.Init()
    GUI.CloseWnd("ActivityPanelUI")
    ActivityPanelUI.RefreshAllActivityCount(1, 1)
    ActivityPanelUI.UnRegister()

end

function ActivityPanelUI.Register()
    CL.RegisterMessage(GM.ActivityListUpdate, "ActivityPanelUI", "OnActivityListUpdate")
    CL.RegisterMessage(GM.FightStateNtf, "ActivityPanelUI", "InFight")
end

function ActivityPanelUI.UnRegister()
    CL.UnRegisterMessage(GM.ActivityListUpdate, "ActivityPanelUI", "OnActivityListUpdate")
    CL.UnRegisterMessage(GM.FightStateNtf, "ActivityPanelUI", "InFight")
end

--活动更新监听事件
function ActivityPanelUI.OnActivityListUpdate()
    ActivityPanelUI.GetActivityList()
    ActivityPanelUI.RefreshAllActivityCount(ActivityIndex1, ActivityIndex2)
end

--活动日历点击事件
function ActivityPanelUI.OnCalendarBtnClick(guid)
    GUI.OpenWnd("ActivityCalendarUI")
end

--底部活跃奖励
function ActivityPanelUI.CreateBottomItem()
    local sliderBg = _gt.GetUI("sliderBg")
    local sliderBgWidth = GUI.GetWidth(sliderBg)
    --设置活跃度进度条显示
    local fill = GUI.GetChild(sliderBg,"fill",false)
    local handle = GUI.GetChild(fill,"handle",false)
    local txt = GUI.GetChild(handle,"txt",false)

    if RoleAttrActivation > 100 then
        GUI.SetWidth(fill,sliderBgWidth)
    else
        GUI.SetWidth(fill,(RoleAttrActivation/100)*sliderBgWidth)
    end
    GUI.StaticSetText(txt,RoleAttrActivation)


    --设置奖励控件
    for i = 1, #RoleServerData.RewardList do
        local item = GUI.GetChild(sliderBg,"AwardItem"..i,false)
        local itemDB = DB.GetOnceItemByKey2(RoleServerData.RewardList[i][2])
        if item then
            GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,tostring(itemDB.Icon))
            if RoleAttrActivation < RoleServerData.RewardList[i][1] then
                GUI.ItemCtrlSetIconGray(item,true)
            else
                GUI.ItemCtrlSetIconGray(item,false)
            end
            GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[tonumber(itemDB.Grade)])
        else
            local ItemIconBg = GUI.ItemCtrlCreate(sliderBg,"AwardItem"..i,QualityRes[1],(2*i - 1) * sliderBgWidth / 10 -40,58,80,80)
            GUI.ItemCtrlSetElementValue(ItemIconBg,eItemIconElement.Icon,tostring(itemDB.Icon))
            GUI.RegisterUIEvent(ItemIconBg, UCE.PointerClick, "ActivityPanelUI", "OnAwardBtnClick")
            GUI.SetData(ItemIconBg,"awardItemId",itemDB.Id)
            if RoleAttrActivation < RoleServerData.RewardList[i][1] then
                GUI.ItemCtrlSetIconGray(ItemIconBg,true)
            else
                GUI.ItemCtrlSetIconGray(ItemIconBg,false)
            end
            GUI.ItemCtrlSetElementValue(ItemIconBg,eItemIconElement.Border,QualityRes[tonumber(itemDB.Grade)])
            SetAnchorAndPivot(ItemIconBg, UIAnchor.Left, UIAroundPivot.Left)
            local ItemIconBgText = GUI.CreateStatic(ItemIconBg,"ItemIconBgText",RoleServerData.RewardList[i][1].."活跃",0,88,120,40,"system",true,false)
            GUI.StaticSetFontSize(ItemIconBgText, fontSize_BigOne)
            GUI.SetColor(ItemIconBgText, ColorType_FontColor2)
        end
    end
end

--底部奖励点击事件
function ActivityPanelUI.OnAwardBtnClick(guid)
    local ItemIconBg = GUI.GetByGuid(guid)
    local itemId = GUI.GetData(ItemIconBg, "awardItemId")
    if itemId == nil or string.len(itemId) == 0 then
        return
    end

    local panelBg = _gt.GetUI("panelBg")
    local itemTips = Tips.CreateByItemId(itemId, panelBg, "itemTips", 0, -30)
end

--活动参加按钮点击事件
function ActivityPanelUI.OnJoinActivity(guid)
    local joinBtn = GUI.GetByGuid(guid)
    local activityId = GUI.GetData(joinBtn, "ActivityId")

    if activityId == nil or string.len(activityId) == 0 then
        return
    else
        activityId = tonumber(activityId)
        if activityId == nil then
            return
        end
    end

    local activity = DB.GetActivity(activityId)
    if activity and activity.Id > 0 then
        GlobalUtils.JoinActivity(activityId)
    end
end

function ActivityPanelUI.SetNewStateVisible(btn, vis)
    if btn == nil then
        return
    end
    local new = GUI.GetChild(btn, "new")
    if vis then
        if new == nil then
            new = GUI.ImageCreate(btn, "new", "1801408170", 0, 0)
            SetAnchorAndPivot(new, UIAnchor.TopRight, UIAroundPivot.TopRight)
        else
            GUI.SetVisible(new, true)
        end
    else
        if new ~= nil then
            GUI.SetVisible(new, false)
        end
    end
end

--选择控件进行活动弹窗
function ActivityPanelUI.OnActivityClick(guid)
    local btn = GUI.GetByGuid(guid)
    local btnStateBg = GUI.GetChild(btn,"btnStateBg",false)
    local btnSelectImage = GUI.GetChild(btnStateBg,"btnSelectImage",false)
    local activityId = GUI.GetData(btn, "ActivityId")
    local ItemIndex = GUI.GetData(btn, "ItemIndex")

    if activityId == nil or string.len(activityId) == 0 then
        return
    end
    activityId = tonumber(activityId)
    if activityId == nil then
        return
    end

    LastSelectActivityId = activityId
    ActivityPanelUI.CreateActivityTips(activityId,ItemIndex,btnSelectImage)
end

--选择图标进行活动弹窗
function ActivityPanelUI.OnActivityIconClick(guid)
    local Icon = GUI.GetByGuid(guid)
    local btnBg = GUI.GetParentElement(Icon)
    local btnStateBg = GUI.GetChild(btnBg,"btnStateBg",false)
    local btnSelectImage = GUI.GetChild(btnStateBg,"btnSelectImage",false)
    local activityId = GUI.GetData(Icon, "ActivityId")
    local ItemIndex = GUI.GetData(Icon, "ItemIndex")

    if activityId == nil or string.len(activityId) == 0 then
        return
    end
    activityId = tonumber(activityId)
    if activityId == nil then
        return
    end
    LastSelectActivityId = activityId
    ActivityPanelUI.CreateActivityTips(activityId,ItemIndex,btnSelectImage)
end

--选择框是否显示
function ActivityPanelUI.ShowSelectImage(parent)
    if parent == nil then
        if LastSelectActivityGuid ~= nil then
            local LastSelectActivityItem = GUI.GetByGuid(LastSelectActivityGuid)
            GUI.SetVisible(LastSelectActivityItem,false)
        end
    end
    local btnSelectImageGuid = GUI.GetGuid(parent)

    if btnSelectImageGuid ~= LastSelectActivityGuid then
        GUI.SetVisible(parent,true)
        local LastSelectActivityItem = GUI.GetByGuid(LastSelectActivityGuid)
        GUI.SetVisible(LastSelectActivityItem,false)
    end
    LastSelectActivityGuid = btnSelectImageGuid
end

--点击活动显示的Tips
function ActivityPanelUI.CreateActivityTips(activityId,ItemIndex,btnSelectImage)
    if LastSelectIndex ~= nil then
        if LastActivityIndex2 == ActivityIndex2 then
            if LastSelectIndex ~= (ItemIndex % 2)  then
                local activityTips =_gt.GetUI("activityTips")
                LastSelectIndex = (ItemIndex % 2)
                GUI.Destroy(activityTips)
                return
            end
        end
    end
    LastActivityIndex2 = ActivityIndex2
    LastSelectIndex = (ItemIndex % 2)
    ActivityPanelUI.ShowSelectImage(btnSelectImage)
    local panelBg = _gt.GetUI("panelBg")
    local activityTips = GUI.GetChild(panelBg,"activityTips",false)
    if activityId == nil then
        GUI.Destroy(activityTips)
        return
    end
    local Abscissa = 0
    if ItemIndex%2 > 0 then --左边活动，右边显示
        Abscissa = 325
    else -- 右边活动，左边显示
        Abscissa = -132
    end
    local activityData = LD.GetActivityDataByID(activityId)
    if activityData == nil then
        print("奖励中找不到此活动的数据："..activityData.ActivtiyID)
        return
    end
    local custom = string.split(activityData.custom, ":")
    local oneItem = string.split(custom[5], ",")
    local activityDB = ActivityAllTable[tostring(activityId)]

    if activityTips == nil then
        activityTips = GUI.ListCreate(panelBg,"activityTips",Abscissa,0, 200, 100)
        _gt.BindName(activityTips,"activityTips")
        local activityBag = GUI.ImageCreate(activityTips, "activityTips", "1800400290", 0, 0, false,450, 360)

        local itemIcon = GUI.ItemCtrlCreate(activityBag, "itemIcon", QualityRes[1], 15, 15)
        GUI.SetScale(itemIcon, Vector3.New(0.875, 0.875, 0.875))
        GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,tostring(activityDB.Icon))
        GUI.ItemCtrlSetElementRect(itemIcon,eItemIconElement.Icon,0,-1,69,69)
        SetAnchorAndPivot(itemIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        --活动名字
        local name = ActivityPanelUI.CreateStatic(fontSize, "name", activityBag, 105, 10, ColorType_YellowName_ActivityTips, false, 300, 50)
        GUI.StaticSetText(name,activityDB.Name)
        SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local count = ActivityPanelUI.CreateStatic(fontSize, "count", activityBag, 105, 50, ColorType_YellowName_ActivityTips,false,100,40)
        if activityDB.Data.max_count == 0 then
            GUI.StaticSetText(count, "无限")
        else
            GUI.StaticSetText(count,activityDB.Data.count.."/"..activityDB.Data.max_count)
        end
        SetAnchorAndPivot(count, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local time = ActivityPanelUI.CreateStatic(fontSize, "time", activityBag, 15, 90, ColorType_Yellow_ActivityTips, false, 115, 35)
        SetAnchorAndPivot(time, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(time, "活动时间：")
        local txt = GUI.CreateStatic(time, "txt", "", 115, 0, 310, 26, "system", true, false)
        GUI.StaticSetText(txt,activityDB.TimeInfo)
        GUI.SetColor(txt, ColorType_Blue_ActivityTips)
        GUI.StaticSetFontSize(txt, fontSize)
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)

        local limitNum = ActivityPanelUI.CreateStatic(fontSize, "limitNum", activityBag, 15, 120, ColorType_Yellow_ActivityTips, false, 115, 35)
        SetAnchorAndPivot(limitNum, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(limitNum, "人数限制：")
        local txt = ActivityPanelUI.CreateStatic(fontSize, "txt", limitNum, 115, 0, ColorType_YellowName_ActivityTips, false, 310, 26)
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)
        GUI.StaticSetText(txt,activityDB.ReceiveInfo)

        local limitLevel = ActivityPanelUI.CreateStatic(fontSize, "limitLevel", activityBag, 15, 150, ColorType_Yellow_ActivityTips, false, 115, 35)
        SetAnchorAndPivot(limitLevel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(limitLevel, "等级限制：")
        local txt = ActivityPanelUI.CreateStatic(fontSize, "txt", limitLevel, 115, 0, ColorType_Blue_ActivityTips, false, 310, 26)
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)
        GUI.StaticSetText(txt,activityDB.LevelInfo)

        local receive = ActivityPanelUI.CreateStatic(fontSize, "receive", activityBag, 15, 180, ColorType_Yellow_ActivityTips, false, 115, 35)
        SetAnchorAndPivot(receive, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(receive, "任务领取：")
        local txt = GUI.CreateStatic(receive, "txt", "", 115, 0, 310, 26, "system", true, false)
        GUI.SetColor(txt, ColorType_Blue_ActivityTips)
        GUI.StaticSetFontSize(txt, fontSize)
        SetAnchorAndPivot(txt, UIAnchor.Left, UIAroundPivot.Left)
        GUI.StaticSetText(txt,activityDB.WayInfo)

        local des = ActivityPanelUI.CreateStatic(fontSize, "des", activityBag, 15, 210, ColorType_Yellow_ActivityTips, false, 115, 35)
        SetAnchorAndPivot(des, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetText(des, "活动描述：")
        local txt = GUI.CreateStatic(des, "txt", "", 115, 5, 310, 26, "system", true, false)
        GUI.SetColor(txt, ColorType_YellowName_ActivityTips)
        GUI.StaticSetFontSize(txt, fontSize)
        GUI.StaticSetText(txt,activityDB.DesInfo)
        local desPreferHeight = GUI.StaticGetLabelPreferHeight(txt)
        GUI.SetHeight(txt, desPreferHeight)
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local award = ActivityPanelUI.CreateStatic(fontSize, "award", txt, -115, 30, ColorType_Yellow_ActivityTips,false,115,35)
        SetAnchorAndPivot(award, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.StaticSetText(award, "活动奖励：")

        local ItemScrWidth = 0
        if #oneItem > 4 then
            ItemScrWidth = 4 *88
        else
            ItemScrWidth = #oneItem * 88
        end
        local ItemScrHigh = math.ceil(#oneItem / 4) * 85
        local ItemScr = GUI.ScrollRectCreate(
                award,
                "BagTypeScr",
                20,
                -ItemScrHigh + 10,
                ItemScrWidth,
                ItemScrHigh,
                0,
                false,
                Vector2.New(85, 85),
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                4,
                false
        )
        GUI.ScrollRectSetVertical(ItemScr,false)
        ItemScr:RegisterEvent(UCE.PointerClick)
        GUI.SetIsRaycastTarget(ItemScr, true)
        GUI.AddWhiteName(activityTips,GUI.GetGuid(ItemScr))
        SetAnchorAndPivot(ItemScr, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.ScrollRectSetChildSpacing(ItemScr,Vector2.New(7, 3))
        for i = 1, #oneItem do
            local itemDB = DB.GetOnceItemByKey1(oneItem[i])
            local itemIcon = GUI.ItemCtrlCreate(ItemScr, "itemIcon"..i, QualityRes[1], 0, -75)
            GUI.SetScale(itemIcon, Vector3.New(0.875, 0.875, 0.875))

            GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,tostring(itemDB.Icon))
            GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,QualityRes[tonumber(itemDB.Grade)])
            GUI.ItemCtrlSetElementRect(itemIcon,eItemIconElement.Icon,0,-1,69,69)
            GUI.AddWhiteName(activityTips,GUI.GetGuid(itemIcon))
            GUI.SetData(itemIcon,"ItemId",itemDB.Id)
            GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "ActivityPanelUI", "OnTipsAwardBtnClick")
        end

        GUI.SetHeight(activityBag,250 + desPreferHeight + ItemScrHigh)
        GUI.GUIListGetPreferredHeight(activityTips)
        GUI.SetIsRemoveWhenClick(activityTips, true)
    end
end

function ActivityPanelUI.OnTipsAwardBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local itemId = GUI.GetData(btn, "ItemId")
    if itemId == nil or string.len(itemId) == 0 then
        return
    end
    local activityTips = _gt.GetUI("activityTips")
    local tmpPosX = GUI.GetPositionX(activityTips) < 0 and 300 or -120
    local panelBg = _gt.GetUI("panelBg")
    -- 显示物品Tips
    local itemTips = Tips.CreateByItemId(itemId, panelBg, "itemTips", tmpPosX, 0)
end

function ActivityPanelUI.OnBtnScrClick()
    local activityTips = _gt.GetUI("activityTips")
    if activityTips ~= nil then
        GUI.Destroy(activityTips)
    end
end

function ActivityPanelUI.CreateStatic(fontsize, key, parent, x, y, color, isRich, w, h)
    color = color or ColorType_FontColor2
    x = x or 0
    y = y or 0
    fontsize = fontsize or fontSize
    isRich = isRich or false
    w = w or 0
    h = h or 0
    local txt = GUI.CreateStatic(parent, key, "", x, y, w, h, "system", isRich)
    GUI.StaticSetFontSize(txt, fontsize)
    GUI.SetColor(txt, color)
    SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    return txt
end

function ActivityPanelUI.InFight(InFight)
    if InFight then
        ActivityPanelUI.OnExit()
    end
end