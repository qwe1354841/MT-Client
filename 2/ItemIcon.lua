local ItemIcon = {}
_G.ItemIcon = ItemIcon

local itemIconBg = UIDefine.ItemIconBg;
local petIconBg = UIDefine.PetItemIconBg3

function ItemIcon.Create(parent, name, x, y, w, h)
  if w == nil then
    w = 0;
  end

  if h == nil then
    h = 0;
  end
  local itemIcon = GUI.ItemCtrlCreate(parent, name, itemIconBg[1], x, y, w, h)
  return itemIcon;
end

function ItemIcon.BindIndexForBag(itemIcon, index, bagType)

  local capacity = LD.GetBagCapacity(bagType);

  if index < capacity then
    local itemData = LD.GetItemDataByIndex(index, bagType);
    if itemData ~= nil then
      ItemIcon.BindItemData(itemIcon, itemData);

      if bagType == item_container_type.item_container_equip then
        local itemDB = DB.GetOnceItemByKey1(itemData.id);
        if GlobalUtils.CheckEqiupCanUse(itemDB) then
          GUI.ItemCtrlSetIconGray(itemIcon,false);
        else
          GUI.ItemCtrlSetIconGray(itemIcon,true);
        end
      end
    else
      ItemIcon.SetEmpty(itemIcon);

      if bagType == item_container_type.item_container_equip then
        local bg = { "1800400530", "1800400620", "1800400630", "1800400640", "1800400650", "1800400660", "1800400670", "1800400680", "1800400690", "1800400700" }
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, "1800400050");
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, bg[index + 1]);
      end
    end
  else
    ItemIcon.SetLock(itemIcon)
  end

end

function ItemIcon.BindItemGuid(itemIcon,itemGuid,bagType,hideAmount)
  if bagType==nil then
    bagType= item_container_type.item_container_bag;
  end


  local itemData = LD.GetItemDataByGuid(itemGuid,bagType);
  if itemData==nil then
    itemData= LD.GetItemDataByGuid(itemGuid,item_container_type.item_container_gem_bag);
  end

  ItemIcon.BindItemData(itemIcon,itemData,hideAmount)
end


function ItemIcon.BindItemData(itemIcon, itemData, hideAmount)
  if itemIcon == nil then
    return ;
  end

  if itemData == nil then
    ItemIcon.SetEmpty(itemIcon);
    return ;
  end

  local itemDB = DB.GetOnceItemByKey1(itemData.id);

  if itemDB.Id == 0 then
    ItemIcon.SetEmpty(itemIcon);
    return ;
  end

  ItemIcon.BindItemDB(itemIcon, itemDB)

  --红色 蒙版
  --是装备
  if itemDB.Type == 1 then
    local naijiudu = itemData:GetIntCustomAttr("DurableNow")
    local naijiuduMax = itemData:GetIntCustomAttr("DurableMax")
    --test("AAA1:"..naijiudu)
   if itemDB.Subtype == 7 then --宠物特殊处理
       naijiudu = itemData:GetIntCustomAttr("EquipDurableVal")
       naijiuduMax = itemData:GetIntCustomAttr("EquipDurableMax")
       --test("AAA2:"..naijiudu)
   end
   --test("AAA:"..itemDB.KeyName..":naijiudu==========>"..naijiudu..",type="..itemDB.Type..",subtype="..itemDB.Subtype)
   if naijiuduMax and naijiuduMax == 0 then --无限耐久
      GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
   else
      if naijiudu <= 0 then
          GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, 1801300230);
          GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.IconMask, 0, 0,80,81);
      else
          GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
      end
   end
 else
      GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
 end


  local isBound = itemData:GetAttr(ItemAttr_Native.IsBound)
  if isBound == "1" then
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120);
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
  else
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil);
  end

 --耐久度为0 标记
  --是装备
  if itemDB.Type == 1 then
     local naijiudu = itemData:GetIntCustomAttr("DurableNow")
     local naijiuduMax = itemData:GetIntCustomAttr("DurableMax")
     --test("BBB1:"..naijiudu)
		if itemDB.Subtype == 7 then 	--宠物特殊处理
        naijiudu = itemData:GetIntCustomAttr("EquipDurableVal")
        naijiuduMax = itemData:GetIntCustomAttr("EquipDurableMax")
        --test("BBB2:"..naijiudu)
    end
    --test("BBB:"..itemDB.KeyName..":naijiudu==========>"..naijiudu..",type="..itemDB.Type..",subtype="..itemDB.Subtype)
    if naijiuduMax and naijiuduMax == 0 then --无限耐久
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
    else
      if naijiudu <= 0 then
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, 1800408430);
        GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.RightBottomSp, 0, 0,22,23);
      else
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
      end
    end
  else
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
  end
  

  --右上角（限时道具）

  if itemData.life~=0 then
    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.RightTopSp, 1800408710);
  else
    GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.RightTopSp, nil);
  end


  ----左下角（宠物装备）
  --GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftBottomSp, 1801208350);
  --GUI.ItemCtrlSetElementRect(itemIcon,eItemIconElement.LeftBottomSp, 5,6,37,37);

  if hideAmount == true then
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, 0);
  else
    local amount = itemData:GetAttr(ItemAttr_Native.Amount);
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, amount);
  end

  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Selected, 1800400280);
  GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Selected, 0, 0, 88, 88);
