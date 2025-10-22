local EquipExtractUI = {
    ---@type table<number,>
    serverData = {}
}
_G.EquipExtractUI =EquipExtractUI 
local guidt = UILayout.NewGUIDUtilTable()
function EquipExtractUI.InitData()
    return {
        -- 背包中，装备中类型
        type = 1,
        -- 选中的道具下标
        index = 1,
        -- 选中的道具uiGuId
        indexGuid = int64.new(0),
		useUnBind = false,
        -- 可用道具
        items = {
            ---@type eqiupItem[]
            [item_container_type.item_container_equip] = {},
            ---@type eqiupItem[]
            [item_container_type.item_container_bag] = {}
        },
		skillIds = {},
		skillIndex = 1,
		skillIndexGuid = int64.new(0),
		effectdata ={}
    }
end
-- local test = print
local test = function()
end
local consumeMax = 4
local data = EquipExtractUI.InitData()
function EquipExtractUI.OnExitGame()
    data = EquipExtractUI.InitData()
    ---@return item_container_type
    data.getBagType = function()
        local type = EquipEnhanceUI.typeList[data.type][12]
        return type
    end
end
---@return item_container_type
data.getBagType = function()
    local type = EquipEnhanceUI.typeList[data.type][12]
    return type
end
function EquipExtractUI.GetData()
    if not EquipExtractUI.serverData.Edition then
		EquipExtractUI.serverData.Edition = "0"
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquipSpecialEffect", "getAllData", EquipExtractUI.serverData.Edition)
end
function EquipExtractUI.OnInEquipBtnClick()
    data.type = 1
    data.index = 1
	EquipExtractUI.ClientRefresh()
end
function EquipExtractUI.OnInBagBtnClick()
    data.type = 2
    data.index = 1
	EquipExtractUI.ClientRefresh()
end
--ui刷新
function EquipExtractUI.RefreshUI()
    local items = data.items[data.getBagType()]
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
    EquipExtractUI.RefreshProduce()
    EquipExtractUI.RefreshConsumeItem()
end

