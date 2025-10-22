local TrackUI = {
    RightMsgList ={};
    SurvivalChallengeData = {}
}

_G.TrackUI = TrackUI

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local _gt = UILayout.NewGUIDUtilTable()

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------


------------------------------------------Start 颜色配置 Start----------------------------------
local RedColor = UIDefine.RedColor
local BrownColor = UIDefine.BrownColor
local Brown4Color = UIDefine.Brown4Color
local Brown6Color = UIDefine.Brown6Color
local WhiteColor = UIDefine.WhiteColor
local White2Color = UIDefine.White2Color
local White3Color = UIDefine.White3Color
local GrayColor = UIDefine.GrayColor
local Gray2Color = UIDefine.Gray2Color
local Gray3Color = UIDefine.Gray3Color
local OrangeColor = UIDefine.OrangeColor
local GreenColor = UIDefine.GreenColor
local Green2Color = UIDefine.Green2Color
local Green3Color = UIDefine.Green3Color
local Blue3Color = UIDefine.Blue3Color
local Purple2Color = UIDefine.Purple2Color
local YellowColor = UIDefine.YellowColor
local Yellow2Color = UIDefine.Yellow2Color
local Yellow3Color = UIDefine.Yellow3Color
local Yellow4Color = UIDefine.Yellow4Color
local Yellow5Color = UIDefine.Yellow5Color
local PinkColor = UIDefine.PinkColor
local OutLineDistance = UIDefine.OutLineDistance
local OutLine_BrownColor = UIDefine.OutLine_BrownColor
----------------------------------------------End 颜色配置 End--------------------------------

local GangConspiracyTime = 0
local GangConspiracyItemState = 0
local GangConspiracyTxt = ""
local GangConspiracyDetailsTxt = ""

local ScreenWidth = 1280
local ScreenHeight = 720
local JIN_DOU_YUN_ID = 31022
local Colors = { UIDefine.WhiteColor, UIDefine.GreenColor, UIDefine.SkyBlueColor, UIDefine.YellowColor, UIDefine.RedColor, UIDefine.Gray2Color, UIDefine.PurpleColor }
TrackUI.QuestLstMax = 0
TrackUI.MainQuestTarget = nil
TrackUI.QuestOrFightInfoMode = 0 --0任务，1战况，2帮战 ，3武道会 ，4吃鸡 ，5副本, 6爬七层塔活动, 7生存挑战, 8幻境寻宝, 9门派竞技,10帮派密谋,11跨服战
TrackUI.ShowType = 1 --1任务，2组队， 3战况， 4帮战，5武道会 ，6吃鸡战况 ，7吃鸡物资，8副本信息 ,9爬七层塔活动, 10生存挑战, 11幻境寻宝, 12门派竞技,13帮派密谋,14跨服战
TrackUI.FightInfoTimer = nil
TrackUI.DefaultSelectTaskID = -1
TrackUI.FightLeftTimer = nil
TrackUI.WuDaoFightTimer = nil
TrackUI.QuickMatchTimer = nil
TrackUI.QuickMatchTimeCount = 30
TrackUI.QuestScrollAreaHeight = 0
TrackUI.IsJindouyunTransfer = true
TrackUI.ChickingAddressPointFlag = false
TrackUI.ChickingBornPointFlag = false

TrackUI.CrossServerWarfarePointFlag = false --跨服战小地图
local tempRoleInfo = {}

function TrackUI.Main(parameter)

    _gt = UILayout.NewGUIDUtilTable()

    local panel = GUI.WndCreateWnd("TrackUI", "TrackUI", 0, 0, eCanvasGroup.Main)
    SetAnchorAndPivot(panel, UIAnchor.Right, UIAroundPivot.Center)
    _gt.BindName(panel,"panel")
    --GUI.CreateSafeArea(panel)

    ScreenWidth = GUI.GetWidth(panel)
    ScreenHeight = GUI.GetHeight(panel)

    local PosY = TrackUI.GetTrackPanelOffsetY()

    --节点
    --local _TrackNode = GUI.ImageCreate(panel, "TrackNode", "", -32, PosY-36, false, 0, 0)
    local _TrackNode = GUI.GroupCreate(panel, "TrackNode", -32, PosY-36, 0, 0)
    _gt.BindName(_TrackNode, "TrackNode")
    SetAnchorAndPivot(_TrackNode, UIAnchor.Right, UIAroundPivot.Center)

    --切换箭头
    local _TrackArrow = GUI.ButtonCreate(_TrackNode, "TrackArrow", "1800202270", -1, -21, Transition.ColorTint)
    _gt.BindName(_TrackArrow, "TrackArrow")
    SetSameAnchorAndPivot(_TrackArrow, UILayout.TopLeft)
    GUI.RegisterUIEvent(_TrackArrow, UCE.PointerClick, "TrackUI", "OnClickTrackNode")

    --标题背景
    local _TitleBack = GUI.ImageCreate(_TrackNode, "TitleBack", "1800200020", -2, 0, false, 220, 40)
    _gt.BindName(_TitleBack, "TitleBack")
    SetAnchorAndPivot(_TitleBack, UIAnchor.Left, UIAroundPivot.Right)
    GUI.SetIsRaycastTarget(_TitleBack, true)
    _TitleBack:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(_TitleBack, UCE.PointerClick, "TrackUI", "OnClickTitleBack")

    --任务按钮
    local _QuestBtn = GUI.ButtonCreate(_TitleBack, "QuestBtn", "1800202260", 55, 0, Transition.ColorTint)
    _gt.BindName(_QuestBtn, "QuestBtn")
    SetSameAnchorAndPivot(_QuestBtn, UILayout.Center)
    GUI.SetVisible(_QuestBtn, true)
    GUI.RegisterUIEvent(_QuestBtn, UCE.PointerClick, "TrackUI", "OnSwitchTrackQuest")

    --战况按钮
    local _FightInfoBtn = GUI.ButtonCreate(_TitleBack, "FightInfoBtn", "1800202260", 55, 0, Transition.ColorTint)
    _gt.BindName(_FightInfoBtn, "FightInfoBtn")
    SetSameAnchorAndPivot(_FightInfoBtn, UILayout.Center)
    GUI.SetVisible(_FightInfoBtn, false)
    GUI.RegisterUIEvent(_FightInfoBtn, UCE.PointerClick, "TrackUI", "OnSwitchFightInfo")

    --帮战按钮
    local _FightInfo2Btn = GUI.ButtonCreate(_TitleBack, "FightInfo2Btn", "1800202260", 55, 0, Transition.ColorTint)
    _gt.BindName(_FightInfo2Btn, "FightInfo2Btn")
    SetSameAnchorAndPivot(_FightInfo2Btn, UILayout.Center)
    GUI.SetVisible(_FightInfo2Btn, false)
    GUI.RegisterUIEvent(_FightInfo2Btn, UCE.PointerClick, "TrackUI", "OnSwitchFightInfo2")
	
	--武道会战况按钮
    local _FightInfo3Btn = GUI.ButtonCreate(_TitleBack, "FightInfo3Btn", "1800202260", 55, 0, Transition.ColorTint)
    _gt.BindName(_FightInfo3Btn, "FightInfo3Btn")
    SetSameAnchorAndPivot(_FightInfo3Btn, UILayout.Center)
    GUI.SetVisible(_FightInfo3Btn, false)
    GUI.RegisterUIEvent(_FightInfo3Btn, UCE.PointerClick, "TrackUI", "OnSwitchFightInfo3")

    --吃鸡争霸赛战况按钮
    local _FightInfo4Btn = GUI.ButtonCreate(_TitleBack, "FightInfo4Btn", "1800202260", 55, 0, Transition.ColorTint)
    _gt.BindName(_FightInfo4Btn, "FightInfo4Btn")
    SetSameAnchorAndPivot(_FightInfo4Btn, UILayout.Center)
    GUI.SetVisible(_FightInfo4Btn, false)
    GUI.RegisterUIEvent(_FightInfo4Btn, UCE.PointerClick, "TrackUI", "OnSwitchFightInfo4")

   -- 积分塔活动
   local _FightInfo6Btn = GUI.ButtonCreate(_TitleBack, "FightInfo6Btn", "1800202260", 55, 0, Transition.ColorTint)
    _gt.BindName(_FightInfo6Btn, "FightInfo6Btn")
    SetSameAnchorAndPivot(_FightInfo6Btn, UILayout.Center)
    GUI.SetVisible(_FightInfo6Btn, false)
    GUI.RegisterUIEvent(_FightInfo6Btn, UCE.PointerClick, "TrackUI", "OnSwitchFightInfo6")

    -- 幻境寻宝活动
   local _FightInfo7Btn = GUI.ButtonCreate(_TitleBack, "FightInfo7Btn", "1800202260", 55, 0, Transition.ColorTint)
   _gt.BindName(_FightInfo7Btn, "FightInfo7Btn")
   SetSameAnchorAndPivot(_FightInfo7Btn, UILayout.Center)
   GUI.SetVisible(_FightInfo7Btn, false)
   GUI.RegisterUIEvent(_FightInfo7Btn, UCE.PointerClick, "TrackUI", "OnSwitchFightInfo7")

   -- 门派竞技活动
   local _FightInfo8Btn = GUI.ButtonCreate(_TitleBack, "FightInfo8Btn", "1800202260", 55, 0, Transition.ColorTint)
   _gt.BindName(_FightInfo8Btn, "FightInfo8Btn")
   SetSameAnchorAndPivot(_FightInfo8Btn, UILayout.Center)
   GUI.SetVisible(_FightInfo8Btn, false)
   GUI.RegisterUIEvent(_FightInfo8Btn, UCE.PointerClick, "TrackUI", "OnSwitchFightInfo8")

    --副本按钮
    local _DungeonBtn = GUI.ButtonCreate(_TitleBack, "DungeonBtn", "1800202260", 55, 0, Transition.ColorTint)
    _gt.BindName(_DungeonBtn, "DungeonBtn")
    SetSameAnchorAndPivot(_DungeonBtn, UILayout.Center)
    GUI.SetVisible(_DungeonBtn, false)
    GUI.RegisterUIEvent(_DungeonBtn, UCE.PointerClick, "TrackUI", "OnSwitchDungeon")

    --组队按钮
    local _TeamBtn = GUI.ButtonCreate(_TitleBack, "TeamBtn", "1800202260", -55, 0, Transition.ColorTint)
    _gt.BindName(_TeamBtn, "TeamBtn")
    SetSameAnchorAndPivot(_TeamBtn, UILayout.Center)
    GUI.SetVisible(_TeamBtn, false)
    GUI.RegisterUIEvent(_TeamBtn, UCE.PointerClick, "TrackUI", "OnSwitchTrackTeam")

    --吃鸡争霸赛物资按钮
    local _BattleBagBtn = GUI.ButtonCreate(_TitleBack, "BattleBagBtn", "1800202260", -55, 0, Transition.ColorTint)
    _gt.BindName(_BattleBagBtn, "BattleBagBtn")
    SetSameAnchorAndPivot(_BattleBagBtn, UILayout.Center)
    GUI.SetVisible(_BattleBagBtn, false)
    GUI.RegisterUIEvent(_BattleBagBtn, UCE.PointerClick, "TrackUI", "OnSwitchBattleBagBtn")

    --生存挑战按钮
    local _ChallengeBtn = GUI.ButtonCreate(_TitleBack, "ChallengeBtn", "1800202260", 55, 0, Transition.ColorTint)
    _gt.BindName(_ChallengeBtn, "ChallengeBtn")
    SetSameAnchorAndPivot(_ChallengeBtn, UILayout.Center)
    GUI.SetVisible(_ChallengeBtn, false)
    GUI.RegisterUIEvent(_ChallengeBtn, UCE.PointerClick, "TrackUI", "OnSwitchChallengeBtn")
    -- 爬塔活动
    -- local climbTowerBtn = GUI.ButtonCreate(_TitleBack, "climbTowerBtn", "1800202260", -55, 0, Transition.ColorTint)
    -- _gt.BindName(climbTowerBtn, "climbTowerBtn")
    -- SetSameAnchorAndPivot(climbTowerBtn, UILayout.Center)
    -- GUI.SetVisible(climbTowerBtn, false)
    -- GUI.RegisterUIEvent(climbTowerBtn, UCE.PointerClick, "TrackUI", "OnSwitchBattleBagBtn")

    --标题任务
    local _TitleQuest = GUI.CreateStatic(_TitleBack, "TitleQuest", "任务", 55, 2, 100, 35)
    _gt.BindName(_TitleQuest, "TitleQuest")
    SetSameAnchorAndPivot(_TitleQuest, UILayout.Center)
    GUI.StaticSetFontSize(_TitleQuest, UIDefine.FontSizeL)
    GUI.SetColor(_TitleQuest, UIDefine.BrownColor)
    GUI.StaticSetAlignment(_TitleQuest, TextAnchor.MiddleCenter)

    --标题战况：水陆大会
    local _TitleFightInfo = GUI.CreateStatic(_TitleBack, "TitleFightInfo", "战况", 55, 2, 100, 35)
    _gt.BindName(_TitleFightInfo, "TitleFightInfo")
    SetSameAnchorAndPivot(_TitleFightInfo, UILayout.Center)
    GUI.StaticSetFontSize(_TitleFightInfo, UIDefine.FontSizeL)
    GUI.SetColor(_TitleFightInfo, UIDefine.BrownColor)
    GUI.StaticSetAlignment(_TitleFightInfo, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleFightInfo, false)

    --标题帮战：帮派竞赛
    local _TitleFightInfo2 = GUI.CreateStatic(_TitleBack, "TitleFight2Info", "帮战", 55, 2, 100, 35)
    _gt.BindName(_TitleFightInfo2, "TitleFightInfo2")
    SetSameAnchorAndPivot(_TitleFightInfo2, UILayout.Center)
    GUI.StaticSetFontSize(_TitleFightInfo2, UIDefine.FontSizeL)
    GUI.SetColor(_TitleFightInfo2, UIDefine.BrownColor)
    GUI.StaticSetAlignment(_TitleFightInfo2, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleFightInfo2, false)
	
	--标题活动：武道会
    local _TitleFightInfo3 = GUI.CreateStatic(_TitleBack, "TitleFight3Info", "活动", 55, 2, 100, 35)
    _gt.BindName(_TitleFightInfo3, "TitleFightInfo3")
    SetSameAnchorAndPivot(_TitleFightInfo3, UILayout.Center)
    GUI.StaticSetFontSize(_TitleFightInfo3, UIDefine.FontSizeL)
    GUI.SetColor(_TitleFightInfo3, UIDefine.BrownColor)
    GUI.StaticSetAlignment(_TitleFightInfo3, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleFightInfo3, false)

    --标题战况：吃鸡争霸赛
    local _TitleFightInfo4 = GUI.CreateStatic(_TitleBack, "TitleFight4Info", "战况", 55, 2, 100, 35)
    _gt.BindName(_TitleFightInfo4, "TitleFightInfo4")
    SetSameAnchorAndPivot(_TitleFightInfo4, UILayout.Center)
    GUI.StaticSetFontSize(_TitleFightInfo4, UIDefine.FontSizeL)
    GUI.SetColor(_TitleFightInfo4, UIDefine.BrownColor)
    GUI.StaticSetAlignment(_TitleFightInfo4, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleFightInfo4, false)

    --标题副本
    local _TitleDungeon = GUI.CreateStatic(_TitleBack, "TitleDungeon", "副本", 55, 2, 100, 35)
    _gt.BindName(_TitleDungeon, "TitleDungeon")
    SetSameAnchorAndPivot(_TitleDungeon, UILayout.Center)
    GUI.StaticSetFontSize(_TitleDungeon, UIDefine.FontSizeL)
    GUI.SetColor(_TitleDungeon, UIDefine.BrownColor)
    GUI.StaticSetAlignment(_TitleDungeon, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleDungeon, false)

    -- 标题积分塔
    local _TitleFightInfo6 = GUI.CreateStatic(_TitleBack, "TitleFight6Info", "积分塔", 55, 2, 100, 35)
    _gt.BindName(_TitleFightInfo6, "TitleFightInfo6")
    SetSameAnchorAndPivot(_TitleFightInfo6, UILayout.Center)
    GUI.StaticSetFontSize(_TitleFightInfo6, UIDefine.FontSizeL)
    GUI.SetColor(_TitleFightInfo6, UIDefine.BrownColor)
    GUI.StaticSetAlignment(_TitleFightInfo6, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleFightInfo6, false)

    -- 标题幻境寻宝
    local _TitleFightInfo7 = GUI.CreateStatic(_TitleBack, "TitleFight7Info", "幻境寻宝", 55, 2, 100, 35)
    _gt.BindName(_TitleFightInfo7, "TitleFightInfo7")
    SetSameAnchorAndPivot(_TitleFightInfo7, UILayout.Center)
    GUI.StaticSetFontSize(_TitleFightInfo7, UIDefine.FontSizeL)
    GUI.SetColor(_TitleFightInfo7, UIDefine.BrownColor)
    GUI.StaticSetAlignment(_TitleFightInfo7, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleFightInfo7, false)

    -- 标题门派竞技
    local _TitleFightInfo8 = GUI.CreateStatic(_TitleBack, "TitleFight8Info", "门派竞技", 55, 2, 100, 35)
    _gt.BindName(_TitleFightInfo8, "TitleFightInfo8")
    SetSameAnchorAndPivot(_TitleFightInfo8, UILayout.Center)
    GUI.StaticSetFontSize(_TitleFightInfo8, UIDefine.FontSizeL)
    GUI.SetColor(_TitleFightInfo8, UIDefine.BrownColor)
    GUI.StaticSetAlignment(_TitleFightInfo8, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleFightInfo8, false)

    --标题组队
    local _TitleTeam = GUI.CreateStatic(_TitleBack, "TitleTeam", "组队", -55, 2, 100, 35)
    _gt.BindName(_TitleTeam, "TitleTeam")
    SetSameAnchorAndPivot(_TitleTeam, UILayout.Center)
    GUI.StaticSetFontSize(_TitleTeam, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(_TitleTeam, TextAnchor.MiddleCenter)

    --标题物资：吃鸡争霸赛
    local _TitleBattleBag = GUI.CreateStatic(_TitleBack, "TitleBattleBag", "物资", -55, 2, 100, 35)
    _gt.BindName(_TitleBattleBag, "TitleBattleBag")
    SetSameAnchorAndPivot(_TitleBattleBag, UILayout.Center)
    GUI.StaticSetFontSize(_TitleBattleBag, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(_TitleBattleBag, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleBattleBag, false)

    --标题生存挑战
    local _TitleChallenge = GUI.CreateStatic(_TitleBack, "TitleChallenge", "生存挑战", 55, 2, 100, 35)
    _gt.BindName(_TitleChallenge, "TitleChallenge")
    SetSameAnchorAndPivot(_TitleChallenge, UILayout.Center)
    GUI.StaticSetFontSize(_TitleChallenge, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(_TitleChallenge, TextAnchor.MiddleCenter)
    GUI.SetVisible(_TitleChallenge, false)

    --黑色底栏
    local Height = TrackUI.GetTrackPanelHeight() + 2

    local _RoleLstBack = GUI.ImageCreate(_TrackNode, "RoleLstBack", "1800200010", -223, 24, false, 254, Height)
    _gt.BindName(_RoleLstBack, "RoleLstBack")
    SetSameAnchorAndPivot(_RoleLstBack, UILayout.TopLeft)
    GUI.SetVisible(_RoleLstBack, false)

    local _QuestLstBack = GUI.ImageCreate(_TrackNode, "QuestLstBack", "1800499999", -223, 118)
    _gt.BindName(_QuestLstBack, "QuestLstBack")
    SetSameAnchorAndPivot(_QuestLstBack, UILayout.TopLeft)
    GUI.SetVisible(_QuestLstBack, true)

    --战斗信息UI
    local _FightInfoBack = GUI.ImageCreate(_TrackNode, "FightInfoBack", "1800200010", -223, 24, false, 254, Height)
    _gt.BindName(_FightInfoBack, "FightInfoBack")
    SetSameAnchorAndPivot(_FightInfoBack, UILayout.TopLeft)
    GUI.SetVisible(_FightInfoBack, true)
    GUI.SetIsRaycastTarget(_FightInfoBack, true)
    TrackUI.OnShowFightInfo(_FightInfoBack)

    --帮派竞赛UI
    local _FightInfo2Back = GUI.ImageCreate(_TrackNode, "FightInfo2Back", "1800200010", -223, 24, false, 254, 100)
    _gt.BindName(_FightInfo2Back, "FightInfo2Back")
    SetSameAnchorAndPivot(_FightInfo2Back, UILayout.TopLeft)
    GUI.SetVisible(_FightInfo2Back, true)
    GUI.SetIsRaycastTarget(_FightInfo2Back, true)
    TrackUI.OnShowFightInfo2(_FightInfo2Back)
	
	--武道会UI
    local _FightInfo3Back = GUI.ImageCreate(_TrackNode, "FightInfo3Back", "1800400290", -222, 24, false, 254, 390)
    _gt.BindName(_FightInfo3Back, "FightInfo3Back")
    SetSameAnchorAndPivot(_FightInfo3Back, UILayout.TopLeft)
    GUI.SetVisible(_FightInfo3Back, true)
    GUI.SetIsRaycastTarget(_FightInfo3Back, true)
    TrackUI.OnShowFightInfo3(_FightInfo3Back)

    --战况UI：吃鸡争霸赛
    local _FightInfo4Back = GUI.ImageCreate(_TrackNode, "FightInfo4Back", "1800200010", -223, 24, false, 254, 390)
    _gt.BindName(_FightInfo4Back, "FightInfo4Back")
    SetSameAnchorAndPivot(_FightInfo4Back, UILayout.TopLeft)
    GUI.SetVisible(_FightInfo4Back, true)
    GUI.SetIsRaycastTarget(_FightInfo4Back, true)
    TrackUI.OnShowFightInfo4(_FightInfo4Back)

    --物资UI：吃鸡争霸赛
    local _BattleBagBack = GUI.ImageCreate(_TrackNode, "BattleBagBack", "1800200010", -223, 24, false, 254, 390)
    _gt.BindName(_BattleBagBack, "BattleBagBack")
    SetSameAnchorAndPivot(_BattleBagBack, UILayout.TopLeft)
    GUI.SetVisible(_BattleBagBack, true)
    GUI.SetIsRaycastTarget(_BattleBagBack, true)
    TrackUI.OnShowBattleBagInfo(_BattleBagBack)

    --副本UI
    local _DungeonBack = GUI.ImageCreate(_TrackNode, "DungeonBack", "1800200010", -223, 24, false, 254, 390)
    _gt.BindName(_DungeonBack, "DungeonBack")
    SetSameAnchorAndPivot(_DungeonBack, UILayout.TopLeft)
    GUI.SetVisible(_DungeonBack, true)
    GUI.SetIsRaycastTarget(_DungeonBack, true)
    GUI.SetColor(_DungeonBack, UIDefine.Transparent)
    TrackUI.OnShowDungeon(_DungeonBack)

    -- 积分塔UI
    local _FightInfo6Back = GUI.ImageCreate(_TrackNode, "FightInfo6Back", "1800200010", -223, 24, false, 254, 390)
    _gt.BindName(_FightInfo6Back, "FightInfo6Back")
    SetSameAnchorAndPivot(_FightInfo6Back, UILayout.TopLeft)
    GUI.SetVisible(_FightInfo6Back, true)
    GUI.SetIsRaycastTarget(_FightInfo6Back, true)
    GUI.SetColor(_FightInfo6Back, UIDefine.Transparent)
    TrackUI.OnShowFightInfo6(_FightInfo6Back)

    -- 生存挑战UI
    local _ChallengeBack = GUI.ImageCreate(_TrackNode, "ChallengeBack", "1800200010", -223, 24, false, 254, 390)
    _gt.BindName(_ChallengeBack, "ChallengeBack")
    SetSameAnchorAndPivot(_ChallengeBack, UILayout.TopLeft)
    GUI.SetVisible(_ChallengeBack, true)
    GUI.SetIsRaycastTarget(_ChallengeBack, true)
    GUI.SetColor(_ChallengeBack, UIDefine.Transparent)
    TrackUI.OnShowChallenge(_ChallengeBack)

    -- 幻境寻宝UI
    local _FightInfo7Back = GUI.ImageCreate(_TrackNode, "FightInfo7Back", "1800200010", -223, 24, false, 254, 390)
    _gt.BindName(_FightInfo7Back, "FightInfo7Back")
    SetSameAnchorAndPivot(_FightInfo7Back, UILayout.TopLeft)
    GUI.SetVisible(_FightInfo7Back, true)
    GUI.SetIsRaycastTarget(_FightInfo7Back, true)
    GUI.SetColor(_FightInfo7Back, UIDefine.Transparent)
    TrackUI.OnShowFightInfo7(_FightInfo7Back)

    -- 门派竞技UI
    local _FightInfo8Back = GUI.ImageCreate(_TrackNode, "FightInfo8Back", "1800200010", -223, 24, false, 254, 392)
    _gt.BindName(_FightInfo8Back, "FightInfo8Back")
    SetSameAnchorAndPivot(_FightInfo8Back, UILayout.TopLeft)
    GUI.SetVisible(_FightInfo8Back, true)
    GUI.SetIsRaycastTarget(_FightInfo8Back, true)
    GUI.SetColor(_FightInfo8Back, UIDefine.Transparent)
    TrackUI.OnShowFightInfo8(_FightInfo8Back)

    --任务筋斗云标记按钮
    local _JinDouYunBtn = GUI.ButtonCreate(_TrackNode, "JinDouYunBtn", "1800202290", -263, -19, Transition.ColorTint, "")
    SetSameAnchorAndPivot(_JinDouYunBtn, UILayout.TopLeft)
    GUI.RegisterUIEvent(_JinDouYunBtn, UCE.PointerClick, "TrackUI", "OnClickJinDouYunBtn")
    _gt.BindName(_JinDouYunBtn, "JinDouYunBtn")

    --滚动区
    Height = TrackUI.GetTrackPanelHeight()

    local _OnePanelSize = Vector2.New(0, 0)
    local _SeatScroll = GUI.ScrollRectCreate(_RoleLstBack, "SeatScroll", 2, 2, 250, Height, 0, false, _OnePanelSize, UIAroundPivot.Top, UIAnchor.Top, 0)
    _gt.BindName(_SeatScroll, "SeatScroll")
    SetSameAnchorAndPivot(_SeatScroll, UILayout.TopLeft)
    GUI.ScrollRectSetChildAnchor(_SeatScroll, UIAnchor.TopLeft)
    GUI.ScrollRectSetChildSpacing(_SeatScroll, Vector2.New(4, 0))
    GUI.ScrollRectSetNormalizedPosition(_SeatScroll, Vector2.New(0, 0))

    local _SeatScrollLst = GUI.ImageCreate(_SeatScroll, "SeatScrollLst", "1800499999", 0, 0)
    _gt.BindName(_SeatScrollLst, "SeatScrollLst")
    SetSameAnchorAndPivot(_SeatScrollLst, UILayout.TopLeft)

    --目前定高度为1，实际需要按任务个数设定高度
    local _QuestScroll = GUI.ScrollRectCreate(_QuestLstBack, "QuestScroll", 2, 2, 250, 251, 0, false, _OnePanelSize, UIAroundPivot.Top, UIAnchor.Top, 0)
    _gt.BindName(_QuestScroll, "QuestScroll")
    SetSameAnchorAndPivot(_QuestScroll, UILayout.TopLeft)
    GUI.ScrollRectSetChildSpacing(_QuestScroll, Vector2.New(0, 0))
    GUI.ScrollRectSetNormalizedPosition(_QuestScroll, Vector2.New(0, 0))

    local _QuestScrollLst = GUI.ImageCreate(_QuestScroll, "QuestScrollLst", "1800499999", -121, 0)
    _gt.BindName(_QuestScrollLst, "QuestScrollLst")
    SetSameAnchorAndPivot(_QuestScrollLst, UILayout.TopLeft)
    TrackUI.SwitchQuestOrFightInfoNode(true)


    --注册消息
    CL.RegisterMessage(GM.TeamInfoUpdate, "TrackUI", "OnTeamInfoUpdate")
    CL.RegisterMessage(GM.QuestInfoUpdate, "TrackUI", "OnQuestInfoUpdate")
    CL.RegisterMessage(GM.PlayerEnterGame, "TrackUI", "OnPlayerEnterGame")
    CL.RegisterAttr(RoleAttr.RoleAttrLevel, TrackUI.UpdateAttrValue)
    --CL.RegisterAttr(RoleAttr.RoleAttrReincarnation, TrackUI.UpdateAttrValue)
    CL.RegisterAttr(RoleAttr.RoleAttrJob1, TrackUI.UpdateAttrValue)
    CL.RegisterAttr(RoleAttr.RoleAttrVip, TrackUI.UpdateAttrValue)
    CL.RegisterAttr(RoleAttr.RoleAttrRole, TrackUI.UpdateAttrValue)
    
    CL.RegisterAttr(RoleAttr.RoleAttrHp, TrackUI.UpdateAttrValue)
    CL.RegisterAttr(RoleAttr.RoleAttrMp, TrackUI.UpdateAttrValue)
    CL.RegisterAttr(RoleAttr.RoleAttrHpLimit, TrackUI.UpdateAttrValue)
    CL.RegisterAttr(RoleAttr.RoleAttrMpLimit, TrackUI.UpdateAttrValue)

    -- 显示活动信息
    local _ActMsg = GUI.CreateStatic(panel, "ActMsg", "活动信息，活动信息", 0, -180, 800, 50,"100");
    SetSameAnchorAndPivot(_ActMsg, UILayout.Center)
    GUI.StaticSetAlignment(_ActMsg, TextAnchor.MiddleCenter);
    GUI.SetIsOutLine(_ActMsg, true)
    GUI.SetOutLine_Distance(_ActMsg, UIDefine.OutLineDistance)
    GUI.SetColor(_ActMsg, UIDefine.White4Color)
    GUI.SetOutLine_Color(_ActMsg, Color.New(236/255,129/255,119/255,255/255))

    GUI.StaticSetFontSize(_ActMsg, 40);
    GUI.SetVisible(_ActMsg,false)
    _gt.BindName(_ActMsg,"ActMsg")

    local _ActMsgCountDown = GUI.CreateStatic(panel, "ActMsgCountDown", "20", 0, -180, 400, 120,"100");
    SetSameAnchorAndPivot(_ActMsgCountDown, UILayout.Center)
    GUI.StaticSetAlignment(_ActMsgCountDown, TextAnchor.MiddleCenter);
    GUI.SetIsOutLine(_ActMsgCountDown, true)
    GUI.SetOutLine_Distance(_ActMsgCountDown, UIDefine.OutLineDistance)
    GUI.SetColor(_ActMsgCountDown, UIDefine.White4Color)
    GUI.SetOutLine_Color(_ActMsgCountDown, Color.New(236/255,129/255,119/255,255/255))

    GUI.StaticSetFontSize(_ActMsgCountDown, 40);
    GUI.SetVisible(_ActMsgCountDown,false)
    _gt.BindName(_ActMsgCountDown,"ActMsgCountDown")
end

function TrackUI.GetATWidth()
	local TrackArrow = _gt.GetUI("TrackArrow")
	local TitleBack = _gt.GetUI("TitleBack")
	local JinDouYunBtn = _gt.GetUI("JinDouYunBtn")
	local SumWidth = GUI.GetWidth(TrackArrow) + GUI.GetWidth(TitleBack) + GUI.GetWidth(JinDouYunBtn)
	return SumWidth
end

function TrackUI.OnDestroy()
    CL.UnRegisterMessage(GM.TeamInfoUpdate, "TrackUI", "OnTeamInfoUpdate")
    CL.UnRegisterMessage(GM.QuestInfoUpdate, "TrackUI", "OnQuestInfoUpdate")
    CL.UnRegisterMessage(GM.PlayerEnterGame, "TrackUI", "OnPlayerEnterGame")
    CL.UnRegisterAttr(RoleAttr.RoleAttrLevel, TrackUI.UpdateAttrValue)
    --CL.UnRegisterAttr(RoleAttr.RoleAttrReincarnation, TrackUI.UpdateAttrValue)
    CL.UnRegisterAttr(RoleAttr.RoleAttrJob1, TrackUI.UpdateAttrValue)
    CL.UnRegisterAttr(RoleAttr.RoleAttrVip, TrackUI.UpdateAttrValue)
    CL.UnRegisterAttr(RoleAttr.RoleAttrRole, TrackUI.UpdateAttrValue)

    CL.UnRegisterAttr(RoleAttr.RoleAttrHp, TrackUI.UpdateAttrValue)
    CL.UnRegisterAttr(RoleAttr.RoleAttrMp, TrackUI.UpdateAttrValue)
    CL.UnRegisterAttr(RoleAttr.RoleAttrHpLimit, TrackUI.UpdateAttrValue)
    CL.UnRegisterAttr(RoleAttr.RoleAttrMpLimit, TrackUI.UpdateAttrValue)

    if TrackUI.QuickMatchTimer then
        TrackUI.QuickMatchTimer:Stop()
        TrackUI.QuickMatchTimer = nil
    end
end

function TrackUI.OnPlayerEnterGame()
    CL.SendNotify(NOTIFY.SubmitForm,"FormVip","VipGetDayIngotData")
end

function TrackUI.UpdateAttrValue(attrType, value)
    --角色列表
    local _TeamInfo = LD.GetTeamInfo()
    local _RoleNum = 0
    if tostring(_TeamInfo.team_guid) ~= "0" and _TeamInfo.members ~= nil then
        _RoleNum = _TeamInfo.members.Length
    end

    local _MemberInfos = _TeamInfo.members
    for i = 1, _RoleNum do
        if _MemberInfos[i - 1].guid == LD.GetSelfGUID() then
            local key = CL.ConvertFromAttr(attrType)
            local roleInfo = tempRoleInfo[i]
			if not roleInfo then break end
            -- print("=============1=======")
            -- print(roleInfo.Hp)
            -- print(roleInfo.MaxHp)
            -- print(roleInfo.Mp)
            -- print(roleInfo.MaxMp)
            -- print(value)
            -- print("=============2=======")
            if key == 35  then 
                value = tonumber(tostring(value))
                roleInfo.Hp = value
                value =  roleInfo.Hp /  roleInfo.MaxHp
            elseif key == 36  then
                value = tonumber(tostring(value))
                roleInfo.MaxHp = value
                value =  roleInfo.Hp /  roleInfo.MaxHp
            elseif  key == 37 then 
                value = tonumber(tostring(value))
                roleInfo.Mp = value
                value =  roleInfo.Mp /  roleInfo.MaxMp
            elseif  key == 38 then
                value = tonumber(tostring(value))
                roleInfo.MaxMp = value
                value =  roleInfo.Mp /  roleInfo.MaxMp
            end
            TrackUI.UpdateRoleAtt(i-1,key , value)
            break
        end
    end
end

function TrackUI.EnableShowJindouyunBtn(show)
    local JindouyunBtn = _gt.GetUI("JinDouYunBtn")
    if JindouyunBtn then
        GUI.SetVisible(JindouyunBtn, show)
    end
end
function TrackUI.OnClickJinDouYunBtn()
    GlobalUtils.ShowBoxMsg2Btn("提示","目前自动使用筋斗云传送处于开启状态，是否前往关闭？","TrackUI","确认","OnJindouyunBtnYes","取消")
end

function TrackUI.OnJindouyunBtnYes()
    GUI.OpenWnd("QuestDlgUI")
end

--切换类型显示：0任务，1战斗信息，2帮派竞赛
function TrackUI.SwitchQuestOrFightInfo2Node(showQuest)
    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 2)
    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 4)
    if showQuest then
        if TrackUI.FightLeftTimer then
            TrackUI.FightLeftTimer:Stop()
            TrackUI.FightLeftTimer = nil
        end
    end
end

function TrackUI.SwitchQuestOrFightInfoNode(showQuest)
    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 1)
    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 3)
    if TrackUI.FightInfoTimer == nil then
        TrackUI.FightInfoTimer = Timer.New(TrackUI.OnFightInfoTimer, 1,-1)
    end
    if TrackUI.QuestOrFightInfoMode == 0 then
        TrackUI.FightInfoTimer:Stop()
        TrackUI.FightInfoTimer:Reset(TrackUI.OnFightInfoTimer, 1,-1)
    else
        TrackUI.FightInfoTimer:Start()
    end
