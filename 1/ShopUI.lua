require "ShopDetailUI"

ShopUI={}
local QualityRes = UIDefine.ItemIconBg
local test = function () end --要去掉打印就把 print 变为 function () end
local _gt = UILayout.NewGUIDUtilTable()
local StaticSetFontSizeColorAlignment = UILayout.StaticSetFontSizeColorAlignment
local tabList = {
    { "购买", "buyTabBtn", "OnBuyTabBtnClick","buyAndRedeemPage","ShopUI/panelBg/Node/buyAndRedeemPage"},
    { "出售", "sellTabBtn", "OnSellTabBtnClick","sellPage","ShopUI/panelBg/Node/sellPage"},
    { "赎回", "redeemTabBtn", "OnRedeemTabBtnClick","buyAndRedeemPage","ShopUI/panelBg/Node/buyAndRedeemPage"}
}

local SelectList = {
    [1] = {icon = "1900110280", text = "装备"},
    [2] = {icon = "1900920760", text = "宝石"},
    [3] = {icon = "1900040450", text = "信物"},
    [4] = {icon = "1900000630", text = "材料"},
    [5] = {icon = "1900000300", text = "消耗品"},
}

local QualityList = {
    [1] = {color = UIDefine.WhiteColor, text = "普通"},
    [2] = {color = UIDefine.GreenColor, text = "优秀"},
    [3] = {color = UIDefine.BlueColor, text = "精良"},
    [4] = {color = UIDefine.PurpleColor, text = "史诗"},
    [5] = {color = UIDefine.OrangeColor, text = "传说"},
}

local ruleType = {
    ["装备"] = {Type = 1},
    ["宝石"] = {Type = 3},
    ["信物"] = {Type = 6},
    ["材料"] = {Type = 3},
    ["消耗品"] = {Type = 2}
}
local SelectQuality = {}

ShopUI.Flag = 1 -- 1 = 购买 2 = 赎回
ShopUI.ManualSelectFirstItem = false
ShopUI.SelectBuyItemPrice = 0
ShopUI.SelectBuyItemGUID = 0
ShopUI.SelectBuyItemIndex = 0
ShopUI.SellSelectItemLst = {}
ShopUI.PlusBtnTimer = nil
ShopUI.MinusBtnTimer = nil
ShopUI.ShopItems = {}
ShopUI.tabIndex = 1 -- 1=购买页  2=出售页  3=赎回页
ShopUI.SellItems = {}
ShopUI.CoinType = RoleAttr.RoleAttrBindGold
ShopUI.ShopType = 2 --商店类型0=宠物商店 1=道具商店 2=随身商店
ShopUI.panelBg = nil
ShopUI.BuyScroll = nil
ShopUI.SelectSellItemCountUI = nil
ShopUI.SelectSellItemIndex = -1
ShopUI.SelectSellItemTotalCount = 0
ShopUI.PressedTimer = nil
ShopUI.PressedCounter = 0

local ONEPAGE_COUNT = 42
local PRESS_WAIT_TIME = 5

function ShopUI.Main( parameter )
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("ShopUI" , "ShopUI" , 0 , 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "商    店","ShopUI","OnExit")
    _gt.BindName(panelBg, "panelBg")
    ShopUI.panelBg = panelBg
    UILayout.CreateRightTab(tabList, "ShopUI")

    GUI.ImageCreate(panelBg,"ItemScrollBg", "1800400010", -180, 10, false, 680, 560)
    GUI.GroupCreate(panelBg,"Node", 0, 0, 0, 0)

    ShopUI.InitData()
    CL.RegisterMessage(GM.RefreshBag,"ShopUI" , "OnRefreshBag")
    CL.RegisterMessage(GM.ShopBuyBackItemRefresh,"ShopUI" , "OnShopBuyBackItemRefresh")

    --目前只刷新金币/绑定金币
    CL.RegisterAttr(RoleAttr.RoleAttrGold, ShopUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrBindGold, ShopUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrGuildAchievement, ShopUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrGuildFightScore, ShopUI.UpdateMoneyValue)
end

function ShopUI.OnDestroy()
    CL.UnRegisterMessage(GM.RefreshBag,"ShopUI" , "OnRefreshBag")
    CL.UnRegisterMessage(GM.ShopBuyBackItemRefresh,"ShopUI" , "OnShopBuyBackItemRefresh")
end

function ShopUI.SwitchType2UI(isType2)
    local redeemTabBtn = GUI.Get("ShopUI/panelBg/tabList/redeemTabBtn")
    if redeemTabBtn ~= nil then
        GUI.SetPositionY(redeemTabBtn, isType2 and 236 or 342)
    end
    local sellTabBtn = GUI.Get("ShopUI/panelBg/tabList/sellTabBtn")
    if sellTabBtn ~= nil then
        GUI.SetPositionY(sellTabBtn, isType2 and 130 or 236)
    end
    local tabBuy = GUI.Get("ShopUI/panelBg/tabList/buyTabBtn")
    if tabBuy ~= nil then
        GUI.SetVisible(tabBuy, isType2==false)
    end
    local bottomBg = GUI.Get("ShopUI/panelBg/tabList/bottomBg")
    if bottomBg ~= nil then
        GUI.SetPositionY(bottomBg, isType2 and 205 or 308)
        local line0 = GUI.GetChild(bottomBg, "line0")
        if isType2 and line0 == nil then
            line0 = GUI.ImageCreate(bottomBg, "line0", "1801305020", 0, -213)
        end
        if line0 ~= nil then
            GUI.SetVisible(line0, isType2)
        end
    end
    local intervalSp1 = GUI.Get("ShopUI/panelBg/tabList/sellTabBtn/intervalSp")
    if intervalSp1 ~= nil then
        GUI.SetVisible(intervalSp1, isType2==false)
    end
end

function ShopUI.UpdateMoneyValue(attrType, value)
    test("UpdateMoneyValue========>"..tostring(attrType)..","..tostring(value))
    if ShopUI.tabIndex == 1 or ShopUI.tabIndex == 3 then
        if ShopUI.CoinType == attrType then
            ShopUI.UpdateOwnMoneyCount(tostring(value))
        end
    end
end

--初始化数据
function ShopUI.InitData()
    ShopUI.tabIndex = ShopUI.ShopType==2 and 2 or 1
    ShopUI.PlusBtnTimer = Timer.New(ShopUI.OnPlusBtnListener,0.18, -1, true)
    ShopUI.MinusBtnTimer = Timer.New(ShopUI.OnMinusBtnListener,0.18, -1, true)
end

function ShopUI.OnRefreshBag()
    ShopUI.SellItems = LD.GetShopSellItems()
    if ShopUI.tabIndex == 2 then
        --包裹更新了，刷新数据
        if ShopUI.SellItems ~= nil then
            local sellScroll = _gt.GetUI("sellScroll")
            local sellCount = ShopUI.SellItems.Count<ONEPAGE_COUNT and ONEPAGE_COUNT or ShopUI.SellItems.Count
            --GUI.LoopScrollRectSetTotalCount(sellScroll, sellCount+1)
            --GUI.LoopScrollRectSetTotalCount(sellScroll, sellCount)
            ShopUI.cre_and_ref_sell_item_scroll(sellCount,ShopUI.sell_scroll_num_max or 0)
            --刷新详情页
            ShopDetailUI.ShowDetailInfo(nil, ShopUI.panelBg, ShopUI.tabIndex, _gt)
            ShopUI.OnUpdateSellTotalPrice()
        end
    elseif ShopUI.tabIndex == 3 then
        local _Count = ShopUI.ShopItems.buy_back_list ~= nil and ShopUI.ShopItems.buy_back_list.Count or 0
        if _Count == 0 then
            ShopUI.RefeshRedeemBtns()
        end

    end
end

function ShopUI.OnShopBuyBackItemRefresh()
    ShopUI.ShopItems = LD.GetShopItems()
    if ShopUI.tabIndex == 3 then
        --购买页和赎回页需要根据切换刷新
        if ShopUI.ShopItems.buy_back_list ~= nil then
            --默认选中第一个
            ShopUI.ManualSelectFirstItem = true
            local _Count = ShopUI.ShopItems.buy_back_list.Count
            local buyScroll = _gt.GetUI("buyScroll")
            GUI.LoopScrollRectSetTotalCount(buyScroll, _Count+1)
            GUI.LoopScrollRectSetTotalCount(buyScroll, _Count)
            --最后为空则清空
            if _Count == 0 then
                ShopDetailUI.ShowDetailInfo(nil, ShopUI.panelBg, ShopUI.tabIndex, _gt)
                ShopUI.SelectBuyItemPrice = 0
                ShopUI.OnUpdateTotalPrice()
            end
        end
    end
end

--打开界面的时候调用
function ShopUI.OnShow(parameter)
    if GUI.GetWnd("ShopUI") == nil then
        return
    end
    ShopUI.ShopItems = LD.GetShopItems()
    ShopUI.SellItems = LD.GetShopSellItems()
    ShopUI.ShopType = parameter ~= nil and tonumber(parameter) or 2
    ShopUI.SwitchType2UI(ShopUI.ShopType == 2)
    if ShopUI.ShopType==2 then
        ShopUI.OnSellTabBtnClick()
    else
        ShopUI.OnBuyTabBtnClick()
        ShopUI.ParseTabShow()
    end
    ShopUI.Init()
end

function ShopUI.Init()
end

function ShopUI.ParseTabShow()
    --处理页签显示
    if ShopUI.ShopItems.type == 1 then
        local config = DB.GetOnceShopByKey1(ShopUI.ShopItems.shop_id)
        if config then
            local showCount = 2
            if config.SaleAble == 0 then
                showCount = showCount - 1
                local sellTabBtn = GUI.Get("ShopUI/panelBg/tabList/sellTabBtn")
                if sellTabBtn then
                    GUI.SetVisible(sellTabBtn, false)
                end
            end
            if config.RedempAble == 0 then
                showCount = showCount - 1
                local redeemTabBtn = GUI.Get("ShopUI/panelBg/tabList/redeemTabBtn")
                if redeemTabBtn then
                    GUI.SetVisible(redeemTabBtn, false)
                end
            end
            --尾部花纹
            local linePic = GUI.Get("ShopUI/panelBg/tabList/bottomBg")
            if linePic then
                GUI.SetPositionY(linePic, 96 + 106*showCount)
            end
        end
    end
end

--刷新界面
function ShopUI.Refresh()
    for i = 1, #tabList do
      if i~=ShopUI.tabIndex then
        local page = _gt.GetUI(tabList[i][4])
        GUI.SetVisible(page,false)
      end
    end

    local curPage = _gt.GetUI(tabList[ShopUI.tabIndex][4])
    GUI.SetVisible(curPage,true)
    ShopUI.SwitchPageBuyOrRedeem()
end

function ShopUI.SwitchPageBuyOrRedeem()
    local buyBtn = _gt.GetUI("buyBtn")
    local redeemBtn = _gt.GetUI("redeemBtn")
    if buyBtn ~= nil then
        GUI.SetVisible(buyBtn, ShopUI.tabIndex==1)
    end
    if redeemBtn ~= nil then
        GUI.SetVisible(redeemBtn, ShopUI.tabIndex==3)
    end

    ShopUI.RefeshRedeemBtns()
    
end

function ShopUI.RefeshRedeemBtns()
    --赎回
    if  ShopUI.tabIndex==3 then
        local PlusBtn = _gt.GetUI("PlusBtn")
        local MinusBtn = _gt.GetUI("MinusBtn")
        test(tostring(PlusBtn)..","..tostring(MinusBtn))
        if PlusBtn ~= nil and MinusBtn ~= nil then
            local _Count = ShopUI.ShopItems.buy_back_list ~= nil and ShopUI.ShopItems.buy_back_list.Count or 0
            GUI.ButtonSetShowDisable(PlusBtn,_Count>0)
            GUI.ButtonSetShowDisable(MinusBtn,_Count>0)
        end
        local countEdit = _gt.GetUI("countEdit")
        if countEdit ~= nil then
            local num = 0
            GUI.EditSetTextM(countEdit, tostring(num))
        end
        --刷新拥有的货币
        ShopUI.UpdateOwnMoneyCount()
    end
