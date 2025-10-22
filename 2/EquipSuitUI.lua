local EquipSuitUI = {
    ---@type table<number,>
    serverData = {}
}
_G.EquipSuitUI =EquipSuitUI 
EquipSuitUI.ClickItemGuid = ""
EquipSuitUI.GradeColor = {
    UIDefine.BrownColor,
    UIDefine.GreenColor,
    UIDefine.BlueColor,
    UIDefine.PurpleColor,
    UIDefine.OrangeColor,
    UIDefine.RedColor,
}
local guidt = UILayout.NewGUIDUtilTable()
function EquipSuitUI.InitData()
	if EquipSuitUI.serverData then
		EquipSuitUI.serverData.Edition = nil
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
		suits = {
			---@type enhanceDynAttrData[][]
            [item_container_type.item_container_equip] = {},
            ---@type enhanceDynAttrData[][]
            [item_container_type.item_container_bag] = {}
		},
		itemIndex = 1,
		itemIndexGuid = int64.new(0),
		suitdata ={},
		suitgradedata = {},
		showsuitdata ={},
		-- skillIndex = 1,
		-- effectdata ={},
		-- showeffectdata ={},
    }
end
local data = EquipSuitUI.InitData()
function EquipSuitUI.OnExitGame()
    data = EquipSuitUI.InitData()
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

