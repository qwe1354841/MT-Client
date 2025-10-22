local EquipRepairUI = {
    ---@type EnhanceInfo
    serverData = {}
}
require "UILayout";
_G.EquipRepairUI =EquipRepairUI
local consumeMax = 4

EquipRepairUI.consumeMax = consumeMax

EquipRepairUI.ClickItemGuid = ""
-- local test = print
local test = function()
end
local guidt = UILayout.NewGUIDUtilTable()
function EquipRepairUI.InitData()
    return {
        type = 1,
        index = 1,
        indexGuid = int64.new(0),
        items = {
            [item_container_type.item_container_equip] = {},
            [item_container_type.item_container_bag] = {}
        },
		checkOn = false
    }
end
local data = EquipRepairUI.InitData()
function EquipRepairUI.OnExitGame()
    data = EquipRepairUI.InitData()
    data.getBagType = function()
        local type = EquipEnhanceUI.typeList[data.type][12]
        return type
    end
end

data.getBagType = function()
    local type = EquipEnhanceUI.typeList[data.type][12]
    return type
end

function EquipRepairUI.RefreshResultInfo(bg, eqiupItemTable)
	test("EquipRepairUI.RefreshResultInfo")
    local EquipRepair = bg or guidt.GetUI("EquipRepair")
	local vbg = GUI.GetChild(EquipRepair, "vbg", false)
    local icon = GUI.GetChild(vbg, "itemIcon", false)
    local name = GUI.GetChild(EquipRepair, "name", false)
    local lv = GUI.GetChild(EquipRepair, "lv", false)
    local equipType = GUI.GetChild(EquipRepair, "equipType", false)
    local uit = {icon, name, lv, equipType}
    for i = 1, #uit do
        GUI.SetVisible(uit[i], true)
    end
    local iteminfo = nil
	local nameTxt, lvTxt, equipTypeTxt = " "
    if eqiupItemTable then
		-- test(eqiupItemTable.name,eqiupItemTable.site)
        if eqiupItemTable.bagtype == item_container_type.item_container_guard_equip and EquipUI.curGuardGuid then
            ItemIcon.BindGuardEquip(icon, EquipUI.curGuardGuid, eqiupItemTable.site)
        else
            ItemIcon.BindIndexForBag(icon, eqiupItemTable.site, eqiupItemTable.bagtype)
        end
		nameTxt = eqiupItemTable.name
		lvTxt = eqiupItemTable.lv .. "级"
		equipTypeTxt = eqiupItemTable.showType
	else
        ItemIcon.BindItemId(icon, nil)
    end
	GUI.StaticSetText(name, nameTxt)
    GUI.StaticSetText(lv, lvTxt)
    GUI.StaticSetText(equipType, equipTypeTxt)
    GUI.SetPositionX(equipType,GUI.StaticGetLabelPreferWidth(lv) + GUI.GetPositionX(lv) + 60)
    if equipTypeTxt and string.find(equipTypeTxt,"无级别") then
        GUI.SetVisible(lv,false)
        GUI.SetPositionX(equipType,GUI.GetPositionX(lv) + 50)
    end
end

function EquipRepairUI.GetData()
    local item = EquipRepairUI.GetItem()
    if item and item.id > 0 and false then
        -- 
        test("GetData " .. tostring(item.guid))
        test("GetData " .. tostring(item.keyname))
        CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "", item.guid)
    else
        EquipRepairUI.ClientRefresh()
    end
end

function EquipRepairUI.OnInEquipBtnClick()
    data.type = 1
    data.index = 1
    EquipRepairUI.ClientRefresh()
end
function EquipRepairUI.OnInBagBtnClick()
    data.type = 2
    data.index = 1
    EquipRepairUI.ClientRefresh()
end

function EquipRepairUI.ClickItem(guid)
    EquipRepairUI.ClickItemGuid = guid
    EquipRepairUI.RefreshUI()
    -- local items = data.items[data.getBagType()]
    -- for index, item in pairs(items) do
    --     if guid == tostring(item.guid) then
    --         data.index = index
    --     end
    -- end
    -- EquipRepairUI.RefreshUI()
