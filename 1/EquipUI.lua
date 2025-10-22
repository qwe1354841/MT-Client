local EquipUI = {
    tabSubIndex = 1,
    tabIndex = 1,
    RefreshLeftItemScroll = nil,
    data = {
        roleid = 0,
        ---@type eqiupItem[]
        bag = {},
        ---@type eqiupItem[]
        equip = {}
    },
    ---@type guidTable
    guidt = UILayout.NewGUIDUtilTable(),
    CheckItemGuid = 0,
    CheckItemId = 0,
    CheckBagType = 0,
    curGuardGuid = nil --- 当前选中的侍从guid
}
_G.EquipUI = EquipUI

local attrT = {RoleAttr.RoleAttrIngot, RoleAttr.RoleAttrBindGold, RoleAttr.RoleAttrBindIngot, RoleAttr.RoleAttrGold}

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

require "EquipScrollItem"
require "Language"
local equipSubTableUIName = {
    "EquipEnhanceUI",
    "EquipProduceUI",
	"EquipRepairUI",
	"EquipEffectsUI",
	"EquipStuntUI",
	"EquipExtractUI",
    "EquipSuitUI",
    "EquipSoulWashingUI",
    "EquipPossessionUI",
    "EquipAscendSoulUI",
}
EquipUI.isShowRedPoint = true
local gemSubTableUIName = {
    "EquipGemInlayUI",
    "EquipGemMergeUI",
    "EquipGemRecastUI"
}

local equipSubTableUI = {}
local gemSubTableUI = {}
local totalSubTableUI = {equipSubTableUI, gemSubTableUI}
local panelBgPath = "EquipUI/panelBg"
---@type guidTable
local guidt = EquipUI.guidt
local defEquipPage = 1
local defRefinePage = 3
-- local defGrowUpPage = 3
-- local defQuenchPage = 4
-- local defGemPage = 5
local defGemPage = 2
local defSuitPage = 4
local defSoulWashingPage = 5

--上一个右上角选中的复选框guid
local lastSelectSubTabGuid = nil

local tabList = {
    setmetatable(
        {
            "装备",
            "tabEquipBtn",
            "OnTabEquipBtnClick",
            "equipPage",
            panelBgPath .. "/equipPage",
            {
                txt = {
                    -- "修理",
                    -- "强化",
                    -- -- "打造", --普通打造
                    -- "打造" --仙器打造
                    "修理",
                    "打造",
                    "强化",
                },
                onClick = {
                    function()
                        EquipUI.tabSubIndex = 3
                        EquipUI.Refresh()
                    end,
                    function()
                        EquipUI.tabSubIndex = 2
                        EquipUI.Refresh()
                    end,
                    function()
                        EquipUI.tabSubIndex = 1
                        EquipUI.Refresh()
                    end
                },
                hide = {
                    function()
                        return false
                    end,
                    function()
                        return UIDefine.FunctionSwitch.EquipCreat ~= "on"
                    end,
                    function()
                        return UIDefine.FunctionSwitch.EquipIntensify ~= "on"
                    end
                },
                def = 3
            }
        },
        {
            __index = function(t, key)
                if key == "hide" then
                    return false
                end
                return rawget(t, key)
            end
        }
    ),
    setmetatable(
        {
            "宝石",
            "tabGemBtn",
            "OnTabGemBtnClick",
            "gemPage",
            panelBgPath .. "/gemPage",
            {
                txt = {
                    --"点化",
                    "合成",
                    "镶嵌"
                },
                onClick = {
                    --function()
                    --    EquipUI.tabSubIndex = 3
                    --    EquipUI.Refresh()
                    --end,
                    function()
                        EquipUI.tabSubIndex = 2
                        EquipUI.Refresh()
                    end,
                    function()
                        EquipUI.tabSubIndex = 1
                        EquipUI.Refresh()
                    end
                },
                --def = 3
                def = 2
            }
        },
        {
            __index = function(t, key)
                if key == "hide" then
                    if UIDefine.FunctionSwitch.EquipGem == "on" then
                        return false
                    end
                    return true
                end
                return rawget(t, key)
            end
        }
    ),
	setmetatable(
		{
			"炼化",
			"tabRefineBtn",
			"OnTabRefineBtnClick",
			"equipPage",
			panelBgPath .. "/equipPage",
			{
				txt = {
					"提取",
					"特技",
					"特效"
				},
				onClick = {
					function()
						EquipUI.tabSubIndex = 3
						EquipUI.Refresh()
					end,
					function()
						EquipUI.tabSubIndex = 2
						EquipUI.Refresh()
					end,
					function()
						EquipUI.tabSubIndex = 1
						EquipUI.Refresh()
					end
				},
				hide = {
					function()
						return false
					end,
					function()
						return false
					end,
					function()
						return false
					end
				},
				def = 3
			}
		},
		{
			__index = function(t, key)
				if key == "hide" then
					if UIDefine.FunctionSwitch.EquipArtifice == "on" then
						return false
					end
					return true
				end
				return rawget(t, key)
			end
		}
	),
    setmetatable(
        {
            "符印",
            "tabSuitBtn",
            "OnTabSuitBtnClick",
            "equipPage",
            panelBgPath .. "/equipPage",
            {
                txt = {
                    "符印",
                },
                onClick = {
                    function()
                        EquipUI.tabSubIndex = 1
                        EquipUI.Refresh()
                    end
                },
                hide = {
					function()
                        if UIDefine.FunctionSwitch.Suit == "on" then
                            if GlobalUtils.suitChangeItemConfig and GlobalUtils.suitChangeItemConfig ~= {} then
                                return false
                            end
                        end
						return true
					end
				},
                def = 4
            }
        },
        {
            __index = function(t, key)
                if key == "hide" then
                    if UIDefine.FunctionSwitch.Suit == "on" then
                        if GlobalUtils.suitChangeItemConfig and GlobalUtils.suitChangeItemConfig ~= {} then
                            return false
                        end
                    end
                    return true
                end
                return rawget(t, key)
            end
        }
    ),
    setmetatable(
            {
                "器灵",
                "tabSoulWashingBtn",
                "OnTabSoulWashingBtnClick",
                "soulWashingPage",
                panelBgPath .. "/soulWashingPage",
                {
                    txt = {
                        "升灵",
                        "附灵",
                        "洗灵",
                    },
                    onClick = {
                        function()
                            EquipUI.tabSubIndex = 3
                            EquipUI.Refresh()
                        end,
                        function()
                            EquipUI.tabSubIndex = 2
                            EquipUI.Refresh()
                        end,
                        function()
                            EquipUI.tabSubIndex = 1
                            EquipUI.Refresh()
                        end,
                    },
                    hide = {
                        function()
                            return false
                        end,
                        function()
                            return false
                        end,
                        function()
                            return false
                        end
                    },
                    def = 5
                }
            },
            {
                __index = function(t, key)
                    if key == "hide" then
                        if UIDefine.FunctionSwitch["EquipSoulReforge"] == "on" then
                            return false
                        end
                        return true

                    end
                    return rawget(t, key)
                end
            }
    ),
}
local ConstSubTab = function(x)
    local t = {
        "1800402030",
        "1800402032",
        "OnSubTabBtnClick",
        x,
        -245,
        160,
        50,
        100,
        35
    }
    return t
