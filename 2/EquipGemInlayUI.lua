local EquipGemInlayUI = {}

EquipGemInlayUI.MaxGemLevel = 10

local test = function()
end
_G.EquipGemInlayUI = EquipGemInlayUI
local _gt = UILayout.NewGUIDUtilTable()
EquipGemInlayUI.ClickItemGuid = ""
local typeList = {
	{
		"装备中",
		"inEquipBtn",
		"1800402030",
		"1800402032",
		"OnInEquipBtnClick",
		-448,
		-245,
		145,
		50,
		100,
		40,
		item_container_type.item_container_equip
	},
	{
		"背包中",
		"inBagBtn",
		"1800402030",
		"1800402032",
		"OnInBagBtnClick",
		-302,
		-245,
		145,
		50,
		100,
		40,
		item_container_type.item_container_bag
	}
}

function EquipGemInlayUI.InitData()
	return {
		-- 背包中，装备中类型
		type = 1,
		-- 选中的道具下标
		index = 1,
		-- 选中的道具uiGuId
		indexGuid = int64.new(0),
		equipGemIndex = 1;
		gemTypeIndex = 1;
		-- 可用道具
		items = {
			---@type eqiupItem[]
			[item_container_type.item_container_equip] = {},
			---@type eqiupItem[]
			[item_container_type.item_container_bag] = {}
		},
		gemGuids = {},
		-- allGemList = {},
		config = nil,
		visible = false;
	}
end
local data = EquipGemInlayUI.InitData()
function EquipGemInlayUI.OnExitGame()
	data = EquipGemInlayUI.InitData()
	---@return item_container_type
	data.getBagType = function()
		local type = typeList[data.type][12]
		return type
	end
end
---@return item_container_type
data.getBagType = function()
	local type = typeList[data.type][12]
	return type
end
local firstClick = false
function EquipGemInlayUI.OnInEquipBtnClick()
	test("==========OnInEquipBtnClick")
	data.type = 1
	data.index = 1
	data.equipGemIndex = 1
	data.gemTypeIndex = 1
	firstClick = true
	EquipGemInlayUI.Refresh()
end
function EquipGemInlayUI.OnInBagBtnClick()
	test("==========OnInBagBtnClick")
	data.type = 2
	data.index = 1
	data.equipGemIndex = 1
	data.gemTypeIndex = 1
	firstClick = true
	EquipGemInlayUI.Refresh()
end
function EquipGemInlayUI.ClickItem(guid)
	EquipGemInlayUI.ClickItemGuid = guid
	EquipGemInlayUI.Refresh()
    -- local items = data.items[data.getBagType()]
    -- for index, item in pairs(items) do
    --     if guid == tostring(item.guid) then
    --         data.index = index
    --     end
    -- end
	-- data.equipGemIndex = 1;
	-- data.gemTypeIndex = 1;
	-- EquipGemInlayUI.Refresh();
end
function EquipGemInlayUI.GetConfig(table)
	--if CL.GetMode() == 1 then
	--	local inspect = require("inspect")
	--	test(inspect(table))
	--end

	data.config = table;

	if data.visible == true then
		EquipGemInlayUI.Refresh();
	end

end

function EquipGemInlayUI.InlaySuccess()
	GUI.OpenWnd("ShowEffectUI", 3000001537)
	ShowEffectUI.SetTimeOff(1)

	local itemInfo = EquipGemInlayUI.GetItem();
	if itemInfo then
		local itemData = EquipUI.GetEquipData(itemInfo.guid, data.getBagType(), itemInfo.site)
		local gemCount, siteCount = LogicDefine.GetEquipGemCount(itemData)
		for i = data.equipGemIndex, siteCount do
			local gemId = itemData:GetIntCustomAttr(LogicDefine.ITEM_GemId_ .. i);
			if gemId == 0 then
				data.equipGemIndex = i;
				local equipGemScroll = EquipUI.guidt.GetUI("equipGemScroll")
				GUI.LoopScrollRectRefreshCells(equipGemScroll);
				return ;
			end
		end
		for i = 1, data.equipGemIndex do
			local gemId = itemData:GetIntCustomAttr(LogicDefine.ITEM_GemId_ .. i);
			if gemId == 0 then
				data.equipGemIndex = i;
				local equipGemScroll = EquipUI.guidt.GetUI("equipGemScroll")
				GUI.LoopScrollRectRefreshCells(equipGemScroll);
				return ;
			end
		end
	end

end

function EquipGemInlayUI.RemoveSuccess()
	GUI.OpenWnd("ShowEffectUI", 3000001627)
	ShowEffectUI.SetTimeOff(1)
end

--ui刷新
function EquipGemInlayUI.Refresh()
	--test("Refresh")
	-- EquipGemInlayUI.GetAllGemList()
	UILayout.OnSubTabClickEx(data.type, typeList)
	local items = data.items[data.getBagType()]
	if EquipGemInlayUI.ClickItemGuid ~= "" then
        for i = 1, #items, 1 do
            local item = items[i]
            if EquipGemInlayUI.ClickItemGuid == tostring(item.guid) then
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
	local itemInfo = EquipGemInlayUI.GetItem();
	local equipGemScroll = EquipUI.guidt.GetUI("equipGemScroll")
	local eqiupIcon = _gt.GetUI("eqiupIcon");
	local gemIcon_Left = _gt.GetUI("gemIcon_Left");
	local gemIcon_Right = _gt.GetUI("gemIcon_Right");
	local equipNameText = EquipUI.guidt.GetUI("equipNameText");
	local equipTypeText = _gt.GetUI("equipTypeText");
	local emptyText = _gt.GetUI("emptyText");

	if itemInfo then
		local itemData = EquipUI.GetEquipData(itemInfo.guid, data.getBagType(), itemInfo.site)
		ItemIcon.BindItemData(eqiupIcon, itemData)
		GUI.SetVisible(equipNameText, true)
		GUI.StaticSetText(equipNameText, itemInfo.name);
		GUI.SetVisible(equipTypeText, true)
		
		local itemId = itemInfo.id
		local itemDB = DB.GetOnceItemByKey1(itemId)
		
		if itemInfo.armorLevel == LogicDefine.ArmorLevel.Fairy then
			GUI.StaticSetText(equipTypeText, tostring(itemInfo.itemLv) .. "阶  仙器")
		else
			--GUI.StaticSetText(equipTypeText, tostring(itemInfo.itemLv) .. "级  " .. itemInfo.showType)
			local text = ""
			if string.find(itemInfo.showType,"无级别") then
				text = itemInfo.showType
			else
				text = tostring(itemDB['Level']) .. "级  " .. itemInfo.showType
			end
			GUI.StaticSetText(equipTypeText, text)
		end
		if itemData:GetIntCustomAttr(LogicDefine.ITEM_GemNum) == 0 then
			GUI.SetVisible(emptyText, true)
		else
			GUI.SetVisible(emptyText, false)
		end
		GUI.LoopScrollRectSetTotalCount(equipGemScroll, itemData:GetIntCustomAttr(LogicDefine.ITEM_GemNum))
		GUI.LoopScrollRectRefreshCells(equipGemScroll)
	else
		ItemIcon.SetEmpty(eqiupIcon)
		GUI.SetVisible(equipNameText, false)
		GUI.SetVisible(equipTypeText, false)
		GUI.SetVisible(emptyText, false)
		GUI.LoopScrollRectSetTotalCount(equipGemScroll, 0)
		GUI.LoopScrollRectRefreshCells(equipGemScroll)
	end
	
	if #items == 0 then
		for i = 1, #UIDefine.GemType do
			local gemTypeBtn = EquipUI.guidt.GetUI("gemTypeBtn" .. i);
			GUI.SetVisible(gemTypeBtn,true)
		end
		for i = 0, 2 do
			local equipGemItem = _gt.GetUI("equipGemItem"..i);
			local icon = GUI.GetChild(equipGemItem, "icon")
			local demountBtn = GUI.GetChild(equipGemItem, "demountBtn")
			local nameText = GUI.GetChild(equipGemItem, "nameText")
			local attrText = GUI.GetChild(equipGemItem, "attrText")
			local valueText = GUI.GetChild(equipGemItem, "valueText")
			local emptyText = GUI.GetChild(equipGemItem, "emptyText")
			local equipGemUpgradeBtn = GUI.GetChild(equipGemItem, "equipGemUpgradeBtn")
			ItemIcon.SetEmpty(icon)
			GUI.SetVisible(demountBtn, false)
			GUI.SetVisible(nameText, false)
			GUI.SetVisible(attrText, false)
			GUI.SetVisible(valueText, false)
			GUI.SetVisible(emptyText, true)
			GUI.StaticSetText(emptyText, "当前无装备")
			GUI.SetVisible(equipGemUpgradeBtn, false)
		end
		GUI.LoopScrollRectSetTotalCount(equipGemScroll, 3)
		GUI.LoopScrollRectRefreshCells(equipGemScroll)
	else
		for i = 1, #UIDefine.GemType do
			local gemTypeBtn = EquipUI.guidt.GetUI("gemTypeBtn" .. i);
			GUI.SetVisible(gemTypeBtn,false)
		end
	end
	--EquipUI.CheckEquipRedPoint()
	EquipGemInlayUI.RefreshGemListScr()
	
	local MergeList = _gt.GetUI("MergeList")
	GUI.LoopScrollRectSetTotalCount(MergeList, 6)
	GUI.LoopScrollRectRefreshCells(MergeList)
end

function EquipGemInlayUI.RefreshGemListScr()

	local site = -1;
	local itemInfo = EquipGemInlayUI.GetItem();
	if itemInfo then
		local itemDB = DB.GetOnceItemByKey1(itemInfo.id)
		if itemDB then
			site = LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
		end
	end

	local index = 0
	for i = 1, #UIDefine.GemType do
		local gemTypeBtn = EquipUI.guidt.GetUI("gemTypeBtn" .. i);
		local gemList = EquipUI.guidt.GetUI("gemList" .. i);
		local arrow = GUI.GetChild(gemTypeBtn, "arrow");
		if data.config ~= nil and site ~= -1 then
			if data.config[site][i] == true then
				index = index + 1;
				GUI.SetVisible(gemTypeBtn, true);
				GUI.SetData(gemTypeBtn, "Index", index)
				if index == data.gemTypeIndex then
					GUI.SetEulerAngles(arrow, Vector3.New(0, 0, -90));
				else
					GUI.SetEulerAngles(arrow, Vector3.New(0, 0, 90));
				end
			GUI.SetVisible(gemList, index == data.gemTypeIndex);
				if index == data.gemTypeIndex then
					EquipGemInlayUI.UpdateGemList(i)
				end
			else
				GUI.SetVisible(gemTypeBtn, false);
				GUI.SetVisible(gemList, false);
			end
		else
			--GUI.SetVisible(gemTypeBtn, false);
			--GUI.SetVisible(gemList, false);
			index = index + 1
			GUI.SetData(gemTypeBtn, "Index", index)
			GUI.SetVisible(gemList, index == data.gemTypeIndex);
			if index == data.gemTypeIndex then
				EquipGemInlayUI.UpdateGemList(i)
				GUI.SetEulerAngles(arrow, Vector3.New(0, 0, -90));
			else
				GUI.SetEulerAngles(arrow, Vector3.New(0, 0, 90));
			end
		end

		-- 小红点
		local isShowRedPoint = false
		if itemInfo and data.getBagType() == item_container_type.item_container_equip then
			local itemData = EquipUI.GetEquipData(itemInfo.guid, data.getBagType(), itemInfo.site)
			local itemGemBagByTypeList,itemGemBagByTypeLevelList = EquipGemInlayUI.GetItemGemBagByTypeList(i)
			local equipGemBagList,equipGemBagLevelList = EquipGemInlayUI.GetEquipGemBagList(site)
			local itemGemList,itemGemLevelList= EquipGemInlayUI.GetItemGemList(itemData)
			local maxGemlv = 0
			for m = 1, #equipGemBagLevelList, 1 do
				local bagGemlv = equipGemBagLevelList[m]
				if bagGemlv > maxGemlv then
					maxGemlv = bagGemlv
				end
			end
			local minitemGemlv = maxGemlv
			for m = 1, #itemGemLevelList, 1 do
				local itemGemlv = itemGemLevelList[m]
				if itemGemlv < minitemGemlv then
					minitemGemlv = itemGemlv
				end
			end
			for n = 1, #itemGemBagByTypeLevelList, 1 do
				local itemGemBagByTypelv = itemGemBagByTypeLevelList[n]
				if maxGemlv == itemGemBagByTypelv then
					isShowRedPoint = true
				end
			end
			if minitemGemlv >= maxGemlv then
				isShowRedPoint = false
			end
		end
		GlobalProcessing.SetRetPoint(gemTypeBtn,isShowRedPoint)
	end
