local StallsUI = {}

_G.StallsUI = StallsUI
local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

--商品最大单价（暂时客户端写死）
-- StallsUI.GoodsMaxPrice = 999999

local LabelList = {
	{ "物品", "BuyPageItemToggle", "OnItemToggleClick", "BuyPage_Item", },
	{ "宠物", "BuyPagePetToggle", "OnPetToggleClick","BuyPage_Pet",},
}

--浏览过的商店名单
StallsUI.BrowsedShopList = {}


StallsUI.ShopIntroduce = {}


--离线摆摊介绍文本
local OfflineTipsText = "设置离线摆摊时间，可以保证你在摆摊状态下退出游戏，仍然可以进行摆摊出售商品。商品售罄会自动收摊。每周系统赠送400分钟离线摆摊时间（系统赠送的离线摆摊时间未用完不会累积到下周）。"

function StallsUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("StallsUI", "StallsUI", 0, 0);
    SetAnchorAndPivot(wnd, UIAnchor.Center, UIAroundPivot.Center)
	
	local w = GUI.GetWidth(wnd)
	local h = GUI.GetHeight(wnd)
	--售卖页
	local SellPage = GUI.GroupCreate(wnd, "SellPage", 0, 0, w,h)
	_gt.BindName(SellPage, "SellPage")
    local Panel = UILayout.CreateFrame_WndStyle0(SellPage, "摆    摊","StallsUI", "OnCloseBtnClick", _gt)

	--创建售卖页相关子控件
	StallsUI.CreateSellPage(Panel)
	
	--购买页
	local BuyPage = GUI.GroupCreate(wnd, "BuyPage", 0, 0, w,h)
	_gt.BindName(BuyPage, "BuyPage")
	local Panel = UILayout.CreateFrame_WndStyle0(BuyPage, "杂货摊","StallsUI", "OnCloseBtnClick", _gt)	
    UILayout.CreateRightTab(LabelList, "StallsUI/BuyPage")
	--创建购买页相关子控件
	StallsUI.CreateBuyPage(Panel)
end
function StallsUI.OnItemQueryNtf()
	-- StallsUI.ConfirmSellPopup(2)
end

function StallsUI.OnPetQueryNtf()
	local petdata = LD.GetQueryPetData()
	PetInfoUI.SetPetData(petdata)
end

function StallsUI.Register()
	CL.RegisterMessage(GM.ItemQueryNtf, "StallsUI", "OnItemQueryNtf");
	CL.RegisterMessage(GM.PetQueryNtf, "StallsUI", "OnPetQueryNtf");
	--监听钱币
	if StallsUI.MoneyType then
		CL.RegisterAttr(UIDefine.MoneyTypes[StallsUI.MoneyType],StallsUI.RefreshOnGoldChange)
	end
end

function StallsUI.UnRegister()
	CL.UnRegisterMessage(GM.ItemQueryNtf, "StallsUI", "OnItemQueryNtf");
	CL.UnRegisterMessage(GM.PetQueryNtf, "StallsUI", "OnPetQueryNtf");
	CL.UnRegisterAttr(UIDefine.MoneyTypes[StallsUI.MoneyType],StallsUI.RefreshOnGoldChange)
end


function StallsUI.RefreshOnGoldChange(goldType,count)
	if StallsUI.ShowType == 1 then
		local num = _gt.GetUI("coinNum_SellPage")
		GUI.StaticSetText(num,tostring(count))
	elseif StallsUI.ShowType == 2 then
		local num = _gt.GetUI("coinNum_BuyPage")
		GUI.StaticSetText(num,tostring(count))
	end

end

function StallsUI.OnShow(parameter)
	if parameter and parameter ~= "" then
		-- StallsUI.Register()
		StallsUI.tabIndex = 1
		if parameter == "0" then
			StallsUI.TargetGuid = tostring(LD.GetSelfGUID())
			StallsUI.ShowType = 1 --出售模式
			--获得自身背包道具/宠物
			StallsUI.GetMyItemGuidList()
			StallsUI.GetMyPetGuidList()
			local status = CL.GetIntCustomData("Stall_Status")
			-- test(status)
			if status == 0 then
				CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "GetReady")
			else
				CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "GetData")
			end
		else
			StallsUI.TargetGuid = parameter
			StallsUI.ShowType = 2 --购买模式
			--上方店铺名刷新(在点击时缓存
			local stallName = GUI.Get("StallsUI/BuyPage/panelBg/titleBg/titleText")
			GUI.StaticSetText(stallName,MainUI.ShopName or "杂货铺")
			
			CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "Display",StallsUI.TargetGuid)
		end
	else
		return 
	end

	local SellPage = _gt.GetUI("SellPage")
	local BuyPage = _gt.GetUI("BuyPage")
	GUI.SetVisible(SellPage,false)
	GUI.SetVisible(BuyPage,false)
	
	local wnd = GUI.GetWnd("StallsUI")
	if wnd then
		GUI.SetVisible(wnd, true)
	end
	
end


function StallsUI.Refresh()
	StallsUI.Register()
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(StallsUI.SellList))

	--刷新钱币显示
	local count = tonumber(tostring(CL.GetAttr(UIDefine.MoneyTypes[StallsUI.MoneyType])))
	StallsUI.RefreshOnGoldChange(StallsUI.MoneyType,count)
	
	if StallsUI.ShowType == 1 then --出售模式
		--获得自己摊位当前状态并设置对应界面
		StallsUI.InitStallStatus()
		
		--刷新离线摆摊相关
		StallsUI.RefreshOfflineStatus()
		
		--刷新店铺名称
		StallsUI.RefreshShopIntroduce()
	
		--刷新包裹子页签
		StallsUI.RefreshSellPageTab()

		--刷新上架货物
		StallsUI.RefreshSellPage()
		
		local SellPage = _gt.GetUI("SellPage")
		GUI.SetVisible(SellPage,true)
	elseif StallsUI.ShowType == 2 then --购买模式
		
		--右侧页签
		UILayout.OnTabClick(StallsUI.tabIndex, LabelList)	
	
		--刷新关注
		StallsUI.RefreshAttention()
		
		--刷新店铺老板
		StallsUI.RefreshOwnerName()
		
		--刷新货物
		StallsUI.ItemGoodsIndex = nil
		StallsUI.LastItemGuid = nil
		StallsUI.RefreshBuyPage()
		
		local BuyPage = _gt.GetUI("BuyPage")
		GUI.SetVisible(BuyPage,true)	
		
		--记录下已经查看过该店铺
		StallsUI.BrowsedShopList[StallsUI.TargetGuid] = true
		MainUI.SetStallSignboards(StallsUI.TargetGuid)
	end
	
end


function StallsUI.RefreshAttention()
	if not StallsUI.AttentionList then
		StallsUI.AttentionList = {}
	end
	
	local Toggle = _gt.GetUI("AttentionToggle")
	if StallsUI.AttentionList[StallsUI.TargetGuid] then
		GUI.CheckBoxSetCheck(Toggle, true)
	else
		GUI.CheckBoxSetCheck(Toggle, false)
	end
end


function StallsUI.InitStallStatus()
	StallsUI.StallStatus = CL.GetIntCustomData("Stall_Status")
	local SetUpBtn = _gt.GetUI("SetUpBtn")
	local PickUpBtn = _gt.GetUI("PickUpBtn")
	if StallsUI.StallStatus == 1 then
		GUI.ButtonSetText(SetUpBtn, "摆摊")
		-- GUI.SetVisible(PickUpBtn,false)
	else
		GUI.ButtonSetText(SetUpBtn, "返回准备")
		-- GUI.SetVisible(PickUpBtn,true)	
	end
end

--刷新名字
function StallsUI.RefreshShopIntroduce()
	StallsUI.ShopIntroduce = loadstring("return "..CL.GetStrCustomData("Stall_ShopIntroduce","0"))()
	StallsUI.OnRenamePanelClose()	
	local StallsName =_gt.GetUI("StallsName")
	GUI.StaticSetText(StallsName,StallsUI.ShopIntroduce[2] or "杂货铺")
end


--刷新离线相关设置
function StallsUI.RefreshOfflineStatus()
	--
	local Panel = _gt.GetUI("setOfflinePanel")
	GUI.Destroy(Panel)
	--时间
	local Toggle = _gt.GetUI("OfflineSellTime")
	GUI.StaticSetText(Toggle,UIDefine.LeftTimeFormatEx2(StallsUI.OfflineTimeSetUse, 1) or "00:00:00")
	--设置按钮状态
	-- test("234====="..StallsUI.OfflineSwitch)
	local Toggle = _gt.GetUI("OfflineSellToggle")
	GUI.CheckBoxSetCheck(Toggle,StallsUI.OfflineSwitch == 1)
end