end

--点击购买页签
function ShopUI.OnBuyTabBtnClick()
    --ShopUI.ShopItems.def_item_id=11201--测试 软皮鞭  
    --ShopUI.ShopItems.def_item_id=11101--测试 青铜双剑
    --ShopUI.ShopItems.def_item_id=10902--测试 松木杖
    --ShopUI.ShopItems.def_item_id=11202--测试 金蛇鞭  
    --ShopUI.ShopItems.def_item_id=12701--测试 软布鞋  
    --ShopUI.ShopItems.def_item_id=12801--测试 生铁护腕
    ShopUI.Flag = 1
    ShopUI.SelectBuyItemGUID = 0
    ShopUI.tabIndex=1
    ShopUI.ManualSelectFirstItem = true
    ShopUI.CreateBuyAndRedeemPage()
    ShopUI.Refresh()
    ShopUI.ShowSellNumNode(false)

    --购买页和赎回页需要根据切换刷新
    if ShopUI.ShopItems.shop_item_list ~= nil then
        local buyScroll = _gt.GetUI("buyScroll")
        GUI.LoopScrollRectSetTotalCount(buyScroll, ShopUI.ShopItems.shop_item_list.Count+1)
        GUI.LoopScrollRectSetTotalCount(buyScroll, ShopUI.ShopItems.shop_item_list.Count)

        --设置到目标位置
        if ShopUI.ShopItems.def_item_id ~= 0 then
            local targetIndex = 1
            local count = ShopUI.ShopItems.shop_item_list and ShopUI.ShopItems.shop_item_list.Count or 0
            if count > 0 then
                for i = 1, count do
                    if ShopUI.ShopItems.shop_item_list[i-1].id == ShopUI.ShopItems.def_item_id then
                        targetIndex = i
                        break
                    end
                end
                --test("count="..count..",targetIndex="..targetIndex)
                -- local countM = math.max(count-8,1)
                -- targetIndex = math.max(math.min(countM, targetIndex), 1)
                -- local moveY = math.floor((targetIndex-1)/2)/(count/2)
                -- GUI.ScrollRectSetNormalizedPosition(buyScroll, Vector2.New(0,moveY))
                -- test("count="..count..",targetIndex="..targetIndex..",moveY="..moveY)
         
                --GUI.LoopScrollRectSrollToCell(buyScroll, targetIndex-1, 0) --等价于下面
                local moveY = (targetIndex-1)/(count-1)
                GUI.ScrollRectSetNormalizedPosition(buyScroll, Vector2.New(0,moveY))
                --test("moveY")
            end
        end

        UILayout.OnTabClick(ShopUI.tabIndex, tabList)
    end
end

--点击出售页签
function ShopUI.OnSellTabBtnClick()
    ShopUI.tabIndex=2
    ShopUI.ManualSelectFirstItem = true
    ShopUI.CreateSellPage()
    ShopUI.Refresh()

    ShopUI.ShowSellNumNode(false)

    --清空选择
    ShopUI.SellSelectItemLst = {}
    ShopDetailUI.ShowDetailInfo(nil, ShopUI.panelBg, ShopUI.tabIndex, _gt)
    ShopUI.OnSelectAllBtnState()
    ShopUI.OnUpdateSellTotalPrice()


    if ShopUI.SellItems ~= nil then
        local sellScroll = _gt.GetUI("sellScroll")
        local sellCount = ShopUI.SellItems.Count<ONEPAGE_COUNT and ONEPAGE_COUNT or ShopUI.SellItems.Count
        --GUI.LoopScrollRectSetTotalCount(sellScroll, sellCount+1)
        --GUI.LoopScrollRectSetTotalCount(sellScroll, sellCount)
        ShopUI.cre_and_ref_sell_item_scroll(sellCount,ShopUI.sell_scroll_num_max or 0)
    end

    UILayout.OnTabClick(ShopUI.tabIndex, tabList)
end

--点击赎回页签
function ShopUI.OnRedeemTabBtnClick()
    local _Count = ShopUI.ShopItems.buy_back_list ~= nil and ShopUI.ShopItems.buy_back_list.Count or 0
    if _Count < 1 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "没有可赎回的道具")
        UILayout.OnTabClick(ShopUI.tabIndex, tabList)
        return
    end
    ShopUI.Flag = 2

    ShopUI.SelectBuyItemGUID = 0
    ShopUI.tabIndex=3
    ShopUI.ManualSelectFirstItem = true

    ShopUI.CreateBuyAndRedeemPage()
    ShopUI.Refresh()
    ShopUI.ShowSellNumNode(false)
    ShopDetailUI.ShowDetailInfo(nil, ShopUI.panelBg, ShopUI.tabIndex, _gt)

    --购买页和赎回页需要根据切换刷新
    --local _Count = ShopUI.ShopItems.buy_back_list ~= nil and ShopUI.ShopItems.buy_back_list.Count or 0
    local buyScroll = _gt.GetUI("buyScroll")
    GUI.LoopScrollRectSetTotalCount(buyScroll, _Count+1)
    GUI.LoopScrollRectSetTotalCount(buyScroll, _Count)

    UILayout.OnTabClick(ShopUI.tabIndex, tabList)
end

--退出界面
function ShopUI.OnExit()
    GUI.DestroyWnd("ShopUI")
end

--创建购买(赎回)界面
function ShopUI.CreateBuyAndRedeemPage()
    local panelBgNode = GUI.GetChild(ShopUI.panelBg, "Node")
    local buyAndRedeemPage = _gt.GetUI(tabList[1][4])
    if buyAndRedeemPage == nil then
        buyAndRedeemPage = GUI.GroupCreate(panelBgNode,tabList[1][4], 0, 0, 0, 0)
        _gt.BindName(buyAndRedeemPage, tabList[1][4])
        local buyScroll = GUI.LoopScrollRectCreate(buyAndRedeemPage,"buyScroll", -180, 10, 660, 540,
                "ShopUI","CreatBuyItemPool","ShopUI","RefreshBuyScroll",0, false, Vector2.New(330, 100),2, UIAroundPivot.Top, UIAnchor.Top)
        GUI.ScrollRectSetChildSpacing(buyScroll, Vector2.New(6, 6))
        _gt.BindName(buyScroll, "buyScroll")
        ShopUI.BuyScroll = buyScroll

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
        GUI.RegisterUIEvent(countEdit, UCE.EndEdit, "ShopUI", "OnBuyCountModify")
        GUI.RegisterUIEvent(countEdit, UCE.PointerClick, "ShopUI", "OnPointerClickBuyCountModify")
        plusBtn:RegisterEvent(UCE.PointerDown)
        plusBtn:RegisterEvent(UCE.PointerUp)
        minusBtn:RegisterEvent(UCE.PointerDown)
        minusBtn:RegisterEvent(UCE.PointerUp)
        GUI.RegisterUIEvent(plusBtn, UCE.PointerDown, "ShopUI", "OnPlusBtnDown")
        GUI.RegisterUIEvent(plusBtn, UCE.PointerUp, "ShopUI", "OnPlusBtnUp")
        GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "ShopUI", "OnPlusBtnClick")
        GUI.RegisterUIEvent(minusBtn, UCE.PointerDown, "ShopUI", "OnMinusBtnDown")
        GUI.RegisterUIEvent(minusBtn, UCE.PointerUp, "ShopUI", "OnMinusBtnUp")
        GUI.RegisterUIEvent(minusBtn, UCE.PointerClick, "ShopUI", "OnMinusBtnClick")

        local spendBg = GUI.ImageCreate(buyAndRedeemPage,"spendBg", "1800900040", 380, 152, false, 252, 35)
        local icon = GUI.ImageCreate(spendBg,"spendIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold], -105, -1, false, 35, 35)
        _gt.BindName(icon, "spendIcon")
        local count = GUI.CreateStatic(spendBg,"spendCount", "0", 10, -1,200,30)
        _gt.BindName(count, "spendCount")
        GUI.StaticSetFontSize(count, UIDefine.FontSizeS)
        GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

        local ownBg = GUI.ImageCreate(buyAndRedeemPage,"ownBg", "1800900040", 380, 202, false, 252, 35)
        local icon = GUI.ImageCreate(ownBg,"ownicon", UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold], -105, -1, false, 35, 35)
        _gt.BindName(icon, "ownicon")
        local count = GUI.CreateStatic(ownBg,"owncount", "0", 10, -1,200,30)
        _gt.BindName(count, "owncount")
        GUI.StaticSetFontSize(count, UIDefine.FontSizeS)
        GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

        local buyBtn = GUI.ButtonCreate(buyAndRedeemPage,"buyBtn", "1800402080", 430, 260, Transition.ColorTint, "购买",160,50,false)
        _gt.BindName(buyBtn, "buyBtn")
        GUI.SetIsOutLine(buyBtn, true)
        GUI.ButtonSetTextFontSize(buyBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(buyBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(buyBtn, UIDefine.OutLine_BrownColor)
        GUI.SetOutLine_Distance(buyBtn, UIDefine.OutLineDistance)
        GUI.RegisterUIEvent(buyBtn, UCE.PointerClick, "ShopUI", "OnBuyBtnClick")

        local redeemBtn = GUI.ButtonCreate(buyAndRedeemPage,"redeemBtn", "1800402080", 430, 260, Transition.ColorTint, "赎回",160,50,false)
        _gt.BindName(redeemBtn, "redeemBtn")
        GUI.SetIsOutLine(redeemBtn, true)
        GUI.ButtonSetTextFontSize(redeemBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(redeemBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(redeemBtn, UIDefine.OutLine_BrownColor)
        GUI.SetOutLine_Distance(redeemBtn, UIDefine.OutLineDistance)
        GUI.RegisterUIEvent(redeemBtn, UCE.PointerClick, "ShopUI", "OnRedeemBtnClick")
    end
end

--购买点击
function ShopUI.OnBuyBtnClick()
    -- test("====OnBuyBtnClick======")
    local countEdit = _gt.GetUI("countEdit")
    local spendCount = _gt.GetUI("spendCount")
    local owncount = _gt.GetUI("owncount")
    if spendCount ~= nil and owncount ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt)
        local cost = num * ShopUI.SelectBuyItemPrice
        local money = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
        if cost > money then
            CL.SendNotify(NOTIFY.ShowBBMsg, "银币不足")
            return
        end
    end
    local countEdit = _gt.GetUI("countEdit")
    if countEdit ~= nil then
        local num = tonumber(GUI.EditGetTextM(countEdit))
        if num == 0 then
            return
        end
        CL.SendNotify(NOTIFY.ShopOpe, 1, ShopUI.SelectBuyItemIndex, num)
    end
end

-- 判断背包有没有满
function ShopUI.CheckBag()
    local id = ShopUI.ShopItems.buy_back_list[ShopUI.SelectBuyItemIndex].id
    local itemDB = DB.GetOnceItemByKey1(id)
    local count = 0
    local bagSize = 0

    if itemDB["ShowType"] == "宝石" then
        count = LD.GetItemCount(item_container_type.item_container_gem_bag)
        bagSize = LD.GetBagCapacity(item_container_type.item_container_gem_bag);
    elseif itemDB["Type"] == 6 and itemDB["Subtype"] == 0 and itemDB["Subtype2"] == 0 then
        count = LD.GetItemCount(item_container_type.item_container_guard_bag)
        bagSize = LD.GetBagCapacity(item_container_type.item_container_guard_bag);
    else
        count = LD.GetItemCount(item_container_type.item_container_bag);
        bagSize = LD.GetBagCapacity(item_container_type.item_container_bag);
    end

    --local countEdit = _gt.GetUI("countEdit")
    --local inputTxt = GUI.EditGetTextM(countEdit)
    -- 背包里这种物品的数量
    --local haveNum = LD.GetItemCountById(id)
    -- 这个物品的堆叠上限
    --local stackMax = tonumber(itemDB["StackMax"])
    -- 这里输入的物品数量
    --local num = tonumber(inputTxt)
    --test((haveNum + num) / stackMax)

    -- 背包满且没有这个物品
    if count >= bagSize then
        return false
    end

    return true

end

--赎回点击
function ShopUI.OnRedeemBtnClick()

    if ShopUI.ShopItems.buy_back_list.Count == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "没有可赎回的物品")
        return
    end

    local countEdit = _gt.GetUI("countEdit")
    local spendCount = _gt.GetUI("spendCount")
    local owncount = _gt.GetUI("owncount")

    if not ShopUI.CheckBag() then
        CL.SendNotify(NOTIFY.ShowBBMsg, "包裹空间不够")
        return
    end

    if spendCount ~= nil and owncount ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt)
        local cost = num * ShopUI.SelectBuyItemPrice
        local money = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
        if cost > money then
            CL.SendNotify(NOTIFY.ShowBBMsg, "银币不足")
            return
        end
    end

    if countEdit ~= nil then
        local num = tonumber(GUI.EditGetTextM(countEdit))
        if num == 0 then
            return
        end
        CL.SendNotify(NOTIFY.ShopOpe, 2, ShopUI.SelectBuyItemIndex, num)
    end
end

function ShopUI.OnPointerClickBuyCountModify()
    local countEdit = _gt.GetUI("countEdit")
    if countEdit ~= nil then
        GUI.EditSetTextM(countEdit, "")
    end
end

function ShopUI.OnBuyCountModify()
    local countEdit = _gt.GetUI("countEdit")
    -- 获取物品上限
    local count = 99
    if ShopUI.Flag == 2 then
        count = ShopUI.ShopItems.buy_back_list[ShopUI.SelectBuyItemIndex].amount
    end
    if count == nil or count == 0 then
        count = 99
    end
    if countEdit ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt) or 1
        if num < 1 then num = 1 end
        if num > count then num = count end
        GUI.EditSetTextM(countEdit, tostring(num))
    end

    --显示总价格
    ShopUI.OnUpdateTotalPrice()