end

-- 关闭或者打开只属于子页签的东西
function EquipGemInlayUI.SetVisible(visible)
	data.visible = visible;
	local gemInlayGroup = EquipUI.guidt.GetUI("gemInlayGroup")
	local EquipBottom = EquipUI.guidt.GetUI("EquipBottom")
	local check = EquipUI.guidt.GetUI("bindBtn")
	if visible == true then
		GUI.SetVisible(gemInlayGroup, true)
		GUI.SetVisible(EquipBottom, false);
		GUI.SetVisible(check, false);
		
		EquipUI.RefreshLeftItemScroll = EquipGemInlayUI.RefreshLeftItem
		EquipUI.ClickLeftItemScroll = EquipGemInlayUI.OnLeftItemClick
		-- GlobalProcessing.EquipGemInlayUI.CheckRedPoint_TB = "false"
	else
		GUI.SetVisible(gemInlayGroup, false)
		GUI.SetVisible(EquipBottom, true);
		GUI.SetVisible(check, true);
		
		if EquipUI.RefreshLeftItemScroll == EquipGemInlayUI.RefreshLeftItem then
			EquipUI.RefreshLeftItemScroll = nil
			EquipUI.ClickLeftItemScroll = nil
		end
		EquipGemInlayUI.ClickItemGuid = ""
	end

end

function EquipGemInlayUI.Show(reset)
	EquipGemInlayUI.GetSelfEquipInfo()
	if reset then
		data.index = 1
		data.type = 1
		data.indexGuid = nil
		data.equipGemIndex = 1;
		data.gemTypeIndex = 1;
		firstClick = true
		EquipUI.SelectBagType(data)
		if data.config == nil then
			CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipGem_GetStoneData")
		end
	end
	EquipGemInlayUI.SetVisible(true)
	EquipGemInlayUI.Refresh()
end

