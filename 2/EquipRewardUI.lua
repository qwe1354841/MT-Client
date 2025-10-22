EquipRewardUI={}

local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255);
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255);
local colorGreen = Color.New(25 / 255, 200 / 255, 0 / 255, 255 / 255);
local colorYellow = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255);
local colorOutline = Color.New(162 / 255.0, 75 / 225.0, 21 / 255.0, 1)

local _gt = UILayout.NewGUIDUtilTable()

function EquipRewardUI.Main(parameter)
	
	local panel = GUI.WndCreateWnd("EquipRewardUI", "EquipRewardUI", 0, 0);
	GUI.SetAnchor(panel, UIAnchor.Center);
	GUI.SetPivot(panel, UIAroundPivot.Center);
	GUI.SetIgnoreChild_OnVisible(panel, true)
	
	local panelBg=UILayout.CreateFrame_WndStyle2(panel,"",740,480, "EquipRewardUI", "OnExit");
	--panelBg:RegisterEvent(UCE.PointerClick)
	_gt.BindName(panelBg, "EquipRewardUI_panelBg")
	GUI.SetData(panelBg, "parameter", parameter)
	
	if parameter == "1" then
		local tipLabel = GUI.GetChild(panelBg, "tipLabel")
		GUI.StaticSetText(tipLabel, "宝石奖励")
		GUI.StaticSetFontSize(tipLabel, UIDefine.FontSizeXL)
		
		local bg = GUI.ImageCreate(panelBg, "bg", "1800400200", 0, -10, false, 700, 350)
	
		local currentBg = GUI.ImageCreate(panelBg, "currentBg", "1801100030", -190, -10, false, 305, 330)
		local cur_title = GUI.CreateStatic(currentBg, "cur_title", "当前等级：", 15, 6, 200, 30);
		GUI.SetColor(cur_title, colorDark);
		GUI.StaticSetFontSize(cur_title, 22);
		GUI.SetAnchor(cur_title, UIAnchor.TopLeft);
		GUI.SetPivot(cur_title, UIAroundPivot.TopLeft);
		_gt.BindName(cur_title, "cur_title")
		
		local Left_AttTxt_1 = GUI.CreateStatic(currentBg, "Left_AttTxt_1", "属性加成", 15, 60, 100, 30);
		GUI.SetColor(Left_AttTxt_1, colorYellow);
		GUI.StaticSetFontSize(Left_AttTxt_1, 24);
		GUI.SetAnchor(Left_AttTxt_1, UIAnchor.TopLeft);
		GUI.SetPivot(Left_AttTxt_1, UIAroundPivot.TopLeft);
		
		local cur_info = GUI.CreateStatic(currentBg, "cur_info", "还未激活奖励，请前往合成和镶嵌宝石", 25 ,100, 250, 100);
		GUI.SetColor(cur_info, colorDark);
		GUI.StaticSetFontSize(cur_info, 24);
		GUI.SetAnchor(cur_info, UIAnchor.TopLeft);
		GUI.SetPivot(cur_info, UIAroundPivot.TopLeft);
		_gt.BindName(cur_info, "cur_info")
		
		local cur_attrScr = GUI.ScrollRectCreate(currentBg, "cur_attrScr", 5, -5, 260, 100, 0, false, Vector2.New(200,32), UIAroundPivot.TopLeft, UIAnchor.TopLeft)
		GUI.ScrollRectSetChildSpacing(cur_attrScr,Vector2.New(0,20))
		_gt.BindName(cur_attrScr, "cur_attrScr")
		GUI.SetVisible(cur_attrScr, false)
	
		for i = 1, 2 do
			local cur_attTxt = GUI.CreateStatic(cur_attrScr, "cur_attTxt"..i, "气血加成", 0, 0)
			GUI.SetColor(cur_attTxt, colorDark);
			GUI.StaticSetFontSize(cur_attTxt, 24);
			GUI.SetAnchor(cur_attTxt, UIAnchor.Left);
			GUI.SetPivot(cur_attTxt, UIAroundPivot.Left);
			_gt.BindName(cur_attTxt, "cur_attTxt"..i)
			--local cur_value = GUI.CreateStatic(cur_attTxt, "value", "+10", 0 ,0, 100, 30);
			--GUI.SetColor(cur_value, colorGreen);
			--GUI.StaticSetFontSize(cur_value, 24);
			--GUI.SetAnchor(cur_value, UIAnchor.Right);
			--GUI.SetPivot(cur_value, UIAroundPivot.Left);
		end
		
		local Left_AttTxt_2 = GUI.CreateStatic(currentBg, "Left_AttTxt_2", "激活条件", 15, 240, 100, 30);
		GUI.SetColor(Left_AttTxt_2, colorYellow);
		GUI.StaticSetFontSize(Left_AttTxt_2, 24);
		GUI.SetAnchor(Left_AttTxt_2, UIAnchor.TopLeft);
		GUI.SetPivot(Left_AttTxt_2, UIAroundPivot.TopLeft);
		
		local cur_condition = GUI.CreateStatic(currentBg, "cur_condition", "无", 155, -40, 260, 40);
		GUI.SetColor(cur_condition, colorDark);
		GUI.StaticSetFontSize(cur_condition, 24);
		GUI.SetAnchor(cur_condition, UIAnchor.BottomLeft);
		GUI.SetPivot(cur_condition, UIAroundPivot.Center);
		GUI.StaticSetAlignment(cur_condition,TextAnchor.MiddleLeft)
		_gt.BindName(cur_condition, "cur_condition")
		
		local cur_activate = GUI.CreateStatic(currentBg, "cur_activate", "27/27", 264, -40, 80, 40);
		GUI.SetColor(cur_activate, colorGreen);
		GUI.StaticSetFontSize(cur_activate, 24);
		GUI.SetAnchor(cur_activate, UIAnchor.BottomLeft);
		GUI.SetPivot(cur_activate, UIAroundPivot.Center);
		GUI.StaticSetAlignment(cur_activate,TextAnchor.MiddleCenter)
		GUI.SetVisible(cur_activate, false)
		_gt.BindName(cur_activate, "cur_activate")
		
		GUI.ImageCreate(panelBg, "arrow", "1801107010", 0, -15);
		
		local afterBg = GUI.ImageCreate(panelBg, "afterBg", "1801100030", 190, -10, false, 305, 330)
		local next_title = GUI.CreateStatic(afterBg, "next_title", "下一个等级：", 15, 6, 200, 30);
		GUI.SetColor(next_title, colorDark);
		GUI.StaticSetFontSize(next_title, 22);
		GUI.SetAnchor(next_title, UIAnchor.TopLeft);
		GUI.SetPivot(next_title, UIAroundPivot.TopLeft);
		_gt.BindName(next_title, "next_title")
		
		local hintBtn = GUI.ButtonCreate(afterBg, "hintBtn", "1800702030", 110, 90, Transition.ColorTint,"",35,35,false);
		GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "EquipRewardUI", "OnHintBtnClick")
		
		local Right_AttTxt_1 = GUI.CreateStatic(afterBg, "Right_AttTxt_1", "属性加成", 15, 60, 100, 30);
		GUI.SetColor(Right_AttTxt_1, colorYellow);
		GUI.StaticSetFontSize(Right_AttTxt_1, 24);
		GUI.SetAnchor(Right_AttTxt_1, UIAnchor.TopLeft);
		GUI.SetPivot(Right_AttTxt_1, UIAroundPivot.TopLeft);
		
		local next_info = GUI.CreateStatic(afterBg, "next_info", "宝石奖励已达到满级", 25 ,100, 250, 100);
		GUI.SetColor(next_info, colorDark);
		GUI.StaticSetFontSize(next_info, 24);
		GUI.SetAnchor(next_info, UIAnchor.TopLeft);
		GUI.SetPivot(next_info, UIAroundPivot.TopLeft);
		GUI.SetVisible(next_info, false)
		_gt.BindName(next_info, "next_info")
		
		local next_attrScr = GUI.ScrollRectCreate(afterBg, "next_attrScr", 5, -5, 260, 100, 0, false, Vector2.New(200,32), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1);
		GUI.ScrollRectSetChildSpacing(next_attrScr,Vector2.New(0,20))
		_gt.BindName(next_attrScr, "next_attrScr")
		
		for i = 1, 2 do
			local next_attTxt = GUI.CreateStatic(next_attrScr, "next_attTxt"..i, "气血加成", 0, 0)
			GUI.SetColor(next_attTxt, colorDark);
			GUI.StaticSetFontSize(next_attTxt, 24);
			GUI.SetAnchor(next_attTxt, UIAnchor.Left);
			GUI.SetPivot(next_attTxt, UIAroundPivot.Left);
			_gt.BindName(next_attTxt, "next_attTxt"..i)
			--local value = GUI.CreateStatic("value", "+10", 0 ,0, next_attTxt, 100, 30, "system", true);
			--GUI.SetColor(value, colorGreen);
			--GUI.StaticSetFontSize(value, 24);
			--GUI.SetAnchor(value, UIAnchor.Right);
			--GUI.SetPivot(value, UIAroundPivot.Left);
		end
		
		local Right_AttTxt_2 = GUI.CreateStatic(afterBg, "Right_AttTxt_2", "激活条件", 15, 240, 100, 30);
		GUI.SetColor(Right_AttTxt_2, colorYellow);
		GUI.StaticSetFontSize(Right_AttTxt_2, 24);
		GUI.SetAnchor(Right_AttTxt_2, UIAnchor.TopLeft);
		GUI.SetPivot(Right_AttTxt_2, UIAroundPivot.TopLeft);
		
		local next_condition = GUI.CreateStatic(afterBg, "next_condition", "全身镶嵌3级宝石", 155, -40, 260, 40);
		GUI.SetColor(next_condition, colorDark);
		GUI.StaticSetFontSize(next_condition, 24);
		GUI.SetAnchor(next_condition, UIAnchor.BottomLeft);
		GUI.SetPivot(next_condition, UIAroundPivot.Center);
		GUI.StaticSetAlignment(next_condition,TextAnchor.MiddleLeft)
		_gt.BindName(next_condition, "next_condition")
		
		local next_activate = GUI.CreateStatic(afterBg, "next_activate", "0/27", 264, -40, 80, 40);
		GUI.SetColor(next_activate, colorYellow);
		GUI.StaticSetFontSize(next_activate, 24);
		GUI.SetAnchor(next_activate, UIAnchor.BottomLeft);
		GUI.SetPivot(next_activate, UIAroundPivot.Center);
		GUI.StaticSetAlignment(next_activate,TextAnchor.MiddleCenter)
		_gt.BindName(next_activate, "next_activate")
		
		local goBtn = GUI.ButtonCreate(panelBg, "goBtn", "1800402080", 0, -40, Transition.ColorTint,"去合成", 140, 50, false);
		GUI.SetAnchor(goBtn, UIAnchor.Bottom);
		GUI.SetIsOutLine(goBtn, true);
		GUI.ButtonSetTextFontSize(goBtn, 24);
		GUI.ButtonSetTextColor(goBtn, colorWhite);
		GUI.SetOutLine_Color(goBtn, colorOutline);
		GUI.SetOutLine_Distance(goBtn, 1);
		GUI.RegisterUIEvent(goBtn, UCE.PointerClick, "EquipRewardUI", "OnGoBtnClick")
	elseif parameter == "2" then
		local tipLabel = GUI.GetChild(panelBg, "tipLabel")
		GUI.StaticSetText(tipLabel, "强化奖励")
		GUI.StaticSetFontSize(tipLabel, UIDefine.FontSizeXL)
		
		local bg = GUI.ImageCreate(panelBg, "bg", "1800400200", 0, -10, false, 700, 350)
	
		local currentBg = GUI.ImageCreate(panelBg, "currentBg", "1801100030", -190, -10, false, 305, 330)
		local cur_title = GUI.CreateStatic(currentBg, "cur_title", "当前等级：", 15, 6, 200, 30);
		GUI.SetColor(cur_title, colorDark);
		GUI.StaticSetFontSize(cur_title, 22);
		GUI.SetAnchor(cur_title, UIAnchor.TopLeft);
		GUI.SetPivot(cur_title, UIAroundPivot.TopLeft);
		_gt.BindName(cur_title, "cur_title")
		
		local Left_AttTxt_1 = GUI.CreateStatic(currentBg, "Left_AttTxt_1", "属性加成", 15, 60, 100, 30);
		GUI.SetColor(Left_AttTxt_1, colorYellow);
		GUI.StaticSetFontSize(Left_AttTxt_1, 24);
		GUI.SetAnchor(Left_AttTxt_1, UIAnchor.TopLeft);
		GUI.SetPivot(Left_AttTxt_1, UIAroundPivot.TopLeft);
		
		local cur_info = GUI.CreateStatic(currentBg, "cur_info", "还未激活奖励，请前往强化", 25 ,100, 250, 100);
		GUI.SetColor(cur_info, colorDark);
		GUI.StaticSetFontSize(cur_info, 24);
		GUI.SetAnchor(cur_info, UIAnchor.TopLeft);
		GUI.SetPivot(cur_info, UIAroundPivot.TopLeft);
		_gt.BindName(cur_info, "cur_info")
		
		local cur_attrScr = GUI.ScrollRectCreate(currentBg, "cur_attrScr", 5, -5, 260, 100, 0, false, Vector2.New(200,32), UIAroundPivot.TopLeft, UIAnchor.TopLeft)
		GUI.ScrollRectSetChildSpacing(cur_attrScr,Vector2.New(0,20))
		_gt.BindName(cur_attrScr, "cur_attrScr")
		GUI.SetVisible(cur_attrScr, false)
	
		for i = 1, 2 do
			local cur_attTxt = GUI.CreateStatic(cur_attrScr, "cur_attTxt"..i, "承受伤害", 0, 0)
			GUI.SetColor(cur_attTxt, colorDark);
			GUI.StaticSetFontSize(cur_attTxt, 24);
			GUI.SetAnchor(cur_attTxt, UIAnchor.Left);
			GUI.SetPivot(cur_attTxt, UIAroundPivot.Left);
			_gt.BindName(cur_attTxt, "cur_attTxt"..i)
			--local cur_value = GUI.CreateStatic(cur_attTxt, "value", "+10", 0 ,0, 100, 30);
			--GUI.SetColor(cur_value, colorGreen);
			--GUI.StaticSetFontSize(cur_value, 24);
			--GUI.SetAnchor(cur_value, UIAnchor.Right);
			--GUI.SetPivot(cur_value, UIAroundPivot.Left);
		end
		
		local Left_AttTxt_2 = GUI.CreateStatic(currentBg, "Left_AttTxt_2", "激活条件", 15, 240, 100, 30);
		GUI.SetColor(Left_AttTxt_2, colorYellow);
		GUI.StaticSetFontSize(Left_AttTxt_2, 24);
		GUI.SetAnchor(Left_AttTxt_2, UIAnchor.TopLeft);
		GUI.SetPivot(Left_AttTxt_2, UIAroundPivot.TopLeft);
		
		local cur_condition = GUI.CreateStatic(currentBg, "cur_condition", "无", 155, -40, 260, 40);
		GUI.SetColor(cur_condition, colorDark);
		GUI.StaticSetFontSize(cur_condition, 24);
		GUI.SetAnchor(cur_condition, UIAnchor.BottomLeft);
		GUI.SetPivot(cur_condition, UIAroundPivot.Center);
		GUI.StaticSetAlignment(cur_condition,TextAnchor.MiddleLeft)
		_gt.BindName(cur_condition, "cur_condition")
		
		local cur_activate = GUI.CreateStatic(currentBg, "cur_activate", "9/9", 264, -40, 80, 40);
		GUI.SetColor(cur_activate, colorGreen);
		GUI.StaticSetFontSize(cur_activate, 24);
		GUI.SetAnchor(cur_activate, UIAnchor.BottomLeft);
		GUI.SetPivot(cur_activate, UIAroundPivot.Center);
		GUI.StaticSetAlignment(cur_activate,TextAnchor.MiddleCenter)
		GUI.SetVisible(cur_activate, false)
		_gt.BindName(cur_activate, "cur_activate")
		
		GUI.ImageCreate(panelBg, "arrow", "1801107010", 0, -15);
		
		local afterBg = GUI.ImageCreate(panelBg, "afterBg", "1801100030", 190, -10, false, 305, 330)
		local next_title = GUI.CreateStatic(afterBg, "next_title", "下一个等级：", 15, 6, 200, 30);
		GUI.SetColor(next_title, colorDark);
		GUI.StaticSetFontSize(next_title, 22);
		GUI.SetAnchor(next_title, UIAnchor.TopLeft);
		GUI.SetPivot(next_title, UIAroundPivot.TopLeft);
		_gt.BindName(next_title, "next_title")
		
		local hintBtn = GUI.ButtonCreate(afterBg, "hintBtn", "1800702030", 110, 90, Transition.ColorTint,"",35,35,false);
		GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "EquipRewardUI", "OnHintBtnClick")
		
		local Right_AttTxt_1 = GUI.CreateStatic(afterBg, "Right_AttTxt_1", "属性加成", 15, 60, 100, 30);
		GUI.SetColor(Right_AttTxt_1, colorYellow);
		GUI.StaticSetFontSize(Right_AttTxt_1, 24);
		GUI.SetAnchor(Right_AttTxt_1, UIAnchor.TopLeft);
		GUI.SetPivot(Right_AttTxt_1, UIAroundPivot.TopLeft);
		
		local next_info = GUI.CreateStatic(afterBg, "next_info", "强化奖励已达到满级", 25 ,100, 250, 100);
		GUI.SetColor(next_info, colorDark);
		GUI.StaticSetFontSize(next_info, 24);
		GUI.SetAnchor(next_info, UIAnchor.TopLeft);
		GUI.SetPivot(next_info, UIAroundPivot.TopLeft);
		GUI.SetVisible(next_info, false)
		_gt.BindName(next_info, "next_info")
		
		local next_attrScr = GUI.ScrollRectCreate(afterBg, "next_attrScr", 5, -5, 260, 100, 0, false, Vector2.New(200,32), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1);
		GUI.ScrollRectSetChildSpacing(next_attrScr,Vector2.New(0,20))
		_gt.BindName(next_attrScr, "next_attrScr")
		
		for i = 1, 2 do
			local next_attTxt = GUI.CreateStatic(next_attrScr, "next_attTxt"..i, "承受伤害", 0, 0)
			GUI.SetColor(next_attTxt, colorDark);
			GUI.StaticSetFontSize(next_attTxt, 24);
			GUI.SetAnchor(next_attTxt, UIAnchor.Left);
			GUI.SetPivot(next_attTxt, UIAroundPivot.Left);
			_gt.BindName(next_attTxt, "next_attTxt"..i)
			--local value = GUI.CreateStatic("value", "+10", 0 ,0, next_attTxt, 100, 30, "system", true);
			--GUI.SetColor(value, colorGreen);
			--GUI.StaticSetFontSize(value, 24);
			--GUI.SetAnchor(value, UIAnchor.Right);
			--GUI.SetPivot(value, UIAroundPivot.Left);
		end
		
		local Right_AttTxt_2 = GUI.CreateStatic(afterBg, "Right_AttTxt_2", "激活条件", 15, 240, 100, 30);
		GUI.SetColor(Right_AttTxt_2, colorYellow);
		GUI.StaticSetFontSize(Right_AttTxt_2, 24);
		GUI.SetAnchor(Right_AttTxt_2, UIAnchor.TopLeft);
		GUI.SetPivot(Right_AttTxt_2, UIAroundPivot.TopLeft);
		
		local next_condition = GUI.CreateStatic(afterBg, "next_condition", "强化所有装备至+4", 155, -40, 260, 40);
		GUI.SetColor(next_condition, colorDark);
		GUI.StaticSetFontSize(next_condition, 24);
		GUI.SetAnchor(next_condition, UIAnchor.BottomLeft);
		GUI.SetPivot(next_condition, UIAroundPivot.Center);
		GUI.StaticSetAlignment(next_condition,TextAnchor.MiddleLeft)
		_gt.BindName(next_condition, "next_condition")
		
		local next_activate = GUI.CreateStatic(afterBg, "next_activate", "0/9", 264, -40, 80, 40);
		GUI.SetColor(next_activate, colorYellow);
		GUI.StaticSetFontSize(next_activate, 24);
		GUI.SetAnchor(next_activate, UIAnchor.BottomLeft);
		GUI.SetPivot(next_activate, UIAroundPivot.Center);
		GUI.StaticSetAlignment(next_activate,TextAnchor.MiddleCenter)
		_gt.BindName(next_activate, "next_activate")
		
		local goBtn = GUI.ButtonCreate(panelBg, "goBtn", "1800402080", 0, -40, Transition.ColorTint,"去强化", 140, 50, false);
		GUI.SetAnchor(goBtn, UIAnchor.Bottom);
		GUI.SetIsOutLine(goBtn, true);
		GUI.ButtonSetTextFontSize(goBtn, 24);
		GUI.ButtonSetTextColor(goBtn, colorWhite);
		GUI.SetOutLine_Color(goBtn, colorOutline);
		GUI.SetOutLine_Distance(goBtn, 1);
		GUI.RegisterUIEvent(goBtn, UCE.PointerClick, "EquipRewardUI", "OnGoBtnClick")
	end
	
	
	--CL.RegisterMessage(GM.ShowWnd, "EquipRewardUI", "OnExit");
	CL.SendNotify(NOTIFY.SubmitForm, "FormAttributeEnhance", "GetData")
	
