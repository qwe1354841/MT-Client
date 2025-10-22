local HangUpUI = {}
_G.HangUpUI = HangUpUI
--require "GUIDriver"
require "UILayout";
--require "Tips";
--local goldRes = UILayout.goldRes;
--local iconGradeBg=UILayout.ItemIcon.QualityBigRes;

--配置

local GUI = GUI

local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

--可移动点表
local canMovePoint = {}

--可移动点随即次数
local randomNum = 0

local isAutomaticSelectStatus = false

local carTypeList = {}

	--x是width, z是height
HangUpUI.Config = {
	{Id = 1,  MapId = 301, LevelMin = 1,   LevelMax = 10,  MonName1 = "无根草",  Model1 = 05101, MonName2 = "小绵羊",  Model2 = 05103, MonName3 = "",  Model3 = 50001, MonName4 = "",  Model4 = 50001, Left = 80,  Top = 40, Width = 120, Height = 90, canMovePoint = {x = 110,z= 72}, },
	{Id = 2,  MapId = 302, LevelMin = 11,  LevelMax = 15,  MonName1 = "蟹将军",  Model1 = 05109, MonName2 = "野猪妖",  Model2 = 05102, MonName3 = "小绵羊",  Model3 = 05103, MonName4 = "",  Model4 = 50001, Left = 10,  Top = 55, Width = 190, Height = 75, canMovePoint = {x = 160,z= 63}, },
	{Id = 3,  MapId = 303, LevelMin = 16,  LevelMax = 20,  MonName1 = "野猪妖",  Model1 = 05102, MonName2 = "行者游魂",  Model2 = 05149, MonName3 = "蟹将军",  Model3 = 05109, MonName4 = "",  Model4 = 50001, Left = 15,  Top = 45, Width = 125, Height = 75, canMovePoint = {x = 113,z= 53}, },
	{Id = 4,  MapId = 304, LevelMin = 21,  LevelMax = 25,  MonName1 = "行者游魂",  Model1 = 05149, MonName2 = "小虎妖",  Model2 = 05118, MonName3 = "浣灵熊",  Model3 = 05122, MonName4 = "",  Model4 = 50001, Left = 75,  Top = 35, Width = 125, Height = 85,canMovePoint = {x = 135,z= 47},  },
	{Id = 5,  MapId = 305, LevelMin = 26,  LevelMax = 30,  MonName1 = "小虎妖",  Model1 = 05118, MonName2 = "岩穴鳄",  Model2 = 05161, MonName3 = "旋龟",  Model3 = 05111, MonName4 = "",  Model4 = 50001, Left = 15,  Top = 45, Width = 165, Height = 35,canMovePoint = {x = 59,z= 51},  },
	{Id = 6,  MapId = 306, LevelMin = 31,  LevelMax = 35,  MonName1 = "山贼斥候",  Model1 = 05104, MonName2 = "瑞兽幼崽",  Model2 = 05155, MonName3 = "雪坊主",  Model3 = 05133, MonName4 = "",  Model4 = 50001, Left = 5,	Top = 30, Width = 175, Height = 45,canMovePoint = {x = 64,z= 45},  },
	{Id = 7,  MapId = 307, LevelMin = 36,  LevelMax = 40,  MonName1 = "雪坊主",  Model1 = 05133, MonName2 = "山贼斥候",  Model2 = 05104, MonName3 = "女尸怨灵",  Model3 = 05319, MonName4 = "",  Model4 = 50001, Left = 5,	Top = 35, Width = 145, Height = 55,canMovePoint = {x = 74,z= 53},  },
	{Id = 8,  MapId = 226, LevelMin = 40,  LevelMax = 43,  MonName1 = "剧毒蜘蛛",  Model1 = 05153, MonName2 = "青冥灯",  Model2 = 05146, MonName3 = "",  Model3 = 50001, MonName4 = "",  Model4 = 50001, Left = 5,	Top = 20, Width = 130, Height = 100,canMovePoint = {x = 51,z= 112}, },
	{Id = 9,  MapId = 227, LevelMin = 44,  LevelMax = 48,  MonName1 = "青冥灯",  Model1 = 05146, MonName2 = "水判官",  Model2 = 05107, MonName3 = "灵木怪",  Model3 = 05162, MonName4 = "",  Model4 = 10034, Left = 35,	Top = 35, Width = 135, Height = 85,canMovePoint = {x = 135,z= 22},  },
	{Id = 10, MapId = 228, LevelMin = 49,  LevelMax = 52,  MonName1 = "剧毒蜘蛛",  Model1 = 05153, MonName2 = "幻灵鹿",  Model2 = 05131, MonName3 = "青冥灯",  Model3 = 05146, MonName4 = "",  Model4 = 50001, Left = 45,	Top = 30, Width = 125, Height = 90,canMovePoint = {x = 61,z= 86},  },
	{Id = 11, MapId = 229, LevelMin = 53,  LevelMax = 57,  MonName1 = "幻灵鹿",  Model1 = 05131, MonName2 = "魅音狐",  Model2 = 05116, MonName3 = "土灵熊",  Model3 = 05126, MonName4 = "",  Model4 = 50001, Left = 30,	Top = 20, Width = 140, Height = 65, canMovePoint = {x = 50,z= 88}, },
	{Id = 12, MapId = 230, LevelMin = 58,  LevelMax = 62,  MonName1 = "魅音狐",  Model1 = 05116, MonName2 = "土灵熊",  Model2 = 05126, MonName3 = "赤炎狼",  Model3 = 05125, MonName4 = "",  Model4 = 50001, Left = 5,   Top = 30, Width = 165, Height = 60, canMovePoint = {x = 39,z= 32}, },
	{Id = 13, MapId = 231, LevelMin = 63,  LevelMax = 66,  MonName1 = "幻灵鹿",  Model1 = 05131, MonName2 = "赤炎狼",  Model2 = 05125, MonName3 = "魅音狐",  Model3 = 05116, MonName4 = "",  Model4 = 50001, Left = 10,  Top = 30, Width = 160, Height = 90, canMovePoint = {x = 50,z= 33}, },
	{Id = 14, MapId = 232, LevelMin = 67,  LevelMax = 70,  MonName1 = "土灵熊",  Model1 = 05126, MonName2 = "天神石像",  Model2 = 05119, MonName3 = "裂天兕",  Model3 = 05115, MonName4 = "",  Model4 = 50001, Left = 5,   Top = 20, Width = 165, Height = 100,canMovePoint = {x = 120,z= 35}, },
	{Id = 15, MapId = 219, LevelMin = 70,  LevelMax = 73,  MonName1 = "水帘妖",  Model1 = 05138, MonName2 = "洞花妖",  Model2 = 05112, MonName3 = "",  Model3 = 50001, MonName4 = "",  Model4 = 50001, Left = 15,  Top = 20, Width = 170, Height = 65,canMovePoint = {x = 114,z= 102},  },
	{Id = 16, MapId = 220, LevelMin = 74,  LevelMax = 78,  MonName1 = "洞花妖",  Model1 = 05112, MonName2 = "玄阴蝎",  Model2 = 05134, MonName3 = "水帘妖",  Model3 = 05138, MonName4 = "",  Model4 = 50001, Left = 40,  Top = 20, Width = 140, Height = 70,canMovePoint = {x = 172,z= 52},  },
	{Id = 17, MapId = 221, LevelMin = 79,  LevelMax = 82,  MonName1 = "玄阴蝎",  Model1 = 05134, MonName2 = "玄阴霜豹",  Model2 = 05136, MonName3 = "洞花妖",  Model3 = 05112, MonName4 = "",  Model4 = 50001, Left = 40,  Top = 15, Width = 140, Height = 105,canMovePoint = {x = 87,z= 64}, },
	{Id = 18, MapId = 222, LevelMin = 83,  LevelMax = 87,  MonName1 = "玄阴霜豹",  Model1 = 05136, MonName2 = "玄阴蝎",  Model2 = 05134, MonName3 = "素尾白狐",  Model3 = 05130, MonName4 = "",  Model4 = 50001, Left = 5,   Top = 5,  Width = 145, Height = 115,canMovePoint = {x = 133,z= 93}, },
	{Id = 19, MapId = 223, LevelMin = 88,  LevelMax = 92,  MonName1 = "素尾白狐",  Model1 = 05130, MonName2 = "冰魄剑灵",  Model2 = 05137, MonName3 = "踏火神犀",  Model3 = 05140, MonName4 = "",  Model4 = 50001, Left = 40,  Top = 5,  Width = 115, Height = 115,canMovePoint = {x = 166,z= 61}, },
	{Id = 20, MapId = 224, LevelMin = 93,  LevelMax = 96,  MonName1 = "踏火神犀",  Model1 = 05140, MonName2 = "水帘妖",  Model2 = 05138, MonName3 = "玄阴霜豹",  Model3 = 05136, MonName4 = "",  Model4 = 50001, Left = 50,  Top = 10, Width = 130, Height = 110,canMovePoint = {x = 36,z= 36}, },
	{Id = 21, MapId = 225, LevelMin = 97,  LevelMax = 100, MonName1 = "水帘妖",  Model1 = 05138, MonName2 = "素尾白狐",  Model2 = 05130, MonName3 = "冰魄剑灵",  Model3 = 05137, MonName4 = "",  Model4 = 50001, Left = 40,  Top = 10, Width = 140, Height = 110,canMovePoint = {x = 95,z= 59}, },
	{Id = 22, MapId = 240, LevelMin = 100, LevelMax = 102, MonName1 = "邪毅将军",  Model1 = 05304, MonName2 = "熔火石灵",  Model2 = 05307, MonName3 = "器灵",  Model3 = 05303, MonName4 = "",  Model4 = 50001, Left = 35,  Top = 35, Width = 85,  Height = 55,canMovePoint = {x = 61,z= 33},  },
	{Id = 23, MapId = 241, LevelMin = 103, LevelMax = 105, MonName1 = "药童子",  Model1 = 05302, MonName2 = "冥焰火凤",  Model2 = 05292, MonName3 = "怨灵鬼",  Model3 = 05300, MonName4 = "巨灵神",  Model4 = 05312, Left = 40,  Top = 40, Width = 120, Height = 90,canMovePoint = {x = 31,z= 57},  },
	{Id = 24, MapId = 242, LevelMin = 106, LevelMax = 108, MonName1 = "怨灵鬼",  Model1 = 05300, MonName2 = "熔火石灵",  Model2 = 05307, MonName3 = "器灵",  Model3 = 05303, MonName4 = "云中仙",  Model4 = 05314, Left = 10,  Top = 30, Width = 70,  Height = 90,canMovePoint = {x = 82,z= 79},  },
	{Id = 25, MapId = 243, LevelMin = 109, LevelMax = 111, MonName1 = "邪毅将军",  Model1 = 05304, MonName2 = "药童子",  Model2 = 05302, MonName3 = "冥焰火凤",  Model3 = 05292, MonName4 = "迦楼纳什",  Model4 = 05318, Left = 35,  Top = 20, Width = 100, Height = 70,canMovePoint = {x = 21,z= 11},  },
	{Id = 26, MapId = 244, LevelMin = 112, LevelMax = 114, MonName1 = "怨灵鬼",  Model1 = 05300, MonName2 = "熔火石灵",  Model2 = 05307, MonName3 = "器灵",  Model3 = 05303, MonName4 = "小花仙",  Model4 = 05291, Left = 30,  Top = 10, Width = 120, Height = 45, canMovePoint = {x = 34,z= 19}, },
	{Id = 27, MapId = 245, LevelMin = 115, LevelMax = 117, MonName1 = "熔火石灵",  Model1 = 05307, MonName2 = "器灵",  Model2 = 05303, MonName3 = "怨灵鬼",  Model3 = 05300, MonName4 = "千年树灵",  Model4 = 05297, Left = 30,  Top = 30, Width = 110, Height = 90,canMovePoint = {x = 79,z= 68},  },
	{Id = 28, MapId = 246, LevelMin = 118, LevelMax = 120, MonName1 = "器灵",  Model1 = 05303, MonName2 = "冥焰火凤",  Model2 = 05292, MonName3 = "药童子",  Model3 = 05302, MonName4 = "七仙女",  Model4 = 05315, Left = 30,  Top = 20, Width = 160, Height = 80,canMovePoint = {x = 104,z= 82},  },
}



