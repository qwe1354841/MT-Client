local BubbleMessageUI = {}
_G.BubbleMessageUI = BubbleMessageUI

if _G.BubbleMessageData==nil then
  _G.BubbleMessageData={}
end

local intervalTime=0.25;
local showDuration=0.2;
local hideDuration=0.3;
local playDuration=1;
local posY={58, 118,178};


function BubbleMessageUI.Main(parameter)

  local wnd = GUI.WndCreateWnd("BubbleMessageUI" , "BubbleMessageUI" , 0 , 0,eCanvasGroup.Top);

  for i = 1, 3 do
    local bubble=GUI.GroupCreate(wnd,"bubble"..i,0,0,0,0);
    UILayout.SetSameAnchorAndPivot(bubble, UILayout.Center)
    GUI.RegisterUIEvent(bubble,ULE.TweenCallBack,"BubbleMessageUI","DoTweenCallback");
    GUI.SetIsRaycastTarget(bubble,false);


    local bg=GUI.ImageCreate(bubble,"bg", "1800001240", 0, 0, false, 200, 50);
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)

    local msgText = GUI.RichEditCreate(bg,"msgText","测试测试",0,0,200,60);
    GUI.StaticSetAlignment(msgText, TextAnchor.MiddleCenter);
    GUI.StaticSetFontSize(msgText,UIDefine.FontSizeL);

    GUI.SetVisible(bubble,false);
  end

  BubbleMessageUI.InitData()
end

function BubbleMessageUI.StopTimer()
  if _G.BubbleMessageData.Timer~=nil then
    _G.BubbleMessageData.Timer:Stop();
    _G.BubbleMessageData.Timer=nil;
  end
end

function BubbleMessageUI.OnDestroy()
  BubbleMessageUI.InitData()
end

function BubbleMessageUI.InitData()
  BubbleMessageUI.isInit=false;
  BubbleMessageUI.isRun=false;
  BubbleMessageUI.index=1;

  BubbleMessageUI.bubbleQueue={};

  BubbleMessageUI.StopTimer();

end

function BubbleMessageUI.OnShow(parameter)
  local wnd = GUI.GetWnd("BubbleMessageUI");
  if wnd == nil then
    return;
  end

  GUI.SetVisible(wnd, true);

  if BubbleMessageUI.isInit==nil then
    BubbleMessageUI.InitData();
  end

  if not BubbleMessageUI.isRun then
    BubbleMessageUI.Bubble()
  end

end

function BubbleMessageUI.Bubble()

  local msg =CL.PeekBBMsg();
  if msg==nil or msg=="" then
    BubbleMessageUI.isRun=false;
    return;
  end

  BubbleMessageUI.isRun =true;
  if  #BubbleMessageUI.bubbleQueue>=3 then
    if _G.BubbleMessageData.Timer==nil then
      _G.BubbleMessageData.Timer=Timer.New(BubbleMessageUI.ActiveBubble,intervalTime,-1)
      _G.BubbleMessageData.Timer:Start();
    end
  else
    BubbleMessageUI.StopTimer()
    BubbleMessageUI.ActiveBubble();
  end
end


function BubbleMessageUI.ActiveBubble()

  local msg =CL.DequeueBBMsg();
  if msg==nil or msg=="" then
    return;
  end
  local wnd = GUI.GetWnd("BubbleMessageUI")
  local bubble = GUI.GetChild(wnd,"bubble"..BubbleMessageUI.index);

  BubbleMessageUI.ShowBubble(bubble,msg);

  table.insert(BubbleMessageUI.bubbleQueue,1,GUI.GetGuid(bubble))

  if #BubbleMessageUI.bubbleQueue>3 then
    local guid = table.remove(BubbleMessageUI.bubbleQueue);
  end

  BubbleMessageUI.index=BubbleMessageUI.index+1;
  if BubbleMessageUI.index>3 then
    BubbleMessageUI.index=1;
  end


  if #BubbleMessageUI.bubbleQueue>=2 then
    for i = 2, #BubbleMessageUI.bubbleQueue do
      local bubble=GUI.GetByGuid(BubbleMessageUI.bubbleQueue[i])
      BubbleMessageUI.Move(bubble,posY[i])
    end
  end

  BubbleMessageUI.Bubble()
end

function BubbleMessageUI.ShowBubble(bubble,msg)
  local bg = GUI.GetChild(bubble,"bg")
  local msgText =  GUI.GetChild(bg,"msgText")
  GUI.StaticSetText(msgText,UIDefine.ReplaceSpecialRichText(msg));
  UILayout.SetUrlColor(msgText, true)
  local w = GUI.RichEditGetPreferredWidth(msgText);

  GUI.SetWidth(msgText,w);
  GUI.SetWidth(bg,w+20);

  GUI.StopTween(bubble,GUITweenType.DOScale)
  GUI.StopTween(bubble,GUITweenType.DOLocalMove)
  GUI.StopTween(bubble,GUITweenType.DOGroupAlpha)
  GUI.SetVisible(bubble,true);
  GUI.SetGroupAlpha(bubble,0.1);
  GUI.SetPositionY(bubble,-posY[1]);


  local data=TweenData.New();
  data.Type =GUITweenType.DOGroupAlpha;
  data.Duration=showDuration;
  data.From = Vector3.New(0.1,0,0);
  data.To =  Vector3.New(1,0,0);
  data.LoopType = UITweenerStyle.Once;
  GUI.DOTween(bubble,data,"Show");
