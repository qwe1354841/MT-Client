PetFragmentConvert = {}

_gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local QualityRes = 
{
  "1800400330","1800400100","1800400110","1800400120","1800400320"
}

local Txtcolor = Color.New(96/255,48/255,13/255,255/255)   -- 字体颜色

function PetFragmentConvert.Main()
	PetFragmentConvert.GoodsNumber = 1
	local panel = GUI.WndCreateWnd("PetFragmentConvert", "PetFragmentConvert", 0, 0, eCanvasGroup.Normal)
	_gt.BindName(panel, "PetFragmentConvert")
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
	
	-- CL.RegisterMessage(GM.ShowWnd,"PetFragmentConvert" , "OnOpenWndCallBack");
	

    local panelCover = GUI.ImageCreate( panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)

    -- 底图
    local panelBg = GUI.ImageCreate( panel, "panelBg", "1800600182", 0, 0, false,530, 350)
    SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)

    local rightBg = GUI.ImageCreate( panelBg, "RightBg", "1800600181", 0, -9.5, false, 225, 40)
    SetAnchorAndPivot(rightBg, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local leftBg = GUI.ImageCreate( panelBg, "LeftBg", "1800600180", 0, -9.5, false, 225, 40)
    SetAnchorAndPivot(leftBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	
    -- 标题底板
    local titleBg = GUI.ImageCreate( panelBg, "TitleBg", "1800600190", 0, -10, false, 230, 50)
    SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Top)

    -- 标题
    local titleTxt = GUI.CreateStatic( titleBg, "TitleText", "神兽拼图兑换", 25, 0, 200, 35)
    SetAnchorAndPivot(titleTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(titleTxt, 26)
    GUI.SetColor(titleTxt, Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255))
	
	local arrowsImg = GUI.ImageCreate(panelBg, "arrowsImg","1800607290",0,-8,false,60,40);
	SetAnchorAndPivot(arrowsImg, UIAnchor.Center, UIAroundPivot.Center)
	
    -- 关闭
    local closeBtn = GUI.ButtonCreate( panelBg, "ClosePanelBtn", "1800302120", 0, -6, Transition.ColorTint)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "PetFragmentConvert", "OnClosePanel")
	
	PetFragmentConvert.OnOpenWndCallBack("PetFragmentConvert")
end

function PetFragmentConvert.OnShow()
	-- local wnd = GUI.GetWnd("PetFragmentConvert")
	-- if wnd then
		-- GUI.SetVisible(wnd,true);
		-- PetFragmentConvert.Refresh()
	-- end
end