--颜色字体
local previewColor = Color.New(0/255,200/255,30/255,255/255);
local colorDark = Color.New(102/255,47/255,22/255,255/255)
local colorYellow = Color.New(172/255,117/255,39/255,255/255)
local colorRed = Color.New(255/255, 0/255, 0/255, 255/255)
local colorLeft = Color.New(80/255, 55/255, 38/255, 255/255)
local colorWhite = Color.New(255/255, 246/255, 232/255, 255/255)
local coloroutline = Color.New(162/255.0,75/225.0,21/255.0,1)
local invisibilityColor = Color.New(255/255,255/255,255/255,0/255);
local outLineColor = Color.New(180/255,92/255,31/255,255/255);
local OutLineColor = Color.New(162/255,75/255,21/255,255/255);
local whiteColor = Color.New(255/255,255/255,255/255,255/255);
local levelOutLineColor = Color.New(0/255,0/255,0/255,255/255);
local titleOutLineColor = Color.New(162/255,75/255,21/255,255/255);
local defaultColor = Color.New(255/255,255/255,255/255,255/255);
local pointColor = Color.New(63/255,250/255,93/255,255/255);
local colorwrite = Color.New(1,1,1,1);
local subBtnColor = Color.New(142/255,75/255,39/255,255/255);
local BtnColor = Color.New(144/255,84/255,56/255,255/255);
local TextColor = Color.New(109 / 255, 60 / 255, 20 / 255, 255 / 255)
local colorLevel = Color.New(169/255, 127/255, 85/255, 255/255)
local colorLight  = Color.New(247/255,232/255,184/255,255/255) ;

local fontSizeBigger = 24
local fontSizeDefault = 22
local skillIconClickTimer ;

local _gt = UILayout.NewGUIDUtilTable()

HangUpUI.LastGUID = 0

local MapId_Chosen_x1 = 0
local MapId_Chosen_z1 = 0
local When_Click_MapId = 0

