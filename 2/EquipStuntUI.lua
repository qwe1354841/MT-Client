local EquipStuntUI = {
    ---@type table<number,>
    serverData = {}
}

_G.EquipStuntUI =EquipStuntUI 
local MaxArtificeCnt = 2

local guidt = UILayout.NewGUIDUtilTable()
function EquipStuntUI.InitData()
	if EquipStuntUI.serverData then
		EquipStuntUI.serverData.Edition = nil
	end
    return {
        type = 1,
        index = 1,
        indexGuid = int64.new(0),
        items = {
            ---@type eqiupItem[]
            [item_container_type.item_container_equip] = {},
            ---@type eqiupItem[]
            [item_container_type.item_container_bag] = {}
        },
		attrs = {
            ---@type enhanceDynAttrData[][]
            [item_container_type.item_container_equip] = {},
            ---@type enhanceDynAttrData[][]
            [item_container_type.item_container_bag] = {}
        },
		skillIndex = 1,
		skillIndexGuid = int64.new(0),
		effectdata = {}
    }
end
local data = EquipStuntUI.InitData()
function EquipStuntUI.OnExitGame()
    data = EquipStuntUI.InitData()
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

function EquipStuntUI.RefreshResultInfo(bg, eqiupItemTable, eqiupItemAttrTable)
	local equipPage = bg or EquipUI.guidt.GetUI("equipPage")
	local nbg = GUI.GetChild(equipPage, "nbg", false)
	local vbg1 = GUI.GetChild(nbg, "vbg1", false)
	local icon = GUI.GetChild(vbg1, "itemIcon", false)
	local name = GUI.GetChild(vbg1, "name", false)
	local enhanceLv = GUI.GetChild(vbg1, "nameEx", false)
	local lv = GUI.GetChild(vbg1, "lv", false)
	local equipType = GUI.GetChild(vbg1, "equipType", false)
	local src = GUI.GetChild(vbg1, "src", false)
	local iteminfo = nil
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
	if eqiupItemAttrTable and #eqiupItemAttrTable > MaxArtificeCnt then
		MaxArtificeCnt = #eqiupItemAttrTable
	end
	for i = 1, MaxArtificeCnt, 1 do
		local att = GUI.GetChild(src, "att"..i, false)
        local attv = GUI.GetChild(att, "value", false)
		if att == nil then
			local attText = GUI.CreateStatic(src, "att" .. i, "物理攻击", 0, 4, 200, 30)
			GUI.StaticSetFontSize(attText, UIDefine.FontSizeM)
			GUI.SetScale(attText, UIDefine.FontSizeM2FontSizeXL)
			GUI.SetColor(attText, UIDefine.BrownColor)
			local value = GUI.CreateStatic(attText, "value", "9999", 22, 0, 200, 30)
			GUI.StaticSetFontSize(value, UIDefine.FontSizeM)
			GUI.SetScale(value, UIDefine.FontSizeM2FontSizeXL)
			GUI.SetColor(value, UIDefine.Green8Color)
			att = attText
			attv = value
		end
		if eqiupItemAttrTable and eqiupItemAttrTable[i] then
				GUI.SetVisible(att, true)
				GUI.SetVisible(attv, true)
				GUI.StaticSetText(att, eqiupItemAttrTable[i].name .. ":")
				local cur1 = nil
				cur1 = tostring(eqiupItemAttrTable[i].value)
				GUI.StaticSetText(attv, cur1)
				GUI.SetColor(attv, UIDefine.Green8Color)
				GUI.SetPositionX(attv,GUI.GetPositionX(att) + GUI.StaticGetLabelPreferWidth(att) + 20)
			else
				GUI.SetVisible(att, false)
				GUI.SetVisible(attv, false)
			end
	end
	local effects = GUI.GetChild(src, "effects")
	local stunt = GUI.GetChild(src, "stunt")
	local effectsText = GUI.GetChild(effects, "effectsText", false)
	local stuntText = GUI.GetChild(stunt, "stuntText", false)
	local vbg2 = GUI.GetChild(nbg, "vbg2", false)
	local icon2 = GUI.GetChild(vbg2, "itemIcon", false)
	local icon3 = GUI.GetChild(vbg2, "itemIcon2", false)
	local name2 = GUI.GetChild(vbg2, "name", false)
	local txt2 = GUI.GetChild(vbg2, "txt", false)
	if eqiupItemTable ~= nil then
		GUI.SetVisible(effects, true)
		GUI.SetVisible(stunt, true)
		GUI.SetVisible(effectsText, true)
		GUI.SetVisible(stuntText, true)
		GUI.SetVisible(name, true)
		GUI.SetVisible(enhanceLv, true)
		GUI.SetVisible(lv, true)
		GUI.SetVisible(equipType, true)
		local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", eqiupItemTable.guid, eqiupItemTable.bagtype)
		local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", eqiupItemTable.guid, eqiupItemTable.bagtype)
		local itemGrade1 = DB.GetOnceSkillByKey1(Equip_SpecialEffect).SkillQuality
		local itemGrade2 = DB.GetOnceSkillByKey1(Equip_Stunt).SkillQuality
		if Equip_Stunt ~= 0 then
			GUI.SetVisible(icon2, true)
			GUI.SetVisible(icon3, false)
			ItemIcon.BindSkillId(icon2, Equip_Stunt)
			GUI.StaticSetText(stuntText, "【"..DB.GetOnceSkillByKey1(Equip_Stunt).Name.."】")
			GUI.StaticSetText(name2, DB.GetOnceSkillByKey1(Equip_Stunt).Name)
			GUI.SetColor(stuntText, UIDefine.GradeColor[itemGrade2])
			GUI.SetColor(name2, UIDefine.GradeColor[itemGrade2])
			if itemGrade2 == 1 then
				GUI.SetColor(stuntText, UIDefine.BrownColor)
			end
			GUI.StaticSetText(txt2, DB.GetOnceSkillByKey1(Equip_Stunt).Info)
			stuntText:RegisterEvent(UCE.PointerClick)
			GUI.SetIsRaycastTarget(stuntText, true)
			GUI.UnRegisterUIEvent(stuntText, UCE.PointerClick, "EquipEffectsUI", "onSkillTipClick2")
			GUI.RegisterUIEvent(stuntText, UCE.PointerClick, "EquipStuntUI", "onSkillTipClick2")
		else
			GUI.SetVisible(icon2, false)
			GUI.SetVisible(icon3, true)
			GUI.StaticSetText(stuntText, "无")
			GUI.StaticSetText(name2, "未获得")
			GUI.SetColor(stuntText, UIDefine.BrownColor)
			GUI.SetColor(name2, UIDefine.BrownColor)
			GUI.StaticSetText(txt2, "")
			GUI.UnRegisterUIEvent(stuntText, UCE.PointerClick, "EquipStuntUI", "onSkillTipClick2")
		end
		if Equip_SpecialEffect ~= 0 then
			GUI.StaticSetText(effectsText, "【"..DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name.."】")
			GUI.SetColor(effectsText, UIDefine.GradeColor[itemGrade1])
			if itemGrade1 == 1 then
				GUI.SetColor(effectsText, UIDefine.BrownColor)
			end
			effectsText:RegisterEvent(UCE.PointerClick)
			GUI.SetIsRaycastTarget(effectsText, true)
			GUI.UnRegisterUIEvent(effectsText, UCE.PointerClick, "EquipEffectsUI", "onSkillTipClick")
			GUI.RegisterUIEvent(effectsText, UCE.PointerClick, "EquipStuntUI", "onSkillTipClick")
		else
			GUI.StaticSetText(effectsText, "无")
			GUI.SetColor(effectsText, UIDefine.BrownColor)
			GUI.UnRegisterUIEvent(effectsText, UCE.PointerClick, "EquipStuntUI", "onSkillTipClick")
		end
		GUI.StaticSetText(enhanceLv, enhanceLvTxt)
		GUI.StaticSetText(name, nameTxt)
		GUI.StaticSetText(lv, lvTxt)
		GUI.StaticSetText(equipType, equipTypeTxt)
		GUI.SetPositionX(enhanceLv , GUI.GetPositionX(name) + GUI.StaticGetLabelPreferWidth(name) + 20)
		GUI.SetPositionX(equipType,GUI.GetPositionX(lv) + GUI.StaticGetLabelPreferWidth(lv) + 10)
		if string.find(equipTypeTxt,"无级别") then
			GUI.SetVisible(lv,false)
			GUI.SetPositionX(equipType,GUI.GetPositionX(lv))
		end
	else
		GUI.SetVisible(icon2, false)
		GUI.SetVisible(icon3, true)
		GUI.SetVisible(effects, false)
		GUI.SetVisible(stunt, false)
		GUI.SetVisible(effectsText, false)
		GUI.SetVisible(stuntText, false)
		GUI.SetVisible(name, false)
		GUI.SetVisible(enhanceLv, false)
		GUI.SetVisible(lv, false)
		GUI.SetVisible(equipType, false)
		GUI.StaticSetText(name2, "未获得")
		GUI.SetColor(name2, Color.New(133 / 255, 122 / 255, 113 / 255, 1))
		GUI.StaticSetText(txt2, "")
		GUI.SetIsRaycastTarget(effectsText, false)
	end
	GUI.SetPositionX(effectsText,GUI.GetPositionX(effects) + GUI.StaticGetLabelPreferWidth(effects) + 20)
	GUI.SetPositionX(stuntText,GUI.GetPositionX(stunt) + GUI.StaticGetLabelPreferWidth(stunt) + 20)
	-- GUI.ScrollRectSetNormalizedPosition(src,Vector2.New(0,1))
