local PetItem = {}
_G.PetItem = PetItem


function PetItem.Create(parent,name,x,y,w,h)
	if w == nil then
		w = 0
	end
	if h == nil then
		h = 0
	end
  local petItem = GUI.CheckBoxExCreate(parent, name, "1800700030", "1800700040", x, y, false, w, h)



  local icon = ItemIcon.Create(petItem, "icon", 15, 1)
  GUI.SetIsRaycastTarget(icon,false);
  UILayout.SetSameAnchorAndPivot(icon,UILayout.Left);
  GUI.SetToggleGroupGuid(petItem, GUI.GetGuid(parent))


  local nameText = GUI.CreateStatic(petItem, "nameText", "name", 105, -20, 170, 35)
  GUI.SetColor(nameText, UIDefine.BrownColor)
  GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(nameText,UILayout.Left);
  GUI.SetVisible(nameText,false)

  local levelText = GUI.CreateStatic(petItem, "levelText", "level", 105, 15, 170, 35)
  GUI.SetColor(levelText, UIDefine.Yellow2Color)
  GUI.StaticSetFontSize(levelText, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(levelText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(levelText,UILayout.Left)
  GUI.SetVisible(nameText,false)

  local lockLabel = GUI.ImageCreate(petItem,"lockLabel","1800707080",-100,20);
  UILayout.SetSameAnchorAndPivot(lockLabel,UILayout.Right)
  GUI.SetVisible(lockLabel,false)

  local petTypeLabel =GUI.ImageCreate(petItem,"petTypeLabel","1800704020",-15,0);
  UILayout.SetSameAnchorAndPivot(petTypeLabel,UILayout.Right);
  GUI.SetVisible(petTypeLabel,false)

  local bindLabel =GUI.ImageCreate(petItem,"bindLabel","1800707030",-60,-15);
  UILayout.SetSameAnchorAndPivot(bindLabel,UILayout.BottomRight);
  GUI.SetVisible(bindLabel,false)

  local LineupLabel =GUI.ImageCreate(petItem,"LineupLabel","1800707010",0,0);
  UILayout.SetSameAnchorAndPivot(LineupLabel,UILayout.TopLeft);
  GUI.SetVisible(LineupLabel,false)

  local MajorPetLabel = GUI.ImageCreate(petItem,"MajorPetLabel","1801207100",-55,-20);
  UILayout.SetSameAnchorAndPivot(MajorPetLabel, UILayout.Right)
  GUI.SetVisible(MajorPetLabel,false)

  local LineUpPet = GUI.ImageCreate(petItem,"LineUpPet","1800707350",30,0,true)
  UILayout.SetSameAnchorAndPivot(LineUpPet, UILayout.Left)
  GUI.SetVisible(LineUpPet,false)

  local lockText = GUI.CreateStatic(petItem, "lockText", "点击扩充格子", 105, 0, 170, 35)
  GUI.SetColor(lockText, UIDefine.BrownColor)
  GUI.StaticSetFontSize(lockText, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(lockText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(lockText,UILayout.Left);
  GUI.SetVisible(lockText,false)
  
  local GetMorePet = GUI.ImageCreate(petItem,"GetMorePet","1800707060",29,1,true)
  UILayout.SetSameAnchorAndPivot(GetMorePet, UILayout.Left)
  GUI.SetVisible(GetMorePet,false)
  
  local GetMoreText = GUI.CreateStatic(petItem, "GetMoreText", "获得更多宠物", 105, 0, 170, 35)
  GUI.SetColor(GetMoreText, UIDefine.BrownColor)
  GUI.StaticSetFontSize(GetMoreText, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(GetMoreText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(GetMoreText,UILayout.Left);
  GUI.SetVisible(GetMoreText,false)

  return petItem;
end



function PetItem.BindPetGuid(petItem,petGuid,type,gray,petGuid0)
  if type==nil then
    type= pet_container_type.pet_container_panel;
  end

  if petGuid==nil or tostring(petGuid)=="0" then
    PetItem.SetEmpty(petItem);
    return;
  end

  local petData = LD.GetPetData(petGuid,type)
  local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole,petGuid,type)));
  local petDB =DB.GetOncePetByKey1(petId);
  if petDB.Id==0 then
    PetItem.SetEmpty(petItem);
    return;
  end



  local icon = GUI.GetChild(petItem,"icon");
  ItemIcon.BindPetDB(icon,petDB)
  GUI.ItemCtrlSetIconGray(icon, gray ~= nil and gray)

  GUI.SetVisible(icon,true);
  GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Type])

  local starsBg = GUI.GetChild(icon,"starsBg")
  GUI.SetVisible(starsBg,true)
  local star =LD.GetPetIntCustomAttr("PetStarLevel",petGuid,type)
  UILayout.SetSmallStars(star, 6, icon)


  local nameText = GUI.GetChild(petItem,"nameText");
  GUI.SetVisible(nameText,true);
  GUI.StaticSetText(nameText,petData.name);
	
  local levelText = GUI.GetChild(petItem,"levelText");
  GUI.SetVisible(levelText,true);
  GUI.StaticSetText(levelText,"等级:"..UIDefine.GetPetLevelStrByGuid(petGuid,type));
  local petTypeLabel = GUI.GetChild(petItem,"petTypeLabel");
  GUI.SetVisible(petTypeLabel,true);
  GUI.ImageSetImageID(petTypeLabel,UIDefine.PetType[petDB.Type])
  local lockLabel = GUI.GetChild(petItem,"lockLabel")
  GUI.SetVisible(lockLabel,true);
  local isLock = LD.GetPetState(PetState.Lock, petGuid)
  if isLock then
	GUI.ImageSetImageID(lockLabel,"1800707020")
  else
	GUI.ImageSetImageID(lockLabel,"1800707080")
	GUI.SetVisible(lockLabel,false)
  end
  local bindLabel = GUI.GetChild(petItem,"bindLabel");
  local isBind=LD.GetPetState(PetState.Bind,petGuid,type)
  GUI.SetVisible(bindLabel,isBind);
  local LineupLabel = GUI.GetChild(petItem,"LineupLabel");
  local isLineup=LD.GetPetState(PetState.Lineup,petGuid,type)
  GUI.SetVisible(LineupLabel,isLineup);

  local lockText = GUI.GetChild(petItem,"lockText");
  GUI.SetVisible(lockText,false);

  if petGuid0 then
	  local MajorPetLabel = GUI.GetChild(petItem,"MajorPetLabel")
	  GUI.SetVisible(MajorPetLabel,false)
	  if LD.GetPetState(PetState.Lineup,petGuid) then
		GUI.SetVisible(MajorPetLabel,true)
		if tostring(petGuid) == petGuid0 then
		  GUI.ImageSetImageID(MajorPetLabel,"1801207100")
		else
		  GUI.ImageSetImageID(MajorPetLabel,"1801207110")
		end
	  end
  end

end

function PetItem.SetEmpty(petItem)

  local icon = GUI.GetChild(petItem,"icon");
  ItemIcon.SetEmpty(icon)


  local nameText = GUI.GetChild(petItem,"nameText");
  GUI.SetVisible(nameText,false);
  local levelText = GUI.GetChild(petItem,"levelText");
  GUI.SetVisible(levelText,false);
  local starsBg = GUI.GetChild(icon,"starsBg")
  GUI.SetVisible(starsBg,false)
  local petTypeLabel = GUI.GetChild(petItem,"petTypeLabel");
  GUI.SetVisible(petTypeLabel,false);
  local lockLabel = GUI.GetChild(petItem,"lockLabel");
  GUI.SetVisible(lockLabel,false);
  local bindLabel = GUI.GetChild(petItem,"bindLabel");
  GUI.SetVisible(bindLabel,false);
  local LineupLabel = GUI.GetChild(petItem,"LineupLabel");
  GUI.SetVisible(LineupLabel,false);
  local lockText = GUI.GetChild(petItem,"lockText");
  GUI.SetVisible(lockText,false);
  local MajorPetLabel = GUI.GetChild(petItem,"MajorPetLabel");
  GUI.SetVisible(MajorPetLabel,false);
end

function PetItem.SetLock(petItem)
  PetItem.SetEmpty(petItem)
  local icon = GUI.GetChild(petItem,"icon");
  ItemIcon.SetLock(icon)
  local lockText = GUI.GetChild(petItem,"lockText");
  GUI.SetVisible(lockText,true);
  local MajorPetLabel = GUI.GetChild(petItem,"MajorPetLabel");
  GUI.SetVisible(MajorPetLabel,false);
end