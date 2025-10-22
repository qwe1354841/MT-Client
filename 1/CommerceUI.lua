require "BourseUI"
local CommerceUI = {
    ServerData = {
        ---@type table<number,number>
        allBuyCnt = {}
    },
}
_G.CommerceUI = CommerceUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local _gt = UILayout.NewGUIDUtilTable()
local panelBgPath = "CommerceUI/panelBg"
CommerceUI.TabIndex = 1

local commerceSubTabList = {
    {"购买", "buySubTabBtn", "1800402030", "1800402032", "OnBuySubTabBtnClick", -450, -245, 135, 50, 100, 35},
    {"出售", "sellSubTabBtn", "1800402030", "1800402032", "OnSellSubTabBtnClick", -315, -245, 135, 50, 100, 35}
}

local tabList = {
    {"商会","CommerceUITabBtn","OnCommerceUITabBtnClick"},  -- attrPage
    {"交易","BourseUITabBtn","OnBourseUITabBtnClick"}
}

function CommerceUI.InitData()
    return {
        commerceSubTabIndex = 1,
        ---@type number
        items = {},
        ---@type table<number,number>
        itemId2Index = {},
        ---@type Commerce_Item[]
        allitems = nil,
		_gt = nil,
		AllOnSellitemIds = {},
		AllOnSellitemGuids = {},
		Input_ConfirmBtnitems = {},
		
        ---@type table<number,table<number,number>>
        types = {},
        itemindex = 1,
        maintype = 0,
		itemindex_OnSearch = 1,
        ---@type table<number,boolean>
        maintypeopen = {},
        subType = 0,
        curBuyCount = 1,
        moneyType = 5,
        ---@type Int64
        curMoney = nil
    }
end
local data = CommerceUI.InitData()

function CommerceUI.OnExitGame()
    data = CommerceUI.InitData()
end
---@return Commerce_Item
function CommerceUI.GetItem()
    return data.allitems[data.items[data.itemindex]]
end
function CommerceUI.OnExit()
	GUI.CloseWnd("CommerceUI")
end
function CommerceUI.Main(parameter)
	--等级不足时禁止打开
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))  
	local Level = MainUI.MainUISwitchConfig["交易行"].OpenLevel
	if not Level then
		CL.SendNotify(NOTIFY.ShowBBMsg, "没有交易所相关数据")
		return
	end
	if CurLevel < Level then
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启交易功能")
		return
	end	
    _gt = UILayout.NewGUIDUtilTable()
	GUI.PostEffect()
    GameMain.AddListen("CommerceUI", "OnExitGame")
	local BourseLevel = MainUI.MainUISwitchConfig["交易行"].Subtab_OpenLevel["交易"]
	if CurLevel >= BourseLevel then
		BourseUI.Main()
	end
	
	CommerceUI.CreateBg()
	
	CL.UnRegisterAttr(UIDefine.GetMoneyEnum(data.moneyType), CommerceUI.NotifyRoleData)
    CL.RegisterAttr(UIDefine.GetMoneyEnum(data.moneyType), CommerceUI.NotifyRoleData)
end

