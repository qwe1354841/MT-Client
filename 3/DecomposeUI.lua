local DecomposeUI = {}
_G.DecomposeUI = DecomposeUI

local _gt = UILayout.NewGUIDUtilTable();

function DecomposeUI.Main(parameter)
  _gt = UILayout.NewGUIDUtilTable();
  local wnd = GUI.WndCreateWnd("DecomposeUI", "DecomposeUI", 0, 0);

  local panelBg = UILayout.CreateFrame_WndStyle2(wnd, "物品分解", 770,500,"DecomposeUI", "OnExit", _gt,true);

  local leftBg = GUI.ImageCreate(panelBg, "leftBg", "1800400010", -185, 8, false, 360, 325);
  local title = GUI.ImageCreate(leftBg, "title", "1800400420", 0, -35);
  UILayout.SetSameAnchorAndPivot(title, UILayout.Top);
  local text = GUI.CreateStatic(title, "text", "我的包裹", 0, 0, 150, 35);
  GUI.StaticSetFontSize(text, UIDefine.FontSizeM);
  GUI.SetColor(text, UIDefine.BrownColor);
  GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);

  local itemScroll = GUI.LoopScrollRectCreate(leftBg, "itemScroll", 0, 10, 350, 305,
      "DecomposeUI", "CreateItemIconPool", "DecomposeUI", "RefreshItemScroll", 0, false, Vector2.New(80, 80), 4, UIAroundPivot.Top, UIAnchor.Top);
  GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(6, 5));
  UILayout.SetSameAnchorAndPivot(itemScroll, UILayout.Top);
  _gt.BindName(itemScroll, "itemScroll");


  local rightBg = GUI.ImageCreate(panelBg, "rightBg", "1800400010", 185, 8, false, 360, 325);
  local title = GUI.ImageCreate(rightBg, "title", "1800400420", 0, -35);
  UILayout.SetSameAnchorAndPivot(title, UILayout.Top);
  local text = GUI.CreateStatic(title, "text", "分解预览", 0, 0, 150, 35);
  GUI.StaticSetFontSize(text, UIDefine.FontSizeM);
  GUI.SetColor(text, UIDefine.BrownColor);
  GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);

  local previewScroll = GUI.LoopScrollRectCreate(rightBg, "previewScroll", 0, 10, 350, 305,
      "DecomposeUI", "CreatePreviewItem", "DecomposeUI", "RefreshPreviewScroll", 0, false, Vector2.New(335, 100), 1, UIAroundPivot.Top, UIAnchor.Top);
  GUI.ScrollRectSetChildSpacing(previewScroll, Vector2.New(1, 1));
  UILayout.SetSameAnchorAndPivot(previewScroll, UILayout.Top);
  _gt.BindName(previewScroll, "previewScroll");


  local costArea= UILayout.CreateAttrBar(panelBg,"costArea",-160,-30,200,UILayout.Bottom)
  local text1 = GUI.CreateStatic(costArea, "text1", "分解花费", -105, 0, 100, 35);
  GUI.SetColor(text1,UIDefine.BrownColor);
  GUI.StaticSetFontSize(text1, UIDefine.FontSizeM);
  GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(text1, UILayout.Left);
  _gt.BindName(costArea, "costArea");


  local selectAllBtn = GUI.ButtonCreate(panelBg, "selectAllBtn", "1800402080", -185, -25, Transition.ColorTint, "选择全部", 150, 47, false);
  GUI.SetIsOutLine(selectAllBtn, true);
  GUI.ButtonSetTextFontSize(selectAllBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(selectAllBtn, UIDefine.WhiteColor);
  GUI.SetOutLine_Color(selectAllBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(selectAllBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(selectAllBtn, UCE.PointerClick, "DecomposeUI", "OnSelectAllBtnClick");
  UILayout.SetSameAnchorAndPivot(selectAllBtn, UILayout.BottomRight);
  _gt.BindName(selectAllBtn, "selectAllBtn");

  local decomposeBtn = GUI.ButtonCreate(panelBg, "decomposeBtn", "1800402080", -25, -25, Transition.ColorTint, "分解", 150, 47, false);
  GUI.SetIsOutLine(decomposeBtn, true);
  GUI.ButtonSetTextFontSize(decomposeBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(decomposeBtn, UIDefine.WhiteColor);
  GUI.SetOutLine_Color(decomposeBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(decomposeBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(decomposeBtn, UCE.PointerClick, "DecomposeUI", "OnDecomposeBtnClick");
  UILayout.SetSameAnchorAndPivot(decomposeBtn, UILayout.BottomRight);

  DecomposeUI.InitData()
  CL.SendNotify(NOTIFY.SubmitForm, "FormItemDisinOrCompo", "GetConfig")

end


function DecomposeUI.InitData()
  DecomposeUI.config=nil
  DecomposeUI.moneyType=nil;
  DecomposeUI.selectNums={};
  DecomposeUI.itemGuids={}
  DecomposeUI.isSelectAll=false;

  DecomposeUI.previewItemData={};
  DecomposeUI.previewBindItemData={};
end

function DecomposeUI.OnShow(parameter)
  local wnd = GUI.GetWnd("DecomposeUI");
  if wnd == nil then
    return ;
  end
  GUI.SetVisible(wnd, true);
  CL.RegisterMessage(GM.RefreshBag, "DecomposeUI", "RefreshEx");


  DecomposeUI.RefreshEx()
end

function DecomposeUI.GetConfig(table,moneyType)
  if CL.GetMode() == 1 then
    local inspect = require("inspect")
    print(inspect(table))
    print("moneyType:"..moneyType)
  end
  DecomposeUI.config=table
  DecomposeUI.moneyType=moneyType

  DecomposeUI.RefreshEx()
end

function DecomposeUI.OnExit()
  GUI.CloseWnd("DecomposeUI");
end

function DecomposeUI.OnClose()
  CL.UnRegisterMessage(GM.RefreshBag, "DecomposeUI", "RefreshEx");
end

function DecomposeUI.RefreshEx()
  if DecomposeUI.config==nil then
    return;
  end

  DecomposeUI.selectNums={};
  DecomposeUI.isSelectAll=false;

  DecomposeUI.itemGuids={}
  local count = LD.GetItemCount()
  for i = 0, count - 1 do
    local itemGuid = LD.GetItemGuidByItemIndex(i);
    local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid);
    local itemDB = DB.GetOnceItemByKey1(itemId);
    if DecomposeUI.config[itemDB.KeyName]~=nil then
      table.insert(DecomposeUI.itemGuids,itemGuid);
    end
  end

  DecomposeUI.Refresh();
end


function DecomposeUI.Refresh()

  local selectAllBtn =_gt.GetUI("selectAllBtn");
  if DecomposeUI.isSelectAll then
    GUI.ButtonSetText(selectAllBtn,"取消选中")
  else
    GUI.ButtonSetText(selectAllBtn,"选中全部")
  end


  local itemScroll = _gt.GetUI("itemScroll")
  GUI.LoopScrollRectSetTotalCount(itemScroll, #DecomposeUI.itemGuids >= 16 and #DecomposeUI.itemGuids or 16);
  GUI.LoopScrollRectRefreshCells(itemScroll);

  local totalCost=0;
  local itemList={};
  local bindItemList={}
  for k, v in pairs(DecomposeUI.selectNums) do
    local itemId=tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id,k))
    local itemDB = DB.GetOnceItemByKey1(itemId)
    local configData = DecomposeUI.config[itemDB.KeyName]
    if configData then
      if v~=nil and v>0 then
        totalCost=totalCost+configData.MoneyVal*v;
        local isBind=tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,k))
        if isBind==0 then
          for i = 1, #configData.itemList do
            local keyName = configData.itemList[i].KeyName;
            local min =  configData.itemList[i].Min;
            local max =  configData.itemList[i].Max;
            if itemList[keyName]==nil then
              itemList[keyName]={Min=min,Max=max};
            else
              itemList[keyName].Min =itemList[keyName].Min+min;
              itemList[keyName].Max =itemList[keyName].Max+max;
            end
          end
        elseif isBind==1 then
          for i = 1, #configData.itemList do
            local keyName = configData.itemList[i].KeyName;
            local min =  configData.itemList[i].Min;
            local max =  configData.itemList[i].Max;
            if bindItemList[keyName]==nil then
              bindItemList[keyName]={Min=min,Max=max};
            else
              bindItemList[keyName].Min =bindItemList[keyName].Min+min;
              bindItemList[keyName].Max =bindItemList[keyName].Max+max;
            end
          end
        end
      end
    end
  end

  DecomposeUI.previewItemData={};
  for k, v in pairs(itemList) do
    table.insert(DecomposeUI.previewItemData,{KeyName=k,Min=v.Min,Max=v.Max});
  end
  DecomposeUI.previewBindItemData={};
  for k, v in pairs(bindItemList) do
    table.insert(DecomposeUI.previewBindItemData,{KeyName=k,Min=v.Min,Max=v.Max});
  end
  local previewScroll = _gt.GetUI("previewScroll")
  GUI.LoopScrollRectSetTotalCount(previewScroll, #DecomposeUI.previewItemData+#DecomposeUI.previewBindItemData);
  GUI.LoopScrollRectRefreshCells(previewScroll);

  local costArea = _gt.GetUI("costArea")

  UILayout.RefreshAttrBar(costArea,UIDefine.GetMoneyEnum(DecomposeUI.moneyType),totalCost)
end


function DecomposeUI.OnDecomposeBtnClick()

  local count=0;
  local str=nil;
  for k, v in pairs(DecomposeUI.selectNums) do
    if v~=nil and v>0 then
      count=count+1;
      if count==1 then
        str=tostring(k)..","..v;
      else
        str=str..","..tostring(k)..","..v;
      end
    end

  end

  print(str);
  print(count)

  if count>0 then
    CL.SendNotify(NOTIFY.SubmitForm, "FormItemDisinOrCompo", "Disintegrate",str,count)
  else
    CL.SendNotify(NOTIFY.ShowBBMsg,"未选中任何道具")
  end
end


function DecomposeUI.OnSelectAllBtnClick()
  if DecomposeUI.isSelectAll then
    DecomposeUI.isSelectAll=false;
    DecomposeUI.selectNums={};
  else
    DecomposeUI.isSelectAll=true;
    DecomposeUI.selectNums={};
    for i = 1, #DecomposeUI.itemGuids do
      local itemGuid = DecomposeUI.itemGuids[i]
      local amount=tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,itemGuid))
      DecomposeUI.selectNums[itemGuid]=amount;
    end
  end
  DecomposeUI.Refresh();
end

function DecomposeUI.CreateItemIconPool()
  local itemScroll = _gt.GetUI("itemScroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll);
  local itemicon = ItemIcon.Create(itemScroll, "itemIcon"..curCount, 0, 0)
  GUI.RegisterUIEvent(itemicon, UCE.PointerClick, "DecomposeUI", "OnItemClick");

  local decreaseBtn = GUI.ButtonCreate(itemicon,"decreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
  GUI.RegisterUIEvent(decreaseBtn, UCE.PointerClick, "DecomposeUI", "OnDecreaseBtnClick")
  GUI.SetVisible(decreaseBtn, true)
  GUI.SetData(decreaseBtn, "ItemIconGuid", GUI.GetGuid(itemicon))
  UILayout.SetSameAnchorAndPivot(decreaseBtn, UILayout.TopRight)
  return itemicon;
end

function DecomposeUI.RefreshItemScroll(parameter)

  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2]);
  local itemIcon = GUI.GetByGuid(guid);
  index=index+1;

  local itemGuid =DecomposeUI.itemGuids[index];
  if itemGuid then
    ItemIcon.BindItemGuid(itemIcon,itemGuid)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Selected, 1800600160);
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Selected, -1, -1, 82, 82);
    local numText=GUI.ItemCtrlGetElement(itemIcon, eItemIconElement.RightBottomNum);
    GUI.SetVisible(numText,true);
    DecomposeUI.SetItemNum(itemIcon,itemGuid)
  else
    ItemIcon.SetEmpty(itemIcon);
    local decreaseBtn =GUI.GetChild(itemIcon,"decreaseBtn")
    GUI.SetVisible(decreaseBtn,false)
  end