end
function EquipStuntUI.onSkillTipClick()
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local normal = EquipStuntUI.GetItem()
	local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", normal.guid, normal.bagtype)
	local name = DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name
	local info = DB.GetOnceSkillByKey1(Equip_SpecialEffect).Info
	Tips.CreateHint(name..":\n"..info, equipPage, 300.6, -27, UILayout.Center, 358.8, 104.8)
end

function EquipStuntUI.onSkillTipClick2()
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local normal = EquipStuntUI.GetItem()
	local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", normal.guid, normal.bagtype)
	local name = DB.GetOnceSkillByKey1(Equip_Stunt).Name
	local info = DB.GetOnceSkillByKey1(Equip_Stunt).Info
	Tips.CreateHint(name..":\n"..info, equipPage, 300.6, -27, UILayout.Center, 358.8, 104.8)
end
function EquipStuntUI.RefreshResultEffeInfo(bg, itemTable)
	local equipPage = bg or EquipUI.guidt.GetUI("equipPage")
	local nbg = GUI.GetChild(equipPage, "nbg", false)
	local vbg4 = GUI.GetChild(nbg, "vbg4", false)
	local itemIcon = GUI.GetChild(vbg4, "itemIcon", false)
	local name = GUI.GetChild(vbg4, "name", false)
	local effectInfoScroll = GUI.GetChild(vbg4, "effectInfoScroll", false)
	local info = GUI.GetChild(vbg4, "txt", true)
	if not itemTable then
		ItemIcon.SetEmpty(itemIcon)
		GUI.StaticSetText(name, "wu")
		GUI.StaticSetText(info, "wu")
	else
		ItemIcon.BindItemId(itemIcon, itemTable.Id)
		GUI.StaticSetText(name, itemTable.Name)
		GUI.SetColor(name, UIDefine.GradeColor[itemTable.Grade])
		if itemTable.Grade == 1 then
			GUI.SetColor(name, UIDefine.BrownColor)
		end
		GUI.StaticSetText(info, itemTable.Info)
		local infoH = GUI.StaticGetLabelPreferHeight(info) + 5
		if infoH < 50 then
			infoH = 50
		end
		GUI.ScrollRectSetChildSize(effectInfoScroll,Vector2.New(306.5, infoH))
		GUI.ScrollRectSetNormalizedPosition(effectInfoScroll,UIDefine.Vector2One)
	end
