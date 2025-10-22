local ActivityCollectUI = {}

_G.ActivityCollectUI = ActivityCollectUI
local _gt = UILayout.NewGUIDUtilTable()

---------------------------------缓存需要的全局变量Start------------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
---------------------------------缓存需要的全局变量End-------------------------------

local ratio = 2                 -- 赠送好友时需要2个相同印章才能赠送
local RewardList = {}           -- 奖励列表
local contact_friend = 2        -- 好友
local FriendList = {}           -- 好友列表
local TaskList = {}             -- 活动页面列表
local TaskPic = {}              -- 活动图片类型
local ActivityReword = {}       -- 第二页面的任务奖励列表
local FinishTaskCount = nil     -- 完成的任务数量
local DayCanFinishMax = nil     -- 每日最大完成数量
local TaskRefreshGold = 0       -- 刷新任务品级需要的银币
local TicketGetNum = nil
local SelectTaskList = nil
local SelectTaskListGuid = nil
local SelectCheckBoxRole = nil
local SelectCheckBoxRoleGuid = nil
local SelectCollectEffect = nil
local fontSizeDefault = 22
local fontSizeSmaller = 20
local fontSizeBigger = 24
local Collection =  {
    ["谪剑仙"] = {Count = 0},
    ["飞翼姬"] = {Count = 0},
    ["烟云客"] = {Count = 0},
    ["冥河使"] = {Count = 0},
    ["阎魔令"] = {Count = 0},
    ["雨师君"] = {Count = 0},
    ["神霄卫"] = {Count = 0},
    ["傲红莲"] = {Count = 0},
    ["花弄影"] = {Count = 0},
    ["青丘狐"] = {Count = 0},
    ["海鲛灵"] = {Count = 0},
    ["凤凰仙"] = {Count = 0},
}

local GetId = nil      -- 抽奖券ID

local roleIcon = {
    ["谪剑仙"] = {"1800107010"},
    ["飞翼姬"] = {"1800107020"},
    ["烟云客"] = {"1800107030"},
    ["冥河使"] = {"1800107040"},
    ["阎魔令"] = {"1800107050"},
    ["雨师君"] = {"1800107060"},
    ["神霄卫"] = {"1800107070"},
    ["傲红莲"] = {"1800107080"},
    ["花弄影"] = {"1800107090"},
    ["青丘狐"] = {"1800107100"},
    ["海鲛灵"] = {"1800107110"},
    ["凤凰仙"] = {"1800107120"}
}

-- 颜色
local colorDark = Color.New(102/255, 47/255, 22/255, 255/255)
local colorWhite = Color.New(255/255, 246/255, 232/255, 255/255)
local colorOutline = Color.New(175/255, 96/255, 19/255, 255/255)

local timer = nil

local level = {
    [1] = {"1801407260","1801401140"},   -- D
    [2] = {"1801407150","1801401150"},   -- C
    [3] = {"1801407140","1801401160"},   -- B
    [4] = {"1801407130","1801401170"},   -- A
    [5] = {"1801407120","1801401180"},   -- S
}

local TaskState = {
    [0] = "1801208670", -- 已完成
    [1] = "",           -- 未接取
    [2] = "1801208710", -- 已领取
}

local pageNum = {
    mainPage = 1,
    activityPage = 2
}

local LabelList={
    {"主页","mainPageTog","OnMainClick","mainPage","CreateMainPage"},
    {"任务","activityPageTog","OnActivityClick","activityPage","CreateActivityPage"}
}

-- 当前所在的页签
local nowPage = 1

-- 抽奖用
local LastEffect = nil
local NowEffect = nil

function ActivityCollectUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("ActivityCollectUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("ActivityCollectUI", "ActivityCollectUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "集印章赢大奖", "ActivityCollectUI", "OnExit")
    _gt.BindName(panelBg, "panelBg")

    UILayout.CreateRightTab(LabelList,"ActivityCollectUI")

end

function ActivityCollectUI.OnShow()
    --等级不足时禁止打开
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = 40
    local wnd = GUI.GetWnd("ActivityCollectUI")

    if wnd == nil then
        return
    end

    if CurLevel < Level then
        CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启收集印章赢大奖活动")
        GUI.SetVisible(wnd,false)
        return
    end

    GUI.SetVisible(wnd,true)
    ActivityCollectUI.InitData()

    ActivityCollectUI.OnMainClick()
end

