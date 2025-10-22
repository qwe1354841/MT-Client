DonateUI = {}
local _gt = UILayout.NewGUIDUtilTable()

-- 列表
local equipList = {}
local petList = {}
local equipSelectedList = {}
local petSelectedList = {}
local PetConfig = {}
local EquipConfig = {}
local Pet_Sell_Formula = {}
local Equip_Sell_Formula = {}

-- 特殊的捐献列表
local SpecialDonateList = {}

local itemGuids = nil
local onceItem = nil

--local equipExploit = nil
--local petExploit = nil

local equipEnhanceLevel = nil           --高品质装备强化等级
local petStar_HighQuality = nil         --高品质宠物星级
local petSkillCount_HighQuality = nil   --高品质宠物技能数量

local tabList = {
    {"装备","EquipTabBtn","OnEquipTabBtnClick"},
    {"宠物","PetTabBtn","OnPetTabBtnClick"},
}

function DonateUI.Main()
    local _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("DonateUI","DonateUI",0,0)
    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "捐    献", "DonateUI", "OnExit", _gt);
    UILayout.CreateRightTab(tabList, "DonateUI");
    local leftBg = GUI.ImageCreate(panelBg, "leftBg", "1800400010", 83, 54, false, 676, 570)
    GUI.SetAnchor(leftBg, UIAnchor.TopLeft)
    GUI.SetPivot(leftBg, UIAroundPivot.TopLeft)
    
    local selectAllBtn = GUI.ButtonCreate(panelBg, "selectAllBtn", "1800402080", 770, 572, Transition.ColorTint, "", 160, 47, false)
    UILayout.SetSameAnchorAndPivot(selectAllBtn, UILayout.TopLeft)
    local selectAllBtnText = GUI.CreateStatic(selectAllBtn,"selectAllBtnText","选中所有",0,0,160, 47, "system", true, false)
    _gt.BindName(selectAllBtnText,"selectAllBtnText")
    UILayout.SetSameAnchorAndPivot(selectAllBtnText, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(selectAllBtnText, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.RegisterUIEvent(selectAllBtn, UCE.PointerClick, "DonateUI", "OnSelectAllBtnClick");
    
    local repayBtn = GUI.ButtonCreate(panelBg, "repayBtn", "1800402080", 950, 572, Transition.ColorTint, "捐献", 160, 47, false)
    UILayout.SetSameAnchorAndPivot(repayBtn, UILayout.TopLeft)
    GUI.ButtonSetTextFontSize(repayBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(repayBtn, UIDefine.WhiteColor);
    
    GUI.RegisterUIEvent(repayBtn, UCE.PointerClick, "DonateUI", "OnRepayBtnClick")
    
    DonateUI.CreateSelectItemArea()
    DonateUI.CreateEquipPage()
    DonateUI.CreatePetPage()
end

function DonateUI.GetDonateEquipAndPetData()
    PetConfig = UIDefine.DonateEquipAndPetData["PetConfig"]
    EquipConfig = UIDefine.DonateEquipAndPetData["EquipConfig"]
    Pet_Sell_Formula = UIDefine.DonateEquipAndPetData["Pet_Sell_Formula"]
    Equip_Sell_Formula = UIDefine.DonateEquipAndPetData["Equip_Sell_Formula"]
    equipEnhanceLevel = UIDefine.DonateEquipAndPetData["equipEnhanceLevel"]                 --高品质装备强化等级
    petStar_HighQuality = UIDefine.DonateEquipAndPetData["petStar_HighQuality"]             --高品质宠物星级
    petSkillCount_HighQuality = UIDefine.DonateEquipAndPetData["petSkillCount_HighQuality"] --高品质宠物技能数量
    SpecialDonateList = UIDefine.DonateEquipAndPetData["SpecialDonateList"]
    -- local inspect = require("inspect")
    -- test(inspect(SpecialDonateList))
    --equipExploit = DonateUI.EquipExploit
    --equipExploit = DonateUI.EquipExploit
end

function DonateUI.CreateEquipPage()
    local wnd = GUI.GetWnd("DonateUI")
    local panelBg = GUI.GetChild(wnd,"panelBg")
    local tabPage1 = GUI.GroupCreate(panelBg, "tabPage1", -185, 14, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg));
    _gt.BindName(tabPage1, "tabPage1");
    local itemScroll = GUI.LoopScrollRectCreate(tabPage1, "itemScroll", 0, 0, 620, 528,
            "DonateUI", "CreateItemIconPool", "DonateUI", "RefreshItemScroll", 0, false, Vector2.New(80, 80), 7, UIAroundPivot.Top, UIAnchor.Top);
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(10, 10));
    _gt.BindName(itemScroll, "itemScroll");
end

function DonateUI.CreatePetPage()
    local wnd = GUI.GetWnd("DonateUI")
    local panelBg = GUI.GetChild(wnd,"panelBg")
    local tabPage2 = GUI.GroupCreate(panelBg, "tabPage2", -185, 14, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg));
    _gt.BindName(tabPage2, "tabPage2");
    local petScroll = GUI.LoopScrollRectCreate(tabPage2, "petScroll", 0, 0, 649, 528,
            "DonateUI", "CreatPetItemPool", "DonateUI", "RefreshItemScroll", 0, false, Vector2.New(320, 180), 2, UIAroundPivot.Top, UIAnchor.Top);
    GUI.ScrollRectSetChildSpacing(petScroll, Vector2.New(10, 10));
    _gt.BindName(petScroll, "petScroll");
end

