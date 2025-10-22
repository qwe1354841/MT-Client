local MallUI = {
    ---@type Mall_Currency[]
    Currency_Tab = {},
    OnRefreshItemScroll = nil,
    OnClickLeftItemScroll = nil,
    ---@type table<number,table<number,string>>
    Version = {},
    ---@type table<string,table<string,Classify_Item[]>>
    Currency_Classify_Item = {}
}
_G.MallUI = MallUI
require "RechargeUI"

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

MallUI.parameter = nil

local Brown4Color = UIDefine.Brown4Color

local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local guidt = UILayout.NewGUIDUtilTable()

local panelBgPath = "MallUI/panelBg"

local tabList = {
    {"金元", "tabList1", "OnTabBtnClick", "mallBuyPage", panelBgPath .. "/mallBuyPage"},
    {"充值", "rechargeTabBtn", "OnTabBtnClick", "rechargePage", panelBgPath .. "/rechargePage"}
}

local mallBuySubTabList = {}
local newMallBuySubTabList = {}

local lastCheckBoxGuid = nil-- mallBuySubTabList[1] ={"功能道具", "mallBuySubTab1", "1800402180", "1800402181", "OnMalllBuySubTabClick", -450, -245, 135, 50, 100, 35},
    -- -- {"宝石打造", "mallBuySubTab2", "1800402180", "1800402181", "OnMalllBuySubTabClick", -315, -245, 135, 50, 100, 35},
    -- -- {"武功秘籍", "mallBuySubTab3", "1800402180", "1800402181", "OnMalllBuySubTabClick", -180, -245, 135, 50, 100, 35},
    -- -- {"灵丹妙药", "mallBuySubTab4", "1800402180", "1800402181", "OnMalllBuySubTabClick", -45, -245, 135, 50, 100, 35},
    -- -- {"奇珍异宝", "mallBuySubTab5", "1800402180", "1800402181", "OnMalllBuySubTabClick", 90, -245, 135, 50, 100, 35}
-- }
function MallUI.InitData()
    MallUI.Version = {}
    for i = 2, #tabList do
        tabList[i] = nil
    end
    -- for i = 2, #mallBuySubTabList do
        -- mallBuySubTabList[i] = nil
    -- end
    MallUI.Currency_Tab = {}
	MallUI.FirstClick = {}
    return {
        tabIndex = 1,
        tabSubIndex = 1,
        index = 1,
        indexGuid = int64.new(0),
        num = 1,
		Item_index = 1,
        ---@type table<string,table<string,Classify_Item[]>>
        Currency_Classify_Item = {},
		GoodsNum = {},
        indexName = ""
    }
end
local data = MallUI.InitData()
function MallUI.Main(parameter)
	--print("MallUI.Main(parameter) = "..tostring(parameter))
	data.tabIndex = 1
    data.tabSubIndex = 1
    data.index = 1
    --MallUI._go_to_precise(parameter)
	CL.SendNotify(NOTIFY.SubmitForm, "FormMall", "GetAllData")
    guidt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("MallUI", "MallUI", 0, 0)
	local panelBg = UILayout.CreateFrame_WndStyle0(panel, "商    城", "MallUI", "OnExit")
	guidt.BindName(panelBg, "panelBg")
	MallUI.CreateMallBuyPage()
	RechargeUI.Create(panelBg)
	--MallUI.RefreshUI()
	MallUI.BindData()
	GameMain.AddListen("MallUI", "OnExitGame")
end
function MallUI.OnExit()
    GUI.CloseWnd("MallUI")
end
--初始化数据
function MallUI.BindData()
    MallUI.GetTabData()
end

--打开界面的时候调用
function MallUI.OnShow(parameter)
	--print("MallUI.OnShow(parameter) = "..tostring(parameter))
    local wnd = GUI.GetWnd("MallUI")
    if wnd then
		if not data.num then
			data.num = 1
		else
			data.num = 1
		end
		if parameter then
			MallUI.parameter = parameter
			MallUI._go_to_precise(parameter)
			if MallUI._parameter then
				data.tabIndex = tonumber(MallUI._parameter[1])
				if not data.tabIndex then
					data.tabIndex = 1
				end
				data.tabSubIndex = tonumber(MallUI._parameter[2])
				if not data.tabSubIndex then
					data.tabSubIndex = 1
				end
				data.index = tonumber(MallUI._parameter[3])
				if not data.index then
					data.index = 1
				end
				data.state = 1   --用于判断是否需要调整scroll位置
				if not MallUI.FirstClick[tostring(data.tabIndex)..tostring(data.tabSubIndex)] then
					if data.tabIndex == #MallUI.Currency_Tab + 1 then
						MallUI.FirstClick[tostring(data.tabIndex)..tostring(data.tabSubIndex)] = 1
						MallUI.RefreshUI()
						MallUI.parameter = nil
					else
						MallUI.GetDataByTab()
					end
				else
					MallUI.RefreshUI()
					MallUI.parameter = nil
				end
				MallUI._parameter = nil
			else
				local a, b = UIDefine.GetParameterStr(parameter)
				data.indexName = a
				MallUI.parameter = nil
				MallUI.ClientRefreshTab()
			end
		else
			data.tabIndex = 1
			data.tabSubIndex = 1
			data.index = 1
			data.state = 0
			if not MallUI.FirstClick[tostring(data.tabIndex)..tostring(data.tabSubIndex)] then
				MallUI.GetDataByTab()
			else
				MallUI.RefreshUI()
			end
			for i = 1, #tabList do
				for j = 1, 5 do
					local itemScroll = guidt.GetUI("itemScroll_"..tostring(i).."_"..tostring(j))
					if itemScroll then
						GUI.LoopScrollRectSrollToCell(itemScroll, 0, 0)
					end
				end
			end
		end
        GUI.SetVisible(wnd, true)
    end
	for key, value in pairs(MallUI.Currency_Tab) do
		CL.RegisterAttr(UIDefine.GetMoneyEnum(value.Money_Type), MallUI.UpdateMoneyValue)
	end
end
function MallUI.OnDestroy()
    MallUI.OnClose()
	data = MallUI.InitData()
end
function MallUI.OnClose()
	for key, value in pairs(MallUI.Currency_Tab) do
		CL.UnRegisterAttr(UIDefine.GetMoneyEnum(value.Money_Type), MallUI.UpdateMoneyValue)
	end
    if MallUI.moneyTimer ~= nil then
        MallUI.moneyTimer:Stop()
        MallUI.moneyTimer = nil
    end
end
function MallUI.UpdateMoneyValue(attrType, value)
    if MallUI.moneyTimer == nil then
        MallUI.moneyTimer = Timer.New(MallUI.RefreshUI, 0.2, false)
    end
    MallUI.moneyTimer:Stop()
    MallUI.moneyTimer:Start()
end
function MallUI.GetTabData()
	--print("MallUI.GetTabData()")
	CL.SendNotify(NOTIFY.SubmitForm, "FormMall", "GetData")
end
function MallUI.GetDataByTab(Tabs_index, Classify_index)
	--print("MallUI.GetDataByTab(Tabs_index, Classify_index)",tostring(Tabs_index),tostring(Classify_index))
    if Tabs_index == nil then
        Tabs_index = data.tabIndex and tonumber(data.tabIndex) or 1
    end
    if Classify_index == nil then
        Classify_index = data.tabSubIndex and tonumber(data.tabSubIndex) or 1
    end
    if Tabs_index and Classify_index then
        local items = MallUI.GetItemDatas(Tabs_index, Classify_index)
        CL.SendNotify(
            NOTIFY.SubmitForm,
            "FormMall",
            "Item_Info",
            #items > 0 and MallUI.Version[Tabs_index][Classify_index] or 0,
            Tabs_index,
            Classify_index
        )
    end
