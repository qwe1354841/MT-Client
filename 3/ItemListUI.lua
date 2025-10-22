local ItemListUI = {}
_G.ItemListUI = ItemListUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local guidt = UILayout.NewGUIDUtilTable()
function ItemListUI.InitData()
    return {
        ---@type eqiupItem[]
        item = {}
    }
end
local data = ItemListUI.InitData()
function ItemListUI.OnExitGame()
    data = ItemListUI.InitData()
end
function ItemListUI.OnExit()
    guidt = nil
    GUI.DestroyWnd("ItemListUI")
end
function ItemListUI.Main(parameter)
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("ItemListUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("ItemListUI", "ItemListUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle2(panel, parameter, 502, 284, "ItemListUI", "OnExit")
    guidt.BindName(panelBg,"panelBg")
    ItemListUI.CreateTipsWnd()
end
function ItemListUI.OnShow(parameter)
    local wnd = GUI.GetWnd("ItemListUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
end
function ItemListUI.OnDestroy()
    ItemListUI.OnClose()
end
function ItemListUI.OnClose()
    local wnd = GUI.GetWnd("ItemListUI")
    GUI.SetVisible(wnd, false)
end
function ItemListUI.GetDate()
end
function ItemListUI.Refresh()
    ItemListUI.ClientRefresh()
end
function ItemListUI.ClientRefresh()
    ItemListUI.RefreshUI()
end
function ItemListUI.RefreshUI()
end

--创建TIPS页面
function ItemListUI.CreateTipsWnd()
    local panelCover = GUI.Get("ItemListUI/panelCover")

    local tipsWnd = GUI.GroupCreate(guidt.GetUI("panelBg"), "tipsWnd", 0, 0, 0, 0)
    GUI.SetIgnoreChild_OnVisible(tipsWnd, true)
    GUI.SetAnchor(tipsWnd, UIAnchor.Center)
    GUI.SetPivot(tipsWnd, UIAroundPivot.Center)
    GUI.SetVisible(tipsWnd, true)

    local titleBgInput = GUI.ImageCreate(tipsWnd, "titleBgInput", "1800400200", 0, 26, false, 467, 195)
    GUI.SetAnchor(titleBgInput, UIAnchor.Center)
    GUI.SetPivot(titleBgInput, UIAroundPivot.Center)


    local tipsScroll =
        GUI.LoopScrollRectCreate(
        tipsWnd,
        "ScrollWnd",
        8,
        37,
        444,
        171,
        "ItemListUI",
        "CreateTipsItem",
        "ItemListUI",
        "RefreshTipsItem",
        0,
        false,
        Vector2.New(76, 76),
        5,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    guidt.BindName(tipsScroll, "tipsScroll")
    GUI.SetAnchor(tipsScroll, UIAnchor.Center)
    GUI.SetPivot(tipsScroll, UIAroundPivot.Center)
    GUI.ScrollRectSetChildAnchor(tipsScroll, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(tipsScroll, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(tipsScroll, Vector2.New(14, 14))
    GUI.LoopScrollRectSetTotalCount(tipsScroll, 0)
end

--显示TIPS页面
function ItemListUI.ShowTipsPage(item)
    data.item = item
    local tipsScroll = guidt.GetUI("tipsScroll")
    local num = #data.item
    GUI.LoopScrollRectSetTotalCount(tipsScroll, num)
    GUI.LoopScrollRectRefreshCells(tipsScroll)
    if tipsScroll then
        GUI.ScrollRectSetNormalizedPosition(tipsScroll, Vector2.New(0, 0))
    end
end

function ItemListUI.CreateTipsItem()
    local scroll = guidt.GetUI("tipsScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = ItemIcon.Create(scroll, tostring(curCount), 0, 0)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "ItemListUI", "OnItemClick")
    return item
end

function ItemListUI.RefreshTipsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    ItemIcon.BindItemId(item, data.item[index].id)
end
--ITEM点击
function ItemListUI.OnItemClick(guid)
    local itemIcon = GUI.GetByGuid(guid)
    if itemIcon == nil then
        return
    end
    local itemId = data.item[GUI.ItemCtrlGetIndex(itemIcon) + 1].id
    if itemId ~= nil then
        local tips = Tips.CreateByItemId(itemId, guidt.GetUI("panelBg"), "tips", -436, 0)
        UILayout.SetSameAnchorAndPivot(tips, UILayout.Center)
    end
end
