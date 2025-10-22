local WelDailyOnLineUI = {
    -- State_1 = 0,
    -- State_2 = 0,
    -- State_3 = 0,
    -- State_4 = 0,
    -- State_5 = 0,
    -- State_6 = 0,
    TodayOnlineSec = 0,
    ---@type WelDailyOnLineConfig[]
    Config = nil,
    updateTime = nil,
    isOpen = false
}
local test = function()
end
_G.WelDailyOnLineUI = WelDailyOnLineUI

local guidt = UILayout.NewGUIDUtilTable()
function WelDailyOnLineUI.InitData()
    if WelDailyOnLineUI.updateTime then
        WelDailyOnLineUI.updateTime:Stop()
        WelDailyOnLineUI.updateTime = nil
    end
    return {
        ---@type WelDailyOnLineConfig[]
        Config = {},
        TodayOnlineSec = 0,
        ClientSec = 0
    }
end

local data = WelDailyOnLineUI.InitData()
function WelDailyOnLineUI.OnExitGame()
    data = WelDailyOnLineUI.InitData()
    WelDailyOnLineUI.isOpen = false
end
function WelDailyOnLineUI.OnShow(WelfareUIGuidt)
    local wnd = GUI.GetWnd("WelfareUI")
    if wnd == nil then
        return
    end
    WelDailyOnLineUI.isOpen = true
    local rewardBg = WelfareUIGuidt.GetUI("rewardBg")
    GUI.SetVisible(rewardBg, true)
    GUI.SetPositionX(rewardBg, 285)
    GUI.SetPositionY(rewardBg, 194)
    GUI.SetWidth(rewardBg, 838)
    GUI.SetHeight(rewardBg, 415)
    WelDailyOnLineUI.GetData()
