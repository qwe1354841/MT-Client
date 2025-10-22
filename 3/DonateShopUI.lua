DonateShopUI = {}
local _gt = UILayout.NewGUIDUtilTable()
-- 获取数据
DonateShopUI.version = "0"

-- local wnd = GUI.GetWnd("ShopStoreUI")
-- 一级菜单列表
local GoodsType = {}
-- 二级菜单列表
local GoodsSubType = {}
-- 所有菜单的信息
local AllGoodsType = {}
-- 所有商品的信息
local DonateShopList = {}
-- 当前选项的商品列表
local itemList = {}
local coinList = {"装备功勋","宠物功勋"}
local coinImgList = {["装备功勋"] = "1801208050",["宠物功勋"] = "1801208060"}
-- 等级限制
local LevelRestrictions = 55
local isVisible = false
DonateShopUI.isNPC = false
local dataIdx = 1
function DonateShopUI.SetDataIdx (idx)
    dataIdx = idx
end
function DonateShopUI.InitData()
    if dataIdx and dataIdx == 2 then
        return {
            --类型
            typeIndex = 2,
            --记录选中类型
            typeFlagIndex = 2,
            --子类型
            subTypeIndex = 6,
            --是否折叠
            isfold = false,
            --首次进入
            isFistOpen = true,
            --是否被选中
            isFistSelected = true,
            --是否是传入ID
            isPassedIntoID = false,
            --对应类型的物品
            typeItem = DonateShopList[GoodsSubType[6]],
            --选中的对应物品
            selectItemIndex = 1,
            --选中的对应ID
            selectItemId = -1,
            --选中的对应物品按钮的guid
            selectItemGuid = "0",
        }
    else
        return {
            --类型
            typeIndex = 1,
            --记录选中类型
            typeFlagIndex = 1,
            --子类型
            subTypeIndex = 1,
            --是否折叠
            isfold = false,
            --首次进入
            isFistOpen = true,
            --是否被选中
            isFistSelected = true,
            --是否是传入ID
            isPassedIntoID = false,
            --对应类型的物品
            typeItem = DonateShopList[GoodsSubType[1]],
            --选中的对应物品
            selectItemIndex = 1,
            --选中的对应ID
            selectItemId = -1,
            --选中的对应物品按钮的guid
            selectItemGuid = "0",
        }
    end
end
local data = DonateShopUI.InitData()

-- 获取功勋
function DonateShopUI.GetExploitData()
    --FormDonateEquipAndPet.GetExploitShopData(player, version)  --获取捐献商店配置
    --FormDonateEquipAndPet.DonateShopPurchase(player, item_id, item_num, item_price, buy_name)  --捐献商店购买
    --FormDonateEquipAndPet.GetEquipExploit(player)  --获取装备功勋
    --FormDonateEquipAndPet.GetPetExploit(player)    --获取宠物功勋
    CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "GetEquipExploit")
    CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "GetPetExploit")
end

-- 根据价钱排序
local sortList = function(a,b)
    local coinNum1 = data.typeItem[a]["Buy"]
    local coinNum2 = data.typeItem[b]["Buy"]
    return coinNum1 < coinNum2
end

-- 获取所有的商品类型
function DonateShopUI.GetAllGoodsType()
    AllGoodsType = DonateShopUI.Donate_Structure
    DonateShopList = DonateShopUI.Donate_ShopList
    GoodsSubType = {}
    GoodsType = {}
    for path , typeName in pairs(AllGoodsType) do
        local typePath = string.split(path,"_")
        -- 第三位点不为空则为二级菜单
        if typePath[3] then
            table.insert(GoodsSubType,path)
        else
            table.insert(GoodsType,path)
        end
    end
    table.sort(GoodsSubType)
    table.sort(GoodsType)
end

-- 创建类型列表
function DonateShopUI.GetGoodsType()
    DonateShopUI.GetAllGoodsType()
    local goodsTypeListScroll = _gt.GetUI("goodsTypeListScroll")
    if goodsTypeListScroll == nil then
        local GoodsTypeBg = _gt.GetUI("GoodsTypeBg")
        DonateShopUI.CreateGoodsTypeList(GoodsTypeBg)
    end