end

function ShopUI.OnPlusBtnDown()
    if ShopUI.PlusBtnTimer ~= nil then
        ShopUI.PlusBtnTimer:Start()
    end
end

function ShopUI.OnPlusBtnUp()
    if ShopUI.PlusBtnTimer ~= nil then
        ShopUI.PlusBtnTimer:Stop()
        ShopUI.PlusBtnTimer:Reset(ShopUI.OnPlusBtnListener,0.18, -1, true)
    end
end

function ShopUI.OnPlusBtnClick()
    ShopUI.OnChangeBuyItemNum(1)
end

function ShopUI.OnPlusBtnListener()
    ShopUI.OnChangeBuyItemNum(1)
end

function ShopUI.OnChangeBuyItemNum(deltaNum)
    -- test("deltaNum="..deltaNum)
    local countEdit = _gt.GetUI("countEdit")
    if countEdit ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt) + deltaNum
        local count = ShopUI.Flag==2 and ShopUI.ShopItems.buy_back_list[ShopUI.SelectBuyItemIndex].amount or 99
        if num < 1 then
            num = 1
            CL.SendNotify(NOTIFY.ShowBBMsg, "已达下限")
        end
        if num > count then 
            num = count 
            CL.SendNotify(NOTIFY.ShowBBMsg, "已达上限")
        end
        GUI.EditSetTextM(countEdit, tostring(num))
    end

    --显示总价格
    ShopUI.OnUpdateTotalPrice()
end

function ShopUI.OnMinusBtnUp()
    if ShopUI.MinusBtnTimer ~= nil then
        ShopUI.MinusBtnTimer:Stop()
        ShopUI.MinusBtnTimer:Reset(ShopUI.OnMinusBtnListener,0.18, -1, true)
    end
end

function ShopUI.OnMinusBtnDown()
    if ShopUI.MinusBtnTimer ~= nil then
        ShopUI.MinusBtnTimer:Start()
    end
end

function ShopUI.OnMinusBtnClick()
    ShopUI.OnChangeBuyItemNum(-1)
end

function ShopUI.OnMinusBtnListener()
    ShopUI.OnChangeBuyItemNum(-1)
end

-- 根据传入的分类选中物品
function ShopUI.OnSelectAllBtnClick(condition)
    --ShopUI.SellSelectItemLst = {}
    if ShopUI.SellItems ~= nil then
        local Count = ShopUI.SellItems.Count
        for i = 0, Count-1 do
            local itemGUID = tostring(ShopUI.SellItems[i].guid)
            local config = DB.GetOnceItemByKey1(ShopUI.SellItems[i].id)
            local setFlag = false

            if SelectQuality[config.Grade] then
                if config.Type == ruleType[condition].Type and config ~= nil then
                    setFlag = true

                    -- 宝石的特殊情况单独判断下
                    if condition == "材料" and config.Subtype == 9 then
                        setFlag = false
                    end

                    if condition == "宝石" and config.Subtype ~= 9 then
                        setFlag = false
                    end
                end

                -- 藏宝图归属到消耗品下
                if config.Type == 4 and condition == "消耗品" then
                    setFlag = true
                end
            end

            if setFlag then
                ShopUI.SellSelectItemLst[itemGUID] = {count=ShopUI.SellItems[i].amount, total=ShopUI.SellItems[i].amount, price=config.SaleGoldBind, guid=itemGUID}
            end
        end
        ShopUI.PressedItemGuid=nil
        --local sellScroll =  _gt.GetUI("sellScroll")
        --local curCount = GUI.LoopScrollRectGetChildInPoolCount(sellScroll)
        -- 选中第一个
        local curCount = 1
        if curCount and curCount > 0  then
            curCount = curCount - 1 
            local name = "ItemIconBg"..curCount
            test("name="..name)
            local btn = _gt.GetUI(name)
            if btn then
                ShopUI.PressedItemGuid=GUI.GetGuid(btn)
            end
        end
       
        ShopUI.SelectSellItemIndex = 0
        ShopUI.OnUpdateSellList()
        ShopUI.ShowSellNumNode(true)
        ShopUI.SetSellNum(ShopUI.SellItems[0].amount)
    end

    ShopUI.OnExitSaleScreeningGroup()
end

function ShopUI.OnUnSelectAllBtnClick()
    ShopUI.SellSelectItemLst = {}
    if ShopUI.SellItems ~= nil then
        ShopUI.OnUpdateSellList()
    end
    ShopUI.PressedItemGuid = nil
    --隐藏详细面板区
    ShopDetailUI.ShowDetailInfo(nil, ShopUI.panelBg, ShopUI.tabIndex, _gt)
    ShopUI.ShowSellNumNode(false)
    ShopUI.SelectSellItemIndex = -1
end

function ShopUI.OnUpdateSellList()
    if ShopUI.SellItems ~= nil then
        local Count = ShopUI.SellItems.Count
        --包裹更新了，刷新数据
        local sellScroll = _gt.GetUI("sellScroll")
        local sellCount = Count<ONEPAGE_COUNT and ONEPAGE_COUNT or Count
        --GUI.LoopScrollRectSetTotalCount(sellScroll, sellCount+1)
        --GUI.LoopScrollRectSetTotalCount(sellScroll, sellCount)
        ShopUI.cre_and_ref_sell_item_scroll(sellCount,ShopUI.sell_scroll_num_max or 0)

        --显示第一件道具属性
        if ShopUI.SellItems ~= nil and ShopUI.SellItems.Count>0 then
            local itemData = ShopUI.SellItems[0]
            ShopDetailUI.ShowDetailInfo(ShopUI.PackRealItemInfos(ShopUI.SellItems[0].id, ShopUI.SellItems[0].dyn_attrs, ShopUI.SellItems[0].isbound==1 and true or false, ShopUI.SellItems[0].amount,true,itemData), ShopUI.panelBg, ShopUI.tabIndex, _gt)
        end
    end
    ShopUI.OnUpdateSellTotalPrice()
    ShopUI.OnSelectAllBtnState()
end

function ShopUI.OnSellYes()
    local sellinfo = ""
    local first = true
    for i, v in pairs(ShopUI.SellSelectItemLst) do
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
    ShopUI.SellSelectItemLst = {}
    ShopUI.OnSelectAllBtnState()
end

function ShopUI.OnSellBtnClick()
    local totalCount = 0
    if ShopUI.SellSelectItemLst then
        for i, v in pairs(ShopUI.SellSelectItemLst) do
            totalCount = totalCount + 1
        end
    end
    if not ShopUI.SellSelectItemLst or totalCount<=0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "未选中出售物品")
        return
    end
    GlobalUtils.ShowBoxMsg(
            "提示",
            "确定出售 "..tostring(totalCount).." 件道具？",
            "ShopUI",
            "确定",
            "OnSellYes",
            "取消"
    )
end