function CommerceUI.CreateBg()
	local panel = GUI.WndCreateWnd("CommerceUI", "CommerceUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "商    会", "CommerceUI", "OnExit")
	_gt.BindName(panelBg, "panelBg")
    UILayout.CreateRightTab(tabList, "CommerceUI")
	UILayout.OnTabClick(1, tabList)
	CommerceUI.GetBaseData()		--本地数据
    if not CommerceUI.typeName or CommerceUI.subTypeName then
		CommerceUI.GetServerCfg()
	end
	--data.OnListTypeBtnClick = 1
end

function CommerceUI.OnShow(parameter)
	if parameter ~= nil then
		if string.find(parameter, "index2") then
			CommerceUI.parameter1, CommerceUI.parameter2 = UIDefine.GetParameterStr(parameter)
			CommerceUI.parameter1 = tonumber(CommerceUI.parameter1)
			CommerceUI.parameter2 = tonumber(CommerceUI.parameter2)
			data.maintype = CommerceUI.parameter1
			data.subType = CommerceUI.parameter2
			CommerceUI.parameter1 = nil
		else
			parameter = string.split(parameter,",")
			CommerceUI.parameter1 = tonumber(parameter[1])
			CommerceUI.parameter2 = tonumber(parameter[2])
			CommerceUI.ItemId = tonumber(parameter[3])
			data.maintype = CommerceUI.parameter1
			data.subType = CommerceUI.parameter2
			CommerceUI.parameter1 = nil
		end
	end
	
	
    local wnd = GUI.GetWnd("CommerceUI")
    if wnd == nil then
        return
    end
	if UIDefine.FunctionSwitch["Exchange"] and UIDefine.FunctionSwitch["Exchange"] ~= "on" then
		GUI.SetVisible(wnd, false)
		CommerceUI.OnBourseUITabBtnClick() 
	else
		GUI.SetVisible(wnd, true)
		CommerceUI.IsVisible = 1
		CommerceUI.OnBuySubTabBtnClick()
		CommerceUI.OnRefreshBtnClick()
	end
end
function CommerceUI.OnDestroy()
    CommerceUI.OnClose()
	data = CommerceUI.InitData()
end
function CommerceUI.OnClose()
    local wnd = GUI.GetWnd("CommerceUI")
    GUI.SetVisible(wnd, false)
	CommerceUI.IsVisible = 0
	--CL.UnRegisterAttr(UIDefine.GetMoneyEnum(data.moneyType), CommerceUI.NotifyRoleData)
end
function CommerceUI.NotifyRoleData(attrType, value)
    if attrType == UIDefine.GetMoneyEnum(data.moneyType) then
		data.curMoney = value
		if CommerceUI.IsVisible == 1 then
			CommerceUI.RefreshBuyCost()
		elseif CommerceUI.IsVisible == 0 then
			
		end
    end
end
function CommerceUI.GetBaseData()
	--test("GetBaseData")
    if data.allitems == nil then
        data.allitems = {}
        local Raw_list = DB.GetExchangeAllKey1s()
		local list = {}
		for i = 0, Raw_list.Count - 1 do
			local id = Raw_list[i]
			local db = DB.GetOnceExchangeByKey1(id)
			table.insert(list, db)
		end
		table.sort(list, function(x,y)
			if x["Buy"] == y["Buy"] then
				return x["Id"] < y["Id"]
			else
				return x["Buy"] < y["Buy"]
			end
		end)
        for i = 1, #list do
            local id = list[i]["Id"]
            local db = list[i]
            local index = #data.allitems + 1
            ---@type Commerce_Item
            local info = {}
            info.Id = id
			info.name = db.Name
            info.keyname = db.KeyName
            info.price = db.Buy
            info.discount = 100
            info.max_num = db.Number
            info.total_num = 0
            info.bought = 0
            info.total = 0
            info.onceBuyLimit = db.BuyMax
            info.type = db.Type
            info.subType = db.SubType
            info.template_type = 0

            data.allitems[index] = info
            data.itemId2Index[id] = index
            data.types[info.type] = data.types[info.type] or {}
            data.maintypeopen[info.type] = true
            data.types[info.type][info.subType] = data.types[info.type][info.subType] or {}
            local subTypeItemsNum = #data.types[info.type][info.subType]
            data.types[info.type][info.subType][subTypeItemsNum + 1] = index
        end
    end

    data.curMoney = nil
end
function CommerceUI.GetServerCfg()
    CL.SendNotify(NOTIFY.SubmitForm, "FormExchange", "GetExchangeData")
end
function CommerceUI.GetDate()
    CL.SendNotify(NOTIFY.SubmitForm, "FormExchange", "GetBuyRecord")
end
function CommerceUI.RefreshCfg()
    CommerceUI.CreateCommercePage()
    CommerceUI.GetDate()
end
function CommerceUI.Refresh()
	--test("Refresh")
	if CommerceUI.parameter1 ~= nil then
	--test(CommerceUI.parameter1)
	--test(CommerceUI.parameter2)
	data.maintype = CommerceUI.parameter1
	data.subType = CommerceUI.parameter2
	end
	
	if CommerceUI.ServerData.allBuyCnt and next(CommerceUI.ServerData.allBuyCnt) then
		for key, value in pairs(CommerceUI.ServerData.allBuyCnt) do
			local index = data.itemId2Index[key]
			if index then
				local item = data.allitems[index]
				if item then
					item.bought = value
				end
			end
		end
	else
		for i = 1, #data.allitems do
			local item = data.allitems[i]
			if item then
				item.bought = 0
			end
		end
	end
    CommerceUI.ClientRefresh()
end
function CommerceUI.ClientRefresh()
	--test("ClientRefresh")
    data.curMoney = data.curMoney or CL.GetAttr(UIDefine.GetMoneyEnum(data.moneyType))
	if data.types and data.types[data.maintype] == nil then
		test("没有data.types[data.maintype]")
        for key, _ in pairs(data.types) do
            data.maintype = key
            break
        end
    end
    if data.types and data.types[data.maintype] and data.types[data.maintype][data.subType] == nil then
        for key, _ in pairs(data.types[data.maintype]) do
            data.subType = key
            break
        end
    end
	if data.types and data.types[data.maintype] then
		data.items = data.types[data.maintype][data.subType]
	end
    if data.items == nil then
        test("商会数据错误 " .. data.maintype .. ":" .. data.subType)
        return
    end
    if data.items[data.itemindex] == nil then
        data.itemindex = 1
    end
    if data.items[data.itemindex] == nil then
        test("商会数据错误 " .. data.maintype .. ":" .. data.subType .. ":" .. data.itemindex)
        return
    end
    CommerceUI.RefreshUI()
end
function CommerceUI.RefreshUI()
	--test("RefreshUI")
	UILayout.OnSubTabClickEx(data.commerceSubTabIndex, commerceSubTabList)
    CommerceUI.RefreshCommercePage()
end
function CommerceUI.RefreshBuyCost()					--右下角数字刷新方法
	--test("RefreshBuyCost")
	if data.curBuyCount < 0 then
        data.curBuyCount = 0
    end
    local price = 0
	local info = CommerceUI.GetItem()
	if data.commerceSubTabIndex == 1 then
		--test("info.id = "..info.Id)
		if data.CommerceUI_OnSearch == 1 then
			--test("=============data.itemindex_OnSearch = "..data.itemindex_OnSearch)
			info = data.Input_ConfirmBtnitems[data.itemindex_OnSearch]
		end
		if info then
			if data.curBuyCount > info.onceBuyLimit then
				data.curBuyCount = info.onceBuyLimit
				CL.SendNotify(NOTIFY.ShowBBMsg,"无法增加购买数量，一次性只能购买"..data.curBuyCount.."个")
			end
			if info.max_num ~= 0 and data.curBuyCount > info.max_num - info.bought then
				data.curBuyCount = info.max_num - info.bought
				if tonumber(data.curBuyCount) ~= 0 then
					CL.SendNotify(NOTIFY.ShowBBMsg,"无法增加购买数量，一次性只能购买"..data.curBuyCount.."个")
				end
			end
		
			if CommerceUI.ServerData.NowPrice and CommerceUI.ServerData.NowPrice[info.Id] then		--如果CommerceUI.ServerData.NowPrice为空则服务器不会发表单
				price = tonumber(CommerceUI.ServerData.NowPrice[info.Id])
			else
				price = info.price
			end
		end
    elseif data.commerceSubTabIndex == 2 then
		info = data.AllOnSellitemIds[tonumber(data.OnsellItemClick_Index)]
		if info then
			price = info.sell
		end
	end
	local countEdit = _gt.GetUI("countEdit")
    local str = GUI.EditGetTextM(countEdit)
	if not str then
		str = 1
	end
    if str ~= tonumber(data.curBuyCount) then
		if data.commerceSubTabIndex == 1 then
			GUI.EditSetTextM(countEdit, data.curBuyCount)
			--CL.SendNotify(NOTIFY.ShowBBMsg,"无法增加购买数量，一次性只能购买"..data.curBuyCount.."个")
		elseif data.commerceSubTabIndex == 2 then
			local sellBtn = _gt.GetUI("sellBtn")
			local index = GUI.GetData(sellBtn, "Index")
			if index then
				local Bag_itemicon = _gt.GetUI("Bag_itemicon"..index)
				local Own_Num = tonumber(GUI.StaticGetText(GUI.GetChild(Bag_itemicon, "RightBottomNum", false)))
				if not Own_Num then
					Own_Num = 1
				end
				local info = data.AllOnSellitemIds[tonumber(index)]	
				if info then
					local SellMax = tonumber(info.sellMax)
					if tonumber(data.curBuyCount) > Own_Num or data.curBuyCount > SellMax then
						if Own_Num < SellMax then
							data.curBuyCount = Own_Num
						else
							data.curBuyCount = SellMax
						end
						CL.SendNotify(NOTIFY.ShowBBMsg,"无法增加出售数量，一次性只能出售"..data.curBuyCount.."个")		--0000
					end
				end
			end
			GUI.EditSetTextM(countEdit, data.curBuyCount)
		end
    end
    UILayout.RefreshAttrBar(_gt.GetUI("spendBg"), UIDefine.GetMoneyEnum(data.moneyType), tonumber(price) * tonumber(data.curBuyCount))
    UILayout.RefreshAttrBar(
        _gt.GetUI("owebg"),
        UIDefine.GetMoneyEnum(data.moneyType),
        UIDefine.ExchangeMoneyToStr(data.curMoney)
    )
	
	local numText = GUI.GetChild(_gt.GetUI("spendBg"), "numText")
	if tonumber(tostring(data.curMoney)) and tonumber(price) * tonumber(data.curBuyCount) then
		if tonumber(tostring(data.curMoney)) < tonumber(price) * tonumber(data.curBuyCount) and data.commerceSubTabIndex == 1 then
			GUI.SetColor(numText, UIDefine.RedColor)
		else
			GUI.SetColor(numText, UIDefine.WhiteColor)
		end
	end
	
	if info ~= nil and next(info) ~= nil then
		local canbuycnt = info.max_num - info.bought
		local canbuy = info.max_num == 0 or canbuycnt > 0
		if CommerceUI.ServerData.limitup then
			local buyBtn = _gt.GetUI("buyBtn")
			if CommerceUI.ServerData.limitup[tonumber(info.Id)] == 1 or canbuy == false then
				GUI.ButtonSetShowDisable(buyBtn, false)
			else
				GUI.ButtonSetShowDisable(buyBtn, true)
			end
		end
	else
		--local refreshBtn = _gt.GetUI("refreshBtn")
		--GUI.ButtonSetShowDisable(refreshBtn, false)
	end	
end
function CommerceUI.RefreshBuy()			--右侧刷新
	--test("RefreshBuy")
    local itemSrc = _gt.GetUI("itemSrc")
    if data.CommerceUI_OnSearch == 0 or nil then
		GUI.LoopScrollRectSetTotalCount(itemSrc, #data.items)
		--test(#data.items)
		if CommerceUI.ItemId ~= nil then
			for i =1, #data.items do
				local info = data.allitems[data.items[i]]
				if info.Id == CommerceUI.ItemId then
					data.itemindex = i
					local num1 = tonumber(data.itemindex-1)
					local num2 = tonumber(#data.items)
					GUI.ScrollRectSetNormalizedPosition(itemSrc,Vector2.New(0,num1/num2))
					CommerceUI.ItemId =nil
				end
			end
		end
		
	elseif data.CommerceUI_OnSearch == 1 then
		GUI.LoopScrollRectSetTotalCount(itemSrc, #data.Input_ConfirmBtnitems)
	end	
    GUI.LoopScrollRectRefreshCells(itemSrc)
	--if data.CommerceUI_OnSearch then
	--	test("data.CommerceUI_OnSearch = "..data.CommerceUI_OnSearch)
	--end
	for mainType, _ in pairs(data.types) do
		local listType = _gt.GetUI("listType" .. mainType)
		local listTypeBtn = _gt.GetUI("listTypeBtn" .. mainType)
		if data.maintype ~= mainType then
			GUI.ButtonSetImageID(listTypeBtn, "1800002030")
			GUI.SetVisible(listType, false)
			local selectMark = GUI.GetChild(listTypeBtn, "selectMark")
			GUI.SetPositionX(selectMark, 30)
			GUI.SetPositionY(selectMark, 0)
			GUI.SetEulerAngles(selectMark, Vector3.New(0, 0, 0))
		else
			if data.maintypeopen[mainType] then
				GUI.ButtonSetImageID(listTypeBtn, "1800002031")
				GUI.SetVisible(listType, true)
				local selectMark = GUI.GetChild(listTypeBtn, "selectMark")
				GUI.SetPositionX(selectMark, 38)
				GUI.SetPositionY(selectMark, 15)
				GUI.SetEulerAngles(selectMark, Vector3.New(0, 0, -90))
			else
				GUI.ButtonSetImageID(listTypeBtn, "1800002031")
				GUI.SetVisible(listType, false)
				local selectMark = GUI.GetChild(listTypeBtn, "selectMark")
				GUI.SetPositionX(selectMark, 30)
				GUI.SetPositionY(selectMark, 0)
				GUI.SetEulerAngles(selectMark, Vector3.New(0, 0, 0))
			end
		end
		if data.CommerceUI_OnSearch == 1 then
			GUI.SetVisible(listType, false)
			GUI.ButtonSetImageID(listTypeBtn, "1800002030")
			local selectMark = GUI.GetChild(listTypeBtn, "selectMark")
			GUI.SetPositionX(selectMark, 30)
			GUI.SetPositionY(selectMark, 0)
			GUI.SetEulerAngles(selectMark, Vector3.New(0, 0, 0))
		end
	end

    for i, _ in pairs(data.types[data.maintype]) do
        local name = "subtype" .. data.maintype .. "_" .. i
        local sub = _gt.GetUI(name)
        if sub then
            if i == data.subType then
                GUI.ButtonSetImageID(sub, "1801302061")
            else
                GUI.ButtonSetImageID(sub, "1801302060")
            end
        end
    end
    ---@type Commerce_Item
	local info = {}
	local descScroll = _gt.GetUI("descScroll")
	local name = _gt.GetUI("name")
	local type = _gt.GetUI("type")
	local level = _gt.GetUI("level")
	local desc = _gt.GetUI("desc")
	GUI.ScrollRectSetNormalizedPosition(descScroll, Vector2.New(0,1))
	if data.commerceSubTabIndex == 1 then
		if data.CommerceUI_OnSearch == 0 or nil then
			info = data.allitems[data.items[data.itemindex]]
		elseif data.CommerceUI_OnSearch == 1 then
			info = data.Input_ConfirmBtnitems[data.itemindex_OnSearch]
		end	
		--test("data.items[data.itemindex] = "..data.items[data.itemindex])
	elseif data.commerceSubTabIndex == 2 then
		info = data.AllOnSellitemIds[tonumber(data.OnsellItemClick_Index)]
		--test("#data.AllOnSellitemIds = "..#data.AllOnSellitemIds)
	end
	local price_constant = _gt.GetUI("price_constant")
	local price_up = _gt.GetUI("price_up")
	local price_down = _gt.GetUI("price_down")
	local price_limit = _gt.GetUI("price_limit")
	local Right_limit_up = _gt.GetUI("Right_limit_up")
	local Right_limit_down = _gt.GetUI("Right_limit_down")
	local minusBtn = _gt.GetUI("minusBtn")
	local plusBtn = _gt.GetUI("plusBtn")
	local countEdit = _gt.GetUI("countEdit")
	local sellBtn = _gt.GetUI("sellBtn")
	
	if info ~= nil and next(info) ~= nil then
		if not info.info then
			local dbItemInfo = DB.GetOnceItemByKey1(info.Id)
			info.info = LogicDefine.NewequipItem(dbItemInfo)
			local tmp = info.info
			tmp.id = dbItemInfo.Id
			tmp.keyname = dbItemInfo.KeyName
			tmp.name = dbItemInfo.Name
			tmp.lv = dbItemInfo.Level
			tmp.desc = dbItemInfo.Info
			tmp.showType = dbItemInfo.ShowType
			tmp.turnBorn = dbItemInfo.TurnBorn
		end
		GUI.StaticSetText(name, info.info.name)
		GUI.StaticSetText(type, "类型: " .. "<color=#b07b27ff>"..info.info.showType.."</color>")
		GUI.StaticSetText(level, "使用等级: " .."<color=#b07b27ff>"..info.info:GetUseLv().."</color>")
		GUI.StaticSetText(desc, "使用效果: " .. info.info.desc)
		GUI.ButtonSetShowDisable(minusBtn, true)
		GUI.ButtonSetShowDisable(plusBtn, true)
		GUI.ButtonSetShowDisable(sellBtn, true)
		GUI.EditSetCanEdit(countEdit,true)
	else
		GUI.StaticSetText(name, "")
		GUI.StaticSetText(type, "")
		GUI.StaticSetText(level, "")
		GUI.StaticSetText(desc, "")
		GUI.SetVisible(price_constant,false)
		GUI.SetVisible(price_up,false)
		GUI.SetVisible(price_down,false)
		GUI.SetVisible(price_limit,false)
		GUI.SetVisible(Right_limit_up,false)
		GUI.SetVisible(Right_limit_down,false)
		GUI.ButtonSetShowDisable(minusBtn, false)
		GUI.ButtonSetShowDisable(plusBtn, false)
		GUI.ButtonSetShowDisable(sellBtn, false)
		GUI.EditSetCanEdit(countEdit,false)
	end
	
	if info ~= nil and next(info) ~= nil then
		if CommerceUI.ServerData.tendency then
			GUI.SetVisible(price_constant,false)
			GUI.SetVisible(price_up,false)
			GUI.SetVisible(price_down,false)
			GUI.SetVisible(price_limit,true)
			if CommerceUI.ServerData.tendency[tonumber(info.Id)] == 1 then
				GUI.SetVisible(price_up,true)
				GUI.StaticSetText(price_limit, "价格上涨")
				GUI.SetColor(price_limit, Color.New(48 / 255, 208 / 255, 96 / 255, 1))
			elseif CommerceUI.ServerData.tendency[tonumber(info.Id)] == -1 then
				GUI.SetVisible(price_down,true)
				GUI.StaticSetText(price_limit, "价格下跌")
				GUI.SetColor(price_limit, Color.New(242 / 255, 80 / 255, 69 / 255, 1))
			else
				GUI.SetVisible(price_constant,true)
				GUI.StaticSetText(price_limit, "价格不变")
				GUI.SetColor(price_limit, UIDefine.BrownColor)
			end
		end
		if CommerceUI.ServerData.limitup then
			GUI.SetVisible(Right_limit_up,false)
			if CommerceUI.ServerData.limitup[tonumber(info.Id)] == 1 then
				GUI.SetVisible(Right_limit_up,true)
				GUI.SetVisible(price_up,false)
				GUI.SetVisible(price_limit,false)
			elseif CommerceUI.ServerData.limitup[tonumber(info.Id)] == 0 then
				GUI.SetVisible(Right_limit_up,false)
			end
		end
		if CommerceUI.ServerData.limitdown then
			GUI.SetVisible(Right_limit_down,false)
			if CommerceUI.ServerData.limitdown[tonumber(info.Id)] == 1 then
				GUI.SetVisible(Right_limit_down,true)
				GUI.SetVisible(price_down,false)
				GUI.SetVisible(price_limit,false)
			elseif CommerceUI.ServerData.limitdown[tonumber(info.Id)] == 0 then
				GUI.SetVisible(Right_limit_down,false)
			end
		end
	else
		--local refreshBtn = _gt.GetUI("refreshBtn")
		--GUI.ButtonSetShowDisable(refreshBtn, false)
	end

	CommerceUI.RefreshBuyCost()
end
--刷新商会界面
function CommerceUI.RefreshCommercePage()
	--test("RefreshCommercePage")
    local commercePage = GUI.Get(panelBgPath .. "/commercePage")
    local commerceBuySubPage = GUI.GetChild(commercePage, "commerceBuySubPage")
    local commerceSellSubPage = GUI.GetChild(commercePage, "commerceSellSubPage")

    if data.commerceSubTabIndex == 1 then
        GUI.SetVisible(commerceBuySubPage, true)
        GUI.SetVisible(commerceSellSubPage, false)
        --CommerceUI.RefreshBuy()
    elseif data.commerceSubTabIndex == 2 then
        GUI.SetVisible(commerceSellSubPage, true)
        GUI.SetVisible(commerceBuySubPage, false)
    end
	CommerceUI.RefreshBuy()
end

--创建商会界面
function CommerceUI.CreateCommercePage()
    local panelBg = GUI.Get(panelBgPath)
    local commercePage = GUI.GroupCreate(panelBg, "commercePage", 0, 0, 0, 0)
    UILayout.CreateSubTab(commerceSubTabList, commercePage, "CommerceUI")
    CommerceUI.CreateCommerceBuySubPage(commercePage)
    --CommerceUI.CreateCommerceSellSubPage(commercePage)
end
function CommerceUI.CreateItem()
    local scroll = _gt.GetUI("itemSrc")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallItem.Create(scroll, tostring(curCount))
    local txt = GUI.CreateStatic(item, "buycnt", " ", 0, 0, 70, 30)
    local sp = GUI.ImageCreate(item, "sellout", "1800404070", 0, 0)
	local Middle_limit_up = GUI.ImageCreate(item, "Middle_limit_up", "1800404090", 142,38,false, 60,30)
	GUI.SetVisible(Middle_limit_up, false)
	local Middle_limit_down = GUI.ImageCreate(item, "Middle_limit_down", "1800404080", 142,38,false, 60,30)
	GUI.SetVisible(Middle_limit_down, false)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Right)
    UILayout.SetSameAnchorAndPivot(sp, UILayout.Right)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "CommerceUI", "OnItemClick")
    return item
end

function CommerceUI.RefreshItem(parameter)
	--test("RefreshItem")
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemui = GUI.GetByGuid(guid)
	
	if data.CommerceUI_OnSearch == 0 then
		GUI.CheckBoxExSetCheck(itemui, index == data.itemindex)
	elseif data.CommerceUI_OnSearch == 1 then
		GUI.CheckBoxExSetCheck(itemui, index == data.itemindex_OnSearch)
	end
	
	if data.CommerceUI_OnSearch == 0 then
		if data.allitems ~= nil and data.items[index] ~= nil then
			local info = data.allitems[data.items[index]]
			if info then
				if not info.info then
					local dbItemInfo = DB.GetOnceItemByKey1(info.Id)
					info.info = LogicDefine.NewequipItem(dbItemInfo)
					local tmp = info.info
					tmp.id = dbItemInfo.Id
					tmp.keyname = dbItemInfo.KeyName
					tmp.name = dbItemInfo.Name
					tmp.lv = dbItemInfo.Level
					tmp.desc = dbItemInfo.Info
					tmp.showType = dbItemInfo.ShowType
					tmp.turnBorn = dbItemInfo.TurnBorn
				end
				MallItem.Refresh(guid, info, data.moneyType)
				if itemui ~= nil then
					local txt = GUI.GetChild(itemui, "buycnt")
					local sp = GUI.GetChild(itemui, "sellout")
					local canbuycnt = info.max_num - info.bought
					local canbuy = info.max_num == 0 or canbuycnt > 0
					if canbuy then
						if info.max_num == 0 then
							GUI.StaticSetText(txt, "不限购")
							GUI.SetColor(txt, UIDefine.Green8Color)
						else
							GUI.SetColor(txt, UIDefine.BrownColor)
							GUI.StaticSetText(txt, canbuycnt)
						end
					end
					GUI.SetVisible(txt, canbuy)
					GUI.SetVisible(sp, not canbuy)
					if CommerceUI.ServerData.NowPrice then
						local coinBg = GUI.GetChild(itemui, "coinBg", false)
						local numText = GUI.GetChild(coinBg, "numText", false)
						if CommerceUI.ServerData.NowPrice[info.Id] then
							local price = CommerceUI.ServerData.NowPrice[info.Id]
							GUI.StaticSetText(numText, price)
						end
					end
					local Middle_limit_up = GUI.GetChild(itemui, "Middle_limit_up", false)
					local Middle_limit_down = GUI.GetChild(itemui, "Middle_limit_down", false)
					if CommerceUI.ServerData.limitup then
						GUI.SetVisible(Middle_limit_up,false)
						if CommerceUI.ServerData.limitup[tonumber(info.Id)] == 1 and canbuy then
							GUI.SetVisible(Middle_limit_up,true)
							GUI.SetVisible(txt,false)
						elseif CommerceUI.ServerData.limitup[tonumber(info.Id)] == 0 then
							GUI.SetVisible(Middle_limit_up,false)
						end
					end
					if CommerceUI.ServerData.limitdown then
						GUI.SetVisible(Middle_limit_down,false)
						if CommerceUI.ServerData.limitdown[tonumber(info.Id)] == 1 and canbuy then
							GUI.SetVisible(Middle_limit_down,true)
							GUI.SetVisible(txt,false)
						elseif CommerceUI.ServerData.limitdown[tonumber(info.Id)] == 0 then
							GUI.SetVisible(Middle_limit_down,false)
						end
					end
				end
			end
		else
			MallItem.Refresh(guid)
		end
	elseif data.CommerceUI_OnSearch == 1 then
		if data.Input_ConfirmBtnitems ~= nil and data.Input_ConfirmBtnitems[index] ~= nil then	
			local info = data.Input_ConfirmBtnitems[index]
			if info then
				if not info.info then
					local dbItemInfo = DB.GetOnceItemByKey1(info.Id)
					info.info = LogicDefine.NewequipItem(dbItemInfo)
					local tmp = info.info
					tmp.id = dbItemInfo.Id
					tmp.keyname = dbItemInfo.KeyName
					tmp.name = dbItemInfo.Name
					tmp.lv = dbItemInfo.Level
					tmp.desc = dbItemInfo.Info
					tmp.showType = dbItemInfo.ShowType
					tmp.turnBorn = dbItemInfo.TurnBorn
				end
				MallItem.Refresh(guid, info, data.moneyType)
				if itemui ~= nil then
					local txt = GUI.GetChild(itemui, "buycnt")
					local sp = GUI.GetChild(itemui, "sellout")
					local canbuycnt = info.max_num - info.bought
					local canbuy = info.max_num == 0 or canbuycnt > 0
					if canbuy then
						if info.max_num == 0 then
							GUI.StaticSetText(txt, "不限购")
							GUI.SetColor(txt, UIDefine.Green8Color)
						else
							GUI.SetColor(txt, UIDefine.BrownColor)
							GUI.StaticSetText(txt, canbuycnt)
						end
					end
					GUI.SetVisible(txt, canbuy)
					GUI.SetVisible(sp, not canbuy)
					if CommerceUI.ServerData.NowPrice then
						local coinBg = GUI.GetChild(itemui, "coinBg", false)
						local numText = GUI.GetChild(coinBg, "numText", false)
						if CommerceUI.ServerData.NowPrice[info.Id] then
							local price = CommerceUI.ServerData.NowPrice[info.Id]
							GUI.StaticSetText(numText, price)
						end
					end
					local Middle_limit_up = GUI.GetChild(itemui, "Middle_limit_up", false)
					local Middle_limit_down = GUI.GetChild(itemui, "Middle_limit_down", false)
					if CommerceUI.ServerData.limitup then
						GUI.SetVisible(Middle_limit_up,false)
						if CommerceUI.ServerData.limitup[tonumber(info.Id)] == 1 and canbuy then
							GUI.SetVisible(Middle_limit_up,true)
							GUI.SetVisible(txt,false)
						elseif CommerceUI.ServerData.limitup[tonumber(info.Id)] == 0 then
							GUI.SetVisible(Middle_limit_up,false)
						end
					end
					if CommerceUI.ServerData.limitdown then
						GUI.SetVisible(Middle_limit_down,false)
						if CommerceUI.ServerData.limitdown[tonumber(info.Id)] == 1 and canbuy then
							GUI.SetVisible(Middle_limit_down,true)
							GUI.SetVisible(txt,false)
						elseif CommerceUI.ServerData.limitdown[tonumber(info.Id)] == 0 then
							GUI.SetVisible(Middle_limit_down,false)
						end
					end
				end
			end
		else
			MallItem.Refresh(guid)
		end
	end
end
-- 创建类型列表
function CommerceUI.CreateTypeList(parent)
	--test("CreateTypeList")
    local typeSrc = GUI.ScrollListCreate(parent, "typeListsrc", 0, 8, 248, 485, false, UIAroundPivot.Top, UIAnchor.Top)
    UILayout.SetSameAnchorAndPivot(typeSrc, UILayout.Top)
	_gt.BindName(typeSrc, "typeSrc")

    for i, value in pairs(data.types) do
        local mainType = i
        local mainTypeName = CommerceUI.typeName[mainType]
        if value then
            -- 父节点按钮
            local listTypeBtn =
				GUI.ButtonCreate(
				typeSrc,
				"listTypeBtn" .. mainType,
				"1800002030",
				0,
				0,
				Transition.ColorTint,
				mainTypeName,
				248,
				62,
				false
            )
            _gt.BindName(listTypeBtn, "listTypeBtn" .. mainType)
            GUI.RegisterUIEvent(listTypeBtn, UCE.PointerClick, "CommerceUI", "OnListTypeBtnClick")
            UILayout.SetSameAnchorAndPivot(listTypeBtn, UILayout.Top)
            GUI.ButtonSetTextFontSize(listTypeBtn, UIDefine.FontSizeXL)
            GUI.ButtonSetTextColor(listTypeBtn, UIDefine.BrownColor)
            GUI.SetPreferredHeight(listTypeBtn, 62)

            local selectMark = GUI.ImageCreate(listTypeBtn, "selectMark", "1801208630", -30, 0)
            UILayout.SetSameAnchorAndPivot(selectMark, UILayout.Right)

            -- 子节点列表框
            local listType = GUI.ListCreate(typeSrc, "listType" .. mainType, 0, 0, 248, 320, false)
            UILayout.SetSameAnchorAndPivot(listType, UILayout.Top)
            GUI.SetVisible(listType, mainType == 0)
            GUI.SetPaddingHorizontal(listType, Vector2.New(9, 9))
            _gt.BindName(listType, "listType" .. mainType)

            -- 子节点
            for subType, item in pairs(value) do
                if CommerceUI.subTypeName[subType] then
                    local name = "subtype" .. mainType .. "_" .. subType
					local listTypeSubBtn =
                        GUI.ButtonCreate(
                        listType,
                        name,
                        "1801302060",
                        0,
                        0,
                        Transition.ColorTint,
                        CommerceUI.subTypeName[subType],
                        230,
                        62,
                        false
                    )
                    UILayout.SetSameAnchorAndPivot(listTypeSubBtn, UILayout.Top)
                    GUI.ButtonSetTextFontSize(listTypeSubBtn, UIDefine.FontSizeXL)
                    GUI.ButtonSetTextColor(listTypeSubBtn, UIDefine.BrownColor)
                    GUI.RegisterUIEvent(listTypeSubBtn, UCE.PointerClick, "CommerceUI", "OnListTypeSubBtnClick")
                    _gt.BindName(listTypeSubBtn, name)
                end
            end
        end
    end
end
--创建商会购买子界面
function CommerceUI.CreateCommerceBuySubPage(commercePage)
    local commerceBuySubPage = GUI.GroupCreate(commercePage, "commerceBuySubPage", 0, 0, 0, 0)
	_gt.BindName(commerceBuySubPage, "commerceBuySubPage")
	
	data.CommerceUI_OnSearch = 0
	
	local panelBg = GUI.Get(panelBgPath)

    local typeScrollBg = GUI.ImageCreate(commerceBuySubPage, "typeScrollBg", "1800400010", -382, 38, false, 265, 505)
    _gt.BindName(typeScrollBg, "typeScrollBg")
    CommerceUI.CreateTypeList(typeScrollBg)

    local itemScrollBg = GUI.ImageCreate(commerceBuySubPage, "itemScrollBg", "1800400010", -40, 38, false, 400, 505)
    local itemScroll =
		GUI.LoopScrollRectCreate(
		itemScrollBg,
		"itemSrc",
		0,
		65,
		400,
		430,
		"CommerceUI",
		"CreateItem",
		"CommerceUI",
		"RefreshItem",
		0,
		false,
		Vector2.New(372, 102),
		1,
		UIAroundPivot.Top,
		UIAnchor.Top
    )
    UILayout.SetSameAnchorAndPivot(itemScroll, UILayout.Top)
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(7, 7))
    _gt.BindName(itemScroll, "itemSrc")

    local tipsBtn = GUI.ButtonCreate(itemScrollBg, "tipsBtn", "1800702030", 20, 20, Transition.ColorTint, "")
    GUI.SetAnchor(tipsBtn, UIAnchor.TopLeft)
    GUI.SetPivot(tipsBtn, UIAroundPivot.TopLeft)
	GUI.RegisterUIEvent(tipsBtn, UCE.PointerClick, "CommerceUI", "OntipsBtnUp")

    local text1 = GUI.CreateStatic(itemScrollBg, "text1", "道具名称", 65, 24, 100, 30)
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text1, UIAnchor.TopLeft)
    GUI.SetPivot(text1, UIAroundPivot.TopLeft)
    GUI.SetColor(text1, UIDefine.BrownColor)

    local text2 = GUI.CreateStatic(itemScrollBg, "text2", "今日限购", -20, 24, 100, 30)
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(text2, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text2, UIAnchor.TopRight)
    GUI.SetPivot(text2, UIAroundPivot.TopRight)
    GUI.SetColor(text2, UIDefine.BrownColor)

    local infoBg = GUI.ImageCreate(panelBg, "infoBg", "1800400010", 345, -110, false, 350, 320)

    local name = GUI.CreateStatic(infoBg, "name", "道具名称", 0, 25, 200, 30)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
    GUI.SetColor(name, UIDefine.BrownColor)
    GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)
    GUI.SetAnchor(name, UIAnchor.Top)
    GUI.SetPivot(name, UIAroundPivot.Center)
    _gt.BindName(name, "name")

    local type = GUI.CreateStatic(infoBg, "type", "类型：", 20, 50, 300, 30, "system", true)
    GUI.StaticSetFontSize(type, UIDefine.FontSizeL)
    GUI.SetColor(type, UIDefine.BrownColor)
    GUI.StaticSetAlignment(type, TextAnchor.MiddleLeft)
    GUI.SetAnchor(type, UIAnchor.TopLeft)
    GUI.SetPivot(type, UIAroundPivot.TopLeft)
    _gt.BindName(type, "type")

    local level = GUI.CreateStatic(infoBg, "level", "使用等级:", 20, 85, 300, 30, "system", true)
    GUI.StaticSetFontSize(level, UIDefine.FontSizeL)
    GUI.SetColor(level, UIDefine.BrownColor)
    GUI.StaticSetAlignment(level, TextAnchor.MiddleLeft)
    GUI.SetAnchor(level, UIAnchor.TopLeft)
    GUI.SetPivot(level, UIAroundPivot.TopLeft)
    _gt.BindName(level, "level")

    -- local sex = GUI.CreateStatic(infoBg, "sex", "性别：", 20, 120, 315, 30)
    -- GUI.StaticSetFontSize(sex, UIDefine.FontSizeL)
    -- GUI.SetColor(sex, UIDefine.BrownColor)
    -- GUI.StaticSetAlignment(sex, TextAnchor.MiddleLeft)
    -- GUI.SetAnchor(sex, UIAnchor.TopLeft)
    -- GUI.SetPivot(sex, UIAroundPivot.TopLeft)
    -- GUI.SetVisible(sex, false)

	local price_limit_Bg = GUI.ImageCreate(infoBg, "price_limit_Bg", "1800400360",0,129,false,300,40)
	local pl = GUI.CreateStatic(price_limit_Bg, "pl", "价格涨跌", -90,1,100,30)
	GUI.StaticSetFontSize(pl, 22)
    GUI.SetColor(pl, UIDefine.BrownColor)
    GUI.StaticSetAlignment(pl, TextAnchor.MiddleLeft)
	local price_constant = GUI.ImageCreate(price_limit_Bg, "price_constant","1800607310", 30,0,false, 25,25)
	_gt.BindName(price_constant, "price_constant")
	GUI.SetVisible(price_constant, true)
	local price_up = GUI.ImageCreate(price_limit_Bg, "price_up","1800607060", 30,0,false, 20,24)
	_gt.BindName(price_up, "price_up")
	GUI.SetVisible(price_up, false)
	local price_down = GUI.ImageCreate(price_limit_Bg, "price_down","1800607070", 30,0,false, 20,24)
	_gt.BindName(price_down, "price_down")
	GUI.SetVisible(price_down, false)
	local price_limit = GUI.CreateStatic(price_limit_Bg, "price_limit", "价格不变", 87,1,100,30)
	GUI.StaticSetFontSize(price_limit, 22)
    GUI.SetColor(price_limit, UIDefine.BrownColor)
    GUI.StaticSetAlignment(price_limit, TextAnchor.MiddleRight)
	_gt.BindName(price_limit, "price_limit")
	local Right_limit_up = GUI.ImageCreate(price_limit_Bg, "Right_limit_up", "1800404090", 82,1,false, 50,25)
	GUI.SetVisible(Right_limit_up,false)
	_gt.BindName(Right_limit_up, "Right_limit_up")
	local Right_limit_down = GUI.ImageCreate(price_limit_Bg, "Right_limit_down", "1800404080", 82,1,false, 50,25)
	GUI.SetVisible(Right_limit_down,false)
	_gt.BindName(Right_limit_down, "Right_limit_down")

    local descScroll =
        GUI.ScrollRectCreate(
        infoBg,
        "descScroll",
        20,
        120,
        315,
        135,
        0,
        false,
        Vector2.New(300, 180),
        UIAroundPivot.TopLeft,
        UIAnchor.TopLeft,
        1
    )
    GUI.SetAnchor(descScroll, UIAnchor.TopLeft)
    GUI.SetPivot(descScroll, UIAroundPivot.TopLeft)
	_gt.BindName(descScroll, "descScroll")

    local desc = GUI.CreateStatic(descScroll, "desc", "描述", 0, 0, 320, 200)
    GUI.StaticSetFontSize(desc, UIDefine.FontSizeL)
    GUI.SetColor(desc, UIDefine.BrownColor)
    GUI.StaticSetAlignment(desc, TextAnchor.UpperLeft)
    GUI.SetAnchor(desc, UIAnchor.TopLeft)
    GUI.SetPivot(desc, UIAroundPivot.TopLeft)
    _gt.BindName(desc, "desc")

    local text1 = GUI.CreateStatic(panelBg, "text1", "数量", 205, 90, 100, 30)
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeL)
    GUI.SetColor(text1, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text1, UIAnchor.Center)
    GUI.SetPivot(text1, UIAroundPivot.Center)

    local text2 = GUI.CreateStatic(commerceBuySubPage, "text2", "花费", 205, 150, 100, 30)
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeL)
    GUI.SetColor(text2, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text2, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text2, UIAnchor.Center)
    GUI.SetPivot(text2, UIAroundPivot.Center)

    local text3 = GUI.CreateStatic(panelBg, "text3", "拥有", 205, 200, 100, 30)
    GUI.StaticSetFontSize(text3, UIDefine.FontSizeL)
    GUI.SetColor(text3, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text3, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text3, UIAnchor.Center)
    GUI.SetPivot(text3, UIAroundPivot.Center)

    local minusBtn = GUI.ButtonCreate(panelBg, "MinusBtn", "1800402140", 280, 90, Transition.ColorTint, "")
	_gt.BindName(minusBtn, "minusBtn")
    local plusBtn = GUI.ButtonCreate(panelBg, "PlusBtn", "1800402150", 480, 90, Transition.ColorTint, "")
	_gt.BindName(plusBtn, "plusBtn")
    local countEdit =
        GUI.EditCreate(
        panelBg,
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
    GUI.RegisterUIEvent(countEdit, UCE.EndEdit, "CommerceUI", "OnBuyCountModify")
    _gt.BindName(countEdit, "countEdit")
    plusBtn:RegisterEvent(UCE.PointerDown)
    plusBtn:RegisterEvent(UCE.PointerUp)
    plusBtn:RegisterEvent(UCE.PointerClick)
    minusBtn:RegisterEvent(UCE.PointerDown)
    minusBtn:RegisterEvent(UCE.PointerUp)
    minusBtn:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(plusBtn, UCE.PointerDown, "CommerceUI", "OnPlusBtnDown")
    GUI.RegisterUIEvent(plusBtn, UCE.PointerUp, "CommerceUI", "OnPlusBtnUp")
    GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "CommerceUI", "OnPlusBtnClick")
    GUI.RegisterUIEvent(minusBtn, UCE.PointerDown, "CommerceUI", "OnMinusBtnDown")
    GUI.RegisterUIEvent(minusBtn, UCE.PointerUp, "CommerceUI", "OnMinusBtnUp")
    GUI.RegisterUIEvent(minusBtn, UCE.PointerClick, "CommerceUI", "OnMinusBtnClick")

    local spendBg = UILayout.CreateAttrBar(panelBg, "spendBg", 380, 152, 252, UILayout.Center)
    UILayout.RefreshAttrBar(spendBg, UIDefine.GetMoneyEnum(data.moneyType), 0)
    _gt.BindName(spendBg, "spendBg")

    local owebg = UILayout.CreateAttrBar(panelBg, "ownBg", 380, 202, 252, UILayout.Center)
    UILayout.RefreshAttrBar(owebg, UIDefine.GetMoneyEnum(data.moneyType), 0)
    _gt.BindName(owebg, "owebg")

    local refreshBtn =
        GUI.ButtonCreate(
        commerceBuySubPage,
        "refreshBtn",
        "1800402080",
        260,
        260,
        Transition.ColorTint,
        "刷新",
        160,
        50,
        false
    )
    GUI.SetEventCD(refreshBtn, UCE.PointerClick, 0.5)
    GUI.SetIsOutLine(refreshBtn, true)
    GUI.ButtonSetTextFontSize(refreshBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(refreshBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(refreshBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(refreshBtn, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(refreshBtn, UCE.PointerClick, "CommerceUI", "OnRefreshBtnClick")
	_gt.BindName(refreshBtn, "refreshBtn")

    local buyBtn =
        GUI.ButtonCreate(
        commerceBuySubPage,
        "buyBtn",
        "1800402080",
        430,
        260,
        Transition.ColorTint,
        "购买",
        160,
        50,
        false
    )
    GUI.SetIsOutLine(buyBtn, true)
    GUI.ButtonSetTextFontSize(buyBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(buyBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(buyBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(buyBtn, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(buyBtn, UCE.PointerClick, "CommerceUI", "OnBuyBtnClick")
	_gt.BindName(buyBtn, "buyBtn")
	
	local Input = GUI.EditCreate(commerceBuySubPage, "Input", "1800001040", "请输入要查找的商品",-67,-245, Transition.ColorTint, "system", 345, 48)
	GUI.EditSetFontSize(Input, 22)
	GUI.EditSetTextColor(Input, UIDefine.BrownColor)
	GUI.SetPlaceholderTxtColor(Input, UIDefine.GrayColor)
	GUI.RegisterUIEvent(Input, UCE.EndEdit, "CommerceUI", "OnSearchInput")
	_gt.BindName(Input, "Input")

	local Input_ClearBtn = GUI.ButtonCreate(Input, "Input_ClearBtn", "1800408220", 148,0,Transition.None, "", 25,25,false)
	--GUI.SetVisible(Input_ClearBtn, false)
	_gt.BindName(Input_ClearBtn, "Input_ClearBtn")
	GUI.SetVisible(Input_ClearBtn, false)
	GUI.RegisterUIEvent(Input_ClearBtn, UCE.PointerClick, "CommerceUI", "OnInput_ClearBtnClick")
	
	local Input_ConfirmBtn = GUI.ButtonCreate(commerceBuySubPage, "Input_ConfirmBtn", "1800802010",133,-244,Transition.ColorTint, "", 45,45,false)
	GUI.RegisterUIEvent(Input_ConfirmBtn, UCE.PointerClick, "CommerceUI", "OnInput_ConfirmBtnClick")
end

--创建商会出售子界面
function CommerceUI.CreateCommerceSellSubPage(commercePage)
    --CommerceUI.GetOnSellItemData()
	local commerceSellSubPage = GUI.GroupCreate(commercePage, "commerceSellSubPage", 0, 0, 0, 0)
	_gt.BindName(commerceSellSubPage,"commerceSellSubPage")
	GUI.SetVisible(commerceSellSubPage, false)
	local SellSubPageBg = GUI.ImageCreate(commerceSellSubPage, "SellSubPageBg", "1800400010", -177,38,false, 674,505)
	
	local itemLoopScroll = GUI.LoopScrollRectCreate(SellSubPageBg, "itemLoopScroll", 1,0,654,475, "CommerceUI", "CreateitemLoopScroll", "CommerceUI", "RefreshitemLoopScroll", 6, false, Vector2.New(80, 80), 7, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
	_gt.BindName(itemLoopScroll, "itemLoopScroll")
	
	local text2 = GUI.CreateStatic(commerceSellSubPage, "text2", "售价", 205, 150, 100, 30)
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeL)
    GUI.SetColor(text2, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text2, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text2, UIAnchor.Center)
    GUI.SetPivot(text2, UIAroundPivot.Center)
	
	local sellBtn = GUI.ButtonCreate(commerceSellSubPage, "sellBtn", "1800402080", 345, 260, Transition.ColorTint, "出售",160,50,false)
    GUI.SetIsOutLine(sellBtn, true)
    GUI.ButtonSetTextFontSize(sellBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(sellBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(sellBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(sellBtn, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(sellBtn, UCE.PointerClick, "CommerceUI", "OnSellBtnClick")
	_gt.BindName(sellBtn, "sellBtn")
	if data.AllOnSellitemIds and next(data.AllOnSellitemIds) then
		local a = 0
		if #data.AllOnSellitemIds < 42 then
			a = 42
			GUI.LoopScrollRectSetTotalCount(itemLoopScroll, a)
		else
			a = (math.ceil(#data.AllOnSellitemIds/7)) * 7
			GUI.LoopScrollRectSetTotalCount(itemLoopScroll, a)
		end
	else
		GUI.LoopScrollRectSetTotalCount(itemLoopScroll, 42)
	end
end

local SellItemLoopScr_OwnNumTB = {}		--用于储存出售页每种道具的数量

function CommerceUI.CreateitemLoopScroll()	
	local itemLoopScroll = _gt.GetUI("itemLoopScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemLoopScroll);
	local index = tostring(tonumber(curCount) + 1)
	GUI.ScrollRectSetChildSpacing(itemLoopScroll, Vector2.New(15, 7))
	local Bag_itemicon = ItemIcon.Create(itemLoopScroll, "Bag_itemicon"..index, 0, 0)
	GUI.RegisterUIEvent(Bag_itemicon, UCE.PointerClick, "CommerceUI", "OnsellItemClick");
	local Selected_icon = GUI.ImageCreate(Bag_itemicon, "Selected_icon", "1800400280", 0,0,false, 87,87)
	GUI.SetVisible(Selected_icon, false)
	GUI.SetData(Bag_itemicon, "Index", index)
	return Bag_itemicon;
end

function CommerceUI.RefreshitemLoopScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	
	local Bag_itemicon = GUI.GetByGuid(guid)
	ItemIcon.SetEmpty(Bag_itemicon)
	local Selected_icon = GUI.GetChild(Bag_itemicon,"Selected_icon")
	GUI.SetVisible(Selected_icon, index == tonumber(data.OnsellItemClick_Index))	
	if data.AllOnSellitemIds ~= nil and data.AllOnSellitemIds[index] ~= nil then
        local info = data.AllOnSellitemIds[index]
		local infoDB = DB.GetOnceItemByKey1(info.Id)
		ItemIcon.BindItemDB(Bag_itemicon, infoDB)
		--test("info.Id = "..info.Id)
		GUI.SetData(Bag_itemicon, "info.Id", info.Id)
		GUI.SetIsRaycastTarget(Bag_itemicon,true)
		if infoDB['Type'] == 6 then
			local infoData = LD.GetItemDataByGuid(data.AllOnSellitemGuids[index], item_container_type.item_container_guard_bag)
			ItemIcon.BindItemData(Bag_itemicon, infoData)
			local amount = infoData:GetAttr(ItemAttr_Native.Amount)
			SellItemLoopScr_OwnNumTB[index] = amount
		elseif infoDB['Type'] == 3 and infoDB['Subtype'] == 9 then
			local infoData = LD.GetItemDataByGuid(data.AllOnSellitemGuids[index], item_container_type.item_container_gem_bag)
			ItemIcon.BindItemData(Bag_itemicon, infoData)
			local amount = infoData:GetAttr(ItemAttr_Native.Amount)
			SellItemLoopScr_OwnNumTB[index] = amount
		else
			local infoData = LD.GetItemDataByGuid((data.AllOnSellitemGuids[index]), item_container_type.item_container_bag)
			ItemIcon.BindItemData(Bag_itemicon, infoData)
			local amount = infoData:GetAttr(ItemAttr_Native.Amount)
			SellItemLoopScr_OwnNumTB[index] = amount
		end
	else
		GUI.SetIsRaycastTarget(Bag_itemicon,false)
		GUI.SetVisible(Selected_icon, false)
	end
end

function CommerceUI.OnsellItemClick(guid)			--出售页点击道具触发的方法
	--print("OnsellItemClick")
	local Bag_itemicon = GUI.GetByGuid(guid)
	local index = GUI.ItemCtrlGetIndex(Bag_itemicon) + 1
	local itemLoopScroll = _gt.GetUI("itemLoopScroll")
	data.OnsellItemClick_Index = index
	GUI.LoopScrollRectRefreshCells(itemLoopScroll)
	data.curBuyCount = 1
	local countEdit = _gt.GetUI("countEdit")
	GUI.EditSetTextM(countEdit, data.curBuyCount)
	CommerceUI.RefreshBuy()
	CommerceUI.ClientRefresh()
	local info_Id = GUI.GetData(Bag_itemicon, "info.Id")
end

--点击商会购买子页签
function CommerceUI.OnBuySubTabBtnClick()
	--test("OnBuySubTabBtnClick")
    data.commerceSubTabIndex = 1
    --local commercePage = GUI.Get(panelBgPath .. "/commercePage")
    local commerceBuySubPage = _gt.GetUI("commerceBuySubPage")
	GUI.SetVisible(commerceBuySubPage, true)
	local commerceSellSubPage = _gt.GetUI("commerceSellSubPage")
	GUI.SetVisible(commerceSellSubPage, false)
	data.curBuyCount = 1
	data.CommerceUI_OnSearch = 0
	CommerceUI.ClientRefresh()
end

--点击商会出售子页签
function CommerceUI.OnSellSubTabBtnClick()
	data.commerceSubTabIndex = 2
	local commerceBuySubPage = _gt.GetUI("commerceBuySubPage")
	GUI.SetVisible(commerceBuySubPage, false)
	local commerceSellSubPage = _gt.GetUI("commerceSellSubPage")
	if not commerceSellSubPage then
		local commercePage = GUI.Get(panelBgPath .. "/commercePage")
		CommerceUI.CreateCommerceSellSubPage(commercePage)
	end
	GUI.SetVisible(commerceSellSubPage, true)
	data.OnsellItemClick_Index = 0
	CommerceUI.GetOnSellItemData()
	local itemLoopScroll = _gt.GetUI("itemLoopScroll")
	if data.AllOnSellitemIds and next(data.AllOnSellitemIds) then
		local a = 0
		if #data.AllOnSellitemIds < 42 then
			a = 42
			GUI.LoopScrollRectSetTotalCount(itemLoopScroll, a)
		else
			a = (math.ceil(#data.AllOnSellitemIds/7)) * 7
			GUI.LoopScrollRectSetTotalCount(itemLoopScroll, a)
		end
		--print("=====出售页循环列表生成"..a.."个格子")
	else
		GUI.LoopScrollRectSetTotalCount(itemLoopScroll, 42)
		--print("出售页循环列表生成42个格子")
	end
	GUI.LoopScrollRectRefreshCells(itemLoopScroll)
	data.CommerceUI_OnSearch = 0
	local Bag_itemicon1 = _gt.GetUI("Bag_itemicon1")
	local guid = GUI.GetGuid(Bag_itemicon1)
	CommerceUI.OnsellItemClick(guid)
end

--购买一级页签
function CommerceUI.OnListTypeBtnClick(guid)
	--test("1178     OnListTypeBtnClick")
	for key, _ in pairs(data.types) do
        if _gt.GetGuid("listTypeBtn" .. key) == guid then
            if data.maintype ~= key then
                data.maintype = key
                data.subType = 0
                data.itemindex = 1
                data.curBuyCount = 1
                data.maintypeopen[key] = true
            else
                data.maintypeopen[key] = not data.maintypeopen[key]
            end
        else
            data.maintypeopen[key] = false
        end
    end

	data.CommerceUI_OnSearch = 0				--表示不在搜索物品状态
	data.itemindex_OnSearch = 1
    CommerceUI.ClientRefresh()
end
--购买2级页签
function CommerceUI.OnListTypeSubBtnClick(guid)
	--test("OnListTypeSubBtnClick")
    for key, _ in pairs(data.types[data.maintype]) do
        if _gt.GetGuid("subtype" .. data.maintype .. "_" .. key) == guid then
            if data.subType == key then
                return
            end
            data.subType = key
            data.itemindex = 1
            data.curBuyCount = 1
            break
        end
    end
	data.CommerceUI_OnSearch = 0
	data.itemindex_OnSearch = 1
    CommerceUI.ClientRefresh()
end
function CommerceUI.OnItemClick(guid)
	--test("OnItemClick")
    local item = GUI.GetByGuid(guid)
    if item then
        local index = GUI.CheckBoxExGetIndex(item) + 1
		--test("OnItemClick    index = "..index)
        --if index == data.itemindex then
        --    return
        --end
		if data.CommerceUI_OnSearch == 0 then
			data.itemindex = index
		elseif data.CommerceUI_OnSearch == 1 then
			data.itemindex_OnSearch = index
		end
        data.curBuyCount = 1
    end

	CommerceUI.ClientRefresh()
end

function CommerceUI.OntipsBtnUp(guid)
	local btn = GUI.GetByGuid(guid);
	local panelBg = GUI.Get(panelBgPath)
	local hint = _gt.GetUI("hint")
	--local hint = GUI.GetChild(panelBg, "hint");
	if hint == nil then
		local hint = GUI.ImageCreate(panelBg, "hint", "1800400290", -5, -6, false, 440, 210)
		local msg = "商会每日24点刷新限购数量、涨跌幅度。\n限购：玩家单人每天可购买的道具数量。\n涨停：价格剧烈上涨导致商品无法购买。\n跌停：价格剧烈下跌导致商品无法出售。\n售罄：限购数量已被买完，当日无法继续购买该商品。";
		local text = GUI.CreateStatic(hint, "text", msg, 0, 0, 410, 210);
		GUI.StaticSetFontSize(text, 22);
		GUI.SetIsRemoveWhenClick(hint, true)
		_gt.BindName(hint, "hint")
		GUI.AddWhiteName(hint, GUI.GetGuid(btn));
	else
		GUI.Destroy(hint);
	end

end

function CommerceUI.OnMinusBtnClick()						--减号
    data.curBuyCount = data.curBuyCount - 1
	test("data.curBuyCount = "..data.curBuyCount)
	if data.curBuyCount < 1 then
		if data.commerceSubTabIndex == 1 then
			CL.SendNotify(NOTIFY.ShowBBMsg,"无法减少购买数量，最小可购买数量为1")
		elseif data.commerceSubTabIndex == 2 then
			CL.SendNotify(NOTIFY.ShowBBMsg,"无法减少出售数量，最小可出售数量为1")
		end
		data.curBuyCount = 1
	end
    CommerceUI.RefreshBuyCost()
end

function CommerceUI.OnMinusBtnDown()
	local fun = function()
        CommerceUI.OnMinusBtnClick();
    end

    if CommerceUI.Timer == nil then
        CommerceUI.Timer = Timer.New(fun, 0.3, -1)
    else
        CommerceUI.Timer:Stop();
        CommerceUI.Timer:Reset(fun, 0.3, 1)
    end
    CommerceUI.Timer:Start();
end

function CommerceUI.OnMinusBtnUp()
	if CommerceUI.Timer ~= nil then
        CommerceUI.Timer:Stop();
        CommerceUI.Timer = nil;
    end
end

function CommerceUI.OnPlusBtnClick()						--加号
    data.curBuyCount = data.curBuyCount + 1
	if data.commerceSubTabIndex == 1 then
		local info = CommerceUI.GetItem()
		local BuyMax = info.onceBuyLimit
		if data.curBuyCount > BuyMax then
			data.curBuyCount = BuyMax
			CL.SendNotify(NOTIFY.ShowBBMsg,"无法增加购买数量，一次性只能购买"..data.curBuyCount.."个")
		end
    elseif data.commerceSubTabIndex == 2 then
		--local sellBtn = _gt.GetUI("sellBtn")
		local index = data.OnsellItemClick_Index
		if index then
			local Own_Num = tonumber(SellItemLoopScr_OwnNumTB[tonumber(index)])
			local info = data.AllOnSellitemIds[tonumber(index)]	
			local SellMax = tonumber(info.sellMax)
			if data.curBuyCount > Own_Num or data.curBuyCount > SellMax then
				if Own_Num < SellMax then
					data.curBuyCount = Own_Num
				else
					data.curBuyCount = SellMax
				end
				CL.SendNotify(NOTIFY.ShowBBMsg,"无法增加出售数量，一次性只能出售"..data.curBuyCount.."个")				--0000
			end
		end
	end
	CommerceUI.RefreshBuyCost()
end

function CommerceUI.OnPlusBtnDown()
	local fun = function()
        CommerceUI.OnPlusBtnClick();
    end
    if CommerceUI.Timer == nil then
        CommerceUI.Timer = Timer.New(fun, 0.3, -1)
    else
        CommerceUI.Timer:Stop();
        CommerceUI.Timer:Reset(fun, 0.3, 1)
    end
    CommerceUI.Timer:Start();
end

function CommerceUI.OnPlusBtnUp()
	if CommerceUI.Timer ~= nil then
        CommerceUI.Timer:Stop();
        CommerceUI.Timer = nil;
    end
end

function CommerceUI.OnBuyCountModify()
    local str = GUI.EditGetTextM(_gt.GetUI("countEdit"))
    data.curBuyCount = tonumber(str) or 1
	if data.commerceSubTabIndex == 1 then
		--CommerceUI.RefreshBuyCost()
    elseif data.commerceSubTabIndex == 2 then
		--local sellBtn = _gt.GetUI("sellBtn")
		local index = data.OnsellItemClick_Index
		if index then
			local Own_Num = tonumber(SellItemLoopScr_OwnNumTB[tonumber(index)])
			--print("Own_Num = "..Own_Num)
			local info = data.AllOnSellitemIds[tonumber(index)]	
			local SellMax = tonumber(info.sellMax)
			--print("SellMax = "..SellMax)
			if data.curBuyCount > Own_Num or data.curBuyCount > SellMax then
				if Own_Num < SellMax then
					data.curBuyCount = Own_Num
				else
					data.curBuyCount = SellMax
				end
				CL.SendNotify(NOTIFY.ShowBBMsg,"无法增加出售数量，一次性只能出售"..data.curBuyCount.."个")				--0000
			end
		end
	end
	CommerceUI.RefreshBuyCost()
end

function CommerceUI.OnRefreshBtnClick()
    --CL.SendNotify(NOTIFY.ShowBBMsg, "刷新完成")
    CommerceUI.GetDate()
end

function CommerceUI.OnBuyBtnClick()
	local info = {}
	if data.CommerceUI_OnSearch == 0 then
		info = CommerceUI.GetItem()
	elseif data.CommerceUI_OnSearch == 1 then
		info = data.Input_ConfirmBtnitems[data.itemindex_OnSearch]
	end
    if info and data.curBuyCount > 0 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormExchange", "BuyItem", info.Id, data.curBuyCount)
    end
end

function CommerceUI.OnInput_ClearBtnClick()
	local Input_ClearBtn = _gt.GetUI("Input_ClearBtn")
	local Input = _gt.GetUI("Input")
	local Txt = GUI.EditGetTextM(Input)
	if Txt and string.len(Txt) > 0 and data.CommerceUI_OnSearch == 1 then
		data.CommerceUI_OnSearch = 0
		data.itemindex_OnSearch = 1
		CommerceUI.ReSet()
	end
	GUI.EditSetTextM(Input, "")
	GUI.SetVisible(Input_ClearBtn, false)
end

function CommerceUI.OnInput_ConfirmBtnClick()
	data.Input_ConfirmBtnitems = {}
	local Input = _gt.GetUI("Input")
	local Txt = GUI.EditGetTextM(Input)
	local list = data.allitems
	--test("#data.allitems = "..#data.allitems)
	if Txt and string.len(Txt) > 0 then
		data.CommerceUI_OnSearch = 1
		for i = 1, #list do
			local Name = list[i].name
			--test("Name = "..Name)
			if string.match(tostring(Name), Txt) ~= nil then
				table.insert(data.Input_ConfirmBtnitems, list[i])
			end
		end
		for i = 0, #data.types do
			local listType = _gt.GetUI("listType"..i)				--次级列表
			local listTypeBtn = _gt.GetUI("listTypeBtn"..i)         --大类选项按钮
			GUI.ButtonSetImageID(listTypeBtn, "1800002030")
            GUI.SetVisible(listType,false)
			data.maintypeopen[i] = false
			local selectMark = GUI.GetChild(listTypeBtn, "selectMark")
			GUI.SetPositionX(selectMark, 30)
			GUI.SetPositionY(selectMark, 0)
			GUI.SetEulerAngles(selectMark, Vector3.New(0, 0, 0))
		end
		local itemSrc = _gt.GetUI("itemSrc")
		GUI.LoopScrollRectSetTotalCount(itemSrc, #data.Input_ConfirmBtnitems)
		GUI.LoopScrollRectRefreshCells(itemSrc)
	
		if #data.Input_ConfirmBtnitems == 0 then
			local price_constant = _gt.GetUI("price_constant")
			local price_up = _gt.GetUI("price_up")
			local price_down = _gt.GetUI("price_down")
			local price_limit = _gt.GetUI("price_limit")
			local Right_limit_up = _gt.GetUI("Right_limit_up")
			local Right_limit_down = _gt.GetUI("Right_limit_down")
			GUI.SetVisible(price_constant,false)
			GUI.SetVisible(price_up,false)
			GUI.SetVisible(price_down,false)
			GUI.SetVisible(price_limit,false)
			GUI.SetVisible(Right_limit_up,false)
			GUI.SetVisible(Right_limit_down,false)
			local name = _gt.GetUI("name")
			local type = _gt.GetUI("type")
			local level = _gt.GetUI("level")
			local desc = _gt.GetUI("desc")
			GUI.StaticSetText(name, "")
			GUI.StaticSetText(type, "")
			GUI.StaticSetText(level, "")
			GUI.StaticSetText(desc, "")
		end
	end
end

function CommerceUI.OnSellBtnClick()
	--test("OnSellBtnClick")
	local sellBtn = _gt.GetUI("sellBtn")
	local index = data.OnsellItemClick_Index
	--test("index = "..index)
    if index and data.curBuyCount > 0 then
		--local info = data.AllOnSellitemIds[tonumber(index)]	
		print("OnSellBtnClick index = "..index)
		local guid = data.AllOnSellitemGuids[tonumber(index)]
		--test("guid = "..guid)
		CL.SendNotify(NOTIFY.SubmitForm, "FormExchange", "SellItem", guid, data.curBuyCount)
	end
end

function CommerceUI.ReSet()
	local listType = _gt.GetUI("listType0")
	local Visible = GUI.GetVisible(listType)
	--test("Visible = "..tostring(Visible))
	if not Visible then
		local listTypeBtn = _gt.GetUI("listTypeBtn0")
		local guid = GUI.GetGuid(listTypeBtn)
		CommerceUI.OnListTypeBtnClick(guid)
	end
	local subtype0_0 = _gt.GetUI("subtype0_0")			--根据书写格式得出的第一个二级选项的名字
	local guid = GUI.GetGuid(subtype0_0)
	CommerceUI.OnListTypeSubBtnClick(guid)
	
	local typeSrc = _gt.GetUI("typeSrc")
	GUI.ScrollRectSetNormalizedPosition(typeSrc, Vector2.New(0,1))
end

function CommerceUI.GetOnSellItemData()			--获取出售页的道具数据
	--test("开始录入出售数据")
	local tempID = {}
	data.AllOnSellitemIds = {}
	data.AllOnSellitemGuids = {}
	local itemBag_Count = LD.GetItemCount(item_container_type.item_container_bag)
	for i = 0, itemBag_Count - 1 do
		local itemGuid = tostring(LD.GetItemGuidByItemIndex(i, item_container_type.item_container_bag));
		--test("itemGuid = "..itemGuid)
		local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid, item_container_type.item_container_bag);
		if DB.GetOnceExchangeByKey1(itemId) and DB.GetOnceExchangeByKey1(itemId)['Id'] ~= 0 then
			table.insert(tempID, itemId)
			table.insert(data.AllOnSellitemGuids, itemGuid)
		end
	end
	
	local gemBag_Count = LD.GetItemCount(item_container_type.item_container_gem_bag)
	for i = 0, gemBag_Count - 1 do
		local gemGuid = tostring(LD.GetItemGuidByItemIndex(i, item_container_type.item_container_gem_bag));
		--test("gemGuid = "..gemGuid)
		local gemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, gemGuid, item_container_type.item_container_gem_bag);
		if DB.GetOnceExchangeByKey1(gemId) and DB.GetOnceExchangeByKey1(gemId)['Id'] ~= 0 then
			table.insert(tempID, gemId);
			table.insert(data.AllOnSellitemGuids, gemGuid)
		end
	end
	
	local guardBag_Count = LD.GetItemCount(item_container_type.item_container_guard_bag)
	for i = 0, guardBag_Count - 1 do
		local guardGuid = tostring(LD.GetItemGuidByItemIndex(i, item_container_type.item_container_guard_bag));
		--test("guardGuid = "..guardGuid)
		local guardId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, guardGuid, item_container_type.item_container_guard_bag);
		if DB.GetOnceExchangeByKey1(guardId) and DB.GetOnceExchangeByKey1(guardId)['Id'] ~= 0 then
			table.insert(tempID, guardId)
			table.insert(data.AllOnSellitemGuids, guardGuid)
		end
	end
	for i = 1, #tempID do
		local id = tempID[i]
		local db = DB.GetOnceExchangeByKey1(id)
		local index = i
		local info = {}
		info.Id = id
		info.keyname = db.KeyName
		info.price = db.Buy
		info.sell = db.Sell
		info.discount = 100
		info.max_num = db.Number
		info.total_num = 0
		info.bought = 0
		info.total = 0
		info.onceBuyLimit = db.BuyMax
		info.sellMax = db.SellMax
		--test("info.sellMax = "..info.sellMax)
		info.type = db.Type
		info.subType = db.SubType
		info.template_type = 0
		local dbItemInfo = DB.GetOnceItemByKey2(info.keyname)
		info.info = LogicDefine.NewequipItem(dbItemInfo)
		local tmp = info.info
		tmp.id = dbItemInfo.Id
		tmp.keyname = dbItemInfo.KeyName
		tmp.name = dbItemInfo.Name
		tmp.lv = dbItemInfo.Level
		tmp.desc = dbItemInfo.Info
		tmp.showType = dbItemInfo.ShowType
		tmp.turnBorn = dbItemInfo.TurnBorn
		
		data.AllOnSellitemIds[index] = info
	end
end

function CommerceUI.OnSellRefresh()						--出售后，服务器调用函数
	local last_Num = #data.AllOnSellitemIds
	CommerceUI.GetOnSellItemData()
	local itemLoopScroll = _gt.GetUI("itemLoopScroll")
	--test("#data.AllOnSellitemIds = "..#data.AllOnSellitemIds)
	if data.AllOnSellitemIds and next(data.AllOnSellitemIds) then
		local a = 0
		if #data.AllOnSellitemIds < 42 then
			a = 42
			GUI.LoopScrollRectSetTotalCount(itemLoopScroll, a)
		else
			a = (math.ceil(#data.AllOnSellitemIds/7)) * 7
			GUI.LoopScrollRectSetTotalCount(itemLoopScroll, a)
		end
	else
		GUI.LoopScrollRectSetTotalCount(itemLoopScroll, 42)
	end
	GUI.LoopScrollRectRefreshCells(itemLoopScroll)
	local index = data.OnsellItemClick_Index
	local Own_Num = tonumber(SellItemLoopScr_OwnNumTB[tonumber(index)]) - tonumber(data.curBuyCount)		--临时方法，待改
	if Own_Num < tonumber(data.curBuyCount) then
		data.curBuyCount = Own_Num
		local countEdit = _gt.GetUI("countEdit")
		GUI.EditSetTextM(countEdit, data.curBuyCount)
	end
	if last_Num - #data.AllOnSellitemIds > 0 then
		data.curBuyCount = 1
		data.OnsellItemClick_Index = tonumber(index) - 1
		if data.OnsellItemClick_Index <= 1 then
			data.OnsellItemClick_Index = 1
		end
	end
	GUI.LoopScrollRectRefreshCells(itemLoopScroll)
	CommerceUI.RefreshBuy()
end

function CommerceUI.OnSearchInput()
	local Input_ClearBtn = _gt.GetUI("Input_ClearBtn")
	GUI.SetVisible(Input_ClearBtn, true)
end

function CommerceUI.OnCommerceUITabBtnClick()
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	Key = tabList[1][1]
	Level = MainUI.MainUISwitchConfig["交易行"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		CommerceUI.TabIndex = 1 
		UILayout.OnTabClick(1, tabList)
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(CommerceUI.TabIndex, tabList)
		return
	end
end

function CommerceUI.OnBourseUITabBtnClick() 
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tabList[2][1]
	local Level = MainUI.MainUISwitchConfig["交易行"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		CommerceUI.TabIndex = 2
		UILayout.OnTabClick(1, tabList)
		GUI.SetVisible(GUI.Get("BourseUI/panelCover"), true)
		GUI.SetVisible(GUI.Get("BourseUI/panelBg"), true)
		GUI.OpenWnd("BourseUI")
		CommerceUI.OnExit()
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(CommerceUI.TabIndex, tabList)
		return
	end
end

