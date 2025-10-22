local PetEquipRepairUI = {
}
_G.PetEquipRepairUI = PetEquipRepairUI

-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
-- 字体大小
local fontSizeDefault = 22
local fontSizeSmaller = 20
local fontSizeBigger = 24
local fontSizeBtn = 26
local fontSizeTitle = 26

-- 颜色
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorYellow = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorLevel = Color.New(169 / 255, 127 / 255, 85 / 255, 255 / 255)
local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)
local colorGray = Color.New(192 / 255, 192 / 255, 192 / 255, 255 / 255)
local colorGreen = Color.New(8 / 255, 175 / 255, 0 / 255, 255 / 255)
local colorLight = Color.New(247 / 255, 232 / 255, 184 / 255, 255/255)
local invisibilityColor = Color.New(255 / 255,255 / 255,255 / 255,0 / 255)
local colorFightChangeTitle = Color.New(162 / 255, 75 / 255, 21 / 255, 1)


local data = {
    -- 背包中，装备中类型
    Bagtype = 1,
    -- 选中的道具下标
    index = 1,
    -- 选中的道具uiGuId
    indexGuid = int64.new(0),
    -- 当前锁定属性状态
    lock = {},
    lockattr = {},
    -- 可用道具
    items = {
        ---@type eqiupItem[]
        [item_container_type.item_container_pet_equip] = {},
        ---@type eqiupItem[]
        [item_container_type.item_container_bag] = {}
    },
    -- 动态属性
    attrs = {
        ---@type DynAttrData[][]
        [item_container_type.item_container_pet_equip] = {},
        ---@type DynAttrData[][]
        [item_container_type.item_container_bag] = {}
    },
    -- 消耗道具
    ---@type eqiupItem[]
    consumeItem = {}
}



local LabelList = {
	{ "装备", "PetEquipRepairTog", "OnPetEquipRepairToggle", "PetEquipRepairPage", "CreatePetEquipRepairPage" },
	{ "洗炼", "PetEquipClearTog", "OnPetEquipClearToggle", "PetEquipClearPage", "CreatePetEquipClearPage" },
}

local tabBtns = {
    { "装备中", "tabUse" },
    { "背包中", "tabBag" }
}

local SubPageBtn = {
    { "强化", "TabRepair" },
    { "修理", "TabStrengthen" }
}

local equipSiteData={
  [1]={site=LogicDefine.PetEquipSite.site_collar,img="1801400030"},
  [2]={site=LogicDefine.PetEquipSite.site_armor,img="1801400040"},
  [3]={site=LogicDefine.PetEquipSite.site_amulet,img="1801400050"},
  [4]={site=LogicDefine.PetEquipSite.site_accessory,img="1801400060"}
}

local CurSelectPage = 1
local CurSelectLeftPage = 1
local CurSelectSubPage = 1
local CurSelectPetEquipIndex = 1 
local IndexPetEquipItemGuid = {}
--默认使用非绑材料
PetEquipRepairUI.UnBind = 0
--默认使用保固石
PetEquipRepairUI.IsSafe = 1

local equipData =nil

local _gt = UILayout.NewGUIDUtilTable()

function PetEquipRepairUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("PetEquipRepairUI", "PetEquipRepairUI", 0, 0);
	GUI.SetVisible(panel, false)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "宠物装备培养", "PetEquipRepairUI", "OnCloseBtnClick", _gt)
	_gt.BindName(panelBg,"panelBg")
    UILayout.CreateRightTab(LabelList, "PetEquipRepairUI")

end

function PetEquipRepairUI.OnShow(parameter)
    local wnd = GUI.GetWnd("PetEquipRepairUI")
    if wnd then
        GUI.SetVisible(wnd, true)
    end
	PetEquipRepairUI.InitData()
	--注册监听事件
	PetEquipRepairUI.RegisterEvent()
	
	if parameter then
		parameter = string.split(parameter, ",")
		CurSelectPage = tonumber(parameter[1])
		CurSelectLeftPage = tonumber(parameter[2])
		PetEquipRepairUI.SelectedGuid = parameter[3]
		if tonumber(parameter[4]) == nil then
			CurSelectSubPage = 2
		else
			CurSelectSubPage = tonumber(parameter[4])
		end
		if tonumber(PetEquipRepairUI.SelectedGuid) ~= nil then
			PetEquipRepairUI.JumpState = 1
		end
	end
	if not PetUI or not PetUI.petGuidList then
		require "PetUI"
		PetUI.petGuidList = LD.GetPetGuids()
	end
	
	--功能未开启
	if UIDefine.FunctionSwitch and UIDefine.FunctionSwitch["PetEquipIntensify"] ~= "on" then
		CurSelectSubPage = 2
		PetEquipRepairUI.StrengthenConfig = {}
	end

	if PetEquipRepairUI.PetEquipRepair_ConsumeEx and PetEquipRepairUI.StrengthenConfig then
		PetEquipRepairUI.RefreshServerData()
	else
		CL.SendNotify(NOTIFY.SubmitForm, "FormPetEquipIntensify", "GetData")
		CL.SendNotify(NOTIFY.SubmitForm, "FormPetEquipRepair", "GetData")
	end
end

function PetEquipRepairUI.InitData()
	CurSelectPage = 1
	CurSelectLeftPage = 1
	CurSelectPetEquipIndex = 1 
	IndexPetEquipItemGuid = {}
	-- PetEquipRepairUI.StrengthenConfig = nil
	
	--跳转状态关闭
	PetEquipRepairUI.JumpState = 0
end

function PetEquipRepairUI.RegisterEvent()
	CL.RegisterAttr(RoleAttr.RoleAttrBindGold,PetEquipRepairUI.OnBindGoldRefresh)
	CL.RegisterMessage(GM.RefreshBag,"PetEquipRepairUI","OnItemRefresh")
end


function PetEquipRepairUI.OnCloseBtnClick()
	GUI.CloseWnd("PetEquipRepairUI")
end

function PetEquipRepairUI.RefreshServerData()
	if CurSelectPage ==1 then
		PetEquipRepairUI.RefreshPetEquipRepairPage()
	elseif CurSelectPage ==2 then
		PetEquipRepairUI.RefreshPetEquipClearPage()
	end
	--确保数据到了才进行
	if PetEquipRepairUI.PetEquipRepair_ConsumeEx and PetEquipRepairUI.StrengthenConfig then
		UILayout.OnTabClick(CurSelectPage, LabelList)
		PetEquipRepairUI.OnTabBtnClick(tabBtns[CurSelectLeftPage].guid)

		--装备页子页签是否显示
		-- CDebug.LogError(CurSelectPage..CurSelectSubPage)
		PetEquipRepairUI.RefreshEquipPageButton(CurSelectPage,CurSelectSubPage)
		
		
		--打印强化配置表
		-- local inspect = require("inspect")
		-- CDebug.LogError(inspect(PetEquipRepairUI.StrengthenConfig))
	end
end

function PetEquipRepairUI.OnPetEquipRepairToggle(key)
	--切换后默认选择第一页第一个物品
	CurSelectLeftPage = 1
	CurSelectPage = 1
	
	UILayout.OnTabClick(CurSelectPage, LabelList)
	PetEquipRepairUI.RefreshEquipPageButton(CurSelectPage,CurSelectSubPage)
	PetEquipRepairUI.OnTabBtnClick(tabBtns[CurSelectLeftPage].guid)
    PetEquipRepairUI.RefreshPetEquipRepairPage()
	
end	

function PetEquipRepairUI.RefreshEquipPageButton(page1,page2)
	--判断子页签按钮是否被创建
	local btn = _gt.GetUI("SubPageBtn1")
	if btn then
		for i =1 ,#SubPageBtn do
			btn = _gt.GetUI("SubPageBtn"..i)
			if tostring(page1) == "1" then
				GUI.SetVisible(btn, true)
				local btnSprite = GUI.GetChild(btn,"btnSprite")
				GUI.SetVisible(btnSprite, page2 == i)
			else
				GUI.SetVisible(btn, false)
			end
		end
	else
    -- 创建各分页按钮
		local btnWidth = 172
		local btnHeight = 48
		local parent = _gt.GetUI("panelBg")
		for i = 1, #SubPageBtn do
			local Btn = GUI.ButtonCreate(parent, SubPageBtn[i][2], "1800402030", 267.5 + (i - 1) * btnWidth, -250, Transition.None, "", btnWidth, btnHeight, false)
			SetAnchorAndPivot(Btn, UIAnchor.Center, UIAroundPivot.Center)
			_gt.BindName(Btn,"SubPageBtn"..i)
			GUI.SetData(Btn,"index",i)
			GUI.SetVisible(Btn, tostring(page1) == "1")

			
			local btnSprite = GUI.ImageCreate(Btn, "btnSprite", "1800402032", 0, 0, false, btnWidth, btnHeight)
			SetAnchorAndPivot(btnSprite, UIAnchor.Center, UIAroundPivot.Center)
			GUI.SetVisible(btnSprite, tostring(page2) == tostring(i))

			local labelTxt = GUI.CreateStatic( Btn, SubPageBtn[i][2] .. "label", SubPageBtn[i][1], 0, 0, btnWidth, btnHeight, "system", true, false)
			SetAnchorAndPivot(labelTxt, UIAnchor.Center, UIAroundPivot.Center)
			GUI.StaticSetFontSize(labelTxt, fontSizeBtn)
			GUI.StaticSetAlignment(labelTxt, TextAnchor.MiddleCenter)
			GUI.SetColor(labelTxt, colorDark)

			GUI.RegisterUIEvent(Btn, UCE.PointerClick, "PetEquipRepairUI", "OnSubPageBtnClick")
		end
	end
	
	--功能未开启时隐藏按钮
	if UIDefine.FunctionSwitch and UIDefine.FunctionSwitch["PetEquipIntensify"] ~= "on" then
		local btn = _gt.GetUI("SubPageBtn1")
		GUI.SetVisible(btn,false)
	end
end

function PetEquipRepairUI.OnSubPageBtnClick(guid)
		-- CDebug.LogError(1232)
		local btn = GUI.GetByGuid(guid)
		local index = tonumber(GUI.GetData(btn,"index"))
		for i =1 ,#SubPageBtn do
			local btn = _gt.GetUI("SubPageBtn"..i)
			local btnSprite = GUI.GetChild(btn,"btnSprite")
			GUI.SetVisible(btnSprite, index == i)
		end
		CurSelectSubPage = index
		--默认选择第一个装备
		CurSelectPetEquipIndex = 1 

		--刷新右侧
		PetEquipRepairUI.RefreshPetEquipRepairPage()		
		
		PetEquipRepairUI.OnTabBtnClick(tabBtns[CurSelectLeftPage].guid)
		
end

function PetEquipRepairUI.OnTabBtnClick(guid)
	-- CDebug.LogError(222222)
	local key = GUI.GetName(GUI.GetByGuid(guid))
    for i = 1, #tabBtns do
        local sprite = GUI.Get("PetEquipRepairUI/panelBg/" .. tabBtns[i][2] .. "/btnSprite")    
		GUI.SetVisible(sprite,tabBtns[i].guid == guid )
    end
	if key == tabBtns[1][2] then
	CurSelectLeftPage = 1
	elseif key == tabBtns[2][2] then
	CurSelectLeftPage = 2
	end
	
	--默认选择第一个装备
	CurSelectPetEquipIndex = 1 
	
	--创建左侧循环列表
	PetEquipRepairUI.CreatePetEquipLeftPage()
	--刷新左侧循环列表
	PetEquipRepairUI.RefreshPetEquipLeftPage()
end

function PetEquipRepairUI.RefreshPetEquipRepairPage()
	--增加强化页至原修理页上 21.12.2
	local PetEquipRepairPage = _gt.GetUI("PetEquipRepairPage")
	local PetEquipStrengthenPage =_gt.GetUI("PetEquipStrengthenPage")
	local RepairAllBth = _gt.GetUI("RepairAllBth")
	if CurSelectSubPage == 1 then
		GUI.SetVisible(RepairAllBth,false)
		GUI.SetVisible(PetEquipRepairPage, false)
		if not PetEquipStrengthenPage then
			PetEquipStrengthenPage = PetEquipRepairUI.CreatePetEquipStrengthenPage("PetEquipStrengthenPage")
		else
			GUI.SetVisible(PetEquipStrengthenPage, true)
		end		
	elseif  CurSelectSubPage == 2 then
		GUI.SetVisible(RepairAllBth,true)
		GUI.SetVisible(PetEquipStrengthenPage, false)
		
		if not PetEquipRepairPage then
			PetEquipRepairPage = PetEquipRepairUI.CreatePetEquipRepairPage("PetEquipRepairPage")
		else
			GUI.SetVisible(PetEquipRepairPage, true)
		end
	end
	
	--隐藏其他页
	local PetEquipClearPage = _gt.GetUI("PetEquipClearPage")
	if PetEquipClearPage then
	GUI.SetVisible(PetEquipClearPage, false)
	end
	
	if CurSelectSubPage == 2 then
	--还原修理装备页面数据
	local RepairItemIcon =  _gt.GetUI("RepairItemIcon") 
	
	local EquipIcon = _gt.GetUI("EquipIcon")
	GUI.ItemCtrlSetElementValue(EquipIcon,eItemIconElement.Icon,"")
	GUI.ItemCtrlSetElementValue(EquipIcon,eItemIconElement.Border,"1800400330")
	GUI.ItemCtrlSetElementValue(EquipIcon,eItemIconElement.LeftBottomSp,"")
	GUI.ItemCtrlSetElementValue(EquipIcon,eItemIconElement.LeftTopSp,"")
	
	local petIcon = _gt.GetUI("petIcon")
	GUI.SetVisible(petIcon,false)
	local tmpName = _gt.GetUI("tmpName")
	GUI.SetVisible(tmpName,false)
	local petName = _gt.GetUI("petName")
	GUI.SetVisible(petName,false)
	local NameTxt = _gt.GetUI("NameTxt")
	GUI.StaticSetText(NameTxt,"")	
	local LevelAndTypeTxt = _gt.GetUI("LevelAndTypeTxt")
	GUI.StaticSetText(LevelAndTypeTxt,"")
	local RepairTipNum1 = _gt.GetUI("RepairTipNum1")
	GUI.StaticSetText(RepairTipNum1,"0")	
	local RepairTipNum2 = _gt.GetUI("RepairTipNum2")
	GUI.StaticSetText(RepairTipNum2,"0")
	local MoneyCostText = _gt.GetUI("MoneyCostText")
	GUI.StaticSetText(MoneyCostText,"0")
	
	GUI.SetVisible(RepairItemIcon,false)
	
	elseif  CurSelectSubPage == 1 then
	--强化提示
	local StrengthenTips =  _gt.GetUI("StrengthenTips") 
	if PetEquipRepairUI.StrengthenConfig then
	GUI.StaticSetText(StrengthenTips,PetEquipRepairUI.StrengthenConfig["Tips"])
	end
	--还原强化页数据
	local icon = _gt.GetUI("StrengthenEquip")
	GUI.SetVisible(icon,false)
	
	local name = _gt.GetUI("StrengthenEquipName")
	-- GUI.SetPositionX(Name,0)
	GUI.StaticSetText(name,"")

	local arrow = GUI.GetChild(name,"arrow")
	GUI.SetVisible(arrow,false)
	local level = GUI.GetChild(name,"level")
	GUI.SetVisible(level,false)
					
	local rate = _gt.GetUI("StrengthenSuccessRate")
	GUI.StaticSetText(rate,"")
	
	
	PetEquipRepairUI.ResetCurScroll = 1
	local CurStrengthenScroll = _gt.GetUI("CurStrengthenScroll")
	GUI.LoopScrollRectSetTotalCount(CurStrengthenScroll, 4)
	GUI.LoopScrollRectRefreshCells(CurStrengthenScroll)
						
	PetEquipRepairUI.ResetPreScroll = 1
	local PreStrengthenScroll = _gt.GetUI("PreStrengthenScroll")
	GUI.LoopScrollRectSetTotalCount(PreStrengthenScroll, 4)
	GUI.LoopScrollRectRefreshCells(PreStrengthenScroll)
	
	local StrengthenCutLine = _gt.GetUI("StrengthenCutLine")
	GUI.StaticSetText(StrengthenCutLine,"强化后属性加成")
	
	local cost = _gt.GetUI("StrengthenMoneyCost")
	GUI.StaticSetText(cost,"0")	
	
	local item1 =  _gt.GetUI("StrengthenItem1")
	GUI.ItemCtrlSetElementValue(item1,eItemIconElement.Icon,"")
	GUI.ItemCtrlSetElementValue(item1,eItemIconElement.Border,"1800400330")
	GUI.ItemCtrlSetElementValue(item1,eItemIconElement.RightBottomNum,"")

	local item2 =  _gt.GetUI("StrengthenItem2")
	GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Icon,"")
	GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Border,"1800400330")
	GUI.ItemCtrlSetElementValue(item2,eItemIconElement.RightBottomNum,"")
	end
	
	--尝试 
	-- itemGUID = nil
	
