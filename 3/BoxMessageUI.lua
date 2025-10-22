local BoxMessageUI = {}
_G.BoxMessageUI = BoxMessageUI

local _gt = UILayout.NewGUIDUtilTable();
function BoxMessageUI.Main(parameter)
  _gt = UILayout.NewGUIDUtilTable();
  local wnd = GUI.WndCreateWnd("BoxMessageUI" , "BoxMessageUI" , 0 , 0,eCanvasGroup.Normal_Extend);

  local maskBtn = GUI.ButtonCreate(wnd,"maskBtn", "1800400220", 0, 0, Transition.None, "", GUI.GetWidth(wnd),  GUI.GetHeight(wnd), false);
  UILayout.SetSameAnchorAndPivot(maskBtn,UILayout.Center);
  GUI.SetColor(maskBtn,UIDefine.Transparent);

  local panelBg=GUI.ImageCreate(wnd,"panelBg","1800001120",0,0,false ,460,260);
  UILayout.SetSameAnchorAndPivot(panelBg,UILayout.Center);


  local flower=GUI.ImageCreate(panelBg,"flower","1800007060",-25,-25);
  UILayout.SetSameAnchorAndPivot(flower,UILayout.TopLeft);


  local timeDownBg=GUI.ImageCreate(panelBg,"timeDownBg","1800608050",20,15,false,50,50);
  UILayout.SetSameAnchorAndPivot(timeDownBg,UILayout.TopLeft);
  _gt.BindName(timeDownBg,"timeDownBg");

  local timeDownText=GUI.CreateStatic(timeDownBg,"timeDownText", "99", 0, 0, 50, 50);
  GUI.SetColor(timeDownText,UIDefine.WhiteColor);
  GUI.StaticSetFontSize(timeDownText, UIDefine.FontSizeM);
  GUI.StaticSetAlignment(timeDownText, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(timeDownText,UILayout.Center);


  local titleBg=GUI.ImageCreate(panelBg,"titleBg","1800001030",0,25);
  UILayout.SetSameAnchorAndPivot(titleBg,UILayout.Top);

  local titleText = GUI.CreateStatic(titleBg,"titleText", "提示", 0, 1, 200, 35);
  GUI.SetColor(titleText,UIDefine.White3Color);
  GUI.StaticSetFontSize(titleText, UIDefine.FontSizeS);
  GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(titleText,UILayout.Center);
  _gt.BindName(titleText,"titleText");

  local closeBtn=GUI.ButtonCreate(panelBg,"closeBtn", "1800002050",-20,20, Transition.ColorTint);
  UILayout.SetSameAnchorAndPivot(closeBtn,UILayout.TopRight);
  GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "BoxMessageUI", "OnCloseBtnClick");
  _gt.BindName(closeBtn,"closeBtn");

  local msgText = GUI.RichEditCreate(panelBg,"msgText","测试测试测试测试测试测试",0,0,420,120);
  GUI.StaticSetAlignment(msgText, TextAnchor.MiddleCenter);
  GUI.StaticSetFontSize(msgText,UIDefine.FontSizeS);
  GUI.SetColor(msgText,UIDefine.BrownColor);
  _gt.BindName(msgText,"msgText");

  local firstBtn=GUI.ButtonCreate(panelBg,"firstBtn","1800002060",120,-20, Transition.ColorTint, "第一按钮",130,45,false)
  UILayout.SetSameAnchorAndPivot(firstBtn,UILayout.Bottom);
  GUI.ButtonSetTextColor(firstBtn,UIDefine.WhiteColor);
  GUI.ButtonSetTextFontSize(firstBtn,UIDefine.FontSizeL)
  GUI.SetIsOutLine(firstBtn,true)
  GUI.SetOutLine_Color(firstBtn,UIDefine.OutLine_BrownColor)
  GUI.SetOutLine_Distance(firstBtn,UIDefine.OutLineDistance)
  GUI.RegisterUIEvent(firstBtn, UCE.PointerClick, "BoxMessageUI", "OnFirstBtnClick");
  _gt.BindName(firstBtn,"firstBtn");

  local secondBtn=GUI.ButtonCreate(panelBg,"secondBtn","1800002060",-120,-20, Transition.ColorTint, "第二按钮",130,45,false)
  UILayout.SetSameAnchorAndPivot(secondBtn,UILayout.Bottom);
  GUI.ButtonSetTextColor(secondBtn,UIDefine.WhiteColor);
  GUI.ButtonSetTextFontSize(secondBtn,UIDefine.FontSizeL)
  GUI.SetIsOutLine(secondBtn,true)
  GUI.SetOutLine_Color(secondBtn,UIDefine.OutLine_BrownColor)
  GUI.SetOutLine_Distance(secondBtn,UIDefine.OutLineDistance)
  GUI.RegisterUIEvent(secondBtn, UCE.PointerClick, "BoxMessageUI", "OnSecondBtnClick");
  _gt.BindName(secondBtn,"secondBtn");

end

function BoxMessageUI.OnShow(parameter)
  local wnd = GUI.GetWnd("BoxMessageUI");
  if wnd == nil then
    return;
  end
  BoxMessageUI.Pop();
end


function BoxMessageUI.OnExit()
  GUI.CloseWnd("BoxMessageUI");
  BoxMessageUI.StopTimer();
end

