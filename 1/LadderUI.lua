local LadderUI = {}
_G.LadderUI = LadderUI

local _gt = UILayout.NewGUIDUtilTable();

local refreshInterval=10   --刷新间隔


function LadderUI.Main(parameter)
  _gt = UILayout.NewGUIDUtilTable();

  local wnd = GUI.WndCreateWnd("LadderUI", "LadderUI", 0, 0);

  local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "天    梯", "LadderUI", "OnExit", _gt);

  local myRankLabel = GUI.CreateStatic(panelBg, "myRankLabel", "我的排名", 80, 70, 100, 30);
  GUI.SetColor(myRankLabel, UIDefine.BrownColor);
  GUI.StaticSetFontSize(myRankLabel, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(myRankLabel, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(myRankLabel, UILayout.TopLeft)

  local myRankBg = GUI.ImageCreate(panelBg, "myRankBg", "1800700010", 180, 69, false, 120, 35);
  UILayout.SetSameAnchorAndPivot(myRankBg, UILayout.TopLeft)

  local myRankText = GUI.CreateStatic(myRankBg, "myRankText", "未上榜", 0, 0, 150, 35);
  GUI.SetColor(myRankText, UIDefine.White2Color);
  GUI.StaticSetFontSize(myRankText, UIDefine.FontSizeS)
  GUI.StaticSetAlignment(myRankText, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(myRankText, UILayout.Center)
  _gt.BindName(myRankText,"myRankText")

  local myFightLabel = GUI.CreateStatic(panelBg, "myFightLabel", "出战总战力", 295, 70, 150, 30);
  GUI.SetColor(myFightLabel, UIDefine.BrownColor);
  GUI.StaticSetFontSize(myFightLabel, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(myFightLabel, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(myFightLabel, UILayout.TopLeft)

  local myFightBg = GUI.ImageCreate(panelBg, "myFightBg", "1800700010", 430, 69, false, 120, 35);
  UILayout.SetSameAnchorAndPivot(myFightBg, UILayout.TopLeft)

  local myFightText = GUI.CreateStatic(myFightBg, "myFightText", "0", 0, 0, 150, 35);
  GUI.SetColor(myFightText, UIDefine.White2Color);
  GUI.StaticSetFontSize(myFightText, UIDefine.FontSizeS)
  GUI.StaticSetAlignment(myFightText, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(myFightText, UILayout.Center)
  _gt.BindName(myFightText,"myFightText")


  local hintBtn = GUI.ButtonCreate(panelBg, "hintBtn", "1800702030", 600, 65, Transition.ColorTint);
  UILayout.SetSameAnchorAndPivot(hintBtn, UILayout.TopLeft);
  GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "LadderUI", "OnHintBtnClick");

  local honorShopBtn = GUI.ButtonCreate(panelBg, "honorShopBtn", "1800402080", -80, 60, Transition.ColorTint, "荣誉商店", 140, 47, false);
  GUI.SetIsOutLine(honorShopBtn, true);
  GUI.ButtonSetTextFontSize(honorShopBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(honorShopBtn, UIDefine.White2Color);
  GUI.SetOutLine_Color(honorShopBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(honorShopBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(honorShopBtn, UCE.PointerClick, "LadderUI", "OnHonorShopBtnClick");
  UILayout.SetSameAnchorAndPivot(honorShopBtn, UILayout.TopRight);

  local playerListBg = GUI.ImageCreate(panelBg, "playerListBg", "1800400200", 0, 8, false, 1040, 450);
  UILayout.SetSameAnchorAndPivot(playerListBg, UILayout.Center)

  for i = 1, 6 do

    local playerBg = GUI.ImageCreate(playerListBg, "playerBg"..i, "1800600550", 5+(i-1)*172, 0, false, 170, 435);
    UILayout.SetSameAnchorAndPivot(playerBg, UILayout.Left)
    _gt.BindName(playerBg,"playerBg"..i)

    local rankBg = GUI.ImageCreate(playerBg, "rankBg", "1800600560", 0, 10, false, 152, 38);
    UILayout.SetSameAnchorAndPivot(rankBg, UILayout.Top)

    local rankText = GUI.CreateStatic(rankBg, "rankText", "排名：9999", 0, 0, 150, 35);
    GUI.SetColor(rankText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(rankText, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(rankText, TextAnchor.MiddleCenter);
    UILayout.SetSameAnchorAndPivot(rankText, UILayout.Center)


    local selfImg = GUI.ImageCreate(playerBg, "selfImg", "1800604080", -50, 60);
    UILayout.SetSameAnchorAndPivot(selfImg, UILayout.Top)


    local nameText = GUI.CreateStatic(playerBg, "nameText", "名称", -25, -45, 110, 35);
    GUI.SetColor(nameText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(nameText, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(nameText, TextAnchor.MiddleRight);
    UILayout.SetSameAnchorAndPivot(nameText, UILayout.Bottom)

    local vipV = GUI.ImageCreate(playerBg, "vipV", "1801605010", -34, 365,false,20,15);
    UILayout.SetSameAnchorAndPivot(vipV, UILayout.TopRight)

    local vipVNum1 = GUI.ImageCreate(playerBg, "vipVNum1", "1801605020", -22, 361,false,15,20);
    UILayout.SetSameAnchorAndPivot(vipVNum1, UILayout.TopRight)

    local vipVNum2 = GUI.ImageCreate(playerBg, "vipVNum2", "1801605020", -8, 361,false,15,20);
    UILayout.SetSameAnchorAndPivot(vipVNum2, UILayout.TopRight)



    local fightText = GUI.CreateStatic(playerBg, "fightText", "总战力:0", 0, -12, 170, 35);
    GUI.SetColor(fightText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(fightText, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(fightText, TextAnchor.MiddleCenter);
    UILayout.SetSameAnchorAndPivot(fightText, UILayout.Bottom)
  end


  --创建模型UI
  local modelGroup = GUI.RawImageCreate(playerListBg, false, "modelGroup", "", 0, 0, 4,false,1280,1280)
  _gt.BindName(modelGroup, "modelGroup");
  GUI.AddToCamera(modelGroup);--应用模型相机参数 在设置完模型相机参数后, 调用此接口后相机生效
  GUI.SetIsRaycastTarget(modelGroup,false)  --控件交互事件开关
  GUI.RawImageSetCameraConfig(modelGroup, "(-2.6,1.45,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,5,0.01,3.8,1E-05");--模型控件摄像机参数，设置后才能正常显示,不推荐使用

  for i = 1, 6 do
    local roleModel = GUI.RawImageChildCreate(modelGroup, false, "roleModel"..i, "", 0, 0)
    _gt.BindName(roleModel, "roleModel"..i);

  end

  for i = 1, 6 do
    local fightBtn = GUI.ButtonCreate(playerListBg, "fightBtn"..i, "1800602180", 38+(i-1)*172, 95, Transition.ColorTint, "", 110, 45, false);
    GUI.RegisterUIEvent(fightBtn, UCE.PointerClick, "LadderUI", "OnBattleBtnClick");
    UILayout.SetSameAnchorAndPivot(fightBtn, UILayout.Left)
    _gt.BindName(fightBtn,"fightBtn"..i)
    GUI.SetData(fightBtn,"Index",i);
  end


  local rankListBtn = GUI.ButtonCreate(panelBg, "rankListBtn", "1800402080", 85, -40, Transition.ColorTint, "天梯榜", 135, 47, false);
  GUI.SetIsOutLine(rankListBtn, true);
  GUI.ButtonSetTextFontSize(rankListBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(rankListBtn, UIDefine.White2Color);
  GUI.SetOutLine_Color(rankListBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(rankListBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(rankListBtn, UCE.PointerClick, "LadderUI", "OnRankListBtnClick");
  UILayout.SetSameAnchorAndPivot(rankListBtn, UILayout.BottomLeft);

  local recordBtn = GUI.ButtonCreate(panelBg, "recordBtn", "1800402080", 235, -40, Transition.ColorTint, "战报", 135, 47, false);
  GUI.SetIsOutLine(recordBtn, true);
  GUI.ButtonSetTextFontSize(recordBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(recordBtn, UIDefine.White2Color);
  GUI.SetOutLine_Color(recordBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(recordBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(recordBtn, UCE.PointerClick, "LadderUI", "OnRecordBtnClick");
  UILayout.SetSameAnchorAndPivot(recordBtn, UILayout.BottomLeft);

  local refreshBtn = GUI.ButtonCreate(panelBg, "refreshBtn", "1800402080", -85, -40, Transition.ColorTint, "刷新", 135, 47, false);
  GUI.SetIsOutLine(refreshBtn, true);
  GUI.ButtonSetTextFontSize(refreshBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(refreshBtn, UIDefine.White2Color);
  GUI.SetOutLine_Color(refreshBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(refreshBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(refreshBtn, UCE.PointerClick, "LadderUI", "OnRefreshBtnClick");
  UILayout.SetSameAnchorAndPivot(refreshBtn, UILayout.BottomRight);
  _gt.BindName(refreshBtn,"refreshBtn");


  local lineupBtn = GUI.ButtonCreate(panelBg, "lineupBtn", "1800402080", -235, -40, Transition.ColorTint, "调整阵容", 135, 47, false);
  GUI.SetIsOutLine(lineupBtn, true);
  GUI.ButtonSetTextFontSize(lineupBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(lineupBtn, UIDefine.White2Color);
  GUI.SetOutLine_Color(lineupBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(lineupBtn, UIDefine.OutLineDistance);
  GUI.RegisterUIEvent(lineupBtn, UCE.PointerClick, "LadderUI", "OnLineupBtnClick");
  UILayout.SetSameAnchorAndPivot(lineupBtn, UILayout.BottomRight);


  local lastTimeBg = GUI.ImageCreate(panelBg, "lastTimeBg", "1800600040", 0, -45,false,420,35);
  UILayout.SetSameAnchorAndPivot(lastTimeBg, UILayout.Bottom)

  local lastTimeText = GUI.CreateStatic(lastTimeBg, "lastTimeText", "剩余挑战次数：10/10", 0, 0, 420, 35);
  GUI.SetColor(lastTimeText, UIDefine.BrownColor);
  GUI.StaticSetFontSize(lastTimeText, UIDefine.FontSizeS)
  GUI.StaticSetAlignment(lastTimeText, TextAnchor.MiddleCenter);
  UILayout.SetSameAnchorAndPivot(lastTimeText, UILayout.Center);
  _gt.BindName(lastTimeText,"lastTimeText");

  CL.RegisterMessage(GM.FightStateNtf, "LadderUI", "OnFightStateNtf");

end

function LadderUI.OnFightStateNtf(inFight)
  if inFight then
    LadderUI.OnExit();
  end
end


function LadderUI.OnRecordBtnClick()
  CL.SendNotify(NOTIFY.SubmitForm, "FormTianTi", "OpenBattleRecord")
end

function LadderUI.GetRecordData(data)
  if CL.GetMode() == 1 then

  end

  GUI.OpenWnd("LadderRecordUI")
  LadderRecordUI.SetData(data)

end


function LadderUI.InitData()
  LadderUI.lastrRquestTick=0;
  LadderUI.playerData=nil
  LadderUI.myRank=0;
  LadderUI.rewardStr="";
  LadderUI.fightNum=0;
  LadderUI.fightTotalNum=0;
  LadderUI.playerSource=0;
end
LadderUI.InitData()

function LadderUI.OnExit()
  GUI.DestroyWnd("LadderUI");
end

function LadderUI.OnDestroy()
  if LadderUI.Timer ~= nil then
    LadderUI.Timer:Stop()
    LadderUI.Timer = nil;
  end
end

function LadderUI.OnShow(parameter)
  local wnd = GUI.GetWnd("LadderUI");
  if wnd == nil then
    return ;
  end

  GUI.SetVisible(wnd, true);

  if LadderUI.playerData==nil or LadderUI.GetRequstInterval()>refreshInterval then
    CL.SendNotify(NOTIFY.SubmitForm, "FormTianTi", "RefreshMainWnd")
  else
    LadderUI.Refresh()
  end

  LadderUI.SetRefreshBtnState()
end

function LadderUI.RefreshData(myRank,rewardStr,fightNum,fightTotalNum,playerData,playerSource)
  LadderUI.lastrRquestTick=CL.GetServerTickCount();
  LadderUI.myRank=myRank;
  LadderUI.rewardStr=rewardStr;
  LadderUI.fightNum=fightNum;
  LadderUI.fightTotalNum=fightTotalNum;
  LadderUI.playerSource=playerSource; --玩家的总战力
  if CL.GetMode() == 1 then

  end

  LadderUI.playerData=playerData;
  LadderUI.Refresh()
  LadderUI.SetRefreshBtnState()
end

function LadderUI.Refresh()

  local myRankText = _gt.GetUI("myRankText")
  if LadderUI.myRank==0 then
    GUI.StaticSetText(myRankText,"未上榜")
  else
    GUI.StaticSetText(myRankText,LadderUI.myRank)
  end


  local myFightText =_gt.GetUI("myFightText")
  GUI.StaticSetText(myFightText,tonumber(LadderUI.playerSource))
  --GUI.StaticSetText(myFightText,CL.GetIntAttr(RoleAttr.RoleAttrFightValue))

  local lastTimeText =_gt.GetUI("lastTimeText")
  GUI.StaticSetText(lastTimeText,"剩余挑战次数：".. LadderUI.fightNum.."/"..LadderUI.fightTotalNum);

  for i = 1, 6 do
    local data = LadderUI.playerData[i];
    if data then
      local playerBg = _gt.GetUI("playerBg"..i)
      local rankBg = GUI.GetChild(playerBg,"rankBg")
      local rankText =  GUI.GetChild(rankBg,"rankText")
      if data.Rank==0 then
        GUI.StaticSetText(rankText,"未上榜");
      else
        GUI.StaticSetText(rankText,"排名："..data.Rank);
      end

      local selfImg=GUI.GetChild(playerBg,"selfImg")
      local fightBtn =_gt.GetUI("fightBtn"..i)
      if uint64.new(data.Guid)==LD.GetSelfGUID() then
        GUI.SetVisible(selfImg,true);
        GUI.SetVisible(fightBtn,false);
        GUI.ImageSetImageID(playerBg,"1800600551")
      else
        GUI.SetVisible(selfImg,false);
        GUI.SetVisible(fightBtn,true);
        GUI.ImageSetImageID(playerBg,"1800600550")
      end


      local nameText =GUI.GetChild(playerBg,"nameText")
      GUI.StaticSetText(nameText,data.Name);

      local fightText =GUI.GetChild(playerBg,"fightText")
      GUI.StaticSetText(fightText,"总战力:"..data.Score);
      LadderUI.AutoTextSize(fightText,170)

      LadderUI.SetVipLv(playerBg,data.VIPLevel)

      local roleDB = DB.GetRole(data.RoleID);
      if roleDB then
        local roleModel = _gt.GetUI("roleModel"..i);

        ModelItem.Bind(roleModel, tonumber(roleDB.Model), data.Color1, data.Color2, eRoleMovement.STAND_W1, data.WeaponId, roleDB.Sex,data.EffectId)
		
		if CL.GetStrCustomData("Model_DynJson1",data.Guid) ~= "" then
			if UIDefine.IsFunctionOrVariableExist(GUI,"RefreshDyeSkinJson") then	
				GUI.RefreshDyeSkinJson(roleModel, CL.GetStrCustomData("Model_DynJson1"), "")
			end
		end			
        GUI.SetLocalPosition(roleModel,-(i-1)*1.032,0,0)
        GUI.SetEulerAngles(roleModel, Vector3.New(0,0,0))
      end
    end
  end
end
--挑战按钮点击
function LadderUI.OnBattleBtnClick(guid)
  local fightBtn = GUI.GetByGuid(guid);

  local index = tonumber(GUI.GetData(fightBtn,"Index"))
  local data =LadderUI.playerData[index];
  --local data = 1;
  if data then
    GUI.OpenWnd("LadderBattleConfirmUI")
    LadderBattleConfirmUI.SetPlayerData(data)
  end
end

function LadderUI.OnHintBtnClick()
  local panelBg = _gt.GetUI("panelBg");
  Tips.CreateHint(LadderUI.rewardStr, panelBg, 0, 105, UILayout.Top)
end

function LadderUI.AutoTextSize(text,width)
  local w = GUI.StaticGetLabelPreferWidth(text)
  GUI.SetWidth(text,w)
  if w > width then
    local s = width / w
    GUI.SetScale(text, Vector3.New(s, s, s))
  else
    GUI.SetScale(text, UIDefine.Vector3One)
  end
end

function LadderUI.OnHonorShopBtnClick()
  CL.SendNotify(NOTIFY.SubmitForm, "FormTianTi", "OpenHonorShop")
end

function LadderUI.OnRankListBtnClick()
  CL.SendNotify(NOTIFY.SubmitForm, "FormTianTi", "OpenTianTiRank")
end

function LadderUI.OnLineupBtnClick()
  --CL.SendNotify(NOTIFY.SubmitForm, "FormTianTi", "OpenGuardWnd")
  GUI.OpenWnd("BattleSeatUI")
end

function LadderUI.OnRefreshBtnClick(guid)
  CL.SendNotify(NOTIFY.SubmitForm, "FormTianTi", "RefreshMainWnd")
  local refreshBtn = _gt.GetUI("refreshBtn")
  GUI.ButtonSetShowDisable(refreshBtn,false);
end

function LadderUI.SetRefreshBtnState()
  if LadderUI.GetRequstInterval()<refreshInterval then
    local refreshBtn = _gt.GetUI("refreshBtn")
    GUI.ButtonSetShowDisable(refreshBtn,false);

    local fun = function()
      local refreshBtn = _gt.GetUI("refreshBtn")
      if LadderUI.GetRequstInterval()<refreshInterval then
        GUI.ButtonSetShowDisable(refreshBtn,false);
        GUI.ButtonSetText(refreshBtn,refreshInterval- LadderUI.GetRequstInterval())
      else
        GUI.ButtonSetShowDisable(refreshBtn,true);
        GUI.ButtonSetText(refreshBtn,"刷新")
        if LadderUI.Timer ~= nil then
          LadderUI.Timer:Stop()
          LadderUI.Timer = nil;
        end
      end
    end


    if LadderUI.Timer == nil then
      LadderUI.Timer = Timer.New(fun, 0.15, -1)
    else
      LadderUI.Timer:Stop();
      LadderUI.Timer:Reset(fun, 1, -1)
    end
    LadderUI.Timer:Start();

  else
    local refreshBtn = _gt.GetUI("refreshBtn")
    GUI.ButtonSetShowDisable(refreshBtn,true);
    GUI.ButtonSetText(refreshBtn,"刷新")
  end


end


--得到获取请求的间隔
function LadderUI.GetRequstInterval()
  return CL.GetServerTickCount()-LadderUI.lastrRquestTick;
end

--设置VIP等级
function LadderUI.SetVipLv(playerBg, vipLv)
  if playerBg == nil then
    return
  end
  local vipV = GUI.GetChild(playerBg, "vipV", false)
  local vipVNum1 = GUI.GetChild(playerBg, "vipVNum1", false)
  local vipVNum2 = GUI.GetChild(playerBg, "vipVNum2", false)
  if vipV and vipVNum1 and vipVNum2 then
    local h = math.floor(vipLv / 10)
    if h > 9 then
      test("设置VIP等级出错，当前设置等级：" .. vipLv)
      h = 9
    end
    local l = vipLv % 10
    local tmp = { vipVNum2, vipVNum1, vipV }
    local picNum = { l, h }
    local picbase = { 1801605020, 1801605020, 1801605010 }
    local x = -GUI.GetPositionX(vipVNum2) -- 设置成右上角对齐时，positionX的值会取反，所以加一个负号
    for i = 1, 3 do
      local w =12
      local pic = picbase[i]
      if picNum[i] then
        pic = pic + picNum[i]
      end
      if i == 1 then
        GUI.SetVisible(tmp[i], true)
      elseif i == 2 then
        local b = h > 0
        GUI.SetVisible(tmp[i], b)
        x = x + (b and w or 0)
      else
        GUI.SetVisible(tmp[i], true)
        x = x + w
      end
      GUI.ImageSetImageID(tmp[i], tostring(pic))
      GUI.SetPositionX(tmp[i], x)
    end
  end
end