function HangUpUI.Main(parameter)	
	
	_gt = UILayout.NewGUIDUtilTable()
	if not HangUpUI.Config then
		test("=======not HangUpUI.Config");
		return
	end
	
	HangUpUI.UIPart = {}
	HangUpUI.UIPart.LeftToggles = {}
	HangUpUI.UIPart.RightGroups = {}
	HangUpUI.UIPart.AllRawImageChildren = {}
	HangUpUI.DataPart = {}
	HangUpUI.DataPart.autoAttactSkillID = 0;
	HangUpUI.DataPart.autoDefenseSkillID = 0;
	HangUpUI.DataPart.LeftSelectID = 0;
	HangUpUI.DataPart.isRoleSkillPopup = false;

	local panel = GUI.WndCreateWnd("HangUpUI", "HangUpUI", 0, 0);
	UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)
	_gt.BindName(panel, "panel");
	local panelBg = UILayout.CreateFrame_WndStyle0(panel, "挂  机","HangUpUI","OnExit");
	_gt.BindName(panelBg, "panelBg");
	--local panelBg= UILayout.CreateBg(panel,"挂  机")
	HangUpUI.UIPart.PopupParent = panelBg
	GUI.SetAnchor(panelBg, UIAnchor.Center)
	GUI.SetPivot(panelBg, UIAroundPivot.Center)
	
	local leftPartBg=GUI.ImageCreate(panelBg,"LeftPartBg","1800400200",70.1,64.1,false ,209.4,552.3);
	GUI.SetAnchor(leftPartBg,UIAnchor.TopLeft);
	GUI.SetPivot(leftPartBg,UIAroundPivot.TopLeft);

	GUI.SetPaddingVertical(scroll_Left,Vector2.New(10,110))
	local vecSpacing=Vector2.New(0, 100);
	GUI.ScrollRectSetChildSpacing(scroll_Left,vecSpacing);

	local rightPartBg=GUI.ImageCreate(panelBg,"RightPartBg","1800400200",110,-86.48,false ,833,359.9);
	HangUpUI.UIPart.RightPartParent = rightPartBg
	
	--local rightDownPartBg=GUI.ImageCreate(panelBg,"rightDownPartBg","",110,220,false ,0,0);
	local rightDownPartBg=GUI.GroupCreate(panelBg,"rightDownPartBg",110,220 ,0,0);
	_gt.BindName(rightDownPartBg, "rightDownPartBg");
	GUI.SetAnchor(rightDownPartBg, UIAnchor.Center)
	GUI.SetPivot(rightDownPartBg, UIAroundPivot.Center)
	--GUI.SetDepth(rightDownPartBg,100)
	
	local autoFightMain=GUI.ImageCreate(rightDownPartBg,"autoFightMain","1800400200",35.7,-27,false ,334.8,187.1);
	_gt.BindName(autoFightMain,"autoFightMain")

	local autoFightCheckBox = GUI.CheckBoxCreate( autoFightMain,"autoFightCheckBox", "1800607150", "1800607151", 12.1, 15.07, Transition.None, false, 42, 40)
	GUI.SetAnchor(autoFightCheckBox, UIAnchor.TopLeft)
	GUI.SetPivot(autoFightCheckBox, UIAroundPivot.TopLeft)
	HangUpUI.UIPart.autoFightCheckBox = autoFightCheckBox
	GUI.CheckBoxSetCheck(autoFightCheckBox,CL.OnGetAutoFightState())
	GUI.RegisterUIEvent(autoFightCheckBox, UCE.PointerClick, "HangUpUI", "OnAutoFightCheckBoxChanged")

	local autoFightCheckBoxLabel = GUI.CreateStatic(autoFightCheckBox,"autoFightCheckBoxLabel", "自动战斗", 47, -30, 200, 100)
	GUI.StaticSetFontSize(autoFightCheckBoxLabel, 20)
	GUI.SetColor(autoFightCheckBoxLabel, TextColor)

	--挂机技能图标
	--主角
	local characSKillBtnPartBg=GUI.ImageCreate(autoFightMain,"characSKillBtnPartBg","1800802030",-78,25.5,false,94,94);
	local ChaSkillShow = GUI.ButtonCreate(characSKillBtnPartBg, "ChaSkillShow", "1800001060", -8,6,Transition.ColorTint,"",80,80,false)
	GUI.SetAnchor(ChaSkillShow, UIAnchor.TopRight)
	GUI.SetPivot(ChaSkillShow, UIAroundPivot.TopRight)
	_gt.BindName(ChaSkillShow, "ChaSkillShow");
	GUI.RegisterUIEvent(ChaSkillShow, UCE.PointerClick, "HangUpUI", "OnClickChaSkillShow")
	local characterSkillCornerLabel = GUI.ImageCreate(characSKillBtnPartBg,"characterSkillCornerLabel","1800807050",0,0);
	GUI.SetAnchor(characterSkillCornerLabel, UIAnchor.TopRight)
	GUI.SetPivot(characterSkillCornerLabel, UIAroundPivot.TopRight)

	--宠物
	local petSKillBtnPartBg=GUI.ImageCreate(autoFightMain,"petSKillBtnPartBg","1800802030",69.6,25.5, false,94,94);
	local PetSkillShow = GUI.ButtonCreate(petSKillBtnPartBg, "PetSkillShow", "1800302210", -8,6,Transition.ColorTint,"",80,80,false)
	GUI.SetAnchor(PetSkillShow, UIAnchor.TopRight)
	GUI.SetPivot(PetSkillShow, UIAroundPivot.TopRight)
	_gt.BindName(PetSkillShow, "PetSkillShow");
	GUI.RegisterUIEvent(PetSkillShow, UCE.PointerClick, "HangUpUI", "OnClickPetSkillShow")
	local petSkillCornerLabel = GUI.ImageCreate(petSKillBtnPartBg,"petSkillCornerLabel","1800807060",0,0);
	GUI.SetAnchor(petSkillCornerLabel, UIAnchor.TopRight)
	GUI.SetPivot(petSkillCornerLabel, UIAroundPivot.TopRight)
	HangUpUI.Skill_Refresh()
	
	local buyDoubleBtn  =  GUI.ButtonCreate(rightDownPartBg,"buyDoubleBtn","1800402080",-274.2,40.6,Transition.ColorTint,"双倍购买",140,47,false);
	GUI.SetIsOutLine(buyDoubleBtn,true);
	GUI.SetOutLine_Setting(buyDoubleBtn,OutLineSetting.OutLine_Orange2_1)
	GUI.ButtonSetTextFontSize(buyDoubleBtn,26);
	GUI.ButtonSetTextColor(buyDoubleBtn,colorwrite);
	GUI.SetOutLine_Color(buyDoubleBtn,coloroutline);
	GUI.SetOutLine_Distance(buyDoubleBtn,1);
	GUI.RegisterUIEvent(buyDoubleBtn , UCE.PointerClick , "HangUpUI", "OnclickBuyDoubleBtn");

	--领双相关功能
	local doubleBgMain=GUI.ImageCreate(rightDownPartBg,"doubleBgMain","1800400200",-278.3,-57.8,false ,275.4,126.5);

	local hasGotDoubleBg = GUI.ImageCreate(doubleBgMain,"hasGotDoubleBg","1800800010",-38,-28.6,false ,172,35.5);
	local hasGotDoubleTxt = GUI.CreateStatic(hasGotDoubleBg,"hasGotDoubleTxt","已领取：",10,0,200,50);
	_gt.BindName(hasGotDoubleTxt,"hasGotDoubleTxt")
	GUI.SetColor(hasGotDoubleTxt, TextColor)
	GUI.StaticSetFontSize(hasGotDoubleTxt, 20)
	GUI.SetAnchor(hasGotDoubleTxt, UIAnchor.Left)
	GUI.SetPivot(hasGotDoubleTxt, UIAroundPivot.Left)
	HangUpUI.UIPart.TxtDoubleTimeOnRole = hasGotDoubleTxt

	local saveBtn = GUI.ButtonCreate(hasGotDoubleBg,"saveBtn","1800402080",117.6,0,Transition.ColorTint,"冻结",99,47,false);
	HangUpUI.UIPart.BtnSaveTime = saveBtn
	
	GUI.SetIsOutLine(saveBtn,true);
	GUI.SetOutLine_Setting(saveBtn,OutLineSetting.OutLine_Orange2_1)	
	GUI.ButtonSetTextFontSize(saveBtn,26);
	GUI.ButtonSetTextColor(saveBtn,colorwrite);
	GUI.SetOutLine_Color(saveBtn,coloroutline);
	GUI.SetOutLine_Distance(saveBtn,1);
	GUI.RegisterUIEvent(saveBtn, UCE.PointerClick , "HangUpUI", "OnclickSaveBtn");

	local allGotDoubleBg = GUI.ImageCreate(doubleBgMain,"allGotDoubleBg","1800800010",-38,27.4,false ,172,35.5);
	local allDoubleTxt = GUI.CreateStatic(allGotDoubleBg,"allDoubleTxt","双倍点数：",10,0,200,50);
	_gt.BindName(allDoubleTxt,"allDoubleTxt")
	GUI.SetColor(allDoubleTxt, TextColor)
	GUI.StaticSetFontSize(allDoubleTxt, 20)
	GUI.SetAnchor(allDoubleTxt, UIAnchor.Left)
	GUI.SetPivot(allDoubleTxt, UIAroundPivot.Left)
	HangUpUI.UIPart.TxtAllDoubleLeft = allDoubleTxt
	local loadBtn  =  GUI.ButtonCreate(allGotDoubleBg,"loadBtn","1800402080",117.3,0,Transition.ColorTint,"提取",99,47,false);
	HangUpUI.UIPart.BtnLoadime = loadBtn
	
	GUI.SetIsOutLine(loadBtn,true);
	GUI.SetOutLine_Setting(loadBtn,OutLineSetting.OutLine_Orange2_1)	
	GUI.ButtonSetTextFontSize(loadBtn,26);
	GUI.ButtonSetTextColor(loadBtn,colorwrite);
	GUI.SetOutLine_Color(loadBtn,coloroutline);
	GUI.SetOutLine_Distance(loadBtn,1);
	GUI.RegisterUIEvent(loadBtn , UCE.PointerClick , "HangUpUI", "OnclickLoadBtn");

	local BigHangUpBtn = GUI.ButtonCreate(allGotDoubleBg,"BigHangUpBtn","1800802020",627.7,0,Transition.ColorTint,"挂机",168,168,false);

	GUI.SetIsOutLine(BigHangUpBtn,true);
	GUI.SetOutLine_Setting(BigHangUpBtn,OutLineSetting.OutLine_Orange2_1)	
	GUI.ButtonSetTextFontSize(BigHangUpBtn,42);
	GUI.ButtonSetTextColor(BigHangUpBtn,colorwrite);
	GUI.SetOutLine_Color(BigHangUpBtn,coloroutline);
	GUI.SetOutLine_Distance(BigHangUpBtn,1);
	GUI.RegisterUIEvent(BigHangUpBtn , UCE.PointerClick , "HangUpUI", "Role_Lv");
 
	if not UIDefine.HangUpUI_LastID then
		UIDefine.HangUpUI_LastID = 1
	end
	
	local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel);
	local RecommendMap_Index = 0
	for i = 1, #HangUpUI.Config do
		if roleLevel <= HangUpUI.Config[i]["LevelMax"] and HangUpUI.Config[i]["LevelMin"] <= roleLevel then
			RecommendMap_Index = i
			--RecommendMap_Index = GUI.SetData(RecommendMap, "RecommendMap_Index", i)
		end
	end
	
	
	UIDefine.HangUpUI_LastID = RecommendMap_Index
	
	local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
	local rlNum = 0
	for i = 1, #HangUpUI.Config do
		if HangUpUI.Config[i]["LevelMin"] <= roleLevel and roleLevel <= HangUpUI.Config[i]["LevelMax"] then
			rlNum = i
		end
	end
	UIDefine.HangUpUI_rlIndex = rlNum
	
	--左边地图界面
	local vec = Vector2.New(198, 77);
	local scroll_Left = GUI.LoopScrollRectCreate(leftPartBg, "scroll_Left" , 6, 5, 219, 539, "HangUpUI", "CreateLeftMap", "HangUpUI", "RefreshLeftMap", 1, false, vec, 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft);
	--GUI.ScrollRectSetChildSpacing(scroll_Left, Vector2.New(0, 2))
	_gt.BindName(scroll_Left, "scroll_Left")
	
	HangUpUI.UIPart.LeftScroller = scroll_Left
	
	--HangUpUI.Refresh()
	GUI.LoopScrollRectSetTotalCount(scroll_Left, #HangUpUI.Config)
	GUI.LoopScrollRectRefreshCells(scroll_Left)
	
	--上方4个怪物栏
	for i = 1, 4 do
		local MonsterBar = GUI.ButtonCreate(rightPartBg, "MonsterBar"..i, "1800800030",206*i-202,0,Transition.None, "", 206,350,false)
		GUI.SetAnchor(MonsterBar, UIAnchor.Left)
		GUI.SetPivot(MonsterBar, UIAroundPivot.Left)
		
		local MonsterBar_figure = GUI.ImageCreate(MonsterBar, "MonsterBar_figure"..i, "1800400230", 38,-30,false, 130,130)
		local MonsterBar_Shadow = GUI.ImageCreate(MonsterBar, "MonsterBar_Shadow"..i, "1800400240", 0, 95, false, 200, 70)
		local MonsterBar_Line = GUI.ImageCreate(MonsterBar, "MonsterBar_Line"..i, "1800800210", -7, 130,false, 220,30)
		
		MonsterBar_Guid = GUI.GetGuid(MonsterBar)
		GUI.RegisterUIEvent(MonsterBar, UCE.PointerClick, "HangUpUI", "OnModelClick")
		GUI.SetData(MonsterBar, "MonsterBar_guid", ""..MonsterBar_Guid)
		GUI.SetData(MonsterBar, "MonsterBar_index", i)
		_gt.BindName(MonsterBar,"MonB"..i)		--给四个怪物栏的Guid绑定
		GUI.SetVisible(MonsterBar, false)  --怪物栏设置是否可见		
		local Mon_Name = GUI.CreateStatic(MonsterBar, "Mon_Name"..i, "怪物"..tostring(i),28,140,150,50) 
		GUI.SetColor(Mon_Name, colorDark)
		GUI.StaticSetFontSize(Mon_Name, 24)
		GUI.StaticSetAlignment(Mon_Name, TextAnchor.MiddleCenter)
		_gt.BindName(Mon_Name, "Mon_Name"..i);	
	end
	
	local model = GUI.RawImageCreate(panelBg, false, "model", "", 110, -160, 3, false, 950, 830)
	_gt.BindName(model, "model");
	model:RegisterEvent(UCE.Drag)
	model:RegisterEvent(UCE.PointerClick)
	GUI.AddToCamera(model);
	GUI.RawImageSetCameraConfig(model, "(0.5,1.2,2),(0,1,0,-4.371139E-08),True,5,0.01,2.7,1E-05");
	GUI.SetIsRaycastTarget(model, false)
	
	for i = 1, 4 do
		local Mon_Model = GUI.RawImageChildCreate(model, true, "Mon_Model"..i, "", 0, 0)
		GUI.RegisterUIEvent(Mon_Model, ULE.AnimationCallBack, "HangUpUI", "OnAnimationCallBack")
		GUI.SetData(Mon_Model, "Mon_Model_index", i)
		_gt.BindName(Mon_Model, "Mon_Model"..i);
	end
	
	local MB_TB = {}
	local Last_Model = {}
	for i = 1, 4 do
		if HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['MonName'..i] ~= "" and HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['Model'..i] ~=0 then
			table.insert(MB_TB, i)
			table.insert(Last_Model, HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['Model'..i])
		end	
	end
	
	for k, v in pairs(MB_TB) do
		local MonsterBar = _gt.GetUI("MonB"..k)
		--Model_Id = MB_TB[v]
		GUI.SetVisible(MonsterBar, true)
		local Mon_Name = _gt.GetUI("Mon_Name"..k)
		GUI.StaticSetText(Mon_Name, HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['MonName'..k])
	end

	--向服务器请求双倍点数相关的内容
	CL.SendNotify(NOTIFY.SubmitForm, "FormHangUp", "get_data") 
	
	CL.UnRegisterMessage(GM.FightAutoSkillChange, "HangUpUI", "Skill_Refresh")
    CL.RegisterMessage(GM.FightAutoSkillChange, "HangUpUI", "Skill_Refresh")

	HangUpUI.Refresh()
	
	GUI.LoopScrollRectSrollToCell(scroll_Left, UIDefine.HangUpUI_LastID - 1, 0)
	
	CL.UnRegisterMessage(GM.CustomDataUpdate, "HangUpUI", "OnCustomDataUpdate")
	CL.RegisterMessage(GM.CustomDataUpdate, "HangUpUI", "OnCustomDataUpdate")
end

function HangUpUI.OnCustomDataUpdate(type, key, val)
	test("OnCustomDataUpdate")
	if key == "DoubleExpPoint" or "FreezeDoubleExpPoint" then
        CL.SendNotify(NOTIFY.SubmitForm, "FormHangUp", "get_data")
    end
end
function HangUpUI.OnShow(parameter)	
	local wnd = GUI.GetWnd("HangUpUI")
	if wnd then
		GUI.SetVisible(wnd, true);
		HangUpUI.Refresh()
		HangUpUI.Skill_Refresh()
		local scroll_Left = _gt.GetUI("scroll_Left")
		if scroll_Left and UIDefine.HangUpUI_LastID and UIDefine.HangUpUI_LastID >= 1 then
			GUI.LoopScrollRectSrollToCell(scroll_Left, UIDefine.HangUpUI_LastID - 1, 0)
		end
		CL.SendNotify(NOTIFY.SubmitForm, "FormHangUp", "get_data") 
	else
		HangUpUI.Main(parameter)
	end
end

--创建或刷新新增自动施法功能按钮
function HangUpUI.CreateOrRefreshAutomaticTypeBtn()
	-- 获取角色等级
	local curLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)

	if GlobalProcessing.AutomaticCasting_OpenLevel and curLevel >= GlobalProcessing.AutomaticCasting_OpenLevel  then

		if UIDefine.FunctionSwitch["AutomaticCasting"] and UIDefine.FunctionSwitch["AutomaticCasting"] == "on" then

			--------------------------------------------------------Start 新增自动施法功能 Start-----------------------------------------------------

			if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= nil then

				local autoFightMain = _gt.GetUI("autoFightMain")

				local automaticTypeBtn = GUI.GetChild(autoFightMain,"automaticTypeBtn",false)

				HangUpUI.SetAutomaticCastingTableData()

				if automaticTypeBtn == nil then

					--自动施法方案选择按钮
					automaticTypeBtn = GUI.ButtonCreate(autoFightMain, "automaticTypeBtn", "1800402080", -10, 10, Transition.ColorTint, "", 140, 45, false);
					SetSameAnchorAndPivot(automaticTypeBtn, UILayout.TopRight)
					GUI.RegisterUIEvent(automaticTypeBtn, UCE.PointerClick, "HangUpUI", "OnAutomaticTypeBtnClick")
					_gt.BindName(automaticTypeBtn,"automaticTypeBtn")

					local text = GUI.CreateStatic(automaticTypeBtn, "text","", 5, 0, 180, 35);

					if GlobalProcessing.AutomaticCasting_CurSchemeIndex == 0 then

						GUI.StaticSetText(text,"无")

					else

						local name = carTypeList[GlobalProcessing.AutomaticCasting_CurSchemeIndex].name
						local nameLength = utf8.len(name)

						if nameLength > 1 then
							name = utf8.sub(name,1,3)..".."
						end
						GUI.StaticSetText(text,name)

					end

					GUI.StaticSetFontSize(text, 24)
					GUI.SetIsOutLine(text,true);
					GUI.SetOutLine_Setting(text,OutLineSetting.OutLine_Orange2_1)
					GUI.SetOutLine_Color(text,coloroutline);
					GUI.SetOutLine_Distance(text,1);
					GUI.SetColor(text,colorwrite)
					SetSameAnchorAndPivot(text, UILayout.Center)
					GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter);

					local arrow = GUI.ImageCreate(automaticTypeBtn, "arrow", "1800607140", -45, 0, false, 20, 12);
					GUI.SetEulerAngles(arrow,Vector3.New(180,0 , 0)) --重置旋转
					SetSameAnchorAndPivot(arrow, UILayout.Center)

				else

					local text = GUI.GetChild(automaticTypeBtn,"text",false)


					if GlobalProcessing.AutomaticCasting_CurSchemeIndex == 0 then

						GUI.StaticSetText(text,"无")

					else

						local name = carTypeList[GlobalProcessing.AutomaticCasting_CurSchemeIndex].name
						local nameLength = utf8.len(name)

						if nameLength > 2 then
							name = utf8.sub(name,1,3)..".."
						end

						GUI.StaticSetText(text,name)

					end


				end


				--刷新自动挂机施放技能的技能id
				GlobalProcessing.RefreshAutomaticCastingData()

			end

			----------------------------------------------------------End 新增自动施法功能 End-----------------------------------------------------

		end

	end