end

function TrackUI.SwitchQuestOrFightInfo3Node(showQuest)
    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 3)
    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 5)
    if showQuest then
        if TrackUI.WuDaoFightTimer then
            TrackUI.WuDaoFightTimer:Stop()
            TrackUI.WuDaoFightTimer = nil
        end
    end
end

function TrackUI.SwitchQuestOrFightInfo7Node(showQuest)
    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 8)
    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 11)
    if showQuest then
        if TrackUI.TreasureHuntTimer then
            TrackUI.TreasureHuntTimer:Stop()
            TrackUI.TreasureHuntTimer = nil
        end
    end
end

function TrackUI.SwitchQuestOrFightInfo8Node(showQuest)
    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 9)
    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 12)
    if showQuest then
        if TrackUI.SchoolContestTimer then
            TrackUI.SchoolContestTimer:Stop()
            TrackUI.SchoolContestTimer = nil
        end
    end
end

function TrackUI.SwitchFightInfo4OrBattleBagNode(showQuest)
    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 4)
    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 6)
    if TrackUI.QuestOrFightInfoMode == 4 then
        CL.UnRegisterMessage(GM.CustomDataUpdate, "TrackUI", "OnCustomDataUpdate")
        CL.RegisterMessage(GM.CustomDataUpdate, "TrackUI", "OnCustomDataUpdate")
    else
        TrackUI.ChickingAddressPointFlag = false
        TrackUI.ChickingBornPointFlag = false
        GUI.DestroyWnd("MapUI")
        local ActMsg = _gt.GetUI("ActMsg")
        local ActMsgCountDown = _gt.GetUI("ActMsgCountDown")
        if TrackUI.DynamicSettingActivityMessageTimer then
            TrackUI.DynamicSettingActivityMessageTimer:Stop()
            TrackUI.DynamicSettingActivityMessageTimer = nil
        end
        GUI.SetVisible(ActMsg,false)
        GUI.SetVisible(ActMsgCountDown,false)
        if TrackUI.SetBattleBackTimer ~= nil then
            TrackUI.SetBattleBackTimer:Stop()
            TrackUI.SetBattleBackTimer = nil
        end
        if TrackUI.SetBattleValueBackTimer ~= nil then
            TrackUI.SetBattleValueBackTimer:Stop()
            TrackUI.SetBattleValueBackTimer = nil
        end
        for i = 1, 2, 1 do
            local battleBack = _gt.GetUI("battleBack" .. i)
            local battleValueBarBack = _gt.GetUI("battleValueBarBack" .. i)
            GUI.SetVisible(battleBack,false)
            GUI.SetVisible(battleValueBarBack,false)
        end
        local fightMsgPage = _gt.GetUI("fightMsgPage")
        GUI.SetVisible(fightMsgPage,false)
        CL.UnRegisterMessage(GM.CustomDataUpdate, "TrackUI", "OnCustomDataUpdate")
        local btn1 = GUI.Get("MainUI/rightBtn")
        local btn2 = GUI.Get("MainUI/leftBtn")
        local bg1 = GUI.Get("MainUI/rightBg")
        local bg2 = GUI.Get("MainUI/leftBg/leftBg_Top")
        local vis1 = GUI.GetData(bg1,"visiable")
        local vis2 = GUI.GetData(bg2,"visiable")
        if vis1 == "true" then
            MainUI.RightBtnDoTweenScale(GUI.GetGuid(btn1))
        end
        if vis2 == "true" then
            MainUI.RightBtnDoTweenScale(GUI.GetGuid(btn2))
        end
        TrackUI.OnExitTipsBtnClick()
    end
end

function TrackUI.SwitchQuestOrDungeonNode(showQuest)
    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 5)
    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 8)
    if TrackUI.QuestOrFightInfoMode == 5 then
        TrackUI.IsFirstEnter = true
        local _Countdown = _gt.GetUI("Countdown")
        GUI.SetVisible(_Countdown,true)
        if TrackUI.UpdateTimer == nil then
            TrackUI.UpdateTimer = Timer.New(TrackUI.SurplusTimer, 1, -1, true)
        else
            TrackUI.UpdateTimer:Stop()
            TrackUI.UpdateTimer:Reset(TrackUI.SurplusTimer, 1, -1)
        end
    else
        TrackUI.UpdateTimer:Stop()
        TrackUI.UpdateTimer = nil
    end
end


-----------------------------------------------------------------Start 跨服战 Start---------------------------------------------------------

--跨服战服务器调用切换
function TrackUI.SwitchQuestOrCrossServerWarfare6Node(showQuest)
    test("跨服战服务器调用切换")


    --跨服战按钮
    local TitleBack = _gt.GetUI("TitleBack")

    local TrackNode = _gt.GetUI("TrackNode")

    local crossServerWarfareBtn = GUI.GetChild(TitleBack,"crossServerWarfareBtn",false)

    local crossServerWarfareTxt = GUI.GetChild(TitleBack,"crossServerWarfareTxt",false)

    local crossServerWarfareBack = GUI.GetChild(TrackNode,"crossServerWarfareBack",false)

    if crossServerWarfareBtn == nil then

        crossServerWarfareBtn = GUI.ButtonCreate(TitleBack, "crossServerWarfareBtn", "1800202260", 55, 0, Transition.ColorTint)
        _gt.BindName(crossServerWarfareBtn, "crossServerWarfareBtn")
        SetSameAnchorAndPivot(crossServerWarfareBtn, UILayout.Center)
        GUI.SetVisible(crossServerWarfareBtn, false)
        GUI.RegisterUIEvent(crossServerWarfareBtn, UCE.PointerClick, "TrackUI", "OnSwitchCrossServerWarfareBtn")

    end



    if crossServerWarfareTxt == nil then

        --跨服战标题
        crossServerWarfareTxt = GUI.CreateStatic(TitleBack, "crossServerWarfareTxt", "跨服战", 55, 2, 100, 35)
        _gt.BindName(crossServerWarfareTxt, "crossServerWarfareTxt")
        SetSameAnchorAndPivot(crossServerWarfareTxt, UILayout.Center)
        GUI.StaticSetFontSize(crossServerWarfareTxt, UIDefine.FontSizeL)
        GUI.StaticSetAlignment(crossServerWarfareTxt, TextAnchor.MiddleCenter)
        GUI.SetVisible(crossServerWarfareTxt, false)

    end

    if crossServerWarfareBack == nil then

        --跨服战UI
        crossServerWarfareBack = GUI.ImageCreate(TrackNode, "crossServerWarfareBack", "1800200010", -223, 24, false, 254, 390)
        _gt.BindName(crossServerWarfareBack, "crossServerWarfareBack")
        SetSameAnchorAndPivot(crossServerWarfareBack, UILayout.TopLeft)
        GUI.SetVisible(crossServerWarfareBack, true)
        GUI.SetIsRaycastTarget(crossServerWarfareBack, true)
        GUI.SetColor(crossServerWarfareBack, UIDefine.Transparent)
        TrackUI.OnShowCrossServerWarfare(crossServerWarfareBack)


    end



    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 11)

    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 14)

    if showQuest == false then

        --关闭其他的界面
        TrackUI.CloseOtherUI()

    end



end


--服务器回调刷新
function TrackUI.RefreshCrossServerWarfareData()
    test("===========================跨服战TrackUI服务器回调刷新=====================")

    test("TrackUI.Act_CrossServerVal",TrackUI.Act_CrossServerVal)

    test("MainUI.Act_CrossServerData",inspect(MainUI.Act_CrossServerData))

    local crossServerWarfareBack = _gt.GetUI("crossServerWarfareBack")
    local bg = GUI.GetChild(crossServerWarfareBack,"CrossServerWarfareBg",false)

    local cutLine = GUI.GetChild(bg,"cutLine",false)
    local ContributionDegreeValue = GUI.GetChild(cutLine,"ContributionDegreeValue",false)

    GUI.StaticSetText(ContributionDegreeValue,TrackUI.Act_CrossServerVal)

    local item = GUI.GetChild(bg,"item",false)
    local pnSellout = GUI.GetChild(bg,"pnSellout",false)

    if MainUI.Act_CrossServerData ~= nil then


        if MainUI.Act_CrossServerData.PlayerValReward ~= nil then

            local temp = {}

            for i, v in pairs(MainUI.Act_CrossServerData.PlayerValReward) do

                table.insert(temp,tonumber(i))

            end

            table.sort(temp,function(a,b)

                if a ~= b then
                    return a < b
                end


            end)

            local key = 0

            for i = 1, #temp do

                if TrackUI.Act_CrossServerVal >= temp[i] then

                    key = temp[i]

                end

            end

            test("temp",inspect(temp))

            test("key",key)

            if key ~= 0 then

                GUI.SetVisible(item,true)
                GUI.SetVisible(pnSellout,false)

                TrackUI.Act_CrossServerValOnesListItemData = MainUI.Act_CrossServerData.PlayerValReward[tostring(key)]

                test("TrackUI.Act_CrossServerValOnesListItemData",inspect(TrackUI.Act_CrossServerValOnesListItemData))

                GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,TrackUI.Act_CrossServerValOnesListItemData.Icon)

            else

                GUI.SetVisible(item,false)
                GUI.SetVisible(pnSellout,true)

            end


        end

    end

end

--跨服战UI创建
function TrackUI.OnShowCrossServerWarfare(parent)
    test("跨服战UI创建")

    local bg = GUI.ImageCreate(parent, "CrossServerWarfareBg", "1800200010", 0, 0, false, 254, 392)
    SetSameAnchorAndPivot(bg, UILayout.TopLeft)

    local openMapBtn = GUI.ButtonCreate(bg, "openMapBtn", "1800402080", 0, 20, Transition.ColorTint, "打开地图", 150, 55, false);
    GUI.SetIsOutLine(openMapBtn, true);
    SetAnchorAndPivot(openMapBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ButtonSetTextFontSize(openMapBtn, 23);
    GUI.ButtonSetTextColor(openMapBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(openMapBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(openMapBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(openMapBtn, UCE.PointerClick, "TrackUI", "OnOpenMapBtnClick");

    local openWarCommuniqueBtn = GUI.ButtonCreate(bg, "openWarCommuniqueBtn", "1800402080", 0, 90, Transition.ColorTint, "打开战报", 150, 55, false);
    GUI.SetIsOutLine(openWarCommuniqueBtn, true);
    SetAnchorAndPivot(openWarCommuniqueBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ButtonSetTextFontSize(openWarCommuniqueBtn, 23);
    GUI.ButtonSetTextColor(openWarCommuniqueBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(openWarCommuniqueBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(openWarCommuniqueBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(openWarCommuniqueBtn, UCE.PointerClick, "TrackUI", "OnOpenWarCommuniqueBtnClick");

    local cutLine = GUI.ImageCreate(bg, "cutLine", "1800300040", 0, 160, false, 230, 2)
    SetSameAnchorAndPivot(cutLine, UILayout.Top)

    local ContributionDegree = GUI.CreateStatic(cutLine, "ContributionDegree", "个人贡献度：", 0, 5, 160, 40)
    SetSameAnchorAndPivot(ContributionDegree, UILayout.TopLeft)
    GUI.StaticSetFontSize(ContributionDegree, 24)
    GUI.SetColor(ContributionDegree, YellowColor)

    local ContributionDegreeValue = GUI.CreateStatic(cutLine,  "ContributionDegreeValue", "99999", 140, 5, 160, 40)
    SetSameAnchorAndPivot(ContributionDegreeValue, UILayout.TopLeft)
    GUI.StaticSetFontSize(ContributionDegreeValue, 24)
    GUI.SetColor(ContributionDegreeValue, WhiteColor)

    local item = GUI.ItemCtrlCreate(bg,"item",QualityRes[2],0,-80,90,90,false,"system",false)
    SetSameAnchorAndPivot(item, UILayout.Bottom)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,75,75)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "TrackUI", "OnContributionDegreeItemClick")


    local pnSellout = GUI.ImageCreate(bg, "pnSellout", "1801100010", 0, -80, false, 200, 80)
    SetSameAnchorAndPivot(pnSellout, UILayout.Bottom)
    GUI.SetVisible(pnSellout, false)

    local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "贡献度无法获得奖励", 0, 0, 200, 50, "system", true)
    SetAnchorAndPivot(txtSellout, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtSellout, 20)
    GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
    GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleCenter)


    --退出
    local _ExitBtn = GUI.ButtonCreate(bg, "ExitBtn", "1800602020", 65, 330, Transition.ColorTint, "退出")
    SetAnchorAndPivot(_ExitBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_ExitBtn, 26)
    GUI.ButtonSetTextColor(_ExitBtn, Brown4Color)
    GUI.SetIsOutLine(_ExitBtn, true)
    GUI.RegisterUIEvent(_ExitBtn, UCE.PointerClick, "TrackUI", "OnExitCrossServerWarfare")

end

--关闭其他的界面
function TrackUI.CloseOtherUI()
    test("关闭其他界面")

    local wnd = GUI.GetWnd("MainUI")

    local leftBg = GUI.GetChild(wnd,"leftBg",false)
    local leftBtn = GUI.GetChild(wnd,"leftBtn",false)

    local leftBg_Top = GUI.GetChild(leftBg,"leftBg_Top",false)

    local vis = GUI.GetData(leftBg_Top, "visiable")
    if vis ~= "true" then
        MainUI.RightBtnDoTweenScale(GUI.GetGuid(leftBtn))
    end

    local rightBtn = GUI.GetChild(wnd,"rightBtn",false)
    local rightBg = GUI.GetChild(wnd,"rightBg",false)

    local vis = GUI.GetData(rightBg, "visiable")
    if vis ~= "true" then
        MainUI.RightBtnDoTweenScale(GUI.GetGuid(rightBtn))
    end



    local willOpenActivityGroup = GUI.GetChild(wnd,"willOpenActivityGroup")

    if GUI.GetVisible(willOpenActivityGroup) then
        GUI.SetVisible(willOpenActivityGroup,false)
    end


    local functionPreviewGroup = GUI.GetChild(wnd,"functionPreviewGroup")

    if GUI.GetVisible(functionPreviewGroup) then
        GUI.SetVisible(functionPreviewGroup,false)
    end

end

function TrackUI.OpenOtherUI()

    local wnd = GUI.GetWnd("MainUI")

    local leftBg = GUI.GetChild(wnd,"leftBg",false)
    local leftBtn = GUI.GetChild(wnd,"leftBtn",false)

    local leftBg_Top = GUI.GetChild(leftBg,"leftBg_Top",false)

    local vis = GUI.GetData(leftBg_Top, "visiable")
    if vis == "true" then
        MainUI.RightBtnDoTweenScale(GUI.GetGuid(leftBtn))
    end

    local rightBtn = GUI.GetChild(wnd,"rightBtn",false)
    local rightBg = GUI.GetChild(wnd,"rightBg",false)


    local vis = GUI.GetData(rightBg, "visiable")
    if vis == "true" then
        MainUI.RightBtnDoTweenScale(GUI.GetGuid(rightBtn))
    end


    local willOpenActivityGroup = GUI.GetChild(wnd,"willOpenActivityGroup")

    if GUI.GetVisible(willOpenActivityGroup) == false then
        GUI.SetVisible(willOpenActivityGroup,true)
    end


    local functionPreviewGroup = GUI.GetChild(wnd,"functionPreviewGroup")

    if GUI.GetVisible(functionPreviewGroup) == false then
        GUI.SetVisible(functionPreviewGroup,true)
    end

    local CrossServerWarfareGroup = GUI.GetChild(wnd,"CrossServerWarfareGroup")
    GUI.Destroy(CrossServerWarfareGroup)

end


function TrackUI.OnOpenWarCommuniqueBtnClick()
    test("打开战报")

    GUI.OpenWnd("CrossServerWarfareBattlefieldReportUI")

end


function TrackUI.OnOpenMapBtnClick()
    test("打开地图")
    GUI.OpenWnd("MapUI",1)

end

function TrackUI.OnContributionDegreeItemClick(guid)
    test("个人贡献奖励item点击事件")

    local crossServerWarfareBack = _gt.GetUI("crossServerWarfareBack")
    local bg = GUI.GetChild(crossServerWarfareBack,"CrossServerWarfareBg",false)

    local txt = ""

    test("MainUI.Act_CrossServerData.PlayerValReward",inspect(MainUI.Act_CrossServerData.PlayerValReward))
    test("TrackUI.Act_CrossServerValOnesListItemData",inspect(TrackUI.Act_CrossServerValOnesListItemData))

    local itemList = TrackUI.Act_CrossServerValOnesListItemData.ItemList

    for i = 1, #itemList,3 do

        txt = txt .. TrackUI.GetContributionDegreeItemTipsTxt(itemList[i],itemList[i+1],itemList[i+2])

        if i + 2 ~= #itemList then
            txt = txt .. ","
        end

    end

    test("txt",txt)

    local Text = "活动结束后可获得如下奖励：<color=#ddd221ff>"..txt.."</color>。"

    local TipsBg = GUI.GetChild(bg,"TipsBg",false)

    if TipsBg == nil then


        TipsBg = GUI.TipsCreate(bg, "TipsBg", 0, 30, 260, 0)
        SetAnchorAndPivot(TipsBg, UIAnchor.Left, UIAroundPivot.Right)
        GUI.SetIsRemoveWhenClick(TipsBg, true)
        GUI.SetVisible(GUI.TipsGetItemIcon(TipsBg),false)

        local TipsText = GUI.CreateStatic(TipsBg,"TipsText",Text,0,0,220,25,"system", true)
        GUI.StaticSetFontSize(TipsText,20)
        SetSameAnchorAndPivot(TipsText, UILayout.Center)
        GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
        local desPreferHeight = GUI.StaticGetLabelPreferHeight(TipsText)
        GUI.SetHeight(TipsText,desPreferHeight)

        GUI.SetHeight(TipsBg,desPreferHeight + 40)



    end

    local panel = _gt.GetUI("panel")

    local scrBg = GUI.GetChild(panel,"scrBg",false)

    if scrBg == nil then

        scrBg = GUI.ImageCreate(panel, "scrBg", "1800001060", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        SetAnchorAndPivot(scrBg, UIAnchor.Center, UIAroundPivot.Center)
        scrBg:RegisterEvent(UCE.PointerClick)
        GUI.SetIsRaycastTarget(scrBg, true)
        GUI.RegisterUIEvent(scrBg, UCE.PointerClick, "TrackUI", "OnContributionDegreeItemTipsBgClick")

    end

end

function TrackUI.OnContributionDegreeItemTipsBgClick(guid)

    local item = GUI.GetByGuid(guid)
    GUI.Destroy(item)

    local crossServerWarfareBack = _gt.GetUI("crossServerWarfareBack")
    local bg = GUI.GetChild(crossServerWarfareBack,"CrossServerWarfareBg",false)
    local TipsBg = GUI.GetChild(bg,"TipsBg",false)
    GUI.Destroy(TipsBg)

end

function TrackUI.GetContributionDegreeItemTipsTxt(Name,Num,IsBounds)

    local isBoundTxt = ""

    if IsBounds == 1 then

        isBoundTxt = "(绑定)"

    end

    return Name..isBoundTxt.."*"..Num

end


function TrackUI.OnWayFindingBtnClick(guid)
    test("寻找阵营按钮点击事件")
    local btn = GUI.GetByGuid(guid)

end

function TrackUI.OnExitCrossServerWarfare()

    CL.SendNotify(NOTIFY.SubmitForm, "FormAct_CrossServer", "ToActiveQuit")

end



------------------------------------------------------------------End  跨服战  End------------------------------------------------------


-----------------------------------------------------------------Start 帮派密谋 Start---------------------------------------------------------

--服务器调用切换
function TrackUI.SwitchQuestOrGangConspiracy6Node(showQuest)

    test("服务器调用切换")

    --帮派密谋按钮
    local TitleBack = _gt.GetUI("TitleBack")

    local TrackNode = _gt.GetUI("TrackNode")

    local gangConspiracyBtn = GUI.GetChild(TitleBack,"gangConspiracyBtn",false)

    local gangConspiracyTxt = GUI.GetChild(TitleBack,"gangConspiracyTxt",false)

    local gangConspiracyBack = GUI.GetChild(TrackNode,"gangConspiracyBack",false)

    if gangConspiracyBtn == nil then

        gangConspiracyBtn = GUI.ButtonCreate(TitleBack, "gangConspiracyBtn", "1800202260", 55, 0, Transition.ColorTint)
        _gt.BindName(gangConspiracyBtn, "gangConspiracyBtn")
        SetSameAnchorAndPivot(gangConspiracyBtn, UILayout.Center)
        GUI.SetVisible(gangConspiracyBtn, false)
        GUI.RegisterUIEvent(gangConspiracyBtn, UCE.PointerClick, "TrackUI", "OnSwitchGangConspiracyBtn")

    end

    if gangConspiracyTxt == nil then

        --密谋标题
        gangConspiracyTxt = GUI.CreateStatic(TitleBack, "gangConspiracyTxt", "帮派密谋", 55, 2, 100, 35)
        _gt.BindName(gangConspiracyTxt, "gangConspiracyTxt")
        SetSameAnchorAndPivot(gangConspiracyTxt, UILayout.Center)
        GUI.StaticSetFontSize(gangConspiracyTxt, UIDefine.FontSizeL)
        GUI.StaticSetAlignment(gangConspiracyTxt, TextAnchor.MiddleCenter)
        GUI.SetVisible(gangConspiracyTxt, false)

    end

    if gangConspiracyBack == nil then

        -- 帮派密谋UI
        gangConspiracyBack = GUI.ImageCreate(TrackNode, "gangConspiracyBack", "1800200010", -223, 24, false, 254, 390)
        _gt.BindName(gangConspiracyBack, "gangConspiracyBack")
        SetSameAnchorAndPivot(gangConspiracyBack, UILayout.TopLeft)
        GUI.SetVisible(gangConspiracyBack, true)
        GUI.SetIsRaycastTarget(gangConspiracyBack, true)
        GUI.SetColor(gangConspiracyBack, UIDefine.Transparent)
        TrackUI.OnShowGangConspiracy(gangConspiracyBack)

    end
    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 10)

    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 13)


end

--帮派密谋服务器回调刷新
function TrackUI.RefreshGangConspiracyData()

    test("帮派密谋服务器回调刷新")

    GangConspiracyItemState = 0
    GangConspiracyDetailsTxt = ""

    if TrackUI.GuildConspireData ~= nil then


        test("TrackUI.GuildConspireData",inspect(TrackUI.GuildConspireData))

        --帮派密谋数据刷新
        TrackUI.RefreshGangConspiracyItemData(TrackUI.GuildConspireData)

    end

end

--帮派密谋服务器回调关闭
function TrackUI.ExitGangConspiracy()

    test("帮派密谋服务器回调关闭")
    local _TitleBack = _gt.GetUI("TitleBack")
    local IsShow = GUI.GetVisible(_TitleBack) == false

    if IsShow then

        TrackUI.OnClickTrackNode()

    end

    TrackUI.SwitchQuestOrGangConspiracy6Node(1)



    TrackUI.StopGangConspiracyTimer()

    local wnd = GUI.GetWnd("GuideArrowUI")

    if wnd then

        GuideArrowUI.OnExit()

    end

end

--帮派密谋数据刷新
function TrackUI.RefreshGangConspiracyItemData(tableData)

    test("帮派密谋数据刷新")

    local gangConspiracyBack = _gt.GetUI("gangConspiracyBack")

    local GangConspiracyBg = GUI.GetChild(gangConspiracyBack,"GangConspiracyBg",false)


    local TipsText = GUI.GetChild(GangConspiracyBg,"TipsTextLoop",false)

    test("tableData.Msg",tableData.Msg)
    GangConspiracyDetailsTxt = tableData.Msg

    GUI.LoopScrollRectSetTotalCount(TipsText, 1)
    GUI.LoopScrollRectRefreshCells(TipsText)




    local taskTitle = GUI.GetChild(GangConspiracyBg,"taskTitle",false)

    local timeTitle = GUI.GetChild(taskTitle,"timeTitle",false)

    local timeTxt = GUI.GetChild(timeTitle,"timeTxt",false)

    --当前服务器时间戳
    local nowTime = CL.GetServerTickCount()

    GangConspiracyTime = 0

    GangConspiracyTime = tableData.TaskDeadline - nowTime

    if GangConspiracyTime > 0 then

        test("GangConspiracyTime",GangConspiracyTime)

        local time = UIDefine.LeftTimeFormatEx2(GangConspiracyTime,1)
        GUI.StaticSetText(timeTxt,time)

        TrackUI.StartGangConspiracyTimer()

    else

        GUI.StaticSetText(timeTxt,"00:00:00")

    end

    local cutLine = GUI.GetChild(timeTitle,"cutLine",false)
    local item = GUI.GetChild(cutLine,"item",false)

    if tableData.TaskItem ~= nil then

        test("tableData.TaskItem",inspect(tableData.TaskItem))

        if next(tableData.TaskItem) then


            if tableData.TaskItem.ItemTips ~= nil then

                GangConspiracyTxt =tableData.TaskItem.ItemTips
                GUI.RegisterUIEvent(item, UCE.PointerClick, "TrackUI", "OnGangConspiracyItemClick")

            else

                GUI.UnRegisterUIEvent(item, UCE.PointerClick, "TrackUI", "OnGangConspiracyItemClick")

            end

            if tableData.TaskItem.Icon == nil then

                GUI.SetVisible(cutLine,false)

                GUI.SetVisible(item,false)


            else

                GUI.SetVisible(cutLine,true)

                GUI.SetVisible(item,true)

                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, tableData.TaskItem.Icon)

                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, QualityRes[tonumber(tableData.TaskItem.Grade)])

            end

        else


            GUI.SetVisible(cutLine,false)

            GUI.SetVisible(item,false)



        end

    else

        GUI.SetVisible(cutLine,false)

        GUI.SetVisible(item,false)

    end

    if TrackUI.GuildConspireTrackPosData ~= nil then

        test("TrackUI.GuildConspireTrackPosData",inspect(TrackUI.GuildConspireTrackPosData))

        local tableTrackData = {}
        tableTrackData.TrackPos = TrackUI.GuildConspireTrackPosData
        tableTrackData.ShowRange = tableData.TaskItem.ShowRange

        local json = jsonUtil.encode(tableTrackData);

        GlobalProcessing.OutOfFunction = TrackUI.SetConspiracyEffectState
        GUI.OpenWnd("GuideArrowUI",json)

    end



end


--计时器启动
function TrackUI.StartGangConspiracyTimer()
    test("计时器启动")
    local fun = function()
        TrackUI.TimerGangConspiracyCallBack()
    end

    TrackUI.StopGangConspiracyTimer()
    TrackUI.RefreshGangConspiracyTimer = Timer.New(fun, 1, GangConspiracyTime)
    TrackUI.RefreshGangConspiracyTimer:Start()
end

--计时器停止
function TrackUI.StopGangConspiracyTimer()
    if TrackUI.RefreshGangConspiracyTimer ~= nil then
        test("计时器关闭")
        TrackUI.RefreshGangConspiracyTimer:Stop()
        TrackUI.RefreshGangConspiracyTimer = nil
    end
end

--帮派密谋计时器回调
function TrackUI.TimerGangConspiracyCallBack()

    test("帮派密谋计时器回调")

    local gangConspiracyBack = _gt.GetUI("gangConspiracyBack")

    local GangConspiracyBg = GUI.GetChild(gangConspiracyBack,"GangConspiracyBg",false)

    local taskTitle = GUI.GetChild(GangConspiracyBg,"taskTitle",false)

    local timeTitle = GUI.GetChild(taskTitle,"timeTitle",false)
    local timeTxt = GUI.GetChild(timeTitle,"timeTxt",false)

    GangConspiracyTime = GangConspiracyTime - 1
    local time = UIDefine.LeftTimeFormatEx2(GangConspiracyTime,1)
    GUI.StaticSetText(timeTxt,time)

end

--帮派密谋UI创建
function TrackUI.OnShowGangConspiracy(parent)

    test("帮派密谋UI创建")

    local bg = GUI.ImageCreate(parent, "GangConspiracyBg", "1800200010", 0, 0, false, 254, 392)
    SetSameAnchorAndPivot(bg, UILayout.TopLeft)

    local taskTitle = GUI.CreateStatic(bg, "taskTitle", "任务详情：", 10, 5, 160, 40)
    SetAnchorAndPivot(taskTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(taskTitle, 24)
    GUI.SetColor(taskTitle, YellowColor)
    _gt.BindName(taskTitle, "taskTitle")

    local TipsTextLoop = GUI.LoopListCreate(
            bg,
            "TipsTextLoop",
            10,
            -95,
            234,
            120,
            "TrackUI",
            "CreateTxtLoop",
            "TrackUI",
            "RefreshTxtLoop",
            0,
            false,
            Vector2.New(234, 120),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft
    )
    _gt.BindName(TipsTextLoop, "TipsTextLoop")
    SetSameAnchorAndPivot(TipsTextLoop, UILayout.Center)
    GUI.ScrollRectSetChildSpacing(TipsTextLoop, Vector2.New(0, 0))
    TipsTextLoop:RegisterEvent(UCE.PointerClick)

    --剩余时间
    local timeTitle = GUI.CreateStatic(taskTitle, "timeTitle", "剩余时间：", 0, 160, 160, 40)
    SetSameAnchorAndPivot(timeTitle, UILayout.BottomLeft)
    GUI.StaticSetFontSize(timeTitle, 24)
    GUI.SetColor(timeTitle, GreenColor)

    --倒计时
    local timeTxt = GUI.CreateStatic(timeTitle, "timeTxt", "30分钟40秒", 110, 0, 150, 40)
    SetSameAnchorAndPivot(timeTxt, UILayout.Left)
    GUI.StaticSetFontSize(timeTxt, 22)
    GUI.SetColor(timeTxt, WhiteColor)

    local cutLine = GUI.ImageCreate(timeTitle, "cutLine", "1800300040", 0, -10, false, 230, 2)
    SetSameAnchorAndPivot(cutLine, UILayout.BottomLeft)

    local item = GUI.ItemCtrlCreate(cutLine,"item",QualityRes[1],70,-105,90,90,false,"system",false)
    SetSameAnchorAndPivot(item, UILayout.BottomLeft)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,80,80)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "TrackUI", "OnGangConspiracyItemClick")

    local effect = GUI.SpriteFrameCreate(item, "effect", "", 0, 2, false, 130, 130)
    SetSameAnchorAndPivot(effect, UILayout.Center)
    GUI.SetFrameId(effect, "3407700000")
    GUI.SetScale(effect, Vector3.New(0.9, 0.9, 0.9))
    GUI.SetVisible(effect,false)
    GUI.Stop(effect)

    --退出
    local _ExitBtn = GUI.ButtonCreate(bg, "ExitBtn", "1800602020", 65, 330, Transition.ColorTint, "逃跑")
    SetAnchorAndPivot(_ExitBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_ExitBtn, 26)
    GUI.ButtonSetTextColor(_ExitBtn, Brown4Color)
    GUI.SetIsOutLine(_ExitBtn, true)
    GUI.RegisterUIEvent(_ExitBtn, UCE.PointerClick, "TrackUI", "OnExitConspiracy")

