PetShopUI = {}
require "UILayout"

local _gt = UILayout.NewGUIDUtilTable()
PetShopUI.SelectBuyItemGUID = 0
PetShopUI.CurrentSelectPetIndex = 0
PetShopUI.PetItems = {}
PetShopUI.CoinType = RoleAttr.RoleAttrBindGold
PetShopUI.ManualSelectFirstItem = true

function PetShopUI.Main(parameter)
    local panel = GUI.WndCreateWnd("PetShopUI" , "PetShopUI" , 0 , 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "宠物商店","PetShopUI","OnExit")

    local Context = GUI.CreateStatic( panelBg,"Context", "野生宠物可做任务用，不具备培养价值", 352, 212, 350, 50)
    GUI.StaticSetFontSize(Context, 20)
    GUI.SetColor(Context, UIDefine.BrownColor)

    local PetTypeBg = GUI.ImageCreate( panelBg,"PetTypeBg", "1800400010", -363.7, 3.275, false, 313.4, 560.45)

    PetShopUI.CreatePetCarryLevelType(PetTypeBg)
    PetShopUI.CreateItemScrollList()
    PetShopUI.CreateItemInfoMenu()

    GUI.RegisterUIMessage(UM.CloseWhenClicked,"PetShopUI" , "OnClose")
    --目前只刷新金币/绑定金币
    CL.RegisterAttr(RoleAttr.RoleAttrGold, PetShopUI.UpdateMoneyValue)
    CL.RegisterAttr(RoleAttr.RoleAttrBindGold, PetShopUI.UpdateMoneyValue)
end