end

function HangUpUI.Refresh()
	--local scroll_Left = _gt.GetUI("scroll_Left")
	local MB_TB = {}
	HangUpUI.LastModelTB = {}
	local Last_Model = {}
	for i = 1, 4 do
		local Mon_Model = _gt.GetUI("Mon_Model"..i)
		GUI.SetVisible(Mon_Model, false)
	end
	for i = 1, 4 do
		if HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['MonName'..i] ~= "" and HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['Model'..i] ~=0 then
			table.insert(MB_TB, i)
			table.insert(Last_Model, HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['Model'..i])
		end	
	end
	for k, v in pairs(MB_TB) do
		local MonsterBar = _gt.GetUI("MonB"..k)
		local Mon_Name = _gt.GetUI("Mon_Name"..k)
		--Model_Id = MB_TB[v]
		GUI.SetVisible(MonsterBar, true)
		GUI.StaticSetText(Mon_Name, HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['MonName'..k])
	end
	for k, v in pairs(Last_Model) do					--替换怪物模型
		local Mon_Model = _gt.GetUI("Mon_Model"..k)
		GUI.SetVisible(Mon_Model, true)
		ModelItem.Bind(Mon_Model, v, nil, nil, eRoleMovement.STAND_W1)	
		GUI.SetLocalPosition(Mon_Model, 2.2-1.17*(k-1),0.15,0)
		GUI.RawImageChildSetModleRotation(Mon_Model, Vector3.New(6,-45,-7))	
		GUI.SetLocalScale(Mon_Model, 0.7,0.7,0.7)
	end
	
	HangUpUI.LastModelTB = Last_Model


	--创建或刷新新增自动施法功能按钮
	HangUpUI.CreateOrRefreshAutomaticTypeBtn()
