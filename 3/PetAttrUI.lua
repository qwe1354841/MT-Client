local PetAttrUI = {}
_G.PetAttrUI = PetAttrUI

local _gt = UILayout.NewGUIDUtilTable();


local tabList = {
  { "宠物属性", "BaseSubTabBtn", "1800402030", "1800402032", "OnBaseSubTabBtnClick", 253, -255, 185, 40, 100, 35 },
  { "属性详情", "DetailSubTabBtn", "1800402030", "1800402032", "OnDetailSubTabBtnClick", 435, -255, 185, 40, 100, 35 },
}

local baseAttrs = {
  { Name = "根骨", Attr1 = RoleAttr.RoleAttrVit ,Img="1800407040"},
  { Name = "气血", Attr1 = RoleAttr.RoleAttrHpLimit,Img="1801507180"},
  { Name = "灵性", Attr1 = RoleAttr.RoleAttrInt ,Img="1800407050"},
  { Name = "法力", Attr1 = RoleAttr.RoleAttrMpLimit,Img="1801507190"},
  { Name = "力量", Attr1 = RoleAttr.RoleAttrStr ,Img="1800407060"},
  { Name = "物攻", Attr1 = RoleAttr.RoleAttrPhyAtk ,Img="1800407040"},
  { Name = "敏捷", Attr1 = RoleAttr.RoleAttrAgi ,Img="1801507210"},
  { Name = "速度", Attr1 = RoleAttr.RoleAttrFightSpeed ,Img="1800407120"},
}


local attrItemWidth = 350;
local attrItemHeightL = 40;
local attrItemHeightM = 35;

