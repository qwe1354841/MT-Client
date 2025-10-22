local AddNewItemUI = {}
_G.AddNewItemUI = AddNewItemUI



local _gt = UILayout.NewGUIDUtilTable();

local loopInterval=0.6;

local showTime = 0.5;
local hideTime = 1;
function AddNewItemUI.Main( parameter )
  _gt = UILayout.NewGUIDUtilTable();
  local wnd = GUI.WndCreateWnd("AddNewItemUI" , "AddNewItemUI" , 0 , 0,eCanvasGroup.Normal_Extend);

  local panelBg = GUI.GroupCreate(wnd,"panelBg",0,0,GUI.GetWidth(wnd),GUI.GetHeight(wnd))
  _gt.BindName(panelBg,"panelBg");

  AddNewItemUI.InitData()

end

function AddNewItemUI.InitData()
  AddNewItemUI.itemGuidList={};
  AddNewItemUI.isPlaying=false;
  AddNewItemUI.imagePool ={};
  if AddNewItemUI.Timer~=nil then
    AddNewItemUI.Timer:Stop();
  end
  AddNewItemUI.Timer=nil
end

function AddNewItemUI.OnShow(parameter)
  local wnd = GUI.GetWnd("AddNewItemUI");
  if wnd == nil then
    return;
  end

  GUI.SetVisible(wnd, true);
end

function AddNewItemUI.Add(itemGuid)
  --限量20个
  if AddNewItemUI.itemGuidList and #AddNewItemUI.itemGuidList > 20 then
      print("限量20个,不加itemGuid="..tostring(itemGuid))
      return
  end
  table.insert(AddNewItemUI.itemGuidList,itemGuid);
  AddNewItemUI.StartPerformance();
end

function AddNewItemUI.StartPerformance()

  if AddNewItemUI.isPlaying==true then
    return;
  end

  AddNewItemUI.isPlaying=true;
  if AddNewItemUI.Timer==nil then
    AddNewItemUI.Timer=Timer.New(AddNewItemUI.UpdatePerformance,loopInterval,-1)
  else
    AddNewItemUI.Timer:Stop();
    AddNewItemUI.Timer:Reset(AddNewItemUI.UpdatePerformance,loopInterval,-1);
  end
  AddNewItemUI.UpdatePerformance();
  AddNewItemUI.Timer:Start();

end


function AddNewItemUI.UpdatePerformance()
  if #AddNewItemUI.itemGuidList<=0 then
    AddNewItemUI.StopPerformance();
    return;
  end

  local itemGuid = table.remove(AddNewItemUI.itemGuidList,1);
  local itemId = LD.GetItemAttrByGuidInAll(ItemAttr_Native.Id,itemGuid);
  if itemId=="" then
    return;
  end
  itemId=tonumber(itemId);
  local itemDB = DB.GetOnceItemByKey1(itemId);
  if itemDB.Id~=0 then
    local icon = AddNewItemUI.CreateIcon(tostring(itemDB.Icon));

    local data=TweenData.New();
    data.Type =GUITweenType.DOScale;
    data.Duration=showTime;
    data.From = Vector3.New(1,1,1);
    data.To =  Vector3.New(1.2,1.2,1.2);
    data.LoopType = UITweenerStyle.Once;
    GUI.DOTween(icon,data,"Show");

  end

end


function AddNewItemUI.StopPerformance()
  AddNewItemUI.isPlaying=false;
  if AddNewItemUI.Timer~=nil then
    AddNewItemUI.Timer:Stop();
    AddNewItemUI.Timer=nil;
  end

end

function AddNewItemUI.DoTweenCallback(guid ,key)
  local icon = GUI.GetByGuid(guid);

  if key=="Show" then

    local bagBtn=GUI.Get("MainUI/rightBg/bagBtn");
    if bagBtn==nil then
      AddNewItemUI.RecycleIcon(icon);
      return;
    end

    local panel=GUI.GetWnd("MainUI")
    local endScreenPoint=GUI.GetScreenPoint(bagBtn)
    local endPoint=GUI.GetPointByScreenPoint(panel,endScreenPoint)

    local data1=TweenData.New();
    data1.Type =GUITweenType.DOLocalMove;
    data1.Duration=hideTime;
    data1.From = Vector3.New(0,0,0);
    data1.To =  Vector3.New(endPoint.x,-endPoint.y,endPoint.z);
    data1.LoopType = UITweenerStyle.Once;
    GUI.DOTween(icon,data1);


    local data2=TweenData.New();
    data2.Type =GUITweenType.DOScale;
    data2.Duration=hideTime;
    data2.From = Vector3.New(1,1,1);
    data2.To =  Vector3.New(0.2,0.2,0.2);
    data2.LoopType = UITweenerStyle.Once;
    GUI.DOTween(icon,data2);

    local data3=TweenData.New();
    data3.Type =GUITweenType.DOGroupAlpha;
    data3.Duration=hideTime;
    data3.From = Vector3.New(1,1,1);
    data3.To =  Vector3.New(0,0,0);
    data3.LoopType = UITweenerStyle.Once;
    GUI.DOTween(icon,data3,"Hide");

  end

  if key=="Hide" then
    AddNewItemUI.RecycleIcon(icon)
  end
end


function AddNewItemUI.CreateIcon(imageId)

  for i = 1, #AddNewItemUI.imagePool do
    local data = AddNewItemUI.imagePool[i];
    if data.Visble == false then
      data.Visble = true;
      local icon =GUI.GetByGuid(data.Guid);
      GUI.SetVisible(icon,true);
      GUI.ImageSetImageID(icon,imageId)
      return icon;
    end
  end

  local panelBg  = _gt.GetUI("panelBg")
  if imageId==nil then
    imageId="1900000000"
  end
  local icon = GUI.ImageCreate(panelBg, "icon".. #AddNewItemUI.imagePool, imageId, 0, 0)
  UILayout.SetSameAnchorAndPivot(icon,UILayout.Center);
  GUI.RegisterUIEvent(icon,ULE.TweenCallBack,"AddNewItemUI","DoTweenCallback");
  table.insert(AddNewItemUI.imagePool, { Visble=true, Guid=GUI.GetGuid(icon)});
  return icon;

end

function AddNewItemUI.RecycleIcon(icon)
  for i = 1, #AddNewItemUI.imagePool do
    local data = AddNewItemUI.imagePool[i];
    if data.Guid == GUI.GetGuid(icon) then
      data.Visble = false;
      GUI.StopTween(icon,GUITweenType.DOLocalMove)
      GUI.StopTween(icon,GUITweenType.DOGroupAlpha)
      GUI.StopTween(icon,GUITweenType.DOScale)
      GUI.SetVisible(icon, false);
      GUI.SetScale(icon,Vector3.New(1,1,1));
      GUI.SetGroupAlpha(icon,1);
      GUI.SetPositionX(icon,0);
      GUI.SetPositionY(icon,0)
    end
  end
end


function AddNewItemUI.OnClose()
  AddNewItemUI.InitData()
end