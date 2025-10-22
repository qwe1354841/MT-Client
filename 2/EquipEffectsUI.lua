local EquipEffectsUI = {
    ---@type table<number,>
    serverData = {}
}
_G.EquipEffectsUI =EquipEffectsUI 
local MaxArtificeCnt = 2
EquipEffectsUI.ClickItemGuid = ""
local guidt = UILayout.NewGUIDUtilTable()
function EquipEffectsUI.InitData()
	if EquipEffectsUI.serverData then
		EquipEffectsUI.serverData.Edition = nil
	end
    return {
        -- 背包中，装备中类型
        type = 1,
        -- 选中的道具下标
        index = 1,
        -- 选中的道具uiGuId
        indexGuid = int64.new(0),
        -- 可用道具
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
		effectdata ={},
		showeffectdata ={},
    }
end
local data = EquipEffectsUI.InitData()
function EquipEffectsUI.OnExitGame()
    data = EquipEffectsUI.InitData()
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

function EquipEffectsUI.RefreshResultInfo(bg, eqiupItemTable, eqiupItemAttrTable)
	local equipPage = bg or EquipUI.guidt.GetUI("equipPage")
	local nbg = GUI.GetChild(equipPage, "nbg", false)
	local vbg1 = GUI.GetChild(nbg, "vbg1", false)
	local icon = GUI.GetChild(vbg1, "itemIcon", false)
	local name = GUI.GetChild(vbg1, "name", false)
	local enhanceLv = GUI.GetChild(vbg1, "nameEx", false)
	local lv = GUI.GetChild(vbg1, "lv", false)
	local equipType = GUI.GetChild(vbg1, "equipType", false)
	local src = GUI.GetChild(vbg1, "src", false)
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
			GUI.SetColor(attText, UIDefine.BrownColor)
			local value = GUI.CreateStatic(attText, "value", "9999", 22, 0, 200, 30)
			GUI.StaticSetFontSize(value, UIDefine.FontSizeM)
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
		if Equip_SpecialEffect ~= 0 then
			GUI.SetVisible(icon2, true)
			GUI.SetVisible(icon3, false)
			ItemIcon.BindSkillId(icon2, Equip_SpecialEffect)
			GUI.StaticSetText(effectsText, "【"..DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name.."】")
			GUI.SetColor(effectsText, UIDefine.GradeColor[itemGrade1])
			GUI.SetColor(name2, UIDefine.GradeColor[itemGrade1])
			if itemGrade1 == 1 then
				GUI.SetColor(effectsText, UIDefine.BrownColor)
			end
			GUI.StaticSetText(name2, DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name)
			GUI.StaticSetText(txt2, DB.GetOnceSkillByKey1(Equip_SpecialEffect).Info)
			effectsText:RegisterEvent(UCE.PointerClick)
			GUI.SetIsRaycastTarget(effectsText, true)
			GUI.UnRegisterUIEvent(effectsText, UCE.PointerClick, "EquipStuntUI", "onSkillTipClick")
			GUI.RegisterUIEvent(effectsText, UCE.PointerClick, "EquipEffectsUI", "onSkillTipClick")
		else
			GUI.SetVisible(icon2, false)
			GUI.SetVisible(icon3, true)
			GUI.StaticSetText(effectsText, "无")
			GUI.StaticSetText(name2, "未获得")
			GUI.SetColor(effectsText, UIDefine.BrownColor)
			GUI.SetColor(name2, UIDefine.BrownColor)
			GUI.StaticSetText(txt2, "")
			GUI.SetIsRaycastTarget(effectsText, false)
			GUI.UnRegisterUIEvent(effectsText, UCE.PointerClick, "EquipEffectsUI", "onSkillTipClick")
		end
		if Equip_Stunt ~= 0 then
			GUI.StaticSetText(stuntText, "【"..DB.GetOnceSkillByKey1(Equip_Stunt).Name.."】")
			GUI.SetColor(stuntText, UIDefine.GradeColor[itemGrade2])
			if itemGrade2 == 1 then
				GUI.SetColor(stuntText, UIDefine.BrownColor)
			end
			stuntText:RegisterEvent(UCE.PointerClick)
			GUI.SetIsRaycastTarget(stuntText, true)
			GUI.UnRegisterUIEvent(effectsText, UCE.PointerClick, "EquipStuntUI", "onSkillTipClick2")
			GUI.RegisterUIEvent(stuntText, UCE.PointerClick, "EquipEffectsUI", "onSkillTipClick2")
		else
			GUI.StaticSetText(stuntText, "无")
			GUI.SetColor(stuntText, UIDefine.BrownColor)
			GUI.SetIsRaycastTarget(stuntText, false)
			GUI.UnRegisterUIEvent(stuntText, UCE.PointerClick, "EquipEffectsUI", "onSkillTipClick2")
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

