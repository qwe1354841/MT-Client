SeasonPassUI = {};

local NextGoodRewardLevel = 0
local FirstRefreshServerData = "true"
local ExchangeShopItemIndex = 1             --兑换界面选中道具index
local ExchangeShopItemNum = 1				--兑换界面CountEdit中输入数字
local TokenDB = {Id=61024, Name="密藏代币", KeyName="面板展示-密藏代币", Type=3, Subtype=14, Subtype2=0, ShowType="密藏代币", User="1", NumberMax=0, Grade=6, SaleGoldBind=10, BuyGoldBind=5000, Icon=1900013860, Info="可在密藏兑换商店兑换道具", Tips="密藏奖励。", TurnBorn=0, Level=1, Sex=0, Job=0, Fight=2, FightTarget=0, StackMax=1, CarryMax=99, TimeLimit=0, TimeCount=0, BindType=0, BindConfirm=1, Tradable=1, Sale=1, SaleConfirm=0, JustUseIt=0, Ingot=5, FastShop=4, FromItem=0, ActivityId=0, Role=0, ModelMan=0, ModelWoman=0, Itemlevel=0, ArmorLevel=0, Role2=0, ModelRole1=0, ModelRole2=0, DurableLose=0, Repair=0, IconDrop=0}
local ExpDB = {Id=61020, Name="密藏经验", KeyName="面板展示-密藏经验", Type=3, Subtype=14, Subtype2=0, ShowType="密藏经验", User="1", NumberMax=0, Grade=7, SaleGoldBind=10, BuyGoldBind=5000, Icon=1900090010, Info="获取密藏经验，当达到一定值后会提升密藏等级", Tips="用于提升密藏等级。", TurnBorn=0, Level=1, Sex=0, Job=0, Fight=2, FightTarget=0, StackMax=1, CarryMax=99, TimeLimit=0, TimeCount=0, BindType=0, BindConfirm=1, Tradable=1, Sale=1, SaleConfirm=0, JustUseIt=0, Ingot=5, FastShop=4, FromItem=0, ActivityId=0, Role=0, ModelMan=0, ModelWoman=0, Itemlevel=0, ArmorLevel=0, Role2=0, ModelRole1=0, ModelRole2=0, DurableLose=0, Repair=0, IconDrop=0}

SeasonPassUI.TabIndex = 1
SeasonPassUI.SubTabIndex = 1
SeasonPassUI.SeasonPassChosen = false
SeasonPassUI.SeasonPassChosenString = "nil"
SeasonPassUI.BuyExpLevelNum = 1
SeasonPassUI.BuyExpInterfaceRoughTB = {}
SeasonPassUI.ExchangeShopInfo = {}
SeasonPassUI.PurchaesPageItem = {}
SeasonPassUI.BuyExpInterfaceTB = {NameTB = {}, Bind = {}, Count = 0,}

local tabList = {
	{"奖励","RewardTabBtn","OnRewardTabBtnClick","RewardPage","RewardPageRefresh"},  -- attrPage
	{"目标","QuestTabBtn","OnQuestTabBtnClick","QuestPage","QuestPageRefresh"},
	{"兑换","ExchangeTabBtn","OnExchangeTabBtnClick","ExchangePage","ExchangePageRefresh"},
	{"购买","PurchaesTabBtn","OnPurchaesTabBtnClick","PurchaesPage","PurchaesPageRefresh"},
}

local _gt = UILayout.NewGUIDUtilTable()

function SeasonPassUI.OnShow(parameter)
	local wnd = GUI.GetWnd('SeasonPassUI')
	if GlobalProcessing.SeasonPass_FunctionSwitch and GlobalProcessing.SeasonPass_FunctionSwitch ~= "on" then
		CL.SendNotify(NOTIFY.ShowBBMsg,"密藏功能未开启")
		return
	end
	if parameter then
		SeasonPassUI.TabIndex = tonumber(parameter) or 1
		CL.SendNotify(NOTIFY.SubmitForm, "FormSeasonPass", "GetData", SeasonPassUI.TabIndex)
	else
		CL.SendNotify(NOTIFY.SubmitForm, "FormSeasonPass", "GetData")
		SeasonPassUI.OnRewardTabBtnClick()
	end
	if wnd then
		GUI.SetVisible(wnd,true)
	end
end

function SeasonPassUI.ServertabList(para1,para2)
	if not para1 or not para2 then
		return
	end
	if tabList[para1] and tabList[para1][para2] then
		assert(loadstring("SeasonPassUI."..tabList[para1][para2].."()"))()
	end
end

function SeasonPassUI.Main(parameter)
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = GlobalProcessing.SeasonPass_OpenLevel
	if not Level then
		CL.SendNotify(NOTIFY.ShowBBMsg,"密藏功能未开启")
		return
	end
    if CurLevel < Level then
        CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..'密藏'.."功能")
        return
    end
	CL.SendNotify(NOTIFY.SubmitForm, "FormSeasonPass", "GetInitializedData")
end