end

function EquipStuntUI.GetData()
    if not EquipStuntUI.serverData.Edition then
		EquipStuntUI.serverData.Edition = "0"
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquipSpecialEffect", "getData",EquipStuntUI.serverData.Edition,2)
end
function EquipStuntUI.OnInEquipBtnClick()
    data.type = 1
    data.index = 1
	EquipStuntUI.ClientRefresh()
end
function EquipStuntUI.OnInBagBtnClick()
    data.type = 2
    data.index = 1
	EquipStuntUI.ClientRefresh()
end

function EquipStuntUI.RefreshUI()
	if EquipUI.CheckItemGuid ~= 0 then
		for i = 1, #data.showeffectdata, 1 do
			local effItem = data.showeffectdata[i]
			if effItem.guid == tostring(EquipUI.CheckItemGuid) then
				data.skillIndex = i
				EquipUI.CheckItemGuid = 0
				break
			end
		end
	end
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
    EquipStuntUI.RefreshProduce()
    EquipStuntUI.RefreshConsumeItem()
end

local uiBKey = {
}

function EquipStuntUI.SetVisible(visible)
    local ui = EquipUI.guidt.GetUI("EquipEnhanceUI")
    GUI.SetVisible(ui, visible)
	local EquipTop = EquipUI.guidt.GetUI("EquipTop")
	local bindBtn = GUI.GetChild(EquipTop, "bindBtn", false)
	GUI.SetVisible(bindBtn, not visible)
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local nbg = GUI.GetChild(equipPage, "nbg", false)
	GUI.SetVisible(nbg, visible)
	local bg = GUI.GetChild(equipPage, "bg", false)
	GUI.SetVisible(bg, not visible)
	local normalBg = GUI.GetChild(equipPage, "normalBg", false)
	GUI.SetVisible(normalBg, not visible)
	local EquipBottom = EquipUI.guidt.GetUI("EquipBottom")
	GUI.SetVisible(EquipBottom, not visible)
	local consumeItem4 = GUI.GetChild(equipPage, "consumeItem4", false)
	GUI.SetVisible(consumeItem4, not visible)
	local inEquipBtn = GUI.GetChild(equipPage,"inEquipBtn")
	local inBagBtn = GUI.GetChild(equipPage,"inBagBtn")
	GUI.SetVisible(inEquipBtn, visible)
	GUI.SetVisible(inBagBtn, visible)
    local t = {}
    for i = 1, #t do
        local attrsbg = guidt.GetUI(t[i])
        GUI.SetVisible(attrsbg, visible)
    end
    for i = 1, #uiBKey do
        local ui = EquipUI.guidt.GetUI(uiBKey[i])
        GUI.SetVisible(ui, visible)
    end
	local vbg4 = GUI.GetChild(nbg, "vbg4", false)
	local effeBtn = GUI.GetChild(vbg4, "effectsBtn", false)
    if visible == false then
        GUI.UnRegisterUIEvent(effeBtn, UCE.PointerClick, "EquipStuntUI", "OnProduceBtnClick")
        if EquipUI.RefreshLeftItemScroll == EquipStuntUI.RefreshLeftItem then
            EquipUI.RefreshLeftItemScroll = nil
            EquipUI.ClickLeftItemScroll = nil
        end
		if EquipEffectsUI.RefreshEffe == EquipStuntUI.RefreshItemScroll then
			EquipEffectsUI.RefreshEffe = nil
		end
		if EquipEffectsUI.OnEffe == EquipStuntUI.OnEffeItemClick then
			EquipEffectsUI.OnEffe = nil
		end
        UILayout.UnRegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipStuntUI")
    else
        GUI.RegisterUIEvent(effeBtn, UCE.PointerClick, "EquipStuntUI", "OnProduceBtnClick")
        EquipUI.RefreshLeftItemScroll = EquipStuntUI.RefreshLeftItem
        EquipUI.ClickLeftItemScroll = EquipStuntUI.OnLeftItemClick
        UILayout.RegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipStuntUI")
		EquipEffectsUI.RefreshEffe = EquipStuntUI.RefreshItemScroll
		EquipEffectsUI.OnEffe = EquipStuntUI.OnEffeItemClick
    end