end
-- 创建类型列表
function DonateShopUI.CreateGoodsTypeList(parent)
    local goodsTypeListScroll = GUI.ScrollListCreate(parent,"goodsTypeListScroll",10, 10, 250, 480, false, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(goodsTypeListScroll, "goodsTypeListScroll")
    UILayout.SetSameAnchorAndPivot(goodsTypeListScroll, UILayout.TopLeft)
    for i = 1 , #GoodsType do
        local path = GoodsType[i]
        local main_i = string.split(path,"_")[2]
        -- 父节点按钮
        local listTypeBtn = GUI.ButtonCreate(goodsTypeListScroll, path, "1800400410", 0, 0, Transition.ColorTint, AllGoodsType[path], 250, 62, false)
        _gt.BindName(listTypeBtn, path)
        GUI.RegisterUIEvent(listTypeBtn, UCE.PointerClick, "DonateShopUI", "OnListTypeBtnClick")
        UILayout.SetSameAnchorAndPivot(listTypeBtn, UILayout.Top)
        GUI.ButtonSetTextFontSize(listTypeBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(listTypeBtn, UIDefine.BrownColor)
        GUI.SetPreferredHeight(listTypeBtn, 62)

        local listType = GUI.ListCreate(goodsTypeListScroll, "listType" .. i, 0, 0, 244, 320, false)
        UILayout.SetSameAnchorAndPivot(listType, UILayout.Top)
        GUI.SetPaddingHorizontal(listType, Vector2.New(10, 0))
        _gt.BindName(listType, "listType" .. i)

        for m = 1 , #GoodsSubType do
            local subPath = GoodsSubType[m]
            if main_i == string.split(subPath,"_")[2] then
                -- 子节点
                local listTypeSubBtn =
                GUI.ButtonCreate(listType, subPath, "1801302060", 0, 0, Transition.ColorTint, AllGoodsType[subPath], 228, 71, false)
                UILayout.SetSameAnchorAndPivot(listTypeSubBtn, UILayout.Top)
                GUI.ButtonSetTextFontSize(listTypeSubBtn, UIDefine.FontSizeXL)
                GUI.ButtonSetTextColor(listTypeSubBtn, UIDefine.BrownColor)
                GUI.RegisterUIEvent(listTypeSubBtn, UCE.PointerClick, "DonateShopUI", "OnListTypeSubBtnClick")
                _gt.BindName(listTypeSubBtn, subPath)
            end
        end
    end
end
--主类型点击
function DonateShopUI.OnListTypeBtnClick(guid)
    for i = 1 , #GoodsType do
        local path = GoodsType[i]
        if _gt.GetGuid(path) == guid then
            if data.typeIndex == i then
                data.isfold = not data.isfold
            else
                data.typeIndex = i
                data.isfold = false
            end
            break
        end
    end
    for i = 1 , #GoodsType do
        local listType = _gt.GetUI("listType" .. i)
        GUI.SetVisible(listType, i == data.typeIndex and not data.isfold)
        if i == data.typeIndex then
            local btn = GUI.GetChildByIndex(listType,0)
            DonateShopUI.OnListTypeSubBtnClick(GUI.GetGuid(btn))
        end
    end
end
-- 子类型被点击
function DonateShopUI.OnListTypeSubBtnClick(guid)
    for i = 1, #GoodsSubType do
        local subPath = GoodsSubType[i]
        if _gt.GetGuid(subPath) == guid then
            data.typeFlagIndex = data.typeIndex
            data.subTypeIndex = i
            data.selectItemIndex = 1
            data.isFistSelected = true
            data.typeItem = DonateShopList[GoodsSubType[data.subTypeIndex]]
            break
        end
    end
    itemList = {}
    for i , v in pairs(data.typeItem) do
        table.insert(itemList,i)
    end
    table.sort(itemList,sortList)
    --DonateShopUI.RefreshItemScroll()
    local count = #itemList
    local ItemScroll = _gt.GetUI("ItemScroll")
    GUI.LoopScrollRectSetTotalCount(ItemScroll, 0)
    GUI.LoopScrollRectSetTotalCount(ItemScroll, count)
    GUI.LoopScrollRectRefreshCells(ItemScroll)
    DonateShopUI.RefreshUI()
end
-- 刷新UI
function DonateShopUI.RefreshUI()
    if data.isFistOpen then
        data.isFistOpen = false
        for i = 1 , #GoodsType do
            local listType = _gt.GetUI("listType" .. i)
            GUI.SetVisible(listType, i == data.typeIndex and not data.isfold)
        end
    end
    
    for i , path in pairs(GoodsSubType) do
        local sub = _gt.GetUI(path)
        if sub then
            if data.typeIndex == data.typeFlagIndex and i == data.subTypeIndex then
                GUI.ButtonSetImageID(sub, "1801302061")
            else
                GUI.ButtonSetImageID(sub, "1801302060")
            end
        end
    end
    if isVisible then
        --设置身上的钱
        DonateShopUI.UpdateOwnMoneyCount()
    end
    DonateShopUI.UpdateCountEdit(1)
end

--设置身上的钱
function DonateShopUI.UpdateOwnMoneyCount()
    --获取当前点击的商品
    local item = GUI.GetByGuid(data.selectItemGuid)
    --根据货币类型设置钱
    for i , coinType in pairs(coinList) do
        if coinType == GUI.GetData(item, "coinType") then
            if i == 1 then
                ShopStoreUI.UpdateOwnMoneyCount(DonateShopUI.EquipExploit)
            elseif i == 2 then
                ShopStoreUI.UpdateOwnMoneyCount(DonateShopUI.PetExploit)
            end
        end
    end
end

--取消点击
function DonateShopUI.UnCheckPreItem()
    if data.selectItemGuid ~= "0" then
        local item = GUI.GetByGuid(data.selectItemGuid)
        if item ~= nil then
            GUI.CheckBoxExSetCheck(item, false)
        end
    end
end

--设置点击
function DonateShopUI.CheckItem()
    local item = GUI.GetByGuid(data.selectItemGuid)
    if item ~= nil then
        GUI.CheckBoxExSetCheck(item, true)
    end
end

--设置购买商品个数
function DonateShopUI.UpdateCountEdit(count)
    local shopBuyPage = DonateShopUI.GetShopBuyPage()
    local countEdit = GUI.GetChild(shopBuyPage,"countEdit",false)
    if countEdit then
        GUI.EditSetTextM(countEdit, tostring(count))
    end
    --显示总价格
    ShopStoreUI.OnUpdateTotalPrice()
end

--当前物品被点击设置价钱信息
function DonateShopUI.OnItemClickSetPriceInfo()
    local item = GUI.GetByGuid(data.selectItemGuid)
    --设置货币类型的图标
    local coinImgId = coinImgList[GUI.GetData(item, "coinType")]
    
    local shopBuyPage = DonateShopUI.GetShopBuyPage()

    local ownIcon = GUI.GetChild(shopBuyPage,"ownicon")
    if ownIcon then
        GUI.ImageSetImageID(ownIcon, coinImgId)
    end
    local spendIcon = GUI.GetChild(shopBuyPage,"spendIcon")
    if spendIcon then
        GUI.ImageSetImageID(spendIcon, coinImgId)
    end
    
    --设置商品价格
    ShopStoreUI.SelectBuyItemPrice = tonumber(GUI.GetData(item, "price"))
    
    --设置商品数量
    DonateShopUI.UpdateCountEdit(1)
end

function DonateShopUI.OnItemClickShowInfo()
    local item = GUI.GetByGuid(data.selectItemGuid)
    data.selectItemIndex = GUI.GetData(item,"index")
    data.selectItemId = GUI.GetData(item, "itemID")
    -- 展示信息
    local donateShopItemInfo = _gt.GetUI("donateShopItemInfo")
    if donateShopItemInfo == nil then
        donateShopItemInfo = GUI.GroupCreate(ShopStoreUI.panelBg,"donateShopItemInfo", 0, 0, 0, 0)
        UILayout.SetSameAnchorAndPivot(donateShopItemInfo, UILayout.TopLeft)
        _gt.BindName(donateShopItemInfo,"donateShopItemInfo")
    end
    ShopDetailUI.ShowDetailInfo(ShopDetailUI.PackShopItemInfos(data.selectItemId, true), donateShopItemInfo, nil, _gt)
end

function DonateShopUI.OnItemClick(guid)
    if guid ~= data.selectItemGuid or data.isFistSelected then
        DonateShopUI.UnCheckPreItem()
        data.selectItemGuid = guid
        data.isFistSelected = false
        DonateShopUI.CheckItem()
        DonateShopUI.OnItemClickShowInfo()
        -- 设置商品价格信息
        DonateShopUI.OnItemClickSetPriceInfo()
    else
        DonateShopUI.CheckItem()
    end
    local item = GUI.GetByGuid(data.selectItemGuid)
    local number = tonumber(GUI.GetData(item, "number"))
    local buyBtn = _gt.GetUI("buyBtn")
    if number == 0 then
        GUI.ButtonSetShowDisable(buyBtn,false)
    else
        GUI.ButtonSetShowDisable(buyBtn,true)
    end
    DonateShopUI.RefreshUI()
end

function DonateShopUI.CreatItemPool()
    local ItemScroll = _gt.GetUI("ItemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(ItemScroll) + 1
    local item = GUI.CheckBoxExCreate(ItemScroll,"item" .. curCount, "1800400360", "1800400361", 0, 0, false, 350, 100)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "DonateShopUI", "OnItemClick")
    
    --物品图标背景
    local ItemIconBg = ItemIcon.Create(item,"ItemIconBg",-115,1)
    GUI.SetIsRaycastTarget(ItemIconBg, false)

    --物品名称
    local ItemName = GUI.CreateStatic( item,"ItemName", "道具名称", 105, -20, 200, 50)
    UILayout.StaticSetFontSizeColorAlignment(ItemName, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(ItemName, UILayout.Left)

    --货币背景、图标、数值
    local CoinBg=UILayout.CreateAttrBar(item,"CoinBg",105,20,180,UILayout.Left)
    
    -- 限购数量
    local limits = GUI.CreateStatic(item,"limits", "99", 300, 10, 60, 50)
    UILayout.StaticSetFontSizeColorAlignment(limits, UIDefine.FontSizeS, UIDefine.BrownColor, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(limits, UILayout.Left)
    
    return item
end

function DonateShopUI.UpdateItemInfo(guid, index)
    local itemInfo = DonateShopUI.GetItemInfo(index)
    local item = GUI.GetByGuid(guid)
    if item ~= nil then
        GUI.SetData(item, "index", index)
        GUI.SetData(item, "price", itemInfo.coinNum)
        GUI.SetData(item, "name", itemInfo.name)
        GUI.SetData(item, "itemID", itemInfo.id)
        GUI.SetData(item, "coinType", itemInfo.coinName)
        GUI.SetData(item, "number", itemInfo.number)
    end
    local ItemIconBg = GUI.GetChild(item, "ItemIconBg")
    if ItemIconBg ~= nil then
        GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.Border,UIDefine.ItemIconBg[itemInfo.grade]);
        GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.Icon, itemInfo.icon);
        GUI.ItemCtrlSetElementRect(ItemIconBg, eItemIconElement.Icon, 0, -1,60,61);
    end

    local ItemName = GUI.GetChild(item, "ItemName")
    if ItemName ~= nil then
        GUI.StaticSetText(ItemName, itemInfo.name)
    end

    local CoinBg =GUI.GetChild(item, "CoinBg")
    UILayout.RefreshAttrBar2(CoinBg,coinImgList[itemInfo.coinName], tostring(itemInfo.coinNum));
    
    local limits = GUI.GetChild(item, "limits")
    if limits ~= nil then
        GUI.StaticSetText(limits, itemInfo.number)
    end
end

function DonateShopUI.RefreshItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])+1
    DonateShopUI.UpdateItemInfo(guid, index)

    local item = GUI.GetByGuid(guid)
    local itemID = GUI.GetData(item, "itemID")
    GUI.CheckBoxExSetCheck(item, index == data.selectItemIndex)
    if data.isPassedIntoID then
        GUI.CheckBoxExSetCheck(item, false)
        if itemID == data.selectItemId then
            data.isPassedIntoID = false
            data.selectItemIndex = index
        end
    end
    if itemID == data.selectItemId then
        DonateShopUI.OnItemClick(guid)
    end
    if data.isFistSelected and index == 1 then
        DonateShopUI.OnItemClick(guid)
    end