function SeasonPassUI.CreateMainPage()
	local panel = GUI.WndCreateWnd("SeasonPassUI" , "SeasonPassUI" , 0 , 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "密  藏","SeasonPassUI","OnExit")
    _gt.BindName(panelBg,"panelBg")
    UILayout.CreateRightTab(tabList, "SeasonPassUI")
	local PageBg = GUI.ImageCreate(panelBg, "PageBg", "1800001060", 0, 0, false, 10, 10)
	_gt.BindName(PageBg,"PageBg")
	local ExpBar_Bg = GUI.ImageCreate(panelBg, "ExpBar_Bg", "1800001150", 105, -200, false, 825, 60)
	_gt.BindName(ExpBar_Bg, "ExpBar_Bg")
	local ExpBar = GUI.ScrollBarCreate(ExpBar_Bg, "ExpBar","","1800408160","1800408110",95,0,500,10,1,false, Transition.None, 0, 1,Direction.LeftToRight,false)
	_gt.BindName(ExpBar, "ExpBar")
	local ExpValue = Vector2.New(500,10)
	GUI.ScrollBarSetFillSize(ExpBar, ExpValue)
	GUI.ScrollBarSetBgSize(ExpBar,ExpValue)
	local ExpTxt = GUI.CreateStatic(ExpBar_Bg, "ExpTxt", "密藏经验", -345,0,120, 50)
	GUI.StaticSetFontSize(ExpTxt, 24)
	GUI.SetColor(ExpTxt, UIDefine.BrownColor)
	GUI.StaticSetAlignment(ExpTxt, TextAnchor.MiddleCenter)
	local ExpNum = GUI.CreateStatic(ExpBar_Bg, "ExpNum", SeasonPassUI.PlayerInfo.Exp.."/"..SeasonPassUI.LevelUpExp, -245,0,150, 50)
	GUI.StaticSetFontSize(ExpNum, 24)
	GUI.SetColor(ExpNum, UIDefine.BrownColor)
	GUI.StaticSetAlignment(ExpNum, TextAnchor.MiddleRight)
	_gt.BindName(ExpNum, "ExpNum")
	
	--购买等级按钮
	local AddExpBtn = GUI.ButtonCreate(ExpBar_Bg, "AddExpBtn", "1800402060",380,0,Transition.ColorTint, "", 34,33, false)
	GUI.RegisterUIEvent(AddExpBtn, UCE.PointerClick, "SeasonPassUI", "AddExpBtnClick");
	
	local ExpLevelTxt_Bg = GUI.ImageCreate(panelBg, "ExpLevelTxt_Bg", "1800600930", -413, -200, false, 208, 58)
	_gt.BindName(ExpLevelTxt_Bg, "ExpLevelTxt_Bg")
	local levelname = GUI.CreateStatic(ExpLevelTxt_Bg, "levelname", "密藏等级",5,1,180,40)
	GUI.StaticSetFontSize(levelname, 24)
	GUI.SetColor(levelname, UIDefine.WhiteColor)
	GUI.StaticSetAlignment(levelname, TextAnchor.MiddleLeft)
	_gt.BindName(levelname, "levelname")
	local levelnum = GUI.CreateStatic(ExpLevelTxt_Bg, "levelnum", SeasonPassUI.PlayerInfo.Level,55,-1,180,40, "108")
	GUI.StaticSetFontSize(levelnum, 30)
	GUI.StaticSetAlignment(levelnum, TextAnchor.MiddleCenter)
	GUI.StaticSetIsGradientColor(levelnum,true)
	GUI.StaticSetGradient_ColorTop(levelnum,Color.New(255/255,244/255,139/255,255/255))
	GUI.SetIsOutLine(levelnum,true)
	GUI.SetOutLine_Distance(levelnum,3)
	GUI.SetOutLine_Color(levelnum,Color.New(182/255,52/255,40/255,255/255))
	GUI.SetIsShadow(levelnum,true)
	GUI.SetShadow_Distance(levelnum,Vector2.New(0,-1))
	GUI.SetShadow_Color(levelnum,UIDefine.BlackColor)
	_gt.BindName(levelnum, "levelnum")
	
	local SeasonPassTime_Bg = GUI.ImageCreate(panelBg, "SeasonPassTime_Bg", "1800600690", 0, -255, false, 600, 40)
	UILayout.SetSameAnchorAndPivot(SeasonPassTime_Bg, UILayout.Center)
	_gt.BindName(SeasonPassTime_Bg, "SeasonPassTime_Bg")
	local SeasonPassTime = GUI.CreateStatic(SeasonPassTime_Bg, "SeasonPassTime", "密藏有效期  "..SeasonPassUI.Time[1].." 至 "..SeasonPassUI.Time[2],0,0,600,40)
	GUI.StaticSetFontSize(SeasonPassTime, 23)
	GUI.SetColor(SeasonPassTime, UIDefine.BrownColor)
	GUI.StaticSetAlignment(SeasonPassTime, TextAnchor.MiddleCenter)
	
	--快速购买等级页面
	local BuyExpInterface_Bg = GUI.ImageCreate(panelBg, "BuyExpInterface_Bg", "1800400220", 0, 0, false, 2000, 2000)
	GUI.SetIsRaycastTarget(BuyExpInterface_Bg, true)
	_gt.BindName(BuyExpInterface_Bg, "BuyExpInterface_Bg")
	BuyExpInterface_Bg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(BuyExpInterface_Bg, UCE.PointerClick, "SeasonPassUI", "BuyExpInterfaceCloseClick")
	local BuyExpInterface = GUI.ImageCreate(BuyExpInterface_Bg, "BuyExpInterface", "1800001150", 0, 0, false, 720, 400)
	GUI.SetIsRaycastTarget(BuyExpInterface, true)
	
	local BuyExpInterfaceTitle = GUI.CreateStatic(BuyExpInterface, "BuyExpInterfaceTitle", "购买密藏等级",-249,-162,180,40)
	GUI.StaticSetFontSize(BuyExpInterfaceTitle, 26)
	GUI.SetColor(BuyExpInterfaceTitle, UIDefine.BrownColor)

	local ItemPreview_Bg = GUI.ImageCreate(BuyExpInterface, "ItemPreview_Bg", "1800300040", -158, 25, false, 360, 310)
	GUI.SetIsRaycastTarget(ItemPreview_Bg, true)
	local TxtHint = GUI.CreateStatic(ItemPreview_Bg, "TxtHint", "可获得奖励预览",-100,-130,160,40)
	GUI.StaticSetFontSize(TxtHint, 20)
	GUI.SetColor(TxtHint, UIDefine.BrownColor)
	GUI.StaticSetAlignment(TxtHint, TextAnchor.MiddleCenter)
	local ItemPreview = GUI.LoopScrollRectCreate(ItemPreview_Bg, "ItemPreview", 0,20,350,260, "SeasonPassUI", "CreateItemPreviewScroll", "SeasonPassUI", "RefreshItemPreviewScroll", 30, false, Vector2.New(80, 80), 4, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
	GUI.ScrollRectSetChildSpacing(ItemPreview,Vector2.New(10,10))
	_gt.BindName(ItemPreview, "ItemPreview")
	GUI.LoopScrollRectSetTotalCount(ItemPreview, SeasonPassUI.MaxLevel)
	local LevelPreview_Bg = GUI.ImageCreate(BuyExpInterface, "LevelPreview_Bg", "1800300040", 185, -80, false, 300, 100)
	GUI.SetIsRaycastTarget(LevelPreview_Bg, true)
    LevelPreview_Bg:RegisterEvent(UCE.PointerClick)
	GUI.ImageCreate(LevelPreview_Bg, "arrow", "1801208630", 0, 0, false, 23, 38)
	local CurLevelTxt = GUI.CreateStatic(LevelPreview_Bg, "CurLevelTxt", "当前等级",-80,-25,150,50)
	GUI.StaticSetFontSize(CurLevelTxt, 25)
	GUI.SetColor(CurLevelTxt, UIDefine.BrownColor)
	GUI.StaticSetAlignment(CurLevelTxt, TextAnchor.MiddleCenter)
	local CurLevel = GUI.CreateStatic(LevelPreview_Bg, "CurLevel", "1",-80,15,100,50)
	GUI.StaticSetFontSize(CurLevel, 35)
	GUI.SetColor(CurLevel, UIDefine.BrownColor)
	GUI.StaticSetAlignment(CurLevel, TextAnchor.MiddleCenter)
	_gt.BindName(CurLevel, "CurLevel")
	local TargetLevelTxt = GUI.CreateStatic(LevelPreview_Bg, "TargetLevelTxt", "提升等级至",80,-25,150,50)
	GUI.StaticSetFontSize(TargetLevelTxt, 25)
	GUI.SetColor(TargetLevelTxt, UIDefine.BrownColor)
	GUI.StaticSetAlignment(TargetLevelTxt, TextAnchor.MiddleCenter)
	local TargetLevel = GUI.CreateStatic(LevelPreview_Bg, "TargetLevel", "2",80,15,100,50)
	GUI.StaticSetFontSize(TargetLevel, 35)
	GUI.SetColor(TargetLevel, UIDefine.BrownColor)
	GUI.StaticSetAlignment(TargetLevel, TextAnchor.MiddleCenter)
	_gt.BindName(TargetLevel, "TargetLevel")
	
	local MinusBtn = GUI.ButtonCreate(BuyExpInterface, "MinusBtn", "1800402140",130,15,Transition.ColorTint, "", 50,50, false)
	GUI.RegisterUIEvent(MinusBtn, UCE.PointerClick, "SeasonPassUI", "BuyExpInterfaceMinusBtn");
	local PlusBtn = GUI.ButtonCreate(BuyExpInterface, "PlusBtn", "1800402150",310,15,Transition.ColorTint, "", 50,50, false)
	GUI.RegisterUIEvent(PlusBtn, UCE.PointerClick, "SeasonPassUI", "BuyExpInterfacePlusBtn");
	local BuyExpcountEdit = GUI.EditCreate(BuyExpInterface, "BuyExpcountEdit", "1800400390", "", 220, 15, Transition.ColorTint, "system", 100, 44, 30, 8, InputType.Standard, ContentType.IntegerNumber)
    GUI.EditSetFontSize(BuyExpcountEdit, UIDefine.FontSizeM)
    GUI.EditSetTextColor(BuyExpcountEdit, UIDefine.BrownColor)
    GUI.EditSetTextM(BuyExpcountEdit, "1")
	GUI.EditSetMaxCharNum(BuyExpcountEdit, 2)
    GUI.RegisterUIEvent(BuyExpcountEdit, UCE.EndEdit, "SeasonPassUI", "BuyExpInterfaceEndEdit")
    _gt.BindName(BuyExpcountEdit, "BuyExpcountEdit")

	_gt.BindName(BuyLevelPreview, "BuyLevelPreview")
	local BuyLevelHint = GUI.CreateStatic(BuyExpInterface, "BuyLevelHint", "数量",65,15,100,50)
	GUI.StaticSetFontSize(BuyLevelHint, 26)
	GUI.SetColor(BuyLevelHint, UIDefine.BrownColor)
	GUI.StaticSetAlignment(BuyLevelHint, TextAnchor.MiddleCenter)
	local TotalCost = GUI.ImageCreate(BuyExpInterface, "TotalCost", "1800900040", 220, 80, false, 230, 40)
	GUI.SetIsRaycastTarget(TotalCost, true)
	local TotalCostIcon = GUI.ImageCreate(TotalCost, "TotalCostIcon", "1800408250", -90, -1, false, 40, 40)
	local TotalCostNum = GUI.CreateStatic(TotalCost, "TotalCostNum", "20000",20,-1,180,50)
	GUI.StaticSetFontSize(TotalCostNum, 26)
	GUI.SetColor(TotalCostNum, UIDefine.WhiteColor)
	GUI.StaticSetAlignment(TotalCostNum, TextAnchor.MiddleCenter)
	_gt.BindName(TotalCostNum, "TotalCostNum")
	local TotalCostTxt = GUI.CreateStatic(TotalCost, "TotalCostTxt", "花费",-155,-1,100,50)
	GUI.StaticSetFontSize(TotalCostTxt, 26)
	GUI.SetColor(TotalCostTxt, UIDefine.BrownColor)
	GUI.StaticSetAlignment(TotalCostTxt, TextAnchor.MiddleCenter)
	local BuyLevelBtn = GUI.ButtonCreate(BuyExpInterface, "BuyLevelBtn", "1801720100",185,147,Transition.ColorTint, "购买", 300,60, false)
	GUI.ButtonSetTextColor(BuyLevelBtn, UIDefine.YellowStdColor)
	GUI.ButtonSetTextFontSize(BuyLevelBtn, 32)
	GUI.RegisterUIEvent(BuyLevelBtn, UCE.PointerClick, "SeasonPassUI", "BuyLevelBtnClick");
	local BuyExpInterfaceClose = GUI.ButtonCreate(BuyExpInterface, "BuyExpInterfaceClose", "1800002050",330,-170,Transition.ColorTint, "", 24,24, false)
	GUI.RegisterUIEvent(BuyExpInterfaceClose, UCE.PointerClick, "SeasonPassUI", "BuyExpInterfaceCloseClick");
	
	GUI.SetVisible(BuyExpInterface_Bg, false)
	
	SeasonPassUI.TabIndex = 1
	SeasonPassUI.OnRewardTabBtnClick()
end

function SeasonPassUI.OnRewardTabBtnClick()
	UILayout.OnTabClick(1, tabList)
	local RewardPage = _gt.GetUI("RewardPage")
	if not RewardPage then
		local PageBg = _gt.GetUI("PageBg")
		local RewardPage = GUI.ImageCreate(PageBg, "RewardPage", "1800400010", 0, 20, false, 1040, 370)
		_gt.BindName(RewardPage,"RewardPage")
		
		local UnLockSeasonPassBtn = GUI.ButtonCreate(RewardPage, "UnLockSeasonPassBtn", "1800002031", 180, 230,Transition.ColorTint, "解锁天宫密藏", 220,55, false)
		GUI.ButtonSetTextFontSize(UnLockSeasonPassBtn, 24)
		GUI.ButtonSetTextColor(UnLockSeasonPassBtn, UIDefine.BrownColor)
		GUI.RegisterUIEvent(UnLockSeasonPassBtn, UCE.PointerClick, "SeasonPassUI", "UnLockSeasonPassBtnClick");
		_gt.BindName(UnLockSeasonPassBtn, "UnLockSeasonPassBtn")
		if SeasonPassUI.PlayerInfo.Bought == "true" then
			GUI.SetVisible(UnLockSeasonPassBtn, false)
		else
			GUI.SetVisible(UnLockSeasonPassBtn, true)
		end
		
		local GetAllRewardBtn = GUI.ButtonCreate(RewardPage, "GetAllRewardBtn", "1800002031", 430,230,Transition.ColorTint, "全部领取", 170,55, false)
		GUI.ButtonSetTextFontSize(GetAllRewardBtn, 24)
		GUI.ButtonSetTextColor(GetAllRewardBtn, UIDefine.BrownColor)
		GUI.RegisterUIEvent(GetAllRewardBtn, UCE.PointerClick, "SeasonPassUI", "GetAllRewardBtnClick");
		
		local itemLoopScroll_Bg = GUI.ImageCreate(RewardPage, "itemLoopScroll_Bg", "1800001060", 0, -25, false, 800, 305)
		local LeftSoildUnit = GUI.ImageCreate(itemLoopScroll_Bg, "LeftSoildUnit", "1800001150", -452,25,false, 120,350)
		GUI.ImageCreate(LeftSoildUnit, "CutLineUp", "1800007041", 0, -130, false, 115, 5)
		GUI.ImageCreate(LeftSoildUnit, "CutLineDown", "1800007041", 0, -20, false, 115, 5)
		local LeftSoildUnit_Txt1 = GUI.CreateStatic(LeftSoildUnit, "LeftSoildUnit_Txt1", "等级", 0, -150, 100, 50)
		GUI.StaticSetFontSize(LeftSoildUnit_Txt1, 24)
		GUI.SetColor(LeftSoildUnit_Txt1, UIDefine.BrownColor)
		GUI.StaticSetAlignment(LeftSoildUnit_Txt1, TextAnchor.MiddleCenter)
		local LeftSoildUnit_Txt2 = GUI.CreateStatic(LeftSoildUnit, "LeftSoildUnit_Txt2", "长安密藏", 0, -75, 100, 50)
		GUI.StaticSetFontSize(LeftSoildUnit_Txt2, 24)
		GUI.SetColor(LeftSoildUnit_Txt2, UIDefine.BrownColor)
		GUI.StaticSetAlignment(LeftSoildUnit_Txt2, TextAnchor.MiddleCenter)
		local LeftSoildUnit_Txt3 = GUI.CreateStatic(LeftSoildUnit, "LeftSoildUnit_Txt3", "天宫密藏", 0, 80, 100, 50)
		GUI.StaticSetFontSize(LeftSoildUnit_Txt3, 24)
		GUI.SetColor(LeftSoildUnit_Txt3, UIDefine.BrownColor)
		GUI.StaticSetAlignment(LeftSoildUnit_Txt3, TextAnchor.MiddleCenter)
		
		--大师兄说了, 这块不要
		--local RightSoildUnit = GUI.ImageCreate(itemLoopScroll_Bg, "RightSoildUnit", "1800600930", 451,25,false, 119,348)
		--GUI.ImageCreate(RightSoildUnit, "CutLineUp", "1800007041", 0, -130, false, 115, 5)
		--GUI.ImageCreate(RightSoildUnit, "CutLineDown", "1800007041", 0, -20, false, 115, 5)
		--local RightSoildUnit_Level = GUI.CreateStatic(RightSoildUnit, "RightSoildUnit_Level", SeasonPassUI.GoodRewardLevel.."级", -17, -150, 100, 50)
		--GUI.StaticSetFontSize(RightSoildUnit_Level, 24)
		--GUI.SetColor(RightSoildUnit_Level, UIDefine.BrownColor)
		--GUI.StaticSetAlignment(RightSoildUnit_Level, TextAnchor.MiddleCenter)
		--_gt.BindName(RightSoildUnit_Level, "RightSoildUnit_Level")
		--local RightSoildUnit_LowValueReward = ItemIcon.Create(RightSoildUnit, "RightSoildUnit_LowValueReward", 0, -75)
		--GUI.RegisterUIEvent(RightSoildUnit_LowValueReward, UCE.PointerClick, "SeasonPassUI", "OnNextGoodRewardClick");
		--GUI.SetData(RightSoildUnit_LowValueReward, "Value", "LowValue")
		--_gt.BindName(RightSoildUnit_LowValueReward, "RightSoildUnit_LowValueReward")
		--local RightSoildUnit_LowValueReward_FinishIcon = GUI.ImageCreate(RightSoildUnit_LowValueReward, "RightSoildUnit_LowValueReward_FinishIcon", "1801208640", 0,0, false, 60, 48)
		--GUI.SetVisible(RightSoildUnit_LowValueReward_FinishIcon, false)
		--_gt.BindName(RightSoildUnit_LowValueReward_FinishIcon, "RightSoildUnit_LowValueReward_FinishIcon")
		--local RightSoildUnit_HighValueReward_1 = ItemIcon.Create(RightSoildUnit, "RightSoildUnit_HighValueReward_1", 0, 35)
		--GUI.RegisterUIEvent(RightSoildUnit_HighValueReward_1, UCE.PointerClick, "SeasonPassUI", "OnNextGoodRewardClick");
		--GUI.SetData(RightSoildUnit_HighValueReward_1, "Value", "HighValue1")
		--_gt.BindName(RightSoildUnit_HighValueReward_1, "RightSoildUnit_HighValueReward_1")
		--local RightSoildUnit_HighValueReward_1_FinishIcon = GUI.ImageCreate(RightSoildUnit_HighValueReward_1, "RightSoildUnit_HighValueReward_1_FinishIcon", "1801208640", 0,0, false, 60, 48)
		--GUI.SetVisible(RightSoildUnit_HighValueReward_1_FinishIcon, false)
		--_gt.BindName(RightSoildUnit_HighValueReward_1_FinishIcon, "RightSoildUnit_HighValueReward_1_FinishIcon")
		--local RightSoildUnit_HighValueReward_2 = ItemIcon.Create(RightSoildUnit, "RightSoildUnit_HighValueReward_2", 0, 125)
		--GUI.RegisterUIEvent(RightSoildUnit_HighValueReward_2, UCE.PointerClick, "SeasonPassUI", "OnNextGoodRewardClick");
		--GUI.SetData(RightSoildUnit_HighValueReward_2, "Value", "HighValue2")
		--_gt.BindName(RightSoildUnit_HighValueReward_2, "RightSoildUnit_HighValueReward_2")
		--local RightSoildUnit_HighValueReward_2_FinishIcon = GUI.ImageCreate(RightSoildUnit_HighValueReward_2, "RightSoildUnit_HighValueReward_2_FinishIcon", "1801208640", 0,0, false, 60, 48)
		--GUI.SetVisible(RightSoildUnit_HighValueReward_2_FinishIcon, false)
		--_gt.BindName(RightSoildUnit_HighValueReward_2_FinishIcon, "RightSoildUnit_HighValueReward_2_FinishIcon")
		--local NextGoodRewardBtn = GUI.ButtonCreate(RightSoildUnit, "NextGoodRewardBtn", "1800702030", 36, -149, Transition.ColorTint, "", 32, 32, false)
		--GUI.RegisterUIEvent(NextGoodRewardBtn, UCE.PointerClick, "SeasonPassUI", "NextGoodRewardBtnClick");
		--_gt.BindName(NextGoodRewardBtn, "NextGoodRewardBtn")
		
		--左下问题提示
		local StaticHint = GUI.CreateStatic(RewardPage, "StaticHint", "每         级均有丰厚奖励", -360, 230, 400, 50)
		GUI.StaticSetFontSize(StaticHint, 30)
		GUI.SetColor(StaticHint, UIDefine.BrownColor)
		GUI.StaticSetAlignment(StaticHint, TextAnchor.MiddleCenter)
		local GoodRewardLevel = GUI.CreateStatic(RewardPage, "GoodRewardLevel", SeasonPassUI.GoodRewardLevel,-448,228,100,40, "108")
		GUI.StaticSetFontSize(GoodRewardLevel, 30)
		GUI.StaticSetAlignment(GoodRewardLevel, TextAnchor.MiddleCenter)
		GUI.StaticSetIsGradientColor(GoodRewardLevel,true)
		GUI.StaticSetGradient_ColorTop(GoodRewardLevel,Color.New(255/255,244/255,139/255,255/255))
		GUI.SetIsOutLine(GoodRewardLevel,true)
		GUI.SetOutLine_Distance(GoodRewardLevel,3)
		GUI.SetOutLine_Color(GoodRewardLevel,Color.New(182/255,52/255,40/255,255/255))
		GUI.SetIsShadow(GoodRewardLevel,true)
		GUI.SetShadow_Distance(GoodRewardLevel,Vector2.New(0,-1))
		GUI.SetShadow_Color(GoodRewardLevel,UIDefine.BlackColor)
		
		local itemLoopScroll = GUI.LoopScrollRectCreate(itemLoopScroll_Bg, "itemLoopScroll", 60,25,900,350, "SeasonPassUI", "CreateitemLoopScroll", "SeasonPassUI", "RefreshitemLoopScroll", 10, true, Vector2.New(120, 350), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
		_gt.BindName(itemLoopScroll, "itemLoopScroll")
		GUI.LoopScrollRectSetTotalCount(itemLoopScroll, SeasonPassUI.MaxLevel)
		GUI.LoopScrollRectSrollToCell(itemLoopScroll, SeasonPassUI.PlayerInfo.Level - 1, 0)
	end
	SeasonPassUI.SubTabIndex = 1
	SeasonPassUI.SwitchPage(1)
end

function SeasonPassUI.OnQuestTabBtnClick()
	UILayout.OnTabClick(2, tabList)
	local QuestPage = _gt.GetUI("QuestPage")
	if not QuestPage then
		local PageBg = _gt.GetUI("PageBg")
		local QuestPage = GUI.ImageCreate(PageBg, "QuestPage", "1800400010", 0, 55, false, 1040, 440)
		_gt.BindName(QuestPage,"QuestPage")
		local DailyQuestBtn = GUI.ButtonCreate(QuestPage, "DailyQuestBtn", "1800002031", -410,-168,Transition.ColorTint, "", 190,65, false)
		local DailyQuestTxt = GUI.CreateStatic(DailyQuestBtn, "DailyQuestTxt", "每日目标", 0, 0, 200, 50)
		GUI.StaticSetFontSize(DailyQuestTxt, 24)
		GUI.SetColor(DailyQuestTxt, UIDefine.BrownColor)
		GUI.StaticSetAlignment(DailyQuestTxt, TextAnchor.MiddleCenter)
		GUI.RegisterUIEvent(DailyQuestBtn, UCE.PointerClick, "SeasonPassUI", "DailyQuestBtnClick");
		_gt.BindName(DailyQuestBtn, "DailyQuestBtn")
		local WeeklyQuestBtn = GUI.ButtonCreate(QuestPage, "WeeklyQuestBtn", "1800002031", -410,-88,Transition.ColorTint, "", 190,65, false)
		local WeeklyQuestTxt = GUI.CreateStatic(WeeklyQuestBtn, "WeeklyQuestTxt", "每周目标", 0, 0, 200, 50)
		GUI.StaticSetFontSize(WeeklyQuestTxt, 24)
		GUI.SetColor(WeeklyQuestTxt, UIDefine.BrownColor)
		GUI.StaticSetAlignment(WeeklyQuestTxt, TextAnchor.MiddleCenter)
		GUI.RegisterUIEvent(WeeklyQuestBtn, UCE.PointerClick, "SeasonPassUI", "WeeklyQuestBtnClick");
		_gt.BindName(WeeklyQuestBtn, "WeeklyQuestBtn")
		local OnceQuestBtn = GUI.ButtonCreate(QuestPage, "OnceQuestBtn", "1800002031", -410,-8,Transition.ColorTint, "", 190,65, false)
		local OnceQuestTxt = GUI.CreateStatic(OnceQuestBtn, "OnceQuestTxt", "一次性目标", 0, 0, 200, 50)
		GUI.StaticSetFontSize(OnceQuestTxt, 24)
		GUI.SetColor(OnceQuestTxt, UIDefine.BrownColor)
		GUI.StaticSetAlignment(OnceQuestTxt, TextAnchor.MiddleCenter)
		GUI.RegisterUIEvent(OnceQuestBtn, UCE.PointerClick, "SeasonPassUI", "OnceQuestBtnClick");
		_gt.BindName(OnceQuestBtn, "OnceQuestBtn")
		
		local QuestScroll_Bg = GUI.ImageCreate(QuestPage, "QuestScroll_Bg", "1800400360", 100, 0, false, 820, 420)
		local QuestScroll = GUI.LoopScrollRectCreate(QuestScroll_Bg, "QuestScroll", 0,0,800,400, "SeasonPassUI", "CreateQuestScroll", "SeasonPassUI", "RefreshQuestScroll", 5, false, Vector2.New(800, 100), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
		_gt.BindName(QuestScroll, "QuestScroll")
		GUI.LoopScrollRectSetTotalCount(QuestScroll, 10)

		local EmptyHint = GUI.CreateStatic(QuestScroll_Bg, "EmptyHint", "暂无任务", 0, 0, 300, 150)
		GUI.StaticSetFontSize(EmptyHint, 50)
		GUI.SetColor(EmptyHint, UIDefine.BrownColor)
		GUI.StaticSetAlignment(EmptyHint, TextAnchor.MiddleCenter)
		GUI.SetVisible(EmptyHint, false)
		_gt.BindName(EmptyHint, "EmptyHint")
	end
	SeasonPassUI.SwitchPage(2)
end

function SeasonPassUI.OnExchangeTabBtnClick()
	UILayout.OnTabClick(3, tabList)
	local ExchangePage = _gt.GetUI("ExchangePage")
	if not ExchangePage then
		local PageBg = _gt.GetUI("PageBg")
		local ExchangePage = GUI.ImageCreate(PageBg, "ExchangePage", "1800001060", 0, 55, false, 1040, 440)
		_gt.BindName(ExchangePage,"ExchangePage")
		
		local ExchangeScroll_Bg = GUI.ImageCreate(ExchangePage, "ExchangeScroll_Bg", "1800400010", -175, 0, false, 690, 440)
		local ExchangeScroll = GUI.LoopScrollRectCreate(ExchangeScroll_Bg, "ExchangeScroll", 0,0,665,420, "SeasonPassUI", "CreateExchangeScroll", "SeasonPassUI", "RefreshExchangeScroll", 8, false, Vector2.New(330, 110), 2, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
		_gt.BindName(ExchangeScroll, "ExchangeScroll")
		GUI.LoopScrollRectSetTotalCount(ExchangeScroll, #SeasonPassUI.ExchangeShopRoughInfo)
		GUI.ScrollRectSetChildSpacing(ExchangeScroll, Vector2.New(5, 0))
		local ExchangeItemInfo_Bg = GUI.ImageCreate(ExchangePage, "ExchangeItemInfo_Bg", "1800400010", 345, -115, false, 350, 210)
		local ExchangeItemInfoName = GUI.CreateStatic(ExchangeItemInfo_Bg, "ExchangeItemInfoName", "物品名字", 0, -80, 200, 50)
		GUI.StaticSetFontSize(ExchangeItemInfoName, 24)
		GUI.SetColor(ExchangeItemInfoName, UIDefine.BrownColor)
		GUI.StaticSetAlignment(ExchangeItemInfoName, TextAnchor.MiddleCenter)
		_gt.BindName(ExchangeItemInfoName, "ExchangeItemInfoName")
		
		local ExchangeItemInfoType = GUI.CreateStatic(ExchangeItemInfo_Bg, "ExchangeItemInfoType", "类型:", -125, -50, 70, 50)
		GUI.StaticSetFontSize(ExchangeItemInfoType, 24)
		GUI.SetColor(ExchangeItemInfoType, UIDefine.BrownColor)
		GUI.StaticSetAlignment(ExchangeItemInfoType, TextAnchor.MiddleLeft)
		local ExchangeItemInfoTypeName = GUI.CreateStatic(ExchangeItemInfo_Bg, "ExchangeItemInfoTypeName", "消耗品", -20, -50, 150, 50, "system", true)
		GUI.StaticSetFontSize(ExchangeItemInfoTypeName, 24)
		GUI.SetColor(ExchangeItemInfoTypeName, Color.New(173 / 255, 105 / 255, 50 / 255, 1))
		GUI.StaticSetAlignment(ExchangeItemInfoTypeName, TextAnchor.MiddleLeft)
		_gt.BindName(ExchangeItemInfoTypeName, "ExchangeItemInfoTypeName")
		
		local ExchangeItemInfoLevel = GUI.CreateStatic(ExchangeItemInfo_Bg, "ExchangeItemInfoLevel", "使用等级:", -100, -20, 120, 50)
		GUI.StaticSetFontSize(ExchangeItemInfoLevel, 24)
		GUI.SetColor(ExchangeItemInfoLevel, UIDefine.BrownColor)
		GUI.StaticSetAlignment(ExchangeItemInfoLevel, TextAnchor.MiddleLeft)
		local ExchangeItemInfoLevelNum = GUI.CreateStatic(ExchangeItemInfo_Bg, "ExchangeItemInfoLevelNum", "12转120级", 25, -20, 150, 50, "system", true)
		GUI.StaticSetFontSize(ExchangeItemInfoLevelNum, 24)
		GUI.SetColor(ExchangeItemInfoLevelNum, Color.New(173 / 255, 105 / 255, 50 / 255, 1))
		GUI.StaticSetAlignment(ExchangeItemInfoLevelNum, TextAnchor.MiddleLeft)
		_gt.BindName(ExchangeItemInfoLevelNum, "ExchangeItemInfoLevelNum")
		
		local descScroll = GUI.ScrollRectCreate(ExchangeItemInfo_Bg, "descScroll", 0, 43, 320, 95, 0, false, Vector2.New(320, 220), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
		_gt.BindName(descScroll, "descScroll")
		local ExchangeItemInfoEffect = GUI.CreateStatic(descScroll, "ExchangeItemInfoEffect", "使用效果: 阿巴阿巴阿巴阿巴阿巴阿巴阿巴阿巴阿巴阿巴阿巴阿巴", 0, 0, 370, 105)
		GUI.StaticSetFontSize(ExchangeItemInfoEffect, 24)
		GUI.SetColor(ExchangeItemInfoEffect, UIDefine.BrownColor)
		GUI.StaticSetAlignment(ExchangeItemInfoEffect, TextAnchor.UpperLeft)
		_gt.BindName(ExchangeItemInfoEffect, "ExchangeItemInfoEffect")
		
		local ExchangeTokenInfo_Bg = GUI.ImageCreate(ExchangePage, "ExchangeTokenInfo_Bg", "1800001060", 345, 105, false, 350, 235)
		local CountTxt = GUI.CreateStatic(ExchangeTokenInfo_Bg, "CountTxt", "数量", -135, -75, 100, 30)
		GUI.StaticSetFontSize(CountTxt, 24)
		GUI.SetColor(CountTxt, UIDefine.BrownColor)
		GUI.StaticSetAlignment(CountTxt, TextAnchor.MiddleCenter)
		local SpendBg = GUI.ImageCreate(ExchangeTokenInfo_Bg, "SpendBg", "1800700010", 40, -15, false, 255, 35)
		local OwnBg = GUI.ImageCreate(ExchangeTokenInfo_Bg, "OwnBg", "1800700010", 40, 35, false, 255, 35)
		local SpendTxt = GUI.CreateStatic(SpendBg, "SpendTxt", "花费", -175, 0, 100, 30)
		GUI.StaticSetFontSize(SpendTxt, 24)
		GUI.SetColor(SpendTxt, UIDefine.BrownColor)
		GUI.StaticSetAlignment(SpendTxt, TextAnchor.MiddleCenter)
		local OwnTxt = GUI.CreateStatic(OwnBg, "OwnTxt", "拥有", -175, 0, 100, 30)
		GUI.StaticSetFontSize(OwnTxt, 24)
		GUI.SetColor(OwnTxt, UIDefine.BrownColor)
		GUI.StaticSetAlignment(OwnTxt, TextAnchor.MiddleCenter)
		local ExchangeTokenIcon1 = GUI.ImageCreate(SpendBg, "ExchangeTokenIcon1", "1900013860", -105, -2, false, 35, 35)
		local ExchangeTokenIcon2 = GUI.ImageCreate(OwnBg, "ExchangeTokenIcon2", "1900013860", -105, -2, false, 35, 35)
		local ExchangeTokenSpendNum = GUI.CreateStatic(SpendBg, "ExchangeTokenSpendNum", "0", 15, 0, 210, 30)
		GUI.StaticSetFontSize(ExchangeTokenSpendNum, 22)
		GUI.SetColor(ExchangeTokenSpendNum, UIDefine.WhiteColor)
		GUI.StaticSetAlignment(ExchangeTokenSpendNum, TextAnchor.MiddleCenter)
		_gt.BindName(ExchangeTokenSpendNum, "ExchangeTokenSpendNum")
		local ExchangeTokenOwnNum = GUI.CreateStatic(OwnBg, "ExchangeTokenOwnNum", "99999", 15, 0, 210, 30)
		GUI.StaticSetFontSize(ExchangeTokenOwnNum, 22)
		GUI.SetColor(ExchangeTokenOwnNum, UIDefine.WhiteColor)
		GUI.StaticSetAlignment(ExchangeTokenOwnNum, TextAnchor.MiddleCenter)
		_gt.BindName(ExchangeTokenOwnNum, "ExchangeTokenOwnNum")
		local ExchangeBtn = GUI.ButtonCreate(ExchangeTokenInfo_Bg, "ExchangeBtn", "1800002031", 95,90,Transition.ColorTint, "兑换", 150,50, false)
		GUI.SetIsOutLine(ExchangeBtn, true)
		GUI.ButtonSetTextFontSize(ExchangeBtn, UIDefine.FontSizeXL)
		GUI.ButtonSetTextColor(ExchangeBtn, UIDefine.WhiteColor)
		GUI.SetOutLine_Color(ExchangeBtn, UIDefine.OutLine_BrownColor)
		GUI.SetOutLine_Distance(ExchangeBtn, UIDefine.OutLineDistance)
		GUI.RegisterUIEvent(ExchangeBtn, UCE.PointerClick, "SeasonPassUI", "ExchangeBtnClick");
		local ExchangeMinusBtn = GUI.ButtonCreate(ExchangeTokenInfo_Bg, "ExchangeMinusBtn", "1800402140", -60,-75,Transition.ColorTint, "", 50,50, false)
		GUI.RegisterUIEvent(ExchangeMinusBtn, UCE.PointerClick, "SeasonPassUI", "ExchangeMinusBtnClick");
		local ExchangePlusBtn = GUI.ButtonCreate(ExchangeTokenInfo_Bg, "ExchangePlusBtn", "1800402150", 140,-75,Transition.ColorTint, "", 50,50, false)
		GUI.RegisterUIEvent(ExchangePlusBtn, UCE.PointerClick, "SeasonPassUI", "ExchangePlusBtnClick");
		local CountEdit = GUI.EditCreate(ExchangeTokenInfo_Bg, "CountEdit", "1800400390", "1", 40, -75, Transition.ColorTint, "system", 130, 50, 8, 8, InputType.Standard, ContentType.IntegerNumber)
		--GUI.SetAnchor(CountEdit, UIAnchor.TopLeft)
		--GUI.SetPivot(CountEdit, UIAroundPivot.TopLeft)
		GUI.EditSetLabelAlignment(CountEdit, TextAnchor.MiddleCenter)
		GUI.EditSetTextColor(CountEdit, UIDefine.BrownColor)
		GUI.EditSetFontSize(CountEdit, 25);	
		GUI.EditSetMaxCharNum(CountEdit, 4)
		_gt.BindName(CountEdit, "CountEdit")
		GUI.RegisterUIEvent(CountEdit, UCE.EndEdit, "SeasonPassUI", "OnNumCountChange")
		local PlaceholderText = GUI.GetChild(CountEdit, "PlaceholderText", false)
		GUI.StaticSetFontSize(PlaceholderText, 25)
	end
	SeasonPassUI.SubTabIndex = 1
	SeasonPassUI.SwitchPage(3)
end

function SeasonPassUI.OnPurchaesTabBtnClick()
	if SeasonPassUI.PlayerInfo.Bought == "true" then
		SeasonPassUI.OnRewardTabBtnClick()
		--UILayout.OnTabClick(1, tabList)
		CL.SendNotify(NOTIFY.ShowBBMsg, "您已购买过密藏，无需再次购买")		--搓说的, 买过任意一版之后就不给进购买页
		return
	end
	UILayout.OnTabClick(4, tabList)
	local PurchaesPage = _gt.GetUI("PurchaesPage")
	if not PurchaesPage then
		local PageBg = _gt.GetUI("PageBg")
		local PurchaesPage = GUI.ImageCreate(PageBg, "PurchaesPage", "1800400010", 0, 10, false, 1040, 550)
		_gt.BindName(PurchaesPage,"PurchaesPage")

		local NormalType_Bg = GUI.ImageCreate(PurchaesPage, "NormalType_Bg", "1800601210", -344,0, false, 334, 532)
		GUI.SetData(NormalType_Bg, "Type", "NormalType")
		_gt.BindName(NormalType_Bg, "NormalType_Bg")
		GUI.SetIsRaycastTarget(NormalType_Bg, true)
		NormalType_Bg:RegisterEvent(UCE.PointerClick)
		GUI.RegisterUIEvent(NormalType_Bg, UCE.PointerClick, "SeasonPassUI", "NormalBuyBtnClick");
		
		local NormalTypeName = GUI.CreateStatic(NormalType_Bg, "NormalTypeName","普通版",0, -225, 240, 50,"105");
		GUI.StaticSetFontSize(NormalTypeName, 40)
		GUI.StaticSetAlignment(NormalTypeName, TextAnchor.MiddleCenter)
		GUI.StaticSetIsGradientColor(NormalTypeName,true)
		GUI.StaticSetGradient_ColorTop(NormalTypeName,Color.New(255/255,244/255,139/255,255/255))
		GUI.SetIsOutLine(NormalTypeName,true)
		GUI.SetOutLine_Distance(NormalTypeName,3)
		GUI.SetOutLine_Color(NormalTypeName,Color.New(182/255,52/255,40/255,255/255))
		GUI.SetIsShadow(NormalTypeName,true)
		GUI.SetShadow_Distance(NormalTypeName,Vector2.New(0,-1))
		GUI.SetShadow_Color(NormalTypeName,UIDefine.BlackColor)
		
		local txt1 = GUI.CreateStatic(NormalType_Bg, "txt1","购买后即可解锁<color=red>天宫密藏</color>\n+\n可<color=red>立即获得</color>下列礼物",0, -143, 270, 165, "system", true);
		GUI.StaticSetFontSize(txt1, 22)
		GUI.SetColor(txt1, UIDefine.BrownColor)
		GUI.StaticSetAlignment(txt1, TextAnchor.MiddleCenter)

		--local NormalTypeRewardShow = GUI.ImageCreate(NormalType_Bg, "NormalTypeRewardShow", "1800300040", -145,40, false, 400, 90)
		local NormalTypeRewardGive = GUI.ImageCreate(NormalType_Bg, "NormalTypeRewardGive", "1800001060", 0,50, false, 300, 200)
		
		--购买后立即赠送
		local NormalTypeRewardGiveLoopScroll = GUI.LoopScrollRectCreate(NormalTypeRewardGive, "NormalTypeRewardGiveLoopScroll", 0,0,270,180, "SeasonPassUI", "CreateNormalTypeRewardGiveLoopScroll", "SeasonPassUI", "RefreshNormalTypeRewardGiveLoopScroll", 10, false, Vector2.New(80, 80), 3, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
		_gt.BindName(NormalTypeRewardGiveLoopScroll, "NormalTypeRewardGiveLoopScroll")
		--GUI.SetIsRaycastTarget(NormalTypeRewardGiveLoopScroll, false)
		GUI.LoopScrollRectSetTotalCount(NormalTypeRewardGiveLoopScroll, SeasonPassUI.NormalItem.GiveCount)
		GUI.ScrollRectSetChildSpacing(NormalTypeRewardGiveLoopScroll,Vector2.New(15,15))
		
		local NormalBuyBtn = GUI.ButtonCreate(NormalType_Bg, "NormalBuyBtn", "1801601110", 0,210,Transition.ColorTint, "", 240,50, false)
		GUI.RegisterUIEvent(NormalBuyBtn, UCE.PointerClick, "SeasonPassUI", "NormalBuyBtnClick");
		
		local NormalTypeValue = GUI.CreateStatic(NormalBuyBtn, "NormalTypeValue", SeasonPassUI.PriceConfig[1].Amount.."元", 0, 0, 240, 50, "106")
		GUI.StaticSetFontSize(NormalTypeValue, 40)
		GUI.StaticSetAlignment(NormalTypeValue, TextAnchor.MiddleCenter)
		GUI.StaticSetIsGradientColor(NormalTypeValue,true)
		GUI.StaticSetGradient_ColorTop(NormalTypeValue,Color.New(255/255,244/255,139/255,255/255))
		GUI.SetIsOutLine(NormalTypeValue,true)
		GUI.SetOutLine_Distance(NormalTypeValue,3)
		GUI.SetOutLine_Color(NormalTypeValue,Color.New(182/255,52/255,40/255,255/255))
		GUI.SetIsShadow(NormalTypeValue,true)
		GUI.SetShadow_Distance(NormalTypeValue,Vector2.New(0,-1))
		GUI.SetShadow_Color(NormalTypeValue,UIDefine.BlackColor)
		
		local LuxuriousType_Bg = GUI.ImageCreate(PurchaesPage, "LuxuriousType_Bg", "1800601220", 344,0, false, 334, 532)
		GUI.SetData(LuxuriousType_Bg, "Type", "LuxuriousType")
		_gt.BindName(LuxuriousType_Bg, "LuxuriousType_Bg")
		GUI.SetIsRaycastTarget(LuxuriousType_Bg, true)
		LuxuriousType_Bg:RegisterEvent(UCE.PointerClick)
		GUI.RegisterUIEvent(LuxuriousType_Bg, UCE.PointerClick, "SeasonPassUI", "LuxuriousBuyBtnClick");
		local LuxuriousTypeName = GUI.CreateStatic(LuxuriousType_Bg, "LuxuriousTypeName", "高级版", 0, -225, 240, 50,"105");
		GUI.StaticSetFontSize(LuxuriousTypeName, 40)
		GUI.StaticSetAlignment(LuxuriousTypeName, TextAnchor.MiddleCenter)
		GUI.StaticSetIsGradientColor(LuxuriousTypeName,true)
		GUI.StaticSetGradient_ColorTop(LuxuriousTypeName,Color.New(255/255,244/255,139/255,255/255))
		GUI.SetIsOutLine(LuxuriousTypeName,true)
		GUI.SetOutLine_Distance(LuxuriousTypeName,3)
		GUI.SetOutLine_Color(LuxuriousTypeName,Color.New(182/255,52/255,40/255,255/255))
		GUI.SetIsShadow(LuxuriousTypeName,true)
		GUI.SetShadow_Distance(LuxuriousTypeName,Vector2.New(0,-1))
		GUI.SetShadow_Color(LuxuriousTypeName,UIDefine.BlackColor)
		
		local txt1 = GUI.CreateStatic(LuxuriousType_Bg, "txt1","购买后即可解锁<color=red>天宫密藏</color>\n+\n大量<color=red>密藏经验</color>\n+\n可<color=red>立即获得</color>下列礼物",0, -130, 300, 165, "system", true);
		GUI.StaticSetFontSize(txt1, 22)
		GUI.SetColor(txt1, UIDefine.BrownColor)
		GUI.StaticSetAlignment(txt1, TextAnchor.MiddleCenter)
		--local LuxuriousShowHintBtn = GUI.ButtonCreate(LuxuriousType_Bg, "LuxuriousShowHintBtn", "1800702030", 105, -225, Transition.ColorTint, "", 32, 32, false)
		--GUI.SetData(LuxuriousShowHintBtn, "Type", "LuxuriousType")
		--GUI.RegisterUIEvent(LuxuriousShowHintBtn, UCE.PointerClick, "SeasonPassUI", "ShowHintBtnClick");
		
		--额外大奖展示
		local LuxuriousTypeRewardGive = GUI.ImageCreate(LuxuriousType_Bg, "LuxuriousTypeRewardGive", "1800001060", 0,50, false, 300, 200)
		
		local LuxuriousTypeRewardGiveLoopScroll = GUI.LoopScrollRectCreate(LuxuriousTypeRewardGive, "LuxuriousTypeRewardGiveLoopScroll", 0,0,270,180, "SeasonPassUI", "CreateLuxuriousTypeRewardGiveLoopScroll", "SeasonPassUI", "RefreshLuxuriousTypeRewardGiveLoopScroll", 10, false, Vector2.New(80, 80), 3, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
		_gt.BindName(LuxuriousTypeRewardGiveLoopScroll, "LuxuriousTypeRewardGiveLoopScroll")
		GUI.LoopScrollRectSetTotalCount(LuxuriousTypeRewardGiveLoopScroll, SeasonPassUI.LuxuriousItem.GiveCount)
		GUI.ScrollRectSetChildSpacing(LuxuriousTypeRewardGiveLoopScroll,Vector2.New(15,15))
		
		local LuxuriousBuyBtn = GUI.ButtonCreate(LuxuriousType_Bg, "LuxuriousBuyBtn", "1801601100", 0,210,Transition.ColorTint, "", 240,50, false)
		GUI.RegisterUIEvent(LuxuriousBuyBtn, UCE.PointerClick, "SeasonPassUI", "LuxuriousBuyBtnClick");
		
		local LuxuriousTypeValue = GUI.CreateStatic(LuxuriousBuyBtn, "LuxuriousTypeValue", SeasonPassUI.PriceConfig[2].Amount.."元", 0, 0, 240, 50, "106")
		GUI.StaticSetFontSize(LuxuriousTypeValue, 40)
		GUI.StaticSetAlignment(LuxuriousTypeValue, TextAnchor.MiddleCenter)
		GUI.StaticSetIsGradientColor(LuxuriousTypeValue,true)
		GUI.StaticSetGradient_ColorTop(LuxuriousTypeValue,Color.New(255/255,244/255,139/255,255/255))
		GUI.SetIsOutLine(LuxuriousTypeValue,true)
		GUI.SetOutLine_Distance(LuxuriousTypeValue,3)
		GUI.SetOutLine_Color(LuxuriousTypeValue,Color.New(182/255,52/255,40/255,255/255))
		GUI.SetIsShadow(LuxuriousTypeValue,true)
		GUI.SetShadow_Distance(LuxuriousTypeValue,Vector2.New(0,-1))
		GUI.SetShadow_Color(LuxuriousTypeValue,UIDefine.BlackColor)
		
		--测试
		local ShowHintBtn = GUI.ButtonCreate(PurchaesPage, "ShowHintBtn", "1800702030", 125, -225, Transition.ColorTint, "", 32, 32, false)
		GUI.RegisterUIEvent(ShowHintBtn, UCE.PointerClick, "SeasonPassUI", "ShowHintBtnClick");
		
		local iconBg = GUI.ImageCreate(PurchaesPage, "iconBg", "1800601180", 0, -95, false, 200, 200)
		UILayout.SetSameAnchorAndPivot(iconBg, UILayout.Center)
		local LuxuriousTypeIcon = GUI.ButtonCreate(iconBg, "LuxuriousTypeIcon", "1900090020", 0, 0, Transition.ColorTint, "", 76, 76, false)
		GUI.RegisterUIEvent(LuxuriousTypeIcon, UCE.PointerClick, "SeasonPassUI", "RewardShowClick");
		GUI.SetData(LuxuriousTypeIcon, "Type", "LuxuriousType")
		UILayout.SetAnchorAndPivot(LuxuriousTypeIcon, UIAnchor.Center, UIAroundPivot.Center)
		local effect = GUI.SpriteFrameCreate(LuxuriousTypeIcon, "effect", "", 0, 0)
		GUI.SetFrameId(effect, "3403700000")	--"3403500000"方框特效
		UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
		GUI.SpriteFrameSetIsLoop(effect, true)
		GUI.Play(effect)
		
		--看板娘图片
		GUI.ImageCreate(PurchaesPage, "aaaa", "1800608770", 0,125, false, 340, 310)
		
		local zxc = GUI.ImageCreate(iconBg, "zxc", "1800400250", 0,0, false, 320, 320)
		UILayout.SetAnchorAndPivot(zxc, UIAnchor.Center, UIAroundPivot.Center)
		
		local itemshow = GUI.CreateStatic(PurchaesPage, "itemshow", "<color=red>天宫密藏</color>奖励预览", 0, -225, 300, 40,"system", true)
		GUI.StaticSetAlignment(itemshow, TextAnchor.MiddleCenter)
		GUI.SetColor(itemshow, UIDefine.BrownColor)
		UILayout.SetAnchorAndPivot(itemshow, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(itemshow, UIDefine.FontSizeL)
		local NormalTypeRewardShow_Cover = GUI.ImageCreate(PurchaesPage, "NormalTypeRewardShow_Cover","1800001060", 0, 0, false, 2000, 2000)
		_gt.BindName(NormalTypeRewardShow_Cover, "NormalTypeRewardShow_Cover")
		GUI.SetIsRaycastTarget(NormalTypeRewardShow_Cover, true)
		NormalTypeRewardShow_Cover:RegisterEvent(UCE.PointerClick)
		GUI.RegisterUIEvent(NormalTypeRewardShow_Cover, UCE.PointerClick, "SeasonPassUI", "RewardShowExit")
		GUI.SetVisible(NormalTypeRewardShow_Cover, false)
		local NormalTypeRewardShow_Bg = GUI.ImageCreate(NormalTypeRewardShow_Cover, "NormalTypeRewardShow_Bg","1800001060", 0, 0, false, 200, 200)
		_gt.BindName(NormalTypeRewardShow_Bg, "NormalTypeRewardShow_Bg")
		
		local center = GUI.ImageCreate(NormalTypeRewardShow_Bg, "center", "1800600182", 0, 30, false, 502, 320)
		GUI.SetIsRaycastTarget(center, true)
		--UILayout.SetAnchorAndPivot(center, UIAnchor.Bottom, UIAroundPivot.Bottom)
	
		local topBar = GUI.ImageCreate(NormalTypeRewardShow_Bg, "topBar", "1800600183", 0, -56, false, 502, 54)
		UILayout.SetAnchorAndPivot(topBar, UIAnchor.Top, UIAroundPivot.Center)
		GUI.SetIsRaycastTarget(topBar, true)
	
		local topBarCenter = GUI.ImageCreate(NormalTypeRewardShow_Bg, "topBarCenter", "1800600190", 0, -56, false, 270, 50)
		UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)
		GUI.SetIsRaycastTarget(topBarCenter, true)
	
		local tipLabel = GUI.CreateStatic(topBarCenter, "tipLabel", "奖励预览", 0, 0, 200, 40)
		GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
		GUI.SetColor(tipLabel, UIDefine.BrownColor)
		UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Center, UIAroundPivot.Center)
		GUI.StaticSetFontSize(tipLabel, UIDefine.FontSizeL)
	
		local closeBtn = GUI.ButtonCreate(NormalTypeRewardShow_Bg, "closeBtn", "1800302120", 150, -80, Transition.ColorTint, "",46,43,false)
		UILayout.SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
		GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "SeasonPassUI", "RewardShowExit")
		
		--部分大奖展示
		local NormalTypeRewardShowLoopScroll_Bg = GUI.ImageCreate(center, "NormalTypeRewardShowLoopScroll_Bg", "1800400200", 0, 0, false, 475, 300)
		GUI.SetIsRaycastTarget(NormalTypeRewardShowLoopScroll_Bg, true)
		
		local NormalTypeRewardShowLoopScroll = GUI.LoopScrollRectCreate(NormalTypeRewardShowLoopScroll_Bg, "NormalTypeRewardShowLoopScroll", 0,0,470,280, "SeasonPassUI", "CreateNormalTypeRewardShowLoopScroll", "SeasonPassUI", "RefreshNormalTypeRewardShowLoopScroll", 10, false, Vector2.New(80, 80), 5, UIAroundPivot.Center, UIAnchor.Center)
		_gt.BindName(NormalTypeRewardShowLoopScroll, "NormalTypeRewardShowLoopScroll")
		GUI.LoopScrollRectSetTotalCount(NormalTypeRewardShowLoopScroll, SeasonPassUI.NormalItem.ShowCount)
		GUI.ScrollRectSetChildSpacing(NormalTypeRewardShowLoopScroll,Vector2.New(15,15))
		
		local txtaaa = GUI.CreateStatic(PurchaesPage, "txtaaa", "请适度娱乐，理性消费", 0, 225, 430, 50, "101")
		GUI.StaticSetFontSize(txtaaa, 30)
		GUI.StaticSetAlignment(txtaaa, TextAnchor.MiddleCenter)
		GUI.StaticSetIsGradientColor(txtaaa,true)
		GUI.StaticSetGradient_ColorTop(txtaaa,Color.New(255/255,244/255,139/255,255/255))
		GUI.SetIsOutLine(txtaaa,true)
		GUI.SetOutLine_Distance(txtaaa,3)
		GUI.SetOutLine_Color(txtaaa,Color.New(182/255,52/255,40/255,255/255))
		GUI.SetIsShadow(txtaaa,true)
		GUI.SetShadow_Distance(txtaaa,Vector2.New(0,-1))
		GUI.SetShadow_Color(txtaaa,UIDefine.BlackColor)
	end
	SeasonPassUI.SubTabIndex = 1
	SeasonPassUI.SwitchPage(4)
end

function SeasonPassUI.CreateitemLoopScroll()
	local itemLoopScroll = _gt.GetUI("itemLoopScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemLoopScroll);
	local index = tostring(tonumber(curCount) + 1)
	--GUI.ScrollRectSetChildSpacing(itemLoopScroll, Vector2.New(15, 7))
	local RewardUnit = GUI.ImageCreate(itemLoopScroll, "RewardUnit"..index, "1800001150", 0,0, false, 115, 290)
	local RewardLevel = GUI.CreateStatic(RewardUnit, "RewardLevel", index.."级", 0, -150, 100, 50)
	GUI.StaticSetFontSize(RewardLevel, 24)
    GUI.SetColor(RewardLevel, UIDefine.BrownColor)
	GUI.StaticSetAlignment(RewardLevel, TextAnchor.MiddleCenter)
	local LowValueReward = ItemIcon.Create(RewardUnit, "LowValueReward", 0, -75)
	GUI.SetData(LowValueReward, "Value", "LowValue")
	GUI.RegisterUIEvent(LowValueReward, UCE.PointerClick, "SeasonPassUI", "ItemiconClickShowTips");
	local effect_Low = GUI.SpriteFrameCreate(LowValueReward, "effect_Low", "", 0, -3)
    GUI.SetFrameId(effect_Low, "3403500000")	--"3403500000"方框特效
	GUI.SetScale(effect_Low, Vector3.New(1.6, 1.6, 1))
    UILayout.SetSameAnchorAndPivot(effect_Low, UILayout.Center)
    GUI.SpriteFrameSetIsLoop(effect_Low, true)
    GUI.Play(effect_Low)
	GUI.SetVisible(effect_Low, false)
	local FinishIcon1 = GUI.ImageCreate(LowValueReward, "FinishIcon", "1801208640", 0,0, false, 60, 48)
	GUI.SetVisible(FinishIcon1, false)
	
	local HighValueReward_1 = ItemIcon.Create(RewardUnit, "HighValueReward_1", 0, 35)
	GUI.SetData(HighValueReward_1, "Value", "HighValue")
	GUI.SetData(HighValueReward_1, "Num", "1")
	GUI.RegisterUIEvent(HighValueReward_1, UCE.PointerClick, "SeasonPassUI", "ItemiconClickShowTips");
	local effect_High1 = GUI.SpriteFrameCreate(HighValueReward_1, "effect_High1", "", 0, -3)
    GUI.SetFrameId(effect_High1, "3403500000")
	GUI.SetScale(effect_High1, Vector3.New(1.6, 1.6, 1))
    UILayout.SetSameAnchorAndPivot(effect_High1, UILayout.Center)
    GUI.SpriteFrameSetIsLoop(effect_High1, true)
    GUI.Play(effect_High1)
	GUI.SetVisible(effect_High1, false)
	local FinishIcon2 = GUI.ImageCreate(HighValueReward_1, "FinishIcon", "1801208640", 0,0, false, 60, 48)
	GUI.SetVisible(FinishIcon2, false)
	
	local HighValueReward_2 = ItemIcon.Create(RewardUnit, "HighValueReward_2", 0, 125)
	GUI.SetData(HighValueReward_2, "Value", "HighValue")
	GUI.SetData(HighValueReward_2, "Num", "2")
	GUI.RegisterUIEvent(HighValueReward_2, UCE.PointerClick, "SeasonPassUI", "ItemiconClickShowTips");
	local effect_High2 = GUI.SpriteFrameCreate(HighValueReward_2, "effect_High2", "", 0, -3)
    GUI.SetFrameId(effect_High2, "3403500000")
	GUI.SetScale(effect_High2, Vector3.New(1.6, 1.6, 1))
    UILayout.SetSameAnchorAndPivot(effect_High2, UILayout.Center)
    GUI.SpriteFrameSetIsLoop(effect_High2, true)
    GUI.Play(effect_High2)
	GUI.SetVisible(effect_High2, false)
	local FinishIcon3 = GUI.ImageCreate(HighValueReward_2, "FinishIcon", "1801208640", 0,0, false, 60, 48)
	GUI.SetVisible(FinishIcon3, false)
	
	GUI.ImageCreate(RewardUnit, "CutLineUp", "1800007041", 0, -130, false, 115, 5)
	GUI.ImageCreate(RewardUnit, "CutLineDown", "1800007041", 0, -20, false, 115, 5)
	
	local CoverAll = GUI.ImageCreate(RewardUnit, "CoverAll", "1800400220", 0,21, false, 115, 300)
	GUI.SetColor(CoverAll, Color.New(102/255, 47/255, 22/255, 155/255))
	GUI.SetVisible(CoverAll, false)
	local Cover = GUI.ImageCreate(RewardUnit, "Cover", "1800400220", 0,76, false, 115, 190)
	GUI.SetColor(Cover, Color.New(102/255, 47/255, 22/255, 155/255))
	GUI.SetVisible(Cover, false)
	
	--local LevelFinishIcon = GUI.ImageCreate(RewardUnit, "LevelFinishIcon", "1800608400", 0,-18, false, 62, 62)		--2021.11.4优化图层位置
	--GUI.SetVisible(LevelFinishIcon, false)
	return RewardUnit;
end

function SeasonPassUI.RefreshitemLoopScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	
	local RewardUnit = GUI.GetByGuid(guid)
	
	local TotalItemNum = 3
	local para = 0				--用于记录低价值奖励配置是否为空，如果为空，后续判定就加上对应数量
	
	local LowValueReward = GUI.GetChild(RewardUnit, "LowValueReward", false)
	local LowValueKeyName = SeasonPassUI.RewardItem[index].LowValue[1]
	local LowValueNum = SeasonPassUI.RewardItem[index].LowValue[2]
	if LowValueKeyName and LowValueNum then
		GUI.SetVisible(LowValueReward, true)
		local Bind = SeasonPassUI.RewardItem[index].LowValue[3] or 1
		if LowValueKeyName ~= "密藏代币" then			--写死的, 不能改, 这个字符串需要与服务器SeasonPassConfig里对应配置匹配
			ItemIcon.SetEmpty(LowValueReward)
			ItemIcon.BindItemKeyNameWithBind(LowValueReward, LowValueKeyName, Bind)
			GUI.ItemCtrlSetElementValue(LowValueReward, eItemIconElement.RightBottomNum, LowValueNum);
		else
			ItemIcon.SetEmpty(LowValueReward)
			GUI.ItemCtrlSetElementValue(LowValueReward, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(LowValueReward, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(LowValueReward, eItemIconElement.Icon, 0, -1,60,60)
			GUI.ItemCtrlSetElementValue(LowValueReward, eItemIconElement.RightBottomNum, LowValueNum);
			--if Bind == 1 then
			--	GUI.ItemCtrlSetElementValue(LowValueReward, eItemIconElement.LeftTopSp, 1800707120);
			--	GUI.ItemCtrlSetElementRect(LowValueReward, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
			--else
			--	GUI.ItemCtrlSetElementValue(LowValueReward, eItemIconElement.LeftTopSp, nil);
			--end
		end
	else
		GUI.SetVisible(LowValueReward, false)
		TotalItemNum = TotalItemNum - 1
		para = para + 1
	end
	
	local HighValueReward_1 = GUI.GetChild(RewardUnit, "HighValueReward_1", false)
	local HighValueReward_2 = GUI.GetChild(RewardUnit, "HighValueReward_2", false)
	local HighValue = SeasonPassUI.RewardItem[index].HighValue
	if HighValue[1][1] and HighValue[1][2] then
		local Bind = HighValue[1][3] or 1
		if HighValue[1][1] ~= "密藏代币" then
			ItemIcon.SetEmpty(HighValueReward_1)
			ItemIcon.BindItemKeyNameWithBind(HighValueReward_1, HighValue[1][1], Bind)
			GUI.ItemCtrlSetElementValue(HighValueReward_1, eItemIconElement.RightBottomNum, HighValue[1][2]);
		else
			ItemIcon.SetEmpty(HighValueReward_1)
			GUI.ItemCtrlSetElementValue(HighValueReward_1, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(HighValueReward_1, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(HighValueReward_1, eItemIconElement.Icon, 0, -1,60,60)
			GUI.ItemCtrlSetElementValue(HighValueReward_1, eItemIconElement.RightBottomNum, HighValue[1][2]);
		end
	end
	if #HighValue == 1 then
		GUI.SetVisible(HighValueReward_2, false)
		TotalItemNum = TotalItemNum - 1
	elseif #HighValue == 2 then
		if HighValue[2][1] and HighValue[2][2] then
			GUI.SetVisible(HighValueReward_2, true)
			local Bind = HighValue[2][3] or 1
			if HighValue[2][1] ~= "密藏代币" then
				ItemIcon.SetEmpty(HighValueReward_2)
				ItemIcon.BindItemKeyNameWithBind(HighValueReward_2, HighValue[2][1], Bind)
				GUI.ItemCtrlSetElementValue(HighValueReward_2, eItemIconElement.RightBottomNum, HighValue[2][2]);
			else
				ItemIcon.SetEmpty(HighValueReward_2)
				GUI.ItemCtrlSetElementValue(HighValueReward_2, eItemIconElement.Border, UIDefine.ItemIconBg[6])
				GUI.ItemCtrlSetElementValue(HighValueReward_2, eItemIconElement.Icon, 1900013860)
				GUI.ItemCtrlSetElementRect(HighValueReward_2, eItemIconElement.Icon, 0, -1,60,60)
				GUI.ItemCtrlSetElementValue(HighValueReward_2, eItemIconElement.RightBottomNum, HighValue[2][2]);
			end
		end
	end
	
	local FinishIcon1 = GUI.GetChild(LowValueReward, "FinishIcon", false)
	local effect_Low = GUI.GetChild(LowValueReward, "effect_Low", false)
	local FinishIcon2 = GUI.GetChild(HighValueReward_1, "FinishIcon", false)
	local effect_High1 = GUI.GetChild(HighValueReward_1, "effect_High1", false)
	local FinishIcon3 = GUI.GetChild(HighValueReward_2, "FinishIcon", false)
	local effect_High2 = GUI.GetChild(HighValueReward_2, "effect_High2", false)
	GUI.SetVisible(FinishIcon1, false)
	GUI.SetVisible(FinishIcon2, false)
	GUI.SetVisible(FinishIcon3, false)
	GUI.ItemCtrlSetIconGray(LowValueReward, false)
	GUI.ItemCtrlSetIconGray(HighValueReward_1, false)
	GUI.ItemCtrlSetIconGray(HighValueReward_2, false)
	GUI.SetVisible(effect_Low, true)
	GUI.SetVisible(effect_High1, true)
	GUI.SetVisible(effect_High2, true)
	
	if SeasonPassUI.ReceivedItem[tostring(index)] and next(SeasonPassUI.ReceivedItem[tostring(index)]) then
		for i = 1, #SeasonPassUI.ReceivedItem[tostring(index)] do
			if SeasonPassUI.ReceivedItem[tostring(index)][i] == 1 then
				GUI.SetVisible(FinishIcon1, true)
				GUI.ItemCtrlSetIconGray(LowValueReward, true)
				GUI.SetVisible(effect_Low, false)
			elseif SeasonPassUI.ReceivedItem[tostring(index)][i] == 2 then
				GUI.SetVisible(FinishIcon2, true)
				GUI.ItemCtrlSetIconGray(HighValueReward_1, true)
				GUI.SetVisible(effect_High1, false)
			elseif SeasonPassUI.ReceivedItem[tostring(index)][i] == 3 then
				GUI.SetVisible(FinishIcon3, true)
				GUI.ItemCtrlSetIconGray(HighValueReward_2, true)
				GUI.SetVisible(effect_High2, false)
			end
		end
	end
	
	--local LevelFinishIcon = GUI.GetChild(RewardUnit, "LevelFinishIcon", false)
	local CoverAll = GUI.GetChild(RewardUnit, "CoverAll", false)
	local Cover = GUI.GetChild(RewardUnit, "Cover", false)
	if index <= SeasonPassUI.PlayerInfo.Level then
		GUI.SetVisible(CoverAll, false)
		if SeasonPassUI.PlayerInfo.Bought == "true" then 
			GUI.SetVisible(Cover, false)
			if SeasonPassUI.ReceivedItem[tostring(index)] then
				if #SeasonPassUI.ReceivedItem[tostring(index)] < TotalItemNum then
					--GUI.SetVisible(LevelFinishIcon, true)
				else
					--GUI.SetVisible(LevelFinishIcon, false)
					GUI.SetVisible(effect_Low, false)
					GUI.SetVisible(effect_High1, false)
					GUI.SetVisible(effect_High2, false)
				end
			else
				--GUI.SetVisible(LevelFinishIcon, true)
			end
		else
			GUI.SetVisible(effect_High1, false)
			GUI.SetVisible(effect_High2, false)
			GUI.SetVisible(Cover, true)
			if SeasonPassUI.ReceivedItem[tostring(index)] then
				--GUI.SetVisible(LevelFinishIcon, false)
			else
				if para == 1 then
					--GUI.SetVisible(LevelFinishIcon, false)
					GUI.SetVisible(effect_Low, false)
				else
					--GUI.SetVisible(LevelFinishIcon, true)
					--GUI.SetVisible(effect_Low, true)
				end
			end
		end
	else
		--GUI.SetVisible(LevelFinishIcon, false)
		GUI.SetVisible(effect_Low, false)
		GUI.SetVisible(effect_High1, false)
		GUI.SetVisible(effect_High2, false)
		GUI.SetVisible(CoverAll, true)
		GUI.SetVisible(Cover, false)
	end

	if (index % SeasonPassUI.GoodRewardLevel) == 0 then
		GUI.ImageSetImageID(RewardUnit, "1800001151")
	else
		GUI.ImageSetImageID(RewardUnit, "1800001150")
	end
	local RewardLevel = GUI.GetChild(RewardUnit, "RewardLevel", false)
	GUI.StaticSetText(RewardLevel, index.."级")
end

function SeasonPassUI.CreateQuestScroll()
	local QuestScroll = _gt.GetUI("QuestScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(QuestScroll);
	local index = tostring(tonumber(curCount) + 1)
	local QuestUnit = GUI.ImageCreate(QuestScroll, "QuestUnit"..index, "1800001150", 0,0, false, 115, 290)
	local FinishBtn = GUI.ButtonCreate(QuestUnit, "FinishBtn", "1800002031", 330,15,Transition.ColorTint, "完成", 75,35, false)
	GUI.ButtonSetTextFontSize(FinishBtn, 21)
	GUI.ButtonSetTextColor(FinishBtn, UIDefine.BrownColor)
	GUI.ButtonSetShowDisable(FinishBtn, false)
	GUI.RegisterUIEvent(FinishBtn, UCE.PointerClick, "SeasonPassUI", "OnQuestFinishBtnClick");
	local FinishIcon = GUI.ImageCreate(QuestUnit, "FinishIcon", "1800604310", 330,0, false, 84,35)
	GUI.SetVisible(FinishIcon, false)
	local QuestName = GUI.CreateStatic(QuestUnit, "QuestName", "目标", -290, 0, 160, 50)
	GUI.StaticSetFontSize(QuestName, 24)
    GUI.SetColor(QuestName, UIDefine.BrownColor)
	GUI.StaticSetAlignment(QuestName, TextAnchor.MiddleLeft)
	local QuestContent = GUI.CreateStatic(QuestUnit, "QuestContent", "目标内容", -5, 0, 390, 90)
	GUI.StaticSetFontSize(QuestContent, 22)
    GUI.SetColor(QuestContent, UIDefine.BrownColor)
	GUI.StaticSetAlignment(QuestContent, TextAnchor.MiddleLeft)
	local QuestProgress = GUI.CreateStatic(QuestUnit, "QuestProgress", "999/1000万", 330, -20, 150, 50)
	GUI.StaticSetFontSize(QuestProgress, 22)
    GUI.SetColor(QuestProgress, UIDefine.BrownColor)
	GUI.StaticSetAlignment(QuestProgress, TextAnchor.MiddleCenter)
	local QuestExpIcon = GUI.ImageCreate(QuestUnit, "QuestExpIcon", "1900090010", 235, 0, false, 76, 76)
	local QuestExpNum = GUI.CreateStatic(QuestExpIcon, "QuestExpNum", "25", 0, 0, 50, 50)
	GUI.StaticSetFontSize(QuestExpNum, 20)
    GUI.SetColor(QuestExpNum, UIDefine.BrownColor)
	GUI.StaticSetAlignment(QuestExpNum, TextAnchor.MiddleCenter)
	return QuestUnit
end

function SeasonPassUI.RefreshQuestScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	local QuestUnit = GUI.GetByGuid(guid)
	
	local FinishBtn = GUI.GetChild(QuestUnit, "FinishBtn", false)
	local FinishIcon = GUI.GetChild(QuestUnit, "FinishIcon", false)
	local QuestName = GUI.GetChild(QuestUnit, "QuestName", false)
	local QuestContent = GUI.GetChild(QuestUnit, "QuestContent", false)
	local QuestProgress = GUI.GetChild(QuestUnit, "QuestProgress", false)
	
	local QuestExpNum = GUI.GetChild(QuestUnit, "QuestExpNum")
	if SeasonPassUI.SubTabIndex == 1 then
		local QuestInfo = SeasonPassUI.QuestList["DailyQuest"][index]
		local PersonalQuestInfo = SeasonPassUI.PersonalQuestInfo[tostring(QuestInfo.Id)]
		GUI.StaticSetText(QuestName, QuestInfo.Name)
		GUI.StaticSetText(QuestContent, QuestInfo.Info)
		GUI.StaticSetText(QuestProgress, PersonalQuestInfo.ShowCount.."/"..QuestInfo.ShowCount..QuestInfo.UnitStr)
		GUI.StaticSetText(QuestExpNum, QuestInfo.Exp)
		if PersonalQuestInfo.FinishQuest == "true" then
			GUI.SetVisible(FinishBtn, false)
			GUI.SetVisible(QuestProgress, false)
			GUI.SetVisible(FinishIcon, true)
		else
			GUI.SetVisible(FinishBtn, true)
			GUI.SetVisible(QuestProgress, true)
			GUI.SetVisible(FinishIcon, false)
			if PersonalQuestInfo.Count >= QuestInfo.Count then
				GUI.ButtonSetShowDisable(FinishBtn, true)
			else
				GUI.ButtonSetShowDisable(FinishBtn, false)
			end
		end
	elseif SeasonPassUI.SubTabIndex == 2 then
		local QuestInfo = SeasonPassUI.QuestList["WeeklyQuest"][index]
		local PersonalQuestInfo = SeasonPassUI.PersonalQuestInfo[tostring(QuestInfo.Id)]
		GUI.StaticSetText(QuestName, QuestInfo.Name)
		GUI.StaticSetText(QuestContent, QuestInfo.Info)
		GUI.StaticSetText(QuestProgress, PersonalQuestInfo.ShowCount.."/"..QuestInfo.ShowCount..QuestInfo.UnitStr)
		GUI.StaticSetText(QuestExpNum, QuestInfo.Exp)
		if PersonalQuestInfo.FinishQuest == "true" then
			GUI.SetVisible(FinishBtn, false)
			GUI.SetVisible(QuestProgress, false)
			GUI.SetVisible(FinishIcon, true)
		else
			GUI.SetVisible(FinishBtn, true)
			GUI.SetVisible(QuestProgress, true)
			GUI.SetVisible(FinishIcon, false)
			if PersonalQuestInfo.Count >= QuestInfo.Count then
				GUI.ButtonSetShowDisable(FinishBtn, true)
			else
				GUI.ButtonSetShowDisable(FinishBtn, false)
			end
		end
	elseif SeasonPassUI.SubTabIndex == 3 then
		local QuestInfo = SeasonPassUI.QuestList["OnceQuest"][index]
		local PersonalQuestInfo = SeasonPassUI.PersonalQuestInfo[tostring(QuestInfo.Id)]
		GUI.StaticSetText(QuestName, QuestInfo.Name)
		GUI.StaticSetText(QuestContent, QuestInfo.Info)
		GUI.StaticSetText(QuestProgress, PersonalQuestInfo.ShowCount.."/"..QuestInfo.ShowCount..QuestInfo.UnitStr)
		GUI.StaticSetText(QuestExpNum, QuestInfo.Exp)
		if PersonalQuestInfo.FinishQuest == "true" then
			GUI.SetVisible(FinishBtn, false)
			GUI.SetVisible(QuestProgress, false)
			GUI.SetVisible(FinishIcon, true)
		else
			GUI.SetVisible(FinishBtn, true)
			GUI.SetVisible(QuestProgress, true)
			GUI.SetVisible(FinishIcon, false)
			if PersonalQuestInfo.Count >= QuestInfo.Count then
				GUI.ButtonSetShowDisable(FinishBtn, true)
			else
				GUI.ButtonSetShowDisable(FinishBtn, false)
			end
		end
	end
end

function SeasonPassUI.OnQuestFinishBtnClick(guid)
	local Btn = GUI.GetByGuid(guid)
	local QuestUnit = GUI.GetParentElement(Btn)
	local Index = tonumber(GUI.ImageGetIndex(QuestUnit)) + 1
	local QuestList = {}
	if SeasonPassUI.SubTabIndex == 1 then
		QuestList = SeasonPassUI.QuestList.DailyQuest
	elseif SeasonPassUI.SubTabIndex == 2 then
		QuestList = SeasonPassUI.QuestList.WeeklyQuest
	elseif SeasonPassUI.SubTabIndex == 3 then
		QuestList = SeasonPassUI.QuestList.OnceQuest
	end
	if next(QuestList) and QuestList[Index] then
		CL.SendNotify(NOTIFY.SubmitForm, "FormSeasonPass", "FinishQuest", QuestList[Index].Id)
	end
end

function SeasonPassUI.CreateExchangeScroll()
	local ExchangeScroll = _gt.GetUI("ExchangeScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(ExchangeScroll);
	local index = tostring(tonumber(curCount) + 1)
	local ExchangeUnit = GUI.CheckBoxExCreate(ExchangeScroll, "ExchangeUnit"..index, "1800001150", "1800001151", 0,0, false, 115, 290)
	GUI.RegisterUIEvent(ExchangeUnit, UCE.PointerClick, "SeasonPassUI", "ExchangeUnitClick");
	local ExchangeItem = ItemIcon.Create(ExchangeUnit, "ExchangeItem", -110, 0)
	GUI.RegisterUIEvent(ExchangeItem, UCE.PointerClick, "SeasonPassUI", "ExchangeItemClick");
	local LimitIcon = GUI.ImageCreate(ExchangeUnit, "LimitIcon", "1801207090", 147,-34, false, 35, 43)
	local ExchangeItemName = GUI.CreateStatic(ExchangeUnit, "ExchangeItemName", "物品名字", 40, -25, 180, 50)
	GUI.StaticSetFontSize(ExchangeItemName, 21)
    GUI.SetColor(ExchangeItemName, UIDefine.BrownColor)
	GUI.StaticSetAlignment(ExchangeItemName, TextAnchor.MiddleLeft)
	local ExchangeItemCost_Bg = GUI.ImageCreate(ExchangeUnit, "ExchangeItemCost_Bg", "1800700010", 45,20, false, 190, 35)
	local TokenIcon = GUI.ImageCreate(ExchangeItemCost_Bg, "TokenIcon", "1900013860", -76,-1, false, 33, 33)
	local TokenNum = GUI.CreateStatic(ExchangeItemCost_Bg, "TokenNum", "999", 10, 0, 160, 50)
	GUI.StaticSetFontSize(TokenNum, 21)
    GUI.SetColor(TokenNum, UIDefine.WhiteColor)
	GUI.StaticSetAlignment(TokenNum, TextAnchor.MiddleCenter)
	local Soldout = GUI.ImageCreate(ExchangeUnit, "Soldout", "1800404070", 45,17, false, 80, 54)
	GUI.SetVisible(Soldout, false)
	return ExchangeUnit
end

function SeasonPassUI.RefreshExchangeScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	local ExchangeUnit = GUI.GetByGuid(guid)
	if ExchangeShopItemIndex == index then
		GUI.CheckBoxExSetCheck(ExchangeUnit, true)
	else
		GUI.CheckBoxExSetCheck(ExchangeUnit, false)
	end
	
	local ExchangeItem = GUI.GetChild(ExchangeUnit, "ExchangeItem", false)
	local ExchangeItemName = GUI.GetChild(ExchangeUnit, "ExchangeItemName", false)
	local ExchangeItemCost_Bg = GUI.GetChild(ExchangeUnit, "ExchangeItemCost_Bg", false)
	local Soldout = GUI.GetChild(ExchangeUnit, "Soldout", false)
	local LimitIcon = GUI.GetChild(ExchangeUnit, "LimitIcon", false)
	local TokenNum = GUI.GetChild(ExchangeItemCost_Bg, "TokenNum", false)
	local KeyName = SeasonPassUI.ExchangeShopRoughInfo[index].Name
	local Name = SeasonPassUI.ExchangeShopInfo[KeyName].Name
	GUI.StaticSetText(ExchangeItemName, Name)
	local Num = SeasonPassUI.ExchangeShopRoughInfo[index].MaxBuy - SeasonPassUI.PersonalExchangeInfo[index]
	local Bind = SeasonPassUI.ExchangeShopRoughInfo[index].Bind
	ItemIcon.BindItemKeyNameWithBind(ExchangeItem, KeyName, Bind)
	if SeasonPassUI.ExchangeShopRoughInfo[index].MaxBuy > 0 then
		GUI.ItemCtrlSetElementValue(ExchangeItem, eItemIconElement.RightBottomNum, Num);
	else
		GUI.ItemCtrlSetElementValue(ExchangeItem, eItemIconElement.RightBottomNum, 1);
	end
	if SeasonPassUI.ExchangeShopRoughInfo[index].MaxBuy ~= 0 then
		GUI.SetVisible(LimitIcon, true)
		if Num == 0 then
			GUI.ItemCtrlSetIconGray(ExchangeItem, true)
			GUI.SetVisible(ExchangeItemCost_Bg, false)
			GUI.SetVisible(Soldout, true)
		else
			GUI.ItemCtrlSetIconGray(ExchangeItem, false)
			GUI.SetVisible(ExchangeItemCost_Bg, true)
			GUI.SetVisible(Soldout, false)
		end
	else
		GUI.ItemCtrlSetIconGray(ExchangeItem, false)
		GUI.SetVisible(ExchangeItemCost_Bg, true)
		GUI.SetVisible(Soldout, false)
		GUI.SetVisible(LimitIcon, false)
	end
	GUI.StaticSetText(TokenNum, SeasonPassUI.ExchangeShopRoughInfo[index].TokenCost)
end

--function SeasonPassUI.OnReward_itemiconClick(guid)
--	--还需添加判定，能领就领，不能领再显示物品tips
--	SeasonPassUI.ItemiconClickShowTips(guid)
--end

function SeasonPassUI.ItemiconClickShowTips(guid)
	local Btn = GUI.GetByGuid(guid)
	local RewardUnit = GUI.GetParentElement(Btn)
	local Index = tonumber(GUI.ImageGetIndex(RewardUnit)) + 1
	local Value = GUI.GetData(Btn, "Value")
	local KeyName = ""
	local para2 = 0
	if Value == "LowValue" then
		KeyName = SeasonPassUI.RewardItem[Index].LowValue[1]
		para2 = 1
	elseif Value == "HighValue" then
		local Num = tonumber(GUI.GetData(Btn, "Num"))
		KeyName = SeasonPassUI.RewardItem[Index].HighValue[Num][1]
		if Num == 1 then
			para2 = 2
		elseif Num == 2 then
			para2 = 3
		end
	end
	local panelBg = _gt.GetUI("panelBg")
	if KeyName == "密藏代币" then				--写死的不能改, 因为这个代币不在道具表里, 且周师傅说不想让玩家在获取代币的时候弹出快速使用弹窗
		local Itemicon_hint = _gt.GetUI("Itemicon_hint")
		if not Itemicon_hint then
			local Itemicon_hint = GUI.ItemTipsCreate(panelBg, "RewardPageTokenTip", -430, 0, 0)
			GUI.SetIsRemoveWhenClick(Itemicon_hint, true)
			local itemIcon = GUI.TipsGetItemIcon(Itemicon_hint)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60)
			Tips.SetBaseInfo(Itemicon_hint, TokenDB)
			Tips.AddInfoAndTips(Itemicon_hint, TokenDB)
			Tips.DeleteItemShowLevel(Itemicon_hint)
			_gt.BindName(Itemicon_hint, "Itemicon_hint")
		else
			GUI.Destroy(Itemicon_hint);
		end
	elseif KeyName == "密藏经验" then
		local TypeIcon_hint = _gt.GetUI("TypeIcon_hint")
		if not TypeIcon_hint then
			local TypeIcon_hint = GUI.ItemTipsCreate(panelBg, "PurchaesPageShowItemTip", 0, 0, 0)
			GUI.SetIsRemoveWhenClick(TypeIcon_hint, true)
			local itemIcon = GUI.TipsGetItemIcon(TypeIcon_hint)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[7])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, ExpDB.Icon)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,70,70)
			Tips.SetBaseInfo(TypeIcon_hint, ExpDB)
			Tips.AddInfoAndTips(TypeIcon_hint, ExpDB)
			Tips.DeleteItemShowLevel(TypeIcon_hint)
			_gt.BindName(TypeIcon_hint, "TypeIcon_hint")
		else
			GUI.Destroy(TypeIcon_hint);
		end
	else
		Tips.CreateByItemKeyName(KeyName, panelBg, "SeasonPassRewardTip", -430, 0, 0)
	end
	if Index <= SeasonPassUI.PlayerInfo.Level then
		local TOF = true
		if SeasonPassUI.ReceivedItem[tostring(Index)] and next(SeasonPassUI.ReceivedItem[tostring(Index)]) then
			for i = 1, #SeasonPassUI.ReceivedItem[tostring(Index)] do
				if SeasonPassUI.ReceivedItem[tostring(Index)][i] == para2 then
					TOF = false
				end
			end
		end
		if SeasonPassUI.PlayerInfo.Bought == "false" then
			if para2 == 2 or para2 == 3 then
				TOF = false
			end
		end
		if TOF then
			SeasonPassUI.GetSingleItem(Index, para2)
		end
	end
end

function SeasonPassUI.OnNextGoodRewardClick(guid)
	local Btn = GUI.GetByGuid(guid)
	local Value = GUI.GetData(Btn, "Value")
	local KeyName = ""
	if Value == "LowValue" then
		KeyName = SeasonPassUI.RewardItem[NextGoodRewardLevel].LowValue[1]
	elseif Value == "HighValue1" then
		KeyName = SeasonPassUI.RewardItem[NextGoodRewardLevel].HighValue[1][1]
	elseif Value == "HighValue2" then
		KeyName = SeasonPassUI.RewardItem[NextGoodRewardLevel].HighValue[2][1]
	end
	local panelBg = _gt.GetUI("panelBg")
	if KeyName == "密藏代币" then				--写死的不能改, 因为这个代币不在道具表里, 且周师傅说不想让玩家在获取代币的时候弹出快速使用弹窗
		local NextGoodReward_hint = _gt.GetUI("NextGoodReward_hint")
		if not NextGoodReward_hint then
			local NextGoodReward_hint = GUI.ItemTipsCreate(panelBg, "NextGoodRewardTip", 0, 0, 0)
			GUI.SetIsRemoveWhenClick(NextGoodReward_hint, true)
			local itemIcon = GUI.TipsGetItemIcon(NextGoodReward_hint)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60)
			Tips.SetBaseInfo(NextGoodReward_hint, TokenDB)
			Tips.AddInfoAndTips(NextGoodReward_hint, TokenDB)
			Tips.DeleteItemShowLevel(NextGoodReward_hint)
			_gt.BindName(NextGoodReward_hint, "NextGoodReward_hint")
		else
			GUI.Destroy(NextGoodReward_hint);
		end
	elseif KeyName == "密藏经验" then
		local TypeIcon_hint = _gt.GetUI("TypeIcon_hint")
		if not TypeIcon_hint then
			local TypeIcon_hint = GUI.ItemTipsCreate(panelBg, "PurchaesPageShowItemTip", 0, 0, 0)
			GUI.SetIsRemoveWhenClick(TypeIcon_hint, true)
			local itemIcon = GUI.TipsGetItemIcon(TypeIcon_hint)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[7])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, ExpDB.Icon)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,70,70)
			Tips.SetBaseInfo(TypeIcon_hint, ExpDB)
			Tips.AddInfoAndTips(TypeIcon_hint, ExpDB)
			Tips.DeleteItemShowLevel(TypeIcon_hint)
			_gt.BindName(TypeIcon_hint, "TypeIcon_hint")
		else
			GUI.Destroy(TypeIcon_hint);
		end
	else
		Tips.CreateByItemKeyName(KeyName, panelBg, "SeasonPassRewardTip", 0, 0, 0)
	end
end

function SeasonPassUI.UnLockSeasonPassBtnClick()
	SeasonPassUI.OnPurchaesTabBtnClick()
end

function SeasonPassUI.GetAllRewardBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm, "FormSeasonPass", "GetAllItem", SeasonPassUI.PlayerInfo.Level)
end

function SeasonPassUI.NextGoodRewardBtnClick(guid)
	local btn = GUI.GetByGuid(guid);
	local panelBg = _gt.GetUI("panelBg")
	local hint = _gt.GetUI("hint")
	if not hint then
		local hint = GUI.ImageCreate(panelBg, "hint", "1800400290", 426, -194, false, 170, 60)
		local msg = "下一阶段大奖";
		local text = GUI.CreateStatic(hint, "text", msg, 0, 0, 170, 60);
		GUI.StaticSetFontSize(text, 22);
		GUI.SetIsRemoveWhenClick(hint, true)
		GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
		_gt.BindName(hint, "hint")
		GUI.AddWhiteName(hint, GUI.GetGuid(btn));
	else
		GUI.Destroy(hint);
	end
end

function SeasonPassUI.DailyQuestBtnClick()
	local QuestScroll = _gt.GetUI("QuestScroll")
	SeasonPassUI.SubTabIndex = 1
	local Num = #SeasonPassUI.QuestList["DailyQuest"]
	local EmptyHint = _gt.GetUI("EmptyHint")
	if Num > 0 then
		GUI.SetVisible(EmptyHint, false)
	else
		GUI.SetVisible(EmptyHint, true)
	end
	GUI.LoopScrollRectSetTotalCount(QuestScroll, Num)
	GUI.LoopScrollRectRefreshCells(QuestScroll)

	SeasonPassUI.QuestBtnClick()
end

function SeasonPassUI.WeeklyQuestBtnClick()
	local QuestScroll = _gt.GetUI("QuestScroll")
	SeasonPassUI.SubTabIndex = 2
	local Num = #SeasonPassUI.QuestList["WeeklyQuest"]
	local EmptyHint = _gt.GetUI("EmptyHint")
	if Num > 0 then
		GUI.SetVisible(EmptyHint, false)
	else
		GUI.SetVisible(EmptyHint, true)
	end
	GUI.LoopScrollRectSetTotalCount(QuestScroll, Num)
	GUI.LoopScrollRectRefreshCells(QuestScroll)

	SeasonPassUI.QuestBtnClick()
end

function SeasonPassUI.OnceQuestBtnClick()
	local QuestScroll = _gt.GetUI("QuestScroll")
	SeasonPassUI.SubTabIndex = 3
	local Num = #SeasonPassUI.QuestList["OnceQuest"]
	local EmptyHint = _gt.GetUI("EmptyHint")
	if Num > 0 then
		GUI.SetVisible(EmptyHint, false)
	else
		GUI.SetVisible(EmptyHint, true)
	end
	GUI.LoopScrollRectSetTotalCount(QuestScroll, Num)
	GUI.LoopScrollRectRefreshCells(QuestScroll)

	SeasonPassUI.QuestBtnClick()
end

function SeasonPassUI.QuestBtnClick()
	local DailyQuestBtn = _gt.GetUI("DailyQuestBtn")
	local WeeklyQuestBtn = _gt.GetUI("WeeklyQuestBtn")
	local OnceQuestBtn = _gt.GetUI("OnceQuestBtn")
	
	if SeasonPassUI.SubTabIndex == 1 then
		GUI.ButtonSetImageID(DailyQuestBtn, "1800002031")
		GUI.ButtonSetImageID(WeeklyQuestBtn, "1800002030")
		GUI.ButtonSetImageID(OnceQuestBtn, "1800002030")
	elseif SeasonPassUI.SubTabIndex == 2 then
		GUI.ButtonSetImageID(DailyQuestBtn, "1800002030")
		GUI.ButtonSetImageID(WeeklyQuestBtn, "1800002031")
		GUI.ButtonSetImageID(OnceQuestBtn, "1800002030")
	elseif SeasonPassUI.SubTabIndex == 3 then
		GUI.ButtonSetImageID(DailyQuestBtn, "1800002030")
		GUI.ButtonSetImageID(WeeklyQuestBtn, "1800002030")
		GUI.ButtonSetImageID(OnceQuestBtn, "1800002031")
	end
end

function SeasonPassUI.SwitchPage(pageNum)
	if not pageNum or type(pageNum) ~= "number" then --or SeasonPassUI.TabIndex == pageNum 
		return
	end
	SeasonPassUI.TabIndex = pageNum
	for i = 1, #tabList do
		local Page = _gt.GetUI(tabList[i][4])
		if i ~= pageNum then
			GUI.SetVisible(Page, false)
		end
	end
	local Page = _gt.GetUI(tabList[pageNum][4])
	if Page then
		GUI.SetVisible(Page, true)
	else
		assert(loadstring("SeasonPassUI."..tabList[pageNum][3].."()"))()
		return
	end
	UILayout.OnTabClick(pageNum, tabList)
	--SeasonPassUI.Refresh()
	assert(loadstring("SeasonPassUI."..tabList[SeasonPassUI.TabIndex][5].."()"))()
	SeasonPassUI.RedPointRefresh()
end

function SeasonPassUI.SeasonPassClick(guid)
	local btn = GUI.GetByGuid(guid)
	local Type = GUI.GetData(btn, "Type")
	local NormalType_Bg = _gt.GetUI("NormalType_Bg")
	local LuxuriousType_Bg = _gt.GetUI("LuxuriousType_Bg")
	GUI.ButtonSetImageID(NormalType_Bg, "1800001150")
	GUI.ButtonSetImageID(LuxuriousType_Bg, "1800001150")
	if not SeasonPassUI.SeasonPassChosen then
		GUI.ButtonSetImageID(btn, "1800001151")
	else
		if SeasonPassUI.SeasonPassChosenString == Type then
			GUI.ButtonSetImageID(btn, "1800001150")
			Type = "nil"
		else
			GUI.ButtonSetImageID(btn, "1800001151")
		end
	end
	
	if Type == "LuxuriousType" then
		CL.SendNotify(NOTIFY.ShowBBMsg, "高级版")
		local Right_Arrow = _gt.GetUI("Right_Arrow")
		GUI.SetVisible(Right_Arrow, true)
		local Left_Arrow = _gt.GetUI("Left_Arrow")
		GUI.SetVisible(Left_Arrow, false)
	elseif Type == "NormalType" then
		CL.SendNotify(NOTIFY.ShowBBMsg, "普通版")
		local Left_Arrow = _gt.GetUI("Left_Arrow")
		GUI.SetVisible(Left_Arrow, true)
		local Right_Arrow = _gt.GetUI("Right_Arrow")
		GUI.SetVisible(Right_Arrow, false)
	elseif Type == "nil" then
		CL.SendNotify(NOTIFY.ShowBBMsg, "取消选择")
		local Right_Arrow = _gt.GetUI("Right_Arrow")
		GUI.SetVisible(Right_Arrow, false)
		local Left_Arrow = _gt.GetUI("Left_Arrow")
		GUI.SetVisible(Left_Arrow, false)
	end
	SeasonPassUI.SeasonPassChosenString = Type
	if SeasonPassUI.SeasonPassChosenString ~= "nil" then
		SeasonPassUI.SeasonPassChosen = true
	else
		SeasonPassUI.SeasonPassChosen = false
	end
end

function SeasonPassUI.TypeIconClick(guid)
	local IconBtn = GUI.GetByGuid(guid)
	local Type = GUI.GetData(IconBtn, "Type")
	local x = 0
	if Type == "NormalType" then
		x = -330
	elseif Type == "LuxuriousType" then
		x = 330
	end
	SeasonPassUI.TypeIconClickTips(guid, Type, x)
end

function SeasonPassUI.TypeIconClickTips(guid, Type, x)
	local btn = GUI.GetByGuid(guid);
	local panelBg = _gt.GetUI("panelBg")
	local TypeIcon_hint = _gt.GetUI("TypeIcon_hint")
	if TypeIcon_hint == nil then
		local TypeIcon_hint = GUI.ImageCreate(panelBg, "TypeIcon_hint", "1800400290", x, -35, false, 300, 100)
		local msg = "";
		if Type == "NormalType" then
			msg = "达到对应等级即可获得下列丰厚礼物"
		elseif Type == "LuxuriousType" then
			msg = "解锁高级版密藏可立即获得:\n1.下列额外奖励；\n2.20级密藏等级"
		end
		local text = GUI.CreateStatic(TypeIcon_hint, "text", msg, 0, 0, 280, 100);
		GUI.StaticSetFontSize(text, 20);
		GUI.SetIsRemoveWhenClick(TypeIcon_hint, true)
		GUI.StaticSetAlignment(text, TextAnchor.MiddleLeft)
		_gt.BindName(TypeIcon_hint, "TypeIcon_hint")
		GUI.AddWhiteName(TypeIcon_hint, GUI.GetGuid(btn));
	else
		GUI.Destroy(TypeIcon_hint);
	end
end

--function SeasonPassUI.Refresh()
--	assert(loadstring("SeasonPassUI."..tabList[SeasonPassUI.TabIndex][5].."()"))()
--end

--处理基于服务器发过来的表的数据
function SeasonPassUI.RefreshServerData()
	local inspect = require("inspect")
	--print("SeasonPassUI.RewardItem = "..inspect(SeasonPassUI.RewardItem))
	--print("SeasonPassUI.PlayerInfo = "..inspect(SeasonPassUI.PlayerInfo))
	--print("ReceivedItem = "..inspect(SeasonPassUI.ReceivedItem))
	--print("SeasonPassUI.QuestList = "..inspect(SeasonPassUI.QuestList))
	--print("SeasonPassUI.PersonalQuestInfo = "..inspect(SeasonPassUI.PersonalQuestInfo))
	--print("SeasonPassUI.ExchangeShopRoughInfo = "..inspect(SeasonPassUI.ExchangeShopRoughInfo))
	--print("SeasonPassUI.PersonalExchangeInfo = "..inspect(SeasonPassUI.PersonalExchangeInfo))
	--print("SeasonPassUI.NormalItem = "..inspect(SeasonPassUI.NormalItem))
	--print("SeasonPassUI.LuxuriousItem = "..inspect(SeasonPassUI.LuxuriousItem))
	if FirstRefreshServerData == "true" then
		for i = 1, SeasonPassUI.MaxLevel do
			if not SeasonPassUI.BuyExpInterfaceRoughTB[i] then
				SeasonPassUI.BuyExpInterfaceRoughTB[i] = {LowValue = {}, HighValue = {}, Bind = {},}
			end
			if SeasonPassUI.RewardItem[i] then
				local LowValueTB = SeasonPassUI.RewardItem[i].LowValue
				local HighValueTB = SeasonPassUI.RewardItem[i].HighValue
				if LowValueTB and next(LowValueTB) then
					if not SeasonPassUI.BuyExpInterfaceRoughTB[i].LowValue[tostring(LowValueTB[1])] then
						SeasonPassUI.BuyExpInterfaceRoughTB[i].LowValue[tostring(LowValueTB[1])] = LowValueTB[2]
					else
						SeasonPassUI.BuyExpInterfaceRoughTB[i].LowValue[tostring(LowValueTB[1])] = SeasonPassUI.BuyExpInterfaceRoughTB[i].LowValue[tostring(LowValueTB[1])] + LowValueTB[2]
					end
					if not SeasonPassUI.BuyExpInterfaceRoughTB[i].Bind[tostring(LowValueTB[1])] then
						SeasonPassUI.BuyExpInterfaceRoughTB[i].Bind[tostring(LowValueTB[1])] = LowValueTB[3] or 1
					end
				end
				if HighValueTB and next(HighValueTB) then
					for j = 1, #HighValueTB do
						if not SeasonPassUI.BuyExpInterfaceRoughTB[i].HighValue[tostring(HighValueTB[j][1])] then
							SeasonPassUI.BuyExpInterfaceRoughTB[i].HighValue[tostring(HighValueTB[j][1])] = HighValueTB[j][2]
						else
							SeasonPassUI.BuyExpInterfaceRoughTB[i].HighValue[tostring(HighValueTB[j][1])] = SeasonPassUI.BuyExpInterfaceRoughTB[i].HighValue[tostring(HighValueTB[j][1])] + HighValueTB[j][2]
						end
						if not SeasonPassUI.BuyExpInterfaceRoughTB[i].Bind[tostring(HighValueTB[j][1])] then
							SeasonPassUI.BuyExpInterfaceRoughTB[i].Bind[tostring(HighValueTB[j][1])] = HighValueTB[j][3] or 1
						end
					end
				end
			end
		end
		for i = 1, #SeasonPassUI.ExchangeShopRoughInfo do
			local Name = SeasonPassUI.ExchangeShopRoughInfo[i].Name
			SeasonPassUI.ExchangeShopInfo[Name] = DB.GetOnceItemByKey2(Name)
		end
		for k,v in pairs(SeasonPassUI.NormalItem.GiveItem) do
			if not SeasonPassUI.PurchaesPageItem[k] then
				SeasonPassUI.PurchaesPageItem[k] = DB.GetOnceItemByKey2(k)
			end
		end
		for k,v in pairs(SeasonPassUI.LuxuriousItem.GiveItem) do
			if not SeasonPassUI.PurchaesPageItem[k] then
				SeasonPassUI.PurchaesPageItem[k] = DB.GetOnceItemByKey2(k)
			end
		end
		FirstRefreshServerData = "false"
	end
	for k, v in pairs(SeasonPassUI.QuestList) do
		table.sort(v,function (a,b)
			return a.Id < b.Id
		end)
	end
	--print("SeasonPassUI.BuyExpInterfaceRoughTB = "..inspect(SeasonPassUI.BuyExpInterfaceRoughTB))
	--print("SeasonPassUI.ExchangeShopInfo = "..inspect(SeasonPassUI.ExchangeShopInfo))
	--print("SeasonPassUI.QuestList = "..inspect(SeasonPassUI.QuestList))
end

function SeasonPassUI.ExpInfoRefresh(Hide)
	local ExpLevelTxt_Bg = _gt.GetUI("ExpLevelTxt_Bg")
	local ExpBar_Bg = _gt.GetUI("ExpBar_Bg")
	local SeasonPassTime_Bg = _gt.GetUI("SeasonPassTime_Bg")
	if Hide then		--用于控制密藏经验栏是否隐藏
		GUI.SetVisible(ExpLevelTxt_Bg, false)
		GUI.SetVisible(ExpBar_Bg, false)
		GUI.SetVisible(SeasonPassTime_Bg, false)
	else
		GUI.SetVisible(ExpLevelTxt_Bg, true)
		GUI.SetVisible(ExpBar_Bg, true)
		GUI.SetVisible(SeasonPassTime_Bg, true)
	end
	local levelnum = _gt.GetUI("levelnum")
	GUI.StaticSetText(levelnum, SeasonPassUI.PlayerInfo.Level)
	local ExpNum = _gt.GetUI("ExpNum")
	GUI.StaticSetText(ExpNum, SeasonPassUI.PlayerInfo.Exp.."/"..SeasonPassUI.LevelUpExp)
	local ExpBar = _gt.GetUI("ExpBar")
	local BarSetPos = SeasonPassUI.PlayerInfo.Exp / SeasonPassUI.LevelUpExp
	GUI.ScrollBarSetPos(ExpBar, BarSetPos)
end

function SeasonPassUI.RewardPageRefresh(Single)
	SeasonPassUI.ExpInfoRefresh()
	
	local UnLockSeasonPassBtn = _gt.GetUI("UnLockSeasonPassBtn")
	if SeasonPassUI.PlayerInfo.Bought == "true" then
		GUI.SetVisible(UnLockSeasonPassBtn, false)
	else
		GUI.SetVisible(UnLockSeasonPassBtn, true)
	end

	local itemLoopScroll = _gt.GetUI("itemLoopScroll")
	GUI.LoopScrollRectRefreshCells(itemLoopScroll)
	if not Single then
		GUI.LoopScrollRectSrollToCell(itemLoopScroll, SeasonPassUI.PlayerInfo.Level - 1, 0)
	end
end

function SeasonPassUI.QuestPageRefresh()
	SeasonPassUI.ExpInfoRefresh()
	if SeasonPassUI.SubTabIndex then
		if SeasonPassUI.SubTabIndex == 2 then
			SeasonPassUI.WeeklyQuestBtnClick()
		elseif SeasonPassUI.SubTabIndex == 3 then
			SeasonPassUI.OnceQuestBtnClick()
		else
			SeasonPassUI.DailyQuestBtnClick()
		end
	else
		SeasonPassUI.DailyQuestBtnClick()
	end
end

function SeasonPassUI.ExchangePageRefresh()
	SeasonPassUI.ExpInfoRefresh()
	ExchangeShopItemIndex = 1
	ExchangeShopItemNum = 1
	SeasonPassUI.ExchangePageItemInfoRefresh()
	SeasonPassUI.ExchangePageTokenInfoRefresh()
end

function SeasonPassUI.PurchaesPageRefresh()
	SeasonPassUI.ExpInfoRefresh(true)
	SeasonPassUI.SeasonPassChosenString = "nil"
end

function SeasonPassUI.GetSingleItem(para1, para2)
	CL.SendNotify(NOTIFY.SubmitForm, "FormSeasonPass", "GetSingleItem", para1, para2)
end

--接收服务器数据并更新本地表格(节省消耗)
function SeasonPassUI.UpdateReceivedItem(para1,para2)
	if not SeasonPassUI.ReceivedItem[tostring(para1)] then
		SeasonPassUI.ReceivedItem[tostring(para1)] = {}
	end
	table.insert(SeasonPassUI.ReceivedItem[tostring(para1)], tonumber(para2))
	--SeasonPassUI.RefreshServerData()
	SeasonPassUI.RewardPageRefresh(true)	--目前只有第一页走这个流程
end

function SeasonPassUI.CreateItemPreviewScroll()
	local ItemPreview = _gt.GetUI("ItemPreview")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(ItemPreview);
	local index = tostring(tonumber(curCount) + 1)
	local item = ItemIcon.Create(ItemPreview, "item", 0, 0)
	GUI.RegisterUIEvent(item, UCE.PointerClick, "SeasonPassUI", "ItemPreviewScrollClick");
	return item
end

function SeasonPassUI.RefreshItemPreviewScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	
	local item = GUI.GetByGuid(guid)
	local ItemName = SeasonPassUI.BuyExpInterfaceTB.NameTB[index]
	local ItemNum = SeasonPassUI.BuyExpInterfaceTB[ItemName]
	if ItemName ~= "密藏代币" then
		local Bind = SeasonPassUI.BuyExpInterfaceTB.Bind[ItemName] or 1
		ItemIcon.BindItemKeyNameWithBind(item, ItemName, Bind)
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, ItemNum);
	else
		ItemIcon.SetEmpty(item)
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[6])
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, 1900013860)
		GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,60,60)
		GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, ItemNum);
	end
