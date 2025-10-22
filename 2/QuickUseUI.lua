local QuickUseUI = {}
_G.QuickUseUI = QuickUseUI


local _gt = UILayout.NewGUIDUtilTable();


local itemHeight =220;
local equipHeight=250;
local guard_height = 280
function QuickUseUI.Main(parameter)

  _gt = UILayout.NewGUIDUtilTable();
  local wnd = GUI.WndCreateWnd("QuickUseUI", "QuickUseUI", 0, 0,eCanvasGroup.Normal_Extend);

  local border = GUI.ImageCreate(wnd, "border", "1800400290", -220, -130, false, 220, itemHeight);
  GUI.SetAnchor(border, UIAnchor.BottomRight)
  GUI.SetPivot(border, UIAroundPivot.Bottom)
  GUI.SetVisible(border, false);
  _gt.BindName(border,"border")
  GUI.SetIsRaycastTarget(border,true);

  local itemIcon = ItemIcon.Create(border,"itemIcon",0,-65);
  GUI.SetAnchor(itemIcon, UIAnchor.Top)
  GUI.SetPivot(itemIcon, UIAroundPivot.Center)
  GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "QuickUseUI", "OnItemIconClick")

  local nameText = GUI.CreateStatic(border, "nameText", "名字", 0, -130, 220, 35);
  GUI.SetColor(nameText, UIDefine.GradeColor[1]);
  GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL);
  GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter);
  GUI.SetPivot(nameText, UIAroundPivot.Center)
  GUI.SetAnchor(nameText, UIAnchor.Top)

  local FightValue = GUI.ImageCreate(border,"FightValue","1800404020",-38,-38,false,58,38)
  GUI.SetPivot(FightValue, UIAroundPivot.Center)
  GUI.SetAnchor(FightValue, UIAnchor.Center)
  
  local FightValueText = GUI.CreateStatic(border, "FightValueText", "0", 30, -165, 220, 50);
  GUI.SetColor(FightValueText, UIDefine.Green7Color);
  GUI.StaticSetFontSize(FightValueText, UIDefine.FontSizeXXL);
  GUI.StaticSetAlignment(FightValueText, TextAnchor.MiddleCenter);
  GUI.SetPivot(FightValueText, UIAroundPivot.Center)
  GUI.SetAnchor(FightValueText, UIAnchor.Top)


  local closeBtn = GUI.ButtonCreate(border, "closeBtn", 1800302120, 2, 2, Transition.ColorTint, "", 50, 50, false);
  UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight);
  GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "QuickUseUI", "Next")

  local useBtn = GUI.ButtonCreate(border, "useBtn", 1800402110, 0, 15, Transition.ColorTint, "使用", 120, 50, false);
  UILayout.SetSameAnchorAndPivot(useBtn, UILayout.Bottom);
  GUI.ButtonSetTextColor(useBtn, UIDefine.BrownColor);
  GUI.ButtonSetTextFontSize(useBtn, UIDefine.FontSizeL)
  GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "QuickUseUI", "OnUseBtnClick")


  QuickUseUI.CreatePopup(wnd);

  QuickUseUI.InitData()
end