end

function TrackUI.CreateTxtLoop()
    local TipsTextLoop = _gt.GetUI("TipsTextLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(TipsTextLoop) + 1
    local chatBoxBg = GUI.LoopListChatCreate(TipsTextLoop, "chatBoxBg"..index, "1800400200", 0, 10)
    SetSameAnchorAndPivot(chatBoxBg, UILayout.TopLeft)
    GUI.LoopListChatSetPreferredWidth(chatBoxBg, 234)
    GUI.SetColor(chatBoxBg, Color.New(1, 1, 1, 0))

    local msgTxt = GUI.RichEditCreate(chatBoxBg,"msgTxt","",0,0,234,120,"system", true)
    SetSameAnchorAndPivot(msgTxt, UILayout.TopLeft)
    GUI.StaticSetFontSize(msgTxt, 22)
    GUI.SetColor(msgTxt, WhiteColor)

    return chatBoxBg
end

function TrackUI.RefreshTxtLoop(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local chatBoxBg = GUI.GetByGuid(guid)

    local msgTxt = GUI.GetChild(chatBoxBg,"msgTxt",false)

    GUI.StaticSetText(msgTxt,GangConspiracyDetailsTxt)

    local desPreferHeight = GUI.StaticGetLabelPreferHeight(msgTxt)

    GUI.LoopListChatSetPreferredHeight(chatBoxBg, desPreferHeight + 10)
    GUI.SetHeight(msgTxt,desPreferHeight + 10)

end

function TrackUI.OnGangConspiracyItemClick()

    if GangConspiracyItemState == 0 then

        local gangConspiracyBack = _gt.GetUI("gangConspiracyBack")

        local GangConspiracyBg = GUI.GetChild(gangConspiracyBack,"GangConspiracyBg",false)

        local TipsBg = GUI.TipsCreate(GangConspiracyBg, "Tips", -178, -132, 300, 0)
        SetSameAnchorAndPivot(TipsBg, UILayout.BottomRight)
        GUI.SetIsRemoveWhenClick(TipsBg, true)
        GUI.SetVisible(GUI.TipsGetItemIcon(TipsBg),false)

        local TipsText = GUI.CreateStatic(TipsBg,"TipsText",GangConspiracyTxt,0,0,260,26,"system", true)
        GUI.StaticSetFontSize(TipsText,22)
        SetSameAnchorAndPivot(TipsText, UILayout.Center)
        GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleCenter)
        local desPreferHeight = GUI.StaticGetLabelPreferHeight(TipsText)
        GUI.SetHeight(TipsText,desPreferHeight)

    else

        CL.SendNotify(NOTIFY.SubmitForm, "FormGuildConspire", "ExecuteTask")

    end



end

--控制高亮动画是否显示
function TrackUI.SetConspiracyEffectState(boolean)

    test("控制高亮动画是否显示")

    local gangConspiracyBack = _gt.GetUI("gangConspiracyBack")

    local GangConspiracyBg = GUI.GetChild(gangConspiracyBack,"GangConspiracyBg",false)

    local taskTitle = GUI.GetChild(GangConspiracyBg,"taskTitle",false)

    local timeTitle = GUI.GetChild(taskTitle,"timeTitle",false)

    local cutLine = GUI.GetChild(timeTitle,"cutLine",false)

    local item = GUI.GetChild(cutLine,"item",false)


    local effect = GUI.GetChild(item,"effect",false)

    if boolean then

        GUI.Play(effect)
        GUI.SetVisible(effect,true)
        GangConspiracyItemState = 1

    else

        GUI.SetVisible(effect,false)
        GUI.Stop(effect)

        GangConspiracyItemState = 0

    end

end

function TrackUI.OnExitConspiracy()

    CL.SendNotify(NOTIFY.SubmitForm, "FormGuildConspire", "QuitTask")

end

----------------------------------------------------------------------End 帮派密谋 End------------------------------------------------------

function TrackUI.SwitchQuestorClimbTower6Node(showQuest)
    TrackUI.QuestOrFightInfoMode = (showQuest and 0 or 6)
    TrackUI.OnSwitchTrackPanel(showQuest and 1 or 9)
    if TrackUI.QuestOrFightInfoMode == 6 then
        local _Countdown = _gt.GetUI("integralTower_Countdown")
        GUI.SetVisible(_Countdown,true)
        if TrackUI.integralTowerTimer == nil then
            TrackUI.integralTowerTimer = Timer.New(TrackUI.integralTowerTimerFunc,1,-1,true)
        else
            TrackUI.integralTowerTimer:Stop()
            TrackUI.integralTowerTimer:Reset(TrackUI.integralTowerTimerFunc,1,-1)
        end
    else
        TrackUI.integralTowerTimer:Stop()
        TrackUI.integralTowerTimer = nil

    end
end

function TrackUI.OnCustomDataUpdate(type, key, val)
    if key == "Act_Chikings_Hp" then
        local Hp_Max = TrackUI.Act_Chickings_Attr.Hp_Max
        TrackUI.RefreshBattleValue(tonumber(tostring(val)), Hp_Max)
    elseif key == "Act_Chickings_Bless" then
        TrackUI.RefreshBattleBuffValue(tonumber(tostring(val)))
    end
end

function TrackUI.OnFightInfoTimer()
    if TrackUI.QuestOrFightInfoMode == 1 then
        if TrackUI.FightStartTime ~= nil then
            local bShow = TrackUI.FightStartTime ~= 0 and true or false
            local txt = _gt.GetUI("timeTitle")
            if txt then
                GUI.SetVisible(txt, bShow)
            end
            txt = _gt.GetUI("time")
            if txt then
                GUI.SetVisible(txt, bShow)
            end
            txt = _gt.GetUI("timeFinish")
            if txt then
                GUI.SetVisible(txt, not bShow)
            end
            if bShow then
                local leftTime = TrackUI.FightStartTime - CL.GetServerTickCount()
                leftTime = math.max(leftTime, 0)
                local time = _gt.GetUI("time")
                if time then
                    GUI.StaticSetText(time, os.date("%M:%S", leftTime))
                end
            end
        end
    end
end

function TrackUI.RefreshFightInfo()
    --我的积分
    local txt = _gt.GetUI("myScore")
    if txt then
        GUI.StaticSetText(txt, tostring(CL.GetIntCustomData("ACTIVITY_ShuiLuDaHui_Pionts")))
    end
    txt = _gt.GetUI("myRank")
    if txt then
        GUI.StaticSetText(txt, TrackUI.MyRank ~= nil and tostring(TrackUI.MyRank) or "0" )
    end
    txt = _gt.GetUI("myGroupID")
    if txt then
        GUI.StaticSetText(txt, TrackUI.TeamIndex  ~= nil and tostring(TrackUI.TeamIndex) or "0" )
    end
    local scoreVals = {[1]={vic=TrackUI.Team_1_Victories, point=TrackUI.Team_1_FightPoint, idx=1},
                       [2]={vic=TrackUI.Team_2_Victories, point=TrackUI.Team_2_FightPoint, idx=2},
                       [3]={vic=TrackUI.Team_3_Victories, point=TrackUI.Team_3_FightPoint, idx=3},
                       [4]={vic=TrackUI.Team_4_Victories, point=TrackUI.Team_4_FightPoint, idx=4}}
    --对数据排序:从大到小
    for i = 1, 4 do
        local maxIndex = -1
        local maxPoint = -1
        for j = i, 4 do
            if maxIndex == -1 then
                maxIndex = j
                maxPoint = scoreVals[maxIndex].point
            else
                if scoreVals[j].point > maxPoint then
                    maxIndex = j
                    maxPoint = scoreVals[maxIndex].point
                end
            end
        end
        if maxIndex ~= i then
            local temp = scoreVals[i]
            scoreVals[i] = scoreVals[maxIndex]
            scoreVals[maxIndex] = temp
        end
    end

    for i = 1, 4 do
        txt = _gt.GetUI("val_"..i.."_1")
        if txt then
            GUI.StaticSetText(txt, scoreVals[i].idx ~= nil and tostring(scoreVals[i].idx) or "0" )
            GUI.SetColor(txt, scoreVals[i].idx ~= nil and TrackUI.TeamIndex==scoreVals[i].idx and UIDefine.GreenColor or UIDefine.WhiteColor)
        end
        txt = _gt.GetUI("val_"..i.."_2")
        if txt then
            GUI.StaticSetText(txt, scoreVals[i].vic ~= nil and tostring(scoreVals[i].vic) or "0" )
            GUI.SetColor(txt, scoreVals[i].idx ~= nil and TrackUI.TeamIndex==scoreVals[i].idx and UIDefine.GreenColor or UIDefine.WhiteColor)
        end
        txt = _gt.GetUI("val_"..i.."_3")
        if txt then
            GUI.StaticSetText(txt, scoreVals[i].point ~= nil and tostring(scoreVals[i].point) or "0" )
            GUI.SetColor(txt, scoreVals[i].idx ~= nil and TrackUI.TeamIndex==scoreVals[i].idx and UIDefine.GreenColor or UIDefine.WhiteColor)
        end
    end
end

function TrackUI.OnShowFightInfo2(parent)
    local img = _gt.GetUI("back2")
    if img == nil then
        local back2 = GUI.ImageCreate(parent, "back2", "1800200010", 0, 101, false, 254, 100)
        _gt.BindName(back2, "back2")
        SetSameAnchorAndPivot(back2, UILayout.TopLeft)

        local back3 = GUI.ImageCreate(parent, "back3", "1800200010", 0, 202, false, 254, 190)
        _gt.BindName(back3, "back3")
        SetSameAnchorAndPivot(back3, UILayout.TopLeft)

        local titlePos = {4,104,206}
        local count = #titlePos
        --背景
        local titleback = GUI.ImageCreate(parent, "titleback", "1800601270", 210, titlePos[1], false, 210, 36)
        SetSameAnchorAndPivot(titleback, UILayout.TopLeft)
        GUI.SetEulerAngles(titleback, Vector3.New(0,180,0))
        GUI.SetColor(titleback, Color.New(1,1,1,0.7))

        local titleback = GUI.ImageCreate(parent, "titleback", "1800601280", 0, titlePos[2], false, 210, 36)
        SetSameAnchorAndPivot(titleback, UILayout.TopLeft)
        GUI.SetColor(titleback, Color.New(1,1,1,0.7))

        local titleback = GUI.ImageCreate(parent, "titleback", "1800601280", 0, titlePos[3], false, 210, 36)
        SetSameAnchorAndPivot(titleback, UILayout.TopLeft)
        GUI.SetColor(titleback, Color.New(0, 1, 0, 0.7))

        for i = 1, count do
            local txt = GUI.CreateStatic(parent, "txt", "个人战况", 28, titlePos[i], 135, 35, "system", false)
            _gt.BindName(txt, "fightInfo2Name"..i)
            SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleLeft)
        end

        local name = {"#NPCLINK<STR:门神,NPCID:19902>#血量","战场积分","#NPCLINK<STR:门神,NPCID:19901>#血量","战场积分","个人积分","个人战绩"}
        local posy = {44,70,144,170,249,279}
        local count = #name
        for i = 1, count do
            if i==1 or i ==3 then
                local txt = GUI.RichEditCreate(parent, "txt", name[i], 40, posy[i], 135, 28)
                SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleLeft)
                GUI.RegisterUIEvent(txt, UCE.PointerClick, "TrackUI", "OnClickFightInfo2Mengshen")
            else
                local txt = GUI.CreateStatic(parent, "txt", name[i], 40, posy[i], 135, 28, "system", true)
                SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleLeft)
            end

            local txt = GUI.CreateStatic(parent,"score"..i, "0", 78, posy[i], 250, 28, "system", false)
            _gt.BindName(txt, "fightInfo2Score"..i)
            SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeS, i~=3 and UIDefine.GreenStdColor or UIDefine.RedColor, TextAnchor.MiddleCenter)
        end

        local txt = GUI.CreateStatic(parent, "leftTime0", "", 0, 310, 255, 28, "system", true)
        _gt.BindName(txt, "leftTime0")
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(parent, "leftTime1", "", 43, 310, 255, 28, "system", true)
        _gt.BindName(txt, "leftTime1")
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeS, UIDefine.GreenStdColor, TextAnchor.MiddleCenter)

        --详细信息
        local FactionFightDetailInfoBtn = GUI.ButtonCreate(parent,"FactionFightDetailInfoBtn", "1800402110", -58, 313,  Transition.ColorTint, "详细信息", 106, 36,false)
        SetAnchorAndPivot(FactionFightDetailInfoBtn, UIAnchor.Center, UIAroundPivot.Center)
        GUI.ButtonSetTextFontSize(FactionFightDetailInfoBtn, UIDefine.FontSizeS)
        GUI.ButtonSetTextColor(FactionFightDetailInfoBtn, UIDefine.Brown3Color)
        GUI.RegisterUIEvent(FactionFightDetailInfoBtn, UCE.PointerClick, "TrackUI", "OnFactionFightDetailInfoBtn")

        --退出战场
        local ExitFactionFightBtn = GUI.ButtonCreate(parent,"ExitFactionFightBtn", "1800402110", 58, 313,  Transition.ColorTint, "退出战场", 106, 36,false)
        _gt.BindName(ExitFactionFightBtn, "ExitFactionFightBtn")
        SetAnchorAndPivot(ExitFactionFightBtn, UIAnchor.Center, UIAroundPivot.Center)
        GUI.ButtonSetTextFontSize(ExitFactionFightBtn, UIDefine.FontSizeS)
        GUI.ButtonSetTextColor(ExitFactionFightBtn, UIDefine.Brown3Color)
        GUI.RegisterUIEvent(ExitFactionFightBtn, UCE.PointerClick, "TrackUI", "OnExitFactionFightBtn")
    end
end

function TrackUI.OnClickFightInfo2Mengshen(guid)
    local _Content = GUI.GetByGuid(guid)
    --得到目标信息
    local ClickInfo = ""
    local ContentInfos = LD.GetRichTextUrlInfo(_Content)
    if ContentInfos ~= nil and ContentInfos.Length > 0 then
        ClickInfo = ContentInfos[ContentInfos.Length - 1]
    end

    --执行寻路
    if ClickInfo ~= "" then
        LD.OnParsePathFinding(ClickInfo)
    end
end

function TrackUI.OnFactionFightDetailInfoBtn()
    GUI.OpenWnd("BattleResultUI")
end

function TrackUI.OnExitFactionFightBtn()
    CL.SendNotify(NOTIFY.SubmitForm, "FormActivity", "GuildBattle_LeaveField")
end

function TrackUI.UpdateFightInfo2Data()
    local factionName = {TrackUI.FactionName1, TrackUI.FactionName2}
    local scoreData = {TrackUI.Team1HP, TrackUI.Team1Score, TrackUI.Team2HP, TrackUI.Team2Score, TrackUI.TeamSelfScore, TrackUI.TeamSelfRecord}
    --设置帮派名字
    for i = 1, 2 do
        local name = _gt.GetUI("fightInfo2Name"..i)
        if name then
            GUI.StaticSetText(name, tostring(factionName[i]))
        end
    end

    for i = 1, 6 do
        local score = _gt.GetUI("fightInfo2Score"..i)
        if score then
            if i==1 or i==3 then
                GUI.StaticSetText(score, tostring(scoreData[i]/100).."%")
                GUI.SetColor(score, Color.New((10000-scoreData[i])/10000,scoreData[i]/10000,0,1))
            else
                GUI.StaticSetText(score, tostring(scoreData[i]))
            end
        end
    end

    local leftTime0 = _gt.GetUI("leftTime0")
    local leftTime1 = _gt.GetUI("leftTime1")
    if leftTime0 and leftTime1 then
        if TrackUI.TimePoint == 0 or TrackUI.TimePoint == nil then
            GUI.StaticSetText(leftTime0, "<color=red>已结束</color>")
            GUI.StaticSetText(leftTime1, "")
            if TrackUI.FightLeftTimer then
                TrackUI.FightLeftTimer:Stop()
                TrackUI.FightLeftTimer = nil
            end
        else
            GUI.StaticSetText(leftTime0, "剩余时间            ")
            if TrackUI.FightLeftTimer == nil then
                TrackUI.FightLeftTimer = Timer.New(TrackUI.OnFightLeftTimer, 1, -1)
                TrackUI.FightLeftTimer:Start()
            end
        end
    end
end

