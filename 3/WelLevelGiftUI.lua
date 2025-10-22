local WelLevelGiftUI = {
    ---@type WelLevelGiftConfig[]
    isOpen = false,
    Config = {}
}
local test = function()
end
_G.WelLevelGiftUI = WelLevelGiftUI

local guidt = UILayout.NewGUIDUtilTable()
function WelLevelGiftUI.InitData()
    return {
        ---@type WelLevelGiftConfig[]
        Config = {},
        lv = 0,
        turn = 0
    }
end

local data = WelLevelGiftUI.InitData()
function WelLevelGiftUI.NotifyRoleData(attrType, value)
    test("NotifyRoleData " .. tonumber(tostring(value)))
    if attrType == RoleAttr.RoleAttrLevel then
        data.lv = value
    end
    WelLevelGiftUI.RefreshUI()
end
function WelLevelGiftUI.OnExitGame()
    data = WelLevelGiftUI.InitData()
    CL.UnRegisterAttr(RoleAttr.RoleAttrLevel, WelLevelGiftUI.NotifyRoleData)
    WelLevelGiftUI.isOpen = false
end
function WelLevelGiftUI.CreateSubPage(subBg)
    guidt = UILayout.NewGUIDUtilTable()
    guidt.BindName(subBg, "subBg")
    local titleBg = GUI.ImageCreate(subBg, "titleBg", "1800608330", 103, -209, false, 828, 124)
    local src =
        GUI.LoopScrollRectCreate(
        subBg,
        "src",
        103,
        77,
        810,
        383,
        "WelLevelGiftUI",
        "CreateItem",
        "WelLevelGiftUI",
        "RefreshItem",
        0,
        false,
        Vector2.New(810, 208),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    UILayout.SetSameAnchorAndPivot(src, UILayout.Center)
    GUI.ScrollRectSetChildSpacing(src, Vector2.New(0, 8))
    guidt.BindName(src, "src")
end

function WelLevelGiftUI.OnShow(WelfareUIGuidt)
    local wnd = GUI.GetWnd("WelfareUI")
    if wnd == nil then
        return
    end
    WelLevelGiftUI.isOpen = true
    local rewardBg = WelfareUIGuidt.GetUI("rewardBg")
    GUI.SetVisible(rewardBg, true)
    GUI.SetPositionX(rewardBg, 285)
    GUI.SetPositionY(rewardBg, 194)
    GUI.SetWidth(rewardBg, 838)
    GUI.SetHeight(rewardBg, 415)
    WelLevelGiftUI.ClientRefresh()
    WelLevelGiftUI.GetData()
    CL.RegisterAttr(RoleAttr.RoleAttrLevel, WelLevelGiftUI.NotifyRoleData)
end
function WelLevelGiftUI.CreateItem()
    local src = guidt.GetUI("src")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(src)
    local item = GUI.ImageCreate(src, "item" .. curCount, "1801100010", 0, 0, false)
    GUI.SetIsRaycastTarget(item, true)
    local keynameBg = GUI.ImageCreate(item, "keynameBg", "1800600510", 15, 0)
    UILayout.SetSameAnchorAndPivot(keynameBg, UILayout.Left)
    local keyName = GUI.CreateStatic(item, "keyName", curCount, 15, 0, 175, 35)
    UILayout.SetSameAnchorAndPivot(keyName, UILayout.Left)
    GUI.SetColor(keyName, UIDefine.BrownColor)
    GUI.StaticSetFontSize(keyName, UIDefine.FontSizeM)
    -- UILayout.SetSameAnchorAndPivot(keyName, UILayout.Center)
    GUI.StaticSetAlignment(keyName, TextAnchor.MiddleCenter)
    local onLineBtn =
        GUI.ButtonCreate(item, "onLineBtn", "1800402110", -25, 0, Transition.ColorTint, "领取", 120, 45, false)
    GUI.RegisterUIEvent(onLineBtn, UCE.PointerClick, "WelLevelGiftUI", "OnGetClick")
    UILayout.SetSameAnchorAndPivot(onLineBtn, UILayout.Right)
    GUI.ButtonSetTextFontSize(onLineBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(onLineBtn, UIDefine.BrownColor)
    local itemSrc =
        GUI.LoopScrollRectCreate(
        item,
        "itemSrc",
        205,
        0,
        450,
        182,
        "WelLevelGiftUI",
        "CreateItemIcon",
        "WelLevelGiftUI",
        "RefreshItemIcon",
        0,
        true,
        Vector2.New(86, 86),
        2,
        UIAroundPivot.TopLeft,
        UIAnchor.TopLeft
    )
    UILayout.SetSameAnchorAndPivot(itemSrc, UILayout.Left)
    GUI.ScrollRectSetChildSpacing(itemSrc, Vector2.New(3, 3))
    GUI.SetLinkScrollRect(itemSrc, src)
    return item
end

function WelLevelGiftUI.RefreshItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local item = GUI.GetByGuid(guid)
    local onLineBtn = GUI.GetChild(item, "onLineBtn", false)
    GUI.ButtonSetIndex(onLineBtn, index)
    index = index + 1
    local src = GUI.GetChild(item, "itemSrc", false)
    local keynameBg = GUI.GetChild(item, "keynameBg", false)
    local keyName = GUI.GetChild(item, "keyName", false)
    if data.Config[index].turn == 0 then
        GUI.StaticSetText(keyName, "到达" .. data.Config[index].lv .. "级")
    else
        GUI.StaticSetText(keyName, "到达" .. data.Config[index].turn .. "转" .. data.Config[index].lv .. "级")
    end
    local redPoint = false
    if data.Config[index].isGet then
        GUI.ButtonSetText(onLineBtn, "已领取")
        GUI.ButtonSetShowDisable(onLineBtn, false)
        GUI.ImageSetImageID(item, "1801100012")
    else
        if
            data.turn > data.Config[index].turn or
                (data.turn == data.Config[index].turn and data.lv >= data.Config[index].lv)
         then
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
    local cnt = 10
    if data.Config[index].items then
        test(data.Config[index].key)
        test(#data.Config[index].items)
        cnt = math.max(cnt, #data.Config[index].items)
    end
    if cnt < 11 then
        GUI.SetIsRaycastTarget(src, false)
    end
    GUI.LoopScrollRectSetTotalCount(src, cnt)
    GUI.LoopScrollRectRefreshCells(src)
end
function WelLevelGiftUI.CreateItemIcon(guid)
    guid = tostring(guid)
    local src = GUI.GetByGuid(guid)
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(src)
    local item = ItemIcon.Create(src, "" .. curCount, 0, 0)
    GUI.SetData(item, "pguid", guid)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "WelLevelGiftUI", "OnItemIconClick")
    return item
end
function WelLevelGiftUI.RefreshItemIcon(parameter)
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
function WelLevelGiftUI.GetData()
    WelfareUI.SendNotify("GetLevelPackageData")
end
function WelLevelGiftUI.Refresh()
    if WelLevelGiftUI.Config then
        if data.Config == nil or #data.Config == 0 then
            data.Config = {}
            for key, value in pairs(WelLevelGiftUI.Config) do
                local i = #data.Config + 1
                data.Config[i] = {}
                data.Config[i].key = key
                data.Config[i].index = i
                local str = string.split(key, "_")
                local lv = str[2]
                local turn = str[1]
                if lv then
                    data.Config[i].lv = tonumber(lv)
                else
                    data.Config[i].lv = 0
                end
                if turn then
                    data.Config[i].turn = tonumber(turn)
                else
                    data.Config[i].turn = 0
                end
                data.Config[i].items = LogicDefine.SeverItems2ClientItems(value)
            end
        end
        for i = 1, #data.Config do
            data.Config[i].isGet =
                WelLevelGiftUI["State_" .. data.Config[i].key] and WelLevelGiftUI["State_" .. data.Config[i].key] == 1 or
                false
        end
    end
    WelLevelGiftUI.ClientRefresh()
end
function WelLevelGiftUI.ClientRefresh()
    test("WelLevelGiftUI.ClientRefresh")
    test(debug.traceback())
    local h = nil
    data.lv, h = int64.longtonum2(CL.GetAttr(RoleAttr.RoleAttrLevel))
    data.turn, h = int64.longtonum2(CL.GetAttr(RoleAttr.RoleAttrReincarnation))
    if data.Config then
        table.sort(
            data.Config,
            function(a, b)
                if a.isGet == b.isGet then
                    if a.turn == b.turn then
                        if a.lv == b.lv then
                            return a.index < b.index
                        end
                        return a.lv < b.lv
                    end
                    return a.turn < b.turn
                end
                return b.isGet
            end
        )
    end

    WelLevelGiftUI.RefreshUI()
end
function WelLevelGiftUI.RefreshUI()
    local scroll = guidt.GetUI("src")
    GUI.LoopScrollRectSetTotalCount(scroll, #data.Config)
    GUI.LoopScrollRectRefreshCells(scroll)
    WelfareUI.RefreshLeftTypeScroll()
end
function WelLevelGiftUI.OnItemIconClick(guid)
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
function WelLevelGiftUI.OnGetClick(guid)
    local onLineBtn = GUI.GetByGuid(guid)
    local index = GUI.ButtonGetIndex(onLineBtn) + 1
    test("OnGetClick " .. data.Config[index].key)
    WelfareUI.SendNotify("ReceiveLevelPackageReward", data.Config[index].key)
end