function EquipExtractUI.RefreshResultInfo(bg, eqiupItemTable)
	local eqiupItem = bg or guidt.GetUI("eqiupItem")
	local extractItem = guidt.GetUI("extractItem")
	local title = GUI.GetChild(eqiupItem, "title", false)
	GUI.StaticSetText(title, "当前选择装备")
	local icon = GUI.GetChild(eqiupItem, "itemIcon", false)
	local name = GUI.GetChild(eqiupItem, "name", false)
	local enhanceLv = GUI.GetChild(eqiupItem, "enhanceLv", false)
	local lv = GUI.GetChild(eqiupItem, "lv", false)
	local equipType = GUI.GetChild(eqiupItem, "equipType", false)
	local rulebg = GUI.GetChild(eqiupItem, "rulebg", false)
	
	local rulebg2 = GUI.GetChild(extractItem, "rulebg", false)
	local rule = GUI.GetChild(rulebg, "rule", false)
	local src = GUI.GetChild(eqiupItem, "src", false)
	local src2 = GUI.GetChild(extractItem, "src", false)
	local attText1 = GUI.GetChild(src, "attText1", false)
	local attText2 = GUI.GetChild(src, "attText2", false)
	local value1 = GUI.GetChild(attText1, "value", false)
	local value2 = GUI.GetChild(attText2, "value", false)
	local info = GUI.GetChild(src2, "info", false)
	local label = GUI.GetChild(info, "label", false)
	local check1 = GUI.GetChild(eqiupItem, "check1", false)
	local check2 = GUI.GetChild(eqiupItem, "check2", false)
	local name2 = GUI.GetChild(extractItem, "name", false)
	local itemIcon2 = GUI.GetChild(extractItem, "itemIcon",false)
	local lv2 = GUI.GetChild(extractItem, "lv", false)
	
	--local attText12 = GUI.GetChild(ArtificeAttr, "attText1", true)
	if eqiupItemTable ~= nil then
		GUI.SetColor(value1, UIDefine.BrownColor)
		GUI.SetColor(value2, UIDefine.BrownColor)
		GUI.SetPositionX(value1, 80)
		GUI.SetPositionX(value2, 80)
		GUI.StaticSetText(attText1, "特效：")
		GUI.StaticSetText(attText2, "特技：")
		GUI.StaticSetText(rule, "请选择要提取的目标")
		GUI.StaticSetAutoSize(rule, true)
		GUI.StaticSetAutoSize(name, true)
		GUI.SetVisible(name, true)
		GUI.SetVisible(enhanceLv, true)
		GUI.SetVisible(lv, true)
		GUI.SetVisible(equipType, true)
		GUI.SetVisible(attText1, true)
		GUI.SetVisible(attText2, true)
		GUI.SetVisible(label, true)
		GUI.SetVisible(rulebg, true)
		GUI.SetVisible(rulebg2, true)
		GUI.SetVisible(tip, false)
		local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", eqiupItemTable.guid, eqiupItemTable.bagtype)
		local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", eqiupItemTable.guid, eqiupItemTable.bagtype)
		local title = GUI.GetChild(extractItem, "title", false)
		GUI.StaticSetText(title, "提取目标")
		local rule2 = GUI.GetChild(rulebg2, "rule", false)
		local itemGrade1 = DB.GetOnceSkillByKey1(Equip_SpecialEffect).SkillQuality
		local itemGrade2 = DB.GetOnceSkillByKey1(Equip_Stunt).SkillQuality
		local enhanceBtn = guidt.GetUI("enhanceBtn")
		if GUI.CheckBoxGetCheck(check1) == true then
			GUI.StaticSetText(rule2, "特效效果")
			GUI.StaticSetText(lv2, "特效")
			GUI.StaticSetText(name2, DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name)
			GUI.StaticSetAutoSize(name2, true)
			GUI.SetColor(name2, UIDefine.GradeColor[itemGrade1])
			if itemGrade1 == 1 then
				GUI.SetColor(name2, UIDefine.BrownColor)
			end
			ItemIcon.BindSkillId(itemIcon2, Equip_SpecialEffect)
			GUI.StaticSetText(label, DB.GetOnceSkillByKey1(Equip_SpecialEffect).Info)
			local h = GUI.StaticGetLabelPreferHeight(label)
			GUI.SetHeight(label,h)
			GUI.ScrollRectSetChildSize(info,Vector2.New(270, h))
			GUI.ScrollRectSetNormalizedPosition(info,Vector2.New(0,1))
			--GUI.StaticSetAutoSize(attText12, true)
			GUI.UnRegisterUIEvent(enhanceBtn, UCE.PointerClick, "EquipExtractUI", "OnProduceBtnClick2")
			GUI.RegisterUIEvent(enhanceBtn, UCE.PointerClick, "EquipExtractUI", "OnProduceBtnClick1")
		end
		if GUI.CheckBoxGetCheck(check2) == true then
			GUI.StaticSetText(rule2, "特技效果")
			GUI.StaticSetText(lv2, "特技")
			GUI.StaticSetText(name2, DB.GetOnceSkillByKey1(Equip_Stunt).Name)
			GUI.StaticSetAutoSize(name2, true)
			GUI.SetColor(name2, UIDefine.GradeColor[itemGrade2])
			if itemGrade2 == 1 then
				GUI.SetColor(name2, UIDefine.BrownColor)
			end
			ItemIcon.BindSkillId(itemIcon2, Equip_Stunt)
			GUI.StaticSetText(label, DB.GetOnceSkillByKey1(Equip_Stunt).Info)
			local h = GUI.StaticGetLabelPreferHeight(label)
			GUI.SetHeight(label,h)
			GUI.ScrollRectSetChildSize(info,Vector2.New(270, h))
			GUI.ScrollRectSetNormalizedPosition(info,Vector2.New(0,1))
			--GUI.StaticSetAutoSize(attText12, true)
			GUI.UnRegisterUIEvent(enhanceBtn, UCE.PointerClick, "EquipExtractUI", "OnProduceBtnClick1")
			GUI.RegisterUIEvent(enhanceBtn, UCE.PointerClick, "EquipExtractUI", "OnProduceBtnClick2")
		end
		GUI.SetWidth(rule, GUI.StaticGetLabelPreferWidth(rule))
		GUI.SetWidth(rule2, GUI.StaticGetLabelPreferWidth(rule2))
		GUI.SetVisible(lv2, true)
		if Equip_SpecialEffect ~= 0 then
			GUI.StaticSetText(value1, "【"..DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name.."】")
			GUI.SetColor(value1, UIDefine.GradeColor[itemGrade1])
			if itemGrade1 == 1 then
				GUI.SetColor(value1, UIDefine.BrownColor)
			end
			GUI.StaticSetText(txt2, DB.GetOnceSkillByKey1(Equip_SpecialEffect).Info)
			value1:RegisterEvent(UCE.PointerClick)
			GUI.SetIsRaycastTarget(value1, true)
			GUI.SetVisible(check1, true)
			GUI.RegisterUIEvent(value1, UCE.PointerClick, "EquipExtractUI", "onSkillTipClick")
		else
			GUI.StaticSetText(value1, "无")
			GUI.SetColor(value1, UIDefine.BrownColor)
			GUI.SetVisible(check1, false)
			GUI.SetIsRaycastTarget(value1, false)
			if GUI.CheckBoxGetCheck(check1) == true then
				GUI.StaticSetText(name2, "未获取")
				GUI.SetColor(name2, UIDefine.BrownColor)
				GUI.SetVisible(lv2, false)
			end
		end
		if Equip_Stunt ~= 0 then
			GUI.StaticSetText(value2, "【"..DB.GetOnceSkillByKey1(Equip_Stunt).Name.."】")
			GUI.SetColor(value2, UIDefine.GradeColor[itemGrade2])
			if itemGrade2 == 1 then
				GUI.SetColor(value2, UIDefine.BrownColor)
			end
			value2:RegisterEvent(UCE.PointerClick)
			GUI.SetIsRaycastTarget(value2, true)
			GUI.SetVisible(check2, true)
			GUI.RegisterUIEvent(value2, UCE.PointerClick, "EquipExtractUI", "onSkillTipClick2")
		else
			GUI.StaticSetText(value2, "无")
			GUI.SetColor(value2, UIDefine.BrownColor)
			GUI.SetVisible(check2, false)
			GUI.SetIsRaycastTarget(value2, false)
			if GUI.CheckBoxGetCheck(check2) == true then
				GUI.StaticSetText(name2, "未获取")
				GUI.SetColor(name2, UIDefine.BrownColor)
				GUI.SetVisible(lv2, false)
			end
		end
		local nameTxt, lvTxt, equipTypeTxt, enhanceLvTxt = " "
		if eqiupItemTable then
			if eqiupItemTable.bagtype == item_container_type.item_container_guard_equip and EquipUI.curGuardGuid then
				ItemIcon.BindGuardEquip(icon, EquipUI.curGuardGuid, eqiupItemTable.site)
			else
				ItemIcon.BindIndexForBag(icon, eqiupItemTable.site, eqiupItemTable.bagtype)
			end
			nameTxt = eqiupItemTable.name
			if eqiupItemTable.enhanceLv and eqiupItemTable.enhanceLv > 0 then
			GUI.SetVisible(enhanceLv, true)
				enhanceLvTxt = "+"..(eqiupItemTable.enhanceLv)
			else 
				GUI.SetVisible(enhanceLv, false)
			end
			lvTxt = tostring(eqiupItemTable.lv) .. "级"
			equipTypeTxt = eqiupItemTable.showType
		else
			ItemIcon.BindItemId(icon, nil)
		end
		GUI.StaticSetText(enhanceLv, enhanceLvTxt)
		GUI.StaticSetText(name, nameTxt)
		GUI.StaticSetText(lv, lvTxt)
		GUI.SetColor(lv, UIDefine.Yellow2Color)
		GUI.StaticSetFontSize(lv, UIDefine.FontSizeM)
		GUI.StaticSetText(equipType, equipTypeTxt)
		GUI.SetColor(equipType, UIDefine.Yellow2Color)
		GUI.StaticSetFontSize(equipType, UIDefine.FontSizeM)
		GUI.SetPositionX(enhanceLv , GUI.GetPositionX(name) + GUI.StaticGetLabelPreferWidth(name) + 10)
		GUI.SetPositionX(equipType,GUI.GetPositionX(lv) + GUI.StaticGetLabelPreferWidth(lv) + 10)
		if string.find(equipTypeTxt,"无级别") then
			GUI.SetVisible(lv,false)
			GUI.SetPositionX(equipType,GUI.GetPositionX(lv))
		end
	else
		GUI.SetVisible(name, false)
		GUI.SetVisible(enhanceLv, false)
		GUI.SetVisible(lv, false)
		GUI.SetVisible(lv2, false)
		GUI.SetVisible(equipType, false)
		GUI.SetVisible(attText1, false)
		GUI.SetVisible(attText2, false)
		ItemIcon.BindItemId(icon, nil)
		GUI.SetVisible(rulebg, false)
		GUI.SetVisible(rulebg2, false)
		GUI.SetVisible(check1, false)
		GUI.SetVisible(check2, false)
		GUI.SetVisible(label, false)
		GUI.StaticSetText(name2, "未获取")
		GUI.SetColor(name2, UIDefine.BrownColor)
		ItemIcon.BindItemId(itemIcon2, nil)
	end
