require "ShopDetailUI"

ShopStoreUI={}

ShopStoreUI.ManualSelectFirstItem = false
ShopStoreUI.ManualSelectFirstItemID = -1
ShopStoreUI.SelectBuyItemPrice = 0
ShopStoreUI.SelectBuyItemGUID = 0
ShopStoreUI.SelectBuyItemIndex = 1
ShopStoreUI.PlusBtnTimer = nil
ShopStoreUI.MinusBtnTimer = nil
ShopStoreUI.ShopItems = {}
ShopStoreUI.CoinType = RoleAttr.RoleAttrBindGold
ShopStoreUI.panelBg = nil
ShopStoreUI.ShopTypePreSelectBtn = nil
ShopStoreUI.Tab = nil
ShopStoreUI.Item_Info = {} --每次服务器下发单个商店数据
ShopStoreUI.ItemDatas = {}
ShopStoreUI.SelectTabIndex = 1
ShopStoreUI.Version = {}
ShopStoreUI.Name2Index = {}
ShopStoreUI.TypeMax = 0
ShopStoreUI.GongXunFlag = 0
ShopStoreUI.FirstClick = true
ShopStoreUI.SelectItemCoin = 0
ShopStoreUI.SpecialShopName = nil
--#TEST
--ShopStoreUI.Tab = {
--    ["师徒商店"] = {Index=1, MoneyName="良师值",  ConsumeType="attr", MoneyType=347, Icon="1800408390", IsPet=0},
--    ["测试商店"] = {Index=2, MoneyName="测试点",  ConsumeType="int", MoneyType="abc_name_0", Icon="1800408380", IsPet=0},
--    ["道具商店"] = {Index=4, MoneyName="道具点",  ConsumeType="item", MoneyType="暗淡的金丹", Icon="1800408380", IsPet=0}
--}

local _gt = UILayout.NewGUIDUtilTable()

function ShopStoreUI.Main( parameter )
    _gt = UILayout.NewGUIDUtilTable()

    local panel = GUI.WndCreateWnd("ShopStoreUI" , "ShopStoreUI" , 0 , 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "兑换商店","ShopStoreUI","OnExit")
    _gt.BindName(panelBg, "panelBg")
    ShopStoreUI.panelBg = panelBg

    GUI.ImageCreate(panelBg,"ItemScrollBg", "1800400010", -180, 36, false, 680, 502)
    GUI.GroupCreate(panelBg,"Node", 0, 0, 0, 0)

    ShopStoreUI.InitData()

    --目前只刷新金币/绑定金币
    CL.RegisterAttr(RoleAttr.RoleAttrGold, ShopStoreUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrBindGold, ShopStoreUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrMentor, ShopStoreUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrPvp, ShopStoreUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrHonor, ShopStoreUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrAdv, ShopStoreUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrGuildContribute, ShopStoreUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrGuildFund, ShopStoreUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrExpLimit, ShopStoreUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrDuel, ShopStoreUI.UpdateMoneyValue)

    CL.RegisterMessage(GM.CustomDataUpdate, "ShopStoreUI", "OnCustomDataUpdate")
    CL.RegisterMessage(GM.RefreshBag, "ShopStoreUI", "OnRefreshBag")
end

function ShopStoreUI.OnRefreshBag()
    local ConsumeType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].ConsumeType
    local MoneyType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].MoneyType
    if ConsumeType=="item" then
        local item = DB.GetOnceItemByKey2(MoneyType)
        if item then
            local count = LD.GetItemCountById(item.Id)
            ShopStoreUI.UpdateOwnMoneyCount(tostring(count))
        end
    end
end

function ShopStoreUI.OnCustomDataUpdate(type, key, val)
    if type == 1 then
        local ConsumeType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].ConsumeType
        local MoneyType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].MoneyType
        if ConsumeType=="int" and key == MoneyType then
            ShopStoreUI.UpdateOwnMoneyCount(tostring(val))
        end
    elseif type == 2 then
        local ConsumeType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].ConsumeType
        local MoneyType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].MoneyType
        if ConsumeType=="int" and key == MoneyType then
            ShopStoreUI.UpdateOwnMoneyCount(tostring(val))
        end
    end
end

function ShopStoreUI.RefreshTab()
    ShopStoreUI.ArrangeData()
    ShopStoreUI.ShowTypeLst()
    test(ShopStoreUI.SpecialShopName)
    --默认点击第一项
    if ShopStoreUI.ShopTypePreSelectBtn ~= nil then
        ShopStoreUI.OnGoodsTypeClick(GUI.GetGuid(ShopStoreUI.ShopTypePreSelectBtn))
    end
end

function ShopStoreUI.RefreshData()
    ShopStoreUI.CreateItemListPage()

    if ShopStoreUI.Item_Info ~= nil then
        for k, v in pairs(ShopStoreUI.Item_Info) do
            if ShopStoreUI.Name2Index[k] ~= nil then
                ShopStoreUI.ItemDatas[ShopStoreUI.Name2Index[k]] = v
            else
                print("当前分类不存在："..k)
            end
        end
    end
    --清除防止后续重复再遍历
    ShopStoreUI.Item_Info = {}
    --客户端Lua缓存
    UIDefine.ItemDatas = ShopStoreUI.ItemDatas

    local itemCount = ShopStoreUI.ItemDatas ~= nil and ShopStoreUI.ItemDatas[ShopStoreUI.SelectTabIndex] ~= nil and #ShopStoreUI.ItemDatas[ShopStoreUI.SelectTabIndex] or 0
    local buyScroll = _gt.GetUI("buyScroll")
    GUI.LoopScrollRectSetTotalCount(buyScroll, itemCount+1)
    GUI.LoopScrollRectSetTotalCount(buyScroll, itemCount)
end

function ShopStoreUI.OnDestroy()
end