end
-- 设置itemIcon 带一个需要数量
function ItemIcon.BindItemIdWithNum(itemIcon, itemId, num)
  if itemIcon == nil then
    return
  end

  if itemId == nil or num==nil then
    ItemIcon.SetEmpty(itemIcon)
    return
  end

  ItemIcon.BindItemId(itemIcon,itemId)
  local numItem = GUI.ItemCtrlGetElement(itemIcon, eItemIconElement.RightBottomNum)
  local curnum = LD.GetItemCountById(itemId, item_container_type.item_container_bag)
  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, curnum .. "/" .. num)
  if curnum < num then
    GUI.SetColor(numItem, UIDefine.RedColor)
  else
    GUI.SetColor(numItem, UIDefine.WhiteColor)
  end
end
function ItemIcon.BindItemId(itemIcon, itemId)
  if itemIcon == nil then
    return
  end

  if itemId == nil then
    ItemIcon.SetEmpty(itemIcon)
    return
  end

  local itemDB = DB.GetOnceItemByKey1(itemId)
  ItemIcon.BindItemDB(itemIcon, itemDB)
end

function ItemIcon.BindItemKeyName(itemIcon, keyName)
  if itemIcon == nil then
    return
  end

  if keyName == nil then
    ItemIcon.SetEmpty(itemIcon)
    return
  end

  local itemDB = DB.GetOnceItemByKey2(keyName)
  ItemIcon.BindItemDB(itemIcon, itemDB)
end

function ItemIcon.BindItemKeyNameWithBind(itemIcon, keyName,bind)
  if itemIcon == nil then
    return
  end

  if keyName == nil then
    ItemIcon.SetEmpty(itemIcon)
    return
  end

  local itemDB = DB.GetOnceItemByKey2(keyName)
  ItemIcon.BindItemDB(itemIcon, itemDB)
  if bind==1 then
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120);
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
  else
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil);
  end

end

function ItemIcon.BindItemDB(itemIcon, itemDB)
	if itemIcon == nil then
		return
	end
	ItemIcon.SetEmpty(itemIcon)
	if itemDB==nil or itemDB.Id == 0 then
		return
	end
	GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, itemIconBg[itemDB.Grade])
	GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, itemDB.Icon)
	if itemDB.Type==2 and itemDB.Subtype==42 then
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,70,70)
	elseif  (itemDB.Type==6 and itemDB.Subtype==0) or itemDB.Type==2 and itemDB.Subtype==8 then
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,70,70)
	elseif itemDB.Type == 2 and itemDB.Subtype == 15 and itemDB.ShowType == "宠物" then
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,70,70)
	else
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60)
	end
	
	GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, 0)
	
	if itemDB.BindType == 1 then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120)
	else
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil)
	end
	if itemDB.Type == 1 and itemDB.Subtype==7 then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp, 1801208350)
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 4, 6)
	else
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil)
	end
end