--创建出售界面
function ShopUI.CreateSellPage()
    local panelBgNode = GUI.GetChild(ShopUI.panelBg, "Node")
    local sellPage = _gt.GetUI(tabList[2][4])
    if sellPage == nil then
        sellPage = GUI.GroupCreate(panelBgNode,tabList[2][4], 0, 0, 0, 0)
        _gt.BindName(sellPage, tabList[2][4])
        --local sellScroll = GUI.LoopScrollRectCreate(sellPage,"sellScroll", -180, 10, 660, 530,
        --        "ShopUI","CreatSellItemPool","ShopUI","RefreshSellScroll", 0, false, Vector2.New(85, 85), 7,UIAroundPivot.Top, UIAnchor.Top)
        local sellScroll = GUI.ScrollRectCreate(sellPage, 'sellScroll', -180, 10,
                660, 530, 0, false,
                Vector2.New(85, 85), UIAroundPivot.Top, UIAnchor.Top,7)
        GUI.ScrollRectSetChildSpacing(sellScroll, Vector2.New(10, 5))
        _gt.BindName(sellScroll, "sellScroll")

        local infoBg = GUI.ImageCreate(sellPage,"infoBg", "1800400010", 345, -50, false, 350, 440)

        local text1 = GUI.CreateStatic(sellPage,"text1", "出售总价", 225, 200, 100, 30)
        UILayout.StaticSetFontSizeColorAlignment(text1, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    	UILayout.SetSameAnchorAndPivot(text1, UILayout.Center)

        local totalBg = GUI.ImageCreate(sellPage,"totalBg", "1800900040", 400, 202, false, 220, 35)
        local icon = GUI.ImageCreate(totalBg,"icon", UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold], -89, -1, false, 35, 35)
        local count = GUI.CreateStatic(totalBg,"totalCount", "0", 12, -1,180,30)
        _gt.BindName(count, "totalCount")
        GUI.StaticSetFontSize(count, UIDefine.FontSizeS)
        GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

        local sellBtn = GUI.ButtonCreate(sellPage,"sellBtn", "1800402080", 430, 260, Transition.ColorTint, "确定出售",160,50,false)
        GUI.SetIsOutLine(sellBtn, true)
        GUI.ButtonSetTextFontSize(sellBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(sellBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(sellBtn, UIDefine.OutLine_BrownColor)
        GUI.SetOutLine_Distance(sellBtn, UIDefine.OutLineDistance)
        GUI.RegisterUIEvent(sellBtn, UCE.PointerClick, "ShopUI", "OnSellBtnClick")

        local selectAllBtn = GUI.ButtonCreate(sellPage,"selectAllBtn", "1800402080", 255, 260, Transition.ColorTint, "出售筛选",160,50,false)
        _gt.BindName(selectAllBtn, "selectAllBtn")
        GUI.SetIsOutLine(selectAllBtn, true)
        GUI.ButtonSetTextFontSize(selectAllBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(selectAllBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(selectAllBtn, UIDefine.OutLine_BrownColor)
        GUI.SetOutLine_Distance(selectAllBtn, UIDefine.OutLineDistance)
        GUI.RegisterUIEvent(selectAllBtn, UCE.PointerClick, "ShopUI", "SaleScreening")

        local unSelectAllBtn = GUI.ButtonCreate(sellPage,"unSelectAllBtn", "1800402080", 255, 260, Transition.ColorTint, "取消选中",160,50,false)
        _gt.BindName(unSelectAllBtn, "unSelectAllBtn")
        GUI.SetIsOutLine(unSelectAllBtn, true)
        GUI.ButtonSetTextFontSize(unSelectAllBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(unSelectAllBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(unSelectAllBtn, UIDefine.OutLine_BrownColor)
        GUI.SetOutLine_Distance(unSelectAllBtn, UIDefine.OutLineDistance)
        GUI.RegisterUIEvent(unSelectAllBtn, UCE.PointerClick, "ShopUI", "OnUnSelectAllBtnClick")
        GUI.SetVisible(unSelectAllBtn, false)
    end
end

-- 打开出售筛选页面
function ShopUI.SaleScreening()

    local wnd = GUI.GetWnd("ShopUI")
    local SaleScreeningGroup = GUI.GetChild(wnd, "SaleScreeningGroup", false)

    if not SaleScreeningGroup then
        local width = 600
        local height = 400
        local SaleScreeningGroup = GUI.GroupCreate(wnd, "SaleScreeningGroup", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
        _gt.BindName(SaleScreeningGroup, "SaleScreeningGroup")
        local SaleScreeningPanelBg = UILayout.CreateFrame_WndStyle2(SaleScreeningGroup,"出售筛选",  width, height, "ShopUI", "OnExitSaleScreeningGroup")
        ShopUI.CreateSaleScreeningPanel(SaleScreeningPanelBg)
    else
        GUI.SetVisible(SaleScreeningGroup, true)
    end
end

-- 创建出售筛选页面
function ShopUI.CreateSaleScreeningPanel(SaleScreeningPanelBg)
    local topText = GUI.CreateStatic(SaleScreeningPanelBg,"topText", "请选择要出售的道具类型", 0, 85, 300, 30)
    StaticSetFontSizeColorAlignment(topText, UIDefine.FontSizeS, UIDefine.RedColor, TextAnchor.UpperCenter)
    GUI.SetAnchor(topText, UIAnchor.Top)

    local screeningBg = GUI.ImageCreate(SaleScreeningPanelBg, "screeningBg", "1800400200", 0, -35, false, 560, 130)
    GUI.SetAnchor(screeningBg, UIAnchor.Center)
    GUI.SetPivot(screeningBg, UIAroundPivot.Center)

    local screeningList = GUI.LoopScrollRectCreate(
            screeningBg,
            "screeningList",
            0,
            7,
            550,
            130,
            "ShopUI",
            "CreateScreeningList",
            "ShopUI",
            "RefreshScreeningList",
            0,
            true,
            Vector2.New(90,90),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top,
            false
    )
    _gt.BindName(screeningList,"screeningList")
    GUI.SetAnchor(screeningList,UIAnchor.Top)
    GUI.SetPivot(screeningList,UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(screeningList, Vector2.New(15, 0))

    GUI.LoopScrollRectSetTotalCount(screeningList, #SelectList)
    GUI.LoopScrollRectRefreshCells(screeningList)

    local midText = GUI.CreateStatic(SaleScreeningPanelBg, "midText", "请选择要出售的道具品质", 0, 260, 300, 30)
    StaticSetFontSizeColorAlignment(midText, UIDefine.FontSizeS, UIDefine.RedColor, TextAnchor.UpperCenter)
    GUI.SetAnchor(midText, UIAnchor.Top)

    for i = 1, #QualityList do

        -- 第一个默认选中
        local ff = false
        if i == 1 then
            ff = true
        end

        local qualityIcon = GUI.CheckBoxCreate(SaleScreeningPanelBg, "qualityIcon"..i, "1800607150","1800607151", (i-1) * 110 + 60, -100, Transition.ColorTint, ff, 38, 38)
        GUI.SetAnchor(qualityIcon, UIAnchor.BottomLeft)
        GUI.SetPivot(qualityIcon, UIAroundPivot.Center)
        _gt.BindName(qualityIcon, "qualityIcon"..i)

        local quality = GUI.CreateStatic(qualityIcon, "quality"..i, QualityList[i].text, 45, 0, 50, 30)
        StaticSetFontSizeColorAlignment(quality, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.UpperCenter)
        if ff then
            StaticSetFontSizeColorAlignment(quality, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.UpperCenter)
        end
        GUI.SetIsOutLine(quality,true)
        GUI.SetOutLine_Color(quality, QualityList[i].color)
        GUI.SetOutLine_Distance(quality, 2)
        GUI.SetAnchor(quality, UIAnchor.Center)
        GUI.SetPivot(quality, UIAroundPivot.Center)
    end

    local confirm = GUI.ButtonCreate(SaleScreeningPanelBg, "confirm", "1800102090", 0, -45, Transition.ColorTint, "<color=#ffffff><size=26>确认选择</size></color>", 160, 50, false);
    UILayout.SetAnchorAndPivot(confirm, UIAnchor.Bottom, UIAroundPivot.Center)
    GUI.ButtonSetOutLineArgs(confirm, true, Color.New(175/255, 96/255, 19/255, 255/255), 1)
    GUI.SetIsOutLine(confirm,true);
    GUI.SetOutLine_Distance(confirm,1);
    GUI.RegisterUIEvent(confirm, UCE.PointerClick, "ShopUI", "OnSelectBtnClick")
    _gt.BindName(confirm, "confirm")

end

function ShopUI.CreateScreeningList()
    local screeningList = _gt.GetUI("screeningList")
    if screeningList == nil then
        return
    end
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(screeningList)

    local icon = GUI.ItemCtrlCreate(screeningList,"icon"..curCount, QualityRes[1],8,10,90,90,false,"system",false)
    _gt.BindName(icon, "icon"..curCount)
    GUI.ItemCtrlSetElementRect(icon, eItemIconElement.Icon, 0, -1, 76, 76)
    GUI.RegisterUIEvent(icon, UCE.PointerClick, "ShopUI", "OnChoiceTypeClick")

    -- 图片右下角勾勾
    local choiceIcon = GUI.ImageCreate(icon,"choiceIcon", "1800608400", -10, -10,  false, 50, 50, false)
    GUI.SetAnchor(choiceIcon, UIAnchor.BottomRight)
    GUI.SetPivot(choiceIcon, UIAroundPivot.Center)

    -- flag 0 代表未选中， 1代表选中
    if curCount == 0 then
        GUI.SetVisible(choiceIcon, true)
        GUI.SetData(icon, "flag", 1)
    else
        GUI.SetVisible(choiceIcon, false)
        GUI.SetData(icon, "flag", 0)
    end

    -- 图片下方文字
    local text = GUI.CreateStatic(icon, "text", "装备", 0, 10, 60, 25)
    StaticSetFontSizeColorAlignment(text, UIDefine.FontSizeS, UIDefine.BrownColor, TextAnchor.LowerCenter)
    GUI.SetAnchor(text, UIAnchor.Bottom)
    GUI.SetPivot(text, UIAroundPivot.Center)

    return icon
end

function ShopUI.RefreshScreeningList(parameter)
    parameter = string.split(parameter , "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1

    local icon = GUI.GetByGuid(guid)
    if not icon then
        return
    end

    ItemIcon.SetEmpty(icon)

    local text = GUI.GetChild(icon, "text", false)

    GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Icon,SelectList[index].icon)
    GUI.StaticSetText(text, SelectList[index].text)
end

function ShopUI.OnChoiceTypeClick(guid)
    local icon = GUI.GetByGuid(guid)
    local flag = GUI.GetData(icon, "flag")
    local choiceIcon = GUI.GetChild(icon, "choiceIcon", false)

    if flag == "0" then
        GUI.SetData(icon, "flag", 1)
        GUI.SetVisible(choiceIcon, true)
    else
        GUI.SetData(icon, "flag", 0)
        GUI.SetVisible(choiceIcon, false)
    end
end

-- 筛选数据处理
function ShopUI.OnSelectBtnClick()
    local screeningList = _gt.GetUI("screeningList")
    if screeningList == nil then
        return
    end

    -- 先存选中的品质，OnSelectAllBtnClick方法用
    SelectQuality = {}
    for i = 1, #QualityList + 1 do
        local qualityIcon = _gt.GetUI("qualityIcon"..i)
        local flag2 = GUI.CheckBoxGetCheck(qualityIcon)
        if flag2 then
            SelectQuality[i] = true
        end
    end

    -- 逐个选中
    for i = 1, #SelectList do
        local icon = _gt.GetUI("icon"..(i-1))
        local flag = GUI.GetData(icon, "flag")
        if flag == "1" then
            ShopUI.OnSelectAllBtnClick(SelectList[i].text)
        end
    end

end

-- 退出出售筛选页面
function ShopUI.OnExitSaleScreeningGroup()
    local SaleScreeningGroup = _gt.GetUI("SaleScreeningGroup")
    GUI.SetVisible(SaleScreeningGroup, false)
end

--创建出售道具列表
function ShopUI.CreatBuyItemPool()
    local buyScroll = _gt.GetUI("buyScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(buyScroll)
    local item = GUI.CheckBoxExCreate(buyScroll,"item" .. curCount, "1800400360", "1800400361", 0, 0, false, 320, 100)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "ShopUI", "OnBuyItemClick")

    --物品图标背景
    local ItemIconBg = GUI.ImageCreate( item,"ItemIconBg", "1800400050", -110, 1, false, 80, 80)
    local ItemIconBgPic = GUI.ImageCreate( ItemIconBg,"ItemIconBgPic", "1800400060", 0, 0, false, 80, 80)
    local ItemIcon = GUI.ImageCreate( ItemIconBg,"ItemIcon", "1900100100", 0, 0, false, 64, 64)

    --物品名称
    local ItemName = GUI.CreateStatic( item,"ItemName", "道具名称", 105, -20, 200, 35)
    GUI.StaticSetFontSize(ItemName, 22)
    GUI.SetAnchor(ItemName, UIAnchor.Left)
    GUI.StaticSetAlignment(ItemName, TextAnchor.MiddleLeft)
    GUI.SetPivot(ItemName, UIAroundPivot.Left)
    GUI.SetColor(ItemName, UIDefine.BrownColor)

    --赎回数量
    local BuyBackNum = GUI.CreateStatic( ItemIconBg,"BuyBackNum", "9", -7, 7, 100, 50)
    GUI.StaticSetFontSize(BuyBackNum, 20)
    UILayout.SetSameAnchorAndPivot(BuyBackNum, UILayout.BottomRight)
    GUI.StaticSetAlignment(BuyBackNum, TextAnchor.MiddleRight)
    GUI.SetIsOutLine(BuyBackNum, true)
    GUI.SetOutLine_Color(BuyBackNum, UIDefine.BlackColor)
    GUI.SetOutLine_Distance(BuyBackNum, 1)
    GUI.SetColor(BuyBackNum, UIDefine.WhiteColor)
    GUI.SetVisible(BuyBackNum, false)

    --货币背景、图标、数值
    local CoinBg = GUI.ImageCreate( item,"CoinBg", "1800900040", 105, 20, false, 200, 35)
    UILayout.SetSameAnchorAndPivot(CoinBg, UILayout.Left)
    local CoinIcon = GUI.ImageCreate( CoinBg,"CoinIcon", "1800408250", 0, -1, false, 36, 36)
    UILayout.SetSameAnchorAndPivot(CoinIcon, UILayout.Left);
    local CoinCount = GUI.CreateStatic( CoinBg,"CoinCount", "", 5, -1, 160, 30)
    GUI.StaticSetFontSize(CoinCount, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(CoinCount, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(CoinCount, UILayout.Center);

    --绑定标记
    local bindFlag = GUI.ImageCreate( ItemIconBg,"bindFlag", "1800707120", 22, 22)
    GUI.SetAnchor(bindFlag, UIAnchor.TopLeft)

    return item
end

--刷新出售道具列表
function ShopUI.RefreshBuyScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])

    --执行刷新：如果之前有默认项，则在列表中选中它
    ShopUI.UpdateBuyItemInfo(guid, index)
    --没有默认项，则选中第一项
    if ShopUI.ShopItems.def_item_id == nil or ShopUI.ShopItems.def_item_id == 0 then
        if index==0 and ShopUI.ManualSelectFirstItem then
            ShopUI.ManualSelectFirstItem = false
            local _Count = 0
            if ShopUI.tabIndex == 1 then
                _Count = ShopUI.ShopItems.shop_item_list ~= nil and ShopUI.ShopItems.shop_item_list.Count or 0
            elseif ShopUI.tabIndex == 3 then
                _Count = ShopUI.ShopItems.buy_back_list ~= nil and ShopUI.ShopItems.buy_back_list.Count or 0
            end
            if _Count > 0 then
                ShopUI.OnBuyItemClick(guid)
            end
        end
    elseif ShopUI.ManualSelectFirstItem then
        if ShopUI.tabIndex == 1 then
            if ShopUI.ShopItems.shop_item_list and ShopUI.ShopItems.def_item_id == ShopUI.ShopItems.shop_item_list[index].id then
                ShopUI.OnBuyItemClick(guid)
                ShopUI.ManualSelectFirstItem = false
            end
        end
    end
end

function ShopUI.ShowDefaultSelectItemDetail(guid, itemID)
    ShopUI.SelectBuyItemIndex = 0
    if ShopUI.tabIndex == 1 and ShopUI.ShopItems.shop_item_list ~= nil then
        local count = ShopUI.ShopItems.shop_item_list.Count
        for i = 0, count-1 do
            if ShopUI.ShopItems.shop_item_list[i].id == itemID then
                ShopUI.SelectBuyItemIndex = i
                break
            end
        end
    end
    --在刷新第一个道具的时候计算了默认选中项，如果刚好是本项目则选中它，否在在后续的refreshItem中，会自动选中ShopUI.SelectBuyItemIndex项目
    local targetItem = ShopUI.SelectBuyItemIndex==0 and guid or nil
    ShopUI.OnBuyItemClick(targetItem, ShopUI.SelectBuyItemIndex)
end

function ShopUI.UnCheckPreBuyItem()
    if ShopUI.SelectBuyItemGUID ~= "0" then
        local item = GUI.GetByGuid(ShopUI.SelectBuyItemGUID)
        if item ~= nil then
            GUI.CheckBoxExSetCheck(item, false)
        end
    end
end

function ShopUI.CheckBuyItem()
    local item = GUI.GetByGuid(ShopUI.SelectBuyItemGUID)
    if item ~= nil then
        GUI.CheckBoxExSetCheck(item, true)
    end
end

function ShopUI.GetItemInfo(index)
    local itemInfo = {id=0, grade=2, icon="1900100100", name="道具护腕", num=0, coinType=RoleAttr.RoleAttrGold, coinCount=7800, bind=true  }
    if ShopUI.tabIndex == 1 then
        if ShopUI.ShopItems.shop_item_list ~= nil and index < ShopUI.ShopItems.shop_item_list.Count then
            itemInfo.id = ShopUI.ShopItems.shop_item_list[index].id
            itemInfo.coinCount = ShopUI.ShopItems.shop_item_list[index].price
            itemInfo.coinType = CL.ConvertAttr(ShopUI.ShopItems.shop_item_list[index].price_type)
            itemInfo.bind = ShopUI.ShopItems.shop_item_list[index].bind==1 and true or false
            local config = DB.GetOnceItemByKey1(itemInfo.id)
            if config ~= nil then
                itemInfo.name = config.Name
                itemInfo.icon = config.Icon
                itemInfo.grade = config.Grade
                itemInfo.num = 0 --数量默认无限制
            end
        end
    elseif ShopUI.tabIndex == 3 then
        if ShopUI.ShopItems.buy_back_list ~= nil and index < ShopUI.ShopItems.buy_back_list.Count then
            itemInfo.id = ShopUI.ShopItems.buy_back_list[index].id
            itemInfo.num = ShopUI.ShopItems.buy_back_list[index].amount
            itemInfo.coinType = RoleAttr.RoleAttrBindGold --赎回固定为绑定金
            itemInfo.bind = ShopUI.ShopItems.buy_back_list[index].isbound==1 and true or false
            local config = DB.GetOnceItemByKey1(itemInfo.id)
            if config ~= nil then
                itemInfo.name = config.Name
                itemInfo.icon = config.Icon
                itemInfo.grade = config.Grade
                itemInfo.coinCount = config.SaleGoldBind
            end
        end
    end

    return itemInfo
end

function ShopUI.UpdateBuyItemInfo(guid, index)
    local itemInfo = ShopUI.GetItemInfo(index)
    local item = GUI.GetByGuid(guid)
    if item ~= nil then
        GUI.SetData(item, "index", index)
        GUI.SetData(item, "price", itemInfo.coinCount)
        GUI.CheckBoxExSetCheck(item, index == ShopUI.SelectBuyItemIndex)
        if index == ShopUI.SelectBuyItemIndex then
            ShopUI.SelectBuyItemGUID = guid
        end
    end
    local ItemIconBg = GUI.GetChild(item, "ItemIconBg")
    if ItemIconBg ~= nil then
        GUI.ImageSetImageID(ItemIconBg,UIDefine.ItemIconBg[itemInfo.grade])
    end
    local ItemIcon = GUI.GetChildByPath(item, "ItemIconBg/ItemIcon")
    if ItemIcon ~= nil then
        GUI.ImageSetImageID(ItemIcon, itemInfo.icon)
    end
    local ItemName = GUI.GetChild(item, "ItemName")
    if ItemName ~= nil then
        GUI.StaticSetText(ItemName, itemInfo.name)
    end
    local BuyBackNum = GUI.GetChildByPath(item, "ItemIconBg/BuyBackNum")
    if BuyBackNum ~= nil then
        GUI.StaticSetText(BuyBackNum, itemInfo.num)
        GUI.SetVisible(BuyBackNum, ShopUI.tabIndex == 3)
    end
    local CoinIcon = GUI.GetChildByPath(item, "CoinBg/CoinIcon")
    if CoinIcon ~= nil then
        GUI.ImageSetImageID(CoinIcon, UIDefine.AttrIcon[itemInfo.coinType])
    end
    local CoinCount = GUI.GetChildByPath(item, "CoinBg/CoinCount")
    if CoinCount ~= nil then
        GUI.StaticSetText(CoinCount, tostring(itemInfo.coinCount))
    end
    local bindFlag =GUI.GetChildByPath(item, "ItemIconBg/bindFlag")
    if bindFlag ~= nil then
        GUI.SetVisible(bindFlag, itemInfo.bind)
    end
end

-- 创建并刷新出售道具列表
ShopUI.cre_and_ref_sell_item_scroll = function(count, cur_max)
    -- 记录创建过的最大的值
    if count > cur_max then
        ShopUI.sell_scroll_num_max = count
    end
    local for_count = math.max(count, cur_max)
    local sellScroll = _gt.GetUI("sellScroll")
    -- 创建部分 i从零开始所以要减一
    for i = 0, for_count -1  do
        local curCount = i
        local ItemIconBg = _gt.GetUI('ItemIconBg' .. curCount)
        if ItemIconBg == nil and i <= count then

            ItemIconBg = ItemIcon.Create(sellScroll,"itemIcon" .. curCount,0,0)
            _gt.BindName(ItemIconBg,"ItemIconBg"..curCount)
            ItemIconBg:RegisterEvent(UCE.PointerUp)
            ItemIconBg:RegisterEvent(UCE.PointerDown)
            GUI.RegisterUIEvent(ItemIconBg, UCE.PointerClick, "ShopUI", "OnSellItemClick")
            GUI.RegisterUIEvent(ItemIconBg, UCE.PointerUp, "ShopUI", "OnSellItemPointerUp")
            GUI.RegisterUIEvent(ItemIconBg, UCE.PointerDown, "ShopUI", "OnSellItemPointerDown")

            local Select = GUI.ImageCreate( ItemIconBg,"Select", "1800600160", 0, -2, false, 85, 85)
            GUI.SetVisible(Select, false)

            local decreaseBtn = GUI.ButtonCreate( ItemIconBg,"decreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
            decreaseBtn:RegisterEvent(UCE.PointerUp)
            decreaseBtn:RegisterEvent(UCE.PointerDown)
            GUI.RegisterUIEvent(decreaseBtn, UCE.PointerClick, "ShopUI", "OnClickMinusBtn")
            GUI.RegisterUIEvent(decreaseBtn, UCE.PointerUp, "ShopUI", "OnMinusBtnPointerUp")
            GUI.RegisterUIEvent(decreaseBtn, UCE.PointerDown, "ShopUI", "OnMinusBtnPointerDown")
            GUI.SetVisible(decreaseBtn, false)
            GUI.SetData(decreaseBtn, "itemGUI", GUI.GetGuid(ItemIconBg))
            UILayout.SetSameAnchorAndPivot(decreaseBtn, UILayout.TopRight)

            local Count = GUI.CreateStatic( ItemIconBg,"Count", "99", -10, -8, 80, 25)
            GUI.StaticSetFontSize(Count, UIDefine.FontSizeSS)
            GUI.StaticSetAlignment(Count, TextAnchor.LowerRight)
            GUI.SetIsOutLine(Count, true)
            GUI.SetOutLine_Color(Count, Color.New(0/255,0/255,0/255,255/255))
            GUI.SetOutLine_Distance(Count, 1)
            GUI.SetColor(Count, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
            UILayout.SetSameAnchorAndPivot(Count, UILayout.BottomRight)

        end
    end
    -- 刷新部分
    for i = 0, for_count - 1 do
        local curCount = i
        local ItemIconBg = _gt.GetUI('ItemIconBg' .. curCount)
        if ItemIconBg ~= nil then
            -- 隐藏多的物品格
            if i > count - 1 then
                GUI.SetVisible(ItemIconBg, false)
            else
                GUI.SetVisible(ItemIconBg, true)
            end
            local guid = GUI.GetGuid(ItemIconBg)
            local index = i
            local datas = { img = "0", count = 0, price = 0, grade = 1, bind = false, guid = "0", type = 0, subType = 0, naijiudu = nil, naijiuduMax = nil}
            if ShopUI.SellItems ~= nil and index >= 0 and index < ShopUI.SellItems.Count then
                datas.count = ShopUI.SellItems[index].amount
                local config = DB.GetOnceItemByKey1(ShopUI.SellItems[index].id)
                datas.bind = ShopUI.SellItems[index].isbound == 1 and true or false
                datas.guid = tostring(ShopUI.SellItems[index].guid)
                if config ~= nil then
                    datas.img = config.Icon
                    datas.price = config.SaleGoldBind
                    datas.grade = config.Grade
                    datas.type = config.Type
                    datas.subType = config.Subtype
                    if config.Type == 1 then
                        if config.Subtype == 7 then
                            datas.naijiudu = ShopUI.SellItems[index]:GetIntCustomAttr("EquipDurableVal")
                            datas.naijiuduMax = ShopUI.SellItems[index]:GetIntCustomAttr("EquipDurableMax")
                        else
                            datas.naijiudu = ShopUI.SellItems[index]:GetIntCustomAttr("DurableNow")
                            datas.naijiuduMax = ShopUI.SellItems[index]:GetIntCustomAttr("DurableMax")
                        end
                    end
                end
            else
                --return
            end

            local item = GUI.GetByGuid(guid)
            if item ~= nil then
                GUI.SetData(item, "index", index)
                GUI.SetData(item, "total", datas.count)
                GUI.SetData(item, "price", datas.price)
                GUI.SetData(item, "guid", datas.guid)
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[datas.grade])
            end

            if ShopUI.SelectSellItemIndex == index then
                ShopUI.SelectSellItemCountUI = item
            end

            if datas.img ~= "0" then
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, datas.img);
                local iconSizeX = 60
                local iconSizeY = 60
                if datas.type == 6 or datas.type == 7 then
                    iconSizeX = 72
                    iconSizeY = 74
                end
                GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1, iconSizeX, iconSizeY);
            else
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, nil);
            end

            local itemIcon = item

            --IconMask和RightBottomSp
            if datas.naijiuduMax and datas.naijiuduMax == 0 then
                --无限耐久
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
            else
                if datas.naijiudu then
                    if datas.naijiudu <= 0 then
                        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, 1801300230);
                        GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.IconMask, 0, 0, 80, 81);
                        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, 1800408430);
                        GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.RightBottomSp, 0, 0, 22, 23);
                    else
                        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
                        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
                    end
                else
                    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
                    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
                end
            end

            if datas.bind == true then
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.LeftTopSp, 1800707120);
                GUI.ItemCtrlSetElementRect(item, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
            else
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.LeftTopSp, nil);
            end

            local strGUID = tostring(datas.guid)
            if ShopUI.SellSelectItemLst[strGUID] ~= nil then
                ShopUI.OnCheckItemForUI(guid, true, tostring(ShopUI.SellSelectItemLst[strGUID].count) .. "/" .. ShopUI.SellSelectItemLst[strGUID].total)
            else
                local Select = GUI.GetChild(item, "Select")
                if Select ~= nil then
                    GUI.SetVisible(Select, false)
                end
                local decreaseBtn = GUI.GetChild(item, "decreaseBtn")
                if decreaseBtn ~= nil then
                    GUI.SetVisible(decreaseBtn, false)
                end
                local Count = GUI.GetChild(item, "Count")
                if Count ~= nil then
                    GUI.StaticSetText(Count, tostring(datas.count))
                    GUI.SetVisible(Count, datas.count > 0)
                end
            end
            local decreaseBtn = GUI.GetChild(item, "decreaseBtn")
            if decreaseBtn ~= nil then
                GUI.SetData(decreaseBtn, "itemGUID", guid)
            end
        end
    end
end

--创建出售道具列表
function ShopUI.CreatSellItemPool()
    local sellScroll =  _gt.GetUI("sellScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(sellScroll)
    local ItemIconBg = ItemIcon.Create(sellScroll,"itemIcon" .. curCount,0,0)
    _gt.BindName(ItemIconBg,"ItemIconBg"..curCount)
    ItemIconBg:RegisterEvent(UCE.PointerUp)
    ItemIconBg:RegisterEvent(UCE.PointerDown)
    GUI.RegisterUIEvent(ItemIconBg, UCE.PointerClick, "ShopUI", "OnSellItemClick")
    GUI.RegisterUIEvent(ItemIconBg, UCE.PointerUp, "ShopUI", "OnSellItemPointerUp")
    GUI.RegisterUIEvent(ItemIconBg, UCE.PointerDown, "ShopUI", "OnSellItemPointerDown")

    local Select = GUI.ImageCreate( ItemIconBg,"Select", "1800600160", 0, -2, false, 85, 85)
    GUI.SetVisible(Select, false)

    local decreaseBtn = GUI.ButtonCreate( ItemIconBg,"decreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
    decreaseBtn:RegisterEvent(UCE.PointerUp)
    decreaseBtn:RegisterEvent(UCE.PointerDown)
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerClick, "ShopUI", "OnClickMinusBtn")
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerUp, "ShopUI", "OnMinusBtnPointerUp")
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerDown, "ShopUI", "OnMinusBtnPointerDown")
    GUI.SetVisible(decreaseBtn, false)
    GUI.SetData(decreaseBtn, "itemGUI", GUI.GetGuid(ItemIconBg))
    UILayout.SetSameAnchorAndPivot(decreaseBtn, UILayout.TopRight)

    local Count = GUI.CreateStatic( ItemIconBg,"Count", "99", -10, -8, 80, 25)
    GUI.StaticSetFontSize(Count, UIDefine.FontSizeSS)
    GUI.StaticSetAlignment(Count, TextAnchor.LowerRight)
    GUI.SetIsOutLine(Count, true)
    GUI.SetOutLine_Color(Count, Color.New(0/255,0/255,0/255,255/255))
    GUI.SetOutLine_Distance(Count, 1)
    GUI.SetColor(Count, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
    UILayout.SetSameAnchorAndPivot(Count, UILayout.BottomRight)
    return ItemIconBg
end

function ShopUI.UpdateSellItemInfo(guid, index)
    local datas = {img="0", count=0, price=0, grade=1, bind=false, guid="0", type=0,subType=0,naijiudu=nil,naijiuduMax=nil}
    if ShopUI.SellItems ~= nil and index>=0 and index<ShopUI.SellItems.Count then
        datas.count = ShopUI.SellItems[index].amount
        local config = DB.GetOnceItemByKey1(ShopUI.SellItems[index].id)
        datas.bind = ShopUI.SellItems[index].isbound==1 and true or false
        datas.guid = tostring(ShopUI.SellItems[index].guid)
        if config ~= nil then
            datas.img = config.Icon
            datas.price = config.SaleGoldBind
            datas.grade = config.Grade
            datas.type = config.Type
            datas.subType = config.Subtype
            if config.Type == 1 then
                if config.Subtype == 7 then
                    datas.naijiudu = ShopUI.SellItems[index]:GetIntCustomAttr("EquipDurableVal")
                    datas.naijiuduMax = ShopUI.SellItems[index]:GetIntCustomAttr("EquipDurableMax")
                else
                    datas.naijiudu = ShopUI.SellItems[index]:GetIntCustomAttr("DurableNow")
                    datas.naijiuduMax = ShopUI.SellItems[index]:GetIntCustomAttr("DurableMax")
                end
            end
        end
    else
        --return
    end

    local item =  GUI.GetByGuid(guid)
    if item ~= nil then
        GUI.SetData(item, "index", index)
        GUI.SetData(item, "total", datas.count)
        GUI.SetData(item, "price", datas.price)
        GUI.SetData(item, "guid", datas.guid)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border, UIDefine.ItemIconBg[datas.grade])
    end

    if ShopUI.SelectSellItemIndex == index then
        ShopUI.SelectSellItemCountUI = item
        -- ShopDetailUI.numNodify = ShopUI.UpdateSelectItemNum
    end

    if datas.img ~= "0" then
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon,datas.img);
        local iconSizeX = 60
        local iconSizeY = 60
        if datas.type == 6 or datas.type == 7 then
            iconSizeX = 72
            iconSizeY = 74
        end
        GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1, iconSizeX, iconSizeY);
    else
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon,nil);
    end

    local itemIcon = item
    
    --IconMask和RightBottomSp
    if datas.naijiuduMax and datas.naijiuduMax == 0 then --无限耐久
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
    else
        if datas.naijiudu  then
            test("datas.naijiudu=>"..datas.naijiudu)
           if datas.naijiudu<=0 then
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, 1801300230);
                GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.IconMask, 0, 0,80,81);
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, 1800408430);
                GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.RightBottomSp, 0, 0,22,23);
           else
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
                GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
           end
        else
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
        end
    end

    if datas.bind==true then
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.LeftTopSp, 1800707120);
        GUI.ItemCtrlSetElementRect(item, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
    else
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.LeftTopSp, nil);
    end

    local strGUID = tostring(datas.guid)
    if ShopUI.SellSelectItemLst[strGUID] ~= nil then
        ShopUI.OnCheckItemForUI(guid, true, tostring(ShopUI.SellSelectItemLst[strGUID].count).."/"..ShopUI.SellSelectItemLst[strGUID].total)
    else
        local Select =  GUI.GetChild(item, "Select")
        if Select ~= nil then
            GUI.SetVisible(Select, false)
        end
        local decreaseBtn =  GUI.GetChild(item, "decreaseBtn")
        if decreaseBtn ~= nil then
            GUI.SetVisible(decreaseBtn, false)
        end
        local Count =  GUI.GetChild(item, "Count")
        if Count ~= nil then
            GUI.StaticSetText(Count, tostring(datas.count))
            GUI.SetVisible(Count, datas.count>0)
        end
    end
    local decreaseBtn =  GUI.GetChild(item, "decreaseBtn")
    if decreaseBtn ~= nil then
        GUI.SetData(decreaseBtn, "itemGUID", guid)
    end
