local FirstRechargeUI = {}
_G.FirstRechargeUI = FirstRechargeUI



local _gt = UILayout.NewGUIDUtilTable();
function FirstRechargeUI.Main(parameter)
  _gt = UILayout.NewGUIDUtilTable();
  local wnd = GUI.WndCreateWnd("FirstRechargeUI", "FirstRechargeUI", 0, 0);

  local panelCover = GUI.ImageCreate(wnd, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
  GUI.SetIsRaycastTarget(panelCover, true)
  panelCover:RegisterEvent(UCE.PointerClick)
  UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center);

  local panelBg = GUI.ImageCreate(wnd, "panelBg", "1801508010", 0, 0);
  UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center);
  _gt.BindName(panelBg, "panelBg");

  local rechargeBtn = GUI.ButtonCreate(panelBg, "rechargeBtn", "1801402010", -170, 200, Transition.ColorTint);
  UILayout.SetSameAnchorAndPivot(rechargeBtn, UILayout.Center);
  GUI.RegisterUIEvent(rechargeBtn, UCE.PointerClick, "FirstRechargeUI", "OnRechargeBtnClick");

  local rechargeTextImg = GUI.ImageCreate(rechargeBtn, "rechargeTextImg", "1801504080", 0, 0);
  UILayout.SetSameAnchorAndPivot(rechargeTextImg, UILayout.Center);
  _gt.BindName(rechargeTextImg, "rechargeTextImg");

  local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1801502010", 425, -92, Transition.ColorTint, "", 50, 50, false)
  UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.Center);
  GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FirstRechargeUI", "OnExit");

	--字体节点
	local TypefaceGroup=GUI.GroupCreate(panelBg,"TypefaceGroup",450,220,0,0,false)
	UILayout.SetSameAnchorAndPivot(TypefaceGroup, UILayout.TopLeft);
	--充值金额 字体
	-- local ChongZhiJinEPic = GUI.ImageCreate(TypefaceGroup, "ChongZhiJinE","1801504010",0,0)
    local ChongZhiJinEPic = GUI.CreateStatic(TypefaceGroup,"ChongZhiJinEPic","充值金额",0,-13,116,50,"101");
    GUI.SetAnchor(ChongZhiJinEPic,UIAnchor.TopLeft)
    FirstRechargeUI.SetFontColor(ChongZhiJinEPic, 1)
    --金额
	-- local JinEPic = GUI.ImageCreate(TypefaceGroup, "JinE","1801504050",120,0)
    local JinEPic = GUI.RichEditCreate(TypefaceGroup,"JinEPic","<i>6元</i>",120,-13,116,50,"101");
	UILayout.SetSameAnchorAndPivot(JinEPic, UILayout.TopLeft);
    FirstRechargeUI.SetFontColor(JinEPic, 2)
	--送 字段
	-- local SongPic1 = GUI.ImageCreate(TypefaceGroup, "Song","1801504020",180,0)
    local SongPic = GUI.CreateStatic(TypefaceGroup,"SongPic","送",180,-13,116,50,"101");
    UILayout.SetSameAnchorAndPivot(SongPic, UILayout.TopLeft);
    FirstRechargeUI.SetFontColor(SongPic, 1)
	--强力 字段
	-- local QiangLiPic = GUI.ImageCreate(TypefaceGroup, "QiangLi","1801504030",30,45)
    local QiangLiPic = GUI.CreateStatic(TypefaceGroup,"QiangLiPic","强力",20,32,116,50,"101");
	UILayout.SetSameAnchorAndPivot(QiangLiPic, UILayout.TopLeft);
    FirstRechargeUI.SetFontColor(QiangLiPic, 1)
    --四连击 字段
	-- local SiLianJiPic = GUI.ImageCreate(TypefaceGroup, "SiLianJi","1801504060",85,45);
    local SiLianJiPic = GUI.RichEditCreate(TypefaceGroup,"SiLianJiPic","<i>四连击</i>",74,32,116,50,"101");
	UILayout.SetSameAnchorAndPivot(SiLianJiPic, UILayout.TopLeft);
    FirstRechargeUI.SetFontColor(SiLianJiPic, 2)
	--SSR侍从 字段
	-- local SSRShiCongPic = GUI.ImageCreate(TypefaceGroup, "SSRShiCong","1801504040",170,45);
    local SSRShiCongPic = GUI.CreateStatic(TypefaceGroup,"QiangLiPic","SSR侍从",170,32,116,50,"101");
	UILayout.SetSameAnchorAndPivot(SSRShiCongPic, UILayout.TopLeft);
    FirstRechargeUI.SetFontColor(SSRShiCongPic, 1)
    --金角大王 字段
	-- local JinJiaoDaWangPic = GUI.ImageCreate(TypefaceGroup, "JinJiaoDaWang","1801504070",270,40);
    local JinJiaoDaWangPic = GUI.RichEditCreate(TypefaceGroup,"JinJiaoDaWangPic","<i>金角大王</i>",285,32,160,50,"101");
    UILayout.SetSameAnchorAndPivot(JinJiaoDaWangPic, UILayout.TopLeft);
    FirstRechargeUI.SetFontColor(JinJiaoDaWangPic, 3)

	local _TitlePic = GUI.ImageCreate(panelBg, "TitlePic","1801508020",280,160);
	UILayout.SetSameAnchorAndPivot(_TitlePic, UILayout.Center);

	local DialogBoxBg = GUI.ImageCreate(panelBg, "DialogBoxBg","1800700240",0,-420);
	UILayout.SetSameAnchorAndPivot(DialogBoxBg, UILayout.TopLeft);
	data = TweenData.New()
	data.Type = GUITweenType.DOLocalMoveY
	data.Duration = 2
	data.To = Vector3.New(0,  15, 0)
	local Keyframe ="((-2.311231,-2.311231,34,-0.00701759,-0.002449036),(0.03038119,0.03038119,0,0.2328766,-0.5569),(0.008459799,0.008459799,0,0.7485815,0.5560657),(-2.333295,-2.333295,34,0.987442,-0.001266479))"
	data.Keyframe = TOOLKIT.Str2Curve(Keyframe)
	data.LoopType = UITweenerStyle.Loop
	GUI.DOTween(DialogBoxBg,data)
	GUI.SetScale(DialogBoxBg,Vector3(1,-1,1))

	local msg = CL.GetRoleName(0)..[[！
我叫你一声，你敢答应吗？]]
	local DialogBoxText = GUI.CreateStatic(DialogBoxBg,"DialogBoxText", msg,20,-10,300,100,"system",false,false);
	GUI.StaticSetFontSize(DialogBoxText, 22)
	GUI.StaticSetAlignment(DialogBoxText, TextAnchor.MiddleLeft)
	UILayout.SetSameAnchorAndPivot(DialogBoxText, UILayout.Center);
	GUI.SetColor(DialogBoxText,Color.New(154/255,109/255,62/255,255/255))
	GUI.SetScale(DialogBoxText,Vector3(1,-1,1))
	_gt.BindName(DialogBoxText, "DialogBoxText");
  -- local textImage = GUI.ImageCreate(panelBg, "textImage", "1801504010", 30, -15, false, 125, 38);
  -- UILayout.SetSameAnchorAndPivot(textImage, UILayout.Center);

  -- local amountText = GUI.CreateStatic(panelBg, "amountText", "1元", 600, -13, 150, 35)
  -- amountText.Style = FontStyle.Italic
  -- GUI.StaticSetFontSize(amountText, UIDefine.FontSizeXXL)
  -- GUI.StaticSetAlignment(amountText, TextAnchor.MiddleLeft);
  -- GUI.SetColor(amountText, UIDefine.WhiteColor)
  -- GUI.SetIsOutLine(amountText, true)
  -- GUI.SetOutLine_Color(amountText, UIDefine.OutLine_YellowColor)
  -- GUI.SetOutLine_Distance(amountText, UIDefine.OutLineDistance)
  -- UILayout.SetSameAnchorAndPivot(amountText, UILayout.Left);
  -- _gt.BindName(amountText, "amountText");

  FirstRechargeUI.itemList = {}
  CL.SendNotify(NOTIFY.SubmitForm, "FormFirstRecharge", "GetData")