function ShopStoreUI.UpdateMoneyValue(attrType, value)
    local ConsumeType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].ConsumeType
    local MoneyType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].MoneyType
    if ConsumeType == "attr" and  CL.ConvertAttr(MoneyType) == attrType then
        ShopStoreUI.UpdateOwnMoneyCount(tostring(value)) 
    end
end

--初始化数据
function ShopStoreUI.InitData()
    ShopStoreUI.PlusBtnTimer = Timer.New(ShopStoreUI.OnPlusBtnListener,0.18, -1, true)
    ShopStoreUI.MinusBtnTimer = Timer.New(ShopStoreUI.OnMinusBtnListener,0.18, -1, true)
end

--打开界面的时候调用
function ShopStoreUI.OnShow(parameter)
    if GUI.GetWnd("ShopStoreUI") == nil then
        return
    end
    ShopStoreUI.SelectBuyItemIndex = 1
    ShopStoreUI.SelectTabIndex = 1
    ShopStoreUI.ManualSelectFirstItemID = -1
    ShopStoreUI.GongXunFlag = 1
    ShopStoreUI.FirstClick = true
    if parameter ~= nil then
		--test(parameter)
        local val = string.split(parameter, ",")
        local count = #val
        if count>=1 then
			if tonumber(val[1]) ~= nil then
				ShopStoreUI.SelectTabIndex = tonumber(val[1])
			else
				local val = string.split(val[1], ":")
				--print(val[2])
				ShopStoreUI.SelectTabIndex = tonumber(val[2])
			end
        end
        if count>=2 then
			if tonumber(val[2]) ~= nil then
				ShopStoreUI.ManualSelectFirstItemID = tonumber(val[2])
			else
				local val = string.split(val[2], ":")
				--print(val[2])
				ShopStoreUI.ManualSelectFirstItemID = tonumber(val[2])
			end
        end
        if count>=3 then
            ShopStoreUI.GongXunFlag = tonumber(val[3]) 
        end
    end
    --取出缓存
    if UIDefine.ItemDatas ~= nil then
        ShopStoreUI.ItemDatas = UIDefine.ItemDatas
    end

    ShopStoreUI.SelectBuyItemGUID = 0
    ShopStoreUI.ManualSelectFirstItem = true

    --请求类型表头数据
    CL.SendNotify(NOTIFY.SubmitForm, "FormExchangeShop", "GetTabData")
end

--退出界面
function ShopStoreUI.OnExit()
    GUI.DestroyWnd("ShopStoreUI")
end

--对数据进行排序，并由 名字Key转为 数字索引Key
--["道具商店"] = {Index=4, MoneyName="道具点",  ConsumeType="item", MoneyType="暗淡的金丹", Icon="1800408380", IsPet=0}
--["师徒商店"] = {Index=1, MoneyName="良师值",  ConsumeType="attr", MoneyType=347, Icon="1800408390", IsPet=0},
--转变为
--[1] = {SubShopName="师徒商店", Index=1, MoneyName="良师值",  ConsumeType="attr", MoneyType=347, Icon="1800408390", IsPet=0},
--[2] = {SubShopName="道具商店",Index=4, MoneyName="道具点",  ConsumeType="item", MoneyType="暗淡的金丹", Icon="1800408380", IsPet=0}
function ShopStoreUI.ArrangeData()
    if ShopStoreUI.Tab ~= nil then
        ShopStoreUI.TempTab = {}
        for k0, v0 in pairs(ShopStoreUI.Tab) do
            local index = #ShopStoreUI.TempTab + 1
            ShopStoreUI.TempTab[index] = v0
            ShopStoreUI.TempTab[index].SubShopName = k0
        end
        local count = #ShopStoreUI.TempTab
        for i = 1, count do
            local minTarget = i
            for j = i+1, count do
                if ShopStoreUI.TempTab[j].Index < ShopStoreUI.TempTab[minTarget].Index then
                    minTarget = j
                end
            end
            if minTarget ~= i then
                local tmp = ShopStoreUI.TempTab[minTarget]
                ShopStoreUI.TempTab[minTarget] = ShopStoreUI.TempTab[i]
                ShopStoreUI.TempTab[i] = tmp
            end
        end
        ShopStoreUI.Tab = {}
        ShopStoreUI.Tab = ShopStoreUI.TempTab
        for i = 1, count do
            ShopStoreUI.Name2Index[ShopStoreUI.Tab[i].SubShopName] = i
        end
    end
end