end

--刷新出售道具列表
function ShopUI.RefreshSellScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    ShopUI.UpdateSellItemInfo(guid, index)
end

function ShopUI.OnCheckItem(guid, isAdd, num, price, itemGUID, forceSetNum)
    if forceSetNum ~= nil then
        if ShopUI.SellSelectItemLst[itemGUID] == nil then
            ShopUI.SellSelectItemLst[itemGUID] = {count=1, total=num, price=price, guid=itemGUID}
        end
        if ShopUI.SellSelectItemLst[itemGUID] ~= nil then
            ShopUI.SellSelectItemLst[itemGUID].count = forceSetNum
            ShopUI.OnCheckItemForUI(guid, true, tostring(ShopUI.SellSelectItemLst[itemGUID].count).."/"..num)
        end
    else
        if isAdd then
            if ShopUI.SellSelectItemLst[itemGUID] == nil then
                ShopUI.SellSelectItemLst[itemGUID] = {count=1, total=num, price=price, guid=itemGUID}
                ShopUI.OnCheckItemForUI(guid, true, "1/"..num)
            else
                if ShopUI.SellSelectItemLst[itemGUID].count<num then
                    ShopUI.SellSelectItemLst[itemGUID].count = ShopUI.SellSelectItemLst[itemGUID].count + 1
                    ShopUI.OnCheckItemForUI(guid, true, tostring(ShopUI.SellSelectItemLst[itemGUID].count).."/"..num)
                else
                    CL.SendNotify(NOTIFY.ShowBBMsg, "已达上限")
                end
            end
        else
            if ShopUI.SellSelectItemLst[itemGUID] ~= nil and ShopUI.SellSelectItemLst[itemGUID].count > 0 then
                ShopUI.SellSelectItemLst[itemGUID].count = ShopUI.SellSelectItemLst[itemGUID].count - 1
            end

            if ShopUI.SellSelectItemLst[itemGUID] == nil or ShopUI.SellSelectItemLst[itemGUID].count <= 0 then
                ShopUI.OnCheckItemForUI(guid, false, num)

                -- 当选中数量为0时停止减少按钮事件
                ShopUI.OnMinusBtnPointerUp()

                ShopUI.SellSelectItemLst[itemGUID] = nil
                ShopUI.OnCheckIsRemovedAllElements()
                ShopUI.SelectSellItemIndex = -1
            else
                ShopUI.OnCheckItemForUI(guid, true, tostring(ShopUI.SellSelectItemLst[itemGUID].count).."/"..num)
            end
        end
    end

    ShopUI.OnUpdateSellTotalPrice()
    ShopUI.OnSelectAllBtnState()