function PetAttrUI.Create(panelBg)
  _gt = UILayout.NewGUIDUtilTable();
  local page = GUI.GroupCreate(panelBg, "petAttrPage", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))

  UILayout.CreateSubTab(tabList, page, "PetAttrUI");

  local rightPanel = GUI.ImageCreate(page, "rightPanel", "1800400200", 345, 90, false, 360, 480)
  UILayout.SetSameAnchorAndPivot(rightPanel, UILayout.Top);

  PetAttrUI.CreateBaseGroup(rightPanel)
  PetAttrUI.CreateDetailGroup(rightPanel)

  local releaseBtn = GUI.ButtonCreate(page, "releaseBtn", "1800402080", 250, 268, Transition.ColorTint, "放生", 160, 47, false);
  GUI.SetIsOutLine(releaseBtn, true);
  GUI.ButtonSetTextFontSize(releaseBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(releaseBtn, UIDefine.White2Color);
  GUI.SetOutLine_Color(releaseBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(releaseBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(releaseBtn, UCE.PointerClick, "PetAttrUI", "OnReleaseBtnClick");

  local lineupBtn = GUI.ButtonCreate(page, "lineupBtn", "1800402080", 440, 268, Transition.ColorTint, "参战", 160, 47, false);
  GUI.SetIsOutLine(lineupBtn, true);
  GUI.ButtonSetTextFontSize(lineupBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(lineupBtn, UIDefine.White2Color);
  GUI.SetOutLine_Color(lineupBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(lineupBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(lineupBtn, UCE.PointerClick, "PetAttrUI", "OnLineupBtnClick");
  _gt.BindName(lineupBtn, "lineupBtn");

  return page;
end

function PetAttrUI.InitData()
  PetAttrUI.tabIndex = 1;
  PetAttrUI.petAttrTable = {};

  PetAttrUI.StopTimer()

end


function PetAttrUI.SwitchPet()

end


function PetAttrUI.OnClose()
  local attrScroll =_gt.GetUI("attrScroll")
  GUI.ScrollRectSetNormalizedPosition(attrScroll,Vector2.New(0,0));
end


function PetAttrUI.Refresh()


  if PetUI.parameter then
    local index2 = UIDefine.GetParameter2(PetUI.parameter)
    PetAttrUI.tabIndex=index2;
    PetUI.parameter=nil;
  end

  UILayout.OnSubTabClickEx(PetAttrUI.tabIndex, tabList);

  for i = 1, #tabList do
    local page = _gt.GetUI("tabPage"..i);
    if page ~= nil then
      GUI.SetVisible(page, i == PetAttrUI.tabIndex);
    end
  end


  if PetAttrUI.tabIndex == 1 then
    PetAttrUI.RefreshBaseGroup();
  elseif PetAttrUI.tabIndex == 2 then
    PetAttrUI.RefreshDetailGroup()
  end

  local lineupBtn = _gt.GetUI("lineupBtn");
  if PetUI.petGuid ~= nil then
    local isLineup = LD.GetPetState(PetState.Lineup, PetUI.petGuid)
    if isLineup then
      GUI.ButtonSetText(lineupBtn, "休息");
    else
      GUI.ButtonSetText(lineupBtn, "参战");
    end
  else
    GUI.ButtonSetText(lineupBtn, "参战");
  end
end

function PetAttrUI.RefreshDetailGroup()
  local attrScroll = _gt.GetUI("attrScroll");
  if PetUI.petGuid == nil then
    GUI.LoopScrollRectSetTotalCount(attrScroll, 0)
  else
    local petData = LD.GetPetData(PetUI.petGuid)
    PetAttrUI.petAttrTable = LogicDefine.GetPetAttrTable(petData)
    GUI.LoopScrollRectSetTotalCount(attrScroll, 0)
    GUI.LoopScrollRectSetTotalCount(attrScroll, #PetAttrUI.petAttrTable)
  end

  GUI.LoopScrollRectRefreshCells(attrScroll)
  PetAttrUI.SetScrollArrow()
end

function PetAttrUI.RefreshBaseGroup()

  local baseGroup =_gt.GetUI("tabPage1")
  for i = 1, #baseAttrs do
    local attrArea = GUI.GetChild(baseGroup, "attrArea" .. i);
    local valueText = GUI.GetChild(attrArea, "valueText");


    if PetUI.petGuid ~= nil then
      local attr1Num = tonumber(tostring(LD.GetPetAttr(baseAttrs[i].Attr1, PetUI.petGuid)));
      GUI.StaticSetText(valueText, tostring(attr1Num));
    else
      GUI.StaticSetText(valueText, "0");
    end

    local w = GUI.GetWidth(valueText)
    if w > 80 then
      local s = 80 / w
      GUI.SetScale(valueText, Vector3.New(s, s, s))
    else
      GUI.SetScale(valueText, UIDefine.Vector3One)
    end
  end

  local remainPointText = _gt.GetUI("remainPointText")
  local hpFill = _gt.GetUI("hpFill");
  local mpFill = _gt.GetUI("mpFill");
  local hpText =  _gt.GetUI("hpText");
  local mpText =  _gt.GetUI("mpText");
  local expFill = _gt.GetUI("expFill")
  local expText = _gt.GetUI("expText")
  local loyalText = _gt.GetUI("loyalText")
  local intimateText = _gt.GetUI("intimateText")


  if PetUI.petGuid ~= nil then
    local rpStr = tostring(LD.GetPetAttr(RoleAttr.RoleAttrRemainPoint, PetUI.petGuid));
    GUI.StaticSetText(remainPointText, rpStr);
    local expNum = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrExp, PetUI.petGuid)));
    local expLimitNum = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrExpLimit, PetUI.petGuid)));

    local fillValue = expLimitNum == 0 and 1 or expNum / expLimitNum;
    GUI.SetImageFillAmount(expFill, fillValue);

    GUI.StaticSetText(expText, expNum .. "/" .. expLimitNum);

    local hpNum = LD.GetPetIntAttr(RoleAttr.RoleAttrHp, PetUI.petGuid);
    local maxHpNum = LD.GetPetIntAttr(RoleAttr.RoleAttrHpLimit, PetUI.petGuid);
    GUI.StaticSetText(hpText, hpNum .. "/" .. maxHpNum);
    local hpFillValue = maxHpNum == 0 and 1 or hpNum / maxHpNum;
    GUI.SetImageFillAmount(hpFill, hpFillValue);

    local mpNum = LD.GetPetIntAttr(RoleAttr.RoleAttrMp, PetUI.petGuid);
    local maxMpNum = LD.GetPetIntAttr(RoleAttr.RoleAttrMpLimit, PetUI.petGuid);
    GUI.StaticSetText(mpText, mpNum .. "/" .. maxMpNum);
    local mpFillValue = maxMpNum == 0 and 1 or mpNum / maxMpNum;
    GUI.SetImageFillAmount(mpFill, mpFillValue)


    GUI.StaticSetText(loyalText, LD.GetPetIntAttr(RoleAttr.PetAttrLoyalty, PetUI.petGuid));
    GUI.StaticSetText(intimateText, LD.GetPetIntAttr(RoleAttr.PetAttrClosePoint, PetUI.petGuid))
  else
    GUI.StaticSetText(remainPointText, "0");
    GUI.StaticSetText(expText, "0/0");
    GUI.SetImageFillAmount(expFill, 0);

    GUI.SetImageFillAmount(hpFill, 0);
    GUI.SetImageFillAmount(mpFill, 0);


    GUI.StaticSetText(hpText, "0/0");
    GUI.StaticSetText(mpText, "0/0");

    GUI.StaticSetText(loyalText, "0");
    GUI.StaticSetText(intimateText, "0");
  end

end

function PetAttrUI.CreateBaseGroup(rightPanel)
  local baseGroup = GUI.GroupCreate(rightPanel, "baseGroup", 0, 0, GUI.GetWidth(rightPanel), GUI.GetHeight(rightPanel));
  _gt.BindName(baseGroup,"tabPage1");

  local hpArea = GUI.CreateStatic(baseGroup, "hpArea", "气 血", 20, 15, 100, 30);
  GUI.SetColor(hpArea, UIDefine.BrownColor);
  GUI.StaticSetFontSize(hpArea, UIDefine.FontSizeM)
  UILayout.SetSameAnchorAndPivot(hpArea, UILayout.TopLeft);

  local bg = GUI.ImageCreate(hpArea, "bg", "1800700010", 60, 1, false, 255, 30);
  local hpFill = GUI.ImageCreate(bg, "hpFill", "1800408120", 0, -1, false, 255, 28);
  UILayout.SetSameAnchorAndPivot(hpFill, UILayout.Center);
  GUI.ImageSetType(hpFill, SpriteType.Filled);
  GUI.SetImageFillMethod(hpFill, SpriteFillMethod.Horizontal_Left)
  _gt.BindName(hpFill, "hpFill")

  local hpText = GUI.CreateStatic(bg, "hpText", "0", 0, 0, 250, 30);
  GUI.SetColor(hpText, UIDefine.White2Color);
  GUI.StaticSetFontSize(hpText, UIDefine.FontSizeSS);
  GUI.StaticSetAlignment(hpText, TextAnchor.MiddleCenter);
  GUI.StaticSetAutoSize(hpText, true)
  UILayout.SetSameAnchorAndPivot(hpText, UILayout.Center);
  _gt.BindName(hpText, "hpText")

  local mpArea = GUI.CreateStatic(baseGroup, "mpArea", "法 力", 20, 55, 100, 30);
  GUI.SetColor(mpArea, UIDefine.BrownColor);
  GUI.StaticSetFontSize(mpArea, UIDefine.FontSizeM)
  UILayout.SetSameAnchorAndPivot(mpArea, UILayout.TopLeft);

  local bg = GUI.ImageCreate(mpArea, "bg", "1800700010", 60, 1, false, 255, 30);
  local mpFill = GUI.ImageCreate(bg, "mpFill", "1800408130", 0, -1, false, 255, 28);
  UILayout.SetSameAnchorAndPivot(mpFill, UILayout.Center);
  GUI.ImageSetType(mpFill, SpriteType.Filled);
  GUI.SetImageFillMethod(mpFill, SpriteFillMethod.Horizontal_Left)
  _gt.BindName(mpFill, "mpFill")

  local mpText = GUI.CreateStatic(bg, "mpText", "0", 0, 0, 250, 30);
  GUI.SetColor(mpText, UIDefine.White2Color);
  GUI.StaticSetFontSize(mpText, UIDefine.FontSizeSS);
  GUI.StaticSetAlignment(mpText, TextAnchor.MiddleCenter);
  GUI.StaticSetAutoSize(mpText, true)
  UILayout.SetSameAnchorAndPivot(mpText, UILayout.Center);
  _gt.BindName(mpText, "mpText")

  local expArea = GUI.CreateStatic(baseGroup, "expArea", "经 验", 20, 95, 100, 30);
  GUI.SetColor(expArea, UIDefine.BrownColor);
  GUI.StaticSetFontSize(expArea, UIDefine.FontSizeM)
  UILayout.SetSameAnchorAndPivot(expArea, UILayout.TopLeft);

  local bg = GUI.ImageCreate(expArea, "bg", "1800700010", 60, 1, false, 215, 30);
  local expFill = GUI.ImageCreate(bg, "expFill", "1800408160", 0, -1, false, 215, 28);
  UILayout.SetSameAnchorAndPivot(expFill, UILayout.Center);
  GUI.ImageSetType(expFill, SpriteType.Filled);
  GUI.SetImageFillMethod(expFill, SpriteFillMethod.Horizontal_Left)
  _gt.BindName(expFill, "expFill")

  local expText = GUI.CreateStatic(bg, "expText", "0", 0, 0, 210, 30);
  GUI.SetColor(expText, UIDefine.White2Color);
  GUI.StaticSetFontSize(expText, UIDefine.FontSizeSS);
  GUI.StaticSetAlignment(expText, TextAnchor.MiddleCenter);
  GUI.StaticSetAutoSize(expText, true)
  UILayout.SetSameAnchorAndPivot(expText, UILayout.Center);
  _gt.BindName(expText, "expText")

  local addExpBtn = GUI.ButtonCreate(expArea, "addExpBtn", "1800702020", 278, -3, Transition.ColorTint, "", 40, 40, false);
  GUI.RegisterUIEvent(addExpBtn, UCE.PointerClick, "PetAttrUI", "OnAddExpBtnClick");

  local domesticateTitle = GUI.ImageCreate(baseGroup, "domesticateTitle", "1800200030", 0, -85, false, 350, 35);
  UILayout.SetSameAnchorAndPivot(domesticateTitle, UILayout.Center);
  local title = GUI.CreateStatic(domesticateTitle, "title", "宠物驯养", 0, 0, 200, 35);
  GUI.StaticSetFontSize(title, UIDefine.FontSizeM);
  GUI.SetColor(title, UIDefine.WhiteColor);
  UILayout.SetSameAnchorAndPivot(title, UILayout.Center);
  GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter);

  local loyalArea = GUI.CreateStatic(baseGroup, "loyalArea", "忠诚", 20, 185, 120, 30);
  GUI.SetColor(loyalArea, UIDefine.BrownColor);
  GUI.StaticSetFontSize(loyalArea, UIDefine.FontSizeM)
  UILayout.SetSameAnchorAndPivot(loyalArea, UILayout.TopLeft);

  local bg = GUI.ImageCreate(loyalArea, "bg", "1800700010", 52, 1, false, 100, 28);
  UILayout.SetSameAnchorAndPivot(bg, UILayout.Left);

  local loyalText = GUI.CreateStatic(bg, "loyalText", "100", 0, 0, 100, 30);
  GUI.SetColor(loyalText, UIDefine.White2Color);
  GUI.StaticSetFontSize(loyalText, UIDefine.FontSizeSS);
  GUI.StaticSetAlignment(loyalText, TextAnchor.MiddleCenter);
  _gt.BindName(loyalText, "loyalText")


  local intimateArea = GUI.CreateStatic(baseGroup, "intimateArea", "亲密", 185, 185, 120, 30);
  GUI.SetColor(intimateArea, UIDefine.BrownColor);
  GUI.StaticSetFontSize(intimateArea, UIDefine.FontSizeM)
  UILayout.SetSameAnchorAndPivot(intimateArea, UILayout.TopLeft);

  local bg = GUI.ImageCreate(intimateArea, "bg", "1800700010", 52, 1, false, 100, 28);
  UILayout.SetSameAnchorAndPivot(bg, UILayout.Left);

  local intimateText = GUI.CreateStatic(bg, "intimateText", "100", 0, 0, 100, 30);
  GUI.SetColor(intimateText, UIDefine.White2Color);
  GUI.StaticSetFontSize(intimateText, UIDefine.FontSizeSS);
  GUI.StaticSetAlignment(intimateText, TextAnchor.MiddleCenter);
  _gt.BindName(intimateText, "intimateText")


  local attrTitle = GUI.ImageCreate(baseGroup, "attrTitle", "1800200030", 0, 5, false, 350, 35);
  UILayout.SetSameAnchorAndPivot(attrTitle, UILayout.Center);
  local title = GUI.CreateStatic(attrTitle, "title", "宠物属性", 0, 0, 200, 35);
  GUI.StaticSetFontSize(title, UIDefine.FontSizeM);
  GUI.SetColor(title, UIDefine.WhiteColor);
  UILayout.SetSameAnchorAndPivot(title, UILayout.Center);
  GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter);


  for i = 1, #baseAttrs do
    local x = 50;
    local y = 275 + 40 * (math.ceil(i/2)-1);
    if math.fmod( i, 2 )==0 then
      x = 220;
    end

    local attrArea = GUI.CreateStatic(baseGroup, "attrArea" .. i, baseAttrs[i].Name, x, y, 80, 30);
    GUI.SetColor(attrArea, UIDefine.BrownColor);
    GUI.StaticSetFontSize(attrArea, UIDefine.FontSizeS);
    GUI.StaticSetAlignment(attrArea, TextAnchor.MiddleLeft);
    UILayout.SetSameAnchorAndPivot(attrArea, UILayout.TopLeft);

    local icon = GUI.ImageCreate(attrArea, "icon", baseAttrs[i].Img, -90, 0);
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Right);

    Tips.RegisterAttrHintEvent(attrArea,"PetUI")

    local valueText = GUI.CreateStatic(attrArea, "valueText", "0", 52, -1, 110, 35);
    GUI.SetColor(valueText, UIDefine.Brown6Color);
    GUI.StaticSetFontSize(valueText, UIDefine.FontSizeSS);
    GUI.StaticSetAlignment(valueText, TextAnchor.MiddleLeft);
    GUI.StaticSetAutoSize(valueText, true)
    UILayout.SetSameAnchorAndPivot(valueText, UILayout.Left);
  end

  local remainPointArea = GUI.CreateStatic(baseGroup, "remainPointArea", "可分配点数", 20, 435, 120, 30);
  GUI.SetColor(remainPointArea, UIDefine.BrownColor);
  GUI.StaticSetFontSize(remainPointArea, UIDefine.FontSizeS)
  UILayout.SetSameAnchorAndPivot(remainPointArea, UILayout.TopLeft);

  local bg = GUI.ImageCreate(remainPointArea, "bg", "1800700010", 115, 1, false, 120, 28);
  UILayout.SetSameAnchorAndPivot(bg, UILayout.Left);

  local remainPointText = GUI.CreateStatic(bg, "remainPointText", "100", 0, 0, 120, 30);
  GUI.SetColor(remainPointText, UIDefine.White2Color);
  GUI.StaticSetFontSize(remainPointText, UIDefine.FontSizeSS);
  GUI.StaticSetAlignment(remainPointText, TextAnchor.MiddleCenter);
  _gt.BindName(remainPointText, "remainPointText")

  local addPointBtn = GUI.ButtonCreate(bg, "addPointBtn", "1800402110", 130, -1, Transition.ColorTint, "加点", 80, 36, false);
  GUI.ButtonSetTextFontSize(addPointBtn, UIDefine.FontSizeS)
  GUI.ButtonSetTextColor(addPointBtn,UIDefine.BrownColor)
  GUI.RegisterUIEvent(addPointBtn, UCE.PointerClick, "PetAttrUI", "OnAddPointBtnClick");