end
function EquipStuntUI.OnProduceBtnClick()
    local item = EquipStuntUI.GetItem()
	local effeItem = data.showeffectdata[data.skillIndex]
    if item ~= nil and item.id > 0 then
		local keyName = effeItem.keyName
		local count = effeItem.count
		local id = effeItem.id
		if count == 0 then
			local equipPage = EquipUI.guidt.GetUI("equipPage")
			local itemTips = Tips.CreateByItemKeyName(keyName,equipPage,"itemTips",0,0)
			GUI.SetHeight(itemTips,GUI.GetHeight(itemTips)+50)
			GUI.SetData(itemTips, "ItemId", tostring(id))
			guidt.BindName(itemTips,"itemTips")
			local wayBtn = GUI.ButtonCreate(itemTips, "wayBtn", 1800402110, 0, -20, Transition.ColorTint, "获取途径", 150, 50, false);
			UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"EquipStuntUI","OnClickItemWayBtn")
            GUI.AddWhiteName(itemTips, GUI.GetGuid(wayBtn))
		else
			local show = false
			if item.bagtype == item_container_type.item_container_equip then
				local bagtype = item_container_type.item_container_equip
				local eqiupItems = data.items[bagtype]
				for i = 1, #eqiupItems, 1 do
					local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", eqiupItems[i].guid, eqiupItems[i].bagtype)
					if DB.GetOnceSkillByKey1(Equip_Stunt).KeyName == keyName then
						show = true
					end
				end
			end
			if show then
				GlobalUtils.ShowBoxMsg2Btn("炼化提示","当前已穿戴该特技，重复穿戴不生效，是否确定炼化？","EquipStuntUI","是","confirm1","否")
			else
				EquipStuntUI.confirm1()
			end
		end
    end