end	

function PetEquipRepairUI.CreatePetEquipRepairPage(pageName)
		local panelBg = _gt.GetUI("panelBg")
		local PetEquipRepairPage = GUI.GroupCreate(panelBg ,pageName, 0, 0, 0, 0)
		_gt.BindName(PetEquipRepairPage, pageName)
		
		local RepairRightPage = GUI.ImageCreate( PetEquipRepairPage, "RepairRightPage", "1801100100", 520, 2);
        SetAnchorAndPivot(RepairRightPage, UIAnchor.Right, UIAroundPivot.Right)
	---按钮需要绑定事件
		local RepairAllBth = GUI.ButtonCreate(PetEquipRepairPage,"RepairAllBth","1800402080",330,288,Transition.ColorTint, "")
		SetAnchorAndPivot(RepairAllBth, UIAnchor.BottomRight , UIAroundPivot.BottomRight )
		GUI.RegisterUIEvent(RepairAllBth, UCE.PointerClick, "PetEquipRepairUI", "OnRepairAllBthClick")
		_gt.BindName(RepairAllBth,"RepairAllBth")
		local ReapairAllTxt =GUI.CreateStatic(RepairAllBth,"ReapairAllTxt","修理全部",0,0,400,200)
		SetAnchorAndPivot(ReapairAllTxt, UIAnchor.Center , UIAroundPivot.Center )
		GUI.StaticSetFontSize(ReapairAllTxt, fontSizeBtn)
		GUI.StaticSetAlignment(ReapairAllTxt, TextAnchor.MiddleCenter)
		GUI.SetIsOutLine(ReapairAllTxt, true)
		GUI.SetOutLine_Color(ReapairAllTxt, colorOutline)
		GUI.SetOutLine_Distance(ReapairAllTxt, 1)
		
		local RepairBth = GUI.ButtonCreate(PetEquipRepairPage,"RepairBth","1800402080",510,288,Transition.ColorTint, "")
		SetAnchorAndPivot(RepairBth, UIAnchor.BottomRight , UIAroundPivot.BottomRight )
		GUI.RegisterUIEvent(RepairBth, UCE.PointerClick, "PetEquipRepairUI", "OnRepairBthClick")
		local ReapairTxt =GUI.CreateStatic(RepairBth,"ReapairTxt","修  理",0,0,400,200)
		SetAnchorAndPivot(ReapairTxt, UIAnchor.Center , UIAroundPivot.Center )
		GUI.StaticSetFontSize(ReapairTxt, fontSizeBtn)
		GUI.StaticSetAlignment(ReapairTxt, TextAnchor.MiddleCenter)
		GUI.SetIsOutLine(ReapairTxt, true)
		GUI.SetOutLine_Color(ReapairTxt, colorOutline)
		GUI.SetOutLine_Distance(ReapairTxt, 1)
		
		local MoneyCost = GUI.CreateStatic(PetEquipRepairPage, "MoneyCost", "消耗", -210, 285, 200, 50)
		SetAnchorAndPivot(MoneyCost, UIAnchor.BottomLeft , UIAroundPivot.BottomLeft );
		GUI.SetColor(MoneyCost, colorDark);
		GUI.StaticSetFontSize(MoneyCost, 26)
	
		local MoneyCostBg = GUI.ImageCreate(MoneyCost, "MoneyCostBg", "1800700010", 65, 5, false, 200, 36)
		
		local MoneyCostIcon = GUI.ImageCreate(MoneyCostBg, "MoneyCostIcon", "1800408280", 0, 1, false, 36, 36)
		SetAnchorAndPivot(MoneyCostIcon, UIAnchor.Left , UIAroundPivot.Left )
		_gt.BindName(MoneyCostIcon,"MoneyCostIcon")

		local MoneyCostText = GUI.CreateStatic(MoneyCostBg, "MoneyCostText", "0", 0, 1, 200, 35,"system",true)
		GUI.SetColor(MoneyCostText, UIDefine.White2Color);
		GUI.StaticSetFontSize(MoneyCostText, 22);
		GUI.StaticSetAlignment(MoneyCostText, TextAnchor.MiddleCenter)
		_gt.BindName(MoneyCostText, "MoneyCostText")