function ShopStoreUI.ShowTypeLst()
    local typeBtnScroll = _gt.GetUI("typeBtnScroll")
    if typeBtnScroll then
        for i = 1, ShopStoreUI.TypeMax do
            local btn = _gt.GetUI("typeBtn"..i)
            if btn then
                GUI.SetVisible(btn, false)
            end
        end
    end

    local count = (ShopStoreUI.Tab ~= nil and #ShopStoreUI.Tab or 0)
    if ShopStoreUI.TypeMax < count then
        ShopStoreUI.TypeMax = count
    end
    if ShopStoreUI.SelectTabIndex > count then
        ShopStoreUI.SelectTabIndex = 1
    end

    if typeBtnScroll == nil then
        typeBtnScroll = GUI.ScrollRectCreate(ShopStoreUI.panelBg, "typeBtnScroll", -180, -240, 676, 54, 0, true, Vector2.New(169,50), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 0)
        _gt.BindName(typeBtnScroll, "typeBtnScroll")
        GUI.SetInertia(typeBtnScroll,false)
        typeBtnScroll:RegisterEvent(UCE.PointerClick)
        typeBtnScroll:RegisterEvent(UCE.EndDrag)
        GUI.RegisterUIEvent(typeBtnScroll, UCE.EndDrag , "ShopStoreUI", "OnTypeBtnDrag")
        --设置初始位置
        --GUI.ScrollRectSetNormalizedPosition(typeBtnScroll, Vector2.New(0,0))

        local leftTag = GUI.ImageCreate(ShopStoreUI.panelBg, "leftTag", "1801507230", 60, 70, false, 32, 32)
        _gt.BindName(leftTag, "leftTag")
        UILayout.SetSameAnchorAndPivot(leftTag, UILayout.TopLeft)
        GUI.SetVisible(leftTag, count>4)

        local rightTag = GUI.ImageCreate(ShopStoreUI.panelBg, "rightTag", "1801507230", 776, 102, false, 32, 32)
        _gt.BindName(rightTag, "rightTag")
        UILayout.SetSameAnchorAndPivot(rightTag, UILayout.TopLeft)
        GUI.SetEulerAngles(rightTag,Vector3.New(0, 0, -180))
        GUI.SetVisible(rightTag, count>4)
    end
    for i = 1, count do
        local btn = _gt.GetUI("typeBtn"..i)
        if btn == nil then
            local goodsType = GUI.CheckBoxExCreate(typeBtnScroll,"typeBtn"..i, "1800402180", "1800402181", (i - 1) * 167, 0, false, 169, 50)
            _gt.BindName(goodsType, "typeBtn"..i)
            GUI.RegisterUIEvent(goodsType, UCE.PointerClick , "ShopStoreUI", "OnGoodsTypeClick")
            GUI.SetData(goodsType, "index", i)
            GUI.CheckBoxExSetCheck(goodsType, i==ShopStoreUI.SelectTabIndex)
            if i==ShopStoreUI.SelectTabIndex then 
			ShopStoreUI.ShopTypePreSelectBtn = goodsType end
            local goodsTypeLabel = GUI.CreateStatic(goodsType,"name"..i, ShopStoreUI.Tab[i].SubShopName, 18, 0, 138, 46)
            _gt.BindName(goodsTypeLabel, "goodsTypeLabel"..i)
            UILayout.StaticSetFontSizeColorAlignment(goodsTypeLabel, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
            UILayout.SetSameAnchorAndPivot(goodsTypeLabel, UILayout.Center)

            local icon = GUI.ImageCreate(goodsType, "icon", ShopStoreUI.Tab[i].Icon, 10, 5, false, 40, 40)
            _gt.BindName(icon, "icon"..i)
            UILayout.SetSameAnchorAndPivot(icon, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(icon, false)
        else
            if i==ShopStoreUI.SelectTabIndex then
                ShopStoreUI.ShopTypePreSelectBtn = btn
            end
            local goodsTypeLabel = _gt.GetUI("goodsTypeLabel"..i)
            if goodsTypeLabel then
                GUI.StaticSetText(goodsTypeLabel, ShopStoreUI.Tab[i].SubShopName)
            end
            local icon = _gt.GetUI("icon"..i)
            if icon then
                GUI.ImageSetImageID(icon, ShopStoreUI.Tab[i].Icon)
            end
            GUI.SetVisible(btn, true)
        end
    end
    local leftTag = _gt.GetUI("leftTag")
    if leftTag then
        GUI.SetVisible(leftTag, count>4)
    end
    local rightTag = _gt.GetUI("rightTag")
    if rightTag then
        GUI.SetVisible(rightTag, count>4)
    end
	if ShopStoreUI.SelectTabIndex > 4  then
        GUI.ScrollRectSetNormalizedPosition(typeBtnScroll,Vector2.New(1, 0))
    else
        GUI.ScrollRectSetNormalizedPosition(typeBtnScroll,Vector2.New(0, 0))
    end
    ShopStoreUI.OnTypeBtnDrag(_gt.GetGuid(typeBtnScroll))
end

function ShopStoreUI.OnGoodsTypeClick(guid)
    ShopStoreUI.ManualSelectFirstItem = true
    local btn = GUI.GetByGuid(guid)
    if ShopStoreUI.ShopTypePreSelectBtn and btn ~= ShopStoreUI.ShopTypePreSelectBtn then
        GUI.CheckBoxExSetCheck(ShopStoreUI.ShopTypePreSelectBtn, false)
    end
    GUI.CheckBoxExSetCheck(btn, true)
    ShopStoreUI.ShopTypePreSelectBtn = btn
    ShopStoreUI.SelectTabIndex = tonumber(GUI.GetData(btn, "index"))
    if ShopStoreUI.ItemDatas ~= nil and ShopStoreUI.ItemDatas[ShopStoreUI.SelectTabIndex] ~= nil then
        ShopStoreUI.CreateItemListPage()
        local count = #ShopStoreUI.ItemDatas[ShopStoreUI.SelectTabIndex]
        local buyScroll = _gt.GetUI("buyScroll")
        GUI.LoopScrollRectSetTotalCount(buyScroll, count+1)
        GUI.LoopScrollRectSetTotalCount(buyScroll, count)
    end
    test(ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].SubShopName)
    test(ShopStoreUI.SpecialShopName)
    if  ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].SubShopName == ShopStoreUI.SpecialShopName then --功勋分装备和宠物
        ShopStoreUI.CreateItemListPage()
        DonateShopUI.SetDataIdx(ShopStoreUI.GongXunFlag == 0 and 1 or ShopStoreUI.GongXunFlag)
        CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "GetExploitShopData")
        DonateShopUI.GetExploitData()
    end
    --仍然请求查询新数据：服务端依赖 Version校验，如有新数据，则发回新数据
    CL.SendNotify(NOTIFY.SubmitForm, "FormExchangeShop", "GetMainData", ShopStoreUI.GetVersion(), ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].SubShopName)

    --重置数量和货币类型
    ShopStoreUI.UpdateSelectItemInfo(1)
    --刷新拥有的货币
    ShopStoreUI.UpdateOwnMoneyCount()
end

