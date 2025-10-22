local MailUI = {}
_G.MailUI = MailUI

local ItemDataTable = {}
local SendItemDataTable = {}

local LabelList = {
  { "好友", "friendPageBtn", "OnFriendPageBtnClick", "recentlyPage" },
  { "邮件", "emailPageBtn", "OnEmailPageBtnClick", "emailPage", },
}
local validTickCount =LogicDefine.MailValidTickCount;
local maxMailCount=LogicDefine.MaxMailCount;

local _gt = UILayout.NewGUIDUtilTable();
function MailUI.Main()
  _gt = UILayout.NewGUIDUtilTable();
  local panel = GUI.WndCreateWnd("MailUI", "MailUI", 0, 0, eCanvasGroup.Normal)
  local panelBg = UILayout.CreateFrame_WndStyle0(panel, "邮    件", "MailUI", "OnCloseBtnClick", _gt)
  UILayout.CreateRightTab(LabelList, "MailUI")
  local page = GUI.GroupCreate(panelBg, "mailPage", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))

  local mailCountArea= GUI.CreateStatic(page, "mailCountArea", "邮件数量", 65, 70, 150, 30)
  GUI.SetColor(mailCountArea, UIDefine.BrownColor)
  GUI.StaticSetFontSize(mailCountArea, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(mailCountArea, TextAnchor.MiddleCenter)
  UILayout.SetSameAnchorAndPivot(mailCountArea, UILayout.TopLeft);

  local bg = GUI.ImageCreate(mailCountArea, "bg", "1800700010", 130, 1, false, 150, 35)
  UILayout.SetSameAnchorAndPivot(bg, UILayout.Left);
  local mailCountText = GUI.CreateStatic(bg, "mailCountText", "0/100", 0, -1, 150, 30)
  GUI.SetColor(mailCountText, UIDefine.WhiteColor)
  GUI.StaticSetFontSize(mailCountText, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(mailCountText, TextAnchor.MiddleCenter)
  UILayout.SetSameAnchorAndPivot(mailCountText, UILayout.Center);
  _gt.BindName(mailCountText, "mailCountText")

  local leftBg = GUI.ImageCreate(page, "leftBg", "1800400200", -380, 5, false, 290, 460);
  UILayout.SetSameAnchorAndPivot(leftBg, UILayout.Center);

  local mailScroll = GUI.LoopScrollRectCreate(leftBg, "mailScroll", 0, 5, 280, 450,
      "MailUI", "CreateMailItem", "MailUI", "RefreshMailScroll", 0, false,
      Vector2.New(280, 100), 1, UIAroundPivot.Top, UIAnchor.Top);
  UILayout.SetSameAnchorAndPivot(mailScroll, UILayout.Top);
  _gt.BindName(mailScroll, "mailScroll");

  local oneKeyBtn = GUI.ButtonCreate(page, "oneKeyBtn", "1800402080", -380, 265, Transition.ColorTint, "一键领取", 160, 47, false);
  GUI.SetIsOutLine(oneKeyBtn, true);
  GUI.ButtonSetTextFontSize(oneKeyBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(oneKeyBtn, UIDefine.WhiteColor);
  GUI.SetOutLine_Color(oneKeyBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(oneKeyBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(oneKeyBtn, UCE.PointerClick, "MailUI", "OnOneKeyBtnClick");
  _gt.BindName(oneKeyBtn, "oneKeyBtn")

  local rightBg = GUI.ImageCreate(page, "rightBg", "1800400200", 150, -15, false, 740, 500);
  UILayout.SetSameAnchorAndPivot(rightBg, UILayout.Center);
  _gt.BindName(rightBg, "rightBg");

  local contentBg = GUI.ImageCreate(rightBg, "contentBg", "1800201190", 0, -60, false, 710, 350);
  UILayout.SetSameAnchorAndPivot(contentBg, UILayout.Center);

  local themeText= GUI.CreateStatic(contentBg, "themeText", "邮件主题", -200, 10, 250, 30)
  GUI.SetColor(themeText, UIDefine.White2Color)
  GUI.StaticSetFontSize(themeText, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(themeText, TextAnchor.MiddleCenter)
  UILayout.SetSameAnchorAndPivot(themeText, UILayout.Top);
  _gt.BindName(themeText, "themeText");

  local contentText= GUI.RichEditCreate(contentBg, "contentText", "邮件内容", 0, 20, 650, 260)
  GUI.SetColor(contentText, UIDefine.BrownColor)
  GUI.StaticSetFontSize(contentText, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(contentText, TextAnchor.UpperLeft)
  UILayout.SetSameAnchorAndPivot(contentText, UILayout.Center);
  _gt.BindName(contentText, "contentText");


  local text1= GUI.CreateStatic(rightBg, "text1", "附件物品", -300, 135, 150, 30)
  GUI.SetColor(text1, UIDefine.BrownColor)
  GUI.StaticSetFontSize(text1, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter)
  UILayout.SetSameAnchorAndPivot(text1, UILayout.Center);

  local itemScroll = GUI.LoopScrollRectCreate(rightBg, "itemScroll", 0, 195, 700, 80,
      "MailUI", "CreateItemIcon", "MailUI", "RefreshItemScroll", 0, true, Vector2.New(80, 80), 1, UIAroundPivot.Left, UIAnchor.Left);
  GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(15, 0));
  _gt.BindName(itemScroll, "itemScroll");

  local getBtn = GUI.ButtonCreate(page, "getBtn", "1800402080", 435, 265, Transition.ColorTint, "提取附件", 160, 47, false);
  GUI.SetIsOutLine(getBtn, true);
  GUI.ButtonSetTextFontSize(getBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(getBtn, UIDefine.WhiteColor);
  GUI.SetOutLine_Color(getBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(getBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(getBtn, UCE.PointerClick, "MailUI", "OnGetBtnClick");
  _gt.BindName(getBtn, "getBtn");

  MailUI.MainInit()
end

function MailUI.MainInit()
  ItemDataTable = {}
  SendItemDataTable = {}
end

function MailUI.OnCloseBtnClick()
  GUI.CloseWnd("MailUI")
end

function MailUI.GetItemData(MailGuid,ItemData)
  ItemData = string.split(ItemData, ",");
  for i = 1, #ItemData,2 do
    ItemDataTable[tostring(MailGuid)][tostring(ItemData[i])] = tostring(ItemData[i+1])
  end
end

function MailUI.OnShow(parameter)
  local wnd = GUI.GetWnd("MailUI");
  if wnd == nil then
    return
  end
  local friendPageBtn = GUI.Get("MailUI/panelBg/tabList/friendPageBtn")
  GUI.AddRedPoint(friendPageBtn,UIAnchor.TopLeft,25,-35,"1800208080")
  if parameter == "1" then
    GUI.SetRedPointVisable(friendPageBtn,true)
  else
    GUI.SetRedPointVisable(friendPageBtn,false)
  end
  GUI.SetVisible(wnd,true)
  MailUI.Register()
  MailUI.OnEmailPageBtnClick()
end

function MailUI.AddListRedPoint()
  --邮箱页签红点
  local count = LD.GetMailTotalRedPointCount()
  local emailPageBtn = GUI.Get("MailUI/panelBg/tabList/emailPageBtn")
  GUI.AddRedPoint(emailPageBtn,UIAnchor.TopLeft,25,-35,"1800208080")
  if count > 0 then
    GUI.SetRedPointVisable(emailPageBtn,true)
  else
    GUI.SetRedPointVisable(emailPageBtn,false)
  end

  --好友页签红点
  local MailUIFriendRedTable = MailUI.FriendRedTable
  local friendPageBtn = GUI.Get("MailUI/panelBg/tabList/friendPageBtn")
  GUI.AddRedPoint(friendPageBtn,UIAnchor.TopLeft,25,-35,"1800208080")
  if not next(MailUIFriendRedTable) then
    GUI.SetRedPointVisable(friendPageBtn,false)
  else
    GUI.SetRedPointVisable(friendPageBtn,true)
  end
end


function MailUI.OnClose()
  local emailPageBtn = _gt.GetUI("emailPageBtn")--GUI.Get("FriendUI/panelBg/tabList/emailPageBtn")
  RedPointMgr.DelRedPointEvent(emailPageBtn, GM.MailUpdate, MailUI.CheckMailRedPoint)
  MailUI.UnRegister()
end

function MailUI.OnFriendPageBtnClick()
  UILayout.OnTabClick(1, LabelList)
  MailUI.OnCloseBtnClick()
  GUI.OpenWnd("FriendUI")
  CL.SendNotify(NOTIFY.SubmitForm,"FormContact","get_senders_guid")
  --好友页签红点
  local friendPageBtn = GUI.Get("MailUI/panelBg/tabList/friendPageBtn")
  GUI.SetRedPointVisable(friendPageBtn,false)
end

function MailUI.OnEmailPageBtnClick()
  UILayout.OnTabClick(2, LabelList)
  MailUI.OnEnter()
end

function MailUI.CheckMailRedPoint()
  if LD.GetMailTotalRedPointCount() > 0 then
    return true
  else
    return false;
  end
end

function MailUI.OnOneKeyBtnClick()
  if #MailUI.mailGuids==0 then
    return;
  end

  if LD.GetMailTotalUnGetCount()>0 then
    CL.SendNotify(NOTIFY.SubmitForm, "FormMail", "GetAllAttachment");
  else
    CL.SendNotify(NOTIFY.SubmitForm, "FormMail", "DeleteAllMails");
  end

end

function MailUI.OnGetBtnClick()


  local mailGuid = MailUI.mailGuids[MailUI.mailIndex];

  if mailGuid==nil then
    return;
  end

  local headMailData = LD.GetMailHeadData(mailGuid);
  if headMailData==nil then
    return;
  end
  if LD.CheckMailHasAttachment(headMailData) then
    CL.SendNotify(NOTIFY.SubmitForm, "FormMail", "GetMailAttachment",tostring(mailGuid));
  else
    CL.SendNotify(NOTIFY.SubmitForm, "FormMail", "DeleteMail",tostring(mailGuid));
  end
end


function MailUI.CreateMailItem()
  local mailScroll = _gt.GetUI("mailScroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(mailScroll);
  local mailItem = GUI.CheckBoxExCreate(mailScroll, "mailItem"..curCount, "1800800030", "1800800040", 0, 0, false)
  GUI.RegisterUIEvent(mailItem, UCE.PointerClick, "MailUI", "OnMailItemClick");
  local icon = ItemIcon.Create(mailItem, "icon", 15, 2)
  GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, "1800209010");
  GUI.ItemCtrlSetElementRect(icon, eItemIconElement.Icon, 0, -1,68,68);
  UILayout.SetSameAnchorAndPivot(icon,UILayout.Left);

  GUI.AddRedPoint(icon,UIAnchor.TopRight,-5,5);

  local titleText = GUI.CreateStatic(mailItem, "titleText", "name", 105, -15, 170, 35,"system",true,false)
  GUI.SetColor(titleText, UIDefine.BrownColor)
  GUI.StaticSetFontSize(titleText, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(titleText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(titleText,UILayout.Left);

  local vaildTimeText = GUI.CreateStatic(mailItem, "vaildTimeText", "有效期：", 105, 20, 170, 35)
  GUI.SetColor(vaildTimeText, UIDefine.Yellow2Color)
  GUI.StaticSetFontSize(vaildTimeText, UIDefine.FontSizeS)
  GUI.StaticSetAlignment(vaildTimeText, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(vaildTimeText,UILayout.Left);

  local attachment = GUI.ImageCreate(mailItem, "attachment", "1800208200", -10, -10);
  UILayout.SetSameAnchorAndPivot(attachment, UILayout.BottomRight);

  return mailItem;
end

function MailUI.RefreshMailScroll(parameter)
  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2]);
  local mailItem = GUI.GetByGuid(guid);
  local icon = GUI.GetChild(mailItem,"icon");
  local titleText = GUI.GetChild(mailItem,"titleText");
  local vaildTimeText = GUI.GetChild(mailItem,"vaildTimeText");
  local attachment = GUI.GetChild(mailItem,"attachment");

  index=index+1;

  local mailGuid = MailUI.mailGuids[index];
  if mailGuid==nil then
    GUI.SetVisible(mailItem,false);
    return;
  end

  local headMailData = LD.GetMailHeadData(mailGuid);
  if headMailData==nil then
    GUI.SetVisible(mailItem,false);
    return;
  end

  GUI.SetRedPointVisable(icon,LD.CheckMailRedPoint(headMailData))
  local titleName = headMailData.title

  local nameLength = utf8.len(titleName)

  if nameLength > 6 then
    titleName = utf8.sub(titleName,1,6).."..."
  end


  GUI.StaticSetText(titleText,titleName);

  local tick=headMailData.send_time+validTickCount -CL.GetServerTickCount();
  local day, hour, minute, second = GlobalUtils.Get_DHMS1_BySeconds(tick)
  if day ~= 0 then
    GUI.StaticSetText(vaildTimeText, "有效期："..day .. "天");
  else
    if hour ~= 0 then
      GUI.StaticSetText(vaildTimeText, "有效期："..hour .. "小时");
    else
      if minute ~= 0 then
        GUI.StaticSetText(vaildTimeText, "有效期："..minute .. "分钟");
      end
    end
  end

  GUI.SetVisible(attachment,LD.CheckMailHasAttachment(headMailData));

  GUI.CheckBoxExSetCheck(mailItem,index==MailUI.mailIndex)
end


function MailUI.OnMailItemClick(guid)
  local mailItem = GUI.GetByGuid(guid);
  local index = GUI.CheckBoxExGetIndex(mailItem);
  index = index+1;

  MailUI.OpenMailBody(index)
end

function MailUI.OpenMailBody(index)

  if index>#MailUI.mailGuids then
    MailUI.Refresh();
    return;
  end

  local mailGuid = MailUI.mailGuids[index];

  local bodyMail = LD.GetMailBodyData(mailGuid);
  MailUI.mailIndex=index;
  if bodyMail==nil then
    CL.SendNotify(NOTIFY.SubmitForm, "FormMail", "OpenMail",tostring(mailGuid));
    MailUI.Refresh();
  else
    MailUI.Refresh();
  end

end

function MailUI.CreateItemIcon()
  local itemScroll = _gt.GetUI("itemScroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll);
  local itemIcon = ItemIcon.Create(itemScroll, "itemIcon"..curCount, 0, 0)
  GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "MailUI", "OnItemClick");
  return itemIcon;
end

function MailUI.RefreshItemScroll(parameter)
  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2]);
  local itemIcon = GUI.GetByGuid(guid);


  local mailGuid = MailUI.mailGuids[MailUI.mailIndex];
  if mailGuid==nil then
    ItemIcon.SetEmpty(itemIcon);
  else
    local bodyMail = LD.GetMailBodyData(mailGuid);
    if bodyMail==nil then
      ItemIcon.SetEmpty(itemIcon);
    else

      if index<bodyMail.attrs.Count then
        ItemIcon.SetEmpty(itemIcon);
        local attrData= bodyMail.attrs[index];
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon,UIDefine.GetAttrIconByAttrId(attrData.attr));
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum,tostring(attrData.value));
      elseif index<bodyMail.attrs.Count+bodyMail.pets.Count then
        local petData = bodyMail.pets[index-bodyMail.attrs.Count];
        ItemIcon.BindPetData(itemIcon,petData)
      elseif index<bodyMail.attrs.Count+bodyMail.pets.Count+bodyMail.items.Count then
        local itemData =bodyMail.items[index-bodyMail.attrs.Count-bodyMail.pets.Count];
        GUI.SetData(itemIcon,"MailGuid",tostring(mailGuid))
        GUI.SetData(itemIcon,"ItemId",tostring(itemData.id))
        ItemIcon.BindItemData(itemIcon,itemData);
      else
        ItemIcon.SetEmpty(itemIcon);
      end

    end
  end

end

function MailUI.OnItemClick(guid)
  local itemIcon = GUI.GetByGuid(guid);
  local index = GUI.ItemCtrlGetIndex(itemIcon);
  local MailGuid = GUI.GetData(itemIcon,"MailGuid")
  local ItemId = GUI.GetData(itemIcon,"ItemId")
  local mailGuid = MailUI.mailGuids[MailUI.mailIndex];
  if mailGuid==nil then
      return;
  end

  local bodyMail = LD.GetMailBodyData(mailGuid);
  if bodyMail==nil then
      return;
  end


  if index<bodyMail.attrs.Count then
    local attrData= bodyMail.attrs[index];
    local itemId =UIDefine.AttrItemId[RoleAttr.IntToEnum(attrData.attr)]
    if itemId~=nil then
      local rightBg = _gt.GetUI("rightBg");
      local itemTips=Tips.CreateByItemId(itemId,rightBg,"itemTips",0,-100)
      UILayout.SetSameAnchorAndPivot(itemTips, UILayout.Bottom)
    end
  elseif index<bodyMail.attrs.Count+bodyMail.pets.Count then
    local petData = bodyMail.pets[index-bodyMail.attrs.Count];
    GUI.OpenWnd("PetInfoUI")
    PetInfoUI.SetPetData(petData);
  elseif index<bodyMail.attrs.Count+bodyMail.pets.Count+bodyMail.items.Count then
    local rightBg = _gt.GetUI("rightBg");
    local itemData =bodyMail.items[index-bodyMail.attrs.Count-bodyMail.pets.Count];

    if ItemDataTable[MailGuid][ItemId] ~= nil then
      local ItemDB = DB.GetOnceItemByKey1(ItemId)
      local KeyName = tostring(ItemDB.KeyName).."#"..tostring(ItemDataTable[MailGuid][ItemId])
      local itemTips = Tips.CreateByItemKeyName(KeyName, rightBg, "itemTips",0,-100)
    else
      local itemTips=Tips.CreateByItemData(itemData,rightBg,"itemTips",0,-100);
    end
    UILayout.SetSameAnchorAndPivot(itemTips, UILayout.Bottom)
  end
end

function MailUI.Register()
  CL.RegisterMessage(GM.MailUpdate, "MailUI", "OnMailUpdate");
end

function MailUI.UnRegister()
  CL.UnRegisterMessage(GM.MailUpdate, "MailUI", "OnMailUpdate");
end

function MailUI.OnMailUpdate(type,mailGuid)
  if type==1 then
    if #MailUI.mailGuids==0 then
      MailUI.mailIndex=1;
    elseif mailGuid then
      MailUI.mailIndex=MailUI.mailIndex+1;
    end

    table.insert(MailUI.mailGuids,1,mailGuid);

  elseif type==2 then
    for i = 1, #MailUI.mailGuids do
      if MailUI.mailGuids[i]==mailGuid then
        SendItemDataTable[tostring(mailGuid)] = 0
        ItemDataTable[tostring(mailGuid)] = {}
        table.remove(MailUI.mailGuids,i);
        local mailScroll = _gt.GetUI("mailScroll")
        GUI.ScrollRectSetNormalizedPosition(mailScroll, Vector2.New(0, 0));
        MailUI.mailIndex=1;
        break
      end
    end
  elseif type==3 then
    if LD.GetMailHeadGuids().Count==0 then
      MailUI.mailGuids={};
    end
    MailUI.mailIndex=1;
  end

  local count = LD.GetMailTotalRedPointCount()
  local emailPageBtn = GUI.Get("MailUI/panelBg/tabList/emailPageBtn")
  GUI.AddRedPoint(emailPageBtn,UIAnchor.TopLeft,25,-35,"1800208080")
  if count > 0 then
    GUI.SetRedPointVisable(emailPageBtn,true)
  else
    GUI.SetRedPointVisable(emailPageBtn,false)
  end

  MailUI.OpenMailBody(MailUI.mailIndex)
end

function MailUI.OnEnter()
  MailUI.InitData();

  MailUI.mailGuids ={};
  local guids=LD.GetMailHeadGuids()
  for i = 0, guids.Count-1 do
    if SendItemDataTable[tostring(guids[i])] ~= 1 then
      CL.SendNotify(NOTIFY.SubmitForm,"FormMail","SuperMailInfo",tostring(guids[i]))
      SendItemDataTable[tostring(guids[i])] = 1
      ItemDataTable[tostring(guids[i])] = {}
    end
    table.insert(MailUI.mailGuids,guids[i]);
  end

  local mailScroll = _gt.GetUI("mailScroll")
  GUI.ScrollRectSetNormalizedPosition(mailScroll, Vector2.New(0, 0));
  MailUI.OpenMailBody(1)
end

function MailUI.InitData()
  MailUI.mailIndex=1;
  MailUI.mailGuids ={};
end


function MailUI.Refresh()

  local mailCountText =_gt.GetUI("mailCountText");
  GUI.StaticSetText(mailCountText,#MailUI.mailGuids.."/"..maxMailCount);

  local mailScroll = _gt.GetUI("mailScroll")
  GUI.LoopScrollRectSetTotalCount(mailScroll, #MailUI.mailGuids);
  GUI.LoopScrollRectRefreshCells(mailScroll);

  local itemScroll = _gt.GetUI("itemScroll")


  local oneKeyBtn = _gt.GetUI("oneKeyBtn");
  local getBtn =  _gt.GetUI("getBtn");
  local themeText = _gt.GetUI("themeText");
  local contentText =  _gt.GetUI("contentText");
  local mailGuid =  MailUI.mailGuids[MailUI.mailIndex];

  if #MailUI.mailGuids==0 or mailGuid==nil then
    GUI.SetVisible(themeText,false);
    GUI.SetVisible(contentText,false);
    GUI.SetVisible(getBtn,false);
    GUI.ButtonSetText(oneKeyBtn,"一键领取")

    GUI.LoopScrollRectSetTotalCount(itemScroll, 7);
  else
    local headMail = LD.GetMailHeadData(mailGuid);
    if headMail~=nil then
      GUI.SetVisible(themeText,true);
      GUI.StaticSetText(themeText,headMail.title)
      GUI.SetVisible(getBtn,true);
      if LD.CheckMailHasAttachment(headMail) then
        GUI.ButtonSetText(getBtn,"提取附件");
      else
        GUI.ButtonSetText(getBtn,"删除");
      end

    else
      GUI.SetVisible(themeText,false);
      GUI.SetVisible(getBtn,false);
    end

    local bodyMail = LD.GetMailBodyData(mailGuid);
    if bodyMail~=nil then
      GUI.SetVisible(contentText,true);
      GUI.StaticSetText(contentText,bodyMail.content)
      local count = bodyMail.attrs.Count+bodyMail.items.Count+bodyMail.pets.Count
      count = count>7 and count or 7;
      GUI.LoopScrollRectSetTotalCount(itemScroll,count);
    else
      GUI.SetVisible(contentText,false);
      GUI.LoopScrollRectSetTotalCount(itemScroll, 7);

    end
    
    if LD.GetMailTotalUnGetCount()>0 then
      GUI.ButtonSetText(oneKeyBtn,"一键领取")
    else
      GUI.ButtonSetText(oneKeyBtn,"一键删除")
    end
  end

  GUI.LoopScrollRectRefreshCells(itemScroll);
end