end

function ShopUI.OnCheckIsRemovedAllElements()
    local isClear = true
    for k, v in pairs(ShopUI.SellSelectItemLst) do
        if ShopUI.SellSelectItemLst[k] ~= nil then
            isClear = false
            break
        end
    end
    if isClear then
        ShopDetailUI.ShowDetailInfo(nil, ShopUI.panelBg, ShopUI.tabIndex, _gt)
        ShopUI.ShowSellNumNode(false)
    end
end

function ShopUI.OnUpdateSellTotalPrice()
    local totalPrice = 0
    for i, v in pairs(ShopUI.SellSelectItemLst) do
        totalPrice = totalPrice + v.count * v.price
    end

    local totalCount = _gt.GetUI("totalCount")
    if totalCount ~= nil then
        GUI.StaticSetText(totalCount, tostring(totalPrice))
    end
end

function ShopUI.OnSelectAllBtnState()
    local totalCount = 0
    for i, v in pairs(ShopUI.SellSelectItemLst) do
        totalCount = totalCount + 1
        break
    end

    local btn = _gt.GetUI("selectAllBtn")
    if btn then
        GUI.SetVisible(btn, totalCount==0 )
    end
    btn = _gt.GetUI("unSelectAllBtn")
    if btn then
        GUI.SetVisible(btn, totalCount>0 )
    end