--中间物品图像框
		local EquipBg = GUI.ImageCreate( RepairRightPage, "EquipBg", "1801100050", 0, -130);
        SetAnchorAndPivot(EquipBg, UIAnchor.Center, UIAroundPivot.Center)
		local EquipIcon = GUI.ItemCtrlCreate( EquipBg, "EquipIcon", "1800400330", 0, 0);
        SetAnchorAndPivot(EquipIcon, UIAnchor.Center, UIAroundPivot.Center)
		_gt.BindName(EquipIcon,"EquipIcon")
		
		local NameTxt = GUI.CreateStatic(RepairRightPage, "NameTxt", "", 0, -50, 200, 80)
		SetAnchorAndPivot(NameTxt, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetColor(NameTxt, colorDark)
		GUI.StaticSetFontSize(NameTxt, fontSizeBigger)
		GUI.StaticSetAlignment (NameTxt,TextAnchor.MiddleCenter)
		_gt.BindName(NameTxt, "NameTxt")
		
		local LevelAndTypeTxt = GUI.CreateStatic(RepairRightPage, "LevelAndTypeTxt", "", 0, -20, 200, 80)
		SetAnchorAndPivot(LevelAndTypeTxt, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetColor(LevelAndTypeTxt, colorYellow)
		GUI.StaticSetFontSize(LevelAndTypeTxt, fontSizeBigger)
		GUI.StaticSetAlignment (LevelAndTypeTxt,TextAnchor.MiddleCenter)
		_gt.BindName(LevelAndTypeTxt, "LevelAndTypeTxt")
		
		local RepairTipsBg1 = GUI.ImageCreate( RepairRightPage, "RepairTipsBg1", "1801100070", 160, 30);
        SetAnchorAndPivot(RepairTipsBg1, UIAnchor.Center, UIAroundPivot.Center)
		local RepairTipTxt1 = GUI.CreateStatic(RepairTipsBg1, "RepairTipTxt1", "当前耐久度", -100, 0, 200, 35);
		SetAnchorAndPivot(RepairTipTxt1, UIAnchor.Center, UIAroundPivot.Left)
		GUI.SetColor(RepairTipTxt1, colorDark);
		GUI.StaticSetFontSize(RepairTipTxt1, 24)
		
		local RepairTipNum1= GUI.CreateStatic(RepairTipsBg1, "RepairTipNum1", "0", 80, 0, 200, 35)
		GUI.SetColor(RepairTipNum1, colorYellow)
		GUI.StaticSetFontSize(RepairTipNum1, 24)
		GUI.StaticSetAlignment (RepairTipNum1,TextAnchor.MiddleCenter)
		_gt.BindName(RepairTipNum1, "RepairTipNum1")

		local RepairTipsBg2 = GUI.ImageCreate( RepairRightPage, "RepairTipsBg2", "1801100070", -160, 30);
        SetAnchorAndPivot(RepairTipsBg2, UIAnchor.Center, UIAroundPivot.Center)
		local RepairTipTxt2 = GUI.CreateStatic(RepairTipsBg2, "RepairTipTxt2", "修复后耐久度", -100, 0, 200, 35);
		SetAnchorAndPivot(RepairTipTxt2, UIAnchor.Center, UIAroundPivot.Left)
		GUI.SetColor(RepairTipTxt2, colorDark);
		GUI.StaticSetFontSize(RepairTipTxt2, 24)
		
		local RepairTipNum2= GUI.CreateStatic(RepairTipsBg2, "RepairTipNum2", "0", 80, 0, 200, 35)
		GUI.SetColor(RepairTipNum2, colorYellow)
		GUI.StaticSetFontSize(RepairTipNum2, 24)
		GUI.StaticSetAlignment (RepairTipNum2,TextAnchor.MiddleCenter)
		_gt.BindName(RepairTipNum2, "RepairTipNum2")
		
		local jianTou = GUI.ImageCreate( RepairRightPage, "jianTou", "1801100060", 0, 30);
        SetAnchorAndPivot(jianTou, UIAnchor.Center, UIAroundPivot.Center)

		
--右上角使用者头像
		local petIcon = GUI.ImageCreate( RepairRightPage, "petIcon", "1800400050", 20, 15,false,64,64);
        SetAnchorAndPivot(petIcon, UIAnchor.TopRight, UIAroundPivot.TopRight)
		_gt.BindName(petIcon, "petIcon")
        local tmpName = GUI.CreateStatic(RepairRightPage, "tmpName","装备使用者", 15, -195,200,200)
        SetAnchorAndPivot(tmpName, UIAnchor.Right, UIAroundPivot.Right)
		GUI.SetColor(tmpName, colorDark);
		GUI.StaticSetFontSize(tmpName, 24)
		_gt.BindName(tmpName, "tmpName")
		local petName = GUI.CreateStatic(RepairRightPage, "petName","txt", 95, -165,200,200)
        SetAnchorAndPivot(petName, UIAnchor.Right, UIAroundPivot.Right)
		GUI.SetColor(petName, colorGreen);
		GUI.StaticSetFontSize(petName, 24)
		GUI.StaticSetAlignment(petName,TextAnchor.MiddleRight)
		_gt.BindName(petName, "petName")
	
--下方道具消耗
		local RepairItemIcon = GUI.ItemCtrlCreate(RepairRightPage, "RepairItemIcon", "1800400330", 0, -35);
		SetAnchorAndPivot(RepairItemIcon, UIAnchor.Bottom, UIAroundPivot.Bottom)
		GUI.RegisterUIEvent(RepairItemIcon, UCE.PointerClick, "PetEquipRepairUI","OnRepairItemClick")
		_gt.BindName(RepairItemIcon,"RepairItemIcon")
		
		local RepairItemName = GUI.CreateStatic(RepairItemIcon, "RepairItemName","混元石", 0, -38 ,150,50)
		SetAnchorAndPivot(RepairItemName, UIAnchor.Bottom, UIAroundPivot.Bottom)
		GUI.SetColor(RepairItemName,colorDark);
		GUI.StaticSetFontSize(RepairItemName, 22)
		GUI.StaticSetAlignment(RepairItemName,TextAnchor.MiddleCenter)		
		
--anniu
		local Btn = _gt.GetUI("tempBtn1")
		if not Btn then
			local btnWidth = 145
			local btnHeight = 45
			for i = 1, #tabBtns do
				local tempBtn = GUI.ButtonCreate( panelBg, tabBtns[i][2], "1800402030", 80 + (i - 1) * btnWidth, 55, Transition.None, "", btnWidth, btnHeight, false)
				SetAnchorAndPivot(tempBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
				tabBtns[i].guid = GUI.GetGuid(tempBtn)
				_gt.BindName(tempBtn,"tempBtn"..i)
				
				local btnSprite = GUI.ImageCreate( tempBtn, "btnSprite", "1800402032", 0, 0, false, btnWidth, btnHeight)
				SetAnchorAndPivot(btnSprite, UIAnchor.Center, UIAroundPivot.Center)
				GUI.SetVisible(btnSprite, false)

				local labelTxt = GUI.CreateStatic( tempBtn, tabBtns[i][2] .. "label", tabBtns[i][1], 0, 0, btnWidth, btnHeight, "system", true, false)
				SetAnchorAndPivot(labelTxt, UIAnchor.Center, UIAroundPivot.Center)
				GUI.StaticSetFontSize(labelTxt, 22)
				GUI.StaticSetAlignment(labelTxt, TextAnchor.MiddleCenter)
				GUI.SetColor(labelTxt, colorDark)

				GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "PetEquipRepairUI", "OnTabBtnClick")
			end
		end
		---默认第一页
		-- PetEquipRepairUI.OnTabBtnClick(tabBtns[1].guid)
		
		return RepairRightPage
		
end


function PetEquipRepairUI.CreatePetEquipStrengthenPage(pageName)
	local panelBg = _gt.GetUI("panelBg")
	local PetEquipStrengthenPage = GUI.GroupCreate(panelBg ,pageName, 0, 0, 0, 0)
	_gt.BindName(PetEquipStrengthenPage, pageName)
	
	--中间部分
	local StrengthenCenterImg = GUI.ImageCreate( PetEquipStrengthenPage, "StrengthenCenterImg", "1801719050",-30,-40,false,580,527);
    SetAnchorAndPivot(StrengthenCenterImg, UIAnchor.Center, UIAroundPivot.Center)
		
	local StrengthenEquip = GUI.ImageCreate(StrengthenCenterImg, "StrengthenEquip", "1900100100",5.9,-41,true,68,68)
	SetAnchorAndPivot(StrengthenEquip, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(StrengthenEquip,"StrengthenEquip")
	
	local StrengthenEquipName = GUI.CreateStatic(PetEquipStrengthenPage, "StrengthenEquipName", "皮革项圈+4", -50, 45, 300, 35,"system",true)
	GUI.SetColor(StrengthenEquipName, colorDark);
	GUI.StaticSetFontSize(StrengthenEquipName, 28);
	GUI.StaticSetAlignment(StrengthenEquipName, TextAnchor.MiddleCenter)
	_gt.BindName(StrengthenEquipName,"StrengthenEquipName")
	
	local arrow = GUI.ImageCreate( StrengthenEquipName, "arrow", "1801507120",100,0,false,24,30);
    SetAnchorAndPivot(arrow, UIAnchor.Center, UIAroundPivot.Center)	
	
	local level = GUI.CreateStatic(StrengthenEquipName, "level", "10", 135, 0, 300, 50,"system",true)
	GUI.SetColor(level, colorDark);
	GUI.StaticSetFontSize(level, 28);
	GUI.StaticSetAlignment(level, TextAnchor.MiddleCenter)
	
	
	local StrengthenSuccessRate = GUI.CreateStatic(PetEquipStrengthenPage, "StrengthenSuccessRate", "当前强化成功率90%", -15, 120, 600, 35,"system",true)
	GUI.SetColor(StrengthenSuccessRate, colorDark);
	GUI.StaticSetFontSize(StrengthenSuccessRate, 28);
	GUI.StaticSetAlignment(StrengthenSuccessRate, TextAnchor.MiddleCenter)
	_gt.BindName(StrengthenSuccessRate,"StrengthenSuccessRate")
	
	local StrengthenTips = GUI.CreateStatic(PetEquipStrengthenPage, "StrengthenTips", "*失败后，下次强化成功率+2%", 120, 300, 600, 300,"system",true)
	GUI.SetColor(StrengthenTips, colorYellow);
	GUI.StaticSetFontSize(StrengthenTips, 22);
	GUI.StaticSetAlignment(StrengthenTips, TextAnchor.UpperLeft)
	_gt.BindName(StrengthenTips,"StrengthenTips")
	
	
	--右侧
	local StrengthenRightPage = GUI.ImageCreate( PetEquipStrengthenPage, "StrengthenRightPage", "1800400200", 522, 2.66,false,341,455);
    SetAnchorAndPivot(StrengthenRightPage, UIAnchor.Right, UIAroundPivot.Right)

	--当前属性	
	local CutLine = GUI.ImageCreate(StrengthenRightPage,"CutLine", "1801401060", 65, -207,false,192,31.2)
	SetAnchorAndPivot(CutLine, UIAnchor.Center, UIAroundPivot.Center)	
	
	local CutLineText = GUI.CreateStatic(CutLine, "CutLineText", "当前属性加成", 57, 2,300, 50,"system")
	SetAnchorAndPivot(CutLineText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(CutLineText, TextAnchor.MiddleLeft)
	GUI.StaticSetFontSize(CutLineText, fontSizeBtn)	


	local CurStrengthenScroll = GUI.LoopScrollRectCreate(StrengthenRightPage, "CurStrengthenScroll", 0, 38, 336.5, 124,
    "PetEquipRepairUI", "CreateCurAttrItemPool", "PetEquipRepairUI", "RefreshCurAttrScroll", 0, false,
	Vector2.New(336.5, 31), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(CurStrengthenScroll, UILayout.Top);
	_gt.BindName(CurStrengthenScroll, "CurStrengthenScroll");
	
	
	--强化后属性加成
	local CutLine = GUI.ImageCreate(StrengthenRightPage,"CutLine", "1801401060", 65, -48,false,192,31.2)
	SetAnchorAndPivot(CutLine, UIAnchor.Center, UIAroundPivot.Center)	
	
	local CutLineText = GUI.CreateStatic(CutLine, "CutLineText", "强化后属性加成", 57, 2,300, 50,"system")
	SetAnchorAndPivot(CutLineText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(CutLineText, TextAnchor.MiddleLeft)
	GUI.StaticSetFontSize(CutLineText, fontSizeBtn)	
	_gt.BindName(CutLineText,"StrengthenCutLine")


	local PreStrengthenScroll = GUI.LoopScrollRectCreate(StrengthenRightPage, "PreStrengthenScroll", 0, 200, 336.5, 124,
    "PetEquipRepairUI", "CreatePreAttrItemPool", "PetEquipRepairUI", "RefreshPreAttrScroll", 0, false,
	Vector2.New(336.5, 31), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(PreStrengthenScroll, UILayout.Top);
	_gt.BindName(PreStrengthenScroll, "PreStrengthenScroll");
	

	--强化材料
	local CutLine = GUI.ImageCreate(StrengthenRightPage,"CutLine", "1801401060", 65, 116,false,192,31.2)
	SetAnchorAndPivot(CutLine, UIAnchor.Center, UIAroundPivot.Center)	
	
	local CutLineText = GUI.CreateStatic(CutLine, "CutLineText", "强化材料", -40, 2,300, 50,"system")
	SetAnchorAndPivot(CutLineText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(CutLineText, TextAnchor.MiddleCenter)
	GUI.StaticSetFontSize(CutLineText, fontSizeBtn)	
	
	--材料框
	local StrengthenIcon = GUI.ItemCtrlCreate(StrengthenRightPage,"StrengthenIcon1","1800400330",115,180,0,0,false)
	SetAnchorAndPivot(StrengthenIcon, UIAnchor.Center, UIAroundPivot.Center)		
	_gt.BindName(StrengthenIcon,"StrengthenItem1")
	GUI.RegisterUIEvent(StrengthenIcon, UCE.PointerClick , "PetEquipRepairUI", "OnStrengthenItem1Click")
	
	local StrengthenIcon = GUI.ItemCtrlCreate(StrengthenRightPage,"StrengthenIcon2","1800400330",-20,180,0,0,false)
	SetAnchorAndPivot(StrengthenIcon, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(StrengthenIcon,"StrengthenItem2")	
	GUI.RegisterUIEvent(StrengthenIcon, UCE.PointerClick , "PetEquipRepairUI", "OnStrengthenItem2Click")
	
	--保固石勾选框
    local IsSafeToggle = GUI.CheckBoxCreate (StrengthenRightPage,"IsSafeToggle", "1800607150", "1800607151", 87.5, -25,Transition.ColorTint, PetEquipRepairUI.IsSafe == 1)
	SetAnchorAndPivot(IsSafeToggle, UIAnchor.BottomRight , UIAroundPivot.BottomRight)
	GUI.RegisterUIEvent(IsSafeToggle, UCE.PointerClick , "PetEquipRepairUI", "OnIsSafeClick")
	-- _gt.BindName(UnBindToggle,"UnBindToggle")	

	--强化按钮
	local StrengthenBth = GUI.ButtonCreate(PetEquipStrengthenPage,"StrengthenBth","1800402080",520,288,Transition.ColorTint, "")
	SetAnchorAndPivot(StrengthenBth, UIAnchor.BottomRight , UIAroundPivot.BottomRight )
	GUI.RegisterUIEvent(StrengthenBth, UCE.PointerClick, "PetEquipRepairUI", "OnStrengthenBthClick")
	local StrengthenBthTxt =GUI.CreateStatic(StrengthenBth,"StrengthenBthTxt","强  化",0,0,400,200)
	SetAnchorAndPivot(StrengthenBthTxt, UIAnchor.Center , UIAroundPivot.Center )
	GUI.StaticSetFontSize(StrengthenBthTxt, fontSizeBtn)
	GUI.StaticSetAlignment(StrengthenBthTxt, TextAnchor.MiddleCenter)
	GUI.SetIsOutLine(StrengthenBthTxt, true)
	GUI.SetOutLine_Color(StrengthenBthTxt, colorOutline)
	GUI.SetOutLine_Distance(StrengthenBthTxt, 1)
	
    local UnBindToggle = GUI.CheckBoxCreate (PetEquipStrengthenPage,"UnBindToggle", "1800607150", "1800607151", -190, 265,Transition.ColorTint, PetEquipRepairUI.UnBind == 1)
	SetAnchorAndPivot(UnBindToggle, UIAnchor.BottomRight , UIAroundPivot.BottomRight)
	GUI.RegisterUIEvent(UnBindToggle, UCE.PointerClick , "PetEquipRepairUI", "OnUnBindClick")
	_gt.BindName(UnBindToggle,"UnBindToggle")
	
	local UnBindToggleText = GUI.CreateStatic(PetEquipStrengthenPage, "UnBindToggleText", "优先使用非绑定材料", 250, 285, 600, 35,"system",true)
	SetAnchorAndPivot(UnBindToggleText, UIAnchor.BottomRight , UIAroundPivot.BottomRight)
	GUI.SetColor(UnBindToggleText, colorDark);
	GUI.StaticSetFontSize(UnBindToggleText, 26);
	GUI.StaticSetAlignment(UnBindToggleText, TextAnchor.MiddleCenter)
	
	--消耗
	local MoneyCost = GUI.CreateStatic(PetEquipStrengthenPage, "MoneyCost", "消耗", 90, 292.6, 200, 50)
	SetAnchorAndPivot(MoneyCost, UIAnchor.BottomLeft , UIAroundPivot.BottomLeft );
	GUI.SetColor(MoneyCost, colorDark);
	GUI.StaticSetFontSize(MoneyCost, 26)
	
	local MoneyCostBg = GUI.ImageCreate(MoneyCost, "MoneyCostBg", "1800700010", 60, 8, false, 180, 36)
		
	local MoneyCostIcon = GUI.ImageCreate(MoneyCostBg, "MoneyCostIcon", "1800408280", 0, 1, false, 36, 36)
	SetAnchorAndPivot(MoneyCostIcon, UIAnchor.Left , UIAroundPivot.Left )
	_gt.BindName(MoneyCostIcon,"MoneyCostIcon")

	local MoneyCostText = GUI.CreateStatic(MoneyCostBg, "StrengthenMoneyCost", "0", -10, 1, 200, 35,"system",true)
	GUI.SetColor(MoneyCostText, UIDefine.White2Color);
	GUI.StaticSetFontSize(MoneyCostText, 22);
	GUI.StaticSetAlignment(MoneyCostText, TextAnchor.MiddleCenter)
	_gt.BindName(MoneyCostText, "StrengthenMoneyCost")	

--anniu
	local Btn = _gt.GetUI("tempBtn1")
	if not Btn then
		local btnWidth = 145
		local btnHeight = 45
		for i = 1, #tabBtns do
			local tempBtn = GUI.ButtonCreate( panelBg, tabBtns[i][2], "1800402030", 80 + (i - 1) * btnWidth, 55, Transition.None, "", btnWidth, btnHeight, false)
			SetAnchorAndPivot(tempBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
			tabBtns[i].guid = GUI.GetGuid(tempBtn)
			_gt.BindName(tempBtn,"tempBtn"..i)
				
			local btnSprite = GUI.ImageCreate( tempBtn, "btnSprite", "1800402032", 0, 0, false, btnWidth, btnHeight)
			SetAnchorAndPivot(btnSprite, UIAnchor.Center, UIAroundPivot.Center)
			GUI.SetVisible(btnSprite, false)

			local labelTxt = GUI.CreateStatic( tempBtn, tabBtns[i][2] .. "label", tabBtns[i][1], 0, 0, btnWidth, btnHeight, "system", true, false)
			SetAnchorAndPivot(labelTxt, UIAnchor.Center, UIAroundPivot.Center)
			GUI.StaticSetFontSize(labelTxt, 22)
			GUI.StaticSetAlignment(labelTxt, TextAnchor.MiddleCenter)
			GUI.SetColor(labelTxt, colorDark)

			GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "PetEquipRepairUI", "OnTabBtnClick")
		end
	end	
	
	return PetEquipStrengthenPage

end




function PetEquipRepairUI.CreatePetEquipLeftPage()
	local PetEquipLeftBg = _gt.GetUI("PetEquipLeftBg")
	if PetEquipLeftBg then
		return
	else
	local panelBg = _gt.GetUI("panelBg")
	local PetEquipLeftBg = GUI.ImageCreate(panelBg, "PetEquipLeftBg", "1800400200", 80, 105, false, 290, 506);
	_gt.BindName(PetEquipLeftBg,"PetEquipLeftBg")
	SetAnchorAndPivot(PetEquipLeftBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)		
	local PetEquipLeftScroll = GUI.LoopScrollRectCreate(PetEquipLeftBg, "PetEquipLeftScroll", 0, 5, 290, 500,
    "PetEquipRepairUI", "CreatePetEquipItem", "PetEquipRepairUI", "RefreshPetEquipItem", 0, false,
    Vector2.New(280, 100), 1, UIAroundPivot.Top, UIAnchor.Top)
	_gt.BindName(PetEquipLeftScroll, "PetEquipLeftScroll")
	
	local TipsWithoutEquip = GUI.GroupCreate(PetEquipLeftBg, "TipsWithoutEquip", 0, 0, 0, 0)
	_gt.BindName(TipsWithoutEquip, "TipsWithoutEquip")
	GUI.SetVisible(TipsWithoutEquip,false)
	
	local Img = GUI.ImageCreate(TipsWithoutEquip, "Img", "1800608770", 150, 380, false, 330,275)
	GUI.SetEulerAngles(Img, Vector3.New(-180, 0, -180))
	SetAnchorAndPivot(Img, UIAnchor.Center, UIAroundPivot.Center)	
	
	local TxtBg = GUI.ImageCreate(TipsWithoutEquip, "TxtBg", "1800601250",150,200,false, 240,100)
	GUI.SetEulerAngles(TxtBg, Vector3.New(-180, 0, -180))
	SetAnchorAndPivot(TxtBg, UIAnchor.Center, UIAroundPivot.Center)	
	
	local Txt = GUI.CreateStatic(TxtBg, "Txt", "少侠,您还没有装备呦~", 0,-12,230,50)
	GUI.StaticSetAlignment(Txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(Txt, UIDefine.FontSizeM)
    GUI.SetColor(Txt, UIDefine.BrownColor)

	
	end
end

local PetEquipList = {}
local itemGUID = nil
local PetEquipGuidInBag = {}
local TempEquipAttrNow ={}
local TempEquipAttr ={}
function PetEquipRepairUI.RefreshPetEquipLeftPage()
	PetEquipGuidInBag = {}
	PetEquipList = {}
	TempEquipAttrNow ={}
	TempEquipAttr ={}
	EquipAttrNow ={}
	EquipAttr ={}
	TempPetGuidList = {}
	if CurSelectPage == 1 then
		--强化
		if CurSelectSubPage == 1 then
			if CurSelectLeftPage == 1 then
				for i = 0 , PetUI.petGuidList.Count - 1 do
					local petGuid = PetUI.petGuidList[i]
					local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, petGuid)
					local moban =DB.GetOncePetByKey1(id)
					for j = 1, #equipSiteData-1 do
						local equipData=LD.GetItemDataByIndex(equipSiteData[j].site,item_container_type.item_container_pet_equip,petGuid)
						if equipData then
							local itemGUID = equipData:GetAttr(ItemAttr_Native.Guid)
							-- local EquipDurableVal = LD.GetItemIntCustomAttrByGuid("EquipDurableVal",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid))) 
							-- local EquipDurableMax = LD.GetItemIntCustomAttrByGuid("EquipDurableMax",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid)))
							PetEquipList[#PetEquipList + 1] = {equipData,0,0,moban,petGuid}
							table.insert(TempPetGuidList,petGuid)
						end
					end
				end
			elseif CurSelectLeftPage == 2 then
				local Type=1;
				local SubType=7;
				local Subtype2=1;
				local site = 2
				local count = LD.GetItemCount()
				for i = 0 , count - 1 do
					local itemGuid = LD.GetItemGuidByItemIndex(i)
					local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
					local itemDB = DB.GetOnceItemByKey1(itemId)
					local equipData = LD.GetItemDataByGuid(itemGuid,item_container_type.item_container_bag)
					for j=1 , 3 do
						if itemDB.Type==Type and itemDB.Subtype==SubType and itemDB.Subtype2== j then
							local itemGUID = equipData:GetAttr(ItemAttr_Native.Guid)
							-- local EquipDurableVal = LD.GetItemIntCustomAttrByGuid("EquipDurableVal",itemGUID,item_container_type.item_container_bag) 
							-- local EquipDurableMax = LD.GetItemIntCustomAttrByGuid("EquipDurableMax",itemGUID,item_container_type.item_container_bag)
							PetEquipList[#PetEquipList + 1] = {equipData,0,0}
							if PetEquipRepairUI.JumpState == 1 then
							table.insert(PetEquipGuidInBag,tostring(itemGUID))
							-- CDebug.LogError(tostring(itemGUID))
							end
						end
					end
				end
			end	
		elseif CurSelectSubPage == 2 then
			--修理
			if CurSelectLeftPage == 1 then
				for i = 0 , PetUI.petGuidList.Count - 1 do
					local petGuid = PetUI.petGuidList[i]
					local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, petGuid)
					local moban =DB.GetOncePetByKey1(id)
					for j = 1, #equipSiteData do
						local equipData=LD.GetItemDataByIndex(equipSiteData[j].site,item_container_type.item_container_pet_equip,petGuid)
						if equipData then
							local itemGUID = equipData:GetAttr(ItemAttr_Native.Guid)
							local EquipDurableVal = LD.GetItemIntCustomAttrByGuid("EquipDurableVal",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid))) 
							local EquipDurableMax = LD.GetItemIntCustomAttrByGuid("EquipDurableMax",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid)))
							PetEquipList[#PetEquipList + 1] = {equipData,EquipDurableVal,EquipDurableMax,moban,petGuid}
							table.insert(TempPetGuidList,petGuid)
						end
					end
				end
			elseif CurSelectLeftPage == 2 then
				local Type=1;
				local SubType=7;
				local Subtype2=1;
				local site = 2
				local count = LD.GetItemCount()
				for i = 0 , count - 1 do
					local itemGuid = LD.GetItemGuidByItemIndex(i)
					local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
					local itemDB = DB.GetOnceItemByKey1(itemId)
					local equipData = LD.GetItemDataByGuid(itemGuid,item_container_type.item_container_bag)
					for j=1 , 4 do
						if itemDB.Type==Type and itemDB.Subtype==SubType and itemDB.Subtype2== j then
							local itemGUID = equipData:GetAttr(ItemAttr_Native.Guid)
							local EquipDurableVal = LD.GetItemIntCustomAttrByGuid("EquipDurableVal",itemGUID,item_container_type.item_container_bag) 
							local EquipDurableMax = LD.GetItemIntCustomAttrByGuid("EquipDurableMax",itemGUID,item_container_type.item_container_bag)
							PetEquipList[#PetEquipList + 1] = {equipData,EquipDurableVal,EquipDurableMax}
							if PetEquipRepairUI.JumpState == 1 then
							table.insert(PetEquipGuidInBag,tostring(itemGUID))
							-- CDebug.LogError(tostring(itemGUID))
							end
						end
					end
				end
			end
		end
		--
	elseif CurSelectPage == 2 then
		if CurSelectLeftPage == 1 then
			for i = 0 , PetUI.petGuidList.Count - 1 do
				local petGuid = PetUI.petGuidList[i]
				local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, petGuid)
				local moban =DB.GetOncePetByKey1(id)
				for j = 1, #equipSiteData do
					local equipData=LD.GetItemDataByIndex(equipSiteData[j].site,item_container_type.item_container_pet_equip,petGuid)
					if equipData then
						local itemGUID = equipData:GetAttr(ItemAttr_Native.Guid)
						local EquipDurableVal = LD.GetItemIntCustomAttrByGuid("PetEquipArtifice_NowArtificeNum",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid))) 
						local EquipDurableMax = LD.GetItemIntCustomAttrByGuid("PetEquipArtifice_MaxArtificeNum",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid)))
						PetEquipList[#PetEquipList + 1] = {equipData,EquipDurableVal,EquipDurableMax,moban,petGuid}
						table.insert(TempPetGuidList,petGuid)
						
						local NowAttrStr = LD.GetItemStrCustomAttrByGuid ("PetEquipArtifice_NowAttrTb",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid))) 
						if NowAttrStr ~= "" then
						
						-- local inspect = require("inspect")
						-- CDebug.LogError(inspect(loadstring("return"..NowAttrStr)()))

						table.insert(TempEquipAttrNow,loadstring("return"..NowAttrStr)())
						else
						table.insert(TempEquipAttrNow,{})
						end
						local AttrStr = LD.GetItemStrCustomAttrByGuid ("PetEquipArtifice_SaveAttrTb",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid))) 
						if AttrStr ~= "" then
						EquipAttr = loadstring("return"..AttrStr)()
						table.insert(TempEquipAttr,loadstring("return"..AttrStr)())
						else
						table.insert(TempEquipAttr,{})
						end	
					end
				end
			end
		elseif CurSelectLeftPage == 2 then
			local Type=1;
			local SubType=7;
			local Subtype2=1;
			local site = 2
			local count = LD.GetItemCount()
			for i = 0 , count - 1 do
				local itemGuid = LD.GetItemGuidByItemIndex(i)
				local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
				local itemDB = DB.GetOnceItemByKey1(itemId)
				local equipData = LD.GetItemDataByGuid(itemGuid,item_container_type.item_container_bag)
				for j=1 , 4 do
					if itemDB.Type==Type and itemDB.Subtype==SubType and itemDB.Subtype2== j then
						local itemGUID = equipData:GetAttr(ItemAttr_Native.Guid)
						local EquipDurableVal = LD.GetItemIntCustomAttrByGuid("PetEquipArtifice_NowArtificeNum",itemGUID,item_container_type.item_container_bag) 
						local EquipDurableMax = LD.GetItemIntCustomAttrByGuid("PetEquipArtifice_MaxArtificeNum",itemGUID,item_container_type.item_container_bag)
						PetEquipList[#PetEquipList + 1] = {equipData,EquipDurableVal,EquipDurableMax}
						
						local NowAttrStr = LD.GetItemStrCustomAttrByGuid ("PetEquipArtifice_NowAttrTb",itemGUID,item_container_type.item_container_bag) 
						if NowAttrStr ~= "" then
						table.insert(TempEquipAttrNow,loadstring("return"..NowAttrStr)())
						else
						table.insert(TempEquipAttrNow,{})
						end
						local AttrStr = LD.GetItemStrCustomAttrByGuid ("PetEquipArtifice_SaveAttrTb",itemGUID,item_container_type.item_container_bag) 
						if AttrStr ~= "" then
						EquipAttr = loadstring("return"..AttrStr)()
						table.insert(TempEquipAttr,loadstring("return"..AttrStr)())
						else
						table.insert(TempEquipAttr,{})
						end
						
						if PetEquipRepairUI.JumpState == 1 then
						table.insert(PetEquipGuidInBag,tostring(itemGUID))
						end

					end
				end
			end
		end	
	end
	
	
	if PetEquipRepairUI.JumpState == 1 then
		if PetEquipRepairUI.SelectedGuid then
			-- CDebug.LogError(#PetEquipGuidInBag)
			for i =1 , #PetEquipGuidInBag do
				if PetEquipGuidInBag[i] == PetEquipRepairUI.SelectedGuid then
					CurSelectPetEquipIndex = i 
					-- CDebug.LogError("aaa"..CurSelectPetEquipIndex)
				end		
			end
		end 
	end
	local CurEquipNum = tonumber(#PetEquipList)
	local PetEquipLeftScroll = _gt.GetUI("PetEquipLeftScroll")
	GUI.LoopScrollRectSetTotalCount(PetEquipLeftScroll, CurEquipNum)  
	GUI.LoopScrollRectRefreshCells(PetEquipLeftScroll)
	

	if  CurEquipNum == 0 then
		if CurSelectPage ==1 then
			PetEquipRepairUI.RefreshPetEquipRepairPage()
		elseif CurSelectPage ==2 then
			PetEquipRepairUI.RefreshPetEquipClearPage()
			--洗炼后属性显示
			PetEquipRepairUI.RefreshClearAttr()
			--当前属性显示
			PetEquipRepairUI.RefreshClearAttrNow()
		end	
	end
	
	if PetEquipRepairUI.JumpState ==1 then
		GUI.ScrollRectSetNormalizedPosition(PetEquipLeftScroll,Vector2.New(0,(CurSelectPetEquipIndex/CurEquipNum)-0.1))
		PetEquipRepairUI.JumpState = 0
	end
	--显示立绘
	local TipsWithoutEquip = _gt.GetUI("TipsWithoutEquip")
	GUI.SetVisible(TipsWithoutEquip,CurEquipNum ==0)
	--洗炼石无宠物时不显示
	if CurSelectPage == 2 then
		local ItemIcon = _gt.GetUI("ItemIcon")
		GUI.SetVisible(ItemIcon, CurEquipNum ~=0)
	end
end


function PetEquipRepairUI.CreatePetEquipItem()
    local PetEquipLeftScroll = _gt.GetUI("PetEquipLeftScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(PetEquipLeftScroll)
    local PetEquipLeftBtn = GUI.CheckBoxExCreate(PetEquipLeftScroll, "PetEquipLeftBtn" .. curCount, "1800700030", "1800700040", 0, 0, false, 0, 0)
    local PetEquipLeft_Icon_Bg = GUI.ImageCreate(PetEquipLeftBtn, "PetEquipLeft_Icon_Bg", "1800400050", 10, 10, false, 80, 81);
    local PetEquipLeft_Icon = GUI.ItemCtrlCreate(PetEquipLeft_Icon_Bg, "PetEquipLeft_Icon", "1900000000", 0, 0,80,81)
	local PetEquipLeft_PetIcon = GUI.ItemCtrlCreate(PetEquipLeftBtn, "PetEquipLeft_PetIcon", "", 200, 100,10,10)

    SetAnchorAndPivot(PetEquipLeft_Icon, UIAnchor.Center, UIAroundPivot.Center)
    local PetEquipLeft_Name = GUI.CreateStatic(PetEquipLeftBtn, "PetEquipLeft_Name", "", 105, -20, 100, 30, "system", true);
    SetAnchorAndPivot(PetEquipLeft_Name, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(PetEquipLeft_Name, colorDark)
    GUI.StaticSetFontSize(PetEquipLeft_Name, fontSizeBigger)

    local PetEquipLeft_Level = GUI.CreateStatic(PetEquipLeftBtn, "PetEquipLeft_Level", "+0", 203, -20, 300, 50, "system", true);
    SetAnchorAndPivot(PetEquipLeft_Level, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(PetEquipLeft_Level, UIDefine.BlueColor)
    GUI.StaticSetFontSize(PetEquipLeft_Level, fontSizeSmaller)
	GUI.StaticSetAlignment(PetEquipLeft_Level,TextAnchor.MiddleLeft)
	GUI.SetVisible(PetEquipLeft_Level,false)
	
	--使用者头像
	local UserIcon = GUI.ImageCreate(PetEquipLeftBtn, "UserIcon", "1900000000", 240, 15, false, 26, 26)
	GUI.SetVisible(UserIcon,false)


    local PetEquipLeft_Durable = GUI.CreateStatic(PetEquipLeftBtn, "PetEquipLeft_Durable", "", 105, 15, 300, 50, "system", true);
    SetAnchorAndPivot(PetEquipLeft_Durable, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(PetEquipLeft_Durable, colorYellow)
    GUI.StaticSetFontSize(PetEquipLeft_Durable, fontSizeDefault)
	GUI.StaticSetAlignment (PetEquipLeft_Durable,TextAnchor.MiddleLeft)
	
	
    GUI.RegisterUIEvent(PetEquipLeftBtn, UCE.PointerClick, "PetEquipRepairUI", "OnSelectEquip")

	
    return PetEquipLeftBtn;

end

function PetEquipRepairUI.RefreshPetEquipItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    index = tonumber(parameter[2]) + 1
    IndexPetEquipItemGuid[index] = guid
	local equipData = PetEquipList[index][1]
    local PetEquipLeftBtn = GUI.GetByGuid(guid)
	local itemId = equipData:GetAttr(ItemAttr_Native.Id)
    GUI.SetData(PetEquipLeftBtn, "equipId", itemId) 
    local PetEquipLeft_Icon_Bg = GUI.GetChild(PetEquipLeftBtn, "PetEquipLeft_Icon_Bg")
    local PetEquipLeft_Icon = GUI.GetChild(PetEquipLeft_Icon_Bg, "PetEquipLeft_Icon")
    local itemDB = DB.GetOnceItemByKey1(tonumber(itemId))
	GUI.ItemCtrlSetElementValue(PetEquipLeft_Icon,eItemIconElement.Icon,tostring(itemDB.Icon))
	GUI.ItemCtrlSetElementValue(PetEquipLeft_Icon,eItemIconElement.Border,UIDefine.ItemIconBg[itemDB.Grade])
	GUI.ItemCtrlSetElementValue(PetEquipLeft_Icon,eItemIconElement.LeftBottomSp,"1801208350")
	GUI.ItemCtrlSetElementRect(PetEquipLeft_Icon,eItemIconElement.LeftBottomSp,5,7,37,37)

	if tonumber(equipData:GetAttr(ItemAttr_Native.IsBound)) == 1 then
	GUI.ItemCtrlSetElementValue(PetEquipLeft_Icon,eItemIconElement.LeftTopSp,"1800707120")
	else
	GUI.ItemCtrlSetElementValue(PetEquipLeft_Icon,eItemIconElement.LeftTopSp,nil)
	end

    local PetEquipLeft_Name = GUI.GetChild(PetEquipLeftBtn, "PetEquipLeft_Name")
    GUI.StaticSetText(PetEquipLeft_Name, itemDB.Name)  
	
	local UserIcon = GUI.GetChild(PetEquipLeftBtn, "UserIcon")
	
	if CurSelectLeftPage == 1 then
		local moban = PetEquipList[index][4]
		local PetEquipLeft_PetIcon = GUI.GetChild(PetEquipLeftBtn, "PetEquipLeft_PetIcon")
		GUI.ItemCtrlSetElementValue(PetEquipLeft_PetIcon,eItemIconElement.Icon,tostring(moban.Head))
		
		GUI.SetVisible(UserIcon,true)
		local TempPetGuid = tostring(TempPetGuidList[index])
		local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,TempPetGuid)))
		local petDB =DB.GetOncePetByKey1(petId)
		GUI.ImageSetImageID(UserIcon,tostring(petDB.Head))
	else
		GUI.SetVisible(UserIcon,false)
	end

	
	local EquipDurableVal = PetEquipList[index][2]
	local EquipDurableMax = PetEquipList[index][3]
	local PetEquipLeft_Durable = GUI.GetChild(PetEquipLeftBtn, "PetEquipLeft_Durable")
	if CurSelectPage == 1 then
		if CurSelectSubPage == 1 then	
			GUI.StaticSetText(PetEquipLeft_Durable,itemDB.Level.."级"..itemDB.ShowType)
		elseif CurSelectSubPage == 2 then
			GUI.StaticSetText(PetEquipLeft_Durable,"耐久度: "..EquipDurableVal.. "/" ..EquipDurableMax)
		end
	elseif CurSelectPage == 2 then
		if EquipDurableMax == -1 then
			GUI.StaticSetText(PetEquipLeft_Durable,"洗炼次数: 无限")
		else
			GUI.StaticSetText(PetEquipLeft_Durable,"洗炼次数: "..EquipDurableVal.. "/" ..EquipDurableMax)
		end
	end

	--强化等级的显示
	local PetEquipLeft_Level = GUI.GetChild(PetEquipLeftBtn, "PetEquipLeft_Level")	
	if equipData ~= nil and CurSelectPage ==1 and CurSelectSubPage == 1 then
		local ulongVal = equipData:GetIntCustomAttr(LogicDefine.EnhanceLv)
		local enhanceLv, h = int64.longtonum2(ulongVal)
		GUI.StaticSetText(PetEquipLeft_Level,"+"..enhanceLv)
		GUI.SetVisible(PetEquipLeft_Level,true)
	else
		GUI.SetVisible(PetEquipLeft_Level,false)
	end


	if CurSelectPetEquipIndex == index then
		-- CDebug.LogError(CurSelectPetEquipIndex)
		GUI.CheckBoxExSetCheck(PetEquipLeftBtn, true)
		PetEquipRepairUI.OnSelectEquip(guid, true)
	else
		GUI.CheckBoxExSetCheck(PetEquipLeftBtn, false)
	end


end


--强化页当前属性格子
function PetEquipRepairUI.CreateCurAttrItemPool()
	local CurStrengthenScroll = GUI.GetByGuid(_gt.CurStrengthenScroll);
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(CurStrengthenScroll)
	local CurStrengthenAttr	= GUI.ImageCreate(CurStrengthenScroll,"CurStrengthenAttr"..curCount, "1801200070", 0,0,false,336.5,31)
	SetAnchorAndPivot(CurStrengthenAttr, UIAnchor.Center, UIAroundPivot.Center)	
	--当前属性名称
	local CurAttrName = GUI.CreateStatic(CurStrengthenAttr, "CurAttrName", "", -10, 0,300, 50,"system")
	SetAnchorAndPivot(CurAttrName, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(CurAttrName,colorDark)
	GUI.StaticSetAlignment(CurAttrName, TextAnchor.MiddleLeft)
	GUI.StaticSetFontSize(CurAttrName, 22)	
	
	--当前基础属性
	local CurBaseAttr = GUI.CreateStatic(CurStrengthenAttr, "CurBaseAttr", "", 110, 0,300, 50,"system")
	SetAnchorAndPivot(CurBaseAttr, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(CurBaseAttr,UIDefine.Green8Color)
	GUI.StaticSetAlignment(CurBaseAttr, TextAnchor.MiddleLeft)
	GUI.StaticSetFontSize(CurBaseAttr, 22)	
	-- _gt.BindName(CurBaseAttr,"CurBaseAttr")
	
	--当前属性加成
	local CurAddAttr = GUI.CreateStatic(CurStrengthenAttr, "CurAddAttr", "", 200, 0,300, 50,"system")
	SetAnchorAndPivot(CurAddAttr, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(CurAddAttr,UIDefine.Green8Color)
	GUI.StaticSetAlignment(CurAddAttr, TextAnchor.MiddleLeft)
	GUI.StaticSetFontSize(CurAddAttr, 22)	
	-- _gt.BindName(CurAddAttr,"CurAddAttr")
	return CurStrengthenAttr
end


--刷新当前强化属性
function PetEquipRepairUI.RefreshCurAttrScroll(parameter)
	parameter = string.split(parameter, "#")
	local guid = parameter[1]
	local index = tonumber(parameter[2])
	local CurStrengthenAttr = GUI.GetByGuid(guid)
	local Name = GUI.GetChild(CurStrengthenAttr, "CurAttrName")
	local BaseAttr = GUI.GetChild(CurStrengthenAttr, "CurBaseAttr")
	local AddAttr = GUI.GetChild(CurStrengthenAttr,"CurAddAttr")	
	
	-- equipData = PetEquipList[CurSelectPetEquipIndex][1]
	GUI.SetVisible(Name,false)
	GUI.SetVisible(BaseAttr,false)
	GUI.SetVisible(AddAttr,false)	
	
	if PetEquipRepairUI.ResetCurScroll ~= 1 then
		if equipData ~= nil then
			local t = {}
			LogicDefine.GetItemDynAttrDataByMark(equipData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)	
			
			index = index + 1
			if index <= #t then
				GUI.SetVisible(Name,true)
				GUI.SetVisible(BaseAttr,true)
				GUI.SetVisible(AddAttr,true)
				GUI.StaticSetText(Name,t[index].name)
									
									--当前属性值
				GUI.StaticSetText(BaseAttr,tostring(t[index].value))

									--当前属性加成
				GUI.StaticSetText(AddAttr,"+"..tostring(t[index].exV))		
			end
		end
	end


end

--强化页预览属性格子
function PetEquipRepairUI.CreatePreAttrItemPool()
	local PreStrengthenScroll = GUI.GetByGuid(_gt.PreStrengthenScroll);
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(PreStrengthenScroll)
	local PreStrengthenAttr	= GUI.ImageCreate(PreStrengthenScroll,"PreStrengthenAttr"..curCount, "1801200070", 0,0,false,336.5,31)
	SetAnchorAndPivot(PreStrengthenAttr, UIAnchor.Center, UIAroundPivot.Center)	
	--预览属性名称
	local PreAttrName = GUI.CreateStatic(PreStrengthenAttr, "PreAttrName", "", -10, 0,300, 50,"system")
	SetAnchorAndPivot(PreAttrName, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PreAttrName,colorDark)
	GUI.StaticSetAlignment(PreAttrName, TextAnchor.MiddleLeft)
	GUI.StaticSetFontSize(PreAttrName, 22)	
	
	--预览基础属性
	local PreBaseAttr = GUI.CreateStatic(PreStrengthenAttr, "PreBaseAttr", "", 110, 0,300, 50,"system")
	SetAnchorAndPivot(PreBaseAttr, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PreBaseAttr,UIDefine.Green8Color)
	GUI.StaticSetAlignment(PreBaseAttr, TextAnchor.MiddleLeft)
	GUI.StaticSetFontSize(PreBaseAttr, 22)	
	
	--预览属性加成
	local PreAddAttr = GUI.CreateStatic(PreStrengthenAttr, "PreAddAttr", "", 200, 0,300, 50,"system")
	SetAnchorAndPivot(PreAddAttr, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PreAddAttr,UIDefine.Green8Color)
	GUI.StaticSetAlignment(PreAddAttr, TextAnchor.MiddleLeft)
	GUI.StaticSetFontSize(PreAddAttr, 22)	
	
	local arrow =  GUI.ImageCreate(PreStrengthenAttr,"arrow", "", 120,0,true,22,20)
	SetAnchorAndPivot(PreStrengthenAttr, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetVisible(arrow,false)
	
	return PreStrengthenAttr
end


--刷新预览强化属性
function PetEquipRepairUI.RefreshPreAttrScroll(parameter)
	parameter = string.split(parameter, "#")
	local guid = parameter[1]
	local index = tonumber(parameter[2])
	local PreStrengthenAttr = GUI.GetByGuid(guid)
	local Name = GUI.GetChild(PreStrengthenAttr, "PreAttrName")
	local BaseAttr = GUI.GetChild(PreStrengthenAttr, "PreBaseAttr")
	local AddAttr = GUI.GetChild(PreStrengthenAttr,"PreAddAttr")	
	local arrow = GUI.GetChild(PreStrengthenAttr,"arrow")
	-- equipData = PetEquipList[CurSelectPetEquipIndex][1]
	GUI.SetVisible(Name,false)
	GUI.SetVisible(BaseAttr,false)
	GUI.SetVisible(AddAttr,false)	
	GUI.SetVisible(arrow,false)
	
	if PetEquipRepairUI.ResetPreScroll ~= 1 then
		if equipData ~= nil then
			local t = {}
			LogicDefine.GetItemDynAttrDataByMark(equipData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)	
			
			index = index + 1
			if index <= #t then
				local itemId = equipData:GetAttr(ItemAttr_Native.Id)
				local itemDB = DB.GetOnceItemByKey1(tonumber(itemId))
				local ulongVal = equipData:GetIntCustomAttr(LogicDefine.EnhanceLv)
				local enhanceLv, h = int64.longtonum2(ulongVal)
				
				local LevelCoef = PetEquipRepairUI.StrengthenConfig["LevelCoef"][itemDB.Level]
				local parameter1 = 0
				if LevelCoef ~= nil then
					parameter1 = assert(loadstring("local IntensifyLevel = "..tonumber(enhanceLv+1).." return "..LevelCoef))()
				end
				local parameter2 = PetEquipRepairUI.StrengthenConfig["GradeCoef"][itemDB.Grade]
				local parameter4 = PetEquipRepairUI.StrengthenConfig["PositionCoef"][itemDB.ShowType]
				local parameter3 = PetEquipRepairUI.StrengthenConfig["AttrCoef"][t[index].keyname]
				local AttrVal = PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv+1]["AttrVal"]
				local PromoteVal = math.floor(assert(loadstring("local LevelCoef = "..parameter1.." local GradeCoef = "..parameter2.." local AttrCoef = "..parameter3.." local PositionCoef = "..parameter4.." return "..AttrVal))())
				
				GUI.StaticSetText(AddAttr,"+"..tostring(tonumber(PromoteVal)))
								
				GUI.StaticSetText(Name,t[index].name)
								
				GUI.StaticSetText(BaseAttr,tostring(t[index].value))
								
				
				GUI.SetVisible(Name,true)
				GUI.SetVisible(BaseAttr,true)
				GUI.SetVisible(AddAttr,true)
				GUI.SetVisible(arrow,true)
					
			end
		end
	end


end


function PetEquipRepairUI.OnSelectEquip(guid, forceRefresh)
	local PetEquipLeftBtn = GUI.GetByGuid(guid)
	local index = GUI.CheckBoxExGetIndex(PetEquipLeftBtn)
    index = index + 1
	data.index =index
	if not forceRefresh and index == CurSelectPetEquipIndex then
    GUI.CheckBoxExSetCheck(PetEquipLeftBtn, true)
		test(12123)
        return
    end
    if CurSelectPetEquipIndex ~= index then
        local lastbtn = GUI.GetByGuid(IndexPetEquipItemGuid[CurSelectPetEquipIndex])
        GUI.CheckBoxExSetCheck(lastbtn, false)
    end
	CurSelectPetEquipIndex = index
	
	equipData = PetEquipList[index][1]
	itemGUID=equipData:GetAttr(ItemAttr_Native.Guid)
	
	local itemId = equipData:GetAttr(ItemAttr_Native.Id)
	local itemDB = DB.GetOnceItemByKey1(tonumber(itemId))
	
	
	
	if CurSelectPage == 1 then
		--强化
		if CurSelectSubPage == 1 then
			
			if equipData ~= nil then
				
				--强化等级
				local ulongVal = equipData:GetIntCustomAttr(LogicDefine.EnhanceLv)
				local enhanceLv, h = int64.longtonum2(ulongVal)
				-- local StrengthenLevel = _gt.GetUI("StrengthenLevel")
				-- GUI.SetVisible(StrengthenLevel,true)
				--当装备未达到强化等级时
				if enhanceLv < PetEquipRepairUI.StrengthenConfig["MaxIntensifyLevel"] then
					local Config = PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv+1]
					
					local t = {}
					LogicDefine.GetItemDynAttrDataByMark(equipData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)	
					
					local StrengthenCutLine = _gt.GetUI("StrengthenCutLine")
					GUI.StaticSetText(StrengthenCutLine,"强化后属性加成")
					

					if #t > 0 then
						--刷新属性显示
						PetEquipRepairUI.ResetCurScroll = 0
						local CurStrengthenScroll = _gt.GetUI("CurStrengthenScroll")
						GUI.LoopScrollRectSetTotalCount(CurStrengthenScroll, math.max(#t,4))
						GUI.LoopScrollRectRefreshCells(CurStrengthenScroll)
						
						PetEquipRepairUI.ResetPreScroll = 0
						local PreStrengthenScroll = _gt.GetUI("PreStrengthenScroll")
						GUI.LoopScrollRectSetTotalCount(PreStrengthenScroll, math.max(#t,4))
						GUI.LoopScrollRectRefreshCells(PreStrengthenScroll)
					end
					
					--装备基础信息显示
					--装备图标
					local Icon = _gt.GetUI("StrengthenEquip")
					GUI.SetVisible(Icon,true)
					GUI.ImageSetImageID(Icon,tostring(itemDB.Icon))
					--装备名称
					local Name = _gt.GetUI("StrengthenEquipName")
					GUI.StaticSetText(Name,itemDB.Name.." +"..tostring(enhanceLv))
					GUI.SetPositionX(Name,-50)
					 
					local arrow = GUI.GetChild(Name,"arrow")
					GUI.SetVisible(arrow,true)
					local level = GUI.GetChild(Name,"level")
					GUI.SetVisible(level,true)
					GUI.StaticSetText(level," +"..tostring(tonumber(enhanceLv)+1))
					
					--强化成功率
					local Rate = _gt.GetUI("StrengthenSuccessRate")
					local luck = equipData:GetIntCustomAttr("EQUIP_LuckAddition")/100
					local RateVal = tonumber((Config["Success"]/10000)*100+luck)
					
					if RateVal >50 and RateVal <= 80 then
					GUI.StaticSetText(Rate,"当前强化成功率 <color=#42B1F0ff>"..RateVal.."%</color>")
					elseif RateVal >80 and RateVal <= 100 then
					GUI.StaticSetText(Rate,"当前强化成功率 <color=#46DC5Fff>"..RateVal.."%</color>")
					else
					GUI.StaticSetText(Rate,"当前强化成功率 <color=#FF0000ff>"..RateVal.."%</color>")
					end
				else				
					local t = {}
					LogicDefine.GetItemDynAttrDataByMark(equipData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)	
					
					local StrengthenCutLine = _gt.GetUI("StrengthenCutLine")
					GUI.StaticSetText(StrengthenCutLine,"已达到强化等级上限")									

					if #t > 0 then
						--刷新属性显示
						PetEquipRepairUI.ResetCurScroll = 0
						local CurStrengthenScroll = _gt.GetUI("CurStrengthenScroll")
						GUI.LoopScrollRectSetTotalCount(CurStrengthenScroll, math.max(#t,4))
						GUI.LoopScrollRectRefreshCells(CurStrengthenScroll)
						
						PetEquipRepairUI.ResetPreScroll = 1
						local PreStrengthenScroll = _gt.GetUI("PreStrengthenScroll")
						GUI.LoopScrollRectSetTotalCount(PreStrengthenScroll, math.max(#t,4))
						GUI.LoopScrollRectRefreshCells(PreStrengthenScroll)
					end
					
					--装备基础信息显示
					--装备图标
					local Icon = _gt.GetUI("StrengthenEquip")
					GUI.SetVisible(Icon,true)
					GUI.ImageSetImageID(Icon,tostring(itemDB.Icon))
					--装备名称
					local Name = _gt.GetUI("StrengthenEquipName")
					GUI.SetPositionX(Name,0)
					GUI.StaticSetText(Name,itemDB.Name.."+"..tostring(enhanceLv).."（满）")
					
					local arrow = GUI.GetChild(Name,"arrow")
					GUI.SetVisible(arrow,false)
					local level = GUI.GetChild(Name,"level")
					GUI.SetVisible(level,false)
					
					--强化成功率
					local Rate = _gt.GetUI("StrengthenSuccessRate")
					GUI.StaticSetText(Rate,"当前已强化至最大等级")		
				end
				
			end
		--修理
		elseif CurSelectSubPage == 2 then
			local EquipIcon = _gt.GetUI("EquipIcon")
			GUI.ItemCtrlSetElementValue(EquipIcon,eItemIconElement.Icon,tostring(itemDB.Icon))
			GUI.ItemCtrlSetElementValue(EquipIcon,eItemIconElement.Border,UIDefine.ItemIconBg[itemDB.Grade])
			GUI.ItemCtrlSetElementValue(EquipIcon,eItemIconElement.LeftBottomSp,"1801208350")
			GUI.ItemCtrlSetElementRect(EquipIcon,eItemIconElement.LeftBottomSp,5,7,37,37)
			if equipData:GetAttr(ItemAttr_Native.IsBound) then
				GUI.ItemCtrlSetElementValue(EquipIcon,eItemIconElement.LeftTopSp,"1800707120")
			end
			
			local NameTxt = _gt.GetUI("NameTxt")
			GUI.StaticSetText(NameTxt,itemDB.Name)
				
			local LevelAndTypeTxt = _gt.GetUI("LevelAndTypeTxt")
			GUI.StaticSetText(LevelAndTypeTxt,itemDB.Level.."级 "..itemDB.ShowType)
			
			local EquipDurableVal = PetEquipList[index][2]
			local EquipDurableMax = PetEquipList[index][3]
			
			local RepairTipNum1 = _gt.GetUI("RepairTipNum1")
			GUI.StaticSetText(RepairTipNum1,EquipDurableVal)
			
			local RepairTipNum2 = _gt.GetUI("RepairTipNum2")
			GUI.StaticSetText(RepairTipNum2,EquipDurableMax)
			
			local MoneyCostIcon = _gt.GetUI("MoneyCostIcon")
			local coin_type = UIDefine.GetMoneyEnum(UIDefine.Repair_MoneyType or 5)
			GUI.ImageSetImageID(MoneyCostIcon, UIDefine.AttrIcon[coin_type])
			
			local petIcon = _gt.GetUI("petIcon")	
			local tmpName = _gt.GetUI("tmpName")	
			local petName = _gt.GetUI("petName")
			local RepairAllBth = _gt.GetUI("RepairAllBth")
			test(CurSelectLeftPage)
			if CurSelectLeftPage == 1 then
				GUI.SetVisible(petIcon,true)
				GUI.SetVisible(tmpName,true)
				GUI.SetVisible(petName,true)
				local moban = PetEquipList[index][4]
				GUI.ImageSetImageID(petIcon,tostring(moban.Head))
				local name = LD.GetPetName(PetEquipList[index][5])
				GUI.StaticSetText(petName,name)
				
				GUI.SetVisible(RepairAllBth,true)
			elseif CurSelectLeftPage == 2 then
				GUI.SetVisible(petIcon,false)
				GUI.SetVisible(tmpName,false)
				GUI.SetVisible(petName,false)
				GUI.SetVisible(RepairAllBth,false)
			end		
		
		
		end
		

------------------------------------------------------------------------------炼化
	elseif CurSelectPage == 2 then
		--获得当前装备的数据
		
		EquipAttrNow = TempEquipAttrNow[index]
		EquipAttr = TempEquipAttr[index]
		PetEquipRepairUI.TempIndex = index
		
		 -- local inspect = require("inspect")
		-- CDebug.LogError(inspect(EquipAttrNow))
		-- local AttrNowWithout = _gt.GetUI("AttrNowWithout")
		-- GUI.SetVisible(AttrNowWithout,false)

		--洗炼后属性显示
		PetEquipRepairUI.RefreshClearAttr()
		--当前属性显示
		PetEquipRepairUI.RefreshClearAttrNow()


	end	

		PetEquipRepairUI.OnItemRefresh()
		PetEquipRepairUI.OnBindGoldRefresh()	
	

end

function PetEquipRepairUI.OnItemRefresh()
	test("背包更新")
	local wnd = GUI.GetWnd("PetEquipRepairUI")
	if not wnd or not GUI.GetVisible(wnd) then
		return
	end
	local itemId = equipData:GetAttr(ItemAttr_Native.Id)
	local itemDB = DB.GetOnceItemByKey1(tonumber(itemId))
	if CurSelectPage ==1 then
		if CurSelectSubPage == 1 then
						--强化道具	
			local Item1 = _gt.GetUI("StrengthenItem1")
			local Item2 = _gt.GetUI("StrengthenItem2")
			local ulongVal = equipData:GetIntCustomAttr(LogicDefine.EnhanceLv)
			local enhanceLv, h = int64.longtonum2(ulongVal)	
			local Config = PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv]
			--当未强化至最大等级（暂时为达到最大级时仍显示升至最大级所需的石头）
			if enhanceLv < PetEquipRepairUI.StrengthenConfig["MaxIntensifyLevel"] then
				Config = PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv+1]
			end
			--强化石
			if Config["ConsumeItem"][1] then
				local key = Config["ConsumeItem"][1]
				local num2 = Config["ConsumeItem"][2]
				local ItemDB = DB.GetOnceItemByKey2(key)
				local num1 = LD.GetItemCountById(ItemDB.Id)
				GUI.ItemCtrlSetElementValue(Item1,eItemIconElement.Icon,tostring(ItemDB.Icon))
				GUI.ItemCtrlSetElementValue(Item1,eItemIconElement.Border,UIDefine.ItemIconBg[ItemDB.Grade])				
				GUI.ItemCtrlSetElementValue(Item1,eItemIconElement.RightBottomNum,num1.."/"..num2)	
				--需要在不足时显示为红色
				local Element =GUI.ItemCtrlGetElement(Item1,eItemIconElement.RightBottomNum)
				if num2 > num1 then
					GUI.SetColor(Element,UIDefine.RedColor)
				else
					GUI.SetColor(Element,colorWhite)
				end	
			end
			--保固道具
			if Config["SafeItem"][1] then
				local key = Config["SafeItem"][1]
				local num2 = Config["SafeItem"][2]
				local ItemDB = DB.GetOnceItemByKey2(key)
				local num1 = LD.GetItemCountById(ItemDB.Id)
				GUI.ItemCtrlSetElementValue(Item2,eItemIconElement.Icon,tostring(ItemDB.Icon))
				GUI.ItemCtrlSetElementValue(Item2,eItemIconElement.Border,UIDefine.ItemIconBg[ItemDB.Grade])				
				GUI.ItemCtrlSetElementValue(Item2,eItemIconElement.RightBottomNum,num1.."/"..num2)	
				--需要在不足时显示为红色
				local Element =GUI.ItemCtrlGetElement(Item2,eItemIconElement.RightBottomNum)
				if num2 > num1 then
					GUI.SetColor(Element,UIDefine.RedColor)
				else
					GUI.SetColor(Element,colorWhite)
				end	
			end		
		elseif 	CurSelectSubPage == 2 then	
			--修理时消耗道具的显示
			local RepairItemIcon = _gt.GetUI("RepairItemIcon")
			local ReapairItemNum1 = 0--获得玩家身上混元石的数量
			local ReapairItemNum2 = 0
			-- if PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]["Item"] ~= nil then
			if PetEquipRepairUI.PetEquipRepair_Consume["Level_"..itemDB.Level] ~= nil then
				if PetEquipRepairUI.PetEquipRepair_Consume["Level_"..itemDB.Level]["Item"][1] ~= nil then
					ReapairItemDB = DB.GetOnceItemByKey2(PetEquipRepairUI.PetEquipRepair_Consume["Level_"..itemDB.Level]["Item"][1])
					ReapairItemNum1 = LD.GetItemCountById(ReapairItemDB.Id)
					-- test(#(PetEquipRepairUI.PetEquipRepair_Consume["Level_"..itemDB.Level]["Item"]))
					ReapairItemNum2 = PetEquipRepairUI.PetEquipRepair_Consume["Level_"..itemDB.Level]["Item"][2]

					GUI.SetVisible(RepairItemIcon,true)
					GUI.ItemCtrlSetElementValue(RepairItemIcon,eItemIconElement.Icon,tostring(ReapairItemDB.Icon))
					GUI.ItemCtrlSetElementValue(RepairItemIcon,eItemIconElement.Border,UIDefine.ItemIconBg[ReapairItemDB.Grade])
					GUI.ItemCtrlSetElementValue(RepairItemIcon,eItemIconElement.RightBottomNum,ReapairItemNum1.."/"..ReapairItemNum2)
					GUI.ItemCtrlSetElementRect(RepairItemIcon,eItemIconElement.RightBottomNum,5,5,100,25)
				else
					GUI.SetVisible(RepairItemIcon,false)
				end
			elseif PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]~= nil then
				if PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]["Item"][1] ~= nil then
					ReapairItemDB = DB.GetOnceItemByKey2(PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]["Item"][1])
					ReapairItemNum1 = LD.GetItemCountById(ReapairItemDB.Id)
					ReapairItemNum2 = PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]["Item"][2]
					
					GUI.SetVisible(RepairItemIcon,true)
					GUI.ItemCtrlSetElementValue(RepairItemIcon,eItemIconElement.Icon,tostring(ReapairItemDB.Icon))
					GUI.ItemCtrlSetElementValue(RepairItemIcon,eItemIconElement.Border,UIDefine.ItemIconBg[ReapairItemDB.Grade])
					GUI.ItemCtrlSetElementValue(RepairItemIcon,eItemIconElement.RightBottomNum,ReapairItemNum1.."/"..ReapairItemNum2)				
					GUI.ItemCtrlSetElementRect(RepairItemIcon,eItemIconElement.RightBottomNum,5,5,100,25)
				else
					GUI.SetVisible(RepairItemIcon,false)
				end
			-- if PetEquipRepairUI.PetEquipRepair_Consume["Level_"..itemDB.Level]["Item"] ~= nil or PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]["Item"] ~= nil then
			else
				GUI.SetVisible(RepairItemIcon,false)
			end
			local ReapairItemNumTxt =GUI.ItemCtrlGetElement(RepairItemIcon,eItemIconElement.RightBottomNum)
			if ReapairItemNum2 > ReapairItemNum1 then
				GUI.SetColor(ReapairItemNumTxt,UIDefine.RedColor)
			else
				GUI.SetColor(ReapairItemNumTxt,colorWhite)
			end	
		end
	elseif CurSelectPage == 2 then
		local Level = itemDB.Level
		local ClearStoneNeedNum = 0
		local MoneyCostNum = 0
		if PetEquipRepairUI.PetEquipArtifice_ConsumeEx[itemDB.KeyName]  then
				ClearStoneNeedNum = PetEquipRepairUI.PetEquipArtifice_ConsumeEx[itemDB.KeyName]["ConsumeNum"]
		else
			if type(PetEquipRepairUI.PetEquipArtifice_Consume["Grade_"..itemDB.Grade]["ConsumeNum"]) == "number" then
				ClearStoneNeedNum = PetEquipRepairUI.PetEquipArtifice_Consume["Grade_"..itemDB.Grade]["ConsumeNum"]
			else
				local ConsumeNum = PetEquipRepairUI.PetEquipArtifice_Consume["Grade_"..itemDB.Grade]["ConsumeNum"]
				local ConsumeNumSum = assert(loadstring("local Level = "..Level.." return "..ConsumeNum))()
				ClearStoneNeedNum = ConsumeNumSum
			end
		end
		local ItemIcon = _gt.GetUI("ItemIcon")
		GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Icon,DB.GetOnceItemByKey1(29820).Icon)
		local ItemGrade = DB.GetOnceItemByKey1(29820).Grade
		GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Border,UIDefine.ItemIconBg[ItemGrade])
		local ClearStoneNum =LD.GetItemCountById(29820,item_container_type.item_container_bag)
		if ClearStoneNum < ClearStoneNeedNum then
			GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.RightBottomNum ,ClearStoneNum.."/"..ClearStoneNeedNum)
			local StoneNumTxt =GUI.ItemCtrlGetElement(ItemIcon,eItemIconElement.RightBottomNum)
			GUI.SetColor(StoneNumTxt,UIDefine.RedColor)
		else 
			GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.RightBottomNum ,ClearStoneNum.."/"..ClearStoneNeedNum)
			local StoneNumTxt =GUI.ItemCtrlGetElement(ItemIcon,eItemIconElement.RightBottomNum)
			GUI.SetColor(StoneNumTxt,UIDefine.White2Color)			
		end
		GUI.ItemCtrlSetElementRect(ItemIcon,eItemIconElement.RightBottomNum,5,5,0,0)
	
	
	end

end

function PetEquipRepairUI.OnBindGoldRefresh(GoldType,count)
	local wnd = GUI.GetWnd("PetEquipRepairUI")
	if not wnd or not GUI.GetVisible(wnd) then
		return
	end
	
	test("银币更新")
	if equipData ~= nil then
		local itemId = equipData:GetAttr(ItemAttr_Native.Id)
		local itemDB = DB.GetOnceItemByKey1(tonumber(itemId))
		if CurSelectPage ==1 then
			if CurSelectSubPage == 1 then
				local Text = _gt.GetUI("StrengthenMoneyCost")
				local AttrMoney = count ~= nil and tonumber(tostring(count)) or tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
				local MoneyCostNum = 0
				local ulongVal = equipData:GetIntCustomAttr(LogicDefine.EnhanceLv)
				local enhanceLv, h = int64.longtonum2(ulongVal)	
				if enhanceLv+1 <= PetEquipRepairUI.StrengthenConfig["MaxIntensifyLevel"] and PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv+1] then
					local Config = PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv+1]
					MoneyCostNum = Config["MoneyVal"]
				end
				
				GUI.StaticSetText(Text,math.floor(MoneyCostNum))
				
				if math.floor(MoneyCostNum) <= AttrMoney then
					GUI.SetColor(Text,UIDefine.White2Color)
				else
					GUI.SetColor(Text,UIDefine.RedColor)
				end		
			
			elseif  CurSelectSubPage == 2 then
				local EquipDurableVal = PetEquipList[data.index][2]
				local EquipDurableMax = PetEquipList[data.index][3]
				local MoneyCostText = _gt.GetUI("MoneyCostText")
				local grade = itemDB.Grade
				local MoneyCostNum = 0
				local GradeCoef = PetEquipRepairUI.PetEquipRepair_GradeCoefficient[grade]
				if PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]  then
					if type(PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]["MoneyValCoef"]) == "number" then
						local CostVal = PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]["MoneyValCoef"]
						MoneyCostNum = (EquipDurableMax - EquipDurableVal)* CostVal
					else 
						local CostVal = PetEquipRepairUI.PetEquipRepair_ConsumeEx[itemDB.KeyName]["MoneyValCoef"]
						local MoneyCostValSum = assert(loadstring("local GradeCoef = "..GradeCoef.." return "..CostVal))()
						MoneyCostNum = (EquipDurableMax - EquipDurableVal)* MoneyCostValSum
					end
				else
					if type(PetEquipRepairUI.PetEquipRepair_Consume["Level_"..itemDB.Level]["MoneyValCoef"]) == "number" then
						local CostVal = PetEquipRepairUI.PetEquipRepair_Consume["Level_"..itemDB.Level]["MoneyValCoef"]
						MoneyCostNum = (EquipDurableMax - EquipDurableVal)* CostVal
					else
						local CostVal = PetEquipRepairUI.PetEquipRepair_Consume["Level_"..itemDB.Level]["MoneyValCoef"]
						local MoneyCostValSum = assert(loadstring("local GradeCoef = "..GradeCoef.." return "..CostVal))()
						MoneyCostNum = (EquipDurableMax - EquipDurableVal)* MoneyCostValSum
					end
				end
				local AttrMoney = count ~= nil and tonumber(tostring(count)) or tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
				
				GUI.StaticSetText(MoneyCostText,math.floor(MoneyCostNum))
				
				if math.floor(MoneyCostNum) <= AttrMoney then
					GUI.SetColor(MoneyCostText,UIDefine.White2Color)
				else
					GUI.SetColor(MoneyCostText,UIDefine.RedColor)
				end
			end
		elseif CurSelectPage ==2 then
			local MoneyCostText2 = _gt.GetUI("MoneyCostText2")
			local Level = itemDB.Level
			local MoneyCostNum = 0
			if PetEquipRepairUI.PetEquipArtifice_ConsumeEx[itemDB.KeyName]  then
					MoneyCostNum =  PetEquipRepairUI.PetEquipArtifice_ConsumeEx[itemDB.KeyName]["MoneyVal"]
			else
				MoneyCostNum = Level*50+500
			end
			local AttrMoney = count ~= nil and tonumber(tostring(count)) or tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
			
			GUI.StaticSetText(MoneyCostText2,MoneyCostNum)
			if MoneyCostNum <= AttrMoney then
				GUI.SetColor(MoneyCostText2,UIDefine.White2Color)
			else
				GUI.SetColor(MoneyCostText2,UIDefine.RedColor)
			end	
		end
	end

