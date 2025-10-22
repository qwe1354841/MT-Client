local WelDiscountUI = {}
_G.WelDiscountUI = WelDiscountUI
---@type guidTable
local GuidCacheUtil = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local SurplusTime = {}
local CountDownTxtList = {}
local purchaseIndex = nil

local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
------------------------------------ end缓存一下全局变量end --------------------------------

--无需停止
function WelDiscountUI.OnExitGame()
    if WelDiscountUI['DiscountSurplusTime'] then
        WelDiscountUI['DiscountSurplusTime']:Stop()
        WelDiscountUI['DiscountSurplusTime'] = nil
    end
end

function WelDiscountUI.OnShow(WelfareUIGuidt)
    CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "GetDiscountData")
    local rewardBg = WelfareUIGuidt.GetUI("rewardBg")
    GUI.SetVisible(rewardBg,false)
end

function WelDiscountUI.CreateSubPage(subBg)
    GUI.PostEffect()
    local page = GUI.GroupCreate(subBg, "WelDiscountPage", 100, 65, 820, 550)
    GuidCacheUtil.BindName(page, "WelDiscountPage")
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top)

    local DiscountPoster = GUI.ImageCreate(page, "img_DiscountPoster", "1800608560", 0, 0, false, 830, 126)
    SetAnchorAndPivot(DiscountPoster, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local bgPanel_Discount = GUI.ImageCreate(page, "bgPanel_Discount", "1800400010", -3, 130, false, 838, 415)
    SetAnchorAndPivot(bgPanel_Discount, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local discountScroll = GUI.LoopScrollRectCreate(
            bgPanel_Discount,
            "DiscountScroll",
            7,
            -2,
            818,
            385,
            "WelDiscountUI",
            "CreateDiscountScroll",
            "WelDiscountUI",
            "RefreshDiscountScroll",
            0,
            false,
            Vector2.New(0, 120),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft
    )
    GuidCacheUtil.BindName(discountScroll, "discountScroll")
    SetAnchorAndPivot(discountScroll, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ScrollRectSetChildSpacing(discountScroll, Vector2.New(0, 12))

    local pnSellout = GUI.ImageCreate(page, "pnSellout", "1801100010", 0, 35, false, 300, 100)
    GuidCacheUtil.BindName(pnSellout, "pnSellout")
    SetAnchorAndPivot(pnSellout, UIAnchor.Center, UIAroundPivot.Center)

    local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "物品已售罄", 0, 0, 200, 50, "system", true)
    SetAnchorAndPivot(txtSellout, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtSellout, 28)
    GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
    GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleCenter)
    GUI.SetVisible(pnSellout, false)

    CountDownTxtList = {}
end

function WelDiscountUI.CreateDiscountScroll()

    local discountScroll = GuidCacheUtil.GetUI("discountScroll")
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(discountScroll) + 1
    local shopItem = GUI.GroupCreate(discountScroll, "shopItem"..curIndex, 0, 0, 120, 124,false)
    SetAnchorAndPivot(shopItem, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local pnShoppingListBase = GUI.ImageCreate(shopItem, "pnShoppingListBase" , "1800900010", 3, 0, false, 817, 124)
    SetAnchorAndPivot(pnShoppingListBase, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    for i = 1, 4 do
        local width = 160+(i-1)*95
        local ItemIconBg = GUI.ItemCtrlCreate(pnShoppingListBase,"ItemIconBg"..i,QualityRes[1],width,20,90,90)
        ItemIcon.SetEmpty(ItemIconBg)
        GUI.ItemCtrlSetElementRect(ItemIconBg,eItemIconElement.Icon,0.5,-2,74,74)
        GUI.RegisterUIEvent(ItemIconBg, UCE.PointerClick, "WelDiscountUI", "DiscountIconClick")
    end

    local tlRebate = GUI.ImageCreate(shopItem, "tlRebate", "1800408190", 10, 12, false, 84, 30)
    SetAnchorAndPivot(tlRebate, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --右上角折扣
    local txtRebate = GUI.CreateStatic(tlRebate, "txtRebate",  10 .. "折", 0, 0, 80, 35, "system", true)
    SetAnchorAndPivot(txtRebate, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(txtRebate, TextAnchor.MiddleCenter)
    GUI.SetColor(txtRebate, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtRebate, 22)
    GUI.SetOutLine_Color(txtRebate, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))

    local txtTitle = GUI.CreateStatic(shopItem, "txtTitle", "等级特惠", 45, 0, 150, 50, "system", true)
    SetAnchorAndPivot(txtTitle, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(txtTitle, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtTitle, 24)

    local tlPrice = GUI.ImageCreate(shopItem, "tlPrice", "1800601040", 558, 0, false, 140, 36)
    SetAnchorAndPivot(tlPrice, UIAnchor.Left, UIAroundPivot.Left)

    --银元图片
    local iconPrice = GUI.ImageCreate(tlPrice, "iconPrice", "1900090030", 8, -2, true)
    SetAnchorAndPivot(tlPrice, UIAnchor.Left, UIAroundPivot.Left)

    --原价
    local txtPriceReal = GUI.CreateStatic(iconPrice, "txtPriceReal", "111", 55, 3, 100, 35, "system", true)
    SetAnchorAndPivot(txtPriceReal, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(txtPriceReal, TextAnchor.MiddleCenter)
    GUI.SetColor(txtPriceReal, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtPriceReal, 20)

    --现在价格
    local txtPriceNow = GUI.CreateStatic(iconPrice, "txtPriceNow", "222", 55, -25, 150, 40, "system", true)
    SetAnchorAndPivot(txtPriceNow, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(txtPriceNow, TextAnchor.MiddleCenter)
    GUI.SetColor(txtPriceNow, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtPriceNow, 20)

    local txtTransline = GUI.CreateStatic(txtPriceReal, "txtTransline", "_______", 5, -10, 80, 40, "system", true)
    SetAnchorAndPivot(txtTransline, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txtTransline, 20)
    GUI.SetColor(txtTransline, Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255))

    local btnBuy = GUI.ButtonCreate(shopItem, "btnBuy", "1800402110", 676, 0, Transition.ColorTint, "购买", 124, 48, false)
    SetAnchorAndPivot(btnBuy, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ButtonSetTextColor(btnBuy, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.ButtonSetTextFontSize(btnBuy, 24)
    GUI.RegisterUIEvent(btnBuy, UCE.PointerClick, "WelDiscountUI", "DiscountBuyClick")

    local countDownTxt = GUI.CreateStatic(btnBuy, "txtCountDown", "333", 10, 30,200, 30, "system", true)
    SetAnchorAndPivot(countDownTxt, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.SetColor(countDownTxt, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetAlignment(countDownTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(countDownTxt, 20)

    return shopItem
end

function WelDiscountUI.RefreshDiscountScroll(parameter)

    parameter = string.split(parameter, "#")
    local guid = parameter[1];
    local index = tonumber(parameter[2])+1
    local item = GUI.GetByGuid(guid)
    local config = GlobalProcessing.DISCOUNT_CONFIG[index]
    local tlRebate = GUI.GetChild(item,"tlRebate",false)
    local txtRebate = GUI.GetChild(tlRebate,"txtRebate",false)
    local txtTitle = GUI.GetChild(item,"txtTitle",false)
    local tlPrice = GUI.GetChild(item,"tlPrice",false)
    local iconPrice = GUI.GetChild(tlPrice,"iconPrice",false)
    local txtPriceReal = GUI.GetChild(iconPrice,"txtPriceReal",false)
    local txtPriceNow = GUI.GetChild(iconPrice,"txtPriceNow",false)
    local btnBuy = GUI.GetChild(item,"btnBuy",false)
    local txtCountDown = GUI.GetChild(btnBuy,"txtCountDown",false)

    for i = 1, 4 do
        local items = {}
        local itemsNumbers = {}
        local pets = config.PetList or {}
        for k, v in ipairs(config.ItemList) do
            if type(v) == "string" then
                table.insert(items, v)
                if type(config.ItemList[k + 1]) == "number" then
                    table.insert(itemsNumbers, config.ItemList[k + 1])
                else
                    table.insert(itemsNumbers, 1)
                end
            end
        end
        local role = CL.GetIntAttr(RoleAttr.RoleAttrRole)
        if config["ItemList_" .. role] then
            for k, v in ipairs(config["ItemList_" .. role]) do
                if type(v) == "string" then
                    table.insert(items, v)
                    if type(config["ItemList_" .. role]) == "number" then
                        table.insert(itemsNumbers, config["Items_" .. role][k + 1])
                    else
                        table.insert(itemsNumbers, 1)
                    end
                end
            end
        end
        local pnShoppingListBase = GUI.GetChild(item,"pnShoppingListBase",false)
        local ItemIconBg = GUI.GetChild(pnShoppingListBase,"ItemIconBg"..i,false)
        if i <= #items then
            local itemKeyName = ""
            if string.find(items[i], "#") then
                itemKeyName = string.split(items[i], "#")[1]
            else
                itemKeyName = items[i]
            end
            local ItemDB = DB.GetOnceItemByKey2(itemKeyName)
            GUI.ItemCtrlSetElementValue(ItemIconBg,eItemIconElement.Icon,ItemDB.Icon)
            GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.Border, QualityRes[ItemDB.Grade])
            GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.RightBottomNum, itemsNumbers[i])
            GUI.SetData(ItemIconBg,"type","item")
            GUI.SetData(ItemIconBg,"itemKey",items[i])
        else
            if #pets > 0 then
                local PetDB = DB.GetOncePetByKey2(pets[1])
                GUI.ItemCtrlSetElementValue(ItemIconBg,eItemIconElement.Icon,tostring(PetDB.Head))
                GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.Border, QualityRes[PetDB.Grade])
                GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.RightBottomNum, pets[2])
                GUI.SetData(ItemIconBg,"type","pet")
                GUI.SetData(ItemIconBg,"PetKeyName",pets[1])
            end
        end
    end
    local temp = {
        nowTime = GlobalProcessing.DISCOUNT_DATA[index][2],
        itemGuid = GUI.GetGuid(txtCountDown)
    }
    SurplusTime[tostring(index)] = temp

    local numPriceNow = 0
    local showDiscount = 0

    local StartTime =  GlobalProcessing.DiscountData[GlobalProcessing.DISCOUNT_DATA[index][1]..'_StartTime']
    local serverTime = CL.GetServerTickCount()
    if StartTime + config.DiscountTime_1 > serverTime then
        numPriceNow = math.floor(config.MoneyVal * config["Discounter_1"])
        showDiscount = config["Discounter_1"] * 10
    else
        numPriceNow = math.floor(config.MoneyVal * config["Discounter_2"])
        showDiscount = config["Discounter_2"] * 10
    end

    --local ShowNowTime = temp.nowTime
    --if ShowNowTime <= config.DiscountTime_1 then
    --    numPriceNow = math.floor(config.MoneyVal * config["Discounter_1"])
    --    showDiscount = config["Discounter_1"] * 10
    --else
    --    numPriceNow = math.floor(config.MoneyVal * config["Discounter_2"])
    --    showDiscount = config["Discounter_2"] * 10
    --end

    GUI.StaticSetText(txtTitle,config["Title"])
    GUI.StaticSetText(txtRebate,showDiscount.."折")
    GUI.StaticSetText(txtPriceReal,config["MoneyVal"])
    GUI.StaticSetText(txtPriceNow,numPriceNow)
    GUI.ImageSetImageID(iconPrice,UIDefine.GetMoneyIcon(config.MoneyType))

    GUI.SetData(btnBuy,"index",config.itemIndex)
    GUI.SetData(btnBuy,"price",numPriceNow)
    GUI.SetData(btnBuy,"title",config.Title)
    GUI.SetData(btnBuy,"MoneyType",config.MoneyType)

    CountDownTxtList[GUI.GetGuid(txtCountDown)] = index
    WelDiscountUI.DiscountTimeCallBack()
    if not WelDiscountUI['DiscountSurplusTime'] then
        WelDiscountUI['DiscountSurplusTime'] = Timer.New(WelDiscountUI.DiscountTimeCallBack, 1, -1)
        WelDiscountUI['DiscountSurplusTime']:Start()
    else
        WelDiscountUI['DiscountSurplusTime']:Start()
    end
end

function WelDiscountUI.DescountDataRefresh()
    if not DISCOUNT_CONFIG then
        print('并未获取Discount基础数据1')
        return
    end
    if GlobalProcessing.DISCOUNT_CONFIG == nil then
        print('并未获取Discount玩家数据2')
        return
    end
    if not GlobalProcessing.DISCOUNT_CONFIG then
        print('并未获取Discount玩家数据3')
        return
    end
    if GlobalProcessing.DISCOUNT_CONFIG == {} then
        print('Discount玩家数据为空4')
        return
    end
    SurplusTime = {}
    CountDownTxtList = {}
    local discountScroll =GuidCacheUtil.GetUI("discountScroll")
    local pnSellout = GuidCacheUtil.GetUI("pnSellout")
    if #GlobalProcessing.DISCOUNT_CONFIG > 0 then
        GUI.SetVisible(pnSellout,false)
        GUI.LoopScrollRectSetTotalCount(discountScroll,#GlobalProcessing.DISCOUNT_CONFIG)
        GUI.LoopScrollRectRefreshCells(discountScroll)
    else
        GUI.LoopScrollRectSetTotalCount(discountScroll,0)
        GUI.LoopScrollRectRefreshCells(discountScroll)
        GUI.SetVisible(pnSellout,true)
    end
end

function WelDiscountUI.DiscountTimeCallBack()
    if not DISCOUNT_CONFIG then
        test('并未获取Discount基础数据')
        WelDiscountUI['DiscountSurplusTime']:Stop()
        return
    end
    if GlobalProcessing.DISCOUNT_CONFIG == nil then
        test('并未获取Discount玩家数据')
        WelDiscountUI['DiscountSurplusTime']:Stop()
        return
    end
    if not GlobalProcessing.DISCOUNT_CONFIG then
        test('并未获取Discount玩家数据')
        WelDiscountUI['DiscountSurplusTime']:Stop()
        return
    end
    if #GlobalProcessing.DISCOUNT_CONFIG == 0 then
        test('Discount玩家数据为空')
        WelDiscountUI['DiscountSurplusTime']:Stop()
        return
    end

    for k, v in ipairs(GlobalProcessing.DISCOUNT_DATA) do
        if SurplusTime[tostring(k)] == nil then
            break
        end
        if SurplusTime[tostring(k)].nowTime >= 0 then
            local surp = SurplusTime[tostring(k)].nowTime
            if surp >= 0 then
                if surp == 0 then
                    CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "GetDiscountData")
                end
                local Days = math.floor(surp / (3600 * 24))
                surp = surp - Days * 3600 * 24
                local Hours = math.floor(surp / 3600)
                surp = surp - Hours * 3600
                local Mins = math.floor(surp / 60)
                surp = surp - Mins * 60
                local Secs = surp
                local str = "<color=#00C819>"
                if Days > 0 then
                    str = str .. Days .. "天"
                end
                str = str .. (Hours < 10 and "0" or "") .. Hours .. ":" .. (Mins < 10 and "0" or "") .. Mins .. ":" .. (Secs < 10 and "0" or "") .. Secs .. "</color> 后"
                local str_2 = "消失"
                if v[3] == 1 then
                    str_2 = "恢复" .. (DISCOUNT_CONFIG[v[1]].Discounter_2 * 10) .. "折"
                end
                str = str .. str_2
                if CountDownTxtList[tostring(SurplusTime[tostring(k)].itemGuid)] == k then
                    local countDownTxt = GUI.GetByGuid(tostring(SurplusTime[tostring(k)].itemGuid))
                    if countDownTxt then
                        GUI.SetVisible(countDownTxt, true)
                        GUI.StaticSetText(countDownTxt, str)
                    end
                end
                SurplusTime[tostring(k)].nowTime = SurplusTime[tostring(k)].nowTime - 1
            end
        end
    end
end

function WelDiscountUI.DiscountIconClick(guid)
    local bgPanel = GuidCacheUtil.GetUI("WelDiscountPage")
    local item_bg = GUI.GetByGuid(guid)
    local types = GUI.GetData(item_bg, "type")
    if types == "item" then
        local item = GUI.GetData(item_bg, "itemKey")
        if item then
            local tips = Tips.CreateByItemKeyName(item, bgPanel, "itemTips", 50, 0)
        end
    elseif types == "pet" then
        CL.SendNotify(NOTIFY.SubmitForm,"FormPet","QueryPetByKeyName",tostring(GUI.GetData(item_bg, "PetKeyName")))
    end
end

function WelDiscountUI.DiscountBuyClick(guid)
    purchaseIndex = GUI.GetData(GUI.GetByGuid(guid), "index")
    local price = GUI.GetData(GUI.GetByGuid(guid), "price")
    local title = GUI.GetData(GUI.GetByGuid(guid), "title")
    local MoneyType = GUI.GetData(GUI.GetByGuid(guid), "MoneyType")
    GlobalUtils.ShowBoxMsg2Btn("提示", "确定使用" .. price .. UIDefine.AttrName[UIDefine.GetMoneyEnum(tonumber(MoneyType))] .. "购买" .. title .. "吗？", "WelDiscountUI", "确定", "OnClickSurePurchase", "取消")
end

function WelDiscountUI.OnClickSurePurchase(guid)
    if purchaseIndex then
        CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "DiscountPurchase", purchaseIndex)
        purchaseIndex = nil
    end
end