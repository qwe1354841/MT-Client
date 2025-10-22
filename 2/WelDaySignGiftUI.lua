local WelDaySignGiftUI = {
    ---@type WelDailySignConfig[]
    DailySignConfig = {},
    -- DailySignState_1 = 0,
    -- DailySignState_2 = 0,
    -- DailySignState_3 = 0,
    -- DailySignState_4 = 0,
    -- DailySignState_5 = 0,
    -- DailySignState_6 = 0,
    -- DailySignState_7 = 0,
    isOpen = false,
    scrollTime = nil
}
_G.WelDaySignGiftUI = WelDaySignGiftUI

local guidt = UILayout.NewGUIDUtilTable()
function WelDaySignGiftUI.InitData()
    return {
        ---@type WelDailySignConfig[]
        Config = {},
        dayOfWeek = 0
    }
end

local data = WelDaySignGiftUI.InitData()
function WelDaySignGiftUI.OnExitGame()
    data = WelDaySignGiftUI.InitData()
    if WelDaySignGiftUI.scrollTime then
        WelDaySignGiftUI.scrollTime:Stop()
        WelDaySignGiftUI.scrollTime = nil
    end
    WelDaySignGiftUI.isOpen = false
end
function WelDaySignGiftUI.CreateSubPage(subBg)
    guidt = UILayout.NewGUIDUtilTable()
    guidt.BindName(subBg, "subBg")
    local src =
        GUI.LoopScrollRectCreate(
        subBg,
        "src",
        103,
        57,
        810,
        535,
        "WelDaySignGiftUI",
        "CreateItem",
        "WelDaySignGiftUI",
        "RefreshItem",
        0,
        false,
        Vector2.New(810, 144),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    UILayout.SetSameAnchorAndPivot(src, UILayout.Top)
    GUI.ScrollRectSetChildSpacing(src, Vector2.New(0, 8))
    guidt.BindName(src, "src")
end
function WelDaySignGiftUI.SrollToCell()
    local scrollNum = 1
    local cnt = #data.Config
    if cnt > 0 and data.dayOfWeek <= cnt and WelDaySignGiftUI["DailySignState_" .. data.dayOfWeek] == 0 then
        scrollNum = data.dayOfWeek
    else
        for i = 1, cnt, 1 do
            if i < data.dayOfWeek and WelDaySignGiftUI["DailySignState_" .. i] == 0 then
                scrollNum = i
                break
            end
        end
    end
    if scrollNum ~= 1 then
        GUI.LoopScrollRectSrollToCell(guidt.GetUI("src"), scrollNum - 1, 1000)
    end
    -- local cnt = #data.Config
    -- if cnt > 0 and data.dayOfWeek <= cnt and WelDaySignGiftUI["DailySignState_" .. data.dayOfWeek] == 0 then
    --     GUI.LoopScrollRectSrollToCell(guidt.GetUI("src"), data.dayOfWeek - 1, 1000)
    -- end
end

function WelDaySignGiftUI.OnShow(WelfareUIGuidt)
    local wnd = GUI.GetWnd("WelfareUI")
    if wnd == nil then
        return
    end
    WelDaySignGiftUI.isOpen = true
    local rewardBg = WelfareUIGuidt.GetUI("rewardBg")
    GUI.SetVisible(rewardBg, true)
    GUI.SetPositionX(rewardBg, 285)
    GUI.SetPositionY(rewardBg, 48)
    GUI.SetWidth(rewardBg, 834)
    GUI.SetHeight(rewardBg, 559)
    WelDaySignGiftUI.ClientRefresh()
    WelDaySignGiftUI.GetData()
    if WelDaySignGiftUI.scrollTime == nil then
        -- body
        WelDaySignGiftUI.scrollTime = Timer.New(WelDaySignGiftUI.SrollToCell, 0.5, 1)
    else
        WelDaySignGiftUI.scrollTime:Stop()
        WelDaySignGiftUI.scrollTime:Reset(WelDaySignGiftUI.SrollToCell, 0.5, 1)
    end
    WelDaySignGiftUI.scrollTime:Start()
end
function WelDaySignGiftUI.CreateItem()
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
    GUI.StaticSetAlignment(keyName, TextAnchor.MiddleCenter)
    local onLineBtn =
        GUI.ButtonCreate(item, "onLineBtn", "1800402110", -25, 0, Transition.ColorTint, "领取", 126, 45, false)
    local effect = GUI.SpriteFrameCreate(onLineBtn, "effect", "", 6, -2, false, 120, 45)
    UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
    GUI.SpriteFrameSetIsLoop(effect, true)
    GUI.SetFrameId(effect, "3403800000")
    GUI.Play(effect)
    GUI.SetScale(effect, Vector3.New(0.64, 0.64, 1))
    UILayout.SetSameAnchorAndPivot(effect, UILayout.Right)
    GUI.RegisterUIEvent(onLineBtn, UCE.PointerClick, "WelDaySignGiftUI", "OnGetClick")
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
        86,
        "WelDaySignGiftUI",
        "CreateItemIcon",
        "WelDaySignGiftUI",
        "RefreshItemIcon",
        0,
        true,
        Vector2.New(86, 86),
        1,
        UIAroundPivot.TopLeft,
        UIAnchor.TopLeft
    )
    UILayout.SetSameAnchorAndPivot(itemSrc, UILayout.Left)
    GUI.ScrollRectSetChildSpacing(itemSrc, Vector2.New(3, 3))
    GUI.SetLinkScrollRect(itemSrc, src)
    return item