end

--当点击强化道具1
function PetEquipRepairUI.OnStrengthenItem1Click()
	if PetEquipRepairUI.StrengthenConfig then
		local ulongVal = equipData:GetIntCustomAttr(LogicDefine.EnhanceLv)
		local enhanceLv, h = int64.longtonum2(ulongVal)	
		local Config = PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv]
		--当未强化至最大等级（暂时为达到最大级时仍显示升至最大级所需的石头）
		if enhanceLv < PetEquipRepairUI.StrengthenConfig["MaxIntensifyLevel"] then
			Config = PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv+1]
		end
		local key = Config["ConsumeItem"][1]
		local parent = _gt.GetUI("PetEquipStrengthenPage")
		local itemtips = Tips.CreateByItemKeyName(key,parent, "itemtips", 150, 100, 50)
		local ItemDB = DB.GetOnceItemByKey2(key)
		GUI.SetData(itemtips, "ItemId", tostring(ItemDB.Id))
		_gt.BindName(itemtips,"StrengthenItemTips")
		
		local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
		GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
		GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
		GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetEquipRepairUI","OnClickStrengthenItemWayBtn")
		GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
	end
end

--当点击强化道具2
function PetEquipRepairUI.OnStrengthenItem2Click()
	if PetEquipRepairUI.StrengthenConfig then
		local ulongVal = equipData:GetIntCustomAttr(LogicDefine.EnhanceLv)
		local enhanceLv, h = int64.longtonum2(ulongVal)	
		local Config = PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv]
		--当未强化至最大等级（暂时为达到最大级时仍显示升至最大级所需的石头）
		if enhanceLv < PetEquipRepairUI.StrengthenConfig["MaxIntensifyLevel"] then
			Config = PetEquipRepairUI.StrengthenConfig["Config"][enhanceLv+1]
		end
		local key = Config["SafeItem"][1]
		local parent = _gt.GetUI("PetEquipStrengthenPage")
		local itemtips = Tips.CreateByItemKeyName(key,parent, "itemtips", 150, 100, 50)
		local ItemDB = DB.GetOnceItemByKey2(key)
		GUI.SetData(itemtips, "ItemId", tostring(ItemDB.Id))
		_gt.BindName(itemtips,"StrengthenItemTips")
		
		local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
		UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
		GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
		GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
		GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetEquipRepairUI","OnClickStrengthenItemWayBtn")
		GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
	end