function ShopStoreUI.GetVersion()
    if ShopStoreUI.Version == nil or ShopStoreUI.Version[ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].SubShopName] == nil then
        return 0
    else
        return ShopStoreUI.Version[ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].SubShopName]
    end
end

--创建购买界面
function ShopStoreUI.CreateItemListPage()
    local panelBg = _gt.GetUI("panelBg")
    local panelBgNode = GUI.GetChild(panelBg, "Node")
    local buyAndRedeemPage = _gt.GetUI("buyPage")
    local donateShopPage = _gt.GetUI("donateShopPage")
    if donateShopPage == nil then
        require("DonateShopUI")
        donateShopPage = DonateShopUI.Create(panelBgNode)
        _gt.BindName(donateShopPage, "donateShopPage")
        DonateShopUI.SetVisible(false)
    end
    if buyAndRedeemPage == nil then
        buyAndRedeemPage = GUI.GroupCreate(panelBgNode,"buyPage", 0, 0, 0, 0)
        _gt.BindName(buyAndRedeemPage, "buyPage")
        local buyScroll = GUI.LoopScrollRectCreate(buyAndRedeemPage,"buyScroll", -180, 36, 660, 480,
                "ShopStoreUI","CreatBuyItemPool","ShopStoreUI","RefreshBuyScroll",0, false, Vector2.New(320, 100),2, UIAroundPivot.Top, UIAnchor.Top)
        GUI.ScrollRectSetChildSpacing(buyScroll, Vector2.New(8, 6))
        _gt.BindName(buyScroll, "buyScroll")

        local infoBg= GUI.ImageCreate(buyAndRedeemPage,"infoBg", "1800400010", 345, -110, false, 350, 320)

        local text1 = GUI.CreateStatic(buyAndRedeemPage,"text1", "数量", 205, 90, 100, 30)
        UILayout.StaticSetFontSizeColorAlignment(text1, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    	UILayout.SetSameAnchorAndPivot(text1, UILayout.Center)

        local text2 = GUI.CreateStatic(buyAndRedeemPage,"text2", "花费", 205, 150, 100, 30)
        UILayout.StaticSetFontSizeColorAlignment(text2, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    	UILayout.SetSameAnchorAndPivot(text2, UILayout.Center)

        local text3 = GUI.CreateStatic(buyAndRedeemPage,"text3", "拥有", 205, 200, 100, 30)
        UILayout.StaticSetFontSizeColorAlignment(text3, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    	UILayout.SetSameAnchorAndPivot(text3, UILayout.Center)

        local minusBtn = GUI.ButtonCreate(buyAndRedeemPage,"MinusBtn", "1800402140", 280,90, Transition.ColorTint, "")
        _gt.BindName(minusBtn, "MinusBtn")
        local plusBtn = GUI.ButtonCreate(buyAndRedeemPage,"PlusBtn", "1800402150", 480, 90, Transition.ColorTint, "")
        _gt.BindName(plusBtn, "PlusBtn")
        local countEdit = GUI.EditCreate(buyAndRedeemPage,"countEdit", "1800400390", "", 380, 90, Transition.ColorTint, "system", 0, 0, 30, 8, InputType.Standard, ContentType.IntegerNumber)
        _gt.BindName(countEdit, "countEdit")
        GUI.EditSetFontSize(countEdit, UIDefine.FontSizeM)
        GUI.EditSetTextColor(countEdit, UIDefine.BrownColor)
        GUI.EditSetTextM(countEdit, "1")
        GUI.RegisterUIEvent(countEdit, UCE.EndEdit, "ShopStoreUI", "OnBuyCountModify")
        plusBtn:RegisterEvent(UCE.PointerDown)
        plusBtn:RegisterEvent(UCE.PointerUp)
        minusBtn:RegisterEvent(UCE.PointerDown)
        minusBtn:RegisterEvent(UCE.PointerUp)
        GUI.RegisterUIEvent(plusBtn, UCE.PointerDown, "ShopStoreUI", "OnPlusBtnDown")
        GUI.RegisterUIEvent(plusBtn, UCE.PointerUp, "ShopStoreUI", "OnPlusBtnUp")
        GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "ShopStoreUI", "OnPlusBtnClick")
        GUI.RegisterUIEvent(minusBtn, UCE.PointerDown, "ShopStoreUI", "OnMinusBtnDown")
        GUI.RegisterUIEvent(minusBtn, UCE.PointerUp, "ShopStoreUI", "OnMinusBtnUp")
        GUI.RegisterUIEvent(minusBtn, UCE.PointerClick, "ShopStoreUI", "OnMinusBtnClick")

        local spendBg = GUI.ImageCreate(buyAndRedeemPage,"spendBg", "1800900040", 380, 152, false, 252, 35)
		--local plusBtn = GUI.ButtonCreate(buyAndRedeemPage,"PlusBtn", "1800402150", 480, 90, Transition.ColorTint, "")
        local icon = GUI.ImageCreate(spendBg,"spendIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold], -105, -1, false, 35, 35)
		_gt.BindName(icon, "spendIcon")
		GUI.SetIsRaycastTarget(spendBg, true)
		GUI.RegisterUIEvent(spendBg, UCE.PointerClick, "ShopStoreUI", "OnMoneyIconClick")
		
        local count = GUI.CreateStatic(spendBg,"spendCount", "0", 10, -1,200,30)
        _gt.BindName(count, "spendCount")
        GUI.StaticSetFontSize(count, UIDefine.FontSizeS)
        GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

        local ownBg = GUI.ImageCreate(buyAndRedeemPage,"ownBg", "1800900040", 380, 202, false, 252, 35)
        local icon = GUI.ImageCreate(ownBg,"ownicon", UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold], -105, -1, false, 35, 35)
        _gt.BindName(icon, "ownicon")
		GUI.SetIsRaycastTarget(ownBg, true)
		GUI.RegisterUIEvent(ownBg, UCE.PointerClick, "ShopStoreUI", "OnMoneyIconClick")
		
        local count = GUI.CreateStatic(ownBg,"owncount", "0", 10, -1,200,30)
        _gt.BindName(count, "owncount")
        GUI.StaticSetFontSize(count, UIDefine.FontSizeS)
        GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)
        ShopStoreUI.UpdateSelectItemInfo(1)
        ShopStoreUI.UpdateOwnMoneyCount()
		
		
		local MoneyAddBtn =  GUI.ButtonCreate(ownBg,"MoneyAddBtn", "1800702020", 110,0, Transition.ColorTint, "")
		--1800702020
		--1801502010
        _gt.BindName(minusBtn, "MoneyAddBtn") 
		GUI.SetIsOutLine(MoneyAddBtn, true)
        GUI.ButtonSetTextFontSize(MoneyAddBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(MoneyAddBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(MoneyAddBtn, UIDefine.OutLine_BrownColor)
        GUI.SetOutLine_Distance(MoneyAddBtn, UIDefine.OutLineDistance)
        GUI.RegisterUIEvent(MoneyAddBtn, UCE.PointerClick, "ShopStoreUI", "OnMoneyAddBtnClick")

        local buyBtn = GUI.ButtonCreate(buyAndRedeemPage,"buyBtn", "1800402080", 430, 260, Transition.ColorTint, "购买",160,50,false)
        _gt.BindName(buyBtn, "buyBtn")
        GUI.SetIsOutLine(buyBtn, true)
        GUI.ButtonSetTextFontSize(buyBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(buyBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(buyBtn, UIDefine.OutLine_BrownColor)
        GUI.SetOutLine_Distance(buyBtn, UIDefine.OutLineDistance)
        GUI.RegisterUIEvent(buyBtn, UCE.PointerClick, "ShopStoreUI", "OnBuyBtnClick")
    end
end

--点击图标显示货币信息
function ShopStoreUI.OnMoneyIconClick(guid)
	--test("点击图标显示货币信息")
	if ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].MoneyInfo ~= nil then
		--test("MoneyInfo:"..ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].MoneyInfo)
		local panelBg = _gt.GetUI("panelBg")
		local panelBgNode = GUI.GetChild(panelBg, "Node")
		local icon = GUI.GetByGuid(guid)
		local hint = GUI.ImageCreate(icon, "hint", "1800400290", -200, -55, false, 370, 80)
		local msg = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].MoneyInfo
		local text = GUI.CreateStatic(hint, "text", msg, 0, 0, 340, 80);
		GUI.StaticSetFontSize(text, 22);
		GUI.SetIsRemoveWhenClick(hint, true)
		_gt.BindName(hint, "hint")
	end
end

--点击加号打开页面或自动寻路
function ShopStoreUI.OnMoneyAddBtnClick()
	--test("点击加号打开页面或自动寻路")
	if ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].GetType ~= nil then
		if ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].GetType == "OpenUI" then
			local OpenUIList = string.split(ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].Target, "#")
			test(OpenUIList[1])
			if  OpenUIList[2] then
				test(OpenUIList[2])
			end
			GUI.OpenWnd(OpenUIList[1], OpenUIList[2])
		elseif ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].GetType == "Run" then
			LD.StartAutoMove(tonumber(ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].Target))	
			ShopStoreUI.OnExit()
		end
	end
