local PetPreviewUI = {}
--宠物合成结果预览UI
_G.PetPreviewUI = PetPreviewUI
local _gt = UILayout.NewGUIDUtilTable()

local PetGuid1 = nil
local PetGuid2 = nil
local itemIconBg = UIDefine.ItemIconBg;	
-- local PetSkillCount = 0
-- local PetSkill = nil

local petProperty = {
	[1] = { "血量资质", "PetAttrHpTalent", "1800408160", "1800408110", 120,"TalentHPMax","TalentHPMin" },
	[2] = { "物攻资质", "PetAttrPhyAtkTalent", "1800408160", "1800408110", 120,"TalentPhyAtkMax" ,"TalentPhyAtkMin"},		
	[3] = { "物防资质", "PetAttrPhyDefTalent", "1800408160", "1800408110", 120,"TalentPhyDefMax","TalentPhyDefMin" },
	[4] = { "法攻资质", "PetAttrMagAtkTalent", "1800408160", "1800408110", 120,"TalentMagAtkMax" ,"TalentMagAtkMin"},
	[5] = { "法防资质", "PetAttrMagDefTalent", "1800408160", "1800408110", 120,"TalentMagDefMax" ,"TalentMagDefMin"},		
	[6] = { "速度资质", "PetAttrSpeedTalent", "1800408160", "1800408110", 120,"TalentSpeedMax","TalentSpeedMin"},
	[7] = { "成  长  率", "PetAttrGrowthrate", "1800408160", "1800408110", 120,"GrowthRateMax","GrowthRateMin" },
	[8] = { "悟        性", "PetAttrSavvy", "1800408160", "1800408110", 120,"SavvyMax" ,"SavvyMin"}
}