end

-- 充值金额这类 ： 1
-- 6元这类 ：2
-- 金角大王 ： 3
function FirstRechargeUI.SetFontColor(font, index)
    if index == 1 then
        GUI.SetPivot(font,UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(font,27)
        GUI.StaticSetIsGradientColor(font,true)
        GUI.StaticSetGradient_ColorBottom(font,Color.New(236/255,219/255,161/255,255/255))
        --设置描边
        GUI.SetIsOutLine(font,true)
        GUI.SetOutLine_Distance(font,3)
        GUI.SetOutLine_Color(font,Color.New(140/255,107/255,32/255,255/255))
    elseif index == 2 then
        GUI.SetPivot(font,UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(font,30)
        GUI.StaticSetIsGradientColor(font,true)
        GUI.StaticSetGradient_ColorTop(font,Color.New(255/255,203/255,85/255,255/255))
        GUI.StaticSetGradient_ColorBottom(font,Color.New(255/255,238/255,187/255,255/255))
        --设置描边
        GUI.SetIsOutLine(font,true)
        GUI.SetOutLine_Distance(font,3)
        GUI.SetOutLine_Color(font,Color.New(185/255,116/255,14/255,255/255))
    elseif index == 3 then
        GUI.SetPivot(font,UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(font,32)
        GUI.StaticSetIsGradientColor(font,true)
        GUI.StaticSetGradient_ColorTop(font,Color.New(255/255,253/255,179/255,255/255))
        GUI.StaticSetGradient_ColorBottom(font,Color.New(255/255,206/255,33/255,255/255))
        --设置描边
        GUI.SetIsOutLine(font,true)
        GUI.SetOutLine_Distance(font,3)
        GUI.SetOutLine_Color(font,Color.New(176/255,77/255,11/255,255/255))
        -- 设置阴影
        GUI.SetIsShadow(font,true)
        GUI.SetShadow_Distance(font,Vector2.New(0,-1))
        GUI.SetShadow_Color(font,UIDefine.BlackColor)
    end
end

function FirstRechargeUI.GetConfig(money, config,guardData)
  print("FirstRechargeUI.GetConfig:" .. money)
  if CL.GetMode() == 1 then
    local inspect = require("inspect")
    print(inspect(config))
    print(inspect(guardData))
  end

  local n = 0;
  if guardData and #guardData > 0 then
    n = n + 1
    FirstRechargeUI.itemList[n] = {KeyName = guardData[1]}
    FirstRechargeUI.itemList[n].Num = 1
    FirstRechargeUI.itemList[n].Bind = guardData[2]
    FirstRechargeUI.itemList[n].isGuard = true
  end
  for i, v in ipairs(config) do
    if type(v) == "string" then
      n = n + 1;
      FirstRechargeUI.itemList[n] = {KeyName = v };
      if type(config[i + 1]) == "number" then
        FirstRechargeUI.itemList[n].Num = config[i + 1];
      elseif n then
        FirstRechargeUI.itemList[n].Num = 1;
      end

      if type(config[i + 2]) == "number" then
        FirstRechargeUI.itemList[n].Bind = config[i + 2];
      else
        FirstRechargeUI.itemList[n].Bind = 1;
      end
    end
  end

  local x =-80;
  local y = 80;
  local panelBg = _gt.GetUI("panelBg")
  for i = 1, #FirstRechargeUI.itemList do
    local data=FirstRechargeUI.itemList[i]
    local itemName = data.KeyName
    if string.find(itemName,"#") then
      itemName = string.split(itemName,"#")[1]
    end
    local itemDB =DB.GetOnceItemByKey2(itemName);
    if data.isGuard then
      local guardDB = DB.GetOnceGuardByKey2(data.KeyName)
      itemDB = DB.GetOnceItemByKey1(guardDB.CallItemIcon);
    end
    x = x + 90;
    if i~=1 and math.fmod(i-1, 4) == 0 then
      y = y + 90;
      x = x - 90 * 4 + 60;
    end

    local itemIcon = ItemIcon.Create(panelBg, "itemIcon" .. i, x, y)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[itemDB.Grade]);
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, itemDB.Icon);
    if data.isGuard then
      -- 侍从头像  调整大小
      GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,71,70);

      local effect = GUI.RichEditCreate(itemIcon, "effect", "", 1, 22, 160, 185)
      UILayout.SetAnchorAndPivot(effect, UIAnchor.Center, UIAroundPivot.Center)
      GUI.StaticSetFontSize(effect, 22)
      GUI.SetIsRaycastTarget(effect, false)
      GUI.SetScale(effect, Vector3.New(0.75, 0.75, 0.75))
      GUI.SetIsRaycastTarget(icon, true)
      local effect = GUI.GetChild(itemIcon, "effect")
      GUI.StaticSetText(effect, "#IMAGE3407700000#")
    else
      GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60);
    end

    if data.Bind ~= 1 or data.isGuard then
      GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil);
    else
      GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120);
      GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
    end

    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, data.Num);
    _gt.BindName(itemIcon, "itemIcon" .. i);
    GUI.SetData(itemIcon,"Index",i);
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "FirstRechargeUI", "OnItemClick");
  end

  -- local amountText = _gt.GetUI("amountText");
  -- GUI.StaticSetText(amountText,money.." 元")