end

function HangUpUI.CreateLeftMap()						--左侧地图循环列表生成
	local scroll_Left = _gt.GetUI("scroll_Left")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll_Left);
	--左边标签栏
	local i = curCount + 1
	
	local Left_Map = GUI.ButtonCreate(scroll_Left, "Left_Map"..i, "1800800030",70.1,64.1,Transition.ColorTint, "",209.4,552.3,false);
	local MapTxtSet = GUI.CreateStatic(Left_Map, "MapTxtSet","", 25, 2, 150, 50)
	GUI.StaticSetAlignment(MapTxtSet, TextAnchor.MiddleCenter)
	GUI.StaticSetFontSize(MapTxtSet, 22)
	GUI.SetColor(MapTxtSet,colorDark)
	
	local levelDes = GUI.CreateStatic(Left_Map, "levelDes", "", 25, 32, 150, 50)
	UILayout.SetSameAnchorAndPivot(Left_Map, UILayout.Center)
	GUI.StaticSetAlignment(levelDes, TextAnchor.MiddleCenter)
	GUI.ButtonSetTextFontSize(Left_Map, UIDefine.FontSizeL)
    GUI.ButtonSetTextColor(Left_Map,UIDefine.BrownColor)
	
	GUI.StaticSetFontSize(levelDes, fontSizeDefault)
	GUI.SetColor(levelDes, colorLevel)
    GUI.RegisterUIEvent(Left_Map , UCE.PointerClick , "HangUpUI", "Left_MapClick")
	--Left_Map_Guid = GUI.GetGuid(Left_Map)
	
	local RecommendMap = GUI.ImageCreate(Left_Map, "RecommendMap", "1800805040", -76, -14, false, 45, 45)
	GUI.SetVisible(RecommendMap, false)
	return Left_Map
end