end

function SeasonPassUI.ItemPreviewScrollClick(guid)
	local btn = GUI.GetByGuid(guid)
	local Type = GUI.GetData(btn, "Type")
	local Index = tonumber(GUI.ItemCtrlGetIndex(btn)) + 1
	
	local KeyName = SeasonPassUI.BuyExpInterfaceTB.NameTB[Index]
	local panelBg = _gt.GetUI("panelBg")
	if KeyName == "密藏代币" then
		local ItemPreviewScrollTip = _gt.GetUI("ItemPreviewScrollTip")
		if not ItemPreviewScrollTip then
			local ItemPreviewScrollTip = GUI.ItemTipsCreate(panelBg, "ItemPreviewScrollTip", 0, 0, 0)
			GUI.SetIsRemoveWhenClick(ItemPreviewScrollTip, true)
			local itemIcon = GUI.TipsGetItemIcon(ItemPreviewScrollTip)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60)
			Tips.SetBaseInfo(ItemPreviewScrollTip, TokenDB)
			Tips.AddInfoAndTips(ItemPreviewScrollTip, TokenDB)
			Tips.DeleteItemShowLevel(ItemPreviewScrollTip)
			_gt.BindName(ItemPreviewScrollTip, "ItemPreviewScrollTip")
		else
			GUI.Destroy(ItemPreviewScrollTip);
		end
	elseif KeyName == "密藏经验" then
		local TypeIcon_hint = _gt.GetUI("TypeIcon_hint")
		if not TypeIcon_hint then
			local TypeIcon_hint = GUI.ItemTipsCreate(panelBg, "PurchaesPageShowItemTip", 0, 0, 0)
			GUI.SetIsRemoveWhenClick(TypeIcon_hint, true)
			local itemIcon = GUI.TipsGetItemIcon(TypeIcon_hint)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[7])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, ExpDB.Icon)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,70,70)
			Tips.SetBaseInfo(TypeIcon_hint, ExpDB)
			Tips.AddInfoAndTips(TypeIcon_hint, ExpDB)
			Tips.DeleteItemShowLevel(TypeIcon_hint)
			_gt.BindName(TypeIcon_hint, "TypeIcon_hint")
		else
			GUI.Destroy(TypeIcon_hint);
		end
	else
		Tips.CreateByItemKeyName(KeyName, panelBg, "ItemPreviewScrollTip", 0, 0, 0)
	end