end

function PetAttrUI.OnAddExpBtnClick()
  PetUI.tabIndex=3;
  PetEduUI.tabIndex=2;
  PetUI.Refresh();
end


function PetAttrUI.OnAddPointBtnClick()
  if PetUI.petGuid~=nil then
    GUI.OpenWnd("AddPointUI");
    AddPointUI.SetPetGuid(PetUI.petGuid);
  end
end

function PetAttrUI.CreateDetailGroup(rightPanel)
  local detailGroup = GUI.GroupCreate(rightPanel, "detailGroup", 0, 0, GUI.GetWidth(rightPanel), GUI.GetHeight(rightPanel));
  _gt.BindName(detailGroup,"tabPage2");

  local attrScroll = GUI.LoopListCreate(detailGroup, "attrScroll", 0, 0, attrItemWidth, 465,
      "PetAttrUI", "CreateAttrItem", "PetAttrUI", "RefreshAttrScroll", 0, false, Vector2.New(0, 0), 1, UIAroundPivot.Top, UIAnchor.Top)
  UILayout.SetSameAnchorAndPivot(attrScroll, UILayout.Center);
  _gt.BindName(attrScroll, "attrScroll");
  attrScroll:RegisterEvent(UCE.EndDrag)
  GUI.RegisterUIEvent(attrScroll, UCE.EndDrag, "PetAttrUI", "OnAttrScrollEndDrag");

  local upArrow = GUI.ImageCreate(detailGroup, "upArrow", "1800607340", 0, 30);
  UILayout.SetSameAnchorAndPivot(upArrow, UILayout.Top)
  GUI.SetEulerAngles(upArrow, Vector3.New(0, 0, 180));
  _gt.BindName(upArrow, "upArrow")

  local downArrow = GUI.ImageCreate(detailGroup, "downArrow", "1800607340", 0, 0);
  UILayout.SetSameAnchorAndPivot(downArrow, UILayout.Bottom)
  _gt.BindName(downArrow, "downArrow")