function ItemIcon.BindPetData(itemIcon, petData)

  if itemIcon == nil then
    return ;
  end

  ItemIcon.SetEmpty(itemIcon);
  if petData==nil then
    return;
  end

  local petId = tonumber(tostring(petData:GetAttr(RoleAttr.RoleAttrRole)))
  ItemIcon.BindPetId(itemIcon, petId)

end

function ItemIcon.BindPetId(itemIcon, petId)

  if itemIcon == nil then
    return ;
  end

  ItemIcon.SetEmpty(itemIcon);
  if petId==nil then
    return;
  end

  local petDB = DB.GetOncePetByKey1(petId);
  ItemIcon.BindPetDB(itemIcon, petDB)

end

function ItemIcon.BindPetKeyName(itemIcon, keyName)

  if itemIcon == nil then
    return ;
  end

  ItemIcon.SetEmpty(itemIcon);
  if keyName==nil then
    return;
  end

  local petDB = DB.GetOncePetByKey2(keyName);
  ItemIcon.BindPetDB(itemIcon, petDB)

end

function ItemIcon.BindGuardKeyName(itemIcon, keyName)

  if itemIcon == nil then
    return ;
  end

  ItemIcon.SetEmpty(itemIcon);
  if keyName==nil then
    return;
  end

  local petDB = DB.GetOnceGuardByKey2(keyName);
  ItemIcon.BindGuardDB(itemIcon, petDB)

end

function ItemIcon.BindPetDB(itemIcon, petDB)
  if itemIcon == nil then
    return
  end
  
  ItemIcon.SetEmpty(itemIcon)

  if petDB==nil then
    return;
  end
  
  if petDB.Id ~= 0 then
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, petIconBg[petDB.Grade]);
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, tostring(petDB.Head));
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1, 70, 70);
  end

end

function ItemIcon.BindGuardDB(itemIcon, guardDB)
  if itemIcon == nil then
    return
  end
  
  ItemIcon.SetEmpty(itemIcon)

  if guardDB==nil then
    return;
  end
  
  if guardDB.Id ~= 0 then
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, itemIconBg[guardDB.Grade]);
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, tostring(guardDB.Head));
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1, 70, 70);
  end

end

function ItemIcon.BindSkillKeyName(itemIcon,skillKeyName)
  if itemIcon == nil then
    return
  end

  local skillDB = DB.GetOnceSkillByKey2(skillKeyName);
  ItemIcon.BindSkillDB(itemIcon,skillDB)
end
function ItemIcon.BindSkillId(itemIcon,skillId)
  if itemIcon == nil then
    return
  end

  local skillDB = DB.GetOnceSkillByKey1(skillId);
  ItemIcon.BindSkillDB(itemIcon,skillDB)
end

function ItemIcon.BindSkillDB(itemIcon,skillDB)
  if itemIcon == nil then
    return
  end

  if skillDB.Id==0 or skillDB.SubType == 14 then
    ItemIcon.SetEmpty(itemIcon);
    return;
  end

  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, itemIconBg[skillDB.SkillQuality]);
  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, tostring(skillDB.Icon))
  GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1, 70, 70);


end


--使用LogicDefine.GetPetSkill(PetData)得到的skillDataEx
function ItemIcon.BindPetSkill(itemIcon, skillDataEx)
  if itemIcon == nil then
    return
  end

  local skillId = skillDataEx.SkillId;
  ItemIcon.BindSkillId(itemIcon,skillId)


  local icon  = GUI.ItemCtrlGetElement(itemIcon,eItemIconElement.Icon)
  if skillDataEx.SkillData.enable==1 then
    GUI.ImageSetGray(icon,false);
  else
    GUI.ImageSetGray(icon,true);
  end

	if skillDataEx.SkillData.bind == 1 then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 44, 45);	
	else
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil);
	end
	
	--宠物技能右下角等级
	local skillDB = DB.GetOnceSkillByKey1(skillId)
	--test(skillDB.UpSkill)
	if skillDB.UpSkill == 1  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1800707140);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	elseif skillDB.UpSkill == 2  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1800707150);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	elseif skillDB.UpSkill == 3  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1800707160);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	elseif skillDB.UpSkill == 4  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1801718014);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	elseif skillDB.UpSkill == 5  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1801718015);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	elseif skillDB.UpSkill == 6  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1801718016);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	elseif skillDB.UpSkill == 7  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1801718017);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	elseif skillDB.UpSkill == 8  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1801718018);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	elseif skillDB.UpSkill == 9  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1801718019);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	elseif skillDB.UpSkill == 10  then
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , 1801718020);
		GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftBottomSp, 60, 8, 15, 22)
	else
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp , nil)
	end