end

--强化ui底部name
local uiBKey = {
}
-- 关闭或者打开只属于子页签的东西
function EquipExtractUI.SetVisible(visible)
    local ui = guidt.GetUI("EquipExtract")
	local eqiupItem = guidt.GetUI("eqiupItem")
	local extractItem = guidt.GetUI("extractItem")
	GUI.SetVisible(ui, visible)
	GUI.SetVisible(eqiupItem, visible)
	GUI.SetVisible(extractItem, visible)
	local check1 = GUI.GetChild(eqiupItem,"check1")
	local check2 = GUI.GetChild(eqiupItem,"check2")
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local inEquipBtn = GUI.GetChild(equipPage,"inEquipBtn")
	local inBagBtn = GUI.GetChild(equipPage,"inBagBtn")
	GUI.SetVisible(inEquipBtn, visible)
	GUI.SetVisible(inBagBtn, visible)
	if visible then
		GUI.SetVisible(EquipUI.guidt.GetUI("EquipBottom"),false)
	end
	
	--GUI.SetVisible(ArtificeAttr, visible)
	--local equipPage = EquipUI.guidt.GetUI("equipPage")
	--local ArtificeAttr = GUI.GetChild(equipPage, "ArtificeAttr", false)
	--GUI.SetVisible(ArtificeAttr, visible)
	--local normalBg = GUI.GetChild(equipPage, "normalBg", false)
	--GUI.SetVisible(checkBg1, visible)
	--GUI.SetVisible(checkBg2, visible)
	--
	--local equipType = GUI.GetChild(ArtificeAttr, "equipType", false)
	--GUI.SetVisible(equipType, not visible)
	--local attText1 = GUI.GetChild(ArtificeAttr, "attText1", true)
	--local attText2 = GUI.GetChild(ArtificeAttr, "attText2", true)
	--local value1 = GUI.GetChild(attText1, "value", true)
	--local value2 = GUI.GetChild(attText2, "value", true)
	--GUI.SetVisible(value1, not visible)
	--GUI.SetVisible(value2, not visible)
	--GUI.SetVisible(attText2, not visible)
	--local itemIcon2 = GUI.GetChild(ArtificeAttr, "itemIcon",false)
	--local LeftTopSp = GUI.GetChild(itemIcon2, "LeftTopSp", false)
	--GUI.SetVisible(LeftTopSp, not visible)
	--local bg = GUI.GetChild(equipPage, "bg", false)
	--local tipBtn = GUI.GetChild(bg, "tipBtn", false)
	--GUI.SetVisible(tipBtn, visible)
	--if visible then
	--	GUI.SetHeight(attText1, 69)
	--	GUI.SetWidth(attText1, 269)
	--end
	--local Viewport = GUI.GetChild(ArtificeAttr, "Viewport", true)
    --local t = {}
    --for i = 1, #t do
    --    local attrsbg = guidt.GetUI(t[i])
    --    GUI.SetVisible(attrsbg, visible)
    --end
    --for i = 1, #uiBKey do
    --    local ui = EquipUI.guidt.GetUI(uiBKey[i])
    --    GUI.SetVisible(ui, visible)
    --end
	local unbind = EquipUI.guidt.GetUI("bindBtn")
    if visible == false then
        for i = 1, consumeMax do
            local item = guidt.GetUI("consumeItem" .. i)
			local check = GUI.GetChild(item, "check", false)
			GUI.SetVisible(check, not visible)
            GUI.UnRegisterUIEvent(item, UCE.PointerClick, "EquipExtractUI", "OnConsumeItemClick")
        end
        if EquipUI.RefreshLeftItemScroll == EquipExtractUI.RefreshLeftItem then
            EquipUI.RefreshLeftItemScroll = nil
            EquipUI.ClickLeftItemScroll = nil
        end
		GUI.UnRegisterUIEvent(check1, UCE.PointerClick , "EquipExtractUI", "OnCheckBox1")
		GUI.UnRegisterUIEvent(check2, UCE.PointerClick , "EquipExtractUI", "OnCheckBox2")
		GUI.UnRegisterUIEvent(unbind, UCE.PointerClick, "EquipExtractUI", "OnCheckBind")
        UILayout.UnRegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipExtractUI")
    else
        for i = 1, consumeMax do
            local item = guidt.GetUI("consumeItem" .. i)
            GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipExtractUI", "OnConsumeItemClick")
        end
		GUI.RegisterUIEvent(check1, UCE.PointerClick , "EquipExtractUI", "OnCheckBox1")
		GUI.RegisterUIEvent(check2, UCE.PointerClick , "EquipExtractUI", "OnCheckBox2")
		GUI.RegisterUIEvent(unbind, UCE.PointerClick, "EquipExtractUI", "OnCheckBind")
        EquipUI.RefreshLeftItemScroll = EquipExtractUI.RefreshLeftItem
        EquipUI.ClickLeftItemScroll = EquipExtractUI.OnLeftItemClick
        UILayout.RegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipExtractUI")
    end