end
function MallUI.SendBuy(tabIndex, subTabIndex, itemIndex, num)
    if tabIndex == nil then
        tabIndex = data.tabIndex
    end
    if subTabIndex == nil then
        subTabIndex = data.tabSubIndex
    end
    if itemIndex == nil then
        itemIndex = data.Item_index
    end
    if num == nil then
        num = data.num
    end

    CL.SendNotify(
        NOTIFY.SubmitForm,
        "FormMall",
        "Purchase",
        MallUI.Version[tabIndex][subTabIndex],
        tabIndex,
        subTabIndex,
        itemIndex,
        num
    )
end
--刷新界面
function MallUI.RefreshUI()
    --if not GUI.GetWnd("MallUI") then
    --    return
    --end
	data.tabIndex = tonumber(data.tabIndex)
	if not data.tabIndex then
		data.tabIndex = 1
		print("RefreshUI   data.tabIndex错误")
	end
	data.tabSubIndex = tonumber(data.tabSubIndex)
	if not data.tabSubIndex then
		data.tabSubIndex = 1
		print("RefreshUI   data.tabSubIndex错误")
	end
	UILayout.CreateRightTab(tabList, "MallUI")
	local mallBuyPage = guidt.GetUI("mallBuyPage")

	MallUI.SetNewMallBuySubTabListData()
	local topClassifyLoop = guidt.GetUI("topClassifyLoop")
	GUI.LoopScrollRectSetTotalCount(topClassifyLoop, #newMallBuySubTabList)
	GUI.LoopScrollRectSrollToCell(topClassifyLoop,data.tabSubIndex - 1 ,2000)
	GUI.LoopScrollRectRefreshCells(topClassifyLoop)

	local rightTag = guidt.GetUI("rightTag")
	GUI.SetVisible(rightTag, data.tabSubIndex - 1 < 5)

	local leftTag = guidt.GetUI("leftTag")
	GUI.SetVisible(leftTag, data.tabSubIndex - 1 > 0)

	if mallBuySubTabList[data.tabIndex] then
		--test("mallBuySubTabList---------------------",inspect(mallBuySubTabList))
		--UILayout.CreateSubTab(mallBuySubTabList[data.tabIndex], mallBuyPage, "MallUI")
		--UILayout.OnSubTabClick(data.tabSubIndex, mallBuySubTabList[1])
	end
	UILayout.OnTabClick(data.tabIndex, tabList)
    for i = 1, #tabList do
        if i ~= data.tabIndex then
            local page = GUI.Get(tabList[i][5])
            GUI.SetVisible(page, false)
			for j = 1, #newMallBuySubTabList do
				local itemScroll = guidt.GetUI("itemScroll_"..tostring(i).."_"..tostring(j))
				if not itemScroll then
					local ItemScrollBg = guidt.GetUI("ItemScrollBg")
					itemScroll = GUI.LoopScrollRectCreate(ItemScrollBg, "itemScroll_"..tostring(i).."_"..tostring(j), 0, 0, 670, 480, "MallUI", "CreatItemPool_"..tostring(i).."_"..tostring(j), "MallUI", "RefreshItemScroll_"..tostring(i).."_"..tostring(j), 0, false, Vector2.New(320, 100), 2, UIAroundPivot.Top, UIAnchor.Top)
					GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(6, 6))
					guidt.BindName(itemScroll, "itemScroll_"..tostring(i).."_"..tostring(j))
				end
				GUI.SetVisible(itemScroll, false)
			end
        else
			for j = 1, #newMallBuySubTabList do
				local itemScroll = guidt.GetUI("itemScroll_"..tostring(i).."_"..tostring(j))
				if not itemScroll then
					local ItemScrollBg = guidt.GetUI("ItemScrollBg")
					itemScroll = GUI.LoopScrollRectCreate(ItemScrollBg, "itemScroll_"..tostring(i).."_"..tostring(j), 0, 0, 670, 480, "MallUI", "CreatItemPool_"..tostring(i).."_"..tostring(j), "MallUI", "RefreshItemScroll_"..tostring(i).."_"..tostring(j), 0, false, Vector2.New(320, 100), 2, UIAroundPivot.Top, UIAnchor.Top)
					GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(6, 6))
					guidt.BindName(itemScroll, "itemScroll_"..tostring(i).."_"..tostring(j))
				end
				if j ~= data.tabSubIndex then
					GUI.SetVisible(itemScroll, false)
				else
					GUI.SetVisible(itemScroll, true)
				end
			end
		end
    end
	if tabList[data.tabIndex] then
		if tabList[data.tabIndex][1] == "充值" then
			RechargeUI.Refresh()
		else
			local ItemNum = #MallUI.GetItemDatas()
			if ItemNum then
				local itemScroll = guidt.GetUI("itemScroll_"..tostring(data.tabIndex).."_"..tostring(data.tabSubIndex))
				if not itemScroll then
					local ItemScrollBg = guidt.GetUI("ItemScrollBg")
					itemScroll = GUI.LoopScrollRectCreate(ItemScrollBg, "itemScroll_"..tostring(i).."_"..tostring(j), 0, 0, 670, 480, "MallUI", "CreatItemPool_"..tostring(i).."_"..tostring(j), "MallUI", "RefreshItemScroll_"..tostring(i).."_"..tostring(j), 0, false, Vector2.New(320, 100), 2, UIAroundPivot.Top, UIAnchor.Top)
					GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(6, 6))
					guidt.BindName(itemScroll, "itemScroll_"..tostring(i).."_"..tostring(j))
				end
				if itemScroll then
					if not data.GoodsNum[tostring(data.tabIndex).."_"..tostring(data.tabSubIndex)] then
						data.GoodsNum[tostring(data.tabIndex).."_"..tostring(data.tabSubIndex)] = 0
					end
					if data.GoodsNum[tostring(data.tabIndex).."_"..tostring(data.tabSubIndex)] and data.GoodsNum[tostring(data.tabIndex).."_"..tostring(data.tabSubIndex)] ~= ItemNum then
						GUI.LoopScrollRectSetTotalCount(itemScroll, ItemNum)
					end
					--GUI.LoopScrollRectSetTotalCount(itemScroll, ItemNum)
					GUI.LoopScrollRectRefreshCells(itemScroll)
					--GUI.LoopScrollRectSrollToCell(itemScroll, 0, 0)
					GUI.SetVisible(itemScroll, true)
					local x,y = GUI.GetNormalizedPosition(itemScroll):Get()				--用于判断是否需要调整scroll位置
					if data.state == 1 then
						--print("开始调整scroll位置")
						data.index = tonumber(data.index) or 1
						GUI.ScrollRectSetNormalizedPosition(itemScroll,Vector2.New(0, (data.index-1)/ItemNum))
						--data.state = 0
					elseif x ~= 1 and data.state == 0 then
						GUI.LoopScrollRectSrollToCell(itemScroll, 0, 0)
					end
				else
					print("没有Scroll，生成时出错")
				end
				data.GoodsNum[tostring(data.tabIndex).."_"..tostring(data.tabSubIndex)] = ItemNum
				MallUI.RefreshInfo()
			end
		end
	end
	if tabList[data.tabIndex] then
		local curPage = GUI.Get(tabList[data.tabIndex][5])
		if curPage then
			GUI.SetVisible(curPage, true)
		end
	end
	if MallUI._parameter then
		MallUI._parameter = nil
	end