--[[
  if skillDataEx.Type==1 then
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800601110);
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 50, 50);

    local ltSp = GUI.ItemCtrlGetElement(itemIcon, eItemIconElement.LeftTopSp);
    local innateText = GUI.GetChild(ltSp, "innateText")
    if innateText == nil then
      innateText = GUI.CreateStatic(ltSp, "innateText", "天生", -6, -7, 50, 30);
      GUI.SetColor(innateText, UIDefine.WhiteColor);
      GUI.StaticSetFontSize(innateText, 14)
      GUI.StaticSetAlignment(innateText, TextAnchor.MiddleCenter)
      UILayout.SetSameAnchorAndPivot(innateText, UILayout.Center);
      GUI.SetEulerAngles(innateText, Vector3.New(0, 0, 45));
    else
      GUI.SetVisible(innateText,true);
      GUI.StaticSetText(innateText,"天生")
    end
  elseif skillDataEx.Type==3 then
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800601110);
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 50, 50);

    local ltSp = GUI.ItemCtrlGetElement(itemIcon, eItemIconElement.LeftTopSp);
    local innateText = GUI.GetChild(ltSp, "innateText")
    if innateText == nil then
      innateText = GUI.CreateStatic(ltSp, "innateText", "内丹", -6, -7, 50, 30);
      GUI.SetColor(innateText, UIDefine.WhiteColor);
      GUI.StaticSetFontSize(innateText, 14)
      GUI.StaticSetAlignment(innateText, TextAnchor.MiddleCenter)
      UILayout.SetSameAnchorAndPivot(innateText, UILayout.Center);
      GUI.SetEulerAngles(innateText, Vector3.New(0, 0, 45));
    else
      GUI.SetVisible(innateText,true);
      GUI.StaticSetText(innateText,"内丹")
    end
  else
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil);
  end
--]]

  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Selected, 1800400280);
  GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Selected, 0, 0, 88, 88);
end

function ItemIcon.BindSkill(itemIcon, skillData)
  if itemIcon == nil then
    return
  end

  local skillId = skillData.id;
  ItemIcon.BindSkillId(itemIcon,skillId)
end

function ItemIcon.SetEmpty(itemIcon)

  GUI.ItemCtrlSetIconGray(itemIcon,false);
  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, itemIconBg[1]);

  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, nil);
  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.IconMask, nil);
  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil);

  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightTopSp, nil);

  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftBottomSp, nil);

  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, 0);
  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomSp, nil);
  GUI.ItemCtrlUnSelect(itemIcon);
end


function ItemIcon.SetAddState(itemIcon)
  ItemIcon.SetEmpty(itemIcon)
  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1800707060");
  GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1, 50, 50);
end

function ItemIcon.SetLock(itemIcon)
  if itemIcon==nil then
    return;
  end

  ItemIcon.SetEmpty(itemIcon)
  GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, 1800400070);
  GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, 0, 75, 75);
end

function ItemIcon.BindGuardEquip(itemIcon, guid, site)
  local itemData = LD.GetItemDataByIndex(site, item_container_type.item_container_guard_equip, guid)
  if itemData ~= nil then
    ItemIcon.BindItemData(itemIcon, itemData);
    --print("ItemIcon.BindGuardEquip(itemIcon, guid, site)", site)
  else
    ItemIcon.SetEmpty(itemIcon);
    local bg = { "1800400530", "1800400620", "1800400630", "1800400640", "1800400650", "1800400660", "1800400670", "1800400680", "1800400690", "1800400700" }
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, "1800400050");
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, bg[site + 1])
  end
end