function QuickUseUI.CreatePopup(wnd)

  local popup = GUI.ButtonCreate(wnd,"popup", "1800400220", 0, 0, Transition.None, "", GUI.GetWidth(wnd),  GUI.GetHeight(wnd), false);
  UILayout.SetSameAnchorAndPivot(popup,UILayout.Center);
  GUI.SetColor(popup,UIDefine.Transparent);
  _gt.BindName(popup,"popup");
  GUI.SetVisible(popup,false);

  local panelBg=GUI.ImageCreate(popup,"panelBg","1800001120",0,0,false ,460,280);
  UILayout.SetSameAnchorAndPivot(panelBg,UILayout.Center);

  local itemIcon = ItemIcon.Create(panelBg,"itemIcon",0,-25)

  local flower=GUI.ImageCreate(panelBg,"flower","1800007060",-25,-25);
  UILayout.SetSameAnchorAndPivot(flower,UILayout.TopLeft);


  local titleBg=GUI.ImageCreate(panelBg,"titleBg","1800001030",0,25);
  UILayout.SetSameAnchorAndPivot(titleBg,UILayout.Top);

  local titleText = GUI.CreateStatic(titleBg,"titleText", "使用提示", 0, 1, 200, 35);
  GUI.SetColor(titleText,UIDefine.White3Color);
  GUI.StaticSetFontSize(titleText, UIDefine.FontSizeS);
  GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(titleText,UILayout.Center);
  _gt.BindName(titleText,"titleText");

  local closeBtn=GUI.ButtonCreate(panelBg,"closeBtn", "1800002050",-20,20, Transition.ColorTint);
  UILayout.SetSameAnchorAndPivot(closeBtn,UILayout.TopRight);
  GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "QuickUseUI", "OnPopupClose");
  _gt.BindName(closeBtn,"closeBtn");

  local msgText = GUI.RichEditCreate(panelBg,"msgText","测试",0,45,440,40);
  GUI.StaticSetAlignment(msgText, TextAnchor.MiddleCenter);
  GUI.StaticSetFontSize(msgText,UIDefine.FontSizeS);
  GUI.SetColor(msgText,UIDefine.BrownColor);
  _gt.BindName(msgText,"msgText");

  local useAllBtn=GUI.ButtonCreate(panelBg,"useAllBtn","1800002060",120,-20, Transition.ColorTint, "使用全部",130,45,false)
  UILayout.SetSameAnchorAndPivot(useAllBtn,UILayout.Bottom);
  GUI.ButtonSetTextColor(useAllBtn,UIDefine.WhiteColor);
  GUI.ButtonSetTextFontSize(useAllBtn,UIDefine.FontSizeL)
  GUI.SetIsOutLine(useAllBtn,true)
  GUI.SetOutLine_Color(useAllBtn,UIDefine.OutLine_BrownColor)
  GUI.SetOutLine_Distance(useAllBtn,UIDefine.OutLineDistance)
  GUI.RegisterUIEvent(useAllBtn, UCE.PointerClick, "QuickUseUI", "OnUseAllBtnClick");


  local useOneBtn=GUI.ButtonCreate(panelBg,"useOneBtn","1800002060",-120,-20, Transition.ColorTint, "只用一个",130,45,false)
  UILayout.SetSameAnchorAndPivot(useOneBtn,UILayout.Bottom);
  GUI.ButtonSetTextColor(useOneBtn,UIDefine.WhiteColor);
  GUI.ButtonSetTextFontSize(useOneBtn,UIDefine.FontSizeL)
  GUI.SetIsOutLine(useOneBtn,true)
  GUI.SetOutLine_Color(useOneBtn,UIDefine.OutLine_BrownColor)
  GUI.SetOutLine_Distance(useOneBtn,UIDefine.OutLineDistance)
  GUI.RegisterUIEvent(useOneBtn, UCE.PointerClick, "QuickUseUI", "OnUseOneBtnClick");
end

function  QuickUseUI.InitData()
    QuickUseUI.itemGuidList={};
  QuickUseUI.type=1;
end



function QuickUseUI.OnShow(parameter)
  local wnd = GUI.GetWnd("QuickUseUI");
  if wnd == nil then
    return;
  end

  CL.RegisterMessage(GM.RefreshBag, "QuickUseUI", "SetInfo");
  CL.RegisterMessage(GM.FightStateNtf, "QuickUseUI", "OnInFight");
  GUI.SetVisible(wnd, true);
end



function QuickUseUI.OnClose()
  CL.UnRegisterMessage(GM.RefreshBag, "QuickUseUI", "SetInfo");
end

-- 获取侍从所需要的碎片数量
QuickUseUI.getGuardNeedAmount = UIDefine.getGuardNeedAmount