--神兽碎片列表
function PetFragmentConvert.Refresh()
	if not PetFragmentConvert.Pet_Fragment_player then 
		return
	end
	if not PetFragmentConvert.Pet_Fragment_system then
		return
	end
	Pet_Fragment_player = PetFragmentConvert.Pet_Fragment_player
	Pet_Fragment_system = PetFragmentConvert.Pet_Fragment_system
	local panelBg = GUI.Get("PetFragmentConvert/panelBg")
	local panel = GUI.GetWnd("PetFragmentConvert")
	--选择玩家的宠物碎片
	if PetFragmentConvert.system_index then 
		PetFragmentConvert.system_index = nil
	end
	if PetFragmentConvert.player_index then 
		PetFragmentConvert.player_index = nil
	end
	if PetFragmentConvert.Item_num then 
		PetFragmentConvert.Item_num = 0
	end
	local left_bg = GUI.GroupCreate( panelBg, "left_bg", -120, -8, 265, 350, false)
    SetAnchorAndPivot(left_bg, UIAnchor.Center, UIAroundPivot.Center)
	
	local right_bg = GUI.GroupCreate( panelBg, "right_bg", 120, -8, 265, 350, false)
    SetAnchorAndPivot(right_bg, UIAnchor.Center, UIAroundPivot.Center)
	
	local btnBuy =GUI.ButtonCreate(right_bg,  "btnBuy", "1800102090",4,134, Transition.ColorTint, "兑换"); -- 兑换按钮
	SetAnchorAndPivot(btnBuy, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetScale(btnBuy, Vector3.New(0.8,0.8,0.8))
	GUI.RegisterUIEvent( btnBuy, UCE.PointerClick , "PetFragmentConvert", "On_btnBuy_Click" )
	
	GUI.SetIsOutLine(btnBuy,true);
	GUI.ButtonSetTextFontSize(btnBuy,32);
	GUI.ButtonSetTextColor(btnBuy,Color.New(1,1,1,1));
	GUI.SetOutLine_Color(btnBuy,Color.New(182/255,92/255,30/255,255/255));
	GUI.SetOutLine_Distance(btnBuy,1);
	
	local btnCancel =GUI.ButtonCreate(left_bg,  "btnCancel", "1800102090",0,134, Transition.ColorTint, "取消"); --取消按钮
	SetAnchorAndPivot(btnCancel, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetScale(btnCancel, Vector3.New(0.8,0.8,0.8))
	GUI.RegisterUIEvent( btnCancel, UCE.PointerClick , "PetFragmentConvert", "OnClosePanel" )
	
	GUI.SetIsOutLine(btnCancel,true);
	GUI.ButtonSetTextFontSize(btnCancel,32);
	GUI.ButtonSetTextColor(btnCancel,Color.New(1,1,1,1));
	GUI.SetOutLine_Color(btnCancel,Color.New(182/255,92/255,30/255,255/255));
	GUI.SetOutLine_Distance(btnCancel,1);
	
	--左侧宠物头像框
	local player_headIcon = GUI.ItemCtrlCreate( left_bg, "player_headIcon", "1801100120", 0, 0, 86, 86, false)
	SetAnchorAndPivot(player_headIcon, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(player_headIcon , UCE.PointerClick , "PetFragmentConvert", "on_itembg_click" )
	
	--右侧宠物头像框
	local system_headIcon = GUI.ItemCtrlCreate( right_bg, "system_headIcon", "1801100120", 0, 0, 86, 86, false)
	SetAnchorAndPivot(system_headIcon, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(system_headIcon , UCE.PointerClick , "PetFragmentConvert", "on_itembg_click" )
	
	--"拥有"富文本框
	PetFragmentConvert['txtCurSpend'] = GUI.RichEditCreate( left_bg,  "txtCurSpend","拥有  0/0",0,77,200,30);
	GUI.StaticSetFontSize(PetFragmentConvert['txtCurSpend'],24)
	GUI.StaticSetAlignment(PetFragmentConvert['txtCurSpend'],TextAnchor.MiddleCenter)
	SetAnchorAndPivot(PetFragmentConvert['txtCurSpend'], UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(PetFragmentConvert['txtCurSpend'],Txtcolor);

	
	local btnNumbersSub =GUI.ButtonCreate(right_bg,  "btnNumbersSub", "1800402140",-88,77, Transition.ColorTint); --减法按钮
	SetAnchorAndPivot(btnNumbersSub, UIAnchor.Center, UIAroundPivot.Center)
	btnNumbersSub:RegisterEvent(UCE.PointerDown )
	btnNumbersSub:RegisterEvent(UCE.PointerUp )
	GUI.RegisterUIEvent( btnNumbersSub, UCE.PointerDown , "PetFragmentConvert", "On_NumberSub" )
	GUI.RegisterUIEvent( btnNumbersSub, UCE.PointerUp, "PetFragmentConvert", "NumberChangingOver" )
	GUI.ButtonSetShowDisable(btnNumbersSub,false)
	
	
	local btnNumbersAdd =GUI.ButtonCreate(right_bg,  "btnNumbersAdd", "1800402150",92,77, Transition.ColorTint); -- 加法按钮
	SetAnchorAndPivot(btnNumbersAdd, UIAnchor.Center, UIAroundPivot.Center)
	btnNumbersAdd:RegisterEvent(UCE.PointerDown )
	btnNumbersAdd:RegisterEvent(UCE.PointerUp )
	GUI.RegisterUIEvent( btnNumbersAdd, UCE.PointerDown, "PetFragmentConvert", "On_NumberAdd" )
	GUI.RegisterUIEvent( btnNumbersAdd, UCE.PointerUp, "PetFragmentConvert", "NumberChangingOver" )
	GUI.ButtonSetShowDisable(btnNumbersAdd,false)
	
	PetFragmentConvert['InputBox'] = GUI.EditCreate( right_bg, "InputBox", "1800400390", "1", 2, 77, Transition.ColorTint, "system", 0, 0, 8, 8, InputType.Standard, ContentType.IntegerNumber) -- 编辑框按钮
	SetAnchorAndPivot(PetFragmentConvert['InputBox'], UIAnchor.Center, UIAroundPivot.Center)
    GUI.EditSetLabelAlignment(PetFragmentConvert['InputBox'], TextAnchor.MiddleCenter)
    GUI.EditSetTextColor(PetFragmentConvert['InputBox'], Txtcolor)
    GUI.EditSetFontSize(PetFragmentConvert['InputBox'], 22)
    GUI.EditSetMaxCharNum(PetFragmentConvert['InputBox'], 4)
    GUI.EditSetTextM(PetFragmentConvert['InputBox'], 1)
    GUI.RegisterUIEvent(PetFragmentConvert['InputBox'], UCE.EndEdit, "PetFragmentConvert", "OnNumCountChange")
	
	-- 左边的下拉框
	local player_leftBtn=GUI.ButtonCreate(left_bg, "player_leftBtn","1800702040",0,-90,Transition.ColorTint,"",180,40,false);
	SetAnchorAndPivot(player_leftBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(player_leftBtn,UCE.PointerClick,"PetFragmentConvert","OnPullListBtnClick")
	
	local text = GUI.CreateStatic( player_leftBtn, "text", "选择神兽拼图", -12, 0, 180, 40, "system", true)
	GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
	SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(text, Txtcolor)
	GUI.StaticSetFontSize(text, 18)
	
	local pullListBtn = GUI.ImageCreate(player_leftBtn, "pullListBtn","1800707070",-10,0);
	SetAnchorAndPivot(pullListBtn, UIAnchor.Right, UIAroundPivot.Right)
	GUI.SetIsRaycastTarget(pullListBtn,false);
	
	
	--选择要兑换的宠物碎片
	-- 右边的下拉框
	local system_rightBtn = GUI.ButtonCreate( right_bg, "system_rightBtn", "1800702040", 0, -90, Transition.ColorTint,"",180,40,false)
	SetAnchorAndPivot(system_rightBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ButtonSetTextFontSize(system_rightBtn,18)
	GUI.RegisterUIEvent(system_rightBtn, UCE.PointerClick, "PetFragmentConvert", "system_OnGuardTypeBtnClick")
	
	local system_text = GUI.CreateStatic( system_rightBtn, "system_text", "选择神兽拼图", -12, 0, 180, 40, "system", true)
	GUI.StaticSetAlignment(system_text, TextAnchor.MiddleCenter)
	SetAnchorAndPivot(system_text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(system_text, Txtcolor)
	GUI.StaticSetFontSize(system_text, 18)
	
	local system_pullListBtn = GUI.ImageCreate(system_rightBtn, "system_pullListBtn","1800707070",-10,0);
	SetAnchorAndPivot(system_pullListBtn, UIAnchor.Right, UIAroundPivot.Right)
	GUI.SetIsRaycastTarget(system_pullListBtn,false);
	
	PetFragmentConvert.OnPullListBtnClick(1)
	PetFragmentConvert.system_OnGuardTypeBtnClick(1)
end

-- 选项背景被点击
function PetFragmentConvert.OnRefineItemsCoverClick(key)
  local refineItemsCover = GUI.Get("PetFragmentConvert/panelBg/refineItemsCover")
  local scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/scr_GuardType_Bg")
  GUI.SetVisible(scr_GuardType_Bg,false);
  GUI.SetVisible(refineItemsCover, false)
end

function PetFragmentConvert.system_OnRefineItemsCoverClick(key)
  local system_refineItemsCover = GUI.Get("PetFragmentConvert/panelBg/system_refineItemsCover")
  local system_scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/system_scr_GuardType_Bg")
  GUI.SetVisible(system_scr_GuardType_Bg,false);
  GUI.SetVisible(system_refineItemsCover, false)
end

--点击碎片按钮显示隐藏
function PetFragmentConvert.OnPullListBtnClick(key) 
	local panelBg = GUI.Get("PetFragmentConvert/panelBg")
	local refineItemsCover = GUI.Get("PetFragmentConvert/panelBg/refineItemsCover")
	local scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/scr_GuardType_Bg")
	local panel = GUI.GetWnd("PetFragmentConvert")
	if not refineItemsCover then 
		refineItemsCover = GUI.ImageCreate( panelBg, "refineItemsCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
		SetAnchorAndPivot(refineItemsCover, UIAnchor.Center, UIAroundPivot.Center)
		refineItemsCover:RegisterEvent(UCE.PointerClick)
		GUI.SetIsRaycastTarget(refineItemsCover, true)
		GUI.RegisterUIEvent(refineItemsCover, UCE.PointerClick, "PetFragmentConvert", "OnRefineItemsCoverClick")
		GUI.SetGroupAlpha(refineItemsCover,0)
		
		--创建神兽碎片按钮选择列表
		scr_GuardType_Bg=GUI.ImageCreate(panelBg, "scr_GuardType_Bg","1800400290",-119,92,false,180,#Pet_Fragment_player * 38 + 10);
		SetAnchorAndPivot(scr_GuardType_Bg, UIAnchor.Top, UIAroundPivot.Top)
		
		local childSize_GuardType=Vector2.New(172,38)
		local scr_GuardType=GUI.ScrollRectCreate(scr_GuardType_Bg, "scr_GuardType",0,0,180,#Pet_Fragment_player * 38,0,false,childSize_GuardType,UIAroundPivot.Top,UIAnchor.Top);
		SetAnchorAndPivot(scr_GuardType, UIAnchor.Center, UIAroundPivot.Center)
		for k,v in ipairs(Pet_Fragment_player) do
			local itemsID = (DB.GetOnceItemByKey2(Pet_Fragment_player[k]["keyname"])).Id
			if itemsID ~= 0 then 
				local item = DB.GetOnceItemByKey2(Pet_Fragment_player[k]["keyname"])
				if item then 
					local btn=GUI.ButtonCreate(scr_GuardType, "player_"..k,"1800600100",0,0,Transition.ColorTint,item.Name,172,40,false);
					GUI.ButtonSetTextFontSize(btn,18)
					GUI.ButtonSetTextColor(btn,Txtcolor); 
					GUI.RegisterUIEvent(btn,UCE.PointerClick,"PetFragmentConvert","player_OnBtnClick")
					if item.Name == "百变神兽拼图" then
						PetFragmentConvert.FirstEnterKey = GUI.GetGuid(btn)
					end
				end
			end
		end
	else
		GUI.SetVisible(refineItemsCover,true);
		GUI.SetVisible(scr_GuardType_Bg,true);
	end
	if key == 1 then 
		GUI.SetVisible(refineItemsCover,false);
		GUI.SetVisible(scr_GuardType_Bg,false);
	end
	
	if PetFragmentConvert.FirstEnterKey then
		PetFragmentConvert.player_OnBtnClick(PetFragmentConvert.FirstEnterKey)
		PetFragmentConvert.FirstEnterKey = nil
	end
end

function PetFragmentConvert.system_OnGuardTypeBtnClick(key) 
	local panelBg = GUI.Get("PetFragmentConvert/panelBg")
	local system_refineItemsCover = GUI.Get("PetFragmentConvert/panelBg/system_refineItemsCover")
	local system_scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/system_scr_GuardType_Bg")
	local panel = GUI.GetWnd("PetFragmentConvert")
	if not system_refineItemsCover then 
		system_refineItemsCover = GUI.ImageCreate( panelBg, "system_refineItemsCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
		SetAnchorAndPivot(system_refineItemsCover, UIAnchor.Center, UIAroundPivot.Center)
		system_refineItemsCover:RegisterEvent(UCE.PointerClick)
		GUI.SetIsRaycastTarget(system_refineItemsCover, true)
		GUI.RegisterUIEvent(system_refineItemsCover, UCE.PointerClick, "PetFragmentConvert", "system_OnRefineItemsCoverClick")
		GUI.SetGroupAlpha(system_refineItemsCover,0)
		--创建神兽碎片按钮选择列表
		system_scr_GuardType_Bg=GUI.ImageCreate(panelBg, "system_scr_GuardType_Bg","1800400290",120,93,false,180,#Pet_Fragment_system * 38 + 10);
		SetAnchorAndPivot(system_scr_GuardType_Bg, UIAnchor.Top, UIAroundPivot.Top)
		local system_childSize_GuardType = Vector2.New(172,38)
		local system_scr_GuardType=GUI.ScrollRectCreate(system_scr_GuardType_Bg, "system_scr_GuardType",0,0,180,#Pet_Fragment_system * 38,0,false,system_childSize_GuardType,UIAroundPivot.Top,UIAnchor.Top);
		SetAnchorAndPivot(system_scr_GuardType, UIAnchor.Center, UIAroundPivot.Center)
		for k,v in ipairs(Pet_Fragment_system) do
			local itemsID = (DB.GetOnceItemByKey2(Pet_Fragment_system[k]["keyname"])).Id
			if itemsID ~= 0 then 
				local item = DB.GetOnceItemByKey2(Pet_Fragment_system[k]["keyname"])
				if item then 
					local btn=GUI.ButtonCreate(system_scr_GuardType, "system_"..k,"1800600100",0,0,Transition.ColorTint,item.Name,172,40,false);
					GUI.ButtonSetTextFontSize(btn,18)
					GUI.ButtonSetTextColor(btn,Txtcolor);
					GUI.RegisterUIEvent(btn,UCE.PointerClick,"PetFragmentConvert","system_OnBtnClick")
				end
			end
		end
	else
		GUI.SetVisible(system_refineItemsCover,true);
		GUI.SetVisible(system_scr_GuardType_Bg,true);
	end
	if key == 1 then 
		GUI.SetVisible(system_refineItemsCover,false);
		GUI.SetVisible(system_scr_GuardType_Bg,false);
	end
end

function PetFragmentConvert.player_OnBtnClick(key)
	--玩家自身神兽碎片Icon
	local player_headIcon = GUI.Get("PetFragmentConvert/panelBg/left_bg/player_headIcon")
	local refineItemsCover = GUI.Get("PetFragmentConvert/panelBg/refineItemsCover")
	local scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/scr_GuardType_Bg")
	local player_leftBtn = GUI.Get("PetFragmentConvert/panelBg/left_bg/player_leftBtn/text")
	local system_scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/system_scr_GuardType_Bg")
	local system_scr_GuardType = GUI.Get("PetFragmentConvert/panelBg/system_scr_GuardType_Bg/system_scr_GuardType")
	local key_1 = string.split(GUI.GetName(GUI.GetByGuid(key)),"_")
	if not key_1[2] then
		return
	end
	PetFragmentConvert.player_index = tonumber(key_1[2])
	PetFragmentConvert.GoodsNumber = 1
	GUI.EditSetTextM(PetFragmentConvert['InputBox'],PetFragmentConvert.GoodsNumber)
	
	local mark = 0
	for k,v in ipairs(Pet_Fragment_system) do
		local Btn = GUI.Get("PetFragmentConvert/panelBg/system_scr_GuardType_Bg/system_scr_GuardType/system_"..k)
		if Pet_Fragment_player[PetFragmentConvert.player_index].keyname == v.keyname then
			GUI.SetVisible(Btn,false);
			GUI.SetHeight(system_scr_GuardType_Bg,(#Pet_Fragment_system-1) * 38 + 10)
			GUI.SetHeight(system_scr_GuardType,(#Pet_Fragment_system-1) * 40)
			GUI.SetPositionY(system_scr_GuardType,#Pet_Fragment_system-1)
			--GUI.ButtonSetShowDisable(Btn,false)
			mark = 1 
		else
			GUI.SetVisible(Btn,true);
			--GUI.ButtonSetShowDisable(Btn,true)
		end
	end
	if mark == 0 then
		GUI.SetHeight(system_scr_GuardType_Bg,#Pet_Fragment_system * 38 + 10)
		GUI.SetHeight(system_scr_GuardType,#Pet_Fragment_system * 40)
		GUI.SetPositionY(system_scr_GuardType,#Pet_Fragment_system)
	end
	
	if not PetFragmentConvert.Item_num then 
		PetFragmentConvert.Item_num = 0
	end
	PetFragmentConvert.txtCurSpend_color(PetFragmentConvert.Item_num,0)
	PetFragmentConvert.item_Icon(key,player_headIcon,refineItemsCover,scr_GuardType_Bg,player_leftBtn,1)
end

function PetFragmentConvert.system_OnBtnClick(key)
	--玩家所需神兽碎片Icon
	local system_headIcon = GUI.Get("PetFragmentConvert/panelBg/right_bg/system_headIcon")
	local system_refineItemsCover = GUI.Get("PetFragmentConvert/panelBg/system_refineItemsCover")
	local system_scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/system_scr_GuardType_Bg")
	local system_rightBtn = GUI.Get("PetFragmentConvert/panelBg/right_bg/system_rightBtn/system_text")
	local scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/scr_GuardType_Bg")
	local scr_GuardType = GUI.Get("PetFragmentConvert/panelBg/scr_GuardType_Bg/scr_GuardType")
	local key_1 = string.split(GUI.GetName(GUI.GetByGuid(key)),"_")
	if not key_1[2] then
		return
	end
	PetFragmentConvert.system_index = tonumber(key_1[2])
	PetFragmentConvert.GoodsNumber = 1
	GUI.EditSetTextM(PetFragmentConvert['InputBox'],PetFragmentConvert.GoodsNumber)
	
	for k,v in ipairs(Pet_Fragment_player) do
		local Btn = GUI.Get("PetFragmentConvert/panelBg/scr_GuardType_Bg/scr_GuardType/player_"..k)
		if Pet_Fragment_system[PetFragmentConvert.system_index].keyname == v.keyname then
			GUI.SetVisible(Btn,false);
			GUI.SetHeight(scr_GuardType_Bg,(#Pet_Fragment_player-1) * 38 + 10)
			GUI.SetHeight(scr_GuardType,(#Pet_Fragment_player-1) * 40)
			GUI.SetPositionY(scr_GuardType,#Pet_Fragment_player-1)
			--GUI.ButtonSetShowDisable(Btn,false)
		else
			GUI.SetVisible(Btn,true);
			--GUI.ButtonSetShowDisable(Btn,true)
		end
	end
	
	
	if not PetFragmentConvert.Item_num then 
		PetFragmentConvert.Item_num = 0
	end
	
	-- CDebug.LogError(PetFragmentConvert.GoodsNumber)
	local num = 0
	if Pet_Fragment_player[PetFragmentConvert.player_index].price and Pet_Fragment_system[PetFragmentConvert.system_index].price then
		num = (PetFragmentConvert.GoodsNumber * Pet_Fragment_system[PetFragmentConvert.system_index].price)/Pet_Fragment_player[PetFragmentConvert.player_index].price
		-- CDebug.LogError(num)
	elseif Pet_Fragment_player[PetFragmentConvert.player_index].price then
		num = PetFragmentConvert.GoodsNumber /Pet_Fragment_player[PetFragmentConvert.player_index].price
		-- CDebug.LogError("2222")
	elseif Pet_Fragment_system[PetFragmentConvert.system_index].price then
		num = PetFragmentConvert.GoodsNumber * Pet_Fragment_system[PetFragmentConvert.system_index].price
		-- CDebug.LogError("333")
	else
		num = PetFragmentConvert.GoodsNumber
		-- CDebug.LogError("777")
	end
	PetFragmentConvert.txtCurSpend_color(PetFragmentConvert.Item_num,num)
	PetFragmentConvert.item_Icon(key,system_headIcon,system_refineItemsCover,system_scr_GuardType_Bg,system_rightBtn,2)
end


--创建itemIcon
function PetFragmentConvert.item_Icon(key,headIocn,refineItemsCover,scr_GuardType_Bg,rightBtn,types)
	if not key then 
		test("key不存在")
		return
	end
	if not headIocn then 
		test("headIocn 不存在")
		return
	end
	if not refineItemsCover then 
		test("refineItemsCover 不存在")
		return
	end
	if not scr_GuardType_Bg then 
		test("scr_GuardType_Bg 不存在")
		return
	end
	if not rightBtn then 
		test("rightBtn 不存在")
		return
	end
	if not types then 
		test("types 不存在")
		return
	end
	local key_1 = string.split(GUI.GetName(GUI.GetByGuid(key)),"_")
	if not key_1[2] then
		return
	end
	local index = tonumber(key_1[2])
	local itemsID = 0
	local item = ""
	
	if types == 1 then 
		itemsID = (DB.GetOnceItemByKey2(Pet_Fragment_player[index].keyname)).Id
		if itemsID ~= 0 then
			item = DB.GetOnceItemByKey2(Pet_Fragment_player[index].keyname)
			PetFragmentConvert.Item_num = LD.GetItemCountById(itemsID)
			local prices = 0
			if PetFragmentConvert.GoodsNumber and PetFragmentConvert.system_index then 
				if Pet_Fragment_player[PetFragmentConvert.player_index].price and Pet_Fragment_system[PetFragmentConvert.system_index].price then
					prices = (PetFragmentConvert.GoodsNumber * Pet_Fragment_system[PetFragmentConvert.system_index].price)/Pet_Fragment_player[PetFragmentConvert.player_index].price
				elseif Pet_Fragment_player[PetFragmentConvert.player_index].price then
					prices = PetFragmentConvert.GoodsNumber /Pet_Fragment_player[PetFragmentConvert.player_index].price
				elseif Pet_Fragment_system[PetFragmentConvert.system_index].price then
					prices = PetFragmentConvert.GoodsNumber * Pet_Fragment_system[PetFragmentConvert.system_index].price
				else
					prices = PetFragmentConvert.GoodsNumber
				end
			end
			PetFragmentConvert.txtCurSpend_color(PetFragmentConvert.Item_num,prices)
			if item then 
				GUI.StaticSetText(rightBtn,item.Name)
				GUI.SetPositionX(rightBtn,-12)
				if Pet_Fragment_player[index].price then 
					GUI.SetPositionX(rightBtn,0)
				end
			end
		end
	elseif types == 2 then 
		itemsID = (DB.GetOnceItemByKey2(Pet_Fragment_system[index].keyname)).Id
		if itemsID ~= 0 then
			item = DB.GetOnceItemByKey2(Pet_Fragment_system[index].keyname)
			if item then 
				GUI.StaticSetText(rightBtn,item.Name)
			end
		end
	end
	
	if itemsID ~= 0 then 
		if item then	
			local grade = QualityRes[item.Grade]
			if grade ~= "" then
				GUI.ItemCtrlSetElementValue(headIocn,eItemIconElement.Border , grade)
			else
				GUI.ItemCtrlSetElementValue(headIocn,eItemIconElement.Border , "")
			end
			GUI.SetData(headIocn,"type","item")
			GUI.SetData(headIocn,"item",""..itemsID)
			GUI.ItemCtrlSetElementValue(headIocn,eItemIconElement.Icon, item.Icon)	
			local img = GUI.ItemCtrlGetElement(headIocn,eItemIconElement.Icon)
			GUI.ImageSetGray(img, false)
			GUI.SetVisible(img, true)
			GUI.SetScale(headIocn,Vector3.one)
			local _item_RightBottom = GUI.ItemCtrlGetElement(headIocn,eItemIconElement.RightBottomNum)
			if _item_RightBottom then
				GUI.SetPositionX(_item_RightBottom, 7)
				GUI.SetPositionY(_item_RightBottom, 5)
				GUI.StaticSetFontSize(_item_RightBottom, 20)
				GUI.SetIsOutLine(_item_RightBottom, true)
				GUI.SetOutLine_Color(_item_RightBottom, Color.New(0 / 255, 0 / 255, 0 / 255, 255 / 255))
				GUI.SetOutLine_Distance(_item_RightBottom, 1)
				GUI.SetColor(_item_RightBottom, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
			end
			GUI.SetVisible(refineItemsCover,false);
			GUI.SetVisible(scr_GuardType_Bg,false);
			local btnNumbersSub = GUI.Get("PetFragmentConvert/panelBg/right_bg/btnNumbersSub")
			local btnNumbersAdd = GUI.Get("PetFragmentConvert/panelBg/right_bg/btnNumbersAdd")
			if  PetFragmentConvert.player_index and  PetFragmentConvert.system_index then
				-- if Pet_Fragment_player[PetFragmentConvert.player_index].price and Pet_Fragment_system[PetFragmentConvert.system_index].price then
					local price_player = tonumber(Pet_Fragment_player[PetFragmentConvert.player_index].price) or 1
					local price_system = tonumber(Pet_Fragment_system[PetFragmentConvert.system_index].price) or 1
					if PetFragmentConvert.Item_num * price_player  >= price_system *2 then
						GUI.ButtonSetShowDisable(btnNumbersAdd,true)
					else
						GUI.ButtonSetShowDisable(btnNumbersAdd,false)		
					end						
				-- end
				
				GUI.ButtonSetShowDisable(btnNumbersSub,false)
				if types == 1 then
					PetFragmentConvert.Item_num = LD.GetItemCountById(itemsID)
				end
				local prices = 1
				if PetFragmentConvert.GoodsNumber and PetFragmentConvert.system_index then 
					if Pet_Fragment_player[PetFragmentConvert.player_index].price and Pet_Fragment_system[PetFragmentConvert.system_index].price then
						prices = (PetFragmentConvert.GoodsNumber * Pet_Fragment_system[PetFragmentConvert.system_index].price)/Pet_Fragment_player[PetFragmentConvert.player_index].price
					elseif Pet_Fragment_player[PetFragmentConvert.player_index].price then
						prices = PetFragmentConvert.GoodsNumber /Pet_Fragment_player[PetFragmentConvert.player_index].price
					elseif Pet_Fragment_system[PetFragmentConvert.system_index].price then
						prices = PetFragmentConvert.GoodsNumber * Pet_Fragment_system[PetFragmentConvert.system_index].price
					else
						prices = PetFragmentConvert.GoodsNumber
					end
				end
				PetFragmentConvert.txtCurSpend_color(PetFragmentConvert.Item_num,prices)
			else
				GUI.ButtonSetShowDisable(btnNumbersSub,false) 
				GUI.ButtonSetShowDisable(btnNumbersAdd,false)
			end
		end			
	end
	
	-- CDebug.LogError(types)
	
	--选中时判断按钮是否可用
	-- if PetFragmentConvert.Item_num and PetFragmentConvert.player_index and PetFragmentConvert.system_index then
		-- local btnNumbersAdd = GUI.Get("PetFragmentConvert/panelBg/right_bg/btnNumbersAdd")
		-- if Pet_Fragment_player[PetFragmentConvert.player_index].price then
			-- if Pet_Fragment_player[PetFragmentConvert.player_index].price == Pet_Fragment_system[PetFragmentConvert.system_index].price then
				-- if PetFragmentConvert.Item_num >= 2 then
					-- GUI.ButtonSetShowDisable(btnNumbersAdd,true)	
				-- else
					-- GUI.ButtonSetShowDisable(btnNumbersAdd,false)	
				-- end
			-- end
		-- else
			-- if PetFragmentConvert.Item_num >= 4 then
				-- GUI.ButtonSetShowDisable(btnNumbersAdd,true)	
			-- else
				-- GUI.ButtonSetShowDisable(btnNumbersAdd,false)	
			-- end			
		-- end
		
		-- local btnNumbersSub = GUI.Get("PetFragmentConvert/panelBg/right_bg/btnNumbersSub")	
		-- GUI.ButtonSetShowDisable(btnNumbersSub,false)

	
end


function PetFragmentConvert.on_itembg_click(key,guid)
	--test("icon创建")
	local bgPanel =  GUI.Get("PetFragmentConvert/panelBg")
	local item_bg = GUI.GetByGuid(key)
	local types = GUI.GetData(item_bg,"type")
	if types == "item" then
		local item = tonumber(GUI.GetData(item_bg,"item"))
		if item then
			local tips = Tips.CreateByItemId(item,bgPanel,"ItemTips",-850,-170)
			SetAnchorAndPivot(tips, UIAnchor.Right, UIAroundPivot.Left)
			GUI.SetIsRemoveWhenClick(tips,true)
		end
	end
end

--关闭
function PetFragmentConvert.OnClosePanel(key,guid)
	
	GUI.DestroyWnd("PetFragmentConvert")
end

--每次打开界面界面
function PetFragmentConvert.OnOpenWndCallBack(wndname)
	if wndname == "PetFragmentConvert" then
		local panel = GUI.GetWnd("PetFragmentConvert")
		GUI.SetVisible(panel,true);
		CL.SendNotify(NOTIFY.SubmitForm,"FormPetFraEx","GetData");
	end
end

--兑换
function PetFragmentConvert.On_btnBuy_Click()
	if not PetFragmentConvert.system_index then	-- 兑换碎片下标
		test("system_index 不存在")
		CL.SendNotify(NOTIFY.ShowBBMsg, "请选择兑换获得的神兽拼图")
		return
	end
	if not PetFragmentConvert.player_index then	-- 被兑换碎片下标
		test("system_index 不存在")
		CL.SendNotify(NOTIFY.ShowBBMsg, "请选择兑换消耗的神兽拼图")
		return
	end
	if not Pet_Fragment_system[PetFragmentConvert.system_index].keyname then
		test("[PetFragmentConvert.system_index].keyname 不存在")
		return
	end
	if not Pet_Fragment_player[PetFragmentConvert.player_index].keyname then	
		test("[PetFragmentConvert.player_index].keyname 不存在")
		return
	end
	if not PetFragmentConvert.GoodsNumber then	 -- 兑换数量
		test("PetFragmentConvert.GoodsNumber 不存在")
		return
	end
	if PetFragmentConvert.GoodsNumber == 0 then
		LD.SendLocalChatMsg("请重新选择兑换数量");
		return
	end
	
	local sum = 0
	if Pet_Fragment_player[PetFragmentConvert.player_index].price and Pet_Fragment_system[PetFragmentConvert.system_index].price then 
		local num1 = Pet_Fragment_player[PetFragmentConvert.player_index].price
		local num2 = Pet_Fragment_system[PetFragmentConvert.system_index].price
		sum = (PetFragmentConvert.GoodsNumber * num2)/num1
	elseif Pet_Fragment_player[PetFragmentConvert.player_index].price then
		sum = PetFragmentConvert.GoodsNumber/Pet_Fragment_player[PetFragmentConvert.player_index].price
	elseif Pet_Fragment_system[PetFragmentConvert.system_index].price then
		sum = PetFragmentConvert.GoodsNumber*Pet_Fragment_system[PetFragmentConvert.system_index].price
	else
		sum = PetFragmentConvert.GoodsNumber
	end
		-- if Pet_Fragment_player[PetFragmentConvert.player_index].price == Pet_Fragment_system[PetFragmentConvert.system_index].price then 
			-- sum = PetFragmentConvert.GoodsNumber 
		-- end
	-- else
		-- sum = PetFragmentConvert.GoodsNumber*Pet_Fragment_system[PetFragmentConvert.system_index].price 
	-- end
	
	
	if PetFragmentConvert.Item_num < sum then 
		LD.SendLocalChatMsg("您的神兽拼图数量不足，无法兑换！");
		CL.SendNotify(NOTIFY.ShowBBMsg, "您的神兽拼图数量不足，无法兑换！")
		return
	end
	
	send_exchange_msg = "".. PetFragmentConvert.player_index .. "," .. PetFragmentConvert.system_index .. "," .. PetFragmentConvert.GoodsNumber
	--send_exchange_msg = "".. PetFragmentConvert.player_index .. "," .. PetFragmentConvert.system_index .. "," .. "4.5"
	local item_player_name = "" -- 被兑换碎片的名称
	local item_system_name = "" -- 兑换碎片的名称
	
	-- 获取（被）兑换碎片在游戏中的物品名称
	local itemsID_player = (DB.GetOnceItemByKey2(Pet_Fragment_player[PetFragmentConvert.player_index].keyname)).Id
	if itemsID_player ~= 0 then
		local item_player = DB.GetOnceItemByKey2(Pet_Fragment_player[PetFragmentConvert.player_index].keyname)
		if item_player then 
			item_player_name = item_player.Name
		end
	end
	-- 获取兑换碎片在游戏中的物品名称
	local itemsID_system = (DB.GetOnceItemByKey2(Pet_Fragment_system[PetFragmentConvert.system_index].keyname)).Id
	if itemsID_system ~= 0 then
		local item_system = DB.GetOnceItemByKey2(Pet_Fragment_system[PetFragmentConvert.system_index].keyname)
		if item_system then 
			item_system_name = item_system.Name
		end
	end
		
	-- 创建一个确认窗口
	GlobalUtils.ShowBoxMsg2Btn("确认兑换","确定使用" .. sum .. "个" .. item_player_name .. "兑换" .. PetFragmentConvert.GoodsNumber .. "个" .. item_system_name .."吗？","PetFragmentConvert","确认","Send_Excange","取消")
	
	PetFragmentConvert.InputBox_Checking(0, 1) -- 检查数据，感觉没用
end

-- 定义一个兑换事件，发送请求到服务器，调用其方法
function PetFragmentConvert.Send_Excange() 
	if not send_exchange_msg then 
		return ""
	end
	CL.SendNotify(NOTIFY.SubmitForm,"FormPetFraEx","conversion",send_exchange_msg);
end

--物品总量
function PetFragmentConvert.item_sum(index)  -- 发送请求兑换完后，执行此方法，修改"拥有" 后面的数量
	local itemsID = (DB.GetOnceItemByKey2(Pet_Fragment_player[index].keyname)).Id
	if itemsID ~= 0 then
		PetFragmentConvert.Item_num = LD.GetItemCountById(itemsID)
		PetFragmentConvert.InputBox_Checking(0, 1)
	end
end

--数量
function PetFragmentConvert.On_NumberSub()
	PetFragmentConvert.NumberChangeMode = -1
	PetFragmentConvert.StartNumberChanging()
end

function PetFragmentConvert.On_NumberAdd()
	PetFragmentConvert.NumberChangeMode = 1
	PetFragmentConvert.StartNumberChanging()
end

PetFragmentConvert.NumberChangeSpeeder = {
	{8,2},
	{5,4},
	{2,6},
	{1,6},
}

function PetFragmentConvert.StartNumberChanging()
	PetFragmentConvert.NumberChangings = 0
	PetFragmentConvert.NumberChangTimes = 0
	PetFragmentConvert.NumberSpeeder = 1
	PetFragmentConvert.NumberBtnStarting = 0
	if not PetFragmentConvert['NumberChangingTimer'] then	
		PetFragmentConvert['NumberChangingTimer'] = Timer.New(PetFragmentConvert.NumberChangingCallBack,0.1,-1)
		PetFragmentConvert['NumberChangingTimer']:Start()
	end
end

function PetFragmentConvert.NumberChangingCallBack()
	PetFragmentConvert.NumberChangings = PetFragmentConvert.NumberChangings + 1
	if PetFragmentConvert.NumberChangings%(PetFragmentConvert.NumberChangeSpeeder[PetFragmentConvert.NumberSpeeder][1]) == 0 then
		PetFragmentConvert.NumberBtnStarting = 1
		PetFragmentConvert.NumberChangTimes = PetFragmentConvert.NumberChangTimes + 1
		PetFragmentConvert.NumberChangings = 0
		PetFragmentConvert.InputBox_Checking(PetFragmentConvert.GoodsNumber, PetFragmentConvert.NumberChangeMode)
	end
	if PetFragmentConvert.NumberChangTimes == PetFragmentConvert.NumberChangeSpeeder[PetFragmentConvert.NumberSpeeder][2] then
		if PetFragmentConvert.NumberChangeSpeeder[PetFragmentConvert.NumberSpeeder+1] then
			PetFragmentConvert.NumberChangTimes = 0
			PetFragmentConvert.NumberSpeeder = PetFragmentConvert.NumberSpeeder + 1
		end
	end
end

function PetFragmentConvert.NumberChangingOver()
	if PetFragmentConvert['NumberChangingTimer'] then
		PetFragmentConvert['NumberChangingTimer']:Stop()
	end
	PetFragmentConvert['NumberChangingTimer'] = nil
	if PetFragmentConvert.NumberBtnStarting == 0 then
		PetFragmentConvert.InputBox_Checking(PetFragmentConvert.GoodsNumber, PetFragmentConvert.NumberChangeMode)
	end
end

--数量框修改后
function PetFragmentConvert.OnNumCountChange()
	local number = tonumber(GUI.EditGetTextM(PetFragmentConvert['InputBox']))
	if number then
		PetFragmentConvert.InputBox_Checking(number,0)
	else
		GUI.EditSetTextM(PetFragmentConvert['InputBox'],0)
	end
end

--输入框数值验证
function PetFragmentConvert.InputBox_Checking(number, changer)
	number = number + changer
	number = math.floor(number)
	
	-- 求出当前所能兑换的最大值
	local count = nil
	-- 获取当前选中的是不是百变神兽碎片
	local is_all_fragment = false
	if Pet_Fragment_player[PetFragmentConvert.player_index].price then
		is_all_fragment = true
	end
	-- 获取当前拥有多少个碎片
	if PetFragmentConvert.Item_num then
		if is_all_fragment then
			count = PetFragmentConvert.Item_num
		else
			count = math.floor(PetFragmentConvert.Item_num / Pet_Fragment_system[PetFragmentConvert.system_index]['price'])
		end
	end
	-- 判断玩家输入的值
	-- 如果<= 最大值 显示输入的值,就是number无需改变
	-- 如果 > 最大值 显示最大值
	if count and number > count then
		number = count
	end	
	
	-- 限定兑换最大值和最小值
	if number > 99 then 
		number = 99
	elseif number < 1 then
		number = 1
	end
	
	PetFragmentConvert.GoodsNumber = number
	local btnNumbersAdd = GUI.Get("PetFragmentConvert/panelBg/right_bg/btnNumbersAdd")
	--如果是随机神兽碎片
	local price_player = tonumber(Pet_Fragment_player[PetFragmentConvert.player_index].price) or 1
	local price_system = tonumber(Pet_Fragment_system[PetFragmentConvert.system_index].price) or 1
	local btnNumbersAdd = GUI.Get("PetFragmentConvert/panelBg/right_bg/btnNumbersAdd")	

	
	if price_player * PetFragmentConvert.Item_num >= price_system * (PetFragmentConvert.GoodsNumber +1)then
		GUI.ButtonSetShowDisable(btnNumbersAdd,true)
	else
		GUI.ButtonSetShowDisable(btnNumbersAdd,false)
	end
	local btnNumbersSub = GUI.Get("PetFragmentConvert/panelBg/right_bg/btnNumbersSub")	
	if PetFragmentConvert.GoodsNumber == 1 then
		GUI.ButtonSetShowDisable(btnNumbersSub,false)
	else
		GUI.ButtonSetShowDisable(btnNumbersSub,true)
	end
	
	
	GUI.EditSetTextM(PetFragmentConvert['InputBox'],number) -- 将数量放入到输入框
	if PetFragmentConvert.system_index then
		if not PetFragmentConvert.Item_num then -- 如果玩家拥有碎片数量变量不存在，防止nil错误
			PetFragmentConvert.Item_num = 0
		end
		-- 检查是否需要修改颜色
		if Pet_Fragment_player[PetFragmentConvert.player_index].price and Pet_Fragment_system[PetFragmentConvert.system_index].price then 
			PetFragmentConvert.txtCurSpend_color(PetFragmentConvert.Item_num,(number*Pet_Fragment_system[PetFragmentConvert.system_index].price)/Pet_Fragment_player[PetFragmentConvert.player_index].price)
		elseif Pet_Fragment_player[PetFragmentConvert.player_index].price then
			PetFragmentConvert.txtCurSpend_color(PetFragmentConvert.Item_num,number/Pet_Fragment_player[PetFragmentConvert.player_index].price)
		elseif Pet_Fragment_system[PetFragmentConvert.system_index].price then
			PetFragmentConvert.txtCurSpend_color(PetFragmentConvert.Item_num,number*Pet_Fragment_system[PetFragmentConvert.system_index].price)
		else
			PetFragmentConvert.txtCurSpend_color(PetFragmentConvert.Item_num,number)
		end
			-- end
		-- else
			-- PetFragmentConvert.txtCurSpend_color(PetFragmentConvert.Item_num,number * math.floor(Pet_Fragment_system[PetFragmentConvert.system_index]['price']))
		-- end
	end
end

--总价超过自身拥有 改红色字体
function PetFragmentConvert.txtCurSpend_color(player_Item_num,total_price) 
	-- CDebug.LogError("参数一"..player_Item_num)
	-- CDebug.LogError("参数二"..total_price)
	if player_Item_num and total_price then 
		if total_price > player_Item_num then -- 如果兑换数量 大于 自身拥有的数量 将字体显示红色
			GUI.StaticSetText(PetFragmentConvert['txtCurSpend'],"拥有  #COLORCOLORDC143C#".. player_Item_num .. "#COLORCOLOR662F16#/" .. total_price);	
		else
			GUI.StaticSetText(PetFragmentConvert['txtCurSpend'],"拥有  #COLORCOLOR662F16#"..  player_Item_num .. "/#COLORCOLOR662F16#" ..total_price);
		end
	end
end

function PetFragmentConvert.OnDestroy()
	-- PetFragmentConvert = nil
	local left_bg = GUI.Get("PetFragmentConvert/panelBg/left_bg")
	local right_bg = GUI.Get("PetFragmentConvert/panelBg/right_bg")
	local refineItemsCover = GUI.Get("PetFragmentConvert/panelBg/refineItemsCover")
	local system_refineItemsCover = GUI.Get("PetFragmentConvert/panelBg/system_refineItemsCover")
	local scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/scr_GuardType_Bg")
	local system_scr_GuardType_Bg = GUI.Get("PetFragmentConvert/panelBg/system_scr_GuardType_Bg")
	if left_bg then
		GUI.Destroy(left_bg) 
	end
	if right_bg then
		GUI.Destroy(right_bg)
	end
	if refineItemsCover then
		GUI.Destroy(refineItemsCover) 
	end
	if system_refineItemsCover then
		GUI.Destroy(system_refineItemsCover)
	end
	if scr_GuardType_Bg then
		GUI.Destroy(scr_GuardType_Bg) 
	end
	if system_scr_GuardType_Bg then
		GUI.Destroy(system_scr_GuardType_Bg)
	end
end	