end

function SeasonPassUI.AddExpBtnClick()
	if SeasonPassUI.PlayerInfo.Level >= SeasonPassUI.MaxLevel then
		CL.SendNotify(NOTIFY.ShowBBMsg, "密藏等级已达上限，无需购买经验")
		return
	end
	local BuyExpInterface_Bg = _gt.GetUI("BuyExpInterface_Bg")
	GUI.SetVisible(BuyExpInterface_Bg, true)
	SeasonPassUI.BuyExpLevelNum = 1
	SeasonPassUI.BuyExpInterfaceRefresh()
end

--快速购买等级页面-点击减少
function SeasonPassUI.BuyExpInterfaceMinusBtn()
	SeasonPassUI.BuyExpLevelNum = SeasonPassUI.BuyExpLevelNum > 1 and SeasonPassUI.BuyExpLevelNum - 1 or 1
	SeasonPassUI.BuyExpInterfaceRefresh()
end

--快速购买等级页面-点击增加
function SeasonPassUI.BuyExpInterfacePlusBtn()
	local a = SeasonPassUI.MaxLevel - SeasonPassUI.PlayerInfo.Level
	SeasonPassUI.BuyExpLevelNum = SeasonPassUI.BuyExpLevelNum < a and SeasonPassUI.BuyExpLevelNum + 1 or a
	SeasonPassUI.BuyExpInterfaceRefresh()