end

function ShopUI.OnCheckItemForUI(guid, select, numInfo)
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


function ShopUI.OnBuyItemClick(guid, index)
    --取消前一个item项的选中
    ShopUI.UnCheckPreBuyItem()
    ShopUI.SelectBuyItemGUID = guid
    local item = GUI.GetByGuid(guid)
    ShopUI.SelectBuyItemIndex = item ~= nil and tonumber(GUI.GetData(item, "index")) or index
    --选中当前item项
    ShopUI.CheckBuyItem()
    local text = 1 -- ShopUI.ShopItems.buy_back_list[ShopUI.SelectBuyItemIndex].amount
    if ShopUI.Flag == 2 then
        text = ShopUI.ShopItems.buy_back_list[ShopUI.SelectBuyItemIndex].amount
    end
    local count = 1
    if text ~= nil and text ~= 0 then
        count = text
    end

    ShopUI.CoinType = RoleAttr.RoleAttrBindGold
    --显示详情
    if ShopUI.tabIndex == 1 and ShopUI.ShopItems.shop_item_list ~= nil and ShopUI.SelectBuyItemIndex>=0 and ShopUI.SelectBuyItemIndex < ShopUI.ShopItems.shop_item_list.Count then
        test("=====购买=======")
        ShopUI.SelectBuyItemPrice = ShopUI.ShopItems.shop_item_list[ShopUI.SelectBuyItemIndex].price
        ShopUI.CoinType = CL.ConvertAttr(ShopUI.ShopItems.shop_item_list[ShopUI.SelectBuyItemIndex].price_type)
        local bind = ShopUI.ShopItems.shop_item_list[ShopUI.SelectBuyItemIndex].bind==1 and true or false
        ShopDetailUI.ShowDetailInfo(ShopDetailUI.PackShopItemInfos(ShopUI.ShopItems.shop_item_list[ShopUI.SelectBuyItemIndex].id, bind), ShopUI.panelBg, ShopUI.tabIndex, _gt)
    elseif ShopUI.tabIndex == 3 and ShopUI.ShopItems.buy_back_list ~= nil and ShopUI.SelectBuyItemIndex>=0 and ShopUI.SelectBuyItemIndex < ShopUI.ShopItems.buy_back_list.Count then
        test("=====赎回=======")
        local id = ShopUI.ShopItems.buy_back_list[ShopUI.SelectBuyItemIndex].id
        local attrs = ShopUI.ShopItems.buy_back_list[ShopUI.SelectBuyItemIndex].dyn_attrs
        local bind = ShopUI.ShopItems.buy_back_list[ShopUI.SelectBuyItemIndex].isbound == 1 and true or false
        --count = ShopUI.ShopItems.buy_back_list[ShopUI.SelectBuyItemIndex].amount
        ShopUI.SelectBuyItemPrice = item ~= nil and tonumber(GUI.GetData(item, "price")) or 1
        local itemData = LD.GetShopBuyBackItem(ShopUI.SelectBuyItemIndex)
        ShopDetailUI.ShowDetailInfo(ShopUI.PackRealItemInfos(id, attrs, bind, count,true,itemData), ShopUI.panelBg, ShopUI.tabIndex, _gt)
        --ShopUI.ShowItemTips(LD.GetShopBuyBackItem(ShopUI.SelectBuyItemIndex))
    end
    --test("count="..count)
    --重置数量和货币类型
    ShopUI.UpdateSelectItemInfo(count,ShopUI.CoinType)
    --显示总价格
    ShopUI.OnUpdateTotalPrice()
    --刷新拥有的货币
    ShopUI.UpdateOwnMoneyCount()
end

function ShopUI.ShowItemTips(itemData)
    local detailExtNode = _gt.GetUI("detailExtNode")
    if detailExtNode then
        local tip = Tips.CreateByItemData(itemData, detailExtNode, "itemTips",763,61,0)
        GUI.SetIsRemoveWhenClick(tip, true)
    end
end

function ShopUI.UpdateSelectItemInfo(count, coinType)
    --if ShopUI.tabIndex == 3 then
        local countEdit = _gt.GetUI("countEdit")
        if countEdit then
            GUI.EditSetTextM(countEdit, tostring(count))
        end
    --end
    --改变货币类型
    local ownIcon = _gt.GetUI("ownicon")
    if ownIcon then
        GUI.ImageSetImageID(ownIcon, UIDefine.AttrIcon[coinType])
    end
    local spendIcon = _gt.GetUI("spendIcon")
    if spendIcon then
        GUI.ImageSetImageID(spendIcon, UIDefine.AttrIcon[coinType])
    end
end

function ShopUI.UpdateOwnMoneyCount(moneyCount)
    local count = _gt.GetUI("owncount")
    if count then
        local money = moneyCount~=nil and moneyCount or tostring(CL.GetAttr(ShopUI.CoinType))
        GUI.StaticSetText(count, money)
        ShopUI.OnUpdateTotalPrice(money)
        GUI.StaticSetText(count, moneyCount~=nil and moneyCount or tostring(CL.GetAttr(ShopUI.CoinType)))
    end
end

function ShopUI.OnUpdateTotalPrice(money)
    local countEdit = _gt.GetUI("countEdit")
    local spendCount = _gt.GetUI("spendCount")
    local owncount = _gt.GetUI("owncount")
    if countEdit ~= nil and spendCount ~= nil and owncount ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt)
        local cost = num * ShopUI.SelectBuyItemPrice
        GUI.StaticSetText(spendCount, tostring(cost))

        if money == nil then
            money = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
        end
        if cost > tonumber(money) then
            GUI.SetColor(spendCount,UIDefine.RedColor)
        else
            GUI.SetColor(spendCount,UIDefine.White2Color)
        end
        GUI.StaticSetText(spendCount, tostring(num * ShopUI.SelectBuyItemPrice))
    end
end

function ShopUI.OnPressedMinusBtn()
    ShopUI.PressedCounter = ShopUI.PressedCounter + 1
    if ShopUI.PressedCounter >= PRESS_WAIT_TIME then
        ShopUI.PressedItemGuid = ShopUI.long_press_item_btn_guid
        ShopUI.OnClickMinusBtn(ShopUI.PressedItemGuid)
    end
end

function ShopUI.OnMinusBtnPointerUp(guid)
    if ShopUI.PressedTimer then
        ShopUI.PressedTimer:Stop()
        ShopUI.PressedTimer = nil
    end
end

function ShopUI.OnMinusBtnPointerDown(guid)
    ShopUI.PressedCounter = 0
    --ShopUI.PressedItemGuid = guid
    ShopUI.long_press_item_btn_guid = guid
    if ShopUI.PressedTimer == nil then
        ShopUI.PressedTimer = Timer.New(ShopUI.OnPressedMinusBtn, 0.1, -1)
    end
    ShopUI.PressedTimer:Start()
end

function ShopUI.OnClickMinusBtn(guid)
    local btn = GUI.GetByGuid(guid)
    local index = 0
    if btn ~= nil then

        -- 判断是否是减少按钮 如果拿不到此数据则是物品格
        local item_guid = GUI.GetData(btn, "itemGUI")
        local item = nil
        if item_guid == nil or item_guid == '' then
            item = btn
        else
            item = GUI.GetByGuid(item_guid)
        end
        local itemgui = GUI.GetGuid(item)

        --local itemgui = GUI.GetData(btn, "itemGUI")
        --local item = GUI.GetByGuid(itemgui)
        if item ~= nil then
            local num = tonumber(GUI.GetData(item, "total"))
            local price = tonumber(GUI.GetData(item, "price"))
            local itemGUID = tostring(GUI.GetData(item, "guid"))
            index = tonumber(GUI.GetData(item, "index"))
            if itemGUID ~= "0" then
                ShopUI.OnCheckItem(itemgui, false, num, price,itemGUID)
            end
            --右侧数量栏
            local Count = ShopUI.SellSelectItemLst[itemGUID] and ShopUI.SellSelectItemLst[itemGUID].count or 0
            ShopUI.SetSellNum(Count)

            ShopUI.SelectSellItemCountUI = item
        end

        if ShopUI.SellItems ~= nil and index>=0 and index<ShopUI.SellItems.Count then
            --设置当前操作索引
            ShopUI.SelectSellItemTotalCount = ShopUI.SellItems[index].amount
            local SellNumNode = _gt.GetUI("SellNumNode")
            if index ~= ShopUI.SelectSellItemIndex or SellNumNode and not GUI.GetVisible(SellNumNode) then
                ShopUI.SelectSellItemIndex = index

                -- 当前选中的物品格guid
                ShopUI.PressedItemGuid = itemgui

                local itemData = ShopUI.SellItems[index]
                ShopDetailUI.ShowDetailInfo(ShopUI.PackRealItemInfos(ShopUI.SellItems[index].id, ShopUI.SellItems[index].dyn_attrs, ShopUI.SellItems[index].isbound==1 and true or false, ShopUI.SellItems[index].amount,true,itemData), ShopUI.panelBg, ShopUI.tabIndex, _gt)
                ShopUI.ShowSellNumNode(true)
                ShopDetailUI.numNodify = ShopUI.UpdateSelectItemNum
                --ShopUI.ShowItemTips(ShopUI.SellItems[index])
            end
        end

    end
end

function ShopUI.OnPressedOneItem()
    ShopUI.PressedCounter = ShopUI.PressedCounter + 1
    if ShopUI.PressedCounter >= PRESS_WAIT_TIME then
        ShopUI.PressedItemGuid = ShopUI.long_press_item_btn_guid
        ShopUI.OnSellItemClick(ShopUI.PressedItemGuid)
    end
end

function ShopUI.OnSellItemPointerUp(guid)
    if ShopUI.PressedTimer then
        ShopUI.PressedTimer:Stop()
        ShopUI.PressedTimer = nil
    end
end

function ShopUI.OnSellItemPointerDown(guid)
    ShopUI.PressedCounter = 0
    --ShopUI.PressedItemGuid = guid
    ShopUI.long_press_item_btn_guid = guid
    if ShopUI.PressedTimer == nil then
        ShopUI.PressedTimer = Timer.New(ShopUI.OnPressedOneItem, 0.1, -1)
    end
    ShopUI.PressedTimer:Start()
end

