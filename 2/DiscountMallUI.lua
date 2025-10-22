local DiscountMallUI = {
    ---@type DiscountClassify_Item[]
    item_info = {},
    ---@type DiscountMallRefresh
    Global = {},
    Refresh_Num = 0,
    refreshTimer = nil
}
_G.DiscountMallUI = DiscountMallUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local test = function()
end
local panelBgPath = "DiscountMallUI/panelBg"
local defTxt = "刷新时间%s 还有%s自动刷新"
local guidt = UILayout.NewGUIDUtilTable()
function DiscountMallUI.InitData()
    return {
        index = 1,
        indexGuid = int64.new(0),
        num = 1,
        ---@type DiscountItem[]
        Currency_Classify_Item = {},
        refreshTime = 0,
        refreshIndex = 0,
        delaytime = 0,
        indexName = "",
        refreshNum = 0
    }
end
---@param  item_info DiscountClassify_Item
---@return DiscountItem
local DiscountClassify_Item2Classify_Item = function(item_info)
    ---@type DiscountItem
    local info = {}
    if item_info then
        info.max_num = 0
        info.bought = 0
        if item_info.itemkey then
            info.keyname = item_info.itemkey
            info.template_type = 0
        elseif item_info.petkey then
            info.keyname = item_info.petkey
            info.template_type = 1
        else
            print("没有合适的keyname")
        end
        info.price = item_info.market_price
        info.money_type = item_info.money_type
        info.bind = item_info.bind
        info.total_num = item_info.limit or 0
        info.total = item_info.bought or 0
        info.discount = item_info.discount
    end
    return info
end
local data = DiscountMallUI.InitData()
function DiscountMallUI.OnExitGame()
    data = DiscountMallUI.InitData()
end
function DiscountMallUI.OnExit()
    guidt = nil
    GUI.DestroyWnd("DiscountMallUI")
end
function DiscountMallUI.Main(parameter)
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("DiscountMallUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("DiscountMallUI", "DiscountMallUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "特    惠", "DiscountMallUI", "OnExit")
    local mallBuyPage = GUI.GroupCreate(panelBg, "mallBuyPage", 0, 0, 0, 0)
    guidt.BindName(mallBuyPage, "mallBuyPage")

    local ItemScrollBg = GUI.ImageCreate(mallBuyPage, "ItemScrollBg", "1800400010", -180, -20, false, 670, 500)
    guidt.BindName(ItemScrollBg, "itemScrollBg")
    local itemScroll =
        GUI.LoopScrollRectCreate(
        ItemScrollBg,
        "itemScroll",
        0,
        0,
        660,
        480,
        "DiscountMallUI",
        "CreatItemPool",
        "DiscountMallUI",
        "RefreshItemScroll",
        0,
        false,
        Vector2.New(320, 178),
        2,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(6, 6))
    guidt.BindName(itemScroll, "itemScroll")

    local infoBg, countEdit, plusBtn, minusBtn, spendBg, ownBg, buyBtn = MallItem.CreateRightInfo(mallBuyPage)
    GUI.RegisterUIEvent(countEdit, UCE.EndEdit, "DiscountMallUI", "OnBuyCountModify")
    guidt.BindName(countEdit, "countEdit")
    guidt.BindName(infoBg, "infoBg")
    GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "DiscountMallUI", "OnPlusBtnClick")
    GUI.RegisterUIEvent(minusBtn, UCE.PointerClick, "DiscountMallUI", "OnMinusBtnClick")

    guidt.BindName(spendBg, "spendBg")
    guidt.BindName(ownBg, "ownBg")
    GUI.RegisterUIEvent(buyBtn, UCE.PointerClick, "DiscountMallUI", "OnBuyBtnClick")
    local txtRefresher = GUI.CreateStatic(ItemScrollBg, "txtRefresher", " ", 0, 48, 450, 30)
    UILayout.SetSameAnchorAndPivot(txtRefresher, UILayout.BottomLeft)
    GUI.StaticSetFontSize(txtRefresher, UIDefine.FontSizeL)
    GUI.SetColor(txtRefresher, UIDefine.BrownColor)
    GUI.StaticSetAlignment(txtRefresher, TextAnchor.MiddleLeft)
    guidt.BindName(txtRefresher, "txtRefresher")

    local btnRefresh =
        GUI.ButtonCreate(
        ItemScrollBg,
        "btnRefresh",
        "1800402110",
        450,
        55,
        Transition.ColorTint,
        "立即刷新",
        118,
        46,
        false
    )
    UILayout.SetSameAnchorAndPivot(btnRefresh, UILayout.BottomLeft)
    GUI.ButtonSetTextFontSize(btnRefresh, UIDefine.FontSizeL)
    GUI.ButtonSetTextColor(btnRefresh, UIDefine.BrownColor)
    GUI.RegisterUIEvent(btnRefresh, UCE.PointerClick, "DiscountMallUI", "UserRefreshItem")
    GUI.SetEventCD(btnRefresh, UCE.PointerClick, 2)

    local pnRefreshMoney = GUI.ImageCreate(ItemScrollBg, "pnRefreshMoney", "1800600500", 565, 50, false, 100, 36)
    UILayout.SetSameAnchorAndPivot(pnRefreshMoney, UILayout.BottomLeft)
    local rftType =
        GUI.ImageCreate(pnRefreshMoney, "type", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 5, 0, false, 32, 32)
    UILayout.SetSameAnchorAndPivot(rftType, UILayout.Left)
    local rfhPrice = GUI.CreateStatic(pnRefreshMoney, "price", " ", 38, -1, 105, 36)
    UILayout.SetSameAnchorAndPivot(rfhPrice, UILayout.Left)
    GUI.StaticSetFontSize(rfhPrice, UIDefine.FontSizeS)
    GUI.SetColor(rfhPrice, UIDefine.BrownColor)
    GUI.StaticSetAlignment(rfhPrice, TextAnchor.MiddleLeft)
    guidt.BindName(rftType, "rfhType")
    guidt.BindName(rfhPrice, "rfhPrice")
