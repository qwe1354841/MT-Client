local PetInfoUI = {}

_G.PetInfoUI = PetInfoUI
local _gt = UILayout.NewGUIDUtilTable()

PetInfoUI.ShowType = 0
PetInfoUI.AttrTalentList = {}
local itemIconBg = UIDefine.ItemIconBg
--宠物携带最大技能数
local CntOfSkillsPerPet = 40

--宠物模型偏移表(Y轴)
local ModelOffsetConfig = {
	["5407"] = 40,
}

local petProperty = {
	[1] = { "气血", "RoleAttrHp", "1800408120", "1800408110", 260, "RoleAttrHpLimit", "HP", Attr = RoleAttr.RoleAttrHpLimit},
	[2] = { "魔法", "RoleAttrMp", "1800408130", "1800408110", 260, "RoleAttrMpLimit" ,"MP", Attr = RoleAttr.RoleAttrMpLimit},

	[3] = { "物攻", "RoleAttrPhyAtk","PhyAtk", Attr = RoleAttr.RoleAttrPhyAtk },
	[4] = { "法攻", "RoleAttrMagAtk","MagAtk" , Attr = RoleAttr.RoleAttrMagAtk},
	[5] = { "物防", "RoleAttrPhyDef","PhyDef" , Attr = RoleAttr.RoleAttrPhyDef},
	[6] = { "法防", "RoleAttrMagDef","MagDef" , Attr = RoleAttr.RoleAttrMagDef},
	[7] = { "速度", "RoleAttrFightSpeed","Speed", Attr = RoleAttr.RoleAttrFightSpeed},

	[8] = { "力量", "RoleAttrStr","Str" , Attr = RoleAttr.RoleAttrStr},
	[9] = { "法力", "RoleAttrInt","Int" , Attr = RoleAttr.RoleAttrInt},
	[10] = { "体质", "RoleAttrVit","Vit" , Attr = RoleAttr.RoleAttrVit},
	[11] = { "耐力", "RoleAttrEnd" ,"End", Attr = RoleAttr.RoleAttrEnd},
	[12] = { "敏捷", "RoleAttrAgi","Agi", Attr = RoleAttr.RoleAttrAgi },
	
	[13] = { "血量资质", "PetAttrHpTalent", "1800408160", "1800408110", 225,"TalentHPMax","TalentHPMin" },
	[14] = { "物攻资质", "PetAttrPhyAtkTalent", "1800408160", "1800408110", 225,"TalentPhyAtkMax" ,"TalentPhyAtkMin"},		
	[15] = { "物防资质", "PetAttrPhyDefTalent", "1800408160", "1800408110", 225,"TalentPhyDefMax","TalentPhyDefMin" },
	[16] = { "法攻资质", "PetAttrMagAtkTalent", "1800408160", "1800408110", 225,"TalentMagAtkMax" ,"TalentMagAtkMin"},
	[17] = { "法防资质", "PetAttrMagDefTalent", "1800408160", "1800408110", 225,"TalentMagDefMax" ,"TalentMagDefMin"},		
	[18] = { "速度资质", "PetAttrSpeedTalent", "1800408160", "1800408110", 225,"TalentSpeedMax","TalentSpeedMin"},
	[19] = { "成  长  率", "PetAttrGrowthrate", "1800408160", "1800408110", 225,"GrowthRateMax","GrowthRateMin" },
	[20] = { "悟        性", "PetAttrSavvy", "1800408160", "1800408110", 225,"SavvyMax" ,"SavvyMin"},

}

local equipSiteData={
  [1]={site=LogicDefine.PetEquipSite.site_collar,img="1801400030"},
  [2]={site=LogicDefine.PetEquipSite.site_armor,img="1801400040"},
  [3]={site=LogicDefine.PetEquipSite.site_amulet,img="1801400050"},
}