end

function ShopStoreUI.OnBuyBtnClick()
    local countEdit = _gt.GetUI("countEdit")
    if countEdit ~= nil then
        local num = tonumber(GUI.EditGetTextM(countEdit))
        CL.SendNotify(NOTIFY.SubmitForm, "FormExchangeShop", "Purchase", ShopStoreUI.GetVersion(), ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].SubShopName, ShopStoreUI.SelectBuyItemIndex, num)
    end
end

function ShopStoreUI.OnBuyCountModify()
    local countEdit = _gt.GetUI("countEdit")
    if countEdit ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt)
        if num < 1 then num = 1 end
        if num > 99 then num = 99 end
        GUI.EditSetTextM(countEdit, tostring(num))
    end

    --显示总价格
    ShopStoreUI.OnUpdateTotalPrice()
end

function ShopStoreUI.OnPlusBtnDown()
    ShopStoreUI.PlusBtnOneClickFlag = true
    if ShopStoreUI.PlusBtnTimer ~= nil then
        ShopStoreUI.PlusBtnTimer:Start()
    end
end

function ShopStoreUI.OnPlusBtnClick()
    ShopStoreUI.OnChangeBuyItemNum(1)
end

function ShopStoreUI.OnMinusBtnClick()
    ShopStoreUI.OnChangeBuyItemNum(-1)
end

function ShopStoreUI.OnPlusBtnUp()
    if ShopStoreUI.PlusBtnTimer ~= nil then
        ShopStoreUI.PlusBtnTimer:Stop()
        ShopStoreUI.PlusBtnTimer:Reset(ShopStoreUI.OnPlusBtnListener,0.18, -1, true)
    end
end

function ShopStoreUI.OnPlusBtnListener()
    ShopStoreUI.OnChangeBuyItemNum(1)
end

function ShopStoreUI.OnChangeBuyItemNum(deltaNum)
    local countEdit = _gt.GetUI("countEdit")
    if countEdit ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt) + deltaNum
        if num < 1 then num = 1 end
        if num > 99 then num = 99 end
        GUI.EditSetTextM(countEdit, tostring(num))
    end

    --显示总价格
    ShopStoreUI.OnUpdateTotalPrice()
end

function ShopStoreUI.OnMinusBtnUp()
    if ShopStoreUI.MinusBtnTimer ~= nil then
        ShopStoreUI.MinusBtnTimer:Stop()
        ShopStoreUI.MinusBtnTimer:Reset(ShopStoreUI.OnMinusBtnListener,0.18, -1, true)
    end