end

--快速购买等级页面-自定义购买数量
function SeasonPassUI.BuyExpInterfaceEndEdit()
	local BuyExpcountEdit = _gt.GetUI("BuyExpcountEdit")
	local str = GUI.EditGetTextM(BuyExpcountEdit)
    SeasonPassUI.BuyExpLevelNum = tonumber(str) or 1
	local a = SeasonPassUI.MaxLevel - SeasonPassUI.PlayerInfo.Level
	if SeasonPassUI.BuyExpLevelNum >= a then
		SeasonPassUI.BuyExpLevelNum = a
	elseif SeasonPassUI.BuyExpLevelNum < 1 then
		SeasonPassUI.BuyExpLevelNum = 1
	end
	SeasonPassUI.BuyExpInterfaceRefresh()
end

--快速购买等级页面-刷新
function SeasonPassUI.BuyExpInterfaceRefresh()
	local CurLevel = _gt.GetUI("CurLevel")
	local TargetLevel = _gt.GetUI("TargetLevel")
	local BuyExpcountEdit = _gt.GetUI("BuyExpcountEdit")
	local TotalCostNum = _gt.GetUI("TotalCostNum")
	GUI.EditSetTextM(BuyExpcountEdit, SeasonPassUI.BuyExpLevelNum)
	GUI.StaticSetText(CurLevel, SeasonPassUI.PlayerInfo.Level)
	GUI.StaticSetText(TargetLevel, SeasonPassUI.PlayerInfo.Level + SeasonPassUI.BuyExpLevelNum)
	GUI.StaticSetText(TotalCostNum, SeasonPassUI.BuyLevelCost * SeasonPassUI.BuyExpLevelNum)
	
	SeasonPassUI.GetBuyExpInterfaceTB()
	local ItemPreview = _gt.GetUI("ItemPreview")
	GUI.LoopScrollRectSetTotalCount(ItemPreview, SeasonPassUI.BuyExpInterfaceTB.Count)
	GUI.LoopScrollRectRefreshCells(ItemPreview)
