local PromoteUI = {}
_G.PromoteUI = PromoteUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local guidt = UILayout.NewGUIDUtilTable()
---@class promoteItemList
---@field name string
---@field isvis function
---@field GetWayType number
---@field wndName string
---@field parameter number[]
---@field ext string
local promoteItemList = {
    {
        name = "角色加点",
        isvis = function()
            return true
        end,
        GetWayType = 1,
        wndName = "AddPointUI",
        parameter = {3},
        ext = ""
    },
    {
        name = "宠物加点",
        isvis = function()
            return true
        end,
        GetWayType = 1,
        wndName = "PetUI",
        parameter = {1,1},
        ext = ""
    },
    {
        name = "技能提升",
        isvis = function()
            local turnBron =  CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
            return turnBron>1 or CL.GetIntAttr(RoleAttr.RoleAttrLevel) >= MainUIBtnOpenDef.Data[5].Lv
        end,
        GetWayType = 1,
        wndName = "RoleSkillUI",
        parameter = {},
        ext = ""
    },
    {
        name = "装备强化",
        isvis = function()
            local turnBron =  CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
            return turnBron>1 or CL.GetIntAttr(RoleAttr.RoleAttrLevel) >= MainUIBtnOpenDef.Data[12].Lv
        end,
        GetWayType = 1,
        wndName = "EquipUI",
        parameter = {1,2},
        ext = ""
    },
    {
        name = "装备炼化",
        isvis = function()
            local turnBron =  CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
            return turnBron>1 or CL.GetIntAttr(RoleAttr.RoleAttrLevel) >= MainUIBtnOpenDef.Data[12].Lv
        end,
        GetWayType = 1,
        wndName = "EquipUI",
        parameter = {2,2},
        ext = ""
    },
    {
        name = "装备重铸",
        isvis = function()
            local turnBron =  CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
            return turnBron>1 or CL.GetIntAttr(RoleAttr.RoleAttrLevel) >= MainUIBtnOpenDef.Data[12].Lv
        end,
        GetWayType = 1,
        wndName = "EquipUI",
        parameter = {2,1},
        ext = ""
    },
    {
        name = "装备打造",
        isvis = function()
            local turnBron =  CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
            return turnBron>1 or CL.GetIntAttr(RoleAttr.RoleAttrLevel) >= MainUIBtnOpenDef.Data[12].Lv
        end,
        GetWayType = 1,
        wndName = "EquipUI",
        parameter = {1,1},
        ext = ""
    }
}
function PromoteUI.InitData()
    return {
        promoteList = {}
    }
end
local data = PromoteUI.InitData()
function PromoteUI.OnExitGame()
    data = PromoteUI.InitData()
end
function PromoteUI.OnExit()
    guidt = nil
    GUI.DestroyWnd("PromoteUI")
end
local itemH = 65
local itemW = 225
function PromoteUI.Main(parameter)
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("PromoteUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("PromoteUI", "PromoteUI", 0, 0, eCanvasGroup.Normal)
    local panelCover =
        GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    GUI.SetColor(panelCover,UIDefine.Transparent)
    panelCover:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(panelCover, UCE.PointerClick, "PromoteUI", "OnExit")

    local bg = GUI.ImageCreate(panelCover, "promoteListBg", "1800400290", 0, 0, false, itemW + 8, 0)
    GUI.SetAnchor(bg, UIAnchor.Center)
    GUI.SetPivot(bg, UIAroundPivot.Top)
    bg:RegisterEvent(UCE.PointerClick)

    local childSize = Vector2.New(214, 65)
    local promoteListScroll =
        GUI.LoopListCreate(
        bg,
        "promoteListScroll",
        0,
        5,
        itemW,
        0,
        "PromoteUI",
        "CreatItem",
        "PromoteUI",
        "RefreshItem",
        0,
        false,
        childSize,
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    guidt.BindName(promoteListScroll, "src")
    UILayout.SetAnchorAndPivot(promoteListScroll, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(promoteListScroll, Vector2.New(0, 0))
    data.promoteList = {}
    for i = 1, #promoteItemList do
        -- body
        if promoteItemList[i].isvis() then
            data.promoteList[#data.promoteList + 1] = promoteItemList[i]
        end
    end
    local h = Mathf.Min(itemH * #data.promoteList, itemH*4)
    GUI.SetHeight(bg, h + 10)
    GUI.SetHeight(promoteListScroll, h)
    GUI.LoopScrollRectSetTotalCount(promoteListScroll, #data.promoteList)
end
function PromoteUI.CreatItem()
    local src = guidt.GetUI("src")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(src)
    local btn = GUI.ButtonCreate(src, curCount, "1800600870", 0, 0, Transition.ColorTint, "", itemW, itemH, false)
    GUI.SetPreferredWidth(btn, 225)
    GUI.SetPreferredHeight(btn, 65)
    GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeL)
    GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)

    GUI.RegisterUIEvent(btn, UCE.PointerClick, "PromoteUI", "OnPromoteItemClick")
    return btn
end
function PromoteUI.RefreshItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    GUI.ButtonSetText(item, data.promoteList[index].name)
end
function PromoteUI.OnPromoteItemClick(guid)
    local index = GUI.ButtonGetIndex(GUI.GetByGuid(guid)) + 1
    ---@type promoteItemList
    local tmp = data.promoteList[index]
    if tmp then
		if tmp.wndName ~= "PetUI" then
			GetWay.Def[tmp.GetWayType].jump(tmp.wndName, tmp.parameter[1], tmp.parameter[2])
		else
			GUI.OpenWnd("PetUI")
		end
    end
    PromoteUI.OnExit()
end
function PromoteUI.OnShow(parameter)
    local wnd = GUI.GetWnd("PromoteUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
    local panelCover = GUI.GetChild(wnd, "panelCover", false)
    local bg = GUI.GetChild(panelCover, "promoteListBg", false)
    local position = {x = 0, y = 0}
    if parameter then
        local base = GUI.GetByGuid(parameter)
        if base then
            local screenPoint = GUI.GetScreenPoint(base)
            position = GUI.GetPointByScreenPoint(GUI.GetWnd("MainUI"), screenPoint)
        end
    end
    GUI.SetPositionX(bg, position.x)
    GUI.SetPositionY(bg, -(position.y - 45))
end
function PromoteUI.OnDestroy()
    PromoteUI.OnClose()
end
function PromoteUI.OnClose()
    local wnd = GUI.GetWnd("PromoteUI")
    GUI.SetVisible(wnd, false)
end
function PromoteUI.GetDate()
end
function PromoteUI.Refresh()
    PromoteUI.ClientRefresh()
end
function PromoteUI.ClientRefresh()
    PromoteUI.RefreshUI()
end
function PromoteUI.RefreshUI()
end