function EquipEffectsUI.RefreshResultEffeInfo(bg, itemTable)
	local equipPage = bg or EquipUI.guidt.GetUI("equipPage")
	local nbg = GUI.GetChild(equipPage, "nbg", false)
	local vbg4 = GUI.GetChild(nbg, "vbg4", false)
	local itemIcon = GUI.GetChild(vbg4, "itemIcon", false)
	local name = GUI.GetChild(vbg4, "name", false)
	local effectInfoScroll = GUI.GetChild(vbg4, "effectInfoScroll", false)
	local info = GUI.GetChild(vbg4, "txt", true)
	if not itemTable then
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

function EquipEffectsUI.GetData()
	if not EquipEffectsUI.serverData.Edition then
		EquipEffectsUI.serverData.Edition = "0"
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquipSpecialEffect", "getData",EquipEffectsUI.serverData.Edition, 1)
end
function EquipEffectsUI.OnInEquipBtnClick()
    data.type = 1
    data.index = 1
	EquipEffectsUI.ClientRefresh()
end
function EquipEffectsUI.OnInBagBtnClick()
    data.type = 2
    data.index = 1
	EquipEffectsUI.ClientRefresh()
end
function EquipEffectsUI.ClickItem(guid)
	EquipEffectsUI.ClickItemGuid = guid
	EquipEffectsUI.RefreshUI()
    -- local items = data.items[data.getBagType()]
    -- for index, item in pairs(items) do
    --     if guid == tostring(item.guid) then
    --         data.index = index
    --     end
    -- end
end
--ui刷新
function EquipEffectsUI.RefreshUI()
    local items = data.items[data.getBagType()]
	if EquipEffectsUI.ClickItemGuid ~= "" then
		for i = 1, #items, 1 do
            local item = items[i]
            if EquipEffectsUI.ClickItemGuid == tostring(item.guid) then
                table.remove(items,i)
                table.insert(items,1,item)
            end
        end
	end
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
    EquipEffectsUI.RefreshProduce()
    EquipEffectsUI.RefreshConsumeItem()
end
--强化ui底部name
local uiBKey = {
}
-- 关闭或者打开只属于子页签的东西
function EquipEffectsUI.SetVisible(visible)
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
	local equipPage = EquipUI.guidt.GetUI("equipPage")
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
    local enhanceBtn = EquipUI.guidt.GetUI("enhanceBtn")
	local vbg4 = GUI.GetChild(nbg, "vbg4", false)
	local effeBtn = GUI.GetChild(vbg4, "effectsBtn", false)
    
    if visible == false then
        GUI.UnRegisterUIEvent(effeBtn, UCE.PointerClick, "EquipEffectsUI", "OnProduceBtnClick")
        if EquipUI.RefreshLeftItemScroll == EquipEffectsUI.RefreshLeftItem then
            EquipUI.RefreshLeftItemScroll = nil
            EquipUI.ClickLeftItemScroll = nil
        end
		if EquipEffectsUI.RefreshEffe == EquipEffectsUI.RefreshEffeScoll then
			EquipEffectsUI.RefreshEffe = nil
		end
		if EquipEffectsUI.OnEffe == EquipEffectsUI.OnEffeEffeClick then
			OnEffeItemClick = nil
		end
        UILayout.UnRegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipEffectsUI")
		EquipEffectsUI.ClickItemGuid = ""
    else
        GUI.RegisterUIEvent(effeBtn, UCE.PointerClick, "EquipEffectsUI", "OnProduceBtnClick")
        EquipUI.RefreshLeftItemScroll = EquipEffectsUI.RefreshLeftItem
        EquipUI.ClickLeftItemScroll = EquipEffectsUI.OnLeftItemClick
        UILayout.RegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipEffectsUI")
		EquipEffectsUI.RefreshEffe = EquipEffectsUI.RefreshEffeScoll
		EquipEffectsUI.OnEffe = EquipEffectsUI.OnEffeEffeClick
    end