end
function DiscountMallUI.OnShow(parameter)
    if UIDefine.FunctionSwitch.DiscountShop ~= "on" then
        DiscountMallUI.OnDestroy()
        CL.SendNotify(NOTIFY.ShowBBMsg,"每日特惠未开启")
        return
    end
    local wnd = GUI.GetWnd("DiscountMallUI")
    if wnd == nil then
        return
    end
    data.index = 1
    DiscountMallUI.GetDate()
    DiscountMallUI.ClientRefresh()
    GUI.SetVisible(wnd, true)
end
function DiscountMallUI.OnDestroy()
    DiscountMallUI.OnClose()
end
function DiscountMallUI.OnClose()
    local wnd = GUI.GetWnd("DiscountMallUI")
    GUI.SetVisible(wnd, false)
    if DiscountMallUI.refreshTimer ~= nil then
        DiscountMallUI.refreshTimer:Stop()
        DiscountMallUI.refreshTimer = nil
    end
end
function DiscountMallUI.GetDate()
    print("DiscountMallUI GetDate")
    CL.SendNotify(NOTIFY.SubmitForm, "FormDiscountShop", "GetMainData")
end
function DiscountMallUI.Refresh()
    data.Currency_Classify_Item = {}
    for i = 1, #DiscountMallUI.item_info do
        local tmp = DiscountClassify_Item2Classify_Item(DiscountMallUI.item_info[i])
        tmp.Id = i
        data.Currency_Classify_Item[i] = tmp
    end
    data.refreshNum = DiscountMallUI.Refresh_Num or 0
	print("=======================tab:"..DiscountMallUI.item_info.UniqueTab)
    DiscountMallUI.ClientRefresh()