function QuickUseUI.Add(itemGuid,PromoteFV)

  if not QuickUseUI.itemGuidList then
    table.insert(UIDefine.prompt_sequence.ui[4].stack,{itemGuid, PromoteFV})
    return
  end

  local itemIdStr=LD.GetItemAttrByGuid(ItemAttr_Native.Id,itemGuid);
  ---- 判断是否是侍从
  --local isGuard = false
  --if itemIdStr=="" then
  --  -- 如果默认物品背包中找不到此物品id，则进入侍从背包中查找
  --  itemIdStr = LD.GetItemAttrByGuid(ItemAttr_Native.Id,itemGuid,item_container_type.item_container_guard_bag)
  --  isGuard = true
  --  -- 如果还是没有则退出
    if itemIdStr == "" then
      return; end
  --end

  local itemId = tonumber(itemIdStr);
  local itemDB = DB.GetOnceItemByKey1(itemId);
  if itemDB.Id==0 then
    return;
  end

  if itemDB.JustUseIt~=1 then
    return;
  end

  if itemDB.Type == 1 then
	if PromoteFV then
		QuickUseUI.PromoteFV = PromoteFV
		QuickUseUI.AddItemGuid(itemGuid)
	else
		return
	end
  else
    -- 如果是侍从
    --if isGuard then
    --    -- 判断是否已经拥有此侍从，判断碎片数量是否足够
    --  local itemKeyName = itemDB.KeyName
    --  local guardKeyName = string.split(itemKeyName,"信物")[1]
    --  local guardId = DB.GetOnceGuardByKey2(guardKeyName).Id
    --  if not LD.IsHaveGuard(guardId) then -- 判断此侍从是否拥有
    --    if LD.GetItemCountById(itemId,item_container_type.item_container_guard_bag) >= QuickUseUI.getGuardNeedAmount then
    --      QuickUseUI.AddItemGuid(itemGuid)
    --    else
    --      return
    --    end
    --  else
    --    return
    --  end
    --else
      QuickUseUI.AddItemGuid(itemGuid)
    --end
  end
end

function QuickUseUI.AddItemGuid(itemGuid)
  -- 判断传入的是装备还是道具
  local item_id = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id,itemGuid));
  local item_type = nil
  if item_id ~= '' then item_type = DB.GetOnceItemByKey1(item_id).Type; end

  -- 这个分支： 如果快速使用的物品是不匹配的门派技能书，就直接不入栈了
  local itemDB = DB.GetOnceItemByKey1(item_id);
  if itemDB.Type == 2 and itemDB.Subtype == 22 then
    local job = CL.GetIntAttr(RoleAttr.RoleAttrJob1)
    if job ~= nil and job ~= itemDB.Job then
      return
    end
  end

  -- type == 1  是装备
  -- 去重
  for i = 1, #QuickUseUI.itemGuidList do
    if QuickUseUI.itemGuidList[i]==itemGuid then
      if item_type then
        if item_type > 1 then
          QuickUseUI.segmentation = QuickUseUI.segmentation - 1
        end
        table.remove(QuickUseUI.itemGuidList,i)
        if UIDefine.prompt_sequence then
          table.remove(UIDefine.prompt_sequence.ui[4].stack,i)
        end
      end
    end
  end

  -- 道具guid，道具guid(segmentation),装备guid
  -- 判断是否是第一次放入数据
  if next(QuickUseUI.itemGuidList) then
    if item_type then
      if item_type == 1 then
        -- 将数据存入
        table.insert(QuickUseUI.itemGuidList,itemGuid);
        if UIDefine.prompt_sequence then
          table.insert(UIDefine.prompt_sequence.ui[4].stack,item_id)
        end
      elseif item_type > 1 then
        if QuickUseUI.segmentation then
          QuickUseUI.segmentation = QuickUseUI.segmentation + 1
          table.insert(QuickUseUI.itemGuidList, QuickUseUI.segmentation, itemGuid);
          if UIDefine.prompt_sequence then
            table.insert(UIDefine.prompt_sequence.ui[4].stack, QuickUseUI.segmentation, item_id)
          end
        end
      end
    end
      -- 如果是第一次
  else
    -- 如果是装备，分割下标为0，如果是道具分割下标为1
    if item_type then
      if item_type == 1 then
        -- 设置分割下标
        QuickUseUI.segmentation = 0
      elseif item_type > 1 then
        -- 设置分割下标
        QuickUseUI.segmentation = 1
      end
      -- 将数据存入
      table.insert(QuickUseUI.itemGuidList,itemGuid);
      if UIDefine.prompt_sequence then
        table.insert(UIDefine.prompt_sequence.ui[4].stack,item_id)
      end
    end
  end
  -- 将待显示栈数据复制
  --UIDefine.prompt_sequence.ui[4].stack = QuickUseUI.itemGuidList

  
  if QuickUseUI.EquipUseTimer then
	QuickUseUI.EquipUseTimer:Stop()
  end
  
  QuickUseUI.SetInfo();
  local itemTips =_gt.GetUI("itemTips");
  if itemTips~=nil then
    GUI.Destroy(itemTips);
  end
