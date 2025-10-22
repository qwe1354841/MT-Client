---@diagnostic disable: undefined-global
GemExchange = {}

_gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local gemList = {}
local inspect = require("inspect")
-- GemExchange.clickIndex = nil
------------------------------------ end缓存一下全局变量end --------------------------------

local QualityRes = 
{
  "1800400330","1800400100","1800400110","1800400120","1800400320"
}

local Txtcolor = Color.New(96/255,48/255,13/255,255/255)   -- 字体颜色

GemExchange.GemType = {
    [1] = { Name = "攻击石", Icon = "1900910150" ,Subtype2 = "1"},
    [2] = { Name = "魔攻石", Icon = "1900910250" ,Subtype2 = "2"},
    [3] = { Name = "物抗石", Icon = "1900910350" ,Subtype2 = "3"},
    [4] = { Name = "生命石", Icon = "1900910450" ,Subtype2 = "4"},
    [5] = { Name = "速度石", Icon = "1900910550" ,Subtype2 = "5"},
    [6] = { Name = "封印石", Icon = "1900910650" ,Subtype2 = "6"},
    [7] = { Name = "魔抗石", Icon = "1900910750" ,Subtype2 = "7"},
    [8] = { Name = "暴击石", Icon = "1900910850" ,Subtype2 = "8"},
    --[9] = {Name="神秘宝石",Icon="1900120300"},
}