function HangUpUI.RefreshLeftMap(parameter)					--循环列表刷新
	parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
	--local scroll_Left = _gt.GetUI("scroll_Left")
	local Left_Map = GUI.GetByGuid(guid)

	local MapId_Txt = HangUpUI.Config[index]['MapId']
	--_gt.BindName(MapId_Txt, "MapId_Txt"..i)
	local MapIdName = DB.GetOnceMapByKey1(MapId_Txt)  
	local MapName = MapIdName.Name
	local levelDesTxt = HangUpUI.Config[index]["LevelMin"].."级".."~"..HangUpUI.Config[index]["LevelMax"].."级"
	local MapTxtSet = GUI.GetChild(Left_Map, "MapTxtSet", false)
	local levelDes = GUI.GetChild(Left_Map, "levelDes", false)
	local RecommendMap = GUI.GetChild(Left_Map, "RecommendMap", false)

	GUI.StaticSetText(MapTxtSet, MapName)
	GUI.StaticSetText(levelDes, levelDesTxt)
	GUI.SetData(Left_Map, "index", index)
	local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
	if index == UIDefine.HangUpUI_rlIndex then
		GUI.SetVisible(RecommendMap, true)
		--UIDefine.RecommendMap_Guid = guid
	else
		GUI.SetVisible(RecommendMap, false)
	end
	
	if index == UIDefine.HangUpUI_LastID then
		GUI.ButtonSetImageID(Left_Map, "1800800040")
		--HangUpUI.LastGUID = guid
	else
		GUI.ButtonSetImageID(Left_Map, "1800800030")
	end
end

function HangUpUI.OnCreateItemFinish(key, guid, isFinsh) 
	local page = GUI.Get("HangUpUI/panelBg")
	if page == nil then
		return
	end

	if tonumber(key) ~= nil and tonumber(key) >= HangUpUI.DataPart.MaxLeftScrollItemCnt then
		local w = GUI.ScrollRectGetPreferredWidth(HangUpUI.UIPart.LeftScroller)
		local h = GUI.ScrollRectGetPreferredHeight(HangUpUI.UIPart.LeftScroller)
		GUI.SetScrollRectGridLayoutSizeX(HangUpUI.UIPart.LeftScroller, w)
		if h<=0 then
			h = HangUpUI.DataPart.MaxLeftScrollItemCnt * 75
		end
		GUI.ScrollRectSetGridLayoutSizeY(HangUpUI.UIPart.LeftScroller, h)
		test("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
		--GUI.ScrollRectSetNormalizedPosition(HangUpUI.UIPart.LeftScroller,Vector2.New(0, 1- HangUpUI.DataPart.LeftScrollItemIndex/HangUpUI.DataPart.MaxLeftScrollItemCnt))
	end
end


function HangUpUI.Left_MapClick(Guid)	
	local panelBg = _gt.GetUI("panelBg")
	local Left_Map = GUI.GetByGuid(Guid)
	for i = 1, 4 do
		local MonsterBar = _gt.GetUI("MonB"..i)
		GUI.SetVisible(MonsterBar, false)
	end
	local Map_index = GUI.GetData(Left_Map, "index")
	UIDefine.HangUpUI_LastID = tonumber(Map_index)
	local scroll_Left = _gt.GetUI("scroll_Left")
	GUI.LoopScrollRectRefreshCells(scroll_Left)	
	HangUpUI.Refresh()
end

--Vector2.New(0, 1- UIDefine.HangUpUI_LastID/#HangUpUI.Config)

--点X
function HangUpUI.OnExit()	
	if Money_table ~= nil then
	    Money_table.RemoveListen("HangUpUI")
	end
	local wnd = GUI.GetWnd("HangUpUI")
	if wnd ~= nil then
		GUI.CloseWnd("HangUpUI");


		local cardTypeBorder = _gt.GetUI("cardTypeBorder")
		GUI.SetVisible(cardTypeBorder, false)

		isAutomaticSelectStatus = false

		local automaticTypeBtn = _gt.GetUI("automaticTypeBtn")
		local arrow = GUI.GetChild(automaticTypeBtn,"arrow",false)
		GUI.SetEulerAngles(arrow,Vector3.New(180,0 , 0)) --重置旋转

	end
end


function HangUpUI.OnClickChaSkillShow(Guid)
	--UIDefine.Check_Auto_Skill = "Player"
	--GUI.OpenWnd("ChaSkill_Plugin")
	local panel = _gt.GetUI("panel")
	SkillItemUtil.CreateSelectSkillPanel(panel, "", 145, -4)
end


function HangUpUI.OnClickPetSkillShow(Guid)
	local PetGuid = tostring(GlobalUtils.GetMainLineUpPetGuid())
	test("PetGuid = "..PetGuid)
	local PetSkillShow = _gt.GetUI("PetSkillShow")
	if PetGuid == "0" then
		CL.SendNotify(NOTIFY.ShowBBMsg, "你当前没有出战宠物，无法设置自动战斗技能。")
		--GUI.ButtonSetImageID(PetSkillShow, "1800302210")
		return
	end
	local panel = _gt.GetUI("panel")
	SkillItemUtil.CreateSelectSkillPanel(panel, "", 145, -4, PetGuid)
end

--"1800700140"技能长按高亮圈

function HangUpUI.Skill_Refresh()
	HangUpUI.ChaSkill_refresh()
	local PetGuid = tostring(GlobalUtils.GetMainLineUpPetGuid())
	if PetGuid ~= "0" then
		HangUpUI.PetSkill_refresh()
	end
end


	--挂机寻路功能
--CL.StartMove(x, y, MapId)
--CL.SetMoveEndAction(MoveEndAction.LuaDefine, "HangUpUI", "startmove",""..MapId)	

function HangUpUI.OnclickHangUpBtn()		--其他都确认完了，准备出发	
	When_Click_MapId = HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['MapId']
	HangUpUI.RandomXY()
	CL.StartMove(MapId_Chosen_x1, MapId_Chosen_z1, When_Click_MapId, eRoleHeadFlag.Patrol)
	CL.SetMoveEndAction(MoveEndAction.LuaDefine, "HangUpUI", "AutoHangUp",""..When_Click_MapId)	
	HangUpUI.OnExit()
end

--随机取点
function HangUpUI.RandomXY()
	test("随机取点")

	math.randomseed(os.time()*1000+CL.GetMillisecond())
	local x1 = math.random(HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['Width']) + HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['Left']
	local z1 = CL.ChangeLogicPosZ(math.random(HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['Height']) + HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)]['Top'])

	randomNum = randomNum + 1

	if randomNum >= 10 then
		MapId_Chosen_x1 = HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)].canMovePoint.x
		MapId_Chosen_z1 = HangUpUI.Config[tonumber(UIDefine.HangUpUI_LastID)].canMovePoint.z
		return
	end

	--客户端z = CL.ChangeLogicPosZ(服务端z)
	--需要转化下 z 坐标
	--表格里的 都是 服务端z 坐标点--if not check(x1,y1) then
	MapId_Chosen_x1 = x1
	MapId_Chosen_z1 = z1

	HangUpUI.Check_RandomXY()
end

--可移动点判断
function HangUpUI.Check_RandomXY()
	test("可移动点判断")
	if CL.IsForbid(MapId_Chosen_x1, MapId_Chosen_z1) then
		HangUpUI.RandomXY()
	end
end

function HangUpUI.AutoHangUp()
	randomNum = 0
	HangUpUI.RandomXY()
	CL.StartMove(MapId_Chosen_x1, MapId_Chosen_z1, When_Click_MapId, eRoleHeadFlag.Patrol)
	CL.SetMoveEndAction(MoveEndAction.LuaDefine, "HangUpUI", "AutoHangUp",""..When_Click_MapId)
end

	--刷新自动技能图标显示
function HangUpUI.Skill_Renew()
	--CL.OnGetAutoFightSkill--返回值是技能id
	--CL.OnSetAutoFightSkill

end

function HangUpUI.Point_refresh()		--双倍点数刷新方法
	if not HangUpUI.GotPoint then
		HangUpUI.GotPoint = 0
	end
	if not HangUpUI.DoublePoint then
		HangUpUI.DoublePoint = 0
	end
	GUI.StaticSetText(_gt.GetUI("hasGotDoubleTxt"),"已领取："..HangUpUI.GotPoint)
	GUI.StaticSetText(_gt.GetUI("allDoubleTxt"),"双倍点数："..HangUpUI.DoublePoint)