end

function QuickUseUI.SetInfo()
  local border = _gt.GetUI("border");
  test(tostring(GlobalProcessing.EquipUseState))
  if GlobalProcessing.EquipUseState then
	  if QuickUseUI.itemGuidList == nil or #QuickUseUI.itemGuidList<=0 then
		GUI.SetVisible(border,false);
		return;
	  end

	  local itemGuid  =QuickUseUI.itemGuidList[#QuickUseUI.itemGuidList];
	  local itemIdStr=LD.GetItemAttrByGuid(ItemAttr_Native.Id,itemGuid);
	  --if itemIdStr=="" then
	  --  itemIdStr = LD.GetItemAttrByGuid(ItemAttr_Native.Id,itemGuid,item_container_type.item_container_guard_bag)
		if itemIdStr == "" then
		QuickUseUI.Next();
		return; end
	  --end

	  local itemId = tonumber(itemIdStr);
	  local itemDB = DB.GetOnceItemByKey1(itemId);
	  if itemDB.Id==0 then
		QuickUseUI.Next();
		return;
	  end


	  if itemDB.Type==1 then
		-- if GlobalUtils.CheckEqiupCanUse(itemDB) then
		local equipSite=LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
		local equipIdStr = LD.GetItemAttrByIndex(ItemAttr_Native.Id,equipSite,item_container_type.item_container_equip);
		if equipIdStr=="" or equipIdStr=="0"  then
		  QuickUseUI.SetEquipInfo(itemGuid,itemDB);
		  return;
		else
		  local equipId = tonumber(equipIdStr);
		  local equipData = DB.GetOnceItemByKey1(equipId);
		  if equipData.ArmorLevel~=2 and itemDB.ArmorLevel==2  then
			QuickUseUI.SetEquipInfo(itemGuid,itemDB);
			return;
		  elseif (equipData.ArmorLevel==2 and itemDB.ArmorLevel==2) or (equipData.ArmorLevel~=2 and itemDB.ArmorLevel~=2) then
			-- if itemDB.Level >= equipData.Level then
			QuickUseUI.SetEquipInfo(itemGuid,itemDB);
			return;
			-- else
			-- end
		  end
		end
		-- end
	  else
		QuickUseUI.SetItemInfo(itemGuid,itemDB);
		return;
	  end


		QuickUseUI.Next();
	else
		GUI.SetVisible(border,false)
	end
end

function QuickUseUI.SetEquipInfo(itemGuid,itemDB)
  QuickUseUI.type=1;
  local popup = _gt.GetUI("popup");
  GUI.SetVisible(popup,false);
  
  local border = _gt.GetUI("border");
  GUI.SetVisible(border,true);
  GUI.SetHeight(border,equipHeight);

  local itemIcon = GUI.GetChild(border,"itemIcon");
  local nameText = GUI.GetChild(border,"nameText");
  local FightValueText = GUI.GetChild(border,"FightValueText");
  local useBtn = GUI.GetChild(border,"useBtn");
  local FightValue = GUI.GetChild(border,"FightValue")

  ---- 隐藏激活侍从部分
  --local guard_activity_image = GUI.GetChild(border,"guard_activity_image")
  --if guard_activity_image then GUI.SetVisible(guard_activity_image,false) end

  ItemIcon.BindItemDB(itemIcon,itemDB)
  GUI.StaticSetText(nameText,itemDB.Name);
  GUI.SetColor(nameText,UIDefine.GradeColor[itemDB.Grade]);
  
  --绑定标志
	if LD.GetItemAttrByGuid(ItemAttr_Native.IsBound ,itemGuid) and LD.GetItemAttrByGuid(ItemAttr_Native.IsBound ,itemGuid) == "1" then
		GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,"1800707120")
	else
		GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.LeftTopSp,nil)
	end
  
  -- if itemDB.ArmorLevel==2 then
    -- GUI.StaticSetText(showTypeText,itemDB.Level.."级仙器")
  -- else
  
  GUI.ButtonSetText(useBtn,"装备")

  if itemDB.Type ==1 and QuickUseUI.PromoteFV then
	GUI.SetVisible(FightValueText,true)
	GUI.SetVisible(FightValue,true)
    GUI.StaticSetText(FightValueText,"+"..tostring(QuickUseUI.PromoteFV))
	QuickUseUI.EquipCountDown = 5
	if not QuickUseUI.EquipUseTimer then
	QuickUseUI.EquipUseTimer = Timer.New(QuickUseUI.EquipAutoUse,1,-1)
	end
	QuickUseUI.EquipUseTimer:Start()
  else
  	GUI.SetVisible(FightValueText,false)
	GUI.SetVisible(FightValue,false)
  end
  -- end