end

function EquipRepairUI.RefreshUI()
    local items = data.items[data.getBagType()]
    if EquipRepairUI.ClickItemGuid ~= "" then
		for i = 1, #items, 1 do
            local item = items[i]
            if EquipRepairUI.ClickItemGuid == tostring(item.guid) then
                table.remove(items,i)
                table.insert(items,1,item)
            end
        end
	end
    local scroll = EquipUI.guidt.GetUI("itemScroll")
    GUI.LoopScrollRectSetTotalCount(scroll, #items)
    GUI.LoopScrollRectRefreshCells(scroll)
    local remainder = EquipUI.guidt.GetUI("emptyIamge")
    local remainder_bg = EquipUI.guidt.GetUI("emptyIamgeTxtBg")
    if #items == 0 then
        GUI.SetVisible(remainder,true)
        GUI.SetVisible(remainder_bg,true)
    else
        GUI.SetVisible(remainder,false)
        GUI.SetVisible(remainder_bg,false)
    end
	local normal = EquipRepairUI.GetItem()
	local EquipRepair = guidt.GetUI("EquipRepair")
	local nowbg = GUI.GetChild(EquipRepair, "nowbg", false)
	local maxbg = GUI.GetChild(EquipRepair, "maxbg", false)
	local textNow2 = GUI.GetChild(nowbg, "textNow2", false)
	local textMax2 = GUI.GetChild(maxbg, "textMax2", false)
	local probability = GUI.GetChild(EquipRepair, "probability", true)
	local luckNum = GUI.GetChild(EquipRepair, "luckNum", true)
	if normal == nil then
		GUI.StaticSetText(textNow2, "0")
		GUI.StaticSetText(textMax2, "0")
		GUI.SetVisible(probability, false)
		GUI.SetVisible(luckNum, false)
        EquipRepairUI.RefreshResultInfo(nil, nil, nil)
	else
		local DurableNow = LD.GetItemIntCustomAttrByGuid("DurableNow", normal.guid, normal.bagtype)
		local DurableMax = LD.GetItemIntCustomAttrByGuid("DurableMax", normal.guid, normal.bagtype)
		if DurableMax == 0 then
			GUI.StaticSetText(textNow2, "无限")
			GUI.StaticSetText(textMax2, "无限")
		else
			GUI.StaticSetText(textNow2, DurableNow)
			GUI.StaticSetText(textMax2, DurableMax)
		end
		local realLuckNum = UIDefine.Repair_Rate/100
		if realLuckNum > 100 then
			GUI.StaticSetText(luckNum, "100%")
		else
			GUI.StaticSetText(luckNum, tostring(realLuckNum).."%")
		end
		EquipRepairUI.RefreshResultInfo(nil,  normal, dynAttrs, curExStr, normal.enhanceLv)
	end
    EquipRepairUI.RefreshProduce()
    EquipRepairUI.RefreshConsumeItem()
end

local uiBKey = {
}

function EquipRepairUI.OnProduceBtnClick()
    local isInfight = CL.GetFightState()
    print("isInfight1" .. tostring(isInfight))
    if isInfight then
        CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法进行装备的修理！")
        return ""
    end
    local item = EquipRepairUI.GetItem()
    if item ~= nil and item.id > 0 then
        test(tostring(item.guid))
        CL.SendNotify(NOTIFY.SubmitForm, "FormRepair", "repair_equip", item.guid, data.checkOn and 1 or 0)
    end
end

function EquipRepairUI.OnAllClick()
    local isInfight = CL.GetFightState()
    print("isInfight2" .. tostring(isInfight))
    if isInfight then
        CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法进行装备的修理！")
        return ""
    end
    local allPay = 0
    local moneyType = UIDefine.MoneyTypes[(UIDefine.Repair_MoneyType or 5)]
    local moneyName = UIDefine.AttrName[moneyType]
    local equipList = data.items[data.getBagType()]
    for i = 1, #equipList, 1 do
        local item = equipList[i]
        local DurableNow = LD.GetItemIntCustomAttrByGuid("DurableNow", item.guid, item.bagtype)
        local DurableMax = LD.GetItemIntCustomAttrByGuid("DurableMax", item.guid, item.bagtype)
        local Coefficient = LD.GetItemIntCustomAttrByGuid("Coefficient", item.guid, item.bagtype)
        local pay = (DurableMax - DurableNow) * Coefficient
        allPay = allPay + pay
    end
    if #equipList == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg,"当前没有需要的修理装备！")
    elseif allPay == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg,"当前装备都不需要修理！")
    else
        GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", "修理全部装备需要消耗".. allPay .. moneyName .."，是否进行修理", "EquipRepairUI", "确定", "confirm", "取消", "cancel")
    end