end


function PetEquipRepairUI.OnClickStrengthenItemWayBtn()
	local tips = _gt.GetUI("StrengthenItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

--是否使用非绑材料
function PetEquipRepairUI.OnUnBindClick()
	PetEquipRepairUI.UnBind = PetEquipRepairUI.UnBind == 1 and 0 or 1
end

--是否使用保固道具
function PetEquipRepairUI.OnIsSafeClick()
	PetEquipRepairUI.IsSafe = PetEquipRepairUI.IsSafe == 1 and 0 or 1
end


function PetEquipRepairUI.OnRepairBthClick()
	if itemGUID ~= nil then
	CL.SendNotify(NOTIFY.SubmitForm, "FormPetEquipRepair","RepairOnce",itemGUID)
	else 
	CL.SendNotify(NOTIFY.ShowBBMsg, "未选中宠物装备")
	end
end

function PetEquipRepairUI.OnRepairAllBthClick()
	if itemGUID~=nil then
	CL.SendNotify(NOTIFY.SubmitForm, "FormPetEquipRepair","RepairAll")
	end
end


function PetEquipRepairUI.OnStrengthenBthClick()
	if itemGUID ~= nil then
		local Version = PetEquipRepairUI.StrengthenConfig["Version"]
		-- CDebug.LogError("安全"..PetEquipRepairUI.IsSafe)
		-- CDebug.LogError("非绑定"..PetEquipRepairUI.UnBind)
		CL.SendNotify(NOTIFY.SubmitForm, "FormPetEquipIntensify","Start",Version,itemGUID,PetEquipRepairUI.IsSafe,PetEquipRepairUI.UnBind)
	else 
		CL.SendNotify(NOTIFY.ShowBBMsg, "未选中宠物装备")
	end
end

function PetEquipRepairUI.RefreshOnRepairClick()  ---为了方便服务器调用
	PetEquipRepairUI.RefreshPetEquipRepairPage()
	PetEquipRepairUI.RefreshPetEquipLeftPage()
end


function PetEquipRepairUI.RefreshOnStrengthenClick()
	PetEquipRepairUI.RefreshPetEquipRepairPage()
	PetEquipRepairUI.RefreshPetEquipLeftPage()
end

-- 强化成功
function PetEquipRepairUI.OnBuildSucces()
	
    -- test("EquipEnhanceUI OnBuildSucces " .. data.Build_Time)
    GUI.OpenWnd("ShowEffectUI", 3000001406)
    ShowEffectUI.SetTimeOff(1)
end
-- 强化失败
function PetEquipRepairUI.OnBuildFail()
    -- test("EquipEnhanceUI OnBuildFail " .. data.Build_Time)
    GUI.OpenWnd("ShowEffectUI", 3000001426)
    ShowEffectUI.SetTimeOff(1)
end

--------------------------------------------------洗炼开始------------------------------------------------------------------

local MaxArtificeCnt = 8
function PetEquipRepairUI.OnPetEquipClearToggle()
	--切换后默认选择第一页第一个物品
	CurSelectLeftPage = 1
	CurSelectPage = 2
	
	UILayout.OnTabClick(CurSelectPage, LabelList)
	PetEquipRepairUI.OnTabBtnClick(tabBtns[CurSelectLeftPage].guid)
	PetEquipRepairUI.RefreshEquipPageButton(CurSelectPage,CurSelectSubPage)
    PetEquipRepairUI.RefreshPetEquipClearPage()
end

function PetEquipRepairUI.CreatePetEquipClearPage(pageName)
	local panelBg = _gt.GetUI("panelBg")
	PetEquipClearPage = GUI.GroupCreate(panelBg ,pageName, 0, 0, 0, 0)
	_gt.BindName(PetEquipClearPage, pageName)
		
	local ClearRightPage = GUI.ImageCreate( PetEquipClearPage, "ClearRightPage", "1801100100", 520, 2);
    SetAnchorAndPivot(ClearRightPage, UIAnchor.Right, UIAroundPivot.Right)
	
-- 下方道具消耗

	local ItemIcon = GUI.ItemCtrlCreate(ClearRightPage, "ItemIcon", "1800400330", 20, -35);
    SetAnchorAndPivot(ItemIcon, UIAnchor.Bottom, UIAroundPivot.Bottom)
	GUI.RegisterUIEvent(ItemIcon, UCE.PointerClick, "PetEquipRepairUI","OnClearItemClick")
	_gt.BindName(ItemIcon,"ItemIcon")
	
-- 洗炼按钮
	local ClearBth = GUI.ButtonCreate(PetEquipClearPage,"ClearBth","1800402080",510,288,Transition.ColorTint, "")
	SetAnchorAndPivot(ClearBth, UIAnchor.BottomRight , UIAroundPivot.BottomRight)
	GUI.RegisterUIEvent(ClearBth, UCE.PointerClick, "PetEquipRepairUI", "OnClearBthClick")
	local ClearTxt =GUI.CreateStatic(ClearBth,"ClearTxt","洗  炼",0,0,400,200)
	SetAnchorAndPivot(ClearTxt, UIAnchor.Center , UIAroundPivot.Center )
	GUI.StaticSetFontSize(ClearTxt, fontSizeBtn)
	GUI.StaticSetAlignment(ClearTxt, TextAnchor.MiddleCenter)
	GUI.SetIsOutLine(ClearTxt, true)
	GUI.SetOutLine_Color(ClearTxt, colorOutline)
	GUI.SetOutLine_Distance(ClearTxt, 1)
--替换按钮
	local ReplaceBth = GUI.ButtonCreate(PetEquipClearPage,"ReplaceBth","1800402080",310,288,Transition.ColorTint, "")
	SetAnchorAndPivot(ReplaceBth, UIAnchor.BottomRight , UIAroundPivot.BottomRight)
	GUI.RegisterUIEvent(ReplaceBth, UCE.PointerClick, "PetEquipRepairUI", "OnReplaceBthClick")
	local ReplaceTxt =GUI.CreateStatic(ReplaceBth,"ReplaceTxt","替  换",0,0,400,200)
	SetAnchorAndPivot(ReplaceTxt, UIAnchor.Center , UIAroundPivot.Center )
	GUI.StaticSetFontSize(ReplaceTxt, fontSizeBtn)
	GUI.StaticSetAlignment(ReplaceTxt, TextAnchor.MiddleCenter)
	GUI.SetIsOutLine(ReplaceTxt, true)
	GUI.SetOutLine_Color(ReplaceTxt, colorOutline)
	GUI.SetOutLine_Distance(ReplaceTxt, 1)
	
-- 花费
	local MoneyCost = GUI.CreateStatic(PetEquipClearPage, "MoneyCost", "消耗", -210, 285, 200, 50)
	SetAnchorAndPivot(MoneyCost, UIAnchor.BottomLeft , UIAroundPivot.BottomLeft );
	GUI.SetColor(MoneyCost, colorDark)
	GUI.StaticSetFontSize(MoneyCost, 26)
	
	local MoneyCostBg = GUI.ImageCreate(MoneyCost, "MoneyCostBg", "1800700010", 65, 5, false, 200, 36)
		
	local MoneyCostIcon = GUI.ImageCreate(MoneyCostBg, "MoneyCostIcon", "1800408280", 0, 1, false, 36, 36)
	SetAnchorAndPivot(MoneyCostIcon, UIAnchor.Left , UIAroundPivot.Left )
	---需要改

	local MoneyCostText2 = GUI.CreateStatic(MoneyCostBg, "MoneyCostText2", "0", 0, 1, 200, 35,"system",true)
	GUI.SetColor(MoneyCostText2, UIDefine.White2Color);
	GUI.StaticSetFontSize(MoneyCostText2, 22);
	GUI.StaticSetAlignment(MoneyCostText2, TextAnchor.MiddleCenter);
	_gt.BindName(MoneyCostText2, "MoneyCostText2")
	
	
-- 中间两个框
	local LeftBg = GUI.ImageCreate( ClearRightPage, "LeftBg", "1801100030", 170, -65, false, 290, 255)
    SetAnchorAndPivot(LeftBg, UIAnchor.Center, UIAroundPivot.Center)
    local LeftTitle = GUI.CreateStatic( LeftBg, "LeftTitle", "当前", 0, -106.5, 200, 50)
	GUI.StaticSetAlignment (LeftTitle,TextAnchor.MiddleLeft)
    GUI.SetColor(LeftTitle, colorDark)
    GUI.StaticSetFontSize(LeftTitle, 26)
	for i = 1 , 8 do
		local AttrNameNow = GUI.CreateStatic(LeftBg, "AttrNameNow"..i, "属性", -20, -98+25*i, 200, 50)
		SetAnchorAndPivot(AttrNameNow, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(AttrNameNow, 22)
		GUI.StaticSetAlignment (AttrNameNow,TextAnchor.MiddleLeft)
		_gt.BindName(AttrNameNow, "AttrNameNow"..i)
		GUI.SetVisible(AttrNameNow,false)

		local AttrValueNow = GUI.CreateStatic(LeftBg, "AttrValueNow"..i, "61", 90,-98+25*i, 200, 50)
		SetAnchorAndPivot(AttrValueNow, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(AttrValueNow, 22)
		GUI.StaticSetAlignment (AttrValueNow,TextAnchor.MiddleLeft)		
		_gt.BindName(AttrValueNow, "AttrValueNow"..i)
		GUI.SetVisible(AttrValueNow,false)
	end
	
	--没有当前属性时
	local AttrNowWithout = GUI.CreateStatic(LeftBg, "AttrNowWithout", "洗炼即可获得额外属性", 25, 10, 300, 50)
	SetAnchorAndPivot(AttrNowWithout, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetFontSize(AttrNowWithout, 22)
	GUI.StaticSetAlignment (AttrNowWithout,TextAnchor.MiddleLeft)
	GUI.SetColor(AttrNowWithout,colorDark)
	_gt.BindName(AttrNowWithout, "AttrNowWithout")
	GUI.SetVisible(AttrNowWithout,false)
  
	local RightBg = GUI.ImageCreate( ClearRightPage, "RightBg", "1801100030", -170, -65, false, 290, 255)
    SetAnchorAndPivot(RightBg, UIAnchor.Center, UIAroundPivot.Center)
    local RightTitle = GUI.CreateStatic(RightBg, "RightTitle", "洗炼后", 0,-106.5, 200, 50)
    GUI.SetColor(RightTitle, colorDark)
	GUI.StaticSetAlignment (RightTitle,TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(RightTitle, 26)
	for i = 1 , 8 do
		local AttrName = GUI.CreateStatic(RightBg, "AttrName"..i, "属性", -20, -98+25*i, 200, 50)
		SetAnchorAndPivot(AttrName, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(AttrName, 22)
		GUI.StaticSetAlignment (AttrName,TextAnchor.MiddleLeft)
		_gt.BindName(AttrName, "AttrName"..i)
		GUI.SetVisible(AttrName,false)

		local AttrValue = GUI.CreateStatic(RightBg, "AttrValue"..i, "61", 90,-98+25*i, 200, 50)
		SetAnchorAndPivot(AttrValue, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(AttrValue, 22)
		GUI.StaticSetAlignment (AttrValue,TextAnchor.MiddleLeft)		
		_gt.BindName(AttrValue, "AttrValue"..i)
		GUI.SetVisible(AttrValue,false)
	end
	

--anniu
	local Btn = _gt.GetUI("tempBtn1")
	if not Btn then
		local btnWidth = 145
		local btnHeight = 45
		for i = 1, #tabBtns do
			local tempBtn = GUI.ButtonCreate( panelBg, tabBtns[i][2], "1800402030", 80 + (i - 1) * btnWidth, 55, Transition.None, "", btnWidth, btnHeight, false)
			SetAnchorAndPivot(tempBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
			tabBtns[i].guid = GUI.GetGuid(tempBtn)
			_gt.BindName(tempBtn,"tempBtn"..i)
				
			local btnSprite = GUI.ImageCreate( tempBtn, "btnSprite", "1800402032", 0, 0, false, btnWidth, btnHeight)
			SetAnchorAndPivot(btnSprite, UIAnchor.Center, UIAroundPivot.Center)
			GUI.SetVisible(btnSprite, false)

			local labelTxt = GUI.CreateStatic( tempBtn, tabBtns[i][2] .. "label", tabBtns[i][1], 0, 0, btnWidth, btnHeight, "system", true, false)
			SetAnchorAndPivot(labelTxt, UIAnchor.Center, UIAroundPivot.Center)
			GUI.StaticSetFontSize(labelTxt, 22)
			GUI.StaticSetAlignment(labelTxt, TextAnchor.MiddleCenter)
			GUI.SetColor(labelTxt, colorDark)

			GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "PetEquipRepairUI", "OnTabBtnClick")
		end
	end	
	
	return PetEquipClearPage
	


end

--当修理消耗的物品被点击
function PetEquipRepairUI.OnRepairItemClick()
	local PetEquipRepairPage = _gt.GetUI("PetEquipRepairPage")
	
	local itemtips = Tips.CreateByItemKeyName("混元石", PetEquipRepairPage, "PetEquipClearItemTip", 0, 0, 50)
	local ItemDB = DB.GetOnceItemByKey2("混元石")
	GUI.SetData(itemtips, "ItemId", tostring(ItemDB.Id))
	_gt.BindName(itemtips,"RepairItemTips")

	local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
	UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetEquipRepairUI","OnClickRepairItemWayBtn")
    GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
	

end

function PetEquipRepairUI.OnClickRepairItemWayBtn()
	local tips = _gt.GetUI("RepairItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end


--当洗炼消耗的物品被点击
function PetEquipRepairUI.OnClearItemClick()
	local PetEquipClearPage = _gt.GetUI("PetEquipClearPage")
	local itemtips = Tips.CreateByItemKeyName("宠物装备洗炼石", PetEquipClearPage, "PetEquipClearItemTip", 0, 0, 50)
	local ItemDB = DB.GetOnceItemByKey2("宠物装备洗炼石")
	GUI.SetData(itemtips, "ItemId", tostring(ItemDB.Id))
	_gt.BindName(itemtips,"ClearItemTips")

	local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
	UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetEquipRepairUI","OnClickClearItemWayBtn")
    GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
	
end

function PetEquipRepairUI.OnClickClearItemWayBtn()
	local tips = _gt.GetUI("ClearItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

function PetEquipRepairUI.RefreshPetEquipClearPage()
    local PetEquipClearPage = _gt.GetUI("PetEquipClearPage")
    if not PetEquipClearPage then
        PetEquipClearPage = PetEquipRepairUI.CreatePetEquipClearPage("PetEquipClearPage")
    else
        GUI.SetVisible(PetEquipClearPage, true)
    end
	--隐藏其他页
	local PetEquipRepairPage = _gt.GetUI("PetEquipRepairPage")
	local PetEquipStrengthenPage = _gt.GetUI("PetEquipStrengthenPage")
	if PetEquipRepairPage or PetEquipStrengthenPage then
		GUI.SetVisible(PetEquipRepairPage, false)
		GUI.SetVisible(PetEquipStrengthenPage, false)
	end
	
	local ItemIcon = _gt.GetUI("ItemIcon")
	GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Icon,"")
	GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Border,"1800400330")
	GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.RightBottomNum ,"")
	-- local ClearStoneNum =LD.GetItemCountById(29820,item_container_type.item_container_bag)	

	local MoneyCostText2 = _gt.GetUI("MoneyCostText2")
	GUI.StaticSetText(MoneyCostText2,"0")
	
end	

function PetEquipRepairUI.OnClearBthClick()
		CL.SendNotify(NOTIFY.SubmitForm,"FormPetEquipArtifice","Artificing",itemGUID)
end


function PetEquipRepairUI.OnReplaceBthClick()
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetEquipArtifice","SaveAttrChange",itemGUID)
end

--刷新洗炼后的属性显示
function PetEquipRepairUI.RefreshClearAttr()
	for i =1 , 8 do
		local Name = _gt.GetUI("AttrName"..i)
		local Value = _gt.GetUI("AttrValue"..i)	
		GUI.SetVisible(Name,false)
		GUI.SetVisible(Value,false)
	end
	if EquipAttr and #EquipAttr > 0 then
		for i =1 , #EquipAttr do
			local Name = _gt.GetUI("AttrName"..i)
			local Value = _gt.GetUI("AttrValue"..i)
			GUI.SetVisible(Name,true)
			GUI.SetVisible(Value,true)
			
			-- CDebug.LogError(#EquipAttr)
			local AttrDB = DB.GetOnceAttrByKey1(EquipAttr[i][1])

			GUI.StaticSetText(Name,AttrDB.ChinaName)
			GUI.StaticSetText(Value,tostring(EquipAttr[i][2]))
			local Grade = EquipAttr[i][3]
			GUI.SetColor(Name,UIDefine.PetEquipAttrGrade["OnWhite"][Grade])
			GUI.SetColor(Value,UIDefine.PetEquipAttrGrade["OnWhite"][Grade])
		end	
	end	
end


--刷新当前的洗炼属性
function PetEquipRepairUI.RefreshClearAttrNow()
	local AttrNowWithout = _gt.GetUI("AttrNowWithout")
	GUI.SetVisible(AttrNowWithout,false)
	for i =1 , 8 do
		local Name = _gt.GetUI("AttrNameNow"..i)
		local Value = _gt.GetUI("AttrValueNow"..i)	
		GUI.SetVisible(Name,false)
		GUI.SetVisible(Value,false)
	end
	if EquipAttrNow and #EquipAttrNow > 0 then
		for i =1 , #EquipAttrNow do
			local Name = _gt.GetUI("AttrNameNow"..i)
			local Value = _gt.GetUI("AttrValueNow"..i)
			GUI.SetVisible(Name,true)
			GUI.SetVisible(Value,true)
			
			local AttrDB = DB.GetOnceAttrByKey1(EquipAttrNow[i][1])

			GUI.StaticSetText(Name,AttrDB.ChinaName)
			GUI.StaticSetText(Value,tostring(EquipAttrNow[i][2]))
			local Grade = EquipAttrNow[i][3]
			GUI.SetColor(Name,UIDefine.PetEquipAttrGrade["OnWhite"][Grade])
			GUI.SetColor(Value,UIDefine.PetEquipAttrGrade["OnWhite"][Grade])
		end	
	else
		GUI.SetVisible(AttrNowWithout,true)
	end
 -- local inspect = require("inspect")
-- CDebug.LogError(inspect(EquipAttrNow))

end

function PetEquipRepairUI.RefreshOnClearClick()  ---洗炼之后的服务器调用的刷新
	PetEquipRepairUI.RefreshPetEquipLeftPage()
	
end

function PetEquipRepairUI.RefreshOnReplaceClick()  ---为了方便服务器调用
	EquipAttrNow = EquipAttr
	table.remove(TempEquipAttrNow,PetEquipRepairUI.TempIndex)
	table.insert(TempEquipAttrNow,PetEquipRepairUI.TempIndex,EquipAttrNow)
	table.remove(TempEquipAttr,PetEquipRepairUI.TempIndex)
	table.insert(TempEquipAttr,PetEquipRepairUI.TempIndex,{})
	EquipAttr = {}
				
	--洗炼后属性显示
	PetEquipRepairUI.RefreshClearAttr()
	--当前属性显示
	PetEquipRepairUI.RefreshClearAttrNow()
end