end

function QuickUseUI.EquipAutoUse()
	test("倒计时  "..QuickUseUI.EquipCountDown)
	if GlobalProcessing.EquipUseState then
		local border = _gt.GetUI("border")
		GUI.SetVisible(border,true)
		local useBtn = GUI.GetChild(border,"useBtn")
		GUI.ButtonSetText(useBtn,"装备( "..QuickUseUI.EquipCountDown.." )")
		if QuickUseUI.EquipCountDown ~= 0 then
			QuickUseUI.EquipCountDown = QuickUseUI.EquipCountDown -1
		else
      -- 打造出来的在装备前去掉tips
      if GUI.GetVisible(GUI.GetWnd("EquipUI")) and EquipProduceUI ~= nil and EquipProduceUI.NewItem == QuickUseUI.itemGuidList[#QuickUseUI.itemGuidList] then
        local panelBg = EquipUI.guidt.GetUI("panelBg")
        local newtips = GUI.GetChild(panelBg,"newtips")
        local itemtips = GUI.GetChild(panelBg,"itemtips")
        GUI.Destroy(newtips)
        GUI.Destroy(itemtips)
      end
			QuickUseUI.EquipUseTimer:Stop()
			QuickUseUI.OnUseBtnClick()
		end
	else
		local border = _gt.GetUI("border")
		GUI.SetVisible(border,false)
		QuickUseUI.EquipCountDown = 5
		QuickUseUI.EquipUseTimer:Stop()
	end
end

function QuickUseUI.SetItemInfo(itemGuid,itemDB)
  QuickUseUI.type=2;
  local popup = _gt.GetUI("popup");
  GUI.SetVisible(popup,false);

  local border = _gt.GetUI("border");
  GUI.SetVisible(border,true);

  local itemIcon = GUI.GetChild(border,"itemIcon");
  local nameText = GUI.GetChild(border,"nameText");
  local FightValue = GUI.GetChild(border,"FightValue")
  local FightValueText = GUI.GetChild(border,"FightValueText");
  local useBtn = GUI.GetChild(border,"useBtn");
  --local guard_activity_image = GUI.GetChild(border,"guard_activity_image")

  ItemIcon.BindItemDB(itemIcon,itemDB)
  GUI.SetColor(nameText,UIDefine.GradeColor[itemDB.Grade]);
  GUI.SetVisible(FightValueText,false);
  GUI.SetVisible(FightValue,false);
  ---- 如果是侍从
  --if itemDB.Type == 6 then
  --  GUI.SetHeight(border,guard_height)
  --  GUI.StaticSetText(nameText,string.split(itemDB.Name,'信物')[1]);
  --  if guard_activity_image == nil then
  --    guard_activity_image = GUI.ImageCreate(border,'guard_activity_image',"1801407230",0,-40,false,145,50)
  --    UILayout.SetSameAnchorAndPivot(guard_activity_image,UILayout.Center)
  --  else
  --    GUI.SetVisible(guard_activity_image,true)
  --  end
  --  GUI.ButtonSetText(useBtn,"点击激活");
  --else
    GUI.SetHeight(border, itemHeight);
    GUI.StaticSetText(nameText,itemDB.Name);
    GUI.ButtonSetText(useBtn,"使用");
    --if guard_activity_image then GUI.SetVisible(guard_activity_image,false) end

  --end
end

function QuickUseUI.OpenPopup()


  local border = _gt.GetUI("border");
  GUI.SetVisible(border,false);

  local popup = _gt.GetUI("popup");
  GUI.SetVisible(popup,true);

  local panelBg =GUI.GetChild(popup,"panelBg");
  local itemIcon =GUI.GetChild(panelBg,"itemIcon");
  local msgText =GUI.GetChild(panelBg,"msgText");

  local itemGuid  =QuickUseUI.itemGuidList[#QuickUseUI.itemGuidList];
  local itemId=tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id,itemGuid));
  local itemDB = DB.GetOnceItemByKey1(itemId);
  ItemIcon.BindItemGuid(itemIcon,itemGuid,item_container_type.item_container_bag,true);
  --local msg ="包裹中有 "..LD.GetItemAttrByGuid(ItemAttr_Native.Amount,itemGuid).." 个".."<color=#" ..UIDefine.GradeColorLabel[itemDB.Grade] .. ">" .. itemDB.Name .. "</color>，是否全部使用？";
  local msg ="包裹中有 "..LD.GetItemCountById(itemId).." 个".."<color=#" ..UIDefine.GradeColorLabel[itemDB.Grade] .. ">" .. itemDB.Name .. "</color>，是否全部使用？";
  GUI.StaticSetText(msgText,msg)