function ShopUI.OnSellItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local index = 0

    -- 判断是否是减少按钮的，如果拿不出数据则不是减少按钮
    local item_guid = GUI.GetData(item, "itemGUI")
    if item_guid == nil or item_guid == '' then
    else
        item = GUI.GetByGuid(item_guid)
    end
    guid = GUI.GetGuid(item) or guid

    if item ~= nil then
        local num = tonumber(GUI.GetData(item, "total"))
        local price = tonumber(GUI.GetData(item, "price"))
        local itemGUID = tostring(GUI.GetData(item, "guid"))
        index = tonumber(GUI.GetData(item, "index"))
        if itemGUID ~= "0" then
            ShopUI.OnCheckItem(guid, true, num, price,itemGUID)
        end
        ShopUI.SelectSellItemCountUI = item
        if ShopUI.SellSelectItemLst[itemGUID] ~= nil then
            ShopUI.SetSellNum(ShopUI.SellSelectItemLst[itemGUID].count)
        end
    end

    if ShopUI.SellItems ~= nil and index>=0 and index<ShopUI.SellItems.Count then
        --设置当前操作索引
        ShopUI.SelectSellItemTotalCount = ShopUI.SellItems[index].amount
        local SellNumNode = _gt.GetUI("SellNumNode")
        if index ~= ShopUI.SelectSellItemIndex or SellNumNode and not GUI.GetVisible(SellNumNode) then
            ShopUI.SelectSellItemIndex = index

            -- 当前选中的物品格guid
            ShopUI.PressedItemGuid = guid

            local itemData = ShopUI.SellItems[index]
            ShopDetailUI.ShowDetailInfo(ShopUI.PackRealItemInfos(ShopUI.SellItems[index].id, ShopUI.SellItems[index].dyn_attrs, ShopUI.SellItems[index].isbound==1 and true or false, ShopUI.SellItems[index].amount,true,itemData), ShopUI.panelBg, ShopUI.tabIndex, _gt)
            ShopUI.ShowSellNumNode(true)
            ShopDetailUI.numNodify = ShopUI.UpdateSelectItemNum
            --ShopUI.ShowItemTips(ShopUI.SellItems[index])
        end
    end
end

function ShopUI.ShowSellNumNode(show)
    local SellNumNode = _gt.GetUI("SellNumNode")
    if SellNumNode then
        GUI.SetVisible(SellNumNode, show)
    end
end

function ShopUI.UpdateSelectItemNum(numNow)
    if ShopUI.SelectSellItemCountUI then
        local guid = GUI.GetGuid(ShopUI.SelectSellItemCountUI)
        local itemGUID = GUI.GetData(ShopUI.SelectSellItemCountUI, "guid")
        local price = GUI.GetData(ShopUI.SelectSellItemCountUI, "price")
        local num = GUI.GetData(ShopUI.SelectSellItemCountUI, "total")
        if itemGUID ~= "0" then
            ShopUI.OnCheckItem(guid, nil, num, price, itemGUID, numNow)
        end
    end
end

function ShopUI.SetSellNum(num)
    --test("SetSellNum="..num)
    local SellCountEdit = _gt.GetUI("SellCountEdit")
    if SellCountEdit then
        GUI.EditSetTextM(SellCountEdit, tostring(num))
    end
end

function ShopUI.PackRealItemInfos(itemID, atts, bind, num, showDetail,itemData)
    local attrTables = ShopDetailUI.PackItemBaseInfo(itemID)
    local itemConfig = DB.GetOnceItemByKey1(itemID)
   
    showDetail = showDetail or false
    if itemConfig ~= nil then
        local itemType = itemConfig.Type
        attrTables.bind = bind
        attrTables.maxNum = num
        --装备分类
        --显示基本类型，调用统一tip显示
        test("showDetail="..tostring(showDetail))
        test("itemType="..itemType)
        if showDetail and itemType == 1 then
            attrTables.func = nil
            attrTables.equipTurnBorn = itemConfig.TurnBorn
            attrTables.equipLevel = itemConfig.Level
            attrTables.role = itemConfig.Role
            --基础属性
            -- if atts ~= nil then
            --     local attrCount = atts.Count
            --     test("attrCount="..attrCount)
            --     local count = 0
            --     for i = 0, attrCount-1 do
            --         local AttrConfig = DB.GetOnceAttrByKey1(atts[i].attr)
            --         if AttrConfig ~= nil then
            --             count = count + 1
            --             local attDesc = AttrConfig.ChinaName.."  "
            --             if AttrConfig.IsPct == 1 then
            --                 attDesc = attDesc..( tonumber(tostring(atts[i].value)) /100).."%"
            --             else
            --                 attDesc = attDesc..tostring(atts[i].value)
            --             end
            --             test("attDesc=>"..attDesc)
            --             attrTables.atts[count] = attDesc
            --         end
            --     end
            -- end

            if itemData then
                --基础属性
                local t = {}
                LogicDefine.GetItemDynAttrDataByMark(itemData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)
                if #t > 0 then
                    for i = 1, #t do
                        local value = tostring(t[i].value)
                        if t[i].Id ~= 0 then
                            if t[i].IsPct then
                                value = tostring(tonumber(value) / 100) .. "%"
                            end
                            local attDesc = t[i].name .. "   " .. value
                            test("attDesc=>"..attDesc)
                            table.insert(attrTables.atts,attDesc)
                        end
                    end
                end

                --特效
                local Equip_SpecialEffect =  itemData:GetIntCustomAttr("Equip_SpecialEffect")
                local SpecialEffect = DB.GetOnceSkillByKey1(Equip_SpecialEffect)
                if SpecialEffect.Name ~= nil then
                    table.insert(attrTables.atts,"特效：【"..tostring(SpecialEffect.Name).."】")
                end
                --特技
                local Equip_Stunt =  itemData:GetIntCustomAttr("Equip_Stunt")
                local Stunt = DB.GetOnceSkillByKey1(Equip_Stunt)
                if Stunt.Name ~= nil then
                    table.insert(attrTables.atts,"特技：【"..tostring(Stunt.Name).."】")
                end

                test("==强化属性==============")
                --强化属性
                local t = {}
                LogicDefine.GetItemDynAttrDataByMark(itemData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)
                local exv ="强化等级：   "
                local exMax = UIDefine.MaxIntensifyLevel
                local ulongVal = itemData:GetIntCustomAttr(LogicDefine.EnhanceLv)
                local enhanceLv, h = int64.longtonum2(ulongVal)
                test("enhanceLv==========="..tostring(enhanceLv))
                if enhanceLv > 0 then
                    exv = exv..enhanceLv
                    if exMax then
                        exv = exv.."/"..exMax
                    end
                    table.insert(attrTables.intensifyInfo,exv)
                    local intensifyInfo_attrs ={}
                    if #t > 0 then
                        for i = 1, #t do
                            local value = tostring(t[i].exV)
                            if t[i].Id ~= 0 then
                                if t[i].IsPct then
                                    value = tostring(tonumber(value) / 100) .. "%"
                                end
                                table.insert(intensifyInfo_attrs,t[i].name .. "   " .. value)
                            end
                        end
                        table.insert(attrTables.intensifyInfo,intensifyInfo_attrs)
                    end
                end

                test("=============宝石属性============")
             
                --宝石属性
                local gemCount, siteCount = LogicDefine.GetEquipGemCount(itemData)
                if gemCount > 0 then
                    --GUI.TipsAddLabel(itemTips, 20, "宝石镶嵌：    " .. gemCount .. "/" .. siteCount, UIDefine.Yellow3Color, false)
                    table.insert(attrTables.gemInfo,"宝石镶嵌：    " .. gemCount .. "/" .. siteCount)
                    local gemInfo_attrs={}
                    for i = 1, siteCount do
                        local gemId = itemData:GetIntCustomAttr(LogicDefine.ITEM_GemId_ .. i)
                        if gemId ~= 0 then
                            local gemDB = DB.GetOnceItemByKey1(gemId)
                            --GUI.TipsAddLabel(itemTips, 20, gemDB.Name .. "：", UIDefine.BlueColor, false)
                            table.insert(gemInfo_attrs,tostring(gemDB.Name))
                            local attrDatas = itemData:GetDynAttrDataByMark(LogicDefine.ITEM_GemAttrMark[i])
                            local GemAttribute = ""
                            for i = 0, attrDatas.Count - 1 do
                                local attrData = attrDatas[i]
                                local attrId = attrData.attr
                                local value = attrData.value
                                GemAttribute = GemAttribute..UIDefine.GetAttrDesStr(attrId, value)
                                if attrDatas.Count > 1 then
                                    if i == 0 then
                                        GemAttribute = GemAttribute.."   "
                                    end
                                end
                            end
                            --GUI.TipsAddLabel(itemTips, 45, GemAttribute, UIDefine.BlueColor, false)
                            table.insert(gemInfo_attrs,GemAttribute)
                            test("GemAttribute=>"..GemAttribute)
                        end
                    end
                    table.insert(attrTables.gemInfo,gemInfo_attrs)
                end
                
                test("=============套装属性============")
                --套装属性
                if GlobalUtils.suitConfig then
                    local suitName=itemData:GetStrCustomAttr(GlobalUtils.suitConfig.Sign_STR)
                    if suitName~="" then
                        local config=GlobalUtils.suitConfig[suitName];
                        local num=0;
            
                        local capacity=LD.GetBagCapacity(item_container_type.item_container_equip)
                        for i = 0, capacity-1 do
                            local suitName2=LD.GetItemStrCustomAttrByIndex(GlobalUtils.suitConfig.Sign_STR,i, item_container_type.item_container_equip)
                            if suitName2==suitName then
                                num=num+1;
                            end
                        end
                        --GUI.TipsAddLabel(itemTips, 20,"套装属性：" ..  config.Suit_Name.."("..num.."/"..config.Total..")", UIDefine.GreenColor, false)
                        table.insert(attrTables.suitInfo,"套装属性：" ..  config.Suit_Name.."("..num.."/"..config.Total..")")
                        local suitInfo_attrs={}
                        for i = 1, config.Total do
                            if config.Size[i] then
                                local state="(未激活)"
                                if num>=i then
                                    state="(已激活)"
                                end
                                for j = 1, #config.Size[i].Attr do
                                    local attrDB = DB.GetOnceAttrByKey2(config.Size[i].Attr[j][1])
                                    if attrDB.Id~=0 then
                                        --GUI.TipsAddLabel(itemTips, 20,"["..i.."]"..UIDefine.GetAttrDesStr(attrDB.Id,config.Size[i].Attr[j][2])..state, UIDefine.GreenColor,false)
                                        table.insert(suitInfo_attrs,"["..i.."]"..UIDefine.GetAttrDesStr(attrDB.Id,config.Size[i].Attr[j][2])..state)
                                    end
            
                                end
                            end
                        end
                        table.insert(attrTables.suitInfo,suitInfo_attrs)
                    end
                end
               
            end

            --属性表
            local itemAttrConfig = DB.GetOnceItem_AttByKey1(itemID)
            if itemAttrConfig ~= nil then
                --穿戴要求属性达到的值
                attrTables.attsRequire = {"","","",""}
                local EquipNeedAtts = {itemAttrConfig.StrRequire, itemAttrConfig.IntRequire, itemAttrConfig.VitRequire, itemAttrConfig.AgiRequire}
                local EquipNeedName = {"力量需求","灵性需求", "根骨需求","敏捷需求"}
                for i = 1, 4 do
                    if EquipNeedAtts[i] ~= 0 then
                        attrTables.attsRequire[i] = EquipNeedName[i].."  "..EquipNeedAtts[i]
                    end
                end
            end
           
        end
    end
    return attrTables
end

-- 为了区分购买和赎回的输入框
function ShopUI.OnBuyModify()
    ShopUI.OnBuyCountModify(1)
end