end

function EquipExtractUI.OnCheckBox1()
	local eqiupItem = guidt.GetUI("eqiupItem")
	local check1 = GUI.GetChild(eqiupItem, "check1", false)
	local check2 = GUI.GetChild(eqiupItem, "check2", false)
	GUI.CheckBoxSetCheck(check1, true)
	GUI.CheckBoxSetCheck(check2, false)
	EquipExtractUI.RefreshProduce()
	EquipExtractUI.RefreshConsumeItem()
end

function EquipExtractUI.OnCheckBox2()
	local eqiupItem = guidt.GetUI("eqiupItem")
	local check1 = GUI.GetChild(eqiupItem, "check1", false)
	local check2 = GUI.GetChild(eqiupItem, "check2", false)
	GUI.CheckBoxSetCheck(check2, true)
	GUI.CheckBoxSetCheck(check1, false)
	EquipExtractUI.RefreshProduce()
	EquipExtractUI.RefreshConsumeItem()
end

function EquipExtractUI.OnCheckBind(guid)
    local check = EquipUI.guidt.GetUI("bindBtn")
    if guid == GUI.GetGuid(check) then
        data.useUnBind = GUI.CheckBoxExGetCheck(check)
    end
end

function EquipExtractUI.OnProduceBtnClick1()
	local normal = EquipExtractUI.GetItem()
	if normal == nil then
		return
	end
	local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", normal.guid, normal.bagtype)
	local name = DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name
	if name then
		local key = Equip_SpecialEffect
		local id = data.effectdata[key].id
		local itemNum = data.effectdata[key].itemNum
		local moneyType = data.effectdata[key].moneyType
		local pay = data.effectdata[key].money
		local curmoney = CL.GetIntAttr(UIDefine.GetMoneyEnum(moneyType))
		local count = LD.GetItemCountById(id)
		if count < itemNum or curmoney < pay then
			-- CL.SendNotify(NOTIFY.ShowBBMsg,"道具不足")
			EquipExtractUI.confirm1()
		else
			-- GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("是否提取", "提取特效会损坏装备", "EquipExtractUI", "确定", "confirm1", "取消", "cancel")
			GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("是否提取", "提取成功后会销毁装备，宝石会退回至宝石包裹，但强化效果会直接消失，是否提取？", "EquipExtractUI", "确定", "confirm1", "取消", "cancel")
		end
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,"没有对应的特效")
	end
end

