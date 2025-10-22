local PetUI = {
	LevelUpPetBag_Table = {},
	PetUpStarIntConfig={},
	PetUpStarConsume={},
	PetStarSkill={},
	PetStarAttr={},
	PetAttrChange={},
	PetRefiningConsume={},
	PetRefiningAttrColor={},
	-- MedicinePetType={},
	-- MedicineItem={},
	-- SkillStudyPetType={},
	-- SkillStudyShowItem = {},
	-- SkillExtractPetType = {},
	-- SkillExtractShowOrder = {},
	-- SkillBindPetType = {},
	-- SkillBindItem = "",
	-- SkillUnbindItem = "",
	PetMixServerData = {},
	PetStarSkillLevel = {},
	CurPetStarSkill = {}
}
_G.PetUI = PetUI
local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------


--宠物模型偏移表(Y轴)
local ModelOffsetConfig = {
	["5407"] = 40,
}

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

--合成相关变量
local visible = 1
local modelVisible1 = 1
local modelVisible2 = 1
local luckItemKeyName = -1


local RestoreItemEduList ={}
local SkillExtractItemList = {}
local SkillExtractItemGuid={}
local SkillBindItemList = {}
local TrainingItemUseList = ""
local CurSkillIndex = 0

local Item_Index =1
local SkillStudy_Index = 1
local Restore_Index = 1
local Extract_Index = 1
local SkillBind_Index = 1

--阵容交换状态
local ExchangTorF = 0

local LabelList = {
	{ "属性", "AttributeTog", "OnAttributeToggle", "AttributePage", "CreateAttributePage" },
	{ "养成", "EduTog", "OnEduToggle", "EduPage", "CreateEduPage","CreateAttributePage"},
	{ "洗炼", "RefineTog", "OnRefineToggle", "RefinePage", "CreateRefinePage"},
	{ "合成", "SynthesisTog", "OnSynthesisToggle", "SynthesisPage", "CreateSynthesisPage"},
	{ "阵容", "PetLineUpTog", "OnPetLineUpToggle", "PetLineUpPage", "CreatePetLineUpPage"},
}

local pageNames = {
    { "pageAttribute", "PetUI/panelBg/AttributePanel" },
	{ "pageEdu", "PetUI/panelBg/pageEduPanel" },
    { "pageRefine", "PetUI/panelBg/pageRefinePanel" },
	{ "SynthesisSubPage", "PetUI/panelBg/SynthesisPanel" },
	{"pagePetLineUp","PetUI/panelBg/pagePetLineUpPanel" }
}

local CurAttributeSubTab = 1
local CurpageRefineSubTab = 1
local tabBtns = {
    { "宠物属性", "tabAttribute" },
    { "资质技能", "tabSkills" },
    { "宠物装备", "tabEquipment" },
}

local tabBtns2 = {
    { "宠物培养", "tabTraining", "tabTrainingPanel", 1 },
    { "技能学习", "tabLearning", "tabLearningPanel", 2 },
    { "宠物还原", "tabRestore", "tabRestorePanel", 3 },
    { "技能提取", "tabExtract", "tabExtractPanel", 4 },
    { "技能绑定", "tabBind", "tabBindPanel", 5 }
}
local tabBtns3 = {
    { "洗炼", "tabClear" },
    { "突破", "tabBreach" }
}

local imgs = {
  site_collar = "1801400030",     --宠物项圈
  site_armor =  "1801400040",     --宠物盔甲
  site_amulet =  "1801400050",    --宠物护符
  site_accessory ="1801400060",   --宠物装饰
}

local equipSiteData={
  [1]={site=LogicDefine.PetEquipSite.site_collar,img="1801400030"},
  [2]={site=LogicDefine.PetEquipSite.site_armor,img="1801400040"},
  [3]={site=LogicDefine.PetEquipSite.site_amulet,img="1801400050"},
  [4]={site=LogicDefine.PetEquipSite.site_accessory,img="1801400060"}
}


local tabNames = {
    { "tabAttributePanel", pageNames[1][2] .. "/tabAttributePanel" },
    { "tabAptitudeAndSkillsPanel", pageNames[1][2] .. "/tabAptitudeAndSkillsPanel" },
    { "tabEquipmentPanel", pageNames[1][2] .. "/tabEquipmentPanel" },
	{ "tabTrainingPanel", pageNames[2][2] .. "/pageEduPanelBg/tabTrainingPanel" },
	{ "tabLearningPanel", pageNames[2][2] .. "/pageEduPanelBg/tabLearningPanel" },
	{ "tabRestorePanel", pageNames[2][2] .. "/pageEduPanelBg/tabRestorePanel" },
	{ "tabExtractPanel", pageNames[2][2] .. "/pageEduPanelBg/tabExtractPanel" },
	{ "tabBindPanel", pageNames[2][2] .. "/pageEduPanelBg/tabBindPanel"},
    { "tabClearPanel", pageNames[3][2] .. "/tabClearPanel" },
    { "tabBreachPanel", pageNames[3][2] .. "/tabBreachPanel" },	
}

-- 宠物装备表
local petEquipments = {
    { "宠物项圈", "RoleAttrcollar", "1801400030", "1800400050", RoleAttrcollar },
    { "宠物盔甲", "RoleAttrarmor", "1801400040", "1800400050", RoleAttrarmor },
    { "宠物护符", "RoleAttramulet", "1801400050", "1800400050", RoleAttramulet },
    { "宠物饰品", "RoleAttraccessory", "1801400060", "1800400050", RoleAttraccessory },
}


-- 宠物属性表
local petProperty = {
    [1] = { "气血", "RoleAttrHp", "1800408120", "1800408110", 260, "RoleAttrHpLimit" },
    [2] = { "魔法", "RoleAttrMp", "1800408130", "1800408110", 260, "RoleAttrMpLimit" },
    [3] = { "经验", "RoleAttrExp", "1800408160", "1800408110", 230, "RoleAttrExpLimit" },
	[4] = { "忠诚", "PetAttrLoyalty", "RaiseBtn", "1800402110", "驯养" },
    [5] = { "寿命", "PetAttrLife", "AddLifeBtn", "1800402110", "增寿" },
    [6] = { "潜能", "RoleAttrRemainPoint", "AddPointBtn", "1800402110", "加点" },

    [7] = { "物攻", "RoleAttrPhyAtk" },
	[8] = { "法攻", "RoleAttrMagAtk" },
    [9] = { "物防", "RoleAttrPhyDef" },
    [10] = { "法防", "RoleAttrMagDef" },
    [11] = { "速度", "RoleAttrFightSpeed" },

    [12] = { "力量", "RoleAttrStr" },
    [13] = { "法力", "RoleAttrInt" },
    [14] = { "体质", "RoleAttrVit" },
    [15] = { "耐力", "RoleAttrEnd" },
    [16] = { "敏捷", "RoleAttrAgi" },
	
	
    [24] = { "悟    性", "PetAttrSavvy", "1800408160", "1800408110", 225, "SavvyMax" ,"SavvyMin"},
    [23] = { "成 长 率", "PetAttrGrowthrate", "1800408160", "1800408110", 225, "GrowthRateMax","GrowthRateMin" },
    [17] = { "血量资质", "PetAttrHpTalent", "1800408160", "1800408110", 225, "TalentHPMax","TalentHPMin" },
    [18] = { "物攻资质", "PetAttrPhyAtkTalent", "1800408160", "1800408110", 225, "TalentPhyAtkMax" ,"TalentPhyAtkMin"},
    [19] = { "物防资质", "PetAttrPhyDefTalent", "1800408160", "1800408110", 225, "TalentPhyDefMax","TalentPhyDefMin" },
    [20] = { "法攻资质", "PetAttrMagAtkTalent", "1800408160", "1800408110", 225, "TalentMagAtkMax" ,"TalentMagAtkMin"},
    [21] = { "法防资质", "PetAttrMagDefTalent", "1800408160", "1800408110", 225, "TalentMagDefMax" ,"TalentMagDefMin"},
	[22] = { "速度资质", "PetAttrSpeedTalent", "1800408160", "1800408110", 225, "TalentSpeedMax","TalentSpeedMin" },

	}
local properties = {17, 18,19, 20, 21, 22}
--左侧宠物选择index
PetUI.ListIndex = 0 

-- 宠物排序种类
local petSortType = {
    { "默认", 1 },
    { "品质", 2 },
    { "星级", 3 },
}

local PetSortType_Index = 1
local RestorePetIndex = 0
function PetUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("PetUI", "PetUI", 0, 0);
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "宠    物","PetUI", "OnCloseBtnClick", _gt)
    UILayout.CreateRightTab(LabelList, "PetUI")
	GUI.SetVisible(panel, false)
	
	local PetLineUpTog = GUI.GetChild(panelBg,"PetLineUpTog")
	GUI.AddRedPoint(PetLineUpTog,UIAnchor.TopLeft,25,-30)
	
	local AttributeTog = GUI.GetChild(panelBg,"AttributeTog")
	GUI.AddRedPoint(AttributeTog,UIAnchor.TopLeft,25,-30)
	
	PetUI.CreateBase(panelBg)
end


function PetUI.InitData()
	PetUI.tabIndex = 1;
	CurpageEduSubTab = 1
	PetUI.preEquipItemGuid=nil;
	PetUI.equipGuids={};
	PetUI.equipSite=0;
	PetUI.JumpItemKey = nil

	PetUI.PetListChange =1

	LastPetGuid = 0

--养成物品选择

	Item_Index =1
	SkillStudy_Index = 1
	Restore_Index = 1
	Extract_Index = 1
	SkillBind_Index = 1	
end

function PetUI.OnShow(parameter)

	local wnd = GUI.GetWnd("PetUI")
	if wnd then
		GUI.SetVisible(wnd, true)
	end

	PetUI.Register()
	PetUI.InitData();

	if parameter then
		parameter = string.split(parameter, ",")
		PetUI.tabIndex = tonumber(parameter[1])
		if PetUI.tabIndex == 1 then
			CurAttributeSubTab = tonumber(parameter[2])
		elseif PetUI.tabIndex == 2 then
			CurpageEduSubTab = tonumber(parameter[2])
			PetUI.JumpItemKey = parameter[3]
		elseif PetUI.tabIndex == 3 then
			CurpageRefineSubTab = tonumber(parameter[2])
			PetUI.JumpItemKey = parameter[3]
		elseif PetUI.tabIndex == 4 then
			PetUI.OnSynthesisToggle()
		end	
	else
	
    end
	
	CL.SendNotify(NOTIFY.SubmitForm, "FormPetSystem", "GetLevelUpPetBag")	
	
	--打开时就获得养成相关数据
	-- local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	-- local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel[LabelList[2][1]]
	-- if Level >= OpenLevel and not GlobalProcessing.ShowItemList then
		-- PetUI.GetPetEduData()
	-- end
	
	-- if wnd then
        -- GUI.SetVisible(wnd, true)
    -- end
end

--向服务器发送获得养成数据的申请
function PetUI.GetPetEduData()
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","MedicineGetData")
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","SkillStudyGetData")
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","RestoreGetData")
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","SkillExtractGetData")
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","SkillBindGetData")
	
end

function PetUI.Register()
	CL.RegisterMessage(GM.PetInfoUpdate, "PetUI", "Refresh");
	-- CL.RegisterMessage(GM.PetListUpdate, "PetUI", "RefreshNoEdu");
	CL.RegisterMessage(GM.RefreshBag, "PetUI","RefreshNoEdu");
	-- CL.RegisterMessage(GM.SkillTipsNtf,"PetUI","OnSkillTipsNtf")
	-- CL.RegisterMessage(UM.CloseWhenClicked, "PetUI", "OnTipsClicked");
	CL.RegisterMessage(GM.FightPetAttrChange, "PetUI","RefreshAttrInFight");
	MainUI.AddMainUIEvt(UIDefine.UIEvent.OnPetLineUpEvt, "PetUI","RefreshPetLineUpData")
	CL.RegisterAttr(RoleAttr.RoleAttrBindGold,PetUI.RefreshOnBindGoldChange)
	-- CL.RegisterMessage(GM.SkillTipsNtf, "PetUI", "OnSkillTipNtf")
end

function PetUI.UnRegister()
	CL.UnRegisterMessage(GM.PetInfoUpdate, "PetUI", "Refresh");
	CL.UnRegisterMessage(GM.RefreshBag, "PetUI","RefreshNoEdu")
	-- CL.UnRegisterMessage(GM.RefreshBag, "PetUI", "Refresh");
  -- CL.UnRegisterMessage(GM.SkillTipsNtf,"PetUI","OnSkillTipsNtf")
	MainUI.RemoveMainUIEvt(UIDefine.UIEvent.OnPetLineUpEvt, "PetUI","RefreshPetLineUpData")
	-- CL.UnRegisterMessage(UM.CloseWhenClicked, "PetUI", "OnTipsClicked");
	CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold,PetUI.RefreshOnBindGoldChange)
	 -- CL.UnRegisterMessage(GM.SkillTipsNtf, "PetUI", "OnSkillTipNtf")
end

--突破页银币刷新
function PetUI.RefreshOnBindGoldChange(GoldType,count)	
	--突破页钱币刷新
	if PetUI.tabIndex == 3 and CurpageRefineSubTab ==2 then
		if PetUI.petGuid ~= nil then
			local PetGUID = PetUI.petGuid
			local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,PetGUID)
			local PetDB =DB.GetOncePetByKey1(id)
			local star =LD.GetPetIntCustomAttr("PetStarLevel",PetGUID,pet_container_type.pet_container_panel)
			
			local BreachCostIcon = _gt.GetUI("BreachCostIcon")
			local coin_type = UIDefine.GetMoneyEnum(UIDefine.Repair_MoneyType or 5) --MoneyType = 5
			GUI.ImageSetImageID(BreachCostIcon, UIDefine.AttrIcon[coin_type])
			
			local BreachCostText = _gt.GetUI("BreachCostText")
			local MoneyVal = 0 
			if star <= 5 then
				MoneyVal = PetUI.PetUpStarConsume["Type_"..PetDB.Type]["Star_"..star]["MoneyVal"]
			else
				MoneyVal = 0
			end
				
			
			local AttrMoney = count ~= nil and tonumber(tostring(count)) or CL.GetIntAttr(RoleAttr.RoleAttrBindGold)
			
			if AttrMoney >= MoneyVal then
				GUI.StaticSetText(BreachCostText,"<color=#ffffffff>"..MoneyVal.."</color>")
			else
				GUI.StaticSetText(BreachCostText,"<color=#FF0000>"..MoneyVal.."</color>")
			end

		end
	end
end


function PetUI.RefreshNoEdu()
	-- test("背包变化")
	--不包括养成页宠物培养技能学习时
	if PetUI.tabIndex == 2 and  CurpageEduSubTab ==1 then
		return
	elseif PetUI.tabIndex == 2 and  CurpageEduSubTab ==2 then
		return
	elseif PetUI.tabIndex == 3 and CurpageRefineSubTab == 1 then
		PetUI.RefreshClearPanel()
	elseif PetUI.tabIndex == 1 and CurAttributeSubTab ==3 then
		PetUI.EquipRefresh()
	else
		PetUI.Refresh()
	end
end

--战斗中主宠属性值的监控
function PetUI.RefreshAttrInFight()
	if CL.GetFightState() then
		if PetUI.petGuid ~= nil and UIDefine.NowLineupList then
			if tostring(PetUI.petGuid) == tostring(UIDefine.NowLineupList[0]) then
				local attrList1= {1,2}
				for i = 1, #attrList1 do
					local attrTb = petProperty[attrList1[i]]
					local text = _gt.GetUI(attrTb[2])  
					local Slider = _gt.GetUI(attrTb[6])
					local now = tostring(LD.GetFighterAttr(RoleAttr[attrTb[2]],PetUI.petGuid))
					local limt =tostring(LD.GetFighterAttr(RoleAttr[attrTb[6]],PetUI.petGuid))
					-- CDebug.LogError(aaaa)
					if limt ~= "0" and now ~= "0" then
					GUI.StaticSetText(text, tostring(LD.GetFighterAttr(RoleAttr[attrTb[2]],PetUI.petGuid)) .. "/" .. tostring(LD.GetFighterAttr(RoleAttr[attrTb[6]],PetUI.petGuid)))
					GUI.ScrollBarSetPos(Slider,tostring(LD.GetFighterAttr(RoleAttr[attrTb[2]],PetUI.petGuid))/tostring(LD.GetFighterAttr(RoleAttr[attrTb[6]],PetUI.petGuid)))
					else
					-- CDebug.LogError(tostring(LD.GetIntAttr(RoleAttr[attrTb[6]],PetUI.petGuid)))
					GUI.StaticSetText(text,  "0/" .. tostring(LD.GetPetIntAttr(RoleAttr[attrTb[6]],PetUI.petGuid)))
					GUI.ScrollBarSetPos(Slider,0)
					end
				end
	
			end
		end
	end
end

function PetUI.RefreshLevelUpPetBag_Table()
	if PetUI.LevelUpPetBag_Table then
		table.sort(PetUI.LevelUpPetBag_Table, function(a, b)
			return a < b
		end)
	end
	PetUI.Refresh()
end

function PetUI.Refresh()
	test("Refresh")
	local Btn = GUI.Get("PetUI/panelBg/tabList/AttributeTog")
	GUI.SetRedPointVisable(Btn,false)
	local tempBtn3 = _gt.GetUI("tempBtn3")
	GUI.SetRedPointVisable(tempBtn3,false)
	
	PetUI.RedPointIndex = {}
	PetUI.RedPointSite = {}

	local pageAttribute = GUI.Get(pageNames[1][2])
    local pageEdu = GUI.Get(pageNames[2][2])
    local pageRefine = GUI.Get(pageNames[3][2])
    local SynthesisSubPage = GUI.Get("PetUI/panelBg/SynthesisSubPage")
    local pagePetLineUp = GUI.Get(pageNames[5][2])
    GUI.SetVisible(pageAttribute, false)
    GUI.SetVisible(pageEdu,false )
    GUI.SetVisible(pageRefine,false )
	GUI.SetVisible(pagePetLineUp,false)
	GUI.SetVisible(SynthesisSubPage, false)
	
	if PetUI.PetListChange ==1 then
	PetUI.RefreshPetList()
	end
	if  PetUI.petGuidList then
		if PetUI.petGuidList.Count > 0 then
			local listchange = 1
			if PetUI.petGuid ~= nil then
				for i=0 , PetUI.petGuidList.Count-1 do
					if PetUI.petGuidList[i] == PetUI.petGuid then
						listchange =0
					end
				end
			end
			if PetUI.tabIndex ~= 4 and PetUI.petGuid == nil or  listchange == 1 then -- or not PetUI.petGuidList.Contains(PetUI.petGuidList, PetUI.petGuid)) then
				if PetUI.tabIndex ==2 and CurpageEduSubTab ==3 then
				PetUI.SetPetGuid(PetUI.petGuidList[RestorePetIndex])
				else
				PetUI.SetPetGuid(PetUI.petGuidList[0])
				end
			end
		else
			PetUI.SetPetGuid(nil)
		end
	else
		PetUI.PetListChange =1
		PetUI.Refresh()
	end
	-- 还原清空取消下阵的标志
	if PetUI.tabIndex ~= 5 then
		ExchangTorF = 0
	end
	-------------------------
	PetUI.RetPointAboutPet()
	PetUI.RedPointData()	
	
	PetUI.RefreshLeftPanel()
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 	
	
	if PetUI.tabIndex == 1 then
		local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel[LabelList[1][1]]
		if Level >= OpenLevel then
			GUI.SetVisible(pageAttribute, true)
			PetUI.RefreshPetModel()
			PetUI.RefreshInfoPanel()
			PetUI.RefreshTabBtnLight()
			PetUI.ShowTab(tabBtns[CurAttributeSubTab][2])
		else
			return
		end
	--养成
	elseif PetUI.tabIndex == 2 then
		-- test("养成")
		--检查是否到达等级
		local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel[LabelList[2][1]]
		if Level >= OpenLevel then
			--是否已经获得数据
			if GlobalProcessing.ShowItemList and next(GlobalProcessing.RestoreShowOrder) and  GlobalProcessing.SkillUnbindItem ~= "" then
				PetUI.RefreshPetModel()
				PetUI.RefreshInfoPanel()
				GUI.SetVisible(pageEdu, true)
				PetUI.CreateEduBase()
				PetUI.RefreshEduPetModel()
				if CurpageEduSubTab ==2 then
					PetUI.OnTabBtnClick(tabBtns2[2].guid)
				elseif CurpageEduSubTab ==3 then
					PetUI.OnTabBtnClick(tabBtns2[3].guid)
				elseif CurpageEduSubTab ==4 then
					PetUI.OnTabBtnClick(tabBtns2[4].guid)
				elseif CurpageEduSubTab ==5 then
					PetUI.OnTabBtnClick(tabBtns2[5].guid)
				else
					PetUI.OnTabBtnClick(tabBtns2[1].guid)
				end
			else
				PetUI.GetPetEduData()
			end
		else
			CL.SendNotify(NOTIFY.ShowBBMsg,tostring(OpenLevel).."级开启宠物"..LabelList[2][1].."功能。")
			PetUI.tabIndex = 1
			PetUI.Refresh()
		end
		--洗炼
	elseif  PetUI.tabIndex == 3 then
		local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel[LabelList[3][1]]
		if Level >= OpenLevel then
			if PetUI.PetUpStarConsume["Type_0"] ~= nil then
				GUI.SetVisible(pageRefine,true)
				PetUI.RefreshPetModel()
				PetUI.RefreshInfoPanel()
				if CurpageRefineSubTab == 1 then
					PetUI.OnTabBtnClick(tabBtns3[1].guid)
				elseif CurpageRefineSubTab == 2 then
					PetUI.OnTabBtnClick(tabBtns3[2].guid)
				end
			else 
				CL.SendNotify(NOTIFY.SubmitForm, "FormPetUpStar", "GetData")
			end
		else
			CL.SendNotify(NOTIFY.ShowBBMsg,tostring(OpenLevel).."级开启宠物"..LabelList[3][1].."功能。")
			PetUI.tabIndex = 1
			PetUI.Refresh()			
		end
		--合成
	elseif PetUI.tabIndex == 4 then
		local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel[LabelList[4][1]]
		if Level >= OpenLevel then
			PetUI.RefreshPetModel()
      		PetUI.RefreshInfoPanel()
     		GUI.SetVisible(SynthesisSubPage, true)
		else
			CL.SendNotify(NOTIFY.ShowBBMsg,tostring(OpenLevel).."级开启宠物"..LabelList[4][1].."功能。")
			PetUI.tabIndex = 1
			PetUI.Refresh()	
		end
		--阵容
	elseif  PetUI.tabIndex == 5 then
		GUI.SetVisible(pagePetLineUp,true)
		PetUI.RefreshPetModel()
		PetUI.RefreshInfoPanel()
		PetUI.CreatePetLineUpPage()
	end			
	
	--右侧标签
	UILayout.OnTabClick(PetUI.tabIndex, LabelList)
	
	
end


function PetUI.RefreshPetList()
		local petList = LD.GetPetGuids()
	petGuidList ={}
	petGuidList.Count = petList.Count
	

	
	for i = 0, petList.Count-1 do
		table.insert(petGuidList,tostring(petList[i]))
	end
	--按默认品质星级排序
	if 	PetSortType_Index ==1 then 
	
	elseif  PetSortType_Index ==2 then
		table.sort(petGuidList, function(a, b)
		local petId1 = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,a)))
		local petId2 = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,b)))
		local petDB1 =DB.GetOncePetByKey1(petId1)
		local petDB2 =DB.GetOncePetByKey1(petId2)
		return petDB1.Type > petDB2.Type
		end)		
	elseif PetSortType_Index ==3 then
		table.sort(petGuidList, function(a, b)
			-- local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, a);
		local star1 = LD.GetPetIntCustomAttr("PetStarLevel",a,pet_container_type.pet_container_panel)
		local star2 = LD.GetPetIntCustomAttr("PetStarLevel",b,pet_container_type.pet_container_panel)
		return star1 > star2
		end)	
	end	
	
	PetUI.petGuidList = {}

	PetUI.petGuidList.Count = petGuidList.Count
	local a = -1
	local num1 = 0
	--出战的宠物阵容
	for i=0, 4 do
		if UIDefine.NowLineupList[i] ~= "-1" then
			a= a+1
			table.insert(PetUI.petGuidList,a,UIDefine.NowLineupList[i])
			num1 = num1 +1
		end
	end
	--出战阵容以外的宠物
	for i=0,petGuidList.Count-1 do
		local petGuids = tostring(petGuidList[i+1])
		local TorF = 0
		-- if #temptable ~=0 then
		--如果有
		if num1 > 0 then
			for j =0,num1-1 do
				if petGuids ~= PetUI.petGuidList[j]  then
					TorF = 0
				else
					TorF = 1
					break
				end
			end
			if TorF == 0 then
				table.insert(PetUI.petGuidList,petGuids)
			end
		else	
			for i= 0 ,petGuidList.Count-1 do
				-- table.insert(PetUI.petGuidList,i,tostring(petGuidList[i]))
				table.insert(PetUI.petGuidList,i,tostring(petGuidList[i+1]))					
				
			end
		end
			-- else
			-- PetUI.petGuidList = LD.GetPetGuids()
			-- end
	end
	

	
	PetUI.PetListChange = 0
end
--阵容红点
function PetUI.RedPointData()
	local PetLineUpTog = GUI.Get("PetUI/panelBg/tabList/PetLineUpTog")
	local joinfightBtn = _gt.GetUI("joinfightBtn")
	local level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	-- PetUI.RedPointList = {}
	-- local count = LD.GetPetCount()
	-- GUI.SetRedPointVisable(PetLineUpTog,false)
	-- GUI.SetRedPointVisable(joinfightBtn,false)
	local mark = 0
	local num = 0 
	local num2 = 0 
	local count = LD.GetPetCount()
	for i=0 , 4 do
		if UIDefine.NowLineupList[i] == "-1" and UIDefine.UnlockLevel[i] <= level then
			mark = 1 
			num = num +1
		elseif	UIDefine.NowLineupList[i] ~= "-1" then
			num2= num2 +1
		end
	end
	if mark ==1 and count >0 and count-num2 > 0 then
		PetUI.LineUpMask = 0
		for i=0 , PetUI.petGuidList.Count-1 do
			if PetUI.LineUpMask == 0 then
				if not LD.GetPetState(PetState.Lineup,PetUI.petGuidList[i]) then
					local PetLevel = tonumber(UIDefine.GetPetLevelStrByGuid(PetUI.petGuidList[i]))
					local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,PetUI.petGuidList[i])
					local petDB =DB.GetOncePetByKey1(id)
					local death = petDB.Life ~= -1 and tonumber(LD.GetPetIntAttr(RoleAttr.PetAttrLife, PetUI.petGuidList[i])) <= 0 
					if PetLevel~= nil and PetLevel <= level + 10 and petDB.CarryLevel <= level and not death then
						PetUI.LineUpMask = 1
						GUI.SetRedPointVisable(PetLineUpTog,true)
						GUI.SetRedPointVisable(joinfightBtn,true)
					end
				end
			end
		end
		if PetUI.LineUpMask == 0 then
			GUI.SetRedPointVisable(PetLineUpTog,false)
			GUI.SetRedPointVisable(joinfightBtn,false)
		end
		if PetUI.petGuid ~= nil then
			CurPetLevel = tonumber(UIDefine.GetPetLevelStrByGuid(PetUI.petGuid))
			if CurPetLevel ~= nil and CurPetLevel > level + 10 or tonumber(PetUI.petDB.CarryLevel) > level then
				GUI.SetRedPointVisable(joinfightBtn,false)	
			end	
		end

	else
		GUI.SetRedPointVisable(PetLineUpTog,false)
		GUI.SetRedPointVisable(joinfightBtn,false)
	end
	
	GUI.ButtonSetShowDisable(joinfightBtn,true)
	if PetUI.petGuid ~= nil then
		if LD.GetPetState(PetState.Lineup,PetUI.petGuid) then
			GUI.SetRedPointVisable(joinfightBtn,false)	
			GUI.ButtonSetShowDisable(joinfightBtn,false)	
		end
	end

end

function PetUI.RetPointAboutPet()
	PetUI.RedPointList = {}
	for i=0 , PetUI.petGuidList.Count-1 do
	-- local attrName= petProperty[attrList2[i]][2]
	local str = LD.GetPetIntAttr(RoleAttr.RoleAttrRemainPoint,PetUI.petGuidList[i])
	if str ~= 0 then
		table.insert(PetUI.RedPointList,i)
	end
	
	
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(PetUI.RedPointList))
	end
	for i=0 , PetUI.petGuidList.Count-1 do
		if PetUI.RedPointEquipData(PetUI.petGuidList[i]) then
			table.insert(PetUI.RedPointList,i)
		end
	end
	
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(PetUI.RedPointSite))
	
		-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(PetUI.RedPointList))
	local tempBtn1 = _gt.GetUI("tempBtn1")
	local tempBtn3 = _gt.GetUI("tempBtn3")
	local AddPointBtn = _gt.GetUI("AddPointBtn")

	GUI.SetRedPointVisable(tempBtn1,false)
	GUI.SetRedPointVisable(AddPointBtn,false)
	
	if PetUI.petGuid ~= nil then
		if LD.GetPetIntAttr(RoleAttr.RoleAttrRemainPoint,PetUI.petGuid) ~=0 then
			GUI.SetRedPointVisable(tempBtn1,true)
			GUI.SetRedPointVisable(AddPointBtn,true)
		end
	end
	
	if PetUI.RedPointSite[PetUI.petGuid] then
	GUI.SetRedPointVisable(tempBtn3,true)
	end
	
	local Btn = GUI.Get("PetUI/panelBg/tabList/AttributeTog")
	if PetUI.RedPointList and #PetUI.RedPointList > 0 then
		if LD.GetPetIntAttr(RoleAttr.RoleAttrRemainPoint,PetUI.petGuid) ~=0 or PetUI.RedPointSite[PetUI.petGuid] then
			GUI.SetRedPointVisable(Btn,true)
		end
	end

end

function PetUI.RedPointEquipData(Key)
	-- local tempBtn = _gt.GetUI("tempBtn3")
	local Btn = GUI.Get("PetUI/panelBg/tabList/AttributeTog")
	-- GUI.SetRedPointVisable(tempBtn,false)
	PetUI.AllPetEquip = {}

	-- PetUI.RedPointSite = {}

	
	if Key ~= nil then
		--需要宠物为参战宠物
		local state = LD.GetPetState(PetState.Lineup,Key)
		if state then
			local mark = nil 
			for i =0 , #equipSiteData-1 do
				if mark == i then 
					break	
				else
					--获得已穿戴的宠物装备数据
					local equipData=LD.GetItemDataByIndex(i,item_container_type.item_container_pet_equip,Key)
					--当宠物穿戴了装备
					if equipData then
					--当宠物佩戴饰品，必定无更好的饰品红点
						if i ~= 3 then
							-- CDebug.LogError("有equipData")
							local id = equipData:GetAttr(ItemAttr_Native.Id)
							local CurItemDB = DB.GetOnceItemByKey1(id)
							local CurEquipLv = CurItemDB.Level
							local CurEquipGra = CurItemDB.Grade
							-- CDebug.LogError(PetUI.CurEquipLv)
							-- CDebug.LogError(PetUI.CurEquipGra)
						--遍历背包
							local count = LD.GetItemCount()
							for j = 0, count - 1 do
								local itemGuid = LD.GetItemGuidByItemIndex(j);
								local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
								local itemDB = DB.GetOnceItemByKey1(itemId);
									
								if itemDB.Type == 1  and itemDB.Subtype==7 and tonumber(itemDB.Subtype2) == i+1  then
									if CurEquipLv < itemDB.Level then
										local PetLevel = UIDefine.GetPetLevelStrByGuid(Key)
										if PetLevel >= itemDB.Level then
											mark = i
											if PetUI.RedPointSite[Key] then
											
											else
												PetUI.RedPointSite[Key]={}
											end
											-- CDebug.LogError(PetUI.RedPointSite)
											table.insert(PetUI.RedPointSite[Key],i)
											-- GUI.SetRedPointVisable(tempBtn,true)
											-- GUI.SetRedPointVisable(Btn,true)
											-- CDebug.LogError("1111")
										end
									elseif CurEquipLv == itemDB.Level then
										if CurEquipGra < itemDB.Grade then
											local PetLevel = UIDefine.GetPetLevelStrByGuid(Key)
											if PetLevel >= itemDB.Level then
												mark = i
												-- CDebug.LogError(PetUI.RedPointSite)
												if PetUI.RedPointSite[Key] then
											
												else
													PetUI.RedPointSite[Key]={}
												end
												table.insert(PetUI.RedPointSite[Key],i)
												-- GUI.SetRedPointVisable(tempBtn,true)
												-- GUI.SetRedPointVisable(Btn,true)
												-- CDebug.LogError("2222")
											end
										end
									end
								end
							end
						end
					--若该宠物没有佩戴装备
					else
						--除饰品以外
						if i ~= 3 then
							local count = LD.GetItemCount()
							for j = 0, count - 1 do
								local itemGuid = LD.GetItemGuidByItemIndex(j)
								local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
								local itemDB = DB.GetOnceItemByKey1(itemId)
								
								if itemDB.Type == 1  and itemDB.Subtype==7 and tonumber(itemDB.Subtype2) == i+1  then
									local PetLevel = UIDefine.GetPetLevelStrByGuid(Key)
									if PetLevel >= itemDB.Level then									
										mark = i
										if PetUI.RedPointSite[Key] then
											
										else
											PetUI.RedPointSite[Key]={}
										end
										table.insert(PetUI.RedPointSite[Key],i)
									end
								end
							end
						else
							local count = LD.GetItemCount()
							for j = 0, count - 1 do
								local itemGuid = LD.GetItemGuidByItemIndex(j)
								local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
								local itemDB = DB.GetOnceItemByKey1(itemId)
								
								if itemDB.Type == 1  and itemDB.Subtype==7 and tonumber(itemDB.Subtype2) == i+1  then
									local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,Key)
									local PetDB =DB.GetOncePetByKey1(id)
									if PetDB.TrinketKey == itemDB.KeyName then									
										mark = i
										if PetUI.RedPointSite[Key] then
											
										else
											PetUI.RedPointSite[Key]={}
										end
										table.insert(PetUI.RedPointSite[Key],i)
									end
								end
							end							
						
						end
					end	
				end
			end
		--若不为参战宠物
		else
			return
		end
	end
	
	if PetUI.RedPointSite[Key] then
		return true
	else
		return false	
	end
end



function PetUI.OnAttributeToggle()
	PetUI.tabIndex = 1
	PetUI.OnTabBtnClick(tabBtns[1].guid)
	PetUI.Refresh()
end

function PetUI.OnRefineToggle()
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel[LabelList[3][1]]
	if Level < OpenLevel then
		CL.SendNotify(NOTIFY.ShowBBMsg,OpenLevel.."级开启宠物"..LabelList[3][1].."功能。")
		UILayout.OnTabClick(PetUI.tabIndex, LabelList)	
		return
	else
		PetUI.tabIndex = 3
		if PetUI.petGuid ~= nil then
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetRefining", "GetData")
		else
			PetUI.Refresh()
		end
	end
end
function PetUI.OnEduToggle()
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel[LabelList[2][1]]
	if Level < OpenLevel then
		CL.SendNotify(NOTIFY.ShowBBMsg,OpenLevel.."级开启宠物"..LabelList[2][1].."功能。")
		UILayout.OnTabClick(PetUI.tabIndex, LabelList)	
		return
	else
		PetUI.tabIndex = 2
		PetUI.Refresh()
	end
end

function PetUI.OnPetLineUpToggle()
	if LD.GetPetCount() == 0 then
	CL.SendNotify(NOTIFY.ShowBBMsg,"您还没有宠物，请先获得一只吧。")
	PetUI.Refresh()
	else
	PetUI.tabIndex = 5
	PetUI.RefreshPetLineUpData()
	end
end
function PetUI.RefreshPetLineUpData()
	PetUI.Refresh()
	PetUI.RefreshPetLineUp()
end

function PetUI.EquipRefresh()

  for i = 1, #equipSiteData do
    local equipField = _gt.GetUI("equipField"..i);
    local add = GUI.GetChild(equipField,"add")
    ItemIcon.SetEmpty(equipField);
    if PetUI.petGuid~=nil then
		local equipData=LD.GetItemDataByIndex(equipSiteData[i].site,item_container_type.item_container_pet_equip,PetUI.petGuid)
		-- CDebug.LogError(tostring(equipSiteData[i].site))
		-- CDebug.LogError(tostring(PetUI.petGuid))
		if equipData~=nil then
			-- test(tostring(equipData.id))
			ItemIcon.BindItemData(equipField,equipData);
			GUI.SetVisible(add,false);
		else
			-- test("equipData没有")
			GUI.ItemCtrlSetElementValue(equipField, eItemIconElement.Border, "1800400050");
			GUI.ItemCtrlSetElementValue(equipField, eItemIconElement.Icon, equipSiteData[i].img);
			GUI.ItemCtrlSetElementRect(equipField, eItemIconElement.Icon, 0, -1,55,55);
			GUI.SetVisible(add,true);
		end
	  
	  
	  --红点
		  GUI.AddRedPoint(equipField,UIAnchor.TopLeft,5,5)
		  GUI.SetRedPointVisable(equipField,false)
		
		if PetUI.RedPointSite[PetUI.petGuid] then
		  for j =1, #PetUI.RedPointSite[PetUI.petGuid] do
			if i-1 == PetUI.RedPointSite[PetUI.petGuid][j] then
				GUI.SetRedPointVisable(equipField,true)
			end
		  end
		end
    else
      GUI.ItemCtrlSetElementValue(equipField, eItemIconElement.Border, "1800400050");
      GUI.ItemCtrlSetElementValue(equipField, eItemIconElement.Icon, equipSiteData[i].img);
      GUI.ItemCtrlSetElementRect(equipField, eItemIconElement.Icon, 0, -1,55,55);
      GUI.SetVisible(add,true);
    end
  end


  if PetUI.parameter then
    local site = UIDefine.GetParameter2(PetUI.parameter)
    PetUI.OpenEquipSite(site)
    PetUI.parameter=nil;
  end

end

function PetUI.RefreshInfoPanel()
	local infoGroup =  _gt.GetUI("infoGroup");
	local nameText = _gt.GetUI("nameText");
	local renameBtn = _gt.GetUI("renameBtn")
	local PetGUID = PetUI.petGuid
	-- local Btn =GUI.Get("PetUI/panelBg/tabList/AttributeTog")
	if	PetUI.tabIndex==1 or PetUI.tabIndex==5 then
		GUI.SetVisible(infoGroup, true);
		GUI.SetVisible(renameBtn,true)
		local levelText = _gt.GetUI("levelText");
		local levelFightText =_gt.GetUI("levelFightText")
		local NumFightText  =_gt.GetUI("NumFightText")
		local restBtn  =_gt.GetUI("restBtn")
		local addExpBtn = _gt.GetUI("addExpBtn")
		local RaiseBtn = _gt.GetUI("RaiseBtn")
		local AddLifeBtn = _gt.GetUI("AddLifeBtn")
		local AddPointBtn = _gt.GetUI("AddPointBtn")		
		if PetGUID ~= nil then
			GUI.SetVisible(nameText, true);
			GUI.StaticSetText(nameText, LD.GetPetName(PetGUID));
			
			GUI.SetVisible(levelText, true);
			GUI.StaticSetText(levelText,UIDefine.GetPetLevelStrByGuid( PetGUID).."级");
			  

			local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, PetGUID)
			local moban =DB.GetOncePetByKey1(id)
			-- GUI.StaticSetText(levelFightText,"角色<color=#FF0000>"..moban.CarryLevel.."</color>级");   
			-- GUI.StaticSetText(levelFightText,"角色"..moban.CarryLevel.."级");   
			local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
			if Level >= moban.CarryLevel then
				GUI.StaticSetText(levelFightText,"角色"..moban.CarryLevel.."级")
			else
				GUI.StaticSetText(levelFightText,"<color=#FF0000>角色"..moban.CarryLevel.."级</color>");   
			end
			GUI.SetVisible(levelFightText, true);
			
			GUI.SetVisible(NumFightText, true);
			GUI.StaticSetText(NumFightText,tostring(LD.GetPetAttr(RoleAttr.RoleAttrFightValue,PetGUID)) )
			
			
			-- local petData=LD.GetPetData(PetGUID)
			-- PetUI.danSkillDatas,PetUI.danEmptyCount=LogicDefine.GetPetDanSkill(petData)
			--PetUI.danMaxCount = tonumber(tostring(LD.GetPetIntCustomAttr(LogicDefine.CustomKey.PET_NeidanMax,PetGUID)))
			
			
			GUI.ButtonSetShowDisable(addExpBtn,true)
			GUI.ButtonSetShowDisable(RaiseBtn,true)
			GUI.ButtonSetShowDisable(AddLifeBtn,true)
			GUI.ButtonSetShowDisable(AddPointBtn,true)
			
			if not LD.GetPetState(PetState.Lineup,PetUI.petGuid) then
			GUI.ButtonSetShowDisable(restBtn,false)
			else 
			GUI.ButtonSetShowDisable(restBtn,true)
			end			

		else
			GUI.SetVisible(nameText, false);
			GUI.SetVisible(levelText, false);
			GUI.SetVisible(levelFightText, false);
			 
			GUI.SetVisible(renameBtn,false)
			GUI.SetVisible(NumFightText,false)
			GUI.ButtonSetShowDisable(restBtn,false)
			GUI.ButtonSetShowDisable(addExpBtn,false)
			GUI.ButtonSetShowDisable(RaiseBtn,false)
			GUI.ButtonSetShowDisable(AddLifeBtn,false)
			GUI.ButtonSetShowDisable(AddPointBtn,false)

		end
	elseif PetUI.tabIndex==2 then
			GUI.SetVisible(infoGroup, false)
			
	elseif PetUI.tabIndex==3 then
			GUI.SetVisible(infoGroup, false)
	elseif PetUI.tabIndex==4 then
			GUI.SetVisible(infoGroup, false)
	end
	if PetGUID ~= nil then
		local attrList3 = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
		for i = 1, #attrList3 do
			local attrName = petProperty[attrList3[i]][2]
			local text = _gt.GetUI(attrName)
			GUI.StaticSetText(text, LD.GetPetIntAttr(RoleAttr[attrName], PetGUID))
		end
		
		local attrList1= {1,2,3}
		for i = 1, #attrList1 do
			local attrTb = petProperty[attrList1[i]]
			local text = _gt.GetUI(attrTb[2])  
			local Slider = _gt.GetUI(attrTb[6])
			GUI.StaticSetText(_gt.GetUI(attrTb[2]), LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetGUID) .. "/" .. LD.GetPetIntAttr(RoleAttr[attrTb[6]], PetGUID))
			GUI.ScrollBarSetPos(Slider,LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetGUID)/LD.GetPetIntAttr(RoleAttr[attrTb[6]], PetGUID))
		end
		--战斗中
		if CL.GetFightState() then
			PetUI.RefreshAttrInFight()
		end
		 
		local attrList2= {4,5,6}
		for i = 1, #attrList2 do
			local attrName= petProperty[attrList2[i]][2]
			local str = LD.GetPetIntAttr(RoleAttr[attrName], PetGUID)
			if attrName == "PetAttrLife" then
				--获取宠物ID
			local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, PetGUID);
			
				--通过ID获取到宠物模板表
			local moban =DB.GetOncePetByKey1(id)
				--拿到模板表中 寿命的模板值
			  if moban.Life  == -1 then
			  str = "永生"
			  --GUI.StaticSetText(text, str)
			  end
			end
			local text = _gt.GetUI(attrName)   
			GUI.StaticSetText(text, str)
		end
	else	
		local attrList3 = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
		for i = 1, #attrList3 do
			local attrName = petProperty[attrList3[i]][2]
			local text = _gt.GetUI(attrName)
			GUI.StaticSetText(text, "")
		end
		local attrList1= {1,2,3}
		for i = 1, #attrList1 do
			local attrTb = petProperty[attrList1[i]]
			local text = _gt.GetUI(attrTb[2])  
			local Slider = _gt.GetUI(attrTb[6])
			GUI.StaticSetText(_gt.GetUI(attrTb[2]), "")
			GUI.ScrollBarSetPos(Slider, 1)
		end
		local attrList2= {4,5,6}
		for i = 1, #attrList2 do
			local attrName= petProperty[attrList2[i]][2]
			local text = _gt.GetUI(attrName)   
			GUI.StaticSetText(text, "")
		end		
		
		
	end
end

function PetUI.skillRefresh()
    local tabAptitudeAndSkillsPanel = _gt.GetUI("tabAptitudeAndSkillsPanel")
    -- if	PetUI.tabIndex<=5 then
	if tabAptitudeAndSkillsPanel == nil then
		GUI.SetVisible(tabAptitudeAndSkillsPanel, true)
	end
	local attrList4 = {17,18,19,20,21,22,23,24}
	
	if PetUI.petGuid~=nil then
		local skillScroll =_gt.GetUI("skillScroll")
		GUI.LoopScrollRectSetTotalCount(skillScroll,math.max(math.ceil((GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid)+1)/4)*4, 8) )
			
		GUI.LoopScrollRectRefreshCells(skillScroll)
		-- local curCount = GUI.LoopScrollRectGetChildInPoolCount(skillScroll)
		-- local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid)
		local attrList4 = { 17, 18, 19, 20, 21, 22, 23, 24 }

		for i = 1 , #attrList4 do
			local attrTb= petProperty[attrList4[i]]
			local currentTxt = _gt.GetUI(attrTb[2])
			local tempSlider = _gt.GetUI(attrTb[6])
			if i ~=7 and i ~=8 then
				GUI.StaticSetText(currentTxt, (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid)) .. "/" ..(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid,pet_container_type.pet_container_panel)))
				GUI.ScrollBarSetPos(tempSlider,(LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))/(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid,pet_container_type.pet_container_panel)))
			else
				GUI.StaticSetText(currentTxt,LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid) .. "/" ..PetUI.petDB[attrTb[6]])
				GUI.ScrollBarSetPos(tempSlider,(LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))/(PetUI.petDB[attrTb[6]]))
			end
		end	
	else
		local skillScroll =_gt.GetUI("skillScroll")
		GUI.LoopScrollRectSetTotalCount(skillScroll, 8) 
		GUI.LoopScrollRectRefreshCells(skillScroll)
	end
	-- end
		  
  

end



function PetUI.RefreshLeftPanel()	
	local petScroll = _gt.GetUI("petScroll");
	local titleText = _gt.GetUI("titleText");
	local petNumText = _gt.GetUI("petNumText");
	-- if PetUI.tabIndex<=5 then
	GUI.StaticSetText(titleText,"我的宠物")
	GUI.SetVisible(petNumText,true);
	GUI.StaticSetText(petNumText, LD.GetPetCount() .. "/" .. LD.GetPetCapacity())

	GUI.SetVisible(petScroll,true);
	GUI.LoopScrollRectSetTotalCount(petScroll, LogicDefine.PetMaxLimit);
	GUI.LoopScrollRectRefreshCells(petScroll);
	
	-- end
end

function PetUI.GetPetModel()
	return _gt.GetUI("petModel");
end
function PetUI.OnShowPetEquipEffect(petModel, bShow, trinketEffectID)
	if petModel then
		trinketEffectID = trinketEffectID or 0
		if bShow == 1 then
			local preTrinketEff = GUI.GetData(petModel, "trinketEff")
			-- if preTrinketEff ~= tostring(trinketEffectID) then
				local preEffectID = tonumber(GUI.GetData(petModel, "effectID"))
				if preEffectID and preEffectID ~= 0 then
					GUI.DestroyRoleEffect(petModel, preEffectID)
				end
				local effectID = GUI.CreateRoleEffect(petModel, trinketEffectID)
				GUI.SetData(petModel, "effectID", effectID)
				GUI.SetData(petModel, "trinketEff", tostring(trinketEffectID))
			-- end
		else
			local effectID = tonumber(GUI.GetData(petModel, "effectID"))
			if effectID and effectID ~= 0 then
				GUI.DestroyRoleEffect(petModel, effectID)
				GUI.SetData(petModel, "trinketEff", "")
			end
		end
	end
end

function PetUI.RefreshPetModel()  -----宠物的展示和模型
	local petModel = GUI.GetByGuid(_gt.petModel);
	local petModelGroup =  _gt.GetUI("petModelGroup")
	local EduPetModelGroup =  _gt.GetUI("EduPetModelGroup")
	local model = _gt.GetUI("model")
	local showBtn = _gt.GetUI("showBtn")
	local petTypeLabel = _gt.GetUI("petTypeLabel")
	local bindLabel = _gt.GetUI("bindLabel")
	local lockBtn = _gt.GetUI("lockBtn")
	local shadow = _gt.GetUI("shadow")
	local petTipBtn = _gt.GetUI("petTipBtn")
	local petTipBtn3 = _gt.GetUI("petTipBtn3")
	local deletePetBtn = _gt.GetUI("deletePetBtn")
	local modelBg = _gt.GetUI("modelBg")
	local modelBg2 = _gt.GetUI("modelBg2")
	local Petname =  _gt.GetUI("Petname")
	local AutoAttackBtn = _gt.GetUI("AutoAttackBtn")
	if PetUI.petGuid ~= nil then			
		if PetUI.tabIndex ==1 or  PetUI.tabIndex ==5 then
			GUI.SetVisible(EduPetModelGroup,false)
			GUI.SetPositionX(model,0)
			-- GUI.SetPositionY(model,-150)
				
				
			GUI.SetVisible(AutoAttackBtn,true)
			GUI.SetVisible(modelBg,true)
			GUI.SetVisible(modelBg2,false)
			GUI.SetVisible(petTipBtn,true)
			GUI.SetVisible(petTipBtn3,false)
			GUI.SetVisible(deletePetBtn,true)
				-- GUI.SetVisible(AutoAttack_bg,true)
				
			GUI.SetPositionX(shadow,-10)
			GUI.SetPositionY(shadow,-60)
				
				
			local isBind = LD.GetPetState(PetState.Bind, PetUI.petGuid)
			GUI.SetVisible(bindLabel, isBind)
			GUI.SetPositionX(bindLabel,-100)
			GUI.SetPositionY(bindLabel,-200)

			local isShow = LD.GetPetState(PetState.Show, PetUI.petGuid)
			GUI.SetVisible(showBtn, true)
			if isShow then
					GUI.ButtonSetText(showBtn, "回收展示");
			else
					GUI.ButtonSetText(showBtn, "展示宠物");
			end
			local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, PetUI.petGuid)
			local moban =DB.GetOncePetByKey1(id)
			GUI.ImageSetImageID(petTypeLabel, UIDefine.PetType[moban.Type])
			GUI.SetPositionX(petTypeLabel,120)
			GUI.SetPositionY(petTypeLabel,-200)
				
			GUI.SetVisible(Petname,false)
			local star =LD.GetPetIntCustomAttr("PetStarLevel",PetUI.petGuid,pet_container_type.pet_container_panel)
			for i = 1 ,6 do
				local StarLevel = GUI.GetChild(petModelGroup,"StarLevel"..i)
				GUI.SetVisible(StarLevel,true)
				GUI.ImageSetImageID(StarLevel,"1801202192")
				GUI.SetPositionX(StarLevel,-90+(i*25))-- -90+
				GUI.SetPositionY(StarLevel,-10)
			end
			for i = 1 ,star do
				local StarLevel = GUI.GetChild(petModelGroup,"StarLevel"..i)
				GUI.ImageSetImageID(StarLevel,"1801202190")
			end
			local isLock = LD.GetPetState(PetState.Lock, PetUI.petGuid)
			local img = "1800707020"
			if isLock == true then
				img = "1800707020"
			else
				img = "1800707080"
			end

			--宠物模型Y轴
			local Offset = ModelOffsetConfig[tostring(moban.Model)] or 0
			GUI.SetPositionY(model, -150 + Offset)
			
			GUI.SetVisible(lockBtn, true)
			GUI.ButtonSetImageID(lockBtn, img)
			GUI.SetVisible(petModelGroup,true)
		end
		if PetUI.tabIndex ==2 then
			GUI.SetVisible(petModelGroup,false)
			GUI.SetVisible(EduPetModelGroup,true)
		end
		if PetUI.tabIndex ==3 then
			GUI.SetVisible(petModelGroup,true)
			GUI.SetVisible(EduPetModelGroup,false)
			GUI.SetPositionX(model,-10)
			-- GUI.SetPositionY(model,-170)
			GUI.SetVisible(AutoAttackBtn,false)
			GUI.SetVisible(modelBg,false)
			GUI.SetVisible(modelBg2,true)
			GUI.SetVisible(lockBtn, false)
			GUI.SetVisible(petTipBtn,false)
			GUI.SetVisible(petTipBtn3,true)
			GUI.SetVisible(deletePetBtn,false)
				-- GUI.SetVisible(AutoAttack_bg,false)
				
			GUI.SetPositionX(shadow,-20)
			GUI.SetPositionY(shadow,-70)
				
			local isBind = LD.GetPetState(PetState.Bind, PetUI.petGuid)
			GUI.SetVisible(bindLabel, isBind)
			GUI.SetPositionX(bindLabel,-135)
			GUI.SetPositionY(bindLabel,-240)
				
			GUI.SetVisible(showBtn, false)
				
			local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, PetUI.petGuid)
			local moban =DB.GetOncePetByKey1(id)
			GUI.ImageSetImageID(petTypeLabel, UIDefine.PetType[moban.Type])
			GUI.SetPositionX(petTypeLabel,140)
			GUI.SetPositionY(petTypeLabel,-230)
				
			GUI.SetVisible(Petname,true)
			GUI.StaticSetText(Petname,moban.Name)

			--宠物模型Y轴
			local Offset = ModelOffsetConfig[tostring(moban.Model)] or 0
			GUI.SetPositionY(model, -170 + Offset)				
				-- local star =LD.GetPetIntCustomAttr("PetStarLevel",PetUI.petGuid,pet_container_type.pet_container_panel)
		end
			
            if PetUI.tabIndex == 4 then
                GUI.SetVisible(petModelGroup, false)
                GUI.SetVisible(infoGroup, false)
                if visible == 1 then
                    PetUI.RefreshBasePet()
                else
                    PetUI.RefreshBasePet2()
                end
            end
			
		if 	PetUI.tabIndex ~= 2 and PetUI.tabIndex ~= 4 then
			GUI.SetVisible(petModel, true);
			GUI.SetVisible(petTypeLabel, true);
			GUI.SetVisible(shadow, true)
			-- CDebug.LogError(tostring(PetUI.petGuid))
			local haveEffect = LD.GetPetIntCustomAttr("PetEquip_HasTrinket",PetUI.petGuid)
			if LastPetGuid ~= PetUI.petGuid or not PetUI.LastEffect or PetUI.LastEffect ~= haveEffect then
				ModelItem.Bind(petModel, tonumber(PetUI.petDB.Model),LD.GetPetIntAttr(RoleAttr.RoleAttrColor1,PetUI.petGuid ),0,eRoleMovement.ATTSTAND_W1)
			--显示饰品特效
				PetUI.OnShowPetEquipEffect(petModel, haveEffect, TOOLKIT.Str2uLong(PetUI.petDB.TrinketEff))
				PetUI.LastEffect = haveEffect
				LastPetGuid = PetUI.petGuid

				if LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid) ~= "" then
					GUI.RefreshDyeSkinJson(petModel, LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid), "")
				end				
			end
				local AutoSkillID = LD.GetPetIntCustomAttr("__auto_c_si", PetUI.petGuid)
				
				-- test("AutoSkillID： "..AutoSkillID)
				if AutoSkillID ==0 then
					AutoSkillID = 1
				end
				local AutoAttackIcon = GUI.GetChild(AutoAttackBtn,"AutoAttackIcon")
				local skillDB =DB.GetOnceSkillByKey1(AutoSkillID)
				local tempStr = tostring(skillDB.Icon)
				local iconStr = (AutoSkillID == 1 or AutoSkillID == 2) and tempStr or string.sub(tempStr, 1, -2) .. "3"
				GUI.ImageSetImageID(AutoAttackIcon, iconStr)
				
		end
	else
		if PetUI.tabIndex ==1  then
			GUI.SetVisible(petModelGroup,true)
			GUI.SetVisible(EduPetModelGroup,false)
			GUI.SetVisible(petModel, false)
			GUI.SetVisible(modelBg2,false)
			GUI.SetVisible(petTypeLabel, false);
			GUI.SetVisible(bindLabel, false);
			GUI.SetVisible(showBtn, false);
			GUI.SetVisible(petTipBtn3,false)
			GUI.SetVisible(AutoAttackBtn,false)
			for i = 1 ,6 do
				local StarLevel = GUI.GetChild(petModelGroup,"StarLevel"..i)
				GUI.SetVisible(StarLevel,false)
			end
			GUI.SetVisible(shadow,false)
			GUI.SetVisible(Petname,false)
			GUI.SetVisible(lockBtn,false) 
		elseif PetUI.tabIndex ==2 then
			GUI.SetVisible(petModelGroup,false)
			GUI.SetVisible(EduPetModelGroup,true)
			
		elseif PetUI.tabIndex ==3 then
				-- GUI.SetVisible(petModel, false)
			GUI.SetVisible(petModelGroup,true)
			GUI.SetVisible(EduPetModelGroup,false)
			GUI.SetVisible(modelBg2,true)
			GUI.SetVisible(petTypeLabel,true);
			GUI.SetPositionX(petTypeLabel,140)
			GUI.SetPositionY(petTypeLabel,-230)				
			GUI.SetVisible(bindLabel,true);
			GUI.SetPositionX(bindLabel,-135)
			GUI.SetPositionY(bindLabel,-240)
				-- GUI.SetVisible(showBtn, false);
			GUI.SetVisible(petTipBtn3,true)
				-- GUI.SetVisible(AutoAttackBtn,false)
				-- GUI.SetVisible(shadow,false)
				-- GUI.SetVisible(Petname,false)
				-- GUI.SetVisible(lockBtn,false)
			GUI.SetVisible(deletePetBtn,false)
			GUI.SetVisible(petTipBtn,false)
		elseif PetUI.tabIndex == 4 then
			GUI.SetVisible(petModelGroup, false)
			GUI.SetVisible(infoGroup, false)
			GUI.SetVisible(EduPetModelGroup,false)
		end
	end
	-- end
end


function PetUI.OnAttrTabBtnClick()
	PetUI.tabIndex = 1;
	PetUI.Refresh() 
end


function PetUI.OnCloseBtnClick(guid)
	PetUI.ResetData()
	PetUI.UnRegister()
	GUI.CloseWnd("PetUI")
end

function PetUI.ResetData()
    local wnd = GUI.GetWnd("PetUI")
    GUI.SetVisible(wnd, false)
	PetUI.tabIndex = 1
	CurAttributeSubTab = 1
	if PetUI.petGuidList and PetUI.petGuidList.Count >0 then
		PetUI.SetPetGuid(PetUI.petGuidList[0])
	end
	local petScroll = _gt.GetUI("petScroll")
	GUI.ScrollRectSetNormalizedPosition(petScroll,Vector2.New(0,0))
	PetUI.Refresh()
end
	

function PetUI.CreateBase(panelBg)
	local petModelGroup = GUI.GroupCreate(panelBg, "petModelGroup", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg));
	_gt.BindName(petModelGroup, "petModelGroup");
	
---宠物龙背景
	local modelBg = GUI.ImageCreate(petModelGroup, "modelBg", "1800400230", 0, -120);
	_gt.BindName(modelBg,"modelBg")
---炼化页宠物模型背景
	local modelBg2 = GUI.ImageCreate(petModelGroup, "modelBg2", "1800700120", -10, -145);
	_gt.BindName(modelBg2,"modelBg2")
	GUI.SetVisible(modelBg2,false)
	
  --宠物阴影
	local shadow = GUI.ImageCreate(petModelGroup, "shadow", "1800400240", -10, -60);
	_gt.BindName(shadow,"shadow")
	GUI.SetVisible(shadow,false)
	
  
----宠物模型
	local model = GUI.RawImageCreate(petModelGroup, false, "model", "", 0, -130, 50, false, 560, 560)
	_gt.BindName(model, "model");
	model:RegisterEvent(UCE.Drag)
	GUI.AddToCamera(model);
	GUI.RawImageSetCameraConfig(model, "(1.65,1.4,2),(-0.04464257,0.9316535,-0.1226545,-0.3390941),True,5,0.01,1.95,1E-05");
	model:RegisterEvent(UCE.PointerClick)
	GUI.RegisterUIEvent(model, UCE.PointerClick, "PetUI", "OnModelClick")
	local petModel = GUI.RawImageChildCreate(model, true, "petModel", "", 0, 0)
	_gt.BindName(petModel, "petModel");
	GUI.BindPrefabWithChild(model, GUI.GetGuid(petModel))
	GUI.RegisterUIEvent(petModel, ULE.AnimationCallBack, "PetUI", "OnAnimationCallBack")
	
	
--星级
	for i =1 ,6 do
	local StarLevel = GUI.ImageCreate(petModelGroup, "StarLevel"..i, "1801202192", -90+(i*25), -10,false,30,30)
	GUI.SetVisible(StarLevel,false)
	end
	
	

	-- 锁定按钮
	local lockBtn = GUI.ButtonCreate( petModelGroup, "lockBtn", "1800707080", 120, -140, Transition.ColorTint)  
	SetAnchorAndPivot(lockBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(lockBtn, UCE.PointerClick, "PetUI", "OnLockBtnClick")
	GUI.SetVisible(lockBtn,false)
	_gt.BindName(lockBtn, "lockBtn")
	
	---左上角tips
	local petTipBtn = GUI.ButtonCreate( petModelGroup, "petTipBtn", "1800702030", -125 , -250 , Transition.ColorTint)
	SetAnchorAndPivot(petTipBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(petTipBtn, UCE.PointerClick, "PetUI", "OnPetTipBtnClick")	
	_gt.BindName(petTipBtn, "petTipBtn")
	--炼化页左下角tips
	local petTipBtn3 = GUI.ButtonCreate( petModelGroup, "petTipBtn3", "1800702030", -125 , -40 , Transition.ColorTint)
	SetAnchorAndPivot(petTipBtn3, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(petTipBtn3, UCE.PointerClick, "PetUI", "OnPetTipBtn3Click")	
	_gt.BindName(petTipBtn3, "petTipBtn3")
	GUI.SetVisible(petTipBtn3,false)
	
	---已绑定
	local bindLabel = GUI.ImageCreate(petModelGroup, "bindLabel", "1800704050", -100, -200);
	_gt.BindName(bindLabel, "bindLabel");
	GUI.SetVisible(bindLabel,false)
	

	
	---放生按钮
	local deletePetBtn = GUI.ButtonCreate(petModelGroup, "deleteBtn", "1801202210", -125, -30, Transition.ColorTint)
    GUI.RegisterUIEvent(deletePetBtn, UCE.PointerClick, "PetUI", "OnFreePetBtnClick")
	_gt.BindName(deletePetBtn, "deletePetBtn")
	
	--自动攻击技能选择
	local AutoAttackBtn = GUI.ButtonCreate(petModelGroup, "AutoAttackBtn","1800802030", 130, -30,Transition.ColorTint,"",68, 68,false)
	GUI.RegisterUIEvent(AutoAttackBtn, UCE.PointerClick, "PetUI", "OnAutoAttackBtnClick")
	GUI.ButtonSetPressedColor(AutoAttackBtn, Color.New(1, 1, 1, 1))
	GUI.SetVisible(AutoAttackBtn,false)
	local AutoAttackIcon = GUI.ImageCreate(AutoAttackBtn,"AutoAttackIcon", "1800302210", 0, -2, false, 53, 53)
	_gt.BindName(AutoAttackBtn,"AutoAttackBtn")
	local AutoAttackCat = GUI.ImageCreate(AutoAttackBtn,"AutoAttackCat", "1800807060", 20, -20,false,25,25)

	-- 宠物类型
	local petTypeLabel = GUI.ImageCreate(petModelGroup, "petTypeLabel", "1800704040", 120, -200)
	_gt.BindName(petTypeLabel, "petTypeLabel");		
	GUI.SetVisible(petTypeLabel,false)
	
	local Petname = GUI.CreateStatic(petModelGroup,"Petname","",-15,15,800,200)
	GUI.SetColor(Petname, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Petname, 24)
	GUI.StaticSetAlignment(Petname, TextAnchor.MiddleCenter)
	_gt.BindName(Petname, "Petname")


	
    ---展示按钮
	local showBtn = GUI.ButtonCreate(petModelGroup, "showBtn", "1800402110", 0, 40, Transition.ColorTint, "展示宠物", 120, 45, false);
	GUI.ButtonSetTextColor(showBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(showBtn, UIDefine.FontSizeS)
	_gt.BindName(showBtn, "showBtn");
	GUI.RegisterUIEvent(showBtn, UCE.PointerClick, "PetUI", "OnShowBtnClick");
	GUI.SetVisible(showBtn,false)

   ----左侧
	local petListBg = GUI.ImageCreate(panelBg, "petListBg", "1800400200", -355, 10, false, 335, 565);
	UILayout.SetSameAnchorAndPivot(petListBg, UILayout.Center);
	_gt.BindName(petListBg,"petListBg")

	local titleBg = GUI.ImageCreate(petListBg, "titleBg", "1800700070", 0, 0, false, 332, 40);
	UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top);

	local titleText = GUI.CreateStatic(titleBg, "titleText", "我的宠物", 15, 0, 100, 30);
	GUI.SetColor(titleText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(titleText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(titleText, UILayout.Left);
	_gt.BindName(titleText, "titleText");
	
	local petNumText = GUI.CreateStatic(titleBg, "petNumText", "0/18", 130, 0, 100, 30);
	GUI.SetColor(petNumText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(petNumText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(petNumText, TextAnchor.MiddleRight);
	UILayout.SetSameAnchorAndPivot(petNumText, UILayout.Left);
	_gt.BindName(petNumText, "petNumText");
	------滚动框
	local petScroll = GUI.LoopScrollRectCreate(petListBg, "petScroll", 0, 42, 330, 515,
    "PetUI", "CreatePetItemPool", "PetUI", "RefreshPetScroll", 0, false,
	Vector2.New(325, 100), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(petScroll, UILayout.Top);
	_gt.BindName(petScroll, "petScroll");
	
	
	-- 选择下拉菜单
    local rightTitle_Bg = GUI.ButtonCreate( petListBg, "rightTitle_Bg", "1800700260", 0, 0, Transition.None,nil,95,39,false)
    SetAnchorAndPivot(rightTitle_Bg, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(rightTitle_Bg, UCE.PointerClick, "PetUI", "OnPullListBtnClick")

    local pullListBtn = GUI.ImageCreate( rightTitle_Bg, "pullListBtn", "1800707070", 12, 0)
    SetAnchorAndPivot(pullListBtn, UIAnchor.Right, UIAroundPivot.Right)
    GUI.SetIsRaycastTarget(pullListBtn, false)

    local petSortType_Txt = GUI.CreateStatic(rightTitle_Bg, "petSortType_Txt", "<color=#662F16><size=20>默认</size></color>", -15, 2, 100, 100, "system", true)
    SetAnchorAndPivot(petSortType_Txt, UIAnchor.Left, UIAroundPivot.Left)
	GUI.StaticSetFontSize(petSortType_Txt, 22)
    -- 创建宠物类型按钮选择列表
    local petSortType_Bg = GUI.ImageCreate( rightTitle_Bg, "petSortType_Bg", "1800400290", 0, 36, false, 115, 115)
    SetAnchorAndPivot(petSortType_Bg, UIAnchor.Top, UIAroundPivot.Top)

    local childSize_petSortType = Vector2.New(105,34)
    local src_petSortType = GUI.ScrollRectCreate( petSortType_Bg, "src_petSortType", 0, 0, 105, 104, 0, false, childSize_petSortType, UIAroundPivot.Top, UIAnchor.Top)
    SetAnchorAndPivot(src_petSortType, UIAnchor.Center, UIAroundPivot.Center)

    for i = 1, #petSortType do
    local btn = GUI.ButtonCreate( src_petSortType, i - 1, "1800600100", 0, 0, Transition.ColorTint, "<color=#662F16><size=20>" .. petSortType[i][1] .. "</size></color>", 105, 32, false)
    GUI.SetData(btn, "sortType", petSortType[i][2])
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "PetUI", "OnPetSortTypeBtnClick")
    end
    GUI.ScrollRectSetVertical(src_petSortType, false)
    GUI.SetVisible(petSortType_Bg, false)
	
    
	local infoGroup = GUI.GroupCreate(panelBg, "infoGroup", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg));
	_gt.BindName(infoGroup, "infoGroup")


	local nameArea = GUI.CreateStatic(infoGroup, "nameArea", "名       称", -75, 90, 200, 50);
	SetAnchorAndPivot(nameArea, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(nameArea, TextAnchor.MiddleLeft)
	GUI.SetColor(nameArea, UIDefine.BrownColor);
	GUI.StaticSetFontSize(nameArea, 24)

	local bg = GUI.ImageCreate(nameArea, "bg", "1800700010", 120, 1, false, 230, 36);

	local nameText = GUI.CreateStatic(bg, "nameText", "", 0, -1, 200, 35);
	GUI.SetColor(nameText, UIDefine.White2Color);
	GUI.StaticSetFontSize(nameText, UIDefine.FontSizeM);
	GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter);
	_gt.BindName(nameText, "nameText")

	local renameBtn = GUI.ButtonCreate(bg, "renameBtn", "1800402120", 100, -1, Transition.ColorTint);
	_gt.BindName(renameBtn, "renameBtn")
	GUI.SetVisible(renameBtn, false)
	GUI.RegisterUIEvent(renameBtn, UCE.PointerClick, "PetUI", "OnRenameBtnClick");
	

	local levelArea = GUI.CreateStatic(infoGroup, "levelArea", "等       级", -75, 130, 200, 50);
	SetAnchorAndPivot(levelArea, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(levelArea, TextAnchor.MiddleLeft)
	GUI.SetColor(levelArea, UIDefine.BrownColor);
	GUI.StaticSetFontSize(levelArea, 24)

	local bg = GUI.ImageCreate(levelArea, "bg", "1800700010", 120, 1, false, 230, 36);

	local levelText = GUI.CreateStatic(bg, "levelText", "", 0, -1, 200, 35);
	GUI.SetColor(levelText, UIDefine.White2Color);
	GUI.StaticSetFontSize(levelText, UIDefine.FontSizeM);
	GUI.StaticSetAlignment(levelText, TextAnchor.MiddleCenter);
	_gt.BindName(levelText, "levelText")

	local levelFight = GUI.CreateStatic(infoGroup, "levelFight", "参战等级", -75, 170, 200, 50);
	SetAnchorAndPivot(levelFight, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(levelFight, TextAnchor.MiddleLeft)
	GUI.SetColor(levelFight, UIDefine.BrownColor);
	GUI.StaticSetFontSize(levelFight, 24)

	local bg = GUI.ImageCreate(levelFight, "bg", "1800700010", 120, 1, false, 230, 36);

	local levelFightText = GUI.CreateStatic(bg, "levelFightText", "", 0, -1, 200, 35,"system",true);
	GUI.SetColor(levelFightText, UIDefine.White2Color);
	GUI.StaticSetFontSize(levelFightText, UIDefine.FontSizeM);
	GUI.StaticSetAlignment(levelFightText, TextAnchor.MiddleCenter);
	_gt.BindName(levelFightText, "levelFightText")


	local NumFight = GUI.CreateStatic(infoGroup, "NumFight", "战       力", -75, 210, 200, 50);
	SetAnchorAndPivot(NumFight, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(NumFight, TextAnchor.MiddleLeft)
	GUI.SetColor(NumFight, UIDefine.BrownColor);
	GUI.StaticSetFontSize(NumFight, 24)

	local bg = GUI.ImageCreate(NumFight, "bg", "1800700010", 120, 1, false, 230, 36);

	local NumFightText = GUI.CreateStatic(bg, "NumFightText", "", 0, -1, 200, 50);
	GUI.SetColor(NumFightText, UIDefine.White2Color);
	GUI.StaticSetFontSize(NumFightText, UIDefine.FontSizeM);
	GUI.StaticSetAlignment(NumFightText, TextAnchor.MiddleCenter);
	_gt.BindName(NumFightText, "NumFightText")
	
	local handBookBtn = GUI.ButtonCreate( infoGroup, "handBookBtn", "1801502130", -125, 255, Transition.ColorTint)
    SetAnchorAndPivot(handBookBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(handBookBtn, true)
    GUI.RegisterUIEvent(handBookBtn, UCE.PointerClick, "PetUI", "OnHandBookBtnClick")

    local handBookTextImg = GUI.ImageCreate( handBookBtn, "handBookTextImg", "1801504270", 0, 23)
    SetAnchorAndPivot(handBookTextImg, UIAnchor.Center, UIAroundPivot.Center)
	
---------------------------------------------------------------------------------------------------------------------	
	local AttributePanel = GUI.GroupCreate( panelBg, "AttributePanel",0, 0, 0, 0)
    SetAnchorAndPivot(AttributePanel, UIAnchor.Center, UIAroundPivot.Center)
	-- parent = AttributePanel
	
    -- 创建各分页按钮
    local btnWidth = 115
    local btnHeight = 43
    for i = 1, #tabBtns do
		local tempBtn = GUI.ButtonCreate( AttributePanel, tabBtns[i][2], "1800402030", 177.5 + (i - 1) * btnWidth, -280, Transition.None, "", btnWidth, btnHeight, false)
        SetAnchorAndPivot(tempBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
		tabBtns[i].guid = GUI.GetGuid(tempBtn)
		_gt.BindName(tempBtn,"tempBtn"..i)
        local btnSprite = GUI.ImageCreate( tempBtn, "btnSprite", "1800402032", 0, 0, false, btnWidth, btnHeight)
        SetAnchorAndPivot(btnSprite, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetVisible(btnSprite, false)
		GUI.AddRedPoint(tempBtn,UIAnchor.TopLeft,5,5)
		GUI.SetRedPointVisable(tempBtn,false)

        local labelTxt = GUI.CreateStatic( tempBtn, tabBtns[i][2] .. "label", tabBtns[i][1], 0, 0, btnWidth, btnHeight, "system", true, false)
        SetAnchorAndPivot(labelTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(labelTxt, fontSizeDefault)
        GUI.StaticSetAlignment(labelTxt, TextAnchor.MiddleCenter)
        GUI.SetColor(labelTxt, colorDark)
        --GUI.AddRedPoint(tempBtn,UIAnchor.TopLeft,11,11)
        --GUI.SetRedPointVisable(tempBtn,false);

        GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "PetUI", "OnTabBtnClick")
    end
	
    ---if LD.GetPetCount() > 0 then
    ----    PetUI.OnPetItemClick("PetItem" .. selectIndex)
---------------------------------------------------------------------------------------------------------------------------------

	


----------------------------------------------------------------------------------------------------------------------------------------
	local pageRefinePanel = GUI.GroupCreate( panelBg, "pageRefinePanel",0, 0, 0, 0)
    SetAnchorAndPivot(pageRefinePanel, UIAnchor.Center, UIAroundPivot.Center)
	-- parent = pageRefinePanel
	
    -- 创建各分页按钮
    local btnWidth = 115
    local btnHeight = 43
    for i = 1, #tabBtns3 do
		local tempBtn = GUI.ButtonCreate( pageRefinePanel, tabBtns3[i][2], "1800402030", 285 + (i - 1) * btnWidth, -280, Transition.None, "", btnWidth, btnHeight, false)
        SetAnchorAndPivot(tempBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
		tabBtns3[i].guid = GUI.GetGuid(tempBtn)
        local btnSprite = GUI.ImageCreate( tempBtn, "btnSprite", "1800402032", 0, 0, false, btnWidth, btnHeight)
        SetAnchorAndPivot(btnSprite, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetVisible(btnSprite, false)

        local labelTxt = GUI.CreateStatic( tempBtn, tabBtns3[i][2] .. "label", tabBtns3[i][1], 0, 0, btnWidth, btnHeight, "system", true, false)
        SetAnchorAndPivot(labelTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(labelTxt, fontSizeDefault)
        GUI.StaticSetAlignment(labelTxt, TextAnchor.MiddleCenter)
        GUI.SetColor(labelTxt, colorDark)
        --GUI.AddRedPoint(tempBtn,UIAnchor.TopLeft,11,11)
        --GUI.SetRedPointVisable(tempBtn,false);

        GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "PetUI", "OnTabBtnClick")
    end	

	PetUI.OnTabBtnClick(tabBtns[1].guid)
------------------------------------------------------------------------------------------------------------------------------------	
    -- PetUI.OnTabBtnClick(tabBtns[1].guid)
end

function PetUI.RefreshTabBtnLight()
    for i = 1, #tabBtns do
        local sprite = GUI.Get("PetUI/panelBg/AttributePanel/" .. tabBtns[i][2] .. "/btnSprite")    ----pageAttribute/
		GUI.SetVisible(sprite,CurAttributeSubTab == i )
    end
end


function PetUI.OnTabBtnClick(guid)
	local key = GUI.GetName(GUI.GetByGuid(guid))
    -- 高亮图显示
    --local spriteList = {}
    for i = 1, #tabBtns do
        local sprite = GUI.Get("PetUI/panelBg/AttributePanel/" .. tabBtns[i][2] .. "/btnSprite")    ----pageAttribute/
		GUI.SetVisible(sprite, tabBtns[i].guid == guid)
    end
	
	for i = 1, #tabBtns2 do
        local sprite = GUI.Get("PetUI/panelBg/pageEduPanel/" .. tabBtns2[i][2] .. "/btnSprite")    ----pageAttribute/
		GUI.SetVisible(sprite, tabBtns2[i].guid == guid)
    end
	
	
	for i = 1, #tabBtns3 do
        local sprite = GUI.Get("PetUI/panelBg/pageRefinePanel/" .. tabBtns3[i][2] .. "/btnSprite")    ----pageAttribute/
		GUI.SetVisible(sprite, tabBtns3[i].guid == guid)
    end
	

    -- 显示选项卡
	PetUI.ShowTab(key)
end


-- 显示选项卡
function PetUI.ShowTab(key)
    local tabAttributePanel = GUI.Get(tabNames[1][2])
    local tabAptitudeAndSkillsPanel = GUI.Get(tabNames[2][2])
    local tabEquipmentPanel = GUI.Get(tabNames[3][2])
	local tabClearPanel = GUI.Get(tabNames[9][2])
	local tabBreachPanel = GUI.Get(tabNames[10][2])
	local pageRefinePanel = GUI.Get(pageNames[3][2])
    -- 宠物属性
    if key == tabBtns[1][2] then
		CurAttributeSubTab = 1
        PetUI.CreateAttributeTab(key)
		
     ---local petInfo = LD.GetPetData(
     ---PetUI.SetPetAttrInfo(petInfo)
        -- 资质技能
    elseif key == tabBtns[2][2] then
		CurAttributeSubTab = 2
	    PetUI.CreateAptitudeAndSkillsTab()
       -- PetUI.SetPetAptitudeAndSkillsInfo()
        -- 宠物装备
    elseif key == tabBtns[3][2] then
        -- 加载所有宠物装备
       --- LD.LoadAllPetEquipment()
	   CurAttributeSubTab = 3
        PetUI.CreateEquipmentTab()
		PetUI.EquipRefresh()
      ---  PetUI.SetPetEquipmentInfo()
	elseif key == tabBtns2[1][2] then 
	CurpageEduSubTab = 1
	PetUI.CreateTrainingTab()
	PetUI.RefreshTrainingTab()
	-- PetUI.RefreshEduPetModel()
	elseif key == tabBtns2[2][2] then  
	CurpageEduSubTab = 2
	PetUI.CreateLearningTab()
	PetUI.RefreshLearningTab()
	elseif key == tabBtns2[3][2] then  
	CurpageEduSubTab = 3
	PetUI.CreateRestoreTab()
	PetUI.RefreshRestoreTab()
	elseif key == tabBtns2[4][2] then  
	CurpageEduSubTab = 4
	PetUI.CreateExtractTab()
	PetUI.RefreshExtractTab()
	elseif key == tabBtns2[5][2] then  
	CurpageEduSubTab = 5
	PetUI.CreateBindTab()
	PetUI.RefreshBindTab()
	elseif key == tabBtns3[1][2] then
		CurpageRefineSubTab = 1
		PetUI.CreateClearTab()
		if PetUI.petGuid ~= nil  then
			CL.SendNotify(NOTIFY.SubmitForm,"FormPetRefining","GetAttrChange",PetUI.petGuid)
		else
			PetUI.RefreshClearPanel()
		end
	elseif key == tabBtns3[2][2] then
		CurpageRefineSubTab = 2
		PetUI.CreateBreachTab()
		if PetUI.petGuid ~= nil then
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetUpStar", "GetPetData",PetUI.petGuid)
		else
			PetUI.RefreshBreachPanel()
		end
    end

    GUI.SetVisible(tabAttributePanel, key == tabBtns[1][2])
    GUI.SetVisible(tabAptitudeAndSkillsPanel, key == tabBtns[2][2])
    GUI.SetVisible(tabEquipmentPanel, key == tabBtns[3][2])
    GUI.SetVisible(tabAttributePanel, key == tabBtns[1][2])
    GUI.SetVisible(pageRefinePanel, key == tabBtns3[1][2] or key == tabBtns3[2][2])
	


    if GUI.GetVisible(tabAttributePanel) then
        local setPetRestBtn = GUI.GetChild(tabAttributePanel, "setPetRestBtn")
        local setPetWorkBtn = GUI.GetChild(tabAttributePanel, "setPetWorkBtn")
            --local returnBtn = GUI.GetChild(tabAttributePanel, "returnBtn")
        GUI.SetVisible(setPetRestBtn, true)
        GUI.SetVisible(setPetWorkBtn, true)
            --GUI.SetVisible(returnBtn, false)
    end
    --end

end


	

-- 创建属性选项卡
function PetUI.CreateAttributeTab(key)
	local AttributePanel = GUI.Get(pageNames[1][2])
	if AttributePanel == nil then
        return
    end

	local tabAttributePanel = GUI.Get(tabNames[1][2])
    if tabAttributePanel ~= nil then 
        return
    end

    -- 宠物属性tab
    tabAttributePanel = GUI.ImageCreate( AttributePanel, tabNames[1][1], "1800400200", 350, -4, false, 345, 472)
    SetAnchorAndPivot(tabAttributePanel, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.SetColor(tabAttributePanel, invisibilityColor)
    GUI.SetVisible(tabAttributePanel, true)
    -----上阵
	local joinfightBtn = GUI.ButtonCreate( tabAttributePanel, "joinfightBtn", "1800402080", 182, 485, Transition.ColorTint, "")
    SetAnchorAndPivot(joinfightBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(joinfightBtn, UCE.PointerClick, "PetUI", "OnJoinBattleBtnClick")
	_gt.BindName(joinfightBtn,"joinfightBtn")
	GUI.AddRedPoint(joinfightBtn,UIAnchor.TopLeft,5,5)

    local joinfightBtnText = GUI.CreateStatic( joinfightBtn, "joinfightBtnText", "上阵", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(joinfightBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(joinfightBtnText, fontSizeBtn)
    GUI.StaticSetAlignment(joinfightBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(joinfightBtnText, true)
    GUI.SetOutLine_Color(joinfightBtnText, colorOutline)
    GUI.SetOutLine_Distance(joinfightBtnText, 1)

-----休息
	local restBtn = GUI.ButtonCreate( tabAttributePanel, "restBtn", "1800402080", 0, 485, Transition.ColorTint, "")
    SetAnchorAndPivot(restBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(restBtn, UCE.PointerClick, "PetUI", "OnSetPetRestBtnClick")
	_gt.BindName(restBtn,"restBtn")

    local restBtnText = GUI.CreateStatic( restBtn, "restBtnText", "休息", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(restBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(restBtnText, fontSizeBtn)
    GUI.StaticSetAlignment(restBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(restBtnText, true)
    GUI.SetOutLine_Color(restBtnText, colorOutline)
    GUI.SetOutLine_Distance(restBtnText, 1)
		
	
--气血 魔法 经验
    local attrList1 = { 1, 2, 3 }
    for i = 1, #attrList1 do
        local data = petProperty[attrList1[i]]

        local label = GUI.CreateStatic( tabAttributePanel, data[2] .. "label", data[1], 12, 18 + (i - 1) * 42, 50, 30, "system", true)
        SetAnchorAndPivot(label, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(label, fontSizeDefault)
        GUI.SetColor(label, colorDark)

        local Slider = GUI.ScrollBarCreate( label, data[2], "", data[3], data[4], 180, -2, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
		_gt.BindName(Slider, data[6])
        
	   
        local silderFillSize = Vector2.New(data[5], 24)
        GUI.ScrollBarSetFillSize(Slider, silderFillSize)
        GUI.ScrollBarSetBgSize(Slider, silderFillSize)
        SetAnchorAndPivot(Slider, UIAnchor.Left, UIAroundPivot.Left)
        if i == 3 then
            GUI.SetPositionX(Slider, 165)

            -- 增加经验
            local addExpBtn = GUI.ButtonCreate( tabAttributePanel, "addExpBtn", "1800702020", 292, 13 + (i - 1) * 42, Transition.ColorTint, "")
            SetAnchorAndPivot(addExpBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.RegisterUIEvent(addExpBtn, UCE.PointerClick, "PetUI", "OnAddExpBtnClick")
			_gt.BindName(addExpBtn,"addExpBtn")

        end

        local text = GUI.CreateStatic( Slider, data[2] .. "Text", "", 0, 1, 200, 30, "system", true)
        SetAnchorAndPivot(text, UIAnchor.Right, UIAroundPivot.Center)
        GUI.StaticSetFontSize(text, fontSizeSmaller)
		GUI.StaticSetAlignment(text,TextAnchor.MiddleCenter)
		_gt.BindName(text, data[2])
		
		
		--local text = GUI.CreateStatic( Slider, data[6] .. "Text", "/", 22, 1, 100, 30, "system", true)
        --SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
        --GUI.StaticSetFontSize(text, fontSizeSmaller)
		
		
		
		--local text = GUI.CreateStatic( Slider, data[6] .. "Text", "", 30, 1, 100, 30, "system", true)
        --SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
        --GUI.StaticSetFontSize(text, fontSizeSmaller)
		
		--_gt.BindName(text, data[6])
	   
	
	
    end
	
	
-- 忠诚、寿命、潜能
    local attrList2 = { 4, 5, 6 }
    for i = 1, #attrList2 do
        local data = petProperty[attrList2[i]]

        local posX = 12
        local posY = 145 + (i - 1) * 42

        if i == 3 then
            posY = posY + 30
        end

        local label = GUI.CreateStatic( tabAttributePanel, data[2] .. "label", data[1], posX, posY, 50, 30, "system", true)
        SetAnchorAndPivot(label, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(label, fontSizeDefault)
        GUI.SetColor(label, colorDark)
        
        local textBg = GUI.ImageCreate( tabAttributePanel, data[2] .. "textBg", "1800700010", posX + 50, posY + 1, false, 132, 26)
        SetAnchorAndPivot(textBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local text = GUI.CreateStatic( textBg, data[2] .. "Text", "   ", 0, 0, 132, 26, "system", true)
        SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(text, fontSizeSmaller)
		GUI.StaticSetAlignment(text,TextAnchor.MiddleCenter)
		
		_gt.BindName(text, data[2])

        local btn = GUI.ButtonCreate( tabAttributePanel, data[3], data[4], posX + 190, posY - 5, Transition.ColorTint, "", 82, 38, false)
        SetAnchorAndPivot(btn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        if i == 1 then
            GUI.RegisterUIEvent(btn, UCE.PointerClick, "PetUI", "OnRaiseBtnClick")
		elseif i == 2 then
			GUI.RegisterUIEvent(btn, UCE.PointerClick, "PetUI", "OnAddLifeBtnClick")
		elseif i == 3 then
			GUI.AddRedPoint(btn, UIAnchor.TopLeft)
			GUI.SetRedPointVisable(btn,false)
		end
		_gt.BindName(btn, data[3])

        local btnText = GUI.CreateStatic( btn, data[3] .. "Text", data[5], 0, 0, 82, 38, "system", true)
        SetAnchorAndPivot(btnText, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(btnText, fontSizeSmaller)
        GUI.StaticSetAlignment(btnText, TextAnchor.MiddleCenter)
        GUI.SetColor(btnText, colorDark)

        if i == 1 then
            -- 加忠诚度Tips
            local addClosePointTipBtn = GUI.ButtonCreate( tabAttributePanel, "addClosePointTipBtn", "1800702030", posX + 276, posY - 5, Transition.ColorTint, "")
            SetAnchorAndPivot(addClosePointTipBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.RegisterUIEvent(addClosePointTipBtn, UCE.PointerClick, "PetUI", "OnAddClosePointTipBtnClick")
        end

        if i == 3 then
            -- 加点Tip
            local addPointTipBtn = GUI.ButtonCreate( tabAttributePanel, "addPointTipBtn", "1800702030", posX + 276, posY - 5, Transition.ColorTint, "")
            SetAnchorAndPivot(addPointTipBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.RegisterUIEvent(addPointTipBtn, UCE.PointerClick, "PetUI", "OnAddPointTipBtnClick")

            GUI.RegisterUIEvent(btn, UCE.PointerClick, "PetUI", "OnAddPointBtnClick")
        end


    end
	
	
-- 一级属性和二级属性
    local attrList3 = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16}

    for i = 1, #attrList3 do
        local data = petProperty[attrList3[i]]
        local posX = 12
        local posY = 300
        if i <= 5 then
            posX = 12
            posY = 300 + (i - 1) * 32
        else
            posX = 190
            posY = 300 + (i - 6) * 32
        end

        local label = GUI.CreateStatic( tabAttributePanel, data[2] .. "label", data[1], posX, posY, 50, 30, "system", true)
        SetAnchorAndPivot(label, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(label, fontSizeDefault)
        GUI.SetColor(label, colorDark)

        local text = GUI.CreateStatic( tabAttributePanel, data[2] .. "Text", "", posX + 65, posY + 2, 100, 24, "system", true)
        SetAnchorAndPivot(text, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(text, fontSizeSmaller)
        GUI.SetColor(text, colorYellow)
		
		_gt.BindName(text, data[2])

	end
end
 
 local ToEduIndex = 0
--当点击增加经验按钮
function PetUI.OnAddExpBtnClick()
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	if Level < 30 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"30级开启宠物养成功能。")
	else
	PetUI.tabIndex = 2
	CurpageEduSubTab = 1
	ToEduIndex = 1
	PetUI.Refresh()
	end
end

--当点击驯养按钮
function PetUI.OnRaiseBtnClick()
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	if Level < 30 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"30级开启宠物养成功能。")
	else
	PetUI.tabIndex = 2
	CurpageEduSubTab = 1
	ToEduIndex = 2
	PetUI.Refresh()
	end

end

--当点击增寿按钮
function PetUI.OnAddLifeBtnClick()
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	if Level < 30 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"30级开启宠物养成功能。")
	else
	PetUI.tabIndex = 2
	CurpageEduSubTab = 1
	ToEduIndex = 3
	PetUI.Refresh()
	end

end

-- 点击图鉴按钮
function PetUI.OnHandBookBtnClick()
	GUI.OpenWnd("PetHandBookUI")
end

function PetUI.CreateAptitudeAndSkillsTab()
	local AttributePanel = GUI.Get(pageNames[1][2])
	if AttributePanel == nil then
        return
    end

    local tabAptitudeAndSkillsPanel = GUI.Get(tabNames[2][2])
    if tabAptitudeAndSkillsPanel == nil then
        
 -- 宠物属性tab
		tabAptitudeAndSkillsPanel = GUI.ImageCreate( AttributePanel, tabNames[2][1], "1800400200", 350, 26, false, 345, 533)
		SetAnchorAndPivot(tabAptitudeAndSkillsPanel, UIAnchor.Center, UIAroundPivot.Center)
		_gt.BindName(tabAptitudeAndSkillsPanel, "tabAptitudeAndSkillsPanel")
		
		
		local attrList = { 17, 18, 19, 20, 21, 22, 23, 24 }
		for i = 1, #attrList do
			local data = petProperty[attrList[i]]

			local label = GUI.CreateStatic( tabAptitudeAndSkillsPanel, data[2] .. "label", data[1], 12, 18 + (i - 1) * 30, 160, 30, "system", true)
			SetAnchorAndPivot(label, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
			GUI.StaticSetFontSize(label, fontSizeDefault)
			GUI.SetColor(label, colorDark)

			-- 悟性特殊处理
			if attrList[i] == 202 then
				GUI.StaticSetText(label, "悟<color=#FFFFFF00>隐藏</color>性")
			elseif attrList[i] == 203 then
				GUI.StaticSetText(label, "成<color=#FFFFFF00>_</color>长<color=#FFFFFF00>_</color>率")
			end

			local tempSlider = GUI.ScrollBarCreate( label, data[2], "", data[3], data[4], 205, -2, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
			_gt.BindName(tempSlider, data[6])

			local silderFillSize = Vector2.New(data[5], 24)
			GUI.ScrollBarSetFillSize(tempSlider, silderFillSize)
			GUI.ScrollBarSetBgSize(tempSlider, silderFillSize)
			SetAnchorAndPivot(tempSlider, UIAnchor.Left, UIAroundPivot.Left)

			local currentTxt = GUI.CreateStatic( tempSlider, data[2] .. "Text", "", 0, 0, 130, 30, "system", true)
			SetAnchorAndPivot(currentTxt, UIAnchor.Center, UIAroundPivot.Center)
			GUI.StaticSetFontSize(currentTxt, fontSizeSmaller)
			GUI.StaticSetAlignment(currentTxt, TextAnchor.MiddleCenter)
			_gt.BindName(currentTxt, data[2])
		
			
			
			

		end
		-- 宠物技能
		-- 技能背景图
		local skillsBg = GUI.ImageCreate( tabAptitudeAndSkillsPanel, "skillsBg", "1800700050", 3, 262, false, 336, 202)
		SetAnchorAndPivot(skillsBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

		-- 标题
		local titleLabel = GUI.CreateStatic( skillsBg, "titleLabel", "宠物技能", -1, -77, 180, 50, "system", true)
		SetAnchorAndPivot(titleLabel, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(titleLabel, fontSizeDefault)
		GUI.StaticSetAlignment(titleLabel, TextAnchor.MiddleCenter)
		GUI.SetColor(titleLabel, colorDark)
		
		local skillScroll = GUI.LoopScrollRectCreate(skillsBg, "skillScroll", 0, 40, 330, 155,
		"PetUI", "CreateSkillItem", "PetUI", "RefreshSkillScroll", 0, false, Vector2.New(80, 80), 4, UIAroundPivot.Top, UIAnchor.Top);
		UILayout.SetSameAnchorAndPivot(skillScroll, UILayout.Top)
		_gt.BindName(skillScroll, "skillScroll")

		-- 炼化资质按钮
		local refineBtn= GUI.ButtonCreate( tabAptitudeAndSkillsPanel, "refineBtn", "1800402080", 90, 475, Transition.ColorTint, "")
		SetAnchorAndPivot(refineBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
		GUI.RegisterUIEvent(refineBtn, UCE.PointerClick, "PetUI", "OnRefineBtnClick")

		local refineBtnText = GUI.CreateStatic( refineBtn, "refineBtnText", "炼化资质", 0, 0, 160, 47, "system", true)
		SetAnchorAndPivot(refineBtnText, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(refineBtnText, fontSizeBtn)
		GUI.StaticSetAlignment(refineBtnText, TextAnchor.MiddleCenter)
		GUI.SetColor(refineBtnText,colorWhite)
		GUI.SetIsOutLine(refineBtnText, true)
		GUI.SetOutLine_Color(refineBtnText, colorOutline)
		GUI.SetOutLine_Distance(refineBtnText, 1)
	end
	
	
	
	PetUI.skillRefresh()
	
	
	
   
	
end	
	
function PetUI.CreateEquipmentTab()
	local AttributePanel = GUI.Get(pageNames[1][2])
    if AttributePanel == nil then
        return
    end

    local tabEquipmentPanel = GUI.Get(tabNames[3][2])
    if tabEquipmentPanel ~= nil then
        return
    end

    -- 宠物装备tab
    tabEquipmentPanel = GUI.ImageCreate( AttributePanel, tabNames[3][1], "1800400200", 350, 25, false, 345, 533)
    SetAnchorAndPivot(tabEquipmentPanel, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(tabEquipmentPanel,"tabEquipmentPanel")
	-- 背景图
    -- 装备背景图
    local euqipmentsBg = GUI.ImageCreate( tabEquipmentPanel, "euqipmentsBg", "1800400250", 0, 0)
    SetAnchorAndPivot(euqipmentsBg, UIAnchor.Center, UIAroundPivot.Center)
	-- 装备
	local pos = {{x=-100,y=-100},{x=100,y=-100},{x=-100,y=100},{x=100,y=100}}
	for i = 1, #equipSiteData do
	local equipField =ItemIcon.Create(tabEquipmentPanel,"equipField"..i,pos[i].x,pos[i].y)
    UILayout.SetSameAnchorAndPivot(equipField, UILayout.Center);
    GUI.ItemCtrlSetElementValue(equipField, eItemIconElement.Border, "1800400050");
    GUI.ItemCtrlSetElementValue(equipField, eItemIconElement.Icon, equipSiteData[i].img);
    GUI.ItemCtrlSetElementRect(equipField, eItemIconElement.Icon, 0, -1,55,55);
    GUI.SetData(equipField,"Site",equipSiteData[i].site);
    _gt.BindName(equipField,"equipField"..i);

    local add = GUI.ImageCreate(equipField, "add", "1800707060", 0, 0,false,50,50)
    UILayout.SetSameAnchorAndPivot(add, UILayout.Center);

    GUI.RegisterUIEvent(equipField, UCE.PointerClick, "PetUI", "OnEquipFieldClick");
  end
		
	local equipRepairItem = GUI.ButtonCreate( tabEquipmentPanel, "equipRepairItem", "1800602020", -15, -10, Transition.ColorTint,"装备培养")
    SetAnchorAndPivot(equipRepairItem, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.RegisterUIEvent(equipRepairItem, UCE.PointerClick, "PetUI", "OnEquipRepairItemBtnClick")
    -- GUI.AddRedPoint(equipRepairItem,UIAnchor.TopLeft,11,11);
    -- GUI.SetRedPointVisable(equipRepairItem,false);
    GUI.ButtonSetTextFontSize(equipRepairItem,24);
    GUI.ButtonSetTextColor(equipRepairItem,colorDark)
    -- GUI.AddRedPoint(equipRepairItem, UIAnchor.TopLeft, 5, 5)
    GUI.SetRedPointVisable(equipRepairItem, false)
	
	
	return AttributePanel
end	





function PetUI.OnEquipFieldClick(guid)
  if PetUI.petGuid==nil then
    CL.SendNotify(NOTIFY.ShowBBMsg,"未选中宠物")
    return;
  end

  local equipField = GUI.GetByGuid(guid);
  local site = tonumber(GUI.GetData(equipField,"Site"))
  PetUI.OpenEquipSite(site)
end

--c
function PetUI.OpenEquipSite(site)
  PetUI.equipSite=site;
  PetUI.equipGuids={};
  PetUI.CurEquipLv = nil
  PetUI.CurEquipGra = nil
  PetUI.RedPointIndex = {}
  PetUI.CurEquipSite = site

  local Type=1;
  local SubType=7;
  local Subtype2=1;
  if site==LogicDefine.PetEquipSite.site_collar then
    Subtype2=1;
  elseif site==LogicDefine.PetEquipSite.site_armor then
    Subtype2=2;
  elseif site==LogicDefine.PetEquipSite.site_amulet then
    Subtype2=3;
  elseif site==LogicDefine.PetEquipSite.site_accessory then
    Subtype2=4;
  end

  local count = LD.GetItemCount()
	if Subtype2 ~=4 then
		for i = 0, count - 1 do
		local itemGuid = LD.GetItemGuidByItemIndex(i);
		local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
		local itemDB = DB.GetOnceItemByKey1(itemId);

			if itemDB.Type==Type and itemDB.Subtype==SubType and itemDB.Subtype2==Subtype2 then
				table.insert(PetUI.equipGuids, itemGuid);
			end
		end
	elseif Subtype2 ==4 then
		for i = 0, count - 1 do
		local itemGuid = LD.GetItemGuidByItemIndex(i);
		local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
		local itemDB = DB.GetOnceItemByKey1(itemId);
		local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,PetUI.petGuid)))
		local petDB =DB.GetOncePetByKey1(petId)

			if itemDB.Type==Type and itemDB.Subtype==SubType and itemDB.Subtype2==Subtype2 and petDB.TrinketKey ==itemDB.KeyName  then
				table.insert(PetUI.equipGuids, itemGuid);
			end
		end
	end
	local PetLevel = UIDefine.GetPetLevelStrByGuid(PetUI.petGuid)
	table.sort(PetUI.equipGuids,function (a,b)
		local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, a);
		local itemDB = DB.GetOnceItemByKey1(itemId);

		local itemId2 = LD.GetItemAttrByGuid(ItemAttr_Native.Id, b);
		local itemDB2 = DB.GetOnceItemByKey1(itemId2);
		
		if itemDB.Level ~= itemDB2.Level then
			if itemDB.Level <= PetLevel and itemDB2.Level <= PetLevel then
				return itemDB.Level > itemDB2.Level
			elseif itemDB.Level <= PetLevel then
				return true
			elseif itemDB2.Level <= PetLevel then
				return false
			else
				return itemDB.Level < itemDB2.Level
			end
		elseif itemDB.Grade ~= itemDB2.Grade then
			return itemDB.Grade > itemDB2.Grade
		end
	end)
  
  local equipData=LD.GetItemDataByIndex(PetUI.equipSite,item_container_type.item_container_pet_equip,PetUI.petGuid)
  
  PetUI.OpenEquipList();
  if equipData then
    local tabEquipmentPanel = _gt.GetUI("tabEquipmentPanel")
    local equipTips=Tips.CreateByItemData(equipData,tabEquipmentPanel,"equipTips",-300,0,50)
    UILayout.SetSameAnchorAndPivot(equipTips,UILayout.Center);
    local takeOffBtn = GUI.ButtonCreate(equipTips, "useBtn", 1800402110,90, -10, Transition.ColorTint, "卸下", 150, 50, false);
    UILayout.SetSameAnchorAndPivot(takeOffBtn, UILayout.Bottom);
    GUI.ButtonSetTextColor(takeOffBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(takeOffBtn, UIDefine.FontSizeL);
    GUI.RegisterUIEvent(takeOffBtn, UCE.PointerClick, "PetUI", "OnTakeOffBtnClick");
	
	local RepairBtn = GUI.ButtonCreate(equipTips, "RepairBtn", 1800402110, -90, -10, Transition.ColorTint, "修理", 150, 50, false);
	UILayout.SetSameAnchorAndPivot(RepairBtn, UILayout.Bottom);
	GUI.ButtonSetTextColor(RepairBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(RepairBtn, UIDefine.FontSizeL);
	GUI.RegisterUIEvent(RepairBtn, UCE.PointerClick, "PetUI", "OnEquipRepairItemBtnClick") 
	
    local inEquip=GUI.ImageCreate(equipTips, "inEquip", "1800707290", 0, 0)
    UILayout.SetSameAnchorAndPivot(inEquip, UILayout.TopLeft);
	
	local id = equipData:GetAttr(ItemAttr_Native.Id)
	local ItemDB = DB.GetOnceItemByKey1(id)
	PetUI.CurEquipLv = ItemDB.Level
	PetUI.CurEquipGra = ItemDB.Grade
  end


end


function PetUI.OpenEquipList()

  local tabEquipmentPanel = _gt.GetUI("tabEquipmentPanel")
  local equipListBg=GUI.ImageCreate(tabEquipmentPanel, "equipListBg", "1800400300", 40, 0,false,280,400)
  UILayout.SetSameAnchorAndPivot(equipListBg, UILayout.Center);
  GUI.SetIsRemoveWhenClick(equipListBg, true)
  _gt.BindName(equipListBg,"equipListBg")
  local title = GUI.ImageCreate(equipListBg, "title", "1800700270", 0, 18)
  UILayout.SetSameAnchorAndPivot(title, UILayout.Top);

  local titleText = GUI.CreateStatic(title, "nameText", "可用装备", 0, -2, 150, 35);
  GUI.SetColor(titleText, UIDefine.WhiteColor);
  GUI.StaticSetFontSize(titleText, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter);

	if #PetUI.equipGuids~=0 then
		local equipScroll = GUI.LoopScrollRectCreate(equipListBg, "equipScroll", 0, 55, 255, 320,
			"PetUI", "CreateEquipItem", "PetUI", "RefreshEquipScroll", 0, false,
			Vector2.New(250, 95), 1, UIAroundPivot.Top, UIAnchor.Top);
		GUI.ScrollRectSetChildSpacing(equipScroll, Vector2.New(1, 5));
		UILayout.SetSameAnchorAndPivot(equipScroll, UILayout.Top);
		_gt.BindName(equipScroll,"equipScroll")

		GUI.LoopScrollRectSetTotalCount(equipScroll, #PetUI.equipGuids);
	else
		local temptable = {
			"面板展示-宠物项圈",
			"面板展示-宠物盔甲",
			"面板展示-宠物护符",
			"面板展示-宠物饰品"
		}
		local itemDB = nil
		if tonumber(PetUI.CurEquipSite) ~= 3 then
			itemDB = DB.GetOnceItemByKey2(temptable[tonumber(PetUI.CurEquipSite)+1])

			local EquipItem=GUI.CheckBoxExCreate(equipListBg, "equipItem", "1800700030", "1800700040", 0, 55, false,250,95)
			UILayout.SetSameAnchorAndPivot(EquipItem, UILayout.Top)
			GUI.AddWhiteName(equipListBg,GUI.GetGuid(EquipItem))
			GUI.SetData(EquipItem,"TempEquipID",itemDB.Id)
			
			local icon = GUI.ItemCtrlCreate(EquipItem,"icon","1800400050",12,2,0,0,true);
			UILayout.SetSameAnchorAndPivot(icon, UILayout.Left)
			GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Icon,itemDB.Icon)
			GUI.ItemCtrlSetIconGray(icon,true)
			GUI.SetIsRaycastTarget(icon,false)
			GUI.ItemCtrlSetElementValue(icon,eItemIconElement.LeftBottomSp, 1801208350);
			GUI.ItemCtrlSetElementRect(icon,eItemIconElement.LeftBottomSp, 5,6,37,37);

			local nameText = GUI.CreateStatic(EquipItem, "nameText",itemDB.Name, 100, -18, 200, 35)
			GUI.SetColor(nameText, UIDefine.BrownColor)
			GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
			GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
			UILayout.SetSameAnchorAndPivot(nameText,UILayout.Left);

			local levelText = GUI.CreateStatic(EquipItem, "levelText", "15~125级", 100, 15, 200, 35,"system",true)
			GUI.SetColor(levelText, UIDefine.Yellow2Color)
			GUI.StaticSetFontSize(levelText, UIDefine.FontSizeM)
			GUI.StaticSetAlignment(levelText, TextAnchor.MiddleLeft)
			UILayout.SetSameAnchorAndPivot(levelText,UILayout.Left)	

			GUI.RegisterUIEvent(EquipItem, UCE.PointerClick, "PetUI", "OnTempPetEquipClick");
		else
			local equipData=LD.GetItemDataByIndex(tonumber(PetUI.CurEquipSite),item_container_type.item_container_pet_equip,PetUI.petGuid) 
			if equipData == nil then
				if PetUI.petDB then
					-- test(PetUI.petDB.TrinketKey)
					itemDB = DB.GetOnceItemByKey2(PetUI.petDB.TrinketKey) 
				else
					itemDB = DB.GetOnceItemByKey2(temptable[tonumber(PetUI.CurEquipSite)+1])
				end
				local EquipItem=GUI.CheckBoxExCreate(equipListBg, "equipItem", "1800700030", "1800700040", 0, 55, false,250,95)
				UILayout.SetSameAnchorAndPivot(EquipItem, UILayout.Top)
				GUI.AddWhiteName(equipListBg,GUI.GetGuid(EquipItem))
				GUI.SetData(EquipItem,"TempEquipID",itemDB.Id)
				
				local icon = GUI.ItemCtrlCreate(EquipItem,"icon","1800400050",12,2,0,0,true);
				UILayout.SetSameAnchorAndPivot(icon, UILayout.Left)
				GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Icon,itemDB.Icon)
				GUI.ItemCtrlSetIconGray(icon,true)
				GUI.SetIsRaycastTarget(icon,false)
				GUI.ItemCtrlSetElementValue(icon,eItemIconElement.LeftBottomSp, 1801208350);
				GUI.ItemCtrlSetElementRect(icon,eItemIconElement.LeftBottomSp, 5,6,37,37);

				local nameText = GUI.CreateStatic(EquipItem, "nameText",itemDB.Name, 100, -18, 200, 35)
				GUI.SetColor(nameText, UIDefine.BrownColor)
				GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
				GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
				UILayout.SetSameAnchorAndPivot(nameText,UILayout.Left);

				local levelText = GUI.CreateStatic(EquipItem, "levelText", tostring(itemDB.Level).."级", 100, 15, 200, 35,"system",true)
				GUI.SetColor(levelText, UIDefine.Yellow2Color)
				GUI.StaticSetFontSize(levelText, UIDefine.FontSizeM)
				GUI.StaticSetAlignment(levelText, TextAnchor.MiddleLeft)
				UILayout.SetSameAnchorAndPivot(levelText,UILayout.Left)					

				GUI.RegisterUIEvent(EquipItem, UCE.PointerClick, "PetUI", "OnTempPetEquipClick");				
			end
		end
	end
end

function PetUI.OnTempPetEquipClick(guid)
	local equipListBg =_gt.GetUI("equipListBg")
	local parent = GUI.GetByGuid(guid)
	local TempEquipID = GUI.GetData(parent,"TempEquipID")
	local itemtips = Tips.CreateByItemId(TempEquipID,parent, "itemtips",-320, 0, 50)  --创造提示
	GUI.SetData(itemtips, "ItemId", tostring(TempEquipID))
	_gt.BindName(itemtips,"TempPetEquipTips")
	local cutLine = GUI.GetChild(itemtips,"CutLine")
	GUI.SetPositionX(cutLine,-200)
	local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
	UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
	GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
	GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
	GUI.AddWhiteName(equipListBg, GUI.GetGuid(itemtips))	
	GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
	GUI.AddWhiteName(equipListBg, GUI.GetGuid(wayBtn))	
	GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickTempPetEquipWayBtn")
end

function PetUI.OnClickTempPetEquipWayBtn()
	local tips = _gt.GetUI("TempPetEquipTips")
	local id =GUI.GetData(tips,"ItemId")
	PetUI.TempEquipID = tostring(id)

	if tips then
        Tips.ShowItemGetWay(tips)
    end
end
  

function PetUI.CreateEquipItem()
  local equipListBg = _gt.GetUI("equipListBg")
  local equipScroll = _gt.GetUI("equipScroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(equipScroll);

  local equipItem=GUI.CheckBoxExCreate(equipScroll, "equipItem"..curCount, "1800700030", "1800700040", 0, 0, false)
  GUI.RegisterUIEvent(equipItem, UCE.PointerClick, "PetUI", "OnEquipItemClick");
  GUI.AddWhiteName(equipListBg,GUI.GetGuid(equipItem))

  local icon = ItemIcon.Create(equipItem,"icon",12,2);
  UILayout.SetSameAnchorAndPivot(icon, UILayout.Left);
  GUI.SetIsRaycastTarget(icon,false)

  local nameText = GUI.CreateStatic(equipItem, "nameText", "name", 100, -18, 200, 35)
  GUI.SetColor(nameText, UIDefine.BrownColor)
  GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(nameText,UILayout.Left);

  local levelText = GUI.CreateStatic(equipItem, "levelText", "level", 100, 15, 200, 35,"system",true)
  GUI.SetColor(levelText, UIDefine.Yellow2Color)
  GUI.StaticSetFontSize(levelText, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(levelText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(levelText,UILayout.Left);
  
  GUI.AddRedPoint(equipItem,UIAnchor.TopLeft,15,15)
  GUI.SetRedPointVisable(equipItem,false)
  
  return equipItem;
end  


function PetUI.OnEquipItemClick(guid)
  local equipItem = GUI.GetByGuid(guid);
  local index = GUI.CheckBoxExGetIndex(equipItem);
  index = index+1;

  if PetUI.preEquipItemGuid then
    local preEquipItem = GUI.GetByGuid(PetUI.preEquipItemGuid);
    GUI.CheckBoxExSetCheck(preEquipItem,false);
  end

  GUI.CheckBoxExSetCheck(equipItem,true);
  PetUI.preEquipItemGuid =guid;



  local equipGuid = PetUI.equipGuids[index];
  local equipItemData = LD.GetItemDataByGuid(equipGuid)
  local tabEquipmentPanel = _gt.GetUI("tabEquipmentPanel")
  local equipTips=Tips.CreateByItemData(equipItemData,tabEquipmentPanel,"equipTips1",-300,0,50)
  UILayout.SetSameAnchorAndPivot(equipTips,UILayout.Center);
  local useBtn = GUI.ButtonCreate(equipTips, "useBtn", 1800402110, 90, -10, Transition.ColorTint, "装备", 150, 50, false);
  UILayout.SetSameAnchorAndPivot(useBtn, UILayout.Bottom);
  GUI.ButtonSetTextColor(useBtn, UIDefine.BrownColor);
  GUI.ButtonSetTextFontSize(useBtn, UIDefine.FontSizeL);
  GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "PetUI", "OnUseBtnClick")
  
  local RepairBtn = GUI.ButtonCreate(equipTips, "RepairBtn", 1800402110, -90, -10, Transition.ColorTint, "修理", 150, 50, false);
  UILayout.SetSameAnchorAndPivot(RepairBtn, UILayout.Bottom);
  GUI.ButtonSetTextColor(RepairBtn, UIDefine.BrownColor);
  GUI.ButtonSetTextFontSize(RepairBtn, UIDefine.FontSizeL);
  GUI.RegisterUIEvent(RepairBtn, UCE.PointerClick, "PetUI", "OnEquipRepairItemBtnClick") 


  local equipData=LD.GetItemDataByIndex(PetUI.equipSite,item_container_type.item_container_pet_equip,PetUI.petGuid)
  if equipData then
    local equipTips=Tips.CreateByItemData(equipData,tabEquipmentPanel,"equipTips2",-700,0,50)
    UILayout.SetSameAnchorAndPivot(equipTips,UILayout.Center);
    local takeOffBtn = GUI.ButtonCreate(equipTips, "useBtn", 1800402110, 90, -10, Transition.ColorTint, "卸下", 150, 50, false);
    UILayout.SetSameAnchorAndPivot(takeOffBtn, UILayout.Bottom);
    GUI.ButtonSetTextColor(takeOffBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(takeOffBtn, UIDefine.FontSizeL);
    GUI.RegisterUIEvent(takeOffBtn, UCE.PointerClick, "PetUI", "OnTakeOffBtnClick");
	local RepairBtn = GUI.ButtonCreate(equipTips, "RepairBtn", 1800402110, -90, -10, Transition.ColorTint, "修理", 150, 50, false);
	UILayout.SetSameAnchorAndPivot(RepairBtn, UILayout.Bottom);
	GUI.ButtonSetTextColor(RepairBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(RepairBtn, UIDefine.FontSizeL);
	GUI.RegisterUIEvent(RepairBtn, UCE.PointerClick, "PetUI", "OnEquipRepairItemBtnClick") 
	
    local inEquip=GUI.ImageCreate(equipTips, "inEquip", "1800707290", 0, 0)
    UILayout.SetSameAnchorAndPivot(inEquip, UILayout.TopLeft);
  end
  
  GUI.AddRedPoint(useBtn,UIAnchor.TopLeft,5,5)
  --红点
  GUI.SetRedPointVisable(useBtn,false)
  local mark = 0
  for i =1, #PetUI.RedPointIndex do
	if mark == 0 then
	  if PetUI.RedPointIndex[i] ==index then
		GUI.SetRedPointVisable(useBtn,true)
		mark =1 
	  end
	end
  end
  
end

function PetUI.OnTakeOffBtnClick()
  if PetUI.petGuid then
    CL.SendNotify(NOTIFY.SubmitForm, "FormPetEquip", "PetTakeOffEquip",tostring(PetUI.petGuid),tostring(PetUI.equipSite));
  end
end

function PetUI.OnUseBtnClick(guid)
  local equipItem = GUI.GetByGuid(PetUI.preEquipItemGuid);
  local index = GUI.CheckBoxExGetIndex(equipItem);
  index = index+1;
  local equipGuid = PetUI.equipGuids[index];

  if PetUI.petGuid then
    CL.SendNotify(NOTIFY.SubmitForm, "FormPetEquip", "PetPutOnEquip",tostring(PetUI.petGuid),tostring(equipGuid));
  end
end

function PetUI.RefreshEquipScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	index = index+1;

	local equipGuid = PetUI.equipGuids[index];
	if equipGuid then
		local equipItem = GUI.GetByGuid(guid);
		local icon = GUI.GetChild(equipItem,"icon")
		local nameText = GUI.GetChild(equipItem,"nameText")
		local levelText = GUI.GetChild(equipItem,"levelText")

		local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, equipGuid);
		local itemDB = DB.GetOnceItemByKey1(itemId);
		ItemIcon.BindItemGuid(icon,equipGuid);
		GUI.StaticSetText(nameText,itemDB.Name);
		if (UIDefine.GetPetLevelStrByGuid(PetUI.petGuid))< itemDB.Level then
		GUI.StaticSetText(levelText,"<color=#FF0000>"..itemDB.Level.."级".."</color>")
		else 
		GUI.StaticSetText(levelText,itemDB.Level.."级")
		end
		--红点
		GUI.SetRedPointVisable(equipItem,false)
		
		if LD.GetPetState(PetState.Lineup,PetUI.petGuid) then
		-- CDebug.LogError(itemDB.Level)
		-- CDebug.LogError(PetUI.CurEquipLv)
			if PetUI.CurEquipLv ~=nil and PetUI.CurEquipGra ~= nil then
				if itemDB.Level > PetUI.CurEquipLv then
					local PetLevel = UIDefine.GetPetLevelStrByGuid(PetUI.petGuid)
					if PetLevel >= itemDB.Level then
						GUI.SetRedPointVisable(equipItem,true)
						table.insert(PetUI.RedPointIndex,index)
					end
				elseif itemDB.Level == PetUI.CurEquipLv then
					if itemDB.Grade > PetUI.CurEquipGra  then
						local PetLevel = UIDefine.GetPetLevelStrByGuid(PetUI.petGuid)
						if PetLevel >= itemDB.Level then
							GUI.SetRedPointVisable(equipItem,true)
							table.insert(PetUI.RedPointIndex,index)
						end
					end
				end
			else
				local PetLevel = UIDefine.GetPetLevelStrByGuid(PetUI.petGuid)
				if PetLevel >= itemDB.Level then
				GUI.SetRedPointVisable(equipItem,true)
				table.insert(PetUI.RedPointIndex,index)
				end
			end
		end
  end
end

--下拉列表被点击
function PetUI.OnPullListBtnClick(key)
    local bg = GUI.Get("PetUI/panelBg/petListBg/rightTitle_Bg/petSortType_Bg")
    local tmp = GUI.GetVisible(bg)
    if tmp == false then
        GUI.SetVisible(bg, true)
        GUI.SetDepth(bg, GUI.GetChildCount(GUI.Get("PetUI/panelBg/petListBg")))
    elseif tmp == true then
        GUI.SetVisible(bg, false)
    end
end
	PetUI.SortType = 1
-- 宠物排序按钮被点击
function PetUI.OnPetSortTypeBtnClick(guid)
    local bg = GUI.Get("PetUI/panelBg/petListBg/rightTitle_Bg/petSortType_Bg")
    GUI.SetVisible(bg, false)
    local btn = GUI.GetByGuid(guid)
    local sortType = tonumber(GUI.GetData(btn, "sortType"))

    local petSortType_Txt = GUI.Get("PetUI/panelBg/petListBg/rightTitle_Bg/petSortType_Txt")
    GUI.StaticSetText(petSortType_Txt, "<color=#662F16><size=20>" .. petSortType[sortType][1] .. "</size></color>")
    PetUI.SortType = sortType
	local index = petSortType[sortType][2]
    PetUI.OnPetListUpdate(index)
end


function PetUI.OnPetListUpdate(index)
	PetSortType_Index =index
	PetUI.PetListChange = 1
	PetUI.Refresh()
end

function PetUI.OnAddPointBtnClick(guid)
	if not PetUI.petGuid then
		return
	end
	GUI.OpenWnd("AddPointUI")
	AddPointUI.SetPetGuid(PetUI.petGuid)
end


--加点Tips
function PetUI.OnAddPointTipBtnClick()
	local tips = GUI.TipsCreate(GUI.Get("PetUI/panelBg"), "Tips", 0, 0, 420, 250)  --"1800400290",
    GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
	local tipsmidicon = GUI.ImageCreate(tips,"tipsmidicon","1801401070",0,-70,false,320,3)
	local tipstext = GUI.CreateStatic(tips,"tipstext","宠物等级大于<color=#FFFF00ff>50</color>级后，需要手动分配潜能点。如果开启了<color=#FFFF00ff>自动加点</color>开关，则会一直自动加点。",0,-120,360,120,"system", true)
	GUI.StaticSetFontSize(tipstext,22)
	local tipstext2 = GUI.CreateStatic(tips,"tipstext2","提高力量属性，会影响血量上限、物攻。",0,-35,360,120,"system", true)
	GUI.StaticSetFontSize(tipstext2,22)
	local tipstext3 = GUI.CreateStatic(tips,"tipstext3","提高法力属性，会影响魔法上限、法攻、法防",0,20,360,120,"system", true)
	GUI.StaticSetFontSize(tipstext3,22)
	local tipstext4 = GUI.CreateStatic(tips,"tipstext4","提高体质属性，会影响血量上限、法防。",0,75,360,120,"system", true)
	GUI.StaticSetFontSize(tipstext4,22)
	local tipstext5 = GUI.CreateStatic(tips,"tipstext5","提高耐力属性，会影响物防、法防。",0,117,360,120,"system", true)
	GUI.StaticSetFontSize(tipstext5,22)
	local tipstext6 = GUI.CreateStatic(tips,"tipstext6","提高敏捷属性，会影响速度。",0,150,360,120,"system", true)
	GUI.StaticSetFontSize(tipstext6,22)

end

---忠诚度Tips
function PetUI.OnAddClosePointTipBtnClick()
	local tips = GUI.TipsCreate(GUI.Get("PetUI/panelBg"), "Tips", 0, 15, 500, 70)  --"1800400290",
    GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
	local tipstext = GUI.CreateStatic(tips,"tipstext","忠诚度-是否百分百服从主人下达的指令。",0,-60,450,120,"system", true)
	GUI.StaticSetFontSize(tipstext,22)
	local tipstext2 = GUI.CreateStatic(tips,"tipstext2","大于<color=#FFFF00ff>60</color>，能百分百服从主人的指令。",0,-30,450,120,"system", true)
	GUI.StaticSetFontSize(tipstext2,22)
	local tipstext3 = GUI.CreateStatic(tips,"tipstext3","小于<color=#FFFF00ff>60</color>，不服从主人指令，每回合普攻。",0,0,450,120,"system", true)
	GUI.StaticSetFontSize(tipstext3,22)
	local tipstext4 = GUI.CreateStatic(tips,"tipstext4","小于<color=#FFFF00ff>30</color>，不服从主人指令，且有概率逃跑。",0,30,450,120,"system", true)
	GUI.StaticSetFontSize(tipstext4,22)
	local tipstext5 = GUI.CreateStatic(tips,"tipstext5","小于<color=#FFFF00ff>5</color>，则无法正常出战。",0,60,450,120,"system", true)
	GUI.StaticSetFontSize(tipstext5,22)

end

function PetUI.OnAddtipsCloseClick()
    local tips =_gt.GetUI("tips2")
	if tips  then
	GUI.SetVisible(tips,false)
	end
end

--左上角tips
function PetUI.OnPetTipBtnClick()
	local tips = GUI.TipsCreate(GUI.Get("PetUI/panelBg"), "Tips", 0, -80, 520, 160)  --"1800400290",
    GUI.SetIsRemoveWhenClick(tips, true)
	GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
	local tipstext = GUI.CreateStatic(tips,"tipstext","1.除“主战”宠物外，还能设置最多4个侍宠。",0,-110,480,120,"system", true)
	GUI.StaticSetFontSize(tipstext,22)
	local tipstext2 = GUI.CreateStatic(tips,"tipstext2","2.每有一个侍从参战时，侍宠就会随之参战一个。",0,-80,480,120,"system", true)
	GUI.StaticSetFontSize(tipstext2,22)
	local tipstext3 = GUI.CreateStatic(tips,"tipstext3","3.宠物参战阵容可点击阵容调整。",0,-50,480,120,"system", true)
	GUI.StaticSetFontSize(tipstext3,22)
	local tipstext4 = GUI.CreateStatic(tips,"tipstext4","4.侍从的出战数量会影响侍宠的出战数量。",0,-20,480,120,"system", true)
	GUI.StaticSetFontSize(tipstext4,22)
	local tipstext5 = GUI.CreateStatic(tips,"tipstext5","5.侍宠的出战优先级会按顺序选择。",0,10,480,120,"system", true)
	GUI.StaticSetFontSize(tipstext5,22)
	local tipstext6 = GUI.CreateStatic(tips,"tipstext6","6.主战宠物可以主动控制，侍宠会自动释放技能。",0,40,480,120,"system", true)
	GUI.StaticSetFontSize(tipstext6,22)
	local tipstext7 = GUI.CreateStatic(tips,"tipstext7","7.只有出战宠物可以展示或取消展示。",0,70,480,120,"system", true)
	GUI.StaticSetFontSize(tipstext7,22)
	local tipstext8 = GUI.CreateStatic(tips,"tipstext8","8.每个侍宠都会偷偷分掉一点主宠的经验哦。",0,100,480,120,"system", true)
	GUI.StaticSetFontSize(tipstext8,22)
end

--左下角tips3
function PetUI.OnPetTipBtn3Click()
	if CurpageRefineSubTab == 1 then
		local tips = GUI.TipsCreate(GUI.Get("PetUI/panelBg"), "Tips", 0, 0, 480, 120)  --"1800400290",
		GUI.SetIsRemoveWhenClick(tips, true)
		GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
		local tipstext = GUI.CreateStatic(tips,"tipstext","1.消耗洗炼符可进行普通洗炼。",0,-90,440,100,"system", true)
		GUI.StaticSetFontSize(tipstext,22)
		local tipstext2 = GUI.CreateStatic(tips,"tipstext2","2.额外消耗洗炼精粹可进行高级洗炼。",0,-60,440,120,"system", true)
		GUI.StaticSetFontSize(tipstext2,22)
		local tipstext3 = GUI.CreateStatic(tips,"tipstext3","3.锁定属性不参与洗炼，单次锁定条目越多，消耗洗炼锁定符越多。",0,-15,440,120,"system", true)
		GUI.StaticSetFontSize(tipstext3,22)
		local tipstext4 = GUI.CreateStatic(tips,"tipstext4","4.洗炼结果有强有弱，高级洗炼效果更佳。如果运气不好，不妨试试锁定",0,45,440,120,"system", true)
		GUI.StaticSetFontSize(tipstext4,22)
		local tipstext5 = GUI.CreateStatic(tips,"tipstext5","5.洗炼出满意的结果记得保存哦。",0,90,440,120,"system", true)
		GUI.StaticSetFontSize(tipstext5,22)
	elseif CurpageRefineSubTab == 2 then
		local tips = GUI.TipsCreate(GUI.Get("PetUI/panelBg"), "Tips", 0, 0, 480, 200)  --"1800400290",
		GUI.SetIsRemoveWhenClick(tips, true)
		GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
		local tipstext = GUI.CreateStatic(tips,"tipstext","1.宠物突破需要吞噬同品质同星级的宠物，吞噬数量与星级一致。",0,-120,420,100,"system", true)
		GUI.StaticSetFontSize(tipstext,22)
		local tipstext2 = GUI.CreateStatic(tips,"tipstext2","2.星级提升可以提升宠物的资质上限，特定星级会解锁特殊技能。",0,-60,420,120,"system", true)
		GUI.StaticSetFontSize(tipstext2,22)
		local tipstext3 = GUI.CreateStatic(tips,"tipstext3","3.宠物一经吞噬，不可逆转。",0,-15,420,120,"system", true)
		GUI.StaticSetFontSize(tipstext3,22)
		local tipstext4 = GUI.CreateStatic(tips,"tipstext4","4.参战、展示、锁定的宠物不能参与吞噬。",0,15,420,120,"system", true)
		GUI.StaticSetFontSize(tipstext4,22)
		local tipstext5 = GUI.CreateStatic(tips,"tipstext5","5.突破获得的技能永久绑定，不能被提取或解绑，且可以与其他绑定技能同时存在。",0,60,420,120,"system", true)
		GUI.StaticSetFontSize(tipstext5,22)
		local tipstext6 = GUI.CreateStatic(tips,"tipstext6","6.突破之后的宠物还原之后，星级会重置为一星。",0,120,420,120,"system", true)
		GUI.StaticSetFontSize(tipstext6,22)		
		
	end
end


function PetUI.OnPettipsCloseClick()
    local tips =_gt.GetUI("tips3")
	if tips  then
		GUI.SetVisible(tips,false)
	end
end

function PetUI.OnAutoAttackBtnClick()
	if PetUI.petGuid~=nil then
		local panelBg =GUI.Get("PetUI/panelBg")
		SkillItemUtil.CreateSelectSkillPanel(panelBg, "AutoAttackTip", 150, 15, PetUI.petGuid)
	end
	
	-- local tips = GUI.TipsCreate(GUI.Get("PetUI/panelBg"), "Tips", 150, 15, 360, 320)  --"1800400290",
    -- GUI.SetIsRemoveWhenClick(tips, true)
	-- GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
	-- local tipsmidicon = GUI.ImageCreate(tips,"tipsmidicon","1801401070",0,-100,false,320,3)
	-- local Attackbtn_bg = GUI.ImageCreate(tips,"Attackbtn_bg","1800700230",-110,-160,false,81,81)
	-- local Attackbtn = GUI.ButtonCreate(Attackbtn_bg,"Attackbtn","1800802060",0,0,Transition.ColorTint)
	-- GUI.RegisterUIEvent(Attackbtn, UCE.PointerClick, "PetUI", "OnAttackbtnClick")
	-- local Defense_bg = GUI.ImageCreate(tips,"Attackbtn_bg","1800700230",0,-160,false,81,81)
	-- local Defensebtn = GUI.ButtonCreate(Defense_bg,"Defensebtn","1800802050",0,0,Transition.ColorTint)
	-- GUI.RegisterUIEvent(Defensebtn, UCE.PointerClick, "PetUI", "OnDefensebtnClick")
end



--当按装备培养
function PetUI.OnEquipRepairItemBtnClick()
   GUI.OpenWnd("PetEquipRepairUI")
end

--当按炼化资质按钮
function PetUI.OnRefineBtnClick()
	PetUI.OnRefineToggle()
end


---------------------------------------------------------------------------------------养成开始---------------------------------------------------
-- local Item_Index =1
-- local SkillStudy_Index = 1
-- local Restore_Index = 1
-- local Extract_Index = 1
-- local SkillBind_Index = 1
--公共部分
-- local EffectAttrName = {"物理攻击","法术攻击","物理防御","血量资质","速度资质","经验","宠物忠诚度","宠物寿命","复活","洗点"}
local EffectAttrName = {
    ["血量上限"] = "RoleAttrHpLimit",
    ["经验"] = { "RoleAttrExp", "RoleAttrExpLimit"},
	["宠物忠诚度"] = {"PetAttrLoyalty"},
    ["宠物寿命"] = {"PetAttrLife"},
	["复活"] = {"PetAttrLife"},
    ["洗点"] = {"RoleAttrRemainPoint"},
    ["物理攻击"] = "RoleAttrPhyAtk",
    ["法术攻击"] = "RoleAttrMagAtk",
    ["物理防御"] = "RoleAttrPhyDef",
    ["法术防御"] = "RoleAttrMagDef",
    ["战斗速度"] = "RoleAttrFightSpeed",

    ["Str"] = { "力量加点", "RoleAttrStrPoint" },
    ["Int"] = { "法力加点", "RoleAttrIntPoint" },
    ["Vit"] = { "体质加点", "RoleAttrVitPoint" },
    ["End"] = { "耐力加点", "RoleAttrEndPoint" },
    ["Agi"] = { "敏捷加点", "RoleAttrAgiPoint" },
	
	
    ["血量资质"] = { "PetAttrHpTalent","TalentHPMax","TalentHPMin" },
    ["速度资质"] = { "PetAttrSpeedTalent","TalentSpeedMax","TalentSpeedMin" },
    ["物攻资质"] = { "PetAttrPhyAtkTalent","TalentPhyAtkMax" ,"TalentPhyAtkMin"},
    ["物防资质"] = { "PetAttrPhyDefTalent","TalentPhyDefMax","TalentPhyDefMin" },
    ["法攻资质"] = { "PetAttrMagAtkTalent","TalentMagAtkMax","TalentMagAtkMin"},
    ["法防资质"] = { "PetAttrMagDefTalent","TalentMagDefMax","TalentMagDefMin"},

	}
	
function PetUI.CreateEduBase()
	local pageEduPanel = GUI.Get(pageNames[2][2])
	if pageEduPanel ~= nil then
        return
    end	
	local panelBg = GUI.Get("PetUI/panelBg")
	pageEduPanel = GUI.GroupCreate( panelBg, "pageEduPanel",0, 0, 0, 0)
    SetAnchorAndPivot(pageEduPanel, UIAnchor.Center, UIAroundPivot.Center)
	-- parent = pageEduPanel
	
	local pageEduPanelBg = GUI.ImageCreate(pageEduPanel,"pageEduPanelBg", "1800400200", 170, 28, false, 710,530)
    GUI.SetAnchor(pageEduPanelBg, UIAnchor.Center)
    GUI.SetPivot(pageEduPanelBg, UIAroundPivot.Center)	
	
	local pageEduPanelBg2 = GUI.ImageCreate(pageEduPanelBg,"pageEduPanelBg2", "1800700130", 0, 0, false, 710,530)
    GUI.SetAnchor(pageEduPanelBg2, UIAnchor.Center)
    GUI.SetPivot(pageEduPanelBg2, UIAroundPivot.Center)		
	

	
    -- 创建各分页按钮
    local btnWidth = 140
    local btnHeight = 43
    for i = 1, #tabBtns2 do
		local tempBtn = GUI.ButtonCreate( pageEduPanel, tabBtns2[i][2], "1800402030", -182.5 + (i - 1) * btnWidth, -275, Transition.None, "", btnWidth, btnHeight, false)
        SetAnchorAndPivot(tempBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
		tabBtns2[i].guid = GUI.GetGuid(tempBtn)
        local btnSprite = GUI.ImageCreate( tempBtn, "btnSprite", "1800402032", 0, 0, false, btnWidth, btnHeight)
        SetAnchorAndPivot(btnSprite, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetVisible(btnSprite, false)

        local labelTxt = GUI.CreateStatic( tempBtn, tabBtns2[i][2] .. "label", tabBtns2[i][1], 0, 0, btnWidth, btnHeight, "system", true, false)
        SetAnchorAndPivot(labelTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(labelTxt, fontSizeDefault)
        GUI.StaticSetAlignment(labelTxt, TextAnchor.MiddleCenter)
        GUI.SetColor(labelTxt, colorDark)

        GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "PetUI", "OnTabBtnClick")
    end
	
	local EduPetModelGroup = GUI.GroupCreate(pageEduPanelBg, "EduPetModelGroup", 0, 0,1280,720);
	_gt.BindName(EduPetModelGroup, "EduPetModelGroup");
	
	--养成页宠物模型背景
	local EduModelBg = GUI.ImageCreate(EduPetModelGroup, "EduModelBg", "1800700120", -190, -125);
	_gt.BindName(EduModelBg,"EduModelBg")
	
	--宠物阴影
	local EduShadow = GUI.ImageCreate(EduPetModelGroup, "EduShadow", "1800400240", -190, -60);
	_gt.BindName(EduShadow,"EduShadow")
  
	--宠物模型
	local EduModel = GUI.RawImageCreate(EduPetModelGroup, false, "EduModel", "", -190, -155, 50, false, 560, 560)
	_gt.BindName(EduModel, "EduModel");
	EduModel:RegisterEvent(UCE.Drag)
	GUI.AddToCamera(EduModel);
	GUI.RawImageSetCameraConfig(EduModel, "(1.65,1.4,2),(-0.04464257,0.9316535,-0.1226545,-0.3390941),True,5,0.01,1.95,1E-05");
	EduModel:RegisterEvent(UCE.PointerClick)
	GUI.RegisterUIEvent(EduModel, UCE.PointerClick, "PetUI", "OnEduModelClick")
	local EduPetModel = GUI.RawImageChildCreate(EduModel, true, "EduPetModel", "", 0, 0)
	_gt.BindName(EduPetModel, "EduPetModel");
	GUI.BindPrefabWithChild(EduModel, GUI.GetGuid(EduPetModel))
	GUI.RegisterUIEvent(EduPetModel, ULE.AnimationCallBack, "PetUI", "OnEduAnimationCallBack")
	
	for i =1 ,6 do
		local EduStarLevel = GUI.ImageCreate(EduPetModelGroup, "EduStarLevel"..i, "1801202192", -270+(i*25), 10,false,30,30)
	end
	
	local EduPetName = GUI.CreateStatic(EduPetModelGroup,"EduPetName","",-185,40,800,200)
	GUI.SetColor(EduPetName, UIDefine.BrownColor);
	GUI.StaticSetFontSize(EduPetName, 20)
	GUI.StaticSetAlignment(EduPetName, TextAnchor.MiddleCenter)
	
		
	---已绑定
	local EdubindLabel = GUI.ImageCreate(EduPetModelGroup, "EdubindLabel", "1800704050", -305, -220);
	_gt.BindName(EdubindLabel, "EdubindLabel");
		-- 宠物类型
	local EdupetTypeLabel = GUI.ImageCreate(EduPetModelGroup, "EdupetTypeLabel", "1800704040", -40, -210)
	_gt.BindName(EdupetTypeLabel, "EdupetTypeLabel");	
	
	
	local EduTip = GUI.ButtonCreate( EduPetModelGroup, "EduTip", "1800702030", -310 , -5 , Transition.ColorTint)
	SetAnchorAndPivot(EduTip, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(EduTip, UCE.PointerClick, "PetUI", "OnEduTipClick")	
	
	-- 滚动窗口背景
    local itemScrollWndBg = GUI.ImageCreate(pageEduPanelBg, "itemScrollWndBg", "1800700050", -178, 152, false, 340, 210)
    SetAnchorAndPivot(itemScrollWndBg, UIAnchor.Center, UIAroundPivot.Center)
	
	local itemScrollWnd = GUI.LoopScrollRectCreate(itemScrollWndBg, "itemScrollWnd", 3, 0, 324, 184,
	"PetUI", "CreateItemScroll", "PetUI", "RefreshItemScroll", 0, false, Vector2.New(80, 80), 4, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(itemScrollWnd, UILayout.Center)
	_gt.BindName(itemScrollWnd, "itemScrollWnd")
	
    -- 道具描述
    local itemDetailBg = GUI.ImageCreate(pageEduPanelBg, "itemDetailBg", "1800700050", 170, 152, false, 340, 210)
    SetAnchorAndPivot(itemDetailBg, UIAnchor.Center, UIAroundPivot.Center)
	local itemDetailIcon = GUI.ItemCtrlCreate(itemDetailBg,"itemDetailIcon","1800400050",-120,-50,0,0,false)
	_gt.BindName(itemDetailIcon,"itemDetailIcon")
	local itemDetailName = GUI.CreateStatic(itemDetailBg,"itemDetailName","",20,-50,300,60)
	GUI.SetColor(itemDetailName, UIDefine.BrownColor);
	GUI.StaticSetFontSize(itemDetailName, 24)
	GUI.StaticSetAlignment(itemDetailName, TextAnchor.MiddleCenter)
	_gt.BindName(itemDetailName,"itemDetailName")
	local itemDetailScrollWnd = GUI.ScrollRectCreate(itemDetailBg, "itemDetailScrollWnd", 0, 20, 324, 60, 0, false, Vector2.New(300,150), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    SetAnchorAndPivot(itemDetailScrollWnd, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(itemDetailScrollWnd,"itemDetailScrollWnd")
	local itemDetailScrollText = GUI.CreateStatic(itemDetailScrollWnd,"itemDetailScrollText","",0,0,300,50)
	GUI.SetColor(itemDetailScrollText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(itemDetailScrollText, 24)
	GUI.StaticSetAlignment(itemDetailScrollText, TextAnchor.UpperLeft)
	_gt.BindName(itemDetailScrollText,"itemDetailScrollText")
	--按钮
	local TrainingItemUseBtn = GUI.ButtonCreate(itemDetailBg,"TrainingItemUseBtn","1800402110",15,155,Transition.ColorTint,"使用一次",130,45,false)
	SetAnchorAndPivot(TrainingItemUseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(TrainingItemUseBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(TrainingItemUseBtn, 24)
	GUI.RegisterUIEvent(TrainingItemUseBtn, UCE.PointerClick, "PetUI", "OnTrainingItemUseBtnClick")
	_gt.BindName(TrainingItemUseBtn,"TrainingItemUseBtn")
	GUI.SetVisible(TrainingItemUseBtn,false)
	
	local TrainingItem10UseBtn = GUI.ButtonCreate(itemDetailBg,"TrainingItem10UseBtn","1800402110",195,155,Transition.ColorTint,"使用十次",130,45,false)
	SetAnchorAndPivot(TrainingItem10UseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(TrainingItem10UseBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(TrainingItem10UseBtn, 24)
	GUI.RegisterUIEvent(TrainingItem10UseBtn, UCE.PointerClick, "PetUI", "OnTrainingItem10UseBtnClick")
	_gt.BindName(TrainingItem10UseBtn,"TrainingItem10UseBtn")
	GUI.SetVisible(TrainingItem10UseBtn,false)
	
	local LearningItemUseBtn = GUI.ButtonCreate(itemDetailBg,"LearningItemUseBtn","1800402110",100,155,Transition.ColorTint,"学习",130,45,false)
	SetAnchorAndPivot(LearningItemUseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(LearningItemUseBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(LearningItemUseBtn, 24)
	GUI.RegisterUIEvent(LearningItemUseBtn, UCE.PointerClick, "PetUI", "OnLearningItemUseBtnClick")
	_gt.BindName(LearningItemUseBtn,"LearningItemUseBtn")
	GUI.SetVisible(LearningItemUseBtn,false)
	
	local RestoreUseBtn = GUI.ButtonCreate(itemDetailBg,"RestoreUseBtn","1800402110",100,155,Transition.ColorTint,"还原",130,45,false)
	SetAnchorAndPivot(RestoreUseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(RestoreUseBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(RestoreUseBtn, 24)
	GUI.RegisterUIEvent(RestoreUseBtn, UCE.PointerClick, "PetUI", "OnRestoreUseBtnClick")
	GUI.SetEventCD(RestoreUseBtn,UCE.PointerClick,1)
	_gt.BindName(RestoreUseBtn,"RestoreUseBtn")
	GUI.SetVisible(RestoreUseBtn,false)
	
	local ExtractUseBtn = GUI.ButtonCreate(itemDetailBg,"ExtractUseBtn","1800402110",100,155,Transition.ColorTint,"提取",130,45,false)
	SetAnchorAndPivot(ExtractUseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(ExtractUseBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(ExtractUseBtn, 24)
	GUI.RegisterUIEvent(ExtractUseBtn, UCE.PointerClick, "PetUI", "OnExtractUseBtnClick")
	_gt.BindName(ExtractUseBtn,"ExtractUseBtn")
	GUI.SetVisible(ExtractUseBtn,false)
	
	local SkillBindUseBtn = GUI.ButtonCreate(itemDetailBg,"SkillBindUseBtn","1800402110",100,155,Transition.ColorTint,"绑定",130,45,false)
	SetAnchorAndPivot(SkillBindUseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(SkillBindUseBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(SkillBindUseBtn, 24)
	GUI.RegisterUIEvent(SkillBindUseBtn, UCE.PointerClick, "PetUI", "OnSkillBindUseBtnClick")
	_gt.BindName(SkillBindUseBtn,"SkillBindUseBtn")
	GUI.SetVisible(SkillBindUseBtn,false)

	local SkillUnBindUseBtn = GUI.ButtonCreate(itemDetailBg,"SkillUnBindUseBtn","1800402110",100,155,Transition.ColorTint,"解绑",130,45,false)
	SetAnchorAndPivot(SkillUnBindUseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(SkillUnBindUseBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(SkillUnBindUseBtn, 24)
	GUI.RegisterUIEvent(SkillUnBindUseBtn, UCE.PointerClick, "PetUI", "OnSkillUnBindUseBtnClick")
	_gt.BindName(SkillUnBindUseBtn,"SkillUnBindUseBtn")
	GUI.SetVisible(SkillUnBindUseBtn,false)	
	
	
	--立绘
	local AnimationPanel = GUI.ImageCreate(pageEduPanelBg,"AnimationPanel","1800708010",240,-50,true)
	SetAnchorAndPivot(AnimationPanel, UIAnchor.Center, UIAroundPivot.Center)
	local AnimationTips = GUI.ImageCreate(AnimationPanel,"AnimationTips","1800700240",-75,-130,true)
	SetAnchorAndPivot(AnimationTips, UIAnchor.Center, UIAroundPivot.Center)
	local AnimationTipsText = GUI.CreateStatic(AnimationTips,"AnimationTipsText","快去获得培养道具吧~",0,0,300,50)
	GUI.SetColor(AnimationTipsText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(AnimationTipsText, 22)
	GUI.StaticSetAlignment(AnimationTipsText, TextAnchor.MiddleCenter)
	_gt.BindName(AnimationPanel,"AnimationPanel")
	_gt.BindName(AnimationTipsText,"AnimationTipsText")
end

--当点击宠物信息展示Tips
function PetUI.OnEduTipClick()
	if PetUI.petGuid ~= nil then
		GUI.OpenWnd("PetInfoUI","2,"..PetUI.petGuid)
	end

end
-- 创建item
function PetUI.CreateItemScroll()
	local itemScrollWnd = _gt.GetUI("itemScrollWnd")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(itemScrollWnd);
	local EduItem = GUI.ItemCtrlCreate(itemScrollWnd, "EduItem" .. curCount, "1800400050", 0, 0, 89, 89)
	GUI.RegisterUIEvent(EduItem, UCE.PointerClick, "PetUI", "OnItemClick")
	local Selectedimg = GUI.ImageCreate(EduItem,"Selectedimg","1800400280",0,0,true)
	SetAnchorAndPivot(Selectedimg, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetVisible(Selectedimg,false)
	return EduItem;
end

-- 刷新Item项
function PetUI.RefreshItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local EduItem = GUI.GetByGuid(guid);
	-- local Selectedimg = GUI.GetChild(EduItem,"Selectedimg")
	-- GUI.SetVisible(Selectedimg,false)
	local index = index+1
	local Selectedimg = GUI.GetChild(EduItem,"Selectedimg")
	if	CurpageEduSubTab == 1 then
		GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,nil)
		if index <= #GlobalProcessing.ShowItemList then
			if Item_Index == index then
			GUI.SetVisible(Selectedimg,true)
			else
			GUI.SetVisible(Selectedimg,false)
			end
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.ShowItemList[index]["ItemKeyName"])
			GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Icon,itemDB.Icon)
			if LD.GetItemCountById(itemDB.Id) == 0 then
				GUI.ItemCtrlSetIconGray(EduItem,true)
				GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.RightBottomNum ,nil)
			else
				GUI.ItemCtrlSetIconGray(EduItem,false)
				GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.RightBottomNum ,LD.GetItemCountById(itemDB.Id))
				-- GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Selected,nil)
				-- GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Selected,"1800400280")
			end
		else
		GUI.SetVisible(Selectedimg,false)
		GUI.ItemCtrlSetIconGray(EduItem,false);
		GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.Icon, nil);
		-- GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.LeftTopSp, nil);
		-- GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightTopSp, nil);
		-- GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.LeftBottomSp, nil);
		GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum, nil);
		-- GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Selected,"1800400280")
		end
	elseif CurpageEduSubTab == 2 then	
		-- GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,nil)
		if index <= #GlobalProcessing.ShowSkillEduList then
			if SkillStudy_Index == index then
			GUI.SetVisible(Selectedimg,true)
			else
			GUI.SetVisible(Selectedimg,false)
			end
			local data = GlobalProcessing.ShowSkillEduList[index]
			local itemDB = DB.GetOnceItemByKey2(data.keyname)
			GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Icon,itemDB.Icon)
			if GlobalProcessing.SkillEduGuidList[index] then
				--是否绑定
				local isBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,GlobalProcessing.SkillEduGuidList[index])
				if isBind == "1" then
					GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,"1800707120")
				else
					GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,nil)
				end		
				GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum, tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,GlobalProcessing.SkillEduGuidList[index])))	
			end
			-- GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum, nil)
			-- GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Selected,nil)
			if data.num <= 0 then
				GUI.ItemCtrlSetIconGray(EduItem,true)
				GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,nil)
				GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum, nil)
			else
				GUI.ItemCtrlSetIconGray(EduItem,false)
				
				-- GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum, nil)
			end
		else
		GUI.SetVisible(Selectedimg,false)
		GUI.ItemCtrlSetIconGray(EduItem,false)
		GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Icon,nil)
		GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum, nil)
		end
	elseif CurpageEduSubTab == 3 then
		GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,nil)
		if index <= #RestoreItemEduList then
			if Restore_Index == index then
			GUI.SetVisible(Selectedimg,true)
			else
			GUI.SetVisible(Selectedimg,false)
			end
			local itemDB = DB.GetOnceItemByKey2(RestoreItemEduList[index])
			GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Icon,itemDB.Icon)
			GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum,LD.GetItemCountById(itemDB.Id))
			if LD.GetItemCountById(itemDB.Id) == 0 then
				GUI.ItemCtrlSetIconGray(EduItem,true)
				GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.RightBottomNum ,nil)
			else
				GUI.ItemCtrlSetIconGray(EduItem,false)
			end
		else
			GUI.SetVisible(Selectedimg,false)
			GUI.ItemCtrlSetIconGray(EduItem,false)
			GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Icon,nil)
			GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum, nil)
		end
	elseif CurpageEduSubTab == 4 then
		if index <= #SkillExtractItemList  then
			if Extract_Index == index then
			GUI.SetVisible(Selectedimg,true)
			else
			GUI.SetVisible(Selectedimg,false)
			end
			local data = SkillExtractItemList[index]
			local itemDB = DB.GetOnceItemByKey2(data.keyname)
			GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Icon,itemDB.Icon)
			if SkillExtractItemGuid[index] ~= nil then
				GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum,tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,SkillExtractItemGuid[index])))
				--是否绑定
				local isBind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,SkillExtractItemGuid[index])
				if isBind == "1" then
					GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,"1800707120")
				else
					GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,nil)
				end
			else
				GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum,nil)
				GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,nil)
			end
			GUI.ItemCtrlSetIconGray(EduItem,false)
			if data.num == 0 then
				GUI.ItemCtrlSetIconGray(EduItem,true)
				GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.RightBottomNum ,nil)
			else
				GUI.ItemCtrlSetIconGray(EduItem,false)
			end
		else
			GUI.SetVisible(Selectedimg,false)
			GUI.ItemCtrlSetIconGray(EduItem,false)
			GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Icon,nil)
			GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum, nil)
			GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,nil)
		end
	elseif CurpageEduSubTab == 5 then
		GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.LeftTopSp,nil)
		if index <= #SkillBindItemList  then
			if SkillBind_Index == index then
			GUI.SetVisible(Selectedimg,true)
			else
			GUI.SetVisible(Selectedimg,false)
			end
			local itemDB = DB.GetOnceItemByKey2(SkillBindItemList[index])
			local num = LD.GetItemCountById(itemDB.Id)
			GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Icon,itemDB.Icon)
			GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum,num)
			if num == 0 then
				GUI.ItemCtrlSetIconGray(EduItem,true)
				GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.RightBottomNum ,nil)
			else
				GUI.ItemCtrlSetIconGray(EduItem,false)
			end
		else
			GUI.SetVisible(Selectedimg,false)
			GUI.ItemCtrlSetIconGray(EduItem,false)
			GUI.ItemCtrlSetElementValue(EduItem,eItemIconElement.Icon,nil)
			GUI.ItemCtrlSetElementValue(EduItem, eItemIconElement.RightBottomNum, nil)
		end
	end
end

function PetUI.OnItemClick(guid)
	TrainingItemUseKey = ""
	local EduItem = GUI.GetByGuid(guid);
	-- local Selectedimg = GUI.GetChild(EduItem,"Selectedimg")
	-- GUI.SetVisible(Selectedimg,true)
	local itemDetailScrollWnd = _gt.GetUI("itemDetailScrollWnd")
	GUI.ScrollRectSetNormalizedPosition(itemDetailScrollWnd,Vector2.New(0,1))
	
	local index = GUI.ItemCtrlGetIndex(EduItem);
	index = index +1 
	if	CurpageEduSubTab == 1 then
		if index <= #GlobalProcessing.ShowItemList then
			Item_Index =index
			PetUI.ShowItemInfo(Item_Index,guid)
		end
	elseif 	CurpageEduSubTab == 2 then
		if index <= #GlobalProcessing.ShowSkillEduList then
			SkillStudy_Index =index
			PetUI.ShowItemInfo(SkillStudy_Index,guid)
		end
	elseif CurpageEduSubTab == 3 then
		if index <= #RestoreItemEduList then
			Restore_Index = index
			PetUI.ShowItemInfo(Restore_Index,guid)
		end
	elseif CurpageEduSubTab == 4 then
		if index <= #SkillExtractItemList  then
		Extract_Index = index
			PetUI.ShowItemInfo(Extract_Index,guid)
		end
	elseif CurpageEduSubTab == 5 then
		if index <= #SkillBindItemList then
		SkillBind_Index = index
			PetUI.ShowItemInfo(SkillBind_Index,guid)
		end
	end
end

function PetUI.ShowItemInfo(EduIndex,guid)
	local itemScrollWnd =_gt.GetUI("itemScrollWnd")
--不亮
	for i = 0 ,GUI.LoopScrollRectGetTotalCount(itemScrollWnd) do
		local EduItem = GUI.LoopScrollRectGetChildInPool(itemScrollWnd,"EduItem"..i)
		local Selectedimg = GUI.GetChild(EduItem,"Selectedimg")
		GUI.SetVisible(Selectedimg,false)
	end


--使选择的格子点亮
	local index = EduIndex-1
	local EduItem = GUI.LoopScrollRectGetChildInPool(itemScrollWnd,"EduItem"..index)
	if guid ~= nil then
		EduItem = GUI.GetByGuid(guid)
		index = GUI.ItemCtrlGetIndex(EduItem)
	end
--
	local tabTrainingPanel = GUI.Get(tabNames[4][2])
	local tabLearningPanel = GUI.Get(tabNames[5][2])
	local tabRestorePanel = GUI.Get(tabNames[6][2])
	local tabExtractPanel = GUI.Get(tabNames[7][2])
	local tabBindPanel = GUI.Get(tabNames[8][2])
	local AnimationPanel = _gt.GetUI("AnimationPanel")
	local AnimationTipsText = _gt.GetUI("AnimationTipsText")
	GUI.SetVisible(AnimationPanel,false)	
	
--右下角功能按钮	
	local TrainingItemUseBtn = _gt.GetUI("TrainingItemUseBtn")
	local TrainingItem10UseBtn = _gt.GetUI("TrainingItem10UseBtn")
	local LearningItemUseBtn =_gt.GetUI("LearningItemUseBtn")
	local RestoreUseBtn = _gt.GetUI("RestoreUseBtn")
	local ExtractUseBtn = _gt.GetUI("ExtractUseBtn")
	local SkillBindUseBtn = _gt.GetUI("SkillBindUseBtn")
	local SkillUnBindUseBtn = _gt.GetUI("SkillUnBindUseBtn")
	
	local itemDetailScrollText = _gt.GetUI("itemDetailScrollText")
	local itemDetailIcon = _gt.GetUI("itemDetailIcon")
	local itemDetailName = _gt.GetUI("itemDetailName")

	if	CurpageEduSubTab == 1 then
		local Selectedimg = GUI.GetChild(EduItem,"Selectedimg")
		GUI.SetVisible(Selectedimg,true)
		
		GUI.SetVisible(tabTrainingPanel,true)
			
		-- local AnimationPanel = _gt.BindName("AnimationPanel")
			
		local attr1Label = GUI.GetChild(tabTrainingPanel,"attr1Label")
		local attr1Bg = GUI.GetChild(tabTrainingPanel,"attr1Bg")
		local attr1Val = GUI.GetChild(tabTrainingPanel,"attr1Val")
		local attr1Slider = GUI.GetChild(tabTrainingPanel,"attr1Slider")
		local attr1ValText = _gt.GetUI("attr1ValText")
		local attr2ValText = _gt.GetUI("attr2ValText")
			
		local attr2Label = GUI.GetChild(tabTrainingPanel,"attr2Label")
		local attr2Bg = GUI.GetChild(tabTrainingPanel,"attr2Bg")
		local attr2Val = GUI.GetChild(tabTrainingPanel,"attr2Val")
		local attr2Slider = GUI.GetChild(tabTrainingPanel,"attr2Slider")
			
		local remainingLabel = GUI.GetChild(tabTrainingPanel,"remainingLabel")
		local remainingBg = GUI.GetChild(tabTrainingPanel,"remainingBg")
		local remainingVal = GUI.GetChild(tabTrainingPanel,"remainingVal")
			
		-- local itemDetailScrollText = _gt.GetUI("itemDetailScrollText")
		-- local itemDetailIcon = _gt.GetUI("itemDetailIcon")
		-- local itemDetailName = _gt.GetUI("itemDetailName")

		--右下角的信息显示
		local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.ShowItemList[Item_Index]["ItemKeyName"])
		GUI.ItemCtrlSetElementValue (itemDetailIcon,eItemIconElement.Icon,itemDB.Icon)
		GUI.ItemCtrlSetElementValue (itemDetailIcon,eItemIconElement.RightBottomNum ,nil)
		GUI.StaticSetText(itemDetailName,itemDB.Name)
		GUI.StaticSetText(itemDetailScrollText,itemDB.Info)
			
		--右下角按钮
		GUI.ButtonSetShowDisable(TrainingItemUseBtn,true)
		GUI.SetVisible(TrainingItemUseBtn,true)
		GUI.SetVisible(TrainingItem10UseBtn,true)
		GUI.SetVisible(LearningItemUseBtn,false)
		GUI.SetVisible(RestoreUseBtn,false)
		GUI.SetVisible(ExtractUseBtn,false)
		GUI.SetVisible(SkillBindUseBtn,false)
		GUI.SetVisible(SkillUnBindUseBtn,false)
		if PetUI.petGuid ~= nil then
			if LD.GetItemCountById(itemDB.Id) < 10 then
				GUI.ButtonSetShowDisable(TrainingItem10UseBtn,false)
			else
				GUI.ButtonSetShowDisable(TrainingItem10UseBtn,true)
			end
		else
			GUI.ButtonSetShowDisable(TrainingItemUseBtn,false)
			GUI.ButtonSetShowDisable(TrainingItem10UseBtn,false)
		end



		--右上角的信息显示
		
			PetUI.TrainingAttrState = 0 --标记使用物品类型 默认为0 按下面顺序如属性丹1，资质丹2 顺序记录
		--判断是否有宠物
		if PetUI.petGuid ~= nil then
			--判断宠物的类型
			local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,PetUI.petGuid)))
			local petDB =DB.GetOncePetByKey1(petId)
			if GlobalProcessing.MedicinePetType[petDB.Type] then
			--判断有无培养道具
				local itemtable ={}
				
				for i=1 , #GlobalProcessing.ShowItemList do
					if #itemtable > 0 then
						break
					else
						itemDB = DB.GetOnceItemByKey2(GlobalProcessing.ShowItemList[i]["ItemKeyName"])
						if LD.GetItemCountById(itemDB.Id) >0 then
							table.insert(itemtable,i)
						end
					end
				end
				-- CDebug.LogError(#itemtable)
				if #itemtable > 0 then
					local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.ShowItemList[Item_Index]["ItemKeyName"])
					PetUI.ItemCanUseNum = "无限制"
					if  GlobalProcessing.ShowItemList[Item_Index]["MaxLimit"] and  GlobalProcessing.ShowItemList[Item_Index]["MaxLimit"] ~= -1 then
						PetUI.ItemCanUseNum = GlobalProcessing.ShowItemList[Item_Index]["MaxLimit"]-(LD.GetPetIntCustomAttr("PetDevelop_MedicineItemUsedNum_"..itemDB.Id,PetUI.petGuid)) 
					end
					GUI.StaticSetText(remainingVal,PetUI.ItemCanUseNum)
					--如果判断类型为宠物属性丹，则
					if itemDB.Type ==3 and itemDB.Subtype ==13 and itemDB.Subtype2 == 11 then
						GUI.SetVisible(attr1Label,true)
						GUI.SetVisible(attr1Bg,true)
						GUI.SetVisible(attr1Val,true)
						GUI.SetVisible(attr1Slider,false)
						
						GUI.SetVisible(attr2Label,false)
						GUI.SetVisible(attr2Bg,false)
						GUI.SetVisible(attr2Val,false)
						GUI.SetVisible(attr2Slider,false)
						
						local attrname = EffectAttrName[GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]] or DB.GetOnceAttrByKey2(GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]).Name
						GUI.StaticSetText(attr1Val, LD.GetPetIntAttr(RoleAttr[attrname],PetUI.petGuid))
						
						GUI.StaticSetText(attr1Label,DB.GetOnceAttrByKey2(GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]).ChinaName)	
						-- GUI.StaticSetText(remainingVal,PetUI.ItemCanUseNum)
						--如果判断类型为宠物资质丹，则
					elseif itemDB.Type ==3 and itemDB.Subtype ==13 and itemDB.Subtype2 == 13 then
						GUI.SetVisible(attr1Label,true)
						GUI.SetVisible(attr1Bg,false)
						GUI.SetVisible(attr1Val,false)
						GUI.SetVisible(attr1Slider,true)
							 
						GUI.SetVisible(attr2Label,false)
						GUI.SetVisible(attr2Bg,false)
						GUI.SetVisible(attr2Val,false)
						GUI.SetVisible(attr2Slider,false)
						

						
						GUI.StaticSetText(attr1Label,DB.GetOnceAttrByKey2(GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]).ChinaName)		
						-- GUI.StaticSetText(remainingVal,PetUI.ItemCanUseNum)

						local attrTb= EffectAttrName[GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]]
						local attrTb1 = LD.GetPetIntAttr(RoleAttr[attrTb[1]], PetUI.petGuid)
						local attrTb2 = LD.GetPetIntCustomAttr(attrTb[2], PetUI.petGuid)
						GUI.ScrollBarSetPos(attr1Slider,(attrTb1)/(attrTb2))
						GUI.StaticSetText(attr1ValText,(attrTb1) .. "/" ..(attrTb2))
						
						--标记目前选中的为资质丹
						PetUI.TrainingAttrState = 2
						--记录选中的物品对应的资质
						PetUI.TrainingAttrTb1 = attrTb1
						PetUI.TrainingAttrTb2 = attrTb2
						--记录选中的物品的数量
						PetUI.TrainingAttrNum = LD.GetItemCountById(itemDB.Id)
						
						
						--使用十次判断是否可用	
						local Type = tostring(type(GlobalProcessing.ShowItemList[Item_Index]["Effect"][2]))
						
						if Type == "number" then
							local Grade = tonumber(GlobalProcessing.ShowItemList[Item_Index]["Effect"][2])
							if PetUI.TrainingAttrNum >=10 then
								if attrTb1 == attrTb2 or tonumber(PetUI.ItemCanUseNum) and PetUI.ItemCanUseNum ==0 then
								GUI.ButtonSetShowDisable(TrainingItemUseBtn,false)
								GUI.ButtonSetShowDisable(TrainingItem10UseBtn,false)
								elseif Grade >= (PetUI.TrainingAttrTb2 - PetUI.TrainingAttrTb1) then
								GUI.ButtonSetShowDisable(TrainingItemUseBtn,true)
								GUI.ButtonSetShowDisable(TrainingItem10UseBtn,false)
								end
							else
								if attrTb1 == attrTb2 or tonumber(PetUI.ItemCanUseNum) and PetUI.ItemCanUseNum ==0  then
									GUI.ButtonSetShowDisable(TrainingItemUseBtn,false)
								end
							end			
						elseif Type == "table" then
							GUI.ButtonSetShowDisable(TrainingItemUseBtn,true)
							GUI.ButtonSetShowDisable(TrainingItem10UseBtn,false)
							
							if attrTb1 == attrTb2 or tonumber(PetUI.ItemCanUseNum) and PetUI.ItemCanUseNum ==0  then
								GUI.ButtonSetShowDisable(TrainingItemUseBtn,false)
							end
						end
						
			
						
						--如果判断类型为宠物经验，则	
					elseif itemDB.Type ==3 and itemDB.Subtype ==13 and itemDB.Subtype2 == 16 then
						GUI.SetVisible(attr1Label,true)
						GUI.SetVisible(attr1Bg,true)
						GUI.SetVisible(attr1Val,true)
						GUI.SetVisible(attr1Slider,false)
							
						GUI.SetVisible(attr2Label,true)
						GUI.SetVisible(attr2Bg,true)
						GUI.SetVisible(attr2Val,true)
						GUI.SetVisible(attr2Slider,true)
							
							
						GUI.StaticSetText(attr1Label,"宠物等级")	
						GUI.StaticSetText(attr1Val,UIDefine.GetPetLevelStrByGuid(PetUI.petGuid))	
							
							
						local attrTb= EffectAttrName[GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]]
						GUI.StaticSetText(attr2Label,"宠物经验")
								
						GUI.ScrollBarSetPos(attr2Slider, LD.GetPetIntAttr(RoleAttr[attrTb[1]],PetUI.petGuid)/LD.GetPetIntAttr(RoleAttr[attrTb[2]],PetUI.petGuid))
						GUI.StaticSetText(attr2ValText,LD.GetPetIntAttr(RoleAttr[attrTb[1]],PetUI.petGuid) .. "/" .. LD.GetPetIntAttr(RoleAttr[attrTb[2]],PetUI.petGuid))
							
						-- GUI.StaticSetText(remainingVal,PetUI.ItemCanUseNum)
						
						--如果判断类型为忠诚，则	
					elseif itemDB.Type ==3 and itemDB.Subtype ==13 and itemDB.Subtype2 == 12 then
						GUI.SetVisible(attr1Label,true)
						GUI.SetVisible(attr1Bg,true)
						GUI.SetVisible(attr1Val,true)
						GUI.SetVisible(attr1Slider,false)
							
						GUI.SetVisible(attr2Label,false)
						GUI.SetVisible(attr2Bg,false)
						GUI.SetVisible(attr2Val,false)
						GUI.SetVisible(attr2Slider,false)
							
						local attrTb= EffectAttrName[GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]]
						GUI.StaticSetText(attr1Label,DB.GetOnceAttrByKey2(GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]).ChinaName)	
						GUI.StaticSetText(attr1Val,LD.GetPetIntAttr(RoleAttr[attrTb[1]],PetUI.petGuid))	
						-- GUI.StaticSetText(remainingVal,PetUI.ItemCanUseNum)
						
						--如果判断类型为宠物寿命，则							
					elseif itemDB.Type ==3 and itemDB.Subtype ==13 and itemDB.Subtype2 == 17 then
						GUI.SetVisible(attr1Label,true)
						GUI.SetVisible(attr1Bg,true)
						GUI.SetVisible(attr1Val,true)
						GUI.SetVisible(attr1Slider,false)
							
						GUI.SetVisible(attr2Label,false)
						GUI.SetVisible(attr2Bg,false)
						GUI.SetVisible(attr2Val,false)
						GUI.SetVisible(attr2Slider,false)
							
						local attrTb= EffectAttrName[GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]]
						GUI.StaticSetText(attr1Label,"宠物寿命")	
						local temptext = LD.GetPetIntAttr(RoleAttr[attrTb[1]],PetUI.petGuid)
						if petDB.Life == -1 then
							GUI.StaticSetText(attr1Val,"永生")
						else
							GUI.StaticSetText(attr1Val,temptext)
						end
						-- GUI.StaticSetText(remainingVal,PetUI.ItemCanUseNum)
						
						--如果判断类型为宠物复活药，则		
					elseif itemDB.Type ==3 and itemDB.Subtype ==13 and itemDB.Subtype2 == 4 then
						GUI.SetVisible(attr1Label,true)
						GUI.SetVisible(attr1Bg,true)
						GUI.SetVisible(attr1Val,true)
						GUI.SetVisible(attr1Slider,false)
							
						GUI.SetVisible(attr2Label,false)
						GUI.SetVisible(attr2Bg,false)
						GUI.SetVisible(attr2Val,false)
						GUI.SetVisible(attr2Slider,false)
							
						local attrTb= EffectAttrName[GlobalProcessing.ShowItemList[Item_Index]["Effect"][1]]
						GUI.StaticSetText(attr1Label,"宠物寿命")	
						local temptext = LD.GetPetIntAttr(RoleAttr[attrTb[1]],PetUI.petGuid)
						if petDB.Life == -1 then
							GUI.StaticSetText(attr1Val,"永生")
						else
							GUI.StaticSetText(attr1Val,temptext)
						end
						-- GUI.StaticSetText(remainingVal,PetUI.ItemCanUseNum)

					elseif itemDB.Type ==3 and itemDB.Subtype ==13 and itemDB.Subtype2 == 10 then
						GUI.SetVisible(attr1Label,true)
						GUI.SetVisible(attr1Bg,true)
						GUI.SetVisible(attr1Val,true)
						GUI.SetVisible(attr1Slider,false)
							
						GUI.SetVisible(attr2Label,true)
						GUI.SetVisible(attr2Bg,true)
						GUI.SetVisible(attr2Val,true)
						GUI.SetVisible(attr2Slider,false)
							
						GUI.StaticSetText(attr1Label,"当前潜能")
						GUI.StaticSetText(attr1Val,tostring(LD.GetPetAttr(RoleAttr.RoleAttrRemainPoint,PetUI.petGuid)))
						GUI.StaticSetText(attr2Label,"可还原潜能")	
						local SumAttrPoint = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrStrPoint,PetUI.petGuid))) + tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrIntPoint,PetUI.petGuid))) + tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrVitPoint,PetUI.petGuid))) + tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrEndPoint,PetUI.petGuid))) + tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrAgiPoint,PetUI.petGuid)))
						GUI.StaticSetText(attr2Val,tostring(SumAttrPoint))
						-- GUI.StaticSetText(remainingVal,PetUI.ItemCanUseNum)	
					elseif itemDB.Type ==3 and itemDB.Subtype ==13 and itemDB.Subtype2 == 14 then
						GUI.SetVisible(attr1Label,true)
						GUI.SetVisible(attr1Bg,true)
						GUI.SetVisible(attr1Val,true)
						GUI.SetVisible(attr1Slider,false)
							
						GUI.SetVisible(attr2Label,true)
						GUI.SetVisible(attr2Bg,true)
						GUI.SetVisible(attr2Val,true)
						GUI.SetVisible(attr2Slider,false)
						

						local CurPoint= EffectAttrName[GlobalProcessing.ShowItemList[Item_Index]["SubPoint"]]
						local ToPoint= EffectAttrName[GlobalProcessing.ShowItemList[Item_Index]["AddPoint"]]
						
						GUI.StaticSetText(attr1Label,CurPoint[1])
						GUI.StaticSetText(attr1Val,tostring(LD.GetPetAttr(RoleAttr[CurPoint[2]],PetUI.petGuid)))
						GUI.StaticSetText(attr2Label,ToPoint[1])	
						GUI.StaticSetText(attr2Val,tostring(LD.GetPetAttr(RoleAttr[ToPoint[2]],PetUI.petGuid)))
						-- GUI.StaticSetText(remainingVal,PetUI.ItemCanUseNum)	
					end
				else
				GUI.SetVisible(tabTrainingPanel,false)
				GUI.SetVisible(AnimationPanel,true)	
				GUI.StaticSetText(AnimationTipsText,"快去获得培养道具吧~")
				end
			else
				GUI.SetVisible(tabTrainingPanel,false)
				GUI.SetVisible(AnimationPanel,true)	
				GUI.StaticSetText(AnimationTipsText,"该宠物不能进行培养")
			end
		else
			GUI.SetVisible(tabTrainingPanel,false)
			GUI.SetVisible(AnimationPanel,true)	
			GUI.StaticSetText(AnimationTipsText,"您还没有宠物哦")
		end

	elseif	CurpageEduSubTab == 2 then
		local Selectedimg = GUI.GetChild(EduItem,"Selectedimg")
		GUI.SetVisible(Selectedimg,true)
		GUI.SetVisible(tabLearningPanel ,true)
		-- local itemDetailScrollText = _gt.GetUI("itemDetailScrollText")
		-- local itemDetailIcon = _gt.GetUI("itemDetailIcon")
		-- local itemDetailName = _gt.GetUI("itemDetailName")
			
			
			--右下角的信息显示
		local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.ShowSkillEduList[SkillStudy_Index].keyname)
		GUI.ItemCtrlSetElementValue(itemDetailIcon,eItemIconElement.Icon,itemDB.Icon)
		GUI.ItemCtrlSetElementValue (itemDetailIcon,eItemIconElement.RightBottomNum ,nil)
		GUI.StaticSetText(itemDetailName,itemDB.Name)
		GUI.StaticSetText(itemDetailScrollText,itemDB.Info)
			
			--右下角按钮
		GUI.SetVisible(TrainingItemUseBtn,false)
		GUI.SetVisible(TrainingItem10UseBtn,false)
		GUI.SetVisible(RestoreUseBtn,false)
		GUI.SetVisible(LearningItemUseBtn,true)
		GUI.SetVisible(ExtractUseBtn,false)
		GUI.SetVisible(SkillBindUseBtn,false)
		GUI.SetVisible(SkillUnBindUseBtn,false)
		if PetUI.petGuid ~= nil then
			GUI.ButtonSetShowDisable(LearningItemUseBtn,true)
			--判断宠物的类型
			local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,PetUI.petGuid)))
			local petDB =DB.GetOncePetByKey1(petId)
			if GlobalProcessing.SkillStudyPetType[petDB.Type] then
				local itemtable = {}
					for i=1 , #GlobalProcessing.ShowSkillEduList do
						if GlobalProcessing.ShowSkillEduList[i].num ==1 then
							table.insert(itemtable,i)
						end
					end
				if #itemtable > 0 then 
				else
					GUI.SetVisible(tabLearningPanel ,false)
					GUI.SetVisible(AnimationPanel,true)	
					GUI.StaticSetText(AnimationTipsText,"快去搜集宠物技能书吧~")
					GUI.ButtonSetShowDisable(LearningItemUseBtn,true)
				end
			else
			GUI.SetVisible(tabLearningPanel ,false)
			GUI.SetVisible(AnimationPanel,true)	
			GUI.StaticSetText(AnimationTipsText,"该宠物不能进行技能学习")
			GUI.ButtonSetShowDisable(LearningItemUseBtn,false)
			end
		else
			GUI.SetVisible(tabLearningPanel ,false)
			GUI.SetVisible(AnimationPanel,true)	
			GUI.StaticSetText(AnimationTipsText,"您还没有宠物哦")
			GUI.ButtonSetShowDisable(LearningItemUseBtn,false)
		end
	elseif	CurpageEduSubTab == 3 then
		local Selectedimg = GUI.GetChild(EduItem,"Selectedimg")
		GUI.SetVisible(Selectedimg,true)
		GUI.SetVisible(tabRestorePanel,true)
		
		--右下角按钮
		GUI.SetVisible(TrainingItemUseBtn,false)
		GUI.SetVisible(TrainingItem10UseBtn,false)
		GUI.SetVisible(LearningItemUseBtn,false)
		GUI.SetVisible(RestoreUseBtn,true)	
		GUI.SetVisible(ExtractUseBtn,false)
		GUI.SetVisible(SkillBindUseBtn,false)
		GUI.SetVisible(SkillUnBindUseBtn,false)
		
		if PetUI.petGuid ~= nil then
			-- local itemDetailScrollText = _gt.GetUI("itemDetailScrollText")
			-- local itemDetailIcon = _gt.GetUI("itemDetailIcon")
			-- local itemDetailName = _gt.GetUI("itemDetailName")
				
			--右下角的信息显示
			local itemDB = DB.GetOnceItemByKey2(RestoreItemEduList[Restore_Index])
			local star =LD.GetPetIntCustomAttr("PetStarLevel",PetUI.petGuid,pet_container_type.pet_container_panel)
			local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, PetUI.petGuid)
			local PetDB =DB.GetOncePetByKey1(id)
			local CarryLevel = PetDB.CarryLevel
			local RestoreConsume = GlobalProcessing.RestoreConsume
			local Num1 = LD.GetItemCountById(itemDB.Id)
			local Num2 =math.ceil(assert(loadstring(" local StarLevel = "..star.." local CarryLevel = "..CarryLevel.." local RestoreConsume = "..RestoreConsume.." return "..RestoreConsume))())
			GUI.ItemCtrlSetElementValue(itemDetailIcon,eItemIconElement.Icon,itemDB.Icon)
			GUI.ItemCtrlSetElementValue (itemDetailIcon,eItemIconElement.RightBottomNum ,Num1.."/"..Num2)
			local itemDetailNumTxt =GUI.ItemCtrlGetElement(itemDetailIcon,eItemIconElement.RightBottomNum)
			if Num1 >= Num2 then
				GUI.SetColor(itemDetailNumTxt,UIDefine.White2Color)
			else
				GUI.SetColor(itemDetailNumTxt,UIDefine.RedColor)
			end
			GUI.StaticSetText(itemDetailName,itemDB.Name)
			GUI.StaticSetText(itemDetailScrollText,itemDB.Info)

			-- local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,PetUI.petGuid)))
			-- local petDB =DB.GetOncePetByKey1(petId)
			if GlobalProcessing.SkillExtractPetType[PetDB.Type] then
				local itemtable = {}
				for i = 1, #RestoreItemEduList do 
					itemDB = DB.GetOnceItemByKey2(RestoreItemEduList[i])
					if LD.GetItemCountById(itemDB.Id) >0 then
						table.insert(itemtable,i)
					end
				end
					if #itemtable >0 then
					
					else
						GUI.SetVisible(tabRestorePanel,false)
						GUI.SetVisible(AnimationPanel,true)	
						GUI.StaticSetText(AnimationTipsText,"快去收集还原丹吧~")
						GUI.SetVisible(RestoreUseBtn,true)
					end
			else
				GUI.SetVisible(tabRestorePanel,false)
				GUI.SetVisible(AnimationPanel,true)	
				GUI.StaticSetText(AnimationTipsText,"该宠物无法还原哦~")
				GUI.SetVisible(RestoreUseBtn,false)
			end
		else
			GUI.SetVisible(tabRestorePanel,false)
			GUI.SetVisible(AnimationPanel,true)	
			GUI.StaticSetText(AnimationTipsText,"您还没有宠物哦")
			GUI.SetVisible(RestoreUseBtn,false)
		end
	elseif	CurpageEduSubTab == 4 then
		local Selectedimg = GUI.GetChild(EduItem,"Selectedimg")
		GUI.SetVisible(Selectedimg,true)
		GUI.SetVisible(tabExtractPanel,true)
		-- local itemDetailScrollText = _gt.GetUI("itemDetailScrollText")
		-- local itemDetailIcon = _gt.GetUI("itemDetailIcon")
		-- local itemDetailName = _gt.GetUI("itemDetailName")

			--右下角的信息显示	
		if #SkillExtractItemList ~=  0 then
			local itemDB = DB.GetOnceItemByKey2(SkillExtractItemList[Extract_Index].keyname)
			GUI.ItemCtrlSetElementValue(itemDetailIcon,eItemIconElement.Icon,itemDB.Icon)
			GUI.ItemCtrlSetElementValue (itemDetailIcon,eItemIconElement.RightBottomNum ,nil)
			GUI.StaticSetText(itemDetailName,itemDB.Name)
			GUI.StaticSetText(itemDetailScrollText,itemDB.Info)		
		else
			GUI.ItemCtrlSetElementValue(itemDetailIcon,eItemIconElement.Icon,nil)
			GUI.ItemCtrlSetElementValue (itemDetailIcon,eItemIconElement.RightBottomNum ,nil)
			GUI.StaticSetText(itemDetailName,"")
			GUI.StaticSetText(itemDetailScrollText,"")	
		end
		--右下角按钮
		GUI.SetVisible(TrainingItemUseBtn,false)
		GUI.SetVisible(TrainingItem10UseBtn,false)
		GUI.SetVisible(LearningItemUseBtn,false)
		GUI.SetVisible(RestoreUseBtn,false)	
		GUI.SetVisible(ExtractUseBtn,true)	
		GUI.SetVisible(SkillBindUseBtn,false)
		GUI.SetVisible(SkillUnBindUseBtn,false)
		if PetUI.petGuid ~= nil then
			GUI.ButtonSetShowDisable(ExtractUseBtn,true)
			local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,PetUI.petGuid)))
			local petDB =DB.GetOncePetByKey1(petId)
			if GlobalProcessing.SkillBindPetType[petDB.Type] then
				if	#SkillExtractItemList ~=  0 then	
				
				else
					GUI.SetVisible(tabExtractPanel,false)
					GUI.SetVisible(AnimationPanel,true)	
					GUI.StaticSetText(AnimationTipsText,"快去收集技能提取卡吧~")
					GUI.ButtonSetShowDisable(ExtractUseBtn,false)
				end
			else
				GUI.SetVisible(tabExtractPanel,false)
				GUI.SetVisible(AnimationPanel,true)	
				GUI.StaticSetText(AnimationTipsText,"该宠物不能进行技能提取哦~")
				GUI.ButtonSetShowDisable(ExtractUseBtn,false)
			end
		else
			GUI.SetVisible(tabExtractPanel,false)
			GUI.SetVisible(AnimationPanel,true)	
			GUI.StaticSetText(AnimationTipsText,"您还没有宠物哦")
			GUI.ButtonSetShowDisable(ExtractUseBtn,false)
		end
	elseif	CurpageEduSubTab == 5 then
		local Selectedimg = GUI.GetChild(EduItem,"Selectedimg")
		GUI.SetVisible(Selectedimg,true)
		GUI.SetVisible(tabBindPanel,true)
		-- local itemDetailScrollText = _gt.GetUI("itemDetailScrollText")
		-- local itemDetailIcon = _gt.GetUI("itemDetailIcon")
		-- local itemDetailName = _gt.GetUI("itemDetailName")
			
		local itemDB = DB.GetOnceItemByKey2(SkillBindItemList[SkillBind_Index])
		GUI.ItemCtrlSetElementValue(itemDetailIcon,eItemIconElement.Icon,itemDB.Icon)
		GUI.ItemCtrlSetElementValue (itemDetailIcon,eItemIconElement.RightBottomNum ,nil)
		GUI.StaticSetText(itemDetailName,itemDB.Name)
		GUI.StaticSetText(itemDetailScrollText,itemDB.Info)		

		--右下角按钮
		GUI.SetVisible(TrainingItemUseBtn,false)
		GUI.SetVisible(TrainingItem10UseBtn,false)
		GUI.SetVisible(LearningItemUseBtn,false)
		GUI.SetVisible(RestoreUseBtn,false)	
		GUI.SetVisible(ExtractUseBtn,false)	

		if PetUI.petGuid ~= nil then
			GUI.ButtonSetShowDisable(SkillBindUseBtn,true)
			GUI.ButtonSetShowDisable(SkillUnBindUseBtn,true)	
			local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,PetUI.petGuid)))
			local petDB =DB.GetOncePetByKey1(petId)
			if GlobalProcessing.SkillBindPetType[petDB.Type] then
				local itemtable = {}
				for i=1 , #SkillBindItemList do
					local itemDB = DB.GetOnceItemByKey2(SkillBindItemList[i])
					if LD.GetItemCountById(itemDB.Id) > 0 then
						table.insert(itemtable,i)
					end
				end
				if #itemtable > 0 then
				
				else
					GUI.SetVisible(tabBindPanel,false)
					GUI.SetVisible(AnimationPanel,true)	
					GUI.StaticSetText(AnimationTipsText,"快去搜集技能绑定符吧~")
					GUI.ButtonSetShowDisable(ExtractUseBtn,false)
				end
			else
				GUI.SetVisible(tabBindPanel,false)
				GUI.SetVisible(AnimationPanel,true)	
				GUI.StaticSetText(AnimationTipsText,"该宠物不能进行技能绑定哦~")
				GUI.ButtonSetShowDisable(ExtractUseBtn,false)
			end
		else
			GUI.SetVisible(tabBindPanel,false)
			GUI.SetVisible(AnimationPanel,true)	
			GUI.StaticSetText(AnimationTipsText,"您还没有宠物哦")
			GUI.ButtonSetShowDisable(SkillBindUseBtn,false)
			GUI.ButtonSetShowDisable(SkillUnBindUseBtn,false)
		end	
		if SkillBind_Index ==2 then
			GUI.SetVisible(SkillBindUseBtn,false)
			GUI.SetVisible(SkillUnBindUseBtn,true)
		else
			GUI.SetVisible(SkillBindUseBtn,true)
			GUI.SetVisible(SkillUnBindUseBtn,false)	
		end
	end
	
	--调整滑动框大小
	local h = GUI.StaticGetLabelPreferHeight(itemDetailScrollText)
	local itemDetailScrollWnd = _gt.GetUI("itemDetailScrollWnd")
	GUI.ScrollRectSetChildSize(itemDetailScrollWnd,Vector2.New(300, h))

end
---------------------------------------------------------------------------------------宠物培养 --------------------------------------------------
function PetUI.CreateTrainingTab()
	local pageEduPanelBg = GUI.Get(pageNames[2][2].."/pageEduPanelBg")
	if pageEduPanelBg == nil then
        return
    end
	local tabLearningPanel = GUI.Get(tabNames[5][2])
	GUI.SetVisible(tabLearningPanel,false)
	local tabRestorePanel = GUI.Get(tabNames[6][2])
	GUI.SetVisible(tabRestorePanel,false)
	local tabExtractPanel = GUI.Get(tabNames[7][2])
	GUI.SetVisible(tabExtractPanel,false)
	local tabBindPanel = GUI.Get(tabNames[8][2])
	GUI.SetVisible(tabBindPanel,false)
	local tabTrainingPanel = GUI.Get(tabNames[4][2])
    if tabTrainingPanel ~= nil then 
		GUI.SetVisible(tabTrainingPanel,true)
        return
    end
    local tabTrainingPanel = GUI.GroupCreate(pageEduPanelBg,"tabTrainingPanel", 0, 0,0,0)
    GUI.SetAnchor(tabTrainingPanel, UIAnchor.Center)
    GUI.SetPivot(tabTrainingPanel, UIAroundPivot.Center)
	
--经验道具
	--等级
    local attr1Label = GUI.CreateStatic( tabTrainingPanel, "attr1Label", "宠物等级", -20, -205, 120, 34, "system", true, false)
    SetAnchorAndPivot(attr1Label, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(attr1Label, fontSizeDefault)
    GUI.SetColor(attr1Label, colorDark)
    GUI.StaticSetAlignment(attr1Label, TextAnchor.MiddleRight)

    local attr1Bg = GUI.ImageCreate( tabTrainingPanel, "attr1Bg", "1800600040", 116, -207, false, 227, 35)
    SetAnchorAndPivot(attr1Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(attr1Bg, true)
 
    local attr1Val = GUI.CreateStatic( tabTrainingPanel, "attr1Val", "90", 116, -207, 227, 35, "system", true, false)
    SetAnchorAndPivot(attr1Val, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(attr1Val, fontSizeDefault)
    GUI.StaticSetAlignment(attr1Val, TextAnchor.MiddleCenter)
    GUI.SetColor(attr1Val, colorWhite)
	--资质
    local attr1Slider = GUI.ScrollBarCreate( tabTrainingPanel, "attr1Slider", "", "1800408160", "1800408110", 231, -189, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    SetAnchorAndPivot(attr1Slider, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local silderFillSize = Vector2.New(227, 35)
    GUI.ScrollBarSetFillSize(attr1Slider, silderFillSize)
    GUI.ScrollBarSetBgSize(attr1Slider, silderFillSize)

    local attr1ValText = GUI.CreateStatic( attr1Slider, "text", "1000", 0, 1, 160, 34, "system", true)
    SetAnchorAndPivot(attr1ValText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(attr1ValText, fontSizeDefault)
	GUI.StaticSetAlignment(attr1ValText, TextAnchor.MiddleCenter)
	_gt.BindName(attr1ValText,"attr1ValText")

    --属性2
    local attr2Label = GUI.CreateStatic( tabTrainingPanel, "attr2Label", "宠物经验", -20, -165, 120, 34, "system", true, false)
    SetAnchorAndPivot(attr2Label, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(attr2Label, fontSizeDefault)
    GUI.SetColor(attr2Label, colorDark)
    GUI.StaticSetAlignment(attr2Label, TextAnchor.MiddleRight)

    --可还原潜能
    local attr2Bg = GUI.ImageCreate( tabTrainingPanel, "attr2Bg", "1800600040", 116, -169, false, 227, 35)
    SetAnchorAndPivot(attr2Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(attr2Bg, false)

   
    local attr2Val = GUI.CreateStatic( tabTrainingPanel, "attr2Val", "", 116, -169, 227, 35, "system", true, false)
    SetAnchorAndPivot(attr2Val, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(attr2Val, fontSizeDefault)
    GUI.StaticSetAlignment(attr2Val, TextAnchor.MiddleCenter)
    GUI.SetColor(attr2Val, colorWhite)
    GUI.SetVisible(attr2Val, false)
	
	--宠物经验
    local attr2Slider = GUI.ScrollBarCreate( tabTrainingPanel, "attr2Slider", "", "1800408160", "1800408110", 230, -152, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    SetAnchorAndPivot(attr2Slider, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local silderFillSize = Vector2.New(225, 35)
    GUI.ScrollBarSetFillSize(attr2Slider, silderFillSize)
    GUI.ScrollBarSetBgSize(attr2Slider, silderFillSize)

    local attr2ValText = GUI.CreateStatic( attr2Slider, "text", "1000", 0, 1, 300, 34, "system", true)
    SetAnchorAndPivot(attr2ValText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(attr2ValText, fontSizeDefault)
	GUI.StaticSetAlignment(attr2ValText, TextAnchor.MiddleCenter)
	_gt.BindName(attr2ValText,"attr2ValText")

    -- 剩余使用次数
    local remainingLabel = GUI.CreateStatic( tabTrainingPanel, "remainingLabel", "可使用数量", -20, -125, 120, 34, "system", true, false)
    SetAnchorAndPivot(remainingLabel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(remainingLabel, fontSizeDefault)
    GUI.SetColor(remainingLabel, colorDark)
    GUI.StaticSetAlignment(remainingLabel, TextAnchor.MiddleRight)

    -- 剩余使用次数背景
    local remainingBg = GUI.ImageCreate( tabTrainingPanel, "remainingBg", "1800600040", 161, -127, false, 183, 35)
    SetAnchorAndPivot(remainingBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(remainingBg, true)

    -- 属性1
    local remainingVal = GUI.CreateStatic( tabTrainingPanel, "remainingVal", "10", 161, -127, 183, 35, "system", true, false)
    SetAnchorAndPivot(remainingVal, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(remainingVal, fontSizeDefault)
    GUI.StaticSetAlignment(remainingVal, TextAnchor.MiddleCenter)
    GUI.SetColor(remainingVal, colorWhite)
	
	-- PetUI.RefreshTrainingTab()
end

-- local GlobalProcessing.ShowItemList = {}
-- local GlobalProcessing.ShowItemNumList = {}
	
function PetUI.RefreshTrainingTab()
	if GlobalProcessing.ShowItemList then
		local count = #GlobalProcessing.ShowItemList
		if ToEduIndex ==1 then
			for i = 1,count do
				if ToEduIndex ==1 then
					if GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "宠物经验丹" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "宠物经验丹2" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 			
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "宠物经验丹3" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "宠物大经验丹" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 					
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "宠物经验丹" and  GlobalProcessing.ShowItemNumList[i] == 0 then
						Item_Index = i
						ToEduIndex = 0 
					end
				else
					break
				end	
			end
		elseif ToEduIndex == 2 then
			for i = 1,count do
				if ToEduIndex == 2 then
					if GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "忠诚度1" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "忠诚度2" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 				
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "忠诚度3" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 				
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "忠诚度4" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 				
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "忠诚度4" and GlobalProcessing.ShowItemNumList[i] == 0 then
						Item_Index = i
						ToEduIndex = 0 
					end
				else
					break
				end
			end	
		elseif ToEduIndex == 3 then
			for i = 1,count do
				if ToEduIndex == 3 then
					if GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "寿命丹1" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "寿命丹2" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 				
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "寿命丹3" and GlobalProcessing.ShowItemNumList[i] == 1 then
						Item_Index = i
						ToEduIndex = 0 		
					elseif GlobalProcessing.ShowItemList[i]["ItemKeyName"] == "寿命丹3" and GlobalProcessing.ShowItemNumList[i] == 0 then
						Item_Index = i
						ToEduIndex = 0 
					end
				else
					break
				end
			end	
		end
		
		--物品跳转
		if PetUI.JumpItemKey ~= nil then
			for i = 1,count do
				if PetUI.JumpItemKey then
					if GlobalProcessing.ShowItemList[i]["ItemKeyName"] == PetUI.JumpItemKey then
						Item_Index = i 
						PetUI.JumpItemKey = nil
					end
				end
			end
		end
		

		local itemScrollWnd = _gt.GetUI("itemScrollWnd")
		GUI.LoopScrollRectSetTotalCount(itemScrollWnd, math.max(math.ceil(count/4)*4,16)) 
		GUI.LoopScrollRectRefreshCells(itemScrollWnd)
		PetUI.ShowItemInfo(Item_Index)
	else
		PetUI.RefreshTrainingTab()
	end
end


--使用一次培养道具
function PetUI.OnTrainingItemUseBtnClick()

	--如果为默认标记状态
	if 	PetUI.TrainingAttrState	== 0 then	
		TrainingItemUseList = GlobalProcessing.ShowItemList[Item_Index]["ItemKeyName"]
		if PetUI.petGuid ~= nil and #TrainingItemUseList > 0 then
			if GlobalProcessing.ShowItemNumList[Item_Index] == 1 then
			-- CDebug.LogError(GlobalProcessing.PetDevelopVersion)
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "MedicineUseItem",PetUI.petGuid,TrainingItemUseList,1,GlobalProcessing.PetDevelopVersion)
			else
				local itemId = DB.GetOnceItemByKey2(TrainingItemUseList).Id
				-- local tabLearningPanel = GUI.Get(tabNames[5][2])
				local parent = GUI.Get("PetUI/panelBg/pageEduPanel/tabTraining")
				local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", 0, 100, 50)  --创造提示
				GUI.SetData(itemtips, "ItemId", tostring(itemId))
				_gt.BindName(itemtips,"TrainingItemTips")
				local cutLine = GUI.GetChild(itemtips,"CutLine")
				GUI.SetPositionX(cutLine,-200)
				local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
				UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
				GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
				GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
				GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickTrainingItemWayBtn")
				GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
			end
		end
	elseif PetUI.TrainingAttrState == 2 then   --如果选中为资质丹
		TrainingItemUseList = GlobalProcessing.ShowItemList[Item_Index]["ItemKeyName"]
		if PetUI.petGuid ~= nil and #TrainingItemUseList > 0 then
			local Type = tostring(type(GlobalProcessing.ShowItemList[Item_Index]["Effect"][2]))
			if Type == "number" then
				local Grade = tonumber(GlobalProcessing.ShowItemList[Item_Index]["Effect"][2])
				if Grade > PetUI.TrainingAttrTb2-PetUI.TrainingAttrTb1 then
					GlobalUtils.ShowBoxMsg2Btn("提示","宠物剩余可提升资质过低，服用该丹药可能会造成浪费，是否确定使用？","PetUI","确定","SendAttrTrainingNotify","取消")
				else
					PetUI.SendAttrTrainingNotify()
				end	
			elseif Type == "table" then
				local Grade = tonumber(GlobalProcessing.ShowItemList[Item_Index]["Effect"][2][2])
				if Grade > PetUI.TrainingAttrTb2-PetUI.TrainingAttrTb1 then
					GlobalUtils.ShowBoxMsg2Btn("提示","宠物剩余可提升资质过低，服用该丹药可能会造成浪费，是否确定使用？","PetUI","确定","SendAttrTrainingNotify","取消")
				else
					PetUI.SendAttrTrainingNotify()
				end	
			end
			
						-- PetUI.ItemCanUseNum
							-- PetUI.TrainingAttrState = 2
						--记录选中的物品对应的资质
						-- PetUI.TrainingAttrTb1 = attrTb1 
						-- PetUI.TrainingAttrTb2 = attrTb2
						-- 记录选中的物品的数量
						-- PetUI.TrainingAttrNum = LD.GetItemCountById(itemDB.Id)
			
		else
			local itemId = DB.GetOnceItemByKey2(TrainingItemUseList).Id
			-- local tabLearningPanel = GUI.Get(tabNames[5][2])
			local parent = GUI.Get("PetUI/panelBg/pageEduPanel/tabTraining")
			local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", 0, 100, 50)  --创造提示
			GUI.SetData(itemtips, "ItemId", tostring(itemId))
			_gt.BindName(itemtips,"TrainingItemTips")
			local cutLine = GUI.GetChild(itemtips,"CutLine")
			GUI.SetPositionX(cutLine,-200)
			local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
			UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
			GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
			GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
			GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickTrainingItemWayBtn")
			GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))		
		end
	
	end
end

function PetUI.SendAttrTrainingNotify()
	TrainingItemUseList = GlobalProcessing.ShowItemList[Item_Index]["ItemKeyName"]
	CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "MedicineUseItem",PetUI.petGuid,TrainingItemUseList,1,GlobalProcessing.PetDevelopVersion)
end
--使用十次培养道具
function PetUI.OnTrainingItem10UseBtnClick()
	TrainingItemUseList = GlobalProcessing.ShowItemList[Item_Index]["ItemKeyName"]
	if PetUI.petGuid ~= nil and #TrainingItemUseList > 0 then
		if PetUI.TrainingAttrState == 0 then
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "MedicineUseItem",PetUI.petGuid,TrainingItemUseList,10,GlobalProcessing.PetDevelopVersion)
		elseif PetUI.TrainingAttrState == 2 then
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "MedicineUseItem",PetUI.petGuid,TrainingItemUseList,10,GlobalProcessing.PetDevelopVersion)
		end
	-- CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "MedicineUseItem",PetUI.petGuid,TrainingItemUseList,10)
	end
end

--道具获取途径
function PetUI.OnClickTrainingItemWayBtn()
	local tips = _gt.GetUI("TrainingItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end
-------------------------------------------------------------------------------------培养结束 ----------------------------------------------------
-------------------------------------------------------------------------------------技能学习 ----------------------------------------------------
function PetUI.CreateLearningTab()
	local pageEduPanelBg = GUI.Get(pageNames[2][2].."/pageEduPanelBg")
	if pageEduPanelBg == nil then
        return
    end
	local tabTrainingPanel = GUI.Get(tabNames[4][2])
	GUI.SetVisible(tabTrainingPanel,false)
	local tabRestorePanel = GUI.Get(tabNames[6][2])
	GUI.SetVisible(tabRestorePanel,false)
	local tabExtractPanel = GUI.Get(tabNames[7][2])
	GUI.SetVisible(tabExtractPanel,false)
	local tabBindPanel = GUI.Get(tabNames[8][2])
	GUI.SetVisible(tabBindPanel,false)
	local tabLearningPanel = GUI.Get(tabNames[5][2])
    if tabLearningPanel ~= nil then 
		GUI.SetVisible(tabLearningPanel,true)
        return
    end
    local tabLearningPanel = GUI.GroupCreate(pageEduPanelBg,"tabLearningPanel", 0, 0,0,0)
    GUI.SetAnchor(tabLearningPanel, UIAnchor.Center)
    GUI.SetPivot(tabLearningPanel, UIAroundPivot.Center)
	
	PetUI.CreateCurSkillPanel(tabLearningPanel)
	
	-- PetUI.RefreshLearningTab()
end

function PetUI.RefreshLearningTab()
	if GlobalProcessing.ShowSkillEduList then
	
	--物品跳转
		local count = #GlobalProcessing.ShowSkillEduList 
		if PetUI.JumpItemKey ~= nil then
			for i = 1,count do
				if PetUI.JumpItemKey then
					if GlobalProcessing.ShowSkillEduList[i].keyname == PetUI.JumpItemKey then
					SkillStudy_Index = i 
					PetUI.JumpItemKey = nil
					end
				end
			end
		end
				
		local itemScrollWnd = _gt.GetUI("itemScrollWnd")
		GUI.LoopScrollRectSetTotalCount(itemScrollWnd, (math.ceil(count/4))*4)
		GUI.LoopScrollRectRefreshCells(itemScrollWnd)
		if PetUI.petGuid ~= nil then
			--技能刷新
			local CurSkillScrollWnd = _gt.GetUI("CurSkillScrollWnd"..CurpageEduSubTab)
			local SkillNum = tonumber(GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid))
			GUI.LoopScrollRectSetTotalCount(CurSkillScrollWnd, math.max(math.ceil(SkillNum/4)*4,16))
			GUI.LoopScrollRectRefreshCells(CurSkillScrollWnd)
		end
		PetUI.ShowItemInfo(SkillStudy_Index)
	else
		PetUI.RefreshLearningTab()
	end	
end

-- function PetUI.GetLearningList()
	-- GlobalProcessing.ShowSkillEduList = {}
	-- GlobalProcessing.SkillEduGuidList={}

	-- local tempList = {} -- 当前没有的物品ID列表
	-- for i = 1 , #GlobalProcessing.SkillStudyShowItem do
		-- local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.SkillStudyShowItem[i])
		-- local num = LD.GetItemCountById(itemDB.Id)
		-- if num ~= 0 then
			-- local itemGuid = LD.GetItemGuidsById(itemDB.Id)
			-- for j = 1, num do 
				-- table.insert(GlobalProcessing.ShowSkillEduList,{ keyname = GlobalProcessing.SkillStudyShowItem[i], num = 1 })
				-- table.insert(GlobalProcessing.SkillEduGuidList,itemGuid[j - 1])
			-- end
		-- else
			-- table.insert(tempList, GlobalProcessing.SkillStudyShowItem[i])
		-- end
	-- end
	
	-- for	i = 1, #tempList do
		-- table.insert(GlobalProcessing.ShowSkillEduList,{ keyname = tempList[i], num = 0 })
	-- end

-- end
--宠物技能书学习使用
function PetUI.OnLearningItemUseBtnClick()
	if PetUI.petGuid ~= nil then
		if GlobalProcessing.ShowSkillEduList[SkillStudy_Index].num == 1 and GlobalProcessing.SkillEduGuidList[SkillStudy_Index] then
			local itemGuid = GlobalProcessing.SkillEduGuidList[SkillStudy_Index]
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "SkillStudy",PetUI.petGuid,itemGuid,GlobalProcessing.PetDevelopVersion)	
		else
			local itemId = DB.GetOnceItemByKey2(GlobalProcessing.ShowSkillEduList[SkillStudy_Index].keyname).Id
			-- local tabLearningPanel = GUI.Get(tabNames[5][2])
			local parent = GUI.Get("PetUI/panelBg/pageEduPanel/tabLearning")
			local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", 0, 100, 50)  --创造提示
			GUI.SetData(itemtips, "ItemId", tostring(itemId))
			_gt.BindName(itemtips,"LearningItemTips")
			local cutLine = GUI.GetChild(itemtips,"CutLine")
			GUI.SetPositionX(cutLine,-200)
			local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
			UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickLearningItemWayBtn")
            GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
		end
	end
end

--技能学习书获取途径
function PetUI.OnClickLearningItemWayBtn()
	local tips = _gt.GetUI("LearningItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end


--技能学习提取解绑共用部分（创建当前技能框）
function PetUI.CreateCurSkillPanel(parent)
	if parent == nil then
        return
    end
	local Wnd = _gt.GetUI("CurSkillScrollWnd"..CurpageEduSubTab)
	if Wnd then
		return
	end
	if CurpageEduSubTab == 2 or CurpageEduSubTab == 4 or CurpageEduSubTab == 5 then
		local titleBg = GUI.ImageCreate(parent, "titleBg", "1800700100",165,-245, false, 294, 32, false)
		SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Top)

		-- 标题
		local titleText = GUI.CreateStatic( titleBg, "titleText", "当前技能", 0, 0, 294, 32, "system", true, false)
		SetAnchorAndPivot(titleText, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
		GUI.StaticSetFontSize(titleText, fontSizeDefault)
		GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter)
		GUI.SetColor(titleText, colorDark)

		
		-- 滚动窗口
		local CurSkillScrollWnd = GUI.LoopScrollRectCreate(parent, "CurSkillScrollWnd"..CurpageEduSubTab, 165, -85, 324, 242,
		"PetUI", "CreateEduCurSkillItem", "PetUI", "RefreshEduCurSkillItem", 0, false, Vector2.New(76, 76), 4, UIAroundPivot.Top, UIAnchor.Top);
		UILayout.SetSameAnchorAndPivot(CurSkillScrollWnd, UILayout.Center)
		_gt.BindName(CurSkillScrollWnd, "CurSkillScrollWnd"..CurpageEduSubTab)
		-- CurSkillScrollWnd = GUI.ScrollRectCreate( parent, "CurSkillScrollWnd", 165, -85, 324, 242, 0, false, Vector2.New(76,76), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 4)
		-- SetAnchorAndPivot(CurSkillScrollWnd, UIAnchor.Center, UIAroundPivot.Center)
		-- GUI.ScrollRectSetChildAnchor(CurSkillScrollWnd, UIAnchor.Top)
		-- GUI.ScrollRectSetChildPivot(CurSkillScrollWnd, UIAroundPivot.Top)
		GUI.ScrollRectSetChildSpacing(CurSkillScrollWnd, Vector2.New(4, 4))
	elseif CurpageEduSubTab == 3 then
	-- 滚动窗口
		local CurSkillScrollWnd = GUI.LoopScrollRectCreate(parent, "CurSkillScrollWnd"..CurpageEduSubTab, 165, -40, 324, 150,
		"PetUI", "CreateEduCurSkillItem", "PetUI", "RefreshEduCurSkillItem", 0, false, Vector2.New(76, 76), 4, UIAroundPivot.Top, UIAnchor.Top);
		UILayout.SetSameAnchorAndPivot(CurSkillScrollWnd, UILayout.Center)
		_gt.BindName(CurSkillScrollWnd, "CurSkillScrollWnd"..CurpageEduSubTab)
		-- CurSkillScrollWnd = GUI.ScrollRectCreate( parent, "CurSkillScrollWnd", 165,-40, 324, 150, 0, false, Vector2.New(76,76), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 4)
		-- SetAnchorAndPivot(CurSkillScrollWnd, UIAnchor.Center, UIAroundPivot.Center)
		-- GUI.ScrollRectSetChildAnchor(CurSkillScrollWnd, UIAnchor.Top)
		-- GUI.ScrollRectSetChildPivot(CurSkillScrollWnd, UIAroundPivot.Top)
		GUI.ScrollRectSetChildSpacing(CurSkillScrollWnd, Vector2.New(4, 4))
	end

    -- for i = 1, 16 do
        -- PetUI.CreateEduCurSkillItem(i, CurSkillScrollWnd)
    -- end
	
	-- local CurSkillScrollWnd = _gt.GetUI("CurSkillScrollWnd"..CurpageEduSubTab)
end

function PetUI.CreateEduCurSkillItem()
	local CurSkillScrollWnd = _gt.GetUI("CurSkillScrollWnd"..CurpageEduSubTab)
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(CurSkillScrollWnd);
    local item = GUI.ItemCtrlCreate( CurSkillScrollWnd, "Skillitem"..curCount, "1800400330", 0, 0, 0, 0, false)
    GUI.SetData(item, "Skillitem", curCount)
	_gt.BindName(item,"Skillitem"..curCount)

    GUI.RegisterUIEvent(item, UCE.PointerClick, "PetUI", "OnEduSkillItemClick")
--创建选择框
	local Selectedimg = GUI.ImageCreate(item,"Selectedimg","1800400280",0,0,true)
	SetAnchorAndPivot(Selectedimg, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetVisible(Selectedimg,false)
	return item
end

function PetUI.OnEduSkillItemClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "Skillitem"))
	local parent = _gt.GetUI("CurSkillScrollWnd"..CurpageEduSubTab)
	local id = tonumber(GUI.GetData(GUI.GetByGuid(guid), "EduSkill_Id"))
	if CurpageEduSubTab ==5 then
		CurSkillIndex = id 
	end	
	local skillnum = tonumber(GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid))
	--显示技能TIPS	
	local PetSkills = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetUI.petGuid)
	if index < skillnum then
		if id then
			-- CL.SendNotify(NOTIFY.SkillTipsReq, id, uint64.new(PetUI.petGuid))
			-- PetUI.SkillPerformance = PetSkills[index].performance
			Tips.CreateSkillId(id,_gt.GetUI("panelBg"),"tips",0,0,0,0,PetSkills[index].performance)
		end
	else
		return
	end
	
	--只有技能绑定页显示选择框
	if CurpageEduSubTab ==5 then

		GUI.LoopScrollRectRefreshCells(parent)
	end

end

--默认选择第一个技能
-- function PetUI.RefreshEduSkillSelect()
	-- local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid)
	-- local parent = GUI.Get("PetUI/panelBg/pageEduPanel/pageEduPanelBg/tabBindPanel/CurSkillScrollWnd") 
	-- for i = 1,16 do
		-- local item = GUI.GetChild(parent,"Skillitem"..i)
		-- local Selectedimg = GUI.GetChild(item,"Selectedimg")
		-- GUI.SetVisible(Selectedimg,i==CurSkillIndex+1 and num > 0)
	-- end
-- end

--刷新当前技能
function PetUI.RefreshEduCurSkillItem(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	-- index = index +1
	-- CDebug.LogError(index)
	local Count = tonumber(GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid))
	local PetSkills = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetUI.petGuid)
	local item = GUI.GetByGuid(guid)
	local Selectedimg = GUI.GetChild(item,"Selectedimg")
	GUI.SetVisible(Selectedimg,false)
	if index < Count then
		local SkillDB = DB.GetOnceSkillByKey1(PetSkills[index].id)
		if CurpageEduSubTab == 5 and tonumber(SkillDB.Id) == CurSkillIndex then
			GUI.SetVisible(Selectedimg,true)
		end
		GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,tostring(SkillDB.Icon))
		GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,UIDefine.ItemIconBg[SkillDB.SkillQuality])
		GUI.SetData(item,"EduSkill_Id",SkillDB.Id)
		if PetSkills[index].bind ==1 then
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.LeftTopSp, 1800707120)
			GUI.ItemCtrlSetElementRect(item, eItemIconElement.LeftTopSp, 0, 0, 44, 45)
		else
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.LeftTopSp, nil)
		end
	else
		ItemIcon.SetEmpty(item)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------- 宠物还原-------------------------------------------------------
function PetUI.CreateRestoreTab()
	local pageEduPanelBg = GUI.Get(pageNames[2][2].."/pageEduPanelBg")
	if pageEduPanelBg == nil then
        return
    end
	local tabTrainingPanel = GUI.Get(tabNames[4][2])
	GUI.SetVisible(tabTrainingPanel,false)
	local tabTrainingPanel = GUI.Get(tabNames[5][2])
	GUI.SetVisible(tabTrainingPanel,false)
	local tabExtractPanel = GUI.Get(tabNames[7][2])
	GUI.SetVisible(tabExtractPanel,false)
	local tabBindPanel = GUI.Get(tabNames[8][2])
	GUI.SetVisible(tabBindPanel,false)
	local tabRestorePanel = GUI.Get(tabNames[6][2])
    if tabRestorePanel ~= nil then 
		GUI.SetVisible(tabRestorePanel,true)
        return
    end
    local tabRestorePanel = GUI.GroupCreate(pageEduPanelBg,"tabRestorePanel", 0, 0,0,0)
    GUI.SetAnchor(tabRestorePanel, UIAnchor.Center)
    GUI.SetPivot(tabRestorePanel, UIAroundPivot.Center)
	
	local properties = { 17,18,19, 20, 21, 22, 23, 24 }

    for i = 1, #properties do
        local data = petProperty[properties[i]]
        local posX = 40 + ((i - 1) % 2) * 175
        local posY = -235 + math.floor((i - 1) / 2) * 30

        local label = GUI.CreateStatic( tabRestorePanel, data[2] .. "label", data[1], posX, posY, 85, 28, "system", true, false)
        SetAnchorAndPivot(label, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(label, fontSizeSmaller)
        GUI.SetColor(label, colorDark)

        local tempSlider = GUI.ScrollBarCreate( label, data[2], "", data[3], data[4], 80, 0, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
		_gt.BindName(tempSlider,"RestoretempSlider"..i)

        local silderFillSize = Vector2.New(80, 24)
        GUI.ScrollBarSetFillSize(tempSlider, silderFillSize)
        GUI.ScrollBarSetBgSize(tempSlider, silderFillSize)
        SetAnchorAndPivot(tempSlider, UIAnchor.Center, UIAroundPivot.Center)
		
        local currentTxt = GUI.CreateStatic( tempSlider, data[2] .. "Text", "1000", 0, 0, 80, 40, "system", true)
        SetAnchorAndPivot(currentTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(currentTxt, fontSizeSmaller)
		GUI.StaticSetAlignment(currentTxt,TextAnchor.MiddleCenter)
		_gt.BindName(currentTxt,"RestorecurrentTxt"..i)
	end
	
	
	PetUI.CreateCurSkillPanel(tabRestorePanel)
end
function PetUI.RefreshRestoreTab()
	RestoreItemEduList = {}
	for i =1 , #GlobalProcessing.RestoreShowOrder do
		table.insert(RestoreItemEduList,GlobalProcessing.RestoreShowOrder[i])	
	end
--刷新右上角资质
	if PetUI.petGuid ~= nil then
		local properties = { 17,18, 19, 20, 21, 22, 23, 24 }
		for i = 1, #properties do
			local currentTxt = _gt.GetUI("RestorecurrentTxt"..i)
			local tempSlider = _gt.GetUI("RestoretempSlider"..i)
			local attrTb= petProperty[properties[i]]
			GUI.StaticSetText(currentTxt, LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))
			if i ~= 7 and i ~= 8 then
			GUI.ScrollBarSetPos(tempSlider,(LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))/(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid,pet_container_type.pet_container_panel)))
			else
			GUI.ScrollBarSetPos(tempSlider,(LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))/(PetUI.petDB[attrTb[6]]))
			end
		end
		local CurSkillScrollWnd = _gt.GetUI("CurSkillScrollWnd"..CurpageEduSubTab)
		local SkillNum = tonumber(GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid))
		GUI.LoopScrollRectSetTotalCount(CurSkillScrollWnd, math.max(math.ceil(SkillNum/4)*4,16))
		GUI.LoopScrollRectRefreshCells(CurSkillScrollWnd)
	
	else
		RestoreItemEduList = {}
	end
	
	--物品跳转
	if PetUI.JumpItemKey ~= nil then
		for i = 1,#RestoreItemEduList do
			if RestoreItemEduList[i] == PetUI.JumpItemKey then
			Restore_Index = i 
			PetUI.JumpItemKey = nil
			end
		end
	end
	
	
	local itemScrollWnd = _gt.GetUI("itemScrollWnd")
	GUI.LoopScrollRectSetTotalCount(itemScrollWnd, 16) 
	GUI.LoopScrollRectRefreshCells(itemScrollWnd)
	PetUI.ShowItemInfo(Restore_Index)
end

function PetUI.OnRestoreUseBtnClick()
	if PetUI.petGuid ~=nil then
		PetUI.Restorekey = RestoreItemEduList[Restore_Index]
		local itemDB = DB.GetOnceItemByKey2(PetUI.Restorekey)
		local count = LD.GetItemCountById(itemDB.Id)
		if count > 0 then
			local star =LD.GetPetIntCustomAttr("PetStarLevel",PetUI.petGuid,pet_container_type.pet_container_panel)
			if star > 1 then
				GlobalUtils.ShowBoxMsg2Btn("提示","该宠物还原之后会变为一星，你确定还原该宠物吗？","PetUI","确定","SendRestoreNotify","取消")
			else
				PetUI.SendRestoreNotify()
			end
		else
			local itemId = itemDB.Id
			-- local tabLearningPanel = GUI.Get(tabNames[5][2])
			local parent = GUI.Get("PetUI/panelBg/pageEduPanel/tabRestore")
			local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -150, 100, 50) 			--创造提示
			-- GUI.SetPositionX(itemtips,-150)
			GUI.SetData(itemtips, "ItemId", tostring(itemId))
			_gt.BindName(itemtips,"RestoreItemTips")
			local cutLine = GUI.GetChild(itemtips,"CutLine")
			GUI.SetPositionX(cutLine,-200)
			local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
			UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickRestoreItemWayBtn")
            GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))		
		end
	end
end

function PetUI.SendRestoreNotify()
	PetUI.PetListChange = 1
	CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "Restore",PetUI.petGuid,PetUI.Restorekey,GlobalProcessing.PetDevelopVersion)

end

--宠物还原道具获取途径
function PetUI.OnClickRestoreItemWayBtn()
	local tips = _gt.GetUI("RestoreItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end
----------------------------------------------------------------------------------还原结束 -------------------------------------------------------
-----------------------------------------------------------------------------------技能提取 -------------------------------------------------------


function PetUI.CreateExtractTab()
	local pageEduPanelBg = GUI.Get(pageNames[2][2].."/pageEduPanelBg")
	if pageEduPanelBg == nil then
        return
    end
	local tabTrainingPanel = GUI.Get(tabNames[4][2])
	GUI.SetVisible(tabTrainingPanel,false)
	local tabLearningPanel = GUI.Get(tabNames[5][2])
	GUI.SetVisible(tabLearningPanel,false)
	local tabRestorePanel = GUI.Get(tabNames[6][2])
	GUI.SetVisible(tabRestorePanel,false)
	local tabBindPanel = GUI.Get(tabNames[8][2])
	GUI.SetVisible(tabBindPanel,false)
	local tabExtractPanel = GUI.Get(tabNames[7][2])
    if tabExtractPanel ~= nil then 
		GUI.SetVisible(tabExtractPanel,true)
        return
    end
    local tabExtractPanel = GUI.GroupCreate(pageEduPanelBg,"tabExtractPanel", 0, 0,0,0)
    GUI.SetAnchor(tabExtractPanel, UIAnchor.Center)
    GUI.SetPivot(tabExtractPanel, UIAroundPivot.Center)
	
	PetUI.CreateCurSkillPanel(tabExtractPanel)
end

function PetUI.RefreshExtractTab()
	SkillExtractItemList = {}
	SkillExtractItemGuid={}
	
	for i = 1 , #GlobalProcessing.SkillExtractShowOrder do
		local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.SkillExtractShowOrder[i])
		local num = LD.GetItemCountById(itemDB.Id)
		if num ~= 0 then
			local itemGuidList = LD.GetItemGuidsById(itemDB.Id)
			-- local inspect = require("inspect")
			-- CDebug.LogError(itemGuidList.Count)
			-- LD.GetItemDataByGuid 
			
			for j = 1, itemGuidList.Count do 
				table.insert(SkillExtractItemList,{keyname = GlobalProcessing.SkillExtractShowOrder[i], num = 1 })
				table.insert(SkillExtractItemGuid,itemGuidList[j - 1])
			end
		end
	end
	
	if #SkillExtractItemList == 0 then
		local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.SkillExtractShowOrder[2])
		local itemGuid = LD.GetItemGuidsById(itemDB.Id)
		table.insert(SkillExtractItemList,{ keyname = GlobalProcessing.SkillExtractShowOrder[2], num = 0 })
		table.insert(SkillExtractItemGuid,nil)
	else
		local itemtable = {}
		for i = 1, #SkillExtractItemList do
			if SkillExtractItemList[i].keyname == GlobalProcessing.SkillExtractShowOrder[2] then
				table.insert(itemtable,i)
			end
		end
		if #itemtable == 0 then
		table.insert(SkillExtractItemList,{ keyname = GlobalProcessing.SkillExtractShowOrder[2], num = 0 })
		table.insert(SkillExtractItemGuid,nil)
		end
	end
	local itemScrollWnd = _gt.GetUI("itemScrollWnd")
	GUI.LoopScrollRectSetTotalCount(itemScrollWnd, 16) 
	GUI.LoopScrollRectRefreshCells(itemScrollWnd)
	if PetUI.petGuid ~= nil then
		--技能刷新
		local CurSkillScrollWnd = _gt.GetUI("CurSkillScrollWnd"..CurpageEduSubTab)
		local SkillNum = tonumber(GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid))
		GUI.LoopScrollRectSetTotalCount(CurSkillScrollWnd, math.max(math.ceil(SkillNum/4)*4,16))
		GUI.LoopScrollRectRefreshCells(CurSkillScrollWnd)
	end
	
	--物品跳转
	if PetUI.JumpItemKey ~= nil then
		for i = 1,#SkillExtractItemList do
			if SkillExtractItemList[i].keyname == PetUI.JumpItemKey then
			Extract_Index = i 
			PetUI.JumpItemKey = nil
			end
		end
	end
	if Extract_Index > #SkillExtractItemList then
		Extract_Index = 1
	end
	PetUI.ShowItemInfo(Extract_Index)
end

function PetUI.OnExtractUseBtnClick()
	if PetUI.petGuid ~= nil then
		if SkillExtractItemList[Extract_Index].num == 1 then 
			local itemGuid=SkillExtractItemGuid[Extract_Index]
			local star =LD.GetPetIntCustomAttr("PetStarLevel",PetUI.petGuid,pet_container_type.pet_container_panel)
			if star > 1 then
				local name = LD.GetPetName(PetUI.petGuid)
				GlobalUtils.ShowBoxMsg2Btn("提示","您的"..name.."已经突破至"..star.."星，提取后会直接消失，是否提取？","PetUI","确定","SendExtractNotify","取消")
			else
				PetUI.SendExtractNotify()
			end
		else
			local itemId = DB.GetOnceItemByKey2(SkillExtractItemList[Extract_Index].keyname).Id
			-- local tabLearningPanel = GUI.Get(tabNames[5][2])
			local parent = GUI.Get("PetUI/panelBg/pageEduPanel/tabExtract")
			local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -300, 100, 50) 			--创造提示
			-- GUI.SetPositionX(itemtips,-150)
			GUI.SetData(itemtips, "ItemId", tostring(itemId))
			_gt.BindName(itemtips,"ExtractItemTips")
			local cutLine = GUI.GetChild(itemtips,"CutLine")
			GUI.SetPositionX(cutLine,-200)
			local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
			UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickExtractItemWayBtn")
            GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
		end
	end
end


function PetUI.SendExtractNotify()
	if PetUI.petGuid ~= nil then
		local itemGuid=SkillExtractItemGuid[Extract_Index]
		PetUI.PetListChange = 1
		CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "SkillExtract",PetUI.petGuid,itemGuid,GlobalProcessing.PetDevelopVersion)		
	end
end

--宠物技能提取道具获取途径
function PetUI.OnClickExtractItemWayBtn()
	local tips = _gt.GetUI("ExtractItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------技能绑定---------------------------------------------------------------
function PetUI.CreateBindTab()
	local pageEduPanelBg = GUI.Get(pageNames[2][2].."/pageEduPanelBg")
	if pageEduPanelBg == nil then
        return
    end
	local tabTrainingPanel = GUI.Get(tabNames[4][2])
	GUI.SetVisible(tabTrainingPanel,false)
	local tabLearningPanel = GUI.Get(tabNames[5][2])
	GUI.SetVisible(tabLearningPanel,false)
	local tabRestorePanel = GUI.Get(tabNames[6][2])
	GUI.SetVisible(tabRestorePanel,false)
	local tabExtractPanel = GUI.Get(tabNames[7][2])
	GUI.SetVisible(tabExtractPanel,false)
	local tabBindPanel = GUI.Get(tabNames[8][2])
    if tabBindPanel ~= nil then 
		GUI.SetVisible(tabBindPanel,true)
        return
    end
    local tabBindPanel = GUI.GroupCreate(pageEduPanelBg,"tabBindPanel", 0, 0,0,0)
    GUI.SetAnchor(tabBindPanel, UIAnchor.Center)
    GUI.SetPivot(tabBindPanel, UIAroundPivot.Center)
	
	PetUI.CreateCurSkillPanel(tabBindPanel)
end

function PetUI.RefreshBindTab()
	CurSkillIndex = 0
	SkillBindItemList = {}
	table.insert(SkillBindItemList,1,GlobalProcessing.SkillBindItem)
	table.insert(SkillBindItemList,2,GlobalProcessing.SkillUnbindItem )
	
	if PetUI.petGuid ~= nil then
		--技能刷新
		local CurSkillScrollWnd = _gt.GetUI("CurSkillScrollWnd"..CurpageEduSubTab)
		local SkillNum = tonumber(GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid))
		GUI.LoopScrollRectSetTotalCount(CurSkillScrollWnd, math.max(math.ceil(SkillNum/4)*4,16))
		GUI.LoopScrollRectRefreshCells(CurSkillScrollWnd)
	end
	local itemScrollWnd = _gt.GetUI("itemScrollWnd")
	GUI.LoopScrollRectSetTotalCount(itemScrollWnd, 16) 
	GUI.LoopScrollRectRefreshCells(itemScrollWnd)
	
	--物品跳转
	if PetUI.JumpItemKey ~= nil then
		for i = 1,#SkillBindItemList do
			if SkillBindItemList[i] == PetUI.JumpItemKey then
			SkillBind_Index = i 
			PetUI.JumpItemKey = nil
			end
		end
	end
	PetUI.ShowItemInfo(SkillBind_Index)
	-- PetUI.RefreshEduSkillSelect()
end

function PetUI.OnSkillBindUseBtnClick()
	if PetUI.petGuid ~= nil then
		local itemDB = DB.GetOnceItemByKey2(SkillBindItemList[1])
		local count = LD.GetItemCountById(itemDB.Id)
		if count >0 then
			local PetSkills = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetUI.petGuid)
			local num = tonumber(GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid))
			if num >=1 and CurSkillIndex ~= 0 then
			-- test(CurSkillIndex)
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "SkillBind",PetUI.petGuid,CurSkillIndex,GlobalProcessing.PetDevelopVersion)	
			else
			CL.SendNotify(NOTIFY.ShowBBMsg, "未选中或宠物没有技能！")
			end
		else
			local itemId = itemDB.Id
			-- local tabLearningPanel = GUI.Get(tabNames[5][2])
			local parent = GUI.Get("PetUI/panelBg/pageEduPanel/tabBind")
			local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -450, 100, 50) 			--创造提示
			-- GUI.SetPositionX(itemtips,-150)
			GUI.SetData(itemtips, "ItemId", tostring(itemId))
			_gt.BindName(itemtips,"BindItemTips")
			local cutLine = GUI.GetChild(itemtips,"CutLine")
			GUI.SetPositionX(cutLine,-200)
			local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
			UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickBindItemWayBtn")
            GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))					
		end
	end
end

function PetUI.OnSkillUnBindUseBtnClick()
	if PetUI.petGuid ~= nil then
		local itemDB = DB.GetOnceItemByKey2(SkillBindItemList[2])
		local count = LD.GetItemCountById(itemDB.Id)
		if count >0 then
			local PetSkills = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetUI.petGuid)
			local num = tonumber(GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid))
			if num >=1 and CurSkillIndex ~= 0 then
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetDevelop", "SkillUnbind",PetUI.petGuid,CurSkillIndex,GlobalProcessing.PetDevelopVersion)	
			else
			CL.SendNotify(NOTIFY.ShowBBMsg, "未选中或宠物没有技能！")
			end
		else
			local itemId = itemDB.Id
			-- local tabLearningPanel = GUI.Get(tabNames[5][2])
			local parent = GUI.Get("PetUI/panelBg/pageEduPanel/tabBind")
			local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -450, 100, 50) 			--创造提示
			-- GUI.SetPositionX(itemtips,-150)
			GUI.SetData(itemtips, "ItemId", tostring(itemId))
			_gt.BindName(itemtips,"BindItemTips")
			local cutLine = GUI.GetChild(itemtips,"CutLine")
			GUI.SetPositionX(cutLine,-200)
			local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
			UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
            GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickBindItemWayBtn")
            GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))							
		end		
	end
end

--宠物技能绑定相关道具获取途径
function PetUI.OnClickBindItemWayBtn()
	local tips = _gt.GetUI("BindItemTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end
--------------------------------------------------------------------------------技能绑定结束------------------------------------------------------------

local EduLastPetGuid = 0
function PetUI.RefreshEduPetModel()
		local EduPetModel = GUI.GetByGuid(_gt.EduPetModel);
		local EduPetModelGroup =  _gt.GetUI("EduPetModelGroup")
		if PetUI.petDB ~= nil then
				GUI.SetVisible(EduPetModel, true);
				--是否绑定					
				local EdubindLabel = GUI.GetChild(EduPetModelGroup,"EdubindLabel")
				GUI.SetVisible(EdubindLabel,LD.GetPetState(PetState.Bind, PetUI.petGuid))
				if EduLastPetGuid ~= PetUI.petGuid then
						ModelItem.Bind(EduPetModel, tonumber(PetUI.petDB.Model),LD.GetPetIntAttr(RoleAttr.RoleAttrColor1,PetUI.petGuid ),0,eRoleMovement.ATTSTAND_W1)
					--显示饰品特效
						local haveEffect = LD.GetPetIntCustomAttr("PetEquip_HasTrinket",PetUI.petGuid)
						PetUI.OnShowPetEquipEffect(EduPetModel, haveEffect, TOOLKIT.Str2uLong(PetUI.petDB.TrinketEff))

					if LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid) ~= "" then
						GUI.RefreshDyeSkinJson(EduPetModel, LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid), "")
					end	
				-- local petModelGroup = GUI.Get("PetUI/panelBg/pageEduPanel/pageEduPanelBg/EduPetModelGroup")
					--星级刷新
					local star =LD.GetPetIntCustomAttr("PetStarLevel",PetUI.petGuid,pet_container_type.pet_container_panel)
					for i = 1 ,6 do
						local EduStarLevel = GUI.GetChild(EduPetModelGroup,"EduStarLevel"..i)
						GUI.ImageSetImageID(EduStarLevel,"1801202192")
						GUI.SetVisible(EduStarLevel,true)
						-- GUI.SetPositionX(EduStarLevel,-100+(i*25))
						-- GUI.SetPositionY(EduStarLevel,-10)
					end
					for i = 1 ,star do
						local EduStarLevel = GUI.GetChild(EduPetModelGroup,"EduStarLevel"..i)
						GUI.ImageSetImageID(EduStarLevel,"1801202190")
					end

				
					local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, PetUI.petGuid)
					local moban =DB.GetOncePetByKey1(id)
					local EduPetName = GUI.GetChild(EduPetModelGroup,"EduPetName")
					GUI.StaticSetText(EduPetName,moban.Name)

					--模型偏移
					local EduModel = _gt.GetUI("EduModel")
					--宠物模型Y轴
					local Offset = ModelOffsetConfig[tostring(moban.Model)] or 0
					GUI.SetPositionY(EduModel, -150 + Offset)		
					
					local EdupetTypeLabel = GUI.GetChild(EduPetModelGroup,"EdupetTypeLabel")
					GUI.ImageSetImageID(EdupetTypeLabel, UIDefine.PetType[PetUI.petDB.Type])
					EduLastPetGuid = PetUI.petGuid
				end
		else
			GUI.SetVisible(EduPetModel, false);
		end
end

----------------------------------------------------------------------------------------------炼化开始--------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------洗炼 --------------------------------------------------------------
local ClearItemsInfo =
    {
        {"ClearItem1", -354, "洗炼符","普通洗练符","OnClearItem1Click",35508,"RefiningItem"},
        {"ClearItem2", -236, "洗炼锁定符","洗练锁定符","OnClearItem2Click",35510},
        {"ClearItem3", 3, "洗炼精粹","高级洗练符","OnClearItem3Click",35509,"RefiningItemEx"}
    }

local LockAttrList ={}

function PetUI.CreateClearTab()
	local pageRefinePanel = GUI.Get(pageNames[3][2])
	if pageRefinePanel == nil then
        return
    end
	local tabClearPanel = GUI.Get(tabNames[9][2])
    if tabClearPanel ~= nil then 
		GUI.SetVisible(tabClearPanel,true)
        return
    end
    local tabClearPanel = GUI.ImageCreate(pageRefinePanel,"tabClearPanel", "1800400200", 160, -240, false, 350,315)
    GUI.SetAnchor(tabClearPanel, UIAnchor.TopLeft)
    GUI.SetPivot(tabClearPanel, UIAroundPivot.TopLeft)
--装饰	
	local foo = GUI.ImageCreate(tabClearPanel,"foo", "1801502030", 0, 0)
    GUI.SetAnchor(foo, UIAnchor.BottomLeft)
    GUI.SetPivot(foo, UIAroundPivot.BottomLeft)
	
    local titleBg = GUI.ImageCreate(tabClearPanel, "titleBg", "1800700070", 0, 0, false, 348, 36)
    GUI.SetAnchor(titleBg, UIAnchor.Top)
    GUI.SetPivot(titleBg, UIAroundPivot.Top)
	


 -- 创建标题
    local titlesInfo =
    {
        {"资质类型", 0, 85},
        {"当前资质", 85, 146},
        {"提升", 231, 68},
        {"锁定", 299, 49},
    }

    for i = 1, #titlesInfo do
        local title = GUI.CreateStatic(titleBg, "attrTitle" .. i, titlesInfo[i][1], titlesInfo[i][2], 2, titlesInfo[i][3], 36, "system", false, false)
        GUI.SetAnchor(title, UIAnchor.TopLeft)
        GUI.SetPivot(title, UIAroundPivot.TopLeft)
        GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(title, 18)
        GUI.SetColor(title, Color.New(104 / 255, 72 / 255, 38 / 255, 1))
    end
-- 分割线
    for i = 1, #titlesInfo - 1 do
        local cutLine = GUI.ImageCreate(titleBg,"cutLine" .. i, "1800600220", titlesInfo[i + 1][2], 1)
        GUI.SetAnchor(cutLine,UIAnchor.TopLeft)
        GUI.SetPivot(cutLine,UIAroundPivot.TopLeft)
    end
-- 资质表格	
	for i = 1, #PetUI.PetUpStarIntConfig do
		local data = PetUI.PetUpStarIntConfig[i]
		local posX = 0
		local posY = 42 +  (i - 1) * 42

		local imgId = "1801501020"
		if i % 2 == 0 then
			imgId= "1801501010"
		end
		local bg = GUI.ImageCreate(tabClearPanel,data[1] .. "bg", imgId, posX + 3, posY - 6,  false, 344, 42)
		GUI.SetAnchor(bg, UIAnchor.TopLeft)
		GUI.SetPivot(bg, UIAroundPivot.TopLeft)

		local label = GUI.CreateStatic(tabClearPanel,data[1] .. "label", data[2], posX, posY, 85, 36, "system", false, false)
		GUI.SetAnchor(label, UIAnchor.TopLeft)
		GUI.SetPivot(label, UIAroundPivot.TopLeft)
		GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter)
		GUI.StaticSetFontSize(label, 20)
		GUI.SetColor(label, Color.New(151 / 255, 92 / 255, 34 / 255, 255 / 255))	
		
		local tempSlider = GUI.ScrollBarCreate(tabClearPanel,data[1], "", "1800408160", "1800408110", posX + 160, posY + 15, 0, 0,  1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
		_gt.BindName(tempSlider,"tempSlider"..i.."Clear")

        local silderFillSize = Vector2.New(148, 24)
        GUI.ScrollBarSetFillSize(tempSlider, silderFillSize)
        GUI.ScrollBarSetBgSize(tempSlider, silderFillSize)
        GUI.SetAnchor(tempSlider, UIAnchor.TopLeft)
        GUI.SetPivot(tempSlider, UIAroundPivot.TopLeft)

        local currentTxt = GUI.CreateStatic(tempSlider,data[1] .. "Text", "", 0, 0,  120, 30, "system", true)
        GUI.SetAnchor(currentTxt, UIAnchor.Center)
        GUI.SetPivot(currentTxt, UIAroundPivot.Center)
		GUI.StaticSetAlignment(currentTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(currentTxt, 20)
		_gt.BindName(currentTxt,data[4].."Clear")
		
-- 提升范围
        local EnhanceChange = GUI.CreateStatic(tabClearPanel,data[2] .. "EnhanceChange", "", posX + 244, posY, 60, 28, "system", true, false)
        GUI.SetAnchor(EnhanceChange, UIAnchor.TopLeft)
        GUI.SetPivot(EnhanceChange, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(EnhanceChange, 20)
        GUI.StaticSetAlignment(EnhanceChange, TextAnchor.MiddleCenter)
        GUI.SetColor(EnhanceChange, colorGreen)

        local lockmark = GUI.ImageCreate(tabClearPanel,data[2] .. "lockmark", "1801207120", posX + 310, posY)
        GUI.SetAnchor(lockmark, UIAnchor.TopLeft)
        GUI.SetPivot(lockmark, UIAroundPivot.TopLeft)
		_gt.BindName(EnhanceChange,"EnhanceChange"..i)
		_gt.BindName(lockmark,"lockmark"..i)
	end
--点击触发锁定
    local touchBtn = GUI.ButtonCreate(tabClearPanel,"touchBtn", "1800400230", 70, 37,Transition.None, "", 270, 270, false)
    GUI.SetAnchor(touchBtn, UIAnchor.TopLeft)
    GUI.SetPivot(touchBtn, UIAroundPivot.TopLeft)
    GUI.SetColor(touchBtn, Color.New(1, 1, 1, 0))
    GUI.RegisterUIEvent(touchBtn, UCE.PointerClick, "PetUI", "OnAttrLockBtnClick")
    _gt.BindName(touchBtn,"touchBtn")
--满资质时提示突破
	local BreachplzBg = GUI.ImageCreate(tabClearPanel,"BreachplzBg", "1800400220", 0, 0,  false, 344, 315)
    GUI.SetAnchor(BreachplzBg, UIAnchor.Center)
    GUI.SetPivot(BreachplzBg, UIAroundPivot.Center)	
	local  BreachplzText = GUI.CreateStatic(BreachplzBg,"BreachplzText", "属性全部达到上限，请先突破", 0, 0, 400, 50, "system")
	GUI.SetAnchor(BreachplzText, UIAnchor.Center)
    GUI.SetPivot(BreachplzText, UIAroundPivot.Center)
	GUI.StaticSetFontSize(BreachplzText, 24)
	GUI.StaticSetAlignment(BreachplzText, TextAnchor.MiddleCenter)
	local BreachplzBtn = GUI.ButtonCreate(BreachplzBg,"BreachplzBtn", "1800402110", 0, 50, Transition.ColorTint, "突破",120,47,false)
    GUI.SetAnchor(BreachplzBtn, UIAnchor.Center)
    GUI.SetPivot(BreachplzBtn, UIAroundPivot.Center)
	GUI.ButtonSetTextColor(BreachplzBtn,colorDark)
	GUI.ButtonSetTextFontSize(BreachplzBtn,24)
    GUI.RegisterUIEvent(BreachplzBtn, UCE.PointerClick, "PetUI", "OnBreachplzBtnClick")
	_gt.BindName(BreachplzBg,"BreachplzBg")
	GUI.SetVisible(BreachplzBg,false)
	
--消耗物品处底图
    local costBg = GUI.ImageCreate(tabClearPanel,"costBg", "1800400200", -330, 325,  false, 680, 132)
    GUI.SetAnchor(costBg, UIAnchor.TopLeft)
    GUI.SetPivot(costBg, UIAroundPivot.TopLeft)
--左下角装饰
    local foo2 = GUI.ImageCreate(costBg,"foo2", "1801502030", 0, 0)
    GUI.SetAnchor(foo2, UIAnchor.BottomLeft)
    GUI.SetPivot(foo2, UIAroundPivot.BottomLeft)

--分割线底图
    local cutLine = GUI.ImageCreate(costBg,"cutLine", "1801401060", 3, 1)
    GUI.SetAnchor(cutLine, UIAnchor.TopLeft)
    GUI.SetPivot(cutLine, UIAroundPivot.TopLeft)

    local tipsText = GUI.CreateStatic(cutLine,"tipsText", "洗炼消耗", 4, 2, 120, 30, "system")
    GUI.SetAnchor(tipsText, UIAnchor.TopLeft)
    GUI.SetPivot(tipsText, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(tipsText, 22)


	for i = 1 ,#ClearItemsInfo do
	local itemDB = DB.GetOnceItemByKey2(ClearItemsInfo[i][4])
	local ClearItemIcon = GUI.ItemCtrlCreate(tabClearPanel,ClearItemsInfo[i][1],"",ClearItemsInfo[i][2],225,81,81)
	SetAnchorAndPivot(ClearItemIcon, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ItemCtrlSetElementValue(ClearItemIcon,eItemIconElement.Border,UIDefine.ItemIconBg2[itemDB.Grade])
	GUI.ItemCtrlSetElementValue(ClearItemIcon,eItemIconElement.Icon,tostring(itemDB.Icon))
	GUI.RegisterUIEvent(ClearItemIcon, UCE.PointerClick, "PetUI",ClearItemsInfo[i][5])
	
	local ItemName = GUI.CreateStatic( tabClearPanel, "ItemName"..i, ClearItemsInfo[i][3], ClearItemsInfo[i][2], 277, 160, 30, "system", true)
    SetAnchorAndPivot(ItemName, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(ItemName, 20)
    GUI.StaticSetAlignment(ItemName, TextAnchor.MiddleCenter)
	GUI.SetColor(ItemName, colorDark)
	end
	
--确认使用洗炼精粹的按钮
    local intensifyToggle = GUI.CheckBoxCreate (tabClearPanel,"intensifyToggle", "1800607150", "1800607151", 242, 361,Transition.ColorTint, false)
    GUI.SetAnchor(intensifyToggle, UIAnchor.TopLeft)
    GUI.SetPivot(intensifyToggle, UIAroundPivot.TopLeft)
	_gt.BindName(intensifyToggle,"intensifyToggle")
--战力	
	local FightNumIcon1 = GUI.ImageCreate(tabClearPanel,"FightNumIcon1", "1800407010", -410, 135)
	SetAnchorAndPivot(FightNumIcon1, UIAnchor.Center, UIAroundPivot.Center)
	local FightNumIcon2 = GUI.ImageCreate(tabClearPanel,"FightNumIcon2", "1800404020", -370, 135)
	SetAnchorAndPivot(FightNumIcon2, UIAnchor.Center, UIAroundPivot.Center)	
	local FightNum = GUI.CreateStatic( tabClearPanel, "FightNum","0", -315, 136.5, 160, 30, "system", true)
    SetAnchorAndPivot(FightNum, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(FightNum, 22)
    GUI.StaticSetAlignment(FightNum, TextAnchor.MiddleCenter)
	GUI.SetColor(FightNum, colorDark)
	_gt.BindName(FightNum,"FightNum")
	---战力需要绑定
	
	
    local btns =
    {
        {"AttrLockBtn", "锁定", -325, "OnAttrLockBtnClick", true},
        {"SaveBtn", "保存", 23, "OnSaveBtnClick", false},
        {"ClearBtn", "洗炼", 192, "OnClearBtnClick", true}
    }

    for i = 1, #btns do
        local btn = GUI.ButtonCreate(tabClearPanel,btns[i][1], "1800402080", btns[i][3], 477, Transition.ColorTint, "")
        GUI.SetAnchor(btn, UIAnchor.TopLeft)
        GUI.SetPivot(btn, UIAroundPivot.TopLeft)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "PetUI", btns[i][4])

        local text = GUI.CreateStatic(btn,"text", btns[i][2], 0, 0, 160, 47, "system", true)
        GUI.SetAnchor(text, UIAnchor.Center)
        GUI.SetPivot(text, UIAroundPivot.Center)
        GUI.StaticSetFontSize(text, fontSizeBtn)
        GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
        GUI.SetColor(text,colorWhite)
        GUI.SetIsOutLine(text, true)
        GUI.SetOutLine_Color(text, colorOutline)
        GUI.SetOutLine_Distance(text, 1)

        GUI.ButtonSetShowDisable(btn, btns[i][5])
		if i == 2 then
			_gt.BindName(btn,"SaveBtn")
		end
    end


end	
	

function PetUI.RefreshClearPanel()
	local tabBreachPanel = GUI.Get("PetUI/panelBg/pageRefinePanel/tabBreachPanel")
	GUI.SetVisible(tabBreachPanel,false)
	local BreachplzBg = _gt.GetUI("BreachplzBg")
	GUI.SetVisible(BreachplzBg,false)
	local BreachplzText = GUI.GetChild(BreachplzBg,"BreachplzText")
	local touchBtn = _gt.GetUI("touchBtn")
	GUI.SetVisible(touchBtn,true)
	local tabClearPanel = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel")
	local PetGUID= PetUI.petGuid
	local BtnTorF =false
	local PetAttrList = {}
	if PetGUID ~= nil then
		local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,PetGUID)
		local moban =DB.GetOncePetByKey1(id)
		local attrList4 = {17,18,19,20,21,22}
		local star =LD.GetPetIntCustomAttr("PetStarLevel",PetGUID,pet_container_type.pet_container_panel)
		
	--道具数量帅新
		for i = 1 ,#ClearItemsInfo do
			local ClearItemIcon =GUI.GetChild(tabClearPanel,ClearItemsInfo[i][1])
			local ClearItemNum1 =LD.GetItemCountById(ClearItemsInfo[i][6],item_container_type.item_container_bag)	
			local ClearItemNum2 = 0
			if i ~= 2  then
				if PetUI.PetRefiningConsume["LockItemKeyname"] then
					ClearItemNum2 =PetUI.PetRefiningConsume[ClearItemsInfo[i][7]][2]
				else
					ClearItemNum2 = 0
				end
				if ClearItemNum1 >= ClearItemNum2 then
					GUI.ItemCtrlSetElementValue(ClearItemIcon,eItemIconElement.RightBottomNum,ClearItemNum1.."/"..ClearItemNum2)
					local NumText = GUI.ItemCtrlGetElement(ClearItemIcon,eItemIconElement.RightBottomNum)
					GUI.SetColor(NumText,Color.New(255 / 255, 255 / 255, 255 / 255, 1))
				else 
					GUI.ItemCtrlSetElementValue(ClearItemIcon,eItemIconElement.RightBottomNum,ClearItemNum1.."/"..ClearItemNum2)
					local NumText = GUI.ItemCtrlGetElement(ClearItemIcon,eItemIconElement.RightBottomNum)
					GUI.SetColor(NumText,Color.New(255 / 255, 0 / 255, 0 / 255, 1))	
				end
			else 
				if #LockAttrList ~= 0 then
					ClearItemNum2 = PetUI.PetRefiningConsume["LockItemNum"][#LockAttrList]
					if ClearItemNum1 >= ClearItemNum2 then
						GUI.ItemCtrlSetElementValue(ClearItemIcon,eItemIconElement.RightBottomNum,ClearItemNum1.."/"..ClearItemNum2)
						local NumText = GUI.ItemCtrlGetElement(ClearItemIcon,eItemIconElement.RightBottomNum)
						GUI.SetColor(NumText,Color.New(255 / 255, 255 / 255, 255 / 255, 1))
					else
						GUI.ItemCtrlSetElementValue(ClearItemIcon,eItemIconElement.RightBottomNum,ClearItemNum1.."/"..ClearItemNum2)
						NumText = GUI.ItemCtrlGetElement(ClearItemIcon,eItemIconElement.RightBottomNum)
						GUI.SetColor(NumText,Color.New(255 / 255, 0 / 255, 0 / 255, 1))
					end
				else
					GUI.ItemCtrlSetElementValue(ClearItemIcon,eItemIconElement.RightBottomNum,ClearItemNum1.."/"..ClearItemNum2)
					local NumText = GUI.ItemCtrlGetElement(ClearItemIcon,eItemIconElement.RightBottomNum)
					GUI.SetColor(NumText,Color.New(255 / 255, 255 / 255, 255 / 255, 1))
				end
			end
		end
	
		
	
	--星级刷新
		local petModelGroup = GUI.Get("PetUI/panelBg/petModelGroup")
		for i = 1 ,6 do
			local StarLevel = GUI.GetChild(petModelGroup,"StarLevel"..i)
			GUI.ImageSetImageID(StarLevel,"1801202192")
			GUI.SetVisible(StarLevel,true)
			GUI.SetPositionX(StarLevel,-100+(i*25))
			GUI.SetPositionY(StarLevel,-10)
		end
		for i = 1 ,star do
			local StarLevel = GUI.GetChild(petModelGroup,"StarLevel"..i)
			GUI.ImageSetImageID(StarLevel,"1801202190")
		end
	--资质刷新
		for i = 1, #PetUI.PetUpStarIntConfig do
			local data = PetUI.PetUpStarIntConfig[i]
			local currentTxt = _gt.GetUI(data[4].."Clear")
			local tempSlider = _gt.GetUI("tempSlider"..i.."Clear")
			local EnhanceChange = _gt.GetUI("EnhanceChange"..i)
			local attrTb= petProperty[attrList4[i]]
			local keyname = petProperty[attrList4[i]][1]
			local Num1 = 0
			local Num2 =PetUI.PetAttrChange[keyname]
			if PetUI.PetAttrChange[keyname] >= 0 then
					Num1 = (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid)) + (PetUI.PetAttrChange[keyname])
			else
					Num1 = (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))+(PetUI.PetAttrChange[keyname])
			end
			GUI.StaticSetText(currentTxt, Num1.. "/" ..(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)))
			GUI.ScrollBarSetPos(tempSlider,Num1/(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)))
		--判断是否资质全满需要突破(+满星特殊显示)
			if (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid)) == (LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)) then
				table.insert(PetAttrList,i)
			end	
		--刷新资质及资质条变化
			if PetUI.PetAttrChange[keyname] > 0 then
				if (Num2/Num1)*1000 > 0 and (Num2/Num1)*1000 <=50 then
					GUI.StaticSetText(EnhanceChange,"<color=#46DC5Fff>".."+"..Num2.."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408160")
				elseif (Num2/Num1)*1000 > 50 and (Num2/Num1)*1000 <=115 then
					GUI.StaticSetText(EnhanceChange,"<color=#42B1F0ff>".."+"..Num2.."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408130")
				elseif (Num2/Num1)*1000 > 115 and (Num2/Num1)*1000 <=180 then
					GUI.StaticSetText(EnhanceChange,"<color=#f08bffff>".."+"..Num2.."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408150")
				elseif (Num2/Num1)*1000 > 180 and (Num2/Num1)*1000 <=99999 then
					GUI.StaticSetText(EnhanceChange,"<color=#FF8700ff>".."+"..Num2.."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408140")
				end
			elseif PetUI.PetAttrChange[keyname] == 0 then
				if Num1 == (LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)) then
					GUI.StaticSetText(EnhanceChange,"<color=#46DC5Fff>".."满".."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408160")
				else
					GUI.StaticSetText(EnhanceChange,"<color=#46DC5Fff>"..Num2.."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408160")
				end
			elseif PetUI.PetAttrChange[keyname] < 0 then
				GUI.StaticSetText(EnhanceChange,"<color=#FF0000ff>"..Num2.."</color>")
				GUI.ScrollBarSetFillImgName(tempSlider,"1800408120")
			end
		--判断是否有资质变化
			if PetUI.PetAttrChange[keyname] ~= 0  then
					BtnTorF =true
			end
		--锁定按钮重置
			local lockmark = _gt.GetUI("lockmark"..i)
			GUI.ImageSetImageID(lockmark,"1801207120")
		end	
		--保存按钮启用
				local btn = _gt.GetUI("SaveBtn")
				if BtnTorF == true then
					GUI.ButtonSetShowDisable(btn,true)
					GUI.ButtonSetImageID(btn,"1800402090")	
				else
					GUI.ButtonSetImageID(btn,"1800402080")
					GUI.ButtonSetShowDisable(btn,false)		
				end
	--判断资质是否全满
			if #PetAttrList == 6 then
				local BreachplzBtn = GUI.GetChild(BreachplzBg,"BreachplzBtn")
				if star ==6 then
				GUI.SetVisible(BreachplzBg,true)
				GUI.SetVisible(BreachplzBtn,false)
				GUI.StaticSetText(BreachplzText,"属性全部达到上限")
				else
				GUI.SetVisible(BreachplzBg,true)
				GUI.SetVisible(BreachplzBtn,true)
				GUI.StaticSetText(BreachplzText,"属性全部达到上限，请先突破")
				end
				GUI.SetVisible(touchBtn,false)
			end
	--战力刷新
		local FightNum =_gt.GetUI("FightNum")
		GUI.StaticSetText(FightNum,tostring(LD.GetPetAttr(RoleAttr.RoleAttrFightValue,PetGUID)) )
		end
		
	--锁定按钮刷新
	for i=1, #LockAttrList do
		local a = LockAttrList[i]
		local lockmark = _gt.GetUI("lockmark"..a)
		GUI.ImageSetImageID(lockmark,"1801207130")
	end
	
end
--当资质锁定被点击
function PetUI.OnAttrLockBtnClick()
	PetUI.CreateAttrLockPanel()
	PetUI.RefreshAttrLockPanel()
end
-- 创建资质锁定界面
function PetUI.CreateAttrLockPanel()
    local tabClearPanel = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel")
    if tabClearPanel == nil then
        return
    end

    local AttrLockPanel = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel/AttrLockPanel")
    if AttrLockPanel ~= nil then
        GUI.SetDepth(AttrLockPanel, GUI.GetChildCount(tabClearPanel))
        GUI.SetVisible(AttrLockPanel, true)
        return
    end

    local AttrLockPanel = GUI.GroupCreate(tabClearPanel,"AttrLockPanel", -800,-160,1280,720)
    GUI.SetDepth(AttrLockPanel, GUI.GetChildCount(tabClearPanel))
	
    UILayout.CreateFrame_WndStyle2(AttrLockPanel,"资质洗炼",828,488)
    local closeBtn = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel/AttrLockPanel/panelBg/closeBtn");
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "PetUI", "OnAttrLockPanelClose")
    local panelCover = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel/AttrLockPanel/panelCover")
    GUI.RegisterUIEvent(panelCover, UCE.PointerClick, "PetUI", "OnAttrLockPanelClose")
    local panelBg = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel/AttrLockPanel/panelBg")

    local attrBg = GUI.ImageCreate(panelBg, "attrBg", "1800400200", 28, 69, false, 618, 385)
    GUI.SetAnchor(attrBg, UIAnchor.TopLeft)
    GUI.SetPivot(attrBg, UIAroundPivot.TopLeft)

    local titleBg = GUI.ImageCreate(attrBg,"titleBg", "1800700070", 0, 0, false, 618, 36)
    GUI.SetAnchor(titleBg, UIAnchor.Top)
    GUI.SetPivot(titleBg, UIAroundPivot.Top)

    -- 创建标题
    local titlesInfo =
    {
        {"资质类型", 0, 124},
        {"当前资质", 124, 256},
        {"提升", 380, 153},
        {"锁定", 533, 85},
    }

    for i = 1, #titlesInfo do
        local title = GUI.CreateStatic(titleBg,"attrTitle" .. i, titlesInfo[i][1], titlesInfo[i][2], 2,titlesInfo[i][3], 36, "system", false, false)
        GUI.SetAnchor(title, UIAnchor.TopLeft)
        GUI.SetPivot(title, UIAroundPivot.TopLeft)
        GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(title, fontSizeTitle)
        GUI.SetColor(title, colorDark)
    end

    -- 分割线
    for i = 1, #titlesInfo - 1 do
        local cutLine = GUI.ImageCreate(titleBg,"cutLine" .. i, "1800600220", titlesInfo[i + 1][2], 1)
        GUI.SetAnchor(cutLine,UIAnchor.TopLeft)
        GUI.SetPivot(cutLine,UIAroundPivot.TopLeft)
    end

    -- 属性列表
    for i = 1, #properties do
        local data = petProperty[properties[i]]
        local posX = 0
        local posY = 42 +  (i - 1) * 56

        local toggle = GUI.CheckBoxCreate(attrBg,data[2] .. "toggle", "1800400360", "1800400361", 0, posY,Transition.ColorTint, false, 600, 50, false)
        GUI.SetAnchor(toggle, UIAnchor.Top)
        GUI.SetPivot(toggle, UIAroundPivot.Top)
        GUI.SetData(toggle, "attrIndex",i)
        GUI.RegisterUIEvent(toggle, UCE.PointerClick , "PetUI", "OnLockItemClick")
		_gt.BindName(toggle,"toggle"..i)

        local label = GUI.CreateStatic(toggle,"label", data[1] .. "资质", 10, 0,  130, 36, "system", false, false)
        GUI.SetAnchor(label, UIAnchor.Left)
        GUI.SetPivot(label, UIAroundPivot.Left)
        GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(label, fontSizeBigger)
        GUI.SetColor(label, colorDark)

        local tempSlider = GUI.ScrollBarCreate(toggle,data[2], "", "1800408140", "1800408110", 120, 0, 246, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
        GUI.SetAnchor(tempSlider, UIAnchor.Left)
        GUI.SetPivot(tempSlider, UIAroundPivot.Left)
        local silderFillSize = Vector2.New(246, 24)
        GUI.ScrollBarSetFillSize(tempSlider, silderFillSize)
        GUI.ScrollBarSetBgSize(tempSlider, silderFillSize)
        GUI.SetIsRaycastTarget(tempSlider, false)
		_gt.BindName(tempSlider,"tempSlider"..i.."ClearLock")

        local currentTxt = GUI.CreateStatic(tempSlider,data[2].."ClearLock", "10000/10000", 0, 0,  200, 50, "system", true)
        GUI.SetAnchor(currentTxt, UIAnchor.Center)
        GUI.SetPivot(currentTxt, UIAroundPivot.Center)
        GUI.StaticSetFontSize(currentTxt, 22)
        GUI.StaticSetAlignment(currentTxt, TextAnchor.MiddleCenter)
		_gt.BindName(currentTxt,"ClearLock"..i)

        -- 提升范围
        local enhanceRange = GUI.CreateStatic(toggle,data[2] .. "EnhanceRange", "", 374, 0,  150, 28, "system", true, false)
        GUI.SetAnchor(enhanceRange, UIAnchor.Left)
        GUI.SetPivot(enhanceRange, UIAroundPivot.Left)
        GUI.StaticSetFontSize(enhanceRange, fontSizeSmaller)
        GUI.StaticSetAlignment(enhanceRange, TextAnchor.MiddleCenter)
        GUI.SetColor(enhanceRange, colorGreen)
		_gt.BindName(enhanceRange,"enhanceRange"..i)

        local lockMark = GUI.ImageCreate(toggle,"lockMark", "1801207120", 550, 0)
        GUI.SetAnchor(lockMark, UIAnchor.Left)
        GUI.SetPivot(lockMark, UIAroundPivot.Left)
		_gt.BindName(lockMark,"lockMark"..i)
		
    end
	--锁定消耗道具
	local itemIconBtn = GUI.ItemCtrlCreate(panelBg,"consumeItem","1900000000",693,296,0,0,true)
    GUI.SetAnchor(itemIconBtn, UIAnchor.TopLeft)
    GUI.SetPivot(itemIconBtn, UIAroundPivot.TopLeft)
    -- GUI.SetData(itemIconBtn, "itemId", PET_REFINE_LOCK_ITEM)
    GUI.RegisterUIEvent(itemIconBtn, UCE.PointerClick, "PetUpgradeUI", "OnClearItem2Click")
	_gt.BindName(itemIconBtn,"consumeItem")


    local name = GUI.CreateStatic(itemIconBtn,"name", "锁定消耗道具", 0, 55,120, 30, "system", true)
    GUI.SetColor(name, colorDark)
    GUI.StaticSetFontSize(name, 20)
    GUI.SetAnchor(name, UIAnchor.Center)
    GUI.SetPivot(name, UIAroundPivot.Center)

    -- 确认按钮
    local confirmBtn = GUI.ButtonCreate(panelBg,"confirmBtn", "1800402110", 672, 413, Transition.ColorTint, "确认", 128, 44, false)
    GUI.SetAnchor(confirmBtn, UIAnchor.TopLeft)
    GUI.SetPivot(confirmBtn, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(confirmBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(confirmBtn, UIDefine.FontSizeL)
    GUI.SetVisible(confirmBtn, true)
    GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "PetUI", "OnConfirmBtnClick")

end

--关闭锁定炼化页
function PetUI.OnAttrLockPanelClose()
	local AttrLockPanel = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel/AttrLockPanel")
    GUI.SetVisible(AttrLockPanel,false)
	LockAttrList={}
	PetUI.RefreshAttrLockPanel()
	PetUI.RefreshClearPanel()
end

--锁定炼化页的刷新
function PetUI.RefreshAttrLockPanel()
	local attrList4 = {17,18,19,20,21,22}
	if PetUI.petGuid ~= nil then
		for i = 1, #PetUI.PetUpStarIntConfig do
			local data = PetUI.PetUpStarIntConfig[i]
			local currentTxt = _gt.GetUI("ClearLock"..i)
			local tempSlider = _gt.GetUI("tempSlider"..i.."ClearLock")
			local enhanceRange = _gt.GetUI("enhanceRange"..i)
			local attrTb= petProperty[attrList4[i]]
			local keyname = petProperty[attrList4[i]][1]
			local Num1 = 0
			local Num2 =PetUI.PetAttrChange[keyname]
			if PetUI.PetAttrChange[keyname] >= 0 then
						Num1 = (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid)) + (PetUI.PetAttrChange[keyname])
			else
						Num1 = (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))+(PetUI.PetAttrChange[keyname])
			end
				GUI.StaticSetText(currentTxt, Num1.. "/" ..(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)))
				GUI.ScrollBarSetPos(tempSlider,Num1/(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)))
			--刷新资质及资质条变化
			if PetUI.PetAttrChange[keyname] > 0 then
				if (Num2/Num1)*1000 > 0 and (Num2/Num1)*1000 <=50 then
					GUI.StaticSetText(enhanceRange,"<color=#46DC5Fff>".."+"..Num2.."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408160")
				elseif (Num2/Num1)*1000 > 50 and (Num2/Num1)*1000 <=115 then
					GUI.StaticSetText(enhanceRange,"<color=#42B1F0ff>".."+"..Num2.."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408130")
				elseif (Num2/Num1)*1000 > 115 and (Num2/Num1)*1000 <=180 then
					GUI.StaticSetText(enhanceRange,"<color=#f08bffff>".."+"..Num2.."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408150")
				elseif (Num2/Num1)*1000 > 180 and (Num2/Num1)*1000 <=99999 then
					GUI.StaticSetText(enhanceRange,"<color=#FF8700ff>".."+"..Num2.."</color>")
					GUI.ScrollBarSetFillImgName(tempSlider,"1800408140")
				end
			elseif PetUI.PetAttrChange[keyname] == 0 then
				GUI.StaticSetText(enhanceRange,"<color=#46DC5Fff>"..Num2.."</color>")
				GUI.ScrollBarSetFillImgName(tempSlider,"1800408160")
			elseif PetUI.PetAttrChange[keyname] < 0 then
				GUI.StaticSetText(enhanceRange,"<color=#FF0000ff>"..Num2.."</color>")
				GUI.ScrollBarSetFillImgName(tempSlider,"1800408120")
			end
		end
	end
	--锁定界面道具的刷新
	local consumeItem = _gt.GetUI("consumeItem")
	local itemDB = DB.GetOnceItemByKey2("洗练锁定符")
	GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.Icon,"1900000470")
	GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.Border ,UIDefine.ItemIconBg2[itemDB.Grade])
	GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.RightBottomNum,LD.GetItemCountById(35510).."/0")
	local NumText = GUI.ItemCtrlGetElement(consumeItem,eItemIconElement.RightBottomNum)
	GUI.SetColor(NumText,Color.New(255 / 255, 255 / 255, 255 / 255, 1))
	if #LockAttrList ~= 0 then
		local Num1 = LD.GetItemCountById(35510)
		local Num2 = PetUI.PetRefiningConsume["LockItemNum"][#LockAttrList]
		if Num1 >= Num2 then
			GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.RightBottomNum,Num1.."/"..Num2)
		else
			GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.RightBottomNum,Num1.."/"..Num2)
			NumText = GUI.ItemCtrlGetElement(consumeItem,eItemIconElement.RightBottomNum)
			GUI.SetColor(NumText,Color.New(255 / 255, 0 / 255, 0 / 255, 1))
		end
	else
		local Num1 = LD.GetItemCountById(35510)
		GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.RightBottomNum,Num1.."/0")
	end
	--锁定页清空
	if #LockAttrList ==0 then
		for i= 1 , 6 do
			local lockMark = _gt.GetUI("lockMark"..i)
			local toggle = _gt.GetUI("toggle"..i)
			GUI.CheckBoxSetCheck(toggle,false)
			GUI.ImageSetImageID(lockMark,"1801207120")
		end
	end
end

function PetUI.OnLockItemClick(guid)
	if PetUI.petGuid ~= nil then
		local attrIndex = GUI.GetData(GUI.GetByGuid(guid),"attrIndex")
		local lockMark = _gt.GetUI("lockMark"..attrIndex)
		local toggle = _gt.GetUI("toggle"..attrIndex)
		if #LockAttrList <5 then
			if GUI.CheckBoxGetCheck(toggle) then
				table.insert(LockAttrList,attrIndex)
				GUI.ImageSetImageID(lockMark,"1801207130")
			else
				for i = 1, #LockAttrList do
					if attrIndex == LockAttrList[i] then
					table.remove(LockAttrList, i)
					end
				end
				GUI.ImageSetImageID(lockMark,"1801207120")
			end
		else
			GUI.CheckBoxSetCheck(toggle,false)
			GUI.ImageSetImageID(lockMark,"1801207120")
			local indexTorF = 0
			for i = 1, #LockAttrList do
				if attrIndex == LockAttrList[i] then
				table.remove(LockAttrList, i)
				indexTorF = 1
				end
			end
			if indexTorF ==0 then
			CL.SendNotify(NOTIFY.ShowBBMsg, "最多锁定5个洗炼属性")
			end
		end

		--道具的数量刷新（可以移到刷新的地方）
		local consumeItem = _gt.GetUI("consumeItem")
		GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.RightBottomNum,"0/0")
		local NumText = GUI.ItemCtrlGetElement(consumeItem,eItemIconElement.RightBottomNum)
		GUI.SetColor(NumText,Color.New(255 / 255, 255 / 255, 255 / 255, 1))
		if #LockAttrList ~= 0 then
			local Num1 = LD.GetItemCountById(35510)
			local Num2 = PetUI.PetRefiningConsume["LockItemNum"][#LockAttrList]
			if Num1 >= Num2 then
				GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.RightBottomNum,Num1.."/"..Num2)
			else
				GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.RightBottomNum,Num1.."/"..Num2)
				NumText = GUI.ItemCtrlGetElement(consumeItem,eItemIconElement.RightBottomNum)
				GUI.SetColor(NumText,Color.New(255 / 255, 0 / 255, 0 / 255, 1))
			end
		else
			local Num1 = LD.GetItemCountById(35510)
			GUI.ItemCtrlSetElementValue(consumeItem,eItemIconElement.RightBottomNum,Num1.."/0")
		end
		PetUI.RefreshClearPanel()
	end
end
--当资质锁定页确定按钮被点击
function PetUI.OnConfirmBtnClick()
	local AttrLockPanel = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel/AttrLockPanel")
    GUI.SetVisible(AttrLockPanel,false)
end

local PetAttrFullList = {}
local PetAttrLockwithFull = {}
local TorF = 0
--当按洗练按钮
function PetUI.OnClearBtnClick()
	if PetUI.petGuid ~= nil then
		--判断是否需要锁定资质
		PetAttrFullList = {}
		PetAttrLockwithFull = {}
		for i = 1, #PetUI.PetUpStarIntConfig do
			local attrList4 = {17,18,19,20,21,22}
			local data = PetUI.PetUpStarIntConfig[i]
			local attrTb= petProperty[attrList4[i]]
			local Num1 = (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))
			local Num2 = (LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid))
			if Num1 == Num2 then
				table.insert(PetAttrFullList,i)
			end
		end
		if  #PetAttrFullList ~=0 then
			if #PetAttrFullList <= #LockAttrList then
				for k = 1 , #PetAttrFullList do
					for v = 1 ,#LockAttrList do
						if 	tonumber(LockAttrList[v]) == tonumber(PetAttrFullList[k]) then
							table.insert(PetAttrLockwithFull,k)
						end
					end
				end
				if #PetAttrLockwithFull ~= #PetAttrFullList then
					for i = 1, #PetAttrLockwithFull do
					end
					GlobalUtils.ShowBoxMsg2Btn("提示","您的宠物已有属性已达上限，建议锁定该属性","PetUI","去锁定","OnAttrLockBtnClick","直接洗炼","UseOrNotBetterClear")
				else
					PetUI.UseOrNotBetterClear()
				end
			elseif #PetAttrFullList > #LockAttrList then
				GlobalUtils.ShowBoxMsg2Btn("提示","您的宠物已有属性已达上限，建议锁定该属性","PetUI","去锁定","OnAttrLockBtnClick","直接洗炼","UseOrNotBetterClear")
			end
		else
			PetUI.UseOrNotBetterClear()
		end
	end
end

function PetUI.UseOrNotBetterClear()
	--判断是否推荐使用洗炼精粹
	local intensifyToggle = _gt.GetUI("intensifyToggle")
	local ClearItem3Num = LD.GetItemCountById(35509)
	if GUI.CheckBoxGetCheck(intensifyToggle) then
		TorF = 1 
		PetUI.SendClearNotify()
	else 
		if ClearItem3Num >= 1 then
			TorF = 0
			GlobalUtils.ShowBoxMsg2Btn("提示","使用洗炼精粹可以获得更好的洗炼效果，是否勾选？","PetUI","确认","OnClealrItem3BtnClick","取消","SendClearNotify")
		else
			TorF = 0
			PetUI.SendClearNotify()
		end	
	end
end

function PetUI.OnClealrItem3BtnClick()
	local intensifyToggle = _gt.GetUI("intensifyToggle")
	GUI.CheckBoxSetCheck(intensifyToggle,true)
	TorF = 1
	PetUI.OnClearBtnClick()
end


function PetUI.SendClearNotify()
	--获得锁定的数据
	local LockAttr = ""
	if #LockAttrList ~= 0 then
		for _ ,v in ipairs(LockAttrList) do
			LockAttr = LockAttr..tostring(v)..","
		end
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormPetRefining", "StartRefining",PetUI.petGuid,TorF,LockAttr)
end

--保存资质时刷新界面
function PetUI.RefreshSavePetAttr()
	--资质刷新
	local attrList4 = {17,18,19,20,21,22}
	for i = 1, #PetUI.PetUpStarIntConfig do
		local data = PetUI.PetUpStarIntConfig[i]
		local currentTxt = _gt.GetUI(data[4].."Clear")
		local tempSlider = _gt.GetUI("tempSlider"..i.."Clear")
		local EnhanceChange = _gt.GetUI("EnhanceChange"..i)
		local EnhanceChangeTxet= "0"
		local attrTb= petProperty[attrList4[i]]
		local keyname = petProperty[attrList4[i]][1]
		GUI.StaticSetText(currentTxt, (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid)).. "/" ..(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)))
		GUI.ScrollBarSetPos(tempSlider,(LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))/(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)))
		------------------------------------------------------------------------------------------------------------------------------
		if (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid)) == (LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)) then
			EnhanceChangeTxet = "满"
		end
		------------------------------------------------------------------------------------------------------------------------------
		GUI.StaticSetText(EnhanceChange,EnhanceChangeTxet)
		GUI.ScrollBarSetFillImgName(tempSlider,"1800408160")
	end	
	--战力刷新
	local FightNum =_gt.GetUI("FightNum")
	GUI.StaticSetText(FightNum,tostring(LD.GetPetAttr(RoleAttr.RoleAttrFightValue,PetUI.petGuid)) )
end

--当按保存按钮
function PetUI.OnSaveBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm, "FormPetRefining", "SeveAttr",PetUI.petGuid)

end
--三个道具分别的TIP
function PetUI.OnClearItem1Click()
	local itemId = DB.GetOnceItemByKey2(ClearItemsInfo[1][4]).Id
	local parent = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel")
	local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -200, 0, 50)  --创造提示
	GUI.SetData(itemtips, "ItemId", tostring(itemId))
	_gt.BindName(itemtips,"ClearItemItem1Tips")
	local cutLine = GUI.GetChild(itemtips,"CutLine")
	GUI.SetPositionX(cutLine,-200)
	local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
	UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickClearItemItem1WayBtn")
    GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))				
end

function PetUI.OnClickClearItemItem1WayBtn()
	local tips = _gt.GetUI("ClearItemItem1Tips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

function PetUI.OnClearItem2Click()
	local itemId = DB.GetOnceItemByKey2(ClearItemsInfo[2][4]).Id
	local parent = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel")
	local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -200, 0, 50)  --创造提示
	GUI.SetData(itemtips, "ItemId", tostring(itemId))
	_gt.BindName(itemtips,"ClearItemItem2Tips")
	local cutLine = GUI.GetChild(itemtips,"CutLine")
	GUI.SetPositionX(cutLine,-200)
	local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
	UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickClearItemItem2WayBtn")
    GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
end

function PetUI.OnClickClearItemItem2WayBtn()
	local tips = _gt.GetUI("ClearItemItem2Tips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

function PetUI.OnClearItem3Click()
	local itemId = DB.GetOnceItemByKey2(ClearItemsInfo[3][4]).Id
	local parent = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel")
	local itemtips =  Tips.CreateByItemId(itemId,parent, "itemtips", -200, 0, 50)  --创造提示
	GUI.SetData(itemtips, "ItemId", tostring(itemId))
	_gt.BindName(itemtips,"ClearItemItem3Tips")
	local cutLine = GUI.GetChild(itemtips,"CutLine")
	GUI.SetPositionX(cutLine,-200)
	local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
	UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickClearItemItem3WayBtn")
    GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))	
end

function PetUI.OnClickClearItemItem3WayBtn()
	local tips = _gt.GetUI("ClearItemItem3Tips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end

--从洗炼页跳转突破页
function PetUI.OnBreachplzBtnClick()
	PetUI.OnTabBtnClick(tabBtns3[2].guid)

end

----------------------------------------------------------------------------------------突破--------------------------------------------------------------------------------------------------------
local BreachSuccessText=
{
    {"role_hp_talent", "气血资质上限", -290, -50,"TalentHPMax",    204},
    {"role_speed_talent","速度资质上限", 80, -50,"TalentSpeedMax", 206},  

    {"role_magatk_talent","法攻资质上限", -290, -15,"TalentMagAtkMax",209},
    {"role_magdef_talent","法防资质上限", 80, -15,"TalentMagDefMax",210},

    {"role_phyatk_talent","物攻资质上限", -290, 20, "TalentPhyAtkMax",207},
    {"role_phydef_talent","物防资质上限", 80, 20,"TalentPhyDefMax",208},

    {"fight_value","战       力", -290, 55,"FightValue",0},
}

function PetUI.CreateBreachTab()
	local pageRefinePanel = GUI.Get(pageNames[3][2])
	if pageRefinePanel == nil then
        return
    end

	local tabBreachPanel = GUI.Get(tabNames[10][2])
    if tabBreachPanel ~= nil then 
		GUI.SetVisible(tabBreachPanel,true)
        return
    end
	
	
    local tabBreachPanel = GUI.ImageCreate(pageRefinePanel,"tabBreachPanel", "1800400200", 160, -240, false, 350, 525)
    GUI.SetAnchor(tabBreachPanel, UIAnchor.TopLeft)
    GUI.SetPivot(tabBreachPanel, UIAroundPivot.TopLeft)

    local titleBg = GUI.ImageCreate(tabBreachPanel,"titleBg", "1800700070", 0, 0,  false, 348, 36)
    GUI.SetAnchor(titleBg, UIAnchor.Top)
    GUI.SetPivot(titleBg, UIAroundPivot.Top)

    -- 创建标题
    local titlesInfo =
    {
        {"资质类型", 0, 85},
        {"当前资质", 85, 146},
        {"上限提升", 231, 117},
    }

    for i = 1, #titlesInfo do
        local title = GUI.CreateStatic(titleBg,"attrTitle" .. i, titlesInfo[i][1], titlesInfo[i][2], 2,  titlesInfo[i][3], 36, "system", false, false)
        GUI.SetAnchor(title, UIAnchor.TopLeft)
        GUI.SetPivot(title, UIAroundPivot.TopLeft)
        GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(title, 18)
        GUI.SetColor(title, Color.New(104 / 255, 72 / 255, 38 / 255, 1))
    end
    for i = 1, #titlesInfo - 1 do
        local cutcutLine = GUI.ImageCreate(titleBg,"cutLine" .. i, "1800600220", titlesInfo[i + 1][2], 1)
        GUI.SetAnchor(cutcutLine,UIAnchor.TopLeft)
        GUI.SetPivot(cutcutLine,UIAroundPivot.TopLeft)
    end
--装饰
	local foo = GUI.ImageCreate( tabBreachPanel,"foo", "1801502030", 2, 288)
    GUI.SetAnchor(foo, UIAnchor.TopLeft)
    GUI.SetPivot(foo, UIAroundPivot.TopLeft)
	

	for i = 1, #PetUI.PetUpStarIntConfig do
		local data = PetUI.PetUpStarIntConfig[i]
		local posX = 0
		local posY = 42 +  (i - 1) * 42

		local imgId = "1801501020"
		if i % 2 == 0 then
			imgId= "1801501010"
		end
		local bg = GUI.ImageCreate(tabBreachPanel,data[1] .. "bg", imgId, posX + 3, posY - 6,  false, 344, 42)
		GUI.SetAnchor(bg, UIAnchor.TopLeft)
		GUI.SetPivot(bg, UIAroundPivot.TopLeft)

		local label = GUI.CreateStatic(tabBreachPanel,data[1] .. "label", data[2], posX, posY, 85, 36, "system", false, false)
		GUI.SetAnchor(label, UIAnchor.TopLeft)
		GUI.SetPivot(label, UIAroundPivot.TopLeft)
		GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter)
		GUI.StaticSetFontSize(label, 20)
		GUI.SetColor(label, Color.New(151 / 255, 92 / 255, 34 / 255, 255 / 255))	
		
		local tempSlider = GUI.ScrollBarCreate(tabBreachPanel,data[1], "", "1800408160", "1800408110", posX + 160, posY + 15, 0, 0,  1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
		_gt.BindName(tempSlider,"tempSlider"..i.."Breach")

        local silderFillSize = Vector2.New(148, 24)
        GUI.ScrollBarSetFillSize(tempSlider, silderFillSize)
        GUI.ScrollBarSetBgSize(tempSlider, silderFillSize)
        GUI.SetAnchor(tempSlider, UIAnchor.TopLeft)
        GUI.SetPivot(tempSlider, UIAroundPivot.TopLeft)

        local currentTxt = GUI.CreateStatic(tempSlider,data[1] .. "Text", "", 0, 0,  120, 30, "system", true)
        GUI.SetAnchor(currentTxt, UIAnchor.Center)
        GUI.SetPivot(currentTxt, UIAroundPivot.Center)
		GUI.StaticSetAlignment(currentTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(currentTxt, 20)
		_gt.BindName(currentTxt,data[4].."Breach")
		----需要给资质绑定
		
		--提升范围  暂时取不到
        local enhanceRange = GUI.CreateStatic(tabBreachPanel,data[1] .. "EnhanceRange", "", posX + 244, posY,  118, 28, "system", true, false)
        GUI.SetAnchor(enhanceRange, UIAnchor.TopLeft)
        GUI.SetPivot(enhanceRange, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(enhanceRange, 22)
        GUI.StaticSetAlignment(enhanceRange, TextAnchor.MiddleCenter)
        GUI.SetColor(enhanceRange, colorGreen)
		_gt.BindName(enhanceRange,"enhanceRange"..i)

	end
	

		
--右边下边的技能框
	local BreachSkillsBg = GUI.ImageCreate( tabBreachPanel, "BreachSkillsBg", "1800700050", 0, 355, false, 350, 160)
	SetAnchorAndPivot(BreachSkillsBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

	local BreachSkillScroll = GUI.LoopScrollRectCreate(BreachSkillsBg, "BreachSkillScroll", 0, 60, 330, 80,
	"PetUI", "CreateBreachSkillItem", "PetUI", "RefreshBreachSkillScroll", 0, false, Vector2.New(80, 80), 4, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(BreachSkillScroll, UILayout.Top)
	_gt.BindName(BreachSkillScroll, "BreachSkillScroll")
		
		 -- 技能栏上的备注文本
	local cutLine = GUI.ImageCreate(tabBreachPanel,"cutLine", "1801401060", 18, 372)
	GUI.SetAnchor(cutLine, UIAnchor.TopLeft)
	GUI.SetPivot(cutLine, UIAroundPivot.TopLeft)

	local unlockText = GUI.CreateStatic(cutLine, "unlockText", "突破后解锁技能", 4, 2,200, 30,"system")
	GUI.SetAnchor(unlockText, UIAnchor.TopLeft)
	GUI.SetPivot(unlockText, UIAroundPivot.TopLeft)
	GUI.StaticSetFontSize(unlockText, 26)	
		
		
--左侧添加宠物框
	local middleBg = GUI.ImageCreate(tabBreachPanel,"middleBg", "1800400200", -340, 265, false, 330, 210)
    GUI.SetAnchor(middleBg, UIAnchor.TopLeft)
    GUI.SetPivot(middleBg, UIAroundPivot.TopLeft)

    local eatTitleBg = GUI.ImageCreate(middleBg,"eatTitleBg", "1801300160", 0, 5,  false, 276, 42)
    GUI.SetAnchor(eatTitleBg, UIAnchor.Top)
    GUI.SetPivot(eatTitleBg, UIAroundPivot.Top)

    local eatTip = GUI.CreateStatic(eatTitleBg,"eatTip", "添加宠物，完成突破", 0, 0,  224, 35, "system", true)
    GUI.SetAnchor(eatTip, UIAnchor.Center)
    GUI.SetPivot(eatTip, UIAroundPivot.Center)
    GUI.StaticSetFontSize(eatTip, 20)
    GUI.StaticSetAlignment(eatTip, TextAnchor.MiddleCenter)
    GUI.SetColor(eatTip, Color.New(104 / 255, 70 / 255, 38 / 255, 1))
	
    local foo3 = GUI.ImageCreate(middleBg,"foo3", "1801502040", 2, -2)
    GUI.SetAnchor(foo3, UIAnchor.BottomLeft)
    GUI.SetPivot(foo3, UIAroundPivot.BottomLeft)
    local foo4 = GUI.ImageCreate(middleBg,"foo4", "1801502020", -2, -2)
    GUI.SetAnchor(foo4, UIAnchor.BottomRight)
    GUI.SetPivot(foo4, UIAroundPivot.BottomRight)
	

	
    -- 要吞噬的宠物
    local EatPetScrollWnd = GUI.ScrollRectCreate(middleBg,"EatPetScrollWnd", 0, 21, 280, 166, 0, false, Vector2.New(280, 240),  UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    GUI.SetAnchor(EatPetScrollWnd, UIAnchor.Center)
    GUI.SetPivot(EatPetScrollWnd, UIAroundPivot.Center)
    GUI.ScrollRectSetChildAnchor(EatPetScrollWnd, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(EatPetScrollWnd, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(EatPetScrollWnd, Vector2.New(0, 2))

    local SwallowedPetGroup = GUI.GroupCreate(EatPetScrollWnd,"SwallowedPetGroup", 0, 0,  280, 240)

    for i = 1, 5 do
        PetUI.CreateSwallowedPetItem(i, SwallowedPetGroup)
    end

	--满星时蒙版
	local UnBreachBg = GUI.ImageCreate(middleBg,"UnBreachBg", "1800400220", 0, 0,  false, 322, 205)
    GUI.SetAnchor(UnBreachBg, UIAnchor.Center)
    GUI.SetPivot(UnBreachBg, UIAroundPivot.Center)	
	local  UnBreachText = GUI.CreateStatic(UnBreachBg,"UnBreachText", "宠物已达到最高星级", 0, 0, 400, 50, "system")
	GUI.SetAnchor(UnBreachText, UIAnchor.Center)
    GUI.SetPivot(UnBreachText, UIAroundPivot.Center)
	GUI.StaticSetFontSize(UnBreachText, 24)
	GUI.StaticSetAlignment(UnBreachText, TextAnchor.MiddleCenter)
	_gt.BindName(UnBreachBg,"UnBreachBg")
	GUI.SetVisible(UnBreachBg,false)
	
--突破按钮
	local BreachBtn = GUI.ButtonCreate( tabBreachPanel, "BreachBtn", "1800402080", -172, 480, Transition.ColorTint, "")
    SetAnchorAndPivot(BreachBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(BreachBtn, UCE.PointerClick, "PetUI", "OnBreachBtnClick")
	_gt.BindName(BreachBtn,"BreachBtn")

    local BreachBtnText = GUI.CreateStatic( BreachBtn, "BreachBtnText", "突破", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(BreachBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(BreachBtnText, fontSizeBtn)
    GUI.StaticSetAlignment(BreachBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(BreachBtnText, true)
    GUI.SetOutLine_Color(BreachBtnText, colorOutline)
    GUI.SetOutLine_Distance(BreachBtnText, 1)
	
	local BreachCostBg = GUI.ImageCreate(tabBreachPanel, "BreachCostBg", "1800700010", -338,485, false, 160, 36)
		
	local BreachCostIcon = GUI.ImageCreate(BreachCostBg, "BreachCostIcon", "1800408280", 10, -1, false, 38, 38)
	SetAnchorAndPivot(BreachCostIcon, UIAnchor.Left , UIAroundPivot.Left )
	_gt.BindName(BreachCostIcon,"BreachCostIcon")

	local BreachCostText = GUI.CreateStatic(BreachCostBg, "BreachCostText", "0", 0, 1, 200, 35,"system",true)
	GUI.SetColor(BreachCostText, UIDefine.White2Color);
	GUI.StaticSetFontSize(BreachCostText, 22);
	GUI.StaticSetAlignment(BreachCostText, TextAnchor.MiddleCenter);
	_gt.BindName(BreachCostText, "BreachCostText")	

	

end


---------------------中间被吃掉的宠物
function PetUI.CreateSwallowedPetItem(index, parent)
    if parent == nil then
        return
    end

    local key = "SwallowedPet" .. index
    local item = GUI.GetChild(parent, key)
    if item ~= nil then
        return
    end

    local offsetX = 94
    local offsetY = 81
    local posX = 50
    local posY = 30
    if index <= 3 then
        posX = 10 + (index - 1) * offsetX
        posY = 2
    else
        posX = 53 + (index % 2) * offsetX
        posY = 2 + offsetY + math.floor((index - 4) / 2) * offsetY
    end

    item = GUI.ItemCtrlCreate(parent,key, "1800400330", posX, posY, 0, 0, false)
	GUI.SetData(item, "index", index)
	--t[GUI.GetGuid(item)] = index
    GUI.SetAnchor(item, UIAnchor.TopLeft)
    GUI.SetPivot(item, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "PetUI", "OnSwallowedPetItemClick")
end
-- -吞噬宠物被点击
function PetUI.OnSwallowedPetItemClick(guid)
	if PetUI.petGuid ~= nil then
		PetUI.PetListChange =1
		local star =LD.GetPetIntCustomAttr("PetStarLevel",PetUI.petGuid,pet_container_type.pet_container_panel)
		local index = GUI.GetData(GUI.GetByGuid(guid), "index")
		index = tonumber(index)
		if star == 6 then
			return
		else
			if  index > star then
				CL.SendNotify(NOTIFY.ShowBBMsg, "突破后才能解锁")
			else
				GUI.OpenWnd("PetSelectUI",tostring(PetUI.petGuid))
				local wnd = GUI.GetWnd("PetSelectUI")
				if wnd ~= nil and PetSelectUI ~= nil then
					PetSelectUI.SetConfirmCallBack(PetUI.SelectPetConfirmCallBack)
				end
			end
		end
	end
end

local EatEatPetList = {}

--被吞噬名单回调
function PetUI.SelectPetConfirmCallBack(SelectEatPetList)
	EatEatPetList=SelectEatPetList
	if #SelectEatPetList == 0 then
		PetUI.RefreshBreachPanel()
	end
	local SwallowedPetGroup = GUI.Get("PetUI/panelBg/pageRefinePanel/tabBreachPanel/middleBg/EatPetScrollWnd/SwallowedPetGroup")
	for i= 1 ,#SelectEatPetList do 
	local item = GUI.GetChild(SwallowedPetGroup,"SwallowedPet" .. i)
		local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, SelectEatPetList[i])
		local moban =DB.GetOncePetByKey1(id)
		GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,tostring(moban.Head))
		GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,UIDefine.PetItemIconBg3[moban.Type])
		GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,67,68)
		local star =LD.GetPetIntCustomAttr("PetStarLevel",SelectEatPetList[i],pet_container_type.pet_container_panel)
		UILayout.SetSmallStars(star, 6, item)
	end
end
--点击突破按钮时
local OldAttrValue = {}
function PetUI.OnBreachBtnClick()
	if PetUI.petGuid ~= nil then
		local star =LD.GetPetIntCustomAttr("PetStarLevel",PetUI.petGuid,pet_container_type.pet_container_panel)
		local EatPetguid = ""
		if #EatEatPetList >=star  then
			for _ ,v in ipairs(EatEatPetList) do
				EatPetguid = EatPetguid..tostring(v)..","
			end
		for i = 1 , #BreachSuccessText do
			if i == 7   then
				OldAttrValue[i]=tostring(LD.GetPetAttr(RoleAttr.RoleAttrFightValue,PetUI.petGuid)) 
			else
				local attrTb = BreachSuccessText[i]
				OldAttrValue[i]=LD.GetPetIntCustomAttr(attrTb[5],PetUI.petGuid)
			end
		end
			PetUI.PetListChange = 1
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetUpStar", "Breach",PetUI.petGuid,EatPetguid)
		else 
			CL.SendNotify(NOTIFY.ShowBBMsg, "吞噬数量不足")
		end
	end
end

--当突破成功时调用的刷新
function PetUI.OnBreachSuccessRefresh()
	EatEatPetList = {}
	PetUI.RefreshBreachPanel()
	PetUI.CreateBreachSuccessPanel()
	PetUI.RefreshBreachSuccessPanel()
end
----------------------右侧技能
function PetUI.CreateBreachSkillItem()
	local BreachSkillScroll = GUI.GetByGuid(_gt.BreachSkillScroll)
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(BreachSkillScroll);
	local BreachSkillItem = GUI.ItemCtrlCreate(PetEquipLeftScroll, "BreachSkillItem" .. curCount, "1800400330", 0, 0, 89, 89)
	GUI.RegisterUIEvent(BreachSkillItem, UCE.PointerClick, "PetUI", "OnBreachSkillItemClick")
	return BreachSkillItem;
end

function PetUI.RefreshBreachSkillScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	index = index +1
	local BreachSkillItem = GUI.GetByGuid(guid)
	if PetUI.petGuid==nil then	
		return;
	end
	local PetGUID= PetUI.petGuid
	local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,PetGUID)
    local moban =DB.GetOncePetByKey1(id)
	local star =LD.GetPetIntCustomAttr("PetStarLevel",PetGUID,pet_container_type.pet_container_panel)
	if index <= #PetUI.CurPetStarSkill then
		local dataKeyName=PetUI.CurPetStarSkill[index]
		-- CDebug.LogError(PetUI.CurPetStarSkill[index])
		local skillDB=DB.GetOnceSkillByKey2(dataKeyName)
		GUI.ItemCtrlSetElementValue(BreachSkillItem,eItemIconElement.Icon,tostring(skillDB.Icon))
		GUI.ItemCtrlSetElementValue(BreachSkillItem,eItemIconElement.Border,UIDefine.ItemIconBg[skillDB.SkillQuality])
		if star < PetUI.PetStarSkillLevel[index]   then
			GUI.ItemCtrlSetIconGray(BreachSkillItem,true)
		else
			GUI.ItemCtrlSetIconGray(BreachSkillItem,false)
		end
	else
		GUI.ItemCtrlSetElementValue(BreachSkillItem,eItemIconElement.Icon,nil)
		GUI.ItemCtrlSetElementValue(BreachSkillItem,eItemIconElement.Border,"1800400330")
	end
end
-----------------------------

function PetUI.RefreshBreachPanel()
	PetUI.PetStarSkillLevel = {}
	PetUI.CurPetStarSkill = {}
	local tabClearPanel = GUI.Get("PetUI/panelBg/pageRefinePanel/tabClearPanel")
	GUI.SetVisible(tabClearPanel,false)
	local PetGUID= PetUI.petGuid
	if PetGUID ~=nil then
		local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,PetGUID)
		local moban =DB.GetOncePetByKey1(id)
		local attrList4 = {17,18,19,20,21,22}
		local star =LD.GetPetIntCustomAttr("PetStarLevel",PetGUID,pet_container_type.pet_container_panel)

		--获得宠物突破技能对应的等级
		-- CDebug.LogError(#PetUI.PetStarSkill)
		-- local inspect = require("inspect")
		-- CDebug.LogError(inspect(PetUI.PetStarSkill[moban.KeyName]))
		if next(PetUI.PetStarSkill)and PetUI.PetStarSkill[moban.KeyName] then
			local temptable = {}
			for k,v in pairs(PetUI.PetStarSkill[moban.KeyName]) do
				k = string.split(k,"_")
				table.insert(PetUI.PetStarSkillLevel,tonumber(k[2])+1)
				temptable[tonumber(k[2])+1] = v
				-- CDebug.LogError(k[2])
			end
			table.sort(PetUI.PetStarSkillLevel, function(a, b)
				return a < b
			end)
			for i =1 ,#PetUI.PetStarSkillLevel do
				table.insert(PetUI.CurPetStarSkill,temptable[PetUI.PetStarSkillLevel[i]])
			end
		end
		
		local petModelGroup = GUI.Get("PetUI/panelBg/petModelGroup")
		for i = 1 ,6 do
			local StarLevel = GUI.GetChild(petModelGroup,"StarLevel"..i)
			GUI.ImageSetImageID(StarLevel,"1801202192")
			GUI.SetVisible(StarLevel,true)
			GUI.SetPositionX(StarLevel,-100+(i*25))
			GUI.SetPositionY(StarLevel,-10)
		end
		for i = 1 ,star do
			local StarLevel = GUI.GetChild(petModelGroup,"StarLevel"..i)
			GUI.ImageSetImageID(StarLevel,"1801202190")
		end

		local SwallowedPetGroup = GUI.Get("PetUI/panelBg/pageRefinePanel/tabBreachPanel/middleBg/EatPetScrollWnd/SwallowedPetGroup")
		for i = 1 , 5 do
		local item = GUI.GetChild(SwallowedPetGroup,"SwallowedPet" .. i)
		local starsBg = GUI.GetChild(item,"starsBg")
			if i > star then
			GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"1800400070")
			GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border ,"1800400330")
			GUI.SetVisible(starsBg,false)
			else 
			GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"1800707060")
			GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border ,"1800400330")
			GUI.SetVisible(starsBg,false)
			end
		end

		local BreachCostIcon = _gt.GetUI("BreachCostIcon")
		local coin_type = UIDefine.GetMoneyEnum(PetUI.PetUpStarConsume["Type_"..moban.Type]["Star_"..star]["MoneyType"] or 5) --MoneyType = 5
		GUI.ImageSetImageID(BreachCostIcon, UIDefine.AttrIcon[coin_type])
		
		local BreachCostText = _gt.GetUI("BreachCostText")
		local MoneyVal = 0 
		if star <= 5 then
			MoneyVal = PetUI.PetUpStarConsume["Type_"..moban.Type]["Star_"..star]["MoneyVal"]
		else
			MoneyVal = 0
		end
			
		local AttrMoney = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
		if AttrMoney >= MoneyVal then
			GUI.StaticSetText(BreachCostText,MoneyVal)
		else
			GUI.StaticSetText(BreachCostText,"<color=#FF0000>"..MoneyVal.."</color>")
		end

		--处理一下系数相关的表
		local temp_tb = {}
		local tb = {}
		-- if PetGUID ~= nil then
		local temp_tb = PetUI.PetStarAttr[tostring(PetGUID)]
		if temp_tb and next(temp_tb)then
			for k ,v in pairs(temp_tb) do
				if type(v) == "table" and v.IntKey then
					tb[v.IntKey] = v.Ratio
				end
			end
		end
		-- end
		for i = 1, #PetUI.PetUpStarIntConfig do
			local data = PetUI.PetUpStarIntConfig[i]
			local currentTxt = _gt.GetUI(data[4].."Breach")
			local tempSlider = _gt.GetUI("tempSlider"..i.."Breach")
			local enhanceRange = _gt.GetUI("enhanceRange"..i)
			local attrTb= petProperty[attrList4[i]]
			GUI.StaticSetText(enhanceRange,tb[data[1]] and "+"..tb[data[1]].."%" or "" )
			GUI.StaticSetText(currentTxt, (LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid)) .. "/" ..(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)))
			GUI.ScrollBarSetPos(tempSlider,(LD.GetPetIntAttr(RoleAttr[attrTb[2]], PetUI.petGuid))/(LD.GetPetIntCustomAttr(attrTb[6], PetUI.petGuid)))
		end
	
		local BreachSkillScroll = _gt.GetUI("BreachSkillScroll")
		GUI.LoopScrollRectSetTotalCount(BreachSkillScroll, 8) 
		GUI.LoopScrollRectRefreshCells(BreachSkillScroll)
		
		local UnBreachBg = _gt.GetUI("UnBreachBg")
		local BreachBtn = _gt.GetUI("BreachBtn")
	
		--满星时出现蒙版
		GUI.SetVisible(UnBreachBg,star ==6)
		--突破按钮不可用
		GUI.ButtonSetShowDisable(BreachBtn,star ~=6)
	end
	
end


--当宠物突破技能被点击
function PetUI.OnBreachSkillItemClick(guid)
	if PetUI.petGuid==nil then
		return;
	end
	-- local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid)
	local BreachSkillItem = GUI.GetByGuid(guid);
	local skills=GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetUI.petGuid)
	local index = GUI.ItemCtrlGetIndex(BreachSkillItem);
	index =index + 1 
	local star = LD.GetPetIntCustomAttr("PetStarLevel",PetUI.petGuid,pet_container_type.pet_container_panel)
	
	if PetUI.PetStarSkillLevel[index] then
		local dataKeyName=PetUI.CurPetStarSkill[index]
		if dataKeyName ~= nil then
			local skillDB=DB.GetOnceSkillByKey2(dataKeyName)
				--GUI.ItemCtrlSelect(skillItem);
			Tips.CreateBreachSkillId(tostring(skillDB.Id),_gt.GetUI("panelBg"),"tips",0,0,0,0,PetUI.PetStarSkillLevel[index],star)
		end
	end

end


function PetUI.CreateBreachSuccessPanel()
    local pageRefinePanel = GUI.Get("PetUI/panelBg/pageRefinePanel")

    local BreachSuccessPanel = GUI.Get("PetUI/panelBg/pageRefinePanel/BreachSuccessPanel")
    if BreachSuccessPanel ~= nil then
        GUI.SetVisible(BreachSuccessPanel, true)
        return
    end
    local BreachSuccessPanel = GUI.GroupCreate(pageRefinePanel,"BreachSuccessPanel", 0, 0, 0, 0)
    local BreachSuccessBg = GUI.ImageCreate(BreachSuccessPanel,"BreachSuccessBg", "1800400220", 0, -25, false,1380, 740)
    GUI.SetAnchor(BreachSuccessBg, UIAnchor.Center)
    GUI.SetPivot(BreachSuccessBg, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(BreachSuccessBg, true)
    BreachSuccessBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(BreachSuccessBg, UCE.PointerClick, "PetUI", "OnBreachBgClick")

    local CenterBg = GUI.ImageCreate(BreachSuccessBg,"CenterBg", "1801200060", 0, 0, false, 1380, 420)
    GUI.SetAnchor(CenterBg, UIAnchor.Center)
    GUI.SetPivot(CenterBg, UIAroundPivot.Center)

    local titleBg1 = GUI.ImageCreate(BreachSuccessBg,"titleBg1", "1801200050", -211, -20)
    GUI.SetAnchor(titleBg1, UIAnchor.Top)
    GUI.SetPivot(titleBg1, UIAroundPivot.Top)

    local titleBg2 = GUI.ImageCreate(BreachSuccessBg,"titleBg2", "1801200050", 211, -20)
    GUI.SetAnchor(titleBg2, UIAnchor.Top)
    GUI.SetPivot(titleBg2, UIAroundPivot.Top)
    GUI.SetScale(titleBg2, Vector3.New(-1,1,1))

    local titleBg3 = GUI.ImageCreate(BreachSuccessBg,"titleBg3", "1801204050", 0, 60)
    GUI.SetAnchor(titleBg3, UIAnchor.Top)
    GUI.SetPivot(titleBg3, UIAroundPivot.Top)

    local CenterGroup = GUI.GroupCreate(CenterBg,"CenterGroup", 0, 0,  1280, 420)
    GUI.SetAnchor(CenterGroup, UIAnchor.Center)
    GUI.SetPivot(CenterGroup, UIAroundPivot.Center)
	_gt.BindName(CenterGroup,"CenterGroup")

    for i = 1, 2 do
        local PetIconBg = GUI.ImageCreate(CenterGroup,"PetIconBg" .. i, "1801201140", (i - 1.5) * 204,30,true)
        GUI.SetAnchor(PetIconBg, UIAnchor.Top)
        GUI.SetPivot(PetIconBg, UIAroundPivot.Top)
        local PetIcon = GUI.ImageCreate(PetIconBg,"PetIcon" .. i, "1800500040", 0,-6,false,70,71)
        GUI.SetAnchor(PetIcon, UIAnchor.Center)
        GUI.SetPivot(PetIcon, UIAroundPivot.Center)
    end

    local TipTop = GUI.ImageCreate(CenterGroup,"TipTop", "1800707050", 0,40)
    GUI.SetAnchor(TipTop, UIAnchor.Top)
    GUI.SetPivot(TipTop, UIAroundPivot.Top)
	
	for i = 1,#BreachSuccessText do
	local Name = GUI.CreateStatic(CenterGroup,BreachSuccessText[i][1].."_Text",BreachSuccessText[i][2],BreachSuccessText[i][3],BreachSuccessText[i][4],200,50)
	GUI.StaticSetFontSize(Name, 22)
	GUI.StaticSetAlignment(Name, TextAnchor.MiddleCenter)
	
	local OldValue = GUI.CreateStatic(CenterGroup,BreachSuccessText[i][1].."_Old","4567",BreachSuccessText[i][3]+115,BreachSuccessText[i][4],200,50)
	GUI.StaticSetFontSize(OldValue, 22)
	GUI.StaticSetAlignment(OldValue, TextAnchor.MiddleCenter)	
	
	local arrows = GUI.ImageCreate(CenterGroup,"arrows", "1801208370", BreachSuccessText[i][3]+175,BreachSuccessText[i][4])
    GUI.SetAnchor(arrows, UIAnchor.Center)
    GUI.SetPivot(arrows, UIAroundPivot.Center)
		
	local NewValue = GUI.CreateStatic(CenterGroup,BreachSuccessText[i][1].."_New","7879",BreachSuccessText[i][3]+220,BreachSuccessText[i][4],200,50)
	GUI.StaticSetFontSize(NewValue, 22)
	GUI.SetColor(NewValue,Color.New(0, 1, 0, 1))
	GUI.StaticSetAlignment(NewValue, TextAnchor.MiddleCenter)
	end
	
	local NewSkill = GUI.ItemCtrlCreate(CenterGroup,"NewSkill", "1800700020",0,300,77,78)
    GUI.SetAnchor(NewSkill, UIAnchor.Top)
    GUI.SetPivot(NewSkill, UIAroundPivot.Top)
	GUI.SetVisible(NewSkill,false)

    local TipBottom = GUI.CreateStatic(BreachSuccessBg,"TipBottom", "点击任意位置继续游戏", 35, -60,300,50)
    GUI.SetAnchor(TipBottom, UIAnchor.Bottom)
    GUI.SetPivot(TipBottom, UIAroundPivot.Bottom)
    GUI.StaticSetFontSize(TipBottom, 22)

end

local PetGradeIcon={
[1]="1801201110",
[2]="1801201120",
[3]="1801201130",
[4]="1801201140",
[5]="1801201140",
[6]="1801201140",
[7]="1801201140"
}
--升星成功页面刷新数据
function PetUI.RefreshBreachSuccessPanel()
	local PetGUID =PetUI.petGuid
	local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,PetGUID)
    local moban =DB.GetOncePetByKey1(id)
	local star = LD.GetPetIntCustomAttr("PetStarLevel",PetGUID,pet_container_type.pet_container_panel)
	local CenterGroup = _gt.GetUI("CenterGroup")
	for i =1 ,2 do
		local PetIconBg = GUI.GetChild(CenterGroup,"PetIconBg"..i)
		GUI.ImageSetImageID(PetIconBg,PetGradeIcon[moban.Type])
		local PetIcon = GUI.GetChild(CenterGroup,"PetIcon"..i)
		GUI.ImageSetImageID(PetIcon,tostring(moban.Head))
		if i == 1 then
			UILayout.SetSmallStarsWithout(star-1, 6, PetIconBg)
		elseif i == 2 then
			UILayout.SetSmallStarsWithout(star, 6, PetIconBg)
		end
	end
	local NewSkill = GUI.GetChild(CenterGroup,"NewSkill")
	local mark = 0
	for i =1,#PetUI.PetStarSkillLevel do
		if PetUI.PetStarSkillLevel[i] == star then
			mark = i
		end
	end
	if mark ~= 0  then
		local dataKeyName=PetUI.CurPetStarSkill[mark]
		if dataKeyName then
			local skillDB=DB.GetOnceSkillByKey2(dataKeyName)
			GUI.SetVisible(NewSkill,true)
			GUI.ItemCtrlSetElementValue(NewSkill,eItemIconElement.Icon,tostring(skillDB.Icon))
			GUI.ItemCtrlSetElementRect(NewSkill,eItemIconElement.Icon,0,-1,66,67)
			GUI.ItemCtrlSetElementValue(NewSkill,eItemIconElement.Border,UIDefine.ItemIconBg[skillDB.SkillQuality])
			local newicon = GUI.ImageCreate(NewSkill,"newicon","1801207080",-30,-20)
		end
	else 
	GUI.SetVisible(NewSkill,false)
	end
	for i= 1 ,#BreachSuccessText do
		local NewValue = GUI.GetChild(CenterGroup,BreachSuccessText[i][1].."_New")
		local OldValue = GUI.GetChild(CenterGroup,BreachSuccessText[i][1].."_Old")
		local attrTb = BreachSuccessText[i]
		local attrText = 0
--战力特殊处理
		if i == 7   then
			attrText=tostring(LD.GetPetAttr(RoleAttr.RoleAttrFightValue,PetGUID)) 
		else
			attrText=LD.GetPetIntCustomAttr(attrTb[5],PetGUID)
		end
		GUI.StaticSetText(OldValue,OldAttrValue[i])
		GUI.StaticSetText(NewValue,attrText)
	end
	
	
	local BreachSkillScroll = _gt.GetUI("BreachSkillScroll")
	GUI.LoopScrollRectSetTotalCount(BreachSkillScroll, 8) 
	GUI.LoopScrollRectRefreshCells(BreachSkillScroll)
end

-- 升星成功背景被点击
function PetUI.OnBreachBgClick()

    local BreachSuccessPanel = GUI.Get("PetUI/panelBg/pageRefinePanel/BreachSuccessPanel")
    if BreachSuccessPanel ~= nil then
        GUI.SetVisible(BreachSuccessPanel, false)
    end

end
----------------------------------------------------------------------突破结束----------------------------------------------------------------------------

----------------------------------------------------------------------炼化结束----------------------------------------------------------------------------------------

---------------------------------------------------------------------合成开始-------------------------------------------------------------------------------------
function PetUI.InitData2()
    return {
        luckyItem = {},
	imageIndex = 1,
        luckyItemIndex = 1,
        luckyItemIndexGuid = int64.new(0),
        luckyItemData = {},
	luckyGuids1 = {},
        luckyGuids2 = {},
        luckyTable = {},
        itemList = {},
        BindList = {},
        numList = {}
    }
end

local synthesisData = PetUI.InitData2()



local PetGuid1 = nil
local PetGuid2 = nil

local flag = false
function PetUI.OnSynthesisToggle()
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel[LabelList[4][1]]
	if Level < OpenLevel then
		CL.SendNotify(NOTIFY.ShowBBMsg,OpenLevel.."级开启宠物"..LabelList[4][1].."功能。")
		UILayout.OnTabClick(PetUI.tabIndex, LabelList)	
		return
	else
		PetUI.tabIndex = 4
      		PetUI.RefreshAll()
      		PetUI.RefeshMiddle()
		PetUI.SetPetGuid(nil)
		CL.SendNotify(NOTIFY.SubmitForm, "FormPetMix", "GetData")
		PetUI.Refresh()
        	PetUI.RefreshBottomImageBg()
     		PetUI.CreateBottomImageBg()
		local SynthesisSubPage = _gt.GetUI("SynthesisSubPage")
		if SynthesisSubPage then
			PetUI.RefreshBottomImageBg()
			return
		end
		PetUI.CreateSynthesisSubPage()
	end
end

function PetUI.CreateSynthesisSubPage()
    local panelBg = GUI.Get("PetUI/panelBg")
    local SynthesisSubPage = GUI.GroupCreate(panelBg, "SynthesisSubPage", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg));
    _gt.BindName(SynthesisSubPage, "SynthesisSubPage")
    local majorImage = GUI.ImageCreate(SynthesisSubPage, "majorImage", "1800704070", -164, -238)
    local deputyImage = GUI.ImageCreate(SynthesisSubPage, "deputyImage", "1800704080", 504, -238)
    local middleImage = GUI.ImageCreate(SynthesisSubPage, "middleImage", "1800700160", 167, -152)
    local middleLeftImage = GUI.ImageCreate(SynthesisSubPage, "middleLeftImage", "1800700120", -14, -152)
    _gt.BindName(middleLeftImage, "middleLeftImage")
    local middleRightImage = GUI.ImageCreate(SynthesisSubPage, "middleRightImage", "1800700120", 353, -152)
    _gt.BindName(middleRightImage, "middleRightImage")
    local checkMiddleLeftImage = GUI.ImageCreate(middleLeftImage, "checkMiddleLeftImage", "1800700140", 0, 0)
    _gt.BindName(checkMiddleLeftImage, "checkMiddleLeftImage")
    middleLeftImage:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(middleLeftImage, true)
    GUI.RegisterUIEvent(middleLeftImage, UCE.PointerClick, "PetUI", "onCheckMiddleLeft")
    local checkMiddleRightImage = GUI.ImageCreate(middleRightImage, "checkMiddleRightImage", "1800700140", 0, 0)
    _gt.BindName(checkMiddleRightImage, "checkMiddleRightImage")
    GUI.SetVisible(checkMiddleRightImage, false)
    middleRightImage:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(middleRightImage, true)
    GUI.RegisterUIEvent(middleRightImage, UCE.PointerClick, "PetUI", "onCheckMiddleRight")
    local middleItemImage = GUI.ItemCtrlCreate(SynthesisSubPage, "middleItemImage", "1800400050", 170, -152)
    _gt.BindName(middleItemImage, "middleItemImage")
    middleItemImage:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(middleItemImage, true)
    GUI.RegisterUIEvent(middleItemImage, UCE.PointerClick, "PetUI", "onMiddleItemImageTipsBtn")
    local ItemName = GUI.CreateStatic(SynthesisSubPage, "ItemName", "幸运符", 170, -97, 300, 200)
    GUI.StaticSetAlignment(ItemName, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(ItemName, UIDefine.FontSizeM)
    GUI.SetScale(ItemName, UIDefine.FontSizeM2FontSizeXL)
    GUI.SetColor(ItemName, UIDefine.BrownColor)
    local SynthesisBtn = GUI.ButtonCreate(SynthesisSubPage, "SynthesisBtn", "1800402110", 169, -58, Transition.ColorTint, "合成", 103, 42, false)
    GUI.ButtonSetTextColor(SynthesisBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(SynthesisBtn, UIDefine.FontSizeM)
    _gt.BindName(SynthesisBtn, "SynthesisBtn")
    GUI.RegisterUIEvent(SynthesisBtn, UCE.PointerClick, "PetUI", "onSynthesisClick");
    local tpsBtn1 = GUI.ButtonCreate(SynthesisSubPage, "tpsBtn1", "1800702030", 170, -243, Transition.ColorTint)
    GUI.RegisterUIEvent(tpsBtn1, UCE.PointerClick, "PetUI", "onTipBtnClick1");
    local leftImage = GUI.ImageCreate(SynthesisSubPage, "leftImage", "1800400010", -15.2, 102, false, 343.65, 182)
    local rightImage = GUI.ImageCreate(SynthesisSubPage, "rightImage", "1800400010", 356.67, 102, false, 343.65, 182)
    local bottomImage = GUI.ImageCreate(SynthesisSubPage, "bottomImage", "1800400010", 172.5, 250.2, false, 715, 100.3)
    local tpsBtn2 = GUI.ButtonCreate(SynthesisSubPage, "tpsBtn2", "1800702030", -150, -14, Transition.ColorTint)
	GUI.RegisterUIEvent(tpsBtn2, UCE.PointerClick, "PetUI", "ZhuChongTips")
    local tpsBtn3 = GUI.ButtonCreate(SynthesisSubPage, "tpsBtn3", "1800702030", 495, -14, Transition.ColorTint)
	GUI.RegisterUIEvent(tpsBtn3, UCE.PointerClick, "PetUI", "FuChongTips")
    local CreateItemLeftPool = GUI.LoopScrollRectCreate(
            leftImage,
            "CreateItemLeftPool",
            0,
            0,
            343,
            160.28,
            "PetUI",
            "CreateItemLeftPool",
            "PetUI",
            "RefreshItemLeftScroll",
            0,
            false,
            Vector2.New(80, 80),
            4,
            UIAroundPivot.Center,
            UIAnchor.Center
    )
    local CreateItemRightPool = GUI.LoopScrollRectCreate(
            rightImage,
            "CreateItemRightPool",
            0,
            0,
            343,
            160.28,
            "PetUI",
            "CreateItemRightPool",
            "PetUI",
            "RefreshItemRightScroll",
            0,
            false,
            Vector2.New(80, 80),
            4,
            UIAroundPivot.Center,
            UIAnchor.Center
    )
    _gt.BindName(CreateItemLeftPool, "CreateItemLeftPool")
    _gt.BindName(CreateItemRightPool, "CreateItemRightPool")
    local a = -301
    for i = 1, 8 do
        local bottomImageBg = GUI.ItemCtrlCreate(bottomImage, "bottomImageBg" .. i, "1800400050", a, 3)
        a = a + 86
    end
    local PreviewBtn = GUI.ButtonCreate(SynthesisSubPage, "PreviewBtn", "1800702060", 169, -11, Transition.ColorTint)
    GUI.RegisterUIEvent(PreviewBtn, UCE.PointerClick, "PetUI", "OnPreviewBtnClick")
end

function PetUI.ZhuChongTips()
	if PetGuid1 ~= nil and PetGuid1 ~= ""  then
		GUI.OpenWnd("PetInfoUI","2,"..tostring(PetGuid1))
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,"请先选择放置一只宠物")
		return
	end
end

function PetUI.FuChongTips()
	if PetGuid2 ~= nil and PetGuid2 ~= "" then
		GUI.OpenWnd("PetInfoUI","2,"..tostring(PetGuid2))
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,"请先选择放置一只宠物")
		return
	end
end

function PetUI.OnPreviewBtnClick()
	if not PetGuid1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请添加主宠后再进行预览")
		return
	end
	if not PetGuid2 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请添加副宠后再进行预览")
		return
	end	
	
	GUI.OpenWnd("PetPreviewUI",tostring(PetGuid1)..","..tostring(PetGuid2))

end

function PetUI.onCheckMiddleLeft()
    local checkMiddleLeftImage = _gt.GetUI("checkMiddleLeftImage")
    local checkMiddleRightImage = _gt.GetUI("checkMiddleRightImage")
    GUI.SetVisible(checkMiddleLeftImage, true)
    GUI.SetVisible(checkMiddleRightImage, false)
    visible = 1
end

function PetUI.onCheckMiddleRight()
    local checkMiddleLeftImage = _gt.GetUI("checkMiddleLeftImage")
    local checkMiddleRightImage = _gt.GetUI("checkMiddleRightImage")
    GUI.SetVisible(checkMiddleLeftImage, false)
    GUI.SetVisible(checkMiddleRightImage, true)
    visible = 2
end


function PetUI.CreateBottomImageBg()
    local luckItem = synthesisData.luckyItemData
    local panelBg = GUI.Get("PetUI/panelBg")
    local SynthesisSubPage = GUI.GetChild(panelBg, "SynthesisSubPage", false)
    local bottomImage = GUI.GetChild(SynthesisSubPage, "bottomImage", false)

    synthesisData.itemList = {}
    synthesisData.BindList = {}
    synthesisData.numList = {}
    if PetUI.PetMixServerData.LuckyJuJu then
        local AllNum = #PetUI.PetMixServerData.LuckyJuJu
        for k, v in ipairs(PetUI.PetMixServerData.LuckyJuJu) do
            synthesisData.itemList[k * 2 - 1] = v
            synthesisData.itemList[k * 2] = v
            synthesisData.BindList[k * 2 - 1] = false
            synthesisData.BindList[k * 2] = true
            synthesisData.numList[k * 2 - 1] = 0
            synthesisData.numList[k * 2] = 0
            local guids = LD.GetItemGuidsById(DB.GetOnceItemByKey2(v[1]).Id)
            if guids then
                for i = 0, guids.Count - 1 do
                    if LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, guids[i]) == "1" then
                        synthesisData.numList[k * 2] = synthesisData.numList[k * 2] + LD.GetItemAttrByGuid(ItemAttr_Native.Amount, guids[i])
                    else
                        synthesisData.numList[k * 2 - 1] = synthesisData.numList[k * 2 - 1] + LD.GetItemAttrByGuid(ItemAttr_Native.Amount, guids[i])
                    end
                end
            end
            if synthesisData.numList[k * 2 - 1] == 0 and synthesisData.numList[k * 2] == 0 then
                synthesisData.itemList[2 * AllNum + k] = v
                synthesisData.BindList[2 * AllNum + k] = false
                synthesisData.numList[2 * AllNum + k] = -1
            end
        end
		 -- local inspect = require("inspect")
-- CDebug.LogError(inspect(synthesisData.numList))

		 -- local inspect = require("inspect")
-- CDebug.LogError(inspect(synthesisData.itemList))


        local index = 0
        for i = 1, 3 * #(PetUI.PetMixServerData.LuckyJuJu) do
            if synthesisData.numList[i] then
                if synthesisData.numList[i] ~= 0 then
					if synthesisData.itemList[i][2] == 1 or synthesisData.numList[i] ~= -1 then
					-- CDebug.LogError(synthesisData.itemList[i][1])
					-- CDebug.LogError(synthesisData.itemList[i][2])
					-- CDebug.LogError(synthesisData.numList[i])
						index = index + 1
						local bottomImageBg = GUI.GetChild(bottomImage, "bottomImageBg" .. index, false)
						_gt.BindName(bottomImageBg, "bottomImageBg" .. index)
						-- CDebug.LogError(synthesisData.itemList[i][1])
						ItemIcon.BindItemKeyName(bottomImageBg, synthesisData.itemList[i][1])
						if synthesisData.numList[i] == -1 then
								GUI.ItemCtrlSetIconGray(bottomImageBg, true)

						else
							
							local bindImage = GUI.GetChild(bottomImageBg, "bindImage")
							if not bindImage then
								bindImage = GUI.ImageCreate(bottomImageBg, "bindImage", "1800707120", -12.8, -13.25)
								_gt.BindName(bindImage, "bindImage" .. i)
							end
							GUI.SetVisible(bindImage, false)
							if synthesisData.BindList[i] == true then
								if synthesisData.numList[i] > 0 then
									GUI.ItemCtrlSetElementValue(bottomImageBg, eItemIconElement.RightBottomNum, tostring(synthesisData.numList[i]))
									GUI.SetVisible(bindImage, true)
								else
									ItemIcon.SetEmpty(bottomImageBg)
									GUI.SetVisible(bindImage, false)
								end
							elseif synthesisData.BindList[i] == false then
								if synthesisData.numList[i] > 0 then
									GUI.ItemCtrlSetElementValue(bottomImageBg, eItemIconElement.RightBottomNum, tostring(synthesisData.numList[i]))
								else
									ItemIcon.SetEmpty(bottomImageBg)
								end
								GUI.SetVisible(bindImage, false)
							end
						end
						GUI.ItemCtrlSetElementValue(GUI.GetChild(bottomImage, "bottomImageBg" .. index, false), eItemIconElement.Border, "1800400050")
						GUI.RegisterUIEvent(bottomImageBg, UCE.PointerClick, "PetUI", "onLuckItem")
					end
                end
            end
        end
    end
end
function PetUI.RefreshBottomImageBg()
    local panelBg = GUI.Get("PetUI/panelBg")
    local SynthesisSubPage = GUI.GetChild(panelBg, "SynthesisSubPage", false)
    local bottomImage = GUI.GetChild(SynthesisSubPage, "bottomImage", false)
    for i = 1, 8 do
        local bottomImageBg = GUI.GetChild(bottomImage, "bottomImageBg" .. i, false)
        ItemIcon.SetEmpty(bottomImageBg)
        local bindImage = _gt.GetUI("bindImage" .. i)
        if bindImage then
            GUI.SetVisible(bindImage, false)
        end
        GUI.ItemCtrlSetElementValue(bottomImageBg, eItemIconElement.Border, "1800400050")
    end
    
end

function PetUI.onLuckItem(guid)
	local panelBg = GUI.Get("PetUI/panelBg")
	local SynthesisSubPage = GUI.GetChild(panelBg, "SynthesisSubPage", false)
	local index = 0
	for i = 1, 3 * #(PetUI.PetMixServerData.LuckyJuJu) do
		if synthesisData.numList[i] then
			if synthesisData.numList[i] ~= 0 then
				if synthesisData.itemList[i][2] == 1 or synthesisData.numList[i] ~= -1 then 
					index = index + 1
					local bottomImageBg = _gt.GetUI("bottomImageBg" .. index)
					if guid == GUI.GetGuid(bottomImageBg) then
						synthesisData.luckyItemIndex = index
						synthesisData.imageIndex = i
						
						if LD.GetItemCountById(DB.GetOnceItemByKey2(synthesisData.itemList[i][1]).Id) > 0 then
							
							local luckTips = Tips.CreateByItemKeyName(synthesisData.itemList[i][1], SynthesisSubPage, "luckTips", 0, 0, 62)
							local ItemLevel = GUI.GetChild(luckTips, "ItemLevel", false)
							GUI.SetVisible(ItemLevel, false)
							local itemLimit = GUI.GetChild(luckTips, "itemLimit", false)
							GUI.SetVisible(itemLimit, false)
							local CutLine = GUI.GetChild(luckTips, "CutLine", false)
							GUI.SetPositionY(CutLine, 120)
							local InfoScr = GUI.GetChild(luckTips, "InfoScr", false)
							GUI.SetPositionY(InfoScr, 138)
							local itemShowLevel = GUI.GetChild(luckTips, "itemShowLevel", false)
							GUI.StaticSetText(itemShowLevel, "等级：1")
							local luckTipsBtn = GUI.ButtonCreate(luckTips, "luckTipsBtn", "1800602020", 0, -35.5, Transition.ColorTint)
							_gt.BindName(luckTipsBtn, "luckTipsBtn")
							-- GUI.SetVisible(luckTipsBtn, true)
							GUI.ButtonSetText(luckTipsBtn, "使用")
							GUI.ButtonSetTextColor(luckTipsBtn, UIDefine.BrownColor)
							GUI.ButtonSetTextFontSize(luckTipsBtn, UIDefine.FontSizeM)
							UILayout.SetAnchorAndPivot(luckTipsBtn, UIAnchor.Bottom, UIAroundPivot.Center)
							GUI.RegisterUIEvent(luckTipsBtn, UCE.PointerClick, "PetUI", "onLuckItemTipsBtn")
						else
							-- CDebug.LogError(synthesisData.itemList[i][1])
							local luckTips = Tips.CreateByItemKeyName(synthesisData.itemList[i][1], SynthesisSubPage, "luckTips", 0, 0, 50)
							local ItemLevel = GUI.GetChild(luckTips, "ItemLevel", false)
							GUI.SetVisible(ItemLevel, false)
							local itemLimit = GUI.GetChild(luckTips, "itemLimit", false)
							GUI.SetVisible(itemLimit, false)
							local CutLine = GUI.GetChild(luckTips, "CutLine", false)
							GUI.SetPositionY(CutLine, 120)
							local InfoScr = GUI.GetChild(luckTips, "InfoScr", false)
							GUI.SetPositionY(InfoScr, 138)
							local itemShowLevel = GUI.GetChild(luckTips, "itemShowLevel", false)
							GUI.StaticSetText(itemShowLevel, "等级：1")
							GUI.SetData(luckTips, "ItemId", tostring(DB.GetOnceItemByKey2(synthesisData.itemList[i][1]).Id))
							_gt.BindName(luckTips,"luckTips")
							-- local cutLine = GUI.GetChild(itemtips,"CutLine")
							-- GUI.SetPositionX(cutLine,-200)
							local wayBtn = GUI.ButtonCreate(luckTips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
							UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
							GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
							GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
							GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"PetUI","OnClickluckItemWayBtn")
							GUI.AddWhiteName(luckTips, GUI.GetGuid(wayBtn))
						end
					end
				end
			end
		end
	end
end

function PetUI.OnClickluckItemWayBtn()
	local tips = _gt.GetUI("luckTips")
	if tips then
        Tips.ShowItemGetWay(tips)
    end
end


function PetUI.onLuckItemTipsBtn()
    local middleItemImage = _gt.GetUI("middleItemImage")
    GUI.RegisterUIEvent(middleItemImage, UCE.PointerClick, "PetUI", "onMiddleItemImageTipsBtn")
    for i = 1, 8 do
        local bottomImageBg1 = _gt.GetUI("bottomImageBg" .. i)
        GUI.UnRegisterUIEvent(bottomImageBg1, UCE.PointerClick, "PetUI", "onLuckItem")
    end
    local bottomImageBg2 = _gt.GetUI("bottomImageBg" .. (synthesisData.luckyItemIndex))
    local num = tonumber(GUI.ItemCtrlGetElementValue(bottomImageBg2, eItemIconElement.RightBottomNum)) or 0
    if num > 1 then
        num = num - 1
        ItemIcon.BindItemKeyName(middleItemImage, synthesisData.itemList[synthesisData.imageIndex][1])
        GUI.ItemCtrlSetElementValue(middleItemImage, eItemIconElement.Border, "1800400050")
        GUI.ItemCtrlSetElementValue(bottomImageBg2, eItemIconElement.Border, "1800400050")
        GUI.ItemCtrlSetElementValue(bottomImageBg2, eItemIconElement.RightBottomNum, tostring(num))
    else
    ItemIcon.BindItemKeyName(middleItemImage, synthesisData.itemList[synthesisData.imageIndex][1])
    GUI.ItemCtrlSetElementValue(middleItemImage, eItemIconElement.Border, "1800400050")
    -- ItemIcon.SetEmpty(bottomImageBg2)
	GUI.ItemCtrlSetIconGray(bottomImageBg2,true)
    GUI.ItemCtrlSetElementValue(bottomImageBg2, eItemIconElement.Border, "1800400050")
	GUI.ItemCtrlSetElementValue(bottomImageBg2, eItemIconElement.RightBottomNum, nil)
    end
    luckItemKeyName = synthesisData.itemList[synthesisData.imageIndex][1]

    if synthesisData.BindList[synthesisData.imageIndex] == true then

        flag = true
            else
        flag = false
          
    
    end
end

function PetUI.onMiddleItemImageTipsBtn(guid)
    local panelBg = GUI.Get("PetUI/panelBg")
    local SynthesisSubPage = GUI.GetChild(panelBg, "SynthesisSubPage", false)
    local middleItemImage = _gt.GetUI("middleItemImage")
    if guid == GUI.GetGuid(middleItemImage) then
		if LD.GetItemCountById(DB.GetOnceItemByKey2(synthesisData.itemList[synthesisData.imageIndex][1]).Id) > 0 then
			local luckTips = Tips.CreateByItemKeyName(synthesisData.itemList[synthesisData.imageIndex][1], SynthesisSubPage, "luckTips2", 0, 0, 62)
			local ItemLevel = GUI.GetChild(luckTips, "ItemLevel", false)
			GUI.SetVisible(ItemLevel, false)
			local itemLimit = GUI.GetChild(luckTips, "itemLimit", false)
			GUI.SetVisible(itemLimit, false)
			local CutLine = GUI.GetChild(luckTips, "CutLine", false)
			GUI.SetPositionY(CutLine, 120)
			local InfoScr = GUI.GetChild(luckTips, "InfoScr", false)
			GUI.SetPositionY(InfoScr, 138)
			local itemShowLevel = GUI.GetChild(luckTips, "itemShowLevel", false)
			GUI.StaticSetText(itemShowLevel, "等级：1")
			local luckTipsBtn = GUI.ButtonCreate(luckTips, "luckTipsBtn", "1800602020", 0, -35.5, Transition.ColorTint)
			GUI.ButtonSetText(luckTipsBtn, "卸下")
			GUI.ButtonSetTextColor(luckTipsBtn, UIDefine.BrownColor)
			GUI.ButtonSetTextFontSize(luckTipsBtn, UIDefine.FontSizeM)
			UILayout.SetAnchorAndPivot(luckTipsBtn, UIAnchor.Bottom, UIAroundPivot.Center)
			GUI.RegisterUIEvent(luckTipsBtn, UCE.PointerClick, "PetUI", "onLuckItemTipsBtn2")
		else
			local luckTips = Tips.CreateByItemKeyName(synthesisData.itemList[synthesisData.imageIndex][1], SynthesisSubPage, "luckTips2", 0, 0, 12)
			local ItemLevel = GUI.GetChild(luckTips, "ItemLevel", false)
			GUI.SetVisible(ItemLevel, false)
			local itemLimit = GUI.GetChild(luckTips, "itemLimit", false)
			GUI.SetVisible(itemLimit, false)
			local CutLine = GUI.GetChild(luckTips, "CutLine", false)
			GUI.SetPositionY(CutLine, 120)
			local InfoScr = GUI.GetChild(luckTips, "InfoScr", false)
			GUI.SetPositionY(InfoScr, 138)
			local itemShowLevel = GUI.GetChild(luckTips, "itemShowLevel", false)
			GUI.StaticSetText(itemShowLevel, "等级：1")
        end
    end
end

function PetUI.onLuckItemTipsBtn2()
    local middleItemImage = _gt.GetUI("middleItemImage")
    GUI.UnRegisterUIEvent(middleItemImage, UCE.PointerClick, "PetUI", "onMiddleItemImageTipsBtn")
    for i = 1, 8 do
        local bottomImageBg1 = _gt.GetUI("bottomImageBg" .. i)
        GUI.RegisterUIEvent(bottomImageBg1, UCE.PointerClick, "PetUI", "onLuckItem")
    end
    local bottomImageBg2 = _gt.GetUI("bottomImageBg" .. (synthesisData.luckyItemIndex))
    local num = tonumber(GUI.ItemCtrlGetElementValue(bottomImageBg2, eItemIconElement.RightBottomNum)) or 0
    if num > 0 then
        num = num + 1
        ItemIcon.SetEmpty(middleItemImage)
        GUI.ItemCtrlSetElementValue(middleItemImage, eItemIconElement.Border, "1800400050")
        ItemIcon.BindItemKeyName(bottomImageBg2, synthesisData.itemList[synthesisData.imageIndex][1])
        GUI.ItemCtrlSetElementValue(bottomImageBg2, eItemIconElement.Border, "1800400050")
        GUI.ItemCtrlSetElementValue(bottomImageBg2, eItemIconElement.RightBottomNum, tostring(num))
    else
    ItemIcon.SetEmpty(middleItemImage)
    GUI.ItemCtrlSetElementValue(middleItemImage, eItemIconElement.Border, "1800400050")
        ItemIcon.BindItemKeyName(bottomImageBg2, synthesisData.itemList[synthesisData.imageIndex][1])
    GUI.ItemCtrlSetElementValue(bottomImageBg2, eItemIconElement.Border, "1800400050")
    end
    luckItemKeyName = -1
end

function PetUI.CreateItemLeftPool()
    local scroll = GUI.Get("PetUI/panelBg/SynthesisSubPage/leftImage/CreateItemLeftPool")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = GUI.ItemCtrlCreate(scroll, "SynthesisSkill" .. curCount, "1800400050", 80, 80)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "PetUI", "OnLeftSkillItemClick")
    return item
end

function PetUI.CreateItemRightPool()
    local scroll = GUI.Get("PetUI/panelBg/SynthesisSubPage/leftImage/CreateItemRightPool")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = GUI.ItemCtrlCreate(scroll, "SynthesisSkill" .. curCount, "1800400050", 80, 80)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "PetUI", "OnRightSkillItemClick")
    return item
end

function PetUI.RefreshItemLeftScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local item = GUI.GetByGuid(guid)
    if PetGuid1 == nil then
        ItemIcon.SetEmpty(item)
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800400050")
        return
    end
    local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid)
    if num <= index then
        ItemIcon.SetEmpty(item)
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800400050")
        return
    end
    local skills = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetGuid1)
    local data = skills[index]
    if modelVisible1 == 1 then
        ItemIcon.BindPetSkill(item, { SkillId = data.id, SkillData = data })
    else
        ItemIcon.SetEmpty(item)
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800400050")
    end
end

function PetUI.OnLeftSkillItemClick(guid)
    if PetGuid1 == nil then
        return
    end
    local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetGuid1)
    local skillItem = GUI.GetByGuid(guid)
    local skills = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetGuid1)
    local index = GUI.ItemCtrlGetIndex(skillItem)
    if index < num then
        if skills[index] then
			-- local skillDB = DB.GetOnceSkillByKey1(skills[index].id)
			-- CL.SendNotify(NOTIFY.SkillTipsReq, skills[index].id, uint64.new(PetGuid1))
			-- PetUI.SkillPerformance = skills[index].performance
            Tips.CreateSkillId(skills[index].id, _gt.GetUI("panelBg"), "tips", 0, 0, 0, 0,skills[index].performance)
        end
    end
end

function PetUI.RefreshItemRightScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local item = GUI.GetByGuid(guid)
    if PetGuid2 == nil then
        ItemIcon.SetEmpty(item)
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800400050")
        return
    end
    local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetGuid2)
    if num <= index then
        ItemIcon.SetEmpty(item)
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800400050")
        return
    end
    local skills = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetGuid2)
    local data = skills[index]
    if modelVisible2 == 1 then
        ItemIcon.BindPetSkill(item, { SkillId = data.id, SkillData = data })
    else
        ItemIcon.SetEmpty(item)
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800400050")
    end
end

function PetUI.OnRightSkillItemClick(guid)
    if PetGuid2 == nil then
        return
    end
    local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetGuid2)
    local skillItem = GUI.GetByGuid(guid)
    local skills = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetGuid2)
    local index = GUI.ItemCtrlGetIndex(skillItem)
    if index < num then
        if skills[index] then
			-- local skillDB = DB.GetOnceSkillByKey1(skills[index].id)
			-- CL.SendNotify(NOTIFY.SkillTipsReq, skills[index].id, uint64.new(PetGuid2))
			-- PetUI.SkillPerformance = skills[index].performance
            Tips.CreateSkillId(skills[index].id, _gt.GetUI("panelBg"), "tips", 0, 0, 0, 0,skills[index].performance)
        end
    end
end

function PetUI.onTipBtnClick1()
    local panelBg = GUI.Get("PetUI/panelBg")
    Tips.CreateHint(string.gsub(PetUI.PetMixServerData.Tips, "\\n", "\n"), panelBg, 166, -131, UILayout.Center, 479, 166)
end

function PetUI.RefreshSynthesis()
    local middleItemImage = _gt.GetUI("middleItemImage")
    GUI.UnRegisterUIEvent(middleItemImage, UCE.PointerClick, "PetUI", "onMiddleItemImageTipsBtn")
    local CreateItemLeftPool = _gt.GetUI("CreateItemLeftPool")
    local CreateItemRightPool = _gt.GetUI("CreateItemRightPool")
    GUI.LoopScrollRectSetTotalCount(CreateItemLeftPool, 8)
    GUI.LoopScrollRectRefreshCells(CreateItemLeftPool)
    GUI.LoopScrollRectSetTotalCount(CreateItemRightPool, 8)
    GUI.LoopScrollRectRefreshCells(CreateItemRightPool)
    PetUI.RefreshBottom()
    PetUI.CreateBottomImageBg()
    PetUI.CreateLeftBasePet()
    PetUI.CreateRightBasePet()
    PetUI.RefreshPetModel()
end

function PetUI.RefreshBottom()
    local luckyJuJu = PetUI.PetMixServerData.LuckyJuJu
    if luckyJuJu ~= nil then
        synthesisData.luckyItem = {}
        synthesisData.luckyItemData = {}
        for k, v in pairs(luckyJuJu) do
            local item = DB.GetOnceItemByKey2(v[1])
            local grade = item.Grade
            local id = item.Id
            local count = LD.GetItemCountById(id)
            local temp = {
                id = id,
                grade = grade,
                keyName = v,
                count = count
            }
            synthesisData.luckyItemData[k] = temp
            table.insert(synthesisData.luckyItem, k)
        end
    end
    PetUI.sortGT()
end

function PetUI.sortGT()
    table.sort(synthesisData.luckyItem, function(luckyId1, luckyId2)
        local grade1 = synthesisData.luckyItemData[luckyId1].grade
        local grade2 = synthesisData.luckyItemData[luckyId2].grade
        local id1 = synthesisData.luckyItemData[luckyId1].id
        local id2 = synthesisData.luckyItemData[luckyId2].id
        local n1 = synthesisData.luckyItemData[luckyId1].count
        local n2 = synthesisData.luckyItemData[luckyId2].count
        if (n1 > 0 and n2 > 0) or (n1 == 0 and n2 == 0) then
            if grade1 ~= grade2 then
                return grade1 > grade2
            else
                return id1 > id2
            end
        else
            return n1 > n2
        end
    end)
end

function PetUI.CreateLeftBasePet()
    local synthesisShadow = _gt.GetUI("synthesisShadow")
    if synthesisShadow then
        return
    end
    local middleLeftImage = _gt.GetUI("middleLeftImage")
    local synthesisPetModelGroup = GUI.GroupCreate(middleLeftImage, "synthesisPetModelGroup", 0, 0, GUI.GetWidth(middleLeftImage), GUI.GetHeight(middleLeftImage));
    _gt.BindName(synthesisPetModelGroup, "synthesisPetModelGroup")
    GUI.SetVisible(synthesisPetModelGroup, false)
    local synthesisShadow = GUI.ImageCreate(synthesisPetModelGroup, "synthesisShadow", "1800400240", 0, 72);
    _gt.BindName(synthesisShadow, "synthesisShadow")
    local synthesisModel = GUI.RawImageCreate(synthesisPetModelGroup, false, "synthesisModel", "", 0, -26, 50, false, 560, 560)
    _gt.BindName(synthesisModel, "synthesisModel")
    synthesisModel:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(synthesisModel, true)
    GUI.RegisterUIEvent(synthesisModel, UCE.PointerClick, "PetUI", "onSynthesisPetModelGroup")
    synthesisModel:RegisterEvent(UCE.Drag)
    GUI.AddToCamera(synthesisModel)
    GUI.RawImageSetCameraConfig(synthesisModel, "(1.65,1.4,2),(-0.04464257,0.9316535,-0.1226545,-0.3390941),True,5,0.01,1.95,1E-05");
    synthesisModel:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(synthesisModel, UCE.PointerClick, "PetUI", "OnModelClick")
    local synthesisPetModel = GUI.RawImageChildCreate(synthesisModel, true, "synthesisPetModel", "", 0, 0)
    _gt.BindName(synthesisPetModel, "synthesisPetModel")
    GUI.BindPrefabWithChild(synthesisModel, GUI.GetGuid(synthesisPetModel))
    GUI.RegisterUIEvent(synthesisPetModel, ULE.AnimationCallBack, "PetUI", "OnAnimationCallBack")
end

function PetUI.CreateRightBasePet()
    local synthesisShadow2 = _gt.GetUI("synthesisShadow2")
    if synthesisShadow2 then
        return
    end
    local middleRightImage = _gt.GetUI("middleRightImage")
    local synthesisPetModelGroup2 = GUI.GroupCreate(middleRightImage, "synthesisPetModelGroup2", 0, 0, GUI.GetWidth(middleRightImage), GUI.GetHeight(middleRightImage));
    _gt.BindName(synthesisPetModelGroup2, "synthesisPetModelGroup2")
    GUI.SetVisible(synthesisPetModelGroup2, false)
    local synthesisShadow2 = GUI.ImageCreate(synthesisPetModelGroup2, "synthesisShadow2", "1800400240", 0, 72);
    _gt.BindName(synthesisShadow2, "synthesisShadow2")
    local synthesisModel2 = GUI.RawImageCreate(synthesisPetModelGroup2, false, "synthesisModel2", "", 0, -26, 50, false, 560, 560)
    _gt.BindName(synthesisModel2, "synthesisModel2")
    synthesisModel2:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(synthesisModel2, true)
    GUI.RegisterUIEvent(synthesisModel2, UCE.PointerClick, "PetUI", "onSynthesisPetModelGroup2")
    synthesisModel2:RegisterEvent(UCE.Drag)
    GUI.AddToCamera(synthesisModel2)
    GUI.RawImageSetCameraConfig(synthesisModel2, "(1.65,1.4,2),(-0.04464257,0.9316535,-0.1226545,-0.3390941),True,5,0.01,1.95,1E-05");
    synthesisModel2:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(synthesisModel2, UCE.PointerClick, "PetUI", "OnModelClick")
    local synthesisPetModel2 = GUI.RawImageChildCreate(synthesisModel2, true, "synthesisPetModel2", "", 0, 0)
    _gt.BindName(synthesisPetModel2, "synthesisPetModel2")
    GUI.BindPrefabWithChild(synthesisModel2, GUI.GetGuid(synthesisPetModel2))
    GUI.RegisterUIEvent(synthesisPetModel2, ULE.AnimationCallBack, "PetUI", "OnAnimationCallBack")
end

function PetUI.onSynthesisPetModelGroup()
    local synthesisPetModelGroup = _gt.GetUI("synthesisPetModelGroup")
    GUI.SetVisible(synthesisPetModelGroup, false)
    modelVisible1 = 2
    local CreateItemLeftPool = _gt.GetUI("CreateItemLeftPool")
    GUI.LoopScrollRectRefreshCells(CreateItemLeftPool)
    local checkMiddleLeftImage = _gt.GetUI("checkMiddleLeftImage")
    local checkMiddleRightImage = _gt.GetUI("checkMiddleRightImage")
    GUI.SetVisible(checkMiddleLeftImage, true)
    GUI.SetVisible(checkMiddleRightImage, false)
    visible = 1
    PetGuid1 = nil
    local petScroll = _gt.GetUI("petScroll")
    local count = LogicDefine.PetMaxLimit
    GUI.LoopScrollRectSetTotalCount(petScroll, count)
    GUI.LoopScrollRectRefreshCells(petScroll)
end

function PetUI.onSynthesisPetModelGroup2()
    local synthesisPetModelGroup2 = _gt.GetUI("synthesisPetModelGroup2")
    GUI.SetVisible(synthesisPetModelGroup2, false)
    modelVisible2 = 2
    local CreateItemRightPool = _gt.GetUI("CreateItemRightPool")
    GUI.LoopScrollRectRefreshCells(CreateItemRightPool)
    local checkMiddleLeftImage = _gt.GetUI("checkMiddleLeftImage")
    local checkMiddleRightImage = _gt.GetUI("checkMiddleRightImage")
    GUI.SetVisible(checkMiddleLeftImage, false)
    GUI.SetVisible(checkMiddleRightImage, true)
    visible = 2
    PetGuid2 = nil
    local petScroll = _gt.GetUI("petScroll")
    local count = LogicDefine.PetMaxLimit
    GUI.LoopScrollRectSetTotalCount(petScroll, count)
    GUI.LoopScrollRectRefreshCells(petScroll)
end

function PetUI.RefreshBasePet()
    if tostring(PetUI.petGuid) ~= PetGuid2 then
		if tostring(PetUI.petGuid) == PetGuid1 or PetGuid1 == nil then
			local synthesisPetModel = _gt.GetUI("synthesisPetModel")
			ModelItem.Bind(synthesisPetModel, tonumber(PetUI.petDB.Model), LD.GetPetIntAttr(RoleAttr.RoleAttrColor1, PetUI.petGuid), 0, eRoleMovement.ATTSTAND_W1)
			if LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid) ~= "" then
				GUI.RefreshDyeSkinJson(synthesisPetModel, LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid), "")
			end
		end
    end
end

function PetUI.RefreshBasePet2()
    if tostring(PetUI.petGuid) ~= PetGuid1   then
		if tostring(PetUI.petGuid) == PetGuid2 or PetGuid2 == nil then
			local synthesisPetModel2 = _gt.GetUI("synthesisPetModel2")
			ModelItem.Bind(synthesisPetModel2, tonumber(PetUI.petDB.Model), LD.GetPetIntAttr(RoleAttr.RoleAttrColor1, PetGuid2 or PetUI.petGuid), 0, eRoleMovement.ATTSTAND_W1)
			if LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid) ~= "" then
				GUI.RefreshDyeSkinJson(synthesisPetModel2, LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid), "")
			end
		end
    end
end

function PetUI.onSynthesisClick()
	if not PetGuid1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请添加主宠后再进行合成")
		return
	end
	if not PetGuid2 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"请添加副宠后再进行合成")
		return
	end
	local star =LD.GetPetIntCustomAttr("PetStarLevel",PetGuid2,pet_container_type.pet_container_panel)
	if star > 1 then
		local name = LD.GetPetName(PetGuid2)
		GlobalUtils.ShowBoxMsg2Btn("提示","您的"..name.."已经突破至"..star.."星，合成后会直接消失，是否合成？","PetUI","确定","SendPetMixNotify","取消")
	else
		PetUI.SendPetMixNotify()
	end
end

function PetUI.SendPetMixNotify()
    if flag == false then
        CL.SendNotify(NOTIFY.SubmitForm, "FormPetMix", "StartMix", PetGuid1, PetGuid2, luckItemKeyName, 1)
		PetUI.PetListChange	= 1
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormPetMix", "StartMix", PetGuid1, PetGuid2, luckItemKeyName, 2)
		PetUI.PetListChange	= 1
    end
end

function PetUI.RefeshMiddle()
    local middleItemImage = _gt.GetUI("middleItemImage")
    ItemIcon.SetEmpty(middleItemImage)
    GUI.UnRegisterUIEvent(middleItemImage, UCE.PointerClick, "PetUI", "onMiddleItemImageTipsBtn")
    GUI.ItemCtrlSetElementValue(middleItemImage, eItemIconElement.Border, "1800400050")
end
function PetUI.RefreshAll()
	luckItemKeyName = -1
    PetUI.onSynthesisPetModelGroup2()
    PetUI.onSynthesisPetModelGroup()
    PetUI.RefeshMiddle()
    PetUI.RefreshBottomImageBg()
    PetUI.CreateBottomImageBg()
    local petScroll = _gt.GetUI("petScroll")
    
    local count = LogicDefine.PetMaxLimit
    GUI.LoopScrollRectSetTotalCount(petScroll, count)

    GUI.LoopScrollRectRefreshCells(petScroll)
end

function PetUI.RefreshOnSynthesis()
	GUI.OpenWnd("PetPreviewUI",tostring(PetGuid1))
	PetUI.RefreshAll()
end

function PetUI.serialize(obj)
    local text = ""
    local t = type(obj)
    if t == "number" then
        text = text .. obj
    elseif t == "boolean" then
        text = text .. tostring(obj)
    elseif t == "string" then
        text = text .. string.format("%q", obj)
    elseif t == "table" then
        text = text .. "{\n"
        for k, v in pairs(obj) do
            text = text .. "[" .. PetUI.serialize(k) .. "]=" .. PetUI.serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                text = text .. "[" .. PetUI.serialize(k) .. "]=" .. PetUI.serialize(v) .. ",\n"
            end
        end

        text = text .. "}"

    elseif t == "nil" then
        return nil
    end

    return text
end
---------------------------------------------------------------------合成结束-------------------------------------------------------------------------------------


----------------------------------------------------------------------阵容----------------------------------------------------------------------------------------------
local lineuptable = {}
local LineUpPetGuid = nil
function PetUI.CreatePetLineUpPage()
	local pagePetLineUpPanel = GUI.Get(pageNames[5][2])
	if pagePetLineUpPanel then
		GUI.SetVisible(pagePetLineUpPanel,true)
		return
	end
	local pagePetLineUpPanel = GUI.ImageCreate( GUI.Get("PetUI/panelBg"), "pagePetLineUpPanel", "1800400200", 350, 9, false, 350, 570)
	SetAnchorAndPivot(PetLineUpPanel, UIAnchor.Center, UIAroundPivot.Center)
    -- 阵容背景图
    local PetLineUpPanelBg = GUI.ImageCreate(pagePetLineUpPanel, "PetLineUpPanelBg", "1800400250", 0, -75)
    SetAnchorAndPivot(PetLineUpPanelBg, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(PetLineUpPanelBg,"PetLineUpPanelBg")
	--下方Tips
	local PetLineUpTipsBg = GUI.ImageCreate(pagePetLineUpPanel, "PetLineUpTipsBg", "1800601320", 0, -5,false,330,120)
	SetAnchorAndPivot(PetLineUpTipsBg, UIAnchor.Bottom, UIAroundPivot.Bottom)
	local PetLineUpTipsText = GUI.CreateStatic(PetLineUpTipsBg,"PetLineUpTipsText","<color=#ac7529ff>随着角色等级的提升，宠物最多能出战5个。侍宠出战数量与侍从出战数量一致。</color><color=#FF0000>仅当侍从出战时，其相应的侍宠才会出战。每个侍宠都会分掉主宠的部分经验。</color>",0,0,300,120, "system",true)
	-- GUI.SetColor(PetLineUpTipsText, UIDefine.White2Color);
	GUI.StaticSetFontSize(PetLineUpTipsText, 18);
	GUI.StaticSetAlignment(PetLineUpTipsText, TextAnchor.MiddleLeft);
	
	pagePetLineUpPanel:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(pagePetLineUpPanel, true)
    GUI.RegisterUIEvent(pagePetLineUpPanel, UCE.PointerClick, "PetUI", "OnClickPetLineUpPanelBg")
	
	local itemData = {{0, -110}, {-115, -10}, {115, -10}, {-60, 110}, {60, 110}}
	local itemInfo = {"主宠","侍宠1","侍宠2","侍宠3","侍宠4"}
	for i =0 , 4 do
		local itemdata = itemData[i+1]
		local item = GUI.ItemCtrlCreate(PetLineUpPanelBg,"PetLineUpItem"..i,"1800400330",itemdata[1],itemdata[2],0,0,true)
		SetAnchorAndPivot(item, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetData(item, "LineUpiIndex", i)
		GUI.RegisterUIEvent(item, UCE.PointerClick, "PetUI", "OnPetLineUpItemClick")
	--选中框
		local SelectedImg = GUI.ImageCreate(item,"LineUpSelected"..i,"1800600160",0,0,false,78,78)
		SetAnchorAndPivot(SelectedImg, UIAnchor.Center, UIAroundPivot.Center)
		GUI.SetVisible(SelectedImg,false)
	--关闭（下阵按钮）	
		local LineDownBtn = GUI.ButtonCreate(item, "LineDownBtn"..i, "1800702100", 8, -6, Transition.ColorTint, "")
		SetAnchorAndPivot(LineDownBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
		GUI.RegisterUIEvent(LineDownBtn, UCE.PointerClick, "PetUI", "OnLineDownBtnClick")
		GUI.SetVisible(LineDownBtn,false)
		
	--主副宠标志
		local imgId = "1801207110"
		if i == 0 then
            imgId = "1801207100"
        end
		local LeftTopSp = GUI.ImageCreate(item,"LeftTopSp"..i,imgId,-10,-10,false,30,30)
		SetAnchorAndPivot(LeftTopSp, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
		-- GUI.ItemCtrlSetElementValue(item,eItemIconElement.LeftTopSp,imgId)
		-- GUI.ItemCtrlGetElement(item,eItemIconElement.LeftTopSp)
	--主服宠文本
		local text = GUI.CreateStatic(PetLineUpPanelBg,"itemName"..i,itemInfo[i+1],itemdata[1],itemdata[2]+55,130,50)
		SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(text, 22)
		GUI.SetColor(text,colorDark)
		GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
		
		
	--需求等级文本
		if i ~=0 then
			local UnLockLevel = tostring(UIDefine.UnlockLevel[i])
			local UnLockLevelText = GUI.CreateStatic(item,"UnLockLevelText"..i,UnLockLevel.."级",0,8,130,50)
			SetAnchorAndPivot(UnLockLevelText, UIAnchor.Bottom, UIAroundPivot.Bottom)
			GUI.StaticSetFontSize(UnLockLevelText, 22)
			GUI.SetColor(UnLockLevelText,colorWhite)
			GUI.StaticSetAlignment(UnLockLevelText, TextAnchor.MiddleCenter)
			
			
			GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"1800400070")
		end
	--加号（上阵）图片
		local LineUpImg = GUI.ImageCreate(item,"LineUpImg"..i,"1800707060",0,0,false,44,44)
		SetAnchorAndPivot(LineUpImg, UIAnchor.Center, UIAroundPivot.Center)
		-- GUI.SetVisible(LineUpImg,false)
		
	--交换图片
		local ExchangeImg = GUI.ImageCreate(item,"LineUpExchange"..i,"1800707340",0,-2,false,70,70)
		SetAnchorAndPivot(ExchangeImg, UIAnchor.Center, UIAroundPivot.Center)	
		-- GUI.SetVisible(ExchangeImg,false)
		
	--红点
		GUI.AddRedPoint(item, UIAnchor.TopLeft,5,5)
			
		if i == 4 then
		end
	end
	


end

--当点击阵容页背景时
function PetUI.OnClickPetLineUpPanelBg()
	ExchangTorF = 0
	PetUI.RefreshPetLineUp()
end

local LineUp_LastIndex = nil
local ExchangePetPos = {}

function PetUI.OnPetLineUpItemClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "LineUpiIndex"))
	local PetLineUpPanelBg = _gt.GetUI("PetLineUpPanelBg")
	local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem"..index)
	local LineUpImg = GUI.GetChild(item,"LineUpImg"..index)
	local petScroll = _gt.GetUI("petScroll")
	local LineDownBtn = GUI.GetChild(item,"LineDownBtn"..index)
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
--是不是第一次点击
	if ExchangTorF ==0 then
		ExchangTorF = 1
		--第一次点击选中时红点消失
		GUI.SetRedPointVisable(item,false)
	--是不是主宠
		if index ==0 then
			LineUp_LastIndex = index
			local SelectedImg = GUI.GetChild(item,"LineUpSelected"..index)
			--位置上有没有宠物
			if UIDefine.NowLineupList[0] == "-1" then
				--主宠不存在 只有选择框 没有下阵按钮
				GUI.SetVisible(SelectedImg,true)
				for i = 1 , 4 do
					local item =  GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem"..i)
					local LineUpImg = GUI.GetChild(item,"LineUpImg"..i)
					GUI.SetVisible(LineUpImg,false)
					if	UIDefine.NowLineupList[i] ~= "-1" then
						local ExchangeImg = GUI.GetChild(item,"LineUpExchange"..i)
						GUI.SetVisible(ExchangeImg,true)
					end
				end
				--左侧可上阵显示
				GUI.LoopScrollRectRefreshCells(petScroll)
			--主宠位置有宠物的时候,有下阵按钮和选择框
			else 
				LineUpPetGuid = UIDefine.NowLineupList[0]
				for i = 1 , #lineuptable do
					if i < 5 then
						local item =  GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem"..i)
						local ExchangeImg = GUI.GetChild(item,"LineUpExchange"..i)
						local LineUpImg = GUI.GetChild(item,"LineUpImg"..i)
						if UIDefine.UnlockLevel[i] <= Level  then
							GUI.SetVisible(LineUpImg,false)
							GUI.SetVisible(ExchangeImg,true)
						end
					end
				end
				GUI.SetVisible(SelectedImg,true)
				GUI.SetVisible(LineDownBtn,true)
				--左侧可上阵显示
				GUI.LoopScrollRectRefreshCells(petScroll)
			end
		else
			local SelectedImg = GUI.GetChild(item,"LineUpSelected"..index)
			local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem0")
			local LineUpImg = GUI.GetChild(item,"LineUpImg0")
			local ExchangeImg = GUI.GetChild(item,"LineUpExchange0")
			--如果主宠上没有宠物
			if UIDefine.NowLineupList[0] == "-1" then
				--筛选出存在宠物的位置
				if index <= #lineuptable  then
					LineUpPetGuid = UIDefine.NowLineupList[index]
					LineUp_LastIndex = index
					--被点击以后都可以出现选择框
					GUI.SetVisible(SelectedImg,true)
					--主宠位置出现交换，自身以外的存在宠物的位置可以交换，最后位置的上阵按钮消失

					GUI.SetVisible(LineUpImg,false)
					GUI.SetVisible(ExchangeImg,true)
					for i = 1 ,#lineuptable +1 do
						if i ~= index  then
							local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem"..i)
							if i ~= #lineuptable +1 then
								local ExchangeImg = GUI.GetChild(item,"LineUpExchange"..i)
								GUI.SetVisible(ExchangeImg,true)
							elseif i == #lineuptable +1 then
								local LineUpImg = GUI.GetChild(item,"LineUpImg"..i)
								GUI.SetVisible(LineUpImg,false)
							end
						end
					end
					--自身位置出现下阵按钮
					GUI.SetVisible(LineDownBtn,true)
					--左侧可上阵显示
					GUI.LoopScrollRectRefreshCells(petScroll)
				--筛选出可上阵的位置
				elseif   UIDefine.UnlockLevel[index]<=Level  and index == #lineuptable +1 then
					LineUp_LastIndex = index
					--被点击以后可以出现选择框
					GUI.SetVisible(SelectedImg,true)
					--主宠上阵标志消失 其余不变
					GUI.SetVisible(LineUpImg,false)
					--左侧可上阵显示
					GUI.LoopScrollRectRefreshCells(petScroll)
				elseif  UIDefine.UnlockLevel[index]<=Level  and  index ~= #lineuptable +1 then
					CL.SendNotify(NOTIFY.ShowBBMsg, "该位置目前无法出战")
					ExchangTorF = 0
				elseif UIDefine.UnlockLevel[index] > Level  then
					CL.SendNotify(NOTIFY.ShowBBMsg, "人物达到"..UIDefine.UnlockLevel[index].."级时开启")
					ExchangTorF = 0
				end
			--如果主宠上有宠物
			else
				--筛选出存在宠物的位置
				if index < #lineuptable  then
					LineUpPetGuid = UIDefine.NowLineupList[index]
					LineUp_LastIndex = index
					--被点击该位置以后出现选择框，下阵按钮 ，主宠出现交换按钮，其它存在宠物的位置出现交换按钮,最后位置的上阵按钮消失
					GUI.SetVisible(SelectedImg,true)
					GUI.SetVisible(LineDownBtn,true)
					
					for i =0 ,#lineuptable do
						if index ~= i  then
							local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem"..i)
							if i ~= #lineuptable then
								local ExchangeImg = GUI.GetChild(item,"LineUpExchange"..i)
								GUI.SetVisible(ExchangeImg,true)
							elseif i== #lineuptable then
								local LineUpImg = GUI.GetChild(item,"LineUpImg"..i)
								GUI.SetVisible(LineUpImg,false)
							end
						end
					end
					--左侧可上阵显示
					GUI.LoopScrollRectRefreshCells(petScroll)
				--筛选出可上阵的位置
				elseif index == #lineuptable and  UIDefine.UnlockLevel[index]<=Level then
					LineUp_LastIndex = index
					--该位置被点击以后出现选择框，主宠出现交换按钮
					GUI.SetVisible(SelectedImg,true)
					GUI.SetVisible(ExchangeImg,true)	
					--左侧可上阵显示
					GUI.LoopScrollRectRefreshCells(petScroll)
				elseif UIDefine.UnlockLevel[index]<=Level and index ~= #lineuptable then
					CL.SendNotify(NOTIFY.ShowBBMsg, "该位置目前无法出战")
					ExchangTorF = 0
				elseif UIDefine.UnlockLevel[index] > Level then
					CL.SendNotify(NOTIFY.ShowBBMsg, "人物达到"..UIDefine.UnlockLevel[index].."级时开启")
					ExchangTorF = 0				
				end	
			end
		end
--第二次点击时
	else
		if index ~= LineUp_LastIndex then
			local ExchangeImg = GUI.GetChild(item,"LineUpExchange"..index)
			if GUI.GetVisible(ExchangeImg)  then
				-- LineUpPetGuid = PetUI.NowLineupList[index]
				ExchangePetPos = {[1]= index , [2]= LineUp_LastIndex}
				PetUI.OnPetLineSwapBtnClick()
			end
		end
	end
end

-- 刷新宠物阵容
function PetUI.RefreshPetLineUp()
	ExchangTorF = 0
	lineuptable = {}
	local PetLineUpPanelBg = _gt.GetUI("PetLineUpPanelBg")
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	local petScroll = _gt.GetUI("petScroll")
	for i =0 ,4 do
		local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem"..i)
		local LineUpImg = GUI.GetChild(item,"LineUpImg"..i)
		local LineDownBtn = GUI.GetChild(item,"LineDownBtn"..i)
		local ExchangeImg = GUI.GetChild(item,"LineUpExchange"..i)
		local SelectedImg = GUI.GetChild(item,"LineUpSelected"..i)
		GUI.SetRedPointVisable(item,false)
		--判断是否等级不足
		if UIDefine.UnlockLevel[i] > Level then
			local UnLockLevelText = GUI.GetChild(item,"UnLockLevelText"..i)
			GUI.SetVisible(UnLockLevelText,true)
			GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,"1800400070")
			GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,"1800400330")
			GUI.SetVisible(LineDownBtn,false)
			GUI.SetVisible(LineUpImg,false)
			GUI.SetVisible(ExchangeImg,false)
			GUI.SetVisible(SelectedImg,false)
			--未开启不显示小红点
			GUI.SetRedPointVisable(item,false)
			-- GUI.UnRegisterUIEvent(item, UCE.PointerClick, "PetUI", "OnPetLineUpItemClick")
		else
		--判断已参战宠物列表
			local UnLockLevelText = nil
			if i ~= 0 then
				UnLockLevelText = GUI.GetChild(item,"UnLockLevelText"..i)
			end
			if UIDefine.NowLineupList[i] ~= "-1" then
				local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, uint64.new(UIDefine.NowLineupList[i]))  --tostring(PetUI.NowLineupList[i])
				local petDB =DB.GetOncePetByKey1(id)
				GUI.SetVisible(UnLockLevelText,false)
				GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,tostring(petDB.Head))
				GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Type])
				GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, 0, 70, 70)
				GUI.SetVisible(SelectedImg,false)
				GUI.SetVisible(LineDownBtn,false)
				GUI.SetVisible(LineUpImg,false)
				GUI.SetVisible(ExchangeImg,false)
				--已有宠物不显示小红点
				GUI.SetRedPointVisable(item,false)
			else
				GUI.SetVisible(UnLockLevelText,false)
				GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,nil)
				GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,"1800400330")
				GUI.SetVisible(SelectedImg,false)
				GUI.SetVisible(LineDownBtn,false)
				GUI.SetVisible(LineUpImg,false)
				GUI.SetVisible(ExchangeImg,false)
			end
		end
		--判断现在有几个参战宠物
		if UIDefine.NowLineupList[i] ~= "-1" then
			table.insert(lineuptable,i)
		end
	end
	local count = LD.GetPetCount()
	local sum = count - #lineuptable
	if #lineuptable == 0 then
		local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem0")
		local LineUpImg = GUI.GetChild(item,"LineUpImg0")
		GUI.SetVisible(LineUpImg,true)
		if sum > 0 then
			GUI.SetRedPointVisable(item,true)
		end
		if UIDefine.UnlockLevel[1] <= Level then
			local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem1")
			local LineUpImg = GUI.GetChild(item,"LineUpImg1")
			GUI.SetVisible(LineUpImg,true)
			--显示小红点
		if sum > 0 then
			GUI.SetRedPointVisable(item,true)
		end
		end
	else 
		if UIDefine.NowLineupList[0] == "-1" then
			local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem0")
			local LineUpImg = GUI.GetChild(item,"LineUpImg0")
			GUI.SetVisible(LineUpImg,true)
			if sum > 0 then
				GUI.SetRedPointVisable(item,true)
			end
			local num = #lineuptable +1
				if num < 5 then
					if UIDefine.UnlockLevel[num] <= Level then
						local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem"..num)
						local LineUpImg = GUI.GetChild(item,"LineUpImg"..num)
						GUI.SetVisible(LineUpImg,true)
						if sum > 0 then
							GUI.SetRedPointVisable(item,true)
						end
					end
				end
		else 
			local num = #lineuptable
			if num < 5 then
				if UIDefine.UnlockLevel[num] <= Level then
					local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem"..num)
					local LineUpImg = GUI.GetChild(item,"LineUpImg"..num)
					GUI.SetVisible(LineUpImg,true)
					if sum > 0 then
						GUI.SetRedPointVisable(item,true)
					end
				end
			end
		end
	end
	
		
	if PetUI.LineUpMask == 0 then
		for i =0 ,4 do
			local item = GUI.GetChild(PetLineUpPanelBg,"PetLineUpItem"..i)
			GUI.SetRedPointVisable(item,false)
		end
	end

	GUI.LoopScrollRectRefreshCells(petScroll)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------


function PetUI.OnModelClick()         --宠物模型刷新

	if PetUI.petGuid==nil then
		return;
	end

	local petModel = GUI.GetByGuid(_gt.petModel);
	math.randomseed(os.time())
	local index = math.random(2)
	local movements = { eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1 }

	ModelItem.Bind(petModel, tonumber(PetUI.petDB.Model),LD.GetPetIntAttr(RoleAttr.RoleAttrColor1,PetUI.petGuid ),0, movements[index])
	if LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid) ~= "" then
		GUI.RefreshDyeSkinJson(petModel, LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid), "")
	end

end

function PetUI.OnEduModelClick()         --养成页宠物模型刷新

	if PetUI.petGuid==nil then
		return;
	end

	local EduPetModel = GUI.GetByGuid(_gt.EduPetModel);
	math.randomseed(os.time())
	local index = math.random(2)
	local movements = { eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1 }

	ModelItem.Bind(EduPetModel, tonumber(PetUI.petDB.Model),LD.GetPetIntAttr(RoleAttr.RoleAttrColor1,PetUI.petGuid ),0, movements[index])

	if LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid) ~= "" then
		GUI.RefreshDyeSkinJson(EduPetModel, LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid), "")
	end
end

function PetUI.OnAnimationCallBack(guid, action)     --宠物模型点击反馈
	if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
		return
	end
	local petModel = GUI.GetByGuid(_gt.petModel);
	ModelItem.Bind(petModel, tonumber(PetUI.petDB.Model),LD.GetPetIntAttr(RoleAttr.RoleAttrColor1,PetUI.petGuid ),0,eRoleMovement.ATTSTAND_W1)

	if LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid) ~= "" then
		GUI.RefreshDyeSkinJson(petModel, LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid), "")
	end
end

function PetUI.OnEduAnimationCallBack(guid, action)     --养成页宠物模型点击反馈
	if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
		return
	end
	local EduPetModel = GUI.GetByGuid(_gt.EduPetModel);
	ModelItem.Bind(EduPetModel, tonumber(PetUI.petDB.Model),LD.GetPetIntAttr(RoleAttr.RoleAttrColor1,PetUI.petGuid ),0,eRoleMovement.ATTSTAND_W1)

	if LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid) ~= "" then
		GUI.RefreshDyeSkinJson(EduPetModel, LD.GetPetStrCustomAttr("Model_DynJson1",PetUI.petGuid), "")
	end
end

function PetUI.CreatePetItemPool()    --创建宠物格子
	local petScroll = GUI.GetByGuid(_gt.petScroll);
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(petScroll)
	local petItem = PetItem.Create(petScroll, "petItem"..curCount, 0, 0)
    local majorLogo = GUI.ImageCreate(petItem, "majorLogo" , "1800707310", -130, 16)
	local deputyLogo = GUI.ImageCreate(petItem, "deputyLogo" , "1800707320", -130, 16)
	GUI.AddRedPoint(petItem,UIAnchor.TopLeft,15,15)
	GUI.SetRedPointVisable(petItem,false)
    GUI.SetVisible(majorLogo, false)
	GUI.SetVisible(deputyLogo, false)
	GUI.RegisterUIEvent(petItem, UCE.PointerClick, "PetUI", "OnPetItemClick");
	return petItem;
end

function PetUI.RefreshPetScroll(parameter)   --刷新宠物格子
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local petItem = GUI.GetByGuid(guid)
    local majorLogo = GUI.GetChild(petItem, "majorLogo" )
    local deputyLogo = GUI.GetChild(petItem, "deputyLogo" )
	local LineUpPet = GUI.GetChild(petItem,"LineUpPet")
	local GetMorePet = GUI.GetChild(petItem,"GetMorePet")
	local GetMoreText = GUI.GetChild(petItem,"GetMoreText")
	local lockNum = PetUI.LevelUpPetBag_Table and #PetUI.LevelUpPetBag_Table or 0
	local capacity = LD.GetPetCapacity()
	local MajorPetLabel = GUI.GetChild(petItem,"MajorPetLabel"..index)
	GUI.UnRegisterUIEvent(petItem, UCE.PointerClick, "PetUI", "OnGetMorePetClick")
	test("======="..index)
	GUI.SetVisible(majorLogo, false)
	GUI.SetVisible(deputyLogo, false)
	GUI.SetVisible(MajorPetLabel,false)
	GUI.SetVisible(LineUpPet,false)
	GUI.SetVisible(GetMorePet,false)
	GUI.SetVisible(GetMoreText,false)
	GUI.SetRedPointVisable(petItem,false)
	if index >= capacity then
		PetItem.SetLock(petItem)
		-- GUI.SetVisible(MajorPetLabel,false)
		local lockText = GUI.GetChild(petItem, "lockText")
		if index < lockNum + capacity  then
			GUI.StaticSetText(lockText, string.format("%d级解锁", PetUI.LevelUpPetBag_Table[index - capacity + 1]))
		else
			GUI.StaticSetText(lockText, "点击扩充格子")
		end
		GUI.CheckBoxExSetCheck(petItem, false);
	else
		local petGuid = PetUI.GetPetGuid(index)
		local Id = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)))
		local petDB = DB.GetOncePetByKey1(Id)
		local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
		local PetLevel = tonumber(UIDefine.GetPetLevelStrByGuid(petGuid))
		for i=1 , #PetUI.RedPointList do
			if index == PetUI.RedPointList[i] then
				GUI.SetRedPointVisable(petItem,true)
			end
		end
		if index < LD.GetPetCount() then
		------------------可上阵显示-------------------------------
			if ExchangTorF ==1 then
				local death = petDB.Life ~= -1 and tonumber(LD.GetPetIntAttr(RoleAttr.PetAttrLife, petGuid)) <= 0
				if not LD.GetPetState(PetState.Lineup,petGuid) and  petDB.CarryLevel <= Level and Level+10 >= PetLevel and not death then
					GUI.SetVisible(LineUpPet,true)
				else
					GUI.SetVisible(LineUpPet,false)
				end
			else
				GUI.SetVisible(LineUpPet,false)
			end
		----------------------------------------------------
			if PetUI.petGuidList[index] == PetUI.petGuid then
				GUI.CheckBoxExSetCheck(petItem, true);
			else
				GUI.CheckBoxExSetCheck(petItem, false);
			end
            if PetUI.tabIndex == 4 then
                if petGuid == PetGuid1 then
                    GUI.SetVisible(majorLogo, true)
                elseif petGuid == PetGuid2 then
                    GUI.SetVisible(deputyLogo, true)
                -- else

                    -- GUI.SetVisible(majorLogo, false)
                    -- GUI.SetVisible(deputyLogo, false)
                end
            -- else
                -- GUI.SetVisible(majorLogo, false)
                -- GUI.SetVisible(deputyLogo, false)
            end
			
		--添加宠物
        elseif index == LD.GetPetCount() then
			if capacity > LD.GetPetCount() then
				GUI.SetVisible(GetMorePet,true)
				GUI.SetVisible(GetMoreText,true)
				GUI.CheckBoxExSetCheck(petItem, false);
				-- GUI.SetVisible(majorLogo, false)
				-- GUI.SetVisible(deputyLogo, false)
				GUI.RegisterUIEvent(petItem, UCE.PointerClick, "PetUI", "OnGetMorePetClick")
			else
				GUI.CheckBoxExSetCheck(petItem, false);
				-- GUI.SetVisible(majorLogo, false)
				-- GUI.SetVisible(deputyLogo, false)
			end
		else
            GUI.CheckBoxExSetCheck(petItem, false);
            -- GUI.SetVisible(majorLogo, false)
            -- GUI.SetVisible(deputyLogo, false)
		end
		
			

		PetItem.BindPetGuid(petItem, petGuid, pet_container_type.pet_container_panel,nil,UIDefine.NowLineupList[0])
	end
end



function PetUI.OnPetItemClick(guid)---当宠物格子被点击
	
	local petItem = GUI.GetByGuid(guid);
	local index = GUI.CheckBoxExGetIndex(petItem);
	PetUI.ListIndex = index
	
	LineUpPetGuid = nil
	if PetUI.tabIndex ==5 then
		if ExchangTorF ==1 then
			local petGuid = PetUI.GetPetGuid(index)
			if petGuid ~=0 and petGuid ~= nil then
				local Id = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)))
				local petDB = DB.GetOncePetByKey1(Id)
				local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
				local PetLevel = tonumber(UIDefine.GetPetLevelStrByGuid(petGuid))
				if	LD.GetPetState(PetState.Lineup,petGuid) then
					CL.SendNotify(NOTIFY.ShowBBMsg, "宠物"..petDB.Name.."已在阵容上，无法上阵")
				elseif petDB.CarryLevel > Level then
					CL.SendNotify(NOTIFY.ShowBBMsg, "因角色等级过低，宠物无法上阵")
				elseif Level+10 < PetLevel then
					CL.SendNotify(NOTIFY.ShowBBMsg, "宠物高出人物等级10级，无法上阵")
				elseif petDB.Life ~=-1 and tonumber(LD.GetPetIntAttr(RoleAttr.PetAttrLife, petGuid)) <= 0 then
					CL.SendNotify(NOTIFY.ShowBBMsg, "您的宠物已经死亡，无法参战")
				else
					LineUpPetGuid = petGuid
				end
			else
				GUI.CheckBoxExSetCheck(petItem, false)
				-- return
			end
		end
	elseif  PetUI.tabIndex == 3 then
	--清空锁定的资质
		LockAttrList={}
	--清空精粹的使用
		local intensifyToggle = _gt.GetUI("intensifyToggle")
		GUI.CheckBoxSetCheck(intensifyToggle,false)
	end
	if index>=LD.GetPetCapacity() then

		CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "UnlockPetField")
		GUI.CheckBoxExSetCheck(petItem,false);
		return;
	end

	PetUI.OnPetItemClickByIndex(index)
	if PetUI.tabIndex ==4 then
		local type = nil
		if type==nil then
			type= pet_container_type.pet_container_panel;
		end
		local PetGuid = PetUI.petGuid
        if PetGuid ~= nil then
			local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, PetGuid)))
			local petDB =DB.GetOncePetByKey1(petId);
			if PetUI.PetMixServerData["MajorPetType"][petDB.Type] then
				local temptype = ""
				if visible ==1 then
					temptype = "MajorPetLevel"
				elseif  visible ==2 then
					temptype = "MinorPetLevel"
				end
				if UIDefine.GetPetLevelStrByGuid(PetGuid,type) >= PetUI.PetMixServerData[temptype] then
					if not  LD.GetPetState(PetState.Lineup,PetUI.petGuid)  then
						if visible == 1 then
							if PetGuid1 ~= PetGuid and PetGuid2 ~= PetGuid then
								local synthesisPetModelGroup = _gt.GetUI("synthesisPetModelGroup")
								GUI.SetVisible(synthesisPetModelGroup, true)
								modelVisible1 = 1
								local CreateItemLeftPool = _gt.GetUI("CreateItemLeftPool")
								GUI.LoopScrollRectRefreshCells(CreateItemLeftPool)
								local checkMiddleLeftImage = _gt.GetUI("checkMiddleLeftImage")
								local checkMiddleRightImage = _gt.GetUI("checkMiddleRightImage")
								GUI.SetVisible(checkMiddleLeftImage, false)
								GUI.SetVisible(checkMiddleRightImage, true)
								PetGuid1 = PetGuid
								visible = 2
									local petScroll = _gt.GetUI("petScroll")
									local count = LogicDefine.PetMaxLimit
									GUI.LoopScrollRectSetTotalCount(petScroll, count)
									GUI.LoopScrollRectRefreshCells(petScroll)
							end
						else
							if PetGuid1 ~= PetGuid and PetGuid2 ~= PetGuid then
								local synthesisPetModelGroup2 = _gt.GetUI("synthesisPetModelGroup2")
								GUI.SetVisible(synthesisPetModelGroup2, true)
								modelVisible2 = 1
								local CreateItemRightPool = _gt.GetUI("CreateItemRightPool")
								GUI.LoopScrollRectRefreshCells(CreateItemRightPool)
								local checkMiddleLeftImage = _gt.GetUI("checkMiddleLeftImage")
								local checkMiddleRightImage = _gt.GetUI("checkMiddleRightImage")
								GUI.SetVisible(checkMiddleLeftImage, true)
								GUI.SetVisible(checkMiddleRightImage, false)
								PetGuid2 = PetGuid
								visible = 1
									local petScroll = _gt.GetUI("petScroll")
									local count = LogicDefine.PetMaxLimit
									GUI.LoopScrollRectSetTotalCount(petScroll, count)
									GUI.LoopScrollRectRefreshCells(petScroll)
							end
						end
					else
						CL.SendNotify(NOTIFY.ShowBBMsg, "已参战的宠物无法参与合成")
					end
				else
					CL.SendNotify(NOTIFY.ShowBBMsg,"参与合成的宠物必须大于等于"..tostring(PetUI.PetMixServerData[temptype]).."级")
				end
			else
				local temptable = {}
				for k,v in pairs(PetUI.PetMixServerData["MajorPetType"]) do
					table.insert(temptable,tonumber(k))
				end
				local tempstr = UIDefine.PetTypeTxt[temptable[1]]
				if #temptable > 1 then
					for i =2 , #temptable do
						tempstr = tempstr.."或"..UIDefine.PetTypeTxt[temptable[i]]
					end
				end
				CL.SendNotify(NOTIFY.ShowBBMsg, "参与合成的宠物类别必须是"..tempstr.."宠物")
			end
		end
    end
end

function PetUI.OnPetItemClickByIndex(index)
	if index < LD.GetPetCount() then
		local petGuid = PetUI.petGuidList[index];
		if PetUI.petGuid ~= petGuid and petGuid ~= nil then
			RestorePetIndex = index
			PetUI.SetPetGuid(petGuid);
		end

	end
	if LineUpPetGuid ~= nil and ExchangTorF ==1 then
		PetUI.OnPetLineUpBtnClick()
	else
		PetUI.Refresh();
	end
end

function PetUI.GetPetGuid(listIndex)
	local petGuid = 0;
	if PetUI.petGuidList ~= nil and listIndex < PetUI.petGuidList.Count then
		petGuid = PetUI.petGuidList[listIndex]
	end
	return petGuid
end

function PetUI.SetPetGuid(petGuid)
	if PetUI.petGuid==petGuid then
		return
	end
	PetUI.petGuid = petGuid
	if PetUI.petGuid ~= nil then
		local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, PetUI.petGuid))) or 0;
		PetUI.petDB = DB.GetOncePetByKey1(petId);
	else
		PetUI.petDB = nil
	end

end


--宠物技能栏
function PetUI.CreateSkillItem()
  local skillScroll = GUI.GetByGuid(_gt.skillScroll)
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(skillScroll);
  local skillItem = ItemIcon.Create(skillScroll,"skillItem"..curCount,0,0)
  GUI.RegisterUIEvent(skillItem, UCE.PointerClick, "PetUI", "OnSkillItemClick")
  return skillItem;
end

function PetUI.RefreshSkillScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local skillItem = GUI.GetByGuid(guid);
	if PetUI.petGuid==nil then
		return
	end
    
	local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid)
	if num < index then
		ItemIcon.SetEmpty(skillItem)
		return
	end
	if num == index then
		ItemIcon.SetAddState(skillItem)
		return
	end

	local skills=GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetUI.petGuid)
	local data = skills[index]

	ItemIcon.BindPetSkill(skillItem,{SkillId = data.id, SkillData = data})
  
end



function PetUI.OnSkillItemClick(guid)
	if PetUI.petGuid==nil then
		return
	end
	
	local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetUI.petGuid)
	local skillItem = GUI.GetByGuid(guid);
	local skills=GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetUI.petGuid)
	local index = GUI.ItemCtrlGetIndex(skillItem);
  
	if index < num then
  
		if skills[index] then
			-- local skillDB = DB.GetOnceSkillByKey1(skills[index].id)
			-- CL.SendNotify(NOTIFY.SkillTipsReq, skills[index].id, uint64.new(PetUI.petGuid))
			-- PetUI.SkillPerformance = skills[index].performance
			Tips.CreateSkillId(skills[index].id,_gt.GetUI("panelBg"),"tips",0,0,0,0,skills[index].performance)
		end
	elseif index == num then
		SkillStudy_Index = 1
		PetUI.tabIndex = 2
		CurpageEduSubTab = 2
		PetUI.Refresh()
	end

	-- local BreachSkillScroll =_gt.GetUI("BreachSkillScroll")
	-- GUI.LoopScrollRectRefreshCells(BreachSkillScroll);
end


--放生按钮被点击
function PetUI.OnFreePetBtnClick()
    if PetUI.petGuid ~= nil then
		local PetData = LD.GetPetData(PetUI.petGuid)
		local isLock = LD.GetPetState(PetState.Lock, PetUI.petGuid)
		if isLock then
			CL.SendNotify(NOTIFY.ShowBBMsg, "锁定宠物不能放生")
			return
		end
		if LD.GetPetState(PetState.Lineup,PetUI.petGuid) then
			CL.SendNotify(NOTIFY.ShowBBMsg, "出战宠物不能放生")
			return
		end
		local msg = "您确定要放生宠物" .. "<color=#ff0000>" .. PetData.name .. "</color>？放生后将无法找回"

        GlobalUtils.ShowBoxMsg2Btn( "宠物放生", msg, "PetUI", "确定","OnMsgBoxOKBtnClick_ReleasePet", "取消","OnMsgBoxCancelBtnClick","OnMsgBoxCancelBtnClick")
		
	end
end


--放生确定
function PetUI.OnMsgBoxOKBtnClick_ReleasePet()
	if PetUI.petGuid ~= nil then
		--刷新阵容位置
		PetUI.PetListChange = 1
		CL.SendNotify(NOTIFY.ReleasePet,uint64.new(PetUI.petGuid))
	end
end

--锁定
function PetUI.OnLockBtnClick()
	if PetUI.petGuid ~= nil and PetUI.petGuid ~= "" then
		local isLock = LD.GetPetState(PetState.Lock, PetUI.petGuid)
		local lockBtn =_gt.GetUI("lockBtn")
		if isLock then
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetSystem", "UnLockStatus",PetUI.petGuid)
			PetUI.Refresh()
		else 
			CL.SendNotify(NOTIFY.SubmitForm, "FormPetSystem", "LockStatus",PetUI.petGuid)
			PetUI.Refresh()
		end
    end
end

--参战（跳转到阵容页面
function PetUI.OnJoinBattleBtnClick()
	if PetUI.petGuid ~=nil then
			if PetUI.petGuid ~= nil then
				local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
				if Level < PetUI.petDB.CarryLevel then
					CL.SendNotify(NOTIFY.ShowBBMsg, "因角色等级过低，宠物无法上阵")
					return
				end
				if LD.GetPetState(PetState.Lineup,PetUI.petGuid)  then
					PetUI.OnPetLineUpToggle()
				else
					local mark = -1 
					for i =0 ,4 do
						if mark == -1 then
							if UIDefine.NowLineupList[i] == "-1" and UIDefine.UnlockLevel[i] <= Level then
								mark = i
							end
						end
					end
					if mark == -1 then
						PetUI.OnPetLineUpToggle()
						CL.SendNotify(NOTIFY.ShowBBMsg, "当前阵容已满，请手动调整阵容")
					else
						CL.SendNotify(NOTIFY.SubmitForm, "FormPetLineup", "UpLineup",PetUI.petGuid,mark)
						PetUI.PetListChange = 1
						-- PetUI.tabIndex = 5
						-- PetUI.OnPetLineUpToggle()
					end
				end
			end
	end
end

--上阵
function PetUI.OnPetLineUpBtnClick()
	if LineUpPetGuid ~= nil  then
		local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,LineUpPetGuid)
		local PetDB =DB.GetOncePetByKey1(id)
		-- if PetDB.Life ~= -1 and tonumber(LD.GetPetIntAttr(RoleAttr.PetAttrLife, LineUpPetGuid)) <= 0 then
			-- CL.SendNotify(NOTIFY.ShowBBMsg, "您的宠物已经死亡，无法参战")
			-- PetUI.Refresh()
			-- return
		-- end
		ExchangTorF = 0
		CL.SendNotify(NOTIFY.SubmitForm, "FormPetLineup", "UpLineup",LineUpPetGuid,LineUp_LastIndex)
		CL.SendNotify(NOTIFY.ShowBBMsg, "成功设置该宠物的出战状态")
		--刷新红点
		PetUI.RedPointData()
		--刷新阵容位置
		PetUI.PetListChange = 1
	end
end
--交换阵容位置
function PetUI.OnPetLineSwapBtnClick()
	ExchangTorF = 0
	CL.SendNotify(NOTIFY.SubmitForm, "FormPetLineup", "SwapLineup",ExchangePetPos[1],ExchangePetPos[2])
	CL.SendNotify(NOTIFY.ShowBBMsg, "成功设置该宠物的出战状态")
	--刷新红点
	PetUI.RedPointData()
	--刷新阵容位置
	PetUI.PetListChange = 1
end

--休息
function PetUI.OnSetPetRestBtnClick()
   if LD.GetPetState(PetState.Lineup,PetUI.petGuid) then
		if PetUI.petGuid ~= nil then
		LineUpPetGuid = PetUI.petGuid
		PetUI.OnLineDownBtnClick()
		end
	end
end

--下阵
function PetUI.OnLineDownBtnClick()
		--还原交换状态
		ExchangTorF = 0
		CL.SendNotify(NOTIFY.SubmitForm, "FormPetLineup", "DownLineup",LineUpPetGuid)
		CL.SendNotify(NOTIFY.ShowBBMsg, "成功设置该宠物的出战状态")
		--刷新红点
		PetUI.RedPointData()
		--刷新阵容位置
		PetUI.PetListChange = 1
end

--当点击展示宠物按钮时
function PetUI.OnShowBtnClick()
	if PetUI.petGuid ~= nil then
		local isShow = LD.GetPetState(PetState.Show, PetUI.petGuid)
		--非展示状态下
		if not isShow then
			--判断寿命
			if PetUI.petDB.Life ~= -1 then 
				local life = tonumber(LD.GetPetIntAttr(RoleAttr.PetAttrLife, PetUI.petGuid))
				if life and life<=0 then
					CL.SendNotify(NOTIFY.ShowBBMsg, "您的宠物已经死亡，无法展示")
					return
				end
			end
		end
		CL.SendNotify(NOTIFY.ShowPet, uint64.new(PetUI.petGuid))
	end
end

--点击图鉴
function PetUI.OnGetMorePetClick()
	GUI.OpenWnd("PetHandBookUI")
end

 --当按改名键
function PetUI.OnRenameBtnClick() 
	if PetUI.petGuid~=nil then
		GUI.OpenWnd("RoleRenameUI")
		RoleRenameUI.SetPetGuid(PetUI.petGuid)
	end
end

-- function PetUI.OnSkillTipNtf(skillId, tip, blueCost)
    -- Tips.CreateSkillId(skillId, _gt.GetUI("panelBg"), "skillTips", 0, 0, 0, 0, PetUI.SkillPerformance, tip)
-- end