end
function DiscountMallUI.ClientRefresh()
    for i = 1, #data.Currency_Classify_Item do
        local itemInfo = data.Currency_Classify_Item[i]
        if itemInfo then
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
    end
    data.refreshTime = 0
    data.refreshIndex = 0
    if DiscountMallUI.Global.RefreshTime then
		--GlobalUtils.Get_DHMS2_BySeconds(CL.GetServerTickCount(), 1)
        local str, day, hour, minute, sec = UIDefine.LeftTimeFormatEx2(CL.GetServerTickCount())
        local cur = {hour, minute, sec}
        local min = {99, 99, 99}
        local minIndex = 0
        for i = 1, #DiscountMallUI.Global.RefreshTime do
            local timestr = string.split(DiscountMallUI.Global.RefreshTime[i], ":")
            local h = tonumber(timestr[1])
            local m = tonumber(timestr[2])
            local s = tonumber(timestr[3])
            if h and m and s then
                local limit = {h, m, s}
                local limitS = h * 3600 + m * 60 + s
                local mins = min[1] * 3600 + min[2] * 60 + min[3]
                if mins > limitS then
                    min = limit
                    minIndex = i
                end
                for j = 1, 3 do
                    if cur[j] > limit[j] then
                        break
                    elseif cur[j] == limit[j] then
                    else
                        local tmp = day * 86400 + limitS
                        if tmp < data.refreshTime or data.refreshTime == 0 then
                            data.refreshTime = tmp
                            data.refreshIndex = i
                        end
                        break
                    end
                end
            else
            end
        end
        --所有时间都不满足条件的话,找最小的那个
        if data.refreshIndex == 0 then
            local tmp = (day + 1) * 86400 + min[1] * 3600 + min[2] * 60 + min[3]
            data.refreshTime = tmp
            data.refreshIndex = minIndex
        end
        data.delaytime = 0
        local str, day, hour, minute, sec = UIDefine.LeftTimeFormatEx(data.refreshTime)
        if hour > 0 then
            data.delaytime = 60
        elseif minute > 0 or sec > 0 then
            data.delaytime = 1
        end
        if data.delaytime > 0 then
            if DiscountMallUI.refreshTimer == nil then
                DiscountMallUI.refreshTimer = Timer.New(DiscountMallUI.RefreshUITime, data.delaytime, -1)
            else
                DiscountMallUI.refreshTimer:Reset(DiscountMallUI.RefreshUITime, data.delaytime, -1)
            end
            DiscountMallUI.refreshTimer:Stop()
            DiscountMallUI.refreshTimer:Start()
        else
            if DiscountMallUI.refreshTimer then
                DiscountMallUI.refreshTimer:Stop()
            end
        end
        test(data.delaytime)
    end
    if data.index < 1 or data.index > #data.Currency_Classify_Item then
        data.index = 1
    end
    data.num = DiscountMallUI.SetItemBuyCnt(1)
    DiscountMallUI.RefreshUI()
end
function DiscountMallUI.RefreshUITime()
    test("DiscountMallUI RefreshUITime")
    if GUI.GetWnd("DiscountMallUI") == nil then
        return
    end
    local str, day, hour, minute, sec = UIDefine.LeftTimeFormatEx(data.refreshTime)

    GUI.StaticSetText(
        guidt.GetUI("txtRefresher"),
        string.format(
            defTxt,
            data.refreshIndex == 0 and "刷新时间异常" or DiscountMallUI.Global.RefreshTime[data.refreshIndex],
            str
        )
    )
    if data.refreshIndex == 0 then
        return
    end
    if hour == 0 and minute == 0 and sec == 0 then
        --服务器重请求
        DiscountMallUI.GetDate()
    else
        --判断是否还有小时
        if data.delaytime == 60 and hour == 0 and DiscountMallUI.refreshTimer then
            data.delaytime = 1
            DiscountMallUI.refreshTimer:Reset(DiscountMallUI.RefreshUITime, data.delaytime, -1)
        end
    end
end
function DiscountMallUI.RefreshUI()
    test("DiscountMallUI RefreshUI")
    if GUI.GetWnd("DiscountMallUI") == nil then
        return
    end
    local itemScroll = guidt.GetUI("itemScroll")
    GUI.LoopScrollRectSetTotalCount(itemScroll, #data.Currency_Classify_Item)
    GUI.LoopScrollRectRefreshCells(itemScroll)

    DiscountMallUI.RefreshInfo()
    DiscountMallUI.RefreshUITime()

    local rfhPrice = guidt.GetUI("rfhPrice")
    local rfhType = guidt.GetUI("rfhType")
    local fun = function()
        GUI.ImageSetImageID(rfhType, UIDefine.AttrIcon[RoleAttr.RoleAttrIngot])
        GUI.StaticSetText(rfhPrice, "max")
    end
    if DiscountMallUI.Global.RefreshMax then
        local max = math.min(data.refreshNum + 1, DiscountMallUI.Global.RefreshMax)
        local tmp = DiscountMallUI.Global["RefreshMoney_" .. max]
        if tmp then
            local type = tmp[2]
            GUI.ImageSetImageID(rfhType, UIDefine.GetMoneyIcon(type))
            GUI.StaticSetText(rfhPrice, tmp[1])
        else
            fun()
        end
    else
        fun()
    end
end
function DiscountMallUI.RefreshItemScroll(parameter)
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
    local itemInfo = DiscountMallUI.GetItemData(index)
    local money_type = itemInfo and itemInfo.money_type or nil
    MallItem.RefreshOff(guid, itemInfo, money_type)
    local itemIcon = GUI.GetChild(GUI.GetByGuid(guid), "icon", false)
    if itemInfo and itemInfo.bind == 1 then
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120)
        GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 44, 45)
    else
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil)
    end