end

function WelDaySignGiftUI.RefreshItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local item = GUI.GetByGuid(guid)
    local onLineBtn = GUI.GetChild(item, "onLineBtn", false)
    local effect = GUI.GetChild(onLineBtn, "effect", false)
    GUI.ButtonSetIndex(onLineBtn, index)
    index = index + 1
    local src = GUI.GetChild(item, "itemSrc", false)
    local keyName = GUI.GetChild(item, "keyName", false)
    if data.Config[index] == nil then
        return
    end
    GUI.StaticSetText(keyName, data.Config[index].Name)
    local redPoint = false
    if data.Config[index].isGet then
        GUI.ButtonSetText(onLineBtn, "已领取")
        GUI.ImageSetImageID(item, "1801100012")
        GUI.ButtonSetShowDisable(onLineBtn, false)
        GUI.SetVisible(effect, false)
        GUI.Stop(effect)
    else
        local txt = "领取"
        local play = false
        if data.dayOfWeek > data.Config[index].index then
            txt = "补领"
            GUI.ButtonSetShowDisable(onLineBtn, true)
        elseif data.dayOfWeek == data.Config[index].index then
            play = true
            redPoint = true
            GUI.ButtonSetShowDisable(onLineBtn, true)
        else
            txt = "未达成"
            GUI.ButtonSetShowDisable(onLineBtn, false)
        end
        GUI.ImageSetImageID(item, "1801100010")
        GUI.SetVisible(effect, play)
        if play then
            GUI.Play(effect)
        else
            GUI.Stop(effect)
        end
        GUI.ButtonSetText(onLineBtn, txt)
    end
    GlobalProcessing.SetRetPoint(onLineBtn, redPoint)
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
function WelDaySignGiftUI.CreateItemIcon(guid)
    guid = tostring(guid)
    local src = GUI.GetByGuid(guid)
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(src)
    local item = ItemIcon.Create(src, "" .. curCount, 0, 0)
    GUI.SetData(item, "pguid", guid)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "WelDaySignGiftUI", "OnItemIconClick")

    return item
end
function WelDaySignGiftUI.RefreshItemIcon(parameter)
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
function WelDaySignGiftUI.GetData()
	if GUI.HasWnd('WelfareUI') then
		WelfareUI.SendNotify("GetDailySignData")
	end
end
function WelDaySignGiftUI.Refresh()
    if WelDaySignGiftUI.DailySignConfig then
        if data.Config == nil or #data.Config == 0 then
            data.Config = {}
            for i = 1, #WelDaySignGiftUI.DailySignConfig do
                data.Config[i] = {}
                data.Config[i].Name = WelDaySignGiftUI.DailySignConfig[i].Name
                data.Config[i].index = i
                data.Config[i].items = LogicDefine.SeverItems2ClientItems(WelDaySignGiftUI.DailySignConfig[i].itemList)
            end
        end
        for i = 1, #data.Config do
            data.Config[i].isGet =
                WelDaySignGiftUI["DailySignState_" .. data.Config[i].index] and
                WelDaySignGiftUI["DailySignState_" .. data.Config[i].index] == 1 or
                false
        end
    end
    WelDaySignGiftUI.ClientRefresh()
end
function WelDaySignGiftUI.ClientRefresh()
    data.dayOfWeek = CL.GetDayOfWeek()
    if data.dayOfWeek == 0 then
        data.dayOfWeek = 7
    end
    WelDaySignGiftUI.RefreshUI()
end
function WelDaySignGiftUI.RefreshUI()
    local scroll = guidt.GetUI("src")
    local cnt = #data.Config
    GUI.LoopScrollRectSetTotalCount(scroll, cnt)
    GUI.LoopScrollRectRefreshCells(scroll)
    GlobalProcessing.DailySign_DataLoading()
    WelfareUI.RefreshLeftTypeScroll()
end
function WelDaySignGiftUI.OnItemIconClick(guid)
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
function WelDaySignGiftUI.OnGetClick(guid)
    local onLineBtn = GUI.GetByGuid(guid)
    local index = GUI.ButtonGetIndex(onLineBtn) + 1
    WelfareUI.SendNotify("ReceiveDailySignReward", data.Config[index].index)
end