end

function SeasonPassUI.GetBuyExpInterfaceTB()
	SeasonPassUI.BuyExpInterfaceTB = {NameTB = {}, Bind = {}, Count = 0,}
	local inspect = require("inspect")
	--print("SeasonPassUI.TB = "..inspect(TB))
	if SeasonPassUI.PlayerInfo.Bought == "true" then
		for i = SeasonPassUI.PlayerInfo.Level + 1, SeasonPassUI.PlayerInfo.Level + SeasonPassUI.BuyExpLevelNum do
			if SeasonPassUI.BuyExpInterfaceRoughTB[i] then
				for k, v in pairs(SeasonPassUI.BuyExpInterfaceRoughTB[i]) do
					if k ~= "Bind" then
						for m,n in pairs(v) do
							if not SeasonPassUI.BuyExpInterfaceTB[m] then
								SeasonPassUI.BuyExpInterfaceTB[m] = n
								SeasonPassUI.BuyExpInterfaceTB.Count = SeasonPassUI.BuyExpInterfaceTB.Count + 1
								table.insert(SeasonPassUI.BuyExpInterfaceTB.NameTB, m)
							else
								SeasonPassUI.BuyExpInterfaceTB[m] = SeasonPassUI.BuyExpInterfaceTB[m] + n
							end
							if not SeasonPassUI.BuyExpInterfaceTB.Bind[m]then
								SeasonPassUI.BuyExpInterfaceTB.Bind[m] = SeasonPassUI.BuyExpInterfaceRoughTB[i].Bind[m] or 1
							end
						end
					end
				end
			end
		end
	else
		for i = SeasonPassUI.PlayerInfo.Level + 1, SeasonPassUI.PlayerInfo.Level + SeasonPassUI.BuyExpLevelNum do
			if SeasonPassUI.BuyExpInterfaceRoughTB[i] and SeasonPassUI.BuyExpInterfaceRoughTB[i].LowValue then
				for k, v in pairs(SeasonPassUI.BuyExpInterfaceRoughTB[i].LowValue) do
					if not SeasonPassUI.BuyExpInterfaceTB[k] then
						SeasonPassUI.BuyExpInterfaceTB[k] = v
						SeasonPassUI.BuyExpInterfaceTB.Count = SeasonPassUI.BuyExpInterfaceTB.Count + 1
						table.insert(SeasonPassUI.BuyExpInterfaceTB.NameTB, k)
					else
						SeasonPassUI.BuyExpInterfaceTB[k] = SeasonPassUI.BuyExpInterfaceTB[k] + v
					end
					if not SeasonPassUI.BuyExpInterfaceTB.Bind[k] then
						SeasonPassUI.BuyExpInterfaceTB.Bind[k] = SeasonPassUI.BuyExpInterfaceRoughTB[i].Bind[k] or 1
					end
				end
			end
		end
	end
	--print("SeasonPassUI.BuyExpInterfaceRoughTB = "..inspect(SeasonPassUI.BuyExpInterfaceRoughTB))
	--print("SeasonPassUI.BuyExpInterfaceTB = "..inspect(SeasonPassUI.BuyExpInterfaceTB))