end
function DiscountMallUI.CreatItemPool()
    test("DiscountMallUI.CreatItemPool")
    local scroll = guidt.GetUI("itemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = MallItem.CreateOff(scroll, "item" .. curCount)
	
    GUI.UnRegisterUIEvent(item, UCE.PointerClick, "DiscountMallUI", "OnLeftItemClick")
    GUI.RegisterUIEvent(item, UCE.PointerClick, "DiscountMallUI", "OnLeftItemClick")
    return item
end
function DiscountMallUI.OnLeftItemClick(guid)
	test("DiscountMallUI.OnLeftItemClick()")
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end
    data.num = DiscountMallUI.SetItemBuyCnt(1)
    DiscountMallUI.RefreshInfo()
    if DiscountMallUI.OnClickLeftItemScroll then
        DiscountMallUI.OnClickLeftItemScroll(guid)
    end
end
function DiscountMallUI.RefreshInfo()
    local infoBg = guidt.GetUI("infoBg")
    local spendBg = guidt.GetUI("spendBg")
    local ownBg = guidt.GetUI("ownBg")
    local countEdit = guidt.GetUI("countEdit")
    local info = DiscountMallUI.GetItemData()
    local moneyInt = info and info.money_type or nil
    local num = data.num
    MallItem.RefreshInfo(infoBg, spendBg, ownBg, countEdit, info, moneyInt, num)
    local itemIcon = GUI.GetChild(infoBg, "itemIcon", false)
    if info and info.bind == 1 then
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120)
        GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 44, 45)
    else
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil)
    end
end
---@return DiscountItem
function DiscountMallUI.GetItemData(index)
    if index == nil then
        index = data.index
    end

    local items = data.Currency_Classify_Item
    if items == nil or items[index] == nil then
        print("数据错误")
        return nil
    end
    return items[index]
end
-- 服务器刷新购买数量信息
function DiscountMallUI.RefreshBuyCnt(index, cnt)
    if DiscountMallUI.item_info[index] then
        DiscountMallUI.item_info[index].bought = cnt
    end
    if data.Currency_Classify_Item[index] then
        data.Currency_Classify_Item[index].total = cnt
        DiscountMallUI.ClientRefresh()
    end
end
function DiscountMallUI.OnBuyCountModify(guid)
    local text = GUI.GetByGuid(guid)
    local num = tonumber(GUI.EditGetTextM(text))
    data.num = DiscountMallUI.SetItemBuyCnt(num)
    GUI.EditSetTextM(text, tostring(data.num))
    DiscountMallUI.RefreshInfo()
end

-- 点击加
function DiscountMallUI.OnPlusBtnClick()
    data.num = DiscountMallUI.SetItemBuyCnt(data.num + 1)
    DiscountMallUI.RefreshInfo()
end
-- 点击减
function DiscountMallUI.OnMinusBtnClick()
    data.num = DiscountMallUI.SetItemBuyCnt(data.num - 1)
    DiscountMallUI.RefreshInfo()
end
-- 点击购买
function DiscountMallUI.OnBuyBtnClick()
    DiscountMallUI.SendBuy()
end
function DiscountMallUI.GetItemCanBuyCnt(index)
    local info = DiscountMallUI.GetItemData(index)
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
function DiscountMallUI.SetItemBuyCnt(num)
    if num then
        local max = DiscountMallUI.GetItemCanBuyCnt()
        if max > -1 then
            num = math.min(max, num)
        end
        num = math.max(num, 0)
    else
        num = 0
    end
    return num
end
function DiscountMallUI.SendBuy(itemIndex, num)
    if itemIndex == nil then
        itemIndex = data.index
    end
    if num == nil then
        num = data.num
    end
    test("DiscountMallUI SendBuy ")

    local info = DiscountMallUI.GetItemData(itemIndex)
    if info then
        test(info.Id)
        test(num)
        test(info.total)
        test(info.total_num)
		local now_total = info.total_num - info.total
		if now_total == 0 then
			CL.SendNotify(NOTIFY.ShowBBMsg, "该商品已售罄")
		else
			if num == 0 then
				CL.SendNotify(NOTIFY.ShowBBMsg, "购买数量不能为0")
			end
		end
        CL.SendNotify(NOTIFY.SubmitForm, "FormDiscountShop", "Purchase", info.Id, num)
    else
        print("can not find itemInfo")
    end
end
function DiscountMallUI.UserRefreshItem()
    test("DiscountMallUI UserRefreshItem ")

    CL.SendNotify(NOTIFY.SubmitForm, "FormDiscountShop", "RefreshSubMoney")
end