end

function EquipRepairUI.confirm()
    local equipType = data.getBagType()
	local n = 1
	if equipType == item_container_type.item_container_equip then
		n = 0
	end
    CL.SendNotify(NOTIFY.SubmitForm, "FormRepair", "repair_all_equip", n)
end
function EquipRepairUI.cancel()

end
function EquipRepairUI.Show(reset)
    test("EquipRepairUI.Show")
    EquipRepairUI.GetSelfEquipInfo()
    if reset then
        data.index = 1
        data.type = 1
        data.indexGuid = nil
        EquipUI.SelectBagType(data)
    end
    EquipRepairUI.SetVisible(true)
    EquipRepairUI.ClientRefresh()
end

function EquipRepairUI.Refresh()
    EquipRepairUI.ClientRefresh()
end

function EquipRepairUI.GetSelfEquipInfo()
    for key, value in pairs(data.items) do
        test("GetSelfEquipInfo")
        test(key)
        --data.attrs[key] = {}
        data.items[key] =
            EquipScrollItem.GetItemByType(
            key,
            function(item)
                local can = 1
                test(can)
                if can == 1 then
                    return true
                else
                    return false
                end
            end
        )
    end
end
function EquipRepairUI.ClientRefresh()
    if data.index > #data.items[data.getBagType()] then
        data.index = 1
    end
    EquipRepairUI.RefreshUI()
end

