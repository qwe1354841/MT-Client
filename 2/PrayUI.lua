---@diagnostic disable: undefined-global, undefined-doc-name
local PrayUI = {
    ---@type PrayServerCfg[]
    ServerData = {},
    ---@type PrayShowData
    ShowData = {},
    onLineTimer = nil,
    uinode = {},
    tmptypeTable = {},
	FreeTimeUsed = {}
}
_G.PrayUI = PrayUI
local fontSizeSmall = UIDefine.FontSizeS
local fontSizeDefault = UIDefine.FontSizeM
local fontSizeBigger = UIDefine.FontSizeXL
local fontSizeTitle = UIDefine.FontSizeXXL

local colorWhite = UIDefine.WhiteColor
local colorDark = UIDefine.BrownColor
local iconGradeBg = UIDefine.ItemIconBg2

local colorblack = UIDefine.BlackColor
local QualityRes = UIDefine.ItemIconBg
local TitemBg = {"1800601190", "1800601210", "1800601220"}
local TitemPosX = {-340, 0, 340}
local PrayUI_redpoint = {0, 0, 0}
local uinode = {"pagePray", "panelBg", "PrizeWnd", "prizeScroll", "tipsWnd", "tipsScroll"}
setmetatable(
    PrayUI.uinode,
    {
        __newindex = function(mytable, key, value)
            for i = 1, #uinode do
                if key == uinode[i] then
                    rawset(mytable, "_" .. uinode[i], GUI.GetGuid(value))
                end
            end
        end,
        __index = function(mytable, key)
            for i = 1, #uinode do
                if key == uinode[i] then
                    return GUI.GetByGuid(mytable["_" .. uinode[i]])
                end
            end
            return nil
        end
    }
)

PrayUI.prizeTable = {}
PrayUI.showBtnTimer = nil
function PrayUI.InitData()
    return {
        ---@type PrayClientCfg[]
        cfg = {},
        curClickIndex = 1,
        curShowCnt = 0,
        prizeItemCnt = 0,
        typeTable = {}
    }
end

local data = PrayUI.InitData()
function PrayUI.OnExitGame()
    data = PrayUI.InitData()
end
function PrayUI.Main(parameter)
    --等级不足时禁止打开
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = MainUI.MainUISwitchConfig["祈福"].OpenLevel
	if CurLevel < Level then
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启祈福功能")
		return
	end
    if UIDefine.FunctionSwitch["Pray_Mode"] then
        if UIDefine.FunctionSwitch["Pray_Mode"] == 2  then
            GUI.OpenWnd("Pray_2UI")
            return
        end
    end

	
    GameMain.AddListen("PrayUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("PrayUI", "PrayUI", 0, 0, eCanvasGroup.Normal)
    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)
    GUI.SetIgnoreChild_OnVisible(panel, true)
    PrayUI.uinode.panelBg = UILayout.CreateFrame_WndStyle0(panel, "祈 福", "PrayUI", "OnCloseBtnClick")
    PrayUI.CreatePage()

end

function PrayUI.OnShow(scriptname)
    local wnd = GUI.GetWnd("PrayUI")
    if wnd == nil then
        return
    end
    data = PrayUI.InitData()
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "GetData")
    test("请求数据")
    GUI.SetVisible(wnd, true)
    if PrayUI.onLineTimer == nil then
        PrayUI.onLineTimer = Timer.New(PrayUI.SetOnlineTime, 1, -1, true)
        for i = 1, #PrayUI_redpoint do
            PrayUI_redpoint[i] = 1
        end
        test("新计时")
    else
        PrayUI.onLineTimer:Stop()
        PrayUI.onLineTimer:Reset(PrayUI.SetOnlineTime, 1, -1, true)
    end
    PrayUI.onLineTimer:Start()
    CL.RegisterMessage(GM.CustomDataUpdate, "PrayUI", "OnCustomDataUpdate")
    CL.RegisterMessage(GM.RefreshBag, "PrayUI", "OnRefreshBag")
end
function PrayUI.OnRefreshBag()
    for i = 1, #data.cfg do
        data.cfg[i].ItemNums = LD.GetItemCountById(data.cfg[i].ItemId, item_container_type.item_container_bag)
    end
    PrayUI.RefreshUI()
end
function PrayUI.OnCustomDataUpdate(type, key, val)
    if type == 2 then
        local l, h = int64.longtonum2(val)
        for i = 1, #data.cfg do
            if key == "PrayFreeTimeUsed" .. i then
                data.cfg[i].FreeTimes = data.cfg[i].DayFreeMax - l
            end
            if key == "PrayNextFreeTime" .. i then
                data.cfg[i].NextFreeSecond = l
            end
        end
        PrayUI.RefreshUI()
    end