end

function ShopStoreUI.OnMinusBtnDown()
    if ShopStoreUI.MinusBtnTimer ~= nil then
        ShopStoreUI.MinusBtnTimer:Start()
    end
end

function ShopStoreUI.OnMinusBtnListener()
    ShopStoreUI.OnChangeBuyItemNum(-1)
end

function ShopStoreUI.OnSellBtnClick()
    local sellinfo = ""
    local first = true
    for i, v in pairs(ShopStoreUI.SellSelectItemLst) do
        if first then
            first = false
            sellinfo = sellinfo..v.guid..","..v.count
        else
            sellinfo = sellinfo..";"..v.guid..","..v.count
        end
    end
    if string.len(sellinfo) > 0 then
        CL.SendNotify(NOTIFY.ShopOpe, 3, sellinfo)
    end
    --清空选中列表
    ShopStoreUI.SellSelectItemLst = {}
end

--创建出售道具列表
function ShopStoreUI.CreatBuyItemPool()
    local buyScroll = _gt.GetUI("buyScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(buyScroll)
    local item = GUI.CheckBoxExCreate(buyScroll,"item" .. curCount, "1800400360", "1800400361", 0, 0, false, 320, 100)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "ShopStoreUI", "OnBuyItemClick")

    --物品图标背景
    local ItemIconBg = ItemIcon.Create(item,"ItemIconBg",-105,1)
    GUI.SetIsRaycastTarget(ItemIconBg, false)

    --物品名称
    local ItemName = GUI.CreateStatic( item,"ItemName", "道具名称", 105, -20, 200, 50)
    GUI.StaticSetFontSize(ItemName, 22)
    GUI.SetAnchor(ItemName, UIAnchor.Left)
    GUI.StaticSetAlignment(ItemName, TextAnchor.MiddleLeft)
    GUI.SetPivot(ItemName, UIAroundPivot.Left)
    GUI.SetColor(ItemName, UIDefine.BrownColor)

    --货币背景、图标、数值
    local CoinBg=UILayout.CreateAttrBar(item,"CoinBg",105,20,200,UILayout.Left)
    return item
end

--刷新出售道具列表
function ShopStoreUI.RefreshBuyScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])+1

    ShopStoreUI.UpdateBuyItemInfo(guid, index)

    if ShopStoreUI.ManualSelectFirstItem then
        --指定选中道具
        if ShopStoreUI.ManualSelectFirstItemID ~= -1 then
            local item = GUI.GetByGuid(guid)
            local itemID = tonumber(GUI.GetData(item, "itemID"))
            if itemID == ShopStoreUI.ManualSelectFirstItemID then
                ShopStoreUI.ManualSelectFirstItemID = -1
                ShopStoreUI.OnBuyItemClick(guid)
            end
        --默认选中第一个
        elseif index==1 then
            ShopStoreUI.ManualSelectFirstItem = false
            ShopStoreUI.OnBuyItemClick(guid)
        end
    end
end

function ShopStoreUI.UnCheckPreBuyItem()
    if ShopStoreUI.SelectBuyItemGUID ~= "0" then
        local item = GUI.GetByGuid(ShopStoreUI.SelectBuyItemGUID)
        if item ~= nil then
            GUI.CheckBoxExSetCheck(item, false)
        end
    end
end

function ShopStoreUI.CheckBuyItem()
    local item = GUI.GetByGuid(ShopStoreUI.SelectBuyItemGUID)
    if item ~= nil then
        GUI.CheckBoxExSetCheck(item, true)
    end
end

function ShopStoreUI.GetItemInfo(index)
    local itemInfo = {id=0, grade=2, icon="1900100100", name="不存在道具"..index, num=0, coinImg="", coinCount=7800, bind=true  }
    local target = ShopStoreUI.ItemDatas[ShopStoreUI.SelectTabIndex] ~= nil and ShopStoreUI.ItemDatas[ShopStoreUI.SelectTabIndex][index] or nil
    local itemConfig = nil
    local isPet = true
    if target and ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex] ~= nil then
        if ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].IsPet == 1 then
            itemConfig = DB.GetOncePetByKey2(target.keyname)
        else
            itemConfig = DB.GetOnceItemByKey2(target.keyname)
            isPet = false
        end
    end
    if itemConfig then
        itemInfo.id = itemConfig.Id
        itemInfo.name = itemConfig.Name
        itemInfo.grade = isPet and itemConfig.Type or itemConfig.Grade
        itemInfo.icon = isPet and tostring(itemConfig.Head) or tostring(itemConfig.Icon)
        itemInfo.num = 0
        itemInfo.coinImg = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].Icon
        itemInfo.coinCount = target.price
        itemInfo.bind = (target.bind==1 and true or false)
        itemInfo.isPet =isPet;
    end
    return itemInfo
end