end

function DonateShopUI.GetItemInfo(index)
    local itemInfo = {id = 101,grade = 2,name = "",icon = "1900100100",coinName = "银币",coinNum = "0",number = "0"}
    local itemByList = data.typeItem[itemList[index]]
    if itemByList ~= nil then
        local itemConfig = DB.GetOnceItemByKey2(itemByList["KeyName"])
        itemInfo.id = itemConfig.Id
        itemInfo.name = itemConfig.Name
        itemInfo.grade = itemConfig.Grade
        itemInfo.icon = tostring(itemConfig.Icon)
        itemInfo.coinName = itemByList["BuyName"]
        itemInfo.coinNum = itemByList["Buy"]
        local buyNum = nil
        if DonateShopUI.allBuyCnt then
            buyNum = DonateShopUI.allBuyCnt[tostring(itemInfo.id)]
        end
        if buyNum == nil then
            buyNum = 0
        end
        itemInfo.number = itemByList["Number"] - buyNum
    end
    return itemInfo
end

function DonateShopUI.OnTipsBtnClick()
    --local donateShopPage = _gt.GetUI("donateShopPage")
    --if donateShopPage == nil then
    --    return
    --end

    local tips = GUI.ImageCreate(ShopStoreUI.panelBg, "Tip", "1800400290", 0, 0, false, 410, 180)
    GUI.SetIsRaycastTarget(tips, true)
    tips:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRemoveWhenClick(tips, true)

    local msgs = {
        "<color=#ffffff>捐献每日0点刷新限购数量，定期更换可兑换物品列表。</color>",
        "<color=#ffffff>捐献道具可获得“装备功勋”</color>",
        "<color=#ffffff>捐献宠物可获得“宠物功勋”</color>",
        "<color=#ffffff>不同道具需要花费不同功勋兑换。</color>",
    }
    local icon1 = coinImgList[coinList[1]]
    local icon2 = coinImgList[coinList[2]]
    for i = 1, #msgs do
        local text;
        if i == 1 then
            text = GUI.CreateStatic(tips, "text" .. i, msgs[i], 10, 26 * i, 380, 52, "system", true, false)
        else
            text = GUI.CreateStatic(tips, "text" .. i, msgs[i], 10, 26 * i + 26, 380, 26, "system", true, false)
            if i == 2 then
                local icon = GUI.ImageCreate(text, "icon", icon1, 105, -5, false,35,35)
            elseif i == 3 then
                local icon = GUI.ImageCreate(text, "icon", icon2, 105, -1, false,35,35)
            end
        end
        UILayout.StaticSetFontSizeColorAlignment(text, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
        UILayout.SetSameAnchorAndPivot(text, UILayout.Top)
    end
end

function DonateShopUI.SetVisible(visible)
    local shopDetailNode = GUI.GetChild(ShopStoreUI.panelBg, "detailNode",false)
    local detailNode = _gt.GetUI("detailNode")
    local shopItemScrollBg = GUI.GetChild(ShopStoreUI.panelBg,"ItemScrollBg",false)
    local panelBgNode = GUI.GetChild(ShopStoreUI.panelBg, "Node",false)
    local shopBuyPage = GUI.GetChild(panelBgNode, "buyPage")
    local shopBuyScroll = GUI.GetChild(shopBuyPage, "buyScroll")
    local donateShopPage = _gt.GetUI("donateShopPage")
    local shopBuyBtn = GUI.GetChild(shopBuyPage,"buyBtn")
    GUI.SetVisible(donateShopPage,visible)
    GUI.SetVisible(detailNode, visible)
    GUI.SetVisible(shopBuyScroll,not visible)
    GUI.SetVisible(shopDetailNode,not visible)
    GUI.SetVisible(shopItemScrollBg,not visible)
    GUI.SetVisible(shopBuyBtn,not visible)

    if DonateShopUI.isNPC then
        DonateShopUI.isNPC = false
        ShopStoreUI.ScrollToDonateShopBtn()
    end
    
    isVisible = visible

    data = DonateShopUI.InitData()
    
    if visible then
        --DonateShopUI.RefreshItemScroll
        local selectItemName = nil
        if ShopStoreUI.ManualSelectFirstItemID ~= -1 then
            local itemDB = DB.GetOnceItemByKey1(ShopStoreUI.ManualSelectFirstItemID)
            selectItemName = itemDB.KeyName
            for shopPath, goodsList in pairs(DonateShopList) do
                local count = 0
                for itemname, iteminfo in pairs(goodsList) do
                    count = count + 1
                    if itemDB.KeyName == iteminfo["KeyName"] then
                        for subindex, subPath in pairs(GoodsSubType) do
                            if shopPath == subPath then
                                for index, path in pairs(GoodsType) do
                                    if string.find(subPath,path) then
                                        data.typeIndex = index
                                    end
                                end
                                data.typeFlagIndex = data.typeIndex
                                data.subTypeIndex = subindex
                                data.isPassedIntoID = true
                                data.isFistSelected = false
                                data.selectItemId = tostring(ShopStoreUI.ManualSelectFirstItemID)
                                data.typeItem = DonateShopList[GoodsSubType[subindex]]
                                ShopStoreUI.ManualSelectFirstItemID = -1
                            end
                        end
                    end
                end
            end
        end
        itemList = {}
        if data.typeItem == nil then
            return ""
        end
        for i , v in pairs(data.typeItem) do
            table.insert(itemList,i)
        end
        table.sort(itemList,sortList)
        local index = 1
        if data.selectItemId ~= -1 then
            for key, iteminfo in pairs(data.typeItem) do
                if selectItemName == iteminfo["KeyName"] then
                    for i = 1, #itemList, 1 do
                        if itemList[i] == key then
                            index = i
                        end
                    end
                end
                -- local itemConfig = DB.GetOnceItemByKey2(itemByList["KeyName"])
            end
        end
        local count = #itemList
        local ItemScroll = _gt.GetUI("ItemScroll")
        GUI.LoopScrollRectSetTotalCount(ItemScroll, 0)
        GUI.LoopScrollRectSetTotalCount(ItemScroll, count)
        GUI.LoopScrollRectRefreshCells(ItemScroll)
        GUI.ScrollRectSetNormalizedPosition(ItemScroll,Vector2.New(0,math.min((index-1)/count,1)))
        DonateShopUI.RefreshUI()
    end
end

-- 创建页面
function DonateShopUI.Create(panelBgNode)
    _gt = UILayout.NewGUIDUtilTable();
    local donateShopPage = GUI.GroupCreate(panelBgNode,"donateShopPage", 0, 0, 0, 0)
    _gt.BindName(donateShopPage, "donateShopPage")

    local GoodsTypeBg = GUI.ImageCreate(donateShopPage,"GoodsTypeBg", "1800400010", -385, 36, false, 270, 500)
    _gt.BindName(GoodsTypeBg,"GoodsTypeBg")

    local ItemScrollBg = GUI.ImageCreate(donateShopPage,"ItemScrollBg", "1800400010", -35, 36, false, 390, 500)
    _gt.BindName(ItemScrollBg, "ItemScrollBg")

    --详情按钮
    local tipBtn = GUI.ButtonCreate(ItemScrollBg,"tipBtn", "1800702030", -160, -210, Transition.ColorTint, "")
    UILayout.SetSameAnchorAndPivot(tipBtn, UILayout.Center)
    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick , "DonateShopUI", "OnTipsBtnClick")

    local text1 = GUI.CreateStatic(ItemScrollBg,"text1", "道具名称", -95, -210, 100, 30)
    UILayout.StaticSetFontSizeColorAlignment(text1, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(text1, UILayout.Center)

    local text2 = GUI.CreateStatic(ItemScrollBg,"text2", "今日限购", 140, -210, 100, 30)
    UILayout.StaticSetFontSizeColorAlignment(text2, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(text2, UILayout.Center)
    
    local ItemScroll = GUI.LoopScrollRectCreate(ItemScrollBg,"ItemScroll", 0, 25, 370, 420,
            "DonateShopUI","CreatItemPool","DonateShopUI","RefreshItemScroll",0, false, Vector2.New(350, 100), 1, UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(ItemScroll, Vector2.New(0, 6))
    _gt.BindName(ItemScroll, "ItemScroll")
    
    local infoBg = GUI.ImageCreate(donateShopPage,"infoBg", "1800400010", 345, -110, false, 350, 320)
    _gt.BindName(infoBg, "infoBg")

    --兑换按钮
    local buyBtn = GUI.ButtonCreate(donateShopPage,"buyBtn", "1800402080", 430, 260, Transition.ColorTint, "购买",160,50,false)
    _gt.BindName(buyBtn, "buyBtn")
    GUI.SetIsOutLine(buyBtn, true)
    GUI.ButtonSetTextFontSize(buyBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(buyBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(buyBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(buyBtn, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(buyBtn, UCE.PointerClick, "DonateShopUI", "OnBuyBtnClick")
    
    --捐献按钮
    -- local donateBtn = GUI.ButtonCreate(donateShopPage,"donateBtn", "1800402080", 250, 260, Transition.ColorTint, "捐献",160,50,false)
    -- _gt.BindName(donateBtn, "donateBtn")
    -- GUI.SetIsOutLine(donateBtn, true)
    -- GUI.ButtonSetTextFontSize(donateBtn, UIDefine.FontSizeXL)
    -- GUI.ButtonSetTextColor(donateBtn, UIDefine.WhiteColor)
    -- GUI.SetOutLine_Color(donateBtn, UIDefine.OutLine_BrownColor)
    -- GUI.SetOutLine_Distance(donateBtn, UIDefine.OutLineDistance)
    -- GUI.RegisterUIEvent(donateBtn, UCE.PointerClick, "DonateShopUI", "OnDonateBtnClick")
    return donateShopPage
end

-- 点击捐献按钮
function DonateShopUI.OnDonateBtnClick()
    --等级达到则打开捐献界面
    local level = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    if level < LevelRestrictions then
        CL.SendNotify(NOTIFY.ShowBBMsg, "捐献系统"..LevelRestrictions.."级开启，您尚未达到开启等级")
    else
        GUI.OpenWnd("DonateUI")
    end 
end

function DonateShopUI.GetShopBuyPage()
    local panelBgNode = GUI.GetChild(ShopStoreUI.panelBg, "Node",false)
    local shopBuyPage = GUI.GetChild(panelBgNode, "buyPage",false)
    return shopBuyPage
end

--获取购买数量
function DonateShopUI.GetBuyNum()
    local shopBuyPage = DonateShopUI.GetShopBuyPage()
    local countEdit = GUI.GetChild(shopBuyPage,"countEdit",false)
    local num = 0
    if countEdit ~= nil then
        num = tonumber(GUI.EditGetTextM(countEdit))
    end
    return num
end

-- 刷新商品列表，服务器调用（每次购买完成后，刷新限购数量）
function DonateShopUI.RefreshGoodsScroll()
    local count = #itemList
    local ItemScroll = _gt.GetUI("ItemScroll")
    GUI.LoopScrollRectSetTotalCount(ItemScroll, count)
    GUI.LoopScrollRectRefreshCells(ItemScroll)
end

-- 点击购买，兑换按钮
function DonateShopUI.OnBuyBtnClick()
    --FormDonateEquipAndPet.DonateShopPurchase(player, item_id, item_num, item_price, buy_name)  --捐献商店购买
    --获取购买数量
    local num = DonateShopUI.GetBuyNum()
    if num ~= 0 then
        --获取当前物品信息
        local item = GUI.GetByGuid(data.selectItemGuid)
        local itemID = GUI.GetData(item, "itemID")
        local itemPrice = GUI.GetData(item, "price")
        local buyName = GUI.GetData(item, "coinType")
        local name = GUI.GetData(item, "name")
        local number = tonumber(GUI.GetData(item, "number"))
        --如果购买数量大于限购数量，则进行调整
        if number < num then
            DonateShopUI.UpdateCountEdit(number)
            CL.SendNotify(NOTIFY.ShowBBMsg, "超过购买上限，" .. name .. "今日限购"..number.."个")
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "DonateShopPurchase",itemID,num,itemPrice,buyName)
        end
    end
end 