end
local StaticSubTabList = {
    ConstSubTab(436),
    ConstSubTab(276),
    ConstSubTab(116)
}

function EquipUI.OnDestroy()
    EquipUI.OnClose()
end

function EquipUI.InitData()
    EquipUI.tabSubIndex = 1
    EquipUI.tabIndex = 1
    EquipUI.RefreshLeftItemScroll = nil
    EquipUI.ClickLeftItemScroll = nil
    EquipUI.guidt = UILayout.NewGUIDUtilTable()
end

function EquipUI.OnExitGame()
    EquipUI.data.roleid = 0
    EquipUI.curGuardGuid = nil
end

function EquipUI.Main(parameter)
    print("parameter",parameter)
	--等级不足时禁止打开
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = MainUI.MainUISwitchConfig["装备"].OpenLevel
	if CurLevel < Level then
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启装备功能")
		return
	end
    local index1 = 1
    local index2 = 1
    if parameter then
        index1 = UIDefine.GetParameter1(parameter)
        index2 = UIDefine.GetParameter2(parameter)
        if index1 > 0 then
        else
            index1 = 1
        end
        if tabList[index1] then
            if index2 > 0 then
            else
                index2 = 1
            end
        end
    end
    local Key = tabList[index1][6].txt[index2]
    Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel_2[Key]
    if Level ~= nil then

        if CurLevel < Level then
            CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
            return
        end

    end

    GUI.PostEffect()
    test(UIDefine.FunctionSwitch.EquipIntensify)
    test(parameter)
    test(debug.traceback())
    for _i = 1, #equipSubTableUIName do
        require(equipSubTableUIName[_i])
        equipSubTableUI[_i] = _G[equipSubTableUIName[_i]]
    end

    for _i = 1, #gemSubTableUIName do
        require(gemSubTableUIName[_i])
        gemSubTableUI[_i] = _G[gemSubTableUIName[_i]]
    end
    GameMain.AddListen("EquipUI", "OnExitGame")
    GameMain.AddListen("EquipUI", "OnExitGame")
    local roleid = CL.GetIntAttr(RoleAttr.RoleAttrRole)
    if EquipUI.data.roleid ~= roleid then
        for j = 1, #totalSubTableUI do
            for i = 1, #totalSubTableUI[j] do
                if totalSubTableUI[j][i]["OnExitGame"] then
                    totalSubTableUI[j][i]["OnExitGame"]()
                end
            end
        end
    end
    EquipUI.data.roleid = roleid
    EquipUI.InitData()
    guidt = EquipUI.guidt
    local wnd = GUI.WndCreateWnd("EquipUI", "EquipUI", 0, 0)
    -- local wnd = GUI.WndCreateWnd("EquipUI", "EquipUI", 0, 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "装    备", "EquipUI", "OnExit", guidt)

    --guidt.BindName(panelBg, "panelBg")
    UILayout.CreateRightTab(tabList, "EquipUI")

    local itemScrollBg = GUI.ImageCreate(panelBg, "itemScrollBg", "1800400200", -375, 35, false, 290, 510)
	
	local emptyIamge = GUI.ImageCreate(itemScrollBg, "emptyIamge", "1800608770", 0,130,false, 330,275)
	GUI.SetEulerAngles(emptyIamge, Vector3.New(-180, 0, -180))
	GUI.SetVisible(emptyIamge,false)
	guidt.BindName(emptyIamge, "emptyIamge")
	
	local emptyIamgeTxtBg = GUI.ImageCreate(itemScrollBg, "emptyIamgeTxtBg", "1800601250",0,-55,false, 240,100)
	GUI.SetEulerAngles(emptyIamgeTxtBg, Vector3.New(-180, 0, -180))
	UILayout.SetSameAnchorAndPivot(emptyIamgeTxtBg, UILayout.Center)
	GUI.SetVisible(emptyIamgeTxtBg,false)
	guidt.BindName(emptyIamgeTxtBg, "emptyIamgeTxtBg")
	local emptyIamgeTxt = GUI.CreateStatic(emptyIamgeTxtBg, "emptyIamgeTxt", "少侠,您还没有装备呦~", 0,-12,230,50)
	GUI.StaticSetAlignment(emptyIamgeTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(emptyIamgeTxt, UIDefine.FontSizeM)
    GUI.SetColor(emptyIamgeTxt, UIDefine.BrownColor)
	
    local itemScroll =
        GUI.LoopScrollRectCreate(
        panelBg,
        "itemScroll",
        -375,
        35,
        285,
        500,
        "EquipUI",
        "CreatItemPool",
        "EquipUI",
        "RefreshItemScroll",
        0,
        false,
        Vector2.New(280, 100),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    guidt.BindName(itemScroll, "itemScroll")

    EquipUI.CreateEquipPage(panelBg)
    EquipUI.CreateGemPage(panelBg)

    local guardGroup = GUI.GroupCreate(panelBg, "guardGroup", 385, 77)
    guidt.BindName(guardGroup, "guardGroup")
    UILayout.SetSameAnchorAndPivot(guardGroup, UILayout.TopLeft)
    -- 侍从名字
    local nameBg = GUI.ImageCreate(guardGroup, "nameBg", "1801401100", 0, 11, false, 250, 40)
    GUI.SetIsRaycastTarget(nameBg, false)
    UILayout.SetSameAnchorAndPivot(nameBg, UILayout.Left)
    local guardName = GUI.CreateStatic(nameBg, "guardName", "侍从名字", 0, 0, 150, 30)
    guidt.BindName(guardName, "guardName")
    UILayout.SetSameAnchorAndPivot(guardName, UILayout.Center)
    GUI.StaticSetAlignment(guardName, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(guardName, UIDefine.FontSizeM)
    GUI.SetColor(guardName, UIDefine.WhiteColor)
    -- 侍从头像
    local gradeSprite = GUI.ImageCreate(guardGroup, "gradeSprite", "1800700250", 0, 7, false, 60, 60)
    guidt.BindName(gradeSprite, "guardGradeSprite")
    GUI.SetIsRaycastTarget(gradeSprite, false)
    UILayout.SetSameAnchorAndPivot(gradeSprite, UILayout.Left)
    local icon = GUI.ImageCreate(gradeSprite, "icon", "1800700250", 0, 0, false, 50, 50)
    guidt.BindName(icon, "guardIcon")
    GUI.SetIsRaycastTarget(icon, false)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Center)
    local guardGuid = UIDefine.GetParameterGuardGuid(parameter)
    test(tostring(guardGuid))
    if guardGuid then
        EquipUI.RefreshGuardGroup(uint64.new(guardGuid))
    else
        EquipUI.BindData()
    end

    CL.RegisterMessage(GM.RefreshBag, "EquipUI", "BindData")
    for i = 1, #attrT do
        CL.RegisterAttr(attrT[i], EquipUI.NotifyRoleData)
    end
end
function EquipUI.NotifyRoleData(attrType, value)
    -- value = tonumber(tostring(value))
    test("NotifyRoleData " .. tonumber(tostring(value)))
    for i = 1, #attrT do
        if attrType == attrT[i] then
            EquipUI.BindData()
            break;
        end
    end
end
-- 创建左侧道具表
function EquipUI.CreatItemPool()
    local scroll = guidt.GetUI("itemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = EquipScrollItem.CreateItem(scroll, "item" .. curCount)
	local ItemPool_redpot = GUI.ImageCreate(item, "ItemPool_redpot"..curCount, "1800208080", -130,-37,false,25,25)
    GUI.SetVisible(ItemPool_redpot,false)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "EquipUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipUI", "OnLeftItemClick")
    return item
end
function EquipUI.OnLeftItemClick(parameter)
    if EquipUI.ClickLeftItemScroll ~= nil then
        EquipUI.ClickLeftItemScroll(parameter)
    end
end
-- 刷新左侧道具表  处理数据
function EquipUI.RefreshItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    EquipUI.RefreshLeftItemScroll(guid, index)
end
function EquipUI.OnExit()
    -- guidt = nil
    GUI.CloseWnd("EquipUI")
    -- GUI.DestroyWnd("EquipUI")
end
--获取数据
function EquipUI.BindData()
    EquipUI.data.equip =
        EquipUI.curGuardGuid and LogicDefine.GetGuardEquipInBag(nil, EquipUI.curGuardGuid) or
        LogicDefine.GetEqiupInBag(nil, item_container_type.item_container_equip)
    EquipUI.data.bag = LogicDefine.GetEqiupInBag(nil, item_container_type.item_container_bag)
    EquipUI.Refresh(false)
end
function EquipUI.SetTabIndex(tabIndex)
    local firstIndex = nil
    if tabList[tabIndex].hide == true then
        for i = 1, #tabList do
            if tabList[i].hide == true then
            else
                firstIndex = firstIndex or i
                break
            end
        end
        EquipUI.tabIndex = firstIndex
    else
        EquipUI.tabIndex = tabIndex
    end

end

function EquipUI.RefreshSubTab(def)
    local index = 0
    local t = {}
    for i = 1, #StaticSubTabList do
        local btn = guidt.GetUI("TopRightBtn" .. i)
        local cur = guidt.GetUI("TopRightTxt" .. i)
        local txt = tabList[EquipUI.tabIndex][6].txt
        local hide = tabList[EquipUI.tabIndex][6].hide
        if txt[i] == nil or (hide and hide[i] and hide[i]()) then
            GUI.SetVisible(btn, false)
        else
            index = index + 1
            t[index] = i
            GUI.SetVisible(btn, true)
            GUI.StaticSetText(cur, txt[i])
            GUI.SetPositionX(btn, StaticSubTabList[index][4])
        end
    end
    def = def or tabList[EquipUI.tabIndex][6].def
    def = math.min(def, index)
    EquipUI.OnSubTabBtnClick(guidt.GetGuid("TopRightBtn" .. t[def]))
end
function EquipUI.Refresh(reset)
    if reset == nil then
        reset = true
        local scroll = guidt.GetUI("itemScroll")
        GUI.LoopScrollRectSetTotalCount(scroll, 0)
        GUI.LoopScrollRectRefreshCells(scroll)
    end
    for i = 1, #tabList do
        if i ~= EquipUI.tabIndex then
            local page = GUI.Get(tabList[i][5])
            GUI.SetVisible(page, false)
        end
    end

    local curPage = GUI.Get(tabList[EquipUI.tabIndex][5])
    GUI.SetVisible(curPage, true)

    test(EquipUI.tabIndex , EquipUI.tabSubIndex , reset)
    if EquipUI.tabIndex == defEquipPage then
        EquipUI.RefreshEquipPage(reset)
    elseif EquipUI.tabIndex == defRefinePage then
        EquipUI.RefreshRefinePage(reset)
    elseif EquipUI.tabIndex == defGrowUpPage then
        EquipUI.RefreshGrowUpPage(reset)
    elseif EquipUI.tabIndex == defQuenchPage then
        EquipUI.RefreshQuenchPage(reset)
    elseif EquipUI.tabIndex == defGemPage then
        EquipUI.RefreshGemPage(reset)
    elseif EquipUI.tabIndex == defSuitPage then
        EquipUI.RefreshSuitPage(reset)
    elseif EquipUI.tabIndex == defSoulWashingPage then
        EquipUI.RefreshSoulWashingPage(reset)
    end
    
    EquipUI.CheckEquipRedPoint()
    -- EquipUI.CheckGemRedPoint()
end

function EquipUI.RefreshGemPage(reset)
    local cur = nil
    if EquipUI.tabSubIndex == 1 then
        cur = EquipGemInlayUI
    elseif EquipUI.tabSubIndex == 2 then
        cur = EquipGemMergeUI
    elseif EquipUI.tabSubIndex == 3 then
        cur = EquipGemRecastUI
    end

    for i = 1, #totalSubTableUI do
        for j = 1, #totalSubTableUI[i] do
            if cur ~= totalSubTableUI[i][j] then
                totalSubTableUI[i][j].SetVisible(false)
            end
        end
    end

    if cur then
        cur.Show(reset, EquipUI.tabSubIndex)
    end
end
function EquipUI.RefreshSuitPage(reset)
    local cur = nil
    if EquipUI.tabSubIndex == 1 then
        cur = EquipSuitUI
    elseif EquipUI.tabSubIndex == 2 then
        cur = EquipRefinerUI
    elseif EquipUI.tabSubIndex == 3 then
        cur = EquipRefinerUI
    end
    for i = 1, #totalSubTableUI do
        for j = 1, #totalSubTableUI[i] do
            if cur ~= totalSubTableUI[i][j] then
                totalSubTableUI[i][j].SetVisible(false)
            end
        end
    end
    if cur then
        cur.Show(reset, EquipUI.tabSubIndex)
    end
end

--刷新洗灵和附灵页面
function EquipUI.RefreshSoulWashingPage(reset)

    local cur = nil
    if EquipUI.tabSubIndex == 1 then
        cur = EquipSoulWashingUI --洗灵
    elseif EquipUI.tabSubIndex == 2 then
        cur = EquipPossessionUI --附灵
    elseif EquipUI.tabSubIndex == 3 then
        cur = EquipAscendSoulUI --升灵
    end

    for i = 1, #totalSubTableUI do
        for j = 1, #totalSubTableUI[i] do
            if cur ~= totalSubTableUI[i][j] then
                totalSubTableUI[i][j].SetVisible(false)
            end
        end
    end
    if cur then
        cur.Show(reset, EquipUI.tabSubIndex)
    end


end

function EquipUI.RefreshQuenchPage(reset)
    local cur = nil
    if EquipUI.tabSubIndex == 1 then
        cur = EquipQuenchUI
    elseif EquipUI.tabSubIndex == 2 then
        cur = EquipRefinerUI
    elseif EquipUI.tabSubIndex == 3 then
        cur = EquipRefinerUI
    end
    for i = 1, #totalSubTableUI do
        for j = 1, #totalSubTableUI[i] do
            if cur ~= totalSubTableUI[i][j] then
                totalSubTableUI[i][j].SetVisible(false)
            end
        end
    end
    if cur then
        cur.Show(reset, EquipUI.tabSubIndex)
    end
end
function EquipUI.RefreshGrowUpPage(reset)
    local cur = nil
    if EquipUI.tabSubIndex == 1 then
        cur = EquipGrowUpUI
    end
    for i = 1, #totalSubTableUI do
        for j = 1, #totalSubTableUI[i] do
            if cur ~= totalSubTableUI[i][j] then
                totalSubTableUI[i][j].SetVisible(false)
            end
        end
    end
    if cur then
        cur.Show(reset)
    end
end
function EquipUI.RefreshRefinePage(reset)
    local cur = nil
    if EquipUI.tabSubIndex == 1 then
        cur = EquipEffectsUI
    elseif EquipUI.tabSubIndex == 2 then
        cur = EquipStuntUI
	elseif EquipUI.tabSubIndex == 3 then
		cur = EquipExtractUI
    end
    for i = 1, #totalSubTableUI do
        for j = 1, #totalSubTableUI[i] do
            if cur ~= totalSubTableUI[i][j] then
                totalSubTableUI[i][j].SetVisible(false)
            end
        end
    end
    cur.Show(reset)
end
function EquipUI.RefreshEquipPage(reset)
    local cur = nil
    if EquipUI.tabSubIndex == 1 then
        cur = EquipEnhanceUI
    elseif EquipUI.tabSubIndex == 2 then
        cur = EquipProduceUI
    elseif EquipUI.tabSubIndex == 3 then
        cur = EquipRepairUI
    end
    for i = 1, #totalSubTableUI do
        for j = 1, #totalSubTableUI[i] do
            if cur ~= totalSubTableUI[i][j] then
                totalSubTableUI[i][j].SetVisible(false)
            end
        end
    end
    cur.Show(reset)
end

--打开界面的时候调用
function EquipUI.OnShow(parameter)
    local wnd = GUI.GetWnd("EquipUI")
    if wnd == nil then
        return
    end
    --等级不足时禁止打开
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = MainUI.MainUISwitchConfig["装备"].OpenLevel
	if CurLevel < Level then
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启装备功能")
		return
	end
    local index1 = 1
    local index2 = 1
    if parameter then
        index1 = UIDefine.GetParameter1(parameter)
        index2 = UIDefine.GetParameter2(parameter)
        if index1 > 0 then
        else
            index1 = 1
        end
        if tabList[index1] then
            if index2 > 0 then
            else
                index2 = 1
            end
        end
    end
    local Key = tabList[index1][6].txt[index2]
    Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel_2[Key]
    if Level ~= nil then

        if CurLevel < Level then
            CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
            return
        end

    end

    EquipUI.BindData()
    CL.RegisterMessage(GM.RefreshBag, "EquipUI", "BindData")
    GUI.SetVisible(wnd,true)
    if parameter then
        test("+++" .. parameter)
        local index1 = UIDefine.GetParameter1(parameter)
        local index2 = UIDefine.GetParameter2(parameter)
        local itemGuid = UIDefine.GetParameterItemGuid(parameter)
        local itemId = nil
        local matchrule = "itemId:(%d+)"
        itemId = string.match(parameter, matchrule)
        local bagType = nil
        matchrule = "bagType:(%d+)"
        bagType = string.match(parameter, matchrule)
        if index1 > 0 then
            EquipUI.SetTabIndex(index1)
        else
            EquipUI.SetTabIndex(1)
        end
        if tabList[EquipUI.tabIndex] then
            -- if index2 > 0 then
            --     EquipUI.tabSubIndex = #(tabList[EquipUI.tabIndex][6].txt) + 1 - index2
            -- else
            --     EquipUI.tabSubIndex = tabList[EquipUI.tabIndex][6].def
            -- end
            if index2 > 0 then
                EquipUI.tabSubIndex = index2
            end
        end
        if itemGuid then
            EquipUI.CheckItemGuid = itemGuid
        else
            EquipUI.CheckItemGuid = 0
        end
        if itemId then
            EquipUI.CheckItemId = tonumber(itemId)
        else
            EquipUI.CheckItemId = 0
        end
        if bagType then
            EquipUI.CheckBagType = tonumber(bagType)
        else
            EquipUI.CheckBagType = 0
        end
        UILayout.OnTabClick(EquipUI.tabIndex, tabList)
        EquipUI.RefreshSubTab(EquipUI.tabSubIndex)
    else
        EquipUI.OnTabEquipBtnClick()
    end
    EquipUI.RefreshGuardGroup(EquipUI.curGuardGuid)
end
--创建顶部按钮
function EquipUI.CreateTopRightBtn()
    local pbg = guidt.GetUI("panelBg")
    local w = GUI.GetWidth(pbg)
    local h = GUI.GetHeight(pbg)
    local bg = GUI.GroupCreate(pbg, "EquipTop", 0, 0, w, h)
    guidt.BindName(bg, "EquipTop")
    for i = 1, #StaticSubTabList do
        local btn =
            GUI.CheckBoxExCreate(
            bg,
            "btn" .. i,
            StaticSubTabList[i][1],
            StaticSubTabList[i][2],
            StaticSubTabList[i][4],
            StaticSubTabList[i][5],
            false,
            StaticSubTabList[i][6],
            StaticSubTabList[i][7]
        )
        local txt = GUI.CreateStatic(btn, "txt", "", 0, 0, StaticSubTabList[i][6], StaticSubTabList[i][7])
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
        GUI.SetScale(txt, UIDefine.FontSizeM2FontSizeXL)
        GUI.SetColor(txt, UIDefine.BrownColor)

        guidt.BindName(txt, "TopRightTxt" .. i)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "EquipUI", StaticSubTabList[i][3])
        guidt.BindName(btn, "TopRightBtn" .. i)
	end
    local check = GUI.CheckBoxExCreate(bg, "bindBtn", "1800607150", "1800607151", -190, -240, false, 40, 40)
    guidt.BindName(check, "bindBtn")
    GUI.CheckBoxExSetCheck(check, false)
    local txt = GUI.CreateStatic(check, "bindText", "优先使用非绑材料", 123, 0, 200, 35)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
    GUI.SetColor(txt, UIDefine.BrownColor)
end
--创建装备界面装备子页签底部消耗相关ui
function EquipUI.CreateEquipBottom()
    local pbg = guidt.GetUI("panelBg")
    local w = GUI.GetWidth(pbg)
    local h = GUI.GetHeight(pbg)
    local bg = GUI.GroupCreate(pbg, "EquipBottom", 0, 0, w, h)
    guidt.BindName(bg, "EquipBottom")
    local consumeText = GUI.CreateStatic(bg, "consumeText", "消耗", -180, 265, 100, 30)
    GUI.SetColor(consumeText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(consumeText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleCenter)
    guidt.BindName(consumeText, "consumeText")

    local consumeBg = GUI.ImageCreate(bg, "consumeBg", "1800700010", -50, 266, false, 180, 35)
    local coin = GUI.ImageCreate(consumeBg, "coin", "1800408280", -74, -1, false, 36, 36)
    guidt.BindName(consumeBg, "consumeBg")
    local num = GUI.CreateStatic(consumeBg, "num", "100", 0, 0, 160, 30)
    GUI.SetColor(num, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
    GUI.SetAnchor(num, UIAnchor.Center)
    GUI.SetPivot(num, UIAroundPivot.Center)
    GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)

    local rateText = GUI.CreateStatic(bg, "rateText", "成功率", 105, 265, 100, 30)
    GUI.SetColor(rateText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(rateText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(rateText, TextAnchor.MiddleCenter)
    guidt.BindName(rateText, "rateText")

    local rateNum = GUI.CreateStatic(bg, "rateNum", "100%", 145, 265, 100, 30)
    GUI.SetColor(rateNum, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(rateNum, UIDefine.FontSizeL)
    GUI.SetPivot(rateNum, UIAroundPivot.Left)
    guidt.BindName(rateNum, "rateNum")

    local luckText = GUI.CreateStatic(bg, "luckText", "幸运", 250, 265, 100, 30)
    GUI.SetColor(luckText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(luckText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(luckText, TextAnchor.MiddleCenter)
    guidt.BindName(luckText, "luckText")

    local luckNum = GUI.CreateStatic(bg, "luckNum", "100%", 278, 265, 100, 30)
    GUI.SetColor(luckNum, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(luckNum, UIDefine.FontSizeL)
    GUI.SetPivot(luckNum, UIAroundPivot.Left)
    guidt.BindName(luckNum, "luckNum")
    local btns = {
        "enhanceBtn",
        "btn2"
    }
    for i = 1, #btns do
        local enhanceBtn =
            GUI.ButtonCreate(
            bg,
            btns[i],
            "1800002060",
            436 - (i - 1) * 180,
            265,
            Transition.ColorTint,
            "强化",
            160,
            50,
            false
        )
        guidt.BindName(enhanceBtn, btns[i])
        if i == 1 then
            GUI.SetEventCD(enhanceBtn, UCE.PointerClick, 0.5)
        end
        GUI.ButtonSetTextColor(enhanceBtn, UIDefine.WhiteColor)
        GUI.ButtonSetTextFontSize(enhanceBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetOutLineArgs(enhanceBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
        if i == 2 then
            GUI.SetVisible(enhanceBtn, false)
        end
    end
    local vpText = GUI.CreateStatic(bg, "vpText", "活力", 110, 265, 100, 30)
    GUI.SetColor(vpText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(vpText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(vpText, TextAnchor.MiddleCenter)
    guidt.BindName(vpText, "vpText")
    local vpBg = GUI.ImageCreate(bg, "vpBg", "1800700010", 240, 266, false, 180, 35)
    local vpNum = GUI.CreateStatic(vpBg, "vpNum", "10/1000", 0, -2, 160, 30)
    GUI.SetColor(vpNum, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(vpNum, UIDefine.FontSizeM)
    GUI.SetAnchor(vpNum, UIAnchor.Center)
    GUI.SetPivot(vpNum, UIAroundPivot.Center)
    GUI.StaticSetAlignment(vpNum, TextAnchor.MiddleCenter)
    guidt.BindName(vpBg, "vpBg")
    guidt.BindName(vpNum, "vpNum")
end
--创建装备界面装备子页签
function EquipUI.CreateEquipPage(panelBg)
    local equipPage = GUI.GroupCreate(panelBg, tabList[1][4], 0, 0, 0, 0)
    local bg = GUI.ImageCreate(equipPage, "bg", "1801100100", 155, 10, false, 740, 460)
    guidt.BindName(equipPage, "equipPage")
    guidt.BindName(bg, "bg")
    -- UILayout.CreateSubTab(equipSubTabList, equipPage, "EquipUI")
    EquipUI.CreateEquipBottom()
    EquipUI.CreateTopRightBtn()
    -- local hintBtn = GUI.ButtonCreate(equipPage, "hintBtn", "1800702030", 480, 200, Transition.ColorTint)
    -- GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "EquipUI", "OnHintBtnClick")
    for i = 1, #equipSubTableUI do
        equipSubTableUI[i].CreateSubPage(equipPage)
    end
end

function EquipUI.CreateGemPage(panelBg)
    local gemPage = GUI.GroupCreate(panelBg, tabList[defGemPage][4], 0, 0, 0, 0)

    for i = 1, #gemSubTableUI do
        gemSubTableUI[i].CreateSubPage(gemPage)
    end
end

function EquipUI.OnTabEquipBtnClick()
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(tabList[1][1])
	local Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		EquipUI.SetTabIndex(defEquipPage)
		UILayout.OnTabClick(EquipUI.tabIndex, tabList)
		EquipUI.RefreshSubTab()
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(EquipUI.tabIndex, tabList)
		return
	end
	
end

function EquipUI.OnTabEnchantBtnClick()
    EquipUI.SetTabIndex(3)
    UILayout.OnTabClick(EquipUI.tabIndex, tabList)
end
function EquipUI.OnTabQuenchBtnClick()
    EquipUI.SetTabIndex(defQuenchPage)
    UILayout.OnTabClick(EquipUI.tabIndex, tabList)
    EquipUI.RefreshSubTab()
end
function EquipUI.OnTabGrowUpBtnClick()
    EquipUI.SetTabIndex(defGrowUpPage)
    UILayout.OnTabClick(EquipUI.tabIndex, tabList)
    EquipUI.RefreshSubTab()
end
function EquipUI.OnTabSuitBtnClick()
    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	local Key = tostring(tabList[4][1])
	local Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		EquipUI.SetTabIndex(defSuitPage)
		UILayout.OnTabClick(EquipUI.tabIndex, tabList)
		EquipUI.RefreshSubTab()
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(EquipUI.tabIndex, tabList)
		return
	end
end

--洗灵页签点击事件
function EquipUI.OnTabSoulWashingBtnClick()
    test("洗灵页签点击事件")

    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Key = tostring(tabList[5][1])
    local Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel[Key]
    if CurLevel >= Level then
        EquipUI.SetTabIndex(defSoulWashingPage)
        UILayout.OnTabClick(EquipUI.tabIndex, tabList)
        EquipUI.RefreshSubTab()
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
        UILayout.OnTabClick(EquipUI.tabIndex, tabList)
        return
    end

end

function EquipUI.OnTabRefineBtnClick()
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(tabList[3][1])
	local Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		EquipUI.SetTabIndex(defRefinePage)
		UILayout.OnTabClick(EquipUI.tabIndex, tabList)
		EquipUI.RefreshSubTab()
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(EquipUI.tabIndex, tabList)
		return
	end
end

function EquipUI.OnTabGemBtnClick()
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(tabList[2][1])
    test("Key",Key)
	local Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		EquipUI.SetTabIndex(defGemPage)
		UILayout.OnTabClick(EquipUI.tabIndex, tabList)
		EquipUI.RefreshSubTab()
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(EquipUI.tabIndex, tabList)
		return
	end
end
function EquipUI.OnSubTabBtnClick(guid)
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
    for i = 1, #StaticSubTabList do
        local cur = guidt.GetUI("TopRightBtn" .. i)
        if guid == guidt.GetGuid("TopRightBtn" .. i) then
			local Key = tabList[EquipUI.tabIndex][6].txt[i]
			local Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel_2[Key]
            if Level == nil then
                Level = 1
            end
			if CurLevel >= Level then
				GUI.CheckBoxExSetCheck(cur, true)
				tabList[EquipUI.tabIndex][6].onClick[i]()

                lastSelectSubTabGuid = tostring(guid)

			else
				CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
				GUI.CheckBoxExSetCheck(cur, false)

                local lastSelectSubTabItem = GUI.GetByGuid(lastSelectSubTabGuid)
                GUI.CheckBoxExSetCheck(lastSelectSubTabItem, true)

				return
			end
        else
            GUI.CheckBoxExSetCheck(cur, false)
        end
    end
	
end

---@param consumeMax number @comment 消耗道具数量
---@param itemIds number[] @comment 道具id数组
---@param keyNames number[] @comment 道具keyname数组
---@param consumeXPos table[] @comment uiX坐标
function EquipUI.RefreshConsumeItem(consumeMax, itemIds, keyNames, consumeXPos)
    local consumeNum = 0
    local notnil = (itemIds ~= nil and keyNames ~= nil)
    for i = 1, consumeMax do
        local item = EquipUI.guidt.GetUI("consumeItem" .. i)
        local info = itemIds
        if notnil and i <= #info then
            consumeNum = consumeNum + 1
            GUI.SetVisible(item, true)
            ItemIcon.BindItemIdWithNum(item, info[i], 1)
            local name = GUI.GetChild(item, "name", false)
            local check = GUI.GetChild(item, "check", false)
            GUI.SetVisible(check, false)
            local iteminfo = DB.GetItem(itemIds[i], keyNames[i])
            if iteminfo ~= nil and iteminfo.Id > 0 then
                GUI.StaticSetText(name, iteminfo.Name)
            end
        else
            GUI.SetVisible(item, false)
        end
    end
    for i = 1, consumeNum do
        local item = EquipUI.guidt.GetUI("consumeItem" .. i)
        GUI.SetPositionX(item, consumeXPos[consumeNum][i])
    end
end
---@param consumeMax number @comment 消耗道具数量
---@param items eqiupItem[] @comment 道具数组
---@param consumeXPos table[] @comment uiX坐标
---@param checkBoxIndex number @comment 从第几个元素开始出现选择框
---@param checkIsOn bool[] @comment 选择框开关
function EquipUI.RefreshConsumeItemEx(consumeMax, items, consumeXPos, checkBoxIndex, checkIsOn)
    local consumeNum = 0
    local notnil = (items ~= nil)
    for i = 1, consumeMax do
        local item = EquipUI.guidt.GetUI("consumeItem" .. i)
        local info = items
        if notnil and i <= #info then
            consumeNum = consumeNum + 1
            GUI.SetVisible(item, true)
            -- print(info[i].id)
            -- print(info[i].count)
            ItemIcon.BindItemIdWithNum(item, info[i].id, info[i].count)
            local name = GUI.GetChild(item, "name", false)
            local check = GUI.GetChild(item, "check", false)
            if checkBoxIndex and i >= checkBoxIndex then
                GUI.SetVisible(check, true)
                if checkIsOn then
                    GUI.CheckBoxExSetCheck(check, true)
                else
                    GUI.CheckBoxExSetCheck(check, false)
                end
            else
                GUI.SetVisible(check, false)
            end
            local iteminfo = DB.GetItem(info[i].id, info[i].keyname)
            if iteminfo ~= nil and iteminfo.Id > 0 then
                GUI.StaticSetText(name, iteminfo.Name)
            end
        else
            GUI.SetVisible(item, false)
        end
    end
    for i = 1, consumeNum do
        local item = EquipUI.guidt.GetUI("consumeItem" .. i)
        --郑  修改前
        --GUI.SetPositionX(item, consumeXPos[consumeNum][i])
        --
        --郑  修改后
        if consumeNum == i then
            GUI.SetPositionX(item, consumeXPos[consumeNum][i])
        else
            GUI.SetPositionX(item, consumeXPos[consumeNum][i]+30)
        end
        --
    end
end

function EquipUI.RefreshConsumeCoin(coin_type, coin_count)
    local bg = guidt.GetUI("consumeBg")
    local consumeText = guidt.GetUI("consumeText")
    GUI.SetVisible(bg, true)
    GUI.SetVisible(consumeText, true)

    local coin = GUI.GetChild(bg, "coin", false)
    local num = GUI.GetChild(bg, "num", false)
    test(tostring(CL.GetAttr(coin_type)))
    test(coin_count)
    local l, h = int64.longtonum2(CL.GetAttr(coin_type))
    local curnum = l
    if curnum < coin_count then
        GUI.SetColor(num, UIDefine.RedColor)
    else
        GUI.SetColor(num, UIDefine.WhiteColor)
    end
    GUI.ImageSetImageID(coin, UIDefine.AttrIcon[coin_type])
    GUI.StaticSetText(num, tostring(coin_count))
end
---@param data EquipData
function EquipUI.SelectBagType(data)
    if #data.items[EquipEnhanceUI.typeList[data.type][12]] == 0 then
        if data.type == 1 then
            data.type = 2
        else
            data.type = 1
        end
        if #data.items[EquipEnhanceUI.typeList[data.type][12]] == 0 then
            data.type = 1
        end
    end
end

-- 获取装备数据 (ItemDataEx)
function EquipUI.GetEquipData(equipGuid, bagType, site)
    if EquipUI.curGuardGuid and bagType == item_container_type.item_container_equip then
        return LD.GetItemDataByIndex(site, item_container_type.item_container_guard_equip, EquipUI.curGuardGuid)
    else
        return LD.GetItemDataByGuid(equipGuid, bagType)
    end
end

function EquipUI.OnClose()
    CL.UnRegisterMessage(GM.RefreshBag, "EquipUI", "BindData")
    CL.UnRegisterMessage(GM.AddNewItem, "EquipProduceUI", "AddEquipItem")
    EquipProduceUI.NewItemGuid = nil
    EquipProduceUI.OnExitGame()
    EquipUI.curGuardGuid = nil
    EquipUI.tabSubIndex = 1
    EquipUI.tabIndex = 1
    for i = 1, #attrT do
        CL.UnRegisterAttr(attrT[i], EquipUI.NotifyRoleData)
    end
end

function EquipUI.RefreshGuardGroup(guardGuid)
    test(tostring(guardGuid))
    local group = guidt.GetUI("guardGroup")
    local titleText = guidt.GetUI("titleText")
    if not guardGuid then
        GUI.StaticSetText(titleText, "装    备")
        GUI.SetVisible(group, false)
        return
    end
    GUI.StaticSetText(titleText, "侍从装备")
    local guardData = LD.GetGuardData(guardGuid)
    if not guardData then
        GUI.SetVisible(group, false)
        return
    end
    EquipUI.curGuardGuid = guardGuid
    EquipUI.BindData()
    GUI.SetVisible(group, true)
    local guardGradeSprite = guidt.GetUI("guardGradeSprite")
    local guardName = guidt.GetUI("guardName")
    local guardIcon = guidt.GetUI("guardIcon")
    local guardId = tonumber(tostring(LogicDefine.GetAttrFromFreeList(guardData.attrs, RoleAttr.RoleAttrRole)))
    local guardDB = DB.GetOnceGuardByKey1(guardId)
    GUI.ImageSetImageID(guardGradeSprite, UIDefine.ItemIconBg[guardDB.Grade])
    GUI.ImageSetImageID(guardIcon, tostring(guardDB.Head))
    GUI.StaticSetText(guardName, guardDB.Name)
end
function EquipUI.SendNotify(fromName, ...)
    -- if EquipUI.curGuardGuid then
    --     CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", fromName, ..., EquipUI.curGuardGuid)
    -- else
    CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", fromName, ...)
    -- end
end

function EquipUI.BagOpenUI(param)
    EquipUI.OnSubTabBtnClick(guidt.GetGuid("TopRightBtn" .. param))
end

function EquipUI.CheckEquipRedPoint()
    local tabdata1 = tabList[1]
    local tabdata2 = tabList[2]
    local tabbtn1 = GUI.GetByGuid(tabdata1.btnGuid)
    local tabbtn2 = GUI.GetByGuid(tabdata2.btnGuid)
    local btn1 = guidt.GetUI("TopRightBtn1")
    local btn2 = guidt.GetUI("TopRightBtn2")
    local btn3 = guidt.GetUI("TopRightBtn3")

    local CurLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
	local EquipSubList = {"打造","强化","合成","镶嵌"}
	local EquipHideList = {"EquipCreat","EquipIntensify","EquipGem","EquipGem"}
	local EquipSubLevelEnough = {false,false,false,false}

	for i = 1, #EquipSubList, 1 do
		local Key = EquipSubList[i]
		local Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel_2[Key]
		local hide = UIDefine.FunctionSwitch[EquipHideList[i]] == "on"
		if CurLevel >= Level and hide then
			EquipSubLevelEnough[i] = true
		end
	end

    -- local inspect = require("inspect")
    -- print(inspect(GlobalProcessing.EquipGemInlayUI.CheckRedPoint_TB))
    local eqiupPoroduceFlag = GlobalProcessing.isEquipProduceShowRedPoint and EquipSubLevelEnough[1]
    local eqiupEnhanceFlag = GlobalProcessing.isEquipEnhanceShowRedPoint and EquipSubLevelEnough[2]
    local gemMergFlag = GlobalProcessing.isEquipGemMergShowRedPoint and EquipSubLevelEnough[3]
    local gemInlayFlag = GlobalProcessing.isEquipGemInlayShowRedPoint and EquipSubLevelEnough[4]
    GUI.SetRedPointVisable(tabbtn1, eqiupPoroduceFlag or eqiupEnhanceFlag)
    GUI.SetRedPointVisable(tabbtn2, gemMergFlag or gemInlayFlag)

    EquipProduceUI.CheckRedPoint()
    EquipEnhanceUI.CheckRedPoint()
    EquipGemMergeUI.CheckRedPoint()
    EquipGemInlayUI.CheckRedPoint()

    if EquipUI.tabIndex == 1 then
        GlobalProcessing.SetRetPoint(btn1, false)
        GlobalProcessing.SetRetPoint(btn2, eqiupPoroduceFlag)
        GlobalProcessing.SetRetPoint(btn3, eqiupEnhanceFlag)
    elseif EquipUI.tabIndex == 2 then
        GlobalProcessing.SetRetPoint(btn1, gemMergFlag)
        GlobalProcessing.SetRetPoint(btn2, gemInlayFlag)
        GlobalProcessing.SetRetPoint(btn3, false)
    else
        GlobalProcessing.SetRetPoint(btn1, false)
        GlobalProcessing.SetRetPoint(btn2, false)
        GlobalProcessing.SetRetPoint(btn3, false)
    end

    if EquipUI.tabIndex == 4 and EquipUI.tabSubIndex == 1 then
        EquipSuitUI.RefreshProduce()
    end

	local TB = {tostring(eqiupPoroduceFlag),tostring(eqiupEnhanceFlag),tostring(gemMergFlag),tostring(gemInlayFlag)}
	GlobalProcessing.Equip_DataLoading(TB, false)
end