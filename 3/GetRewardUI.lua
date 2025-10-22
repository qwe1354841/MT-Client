local GetRewardUI = {}
_G.GetRewardUI = GetRewardUI
local _gt = UILayout.NewGUIDUtilTable();

local gradeEffect1 = "#IMAGE3404100000#"
local gradeEffect2 = "#IMAGE3404200000#"

local showEffect = "#IMAGE3404000000#";

local sound = {
	[1] = "Att_zhang",
	[2] = "Panel_Warning",
}

function GetRewardUI.Main(parameter)
  _gt = UILayout.NewGUIDUtilTable();
  local wnd = GUI.WndCreateWnd("GetRewardUI", "GetRewardUI", 0, 0);

  local panelCover = GUI.ImageCreate(wnd, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
  UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center);
  GUI.SetIsRaycastTarget(panelCover, true)

  local bg = GUI.ImageCreate(wnd, "bg", "1800601240", 0, -10, false, GUI.GetWidth(wnd), 340)
  UILayout.SetSameAnchorAndPivot(bg, UILayout.Center);
  _gt.BindName(bg,"bg")

  local title = GUI.ImageCreate(bg, "title", "1800608750", 0, -70)
  UILayout.SetSameAnchorAndPivot(title, UILayout.Top);

  local itemScroll = GUI.ScrollRectCreate(bg,"itemScroll", 0, -25, 700, 250, 0, false, Vector2.New(80, 80), UIAroundPivot.Center, UIAnchor.Center, 5)
  UILayout.SetSameAnchorAndPivot(itemScroll, UILayout.Center);
  GUI.ScrollRectSetAlignment(itemScroll, TextAnchor.MiddleCenter)
  GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(15, 15))
  for i = 1, 10 do
    local itemIcon= ItemIcon.Create(itemScroll,"itemIcon"..i,0,0)
    GUI.SetData(itemIcon,"Index",i);
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "GetRewardUI", "OnItemIconClick");
    local gradeEffect= GUI.RichEditCreate(itemIcon,"gradeEffect",gradeEffect1,0,42,0,0)
    GUI.SetVisible(gradeEffect,false)
    GUI.SetIsRaycastTarget(gradeEffect,false)

    local showEffect= GUI.RichEditCreate(itemIcon,"showEffect",showEffect,0,42,0,0)
    GUI.SetWidth(showEffect,GUI.RichEditGetPreferredWidth(showEffect))
    GUI.SetHeight(showEffect,GUI.RichEditGetPreferredHeight(showEffect))
    GUI.SetVisible(showEffect,false)
    GUI.SetIsRaycastTarget(showEffect,false)
  end
  _gt.BindName(itemScroll,"itemScroll");

  local leftBtn = GUI.ButtonCreate(bg, "leftBtn", 1800402110, -115, -25, Transition.ColorTint, "左按钮", 140, 50, false);
  UILayout.SetSameAnchorAndPivot(leftBtn, UILayout.Bottom);
  GUI.ButtonSetTextColor(leftBtn, UIDefine.BrownColor);
  GUI.ButtonSetTextFontSize(leftBtn, UIDefine.FontSizeL)
  _gt.BindName(leftBtn,"leftBtn");
  GUI.RegisterUIEvent(leftBtn, UCE.PointerClick, "GetRewardUI", "OnLeftBtnClick");

  local rightBtn = GUI.ButtonCreate(bg, "rightBtn", 1800402110, 115, -25, Transition.ColorTint, "右按钮", 140, 50, false);
  UILayout.SetSameAnchorAndPivot(rightBtn, UILayout.Bottom);
  GUI.ButtonSetTextColor(rightBtn, UIDefine.BrownColor);
  GUI.ButtonSetTextFontSize(rightBtn, UIDefine.FontSizeL)
  _gt.BindName(rightBtn,"rightBtn");
  GUI.RegisterUIEvent(rightBtn, UCE.PointerClick, "GetRewardUI", "OnRightBtnClick");
end

function GetRewardUI.OnItemIconClick(guid)
  local itemIcon =GUI.GetByGuid(guid);
  local index = tonumber(GUI.GetData(itemIcon,"Index"));

  local itemInfo = GetRewardUI.itemDataList[index];
  if itemInfo ==nil then
    print("itemInfo is null:"..index);
    return;
  end

  local bg =_gt.GetUI("bg")
  if itemInfo.IsPet then
    print("KeyName"..itemInfo.KeyName);
    local petDB =DB.GetOncePetByKey2(itemInfo.KeyName)
    Tips.CreatePetTip(itemInfo.KeyName,bg,"petTips",-420,0)
  elseif itemInfo.IsGuard then
    Tips.CreateGuardTip(itemInfo.KeyName,bg,"guardTips",-420,0)
  else
    print("KeyName"..itemInfo.KeyName);
    Tips.CreateByItemKeyName(itemInfo.KeyName,bg,"itemTips",-420,0)
  end
end

function GetRewardUI.InitData()

  GetRewardUI.itemDataList ={};
  GetRewardUI.leftBtnFun= nil;
  GetRewardUI.rightBtnFun =nil;
  GetRewardUI.itemIndex=1;
  GetRewardUI.endPerformanceFun=nil
  GetRewardUI.timer=nil
end