end

function HangUpUI.ChaSkill_refresh()		--主角自动战斗技能刷新方法
	local Skill_Id = CL.OnGetAutoFightSkill(false)				--读取先前设置的自动战斗技能
	--test("ChaSkill_refresh   Skill_Id = "..Skill_Id)
	if Skill_Id == 0 then
		Skill_Id = 1
	end
	local Skill = DB.GetOnceSkillByKey1(Skill_Id)
	
	local ChaSkillShow = _gt.GetUI("ChaSkillShow")
	
	if Skill_Id == 1 then
		GUI.ButtonSetImageID(ChaSkillShow, "1800802060")
	elseif Skill_Id == 2 then
		GUI.ButtonSetImageID(ChaSkillShow, "1800802050")
	else
		GUI.ButtonSetImageID(ChaSkillShow, tostring(Skill.Icon)+3)
	end
end

function HangUpUI.PetSkill_refresh()		--宠物自动战斗技能刷新方法
	local PetGuid = tostring(GlobalUtils.GetMainLineUpPetGuid())
	
	local PetSkillShow = _gt.GetUI("PetSkillShow")
	
	if PetGuid == "0" then
		--CL.SendNotify(NOTIFY.ShowBBMsg, "你当前没有出战宠物，无法设置自动战斗技能。")
		GUI.ButtonSetImageID(PetSkillShow, "1800302210")
		return
	end
	local Skill_Id = LD.GetPetIntCustomAttr("__auto_c_si", PetGuid) --读取先前设置的自动战斗技能
	test("PetSkill_refresh   Skill_Id = "..Skill_Id)
	if Skill_Id == 0 then
		Skill_Id = 1
	end
	local Skill = DB.GetOnceSkillByKey1(Skill_Id)
	if Skill_Id == 1 then
		GUI.ButtonSetImageID(PetSkillShow, "1800802060")
	elseif Skill_Id == 2 then
		GUI.ButtonSetImageID(PetSkillShow, "1800802050")
	else
		GUI.ButtonSetImageID(PetSkillShow, tostring(Skill.Icon)+3)
	end
end

function HangUpUI.OnclickSaveBtn()
	CL.SendNotify(NOTIFY.SubmitForm, "FormHangUp", "FreezeDoubleExp") 
end

function HangUpUI.OnclickLoadBtn()
	CL.SendNotify(NOTIFY.SubmitForm, "FormHangUp", "DrawDoubleExp") 
end

function HangUpUI.OnclickBuyDoubleBtn()
	CL.SendNotify(NOTIFY.SubmitForm, "FormHangUp", "OneKeyBy") 
end

--获取自身等级
function HangUpUI.Role_Lv()				--点击"挂机"按钮后导到的方法
	if CL.GetIntCustomData("Assist_GoOn") == 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "正在辅助中，无法开启挂机。")
		return
	end
	local Fight = CL.GetFightState()
	if Fight then
		CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法挂机")
		HangUpUI.OnExit()
		return
	end
	
	local buffInfo = LD.GetBuffList()
	if buffInfo then
		for i = 1, buffInfo.Count do
			local buff = buffInfo[i - 1]
			if buff.buff_id == 3 then
				GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", "当前有辟妖香效果，挂机无收益，是否取消辟妖香效果？", "HangUpUI", "确定", "SureToRemoveNormalBuff", "取消", "Cancel")
				return
			end
		end
	end
	
	local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel);
	local config = HangUpUI.Config[UIDefine.HangUpUI_LastID]
	if roleLevel > config.LevelMax then
		--CL.MessageBox(MessageBoxType.NeedSure, "HangupTooWeekConfirmMsgBox", "这里的怪物对于您来说太弱了，是否前往挂机？", "HangUpUI", "OnMsgBoxTooWeekOkBtnClick", "OnMsgBoxTooWeekCancelBtnClick",MessageBoxStyle.Opposite,"确认","取消","确认前往")
		GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", "这里的怪物对于您来说太弱了，是否前往挂机？", "HangUpUI", "确定", "Sure", "取消", "Cancel")
		return;
	end
	
	if roleLevel < config.LevelMin then
		--CL.MessageBox(MessageBoxType.NeedSure, "HangupToStrongConfirmMsgBox", "这里的怪物等级对于您来说有些强，是否前往挂机？", "HangUpUI", "OnMsgBoxTooStrongOkBtnClick", "OnMsgBoxTooStrongCancelBtnClick",MessageBoxStyle.Opposite,"确认","取消","确认前往")
		GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", "这里的怪物等级对于您来说有些强，是否前往挂机？", "HangUpUI", "确定", "Sure", "取消", "Cancel")
		return;
	end
	
	if roleLevel <= config.LevelMax and config.LevelMin <= roleLevel then
		HangUpUI.OnclickHangUpBtn()
	end
end

function HangUpUI.Sure()
	HangUpUI.OnclickHangUpBtn()
	--GUI.CloseWnd("HangUpUI")
end

function HangUpUI.SureToRemoveNormalBuff()
	LD.SendStopBuff(3)
	HangUpUI.OnclickHangUpBtn()
	--GUI.CloseWnd("HangUpUI")
end

function HangUpUI.Cancel()

end

function HangUpUI.OnClickPetSkillPopup()
	CL.SendNotify(NOTIFY.ShowBBMsg, "你当前没有出战宠物，无法设置自动战斗技能。")
end

function HangUpUI.OnAutoFightCheckBoxChanged(guid)
	if CL.GetFightState() then
		CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中，无法设置自动战斗。")
		local autoFightCheckBox = GUI.GetByGuid(guid)
		GUI.CheckBoxSetCheck(autoFightCheckBox, not GUI.CheckBoxGetCheck(autoFightCheckBox))
		return
	end

	if CL.OnGetAutoFightState() then
		CL.OnAutoFightBtnClick(0);
	else
		CL.OnAutoFightBtnClick(1);
	end
end