end

function EquipRewardUI.OnHintBtnClick(guid)

	local btn = GUI.GetByGuid(guid);
	local panelBg = GUI.Get("EquipRewardUI/panelBg");
	local hint = _gt.GetUI("hint")
	--local hint = GUI.GetChild(panelBg, "hint");
	if hint == nil then
		local hint = GUI.ImageCreate(panelBg, "hint", "1800400290", 90, 100, false, 370, 80)
		local msg = "奖励需要所有装备栏中都穿戴了装备（除法宝外）时才可生效哦！";
		local text = GUI.CreateStatic(hint, "text", msg, 0, 0, 340, 80);
		GUI.StaticSetFontSize(text, 22);
		GUI.SetIsRemoveWhenClick(hint, true)
		_gt.BindName(hint, "hint")
		GUI.AddWhiteName(hint, GUI.GetGuid(btn));
	else
		GUI.Destroy(hint);
	end

end

function EquipRewardUI.OnGoBtnClick(guid)
	local panelBg = _gt.GetUI("EquipRewardUI_panelBg")
	local parameter = GUI.GetData(panelBg, "parameter")
	EquipRewardUI.OnExit()
	if parameter == "1" then
		GUI.OpenWnd("EquipUI","index:2,index2:1")
		-- GUI.OpenWnd("EquipUI", string.format("index:%s,index2:%s", 2, 2));
	elseif parameter == "2" then
		GUI.OpenWnd("EquipUI", string.format("index:%s,index2:%s", 1, 3));
	end