end

--创建金元(金砖)界面
function MallUI.CreateMallBuyPage()
    local panelBg = guidt.GetUI("panelBg")
    local mallBuyPage = GUI.GroupCreate(panelBg, tabList[1][4], 0, 0, 0, 0)
    guidt.BindName(mallBuyPage, "mallBuyPage")
	GUI.SetVisible(mallBuyPage, false)

	local ItemScrollBg = GUI.ImageCreate(mallBuyPage, "ItemScrollBg", "1800400010", -180, 30, false, 670, 500)
	guidt.BindName(ItemScrollBg, "ItemScrollBg")


	--创建循环列表，共10项 为了切换时不会出现明显的刷新迹象

	--local itemScroll_1_1 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_1_1",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_1_1",
	--	"MallUI",
	--	"RefreshItemScroll_1_1",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_1_1, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_1_1, "itemScroll_1_1")
	--
	--local itemScroll_1_2 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_1_2",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_1_2",
	--	"MallUI",
	--	"RefreshItemScroll_1_2",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_1_2, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_1_2, "itemScroll_1_2")
	--
	--local itemScroll_1_3 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_1_3",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_1_3",
	--	"MallUI",
	--	"RefreshItemScroll_1_3",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_1_3, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_1_3, "itemScroll_1_3")
	--
	--local itemScroll_1_4 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_1_4",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_1_4",
	--	"MallUI",
	--	"RefreshItemScroll_1_4",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_1_4, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_1_4, "itemScroll_1_4")
	--
	--local itemScroll_1_5 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_1_5",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_1_5",
	--	"MallUI",
	--	"RefreshItemScroll_1_5",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_1_5, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_1_5, "itemScroll_1_5")
	--
	--local itemScroll_2_1 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_2_1",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_2_1",
	--	"MallUI",
	--	"RefreshItemScroll_2_1",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_2_1, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_2_1, "itemScroll_2_1")
	--
	--local itemScroll_2_2 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_2_2",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_2_2",
	--	"MallUI",
	--	"RefreshItemScroll_2_2",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_2_2, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_2_2, "itemScroll_2_2")
	--
	--local itemScroll_2_3 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_2_3",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_2_3",
	--	"MallUI",
	--	"RefreshItemScroll_2_3",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_2_3, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_2_3, "itemScroll_2_3")
	--
	--local itemScroll_2_4 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_2_4",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_2_4",
	--	"MallUI",
	--	"RefreshItemScroll_2_4",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_2_4, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_2_4, "itemScroll_2_4")
	--
	--local itemScroll_2_5 =
	--	GUI.LoopScrollRectCreate(
	--	ItemScrollBg,
	--	"itemScroll_2_5",
	--	0,
	--	0,
	--	670,
	--	480,
	--	"MallUI",
	--	"CreatItemPool_2_5",
	--	"MallUI",
	--	"RefreshItemScroll_2_5",
	--	0,
	--	false,
	--	Vector2.New(320, 100),
	--	2,
	--	UIAroundPivot.Top,
	--	UIAnchor.Top
	--)
	--GUI.ScrollRectSetChildSpacing(itemScroll_2_5, Vector2.New(6, 6))
	--guidt.BindName(itemScroll_2_5, "itemScroll_2_5")
	
    local infoBg = GUI.ImageCreate(mallBuyPage, "infoBg", "1800400010", 345, -110, false, 350, 320)
    guidt.BindName(infoBg, "infoBg")
    local itemIcon = ItemIcon.Create(infoBg, "itemIcon", 20, 20)
    UILayout.SetSameAnchorAndPivot(itemIcon, UILayout.TopLeft)

    local name = GUI.CreateStatic(infoBg, "name", "道具名称", 120, 20, 220, 30)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
    GUI.SetColor(name, UIDefine.BrownColor)
    GUI.StaticSetAlignment(name, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)

    local type = GUI.CreateStatic(infoBg, "type", "类型：", 120, 50, 220, 30)
    GUI.StaticSetFontSize(type, UIDefine.FontSizeL)
    GUI.SetColor(type, UIDefine.BrownColor)
    GUI.StaticSetAlignment(type, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(type, UILayout.TopLeft)

    local level = GUI.CreateStatic(infoBg, "level", "使用等级:", 20, 100, 315, 30)
    GUI.StaticSetFontSize(level, UIDefine.FontSizeL)
    GUI.SetColor(level, UIDefine.BrownColor)
    GUI.StaticSetAlignment(level, TextAnchor.MiddleLeft)
    GUI.SetAnchor(level, UIAnchor.TopLeft)
    GUI.SetPivot(level, UIAroundPivot.TopLeft)

    local descScroll =
        GUI.ScrollRectCreate(
        infoBg,
        "descScroll",
        20,
        200,
        315,
        80,
        0,
        false,
        Vector2.New(300, 220),
        UIAroundPivot.TopLeft,
        UIAnchor.TopLeft,
        1
    )
    GUI.SetAnchor(descScroll, UIAnchor.TopLeft)
    GUI.SetPivot(descScroll, UIAroundPivot.TopLeft)

    local desc = GUI.CreateStatic(descScroll, "desc", "描述", 0, 0, 320, 220, "system", true)
    GUI.StaticSetFontSize(desc, UIDefine.FontSizeL)
    GUI.SetColor(desc, UIDefine.BrownColor)
    GUI.StaticSetAlignment(desc, TextAnchor.UpperLeft)
    GUI.SetAnchor(desc, UIAnchor.TopLeft)
    GUI.SetPivot(desc, UIAroundPivot.TopLeft)

    local limitNum = GUI.CreateStatic(infoBg, "limitNum", "限购数量：", 20, 140, 315, 30)
    GUI.StaticSetFontSize(limitNum, UIDefine.FontSizeL)
    GUI.SetColor(limitNum, UIDefine.BrownColor)
    GUI.StaticSetAlignment(limitNum, TextAnchor.MiddleLeft)
    GUI.SetAnchor(limitNum, UIAnchor.TopLeft)
    GUI.SetPivot(limitNum, UIAroundPivot.TopLeft)

    local text1 = GUI.CreateStatic(mallBuyPage, "text1", "数量", 205, 90, 100, 30)
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeL)
    GUI.SetColor(text1, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text1, UIAnchor.Center)
    GUI.SetPivot(text1, UIAroundPivot.Center)

    local text2 = GUI.CreateStatic(mallBuyPage, "text2", "花费", 205, 150, 100, 30)
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeL)
    GUI.SetColor(text2, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text2, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text2, UIAnchor.Center)
    GUI.SetPivot(text2, UIAroundPivot.Center)

    local text3 = GUI.CreateStatic(mallBuyPage, "text3", "拥有", 205, 200, 100, 30)
    GUI.StaticSetFontSize(text3, UIDefine.FontSizeL)
    GUI.SetColor(text3, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text3, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text3, UIAnchor.Center)
    GUI.SetPivot(text3, UIAroundPivot.Center)

    local minusBtn = GUI.ButtonCreate(mallBuyPage, "MinusBtn", "1800402140", 280, 90, Transition.ColorTint, "")
	guidt.BindName(minusBtn, "minusBtn")
    local plusBtn = GUI.ButtonCreate(mallBuyPage, "PlusBtn", "1800402150", 480, 90, Transition.ColorTint, "")
	guidt.BindName(plusBtn, "plusBtn")
    local countEdit =
        GUI.EditCreate(
        mallBuyPage,
        "countEdit",
        "1800400390",
        "",
        380,
        90,
        Transition.ColorTint,
        "system",
        0,
        0,
        30,
        8,
        InputType.Standard,
        ContentType.IntegerNumber
    )
    GUI.EditSetFontSize(countEdit, UIDefine.FontSizeM)
    GUI.EditSetTextColor(countEdit, UIDefine.BrownColor)
    GUI.EditSetTextM(countEdit, "1")
    GUI.RegisterUIEvent(countEdit, UCE.EndEdit, "MallUI", "OnBuyCountModify")
    GUI.RegisterUIEvent(countEdit, UCE.PointerClick, "MallUI", "OnClickBuyCountModify")
    guidt.BindName(countEdit, "countEdit")
    GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "MallUI", "OnPlusBtnClick")
    GUI.RegisterUIEvent(minusBtn, UCE.PointerClick, "MallUI", "OnMinusBtnClick")
    plusBtn:RegisterEvent(UCE.PointerDown)
    plusBtn:RegisterEvent(UCE.PointerUp)
    minusBtn:RegisterEvent(UCE.PointerDown)
    minusBtn:RegisterEvent(UCE.PointerUp)
    GUI.RegisterUIEvent(plusBtn, UCE.PointerDown, "MallUI", "OnPlusBtnDown")
    GUI.RegisterUIEvent(plusBtn, UCE.PointerUp, "MallUI", "OnPlusBtnUp")
    GUI.RegisterUIEvent(minusBtn, UCE.PointerDown, "MallUI", "OnMinusBtnDown")
    GUI.RegisterUIEvent(minusBtn, UCE.PointerUp, "MallUI", "OnMinusBtnUp")

    local spendBg = GUI.ImageCreate(mallBuyPage, "spendBg", "1800900040", 380, 152, false, 252, 35)
    guidt.BindName(spendBg, "spendBg")
    local icon = GUI.ImageCreate(spendBg, "icon", "1800408250", -105, -1, false, 35, 35)
    local count = GUI.CreateStatic(spendBg, "count", 666666, 10, -1, 200, 30)
    GUI.StaticSetFontSize(count, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

    local ownBg = GUI.ImageCreate(mallBuyPage, "ownBg", "1800900040", 380, 202, false, 252, 35)
    guidt.BindName(ownBg, "ownBg")
    local icon = GUI.ImageCreate(ownBg, "icon", "1800408250", -105, -1, false, 35, 35)
    local count = GUI.CreateStatic(ownBg, "count", 666666, 10, -1, 200, 30)
    GUI.StaticSetFontSize(count, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

    local buyBtn = GUI.ButtonCreate(mallBuyPage, "buyBtn", "1800402080", 425, 260, Transition.ColorTint, "购买", 160, 50, false)
    GUI.SetIsOutLine(buyBtn, true)
    GUI.ButtonSetTextFontSize(buyBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(buyBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(buyBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(buyBtn, UIDefine.OutLineDistance)
	guidt.BindName(buyBtn, "buyBtn")
    GUI.RegisterUIEvent(buyBtn, UCE.PointerClick, "MallUI", "OnBuyBtnClick")
end

function MallUI.OnClickBuyCountModify(guid)
    local text = GUI.GetByGuid(guid)
    GUI.EditSetTextM(text,"")
end

function MallUI.OnBuyCountModify(guid)
    local text = GUI.GetByGuid(guid)
    local num = tonumber(GUI.EditGetTextM(text)) or 1
    data.num = MallUI.SetItemBuyCnt(num)
    GUI.EditSetTextM(text, tostring(data.num))
    MallUI.RefreshInfo()
end

-- 点击加
function MallUI.OnPlusBtnClick()
    data.num = MallUI.SetItemBuyCnt(data.num + 1)
    MallUI.RefreshInfo()
end

function MallUI.OnPlusBtnDown()
	local fun = function()
        MallUI.OnPlusBtnClick();
    end

    if MallUI.Timer == nil then
        MallUI.Timer = Timer.New(fun, 0.3, -1)
    else
        MallUI.Timer:Stop();
        MallUI.Timer:Reset(fun, 0.3, 1)
    end

    MallUI.Timer:Start();
end

function MallUI.OnPlusBtnUp()
	if MallUI.Timer ~= nil then
        MallUI.Timer:Stop();
        MallUI.Timer = nil;
    end
end

-- 点击减
function MallUI.OnMinusBtnClick()
    data.num = MallUI.SetItemBuyCnt(data.num - 1)
    MallUI.RefreshInfo()
end

function MallUI.OnMinusBtnDown()
	local fun = function()
        MallUI.OnMinusBtnClick();
    end

    if MallUI.Timer == nil then
        MallUI.Timer = Timer.New(fun, 0.3, -1)
    else
        MallUI.Timer:Stop();
        MallUI.Timer:Reset(fun, 0.3, 1)
    end

    MallUI.Timer:Start();
end

function MallUI.OnMinusBtnUp()
	if MallUI.Timer ~= nil then
        MallUI.Timer:Stop();
        MallUI.Timer = nil;
    end
end

-- 点击购买
function MallUI.OnBuyBtnClick()
	local itemInfo = MallUI.GetItemData(data.index)
	--local inspect = require("inspect")
	--print(inspect(itemInfo))
	if itemInfo.max_num and itemInfo.bought and itemInfo.max_num > 0 and itemInfo.bought >= itemInfo.max_num then
		CL.SendNotify(NOTIFY.ShowBBMsg, "今日购买次数已用尽")
		return
	end
	data.Item_index = itemInfo.Index
    MallUI.SendBuy()
end
--点击页签
function MallUI.OnTabBtnClick(guid)
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
    for i = 1, #tabList do
		if guid == tabList[i].btnGuid then
			local Key = tostring(tabList[i][1])
			local Level = MainUI.MainUISwitchConfig["商城"].Subtab_OpenLevel[Key]
			if CurLevel >= Level then
				data.tabIndex = i
			else
				CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
				MallUI.RefreshUI()
				--CL.SendNotify(NOTIFY.ShowBBMsg, "错误编号2")
				return
			end
        end
    end
    data.index = 1
    data.num = 1
    data.tabSubIndex = 1
	data.state = 0
    if data.tabIndex ~= #tabList then
        MallUI.GetDataByTab()
    end

    MallUI.RefreshUI()
end

--点击商品分类
function MallUI.OnMalllBuySubTabClick(guid)
	if not data.tabIndex or not tonumber(data.tabIndex) then
		data.tabIndex = 1
	end
    for i = 1, #mallBuySubTabList[1] do
		if guid == mallBuySubTabList[1][i].btnGuid then
            data.tabSubIndex = i
        end
    end
	if not data.tabSubIndex or not tonumber(data.tabSubIndex) then
		data.tabSubIndex = 1
		print("MallUI.OnMalllBuySubTabClick()   guid错误")
	end
    data.index = 1
    data.num = 1
	data.state = 0
    MallUI.GetDataByTab()
    MallUI.RefreshUI()
end
function MallUI.CreateMallScrollItem(parent, name, w, h)
    return MallItem.Create(parent, name)
end
function MallUI.RefreshLeftItemByItemInfosEx(guid, index)
	local itemInfo = MallUI.GetItemData(index)
	MallItem.Refresh(guid, itemInfo, MallUI.GetMoneyType())
end

-- 创建左侧道具表 1_1
function MallUI.CreatItemPool_1_1()
    local scroll = guidt.GetUI("itemScroll_1_1")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 1_1
function MallUI.RefreshItemScroll_1_1(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

-- 创建左侧道具表 1_2
function MallUI.CreatItemPool_1_2()
    local scroll = guidt.GetUI("itemScroll_1_2")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 1_2
function MallUI.RefreshItemScroll_1_2(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

-- 创建左侧道具表 1_3
function MallUI.CreatItemPool_1_3()
    local scroll = guidt.GetUI("itemScroll_1_3")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 1_3
function MallUI.RefreshItemScroll_1_3(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

-- 创建左侧道具表 1_4
function MallUI.CreatItemPool_1_4()
    local scroll = guidt.GetUI("itemScroll_1_4")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 1_4
function MallUI.RefreshItemScroll_1_4(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

-- 创建左侧道具表 1_5
function MallUI.CreatItemPool_1_5()
    local scroll = guidt.GetUI("itemScroll_1_5")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 1_5
function MallUI.RefreshItemScroll_1_5(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

-- 创建左侧道具表 2_1
function MallUI.CreatItemPool_2_1()
    local scroll = guidt.GetUI("itemScroll_2_1")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 2_1
function MallUI.RefreshItemScroll_2_1(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

-- 创建左侧道具表 2_2
function MallUI.CreatItemPool_2_2()
    local scroll = guidt.GetUI("itemScroll_2_2")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 2_2
function MallUI.RefreshItemScroll_2_2(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

-- 创建左侧道具表 2_3
function MallUI.CreatItemPool_2_3()
    local scroll = guidt.GetUI("itemScroll_2_3")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 2_3
function MallUI.RefreshItemScroll_2_3(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

-- 创建左侧道具表 2_4
function MallUI.CreatItemPool_2_4()
    local scroll = guidt.GetUI("itemScroll_2_4")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 2_4
function MallUI.RefreshItemScroll_2_4(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

-- 创建左侧道具表 2_5
function MallUI.CreatItemPool_2_5()
    local scroll = guidt.GetUI("itemScroll_2_5")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallUI.CreateMallScrollItem(scroll, "item" .. curCount)
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "MallUI", "OnLeftItemClick")
    return item
end
-- 刷新左侧道具表 2_5
function MallUI.RefreshItemScroll_2_5(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    MallUI.RefreshLeftItemByItemInfosEx(guid, index)
end

function MallUI.OnLeftItemClick(guid)
	--print(guid)
	--print(data.indexGuid)
    local item = GUI.GetByGuid(guid)
    --GUI.CheckBoxExSetCheck(item, true)
    data.index = tonumber(GUI.CheckBoxExGetIndex(item)) + 1
    data.num = 1
	data.state = 2			--既不是通过跳转选中道具，也不需要将scroll复位
    if guid ~= data.indexGuid then
        --GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end
	local scroll = guidt.GetUI("itemScroll_"..tostring(data.tabIndex).."_"..tostring(data.tabSubIndex))
	if scroll then
		GUI.LoopScrollRectRefreshCells(scroll)
	end
	
    MallUI.RefreshInfo()
	--if MallUI.OnClickLeftItemScroll then
	--	MallUI.OnClickLeftItemScroll(guid)
	--end
end
--刷新右侧信息
function MallUI.RefreshInfo()
	local infoBg = guidt.GetUI("infoBg")
    local itemIcon = GUI.GetChild(infoBg, "itemIcon", false)

    local name = GUI.GetChild(infoBg, "name", false)
    local type = GUI.GetChild(infoBg, "type", false)
    local level = GUI.GetChild(infoBg, "level", false)
    local descScroll = GUI.GetChild(infoBg, "descScroll", false)

    local desc = GUI.GetChild(descScroll, "desc", false)
    local limitNum = GUI.GetChild(infoBg, "limitNum", false)
    local spendBg = guidt.GetUI("spendBg")
    local ownBg = guidt.GetUI("ownBg")
    local countEdit = guidt.GetUI("countEdit")
    local spendicon = GUI.GetChild(spendBg, "icon")
    local spendcount = GUI.GetChild(spendBg, "count")
    local ownicon = GUI.GetChild(ownBg, "icon")
    local owncount = GUI.GetChild(ownBg, "count")
    local info = MallUI.GetItemData()
	local plusBtn = guidt.GetUI("plusBtn")
	local minusBtn = guidt.GetUI("minusBtn")
	--local buyBtn = guidt.GetUI("buyBtn")

    if info and info.info and info.info.id and info.info.id > 0 then
        --local inspect = require("inspect")
		--print(inspect(info))
		if info.template_type == 0 then
            ItemIcon.BindItemId(itemIcon, info.info.id)
        elseif info.template_type == 1 then
            ItemIcon.BindPetId(itemIcon, info.info.id)
        end
        GUI.StaticSetText(name, info.info.name)
        GUI.StaticSetText(type, "类型: " .. info.info.showType)
        GUI.StaticSetText(level, "使用等级: " .. info.info:GetUseLv())
        GUI.StaticSetText(desc, "描述: " .. info.info.desc)
        if info.max_num > 0 then
            --print("info.bought = "..info.bought)
			GUI.StaticSetText(limitNum, "今日限购数量: " .. info.max_num .. " 今日已购 " .. info.bought)
        elseif info.total_num > 0 then
            --print("info.total = "..info.total)
			GUI.StaticSetText(limitNum, "限购数量: " .. info.total_num .. " 已购 " .. info.total)
        else
            GUI.StaticSetText(limitNum, "不限购")
        end

		local totalcost = tonumber(info.price) * tonumber(data.num) or 0
		local totalown = UIDefine.ExchangeMoneyToStr((CL.GetAttr(UIDefine.GetMoneyEnum(MallUI.GetMoneyType()))))
        GUI.StaticSetText(spendcount, totalcost)
		GUI.StaticSetText(owncount, totalown)
		if totalcost > tonumber(tostring(CL.GetAttr(UIDefine.GetMoneyEnum(MallUI.GetMoneyType())))) then
			GUI.SetColor(spendcount, Color.New(255/255, 0/255, 0/255, 255))
		else
			GUI.SetColor(spendcount, UIDefine.WhiteColor)
		end
		
        GUI.ImageSetImageID(spendicon, UIDefine.GetMoneyIcon(MallUI.GetMoneyType()))
        GUI.ImageSetImageID(ownicon, UIDefine.GetMoneyIcon(MallUI.GetMoneyType()))
		if info.max_num > 0 and info.max_num == info.bought or info.total_num > 0 and info.total_num == info.total then
			GUI.ButtonSetShowDisable(plusBtn, false)
			MallUI.OnPlusBtnUp()
			GUI.ButtonSetShowDisable(minusBtn, false)
			MallUI.OnMinusBtnUp()
			GUI.EditSetTextM(countEdit, "0")
		else
			if info.max_num > 0 and data.num == info.max_num - info.bought or info.total_num > 0 and data.num == info.total_num - info.total then
				GUI.ButtonSetShowDisable(plusBtn, false)
				MallUI.OnPlusBtnUp()
			else
				GUI.ButtonSetShowDisable(plusBtn, true)
			end
			if data.num ~= 1 then
				GUI.ButtonSetShowDisable(minusBtn, true)
			else
				GUI.ButtonSetShowDisable(minusBtn, false)
				MallUI.OnMinusBtnUp()
			end
			if info.max_num > 0 and data.num > info.max_num - info.bought then
				data.num = info.max_num - info.bought
			elseif info.total_num > 0 and data.num > info.total_num - info.total then
				data.num = info.total_num - info.total
			end
			GUI.EditSetTextM(countEdit, tostring(data.num))
		end
    else
        ItemIcon.BindItemId(itemIcon, nil)
        GUI.StaticSetText(name, "道具名称")
        GUI.StaticSetText(type, "类型: ")
        GUI.StaticSetText(level, "使用等级:")
        GUI.StaticSetText(desc, "描述: ")
        GUI.StaticSetText(limitNum, "不限购")
        GUI.StaticSetText(spendcount, "0")
        GUI.StaticSetText(owncount, "0")
        GUI.EditSetTextM(countEdit, "0")
    end
    local h = GUI.StaticGetLabelPreferHeight(desc)
    GUI.SetHeight(desc,h)
    local height = 80
    if h > height then
        height = h
    end
    GUI.ScrollRectSetChildSize(descScroll,Vector2.New(315, height))
    GUI.ScrollRectSetNormalizedPosition(descScroll, UIDefine.Vector2One)
end

-- 服务器通知刷新
function MallUI.RefreshTab()
    MallUI.ClientRefreshTab()
end
function MallUI.RefreshData(Tabs_index, Classify_index)
    MallUI.ClientRefresh()
	MallUI.FirstClick[tostring(Tabs_index)..tostring(Classify_index)] = 1
end
-- 服务器刷新购买数量信息
function MallUI.RefreshBuyCnt(tabIndex, subTabName, index, name, cnt)
	local a = MallUI.Index_To_ItemIndex[tonumber(tabIndex)][subTabName][tostring(index)]
	if data.Currency_Classify_Item and data.Currency_Classify_Item[tonumber(tabIndex)] and data.Currency_Classify_Item[tonumber(tabIndex)][subTabName] and data.Currency_Classify_Item[tonumber(tabIndex)][subTabName][a] and data.Currency_Classify_Item[tonumber(tabIndex)][subTabName][a][name] then
		data.Currency_Classify_Item[tonumber(tabIndex)][subTabName][a][name] = cnt
	end
	MallUI.ClientRefresh()
end

function MallUI.ClientRefresh()
	if not MallUI.Index_To_ItemIndex then
		MallUI.Index_To_ItemIndex = {}
	end
	--if not MallUI.ItemIndex_To_Index then
	--	MallUI.ItemIndex_To_Index = {}
	--end
    local panel = GUI.GetWnd("MallUI")
	for k, v in pairs(MallUI.Currency_Classify_Item) do
		if data.Currency_Classify_Item[k] == nil then
			data.Currency_Classify_Item[k] = {}
		end
		if not MallUI.Index_To_ItemIndex[k] then
			MallUI.Index_To_ItemIndex[k] = {}
		end
		for key, value in pairs(v) do
			data.Currency_Classify_Item[k][key] = value
			for i = 1, #value do
				if data.Currency_Classify_Item[k][key][i].total_num == nil then
					data.Currency_Classify_Item[k][key][i].total_num = 0
				end
				if data.Currency_Classify_Item[k][key][i].max_num == nil then
					data.Currency_Classify_Item[k][key][i].max_num = 0
				end
				if data.Currency_Classify_Item[k][key][i].bought == nil then
					--test(k .. key .. i)
					data.Currency_Classify_Item[k][key][i].bought = 0
				end
				if data.Currency_Classify_Item[k][key][i].total == nil then
					data.Currency_Classify_Item[k][key][i].total = 0
				end
				if not data.Currency_Classify_Item[k][key][i].Index then
					data.Currency_Classify_Item[k][key][i].Index = i
				end
			end
			for j = #data.Currency_Classify_Item[k][key], 1, -1 do
				if data.Currency_Classify_Item[k][key][j].total_num > 0 and data.Currency_Classify_Item[k][key][j].total_num == data.Currency_Classify_Item[k][key][j].total then
					--print("j = "..j)
					table.remove(data.Currency_Classify_Item[k][key], j)
				end
			end
		end
	end
    for k, v in pairs(data.Currency_Classify_Item) do
		for m, n in pairs(v) do
			if not MallUI.Index_To_ItemIndex[k][m] then
				MallUI.Index_To_ItemIndex[k][m] = {}
			end
			for i = 1, #n do
				local a = data.Currency_Classify_Item[k][m][i].Index
				if not MallUI.Index_To_ItemIndex[k][m][tostring(a)] then
					MallUI.Index_To_ItemIndex[k][m][tostring(a)] = 0
				end
				MallUI.Index_To_ItemIndex[k][m][tostring(a)] = i
			end
		end
	end
	--local inspect = require("inspect")

    if data.index < 1 or data.index > #MallUI.GetItemDatas() then
        data.index = 1
    end
	
    if GUI.GetVisible(panel) == true then
		if MallUI.parameter then
			MallUI._go_to_precise(MallUI.parameter)
		end
		if MallUI._parameter then
			data.tabIndex = tonumber(MallUI._parameter[1])
			if not data.tabIndex then
				data.tabIndex = 1
			end
			data.tabSubIndex = tonumber(MallUI._parameter[2])
			if not data.tabSubIndex then
				data.tabSubIndex = 1
			end
			data.index = tonumber(MallUI._parameter[3])
			if not data.index then
				data.index = 1
			end
		end
		MallUI.RefreshUI()
		MallUI.parameter = nil
		MallUI._parameter = nil
    end
end

function MallUI.ClientRefreshTab()
    local index = 0
    if data.tabIndex < 1 or data.tabIndex > #MallUI.Currency_Tab + 1 then
		data.tabIndex = 1
    end
    if MallUI.Currency_Tab[data.tabIndex] == nil or MallUI.Currency_Tab[data.tabIndex].Classify == nil then
        --test(MallUI.Currency_Tab[data.tabIndex])
        --test(MallUI.Currency_Tab[data.tabIndex].Classify)
		--CL.SendNotify(NOTIFY.ShowBBMsg, "错误编号1")
        return
    end
    if data.tabSubIndex < 1 or data.tabSubIndex > #MallUI.Currency_Tab[data.tabIndex].Classify then
        data.tabSubIndex = 1
    end

    for i = 1, #MallUI.Currency_Tab do
        MallUI.Version[i] = {}
        index = i
        if not tabList[i] then
            test(MallUI.Currency_Tab[i].Name)
            table.insert(tabList, i, {MallUI.Currency_Tab[i].Name, "tabList" .. i, "OnTabBtnClick", "mallBuyPage", panelBgPath .. "/mallBuyPage"})
        else
            test(MallUI.Currency_Tab[i].Name)
            tabList[i].hide = false
            tabList[i][1] = MallUI.Currency_Tab[i].Name
            tabList[i][2] = "tabList" .. i
            tabList[i][3] = "OnTabBtnClick"
            tabList[i][4] = "mallBuyPage"
            tabList[i][5] = panelBgPath .. "/mallBuyPage"
        end
        CL.RegisterAttr(UIDefine.GetMoneyEnum(MallUI.Currency_Tab[i].Money_Type), MallUI.UpdateMoneyValue)
    end

    if tabList[index + 1] == nil then
        table.insert(tabList, {"充值", "rechargeTabBtn", "OnTabBtnClick", "rechargePage", panelBgPath .. "/rechargePage"})
    else
        tabList[index + 1][1] = "充值"
        tabList[index + 1][2] = "rechargeTabBtn"
        tabList[index + 1][3] = "OnTabBtnClick"
        tabList[index + 1][4] = "rechargePage"
        tabList[index + 1][5] = panelBgPath .. "/rechargePage"
    end

    for i = index + 2, #tabList do
        tabList[i].hide = true
    end
	for a = 1,#MallUI.Currency_Tab do
		local classify = MallUI.Currency_Tab[a].Classify
		if not mallBuySubTabList[a] then
			mallBuySubTabList[a] = {}
		end
		for i = 1, #classify do
			index = i
			if not mallBuySubTabList[a][i] then
				mallBuySubTabList[a][i] = {}
				mallBuySubTabList[a][i][1] = classify[i]
				mallBuySubTabList[a][i][2] = "mallBuySubTab" .. i
				mallBuySubTabList[a][i][3] = "1800402180"
				mallBuySubTabList[a][i][4] = "1800402181"
				mallBuySubTabList[a][i][5] = "OnMalllBuySubTabClick"
				mallBuySubTabList[a][i][6] = -450 + 135 * (i - 1)
				mallBuySubTabList[a][i][7] = -245
				mallBuySubTabList[a][i][8] = 135
				mallBuySubTabList[a][i][9] = 50
				mallBuySubTabList[a][i][10] = 100
				mallBuySubTabList[a][i][11] = 35
			else
				mallBuySubTabList[a][i].hide = false
				mallBuySubTabList[a][i][1] = classify[i]
			end
		end
		for i = index + 1, #mallBuySubTabList do
			mallBuySubTabList[a][i].hide = true
		end
	end
    if data.indexName then
		for i = 1, #tabList do
			if data.indexName == tabList[i][1] then
				data.tabIndex = i
				break
			end
		end
		data.indexName = nil
    end
	
	UILayout.CreateRightTab(tabList, "MallUI")

	local parent = GUI.Get("MallUI/panelBg/tabList")

	GUI.SetVisible(parent, false)

	
	local mallBuyPage = guidt.GetUI("mallBuyPage")


	MallUI.SetNewMallBuySubTabListData()

	--顶部分类选项
	local topClassifyLoop =
	GUI.LoopScrollRectCreate(
			mallBuyPage,
			"topClassifyLoop",
			-520,
			-270,
			680,
			55,
			"MallUI",
			"CreateClassifyItem",
			"MallUI",
			"RefreshClassifyItem",
			0,
			true,
			Vector2.New(135,50),
			1,
			UIAroundPivot.TopLeft,
			UIAnchor.TopLeft,
			false
	)
	SetSameAnchorAndPivot(topClassifyLoop, UILayout.TopLeft)
	GUI.ScrollRectSetAlignment(topClassifyLoop, TextAnchor.UpperLeft)
	GUI.LoopScrollRectSetTotalCount(topClassifyLoop, #newMallBuySubTabList)
	GUI.LoopScrollRectSrollToCell(topClassifyLoop,data.tabSubIndex - 1 ,2000)
	GUI.LoopScrollRectRefreshCells(topClassifyLoop)
	GUI.ScrollRectSetChildSpacing(topClassifyLoop, Vector2.New(1,0 ))
	guidt.BindName(topClassifyLoop,"topClassifyLoop")
	GUI.ScrollRectSetHorizontal(topClassifyLoop,false)

	if UIDefine.FunctionSwitch.MallFree == "on" then
		if MallUI.MallFreeTipsInfo and not guidt.GetUI("MallFreeTips") then
			local MallFreeTips = GUI.ButtonCreate(guidt.GetUI("buyBtn"), "MallFreeTips", "1800702030", -50, 5, Transition.ColorTint, "")
			guidt.BindName(MallFreeTips, "MallFreeTips")
    	    UILayout.SetAnchorAndPivot(MallFreeTips, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    	    GUI.RegisterUIEvent(MallFreeTips, UCE.PointerClick, "MallUI", "OnMallFreeTipsClick")
		end
	end
	
    if data.tabIndex ~= #tabList then
		-- 如果首次打开界面，有跳转的参数
        if MallUI._parameter then
            if MallUI._parameter[1] then data.tabIndex = MallUI._parameter[1] end
            if MallUI._parameter[2] then data.tabSubIndex = MallUI._parameter[2] end
            if MallUI._parameter[3] then data.index = MallUI._parameter[3] end
            data.state = 1
            MallUI._parameter = nil
        end
        MallUI.GetDataByTab()
    else
        MallUI.RefreshUI()
    end
end

function MallUI.OnMallFreeTipsClick()
	local tips = GUI.TipsCreate(GUI.Get("MallUI/panelBg"), "Tips", 80, 180, 400, 12)  --"1800400290",
    GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
	local tipstext = GUI.CreateStatic(tips,"tipstext",MallUI.MallFreeTipsInfo,0,0,360,120,"system", true)
	GUI.StaticSetFontSize(tipstext,22)
end

function MallUI.SetNewMallBuySubTabListData()
	newMallBuySubTabList = {}
	if MallUI.Currency_Tab~= nil then
		if MallUI.Currency_Tab[data.tabIndex] ~= nil then
			for i = 1, #MallUI.Currency_Tab[data.tabIndex].Classify do
				table.insert(newMallBuySubTabList,MallUI.Currency_Tab[data.tabIndex].Classify[i])
			end
		end

	end
end

function MallUI.CreateClassifyItem()
	local topClassifyLoop = guidt.GetUI("topClassifyLoop")
	local index = GUI.LoopScrollRectGetChildInPoolCount(topClassifyLoop) + 1

	local CheckBox = GUI.CheckBoxExCreate(topClassifyLoop, "CheckBox"..index, "1800402180", "1800402181", 0, 0, false)
	SetSameAnchorAndPivot(CheckBox, UILayout.Center)
	GUI.RegisterUIEvent(CheckBox, UCE.PointerClick, "MallUI", "OnClassifyItemClick")

	local txt = GUI.CreateStatic(CheckBox, "txt", " ", 0, 0, 150, 30)
	SetSameAnchorAndPivot(txt, UILayout.Center)
	GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
	GUI.SetColor(txt, Brown4Color)
	GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

	return CheckBox
end

function MallUI.RefreshClassifyItem(parameter)
	parameter = string.split(parameter, "#")
	local guid = parameter[1]
	local index = tonumber(parameter[2]) + 1
	local CheckBox = GUI.GetByGuid(guid)

	local tableData = newMallBuySubTabList[index]
	if tableData then

		if tableData == newMallBuySubTabList[data.tabSubIndex] then
			GUI.CheckBoxExSetCheck(CheckBox,true)
			lastCheckBoxGuid = tostring(GUI.GetGuid(CheckBox))
		else
			GUI.CheckBoxExSetCheck(CheckBox,false)
		end

		local txt = GUI.GetChild(CheckBox,"txt",false)
		GUI.StaticSetText(txt,tableData)

		GUI.SetData(CheckBox,"name",tableData)
	end
end

function MallUI.OnClassifyItemClick(guid)
	local CheckBox = GUI.GetByGuid(guid)
	local name = GUI.GetData(CheckBox,"name")

	if tostring(guid) ~= lastCheckBoxGuid then
		GUI.CheckBoxExSetCheck(CheckBox,true)
		if lastCheckBoxGuid ~= nil then
			local LastCheckBox = GUI.GetByGuid(lastCheckBoxGuid)
			GUI.CheckBoxExSetCheck(LastCheckBox,false)
		end
	else
		GUI.CheckBoxExSetCheck(CheckBox,true)
	end
	lastCheckBoxGuid = tostring(guid)
	for i = 1, #newMallBuySubTabList do
		if newMallBuySubTabList[i] == name then
			data.tabSubIndex = i
		end
	end
	test("data.tabSubIndex",tostring(data.tabSubIndex))

	data.index = 1
	data.num = 1
	data.state = 0
	MallUI.GetDataByTab()
	MallUI.RefreshUI()
end

---@return Classify_Item[]
function MallUI.GetItemDatas(tabIndex, subTabIndex)
    if tabIndex == nil then
        tabIndex = data.tabIndex and tonumber(data.tabIndex) or 1
    end
    if subTabIndex == nil then
        subTabIndex = data.tabSubIndex and tonumber(data.tabSubIndex) or 1
    end
    local tab = MallUI.Currency_Tab[tabIndex]
    if tab == nil or tab.Classify == nil then
		print("tab数据错误")
		return {}
    end
    local subTabName = tab.Classify[subTabIndex]
    if subTabName == nil then
		print("subTabName数据错误")
		MallUI.ReGetDataByTab(tabIndex, subTabIndex)
		return {}
    end
    local classifyItem = data.Currency_Classify_Item[tabIndex]
    if classifyItem == nil then
		print("classifyItem数据错误")
		MallUI.ReGetDataByTab(tabIndex, subTabIndex)
		return {}
    end
    local items = classifyItem[subTabName]
    if items == nil then
		print("items数据错误")
		MallUI.ReGetDataByTab(tabIndex, subTabIndex)
		return {}
    end
    return items
end

--重新请求数据
function MallUI.ReGetDataByTab(Tabs_index, Classify_index)
	if Tabs_index == nil then
        Tabs_index = data.tabIndex and tonumber(data.tabIndex) or 1
    end
    if Classify_index == nil then
        Classify_index = data.tabSubIndex and tonumber(data.tabSubIndex) or 1
    end
    if Tabs_index and Classify_index then
        CL.SendNotify(NOTIFY.SubmitForm,"FormMall","Item_Info",0,Tabs_index,Classify_index)
    end
end

function MallUI.GetMoneyType(tabIndex)
    if tabIndex == nil then
        tabIndex = data.tabIndex
    end
    if MallUI.Currency_Tab[tabIndex] == nil then
		print("MallUI.GetMoneyType(tabIndex)数据错误")
		CL.SendNotify(NOTIFY.ShowBBMsg, "错误编号4")
		return nil
    end
    return MallUI.Currency_Tab[tabIndex].Money_Type
end
---@return Classify_Item
function MallUI.GetItemData(index, tabIndex, subTabIndex)
    if index == nil then
        index = data.index
    end
    local items = MallUI.GetItemDatas(tabIndex, subTabIndex)
    if items == nil or items[index] == nil then
		print("MallUI.GetItemData数据错误")
		return nil
    end
    local itemInfo = items[index]
    if itemInfo then
        --local inspect = require("inspect")
		--print(inspect(itemInfo))
		if itemInfo.info == nil or itemInfo.info.id == nil then
            if itemInfo.template_type == 0 then
                local dbItemInfo = DB.GetOnceItemByKey2(itemInfo.keyname)
                itemInfo.info = LogicDefine.NewequipItem()
                local tmp = itemInfo.info
                tmp.id = dbItemInfo.Id
                tmp.keyname = dbItemInfo.KeyName
                tmp.name = dbItemInfo.Name
                tmp.lv = dbItemInfo.Level
                tmp.desc = dbItemInfo.Info
                tmp.showType = dbItemInfo.ShowType
                tmp.turnBorn = dbItemInfo.TurnBorn
            elseif itemInfo.template_type == 1 then
                local dbItemInfo = DB.GetOncePetByKey2(itemInfo.keyname)
                itemInfo.info = LogicDefine.NewequipItem()
                local tmp = itemInfo.info
                tmp.id = dbItemInfo.Id
                tmp.keyname = dbItemInfo.KeyName
                tmp.name = dbItemInfo.Name
                tmp.desc = dbItemInfo.Info
                tmp.lv = 1
                test(dbItemInfo.Type)
                tmp.showType = UIDefine.PetTypeTxt[dbItemInfo.Type]
            end
        end
    end
    return itemInfo
end
function MallUI.GetItemCanBuyCnt(index, tabIndex, subTabIndex)
    local info = MallUI.GetItemData(index, tabIndex, subTabIndex)
    if info then
        local num = -1
        if info.max_num and info.max_num > 0 then
            num = info.max_num - info.bought
        elseif info.total_num and info.total_num > 0 then
            num = info.total_num - info.total
        end
        return num
    else
        return 0
    end
end
function MallUI.SetItemBuyCnt(num)
    if num then
        local max = MallUI.GetItemCanBuyCnt()
        if max > -1 then
            num = math.min(max, num)
        end
        num = math.max(num, 1)
    else
        num = 1
    end
	if num > 99 then
		num = 99
		CL.SendNotify(NOTIFY.ShowBBMsg, "无法增加购买数量，一次性只能购买"..num.."个")
	end
    return num
end
function MallUI.OnExitGame()
    data = MallUI.InitData()
end


-- 解析打开界面跳转数据
function MallUI._go_to_precise(parameter)
	--print(tostring(parameter))
	if not parameter then
		--print("MallUI._go_to_precise     没有parameter")
		CL.SendNotify(NOTIFY.ShowBBMsg, "错误编号3")
		return
	end
	-- 如果传入的是具体位置
	local index, index2, index3 = nil
	if string.find(parameter, "index3") then
		index, index2, index3 = UIDefine.get_parameter_str_3(parameter)
		index = tonumber(index)
		index2 = tonumber(index2)
		index3 = tonumber(index3)
		-- 如果传入的物品id或keyName
	else
		index, index2 = UIDefine.GetParameterStr(parameter)
		if not tonumber(index) then
			index, index2, index3 = GlobalUtils.ItemToMall(parameter)
		else
			index = tonumber(index)
			index2 = tonumber(index2)
			index3 = 1
		end
	end

	if index and index2 and index3 and MallUI.Index_To_ItemIndex then
		print("aaa")
		if MallUI.Currency_Tab[index] and MallUI.Currency_Tab[index].Classify then
			print("bbb")
			local tabname = MallUI.Currency_Tab[index].Classify[index2]
			if tabname and MallUI.Index_To_ItemIndex[index] and MallUI.Index_To_ItemIndex[index][tabname] then
				index3 = MallUI.Index_To_ItemIndex[index][tabname][tostring(index3)]
			end
		end
	end

	if index or index2 or index3 then
		MallUI._parameter = {index, index2, index3}
	else
		--print("index or index2 or index3都没有")
	end
end