end



function PetAttrUI.CreateAttrItem()
  local attrScroll = _gt.GetUI("attrScroll");
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(attrScroll);
  local attrItem = GUI.GroupCreate(attrScroll, "attrItem"..curCount, 0, 0, 0, 0)

  local typeNameBg = GUI.ImageCreate(attrItem,"typeNameBg","1801401060",0,0,false,attrItemWidth,attrItemHeightL);

  local typeNameText = GUI.CreateStatic(typeNameBg,"typeNameText","属性分类",10,2,attrItemWidth,attrItemHeightL);
  GUI.SetColor(typeNameText,UIDefine.WhiteColor);
  GUI.StaticSetFontSize(typeNameText, UIDefine.FontSizeXL);
  GUI.StaticSetAlignment(typeNameText, TextAnchor.MiddleLeft);
  UILayout.SetSameAnchorAndPivot(typeNameText,UILayout.Left);


  local attrBg = GUI.ImageCreate(attrItem,"attrBg","1801501020",0,0,false,attrItemWidth,attrItemHeightM);

  local attrNameText = GUI.CreateStatic(attrBg,"attrNameText","属性名称",15,2,140,attrItemHeightM);
  GUI.SetColor(attrNameText,UIDefine.BrownColor);
  GUI.StaticSetFontSize(attrNameText, UIDefine.FontSizeL);
  GUI.StaticSetAlignment(attrNameText, TextAnchor.MiddleLeft);
  UILayout.SetSameAnchorAndPivot(attrNameText,UILayout.Left);

  Tips.RegisterAttrHintEvent(attrNameText,"PetUI")

  local attrValueText = GUI.CreateStatic(attrBg,"attrValueText","0",-15,2,175,attrItemHeightM);
  GUI.SetColor(attrValueText,UIDefine.BrownColor);
  GUI.StaticSetFontSize(attrValueText, UIDefine.FontSizeL);
  GUI.StaticSetAlignment(attrValueText, TextAnchor.MiddleRight);
  UILayout.SetSameAnchorAndPivot(attrValueText,UILayout.Right);
  return attrItem