end
--创建祈福ITEM页面
function PrayUI.CreatePage()
    local pagePray = GUI.GroupCreate(PrayUI.uinode.panelBg, "pagePray", 0, -20, 0, 0)
    PrayUI.uinode.pagePray = pagePray
    GUI.SetIgnoreChild_OnVisible(pagePray, true)
    GUI.SetAnchor(pagePray, UIAnchor.Center)
    GUI.SetPivot(pagePray, UIAroundPivot.Center)
    GUI.SetVisible(pagePray, true)

    for i = 1, #TitemBg do
        PrayUI.CreateOutItem(pagePray, i)
    end
end

--创建单个祈福ITEM
function PrayUI.CreateOutItem(parent, itemIndex)
    --背景
    local itemBg =
        GUI.ImageCreate(parent, "itemBg" .. itemIndex, TitemBg[itemIndex], TitemPosX[itemIndex], -239, false, 330, 530)
    UILayout.SetSameAnchorAndPivot(itemBg, UILayout.Top)

    --图标
    local iconBg = GUI.ImageCreate(itemBg, "iconBg", "1800601180", 0, -118, false)
    UILayout.SetSameAnchorAndPivot(iconBg, UILayout.Center)

    local itemIcon = ItemIcon.Create(iconBg, "itemIcon", 0, 0)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "PrayUI", "OnTipsBtnClick")
    GUI.SetData(itemIcon, "tipIndex", itemIndex)

    --标题
    local titleBg = GUI.ImageCreate(itemBg, "titleBg", "1800601230", -3, -223, false, 277, 54)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Center)
    local itemTitle = GUI.RichEditCreate(titleBg, "itemTitle", "", 0, 0, 270, 54, "system", true)
    UILayout.SetSameAnchorAndPivot(itemTitle, UILayout.Center)
    GUI.StaticSetAlignment(itemTitle, TextAnchor.UpperCenter)
    GUI.SetColor(itemTitle, colorWhite)
    GUI.StaticSetFontSize(itemTitle, fontSizeDefault)

    --提示按钮
    local tipBtn = GUI.ButtonCreate(itemBg, "tipBtn", "1800702030", -11, 204, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(tipBtn, UILayout.TopRight)
    --    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick, "PrayUI", "OnTipsBtnClick")
    --    GUI.SetData(tipBtn,"tipIndex",itemIndex)
    GUI.SetVisible(tipBtn, false)

    --item抽奖描述
    local descBg = GUI.ImageCreate(itemBg, "descBg", "1800601170", 0, 28, false)
    UILayout.SetSameAnchorAndPivot(descBg, UILayout.Center)

    --    local itemSelectDescScroll = GUI.ScrollRectCreate( 100), "itemSelectDescScroll", 0, 0, 233, 68, 0, false, Vector2.New(233, descBg, UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    --    GUI.SetAnchor(itemSelectDescScroll, UIAnchor.Center)
    --    GUI.SetPivot(itemSelectDescScroll, UIAroundPivot.Center)
    --    GUI.ScrollRectSetChildAnchor(itemSelectDescScroll, UIAnchor.Top)
    --    GUI.ScrollRectSetChildPivot(itemSelectDescScroll, UIAroundPivot.Top)
    --    GUI.ScrollRectSetChildSpacing(itemSelectDescScroll, Vector2.New(0, 0))

    local itemDesc = GUI.RichEditCreate(descBg, "itemDesc", "", 0, 0, 233, 68, "system", true)
    UILayout.SetSameAnchorAndPivot(itemDesc, UILayout.Center)
    GUI.StaticSetAlignment(itemDesc, TextAnchor.MiddleCenter)
    GUI.SetColor(itemDesc, colorDark)
    GUI.StaticSetFontSize(itemDesc, fontSizeSmall)

    --抽奖详细信息
    local detailBg = GUI.GroupCreate(itemBg, "detailBg", 1, 0, 0, 0)
    UILayout.SetSameAnchorAndPivot(detailBg, UILayout.BottomLeft)
    GUI.SetVisible(detailBg, true)
    --剩余道具
    local propNum = GUI.CreateStatic(detailBg, "propNum", "", 158, 147, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(propNum, UILayout.Center)
    GUI.StaticSetAlignment(propNum, TextAnchor.MiddleCenter)
    GUI.SetColor(propNum, colorWhite)
    GUI.StaticSetFontSize(propNum, fontSizeSmall)

    --免费次数
    local freeTime = GUI.CreateStatic(detailBg, "freeTime", "", -16, 120, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(freeTime, UILayout.TopLeft)
    GUI.StaticSetAlignment(freeTime, TextAnchor.MiddleCenter)
    GUI.SetColor(freeTime, colorWhite)
    GUI.StaticSetFontSize(freeTime, fontSizeSmall)

    --折扣优惠
    local discount = GUI.CreateStatic(detailBg, "discount", "9折优惠", 343, 120, 200, 27, "system", false, true)
    UILayout.SetSameAnchorAndPivot(discount, UILayout.TopRight)
    GUI.StaticSetAlignment(discount, TextAnchor.MiddleCenter)
    GUI.SetColor(discount, colorWhite)
    GUI.StaticSetFontSize(discount, fontSizeSmall)

    --祈福一次
    local oneTimeBtn = GUI.ButtonCreate(detailBg, "oneTimeBtn", "1800602290", 8, 5, Transition.ColorTint)
    GUI.SetAnchor(oneTimeBtn, UIAnchor.BottomLeft)
    GUI.SetPivot(oneTimeBtn, UIAroundPivot.BottomLeft)
    GUI.RegisterUIEvent(oneTimeBtn, UCE.PointerClick, "PrayUI", "OnOneTimeBtnClick")
    GUI.SetData(oneTimeBtn, "prayItemIndex", itemIndex)

    local oneTime = GUI.CreateStatic(detailBg, "oneTime", "祈福一次", 86, 69, 100, 30, "system", false, true)
    GUI.SetAnchor(oneTime, UIAnchor.Center)
    GUI.SetPivot(oneTime, UIAroundPivot.Center)
    GUI.StaticSetAlignment(oneTime, TextAnchor.MiddleCenter)
    GUI.SetColor(oneTime, colorDark)
    GUI.StaticSetFontSize(oneTime, fontSizeDefault)

    -- 金钱
    local coinBg1, icon, numText = UILayout.CreateAttrBar(detailBg, "coinBg1", 30, 50, 117, UILayout.TopLeft)
	GUI.SetPositionX(icon, -12)
	
    --祈福十次
    local tenTimeBtn =
        GUI.ButtonCreate(detailBg, "tenTimeBtn", "1800402110", 319, 5, Transition.ColorTint, "", 152, 86, false)
    GUI.SetAnchor(tenTimeBtn, UIAnchor.BottomRight)
    GUI.SetPivot(tenTimeBtn, UIAroundPivot.BottomRight)
    GUI.RegisterUIEvent(tenTimeBtn, UCE.PointerClick, "PrayUI", "OnTenTimeBtnClick")
    GUI.SetData(tenTimeBtn, "prayItemIndex", itemIndex)

    local tenTime = GUI.CreateStatic(detailBg, "tenTime", "祈福十次", 240, 069, 100, 30, "system", false, true)
    GUI.SetAnchor(tenTime, UIAnchor.Center)
    GUI.SetPivot(tenTime, UIAroundPivot.Center)
    GUI.StaticSetAlignment(tenTime, TextAnchor.MiddleCenter)
    GUI.SetColor(tenTime, colorDark)
    GUI.StaticSetFontSize(tenTime, fontSizeDefault)

    -- 金钱
    local coinBg2, icon, numText = UILayout.CreateAttrBar(detailBg, "coinBg2", 190, 50, 117, UILayout.TopLeft)
	GUI.SetPositionX(icon, -12)
end

--刷新祈福界面
function PrayUI.Refresh()
    data.cfg = {}
    for i = 1, #PrayUI.ServerData do
        ---@type PrayClientCfg
        local tmp = {}
        tmp.Desc = PrayUI.ServerData[i].Desc
        tmp.OncePrice = PrayUI.ServerData[i].OncePrice
        --tmp.Rewards_Item = LogicDefine.SeverItems2ClientItems(PrayUI.ServerData[i].Rewards_Shows)
        tmp.DayFreeMax = PrayUI.ServerData[i].DayFreeMax
        tmp.Title = PrayUI.ServerData[i].Title
        tmp.MoneyType = PrayUI.ServerData[i].MoneyType
        tmp.ItemKey = PrayUI.ServerData[i].ItemKey
        tmp.TenthPrice = PrayUI.ServerData[i].TenthPrice
        tmp.ShowItem = PrayUI.ServerData[i].ShowItem
        tmp.ItemId = DB.GetOnceItemByKey2(tmp.ItemKey).Id
        data.cfg[i] = tmp
    end
    PrayUI.ClientRefresh()
end
--打开界面太卡了，分开做
function PrayUI.RefreshRewardsItemData(index)
	if data.cfg == nil or data.cfg[index] == nil or PrayUI.ServerData == nil or PrayUI.ServerData[index] == nil or PrayUI.ServerData[index].Rewards_Shows == nil then
		test("PrayUI.RefreshRewardsItemData 错误")
		return false
	end
	data.cfg[index]["Rewards_Item"] = LogicDefine.SeverItems2ClientItems(PrayUI.ServerData[index].Rewards_Shows)
	return true
end

function PrayUI.ClientRefresh()
    for i = 1, #data.cfg do
        data.cfg[i].ItemNums = LD.GetItemCountById(data.cfg[i].ItemId, item_container_type.item_container_bag)
        data.cfg[i].FreeTimes = data.cfg[i].DayFreeMax - (PrayUI.FreeTimeUsed[i] or 0)
        data.cfg[i].NextFreeSecond = CL.GetIntCustomData("PrayNextFreeTime" .. i)
    end
    PrayUI.RefreshUI()
end
function PrayUI.RefreshUI()
    test("刷新祈福")
    if PrayUI.uinode.pagePray == nil then
        return
    end

    if data.cfg == nil then
        test("祈福数据为空")
        return
    end
    for i = 1, #data.cfg do
        local itemParet = GUI.GetChild(PrayUI.uinode.pagePray, "itemBg" .. i)
        local coinBg1 = GUI.GetChild(itemParet, "coinBg1")
        local coinBg2 = GUI.GetChild(itemParet, "coinBg2")
        local itemTitle = GUI.GetChild(itemParet, "itemTitle")
        local itemIcon = GUI.GetChild(itemParet, "itemIcon")
        local itemDesc = GUI.GetChild(itemParet, "itemDesc")
        local propNum = GUI.GetChild(itemParet, "propNum")
        local freeTime = GUI.GetChild(itemParet, "freeTime")
        local discount = GUI.GetChild(itemParet, "discount")
        local price1 = GUI.GetChild(coinBg1, "numText")
        local price2 = GUI.GetChild(coinBg2, "numText")
        local oneTimeBtn = GUI.GetChild(itemParet, "oneTimeBtn")

        local data = data.cfg[i]
        if data == nil then
            return
        end

        local keyInfo = DB.GetOnceItemByKey2(data.ItemKey)
        GUI.StaticSetText(itemTitle, "" .. data.Title)
        local itemID = data.ShowItem
        test(data.ShowItem)
        if itemID ~= nil then
            ItemIcon.BindItemKeyName(itemIcon, itemID)
            GUI.SetData(itemIcon, "itemId", itemID)
        end
        GUI.StaticSetText(itemDesc, data.Desc)
        GUI.StaticSetText(propNum, "剩余抽奖道具: " .. data.ItemNums)

        --设置祈福一次按钮显示
        if data.NextFreeSecond ~= nil then
            if data.FreeTimes > 0 and data.NextFreeSecond == 0 then
                UILayout.RefreshAttrBar(coinBg1, nil, "本次免费")
                GUI.SetColor(price1, colorWhite)
            elseif UIDefine.MoneyTypes[data.MoneyType] == nil or data.ItemNums > 0 then
                if data.ItemNums < 1 then
                    GUI.SetColor(price1, UIDefine.RedColor)
                else
                    GUI.SetColor(price1, colorWhite)
                end
                UILayout.RefreshAttrBar2(coinBg1, keyInfo.Icon, "×1")
            else
                UILayout.RefreshAttrBar(coinBg1, UIDefine.GetMoneyEnum(data.MoneyType), data.OncePrice)
                GUI.SetColor(price1, colorWhite)
            end
        end

        --设置祈福十次按钮显示
        if UIDefine.MoneyTypes[data.MoneyType] == nil or data.ItemNums >= 10 then
            UILayout.RefreshAttrBar2(coinBg2, keyInfo.Icon, "×10")
            if data.ItemNums < 10 then
                GUI.SetColor(price2, UIDefine.RedColor)
            else
                GUI.SetColor(price2, colorWhite)
            end
        else
            UILayout.RefreshAttrBar(coinBg2, UIDefine.GetMoneyEnum(data.MoneyType), data.TenthPrice)
            GUI.SetColor(price2, colorWhite)
        end
        if UIDefine.MoneyTypes[data.MoneyType] ~= nil then
            GUI.SetVisible(discount, true)
            local per = string.format("%.1f", data.TenthPrice / (data.OncePrice * 10))
            per = per * 10
            GUI.StaticSetText(discount, per .. "折优惠")
        else
            GUI.SetVisible(discount, false)
        end
    end

    PrayUI.SetOnlineTime()
end

--刷新祈福ITEM上的免费时间
function PrayUI.SetOnlineTime()
    if not data.cfg then
        return
    end
    for i = 1, 3 do
        local itemParet = GUI.GetChild(PrayUI.uinode.pagePray, "itemBg" .. i)
        local freeTime = GUI.GetChild(itemParet, "freeTime")
        local oneTimeBtn = GUI.GetChild(itemParet, "oneTimeBtn")

        local coinBg1 = GUI.GetChild(itemParet, "coinBg1")
        local price1 = GUI.GetChild(coinBg1, "numText")
        local str, day, hours, minutes, sec = UIDefine.LeftTimeFormatEx(data.cfg[i].NextFreeSecond)
        local freefun = function()
            return day == 0 and hours == 0 and minutes == 0 and sec == 0
        end
        if data.cfg[i].DayFreeMax > 0 then
            if freefun() then
                GUI.StaticSetText(freeTime, "免费次数: " .. data.cfg[i].FreeTimes)
                -- test("redpoint =====================按钮"..i.."状态"..PrayUI_redpoint[i])
                if data.cfg[i].FreeTimes > 0 and PrayUI_redpoint[i] == 0 then
                    PrayUI_redpoint[i] = 1
                end
            else
                PrayUI_redpoint[i] = 0
                if data.cfg[i].NextFreeSecond ~= nil then
                    GUI.StaticSetText(freeTime, str .. "后免费")
                else
                    test("获取剩余免费时间失败")
                    GUI.StaticSetText(freeTime, "")
                end
            end
        end

        if data.cfg[i].FreeTimes > 0 and freefun() then
            UILayout.RefreshAttrBar(coinBg1, nil, "本次免费")
            GUI.SetColor(price1, colorWhite)
        end
    end
end

--点击TIPS按钮
function PrayUI.OnTipsBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    test("PrayUI.OnTipsBtnClick")
    local index = tonumber(GUI.GetData(element, "tipIndex"))
    if data.cfg == nil then
        test("祈福数据为空")
        return
    end

    if index == nil then
        return
    end
	
	if not data.cfg[index]["Rewards_Item"] then
		if not PrayUI.RefreshRewardsItemData(index) then
			return
		end
	end
	
    GUI.OpenWnd("ItemListUI", "可获得列表")
    local tmp = {}
    for i = 1, #data.cfg[index].Rewards_Item do
        tmp[i] = {id = data.cfg[index].Rewards_Item[i].id}
    end
    ItemListUI.ShowTipsPage(tmp)
end

--祈福一次按钮点击
function PrayUI.OnOneTimeBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    local index = tonumber(GUI.GetData(element, "prayItemIndex"))
    data.curClickIndex = index
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", index, 1)
    test("点击抽一次: " .. index)
end

--祈福十次按钮点击
function PrayUI.OnTenTimeBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    local index = tonumber(GUI.GetData(element, "prayItemIndex"))
    data.curClickIndex = index
    test("点击十连抽: " .. index)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", index, 2)
end

--关闭祈福页面按钮点击
function PrayUI.OnCloseBtnClick()
    GUI.DestroyWnd("PrayUI")
end

function PrayUI.OnDestroy()
    PrayUI.OnClose()
end

-------------------------------------------------------以下是抽奖二级界面------------------------------------------------------

--获取祈福奖励数据
function PrayUI.SummonLotteryReward()
    PrayUI.prizeTable = {}
    local table_now = {}
    PrayUI.tmptypeTable = {}
    test("抽奖数据: " .. #table_now)
    table_now = PrayUI.ShowData
    if table_now then
        PrayUI.tmptypeTable = table_now.Orders
        local itemTable = {}
        local petTable = {}
        local guardTable = {}
        if table_now.ItemList then
            --itemTable = LogicDefine.SeverItems2ClientItems(table_now.ItemList, itemTable)
			for k,v in ipairs(table_now.ItemList) do
                if type(v) == "string" then
                    local table_splited = {}
                    local num = 1
                    local bind = true
                    local soundType = 0
                    if type(table_now.ItemList[k+1]) == "number" then
                        num = table_now.ItemList[k+1]
                        if type(table_now.ItemList[k+2]) == "number" then
                            bind = (table_now.ItemList[k+2] == 0 and false or true)
                            if type(table_now.ItemList[k+3]) == "number" then
                                soundType = table_now.ItemList[k+3]
                            end
                        end
                    end
                    if num > 0 then
                        table_splited[1] = v
                        table_splited[2] = num
                        table_splited[3] = bind
                        table_splited[4] = soundType
                        table.insert(itemTable,table_splited)
                    end
                end
            end
        end
        --keyname,bind,soundType
        if table_now.PetList then
            for i, v in ipairs(table_now.PetList) do
                if type(v) == "string" then
                    local table_splited = {}
                    local bind = false
                    local soundType = 0
                    if type(table_now.PetList[i + 1]) == "number" then
                        bind = (table_now.PetList[i + 1] == 0 and false or true)
                        if type(table_now.PetList[i + 2]) == "number" then
                            soundType = table_now.PetList[i + 2]
                        end
                    end
					table_splited[1] = v
					table_splited[2] = 1
					table_splited[3] = bind
					table_splited[4] = soundType
					table.insert(petTable, table_splited)
				
                end
            end
        end
		if table_now.GuardList then
			for i, v in ipairs(table_now.GuardList) do
				if type(v) == "string" then
					local table_splited = {}
					local bind = false
                    if type(table_now.GuardList[i + 1]) == "number" then
                        bind = (table_now.GuardList[i + 1] == 0 and false or true)
						if type(table_now.GuardList[i + 2]) == "number" then
                            soundType = table_now.GuardList[i + 2]
                        end
                    end
					table_splited[1] = v
					table_splited[2] = 1
					table_splited[3] = bind
                    table_splited[4] = soundType
					table.insert(guardTable, table_splited)
				end
			end
		end

        local tableName = {itemTable, petTable, guardTable}
        local itemCnt = 1
        local petCnt = 1
        local guardCnt = 1
        if PrayUI.tmptypeTable then
            for a = 1, #PrayUI.tmptypeTable do
                local itemType = PrayUI.tmptypeTable[a]
                local tempTable = tableName[itemType]
                local tempData = nil
                --test("table type : ",itemType)
                if itemType == 1 then
                    if itemCnt <= #tempTable then
                        tempData = tempTable[itemCnt]
                        itemCnt = itemCnt + 1
                    end
                elseif itemType == 2 then
                    if petCnt <= #tempTable then
                        tempData = tempTable[petCnt]
                        petCnt = petCnt + 1
                    end
                else
                    if guardCnt <= #tempTable then
                        tempData = tempTable[guardCnt]
                        guardCnt = guardCnt + 1
                    end
                end
                if tempData then
                    table.insert(PrayUI.prizeTable, tempData)
                end
            end
        end
    end
    test(("item 数量: ") .. #PrayUI.prizeTable)
    PrayUI.ShowPrizePage()
end

--创建奖励页面
function PrayUI.CreatePrizeWnd()
    local panelCover = GUI.Get("PrayUI/panelCover")

    PrayUI.uinode.PrizeWnd = GUI.GroupCreate(PrayUI.uinode.panelBg, "pirzePage", 0, 0, 0, 0)
    GUI.SetIgnoreChild_OnVisible(PrayUI.uinode.PrizeWnd, true)
    GUI.SetAnchor(PrayUI.uinode.PrizeWnd, UIAnchor.Center)
    GUI.SetPivot(PrayUI.uinode.PrizeWnd, UIAroundPivot.Center)
    GUI.SetVisible(PrayUI.uinode.PrizeWnd, true)

    local prizeCover =
        GUI.ImageCreate(
        PrayUI.uinode.PrizeWnd,
        "prizeCover",
        "1800400220",
        0,
        -40,
        false,
        GUI.GetWidth(panelCover),
        GUI.GetHeight(panelCover) + 100
    )
    GUI.SetAnchor(prizeCover, UIAnchor.Center)
    GUI.SetPivot(prizeCover, UIAroundPivot.Center)
    prizeCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(prizeCover, true)

    local prizeBg = GUI.ImageCreate(PrayUI.uinode.PrizeWnd, "prizeBg", "1800601240", 0, -7, false, 1280, 343)
    GUI.SetAnchor(prizeBg, UIAnchor.Center)
    GUI.SetPivot(prizeBg, UIAroundPivot.Center)

    local titleBg = GUI.ImageCreate(PrayUI.uinode.PrizeWnd, "titleBg", "1800608750", 0, -188, false)
    GUI.SetAnchor(titleBg, UIAnchor.Center)
    GUI.SetPivot(titleBg, UIAroundPivot.Center)

    PrayUI.uinode.prizeScroll =
        GUI.ScrollRectCreate(
        PrayUI.uinode.PrizeWnd,
        "ScrollWnd",
        0,
        -30,
        699,
        300,
        0,
        false,
        Vector2.New(76, 76),
        UIAroundPivot.Top,
        UIAnchor.Top,
        5
    )
    GUI.SetAnchor(PrayUI.uinode.prizeScroll, UIAnchor.Center)
    GUI.SetPivot(PrayUI.uinode.prizeScroll, UIAroundPivot.Center)
    GUI.ScrollRectSetChildAnchor(PrayUI.uinode.prizeScroll, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(PrayUI.uinode.prizeScroll, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(PrayUI.uinode.prizeScroll, Vector2.New(14, 14))
    GUI.SetPaddingHorizontal(PrayUI.uinode.prizeScroll, Vector2.New(50, 50))
    GUI.SetPaddingVertical(PrayUI.uinode.prizeScroll, Vector2.New(64, 50))
    GUI.ScrollRectSetVertical(PrayUI.uinode.prizeScroll, false)
    GUI.ScrollRectSetHorizontal(PrayUI.uinode.prizeScroll, false)

    local againBtn =
        GUI.ButtonCreate(
        PrayUI.uinode.PrizeWnd,
        "againBtn",
        "1800402110",
        -90,
        103,
        Transition.ColorTint,
        "",
        120,
        46,
        false
    )
    GUI.SetAnchor(againBtn, UIAnchor.Center)
    GUI.SetPivot(againBtn, UIAroundPivot.Center)
    GUI.RegisterUIEvent(againBtn, UCE.PointerClick, "PrayUI", "OnAgainBtnClick")

    local againText = GUI.CreateStatic(againBtn, "againText", "再来一次", 0, 0, 120, 46, "system", false, true)
    GUI.SetAnchor(againText, UIAnchor.Center)
    GUI.SetPivot(againText, UIAroundPivot.Center)
    GUI.StaticSetAlignment(againText, TextAnchor.MiddleCenter)
    GUI.SetColor(againText, colorDark)
    GUI.StaticSetFontSize(againText, fontSizeDefault)

    local knowBtn =
        GUI.ButtonCreate(
        PrayUI.uinode.PrizeWnd,
        "knowBtn",
        "1800402110",
        90,
        103,
        Transition.ColorTint,
        "",
        120,
        46,
        false
    )
    GUI.SetAnchor(knowBtn, UIAnchor.Center)
    GUI.SetPivot(knowBtn, UIAroundPivot.Center)
    GUI.RegisterUIEvent(knowBtn, UCE.PointerClick, "PrayUI", "OnKnowBtnClick")

    local knowText = GUI.CreateStatic(knowBtn, "knowText", "知道了", 0, 0, 120, 46, "system", false, true)
    GUI.SetAnchor(knowText, UIAnchor.Center)
    GUI.SetPivot(knowText, UIAroundPivot.Center)
    GUI.StaticSetAlignment(knowText, TextAnchor.MiddleCenter)
    GUI.SetColor(knowText, colorDark)
    GUI.StaticSetFontSize(knowText, fontSizeDefault)
    GUI.SetVisible(knowBtn, false)
    GUI.SetVisible(againBtn, false)
end

--创建获得奖品页面
function PrayUI.ShowPrizePage()
    test("显示抽奖界面")

    data.curShowCnt = #PrayUI.prizeTable

    local knowBtn = GUI.GetChild(PrayUI.uinode.PrizeWnd, "knowBtn")
    if knowBtn ~= nil then
        GUI.SetVisible(knowBtn, false)
    end
    local againBtn = GUI.GetChild(PrayUI.uinode.PrizeWnd, "againBtn")
    if againBtn ~= nil then
        local againText = GUI.GetChild(againBtn, "againText")
        if data.curShowCnt == 1 then
            GUI.StaticSetText(againText, "再来一次")
        else
            GUI.StaticSetText(againText, "再来十次")
        end
        GUI.SetVisible(againBtn, false)
    end
    PrayUI.OpenGetRewardUI()
    PrayUI.ShowBtnTimerFunc()
end

function PrayUI.OpenGetRewardUI()
    GUI.OpenWnd("GetRewardUI")
    local itemDataList = {}
	local intervalTime = (PrayUI.ServerData["ShowTime"] or 380)/1000
    for i = 1, #PrayUI.prizeTable do
        itemDataList[i] = {}
		local tmp = PrayUI.prizeTable[i]
		itemDataList[i].KeyName = tmp[1]
		itemDataList[i].Num = tmp[2]
		itemDataList[i].Bind = tmp[3]
		itemDataList[i].Sound = tmp[4]
        if PrayUI.tmptypeTable[i] == 1 then
            ---@type eqiupItem
            -- local tmp = PrayUI.prizeTable[i]
            -- itemDataList[i].KeyName = tmp.keyname
            -- itemDataList[i].Num = tmp.count
            itemDataList[i].IsItem = true
        elseif PrayUI.tmptypeTable[i] == 2 then
            -- local tmp = PrayUI.prizeTable[i]
            -- itemDataList[i].KeyName = tmp[1]
            -- itemDataList[i].Num = tmp[2]
            itemDataList[i].IsPet = true
		elseif PrayUI.tmptypeTable[i] == 3 then
			-- local tmp = PrayUI.prizeTable[i]
            -- itemDataList[i].KeyName = tmp[1]
            -- itemDataList[i].Num = tmp[2]
			itemDataList[i].IsGuard = true
        end
        test(itemDataList[i].KeyName)
    end
    GetRewardUI.ShowItem(
        itemDataList,
        function()
            -- CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "LuckyWheel_Receive_Tenth")
        end,
		intervalTime
    )
    GetRewardUI.SetLeftBtn(data.curShowCnt == 1 and "再来一次" or "再来十次", PrayUI.OnAgainBtnClick)
    GetRewardUI.SetRightBtn("知道了", PrayUI.OnKnowBtnClick)
end

function PrayUI.ShowBtnTimerFunc()
    if not PrayUI.showBtnTimer then
    --//TODO  关闭自动关闭
    -- PrayUI.showBtnTimer = Timer.New(PrayUI.ShowPrizeBtns, 10, 1)
    -- PrayUI.showBtnTimer:Start()
    end
end

function PrayUI.ShowPrizeBtns()
    PrayUI.OnKnowBtnClick()
end

function PrayUI.BindItemId(itemIconBtn, itemId, amount)
    if itemIconBtn == nil then
        return
    else
        ItemIcon.BindItemId(itemIconBtn, itemId, amount)
        GUI.ItemCtrlSetElementValue(itemIconBtn, eItemIconElement.RightBottomNum, amount)
        return
    end

    local itemData = DB.GetOnceItemByKey2(itemId)
    if itemData ~= nil then
        GUI.ItemCtrlSetElementValue(itemIconBtn, eItemIconElement.Border, QualityRes[itemData.Grade])
        GUI.ItemCtrlSetElementValue(itemIconBtn, eItemIconElement.Icon, itemData.Icon)
        local icon = GUI.ItemCtrlGetSprite_Icon(itemIconBtn)
        GUI.SetPositionY(icon, -1)

        local itemConsumable = DB.Get_item_consumable(itemId)
        GUI.SetItemIconBtnIconScale(itemIconBtn, 0.8)
        if
            itemConsumable ~= nil and
                (itemConsumable.Type == 32 or itemConsumable.Type == 8 or itemConsumable.Type == 41)
         then
            GUI.SetItemIconBtnIconScale(itemIconBtn, 0.9)
        end

        local equip = DB.Get_item_equip(itemId)
        if equip ~= nil and equip.Type == 7 then
            GUI.SetItemIconBtnLeftBottomName(itemIconBtn, "1801208350")
            local lbSprite = GUI.GetItemIconBtnSprite_LeftBottom(itemIconBtn)
            GUI.SetPositionX(lbSprite, 4)
            GUI.SetPositionY(lbSprite, 6)
        else
            GUI.SetItemIconBtnLeftBottomName(itemIconBtn, nil)
        end

        GUI.SetItemIconBtnRightTopName(itemIconBtn, nil)
        if itemConsumable ~= nil and (itemConsumable.Type == 32) then
            GUI.SetItemIconBtnRightTopName(itemIconBtn, "1801208250")
        end

        GUI.ItemCtrlSetCount(itemIconBtn, amount)
        local count = GUI.ItemCtrlGetLabel_Num(itemIconBtn)
        if count ~= nil then
            GUI.SetPositionX(count, 8)
            GUI.SetPositionY(count, 5)
            GUI.StaticSetFontSize(count, 20)
            GUI.SetIsOutLine(count, true)
            GUI.SetOutLine_Color(count, colorblack)
            GUI.SetOutLine_Distance(count, 1)
            GUI.SetColor(count, colorWhite)
        end
    else
        ItemIconBtn.SetEmpty(itemIconBtn)
    end
end

--关闭奖品页面按钮点击
function PrayUI.OnKnowBtnClick()
    if PrayUI.showBtnTimer ~= nil then
        PrayUI.showBtnTimer:Stop()
        PrayUI.showBtnTimer = nil
    end
    GUI.CloseWnd("GetRewardUI")
end

--再来一次按钮点击
function PrayUI.OnAgainBtnClick()
    PrayUI.OnKnowBtnClick()
    test(data.curClickIndex)
    test(data.curShowCnt)
    if data.curShowCnt == nil or data.curClickIndex == nil then
        return
    end
    test("再抽一次index: " .. data.curClickIndex)
    if data.curShowCnt == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", data.curClickIndex, 1)
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormPray", "StartDraw", data.curClickIndex, 2)
    end
end
function PrayUI.OnClose()
    if PrayUI.onLineTimer then
        PrayUI.onLineTimer:Stop()
        PrayUI.onLineTimer = nil
    end
    CL.UnRegisterMessage(GM.CustomDataUpdate, "PrayUI", "OnCustomDataUpdate")
    CL.UnRegisterMessage(GM.RefreshBag, "PrayUI", "OnRefreshBag")
    PrayUI.OnKnowBtnClick()
end