end

function FirstRechargeUI.OnShow(parameter)
  local wnd = GUI.GetWnd("FirstRechargeUI");
  if wnd == nil then
    return ;
  end

  GUI.SetVisible(wnd, true);

  local rechargeTextImg=_gt.GetUI("rechargeTextImg");

  if CL.GetIntCustomData("GotFirstRecharge")==0 then
    GUI.ImageSetImageID(rechargeTextImg,"1801504080")
  else
    GUI.ImageSetImageID(rechargeTextImg,"1801504100")
  end

  local DialogBoxText = _gt.GetUI("DialogBoxText");
  local msg = CL.GetRoleName(0)..[[！
我叫你一声，你敢答应吗？]]
  GUI.StaticSetText(DialogBoxText, msg)
end

function FirstRechargeUI.OnExit()
  GUI.CloseWnd("FirstRechargeUI")
end

function FirstRechargeUI.OnRechargeBtnClick()

  if CL.GetIntCustomData("GotFirstRecharge")==0 then
    GetWay.Def[1].jump("MallUI", "充值")
  else
    CL.SendNotify(NOTIFY.SubmitForm, "FormFirstRecharge", "GiveReward")
  end

  FirstRechargeUI.OnExit()
end

function FirstRechargeUI.OnItemClick(guid)
  local itemIcon = GUI.GetByGuid(guid);
  local index = tonumber(GUI.GetData(itemIcon,"Index"));
  local data=FirstRechargeUI.itemList[index]
  if data.isGuard then
    local guardDB = DB.GetOnceGuardByKey2(data.KeyName)
    if not GlobalProcessing then
      require "GlobalProcessing"
    end
    GlobalProcessing.ShowGuardInfo(guardDB.Id)
  elseif data then
    local panelBg = _gt.GetUI("panelBg")
    local itemTips=Tips.CreateByItemKeyName(data.KeyName,panelBg,"itemTips",-250,0)
    UILayout.SetSameAnchorAndPivot(itemTips, UILayout.Center);
  end
end