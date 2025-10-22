local TurnBornCorrectUI = {}
_G.TurnBornCorrectUI = TurnBornCorrectUI


local _gt = UILayout.NewGUIDUtilTable();

function TurnBornCorrectUI.Main(parameter)
  _gt = UILayout.NewGUIDUtilTable();


  local wnd = GUI.WndCreateWnd("TurnBornCorrectUI", "TurnBornCorrectUI", 0, 0);

  local panelBg = UILayout.CreateFrame_WndStyle2(wnd, "转生修正", 950, 620, "TurnBornCorrectUI", "OnExit", _gt)

  local  leftBg= GUI.ImageCreate(panelBg, "leftBg", "1800400200", 20, 60, false, 295, 540);
  UILayout.SetSameAnchorAndPivot(leftBg, UILayout.TopLeft);

  local leftScroll=GUI.ScrollListCreate(leftBg,"leftScroll", 0, 0, 285, 525, false, UIAroundPivot.Top,UIAnchor.Top)
  UILayout.SetSameAnchorAndPivot(leftScroll, UILayout.Center);
  _gt.BindName(leftScroll,"leftScroll");


  TurnBornCorrectUI.raceTable={};

  local roleIds = DB.GetRoleAllKeys();
  for i = 0, roleIds.Count-1 do
    local roleDB = DB.GetRole(roleIds[i]);
    local raceData;
    for j = 1,#TurnBornCorrectUI.raceTable do
      if TurnBornCorrectUI.raceTable[j].Race==roleDB.Race then
        raceData=TurnBornCorrectUI.raceTable[j];
        break;
      end
    end

    if raceData==nil then
      raceData={Race=roleDB.Race,Icon=roleDB.Icon,RoleIds={}};
      table.insert(TurnBornCorrectUI.raceTable,raceData);
    end

    table.insert(raceData.RoleIds,roleDB.Id);
    table.sort(raceData.RoleIds,function (a,b)
      return b>a;
    end)
  end

  table.sort(TurnBornCorrectUI.raceTable,function (a,b)
    return b.Race>a.Race;
  end)

  for i = 1, #TurnBornCorrectUI.raceTable do
    local raceData =TurnBornCorrectUI.raceTable[i]
    local raceBtn = GUI.ButtonCreate(leftScroll,"raceBtn"..i,"1800002030",0,0, Transition.ColorTint,"" ,285,90,false)
    GUI.SetPreferredWidth(raceBtn,285);
    GUI.SetPreferredHeight(raceBtn,90)
    GUI.RegisterUIEvent(raceBtn, UCE.PointerClick, "TurnBornCorrectUI", "OnRaceBtnClick")
    _gt.BindName(raceBtn,"raceBtn"..i);
    GUI.SetData(raceBtn,"Index",i);

    local raceIcon = GUI.ImageCreate(raceBtn, "raceIcon", tostring(raceData.Icon), 30, -2);
    UILayout.SetSameAnchorAndPivot(raceIcon, UILayout.Left);


    local raceNameText = GUI.CreateStatic(raceBtn, "raceNameText",UIDefine.GetRaceName(raceData.Race), 120, 0, 100, 35);
    GUI.StaticSetFontSize(raceNameText, UIDefine.FontSizeL)
    GUI.SetColor(raceNameText, UIDefine.BrownColor);
    GUI.StaticSetAlignment(raceNameText, TextAnchor.MiddleLeft);
    UILayout.SetSameAnchorAndPivot(raceNameText, UILayout.Left);


    local curText = GUI.CreateStatic(raceBtn, "curText","（当前）", 180, 0, 100, 35);
    GUI.StaticSetFontSize(curText, UIDefine.FontSizeL)
    GUI.SetColor(curText, UIDefine.GreenColor);
    GUI.StaticSetAlignment(curText, TextAnchor.MiddleLeft);
    UILayout.SetSameAnchorAndPivot(curText, UILayout.Left);

    local roleList= GUI.ListCreate(leftScroll,"roleList"..i,0,0,285,0,false);
    GUI.SetPaddingHorizontal(roleList,Vector2.New(12,0));
    _gt.BindName(roleList,"roleList"..i);

    for i = 1, #raceData.RoleIds do
      local roleId = raceData.RoleIds[i];
      local roleDB = DB.GetRole(roleId);
      if roleDB.Id~=0 then
        local roleItem = GUI.CheckBoxExCreate(roleList, "roleItem"..i, "1800602040", "1800602041", 0, 0, false, 260, 100)
        GUI.RegisterUIEvent(roleItem, UCE.PointerClick, "TurnBornCorrectUI", "OnRoleItemClick")
        GUI.SetData(roleItem,"Index",i);

        local roleIcon=ItemIcon.Create(roleItem,"roleIcon",-60,1)
        GUI.ItemCtrlSetElementValue(roleIcon,eItemIconElement.Icon, tostring(roleDB.Head));
        GUI.ItemCtrlSetElementRect(roleIcon,eItemIconElement.Icon, 0,-1,70,70);

        local nameText = GUI.CreateStatic(roleItem, "nameText",roleDB.RoleName, 130, 0, 100, 35);
        GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
        GUI.SetColor(nameText, UIDefine.BrownColor);
        GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft);
        UILayout.SetSameAnchorAndPivot(nameText, UILayout.Left);

        local curMark = GUI.ImageCreate(roleItem, "curMark","1801507150", 5, 5);
        UILayout.SetSameAnchorAndPivot(curMark, UILayout.TopLeft);
      end
    end
  end

  local turnScroll = GUI.LoopScrollRectCreate(panelBg, "turnScroll", -25, 60, 600, 60,
      "TurnBornCorrectUI", "CreateTurnItem", "TurnBornCorrectUI", "RefreshTrunScroll", 0, true, Vector2.New(150, 50), 1, UIAroundPivot.Left, UIAnchor.Left);
  --GUI.ScrollRectSetChildSpacing(turnScroll, Vector2.New(1, 1));
  UILayout.SetSameAnchorAndPivot(turnScroll, UILayout.TopRight);
  _gt.BindName(turnScroll,"turnScroll");


  local rightBg= GUI.ImageCreate(panelBg, "rightBg", "1800400200", 150, 20, false, 600, 430);
  UILayout.SetSameAnchorAndPivot(rightBg, UILayout.Center);


  local curArea = GUI.ImageCreate(rightBg, "curArea","1801100030", -150, 0,false,280,410);
  UILayout.SetSameAnchorAndPivot(curArea, UILayout.Center);

  local title = GUI.CreateStatic(curArea, "title", "当前修正", 20, 6, 150, 30)
  GUI.SetColor(title, UIDefine.BrownColor)
  GUI.StaticSetFontSize(title, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(title, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(title, UILayout.TopLeft)


  local curAttrScroll = GUI.LoopScrollRectCreate(curArea, "curAttrScroll", 0, 50, 280, 345,
      "TurnBornCorrectUI", "CreateCurAttrItem", "TurnBornCorrectUI", "RefreshCurAttrScroll", 0, false, Vector2.New(280, 35), 1, UIAroundPivot.Top, UIAnchor.Top);
  --GUI.ScrollRectSetAlignment(infoScroll,TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(curAttrScroll, UILayout.Top);
  _gt.BindName(curAttrScroll , "curAttrScroll");

  local noReText = GUI.CreateStatic(curArea, "noReText", "未 转 生", 0, 0, 150, 50)
  GUI.SetColor(noReText, UIDefine.RedColor)
  GUI.StaticSetFontSize(noReText, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(noReText, TextAnchor.MiddleCenter)
  UILayout.SetSameAnchorAndPivot(noReText, UILayout.Center)
  _gt.BindName(noReText , "noReText");

  local nextArea = GUI.ImageCreate(rightBg, "nextArea","1801100030", 150, 0,false,280,410);
  UILayout.SetSameAnchorAndPivot(nextArea, UILayout.Center);

  local title = GUI.CreateStatic(nextArea, "title", "转换后", 20, 6, 150, 30)
  GUI.SetColor(title, UIDefine.BrownColor)
  GUI.StaticSetFontSize(title, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(title, TextAnchor.MiddleLeft)
  UILayout.SetSameAnchorAndPivot(title, UILayout.TopLeft);


  local nextAttrScroll = GUI.LoopScrollRectCreate(nextArea, "nextAttrScroll", 0, 50, 280, 345,
      "TurnBornCorrectUI", "CreateNextAttrItem", "TurnBornCorrectUI", "RefreshNextAttrScroll", 0, false, Vector2.New(280, 35), 1, UIAroundPivot.Top, UIAnchor.Top);
  --GUI.ScrollRectSetAlignment(infoScroll,TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(nextAttrScroll, UILayout.Top);
  _gt.BindName(nextAttrScroll , "nextAttrScroll");


  local consumeText = GUI.CreateStatic(panelBg, "consumeText", "消耗", -120, -28, 100, 30)
  GUI.SetColor(consumeText, UIDefine.BrownColor)
  GUI.StaticSetFontSize(consumeText, UIDefine.FontSizeL)
  GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleCenter)
  UILayout.SetSameAnchorAndPivot(consumeText, UILayout.Bottom);

  local consumeBg = GUI.ImageCreate(panelBg, "consumeBg", "1800700010", 0, -25, false, 180, 35)
  UILayout.SetSameAnchorAndPivot(consumeBg, UILayout.Bottom);
  local coin = GUI.ImageCreate(consumeBg, "coin", "1800408280", -74, 1, false, 36, 36)
  _gt.BindName(coin, "consumeIcon")
  local num = GUI.CreateStatic(consumeBg, "num", "100", 5, 1, 160, 30)
  GUI.SetColor(num, UIDefine.WhiteColor)
  GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
  GUI.SetAnchor(num, UIAnchor.Center)
  GUI.SetPivot(num, UIAroundPivot.Center)
  GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
  _gt.BindName(num, "consumeNum")

  local confirmBtn = GUI.ButtonCreate(panelBg, "confirmBtn", "1800402080", -30, -20, Transition.ColorTint, "确定转换", 150, 47, false);
  GUI.SetIsOutLine(confirmBtn, true);
  GUI.ButtonSetTextFontSize(confirmBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(confirmBtn, UIDefine.WhiteColor);
  GUI.SetOutLine_Color(confirmBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(confirmBtn, UIDefine.OutLineDistance);
  UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight);
  GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "TurnBornCorrectUI", "OnConfirmBtnClick");
  _gt.BindName(confirmBtn, "confirmBtn")


end


function TurnBornCorrectUI.GetData(table)
  if GUI.GetVisible(GUI.GetWnd("TurnBornCorrectUI"))==false then
    return;
  end

  print("TurnBornCorrectUI.GetData")
  if CL.GetMode() == 1 then

    local inspect = require("inspect")
    print(inspect(REINCARNATION_DATA))

    local inspect = require("inspect")
    print(inspect(table))
  end

  TurnBornCorrectUI.data=table;
  TurnBornCorrectUI.Refresh()
end

function TurnBornCorrectUI.InitData()
  TurnBornCorrectUI.raceIndex=1;
  TurnBornCorrectUI.roleIndex =0;
  TurnBornCorrectUI.turnIndex=1;
  TurnBornCorrectUI.data={};
end



function TurnBornCorrectUI.OnShow(parameter)

  GUI.SetVisible(GUI.GetWnd("TurnBornCorrectUI"),true);

  TurnBornCorrectUI.InitData()


  TurnBornCorrectUI.raceIndex=1;
  TurnBornCorrectUI.roleIndex =1;
  for i = 1, #TurnBornCorrectUI.raceTable do
    local raceData = TurnBornCorrectUI.raceTable[i];
    local raceBtn = _gt.GetUI("raceBtn"..i)
    local roleList = _gt.GetUI("roleList"..i)

    local curText = GUI.GetChild(raceBtn,"curText");
    if i==TurnBornCorrectUI.raceIndex then
      TurnBornCorrectUI.raceIndex=i;
      GUI.SetVisible(roleList,true);
    else
      GUI.SetVisible(roleList,false);
    end
    GUI.SetVisible(curText,false);

    for j = 1, #raceData.RoleIds do
      local roleItem = GUI.GetChild(roleList,"roleItem"..j);
      local curMark = GUI.GetChild(roleItem,"curMark");
      GUI.SetVisible(curMark,false);
      GUI.CheckBoxExSetCheck(roleItem,j==TurnBornCorrectUI.roleIndex);
    end
  end


  CL.SendNotify(NOTIFY.SubmitForm, "FormReincarnation", "GetData")
end

function TurnBornCorrectUI.Refresh()

  local preRoleId =TurnBornCorrectUI.data[TurnBornCorrectUI.turnIndex]
  local preRace=0;
  if preRoleId~=nil then
    preRace= DB.GetRole(preRoleId).Race;
  end

  for i = 1, #TurnBornCorrectUI.raceTable do
    local raceData = TurnBornCorrectUI.raceTable[i];
    local raceBtn = _gt.GetUI("raceBtn"..i)
    local roleList = _gt.GetUI("roleList"..i)
    local curText = GUI.GetChild(raceBtn,"curText");
    GUI.SetVisible(curText,raceData.Race == preRace);
    for j = 1, #raceData.RoleIds do
      local roleId = raceData.RoleIds[j];
      local roleItem = GUI.GetChild(roleList,"roleItem"..j);
      local curMark = GUI.GetChild(roleItem,"curMark");
      GUI.SetVisible(curMark,roleId== preRoleId);
      GUI.CheckBoxExSetCheck(roleItem,j==TurnBornCorrectUI.roleIndex);
    end
  end


  local roleId = TurnBornCorrectUI.GetCurRoleId();
  local turnScroll = _gt.GetUI("turnScroll");
  GUI.LoopScrollRectSetTotalCount(turnScroll, REINCARNATION_DATA.Reincarnation_Count);
  GUI.LoopScrollRectRefreshCells(turnScroll);

  local confirmBtn =_gt.GetUI("confirmBtn");
  local noReText =_gt.GetUI("noReText");
  local curAttrScroll =_gt.GetUI("curAttrScroll");
  if  TurnBornCorrectUI.turnIndex<=CL.GetIntAttr(RoleAttr.RoleAttrReincarnation) and preRoleId ~=nil then
    GUI.SetVisible(curAttrScroll,true);
    GUI.SetVisible(noReText,false)
    GUI.ButtonSetShowDisable(confirmBtn,roleId ~= preRoleId);
    GUI.LoopScrollRectSetTotalCount(curAttrScroll, #REINCARNATION_DATA["Reincarnation_"..TurnBornCorrectUI.turnIndex]["Role_".. preRoleId]);
    GUI.LoopScrollRectRefreshCells(curAttrScroll);

  else
    GUI.SetVisible(curAttrScroll,false)
    GUI.SetVisible(noReText,true);
    GUI.ButtonSetShowDisable(confirmBtn,false);
  end

  local reData =REINCARNATION_DATA["Reincarnation_"..TurnBornCorrectUI.turnIndex]
  local nextAttrScroll =_gt.GetUI("nextAttrScroll");
  GUI.LoopScrollRectSetTotalCount(nextAttrScroll, #reData["Role_"..roleId]);
  GUI.LoopScrollRectRefreshCells(nextAttrScroll);

  local consumeIcon =_gt.GetUI("consumeIcon");
  local consumeNum =_gt.GetUI("consumeNum");
  GUI.ImageSetImageID(consumeIcon,UIDefine.GetMoneyIcon(reData.Reincarnation_Cost.Money_Type))
  GUI.StaticSetText(consumeNum,reData.Reincarnation_Cost.Cost)
end


--退出界面
function TurnBornCorrectUI.OnExit()
  GUI.CloseWnd("TurnBornCorrectUI");
end


function TurnBornCorrectUI.CreateCurAttrItem()
  local curAttrScroll = _gt.GetUI("curAttrScroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(curAttrScroll);
  local attrItem =  GUI.GroupCreate(curAttrScroll,"attrItem"..curCount,0,0,0,0);

  local attrName = GUI.CreateStatic(attrItem, "attrName", "属性", 20, 0, 150, 35);
  GUI.SetColor(attrName, UIDefine.BrownColor);
  GUI.StaticSetFontSize(attrName, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(attrName, TextAnchor.MiddleLeft);
  UILayout.SetSameAnchorAndPivot(attrName, UILayout.Left);
  Tips.RegisterAttrHintEvent(attrName,"TurnBornCorrectUI")

  local attrValue = GUI.CreateStatic(attrItem, "attrValue", "100", 150, 0, 200, 35);
  GUI.SetColor(attrValue, UIDefine.Green5Color);
  GUI.StaticSetFontSize(attrValue, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(attrValue, TextAnchor.MiddleLeft);
  GUI.StaticSetAutoSize(attrValue,true)
  UILayout.SetSameAnchorAndPivot(attrValue, UILayout.Left);

  return attrItem;
end

function TurnBornCorrectUI.CreateNextAttrItem()
  local nextAttrScroll = _gt.GetUI("nextAttrScroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(nextAttrScroll);
  local attrItem =  GUI.GroupCreate(nextAttrScroll,"attrItem"..curCount,0,0,0,0);

  local attrName = GUI.CreateStatic(attrItem, "attrName", "属性", 20, 0, 150, 35);
  GUI.SetColor(attrName, UIDefine.BrownColor);
  GUI.StaticSetFontSize(attrName, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(attrName, TextAnchor.MiddleLeft);
  UILayout.SetSameAnchorAndPivot(attrName, UILayout.Left);
  Tips.RegisterAttrHintEvent(attrName,"TurnBornCorrectUI")

  local attrValue = GUI.CreateStatic(attrItem, "attrValue", "100", 150, 0, 200, 35);
  GUI.SetColor(attrValue, UIDefine.Green5Color);
  GUI.StaticSetFontSize(attrValue, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(attrValue, TextAnchor.MiddleLeft);
  GUI.StaticSetAutoSize(attrValue,true)
  UILayout.SetSameAnchorAndPivot(attrValue, UILayout.Left);

  return attrItem;
end


function TurnBornCorrectUI.RefreshCurAttrScroll(parameter)
  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2]);
  local attrItem= GUI.GetByGuid(guid);
  index =index+1;

  local configIndex =TurnBornCorrectUI.data[TurnBornCorrectUI.turnIndex]
  local skillData = REINCARNATION_DATA["Reincarnation_"..TurnBornCorrectUI.turnIndex]["Role_"..configIndex][index]

  local attrDB = DB.GetOnceAttrByKey2(skillData[1]);
  local attrName = GUI.GetChild(attrItem,"attrName");
  local attrValue = GUI.GetChild(attrItem,"attrValue");
  GUI.StaticSetText(attrName,attrDB.ChinaName );
  local value = skillData[2]
  if attrDB.IsPct == 1 then
    value = tostring(tonumber(value)/100).."%"
  end
  GUI.StaticSetText(attrValue,"+"..value);
end


function TurnBornCorrectUI.RefreshNextAttrScroll(parameter)
  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2]);
  local attrItem= GUI.GetByGuid(guid);
  index =index+1;

  local roleId = TurnBornCorrectUI.GetCurRoleId();
  local attrData = REINCARNATION_DATA["Reincarnation_"..TurnBornCorrectUI.turnIndex]["Role_"..roleId][index]

  local attrDB = DB.GetOnceAttrByKey2(attrData[1]);
  local attrName = GUI.GetChild(attrItem,"attrName");
  local attrValue = GUI.GetChild(attrItem,"attrValue");
  GUI.StaticSetText(attrName,attrDB.ChinaName );
  local value = attrData[2]
  if attrDB.IsPct == 1 then
    value = tostring(tonumber(value)/100).."%"
  end
  GUI.StaticSetText(attrValue,"+"..value);
end


function TurnBornCorrectUI.OnConfirmBtnClick()
  local roleId =TurnBornCorrectUI.GetCurRoleId();
  print("ChangeReincarnationByRole:"..TurnBornCorrectUI.turnIndex.."-"..roleId)
  CL.SendNotify(NOTIFY.SubmitForm, "FormReincarnation", "ChangeReincarnationByRole",TurnBornCorrectUI.turnIndex,roleId);
end







function TurnBornCorrectUI.OnRaceBtnClick(guid)
  local raceBtn = GUI.GetByGuid(guid)
  local index = tonumber(GUI.GetData(raceBtn,"Index"));

  local roleList = _gt.GetUI("roleList"..index);
  if TurnBornCorrectUI.raceIndex~=index then
    local preRoleList = _gt.GetUI("roleList"..TurnBornCorrectUI.raceIndex);
    GUI.SetVisible(preRoleList,false);
    TurnBornCorrectUI.raceIndex=index;
    TurnBornCorrectUI.roleIndex=1;
    GUI.SetVisible(roleList,true);
  else
    GUI.SetVisible(roleList,not GUI.GetVisible(roleList));
  end

  TurnBornCorrectUI.Refresh()
end

function TurnBornCorrectUI.GetCurRoleId()
  return TurnBornCorrectUI.raceTable[TurnBornCorrectUI.raceIndex].RoleIds[TurnBornCorrectUI.roleIndex];
end

function TurnBornCorrectUI.OnRoleItemClick(guid)
  local roleItem  = GUI.GetByGuid(guid);
  local index = tonumber(GUI.GetData(roleItem,"Index"));

  if  TurnBornCorrectUI.roleIndex ==index then
      GUI.CheckBoxExSetCheck(roleItem,true);
      return;
  end

  local roleList = _gt.GetUI("roleList"..TurnBornCorrectUI.raceIndex);
  local preRoleItem =GUI.GetChild(roleList,"roleItem"..TurnBornCorrectUI.roleIndex)
  GUI.CheckBoxExSetCheck(preRoleItem,false);
  TurnBornCorrectUI.roleIndex =index;
  GUI.CheckBoxExSetCheck(roleItem,true);

  local turnScroll = GUI.GetByGuid(_gt.turnScroll);
  GUI.ScrollRectSetNormalizedPosition(turnScroll, Vector2.New(0, 0));
  TurnBornCorrectUI.Refresh();
end

function TurnBornCorrectUI.CreateTurnItem()
  local turnScroll = _gt.GetUI("turnScroll")
  local curCount = GUI.LoopScrollRectGetChildInPoolCount(turnScroll);
  local turnItem = GUI.CheckBoxExCreate(turnScroll, "turnItem"..curCount, "1800402030", "1800402032", 0, 0, false, 150, 50)
  GUI.RegisterUIEvent(turnItem, UCE.PointerClick, "TurnBornCorrectUI", "OnTurnItemClick");

  local nameText = GUI.CreateStatic(turnItem, "nameText","1转修正", 0, 0, 150, 35);
  GUI.StaticSetFontSize(nameText, UIDefine.FontSizeM)
  GUI.SetColor(nameText, UIDefine.BrownColor);
  GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(nameText, UILayout.Center);

  return turnItem;
end

function TurnBornCorrectUI.RefreshTrunScroll(parameter)
  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2]);
  index=index+1;
  local turnItem = GUI.GetByGuid(guid);
  local nameText = GUI.GetChild(turnItem,"nameText");
  GUI.StaticSetText(nameText,index.."转修正")
  if index==TurnBornCorrectUI.turnIndex then
    GUI.CheckBoxExSetCheck(turnItem,true);
  else
    GUI.CheckBoxExSetCheck(turnItem,false);
  end
end

function TurnBornCorrectUI.OnTurnItemClick(guid)
  local turnItem = GUI.GetByGuid(guid);
  local index = GUI.CheckBoxExGetIndex(turnItem)
  index=index+1;
  TurnBornCorrectUI.turnIndex=index;
  TurnBornCorrectUI.Refresh();
end