PetShopUI.GoodsSubType={0,5,15,25,35,45}
function PetShopUI.CreatePetCarryLevelType(parent)
    --local scroll = GUI.ScrollRectCreate( parent, "scroll", 0, 0, 313, 544, 0, false, Vector2.New(294,65), UIAroundPivot.Top, UIAnchor.Top)
     --GUI.ScrollRectSetChildSpacing(scroll,Vector2.New(0,2))
     
    --  local tableClone = function (t)
    --      local newt = {}
    --      for i = 1, #t do
    --         table.insert(newt,t[i])
    --      end
    --      return newt
    --  end
     local isInTable = function (t,value)
         for k,v in pairs(t) do 
            test("k="..k..",v="..v)
            if v == value then
                return true
            else
                return false
            end
         end
     end
     local removeRepeatValue=function (t)
        local newt={}
        for k,v in pairs(t) do
            newt[v] = k          
        end
        local newt2={}
        for k, _ in pairs(newt) do
            --test("k="..k)
            table.insert(newt2,k)
        end 
        return newt2
     end

     local tempT = {}
     PetShopUI.GoodsSubType = {}
     PetShopUI.PetItems = LD.GetShopItems()
     for i = 0, PetShopUI.PetItems.shop_item_list.Count - 1 do
        local config = DB.GetOncePetByKey1(PetShopUI.PetItems.shop_item_list[i].id)
        if config then
            table.insert(tempT,config.CarryLevel)
        end
     end
     --去重
     PetShopUI.GoodsSubType = removeRepeatValue(tempT)
    --  local _log=""
    --  for i = 1, #PetShopUI.GoodsSubType do
    --      _log = _log..PetShopUI.GoodsSubType[i]..","
    --  end
    --  test("_log1=".._log)
    --排序
     table.sort(PetShopUI.GoodsSubType,function (a,b)
         if a < b then
             return true
         else
            return false
         end
     end)
    --  local _log=""
    --  for i = 1, #PetShopUI.GoodsSubType do
    --      _log = _log..PetShopUI.GoodsSubType[i]..","
    --  end
    --  test("_log2=".._log)
    --=====================================================================

    local goodsTypeListScroll = GUI.ScrollRectCreate( parent, "goodsTypeListScroll", 0, 0, 313, 544, 0, false, Vector2.New(294,65), UIAroundPivot.Top, UIAnchor.Top)
    --GUI.ScrollRectSetChildSpacing(goodsTypeListScroll,Vector2.New(0,2))
    --_gt.BindName(goodsTypeListScroll, "goodsTypeListScroll")
    --UILayout.SetSameAnchorAndPivot(goodsTypeListScroll, UILayout.TopLeft)
    --仅显示宠物分类
    local Btn = GUI.CheckBoxExCreate(goodsTypeListScroll, "typeBtn", "1800400410", "1800400411", 0, -238,false)
    local TitleText = GUI.CreateStatic( Btn,"TitleText", "宠物", 0, 0, 250, 32)
    GUI.StaticSetFontSize(TitleText, 26)
    GUI.StaticSetAlignment(TitleText, TextAnchor.MiddleCenter)
    GUI.SetColor(TitleText, UIDefine.BrownColor)
    GUI.CheckBoxExSetCheck(Btn, true)
    GUI.SetIsRaycastTarget(Btn, false)

    local listType = GUI.ListCreate(goodsTypeListScroll, "listType", 0, 0, 294, 320, false)
    UILayout.SetSameAnchorAndPivot(listType, UILayout.Top)
    --GUI.SetPaddingHorizontal(listType, Vector2.New(35, 0))
   -- _gt.BindName(listType, "listType" .. i)
    GUI.GUIListSetChildSpacing(listType,-2)

    for m = 1 , #PetShopUI.GoodsSubType do
        local subPath = "listTypeSubBtn"..PetShopUI.GoodsSubType[m]
        local btnName = PetShopUI.GoodsSubType[m].."级"
        -- 子节点
        local listTypeSubBtn = GUI.ButtonCreate(listType, subPath, "1801302060", 0, 0, Transition.ColorTint,btnName , 294, 71, false)
        UILayout.SetSameAnchorAndPivot(listTypeSubBtn, UILayout.Top)
        GUI.ButtonSetTextFontSize(listTypeSubBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(listTypeSubBtn, UIDefine.BrownColor)
        GUI.RegisterUIEvent(listTypeSubBtn, UCE.PointerClick, "PetShopUI", "OnListTypeSubBtnClick")
        _gt.BindName(listTypeSubBtn, subPath)
    end
end

function PetShopUI.OnListTypeSubBtnClick(guid)
    for i = 1, #PetShopUI.GoodsSubType do
        local subPath = "listTypeSubBtn"..PetShopUI.GoodsSubType[i]
        if _gt.GetGuid(subPath) == guid then
            PetShopUI.CurrentSelectPetType = PetShopUI.GoodsSubType[i]
            PetShopUI.CurrentSelectPetIndex = 1
            break
        end
    end

    PetShopUI.RefreshUI()
end

function PetShopUI.UpdateMoneyValue(attrType, value)
    if PetShopUI.CoinType == attrType then
        PetShopUI.RefreshOwnCostUI(value)
    end
end

function PetShopUI.OnClose()
    GUI.DestroyWnd("PetShopUI")
end

PetShopUI.PetArrayByCarryLevel={}
function PetShopUI.OnShow()
    if GUI.GetWnd("PetShopUI") == nil then
        return
    end

    PetShopUI.PetItems = LD.GetShopItems()
    --根据携带等级分类
    PetShopUI.PetArrayByCarryLevel={}
    for j = 1, #PetShopUI.GoodsSubType do
        local level = PetShopUI.GoodsSubType[j]
        PetShopUI.PetArrayByCarryLevel[level]={}
        for i = 0, PetShopUI.PetItems.shop_item_list.Count - 1 do
            local config = DB.GetOncePetByKey1(PetShopUI.PetItems.shop_item_list[i].id)
            if config then
                if config.CarryLevel == level then
                    table.insert(PetShopUI.PetArrayByCarryLevel[level],PetShopUI.PetItems.shop_item_list[i])
                end 
            end
        end
    end

    local cnt = 0
    for k,v  in pairs(PetShopUI.PetArrayByCarryLevel)  do
        --print("k="..k..",#v="..#v)
        cnt = cnt + #v
    end
    test("PetShopUI.PetItems.shop_item_list.Count="..PetShopUI.PetItems.shop_item_list.Count..",cnt="..cnt)

    --找到选中的物体类型和位置
    PetShopUI.ManualSelectFirstItem = PetShopUI.PetItems.def_item_id ~= 0 and true or false
    PetShopUI.CurrentSelectPetType = PetShopUI.GoodsSubType[1]
    PetShopUI.CurrentSelectPetIndex = 1
    --local count = PetShopUI.PetItems.shop_item_list.Count
    if PetShopUI.PetItems.def_item_id ~= 0 then
        -- for i = 1, count do
        --     if PetShopUI.PetItems.shop_item_list[i-1].id == PetShopUI.PetItems.def_item_id then
        --         PetShopUI.CurrentSelectPetIndex = i-1
        --         break
        --     end
        -- end
        for k,v in pairs(PetShopUI.PetArrayByCarryLevel) do
            local leveldata = v
            for j = 1, #leveldata do
                local data = leveldata[j]
                if  PetShopUI.PetItems.def_item_id == data.id then
                    PetShopUI.CurrentSelectPetType = k
                    PetShopUI.CurrentSelectPetIndex = j
                    break
                end
            end
        end
    end

    PetShopUI.RefreshUI()
end


function PetShopUI.RefreshUI()
    test("PetShopUI.CurrentSelectPetType="..PetShopUI.CurrentSelectPetType)
    test("PetShopUI.CurrentSelectPetIndex="..PetShopUI.CurrentSelectPetIndex)

    --local _data = PetShopUI.PetItems.shop_item_list
    local _data = PetShopUI.PetArrayByCarryLevel[PetShopUI.CurrentSelectPetType]
    local count  = #_data
    local ItemScroll = _gt.GetUI("ItemScroll")
    if  _data ~= nil then
        GUI.LoopScrollRectSetTotalCount(ItemScroll, count)
        GUI.LoopScrollRectRefreshCells(ItemScroll)
        if count > 0 then
            local targetIndex = math.max(math.min(count-8, PetShopUI.CurrentSelectPetIndex), 0)
            GUI.ScrollRectSetNormalizedPosition(ItemScroll, Vector2.New(0,targetIndex/count))
        end
    end

    for i = 1 , #PetShopUI.GoodsSubType do
        local subPath = "listTypeSubBtn"..PetShopUI.GoodsSubType[i]
        local sub = _gt.GetUI(subPath)
        if sub then
            if PetShopUI.GoodsSubType[i]==PetShopUI.CurrentSelectPetType  then
                GUI.ButtonSetImageID(sub, "1801302061")
            else
                GUI.ButtonSetImageID(sub, "1801302060")
            end
        end
    end

    PetShopUI.RefreshSpendCostUI()
    PetShopUI.RefreshOwnCostUI()
end

function PetShopUI.CreateItemScrollList()
    local panelBg = GUI.Get("PetShopUI/panelBg")
    local ItemScrollBg = GUI.ImageCreate( panelBg,"ItemScrollBg", "1800400010", 163.6, -48, false, 716.8, 455.6)
    local ItemScroll = GUI.LoopScrollRectCreate(ItemScrollBg, "ItemScroll", 0, 0, 702, 437,
            "PetShopUI","CreatPetItemPool","PetShopUI","RefreshPetItemScroll", 0, false, Vector2.New(342, 100.5), 2, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(ItemScroll, "ItemScroll")
    GUI.ScrollRectSetChildSpacing(ItemScroll, Vector2.New(8, 6))
end

function PetShopUI.CreatPetItemPool()
    local scroll = _gt.GetUI("ItemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local icon = GUI.ItemCtrlCreate( scroll,"itemIcon" .. curCount, "1800700030", 0, 0)
    local ItemSelectedBg = GUI.ImageCreate( icon,"ItemSelectedBg", "1800700040", 0, 0, false, 342, 100.5)
    GUI.SetVisible(ItemSelectedBg, false)
    --物品图标背景
    local ItemIconBg = GUI.ImageCreate( icon,"ItemIconBg", "1800400050", -121, 2, false, 80, 80)
    local ItemIconBg_Orn = GUI.ImageCreate( ItemIconBg,"ItemIconBg_Orn", "1800400060", 0, 0, false, 80, 80)
    --图标
    local ItemIcon = GUI.ImageCreate( ItemIconBg,"ItemIcon", "1900359890", 0, 0, false, 64, 64)

    --物品名称
    local ItemName = GUI.CreateStatic( icon,"ItemName", "红烧窝窝牛", 103, -25, 232, 50)
    GUI.StaticSetFontSize(ItemName, 22)
    GUI.SetAnchor(ItemName, UIAnchor.Left)
    GUI.StaticSetAlignment(ItemName, TextAnchor.MiddleLeft)
    GUI.SetPivot(ItemName, UIAroundPivot.Left)
    GUI.SetColor(ItemName, UIDefine.BrownColor)

    --货币背景
    local CoinBg = GUI.ImageCreate( icon,"CoinBg", "1800900040", 21, 19, false, 190.4, 35.2)

    --货币图标
    local CoinIcon = GUI.ImageCreate( CoinBg,"CoinIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], -77.7, -2.8, false, 35, 35)

    --货币数值
    local CoinCount = GUI.CreateStatic( CoinBg,"CoinCount", 666666, 58.9, 0, 150, 50)
    GUI.StaticSetFontSize(CoinCount, 19)
    GUI.SetAnchor(CoinCount, UIAnchor.Left)
    GUI.StaticSetAlignment(CoinCount, TextAnchor.MiddleLeft)
    GUI.SetPivot(CoinCount, UIAroundPivot.Left)

    GUI.RegisterUIEvent(icon, UCE.PointerClick, "PetShopUI", "OnClickItemIcon")
    return icon
end

function PetShopUI.RefreshPetItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    PetShopUI.RefreshItem(index, guid)
end

function PetShopUI.RefreshItem(index, guid)
    local icon = GUI.GetByGuid(guid)
    if icon then
        GUI.SetData(icon, "index", index)
    end
    local ItemSelectedBg = GUI.GetChildByPath(icon, "ItemSelectedBg")
    local ItemIcon = GUI.GetChildByPath(icon, "ItemIconBg/ItemIcon")
    local ItemName = GUI.GetChildByPath(icon, "ItemName")
    local CostTypeIcon = GUI.GetChildByPath(icon, "CoinBg/CoinIcon")
    local CoinCount = GUI.GetChildByPath(icon, "CoinBg/CoinCount")

    local _data = PetShopUI.PetArrayByCarryLevel[PetShopUI.CurrentSelectPetType] --PetShopUI.PetItems.shop_item_list
    local petinfo = nil
    --if _data~=nil and index-1 >= 0 and index-1 < _data.Count then
    if _data~=nil and index >= 1 and index <= #_data then
        local config = DB.GetOncePetByKey1(_data[index].id)
        if config then
            petinfo = {}
            petinfo.id = _data[index].id
            petinfo.head = config.Head
            petinfo.name = config.Name
            petinfo.price = _data[index].price
            petinfo.price_type = _data[index].price_type
            petinfo.carry_level = config.CarryLevel
        end
    end
    if petinfo~=nil then
        GUI.ImageSetImageID(ItemIcon, tostring(petinfo.head))
        GUI.StaticSetText(ItemName, petinfo.name)
        local costTypeImg = UIDefine.AttrIcon[CL.ConvertAttr(petinfo.price_type)]
        GUI.ImageSetImageID(CostTypeIcon, costTypeImg)
        GUI.StaticSetText(CoinCount, petinfo.price)
    end

    --设置默认选中
    if PetShopUI.ManualSelectFirstItem then
        if petinfo ~= nil and petinfo.id == PetShopUI.PetItems.def_item_id then
            PetShopUI.ManualSelectFirstItem = false
            PetShopUI.CurrentSelectPetIndex = index
            PetShopUI.SelectBuyItemGUID = guid
            GUI.SetVisible(ItemSelectedBg, true)
        end
    else
        if PetShopUI.CurrentSelectPetIndex == index then
            PetShopUI.SelectBuyItemGUID = guid
            GUI.SetVisible(ItemSelectedBg, true)
        else
            GUI.SetVisible(ItemSelectedBg, false)
        end
    end
end

function PetShopUI.CreateItemInfoMenu()
    local panelBg = GUI.Get("PetShopUI/panelBg")
    PetShopUI.SetTitleLabel("花费", "name0",25, UIDefine.BrownColor, -164, -211, panelBg, 50, 30)
    PetShopUI.SetTitleLabel("拥有", "name1",25, UIDefine.BrownColor, -164, -261, panelBg, 50, 30)

    local SpendCoinBg = GUI.ImageCreate( panelBg,"SpendCoinBg", "1800900040", 14.3, 213.7, false, 252, 35)
    local SpendCoinIcon = GUI.ImageCreate( SpendCoinBg,"SpendCoinIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], -106.3, -2.8, false, 35, 35)
    _gt.BindName(SpendCoinIcon, "SpendCoinIcon")
    local count = GUI.CreateStatic( SpendCoinBg,"count", "0", 0, -1, 210,30)
    _gt.BindName(count, "spendcount")
    GUI.StaticSetFontSize(count, 20)
    GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

    local OwnCoinBg = GUI.ImageCreate( panelBg,"OwnCoinBg", "1800900040", 14.29999, 263.8, false, 252, 35)
    local OwnCoinIcon = GUI.ImageCreate( OwnCoinBg,"OwnCoinIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], -106.3, -2.8, false, 35, 35)
    _gt.BindName(OwnCoinIcon, "OwnCoinIcon")
    local count = GUI.CreateStatic( OwnCoinBg,"count", "0", 0, -1,210,30)
    _gt.BindName(count, "owncount")
    GUI.StaticSetFontSize(count, 20)
    GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

    local BuyBtn = GUI.ButtonCreate( panelBg,"BuyBtn", "1800402080", 438.3, 260, Transition.ColorTint, "购买")
    GUI.SetIsOutLine(BuyBtn, true)
    GUI.ButtonSetTextFontSize(BuyBtn, 26)
    GUI.ButtonSetTextColor(BuyBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(BuyBtn, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(BuyBtn, 1)
    GUI.RegisterUIEvent(BuyBtn, UCE.PointerClick, "PetShopUI", "BuyItem")
end

function PetShopUI.BuyItem(guid)
    local buyIdx = nil
    for i = 0, PetShopUI.PetItems.shop_item_list.Count -1  do
        if PetShopUI.PetItems.shop_item_list[i].id == PetShopUI.PetArrayByCarryLevel[PetShopUI.CurrentSelectPetType][PetShopUI.CurrentSelectPetIndex].id then
            buyIdx = i
        end
    end
    test("PetShopUI.CurrentSelectPetType="..PetShopUI.CurrentSelectPetType..",PetShopUI.CurrentSelectPetIndex="..PetShopUI.CurrentSelectPetIndex..",buyIdx="..tostring(buyIdx))
    if buyIdx then
        CL.SendNotify(NOTIFY.ShopOpe, 1, buyIdx, 1)
    else
        test("BuyItem====>buyIndx is nil")
    end
end

function PetShopUI.SetTitleLabel(context, name, size, color, x, y, parent, w, h)
    local Title = GUI.CreateStatic( parent,name, context, x, -y,w,h)
    GUI.StaticSetFontSize(Title, size)
    GUI.SetColor(Title, color)
end

function PetShopUI.RefreshSpendCostUI()
    local CostIconType = _gt.GetUI("SpendCoinIcon")
    local CostCount = _gt.GetUI("spendcount")
    --local _data = PetShopUI.PetItems.shop_item_list
    local _data = PetShopUI.PetArrayByCarryLevel[PetShopUI.CurrentSelectPetType]
    if  _data~= nil and PetShopUI.CurrentSelectPetIndex >=1 and PetShopUI.CurrentSelectPetIndex <= #_data then
        local costType = UIDefine.AttrIcon[CL.ConvertAttr(_data[PetShopUI.CurrentSelectPetIndex].price_type)]
        GUI.ImageSetImageID(CostIconType, costType)
        GUI.StaticSetText(CostCount, _data[PetShopUI.CurrentSelectPetIndex].price)
    end
end

function PetShopUI.RefreshOwnCostUI(value)
    local OwnIconType = _gt.GetUI("OwnCoinIcon")
    local OwnCount = _gt.GetUI("owncount")
    --local _data = PetShopUI.PetItems.shop_item_list
    local _data = PetShopUI.PetArrayByCarryLevel[PetShopUI.CurrentSelectPetType]
    if  _data~= nil and PetShopUI.CurrentSelectPetIndex >=1 and PetShopUI.CurrentSelectPetIndex <= #_data then
        PetShopUI.CoinType = CL.ConvertAttr(_data[PetShopUI.CurrentSelectPetIndex].price_type)
        local costTypeImg = UIDefine.AttrIcon[PetShopUI.CoinType]
        GUI.ImageSetImageID(OwnIconType, costTypeImg)
        local OwnMoneyCount = value~=nil and tostring(value) or tostring(CL.GetAttr(PetShopUI.CoinType))
        GUI.StaticSetText(OwnCount,OwnMoneyCount)
    end
end

function PetShopUI.OnClickItemIcon(guid)
    --取消之前的选中
    local preIcon = GUI.GetByGuid(PetShopUI.SelectBuyItemGUID)
    local ItemSelectedBg = GUI.GetChildByPath(preIcon, "ItemSelectedBg")
    if ItemSelectedBg then
        GUI.SetVisible(ItemSelectedBg, false)
    end

    --选中现在的
    local icon = GUI.GetByGuid(guid)
    if icon then
        PetShopUI.CurrentSelectPetIndex = tonumber(GUI.GetData(icon, "index")) -- -1
        PetShopUI.ManualSelectFirstItem = false
    end
    PetShopUI.SelectBuyItemGUID = guid
    local ItemSelectedBg = GUI.GetChildByPath(icon, "ItemSelectedBg")
    if ItemSelectedBg then
        GUI.SetVisible(ItemSelectedBg, true)
    end

    --刷新对象花费
    PetShopUI.RefreshSpendCostUI()
end

function PetShopUI.OnExit()
    GUI.DestroyWnd("PetShopUI")
end