--parameter : "1,keyname" "2,guid"  "3,合成"   "else,setdata"
function PetInfoUI.Main(parameter)
	PetInfoUI.ShowType = nil 
	PetInfoUI.Key = nil 
	if parameter then
		parameter = string.split(parameter,",")
		PetInfoUI.ShowType = tonumber(parameter[1])
		if PetInfoUI.ShowType ==2 or PetInfoUI.ShowType ==1 then
			PetInfoUI.Key = parameter[2]
		end
	end
	
    _gt = UILayout.NewGUIDUtilTable()
	local wnd = GUI.WndCreateWnd("PetInfoUI", "PetInfoUI", 0, 0,eCanvasGroup.Normal_Extend)
	local panelBg = UILayout.CreateFrame_WndStyle2(wnd, "宠物信息", 760, 585, "PetInfoUI", "OnCloseBtnClick", _gt)
	_gt.BindName(panelBg,"PetInfoUI")
	
	--宠物名字
	local PetName= GUI.CreateStatic(panelBg, "PetName", "神兽分二点", 90, 60, 200, 30);
	GUI.SetColor(PetName, UIDefine.BrownColor)
	GUI.StaticSetFontSize(PetName, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(PetName, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(PetName, UILayout.TopLeft)
	_gt.BindName(PetName, "PetName")
	--等级
	local LevelArea = GUI.CreateStatic(panelBg, "LevelArea", "等级", 25, 90, 60, 30);
	GUI.SetColor(LevelArea, UIDefine.BrownColor)
	GUI.StaticSetFontSize(LevelArea, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(LevelArea, UILayout.TopLeft)

	local bg = GUI.ImageCreate(LevelArea, "bg", "1800700010", 62, -1, false, 85, 30);
	UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)

	local LevelText = GUI.CreateStatic(bg, "LevelText", "0", 0, -1, 150, 35);
	GUI.SetColor(LevelText, UIDefine.White2Color)
	GUI.StaticSetFontSize(LevelText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(LevelText, TextAnchor.MiddleCenter)
	_gt.BindName(LevelText, "LevelText")
	--参战等级
	local CarryLevelArea = GUI.CreateStatic(panelBg, "CarryLevelArea", "参战等级", 185, 90, 100, 30);
	GUI.SetColor(CarryLevelArea, UIDefine.BrownColor);
	GUI.StaticSetFontSize(CarryLevelArea, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(CarryLevelArea, UILayout.TopLeft)

	local bg = GUI.ImageCreate(CarryLevelArea, "bg", "1800700010", 92, -1, false, 90, 30);
	UILayout.SetSameAnchorAndPivot(bg, UILayout.Center);

	local CarryLevelText = GUI.CreateStatic(bg, "CarryLevelText", "0", 0, -1, 100, 35);
	GUI.SetColor(CarryLevelText, UIDefine.White2Color);
	GUI.StaticSetFontSize(CarryLevelText, UIDefine.FontSizeS)
	GUI.StaticSetAlignment(CarryLevelText, TextAnchor.MiddleCenter)
	_gt.BindName(CarryLevelText, "CarryLevelText")
	--模型背景
	local ModelBg = GUI.ImageCreate(panelBg, "ModelBg", "1800400230", 15, 120);
	UILayout.SetSameAnchorAndPivot(ModelBg, UILayout.TopLeft);
	
	--模型
	local model = GUI.RawImageCreate(ModelBg, false, "model", "", -150, -190, 50, false, 560, 560)
    _gt.BindName(model, "model");
    model:RegisterEvent(UCE.Drag)
    GUI.AddToCamera(model);
    GUI.RawImageSetCameraConfig(model, "(1.65, 1.4, 2),(-0.04464257, 0.9316535, -0.1226545, -0.3390941), True, 5, 0.01, 1.95, 1E-05");
    model:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(model, UCE.PointerClick, "PetInfoUI", "OnModelClick")
    local petModel = GUI.RawImageChildCreate(model, true, "petModel", "", 0, 0)
    _gt.BindName(petModel, "petModel");
    GUI.BindPrefabWithChild(model, GUI.GetGuid(petModel))
    GUI.RegisterUIEvent(petModel, ULE.AnimationCallBack, "PetInfoUI", "OnAnimationCallBack")
	
	--阴影
	local Shadow = GUI.ImageCreate(panelBg, "Shadow", "1800400240", -10, 260);
	UILayout.SetSameAnchorAndPivot(Shadow, UILayout.TopLeft)
	--装备栏
	local equipSiteData={
		[1]={site=LogicDefine.PetEquipSite.site_collar,img="1801400030"},
		[2]={site=LogicDefine.PetEquipSite.site_armor,img="1801400040"},
		[3]={site=LogicDefine.PetEquipSite.site_amulet,img="1801400050"},
	}

	for i = 1, 3 do 
	local PetEquip =ItemIcon.Create(panelBg,"PetEquip"..i,-65,125+(-85*i))
    UILayout.SetSameAnchorAndPivot(PetEquip, UILayout.Center);
    GUI.ItemCtrlSetElementValue(PetEquip, eItemIconElement.Border, "1800400050");
    GUI.ItemCtrlSetElementValue(PetEquip, eItemIconElement.Icon, equipSiteData[i].img);
    GUI.ItemCtrlSetElementRect(PetEquip, eItemIconElement.Icon, 0, -1,55,55)
	GUI.RegisterUIEvent(PetEquip, UCE.PointerClick, "PetInfoUI", "OnEquipItemClick")
	GUI.SetData(PetEquip, "index", i)
	_gt.BindName(PetEquip,"PetEquip"..i)
	end
	--星级
	for i =1 ,6 do
	local StarBg = GUI.ImageCreate(panelBg, "StarBg"..i, "1801202192", 45+(i*25), 315,false,30,30)
	UILayout.SetSameAnchorAndPivot(StarBg, UILayout.TopLeft)
	_gt.BindName(StarBg,"StarBg"..i)
	-- GUI.SetVisible(StarBg,false)
	end
	--战力
	local FightNumIcon1 = GUI.ImageCreate(panelBg,"FightNumIcon1", "1800407010", 75, 345)
	UILayout.SetSameAnchorAndPivot(FightNumIcon1, UILayout.TopLeft)
	local FightNumIcon2 = GUI.ImageCreate(panelBg,"FightNumIcon2", "1800404020", 100, 345)
	UILayout.SetSameAnchorAndPivot(FightNumIcon2, UILayout.TopLeft)
	local FightNum = GUI.CreateStatic( panelBg, "FightNum","4561", 100, 345, 160, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(FightNum, UILayout.TopLeft)
    GUI.StaticSetFontSize(FightNum, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(FightNum, TextAnchor.MiddleCenter)
	GUI.SetColor(FightNum, UIDefine.BrownColor)
	_gt.BindName(FightNum,"FightNum")
	--战力是否隐藏
	GUI.SetVisible(FightNumIcon1,PetInfoUI.ShowType ~= 1)
	GUI.SetVisible(FightNumIcon2,PetInfoUI.ShowType ~= 1)
	GUI.SetVisible(FightNum,PetInfoUI.ShowType ~= 1)
	
	local CutLine = GUI.ImageCreate(panelBg, "CutLine", "1800400740", -185, 95,false, 370,31)
	UILayout.SetSameAnchorAndPivot(CutLine, UILayout.Center)
	
	if PetInfoUI.ShowType == 1 then 
	local CutLineText = GUI.CreateStatic(CutLine, "CutLineText", "宠物可能拥有技能", 0, 0, 300, 50);
	UILayout.SetSameAnchorAndPivot(CutLineText, UILayout.Center)
	GUI.SetColor(CutLineText, UIDefine.White2Color);
	GUI.StaticSetFontSize(CutLineText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(CutLineText, TextAnchor.MiddleCenter)
	else
	local CutLineText = GUI.CreateStatic(CutLine, "CutLineText", "宠物技能", 0, 0, 300, 50);
	UILayout.SetSameAnchorAndPivot(CutLineText, UILayout.Center)
	GUI.SetColor(CutLineText, UIDefine.White2Color);
	GUI.StaticSetFontSize(CutLineText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(CutLineText, TextAnchor.MiddleCenter)	
	end
	
	--技能
	local PetSkillScroll = GUI.LoopScrollRectCreate(panelBg, "PetSkillScroll", -185, 195, 400, 160,
	"PetInfoUI", "CreatePetSkillItem", "PetInfoUI", "RefreshPetSkillScroll", 0, false, Vector2.New(80, 80), 4, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(PetSkillScroll, UILayout.Center)
	_gt.BindName(PetSkillScroll, "PetSkillScroll")
	
	local petTypeLabel = GUI.ImageCreate(panelBg, "petTypeLabel", "1800704020", 235, 125);
	_gt.BindName(petTypeLabel, "petTypeLabel")
	UILayout.SetSameAnchorAndPivot(petTypeLabel, UILayout.TopLeft)
	
	
	local RightPanel = GUI.ImageCreate(panelBg, "RightPanel", "1800400200", -20, 60, false, 360, 505)
	UILayout.SetSameAnchorAndPivot(RightPanel, UILayout.TopRight);
	_gt.BindName(RightPanel,"RightPanel")

	--气血、魔法
	local attrList1 = {1, 2}
    for i = 1, #attrList1 do
        local data = petProperty[attrList1[i]]

        local Label = GUI.CreateStatic( RightPanel, data[2] .. "Label", data[1], 140, -267 + ( 40 * i ), 50, 30, "system", true)
		UILayout.SetSameAnchorAndPivot(Label, UILayout.Center)
        GUI.StaticSetFontSize(Label, UIDefine.FontSizeS)
        GUI.SetColor(Label,UIDefine.BrownColor)

        local Slider = GUI.ScrollBarCreate( Label, data[2], "", data[3], data[4], 180, -2, 20, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false,false)
		_gt.BindName(Slider, data[6])
        
        local silderFillSize = Vector2.New(data[5], 24)
        GUI.ScrollBarSetFillSize(Slider, silderFillSize)
        GUI.ScrollBarSetBgSize(Slider, silderFillSize)
        UILayout.SetSameAnchorAndPivot(Slider, UILayout.Left)

        local text = GUI.CreateStatic( Slider, data[2] .. "Text", "", 0, 1, 200, 30, "system", true)
         UILayout.SetSameAnchorAndPivot(text, UILayout.Center)
        GUI.StaticSetFontSize(text, UIDefine.FontSizeS)
		GUI.StaticSetAlignment(text,TextAnchor.MiddleCenter)
		_gt.BindName(text, data[2])
	end
	--属性
	local attrList2 = {3,4,5,6,7}
	for i = 1, #attrList2 do
        local data = petProperty[attrList2[i]]

        local Label = GUI.CreateStatic( RightPanel, data[2] .. "Label", data[1], 90, -175 + (32*i) , 150, 30, "system", true, false)
        UILayout.SetSameAnchorAndPivot(Label, UILayout.Center)
        GUI.StaticSetFontSize(Label, UIDefine.FontSizeS)
        GUI.SetColor(Label, UIDefine.BrownColor)

        local text = GUI.CreateStatic(Label, data[2] .. "Text", "20", 90, 1, 200, 30, "system", true)
        UILayout.SetSameAnchorAndPivot(text, UILayout.Center)
        GUI.StaticSetFontSize(text, UIDefine.FontSizeS)
		GUI.StaticSetAlignment(text,TextAnchor.MiddleLeft)
		GUI.SetColor(text, UIDefine.Yellow2Color)
		_gt.BindName(text, data[2])		
	end
	
	local attrList3 = {8,9,10,11,12}
	for i = 1, #attrList3 do
        local data = petProperty[attrList3[i]]

        local Label = GUI.CreateStatic( RightPanel, data[2] .. "Label", data[1], -90, -175 + (32*i) , 150, 30, "system", true, false)
        UILayout.SetSameAnchorAndPivot(Label, UILayout.Center)
        GUI.StaticSetFontSize(Label, UIDefine.FontSizeS)
        GUI.SetColor(Label, UIDefine.BrownColor)	
		
        local text = GUI.CreateStatic(Label, data[2] .. "Text", "20", 90, 1, 200, 30, "system", true)
        UILayout.SetSameAnchorAndPivot(text, UILayout.Center)
        GUI.StaticSetFontSize(text, UIDefine.FontSizeS)
		GUI.StaticSetAlignment(text,TextAnchor.MiddleLeft)
		GUI.SetColor(text, UIDefine.Yellow2Color)
		_gt.BindName(text, data[2])		
	end	
	
	--资质
	local attrList4 = {13,14,15,16,17,18,19,20}
	for i = 1, #attrList4 do
		local data = petProperty[attrList4[i]]

		local Label = GUI.CreateStatic( RightPanel, data[2] .. "Label", data[1], 90,  -5+(29 * i) , 150, 30, "system", true, false)
		UILayout.SetSameAnchorAndPivot(Label, UILayout.Center)
		GUI.StaticSetFontSize(Label, UIDefine.FontSizeM)
		GUI.SetColor(Label, UIDefine.BrownColor)

		if PetInfoUI.ShowType == 1 then 
			local currentTxt = GUI.CreateStatic(Label, data[2] .. "Text", "10000~20000", 125, 0, 200, 40, "system", true)
			UILayout.SetSameAnchorAndPivot(currentTxt, UILayout.Center)
			GUI.StaticSetFontSize(currentTxt, UIDefine.FontSizeM)
			GUI.StaticSetAlignment(currentTxt,TextAnchor.MiddleLeft)
			GUI.SetColor(currentTxt, UIDefine.Yellow2Color)
			_gt.BindName(currentTxt,"AttrTalentText"..i)	
		else 
			local tempSlider = GUI.ScrollBarCreate( Label, data[2], "", data[3], data[4], 90, -2, 250, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false,false)
			_gt.BindName(tempSlider,"TalentSlider"..i)
			
			local silderFillSize = Vector2.New(230, 24)
			GUI.ScrollBarSetFillSize(tempSlider, silderFillSize)
			GUI.ScrollBarSetBgSize(tempSlider, silderFillSize)
			UILayout.SetSameAnchorAndPivot(tempSlider, UILayout.Left)
				
			local currentTxt = GUI.CreateStatic( tempSlider, data[2] .. "Text", "1000", 0, 0, 200, 40, "system", true)
			UILayout.SetSameAnchorAndPivot(currentTxt, UILayout.Center)
			GUI.StaticSetFontSize(currentTxt, UIDefine.FontSizeS)
			GUI.StaticSetAlignment(currentTxt,TextAnchor.MiddleCenter)
			_gt.BindName(currentTxt,"AttrTalentText"..i)
		end
	end
	
end
 
 
function PetInfoUI.OnShow(parameter)
	if PetInfoUI.ShowType == 1 then
		CL.SendNotify(NOTIFY.SubmitForm,"FormPetDataPreview","GetAttrData",PetInfoUI.Key)
	elseif PetInfoUI.ShowType == 2 then
		PetInfoUI.Refresh()
	end
end


function PetInfoUI.SetPetData(petData) 
	if petData==nil then
		return;
	end
	PetInfoUI.petData=petData
	PetInfoUI.Refresh()
end

 
function PetInfoUI.OnCloseBtnClick()
	GUI.DestroyWnd("PetInfoUI")
end
 
 
function PetInfoUI.Refresh()
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(PetInfoUI.AttrTalentList))	
	if PetInfoUI.ShowType ==1 then
		PetInfoUI.currPetDB = DB.GetOncePetByKey2(PetInfoUI.Key)
	elseif PetInfoUI.ShowType ==2 then
		local id = LD.GetPetIntAttr(RoleAttr.RoleAttrRole,PetInfoUI.Key)
		PetInfoUI.currPetDB =DB.GetOncePetByKey1(id)
	else
		local id = tonumber(tostring(PetInfoUI.petData:GetAttr(RoleAttr.RoleAttrRole)))
		PetInfoUI.currPetDB =DB.GetOncePetByKey1(id)
	end
	--刷新装备
	PetInfoUI.RefreshPetEquip()
		
	--刷新公用模板信息
	PetInfoUI.RefreshBaseInfo()
	
	--刷新属性
	PetInfoUI.RefreshBaseAttrAndTalent()
	
	--刷新宠物技能栏
	PetInfoUI.RefreshPetSkill()
	
end
 
 --刷新宠物基础信息
function PetInfoUI.RefreshBaseInfo()
 	local PetName = _gt.GetUI("PetName")
	local CarryLevel = _gt.GetUI("CarryLevelText")
	local level = _gt.GetUI("LevelText")
	local petTypeLabel = _gt.GetUI("petTypeLabel")
	local FightValue = _gt.GetUI("FightNum")

	PetInfoUI.colorID = nil
	if PetInfoUI.ShowType ==1 then --无实物
		--刷新名字
		GUI.StaticSetText(PetName,tostring(PetInfoUI.currPetDB.Name))
		--刷新等级
		GUI.StaticSetText(level,"0")	
		--默认星级
		local starlevel = 1
		for i=1 , starlevel do
			local star = _gt.GetUI("StarBg"..i)
			GUI.ImageSetImageID(star,"1801202190")
		end
	elseif  PetInfoUI.ShowType ==2 then  --guid
 		--刷新名字
		GUI.StaticSetText(PetName, LD.GetPetName(PetInfoUI.Key))
		--刷新等级
		GUI.StaticSetText(level,UIDefine.GetPetLevelStrByGuid(PetInfoUI.Key))
		--刷新战力
		GUI.StaticSetText(FightValue,tostring(LD.GetPetAttr(RoleAttr.RoleAttrFightValue,PetInfoUI.Key)) )
		--刷新星级
		local starlevel = LD.GetPetIntCustomAttr("PetStarLevel",PetInfoUI.Key,pet_container_type.pet_container_panel)
		for i=1 , starlevel do
			local star = _gt.GetUI("StarBg"..i)
			GUI.ImageSetImageID(star,"1801202190")
		end
		
		PetInfoUI.colorID = LD.GetPetIntAttr(RoleAttr.RoleAttrColor1,PetInfoUI.Key)
	else --petdata
		--刷新名字
		GUI.StaticSetText(PetName,tostring(PetInfoUI.petData.name))
		--刷新等级
		GUI.StaticSetText(level,tostring(PetInfoUI.petData:GetAttr(RoleAttr.RoleAttrLevel)))
		--刷新战力
		GUI.StaticSetText(FightValue,tostring(PetInfoUI.petData:GetAttr(RoleAttr.RoleAttrFightValue)))
		--刷新星级
		local starlevel = PetInfoUI.petData:GetIntCustomAttr("PetStarLevel")
		for i=1 , starlevel do
			local star = _gt.GetUI("StarBg"..i)
			GUI.ImageSetImageID(star,"1801202190")
		end
		PetInfoUI.colorID = PetInfoUI.petData:GetIntAttr(RoleAttr.RoleAttrColor1)
	end
	--刷新参战等级
	GUI.StaticSetText(CarryLevel,"角色"..tostring(PetInfoUI.currPetDB.CarryLevel).."级")
	--宠物类型
	GUI.ImageSetImageID(petTypeLabel, UIDefine.PetType[PetInfoUI.currPetDB.Type])	
	--刷新模型
	PetInfoUI.RefreshPetModel(PetInfoUI.colorID)
 
end
 
--刷新宠物基础属性和资质
function PetInfoUI.RefreshBaseAttrAndTalent()
	local attrList1 = {1, 2}
	local attrList2 = {3,4,5,6,7}
	local attrList3 = {8,9,10,11,12}
	local attrList4 = {13,14,15,16,17,18,19,20}
	if PetInfoUI.ShowType ==1 then
		for i = 1, #attrList1 do
			local data = petProperty[attrList1[i]]
			local text = _gt.GetUI(data[2])
			GUI.StaticSetText(text,PetInfoUI.AttrTalentList[data[7]])	
		end
		for i = 1, #attrList2 do
			local data = petProperty[attrList2[i]]
			local text = _gt.GetUI(data[2])
			GUI.StaticSetText(text,PetInfoUI.AttrTalentList[data[3]])	
		end
		for i = 1, #attrList3 do
			local data = petProperty[attrList3[i]]
			local text = _gt.GetUI(data[2])
			GUI.StaticSetText(text,PetInfoUI.AttrTalentList[data[3]])	
		end
		for i = 1, #attrList4 do
			local data = petProperty[attrList4[i]]
			local text = _gt.GetUI("AttrTalentText"..i)
			local attrmax = data[6]
			local attrmin = data[7]
			GUI.StaticSetText(text,PetInfoUI.currPetDB[attrmin].."~"..PetInfoUI.currPetDB[attrmax])
		end
	elseif PetInfoUI.ShowType ==2 then
		for i = 1, #attrList1 do
			local data = petProperty[attrList1[i]]
			local text = _gt.GetUI(data[2])
			GUI.StaticSetText(text,LD.GetPetIntAttr(RoleAttr[data[6]],PetInfoUI.Key))
		end
		for i = 1, #attrList2 do
			local data = petProperty[attrList2[i]]
			local text = _gt.GetUI(data[2])
			GUI.StaticSetText(text,LD.GetPetIntAttr(RoleAttr[data[2]],PetInfoUI.Key))	
		end
		for i = 1, #attrList3 do
			local data = petProperty[attrList3[i]]
			local text = _gt.GetUI(data[2])
			GUI.StaticSetText(text,LD.GetPetIntAttr(RoleAttr[data[2]],PetInfoUI.Key))	
		end
		for i = 1, #attrList4 do
			local data = petProperty[attrList4[i]]
			local text = _gt.GetUI("AttrTalentText"..i)
			local TalentSlider = _gt.GetUI("TalentSlider"..i)
			if i ~= 7 and i ~= 8 then
				GUI.StaticSetText(text,LD.GetPetIntAttr(RoleAttr[data[2]], PetInfoUI.Key) .. "/" ..LD.GetPetIntCustomAttr(data[6], PetInfoUI.Key))
				GUI.ScrollBarSetPos(TalentSlider,(LD.GetPetIntAttr(RoleAttr[data[2]], PetInfoUI.Key))/(LD.GetPetIntCustomAttr(data[6], PetInfoUI.Key)))
			else
				GUI.StaticSetText(text,LD.GetPetIntAttr(RoleAttr[data[2]], PetInfoUI.Key) .. "/" ..PetInfoUI.currPetDB[data[6]])
				GUI.ScrollBarSetPos(TalentSlider,(LD.GetPetIntAttr(RoleAttr[data[2]], PetInfoUI.Key))/(PetInfoUI.currPetDB[data[6]]))
			end	
		end
	else
		for i = 1, #attrList1 do
			local data = petProperty[attrList1[i]]
			local text = _gt.GetUI(data[2])
			GUI.StaticSetText(text,tostring(PetInfoUI.petData:GetAttr(data.Attr)))
		end
		for i = 1, #attrList2 do
			local data = petProperty[attrList2[i]]
			local text = _gt.GetUI(data[2])
			GUI.StaticSetText(text,tostring(PetInfoUI.petData:GetAttr(data.Attr)))
		end
		for i = 1, #attrList3 do
			local data = petProperty[attrList3[i]]
			local text = _gt.GetUI(data[2])
			GUI.StaticSetText(text,tostring(PetInfoUI.petData:GetAttr(data.Attr)))
		end
		for i = 1, #attrList4 do
			local data = petProperty[attrList4[i]]
			local text = _gt.GetUI("AttrTalentText"..i)
			local TalentSlider = _gt.GetUI("TalentSlider"..i)
			if i ~= 7 and i ~= 8 then
			GUI.StaticSetText(text,PetInfoUI.petData:GetIntAttr(RoleAttr[data[2]]) .. "/" ..PetInfoUI.petData:GetIntCustomAttr(data[6]))
			GUI.ScrollBarSetPos(TalentSlider,(PetInfoUI.petData:GetIntAttr(RoleAttr[data[2]]))/(PetInfoUI.petData:GetIntCustomAttr(data[6])))
			else
			GUI.StaticSetText(text,tostring(PetInfoUI.petData:GetAllAttr(RoleAttr[data[2]])) .. "/" ..PetInfoUI.currPetDB[data[6]])
			GUI.ScrollBarSetPos(TalentSlider,(tostring(PetInfoUI.petData:GetAllAttr(RoleAttr[data[2]])))/(PetInfoUI.currPetDB[data[6]]))			
			end
		end	
	end
end
 
--刷新宠物技能
function PetInfoUI.RefreshPetSkill()
		local PetSkillScroll = _gt.GetUI("PetSkillScroll")
		local skillcount = 0
		--刷新技能
		if PetInfoUI.ShowType ==1 then --无实物
			currSkillIdList = PetInfoUI.GetSkillIdByPetDB(PetInfoUI.currPetDB)
			skillcount = (math.ceil(#currSkillIdList/4))*4
		elseif PetInfoUI.ShowType ==2 then
			skillcount = (math.ceil((GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetInfoUI.Key))/4))*4
		else
			PetInfoUI.skillDatas,PetInfoUI.skillEmptyCount,PetInfoUI.allSkillCount=LogicDefine.GetPetSkill(PetInfoUI.petData)
			test(PetInfoUI.allSkillCount)
			skillcount = (math.ceil(PetInfoUI.allSkillCount/4))*4
		end
		
		GUI.LoopScrollRectSetTotalCount(PetSkillScroll, math.max(skillcount,8))
		GUI.LoopScrollRectRefreshCells(PetSkillScroll)

end
 
--刷新宠物装备信息
function PetInfoUI.RefreshPetEquip()
	--刷新装备
	if PetInfoUI.ShowType ==1 then
	
	
	elseif PetInfoUI.ShowType == 2 then
		for i = 1, #equipSiteData do
			local PetEquip =_gt.GetUI("PetEquip"..i)
			local equipData =LD.GetItemDataByIndex(equipSiteData[i].site,item_container_type.item_container_pet_equip,PetInfoUI.Key)
			ItemIcon.SetEmpty(PetEquip)
			if equipData then
				ItemIcon.BindItemData(PetEquip,equipData);
			else
				GUI.ItemCtrlSetElementValue(PetEquip, eItemIconElement.Border, "1800400050");
				GUI.ItemCtrlSetElementValue(PetEquip, eItemIconElement.Icon, equipSiteData[i].img);
				GUI.ItemCtrlSetElementRect(PetEquip, eItemIconElement.Icon, 0, -1,55,55);
			end
		end
	else 
		local equipData = PetInfoUI.petData.equips.items
			for i = 1, #equipSiteData do
				local PetEquip =_gt.GetUI("PetEquip"..i)
				local mark = 0
				ItemIcon.SetEmpty(PetEquip)
				for j = 1 , equipData.Length do
					if equipData[j-1].site == i-1 then
						ItemIcon.BindItemData(PetEquip,equipData[j-1])	
						mark = 1
					end		
				end
				if mark ~= 1 then
					GUI.ItemCtrlSetElementValue(PetEquip, eItemIconElement.Border, "1800400050");
					GUI.ItemCtrlSetElementValue(PetEquip, eItemIconElement.Icon, equipSiteData[i].img);
					GUI.ItemCtrlSetElementRect(PetEquip, eItemIconElement.Icon, 0, -1,55,55);				
				end
			end
	end
end


function PetInfoUI.RefreshPetModel(colorID)
	local petModel = _gt.GetUI("petModel")
	colorID = colorID or tonumber(PetInfoUI.currPetDB.ColorId)
	ModelItem.Bind(petModel, tonumber(PetInfoUI.currPetDB.Model), colorID, 0, eRoleMovement.ATTSTAND_W1)
	local dyn = ""
	if PetInfoUI.ShowType == 2 then
		dyn = LD.GetPetStrCustomAttr("Model_DynJson1",PetInfoUI.Key)		
	else
		dyn = PetInfoUI.petData:GetStrCustomAttr("Model_DynJson1")
	end
	if dyn ~= "" then
		if UIDefine.IsFunctionOrVariableExist(GUI,"RefreshDyeSkinJson") then 
			GUI.RefreshDyeSkinJson(petModel, dyn, "")
		end
	end	
	--宠物模型Y轴
	local model = _gt.GetUI("model")
	local Offset = ModelOffsetConfig[tostring(PetInfoUI.currPetDB.Model)] or 0
	GUI.SetPositionY(model,-190+Offset)
end
 
--当模型被点击
function PetInfoUI.OnModelClick(guid)
	if not PetInfoUI.currPetDB then return end
	
	local petModel = _gt.GetUI("petModel")
	math.randomseed(os.time())
	local index = math.random(2)
	local movements = { eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1 }
	ModelItem.Bind(petModel, tonumber(PetInfoUI.currPetDB.Model), PetInfoUI.colorID or tonumber(PetInfoUI.currPetDB.ColorId), 0, movements[index])
	local dyn = ""
	if PetInfoUI.ShowType == 2 then
		dyn = LD.GetPetStrCustomAttr("Model_DynJson1",PetInfoUI.Key)		
	else
		dyn = PetInfoUI.petData:GetStrCustomAttr("Model_DynJson1")
	end
	if dyn ~= "" then
		GUI.RefreshDyeSkinJson(petModel, dyn, "")
	end	
end

--点击模型后的回调函数
function PetInfoUI.OnAnimationCallBack(guid, action)
    if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
        return
    end

    local petModel = _gt.GetUI("petModel")
    ModelItem.Bind(petModel, tonumber(PetInfoUI.currPetDB.Model), PetInfoUI.colorID or tonumber(PetInfoUI.currPetDB.ColorId), 0, eRoleMovement.ATTSTAND_W1)
	local dyn = ""
	if PetInfoUI.ShowType == 2 then
		dyn = LD.GetPetStrCustomAttr("Model_DynJson1",PetInfoUI.Key)		
	else
		dyn = PetInfoUI.petData:GetStrCustomAttr("Model_DynJson1")
	end
	if dyn ~= "" then
		GUI.RefreshDyeSkinJson(petModel, dyn, "")
	end	
end
 
 --获取当前宠物的所有技能ID
function PetInfoUI.GetSkillIdByPetDB(petDB)

    local skillGroups = { tonumber(petDB.SkillGroup1), tonumber(petDB.SkillGroup2), tonumber(petDB.SkillGroup3) }

    local tb_skillData = {}
    for i = 1, #skillGroups do
        local skillGroup = DB.GetOnceSkill_GroupByKey1(skillGroups[i])
        local t = { SkillGroup = skillGroup, Take = 0 }
        if skillGroup ~= 0 then
            if i == 1 then
                t.Take = 1
            else
                t.Take = 0
            end
            table.insert(tb_skillData, t)
        end
    end

    local skillIdList = {}

    for i = 1, #tb_skillData do
        local skillGroup = tb_skillData[i].SkillGroup
        for j = 1, CntOfSkillsPerPet do
            local id = tonumber(skillGroup["Skill"..j])
            if id ~= 0 then
                local t = { Id = id, Take = 0 }
                if tb_skillData[i].Take == 1 then
                    t.Take = 1
                end
                table.insert(skillIdList, t)
            end
        end
    end

    return skillIdList
end
 
--创建宠物技能栏格子
function PetInfoUI.CreatePetSkillItem()
	local PetSkillScroll = _gt.GetUI("PetSkillScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(PetSkillScroll);
	local PetSkillItem = GUI.ItemCtrlCreate(PetSkillScroll, "PetSkillItem" .. curCount, "1800400330", 0, 0, 89, 89)
	GUI.RegisterUIEvent(PetSkillItem, UCE.PointerClick, "PetInfoUI", "OnSkillItemClick")
	return PetSkillItem;
end

--刷新宠物技能栏格子
function PetInfoUI.RefreshPetSkillScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local PetSkillItem = GUI.GetByGuid(guid)
	
	if PetInfoUI.ShowType == 1 then
		index = index +1
		if index <= #currSkillIdList then
			local SkillDB = DB.GetOnceSkillByKey1(currSkillIdList[index].Id)
			GUI.ItemCtrlSetElementValue(PetSkillItem, eItemIconElement.Icon , tostring(SkillDB.Icon))
			GUI.ItemCtrlSetElementValue(PetSkillItem, eItemIconElement.Border,itemIconBg[SkillDB.SkillQuality])
			
			--必带标志
			GUI.ItemCtrlSetElementValue(PetSkillItem, eItemIconElement.LeftTopSp, 1800707130)
			GUI.ItemCtrlSetElementRect(PetSkillItem, eItemIconElement.LeftTopSp, 0, 0, 44, 45)
			
			--右下角等级
			if SkillDB.UpSkill == 1  then
				GUI.ItemCtrlSetElementValue(PetSkillItem, eItemIconElement.LeftBottomSp , 1800707140);
				GUI.ItemCtrlSetElementRect(PetSkillItem, eItemIconElement.LeftBottomSp, 58, 8, 15, 20)
			elseif SkillDB.UpSkill == 2  then
				GUI.ItemCtrlSetElementValue(PetSkillItem, eItemIconElement.LeftBottomSp , 1800707150);
				GUI.ItemCtrlSetElementRect(PetSkillItem, eItemIconElement.LeftBottomSp, 55, 8, 20, 20)
			elseif SkillDB.UpSkill == 3  then
				GUI.ItemCtrlSetElementValue(PetSkillItem, eItemIconElement.LeftBottomSp , 1800707160);
				GUI.ItemCtrlSetElementRect(PetSkillItem, eItemIconElement.LeftBottomSp, 50, 8, 25, 20)
			else
				GUI.ItemCtrlSetElementValue(PetSkillItem, eItemIconElement.LeftBottomSp , nil)
			end
		else
			ItemIcon.SetEmpty(PetSkillItem)
			return
		end
	elseif PetInfoUI.ShowType ==2 then
		if PetInfoUI.Key==nil then
			return
		end
    
		local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetInfoUI.Key)
		if num <= index then
			ItemIcon.SetEmpty(PetSkillItem)
			return
		end
		local skills=GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetInfoUI.Key)
		local data = skills[index]
		ItemIcon.BindPetSkill(PetSkillItem,{SkillId = data.id, SkillData = data})
	else
		index=index+1;
		if index<=#PetInfoUI.skillDatas then
			ItemIcon.BindPetSkill(PetSkillItem,PetInfoUI.skillDatas[index])
		else
			ItemIcon.SetEmpty(PetSkillItem)
			return
		end
	end
end

--宠物技能栏被点击
function PetInfoUI.OnSkillItemClick(guid)
	local PetSkillItem = GUI.GetByGuid(guid)
	local index = GUI.ItemCtrlGetIndex(PetSkillItem)
	if PetInfoUI.ShowType == 1 then
		index = index +1
		if index <= #currSkillIdList then
			-- local SkillDB = DB.GetOnceSkillByKey1(currSkillIdList[index].Id)
			Tips.CreateSkillId(currSkillIdList[index].Id,_gt.GetUI("PetInfoUI"),"tips",0,0,0,0,0)
		else
			return
		end
	elseif PetInfoUI.ShowType == 2 then
	
		local num = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetInfoUI.Key)
		local skills=GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetInfoUI.Key)
  
		if index < num then
			if skills[index] then
				-- local SkillDB = DB.GetOnceSkillByKey1(skills[index].id)
				Tips.CreateSkillId(skills[index].id,_gt.GetUI("PetInfoUI"),"tips",0,0,0,0,skills[index].performance)
			end
		end
	else
		index=index+1
		if index<=#PetInfoUI.skillDatas then
			-- local SkillDB = DB.GetOnceSkillByKey1(PetInfoUI.skillDatas[index].SkillId)
			Tips.CreateSkillId(PetInfoUI.skillDatas[index].SkillId,_gt.GetUI("PetInfoUI"),"tips",0,0,0,0,PetInfoUI.skillDatas[index].performance)
		end
	end
	
end

function PetInfoUI.OnEquipItemClick(guid) 
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "index"))
	if PetInfoUI.Key ~= nil then
		--当传入的为guid时
		if PetInfoUI.ShowType == 2 then
			local equipData =LD.GetItemDataByIndex(equipSiteData[index].site,item_container_type.item_container_pet_equip,PetInfoUI.Key)
			if equipData then
				local equipTips=Tips.CreateByItemData(equipData,_gt.GetUI("PetInfoUI"),"equipTips",200,20,50)
			end
		end
	else
		local equipData = PetInfoUI.petData.equips.items
		for i = 0, equipData.Length -1 do
			if index-1 == equipData[i].site then
		-- if equipData then
			test(tostring(PetInfoUI.petData.guid))
			local equipTips=Tips.CreateByItemData(equipData[i],_gt.GetUI("PetInfoUI"),"equipTips",200,20,50)
			end	
		end
	end
end

function PetInfoUI.AdjustForStalls(state,money_type,index,price,target_guid)--state：1为上架，2为下架 3 为购买
	if not state or not money_type then
		GUI.DestroyWnd("PetInfoUI")
		return
	end
	
	local Panel = _gt.GetUI("PetInfoUI")
	local Bg = GUI.GetChild(Panel,"center")
	GUI.SetPositionY(Panel,-40)
	GUI.SetHeight(Bg,581)
	GUI.SetPositionY(Bg,-50)
	

	local Text = GUI.CreateStatic(Panel, "Text", "出售价格", -70, 35, 300, 44);
	GUI.SetColor(Text, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Bottom);


	local ConfirmBtn = GUI.ButtonCreate(Panel, "ConfirmBtn", "1800402110", 200, 35, Transition.ColorTint, "", 115, 44, false)
	GUI.ButtonSetTextFontSize(ConfirmBtn, UIDefine.FontSizeL)
	GUI.ButtonSetTextColor(ConfirmBtn, UIDefine.BrownColor)
	GUI.RegisterUIEvent(ConfirmBtn, UCE.PointerClick, "PetInfoUI", "OnStallsConfirmBtn")
	UILayout.SetSameAnchorAndPivot(ConfirmBtn, UILayout.Bottom)
	GUI.SetData(ConfirmBtn,"state",state)
	if state == 1 then
		local PriceInput = GUI.EditCreate(Panel, "PriceInput", "1800400390", "请输入价格", 10, 35, Transition.ColorTint, "system", 250, 44, 8, 8, InputType.Standard, ContentType.IntegerNumber)
		UILayout.SetSameAnchorAndPivot(PriceInput, UILayout.Bottom);
		GUI.EditSetLabelAlignment(PriceInput, TextAnchor.MiddleCenter)
		GUI.EditSetTextColor(PriceInput, UIDefine.BrownColor)
		GUI.EditSetFontSize(PriceInput, UIDefine.FontSizeM)
		GUI.EditSetMaxCharNum(PriceInput, 9);
		_gt.BindName(PriceInput, "PriceInput")
		GUI.RegisterUIEvent(PriceInput, UCE.EndEdit, "PetInfoUI", "OnPriceInputEndEdit")
		
		local Coin = GUI.ImageCreate(PriceInput, "Coin", UIDefine.GetMoneyIcon(money_type), 5, -1, false, 36, 36)
		UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left)

		
		GUI.ButtonSetText(ConfirmBtn, "上架")
	elseif state == 2 then
		local PriceBg = GUI.ImageCreate(Panel, "PriceBg", "1800700010", 10, 35, false, 250, 44)
		UILayout.SetSameAnchorAndPivot(PriceBg, UILayout.Bottom);
		local Coin = GUI.ImageCreate(PriceBg, "Coin",  UIDefine.GetMoneyIcon(money_type), 2, -1, false, 36, 36)
		UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left)
		local Num = GUI.CreateStatic(PriceBg, "Num", price or "价格获取失败", 5, -1, 240, 30)
		GUI.SetColor(Num, UIDefine.WhiteColor)
		GUI.StaticSetFontSize(Num, UIDefine.FontSizeM)
		GUI.SetAnchor(Num, UIAnchor.Center)
		GUI.SetPivot(Num, UIAroundPivot.Center)
		GUI.StaticSetAlignment(Num, TextAnchor.MiddleCenter)	
	
		GUI.ButtonSetText(ConfirmBtn, "下架")
		GUI.SetData(ConfirmBtn,"index",index)
		-- GUI.SetData(ConfirmBtn,"price",price)
	elseif state == 3 then
		local PriceBg = GUI.ImageCreate(Panel, "PriceBg", "1800700010", 10, 35, false, 250, 44)
		UILayout.SetSameAnchorAndPivot(PriceBg, UILayout.Bottom);
		local Coin = GUI.ImageCreate(PriceBg, "Coin",  UIDefine.GetMoneyIcon(money_type), 2, -1, false, 36, 36)
		UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left)
		local Num = GUI.CreateStatic(PriceBg, "Num", price or "价格获取失败", 5, -1, 240, 30)
		-- GUI.SetColor(Num, UIDefine.WhiteColor)
		GUI.StaticSetFontSize(Num, UIDefine.FontSizeM)
		GUI.SetAnchor(Num, UIAnchor.Center)
		GUI.SetPivot(Num, UIAroundPivot.Center)
		GUI.StaticSetAlignment(Num, TextAnchor.MiddleCenter)	
		GUI.ButtonSetText(ConfirmBtn, "购买")
		local goldNum = tonumber(tostring(CL.GetAttr(UIDefine.MoneyTypes[money_type])))
		if goldNum >= tonumber(price) then
			GUI.SetColor(Num, UIDefine.WhiteColor)
		else
			GUI.SetColor(Num, UIDefine.RedColor)
		end
		GUI.SetData(ConfirmBtn,"index",index)
		GUI.SetData(ConfirmBtn,"target_guid",target_guid)
		-- GUI.SetData(ConfirmBtn,"price",price)
	end
end

function PetInfoUI.OnPriceInputEndEdit()
	local PriceInput = _gt.GetUI("PriceInput")
	local Price = GUI.EditGetTextM(PriceInput)
	
	if tonumber(Price) == 0 then
		GUI.EditSetTextM(PriceInput,1)
	end
	-- test()
end

function PetInfoUI.OnStallsConfirmBtn(guid)
	local btn = GUI.GetByGuid(guid)
	local state = tonumber(GUI.GetData(btn,"state"))
	if state == 1 then
		local PriceInput = _gt.GetUI("PriceInput")
		local price = tonumber(GUI.EditGetTextM(PriceInput))
		if price then
			local status = CL.GetIntCustomData("Stall_Status")
			if status ~= 1  then
				CL.SendNotify(NOTIFY.ShowBBMsg,"不在准备状态下无法进行上架操作")
				return
			end
			CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "Listing",2,PetInfoUI.Key,1,price)
		else
			CL.SendNotify(NOTIFY.ShowBBMsg,"价格不能为空！")
		end
	elseif state == 2 then
		local index = tonumber(GUI.GetData(btn,"index"))
		local status = CL.GetIntCustomData("Stall_Status")
		if status ~= 1 then
			CL.SendNotify(NOTIFY.ShowBBMsg,"不在准备状态下无法进行下架操作")
			return
		end
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "Retrieve",2,index)
	elseif state == 3 then
		local index = tonumber(GUI.GetData(btn,"index"))
		local target_guid = GUI.GetData(btn,"target_guid")
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "Buy",target_guid,2,index,1)
	end
end