function TrackUI.OnShowFightInfo3(parent)
    local ActTitel = GUI.CreateStatic(parent, "ActTitel", "天下第一比武大会", 16, 10, 300, 30, "system", false)
    _gt.BindName(ActTitel, "ActTitel")
    SetAnchorAndPivot(ActTitel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(ActTitel, UIDefine.FontSizeM)
    GUI.SetColor(ActTitel, UIDefine.GreenStdColor)
	
	local NumTitel1 = GUI.CreateStatic(parent, "NumTitel1", "本方人数：", 16, 50, 300, 30, "system", false)
    SetAnchorAndPivot(NumTitel1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(NumTitel1, UIDefine.FontSizeM)
    GUI.SetColor(NumTitel1, UIDefine.White2Color)   
	local Text = GUI.CreateStatic(parent, "NumText1", "", 80, 50, 150, 30, "system", false)
    SetAnchorAndPivot(Text, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
    GUI.SetColor(Text, UIDefine.GreenStdColor) 
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)	
	_gt.BindName(Text,"NumText1")
	
	local NumTitel2 = GUI.CreateStatic(parent, "NumTitel2", "敌方人数：", 16, 90, 300, 30, "system", false)
    SetAnchorAndPivot(NumTitel2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(NumTitel2, UIDefine.FontSizeM)
    GUI.SetColor(NumTitel2, UIDefine.White2Color)   
	local Text = GUI.CreateStatic(parent, "NumText2", "", 80, 90, 150, 30, "system", false)
    SetAnchorAndPivot(Text, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
    GUI.SetColor(Text, UIDefine.RedColor) 
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)		
	_gt.BindName(Text,"NumText2")
	
	local ScoreTitel = GUI.CreateStatic(parent, "ScoreTitel", "我的积分：", 16, 130, 300, 30, "system", false)
    SetAnchorAndPivot(ScoreTitel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(ScoreTitel, UIDefine.FontSizeM)
    GUI.SetColor(ScoreTitel, UIDefine.White2Color)   
	local Text = GUI.CreateStatic(parent, "ScoreText", "", 80, 130, 150, 30, "system", false)
    SetAnchorAndPivot(Text, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
    GUI.SetColor(Text, UIDefine.RedColor)  
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)	
	_gt.BindName(Text,"ScoreText")
	
	local ChanceTitel = GUI.CreateStatic(parent, "ChanceTitel", "剩余可失败次数：", 16, 170, 300, 30, "system", false)
    SetAnchorAndPivot(ChanceTitel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(ChanceTitel, UIDefine.FontSizeM)
    GUI.SetColor(ChanceTitel, UIDefine.White2Color)   
	local Text = GUI.CreateStatic(parent, "ChanceText", "", 140, 170, 150, 30, "system", false)
    SetAnchorAndPivot(Text, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
    GUI.SetColor(Text, UIDefine.RedColor)  
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)	
	_gt.BindName(Text,"ChanceText")
		
	local TimeTitel = GUI.CreateStatic(parent, "TimeTitel", "活动结束时间：", 16, 280, 300, 30, "system", false)
    SetAnchorAndPivot(TimeTitel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(TimeTitel, UIDefine.FontSizeM)
    GUI.SetColor(TimeTitel, UIDefine.White2Color)   
	_gt.BindName(TimeTitel,"TimeTitel")	
	GUI.SetVisible(TimeTitel, false)
	local WuDaoHui_Time = GUI.CreateStatic(parent, "WuDaoHui_Time", "52:19", 125, 280, 150, 30, "system", false)
    SetAnchorAndPivot(WuDaoHui_Time, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(WuDaoHui_Time, UIDefine.FontSizeM)
    GUI.SetColor(WuDaoHui_Time, UIDefine.White2Color)  
	GUI.StaticSetAlignment(WuDaoHui_Time, TextAnchor.MiddleCenter)	
	_gt.BindName(WuDaoHui_Time,"WuDaoHui_Time")	
	GUI.SetVisible(WuDaoHui_Time, false)
	
	local WarSituationBtn = GUI.ButtonCreate(parent, "WarSituationBtn", "1800402110", 60, 220, Transition.ColorTint, "战况查询", 120, 50, false);
	SetAnchorAndPivot(WarSituationBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(WarSituationBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(WarSituationBtn, UIDefine.FontSizeL)
	_gt.BindName(WarSituationBtn, "WarSituationBtn")
	GUI.RegisterUIEvent(WarSituationBtn, UCE.PointerClick, "TrackUI", "OnWarSituationBtnClick")
	
	local ExitWuDaoActBtn = GUI.ButtonCreate(parent, "ExitWuDaoActBtn", "1800402110", 60, 320, Transition.ColorTint, "退出活动", 120, 50, false);
	SetAnchorAndPivot(ExitWuDaoActBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(ExitWuDaoActBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(ExitWuDaoActBtn, UIDefine.FontSizeL)
	_gt.BindName(ExitWuDaoActBtn, "ExitWuDaoActBtn")
	GUI.RegisterUIEvent(ExitWuDaoActBtn, UCE.PointerClick, "TrackUI", "OnExitWuDaoActBtnClick")	
	
	
	
end

function TrackUI.UpdateFightInfo3Data()
	local inspect = require("inspect")
	--CDebug.LogError(inspect(TrackUI.RightMsgList))
	local TeamPlayNum = _gt.GetUI("NumText1")
	local EnemyTeamPlayerNum = _gt.GetUI("NumText2")
	local Score = _gt.GetUI("ScoreText")
	local SurplusDeaths = _gt.GetUI("ChanceText")
	local TimeTitel = _gt.GetUI("TimeTitel")
	local WuDaoHui_Time = _gt.GetUI("WuDaoHui_Time")
	if TrackUI.RightMsgList["TeamPlayerNum"] ~= nil then 
		GUI.StaticSetText(TeamPlayNum,TrackUI.RightMsgList["TeamPlayerNum"])
		GUI.StaticSetText(EnemyTeamPlayerNum,TrackUI.RightMsgList["EnemyTeamPlayerNum"])
		GUI.StaticSetText(Score,TrackUI.RightMsgList["PlayerScore"])
		GUI.StaticSetText(SurplusDeaths,TrackUI.RightMsgList["SurplusDeaths"])
			if TrackUI.RightMsgList["FightEndTime"] == 0 then
				GUI.SetVisible(TimeTitel, false)
				GUI.SetVisible(WuDaoHui_Time, false)
				if TrackUI.WuDaoFightTimer then
					TrackUI.WuDaoFightTimer:Reset(TrackUI.OnWuDaoFightTimerGo,1,-1)
					TrackUI.WuDaoFightTimer:Stop()
				end
			else
				GUI.SetVisible(TimeTitel, true)
				GUI.SetVisible(WuDaoHui_Time, true)
				TrackUI.WuDaoFightTimer = Timer.New(TrackUI.OnWuDaoFightTimerGo,1,-1)
				TrackUI.WuDaoFightTimer:Start()
			end
	else
		GUI.StaticSetText(TeamPlayNum,"0")
		GUI.StaticSetText(EnemyTeamPlayerNum,"0")
		GUI.StaticSetText(Score,"0")
		GUI.StaticSetText(SurplusDeaths,TrackUI.RightMsgList["SurplusDeaths"])	
		GUI.SetVisible(TimeTitel, false)
		GUI.SetVisible(WuDaoHui_Time, false)
		if TrackUI.WuDaoFightTimer then
			TrackUI.WuDaoFightTimer:Reset(TrackUI.OnWuDaoFightTimerGo,1,-1)
			TrackUI.WuDaoFightTimer:Stop()
		end
	end
end

function TrackUI.OnWuDaoFightTimerGo()
	local WuDaoHui_Time = _gt.GetUI("WuDaoHui_Time")
	local day,house,minute,second = GlobalUtils.Get_DHMS2_BySeconds(tonumber(TrackUI.RightMsgList["FightEndTime"]) - CL.GetServerTickCount())
	local Time = minute..":"..second
	GUI.StaticSetText(WuDaoHui_Time,Time)
	if minute == "00" and second == "00" then
		GUI.SetVisible(WuDaoHui_Time,false)
	end
end

function TrackUI.OnWarSituationBtnClick()
	GUI.OpenWnd("WuDaoHuiUI")
end

function TrackUI.OnExitWuDaoActBtnClick()
	 CL.SendNotify(NOTIFY.SubmitForm, "FormWuDaoHui", "ExitWuDaoHui")
end

function TrackUI.OnFightLeftTimer()
    local leftTime1 = _gt.GetUI("leftTime1")
    if leftTime1 and TrackUI.TimePoint ~= 0 and TrackUI.TimePoint ~= nil then
        local str, day, hour, minute, second = UIDefine.LeftTimeFormatEx(TrackUI.TimePoint)
        GUI.StaticSetText(leftTime1, string.format( "%02d:%02d", minute, second))
    end
end

function TrackUI.OnShowFightInfo4(parent)
    TrackUI.CreateBattleValueBar(parent,1)

    local debuffText = GUI.CreateStatic(parent, "debuffText", "异常状态：", 16, 70, 150, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(debuffText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)

    local debuffSrc = GUI.LoopScrollRectCreate(parent,"debuffSrc",16,100,220,70,"TrackUI","CreateDebuffItemIcon",
                        "TrackUI","RefreshDebuffItemIcon",0,true,Vector2.New(70, 70),1,UIAroundPivot.TopLeft,UIAnchor.TopLeft)
    SetSameAnchorAndPivot(debuffSrc, UILayout.TopLeft)
    GUI.ScrollRectSetChildSpacing(debuffSrc, Vector2.New(3, 3))
    _gt.BindName(debuffSrc, "debuffSrc")

    local remainingPlayerNumText = GUI.CreateStatic(parent, "remainingPlayerNumText", "剩余玩家：", 16, 180, 150, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(remainingPlayerNumText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    local remainingPlayerNum = GUI.CreateStatic(parent, "remainingPlayerNum", "12", 120, 180, 100, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(remainingPlayerNum, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(remainingPlayerNum,"remainingPlayerNum")

    local eliminatedPlayerNumText = GUI.CreateStatic(parent, "eliminatedPlayerNumText", "淘汰玩家：", 16, 210, 150, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(eliminatedPlayerNumText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    local eliminatedPlayerNum = GUI.CreateStatic(parent, "eliminatedPlayerNum", "1", 120, 210, 100, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(eliminatedPlayerNum, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(eliminatedPlayerNum,"eliminatedPlayerNum")

    local battleBagText = GUI.CreateStatic(parent, "battleBagText", "背包：", 16, 240, 100, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(battleBagText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    local battleBagLevel = GUI.CreateStatic(parent, "battleBagLevel", "低级", 80, 240, 200, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(battleBagLevel, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(battleBagLevel,"battleBagLevel")

    local movementSpeedText = GUI.CreateStatic(parent, "movementSpeedText", "移速：", 16, 270, 100, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(movementSpeedText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    local movementSpeedLevel = GUI.CreateStatic(parent, "movementSpeedLevel", "低级", 80, 270, 200, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(movementSpeedLevel, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(movementSpeedLevel,"movementSpeedLevel")

    -- local playerViewText = GUI.CreateStatic(parent, "playerViewText", "视野：", 16, 300, 100, 30, "system", false)
    -- UILayout.StaticSetFontSizeColorAlignment(playerViewText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    -- local playerViewLevel = GUI.CreateStatic(parent, "playerViewLevel", "低级", 80, 300, 200, 30, "system", false)
    -- UILayout.StaticSetFontSizeColorAlignment(playerViewLevel, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    -- _gt.BindName(playerViewLevel,"playerViewLevel")

    -- local exitBattleActBtn = GUI.ButtonCreate(parent, "exitBattleActBtn", "1800402110", 60, 335, Transition.ColorTint, "退出", 120, 50, false)
    local exitBattleActBtn = GUI.ButtonCreate(parent, "exitBattleActBtn", "1800402110", 60, 320, Transition.ColorTint, "退出", 120, 50, false)
    SetAnchorAndPivot(exitBattleActBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	GUI.ButtonSetTextColor(exitBattleActBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(exitBattleActBtn, UIDefine.FontSizeL)
	_gt.BindName(exitBattleActBtn, "exitBattleActBtn")
	GUI.RegisterUIEvent(exitBattleActBtn, UCE.PointerClick, "TrackUI", "OnExitBattleActBtnClick")	
end

function TrackUI.OnShowBattleBagInfo(parent)
    TrackUI.CreateBattleValueBar(parent,2)

    local itemSrc = GUI.LoopScrollRectCreate(parent,"itemSrc",16,80,220,300,"TrackUI","CreateItemIcon",
                        "TrackUI","RefreshItemIcon",0,false,Vector2.New(70, 70),3,UIAroundPivot.TopLeft,UIAnchor.TopLeft)
    SetSameAnchorAndPivot(itemSrc, UILayout.TopLeft)
    GUI.ScrollRectSetChildSpacing(itemSrc, Vector2.New(3, 3))
    _gt.BindName(itemSrc, "itemSrc")
end

function TrackUI.CreateBattleValueBar(parent,index)
    local name = "battleBack" .. index
    local battleBack = GUI.ImageCreate(parent,name,"1800400200",0,0,false,254,390)
    GUI.SetColor(battleBack,Color.New(1,0,0.2,1))
    GUI.SetVisible(battleBack,false)
    _gt.BindName(battleBack, name)
    local name = "battleValueText" .. index
    local battleValueText = GUI.CreateStatic(parent, name, "鸡力值：", 16, 10, 100, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(battleValueText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    local name = "battleBuffIcon" .. index
    local battleBuffIcon = ItemIcon.Create(parent, name, 205, 7,30,30)
    GUI.ItemCtrlSetElementValue(battleBuffIcon, eItemIconElement.Border, "1801300190")
	GUI.ItemCtrlSetElementValue(battleBuffIcon, eItemIconElement.Icon, "1900817210")
    GUI.ItemCtrlSetElementRect(battleBuffIcon, eItemIconElement.Icon, 0, -1,30,30)
    _gt.BindName(battleBuffIcon, name)
    local name = "battleBuffTime" .. index
    local battleBuffTime = GUI.CreateStatic(battleBuffIcon, name, "25", 0, 0, 50, 30, "system", true)
    _gt.BindName(battleBuffTime, name)
    SetSameAnchorAndPivot(battleBuffTime, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(battleBuffTime, UIDefine.FontSizeL, UIDefine.WhiteColor,TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(battleBuffTime, true)
    GUI.SetOutLine_Distance(battleBuffTime, UIDefine.OutLineDistance)
    GUI.SetOutLine_Color(battleBuffTime, Color.New(255/255,0/255,193/255,255/255))
    local name = "battleValueSlider" .. index
    local battleValueSlider = GUI.ScrollBarCreate(parent, name, "", "1800408160", "1800408110", 16, 40, 220, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    _gt.BindName(battleValueSlider, name)
    local silderFillSize = Vector2.New(220, 24)
    GUI.ScrollBarSetFillSize(battleValueSlider, silderFillSize)
    GUI.ScrollBarSetBgSize(battleValueSlider, silderFillSize)
    SetAnchorAndPivot(battleValueSlider, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local name = "battleValueSliderBack" .. index
    local battleValueSliderBack = GUI.ScrollBarCreate(parent, name, "", "1800408120", "1800408110", 16, 40, 220, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    _gt.BindName(battleValueSliderBack, name)
    GUI.ScrollBarSetFillSize(battleValueSliderBack, silderFillSize)
    GUI.ScrollBarSetBgSize(battleValueSliderBack, silderFillSize)
    SetAnchorAndPivot(battleValueSliderBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(battleValueSliderBack,false)
    local name = "battleValueSliderCurrentTxt" .. index
    local battleValueSliderCurrentTxt = GUI.CreateStatic(parent, name, "95/100", 16, 40, 220, 25, "system", true)
    _gt.BindName(battleValueSliderCurrentTxt, name)
    UILayout.StaticSetFontSizeColorAlignment(battleValueSliderCurrentTxt, UIDefine.FontSizeS, UIDefine.WhiteColor,TextAnchor.MiddleCenter)
end

function TrackUI.RefreshBattleValue(curNum, maxValue)
    if curNum == nil or maxValue == nil then
        return
    end
    for index = 1, 2 do
        local battleValueBar = _gt.GetUI("battleValueSlider" .. index)
        local battleValueBarBack = _gt.GetUI("battleValueSliderBack" .. index)
        local battleValueCurTxt = _gt.GetUI("battleValueSliderCurrentTxt" .. index)
        local battleBack = _gt.GetUI("battleBack" .. index)
        GUI.ScrollBarSetPos(battleValueBar,curNum / maxValue)
        GUI.ScrollBarSetPos(battleValueBarBack,curNum / maxValue)
        GUI.StaticSetText(battleValueCurTxt,curNum .. "/" .. maxValue)
        if TrackUI.curBattleValue ~= nil and TrackUI.curBattleValue > curNum then
            GUI.SetVisible(battleValueBarBack,true)
            GUI.SetGroupAlpha(battleValueBarBack, 0.1)
            TrackUI.OnShowBattleValueBarBack = true
            if TrackUI.SetBattleValueBackTimer == nil then
                TrackUI.SetBattleValueBackTimer = Timer.New(TrackUI.SetBattleValueBack,0.05,-1)
            else
                TrackUI.SetBattleValueBackTimer:Stop()
                TrackUI.SetBattleValueBackTimer:Reset(TrackUI.SetBattleValueBack,0.05,-1)
            end
            TrackUI.SetBattleValueBackTimer:Start()
        else
            GUI.SetVisible(battleValueBarBack,false)
            if TrackUI.SetBattleValueBackTimer ~= nil then
                TrackUI.SetBattleValueBackTimer:Stop()
                TrackUI.SetBattleValueBackTimer = nil
            end
        end
        if curNum < 30 then
            GUI.SetVisible(battleBack,true)
            GUI.SetGroupAlpha(battleBack, 0.1)
            TrackUI.OnShowBattleBack = true
            if TrackUI.SetBattleBackTimer == nil then
                TrackUI.SetBattleBackTimer = Timer.New(TrackUI.SetBattleBack,0.1,-1)
            else
                TrackUI.SetBattleBackTimer:Stop()
                TrackUI.SetBattleBackTimer:Reset(TrackUI.SetBattleBack,0.1,-1)
            end
            TrackUI.SetBattleBackTimer:Start()
        else
            GUI.SetVisible(battleBack,false)
            if TrackUI.SetBattleBackTimer ~= nil then
                TrackUI.SetBattleBackTimer:Stop()
                TrackUI.SetBattleBackTimer = nil
            end
        end
    end
    TrackUI.curBattleValue = curNum
end

function TrackUI.SetBattleValueBack()
    if TrackUI.OnShowBattleValueBarBack then
        for index = 1, 2 do
            local battleValueBarBack = _gt.GetUI("battleValueSliderBack" .. index)
            local alpha = GUI.GetGroupAlpha(battleValueBarBack)
            alpha = alpha + 0.1
            if alpha < 0.4 then
                GUI.SetGroupAlpha(battleValueBarBack, alpha)
            else
                TrackUI.OnShowBattleValueBarBack = false
            end
        end
    end
    if TrackUI.OnShowBattleValueBarBack == false then
        for index = 1, 2 do
            local battleValueBarBack = _gt.GetUI("battleValueSliderBack" .. index)
            local alpha = GUI.GetGroupAlpha(battleValueBarBack)
            alpha = alpha - 0.1
            if alpha > 0.1 then
                GUI.SetGroupAlpha(battleValueBarBack, alpha)
            else
                GUI.SetVisible(battleValueBarBack,false)
                TrackUI.OnShowBattleValueBarBack = true
                TrackUI.SetBattleValueBackTimer:Stop()
            end
        end
    end
end

function TrackUI.SetBattleBack()
    if TrackUI.OnShowBattleBack then
        for index = 1, 2 do
            local battleBack = _gt.GetUI("battleBack" .. index)
            local alpha = GUI.GetGroupAlpha(battleBack)
            alpha = alpha + 0.1
            if alpha < 0.6 then
                GUI.SetGroupAlpha(battleBack, alpha)
            else
                TrackUI.OnShowBattleBack = false
            end
        end
    end
    if TrackUI.OnShowBattleBack == false then
        for index = 1, 2 do
            local battleBack = _gt.GetUI("battleBack" .. index)
            local alpha = GUI.GetGroupAlpha(battleBack)
            alpha = alpha - 0.1
            if alpha > 0.1 then
                GUI.SetGroupAlpha(battleBack, alpha)
            else
                TrackUI.OnShowBattleBack = true
            end
        end
    end
end

function TrackUI.RefreshBattleBuffValue(bless)
    if bless == nil then
        return
    end
    for index = 1, 2 do
        local battleBuffIcon = _gt.GetUI("battleBuffIcon" .. index)
        local battleBuffTime = _gt.GetUI("battleBuffTime" .. index)
        GUI.StaticSetText(battleBuffTime,bless)
        if bless and bless > 0 then
            GUI.SetVisible(battleBuffIcon, true)
        else
            GUI.SetVisible(battleBuffIcon, false)
        end
    end
end

function TrackUI.RefreshBattleRoyaleDebuff()
    local debuffCofig = TrackUI.Act_Chickings_Config.Debuff
    TrackUI.BattleRoyaleDebuff = {}
    local flag = true
    for debuffName, config in pairs(debuffCofig) do
        local sec = TrackUI.UpdateBattleRoyaleDebuff[debuffName]
        if sec and sec > 0 then
            flag = false
            table.insert(TrackUI.BattleRoyaleDebuff,{name = debuffName,sec = sec,config = config})
            TrackUI.UpdateBattleRoyaleDebuff[debuffName] = sec - 1
        end
    end
    table.sort(TrackUI.BattleRoyaleDebuff,function (a,b)
        return a.sec < b.sec
    end)
    local scroll = _gt.GetUI("debuffSrc")
    GUI.LoopScrollRectSetTotalCount(scroll, 3)
    GUI.LoopScrollRectRefreshCells(scroll)
    if flag then
        if TrackUI.RefreshBattleRoyaleDebuffTimer then
            TrackUI.RefreshBattleRoyaleDebuffTimer:Stop()
            TrackUI.RefreshBattleRoyaleDebuffTimer = nil
        end
    end
end

function TrackUI.CreateDebuffItemIcon()
    local debuffSrc = _gt.GetUI("debuffSrc")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(debuffSrc) + 1
    local debuffIcon = ItemIcon.Create(debuffSrc, "debuffIcon" .. curCount, 0, 0,70,70)
    local countDown = GUI.CreateStatic(debuffIcon,"countDown","12",0,0,70,30,"system")
    UILayout.StaticSetFontSizeColorAlignment(countDown, UIDefine.FontSizeXL, UIDefine.WhiteColor,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(countDown, UILayout.Center)
    GUI.SetIsOutLine(countDown, true)
    GUI.SetOutLine_Distance(countDown, UIDefine.OutLineDistance)
    GUI.SetOutLine_Color(countDown, UIDefine.Purple2Color)
    GUI.RegisterUIEvent(debuffIcon, UCE.PointerClick, "TrackUI", "OnDebuffClick")
    return debuffIcon
end

function TrackUI.RefreshDebuffItemIcon(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local countDown = GUI.GetChild(item,"countDown")
    if TrackUI.BattleRoyaleDebuff and TrackUI.BattleRoyaleDebuff[index] then
        local debuffName = TrackUI.BattleRoyaleDebuff[index].name
        local sec = TrackUI.BattleRoyaleDebuff[index].sec
        local config = TrackUI.BattleRoyaleDebuff[index].config

        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[4])
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, config.Icon)
        GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,60,60)

        GUI.StaticSetText(countDown,sec)
        -- GUI.
        GUI.SetVisible(countDown,true)
        GUI.SetData(item,"debuffName",debuffName)
    else
        ItemIcon.BindItemId(item)
        GUI.SetVisible(countDown,false)
        GUI.SetData(item,"debuffName",nil)
    end
end

function TrackUI.OnDebuffClick(guid)
    local item = GUI.GetByGuid(guid)
    local debuffName = GUI.GetData(item,"debuffName")
    local debuffSrc = _gt.GetUI("debuffSrc")
    if debuffName == nil then
        return
    end
    local config = TrackUI.Act_Chickings_Config.Debuff[debuffName]
    local debuffTips = Tips.CreateChinkingItemTipsByInfo(config, debuffName, GUI.GetParentElement(debuffSrc), "debuffTips", -270, 50, 300)
end

function TrackUI.CreateItemIcon()
    local itemSrc = _gt.GetUI("itemSrc")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemSrc) + 1
    local itemIcon = ItemIcon.Create(itemSrc, "itemIcon" .. curCount, 0, 0,70,70)
    local ItemSelected = GUI.ImageCreate(itemIcon,"ItemSelected", "1800400280", -1, -1, false, 72, 72)
    GUI.SetVisible(ItemSelected,false)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "TrackUI", "OnItemClick")
    return itemIcon
end

function TrackUI.RefreshItemIcon(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index > TrackUI.BattleBagSize then
        ItemIcon.SetLock(item)
        GUI.SetData(item,"index",nil)
    elseif TrackUI.UpdateBattleRoyaleItems and TrackUI.UpdateBattleRoyaleItems[index] then
        local itemName = TrackUI.UpdateBattleRoyaleItems[index].Name
        local itemType = TrackUI.UpdateBattleRoyaleItems[index].Type
        local itemInfo = TrackUI.Act_Chickings_Config[itemType][itemName]

        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[itemInfo.Grade])
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, itemInfo.Icon)
        GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,60,60)

        GUI.SetData(item,"index",index)
    else
        ItemIcon.BindItemId(item)
        GUI.SetData(item,"index",nil)
    end
end

function TrackUI.OnItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local ItemSelected = GUI.GetChild(item,"ItemSelected")
    local index = tonumber(GUI.GetData(item,"index"))
    local itemSrc = _gt.GetUI("itemSrc")
    local haveItem = false
    if index then
        haveItem = true
        local itemName = TrackUI.UpdateBattleRoyaleItems[index].Name
        local itemType = TrackUI.UpdateBattleRoyaleItems[index].Type
        local itemInfo = TrackUI.Act_Chickings_Config[itemType][itemName]
        local itemTips = Tips.CreateChinkingItemTipsByInfo(itemInfo, itemName, GUI.GetParentElement(itemSrc), "itemTips", -240, 150, 300, 50)

        if itemName == "银坷垃" or itemName == "金坷垃" or itemName == "鸡王神符" or itemName == "隐形药水"  then
            local useItemBtn = GUI.ButtonCreate(itemTips, "useItemBtn", 1800402110, 65, -10, Transition.ColorTint, "使用", 125, 50, false);
            SetSameAnchorAndPivot(useItemBtn, UILayout.Bottom);
            GUI.ButtonSetTextColor(useItemBtn, UIDefine.BrownColor);
            GUI.ButtonSetTextFontSize(useItemBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(useItemBtn, UCE.PointerClick, "TrackUI", "OnUseItemBtnClick");

            local deleteItemBtn = GUI.ButtonCreate(itemTips, "deleteItemBtn", 1800402110, -65, -10, Transition.ColorTint, "丢弃物资", 125, 50, false);
            SetSameAnchorAndPivot(deleteItemBtn, UILayout.Bottom);
            GUI.ButtonSetTextColor(deleteItemBtn, UIDefine.BrownColor);
            GUI.ButtonSetTextFontSize(deleteItemBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(deleteItemBtn, UCE.PointerClick, "TrackUI", "OnDeleteItemBtnClick");
        else
            local deleteItemBtn = GUI.ButtonCreate(itemTips, "deleteItemBtn", 1800402110, 0, -10, Transition.ColorTint, "丢弃物资", 150, 50, false);
            SetSameAnchorAndPivot(deleteItemBtn, UILayout.Bottom);
            GUI.ButtonSetTextColor(deleteItemBtn, UIDefine.BrownColor);
            GUI.ButtonSetTextFontSize(deleteItemBtn, UIDefine.FontSizeL)
            GUI.RegisterUIEvent(deleteItemBtn, UCE.PointerClick, "TrackUI", "OnDeleteItemBtnClick");
        end
    end
    GUI.SetVisible(ItemSelected,haveItem)
    if TrackUI.ClickItemIconGuid ~= guid then
        local LastClickItem = GUI.GetByGuid(TrackUI.ClickItemIconGuid)
        if LastClickItem then
            ItemSelected = GUI.GetChild(LastClickItem,"ItemSelected")
            GUI.SetVisible(ItemSelected,false)
        end
        TrackUI.ClickItemIconGuid = guid
    end
end

function TrackUI.OnUseItemBtnClick()
    local item = GUI.GetByGuid(TrackUI.ClickItemIconGuid)
    local index = tonumber(GUI.GetData(item,"index"))
    CL.SendNotify(NOTIFY.SubmitForm,"FormAct_Chikings","UseItem",index)
end

function TrackUI.OnDeleteItemBtnClick()
    local item = GUI.GetByGuid(TrackUI.ClickItemIconGuid)
    local index = tonumber(GUI.GetData(item,"index"))
    CL.SendNotify(NOTIFY.SubmitForm,"FormAct_Chikings","DropItem",index)
end

function TrackUI.UpdateBattleRoyaleInfo()
    local Arrt_Info = TrackUI.Act_Chickings_Attr
    if Arrt_Info == nil then
        return
    end
    TrackUI.UpdateBattleValue()
    TrackUI.UpdateFightInfo4Data(Arrt_Info)
    TrackUI.UpdateBattleBagInfoData(Arrt_Info)
end

function TrackUI.UpdateBattleValue()
    local Hp_Max = TrackUI.Act_Chickings_Attr.Hp_Max
    local Hp = CL.GetIntCustomData("Act_Chikings_Hp")
    local Bless = CL.GetIntCustomData("Act_Chickings_Bless")

    TrackUI.RefreshBattleValue(Hp, Hp_Max)
    TrackUI.RefreshBattleBuffValue(Bless)
end

function TrackUI.UpdateFightInfo4Data(arrtInfo)
    local scroll = _gt.GetUI("debuffSrc")
    GUI.LoopScrollRectSetTotalCount(scroll, 3)
    GUI.LoopScrollRectRefreshCells(scroll)

    local remainingPlayerNum = _gt.GetUI("remainingPlayerNum")
    local eliminatedPlayerNum = _gt.GetUI("eliminatedPlayerNum")
    local battleBagLevel = _gt.GetUI("battleBagLevel")
    local movementSpeedLevel = _gt.GetUI("movementSpeedLevel")
    local playerViewLevel = _gt.GetUI("playerViewLevel")
    GUI.StaticSetText(remainingPlayerNum,arrtInfo.Players)
    GUI.StaticSetText(eliminatedPlayerNum,arrtInfo.Kill)
    
    -- local arrtList = {"Bag","Shoes","Eye"}
    -- local actArrList = {"Bag","Speed","View"}
    local arrtList = {"Bag","Shoes"}
    local actArrList = {"Bag","Speed"}
    local arrtValue = {}
    local actConfig = TrackUI.Act_Chickings_Config
    for i = 1, #arrtList, 1 do
        local text = ""
        local color = nil
        for name, value in pairs(actConfig[arrtList[i]]) do
            if value.ConfigIndex == arrtInfo[actArrList[i]] then
                text = name
                color = UIDefine.GradeColor[value.Grade]
            end
        end
        if text == "" then
            text = "无"
            color = UIDefine.WhiteColor
        end
        arrtValue[arrtList[i]] = {text = text,color = color}
    end
    GUI.StaticSetText(battleBagLevel,arrtValue["Bag"].text)
    GUI.SetColor(battleBagLevel,arrtValue["Bag"].color)
    GUI.StaticSetText(movementSpeedLevel,arrtValue["Shoes"].text)
    GUI.SetColor(movementSpeedLevel,arrtValue["Shoes"].color)
    -- GUI.StaticSetText(playerViewLevel,arrtValue["Eye"].text)
    -- GUI.SetColor(playerViewLevel,arrtValue["Eye"].color)
end

function TrackUI.UpdateBattleBagInfoData(arrtInfo)
    if TrackUI.Act_Chickings_Config == nil or TrackUI.Act_Chickings_Config.BagConfig == nil then
        return
    end
    TrackUI.BattleBagSize = TrackUI.Act_Chickings_Config.BagConfig[arrtInfo.Bag]
    local scroll = _gt.GetUI("itemSrc")
    GUI.LoopScrollRectSetTotalCount(scroll, 12)
    GUI.LoopScrollRectRefreshCells(scroll)
end

function TrackUI.UpdateBattleRoyaleBags(index,itemType,itemName)
    if TrackUI.UpdateBattleRoyaleItems == nil then
        TrackUI.UpdateBattleRoyaleItems = {}
    end
    if tostring(itemType) == "nil" then
        TrackUI.UpdateBattleRoyaleItems[index] = nil
    else
        TrackUI.UpdateBattleRoyaleItems[index] = {Type = itemType,Name = itemName}
        TrackUI.OnSwitchTrackPanel(7)
    end
    TrackUI.UpdateBattleRoyaleInfo()
end

function TrackUI.SetBattleRoyaleDebuff(debuffName,sec)
    if TrackUI.UpdateBattleRoyaleDebuff == nil then
        TrackUI.UpdateBattleRoyaleDebuff = {}
    end
    TrackUI.UpdateBattleRoyaleDebuff[debuffName] = sec
    if TrackUI.RefreshBattleRoyaleDebuffTimer == nil then
        TrackUI.RefreshBattleRoyaleDebuff()
        TrackUI.RefreshBattleRoyaleDebuffTimer = Timer.New(TrackUI.RefreshBattleRoyaleDebuff,1,-1)
        TrackUI.RefreshBattleRoyaleDebuffTimer:Start()
    end
end

function TrackUI.AirdropShow(flag,x,y,Rand)
    if TrackUI.ChickingAirdropPoint == nil then
        TrackUI.ChickingAirdropPoint = {}
    end
    if flag then
        local airdropPoint = MapUI.CreateChickingAirdropPoint(x,y,Rand)
        local guid = GUI.GetGuid(airdropPoint)
        TrackUI.ChickingAirdropPoint[guid] = {PosX = x,PosY =y}
    else
        local guid = ""
        for pointGuid, position in pairs(TrackUI.ChickingAirdropPoint) do
            if position.PosX == x and position.PosY == y then
                guid = pointGuid
                break
            end
        end
        TrackUI.ChickingAirdropPoint[guid] = nil
        local airdropPoint = GUI.GetByGuid(guid)
        GUI.SetVisible(airdropPoint,false)
    end
end

function TrackUI.OnExitBattleActBtnClick()
    GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("是否退出", "是否退出吃鸡争霸赛？\n退出后将无法回到吃鸡战场", "TrackUI", "确定", "OnExitBattleActConfirmBtnClick", "取消")
end

function TrackUI.OnExitBattleActConfirmBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm,"FormAct_Chikings","LeaveMap")
end

TrackUI.DynamicActivityMessage = {
    {
    text = "正在等待其他玩家加入游戏   ",
    sec = 0,
    },
    {
    text = "大战一触即发  比赛即将开始   ",
    sec = 0,
    },
    {
    text = " 秒之后比赛开始，请选择您的出生点",
    sec = 0,
    },
}
function TrackUI.DynamicSettingActivityMessage()
    local ActMsg = _gt.GetUI("ActMsg")
    local ActMsgCountDown = _gt.GetUI("ActMsgCountDown")
    local index = TrackUI.DynamicActivityMessage.index
    local text = TrackUI.DynamicActivityMessage[index].text
    local sec = TrackUI.DynamicActivityMessage[index].sec
    GUI.StaticSetText(ActMsg,text)
    GUI.StaticSetText(ActMsgCountDown,sec)
    sec = sec - 1
    TrackUI.DynamicActivityMessage[index].sec = sec
    local str = ""
    if index == 1 or index == 2 then
        -- str = text .. sec
        GUI.SetPositionX(ActMsgCountDown,GUI.GetPositionX(ActMsg) + GUI.StaticGetLabelPreferWidth(ActMsg)/2 + 10)
    elseif index == 3 then
        -- str = sec .. text
        GUI.SetPositionX(ActMsgCountDown,GUI.GetPositionX(ActMsg) - GUI.StaticGetLabelPreferWidth(ActMsg)/2 - 20)
    end
    if sec < 10 then
        GUI.StaticSetFontSize(ActMsgCountDown,120)
        GUI.SetGroupAlpha(ActMsgCountDown, 0.3)
        if TrackUI.DynamicSetFontSizeTimer then
            TrackUI.DynamicSetFontSizeTimer:Stop()
            TrackUI.DynamicSetFontSizeTimer = nil
        end
        if TrackUI.DynamicSetFontSizeTimer == nil then
            TrackUI.DynamicSetFontSizeTimer = Timer.New(TrackUI.DynamicSetFontSize,0.05,-1)
        else
            TrackUI.DynamicSetFontSizeTimer:Stop()
            TrackUI.DynamicSetFontSizeTimer:Reset(TrackUI.DynamicSetFontSize,0.05,-1)
        end
        TrackUI.DynamicSetFontSizeTimer:Start()
        TrackUI.DynamicSetFontSize()
    else
        GUI.StaticSetFontSize(ActMsgCountDown,40)
        GUI.SetGroupAlpha(ActMsgCountDown, 1)
    end
    if sec < 0 then
        if TrackUI.DynamicSettingActivityMessageTimer then
            TrackUI.DynamicSettingActivityMessageTimer:Stop()
        end
    end
end

function TrackUI.DynamicSetFontSize()
    local ActMsgCountDown = _gt.GetUI("ActMsgCountDown")
    local fontSize = GUI.StaticGetFontSize(ActMsgCountDown)
    local alpha = GUI.GetGroupAlpha(ActMsgCountDown)
    fontSize = fontSize - 15
    alpha = alpha + 0.1
    if fontSize > 40 then
        GUI.StaticSetFontSize(ActMsgCountDown,fontSize)
        GUI.SetGroupAlpha(ActMsgCountDown, alpha)
    else
        GUI.StaticSetFontSize(ActMsgCountDown,40)
        GUI.SetGroupAlpha(ActMsgCountDown, 1)
        if TrackUI.DynamicSetFontSizeTimer then
            TrackUI.DynamicSetFontSizeTimer:Stop()
            TrackUI.DynamicSetFontSizeTimer = nil
        end
    end
end

function TrackUI.SetBattleRoyaleState(index,actTickCount)
    local ActMsg = _gt.GetUI("ActMsg")
    local ActMsgCountDown = _gt.GetUI("ActMsgCountDown")
    local serverTime = CL.GetServerTickCount()
    if index == 1 then
        GUI.SetPositionX(ActMsg,-30)
        TrackUI.ChickingAddressPointFlag = true
        TrackUI.ChickingBornPointFlag = false
        GUI.SetVisible(ActMsg,true)
        GUI.SetVisible(ActMsgCountDown,true)
        TrackUI.ShowBattleRoyaleTips()
        local btn1 = GUI.Get("MainUI/rightBtn")
        local btn2 = GUI.Get("MainUI/leftBtn")
        local bg1 = GUI.Get("MainUI/rightBg")
        local bg2 = GUI.Get("MainUI/leftBg/leftBg_Top")
        local vis1 = GUI.GetData(bg1,"visiable")
        local vis2 = GUI.GetData(bg2,"visiable")
        if vis1 ~= "true" then
            MainUI.RightBtnDoTweenScale(GUI.GetGuid(btn1))
        end
        if vis2 ~= "true" then
            MainUI.RightBtnDoTweenScale(GUI.GetGuid(btn2))
        end
    elseif index == 2 then
        GUI.SetPositionX(ActMsg,-30)
        TrackUI.ChickingAddressPointFlag = true
        TrackUI.ChickingBornPointFlag = false
        GUI.SetVisible(ActMsg,true)
        GUI.SetVisible(ActMsgCountDown,true)
    elseif index == 3 then
        GUI.SetPositionX(ActMsg,30)
        TrackUI.ChickingAddressPointFlag = false
        TrackUI.ChickingBornPointFlag = true
        GUI.SetVisible(ActMsg,true)
        GUI.SetVisible(ActMsgCountDown,true)
        openMap = true
        TrackUI.ChooseBornPointName = nil
        GUI.OpenWnd("MapUI","1")
        TrackUI.OnExitTipsBtnClick()
    elseif index == 4 then
        TrackUI.ChickingAddressPointFlag = true
        TrackUI.ChickingBornPointFlag = false
        if TrackUI.DynamicSettingActivityMessageTimer then
            TrackUI.DynamicSettingActivityMessageTimer:Stop()
            TrackUI.DynamicSettingActivityMessageTimer = nil
        end
        GUI.SetVisible(ActMsg,false)
        GUI.SetVisible(ActMsgCountDown,false)
        GUI.CloseWnd("MapUI")
        TrackUI.OnExitTipsBtnClick()
    end
    if TrackUI.DynamicActivityMessage[index] then
        TrackUI.DynamicActivityMessage.index = index
        TrackUI.DynamicActivityMessage[index].sec = actTickCount - serverTime
        if TrackUI.DynamicSettingActivityMessageTimer == nil then
            TrackUI.DynamicSettingActivityMessageTimer = Timer.New(TrackUI.DynamicSettingActivityMessage,1,-1)
        else
            TrackUI.DynamicSettingActivityMessageTimer:Stop()
            TrackUI.DynamicSettingActivityMessageTimer:Reset(TrackUI.DynamicSettingActivityMessage,1,-1)
        end
        TrackUI.DynamicSettingActivityMessageTimer:Start()
        TrackUI.DynamicSettingActivityMessage()
    end
end

function TrackUI.ShowBattleRoyaleTips()
    local tips = _gt.GetUI("BattleRoyaleTips")
    if tips == nil then
        local panel = _gt.GetUI("panel")
        local str = "玩法简介：\n1.鸡力值将随着比赛时间流逝\n2.神鸡祝福将阻止鸡力值的流逝\n3.可与石像交互获得神鸡祝福\n4.神鸡石像会慢慢减少\n5.拾取宝箱，可获得鸡力值恢复道具或战斗增益道具\n6.本场景中移速会降低，但宝箱中有可以提高移速的道具\n7.战斗失败和鸡力值归零都会被移出战局\n8.留在地图中的最后一人将成为最终获胜玩家！"
        local BattleRoyaleTips = GUI.ImageCreate(panel,"BattleRoyaleTips","1800200010",0,70,false,410,450)
        SetSameAnchorAndPivot(BattleRoyaleTips, UILayout.Center)
        local lable = GUI.CreateStatic(BattleRoyaleTips, "lable", str, 0, -20, 380, 400)
	    UILayout.StaticSetFontSizeColorAlignment(lable, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleLeft)
        GUI.StaticSetLineSpacing(lable,1.2)
        local exitTipsBtn = GUI.ButtonCreate(BattleRoyaleTips, "exitTipsBtn", "1800402110", 0, -10, Transition.ColorTint, "我知道了", 120, 50, false)
        SetSameAnchorAndPivot(exitTipsBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(exitTipsBtn, UIDefine.BrownColor);
        GUI.ButtonSetTextFontSize(exitTipsBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(exitTipsBtn, UCE.PointerClick, "TrackUI", "OnExitTipsBtnClick")	
        _gt.BindName(BattleRoyaleTips,"BattleRoyaleTips")
    else
        GUI.SetVisible(tips,true)
    end
end

function TrackUI.OnExitTipsBtnClick()
    local tips = _gt.GetUI("BattleRoyaleTips")
    GUI.SetVisible(tips,false)
end

function TrackUI.ShowBattleRoyaleFightMsgPage(type,sec)
    TrackUI.FightMsgType = type
    TrackUI.FightMsgCount = sec
    -- if type == 1 then
    --     CL.SetRoleTopName(uint64.new(1800304020))
    -- end
    
    TrackUI.OnShowBattleRoyaleFightMsgPage()
    TrackUI.RefreshBattleRoyaleFightMsgPage()
    if TrackUI.RefreshBattleRoyaleFightMsgPageTimer == nil then
        TrackUI.RefreshBattleRoyaleFightMsgPageTimer = Timer.New(TrackUI.RefreshBattleRoyaleFightMsgPage,1,-1)
    else
        TrackUI.RefreshBattleRoyaleFightMsgPageTimer:Stop()
        TrackUI.RefreshBattleRoyaleFightMsgPageTimer:Reset(TrackUI.RefreshBattleRoyaleFightMsgPage,1,-1)
    end
    TrackUI.RefreshBattleRoyaleFightMsgPageTimer:Start()
end

function TrackUI.RefreshBattleRoyaleFightMsgPage()
    local fightMsgPage = _gt.GetUI("fightMsgPage")
    local titleText = GUI.GetChild(fightMsgPage,"titleText")
    local tipText1 = GUI.GetChild(fightMsgPage,"tipText1")
    local tipText2 = GUI.GetChild(fightMsgPage,"tipText2")
    local confirmBtn = GUI.GetChild(fightMsgPage,"confirmBtn")
    local text1,text2,text3,text4 = "","","",""
    local spotText = ""
    local sec = TrackUI.FightMsgCount
    sec = sec - 1
    TrackUI.FightMsgCount = sec
    if TrackUI.FightMsgType == 1 then
        text1 = "隐身中"
        text2 = sec .. "秒后现身"
        text3 = "现身后将对周围玩家造成20点鸡力值的伤害"
        text4 = "立即现身"
    end
    local spotCount = sec % 3
    if spotCount == 0 then
        spotText = "..."
    elseif spotCount == 1 then
        spotText = ".."
    else
        spotText = "."
    end
    text1 = text1 .. spotText
    GUI.StaticSetText(titleText,text1)
    GUI.StaticSetText(tipText1,text2)
    GUI.StaticSetText(tipText2,text3)
    GUI.ButtonSetText(confirmBtn,text4)
    if sec <= 0 then
        if TrackUI.RefreshBattleRoyaleFightMsgPageTimer then
            TrackUI.RefreshBattleRoyaleFightMsgPageTimer:Stop()
            TrackUI.RefreshBattleRoyaleFightMsgPageTimer = nil
        end
        local fightMsgPage = _gt.GetUI("fightMsgPage")
        GUI.SetVisible(fightMsgPage,false)
        -- CL.SetRoleTopName(uint64.new(0))
    end
end

function TrackUI.OnShowBattleRoyaleFightMsgPage()
    local fightMsgPage = _gt.GetUI("fightMsgPage")
    if fightMsgPage == nil then
        local panel = _gt.GetUI("panel")
        fightMsgPage = GUI.ImageCreate( panel,"fightMsgPage", "1800200010", 0, 0, false, 250, 165)
        SetSameAnchorAndPivot(fightMsgPage, UILayout.Center)
        _gt.BindName(fightMsgPage,"fightMsgPage")

        local titleText = GUI.CreateStatic(fightMsgPage, "titleText", "隐身中...", 10, -60, 240, 50, "201", false)
        UILayout.StaticSetFontSizeColorAlignment(titleText, 40, UIDefine.WhiteColor,TextAnchor.MiddleCenter)
        SetSameAnchorAndPivot(titleText, UILayout.TopLeft)
        GUI.SetIsOutLine(titleText, true)
        GUI.SetOutLine_Distance(titleText, UIDefine.OutLineDistance)
        GUI.SetOutLine_Color(titleText, UIDefine.Blue4Color)

        local tipText1 = GUI.CreateStatic(fightMsgPage, "tipText1", "隐身中，xx秒现身", 10, 10, 240, 30, "system", false)
        UILayout.StaticSetFontSizeColorAlignment(tipText1, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.MiddleCenter)
        SetSameAnchorAndPivot(tipText1, UILayout.TopLeft)

        local tipText2 = GUI.CreateStatic(fightMsgPage, "tipText2", "现身后将对周围玩家造成20点鸡力值的伤害", 10, 40, 240, 60, "system", false)
        UILayout.StaticSetFontSizeColorAlignment(tipText2, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
        SetSameAnchorAndPivot(tipText2, UILayout.TopLeft)

        local confirmBtn = GUI.ButtonCreate(fightMsgPage, "confirmBtn", 1800402110, 0, -10, Transition.ColorTint, "立即现身", 150, 50, false);
        SetSameAnchorAndPivot(confirmBtn, UILayout.Bottom);
        GUI.ButtonSetTextColor(confirmBtn, UIDefine.BrownColor);
        GUI.ButtonSetTextFontSize(confirmBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "TrackUI", "OnConfirmBtnClick");
    else
        GUI.SetVisible(fightMsgPage,true)
    end
end

function TrackUI.OnConfirmBtnClick()
    if TrackUI.FightMsgType == 1 then
        -- CL.SetRoleTopName(uint64.new(0))
        CL.SendNotify(NOTIFY.SubmitForm,"FormAct_Chikings","ShowUpFromGhost")
        test("现身了")
    end
    local fightMsgPage = _gt.GetUI("fightMsgPage")
    GUI.SetVisible(fightMsgPage,false)
    if TrackUI.RefreshBattleRoyaleFightMsgPageTimer then
        TrackUI.RefreshBattleRoyaleFightMsgPageTimer:Stop()
        TrackUI.RefreshBattleRoyaleFightMsgPageTimer = nil
    end
end

function TrackUI.ShowBattleSettlementPage(index,playerNum,ItemTable,coinNum,killNum)
    TrackUI.Width = ScreenWidth
    TrackUI.Height = ScreenHeight
    TrackUI.BattleResultList = {index = index,playerNum = playerNum,ItemTable = ItemTable,coinNum = coinNum,killNum = killNum}
    GUI.OpenWnd("BattleRoyaleSettlementPageUI")
end

function TrackUI.OnShowDungeon(parent)
    local colorP = Color.New(220 / 255, 96 / 255, 247 / 255, 255 / 255)
    local colorWhite = UIDefine.WhiteColor
    local colorDark = UIDefine.BrownColor
    local _PIC1 = GUI.ImageCreate(parent, "PIC1", "1800200010", 0, 0, false, 254, 79)
    SetAnchorAndPivot(_PIC1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PIC2 = GUI.ImageCreate(parent, "PIC2", "1800200010", 0, 80, false, 254, 119)
    SetAnchorAndPivot(_PIC2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PIC3 = GUI.ImageCreate(parent, "PIC3", "1800200010", 0, 200, false, 254, 198)
    SetAnchorAndPivot(_PIC3, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --进度节点
    --local _ScheduleNode = GUI.ImageCreate(_DungeonWnd, "ScheduleNode", "", 0, 0, false, 0, 0)
    local _ScheduleNode = GUI.GroupCreate(parent, "ScheduleNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_ScheduleNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_ScheduleNode, true)

    local _ScheduleTitle = GUI.CreateStatic(_ScheduleNode, "ScheduleTitle", "副本进度", 10, 10, 200, 30)
    SetAnchorAndPivot(_ScheduleTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_ScheduleTitle, 21)
    GUI.SetColor(_ScheduleTitle, colorP)

    local bg = GUI.ImageCreate(_ScheduleNode, "ScheduleBootstrapBG", "1800608510", 13, 58, false, 0, 0)
    SetAnchorAndPivot(bg, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ImageSetType(bg, SpriteType.Filled)
    GUI.SetImageFillMethod(bg, SpriteFillMethod.Horizontal_Left)
    GUI.SetImageFillAmount(bg, 1)

    local _ScheduleBootstrap = GUI.ImageCreate(_ScheduleNode, "ScheduleBootstrap", "1800608511", 13, 58, false, 0, 0)
    _gt.BindName(_ScheduleBootstrap, "ScheduleBootstrap")
    SetAnchorAndPivot(_ScheduleBootstrap, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ImageSetType(_ScheduleBootstrap, SpriteType.Filled)
    GUI.SetImageFillMethod(_ScheduleBootstrap, SpriteFillMethod.Horizontal_Left)

    local _ScheduleTitleNum = GUI.CreateStatic(_ScheduleNode, "ScheduleTitleNum", "", 254 / 2, 58, 150, 30)
    _gt.BindName(_ScheduleTitleNum, "ScheduleTitleNum")
    SetAnchorAndPivot(_ScheduleTitleNum, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(_ScheduleTitleNum, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(_ScheduleTitleNum, 18)
    GUI.SetColor(_ScheduleTitleNum, colorWhite)

    --信息节点
    --local _InfNode = GUI.ImageCreate(_DungeonWnd, "InfNode", "", 0, 0, false, 0, 0)
    local _InfNode = GUI.GroupCreate(parent, "InfNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_InfNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_InfNode, true)

    local _InfTitle = GUI.CreateStatic(_InfNode, "ScheduleTitle", "追踪信息", 10, 85, 200, 30)
    SetAnchorAndPivot(_InfTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_InfTitle, 21)
    GUI.SetColor(_InfTitle, colorP)

    local _InfTxt = GUI.RichEditCreate(_InfNode, "InfTxt", "", 10, 118, 220, 90)
    _gt.BindName(_InfTxt, "InfTxt")
    SetAnchorAndPivot(_InfTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_InfTxt, 18);
    GUI.SetColor(_InfTxt, colorWhite);
    _InfTxt:RegisterEvent(UCE.PointerClick);
    GUI.StaticSetAlignment(_InfTxt, TextAnchor.UpperLeft)
    GUI.RegisterUIEvent(_InfTxt, UCE.PointerClick, "TrackUI", "OnClickDungeonQuestContent")

    --奖励节点
    --local _GiftNode = GUI.ImageCreate(_DungeonWnd, "GiftNode", "", 0, 0, false, 0, 0)
    local _GiftNode = GUI.GroupCreate(parent, "GiftNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_GiftNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_GiftNode, true)

    local _GiftTitle = GUI.CreateStatic(_InfNode, "GiftTitle", "副本奖励", 10, 205, 200, 30)
    SetAnchorAndPivot(_GiftTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_GiftTitle, 21)
    GUI.SetColor(_GiftTitle, colorP)

    --经验
    local _GiftExpBG = GUI.ImageCreate(_GiftNode, "GiftExpBG", "1800600810", 10, 240, false, 0, 0)
    _gt.BindName(_GiftExpBG, "GiftExpBG")
    SetAnchorAndPivot(_GiftExpBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _GiftExpIcon = GUI.ImageCreate(_GiftNode, "GiftExpIcon", "1800408330", 9, 239, false, 28, 28)
    _gt.BindName(_GiftExpIcon, "GiftExpIcon")
    SetAnchorAndPivot(_GiftExpIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _GiftExpFirst = GUI.ImageCreate(_GiftNode, "GiftExpFirst", "1800604400", 5, 230, false, 0, 0)
    _gt.BindName(_GiftExpFirst, "GiftExpFirst")
    SetAnchorAndPivot(_GiftExpFirst, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_GiftExpFirst, false)

    local _GiftExpTxt = GUI.CreateStatic(_GiftNode, "GiftExpTxt", "", 85, 253, 90, 30)
    _gt.BindName(_GiftExpTxt, "GiftExpTxt")
    SetAnchorAndPivot(_GiftExpTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_GiftExpTxt, 18)
    GUI.SetColor(_GiftExpTxt, colorWhite)

    --银币
    local _GiftGoldBG = GUI.ImageCreate(_GiftNode, "GiftGoldBG", "1800600810", 130, 240, false, 0, 0)
    _gt.BindName(_GiftGoldBG, "GiftGoldBG")
    SetAnchorAndPivot(_GiftGoldBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _GiftGoldIcon = GUI.ImageCreate(_GiftNode, "GiftGoldIcon", "1800408280", 130, 239, false, 28, 28)
    _gt.BindName(_GiftGoldIcon, "GiftGoldIcon")
    SetAnchorAndPivot(_GiftGoldIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _GiftGoldFirst = GUI.ImageCreate(_GiftNode, "GiftGoldFirst", "1800604400", 125, 230, false, 0, 0)
    _gt.BindName(_GiftGoldFirst, "GiftGoldFirst")
    SetAnchorAndPivot(_GiftGoldFirst, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_GiftGoldFirst, false)

    local _GiftGoldTxt = GUI.CreateStatic(_GiftNode, "GiftGoldTxt", "", 205, 253, 90, 30)
    _gt.BindName(_GiftGoldTxt, "GiftGoldTxt")
    SetAnchorAndPivot(_GiftGoldTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_GiftGoldTxt, 18)
    GUI.SetColor(_GiftGoldTxt, colorWhite)

    --奖励物品节点
    --local _GiftItemNode = GUI.ImageCreate(_DungeonWnd, "GiftItemNode", "", 0, 35, false, 0, 0)
    local _GiftItemNode = GUI.GroupCreate(parent, "GiftItemNode", 0, 35, 0, 0)
    SetAnchorAndPivot(_GiftItemNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_GiftItemNode, true)

    local RewardScroll = GUI.LoopScrollRectCreate(_GiftItemNode, "RewardScroll", 10, 245, 230, 50,
            "TrackUI", "CreateRewardItem", "TrackUI", "RefreshRewardScroll", 0, true, Vector2.New(50, 50), 1, UIAroundPivot.Left, UIAnchor.Left)
    GUI.ScrollRectSetChildSpacing(RewardScroll, Vector2.New(0, 10))
    _gt.BindName(RewardScroll, "RewardScroll")

    --倒计时
    local _Countdown = GUI.CreateStatic(parent, "Countdown", "00:00", 30, -173, 150, 30)
    _gt.BindName(_Countdown, "Countdown")
    SetAnchorAndPivot(_Countdown, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(_Countdown, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(_Countdown, 22)
    GUI.SetColor(_Countdown, colorWhite)

    --退出按钮
    local _ExitBtn = GUI.ButtonCreate(parent, "ExitBtn", "1800602020", 65, 345, Transition.ColorTint, "退出")

    SetAnchorAndPivot(_ExitBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_ExitBtn, 26)
    GUI.ButtonSetTextColor(_ExitBtn, colorDark)
    GUI.SetIsOutLine(_ExitBtn, true)
    GUI.RegisterUIEvent(_ExitBtn, UCE.PointerClick, "TrackUI", "OnClickExitBtn")
end

function TrackUI.UpdateDungeonData()
    local data = TrackUI.dungeonData
    TrackUI.Second = math.floor((data.DeadlineSec - CL.GetServerTickCount()))
    if TrackUI.IsFirstEnter then
        TrackUI.IsFirstEnter = false
        TrackUI.UpdateTimer:Start()
    end
    TrackUI.SetExp(data.RewardExp)
    TrackUI.SetGold(data.RewardMoney)
    local _InfTxt = _gt.GetUI("InfTxt")
    local _ScheduleTitleNum = _gt.GetUI("ScheduleTitleNum")
    local _ScheduleBootstrap = _gt.GetUI("ScheduleBootstrap")
    GUI.StaticSetText(_InfTxt, tostring(data.TraceMsg))
    if _ScheduleTitleNum then
        GUI.StaticSetText(_ScheduleTitleNum,  tonumber(data.NowStep) .. "/" .. tonumber(data.MaxStep))
    end
    if _ScheduleBootstrap then
        GUI.SetImageFillAmount(_ScheduleBootstrap, tonumber(data.NowStep) / tonumber(data.MaxStep))
    end
    local rewards = data.RewardItem
    local temp = {}
    local count = math.floor(#rewards / 3)
    for i = 1, count do
        local idx = (i - 1) * 3 + 1
        temp[#temp + 1] = {
            rewards[idx],
            rewards[idx + 1],
            rewards[idx + 2],
        }
    end
    TrackUI.ItemReward = temp
    local scroll = _gt.GetUI("RewardScroll")
    GUI.LoopScrollRectSetTotalCount(scroll, count)
    GUI.LoopScrollRectRefreshCells(scroll)
end

function TrackUI.SetExp(date_exp,isFirst)
    local _GiftExpFirst = _gt.GetUI("GiftExpFirst")
    local _GiftExpTxt = _gt.GetUI("GiftExpTxt")
    local _GiftExpIcon = _gt.GetUI("GiftExpIcon")
    local _GiftExpBG = _gt.GetUI("GiftExpBG")

    if _GiftExpFirst ~= nil and _GiftExpTxt ~= nil then
        if tonumber(date_exp) == -1 then
            GUI.SetVisible(_GiftExpFirst, false)
            GUI.SetVisible(_GiftExpTxt, false)
            GUI.SetVisible(_GiftExpIcon, false)
            GUI.SetVisible(_GiftExpBG, false)
        else
            GUI.SetVisible(_GiftExpTxt, true)
            GUI.SetVisible(_GiftExpIcon, true)
            GUI.SetVisible(_GiftExpBG, true)
            GUI.SetVisible(_GiftExpFirst, isFirst)
            GUI.StaticSetText(_GiftExpTxt, date_exp)
        end
    end
end

function TrackUI.SetGold(date_gold, isFirst)
    local _GiftGoldFirst = _gt.GetUI("GiftGoldFirst")
    local _GiftGoldTxt = _gt.GetUI("GiftGoldTxt")
    local _GiftGoldBG = _gt.GetUI("GiftGoldBG")
    local _GiftGoldIcon = _gt.GetUI("GiftGoldIcon")

    if _GiftGoldFirst ~= nil and _GiftGoldTxt ~= nil then
        if tonumber(date_gold) == -1 then
            GUI.SetVisible(_GiftGoldFirst, false)
            GUI.SetVisible(_GiftGoldTxt, false)
            GUI.SetVisible(_GiftGoldBG, false)
            GUI.SetVisible(_GiftGoldIcon, false)
        else
            GUI.SetVisible(_GiftGoldTxt, true)
            GUI.SetVisible(_GiftGoldBG, true)
            GUI.SetVisible(_GiftGoldIcon, true)
            GUI.SetVisible(_GiftGoldFirst, isFirst)
            GUI.StaticSetText(_GiftGoldTxt, date_gold)
        end
    end
end

function TrackUI.SurplusTimer()
    if not TrackUI.Second then
        return
    end
    if TrackUI.Second <= 0 then
        TrackUI.UpdateTimer:Stop()
        local _Countdown = _gt.GetUI("Countdown")
        GUI.SetVisible(_Countdown,false)
    else
        TrackUI.Second = TrackUI.Second - 1
    end
    local timeStr = GlobalUtils.GetTimeString(TrackUI.Second)
    local _Countdown = _gt.GetUI("Countdown")
    GUI.StaticSetText(_Countdown, timeStr)
end

function TrackUI.OnClickDungeonQuestContent()
    local data =TrackUI.dungeonData.TraceAim
    if not data or not next(data) then
        CL.SendNotify(NOTIFY.ShowBBMsg, "无法寻路到目标")
        return
    end
    CL.StartMove(data[2], CL.ChangeLogicPosZ(data[3])) --,CL.GetCurrentMapId()
    if data[4] ~= 1 then
        local DBconfig = DB.GetOnceNpcByKey2(data[1])
        CL.SetMoveEndAction(MoveEndAction.SelectNpc, DBconfig.Id)
    end
end

function TrackUI.CreateRewardItem()
    local rewardScroll = _gt.GetUI("RewardScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(rewardScroll)
    local item = GUI.ItemCtrlCreate(rewardScroll, "GiftItemBg" .. curCount, "1800600050", 0, 0, 50, 50, false)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "TrackUI", "on_item_click")
    local FirstRewardIcon = GUI.ImageCreate(item, "FirstRewardIcon", "1800604400", 0,0, false, 38, 24)
	return item
end

function TrackUI.OnClickExitBtn()
    CL.SendNotify(NOTIFY.SubmitForm, "FormDungeon", "ClickQuit")
end

function TrackUI.RefreshRewardScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local item = GUI.GetByGuid(guid)
    local data = TrackUI.ItemReward[index + 1]
    local DBItem = DB.GetOnceItemByKey2(data[1])
	local FirstRewardIcon = GUI.GetChild(item, "FirstRewardIcon", false)
    if DBItem.Id == 0 then
        GUI.SetVisible(item, false)
        return
    end
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, DBItem.Icon)
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, data[2])
    local grade = UIDefine.ItemIconBg[DBItem.Grade]
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, grade)
    GUI.SetData(item, "item", DBItem.Id)
	
	if TrackUI.dungeonData["IsFirstReward"] == 1 then
		GUI.SetVisible(FirstRewardIcon, true)
	else
		GUI.SetVisible(FirstRewardIcon, false)
	end
end

function TrackUI.on_item_click(guid)
    local _Panel = GUI.GetWnd("TrackUI")
    local panelCover = GUI.ImageCreate( _Panel , "TrackWnd_PanelCover" , "1800400220" , 0 , 0 , false , 1280 , 720);
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover,true)
    GUI.SetColor(panelCover, UIDefine.Transparent)
    GUI.SetVisible(panelCover,true);
    panelCover:RegisterEvent(UCE.PointerClick)
    local item_bg = GUI.GetByGuid(guid)
    local item = tonumber(GUI.GetData(item_bg, "item"))
    local x = 185
    local y = 23
    local itemTips = Tips.CreateByItemId(item, panelCover, "itemTips", x, y)
    GUI.SetIsRemoveWhenClick(panelCover,true)
end

function TrackUI.OnShowFightInfo(parent)
    local txt = _gt.GetUI("myScoreTitle")
    --玩家名字
    if txt == nil then
        txt = GUI.CreateStatic(parent, "myScoreTitle", "我的积分", 16, 12, 135, 28, "system", false)
        _gt.BindName(txt, "myScoreTitle")
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        GUI.SetColor(txt, UIDefine.WhiteColor)

        txt = GUI.CreateStatic(parent, "title0", "个人排名", 16, 45, 135, 28, "system", false)
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        GUI.SetColor(txt, UIDefine.WhiteColor)

        txt = GUI.CreateStatic(parent, "title1", "我的小组编号", 16, 78, 135, 28, "system", false)
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        GUI.SetColor(txt, UIDefine.WhiteColor)

        txt = GUI.CreateStatic(parent, "title2", "小组排名情况", 16, 111, 135, 28, "system", false)
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        GUI.SetColor(txt, UIDefine.WhiteColor)

        txt = GUI.CreateStatic(parent, "title3", "编号", 16, 144, 135, 28, "system", false)
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        GUI.SetColor(txt, UIDefine.WhiteColor)

        txt = GUI.CreateStatic(parent, "title4", "胜场", 86, 144, 135, 28, "system", false)
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        GUI.SetColor(txt, UIDefine.WhiteColor)

        txt = GUI.CreateStatic(parent, "title5", "队伍总分", 162, 144, 135, 28, "system", false)
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        GUI.SetColor(txt, UIDefine.WhiteColor)

        txt = GUI.CreateStatic(parent, "title6", "距下一场战斗开启还有", 13, 296, 245, 28, "system", false)
        _gt.BindName(txt, "timeTitle")
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeSS)
        GUI.SetColor(txt, UIDefine.WhiteColor)

        txt = GUI.CreateStatic(parent, "title7", "全部比赛已结束", 63, 296, 245, 28, "system", false)
        _gt.BindName(txt, "timeFinish")
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeSS)
        GUI.SetColor(txt, UIDefine.WhiteColor)
        GUI.SetVisible(txt, false)

        txt = GUI.CreateStatic(parent, "time", "00:00", 96, 296, 245, 28, "system", false)
        _gt.BindName(txt, "time")
        SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        --准备按钮
        local PrepareBtn = GUI.ButtonCreate(parent,"PrepareBtn", "1800402110", 0, 158,  Transition.ColorTint, "准备", 145, 46,false)
        _gt.BindName(PrepareBtn, "PrepareBtn")
        GUI.SetEventCD(PrepareBtn,UCE.PointerClick, 0.5)
        GUI.SetData(PrepareBtn, "flag", "1")
        SetAnchorAndPivot(PrepareBtn, UIAnchor.Center, UIAroundPivot.Center)
        GUI.ButtonSetTextFontSize(PrepareBtn, UIDefine.FontSizeL)
        GUI.ButtonSetTextColor(PrepareBtn, UIDefine.Brown3Color)
        GUI.RegisterUIEvent(PrepareBtn, UCE.PointerClick, "TrackUI", "OnPrepareBtn")

        local txtName = {"myScore","myRank","myGroupID"}
        for i = 1, 3 do
            txt = GUI.CreateStatic(parent, txtName[i], "0", 81, 10+(i-1)*33, 245, 28, "system", false)
            _gt.BindName(txt, txtName[i])
            SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        end

        --显示4组排名数据
        for i = 1, 4 do
            txt = GUI.CreateStatic(parent, "val_"..i.."_1", tostring(i), -85, 172+(i-1)*31, 245, 28, "system", false)
            _gt.BindName(txt, "val_"..i.."_1")
            SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

            txt = GUI.CreateStatic(parent, "val_"..i.."_2", "1", -16, 172+(i-1)*31, 245, 28, "system", false)
            _gt.BindName(txt, "val_"..i.."_2")
            SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

            txt = GUI.CreateStatic(parent, "val_"..i.."_3", "2", 81, 172+(i-1)*31, 245, 28, "system", false)
            _gt.BindName(txt, "val_"..i.."_3")
            SetAnchorAndPivot(txt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(txt,  UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        end
    end
end

function TrackUI.OnQuestInfoUpdate(param0, param1)
    TrackUI.ShowQuestLst()
    --主线任务变更：则模拟自动点击一次
    --if param1 == 1 then
        --if TrackUI.MainQuestTarget ~= nil and CL.GetIntAttr(RoleAttr.RoleAttrLevel) == 1 then
        --    TrackUI.OnClickQuestContent(TrackUI.MainQuestTarget)
        --end
    --end
end

function TrackUI.OnPrepareBtn(guid)
    local btn = GUI.GetByGuid(guid)
    if btn then
        local flag = tonumber(GUI.GetData(btn, "flag"))
        CL.SendNotify(NOTIFY.SubmitForm, "FormShuiLuDaHui", "SetReady", flag)
    end
end

function TrackUI.SwitchPrepareBtn(bPrepare)
    local btn = _gt.GetUI("PrepareBtn")
    if btn then
        GUI.ButtonSetText(btn, bPrepare and "准备" or "取消准备")
        GUI.SetData(btn, "flag", bPrepare and 1 or 0)
    end
end

-- 生存挑战
function TrackUI.OnShowChallenge(parent)
    local colorWhite = UIDefine.WhiteColor
    local colorDark = UIDefine.BrownColor
    local titleColor = Color.New(220 / 255, 96 / 255, 247 / 255, 255 / 255)

    local _PIC1 = GUI.ImageCreate(parent, "PIC1", "1800200010", 0, 0, false, 254, 392)
    SetAnchorAndPivot(_PIC1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 时间
    local _TimeTitle = GUI.CreateStatic(_PIC1, "TimeTitle", "时间", 10, 40, 70, 40)
    SetAnchorAndPivot(_TimeTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_TimeTitle, 26)
    GUI.SetColor(_TimeTitle, titleColor)
    _gt.BindName(_TimeTitle, "TimeTitle")

    --倒计时
    local _ChallengeTime = GUI.CreateStatic(_PIC1, "ChallengeTime", "00:00", 90, 40, 150, 40)
    _gt.BindName(_ChallengeTime, "ChallengeTime")
    SetAnchorAndPivot(_ChallengeTime, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_ChallengeTime, 26)
    GUI.SetColor(_ChallengeTime, colorWhite)

    --战绩
    local _Record = GUI.CreateStatic(_PIC1, "Record", "战绩", 10, 110, 70, 40)
    SetAnchorAndPivot(_Record, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Record, 26)
    GUI.SetColor(_Record, titleColor)

    --倒计时
    local _VorDRecord = GUI.CreateStatic(_PIC1, "VorDRecord", "0胜0负", 90, 110, 150, 40)
    _gt.BindName(_VorDRecord, "VorDRecord")
    SetAnchorAndPivot(_Countdown, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_VorDRecord, 26)
    GUI.SetColor(_VorDRecord, colorWhite)

    --排行榜
    local _ShowBtn = GUI.ButtonCreate(_PIC1, "ExitBtn", "1800602020", 65, 275, Transition.ColorTint, "排行榜")
    SetAnchorAndPivot(_ShowBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_ShowBtn, 26)
    GUI.ButtonSetTextColor(_ShowBtn, colorDark)
    GUI.SetIsOutLine(_ShowBtn, true)
    GUI.RegisterUIEvent(_ShowBtn, UCE.PointerClick, "TrackUI", "OnShowBtnClick")

    --退出战斗
    local _ExitBtn = GUI.ButtonCreate(_PIC1, "ExitBtn", "1800602020", 65, 325, Transition.ColorTint, "退出战斗")
    SetAnchorAndPivot(_ExitBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_ExitBtn, 26)
    GUI.ButtonSetTextColor(_ExitBtn, colorDark)
    GUI.SetIsOutLine(_ExitBtn, true)
    GUI.RegisterUIEvent(_ExitBtn, UCE.PointerClick, "TrackUI", "OnExitChallenge")
end

function TrackUI.UpdateChallenge()
    local vNum = TrackUI.SurvivalChallengeData.PlayerWinsNum
    local dNum = TrackUI.SurvivalChallengeData.PlayerLoseNum
    local _VorDRecord = _gt.GetUI("VorDRecord")
    GUI.StaticSetText(_VorDRecord, tostring(vNum).."胜"..tostring(dNum).."负")

    local _TimeTitle = _gt.GetUI("TimeTitle")
    if TrackUI.SurvivalChallengeData.NowState == 1 then
        GUI.StaticSetText(_TimeTitle, "准备")
        TrackUI.Second = math.floor((TrackUI.SurvivalChallengeData.ACTReadyTime))
    else
        GUI.StaticSetText(_TimeTitle, "时间")
        TrackUI.Second = math.floor((TrackUI.SurvivalChallengeData.ACTEndTime - CL.GetServerTickCount()))
    end

    if TrackUI.UpdateChallengeTimer == nil then
        TrackUI.UpdateChallengeTimer = Timer.New(TrackUI.ChallengeTimer, 1, -1, true)
    else
        TrackUI.UpdateChallengeTimer:Stop()
        TrackUI.UpdateChallengeTimer:Reset(TrackUI.ChallengeTimer, 1, -1)
    end
    TrackUI.UpdateChallengeTimer:Start()
end

function TrackUI.ChallengeTimer()
    if not TrackUI.Second then
        return
    end
    if TrackUI.Second <= 0 then
        TrackUI.UpdateChallengeTimer:Stop()
        local _ChallengeTime = _gt.GetUI("ChallengeTime")
        GUI.StaticSetText(_ChallengeTime, "00:00")
    else
        TrackUI.Second = TrackUI.Second - 1
    end
    local timeStr = GlobalUtils.GetTimeString(TrackUI.Second)
    local _ChallengeTime = _gt.GetUI("ChallengeTime")
    GUI.StaticSetText(_ChallengeTime, timeStr)
end

--生存挑战-显示榜单
function TrackUI.OnShowBtnClick()
    GUI.OpenWnd("ChallengeRankUI")
end

--生存挑战-退出
function TrackUI.OnExitChallenge()
    test("OnExitChallenge")
    CL.SendNotify(NOTIFY.SubmitForm, "FormSurvivalChallenge", "OutChallenge")
end

function TrackUI.OnShow(parameter)
    local wnd = GUI.GetWnd("TrackUI")
    if wnd then
        GUI.SetVisible(wnd, true)
    end
    TrackUI.ShowTeamLst()
    TrackUI.ShowQuestLst()
end

function TrackUI.OnTeamInfoUpdate(Type, p0, p1, p2)
    --print(tostring(Type)..","..tostring(p0)..","..tostring(p1)..","..tostring(p2))
    if Type == 0 or Type == 7 or Type == 8 then
        TrackUI.ShowTeamLst()
    elseif Type == 1 then
        TrackUI.UpdateRoleAtt(p0, p1, p2)
    elseif Type == 3 then
        --发布了组队目标
        TrackUI.SwitchShowMatchBtn()
    end
end

function TrackUI.UpdateRoleAtt(roleIndex, key, value)
    print(tostring(roleIndex)..","..tostring(key)..","..tostring(value))
    if key == 1 then
        local _Face = _gt.GetUI("Face" .. (roleIndex + 1))
        if _Face ~= nil then
            local _RoleDB = DB.GetRole(tonumber(tostring(value)))
            if _RoleDB ~= nil then
                GUI.ImageSetImageID(_Face, tostring(_RoleDB.Head))
            end
        end
        --等级
    elseif key == 2 then
        local _RoleLevel = _gt.GetUI("RoleLevel" .. (roleIndex + 1))
        if _RoleLevel ~= nil then
            local Reincarnation = GUI.GetData(_RoleLevel, "Reincarnation")
            GUI.SetData(_RoleLevel, "Level", tostring(value))
            GUI.StaticSetText(_RoleLevel, tostring(value))
        end
        --门派
    elseif key == 3 then
        local _SchoolFlag = _gt.GetUI("SchoolFlag" .. (roleIndex + 1))
        if _SchoolFlag ~= nil then
            local _SchoolDB = DB.GetSchool(tonumber(tostring(value)))
            if _SchoolDB ~= nil then
                GUI.ImageSetImageID(_SchoolFlag, tostring(_SchoolDB.Icon))
            end
        end
        --转生
    elseif key == 9 then
        local _RoleLevel = _gt.GetUI("RoleLevel" .. (roleIndex + 1))
        if _RoleLevel ~= nil then
            local Level =  GUI.GetData(_RoleLevel, "Level")
            GUI.SetData(_RoleLevel, "Reincarnation", tostring(value))
            GUI.StaticSetText(_RoleLevel, Level.."级")
            --GUI.StaticSetText(_RoleLevel, tostring(value).."转"..Level.."级")                   --备份
        end
        --VIP等级
    elseif key == 224 then
        local _Face = _gt.GetUI("Face" .. (roleIndex + 1))
        HeadIcon.BindRoleVipLv(_Face, tonumber(tostring(value)))
    elseif key == 35 then --hp
        local _RoleHp = _gt.GetUI("_RoleHP" .. (roleIndex + 1))
        GUI.ScrollBarSetPos(_RoleHp,tonumber(tostring(value)))
    elseif key == 36 then --maxhp
        local _RoleHp = _gt.GetUI("_RoleHP" .. (roleIndex + 1))
        GUI.ScrollBarSetPos(_RoleHp,tonumber(tostring(value)))
    elseif key == 37 then --mp
        local _RoleMp = _gt.GetUI("_RoleMP" .. (roleIndex + 1))
        GUI.ScrollBarSetPos(_RoleMp,tonumber(tostring(value)))
    elseif key == 38 then --maxmp
        local _RoleMp = _gt.GetUI("_RoleMP" .. (roleIndex + 1))
        GUI.ScrollBarSetPos(_RoleMp,tonumber(tostring(value)))
    end
end

function TrackUI.GetTrackPanelHeight()
    if ScreenHeight >= 720 then
        return 390
    end

    return ScreenHeight - 330
end

function TrackUI.GetTrackPanelOffsetY()
    if ScreenHeight >= 720 then
        return -196
    end
    return (-196 + 360 - ScreenHeight / 2)
end

function TrackUI.OnSwitchTrackQuest(guid)
    local _QuestBtn = _gt.GetUI("QuestBtn")
    if _QuestBtn ~= nil then
        if GUI.GetVisible(_QuestBtn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(1)
        else
            --打开任务面板
            GUI.OpenWnd("QuestDlgUI")
        end
    end
end

function TrackUI.OnSwitchFightInfo(guid)
    local _FightInfoBtn = _gt.GetUI("FightInfoBtn")
    if _FightInfoBtn ~= nil then
        if GUI.GetVisible(_FightInfoBtn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(3)
        end
    end
end

function TrackUI.OnSwitchFightInfo2(guid)
    local _FightInfo2Btn = _gt.GetUI("FightInfo2Btn")
    if _FightInfo2Btn ~= nil then
        if GUI.GetVisible(_FightInfo2Btn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(4)
        end
    end
end

function TrackUI.OnSwitchFightInfo3(guid)
    local _FightInfo3Btn = _gt.GetUI("FightInfo3Btn")
    if _FightInfo3Btn ~= nil then
        if GUI.GetVisible(_FightInfo3Btn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(5)
        end
    end
end

function TrackUI.OnSwitchFightInfo4(guid)
    local _FightInfo4Btn = _gt.GetUI("FightInfo4Btn")
    if _FightInfo4Btn ~= nil then
        if GUI.GetVisible(_FightInfo4Btn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(6)
        end
    end
end

function TrackUI.OnSwitchFightInfo6(guid)
    local _FightInfo6Btn = _gt.GetUI("FightInfo6Btn")
    if _FightInfo6Btn ~= nil then
        if GUI.GetVisible(_FightInfo6Btn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(6)
        end
    end
end

function TrackUI.OnSwitchBattleBagBtn(guid)
    local _BattleBagBtn = _gt.GetUI("BattleBagBtn")
    if _BattleBagBtn ~= nil then
        if GUI.GetVisible(_BattleBagBtn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(7)
        end
    end
end

function TrackUI.OnSwitchDungeon()
    local _DungeonBtn = _gt.GetUI("DungeonBtn")
    if _DungeonBtn ~= nil then
        if GUI.GetVisible(_DungeonBtn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(8)
        end
    end
end

function TrackUI.OnSwitchChallengeBtn()
    local _ChallengeBtn = _gt.GetUI("ChallengeBtn")
    if _ChallengeBtn ~= nil then
        if GUI.GetVisible(_ChallengeBtn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(10)
        end
    end
end

function TrackUI.OnSwitchFightInfo7(guid)
    local _FightInfo7Btn = _gt.GetUI("FightInfo7Btn")
    if _FightInfo7Btn ~= nil then
        if GUI.GetVisible(_FightInfo7Btn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(11)
        end
    end
end

function TrackUI.OnSwitchFightInfo8(guid)
    local _FightInfo8Btn = _gt.GetUI("FightInfo8Btn")
    if _FightInfo8Btn ~= nil then
        if GUI.GetVisible(_FightInfo8Btn) == false then
            --切换到任务追踪页签
            TrackUI.OnSwitchTrackPanel(12)
        end
    end
end

function TrackUI.OnSwitchTrackTeam(Key)

    local _TeamBtn = _gt.GetUI("TeamBtn")
    if _TeamBtn ~= nil then
        if GUI.GetVisible(_TeamBtn) == false then
            --切换到队伍页签
            TrackUI.OnSwitchTrackPanel(2)
        else
            if not CanSystemOpen(2) then
                CL.SendNotify(NOTIFY.ShowBBMsg, tostring(MainUIBtnOpenDef.Data[2].Lv).."级开启队伍功能")
                return
            end
            --打开组队界面
            GUI.OpenWnd("TeamPanelUI")
        end
    end
end

function TrackUI.OnSwitchTrackPanel(showType)

    TrackUI.ShowType = showType

    local _QuestBtn = _gt.GetUI("QuestBtn")
    local _TeamBtn = _gt.GetUI("TeamBtn")
    local _FightInfoBtn = _gt.GetUI("FightInfoBtn")
    local _FightInfo2Btn = _gt.GetUI("FightInfo2Btn")
	local _FightInfo3Btn = _gt.GetUI("FightInfo3Btn")
    local _FightInfo4Btn = _gt.GetUI("FightInfo4Btn")
    local _FightInfo6Btn = _gt.GetUI("FightInfo6Btn")
    local _FightInfo7Btn = _gt.GetUI("FightInfo7Btn")
    local _FightInfo8Btn = _gt.GetUI("FightInfo8Btn")
    local _DungeonBtn = _gt.GetUI("DungeonBtn")
    local _BattleBagBtn = _gt.GetUI("BattleBagBtn")
    local _RoleLstBack = _gt.GetUI("RoleLstBack")
    local _QuestLstBack = _gt.GetUI("QuestLstBack")
    local _FightInfoBack = _gt.GetUI("FightInfoBack")
    local _FightInfo2Back = _gt.GetUI("FightInfo2Back")
	local _FightInfo3Back = _gt.GetUI("FightInfo3Back")
    local _FightInfo4Back = _gt.GetUI("FightInfo4Back")
    local _FightInfo6Back = _gt.GetUI("FightInfo6Back")
    local _FightInfo7Back = _gt.GetUI("FightInfo7Back")
    local _FightInfo8Back = _gt.GetUI("FightInfo8Back")
    local _BattleBagBack = _gt.GetUI("BattleBagBack")
    local _DungeonBack = _gt.GetUI("DungeonBack")
    local _ChallengeBack = _gt.GetUI("ChallengeBack")   -- 生存挑战
    local _TitleQuest = _gt.GetUI("TitleQuest")
    local _TitleTeam = _gt.GetUI("TitleTeam")
    local _TitleFightInfo = _gt.GetUI("TitleFightInfo")
    local _TitleFightInfo2 = _gt.GetUI("TitleFightInfo2")
	local _TitleFightInfo3 = _gt.GetUI("TitleFightInfo3")
    local _TitleFightInfo4 = _gt.GetUI("TitleFightInfo4")
    local _TitleFightInfo6 = _gt.GetUI("TitleFightInfo6")
    local _TitleFightInfo7 = _gt.GetUI("TitleFightInfo7")
    local _TitleFightInfo8 = _gt.GetUI("TitleFightInfo8")
    local _TitleDungeon = _gt.GetUI("TitleDungeon")
    local _TitleBattleBag = _gt.GetUI("TitleBattleBag")
    local _TitleBack = _gt.GetUI("TitleBack")
    local _TitleChallenge = _gt.GetUI("TitleChallenge") -- 生存挑战
    local _VipInfoPanel = _gt.GetUI("VipInfoPanel")
    local _ChallengeBtn = _gt.GetUI("ChallengeBtn") -- 生存挑战
    local gangConspiracyBtn = _gt.GetUI("gangConspiracyBtn") -- 帮派密谋按钮
    local gangConspiracyTxt = _gt.GetUI("gangConspiracyTxt") -- 帮派密谋标题
    local gangConspiracyBack = _gt.GetUI("gangConspiracyBack") -- 帮派密谋下面UI

    local crossServerWarfareBtn = _gt.GetUI("crossServerWarfareBtn")  --跨服战按钮
    local crossServerWarfareTxt = _gt.GetUI("crossServerWarfareTxt") --跨服战标题
    local crossServerWarfareBack = _gt.GetUI("crossServerWarfareBack") --跨服战下面UI



    if showType == 13 then --帮派密谋

        if gangConspiracyBtn == nil or gangConspiracyBack == nil or gangConspiracyTxt == nil then

            TrackUI.SwitchQuestOrGangConspiracy6Node()

            return

        end

    elseif showType == 14 then --跨服战

        if crossServerWarfareBtn == nil or crossServerWarfareTxt == nil or crossServerWarfareBack == nil then

            TrackUI.SwitchQuestOrCrossServerWarfare6Node()

            return

        end

    end

    if _QuestBtn ~= nil and _TeamBtn ~= nil and _RoleLstBack ~= nil
            and _QuestLstBack ~= nil and _TitleQuest ~= nil and _TitleTeam ~= nil
            and _FightInfoBtn ~= nil and _FightInfoBack ~= nil and _TitleFightInfo ~= nil
            and _FightInfo2Btn ~= nil and _FightInfo2Back ~= nil and _TitleFightInfo2 ~= nil
			and _FightInfo3Btn ~= nil and _FightInfo3Back ~= nil and _TitleFightInfo3 ~= nil
            and _FightInfo4Btn ~= nil and _FightInfo4Back ~= nil and _TitleFightInfo4 ~= nil
            and _BattleBagBtn ~= nil and _BattleBagBack ~= nil and _TitleBattleBag ~= nil
            and _TitleBack ~= nil and _DungeonBtn ~= nil and _DungeonBack ~= nil and _TitleDungeon ~= nil
            and _FightInfo6Btn ~= nil and _FightInfo6Back ~= nil and _TitleFightInfo6 ~= nil
            and _ChallengeBtn ~= nil and _TitleChallenge ~= nil and _ChallengeBack ~= nil
            and _FightInfo7Btn ~= nil and _FightInfo7Back ~= nil and _TitleFightInfo7 ~= nil
            and _FightInfo8Btn ~= nil and _FightInfo8Back ~= nil and _TitleFightInfo8 ~= nil
    then
        local IsShow = GUI.GetVisible(_TitleBack)
        GUI.SetVisible(_QuestBtn, showType==1)
        GUI.SetVisible(_TeamBtn, showType == 2)
        GUI.SetVisible(_FightInfoBtn, showType == 3)
        GUI.SetVisible(_FightInfo2Btn, showType == 4)
		GUI.SetVisible(_FightInfo3Btn, showType == 5)
        GUI.SetVisible(_FightInfo4Btn, showType == 6)
        GUI.SetVisible(_BattleBagBtn, showType == 7)
        GUI.SetVisible(_DungeonBtn, showType == 8)
        GUI.SetVisible(_FightInfo6Btn,showType == 9)
        GUI.SetVisible(_ChallengeBtn, showType == 10)
        GUI.SetVisible(_FightInfo7Btn,showType == 11)
        GUI.SetVisible(_FightInfo8Btn,showType == 12)
        GUI.SetVisible(gangConspiracyBtn,showType == 13)--帮派密谋
        GUI.SetVisible(crossServerWarfareBtn,showType == 14)--跨服战

        GUI.SetVisible(_QuestLstBack, showType == 1 and IsShow)
        GUI.SetVisible(_RoleLstBack, showType == 2 and IsShow)
        GUI.SetVisible(_FightInfoBack, showType==3 and IsShow)
        GUI.SetVisible(_FightInfo2Back, showType==4 and IsShow)
		GUI.SetVisible(_FightInfo3Back, showType==5 and IsShow)
        GUI.SetVisible(_FightInfo4Back, showType==6 and IsShow)
		GUI.SetVisible(_BattleBagBack, showType==7 and IsShow)
        GUI.SetVisible(_DungeonBack, showType==8 and IsShow)
        GUI.SetVisible(_FightInfo6Back, showType==9 and IsShow)
        GUI.SetVisible(_ChallengeBack, showType==10 and IsShow)
        GUI.SetVisible(_FightInfo7Back, showType==11 and IsShow)
        GUI.SetVisible(_FightInfo8Back, showType==12 and IsShow)
        GUI.SetVisible(gangConspiracyBack, showType==13 and IsShow)--帮派密谋
        GUI.SetVisible(crossServerWarfareBack,showType == 14)--跨服战

        GUI.SetVisible(_TitleFightInfo, TrackUI.QuestOrFightInfoMode==1)
        GUI.SetVisible(_TitleQuest, TrackUI.QuestOrFightInfoMode==0)
        GUI.SetVisible(_TitleFightInfo2, TrackUI.QuestOrFightInfoMode==2)
		GUI.SetVisible(_TitleFightInfo3, TrackUI.QuestOrFightInfoMode==3)
        GUI.SetVisible(_TitleTeam, TrackUI.QuestOrFightInfoMode~=4)
        GUI.SetVisible(_TitleFightInfo4, TrackUI.QuestOrFightInfoMode==4)
		GUI.SetVisible(_TitleBattleBag, TrackUI.QuestOrFightInfoMode==4)
        GUI.SetVisible(_TitleDungeon, TrackUI.QuestOrFightInfoMode==5)
        GUI.SetVisible(_TitleFightInfo6, TrackUI.QuestOrFightInfoMode==6)
        GUI.SetVisible(_TitleChallenge, TrackUI.QuestOrFightInfoMode==7)
        GUI.SetVisible(_TitleFightInfo7, TrackUI.QuestOrFightInfoMode==8)
        GUI.SetVisible(_TitleFightInfo8, TrackUI.QuestOrFightInfoMode==9)
        GUI.SetVisible(gangConspiracyTxt, TrackUI.QuestOrFightInfoMode==10)--帮派密谋
        GUI.SetVisible(crossServerWarfareTxt, TrackUI.QuestOrFightInfoMode==11)--跨服战
		
        if showType == 1 then
            GUI.SetColor(_TitleQuest, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 2 then
            GUI.SetColor(_TitleQuest, WhiteColor)
            GUI.SetColor(_TitleTeam, BrownColor)
            GUI.SetColor(_TitleFightInfo, WhiteColor)
            GUI.SetColor(_TitleFightInfo2, WhiteColor)
			GUI.SetColor(_TitleFightInfo3, WhiteColor)
			GUI.SetColor(_TitleFightInfo4, WhiteColor)
			GUI.SetColor(_TitleFightInfo6, WhiteColor)
            GUI.SetColor(_TitleDungeon, WhiteColor)
            GUI.SetColor(_TitleChallenge, WhiteColor)
            GUI.SetColor(_TitleFightInfo7, WhiteColor)
            GUI.SetColor(_TitleFightInfo8, WhiteColor)

            if gangConspiracyTxt ~= nil then--帮派密谋

                GUI.SetColor(gangConspiracyTxt, WhiteColor)

            elseif crossServerWarfareTxt ~= nil then--跨服战

                GUI.SetColor(crossServerWarfareTxt, WhiteColor)

            end

        elseif showType == 3 then
            GUI.SetColor(_TitleFightInfo, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 4 then
            GUI.SetColor(_TitleFightInfo2, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 5 then
            GUI.SetColor(_TitleFightInfo3, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 6 then
            GUI.SetColor(_TitleFightInfo4, BrownColor)
            GUI.SetColor(_TitleBattleBag, WhiteColor)
        elseif showType == 7 then
            GUI.SetColor(_TitleFightInfo4, WhiteColor)
            GUI.SetColor(_TitleBattleBag, BrownColor)
        elseif showType == 8 then
            GUI.SetColor(_TitleDungeon, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 9 then
            GUI.SetColor(_TitleFightInfo6, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 10 then
            GUI.SetColor(_TitleChallenge, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 11 then
            GUI.SetColor(_TitleFightInfo7, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 12 then
            GUI.SetColor(_TitleFightInfo8, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 13 then --帮派密谋
            GUI.SetColor(gangConspiracyTxt, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        elseif showType == 14 then --跨服战
            GUI.SetColor(crossServerWarfareTxt, BrownColor)
            GUI.SetColor(_TitleTeam, WhiteColor)
        end
    end

    if _VipInfoPanel then
        GUI.SetVisible(_VipInfoPanel, showType==1)
    end
end

function TrackUI.OnClickTrackNode(parameter)
    local _TitleBack = _gt.GetUI("TitleBack")
    local _TrackArrow = _gt.GetUI("TrackArrow")
    local _RoleLstBack = _gt.GetUI("RoleLstBack")
    local _QuestLstBack = _gt.GetUI("QuestLstBack")
    local _FightInfoBack = _gt.GetUI("FightInfoBack")
    local _FightInfo2Back = _gt.GetUI("FightInfo2Back")
	local _FightInfo3Back = _gt.GetUI("FightInfo3Back")
    local _FightInfo4Back = _gt.GetUI("FightInfo4Back")
    local _FightInfo6Back = _gt.GetUI("FightInfo6Back")
    local _BattleBagBack = _gt.GetUI("BattleBagBack")
    local _DungeonBack = _gt.GetUI("DungeonBack")
    local _VipInfoPanel = _gt.GetUI("VipInfoPanel")
	local _ChallengeBack = _gt.GetUI("ChallengeBack")
    local _FightInfo7Back = _gt.GetUI("FightInfo7Back")
    local _FightInfo8Back = _gt.GetUI("FightInfo8Back")
    local _JinDouYunBtn = _gt.GetUI("JinDouYunBtn")
    local gangConspiracyBack = _gt.GetUI("gangConspiracyBack")--帮派密谋
    local crossServerWarfareBack = _gt.GetUI("crossServerWarfareBack") --跨服战

    local IsShow = GUI.GetVisible(_TitleBack) == false
    if _TitleBack and _TrackArrow and _RoleLstBack and _QuestLstBack and _FightInfoBack then
        GUI.SetVisible(_TitleBack, IsShow)

        GUI.SetVisible(_RoleLstBack, TrackUI.ShowType==2 and IsShow)
        GUI.SetVisible(_QuestLstBack, TrackUI.ShowType==1 and IsShow)
        GUI.SetVisible(_FightInfoBack, TrackUI.ShowType==3 and IsShow)
        GUI.SetVisible(_FightInfo2Back, TrackUI.ShowType==4 and IsShow)
		GUI.SetVisible(_FightInfo3Back, TrackUI.ShowType==5 and IsShow)
        GUI.SetVisible(_FightInfo4Back, TrackUI.ShowType==6 and IsShow)
		GUI.SetVisible(_BattleBagBack, TrackUI.ShowType==7 and IsShow)
        GUI.SetVisible(_DungeonBack, TrackUI.ShowType==8 and IsShow)
        GUI.SetVisible(_FightInfo6Back, TrackUI.ShowType==9 and IsShow)
		GUI.SetVisible(_ChallengeBack, TrackUI.ShowType==10 and IsShow)
        GUI.SetVisible(_FightInfo7Back, TrackUI.ShowType==11 and IsShow)
        GUI.SetVisible(_FightInfo8Back, TrackUI.ShowType==12 and IsShow)

        if gangConspiracyBack then

            GUI.SetVisible(gangConspiracyBack, TrackUI.ShowType==13 and IsShow)

        end

        if crossServerWarfareBack then

            GUI.SetVisible(crossServerWarfareBack, TrackUI.ShowType==14 and IsShow)

        end

        if MainUI.IsJindouyunTransfer then
            GUI.SetVisible(_JinDouYunBtn, IsShow)
        else
            GUI.SetVisible(_JinDouYunBtn, false)
        end
        if GUI.GetVisible(_TitleBack) then
            GUI.ButtonSetImageID(_TrackArrow, "1800202270")
        else
            GUI.ButtonSetImageID(_TrackArrow, "1800202280")
        end
    end
    if _VipInfoPanel then
        GUI.SetVisible(_VipInfoPanel, TrackUI.ShowType==1 and IsShow)
    end
end

function TrackUI.OnClickTitleBack(guid)
    local _TeamBtn = _gt.GetUI("TeamBtn")
    local IsShowTeam = GUI.GetVisible(_TeamBtn)
    local _BattleBagBtn = _gt.GetUI("BattleBagBtn")
    local IsShowBattleBag = GUI.GetVisible(_BattleBagBtn)
    if TrackUI.QuestOrFightInfoMode == 0 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 1 or 2)
    elseif TrackUI.QuestOrFightInfoMode == 1 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 3 or 2)
    elseif TrackUI.QuestOrFightInfoMode == 2 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 4 or 2)
    elseif TrackUI.QuestOrFightInfoMode == 3 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 5 or 2)
    elseif TrackUI.QuestOrFightInfoMode == 4 then
        TrackUI.OnSwitchTrackPanel(IsShowBattleBag and 6 or 7)
    elseif TrackUI.QuestOrFightInfoMode == 5 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 8 or 2)
    elseif TrackUI.QuestOrFightInfoMode == 6 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 9 or 2)
    elseif TrackUI.QuestOrFightInfoMode == 7 then   -- 生存挑战
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 10 or 2)
    elseif TrackUI.QuestOrFightInfoMode == 8 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 11 or 2)
    elseif TrackUI.QuestOrFightInfoMode == 9 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 12 or 2)
    elseif TrackUI.QuestOrFightInfoMode == 10 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 13 or 2)--帮派密谋
    elseif TrackUI.QuestOrFightInfoMode == 11 then
        TrackUI.OnSwitchTrackPanel(IsShowTeam and 14 or 2)--跨服战
    end
end

function TrackUI.ShowTeamLst()
    local _SeatScroll = _gt.GetUI("SeatScrollLst")
    local _RoleLstBack = _gt.GetUI("RoleLstBack")

    --角色列表
    local _TeamInfo = LD.GetTeamInfo()
    local _RoleNum = 0
    if tostring(_TeamInfo.team_guid) ~= "0" and _TeamInfo.members ~= nil then
        _RoleNum = _TeamInfo.members.Length
    end

    local _MemberInfos = _TeamInfo.members
    --首先隐藏多余的头像信息
    for i = _RoleNum + 1, 5 do
        local _RoleLst = _gt.GetUI("FaceBack" .. i)
        if _RoleLst ~= nil then
            GUI.SetVisible(_RoleLst, false)
        end
    end
    --test("当前队伍人数：".._RoleNum..", 得到信息数量：".._MemberInfos.Count)
    for i = 1, _RoleNum do
        local _RoleLst = _gt.GetUI("FaceBack" .. i)
        if _RoleLst == nil then
            --头像背景框
            local _FaceBack = GUI.ImageCreate(_SeatScroll, "FaceBack" .. i, "1800600070", -82, 5 + (i - 1) * 79)
            _gt.BindName(_FaceBack, "FaceBack" .. i)
            SetSameAnchorAndPivot(_FaceBack, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_FaceBack, false)

            --玩家名字
            local _RoleName = GUI.CreateStatic(_FaceBack, "RoleName" .. i, "谁是野猪怪呢", 8, 6, 135, 28, "system", false)
            _gt.BindName(_RoleName, "RoleName" .. i)
            SetAnchorAndPivot(_RoleName, UIAnchor.TopRight, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(_RoleName, UIDefine.FontSizeM)
            GUI.SetColor(_RoleName, UIDefine.GreenStdColor)
            GUI.SetIsOutLine(_RoleName, true)
            GUI.SetOutLine_Color(_RoleName, UIDefine.BlackColor)
            GUI.SetOutLine_Distance(_RoleName, 1)
            GUI.StaticSetAlignment(_RoleName, TextAnchor.MiddleLeft)

            --等级
            local _RoleLevel = GUI.CreateStatic(_FaceBack, "RoleLevel" .. i, "12", 93, -15, 120, 35)
            _gt.BindName(_RoleLevel, "RoleLevel" .. i)
            SetAnchorAndPivot(_RoleLevel, UIAnchor.Right, UIAroundPivot.Left)
            GUI.StaticSetFontSize(_RoleLevel, UIDefine.FontSizeM)
            GUI.SetColor(_RoleLevel, UIDefine.WhiteColor)
            GUI.SetIsOutLine(_RoleLevel, true)
            GUI.SetOutLine_Color(_RoleLevel, UIDefine.BlackColor)
            GUI.SetOutLine_Distance(_RoleLevel, 1)
            GUI.StaticSetAlignment(_RoleLevel, TextAnchor.MiddleCenter)

            --红蓝条
            local _RoleHP=GUI.ScrollBarCreate(_FaceBack,"hpSlider","","1800408120","1800408110",75,8,120,18, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
            GUI.ScrollBarSetFillSize(_RoleHP,Vector2.New(120,18))
            GUI.ScrollBarSetBgSize(_RoleHP,Vector2.New(120,18))
            SetSameAnchorAndPivot(_RoleHP, UILayout.Left)
            GUI.SetIsRaycastTarget(_RoleHP,false)
            _gt.BindName(_RoleHP, "_RoleHP" .. i)

            local _RoleMP=GUI.ScrollBarCreate(_FaceBack,"mpSlider","","1800408130","1800408110",75,27,120,18, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
            GUI.ScrollBarSetFillSize(_RoleMP,Vector2.New(120,18))
            GUI.ScrollBarSetBgSize(_RoleMP,Vector2.New(120,18))
            SetSameAnchorAndPivot(_RoleMP, UILayout.Left)
            GUI.SetIsRaycastTarget(_RoleMP,false)
            _gt.BindName(_RoleMP, "_RoleMP" .. i)

            --门派标记
            local _SchoolFlag = GUI.ImageCreate(_FaceBack, "SchoolFlag" .. i, "1800408020", 155, 20,false, 30, 30)
            _gt.BindName(_SchoolFlag, "SchoolFlag" .. i)
            SetAnchorAndPivot(_SchoolFlag, UIAnchor.Right, UIAroundPivot.Center)

            --点击响应区域
            local _Node = GUI.ImageCreate(_FaceBack, "Node", "1800499999", 0, 0, false, 240, 68)
            SetSameAnchorAndPivot(_Node, UILayout.TopLeft)
            _Node:RegisterEvent(UCE.PointerClick)
            GUI.SetData(_Node, "NodeIndex", i)
            GUI.SetIsRaycastTarget(_Node, true)
            GUI.RegisterUIEvent(_Node, UCE.PointerClick, "TrackUI", "OnClickTeamRole")

            --头像
            local headRes = tostring(CL.GetRoleHeadIcon())
			if not headRes or headRes == "0" then
                headRes = "1900000000"  -- 此处如果传入0会报错，所以填一个默认值
            end
            local _Face = HeadIcon.Create(_FaceBack, "Face" .. i, headRes,  0, 0, 60, 60)
            _gt.BindName(_Face, "Face" .. i)
            SetSameAnchorAndPivot(_Face, UILayout.Center)
            HeadIcon.BindRoleGuid(_Face)
            GUI.RegisterUIEvent(_Face, UCE.PointerClick, "TrackUI", "OnClickTeamRoleFace")

            --暂离标记
            local _TeamLeaveFlag = GUI.ImageCreate(_Face, "TeamLeaveFlag" .. i, "1800607160", 0, 0)
            _gt.BindName(_TeamLeaveFlag, "TeamLeaveFlag" .. i)
            SetSameAnchorAndPivot(_TeamLeaveFlag, UILayout.Center)
            GUI.SetIsRaycastTarget(_TeamLeaveFlag, false)

            --离线标记
            local _TeamOfflineFlag = GUI.ImageCreate(_Face, "TeamOfflineFlag" .. i, "1800001240", 0, 0, false, 60, 60)
            _gt.BindName(_TeamOfflineFlag, "TeamOfflineFlag" .. i)
            SetSameAnchorAndPivot(_TeamOfflineFlag, UILayout.Center)
            GUI.SetIsRaycastTarget(_TeamOfflineFlag, false)
            local pic = GUI.ImageCreate(_TeamOfflineFlag, "pic", "1800604050", 0, 0, false, 55, 30)
            SetSameAnchorAndPivot(pic, UILayout.Center)

            --队长标记
            local _LeaderFlag = GUI.ImageCreate(_Face, "LeaderFlag" .. i, "1800607230", -4, -3)
            _gt.BindName(_LeaderFlag, "LeaderFlag" .. i)
            SetSameAnchorAndPivot(_LeaderFlag, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_LeaderFlag, false)

            --分割线
            local _Line = GUI.ImageCreate(_FaceBack, "Line", "1800607100", 60, 41)
            SetAnchorAndPivot(_Line, UIAnchor.Right, UIAroundPivot.Center)
            GUI.SetVisible(_Line, i ~= _RoleNum)
        end

        --恢复显示
        _RoleLst = _gt.GetUI("FaceBack" .. i)
        GUI.SetVisible(_RoleLst, true)

        local roleInfo = {Role=1, Vip=1, Reincarnation=1, Level=1, Job=1}
        if _MemberInfos[i - 1].guid == LD.GetSelfGUID() then
            roleInfo.Role = CL.GetIntAttr(RoleAttr.RoleAttrRole)
            roleInfo.Vip = CL.GetIntAttr(RoleAttr.RoleAttrVip)
            roleInfo.Reincarnation = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
            roleInfo.Level = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
            roleInfo.Job = CL.GetIntAttr(RoleAttr.RoleAttrJob1)
            roleInfo.Hp = CL.GetIntAttr(RoleAttr.RoleAttrHp)
            roleInfo.Mp = CL.GetIntAttr(RoleAttr.RoleAttrMp)
            roleInfo.MaxHp = CL.GetIntAttr(RoleAttr.RoleAttrHpLimit)
            roleInfo.MaxMp = CL.GetIntAttr(RoleAttr.RoleAttrMpLimit)
        else
            roleInfo.Role = _TeamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrRole)
            roleInfo.Vip = _TeamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrVip)
            roleInfo.Reincarnation = _TeamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrReincarnation)
            roleInfo.Level = _TeamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrLevel)
            roleInfo.Job = _TeamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrJob1)
            roleInfo.Hp = _TeamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrHp) 
            roleInfo.Mp = _TeamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrMp)
            roleInfo.MaxHp = _TeamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrHpLimit) 
            roleInfo.MaxMp = _TeamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrMpLimit)
        end
        tempRoleInfo[i] = roleInfo
        --头像
        local _Face = _gt.GetUI("Face" .. i)
        if _Face ~= nil then
            GUI.SetData(_Face, "RoleGUID", _MemberInfos[i - 1].guid)
            local _RoleDB = DB.GetRole(roleInfo.Role)
            if _RoleDB ~= nil then
                GUI.ImageSetImageID(_Face, tostring(_RoleDB.Head))
            end
            HeadIcon.BindRoleVipLv(_Face, roleInfo.Vip)
            GUI.ImageSetGray(_Face, _MemberInfos[i - 1].temp_leave == 2)
        end

        --暂离标记
        local _TeamLeaveFlag = _gt.GetUI("TeamLeaveFlag" .. i)
        if _TeamLeaveFlag ~= nil then
            GUI.SetVisible(_TeamLeaveFlag, _MemberInfos[i - 1].temp_leave == 1)
        end

        --离线标记
        local _TeamOfflineFlag = _gt.GetUI("TeamOfflineFlag" .. i)
        if _TeamOfflineFlag ~= nil then
            GUI.SetVisible(_TeamOfflineFlag, _MemberInfos[i - 1].temp_leave == 2)
        end

        --队长标记
        local _LeaderFlag = _gt.GetUI("LeaderFlag" .. i)
        if _LeaderFlag ~= nil then
            GUI.SetVisible(_LeaderFlag, i == 1)
        end

        --名字
        local _RoleName = _gt.GetUI("RoleName" .. i)
        if _RoleName ~= nil then
            GUI.StaticSetText(_RoleName, _MemberInfos[i - 1].name)
        end
        --等级
        local _RoleLevel = _gt.GetUI("RoleLevel" .. i)
        if _RoleLevel ~= nil then
            GUI.SetData(_RoleLevel, "Level", tostring(roleInfo.Level))
            GUI.StaticSetText(_RoleLevel, roleInfo.Level)--.."级"
        end
        --门派标记
        local _SchoolFlag = _gt.GetUI("SchoolFlag" .. i)
        if _SchoolFlag ~= nil then
            local _SchoolDB = DB.GetSchool(roleInfo.Job)
            if _SchoolDB ~= nil then
                GUI.ImageSetImageID(_SchoolFlag, tostring(_SchoolDB.BigIcon))
            end
        end

        local _RoleHp = _gt.GetUI("_RoleHP" .. i)
        --print(roleInfo.Hp ..",".. roleInfo.MaxHp)
        --print("progress===>"..roleInfo.Hp / roleInfo.MaxHp)
        if _RoleHp ~= nil then
            GUI.ScrollBarSetPos(_RoleHp,(roleInfo.Hp / roleInfo.MaxHp))
        end

        local _RoleMp = _gt.GetUI("_RoleMP" .. i)
        --print(roleInfo.Mp ..",".. roleInfo.MaxMp)
        --print("progress===>"..roleInfo.Mp / roleInfo.MaxMp)
        if _RoleMp ~= nil then
            GUI.ScrollBarSetPos(_RoleMp,(roleInfo.Mp / roleInfo.MaxMp))
        end

    end

    local _SeatScroll2 = _gt.GetUI("SeatScroll")
    if _SeatScroll2 ~= nil then
        GUI.ScrollRectSetChildSize(_SeatScroll2, Vector2.New(66, 66))--Vector2.New(250, 80 * _RoleNum))
    end

    local _CreateTeamBtn = _gt.GetUI("CreateTeamBtn")
    local _FindTeamBtn = _gt.GetUI("FindTeamBtn")
    if _CreateTeamBtn ~= nil then
        GUI.SetVisible(_CreateTeamBtn, _RoleNum == 0)
        GUI.SetVisible(_FindTeamBtn, _RoleNum == 0)
    else
        if _RoleNum == 0 and _CreateTeamBtn == nil then
            --创建队伍按钮
            _CreateTeamBtn = GUI.ButtonCreate(_RoleLstBack, "CreateTeamBtn", "1800602030", 56, 60, Transition.ColorTint, "创建队伍")
            _gt.BindName(_CreateTeamBtn, "CreateTeamBtn")
            SetSameAnchorAndPivot(_CreateTeamBtn, UILayout.TopLeft)
            GUI.ButtonSetTextFontSize(_CreateTeamBtn, 26)
            GUI.ButtonSetTextColor(_CreateTeamBtn, UIDefine.WhiteColor)
            GUI.SetIsOutLine(_CreateTeamBtn, true)
            GUI.SetOutLine_Color(_CreateTeamBtn, UIDefine.Orange2Color)
            GUI.SetOutLine_Distance(_CreateTeamBtn, 1)
            GUI.RegisterUIEvent(_CreateTeamBtn, UCE.PointerClick, "TrackUI", "OnCreateTeam")

            --寻找队伍按钮
            local _FindTeamBtn = GUI.ButtonCreate( _RoleLstBack,"FindTeamBtn", "1800602030", 56, 130, Transition.ColorTint, "寻找队伍")
            _gt.BindName(_FindTeamBtn, "FindTeamBtn")
            SetSameAnchorAndPivot(_FindTeamBtn, UILayout.TopLeft)
            GUI.ButtonSetTextFontSize(_FindTeamBtn, 26)
            GUI.ButtonSetTextColor(_FindTeamBtn, UIDefine.WhiteColor)
            GUI.SetIsOutLine(_FindTeamBtn, true)
            GUI.SetOutLine_Color(_FindTeamBtn, UIDefine.Orange2Color)
            GUI.SetOutLine_Distance(_FindTeamBtn, 1)
            GUI.RegisterUIEvent(_FindTeamBtn, UCE.PointerClick, "TrackUI", "OnFindTeamBtn")

            --发布招募按钮
            local _TeamPlatformBtn = GUI.ButtonCreate( _RoleLstBack,"TeamPlatformBtn", "1800602030", 0, 160, Transition.ColorTint, "发布招募", 175, 47, false)
            _gt.BindName(_TeamPlatformBtn, "TeamPlatformBtn")
            SetSameAnchorAndPivot(_TeamPlatformBtn, UILayout.Center)
            GUI.ButtonSetTextFontSize(_TeamPlatformBtn, 26)
            GUI.ButtonSetTextColor(_TeamPlatformBtn, UIDefine.WhiteColor)
            GUI.SetIsOutLine(_TeamPlatformBtn, true)
            GUI.SetOutLine_Color(_TeamPlatformBtn, UIDefine.Orange2Color)
            GUI.SetOutLine_Distance(_TeamPlatformBtn, 1)
            GUI.SetVisible(_TeamPlatformBtn, false)
            GUI.RegisterUIEvent(_TeamPlatformBtn, UCE.PointerClick, "TrackUI", "OnTeamPlatformBtn")

            --快速招募按钮
            local _QuickMatchBtn = GUI.ButtonCreate( _RoleLstBack,"QuickMatchBtn", "1800602030", 0, 160, Transition.ColorTint, "快速招募", 175, 47, false)
            _gt.BindName(_QuickMatchBtn, "QuickMatchBtn")
            SetSameAnchorAndPivot(_QuickMatchBtn, UILayout.Center)
            GUI.ButtonSetTextFontSize(_QuickMatchBtn, 26)
            GUI.ButtonSetTextColor(_QuickMatchBtn, UIDefine.WhiteColor)
            GUI.SetIsOutLine(_QuickMatchBtn, true)
            GUI.SetOutLine_Color(_QuickMatchBtn, UIDefine.Orange2Color)
            GUI.SetOutLine_Distance(_QuickMatchBtn, 1)
            GUI.SetVisible(_QuickMatchBtn, false)
            GUI.RegisterUIEvent(_QuickMatchBtn, UCE.PointerClick, "TrackUI", "OnQuickMatchBtn")
        end
    end
    --切换显示 发布招募 / 快速招募 按钮
    TrackUI.SwitchShowMatchBtn()
end

function TrackUI.SwitchShowMatchBtn()
    local _TeamInfo = LD.GetTeamInfo()
    local _RoleNum = 0
    if tostring(_TeamInfo.team_guid) ~= "0" and _TeamInfo.members ~= nil then
        _RoleNum = _TeamInfo.members.Length
    end

    local haveTeamTarget = false
    local TeamTargetInfo = LD.GetTeamTarget()
    if TeamTargetInfo.Count>=6 and TeamTargetInfo[0] ~= 0 then
        haveTeamTarget = true
    end

    local _TeamPlatformBtn = _gt.GetUI("TeamPlatformBtn")
    if _TeamPlatformBtn then
        GUI.SetVisible(_TeamPlatformBtn, _RoleNum >= 1 and _RoleNum < 5 and not haveTeamTarget)
    end

    local IsShowQuickMatch = _RoleNum >= 1 and _RoleNum < 5 and haveTeamTarget
    local _QuickMatchBtn = _gt.GetUI("QuickMatchBtn")
    if _QuickMatchBtn then
        GUI.SetVisible(_QuickMatchBtn, IsShowQuickMatch)
    end
    if not IsShowQuickMatch then
        TrackUI.StopTimerResetQuickMatchBtn()
    end
end

function TrackUI.OnTeamPlatformBtn()
    GUI.OpenWnd("TeamPlatformUI")
end

function TrackUI.OnQuickMatchBtn()
    TrackUI.QuickMatchTimeCount = 30
    TrackUI.QuickMatchTimer = Timer.New(TrackUI.OnQuickMatchBtnListener, 1, 30)
    TrackUI.QuickMatchTimer:Start()
    local _QuickMatchBtn = _gt.GetUI("QuickMatchBtn")
    if _QuickMatchBtn then
        GUI.ButtonSetText(_QuickMatchBtn, "快速招募("..TrackUI.QuickMatchTimeCount.."s)")
        GUI.ButtonSetShowDisable(_QuickMatchBtn, false)
    end
    TrackUI.OnApplyQuickMatch()
end

function TrackUI.ShowQuickMatchPanel()
    GlobalUtils.ShowBoxMsg("提示","队伍人数不满足，请选择操作：","TrackUI","快速匹配","OnApplyQuickMatch","发布招募", "OnQuickMatchPanelBtn",
            true,nil,nil,nil,true,nil)
end

function TrackUI.OnQuickMatchPanelBtn()
    TrackUI.OnTeamPlatformBtn()
end

function TrackUI.OnApplyQuickMatch()
    CL.SendNotify(NOTIFY.SubmitForm,"FormTeam","ApplyHostTeamer")
end

function TrackUI.StopTimerResetQuickMatchBtn()
    if TrackUI.QuickMatchTimer ~= nil then
        TrackUI.QuickMatchTimer:Stop()
        TrackUI.QuickMatchTimer = nil

        local _QuickMatchBtn = _gt.GetUI("QuickMatchBtn")
        if _QuickMatchBtn then
            GUI.ButtonSetText(_QuickMatchBtn, "快速招募")
            GUI.ButtonSetShowDisable(_QuickMatchBtn, true)
        end
    end
end

function TrackUI.OnQuickMatchBtnListener()
    TrackUI.QuickMatchTimeCount = TrackUI.QuickMatchTimeCount - 1
    local _QuickMatchBtn = _gt.GetUI("QuickMatchBtn")
    if _QuickMatchBtn then
        GUI.ButtonSetText(_QuickMatchBtn, "快速招募("..TrackUI.QuickMatchTimeCount.."s)")
    end
    if TrackUI.QuickMatchTimeCount <= 0 then
        TrackUI.StopTimerResetQuickMatchBtn()
    end
end

function TrackUI.OnCreateTeam(param)
    if not CanSystemOpen(2) then
        CL.SendNotify(NOTIFY.ShowBBMsg, tostring(MainUIBtnOpenDef.Data[2].Lv).."级开启队伍功能")
        return
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "CreateTeam", 0, 1, 1, 1)
end

function TrackUI.OnFindTeamBtn(param)
    if not CanSystemOpen(2) then
        CL.SendNotify(NOTIFY.ShowBBMsg, tostring(MainUIBtnOpenDef.Data[2].Lv).."级开启队伍功能")
        return
    end
    GUI.OpenWnd("TeamPlatformPersonalUI")
end

function TrackUI.OnClickTeamRoleFace(guid)
    local _Face = GUI.GetByGuid(guid)
    TrackUI.OnShowRoleHeadInfoUI(_Face)
end

function TrackUI.OnClickTeamRole(guid)
    local _Node = GUI.GetByGuid(guid)
    local _Index = GUI.GetData(_Node, "NodeIndex")
    local _Face = GUI.GetChild(GUI.GetParentElement(_Node), "Face" .. _Index)
    TrackUI.OnShowRoleHeadInfoUI(_Face)
end

function TrackUI.OnShowRoleHeadInfoUI(face)
    if face ~= nil then
        local _RoleGUID = GUI.GetData(face, "RoleGUID")
        GUI.OpenWnd("TeamHeadInfoUI", _RoleGUID)
    end
end

function TrackUI.SetQuestTop(id)
    TrackUI.DefaultSelectTaskID = id
    TrackUI.ShowQuestLst()
end

function TrackUI.OnManualClickQuest(id)
    if TrackUI.Qsts ~= nil then
        local Count = TrackUI.Qsts.Count
        for i = 1, Count do
            local _Content = _gt.GetUI("Content" .. i)
            if _Content ~= nil then
                local TaskID = tonumber(GUI.GetData(_Content, "TaskID"))
                if TaskID == id then
                    --得到目标信息
                    local ClickInfo = ""
                    local ContentInfos = LD.GetRichTextUrlInfo(_Content)
                    if ContentInfos ~= nil and ContentInfos.Length > 0 then
                        ClickInfo = ContentInfos[ContentInfos.Length - 1]
                    end

                    --执行寻路
                    if ClickInfo ~= "" then
                        LD.OnParsePathFinding(ClickInfo)
                    else
                        print("！！！当前任务"..tostring(id).."的信息为空！！！")
                    end
                    break
                end
            end
        end
    end
end

function TrackUI.ShowQuestLst()
    local _QuestScroll = _gt.GetUI("QuestScrollLst")
    if _QuestScroll == nil then
        return
    end
    TrackUI.Qsts = LD.GetQuestExts()
    local Count = TrackUI.Qsts.Count
    if TrackUI.QuestLstMax < Count then
        TrackUI.QuestLstMax = Count
    end
    --test("显示"..Count.."条任务信息。。。。。")
    local OffsetY = 0
    local TotalPosY = 0
    local _MainQstIndex = -1
    local _IsShowEffect = false
    TrackUI.MainQuestTarget = nil

    --主线任务框选特效0
    local _MainQstEffect0 = _gt.GetUI("MainQstEffect0")
    if _MainQstEffect0 == nil then
        _MainQstEffect0 = GUI.SpriteFrameCreate(_QuestScroll, "MainQstEffect0", "340441", -25, -28)
        _gt.BindName(_MainQstEffect0, "MainQstEffect0")
        SetSameAnchorAndPivot(_MainQstEffect0, UILayout.TopLeft)
        GUI.SetIsRaycastTarget(_MainQstEffect0, false)
        GUI.Play(_MainQstEffect0)
    end

    local _Qst = nil
    local _MainIndex = -1
    local _QstIndex = 0
    for i = 1, TrackUI.QuestLstMax do
        local IsShow = (i <= Count)
        if IsShow then
            if i == 1 then
                for k = 0, Count - 1 do
                    if TrackUI.DefaultSelectTaskID == -1 then
                        --第一条显示主线任务
                        if TrackUI.Qsts[k].QuestColor == 6 then
                            _Qst = TrackUI.Qsts[k]
                            _MainIndex = k
                            break
                        end
                    else
                        --或第一条显示指定ID的任务
                        if TrackUI.Qsts[k].TaskID == TrackUI.DefaultSelectTaskID then
                            _Qst = TrackUI.Qsts[k]
                            _MainIndex = k
                            break
                        end
                    end
                end
                if _MainIndex==-1 then
                    _Qst = TrackUI.Qsts[0]
                    _QstIndex = 1
                end
            else
                --后续显示其他，如果遇到主线则+1
                if _MainIndex==-1 or _QstIndex < _MainIndex then
                    _Qst = TrackUI.Qsts[_QstIndex]
                else
                    _Qst = TrackUI.Qsts[_QstIndex + 1]
                end
                _QstIndex = _QstIndex + 1
            end
        end
        local _QuestNode = _gt.GetUI("Node" .. i)
        local _NodeBack = _gt.GetUI("NodeBack" .. i)
        if _QuestNode == nil then
            if IsShow then
                --底框
                _QuestNode = GUI.ImageCreate(_QuestScroll, "Node" .. i, "1800200010", 0, 0, false, 250, 95)
                _gt.BindName(_QuestNode, "Node" .. i)
                SetSameAnchorAndPivot(_QuestNode, UILayout.TopLeft)
                GUI.SetIsRaycastTarget(_QuestNode, true)
                _QuestNode:RegisterEvent(UCE.PointerClick)
                _QuestNode:RegisterEvent(UCE.PointerDown)
                _QuestNode:RegisterEvent(UCE.PointerUp)
                GUI.RegisterUIEvent(_QuestNode, UCE.PointerClick, "TrackUI", "OnClickQuestContentBack")
                GUI.RegisterUIEvent(_QuestNode, UCE.PointerDown, "TrackUI", "OnClickQuestContentDownBack")
                GUI.RegisterUIEvent(_QuestNode, UCE.PointerUp, "TrackUI", "OnClickQuestContentUpBack")

                --选中标记框
                _NodeBack = GUI.ImageCreate(_QuestNode, "NodeBack" .. i, "1800200011", 0, 0, false, 250, 95)
                _gt.BindName(_NodeBack, "NodeBack" .. i)
                SetSameAnchorAndPivot(_NodeBack, UILayout.TopLeft)
                GUI.SetVisible(_NodeBack, false)

                --任务名
                local _Name = GUI.CreateStatic(_QuestNode, "Name" .. i, "摘个大西瓜", 12, 0, 250, 35)
                _gt.BindName(_Name, "Name" .. i)
                SetSameAnchorAndPivot(_Name, UILayout.TopLeft)
                GUI.StaticSetFontSize(_Name, 20)
                GUI.SetColor(_Name, UIDefine.PurpleColor)

                --任务信息
                local _Content = GUI.RichEditCreate(_QuestNode, "Content" .. i, "来来来来快去寻找#NPCLINK<STR:吕秀才（3/6）,NPCID:101>#吧", 11, 35, 238, 60)
                _gt.BindName(_Content, "Content" .. i)
                SetSameAnchorAndPivot(_Content, UILayout.TopLeft)
                GUI.StaticSetFontSize(_Content, 20)
                GUI.StaticSetAlignment(_Content, TextAnchor.UpperLeft)
                _Content:RegisterEvent(UCE.PointerDown)
                _Content:RegisterEvent(UCE.PointerUp)
                GUI.RegisterUIEvent(_Content, UCE.PointerClick, "TrackUI", "OnClickQuestContent")
                GUI.RegisterUIEvent(_Content, UCE.PointerDown, "TrackUI", "OnClickQuestContentDown")
                GUI.RegisterUIEvent(_Content, UCE.PointerUp, "TrackUI", "OnClickQuestContentUp")

                --倒计时标记
                local _TimeBtn = GUI.ButtonCreate(_QuestNode, "TimeBtn" .. i, "1800208100", 183, 2, Transition.ColorTint)
                _gt.BindName(_TimeBtn, "TimeBtn" .. i)
                SetSameAnchorAndPivot(_TimeBtn, UILayout.TopLeft)
                GUI.RegisterUIEvent(_TimeBtn, UCE.PointerClick, "TrackUI", "OnQuestTimeBtn")

                --战斗标记
                local _FightFlag = GUI.ImageCreate(_QuestNode, "FightFlag" .. i, "1800208110", 217, 2)
                _gt.BindName(_FightFlag, "FightFlag" .. i)
                SetSameAnchorAndPivot(_FightFlag, UILayout.TopLeft)
            end
        end

        if _QuestNode ~= nil then
            GUI.SetVisible(_QuestNode, IsShow)
        end

        if IsShow and _Qst then
            --名称
            local _Name = _gt.GetUI("Name" .. i)
            if _Name ~= nil then
                TrackUI.SetQuestNameWithColor(_Name, _Qst.Name, _Qst.QuestColor, _Qst.DisplayCycleFlag, _Qst.FinishCycleNum, _Qst.TotalCycleNum)
            end

            --背景框位置
            if _QuestNode ~= nil then
                GUI.SetPositionX(_QuestNode, 0)
                TotalPosY = OffsetY + (i - 1) * 96
                GUI.SetPositionY(_QuestNode, TotalPosY)
            end

            --内容
            local _ContentHeight = 40
            local _Content = _gt.GetUI("Content" .. i)
            if _Content ~= nil then
                --print("显示任务信息：["..(i-1).."]: ".._Qst.TaskID.." - "..TrackUI.Qsts[i-1].TrackInfo)
                GUI.StaticSetText(_Content, _Qst.TrackInfo)
                GUI.SetData(_Content, "TaskID", tostring(_Qst.TaskID))
                local RealHeight = GUI.RichEditGetPreferredHeight(_Content)
                _ContentHeight = RealHeight / 24 * 20
                --移除最小2行行高的约定 if _ContentHeight < 40 then _ContentHeight = 40 end
                GUI.SetHeight(_Content, RealHeight+3) --在某些分辨率下为临界值状态，导致少显示一行，因此多3个高度像素
                --if RealHeight < 40 then
                    --print("RealHeight:"..tostring(RealHeight)..", _Qst.TaskID:"..tostring(_Qst.TaskID)..",_Qst.Name:"..tostring(_Qst.Name)..", Info:"..tostring(TrackUI.Qsts[i-1].TrackInfo))
                --end
                OffsetY = OffsetY + _ContentHeight - 40
            end
            --主线对象
            if _Qst.QuestColor == 6 then
                TrackUI.MainQuestTarget = GUI.GetGuid(_Content)
            end

            --背景框大小
            local BackHeight = 75
            if _QuestNode ~= nil and _NodeBack ~= nil then
                BackHeight = 75
                if _ContentHeight > 20 then
                    BackHeight = BackHeight + (_ContentHeight - 20)
                end
                if _Qst.QuestColor == 6 then
                    if 95 > BackHeight then
                        OffsetY = OffsetY + 95 - BackHeight
                        BackHeight = 95
                    end
                end
                TotalPosY = TotalPosY + BackHeight
                GUI.SetHeight(_QuestNode, BackHeight)
                GUI.SetHeight(_NodeBack, BackHeight)
            end

            --时间标记
            local _TimeBtn = _gt.GetUI("TimeBtn" .. i)
            if _TimeBtn ~= nil then
                GUI.SetVisible(_TimeBtn, _Qst.TimeFlag)
                if _Qst.FightFlag then
                    GUI.SetPositionX(_TimeBtn, 183)
                else
                    GUI.SetPositionX(_TimeBtn, 217)
                end
            end

            --时间Tip
            local _TimeTip = _gt.GetUI("TimeTip" .. i)
            if _TimeTip ~= nil then
                if _Qst.TimeFlag == false and GUI.GetVisible(_TimeTip) then
                    GUI.Destroy(_TimeTip)
                end
            end

            --战斗标记
            local _FightFlag = _gt.GetUI("FightFlag" .. i)
            if _FightFlag ~= nil then
                GUI.SetVisible(_FightFlag, _Qst.FightFlag)
            end

            --主线任务框选特效
            if _Qst.QuestColor == 6 and _Qst.State ~= 0 then
                _MainQstIndex = TotalPosY - BackHeight
                _IsShowEffect = true
            end
        end
    end
    TrackUI.OnSetQuestScrollAreaHeight(TotalPosY)

    if _MainQstEffect0 ~= nil then
        if _IsShowEffect then
            GUI.SetPositionY(_MainQstEffect0, _MainQstIndex - 28)
            GUI.SetDepth(_MainQstEffect0, Count + 1)
        end
        GUI.SetVisible(_MainQstEffect0, _IsShowEffect)
    end
    --恢复默认选择对象
    TrackUI.DefaultSelectTaskID = -1
end

function TrackUI.OnSetQuestScrollAreaHeight(TotalPosY)
    TrackUI.QuestScrollAreaHeight = TotalPosY
    local _QuestNode = _gt.GetUI("QuestScroll")
    if _QuestNode ~= nil then
        local MaxHeight = TrackUI.GetTrackPanelHeight()
        if UIDefine.FunctionSwitch and UIDefine.FunctionSwitch.VipIngotTrace == "on" then
            TrackUI.IsShowVipPanel = true
        else
            TrackUI.IsShowVipPanel = false
        end
        if TrackUI.IsShowVipPanel then
            MaxHeight = MaxHeight - 95
        else
            local _QuestLstBack = _gt.GetUI("QuestLstBack")
            GUI.SetPositionY(_QuestLstBack, 22)
        end

        --设置实际内容区域的大小
        GUI.ScrollRectSetChildSize(_QuestNode, Vector2.New(250, TotalPosY))
        if TotalPosY > MaxHeight then
            TotalPosY = MaxHeight
        end
        --设置滚动的可视区域的高度
        GUI.SetHeight(_QuestNode, TotalPosY)
    end
end

function TrackUI.OnQuestTimeBtn(guid)
    local flag = GUI.GetByGuid(guid)
    local Index = tonumber(string.sub(GUI.GetName(flag), 8))
    local tip = Tips.CreateHint(UIDefine.LeftTimeFormat(tonumber(tostring(TrackUI.Qsts[Index - 1].EndTime))), flag, 19, 46, UILayout.Center, nil, nil, true)
    SetAnchorAndPivot(tip, UIAnchor.Center, UIAroundPivot.Right)
    GUI.SetIsRemoveWhenClick(tip, true)
end

function TrackUI.SetQuestNameWithColor(questName, nameInfo, questColor, displayCycleFlag, finishCycleNum, totalCycleNum)
    local NameColor = UIDefine.YellowColor
    local NameTxt = nameInfo
    local _Index = questColor + 1
    if _Index <= 7 then
        NameColor = Colors[_Index]
    end
    if displayCycleFlag then
        NameTxt = NameTxt .. "（" .. finishCycleNum .. "/" .. totalCycleNum .. "）"
    end
    GUI.StaticSetText(questName, NameTxt)
    GUI.SetColor(questName, NameColor)
end

function TrackUI.OnClickQuestContentBack(guid)
    local item = GUI.GetByGuid(guid)
    local name = GUI.GetName(item)
    local Index = tonumber(string.sub(name, 5))
    local ContentName = "Content" .. Index
    TrackUI.OnClickQuestContent(nil, ContentName)
end

function TrackUI.OnClickQuestContent(guid, key)
    local item = guid ~= nil and GUI.GetByGuid(guid) or nil
    local name = item ~= nil and GUI.GetName(item) or key
    TrackUI.OnParseClickQuestContent(name)
end

function TrackUI.OnClickQuestContentDownBack(guid)
    local item = GUI.GetByGuid(guid)
    local name = GUI.GetName(item)
    local Index = tonumber(string.sub(name, 5))
    local ContentName = "Content" .. Index
    --TrackUI.OnShowClickQuestContentEffectDown(ContentName)
end

function TrackUI.OnClickQuestContentDown(guid)
    local item = GUI.GetByGuid(guid)
    local name = GUI.GetName(item)
    --TrackUI.OnShowClickQuestContentEffectDown(name)
end

function TrackUI.OnClickQuestContentUpBack(key)
    --TrackUI.OnShowClickQuestContentEffectUp()
end

function TrackUI.OnClickQuestContentUp(key)
    --TrackUI.OnShowClickQuestContentEffectUp()
end

function TrackUI.OnParseClickQuestContent(key)
    local RoleAttrIsAutoGame = CL.GetIntAttr(RoleAttr.RoleAttrIsAutoGame)
    if RoleAttrIsAutoGame == 1 then
        return
    end

    local Index = tonumber(string.sub(key, 8))
    local _Content = _gt.GetUI("Content" .. Index)
    if _Content == nil then
        return
    end

    --得到目标信息
    local ClickInfo = ""
    local ContentInfos = LD.GetRichTextUrlInfo(_Content)
    if ContentInfos ~= nil and ContentInfos.Length > 0 then
        ClickInfo = ContentInfos[ContentInfos.Length - 1]
    end

    local DirTransfer = false
    --如果存在道具筋斗云则直接传送
    if CL.GetIntAttr(RoleAttr.RoleAttrPathfindingTransfer) == 0 and MainUI.IsJindouyunTransfer and string.len(ClickInfo) > 0 then
        if LD.GetItemCountById(JIN_DOU_YUN_ID) > 0 and LD.OnPathFindingTargetDistanceInScope(ClickInfo) == false then
            local taskID = tonumber(GUI.GetData(_Content, "TaskID"))
            print("点击了筋斗云："..tostring(taskID))
            CL.StopMove()
            CL.SendNotify(NOTIFY.SubmitForm,"FormJinDouYun","Main", taskID)
            DirTransfer = true
        end
    end

    if not DirTransfer then
        --执行寻路
        if string.len(ClickInfo) > 0 then
            LD.OnParsePathFinding(ClickInfo)
        else
            print("！！！点击的信息为空！！！")
        end
    end
end


function TrackUI.RefreshVipPanel()
    TrackUI.IsShowVipPanel = false

    TrackUI.IsFullVipIngotState = false

    if UIDefine.FunctionSwitch and UIDefine.FunctionSwitch.VipIngotTrace == "on" then
        TrackUI.IsShowVipPanel = true
    end
    local _TrackNode = _gt.GetUI("TrackNode")
    local _QuestLstBack = _gt.GetUI("QuestLstBack")
    if _TrackNode == nil or _QuestLstBack == nil then
        CDebug.LogError("过早调用RefreshVipPanel，MainUI界面并未创建完成！")
        return
    end
    local _VipInfoPanel = _gt.GetUI("VipInfoPanel")
    if _VipInfoPanel ~= nil then
        GUI.SetVisible(_VipInfoPanel, TrackUI.IsShowVipPanel and GUI.GetVisible(_QuestLstBack) )
    end

    --动态改变任务的位置和区域大小
    if _QuestLstBack ~= nil then
        if TrackUI.IsShowVipPanel then
            GUI.SetPositionY(_QuestLstBack, 118)
        else
            GUI.SetPositionY(_QuestLstBack, 22)
        end
    end
    TrackUI.OnSetQuestScrollAreaHeight(TrackUI.QuestScrollAreaHeight)
    if TrackUI.IsShowVipPanel then
        if _VipInfoPanel == nil then
            --底框
            _VipInfoPanel = GUI.ImageCreate( _TrackNode,"VipInfoPanel", "1800200010", -221, 23, false, 250, 95)
            _gt.BindName(_VipInfoPanel, "VipInfoPanel")
            SetSameAnchorAndPivot(_VipInfoPanel, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_VipInfoPanel, true)
            _VipInfoPanel:RegisterEvent(UCE.PointerClick)
            GUI.RegisterUIEvent(_VipInfoPanel, UCE.PointerClick, "TrackUI", "OnClickVipInfoPanel")
            GUI.SetVisible(_VipInfoPanel, TrackUI.IsShowVipPanel and GUI.GetVisible(_QuestLstBack) )

            --VIP等级
            local _VipNumBack = GUI.ImageCreate( _VipInfoPanel,"VipNumBack", "1801207070", -6, 0, false, 180, 37)
            SetSameAnchorAndPivot(_VipNumBack, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_VipNumBack, false)
            local _VipNumPrePic0 = GUI.ImageCreate( _VipNumBack,"VipNumPrePic0", "1801205070", 12, 4)
            SetSameAnchorAndPivot(_VipNumPrePic0, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_VipNumPrePic0, false)
            local _VipNumPrePic1 = GUI.ImageCreate( _VipNumBack,"VipNumPrePic1", "1801205080", 87, 0)
            SetSameAnchorAndPivot(_VipNumPrePic1, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_VipNumPrePic1, false)
            local _VipNum0 = GUI.ImageCreate( _VipNumBack,"VipNum0", "1801205090", 59, 4)
            _gt.BindName(_VipNum0, "VipNum0")
            SetSameAnchorAndPivot(_VipNum0, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_VipNum0, false)
            local _VipNum1 = GUI.ImageCreate( _VipNumBack,"VipNum1", "1801205090", 72, 4)
            _gt.BindName(_VipNum1, "VipNum1")
            SetSameAnchorAndPivot(_VipNum1, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_VipNum1, false)

            --描述信息
            local _Content = GUI.RichEditCreate(_VipInfoPanel,"Content", "#SHOWUI<STR:每日活动,UIWndName:ActivityPanelUI>#可获得银元宝", 24, 38, 238, 60)
            _gt.BindName(_Content,"VipContent")
            SetSameAnchorAndPivot(_Content, UILayout.TopLeft)
            GUI.StaticSetFontSize(_Content, 20)
            GUI.StaticSetAlignment(_Content, TextAnchor.UpperLeft)
            GUI.RegisterUIEvent(_Content, UCE.PointerClick, "TrackUI", "OnClickVipInfoPanel")

            --当前元宝数量进度条
            local _Process = GUI.ScrollBarCreate( _VipInfoPanel,"Process", "", "1801201070", "1801201080", 23, 64, 221, 28, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
            _gt.BindName(_Process,"VipProcess")
            local _RoleHPValue = Vector2.New(221, 28)
            GUI.ScrollBarSetFillSize(_Process, _RoleHPValue)
            GUI.ScrollBarSetBgSize(_Process, _RoleHPValue)
            SetSameAnchorAndPivot(_Process, UILayout.TopLeft)
            local _Num = GUI.CreateStatic( _VipInfoPanel,"Num", "", 13, 31, 238, 60, "system", true)
            _gt.BindName(_Num, "VipNum")
            SetSameAnchorAndPivot(_Num, UILayout.Center)
            GUI.StaticSetFontSize(_Num, 18)
            GUI.StaticSetAlignment(_Num, TextAnchor.MiddleCenter)
            GUI.SetIsRaycastTarget(_Num, false)
            --点击层
            local _ProcessPic = GUI.ImageCreate( _VipInfoPanel,"ProcessPic", "1800499999", 23, 64, false, 221, 28)
            SetSameAnchorAndPivot(_ProcessPic, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_ProcessPic, true)
            GUI.RegisterUIEvent(_ProcessPic, UCE.PointerClick, "TrackUI", "OnClickVipInfoPanel")

            --元宝图标
            local _IngotPic = GUI.ImageCreate( _VipInfoPanel,"IngotPic", "1800408260", 6, 57)
            SetSameAnchorAndPivot(_IngotPic, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(_IngotPic, false)
        end

        local _VipFuncOpenLevel = 0
        if TrackUI.VipFuncOpenLevel ~= nil then
            _VipFuncOpenLevel = TrackUI.VipFuncOpenLevel
        end
        local _PanelContent = "#SHOWUI<STR:每日活动,UIWndName:ActivityPanelUI>#可获得银元宝"
        local _RoleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
        if _VipFuncOpenLevel > _RoleLevel then
            _PanelContent = tostring(_VipFuncOpenLevel).."级开启活动掉落元宝"
        end

        local _VipValue = 0
        if TrackUI.CurVipIngotNum ~= nil then
            _VipValue = TrackUI.CurVipIngotNum
        end
        local _VipMaxValue = 100
        if TrackUI.MaxVipIngotCount and TrackUI.MaxVipIngotCount ~= 0 then
            _VipMaxValue = TrackUI.MaxVipIngotCount
        end

        local _RoleAttrVip = CL.GetIntAttr(RoleAttr.RoleAttrVip)
        local _NumInfo =tostring(_VipValue).."/".._VipMaxValue
        local _NumInfoFloat = _VipValue/_VipMaxValue
        if _VipValue >= _VipMaxValue then
            TrackUI.IsFullVipIngotState = true
            local _VipLevelMax = 15
            if TrackUI.VipLevelMax then
                _VipLevelMax = TrackUI.VipLevelMax
            end
            if _RoleAttrVip>=_VipLevelMax then
                _PanelContent = "今日活动元宝已达上限"
            else
                _PanelContent = "提升至#SHOWUI<STR:VIP"..(_RoleAttrVip+1)..">#获得更多元宝"
            end
        end

        --描述
        local _Content = _gt.GetUI("VipContent")
        if _Content ~= nil then
            GUI.StaticSetText(_Content, _PanelContent)
        end

        --数量
        local _Num = _gt.GetUI("VipNum")
        if _Num ~= nil then
            GUI.StaticSetText(_Num, _NumInfo)
        end
        local _Process = _gt.GetUI("VipProcess")
        if _Process ~= nil then
            GUI.ScrollBarSetPos(_Process, _NumInfoFloat)
        end

        local _VipValue0 = _RoleAttrVip
        if _RoleAttrVip>=10 then
            _VipValue0 = math.modf( _RoleAttrVip / 10 )
        end

        --VIP等级
        local _VipNum0 = _gt.GetUI("VipNum0")
        if _VipNum0 ~= nil then
            GUI.ImageSetImageID(_VipNum0, "180120509".._VipValue0)
        end
        local _VipNum1 = _gt.GetUI("VipNum1")
        if _VipNum1 ~= nil then
            GUI.SetVisible(_VipNum1, _RoleAttrVip>=10)
            if _RoleAttrVip>=10 then
                GUI.ImageSetImageID(_VipNum1, "180120509"..(_RoleAttrVip%10))
            end
        end
    end
end

function TrackUI.OnClickVipInfoPanel()
    local _VipFuncOpenLevel = 0
    if TrackUI.VipFuncOpenLevel ~= nil then
        _VipFuncOpenLevel = TrackUI.VipFuncOpenLevel
    end
    local _RoleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    if _RoleLevel < _VipFuncOpenLevel then
        return
    end

    if TrackUI.IsFullVipIngotState then
        GUI.OpenWnd("VipUI")
    else
        GUI.OpenWnd("ActivityPanelUI","index:1,index2:2")
    end
end



function TrackUI.OnShowFightInfo6(parent)
    local colorP = Color.New(220 / 255, 96 / 255, 247 / 255, 255 / 255)
    local colorWhite = UIDefine.WhiteColor
    local colorDark = UIDefine.BrownColor
    local titleColor = colorP --UIDefine.RedCol

    local _PIC1 = GUI.ImageCreate(parent, "PIC1", "1800200010", 0, 0, false, 254, 79)
    SetAnchorAndPivot(_PIC1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PIC2 = GUI.ImageCreate(parent, "PIC2", "1800200010", 0, 80, false, 254, 140)
    SetAnchorAndPivot(_PIC2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PIC3 = GUI.ImageCreate(parent, "PIC3", "1800200010", 0, 221, false, 254, 172)
    SetAnchorAndPivot(_PIC3, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- local bg6 = GUI.ImageCreate(parent, "bg6", "1800600360", 0, 0, false, 254, 395)
    -- SetAnchorAndPivot(bg6, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- local bg6_b = GUI.ImageCreate(parent, "bg6-b", "1800400230", 0, 0, true)
    -- SetSameAnchorAndPivot(bg6_b,UILayout.Center)

    -- local bg6_c = GUI.ImageCreate(parent, "bg6-c", "1801720050", 0, 0, false,150,150)
    -- SetSameAnchorAndPivot(bg6_c,UILayout.Center)

    --进度节点
    local _ScheduleNode = GUI.GroupCreate(parent, "ScheduleNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_ScheduleNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_ScheduleNode, true)

    local _ScheduleTitle = GUI.CreateStatic(_ScheduleNode, "ScheduleTitle", "当前层数", 10, 10, 200, 30)
    SetAnchorAndPivot(_ScheduleTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_ScheduleTitle, 21)
    GUI.SetColor(_ScheduleTitle, titleColor)

    -- i 图标
    local scoreHint = GUI.ButtonCreate(parent, "scoreHint", "1800702030", -17, -348, Transition.ColorTint, "")
    SetSameAnchorAndPivot(scoreHint, UILayout.BottomRight)
    GUI.RegisterUIEvent(scoreHint, UCE.PointerClick, "TrackUI", "hint_event")

    local bg = GUI.ImageCreate(_ScheduleNode, "ScheduleBootstrapBG", "1800608510", 13, 58, false, 0, 0)
    SetAnchorAndPivot(bg, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ImageSetType(bg, SpriteType.Filled)
    GUI.SetImageFillMethod(bg, SpriteFillMethod.Horizontal_Left)
    GUI.SetImageFillAmount(bg, 1)

    local _ScheduleBootstrap = GUI.ImageCreate(_ScheduleNode, "ScheduleBootstrap", "1800608511", 13, 58, false, 0, 0)
    _gt.BindName(_ScheduleBootstrap, "integralTower_ScheduleBootstrap")
    SetAnchorAndPivot(_ScheduleBootstrap, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ImageSetType(_ScheduleBootstrap, SpriteType.Filled)
    GUI.SetImageFillMethod(_ScheduleBootstrap, SpriteFillMethod.Horizontal_Left)

    local _ScheduleTitleNum = GUI.CreateStatic(_ScheduleNode, "ScheduleTitleNum", "", 254 / 2, 58, 150, 30)
    _gt.BindName(_ScheduleTitleNum, "integralTower_ScheduleTitleNum")
    SetAnchorAndPivot(_ScheduleTitleNum, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(_ScheduleTitleNum, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(_ScheduleTitleNum, 18)
    GUI.SetColor(_ScheduleTitleNum, colorWhite)

    --信息节点
    local _InfNode = GUI.GroupCreate(parent, "InfNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_InfNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_InfNode, true)

    local _InfTitle = GUI.CreateStatic(_InfNode, "ScheduleTitle", "追踪信息", 10, 85, 200, 30)
    SetAnchorAndPivot(_InfTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_InfTitle, 21)
    GUI.SetColor(_InfTitle, titleColor)

    local trackTxt = GUI.RichEditCreate(_InfNode, "trackTxt", "", 10, 106, 220, 116)
    _gt.BindName(trackTxt, "integralTower_trackTxt")
    SetAnchorAndPivot(trackTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(trackTxt, UIDefine.FontSizeSS);
    GUI.SetColor(trackTxt, colorWhite);
    
    local moreSub = -20
    -- 下层时间
    local nextTimeTile = GUI.CreateStatic(_InfNode, "nextTimeTile", "下层时间", 10, 205-moreSub, 200, 30)
    SetAnchorAndPivot(nextTimeTile, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(nextTimeTile, 21)
    GUI.SetColor(nextTimeTile, titleColor)
    
    --倒计时
    local _Countdown = GUI.CreateStatic(_ScheduleNode, "Countdown", "00:00", 253, 205-moreSub, 150, 30)
    _gt.BindName(_Countdown, "integralTower_Countdown")
    SetSameAnchorAndPivot(_Countdown,UILayout.TopRight)
    GUI.StaticSetAlignment(_Countdown, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(_Countdown, 21)
    GUI.SetColor(_Countdown, colorWhite)
    
    local sub = -5+moreSub
    -- 当前积分标题
    local _GiftTitle = GUI.CreateStatic(_InfNode, "GiftTitle", "当前积分", 10, 233-sub, 200, 30)
    SetAnchorAndPivot(_GiftTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_GiftTitle, 21)
    GUI.SetColor(_GiftTitle, titleColor)

    -- 当前积分
    local _InfTxt = GUI.CreateStatic(_InfNode, "InfTxt", "", 135, 238-sub, 220, 90,"100")
    _gt.BindName(_InfTxt, "integralTower_InfTxt")
    SetAnchorAndPivot(_InfTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_InfTxt, UIDefine.FontSizeM);
    GUI.SetColor(_InfTxt, colorWhite);
    GUI.StaticSetAlignment(_InfTxt, TextAnchor.UpperLeft)

    local w = 110
    local y = 340

    -- 显示榜单按钮
    local showRankingBtn = GUI.ButtonCreate(parent, "showRankingBtn", "1800602020", 6, y, Transition.ColorTint, "积分榜",w,46,false)
    SetAnchorAndPivot(showRankingBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(showRankingBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(showRankingBtn, colorDark)
    GUI.SetIsOutLine(showRankingBtn, true)
    GUI.RegisterUIEvent(showRankingBtn, UCE.PointerClick, "TrackUI", "integralTowerShowRanking")
    --退出按钮
    local _ExitBtn = GUI.ButtonCreate(parent, "ExitBtn", "1800602020", 137, y, Transition.ColorTint, "退出",w,46,false)
    SetAnchorAndPivot(_ExitBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_ExitBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(_ExitBtn, colorDark)
    GUI.SetIsOutLine(_ExitBtn, true)
    GUI.RegisterUIEvent(_ExitBtn, UCE.PointerClick, "TrackUI", "integralTowerExitBtn")
end

function TrackUI.integralTowerExitBtn()
    -- GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", "是否退出积分塔", "TrackUI", "确定", "integralTowerExit", "取消")
    
    CL.SendNotify(NOTIFY.SubmitForm,"FormIntegralTower","ToActiveQuit")
end

function TrackUI.integralTowerExit()
    -- FormIntegralTower.ToActiveQuit(player)
    CL.SendNotify(NOTIFY.SubmitForm,"FormIntegralTower","ToActiveQuit")
end

-- 服务端执行积分塔退出的方法
function TrackUI.integralTowerExitServerRun()
    TrackUI.integralTowerTimer:Stop()
    TrackUI.integralTowerTimer = nil
    TrackUI.integralTowerData = nil
    TrackUI.SwitchQuestOrFightInfoNode(true)
end

function TrackUI.integralTowerShowRanking()
    local wnd = GUI.GetWnd("SevenTierClimbTowerIntegralUI")
    if wnd and GUI.GetVisible(wnd) == false then
    else
        GUI.OpenWnd("SevenTierClimbTowerIntegralUI")
    end
end

-- 积分塔活动数据
TrackUI.integralTowerData = {
    integral = 1, -- 积分
    currentTier = 1, -- 当前层数
    totalTier = 7, -- 总层数 可不传入
    second = 10, -- 下一层开启时间
}
function TrackUI.integralTowerRefresh()
    if TrackUI.integralTowerData == nil then
        test("TrackUI.integralTowerRefresh() data is null")
        return 
    end
    TrackUI.integralTowerData.currentTier = TrackUI.integralTowerData.NowMapIndex
    TrackUI.integralTowerData.integral = TrackUI.integralTowerData.Integral
    TrackUI.integralTowerData.second = TrackUI.integralTowerData.NextOpenLineTime
    TrackUI.integralTowerData.totalTier = TrackUI.integralTowerData.MaxMapNum

    -- 当前服务器时间
    local serverTimeStamp = CL.GetServerTickCount()

    if TrackUI.integralTowerData.second then
        TrackUI.integralTowerData.second = TrackUI.integralTowerData.second - serverTimeStamp
    else
        TrackUI.integralTowerData.second = 15*60
        test("TrackUI.integralTowerRefresh() second is null")
    end
    local data = TrackUI.integralTowerData

    local trackInfo = data.TraceMsg or '受天庭所托，各位在此地，修为时时刻刻都能提升。什么？上去？不不不，上层皆是豺狼虎豹之徒，尔等不是对手！'
    local trackTxt = _gt.GetUI('integralTower_trackTxt')
    if trackTxt then
        GUI.StaticSetText(trackTxt,' '..trackInfo)
    end


    local integral = data.integral or 1

    local integralTxt = _gt.GetUI("integralTower_InfTxt")
    if integralTxt then
        GUI.StaticSetText(integralTxt," "..integral)
    end

    local currentTier = data.currentTier or 0
    local totalTier = data.totalTier or 7
    
    local showTierTxt = _gt.GetUI("integralTower_ScheduleTitleNum")
    if showTierTxt then 
        GUI.StaticSetText(showTierTxt,currentTier.."/"..totalTier)
    end

    local scheduleImg = _gt.GetUI("integralTower_ScheduleBootstrap")
    if scheduleImg then
        if totalTier ~= 0 then
            GUI.SetImageFillAmount(scheduleImg,currentTier/totalTier)
        else
            GUI.SetImageFillAmount(scheduleImg,1)
        end
    end

    if TrackUI.integralTowerTimer then
        TrackUI.integralTowerTimer:Stop()
        TrackUI.integralTowerTimer:Start()
    else
        test("TrackUI.integralTowerRefresh() TrackUI.integralTowerTimer is null")
    end

end

function TrackUI.integralTowerTimerFunc() 
    if TrackUI.integralTowerData == nil then
        test("TrackUI.integralTowerTimerFunc data is null")
        return 
    end
    local data = TrackUI.integralTowerData
    local second = data.second or 10 

    local _Countdown = _gt.GetUI("integralTower_Countdown")
    if _Countdown then
        if not second then
            return
        end
        if second <= 0 then
            TrackUI.integralTowerTimer:Stop()
            -- GUI.SetVisible(_Countdown,false)
            GUI.StaticSetText(_Countdown,"已开启")
        else
            second = second - 1
            local timeStr = GlobalUtils.GetTimeString(second)
            GUI.StaticSetText(_Countdown, timeStr)
        end
    end
    TrackUI.integralTowerData.second = second

end

function TrackUI.hint_event(guid)
    local bg = _gt.GetUI('FightInfo6Back')
    local hint = GUI.GetChild(bg, 'hint')
    if hint == nil then
        hint = GUI.ImageCreate(bg, "hint", "1800400290", -306, -40, false, 809, 350)
        GUI.SetIsRemoveWhenClick(hint, true)
        SetSameAnchorAndPivot(hint, UILayout.BottomRight)
        GUI.AddWhiteName(hint, guid)
        GUI.SetIsRaycastTarget(hint,true)

        local hintText = GUI.CreateStatic(hint, "hintText", "", 0, -15, 200, 70, "system", true)
        GUI.StaticSetFontSize(hintText, UIDefine.FontSizeM)
        GUI.StaticSetAlignment(hintText, TextAnchor.UpperLeft)
        SetSameAnchorAndPivot(hintText, UILayout.Top)

        local hintStr = ""
        if TrackUI.integralTowerTips then
            hintStr = TrackUI.integralTowerTips
        else
            test("TrackUI.hint_event(guid)  track.integralTowerTips is null 玩法说明")
        end

        GUI.StaticSetText(hintText, hintStr)

        local height = GUI.StaticGetLabelPreferHeight(hintText)
        local width = GUI.StaticGetLabelPreferWidth(hintText)

        GUI.SetHeight(hintText, height)
        GUI.SetWidth(hintText, width)
    else
        GUI.Destroy(hint)
    end
end

function TrackUI.OnShowFightInfo7(parent)
    local _PIC1 = GUI.ImageCreate(parent, "PIC1", "1800200010", 0, 0, false, 254, 84)
    SetAnchorAndPivot(_PIC1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PIC2 = GUI.ImageCreate(parent, "PIC2", "1800200010", 0, 85, false, 254, 94)
    SetAnchorAndPivot(_PIC2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --393
    local _PIC3 = GUI.ImageCreate(parent, "PIC3", "1800200010", 0, 180, false, 254, 210)
    SetAnchorAndPivot(_PIC3, UIAnchor.TopLeft, UIAroundPivot.TopLeft)


    local _Title = GUI.CreateStatic(parent, "Title", "活动层数", 10, 10, 200, 30)
    SetAnchorAndPivot(_Title, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Title, 21)
    GUI.SetColor(_Title, Color.New(220 / 255, 96 / 255, 247 / 255, 255 / 255))

    local _CountDown = GUI.CreateStatic(parent, "CountDown", "02:10:59", 120, 10, 200, 30)
    SetAnchorAndPivot(_CountDown, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_CountDown, 24)
    GUI.SetColor(_CountDown, UIDefine.WhiteColor)
    _gt.BindName(_CountDown,"TreasureHuntCountDown")

    local SilderFillSize = Vector2.New(228,24)
    local _ScheduleBootSlider = GUI.ScrollBarCreate(parent, "ScheduleBootSlider","","1800408160","1800408110", 0, 60, 0, 0,  1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
	SetAnchorAndPivot(_ScheduleBootSlider, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ScrollBarSetFillSize(_ScheduleBootSlider, SilderFillSize)
    GUI.ScrollBarSetBgSize(_ScheduleBootSlider,SilderFillSize)
	_gt.BindName(_ScheduleBootSlider,"ScheduleBootSlider")
	GUI.ScrollBarSetPos(_ScheduleBootSlider,1/1)
	local _ScheduleBootSliderTotal = GUI.CreateStatic(_ScheduleBootSlider, "ScheduleBootSliderTotal", "10/10", 0, 0, 228, 30, "system")
	SetAnchorAndPivot(_ScheduleBootSliderTotal, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(_ScheduleBootSliderTotal,UIDefine.WhiteColor)
	GUI.StaticSetFontSize(_ScheduleBootSliderTotal, 16)
	GUI.StaticSetAlignment(_ScheduleBootSliderTotal, TextAnchor.MiddleCenter)
	_gt.BindName(_ScheduleBootSliderTotal,"ScheduleBootSliderTotal")

    local _Title2 = GUI.CreateStatic(parent, "Title2", "活动跳转", 10, 95, 200, 30)
    SetAnchorAndPivot(_Title2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Title2, 21)
    GUI.SetColor(_Title2, Color.New(220 / 255, 96 / 255, 247 / 255, 255 / 255))

    local _PreviousFloorBtn = GUI.ButtonCreate(parent, "PreviousFloorBtn", "1800402090", -60, 130 , Transition.ColorTint, "前往上层",100,40,false)
    SetAnchorAndPivot(_PreviousFloorBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ButtonSetTextFontSize(_PreviousFloorBtn, 20)
    GUI.ButtonSetTextColor(_PreviousFloorBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(_PreviousFloorBtn, true)
    GUI.SetOutLine_Distance(_PreviousFloorBtn,1)
    GUI.SetOutLine_Color(_PreviousFloorBtn,UIDefine.Green8Color)
    GUI.RegisterUIEvent(_PreviousFloorBtn, UCE.PointerClick, "TrackUI", "OnPreviousFloorBtnClick")
    _gt.BindName(_PreviousFloorBtn,"PreviousFloorBtn")

    local _NextFloorBtn = GUI.ButtonCreate(parent, "NextFloorBtn", "1800402090", 60, 130, Transition.ColorTint, "前往下层",100,40,false)
    SetAnchorAndPivot(_NextFloorBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ButtonSetTextFontSize(_NextFloorBtn, 20)
    GUI.ButtonSetTextColor(_NextFloorBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(_NextFloorBtn, true)
    GUI.SetOutLine_Distance(_NextFloorBtn,1)
    GUI.SetOutLine_Color(_NextFloorBtn,UIDefine.Green8Color)
    GUI.RegisterUIEvent(_NextFloorBtn, UCE.PointerClick, "TrackUI", "OnNextFloorBtnClick")
    _gt.BindName(_NextFloorBtn,"NextFloorBtn")

    local _Title3 = GUI.CreateStatic(parent, "Title3", "钥匙数量", 10, 190, 200, 30)
    SetAnchorAndPivot(_Title3, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Title3, 21)
    GUI.SetColor(_Title3, Color.New(220 / 255, 96 / 255, 247 / 255, 255 / 255))

    local _GoldenKey = GUI.ImageCreate(parent,"GoldenKey","1801608090", -60, 230 ,false, 62, 57)
    SetAnchorAndPivot(_GoldenKey, UIAnchor.Top, UIAroundPivot.Top)
    _GoldenKey:RegisterEvent(UCE.PointerClick)
	GUI.SetIsRaycastTarget(_GoldenKey, true)
	GUI.RegisterUIEvent(_GoldenKey, UCE.PointerClick, "TrackUI", "OnGoldenKeyClick")

    local _GoldenKeyNum = GUI.CreateStatic(_GoldenKey, "GoldenKeyNum", "x 0", 55, 30, 100, 30)
    SetAnchorAndPivot(_GoldenKeyNum, UIAnchor.Top, UIAroundPivot.Top)
    GUI.StaticSetFontSize(_GoldenKeyNum, 24)
    GUI.SetColor(_GoldenKeyNum, UIDefine.Yellow3Color)
    GUI.StaticSetAlignment(_GoldenKeyNum, TextAnchor.MiddleLeft)
    _gt.BindName(_GoldenKeyNum,"TreasureHuntGoldenKeyNum")

    local _SilverKey = GUI.ImageCreate(parent,"SilverKey","1801608100", 60, 230 ,false, 62, 57)
    SetAnchorAndPivot(_SilverKey, UIAnchor.Top, UIAroundPivot.Top)
    _SilverKey:RegisterEvent(UCE.PointerClick)
	GUI.SetIsRaycastTarget(_SilverKey, true)
	GUI.RegisterUIEvent(_SilverKey, UCE.PointerClick, "TrackUI", "OnSilverKeyClick")

    local _SilverKeyNum = GUI.CreateStatic(_SilverKey, "SilverKeyNum", "x 0", 55, 30, 100, 30)
    SetAnchorAndPivot(_SilverKeyNum, UIAnchor.Top, UIAroundPivot.Top)
    GUI.StaticSetFontSize(_SilverKeyNum, 24)
    GUI.SetColor(_SilverKeyNum, UIDefine.White2Color)
    GUI.StaticSetAlignment(_SilverKeyNum, TextAnchor.MiddleLeft)
    _gt.BindName(_SilverKeyNum,"TreasureHuntSilverKeyNum")

    local _ExitBtn = GUI.ButtonCreate(parent, "ExitBtn", "1800602020", 0, 320, Transition.ColorTint, "退出",120,46,false)
    SetAnchorAndPivot(_ExitBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ButtonSetTextFontSize(_ExitBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(_ExitBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(_ExitBtn, true)
    GUI.SetOutLine_Distance(_ExitBtn,1)
    GUI.SetOutLine_Color(_ExitBtn,UIDefine.BrownColor)
    GUI.RegisterUIEvent(_ExitBtn, UCE.PointerClick, "TrackUI", "OnExitTreasureHuntClick")
end

function TrackUI.OnGoldenKeyClick()
    local Back = _gt.GetUI("FightInfo7Back")
    if TrackUI.TreasureHunt_Key then
        local name = TrackUI.TreasureHunt_Key[1].Name
        local tips = TrackUI.TreasureHunt_Key[1].Tips
        Tips.CreateHint(name..":\n"..tips, Back, 0, -27, UILayout.Center, 200, 60)
    end
end

function TrackUI.OnSilverKeyClick()
    local Back = _gt.GetUI("FightInfo7Back")
    if TrackUI.TreasureHunt_Key then
        local name = TrackUI.TreasureHunt_Key[2].Name
        local tips = TrackUI.TreasureHunt_Key[2].Tips
        Tips.CreateHint(name..":\n"..tips, Back, 0, -27, UILayout.Center, 200, 60)
    end
end

function TrackUI.OnPreviousFloorBtnClick()
    if TrackUI.TreasureHuntData and TrackUI.TreasureHuntData.TransferPos then
        local PosList = TrackUI.TreasureHuntData.TransferPos
        local curUpX = PosList.UpX
        local curUpY = CL.ChangeLogicPosZ(PosList.UpY)
        CL.StartMove(curUpX,curUpY)
    end
end

function TrackUI.OnNextFloorBtnClick()
    if TrackUI.TreasureHuntData and TrackUI.TreasureHuntData.TransferPos then
        local PosList = TrackUI.TreasureHuntData.TransferPos
        local curDownX = PosList.DownX
        local curDownY = CL.ChangeLogicPosZ(PosList.DownY)
        CL.StartMove(curDownX,curDownY)
    end
end

function TrackUI.OnExitTreasureHuntClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormTreasureHunt", "ToActiveQuit")
end

function TrackUI.RefreshTreasureHunt()
    local ScheduleBootSlider = _gt.GetUI("ScheduleBootSlider")
    local ScheduleBootSliderTotal = _gt.GetUI("ScheduleBootSliderTotal")
    local GoldenKeyNum = _gt.GetUI("TreasureHuntGoldenKeyNum")
    local SilverKeyNum = _gt.GetUI("TreasureHuntSilverKeyNum")
    local PreviousFloorBtn = _gt.GetUI("PreviousFloorBtn")
    local NextFloorBtn = _gt.GetUI("NextFloorBtn")

    if TrackUI.TreasureHuntData then
        local data = TrackUI.TreasureHuntData
        local PosList = data.TransferPos
        local KeyList = data.Key

        GUI.ScrollBarSetPos(ScheduleBootSlider,data.NowMapIndex / TrackUI.TreasureHunt_MaxMapNum)
        GUI.StaticSetText(ScheduleBootSliderTotal,data.NowMapIndex .. "/" .. TrackUI.TreasureHunt_MaxMapNum)
        GUI.StaticSetText(GoldenKeyNum,"x " .. KeyList["金钥匙"])
        GUI.StaticSetText(SilverKeyNum,"x " .. KeyList["银钥匙"])

        if PosList.UpY and PosList.UpX and (PosList.UpY ~= 0 and PosList.UpX ~= 0) then
            GUI.ButtonSetShowDisable(PreviousFloorBtn, true)
            GUI.ButtonSetTextColor(_PreviousFloorBtn, UIDefine.WhiteColor)
        else
            GUI.ButtonSetShowDisable(PreviousFloorBtn, false)
            GUI.ButtonSetTextColor(_PreviousFloorBtn, UIDefine.GrayColor)
        end

        if PosList.DownY and PosList.DownX and (PosList.DownY ~= 0 and PosList.DownX ~= 0) then
            GUI.ButtonSetShowDisable(NextFloorBtn, true)
            GUI.ButtonSetTextColor(_PreviousFloorBtn, UIDefine.WhiteColor)
        else
            GUI.ButtonSetShowDisable(NextFloorBtn, false)
            GUI.ButtonSetTextColor(_PreviousFloorBtn, UIDefine.GrayColor)
        end
    end
    TrackUI.RefreshTreasureHuntCountDown()
    -- local inspect = require("inspect")
    -- test(inspect(TrackUI.TreasureHuntData))
end

function TrackUI.RefreshTreasureHuntCountDown()
    if TrackUI.TreasureHuntTimer then
        TrackUI.TreasureHuntTimer:Stop()
        TrackUI.TreasureHuntTimer:Reset(TrackUI.RefreshTreasureHuntCountDownFuc,1,-1)
    else
        TrackUI.TreasureHuntTimer = Timer.New(TrackUI.RefreshTreasureHuntCountDownFuc,1,-1)
    end
    TrackUI.TreasureHuntTimer:Start()
end

function TrackUI.RefreshTreasureHuntCountDownFuc()
    local CountDown = _gt.GetUI("TreasureHuntCountDown")
    local curTickCount = CL.GetServerTickCount()
    if TrackUI.TreasureHunt_EndTime and TrackUI.TreasureHunt_EndTime >= curTickCount then
        local second = TrackUI.TreasureHunt_EndTime - curTickCount
        local timeStr = GlobalUtils.GetTimeString(second)
        GUI.StaticSetText(CountDown,timeStr)
    end
end

function TrackUI.OnShowFightInfo8(parent)
    local _PIC1 = GUI.ImageCreate(parent, "PIC1", "1800200010", 0, 0, false, 254, 104)
    SetAnchorAndPivot(_PIC1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PIC2 = GUI.ImageCreate(parent, "PIC2", "1800200010", 0, 105, false, 254, 104)
    SetAnchorAndPivot(_PIC2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --393
    local _PIC3 = GUI.ImageCreate(parent, "PIC3", "1800200010", 0, 210, false, 254, 180)
    SetAnchorAndPivot(_PIC3, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local colorP = Color.New(220 / 255, 96 / 255, 247 / 255, 255 / 255)

    local _Title = GUI.CreateStatic(parent, "Title", "倒计时", 10, 15, 200, 30)
    SetAnchorAndPivot(_Title, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_Title, 21, colorP)

    local _CountDown = GUI.CreateStatic(parent, "CountDown", "00:00:00", 100, 15, 200, 30)
    SetAnchorAndPivot(_CountDown, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_CountDown, 24, UIDefine.WhiteColor)
    _gt.BindName(_CountDown,"ContestCountDown")

    local _Title2 = GUI.CreateStatic(parent, "Title2", "战   绩", 10, 60, 200, 30)
    SetAnchorAndPivot(_Title2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Title2, 21)
    GUI.SetColor(_Title2, colorP)

    local _Result = GUI.CreateStatic(parent, "Result", "0 - 0", 100, 60, 200, 30)
    SetAnchorAndPivot(_Result, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Result, 24)
    GUI.SetColor(_Result, UIDefine.WhiteColor)
    _gt.BindName(_Result,"Result")

    local _TipsBtn = GUI.ButtonCreate(parent, "TipsBtn", "1800702030", 200, 60, Transition.ColorTint, "",30,30,false)
    SetAnchorAndPivot(_TipsBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(_TipsBtn, UCE.PointerClick, "TrackUI", "OnContestTipsBtnClick")

    local _Title3 = GUI.CreateStatic(parent, "Title3", "积   分", 10, 120, 200, 30)
    SetAnchorAndPivot(_Title3, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Title3, 21)
    GUI.SetColor(_Title3, colorP)

    local _Score = GUI.CreateStatic(parent, "Score", "0", 100, 120, 200, 30)
    SetAnchorAndPivot(_Score, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Score, 24)
    GUI.SetColor(_Score, UIDefine.WhiteColor)
    _gt.BindName(_Score,"Score")

    local _Title4 = GUI.CreateStatic(parent, "Title4", "排   名", 10, 165, 200, 30)
    SetAnchorAndPivot(_Title4, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Title4, 21)
    GUI.SetColor(_Title4, colorP)

    local _CurRank = GUI.CreateStatic(parent, "CurRank", "0", 100, 165, 200, 30)
    SetAnchorAndPivot(_CurRank, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_CurRank, 24)
    GUI.SetColor(_CurRank, UIDefine.WhiteColor)
    _gt.BindName(_CurRank,"CurRank")

    local _RankBtn = GUI.ButtonCreate(parent, "RankBtn", "1800602020", 0, 240, Transition.ColorTint, "排行榜",120,46,false)
    SetAnchorAndPivot(_RankBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ButtonSetTextFontSize(_RankBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(_RankBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(_RankBtn, true)
    GUI.SetOutLine_Distance(_RankBtn,1)
    GUI.SetOutLine_Color(_RankBtn,UIDefine.BrownColor)
    GUI.RegisterUIEvent(_RankBtn, UCE.PointerClick, "TrackUI", "OnContestRankBtnClick")

    local _ExitBtn = GUI.ButtonCreate(parent, "ExitBtn", "1800602020", 0, 320, Transition.ColorTint, "退出",120,46,false)
    SetAnchorAndPivot(_ExitBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.ButtonSetTextFontSize(_ExitBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(_ExitBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(_ExitBtn, true)
    GUI.SetOutLine_Distance(_ExitBtn,1)
    GUI.SetOutLine_Color(_ExitBtn,UIDefine.BrownColor)
    GUI.RegisterUIEvent(_ExitBtn, UCE.PointerClick, "TrackUI", "OnContestExitBtnClick")
end

function TrackUI.OnContestTipsBtnClick()
    local Back = _gt.GetUI("FightInfo8Back")
    if TrackUI.SchoolContest_MaxLoseNum then
        local text = "当失败" .. TrackUI.SchoolContest_MaxLoseNum .. "场时，会被自动淘汰"
        Tips.CreateHint(text, Back, 0, -27, UILayout.Center, 200, 60)
    end
end

function TrackUI.OnContestRankBtnClick()
    test("排行榜按钮")
    if TrackUI.SchoolContest_RankID then
        GUI.OpenWnd(RankUI,tostring(TrackUI.SchoolContest_RankID))
    end
end

function TrackUI.OnContestExitBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormSchoolContest", "ExitAct")
end

function TrackUI.RefreshSchoolContest()
    local Result = _gt.GetUI("Result")
    local Score = _gt.GetUI("Score")
    local CurRank = _gt.GetUI("CurRank")

    GUI.StaticSetText(Result,TrackUI.SchoolContest_WinNum .. " - " .. TrackUI.SchoolContest_LoseNum)
    GUI.StaticSetText(Score,TrackUI.SchoolContest_Score)
    GUI.StaticSetText(CurRank,TrackUI.SchoolContest_Rank)
    TrackUI.RefreshSchoolContestCountDown()

    local inspect = require("inspect")
    test(inspect(TrackUI.SchoolContest_StateEndTime))

end

function TrackUI.RefreshSchoolContestCountDown()
    if TrackUI.SchoolContestTimer then
        TrackUI.SchoolContestTimer:Stop()
        TrackUI.SchoolContestTimer:Reset(TrackUI.RefreshSchoolContestCountDownFuc,1,-1)
    else
        TrackUI.SchoolContestTimer = Timer.New(TrackUI.RefreshSchoolContestCountDownFuc,1,-1)
    end
    TrackUI.RefreshSchoolContestCountDownFuc()
    TrackUI.SchoolContestTimer:Start()
end

function TrackUI.RefreshSchoolContestCountDownFuc()
    local CountDown = _gt.GetUI("ContestCountDown")
    local curTickCount = CL.GetServerTickCount()
    if TrackUI.SchoolContest_StateEndTime and TrackUI.SchoolContest_StateEndTime >= curTickCount then
        local second = TrackUI.SchoolContest_StateEndTime - curTickCount
        local timeStr = GlobalUtils.GetTimeString(second)
        GUI.StaticSetText(CountDown,timeStr)
    end
end