function EquipExtractUI.OnProduceBtnClick2()
	local normal = EquipExtractUI.GetItem()
	if normal == nil then
		return
	end
	local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", normal.guid, normal.bagtype)
	local name = DB.GetOnceSkillByKey1(Equip_Stunt).Name
	if name then
		local key = Equip_Stunt
		local id = data.effectdata[key].id
		local itemNum = data.effectdata[key].itemNum
		local moneyType = data.effectdata[key].moneyType
		local pay = data.effectdata[key].money
		local curmoney = CL.GetIntAttr(UIDefine.GetMoneyEnum(moneyType))
		local count = LD.GetItemCountById(id)
		if count < itemNum or curmoney < pay then
			-- CL.SendNotify(NOTIFY.ShowBBMsg,"道具不足")
			EquipExtractUI.confirm2()
		else
			-- GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("是否提取", "提取特技会损坏装备", "EquipExtractUI", "确定", "confirm2", "取消", "cancel")
			GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("是否提取", "提取成功后会销毁装备，宝石会退回至宝石包裹，但强化效果会直接消失，是否提取？", "EquipExtractUI", "确定", "confirm2", "取消", "cancel")
		end
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,"没有对应的特技")
	end
end

function EquipExtractUI.confirm1()
	local item = EquipExtractUI.GetItem()
    if item ~= nil and item.id > 0 then
        test(tostring(item.guid))
        CL.SendNotify(NOTIFY.SubmitForm, "FormEquipSpecialEffect", "extractSpecialEffect", item.guid,data.useUnBind and 1 or 0)
    end
end

function EquipExtractUI.confirm2()
	local item = EquipExtractUI.GetItem()
    if item ~= nil and item.id > 0 then
        test(tostring(item.guid))
        CL.SendNotify(NOTIFY.SubmitForm, "FormEquipSpecialEffect", "extractStunt", item.guid,data.useUnBind and 1 or 0)
    end
end

function EquipExtractUI.cancel()

end

function EquipExtractUI.Show(reset)
    test("EquipExtractUI.Show")
	EquipExtractUI.GetSelfEquipInfo()
    if reset then
        data.index = 1
        data.type = 1
        data.indexGuid = nil
		data.useUnBind = false,
		EquipUI.SelectBagType(data)
		EquipExtractUI.GetData()
    end
    EquipExtractUI.SetVisible(true)
	EquipExtractUI.ClientRefresh()
end
-- 表单接受数据回调
function EquipExtractUI.Refresh()
	local effeItems = EquipExtractUI.serverData.EquipSpecialEffectConfig['SpecialEffect']
	local stuntItems = EquipExtractUI.serverData.EquipSpecialEffectConfig['Stunt']
	if effeItems ~= nil and stuntItems ~= nil then
		data.effectdata = {}
		data.skillIds = {}
		EquipExtractUI.SetItemData(effeItems)
		EquipExtractUI.SetItemData(stuntItems)
	end
    EquipExtractUI.ClientRefresh()
end

function EquipExtractUI.SetItemData(itemData)
	local extractItemList = {}
	for k, v in pairs (itemData) do
		local keyName = v.Extract_Item_KeyName
		local item = nil
		local id = nil
		if extractItemList[keyName] == nil then
			item = DB.GetOnceItemByKey2(keyName)
			extractItemList[keyName] = item
			id = item.Id
		else
			item = extractItemList[keyName]
			id = item.Id
		end
		local itemNum = v.Extract_Item_Num
		local moneyType = v.MoneyType
		local money = v.Extract_Money
		local temp = {
			id = id,
			keyName = keyName,
			itemNum = itemNum,
			moneyType = moneyType,
			money = money
		}
		data.effectdata[k] = temp
		table.insert(data.skillIds, k)
	end
end
--筛选道具
function EquipExtractUI.GetSelfEquipInfo()
    for key, value in pairs(data.items) do
        data.items[key] =
            EquipScrollItem.GetItemByType(
            key,
            ---@return bool
            ---@param item eqiupItem
            function(item)
                if item.subtype ~= 4 then
                    return true
                else
                    return false
                end
            end
        )
    end
end
function EquipExtractUI.ClientRefresh()
    -- data.consumeMax
    -- test("EquipExtractUI.Refresh")
    -- for key, value in pairs(EquipExtractUI.serverData) do
    -- end
    if data.index > #data.items[data.getBagType()] then
        data.index = 1
    end
	EquipExtractUI.RefreshCheckBox()
    EquipExtractUI.RefreshUI()
end