function EquipRepairUI.CreateSubPage(equipPage)
    GameMain.AddListen("EquipRepairUI", "OnExitGame")
    guidt = UILayout.NewGUIDUtilTable()
    local EquipRepair = GUI.GroupCreate(equipPage, "EquipRepair", 0, 0, 0, 0)
    guidt.BindName(EquipRepair, "EquipRepair")
	local vbg = GUI.ImageCreate(EquipRepair, "vbg", "1801100050", 160, -129, false, 198, 116)
	local nowbg = GUI.ImageCreate(EquipRepair, "nowbg", "1801100070", -10, 40, false, 230, 50)
	local maxbg = GUI.ImageCreate(EquipRepair, "maxbg", "1801100070", 330, 40, false, 230, 50)
	local arrowbg = GUI.ImageCreate(EquipRepair, "arrowbg", "1801100060", 160, 40, false, 38, 34)
	local textNow = GUI.CreateStatic(nowbg, "textNow", "当前耐久度", -40, 0, 200, 60)
	GUI.StaticSetAlignment(textNow, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(textNow, UIDefine.FontSizeM)
    GUI.SetScale(textNow, UIDefine.FontSizeM2FontSizeXL)
    GUI.SetColor(textNow, UIDefine.BrownColor)
	local textNow2 = GUI.CreateStatic(nowbg, "textNow2", "-1", 80, 0, 200, 60)
	GUI.StaticSetAlignment(textNow2, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(textNow2, UIDefine.FontSizeM)
    GUI.SetScale(textNow2, UIDefine.FontSizeM2FontSizeXL)
    GUI.SetColor(textNow2, UIDefine.BrownColor)
	local textMax = GUI.CreateStatic(maxbg, "textMax", "修理后耐久度", -30, 0, 200, 60)
	GUI.StaticSetAlignment(textMax, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(textMax, UIDefine.FontSizeM)
    GUI.SetScale(textMax, UIDefine.FontSizeM2FontSizeXL)
    GUI.SetColor(textMax, UIDefine.BrownColor)
	local textMax2 = GUI.CreateStatic(maxbg, "textMax2", "-1", 80, 0, 200, 60)
	GUI.StaticSetAlignment(textMax2, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(textMax2, UIDefine.FontSizeM)
    GUI.SetScale(textMax2, UIDefine.FontSizeM2FontSizeXL)
    GUI.SetColor(textMax2, UIDefine.BrownColor)
    local enhanceBtn = GUI.ButtonCreate(EquipRepair, "enhanceBtn", "1800002060", 436 , 265, Transition.ColorTint, "修理", 160, 50, false)
    guidt.BindName(enhanceBtn, "enhanceBtn")
    GUI.SetEventCD(enhanceBtn, UCE.PointerClick, 0.5)
    GUI.ButtonSetTextColor(enhanceBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(enhanceBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetOutLineArgs(enhanceBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(enhanceBtn, UCE.PointerClick, "EquipRepairUI", "OnProduceBtnClick")
	local repairAll = GUI.ButtonCreate(EquipRepair, "repairAll", "1800002060", 265, 265, Transition.ColorTint, "修理全部", 160, 50, false, false)
	GUI.ButtonSetTextFontSize(repairAll, UIDefine.FontSizeXL)
	GUI.ButtonSetTextColor(repairAll, UIDefine.WhiteColor)
	if UIDefine.FunctionSwitch.RepairAll == "on" then
		GUI.SetVisible(repairAll, true)
	else
		GUI.SetVisible(repairAll, false)
	end
	GUI.ButtonSetOutLineArgs(repairAll, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
	GUI.RegisterUIEvent(repairAll, UCE.PointerClick, "EquipRepairUI", "OnAllClick")
	local itemIcon = GUI.ItemCtrlCreate(vbg, "itemIcon", UIDefine.ItemIconBg2[1], 0, 0)
	local name = GUI.CreateStatic(EquipRepair, "name", "名字", 60, -70, 198, 30)
	GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)
	GUI.SetColor(name, UIDefine.BrownColor)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
	local level = GUI.CreateStatic(EquipRepair, "lv", "10级", 160, -20, 100, 30)
    GUI.SetColor(level, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(level, UIDefine.FontSizeM)
    local equipType = GUI.CreateStatic(EquipRepair, "equipType", "武器", 220, -20, 200, 30)
    GUI.SetColor(equipType, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(equipType, UIDefine.FontSizeM)
	local probability = GUI.CreateStatic(EquipRepair, "probability", "成功率", -60, 255, 100, 100)
	GUI.SetColor(probability, UIDefine.BrownColor)
    GUI.StaticSetFontSize(probability, UIDefine.FontSizeL)
	local luckNum = GUI.CreateStatic(EquipRepair, "luckNum", "200%", 20, 255, 100, 100)
    GUI.SetColor(luckNum, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(luckNum, UIDefine.FontSizeL)
    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)
	local EquipTop = EquipUI.guidt.GetUI("EquipTop")
	local btn1 = GUI.GetChild(EquipTop, "btn1", false)
	if UIDefine.FunctionSwitch.Repair == "on" then
		GUI.SetVisible(btn1, true)
	else
		GUI.SetVisible(btn1, false)
	end
end

function EquipRepairUI.SetVisible(visible)
	local ui = guidt.GetUI("EquipRepair")
    GUI.SetVisible(ui, visible)
	local normalBg = EquipUI.guidt.GetUI("normalBg")
	GUI.SetVisible(normalBg,not visible)
	local bindbtn = EquipUI.guidt.GetUI("bindBtn")
	GUI.SetVisible(bindbtn, not visible)
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local consumeItem4 = GUI.GetChild(equipPage, "consumeItem4", false)
	GUI.SetVisible(consumeItem4, not visible)
    local inEquipBtn = GUI.GetChild(equipPage,"inEquipBtn")
    local inBagBtn = GUI.GetChild(equipPage,"inBagBtn")
    GUI.SetVisible(inEquipBtn, visible)
    GUI.SetVisible(inBagBtn, visible)
    
    -- 郑   点击修理按钮的时候把 向右的箭头隐藏 2021/5/11
    local rightArrow = GUI.GetChild(equipPage, "rightArrow", false)
    GUI.SetVisible(rightArrow, not visible)
    --

    local t = {}
    for i = 1, #t do
        local attrsbg = guidt.GetUI(t[i])
        GUI.SetVisible(attrsbg, visible)
    end
    for i = 1, #uiBKey do
        local ui = EquipUI.guidt.GetUI(uiBKey[i])
        GUI.SetVisible(ui, visible)
    end
    local enhanceBtn = EquipUI.guidt.GetUI("enhanceBtn")
    GUI.SetVisible(enhanceBtn, not visible)
    local consumeMax = 4
    if visible == false then
        for i = 1, consumeMax do
            local item = EquipUI.guidt.GetUI("consumeItem" .. i)
            GUI.UnRegisterUIEvent(item, UCE.PointerClick, "EquipRepairUI", "OnConsumeItemClick")
        end
        if EquipUI.RefreshLeftItemScroll == EquipRepairUI.RefreshLeftItem then
            EquipUI.RefreshLeftItemScroll = nil
            EquipUI.ClickLeftItemScroll = nil
        end
        UILayout.UnRegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipRepairUI")
        EquipRepairUI.ClickItemGuid = ""
    else
        for i = 1, consumeMax do
            local item = EquipUI.guidt.GetUI("consumeItem" .. i)
            GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipRepairUI", "OnConsumeItemClick")
        end
        EquipUI.RefreshLeftItemScroll = EquipRepairUI.RefreshLeftItem
        EquipUI.ClickLeftItemScroll = EquipRepairUI.OnLeftItemClick
        UILayout.RegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipRepairUI")
    end
end

function EquipRepairUI.RefreshLeftItem(guid, index)
    local type = data.getBagType()
    EquipScrollItem.RefreshLeftItemByItemInfosEx(guid, type, data.items[type][index])
    local item = GUI.GetByGuid(guid)
	local nameEx = GUI.GetChild(item, "nameEx", false)
	GUI.SetVisible(nameEx, false)
	local normal = EquipRepairUI.GetItem(index)
	local DurableNow = LD.GetItemIntCustomAttrByGuid("DurableNow", normal.guid, normal.bagtype)
	local DurableMax = LD.GetItemIntCustomAttrByGuid("DurableMax", normal.guid, normal.bagtype)
	local lv = GUI.GetChild(item, "lv", false)
	if DurableMax == 0 then
		GUI.StaticSetText(lv, "耐久度:".."永不磨损")
	else
		GUI.StaticSetText(lv, "耐久度:"..DurableNow.."/"..DurableMax)
	end
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
    GlobalProcessing.SetRetPoint(item,false)
end

function EquipRepairUI.OnLeftItemClick(guid)
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    EquipRepairUI.ClientRefresh()
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end
    EquipRepairUI.RefreshProduce()
end

function EquipRepairUI.GetItem(index)
    if index == nil then
        index = data.index
    end
    local type = data.getBagType()
    return data.items[type][index]
end

function EquipRepairUI.RefreshProduce()
    UILayout.OnSubTabClickEx(data.type, EquipEnhanceUI.typeList)
    local type = data.getBagType()
    local item = EquipRepairUI.GetItem()
end

function EquipRepairUI.OnConsumeItemClick(guid)
    local consumeMax = 4
    local itemInfo = EquipRepairUI.GetItem()
	local RepairItemList = LD.GetItemStrCustomAttrByGuid("RepairItemList", itemInfo.guid, itemInfo.bagtype)
	local config = assert(loadstring("return " .. RepairItemList))()
	local id1 = DB.GetOnceItemByKey2(config.ItemList[1]).Id
	local id2 = DB.GetOnceItemByKey2(config.SucceedItem[1]).Id
	RepairItemList = {{id = id1, keyname = config.ItemList[1], count = config.ItemList[2]}, {id = id2, keyname = config.SucceedItem[1], count = config.SucceedItem[2]}}
    for i = 1, consumeMax do
        local item = EquipUI.guidt.GetUI("consumeItem" .. i)
        if guid == GUI.GetGuid(item) then
            Tips.CreateByItemId(
                RepairItemList[i].id,
                EquipUI.guidt.GetUI("equipPage"),
                "tips",
                0,
                0
            )
        end
    end
end

function EquipRepairUI.RefreshConsumeItem()
	local EquipBottom = EquipUI.guidt.GetUI("EquipBottom")
	local consumeBg = GUI.GetChild(EquipBottom, "consumeBg", false)
	local coin = GUI.GetChild(consumeBg, "coin", false)
	test(coin)
    test("EquipRepairUI.RefreshConsumeItem")
    local consumeXPos = {
        {150},
        {
            50,
            250
        },
        {
            0,
            150,
            300
        }
    }
	local normal = EquipRepairUI.GetItem()
	if normal == nil then
        EquipUI.RefreshConsumeItemEx(EquipEnhanceUI.consumeMax, {}, consumeXPos)
        EquipUI.RefreshConsumeCoin(RoleAttr.RoleAttrIngot, 0)
		EquipUI.RefreshConsumeCoin(UIDefine.GetMoneyEnum(UIDefine.Repair_MoneyType or 5), 0)
        return
    end
	local DurableNow = LD.GetItemIntCustomAttrByGuid("DurableNow", normal.guid, normal.bagtype)
	local DurableMax = LD.GetItemIntCustomAttrByGuid("DurableMax", normal.guid, normal.bagtype)
	local Coefficient = LD.GetItemIntCustomAttrByGuid("Coefficient", normal.guid, normal.bagtype)
	local RepairItemList = LD.GetItemStrCustomAttrByGuid("RepairItemList", normal.guid, normal.bagtype)
	test("aaaaaaaaaaaaaa:"..RepairItemList)
	local config = assert(loadstring("return " .. RepairItemList))()
	local pay = (DurableMax - DurableNow) * Coefficient
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local consumeItem1 = GUI.GetChild(equipPage, "consumeItem1", false)
	local bg = guidt.GetUI("EquipRepair")
	local probability = GUI.GetChild(bg, "probability", false)
	local luckNum = GUI.GetChild(bg, "luckNum", false)
	local consumeItem2 = GUI.GetChild(equipPage, "consumeItem2", false)
	local consumeItem3 = GUI.GetChild(equipPage, "consumeItem3", false)
	GUI.SetVisible(consumeItem1, false)
	GUI.SetVisible(consumeItem2, false)
	GUI.SetVisible(consumeItem3, false)
	if config ~= nil then
		local id1 = DB.GetOnceItemByKey2(config.ItemList[1]).Id
		local id2 = DB.GetOnceItemByKey2(config.SucceedItem[1]).Id
		RepairItemList = {{id = id1, keyname = config.ItemList[1], count = config.ItemList[2]}, {id = id2, keyname = config.SucceedItem[1], count = config.SucceedItem[2]}}
		GUI.SetVisible(probability, true)
		GUI.SetVisible(luckNum, true)
		EquipUI.RefreshConsumeItemEx(2, RepairItemList, consumeXPos, 2, true)
		EquipUI.RefreshConsumeCoin(UIDefine.GetMoneyEnum(UIDefine.Repair_MoneyType or 5), pay)
	else
		GUI.SetVisible(consumeItem1, false)
		GUI.SetVisible(consumeItem2, false)
		GUI.SetVisible(probability, false)
		GUI.SetVisible(luckNum, false)
		EquipUI.RefreshConsumeCoin(UIDefine.GetMoneyEnum(UIDefine.Repair_MoneyType or 5), pay)
	end
end