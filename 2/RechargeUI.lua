local RechargeUI = {}
_G.RechargeUI = RechargeUI

local _gt = UILayout.NewGUIDUtilTable();

function RechargeUI.Create(panelBg)
	_gt = UILayout.NewGUIDUtilTable();
	local rechargePage = GUI.GroupCreate(panelBg, "rechargePage", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
	GUI.SetVisible(rechargePage, false)
	local scrollBg = GUI.ImageCreate(rechargePage, "scrollBg", "1800400010", 0, 10, false, 1040, 550)
	local rechargeScroll =
	GUI.LoopScrollRectCreate(
		scrollBg,
		"rechargeScroll",
		0,
		0,
		1010,
		520,
		"RechargeUI",
		"CreateRechargeItem",
		"RechargeUI",
		"RefreshRechargeScroll",
		0,
		false,
		Vector2.New(250, 250),
		4,
		UIAroundPivot.Top,
		UIAnchor.Top
	)
	GUI.ScrollRectSetChildSpacing(rechargeScroll, Vector2.New(6, 20))
	_gt.BindName(rechargeScroll,"rechargeScroll")
	CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "GetData","Recharge")
end


function RechargeUI.Refresh()
	RechargeUI.RefreshData()
end

function RechargeUI.RefreshData()
	if CL.GetMode() == 1 then
		local inspect = require("inspect")
		--print(inspect(RECHARGE_DATA))
	end
	
	local rechargeScroll = _gt.GetUI("rechargeScroll");
	GUI.LoopScrollRectSetTotalCount(rechargeScroll, #RECHARGE_DATA.RechargeFunction_Config)
	GUI.LoopScrollRectRefreshCells(rechargeScroll)
end



--创建充值选项列表
function RechargeUI.CreateRechargeItem()
  local rechargeScroll = _gt.GetUI("rechargeScroll");

  local curCount = GUI.LoopScrollRectGetChildInPoolCount(rechargeScroll)
  local rechargeItem = GUI.ItemCtrlCreate(rechargeScroll, "rechargeItem" .. curCount, "1800400730", 0, 0)
  GUI.ItemCtrlSetElementValue(rechargeItem, eItemIconElement.Icon, "1800408600");
  GUI.ItemCtrlSetElementRect(rechargeItem, eItemIconElement.Icon, 0, -10,210,170);

  local coinBg = GUI.ImageCreate(rechargeItem, "coinBg", "1800400740", 20, 20, false, 200, 28)
  GUI.SetAnchor(coinBg, UIAnchor.TopLeft)
  GUI.SetPivot(coinBg, UIAroundPivot.TopLeft)

  local icon = GUI.ImageCreate(coinBg, "icon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 0, -2, false, 45, 45)
  GUI.SetAnchor(icon, UIAnchor.Left)
  GUI.SetPivot(icon, UIAroundPivot.Left)

  local amount = GUI.CreateStatic(coinBg, "amount", "1000", 0, 0, 120, 30)
  GUI.SetAnchor(amount, UIAnchor.Center)
  GUI.SetPivot(amount, UIAroundPivot.Center)
  GUI.StaticSetFontSize(amount, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(amount, TextAnchor.MiddleCenter)
  GUI.SetColor(amount, UIDefine.WhiteColor)

  local giveBg = GUI.ImageCreate(rechargeItem, "giveBg", "1800408560", -40, 40)
  GUI.SetAnchor(giveBg, UIAnchor.TopRight)
  GUI.SetPivot(giveBg, UIAroundPivot.Center)

  local icon = GUI.ImageCreate(giveBg, "icon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], -20, 25, false, 40, 40)
  GUI.SetAnchor(icon, UIAnchor.TopRight)
  GUI.SetPivot(icon, UIAroundPivot.Center)

  local amount = GUI.CreateStatic(giveBg, "amount", "100", 0, 12, 80, 30)
  GUI.SetAnchor(amount, UIAnchor.Center)
  GUI.SetPivot(amount, UIAroundPivot.Center)
  GUI.StaticSetFontSize(amount, UIDefine.FontSizeM)
  GUI.StaticSetAlignment(amount, TextAnchor.MiddleCenter)
  GUI.SetColor(amount, UIDefine.WhiteColor)

  local buyBtn =
  GUI.ButtonCreate(rechargeItem, "buyBtn", "1800002110", 0, 95, Transition.ColorTint, "￥ 648", 120, 45, false)
  GUI.SetIsOutLine(buyBtn, true)
  GUI.ButtonSetTextFontSize(buyBtn, UIDefine.FontSizeXL)
  GUI.ButtonSetTextColor(buyBtn, UIDefine.WhiteColor)
  GUI.SetOutLine_Color(buyBtn, UIDefine.OutLine_BrownColor)
  GUI.SetOutLine_Distance(buyBtn, UIDefine.OutLineDistance)
  GUI.RegisterUIEvent(buyBtn, UCE.PointerClick, "RechargeUI", "OnBuyBtnClick")
  return rechargeItem
end

--刷新充值选项列表
function RechargeUI.RefreshRechargeScroll(parameter)
  parameter = string.split(parameter, "#");
  local guid = parameter[1];
  local index = tonumber(parameter[2]);

  index=index+1;
  if index>#RECHARGE_DATA.RechargeFunction_Config then
    return;
  end

  local data=RECHARGE_DATA.RechargeFunction_Config[index];
  local rechargeItem = GUI.GetByGuid(guid)
  GUI.ItemCtrlSetElementValue(rechargeItem, eItemIconElement.Icon,data.Icon);

  local coinBg =GUI.GetChild(rechargeItem,"coinBg");
  local amount =GUI.GetChild(coinBg,"amount");
  GUI.StaticSetText(amount,data.Ingot);

  local giveBg =GUI.GetChild(rechargeItem,"giveBg");
  local amount =GUI.GetChild(giveBg,"amount");
  if RECHARGE_DATA["IsPlayerRecharged_"..index]==nil or RECHARGE_DATA["IsPlayerRecharged_"..index]==0 then
    if data.BonusOnce>0 then
      GUI.SetVisible(giveBg,true);
      GUI.StaticSetText(amount,data.BonusOnce);
    else
      GUI.SetVisible(giveBg,false);
    end
  else
    if data.BonusNor >0 then
      GUI.SetVisible(giveBg,true);
      GUI.StaticSetText(amount,data.BonusNor );
    else
      GUI.SetVisible(giveBg,false);
    end
  end

  local buyBtn=GUI.GetChild(rechargeItem,"buyBtn");
  GUI.ButtonSetText(buyBtn,"￥ "..data.Amount);
  GUI.SetData(buyBtn,"Index",index);
end

local _tempGuid=""
function RechargeUI.OnBuyBtnClick(guid)
  _tempGuid = guid
  local guid = _tempGuid
  local buyBtn = GUI.GetByGuid(guid);
  local index = tonumber(GUI.GetData(buyBtn,"Index"))
  local data=RECHARGE_DATA.RechargeFunction_Config[index];
  test(data.Amount)
  if UIDefine.IsFunctionOrVariableExist(LD, "QueryPayScene")  then 
      CDebug.Log("exist LD.QueryPayScene")
      LD.QueryPayScene(data.Amount)
  else
      CDebug.Log("old code!")
      CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType","Recharge",index)
  end
end

function RechargeUI.QueryPaySceneCallback(payscene)
  test("QueryPaySceneCallback:payscene="..payscene)
  local guid = _tempGuid
  local buyBtn = GUI.GetByGuid(guid);
  local index = tonumber(GUI.GetData(buyBtn,"Index"))
  if payscene == 1 then--H5支付
    print("SetRechargeType:".."Recharge,"..index);
    CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType","Recharge",index)
  elseif payscene == 2 then--苹果支付
     CDebug.Log("苹果支付")
    -- local _paysdk = "0.1"
    -- local config = nil
    -- local res,config = SETTING.TryGetBasicconfig("PaySDK",config)
    -- if res == true then
    --     print("has Key PaySDK")
    --     _paysdk = config.Value
    -- end
    -- print("paysdk=".._paysdk)
    -- if _paysdk == "0.2"  then--正式
    --   CDebug.Log("自己拉起苹果支付")
    --   local data=RECHARGE_DATA.RechargeFunction_Config[index];
    --   LD.StartPay(2,data.Amount)--自己拉起苹果支付
    -- else
    --   CDebug.Log("通过渠道走苹果支付")
    --   CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType","Recharge",index)--通过渠道走苹果支付
    -- end
    CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType","Recharge",index)
  end
end


-- function RechargeUI.OnBuyBtnClick(guid)

--   local buyBtn = GUI.GetByGuid(guid);
--   local index = tonumber(GUI.GetData(buyBtn,"Index"))
--   print("SetRechargeType:".."Recharge,"..index);
--   CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType","Recharge",index)
-- end