end

function EquipRewardUI.Refresh()
	print("EquipRewardUI.Refresh")
	local panelBg = _gt.GetUI("EquipRewardUI_panelBg")
	local parameter = GUI.GetData(panelBg, "parameter")
	
	if parameter == "1" then
		local cur_title = _gt.GetUI("cur_title")
		GUI.StaticSetText(cur_title, "当前等级："..EquipRewardUI.gem_present_award_level)
		
		local next_title = _gt.GetUI("next_title")
		GUI.StaticSetText(next_title, "下一个等级："..EquipRewardUI.gem_next_award_level)
		
		local cur_attrScr = _gt.GetUI("cur_attrScr")
		local cur_activate = _gt.GetUI("cur_activate")
		local cur_condition = _gt.GetUI("cur_condition")
		local cur_info = _gt.GetUI("cur_info")
		if EquipRewardUI.gem_present_award_level == 0 then
			GUI.SetVisible(cur_info, true)
			GUI.StaticSetText(cur_condition, "无")
			GUI.SetVisible(cur_activate, false)
			GUI.SetVisible(cur_attrScr, false)
		else
			GUI.SetVisible(cur_info, false)
			GUI.StaticSetText(cur_condition, "全身镶嵌"..EquipRewardUI.gem_streng.."级宝石")
			GUI.SetVisible(cur_activate, true)
			GUI.SetVisible(cur_attrScr, true)
			local attid = DB.GetOnceTitleByKey1(EquipRewardUI.gem_present_titleid)['BuffId']
			local buff = string.split(DB.GetOnceBuffByKey1(attid)['Info'], "，")
			for i = 1, 2 do
				local cur_attTxt = _gt.GetUI("cur_attTxt"..i)
				GUI.SetVisible(cur_attTxt, true)
				GUI.StaticSetText(cur_attTxt, buff[i])
			end
		end
		
		local next_activate = _gt.GetUI("next_activate")
		GUI.StaticSetText(next_activate, EquipRewardUI.EnoughGemCount.."/27")
		
		local next_condition = _gt.GetUI("next_condition")
		local next_info = _gt.GetUI("next_info")
		local next_attrScr = _gt.GetUI("next_attrScr")
		if EquipRewardUI.gem_next_award_level == 0 then
			GUI.StaticSetText(next_condition, "无")
			GUI.SetVisible(next_activate, false)
			GUI.SetVisible(next_info, true)
			GUI.SetVisible(next_attrScr, false)
			GUI.StaticSetText(next_title, "下一个等级：无")
		else
			GUI.StaticSetText(next_condition, "全身镶嵌"..EquipRewardUI.gem_next_streng.."级宝石")
			GUI.SetVisible(next_activate, true)
			GUI.SetVisible(next_info, false)
			local attid = DB.GetOnceTitleByKey1(EquipRewardUI.gem_next_titleid)['BuffId']
			local buff = string.split(DB.GetOnceBuffByKey1(attid)['Info'], "，")
			for i = 1, 2 do
				local next_attTxt = _gt.GetUI("next_attTxt"..i)
				GUI.SetVisible(next_attTxt, true)
				GUI.StaticSetText(next_attTxt, buff[i])
			end
		end
	elseif parameter == "2" then
		local cur_title = _gt.GetUI("cur_title")
		GUI.StaticSetText(cur_title, "当前等级："..EquipRewardUI.equip_present_award_level)
		
		local next_title = _gt.GetUI("next_title")
		GUI.StaticSetText(next_title, "下一个等级："..EquipRewardUI.equip_next_award_level)
		
		local cur_attrScr = _gt.GetUI("cur_attrScr")
		local cur_activate = _gt.GetUI("cur_activate")
		local cur_condition = _gt.GetUI("cur_condition")
		local cur_info = _gt.GetUI("cur_info")
		if EquipRewardUI.equip_present_award_level == 0 then
			GUI.SetVisible(cur_info, true)
			GUI.StaticSetText(cur_condition, "无")
			GUI.SetVisible(cur_activate, false)
			GUI.SetVisible(cur_attrScr, false)
		else
			GUI.SetVisible(cur_info, false)
			GUI.StaticSetText(cur_condition, "强化所有装备至+"..EquipRewardUI.equip_streng)
			GUI.SetVisible(cur_activate, true)
			GUI.SetVisible(cur_attrScr, true)
			local attid = DB.GetOnceTitleByKey1(EquipRewardUI.equip_present_titleid)['BuffId']
			local buff = string.split(DB.GetOnceBuffByKey1(attid)['Info'], "，")
			for i = 1, 2 do
				local cur_attTxt = _gt.GetUI("cur_attTxt"..i)
				GUI.SetVisible(cur_attTxt, true)
				GUI.StaticSetText(cur_attTxt, buff[i])
			end
		end
		
		local next_activate = _gt.GetUI("next_activate")
		GUI.StaticSetText(next_activate, EquipRewardUI.EnoughEquipCount.."/9")
		
		local next_condition = _gt.GetUI("next_condition")
		local next_info = _gt.GetUI("next_info")
		local next_attrScr = _gt.GetUI("next_attrScr")
		if EquipRewardUI.equip_next_award_level == 0 then
			GUI.StaticSetText(next_condition, "无")
			GUI.SetVisible(next_activate, false)
			GUI.SetVisible(next_info, true)
			GUI.SetVisible(next_attrScr, false)
			GUI.StaticSetText(next_title, "下一个等级：无")
		else
			GUI.StaticSetText(next_condition, "强化所有装备至+"..EquipRewardUI.equip_next_streng)
			GUI.SetVisible(next_activate, true)
			GUI.SetVisible(next_info, false)
			local attid = DB.GetOnceTitleByKey1(EquipRewardUI.equip_next_titleid)['BuffId']
			local buff = string.split(DB.GetOnceBuffByKey1(attid)['Info'], "，")
			for i = 1, 2 do
				local next_attTxt = _gt.GetUI("next_attTxt"..i)
				GUI.SetVisible(next_attTxt, true)
				GUI.StaticSetText(next_attTxt, buff[i])
			end
		end
	end