end

function QuickUseUI.OnUseAllBtnClick()

  local itemGuid  =QuickUseUI.itemGuidList[#QuickUseUI.itemGuidList];
  local inspect = require("inspect")


  local itemData= LD.GetItemDataByGuid(itemGuid);
  if itemData==nil then
    CL.SendNotify(NOTIFY.ShowBBMsg, "包裹中已无此道具")
    QuickUseUI.OnPopupClose()
    return;
  end
  local itemCount=LD.GetItemCount()
  --local itemTmpTable={}
  --从背包中使用其相同ID的物品
  for index = 0, itemCount-1 do
    local newItemData=LD.GetItemDataByItemIndex(index)
    if newItemData.id==itemData.id then
      GlobalUtils.UseAllItem(newItemData.guid)
    end
  end

  QuickUseUI.OnPopupClose()
end

function QuickUseUI.OnUseOneBtnClick()
  local itemGuid  =QuickUseUI.itemGuidList[#QuickUseUI.itemGuidList];
  local itemData= LD.GetItemDataByGuid(itemGuid);
  if itemData==nil then
    CL.SendNotify(NOTIFY.ShowBBMsg, "包裹中已无此道具")
    QuickUseUI.OnPopupClose()
    return;
  end

  GlobalUtils.UseItem(itemGuid)
  QuickUseUI.OnPopupClose()
end

function QuickUseUI.OnUseBtnClick(guid)
  local itemGuid  =QuickUseUI.itemGuidList[#QuickUseUI.itemGuidList];
  --暂时无法必现还原表QuickUseUI.itemGuidList内数据丢失原因，紧急处理为找不到该数据时return 2021.10.27
	if itemGuid == nil then
		QuickUseUI.Next();
		return ''
	end
  local itemData= LD.GetItemDataByGuid(itemGuid);
  --if itemData==nil then
  --  itemData = LD.GetItemDataByGuid(itemGuid,item_container_type.item_container_guard_bag)
    if itemData == nil then
    CL.SendNotify(NOTIFY.ShowBBMsg, "包裹中已无此道具")
    QuickUseUI.Next();
    return; end
  --end
  if QuickUseUI.type==1 then
    local dst = System.Enum.ToInt(item_container_type.item_container_equip);
	GlobalProcessing.PutOnEquip(itemGuid, dst)
    --CL.SendNotify(NOTIFY.MoveItem, itemGuid, dst);
  elseif QuickUseUI.type==2 then
    local amount=tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,itemGuid));
    --if amount == nil then
    --  amount = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,itemGuid,item_container_type.item_container_guard_bag))
    --end
    if amount>1 then
      local itemId=tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id,itemGuid));
      --if itemId == nil then itemId = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id,itemGuid,item_container_type.item_container_guard_bag)) end
      local itemDB = DB.GetOnceItemByKey1(itemId);
      if GlobalUtils.CheckCanUseAll(itemDB) then
        QuickUseUI.OpenPopup();
        return;
      end
    end
    GlobalUtils.UseItem(itemGuid);
  end

  QuickUseUI.Next();