end

function DecomposeUI.SetItemNum(itemIcon,itemGuid)

  local decreaseBtn =GUI.GetChild(itemIcon,"decreaseBtn")
  local amount=tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount,itemGuid))
  if DecomposeUI.selectNums[itemGuid]==nil or DecomposeUI.selectNums[itemGuid]==0 then

    GUI.ItemCtrlUnSelect(itemIcon)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, amount);
    GUI.SetVisible(decreaseBtn,false);
  else

    if DecomposeUI.selectNums[itemGuid]>amount then
      DecomposeUI.selectNums[itemGuid]=amount;
    end
    GUI.ItemCtrlSelect(itemIcon)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum,DecomposeUI.selectNums[itemGuid].."/"..amount);
    GUI.SetVisible(decreaseBtn,true);
    GUI.SetDepth(decreaseBtn,GUI.GetChildCount(itemIcon)+1)
  end
end

function DecomposeUI.OnItemClick(guid)

  local itemIcon = GUI.GetByGuid(guid);
  local index = GUI.ItemCtrlGetIndex(itemIcon);
  index=index+1;
  local itemGuid =DecomposeUI.itemGuids[index];
  if itemGuid then
    local panelBg = _gt.GetUI("panelBg");
    local itemData = LD.GetItemDataByGuid(itemGuid)
    local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", 400, 0);

    if DecomposeUI.selectNums[itemGuid]==nil then
      DecomposeUI.selectNums[itemGuid]=1;
    else
      DecomposeUI.selectNums[itemGuid]=DecomposeUI.selectNums[itemGuid]+1;
    end

    DecomposeUI.Refresh();
  end