end

--function EquipRewardUI.OnShow(scriptname, parameter)
--	print("EquipRewardUI.OnShow")
--	local wnd = GUI.GetWnd("EquipRewardUI")
--	if  wnd== nil or scriptname ~= "EquipRewardUI" then
--		return ;
--	end
--
--	GUI.SetVisible(wnd,true);
--
--	local panelBg = GUI.Get("EquipRewardUI/panelBg");
--	local title = GUI.GetChild(panelBg,"tipLabel");
--	local goBtn = GUI.GetChild(panelBg,"goBtn");
--	
--	local currentRewardLevel =0;
--	local nextRewardLevel=0;
--	local currentConditionLevel=0;
--	local nextConditionLevel =0;
--	local currentConditionInfo ="";
--	local nextConditionInfo =""
--	local currentTitleId =0;
--	local nextTitleId =0;
--	
--	if parameter==nil or tonumber(parameter)==1 then
--		GUI.SetLabelText(title,"宝石奖励");
--		GUI.SetButtonText(goBtn,"去合成");
--		GUI.SetData(goBtn,"Index",1);
--		currentRewardLevel =BagUI.gem_present_award_level;
--		nextRewardLevel = BagUI.gem_next_award_level;
--		currentConditionLevel=BagUI.gem_streng;
--		nextConditionLevel= BagUI.gem_next_streng;
--		if currentConditionLevel==0 then
--			currentConditionInfo ="无";
--		else
--			currentConditionInfo ="全身镶嵌"..currentConditionLevel.."级宝石";
--		end
--
--		if nextConditionLevel==0 then
--			nextConditionInfo="无";
--		else
--			nextConditionInfo ="全身镶嵌"..nextConditionLevel.."级宝石";
--		end
--
--		currentTitleId=BagUI.gem_present_titleid;
--		nextTitleId = BagUI.gem_next_titleid;
--	elseif tonumber(parameter)==2 then
--		GUI.SetLabelText(title,"强化奖励")
--		GUI.SetButtonText(goBtn,"去强化");
--		GUI.SetData(goBtn,"Index",2);
--		currentRewardLevel =BagUI.equip_present_award_level;
--		nextRewardLevel = BagUI.equip_next_award_level;
--		currentConditionLevel=BagUI.equip_streng;
--		nextConditionLevel= BagUI.equip_next_streng;
--		if currentConditionLevel==0 then
--			currentConditionInfo="无";
--		else
--			currentConditionInfo ="强化所有装备至+"..currentConditionLevel
--		end
--
--		if nextConditionLevel==0 then
--			nextConditionInfo="无";
--		else
--			nextConditionInfo ="强化所有装备至+"..nextConditionLevel;
--		end
--		currentTitleId=BagUI.equip_present_titleid;
--		nextTitleId = BagUI.equip_next_titleid;
--	end
--
--
--  --当前
--  local currentBg = GUI.GetChild(panelBg,"currentBg");
--  local title= GUI.GetChild(currentBg,"title");
--  GUI.SetLabelText(title,"当前等级："..currentRewardLevel);
--
--  local condition= GUI.GetChild(currentBg,"condition");
--  GUI.SetLabelText(condition,currentConditionInfo);
--
--  local info = GUI.GetChild(currentBg,"info");
--  local attrScr = GUI.GetChild(currentBg,"attrScr");
--
--
--  local activate= GUI.GetChild(currentBg,"activate");
--  if currentConditionLevel==0 then
--    GUI.SetVisible(activate,false);
--    GUI.SetVisible(attrScr,false);
--    GUI.SetVisible(info,true);
--
--    if parameter==nil or tonumber(parameter)==1 then
--      GUI.SetLabelText(info,"还未激活奖励，请前往合成和镶嵌宝石");
--    elseif tonumber(parameter)==2 then
--      GUI.SetLabelText(info,"还未激活奖励，请前往强化");
--    end
--
--  else
--    GUI.SetVisible(activate,true);
--    GUI.SetVisible(attrScr,true);
--    GUI.SetVisible(info,false);
--
--    local attText1 = GUI.GetChild(attrScr,"attText1");
--    local attText2 = GUI.GetChild(attrScr,"attText2");
--
--   local titleData =DB.Get_title(currentTitleId);
--    if titleData~=nil then
--      local infos = string.split(titleData.Info,"，");
--
--      GUI.SetLabelText(attText1, infos[1]);
--      GUI.SetLabelText(attText2,infos[2]);
--    end
--
--    local amount =0;
--    local count=0;
--    if parameter==nil or tonumber(parameter)==1 then
--      local guids= LD.GetAllItemGuidByType(container_type.container_type_equip)
--      if guids~=nil then
--        for i = 0, guids.Count-1 do
--          local guid = guids[i];
--          if tostring(guid)~="0" then
--            amount = amount+ tonumber(LD.GetItemAttrByGuid(item_attr.item_equip_drillnum, guid));
--            local gemSlot = LD.GetItemAttrByGuid(item_attr.item_equip_gemslot, guid);
--            local gemSlotList = string.split(gemSlot, ",");
--
--
--            for j = 1, #gemSlotList do
--              local gemId = tonumber(gemSlotList[j]);
--              local itemMaterialData = DB.Get_item_material(gemId);
--              if itemMaterialData~=nil then
--                if itemMaterialData.SubType>=currentConditionLevel then
--                  count =count+1;
--                end
--              end
--            end
--
--          end
--        end
--      end
--    elseif tonumber(parameter)==2 then
--      amount =9;
--      local guids= LD.GetAllItemGuidByType(container_type.container_type_equip)
--      if guids~=nil then
--        for i = 0, guids.Count-1 do
--          local guid = guids[i];
--          if tostring(guid)~="0" then
--            local enhanceLevel = tonumber(LD.GetItemAttrByGuid(item_attr.item_equip_enhance, guid));
--            if enhanceLevel>=currentConditionLevel then
--              count =count+1;
--            end
--          end
--        end
--      end
--
--    end
--    GUI.SetLabelText(activate, count.."/"..amount);
--  end
--
--
--  --下一级
--  local afterBg = GUI.GetChild(panelBg,"afterBg");
--  local title= GUI.GetChild(afterBg,"title");
--  if nextRewardLevel==0 then
--    GUI.SetLabelText(title,"下一个等级：无");
--  else
--    GUI.SetLabelText(title,"下一个等级："..nextRewardLevel);
--  end
--
--
--  local condition= GUI.GetChild(afterBg,"condition");
--  GUI.SetLabelText(condition,nextConditionInfo);
--
--  local info = GUI.GetChild(afterBg,"info");
--  local attrScr = GUI.GetChild(afterBg,"attrScr");
--
--
--  local activate= GUI.GetChild(afterBg,"activate");
--  if nextConditionLevel==0 then
--    GUI.SetVisible(activate,false);
--    GUI.SetVisible(attrScr,false);
--    GUI.SetVisible(info,true);
--
--    if parameter==nil or tonumber(parameter)==1 then
--      GUI.SetLabelText(info,"宝石奖励已达到满级");
--    elseif tonumber(parameter)==2 then
--      GUI.SetLabelText(info,"强化奖励已达到满级");
--    end
--  else
--    GUI.SetVisible(activate,true);
--    GUI.SetVisible(attrScr,true);
--    GUI.SetVisible(info,false);
--
--    local attText1 = GUI.GetChild(attrScr,"attText1");
--    local attText2 = GUI.GetChild(attrScr,"attText2");
--
--    local titleData =DB.Get_title(nextTitleId);
--    if titleData~=nil then
--      local infos = string.split(titleData.Info,"，");
--
--      GUI.SetLabelText(attText1, infos[1]);
--      GUI.SetLabelText(attText2,infos[2]);
--
--    end
--
--    local amount =0;
--    local count=0;
--    if parameter==nil or tonumber(parameter)==1 then
--      local guids= LD.GetAllItemGuidByType(container_type.container_type_equip)
--      if guids~=nil then
--        for i = 0, guids.Count-1 do
--          local guid = guids[i];
--          if tostring(guid)~="0" then
--            amount = amount+ tonumber(LD.GetItemAttrByGuid(item_attr.item_equip_drillnum, guid));
--            local gemSlot = LD.GetItemAttrByGuid(item_attr.item_equip_gemslot, guid)
--            local gemSlotList = string.split(gemSlot, ",");
--
--            for j = 1, #gemSlotList do
--              local gemId = tonumber(gemSlotList[j]);
--              local itemMaterialData = DB.Get_item_material(gemId);
--              if itemMaterialData~=nil then
--                if itemMaterialData.SubType>=nextConditionLevel then
--                  count =count+1;
--                end
--              end
--            end
--
--          end
--        end
--      end
--    elseif tonumber(parameter)==2 then
--      amount = 9;
--      local guids= LD.GetAllItemGuidByType(container_type.container_type_equip)
--      if guids~=nil then
--        for i = 0, guids.Count-1 do
--          local guid = guids[i];
--
--          if tostring(guid)~="0" then
--            local enhanceLevel = tonumber(LD.GetItemAttrByGuid(item_attr.item_equip_enhance, guid));
--            if enhanceLevel>=nextConditionLevel then
--              count =count+1;
--            end
--          end
--        end
--      end
--    end
--    GUI.SetLabelText(activate, count.."/"..amount);
--  end
--end

function EquipRewardUI.OnShow(scriptname, parameter)
	
end

function EquipRewardUI.OnExit()
    GUI.DestroyWnd("EquipRewardUI");
end