function EquipSuitUI.RefreshResultInfo(bg, eqiupItemTable, eqiupItemSuitTable)
	local equipPage = bg or EquipUI.guidt.GetUI("equipPage")
	local suitPage = GUI.GetChild(equipPage, "suitPage", false)
	local suitInfo = GUI.GetChild(suitPage, "suitInfo", false)
	local icon = GUI.GetChild(suitInfo, "itemIcon", false)
	local name = GUI.GetChild(suitInfo, "name", false)
	local enhanceLv = GUI.GetChild(suitInfo, "nameEx", false)
	local lv = GUI.GetChild(suitInfo, "lv", false)
	local equipType = GUI.GetChild(suitInfo, "equipType", false)
	local src = GUI.GetChild(suitInfo, "src", false)
	local suits = GUI.GetChild(suitInfo, "suits", false)
	local suitsText = GUI.GetChild(suitInfo, "suitsText", false)

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
	if eqiupItemSuitTable and eqiupItemSuitTable.Suit_Name then
		GUI.StaticSetText(suitsText,eqiupItemSuitTable.Suit_Name)
		local suitgrade = data.suitgradedata[eqiupItemSuitTable.suitName].grade
		GUI.SetColor(suitsText,EquipSuitUI.GradeColor[suitgrade])
	else
		GUI.StaticSetText(suitsText,"无")
		GUI.SetColor(suitsText,UIDefine.BrownColor)
	end
	
	local curSuitInfo = GUI.GetChild(suitPage, "curSuitInfo", false)
	local curInfosrc = GUI.GetChild(curSuitInfo, "curInfosrc", false)
	local suitText = GUI.GetChild(curSuitInfo, "suitText", false)
	
	if eqiupItemSuitTable and eqiupItemSuitTable.Suit_Name then
		GUI.SetVisible(curInfosrc,true)
		GUI.SetVisible(suitText,false)
		local count = 1
		local num = eqiupItemSuitTable.suitsNum
		local suitName = GUI.GetChild(curInfosrc, "suitName", false)
		if suitName == nil then
			suitName = GUI.CreateStatic(curInfosrc, "suitName", "名称", 0, 4, 200, 30)
			UILayout.StaticSetFontSizeColorAlignment(suitName, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
		end
		local suitgrade = data.suitgradedata[eqiupItemSuitTable.suitName].grade
		GUI.StaticSetText(suitName,eqiupItemSuitTable.Suit_Name .. "(" .. num .. "/" .. eqiupItemSuitTable.Total .. ")")
		GUI.SetColor(suitName,EquipSuitUI.GradeColor[suitgrade])
		local curCount = GUI.GetChildCount(curInfosrc)
		for i = 1, curCount do
			local suitLable = GUI.GetChild(curInfosrc, "suitLable"..i, false)
			GUI.SetVisible(suitLable,false)
		end
		for i = 1, eqiupItemSuitTable.Total do
			if eqiupItemSuitTable.Size[i] then
				for j = 1, #eqiupItemSuitTable.Size[i].Attr do
					local attrDB = DB.GetOnceAttrByKey2(eqiupItemSuitTable.Size[i].Attr[j][1])
					if attrDB.Id~=0 then
						local suitLable = GUI.GetChild(curInfosrc, "suitLable"..count, false)
						local suitStateLable = GUI.GetChild(suitLable, "suitStateLable", false)
						if suitLable == nil then
							suitLable = GUI.CreateStatic(curInfosrc, "suitLable"..count, "属性", 0, 4, 200, 30)
							UILayout.StaticSetFontSizeColorAlignment(suitLable, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
							suitStateLable = GUI.CreateStatic(suitLable, "suitStateLable", "(未达成)", 0, 0, 200, 30)
							UILayout.StaticSetFontSizeColorAlignment(suitStateLable, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
						end
						local state="(未达成)"
						local stateColor = UIDefine.BrownColor
                        if num>=i then
                            state="(已达成)"
							stateColor = UIDefine.Green7Color
                        end
						local suitValue = "["..i.."]"..UIDefine.GetAttrDesStr(attrDB.Id,eqiupItemSuitTable.Size[i].Attr[j][2])
						GUI.SetVisible(suitLable,true)
						GUI.StaticSetText(suitLable,suitValue)
						GUI.StaticSetText(suitStateLable,state)
						GUI.SetPositionX(suitStateLable,GUI.GetPositionX(suitLable)+GUI.StaticGetLabelPreferWidth(suitLable))
						GUI.SetColor(suitStateLable,stateColor)
						count = count + 1
					end
				end
			end
		end
	else
		GUI.SetVisible(curInfosrc,false)
		GUI.SetVisible(suitText,true)
	end
	if eqiupItemTable ~= nil then
		GUI.SetVisible(name, true)
		GUI.SetVisible(enhanceLv, true)
		GUI.SetVisible(lv, true)
		GUI.SetVisible(equipType, true)
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
		GUI.SetVisible(name, true)
		GUI.StaticSetText(name,"当前未选中道具")
		GUI.SetVisible(enhanceLv, false)
		GUI.SetVisible(lv, false)
		GUI.SetVisible(equipType, false)
	end
	GUI.SetPositionX(suitsText,GUI.GetPositionX(suits) + GUI.StaticGetLabelPreferWidth(suits) + 20)
	GUI.ScrollRectSetNormalizedPosition(src,Vector2.New(0,1))
end

function EquipSuitUI.RefreshResultSuitInfo(bg, itemTable)
	local equipPage = bg or EquipUI.guidt.GetUI("equipPage")
	local suitPage = GUI.GetChild(equipPage, "suitPage", false)
	local selectSuitInfo = GUI.GetChild(suitPage, "selectSuitInfo", false)
	local selectInfosrc = GUI.GetChild(selectSuitInfo, "selectInfosrc", false)
	local suitText = GUI.GetChild(selectSuitInfo, "suitText", false)
	local bottomGroup = GUI.GetChild(suitPage, "bottomGroup", false)
	local consumeBg = GUI.GetChild(bottomGroup, "consumeBg", false)
	local coinIcon = GUI.GetChild(consumeBg, "coin", false)
	local coinNum = GUI.GetChild(consumeBg, "num", false)
	local rateNum = GUI.GetChild(bottomGroup, "rateNum", false)
	local moneyType = UIDefine.MoneyTypes[5]
	local moneyValue = 100
	if itemTable and itemTable.suit_keyname then
		local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
		local suitName = itemTable.suit_keyname
		local num=0;
		local capacity=LD.GetBagCapacity(item_container_type.item_container_equip)
		for i = 0, capacity-1 do
			local suitName2=LD.GetItemStrCustomAttrByIndex(GlobalUtils.suitConfig.Sign_STR,i, item_container_type.item_container_equip)
			if suitName2==suitName then
				num=num+1;
			end
		end
		local config=GlobalUtils.suitConfig[suitName];
		local suitgrade = data.suitgradedata[suitName].grade
		local lable = config.Suit_Name .. "(" .. num .. "/" .. config.Total .. ")"
		GUI.SetVisible(selectInfosrc,true)
		GUI.SetVisible(suitText,false)
		local count = 1
		local suitName = GUI.GetChild(selectInfosrc, "suitName", false)
		local suitLevel = GUI.GetChild(suitName, "suitLevel", false)
		if suitName == nil then
			suitName = GUI.CreateStatic(selectInfosrc, "suitName", "名称", 0, 4, 200, 30)
			UILayout.StaticSetFontSizeColorAlignment(suitName, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
			suitLevel = GUI.CreateStatic(suitName, "suitLevel", "(100级)", 0, 0, 200, 30)
			UILayout.StaticSetFontSizeColorAlignment(suitLevel, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
		end
		GUI.StaticSetText(suitName,lable)
		if roleLevel < itemTable.level then
			GUI.StaticSetText(suitLevel,"(".. itemTable.level .."级)")
			GUI.SetColor(suitLevel,UIDefine.RedColor)
			GUI.SetPositionX(suitLevel,GUI.GetPositionX(suitName)+GUI.StaticGetLabelPreferWidth(suitName))
		else
			GUI.StaticSetText(suitLevel,nil)
		end
		
		GUI.SetColor(suitName,EquipSuitUI.GradeColor[suitgrade])
		local curCount = GUI.GetChildCount(selectInfosrc)
		for i = 1, curCount do
			local suitLable = GUI.GetChild(selectInfosrc, "suitLable"..i, false)
			GUI.SetVisible(suitLable,false)
		end
		for i = 1, config.Total do
			if config.Size[i] then
				for j = 1, #config.Size[i].Attr do
					local attrDB = DB.GetOnceAttrByKey2(config.Size[i].Attr[j][1])
					if attrDB.Id~=0 then
						local suitLable = GUI.GetChild(selectInfosrc, "suitLable"..count, false)
						local suitStateLable = GUI.GetChild(suitLable, "suitStateLable", false)
						if suitLable == nil then
							suitLable = GUI.CreateStatic(selectInfosrc, "suitLable"..count, "属性", 0, 4, 200, 30)
							UILayout.StaticSetFontSizeColorAlignment(suitLable, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
							suitStateLable = GUI.CreateStatic(suitLable, "suitStateLable", "(未达成)", 0, 0, 200, 30)
							UILayout.StaticSetFontSizeColorAlignment(suitStateLable, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
						end
						local state="(未达成)"
						local stateColor = UIDefine.BrownColor
                        if num>=i then
                            state="(已达成)"
							stateColor = UIDefine.Green7Color
                        end
						local suitValue = "["..i.."]"..UIDefine.GetAttrDesStr(attrDB.Id,config.Size[i].Attr[j][2])
						GUI.SetVisible(suitLable,true)
						GUI.StaticSetText(suitLable,suitValue)
						GUI.StaticSetText(suitStateLable,state)
						GUI.SetPositionX(suitStateLable,GUI.GetPositionX(suitLable)+GUI.StaticGetLabelPreferWidth(suitLable))
						GUI.SetColor(suitStateLable,stateColor)
						count = count + 1
					end
				end
			end
		end
		moneyType = UIDefine.MoneyTypes[itemTable.money_type]
		moneyValue = itemTable.money_value
		GUI.ImageSetImageID(coinIcon,UIDefine.AttrIcon[moneyType])
		GUI.StaticSetText(coinNum,UIDefine.ExchangeMoneyToStr(moneyValue))
		GUI.StaticSetText(rateNum,math.floor(itemTable.change_rate / 100) .. "%")
	else
		GUI.SetVisible(selectInfosrc,false)
		GUI.SetVisible(suitText,true)
		GUI.ImageSetImageID(coinIcon,UIDefine.AttrIcon[moneyType])
		GUI.StaticSetText(coinNum,moneyValue)
		GUI.StaticSetText(rateNum,"100%")
	end
	local l, h = int64.longtonum2(CL.GetAttr(moneyType))
    local curnum = l
    if curnum < moneyValue then
        GUI.SetColor(coinNum, UIDefine.RedColor)
    else
        GUI.SetColor(coinNum, UIDefine.WhiteColor)
    end
end
function EquipSuitUI.OnInEquipBtnClick()
    data.type = 1
    data.index = 1
	EquipSuitUI.ClientRefresh()
end
function EquipSuitUI.OnInBagBtnClick()
    data.type = 2
    data.index = 1
	EquipSuitUI.ClientRefresh()
end
function EquipSuitUI.ClickItem(guid)
	EquipSuitUI.ClickItemGuid = guid
	EquipSuitUI.RefreshUI()
    -- local items = data.items[data.getBagType()]
    -- for index, item in pairs(items) do
    --     if guid == tostring(item.guid) then
    --         data.index = index
    --     end
    -- end
end
--ui刷新
function EquipSuitUI.RefreshUI()
    local items = data.items[data.getBagType()]
	if EquipSuitUI.ClickItemGuid ~= "" then
		for i = 1, #items, 1 do
            local item = items[i]
            if EquipSuitUI.ClickItemGuid == tostring(item.guid) then
                table.remove(items,i)
                table.insert(items,1,item)
            end
        end
	end
	if EquipUI.CheckItemGuid ~= 0 then
		-- for i = 1, #data.showeffectdata, 1 do
		-- 	local effItem = data.showeffectdata[i]
		-- 	if effItem.guid == tostring(EquipUI.CheckItemGuid) then
		-- 		data.skillIndex = i
		-- 		EquipUI.CheckItemGuid = 0
		-- 		break
		-- 	end
		-- end
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
    EquipSuitUI.RefreshProduce()
end
-- 关闭或者打开只属于子页签的东西
function EquipSuitUI.SetVisible(visible)
    local ui = EquipUI.guidt.GetUI("EquipEnhanceUI")
    GUI.SetVisible(ui, visible)
	local EquipTop = EquipUI.guidt.GetUI("EquipTop")
	local bindBtn = GUI.GetChild(EquipTop, "bindBtn", false)
	GUI.SetVisible(bindBtn, not visible)
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local suitPage = GUI.GetChild(equipPage, "suitPage", false)
	GUI.SetVisible(suitPage, visible)
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
    
    if visible == false then
        if EquipUI.RefreshLeftItemScroll == EquipSuitUI.RefreshLeftItem then
            EquipUI.RefreshLeftItemScroll = nil
            EquipUI.ClickLeftItemScroll = nil
        end
        UILayout.UnRegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipSuitUI")
		EquipSuitUI.ClickItemGuid = ""
    else
        EquipUI.RefreshLeftItemScroll = EquipSuitUI.RefreshLeftItem
        EquipUI.ClickLeftItemScroll = EquipSuitUI.OnLeftItemClick
        UILayout.RegisterSubTabUIEvent(EquipEnhanceUI.typeList, "EquipSuitUI")
    end
end
function EquipSuitUI.OnSuitBtnClick()
    local item = EquipSuitUI.GetItem()
	local dynSuit = data.suits[data.getBagType()][data.index]
	local suitItem = data.showsuitdata[data.itemIndex]
    if item ~= nil and item.id > 0 then
		local keyName = suitItem.item_keyname
		local count = suitItem.count
		local id = suitItem.id
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
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"EquipSuitUI","OnClickItemWayBtn")
            GUI.AddWhiteName(itemTips, GUI.GetGuid(wayBtn))
		else
			local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
			if roleLevel < suitItem.level then
				CL.SendNotify(NOTIFY.ShowBBMsg,"使用等级不足")
				return
			end
			if dynSuit and dynSuit.Suit_Name then
				if suitItem.suit_keyname == dynSuit.suitName then
					CL.SendNotify(NOTIFY.ShowBBMsg,"相同的套装不能替换")
					return
				end
				local config=GlobalUtils.suitConfig[suitItem.suit_keyname];
				local suitgrade1 = data.suitgradedata[dynSuit.suitName].grade
				local suitgrade2 = data.suitgradedata[suitItem.suit_keyname].grade
				GlobalUtils.ShowBoxMsg2Btn("符印提示","是否确定将<color=#"..UIDefine.GradeColorLabel[suitgrade1]..">"..dynSuit.Suit_Name.."</color>套装替换为<color=#"..UIDefine.GradeColorLabel[suitgrade2]..">"..config.Suit_Name.."</color>套装，替换可能会拆散当前已激活的套装效果，请谨慎操作","EquipSuitUI","是","confirm1","否")
			else
				EquipSuitUI.confirm1()
			end
		end
    end
end
function EquipSuitUI.confirm1()
	local item = EquipSuitUI.GetItem()
	local bagtype = data.getBagType()
	local isBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,item.guid,bagtype) == "1"
	local suitItem = data.showsuitdata[data.itemIndex]
	if suitItem.isBind and not isBind then
		GlobalUtils.ShowBoxMsg2Btn("符印提示","当前选择的符印为绑定道具，使用后装备也会绑定，是否继续？","EquipSuitUI","是","confirm2","否")
	else
		EquipSuitUI.confirm2()
	end
end
function EquipSuitUI.confirm2()
	local item = EquipSuitUI.GetItem()
	local suitItem = data.showsuitdata[data.itemIndex]
	CL.SendNotify(NOTIFY.SubmitForm, "FormSuit", "change_by_item", item.guid, suitItem.guid)
end
--道具获取途径
function EquipSuitUI.OnClickItemWayBtn()
	local tips = guidt.GetUI("itemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end
function EquipSuitUI.Show(reset)
	EquipSuitUI.GetSelfEquipInfo()
    if reset then
        data.index = 1
        data.type = 1
		data.itemIndex = 1
        data.indexGuid = nil
		EquipUI.SelectBagType(data)
		EquipSuitUI.GetSuitData()
    end
    EquipSuitUI.SetVisible(true)
	EquipSuitUI.ClientRefresh()
end
function EquipSuitUI.GetSuitData()
	local suitItems = GlobalUtils.suitChangeItemConfig
	local suitData = GlobalUtils.suitConfig
	if suitItems ~= nil then
		data.suitdata = {}
		data.suitgradedata = {}
		for key, value in pairs(suitItems) do
			local itemKeyName = key
			local itemDB = DB.GetOnceItemByKey2(itemKeyName)
			local grade = itemDB.Grade
			local id = itemDB.Id
			local level = itemDB.Level
			data.suitdata[key] = value
			data.suitdata[key].grade = grade
			data.suitdata[key].id = id
			data.suitdata[key].level = level
			data.suitgradedata[value.suit_keyname] = {}
			data.suitgradedata[value.suit_keyname].grade = grade
		end
	end
	if suitData ~= nil then
		for key, value in pairs(suitData) do
			if data.suitgradedata[key] == nil then
				data.suitgradedata[key] = {}
				data.suitgradedata[key].grade = 1
			end
		end
	end
end
--筛选道具
function EquipSuitUI.GetSelfEquipInfo()
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
function EquipSuitUI.ClientRefresh()
    if data.index > #data.items[data.getBagType()] then
        data.index = 1
    end
	data.showsuitdata = {}
	local subtype = 0
	local normal = EquipSuitUI.GetItem()
	if normal ~= nil then
		subtype = normal.subtype
	end
	for key, v in pairs(data.suitdata) do
		if v["sub_type_" .. subtype] == 1 then
			local item_GUIDList = LD.GetItemGuidsById(v.id)
			if item_GUIDList and item_GUIDList.Count ~= 0 then
				for i = 0 , item_GUIDList.Count -1  do -- 遍历所获取的格子
					local guid = item_GUIDList[i]
					local Count = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,guid))
					local isBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,guid) == "1"
					table.insert(data.showsuitdata,{ id = v.id, grade = v.grade, level = v.level, item_keyname = key,suit_keyname = v.suit_keyname,change_rate = v.change_rate,money_type = v.money_type,money_value = v.money_value,count = Count, isBind = isBind, guid = tostring(guid)})
				end
			else
				table.insert(data.showsuitdata,{ id = v.id, grade = v.grade, level = v.level, item_keyname = key,suit_keyname = v.suit_keyname,change_rate = v.change_rate,money_type = v.money_type,money_value = v.money_value, count = 0, isBind = false, guid = ""})
			end
		end
	end
	if data.itemIndex > #data.showsuitdata then
		data.itemIndex = 1
	end
	EquipSuitUI.sortGT()
    EquipSuitUI.RefreshUI()
end


function EquipSuitUI.CreateSubPage(equipPage)
    GameMain.AddListen("EquipSuitUI", "OnExitGame")
	local equipPage = EquipUI.guidt.GetUI("equipPage")
	local suitPage = GUI.ImageCreate(equipPage, "suitPage", "1800400010", 152, 30, false, 740, 502)
	local suitInfo = GUI.ImageCreate(suitPage, "suitInfo", "1800700050", 10, 15, false, 340, 435)
	UILayout.SetSameAnchorAndPivot(suitInfo, UILayout.TopLeft)
	local itemIcon = GUI.ItemCtrlCreate(suitInfo, "itemIcon", UIDefine.ItemIconBg2[1], 25, 15)
	local name = GUI.CreateStatic(suitInfo, "name", "武器", 120, 10, 200, 60)
	UILayout.StaticSetFontSizeColorAlignment(name, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
	GUI.SetScale(name, UIDefine.FontSizeM2FontSizeXL)
	local nameEx = GUI.CreateStatic(suitInfo, "nameEx", "+5", 160, 10, 200, 60)
	UILayout.StaticSetFontSizeColorAlignment(nameEx, UIDefine.FontSizeM, UIDefine.EnhanceBlueColor, TextAnchor.MiddleLeft)
	GUI.SetScale(nameEx, UIDefine.FontSizeM2FontSizeXL)
	local lv = GUI.CreateStatic(suitInfo, "lv", "5级", 120, 51, 200, 60)
	UILayout.StaticSetFontSizeColorAlignment(lv, UIDefine.FontSizeM, UIDefine.Yellow2Color, TextAnchor.MiddleLeft)
	local equipType = GUI.CreateStatic(suitInfo, "equipType", "重剑", 160, 51, 200, 60)
	UILayout.StaticSetFontSizeColorAlignment(equipType, UIDefine.FontSizeM, UIDefine.Yellow2Color, TextAnchor.MiddleLeft)
	local suits = GUI.CreateStatic(suitInfo, "suits", "套装效果", 25, 105, 100, 30)
	UILayout.StaticSetFontSizeColorAlignment(suits, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
	local suitsText = GUI.CreateStatic(suitInfo, "suitsText", "无", 60, 105, 200, 30)
    UILayout.StaticSetFontSizeColorAlignment(suitsText, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
	local suitLine = GUI.ImageCreate(suitInfo, "suitLine", "1800408420", 0, 140,false)
	UILayout.SetSameAnchorAndPivot(suitLine, UILayout.Top)
	
	local suitItemScroll = GUI.LoopScrollRectCreate(suitInfo,"suitItemScroll",-10,180,360,240,"EquipSuitUI","CreatItemPool","EquipSuitUI","RefreshItemScroll",
        0,false,Vector2.New(80, 80),4,UIAroundPivot.Top,UIAnchor.Top)
	EquipUI.guidt.BindName(suitItemScroll, "suitItemScroll")

	local curSuitInfo = GUI.ImageCreate(suitPage, "curSuitInfo", "1800700050", 370, 15, false, 346, 213)
	UILayout.SetSameAnchorAndPivot(curSuitInfo, UILayout.TopLeft)
	local curSuitTitle = GUI.ImageCreate(curSuitInfo, "curSuitTitle", "1800601310", 0, 15, false)
	UILayout.SetSameAnchorAndPivot(curSuitTitle, UILayout.Top)
	local curSuitTitleText = GUI.CreateStatic(curSuitTitle, "curSuitTitleText", "当前套装", 0, 0, 200, 30)
    UILayout.StaticSetFontSizeColorAlignment(curSuitTitleText, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(curSuitTitleText, UILayout.Center)
	local curInfosrc = GUI.ScrollRectCreate(curSuitInfo, "curInfosrc", 80, 60, 300, 130,0,false,Vector2.New(300,30))
	local suitText = GUI.CreateStatic(curSuitInfo, "suitText", "当前装备套装为空", 0, 0, 200, 30)
	UILayout.StaticSetFontSizeColorAlignment(suitText, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(suitText, UILayout.Center)

	local selectSuitInfo = GUI.ImageCreate(suitPage, "selectSuitInfo", "1800700050", 370, 237, false, 346, 213)
	UILayout.SetSameAnchorAndPivot(selectSuitInfo, UILayout.TopLeft)
	local selectSuitTitle = GUI.ImageCreate(selectSuitInfo, "selectSuitTitle", "1800601310", 0, 15, false)
	UILayout.SetSameAnchorAndPivot(selectSuitTitle, UILayout.Top)
	local selectSuitTitleText = GUI.CreateStatic(selectSuitTitle, "selectSuitTitleText", "选择套装", 0, 0, 200, 30)
    UILayout.StaticSetFontSizeColorAlignment(selectSuitTitleText, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(selectSuitTitleText, UILayout.Center)
	local selectInfosrc = GUI.ScrollRectCreate(selectSuitInfo, "selectInfosrc", 80, 60, 300, 130,0,false,Vector2.New(300,30))
	local suitText = GUI.CreateStatic(selectSuitInfo, "suitText", "当前套装属性为空", 0, 0, 200, 30)
	UILayout.StaticSetFontSizeColorAlignment(suitText, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(suitText, UILayout.Center)

	local bottomGroup = GUI.GroupCreate(suitPage,"bottomGroup",0,450)
	UILayout.SetSameAnchorAndPivot(bottomGroup, UILayout.TopLeft)

	local consumeText = GUI.CreateStatic(bottomGroup, "curSuitTitleText", "消耗货币", 20, 7, 200, 30)
    UILayout.StaticSetFontSizeColorAlignment(consumeText, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)

	local consumeBg = GUI.ImageCreate(bottomGroup, "consumeBg", "1800700010", 140, 7, false, 120, 30)
    local coin = GUI.ImageCreate(consumeBg, "coin", "1800408280", -60, -2, false)
	UILayout.SetSameAnchorAndPivot(coin, UILayout.Center)
    local num = GUI.CreateStatic(consumeBg, "num", "100", 0, 0, 160, 30)
	UILayout.StaticSetFontSizeColorAlignment(num, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(num, UILayout.Center)

	local rateText = GUI.CreateStatic(bottomGroup, "rateText", "成功率", 340, 7, 100, 30)
	UILayout.StaticSetFontSizeColorAlignment(rateText, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    local rateNum = GUI.CreateStatic(bottomGroup, "rateNum", "100%", 410, 7, 100, 30)
	UILayout.StaticSetFontSizeColorAlignment(rateNum, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)

	local suitBtn = GUI.ButtonCreate(bottomGroup, "suitBtn", "1800002060", 595 , 3, Transition.ColorTint, "符印", 120, 40, false)
    GUI.SetEventCD(suitBtn, UCE.PointerClick, 0.5)
    GUI.ButtonSetTextColor(suitBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(suitBtn, UIDefine.FontSizeS)
    GUI.ButtonSetOutLineArgs(suitBtn, true, UIDefine.BlackColor, UIDefine.OutLineDistance)
	GUI.RegisterUIEvent(suitBtn, UCE.PointerClick, "EquipSuitUI", "OnSuitBtnClick")
end


function EquipSuitUI.CreatItemPool()
	local scroll = EquipUI.guidt.GetUI("suitItemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = ItemIcon.Create(scroll, "suitItem" .. curCount, 0, 0, 80, 80)
	GUI.ItemCtrlSetElementValue(item, eItemIconElement.Selected, 1800400280)
	GUI.ItemCtrlSetElementRect(item, eItemIconElement.Selected, 0, 0, 88, 88)
	GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipSuitUI", "OnSuitItemClick")
    return item
end

function EquipSuitUI.OnSuitItemClick(guid)
	local item = GUI.GetByGuid(guid)
    GUI.ItemCtrlSelect(item)
    data.itemIndex = GUI.ItemCtrlGetIndex(item) + 1
    if guid ~= data.itemIndexGuid then
		GUI.ItemCtrlUnSelect(item)
        data.itemIndexGuid = guid
    end
    EquipSuitUI.RefreshProduce()
end

function EquipSuitUI.RefreshItemScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	local item = GUI.GetByGuid(guid)
	local suitItem = data.showsuitdata[index]
	local id = suitItem.id
	local count = suitItem.count
	local isBind = suitItem.isBind
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
	if index == data.itemIndex then
        data.itemIndexGuid = guid
		GUI.ItemCtrlSelect(item)
    else
        GUI.ItemCtrlUnSelect(item)
    end
end

function EquipSuitUI.sortGT()
	table.sort(data.showsuitdata,function (suit1, suit2)
		local grade1 = suit1.grade
		local grade2 = suit2.grade
		local id1 = suit1.id
		local id2 = suit2.id
		local isBind1 = suit1.isBind
		local isBind2 = suit2.isBind
		local count1 = suit1.count
		local count2 = suit2.count
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

function EquipSuitUI.RefreshLeftItem(guid, index)
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
function EquipSuitUI.OnLeftItemClick(guid)
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end
    EquipSuitUI.RefreshProduce()
	EquipSuitUI.ClientRefresh()
end
---@return eqiupItem
function EquipSuitUI.GetItem(index)
    if index == nil then
        index = data.index
    end
    local type = data.getBagType()
    return data.items[type][index]
end


-- 刷新结果
function EquipSuitUI.RefreshProduce()
    UILayout.OnSubTabClickEx(data.type, EquipEnhanceUI.typeList)
    local type = data.getBagType()
    local normal = EquipSuitUI.GetItem()
	if normal ~= nil then
		local dyn = EquipUI.GetEquipData(normal.guid, type, normal.site)
        data.suits[type][data.index] = {}
		if GlobalUtils.suitConfig then
			local suitName=dyn:GetStrCustomAttr(GlobalUtils.suitConfig.Sign_STR)
			if suitName~="" then
				local num=0;
				local capacity=LD.GetBagCapacity(item_container_type.item_container_equip)
                for i = 0, capacity-1 do
                    local suitName2=LD.GetItemStrCustomAttrByIndex(GlobalUtils.suitConfig.Sign_STR,i, item_container_type.item_container_equip)
                    if suitName2==suitName then
                        num=num+1;
                    end
                end
				local config=GlobalUtils.suitConfig[suitName];
				if config then
					config.suitsNum = num
					config.suitName = suitName
					data.suits[type][data.index] = config
				end
			end
		end
	end
	local dynSuit = data.suits[type][data.index]
	local suitItemScroll = EquipUI.guidt.GetUI("suitItemScroll")
	GUI.LoopScrollRectSetTotalCount(suitItemScroll, #data.showsuitdata)
    GUI.LoopScrollRectRefreshCells(suitItemScroll)
	if normal == nil then
		EquipSuitUI.RefreshResultInfo(nil, nil, nil)
	else
		EquipSuitUI.RefreshResultInfo(nil, normal,dynSuit)
	end
	local suitItem = data.showsuitdata[data.itemIndex]
	if not suitItem then
		EquipSuitUI.RefreshResultSuitInfo(nil, nil)
	else
		EquipSuitUI.RefreshResultSuitInfo(nil, suitItem)
	end
end