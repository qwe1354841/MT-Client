local LadderBattleConfirmUI = {}
_G.LadderBattleConfirmUI = LadderBattleConfirmUI
local _gt = UILayout.NewGUIDUtilTable();
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorDefault = Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255)
-------------------------------------------------------------------------------------------
local SeatNum=5
local inspect = require("inspect")
-------------------------------------------------------------------------------------------


function LadderBattleConfirmUI.Main(parameter)
  _gt = UILayout.NewGUIDUtilTable();

  local parentPanel = GUI.WndCreateWnd("LadderBattleConfirmUI", "LadderBattleConfirmUI", 0, 0, eCanvasGroup.Normal);
  SetAnchorAndPivot(parentPanel,UIAnchor.Center,UIAroundPivot.Center)
  _gt.BindName(parentPanel,"parentPanel")
  local panelCover=GUI.ImageCreate(parentPanel,"panelCover","1800400220",0,0,false,GUI.GetWidth(parentPanel), GUI.GetHeight(parentPanel))
  SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
  GUI.SetIsRaycastTarget(panelCover, true)
  local panelBg = GUI.ImageCreate(parentPanel, "panelBg", "1800900010", 0, 0, false, 500, 550);
  SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)
  _gt.BindName(panelBg,"panelBg")

  local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800302120", -16, 16, Transition.ColorTint);
  SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.Center)
  GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "LadderBattleConfirmUI", "OnExit");

  local titleBg = GUI.ImageCreate(panelBg, "titleBg", "1800001140", 0, -230, false, 260, 40);
  SetAnchorAndPivot(titleBg, UIAnchor.Center, UIAroundPivot.Center)
  local titleLabel = GUI.CreateStatic(titleBg, "titleLabel", "名字", -10, 0, 160, 40);
  LadderBattleConfirmUI.SetTextBasicInfo(titleLabel, colorDark, TextAnchor.MiddleCenter, 24)

  local battleSeatBg = GUI.ImageCreate(panelBg, "battleSeatBg", "1800300040", 0, 10, false, 450, 400);
  SetAnchorAndPivot(battleSeatBg, UIAnchor.Center, UIAroundPivot.Center)
  _gt.BindName(battleSeatBg,"battleSeatBg")

  local battleInfoBg=GUI.ImageCreate(battleSeatBg,"battleInfoBg","1800200050",0,10,false,300,95)
  SetAnchorAndPivot(battleInfoBg, UIAnchor.Top, UIAroundPivot.Top)

  local battleInfoIconBg=GUI.ImageCreate(battleInfoBg,"battleInfoIconBg","1800400050",20,0,false,70,70)
  SetAnchorAndPivot(battleInfoIconBg, UIAnchor.Left, UIAroundPivot.Left)


  local battleInfoIcon=GUI.ImageCreate(battleInfoIconBg,"battleInfoIconBg","1800903100",0,0,false,60,60)
  SetAnchorAndPivot(battleInfoIcon, UIAnchor.Center, UIAroundPivot.Center)
  _gt.BindName(battleInfoIcon,"battleInfoIcon")


  local battleInfo=GUI.CreateStatic(battleInfoBg,"battleInfo","1级普通阵",70,0,200,50)
  SetAnchorAndPivot(battleInfo, UIAnchor.Center, UIAroundPivot.Center)
  GUI.StaticSetFontSize(battleInfo,UIDefine.FontSizeL)
  GUI.SetColor(battleInfo,UIDefine.BrownColor)
  _gt.BindName(battleInfo,"battleInfo")


  --local wnd = GUI.WndCreateWnd("LadderBattleConfirmUI", "LadderBattleConfirmUI", 0, 0);
  --local panelBg=UILayout.CreateFrame_WndStyle2_WithoutCover(wnd,"挑  战",500,550,"LadderBattleConfirmUI","OnExit")
  --local vs = GUI.ImageCreate(panelBg, "vs", "1800202381", 0, -10);
  --UILayout.SetSameAnchorAndPivot(vs, UILayout.Center)
  --local player1Bg = GUI.ImageCreate(panelBg, "player1Bg", "1800700050", 0, -105,false,305,110 );
  --UILayout.SetSameAnchorAndPivot(vs, UILayout.Center)
  --_gt.BindName(player1Bg,"player1Bg")
  --local player= ItemIcon.Create(player1Bg,"player",-95,2)
  --UILayout.SetSameAnchorAndPivot(player, UILayout.Center)
  --HeadIcon.CreateVip(player,45,45,-6,6)
  --local nameText = GUI.CreateStatic(player, "nameText", "名称", 90, -15, 180, 35);
  --GUI.SetColor(nameText, UIDefine.BrownColor);
  --GUI.StaticSetFontSize(nameText, UIDefine.FontSizeS)
  --GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft);
  --UILayout.SetSameAnchorAndPivot(nameText, UILayout.Left)
  --local fightText = GUI.CreateStatic(player, "fightText", "装备评分:0", 90, 18, 180, 35);
  --GUI.SetColor(fightText, UIDefine.BrownColor);
  --GUI.StaticSetFontSize(fightText, UIDefine.FontSizeSS)
  --GUI.StaticSetAlignment(fightText, TextAnchor.MiddleLeft);
  --UILayout.SetSameAnchorAndPivot(fightText, UILayout.Left)
  --local player2Bg = GUI.ImageCreate(panelBg, "player2Bg", "1800700050", 0, 80,false,305,110 );
  --UILayout.SetSameAnchorAndPivot(vs, UILayout.Center)
  --_gt.BindName(player2Bg,"player2Bg")
  --local player= ItemIcon.Create(player2Bg,"player",-95,2)
  --UILayout.SetSameAnchorAndPivot(player, UILayout.Center)
  --HeadIcon.CreateVip(player,45,45,-6,6)
  --local nameText = GUI.CreateStatic(player, "nameText", "名称", 90, -15, 180, 35);
  --GUI.SetColor(nameText, UIDefine.BrownColor);
  --GUI.StaticSetFontSize(nameText, UIDefine.FontSizeS)
  --GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft);
  --UILayout.SetSameAnchorAndPivot(nameText, UILayout.Left)
  --local fightText = GUI.CreateStatic(player, "fightText", "装备评分:0", 90, 18, 180, 35);
  --GUI.SetColor(fightText, UIDefine.BrownColor);
  --GUI.StaticSetFontSize(fightText, UIDefine.FontSizeSS)
  --GUI.StaticSetAlignment(fightText, TextAnchor.MiddleLeft);
  --UILayout.SetSameAnchorAndPivot(fightText, UILayout.Left)
  --角色以及侍从的战位
  --LadderBattleConfirmUI.RefreshSeatPosition()

  local cancelBtn = GUI.ButtonCreate(panelBg, "cancelBtn", "1800402080", 20, -10, Transition.ColorTint, "再想想", 120, 47, false);
  GUI.SetIsOutLine(cancelBtn, true);
  GUI.ButtonSetTextFontSize(cancelBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(cancelBtn, UIDefine.White2Color);
  GUI.SetOutLine_Color(cancelBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(cancelBtn, UIDefine.OutLineDistance);
  SetAnchorAndPivot(cancelBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
  --UILayout.SetSameAnchorAndPivot(cancelBtn, UILayout.Center);
  GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick, "LadderBattleConfirmUI", "OnExit");
  --print("在1处")
  local battleBtn = GUI.ButtonCreate(panelBg, "battleBtn", "1800402080", -25, -10, Transition.ColorTint, "干掉他", 120, 47, false);
  GUI.SetIsOutLine(battleBtn, true);
  GUI.ButtonSetTextFontSize(battleBtn, UIDefine.FontSizeXL);
  GUI.ButtonSetTextColor(battleBtn, UIDefine.White2Color);
  GUI.SetOutLine_Color(battleBtn, UIDefine.OutLine_BrownColor);
  GUI.SetOutLine_Distance(battleBtn, UIDefine.OutLineDistance);
  SetAnchorAndPivot(battleBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
  --UILayout.SetSameAnchorAndPivot(battleBtn, UILayout.Center);
  GUI.RegisterUIEvent(battleBtn, UCE.PointerClick, "LadderBattleConfirmUI", "OnBattleBtnClick");

  CL.RegisterMessage(GM.FightStateNtf, "LadderBattleConfirmUI", "OnFightStateNtf");

end


function LadderBattleConfirmUI.OnShow()
  print("onShow")
  --LadderBattleConfirmUI.SetPlayerData()

end


--是否处于战斗状态查询
function LadderBattleConfirmUI.OnFightStateNtf(inFight)
  if inFight then
    LadderBattleConfirmUI.OnExit();
  end
end
--战斗按钮点击
function LadderBattleConfirmUI.OnBattleBtnClick()
  if LadderBattleConfirmUI.data then
    print("StartBattleJudge:"..LadderBattleConfirmUI.data.Guid)
    CL.SendNotify(NOTIFY.SubmitForm, "FormTianTi", "StartBattleJudge",LadderBattleConfirmUI.data.Guid)
  else
    print("数据不存在")
  end
end
--退出
function LadderBattleConfirmUI.OnExit()
  GUI.DestroyWnd("LadderBattleConfirmUI");
end
--设置文本文字的字体、颜色、对齐方式
function LadderBattleConfirmUI.SetTextBasicInfo(txt, color, Anchor, txtSize)
  if txt ~= nil then
    SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txt, txtSize);
    GUI.SetColor(txt, color);
    GUI.StaticSetAlignment(txt, Anchor)
  end
end

function LadderBattleConfirmUI.ChallengeScrollTips()
  --挑战卷轴Id
  local itemId=21709
  local parentPanel=_gt.GetUI("parentPanel")
  local CSTips=Tips.CreateByItemId(itemId,parentPanel,"TSBookTips",0,0,50)
  GUI.SetData(CSTips,"ItemId",itemId)
  _gt.BindName(CSTips,"CSTips")
  local wayBtn=GUI.ButtonCreate(CSTips,"wayBtn","1800402110",0,-10,Transition.ColorTint,"获得途径", 150, 50, false)
  SetAnchorAndPivot(wayBtn,UIAnchor.Bottom,UIAroundPivot.Bottom)
  GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
  GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
  GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"LadderBattleConfirmUI","onClickCSWayBtn")
  GUI.AddWhiteName(CSTips, GUI.GetGuid(wayBtn))

end
function LadderBattleConfirmUI.onClickCSWayBtn()
  local CSTips=_gt.GetUI("CSTips")
  if CSTips==nil then
    print("TSTips is nil")
  end
  if CSTips then

    Tips.ShowItemGetWay(CSTips)
  end
end


--获取玩家数据
function LadderBattleConfirmUI.SetPlayerData(data)


  LadderBattleConfirmUI.data=data;
  --print("再执行第二步")
  --print("数据如下")
  --CDebug.LogError(inspect(LadderBattleConfirmUI.data))
  --print("data============="..data)
  local panelBg = _gt.GetUI("panelBg")
  local titleBg=GUI.GetChild(panelBg,"titleBg")
  local titleLabel=GUI.GetChild(titleBg,"titleLabel")
  GUI.StaticSetText(titleLabel,data.Name)

  local battleInfoIcon=_gt.GetUI("battleInfoIcon")
  local battleInfo=_gt.GetUI("battleInfo")
  --print("SeatID"..data.SeatId)
  local battleSeatDB=DB.GetOnceSeatByKey1(tonumber(data.SeatId))

  --print(inspect(battleSeatDB))
  --CDebug.LogError(inspect(battleSeatDB))
  GUI.ImageSetImageID(battleInfoIcon,battleSeatDB.Icon)
  GUI.StaticSetText(battleInfo,data.SeatLevel.."级"..battleSeatDB.Name)



  LadderBattleConfirmUI.RefreshSeatPosition()
  --for i = 1, SeatNum do
  --  local model=_gt.GetUI("SeatModel" .. i)
  --  if i==1 then
  --    --local roleModel=GUI.GetAttr(RoleAttr.RoleAttrRole)
  --    ModelItem.BindSelfRole(model,eRoleMovement.STAND_W1)
  --  end
  --end

  --local player = GUI.GetChild(player1Bg,"player");
  --local nameText = GUI.GetChild(player,"nameText");
  --local fightText = GUI.GetChild(player,"fightText");
  --
  --local roleDB = DB.GetRole(data.RoleID);
  --if roleDB then
  --  GUI.ItemCtrlSetElementValue(player, eItemIconElement.Icon, tostring(roleDB.Head));
  --  GUI.ItemCtrlSetElementRect(player, eItemIconElement.Icon, 0, -1, 69, 69);
  --end
  --HeadIcon.BindRoleVipLv(player, data.VIPLevel)
  --GUI.StaticSetText(nameText,data.Name);
  --GUI.StaticSetText(fightText,"装备评分:"..data.Score);
  --
  --
  --local player2Bg = _gt.GetUI("player2Bg")
  --local player = GUI.GetChild(player2Bg,"player");
  --local nameText = GUI.GetChild(player,"nameText");
  --local fightText = GUI.GetChild(player,"fightText");
  --
  --local roleDB = DB.GetRole(CL.GetRoleTemplateID());
  --if roleDB then
  --  GUI.ItemCtrlSetElementValue(player, eItemIconElement.Icon, tostring(roleDB.Head));
  --  GUI.ItemCtrlSetElementRect(player, eItemIconElement.Icon, 0, -1, 69, 69);
  --end
  --HeadIcon.BindRoleVipLv(player,CL.GetIntAttr(RoleAttr.RoleAttrVip))
  --GUI.StaticSetText(nameText,CL.GetRoleName());
  --GUI.StaticSetText(fightText,"装备评分:"..CL.GetIntAttr(RoleAttr.RoleAttrFightValue));

end

----------------------------------------------阵法战位开始-----------------------------------------
--以下代码copy于battleSeatUI
local SeatPositionDate={}  --战位位置数据
local SeatOrderNum = {"1800605060","1800605070","1800605080","1800605090","1800605100"}
local sData=nil
local SelectedSeatId=1
local guardGuidList={}
--阵法站位
function LadderBattleConfirmUI.RefreshSeatPosition()
  local DisX=53
  local DisY=22
  --若想改变阵法的位置（X Y）请调整下面两个参数StartX和StartY    其他参数均已设计好勿动
  local StartX=57
  local StartY=290

  --print("先执行第一步")
  sData=LadderBattleConfirmUI.data
  SelectedSeatId=sData.SeatId
  --侍从的模型代码还未传输，且不知数据里面内容，故下面还未完成
  --切记guardGuidList的index是从0开始的
  guardGuidList=sData.GuardIdList

  local modelNode=_gt.GetUI("SeatModelNode")
  --如果modelNode不存在
  if  not modelNode then
    local battleSeatBg=_gt.GetUI("battleSeatBg")
    --站位底板
    for j = 1, 3 do
      for i = 1, 5 do
          --底板
        local PX = StartX + (i - 1) * DisX + (j - 1) * 55
        local PY = StartY - (i - 1) * DisY + (j - 1) * 31
        local name = "modelListNode" .. ((j - 1) * 5 + i - 1)
        local modelListNode = GUI.CheckBoxCreate(battleSeatBg, name, "1800600111", "1800600110", PX, PY, Transition.ColorTint, false)
        SetAnchorAndPivot(modelListNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetInteractable(modelListNode, false)--是否禁用UI组件
        GUI.CheckBoxSetCheck(modelListNode,false)
        modelListNode:UnRegisterEvent(UCE.PointerClick)
        _gt.BindName(modelListNode, name)
      end
    end

    modelNode=GUI.RawImageCreate(battleSeatBg,false,"SeatModelNode","",0,0,3,false,440,440)
    GUI.SetIsRaycastTarget(modelNode, false)
    _gt.BindName(modelNode, "SeatModelNode")
    GUI.AddToCamera(modelNode)
    GUI.RawImageSetCameraConfig(modelNode, "(0.09119999,1.336,2.56),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,4.79,-1,3.33,37")

    --数字
    for i = 1, SeatNum do
        local number=GUI.ImageCreate(modelNode,"Num"..i,SeatOrderNum[i],6,34)
        SetAnchorAndPivot(number,UIAnchor.Center,UIAroundPivot.Center)
        _gt.BindName(number,"number"..i)
    end
  end

  --for i = 0, 14 do
  --  local modelListNode=-_gt.GetUI("modelListNode"..i)
  --  GUI.CheckBoxSetCheck(modelListNode,false)
  --end

  local siteInfo=LadderBattleConfirmUI.GetSeatRowCol(SelectedSeatId or 1)
  local guardGuidList=guardGuidList or {}

  for i = 1, SeatNum do
    local guardGuid=guardGuidList[i-1]
    local posIndex=siteInfo[i]
    local X=posIndex%5
    local Y=(posIndex-X)/5
    local model=_gt.GetUI("SeatModel"..i)

    --print(i.."X======"..X)
    --print(i.."Y======"..Y)
    --print("guard index is =="..(i-1).." id is "..guardGuid)
    --CDebug.LogError(inspect(guardGuid))
    if  i~=1 and (not guardGuid or guardGuid=="0" or guardGuid==0) then
      if model then
        GUI.SetVisible(model,false)
      end
    else
      if not model then

        model=GUI.RawImageChildCreate(modelNode,true,"SeatModel" .. i,"",0,0)
        _gt.BindName(model,"SeatModel" .. i)
      else

        GUI.SetVisible(model, true)
      end

      if i==1 then

        --该处应该创建对决的角色的模型
        --此处先使用当前角色的模型只为进行实验
        --ModelItem.BindSelfRole(model,eRoleMovement.STAND_W1)
        --现在因为角色模型的id还未从服务器端获取，故以下代码还未完成
        --角色模型只需要更改sData.RoleID便可

        local roleDB=DB.GetRole(sData.RoleID)
        ModelItem.Bind(model,tonumber(roleDB.Model),sData.Color1,sData.Color2,eRoleMovement.STAND_W1,sData.WeaponId,0,sData.EffectId)
      else
        --在此处配置侍从的模型
        --local id=LD.GetGuardIDByGUID(guardGuid)

        local guardDB = DB.GetOnceGuardByKey1(guardGuid)
        ModelItem.Bind(model, guardDB.Model, guardDB.ColorID1, guardDB.ColorID2, eRoleMovement.STAND_W1)

      end
      local PX = -Y * (0.82) - X * (0.79) + 2.46
      local PY = -Y * (0.30) + X * (0.33) -0.85
      GUI.SetLocalPosition(model, PX, PY, -0.4 + 0.8 * Y)
      GUI.SetEulerAngles(model, 0, -45, 0)

    end

    local modelListNode=_gt.GetUI("modelListNode"..posIndex)
    GUI.CheckBoxSetCheck(modelListNode,true)

    local number=_gt.GetUI("number"..i)
    if LadderBattleConfirmUI.IsShowNum(X,Y,siteInfo,guardGuidList) then
      GUI.SetVisible(number,true)
      local PX = StartX + X * DisX + Y * 55 - 217
      local PY = StartY - X * DisY + Y * 31 - 217
      GUI.SetPositionX(number, PX)
      GUI.SetPositionY(number, PY + 6)
    else
      GUI.SetVisible(number, false)
    end
  end

end
--获得阵法战位的行数以及列数
function LadderBattleConfirmUI.GetSeatRowCol(seatId)
  local data=SeatPositionDate[seatId]
  if  not data then
    local seatDB=DB.GetOnceSeatByKey1(seatId)
    if not seatDB or seatDB.Id==0 then
        print("找不到阵法ID为:"..seatId.."的阵法")
        return nil
    end

    local infoDB=SETTING.GetLineup(seatDB.LineupId)
    if infoDB.ID==0 then
      print("找不到站位配置：" .. seatDB.LineupId)
      return nil
    end
    data={}
    for i = 0, SeatNum-1 do
      local site=infoDB.Sites[0].Site[i]
      data[#data + 1] = (site.Row - 1) * 5 + site.Col - 1
    end
    SeatPositionDate[seatId]=data
  end
  return data
end
--是否显示数字
function LadderBattleConfirmUI.IsShowNum(x,y,seatInfo,guardGuidList)
  if y==2 then
    return true
  else
    local valX=y*5+x
    local frontX=valX+4
    for i = 1, #seatInfo do
      local tmpX=seatInfo[i]%5
      local tmpY=(seatInfo[i]-tmpX)/5
      if  tmpY~=y and seatInfo[i] ==frontX then
        if guardGuidList[i] and guardGuidList[i]~=0 and guardGuidList[i]~="0" then
          return false
        end
      end
    end
    return true
  end
end
----------------------------------------------阵法战位结束-----------------------------------------