end


function QuickUseUI.OnItemIconClick(guid)
  local itemTips =_gt.GetUI("itemTips");
  if itemTips~=nil then
    GUI.Destroy(itemTips);
    local itemTips2 =_gt.GetUI("itemTips2");
    GUI.Destroy(itemTips2);
    return;
  end

  local itemGuid  =QuickUseUI.itemGuidList[#QuickUseUI.itemGuidList];
  local itemData =LD.GetItemDataByGuid(itemGuid)

  local border =_gt.GetUI("border");

  if QuickUseUI.type == 1 then
    local itemDB = DB.GetOnceItemByKey1(itemData.id)
    local site = LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
    local itemTips = Tips.CreateByItemData(itemData, border, "itemTips", -408, 177, 50)
    UILayout.SetSameAnchorAndPivot(itemTips, UILayout.TopLeft)
    GUI.AddWhiteName(itemTips,guid)
    _gt.BindName(itemTips,"itemTips")
    local equipbtn = GUI.ButtonCreate(itemTips, "equipbtn", "1800402110", 0 , -15, Transition.ColorTint, "装备", 160, 50, false)
    UILayout.SetSameAnchorAndPivot(equipbtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(equipbtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(equipbtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(equipbtn,UCE.PointerClick,"QuickUseUI","OnUseBtnClick")
    local equip = LogicDefine.GetEquipBySite(site)
    if equip then
      local equipData = LD.GetItemDataByGuid(equip.guid,item_container_type.item_container_equip)
      local itemTips2 =  Tips.CreateByItemData(equipData, border, "itemTips2", -808, 177)
      UILayout.SetSameAnchorAndPivot(itemTips2, UILayout.TopLeft)
      local LeftTopImg = GUI.ImageCreate(itemTips2,"LeftTopImg","1800707290",0,0,true)
      GUI.AddWhiteName(itemTips2,guid)
      _gt.BindName(itemTips2,"itemTips2")
      -- 添加特技特效相关到白名单
      local itemInfoScr = GUI.GetChildByPath(itemTips,"InfoScr/InfoGroup")
      local itemInfoScr2 = GUI.GetChildByPath(itemTips2,"InfoScr/InfoGroup")
      local itemInfoCount = GUI.GetChildCount(itemInfoScr)
      local itemInfoCount2 = GUI.GetChildCount(itemInfoScr2)
      for i = 0, itemInfoCount - 1, 1 do
          local label = GUI.GetChildByIndex(itemInfoScr,i)
          if GUI.GetData(label,"SpecialEffect") or GUI.GetData(label,"StuntID") then
              GUI.AddWhiteName(itemTips2,GUI.GetGuid(label))
          end
      end
      for i = 0, itemInfoCount2 - 1, 1 do
          local label = GUI.GetChildByIndex(itemInfoScr2,i)
          if GUI.GetData(label,"SpecialEffect") or GUI.GetData(label,"StuntID") then
              GUI.AddWhiteName(itemTips,GUI.GetGuid(label))
          end
      end
      local t = {}
      local T = {}
      LogicDefine.GetItemDynAttrDataByMark(itemData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)
      LogicDefine.GetItemDynAttrDataByMark(equipData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, T)
      local InfoScr = GUI.GetChild(itemTips,"InfoScr")
      if #t > 0 and #T > 0 then
        for i = 1, #t, 1 do
          --获得提升的图片
          local attrName = t[i].name
          local UpImg = nil
          for j = 1, #t, 1 do
            local curUpImg = GUI.GetChild(InfoScr,"UpImg"..j)
            local label = GUI.GetParentElement(curUpImg)
            if string.find(GUI.StaticGetText(label),attrName) then
              UpImg = curUpImg
            end
          end
          local attrIndex = 0
          for j = 1, #T, 1 do
            if t[i].name == T[j].name then
              attrIndex = j
            end
          end
          if attrIndex == 0 then
            local value = tonumber(tostring(t[i].value))
            if value > 0 then
                GUI.ImageSetImageID(UpImg,"1800607060")
                GUI.SetVisible(UpImg,true)
            elseif value < 0 then
                GUI.ImageSetImageID(UpImg,"1800607070")
                GUI.SetVisible(UpImg,true)
            else
                GUI.SetVisible(UpImg,false)
            end
          else
            local value1 = tonumber(tostring(t[i].value))
            local value2 = tonumber(tostring(T[attrIndex].value))
            if value1 > value2 then
                GUI.ImageSetImageID(UpImg,"1800607060")
                GUI.SetVisible(UpImg,true)
            elseif  value1 < value2 then
                GUI.ImageSetImageID(UpImg,"1800607070")
                GUI.SetVisible(UpImg,true)
            elseif value1 == value2 then
                GUI.SetVisible(UpImg,false)
            end
          end
        end
      end
    else
      local t = {}
      LogicDefine.GetItemDynAttrDataByMark(itemData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)
      local InfoScr = GUI.GetChild(itemTips,"InfoScr")
      if #t > 0 then
        for i = 1, #t do
          --获得提升的图片
          local attrName = t[i].name
          local UpImg = nil
          for j = 1, #t, 1 do
            local curUpImg = GUI.GetChild(InfoScr,"UpImg"..j)
            local label = GUI.GetParentElement(curUpImg)
            if string.find(GUI.StaticGetText(label),attrName) then
              UpImg = curUpImg
            end
          end
          local value = tonumber(tostring(t[i].value))
          if value > 0 then
            GUI.ImageSetImageID(UpImg,"1800607060")
            GUI.SetVisible(UpImg,true)
          elseif value < 0 then
            GUI.ImageSetImageID(UpImg,"1800607070")
            GUI.SetVisible(UpImg,true)
          else
            GUI.SetVisible(UpImg,false)
          end
        end
      end
    end
  else
    local itemTips=Tips.CreateByItemData(itemData,border,"itemTips",-220,0)
    UILayout.SetSameAnchorAndPivot(itemTips, UILayout.BottomRight)
    GUI.AddWhiteName(itemTips,guid);
    _gt.BindName(itemTips,"itemTips")
  end
end

function QuickUseUI.Next()
  if QuickUseUI.EquipUseTimer then
	QuickUseUI.EquipUseTimer:Stop()
  end
  
  local border = _gt.GetUI("border");
  if #QuickUseUI.itemGuidList<=0 then
    GUI.SetVisible(border,false);
    return;
  end

    -- 如果不是武器，是道具，将'分割下标'移动
  if QuickUseUI.type and QuickUseUI.type > 1 then
    QuickUseUI.segmentation = QuickUseUI.segmentation - 1
  end

  -- 因为总是从最后一个取出，所以删除的就是最后一个,不需要考虑 '分割下标'
  table.remove(QuickUseUI.itemGuidList)
  if UIDefine.prompt_sequence then
    table.remove(UIDefine.prompt_sequence.ui[4].stack)
  end

  -- 将待显示栈数据复制
  --UIDefine.prompt_sequence.ui[4].stack = QuickUseUI.itemGuidList

  QuickUseUI.SetInfo()
end

function QuickUseUI.OnPopupClose()
  local popup = _gt.GetUI("popup");
  GUI.SetVisible(popup,false);

  QuickUseUI.Next();
end

function QuickUseUI.OnInFight(isfight)
	if isfight then
		QuickUseUI.OnPopupClose()	
	end
end