function HangUpUI.OnModelClick(guid)
	if not HangUpUI.LastModelTB then
		return
	end
	local MonsterBar = GUI.GetByGuid(guid)
	local MonsterBar_index = GUI.GetData(MonsterBar, "MonsterBar_index")
	
	local Mon_Model = _gt.GetUI("Mon_Model"..MonsterBar_index);
	math.randomseed(os.time())
	local movements = {eRoleMovement.MAGIC_W1, eRoleMovement.PHYATT_W1}
	local index = math.random(#movements)

	ModelItem.Bind(Mon_Model, HangUpUI.LastModelTB[tonumber(MonsterBar_index)] ,nil,nil, movements[index])
end

function HangUpUI.OnAnimationCallBack(guid, action)
	if action == System.Enum.ToInt(eRoleMovement.STAND_W1) then
		return
	end
	local Mon_Model = GUI.GetByGuid(guid)
	local Mon_Model_index = GUI.GetData(Mon_Model, "Mon_Model_index")

	ModelItem.Bind(Mon_Model, HangUpUI.LastModelTB[tonumber(Mon_Model_index)] ,nil,nil, eRoleMovement.STAND_W1)
end

--设置列表
function HangUpUI.SetAutomaticCastingTableData()

	if GlobalProcessing.AutomaticCastingData ~= nil then

		if #GlobalProcessing.AutomaticCastingData > 0 then

			carTypeList = GlobalProcessing.AutomaticCastingData
			for i = 1, #carTypeList do

				if GlobalProcessing.AutomaticCasting_CurSchemeIndex == 0 then

					carTypeList[i].isSelect = false

				elseif i == GlobalProcessing.AutomaticCasting_CurSchemeIndex then

					carTypeList[i].isSelect = true

				else

					carTypeList[i].isSelect = false

				end

			end

		end

	end

	test("carTypeList",inspect(carTypeList))

end

function HangUpUI.OnAutomaticTypeBtnClick()

	test("GlobalProcessing.AutomaticCastingData",inspect(GlobalProcessing.AutomaticCastingData))

	test("GlobalProcessing.AutomaticCasting_CurSchemeIndex",GlobalProcessing.AutomaticCasting_CurSchemeIndex)

	local panelBg = _gt.GetUI("panelBg")
	local automaticTypeBtn = _gt.GetUI("automaticTypeBtn")
	local arrow = GUI.GetChild(automaticTypeBtn,"arrow",false)

	if isAutomaticSelectStatus then

		GUI.SetEulerAngles(arrow,Vector3.New(180,0 , 0)) --重置旋转
		isAutomaticSelectStatus = false

	else
		GUI.SetEulerAngles(arrow,Vector3.New(0, 0, 0)) --重置旋转
		isAutomaticSelectStatus = true
	end



	if isAutomaticSelectStatus then

		local cardTypeBorder = GUI.GetChild(panelBg,"cardTypeBorder",false)

		if cardTypeBorder == nil then

			--变身卡类型选择背景
			cardTypeBorder = GUI.ImageCreate(panelBg, "cardTypeBorder", "1800400290", 220, 20, false, 180, 15 + 50 * #carTypeList,false);
			_gt.BindName(cardTypeBorder,"cardTypeBorder")
			GUI.SetVisible(cardTypeBorder,true)
			SetSameAnchorAndPivot(cardTypeBorder, UILayout.Center)

			--滚动列表
			local carTypeScr = GUI.ScrollRectCreate(cardTypeBorder, "carTypeScr", 0, 10, 180,   50 * #carTypeList, 0, false, Vector2.New(165, 45), UIAroundPivot.Top, UIAnchor.Top, 1);
			SetSameAnchorAndPivot(carTypeScr, UILayout.Top)
			GUI.ScrollRectSetChildSpacing(carTypeScr, Vector2.New(5, 5))

			for i = 1, #carTypeList do

				local carTypeGroup = GUI.GetChild(carTypeScr,"carTypeGroup"..i,false)

				if carTypeGroup == nil then

					carTypeGroup = GUI.GroupCreate(carTypeScr,"carTypeGroup"..i,0,0,150,40,false)
					SetSameAnchorAndPivot(carTypeGroup, UILayout.Center)

					local btBg = "1801102010"

					local carTypeSelectBtn = GUI.ButtonCreate(carTypeGroup, "carTypeSelectBtn", btBg, 0, 0, Transition.ColorTint, "", 130, 40, false);
					GUI.ButtonSetTextColor(carTypeSelectBtn, UIDefine.BrownColor);
					SetSameAnchorAndPivot(carTypeSelectBtn, UILayout.Left)
					GUI.RegisterUIEvent(carTypeSelectBtn, UCE.PointerClick, "HangUpUI", "OnAutomaticBtnSelectClick")
					GUI.SetData(carTypeSelectBtn, "name", carTypeList[i].name)
					GUI.SetData(carTypeSelectBtn, "index", i)

					local selectImg = "1800607150"
					if carTypeList[i].isSelect then

						selectImg = "1800607151"

						GUI.SetData(carTypeSelectBtn,"isSelect",1)
					else

						GUI.SetData(carTypeSelectBtn,"isSelect",0)

					end

					local selectBg = GUI.ImageCreate(carTypeSelectBtn, "selectBg", selectImg, 5, 0, false, 30, 30,false)
					SetSameAnchorAndPivot(selectBg, UILayout.Left)


					local text = GUI.CreateStatic(carTypeSelectBtn, "text", carTypeList[i].name, 12, 0, 180, 35);
					GUI.StaticSetFontSize(text, 20)
					GUI.SetColor(text, UIDefine.BrownColor)
					GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
					SetSameAnchorAndPivot(text, UILayout.Center)


					local setBg = GUI.ImageCreate(carTypeGroup, "selectBg", btBg, 0, 0, false, 40, 40,false)
					SetSameAnchorAndPivot(setBg, UILayout.Right)


					local setBtn = GUI.ButtonCreate(setBg, "setBtn", "1800202240", 0, 0, Transition.ColorTint, "", 25, 25, false);
					SetSameAnchorAndPivot(setBtn, UILayout.Center)
					GUI.RegisterUIEvent(setBtn, UCE.PointerClick, "HangUpUI", "OnAutomaticBtnSetBtnClick")
					GUI.SetData(setBtn, "index", i)


				end
			end

		else


			GUI.SetVisible(cardTypeBorder,true)

			test("选择页面刷新")

			local carTypeScr = GUI.GetChild(cardTypeBorder,"carTypeScr",false)

			for i = 1, #carTypeList do

				local carTypeGroup = GUI.GetChild(carTypeScr,"carTypeGroup"..i,false)

				local carTypeSelectBtn = GUI.GetChild(carTypeGroup,"carTypeSelectBtn",false)


				local text = GUI.GetChild(carTypeSelectBtn,"text",false)
				GUI.StaticSetText(text,carTypeList[i].name)

				local selectImg = "1800607150"
				if carTypeList[i].isSelect then

					selectImg = "1800607151"

					GUI.SetData(carTypeSelectBtn,"isSelect",1)
				else

					GUI.SetData(carTypeSelectBtn,"isSelect",0)

				end

				local selectBg = GUI.GetChild(carTypeSelectBtn,"selectBg",false)

				GUI.ImageSetImageID(selectBg,selectImg)

				test("carTypeList",inspect(carTypeList))
				local text = GUI.GetChild(carTypeSelectBtn,"text",false)
				GUI.StaticSetText(text,carTypeList[i].name)

			end


		end

	else

		local cardTypeBorder = GUI.GetChild(panelBg,"cardTypeBorder",false)

		if cardTypeBorder ~= nil then

			GUI.SetVisible(cardTypeBorder,false)

		end

	end

end

function HangUpUI.OnAutomaticBtnSelectClick(guid)

	test("选择方案按钮点击事件")

	local carTypeSelectBtn = GUI.GetByGuid(guid);
	local name = GUI.GetData(carTypeSelectBtn,"name")
	local isSelect = tonumber(GUI.GetData(carTypeSelectBtn,"isSelect"))
	local index = tonumber(GUI.GetData(carTypeSelectBtn,"index"))

	local automaticTypeBtn = _gt.GetUI("automaticTypeBtn")
	local arrow = GUI.GetChild(automaticTypeBtn,"arrow",false)
	GUI.SetEulerAngles(arrow,Vector3.New(180,0 , 0)) --重置旋转

	local text = GUI.GetChild(automaticTypeBtn,"text",false)


	if isSelect == 1 then


		GUI.StaticSetText(text,"无")

		GUI.SetData(carTypeSelectBtn,"isSelect",0)

	else

		local nameLength = utf8.len(name)

		if nameLength > 1 then
			name = utf8.sub(name,1,3)..".."
		end

		GUI.StaticSetText(text,name)

		GUI.SetData(carTypeSelectBtn,"isSelect",1)

	end

	isAutomaticSelectStatus = false


	local cardTypeBorder = _gt.GetUI("cardTypeBorder")
	GUI.SetVisible(cardTypeBorder, false)


	CL.SendNotify(NOTIFY.SubmitForm, "FormAutomaticCasting", "SelectedScheme", index)


end

--设置按钮点击事件
function HangUpUI.OnAutomaticBtnSetBtnClick(guid)

	test("设置按钮点击事件")

	local setBtn = GUI.GetByGuid(guid)

	local index = tonumber(GUI.GetData(setBtn,"index"))

	local cardTypeBorder = _gt.GetUI("cardTypeBorder")
	GUI.SetVisible(cardTypeBorder, false)

	test("index",index)

	GetWay.Def[1].jump("AutomaticCastingUI", index,1)

	isAutomaticSelectStatus = false

	local automaticTypeBtn = _gt.GetUI("automaticTypeBtn")
	local arrow = GUI.GetChild(automaticTypeBtn,"arrow",false)
	GUI.SetEulerAngles(arrow,Vector3.New(180,0 , 0)) --重置旋转

end