end
function WelDailyOnLineUI.CreateSubPage(subBg)
    guidt = UILayout.NewGUIDUtilTable()
    guidt.BindName(subBg, "subBg")
    local titleBg = GUI.ImageCreate(subBg, "titleBg", "1800600470", 103, -209, false, 828, 124)
    local txt = GUI.CreateStatic(titleBg, "txt", " ", 0, 47, 240, 35)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    guidt.BindName(txt, "txt")
    local src =
        GUI.LoopScrollRectCreate(
        subBg,
        "src",
        103,
        77,
        810,
        383,
        "WelDailyOnLineUI",
        "CreateItem",
        "WelDailyOnLineUI",
        "RefreshItem",
        0,
        false,
        Vector2.New(810, 128),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    UILayout.SetSameAnchorAndPivot(src, UILayout.Center)
    GUI.ScrollRectSetChildSpacing(src, Vector2.New(0, 8))
    guidt.BindName(src, "src")
end
function WelDailyOnLineUI.CreateItem()
    local src = guidt.GetUI("src")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(src)
    local item = GUI.ImageCreate(src, "item" .. curCount, "1801100010", 0, 0, false)
    GUI.SetIsRaycastTarget(item, true)
    local dailyOnLineKeyName = GUI.CreateStatic(item, "dailyOnLineKeyName", curCount, 47, 0, 240, 35)
    GUI.SetColor(dailyOnLineKeyName, UIDefine.BrownColor)
    GUI.StaticSetFontSize(dailyOnLineKeyName, UIDefine.FontSizeM)
    UILayout.SetSameAnchorAndPivot(dailyOnLineKeyName, UILayout.Left)
    GUI.StaticSetAlignment(dailyOnLineKeyName, TextAnchor.MiddleLeft)
    local onLineBtn =
        GUI.ButtonCreate(item, "onLineBtn", "1800402110", -20, 0, Transition.ColorTint, "领取", 120, 45, false)

    GUI.RegisterUIEvent(onLineBtn, UCE.PointerClick, "WelDailyOnLineUI", "OnGetClick")
    UILayout.SetSameAnchorAndPivot(onLineBtn, UILayout.Right)
    GUI.ButtonSetTextFontSize(onLineBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(onLineBtn, UIDefine.BrownColor)
    local itemSrc =
        GUI.LoopScrollRectCreate(
        item,
        "itemSrc",
        203,
        0,
        450,
        86,
        "WelDailyOnLineUI",
        "CreateItemIcon",
        "WelDailyOnLineUI",
        "RefreshItemIcon",
        0,
        true,
        Vector2.New(86, 86),
        1,
        UIAroundPivot.Left,
        UIAnchor.Left
    )
    UILayout.SetSameAnchorAndPivot(itemSrc, UILayout.Left)
    GUI.ScrollRectSetChildSpacing(itemSrc, Vector2.New(3, 0))
    GUI.SetLinkScrollRect(itemSrc, src)
    return item
end

function WelDailyOnLineUI.RefreshItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local item = GUI.GetByGuid(guid)
    local onLineBtn = GUI.GetChild(item, "onLineBtn", false)
    GUI.ButtonSetIndex(onLineBtn, index)
    index = index + 1
    local src = GUI.GetChild(item, "itemSrc", false)
    local keyname = GUI.GetChild(item, "dailyOnLineKeyName", false)
    GUI.StaticSetText(keyname, "在线" .. UIDefine.LeftTimeFormatEx(data.Config[index].Second + CL.GetServerTickCount()))
    local redPoint = false
    if data.Config[index].isGet then
        GUI.ButtonSetText(onLineBtn, "已领取")
        GUI.ButtonSetShowDisable(onLineBtn, false)
        GUI.ImageSetImageID(item, "1801100012")
    else
        if data.TodayOnlineSec >= data.Config[index].Second then
            GUI.ButtonSetText(onLineBtn, "领取")
            GUI.ButtonSetShowDisable(onLineBtn, true)
            redPoint = true
        else
            GUI.ButtonSetText(onLineBtn, "未达成")
            GUI.ButtonSetShowDisable(onLineBtn, false)
        end
        GUI.ImageSetImageID(item, "1801100010")
    end
    GlobalProcessing.SetRetPoint(onLineBtn,redPoint)
    local cnt = 5
    if data.Config[index].items then
        cnt = math.max(cnt, #data.Config[index].items)
    end
    if cnt < 6 then
        GUI.SetIsRaycastTarget(src, false)
    end
    GUI.LoopScrollRectSetTotalCount(src, cnt)
    GUI.LoopScrollRectRefreshCells(src)
end
function WelDailyOnLineUI.CreateItemIcon(guid)
    guid = tostring(guid)
    local src = GUI.GetByGuid(guid)
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(src)
    local item = ItemIcon.Create(src, "" .. curCount, 0, 0)
    GUI.SetData(item, "pguid", guid)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "WelDailyOnLineUI", "OnItemIconClick")
    return item
end
function WelDailyOnLineUI.RefreshItemIcon(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local item = GUI.GetByGuid(guid)
    index = index + 1
    local pguid = GUI.GetData(item, "pguid")
    local pitem = GUI.GetParentElement(GUI.GetByGuid(pguid))
    local pindex = GUI.ImageGetIndex(pitem) + 1
    local info = nil
    if data.Config[pindex] and data.Config[pindex].items then
        info = data.Config[pindex].items[index]
    end
    if info then
        ItemIcon.BindItemId(item, info.id)
        if info.count ~= 1 then
            GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, info.count)
            GUI.SetVisible(GUI.ItemCtrlGetElement(item, eItemIconElement.RightBottomNum), true)
        end
    else
        ItemIcon.BindItemIdWithNum(item, nil, nil)
    end
end
function WelDailyOnLineUI.GetData()
    WelDailyOnLineUI.TodayOnlineSec = 0
    WelfareUI.SendNotify("GetDailyOnlineData")
end
function WelDailyOnLineUI.Refresh()
    if WelDailyOnLineUI.Config then
        --数据变化不大 保存一下数据 免得每次去构造
        if data.TodayOnlineSec == nil or data.TodayOnlineSec == 0 then
            data.Config = {}
            for i = 1, #WelDailyOnLineUI.Config do
                data.Config[i] = {}
                data.Config[i].index = i
                data.Config[i].Second = WelDailyOnLineUI.Config[i].Second
                data.Config[i].items = LogicDefine.SeverItems2ClientItems(WelDailyOnLineUI.Config[i].itemList)
            end
        end
        for i = 1, #WelDailyOnLineUI.Config do
            data.Config[i].isGet = WelDailyOnLineUI["State_" .. data.Config[i].index] == 1
            data.TodayOnlineSec = WelDailyOnLineUI.TodayOnlineSec
            data.ClientSec = CL.GetServerTickCount()
        end
    end
    WelDailyOnLineUI.ClientRefresh()
end
function WelDailyOnLineUI.ClientRefresh()
    test("WelDailyOnLineUI.ClientRefresh")
    test(debug.traceback())
    test(tostring(data.TodayOnlineSec))
    if data.Config then
        table.sort(
            data.Config,
            function(a, b)
                if a.isGet == b.isGet then
                    return a.Second < b.Second
                end
                return b.isGet
            end
        )
    end
    if WelDailyOnLineUI.updateTime == nil then
        WelDailyOnLineUI.updateTime = Timer.New(WelDailyOnLineUI.UpdateTime, 1, -1)
    else
        WelDailyOnLineUI.updateTime:Stop()
        WelDailyOnLineUI.updateTime:Reset(WelDailyOnLineUI.UpdateTime, 1, -1)
    end
    WelDailyOnLineUI.updateTime:Start()

    WelDailyOnLineUI.RefreshUI()
end
function WelDailyOnLineUI.OnGetClick(guid)
    local onLineBtn = GUI.GetByGuid(guid)
    local index = GUI.ButtonGetIndex(onLineBtn) + 1
    WelfareUI.SendNotify("ReceiveDailyOnlineReward", data.Config[index].index)
end
function WelDailyOnLineUI.UpdateTime()
    test("WelDailyOnLineUI.UpdateTime")
    data.TodayOnlineSec = CL.GetServerTickCount() - data.ClientSec + data.TodayOnlineSec
    data.ClientSec = CL.GetServerTickCount()
    WelDailyOnLineUI.RefreshUI()
end
function WelDailyOnLineUI.RefreshUI()
    local scroll = guidt.GetUI("src")
    GUI.LoopScrollRectSetTotalCount(scroll, #data.Config)
    GUI.LoopScrollRectRefreshCells(scroll)
    WelfareUI.RefreshLeftTypeScroll()
    GUI.StaticSetText(guidt.GetUI("txt"), "今日在线" .. UIDefine.LeftTimeFormatEx(data.TodayOnlineSec + data.ClientSec))
end
function WelDailyOnLineUI.OnItemIconClick(guid)
    local item = GUI.GetByGuid(guid)
    local index = GUI.ItemCtrlGetIndex(item) + 1
    local pguid = GUI.GetData(item, "pguid")
    local pitem = GUI.GetParentElement(GUI.GetByGuid(pguid))
    local pindex = GUI.ImageGetIndex(pitem) + 1
    local info = data.Config[pindex].items[index]
    if info then
        Tips.CreateByItemId(info.id, guidt.GetUI("subBg"), "tips", 0, 0)
    end
end