end

function PetAttrUI.RefreshAttrScroll(parameter)
  parameter = string.split(parameter, "#")
  local guid = parameter[1]
  local index = tonumber(parameter[2])
  local attrItem = GUI.GetByGuid(guid);
  index=index+1;


  local imageId ="1801501020";
  if math.fmod( index, 2 )==0 then
    imageId ="1801501010";
  end

  local attrData=PetAttrUI.petAttrTable[index];
  if attrData==nil then
    GUI.SetVisible(attrItem,false);
    return;
  end

  local typeNameBg=GUI.GetChild(attrItem,"typeNameBg");
  local typeNameText = GUI.GetChild(typeNameBg,"typeNameText");
  local attrBg =  GUI.GetChild(attrItem,"attrBg");
  local attrNameText = GUI.GetChild(attrBg,"attrNameText");
  local attrValueText = GUI.GetChild(attrBg,"attrValueText");

  if attrData.TypeName~=nil then
    GUI.SetVisible(typeNameBg,true);
    GUI.SetVisible(attrBg,false);

    GUI.StaticSetText(typeNameText,attrData.TypeName);
    GUI.SetPreferredHeight(attrItem, attrItemHeightL);
  else
    GUI.SetVisible(typeNameBg,false);
    GUI.SetVisible(attrBg,true);

    GUI.ImageSetImageID(attrBg,imageId)

    GUI.StaticSetText(attrNameText,attrData.ChinaName);
    if attrData.MaxValue==nil then
      local value =attrData.Value;
      if attrData.IsPct==1 then
        value= tostring(tonumber(attrData.Value)/100).."%";
      end
      GUI.StaticSetText(attrValueText,value);
    else
      GUI.StaticSetText(attrValueText,attrData.Value.."/"..attrData.MaxValue);
    end

    GUI.SetPreferredHeight(attrItem, attrItemHeightM);
  end

  GUI.SetPreferredWidth(attrItem, attrItemWidth);