function EquipExtractUI.CreateEquipItem(parent,name,x,y)
	local equipItem = EquipExtractUI.CreateItem(parent,name,x,y,"当前选择装备","请选择要提取的目标")

	local enhanceLv = GUI.CreateStatic(equipItem, "enhanceLv", "等级：", 200, 60, 150, 30)
	GUI.SetColor(enhanceLv, UIDefine.EnhanceBlueColor)
	GUI.StaticSetFontSize(enhanceLv, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(enhanceLv, UILayout.TopLeft)


	local equipType = GUI.CreateStatic(equipItem, "equipType", "10", 200, 100, 200, 30)
	GUI.SetColor(equipType, UIDefine.EnhanceBlueColor)
	GUI.StaticSetFontSize(equipType, UIDefine.FontSizeM)
	
	local src = GUI.GetChild(equipItem,"src")

	local att1Text = GUI.CreateStatic(src, "attText1", "特效:", 17, 5, 100, 30)
	GUI.SetColor(att1Text, UIDefine.BrownColor)
	GUI.StaticSetFontSize(att1Text, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(att1Text, UILayout.TopLeft)
	local value = GUI.CreateStatic(att1Text, "value", "10", 112, 0, 166, 30)
	GUI.SetColor(value, UIDefine.Green8Color)
	GUI.StaticSetFontSize(value, UIDefine.FontSizeM)

	local att2Text = GUI.CreateStatic(src, "attText2", "特技：", 17, 35, 100, 30)
	GUI.SetColor(att2Text, UIDefine.BrownColor)
	GUI.StaticSetFontSize(att2Text, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(att2Text, UILayout.TopLeft)
	local value = GUI.CreateStatic(att2Text, "value", "10", 112, 0, 166, 30)
	GUI.SetColor(value, UIDefine.Green8Color)
	GUI.StaticSetFontSize(value, UIDefine.FontSizeM)

	local check1 = GUI.CheckBoxCreate(equipItem, "check1", "1800208040", "1800208041", 256, 190, Transition.None, true)
	local check2 = GUI.CheckBoxCreate(equipItem, "check2", "1800208040", "1800208041", 256, 220, Transition.None, false)
	
	return equipItem
end

function EquipExtractUI.CreateExtractItem(parent,name,x,y)
	local extractItem = EquipExtractUI.CreateItem(parent,name,x,y,"提取目标","效果")
	local src = GUI.GetChild(extractItem,"src")
	local info = GUI.ScrollListCreate(src, "info", 0, 10, 270, 55, false, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
	local label = GUI.CreateStatic(info,"label", "具体信息", 0, 0, 270, 60, "system", false, false)
	UILayout.SetSameAnchorAndPivot(label, UILayout.TopLeft)
	UILayout.StaticSetFontSizeColorAlignment(label, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.UpperLeft)
	return extractItem
end

function EquipExtractUI.CreateItem(parent,name,x,y,title,ruleText)
	local itemBg = GUI.ImageCreate(parent, name, "1801100030", x, y, false, 300, 260)
	UILayout.SetSameAnchorAndPivot(itemBg, UILayout.TopLeft)

	local title = GUI.CreateStatic(itemBg, "title", title, 20, 5, 200, 30)
	GUI.SetColor(title, UIDefine.BrownColor)
	GUI.StaticSetFontSize(title, UIDefine.FontSizeL)

	local itemIcon = GUI.ItemCtrlCreate(itemBg, "itemIcon", UIDefine.ItemIconBg2[1], 18, 53)
	local name = GUI.CreateStatic(itemBg, "name", "名字", 115, 60, 150, 30)
	GUI.SetColor(name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)

	local level = GUI.CreateStatic(itemBg, "lv", "10", 115, 100, 100, 30)
	GUI.SetColor(level, UIDefine.EnhanceBlueColor)
	GUI.StaticSetFontSize(level, UIDefine.FontSizeM)

	local rulebg = GUI.ImageCreate(itemBg, "rulebg", "1801100040", 15, 145)
	local rule = GUI.CreateStatic(rulebg, "rule", ruleText, 2, 0, 100, 30)
	GUI.SetColor(rule, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(rule, UIDefine.FontSizeM)
	local src = GUI.CreateStatic(itemBg, "src", "", 15, 170, 300, 70)
	
	return itemBg
end

function EquipExtractUI.CreateSubPage(equipPage)
    GameMain.AddListen("EquipExtractUI", "OnExitGame")
    guidt = UILayout.NewGUIDUtilTable()
	local EquipExtract = GUI.GroupCreate(equipPage, "EquipExtract", 0, 0, 0, 0)
	guidt.BindName(EquipExtract,"EquipExtract")
	local eqiupItem = EquipExtractUI.CreateEquipItem(EquipExtract,"eqiupItem",-190,-190)
	guidt.BindName(eqiupItem,"eqiupItem")
	local extractItem = EquipExtractUI.CreateExtractItem(EquipExtract,"extractItem",200,-190)
	guidt.BindName(extractItem,"extractItem")
	local rightArrow = GUI.ImageCreate(EquipExtract,"rightArrow","1801107010", 158, -60)

	local consumeItem = ItemIcon.Create(EquipExtract, "consumeItem1", 150, 155)
	GUI.SetData(consumeItem, "ItemIndex", i)
	local name = GUI.CreateStatic(consumeItem, "name", "材料", 0, 55, 150, 30)
	GUI.SetColor(name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(name, UIDefine.FontSizeS)
	GUI.SetAnchor(name, UIAnchor.Center)
	GUI.SetPivot(name, UIAroundPivot.Center)
	GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)
	guidt.BindName(consumeItem, "consumeItem1")


	--UILayout.CreateSubTab(EquipEnhanceUI.typeList, EquipExtract, "EquipExtractUI")
	
	--local normalBg = GUI.GetChild(equipPage, "normalBg", false)
	--local check1 = GUI.CheckBoxCreate(normalBg, "check1", "1800208040", "1800208041", 256, 190, Transition.None, true)
	--local check2 = GUI.CheckBoxCreate(normalBg, "check2", "1800208040", "1800208041", 256, 220, Transition.None, false)
	--local bg = GUI.GetChild(equipPage, "bg", false)
	local tpsBtn = GUI.ButtonCreate(EquipExtract, "tipBtn", "1800702030", 480, 200, Transition.ColorTint)
	GUI.RegisterUIEvent(tpsBtn, UCE.PointerClick, "EquipExtractUI", "onTipBtnClick");

	local consumeText = GUI.CreateStatic(EquipExtract, "consumeText", "消耗", -180, 265, 100, 30)
	GUI.SetColor(consumeText, UIDefine.BrownColor)
	GUI.StaticSetFontSize(consumeText, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleCenter)
	guidt.BindName(consumeText, "consumeText")

	local consumeBg = GUI.ImageCreate(EquipExtract, "consumeBg", "1800700010", -50, 266, false, 180, 35)
	local coin = GUI.ImageCreate(consumeBg, "coin", "1800408280", -74, -1, false, 36, 36)
	guidt.BindName(consumeBg, "consumeBg")
	local num = GUI.CreateStatic(consumeBg, "num", "100", 0, 0, 160, 30)
	GUI.SetColor(num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
	GUI.SetAnchor(num, UIAnchor.Center)
	GUI.SetPivot(num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)

	local enhanceBtn = GUI.ButtonCreate(EquipExtract, "enhanceBtn", "1800002060", 436 , 265, Transition.ColorTint, "提取", 160, 50, false)
	guidt.BindName(enhanceBtn, "enhanceBtn")
	GUI.SetEventCD(enhanceBtn, UCE.PointerClick, 0.5)
	GUI.ButtonSetTextColor(enhanceBtn, UIDefine.WhiteColor)
	GUI.ButtonSetTextFontSize(enhanceBtn, UIDefine.FontSizeXL)
	GUI.ButtonSetOutLineArgs(enhanceBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
end

function EquipExtractUI.onTipBtnClick()
	test("EquipExtractUI.onTipBtnClick")
	local panelBg = EquipUI.guidt.GetUI("panelBg")
	-- Tips.CreateHint("1.当有特效或特技的装备进行提取时，仅可选择\n一项进行提取。\n2.提取特技或特效后，装备会消失。\n3.提取特技或特效会根据稀有度消耗不同数量\n的材料。\n4.带有特殊标识的特技或特效不可进行提取。\n5.只有装备及消耗材料都为非绑定的情况下，才\n可获得非绑特技特效卷轴", panelBg, 195.7, 128.9, UILayout.Center, 535, 257)
	Tips.CreateHint("1.当有特效或特技的装备进行提取时，仅可选择一项进行提取。\n2.提取特技或特效后，装备会消失。\n3.带有特殊标识的特技或特效不可进行提取。\n4.只有装备及消耗材料都为非绑定的情况下，才可获得非绑特技特效卷轴", panelBg, 210, 130, UILayout.Center, 445, 161)
end

function EquipExtractUI.onSkillTipClick()
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local normal = EquipExtractUI.GetItem()
	local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", normal.guid, normal.bagtype)
	local name = DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name
	local info = DB.GetOnceSkillByKey1(Equip_SpecialEffect).Info
	Tips.CreateHint(name..":\n"..info, equipPage, 300.6, -27, UILayout.Center, 358.8, 104.8)
end

function EquipExtractUI.onSkillTipClick2()
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local normal = EquipExtractUI.GetItem()
	local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", normal.guid, normal.bagtype)
	local name = DB.GetOnceSkillByKey1(Equip_Stunt).Name
	local info = DB.GetOnceSkillByKey1(Equip_Stunt).Info
	Tips.CreateHint(name..":\n"..info, equipPage, 300.6, -27, UILayout.Center, 358.8, 104.8)
end

function EquipExtractUI.RefreshLeftItem(guid, index)
	test("EquipExtractUI.RefreshLeftItem")
    local type = data.getBagType()
    EquipScrollItem.RefreshLeftItemByItemInfosEx(guid, type, data.items[type][index])
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
	GlobalProcessing.SetRetPoint(item,false)
end
function EquipExtractUI.OnLeftItemClick(guid)
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end
	EquipExtractUI.ClientRefresh()
end
function EquipExtractUI.RefreshCheckBox()
	local equip = EquipExtractUI.GetItem()
	local checkFrist = true
	if equip then
		local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", equip.guid, equip.bagtype)
		local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", equip.guid, equip.bagtype)
		if Equip_SpecialEffect == 0 and Equip_Stunt ~= 0 then
			checkFrist = false
		end
		local eqiupItem = guidt.GetUI("eqiupItem")
		local check1 = GUI.GetChild(eqiupItem, "check1", false)
		local check2 = GUI.GetChild(eqiupItem, "check2", false)
		if checkFrist then
			GUI.CheckBoxSetCheck(check1, true)
			GUI.CheckBoxSetCheck(check2, false)
		else
			GUI.CheckBoxSetCheck(check1, false)
			GUI.CheckBoxSetCheck(check2, true)
		end
	end
end
---@return eqiupItem
function EquipExtractUI.GetItem(index)
    if index == nil then
        index = data.index
    end
    local type = data.getBagType()
    return data.items[type][index]
end

-- 刷新结果
function EquipExtractUI.RefreshProduce()
    UILayout.OnSubTabClickEx(data.type, EquipEnhanceUI.typeList)
    local type = data.getBagType()
    local item = EquipExtractUI.GetItem()
	if item == nil then
		EquipExtractUI.RefreshResultInfo(nil,  nil)
	else
		EquipExtractUI.RefreshResultInfo(nil,  item)
	end
end
function EquipExtractUI.OnConsumeItemClick(guid)
	local effeItems = data.effectdata
	local key = 0
	local normal = EquipExtractUI.GetItem()
	if normal then
		local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", normal.guid, normal.bagtype)
		local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", normal.guid, normal.bagtype)
		local eqiupItem = guidt.GetUI("eqiupItem")
		local check1 = GUI.GetChild(eqiupItem, "check1", false)
		local check2 = GUI.GetChild(eqiupItem, "check2", false)
		if GUI.CheckBoxGetCheck(check1) then
			key = Equip_SpecialEffect
		elseif GUI.CheckBoxGetCheck(check2) then
			key = Equip_Stunt
		end
	end
	local id = effeItems[key].id
    for i = 1, consumeMax do
        local item = guidt.GetUI("consumeItem" .. i)
        if guid == GUI.GetGuid(item) then
			local itemtips =  Tips.CreateByItemId(id, EquipUI.guidt.GetUI("equipPage"), "tips", 0, 0, 50)
			GUI.SetData(itemtips, "ItemId", tostring(id))
			guidt.BindName(itemtips,"tips")
			local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -15, Transition.ColorTint, "获取途径", 150, 50, false);
			UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
			GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
			GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
			GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"EquipExtractUI","onClickEquilWayBtn")
			GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
        end
    end
end
function EquipExtractUI.onClickEquilWayBtn()
    local tip = guidt.GetUI("tips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end
-- 刷新消耗道具
function EquipExtractUI.RefreshConsumeItem()
    --local consumeXPos = {
    --    {150},
    --    {
    --        50,
    --        250
    --    },
    --    {
    --        0,
    --        150,
    --        300
    --    }
    --}
	
	--local equipPage = EquipUI.guidt.GetUI("equipPage")
	local effeItems = data.effectdata
	local key = 0
	local normal = EquipExtractUI.GetItem()
	if normal then
		local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", normal.guid, normal.bagtype)
		local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", normal.guid, normal.bagtype)
		local eqiupItem = guidt.GetUI("eqiupItem")
		local check1 = GUI.GetChild(eqiupItem, "check1", false)
		local check2 = GUI.GetChild(eqiupItem, "check2", false)
		if GUI.CheckBoxGetCheck(check1) then
			key = Equip_SpecialEffect
		elseif GUI.CheckBoxGetCheck(check2) then
			key = Equip_Stunt
		end
	end
	if effeItems[key] then
		local id = effeItems[key].id
		local keyName = data.effectdata[key].keyName
		local count = data.effectdata[key].itemNum
		local moneyType = data.effectdata[key].moneyType
		local pay = data.effectdata[key].money
		local itemList = {{id = id, keyname = keyName, count = count}}
		if normal == nil then
			itemList = nil
		end
		EquipExtractUI.RefreshConsumeItemEx(4, itemList)
		EquipExtractUI.RefreshConsumeCoin(UIDefine.GetMoneyEnum(moneyType), pay)
	else
		EquipExtractUI.RefreshConsumeItemEx(4, nil)
		EquipExtractUI.RefreshConsumeCoin(nil)
	end
	local check = EquipUI.guidt.GetUI("bindBtn")
    GUI.CheckBoxExSetCheck(check, data.useUnBind)
end

function EquipExtractUI.RefreshConsumeItemEx(consumeMax, items)
	local consumeNum = 0
	local notnil = (items ~= nil)
	for i = 1, consumeMax do
		local item = guidt.GetUI("consumeItem" .. i)
		local info = items
		if notnil and i <= #info then
			consumeNum = consumeNum + 1
			GUI.SetVisible(item, true)
			ItemIcon.BindItemIdWithNum(item, info[i].id, info[i].count)
			local name = GUI.GetChild(item, "name", false)
			local iteminfo = DB.GetItem(info[i].id, info[i].keyname)
			if iteminfo ~= nil and iteminfo.Id > 0 then
				GUI.StaticSetText(name, iteminfo.Name)
			end
		else
			GUI.SetVisible(item, false)
		end
	end
end

function EquipExtractUI.RefreshConsumeCoin(coin_type, coin_count)
	local bg = guidt.GetUI("consumeBg")
	local consumeText = guidt.GetUI("consumeText")
	GUI.SetVisible(bg, true)
	GUI.SetVisible(consumeText, true)

	local coin = GUI.GetChild(bg, "coin", false)
	local num = GUI.GetChild(bg, "num", false)
	if coin_type == nil then
		GUI.SetVisible(coin,false)
		GUI.SetVisible(num,false)
		return
	else
		GUI.SetVisible(coin,true)
		GUI.SetVisible(num,true)
	end
	local l, h = int64.longtonum2(CL.GetAttr(coin_type))
	local curnum = l
	if curnum < coin_count then
		GUI.SetColor(num, UIDefine.RedColor)
	else
		GUI.SetColor(num, UIDefine.WhiteColor)
	end
	GUI.ImageSetImageID(coin, UIDefine.AttrIcon[coin_type])
	GUI.StaticSetText(num, tostring(coin_count))
end