function PetPreviewUI.Main(parameter)
	local panel = GUI.GetWnd("PetUI")
	
    local panelCover = GUI.ImageCreate(panel, "PetPreviewpanel", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    GUI.SetIsRaycastTarget(panelCover, true)
	panel:RegisterEvent(UCE.PointerClick)
	GUI.RegisterUIEvent(panelCover, UCE.PointerClick, "PetPreviewUI", "OnCloseBtnClick")
	

    local panelBg = GUI.ImageCreate(panelCover, "center", "1800600182", 0, 15, false, 600, 620)
	GUI.SetIsRaycastTarget(panelBg, true)
	_gt.BindName(panelBg,"PetPreviewpanel")
	panelBg:RegisterEvent(UCE.PointerClick)

    local topBarLeft = GUI.ImageCreate(panelBg, "topBarLeft", "1800600180", -150, -295, false, 300, 54)
    UILayout.SetAnchorAndPivot(topBarLeft, UIAnchor.Center, UIAroundPivot.Center)
	
    local topBarRight = GUI.ImageCreate(panelBg, "topBarRight", "1800600181", 150, -295, false, 300, 54)
    UILayout.SetAnchorAndPivot(topBarRight, UIAnchor.Center, UIAroundPivot.Center)

    local topBarCenter = GUI.ImageCreate(panelBg, "topBarCenter", "1800600190", 0, -295, false, 380, 50)
    UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Center, UIAroundPivot.Center)

    local tipLabel = GUI.CreateStatic(panelBg, "tipLabel", "合成结果预览", 0, 15, 200, 40)
    GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(tipLabel, UIDefine.BrownColor)
    UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)
    GUI.StaticSetFontSize(tipLabel, UIDefine.FontSizeL)
	_gt.BindName(tipLabel,"tipLabel")

	
	--模型背景
	local ModelBg = GUI.ImageCreate(panelBg, "ModelBg", "1800400230", -120, -150);
	UILayout.SetSameAnchorAndPivot(ModelBg, UILayout.Center);
	
	--模型
	local model = GUI.RawImageCreate(ModelBg, false, "model", "", 0, -30, 50, false, 360, 360)
    _gt.BindName(model, "model");
    model:RegisterEvent(UCE.Drag)
    GUI.AddToCamera(model);
    GUI.RawImageSetCameraConfig(model, "(1.65, 1.3, 2),(-0.04464257, 0.9316535, -0.1226545, -0.3390941), True, 5, 0.01, 1.25, 1E-05");
    model:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(model, UCE.PointerClick, "PetPreviewUI", "OnModelClick")
    local petModel = GUI.RawImageChildCreate(model, true, "petModel", "", 0, 0)
    _gt.BindName(petModel, "petModel");
    GUI.BindPrefabWithChild(model, GUI.GetGuid(petModel))
    GUI.RegisterUIEvent(petModel, ULE.AnimationCallBack, "PetPreviewUI", "OnAnimationCallBack")
	
	--阴影
	local Shadow = GUI.ImageCreate(panelBg, "Shadow", "1800400240", -120, -80);
	UILayout.SetSameAnchorAndPivot(Shadow, UILayout.Center)	
	
	--名称
	local NameArea = GUI.CreateStatic(panelBg, "NameArea", "名称", -240, -25, 160, 50);
	GUI.SetColor(NameArea, UIDefine.BrownColor)
	GUI.StaticSetFontSize(NameArea, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(NameArea, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(NameArea, UILayout.Center)

	local bg = GUI.ImageCreate(NameArea, "bg", "1800700010", 130, 2, false, 200, 35);
	UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)

	local NameText = GUI.CreateStatic(NameArea, "NameText", "小绵羊", 125, 0, 160, 50);
	GUI.SetColor(NameText, UIDefine.White2Color)
	GUI.StaticSetFontSize(NameText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(NameText, TextAnchor.MiddleCenter)
	_gt.BindName(NameText, "NameText")
	
	--名称
	local LevelArea = GUI.CreateStatic(panelBg, "LevelArea", "等级", -240,10, 160, 50);
	GUI.SetColor(LevelArea, UIDefine.BrownColor)
	GUI.StaticSetFontSize(LevelArea, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(LevelArea, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(LevelArea, UILayout.Center)

	local bg = GUI.ImageCreate(LevelArea, "bg", "1800700010", 130, 2, false, 200, 35);
	UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)

	local LevelText = GUI.CreateStatic(LevelArea, "LevelText", "1", 125, 0, 160, 50);
	GUI.SetColor(LevelText, UIDefine.White2Color)
	GUI.StaticSetFontSize(LevelText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(LevelText, TextAnchor.MiddleCenter)
	_gt.BindName(LevelText, "LevelText")
	
	--宠物类型
	local petTypeLabel = GUI.ImageCreate(panelBg, "petTypeLabel", "1800704020", -18, -210)
	_gt.BindName(petTypeLabel, "petTypeLabel")
	
	--绑定图片
	local PetBindLabel = GUI.ImageCreate(panelBg, "PetBindLabel", "1800707030", -240, -75)
	_gt.BindName(PetBindLabel, "PetBindLabel")
	
    local CloseBtn = GUI.ButtonCreate(panelBg, "CloseBtn", "1800302120", 0, -10, Transition.ColorTint)
    UILayout.SetAnchorAndPivot(CloseBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
	GUI.RegisterUIEvent(CloseBtn, UCE.PointerClick, "PetPreviewUI", "OnCloseBtnClick")	
	
	--属性面板
	PetPreviewUI.CreateAttrPanel(panelBg)
	
	--技能面板
	PetPreviewUI.CreateSkillPanel(panelBg)
	
	if parameter then
		PetPreviewUI.Refresh(parameter)
	end
end

function PetPreviewUI.OnModelClick()         --

	if PetGuid1 == nil then
		return
	end
	local petModel = GUI.GetByGuid(_gt.petModel);
	math.randomseed(os.time())
	local index = math.random(2)
	local movements = { eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1 }

	ModelItem.Bind(petModel, tonumber(PetPreviewUI.PetDB.Model),LD.GetPetIntAttr(RoleAttr.RoleAttrColor1,PetGuid1),0, movements[index])

end

function PetPreviewUI.OnAnimationCallBack(guid, action)   
	if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
		return
	end
	local petModel = GUI.GetByGuid(_gt.petModel);
	ModelItem.Bind(petModel, tonumber(PetPreviewUI.PetDB.Model),LD.GetPetIntAttr(RoleAttr.RoleAttrColor1,PetGuid1),0,eRoleMovement.ATTSTAND_W1)

end

function PetPreviewUI.Refresh(parameter)
	PetGuid1 = nil
	PetGuid2 = nil
	PetPreviewUI.PetDB = nil
	if parameter then
		parameter = string.split(parameter, ",")
		PetGuid1 = parameter[1]
		PetGuid2 = parameter[2]
	end

	if PetGuid1 ~= nil then
		local Id = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, PetGuid1)))
		PetPreviewUI.PetDB = DB.GetOncePetByKey1(Id)
		PetPreviewUI.RefreshInfoPanel()
		PetPreviewUI.RefreshAttrPanel()
		--刷新技能
		PetPreviewUI.RefreshSkillPanel()
	end
end

function PetPreviewUI.RefreshWithoutGuid2()
	local Titel = _gt.GetUI("tipLabel")
	GUI.StaticSetText(Titel,"宠物合成结果")
	local SkillTitel = _gt.GetUI("title")
	GUI.StaticSetText(SkillTitel,"宠物技能")
end


function PetPreviewUI.RefreshInfoPanel()
	local NameText = _gt.GetUI("NameText")
	local LevelText = _gt.GetUI("LevelText")
	local petTypeLabel = _gt.GetUI("petTypeLabel")
	local PetBindLabel = _gt.GetUI("PetBindLabel")
 	local petModel = _gt.GetUI("petModel")
	--基础信息
	local Name = LD.GetPetName(PetGuid1)
	GUI.StaticSetText(NameText,tostring(Name))
	-- local Level = UIDefine.GetPetLevelStrByGuid(PetGuid1)
	GUI.StaticSetText(LevelText,"1")
	GUI.ImageSetImageID(petTypeLabel, UIDefine.PetType[PetPreviewUI.PetDB.Type])
	
	--刷新模型
	if PetPreviewUI.PetDB ~= nil then
		ModelItem.Bind(petModel, tonumber(PetPreviewUI.PetDB.Model), tonumber(PetPreviewUI.PetDB.ColorId), 0, eRoleMovement.ATTSTAND_W1)
	end
	
	
	local isBind = LD.GetPetState(PetState.Bind, PetGuid1)
	if PetGuid2 ~= nil then 
		if not isBind then
			isBind = LD.GetPetState(PetState.Bind,PetGuid2)
		end
	else
		PetPreviewUI.RefreshWithoutGuid2()
	end
	
	GUI.SetVisible(PetBindLabel,isBind)
end

function PetPreviewUI.RefreshAttrPanel()
	local attrList = {1,2,3,4,5,6,7,8}
	for i = 1, #attrList do
		local data = petProperty[attrList[i]]
		local text = _gt.GetUI(data[2] .. "Text")
		local tempSlider = _gt.GetUI("tempSlider"..i)
		if i ~= 7 and i ~= 8 then
			GUI.StaticSetText(text,LD.GetPetIntAttr(RoleAttr[data[2]], PetGuid1) .. "/" ..LD.GetPetIntCustomAttr(data[6], PetGuid1))
			GUI.ScrollBarSetPos(tempSlider,(LD.GetPetIntAttr(RoleAttr[data[2]], PetGuid1))/(LD.GetPetIntCustomAttr(data[6], PetGuid1)))
		else
			GUI.StaticSetText(text,LD.GetPetIntAttr(RoleAttr[data[2]], PetGuid1) .. "/" ..PetPreviewUI.PetDB[data[6]])
			GUI.ScrollBarSetPos(tempSlider,(LD.GetPetIntAttr(RoleAttr[data[2]],PetGuid1))/(PetPreviewUI.PetDB[data[6]]))
		end		
	end
end


function PetPreviewUI.OnCloseBtnClick(key)
	local panel = GUI.Get("PetUI/PetPreviewpanel")
	GUI.Destroy(panel) 
end

function PetPreviewUI.CreateAttrPanel(panelBg)
	local AttributeBg = GUI.ImageCreate(panelBg,"AttributeBg", "1800400200", 145, -105,false, 260, 280);
	UILayout.SetSameAnchorAndPivot(AttributeBg, UILayout.Center)

	local attrList = {1,2,3,4,5,6,7,8}
	for i = 1, #attrList do
		local data = petProperty[attrList[i]]

		local Label = GUI.CreateStatic(AttributeBg, data[2] .. "Label", data[1], 15, 8+(i-1)*32 , 150, 50, "system", true, false)
		UILayout.SetSameAnchorAndPivot(Label, UILayout.TopLeft)
		GUI.StaticSetFontSize(Label, UIDefine.FontSizeM)
		GUI.SetColor(Label, UIDefine.BrownColor)

		local tempSlider = GUI.ScrollBarCreate(Label, data[2], "", data[3], data[4], 170, 0, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false,false)
		_gt.BindName(tempSlider,"tempSlider"..i)
			
		local silderFillSize = Vector2.New(data[5], 25)
		GUI.ScrollBarSetFillSize(tempSlider, silderFillSize)
		GUI.ScrollBarSetBgSize(tempSlider, silderFillSize)
		UILayout.SetSameAnchorAndPivot(tempSlider, UILayout.Left)
				
		local currentTxt = GUI.CreateStatic( tempSlider, data[2] .. "Text", "100/100", 0, 0, 150, 50, "system", true)
		UILayout.SetSameAnchorAndPivot(currentTxt, UILayout.Center)
		GUI.StaticSetFontSize(currentTxt, UIDefine.FontSizeS)
		GUI.StaticSetAlignment(currentTxt,TextAnchor.MiddleCenter)
		_gt.BindName(currentTxt,data[2] .. "Text")
	end

end

function PetPreviewUI.CreateSkillPanel(panelBg)
	local SkillBg = GUI.ImageCreate(panelBg,"SkillBg", "1800400200", 0, 170,false, 555, 250);
	UILayout.SetSameAnchorAndPivot(SkillBg, UILayout.Center)	

	local bar1 = GUI.ImageCreate(SkillBg,"bar1", "1800700150", 100, 25,  false, 200, 20);
	UILayout.SetAnchorAndPivot(bar1, UIAnchor.TopLeft, UIAroundPivot.Center)

	local bar2 = GUI.ImageCreate(SkillBg,"bar2", "1800700150", -100, 25, false, 200, 20);
	UILayout.SetAnchorAndPivot(bar2, UIAnchor.TopRight, UIAroundPivot.Center)
	GUI.SetEulerAngles(bar2, Vector3.New(0, -180, 0))

	local title = GUI.CreateStatic(SkillBg,"title", "技能可能情况", 0, 25, 200, 500, "system", true)
	UILayout.SetAnchorAndPivot(title, UIAnchor.Top, UIAroundPivot.Center)
	GUI.StaticSetAlignment(title,TextAnchor.MiddleCenter)
	GUI.StaticSetFontSize(title, UIDefine.FontSizeL)
	GUI.SetColor(title,UIDefine.BrownColor)
	_gt.BindName(title,"title")

	local SkillScroll = GUI.ScrollRectCreate(SkillBg,"SkillScroll", 7, 45, 540, 195, 0, false, Vector2.New(78, 78), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 6)
	UILayout.SetSameAnchorAndPivot(SkillScroll, UILayout.TopLeft)
	GUI.ScrollRectSetChildAnchor(SkillScroll,UIAnchor.Top)
	GUI.ScrollRectSetChildPivot(SkillScroll,UIAroundPivot.Top)
	GUI.ScrollRectSetChildSpacing(SkillScroll,Vector2.New(8, 8))
	
	for i = 1, 24 do
    -- 技能图标底图
		local SkillItem = GUI.ItemCtrlCreate(SkillScroll,"SkillItem" .. i, "1800400050", 1, 0)
		GUI.RegisterUIEvent(SkillItem, UCE.PointerClick, "PetPreviewUI", "OnSkillItemClick")	
		GUI.SetData(SkillItem,"Index",i)
		_gt.BindName(SkillItem,"SkillItem"..i)
	end
end

function PetPreviewUI.RefreshSkillPanel()
	local PetSkill = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetGuid1)
	local PetSkillCount = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetGuid1)