end
function EquipEffectsUI.OnProduceBtnClick()
    local item = EquipEffectsUI.GetItem()
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
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"EquipEffectsUI","OnClickItemWayBtn")
            GUI.AddWhiteName(itemTips, GUI.GetGuid(wayBtn))
		else
			local show = false
			if item.bagtype == item_container_type.item_container_equip then
				local bagtype = item_container_type.item_container_equip
				local eqiupItems = data.items[bagtype]
				for i = 1, #eqiupItems, 1 do
					local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", eqiupItems[i].guid, eqiupItems[i].bagtype)
					if DB.GetOnceSkillByKey1(Equip_SpecialEffect).KeyName == keyName then
						show = true
					end
				end
			end
			if show then
				GlobalUtils.ShowBoxMsg2Btn("炼化提示","当前已穿戴该特效，重复穿戴不生效，是否确定炼化？","EquipEffectsUI","是","confirm1","否")
			else
				EquipEffectsUI.confirm1()
			end
		end
    end
end
function EquipEffectsUI.confirm1()
	local item = EquipEffectsUI.GetItem()
	local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", item.guid, item.bagtype)
	if DB.GetOnceSkillByKey1(Equip_SpecialEffect).SkillQuality >= 4 then
		GlobalUtils.ShowBoxMsg2Btn("炼化提示","当前装备上的特效为高品质特效，炼化后该特效将被覆盖，是否确定炼化？","EquipEffectsUI","是","confirm2","否")
	else
		EquipEffectsUI.confirm2()
	end
end
function EquipEffectsUI.confirm2()
	local item = EquipEffectsUI.GetItem()
	local bagtype = data.getBagType()
	local isBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,item.guid,bagtype) == "1"
	local effeItem = data.showeffectdata[data.skillIndex]
	if effeItem.isBind and not isBind then
		GlobalUtils.ShowBoxMsg2Btn("炼化提示","您使用了绑定的"..effeItem.name.."，炼化后装备"..item.name.."也将被绑定，是否确定炼化？","EquipEffectsUI","是","confirm3","否")
	else
		EquipEffectsUI.confirm3()
	end