function ShopStoreUI.UpdateBuyItemInfo(guid, index)
    local itemInfo = ShopStoreUI.GetItemInfo(index)
    
    local item = GUI.GetByGuid(guid)
    if item ~= nil then
        GUI.SetData(item, "index", index)
        GUI.SetData(item, "price", itemInfo.coinCount)
        GUI.SetData(item, "itemID", itemInfo.id)
        GUI.CheckBoxExSetCheck(item, index == ShopStoreUI.SelectBuyItemIndex)
        if index == ShopStoreUI.SelectBuyItemIndex then
            ShopStoreUI.SelectBuyItemGUID = guid
        end
    end

    local ItemIconBg = GUI.GetChild(item, "ItemIconBg")
    if ItemIconBg ~= nil then
        GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.Border,UIDefine.ItemIconBg[itemInfo.grade]);
        GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.Icon, itemInfo.icon);
        GUI.ItemCtrlSetElementRect(ItemIconBg, eItemIconElement.Icon, 0, -1,70,69);
        --老方法 下面
        --if itemInfo.isPet then
        --    GUI.ItemCtrlSetElementRect(ItemIconBg, eItemIconElement.Icon, 0, -1,70,69);
        --else
        --    --GUI.ItemCtrlSetElementRect(ItemIconBg, eItemIconElement.Icon, 0, -1,60,61);
        --end

        if itemInfo.bind then
            GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.LeftTopSp, 1800707120);
            GUI.ItemCtrlSetElementRect(ItemIconBg, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
        else
            GUI.ItemCtrlSetElementValue(ItemIconBg, eItemIconElement.LeftTopSp, nil);
        end
    end

    local ItemName = GUI.GetChild(item, "ItemName")
    if ItemName ~= nil then
        GUI.StaticSetText(ItemName, itemInfo.name)
    end

    local CoinBg =GUI.GetChild(item, "CoinBg")
    UILayout.RefreshAttrBar2(CoinBg,itemInfo.coinImg, tostring(itemInfo.coinCount));
end

function ShopStoreUI.OnCheckItemForUI(guid, select, numInfo)
    local item =  GUI.GetByGuid(guid)
    local Select =  GUI.GetChild(item, "Select")
    if Select ~= nil then
        GUI.SetVisible(Select, select)
    end
    local decreaseBtn =  GUI.GetChild(item, "decreaseBtn")
    if decreaseBtn ~= nil then
        GUI.SetVisible(decreaseBtn, select)
    end
    local Count =  GUI.GetChild(item, "Count")
    if Count ~= nil then
        GUI.StaticSetText(Count, numInfo)
    end
end

function ShopStoreUI.OnBuyItemClick(guid)
    --取消前一个item项的选中
    ShopStoreUI.UnCheckPreBuyItem()
    ShopStoreUI.SelectBuyItemGUID = guid
    local item = GUI.GetByGuid(guid)
    ShopStoreUI.SelectBuyItemIndex = tonumber(GUI.GetData(item, "index"))
    ShopStoreUI.SelectBuyItemPrice = tonumber(GUI.GetData(item, "price"))
    --选中当前item项
    ShopStoreUI.CheckBuyItem()
    local count = 1
    ShopStoreUI.CoinType = RoleAttr.RoleAttrBindGold
    --显示详情
    local target = ShopStoreUI.ItemDatas[ShopStoreUI.SelectTabIndex] ~= nil and ShopStoreUI.ItemDatas[ShopStoreUI.SelectTabIndex][ShopStoreUI.SelectBuyItemIndex] or nil
    if target then
        if ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].IsPet == 1 then
            ShopDetailUI.ShowDetailInfo(ShopDetailUI.PackShopPetInfos(target.keyname), ShopStoreUI.panelBg, nil, _gt)
        else
            local config = DB.GetOnceItemByKey2(target.keyname)
            if config then
                ShopDetailUI.ShowDetailInfo(ShopDetailUI.PackShopItemInfos(config.Id, true), ShopStoreUI.panelBg, nil, _gt)
            end
        end
    end
    --显示预览按钮
    local detailNode = _gt.GetUI("detailNode")
    if detailNode and target then
        local petPreviewBtn = _gt.GetUI("petPreviewBtn")
        if petPreviewBtn == nil then
            petPreviewBtn = GUI.ButtonCreate(detailNode,"petPreviewBtn", "1800702060", 1055,70, Transition.ColorTint, "")
            _gt.BindName(petPreviewBtn, "petPreviewBtn")
            GUI.RegisterUIEvent(petPreviewBtn, UCE.PointerClick, "ShopStoreUI", "OnPetPreviewBtn")
        end
        GUI.SetData(petPreviewBtn, "petName", target.keyname)
        GUI.SetVisible(petPreviewBtn, ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].IsPet==1)
		
		if string.find(target.keyname, "信物") ~= nil then
			local guardPreviewBtn = _gt.GetUI("guardPreviewBtn")
			if not guardPreviewBtn then
				guardPreviewBtn = GUI.ButtonCreate(detailNode,"guardPreviewBtn", "1800702060", 1055,70, Transition.ColorTint, "")
				_gt.BindName(guardPreviewBtn, "guardPreviewBtn")
				GUI.RegisterUIEvent(guardPreviewBtn, UCE.PointerClick, "ShopStoreUI", "OnguardPreviewBtn")
			end
			local guard_key_name = string.split(target.keyname,'信物')
			--test(guard_key_name[1])
			local guard = DB.GetOnceGuardByKey2(guard_key_name[1])
			GUI.SetData(guardPreviewBtn, "guardId", guard.Id)
			GUI.SetVisible(guardPreviewBtn, true)
		else
			--test("非信物道具")
			local guardPreviewBtn = _gt.GetUI("guardPreviewBtn")
			GUI.SetVisible(guardPreviewBtn, false)
		end
    end
    --显示总价格
    ShopStoreUI.OnUpdateTotalPrice()
end

function ShopStoreUI.OnPetPreviewBtn(guid)
    local btn = GUI.GetByGuid(guid)
    local petName = GUI.GetData(btn, "petName")
	CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "QueryPetByKeyName", petName)
end

function ShopStoreUI.OnguardPreviewBtn(guid)
	local btn = GUI.GetByGuid(guid)
	local guardId = GUI.GetData(btn, "guardId")
	if guardId then
		GlobalProcessing.ShowGuardInfo(guardId)
	end
end

function ShopStoreUI.UpdateSelectItemInfo(count)
    local countEdit = _gt.GetUI("countEdit")
    if countEdit then
        GUI.EditSetTextM(countEdit, tostring(count))
    end
    --改变货币类型
    local ownIcon = _gt.GetUI("ownicon")
    if ownIcon then
        GUI.ImageSetImageID(ownIcon, ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].Icon)
    end
    local spendIcon = _gt.GetUI("spendIcon")
    if spendIcon then
        GUI.ImageSetImageID(spendIcon, ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].Icon)
    end
	