--记录下来主宠的突破技能是哪个
	local TempTable = {}
	for i= 0 , PetSkillCount - 1 do
		local star = LD.GetPetIntCustomAttr("PetStarLevel",PetGuid1,pet_container_type.pet_container_panel)
		for j = 1, star do
			local BreachSkillID = LD.GetPetIntCustomAttr("PetUpStar_Skill_"..j,PetGuid1,pet_container_type.pet_container_panel)
			if PetSkill[i].id == BreachSkillID then
				table.insert(TempTable,i)
			end
		end
	end
	if PetGuid2 ~= nil then
		local TempSkill = GlobalProcessing.GetPetSkillByGuidWithoutMounts(PetGuid2)
		local TempSkillCount = GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(PetGuid2)
		local mark = {}
		for i = 0, TempSkillCount-1 do
			-- local TempDB = DB.GetOnceSkillByKey1(TempSkill.id)
			local star = LD.GetPetIntCustomAttr("PetStarLevel",PetGuid2,pet_container_type.pet_container_panel)
			local flag =0
			for j= 1 ,star do
				if flag ~= 1 then
					local BreachSkillID = LD.GetPetIntCustomAttr("PetUpStar_Skill_"..j,PetGuid2,pet_container_type.pet_container_panel)
					if TempSkill[i].id == BreachSkillID then
						flag = 1
					end
				end
			end
			if flag ~= 1 then
				table.insert(mark,i)
			end
		end	
		test(#mark)
		if #mark > 0 then
			if PetSkillCount > 0 then
				local tempmark = {}
				for i= 1 , #mark do	
					local flag = 0
					for j =0 , PetSkillCount-1 do
						if flag ~= 1 then
							if PetSkill[j].id == TempSkill[mark[i]].id then
								flag = 1 
							end
						end
					end
					if flag ~= 1 then
						table.insert(tempmark,mark[i])
					end
				end
				if 	#tempmark > 0 then
					for i= 1 , #tempmark do
						table.insert(PetSkill,TempSkill[tempmark[i]])
						PetSkillCount = PetSkillCount+ 1
					end
				end
			else
				for i= 1 , #mark do
					table.insert(PetSkill,i-1,TempSkill[mark[i]])
					PetSkillCount = PetSkillCount+ 1
				end
			end
		end
	end

	
	
	
	for i =1 ,PetSkillCount do
		local SkillItem = _gt.GetUI("SkillItem"..i)
		local SkillDB = DB.GetOnceSkillByKey1(PetSkill[i-1].id)
		GUI.ItemCtrlSetElementValue(SkillItem,eItemIconElement.Icon,tostring(SkillDB.Icon))
		GUI.ItemCtrlSetElementRect(SkillItem,eItemIconElement.Icon,0,-1,69,69)
		GUI.ItemCtrlSetElementValue(SkillItem, eItemIconElement.Border, itemIconBg[SkillDB.SkillQuality])
		--宠物技能右下角等级

		if SkillDB.UpSkill == 1  then
			GUI.ItemCtrlSetElementValue(SkillItem, eItemIconElement.LeftBottomSp , 1800707140);
			GUI.ItemCtrlSetElementRect(SkillItem, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
		elseif SkillDB.UpSkill == 2  then
			GUI.ItemCtrlSetElementValue(SkillItem, eItemIconElement.LeftBottomSp , 1800707150);
			GUI.ItemCtrlSetElementRect(SkillItem, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
		elseif SkillDB.UpSkill == 3  then
			GUI.ItemCtrlSetElementValue(SkillItem, eItemIconElement.LeftBottomSp , 1800707160);
			GUI.ItemCtrlSetElementRect(SkillItem, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
		else
			GUI.ItemCtrlSetElementValue(SkillItem, eItemIconElement.LeftBottomSp , nil)
		end
	end
	
	--左上角必带标志
	if PetGuid2 ~= nil then
		if #TempTable > 0 then
			for i = 1 , #TempTable do
				local SkillItem = _gt.GetUI("SkillItem"..(TempTable[i]+1))
				GUI.ItemCtrlSetElementValue(SkillItem, eItemIconElement.LeftTopSp,"1800707130")
			end
		end
	else
		if #TempTable > 0 then
			for i = 1 , #TempTable do
				local SkillItem = _gt.GetUI("SkillItem"..(TempTable[i]+1))
				GUI.ItemCtrlSetElementValue(SkillItem, eItemIconElement.LeftTopSp,"1801507130")
			end
		end
	end
	--用于Tips的变量
	PetPreviewUI.PetSkillCount = PetSkillCount
	PetPreviewUI.PetSkills = PetSkill
end

function PetPreviewUI.OnSkillItemClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "Index"))
	if index <= PetPreviewUI.PetSkillCount then
		local Skills = PetPreviewUI.PetSkills
		Tips.CreateSkillId(Skills[index-1].id,_gt.GetUI("PetPreviewpanel"),"tips",0,0,0,0,Skills[index-1].performance)
	else
		return
	end
end