end


function BubbleMessageUI.Move(bubble,posY)
  local curPosY=GUI.GetPositionY(bubble)

  local data=TweenData.New();
  data.Type =GUITweenType.DOLocalMove;
  data.Duration=showDuration;
  data.From = Vector3.New(0,-curPosY,0);
  data.To = Vector3.New(0,-posY,0);
  data.LoopType = UITweenerStyle.Once;
  GUI.DOTween(bubble,data);
end

function BubbleMessageUI.Hide(bubble)
  local data=TweenData.New();
  data.Type =GUITweenType.DOGroupAlpha;
  data.Duration=hideDuration;
  data.From = Vector3.New(1,0,0);
  data.To =  Vector3.New(0,0,0);
  data.LoopType = UITweenerStyle.Once;
  GUI.DOTween(bubble,data,"Hide");
end

function BubbleMessageUI.Play(bubble)
  local data=TweenData.New();
  data.Type =GUITweenType.DOScale;
  data.Duration=playDuration;
  data.From = Vector3.New(1,1,1);
  data.To =  Vector3.New(1,1,1);
  data.LoopType = UITweenerStyle.Once;
  GUI.DOTween(bubble,data,"Play");
end

function BubbleMessageUI.DoTweenCallback(guid ,key)
  local bubble = GUI.GetByGuid(guid);

  if key=="Show" then
    BubbleMessageUI.Play(bubble)
  end

  if key=="Play" then
    BubbleMessageUI.Hide(bubble)
  end

  if key=="Hide" then
    if BubbleMessageUI.bubbleQueue~=nil then
      local guid= table.remove(BubbleMessageUI.bubbleQueue);
    end

  end
end


function BubbleMessageUI.TurnBornSuccess()

  local wnd = GUI.GetWnd("BubbleMessageUI")
  local turnBornSuccess = GUI.GroupCreate(wnd,"turnBornSuccess",0,0,0,0);
  UILayout.SetSameAnchorAndPivot(turnBornSuccess, UILayout.Center);
  GUI.RegisterUIEvent(turnBornSuccess,ULE.TweenCallBack,"BubbleMessageUI","TurnBornSuccessDoTweenCallback");
  local image= GUI.ImageCreate(turnBornSuccess, "image", "1800229280", 0, 0,false,250,80)

  GUI.SetGroupAlpha(turnBornSuccess,0);
  local data=TweenData.New();
  data.Type =GUITweenType.DOGroupAlpha;
  data.Duration=0.5;
  data.From = Vector3.New(0.1,0,0);
  data.To =  Vector3.New(1,0,0);
  data.LoopType = UITweenerStyle.Once;
  GUI.DOTween(turnBornSuccess,data);


  local data=TweenData.New();
  data.Type =GUITweenType.DOLocalMove;
  data.Duration=1;
  data.From = Vector3.New(0,0,0);
  data.To =  Vector3.New(0,-100,0);
  data.LoopType = UITweenerStyle.Once;
  GUI.DOTween(turnBornSuccess,data,"Move");
end


function BubbleMessageUI.TurnBornSuccessDoTweenCallback(guid ,key)
  local turnBornSuccess = GUI.GetByGuid(guid);
  if key=="Move" then
    GUI.Destroy(turnBornSuccess)
  end
end


function BubbleMessageUI.RoleTransferSuccess()
  print("BubbleMessageUI.RoleTransferSuccess");

  local wnd = GUI.GetWnd("BubbleMessageUI")
  local roleTransfer = GUI.GroupCreate(wnd,"roleTransfer",0,0,0,0);
  UILayout.SetSameAnchorAndPivot(roleTransfer, UILayout.Center);
  GUI.RegisterUIEvent(roleTransfer,ULE.TweenCallBack,"BubbleMessageUI","RoleTransferSuccessDoTweenCallback");
  local image= GUI.ImageCreate(roleTransfer, "image", "1800229290", 0, 0,false,250,80)

  GUI.SetGroupAlpha(roleTransfer,0);
  local data=TweenData.New();
  data.Type =GUITweenType.DOGroupAlpha;
  data.Duration=0.5;
  data.From = Vector3.New(0.1,0,0);
  data.To =  Vector3.New(1,0,0);
  data.LoopType = UITweenerStyle.Once;
  GUI.DOTween(roleTransfer,data);

  local data=TweenData.New();
  data.Type =GUITweenType.DOLocalMove;
  data.Duration=1;
  data.From = Vector3.New(0,0,0);
  data.To =  Vector3.New(0,-100,0);
  data.LoopType = UITweenerStyle.Once;
  GUI.DOTween(roleTransfer,data,"Move");
end


function BubbleMessageUI.RoleTransferSuccessDoTweenCallback(guid ,key)
  local roleTransfer = GUI.GetByGuid(guid);
  if key=="Move" then
    GUI.Destroy(roleTransfer)
  end
end