-- 创建选中道具信息
function DonateUI.CreateSelectItemArea()
    local wnd = GUI.GetWnd("DonateUI")
    local panelBg = GUI.GetChild(wnd,"panelBg")

    local itemSelectedInfoBg = GUI.ImageCreate(panelBg,"itemSelectedInfoBg", "1800400200", 773, 64, false, 338, 431)
    _gt.BindName(itemSelectedInfoBg,"itemSelectedInfoBg")
    UILayout.SetSameAnchorAndPivot(itemSelectedInfoBg, UILayout.TopLeft)

    local equipInfo = GUI.GroupCreate(itemSelectedInfoBg,"equipInfo",0,0,GUI.GetWidth(itemSelectedInfoBg), GUI.GetHeight(itemSelectedInfoBg))
    
    --图标
    local itemIcon = ItemIcon.Create(equipInfo, "itemIcon", 12, 14)
    UILayout.SetSameAnchorAndPivot(itemIcon, UILayout.TopLeft)
    GUI.SetIsRaycastTarget(itemIcon, false)
    
    -- 道具名称
    local itemName = GUI.CreateStatic(equipInfo,"itemName", "", 105, 15, 222, 30, "system", true, false)
    UILayout.SetSameAnchorAndPivot(itemName, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(itemName, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)
    
    -- 强化等级
    local enhanceText = GUI.CreateStatic(equipInfo,"enhanceText", "+20", 175, 15, 222, 30, "system", true, false)
    UILayout.SetSameAnchorAndPivot(enhanceText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(enhanceText, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)
    
    -- 道具类型
    local itemType = GUI.CreateStatic(equipInfo,"itemType", "类型：", 105, 45, 222, 30, "system", true, false)
    UILayout.SetSameAnchorAndPivot(itemType, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(itemType, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local itemTypeText = GUI.CreateStatic(equipInfo,"itemTypeText", "重剑", 175, 45, 222, 30, "system", true, false)
    UILayout.SetSameAnchorAndPivot(itemTypeText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(itemTypeText, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    -- 道具等级
    local itemLevel = GUI.CreateStatic(equipInfo,"itemLevel", "等级需求：", 105, 75, 222, 30, "system", true, false)
    UILayout.SetSameAnchorAndPivot(itemLevel, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(itemLevel, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local itemLevelText = GUI.CreateStatic(equipInfo,"itemLevelText", "120", 225, 75, 222, 30, "system", true, false)
    UILayout.SetSameAnchorAndPivot(itemLevelText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(itemLevelText, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    -- 道具限制
    local itemRole = GUI.CreateStatic(equipInfo,"itemRole", "所需角色：", 15, 105, 300, 30, "system", true, false)
    UILayout.SetSameAnchorAndPivot(itemRole, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(itemRole, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local itemRoleText = GUI.CreateStatic(equipInfo,"itemRoleText", "她她她 杀杀杀", 135, 105, 300, 30, "system", true, false)
    UILayout.SetSameAnchorAndPivot(itemRoleText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(itemRoleText, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local petInfo = GUI.GroupCreate(itemSelectedInfoBg,"petInfo",0,0,GUI.GetWidth(itemSelectedInfoBg), GUI.GetHeight(itemSelectedInfoBg))

    --详情按钮
    local tipBtn = GUI.ButtonCreate(petInfo,"tipBtn", "1800702060", 291, 6, Transition.ColorTint, "")
    -- petPreviewBtn = GUI.ButtonCreate(detailNode,"petPreviewBtn", "1800702060", 1055,70, Transition.ColorTint, "")
    UILayout.SetSameAnchorAndPivot(tipBtn, UILayout.TopLeft)
    GUI.RegisterUIEvent(tipBtn, UCE.PointerClick , "DonateUI", "OnItemDetailBtnClick")

    --图标
    local itemIcon = ItemIcon.Create(petInfo, "itemIcon", 12, 14)
    UILayout.SetSameAnchorAndPivot(itemIcon, UILayout.TopLeft)
    GUI.SetIsRaycastTarget(itemIcon, false)

    -- 道具名称
    local itemName = GUI.CreateStatic(petInfo,"itemName", "", 105, 15, 222, 30, "system", true, false)
    UILayout.SetSameAnchorAndPivot(itemName, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(itemName, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local cutLine = GUI.ImageCreate(petInfo,"cutLine" ,"1800400310",-3,-100,false,333,3);
    UILayout.SetSameAnchorAndPivot(cutLine, UILayout.Center)

    -- 道具描述
    local itemSelectDescScroll = GUI.ScrollRectCreate(petInfo,"itemSelectDescScroll", 17, 124, 300, 270, 0, false, Vector2.New(300, 270), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    UILayout.SetSameAnchorAndPivot(itemSelectDescScroll, UILayout.TopLeft)
    GUI.ScrollRectSetChildAnchor(itemSelectDescScroll, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(itemSelectDescScroll, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(itemSelectDescScroll, Vector2.New(0, 0))

    local itemSelectDesc = GUI.CreateStatic(itemSelectDescScroll,"itemSelectDesc", "", 0, 0, 300, 270, "system", false, false)
    UILayout.SetSameAnchorAndPivot(itemSelectDesc, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(itemSelectDesc, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.UpperLeft)
    GUI.SetVisible(equipInfo,false)
    GUI.SetVisible(petInfo,false)
    
    -- 花费/售价
    local costLabel = GUI.CreateStatic(panelBg,"costLabel", "获得", 782, 515, 80, 40, "system", false, false)
    UILayout.SetSameAnchorAndPivot(costLabel, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(costLabel, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)
    
    local costBg = GUI.ImageCreate(panelBg,"costBg", "1800900040", 852, 518, false, 255, 36)
    UILayout.SetSameAnchorAndPivot(costBg, UILayout.TopLeft)

    local costIcon = GUI.ImageCreate(costBg,"costIcon", "1801208050", 6, -2, false, 40, 40)
    UILayout.SetSameAnchorAndPivot(costIcon, UILayout.Left)

    local cost = GUI.CreateStatic(costBg,"cost", "", 46, -2, 180, 40, "system", false, false)
    UILayout.SetSameAnchorAndPivot(cost, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(cost, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
end

function DonateUI.CreateItemIconPool()
    local itemScroll = _gt.GetUI("itemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll) + 1
    local itemicon = ItemIcon.Create(itemScroll, "itemIcon"..curCount, 0, 0)
    local ItemSelected = GUI.ImageCreate(itemicon,"ItemSelected", "1800600160", -1, -1, false, 80, 80)
    GUI.SetVisible(ItemSelected,false)
    local ReduceCountBtn = GUI.ButtonCreate(itemicon,"reduceBtn", "1800702070", 28, -28, Transition.ColorTint, "");
    GUI.RegisterUIEvent(ReduceCountBtn, UCE.PointerClick, "DonateUI", "OnClickReduceBtn");
    GUI.SetVisible(ReduceCountBtn, false);
    local count = GUI.CreateStatic(itemicon,"count", "1", -5, 0, 140, 30, "system", false, false)
    -- 计数添加黑边
    GUI.StaticSetFontSize(count, UIDefine.FontSizeSS)
    GUI.StaticSetAlignment(count, TextAnchor.MiddleRight)
    GUI.SetIsOutLine(count, true)
    GUI.SetOutLine_Color(count, Color.New(0/255,0/255,0/255,255/255))
    GUI.SetOutLine_Distance(count, 1)
    GUI.SetColor(count, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
    UILayout.SetSameAnchorAndPivot(count, UILayout.BottomRight)
    -- UILayout.SetSameAnchorAndPivot(count, UILayout.BottomRight)
    -- UILayout.StaticSetFontSizeColorAlignment(count, UIDefine.FontSizeSSS, UIDefine.WhiteColor, TextAnchor.MiddleRight)
    -- GUI.SetOutLine_Color(count, Color.New(0/255,0/255,0/255,255/255))
    -- GUI.SetOutLine_Distance(count, 1)
    -- GUI.SetColor(count, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
    -- GUI.SetVisible(count, false)

    GUI.RegisterUIEvent(itemicon, UCE.PointerClick, "DonateUI", "OnItemClick");
    return itemicon
end

function DonateUI.CreatPetItemPool()
    local petScroll = _gt.GetUI("petScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(petScroll) + 1
    local petItem = GUI.ItemCtrlCreate(petScroll, "petitem"..curCount, "1800400460", 0, 0)
    local ItemSelected = GUI.ImageCreate(petItem,"ItemSelected", "1800400461", 0,0)
    GUI.SetVisible(ItemSelected,false)
    
    --价格组件
    local coinBg = GUI.ImageCreate(petItem,"coinBg", "1800400450", 12, 131, false, 300, 38)
    UILayout.SetSameAnchorAndPivot(coinBg, UILayout.TopLeft)

    local coinIcon = GUI.ImageCreate(coinBg,"coinIcon", "1801208060", 86, -2, false, 40, 40)
    UILayout.SetSameAnchorAndPivot(coinIcon, UILayout.TopLeft)
    
    local priceText = GUI.CreateStatic(coinBg,"priceText", "单价:", 20, 8, 100, 30, "system", true,false)
    UILayout.SetSameAnchorAndPivot(priceText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(priceText, UIDefine.FontSizeS, UIDefine.BrownColor, nil)

    local price = GUI.CreateStatic(coinBg,"price", "12345678", 134, 5, 140, 30, "system", false, false)
    UILayout.SetSameAnchorAndPivot(price, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(price, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    
    --数量组件
    local countBg = GUI.ImageCreate(petItem,"countBg", "1800400450", 12, 95, false, 300, 38)
    UILayout.SetSameAnchorAndPivot(countBg, UILayout.TopLeft)

    local countText = GUI.CreateStatic(countBg,"countText", "数量:", 20, 8, 100, 30, "system", true,false)
    UILayout.SetSameAnchorAndPivot(countText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(countText, UIDefine.FontSizeS, UIDefine.BrownColor, nil)

    local count = GUI.CreateStatic(countBg,"count", "12345678", 134, 5, 140, 30, "system", false, false)
    UILayout.SetSameAnchorAndPivot(count, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(count, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    
    --图标
    local itemicon = ItemIcon.Create(petItem, "itemIcon", 8, 10)
    UILayout.SetSameAnchorAndPivot(itemicon, UILayout.TopLeft)

    -- 名字
    local name = GUI.CreateStatic(petItem,"name", "宠物名字", 98, 7, 150, 30, "system", true,false)
    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(name, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

    -- 等级
    local levelText = GUI.CreateStatic(petItem,"levelText", "等级:", 98, 52, 150, 25, "system", true,false)
    UILayout.SetSameAnchorAndPivot(levelText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(levelText, UIDefine.FontSizeS, UIDefine.BrownColor, nil)

    local level = GUI.CreateStatic(petItem,"level", "1234", 156, 52, 150, 25, "system", true,false)
    UILayout.SetSameAnchorAndPivot(level, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(level, UIDefine.FontSizeS, UIDefine.BrownColor, nil)

    -- 战力
    local petFightText = GUI.CreateStatic(petItem,"petFightText", "战力:", 204, 52, 150, 25, "system", true,false)
    UILayout.SetSameAnchorAndPivot(petFightText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(petFightText, UIDefine.FontSizeS, UIDefine.BrownColor, nil)

    local petFight = GUI.CreateStatic(petItem,"petFight", "1234", 260, 52, 150, 25, "system", true,false)
    UILayout.SetSameAnchorAndPivot(petFight, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(petFight, UIDefine.FontSizeS, UIDefine.BrownColor, nil)

    --减号按钮
    local reduceCountBtn = GUI.ButtonCreate(petItem,"reduceCountBtn", "1800702070", 143, -74, Transition.ColorTint, "");
    GUI.SetVisible(reduceCountBtn, false)

    local reduceBtn = GUI.ButtonCreate(petItem,"reduceBtn", "1800400220", 0, 0, Transition.None, "",320,180,false);
    GUI.RegisterUIEvent(reduceBtn , UCE.PointerClick , "DonateUI", "OnClickReduceBtn" )
    GUI.SetColor(reduceBtn, Color.New(1,1,1,0))
    GUI.SetVisible(reduceBtn, false);
    
    GUI.RegisterUIEvent(petItem, UCE.PointerClick, "DonateUI", "OnItemClick");
    return petItem
end

function DonateUI.RefreshItemScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if item then
        if DonateUI.tabIndex == 1 then
            DonateUI.SetEquipItemData(item,index)
        else
            DonateUI.SetPetItemData(item,index)
        end
    end
end

function DonateUI.SetEquipItemData(Item,index)
    local itemGuid = nil
    local count = GUI.GetChild(Item,"count")
    if index <= #equipList then
        itemGuid = equipList[index]
        ItemIcon.BindItemGuid(Item,itemGuid)
        GUI.SetVisible(count,true)
        if DonateUI.IsEquipHighQuality(itemGuid) then
            GUI.ItemCtrlSetElementValue(Item, eItemIconElement.LeftTopSp, 1801507170);
            GUI.ItemCtrlSetElementRect(Item, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
        end
        -- 查看当前元素是否被选中
        DonateUI.SelectItem(Item,equipList[index])
    else
        ItemIcon.SetEmpty(Item)
        GUI.SetVisible(count,false)
    end
end

function DonateUI.SetPetItemData(item,index)
    if not item then
        return
    end
    local icon = GUI.GetChild(item,"itemIcon")
    local name = GUI.GetChild(item,"name")
    local level = GUI.GetChild(item,"level")
    local petFight = GUI.GetChild(item,"petFight")
    local count = GUI.GetChildByPath(item,"countBg/count")
    local price = GUI.GetChildByPath(item,"coinBg/price")
    
    local petGuid = tostring(petList[index])
    local petData = LD.GetPetData(petGuid)
    local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)));
    
    if petId > 0 then
        local petDB = DB.GetOncePetByKey1(petId)
        ItemIcon.BindPetDB(icon,petDB)
        local star =LD.GetPetIntCustomAttr("PetStarLevel",petGuid,pet_container_type.pet_container_panel)
        UILayout.SetSmallStars(star, 6, icon)
        GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Grade])
        
        if DonateUI.IsPetHighQuality(petGuid) then
            GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp, 1801507170);
            GUI.ItemCtrlSetElementRect(icon, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
        end
        
        GUI.StaticSetText(name,petDB.Name)
        
        local petLevel = petData:GetIntAttr(RoleAttr.RoleAttrLevel)
        GUI.StaticSetText(level,petLevel)
        
        local fightValue = tostring(LD.GetPetAttr(RoleAttr.RoleAttrFightValue,petGuid))
        GUI.StaticSetText(petFight,fightValue)
        GUI.StaticSetText(count,"0".."/"..1)
        
        local petValue = DonateUI.GetPetValue(petDB)
        GUI.StaticSetText(price,petValue)

        -- 查看当前元素是否被选中
        DonateUI.SelectItem(item,petList[index])
    end
end

-- 查看装备强化等级，是否为高品质
function DonateUI.IsEquipHighQuality(itemGuid)
    local itemData = LD.GetItemDataByGuid(itemGuid)
    local enhanceLv = itemData:GetIntCustomAttr(LogicDefine.EnhanceLv)
    if enhanceLv >= equipEnhanceLevel  then
        return true
    end
    return false
end

-- 查看宠物技能，星级，是否为高品质
function DonateUI.IsPetHighQuality(petGuid)
    local skillCount = LD.GetPetSkillCount(petGuid)
    if skillCount >= petSkillCount_HighQuality then
        return true
    end
    local star =LD.GetPetIntCustomAttr("PetStarLevel",petGuid)
    if star >= petStar_HighQuality then
        return true
    end
    return false
end

function DonateUI.SelectItem(item,itemGuid)
    local ItemSelected = GUI.GetChild(item,"ItemSelected")
    local reduceBtn = GUI.GetChild(item,"reduceBtn")
    if DonateUI.tabIndex == 1 then
        local count = GUI.GetChild(item,"count")
        if DonateUI.SelectValue(equipSelectedList,itemGuid) then
            GUI.SetVisible(ItemSelected,true)
            GUI.SetVisible(reduceBtn,true)
            GUI.StaticSetText(count,"1".."/"..1)
        else
            GUI.SetVisible(ItemSelected,false)
            GUI.SetVisible(reduceBtn,false)
            GUI.StaticSetText(count,"1")
        end
    else
        local count = GUI.GetChildByPath(item,"countBg/count")
        local reduceCountBtn = GUI.GetChild(item,"reduceCountBtn")
        if DonateUI.SelectValue(petSelectedList,itemGuid) then
            GUI.SetVisible(ItemSelected,true)
            GUI.SetVisible(reduceBtn,true)
            GUI.SetVisible(reduceCountBtn,true)
            GUI.StaticSetText(count,"1".."/"..1)
        else
            GUI.SetVisible(ItemSelected,false)
            GUI.SetVisible(reduceBtn,false)
            GUI.SetVisible(reduceCountBtn,false)
            GUI.StaticSetText(count,"0".."/"..1)
        end
    end
    
end

-- 展示选中项的信息
function DonateUI.ShowItemSelectedInfo()
    
    local wnd = GUI.GetWnd("DonateUI")
    local panelBg = GUI.GetChild(wnd,"panelBg")
    local itemInfoBg = GUI.GetChild(panelBg,"itemSelectedInfoBg")
    local costBg = GUI.GetChild(panelBg,"costBg")
    local costIcon = GUI.GetChild(costBg,"costIcon")
    local cost = GUI.GetChild(costBg,"cost")
    
    local costNum = nil
    if DonateUI.tabIndex == 1 then
        GUI.ImageSetImageID(costIcon,"1801208050")
        if #equipSelectedList == 0 then
            GUI.SetVisible(itemInfoBg,false)
            costNum = 0
        else
            GUI.SetVisible(itemInfoBg,true)
            costNum = DonateUI.GetEquipSelectedCost(equipSelectedList)
            DonateUI.SetEquipInfo(itemInfoBg)
        end
    else
        GUI.ImageSetImageID(costIcon,"1801208060")
        if #petSelectedList == 0 then
            GUI.SetVisible(itemInfoBg,false)
            costNum = 0
        else
            GUI.SetVisible(itemInfoBg,true)
            costNum = DonateUI.GetPetSelectedCost(petSelectedList)
            DonateUI.SetPetInfo(itemInfoBg)
        end
    end
    GUI.StaticSetText(cost,costNum)
end

-- 设置宠物基础信息
function DonateUI.SetPetInfo(itemInfoBg)
    local itemGuid = nil
    local itemDB = nil
    local equipInfo = GUI.GetChild(itemInfoBg,"equipInfo")
    local petInfo = GUI.GetChild(itemInfoBg,"petInfo")
    GUI.SetVisible(equipInfo,false)
    GUI.SetVisible(petInfo,true)
    local itemName = GUI.GetChild(petInfo,"itemName")
    local itemIcon = GUI.GetChild(petInfo,"itemIcon")
    local tipBtn = GUI.GetChild(petInfo,"tipBtn")
    local itemSelectDescScroll = GUI.GetChild(petInfo,"itemSelectDescScroll")
    local itemSelectDesc = GUI.GetChild(itemSelectDescScroll,"itemSelectDesc")
    itemGuid = tostring(petSelectedList[#petSelectedList])
    local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, itemGuid)));
    itemDB = DB.GetOncePetByKey1(petId)
    ItemIcon.BindPetDB(itemIcon,itemDB)
    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,UIDefine.PetItemIconBg3[itemDB.Type])
    GUI.StaticSetText(itemName,itemDB.Name)
    GUI.StaticSetText(itemSelectDesc,itemDB.Info)
    GUI.ScrollRectSetNormalizedPosition(itemSelectDescScroll,Vector2.New(0,1))
    GUI.SetData(tipBtn,"itemGuid",itemGuid)
end

-- 设置装备信息
function DonateUI.SetEquipInfo(itemInfoBg)
    local itemGuid = nil
    local itemDB = nil
    local itemData = nil
    local equipInfo = GUI.GetChild(itemInfoBg,"equipInfo")
    local petInfo = GUI.GetChild(itemInfoBg,"petInfo")
    local itemName = GUI.GetChild(equipInfo,"itemName")
    local itemIcon = GUI.GetChild(equipInfo,"itemIcon")
    local enhanceText = GUI.GetChild(equipInfo,"enhanceText")
    local itemTypeText = GUI.GetChild(equipInfo,"itemTypeText")
    local itemLevel = GUI.GetChild(equipInfo,"itemLevel")
    local itemLevelText = GUI.GetChild(equipInfo,"itemLevelText")
    local itemRole = GUI.GetChild(equipInfo,"itemRole")
    local itemRoleText = GUI.GetChild(equipInfo,"itemRoleText")
    local cutLine = GUI.GetChild(equipInfo,"cutLine")
    if cutLine then
        GUI.Destroy(cutLine)
    end
    GUI.SetVisible(equipInfo,true)
    GUI.SetVisible(petInfo,false)
    
    itemGuid = tostring(equipSelectedList[#equipSelectedList])
    ItemIcon.BindItemGuid(itemIcon,itemGuid)
    itemData = LD.GetItemDataByGuid(itemGuid)
    itemDB = DB.GetOnceItemByKey1(itemData.id)
    -- 获取强化等级
    local enhanceLv = itemData:GetIntCustomAttr(LogicDefine.EnhanceLv)
    -- 获取装备限制
    local limitName,limitStr,isRed = DonateUI.GetEquipLimit(itemDB)
    local levelStr , levelisRed = DonateUI.GetEquipLevel(itemDB)
    GUI.StaticSetText(itemName,itemDB.Name)
    local w = GUI.StaticGetLabelPreferWidth(itemName)
    GUI.SetWidth(itemName, w)
    GUI.SetPositionX(enhanceText,w + 120)
    if enhanceLv > 0 then
        GUI.StaticSetText(enhanceText,"+" .. enhanceLv)
        GUI.SetColor(enhanceText,UIDefine.EnhanceBlueColor)
    else
        GUI.StaticSetText(enhanceText,"")
    end
    GUI.StaticSetText(itemTypeText,itemDB.ShowType)
    GUI.SetColor(itemTypeText,UIDefine.Yellow2Color)
    GUI.StaticSetText(itemLevelText,levelStr)

    if levelisRed then
        GUI.SetColor(itemLevel,UIDefine.RedColor)
        GUI.SetColor(itemLevelText,UIDefine.RedColor)
    else
        GUI.SetColor(itemLevel,UIDefine.BrownColor)
        GUI.SetColor(itemLevelText,UIDefine.Yellow2Color)
    end
    GUI.StaticSetText(itemRole,limitName)
    GUI.StaticSetText(itemRoleText,limitStr)
    if isRed then
        GUI.SetColor(itemRole,UIDefine.RedColor)
        GUI.SetColor(itemRoleText,UIDefine.RedColor)
    else
        GUI.SetColor(itemRole,UIDefine.BrownColor)
        GUI.SetColor(itemRoleText,UIDefine.Yellow2Color)
    end
    
    local cutLineHeight = -75
    local itemInfoHeight = 150
    if limitName == "" then
        cutLineHeight = cutLineHeight - 25
        itemInfoHeight = itemInfoHeight - 25
    end
    
    local cutLine = GUI.ImageCreate(equipInfo,"cutLine" ,"1800600030",-3,cutLineHeight,false,333,3);
    UILayout.SetSameAnchorAndPivot(cutLine, UILayout.Center)
    
    local itemSelectDescScroll = DonateUI.AddEquipInfoByItemData(equipInfo, itemDB, itemData,limitName)
    GUI.ScrollRectSetNormalizedPosition(itemSelectDescScroll,Vector2.New(0,1))
end

function DonateUI.GetEquipLevel(itemDB)
    local itemLevel=itemDB.Level
    local levelStr = ""
    local isRed = false
    if itemDB.TurnBorn>0 then
        levelStr = levelStr.. itemDB.TurnBorn .. "转"
    end
    levelStr = levelStr.. itemLevel .. "级"
    if CL.GetIntAttr(RoleAttr.RoleAttrReincarnation) == itemDB.TurnBorn then
        if CL.GetIntAttr(RoleAttr.RoleAttrLevel) < itemLevel then
            isRed = true
        end
    elseif CL.GetIntAttr(RoleAttr.RoleAttrReincarnation) < itemDB.TurnBorn then
        isRed = true
    end
    return levelStr , isRed
end

function DonateUI.GetEquipLimit(itemDB)
    local limitName = ""
    local limitStr = ""
    local isRed = false
    if itemDB.Role ~= 0 then
        limitName = "所需角色:"
        local roleDB = DB.GetRole(itemDB.Role)
        local role2 = nil
        if itemDB.Role2 ~= 0 then
            role2 = DB.GetRole(itemDB.Role2)
        end
        if roleDB.Id ~= 0 then
            limitStr =  limitStr.." ".. roleDB.RoleName
        end
        if role2 then
            limitStr = limitStr.." "..role2.RoleName
        end
        local roleid = CL.GetRoleTemplateID()
        if  roleid~= itemDB.Role and roleid ~= itemDB.Role2 then
            isRed = true
        end
    elseif itemDB.Job ~= 0 then
        local schoolDB = DB.GetSchool(itemDB.Job)
        if schoolDB.Id ~= 0 then
            limitName = "所需门派："
            limitStr = schoolDB.Name
        end
        if CL.GetIntAttr(RoleAttr.RoleAttrJob1) ~= itemDB.Job then
            isRed = true
        end
    elseif itemDB.Sex ~= 0 then
        limitName = "所需性别："
        limitStr = UIDefine.GetSexName(itemDB.Sex)
        if CL.GetIntAttr(RoleAttr.RoleAttrGender) ~= itemDB.Sex then
            isRed = true
        end
    end
    return limitName,limitStr,isRed
end

function DonateUI.InfoAddLabel(parent,name,x,y,value)
    local label = GUI.CreateStatic(parent,name, value, x, y, 300, 150, "system", false, false)
    UILayout.SetSameAnchorAndPivot(label, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(label, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.UpperLeft)
    local h = GUI.StaticGetLabelPreferHeight(label)
    GUI.SetHeight(label,h)
    return label
end

function DonateUI.InfoAddCutLine(parent,h)
    local cutLine = GUI.ImageCreate(parent,"cutLine" ,"1800600030",-5,h + 6,false,300,3);
    UILayout.SetSameAnchorAndPivot(cutLine, UILayout.TopLeft)
end

function DonateUI.AddEquipInfoByItemData(equipInfo, itemDB, itemData,text)
    local itemSelectDescScroll = GUI.GetChild(equipInfo,"itemSelectDescScroll")
    local itemInfoY = 150
    local itemInfoHeight = 270
    if text == "" then
        itemInfoY = itemInfoY -25
        itemInfoHeight = itemInfoHeight + 25
    end
    if itemSelectDescScroll ~= nil then
        GUI.Destroy(itemSelectDescScroll)
    end

    local itemSelectDescScroll = GUI.ScrollRectCreate(equipInfo,"itemSelectDescScroll", 17, itemInfoY, 300, itemInfoHeight, 
            0, false, Vector2.New(300, itemInfoHeight), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    UILayout.SetSameAnchorAndPivot(itemSelectDescScroll, UILayout.TopLeft)
    GUI.ScrollRectSetChildAnchor(itemSelectDescScroll, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(itemSelectDescScroll, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(itemSelectDescScroll, Vector2.New(0, 0))

    local itemSelectDesc = GUI.CreateStatic(itemSelectDescScroll,"itemSelectDesc", "", 0, 0, 300, itemInfoHeight, "system", false, false)
    
    local Height = 0
    
    if not itemData then
        return
    end
    ---@type enhanceDynAttrData[]
    local showSpCnt = 1
    
    if
    itemData:GetIntCustomAttr(LogicDefine.ITEM_SPAttrNum) > 0 and
            itemData:GetIntCustomAttr(LogicDefine.ITEM_SPAttrSh .. showSpCnt) > 0
    then
        local cname = itemData:GetStrCustomAttr(LogicDefine.ITEM_SPAttrNa .. showSpCnt) -- LD.GetItemStrCustomAttrByGuid(LogicDefine.ITEM_SPAttrNa .. showSpCnt, guid, bagtype)
        local val = itemData:GetIntCustomAttr(LogicDefine.ITEM_SPAttrVa .. showSpCnt)
        local itemAttributeDesc = DonateUI.InfoAddLabel(itemSelectDesc,"itemAttributeDesc",0,Height,"基础属性：   <color=#21DDDAB2>" .. cname .. " " .. val .. "</color>")
        local h = GUI.StaticGetLabelPreferHeight(itemAttributeDesc)
        Height = Height + h
    else
        local itemAttributeDesc = DonateUI.InfoAddLabel(itemSelectDesc,"itemAttributeDesc",0,Height,"基础属性：")
        local h = GUI.StaticGetLabelPreferHeight(itemAttributeDesc)
        Height = Height + h
    end
    
    local t = {}
    LogicDefine.GetItemDynAttrDataByMark(itemData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)
    if #t > 0 then
        for i = 1, #t do
            local value = tostring(t[i].value)
            if t[i].Id ~= 0 then
                if t[i].IsPct then
                    value = tostring(tonumber(value) / 100) .. "%"
                end
                local itemAttributeText = DonateUI.InfoAddLabel(itemSelectDesc,"itemAttributeText"..i,35,Height,t[i].name .. "   " .. value)
                local h = GUI.StaticGetLabelPreferHeight(itemAttributeText)
                Height = Height + h
            end
        end
    end

    DonateUI.InfoAddCutLine(itemSelectDesc,Height)
    
    Height = Height + 15

    --强化
    local exv ="强化等级：   "
    local exMax = UIDefine.MaxIntensifyLevel
    local ulongVal = itemData:GetIntCustomAttr(LogicDefine.EnhanceLv)
    local enhanceLv, h = int64.longtonum2(ulongVal)
    exv = exv..enhanceLv
    if exMax then
        exv = exv.."/"..exMax
    end
    local itemEnhanceLvText = DonateUI.InfoAddLabel(itemSelectDesc,"itemEnhanceLvText",0,Height,exv)
    local h = GUI.StaticGetLabelPreferHeight(itemEnhanceLvText)
    Height = Height + h
    if #t > 0 and enhanceLv > 0 then
        for i = 1, #t do
            local value = tostring(t[i].exV)
            if t[i].Id ~= 0 and tonumber(value) ~= 0 then
                if t[i].IsPct then
                    value = tostring(tonumber(value) / 100) .. "%"
                end
                local itemEnhanceLv = DonateUI.InfoAddLabel(itemSelectDesc,"itemEnhanceLv"..1,35,Height,t[i].name .. "   " .. value)
                local h = GUI.StaticGetLabelPreferHeight(itemEnhanceLv)
                Height = Height + h
            end
        end
    end
    DonateUI.InfoAddCutLine(itemSelectDesc,Height)
    Height = Height + 15
    
    --强化end

    local dynsAttrType = {LogicDefine.ItemAttrMark.Artifice,LogicDefine.ItemAttrMark.Refiner}
    local str = {"炼化属性: ","炼器属性: "}
    for j = 1, #dynsAttrType do
        -- body
        local dyns11 = itemData:GetDynAttrDataByMark(dynsAttrType[j])
        if dyns11.Count > 0 then
            local dynsAttrTypeText = DonateUI.InfoAddLabel(itemSelectDesc,"dynsAttrTypeText",0,Height,str[j])
            local h = GUI.StaticGetLabelPreferHeight(dynsAttrTypeText)
            Height = Height + h
            for i = 0, dyns11.Count - 1 do
                local attrId = dyns11[i].attr
                local value = tostring(dyns11[i].value)
                local attrDB = DB.GetOnceAttrByKey1(attrId)
                if attrDB.Id ~= 0 then
                    if attrDB.IsPct == 1 then
                        value = tostring(tonumber(value) / 100) .. "%"
                    end
                    local dynsAttrType = DonateUI.InfoAddLabel(itemSelectDesc,"dynsAttrType"..i,35,Height,attrDB.ChinaName .. "   " .. value)
                    local h = GUI.StaticGetLabelPreferHeight(dynsAttrType)
                    Height = Height + h
                end
            end
            DonateUI.InfoAddCutLine(itemSelectDesc,Height)
            Height = Height + 15
        end
    end

    
    local gemCount, siteCount = LogicDefine.GetEquipGemCount(itemData)
    if gemCount > 0 then
        local GemCountText = DonateUI.InfoAddLabel(itemSelectDesc,"GemCountText",0,Height,"宝石镶嵌：    " .. gemCount .. "/" .. siteCount)
        local h = GUI.StaticGetLabelPreferHeight(GemCountText)
        Height = Height + h
        for i = 1, siteCount do
            local gemId = itemData:GetIntCustomAttr(LogicDefine.ITEM_GemId_ .. i)
            if gemId ~= 0 then
                local gemDB = DB.GetOnceItemByKey1(gemId)
                local GemName = DonateUI.InfoAddLabel(itemSelectDesc,"GemName"..i,0,Height,gemDB.Name .. "：")
                local h = GUI.StaticGetLabelPreferHeight(GemName)
                Height = Height + h
                local attrDatas = itemData:GetDynAttrDataByMark(LogicDefine.ITEM_GemAttrMark[i])
                if attrDatas.Count > 0 then
                    local attrData = attrDatas[0]
                    local attrId = attrData.attr
                    local value = attrData.value
                    local GemVal = DonateUI.InfoAddLabel(itemSelectDesc,"GemVal"..i,35,Height,UIDefine.GetAttrDesStr(attrId, value))
                    local h = GUI.StaticGetLabelPreferHeight(GemVal)
                    Height = Height + h
                end
            end
        end
        DonateUI.InfoAddCutLine(itemSelectDesc,Height)
        Height = Height + 15
    end
    
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
            local suitText = DonateUI.InfoAddLabel(itemSelectDesc,"suitText",0,Height,"套装属性：" ..  config.Suit_Name.."("..num.."/"..config.Total..")")
            local h = GUI.StaticGetLabelPreferHeight(suitText)
            Height = Height + h
            for i = 1, config.Total do
                if config.Size[i] then
                    local state="(未激活)"
                    if num>=i then
                        state="(已激活)"
                    end
                    for j = 1, #config.Size[i].Attr do
                        local attrDB = DB.GetOnceAttrByKey2(config.Size[i].Attr[j][1])
                        if attrDB.Id~=0 then
                            local stateVal = DonateUI.InfoAddLabel(itemSelectDesc,"stateVal",0,Height,"["..i.."]"..UIDefine.GetAttrDesStr(attrDB.Id,config.Size[i].Attr[j][2])..state)
                            local h = GUI.StaticGetLabelPreferHeight(stateVal)
                            Height = Height + h
                        end
                    end
                end
            end
            DonateUI.InfoAddCutLine(itemSelectDesc,Height)
            Height = Height + 15
        end
    end

    -- 特技特效
    -- local cname = itemData:GetStrCustomAttr(LogicDefine.Equip_SpecialEffect) -- LD.GetItemStrCustomAttrByGuid(LogicDefine.ITEM_SPAttrNa .. showSpCnt, guid, bagtype)
    -- local val = itemData:GetIntCustomAttr(LogicDefine.ITEM_SPAttrVa .. showSpCnt)
    local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", itemData.guid)
    local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", itemData.guid)
    if Equip_SpecialEffect ~= 0 then
        test(Equip_SpecialEffect)
        local effectTitle = DonateUI.InfoAddLabel(itemSelectDesc,"effectTitle",0,Height,"特效：")
        local effectText = DonateUI.InfoAddLabel(itemSelectDesc,"effectText",70,Height,DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name)
        -- local itemGrade1 = DB.GetOnceSkillByKey1(Equip_SpecialEffect).SkillQuality
        -- GUI.SetColor(effectText, UIDefine.GradeColor[itemGrade1])
        local h = GUI.StaticGetLabelPreferHeight(effectText)
        Height = Height + h
        local effectInfoText = DonateUI.InfoAddLabel(itemSelectDesc,"effectInfoText",0,Height,DB.GetOnceSkillByKey1(Equip_SpecialEffect).Info)
        local h = GUI.StaticGetLabelPreferHeight(effectInfoText)
        Height = Height + h
    end
    if Equip_Stunt ~= 0 then
        test(Equip_Stunt)
        local stuntTitle = DonateUI.InfoAddLabel(itemSelectDesc,"stuntTitle",0,Height,"特技：")
        local stuntText = DonateUI.InfoAddLabel(itemSelectDesc,"stuntText",70,Height,DB.GetOnceSkillByKey1(Equip_Stunt).Name)
        -- local itemGrade2 = DB.GetOnceSkillByKey1(Equip_Stunt).SkillQuality
        -- GUI.SetColor(stuntText, UIDefine.GradeColor[itemGrade2])
        local h = GUI.StaticGetLabelPreferHeight(stuntText)
        Height = Height + h
        local stuntInfoText = DonateUI.InfoAddLabel(itemSelectDesc,"stuntInfoText",0,Height,DB.GetOnceSkillByKey1(Equip_Stunt).Info)
        local h = GUI.StaticGetLabelPreferHeight(stuntInfoText)
        Height = Height + h
    end

    if Equip_SpecialEffect ~= 0 or Equip_Stunt ~= 0 then
        DonateUI.InfoAddCutLine(itemSelectDesc,Height)
        Height = Height + 15
    end
		
		

    --武器耐久度
    --宠物特殊处理
    if itemDB.Subtype == 7 then
        local itemGUID = itemData:GetAttr(ItemAttr_Native.Guid)
        local EquipDurableVal = LD.GetItemIntCustomAttrByGuid("EquipDurableVal",itemGUID)
        local EquipDurableMax = LD.GetItemIntCustomAttrByGuid("EquipDurableMax",itemGUID)
        if EquipDurableMax ~= nil then
            if EquipDurableMax == 0 then
                EquipDurableVal = "无限"
                EquipDurableMax = "无限"
            end
            local durableText = DonateUI.InfoAddLabel(itemSelectDesc,"durableText",0,Height,"耐久度：" .. EquipDurableVal .. "/" .. EquipDurableMax)
            local h = GUI.StaticGetLabelPreferHeight(durableText)
            Height = Height + h
        end
    else
        local DurableNow = itemData:GetIntCustomAttr("DurableNow")
        local DurableMax = itemData:GetIntCustomAttr("DurableMax")
        if DurableMax ~= nil then
            if DurableMax == 0 then
                DurableNow = "无限"
                DurableMax = "无限"
            end
            local durableText = DonateUI.InfoAddLabel(itemSelectDesc,"durableText",0,Height,"耐久度：" .. DurableNow .. "/" .. DurableMax)
            local h = GUI.StaticGetLabelPreferHeight(durableText)
            Height = Height + h
        end
    end
    -- 出售价
    local costNum = DonateUI.GetEquipValue(itemDB)
    local costText = DonateUI.InfoAddLabel(itemSelectDesc,"costText",0,Height,"出售价：" .. "    " .. costNum)
    local costIcon = GUI.ImageCreate(costText,"costIcon", "1801208050", 80, 0, false, 26, 26)
    UILayout.SetSameAnchorAndPivot(costIcon, UILayout.Left)
    local h = GUI.StaticGetLabelPreferHeight(costText)
    Height = Height + h
    DonateUI.InfoAddCutLine(itemSelectDesc,Height)
    Height = Height + 15
    local itemInfo = DonateUI.InfoAddLabel(itemSelectDesc,"itemInfo",0,Height,itemDB.Tips)
    local h = GUI.StaticGetLabelPreferHeight(itemInfo)
    Height = Height + h
    if itemInfoHeight < Height then
        GUI.ScrollRectSetChildSize(itemSelectDescScroll,Vector2.New(300, Height))
    end
    return itemSelectDescScroll
end

-- 获取选中的装备的总价值
function DonateUI.GetEquipSelectedCost(list)
    local itemGuid = nil
    local itemData = nil
    local itemDB = nil
    local costNum = 0
    for i , v in ipairs(list) do
        itemGuid = tostring(v)
        itemData = LD.GetItemDataByGuid(itemGuid)
        itemDB = DB.GetOnceItemByKey1(itemData.id)
        costNum = costNum + DonateUI.GetEquipValue(itemDB)
    end
    return costNum
end

-- 获取选中的宠物的总价值
function DonateUI.GetPetSelectedCost(list)
    local itemGuid = nil
    local itemDB = nil
    local costNum = 0
    for i , v in ipairs(list) do
        itemGuid = tostring(v)
        local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, itemGuid)));
        itemDB = DB.GetOncePetByKey1(petId)
        costNum = costNum + DonateUI.GetPetValue(itemDB)
    end
    return costNum
end

-- 点击物品图标
function DonateUI.OnItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local itemIndex = GUI.ItemCtrlGetIndex(item) + 1
    if item ~= nil then
        if DonateUI.tabIndex == 1 then
            if DonateUI.SelectValue(equipSelectedList,equipList[itemIndex]) then
                CL.SendNotify(NOTIFY.ShowBBMsg, "无法增加出售数量，一次性只能出售1个")
                DonateUI.remove(equipSelectedList,equipList[itemIndex])
            end
            DonateUI.insert(equipSelectedList,equipList[itemIndex])
            DonateUI.SetEquipItemData(item,itemIndex)
        else
            if DonateUI.SelectValue(petSelectedList,petList[itemIndex]) then
                CL.SendNotify(NOTIFY.ShowBBMsg, "无法增加出售数量，一次性只能出售1个")
                DonateUI.remove(petSelectedList,petList[itemIndex])
            end
            DonateUI.insert(petSelectedList,petList[itemIndex])
            DonateUI.SetPetItemData(item,itemIndex)
        end
    end
    DonateUI.SetPageInfo()
end

function DonateUI.SetPageInfo()
    DonateUI.SetSelectAllBtnText()
    DonateUI.SetRepayBtn()
    DonateUI.ShowItemSelectedInfo()
end

-- 点击减号图标
function DonateUI.OnClickReduceBtn(guid)
    local reduceBtn = GUI.GetByGuid(guid)
    local item = GUI.GetParentElement(reduceBtn)
    local itemIndex = GUI.ItemCtrlGetIndex(item) + 1
    if item ~= nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "已取消捐献该商品");
        if DonateUI.tabIndex == 1 then
            DonateUI.remove(equipSelectedList,equipList[itemIndex])
            DonateUI.SetEquipItemData(item,itemIndex)
        else
            DonateUI.remove(petSelectedList,petList[itemIndex])
            DonateUI.SetPetItemData(item,itemIndex)
        end
    end
    DonateUI.SetPageInfo()
end

-- 查询值是否存在
function DonateUI.SelectValue(list,val)
    for i , v in pairs(list) do
        if v == val then
            return true;
        end
    end
    return false
end

-- 插入guid
function DonateUI.insert(list,val)
    if not DonateUI.SelectValue(list,val) then
        table.insert(list,val)
    end
end

-- 删除guid
function DonateUI.remove(list,val)
    for i , v in ipairs(list) do
        if v == val then
            table.remove(list,i)
        end
    end
end

function DonateUI.RefreshEquipPage()
    local itemScroll = _gt.GetUI("itemScroll")
    local capacity = LD.GetBagCapacity(item_container_type.item_container_bag);
    GUI.LoopScrollRectSetTotalCount(itemScroll, capacity);
    GUI.LoopScrollRectRefreshCells(itemScroll);
end

function DonateUI.RefreshPetPage()
    local petScroll = _gt.GetUI("petScroll")
    local count = #petList
    GUI.LoopScrollRectSetTotalCount(petScroll, count);
    GUI.LoopScrollRectRefreshCells(petScroll);
end

function DonateUI.OnEquipTabBtnClick()
    DonateUI.tabIndex = 1
    DonateUI.Refresh()
end

function DonateUI.OnPetTabBtnClick()
    DonateUI.tabIndex = 2
    DonateUI.Refresh()
end

function DonateUI.OnItemDetailBtnClick(guid)
    local tipBtn = GUI.GetByGuid(guid)
    local itemGuid = GUI.GetData(tipBtn,"itemGuid")
    GUI.OpenWnd("PetInfoUI","2,"..tostring(itemGuid))
end

-- 获取宠物价值
function DonateUI.GetPetValue(petDB)
    local cost = 0
    if SpecialDonateList[petDB.KeyName] then
        cost = tonumber(SpecialDonateList[petDB.KeyName].DonatePrice)
    elseif Pet_Sell_Formula and petDB then
        local Type = petDB.Type
        local carrylevel = petDB.CarryLevel
        local str =[[
        carrylevel = ]] .. carrylevel .. [[
        Type = ]]..Type..[[
        ]]
        cost = assert(loadstring(str.."return "..Pet_Sell_Formula))()
        if cost then
            cost = math.floor(cost)
            if  cost < 0 then
                cost = 0
            end
        else
            test("价格公式解析错误。")
        end
        --        test("捐献装备价格: "..cost)
    else
        test("Pet_Sell_Formula is nil")
    end
    return cost
end

-- 获取装备价值
function DonateUI.GetEquipValue(itemDB)
    local cost = 0
    if SpecialDonateList[itemDB.KeyName] then
        cost = tonumber(SpecialDonateList[itemDB.KeyName].DonatePrice)
    elseif Equip_Sell_Formula and itemDB then
        local level = itemDB.Level
        local Grade = itemDB.Grade
        local BuyGoldBind = itemDB.BuyGoldBind
        local str = [[
        level = ]]..level..[[
        Grade = ]]..Grade..[[
        BuyGoldBind = ]]..BuyGoldBind..[[
        ]]
        cost = assert(loadstring(str.."return "..Equip_Sell_Formula))()
        if cost then
            cost = math.floor(cost)
            if  cost < 0 then
                cost = 0
            end
        else
            test("价格公式解析错误。")
        end
        --        test("捐献装备价格: "..cost)
    else
        test("Donate_Equip_Sell_Formula is nil")
    end
    return cost
end

-- 获取装备列表
function DonateUI.GetEquipList()
    local bagType = item_container_type.item_container_bag;
    local itemCount = LD.GetItemCount(bagType)
    for i = 0 , itemCount-1 do
        local itemData = LD.GetItemDataByItemIndex(i, bagType)
        local itemDB = DB.GetOnceItemByKey1(itemData.id)
        -- 查询是否是属于特殊的捐献列表
        if SpecialDonateList[itemDB.KeyName] then
            table.insert(equipList,itemData.guid)
        -- 所有不是白装的装备
        elseif itemDB.Type == EquipConfig["item_Type"] then
            if DonateUI.HaveType(true,itemDB.Grade) then
                if DonateUI.HaveLevel(itemDB.Level) then
                    table.insert(equipList,itemData.guid)
                end
            end
        end
    end
end

-- 装备列表排序
function DonateUI.EquipListSort(guid1,guid2)
    local itemData1 = LD.GetItemDataByGuid(tostring(guid1))
    local itemDB1 = DB.GetOnceItemByKey1(itemData1.id)
    local costNum1 = DonateUI.GetEquipValue(itemDB1)

    local itemData2 = LD.GetItemDataByGuid(tostring(guid2))
    local itemDB2 = DB.GetOnceItemByKey1(itemData2.id)
    local costNum2 = DonateUI.GetEquipValue(itemDB2)

    if costNum1 == costNum2 then
        return false
    else
        return costNum1 < costNum2
    end
end

-- 宠物列表排序
function DonateUI.PetListSort(guid1,guid2)
    local petId1 = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, tostring(guid1))))
    local itemDB1 = DB.GetOncePetByKey1(petId1)
    local costNum1 = DonateUI.GetPetValue(itemDB1)

    local petId2 = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, tostring(guid2))))
    local itemDB2 = DB.GetOncePetByKey1(petId2)
    local costNum2 = DonateUI.GetPetValue(itemDB2)
    
    if costNum1 == costNum2 then
        return false
    else
        return costNum1 < costNum2
    end
end

--获取宠物列表
function DonateUI.GetPetList()
    local guids = LD.GetPetGuids()
    if guids and PetConfig then
        for i = 0, guids.Count-1 do
            local petGuid = tostring(guids[i])
            local canDonate = true
            for m = 0, #UIDefine.NowLineupList, 1 do
                if UIDefine.NowLineupList[m] == petGuid then
                    canDonate = false
                end
            end
            if canDonate then
                local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)))
                local petDB = DB.GetOncePetByKey1(petId)
                -- 查询是否是属于特殊的捐献列表
                if SpecialDonateList[petDB.KeyName] then
                    table.insert(petList,guids[i])
                elseif DonateUI.HaveType(false,petDB.Type) then
                    table.insert(petList,guids[i])
                end
            end
        end
    end
end

-- 是否为对应类型的物品
function DonateUI.HaveType(isEquip,type)
    local typeTable = nil
    if isEquip then
        typeTable = EquipConfig["grade"]
    else
        typeTable = PetConfig["pet_Type"]
    end
    if typeTable == nil then
        test("可捐献类型表为空")
        return false
    end
    for k, v in pairs(typeTable) do
        if type == v then
            return true
        end
    end
    return false
end

-- 道具等级是否符合
function DonateUI.HaveLevel(level)
    if EquipConfig["level"] then
        for key, value in pairs(EquipConfig["level"]) do
            if level == value then
                return true
            end
        end
        return false
    else
        return true
    end
end

function DonateUI.IsEquipHaveGem(guid)
    local itemData = LD.GetItemDataByGuid(tostring(guid))
    local gemCount, siteCount = LogicDefine.GetEquipGemCount(itemData)
    if gemCount > 0 then
        return true
    end
    return false
end

function DonateUI.IsPetHaveEquip(guid)
    local bageType = item_container_type.item_container_pet_equip
    local equipData
    for i , v in pairs(LogicDefine.PetEquipSite) do
        equipData = LD.GetItemDataByIndex(v,bageType,guid)
        if equipData ~= nil then
            return true
        end
    end
    return false
end

-- 捐献物品点击
function DonateUI.OnRepayBtnClick()
    itemGuids = nil
    onceItem = false
    local guid = nil

    local equipHaveGem = false
    local petHaveEquip = false

    local highQualityEquip=false
    local highQualityPet=false
    
    if DonateUI.tabIndex == 1 then
        guid = tostring(equipSelectedList[1])
        itemGuids = guid
        highQualityEquip = DonateUI.IsEquipHighQuality(guid)
        equipHaveGem = DonateUI.IsEquipHaveGem(guid)
        if #equipSelectedList == 1 then
            onceItem = true
        else
            onceItem = false
            for i = 2 , #equipSelectedList do
                guid = tostring(equipSelectedList[i])
                itemGuids = itemGuids .. "-" .. guid
                if equipHaveGem == false then
                    equipHaveGem = DonateUI.IsEquipHaveGem(guid)
                end
                if highQualityEquip == false then
                    highQualityEquip = DonateUI.IsEquipHighQuality(guid)
                end
            end
        end
    elseif DonateUI.tabIndex == 2 then
        guid = tostring(petSelectedList[1])
        itemGuids = guid
        highQualityPet = DonateUI.IsPetHighQuality(guid)
        petHaveEquip = DonateUI.IsPetHaveEquip(guid)
        if #petSelectedList == 1 then
            onceItem = true
        else
            onceItem = false
            for i = 2 , #petSelectedList do
                guid = tostring(petSelectedList[i])
                itemGuids = itemGuids .. "-" .. guid
                if highQualityPet == false then
                    highQualityPet = DonateUI.IsPetHighQuality(guid)
                end
                if petHaveEquip == false then
                    petHaveEquip = DonateUI.IsPetHighQuality(guid)
                end
            end
        end
    end
    if highQualityPet or highQualityEquip or equipHaveGem or petHaveEquip then
        local desc = ""
        if DonateUI.tabIndex == 1 then
            if highQualityEquip then
                desc = "您选中的装备中有高品质道具，是否捐献？"
            else
                desc = "装备上有镶嵌宝石，是否确认捐献？"
            end
        elseif DonateUI.tabIndex == 2 then
            if highQualityPet then
                desc = "您选中的宠物有高品质宠物，是否捐献？"
            else
                desc = "宠物上有宠物装备，是否确认捐献？"
            end
        end
        GlobalUtils.ShowBoxMsg2Btn("捐献提示",desc,"DonateUI","是","OnConfirmDonateOprBtnClick","否")
        return
    end
    
    DonateUI.OnConfirmDonateOprBtnClick()
end

-- 捐献
function DonateUI.OnConfirmDonateOprBtnClick()
    local costNum = nil
    if DonateUI.tabIndex == 1 then
        costNum = DonateUI.GetEquipSelectedCost(equipSelectedList)
        if onceItem then
            CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "DonateOnceItem",itemGuids,costNum)
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "DonateItems",itemGuids,costNum)
        end
    elseif DonateUI.tabIndex == 2 then
        costNum = DonateUI.GetPetSelectedCost(petSelectedList)
        if onceItem then
            CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "DonateOncePet",itemGuids,costNum)
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "DonatePets",itemGuids,costNum)
        end
    end
    DonateUI.Refresh()
end

function DonateUI.Refresh()
    UILayout.OnTabClick(DonateUI.tabIndex, tabList);
    for i = 1, #tabList do
        local page = _gt.GetUI("tabPage" .. i);
        GUI.SetVisible(page, i == DonateUI.tabIndex);
    end
    if DonateUI.tabIndex == 1 then
        equipList = {}
        equipSelectedList = {}
        DonateUI.GetEquipList()
        table.sort(equipList,DonateUI.EquipListSort)
        DonateUI.RefreshEquipPage()
    elseif DonateUI.tabIndex == 2 then
        petList = {}
        petSelectedList = {}
        DonateUI.GetPetList()
        table.sort(petList,DonateUI.PetListSort)
        DonateUI.RefreshPetPage()
    end
    DonateUI.SetPageInfo()
end

-- 设置捐献按钮
function DonateUI.SetRepayBtn()
    local repayBtn = GUI.Get("DonateUI/panelBg/repayBtn")
    if DonateUI.tabIndex == 1 and #equipSelectedList == 0 then
        GUI.ButtonSetShowDisable(repayBtn,false)
    elseif DonateUI.tabIndex == 2 and #petSelectedList == 0 then
        GUI.ButtonSetShowDisable(repayBtn,false)
    else
        GUI.ButtonSetShowDisable(repayBtn,true)
    end
end

-- 设置选中所有按钮文本
function DonateUI.SetSelectAllBtnText()
    local selectAllBtnText = GUI.Get("DonateUI/panelBg/selectAllBtn/selectAllBtnText")
    if DonateUI.tabIndex == 1 and #equipSelectedList == #equipList and #equipList ~= 0 then
        GUI.StaticSetText(selectAllBtnText,"取消选中")
    elseif DonateUI.tabIndex == 2 and #petSelectedList == #petList and #petList ~= 0 then
        GUI.StaticSetText(selectAllBtnText,"取消选中")
    else
        GUI.StaticSetText(selectAllBtnText,"选中所有")
    end
end

function DonateUI.insertList(selectList,itemList)
    for i , v in pairs(itemList) do
        DonateUI.insert(selectList,v)
    end
end

function DonateUI.OnSelectAllBtnClick()
    if DonateUI.tabIndex == 1 then
        if #equipSelectedList == #equipList and #equipList ~= 0 then
            equipSelectedList = {}
        else
            DonateUI.insertList(equipSelectedList,equipList)
        end
        DonateUI.RefreshEquipPage()
    elseif DonateUI.tabIndex == 2 then
        if #petSelectedList == #petList and #petList ~= 0 then
            petSelectedList = {}
        else
            DonateUI.insertList(petSelectedList,petList)
        end
        DonateUI.RefreshPetPage()
    end
    DonateUI.SetPageInfo()
end

function DonateUI.OnExit()
    GUI.DestroyWnd("DonateUI")
end 

function DonateUI.OnShow()
    local wnd = GUI.GetWnd("DonateUI")
    if wnd == nil then
        return ;
    end
    --CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "GetEquipExploit")
    --CL.SendNotify(NOTIFY.SubmitForm, "FormDonateEquipAndPet", "GetPetExploit")
    ----FormDonateEquipAndPet.GetEquipExploit(player)	--获取装备功勋
    ----FormDonateEquipAndPet.GetPetExploit(player)		--获取宠物功勋
    DonateUI.GetDonateEquipAndPetData()
    GUI.SetVisible(wnd,true)
    DonateUI.OnEquipTabBtnClick()
end 