end

function SeasonPassUI.BuyLevelBtnClick()
	SeasonPassUI.BuyExpLevelNum = tonumber(SeasonPassUI.BuyExpLevelNum)
	if not SeasonPassUI.BuyExpLevelNum then
		return
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormSeasonPass", "BuyLevel", SeasonPassUI.BuyExpLevelNum)
	--SeasonPassUI.BuyExpInterfaceCloseClick()
end

function SeasonPassUI.BuyExpInterfaceCloseClick()
	local BuyExpInterface_Bg = _gt.GetUI("BuyExpInterface_Bg")
	GUI.SetVisible(BuyExpInterface_Bg, false)
end

--兑换页面右侧道具信息刷新
function SeasonPassUI.ExchangePageItemInfoRefresh()
	local ExchangeItemInfoName = _gt.GetUI("ExchangeItemInfoName")
	local ExchangeItemInfoTypeName = _gt.GetUI("ExchangeItemInfoTypeName")
	local ExchangeItemInfoLevelNum = _gt.GetUI("ExchangeItemInfoLevelNum")
	local ExchangeItemInfoEffect = _gt.GetUI("ExchangeItemInfoEffect")
	local descScroll = _gt.GetUI("descScroll")
	local Name = SeasonPassUI.ExchangeShopRoughInfo[ExchangeShopItemIndex].Name
	local ItemInfo = SeasonPassUI.ExchangeShopInfo[Name]
	GUI.StaticSetText(ExchangeItemInfoName, ItemInfo.Name)
	GUI.StaticSetText(ExchangeItemInfoTypeName, ItemInfo.ShowType)
	GUI.StaticSetText(ExchangeItemInfoLevelNum, ItemInfo.Level.."级")
	GUI.ScrollRectSetNormalizedPosition(descScroll, UIDefine.Vector2One)
	GUI.StaticSetText(ExchangeItemInfoEffect, "使用效果: "..ItemInfo.Tips)
	local ExchangeScroll = _gt.GetUI("ExchangeScroll")
	GUI.LoopScrollRectRefreshCells(ExchangeScroll)
end

--兑换页面右侧Token信息刷新
function SeasonPassUI.ExchangePageTokenInfoRefresh()
	local ExchangeTokenSpendNum = _gt.GetUI("ExchangeTokenSpendNum")
	local ExchangeTokenOwnNum = _gt.GetUI("ExchangeTokenOwnNum")
	local CountEdit = _gt.GetUI("CountEdit")
	local a = SeasonPassUI.ExchangeShopRoughInfo[ExchangeShopItemIndex].MaxBuy - SeasonPassUI.PersonalExchangeInfo[ExchangeShopItemIndex]
	if SeasonPassUI.ExchangeShopRoughInfo[ExchangeShopItemIndex].MaxBuy > 0 then
		if a > 0 then
			if ExchangeShopItemNum >= a then
				ExchangeShopItemNum = a
			elseif ExchangeShopItemNum < 1 then
				ExchangeShopItemNum = 1
			end
		else
			ExchangeShopItemNum = 0
		end
	elseif SeasonPassUI.ExchangeShopRoughInfo[ExchangeShopItemIndex].MaxBuy == 0 then
		if ExchangeShopItemNum >= 99 then
			ExchangeShopItemNum = 99
		elseif ExchangeShopItemNum < 1 then
			ExchangeShopItemNum = 1
		end
	end
	GUI.EditSetTextM(CountEdit, ExchangeShopItemNum)
	local Val = ExchangeShopItemNum * SeasonPassUI.ExchangeShopRoughInfo[ExchangeShopItemIndex].TokenCost
	GUI.StaticSetText(ExchangeTokenSpendNum, Val)
	if Val > SeasonPassUI.PlayerInfo.TokenOwn then
		GUI.SetColor(ExchangeTokenSpendNum, UIDefine.RedColor)
	else
		GUI.SetColor(ExchangeTokenSpendNum, UIDefine.WhiteColor)
	end
	GUI.StaticSetText(ExchangeTokenOwnNum, SeasonPassUI.PlayerInfo.TokenOwn)
end

function SeasonPassUI.ExchangeMinusBtnClick()
	ExchangeShopItemNum = ExchangeShopItemNum - 1
	SeasonPassUI.ExchangePageTokenInfoRefresh()
end

function SeasonPassUI.ExchangePlusBtnClick()
	ExchangeShopItemNum = ExchangeShopItemNum + 1
	SeasonPassUI.ExchangePageTokenInfoRefresh()
end

function SeasonPassUI.OnNumCountChange()
	local CountEdit = _gt.GetUI("CountEdit")
	local Num = tonumber(GUI.EditGetTextM(CountEdit))
	if Num then
		ExchangeShopItemNum = Num
		SeasonPassUI.ExchangePageTokenInfoRefresh()
	end
end

function SeasonPassUI.ExchangeUnitClick(guid)
	local Unit = GUI.GetByGuid(guid)
	local Index = tonumber(GUI.CheckBoxExGetIndex(Unit)) + 1
	ExchangeShopItemIndex = Index
	ExchangeShopItemNum = 1
	SeasonPassUI.ExchangePageItemInfoRefresh()
	SeasonPassUI.ExchangePageTokenInfoRefresh()
end

function SeasonPassUI.ExchangeItemClick(guid)
	local ItemCtrl = GUI.GetByGuid(guid)
	local Unit = GUI.GetParentElement(ItemCtrl)
	local Index = tonumber(GUI.CheckBoxExGetIndex(Unit)) + 1
	ExchangeShopItemIndex = Index
	ExchangeShopItemNum = 1
	SeasonPassUI.ExchangePageItemInfoRefresh()
	SeasonPassUI.ExchangePageTokenInfoRefresh()
end

function SeasonPassUI.ExchangeBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm, "FormSeasonPass", "ExchangeItem", ExchangeShopItemIndex, ExchangeShopItemNum)
end

function SeasonPassUI.CreateNormalTypeRewardShowLoopScroll()
	local NormalTypeRewardShowLoopScroll = _gt.GetUI("NormalTypeRewardShowLoopScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(NormalTypeRewardShowLoopScroll);
	local index = tostring(tonumber(curCount) + 1)
	local item = ItemIcon.Create(NormalTypeRewardShowLoopScroll, "item", 0, 0)
	GUI.SetData(item, "Type", "Normal")
	GUI.RegisterUIEvent(item, UCE.PointerClick, "SeasonPassUI", "PurchaesPageShowItemClick");
	local CenterNum = GUI.CreateStatic(item, "CenterNum", "999", 0, -5, 160, 50)
	GUI.StaticSetFontSize(CenterNum, 20);
	GUI.StaticSetAlignment(CenterNum, TextAnchor.MiddleCenter)
	GUI.SetIsOutLine(CenterNum, true)
	GUI.SetOutLine_Color(CenterNum, UIDefine.OutLine_BlackColor)
	GUI.SetOutLine_Distance(CenterNum, UIDefine.OutLineDistance)
	GUI.SetVisible(CenterNum, false)
	return item
end

function SeasonPassUI.RefreshNormalTypeRewardShowLoopScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	
	local item = GUI.GetByGuid(guid)
	local ItemName = SeasonPassUI.NormalItem.ShowName[index]
	local ItemNum = SeasonPassUI.NormalItem.ShowItem[SeasonPassUI.NormalItem.ShowName[index]]
	local CenterNum = GUI.GetChild(item, "CenterNum", false)
	GUI.SetVisible(CenterNum, false)
	if ItemName and ItemNum then
		ItemIcon.SetEmpty(item)
		if ItemName == "密藏代币" then
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,60,60)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, ItemNum);
		elseif ItemName == "密藏经验" then
			GUI.SetVisible(CenterNum, true)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[7])
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, 1900090010)
			GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,70,70)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, 1);
			GUI.StaticSetText(CenterNum, ItemNum)
		else
			local Bind = SeasonPassUI.LuxuriousItem.ShowBind[ItemName] or 1
			ItemIcon.BindItemKeyNameWithBind(item, ItemName, Bind)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, ItemNum);
		end
	else
		ItemIcon.SetEmpty(item)
	end