function EquipGemInlayUI.CreateSubPage(gemPage)
	GameMain.AddListen("EquipGemInlayUI", "OnExitGame")
	_gt = UILayout.NewGUIDUtilTable()
	--EquipGemMergeUI.ComposeData
	local gemInlayGroup = GUI.GroupCreate(gemPage, "gemInlayGroup", 0, 0, 0, 0)
	EquipUI.guidt.BindName(gemInlayGroup, "gemInlayGroup")
	
	UILayout.CreateSubTab(typeList, gemInlayGroup, "EquipGemInlayUI")
	
	local equipInfoBg = GUI.ImageCreate(gemInlayGroup, "equipInfoBg", "1800400200", -15, 35, false, 400, 510)
	UILayout.SetSameAnchorAndPivot(equipInfoBg, UILayout.Center);
	
	local decorate1 = GUI.ImageCreate(equipInfoBg, "decorate1", "1801502020", -145, -190)
	GUI.SetEulerAngles(decorate1, Vector3.New(0, 0, -180));
	
	local decorate2 = GUI.ImageCreate(equipInfoBg, "decorate2", "1801502020", 145, -190)
	GUI.SetEulerAngles(decorate2, Vector3.New(-180, 0, 0));
	
	local decorate3 = GUI.ImageCreate(equipInfoBg, "decorate3", "1800400250", 0, -170, false, 150, 150)
	
	local decorate4 = GUI.ImageCreate(equipInfoBg, "decorate4", "1800700150", -135, -70, false, 140, 10)
	
	local decorate5 = GUI.ImageCreate(equipInfoBg, "decorate5", "1800700150", 135, -70, false, 140, 10)
	GUI.SetEulerAngles(decorate5, Vector3.New(-180, 0, -180));
	
	local titleText = GUI.CreateStatic(equipInfoBg, "titleText", "宝石镶嵌", 0, -70, 150, 30);
	GUI.StaticSetFontSize(titleText, UIDefine.FontSizeXL);
	GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter);
	GUI.SetColor(titleText, UIDefine.BrownColor);
		
	--local equipGemUpgradeBg = GUI.ImageCreate(gemInlayGroup, "equipGemUpgradeBg", )
	
	local eqiupIcon = ItemIcon.Create(equipInfoBg, "eqiupIcon", 0, -195);							--中间预览(武器)
	_gt.BindName(eqiupIcon, "eqiupIcon")
	GUI.RegisterUIEvent(eqiupIcon, UCE.PointerClick, "EquipGemInlayUI", "OnEqiupIconClick");
	
	local equipNameText = GUI.CreateStatic(equipInfoBg, "equipNameText", "name", 0, -135, 350, 35, "system", true);
	GUI.StaticSetFontSize(equipNameText, UIDefine.FontSizeXL);
	GUI.StaticSetAlignment(equipNameText, TextAnchor.MiddleCenter);
	GUI.SetColor(equipNameText, UIDefine.BrownColor);
	EquipUI.guidt.BindName(equipNameText, "equipNameText")

	local equipTypeText = GUI.CreateStatic(equipInfoBg, "equipTypeText", "level  type", 0, -105, 350, 30);
	GUI.StaticSetFontSize(equipTypeText, UIDefine.FontSizeM);
	GUI.StaticSetAlignment(equipTypeText, TextAnchor.MiddleCenter);
	GUI.SetColor(equipTypeText, UIDefine.Yellow2Color);
	_gt.BindName(equipTypeText, "equipTypeText")
	
	local emptyText = GUI.CreateStatic(equipInfoBg, "emptyText", "无宝石镶嵌槽", 0, 80, 200, 35)
	GUI.SetColor(emptyText, UIDefine.GrayColor)
	GUI.StaticSetFontSize(emptyText, UIDefine.FontSizeXL)
	GUI.StaticSetAlignment(emptyText, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(emptyText, UILayout.Center);
	_gt.BindName(emptyText, "emptyText");
	
	local equipGemScroll = GUI.LoopScrollRectCreate(equipInfoBg, "equipGemScroll", 0, -5, 390, 305,
		"EquipGemInlayUI", "CreateEquipGemItem", "EquipGemInlayUI", "RefreshEquipGemScroll", 0, false,
		Vector2.New(385, 102), 1, UIAroundPivot.Top, UIAnchor.Top);
	EquipUI.guidt.BindName(equipGemScroll, "equipGemScroll")
	UILayout.SetSameAnchorAndPivot(equipGemScroll, UILayout.Bottom);
	
	local gemListBg = GUI.ImageCreate(gemInlayGroup, "gemListBg", "1800400200", 355, -220, false, 320, 510)
	UILayout.SetSameAnchorAndPivot(gemListBg, UILayout.Top);
	
	local decorate1 = GUI.ImageCreate(gemListBg, "decorate1", "1801502030", -78, 212)
	UILayout.SetSameAnchorAndPivot(decorate1, UILayout.Center);
	
	local gemListScroll = GUI.ScrollListCreate(gemListBg, "gemListScroll", 0, 10, 305, 490, false, UIAroundPivot.Top, UIAnchor.Top)
	UILayout.SetSameAnchorAndPivot(gemListScroll, UILayout.Top);

	for i = 1, #UIDefine.GemType do
		
		--宝石种类(物攻石，魔攻石这种)
		local gemTypeBtn = GUI.ButtonCreate(gemListScroll, "gemTypeBtn" .. i, "1800002030", 0, 0, Transition.ColorTint, "", 300, 65, false);
		GUI.RegisterUIEvent(gemTypeBtn, UCE.PointerClick, "EquipGemInlayUI", "OnGemTypeBtnClick");
		GUI.SetPreferredHeight(gemTypeBtn, 65)
		EquipUI.guidt.BindName(gemTypeBtn, "gemTypeBtn" .. i);
		GUI.SetData(gemTypeBtn, "GemType", i);
		
		--宝石种类_图标
		local icon = GUI.ImageCreate(gemTypeBtn, "icon", UIDefine.GemType[i].Icon, -75, 0, false, 50, 50)
		UILayout.SetSameAnchorAndPivot(icon, UILayout.Center);
		
		--宝石种类_名字
		local nameText = GUI.CreateStatic(gemTypeBtn, "nameText", UIDefine.GemType[i].Name, 15, 0, 200, 35);
		GUI.StaticSetFontSize(nameText, UIDefine.FontSizeXL);
		GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter);
		GUI.SetColor(nameText, UIDefine.BrownColor);
		UILayout.SetSameAnchorAndPivot(nameText, UILayout.Center);
		
		local arrow = GUI.ImageCreate(gemTypeBtn, "arrow", "1801208630", 105, 0)
		UILayout.SetSameAnchorAndPivot(arrow, UILayout.Center);
		GUI.SetEulerAngles(arrow, Vector3.New(0, 0, 90));
		
		--宝石详细列表
		local gemList = GUI.ListCreate(gemListScroll, "gemList" .. i, 0, 0, 285, 0, false);
		EquipUI.guidt.BindName(gemList, "gemList" .. i);
	end

	--"1800608770"	--无装备时的看板娘
	--"1800601250"	--对话框
	
	local GemUpgrade_panelCover = GUI.ImageCreate(gemInlayGroup, "GemUpgrade_panelCover", "1800400220", 0, 0, false, 2000, 2000)
	UILayout.SetAnchorAndPivot(GemUpgrade_panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(GemUpgrade_panelCover, true)
	_gt.BindName(GemUpgrade_panelCover, "GemUpgrade_panelCover")
	
	local panelBg = GUI.GroupCreate(GemUpgrade_panelCover, "panelBg", 0, -56, 670, 540)
    UILayout.SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)

    local center = GUI.ImageCreate(panelBg, "center", "1800600182", 0, 0, false, 670, 540 - 54)
    UILayout.SetAnchorAndPivot(center, UIAnchor.Bottom, UIAroundPivot.Bottom)
	
	local GemUpgrade_infoBg_1 = GUI.ImageCreate(center, "GemUpgrade_infoBg_1", "1800300040", 0,266, false, 628, 206)
	
	local GemUpgrade_infoBg_2 = GUI.ImageCreate(center, "GemUpgrade_infoBg_2", "1800300040", 0,74, false, 628, 186)

    local topBar = GUI.ImageCreate(panelBg, "topBar", "1800600183", 0, 30, false, 670, 54)
    UILayout.SetAnchorAndPivot(topBar, UIAnchor.Top, UIAroundPivot.Center)

    local topBarCenter = GUI.ImageCreate(panelBg, "topBarCenter", "1800600190", 0, 30, false, 270, 50)
    UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

    local tipLabel = GUI.CreateStatic(topBarCenter, "tipLabel", "快捷合成", 0, 0, 200, 40)
    GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(tipLabel, UIDefine.BrownColor)
    UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(tipLabel, UIDefine.FontSizeXXL)
	
	local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800302120", 0, 5, Transition.ColorTint)
    UILayout.SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
	GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "EquipGemInlayUI", "closeMethod")
	
	local MergeBtn = GUI.ButtonCreate(center, "MergeBtn", "1800302130", 236,17,Transition.ColorTint,"合成", 170, 50, false)
	GUI.ButtonSetTextColor(MergeBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(MergeBtn, UIDefine.FontSizeXL)
	GUI.ButtonSetOutLineArgs(MergeBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
	GUI.RegisterUIEvent(MergeBtn, UCE.PointerClick, "EquipGemInlayUI", "OnMergeBtnClick");
	_gt.BindName(MergeBtn, "MergeBtn")
	GUI.SetEventCD(MergeBtn,UCE.PointerClick, 2);
	
	local Txt_1_Mid = GUI.CreateStatic(GemUpgrade_infoBg_1, "Txt_1_Mid", "合成预览", 0,80,200,40)
	GUI.StaticSetAlignment(Txt_1_Mid, TextAnchor.MiddleCenter)
    GUI.SetColor(Txt_1_Mid, UIDefine.BrownColor)
    UILayout.SetAnchorAndPivot(Txt_1_Mid, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Txt_1_Mid, UIDefine.FontSizeL)
	
	local Txt_1_Mid_decorate_1 = GUI.ImageCreate(GemUpgrade_infoBg_1, "Txt_1_Mid_decorate_1", "1800700150", -205, 175, false, 200, 17)
	local Txt_1_Mid_decorate_2 = GUI.ImageCreate(GemUpgrade_infoBg_1, "Txt_1_Mid_decorate_2", "1800700150", 205, 175, false, 200, 17)
	GUI.SetEulerAngles(Txt_1_Mid_decorate_2, Vector3.New(-180, 0, -180));
	
	local Txt_1_Left = GUI.CreateStatic(GemUpgrade_infoBg_1, "Txt_1_Left", "当前使用宝石", -153,51, 200, 40)
	GUI.StaticSetAlignment(Txt_1_Left, TextAnchor.MiddleCenter)
    GUI.SetColor(Txt_1_Left, UIDefine.Yellow2Color)
    UILayout.SetAnchorAndPivot(Txt_1_Left, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Txt_1_Left, UIDefine.FontSizeS)
	
	local Txt_1_Right = GUI.CreateStatic(GemUpgrade_infoBg_1, "Txt_1_Right", "合成结果预览", 153,51, 200, 40)
	GUI.StaticSetAlignment(Txt_1_Right, TextAnchor.MiddleCenter)
    GUI.SetColor(Txt_1_Right, UIDefine.Yellow2Color)
    UILayout.SetAnchorAndPivot(Txt_1_Right, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Txt_1_Right, UIDefine.FontSizeS)
	_gt.BindName(Txt_1_Right, "Txt_1_Right")
	
	local gemIcon_decorate_1 = GUI.ImageCreate(GemUpgrade_infoBg_1, "gemIcon_decorate_1", "1801502090", -15,87,false, 170, 9)
	
	local gemIcon_Left_decorate_1 = GUI.ImageCreate(GemUpgrade_infoBg_1, "gemIcon_Left_decorate_1", "1801502080", -101,54,false, 35,75)
	
	local gemIcon_Left = ItemIcon.Create(GemUpgrade_infoBg_1, "gemIcon_Left", -155, 50);							--左侧宝石预览
	_gt.BindName(gemIcon_Left, "gemIcon_Left")
	GUI.RegisterUIEvent(gemIcon_Left, UCE.PointerClick, "EquipGemInlayUI", "On_gemIcon_Left_Click")
	
	local gemIcon_Right_decorate_1 = GUI.ImageCreate(GemUpgrade_infoBg_1, "gemIcon_Right_decorate_1", "1801502070", 94,46,false,60,92)
	
	local gemIcon_Right_decorate_2 = GUI.ImageCreate(GemUpgrade_infoBg_1, "gemIcon_Right_decorate_2", "1801502070", 215,46,false,60,92)
	GUI.SetEulerAngles(gemIcon_Right_decorate_2, Vector3.New(-180, 0, -180));
	
	local gemIcon_Right_Ex = GUI.ImageCreate(GemUpgrade_infoBg_1, "gemIcon_Right_Ex", "1801100170", 155,41, false, 100,100)
	_gt.BindName(gemIcon_Right_Ex, "gemIcon_Right_Ex")
	
	local gemIcon_Right_MaxLevelInfo = GUI.CreateStatic(GemUpgrade_infoBg_1, "gemIcon_Right_MaxLevelInfo", "当前宝石已\n升级到最高", 155,-12,130,80)
	GUI.StaticSetAlignment(gemIcon_Right_MaxLevelInfo, TextAnchor.MiddleCenter)
    GUI.SetColor(gemIcon_Right_MaxLevelInfo, UIDefine.Yellow2Color)
    UILayout.SetAnchorAndPivot(gemIcon_Right_MaxLevelInfo, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(gemIcon_Right_MaxLevelInfo, UIDefine.FontSizeM)
	GUI.SetVisible(gemIcon_Right_MaxLevelInfo, false)
	_gt.BindName(gemIcon_Right_MaxLevelInfo, "gemIcon_Right_MaxLevelInfo")
	
	local gemIcon_Right = ItemIcon.Create(GemUpgrade_infoBg_1, "gemIcon_Right", 155, 50);							--右侧宝石预览
	_gt.BindName(gemIcon_Right, "gemIcon_Right")
	GUI.RegisterUIEvent(gemIcon_Right, UCE.PointerClick, "EquipGemInlayUI", "On_gemIcon_Right_Click")
	
	local gemIcon_Right_Switch_1 = GUI.ButtonCreate(gemIcon_Right, "gemIcon_Right_Switch_1", "1801507110",-73,-44, Transition.None, "", 40,40,false)
	GUI.RegisterUIEvent(gemIcon_Right_Switch_1, UCE.PointerClick, "EquipGemInlayUI", "On_TarGemSwitch_Click")
	GUI.SetData(gemIcon_Right_Switch_1, "SwitchIcon", "Left")
	_gt.BindName(gemIcon_Right_Switch_1, "gemIcon_Right_Switch_1")
	local gemIcon_Right_Switch_2 = GUI.ButtonCreate(gemIcon_Right, "gemIcon_Right_Switch_2", "1801507120",73,-44, Transition.None, "", 40,40,false)
	GUI.RegisterUIEvent(gemIcon_Right_Switch_2, UCE.PointerClick, "EquipGemInlayUI", "On_TarGemSwitch_Click")
	GUI.SetData(gemIcon_Right_Switch_2, "SwitchIcon", "Right")
	_gt.BindName(gemIcon_Right_Switch_2, "gemIcon_Right_Switch_2")
	
	local gemIcon_Arrow = GUI.ImageCreate(GemUpgrade_infoBg_1, "gemIcon_Arrow", "1800707050", 0,-12,false, 48,44)
	UILayout.SetAnchorAndPivot(gemIcon_Arrow, UIAnchor.Center, UIAroundPivot.Center)
	
	local gemAtt_Change_Txt_1 = GUI.CreateStatic(GemUpgrade_infoBg_1, "gemAtt_Change_Txt_1", "物攻+5", 0,-50, 200,30)
	GUI.StaticSetAlignment(gemAtt_Change_Txt_1, TextAnchor.MiddleCenter)
    GUI.SetColor(gemAtt_Change_Txt_1, Color.New(25 / 255, 200 / 255, 0 / 255, 1))
    UILayout.SetAnchorAndPivot(gemAtt_Change_Txt_1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(gemAtt_Change_Txt_1, UIDefine.FontSizeM)
	_gt.BindName(gemAtt_Change_Txt_1, "gemAtt_Change_Txt_1")
	
	local gemAtt_Change_Txt_2 = GUI.CreateStatic(GemUpgrade_infoBg_1, "gemAtt_Change_Txt_2", "物攻+5", 0,26, 200,30)
	GUI.StaticSetAlignment(gemAtt_Change_Txt_2, TextAnchor.MiddleCenter)
    GUI.SetColor(gemAtt_Change_Txt_2, Color.New(25 / 255, 200 / 255, 0 / 255, 1))
    UILayout.SetAnchorAndPivot(gemAtt_Change_Txt_2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(gemAtt_Change_Txt_2, UIDefine.FontSizeM)
	_gt.BindName(gemAtt_Change_Txt_2, "gemAtt_Change_Txt_2")
	
	local GemUpgrade_infoBg_1_decorate_1 = GUI.ImageCreate(GemUpgrade_infoBg_1, "GemUpgrade_infoBg_1_decorate_1", "1801502040", -259,0,false,105,125)
	local GemUpgrade_infoBg_1_decorate_2 = GUI.ImageCreate(GemUpgrade_infoBg_1, "GemUpgrade_infoBg_1_decorate_2", "1801502020", 260,0,false,105,125)
	
	local gem_Left = GUI.ImageCreate(GemUpgrade_infoBg_1, "gem_Left", "1800001060", -156,6,false, 150, 40)
	local gem_Left_Level = GUI.CreateStatic(gem_Left, "gem_Left_Level", "1级", -37,0,50,30)
	GUI.StaticSetAlignment(gem_Left_Level, TextAnchor.MiddleCenter)
    GUI.SetColor(gem_Left_Level, UIDefine.Yellow2Color)
    UILayout.SetAnchorAndPivot(gem_Left_Level, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(gem_Left_Level, UIDefine.FontSizeS)
	_gt.BindName(gem_Left_Level, "gem_Left_Level")
	local gem_Left_Type = GUI.CreateStatic(gem_Left, "gem_Left_Type", "开锋石", 19,0,100,30)
	GUI.StaticSetAlignment(gem_Left_Type, TextAnchor.MiddleCenter)
    GUI.SetColor(gem_Left_Type, UIDefine.BrownColor)
    UILayout.SetAnchorAndPivot(gem_Left_Type, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(gem_Left_Type, UIDefine.FontSizeM)
	_gt.BindName(gem_Left_Type, "gem_Left_Type")
	
	local gem_Right = GUI.ImageCreate(GemUpgrade_infoBg_1, "gem_Right", "1800001060", 156,6,false, 150, 40)
	local gem_Right_Level = GUI.CreateStatic(gem_Right, "gem_Right_Level", "2级", -37,0,50,30)
	GUI.StaticSetAlignment(gem_Right_Level, TextAnchor.MiddleCenter)
    GUI.SetColor(gem_Right_Level, UIDefine.Yellow2Color)
    UILayout.SetAnchorAndPivot(gem_Right_Level, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(gem_Right_Level, UIDefine.FontSizeS)
	_gt.BindName(gem_Right_Level, "gem_Right_Level")
	local gem_Right_Type = GUI.CreateStatic(gem_Right, "gem_Right_Type", "开锋石", 19,0,100,30)
	GUI.StaticSetAlignment(gem_Right_Type, TextAnchor.MiddleCenter)
    GUI.SetColor(gem_Right_Type, UIDefine.BrownColor)
    UILayout.SetAnchorAndPivot(gem_Right_Type, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(gem_Right_Type, UIDefine.FontSizeM)
	_gt.BindName(gem_Right_Type, "gem_Right_Type")
	
	local Txt_2_Mid = GUI.CreateStatic(GemUpgrade_infoBg_2, "Txt_2_Mid", "背包参与宝石合成", 0,64,250,40)
	GUI.StaticSetAlignment(Txt_2_Mid, TextAnchor.MiddleCenter)
    GUI.SetColor(Txt_2_Mid, UIDefine.BrownColor)
    UILayout.SetAnchorAndPivot(Txt_2_Mid, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Txt_2_Mid, UIDefine.FontSizeL)
	
	local Txt_2_Mid_decorate_1 = GUI.ImageCreate(GemUpgrade_infoBg_2, "Txt_2_Mid_decorate_1", "1800700150", -205, 150, false, 200, 17)
	local Txt_2_Mid_decorate_2 = GUI.ImageCreate(GemUpgrade_infoBg_2, "Txt_2_Mid_decorate_2", "1800700150", 205, 150, false, 200, 17)
	GUI.SetEulerAngles(Txt_2_Mid_decorate_2, Vector3.New(-180, 0, -180));
	
	local MergeList = GUI.LoopScrollRectCreate(GemUpgrade_infoBg_2, "MergeList", 0,10,580,130, 
		"EquipGemInlayUI", "CreateMergeList", "EquipGemInlayUI", "RefreshMergeList", 0, true,
		Vector2.New(80, 80), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
	_gt.BindName(MergeList, "MergeList")
	
	local Money_CheckBox = GUI.CheckBoxExCreate(center, "Money_CheckBox", "1800208210", "1800208211", -298,26,true, 30,30)
	_gt.BindName(Money_CheckBox, "Money_CheckBox")
	local Money_CheckBox_Txt = GUI.CreateStatic(center, "Money_CheckBox_Txt", "自动银币补充", -212,-202,130,40)
	UILayout.SetAnchorAndPivot(Money_CheckBox_Txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Money_CheckBox_Txt, 20)
	GUI.SetColor(Money_CheckBox_Txt, UIDefine.Yellow2Color)
	local Money_Cost_Txt = GUI.CreateStatic(center, "Money_Cost_Txt", "总消耗", -85,-202,80,40)
	UILayout.SetAnchorAndPivot(Money_Cost_Txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(Money_Cost_Txt, UIDefine.FontSizeL)
	GUI.SetColor(Money_Cost_Txt, UIDefine.BrownColor)
	local Money_CostBg = GUI.ImageCreate(center, "Money_CostBg", "1800700010", 47,-203,false, 180,35)
	UILayout.SetAnchorAndPivot(Money_CostBg, UIAnchor.Center, UIAroundPivot.Center)
	local Money_CostNum = GUI.CreateStatic(Money_CostBg, "Money_CostNum", "100", 13,-1,145,35)
	UILayout.SetAnchorAndPivot(Money_CostNum, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetFontSize(Money_CostNum, 22);
	GUI.StaticSetAlignment(Money_CostNum, TextAnchor.MiddleCenter);
	_gt.BindName(Money_CostNum, "Money_CostNum")
	local Money_Icon = GUI.ImageCreate(Money_CostBg, "Money_Icon","1800408280",-74,-2,false, 35,35)
	_gt.BindName(Money_Icon, "Money_Icon")
	
	GUI.SetVisible(GemUpgrade_panelCover, false)

end

function EquipGemInlayUI.closeMethod()
	local GemUpgrade_panelCover = _gt.GetUI("GemUpgrade_panelCover")
	GUI.SetVisible(GemUpgrade_panelCover, false)
end

function EquipGemInlayUI.On_gemIcon_Left_Click()
	local Money_Icon = _gt.GetUI("Money_Icon")					--用作父节点
	local cur_gemId = data.EquipGemInlayUI_cur_gemDB['Id']
	Tips.CreateByItemId(cur_gemId, Money_Icon, "gemIcon_Left_Tips", 135, -205, 0)
end

function EquipGemInlayUI.On_gemIcon_Right_Click()
	local Money_Icon = _gt.GetUI("Money_Icon")
	local tar_gemId = data.EquipGemInlayUI_tar_gemDB['Id']
	Tips.CreateByItemId(tar_gemId, Money_Icon, "gemIcon_Right_Tips", 445, -205, 0)
end

function EquipGemInlayUI.OnMergeBtnClick()
	--FormEquip.EquipGem_ConsumeQuickCompound(player, item_guid, slot, targetgem_id)		item_guid是装备guid   slot是宝石镶嵌在装备槽位
	local Money_CheckBox = _gt.GetUI("Money_CheckBox")
	local T_OR_F = GUI.CheckBoxExGetCheck(Money_CheckBox)
	if T_OR_F == false then
		GlobalUtils.ShowBoxMsg2Btn("提示","当前合成宝石不足，是否开启银币自动补充？","EquipGemInlayUI", "确定", "Auto_Completion_Comfirm", "取消", "Auto_Completion_Cancel")
		return
	end
	if data.RightGemList_QuickMerge == 0 then
		local itemInfo = EquipGemInlayUI.GetItem();
		local item_Guid = tostring(itemInfo.guid)
		local slot = data.EquipGemInlayUI_Slot
		CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipGem_ConsumeQuickCompound", item_Guid, slot, data.EquipGemInlayUI_cur_gemDB['Id'], data.EquipGemInlayUI_tar_gemDB['Id'])
	elseif data.RightGemList_QuickMerge == 1 then
		CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipGem_ConsumeQuickCompound", 0, 0, data.EquipGemInlayUI_cur_gemDB['Id'], data.EquipGemInlayUI_tar_gemDB['Id'])
	end
end

function EquipGemInlayUI.MergeSuccessfully()
	local gem_id = data.EquipGemInlayUI_tar_gemDB['Id']
	local targetgem_id = gem_id + 1 
	local gem_Type = data.EquipGemInlayUI_tar_gemDB['Subtype2']
	
	local itemmode = false
	if data.RightGemList_QuickMerge == 1 then
		itemmode = 0
	elseif data.RightGemList_QuickMerge == 0 then
		itemmode = 1
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipGem_QuickCompound", gem_Type, gem_id, targetgem_id, itemmode)
	data.EquipGemInlayUI_targetgem_id = data.EquipGemInlayUI_targetgem_id + 1
end

function EquipGemInlayUI.Auto_Completion_Cancel()
	
end

function EquipGemInlayUI.Auto_Completion_Comfirm()
	local Money_CheckBox = _gt.GetUI("Money_CheckBox")
	GUI.CheckBoxExSetCheck(Money_CheckBox, true)
end

function EquipGemInlayUI.CreateMergeList()
	--test("======================CreateMergeList======================")
	local MergeList = _gt.GetUI("MergeList")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(MergeList);
	local index = tostring(tonumber(curCount) + 1)
	GUI.ScrollRectSetChildSpacing(MergeList, Vector2.New(20, 0))
	local Item = GUI.ItemCtrlCreate(MergeList, "Item"..index, "1800400330", 0, 0, 80,80, false)
	UILayout.SetAnchorAndPivot(Item, UIAnchor.Left, UIAroundPivot.Left)
  	--GUI.SetColor(Item,Color.New(1,1,1,0))
	--local gemIcon = GUI.ItemCtrlCreate(Item, "gemIcon"..index,"1800400330",0,0,80,80)
	local MergeList_demount = GUI.ButtonCreate(Item, "MergeList_demount", "1800702070", 56,-29, Transition.ColorTint, "", 23,23,false)
	GUI.RegisterUIEvent(MergeList_demount, UCE.PointerClick, "EquipGemInlayUI", "OnMergeList_demountClick");
	
	local MergeList_Gem_Fraction = GUI.CreateStatic(Item, "MergeList_Gem_Fraction", "0/0", 0,24,80,22)
	GUI.StaticSetAlignment(MergeList_Gem_Fraction, TextAnchor.MiddleCenter)
    GUI.SetColor(MergeList_Gem_Fraction, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(MergeList_Gem_Fraction, 18)
	GUI.SetIsOutLine(MergeList_Gem_Fraction,true)
	GUI.SetOutLine_Color(MergeList_Gem_Fraction,UIDefine.BlackColor)
	GUI.SetOutLine_Distance(MergeList_Gem_Fraction, 1)
	local MergeList_Gem_Type = GUI.CreateStatic(Item, "MergeList_Gem_Type", "开锋石", 0,52,80,30)
	GUI.StaticSetAlignment(MergeList_Gem_Type, TextAnchor.MiddleCenter)
    GUI.SetColor(MergeList_Gem_Type, UIDefine.BrownColor)
    GUI.StaticSetFontSize(MergeList_Gem_Type, 21)
	local MergeList_Gem_Level = GUI.CreateStatic(Item, "MergeList_Gem_Level", "1级", 0,77,80,25)
	GUI.StaticSetAlignment(MergeList_Gem_Level, TextAnchor.MiddleCenter)
    GUI.SetColor(MergeList_Gem_Level, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(MergeList_Gem_Level, 20)

	return Item
end

function EquipGemInlayUI.RefreshMergeList(parameter)
	--test("======================RefreshMergeList======================")
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	
	local MergeList = _gt.GetUI("MergeList")
	local Item = GUI.GetByGuid(guid)
	
	if EquipGemInlayUI.QuickCompoundGemList ~= nil then
		local QuickCompoundGemList_Temp_TB = EquipGemInlayUI.QuickCompoundGemList
		table.sort(QuickCompoundGemList_Temp_TB, function(a,b) 
		return a.gemId > b.gemId
		end)
		local MergeList_demount = GUI.GetChild(Item,"MergeList_demount");
		local MergeList_Gem_Fraction = GUI.GetChild(Item,"MergeList_Gem_Fraction")
		local MergeList_Gem_Type = GUI.GetChild(Item, "MergeList_Gem_Type")
		local MergeList_Gem_Level = GUI.GetChild(Item, "MergeList_Gem_Level")
		if QuickCompoundGemList_Temp_TB[index] ~= nil then
			GUI.SetData(MergeList_demount, "index", index)
			GUI.SetData(MergeList_demount, "gemId"..index, QuickCompoundGemList_Temp_TB[index]['gemId'])
			local gemDB = DB.GetOnceItemByKey1(QuickCompoundGemList_Temp_TB[index]['gemId'])
			ItemIcon.BindItemDB(Item, gemDB);
			GUI.StaticSetText(MergeList_Gem_Type, string.split(gemDB['Name'], "级")[2])
			GUI.StaticSetText(MergeList_Gem_Level, string.split(gemDB['Name'], "级")[1].."级")
			GUI.StaticSetText(MergeList_Gem_Fraction, QuickCompoundGemList_Temp_TB[index]['gemSelNum'].."/"..QuickCompoundGemList_Temp_TB[index]['gemNum'])
			
			GUI.SetVisible(MergeList_demount, true)
			GUI.SetVisible(MergeList_Gem_Fraction, true)
			GUI.SetVisible(MergeList_Gem_Type, true)
			GUI.SetVisible(MergeList_Gem_Level, true)
		else
			ItemIcon.SetEmpty(Item)
			GUI.SetVisible(MergeList_demount, false)
			GUI.SetVisible(MergeList_Gem_Fraction, false)
			GUI.SetVisible(MergeList_Gem_Type, false)
			GUI.SetVisible(MergeList_Gem_Level, false)
		end
	end
end

function EquipGemInlayUI.OnMergeList_demountClick(guid)
	local MergeList_demount = GUI.GetByGuid(guid)
	local index = tonumber(GUI.GetData(MergeList_demount, "index"))
	test("index = "..index)
	local gemId = tonumber(GUI.GetData(MergeList_demount, "gemId"..index))
	test("gemId = "..gemId)
	local gem_guid_List = LD.GetItemGuidsById(gemId, item_container_type.item_container_gem_bag)
	local gem_guid = tostring(gem_guid_List[0])
	
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipGem_SubGemNum", gem_guid)
end

function EquipGemInlayUI.CreateEquipGemItem()
	local equipGemScroll = EquipUI.guidt.GetUI("equipGemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(equipGemScroll);
	local equipGemItem = GUI.CheckBoxExCreate(equipGemScroll, "equipGemItem" ..curCount, "1801302060", "1800700040", 0, 0, false)
	GUI.RegisterUIEvent(equipGemItem, UCE.PointerClick, "EquipGemInlayUI", "OnEquipGemItemClick");
	UILayout.SetSameAnchorAndPivot(equipGemItem, UILayout.Center);
	_gt.BindName(equipGemItem, "equipGemItem"..curCount)
	local icon = ItemIcon.Create(equipGemItem, "icon", -125, 2);
	UILayout.SetSameAnchorAndPivot(icon, UILayout.Center);
	
	local demountBtn = GUI.ButtonCreate(equipGemItem, "demountBtn", "1800702070", -102, -23, Transition.ColorTint, "", 33,33,false);
	GUI.RegisterUIEvent(demountBtn, UCE.PointerClick, "EquipGemInlayUI", "OnDemountBtnClick");
	UILayout.SetSameAnchorAndPivot(demountBtn, UILayout.Center);
	GUI.SetVisible(demountBtn, false)
	
	local equipGemUpgradeBtn = GUI.ButtonCreate(equipGemItem, "equipGemUpgradeBtn", "1801402080", 140, -20, Transition.ColorTint, "升级",80,39,false)
	GUI.ButtonSetTextColor(equipGemUpgradeBtn,UIDefine.BrownColor)
	GUI.ButtonSetTextFontSize(equipGemUpgradeBtn, 19)
	GUI.RegisterUIEvent(equipGemUpgradeBtn, UCE.PointerClick, "EquipGemInlayUI", "OnEquipGemUpgradeClick");
	GUI.SetData(equipGemUpgradeBtn, "index", tostring(curCount + 1))
	GUI.SetVisible(equipGemUpgradeBtn, false)
	
	local nameText = GUI.CreateStatic(equipGemItem, "nameText", "name", 125, -20, 250, 35)
	GUI.SetColor(nameText, UIDefine.BrownColor)
	GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
	UILayout.SetSameAnchorAndPivot(nameText, UILayout.Left);
	GUI.SetVisible(nameText, false)
	
	local attrText = GUI.CreateStatic(equipGemItem, "attrText", "attr", 125, 15, 250, 35)
	GUI.SetColor(attrText, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(attrText, UIDefine.FontSizeS)
	GUI.StaticSetAlignment(attrText, TextAnchor.MiddleLeft)
	UILayout.SetSameAnchorAndPivot(attrText, UILayout.Left);
	GUI.SetVisible(attrText, false)
	
	local valueText = GUI.CreateStatic(equipGemItem, "valueText", "value", 280, -18, 100, 35)
	GUI.SetColor(valueText, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(valueText, UIDefine.FontSizeS)
	GUI.StaticSetAlignment(valueText, TextAnchor.MiddleLeft)
	UILayout.SetSameAnchorAndPivot(valueText, UILayout.Left);
	GUI.SetVisible(valueText, false)
	
	local emptyText = GUI.CreateStatic(equipGemItem, "emptyText", "未镶嵌宝石", 30, 0, 200, 35)
	GUI.SetColor(emptyText, UIDefine.GrayColor)
	GUI.StaticSetFontSize(emptyText, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(emptyText, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(emptyText, UILayout.Center);
	
	return equipGemItem;
end

function EquipGemInlayUI.RefreshEquipGemScroll(parameter)
	if EquipUI.tabSubIndex == 2 then
		EquipGemMergeUI.RefreshEquipGemScroll(parameter)
		return ;
	end

	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local equipGemItem = GUI.GetByGuid(guid);
	local icon = GUI.GetChild(equipGemItem, "icon")
	local demountBtn = GUI.GetChild(equipGemItem, "demountBtn")
	local nameText = GUI.GetChild(equipGemItem, "nameText")
	local attrText = GUI.GetChild(equipGemItem, "attrText")
	local valueText = GUI.GetChild(equipGemItem, "valueText")
	local emptyText = GUI.GetChild(equipGemItem, "emptyText")
	local equipGemUpgradeBtn = GUI.GetChild(equipGemItem, "equipGemUpgradeBtn")
	local equipGemScroll = EquipUI.guidt.GetUI("equipGemScroll")						--仅作为GUI.SetData的obj使用
	
	index = index + 1;
	
	GUI.CheckBoxExSetCheck(equipGemItem, index == data.equipGemIndex)

	local isShowRedPoint = false
	local itemInfo = EquipGemInlayUI.GetItem();
	if itemInfo then
		local itemData = EquipUI.GetEquipData(itemInfo.guid, data.getBagType(), itemInfo.site)
		if itemData then
			local gemId = itemData:GetIntCustomAttr(LogicDefine.ITEM_GemId_ .. index);
			if gemId == 0 then
				ItemIcon.SetEmpty(icon);
				GUI.SetVisible(demountBtn, false);
				GUI.SetVisible(nameText, false);
				GUI.SetVisible(attrText, false);
				GUI.SetVisible(valueText, false);
				GUI.SetVisible(emptyText, true);
				GUI.StaticSetText(emptyText, "未镶嵌宝石")
				GUI.SetVisible(equipGemUpgradeBtn, false);
			else
				GUI.SetData(equipGemScroll, "gemId"..index, gemId)
				local gemDB = DB.GetOnceItemByKey1(gemId)
				local gem_AttDB = DB.GetOnceItem_AttByKey1(gemId)
				ItemIcon.BindItemDB(icon, gemDB);
				GUI.SetVisible(demountBtn, true);
				GUI.SetVisible(nameText, true);
				GUI.SetVisible(attrText, true);
				GUI.SetVisible(equipGemUpgradeBtn, true);
				GUI.SetVisible(valueText, false);
				GUI.SetVisible(emptyText, false);
				GUI.StaticSetText(nameText, gemDB.Name);
				local gem_Att_1_Type = gem_AttDB['Att1']
				local gem_Att_1_Num = gem_AttDB['Att1Max']
				local gem_Att_2_Type = gem_AttDB['Att2']
				local gem_Att_2_Num = gem_AttDB['Att2Max']
				local info = UIDefine.GetAttrDesStr(gem_Att_1_Type, gem_Att_1_Num).."  "..UIDefine.GetAttrDesStr(gem_Att_2_Type, gem_Att_2_Num)
				GUI.StaticSetText(attrText, info);
				GUI.SetData(demountBtn, "GemType", index);
			end
			local gemLevel = DB.GetOnceItemByKey1(gemId)['Itemlevel']
			if EquipGemInlayUI.MaxGemLevel then
				if gemLevel >= EquipGemInlayUI.MaxGemLevel then
					GUI.SetVisible(equipGemUpgradeBtn, false)
				end
			end
			-- 小红点
			if data.getBagType() == item_container_type.item_container_equip then
				local site = itemInfo.site
				-- if data.getBagType() ~= item_container_type.item_container_equip then
				-- 	local itemDB = DB.GetOnceItemByKey1(itemData.id)
				-- 	site = LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
				-- end
				local equipGemBagList,equipGemBagLevelList = EquipGemInlayUI.GetEquipGemBagList(site)
				for i = 1, #equipGemBagLevelList, 1 do
					local bagGemlv = equipGemBagLevelList[i]
					if gemLevel < bagGemlv then
						isShowRedPoint = true
						break;
					end
				end
			end
		end
	end
	GlobalProcessing.SetRetPoint(equipGemItem,isShowRedPoint)
end

function EquipGemInlayUI.OnEqiupIconClick()
	if EquipUI.tabSubIndex == 2 then
		return ;
	end
	local itemInfo = EquipGemInlayUI.GetItem();
	local itemData = EquipUI.GetEquipData(itemInfo.guid, data.getBagType(), itemInfo.site)

	local gemInlayGroup = EquipUI.guidt.GetUI("gemInlayGroup")
	Tips.CreateByItemData(itemData, gemInlayGroup, "equipTips", -420, 0);
end

function EquipGemInlayUI.OnGemTypeBtnClick(guid)

	if EquipUI.tabSubIndex == 2 then
		EquipGemMergeUI.OnGemTypeBtnClick(guid)
		return ;
	end
	local gemTypeBtn = GUI.GetByGuid(guid);
	local index = tonumber(GUI.GetData(gemTypeBtn, "Index"));
	data.gemTypeIndex = data.gemTypeIndex == index and 0 or index;
	data.gemClickIndex = index
	EquipGemInlayUI.RefreshGemListScr();
end

function EquipGemInlayUI.UpdateGemList(gemType)
	data.gemGuids = {}
	test("UpdateGemList")
	data.EquipGemInlayUI_BuyOrMerge = 0	--用于判断是生成快捷购买还是快捷合成； 0是购买，1是合成
	local BuyOrMerge = 0
	local count = LD.GetItemCount(item_container_type.item_container_gem_bag)
	for i = 0, count - 1 do
		local itemGuid = LD.GetItemGuidByItemIndex(i, item_container_type.item_container_gem_bag);
		local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid, item_container_type.item_container_gem_bag);
		local itemDB = DB.GetOnceItemByKey1(itemId);
		if itemDB.Type == 3 and itemDB.Subtype == 9 and itemDB.Subtype2 == gemType then
			table.insert(data.gemGuids, itemGuid);
		end
	end

	table.sort(data.gemGuids, function(a, b)
		local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, a, item_container_type.item_container_gem_bag);
		local itemDB = DB.GetOnceItemByKey1(itemId);
		local itemId2 = LD.GetItemAttrByGuid(ItemAttr_Native.Id, b, item_container_type.item_container_gem_bag);
		local itemDB2 = DB.GetOnceItemByKey1(itemId2);
		return itemDB.Itemlevel > itemDB2.Itemlevel;
	end)

	local gemList = EquipUI.guidt.GetUI("gemList" .. gemType);
	for i = 1, #data.gemGuids do
		local gemItem = GUI.GetChild(gemList, "gemItem" .. i);
		local icon = GUI.GetChild(gemItem, "icon");
		local nameText = GUI.GetChild(gemItem, "nameText");
		local attrText = GUI.GetChild(gemItem, "attrText");
		if gemItem == nil then
			gemItem, icon, nameText, attrText = EquipGemInlayUI.CreateGemItem(gemList, i)
		end

		local itemGuid = data.gemGuids[i]
		--test("===========itemGuid = "..tostring(itemGuid))
		GUI.SetVisible(gemItem, true);
		GUI.SetData(gemItem, "ItemGuid", tostring(itemGuid));
		GUI.SetData(gemItem, "GemType", gemType);
		--test("===========gemType = "..gemType)
		local itemData = LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_gem_bag)
		ItemIcon.BindItemData(icon, itemData);
		--test("itemData.id = "..itemData.id)
		local itemDB = DB.GetOnceItemByKey1(itemData.id);
		if EquipGemInlayUI.MaxGemLevel and itemDB['Itemlevel'] < EquipGemInlayUI.MaxGemLevel then
			BuyOrMerge = 1
		else
			BuyOrMerge = 0
		end
		GUI.StaticSetText(nameText, itemDB.Name);
		local item_AttDB = DB.GetOnceItem_AttByKey1(itemData.id)
		
		local attrDatas = itemData:GetDynAttrDataByMark(LogicDefine.GemAttrMark);
		if attrDatas.Count > 0 then
			local info = ""
			local gem_Att_1_Type = item_AttDB['Att1']
			local gem_Att_1_Num = item_AttDB['Att1Max']
			local gem_Att_2_Type = item_AttDB['Att2']
			local gem_Att_2_Num = item_AttDB['Att2Max']
			if gem_Att_2_Type ~= 0 then
				info = UIDefine.GetAttrDesStr(gem_Att_1_Type, gem_Att_1_Num).."\n"..UIDefine.GetAttrDesStr(gem_Att_2_Type, gem_Att_2_Num)
			else
				info = UIDefine.GetAttrDesStr(gem_Att_1_Type, gem_Att_1_Num)
			end
			
			GUI.StaticSetText(attrText, info);
			local w = GUI.StaticGetLabelPreferWidth(attrText)
			GUI.SetWidth(attrText, w)
			if w > 170 then
				local s = 170 / w
				GUI.SetScale(attrText, Vector3.New(s, s, s))
			else
				GUI.SetScale(attrText, UIDefine.Vector3One)
			end
			GUI.SetPositionY(attrText,18)
			GUI.SetHeight(attrText,55)
		else
			GUI.StaticSetText(attrText, " ");
		end
		
		if BuyOrMerge == 1 then
			data.EquipGemInlayUI_BuyOrMerge = 1
		end

		-- 小红点
		local isShowRedPoint = false
		local type = data.getBagType()
		local itemInfo = data.items[type][data.index]
		if itemInfo  and data.getBagType() == item_container_type.item_container_equip then
			local equipData = EquipUI.GetEquipData(itemInfo.guid, type, itemInfo.site)
			local site = itemInfo.site
			if type ~= item_container_type.item_container_equip then
				local equipDB = DB.GetOnceItemByKey1(equipData.id)
				site = LogicDefine.GetEquipSite(equipDB.Type, equipDB.Subtype, equipDB.Subtype2)
			end
			local equipGemBagList,equipGemBagLevelList = EquipGemInlayUI.GetEquipGemBagList(site)
			local itemGemList,itemGemLevelList= EquipGemInlayUI.GetItemGemList(equipData)
			local maxGemlv = 0
			for m = 1, #equipGemBagLevelList, 1 do
				local bagGemlv = equipGemBagLevelList[m]
				if bagGemlv > maxGemlv then
					maxGemlv = bagGemlv
				end
			end
			local minitemGemlv = maxGemlv
			for m = 1, #itemGemLevelList, 1 do
				local itemGemlv = itemGemLevelList[m]
				if itemGemlv < minitemGemlv then
					minitemGemlv = itemGemlv
				end
			end
			if maxGemlv == itemDB.Itemlevel then
				isShowRedPoint = true
			end
			if minitemGemlv >= maxGemlv then
				isShowRedPoint = false
			end
		end
		GlobalProcessing.SetRetPoint(gemItem,isShowRedPoint)
	end
	
	--生成 快捷购买 按钮
	if gemType ~= 9 then
		local gemItem = GUI.GetChild(gemList, "gemItem" .. (#data.gemGuids + 1));
		--test("gemItem "..#data.gemGuids)
		local icon = GUI.GetChild(gemItem, "icon");
		local nameText = GUI.GetChild(gemItem, "nameText");
		local attrText = GUI.GetChild(gemItem, "attrText");
		if gemItem == nil then
			gemItem, icon, nameText, attrText = EquipGemInlayUI.CreateGemItem(gemList, (#data.gemGuids + 1))
		end
		GUI.SetVisible(gemItem, true);
		GlobalProcessing.SetRetPoint(gemItem,false)
		GUI.StaticSetText(nameText, UIDefine.GemType[gemType].Name);
		GUI.SetData(gemItem, "ItemGuid", 0);                                  
		GUI.SetData(gemItem, "GemType", gemType);                             
		--ItemIcon.SetAddState(icon)                                            
		--test(UIDefine.GemType[gemType].Name)                               
		if data.EquipGemInlayUI_BuyOrMerge == 0 then
			GUI.StaticSetText(attrText, "快捷购买");                              
			ItemIcon.SetAddState(icon)
		else
			GUI.StaticSetText(attrText, "快捷合成")
			ItemIcon.SetEmpty(icon)
			GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, "1801607010");
			GUI.ItemCtrlSetElementRect(icon, eItemIconElement.Icon, 0, -1, 50, 50);
			GUI.SetData(gemItem, "gemType", gemType)
		end
		GUI.SetScale(attrText, UIDefine.Vector3One)
		GUI.SetWidth(attrText, 170)

		for i = #data.gemGuids + 2, GUI.GetChildCount(gemList) do
			--test("gemList = "..GUI.GetChildCount(gemList))
			local gemItem = GUI.GetChild(gemList, "gemItem" .. i);
			GUI.SetVisible(gemItem, false);
		end
	else
		for i = #data.gemGuids + 1, GUI.GetChildCount(gemList) do
			--test("gemType = 9    "..i)
			local gemItem = GUI.GetChild(gemList, "gemItem" .. i);
			GUI.SetVisible(gemItem, false);
			GlobalProcessing.SetRetPoint(gemItem,false)
		end
	end

	--"1801607010"回收图标
end

function EquipGemInlayUI.CreateGemItem(gemList, index)
	local gemItem = GUI.ButtonCreate(gemList, "gemItem" .. index, "1801302060", 0, 0, Transition.ColorTint, "", 300, 102, false);
	GUI.RegisterUIEvent(gemItem, UCE.PointerClick, "EquipGemInlayUI", "OnGemItemClick");
	
	local icon = ItemIcon.Create(gemItem, "icon", -85, 2);
	UILayout.SetSameAnchorAndPivot(icon, UILayout.Center);
	local nameText = GUI.CreateStatic(gemItem, "nameText", "name", 115, -20, 170, 35)
	GUI.SetColor(nameText, UIDefine.BrownColor)
	GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
	UILayout.SetSameAnchorAndPivot(nameText, UILayout.Left);
	
	local attrText = GUI.CreateStatic(gemItem, "attrText", "attr", 115, 15, 170, 35)
	GUI.SetColor(attrText, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(attrText, UIDefine.FontSizeS)
	GUI.StaticSetAlignment(attrText, TextAnchor.MiddleLeft)
	UILayout.SetSameAnchorAndPivot(attrText, UILayout.Left);
	
	return gemItem, icon, nameText, attrText
end

function EquipGemInlayUI.OnGemItemClick(guid)
	--test("data.EquipGemInlayUI_BuyOrMerge = "..data.EquipGemInlayUI_BuyOrMerge)
	if EquipUI.tabSubIndex == 2 then
		test("=====================EquipGemInlayUI.OnGemItemClick")
		EquipGemMergeUI.OnGemItemClick(guid)
		return ;
	end
	local gemItem = GUI.GetByGuid(guid);
	local itemGuid = GUI.GetData(gemItem, "ItemGuid")
	local gemType = GUI.GetData(gemItem, "gemType")
	if itemGuid ~= "0" then
		local itemInfo = EquipGemInlayUI.GetItem()
		if itemInfo then
			--test("EmbedGem:")
			--test(tostring(itemInfo.guid))
			--test(tostring(data.equipGemIndex))
			--test(itemGuid)
			local itemData = EquipUI.GetEquipData(itemInfo.guid, data.getBagType(), itemInfo.site)
			if itemData:GetIntCustomAttr(LogicDefine.ITEM_GemNum) == 0 then
				CL.SendNotify(NOTIFY.ShowBBMsg,"该装备的宝石镶嵌槽位为空，无法镶嵌")
			else
				if EquipUI.curGuardGuid then
					CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "GuardEmbedGem", EquipUI.curGuardGuid, itemInfo.guid, data.equipGemIndex, uint64.new(itemGuid))
				else
					CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EmbedGem", itemInfo.guid, data.equipGemIndex, uint64.new(itemGuid))
				end
			end
			--EquipGemInlayUI.UpdateGemList(index)
		end
	else
		if data.EquipGemInlayUI_BuyOrMerge == 0 then
			local gemType = tonumber(GUI.GetData(gemItem, "GemType"));
			test("BuyGem:" .. gemType)
			CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "BuyGem", gemType)
		else
			local gem_idTB = {}
			local gem_id = 5001
			local gem_Num = LD.GetItemCount(item_container_type.item_container_gem_bag)
			for i = 0, gem_Num - 1 do
				local itemData = LD.GetItemDataByIndex(i, item_container_type.item_container_gem_bag)
				if itemData then
					local itemDB = DB.GetOnceItemByKey1(itemData.id)
					if tonumber(itemDB['Subtype2']) == tonumber(gemType) and tonumber(itemDB['Itemlevel']) < EquipGemInlayUI.MaxGemLevel then
						table.insert(gem_idTB, itemDB['Id'])
					end
				end
			end
			if gem_idTB ~= {} then
				table.sort(gem_idTB, function(a,b) 
				return a > b
				end)
				gem_id = gem_idTB[1]
			end
			data.RightGemList_QuickMerge = 1							--用于判断是否是从右侧列表进入；1为从右侧，0为从升级按钮点击
			EquipGemInlayUI.RightGemList_QuickMergeClick(gem_id)		--data.RightGemList_QuickMerge服务器端相反；1从升级，0从右侧
		end
	end
	CL.SendNotify(NOTIFY.RearrangeItem, System.Enum.ToInt(item_container_type.item_container_gem_bag))		--宝石背包整理
	EquipGemInlayUI.Refresh()
end



function EquipGemInlayUI.OnDemountBtnClick(guid)
	if EquipUI.tabSubIndex == 2 then
		EquipGemMergeUI.OnDemountBtnClick(guid)
		return ;
	end
	--test("=========OnDemountBtnClick_guid = "..guid)
	local demountBtn = GUI.GetByGuid(guid)
	local index = tonumber(GUI.GetData(demountBtn, "GemType"));
	local itemInfo = EquipGemInlayUI.GetItem()
	data.equipGemIndex = index;
	if itemInfo then
		--test("RemoveGem:")
		--test(tostring(itemInfo.guid))
		--test(index)
		if EquipUI.curGuardGuid then
			--test("=====EquipUI.curGuardGuid = "..EquipUI.curGuardGuid)
			CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "GuardRemoveGem", EquipUI.curGuardGuid, itemInfo.guid, index)
		else
			--test("=====itemInfo.guid = "..tostring(itemInfo.guid))
			--test("=====index = "..index)
			CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "RemoveGem", itemInfo.guid, index)
		end
	end
	--EquipGemInlayUI.UpdateGemList(index)
	CL.SendNotify(NOTIFY.RearrangeItem, System.Enum.ToInt(item_container_type.item_container_gem_bag))
	EquipGemInlayUI.Refresh()
end

function EquipGemInlayUI.OnEquipGemItemClick(guid)
	if EquipUI.tabSubIndex == 2 then
		EquipGemMergeUI.OnEquipGemItemClick(guid)
		return ;
	end

	local equipGemItem = GUI.GetByGuid(guid);
	local index = GUI.CheckBoxExGetIndex(equipGemItem)
	index = index + 1;
	data.equipGemIndex = index;
	local equipGemScroll = EquipUI.guidt.GetUI("equipGemScroll")
	GUI.LoopScrollRectRefreshCells(equipGemScroll)
end

function EquipGemInlayUI.OnEquipGemUpgradeClick(guid)			--从升级按钮点开快捷合成
	--FormEquip.EquipGem_QuickCompound(player, gem_Type, gem_id, targetgem_id)
	data.EquipGemInlayUI_targetgem_id = 0
	data.RightGemList_QuickMerge = 0
	local equipGemUpgradeBtn = GUI.GetByGuid(guid)
	local equipGemScroll = EquipUI.guidt.GetUI("equipGemScroll")			--gemId储存在这个obj上
	local index = GUI.GetData(equipGemUpgradeBtn, "index")
	local gem_id = GUI.GetData(equipGemScroll, "gemId"..index)
	local targetgem_id = gem_id + 1
	
	data.EquipGemInlayUI_Slot = index

	local gem_Type = DB.GetOnceItemByKey1(gem_id)['Subtype2']				--Subtype2是用于判断宝石种类的参数
	
	--local gemIcon_Right_Switch_1 = _gt.GetUI("gemIcon_Right_Switch_1")
	--GUI.SetData(gemIcon_Right_Switch_1, "gem_id", gem_id)
	--GUI.SetData(gemIcon_Right_Switch_1, "targetgem_id", targetgem_id)
	--local gemIcon_Right_Switch_2 = _gt.GetUI("gemIcon_Right_Switch_2")
	--GUI.SetData(gemIcon_Right_Switch_2, "gem_id", gem_id)
	--GUI.SetData(gemIcon_Right_Switch_2, "targetgem_id", targetgem_id)
	
	local itemmode = false
	if data.RightGemList_QuickMerge == 1 then
		itemmode = 0
	elseif data.RightGemList_QuickMerge == 0 then
		itemmode = 1
	end
	
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipGem_QuickCompound", gem_Type, gem_id, targetgem_id, itemmode)

end

function EquipGemInlayUI.RightGemList_QuickMergeClick(gem_id)				--从右侧宝石列表 快捷合成点击进入	gem_id需要传入
	data.EquipGemInlayUI_targetgem_id = 0
	local targetgem_id = gem_id + 1
	local gem_Type = DB.GetOnceItemByKey1(gem_id)['Subtype2']
	--local gemIcon_Right_Switch_1 = _gt.GetUI("gemIcon_Right_Switch_1")
	--GUI.SetData(gemIcon_Right_Switch_1, "gem_id", gem_id)
	--GUI.SetData(gemIcon_Right_Switch_1, "targetgem_id", targetgem_id)
	--local gemIcon_Right_Switch_2 = _gt.GetUI("gemIcon_Right_Switch_2")
	--GUI.SetData(gemIcon_Right_Switch_2, "gem_id", gem_id)
	--GUI.SetData(gemIcon_Right_Switch_2, "targetgem_id", targetgem_id)
	
	local itemmode = false
	if data.RightGemList_QuickMerge == 1 then
		itemmode = 0
	elseif data.RightGemList_QuickMerge == 0 then
		itemmode = 1
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipGem_QuickCompound", gem_Type, gem_id, targetgem_id, itemmode)
end

function EquipGemInlayUI.OnEquipGemUpgradeClick_S()
	local GemUpgrade_panelCover = _gt.GetUI("GemUpgrade_panelCover")
	GUI.SetVisible(GemUpgrade_panelCover,true)
end

function EquipGemInlayUI.On_TarGemSwitch_Click(guid)					--切换宝石合成等级
	local gemIcon_Right_Switch = GUI.GetByGuid(guid)
	local SwitchIcon = GUI.GetData(gemIcon_Right_Switch, "SwitchIcon")
	local gem_id = tonumber(GUI.GetData(gemIcon_Right_Switch, "gem_id"))
	test("=================gem_id = "..gem_id)
	local targetgem_id = tonumber(GUI.GetData(gemIcon_Right_Switch, "targetgem_id"))
	test("=================targetgem_id = "..targetgem_id)
	local gem_Type = DB.GetOnceItemByKey1(gem_id)['Subtype2']
	
	if data.EquipGemInlayUI_targetgem_id <= 5000 then
		data.EquipGemInlayUI_targetgem_id = targetgem_id
	end
	if SwitchIcon == "Left" then
		data.EquipGemInlayUI_targetgem_id = data.EquipGemInlayUI_targetgem_id - 1
	end
	if SwitchIcon == "Right" then
		data.EquipGemInlayUI_targetgem_id = data.EquipGemInlayUI_targetgem_id + 1
	end
	
	test("data.EquipGemInlayUI_targetgem_id = "..data.EquipGemInlayUI_targetgem_id)
	
	local itemmode = false
	if data.RightGemList_QuickMerge == 1 then
		itemmode = 0
	elseif data.RightGemList_QuickMerge == 0 then
		itemmode = 1
	end
	
	CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipGem_QuickCompound", gem_Type, gem_id, data.EquipGemInlayUI_targetgem_id, itemmode)
	
end

function EquipGemInlayUI.QuickMerge_Refresh()			--快捷合成界面专用刷新函数，等服务器调用
	--local MoneyType_IconTB = {[] = ""}
	--EquipGemInlayUI.QuickCompoundConsum				--服务器发过来的表单名字，为上方预览的两颗宝石数据(MoneyType, cur, tar, MoneyVal)
	--EquipGemInlayUI.QuickCompoundGemList				--服务器发过来的表单名字，为下方合成所需宝石(gemId, gemSelNum, gemNum)
	local MergeList = _gt.GetUI("MergeList")
	local gemIcon_Left = _gt.GetUI("gemIcon_Left");
	local gemIcon_Right = _gt.GetUI("gemIcon_Right");
	local Money_Icon = _gt.GetUI("Money_Icon")
	local Money_CostNum = _gt.GetUI("Money_CostNum")
	--local MergeList_Gem_Type = GUI.GetChild()
	local gem_Left_Level = _gt.GetUI("gem_Left_Level");
	local gem_Left_Type = _gt.GetUI("gem_Left_Type");
	local gem_Right_Level = _gt.GetUI("gem_Right_Level");
	local gem_Right_Type = _gt.GetUI("gem_Right_Type");
	local gemAtt_Change_Txt_1 = _gt.GetUI("gemAtt_Change_Txt_1");
	local gemAtt_Change_Txt_2 = _gt.GetUI("gemAtt_Change_Txt_2");
	local gemIcon_Right_Switch_1 = _gt.GetUI("gemIcon_Right_Switch_1")										--左箭头
	local gemIcon_Right_Switch_2 = _gt.GetUI("gemIcon_Right_Switch_2")                                      --右箭头
	local gemIcon_Right_Ex = _gt.GetUI("gemIcon_Right_Ex")
	local gemIcon_Right_MaxLevelInfo = _gt.GetUI("gemIcon_Right_MaxLevelInfo")
	local Txt_1_Right = _gt.GetUI("Txt_1_Right")
	local MergeBtn = _gt.GetUI("MergeBtn")
	
	local cur_gemDB = DB.GetOnceItemByKey1(EquipGemInlayUI.QuickCompoundConsum['cur']);	
	ItemIcon.BindItemDB(gemIcon_Left,cur_gemDB)
	data.EquipGemInlayUI_cur_gemDB = cur_gemDB
	local cur_gemType = string.split(cur_gemDB['Name'], "级")[2]
	GUI.StaticSetText(gem_Left_Level, cur_gemDB['Itemlevel'].."级")
	GUI.StaticSetText(gem_Left_Type, cur_gemType)
	--test("=========cur_gemDB['Itemlevel'] = "..cur_gemDB['Itemlevel'])
	if cur_gemDB['Itemlevel'] >= EquipGemInlayUI.MaxGemLevel then
		--GUI.SetVisible(gemIcon_Right, false)
		GUI.SetVisible(gemIcon_Right_Ex, false)
		GUI.SetVisible(gemIcon_Right_MaxLevelInfo, true)
		GUI.SetVisible(Txt_1_Right, false)
		GUI.SetVisible(gemAtt_Change_Txt_1, false)
		GUI.SetVisible(gemAtt_Change_Txt_2, false)
		GUI.SetVisible(gem_Right_Type, false)
		GUI.SetVisible(gem_Right_Level, false)
		GUI.ButtonSetShowDisable(MergeBtn, false)
	else	
		--GUI.SetVisible(gemIcon_Right, true)
		GUI.SetVisible(gemIcon_Right_Ex, true)
		GUI.SetVisible(gemIcon_Right_MaxLevelInfo, false)
		GUI.SetVisible(Txt_1_Right, true)
		GUI.SetVisible(gemAtt_Change_Txt_1, true)
		GUI.SetVisible(gemAtt_Change_Txt_2, true)
		GUI.SetVisible(gem_Right_Type, true)
		GUI.SetVisible(gem_Right_Level, true)
		GUI.ButtonSetShowDisable(MergeBtn, true)
	end

	local tar_gemDB = DB.GetOnceItemByKey1(EquipGemInlayUI.QuickCompoundConsum['tar']);	
	--test("===========tar_gemDB['Itemlevel'] = "..tar_gemDB['Itemlevel'])
	if tar_gemDB['Itemlevel'] <= EquipGemInlayUI.MaxGemLevel then
		ItemIcon.BindItemDB(gemIcon_Right,tar_gemDB)
		GUI.SetVisible(gemIcon_Right, true)
	else
		GUI.SetVisible(gemIcon_Right, false)
	end
	data.EquipGemInlayUI_tar_gemDB = tar_gemDB
	local tar_gemType = string.split(tar_gemDB['Name'], "级")[2]
	GUI.StaticSetText(gem_Right_Level, tar_gemDB['Itemlevel'].."级")
	GUI.StaticSetText(gem_Right_Type, tar_gemType)
	
	if tar_gemDB['Itemlevel'] - cur_gemDB['Itemlevel'] == 1 then
		GUI.SetVisible(gemIcon_Right_Switch_1, false)
	else
		GUI.SetVisible(gemIcon_Right_Switch_1, true)
	end
	
	if tar_gemDB['Itemlevel'] >= EquipGemInlayUI.MaxGemLevel then
		GUI.SetVisible(gemIcon_Right_Switch_2, false)
	else
		GUI.SetVisible(gemIcon_Right_Switch_2, true)
	end
	
	local gemAtt_Type_1 = DB.GetOnceItem_AttByKey1(EquipGemInlayUI.QuickCompoundConsum['cur'])['Att1']
	local cur_gemAtt_Num_1 = DB.GetOnceItem_AttByKey1(EquipGemInlayUI.QuickCompoundConsum['cur'])['Att1Max']
	local tar_gemAtt_Num_1 = DB.GetOnceItem_AttByKey1(EquipGemInlayUI.QuickCompoundConsum['tar'])['Att1Max']
	local gemAtt_Num_Diff_1 = tostring(tonumber(tostring(tar_gemAtt_Num_1)) - tonumber(tostring(cur_gemAtt_Num_1)))
	GUI.StaticSetText(gemAtt_Change_Txt_1, tostring(DB.GetOnceAttrByKey1(gemAtt_Type_1)['ChinaName']).."+"..gemAtt_Num_Diff_1)	--属性变化文字(中间绿色部分)
	local gemAtt_Type_2 = DB.GetOnceItem_AttByKey1(EquipGemInlayUI.QuickCompoundConsum['cur'])['Att2']
	local cur_gemAtt_Num_2 = DB.GetOnceItem_AttByKey1(EquipGemInlayUI.QuickCompoundConsum['cur'])['Att2Max']
	local tar_gemAtt_Num_2 = DB.GetOnceItem_AttByKey1(EquipGemInlayUI.QuickCompoundConsum['tar'])['Att2Max']
	local gemAtt_Num_Diff_2 = tostring(tonumber(tostring(tar_gemAtt_Num_2)) - tonumber(tostring(cur_gemAtt_Num_2)))
	if gemAtt_Type_2 ~= 0 then
		GUI.StaticSetText(gemAtt_Change_Txt_2, tostring(DB.GetOnceAttrByKey1(gemAtt_Type_2)['ChinaName']).."+"..gemAtt_Num_Diff_2)
	else
		GUI.SetVisible(gemAtt_Change_Txt_2, false)
	end
	local MoneyType = UIDefine.MoneyTypes[EquipGemInlayUI.QuickCompoundConsum['MoneyType'] or 5]
	local ownMoney = tonumber(tostring(CL.GetAttr(MoneyType)))
	local costMoney = EquipGemInlayUI.QuickCompoundConsum['MoneyVal']
	GUI.StaticSetText(Money_CostNum, costMoney)
	if ownMoney < costMoney then
		GUI.SetColor(Money_CostNum,UIDefine.RedColor)
	else
		GUI.SetColor(Money_CostNum,UIDefine.WhiteColor)
	end
	
	local QuickCompoundGemList_Num = 0
	if #EquipGemInlayUI.QuickCompoundGemList < 6 then
		QuickCompoundGemList_Num = 6
	else
		QuickCompoundGemList_Num = #EquipGemInlayUI.QuickCompoundGemList
	end
	
	GUI.SetData(gemIcon_Right_Switch_1, "gem_id", EquipGemInlayUI.QuickCompoundConsum['cur'])
	GUI.SetData(gemIcon_Right_Switch_1, "targetgem_id", EquipGemInlayUI.QuickCompoundConsum['tar'])
	
	GUI.SetData(gemIcon_Right_Switch_2, "gem_id", EquipGemInlayUI.QuickCompoundConsum['cur'])
	GUI.SetData(gemIcon_Right_Switch_2, "targetgem_id", EquipGemInlayUI.QuickCompoundConsum['tar'])

	GUI.LoopScrollRectSetTotalCount(MergeList, QuickCompoundGemList_Num)
	GUI.LoopScrollRectRefreshCells(MergeList)
	
end

function EquipGemInlayUI.GetSelfEquipInfo()
	for key, value in pairs(data.items) do
		data.items[key] = EquipScrollItem.GetItemByType(
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

function EquipGemInlayUI.RefreshLeftItem(guid, index)
	local type = data.getBagType()
	EquipScrollItem.RefreshLeftItem_GemByItemInfo(guid, type, data.items[type][index])
	local item = GUI.GetByGuid(guid)
	if index == data.index then
		data.indexGuid = guid
		GUI.CheckBoxExSetCheck(item, true)
	else
		GUI.CheckBoxExSetCheck(item, false)
	end
	
	-- 小红点
	local itemInfo = data.items[type][index]
	local isShowRedPoint = false
	if itemInfo and type == item_container_type.item_container_equip then
		local itemData = EquipUI.GetEquipData(itemInfo.guid, type, itemInfo.site)
		local site = itemInfo.site
		-- if type ~= item_container_type.item_container_equip then
		-- 	local itemDB = DB.GetOnceItemByKey1(itemData.id)
		-- 	site = LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
		-- end
		local equipGemBagList,equipGemBagLevelList = EquipGemInlayUI.GetEquipGemBagList(site)
		local itemGemList,itemGemLevelList = EquipGemInlayUI.GetItemGemList(itemData)
		for i = 1, #equipGemBagLevelList, 1 do
			local bagGemlv = equipGemBagLevelList[i]
			for j = 1, #itemGemLevelList, 1 do
				local itemGemlv = itemGemLevelList[j]
				if itemGemlv < bagGemlv then
					isShowRedPoint = true
					break;
				end
			end
			if isShowRedPoint then
				break
			end
		end
	end
	GlobalProcessing.SetRetPoint(item,isShowRedPoint)
	if firstClick and index == data.index then
		firstClick = false
		local itemData = EquipUI.GetEquipData(itemInfo.guid, type, itemInfo.site)
		local itemGemList,itemGemLevelList = EquipGemInlayUI.GetItemGemList(itemData)
		local gemIndex = 0
		for i = 1, #itemGemList, 1 do
			local gemId = itemGemList[i]
			if gemId == 0 then
				gemIndex = i
				break
			end
		end
		if gemIndex == 0 then
			data.equipGemIndex = 1
		else
			data.equipGemIndex = gemIndex
		end
	end
end
function EquipGemInlayUI.OnLeftItemClick(guid)
	local item = GUI.GetByGuid(guid)
	GUI.CheckBoxExSetCheck(item, true)
	data.index = GUI.CheckBoxExGetIndex(item) + 1
	if guid ~= data.indexGuid then
		GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
		data.indexGuid = guid
	end
	local itemInfo = EquipGemInlayUI.GetItem()
	local itemData = EquipUI.GetEquipData(itemInfo.guid, data.getBagType(), itemInfo.site)
	local itemGemList,itemGemLevelList = EquipGemInlayUI.GetItemGemList(itemData)
	local gemIndex = 0
	for i = 1, #itemGemList, 1 do
		local gemId = itemGemList[i]
		if gemId == 0 then
			gemIndex = i
			break
		end
	end
	if gemIndex == 0 then
		data.equipGemIndex = 1
	else
		data.equipGemIndex = gemIndex
	end
	data.gemTypeIndex = 1
	EquipGemInlayUI.Refresh();
end
---@return eqiupItem
function EquipGemInlayUI.GetItem(index)
	if index == nil then
		index = data.index
	end
	local type = data.getBagType()
	return data.items[type][index]
end
--CL.SendNotify(NOTIFY.RearrangeItem, System.Enum.ToInt(item_container_type.item_container_gem_bag))

function EquipGemInlayUI.GetItemGemList(itemData)
	local itemGemList = {}
	local itemGemLevelList = {}
	if itemData then
		local gemCount, siteCount = LogicDefine.GetEquipGemCount(itemData)
		for i = 1, siteCount do
			local gemId = itemData:GetIntCustomAttr(LogicDefine.ITEM_GemId_ .. i)
			table.insert(itemGemList,gemId)
			if gemId == 0 then
				table.insert(itemGemLevelList,0)
			else
				local gemDB = DB.GetOnceItemByKey1(gemId)
				table.insert(itemGemLevelList,tonumber(gemDB.Itemlevel))
			end
		end
	end
	return itemGemList,itemGemLevelList
end
function EquipGemInlayUI.GetItemGemBagByTypeList(gemType)
	local itemGemBagByTypeList = {}
	local itemGemBagByTypeLevelList = {}
	if GlobalProcessing.EquipGem_HaveGemTypeList then
		for id, gemvalue in pairs(GlobalProcessing.EquipGem_HaveGemTypeList[tostring(gemType)]) do
			table.insert(itemGemBagByTypeList,id)
			table.insert(itemGemBagByTypeLevelList,gemvalue.level)
		end
	end
	return itemGemBagByTypeList,itemGemBagByTypeLevelList
end
function EquipGemInlayUI.GetEquipGemBagList(site)
	local equipGemBagList = {}
	local equipGemBagLevelList = {}
	if GlobalProcessing.EquipGem_HaveSiteList and GlobalProcessing.EquipGem_HaveSiteList[tostring(site)] then
		for id, gemvalue in pairs(GlobalProcessing.EquipGem_HaveSiteList[tostring(site)]) do
			table.insert(equipGemBagList,id)
			table.insert(equipGemBagLevelList,gemvalue.level)
		end
	end
	return equipGemBagList,equipGemBagLevelList
end

function EquipGemInlayUI.CheckRedPoint()
	local gemInlayGroup = EquipUI.guidt.GetUI("gemInlayGroup")
	local inEquipBtn = GUI.GetChild(gemInlayGroup,"inEquipBtn",false)
	if EquipUI.tabIndex == 2 and EquipUI.tabSubIndex == 1 then
		GlobalProcessing.SetRetPoint(inEquipBtn,GlobalProcessing.isEquipGemInlayShowRedPoint)
		EquipGemInlayUI.Refresh()
	end
end