function BoxMessageUI.Pop()
  local boxMsg =CL.PeekBoxMsg();
  if boxMsg==nil  then
    BoxMessageUI.OnExit();
    return;
  end

  local wnd = GUI.GetWnd("BoxMessageUI");
  GUI.SetVisible(wnd,true);

  local titleText = GUI.GetByGuid(_gt.titleText);
  GUI.StaticSetText(titleText,boxMsg.title)

  local msgText = GUI.GetByGuid(_gt.msgText);
  GUI.StaticSetText(msgText,boxMsg.msg)

  local closeBtn =GUI.GetByGuid(_gt.closeBtn);
  if boxMsg.hasCloseBtn==false then
    GUI.SetVisible(closeBtn,false);
  else
    GUI.SetVisible(closeBtn,true);
  end

  local firstBtn = GUI.GetByGuid(_gt.firstBtn);
  GUI.ButtonSetText(firstBtn,boxMsg.name_1stBtn);
  GUI.ButtonSetImageID(firstBtn, boxMsg.isGreenBtn and "1800402090" or "1800002060")

  local secondBtn =GUI.GetByGuid(_gt.secondBtn);
  if boxMsg.name_2ndBtn==nil or boxMsg.name_2ndBtn=="" then
    GUI.SetVisible(secondBtn,false);
    GUI.SetPositionX(firstBtn,0);
  else
    GUI.SetVisible(secondBtn,true);
    GUI.ButtonSetText(secondBtn,boxMsg.name_2ndBtn);

    GUI.SetPositionX(firstBtn,120);
    GUI.SetPositionX(secondBtn,-120);
  end


  local timeDownBg =_gt.GetUI("timeDownBg");
  BoxMessageUI.StopTimer()
  GUI.SetVisible(timeDownBg,false);
  if boxMsg.timeType~=0 then
    BoxMessageUI.timeDownCount = boxMsg.time;
    BoxMessageUI.timer = Timer.New(BoxMessageUI.TimeDown,1,-1);
    BoxMessageUI.timer:Start();

    BoxMessageUI.TimeDown();
  end


end

function BoxMessageUI.StopTimer()
  if BoxMessageUI.timer~=nil then
    BoxMessageUI.timer:Stop();
    BoxMessageUI.timer=nil;
  end
end

function BoxMessageUI.TimeDown()

  local boxMsg =CL.PeekBoxMsg();
  if boxMsg==nil  then
    BoxMessageUI.OnExit();
    return;
  end

  if boxMsg.timeType==0 then
    BoxMessageUI.StopTimer();
    return;
  end


  local timeDownBg =_gt.GetUI("timeDownBg");
  if boxMsg.timeType==1 then
    GUI.SetVisible(timeDownBg,true);
    local timeDownText = GUI.GetChild(timeDownBg,"timeDownText");
    GUI.StaticSetText(timeDownText,BoxMessageUI.timeDownCount);
  elseif boxMsg.timeType==2 then
    GUI.SetVisible(timeDownBg,false);
    local firstBtn = _gt.GetUI("firstBtn")
    GUI.ButtonSetText(firstBtn,boxMsg.name_1stBtn.."(".. BoxMessageUI.timeDownCount..")");

  elseif boxMsg.timeType==3 then
    GUI.SetVisible(timeDownBg,false);
    local secondBtn =_gt.GetUI("secondBtn")
    GUI.ButtonSetText(secondBtn,boxMsg.name_2ndBtn.."(".. BoxMessageUI.timeDownCount..")");
  end

  BoxMessageUI.timeDownCount=BoxMessageUI.timeDownCount-1;
  if BoxMessageUI.timeDownCount<0 then
    BoxMessageUI.OnEndMsg()
  end
end

function BoxMessageUI.OnEndMsg()
  local boxMsg =CL.PeekBoxMsg()
  if boxMsg then
    BoxMessageUI.StopTimer();

    if boxMsg.timeType==1 then
      BoxMessageUI.OnCloseBtnClick()
    elseif boxMsg.timeType==2 then
      BoxMessageUI.OnFirstBtnClick()
    elseif boxMsg.timeType==3 then
      BoxMessageUI.OnSecondBtnClick()
    end
  end
end

function BoxMessageUI.OnClose()
    --执行默认取消操作>关闭操作
    if not BoxMessageUI.OnSecondBtnClick() then
      if not BoxMessageUI.OnFirstBtnClick() then
        BoxMessageUI.OnCloseBtnClick()
      end
    end
end

function BoxMessageUI.OnCloseBtnClick()
  return BoxMessageUI.CallFunc("method_closeBtn");
end

function BoxMessageUI.OnFirstBtnClick()
  return BoxMessageUI.CallFunc("method_1stBtn");

end

function BoxMessageUI.OnSecondBtnClick()
  return BoxMessageUI.CallFunc("method_2ndBtn");
end

function BoxMessageUI.CallFunc(methodStr)
  local boxMsg =CL.PeekBoxMsg();
  if boxMsg==nil or boxMsg.scriptName==nil or boxMsg.scriptName=="" then
    return true;
  end
  local ret = false
  if boxMsg[methodStr]~=nil and boxMsg[methodStr]~="" then
    local fun = _G[boxMsg.scriptName][boxMsg[methodStr]];
    if fun~=nil then
      if boxMsg.customData~=nil then
        fun(boxMsg.customData);
      else
        fun();
      end
      ret = true
    end
  end

  CL.PopBoxMsg();
  BoxMessageUI.Pop();
  return ret
end