function GetRewardUI.OnShow(parameter)
  local wnd = GUI.GetWnd("GetRewardUI");
  if wnd == nil then
    return ;
  end


  local itemScroll =_gt.GetUI("itemScroll");
  for i = 0, GUI.GetChildCount(itemScroll)-1 do
    local itemIcon = GUI.GetChildByIndex(itemScroll,i);
    local gradeEffect = GUI.GetChild(itemIcon,"gradeEffect");
    GUI.SetVisible(gradeEffect,false);
    local showEffect = GUI.GetChild(itemIcon,"showEffect");
    GUI.SetVisible(showEffect,false);

    GUI.SetVisible(itemIcon,false);
  end

  local leftBtn =_gt.GetUI("leftBtn");
  GUI.SetVisible(leftBtn,false);
  local rightBtn =_gt.GetUI("rightBtn");
  GUI.SetVisible(rightBtn,false);

  GetRewardUI.InitData();

  GUI.SetVisible(wnd, true);
end

function GetRewardUI.OnExit()
  GUI.CloseWnd("GetRewardUI")
end

function GetRewardUI.OnClose()
  if GetRewardUI.timer~=nil then
    GetRewardUI.timer:Stop();
    GetRewardUI.timer=nil;
  end

end


function GetRewardUI.ShowItem(itemDataList,endPerformanceFun,intervalTime)
  GetRewardUI.itemIndex=1;
  GetRewardUI.itemDataList=itemDataList;
  GetRewardUI.endPerformanceFun=endPerformanceFun;
  if  GetRewardUI.timer==nil then
    GetRewardUI.timer = Timer.New(GetRewardUI.Performance,intervalTime or 0.5,#GetRewardUI.itemDataList+1)
  else
    GetRewardUI.timer:Stop()
    GetRewardUI.timer:Reset(GetRewardUI.Performance, intervalTime or 0.5, #GetRewardUI.itemDataList+1)
  end

  GetRewardUI.timer:Start()
end

function GetRewardUI.Performance()

  local itemScroll =_gt.GetUI("itemScroll");

  local preItemIcon =GUI.GetChild(itemScroll,"itemIcon"..(GetRewardUI.itemIndex-1));
  if preItemIcon~=nil then
    local showEffect = GUI.GetChild(preItemIcon,"showEffect");
    GUI.SetVisible(showEffect,false);
  end


  local itemInfo = GetRewardUI.itemDataList[GetRewardUI.itemIndex];
  if itemInfo ==nil then
    return;
  end

  local itemIcon = GUI.GetChild(itemScroll,"itemIcon"..GetRewardUI.itemIndex);
  local curDB = nil;

  if itemInfo.IsPet then
	curDB = DB.GetOncePetByKey2(itemInfo.KeyName);
    GUI.SetVisible(itemIcon,true);
    ItemIcon.BindPetDB(itemIcon, curDB)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum,1);
	CL.PlayEffect(itemInfo.Sound and sound[itemInfo.Sound] or sound[2]);
  elseif itemInfo.IsGuard then
	curDB = DB.GetOnceGuardByKey2(itemInfo.KeyName);
	GUI.SetVisible(itemIcon,true);
	ItemIcon.BindGuardDB(itemIcon, curDB)
	GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum,1);
	CL.PlayEffect(itemInfo.Sound and sound[itemInfo.Sound] or sound[2]);
  else
	curDB = DB.GetOnceItemByKey2(itemInfo.KeyName);
    GUI.SetVisible(itemIcon,true);
    ItemIcon.BindItemDB(itemIcon,curDB);
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, itemInfo.Num);
    CL.PlayEffect(itemInfo.Sound and sound[itemInfo.Sound] or sound[1]);
  end

  GetRewardUI.SetGradeEffect(itemIcon,curDB)
  local showEffect = GUI.GetChild(itemIcon,"showEffect");
  GUI.SetVisible(showEffect,true);
  

  if GetRewardUI.itemIndex==#GetRewardUI.itemDataList then
    local leftBtn =_gt.GetUI("leftBtn");
    GUI.SetVisible(leftBtn,true);
    local rightBtn =_gt.GetUI("rightBtn");
    GUI.SetVisible(rightBtn,true);
  end

  GetRewardUI.itemIndex=GetRewardUI.itemIndex+1;
end


function GetRewardUI.OnLeftBtnClick()

  if GetRewardUI.leftBtnFun~=nil then
    GetRewardUI.leftBtnFun();
  end

  GetRewardUI.OnExit()
end

function GetRewardUI.OnRightBtnClick()

  if GetRewardUI.rightBtnFun~=nil then
    GetRewardUI.rightBtnFun();
  end

  GetRewardUI.OnExit()
end

function GetRewardUI.SetLeftBtn(btnName,fun)

  local leftBtn =_gt.GetUI("leftBtn");
  GUI.ButtonSetText(leftBtn,btnName)
  GetRewardUI.leftBtnFun = fun;
end

function GetRewardUI.SetRightBtn(btnName,fun)

  local rightBtn =_gt.GetUI("rightBtn");
  GUI.ButtonSetText(rightBtn,btnName)
  GetRewardUI.rightBtnFun = fun;
end


function GetRewardUI.SetGradeEffect(itemIcon,DB)


  local gradeEffect = GUI.GetChild(itemIcon,"gradeEffect");
  if DB.Grade==4 then
    GUI.SetVisible(gradeEffect,true);
    GUI.StaticSetText(gradeEffect,gradeEffect1);

    GUI.SetWidth(gradeEffect,GUI.RichEditGetPreferredWidth(gradeEffect))
    GUI.SetHeight(gradeEffect,GUI.RichEditGetPreferredHeight(gradeEffect))
  elseif DB.Grade==5 then
    GUI.SetVisible(gradeEffect,true);
    GUI.StaticSetText(gradeEffect,gradeEffect2);

    GUI.SetWidth(gradeEffect,GUI.RichEditGetPreferredWidth(gradeEffect))
    GUI.SetHeight(gradeEffect,GUI.RichEditGetPreferredHeight(gradeEffect))
  else
    GUI.SetVisible(gradeEffect,false);
  end

end