function ActivityCollectUI.OnMainClick()

    if not ActivityCollectUI.ResetLastSelectPage(pageNum.mainPage) then
        return
    end

    local taskStr = _gt.GetUI("taskStr")
    if taskStr then
        GUI.LoopScrollRectSrollToCell(taskStr, 0, 10000)
        GUI.LoopScrollRectSetTotalCount(taskStr, #TaskList)
        GUI.LoopScrollRectRefreshCells(taskStr)
    end

    ActivityCollectUI.InitData()
end

function ActivityCollectUI.OnActivityClick()

    if not ActivityCollectUI.ResetLastSelectPage(pageNum.activityPage) then
        return
    end

    ActivityCollectUI.TaskInitData()
end

function ActivityCollectUI.ResetLastSelectPage(index)
    UILayout.OnTabClick(index,LabelList)
    if nowPage == index then
        return false
    end
    ActivityCollectUI.SetLastPageInvisible()
    nowPage = index
    return true
end

function ActivityCollectUI.SetLastPageInvisible()
    if nowPage then
        local name = LabelList[nowPage][4]
        local lastPage=_gt.GetUI(name)
        if lastPage then
            GUI.SetVisible(lastPage,false)
        end
        nowPage = nil
    end
end

-- 创建主页面
function ActivityCollectUI.CreateMainPage(pageName)
    local panelBg = _gt.GetUI("panelBg")
    local mainPage = GUI.GroupCreate(panelBg, pageName,0,0,1197,639)
    _gt.BindName(mainPage, pageName)

    local scrBg = GUI.ImageCreate(mainPage, "scrBg", "1800400010", 65, 55, false, 335, 565)
    SetAnchorAndPivot(scrBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(scrBg, "scrBg")

    -- 滚动框顶上的说明
    local titleBg = GUI.ImageCreate(scrBg, "titleBg", "1800700070", 0, 5, false, 325, 40);
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top);

    local titleText = GUI.CreateStatic(titleBg, "titleText", "收集奖励", 10, 0, 100, 30);
    GUI.SetColor(titleText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(titleText, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter);
    UILayout.SetSameAnchorAndPivot(titleText, UILayout.Left);

    local hintBtn2 = GUI.ButtonCreate(titleBg, "hintBtn2", "1800702030", 120, 0, Transition.ColorTint);
    UILayout.SetSameAnchorAndPivot(hintBtn2, UILayout.Bottom);
    GUI.RegisterUIEvent(hintBtn2, UCE.PointerClick, "ActivityCollectUI", "OnHintBtn2Click");

    -- 左侧奖励滚动框
    local giftStr = GUI.LoopScrollRectCreate(
            scrBg,
            "giftStr",
            0,
            45,
            340,
            511,
            "ActivityCollectUI",
            "CreateGiftStr",
            "ActivityCollectUI",
            "RefreshGiftStr",
            0,
            false,
            Vector2.New(317, 100),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    _gt.BindName(giftStr, "giftStr")
    SetAnchorAndPivot(giftStr, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(giftStr, Vector2.New(0, 4))

    -- 右边的大背景
    local scrBg2 = GUI.ImageCreate(mainPage, "scrBg2", "1800400340", 398, 55, false, 730, 565)
    SetAnchorAndPivot(scrBg2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local Roulette = GUI.ImageCreate(mainPage,"Roulette","1800400250",80,0,false,500,500)
    SetAnchorAndPivot(Roulette,UIAnchor.Center,UIAroundPivot.Center)
    _gt.BindName(Roulette, "Roulette")

    -- 创建中间轮盘方法
    ActivityCollectUI.CreateRoulette(200, 0, Roulette)

    local mainRule1 = GUI.CreateStatic(mainPage,"mainRule1", "集齐特定组合可获得好礼", 500, -100, 40, 450, "201")
    UILayout.SetSameAnchorAndPivot(mainRule1, UILayout.Center)
    SetAnchorAndPivot(mainRule1,UIAnchor.Center,UIAroundPivot.Center)
    ActivityCollectUI.SetFont(mainRule1, 26)

    local mainRule2 = GUI.CreateStatic(mainPage,"mainRule1", "集齐所有印章可获得", 460, -100, 40, 390, "201")
    UILayout.SetSameAnchorAndPivot(mainRule2, UILayout.Center)
    SetAnchorAndPivot(mainRule2,UIAnchor.Center,UIAroundPivot.Center)
    ActivityCollectUI.SetFont(mainRule2, 26)

    local mainRule3 = GUI.CreateStatic(mainPage,"mainRule1", "最终大奖", 400, -100, 40, 200, "108")
    UILayout.SetSameAnchorAndPivot(mainRule3, UILayout.Center)
    SetAnchorAndPivot(mainRule3,UIAnchor.Center,UIAroundPivot.Center)
    ActivityCollectUI.SetFont(mainRule3, 40)

    -- 中间的大按钮
    local giveGift = GUI.ButtonCreate(Roulette,"giveGift","1800802020",0,0,Transition.ColorTint,"",185,185,false);
    SetAnchorAndPivot(giveGift,UIAnchor.Center,UIAroundPivot.Center)
    _gt.BindName(giveGift, "giveGift")
    GUI.RegisterUIEvent(giveGift , UCE.PointerClick , "ActivityCollectUI", "GiveGift");

    -- 按钮上文字
    local giveGiftTxt = GUI.CreateStatic(giveGift,"giveGiftTxt","",7,0,130,50,"101");
    ActivityCollectUI.SetFont(giveGiftTxt, 30)
    _gt.BindName(giveGiftTxt, "giveGiftTxt")
    --GUI.ButtonSetDisabledColor(giveGift, UIDefine.GrayColor)
    -- 绑定礼包数据
    GUI.SetData(giveGift, "id", 100)

    -- 抽取印章按钮
    local playBtn = GUI.ButtonCreate(mainPage, "playBtn", "1800102090", -100, -110, Transition.ColorTint, "<color=#ffffff><size=26>抽取印章</size></color>", 170, 55, false);
    SetAnchorAndPivot(playBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.ButtonSetOutLineArgs(playBtn, true, colorOutline, 1)
    GUI.SetIsOutLine(playBtn,true);
    GUI.SetOutLine_Distance(playBtn,1);
    GUI.RegisterUIEvent(playBtn, UCE.PointerClick, "ActivityCollectUI", "OnPlayBtnClick")

    local have = GUI.CreateStatic(playBtn,"have","抽奖券: ",-25, 53, 200, 50,"101");
    ActivityCollectUI.SetFont(have, 24)
    local numTxt = GUI.CreateStatic(have,"numTxt","0",80, 0, 200, 50,"101");
    ActivityCollectUI.SetFont(numTxt, 24)
    _gt.BindName(numTxt, "numTxt")

    -- 赠送好友按钮
    local sendToFriend = GUI.ButtonCreate(mainPage, "sendToFriend", "1800102090", -100, -50, Transition.ColorTint, "<color=#ffffff><size=26>赠送好友</size></color>", 170, 55, false);
    SetAnchorAndPivot(sendToFriend, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.ButtonSetOutLineArgs(sendToFriend, true, colorOutline, 1)
    GUI.SetIsOutLine(sendToFriend,true);
    GUI.SetOutLine_Distance(sendToFriend,1);
    GUI.RegisterUIEvent(sendToFriend, UCE.PointerClick, "ActivityCollectUI", "GiftFriends")
    _gt.BindName(sendToFriend, "sendToFriend")

    local effectRoleRoulette = GUI.ItemCtrlCreate(Roulette,"effectRoleRoulette" ,QualityRes[1], -100, -120, 100,100)
    GUI.ItemCtrlSetElementValue(effectRoleRoulette, eItemIconElement.Border,"1800608290")
    _gt.BindName(effectRoleRoulette, "effectRoleRoulette")
    GUI.SetVisible(effectRoleRoulette, false)
end

-- 初始化数据
function ActivityCollectUI.InitData()
    RewardList = {}
    GetId = nil
    CL.SendNotify(NOTIFY.SubmitForm, "FormCollect", "GetData")
end

function ActivityCollectUI.TaskInitData()
    SelectTaskList = nil
    SelectTaskListGuid = nil
    CL.SendNotify(NOTIFY.SubmitForm, "FormCollect", "Get_Task")
end

function ActivityCollectUI.CreateGiftStr()
    local giftStr = _gt.GetUI("giftStr")
    if giftStr == nil then
        return
    end
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(giftStr)

    local giftItem = GUI.CheckBoxExCreate(giftStr,"giftItem"..curCount,"1800700030","1800700030",0,10,false,270,100)

    -- 第一个头像
    local giftItemIcon1 = GUI.ItemCtrlCreate(giftItem,"giftItemIcon1" ,QualityRes[1], 5,0,100,100)
    GUI.ItemCtrlSetElementValue(giftItemIcon1, eItemIconElement.Border,"1800608290")
    GUI.ItemCtrlSetIconGray(giftItemIcon1,true)
    SetAnchorAndPivot(giftItemIcon1,UIAnchor.Left,UIAroundPivot.Left)

    -- 中间的加号
    local add = GUI.CreateStatic(giftItem,"add","+",100,0,30,30)
    GUI.SetColor(add, UIDefine.BrownColor)
    GUI.StaticSetFontSize(add, UIDefine.FontSizeL)
    SetAnchorAndPivot(add,UIAnchor.Left,UIAroundPivot.Left)

    -- 第二个头像
    local giftItemIcon2 = GUI.ItemCtrlCreate(giftItem,"giftItemIcon2" ,QualityRes[1],105,0,100,100)
    GUI.ItemCtrlSetElementValue(giftItemIcon2, eItemIconElement.Border,"1800608290")
    GUI.ItemCtrlSetIconGray(giftItemIcon2,true)
    SetAnchorAndPivot(giftItemIcon2,UIAnchor.Left,UIAroundPivot.Left)

    -- 等于号
    local equal = GUI.CreateStatic(giftItem,"equal","=",60,0,30,30)
    GUI.SetColor(equal, UIDefine.BrownColor)
    GUI.StaticSetFontSize(equal, UIDefine.FontSizeL)
    SetAnchorAndPivot(equal,UIAnchor.Center,UIAroundPivot.Center)

    -- 第三个奖励icon
    local giftItemIcon3 = GUI.ItemCtrlCreate(giftItem,"giftItemIcon3" ,QualityRes[1],-5,0,100,100)
    GUI.ItemCtrlSetElementValue(giftItemIcon3, eItemIconElement.Border,"1800608290")
    GUI.ItemCtrlSetIconGray(giftItemIcon3,true)
    SetAnchorAndPivot(giftItemIcon3,UIAnchor.Right,UIAroundPivot.Right)
    GUI.ItemCtrlSetElementRect(giftItemIcon3,eItemIconElement.RightBottomNum,5,5,100,25)
    GUI.RegisterUIEvent(giftItemIcon3,UCE.PointerClick,"ActivityCollectUI","GiveGift")

    -- 奖励可领取时的高光
    local giftItemEffect = GUI.SpriteFrameCreate(giftItemIcon3, "giftItemEffect", "", 0, 0, true)
    GUI.SetFrameId(giftItemEffect, "3403700000")
    GUI.SetVisible(giftItemEffect, false)
    UILayout.SetSameAnchorAndPivot(giftItemEffect, UILayout.Center)
    GUI.Play(giftItemEffect)

    -- 已完成图形
    local finish = GUI.ImageCreate(giftItemIcon3,"finish","1800404060",0,0,false,100,40)
    SetAnchorAndPivot(finish,UIAnchor.Center,UIAroundPivot.Center)
    GUI.SetVisible(finish, false)

    return giftItem
end

function ActivityCollectUI.RefreshGiftStr(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    --local UIElement=GUI.GetByGuid(guid)
    local info = RewardList[index]
    local giftItem = GUI.GetByGuid(guid)
    --GUI.SetData(UIElement, "giftItem", tostring(roleIcon[info.name]))
    -- 刷新头像和礼物的icon
    local giftItemIcon1 = GUI.GetChild(giftItem,"giftItemIcon1", false)
    GUI.ItemCtrlSetElementValue(giftItemIcon1, eItemIconElement.Icon,roleIcon[info.Icon][1])
    GUI.ItemCtrlSetIconGray(giftItemIcon1,true)
    GUI.ItemCtrlSetElementValue(giftItemIcon1, eItemIconElement.RightBottomNum, info.IconCount);

    local giftItemIcon2 = GUI.GetChild(giftItem,"giftItemIcon2", false)
    GUI.ItemCtrlSetElementValue(giftItemIcon2, eItemIconElement.Icon,roleIcon[info.Icon2][1])
    GUI.ItemCtrlSetIconGray(giftItemIcon2,true)
    GUI.ItemCtrlSetElementValue(giftItemIcon2, eItemIconElement.RightBottomNum, info.Icon2Count);

    local item = DB.GetOnceItemByKey1(info.ItemId)
    local giftItemIcon3 = GUI.GetChild(giftItem,"giftItemIcon3", false)
    GUI.ItemCtrlSetElementValue(giftItemIcon3, eItemIconElement.Icon,item.Icon)
    GUI.ItemCtrlSetIconGray(giftItemIcon3,true)
    GUI.ItemCtrlSetElementValue(giftItemIcon3, eItemIconElement.RightBottomNum, info.ItemCount);
    GUI.SetData(giftItemIcon3, "id", info.id)
    GUI.SetData(giftItemIcon3, "itemId", info.ItemId)

    local finish = GUI.GetChild(giftItemIcon3, "finish", false)
    GUI.SetData(finish, "type", info.type)

    local flag = false
    local flag2 = false
    if info.IconCount <= Collection[info.Icon].Count then
        GUI.ItemCtrlSetIconGray(giftItemIcon1,false)
        flag = true
    else
        GUI.ItemCtrlSetIconGray(giftItemIcon1,true)
    end
    if info.Icon2Count <= Collection[info.Icon2].Count then
        GUI.ItemCtrlSetIconGray(giftItemIcon2,false)
        flag2 = true
    else
        GUI.ItemCtrlSetIconGray(giftItemIcon2,true)
    end

    -- 当左侧奖励可领取时不变灰，特效显现
    local giftItemEffect = GUI.GetChild(giftItemIcon3, "giftItemEffect", false)
    if flag and flag2 then
        GUI.ItemCtrlSetIconGray(giftItemIcon3,false)
        GUI.SetVisible(giftItemEffect, true)
        GUI.SetData(giftItemIcon3, "isAvailable", "1")
    else
        GUI.ItemCtrlSetIconGray(giftItemIcon3,true)
        GUI.SetVisible(giftItemEffect, false)
        GUI.SetData(giftItemIcon3, "isAvailable", "0")
    end

    -- 如果已经领过了就把已领取显示出来
    if info.type == 1 then
        GUI.SetVisible(finish, true)
        GUI.SetData(finish, "type", 1)
        GUI.ItemCtrlSetIconGray(giftItemIcon3,true)
        GUI.SetData(giftItemIcon3, "isAvailable", "0")
        GUI.SetVisible(giftItemEffect, false)
    else
        GUI.SetVisible(finish, false)
    end
end

function ActivityCollectUI.SetFont(font, size)
    GUI.SetAnchor(font,UIAnchor.Center)
    GUI.SetPivot(font,UIAroundPivot.Center)

    if size ~= nil then
        GUI.StaticSetFontSize(font,size)
    end
    --设置颜色渐变
    GUI.StaticSetIsGradientColor(font,true)
    GUI.StaticSetGradient_ColorTop(font,Color.New(255/255,244/255,139/255,255/255))
    --设置描边
    GUI.SetIsOutLine(font,true)
    GUI.SetOutLine_Distance(font,3)
    GUI.SetOutLine_Color(font,Color.New(182/255,52/255,40/255,255/255))
end

-- valueX : 圆环的x值
-- valueY : 圆环的y值
-- Roulette : 圆环的父类
function ActivityCollectUI.CreateRoulette(valueX, valueY, Roulette)

    if not Collection then
        return
    end

    local a = math.pi / 180;
    local r = 200; -- 圆环半径
    local angle = 360 / 12; -- 根据span的数量来决定弧度大小(要改数量记得改这里，后面的除数对应数量)
    local i = 0
    for k,v in pairs(Collection) do
        i = i + 1
        local x = valueX + math.sin(a * angle * i) * r
        local y = valueY + math.cos(a * angle * i) * r

        local roleRoulette = GUI.ItemCtrlCreate(Roulette,"roleRoulette"..k ,QualityRes[1], x, y, 100,100)
        GUI.ItemCtrlSetElementValue(roleRoulette, eItemIconElement.Icon,roleIcon[k][1])
        _gt.BindName(roleRoulette, "roleRoulette"..k)
        local effect = GUI.ImageCreate(roleRoulette, "effect"..k, "1800300110",0, 0, false, 100, 100)
        GUI.SetVisible(effect, false)
        _gt.BindName(effect, "effect"..k)

        GUI.ItemCtrlSetElementValue(roleRoulette, eItemIconElement.Border,"1800608290")
        GUI.ItemCtrlSetElementValue(roleRoulette, eItemIconElement.RightBottomNum, v.Count);
        --添加灰色阴影
        GUI.ItemCtrlSetIconGray(roleRoulette,true)
        SetAnchorAndPivot(roleRoulette,UIAnchor.Left,UIAroundPivot.Left)
    end

    --ActivityCollectUI.RefreshRoulette("roleRoulette")
end


-- 刷新圆环方法
-- flag == 2 代表他是第二界面的
function ActivityCollectUI.RefreshRoulette(uiName, flags)

    if not Collection then
        return
    end

    if uiName == nil then
        return
    end

    local num = 0
    if flags == 2 then
        num = 1
    end

    -- 如果有一个变灰了，中间的按钮就要变灰
    local flag = false

    for k,v in pairs(Collection) do
        local roleRoulette = _gt.GetUI(tostring(uiName)..k)
        GUI.SetData(roleRoulette, "count", v.Count)
        GUI.ItemCtrlSetElementValue(roleRoulette, eItemIconElement.RightBottomNum, v.Count);

        if v.Count > num then
            GUI.ItemCtrlSetIconGray(roleRoulette,false)
        else
            GUI.ItemCtrlSetIconGray(roleRoulette,true)
            flag = true
        end
    end

    -- 让中间圆环在不能领取时不可用
    --if flag then
    --    GUI.ButtonSetShowDisable(giveGift, false)
    --else
    --    GUI.ButtonSetShowDisable(giveGift, true)
    --end

    local giveGift = _gt.GetUI("giveGift")
    local giveGiftTxt = _gt.GetUI("giveGiftTxt")

    if flags ~= 2 then
        if flag then
            GUI.StaticSetText(giveGiftTxt, "查看奖励")
            GUI.SetData(giveGift, "isAvailable", "0")
        else
            GUI.StaticSetText(giveGiftTxt, "获得奖励")
            GUI.SetData(giveGift, "isAvailable", "1")
        end
    end
end

-- 领奖方法(左边和中间的领奖都是走这里过的)
function ActivityCollectUI.GiveGift(guid)
    local giftItemIcon = GUI.GetByGuid(guid)
    local finish = GUI.GetChild(giftItemIcon, "finish", false)
    -- 获取礼物id
    local giftId = GUI.GetData(giftItemIcon, "id")
    local type = GUI.GetData(finish, "type")
    local isAvailable = GUI.GetData(giftItemIcon, "isAvailable")
    if type == "1" then
        CL.SendNotify(NOTIFY.ShowBBMsg, "已经领过该奖励了")
        return
    end

    -- 0 --> 不可领取 1 --> 可以领取
    if isAvailable == "0" then
        local panelBg = _gt.GetUI("panelBg")
        local itemId = GUI.GetData(giftItemIcon, "itemId")
        local itemTips = Tips.CreateByItemId(itemId, panelBg, "itemTips", 0, 0)
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormCollect", "Get_Reward", tonumber(giftId))
    end
end

-- 抽取印章方法
function ActivityCollectUI.OnPlayBtnClick()

    if timer ~= nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "点击过快！")
        return
    end

    local count = LD.GetItemCountById(GetId, item_container_type.item_container_bag)
    if count == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "您的抽奖券不足！")
        return
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormCollect", "Get_Collection")
end

-- 打开赠送好友页面
function ActivityCollectUI.GiftFriends()
    --GUI.OpenWnd("ActivityCollectGiftFriendUI")
    local wnd = GUI.GetWnd("ActivityCollectUI")
    local GiftFriendsGroup = GUI.GetChild(wnd, "GiftFriendsGroup", false)

    ActivityCollectUI.RegisterMessage()
    ActivityCollectUI.InitFriendData(contact_friend)

    if not GiftFriendsGroup then
        local width = 780
        local height = 584
        local GiftFriendsGroup = GUI.GroupCreate(wnd, "GiftFriendsGroup", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
        _gt.BindName(GiftFriendsGroup, "GiftFriendsGroup")
        local GiftFriendsPanelBg = UILayout.CreateFrame_WndStyle2(GiftFriendsGroup,"赠送好友",  width, height, "ActivityCollectUI", "OnExitGiftFriendsGroup")
        ActivityCollectUI.CreateGiftFriendsPanel(GiftFriendsPanelBg)
    else
        GUI.SetVisible(GiftFriendsGroup, true)
    end
end

function ActivityCollectUI.OpenRefresh()

    if nowPage ~= 1 then
        return
    end

    Collection = ActivityCollectUI.Collection   -- 玩家的印章数量列表
    RewardList = ActivityCollectUI.RewardList   -- 奖励列表
    GetId = ActivityCollectUI.Get_id            -- 奖券id

    local pageName=LabelList[pageNum.mainPage][4]
    local pageBg=_gt.GetUI(pageName)
    if not pageBg then
        pageBg = ActivityCollectUI.CreateMainPage(pageName)
    else
        GUI.SetVisible(pageBg,true)
    end

    local numTxt = _gt.GetUI("numTxt")
    local count = LD.GetItemCountById(GetId, item_container_type.item_container_bag)
    GUI.StaticSetText(numTxt, tostring(count))

    if count <= 0 then
        GUI.StaticSetGradient_ColorTop(numTxt,UIDefine.RedColor)
    else
        ActivityCollectUI.SetFont(numTxt, 24)
    end

    local giftStr = _gt.GetUI("giftStr")
    GUI.LoopScrollRectSetTotalCount(giftStr,#RewardList)
    GUI.LoopScrollRectRefreshCells(giftStr)

    ActivityCollectUI.RefreshRoulette("roleRoulette")

    local wnd = GUI.GetWnd("ActivityCollectUI")
    local GiftFriendsGroup = GUI.GetChild(wnd, "GiftFriendsGroup", false)

    if GiftFriendsGroup then
        ActivityCollectUI.RefreshRoulette("collectHead", 2 )
        local collectHead = GUI.GetByGuid(SelectCollectEffect)
        local effect = GUI.GetChild(collectHead, "effect", false)
        GUI.SetVisible(effect, false)

        local countEdit = _gt.GetUI("countEdit")
        GUI.EditSetTextM(countEdit, "0")
    end

    local giveGift = _gt.GetUI("giveGift")
    GUI.SetData(giveGift, "itemId", RewardList[100].ItemId)
end

-- 抽取后服务器调用该方法
function ActivityCollectUI.GetCollectRefresh()

    local collectionName = ActivityCollectUI.CollectionName
    Collection = ActivityCollectUI.Collection

    local giftStr = _gt.GetUI("giftStr")
    GUI.LoopScrollRectSetTotalCount(giftStr,#RewardList)
    GUI.LoopScrollRectRefreshCells(giftStr)
    GUI.OpenWnd("ActivityCollectRewardUI", collectionName)
end

function ActivityCollectUI.GetCollect(collectionName)
    timer = Timer.New(ActivityCollectUI.TimeFunc, 0.6, 1)
    timer:Start()

    local effectRoleRoulette = _gt.GetUI("effectRoleRoulette")
    GUI.ItemCtrlSetElementValue(effectRoleRoulette, eItemIconElement.Icon,roleIcon[collectionName][1])

    local collect = _gt.GetUI("roleRoulette"..collectionName)

    NowEffect = collectionName

    local tweenMove = TweenData.New()
    tweenMove.Type = GUITweenType.DOLocalMove
    tweenMove.Duration = 0.5
    tweenMove.From = Vector3.New(-50, -50, 0)
    tweenMove.LoopType = UITweenerStyle.Once

    local x = GUI.GetPositionX(collect)
    local y = GUI.GetPositionY(collect)

    tweenMove.To = Vector3.New(x-200, -y, 0)
    GUI.DOTween(effectRoleRoulette, tweenMove, "AttributeChangeTipMove")
    GUI.SetVisible(effectRoleRoulette, true)

    CL.SendNotify(NOTIFY.ShowBBMsg, "您抽到了"..collectionName.."的信物")
end

function ActivityCollectUI.TimeFunc()

    if LastEffect ~= nil then
        local nowEffect = _gt.GetUI("effect"..LastEffect)
        GUI.SetVisible(nowEffect, false)
    end

    local nowEffect = _gt.GetUI("effect"..NowEffect)
    GUI.SetVisible(nowEffect, true)

    LastEffect = NowEffect

    local effectRoleRoulette = _gt.GetUI("effectRoleRoulette")
    GUI.SetVisible(effectRoleRoulette, false)

    ActivityCollectUI.OpenRefresh()

    timer = nil
end

function ActivityCollectUI.OnExit()
    GUI.CloseWnd("ActivityCollectUI")
    ActivityCollectUI.UnRegisterMessage()
end

-----------------------以下是赠送好友页面

function ActivityCollectUI.OnExitGiftFriendsGroup()
    local OnExitGiftFriendsGroup = _gt.GetUI("GiftFriendsGroup")
    GUI.SetVisible(OnExitGiftFriendsGroup, false)
end

function ActivityCollectUI.CreateGiftFriendsPanel(GiftFriendsPanelBg)

    local friendListBg = GUI.ImageCreate(GiftFriendsPanelBg, "contactListBg", "1800400200", 16, 60, false, 312, 512)
    GUI.SetAnchor(friendListBg, UIAnchor.TopLeft)
    GUI.SetPivot(friendListBg, UIAroundPivot.TopLeft)

    local friendList = GUI.LoopScrollRectCreate(
            friendListBg,
            "friendList",
            0,
            7,
            320,
            498,
            "ActivityCollectUI",
            "CreateFriendList",
            "ActivityCollectUI",
            "RefreshFriendList",
            0,
            false,
            Vector2.New(300,110),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top,
            false
    )
    _gt.BindName(friendList,"friendList")
    GUI.SetAnchor(friendList,UIAnchor.Top)
    GUI.SetPivot(friendList,UIAroundPivot.Top)

    GUI.LoopScrollRectSetTotalCount(friendList,#FriendList)
    GUI.LoopScrollRectRefreshCells(friendList)

    local collectListBg = GUI.ImageCreate(GiftFriendsPanelBg, "collectListBg", "1800400200", -20, 60, false, 420, 355)
    GUI.SetAnchor(collectListBg, UIAnchor.TopRight)
    GUI.SetPivot(collectListBg, UIAroundPivot.TopRight)

    -- 创建右边印章的方法
    ActivityCollectUI.CreateCollects(-150, -90, 100, 90, collectListBg)

    local rule = GUI.CreateStatic(collectListBg,"text1", "消耗"..ratio.."个相同印章可送给好友1个抽奖券", 0, 140, 240, 70)
    UILayout.StaticSetFontSizeColorAlignment(rule, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(rule, UILayout.Center)

    local btnBg = GUI.ImageCreate(GiftFriendsPanelBg, "btnBg", "1800400200", -20, -15, false, 420, 150)
    GUI.SetAnchor(btnBg, UIAnchor.BottomRight)
    GUI.SetPivot(btnBg, UIAroundPivot.BottomRight)

    local text1 = GUI.CreateStatic(btnBg,"text1", "赠送数量", 120, 40, 120, 70)
    UILayout.StaticSetFontSizeColorAlignment(text1, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(text1, UILayout.Center)

    local minusBtn = GUI.ButtonCreate(btnBg,"MinusBtn", "1800402140", 226,90, Transition.ColorTint, "")
    _gt.BindName(minusBtn, "MinusBtn")
    local plusBtn = GUI.ButtonCreate(btnBg,"PlusBtn", "1800402150", 50, 90, Transition.ColorTint, "")
    _gt.BindName(plusBtn, "PlusBtn")

    local countEdit = GUI.EditCreate(btnBg,"countEdit", "1800400390", "", 100, 95, Transition.ColorTint, "system", 0, 0, 30, 8, InputType.Standard, ContentType.IntegerNumber)
    _gt.BindName(countEdit, "countEdit")
    GUI.EditSetFontSize(countEdit, UIDefine.FontSizeM)
    GUI.EditSetTextColor(countEdit, UIDefine.BrownColor)
    GUI.EditSetTextM(countEdit, "0")

    GUI.RegisterUIEvent(countEdit, UCE.EndEdit, "ActivityCollectUI", "OnBuyCountModify")
    GUI.RegisterUIEvent(countEdit, UCE.PointerClick, "ActivityCollectUI", "OnPointerClickBuyCountModify")
    GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "ActivityCollectUI", "OnPlusBtnClick")
    GUI.RegisterUIEvent(minusBtn, UCE.PointerClick, "ActivityCollectUI", "OnMinusBtnClick")

    -- 赠送印章按钮
    local sendToFriend = GUI.ButtonCreate(btnBg, "sendCollect", "1800102090", 0, 5, Transition.ColorTint, "<color=#ffffff><size=26>赠送印章</size></color>", 200, 70, false);
    SetAnchorAndPivot(sendToFriend, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ButtonSetOutLineArgs(sendToFriend, true, colorOutline, 1)
    GUI.SetIsOutLine(sendToFriend,true);
    GUI.SetOutLine_Distance(sendToFriend,1);
    GUI.RegisterUIEvent(sendToFriend, UCE.PointerClick, "ActivityCollectUI", "SendCollect")

    --GUI.LoopScrollRectSetTotalCount(friendList,#FriendList)
    --GUI.LoopScrollRectRefreshCells(friendList)
end

function ActivityCollectUI.RegisterMessage()
    CL.UnRegisterMessage(GM.FriendListUpdate, "ActivityCollectUI", "InitFriendData")
    CL.RegisterMessage(GM.FriendListUpdate, "ActivityCollectUI", "InitFriendData")
end

function ActivityCollectUI.UnRegisterMessage()
    CL.UnRegisterMessage(GM.FriendListUpdate, "ActivityCollectUI", "InitFriendData")
end

function ActivityCollectUI.InitFriendData(contactFriend)

    if contact_friend ~= contactFriend then
        return
    end

    FriendList = {}
    local list = LD.GetContactDataListByType(contact_friend)
    if not list then
        return
    end
    for i = 1, list.Count do
        local data = list[i - 1]
        local temp = {
            guid = data.guid,
            contact_type = data.contact_type,
            name = data.name,
            role = data.role,
            roleId = data.sn,
            level = data.level,
            school = data.job,
            friendship = data.friendship,
            last_contact_time = data.last_contact_time,
            status = data.status,
            vip = data.vip,
            reincarnation = data.reincarnation,
        }
        table.insert(FriendList, temp)
    end

    local friendList = _gt.GetUI("friendList")
    if friendList then
        GUI.LoopScrollRectSetTotalCount(friendList,#FriendList)
        GUI.LoopScrollRectRefreshCells(friendList)
    end
end

function ActivityCollectUI.CreateFriendList()
    local friendList = _gt.GetUI("friendList")
    if friendList == nil then
        return
    end
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(friendList)

    -- 背景
    local Friends = GUI.CheckBoxExCreate(friendList,"Friends" .. curCount, "1800800030", "1800800040", 1, 0,  false, 300, 100)
    GUI.CheckBoxExSetCheck(Friends, false)
    GUI.SetAnchor(Friends, UIAnchor.Top)
    GUI.SetPivot(Friends, UIAroundPivot.Top)
    GUI.RegisterUIEvent(Friends, UCE.PointerClick , "ActivityCollectUI", "OnContactItemClick")

    -- iconBg
    local iconBg = GUI.ImageCreate(Friends,"iconBg", "1800201110", 8, 10)
    GUI.SetAnchor(iconBg, UIAnchor.TopLeft)
    GUI.SetPivot(iconBg, UIAroundPivot.TopLeft)

    -- icon
    local icon = GUI.ImageCreate(iconBg,"icon", "1900000000", 0, 0,  false, 76, 76, false)
    GUI.SetAnchor(icon, UIAnchor.Center)
    GUI.SetPivot(icon, UIAroundPivot.Center)
    GUI.AddRedPoint(icon,UIAnchor.TopLeft,0,0,"1800208080")
    GUI.SetRedPointVisable(icon, false)

    -- 玩家等级
    local level = GUI.CreateStatic(iconBg,"level", "120", -6, -1,  50, 25)
    GUI.SetAnchor(level, UIAnchor.BottomRight)
    GUI.SetPivot(level, UIAroundPivot.BottomRight)
    GUI.StaticSetFontSize(level, fontSizeSmaller)
    GUI.StaticSetAlignment(level,TextAnchor.MiddleRight)
    GUI.SetColor(level, colorWhite)
    GUI.SetIsOutLine(level, true)
    GUI.SetOutLine_Color(level, Color.New(0/255,0/255,0/255,255/255))
    GUI.SetOutLine_Distance(level, 1)

    -- 玩家名字
    local RoleName = GUI.CreateStatic(Friends,"RoleName", "玩家有六个字", 138, 18,  150, 26, "system", false, false)
    GUI.SetAnchor(RoleName, UIAnchor.TopLeft)
    GUI.SetPivot(RoleName, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(RoleName, fontSizeBigger)
    GUI.StaticSetAlignment(RoleName,TextAnchor.MiddleLeft)
    GUI.SetColor(RoleName, colorDark)
    GUI.StaticSetFontSizeBestFit(RoleName)

    -- 门派标签
    local schoolMark = GUI.ImageCreate(Friends,"schoolMark", "1800400200", 98, 18)
    GUI.SetAnchor(schoolMark, UIAnchor.TopLeft)
    GUI.SetPivot(schoolMark, UIAroundPivot.TopLeft)

    -- ID
    local idText = GUI.CreateStatic(Friends,"idText", "ID：7777777", 110, 63,  150, 30,"system",true)
    GUI.SetAnchor(idText, UIAnchor.TopLeft)
    GUI.SetPivot(idText, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(idText, fontSizeDefault)
    GUI.SetColor(idText, colorDark)

    return Friends
end

function ActivityCollectUI.RefreshFriendList(parameter)
    parameter = string.split(parameter , "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if not item then
        return
    end

    local icon = GUI.GetChild(item,"icon")
    local level = GUI.GetChild(item,"level")
    local RoleName = GUI.GetChild(item,"RoleName")
    local schoolMark = GUI.GetChild(item,"schoolMark")
    local idText = GUI.GetChild(item,"idText")
    local temp = FriendList[index]
    if temp then
        local role = DB.GetRole(tonumber(temp.role))
        GUI.ImageSetImageID(icon, tostring(role.Head))
        GUI.StaticSetText(level,temp.level)
        GUI.StaticSetText(RoleName,temp.name)

        if SelectCheckBoxRole ~= temp.name then
            GUI.CheckBoxExSetCheck(item, false)
        else
            GUI.CheckBoxExSetCheck(item, true)
        end

        local school = DB.GetSchool(tonumber(temp.school))
        GUI.ImageSetImageID(schoolMark, tostring(school.Icon))
        GUI.StaticSetText(idText,"ID:"..temp.roleId+1000000)

        GUI.SetData(item, "guid", temp.guid)
    end
end

-- x : x 坐标； y : y坐标
-- w : 左右间距； h : 上下间距
-- collectListBg : 父类
function ActivityCollectUI.CreateCollects(x, y, w, h, collectListBg)
    if Collection then
        local i = 1
        local j = 1
        for k,v in pairs(Collection) do
            local collectHead = GUI.ItemCtrlCreate(collectListBg,"collectHead"..k ,QualityRes[1], x + (i-1) * w,y + j * h,100,100)
            -- 选中印章的特效
            local effect = GUI.ImageCreate(collectHead, "effect", "1800300110",0, 0, false, 100, 100)
            GUI.SetVisible(effect, false)
            GUI.ItemCtrlSetElementValue(collectHead, eItemIconElement.Icon,roleIcon[k][1])
            GUI.ItemCtrlSetElementValue(collectHead, eItemIconElement.Border,"1800608290")
            GUI.ItemCtrlSetElementValue(collectHead, eItemIconElement.RightBottomNum, v.Count);
            GUI.ItemCtrlSetElementRect(collectHead,eItemIconElement.RightBottomNum,5,5,100,25)
            GUI.ItemCtrlSetIconGray(collectHead,true)
            _gt.BindName(collectHead, "collectHead"..k)
            SetAnchorAndPivot(collectHead,UIAnchor.Top,UIAroundPivot.Top)
            GUI.RegisterUIEvent(collectHead,UCE.PointerClick,"ActivityCollectUI","SelectCollect")

            GUI.SetData(collectHead, "count", v.Count)
            GUI.SetData(collectHead, "collect", k)
            j = j + 1
            if j % 4 == 0 then
                i = i + 1
                j = 1
            end
        end
    end

    ActivityCollectUI.RefreshRoulette("collectHead", 2)
end

-- 好友列表被点击
function ActivityCollectUI.OnContactItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local RoleName = GUI.GetChild(item, "RoleName", false)
    local name = GUI.StaticGetText(RoleName)
    if SelectCheckBoxRole ~= name then
        GUI.CheckBoxExSetCheck(item, true)
        local OldItem = GUI.GetByGuid(SelectCheckBoxRoleGuid)
        GUI.CheckBoxExSetCheck(OldItem, false)
        SelectCheckBoxRole = name
        SelectCheckBoxRoleGuid = guid
    else
        GUI.CheckBoxExSetCheck(item, true)
    end
end

-- 印章被点击
function ActivityCollectUI.SelectCollect(guid)
    local collectHead = GUI.GetByGuid(guid)
    if collectHead then

        local count = tonumber(GUI.GetData(collectHead, "count"))
        if count < ratio then
            CL.SendNotify(NOTIFY.ShowBBMsg, "请选择数量足够的印章")
            return
        end

        local effect = GUI.GetChild(collectHead, "effect", false)
        if SelectCollectEffect == nil then
            SelectCollectEffect = guid
        else
            local OldCollectHead = GUI.GetByGuid(SelectCollectEffect)
            local OldEffect = GUI.GetChild(OldCollectHead, "effect", false)
            GUI.SetVisible(OldEffect, false)
            SelectCollectEffect = guid
        end
        local countEdit = _gt.GetUI("countEdit")
        GUI.EditSetTextM(countEdit, "0")
        GUI.SetVisible(effect, true)
    end
end

function ActivityCollectUI.SendCollect()
    if SelectCheckBoxRole == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中一个好友")
        return
    end

    if SelectCollectEffect == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请选择要赠送的印章")
        return
    end

    local friends = GUI.GetByGuid(SelectCheckBoxRoleGuid)
    local guid = GUI.GetData(friends, "guid")
    local collect = GUI.GetByGuid(SelectCollectEffect)
    local collectName = GUI.GetData(collect, "collect")
    local countEdit = _gt.GetUI("countEdit")
    local num = tonumber(GUI.EditGetTextM(countEdit))
    local count = tonumber(GUI.GetData(collect, "count"))
    count = count - (count % ratio)


    if num <= 0 or num > count or count < ratio or count % ratio ~= 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "赠送的数量有误")
        return
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormCollect", "Give_Friend", guid, collectName, num/2)
end

function ActivityCollectUI.OnBuyCountModify()
    local countEdit = _gt.GetUI("countEdit")
    if SelectCollectEffect == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选择一个你想赠送的印章")
        return
    end

    -- 获取玩家拥有的印章数量
    local collect = GUI.GetByGuid(SelectCollectEffect)
    local count = tonumber(GUI.GetData(collect, "count"))

    if count == nil or count == 0 then
        count = 99
    end

    if count % ratio ~= 0 then
        count = count - (count % ratio)
    end

    if countEdit ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt) or 1
        if num < 1 then num = 0 end
        if num > count then num = count end
        if num % ratio ~= 0 then
            num = num - (num % ratio)
        end
        GUI.EditSetTextM(countEdit, tostring(num))
    end
end

function ActivityCollectUI.OnPointerClickBuyCountModify()
    local countEdit = _gt.GetUI("countEdit")
    if countEdit ~= nil then
        GUI.EditSetTextM(countEdit, "")
    end
end

function ActivityCollectUI.OnPlusBtnClick()
    ActivityCollectUI.OnChangeBuyItemNum(ratio)
end

function ActivityCollectUI.OnMinusBtnClick()
    ActivityCollectUI.OnChangeBuyItemNum(-ratio)
end

function ActivityCollectUI.OnChangeBuyItemNum(deltaNum)
    local countEdit = _gt.GetUI("countEdit")
    if countEdit ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt) + deltaNum

        if SelectCollectEffect == nil then
            CL.SendNotify(NOTIFY.ShowBBMsg, "请先选择一个你想赠送的印章")
            return
        end

        local collect = GUI.GetByGuid(SelectCollectEffect)
        local count = tonumber(GUI.GetData(collect, "count"))

        if count == nil then
            count = 99
        end

        if num < 1 then
            num = 0
            CL.SendNotify(NOTIFY.ShowBBMsg, "已达下限")
        end
        if num > count then
            num = count - (count % ratio)
            CL.SendNotify(NOTIFY.ShowBBMsg, "已达上限")
        end
        GUI.EditSetTextM(countEdit, tostring(num))
    end
end

-----------------------以下是任务页面
function ActivityCollectUI.CreateActivityPage(pageName)
    local panelBg = _gt.GetUI("panelBg")
    local activityPage = GUI.GroupCreate(panelBg, pageName,0,0,1197,639)
    _gt.BindName(activityPage, pageName)

    local scrBg = GUI.ImageCreate(activityPage, "scrBg", "1800400010", 65, 60, false, 700, 480)
    SetAnchorAndPivot(scrBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 左侧任务滚动框
    local taskStr = GUI.LoopScrollRectCreate(
            scrBg,
            "taskStr",
            0,
            10,
            700,
            460,
            "ActivityCollectUI",
            "CreateTaskStr",
            "ActivityCollectUI",
            "RefreshTaskStr",
            0,
            false,
            Vector2.New(685, 100),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    _gt.BindName(taskStr, "taskStr")
    SetAnchorAndPivot(taskStr, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(taskStr, Vector2.New(0, 4))

    -- 右侧详细信息背景
    local infoBg = GUI.ImageCreate(activityPage, "infoBg", "1800400010", -75, 60, false, 350, 480)
    SetAnchorAndPivot(infoBg, UIAnchor.TopRight, UIAroundPivot.TopRight)
    _gt.BindName(infoBg, "infoBg")

    local titleBg = GUI.ImageCreate(infoBg, "titleBg", "1800001030", 0, 15, false, 240, 39);
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top);

    local taskTitle = GUI.CreateStatic(titleBg, "taskTitle", "任务标题", 0, 1, 200, 30);
    GUI.SetColor(taskTitle, UIDefine.WhiteColor);
    GUI.StaticSetFontSize(taskTitle, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(taskTitle, TextAnchor.MiddleCenter);
    UILayout.SetSameAnchorAndPivot(taskTitle, UILayout.Center);

    local split1 = GUI.ImageCreate(infoBg, "split1", "1801401070", 0, 65, false, 315, 4);
    UILayout.SetSameAnchorAndPivot(split1, UILayout.Top);

    local text1 = GUI.CreateStatic(infoBg, "text1", "任务奖励", 0, 75, 150, 30);
    GUI.SetColor(text1, UIDefine.BrownColor);
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter);
    UILayout.SetSameAnchorAndPivot(text1, UILayout.TopLeft);

    -- 任务奖励
    local rewardStr = GUI.LoopScrollRectCreate(
            infoBg,
            "rewardStr",
            -30,
            120,
            270,
            100,
            "ActivityCollectUI",
            "CreateRewardStr",
            "ActivityCollectUI",
            "RefreshRewardStr",
            0,
            true,
            Vector2.New(76, 76),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft
    )
    _gt.BindName(rewardStr, "rewardStr")
    SetAnchorAndPivot(rewardStr, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(rewardStr, Vector2.New(4, 0))

    local split2 = GUI.ImageCreate(infoBg, "split2", "1801401070", 0, 210, false, 315, 4);
    UILayout.SetSameAnchorAndPivot(split2, UILayout.Top);

    local text2 = GUI.CreateStatic(infoBg, "text2", "任务描述", 0, 220, 150, 30);
    GUI.SetColor(text2, UIDefine.BrownColor);
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(text2, TextAnchor.MiddleCenter);
    UILayout.SetSameAnchorAndPivot(text2, UILayout.TopLeft);

    local taskDesc = GUI.CreateStatic(infoBg, "taskDesc", "任务描述", 0, 260, 300, 140);
    GUI.SetColor(taskDesc, UIDefine.Yellow2Color);
    GUI.StaticSetFontSize(taskDesc, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(taskDesc, TextAnchor.UpperLeft);
    UILayout.SetSameAnchorAndPivot(taskDesc, UILayout.Top);
    _gt.BindName(taskDesc, "taskDesc")

    --local spendWord = GUI.CreateStatic(infoBg, "spendWord", "刷新需花费", 0, -55, 200, 30)
    --GUI.SetColor(spendWord, UIDefine.Yellow2Color)
    --GUI.StaticSetFontSize(spendWord, UIDefine.FontSizeS)
    --GUI.StaticSetAlignment(spendWord, TextAnchor.UpperLeft);
    --UILayout.SetSameAnchorAndPivot(spendWord, UILayout.Bottom);
    --
    --local spendIcon = GUI.ImageCreate(spendWord,"spendIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold], 24, 2, false, 30, 30)
    --SetAnchorAndPivot(spendIcon, UIAnchor.Bottom, UIAroundPivot.Bottom)
    --_gt.BindName(spendIcon, "spendIcon")
    --
    --local spendGold = GUI.CreateStatic(spendWord, "spendGold", "0", 140, 0, 200, 30)
    --GUI.SetColor(spendGold, UIDefine.Yellow2Color)
    --GUI.StaticSetFontSize(spendGold, UIDefine.FontSizeS)
    --GUI.StaticSetAlignment(spendGold, TextAnchor.UpperLeft);
    --UILayout.SetSameAnchorAndPivot(spendGold, UILayout.Bottom);

    -- 刷新品级按钮
    local refreshRank = GUI.ButtonCreate(infoBg, "refreshRank", "1800102090", 0, -10, Transition.ColorTint, "<color=#ffffff><size=26>刷新品级</size></color>", 170, 55, false);
    SetAnchorAndPivot(refreshRank, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.SetIsOutLine(refreshRank,true);
    GUI.ButtonSetOutLineArgs(refreshRank, true, colorOutline, 1)
    GUI.SetOutLine_Distance(refreshRank,1);
    GUI.RegisterUIEvent(refreshRank, UCE.PointerClick, "ActivityCollectUI", "RefreshRankF")
    _gt.BindName(refreshRank, "refreshRank")
    GUI.SetVisible(refreshRank, false)

    local hintBtn = GUI.ButtonCreate(refreshRank, "hintBtn", "1800702030", 120, 0, Transition.ColorTint);
    UILayout.SetSameAnchorAndPivot(hintBtn, UILayout.Bottom);
    GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "ActivityCollectUI", "OnHintBtnClick");

    -- 领取任务按钮
    local receiveTask = GUI.ButtonCreate(activityPage, "receiveTask", "1800102090", -100, -30, Transition.ColorTint, "<color=#ffffff><size=26>领取任务</size></color>", 170, 55, false);
    SetAnchorAndPivot(receiveTask, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.ButtonSetOutLineArgs(receiveTask, true, colorOutline, 1)
    GUI.SetIsOutLine(receiveTask,true);
    GUI.SetOutLine_Distance(receiveTask,1);
    GUI.RegisterUIEvent(receiveTask, UCE.PointerClick, "ActivityCollectUI", "ReceiveTask")
    _gt.BindName(receiveTask, "receiveTask")

    local wordTxt = GUI.CreateStatic(activityPage,"wordTxt","今日还可领取次数       次",100, -40, 300, 50,"101");
    ActivityCollectUI.SetFont(wordTxt, 24)
    SetAnchorAndPivot(wordTxt, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    _gt.BindName(wordTxt, "wordTxt")
end

--TaskList -v
--HandItemId 上交物品的id--服务器用
--ItemId 奖励列表的id--服务器用
--NPC NPC的id--服务器用
--Rank 品质--决定左边的D - S
--ShowInfo 详细信息--右边的详细信息
--ShowName 任务名--任务名
--State 状态--0 - 已完成 1 - 未接取 2 - 已领取
--Type 任务类型--和TaskPic决定左边图标
--id 任务id--服务器用

-- 服务器调用刷新方法
function ActivityCollectUI.TaskRefresh()

    TaskList = ActivityCollectUI.TaskList                 -- 任务主要数据列表
    TaskPic = ActivityCollectUI.TaskPic                   -- 任务图标
    FinishTaskCount = ActivityCollectUI.FinishTaskCount   -- 已接取任务数量
    DayCanFinishMax = ActivityCollectUI.DayCanFinishMax   -- 每日最大完成数量
    TaskRefreshGold = ActivityCollectUI.TaskRefreshGold   -- 刷新任务品级需要的银币
    TicketGetNum = ActivityCollectUI.TicketGetNum         -- 任务道具偏差

    if TaskRefreshGold == nil then
        TaskRefreshGold = 0
    end

    if TaskList == nil or TaskPic == nil then
        test("未能获取数据")
        return
    end

    table.sort(TaskList, ActivityCollectUI.Sort)

    local pageName = LabelList[pageNum.activityPage][4]
    local pageBg = _gt.GetUI(pageName)
    if not pageBg then
        pageBg = ActivityCollectUI.CreateActivityPage(pageName)
    else
        GUI.SetVisible(pageBg,true)
    end

    local taskStr = _gt.GetUI("taskStr")

    GUI.LoopScrollRectSetTotalCount(taskStr, #TaskList)
    GUI.LoopScrollRectRefreshCells(taskStr)

    local wordTxt = _gt.GetUI("wordTxt")
    GUI.StaticSetText(wordTxt, "今日接取  ".. FinishTaskCount .. " / " .. DayCanFinishMax .. "  次")

    if SelectTaskList ~= nil then
        ActivityCollectUI.RefreshInfo(SelectTaskListGuid)
        --ActivityCollectUI.OnTaskClick(SelectTaskListGuid)
    end

end

-- 排序
function ActivityCollectUI.Sort(a,b)
    local pri1 = a.State
    local pri2 = b.State
    if pri1 == pri2 then
        return a.id > b.id
    end
    return pri1 > pri2
end

function ActivityCollectUI.CreateTaskStr()
    local taskStr = _gt.GetUI("taskStr")
    if taskStr == nil then
        return
    end
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(taskStr)

    local taskItem = GUI.CheckBoxExCreate(taskStr,"taskItem"..curCount,"1800400360","1800400361",0,0,false,690,100)
    GUI.SetAnchor(taskItem, UIAnchor.TopLeft)
    GUI.SetPivot(taskItem, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(taskItem, UCE.PointerClick , "ActivityCollectUI", "OnTaskClick")
    _gt.BindName(taskItem, "taskItem"..curCount)

    -- iconBg
    local taskIconBg = GUI.ImageCreate(taskItem, "taskIconBg", "1800201110", 8, 8)
    GUI.SetAnchor(taskIconBg, UIAnchor.TopLeft)
    GUI.SetPivot(taskIconBg, UIAroundPivot.TopLeft)

    local pic3 = GUI.ImageCreate(taskIconBg,"pic3","1801401190",250,-10,false,350,100)
    local taskTextBorder = GUI.ImageCreate(taskIconBg,"taskTextBorder","1801401140",-10,-10,false,350,105)
    local pic2 = GUI.ImageCreate(taskTextBorder,"pic2","1800600340",120,30,false,180,50)

    -- icon
    local taskIcon = GUI.ImageCreate(taskIconBg,"taskIcon", "1801109130", 0, 0,  false, 76, 76, false)
    GUI.SetAnchor(taskIcon, UIAnchor.Center)
    GUI.SetPivot(taskIcon, UIAroundPivot.Center)

    -- 竖线
    local line = GUI.ImageCreate(taskItem, "line", "1801601080", 100, 2, false, 2, 96, false)

    -- 任务品级
    local taskLevel = GUI.ImageCreate(taskItem, "taskLevel", "1801407120", 30, 0, false, 76, 76, false)
    GUI.SetAnchor(taskLevel, UIAnchor.Center)
    GUI.SetPivot(taskLevel, UIAroundPivot.Center)

    -- 任务名字
    local taskText = GUI.CreateStatic(taskItem,"taskText","",-40, 0, 300, 50,"101");
    ActivityCollectUI.SetFont(taskText, 20)
    SetAnchorAndPivot(taskText, UIAnchor.Center, UIAroundPivot.Center)

    local taskState = GUI.ImageCreate(taskItem, "taskState", "", -20, 0, false, 150, 84, false)
    GUI.SetAnchor(taskState, UIAnchor.Right)
    GUI.SetPivot(taskState, UIAroundPivot.Right)

    return taskItem
end

function ActivityCollectUI.RefreshTaskStr(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local info = TaskList[index]
    --local UIElement=GUI.GetByGuid(guid)
    local taskItem = GUI.GetByGuid(guid)
    GUI.SetData(taskItem, "id", info.id)
    GUI.SetData(taskItem, "num", index)

    local taskIconBg = GUI.GetChild(taskItem, "taskIconBg", false)
    local taskIcon = GUI.GetChild(taskIconBg, "taskIcon", false)
    local taskText = GUI.GetChild(taskItem, "taskText", false)
    local taskLevel = GUI.GetChild(taskItem, "taskLevel", false)
    local taskState = GUI.GetChild(taskItem, "taskState", false)
    local taskTextBorder = GUI.GetChild(taskIconBg, "taskTextBorder", false)

    GUI.CheckBoxExSetCheck(taskItem, false)

    if SelectTaskList == nil or SelectTaskListGuid == nil then
        SelectTaskList = TaskList[1].id
        SelectTaskListGuid = guid
        ActivityCollectUI.RefreshInfo(guid)
    --elseif tostring(SelectTaskList) == tostring(info.id) then
        --ActivityCollectUI.RefreshInfo(SelectTaskListGuid)
    end

    if tostring(SelectTaskList) == tostring(info.id) then
        GUI.CheckBoxExSetCheck(taskItem, true)
    end

    GUI.ImageSetImageID(taskIcon, TaskPic[info.Type])        -- 设置任务图片
    GUI.StaticSetText(taskText, info.ShowName)               -- 设置任务名字
    GUI.ImageSetImageID(taskLevel, level[info.Rank][1])      -- 设置任务品质等级
    GUI.ImageSetImageID(taskTextBorder, level[info.Rank][2]) -- 任务底板

    if info.State == 1 then
        GUI.SetVisible(taskState, false)
    else
        GUI.SetVisible(taskState, true)
        GUI.ImageSetImageID(taskState, TaskState[info.State]) -- 设置任务状态
    end
end

function ActivityCollectUI.OnTaskClick(guid)
    local item = GUI.GetByGuid(guid)
    local id = GUI.GetData(item, "id")

    if SelectTaskList ~= id and SelectTaskListGuid ~= tostring(guid) then

        if id == "" or id == nil then
            id = TaskList[1].id
        end

        GUI.CheckBoxExSetCheck(item, true)
        local OldItem = GUI.GetByGuid(SelectTaskListGuid)
        GUI.CheckBoxExSetCheck(OldItem, false)
        SelectTaskList = id
        SelectTaskListGuid = tostring(guid)
        ActivityCollectUI.RefreshInfo(guid)
    else
        GUI.CheckBoxExSetCheck(item, true)
    end
end

function ActivityCollectUI.CreateRewardStr()
    local rewardStr = _gt.GetUI("rewardStr")
    if rewardStr == nil then
        return
    end
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(rewardStr)
    -- iconBg
    local rewardIconBg = GUI.ImageCreate(rewardStr, "taskIconBg"..curCount, "1800201110", 0, 0)
    GUI.SetAnchor(rewardIconBg, UIAnchor.TopLeft)
    GUI.SetPivot(rewardIconBg, UIAroundPivot.TopLeft)

    -- icon
    local rewardIcon = ItemIcon.Create(rewardIconBg,"rewardIcon", 0, 0)
    UILayout.SetSameAnchorAndPivot(rewardIcon, UILayout.Top);
    _gt.BindName(rewardIcon, "rewardIcon")
    GUI.RegisterUIEvent(rewardIcon, UCE.PointerClick, "ActivityCollectUI", "OnRewardIconClick");

    return rewardIconBg
end

function ActivityCollectUI.RefreshRewardStr(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local info = ActivityReword[index]

    local rewardIconBg = GUI.GetByGuid(guid)
    local rewardIcon = GUI.GetChild(rewardIconBg, "rewardIcon")
    GUI.SetData(rewardIcon, "info", info)
    ItemIcon.BindItemId(rewardIcon, info)

    if info == GetId then
        local taskItem = GUI.GetByGuid(SelectTaskListGuid)
        local num = GUI.GetData(taskItem, "num")
        local info = TaskList[tonumber(num)]
        local rank = tonumber(info.Rank)
        local min = rank + TicketGetNum[1]
        local max = rank + TicketGetNum[2]

        if min <= 0 then
            min = 1
        end

        GUI.ItemCtrlSetElementValue(rewardIcon, eItemIconElement.RightBottomNum, tostring(min).."~"..tostring(max));
    end
end

function ActivityCollectUI.OnRewardIconClick(guid)
    local rewardIcon = GUI.GetByGuid(guid)
    local info = GUI.GetData(rewardIcon, "info")
    local infoBg = _gt.GetUI("infoBg")

    -- 显示奖励tips
    local itemTips = Tips.CreateByItemId(info, infoBg, "itemTips", 0, 0)
end

function ActivityCollectUI.RefreshInfo(guid)
    local infoBg = _gt.GetUI("infoBg")
    local taskItem = GUI.GetByGuid(guid)
    local num = GUI.GetData(taskItem, "num")
    local info = TaskList[tonumber(num)]
    local taskTitle = GUI.GetChild(infoBg, "taskTitle")
    local rewardStr = GUI.GetChild(infoBg, "rewardStr", false)
    local taskDesc = GUI.GetChild(infoBg, "taskDesc", false)
    local receiveTask = _gt.GetUI("receiveTask")
    local refreshRank = GUI.GetChild(infoBg, "refreshRank", false)

    GUI.ScrollRectSetNormalizedPosition(rewardStr, Vector2.New(0))

    -- 设置标题
    GUI.StaticSetText(taskTitle, info.ShowName)
    -- 设置任务描述
    GUI.StaticSetText(taskDesc, info.ShowInfo)

    ActivityReword = info.ItemId
    GUI.LoopScrollRectSetTotalCount(rewardStr, #ActivityReword)
    GUI.LoopScrollRectRefreshCells(rewardStr)

    GUI.SetVisible(receiveTask, true)
    if info.State == 1 then
        GUI.ButtonSetText(receiveTask, "<color=#ffffff><size=26>领取任务</size></color>")
        GUI.SetVisible(refreshRank, true)
    elseif info.State == 2 then
        GUI.ButtonSetText(receiveTask, "<color=#ffffff><size=26>前往任务</size></color>")
        GUI.SetVisible(refreshRank, false)
    elseif info.State == 0 then
        GUI.SetVisible(receiveTask, false)
        GUI.SetVisible(refreshRank, false)
    end
end

-- 领取任务方法
function ActivityCollectUI.ReceiveTask()
    CL.SendNotify(NOTIFY.SubmitForm, "FormCollect", "GoTo_Task", tonumber(SelectTaskList))
end

-- 跳转到对应NPC
function ActivityCollectUI.FindNpc(mapId, X, Y, NPCId)
    GUI.CloseWnd('BagUI')
    GetWay.Def[3].jump(mapId, X, Y)
    CL.SetMoveEndAction(MoveEndAction.SelectNpc, NPCId)
    ActivityCollectUI.OnExit()
end

function ActivityCollectUI.RefreshRankF()
    if TaskRefreshGold <= 0 then
        ActivityCollectUI.RefreshRank()
    else
        local str = "本次刷新需要消耗 ".. tostring(TaskRefreshGold) .. " 银币，确认要刷新吗？"
        GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", str, "ActivityCollectUI", "确认", "RefreshRank", "取消")
    end

end

function ActivityCollectUI.RefreshRank()
    if SelectTaskList ~= nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormCollect", "ReTaskRank", tonumber(SelectTaskList))
    end
end

function ActivityCollectUI.OnHintBtnClick()
    local infoBg = _gt.GetUI("infoBg");
    Tips.CreateHint("在S ~ D之间重新生成任务品级，每天前3次刷新不需要消耗银币。",infoBg,0,345,UILayout.Top,330)
end

function ActivityCollectUI.OnHintBtn2Click()
    local scrBg = _gt.GetUI("scrBg")
    Tips.CreateHint("收集对应组合可获得奖励，奖励只能领取一次且不会消耗印章", scrBg, 0, 40, UILayout.Top, 300)
end