end

function DecomposeUI.OnDecreaseBtnClick(guid)
  local decreaseBtn =GUI.GetByGuid(guid);
  local itemIconGuid = GUI.GetData(decreaseBtn,"ItemIconGuid")
  local itemIcon = GUI.GetByGuid(itemIconGuid);
  local index = GUI.ItemCtrlGetIndex(itemIcon);
  index=index+1;

  local itemGuid =DecomposeUI.itemGuids[index];
  if itemGuid then
    if DecomposeUI.selectNums[itemGuid]~=nil or DecomposeUI.selectNums[itemGuid]>0 then
      DecomposeUI.selectNums[itemGuid]=DecomposeUI.selectNums[itemGuid]-1;
    end

    DecomposeUI.Refresh();
  end
end


function DecomposeUI.CreatePreviewItem()
  local previewScroll = _gt.GetUI("previewScroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(previewScroll);
  local previewItem = GUI.ButtonCreate(previewScroll, "previewItem"..curCount, "1800400360", 0, 0, Transition.ColorTint);
  GUI.RegisterUIEvent(previewItem, UCE.PointerClick, "DecomposeUI", "OnPreviewItemClick");
  local icon = ItemIcon.Create(previewItem, "icon", 15, 1)
  GUI.SetIsRaycastTarget(icon,false);
  UILayout.SetSameAnchorAndPivot(icon,UILayout.Left);
  local nameText = GUI.CreateStatic(previewItem, "nameText", "name", 105, -20, 220, 35)
  GUI.SetColor(nameText, UIDefine.BrownColor)
  GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(nameText,UILayout.Left);

  local numText = GUI.CreateStatic(previewItem, "numText", "num", 105, 15, 220, 35)
  GUI.SetColor(numText, UIDefine.Yellow2Color)
  GUI.StaticSetFontSize(numText, UIDefine.FontSizeS)
  GUI.StaticSetAlignment(numText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(numText,UILayout.Left);

  return previewItem;
end

function DecomposeUI.OnPreviewItemClick(guid)
  local previewItem = GUI.GetByGuid(guid);
  local index = GUI.ButtonGetIndex(previewItem)
  index = index + 1;

  local data;
  if index<=#DecomposeUI.previewItemData then
    data = DecomposeUI.previewItemData[index];
  else
    data = DecomposeUI.previewBindItemData[index-#DecomposeUI.previewItemData];
  end

  if data then
    local panelBg = _gt.GetUI("panelBg");
    local itemTips = Tips.CreateByItemKeyName(data.KeyName, panelBg, "itemTips", -400, 0);
  end
end


function DecomposeUI.RefreshPreviewScroll(parameter)
  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2]);
  local previewItem = GUI.GetByGuid(guid);
  local icon = GUI.GetChild(previewItem,"icon")
  local nameText = GUI.GetChild(previewItem,"nameText")
  local numText = GUI.GetChild(previewItem,"numText")
  index = index + 1;

  local data;
  local isBind=false;
  if index<=#DecomposeUI.previewItemData then
    data = DecomposeUI.previewItemData[index];
  else
    isBind=true;
    data = DecomposeUI.previewBindItemData[index-#DecomposeUI.previewItemData];
  end
  if data then
    local itemDB = DB.GetOnceItemByKey2(data.KeyName)
    ItemIcon.BindItemDB(icon,itemDB);
    if isBind then
      GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp, 1800707120)
    else
      GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp, nil)
    end
    GUI.StaticSetText(nameText,itemDB.Name);
    GUI.StaticSetText(numText,"可获得数量："..data.Min.."~"..data.Max);
  end

end