end
function EquipStuntUI.confirm1()
	local item = EquipStuntUI.GetItem()
	local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", item.guid, item.bagtype)
	if DB.GetOnceSkillByKey1(Equip_Stunt).SkillQuality >= 4 then
		GlobalUtils.ShowBoxMsg2Btn("炼化提示","当前装备上的特技为高品质特技，炼化后该特技将被覆盖，是否确定炼化？","EquipStuntUI","是","confirm2","否")
	else
		EquipStuntUI.confirm2()
	end
end
function EquipStuntUI.confirm2()
	local item = EquipStuntUI.GetItem()
	local bagtype = data.getBagType()
	local isBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,item.guid,bagtype) == "1"
	local effeItem = data.showeffectdata[data.skillIndex]
	if effeItem.isBind and not isBind then
		GlobalUtils.ShowBoxMsg2Btn("炼化提示","您使用了绑定的"..effeItem.name.."，炼化后装备"..item.name.."也将被绑定，是否确定炼化？","EquipStuntUI","是","confirm3","否")
	else
		EquipStuntUI.confirm3()
	end
end
function EquipStuntUI.confirm3()
	local item = EquipStuntUI.GetItem()
	local effeItem = data.showeffectdata[data.skillIndex]
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquipSpecialEffect", "artificeStunt", item.guid, effeItem.key, effeItem.guid)
end
--道具获取途径
function EquipStuntUI.OnClickItemWayBtn()
	local tips = guidt.GetUI("itemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end
function EquipStuntUI.Show(reset)
	EquipStuntUI.GetSelfEquipInfo()
    if reset then
        data.index = 1
        data.type = 1
		data.skillIndex = 1
        data.indexGuid = nil
		EquipUI.SelectBagType(data)
		EquipStuntUI.GetData()
    end
    EquipStuntUI.SetVisible(true)
	EquipStuntUI.ClientRefresh()
end

function EquipStuntUI.Refresh()
	local effeItems = EquipStuntUI.serverData.EquipSpecialEffectConfig
	if effeItems ~= nil then
		data.effectdata = {}
		for k, v in pairs (effeItems) do
			local keyName = v.Artifice_Item_KeyName
			local item = DB.GetOnceItemByKey2(keyName)
			local grade = item.Grade
			local id = item.Id
			local temp = {
				id = id,
				grade = grade,
				keyName = keyName,
				name = item.Name
			}
			data.effectdata[k] = temp
		end
	end
    EquipStuntUI.ClientRefresh()
end

function EquipStuntUI.GetSelfEquipInfo()
    for key, value in pairs(data.items) do
        data.items[key] =
            EquipScrollItem.GetItemByType(
            key,
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
function EquipStuntUI.ClientRefresh()
    if data.index > #data.items[data.getBagType()] then
        data.index = 1
    end
    data.showeffectdata = {}
	for k, v in pairs (data.effectdata) do
		local item_GUIDList = LD.GetItemGuidsById(v.id)
		if item_GUIDList and item_GUIDList.Count ~= 0 then
			for i = 0 , item_GUIDList.Count -1  do -- 遍历所获取的格子
				local guid = item_GUIDList[i]
				local Count = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,guid))
				local isBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,guid) == "1"
				table.insert(data.showeffectdata,{ id = v.id, grade = v.grade, key = k, keyName = v.keyName,count = Count, name = v.name ,isBind = isBind, guid = tostring(guid)})
			end
		else
			table.insert(data.showeffectdata,{ id = v.id, grade = v.grade, key = k,keyName = v.keyName, count = 0, name = v.name, isBind = false, guid = ""})
		end
	end
	EquipStuntUI.sortGT()
    EquipStuntUI.RefreshUI()