end
function EquipEffectsUI.confirm3()
	local item = EquipEffectsUI.GetItem()
	local effeItem = data.showeffectdata[data.skillIndex]
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquipSpecialEffect", "artificeSpecialEffect", item.guid, effeItem.key, effeItem.guid)
end
--道具获取途径
function EquipEffectsUI.OnClickItemWayBtn()
	local tips = guidt.GetUI("itemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end
function EquipEffectsUI.Show(reset)
	EquipEffectsUI.GetSelfEquipInfo()
    if reset then
        data.index = 1
        data.type = 1
		data.skillIndex = 1
        data.indexGuid = nil
		EquipUI.SelectBagType(data)
		EquipEffectsUI.GetData()
    end
    EquipEffectsUI.SetVisible(true)
	EquipEffectsUI.ClientRefresh()
end


-- 表单接受数据回调
function EquipEffectsUI.Refresh()
	local effeItems = EquipEffectsUI.serverData.EquipSpecialEffectConfig
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
    EquipEffectsUI.ClientRefresh()
end
--筛选道具
function EquipEffectsUI.GetSelfEquipInfo()
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
function EquipEffectsUI.ClientRefresh()
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
				table.insert(data.showeffectdata,{ id = v.id, grade = v.grade, key = k,keyName = v.keyName,count = Count, name = v.name, isBind = isBind, guid = tostring(guid)})
			end
		else
			table.insert(data.showeffectdata,{ id = v.id, grade = v.grade, key = k,keyName = v.keyName, count = 0, name = v.name, isBind = false, guid = ""})
		end
	end
	EquipEffectsUI.sortGT()
    EquipEffectsUI.RefreshUI()
end
function EquipEffectsUI.CreateSubPage(equipPage)
    GameMain.AddListen("EquipEffectsUI", "OnExitGame")
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local nbg = GUI.ImageCreate(equipPage, "nbg", "1800400010", 152, 30, false, 740, 502)
	local vbg1 = GUI.ImageCreate(nbg, "vbg1", "1800700050", -177, -113, false, 300, 220)
	local itemIcon = GUI.ItemCtrlCreate(vbg1, "itemIcon", UIDefine.ItemIconBg2[1], -89, -58)
	local name = GUI.CreateStatic(vbg1, "name", "", 70, -76, 200, 60)
	GUI.StaticSetAlignment(name, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeM)
    GUI.SetScale(name, UIDefine.FontSizeM2FontSizeXL)
    GUI.SetColor(name, UIDefine.BrownColor)
	local nameEx = GUI.CreateStatic(vbg1, "nameEx", "", 120, -76, 200, 60)
	GUI.StaticSetAlignment(nameEx, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(nameEx, UIDefine.FontSizeM)
    GUI.SetScale(nameEx, UIDefine.FontSizeM2FontSizeXL)
    GUI.SetColor(nameEx, UIDefine.EnhanceBlueColor)
	local lv = GUI.CreateStatic(vbg1, "lv", "", 60, -40, 200, 60)
	GUI.StaticSetAlignment(lv, TextAnchor.MiddleLeft)
	GUI.SetColor(lv, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(lv, UIDefine.FontSizeM)
	local equipType = GUI.CreateStatic(vbg1, "equipType", "", 110, -40, 200, 60)
	GUI.StaticSetAlignment(equipType, TextAnchor.MiddleLeft)
	GUI.SetColor(equipType, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(equipType, UIDefine.FontSizeM)
	local src = GUI.ScrollRectCreate(vbg1, "src", 25, 95, 300, 110,0,false,Vector2.New(300,30))
	UILayout.SetSameAnchorAndPivot(src, UILayout.TopLeft)
	local effects = GUI.CreateStatic(src, "effects", "特效:", 0, 4, 100, 60)
	GUI.StaticSetAlignment(effects, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(effects, UIDefine.FontSizeM)
    GUI.SetColor(effects, UIDefine.BrownColor)
	local stunt = GUI.CreateStatic(src, "stunt", "特技:", 0, 30, 100, 60)
	GUI.StaticSetAlignment(stunt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(stunt, UIDefine.FontSizeM)
    GUI.SetColor(stunt, UIDefine.BrownColor)
	local effectsText = GUI.CreateStatic(effects, "effectsText", "【随机】", 60, 0, 200, 30)
    GUI.StaticSetFontSize(effectsText, UIDefine.FontSizeM)
	GUI.SetColor(effectsText, UIDefine.BrownColor)
	local stuntText = GUI.CreateStatic(stunt, "stuntText", "【随机】", 60, 0, 200, 30)
    GUI.StaticSetFontSize(stuntText, UIDefine.FontSizeM)
	GUI.SetColor(stuntText, UIDefine.BrownColor)
	local vbg2 = GUI.ImageCreate(nbg, "vbg2", "1801100190", 179, -117, false, 348, 230)
	local line = GUI.ImageCreate(vbg2, "line", "1801100200", 0.4, 1.64, false, 372.59, 6.9)
	local itemIcon = GUI.ItemCtrlCreate(vbg2, "itemIcon", UIDefine.ItemIconBg2[1], -105, -56)
	local itemIcon = GUI.ItemCtrlCreate(vbg2, "itemIcon2", UIDefine.ItemIconBg2[1], -105, -56)
	local name = GUI.CreateStatic(vbg2, "name", "名称", 64, -56, 200, 60)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeM)
    GUI.SetScale(name, UIDefine.FontSizeM2FontSizeXL)
	GUI.SetColor(name, Color.New(132 / 255, 121 / 255, 113 / 255, 1))
	local txt = GUI.CreateStatic(vbg2, "txt", "功能", -7.7, 52.6, 270, 200)
	GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
	local vbg3 = GUI.ImageCreate(nbg, "vbg3", "1800700050", -183, 133, false, 345, 218)
	local effectItemScroll =
        GUI.LoopScrollRectCreate(
        vbg3,
        "effectItemScroll",
        0,
        0,
        360,
        190,
        "EquipEffectsUI",
        "CreatItemPool",
        "EquipEffectsUI",
        "RefreshItemScroll",
        0,
        false,
        Vector2.New(80, 80),
        4,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
	EquipUI.guidt.BindName(effectItemScroll, "effectItemScroll")
	local vbg4 = GUI.ImageCreate(nbg, "vbg4", "1800700050", 184, 133, false, 350, 218)
	local effectInfoScroll = GUI.ScrollRectCreate(
		vbg4, 
		"effectInfoScroll", 
		21, 
		20, 
		343, 
		50, 
		0, 
		false, 
		Vector2.New(306.5, 80), 
		UIAroundPivot.TopLeft ,
        UIAnchor.TopLeft , 
		1, 
		false
	)
	local itemIcon = GUI.ItemCtrlCreate(vbg4, "itemIcon", UIDefine.ItemIconBg2[1], -120, -52)
	local name = GUI.CreateStatic(vbg4, "name", "名称", 57, -52, 200, 60)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeM)
    GUI.SetScale(name, UIDefine.FontSizeM2FontSizeXL)
	GUI.SetColor(name, UIDefine.BrownColor)
	local txt = GUI.CreateStatic(effectInfoScroll, "txt", "功能", 9, 20, 270, 200)
	GUI.StaticSetAlignment(txt, TextAnchor.UpperLeft)
	GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetScale(txt, UIDefine.Vector3One)
	GUI.SetColor(txt, UIDefine.BrownColor)
	local tpsBtn = GUI.ButtonCreate(vbg4, "tipBtn", "1800702030", 150, -83, Transition.ColorTint)
	GUI.RegisterUIEvent(tpsBtn, UCE.PointerClick, "EquipEffectsUI", "onTipBtnClick");
	local effectsBtn = GUI.ButtonCreate(vbg4, "effectsBtn", "1800802040", 1.9073e-06, 71, Transition.ColorTint, "炼化")
	GUI.ButtonSetTextColor(effectsBtn, UIDefine.BrownColor)
	GUI.ButtonSetTextFontSize(effectsBtn, UIDefine.FontSizeM)
end

function EquipEffectsUI.onTipBtnClick()
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	-- 1.如果穿戴的装备有相同的特效或特技，只生效1个。\n2.如果穿戴的装备有不同等级的属性特效，属性可叠加。\n3.如果穿戴的装备有不同等级的效果特效（如：横扫或圣佑），只生效较高等级的特效。
	-- Tips.CreateHint("1.穿戴相同的特效或特技，只生效1个。\n2.穿戴不同等级的属性特效，属性可叠加。\n3.穿戴不同等级的效果特效（如：横扫或圣佑），只生效较高的特效。", equipPage, 230, 135, UILayout.Center, 431, 131)
	Tips.CreateHint("1.如果穿戴的装备有相同的特效或特技，则只生效1个。\n2.如果穿戴的装备有不同等级的属性特效，属性可叠加。\n3.如果穿戴的装备有不同等级的效果特效（如：横扫或圣佑），只生效较高等级的特效。", equipPage, 170, 135, UILayout.Center, 551, 131)
end

function EquipEffectsUI.onSkillTipClick()
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local normal = EquipEffectsUI.GetItem()
	local Equip_SpecialEffect = LD.GetItemIntCustomAttrByGuid("Equip_SpecialEffect", normal.guid, normal.bagtype)
	local name = DB.GetOnceSkillByKey1(Equip_SpecialEffect).Name
	local info = DB.GetOnceSkillByKey1(Equip_SpecialEffect).Info
	Tips.CreateHint(name..":\n"..info, equipPage, 300.6, -27, UILayout.Center, 358.8, 104.8)
end

function EquipEffectsUI.onSkillTipClick2()
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local normal = EquipEffectsUI.GetItem()
	local Equip_Stunt = LD.GetItemIntCustomAttrByGuid("Equip_Stunt", normal.guid, normal.bagtype)
	local name = DB.GetOnceSkillByKey1(Equip_Stunt).Name
	local info = DB.GetOnceSkillByKey1(Equip_Stunt).Info
	Tips.CreateHint(name..":\n"..info, equipPage, 300.6, -27, UILayout.Center, 358.8, 104.8)
end

function EquipEffectsUI.CreatItemPool()
	local scroll = EquipUI.guidt.GetUI("effectItemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = ItemIcon.Create(scroll, "effectItem" .. curCount, 0, 0, 80, 80)
	GUI.ItemCtrlSetElementValue(item, eItemIconElement.Selected, 1800400280)
	GUI.ItemCtrlSetElementRect(item, eItemIconElement.Selected, 0, 0, 88, 88)
	guidt.BindName(item, "item")
	GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipEffectsUI", "OnEffeItemClick")
    return item
end

function EquipEffectsUI.RefreshEffeScoll(parameter)
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

function EquipEffectsUI.RefreshItemScroll(parameter)
	if EquipEffectsUI.RefreshEffe ~= nil then
		EquipEffectsUI.RefreshEffe(parameter)
	end
end

function EquipEffectsUI.RefreshEffe(parameter)
	
end

function EquipEffectsUI.OnEffeEffeClick(skillIndexGuid)
	local item = GUI.GetByGuid(skillIndexGuid)
    GUI.ItemCtrlSelect(item)
    data.skillIndex = GUI.ItemCtrlGetIndex(item) + 1
    if skillIndexGuid ~= data.skillIndexGuid then
		GUI.ItemCtrlUnSelect(item)
        data.skillIndexGuid = skillIndexGuid
    end
    EquipEffectsUI.RefreshProduce()
end

function EquipEffectsUI.OnEffeItemClick(skillIndexGuid)
    if EquipEffectsUI.OnEffe ~= nil then
		EquipEffectsUI.OnEffe(skillIndexGuid)
	end
end

function EquipEffectsUI.OnEffe(skillIndexGuid)
	
end

function EquipEffectsUI.sortGT()
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

function EquipEffectsUI.RefreshLeftItem(guid, index)
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
function EquipEffectsUI.OnLeftItemClick(guid)
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end
    EquipEffectsUI.RefreshProduce()
	EquipEffectsUI.ClientRefresh()
end
---@return eqiupItem
function EquipEffectsUI.GetItem(index)
    if index == nil then
        index = data.index
    end
    local type = data.getBagType()
    return data.items[type][index]
end


-- 刷新结果
function EquipEffectsUI.RefreshProduce()
    UILayout.OnSubTabClickEx(data.type, EquipEnhanceUI.typeList)
    local type = data.getBagType()
    local normal = EquipEffectsUI.GetItem()
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
		EquipEffectsUI.RefreshResultInfo(nil, nil, nil)
	else
		EquipEffectsUI.RefreshResultInfo(nil, normal, dynAttrs)
	end

	local effItem = data.showeffectdata[data.skillIndex]
	if not effItem then
		EquipEffectsUI.RefreshResultEffeInfo(nil, nil)
	else
		local keyName = effItem.keyName
		local skillItem = DB.GetOnceItemByKey2(keyName)
		EquipEffectsUI.RefreshResultEffeInfo(nil, skillItem)
	end
end


function EquipEffectsUI.OnConsumeItemClick(guid)
    local consumeMax = 3
    local itemInfo = EquipEffectsUI.GetItem()
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
-- 刷新消耗道具
function EquipEffectsUI.RefreshConsumeItem()
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