end

function SeasonPassUI.CreateNormalTypeRewardGiveLoopScroll()
	local NormalTypeRewardGiveLoopScroll = _gt.GetUI("NormalTypeRewardGiveLoopScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(NormalTypeRewardGiveLoopScroll);
	local index = tostring(tonumber(curCount) + 1)
	--local item_Bg = GUI.ImageCreate(NormalTypeRewardGiveLoopScroll, "item_Bg", "1801400010", 0, 0, false, 300, 100)	--"1801400010", "1800001060"
	--local item_Name = GUI.CreateStatic(item_Bg, "item_Name", "道具", 50, 0, 180, 80)
	--GUI.StaticSetFontSize(item_Name, 24);
	--GUI.StaticSetAlignment(item_Name, TextAnchor.MiddleLeft)
	--GUI.SetIsOutLine(item_Name, true)
	--GUI.SetOutLine_Color(item_Name, UIDefine.OutLine_BlackColor)
	--GUI.SetOutLine_Distance(item_Name, UIDefine.OutLineDistance)
	local item = ItemIcon.Create(NormalTypeRewardGiveLoopScroll, "item", -100, 0)
	GUI.SetData(item, "Type", "Normal")
	GUI.RegisterUIEvent(item, UCE.PointerClick, "SeasonPassUI", "PurchaesPageGiveItemClick");
	local CenterNum = GUI.CreateStatic(item, "CenterNum", "999", 0, -5, 160, 50)
	GUI.StaticSetFontSize(CenterNum, 20);
	GUI.StaticSetAlignment(CenterNum, TextAnchor.MiddleCenter)
	GUI.SetIsOutLine(CenterNum, true)
	GUI.SetOutLine_Color(CenterNum, UIDefine.OutLine_BlackColor)
	GUI.SetOutLine_Distance(CenterNum, UIDefine.OutLineDistance)
	GUI.SetVisible(CenterNum, false)
	return item
end

function SeasonPassUI.RefreshNormalTypeRewardGiveLoopScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	
	--local item_Bg = GUI.GetByGuid(guid)
	--local item_Name = GUI.GetChild(item_Bg, "item_Name")
	local item = GUI.GetByGuid(guid)
	local ItemName = SeasonPassUI.NormalItem.GiveName[index]
	local ItemNum = SeasonPassUI.NormalItem.GiveItem[SeasonPassUI.NormalItem.GiveName[index]]
	local CenterNum = GUI.GetChild(item, "CenterNum", false)
	GUI.SetVisible(CenterNum, false)
	if ItemName and ItemNum then
		ItemIcon.SetEmpty(item)
		if ItemName == "密藏代币" then
			--GUI.StaticSetText(item_Name, "密藏代币")
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,60,60)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, ItemNum);
		elseif ItemName == "密藏经验" then
			--GUI.StaticSetText(item_Name, "密藏经验")
			GUI.SetVisible(CenterNum, true)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[7])
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, 1900090010)
			GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,70,70)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, 1);
			GUI.StaticSetText(CenterNum, ItemNum)
		else
			--GUI.StaticSetText(item_Name, tostring(SeasonPassUI.PurchaesPageItem[ItemName].Name))
			local Bind = SeasonPassUI.LuxuriousItem.ShowBind[ItemName] or 1
			ItemIcon.BindItemKeyNameWithBind(item, ItemName, Bind)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, ItemNum);
		end
	else
		--GUI.StaticSetText(item_Name, "")
		ItemIcon.SetEmpty(item)
	end
end

function SeasonPassUI.CreateLuxuriousTypeRewardGiveLoopScroll()
	local LuxuriousTypeRewardGiveLoopScroll = _gt.GetUI("LuxuriousTypeRewardGiveLoopScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(LuxuriousTypeRewardGiveLoopScroll);
	local index = tostring(tonumber(curCount) + 1)
	--local item_Bg = GUI.ImageCreate(LuxuriousTypeRewardGiveLoopScroll, "item_Bg", "1801400010", 0, 0, false, 300, 100)	--"1801400010", "1800001060"
	--local item_Name = GUI.CreateStatic(item_Bg, "item_Name", "道具", 50, 0, 180, 80)
	--GUI.StaticSetFontSize(item_Name, 24);
	--GUI.StaticSetAlignment(item_Name, TextAnchor.MiddleLeft)
	--GUI.SetIsOutLine(item_Name, true)
	--GUI.SetOutLine_Color(item_Name, UIDefine.OutLine_BlackColor)
	--GUI.SetOutLine_Distance(item_Name, UIDefine.OutLineDistance)
	local item = ItemIcon.Create(LuxuriousTypeRewardGiveLoopScroll, "item", -100, 0)
	GUI.SetData(item, "Type", "Luxurious")
	GUI.RegisterUIEvent(item, UCE.PointerClick, "SeasonPassUI", "PurchaesPageGiveItemClick");
	local CenterNum = GUI.CreateStatic(item, "CenterNum", "999", 0, -5, 160, 50)
	GUI.StaticSetFontSize(CenterNum, 20);
	GUI.StaticSetAlignment(CenterNum, TextAnchor.MiddleCenter)
	GUI.SetIsOutLine(CenterNum, true)
	GUI.SetOutLine_Color(CenterNum, UIDefine.OutLine_BlackColor)
	GUI.SetOutLine_Distance(CenterNum, UIDefine.OutLineDistance)
	GUI.SetVisible(CenterNum, false)
	return item
end

function SeasonPassUI.RefreshLuxuriousTypeRewardGiveLoopScroll(parameter)
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	
	--local item_Bg = GUI.GetByGuid(guid)
	--local item_Name = GUI.GetChild(item_Bg, "item_Name")
	local item = GUI.GetByGuid(guid)
	local ItemName = SeasonPassUI.LuxuriousItem.GiveName[index]
	local ItemNum = SeasonPassUI.LuxuriousItem.GiveItem[SeasonPassUI.LuxuriousItem.GiveName[index]]
	local CenterNum = GUI.GetChild(item, "CenterNum", false)
	GUI.SetVisible(CenterNum, false)
	
	if ItemName and ItemNum then
		ItemIcon.SetEmpty(item)
		if ItemName == "密藏代币" then
			--GUI.StaticSetText(item_Name, "密藏代币")
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,60,60)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, ItemNum);
		elseif ItemName == "密藏经验" then
			--GUI.StaticSetText(item_Name, "密藏经验")
			GUI.SetVisible(CenterNum, true)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[7])
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, 1900090010)
			GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,70,70)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, 1);
			GUI.StaticSetText(CenterNum, UIDefine.ExchangeMoneyToStr(ItemNum))
		else
			--GUI.StaticSetText(item_Name, tostring(SeasonPassUI.PurchaesPageItem[ItemName].Name))
			local Bind = SeasonPassUI.LuxuriousItem.ShowBind[ItemName] or 1
			ItemIcon.BindItemKeyNameWithBind(item, ItemName, Bind)
			GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, ItemNum);
		end
	else
		GUI.StaticSetText(item_Name, "")
		ItemIcon.SetEmpty(item)
	end
end

function SeasonPassUI.PurchaesPageShowItemClick(guid)
	local btn = GUI.GetByGuid(guid)
	local Type = GUI.GetData(btn, "Type")
	local Index = tonumber(GUI.ItemCtrlGetIndex(btn)) + 1
	
	local KeyName = ""
	if Type == "Normal" then
		KeyName = SeasonPassUI.NormalItem.ShowName[Index]
	elseif Type == "Luxurious" then
		KeyName = SeasonPassUI.LuxuriousItem.ShowName[Index]
	end
	local panelBg = _gt.GetUI("panelBg")
	if KeyName == "密藏代币" then
		local TypeIcon_hint = _gt.GetUI("TypeIcon_hint")
		if not TypeIcon_hint then
			local TypeIcon_hint = GUI.ItemTipsCreate(panelBg, "PurchaesPageShowItemTip", 0, 0, 0)
			GUI.SetIsRemoveWhenClick(TypeIcon_hint, true)
			local itemIcon = GUI.TipsGetItemIcon(TypeIcon_hint)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60)
			Tips.SetBaseInfo(TypeIcon_hint, TokenDB)
			Tips.AddInfoAndTips(TypeIcon_hint, TokenDB)
			Tips.DeleteItemShowLevel(TypeIcon_hint)
			_gt.BindName(TypeIcon_hint, "TypeIcon_hint")
		else
			GUI.Destroy(TypeIcon_hint);
		end
	elseif KeyName == "密藏经验" then
		local TypeIcon_hint = _gt.GetUI("TypeIcon_hint")
		if not TypeIcon_hint then
			local TypeIcon_hint = GUI.ItemTipsCreate(panelBg, "PurchaesPageShowItemTip", 0, 0, 0)
			GUI.SetIsRemoveWhenClick(TypeIcon_hint, true)
			local itemIcon = GUI.TipsGetItemIcon(TypeIcon_hint)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[7])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, ExpDB.Icon)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,70,70)
			Tips.SetBaseInfo(TypeIcon_hint, ExpDB)
			Tips.AddInfoAndTips(TypeIcon_hint, ExpDB)
			Tips.DeleteItemShowLevel(TypeIcon_hint)
			_gt.BindName(TypeIcon_hint, "TypeIcon_hint")
		else
			GUI.Destroy(TypeIcon_hint);
		end
	else
		Tips.CreateByItemKeyName(KeyName, panelBg, "PurchaesPageShowItemTip", 0, 0, 0)
	end
end

function SeasonPassUI.PurchaesPageGiveItemClick(guid)
	local btn = GUI.GetByGuid(guid)
	local Type = GUI.GetData(btn, "Type")
	--local parent = GUI.GetParentElement(btn)
	local Index = tonumber(GUI.ItemCtrlGetIndex(btn)) + 1
	
	local KeyName = ""
	if Type == "Normal" then
		KeyName = SeasonPassUI.NormalItem.GiveName[Index]
	elseif Type == "Luxurious" then
		KeyName = SeasonPassUI.LuxuriousItem.GiveName[Index]
	end
	local panelBg = _gt.GetUI("panelBg")
	if KeyName == "密藏代币" then
		local TypeIcon_hint = _gt.GetUI("TypeIcon_hint")
		if not TypeIcon_hint then
			local TypeIcon_hint = GUI.ItemTipsCreate(panelBg, "PurchaesPageShowItemTip", 0, 0, 0)
			GUI.SetIsRemoveWhenClick(TypeIcon_hint, true)
			local itemIcon = GUI.TipsGetItemIcon(TypeIcon_hint)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[6])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, 1900013860)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60)
			Tips.SetBaseInfo(TypeIcon_hint, TokenDB)
			Tips.AddInfoAndTips(TypeIcon_hint, TokenDB)
			Tips.DeleteItemShowLevel(TypeIcon_hint)
			_gt.BindName(TypeIcon_hint, "TypeIcon_hint")
		else
			GUI.Destroy(TypeIcon_hint);
		end
	elseif KeyName == "密藏经验" then
		local TypeIcon_hint = _gt.GetUI("TypeIcon_hint")
		if not TypeIcon_hint then
			local TypeIcon_hint = GUI.ItemTipsCreate(panelBg, "PurchaesPageShowItemTip", 0, 0, 0)
			GUI.SetIsRemoveWhenClick(TypeIcon_hint, true)
			local itemIcon = GUI.TipsGetItemIcon(TypeIcon_hint)
			ItemIcon.SetEmpty(itemIcon)
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[7])
			GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, ExpDB.Icon)
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,70,70)
			Tips.SetBaseInfo(TypeIcon_hint, ExpDB)
			Tips.AddInfoAndTips(TypeIcon_hint, ExpDB)
			Tips.DeleteItemShowLevel(TypeIcon_hint)
			_gt.BindName(TypeIcon_hint, "TypeIcon_hint")
		else
			GUI.Destroy(TypeIcon_hint);
		end
	else
		Tips.CreateByItemKeyName(KeyName, panelBg, "PurchaesPageShowItemTip", 0, 0, 0)
	end
end

function SeasonPassUI.NormalBuyBtnClick()
	if SeasonPassUI.PlayerInfo.Bought == "true" then
		CL.SendNotify(NOTIFY.ShowBBMsg, "您已购买过密藏，无需再次购买普通版密藏")
		return
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType", "SeasonPass", 1, SeasonPassUI.PriceConfig[1].Amount)
end

function SeasonPassUI.LuxuriousBuyBtnClick()
	if SeasonPassUI.PlayerInfo.LuxuriousBought == "true" then
		CL.SendNotify(NOTIFY.ShowBBMsg, "您已购买过高级版密藏，无需再次购买")
		return
	end
	CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType", "SeasonPass", 2, SeasonPassUI.PriceConfig[2].Amount)
end

function SeasonPassUI.ShowHintBtnClick(guid)
	local btn = GUI.GetByGuid(guid);
	local panelBg = _gt.GetUI("panelBg")
	local ShowHint = _gt.GetUI("ShowHint")
	if not ShowHint then
		local ShowHint = GUI.ImageCreate(panelBg, "ShowHint", "1800400290", 0, -120, false, 420, 150)
		local msg = "少侠需通过完成密藏目标获取经验并达到相应密藏等级后才能在奖励页面领取对应奖励；\n或者少侠可以购买密藏等级从而直接解锁对应奖励";
		local text = GUI.CreateStatic(ShowHint, "text", msg, 0, 0, 400, 130);
		GUI.StaticSetFontSize(text, 22);
		GUI.SetIsRemoveWhenClick(ShowHint, true)
		GUI.StaticSetAlignment(text, TextAnchor.MiddleLeft)
		_gt.BindName(ShowHint, "ShowHint")
		GUI.AddWhiteName(ShowHint, GUI.GetGuid(btn));
	else
		GUI.Destroy(ShowHint);
	end
end

function SeasonPassUI.RewardShowClick()
	local NormalTypeRewardShow_Cover = _gt.GetUI("NormalTypeRewardShow_Cover")
	GUI.SetVisible(NormalTypeRewardShow_Cover,true)
end

function SeasonPassUI.RewardShowExit()
	local NormalTypeRewardShow_Cover = _gt.GetUI("NormalTypeRewardShow_Cover")
	GUI.SetVisible(NormalTypeRewardShow_Cover,false)
end

function SeasonPassUI.OnExit()
	local wnd = GUI.GetWnd('SeasonPassUI')
    if wnd then
        GUI.SetVisible(wnd,false)
    end
end

function SeasonPassUI.RedPointRefresh()
	local RewardTabBtn = GUI.Get("SeasonPassUI/panelBg/tabList/RewardTabBtn")
	local QuestTabBtn = GUI.Get("SeasonPassUI/panelBg/tabList/QuestTabBtn")
	local DailyQuestBtn = _gt.GetUI("DailyQuestBtn")
	local WeeklyQuestBtn = _gt.GetUI("WeeklyQuestBtn")
	local OnceQuestBtn = _gt.GetUI("OnceQuestBtn")
	if RewardTabBtn then
		if GlobalProcessing.SeasonPassRedPoint.RewardRemain and next(GlobalProcessing.SeasonPassRedPoint.RewardRemain) then
			GUI.SetRedPointVisable(RewardTabBtn, true)
		else
			GUI.SetRedPointVisable(RewardTabBtn, false)
		end
	end
	if GlobalProcessing.SeasonPassRedPoint.LevelMax == "false" and GlobalProcessing.SeasonPassRedPoint.QuestCanFinish and next(GlobalProcessing.SeasonPassRedPoint.QuestCanFinish) then
		if QuestTabBtn then
			GUI.SetRedPointVisable(QuestTabBtn, true)
		end
		if DailyQuestBtn then
			if GlobalProcessing.SeasonPassRedPoint.QuestCanFinish["DailyQuest"] and GlobalProcessing.SeasonPassRedPoint.QuestCanFinish["DailyQuest"] == "true" then
				GlobalProcessing.SetRetPoint(DailyQuestBtn, true)
			else
				GlobalProcessing.SetRetPoint(DailyQuestBtn, false)
			end
		end
		if WeeklyQuestBtn then
			if GlobalProcessing.SeasonPassRedPoint.QuestCanFinish["WeeklyQuest"] and GlobalProcessing.SeasonPassRedPoint.QuestCanFinish["WeeklyQuest"] == "true" then
				GlobalProcessing.SetRetPoint(WeeklyQuestBtn, true)
			else
				GlobalProcessing.SetRetPoint(WeeklyQuestBtn, false)
			end
		end
		if OnceQuestBtn then
			if GlobalProcessing.SeasonPassRedPoint.QuestCanFinish["OnceQuest"] and GlobalProcessing.SeasonPassRedPoint.QuestCanFinish["OnceQuest"] == "true" then
				GlobalProcessing.SetRetPoint(OnceQuestBtn, true)
			else
				GlobalProcessing.SetRetPoint(OnceQuestBtn, false)
			end
		end
	else
		if QuestTabBtn then
			GUI.SetRedPointVisable(QuestTabBtn, false)
		end
		if DailyQuestBtn then
			GlobalProcessing.SetRetPoint(DailyQuestBtn, false)
		end
		if WeeklyQuestBtn then
			GlobalProcessing.SetRetPoint(WeeklyQuestBtn, false)
		end
		if OnceQuestBtn then
			GlobalProcessing.SetRetPoint(OnceQuestBtn, false)
		end
	end
	--GlobalProcessing.SetRetPoint(obj, bool)
end