end
function EquipStuntUI.CreateSubPage(equipPage)
    GameMain.AddListen("EquipStuntUI", "OnExitGame")
end

function EquipStuntUI.sortGT()
	table.sort(data.showeffectdata,function (eff1, eff2)
		local grade1 = eff1.grade
		local grade2 = eff2.grade
		local id1 = eff1.id
		local id2 = eff2.id
		local isBind1 = eff1.isBind
		local isBind2 = eff2.isBind
		local count1 = eff1.count
		local count2 = eff2.count
		if (count1 > 0 and count2 > 0) or (count1 == 0 and count2 == 0) then
			if grade1 ~= grade2 then
				return grade1 > grade2
			elseif id1 ~= id2 then
				return id1 > id2
			elseif isBind1 ~= isBind2 then
				return isBind2
			elseif count1 ~= count2 then
				return count1 > count2
			else
				return false
			end
		else
			return count1 > count2
		end
	end)
end

function EquipStuntUI.RefreshItemScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	local item = GUI.GetByGuid(guid)
	local effeItem = data.showeffectdata[index]
	local id = effeItem.id
	local count = effeItem.count
	local isBind = effeItem.isBind
	ItemIcon.BindItemId(item, id)
	if count <= 0 then
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1801100120")
	end
	if count > 1 then
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, count)
        GUI.SetVisible(GUI.ItemCtrlGetElement(item, eItemIconElement.RightBottomNum), true)
	else
		GUI.SetVisible(GUI.ItemCtrlGetElement(item, eItemIconElement.RightBottomNum), false)
	end
	GUI.ItemCtrlSetIconGray(item, not (count > 0))
	if isBind then
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.LeftTopSp, 1800707120);
		GUI.ItemCtrlSetElementRect(item, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
	else
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.LeftTopSp, nil);
	end
	if index == data.skillIndex then
        data.skillIndexGuid = guid
		GUI.ItemCtrlSelect(item)
    else
        GUI.ItemCtrlUnSelect(item)
    end