end

function PetAttrUI.OnAttrScrollEndDrag()

  if PetAttrUI.timer == nil then
    PetAttrUI.timer = Timer.New(PetAttrUI.SetScrollArrow, 1, 1)
  else
    PetAttrUI.timer:Stop();
    PetAttrUI.timer:Reset(PetAttrUI.SetScrollArrow, 1, 1)
  end
  PetAttrUI.timer:Start();
end

function PetAttrUI.StopTimer()
  if PetAttrUI.timer~=nil then
    PetAttrUI.timer:Stop();
    PetAttrUI.timer=nil;
  end
end


function PetAttrUI.SetScrollArrow()
  local attrScroll = _gt.GetUI("attrScroll")
  local pos = GUI.GetNormalizedPosition(attrScroll);
  local count = GUI.LoopScrollRectGetTotalCount(attrScroll);
  local upArrow = _gt.GetUI("upArrow")
  local downArrow = _gt.GetUI("downArrow");
  if count>13 then
    if pos.y<(1/count) then
      GUI.SetVisible(upArrow,true);
      GUI.SetVisible(downArrow,false);
    elseif pos.y>1-(1/count) then
      GUI.SetVisible(upArrow,false);
      GUI.SetVisible(downArrow,true);
    else
      GUI.SetVisible(upArrow,true);
      GUI.SetVisible(downArrow,true);
    end
  else
    GUI.SetVisible(upArrow,false);
    GUI.SetVisible(downArrow,false);
  end
end


function PetAttrUI.OnBaseSubTabBtnClick()
  PetAttrUI.tabIndex = 1;
  PetAttrUI.Refresh()
end

function PetAttrUI.OnDetailSubTabBtnClick()
  PetAttrUI.tabIndex = 2;
  PetAttrUI.Refresh()
end


function PetAttrUI.OnReleaseBtnClick()
  if PetUI.petGuid ~= nil then

    local msg = "确定要放生 <color=#FF0000FF>"..LD.GetPetName(PetUI.petGuid ).."</color> 吗？"
    GlobalUtils.ShowBoxMsg2Btn("提示",msg,"PetAttrUI","确定","ConfirmRelease","取消")
  end
end

function PetAttrUI.ConfirmRelease()
  if PetUI.petGuid ~= nil then
    CL.SendNotify(NOTIFY.ReleasePet, PetUI.petGuid)
  end

end

function PetAttrUI.OnLineupBtnClick()
  if PetUI.petGuid ~= nil then
    CL.SendNotify(NOTIFY.SetPetLineup, PetUI.petGuid)
  end
end