end

function ShopStoreUI.UpdateOwnMoneyCount(moneyCount)
    local count = _gt.GetUI("owncount")
    if count then
        if moneyCount == nil then
            local ConsumeType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].ConsumeType
            local MoneyType = ShopStoreUI.Tab[ShopStoreUI.SelectTabIndex].MoneyType
            if ConsumeType=="attr" then
                moneyCount = tostring(CL.GetAttr(CL.ConvertAttr(MoneyType)))
            elseif ConsumeType=="int" then
                moneyCount = tostring(CL.GetLongCustomData(MoneyType))
            elseif ConsumeType=="item" then
                local item = DB.GetOnceItemByKey2(MoneyType)
                if item then
                    moneyCount = LD.GetItemCountById(item.Id)
                end
            end
        end
        ShopStoreUI.SelectItemCoin = moneyCount
        GUI.StaticSetText(count, UIDefine.ExchangeMoneyToStr(moneyCount))
        ShopStoreUI.OnUpdateTotalPrice()
    end
end

function ShopStoreUI.OnTypeBtnDrag(guid)
    local leftTag = _gt.GetUI("leftTag")
    local rightTag = _gt.GetUI("rightTag")
    local count = #ShopStoreUI.TempTab
    local typeBtnScroll = GUI.GetByGuid(guid)
    local x,y = GUI.GetNormalizedPosition(typeBtnScroll):Get()
    -- test(x,y)
    -- test(ShopStoreUI.SelectTabIndex)
    if leftTag then
        GUI.SetVisible(leftTag, count>4)
    end
    if rightTag then
        GUI.SetVisible(rightTag, count>4)
    end
    -- local width = GUI.ScrollRectGetGridLayoutSizeX(typeBtnScroll)
    -- GUI.ScrollRectSetNormalizedPosition(typeBtnScroll,Vector2.New(2/count, 0))
    -- local x,y = GUI.GetNormalizedPosition(typeBtnScroll):Get()
    -- test(x,y)
    -- if x == 0 and y == 0 then
    --     test(ShopStoreUI.SelectTabIndex)
    --     if ShopStoreUI.SelectTabIndex == 1 then
    --         GUI.SetVisible(leftTag,false)
    --     elseif ShopStoreUI.SelectTabIndex == count then
    --         GUI.SetVisible(rightTag,false)
    --     end
    -- else
    if ShopStoreUI.FirstClick then
        ShopStoreUI.FirstClick = false
        if ShopStoreUI.SelectTabIndex > 4  then
            GUI.SetVisible(rightTag,false)
        else
            GUI.SetVisible(leftTag,false)
        end
    elseif x == 0 then
        GUI.SetVisible(rightTag,false)
    elseif x == 1 then
        GUI.SetVisible(leftTag,false)
    end
end

function ShopStoreUI.OnUpdateTotalPrice()
    local count = _gt.GetUI("owncount")
    local countEdit = _gt.GetUI("countEdit")
    local spendCount = _gt.GetUI("spendCount")
    if countEdit ~= nil and spendCount ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt)
        GUI.StaticSetText(spendCount, tostring(num * ShopStoreUI.SelectBuyItemPrice))
    end

    -- 花费的钱数在数量不够时，可以变为红色
    local moneySpend = 0
    local moneyCount = 0
    if spendCount then
        moneySpend = tonumber(GUI.StaticGetText(spendCount))
    end
    if count then
        moneyCount = tonumber(GUI.StaticGetText(count))
        if moneyCount == nil then
            moneyCount = ShopStoreUI.SelectItemCoin
        end
    end
    if moneySpend > tonumber(moneyCount) then
        GUI.SetColor(spendCount,UIDefine.RedColor)
    else
        GUI.SetColor(spendCount,UIDefine.WhiteColor)
    end
end

function ShopStoreUI.OnClickMinusBtn(guid)
    local btn = GUI.GetByGuid(guid)
    local index = 0
    if btn ~= nil then
        local itemgui = GUI.GetData(btn, "itemGUI")
        local item = GUI.GetByGuid(itemgui)
        if item ~= nil then
            local num = tonumber(GUI.GetData(item, "total"))
            local price = tonumber(GUI.GetData(item, "price"))
            local itemGUID = tostring(GUI.GetData(item, "guid"))
            index = tonumber(GUI.GetData(item, "index"))
            ShopStoreUI.OnCheckItem(itemgui, false, num, price,itemGUID)
        end
    end
end

function ShopStoreUI.ScrollToDonateShopBtn()
    local count = #ShopStoreUI.Tab
    local typeBtnScroll = GUI.GetChild(ShopStoreUI.panelBg,"typeBtnScroll")
    for i , tab in pairs(ShopStoreUI.Tab) do
        if tab.SubShopName == "功勋商店" then
            GUI.ScrollRectSetNormalizedPosition(typeBtnScroll,Vector2.New((i-1)/(count-1), 0))
            ShopStoreUI.OnTypeBtnDrag(_gt.GetGuid(typeBtnScroll))
        end
    end
end

function ShopStoreUI.ClickDonateShopBtn()
    for i , tab in pairs(ShopStoreUI.Tab) do
        local btnName = "typeBtn"..i
        if tab.SubShopName == "功勋商店" then
            DonateShopUI.isNPC = true
            local typeBtnScroll = GUI.GetChild(ShopStoreUI.panelBg,"typeBtnScroll")
            local btn = GUI.GetChild(typeBtnScroll,btnName)
            --local btn = GUI.Get("ShopStoreUI/panelBg/typeBtnScroll/" .. btnName)
            ShopStoreUI.OnGoodsTypeClick(GUI.GetGuid(btn))
            ShopStoreUI.ScrollToDonateShopBtn()
        end
    end
end