end

function EquipStuntUI.OnEffeItemClick(skillIndexGuid)
    local item = GUI.GetByGuid(skillIndexGuid)
    GUI.ItemCtrlSelect(item)
    data.skillIndex = GUI.ItemCtrlGetIndex(item) + 1
    if skillIndexGuid ~= data.skillIndexGuid then
		GUI.ItemCtrlUnSelect(item)
        data.skillIndexGuid = skillIndexGuid
    end
    EquipStuntUI.RefreshProduce()
end
function EquipStuntUI.RefreshLeftItem(guid, index)
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
function EquipStuntUI.OnLeftItemClick(guid)
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end
    EquipStuntUI.RefreshProduce()
	EquipStuntUI.ClientRefresh()
end
---@return eqiupItem
function EquipStuntUI.GetItem(index)
    if index == nil then
        index = data.index
    end
    local type = data.getBagType()
    return data.items[type][index]
end

function EquipStuntUI.RefreshProduce()
    UILayout.OnSubTabClickEx(data.type, EquipEnhanceUI.typeList)
    local type = data.getBagType()
    local normal = EquipStuntUI.GetItem()
	if normal ~= nil then
        local dyn = EquipUI.GetEquipData(normal.guid, type, normal.site)
        data.attrs[type][data.index] = {}
        LogicDefine.GetItemDynAttrDataByMark(
            dyn,
            LogicDefine.ItemAttrMark.Base,
            LogicDefine.ItemAttrMark.Enhance,
            data.attrs[type][data.index]
        )
    end
	local dynAttrs = data.attrs[type][data.index]
	local effectItemScroll = EquipUI.guidt.GetUI("effectItemScroll")
	GUI.LoopScrollRectSetTotalCount(effectItemScroll, #data.showeffectdata)
    GUI.LoopScrollRectRefreshCells(effectItemScroll)
	if normal == nil then
		EquipStuntUI.RefreshResultInfo(nil, nil, nil)
	else
		EquipStuntUI.RefreshResultInfo(nil, normal, dynAttrs)
	end

	local effItem = data.showeffectdata[data.skillIndex]
	if not effItem then
		EquipStuntUI.RefreshResultEffeInfo(nil, nil)
	else
		local keyName = effItem.keyName
		local skillItem = DB.GetOnceItemByKey2(keyName)
		EquipStuntUI.RefreshResultEffeInfo(nil, skillItem)
	end
end
function EquipStuntUI.OnConsumeItemClick(guid)
    local consumeMax = 3
    local itemInfo = EquipStuntUI.GetItem()
    for i = 1, consumeMax do
        local item = EquipUI.guidt.GetUI("consumeItem" .. i)
        if guid == GUI.GetGuid(item) then
            Tips.CreateByItemId(
                data.info[itemInfo.id].item[i].id,
                EquipUI.guidt.GetUI("equipPage"),
                "tips",
                0,
                0
            )
        end
    end
end

function EquipStuntUI.RefreshConsumeItem()
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
    EquipUI.RefreshConsumeItemEx(#consumeXPos, {}, consumeXPos)
    EquipUI.RefreshConsumeCoin(RoleAttr.RoleAttrIngot, 0)
end
function EquipStuntUI.OnBuildSucces()
    -- GUI.OpenWnd("ShowEffectUI", 3000001739)
    -- ShowEffectUI.SetTimeOff(1)
end