function StallsUI.RefreshBuyPage()
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(StallsUI.SellList))
	-- test("1111")
	local ItemGoodsPage = _gt.GetUI("BuyPage_Item")
	local PetGoodsPage = _gt.GetUI("BuyPage_Pet") 
	if StallsUI.tabIndex ==1 then
		--刷新道具信息
		StallsUI.RefreshItemInfoPanel()
		--刷新道具商品
		local scroll = _gt.GetUI("BuyPage_ItemGoodsScroll")
		local tb = StallsUI.SellList["Item"]
		GUI.LoopScrollRectSetTotalCount(scroll, #tb)
		GUI.LoopScrollRectRefreshCells(scroll)
		--刷新道具信息
		-- StallsUI.RefreshItemInfoPanel()
	elseif StallsUI.tabIndex ==2 then
		--刷新宠物商品
		local scroll = _gt.GetUI("BuyPage_PetGoodsScroll")
		local tb = StallsUI.SellList["Pet"]
		GUI.LoopScrollRectSetTotalCount(scroll, #tb)
		GUI.LoopScrollRectRefreshCells(scroll)	
	end
	GUI.SetVisible(ItemGoodsPage,StallsUI.tabIndex == 1)
	GUI.SetVisible(PetGoodsPage,StallsUI.tabIndex == 2)
end

function StallsUI.UpDateOnSellGoods()
	if StallsUI.ShowType == 1 then 
		if StallsUI.tabIndex == 1 then
			--上下架界面关闭
			StallsUI.OnSellPopupClose()
			--对我的道具列表进行刷新
			StallsUI.GetMyItemGuidList()
			
			--刷新货物
			local scroll = _gt.GetUI("SellItemScroll")
			local tb = StallsUI.SellList["Item"]
			GUI.LoopScrollRectSetTotalCount(scroll, #tb)
			GUI.LoopScrollRectRefreshCells(scroll)
			
		elseif StallsUI.tabIndex == 2 then
			GUI.DestroyWnd("PetInfoUI")
			StallsUI.GetMyPetGuidList()
			
			local scroll = _gt.GetUI("SellPetScroll")
			local tb = StallsUI.SellList["Pet"]
			GUI.LoopScrollRectSetTotalCount(scroll, #tb)
			GUI.LoopScrollRectRefreshCells(scroll)		
		end
	elseif StallsUI.ShowType == 2 then
		if StallsUI.tabIndex == 2 then
			GUI.DestroyWnd("PetInfoUI")
		end
		StallsUI.RefreshBuyPage()
	end
end


function StallsUI.RefreshSellPage()
	local ItemGoodsPage = _gt.GetUI("ItemGoodsPage")
	local PetGoodsPage = _gt.GetUI("PetGoodsPage") 
	
	
	if StallsUI.tabIndex == 1 then
		StallsUI.RefreshCanSellGoods()

		local scroll = _gt.GetUI("SellItemScroll")
		local tb = StallsUI.SellList["Item"]
		GUI.LoopScrollRectSetTotalCount(scroll, #tb)
		GUI.LoopScrollRectRefreshCells(scroll)
	elseif StallsUI.tabIndex == 2 then
		StallsUI.RefreshCanSellPet()
		
		local tb = StallsUI.SellList["Pet"]
		local scroll = _gt.GetUI("SellPetScroll")
		GUI.LoopScrollRectSetTotalCount(scroll, #tb)
		GUI.LoopScrollRectRefreshCells(scroll)
	end
	
	GUI.SetVisible(ItemGoodsPage,StallsUI.tabIndex == 1)
	GUI.SetVisible(PetGoodsPage,StallsUI.tabIndex == 2)
end


function StallsUI.GetMyItemGuidList() --获得可售物品列表
	-- if not StallsUI.MyItemGuidList then
		StallsUI.MyItemGuidList = {}
	-- end
	local bagType={item_container_type.item_container_bag,item_container_type.item_container_gem_bag,item_container_type.item_container_guard_bag}
	for i = 1, #bagType do
		local itemCount = LD.GetItemCount(bagType[i])
		for j = 0, itemCount - 1 do
			local itemData = LD.GetItemDataByItemIndex(j,bagType[i])
			if itemData.isbound == 0 then
				table.insert(StallsUI.MyItemGuidList, itemData.guid)
			end
		end
	end	
	
	StallsUI.RefreshCanSellGoods()

end

--刷新可售道具
function StallsUI.RefreshCanSellGoods()
	
	if StallsUI.MyItemGuidList then
		local MyItemScroll = _gt.GetUI("MyItemScroll")
		local count = #StallsUI.MyItemGuidList
		GUI.LoopScrollRectSetTotalCount(MyItemScroll, math.max(math.ceil(count/5)*5,25))
		GUI.LoopScrollRectRefreshCells(MyItemScroll)
	end

end


function StallsUI.GetMyPetGuidList() --获得可售宠物列表
	-- if not StallsUI.MyItemGuidList then
		StallsUI.MyPetGuidList = {}
	-- end
	local petList = LD.GetPetGuids()
	-- petGuidList.Count
	for i= 0 , petList.Count - 1 do
		if tostring(LD.GetPetState(PetState.Bind, petList[i])) == "false" then
			table.insert(StallsUI.MyPetGuidList,petList[i])
		end
	end

	
	StallsUI.RefreshCanSellPet()

end

--刷新可售道具
function StallsUI.RefreshCanSellPet()
	
	if StallsUI.MyPetGuidList then
		local MyPetScroll = _gt.GetUI("MyPetScroll")
		local count = #StallsUI.MyPetGuidList
		GUI.LoopScrollRectSetTotalCount(MyPetScroll, count)
		GUI.LoopScrollRectRefreshCells(MyPetScroll)
	end

end

--设置离线摆摊
function StallsUI.OnOfflineSellToggleClick()
	local Toggle = _gt.GetUI("OfflineSellToggle")
	-- test(tostring(GUI.CheckBoxGetCheck(Toggle) and 1 or 0))
	CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "SetOffline",GUI.CheckBoxGetCheck(Toggle) and 1 or 0)	
end


function StallsUI.CreateSellPage(Panel)
	if not Panel then
		return
	end
	
	--交易记录按钮
	local RecordBtn = GUI.ButtonCreate(Panel, "RecordBtn", "1800402110", 450, -250, Transition.ColorTint, "交易记录", 138, 45, false);
	GUI.ButtonSetTextColor(RecordBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(RecordBtn, UIDefine.FontSizeM)
	GUI.RegisterUIEvent(RecordBtn, UCE.PointerClick, "StallsUI", "OnRecordBtnClick")	
	
	--离线摆摊相关
    local OfflineSellToggle = GUI.CheckBoxCreate (Panel,"OfflineSellToggle", "1800607150", "1800607151", 100, 85,Transition.ColorTint, false)
	SetAnchorAndPivot(OfflineSellToggle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)	
	GUI.RegisterUIEvent(OfflineSellToggle, UCE.PointerClick, "StallsUI", "OnOfflineSellToggleClick")	
	_gt.BindName(OfflineSellToggle,"OfflineSellToggle")

	local Text = GUI.CreateStatic(OfflineSellToggle, "Text", "离线摆摊", 120, 0, 200, 50)
	GUI.SetColor(Text, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
	
	local Bg = GUI.ImageCreate(OfflineSellToggle, "StallsNameBg", "1800700010", 122, -16, false, 104, 32)
	local OfflineSellTime = GUI.CreateStatic(Bg, "OfflineSellTime", "00:00:00", 0, -1, 200, 50)
	GUI.SetColor(OfflineSellTime, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(OfflineSellTime, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(OfflineSellTime, UILayout.Center)
	GUI.StaticSetAlignment(OfflineSellTime, TextAnchor.MiddleCenter)
	_gt.BindName(OfflineSellTime,"OfflineSellTime")
	
	local SetOffline = GUI.ButtonCreate(OfflineSellToggle, "SetOffline", "1800402110", 234, -26, Transition.ColorTint, "设置", 72, 45, false);
	GUI.ButtonSetTextColor(SetOffline, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(SetOffline, UIDefine.FontSizeM)
	GUI.RegisterUIEvent(SetOffline, UCE.PointerClick, "StallsUI", "OnSetOfflineBtnClick")	
	
	--摊位名称
	local StallsNameBg = GUI.ImageCreate(Panel, "StallsNameBg", "1800400420", 0, 59, false, 260, 45)
	UILayout.SetSameAnchorAndPivot(StallsNameBg, UILayout.Top)
	local StallsName = GUI.CreateStatic(StallsNameBg, "StallsName", "杂货铺", 0, 0, 435, 50)
	GUI.SetColor(StallsName, UIDefine.BrownColor)
	GUI.StaticSetFontSize(StallsName, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(StallsName, UILayout.Center)
	GUI.StaticSetAlignment(StallsName, TextAnchor.MiddleCenter)
	_gt.BindName(StallsName,"StallsName")
	local RenameBtn = GUI.ButtonCreate(StallsNameBg,"RenameBtn", "1800402120", 100 , 0, Transition.ColorTint)
    SetAnchorAndPivot(RenameBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(RenameBtn, UCE.PointerClick, "StallsUI", "OnRenameBtnClick")		
	
	--左侧上架商品底图
	local LeftBg = GUI.ImageCreate(Panel, "LeftBg", "1800400200", -227, 5, false, 590, 450)
	UILayout.SetSameAnchorAndPivot(LeftBg, UILayout.Center)
	

	--右侧可售商品底图
	local RightBg = GUI.ImageCreate(Panel, "RightBg", "1800400200", 300, 5, false, 440, 450)
	UILayout.SetSameAnchorAndPivot(RightBg, UILayout.Center)
	--标题
	local TitleBg = GUI.ImageCreate(RightBg, "TitleBg", "1800700070", 0, 0, false, 435, 40);
	UILayout.SetSameAnchorAndPivot(TitleBg, UILayout.Top)
	local Title = GUI.CreateStatic(TitleBg, "Title", "可  售", 0, 0, 435, 50)
	GUI.SetColor(Title, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Title, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Title, UILayout.Center)
	GUI.StaticSetAlignment(Title, TextAnchor.MiddleCenter)

	--道具商品页
	local ItemGoodsPage = GUI.GroupCreate(Panel, "ItemGoodsPage", 0, 0, 0,0)
	_gt.BindName(ItemGoodsPage,"ItemGoodsPage")
	
	--道具商品
	local SellItemScroll = GUI.LoopScrollRectCreate(ItemGoodsPage, "SellItemScroll", -227, 4, 580, 430,"StallsUI", "CreateSellGoodsItem", "StallsUI", "RefreshSellItemScroll", 0, false, Vector2.New(285, 110), 2, UIAroundPivot.Top, UIAnchor.Top)
	UILayout.SetSameAnchorAndPivot(SellItemScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(SellItemScroll, Vector2.New(5, 4))
	_gt.BindName(SellItemScroll, "SellItemScroll")	

	
	
	--拥有的道具
	-- local MyItemBg = GUI.GroupCreate(RightBg, "MyItemBg", 0, 0, 0,0)

	local MyItemScroll = GUI.LoopScrollRectCreate(ItemGoodsPage, "MyItemScroll", 300, 40, 430, 340,"StallsUI", "CreateMyGoodsItem", "StallsUI", "RefreshMyItemScroll", 0, false, Vector2.New(80, 81), 5, UIAroundPivot.Top, UIAnchor.Top)
	UILayout.SetSameAnchorAndPivot(MyItemScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(MyItemScroll, Vector2.New(5, 5))
	_gt.BindName(MyItemScroll, "MyItemScroll")		
	

	--宠物商品页
	local PetGoodsPage = GUI.GroupCreate(Panel, "PetGoodsBg", 0, 0, 0,0)
	_gt.BindName(PetGoodsPage,"PetGoodsPage")
	GUI.SetVisible(PetGoodsPage,false)
	
	local SellPetScroll = GUI.LoopScrollRectCreate(PetGoodsPage, "SellPetScroll", -227, 4, 580, 430,"StallsUI", "CreateSellPetItem", "StallsUI", "RefreshSellPetScroll", 0, false, Vector2.New(575, 110), 1, UIAroundPivot.Top, UIAnchor.Top)
	UILayout.SetSameAnchorAndPivot(SellPetScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(SellPetScroll, Vector2.New(0, 5))
	_gt.BindName(SellPetScroll, "SellPetScroll")	

	-- GUI.LoopScrollRectSetTotalCount(SellPetScroll, 6) 
	-- GUI.LoopScrollRectRefreshCells(SellPetScroll)	

	--拥有的可售宠物
	local MyPetScroll = GUI.LoopScrollRectCreate(PetGoodsPage, "MyPetScroll", 300, 40, 430, 340,"StallsUI", "CreateMyPetItem", "StallsUI", "RefreshMyPetScroll", 0, false, Vector2.New(420, 96), 1, UIAroundPivot.Top, UIAnchor.Top)
	UILayout.SetSameAnchorAndPivot(MyPetScroll, UILayout.Center)
	-- GUI.ScrollRectSetChildSpacing(MyPetScroll, Vector2.New(0, 5))
	_gt.BindName(MyPetScroll, "MyPetScroll")		
	


	
	--宠物道具切换页签
	local tempBtn = GUI.ButtonCreate(Panel,"TabItem", "1800402030", 191 , -160, Transition.None, "", 227, 45, false)
    SetAnchorAndPivot(tempBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetData(tempBtn,"index",1)
	GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "StallsUI", "OnTabBtnClick")	

	local Sprite = GUI.ImageCreate(tempBtn, "Sprite", "1800402032", 0, 0, false, 226, 45)
	SetAnchorAndPivot(Sprite, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(Sprite,"TabBtnSprite_1")
	-- GUI.SetVisible(Sprite, false)
		
	local Text = GUI.CreateStatic( tempBtn, "Text", "物  品", 0, 0, 110, 50, "system", true, false)
	SetAnchorAndPivot(Text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)
	GUI.SetColor(Text, UIDefine.BrownColor)
	
	local tempBtn = GUI.ButtonCreate(Panel,"TabPet", "1800402030", 409, -160, Transition.None, "", 227, 45, false)
    SetAnchorAndPivot(tempBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetData(tempBtn,"index",2)
	GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "StallsUI", "OnTabBtnClick")

	local Sprite = GUI.ImageCreate(tempBtn, "Sprite", "1800402032", 0, 0, false, 226, 45)
	SetAnchorAndPivot(Sprite, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(Sprite,"TabBtnSprite_2")
	GUI.SetVisible(Sprite, false)
	
	local Text = GUI.CreateStatic( tempBtn, "Text", "宠  物", 0, 0, 110, 50, "system", true, false)
	SetAnchorAndPivot(Text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)
	GUI.SetColor(Text, UIDefine.BrownColor)
	
	
	--预计销售额
	-- local Text = GUI.CreateStatic(Panel, "Text", "预计销售额", -395, 264, 250, 50)
	-- GUI.SetColor(Text, UIDefine.BrownColor)
	-- GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
	-- UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
	
	-- local Bg = GUI.ImageCreate(Text, "Bg", "1800700010", 112, 0, false, 220, 38)
	-- local SalesIcon = GUI.ImageCreate(Bg, "SalesIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], -90, 0, false, 40, 40)
	-- local ExpectedSales = GUI.CreateStatic(Bg, "ExpectedSales", "0", 10, -1, 200, 50)
	-- GUI.SetColor(ExpectedSales, UIDefine.WhiteColor)
	-- GUI.StaticSetFontSize(ExpectedSales, UIDefine.FontSizeM)
	-- UILayout.SetSameAnchorAndPivot(ExpectedSales, UILayout.Center)
	-- GUI.StaticSetAlignment(ExpectedSales, TextAnchor.MiddleCenter)	
	
	--我的金币
	local Text = GUI.CreateStatic(Panel, "Text", "我的金币", 180, 264, 250, 50)
	GUI.SetColor(Text, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
	
	local Bg = GUI.ImageCreate(Text, "Bg", "1800700010", 87, 0, false, 220, 38)
	local MyCoinIcon = GUI.ImageCreate(Bg, "MyCoinIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], -90, 0, false, 40, 40)
	local MyCoin = GUI.CreateStatic(Bg, "MyCoin", "0", 10, -1, 200, 50)
	GUI.SetColor(MyCoin, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(MyCoin, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(MyCoin, UILayout.Center)
	GUI.StaticSetAlignment(MyCoin, TextAnchor.MiddleCenter)
	_gt.BindName(MyCoin,"coinNum_SellPage")
	
	
	local SetUpBtn = GUI.ButtonCreate(Panel, "SetUpBtn", "1800402110", 460, 260, Transition.ColorTint, "摆摊", 125, 50, false);
	GUI.ButtonSetTextColor(SetUpBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(SetUpBtn, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(SetUpBtn, UILayout.Center)
	GUI.RegisterUIEvent(SetUpBtn, UCE.PointerClick, "StallsUI", "OnSetUpBtnClick")
	_gt.BindName(SetUpBtn,"SetUpBtn")
	
	local PickUpBtn = GUI.ButtonCreate(Panel, "PickUpBtn", "1800402110", -20, 260, Transition.ColorTint, "收摊", 125, 50, false);
	GUI.ButtonSetTextColor(PickUpBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(PickUpBtn, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(PickUpBtn, UILayout.Center)
	GUI.RegisterUIEvent(PickUpBtn, UCE.PointerClick, "StallsUI", "OnPickUpBtnClick")
	_gt.BindName(PickUpBtn,"PickUpBtn")
	-- GUI.SetVisible(PickUpBtn,false)
	
	
	--预先创建弹出上架售出页面
	
	StallsUI.CreateSellPopup(Panel)
	
end

--修改摊位名
function StallsUI.OnRenameBtnClick()
	-- if StallsUI.StallStatus ~= 1  then
		-- CL.SendNotify(NOTIFY.ShowBBMsg,"准备状态下才可以对摊位详情进行修改")
		-- return
	-- end
	local parent = _gt.GetUI("SellPage")
	local wnd = GUI.GetWnd("StallsUI")
    local panel = GUI.ImageCreate(parent,"renamePanel", "1800400220", 0, 0, false,GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panel, true)
    panel:RegisterEvent(UCE.PointerClick)
	_gt.BindName(panel,"renamePanel")
	
	local panel = UILayout.CreateFrame_WndStyle2_WithoutCover(panel, "摊位详情", 400, 420, "StallsUI", "OnRenamePanelClose")
	local Text = GUI.CreateStatic( panel, "Text","名称：", -125, 80, 200, 50, "system", true)
    UILayout.SetAnchorAndPivot(Text, UIAnchor.Top, UIAroundPivot.Top)
	GUI.SetColor(Text,UIDefine.Brown4Color)
    GUI.StaticSetFontSize(Text,24)
    GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)	

    local nameInput = GUI.EditCreate(Text, "nameInput","1800001040",StallsUI.ShopIntroduce[2] or "", 155, 0, Transition.ColorTint, "system", 240, 50, 25, 10)
    GUI.EditSetMaxCharNum(nameInput, 14) 
	GUI.EditSetMultiLineEdit(nameInput, LineType.MultiLineSubmit)
    GUI.EditSetTextColor(nameInput, UIDefine.BrownColor)
    GUI.SetPlaceholderTxtColor(nameInput, UIDefine.GrayColor)
    GUI.EditSetLabelAlignment(nameInput, TextAnchor.MiddleLeft)
    GUI.EditSetFontSize(nameInput, 22)
    _gt.BindName(nameInput,"nameInput")

	local Text = GUI.CreateStatic( panel, "Text","简介：", -125, -45, 200, 50, "system", true)
    UILayout.SetAnchorAndPivot(Text, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(Text,UIDefine.Brown4Color)
    GUI.StaticSetFontSize(Text,24)
    GUI.StaticSetAlignment(Text, TextAnchor.MiddleCenter)

    local introduceInput = GUI.EditCreate(Text, "introduceInput","1800001040",StallsUI.ShopIntroduce[3] or "", 125, 100, Transition.ColorTint, "system", 330, 150, 25, 10)
    GUI.EditSetMaxCharNum(introduceInput, 60) 
	GUI.EditSetMultiLineEdit(introduceInput, LineType.MultiLineSubmit)
    GUI.EditSetTextColor(introduceInput, UIDefine.BrownColor)
    GUI.SetPlaceholderTxtColor(introduceInput, UIDefine.GrayColor)
    GUI.EditSetLabelAlignment(introduceInput, TextAnchor.UpperLeft)
    GUI.EditSetFontSize(introduceInput, 22)
	_gt.BindName(introduceInput,"introduceInput")	
	
	local SubmitBtn = GUI.ButtonCreate(panel,"SubmitBtn","1800102090",0,165,Transition.ColorTint,"",125,44,false)
	UILayout.SetAnchorAndPivot(SubmitBtn, UIAnchor.Center, UIAroundPivot.Center)
	GUI.RegisterUIEvent(SubmitBtn, UCE.PointerClick, "StallsUI", "OnSubmitBtnClick")
	
    local SubmitBtnText = GUI.CreateStatic(SubmitBtn, "SubmitBtnText", "提交", 0, 0, 160, 80, "system", true)
    UILayout.SetAnchorAndPivot(SubmitBtnText, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(SubmitBtnText,UIDefine.WhiteColor)
    GUI.StaticSetFontSize(SubmitBtnText, 26)
    GUI.StaticSetAlignment(SubmitBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(SubmitBtnText, true)
    GUI.SetOutLine_Color(SubmitBtnText,Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(SubmitBtnText,1)		
	
end

function StallsUI.OnSubmitBtnClick()
	local nameInput = _gt.GetUI("nameInput")
	local introduceInput = _gt.GetUI("introduceInput")
	
	local name = GUI.EditGetTextM(nameInput) or StallsUI.ShopIntroduce[2]
	local introduce = GUI.EditGetTextM(introduceInput) or StallsUI.ShopIntroduce[3]
	if name ~= "" then
		-- test(introduce)
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "SetName",name,introduce)
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,"摊位名称不能为空！")
	end
	
end

function StallsUI.OnRenamePanelClose()
	local panel = _gt.GetUI("renamePanel")
	GUI.Destroy(panel)
end

function StallsUI.OnRecordBtnClick()
	local parent = _gt.GetUI("SellPage")
	local wnd = GUI.GetWnd("StallsUI")
    local panel = GUI.ImageCreate(parent,"reportPanel", "1800400220", 0, 0, false,GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panel, true)
    panel:RegisterEvent(UCE.PointerClick)
	_gt.BindName(panel,"reportPanel")
	
	local panel = UILayout.CreateFrame_WndStyle2_WithoutCover(panel, "交易记录", 640, 460, "StallsUI", "OnReportPanelClose")
	local Bg = GUI.ImageCreate(panel, "Bg", "1800400200", 0, 15, false, 600, 375)
	UILayout.SetSameAnchorAndPivot(Bg, UILayout.Center)	

    local reportScrollWnd = GUI.ScrollRectCreate(Bg,"reportScrollWnd", 0, 0, 580, 360, 0, false, Vector2.New(580, 60),  UIAroundPivot.Top, UIAnchor.Top, 1)
    GUI.SetAnchor(reportScrollWnd, UIAnchor.Center)
    GUI.SetPivot(reportScrollWnd, UIAroundPivot.Center)
    -- GUI.ScrollRectSetChildSpacing(reportScrollWnd, Vector2.New(0, 2))
	
	if GlobalProcessing.StallReport and GlobalProcessing.StallReport[StallsUI.TargetGuid] then
		local tb = GlobalProcessing.StallReport[StallsUI.TargetGuid]
		for i = 1 ,#tb do
			local Text = GUI.CreateStatic(reportScrollWnd, "reportText"..i, tb[i], 10, -1, 580, 60,"system",true)
			GUI.SetColor(Text, UIDefine.BrownColor)
			GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
			UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
			GUI.StaticSetAlignment(Text, TextAnchor.MiddleLeft)	
		end
	end
end

function StallsUI.OnSetOfflineBtnClick()
	local parent = _gt.GetUI("SellPage")
	local wnd = GUI.GetWnd("StallsUI")
    local panel = GUI.ImageCreate(parent,"setOfflinePanel", "1800400220", 0, 0, false,GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panel, true)
    panel:RegisterEvent(UCE.PointerClick)
	_gt.BindName(panel,"setOfflinePanel")
	
	local Bg = GUI.ImageCreate(panel, "Bg", "1800600590", 0, 0, false, 560, 420)
	UILayout.SetSameAnchorAndPivot(Bg, UILayout.Center)	

	local CloseBtn = GUI.ButtonCreate(Bg, "CloseBtn", "1800302120", 0, 0, Transition.ColorTint)
    UILayout.SetAnchorAndPivot(CloseBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
	GUI.RegisterUIEvent(CloseBtn, UCE.PointerClick, "StallsUI", "OnSetOfflinePanelClose")

	local TitleBg = GUI.ImageCreate(Bg, "TitleBg", "1800001140", 0, -165, false, 240, 42)
	UILayout.SetSameAnchorAndPivot(TitleBg, UILayout.Center)	
	
	local Title = GUI.CreateStatic(TitleBg, "Title", "离线摆摊设置", 0, 0, 200, 50,"system",true)
	GUI.SetColor(Title, UIDefine.White2Color)
	GUI.StaticSetFontSize(Title, UIDefine.FontSizeXL)
	UILayout.SetSameAnchorAndPivot(Title, UILayout.Center)
	GUI.StaticSetAlignment(Title, TextAnchor.MiddleCenter)	
	
	--本周离线摆摊时间
		
	local Text = GUI.CreateStatic(Bg, "Text", "本周剩余离线摆摊时间", 40, 60, 580, 60,"system",true)
	GUI.SetColor(Text, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleLeft)	
	
	
	local TimeBg = GUI.ImageCreate(Text, "TimeBg", "1800700010", 80, 0, false, 280, 40)
	UILayout.SetSameAnchorAndPivot(TimeBg, UILayout.Center)
	
	
	--剩余时间
	-- local timeFree = UIDefine.LeftTimeFormatEx2(CL.GetIntCustomData("Stall_OfflineTimeFree"), 1)
	local timeFree = math.floor(CL.GetIntCustomData("Stall_OfflineTimeFree")/60)
	local timeExtra = math.floor(CL.GetIntCustomData("Stall_OfflineTimeExtra")/60)
	
	local timeTotal = GUI.CreateStatic(TimeBg, "timeTotal", timeFree.." + <color=#FFFF00ff>"..timeExtra.."</color>", -25, -1, 200, 60,"system",true)
	GUI.SetColor(timeTotal, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(timeTotal, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(timeTotal, UILayout.Center)
	GUI.StaticSetAlignment(timeTotal, TextAnchor.MiddleCenter)

	local ss = GUI.CreateStatic(TimeBg, "ss", "分", 175, -1, 200, 60,"system",true)
	GUI.SetColor(ss, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(ss, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(ss, UILayout.Center)
	
	local addBtn = GUI.ButtonCreate(TimeBg, "addBtn", "1800402060", 0, 0, Transition.ColorTint,"",40,40,false)
    UILayout.SetAnchorAndPivot(addBtn, UIAnchor.Right, UIAroundPivot.Right)
	GUI.RegisterUIEvent(addBtn, UCE.PointerClick, "StallsUI", "OnAddBtnClick_SetOffline")
	

	local Text = GUI.CreateStatic(Bg, "Text", "请设置离线摆摊时间", 40, 115, 580, 60,"system",true)
	GUI.SetColor(Text, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
	GUI.StaticSetAlignment(Text, TextAnchor.MiddleLeft)	

	local NumInput = GUI.EditCreate(Text, "NumInput", "1800400390", tostring(math.floor(StallsUI.OfflineTimeSetUse/60)) or "0", 20, 0, Transition.ColorTint, "system", 205, 44, 30, 8, InputType.Standard, ContentType.IntegerNumber)
	UILayout.SetSameAnchorAndPivot(NumInput, UILayout.Center);
	GUI.EditSetLabelAlignment(NumInput, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(NumInput, UIDefine.BrownColor)
	GUI.EditSetFontSize(NumInput, UIDefine.FontSizeM)
	GUI.EditSetMaxCharNum(NumInput, 8);
	GUI.RegisterUIEvent(NumInput, UCE.EndEdit, "StallsUI", "OnNumInputEndEdit_SetOffline");
	_gt.BindName(NumInput, "OfflineTime_numInput")	
	
	local ss = GUI.CreateStatic(NumInput, "ss", "分", 160, 0, 200, 60,"system",true)
	GUI.SetColor(ss, UIDefine.Brown4Color)
	GUI.StaticSetFontSize(ss, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(ss, UILayout.Center)
	
	local maxBtn = GUI.ButtonCreate(Text, "maxBtn", "1800402110", 173, 0, Transition.ColorTint, "最大", 90, 48, false);
	GUI.ButtonSetTextColor(maxBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(maxBtn, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(maxBtn, UILayout.Center)
	GUI.RegisterUIEvent(maxBtn, UCE.PointerClick, "StallsUI", "OnMaxBtnClick_SetOffline")


	local cancelBtn = GUI.ButtonCreate(Bg, "cancelBtn", "1800402110", -140, 175, Transition.ColorTint, "取消", 108, 48, false);
	GUI.ButtonSetTextColor(cancelBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(cancelBtn, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(cancelBtn, UILayout.Center)
	GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick, "StallsUI", "OnSetOfflinePanelClose")

	local setBtn = GUI.ButtonCreate(Bg, "setBtn", "1800402110", 140, 175, Transition.ColorTint, "设置", 108, 48, false);
	GUI.ButtonSetTextColor(setBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(setBtn, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(setBtn, UILayout.Center)
	GUI.RegisterUIEvent(setBtn, UCE.PointerClick, "StallsUI", "OnSetTimeBtnClick")
	
	--tips
	local Bg = GUI.ImageCreate(Bg, "Bg", "1800400200", 0, -50, false, 530, 150)
	UILayout.SetSameAnchorAndPivot(Bg, UILayout.Center)	


	local Text = GUI.CreateStatic(Bg, "Text", OfflineTipsText, 0, 10, 480, 150,"system",true)
	GUI.SetColor(Text, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
	GUI.StaticSetAlignment(Text, TextAnchor.UpperLeft)
	
	
end

function StallsUI.OnAddBtnClick_SetOffline()
	
	GUI.OpenWnd("MallUI", StallsUI.OfflineTimeItem)

end

function StallsUI.OnMaxBtnClick_SetOffline()
	local numInput = _gt.GetUI("OfflineTime_numInput")
	local maxTime = math.min(StallsUI.MaxOfflineTime/60,math.floor(CL.GetIntCustomData("Stall_OfflineTimeFree")/60) + math.floor(CL.GetIntCustomData("Stall_OfflineTimeExtra")/60))
	GUI.EditSetTextM(numInput,maxTime)
end

function StallsUI.OnSetTimeBtnClick()
	local numInput = _gt.GetUI("OfflineTime_numInput")
	local num = tonumber(GUI.EditGetTextM(numInput)) or math.floor(StallsUI.OfflineTimeSetUse/60)
	if num then
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "SetOfflineTime",num*60)	
	end
end

function StallsUI.OnNumInputEndEdit_SetOffline()
	local numInput = _gt.GetUI("OfflineTime_numInput")
	local num = tonumber(GUI.EditGetTextM(numInput))
	if num then
		if num > (StallsUI.MaxOfflineTime/60) then
			CL.SendNotify(NOTIFY.ShowBBMsg, "离线摆摊时间不能超过"..(StallsUI.MaxOfflineTime/60).."分钟")
			GUI.EditSetTextM(numInput,StallsUI.MaxOfflineTime/60)
			return
		end
		local maxTime = math.floor(CL.GetIntCustomData("Stall_OfflineTimeFree")/60) + math.floor(CL.GetIntCustomData("Stall_OfflineTimeExtra")/60)
		if num > maxTime then
			GUI.EditSetTextM(numInput,maxTime)
			return
		end
	end
end

function StallsUI.OnSetOfflinePanelClose()
	local panel = _gt.GetUI("setOfflinePanel")
	GUI.Destroy(panel)
end

function StallsUI.OnReportPanelClose()
	local panel = _gt.GetUI("reportPanel")
	GUI.Destroy(panel)

end

function StallsUI.OnSetUpBtnClick()
	if StallsUI.StallStatus == 1  then
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "Start")
	else
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "GetReady")
	end
end

function StallsUI.OnPickUpBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "PackUp")
	StallsUI.OnCloseBtnClick()
end


--售卖道具Scroll
function StallsUI.CreateSellGoodsItem()
	local SellItemScroll = _gt.GetUI("SellItemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(SellItemScroll)
	local SellItem = GUI.ButtonCreate(SellItemScroll, "SellItem" .. curCount, "1800400360", 0, 0, Transition.ColorTint)
	GUI.RegisterUIEvent(SellItem, UCE.PointerClick, "StallsUI", "OnSellGoodsItemClick");
	local Icon = ItemIcon.Create(SellItem, "Icon", -85, 1)
	local Name = GUI.CreateStatic(SellItem, "Name", "", 110, 10, 250, 50)
	GUI.SetColor(Name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Name, UILayout.TopLeft)
	GUI.StaticSetAlignment(Name, TextAnchor.MiddleLeft)
	local CoinBg = GUI.ImageCreate(SellItem, "CoinBg", "1800700010", 110, 20, false, 155, 35)
	UILayout.SetSameAnchorAndPivot(CoinBg, UILayout.Left);
	GUI.SetVisible(CoinBg,false)
	local Coin = GUI.ImageCreate(CoinBg, "Coin", StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "", 0, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left);
	local Price = GUI.CreateStatic(CoinBg, "Price", "", 5, -1, 160, 50)
	GUI.SetColor(Price, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(Price, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(Price, UILayout.Center)
	GUI.StaticSetAlignment(Price, TextAnchor.MiddleCenter)
	return SellItem;
end


function StallsUI.RefreshSellItemScroll(parameter)						--出售页左侧循环列表刷新
	parameter = string.split(parameter, "#")
	local guid = parameter[1]
	local index = tonumber(parameter[2])
	local SellItem = GUI.GetByGuid(guid)
	index = index + 1
	local Icon = GUI.GetChild(SellItem,"Icon")
	local Name = GUI.GetChild(SellItem,"Name")
	local CoinBg = GUI.GetChild(SellItem,"CoinBg")
	local Price = GUI.GetChild(CoinBg,"Price")
	local Coin= GUI.GetChild(Price,"Coin")
	
	local tb = StallsUI.SellList["Item"][index]
	if tb ~= "" then
		tb = string.split(tb,",")
		local itemDB = DB.GetOnceItemByKey1(tb[1])
		GUI.StaticSetText(Name,itemDB.Name)
		GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Icon, itemDB.Icon)
		GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Border, UIDefine.ItemIconBg[itemDB.Grade])
		GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.RightBottomNum, tb[2])
		
		GUI.SetVisible(CoinBg,true)
		GUI.StaticSetText(Price,tb[3])
		GUI.ImageSetImageID(Coin,StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "")
		
		GUI.SetData(SellItem,"index",index)
	else
		GUI.StaticSetText(Name,"")
		ItemIcon.SetEmpty(Icon)
		-- GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Icon,"")
		-- GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Border,"")
		-- GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.RightBottomNum, "")
		
		GUI.SetVisible(CoinBg,false)
		-- GUI.StaticSetText(Price,tb[3])
		GUI.SetData(SellItem,"index",nil)		
	end
end

function StallsUI.OnSellGoodsItemClick(guid)
	if StallsUI.StallStatus ~= 1  then
		CL.SendNotify(NOTIFY.ShowBBMsg,"准备状态下才可以对货物进行操作")
		return
	end
	local index = GUI.GetData(GUI.GetByGuid(guid),"index")
	if index and index ~= "" then
		StallsUI.PreSellItemIndex = tonumber(index)
		StallsUI.PreSellItemGuid = nil
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "DisplayDetail",StallsUI.TargetGuid,1,index)
		StallsUI.ConfirmSellPopup(2)
	end
end


--当前售卖宠物Scroll
function StallsUI.CreateSellPetItem()
	local SellPetScroll = _gt.GetUI("SellPetScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(SellPetScroll)
	local SellPetItem = GUI.ButtonCreate(SellPetScroll, "SellPetItem" .. curCount, "1800700030", 0, 0, Transition.ColorTint)
	GUI.RegisterUIEvent(SellPetItem, UCE.PointerClick, "StallsUI", "OnSellPetItemClick");
	local Icon = ItemIcon.Create(SellPetItem, "Icon", 18, 1)
	UILayout.SetSameAnchorAndPivot(Icon, UILayout.Left)
	local Name = GUI.CreateStatic(SellPetItem, "Name", "", 110, 10, 250, 50)
	GUI.SetColor(Name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Name, UILayout.TopLeft)
	GUI.StaticSetAlignment(Name, TextAnchor.MiddleLeft)
	local CoinBg = GUI.ImageCreate(SellPetItem, "CoinBg", "1800700010", 110, 20, false, 155, 35)
	UILayout.SetSameAnchorAndPivot(CoinBg, UILayout.Left);
	GUI.SetVisible(CoinBg,false)
	local Coin = GUI.ImageCreate(CoinBg, "Coin", StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "", 0, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left);
	local Price = GUI.CreateStatic(CoinBg, "Price", "100", 5, -1, 160, 50)
	GUI.SetColor(Price, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(Price, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(Price, UILayout.Center)
	GUI.StaticSetAlignment(Price, TextAnchor.MiddleCenter)
	local Level = GUI.CreateStatic(SellPetItem, "Level", "", 160, -20, 250, 50)
	GUI.SetColor(Level, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(Level, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Level, UILayout.Center)
	GUI.StaticSetAlignment(Level, TextAnchor.MiddleLeft)
	local FightValue = GUI.CreateStatic(SellPetItem, "FightValue", "", 160, 20, 250, 50)
	GUI.SetColor(FightValue, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(FightValue, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(FightValue, UILayout.Center)
	GUI.StaticSetAlignment(FightValue, TextAnchor.MiddleLeft)
	local PetType = GUI.ImageCreate(SellPetItem, "PetType", "", -25, 0, true, 155, 35)
	UILayout.SetSameAnchorAndPivot(PetType, UILayout.Right)		
	return SellPetItem;
end


function StallsUI.RefreshSellPetScroll(parameter)						--出售页左侧循环列表刷新
	parameter = string.split(parameter, "#")
	local guid = parameter[1]
	local index = tonumber(parameter[2])
	local SellPetItem = GUI.GetByGuid(guid)
	local Icon = GUI.GetChild(SellPetItem,"Icon")
	local Name = GUI.GetChild(SellPetItem,"Name")
	local CoinBg = GUI.GetChild(SellPetItem,"CoinBg")
	local FightValue = GUI.GetChild(SellPetItem,"FightValue")
	local Level = GUI.GetChild(SellPetItem,"Level")
	local Price = GUI.GetChild(CoinBg,"Price")
	local Coin = GUI.GetChild(CoinBg,"Coin")
	local PetType = GUI.GetChild(SellPetItem,"PetType")
	index = index + 1

	local tb = StallsUI.SellList["Pet"][index]
	if tb ~= "" then
		tb = string.split(tb,",")
		local petDB = DB.GetOncePetByKey1(tb[1])
		-- GUI.ItemCtrlSetElementValue(Icon,eItemIconElement.Icon,tostring(petDB.Head))
		ItemIcon.BindPetDB(Icon, petDB)
		
		GUI.StaticSetText(Name,tb[2])
		
		GUI.StaticSetText(Level,"等级："..tb[3])
		
		GUI.StaticSetText(FightValue,"战力："..tb[4])
		
		GUI.StaticSetText(Price,tb[5])
		GUI.ImageSetImageID(Coin,StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "")
		GUI.SetVisible(CoinBg,true)
		
		GUI.SetVisible(PetType,true)
		GUI.ImageSetImageID(PetType,UIDefine.PetType[petDB.Type])
		
		GUI.SetData(SellPetItem,"index",index)
		GUI.SetData(SellPetItem,"price",tb[5])
	else
		-- GUI.ItemCtrlSetElementValue(Icon,eItemIconElement.Icon,"")
		ItemIcon.SetEmpty(Icon)
		
		GUI.StaticSetText(Name,"")
		
		GUI.StaticSetText(Level,"")
		
		GUI.StaticSetText(FightValue,"")
		
		GUI.SetVisible(CoinBg,false)
		-- GUI.StaticSetText(Price,"")
		
		
		GUI.SetVisible(PetType,false)
	
	
		GUI.SetData(SellPetItem,"index",nil)
	end
end

function StallsUI.OnSellPetItemClick(guid)
	if StallsUI.StallStatus ~= 1 then
		CL.SendNotify(NOTIFY.ShowBBMsg,"准备状态下才可以对货物进行操作")
		return
	end
	local index = GUI.GetData(GUI.GetByGuid(guid),"index")
	if index and index ~= "" then
		local price = GUI.GetData(GUI.GetByGuid(guid),"price")
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "DisplayDetail",StallsUI.TargetGuid,2,index)
		GUI.OpenWnd("PetInfoUI")
		PetInfoUI.AdjustForStalls(2,StallsUI.MoneyType,index,price)
	end
end

--我的可售道具
function StallsUI.CreateMyGoodsItem()
	local MyItemScroll = _gt.GetUI("MyItemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(MyItemScroll)
	local Item = ItemIcon.Create(MyItemScroll, "Item", 0, 0)
	GUI.RegisterUIEvent(Item, UCE.PointerClick, "StallsUI", "OnCanSellItemClick");
	return Item;
end

function StallsUI.RefreshMyItemScroll(parameter)				
	parameter = string.split(parameter, "#")
	local guid = parameter[1]
	local index = tonumber(parameter[2])
	local Item = GUI.GetByGuid(guid)
	index = index + 1
	if index <= #StallsUI.MyItemGuidList then
		local itemGuid = StallsUI.MyItemGuidList[index]
		local itemData = LD.GetItemDataByGuid(itemGuid) or LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_gem_bag) or LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_guard_bag)
		ItemIcon.BindItemData(Item, itemData)
		GUI.SetData(Item,"itemGuid",itemGuid)
	else
		ItemIcon.SetEmpty(Item)
		GUI.SetData(Item,"itemGuid","")
	end
end

function StallsUI.OnCanSellItemClick(guid)
	local itemGuid = GUI.GetData(GUI.GetByGuid(guid),"itemGuid")
	if itemGuid and itemGuid ~= "" then
		StallsUI.PreSellItemGuid = itemGuid
		StallsUI.ConfirmSellPopup(1)
	end
end


--我的可售宠物
function StallsUI.CreateMyPetItem()
	local MyPetScroll = _gt.GetUI("MyPetScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(MyPetScroll)
	local PetItem = GUI.ButtonCreate(MyPetScroll, "PetItem" .. curCount, "1800700030", 0, 0, Transition.ColorTint)
	GUI.RegisterUIEvent(PetItem, UCE.PointerClick, "StallsUI", "OnCanSellPetClick");
	local Icon = ItemIcon.Create(PetItem, "Icon", 15, 1)
	UILayout.SetSameAnchorAndPivot(Icon, UILayout.Left)
	local Name = GUI.CreateStatic(PetItem, "Name", "名称", 110, 5, 250, 50)
	GUI.SetColor(Name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Name, UILayout.TopLeft)
	GUI.StaticSetAlignment(Name, TextAnchor.MiddleLeft)
	local Level = GUI.CreateStatic(PetItem, "Level", "等级：0", 25, 18, 250, 50)
	GUI.SetColor(Level, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(Level, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Level, UILayout.Center)
	GUI.StaticSetAlignment(Level, TextAnchor.MiddleLeft)
	local FightValue = GUI.CreateStatic(PetItem, "FightValue", "战力：0", 150, 18, 250, 50)
	GUI.SetColor(FightValue, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(FightValue, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(FightValue, UILayout.Center)
	GUI.StaticSetAlignment(FightValue, TextAnchor.MiddleLeft)
	local PetType = GUI.ImageCreate(PetItem, "PetType", "1800704040", -20, 0, true, 155, 35)
	UILayout.SetSameAnchorAndPivot(PetType, UILayout.Right)		
	
	return PetItem;
end

function StallsUI.RefreshMyPetScroll(parameter)				
	parameter = string.split(parameter, "#")
	local guid = parameter[1]
	local index = tonumber(parameter[2])
	local Item = GUI.GetByGuid(guid)
	local Icon = GUI.GetChild(Item,"Icon")
	local Name = GUI.GetChild(Item,"Name")
	local Level = GUI.GetChild(Item,"Level")
	local FightValue = GUI.GetChild(Item,"FightValue")
	local PetType = GUI.GetChild(Item,"PetType")
	index = index + 1
	
	local petGuid = StallsUI.MyPetGuidList[index]
	local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)))
	local petDB = DB.GetOncePetByKey1(petId)
	
	GUI.SetData(Item,"petGuid",petGuid)
	
	ItemIcon.BindPetId(Icon, petId)
	
	GUI.StaticSetText(Name,LD.GetPetName(petGuid))
	
	GUI.StaticSetText(Level,"等级："..UIDefine.GetPetLevelStrByGuid(petGuid))
	
	GUI.StaticSetText(FightValue,"战力："..tostring(LD.GetPetAttr(RoleAttr.RoleAttrFightValue,petGuid)))
	
	GUI.ImageSetImageID(PetType,UIDefine.PetType[petDB.Type])
end

function StallsUI.OnCanSellPetClick(guid)
	local petGuid = GUI.GetData(GUI.GetByGuid(guid),"petGuid")
	GUI.OpenWnd("PetInfoUI","2,"..petGuid)
	PetInfoUI.AdjustForStalls(1,StallsUI.MoneyType)

end



--切换售卖道具/宠物
function StallsUI.OnTabBtnClick(guid)
	local index = tonumber(GUI.GetData(GUI.GetByGuid(guid),"index"))
	
	StallsUI.tabIndex = index
	
	--刷新页签高亮
	StallsUI.RefreshSellPageTab()
	
	StallsUI.RefreshSellPage()
end

--刷新页签高亮
function StallsUI.RefreshSellPageTab()
	local Sprite_1 = _gt.GetUI("TabBtnSprite_1")
	local Sprite_2 = _gt.GetUI("TabBtnSprite_2")
	
	GUI.SetVisible(Sprite_1,StallsUI.tabIndex == 1)
	GUI.SetVisible(Sprite_2,StallsUI.tabIndex == 2)
	
end



--出售定价页面
function StallsUI.CreateSellPopup(Panel)
	local SellPopup = GUI.GroupCreate(Panel, "SellPopup", 0, 0, 0,0)
	_gt.BindName(SellPopup,"SellPopup")
	GUI.SetVisible(SellPopup,false)
	local wnd = GUI.GetWnd("StallsUI")
	local Shadow = GUI.ImageCreate(SellPopup, "Shadow", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
	GUI.SetIsRaycastTarget(Shadow, true)

	local Bg = GUI.ImageCreate(SellPopup, "Bg", "1800900010", 0, -15, false, 380, 500);
	local CloseBtn = GUI.ButtonCreate(Bg, "CloseBtn", "1800302120", 2, -2, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(CloseBtn, UILayout.TopRight)
	GUI.RegisterUIEvent(CloseBtn, UCE.PointerClick, "StallsUI", "OnSellPopupClose")
	
	local TitleBg = GUI.ImageCreate(Bg, "TitleBg", "1800001140", 0, 20, false, 230, 40);
	UILayout.SetSameAnchorAndPivot(TitleBg, UILayout.Top);
	
	local Title = GUI.CreateStatic(TitleBg, "Title", "上架确认", 0, 1, 100, 30);
	GUI.SetColor(Title, UIDefine.White2Color);
	GUI.StaticSetFontSize(Title, UIDefine.FontSizeL);
	GUI.StaticSetAlignment(Title, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(Title, UILayout.Center)
	_gt.BindName(Title, "SellPopup_title")
	
	
	local ItemBg = GUI.ImageCreate(Bg, "ItemBg", "1800400200", 0, 72, false, 345, 120);
	UILayout.SetSameAnchorAndPivot(ItemBg, UILayout.Top)
	
	local ItemInfo = GUI.ButtonCreate(ItemBg, "ItemInfo", "1800400360", 0, 0, Transition.ColorTint, "", 325, 100, false);
	UILayout.SetSameAnchorAndPivot(ItemInfo, UILayout.Center);
	GUI.RegisterUIEvent(ItemInfo, UCE.PointerClick, "StallsUI", "OnItemClick_SellPopup");
	-- _gt.BindName(ItemInfo, "SellPopup_ItemInfo")
	
	local Icon = ItemIcon.Create(ItemInfo, "Icon", -105, 1);
	_gt.BindName(Icon, "SellPopup_ItemIcon")
		
	local Name = GUI.CreateStatic(ItemInfo, "Name", "名字", 110, -20, 200, 30);
	GUI.StaticSetFontSize(Name, UIDefine.FontSizeM)
	GUI.SetColor(Name, UIDefine.BrownColor)
	UILayout.SetSameAnchorAndPivot(Name, UILayout.Left)
	GUI.StaticSetAlignment(Name, TextAnchor.MiddleLeft)
	_gt.BindName(Name, "SellPopup_Name")
	
	local Level = GUI.CreateStatic(ItemInfo, "Level", "等级：", 110, 15, 200, 30);
	GUI.StaticSetFontSize(Level, UIDefine.FontSizeM)
	GUI.SetColor(Level, UIDefine.Yellow2Color)
	UILayout.SetSameAnchorAndPivot(Level, UILayout.Left)
	GUI.StaticSetAlignment(Level, TextAnchor.MiddleLeft)
	_gt.BindName(Level, "SellPopup_Level")
	
	local Text = GUI.CreateStatic(Bg, "Text", "数量", 40, 210, 100, 30);
	GUI.SetColor(Text, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.TopLeft);
	
	local MinusBtn = GUI.ButtonCreate(Bg, "MinusBtn", "1800402140", -60, 200, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(MinusBtn, UILayout.Top);
	MinusBtn:RegisterEvent(UCE.PointerUp)
	MinusBtn:RegisterEvent(UCE.PointerDown)
	GUI.RegisterUIEvent(MinusBtn, UCE.PointerDown, "StallsUI", "OnNumMinusBtnDown")
	GUI.RegisterUIEvent(MinusBtn, UCE.PointerUp, "StallsUI", "OnNumMinusBtnUp")
	_gt.BindName(MinusBtn, "SellPopup_numMinusBtn")
	
	local NumInput = GUI.EditCreate(Bg, "NumInput", "1800400390", "1", 38, 202, Transition.ColorTint, "system", 0, 0, 8, 8, InputType.Standard, ContentType.IntegerNumber)
	UILayout.SetSameAnchorAndPivot(NumInput, UILayout.Top);
	GUI.EditSetLabelAlignment(NumInput, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(NumInput, UIDefine.BrownColor)
	GUI.EditSetFontSize(NumInput, UIDefine.FontSizeM)
	GUI.EditSetMaxCharNum(NumInput, 4);
	GUI.RegisterUIEvent(NumInput, UCE.EndEdit, "StallsUI", "OnNumInputEndEdit");
	_gt.BindName(NumInput, "SellPopup_numInput")
	
	local AddBtn = GUI.ButtonCreate(Bg, "AddBtn", "1800402150", 135, 200, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(AddBtn, UILayout.Top);
	AddBtn:RegisterEvent(UCE.PointerUp)
	AddBtn:RegisterEvent(UCE.PointerDown)
	GUI.RegisterUIEvent(AddBtn, UCE.PointerDown, "StallsUI", "OnNumAddBtnDown")
	GUI.RegisterUIEvent(AddBtn, UCE.PointerUp, "StallsUI", "OnNumAddBtnUp")
	_gt.BindName(AddBtn, "SellPopup_numAddBtn")
	
	
	local Text = GUI.CreateStatic(Bg, "Text", "单价", 40, 275, 100, 30);
	GUI.SetColor(Text, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.TopLeft);
	
	local PriceInput = GUI.EditCreate(Bg, "PriceInput", "1800400390", "1", 40, 270, Transition.ColorTint, "system", 250, 44, 8, 8, InputType.Standard, ContentType.IntegerNumber)
	UILayout.SetSameAnchorAndPivot(PriceInput, UILayout.Top);
	GUI.EditSetLabelAlignment(PriceInput, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(PriceInput, UIDefine.BrownColor)
	GUI.EditSetFontSize(PriceInput, UIDefine.FontSizeM)
	GUI.EditSetMaxCharNum(PriceInput, 9);
	-- GUI.RegisterUIEvent(PriceInput, UCE.PointerClick, "StallsUI", "OnPriceInputClick")
	_gt.BindName(PriceInput, "SellPopup_priceInput")
	GUI.RegisterUIEvent(PriceInput, UCE.EndEdit, "StallsUI", "OnPriceInputEndEdit")
	local Coin = GUI.ImageCreate(PriceInput, "Coin", StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "", 5, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left)
	
	local logo = GUI.ImageCreate(PriceInput, "logo", "1800402120", -2, 0, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(logo, UILayout.Right);	

	local Text = GUI.CreateStatic(Bg, "Text", "总价", 40, 340, 150, 30)
	GUI.SetColor(Text, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.TopLeft)
	
	local TotalPriceBg = GUI.ImageCreate(Bg, "TotalPriceBg", "1800700010", 40, 335, false, 245, 44)
	UILayout.SetSameAnchorAndPivot(TotalPriceBg, UILayout.Top);
	local Coin = GUI.ImageCreate(TotalPriceBg, "Coin", StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "", 2, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left)
	local Num = GUI.CreateStatic(TotalPriceBg, "Num", "100", 5, -1, 240, 30)
	GUI.SetColor(Num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(Num, UIDefine.FontSizeM)
	GUI.SetAnchor(Num, UIAnchor.Center)
	GUI.SetPivot(Num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(Num, TextAnchor.MiddleCenter)
	_gt.BindName(Num, "SellPopup_totalPrice")
	
	--下架数量
	local NumBg = GUI.ImageCreate(Bg, "NumBg", "1800700010", 40, 202, false, 245, 44)
	UILayout.SetSameAnchorAndPivot(NumBg, UILayout.Top);
	local Lable = GUI.CreateStatic(NumBg, "Lable", "1", 5, -1, 240, 30)
	GUI.SetColor(Lable, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(Lable, UIDefine.FontSizeM)
	GUI.SetAnchor(Lable, UIAnchor.Center)
	GUI.SetPivot(Lable, UIAroundPivot.Center)
	GUI.StaticSetAlignment(Lable, TextAnchor.MiddleCenter)
	_gt.BindName(NumBg, "SellPopup_Num2")	

	
	--下架单价
	local PriceBg = GUI.ImageCreate(Bg, "PriceBg", "1800700010", 40, 270, false, 245, 44)
	UILayout.SetSameAnchorAndPivot(PriceBg, UILayout.Top)
	local Coin = GUI.ImageCreate(PriceBg, "Coin", StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "", 2, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left)
	local Lable = GUI.CreateStatic(PriceBg, "Lable", "1", 5, -1, 240, 30)
	GUI.SetColor(Lable, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(Lable, UIDefine.FontSizeM)
	GUI.SetAnchor(Lable, UIAnchor.Center)
	GUI.SetPivot(Lable, UIAroundPivot.Center)
	GUI.StaticSetAlignment(Lable, TextAnchor.MiddleCenter)
	_gt.BindName(PriceBg, "SellPopup_Price2")
	

	local ConfirmBtn = GUI.ButtonCreate(Bg, "ConfirmBtn", "1800402110", 90, 190, Transition.ColorTint, "上架", 115, 50, false)
	GUI.ButtonSetTextFontSize(ConfirmBtn, UIDefine.FontSizeL)
	GUI.ButtonSetTextColor(ConfirmBtn, UIDefine.BrownColor)
	GUI.RegisterUIEvent(ConfirmBtn, UCE.PointerClick, "StallsUI", "OnItemGoodsSale")
	UILayout.SetSameAnchorAndPivot(ConfirmBtn, UILayout.Center)
	_gt.BindName(ConfirmBtn, "SellPopup_confirmBtn")	
	
	local retrieveBtn = GUI.ButtonCreate(Bg, "retrieveBtn", "1800402110", 90, 190, Transition.ColorTint, "下架", 115, 50, false)
	GUI.ButtonSetTextFontSize(retrieveBtn, UIDefine.FontSizeL)
	GUI.ButtonSetTextColor(retrieveBtn, UIDefine.BrownColor)
	GUI.RegisterUIEvent(retrieveBtn, UCE.PointerClick, "StallsUI", "OnItemGoodsRetrieve")
	UILayout.SetSameAnchorAndPivot(retrieveBtn, UILayout.Center)
	_gt.BindName(retrieveBtn, "SellPopup_retrieveBtn")	
	
	local CancelBtn = GUI.ButtonCreate(Bg, "CancelBtn", "1800402110", -90, 190, Transition.ColorTint, "取消", 115, 50, false)
	GUI.ButtonSetTextFontSize(CancelBtn, UIDefine.FontSizeL)
	GUI.ButtonSetTextColor(CancelBtn, UIDefine.BrownColor)
	GUI.RegisterUIEvent(CancelBtn, UCE.PointerClick, "StallsUI", "OnSellPopupClose")
	UILayout.SetSameAnchorAndPivot(CancelBtn, UILayout.Center)
end

function StallsUI.OnItemClick_SellPopup()
	local panel = _gt.GetUI("SellPopup")
	local itemData = LD.GetQueryItemData()
	if StallsUI.PreSellItemGuid then
		itemData = LD.GetItemDataByGuid(StallsUI.PreSellItemGuid) or LD.GetItemDataByGuid(StallsUI.PreSellItemGuid, item_container_type.item_container_gem_bag) or LD.GetItemDataByGuid(StallsUI.PreSellItemGuid, item_container_type.item_container_guard_bag)
	end
	Tips.CreateByItemData(itemData, panel, "itemTips", 390, -45)
end

--上架
function StallsUI.OnItemGoodsSale()
	if StallsUI.PreSellItemGuid and StallsUI.PreSellAmount and StallsUI.PreSellPrice then
		if StallsUI.StallStatus ~= 1  then
			CL.SendNotify(NOTIFY.ShowBBMsg,"当前不在准备状态下无法进行上架操作")
			return
		end		
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "Listing",1,StallsUI.PreSellItemGuid,StallsUI.PreSellAmount,StallsUI.PreSellPrice)
	end
end

--下架

function StallsUI.OnItemGoodsRetrieve()
	if StallsUI.PreSellItemIndex then
		-- if StallsUI.StallStatus == 1 then
			-- CL.SendNotify(NOTIFY.ShowBBMsg,"摆摊状态下无法进行下架操作")
			-- return
		-- end		
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "Retrieve",1,StallsUI.PreSellItemIndex)
	end
end

function StallsUI.ConfirmSellPopup(state)
	--state 1为上架 2为下
	local confirmBtn = _gt.GetUI("SellPopup_confirmBtn")
	local priceInput = _gt.GetUI("SellPopup_priceInput")
	local numAddBtn = _gt.GetUI("SellPopup_numAddBtn")
	local numMinusBtn = _gt.GetUI("SellPopup_numMinusBtn")
	local numInput = _gt.GetUI("SellPopup_numInput")
	local num2 = _gt.GetUI("SellPopup_Num2")
	local price2 = _gt.GetUI("SellPopup_Price2")
	local retrieveBtn = _gt.GetUI("SellPopup_retrieveBtn")
	local title = _gt.GetUI("SellPopup_title")
	

	local Icon = _gt.GetUI("SellPopup_ItemIcon")
	local Name = _gt.GetUI("SellPopup_Name")
	local Level = _gt.GetUI("SellPopup_Level")
	
	--刷新商品信息
	local id
	if state == 1 then
		local itemGuid = StallsUI.PreSellItemGuid
		local itemData = LD.GetItemDataByGuid(itemGuid) or LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_gem_bag) or LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_guard_bag)
		id = itemData.id
		--预售价格及数量
		StallsUI.PreSellPrice = 1
		StallsUI.PreSellAmount = 1 		
		StallsUI.MaxAmount = tonumber(itemData:GetAttr(ItemAttr_Native.Amount))
		GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.RightBottomNum, StallsUI.MaxAmount)
		
		StallsUI.UpdateAmountPrice()
		GUI.StaticSetText(title,"上架确认")

	elseif state == 2 then
		local tb = StallsUI.SellList["Item"][StallsUI.PreSellItemIndex]
		tb = string.split(tb,",")
		id = tb[1]
		-- test(StallsUI.PreSellItemIndex)
		GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.RightBottomNum, 0)
		--数量
		GUI.StaticSetText(GUI.GetChild(num2,"Lable"),tb[2])
		--单价
		GUI.StaticSetText(GUI.GetChild(price2,"Lable"),tb[3])
		
		local totalPrice = _gt.GetUI("SellPopup_totalPrice")
		GUI.StaticSetText(totalPrice,tb[2]*tb[3])
		GUI.StaticSetText(title,"下架确认")
	end
	--基础信息
	local itemDB = DB.GetOnceItemByKey1(id)
	GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Border, UIDefine.ItemIconBg[itemDB.Grade])
	GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Icon, itemDB.Icon)	
	
	GUI.StaticSetText(Name,itemDB.Name)
	GUI.StaticSetText(Level,"等级："..itemDB.Level)

	--显示
	GUI.SetVisible(confirmBtn,state == 1)
	GUI.SetVisible(priceInput,state == 1)
	GUI.SetVisible(numAddBtn,state == 1)
	GUI.SetVisible(numMinusBtn,state == 1)
	GUI.SetVisible(numInput,state == 1)
	GUI.SetVisible(num2,state == 2)
	GUI.SetVisible(price2,state == 2)	
	GUI.SetVisible(retrieveBtn,state == 2)
	
	local SellPopup  = _gt.GetUI("SellPopup")
	GUI.SetVisible(SellPopup,true)	
	
end


function StallsUI.OnNumAddBtnDown()
	local fun = function()
		StallsUI.PreSellAmount = StallsUI.PreSellAmount + 1
		StallsUI.UpdateAmountPrice()
	end
	if StallsUI.AmountTimer == nil then
		StallsUI.AmountTimer = Timer.New(fun, 0.15, -1)
	else
		StallsUI.AmountTimer:Stop()
		StallsUI.AmountTimer:Reset(fun, 0.15, -1)
	end
	StallsUI.AmountTimer:Start()
	fun()
end

function StallsUI.OnNumAddBtnUp()
	if StallsUI.AmountTimer ~= nil then
		StallsUI.AmountTimer:Stop()
		StallsUI.AmountTimer = nil;
	end
end

function StallsUI.OnNumMinusBtnDown()
	local fun = function()
		StallsUI.PreSellAmount = StallsUI.PreSellAmount - 1;
		StallsUI.UpdateAmountPrice();
	end

	if StallsUI.AmountTimer == nil then
		StallsUI.AmountTimer = Timer.New(fun, 0.15, -1)
	else
		StallsUI.AmountTimer:Stop();
		StallsUI.AmountTimer:Reset(fun, 0.15, -1)
	end
	StallsUI.AmountTimer:Start();
	fun();
end

function StallsUI.OnNumMinusBtnUp()
	if StallsUI.AmountTimer ~= nil then
		StallsUI.AmountTimer:Stop()
		StallsUI.AmountTimer = nil;
	end
end

function StallsUI.OnPriceInputEndEdit()
	local PriceInput = _gt.GetUI("SellPopup_priceInput")
	local Price = GUI.EditGetTextM(PriceInput)
	if Price == "" or tonumber(Price) == 0 then
		StallsUI.PreSellPrice = 1
	else
		StallsUI.PreSellPrice = Price
	end
	
	StallsUI.UpdateAmountPrice()
	

end

function StallsUI.OnNumInputEndEdit()
	-- test("OnNumInputEndEdit")
	local NumInput = _gt.GetUI("SellPopup_numInput")
	local Number = GUI.EditGetTextM(NumInput)
	if Number == "" or tonumber(Number) == 0 then
		StallsUI.PreSellAmount = 1
	else
		StallsUI.PreSellAmount = tonumber(Number)
	end
	StallsUI.UpdateAmountPrice()

end

function StallsUI.UpdateAmountPrice()
	local NumInput = _gt.GetUI("SellPopup_numInput")
	local PriceInput = _gt.GetUI("SellPopup_priceInput")
	
	
	local MaxAmount = StallsUI.MaxAmount
	StallsUI.PreSellAmount = math.min(StallsUI.PreSellAmount,MaxAmount)
	StallsUI.PreSellAmount = math.max(StallsUI.PreSellAmount,1)
	
	local MaxPrice = StallsUI.MaxPrice
	StallsUI.PreSellPrice = math.min(StallsUI.PreSellPrice,MaxPrice)
	
	GUI.EditSetTextM(NumInput,StallsUI.PreSellAmount)
	GUI.EditSetTextM(PriceInput,StallsUI.PreSellPrice)
	
	--总价
	local NumText = _gt.GetUI("SellPopup_totalPrice")
	GUI.StaticSetText(NumText,StallsUI.PreSellAmount*StallsUI.PreSellPrice)

end

function StallsUI.OnSellPopupClose()
	local SellPopup  = _gt.GetUI("SellPopup")
	GUI.SetVisible(SellPopup,false)
	
	--预售价格及数量
	-- StallsUI.PreSellPrice = 1
	-- StallsUI.PreSellAmount = 1 


end

function StallsUI.SetGoodsDB()


end

-----------------------------------------------------------摆摊购买页---------------------------------------------------------------------

function StallsUI.CreateBuyPage(Panel)
	if not Panel then
		return
	end
	--上方摊位信息
    local AttentionToggle = GUI.CheckBoxCreate(Panel,"AttentionToggle", "1800607150", "1800607151", 110, 80,Transition.ColorTint, false)
	SetAnchorAndPivot(AttentionToggle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)	
	_gt.BindName(AttentionToggle,"AttentionToggle")
	GUI.RegisterUIEvent(AttentionToggle, UCE.PointerClick, "StallsUI", "OnAttentionToggleClick")
	
	local Text = GUI.CreateStatic(AttentionToggle, "Text", "关注本摊", 120, 0, 200, 50)
	GUI.SetColor(Text, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)

	
	--摊主
	local Text = GUI.CreateStatic(Panel, "Text", "摊主名称", -318, 55, 200, 50)
	GUI.SetColor(Text, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.TopRight)
	
	local Bg = GUI.ImageCreate(Text, "OwnerNameBg", "1800700010", -85, 9, false, 180, 32)
	local StallOwnerName = GUI.CreateStatic(Bg, "StallOwnerName", "", 0, -1, 200, 50)
	GUI.SetColor(StallOwnerName, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(StallOwnerName, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(StallOwnerName, UILayout.Center)
	GUI.StaticSetAlignment(StallOwnerName, TextAnchor.MiddleCenter)
	_gt.BindName(StallOwnerName,"StallOwnerName")

	local ContactBtn = GUI.ButtonCreate(Text, "ContactBtn", "1800402110", -270, 0, Transition.ColorTint, "联系摊主", 138, 45, false);
	GUI.ButtonSetTextColor(ContactBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(ContactBtn, UIDefine.FontSizeM)	
	UILayout.SetSameAnchorAndPivot(ContactBtn, UILayout.Center)
	GUI.RegisterUIEvent(ContactBtn, UCE.PointerClick, "StallsUI", "OnContactBtnClick")
	
	--道具商品页
	local BuyPage_Item = GUI.GroupCreate(Panel, "BuyPage_Item", 0, 0, 0,0)
	_gt.BindName(BuyPage_Item,"BuyPage_Item")
	GUI.SetVisible(BuyPage_Item,false)
	
	local LeftBg = GUI.ImageCreate(BuyPage_Item, "LeftBg", "1800400200", -205, 30, false, 630, 510)
	UILayout.SetSameAnchorAndPivot(LeftBg, UILayout.Center)
	
	local ItemInfoBg = GUI.ImageCreate(BuyPage_Item, "ItemInfoBg", "1800400200", 330, -80, false, 380, 290)
	UILayout.SetSameAnchorAndPivot(ItemInfoBg, UILayout.Center)
	StallsUI.CreateItemInfoPanel(ItemInfoBg)
	_gt.BindName(ItemInfoBg,"ItemInfo_BuyPage")

	--道具列表
	local BuyPage_ItemGoodsScroll = GUI.LoopScrollRectCreate(LeftBg, "BuyPage_ItemGoodsScroll", 0, 0, 610, 490,"StallsUI", "CreateGoodsItem_BuyPage", "StallsUI", "RefreshItemScroll_BuyPage", 0, false, Vector2.New(305, 110), 2, UIAroundPivot.Top, UIAnchor.Top)
	UILayout.SetSameAnchorAndPivot(BuyPage_ItemGoodsScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(BuyPage_ItemGoodsScroll, Vector2.New(4, 3))
	_gt.BindName(BuyPage_ItemGoodsScroll,"BuyPage_ItemGoodsScroll")	

	-- GUI.LoopScrollRectSetTotalCount(BuyPage_ItemGoodsScroll, 15) 
	-- GUI.LoopScrollRectRefreshCells(BuyPage_ItemGoodsScroll)	
	
	--数量
	local Text = GUI.CreateStatic(BuyPage_Item, "Text", "数量", 230, 95, 150, 50);
	GUI.SetColor(Text, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeXL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Center);
	
	local MinusBtn = GUI.ButtonCreate(BuyPage_Item, "MinusBtn", "1800402140", 255, 95, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(MinusBtn, UILayout.Center);
	MinusBtn:RegisterEvent(UCE.PointerUp)
	MinusBtn:RegisterEvent(UCE.PointerDown)
	GUI.RegisterUIEvent(MinusBtn, UCE.PointerDown, "StallsUI", "OnNumMinusBtnDown_BuyPage")
	GUI.RegisterUIEvent(MinusBtn, UCE.PointerUp, "StallsUI", "OnNumMinusBtnUp_BuyPage")
	_gt.BindName(MinusBtn, "BuyPage_numMinusBtn")
	
	local NumInput = GUI.EditCreate(BuyPage_Item, "NumInput", "1800400390", "", 355, 95, Transition.ColorTint, "system", 126, 47, 8, 8, InputType.Standard, ContentType.IntegerNumber)
	UILayout.SetSameAnchorAndPivot(NumInput, UILayout.Center);
	GUI.EditSetLabelAlignment(NumInput, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(NumInput, UIDefine.BrownColor)
	GUI.EditSetFontSize(NumInput, UIDefine.FontSizeL)
	GUI.EditSetMaxCharNum(NumInput, 3);
	GUI.RegisterUIEvent(NumInput, UCE.EndEdit, "StallsUI", "OnNumInputEndEdit_BuyPage");
	_gt.BindName(NumInput, "BuyPage_numInput")
	GUI.EditSetTextM(NumInput, "1")
	
	local AddBtn = GUI.ButtonCreate(BuyPage_Item, "AddBtn", "1800402150", 455, 95, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(AddBtn, UILayout.Center);
	AddBtn:RegisterEvent(UCE.PointerUp)
	AddBtn:RegisterEvent(UCE.PointerDown)
	GUI.RegisterUIEvent(AddBtn, UCE.PointerDown, "StallsUI", "OnNumAddBtnDown_BuyPage")
	GUI.RegisterUIEvent(AddBtn, UCE.PointerUp, "StallsUI", "OnNumAddBtnUp_BuyPage")
	_gt.BindName(AddBtn, "BuyPage_numAddBtn")	
	
	
	--花费
	local Text = GUI.CreateStatic(BuyPage_Item, "Text", "花费", 230, 150, 150, 50)
	GUI.SetColor(Text, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeXL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
	
	local Bg = GUI.ImageCreate(BuyPage_Item, "Bg", "1800700010", 360, 150, false, 260, 40)
	UILayout.SetSameAnchorAndPivot(Bg, UILayout.Center);
	local Coin = GUI.ImageCreate(Bg, "Coin",UIDefine.GetMoneyIcon(1), 2, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left)
	local Num = GUI.CreateStatic(Bg, "Num", "100", 5, -1, 240, 30)
	GUI.SetColor(Num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(Num, UIDefine.FontSizeL)
	GUI.SetAnchor(Num, UIAnchor.Center)
	GUI.SetPivot(Num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(Num, TextAnchor.MiddleCenter)
	_gt.BindName(Num, "BuyPage_totalPrice")
	
	--拥有
	local Text = GUI.CreateStatic(BuyPage_Item, "Text", "拥有", 230, 205, 150, 50)
	GUI.SetColor(Text, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Text, UIDefine.FontSizeXL)
	UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
	
	local Bg = GUI.ImageCreate(BuyPage_Item, "Bg", "1800700010", 360, 205, false, 260, 40)
	UILayout.SetSameAnchorAndPivot(Bg, UILayout.Center);
	local Coin = GUI.ImageCreate(Bg, "Coin",UIDefine.GetMoneyIcon(1), 2, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left)
	local Num = GUI.CreateStatic(Bg, "Num", "100", 5, -1, 240, 30)
	GUI.SetColor(Num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(Num, UIDefine.FontSizeL)
	GUI.SetAnchor(Num, UIAnchor.Center)
	GUI.SetPivot(Num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(Num, TextAnchor.MiddleCenter)
	_gt.BindName(Num, "coinNum_BuyPage")
	
	--刷新
	local RefreshBtn = GUI.ButtonCreate( BuyPage_Item, "RefreshBtn", "1800402080", 230, 285, Transition.ColorTint, "")
    SetAnchorAndPivot(RefreshBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.RegisterUIEvent(RefreshBtn, UCE.PointerClick, "StallsUI", "OnRefreshBtnClick")
	-- _gt.BindName(RefreshBtn,"RefreshBtn")

    local RefreshBtnText = GUI.CreateStatic( RefreshBtn, "RefreshBtnText", "刷新", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(RefreshBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(RefreshBtnText, 26)
    GUI.StaticSetAlignment(RefreshBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(RefreshBtnText, true)
    GUI.SetOutLine_Color(RefreshBtnText, Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(RefreshBtnText, 1)
	
	--购买
	local BuyBtn = GUI.ButtonCreate( BuyPage_Item, "BuyBtn", "1800402080", 430, 285, Transition.ColorTint, "")
    SetAnchorAndPivot(BuyBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.RegisterUIEvent(BuyBtn, UCE.PointerClick, "StallsUI", "OnBuyBtnClick")

    local BuyBtnText = GUI.CreateStatic( BuyBtn, "BuyBtnText", "购买", 0, 0, 160, 47, "system", true)
    SetAnchorAndPivot(BuyBtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(BuyBtnText, 26)
    GUI.StaticSetAlignment(BuyBtnText, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(BuyBtnText, true)
    GUI.SetOutLine_Color(BuyBtnText, Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
    GUI.SetOutLine_Distance(BuyBtnText, 1)
	
	
	--购买宠物页
	local BuyPage_Pet = GUI.GroupCreate(Panel, "BuyPage_Pet", 0, 0, 0,0)
	_gt.BindName(BuyPage_Pet,"BuyPage_Pet")
	
	local Bg = GUI.ImageCreate(BuyPage_Pet, "Bg", "1800400200", 0, 30, false, 1040, 510)
	UILayout.SetSameAnchorAndPivot(Bg, UILayout.Center)
	
	
	--宠物列表
	local BuyPage_PetGoodsScroll = GUI.LoopScrollRectCreate(Bg, "BuyPage_PetGoodsScroll", 0, 0, 1040, 490,"StallsUI", "CreatePetItem_BuyPage", "StallsUI", "RefreshPetScroll_BuyPage", 0, false, Vector2.New(510, 110), 2, UIAroundPivot.Top, UIAnchor.Top)
	UILayout.SetSameAnchorAndPivot(BuyPage_PetGoodsScroll, UILayout.Center)
	GUI.ScrollRectSetChildSpacing(BuyPage_PetGoodsScroll, Vector2.New(4, 3))
	_gt.BindName(BuyPage_PetGoodsScroll,"BuyPage_PetGoodsScroll")	

end

--联系摊主
function StallsUI.OnContactBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm,"FormContact","AddStrangerList",StallsUI.TargetGuid)
	GUI.OpenWnd("FriendUI",StallsUI.TargetGuid)
end
--点击关注
function StallsUI.OnAttentionToggleClick()
	-- test("1aaaaa11")
	local Toggle = _gt.GetUI("AttentionToggle")
	if not StallsUI.AttentionList then
		StallsUI.AttentionList = {}
	end
	-- test(GUI.CheckBoxGetCheck(Toggle))
	StallsUI.AttentionList[StallsUI.TargetGuid] = GUI.CheckBoxGetCheck(Toggle)
	-- StallsUI.RefreshAttention()
	MainUI.SetStallSignboards(StallsUI.TargetGuid)
end

function StallsUI.RefreshOwnerName()
	local StallOwnerName = _gt.GetUI("StallOwnerName")
	GUI.StaticSetText(StallOwnerName,StallsUI.OwnerName)
end

function StallsUI.OnBuyBtnClick()
	if StallsUI.ItemGoodsIndex and StallsUI.PreBuyAmount then
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "Buy",StallsUI.TargetGuid,1,StallsUI.ItemGoodsIndex,StallsUI.PreBuyAmount)
	end


end

function StallsUI.OnRefreshBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "Display",StallsUI.TargetGuid)
end

function StallsUI.CreateGoodsItem_BuyPage()
	local Scroll = _gt.GetUI("BuyPage_ItemGoodsScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(Scroll)
	local GoodsItem = GUI.ButtonCreate(Scroll, "GoodsItem" .. curCount, "1800400360", 0, 0, Transition.ColorTint)
	GUI.RegisterUIEvent(GoodsItem, UCE.PointerClick, "StallsUI", "OnItemGoodsClick_BuyPage");
	local Icon = ItemIcon.Create(GoodsItem, "Icon", -85, 1)
	local Name = GUI.CreateStatic(GoodsItem, "Name", "", 110, 10, 250, 50)
	GUI.SetColor(Name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Name, UILayout.TopLeft)
	GUI.StaticSetAlignment(Name, TextAnchor.MiddleLeft)
	local CoinBg = GUI.ImageCreate(GoodsItem, "CoinBg", "1800700010", 110, 20, false, 155, 35)
	UILayout.SetSameAnchorAndPivot(CoinBg, UILayout.Left);
	GUI.SetVisible(CoinBg,false)
	local Coin = GUI.ImageCreate(CoinBg, "Coin", StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "", 0, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left);
	local Price = GUI.CreateStatic(CoinBg, "Price", "", 5, -1, 160, 50)
	GUI.SetColor(Price, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(Price, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(Price, UILayout.Center)
	GUI.StaticSetAlignment(Price, TextAnchor.MiddleCenter)
	return GoodsItem;
end


function StallsUI.RefreshItemScroll_BuyPage(parameter)						
	parameter = string.split(parameter, "#")
	local guid = parameter[1]
	local index = tonumber(parameter[2])
	local GoodsItem = GUI.GetByGuid(guid)
	local Icon = GUI.GetChild(GoodsItem,"Icon")
	local Name = GUI.GetChild(GoodsItem,"Name")
	local CoinBg = GUI.GetChild(GoodsItem,"CoinBg")
	local Price = GUI.GetChild(CoinBg,"Price")
	local Coin= GUI.GetChild(Price,"Coin")
	index = index + 1
	
	GUI.ButtonSetImageID(GoodsItem, "1800400360")
	local tb = StallsUI.SellList["Item"][index]
	if tb ~= "" then
		tb = string.split(tb,",")
		local itemDB = DB.GetOnceItemByKey1(tb[1])
		GUI.StaticSetText(Name,itemDB.Name)
		GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Icon, itemDB.Icon)
		GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.RightBottomNum, tb[2])
		
		GUI.SetVisible(CoinBg,true)
		GUI.StaticSetText(Price,tb[3])
		GUI.ImageSetImageID(Coin,StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "")
		
		GUI.SetData(GoodsItem,"index",index)
		
		if not StallsUI.ItemGoodsIndex or StallsUI.ItemGoodsIndex == index then
			StallsUI.ItemGoodsIndex = index
			StallsUI.LastItemGuid = guid
			GUI.ButtonSetImageID(GoodsItem, "1800400361")
			StallsUI.RefreshItemInfoPanel()
		end
	else
		GUI.StaticSetText(Name,"")
		GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.Icon,"")
		GUI.ItemCtrlSetElementValue(Icon, eItemIconElement.RightBottomNum, "")
		
		GUI.SetVisible(CoinBg,false)
		GUI.SetData(GoodsItem,"index",nil)
		
		if StallsUI.ItemGoodsIndex and StallsUI.ItemGoodsIndex == index then
			StallsUI.ItemGoodsIndex = nil
			StallsUI.LastItemGuid = nil	
			StallsUI.RefreshItemInfoPanel()
		end
	end
end

function StallsUI.OnItemGoodsClick_BuyPage(guid)
	local item = GUI.GetByGuid(guid)
	local index = tonumber(GUI.GetData(item,"index"))
	if index then
		if not StallsUI.ItemGoodsIndex or StallsUI.ItemGoodsIndex ~= index then
			if StallsUI.LastItemGuid then
				local item = GUI.GetByGuid(StallsUI.LastItemGuid)
				GUI.ButtonSetImageID(item, "1800400360")
			end
			
			GUI.ButtonSetImageID(item, "1800400361")
			StallsUI.LastItemGuid = guid
			StallsUI.ItemGoodsIndex = index
			--刷新信息
			StallsUI.RefreshItemInfoPanel()
		end
	end

	
end


function StallsUI.CreatePetItem_BuyPage()
	local Scroll = _gt.GetUI("BuyPage_PetGoodsScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(Scroll)
	local PetGoodsItem = GUI.ButtonCreate(Scroll, "PetGoodsItem" .. curCount, "1800700030", 0, 0, Transition.ColorTint)
	GUI.RegisterUIEvent(PetGoodsItem, UCE.PointerClick, "StallsUI", "OnPetGoodsClick_BuyPage");
	local Icon = ItemIcon.Create(PetGoodsItem, "Icon", 18, 1)
	UILayout.SetSameAnchorAndPivot(Icon, UILayout.Left)
	local Name = GUI.CreateStatic(PetGoodsItem, "Name", "", 110, 10, 250, 50)
	GUI.SetColor(Name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Name, UILayout.TopLeft)
	GUI.StaticSetAlignment(Name, TextAnchor.MiddleLeft)
	local CoinBg = GUI.ImageCreate(PetGoodsItem, "CoinBg", "1800700010", 110, 20, false, 155, 35)
	UILayout.SetSameAnchorAndPivot(CoinBg, UILayout.Left);
	-- GUI.SetVisible(CoinBg,false)
	local Coin = GUI.ImageCreate(CoinBg, "Coin", StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "", 0, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(Coin, UILayout.Left);
	local Price = GUI.CreateStatic(CoinBg, "Price", "", 10, -1, 160, 50)
	GUI.SetColor(Price, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(Price, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(Price, UILayout.Center)
	GUI.StaticSetAlignment(Price, TextAnchor.MiddleCenter)
	local Level = GUI.CreateStatic(PetGoodsItem, "Level", "", 155, -20, 250, 50)
	GUI.SetColor(Level, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(Level, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Level, UILayout.Center)
	GUI.StaticSetAlignment(Level, TextAnchor.MiddleLeft)
	local FightValue = GUI.CreateStatic(PetGoodsItem, "FightValue", "", 155, 20, 250, 50)
	GUI.SetColor(FightValue, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(FightValue, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(FightValue, UILayout.Center)
	GUI.StaticSetAlignment(FightValue, TextAnchor.MiddleLeft)
	local PetType = GUI.ImageCreate(PetGoodsItem, "PetType", "", -28, 0, true, 155, 35)
	UILayout.SetSameAnchorAndPivot(PetType, UILayout.Right)		
	return PetGoodsItem;
end

function StallsUI.RefreshPetScroll_BuyPage(parameter)						
	parameter = string.split(parameter, "#")
	local guid = parameter[1]
	local index = tonumber(parameter[2])
	local PetGoodsItem = GUI.GetByGuid(guid)
	local Icon = GUI.GetChild(PetGoodsItem,"Icon")
	local Name = GUI.GetChild(PetGoodsItem,"Name")
	local CoinBg = GUI.GetChild(PetGoodsItem,"CoinBg")
	local FightValue = GUI.GetChild(PetGoodsItem,"FightValue")
	local Level = GUI.GetChild(PetGoodsItem,"Level")
	local Price = GUI.GetChild(CoinBg,"Price")
	local Coin = GUI.GetChild(CoinBg,"Coin")
	local PetType = GUI.GetChild(PetGoodsItem,"PetType")
	index = index + 1

	local tb = StallsUI.SellList["Pet"][index]
	if tb ~= "" then
		tb = string.split(tb,",")
		local petDB = DB.GetOncePetByKey1(tb[1])
		-- GUI.ItemCtrlSetElementValue(Icon,eItemIconElement.Icon,tostring(petDB.Head))
		ItemIcon.BindPetDB(Icon, petDB)
		
		GUI.StaticSetText(Name,tb[2])
		
		GUI.StaticSetText(Level,"等级："..tb[3])
		
		GUI.StaticSetText(FightValue,"战力："..tb[4])
		
		GUI.StaticSetText(Price,tb[5])
		GUI.ImageSetImageID(Coin,StallsUI.MoneyType and UIDefine.GetMoneyIcon(StallsUI.MoneyType) or "")
		GUI.SetVisible(CoinBg,true)
		
		GUI.SetVisible(PetType,true)
		GUI.ImageSetImageID(PetType,UIDefine.PetType[petDB.Type])
		
		GUI.SetData(PetGoodsItem,"index",index)
		GUI.SetData(PetGoodsItem,"price",tb[5])
	else
		-- GUI.ItemCtrlSetElementValue(Icon,eItemIconElement.Icon,"")
		ItemIcon.SetEmpty(Icon)
		
		GUI.StaticSetText(Name,"")
		
		GUI.StaticSetText(Level,"")
		
		GUI.StaticSetText(FightValue,"")
		
		GUI.SetVisible(CoinBg,false)
	
		GUI.SetVisible(PetType,false)
	
		GUI.SetData(PetGoodsItem,"index",nil)
	end
end

function StallsUI.OnPetGoodsClick_BuyPage(guid)
	local index = GUI.GetData(GUI.GetByGuid(guid),"index")
	if index and index ~= "" then
		local price = GUI.GetData(GUI.GetByGuid(guid),"price")
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "DisplayDetail",StallsUI.TargetGuid,2,index)
		GUI.OpenWnd("PetInfoUI")
		PetInfoUI.AdjustForStalls(3,StallsUI.MoneyType,index,price,StallsUI.TargetGuid)
	end
end

--商品货物信息
function StallsUI.CreateItemInfoPanel(Panel)
	local Icon = ItemIcon.Create(Panel, "ItemIcon", -120 , -81)
	GUI.RegisterUIEvent(Icon, UCE.PointerClick, "StallsUI", "OnItemInfoClick_BuyPage")
	GUI.SetVisible(Icon,false)
	
	local Name = GUI.CreateStatic(Panel, "Name", "", 123, 17, 250, 50)
	GUI.SetColor(Name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(Name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Name, UILayout.TopLeft)
	
	local Level = GUI.CreateStatic(Panel, "Level", "", 60, -65, 250, 50)
	GUI.SetColor(Level, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(Level, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(Level, UILayout.Center)
	GUI.StaticSetAlignment(Level, TextAnchor.MiddleLeft)	
	
	local ShowType = GUI.CreateStatic(Panel, "ShowType", "", 140, -65, 250, 50)
	GUI.SetColor(ShowType, UIDefine.Yellow2Color)
	GUI.StaticSetFontSize(ShowType, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(ShowType, UILayout.Center)
	GUI.StaticSetAlignment(ShowType, TextAnchor.MiddleLeft)	
	
	--cutline
	
    local ItemDesScrollWnd = GUI.ScrollRectCreate( Panel, "ItemDesScrollWnd", 0, 50, 370, 140, 0, false, Vector2.New(355,355), UIAroundPivot.Top, UIAnchor.Top)
    SetAnchorAndPivot(ItemDesScrollWnd, UIAnchor.Center, UIAroundPivot.Center)	


	local ItemDes = GUI.CreateStatic(ItemDesScrollWnd, "ItemDes", "", 0, 0, 250, 355 ,"system",true)
	GUI.SetColor(ItemDes, UIDefine.BrownColor)
	GUI.StaticSetFontSize(ItemDes, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(ItemDes, TextAnchor.UpperLeft)	
	
end

function StallsUI.OnItemInfoClick_BuyPage()
	local panel = _gt.GetUI("BuyPage")
 	local itemData = LD.GetQueryItemData();
	Tips.CreateByItemData(itemData, panel, "itemTips", 420, -45)
end


function StallsUI.RefreshItemInfoPanel()
	local Panel = _gt.GetUI("ItemInfo_BuyPage")
	local Item = GUI.GetChild(Panel,"ItemIcon")	
	local Name = GUI.GetChild(Panel,"Name")
	local Level = GUI.GetChild(Panel,"Level")
	local ShowType = GUI.GetChild(Panel,"ShowType")
	local ItemDes = GUI.GetChild(Panel,"ItemDes")
	
	--选择数量重置为1
	StallsUI.PreBuyAmount = 1
	
	if StallsUI.ItemGoodsIndex and  StallsUI.SellList["Item"][StallsUI.ItemGoodsIndex] ~= "" then
		local tb = StallsUI.SellList["Item"][StallsUI.ItemGoodsIndex]
		tb = string.split(tb,",")
		local itemDB = DB.GetOnceItemByKey1(tb[1])
		
		GUI.ItemCtrlSetElementValue(Item, eItemIconElement.Icon, itemDB.Icon)
		-- GUI.ItemCtrlSetElementValue(Item, eItemIconElement.RightBottomNum, tb[2])
		GUI.ItemCtrlSetElementValue(Item, eItemIconElement.Border, UIDefine.ItemIconBg[itemDB.Grade])
		GUI.SetVisible(Item,true)
		GUI.StaticSetText(Name,itemDB.Name)
		GUI.StaticSetText(Level,itemDB.Level.."级")
		GUI.StaticSetText(ShowType,itemDB.ShowType)
		local DesStr = ""
		if itemDB.Info ~= "不显示" then
			DesStr = "使用效果："..itemDB.Info.."\n"
		end
		DesStr = DesStr.."使用说明："..itemDB.Tips
		GUI.StaticSetText(ItemDes,DesStr)
		--刷新数量
		StallsUI.UpdateTotalPrice_BuyPage()
		
		--请求数据
		CL.SendNotify(NOTIFY.SubmitForm, "FormStall", "DisplayDetail",StallsUI.TargetGuid,1,StallsUI.ItemGoodsIndex)
	else
		-- ItemIcon.SetEmpty(Item)
		GUI.SetVisible(Item,false)
		GUI.StaticSetText(Name,"")
		GUI.StaticSetText(Level,"")
		GUI.StaticSetText(ShowType,"")
		GUI.StaticSetText(ItemDes,"")
		
		--刷新数量
		StallsUI.UpdateTotalPrice_BuyPage()
	end

end



function StallsUI.OnNumAddBtnDown_BuyPage()
	local fun = function()
		StallsUI.PreBuyAmount = StallsUI.PreBuyAmount + 1
		StallsUI.UpdateTotalPrice_BuyPage()
	end
	if StallsUI.AmountTimer == nil then
		StallsUI.AmountTimer = Timer.New(fun, 0.15, -1)
	else
		StallsUI.AmountTimer:Stop()
		StallsUI.AmountTimer:Reset(fun, 0.15, -1)
	end
	StallsUI.AmountTimer:Start()
	fun()
end

function StallsUI.OnNumAddBtnUp_BuyPage()
	if StallsUI.AmountTimer ~= nil then
		StallsUI.AmountTimer:Stop()
		StallsUI.AmountTimer = nil;
	end
end

function StallsUI.OnNumMinusBtnDown_BuyPage()
	local fun = function()
		StallsUI.PreBuyAmount = StallsUI.PreBuyAmount - 1;
		StallsUI.UpdateTotalPrice_BuyPage();
	end

	if StallsUI.AmountTimer == nil then
		StallsUI.AmountTimer = Timer.New(fun, 0.15, -1)
	else
		StallsUI.AmountTimer:Stop();
		StallsUI.AmountTimer:Reset(fun, 0.15, -1)
	end
	StallsUI.AmountTimer:Start();
	fun();
end

function StallsUI.OnNumMinusBtnUp_BuyPage()
	if StallsUI.AmountTimer ~= nil then
		StallsUI.AmountTimer:Stop()
		StallsUI.AmountTimer = nil;
	end
end

function StallsUI.OnNumInputEndEdit_BuyPage()
	-- test("OnNumInputEndEdit_BuyPage")
	local NumInput = _gt.GetUI("BuyPage_numInput")
	local Number = GUI.EditGetTextM(NumInput)
	if Number == "" or tonumber(Number) == 0 then
		StallsUI.PreBuyAmount = 1
	else
		StallsUI.PreBuyAmount = tonumber(Number)
	end
	StallsUI.UpdateTotalPrice_BuyPage()

end

function StallsUI.UpdateTotalPrice_BuyPage()	
	local totalPrice = _gt.GetUI("BuyPage_totalPrice")
	local NumInput = _gt.GetUI("BuyPage_numInput")
	local MinusBtn = _gt.GetUI("BuyPage_numMinusBtn")
	local AddBtn = _gt.GetUI("BuyPage_numAddBtn")
	local tb = StallsUI.ItemGoodsIndex and StallsUI.SellList["Item"][StallsUI.ItemGoodsIndex] or ""
	if tb ~= "" then
		tb = string.split(tb,",")
		local price = tonumber(tb[3])
		local limit = tonumber(tb[2])
		StallsUI.PreBuyAmount = math.min(limit,StallsUI.PreBuyAmount)
		StallsUI.PreBuyAmount = math.max(1,StallsUI.PreBuyAmount)

		GUI.StaticSetText(totalPrice,StallsUI.PreBuyAmount*price)
		GUI.EditSetTextM(NumInput,StallsUI.PreBuyAmount)
		
		local goldNum = tonumber(tostring(CL.GetAttr(UIDefine.MoneyTypes[StallsUI.MoneyType])))
		--花费颜色
		if goldNum >= StallsUI.PreBuyAmount*price then
			GUI.SetColor(totalPrice, UIDefine.WhiteColor)
		else
			GUI.SetColor(totalPrice, UIDefine.RedColor)
		end
		
		
		------按钮
		if StallsUI.PreBuyAmount >= limit then
			GUI.ButtonSetShowDisable(AddBtn,false)
		else
			GUI.ButtonSetShowDisable(AddBtn,true)
		end
		
		if StallsUI.PreBuyAmount <= 1 then
			GUI.ButtonSetShowDisable(MinusBtn,false)
		else
			GUI.ButtonSetShowDisable(MinusBtn,true)
		end
	else
		GUI.StaticSetText(totalPrice,"")
		GUI.EditSetTextM(NumInput,"1")
		GUI.ButtonSetShowDisable(MinusBtn,false)
		GUI.ButtonSetShowDisable(AddBtn,false)
	end

end

function StallsUI.OnItemToggleClick()
	StallsUI.tabIndex = 1
	UILayout.OnTabClick(StallsUI.tabIndex, LabelList)	
	StallsUI.RefreshBuyPage()
end


function StallsUI.OnPetToggleClick()
	StallsUI.tabIndex = 2
	UILayout.OnTabClick(StallsUI.tabIndex, LabelList)	
	StallsUI.RefreshBuyPage()
end

function StallsUI.OnCloseBtnClick()
	-- if StallsUI.ShowType == 1 and StallsUI.StallStatus == 1 then
		-- CL.SendNotify(NOTIFY.ShowBBMsg,"上架货物后点击摆摊按钮才会开始售卖哦~")
	-- end
	GUI.CloseWnd("StallsUI")
	StallsUI.UnRegister()
end