GemExchange.Gem01 = {
    [1] = { Name = "开锋石", Icon = "1900910150",Subtype2 = "1"},
    [2] = { Name = "幻灵石", Icon = "1900910250",Subtype2 = "2" },
    [3] = { Name = "金刚石", Icon = "1900910350",Subtype2 = "3" },
    [4] = { Name = "舍利石", Icon = "1900910450",Subtype2 = "4" },
    [5] = { Name = "雷影石", Icon = "1900910550",Subtype2 = "5" },
    [6] = { Name = "镇魂石", Icon = "1900910650",Subtype2 = "6" },
    [7] = { Name = "玲珑石", Icon = "1900910750",Subtype2 = "7" },
    [8] = { Name = "烈光石", Icon = "1900910850",Subtype2 = "8" },
    --[9] = {Name="神秘宝石",Icon="1900120300"},
}
--主界面
function GemExchange.Main()
	
	GemExchange.clickIndex = nil
	
    local gemExchange = GUI.WndCreateWnd("GemExchange", "GemExchange", 0, 0, eCanvasGroup.Normal)				--创建UI窗口
	_gt.BindName(gemExchange, "GemExchange")
    SetAnchorAndPivot(gemExchange, UIAnchor.Center, UIAroundPivot.Center)

    local gemCover = GUI.ImageCreate( gemExchange, "gemCover", "1800400220", 0, 0, false, GUI.GetWidth(gemExchange), GUI.GetHeight(gemExchange))
    SetAnchorAndPivot(gemCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(gemCover, true)
    --gemCover:RegisterEvent(UCE.PointerClick)

    -- -- 底图
    local panelBg = GUI.ImageCreate( gemExchange, "panelBg", "1800600182", 0, 0, false,530, 350)
    SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(panelBg, "panelBg")

    local rightBg = GUI.ImageCreate( panelBg, "RightBg", "1800600181", 0, -9.5, false, 225, 40)
    SetAnchorAndPivot(rightBg, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local leftBg = GUI.ImageCreate( panelBg, "LeftBg", "1800600180", 0, -9.5, false, 225, 40)
    SetAnchorAndPivot(leftBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
	
    -- 标题底板
    local titleBg = GUI.ImageCreate( panelBg, "TitleBg", "1800600190", 0, -10, false, 230, 50)
    SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Top)

    local titleTxt = GUI.CreateStatic( titleBg, "TitleText", "宝石转换", 0, 0, 200, 35)
    SetAnchorAndPivot(titleTxt, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleCenter)	
    GUI.StaticSetFontSize(titleTxt, 26)
    GUI.SetColor(titleTxt, Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255))
	
	local arrowsImg = GUI.ImageCreate(panelBg, "arrowsImg","1800607290",0,-8,false,60,40);
	SetAnchorAndPivot(arrowsImg, UIAnchor.Center, UIAroundPivot.Center)
	
    -- 关闭
    local closeBtn = GUI.ButtonCreate(panelBg,'closeBtn','1800302120',0,-6,Transition.ColorTint,'',46,43,false)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    --GUI.SetIsRaycastTarget(closeBtn, false)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "GemExchange", "OnCloseGem")
	-- GemExchange.OnOpenWndCallBack("GemExchange")
	a = nil
	i = nil
	--print(a)
	-- local txtCurSpend = _gt.GetUI('txtCurSpend')
	-- GUI.StaticSetText(txtCurSpend,"已选中 ".. "0")
	local left_bg = _gt.GetUI("left_bg")
	if left_bg then
		return
	end
	local panelBg = _gt.GetUI("panelBg")
	local GemExchange = GUI.GetWnd("GemExchange")

    local left_bg = GUI.GroupCreate( panelBg, "left_bg", -120, -8, 265, 350, false)						
    SetAnchorAndPivot(left_bg, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(left_bg,'left_bg')
	
	local right_bg = GUI.GroupCreate( panelBg, "right_bg", 120, -8, 265, 350, false)					
    SetAnchorAndPivot(right_bg, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(right_bg,'right_bg')
	
	local btnBuy =GUI.ButtonCreate(right_bg,  "btnBuy", "1800102090",4,134, Transition.ColorTint, "兑换"); -- 兑换按钮
	SetAnchorAndPivot(btnBuy, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetScale(btnBuy, Vector3.New(0.8,0.8,0.8))
	GUI.RegisterUIEvent( btnBuy, UCE.PointerClick , "GemExchange", "On_btnBuy_Click" )

	GUI.SetIsOutLine(btnBuy,true);											--给这个兑换按钮描个边
	GUI.ButtonSetTextFontSize(btnBuy,32);									--按钮控件文本字体 
	GUI.ButtonSetTextColor(btnBuy,Color.New(1,1,1,1));						--按钮控件文本颜色 
	GUI.SetOutLine_Color(btnBuy,Color.New(182/255,92/255,30/255,255/255));	--控件描边颜色
	GUI.SetOutLine_Distance(btnBuy,1);										--控件描边宽度
	
	local coin =GUI.ImageCreate(left_bg,  "coin", UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold],-60,135,false, 60, 60); 
	SetAnchorAndPivot(coin, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetScale(coin, Vector3.New(0.8,0.8,0.8))
	_gt.BindName(coin,'coin')

	local txtMoney = GUI.CreateStatic(left_bg,'txtMoney','0',0,135,300,300)
	GUI.StaticSetFontSize(txtMoney,24)													--文本控件字体大小 
	GUI.StaticSetAlignment(txtMoney,TextAnchor.MiddleCenter)							--文本控件对齐方式 
	SetAnchorAndPivot(txtMoney, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(txtMoney,Txtcolor);
	_gt.BindName(txtMoney,'txtMoney')
	
	--左侧宠物头像框
	local player_headIcon = GUI.ItemCtrlCreate( left_bg, "player_headIcon", "1801100120", 0, 0, 86, 86, false)
    _gt.BindName(player_headIcon,"player_headIcon")
	SetAnchorAndPivot(player_headIcon, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(player_headIcon , UCE.PointerClick , "GemExchange", "gem_" )
	
	-- local gemBg = _gt.GetUI('gemBg')
	-- GUI.SetVisible(gemBg,true)
    -- GUI.ButtonSetShowDisable(player_headIcon,true)
	
	local Plus = GUI.ItemCtrlCreate( player_headIcon, "Plus", "1800707060", 0, 0, 60, 60, false)
	SetAnchorAndPivot(Plus, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(Plus , UCE.PointerClick , "GemExchange", "gem_" )
	_gt.BindName(Plus,'Plus')

	-- local player_gemImage = GUI.ItemCtrlCreate(player_headIcon,"player_gemImage","1800102021",0,0,70,70,false)
	-- SetAnchorAndPivot(player_gemImage, UIAnchor.Center, UIAroundPivot.Center)
	-- _gt.BindName(player_gemImage,'player_gemImage')

	--右侧宠物头像框
	local system_headIcon = GUI.ItemCtrlCreate( right_bg, "system_headIcon", "1801100120", 0, 0, 86, 86, false)
	_gt.BindName(system_headIcon,'system_headIcon')
	SetAnchorAndPivot(system_headIcon, UIAnchor.Center, UIAroundPivot.Center)
	
	--"已选中"富文本框
	-- GemExchange.txtCurSpend= GUI.RichEditCreate( left_bg,  "txtCurSpend","已选中  0",0,77,200,30);	--创建富文本控件 
	local txtCurSpend = GUI.RichEditCreate( left_bg,  "txtCurSpend","已选中  0",0,77,200,30)
	GUI.StaticSetFontSize(txtCurSpend,24)													--文本控件字体大小 
	GUI.StaticSetAlignment(txtCurSpend,TextAnchor.MiddleCenter)							--文本控件对齐方式 
	SetAnchorAndPivot(txtCurSpend, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(txtCurSpend,Txtcolor);
	_gt.BindName(txtCurSpend,'txtCurSpend')

	
	local btnNumbersSub =GUI.ButtonCreate(right_bg,  "btnNumbersSub", "1800402140",-88,77, Transition.ColorTint); --减法按钮
	SetAnchorAndPivot(btnNumbersSub, UIAnchor.Center, UIAroundPivot.Center)
	btnNumbersSub:RegisterEvent(UCE.PointerDown )
	btnNumbersSub:RegisterEvent(UCE.PointerUp )
	GUI.RegisterUIEvent( btnNumbersSub, UCE.PointerDown , "GemExchange", "On_NumberSub" )
	-- GUI.RegisterUIEvent( btnNumbersSub, UCE.PointerUp, "GemExchange", "NumberChangingOver" )
	GUI.ButtonSetShowDisable(btnNumbersSub,false)																--按钮控件是否禁用 
	_gt.BindName(btnNumbersSub,'btnNumbersSub')
	
	
	local btnNumbersAdd =GUI.ButtonCreate(right_bg,  "btnNumbersAdd", "1800402150",92,77, Transition.ColorTint); -- 加法按钮
	SetAnchorAndPivot(btnNumbersAdd, UIAnchor.Center, UIAroundPivot.Center)
	btnNumbersAdd:RegisterEvent(UCE.PointerDown )
	btnNumbersAdd:RegisterEvent(UCE.PointerUp )
	GUI.RegisterUIEvent( btnNumbersAdd, UCE.PointerDown, "GemExchange", "On_NumberAdd" )
	-- GUI.RegisterUIEvent( btnNumbersAdd, UCE.PointerUp, "GemExchange", "NumberChangingOver" )
	GUI.ButtonSetShowDisable(btnNumbersAdd,false)
	_gt.BindName(btnNumbersAdd,'btnNumbersAdd')
	
	-- GemExchange['InputBox'] = GUI.EditCreate( right_bg, "InputBox", "1800400390", "0", 2, 77, Transition.ColorTint, "system", 0, 0, 8, 8, InputType.Standard, ContentType.IntegerNumber) -- 编辑框按钮
	local InputBox = GUI.EditCreate( right_bg, "InputBox", "1800400390", "0", 2, 77, Transition.ColorTint, "system", 0, 0, 8, 8, InputType.Standard, ContentType.IntegerNumber)
	SetAnchorAndPivot(InputBox, UIAnchor.Center, UIAroundPivot.Center)
    GUI.EditSetLabelAlignment(InputBox, TextAnchor.MiddleCenter)							--对其方式
    GUI.EditSetTextColor(InputBox, Txtcolor)												--输入控件文字颜色 
    GUI.EditSetFontSize(InputBox, 22)														--输入控件字体大小 
    GUI.EditSetMaxCharNum(InputBox, 4)													--输入控件输入长度 
    GUI.EditSetTextM(InputBox, 0)															--设置输入控件文字 
    GUI.RegisterUIEvent(InputBox, UCE.EndEdit, "GemExchange", "OnNumCountChange")	--注册UI逻辑交互事件 
	_gt.BindName(InputBox,'InputBox')
	
	-- 左边的下拉框
	local player_leftBtn=GUI.ButtonCreate(left_bg, "player_leftBtn","1800702040",0,-90,Transition.None,"",180,40,false);   --x y w h
	SetAnchorAndPivot(player_leftBtn, UIAnchor.Center, UIAroundPivot.Center)
	
	local text = GUI.CreateStatic( player_leftBtn, "text", "选择宝石",-0.3, 0, 200, 40, "system", true)			--x y w h
	GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)														--文本控件对齐方式 
	SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(text, Txtcolor)																				--控件颜色
	GUI.StaticSetFontSize(text, 18)																				--文本控件字体大小 

	--选择要兑换的宠物碎片
	-- 右边的下拉框
	local system_rightBtn = GUI.ButtonCreate( right_bg, "system_rightBtn", "1800702040", 0, -90, Transition.ColorTint,"",180,40,false)
	SetAnchorAndPivot(system_rightBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.ButtonSetTextFontSize(system_rightBtn,18)
	GUI.RegisterUIEvent(system_rightBtn, UCE.PointerClick, "GemExchange", "system_OnGuardTypeBtnClick")
	
	local system_text = GUI.CreateStatic( system_rightBtn, "system_text", "合成宝石", -12, 0, 180, 40, "system", true)
	GUI.StaticSetAlignment(system_text, TextAnchor.MiddleCenter)
	SetAnchorAndPivot(system_text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(system_text, Txtcolor)
	GUI.StaticSetFontSize(system_text, 18)
	_gt.BindName(system_text,'system_text')
	
	local system_pullListBtn = GUI.ImageCreate(system_rightBtn, "system_pullListBtn","1800707070",-10,0);
	SetAnchorAndPivot(system_pullListBtn, UIAnchor.Right, UIAroundPivot.Right)
	GUI.SetIsRaycastTarget(system_pullListBtn,false);
	
	-- gemExchange.OnOpenWndCallBack("gemExchange")
	-- GemExchange.system_OnGuardTypeBtnClick(1)

	local parent = _gt.GetUI("GemExchange")
    -- local gem = GUI.GroupCreate(gemExchange)


--选择宝石界面
    -- 底图
    local gemBg = GUI.ImageCreate( parent, "gemBg", "1800600182", 380, 20, false,350, 290)
    SetAnchorAndPivot(gemBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(gemBg, "gemBg")

	local rightBg = GUI.ImageCreate( gemBg, "RightBg", "1800600181", 0, -9.5, false, 225, 40)
    SetAnchorAndPivot(rightBg, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local leftBg = GUI.ImageCreate( gemBg, "LeftBg", "1800600180", 0, -9.5, false, 225, 40)
    SetAnchorAndPivot(leftBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 标题底板
    local titleBg_ = GUI.ImageCreate( gemBg, "TitleBg", "1800600190", 0, -10, false, 230, 50)
    SetAnchorAndPivot(titleBg_, UIAnchor.Top, UIAroundPivot.Top)

    -- 标题
    local titleTxt_ = GUI.CreateStatic( titleBg_, "TitleText", "宝石", 0, 0, 200, 35)
    SetAnchorAndPivot(titleTxt_, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetAlignment(titleTxt_, TextAnchor.MiddleCenter)	
    GUI.StaticSetFontSize(titleTxt_, 26)
    GUI.SetColor(titleTxt_, Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255))

    -- 关闭
    local closeBtn_ = GUI.ButtonCreate( gemBg, "ClosePanelBtn", "1800302120", 0,-6,Transition.ColorTint,'',46,43,false)
    SetAnchorAndPivot(closeBtn_, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn_, UCE.PointerClick, "GemExchange", "OnCloseGem_")

	local bottomBg = GUI.ImageCreate(gemBg, "bottomBg", "1800400010", 0, -10, false, 330, 200);
	local itemScroll = GUI.LoopScrollRectCreate(bottomBg, "itemScroll", 0, 0, 320, 180,
      "GemExchange", "CreateItemScroll", "GemExchange", "RefreshItemScroll", 0, false, Vector2.New(60, 60), 5, UIAroundPivot.Top, UIAnchor.Top);
  	GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(1, 1));
  	_gt.BindName(itemScroll, "itemScroll")

	local btnOk =GUI.ButtonCreate(gemBg,  "btnOk", "1800102090",0,115, Transition.ColorTint, "确定" , 120,50,false); 
	SetAnchorAndPivot(btnOk, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetIsOutLine(btnOk,true);											--给这个兑换按钮描个边
	GUI.ButtonSetTextFontSize(btnOk,30);									--按钮控件文本字体 
	GUI.ButtonSetTextColor(btnOk,Color.New(1,1,1,1));						--按钮控件文本颜色 
	GUI.SetOutLine_Color(btnOk,Color.New(182/255,92/255,30/255,255/255));	--控件描边颜色
	GUI.SetOutLine_Distance(btnOk,1);	
	GUI.SetScale(btnOk, Vector3.New(0.8,0.8,0.8))
	GUI.RegisterUIEvent(btnOk, UCE.PointerClick, "GemExchange", "player_Gem")
	_gt.BindName(btnOk,'btnOk')
	  
	GUI.SetVisible(gemBg,false)

end

--刷新方法
function GemExchange.Refresh()
	local gemType = item_container_type.item_container_gem_bag

	if GemExchange.clickIndex and gemList and gemList[GemExchange.clickIndex] then
		itemdata = LD.GetItemDataByGuid(gemList[GemExchange.clickIndex],gemType)
		if	itemdata then
			gem_num = tonumber(itemdata:GetAttr(ItemAttr_Native.Amount))
			--print(gem_num)
		else
			gem_num = 0
		end
	end
	-- local gem_num = LD.GetItemCountById(itemdata.id,gemType)
	local txtCurSpend = _gt.GetUI('txtCurSpend')
	GUI.StaticSetText(txtCurSpend,"已选中 "..gem_num)
	GemExchange.clickIndex = nil
	GemExchange.gem_()
end


--格子计算
function GemExchange.gem_()
	GemExchange.GetGemType()
	-- test("++++++++++++++++")
	local gemBg = _gt.GetUI('gemBg')
	GUI.SetVisible(gemBg,true)
	local itemScroll = _gt.GetUI("itemScroll")
	local Selectedimg = _gt.GetUI('Selectedimg')

	GUI.SetVisible(Selectedimg,false)

	local num = (math.ceil(#gemList/5))*5	

	GUI.LoopScrollRectSetTotalCount(itemScroll, math.max(num,15));
	GUI.LoopScrollRectRefreshCells(itemScroll);
	
	-- local inspect = require("inspect")
	-- print(inspect(GemExchange.GemExchangeData.ExchangeMoney[6]))
end

--出现格子
function GemExchange.CreateItemScroll()
	local itemScroll = _gt.GetUI("itemScroll")
	local curCount =GUI.LoopScrollRectGetChildInPoolCount(itemScroll);
	local EduItem = GUI.ItemCtrlCreate(itemScroll, "EduItem" .. curCount, "1800400050", 0, 0, 89, 89)
	GUI.RegisterUIEvent(EduItem, UCE.PointerClick, "GemExchange", "OnItemClick")
	_gt.BindName(EduItem,"EduItem"..curCount)
	local Selectedimg = GUI.ImageCreate(EduItem,"Selectedimg","1800400280",0,0,false,60,60)
	SetAnchorAndPivot(Selectedimg, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(Selectedimg,'Selectedimg')
	GUI.SetVisible(Selectedimg,false)
	-- GUI.LoopScrollRectSetTotalCount(itemScroll, 126);
	-- GUI.LoopScrollRectRefreshCells(itemScroll);
	return EduItem;
end
--格子里面与选中
function GemExchange.RefreshItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1]
	local index = tonumber(parameter[2]) + 1
	local EduItem = GUI.GetByGuid(guid)
	local gemType = item_container_type.item_container_gem_bag
	local gemGuid = gemList[index]
	GUI.SetData(EduItem,'gem_index',index)	
	if gemGuid then
		ItemIcon.BindItemGuid(EduItem,gemGuid,gemType)
	else
		ItemIcon.SetEmpty(EduItem)
	end
	
	-- ItemIcon.BindIndexForBag(EduItem, index, gemType)	
	if GemExchange.clickIndex == index then
		GemExchange.OnItemClick(guid)
	else
		local img = GUI.GetChild(EduItem,"Selectedimg")
		GUI.SetVisible(img,false)
	end
end
--点击格子的判断
function GemExchange.OnItemClick(guid)
	local EduItem = GUI.GetByGuid(guid)
	local index = tonumber(GUI.GetData(EduItem,"gem_index"))
	player = index
	local z = LD.GetItemCount(item_container_type.item_container_gem_bag);
	local gemType = item_container_type.item_container_gem_bag
	--print(index)
	if index - 1 >= z then
		return
	end
	GemExchange.clickIndex = index
	for i =0, 119 do
		local Item = _gt.GetUI("EduItem"..i)
		local img = GUI.GetChild(Item,"Selectedimg")
		GUI.SetVisible(img,false)
	end
	if gemList then
		itemdata = LD.GetItemDataByGuid(gemList[index],gemType)
	end
	local asd = itemdata.id
	--print(asd)
	if	itemdata then
		 gem_num = tonumber(itemdata:GetAttr(ItemAttr_Native.Amount))
		 --print(gem_num)
	end
    local select = GUI.GetChild(EduItem, 'Selectedimg')
	_gt.BindName(select,'select')
   
    GUI.SetVisible(select, true)
	local itemData = LD.GetItemDataByIndex(0)

end
--玩家选择宝石的判断
function GemExchange.player_Gem(key)
	local Gem01 = GemExchange.Gem01
	local GemType = GemExchange.GemType
	local gemBg = _gt.GetUI('gemBg')
	local system_text = _gt.GetUI('system_text')
	local system_headIcon = _gt.GetUI('system_headIcon')
	GUI.SetVisible(gemBg,false)
	local player_headIcon = _gt.GetUI('player_headIcon')
	local system_refineItemsCover = nil
	local system_scr_GuardType_Bg = nil
	local text = GUI.Get("GemExchange/panelBg/left_bg/player_leftBtn/text")
	GemExchange.item_Icon(key,player_headIcon,system_refineItemsCover,system_scr_GuardType_Bg,text,2)
	GUI.SetData(EduItem,'gem_index',index)
	local txtCurSpend = _gt.GetUI('txtCurSpend')
	GUI.StaticSetText(txtCurSpend,"已选中 "..gem_num)
	local InputBox = _gt.GetUI('InputBox')
	local num = tonumber(GUI.EditGetTextM(InputBox))
	local btnNumbersAdd = _gt.GetUI('btnNumbersAdd')
	local btnNumbersSub = _gt.GetUI('btnNumbersSub')
	local money = _gt.GetUI('txtMoney')
	GUI.StaticSetText(money,"0")
	GUI.EditSetTextM(InputBox, 0)
	local num = tonumber(GUI.EditGetTextM(InputBox))
	local coin = _gt.GetUI('coin')
	local gemType = item_container_type.item_container_gem_bag
	local capacity = LD.GetBagCapacity(gemType)
	GemExchange.playerindex = GemExchange.clickIndex -1
	local itemdata = LD.GetItemDataByGuid(gemList[GemExchange.clickIndex],gemType)
	local itemDB = DB.GetOnceItemByKey1(itemdata.id)
	local Level = itemDB.Itemlevel
	if i~= nil then
		local grade = QualityRes[itemDB.Grade]
		local index = tonumber(system_index)
		local itemDB_system = DB.GetOnceItemByKey2(Level.."级"..GemType[index].Name)
		GUI.ItemCtrlSetElementValue(system_headIcon,eItemIconElement.Icon, itemDB_system.Icon)
		GUI.ItemCtrlSetElementValue(system_headIcon,eItemIconElement.Border , grade)
		GUI.StaticSetText(system_text,itemDB_system.Name)
		GUI.SetData(system_headIcon,"Need",itemDB_system.Name)
		Need = itemDB_system.Id
	end
	local table = GemExchange.GemExchangeData.ExchangeMoney
	local tab = table[Level]
	local img_num = tab.MoneyType
	local Icon = UIDefine.MoneyTypes[img_num]
	local img = UIDefine.AttrIcon[Icon]
	GUI.ImageSetImageID(coin,img)
	if num < gem_num then
		GUI.ButtonSetShowDisable(btnNumbersAdd,true)
	else
		GUI.ButtonSetShowDisable(btnNumbersAdd,false)
	end

	Swap = tostring(itemdata.guid)
end
	

function GemExchange.system_OnRefineItemsCoverClick(key)
	local system_refineItemsCover = GUI.Get("GemExchange/panelBg/system_refineItemsCover")
	local system_scr_GuardType_Bg = GUI.Get("GemExchange/panelBg/system_scr_GuardType_Bg")
	GUI.SetVisible(system_scr_GuardType_Bg,false);
	GUI.SetVisible(system_refineItemsCover, false)
end

function GemExchange.system_OnGuardTypeBtnClick(key) 											--右边下拉菜单的创建
	--print("123")
	local GemType = GemExchange.Gem01
	local panelBg = GUI.Get("GemExchange/panelBg")
	local system_refineItemsCover = GUI.Get("GemExchange/panelBg/system_refineItemsCover")
	_gt.BindName(system_refineItemsCover,'system_refineItemsCover')
	local system_scr_GuardType_Bg = GUI.Get("GemExchange/panelBg/system_scr_GuardType_Bg")
	_gt.BindName(system_scr_GuardType_Bg,'system_scr_GuardType_Bg')
	local panel = GUI.GetWnd("GemExchange")
	i = 1
	if not system_refineItemsCover then 
		system_refineItemsCover = GUI.ImageCreate( panelBg, "system_refineItemsCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
		SetAnchorAndPivot(system_refineItemsCover, UIAnchor.Center, UIAroundPivot.Center)
		system_refineItemsCover:RegisterEvent(UCE.PointerClick)
		GUI.SetIsRaycastTarget(system_refineItemsCover, true)
		GUI.RegisterUIEvent(system_refineItemsCover, UCE.PointerClick, "GemExchange", "system_OnRefineItemsCoverClick")
		GUI.SetGroupAlpha(system_refineItemsCover,0)
		--创建神兽碎片按钮选择列表
		system_scr_GuardType_Bg=GUI.ImageCreate(panelBg, "system_scr_GuardType_Bg","1800400290",120,93,false,180,#GemExchange.GemType* 38 + 10);
		SetAnchorAndPivot(system_scr_GuardType_Bg, UIAnchor.Top, UIAroundPivot.Top)
		
		local system_childSize_GuardType = Vector2.New(172,38)
		local system_scr_GuardType=GUI.ScrollRectCreate(system_scr_GuardType_Bg, "system_scr_GuardType",0,0,180,#GemExchange.GemType* 38,0,false,system_childSize_GuardType,UIAroundPivot.Top,UIAnchor.Top);
		SetAnchorAndPivot(system_scr_GuardType, UIAnchor.Center, UIAroundPivot.Center)
		-- for i = 1, #GemExchange.GemType do
		-- 	local name = GemExchange.GemType[i].Name	
		-- end
		

		for k,v in ipairs(GemType) do
			-- local itemsID = (DB.GetOnceItemByKey2(GemType[k]["Name"])).Id
			-- if itemsID ~= 0 then 
				-- local item = DB.GetOnceItemByKey2(GemType[k]["Name"])
				-- if item then 
					local btn=GUI.ButtonCreate(system_scr_GuardType, "system_"..k,"1800600100",0,0,Transition.ColorTint,v.Name,172,40,false);
					GUI.ButtonSetTextFontSize(btn,18)
					GUI.ButtonSetTextColor(btn,Txtcolor);
					GUI.RegisterUIEvent(btn,UCE.PointerClick,"GemExchange","system_OnBtnClick")
					GUI.SetData(btn,"index",k)
				-- end
			-- end
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

function GemExchange.system_OnBtnClick(key)
	local system_headIcon = GUI.Get("GemExchange/panelBg/right_bg/system_headIcon")
	local system_refineItemsCover = GUI.Get("GemExchange/panelBg/system_refineItemsCover")
	local system_scr_GuardType_Bg = GUI.Get("GemExchange/panelBg/system_scr_GuardType_Bg")
	local system_text = GUI.Get("GemExchange/panelBg/right_bg/system_rightBtn/system_text")
	GemExchange.item_Icon(key,system_headIcon,system_refineItemsCover,system_scr_GuardType_Bg,system_text,1)
end
--所有表的创建
function GemExchange.item_Icon(key,system_headIcon,system_refineItemsCover,system_scr_GuardType_Bg,system_text,types)
	local btn = GUI.GetByGuid(key)
	local index = tonumber(GUI.GetData(btn,"index"))
	--print(index)
	if index then
		system_index = index
	end
	local GemType = GemExchange.GemType
	local gemType = item_container_type.item_container_gem_bag
	local Gem01 = GemExchange.Gem01 
	local Plus = _gt.GetUI('Plus')
	local player_headIcon = _gt.GetUI('player_headIcon')
	-- local player_gemImage = _gt.GetUI('player_gemImage')
	if types == 1 then
		a = 1
		GUI.SetVisible(system_scr_GuardType_Bg,false)
		GUI.SetVisible(system_refineItemsCover,false)
		local player_Swap = GemExchange.clickIndex
		if player_Swap == nil then
			GUI.ItemCtrlSetElementValue(system_headIcon,eItemIconElement.Icon, GemType[index].Icon)
			GUI.ItemCtrlSetElementValue(system_headIcon,eItemIconElement.Border , "1800400110")
			GUI.StaticSetText(system_text,Gem01[index].Name)
			local itemDB_system = DB.GetOnceItemByKey2("1级"..GemType[index].Name)
			local Subtype2 = itemDB_system.Subtype2
			GUI.SetData(system_headIcon,"Subtype2",itemDB_system.Subtype2)
			--print(Subtype2)
		end
		if player_Swap ~= nil then
			local itemData =LD.GetItemDataByIndex(GemExchange.playerindex,(item_container_type.item_container_gem_bag))

			GemExchange.playerindex = GemExchange.clickIndex -1
			-- local itemdata = LD.GetItemDataByGuid(gemList[GemExchange.playerindex],gemType)
			--print(gemList[GemExchange.clickIndex])
			local itemData_player = LD.GetItemDataByGuid(gemList[GemExchange.clickIndex],gemType)
			local itemDB_player = ""
			--print(tostring(itemData_player))
			if itemData_player then
				--print("11132131312")
				itemDB_player = DB.GetOnceItemByKey1(itemData_player.id)
			end
			-- print(itemDB_player.Grade,type(itemDB_player.Grade))
			if  itemDB_player == "" then
				CL.SendNotify(NOTIFY.ShowBBMsg, "当前宝石已用完，请切换宝石")
				return
			end
			local grade = QualityRes[itemDB_player.Grade]
			local itemDB_system = DB.GetOnceItemByKey2(itemDB_player.Itemlevel.."级"..GemType[index].Name)
			GUI.SetData(system_headIcon,"Need",itemDB_system.Name)
			-- print(itemData.guid)
			-- print(itemDB_system.Id)
			Need = itemDB_system.Id
			local Subtype2 = itemDB_system.Subtype2
			GUI.SetData(system_headIcon,"Subtype2",itemDB_system.Subtype2)
			local asd = tostring(Need)
			--print(asd)
			--print(Subtype2)
			--print(itemDB_system.Name)
			GUI.ItemCtrlSetElementValue(system_headIcon,eItemIconElement.Icon, itemDB_system.Icon)
			GUI.ItemCtrlSetElementValue(system_headIcon,eItemIconElement.Border , grade)
			GUI.StaticSetText(system_text,itemDB_player.Itemlevel..'级'..Gem01[index].Name)
		end
		
	elseif types == 2 then
		GUI.SetVisible(Plus,false)
		GemExchange.playerindex = GemExchange.clickIndex -1
		--print(player)
		local gemType = item_container_type.item_container_gem_bag
		local itemdata = LD.GetItemDataByGuid(gemList[player],gemType)
		local itemDB = DB.GetOnceItemByKey1(itemdata.id)
		local grade = QualityRes[itemDB.Grade]
		Level = tonumber(itemDB.Itemlevel)
		--print(Level)
		GUI.ItemCtrlSetElementValue(player_headIcon,eItemIconElement.Icon, itemDB.Icon)
		--print(player_headIcon)
		GUI.ItemCtrlSetElementValue(player_headIcon,eItemIconElement.Border , grade)
		GUI.StaticSetText(system_text,itemDB.Name)
		--print(itemDB.Name)
		GUI.SetData(player_headIcon,'Swap',itemDB.Name)
	end
end	
--数字的变化
function GemExchange.OnNumCountChange()
	local InputBox = _gt.GetUI('InputBox')
	local money = _gt.GetUI('txtMoney')
	local coin = _gt.GetUI('coin')
	local num = tonumber(GUI.EditGetTextM(InputBox))
	local table = GemExchange.GemExchangeData.ExchangeMoney
	local tab = table[Level]
	local val = tab.MoneyVal
	local pay = num*val
	GUI.StaticSetText(money,pay)
	local img_num = tab.MoneyType
	local Icon = UIDefine.MoneyTypes[img_num]
	local img = UIDefine.AttrIcon[Icon]
	GUI.ImageSetImageID(coin,img)
end
--新建一个宝石列表
function GemExchange.GetGemType()
	gemList = {}
	local system_headIcon = _gt.GetUI('system_headIcon')
	--local Subtype2 = tonumber(GUI.GetData(system_headIcon,'Subtype2'))
	--print(Subtype2)
	local gemType = item_container_type.item_container_gem_bag
	local capacity = LD.GetBagCapacity(gemType)
	for i = 0, capacity - 1 do
		local itemdata = LD.GetItemDataByIndex(i,gemType)
		if itemdata then
			--local itemDB = DB.GetOnceItemByKey1(itemdata.id)
			--if itemDB.Subtype2 ~= Subtype2 then
				table.insert(gemList , itemdata.guid)
			--end
		end
	end
end
--每次打开界面界面
function GemExchange.OnOpenWndCallBack(wndname)
	if wndname == "GemExchange" then
		local panel = GUI.GetWnd("GemExchange")
		GUI.SetVisible(panel,true);
		CL.SendNotify(NOTIFY.SubmitForm,"FormExchangeGem","GetData");
	end
end
--判断兑换是否成立
function GemExchange.On_btnBuy_Click()
	-- local gemType = item_container_type.item_container_gem_bag;
	-- CL.SendNotify(NOTIFY.RearrangeItem, System.Enum.ToInt(gemType));
	local player_Swap = GemExchange.clickIndex
	local InputBox = _gt.GetUI('InputBox')
	local num = tonumber(GUI.EditGetTextM(InputBox))
	local system_headIcon = _gt.GetUI('system_headIcon')
	local player_Need = GUI.GetData(system_headIcon,'Need')
	local player_headIcon = _gt.GetUI('player_headIcon')
	local player_Swap = GUI.GetData(player_headIcon,'Swap')
	local silver = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
	local num = tonumber(GUI.EditGetTextM(InputBox))
	local money = _gt.GetUI('txtMoney')
	local coin = _gt.GetUI('coin')
	local table = GemExchange.GemExchangeData.ExchangeMoney
	local minLevel = GemExchange.GemExchangeData.MinExchangeLevel
	if a ~= 1  then	-- 兑换碎片下标
		CL.SendNotify(NOTIFY.ShowBBMsg, "请选择兑换获得的宝石")
		return
	end
	if player_Swap == nil then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请选择兑换消耗的宝石")
		return
	end
	if num == 0 then
		CL.SendNotify(NOTIFY.ShowBBMsg, "请重新选择兑换数量")
		LD.SendLocalChatMsg("请重新选择兑换数量");
		return
	end
	send_exchange_msg = "".. Swap .. "-" .. Need .. "-" .. num
	GlobalUtils.ShowBoxMsg2Btn("确认兑换","少侠确定兑换吗？","GemExchange","确认","Send_Excange","取消")
end	
--是否兑换
function GemExchange.Send_Excange()
	if not send_exchange_msg then 
		return ""
	end
	CL.SendNotify(NOTIFY.SubmitForm,"FormExchangeGem","StartExchange",send_exchange_msg);
	
end
--加号按钮
function GemExchange.On_NumberAdd()
	local InputBox = _gt.GetUI('InputBox')
	local num = tonumber(GUI.EditGetTextM(InputBox))
	local btnNumbersAdd = _gt.GetUI('btnNumbersAdd')
	GUI.EditSetTextM(InputBox, num+1)
	local num = tonumber(GUI.EditGetTextM(InputBox))
	local money = _gt.GetUI('txtMoney')
	local coin = _gt.GetUI('coin')
	local table = GemExchange.GemExchangeData.ExchangeMoney
	local minLevel = GemExchange.GemExchangeData.MinExchangeLevel
	--
		local tab = table[Level]
		local val = tab.MoneyVal
		local pay = num*val
		GUI.StaticSetText(money,pay)
		local img_num = tab.MoneyType
		local Icon = UIDefine.MoneyTypes[img_num]
		local img = UIDefine.AttrIcon[Icon]
		GUI.ImageSetImageID(coin,img)
		--
	if num < gem_num then
		GUI.ButtonSetShowDisable(btnNumbersAdd,true)
	else
		GUI.ButtonSetShowDisable(btnNumbersAdd,false)
	end
	local btnNumbersSub = _gt.GetUI('btnNumbersSub')
	if num > 1 then
		GUI.ButtonSetShowDisable(btnNumbersSub,true)
	else
		GUI.ButtonSetShowDisable(btnNumbersSub,false)
	end
end

function GemExchange.On_NumberSub()
	local InputBox = _gt.GetUI('InputBox')
	local num = tonumber(GUI.EditGetTextM(InputBox))
	local btnNumbersSub = _gt.GetUI('btnNumbersSub')
	local btnNumbersAdd = _gt.GetUI('btnNumbersAdd')
	GUI.EditSetTextM(InputBox, num-1)
	local num = tonumber(GUI.EditGetTextM(InputBox))
	local money = _gt.GetUI('txtMoney')
	local coin = _gt.GetUI('coin')
	local table = GemExchange.GemExchangeData.ExchangeMoney
	local minLevel = GemExchange.GemExchangeData.MinExchangeLevel
	local tab = table[Level]
		local val = tab.MoneyVal
		local pay = num*val
		GUI.StaticSetText(money,pay)
		local img_num = tab.MoneyType
		local Icon = UIDefine.MoneyTypes[img_num]
		local img = UIDefine.AttrIcon[Icon]
		GUI.ImageSetImageID(coin,img)
	if num > 1 then
		GUI.ButtonSetShowDisable(btnNumbersSub,true)
	else
		GUI.ButtonSetShowDisable(btnNumbersSub,false)
	end
	if num < gem_num then
		GUI.ButtonSetShowDisable(btnNumbersAdd,true)
	else
		GUI.ButtonSetShowDisable(btnNumbersAdd,false)
	end
end


function GemExchange.OnShow(parameter)
    local Wnd = GUI.GetWnd("GemExchange")
    if Wnd then
        GUI.SetVisible(Wnd,true);
    end
	GemExchange.OnOpenWndCallBack("GemExchange")
end
--结束
function GemExchange.OnCloseGem()
    GUI.DestroyWnd("GemExchange")
end	

function GemExchange.OnCloseGem_()
    -- print("--------------------")
    local gemBg = _gt.GetUI("gemBg")
    -- if wnd then
    --     print("wnd") 
    -- end
    GUI.SetVisible(gemBg,false)
end

function GemExchange.OnDestroy()
	--print(123)
	-- GemExchange = nil
	local left_bg = GUI.Get("GemExchange/panelBg/left_bg")
	local right_bg = GUI.Get("GemExchange/panelBg/right_bg")
	local system_refineItemsCover = GUI.Get("GemExchange/panelBg/system_refineItemsCover")
	local system_scr_GuardType_Bg = GUI.Get("GemExchange/panelBg/system_scr_GuardType_Bg")
	if left_bg then
		GUI.Destroy(left_bg) 
	end
	if right_bg then
		GUI.Destroy(right_bg)
	end
	if system_refineItemsCover then
		GUI.Destroy(system_refineItemsCover)
	end
	if system_scr_GuardType_Bg then
		GUI.Destroy(system_scr_GuardType_Bg)
	end
end	