local BourseUI = {}
_G.BourseUI = BourseUI

require "PetItem"
require "jsonUtil"
local _gt = UILayout.NewGUIDUtilTable();
local countPerPage = 8;

local tabList = {
  { "购买", "buyTabBtn", "1800402030", "1800402032", "OnBuyTabBtnBtnClick", -450, -245, 135, 50, 130, 50 },
  { "出售", "sellTabBtn", "1800402030", "1800402032", "OnSellTabBtnClick", -310, -245, 135, 50, 130, 50 },
}

local subTabList = {
  { "道具", "itemSubTabBtn", "1800402030", "1800402032", "OnItemSubTabBtnClick", 305, -195, 135, 50, 130, 50 },
  { "宠物", "petSubTabBtn", "1800402030", "1800402032", "OnPetSubTabBtnClick", 445, -195, 135, 50, 130, 50 },
}

local pullDownItemW = 175;
local pullDownItemH = 40;

local Right_tabList = {
    {"商会","CommerceUITabBtn","OnCommerceUITabBtnClick","guardArr_Right"},  -- attrPage
    {"交易","BourseUITabBtn","OnBourseUITabBtnClick","guardUpdateStar_Bg"}
}


function BourseUI.RefreshRecords(str)
	test("BourseUI.RefreshRecords");
	GUI.OpenWnd("BourseRecordUI")
	BourseRecordUI.SetContent(str);
end


function BourseUI.GetConfig(str)
	--test("BourseUI.GetConfig");
	--test(str);
	local config = loadstring("return " .. str)();

	--上手续费
	BourseUI.Fee = config["Fee"];
	--交易税
	BourseUI.Tax = config["Tax"];
	--上架时间
	BourseUI.Seconds = config["Seconds"];
	BourseUI.TimeData = {}

	for i = 1, #config["Seconds"] do
		local day, hour, minute, second = GlobalUtils.Get_DHMS1_BySeconds(config["Seconds"][i]);
		local time = "";
		if day ~= 0 then
			time = time .. day .. "天";
		end
		if hour ~= 0 then
			time = time .. hour .. "小时";
		end
		if minute~=0 then
			time = time ..minute.."分钟";
		end
		if second~=0 then
			time = time ..second.."秒";
		end
		table.insert(BourseUI.TimeData, time);
	end
	--每页道具数量
	countPerPage = config["NumPerPage"];
	
	--最低金元
	BourseUI.MinPrice_1 = config["MinPrice_1"];
	--最低银元
	BourseUI.MinPrice_2 = config["MinPrice_2"];
	--最低金币
	BourseUI.MinPrice_4 = config["MinPrice_4"];
	--最低银币
	BourseUI.MinPrice_5 = config["MinPrice_5"];
	BourseUI.MinPrice_13 = config["MinPrice_13"];
	BourseUI.MinPrice_14 = config["MinPrice_14"];
	
	BourseUI.MaxPrice = config["MaxPrice"];
	--金元宝商城手续费扣减的货币类型
	BourseUI.FeeBy1 = config["FeeBy1"];
	--银元宝商城手续费扣减的货币类型
	BourseUI.FeeBy2 = config["FeeBy2"];
	--金币商城手续费扣减的货币类型
	BourseUI.FeeBy4 = config["FeeBy4"];
	--银币商城手续费扣减的货币类型
	BourseUI.FeeBy5 = config["FeeBy5"];
	BourseUI.FeeBy13 = config["FeeBy13"];
	BourseUI.FeeBy14 = config["FeeBy14"];
	--基础价格
	BourseUI.PriceBeta = config["PriceBeta"];
	--宠物基础价格
	BourseUI.PetPriceBeta = config["PetPriceBeta"];
	--最低指导价（基于基础价格）
	BourseUI.PriceMin = config["PriceMin"];
	--最高指导价（基于基础价格）
	BourseUI.PriceMax = config["PriceMax"];
	--价格变成金元时的价格变化
	BourseUI.Price2_1 = config["Price2_1"];
	--价格变成银元时的价格变化
	BourseUI.Price2_2 = config["Price2_2"];
	--价格变成金币时的价格变化
	BourseUI.Price2_4 = config["Price2_4"];
	--价格变成银币时的价格变化
	BourseUI.Price2_5 = config["Price2_5"];
	
	BourseUI.Price2_13 = config["Price2_13"];
	BourseUI.Price2_14 = config["Price2_14"];
	
	BourseUI.MoneyType1 = config["FirstMoneyType"];
	BourseUI.MoneyType2 = config["SecondMoneyType"];
	
	BourseUI.ItemBaseLimit = config["MaxItemSelling"]
	BourseUI.ItemMaxLimit = BourseUI.ItemBaseLimit + config["AdderItemSelling"];
	BourseUI.PetBaseLimit = config["MaxPetSelling"]
	BourseUI.PetMaxLimit = BourseUI.PetBaseLimit + config["AdderPetSelling"];
	
	BourseUI.ReadMe = config["ReadMe"];
end

function BourseUI.GetLevelConfig(str)
	--test("BourseUI.GetLevelConfig:"..str);
	BourseUI.LevelConfig = loadstring("return " .. str)();
end

function BourseUI.GetCatalogList(str)
	--test("BourseUI.GetCatalogList");
	BourseUI.CategoryList = loadstring("return " .. str)();
	if not BourseUI.CategoryList or not next(BourseUI.CategoryList) then
		CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetConfig")
	end
	--local inspect = require("inspect")
	--print(inspect(BourseUI.CategoryList))
end

function BourseUI.GetCatalog(str)
	--test("BourseUI.GetCatalog");
	BourseUI.TotalCatalog = loadstring("return "..str)();
	if not BourseUI.TotalCatalog or not next(BourseUI.TotalCatalog) then
		CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetConfig")
	end
	--local inspect = require("inspect")
	--print(inspect(BourseUI.TotalCatalog))
end

function BourseUI.GetShieldingItemList(str)
	--test("BourseUI.GetShieldingItemList");
	BourseUI.ShieldingItemList = loadstring("return " .. str)();
	if not BourseUI.ShieldingItemList or not next(BourseUI.ShieldingItemList) then
		CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetConfig")
	end
end

function BourseUI.DataDownloaded()
	--test("==========================================BourseUI.DataDownloaded");
	BourseUI.InitAllowList();
	if not BourseUI.isDataDownloaded then
		-- 第一次进入时
		BourseUI.isDataDownloaded = true
		if UIDefine.FunctionSwitch["Exchange"] and UIDefine.FunctionSwitch["Exchange"] ~= "on" then
			require("CommerceUI")
			CommerceUI.OnBourseUITabBtnClick() 
		end
	end
	BourseUI.isDataDownloaded = true;
end


--function BourseUI.RefreshSellData(str)
--	local allSellData = loadstring("return " .. str)();
--	test("BourseUI.RefreshSellData");
--	test(str)
--	BourseUI.sellItemInfo = {};
--	BourseUI.sellPetInfo = {};
--	for i = 1, #allSellData do
--		local sellData = allSellData[i];
--		if sellData["coin_type"] == BourseUI.GetCurMoneyType()+System.Enum.ToInt(RoleAttr.RoleAttrExp) then
--			local info = {}
--			info.guid = sellData["guid"];
--			info.id = sellData["id"];
--			info.type = sellData["type"];
--			info.disable_times = sellData["disable_times"];
--			info.enable_times = sellData["enable_times"];
--			info.enable = sellData["enable"];
--			info.coin_type = sellData["coin_type"];
--			info.coin_value = sellData["coin_value"];
--			if sellData["type"] == 1 then
--				info.amount = sellData["amount"];
--				table.insert(BourseUI.sellItemInfo, info);
--			elseif sellData["type"] == 2 then
--				info.level = sellData["level"];
--				table.insert(BourseUI.sellPetInfo, info);
--			end
--		end
--	end
--	CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "QuetyCoin", BourseUI.GetCurMoneyType())
--	BourseUI.Refresh();
--end

function BourseUI.RefreshNowPage()
	test("RefreshNowPage")
	BourseUI.QueryReq();
end


function BourseUI.RefreshSellDataEx(json)
	local allSellData = jsonUtil.decode(json)
	BourseUI.sellItemInfo = {};
	BourseUI.sellPetInfo = {};
	for i = 1, #allSellData do
		local sellData = allSellData[i];
		if sellData["coin_type"] == BourseUI.GetCurMoneyType() + System.Enum.ToInt(RoleAttr.RoleAttrExp) then
			local info = {}
			info.guid = sellData["guid"];
			info.star_lv = sellData["star_lv"]
			info.id = sellData["id"];
			info.type = sellData["type"];
			info.disable_times = sellData["disable_times"];
			info.enable_times = sellData["enable_times"];
			info.enable = sellData["enable"];
			info.coin_type = sellData["coin_type"];
			info.coin_value = sellData["coin_value"];
			info.SpecialBuyer = sellData["SpecialBuyer"];
			if sellData["type"] == 1 then
				info.amount = sellData["amount"];
				table.insert(BourseUI.sellItemInfo, info);
			elseif sellData["type"] == 2 then
				info.level = sellData["level"];
				info.amount=1;
				table.insert(BourseUI.sellPetInfo, info);
			end
		end
	end

	CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "QuetyCoin", BourseUI.GetCurMoneyType())
	BourseUI.Refresh();
end

function BourseUI.RefreshMoneyData(type, value)
	--test("BourseUI.RefreshMoneyData:" .. type .. "-" .. value);

	local incomeBg = _gt.GetUI("incomeBg");
	UILayout.RefreshAttrBar(incomeBg,UIDefine.GetMoneyEnum(type),tostring(value))
	
	local ownBg = _gt.GetUI("ownBg");
	local moneyEnum =UIDefine.GetMoneyEnum(BourseUI.GetCurMoneyType())
	UILayout.RefreshAttrBar(ownBg,moneyEnum,UIDefine.ExchangeMoneyToStr(CL.GetAttr(moneyEnum)))
end

function BourseUI.RefreshAuctionCounts(coin_type, index, str)
	--test("BourseUI.RefreshAuctionCounts:");
	--test(str);
	if tonumber(coin_type) == BourseUI.GetCurMoneyType() and tonumber(index) == BourseUI.dirIndex then
		BourseUI.subDirGoodsCount = string.split(str, ",");
		BourseUI.Refresh();
	end
end

--function BourseUI.RefreshData(str)
--  test("BourseUI.RefreshData");
--  test(str)
--
--  BourseUI.buyGoodsInfo = {};
--
--  local allBuyData = loadstring("return " .. str)();
--  for i = 1, #allBuyData do
--    local buyData = allBuyData[i];
--    if buyData["coin_type"] == BourseUI.GetCurMoneyType() + System.Enum.ToInt(RoleAttr.RoleAttrExp) then
--      local info = {}
--      info.guid = buyData["guid"];
--      info.id = buyData["id"];
--      info.type = buyData["type"];
--      info.seller_name = buyData["seller_name"];
--      info.seller_guid = buyData["seller_guid"];
--      info.enable_times = buyData["enable_times"];
--      info.disable_times = buyData["disable_times"];
--      info.coin_type = buyData["coin_type"];
--      info.coin_value = buyData["coin_value"];
--      if info.type == 1 then
--        info.amount = buyData["amount"];
--      elseif info.type == 2 then
--        info.level = buyData["level"];
--      end
--
--      table.insert(BourseUI.buyGoodsInfo, info);
--    end
--  end
--
--  if allBuyData["total_page"] == nil then
--    BourseUI.goodsMaxPage = 1;
--  else
--    BourseUI.goodsMaxPage = allBuyData["total_page"];
--  end
--  BourseUI.Refresh();
--
--end

function BourseUI.RefreshDataEx(json)
	--test("BourseUI.RefreshDataEx");
	--test(json)
	local allBuyData = jsonUtil.decode(json)
	BourseUI.buyGoodsInfo={};
	for k, v in pairs(allBuyData) do
		if k=="total_page" then
			BourseUI.goodsMaxPage=v;
		else
			local buyData=v;
			if buyData["coin_type"] == BourseUI.GetCurMoneyType() + System.Enum.ToInt(RoleAttr.RoleAttrExp) then
				local info = {}
				info.guid = buyData["guid"];
				info.star_lv = buyData["star_lv"];
				info.id = buyData["id"];
				info.type = buyData["type"];
				info.seller_name = buyData["seller_name"];
				info.seller_guid = buyData["seller_guid"];
				info.enable_times = buyData["enable_times"];
				info.disable_times = buyData["disable_times"];
				info.coin_type = buyData["coin_type"];
				info.coin_value = buyData["coin_value"];
				info.SpecialBuyer = buyData["SpecialBuyer"];
				if info.type == 1 then
					info.amount = buyData["amount"];
				elseif info.type == 2 then
					info.level = buyData["level"];
					info.amount=1;
				end
				BourseUI.buyGoodsInfo[tonumber(k)]=info;
			end
		end
	end

	if BourseUI.goodsMaxPage==0 then
		BourseUI.goodsMaxPage=1;
	end
	BourseUI.Refresh();
end

--function BourseUI.RefreshCollection(str)
--  test("BourseUI.RefreshCollection");
--  test(str)
--  local collectionInfo = loadstring("return " .. str)();
--
--  BourseUI.collectionGuid = {};
--  for i = 1, #collectionInfo do
--    local info = collectionInfo[i];
--    if info["coin_type"] == BourseUI.GetCurMoneyType() then
--      table.insert(BourseUI.collectionGuid, info["guid"]);
--    end
--  end
--
--  if BourseUI.checkCollection == true then
--    BourseUI.checkCollection = false;
--  else
--    BourseUI.buyGoodsInfo = {};
--    for i = 1, #collectionInfo do
--      local buyData = collectionInfo[i];
--      if buyData["coin_type"] == BourseUI.GetCurMoneyType() + System.Enum.ToInt(RoleAttr.RoleAttrExp) then
--        local info = {}
--        info.guid = buyData["guid"];
--        info.id = buyData["id"];
--        info.type = buyData["type"];
--        info.seller_name = buyData["seller_name"];
--        info.seller_guid = buyData["seller_guid"];
--        info.enable_times = buyData["enable_times"];
--        info.disable_times = buyData["disable_times"];
--        info.coin_type = buyData["coin_type"];
--        info.coin_value = buyData["coin_value"];
--        if info.type == 1 then
--          info.amount = buyData["amount"];
--        elseif info.type == 2 then
--          info.level = buyData["level"];
--        end
--
--        table.insert(BourseUI.buyGoodsInfo, info);
--      end
--    end
--
--    BourseUI.goodsMaxPage = math.ceil(#BourseUI.buyGoodsInfo / countPerPage);
--    if BourseUI.goodsMaxPage <= 0 then
--      BourseUI.goodsMaxPage = 1;
--    end
--  end
--
--  BourseUI.Refresh();
--end

function BourseUI.RefreshCollectionEx(json)
	--test("BourseUI.RefreshCollectionEx");
	--test(json)
	local collectionInfo = jsonUtil.decode(json)
	BourseUI.collectionGuid = {};
	for i = 1, #collectionInfo do
		local info = collectionInfo[i];
		if info["coin_type"] == BourseUI.GetCurMoneyType() + System.Enum.ToInt(RoleAttr.RoleAttrExp) then
			table.insert(BourseUI.collectionGuid, info["guid"]);
		end
	end

	if BourseUI.checkCollection == true then
		BourseUI.checkCollection = false;
	else
		BourseUI.buyGoodsInfo = {};
		for i = 1, #collectionInfo do
			local buyData = collectionInfo[i];
			if buyData["coin_type"] == BourseUI.GetCurMoneyType() + System.Enum.ToInt(RoleAttr.RoleAttrExp) then
				local info = {}
				info.guid = buyData["guid"];
				info.star_lv = buyData["star_lv"]
				info.id = buyData["id"];
				info.type = buyData["type"];
				info.seller_name = buyData["seller_name"];
				info.seller_guid = buyData["seller_guid"];
				info.enable_times = buyData["enable_times"];
				info.disable_times = buyData["disable_times"];
				info.coin_type = buyData["coin_type"];
				info.coin_value = buyData["coin_value"];
				info.SpecialBuyer = buyData["SpecialBuyer"];
				if info.type == 1 then
					info.amount = buyData["amount"];
				elseif info.type == 2 then
					info.level = buyData["level"];
				end

				table.insert(BourseUI.buyGoodsInfo, info);
			end
		end

		BourseUI.goodsMaxPage = math.ceil(#BourseUI.buyGoodsInfo / countPerPage);
		if BourseUI.goodsMaxPage <= 0 then
			BourseUI.goodsMaxPage = 1;
		end
	end

	BourseUI.Refresh();
end

function BourseUI.QueryReq()
	if BourseUI.tabIndex == 1 then
		local stage = BourseUI.GetCurStage();
		--print("stage = "..tostring(stage))
		if stage == 0 then
			--test("GetCollection")
			BourseUI.checkCollection = false;
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetCollection");
		elseif stage == 1 then
			--test("GetGoodCount")
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetGoodCount", BourseUI.GetCurMoneyType(), BourseUI.dirIndex)
		elseif stage == 2 then
			local pageIndex = BourseUI.goodsPageIndex;
			if BourseUI.priceSort == 1 then
				pageIndex = BourseUI.goodsPageIndex;
			elseif BourseUI.priceSort == 2 then
				pageIndex = 0 - BourseUI.goodsPageIndex;
			end
			local curIndex = (BourseUI.subDirPageIndex - 1) * countPerPage + BourseUI.subDirIndex;
			local subDirData = BourseUI.GetSubDirData();
			if subDirData.Pet_Type == nil then
				local level = 0;
				if subDirData.LevelType ~= nil and subDirData.LevelType ~= 0 then
				if BourseUI.levelIndex ~= 0 then
					level = BourseUI.LevelConfig[subDirData.LevelType][BourseUI.levelIndex];
				end
				end
				local job = 0;
				local sex = 0;
				if subDirData.SexType ~= nil and subDirData.SexType ~= 0 then
					sex = BourseUI.sexIndex;
				end
				--print("level:"..level)
				CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetData", pageIndex, BourseUI.GetCurMoneyType(), BourseUI.dirIndex, curIndex, BourseUI.GetCurMoneyType(), level, job, sex, BourseUI.searchContent);
				BourseUI.checkCollection = true;
				CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetCollection");
			else
				CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetPetData", pageIndex, BourseUI.GetCurMoneyType(), BourseUI.dirIndex, curIndex, BourseUI.GetCurMoneyType(), BourseUI.searchContent);
				BourseUI.checkCollection = true;
				CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetCollection");
			end
		end
	elseif BourseUI.tabIndex == 2 then
		--test("GetMySellList")
		CL.SendNotify(NOTIFY.SubmitForm, "FormAuction ", "GetMySellList");
	end
end

function BourseUI.Main(parameter)
	if UIDefine.FunctionSwitch["Exchange"] and UIDefine.FunctionSwitch["Exchange"] ~= "on" then
		Right_tabList[1].hide = true
	else
		Right_tabList[1].hide = false
	end
	_gt = UILayout.NewGUIDUtilTable();
	BourseUI.CreateBg()
end

function BourseUI.CreateBg()
	local wnd = GUI.WndCreateWnd("BourseUI", "BourseUI", 0, 0);
	
	local panelBg = _gt.GetUI("panelBg")
	if not panelBg then
		panelBg = UILayout.CreateFrame_WndStyle0(wnd, "交    易", "BourseUI", "OnExit");
		_gt.BindName(panelBg, "panelBg")
		GUI.SetVisible(panelBg, false)
		GUI.SetVisible(GUI.Get("BourseUI/panelCover"), false)
	end

	UILayout.CreateSubTab(tabList, panelBg, "BourseUI");
	UILayout.CreateRightTab(Right_tabList, "BourseUI")
	
	local recordBtn = GUI.ButtonCreate(panelBg, "recordBtn", "1800402110", 450, -245, Transition.ColorTint, "交易记录", 120, 50, false);
	GUI.ButtonSetTextColor(recordBtn, UIDefine.BrownColor);
	GUI.ButtonSetTextFontSize(recordBtn, UIDefine.FontSizeM)
	GUI.RegisterUIEvent(recordBtn, UCE.PointerClick, "BourseUI", "OnRecordBtnClick");
	_gt.BindName(recordBtn, "recordBtn");
	
	BourseUI.CreateBuyPage()
	BourseUI.CreateSellPage()
	BourseUI.CreateBuyPopup(panelBg);
	BourseUI.CreateSellPopup(panelBg);
	BourseUI.CreatePullDown(panelBg);
	BourseUI.InitData()
	
	CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetConfig")
end

function BourseUI.InitData()
	--test("InitData")
	BourseUI.isDataDownloaded = false;
	BourseUI.moneyTypeIndex = 1
	BourseUI.tabIndex = 1;
	BourseUI.dirIndex = 0;
	BourseUI.subDirIndex = 0;
	BourseUI.subDirPageIndex = 1;
	BourseUI.goodsPageIndex = 1;
	BourseUI.goodsMaxPage = 1;
	BourseUI.priceSort = 1;
	BourseUI.levelIndex = 0;
	BourseUI.sexIndex = 0;
	BourseUI.subTabIndex = 1;
	BourseUI.canSellItemGuidList = {};
	BourseUI.canSellPetGuidList = {};
	BourseUI.firstEnterBuyPage = true;
	BourseUI.firstEnterSellPage = true;
	BourseUI.searchContent = ""
	BourseUI.checkCollection = false;
	--1:上架时间 2:级别筛选 3:性别筛选
	BourseUI.pullDownType = 1;
	BourseUI.sellItemLimit = 0;
	BourseUI.sellPetLimit = 0;
	BourseUI.buyGoodsIndex = 0;
	BourseUI.sellGoodsIndex = 0;
	BourseUI.subDirGoodsCount = {}
	BourseUI.sellItemInfo = {};
	BourseUI.sellPetInfo = {};
	BourseUI.collectionGuid = {};
	BourseUI.buyGoodsInfo = {};
	BourseUI.InitPopupData();
end

function BourseUI.InitPopupData()
	-- 0:关闭 1.上架道具 2.上架宠物 3.重新上架道具 4重新上架宠物 5.下架道具 6.下架宠物 7.购买道具 8.购买宠物
	BourseUI.popupState = 0;
	--道具或者宠物的guid
	BourseUI.popupGuid = 0;
	--道具或者宠物的Id
	BourseUI.popupId = 0;
	BourseUI.popupAmount = 1;
	BourseUI.popupTimeIndex = 1;
	BourseUI.popupPrice = 1;
	BourseUI.popupMinPrice = 1;
	BourseUI.popupMaxPrice = 1;
end

function BourseUI.OnShow(parameter)
	local wnd = GUI.GetWnd("BourseUI");
	if wnd == nil then
		test("没有wnd")
		return ;
	end

	if BourseUI.isDataDownloaded == false then
		GUI.SetVisible(wnd, false);
		test("没有isDataDownloaded")
		return
	end
	GUI.SetVisible(wnd, true);
	UILayout.OnTabClick(2, Right_tabList)
	BourseUI.Register();
	BourseUI.firstEnterBuyPage = true;
	BourseUI.firstEnterSellPage = true;
	BourseUI.OnBuyTabBtnBtnClick()
end

function BourseUI.Register()
	CL.RegisterMessage(GM.CustomDataUpdate, "BourseUI", "OnCustomDataUpdate");
	CL.RegisterMessage(GM.ItemQueryNtf, "BourseUI", "OnItemQueryNtf");
	CL.RegisterMessage(GM.PetQueryNtf, "BourseUI", "OnPetQueryNtf");
end

function BourseUI.UnRegister()
	CL.UnRegisterMessage(GM.CustomDataUpdate, "BourseUI", "OnCustomDataUpdate");
	CL.UnRegisterMessage(GM.ItemQueryNtf, "BourseUI", "OnItemQueryNtf");
	CL.UnRegisterMessage(GM.PetQueryNtf, "BourseUI", "OnPetQueryNtf");
end

function BourseUI.OnCustomDataUpdate(type,key,value)
	if key=="AuctionSystem_AdderItemSelling" or key=="AuctionSystem_AdderPetSelling" then
		BourseUI.Refresh();
	end
end

function BourseUI.OnDestroy()
    BourseUI.OnExit()
	BourseUI.InitData()
end

function BourseUI.OnExit()
	GUI.CloseWnd("BourseUI");
end

function BourseUI.OnClose()
	BourseUI.UnRegister();
	BourseUI.OnPopupClose();
	if BourseUI.amountTimer ~= nil then
		BourseUI.amountTimer:Stop()
		BourseUI.amountTimer = nil;
	end
end

function BourseUI.Refresh()
	--test("BourseUI.Refresh")
	for i = 1, #tabList do
		local page = _gt.GetUI("tabPage" .. i);
		GUI.SetVisible(page, i == BourseUI.tabIndex);
	end
	UILayout.OnSubTabClickEx(BourseUI.tabIndex, tabList);
	if BourseUI.tabIndex == 1 then
		BourseUI.RefreshBuyPage();
	elseif BourseUI.tabIndex == 2 then
		BourseUI.RefreshSellPage();
	end
end

function BourseUI.OnBuyTabBtnBtnClick()
	BourseUI.tabIndex = 1;
	if BourseUI.firstEnterBuyPage then
		BourseUI.firstEnterBuyPage = false;
		BourseUI.SetDirIndex(1);
	else
		BourseUI.Refresh();
	end
end

function BourseUI.OnSellTabBtnClick()
	BourseUI.tabIndex = 2;
	if BourseUI.firstEnterSellPage then
		BourseUI.firstEnterSellPage = false;
		BourseUI.OnItemSubTabBtnClick()
	else
		if BourseUI.subTabIndex == 1 then
			BourseUI.OnItemSubTabBtnClick()
		elseif BourseUI.subTabIndex == 2 then
			BourseUI.OnPetSubTabBtnClick()
		end
	end
end

--return 0.收藏夹 1.选择分类 2.选择物品
function BourseUI.GetCurStage()
	if BourseUI.dirIndex == 0 then
		return 0;
	else
		if BourseUI.subDirIndex == 0 then
			return 1;
		else
			return 2;
		end
	end
end

function BourseUI.GetMaxPage()
	if BourseUI.GetCurStage() == 1 then
		local dirData = BourseUI.GetDirData();
		return math.ceil(#dirData / countPerPage);
	else
		return BourseUI.goodsMaxPage
	end
end

function BourseUI.GetDirData()
	local catalog = BourseUI.TotalCatalog[BourseUI.dirIndex];
	local dirData = BourseUI.CategoryList[catalog];
	if not dirData or not next(dirData) then
		CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetConfig")
	end
	--local inspect = require("inspect")
	--print(inspect(dirData))
	return dirData;
end

function BourseUI.GetSubDirDataByIndex(index)
	local dirData = BourseUI.GetDirData();
	if dirData == nil then
		return nil;
	end
	index = (BourseUI.subDirPageIndex - 1) * countPerPage + index;
	local subDirData = dirData[index];
	return subDirData;
end

function BourseUI.GetSubDirData()
	return BourseUI.GetSubDirDataByIndex(BourseUI.subDirIndex)
end

function BourseUI.GetSellGoodsInfo()
	if BourseUI.subTabIndex == 1 then
		return BourseUI.sellItemInfo[BourseUI.sellGoodsIndex];
	elseif BourseUI.subTabIndex == 2 then
		return BourseUI.sellPetInfo[BourseUI.sellGoodsIndex];
	end
	return nil;
end

function BourseUI.GetBuyGoodsInfoByIndex(index)
	local curIndex = index;
	local curStage = BourseUI.GetCurStage();
	if curStage == 0 then
		curIndex = (BourseUI.goodsPageIndex - 1) * countPerPage + index;
	elseif curStage == 2 then
		curIndex = index;
	end
	return BourseUI.buyGoodsInfo[curIndex];
end

function BourseUI.GetBuyGoodsInfo()
	return BourseUI.GetBuyGoodsInfoByIndex(BourseUI.buyGoodsIndex);
end

function BourseUI.CheckInCollection(guid)
	for i = 1, #BourseUI.collectionGuid do
		if BourseUI.collectionGuid[i] == guid then
			return true;
		end
	end
	return false;
end

function BourseUI.OnItemQueryNtf()
	if BourseUI.popupState == 7 then
		local goodsInfo = BourseUI.GetBuyGoodsInfo();
		BourseUI.popupGuid = goodsInfo.guid;
		BourseUI.popupId = goodsInfo.id;
		BourseUI.popupPrice = goodsInfo.coin_value;
		BourseUI.popupAmount = 1;
		BourseUI.BuyItem(goodsInfo);
	elseif BourseUI.popupState == 5 then
		local goodsInfo = BourseUI.GetSellGoodsInfo();
		BourseUI.popupGuid = goodsInfo.guid;
		BourseUI.popupId = goodsInfo.id;
		BourseUI.popupPrice = goodsInfo.coin_value;
		BourseUI.popupAmount = goodsInfo.amount;
		BourseUI.BuyItem(goodsInfo);
	end
end

function BourseUI.OnPetQueryNtf()
	if BourseUI.popupState == 8 then
		local goodsInfo = BourseUI.GetBuyGoodsInfo();
		BourseUI.popupGuid = goodsInfo.guid;
		BourseUI.popupId = goodsInfo.id;
		BourseUI.popupPrice = goodsInfo.coin_value;
		BourseUI.popupAmount = 1;
		BourseUI.BuyPet(goodsInfo);
	elseif BourseUI.popupState == 6 then
		local goodsInfo = BourseUI.GetSellGoodsInfo();
		BourseUI.popupGuid = goodsInfo.guid;
		BourseUI.popupId = goodsInfo.id;
		BourseUI.popupPrice = goodsInfo.coin_value;
		BourseUI.popupAmount = 1;
		BourseUI.BuyPet(goodsInfo);
	end
end


function BourseUI.OnRecordBtnClick()
	CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "QueryRecords")
end

function BourseUI.RefreshSellPage()
	UILayout.OnSubTabClickEx(BourseUI.subTabIndex, subTabList);
	local itemScroll = _gt.GetUI("itemScroll");
	local petScroll = _gt.GetUI("petScroll");
	local boothText = _gt.GetUI("boothText");
	local sellGoodsScroll = _gt.GetUI("sellGoodsScroll");
	if BourseUI.subTabIndex == 1 then
		BourseUI.sellItemLimit = BourseUI.ItemBaseLimit + CL.GetIntCustomData("AuctionSystem_AdderItemSelling")
		GUI.StaticSetText(boothText, "我的摊位 " .. #BourseUI.sellItemInfo .. "/" .. BourseUI.sellItemLimit)
		GUI.SetVisible(itemScroll, true);
		GUI.SetVisible(petScroll, false);
		BourseUI.canSellItemGuidList = {};
		local bagType={item_container_type.item_container_bag,item_container_type.item_container_gem_bag,item_container_type.item_container_guard_bag}
		for j = 1, #bagType do
			local itemCount = LD.GetItemCount(bagType[j]);
			for i = 0, itemCount - 1 do
				local itemData = LD.GetItemDataByItemIndex(i,bagType[j]);
				if itemData.isbound == 0 and BourseUI.CheckItemCanSell(itemData.id) then
					table.insert(BourseUI.canSellItemGuidList, itemData.guid)				--0000
				end
			end
		end
		local itemCount = #BourseUI.canSellItemGuidList < 15 and 15 or #BourseUI.canSellItemGuidList;
		GUI.LoopScrollRectSetTotalCount(itemScroll, itemCount);
		GUI.LoopScrollRectRefreshCells(itemScroll);
		GUI.LoopScrollRectSetTotalCount(sellGoodsScroll, BourseUI.ItemMaxLimit);
		GUI.LoopScrollRectRefreshCells(sellGoodsScroll);
	elseif BourseUI.subTabIndex == 2 then
		BourseUI.sellPetLimit = BourseUI.PetBaseLimit + CL.GetIntCustomData("AuctionSystem_AdderPetSelling")
		GUI.StaticSetText(boothText, "我的摊位 " .. #BourseUI.sellPetInfo .. "/" .. BourseUI.sellPetLimit)
		GUI.SetVisible(itemScroll, false);
		GUI.SetVisible(petScroll, true);
		local petGuidList = LD.GetPetGuids();
		BourseUI.canSellPetGuidList = {};
		for i = 0, petGuidList.Count - 1 do
			local petGuid = petGuidList[i];
			local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)))
			if not LD.GetPetState(PetState.Bind, petGuid) and not LD.GetPetState(PetState.Lock, petGuid) and not LD.GetPetState(PetState.Show, petGuid) and not LD.GetPetState(PetState.Lineup, petGuid) and BourseUI.CheckPetCanSell(petId) then
				table.insert(BourseUI.canSellPetGuidList, petGuid)
			end
		end
		GUI.LoopScrollRectSetTotalCount(petScroll, #BourseUI.canSellPetGuidList);
		GUI.LoopScrollRectRefreshCells(petScroll);
		GUI.LoopScrollRectSetTotalCount(sellGoodsScroll, BourseUI.PetMaxLimit);
		GUI.LoopScrollRectRefreshCells(sellGoodsScroll);
	end
end

function BourseUI.RefreshBuyPage()
	--local inspect = require("inspect")
    --print(inspect(tabList))
	local dirScroll = _gt.GetUI("dirScroll");	
	GUI.LoopScrollRectSetTotalCount(dirScroll, #BourseUI.TotalCatalog + 1);
	GUI.LoopScrollRectRefreshCells(dirScroll);
	local curStage = BourseUI.GetCurStage();
	local searchInput = _gt.GetUI("searchInput");
	GUI.SetVisible(searchInput, curStage == 2);
	local priceSortBtn = _gt.GetUI("priceSortBtn");
	GUI.SetVisible(priceSortBtn, curStage == 2);
	local backBtn = _gt.GetUI("backBtn");
	GUI.SetVisible(backBtn, curStage == 2);
	local sexSelectBtn = _gt.GetUI("sexSelectBtn");
	local levelSelectBtn = _gt.GetUI("levelSelectBtn");
	local subDirScroll = _gt.GetUI("subDirScroll");
	local buyGoodsScroll = _gt.GetUI("buyGoodsScroll");
	local pageText = _gt.GetUI("pageText");
	if curStage == 0 or curStage == 2 then
		GUI.SetVisible(subDirScroll, false);
		GUI.SetVisible(buyGoodsScroll, true);
		local subDirData = BourseUI.GetSubDirData();
		if subDirData == nil then
			GUI.SetVisible(sexSelectBtn, false);
			GUI.SetVisible(levelSelectBtn, false);
		else
			if subDirData.LevelType == nil or subDirData.LevelType == 0 then
				GUI.SetVisible(levelSelectBtn, false);
			else
				GUI.SetVisible(levelSelectBtn, true);
				local selectedText = GUI.GetChild(levelSelectBtn, "selectedText");
				if BourseUI.levelIndex == 0 then
					GUI.StaticSetText(selectedText, "级别");
				else
					GUI.StaticSetText(selectedText, BourseUI.LevelConfig[subDirData.LevelType][BourseUI.levelIndex] .. "级");
				end
			end
			if subDirData.SexType == nil or subDirData.SexType == 0 then
				GUI.SetVisible(sexSelectBtn, false);
			else
				GUI.SetVisible(sexSelectBtn, true);
				local selectedText = GUI.GetChild(sexSelectBtn, "selectedText");
				if BourseUI.sexIndex == 0 then
					GUI.StaticSetText(selectedText, "性别");
				else
					GUI.StaticSetText(selectedText, UIDefine.GetSexName(BourseUI.sexIndex));
				end
			end
		end
		--GUI.LoopScrollRectSetTotalCount(buyGoodsScroll, #BourseUI.buyGoodsInfo);
		GUI.LoopScrollRectSetTotalCount(buyGoodsScroll, countPerPage);
		GUI.LoopScrollRectRefreshCells(buyGoodsScroll);
		GUI.StaticSetText(pageText, BourseUI.goodsPageIndex .. "/" .. BourseUI.GetMaxPage())
		BourseUI.UpdatePriceSortBtn();
	elseif curStage == 1 then
		GUI.SetVisible(sexSelectBtn, false);
		GUI.SetVisible(levelSelectBtn, false);
		GUI.SetVisible(subDirScroll, true);
		GUI.SetVisible(buyGoodsScroll, false);
		GUI.LoopScrollRectSetTotalCount(subDirScroll, countPerPage);
		GUI.LoopScrollRectRefreshCells(subDirScroll);
		GUI.StaticSetText(pageText, BourseUI.subDirPageIndex .. "/" .. BourseUI.GetMaxPage())
	end
end

function BourseUI.CreateSellPage()
	local panelBg = _gt.GetUI("panelBg")
	local sellPage = GUI.GroupCreate(panelBg, "sellPage", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
	_gt.BindName(sellPage, "tabPage2");
	GUI.SetVisible(sellPage, false);
	local leftBg = GUI.ImageCreate(sellPage, "leftBg", "1800400200", -145, 5, false, 740, 450)
	UILayout.SetSameAnchorAndPivot(leftBg, UILayout.Center);
	local sellGoodsScroll = GUI.LoopScrollRectCreate(leftBg, "sellGoodsScroll", 0, 0, 730, 430,	"BourseUI", "CreateSellGoodsItem", "BourseUI", "RefreshSellGoodsScroll", 0, false, Vector2.New(360, 105), 2, UIAroundPivot.Top, UIAnchor.Top);
	GUI.ScrollRectSetChildSpacing(sellGoodsScroll, Vector2.New(5, 4));
	_gt.BindName(sellGoodsScroll, "sellGoodsScroll");
	local boothText = GUI.CreateStatic(sellPage, "boothText", "我的摊位0/0", 0, -240, 250, 40);
	GUI.SetColor(boothText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(boothText, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(boothText, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(boothText, UILayout.Center);
	_gt.BindName(boothText, "boothText");
	local hintBtn = GUI.ButtonCreate(sellPage, "hintBtn", "1800702030", 200, -240, Transition.ColorTint);
	UILayout.SetSameAnchorAndPivot(hintBtn, UILayout.Center);
	GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "BourseUI", "OnHintBtnClick");
	local incomeArea = GUI.CreateStatic(sellPage, "incomeArea", "售出获得", -455, 265, 150, 30)
	GUI.SetColor(incomeArea, UIDefine.BrownColor)
	GUI.StaticSetFontSize(incomeArea, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(incomeArea, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(incomeArea, UILayout.Center);
	local incomeBg = UILayout.CreateAttrBar(incomeArea,"incomeBg",130,1,200,UILayout.Left)
	_gt.BindName(incomeBg, "incomeBg")
	local receiveBtn = GUI.ButtonCreate(sellPage, "receiveBtn", "1800402080", -95, 265, Transition.ColorTint, "领取", 160, 47, false);
	GUI.SetIsOutLine(receiveBtn, true);
	GUI.ButtonSetTextFontSize(receiveBtn, UIDefine.FontSizeXL);
	GUI.ButtonSetTextColor(receiveBtn, UIDefine.WhiteColor);
	GUI.SetOutLine_Color(receiveBtn, UIDefine.OutLine_BrownColor);
	GUI.SetOutLine_Distance(receiveBtn, UIDefine.OutLineDistance);
	GUI.RegisterUIEvent(receiveBtn, UCE.PointerClick, "BourseUI", "OnReceiveBtnClick");
	local ownArea = GUI.CreateStatic(sellPage, "ownArea", "拥有", 270, 265, 150, 30)
	GUI.SetColor(ownArea, UIDefine.BrownColor)
	GUI.StaticSetFontSize(ownArea, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(ownArea, TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(ownArea, UILayout.Center);
	local ownBg = UILayout.CreateAttrBar(ownArea,"ownBg",105,1,200,UILayout.Left)
	_gt.BindName(ownBg, "ownBg")
	UILayout.CreateSubTab(subTabList, sellPage, "BourseUI");
	local rightBg = GUI.ImageCreate(sellPage, "rightBg", "1800400200", 375, 30, false, 280, 400)
	UILayout.SetSameAnchorAndPivot(rightBg, UILayout.Center);
	local itemScroll = GUI.LoopScrollRectCreate(rightBg, "itemScroll", 0, 0, 270, 380, "BourseUI", "CreateItemIcon", "BourseUI", "RefreshItemScroll", 0, false, Vector2.New(80, 80), 3, UIAroundPivot.Top, UIAnchor.Top);
	GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(5, 5));
	_gt.BindName(itemScroll, "itemScroll");
	local petScroll = GUI.LoopScrollRectCreate(rightBg, "petScroll", 0, 0, 270, 380, "BourseUI", "CreatePetItem", "BourseUI", "RefreshPetScroll", 0, false, Vector2.New(265, 95), 1, UIAroundPivot.Top, UIAnchor.Top);
	GUI.ScrollRectSetChildSpacing(petScroll, Vector2.New(1, 1));
	_gt.BindName(petScroll, "petScroll");
	return sellPage
end


function BourseUI.OnReceiveBtnClick()
	test("TakeOffCoin")
	CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "TakeOffCoin", BourseUI.GetCurMoneyType());
end


function BourseUI.OnHintBtnClick()
	local sellPage = _gt.GetUI("tabPage2");
	Tips.CreateHint(BourseUI.ReadMe,sellPage,200,110,UILayout.Top,450)
end

function BourseUI.CreateSellGoodsItem()
	local sellGoodsScroll = _gt.GetUI("sellGoodsScroll");
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(sellGoodsScroll);
	local sellGoodsItem = GUI.ButtonCreate(sellGoodsScroll, "sellGoodsItem" .. curCount, "1800400360", 0, 0, Transition.ColorTint);
	GUI.RegisterUIEvent(sellGoodsItem, UCE.PointerClick, "BourseUI", "OnSellGoodsItemClick");
	local itemIcon = ItemIcon.Create(sellGoodsItem, "itemIcon", -130, 1);
	local cornerMark = GUI.ImageCreate(sellGoodsItem, "cornerMark", "1801308010", -1, 0, false, 60, 60)
	UILayout.SetSameAnchorAndPivot(cornerMark, UILayout.TopLeft);
	local name = GUI.CreateStatic(sellGoodsItem, "name", "名称", 100, 15, 250, 35)
	GUI.SetColor(name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft);
	GUI.StaticSetAlignment(name, TextAnchor.MiddleLeft)
	local coinBg = GUI.ImageCreate(sellGoodsItem, "coinBg", "1800700010", 100, 20, false, 200, 35)
	UILayout.SetSameAnchorAndPivot(coinBg, UILayout.Left);
	local coin = GUI.ImageCreate(coinBg, "coin", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 0, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(coin, UILayout.Left);
	local num = GUI.CreateStatic(coinBg, "num", "100", 5, -1, 160, 30)
	GUI.SetColor(num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
	GUI.SetAnchor(num, UIAnchor.Center)
	GUI.SetPivot(num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
	local remainText = GUI.CreateStatic(sellGoodsItem, "remainText", "1天", -10, 5, 100, 35)
	GUI.SetColor(remainText, UIDefine.RedColor)
	GUI.StaticSetFontSize(remainText, UIDefine.FontSizeM)
	UILayout.SetSameAnchorAndPivot(remainText, UILayout.TopRight);
	GUI.StaticSetAlignment(remainText, TextAnchor.MiddleRight)
	local lockText = GUI.CreateStatic(sellGoodsItem, "lockText", "点击解锁栏位", 10, 0, 250, 35)
	GUI.SetColor(lockText, UIDefine.BrownColor)
	GUI.StaticSetFontSize(lockText, UIDefine.FontSizeXL)
	UILayout.SetSameAnchorAndPivot(lockText, UILayout.Center);
	GUI.StaticSetAlignment(lockText, TextAnchor.MiddleCenter)
	local SpecialBuyer_Lock = GUI.ImageCreate(sellGoodsItem, "SpecialBuyer_Lock", "1800408170", 148, 18, false, 42, 53)
	GUI.SetVisible(SpecialBuyer_Lock, false)
	return sellGoodsItem;
end

function BourseUI.OnSellGoodsItemClick(guid)
	local sellGoodsItem = GUI.GetByGuid(guid);
	local index = GUI.ButtonGetIndex(sellGoodsItem);
	index = index + 1;
	
	BourseUI.sellGoodsIndex = index;
	local sellInfo = BourseUI.GetSellGoodsInfo();
	if BourseUI.subTabIndex == 1 then
		--print("BourseUI.subTabIndex == 1")
		if index > BourseUI.sellItemLimit then
			--test("UnlockField:" .. BourseUI.subTabIndex);
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "UnlockField", BourseUI.subTabIndex)
			return ;
		end
		if sellInfo ~= nil then
			BourseUI.popupState = 5;
			--test("NotifyDetail:" .. tostring(sellInfo.guid))
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "NotifyDetail", tostring(sellInfo.guid))
		end
	elseif BourseUI.subTabIndex == 2 then
		--print("BourseUI.subTabIndex == 2")
		if index > BourseUI.sellPetLimit then
			--test("UnlockField:" .. BourseUI.subTabIndex);
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "UnlockField", BourseUI.subTabIndex)
			return ;
		end
		if sellInfo ~= nil then
			BourseUI.popupState = 6;
			--test("NotifyDetail:" .. tostring(sellInfo.guid))
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "NotifyDetail", tostring(sellInfo.guid))
		end
	end
end


function BourseUI.OnBuyGoodsItemClick(guid)
	local sellGoodsItem = GUI.GetByGuid(guid);
	local index = GUI.ButtonGetIndex(sellGoodsItem);
	index = index + 1;
	
	BourseUI.buyGoodsIndex = index;
	local  buyInfo = BourseUI.GetBuyGoodsInfo();

	if buyInfo.type == 1 then
		BourseUI.popupState = 7;
	elseif buyInfo.type == 2 then
		BourseUI.popupState = 8;
	end

	--test("==========NotifyDetail:" .. tostring(buyInfo.guid))
	CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "NotifyDetail", tostring(buyInfo.guid))
end


function BourseUI.RefreshSellGoodsScroll(parameter)						--出售页左侧循环列表刷新
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local sellGoodsItem = GUI.GetByGuid(guid);
	index = index + 1;
	local starsBg = GUI.GetChild(sellGoodsItem,"starsBg")
	GUI.SetVisible(starsBg,false)
	if BourseUI.subTabIndex == 1 then
		if index <= #BourseUI.sellItemInfo then
			BourseUI.SetItemSellGoodsItem(sellGoodsItem, BourseUI.sellItemInfo[index])
		elseif index <= BourseUI.sellItemLimit then
			BourseUI.SetEmptySellGoodsItem(sellGoodsItem)
		else
			BourseUI.SetLockSellGoodsItem(sellGoodsItem)
		end
	elseif BourseUI.subTabIndex == 2 then
		if index <= #BourseUI.sellPetInfo then
			BourseUI.SetPetSellGoodsItem(sellGoodsItem, BourseUI.sellPetInfo[index])
		elseif index <= BourseUI.sellPetLimit then
			BourseUI.SetEmptySellGoodsItem(sellGoodsItem)
		else
			BourseUI.SetLockSellGoodsItem(sellGoodsItem)
		end
	end
end

function BourseUI.SetItemSellGoodsItem(sellGoodsItem, itemInfo)		--出售页相关
	local itemIcon = GUI.GetChild(sellGoodsItem, "itemIcon");
	local cornerMark = GUI.GetChild(sellGoodsItem, "cornerMark");
	local name = GUI.GetChild(sellGoodsItem, "name");
	local coinBg = GUI.GetChild(sellGoodsItem, "coinBg");
	local coin = GUI.GetChild(coinBg, "coin");
	local num = GUI.GetChild(coinBg, "num");
	local remainText = GUI.GetChild(sellGoodsItem, "remainText");
	local lockText = GUI.GetChild(sellGoodsItem, "lockText");
	local SpecialBuyer_Lock = GUI.GetChild(sellGoodsItem, "SpecialBuyer_Lock");
	GUI.SetVisible(cornerMark, true);
	GUI.SetVisible(name, true);
	GUI.SetVisible(coinBg, true);
	GUI.SetVisible(remainText, true);
	GUI.SetVisible(lockText, false);
	--test("itemInfo.id = "..itemInfo.id)
	local itemDB = DB.GetOnceItemByKey1(itemInfo.id)
	ItemIcon.BindItemId(itemIcon, itemInfo.id);
	GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, itemInfo.amount);

	GUI.StaticSetText(name, itemDB.Name);
	
	local name_width, TB = UIDefine.strnum(itemDB.Name)
	local total_width = TB[1] + TB[2] + 2 * TB[3] + 2 * TB[4]
	if total_width > 16 then
		GUI.StaticSetFontSize(name, 20)
	elseif total_width <= 14 then
		GUI.StaticSetFontSize(name, 24)
	elseif total_width == 16 then
		GUI.StaticSetFontSize(name, 21)
	elseif total_width == 15 then
		GUI.StaticSetFontSize(name, 22)
	end
	
	if itemInfo.enable == 1 then
		GUI.SetVisible(cornerMark, false)
	else
		GUI.SetVisible(cornerMark, true)
	end

	GUI.StaticSetText(num, itemInfo.coin_value);
	GUI.ImageSetImageID(coin, UIDefine.GetAttrIconByAttrId(itemInfo.coin_type));
	if itemInfo.SpecialBuyer and itemInfo.SpecialBuyer ~= "" and itemInfo.SpecialBuyer ~= "无" then
		GUI.SetVisible(SpecialBuyer_Lock, true)
	else
		GUI.SetVisible(SpecialBuyer_Lock, false)
	end	
	BourseUI.SetRemainText(remainText, itemInfo)
end

function BourseUI.SetRemainText(remainText, goodsInfo)
	if goodsInfo.enable == 0 then
	elseif goodsInfo.enable == 1 then
		GUI.SetVisible(remainText, true);
		local unixTime = tonumber(goodsInfo.disable_times) - tonumber(tostring(CL.GetServerTickCount()));
		local day, hour, minute, second = GlobalUtils.Get_DHMS1_BySeconds(unixTime)
		if day ~= 0 then
			GUI.StaticSetText(remainText, day .. "天");
		else
			if hour ~= 0 then
				GUI.StaticSetText(remainText, hour .. "小时");
			else
				if minute ~= 0 then
					GUI.StaticSetText(remainText, minute .. "分钟");
				end
			end
		end
	elseif goodsInfo.enable == 2 then
		GUI.SetVisible(remainText, false);
	end
end

function BourseUI.SetPetSellGoodsItem(sellGoodsItem, petInfo)
	--test("BourseUI.SetPetSellGoodsItem")
	local itemIcon = GUI.GetChild(sellGoodsItem, "itemIcon");
	local cornerMark = GUI.GetChild(sellGoodsItem, "cornerMark");
	local name = GUI.GetChild(sellGoodsItem, "name");
	local coinBg = GUI.GetChild(sellGoodsItem, "coinBg");
	local coin = GUI.GetChild(coinBg, "coin");
	local num = GUI.GetChild(coinBg, "num");
	local remainText = GUI.GetChild(sellGoodsItem, "remainText");
	local lockText = GUI.GetChild(sellGoodsItem, "lockText");
	local SpecialBuyer_Lock = GUI.GetChild(sellGoodsItem, "SpecialBuyer_Lock");
	
	GUI.SetVisible(cornerMark, true);
	GUI.SetVisible(name, true);
	GUI.SetVisible(coinBg, true);
	GUI.SetVisible(remainText, true);
	GUI.SetVisible(lockText, false);
	
	local petDB = DB.GetOncePetByKey1(petInfo.id)
	ItemIcon.BindPetDB(itemIcon, petDB);
	GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, 1);
	GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Type])
	local starsBg = GUI.GetChild(sellGoodsItem,"starsBg")
	GUI.SetVisible(starsBg,true)
	if petInfo.star_lv then
		UILayout.SetSmallStars(petInfo.star_lv, 6, itemIcon)	
	end
	GUI.StaticSetText(name, petDB.Name);
	if petInfo.enable == 1 then
		GUI.SetVisible(cornerMark, false)
	else
		GUI.SetVisible(cornerMark, true)
	end

	GUI.StaticSetText(num, petInfo.coin_value);
	GUI.ImageSetImageID(coin, UIDefine.GetAttrIconByAttrId(petInfo.coin_type));
	if petInfo.SpecialBuyer and petInfo.SpecialBuyer ~= "" and petInfo.SpecialBuyer ~= "无" then
		GUI.SetVisible(SpecialBuyer_Lock, true)
	else
		GUI.SetVisible(SpecialBuyer_Lock, false)
	end
	
	BourseUI.SetRemainText(remainText, petInfo)
end

function BourseUI.SetEmptySellGoodsItem(sellGoodsItem)
	local itemIcon = GUI.GetChild(sellGoodsItem, "itemIcon");
	local cornerMark = GUI.GetChild(sellGoodsItem, "cornerMark");
	local name = GUI.GetChild(sellGoodsItem, "name");
	local coinBg = GUI.GetChild(sellGoodsItem, "coinBg");
	local coin = GUI.GetChild(coinBg, "coin");
	local num = GUI.GetChild(coinBg, "num");
	local remainText = GUI.GetChild(sellGoodsItem, "remainText");
	local lockText = GUI.GetChild(sellGoodsItem, "lockText");
	local starsBg = GUI.GetChild(sellGoodsItem,"starsBg")
	local SpecialBuyer_Lock = GUI.GetChild(sellGoodsItem, "SpecialBuyer_Lock");
	GUI.SetVisible(starsBg,false)
	
	ItemIcon.SetEmpty(itemIcon);
	GUI.SetVisible(cornerMark, false);
	GUI.SetVisible(name, false);
	GUI.SetVisible(coinBg, false);
	GUI.SetVisible(cornerMark, false);
	GUI.SetVisible(remainText, false);
	GUI.SetVisible(lockText, false);
	GUI.SetVisible(SpecialBuyer_Lock, false);
end

function BourseUI.SetLockSellGoodsItem(sellGoodsItem)
	local itemIcon = GUI.GetChild(sellGoodsItem, "itemIcon");
	local cornerMark = GUI.GetChild(sellGoodsItem, "cornerMark");
	local name = GUI.GetChild(sellGoodsItem, "name");
	local coinBg = GUI.GetChild(sellGoodsItem, "coinBg");
	local remainText = GUI.GetChild(sellGoodsItem, "remainText");
	local lockText = GUI.GetChild(sellGoodsItem, "lockText");
	
	ItemIcon.SetLock(itemIcon);
	GUI.SetVisible(cornerMark, false);
	GUI.SetVisible(name, false);
	GUI.SetVisible(coinBg, false);
	GUI.SetVisible(cornerMark, false);
	GUI.SetVisible(remainText, false);
	GUI.SetVisible(lockText, true);
	
end

function BourseUI.GetCurPopup()
	local buyPopup = _gt.GetUI("buyPopup");
	if GUI.GetVisible(buyPopup) then
		--print("buyPopup")
		return buyPopup;
	end

	local sellPopup = _gt.GetUI("sellPopup");
	if GUI.GetVisible(sellPopup) then
		--print("sellPopup")
		return sellPopup;
	end

	return nil;
end

function BourseUI.OnPopupClose()
	BourseUI.popupState = 0;
	local popup = BourseUI.GetCurPopup();
	if popup ~= nil then
		GUI.SetVisible(popup, false);
		local SelectSpecialBuyer_Bg = _gt.GetUI("SelectSpecialBuyer_Bg")
		GUI.SetVisible(SelectSpecialBuyer_Bg, false);
		local SpecialBuyer_CheckBox = _gt.GetUI("SpecialBuyer_CheckBox")
		GUI.CheckBoxExSetCheck(SpecialBuyer_CheckBox, false)
		local SelectSpecialBuyer_Edit = _gt.GetUI("SelectSpecialBuyer_Edit")
		GUI.EditSetTextM(SelectSpecialBuyer_Edit, "无")
	end
	BourseUI.PasswordExit()
	GUI.CloseWnd("PetInfoUI");
end

function BourseUI.CreateBuyPopup(panelBg)		--购买页弹窗创建
	local buyPopup = GUI.GroupCreate(panelBg, "buyPopup", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
	_gt.BindName(buyPopup, "buyPopup");
	local wnd = GUI.GetWnd("BourseUI")
	local panelBg = _gt.GetUI("panelBg")
	local mask = GUI.ImageCreate(buyPopup, "mask", "1800400220", 0, GUI.GetPositionY(panelBg), false, GUI.GetWidth(wnd), GUI.GetHeight(wnd));
	GUI.SetIsRaycastTarget(mask, true)
	
	local BuyPopup_panelBg = GUI.ImageCreate(buyPopup, "BuyPopup_panelBg", "1800900010", 0, 0, false, 380, 560);
	local closeBtn = GUI.ButtonCreate(BuyPopup_panelBg, "closeBtn", "1800302120", 2, -2, Transition.ColorTint);
	UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight);
	GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "BourseUI", "OnPopupClose")
	
	local titleBg = GUI.ImageCreate(BuyPopup_panelBg, "titleBg", "1800001140", 0, 20, false, 230, 40);
	UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top);
	
	local title = GUI.CreateStatic(titleBg, "title", "商品信息", 0, 1, 120, 30);
	GUI.SetColor(title, UIDefine.White2Color);
	GUI.StaticSetFontSize(title, UIDefine.FontSizeL);
	GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(title, UILayout.Center);
	_gt.BindName(title, "BuyPopup_title")
	
	local itemBg = GUI.ImageCreate(BuyPopup_panelBg, "itemBg", "1800400200", 0, 70, false, 345, 260);
	UILayout.SetSameAnchorAndPivot(itemBg, UILayout.Top);
	local itemInfo = GUI.ButtonCreate(itemBg, "itemInfo", "1800400360", 0, 13, Transition.ColorTint, "", 325, 100, false);
	UILayout.SetSameAnchorAndPivot(itemInfo, UILayout.Top);
	GUI.RegisterUIEvent(itemInfo, UCE.PointerClick, "BourseUI", "OnItemInfoClick");
	_gt.BindName(itemInfo, "BuyPopup_itemInfo")
	
	local Popup_itemIcon = ItemIcon.Create(itemInfo, "itemIcon", -105, 10);
	_gt.BindName(Popup_itemIcon, "Popup_itemIcon")
	
	local Popup_petItem = PetItem.Create(itemBg, "petItem", 0, -67, 325, 100);
	GUI.CheckBoxExSetBgImageId(Popup_petItem, "1800400360")
	GUI.CheckBoxExSetCheckImageId(Popup_petItem, "1800400361")
	_gt.BindName(Popup_petItem, "BuyPopup_petItem")	
	GUI.RegisterUIEvent(Popup_petItem, UCE.PointerClick, "BourseUI", "OnItemInfoClick");
	UILayout.SetSameAnchorAndPivot(Popup_petItem, UILayout.Center);
	GUI.ImageCreate(Popup_petItem, "aaaaa", "1800702060", 80,0,false,46,44)		--没啥卵用，只是提示玩家这个框是可以点的
	
	local Popup_name = GUI.CreateStatic(itemInfo, "name", "名字", 110, -20, 200, 30);
	GUI.StaticSetFontSize(Popup_name, UIDefine.FontSizeM);
	GUI.SetColor(Popup_name, UIDefine.BrownColor);
	UILayout.SetSameAnchorAndPivot(Popup_name, UILayout.Left);
	GUI.StaticSetAlignment(Popup_name, TextAnchor.MiddleLeft);
	_gt.BindName(Popup_name, "Popup_name")
	
	local Popup_level = GUI.CreateStatic(itemInfo, "level", "等级：", 110, 15, 200, 30);
	GUI.StaticSetFontSize(Popup_level, UIDefine.FontSizeM);
	GUI.SetColor(Popup_level, UIDefine.Yellow2Color);
	UILayout.SetSameAnchorAndPivot(Popup_level, UILayout.Left);
	GUI.StaticSetAlignment(Popup_level, TextAnchor.MiddleLeft);
	_gt.BindName(Popup_level, "Popup_level")
	
	local Popup_ItemTipsScr = GUI.ScrollRectCreate(itemBg, "Popup_ItemTipsScr", 0,120,325,130,1,false, Vector2.New(300, 200), UIAroundPivot.Top, UIAnchor.Top)
	local str = "使用说明："
	local Popup_ItemTipsTxt = GUI.CreateStatic(Popup_ItemTipsScr, "Popup_ItemTipsTxt", str, 0,0,300,200)
	GUI.SetColor(Popup_ItemTipsTxt, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Popup_ItemTipsTxt, UIDefine.FontSizeL);
	GUI.StaticSetAlignment(Popup_ItemTipsTxt, TextAnchor.UpperLeft);
	UILayout.SetSameAnchorAndPivot(Popup_ItemTipsTxt, UILayout.Center);
	_gt.BindName(Popup_ItemTipsTxt, "Popup_ItemTipsTxt")
	
	
	local numText = GUI.CreateStatic(BuyPopup_panelBg, "numText", "数量", 40, 350, 100, 30);
	GUI.SetColor(numText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(numText, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(numText, UILayout.TopLeft);
	
	local numMinusBtn = GUI.ButtonCreate(BuyPopup_panelBg, "numMinusBtn", "1800402140", -60, 340, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(numMinusBtn, UILayout.Top);
	numMinusBtn:RegisterEvent(UCE.PointerUp)
	numMinusBtn:RegisterEvent(UCE.PointerDown)
	GUI.RegisterUIEvent(numMinusBtn, UCE.PointerDown, "BourseUI", "OnNumMinusBtnDown")
	GUI.RegisterUIEvent(numMinusBtn, UCE.PointerUp, "BourseUI", "OnNumMinusBtnUp")
	_gt.BindName(numMinusBtn, "BuyPopup_numMinusBtn")
	
	local Popup_numInput = GUI.EditCreate(BuyPopup_panelBg, "numInput", "1800400390", "1", 38, 342, Transition.ColorTint, "system", 0, 0, 8, 8, InputType.Standard, ContentType.IntegerNumber)
	UILayout.SetSameAnchorAndPivot(Popup_numInput, UILayout.Top);
	GUI.EditSetLabelAlignment(Popup_numInput, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(Popup_numInput, UIDefine.BrownColor)
	GUI.EditSetFontSize(Popup_numInput, UIDefine.FontSizeM)
	GUI.EditSetMaxCharNum(Popup_numInput, 3);
	_gt.BindName(Popup_numInput, "BuyPopup_numInput")
	GUI.RegisterUIEvent(Popup_numInput, UCE.EndEdit, "BourseUI", "OnPopupNumInputEndEdit");
	
	local numAddBtn = GUI.ButtonCreate(BuyPopup_panelBg, "numAddBtn", "1800402150", 135, 340, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(numAddBtn, UILayout.Top);
	numAddBtn:RegisterEvent(UCE.PointerUp)
	numAddBtn:RegisterEvent(UCE.PointerDown)
	GUI.RegisterUIEvent(numAddBtn, UCE.PointerDown, "BourseUI", "OnNumAddBtnDown")
	GUI.RegisterUIEvent(numAddBtn, UCE.PointerUp, "BourseUI", "OnNumAddBtnUp")
	_gt.BindName(numAddBtn, "BuyPopup_numAddBtn")
	
	local numBg = GUI.ImageCreate(BuyPopup_panelBg, "numBg", "1800700010", 40, 347, false, 245, 35)
	UILayout.SetSameAnchorAndPivot(numBg, UILayout.Top)
	_gt.BindName(numBg, "BuyPopup_numBg")
	
	local num = GUI.CreateStatic(numBg, "num", "100", 0, -1, 240, 30)
	_gt.BindName(num, "BuyPopup_num")
	GUI.SetColor(num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
	GUI.SetAnchor(num, UIAnchor.Center)
	GUI.SetPivot(num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
	
	local priceText = GUI.CreateStatic(BuyPopup_panelBg, "priceText", "单价", 40, 400, 100, 30);
	GUI.SetColor(priceText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(priceText, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(priceText, UILayout.TopLeft);
	
	local priceBg = GUI.ImageCreate(BuyPopup_panelBg, "priceBg", "1800700010", 40, 399, false, 245, 35)
	UILayout.SetSameAnchorAndPivot(priceBg, UILayout.Top);
	local coin = GUI.ImageCreate(priceBg, "coin", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 2, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(coin, UILayout.Left);
	local num = GUI.CreateStatic(priceBg, "num", "100", 5, -1, 240, 30)
	GUI.SetColor(num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
	GUI.SetAnchor(num, UIAnchor.Center)
	GUI.SetPivot(num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
	
	local totalPriceText = GUI.CreateStatic(BuyPopup_panelBg, "totalPriceText", "总价", 40, 450, 100, 30);
	GUI.SetColor(totalPriceText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(totalPriceText, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(totalPriceText, UILayout.TopLeft);
	
	local totalPriceBg = GUI.ImageCreate(BuyPopup_panelBg, "totalPriceBg", "1800700010", 40, 448, false, 245, 35)
	UILayout.SetSameAnchorAndPivot(totalPriceBg, UILayout.Top);
	local coin = GUI.ImageCreate(totalPriceBg, "coin", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 2, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(coin, UILayout.Left);
	local num = GUI.CreateStatic(totalPriceBg, "num", "100", 5, -1, 240, 30)
	GUI.SetColor(num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
	GUI.SetAnchor(num, UIAnchor.Center)
	GUI.SetPivot(num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
	_gt.BindName(num, "Buy_totalPrice_num")
	
	local confirmBtn = GUI.ButtonCreate(BuyPopup_panelBg, "confirmBtn", "1800402110", 90, 495, Transition.ColorTint, "购买", 115, 50, false);
	GUI.ButtonSetTextFontSize(confirmBtn, UIDefine.FontSizeL);
	GUI.ButtonSetTextColor(confirmBtn, UIDefine.BrownColor);
	GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "BourseUI", "OnOpr1Req")
	UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.Top)
	_gt.BindName(confirmBtn, "BuyPopup_confirmBtn")
	
	local leftConfirmBtn = GUI.ButtonCreate(BuyPopup_panelBg, "leftConfirmBtn", "1800402110", -90, 495, Transition.ColorTint, "取消", 115, 50, false);
	GUI.ButtonSetTextFontSize(leftConfirmBtn, UIDefine.FontSizeL);
	GUI.ButtonSetTextColor(leftConfirmBtn, UIDefine.BrownColor);
	GUI.RegisterUIEvent(leftConfirmBtn, UCE.PointerClick, "BourseUI", "OnOpr2Req")
	UILayout.SetSameAnchorAndPivot(leftConfirmBtn, UILayout.Top)
	_gt.BindName(leftConfirmBtn, "BuyPopup_leftConfirmBtn")
	--3.10新增 购买密码功能
	local Password_Bg = GUI.ImageCreate(BuyPopup_panelBg, "Password_Bg", "1800900010", 0, 0, false, 330, 300)
	_gt.BindName(Password_Bg, "Password_Bg")
	GUI.SetIsRaycastTarget(Password_Bg, true)
	local Password_Exit = GUI.ButtonCreate(Password_Bg, "Password_Exit", "1800302120", 143, -2, Transition.ColorTint, "", 46, 43, false);
	GUI.RegisterUIEvent(Password_Exit, UCE.PointerClick, "BourseUI", "PasswordExit");
	UILayout.SetSameAnchorAndPivot(Password_Exit, UILayout.Top);
	local Seller_Title = GUI.CreateStatic(Password_Bg, "Seller_Title", "卖家：", -55, 20, 150, 60);
	GUI.SetColor(Seller_Title, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Seller_Title, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Seller_Title, UILayout.Top);
	local Seller_Name = GUI.CreateStatic(Password_Bg, "Seller_Name", "XXX", 20, 20, 150, 60);
	GUI.SetColor(Seller_Name, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Seller_Name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Seller_Name, UILayout.Top);
	GUI.StaticSetAlignment(Seller_Name, TextAnchor.MiddleCenter)
	_gt.BindName(Seller_Name, "Seller_Name")
	local Password_Title = GUI.CreateStatic(Password_Bg, "Password_Title", "购买密码", -55, 80, 150, 60);
	GUI.SetColor(Password_Title, UIDefine.BrownColor);
	GUI.StaticSetFontSize(Password_Title, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(Password_Title, UILayout.Top);
	local Password_Edit = GUI.EditCreate(Password_Bg, "Password_Edit", "1800400390", "", 0, 145, Transition.ColorTint, "system", 255, 55, 8, 8)
	UILayout.SetSameAnchorAndPivot(Password_Edit, UILayout.Top);
	GUI.EditSetLabelAlignment(Password_Edit, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(Password_Edit, UIDefine.BrownColor)
	GUI.EditSetFontSize(Password_Edit, UIDefine.FontSizeM)
	GUI.EditSetMaxCharNum(Password_Edit, 12);
	_gt.BindName(Password_Edit, "Password_Edit")
	--GUI.RegisterUIEvent(Password_Edit, UCE.PointerClick, "BourseUI", "OnPriceInputClick")
	--GUI.RegisterUIEvent(Password_Edit, UCE.EndEdit, "BourseUI", "SelectSpecialBuyerEndEdit")
	local Password_Confirm = GUI.ButtonCreate(Password_Bg, "Password_Confirm", "1800402110", 75, 225, Transition.ColorTint, "确定", 115, 50, false);
	GUI.ButtonSetTextFontSize(Password_Confirm, UIDefine.FontSizeL);
	GUI.ButtonSetTextColor(Password_Confirm, UIDefine.BrownColor);
	GUI.RegisterUIEvent(Password_Confirm, UCE.PointerClick, "BourseUI", "PasswordConfirm")
	UILayout.SetSameAnchorAndPivot(Password_Confirm, UILayout.Top)
	local Password_Cancel = GUI.ButtonCreate(Password_Bg, "Password_Cancel", "1800402110", -75, 225, Transition.ColorTint, "取消", 115, 50, false);
	GUI.ButtonSetTextFontSize(Password_Cancel, UIDefine.FontSizeL);
	GUI.ButtonSetTextColor(Password_Cancel, UIDefine.BrownColor);
	GUI.RegisterUIEvent(Password_Cancel, UCE.PointerClick, "BourseUI", "PasswordExit")
	UILayout.SetSameAnchorAndPivot(Password_Cancel, UILayout.Top)

	GUI.SetVisible(Password_Bg, false);
	
	GUI.SetVisible(buyPopup, false);
end

function BourseUI.PasswordConfirm()
	local Password_Edit = _gt.GetUI("Password_Edit")
	local Password = GUI.EditGetTextM(Password_Edit)
	CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "Aucting", tostring(BourseUI.popupGuid), BourseUI.popupAmount, Password);
	local Password_Bg = _gt.GetUI("Password_Bg")
	GUI.SetVisible(Password_Bg, false);
end

function BourseUI.PasswordExit()
	local Password_Edit = _gt.GetUI("Password_Edit")
	GUI.EditSetTextM(Password_Edit, "")
	local Password_Bg = _gt.GetUI("Password_Bg")
	GUI.SetVisible(Password_Bg, false);
end
function BourseUI.CreateSellPopup(panelBg)		--上架界面

	local sellPopup = GUI.GroupCreate(panelBg, "sellPopup", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
	_gt.BindName(sellPopup, "sellPopup");
	
	local wnd = GUI.GetWnd("BourseUI")
	local panelBg = _gt.GetUI("panelBg")
	local mask = GUI.ImageCreate(sellPopup, "mask", "1800400220", 0, GUI.GetPositionY(panelBg), false, GUI.GetWidth(wnd), GUI.GetHeight(wnd));
	GUI.SetIsRaycastTarget(mask, true)
	
	local SellPopup_panelBg = GUI.ImageCreate(sellPopup, "SellPopup_panelBg", "1800900010", 0, -15, false, 380, 650);
	_gt.BindName(SellPopup_panelBg, "SellPopup_panelBg")
	local closeBtn = GUI.ButtonCreate(SellPopup_panelBg, "closeBtn", "1800302120", 2, -2, Transition.ColorTint);
	UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight);
	GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "BourseUI", "OnPopupClose")
	
	local titleBg = GUI.ImageCreate(SellPopup_panelBg, "titleBg", "1800001140", 0, 20, false, 230, 40);
	UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top);
	
	local title = GUI.CreateStatic(titleBg, "title", "上架确认", 0, 1, 100, 30);
	GUI.SetColor(title, UIDefine.White2Color);
	GUI.StaticSetFontSize(title, UIDefine.FontSizeL);
	GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(title, UILayout.Center);
	
	local itemBg = GUI.ImageCreate(SellPopup_panelBg, "itemBg", "1800400200", 0, 72, false, 345, 120);
	UILayout.SetSameAnchorAndPivot(itemBg, UILayout.Top);
	local itemInfo = GUI.ButtonCreate(itemBg, "itemInfo", "1800400360", 0, 0, Transition.ColorTint, "", 325, 100, false);
	UILayout.SetSameAnchorAndPivot(itemInfo, UILayout.Center);
	GUI.RegisterUIEvent(itemInfo, UCE.PointerClick, "BourseUI", "OnItemInfoClick");
	_gt.BindName(itemInfo, "SellPopup_itemInfo")
	
	local itemIcon = ItemIcon.Create(itemInfo, "itemIcon", -105, 1);
	_gt.BindName(itemIcon, "SellPopup_itemIcon")
	
	local Popup_petItem = PetItem.Create(itemBg, "petItem", 0, 0, 325, 100);
	GUI.CheckBoxExSetBgImageId(Popup_petItem, "1800400360")
	GUI.CheckBoxExSetCheckImageId(Popup_petItem, "1800400361")
	GUI.RegisterUIEvent(Popup_petItem, UCE.PointerClick, "BourseUI", "OnItemInfoClick");
	UILayout.SetSameAnchorAndPivot(Popup_petItem, UILayout.Center);
	_gt.BindName(Popup_petItem, "SellPopup_petItem")
	GUI.ImageCreate(Popup_petItem, "aaaaa", "1800702060", 80,0,false,46,44)		--没啥卵用，只是提示玩家这个框是可以点的
	
	local name = GUI.CreateStatic(itemInfo, "name", "名字", 110, -20, 200, 30);
	GUI.StaticSetFontSize(name, UIDefine.FontSizeM);
	GUI.SetColor(name, UIDefine.BrownColor);
	UILayout.SetSameAnchorAndPivot(name, UILayout.Left);
	GUI.StaticSetAlignment(name, TextAnchor.MiddleLeft);
	
	local level = GUI.CreateStatic(itemInfo, "level", "等级：", 110, 15, 200, 30);
	GUI.StaticSetFontSize(level, UIDefine.FontSizeM);
	GUI.SetColor(level, UIDefine.Yellow2Color);
	UILayout.SetSameAnchorAndPivot(level, UILayout.Left);
	GUI.StaticSetAlignment(level, TextAnchor.MiddleLeft);
	
	local putawayTimeText = GUI.CreateStatic(SellPopup_panelBg, "putawayTimeText", "上架时间", 25, 205, 100, 30);
	GUI.SetColor(putawayTimeText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(putawayTimeText, UIDefine.FontSizeL);
	UILayout.SetSameAnchorAndPivot(putawayTimeText, UILayout.TopLeft);
	
	local timeSelectBtn = GUI.ButtonCreate(SellPopup_panelBg, "timeSelectBtn", "1801102010", 40, 200, Transition.ColorTint, "", 175, 40, false);
	GUI.RegisterUIEvent(timeSelectBtn, UCE.PointerClick, "BourseUI", "OnTimeSelectBtnClick")
	UILayout.SetSameAnchorAndPivot(timeSelectBtn, UILayout.Top);
	local selectedText = GUI.CreateStatic(timeSelectBtn, "selectedText", "1天", -10, 0, 160, 30);
	GUI.SetColor(selectedText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(selectedText, UIDefine.FontSizeL);
	UILayout.SetSameAnchorAndPivot(selectedText, UILayout.Center);
	GUI.StaticSetAlignment(selectedText, TextAnchor.MiddleCenter);
	local arrow = GUI.ImageCreate(timeSelectBtn, "arrow", "1800707070", 60, 0)
	UILayout.SetSameAnchorAndPivot(arrow, UILayout.Center);
	
	local numText = GUI.CreateStatic(SellPopup_panelBg, "numText", "数量", 40, 260, 100, 30);
	GUI.SetColor(numText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(numText, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(numText, UILayout.TopLeft);
	
	local numMinusBtn = GUI.ButtonCreate(SellPopup_panelBg, "numMinusBtn", "1800402140", -60, 250, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(numMinusBtn, UILayout.Top);
	numMinusBtn:RegisterEvent(UCE.PointerUp)
	numMinusBtn:RegisterEvent(UCE.PointerDown)
	GUI.RegisterUIEvent(numMinusBtn, UCE.PointerDown, "BourseUI", "OnNumMinusBtnDown")
	GUI.RegisterUIEvent(numMinusBtn, UCE.PointerUp, "BourseUI", "OnNumMinusBtnUp")
	_gt.BindName(numMinusBtn, "SellPopup_numMinusBtn")
	
	local numInput = GUI.EditCreate(SellPopup_panelBg, "numInput", "1800400390", "1", 38, 252, Transition.ColorTint, "system", 0, 0, 8, 8, InputType.Standard, ContentType.IntegerNumber)
	UILayout.SetSameAnchorAndPivot(numInput, UILayout.Top);
	GUI.EditSetLabelAlignment(numInput, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(numInput, UIDefine.BrownColor)
	GUI.EditSetFontSize(numInput, UIDefine.FontSizeM)
	GUI.EditSetMaxCharNum(numInput, 3);
	GUI.RegisterUIEvent(numInput, UCE.EndEdit, "BourseUI", "OnNumInputEndEdit");
	_gt.BindName(numInput, "SellPopup_numInput")
	
	local numAddBtn = GUI.ButtonCreate(SellPopup_panelBg, "numAddBtn", "1800402150", 135, 250, Transition.ColorTint)
	UILayout.SetSameAnchorAndPivot(numAddBtn, UILayout.Top);
	numAddBtn:RegisterEvent(UCE.PointerUp)
	numAddBtn:RegisterEvent(UCE.PointerDown)
	GUI.RegisterUIEvent(numAddBtn, UCE.PointerDown, "BourseUI", "OnNumAddBtnDown")
	GUI.RegisterUIEvent(numAddBtn, UCE.PointerUp, "BourseUI", "OnNumAddBtnUp")
	_gt.BindName(numAddBtn, "SellPopup_numAddBtn")
	
	local priceText = GUI.CreateStatic(SellPopup_panelBg, "priceText", "单价", 40, 315, 100, 30);
	GUI.SetColor(priceText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(priceText, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(priceText, UILayout.TopLeft);
	
	local priceInput = GUI.EditCreate(SellPopup_panelBg, "priceInput", "1800400390", "1", 40, 309, Transition.ColorTint, "system", 250, 44, 8, 8, InputType.Standard, ContentType.IntegerNumber)
	UILayout.SetSameAnchorAndPivot(priceInput, UILayout.Top);
	GUI.EditSetLabelAlignment(priceInput, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(priceInput, UIDefine.BrownColor)
	GUI.EditSetFontSize(priceInput, UIDefine.FontSizeM)
	GUI.EditSetMaxCharNum(priceInput, 9);
	GUI.RegisterUIEvent(priceInput, UCE.PointerClick, "BourseUI", "OnPriceInputClick")
	GUI.RegisterUIEvent(priceInput, UCE.EndEdit, "BourseUI", "OnPriceInputEndEdit")
	local coin = GUI.ImageCreate(priceInput, "coin", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 5, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(coin, UILayout.Left);
	
	local logo = GUI.ImageCreate(priceInput, "logo", "1800402120", -2, 0, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(logo, UILayout.Right);
	
	local costText = GUI.CreateStatic(SellPopup_panelBg, "costText", "手续费", 25, 370, 150, 30);
	GUI.SetColor(costText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(costText, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(costText, UILayout.TopLeft);
	
	local costBg = GUI.ImageCreate(SellPopup_panelBg, "costBg", "1800700010", 40, 368, false, 245, 35)
	UILayout.SetSameAnchorAndPivot(costBg, UILayout.Top);
	local coin = GUI.ImageCreate(costBg, "coin", UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold], 2, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(coin, UILayout.Left);
	local num = GUI.CreateStatic(costBg, "num", "100", 5, -1, 240, 30)
	GUI.SetColor(num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
	GUI.SetAnchor(num, UIAnchor.Center)
	GUI.SetPivot(num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
	
	local tradeCostText = GUI.CreateStatic(SellPopup_panelBg, "tradeCostText", "交易税", 25, 425, 150, 30);
	GUI.SetColor(tradeCostText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(tradeCostText, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(tradeCostText, UILayout.TopLeft);
	
	local tradeCostBg = GUI.ImageCreate(SellPopup_panelBg, "tradeCostBg", "1800700010", 40, 423, false, 245, 35)
	UILayout.SetSameAnchorAndPivot(tradeCostBg, UILayout.Top);
	local coin = GUI.ImageCreate(tradeCostBg, "coin", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 2, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(coin, UILayout.Left);
	local num = GUI.CreateStatic(tradeCostBg, "num", "100", 5, -1, 240, 30)
	GUI.SetColor(num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
	GUI.SetAnchor(num, UIAnchor.Center)
	GUI.SetPivot(num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
	
	local totalPriceText = GUI.CreateStatic(SellPopup_panelBg, "totalPriceText", "总价", 40, 480, 150, 30);
	GUI.SetColor(totalPriceText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(totalPriceText, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(totalPriceText, UILayout.TopLeft);
	
	local totalPriceBg = GUI.ImageCreate(SellPopup_panelBg, "totalPriceBg", "1800700010", 40, 478, false, 245, 35)
	UILayout.SetSameAnchorAndPivot(totalPriceBg, UILayout.Top);
	local coin = GUI.ImageCreate(totalPriceBg, "coin", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 2, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(coin, UILayout.Left);
	local num = GUI.CreateStatic(totalPriceBg, "num", "100", 5, -1, 240, 30)
	GUI.SetColor(num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
	GUI.SetAnchor(num, UIAnchor.Center)
	GUI.SetPivot(num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
	_gt.BindName(num, "Sell_totalPrice_num")
	
	local confirmBtn = GUI.ButtonCreate(SellPopup_panelBg, "confirmBtn", "1800402110", 90, 586, Transition.ColorTint, "上架", 115, 50, false);
	GUI.ButtonSetTextFontSize(confirmBtn, UIDefine.FontSizeL);
	GUI.ButtonSetTextColor(confirmBtn, UIDefine.BrownColor);
	GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "BourseUI", "OnOpr1Req")
	UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.Top)
	
	local leftConfirmBtn = GUI.ButtonCreate(SellPopup_panelBg, "leftConfirmBtn", "1800402110", -90, 586, Transition.ColorTint, "取消", 115, 50, false);
	GUI.ButtonSetTextFontSize(leftConfirmBtn, UIDefine.FontSizeL);
	GUI.ButtonSetTextColor(leftConfirmBtn, UIDefine.BrownColor);
	GUI.RegisterUIEvent(leftConfirmBtn, UCE.PointerClick, "BourseUI", "OnOpr2Req")
	UILayout.SetSameAnchorAndPivot(leftConfirmBtn, UILayout.Top)
	--3.10新增 购买密码功能
	local SpecialBuyer_Bg = GUI.ImageCreate(SellPopup_panelBg, "SpecialBuyer_Bg", "1800001060", 0, 523, false, 330, 55)
	UILayout.SetSameAnchorAndPivot(SpecialBuyer_Bg, UILayout.Top)
	local SpecialBuyer_Title = GUI.CreateStatic(SpecialBuyer_Bg, "SpecialBuyer_Title", "设定购买密码", -40, 0, 150, 50);
	GUI.SetColor(SpecialBuyer_Title, UIDefine.BrownColor);
	GUI.StaticSetFontSize(SpecialBuyer_Title, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(SpecialBuyer_Title, UILayout.Top);
	local SpecialBuyer_CheckBox = GUI.CheckBoxExCreate(SpecialBuyer_Bg, "SpecialBuyer_CheckBox", "1800607150", "1800607151", 80, 6, false, 40, 40)
	UILayout.SetSameAnchorAndPivot(SpecialBuyer_CheckBox, UILayout.Top);
	GUI.RegisterUIEvent(SpecialBuyer_CheckBox, UCE.PointerClick, "BourseUI", "SpecialBuyer");
	_gt.BindName(SpecialBuyer_CheckBox, "SpecialBuyer_CheckBox")

	local SelectSpecialBuyer_Bg = GUI.ImageCreate(SellPopup_panelBg, "SelectSpecialBuyer_Bg", "1800900010", 0, 0, false, 330, 250)
	_gt.BindName(SelectSpecialBuyer_Bg, "SelectSpecialBuyer_Bg")
	GUI.SetIsRaycastTarget(SelectSpecialBuyer_Bg, true)
	local SelectSpecialBuyer_Exit = GUI.ButtonCreate(SelectSpecialBuyer_Bg, "SelectSpecialBuyer_Exit", "1800302120", 143, -2, Transition.ColorTint, "", 46, 43, false);
	GUI.RegisterUIEvent(SelectSpecialBuyer_Exit, UCE.PointerClick, "BourseUI", "SelectSpecialBuyerExit");
	UILayout.SetSameAnchorAndPivot(SelectSpecialBuyer_Exit, UILayout.Top);
	local SelectSpecialBuyer_Title = GUI.CreateStatic(SelectSpecialBuyer_Bg, "SelectSpecialBuyer_Title", "购买密码", -55, 20, 150, 60);
	GUI.SetColor(SelectSpecialBuyer_Title, UIDefine.BrownColor);
	GUI.StaticSetFontSize(SelectSpecialBuyer_Title, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(SelectSpecialBuyer_Title, UILayout.Top);
	local SelectSpecialBuyer_Edit = GUI.EditCreate(SelectSpecialBuyer_Bg, "SelectSpecialBuyer_Edit", "1800400390", "无", 0, 85, Transition.ColorTint, "system", 255, 55, 8, 8)
	UILayout.SetSameAnchorAndPivot(SelectSpecialBuyer_Edit, UILayout.Top);
	GUI.EditSetLabelAlignment(SelectSpecialBuyer_Edit, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(SelectSpecialBuyer_Edit, UIDefine.BrownColor)
	GUI.EditSetFontSize(SelectSpecialBuyer_Edit, UIDefine.FontSizeM)
	GUI.EditSetMaxCharNum(SelectSpecialBuyer_Edit, 12);
	_gt.BindName(SelectSpecialBuyer_Edit, "SelectSpecialBuyer_Edit")
	--GUI.RegisterUIEvent(SelectSpecialBuyer_Edit, UCE.PointerClick, "BourseUI", "OnPriceInputClick")
	--GUI.RegisterUIEvent(SelectSpecialBuyer_Edit, UCE.EndEdit, "BourseUI", "SelectSpecialBuyerEndEdit")
	local SelectSpecialBuyer_Confirm = GUI.ButtonCreate(SelectSpecialBuyer_Bg, "SelectSpecialBuyer_Confirm", "1800402110", 75, 165, Transition.ColorTint, "确定", 115, 50, false);
	GUI.ButtonSetTextFontSize(SelectSpecialBuyer_Confirm, UIDefine.FontSizeL);
	GUI.ButtonSetTextColor(SelectSpecialBuyer_Confirm, UIDefine.BrownColor);
	GUI.RegisterUIEvent(SelectSpecialBuyer_Confirm, UCE.PointerClick, "BourseUI", "SelectSpecialBuyerConfirm")
	UILayout.SetSameAnchorAndPivot(SelectSpecialBuyer_Confirm, UILayout.Top)
	local SelectSpecialBuyer_Cancel = GUI.ButtonCreate(SelectSpecialBuyer_Bg, "SelectSpecialBuyer_Cancel", "1800402110", -75, 165, Transition.ColorTint, "取消", 115, 50, false);
	GUI.ButtonSetTextFontSize(SelectSpecialBuyer_Cancel, UIDefine.FontSizeL);
	GUI.ButtonSetTextColor(SelectSpecialBuyer_Cancel, UIDefine.BrownColor);
	GUI.RegisterUIEvent(SelectSpecialBuyer_Cancel, UCE.PointerClick, "BourseUI", "SelectSpecialBuyerExit")
	UILayout.SetSameAnchorAndPivot(SelectSpecialBuyer_Cancel, UILayout.Top)


	GUI.SetVisible(SelectSpecialBuyer_Bg, false);

	GUI.SetVisible(sellPopup, false);
end

--3.10新增 购买密码功能
function BourseUI.SpecialBuyer(guid)
	local CheckBox = GUI.GetByGuid(guid)
	local TOF = GUI.CheckBoxExGetCheck(CheckBox)
	if TOF then
		--CL.SendNotify(NOTIFY.ShowBBMsg, "勾上了");
		local SelectSpecialBuyer_Bg = _gt.GetUI("SelectSpecialBuyer_Bg")
		GUI.SetVisible(SelectSpecialBuyer_Bg, true)
	else
		--CL.SendNotify(NOTIFY.ShowBBMsg, "取消了");
		local SelectSpecialBuyer_Bg = _gt.GetUI("SelectSpecialBuyer_Bg")
		GUI.SetVisible(SelectSpecialBuyer_Bg, false)
		local SelectSpecialBuyer_Edit = _gt.GetUI("SelectSpecialBuyer_Edit")
		GUI.EditSetTextM(SelectSpecialBuyer_Edit, "无")
	end
end

--function BourseUI.SelectSpecialBuyerEndEdit(guid)
--	local SelectSpecialBuyer_Edit = _gt.GetUI("SelectSpecialBuyer_Edit")
--	--GUI.EditSetTextM(SelectSpecialBuyer_Edit, "无")
--	local TXT = GUI.EditGetTextM(SelectSpecialBuyer_Edit)
--end

function BourseUI.SelectSpecialBuyerExit(guid)
	--CL.SendNotify(NOTIFY.ShowBBMsg, "关了");
	local SelectSpecialBuyer_Bg = _gt.GetUI("SelectSpecialBuyer_Bg")
	GUI.SetVisible(SelectSpecialBuyer_Bg, false)
	local SpecialBuyer_CheckBox = _gt.GetUI("SpecialBuyer_CheckBox")
	GUI.CheckBoxExSetCheck(SpecialBuyer_CheckBox, false)
	local SelectSpecialBuyer_Edit = _gt.GetUI("SelectSpecialBuyer_Edit")
	GUI.EditSetTextM(SelectSpecialBuyer_Edit, "无")
end

function BourseUI.SelectSpecialBuyerConfirm(guid)
	local SelectSpecialBuyer_Bg = _gt.GetUI("SelectSpecialBuyer_Bg")
	GUI.SetVisible(SelectSpecialBuyer_Bg, false)
	local SelectSpecialBuyer_Edit = _gt.GetUI("SelectSpecialBuyer_Edit")
	local TXT = GUI.EditGetTextM(SelectSpecialBuyer_Edit)
	if TXT == "无" or TXT == "" then
		local SpecialBuyer_CheckBox = _gt.GetUI("SpecialBuyer_CheckBox")
		GUI.CheckBoxExSetCheck(SpecialBuyer_CheckBox, false)
		return
	end
	CL.SendNotify(NOTIFY.ShowBBMsg, "已设定购买密码");
end
function BourseUI.CreatePullDown(panelBg)
	local wnd = GUI.GetWnd("BourseUI")
	local pullDownCover = GUI.ButtonCreate(panelBg, "pullDownCover", "1800400220", 0, GUI.GetPositionY(panelBg), Transition.None, "", GUI.GetWidth(wnd), GUI.GetHeight(wnd), false);
	GUI.RegisterUIEvent(pullDownCover, UCE.PointerClick, "BourseUI", "OnPullDownClose")
	_gt.BindName(pullDownCover, "pullDownCover");
	
	local border = GUI.ImageCreate(pullDownCover, "border", "1800400290", 0, 0, false, pullDownItemW + 12, 12);
	UILayout.SetSameAnchorAndPivot(border, UILayout.Top)
	
	local pullDownScroll = GUI.LoopScrollRectCreate(border, "pullDownScroll", 0, 5, pullDownItemW, 0,
		"BourseUI", "CreatePullDownItem", "BourseUI", "RefreshPullDownScroll", 0, false,
		Vector2.New(pullDownItemW, pullDownItemH), 1, UIAroundPivot.Top, UIAnchor.Top);
	UILayout.SetSameAnchorAndPivot(petScroll, UILayout.Top);
	_gt.BindName(pullDownScroll, "pullDownScroll");
	
	GUI.SetVisible(pullDownCover, false);
end

function BourseUI.CreatePullDownItem()
	local pullDownScroll = _gt.GetUI("pullDownScroll");
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(pullDownScroll);
	
	local pullDownItem = GUI.ButtonCreate(pullDownScroll, "pullDownItem" .. curCount, "1801102010", 0, 0, Transition.ColorTint, "0", pullDownItemW, pullDownItemH, false);
	GUI.ButtonSetTextFontSize(pullDownItem, UIDefine.FontSizeL);
	GUI.ButtonSetTextColor(pullDownItem, UIDefine.BrownColor);
	GUI.RegisterUIEvent(pullDownItem, UCE.PointerClick, "BourseUI", "OnPullDownItemClick");
	
	local selected = GUI.ImageCreate(pullDownItem, "selected", "1800600160", 0, 0, false, pullDownItemW + 5, pullDownItemH + 2)
	
	return pullDownItem;
end

function BourseUI.RefreshPullDownScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local pullDownItem = GUI.GetByGuid(guid);
	local selected = GUI.GetChild(pullDownItem, "selected");
	
	if BourseUI.pullDownType == 1 then
		index = index + 1;
		GUI.ButtonSetText(pullDownItem, BourseUI.TimeData[index]);
		GUI.SetVisible(selected, index == BourseUI.popupTimeIndex)
	elseif BourseUI.pullDownType == 2 then
		if index == 0 then
			GUI.ButtonSetText(pullDownItem, "全部");
		else
			GUI.ButtonSetText(pullDownItem, BourseUI.LevelConfig[BourseUI.GetSubDirData().LevelType][index] .. "级");
		end
		GUI.SetVisible(selected, index == BourseUI.levelIndex)
	elseif BourseUI.pullDownType == 3 then
		if index == 0 then
			GUI.ButtonSetText(pullDownItem, "全部");
		else
			GUI.ButtonSetText(pullDownItem, UIDefine.GetSexName(index));
		end
		GUI.SetVisible(selected, index == BourseUI.sexIndex)
	end
end

function BourseUI.OnPullDownItemClick(guid)
	local pullDownItem = GUI.GetByGuid(guid);
	local index = GUI.ButtonGetIndex(pullDownItem);
	if BourseUI.pullDownType == 1 then
		index = index + 1;
		BourseUI.popupTimeIndex = index;
		local sellPopup = _gt.GetUI("sellPopup");
		local timeSelectBtn = GUI.GetChild(sellPopup, "timeSelectBtn");
		local selectedText = GUI.GetChild(timeSelectBtn, "selectedText");
		GUI.StaticSetText(selectedText, BourseUI.TimeData[index]);
		BourseUI.UpdatePopupPrice();
	elseif BourseUI.pullDownType == 2 then
		BourseUI.levelIndex = index;
		local levelSelectBtn = _gt.GetUI("levelSelectBtn")
		local selectedText = GUI.GetChild(levelSelectBtn, "selectedText");
		if index == 0 then
		GUI.StaticSetText(selectedText, "全部");
		else
		GUI.StaticSetText(selectedText, BourseUI.LevelConfig[BourseUI.GetSubDirData().LevelType][index] .. "级");
		end
		BourseUI.QueryReq();
	elseif BourseUI.pullDownType == 3 then
		BourseUI.sexIndex = index;
		local sexSelectBtn = _gt.GetUI("sexSelectBtn")
		local selectedText = GUI.GetChild(sexSelectBtn, "selectedText");
		if index == 0 then
		GUI.StaticSetText(selectedText, "全部");
		else
		GUI.StaticSetText(selectedText, UIDefine.GetSexName(index));
		end
		BourseUI.QueryReq();
	end
	BourseUI.OnPullDownClose();
end

function BourseUI.OnPullDownClose()
	local pullDownCover = _gt.GetUI("pullDownCover");
	GUI.SetVisible(pullDownCover, false)
end

function BourseUI.OnLevelSelectBtnClick(guid)
  local pullDownCover = _gt.GetUI("pullDownCover");
  GUI.SetVisible(pullDownCover, true);

  BourseUI.pullDownType = 2;

  local border = GUI.GetChild(pullDownCover, "border");
  local pullDownScroll = GUI.GetChild(border, "pullDownScroll");

  local levelData = BourseUI.LevelConfig[BourseUI.GetSubDirData().LevelType]
  local count = (#levelData + 1) >= 8 and 8 or (#levelData+1)
  GUI.SetHeight(border, count * pullDownItemH + 12);
  GUI.SetPositionX(border, 190);
  GUI.SetPositionY(border, 170);

  GUI.SetHeight(pullDownScroll, count * pullDownItemH);
  GUI.LoopScrollRectSetTotalCount(pullDownScroll, #levelData+1);
  GUI.LoopScrollRectRefreshCells(pullDownScroll);
end

function BourseUI.OnSexSelectBtnClick(guid)
  local pullDownCover = _gt.GetUI("pullDownCover");
  GUI.SetVisible(pullDownCover, true);

  BourseUI.pullDownType = 3;

  local border = GUI.GetChild(pullDownCover, "border");
  local pullDownScroll = GUI.GetChild(border, "pullDownScroll");
  local count = System.Enum.ToInt(RoleGender.GenderMax)
  GUI.SetHeight(border, count * pullDownItemH + 12);
  GUI.SetPositionX(border, 65);
  GUI.SetPositionY(border, 170);

  GUI.SetHeight(pullDownScroll, count * pullDownItemH);
  GUI.LoopScrollRectSetTotalCount(pullDownScroll, count);
  GUI.LoopScrollRectRefreshCells(pullDownScroll);
end

function BourseUI.OnTimeSelectBtnClick(guid)
  local pullDownCover = _gt.GetUI("pullDownCover");
  GUI.SetVisible(pullDownCover, true);

  BourseUI.pullDownType = 1;

  local border = GUI.GetChild(pullDownCover, "border");
  local pullDownScroll = GUI.GetChild(border, "pullDownScroll");

  GUI.SetHeight(border, #BourseUI.TimeData * pullDownItemH + 12);
  GUI.SetPositionX(border, 40);
  GUI.SetPositionY(border, 335);

  GUI.SetHeight(pullDownScroll, #BourseUI.TimeData * pullDownItemH);
  GUI.LoopScrollRectSetTotalCount(pullDownScroll, #BourseUI.TimeData);
  GUI.LoopScrollRectRefreshCells(pullDownScroll);
end

function BourseUI.OnOpr1Req(guid)
	--print("BourseUI.popupPrice = "..tostring(BourseUI.popupPrice))
	--print("BourseUI.popupState = "..tostring(BourseUI.popupState))
	if BourseUI.popupState == 1 then
		--print("StartSellItem");
		local SelectSpecialBuyer_Edit = _gt.GetUI("SelectSpecialBuyer_Edit")
		local TXT = GUI.EditGetTextM(SelectSpecialBuyer_Edit)
		print("TXT = "..tostring(TXT))
		if TXT ~= "无" and TXT ~= "" then
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "StartSellItem", tostring(BourseUI.popupGuid), BourseUI.popupAmount, BourseUI.GetCurMoneyType(), BourseUI.popupPrice, BourseUI.popupTimeIndex, TXT);
		else
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "StartSellItem", tostring(BourseUI.popupGuid), BourseUI.popupAmount, BourseUI.GetCurMoneyType(), BourseUI.popupPrice, BourseUI.popupTimeIndex);
		end
	elseif BourseUI.popupState == 2 then
		--print("StartSellPet")
		local SelectSpecialBuyer_Edit = _gt.GetUI("SelectSpecialBuyer_Edit")
		local TXT = GUI.EditGetTextM(SelectSpecialBuyer_Edit)
		if TXT ~= "无" and TXT ~= "" then
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "StartSellPet", tostring(BourseUI.popupGuid), BourseUI.GetCurMoneyType(), BourseUI.popupPrice, BourseUI.popupTimeIndex, TXT);
		else
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "StartSellPet", tostring(BourseUI.popupGuid), BourseUI.GetCurMoneyType(), BourseUI.popupPrice, BourseUI.popupTimeIndex);
		end
	elseif  BourseUI.popupState == 3 or BourseUI.popupState == 4 then
		--print("SellAgain")
		CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "SellAgain", tostring(BourseUI.popupGuid), BourseUI.GetCurMoneyType(), BourseUI.popupPrice, BourseUI.popupTimeIndex);
	elseif BourseUI.popupState == 5 or BourseUI.popupState == 6 then
		local sellInfo = BourseUI.GetSellGoodsInfo();
		--local inspect = require "inspect"
		--print(inspect(sellInfo))
		if sellInfo.enable==2 then
			BourseUI.OnPopupClose();
			if BourseUI.subTabIndex==1 then
				local itemData = LD.GetQueryItemData();
				local itemDB = DB.GetOnceItemByKey1(sellInfo.id);
				BourseUI.popupState=3;
				BourseUI.popupTimeIndex=1;
				BourseUI.popupGuid = sellInfo.guid;
				BourseUI.popupId = sellInfo.id;
				BourseUI.popupAmount = sellInfo.amount;
				BourseUI.popupTimeIndex = 1;
				BourseUI.popupPrice, BourseUI.popupMinPrice, BourseUI.popupMaxPrice = BourseUI.GetSellItemPrice(itemDB)
				BourseUI.popupPrice = sellInfo.coin_value
				BourseUI.SellItem(itemData, itemDB);
			elseif BourseUI.subTabIndex==2 then
				local petData = LD.GetQueryPetData();
				local petDB = DB.GetOncePetByKey1(sellInfo.id);
				local petStar = petData:GetIntCustomAttr("PetStarLevel") or 1
				BourseUI.popupState=4;
				BourseUI.popupTimeIndex=1;
				BourseUI.popupGuid = sellInfo.guid;
				BourseUI.popupId = sellInfo.id;
				BourseUI.popupAmount = 1;
				BourseUI.popupTimeIndex = 1;
				BourseUI.popupPrice, BourseUI.popupMinPrice, BourseUI.popupMaxPrice = BourseUI.GetSellPetPrice(petDB,petStar)
				BourseUI.popupPrice = sellInfo.coin_value
				BourseUI.SellPet(petData, petDB, BourseUI.popupGuid)
			end
			return;
		elseif sellInfo.enable==1 then
			--print("Withdraw");
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "Withdraw",BourseUI.popupGuid);
		end
	elseif BourseUI.popupState == 7 or BourseUI.popupState == 8 then
		--print("Aucting")
		local goodsInfo = BourseUI.GetBuyGoodsInfo();
		--local inspect = require "inspect"
		--print(inspect(goodsInfo))
		local SpecialBuyer = goodsInfo.SpecialBuyer
		if SpecialBuyer and (SpecialBuyer ~= "无" and SpecialBuyer ~= "") then
			local Seller_Name = _gt.GetUI("Seller_Name")
			GUI.StaticSetText(Seller_Name, tostring(goodsInfo.seller_name))
			local Password_Bg = _gt.GetUI("Password_Bg")
			GUI.SetVisible(Password_Bg, true);
			return
		else
			local Password_Bg = _gt.GetUI("Password_Bg")
			GUI.SetVisible(Password_Bg, false);
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "Aucting", tostring(BourseUI.popupGuid), BourseUI.popupAmount);
		end
	end

	BourseUI.OnPopupClose();
end


function BourseUI.OnOpr2Req(guid)
	if BourseUI.popupState == 5 or BourseUI.popupState == 6 then
		local sellInfo = BourseUI.GetSellGoodsInfo();
		if sellInfo.enable==2 then
			test("TakeOut");
			CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "TakeOut",BourseUI.popupGuid);
		end
	end
	BourseUI.OnPopupClose();
end

function BourseUI.OnPriceInputClick(guid)--0000
	--print("BourseUI.OnPriceInputClick(guid)")
	local sellPopup = _gt.GetUI("sellPopup");
	local priceHint = GUI.GetChild(sellPopup, "priceHint");
	if not priceHint then
		priceHint = GUI.ImageCreate(sellPopup, "priceHint", "1800400290", 35, 290, false, 480, 50)
		UILayout.SetSameAnchorAndPivot(priceHint, UILayout.Top)
		local text = GUI.CreateStatic(priceHint, "text", "价格区间：" .. BourseUI.popupMinPrice .. " - " .. BourseUI.popupMaxPrice, 0, 0, 450, 200);
		GUI.StaticSetFontSize(text, UIDefine.FontSizeM);
		GUI.SetIsRemoveWhenClick(priceHint, true)
		UILayout.SetSameAnchorAndPivot(text, UILayout.Center)
		GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
	end
	GUI.SetVisible(priceHint, true);
	local text = GUI.GetChild(priceHint, "text");
	local w = GUI.StaticGetLabelPreferWidth(text)
	GUI.SetWidth(priceHint, w + 50);
	GUI.SetWidth(text, w);
end

function BourseUI.OnPriceInputEndEdit(guid)
	local priceInput = GUI.GetByGuid(guid);
	if GUI.EditGetTextM(priceInput) == "" then
		BourseUI.popupPrice = 0;
	else
		BourseUI.popupPrice = tonumber(GUI.EditGetTextM(priceInput));
	end
	BourseUI.UpdatePopupPrice()
	local sellPopup = _gt.GetUI("sellPopup");
	local priceHint = GUI.GetChild(sellPopup, "priceHint");
	GUI.SetVisible(priceHint, false);
end

function BourseUI.OnNumInputEndEdit()
	local popup = BourseUI.GetCurPopup();
	if popup == nil then
		return ;
	end
	local panelBg = GUI.GetChild(popup, "panelBg")
	local numInput = _gt.GetUI("SellPopup_numInput")
	if GUI.EditGetTextM(numInput) == "" then
		BourseUI.popupAmount = 1;
	else
		local Number = GUI.EditGetTextM(numInput)
		if not Number then
			Number = 1
		end
		BourseUI.popupAmount = tonumber(Number);
		--test("GUI.EditGetTextM(numInput) = "..tostring(Number))
	end

	BourseUI.UpdatePopupAmount(panelBg);
end

function BourseUI.OnPopupNumInputEndEdit()
	local popup = BourseUI.GetCurPopup();
	if popup == nil then
		return ;
	end
	local panelBg = GUI.GetChild(popup, "panelBg")
	local Popup_numInput = _gt.GetUI("BuyPopup_numInput")
	if GUI.EditGetTextM(Popup_numInput) == "" then
		BourseUI.popupAmount = 1;
	else
		local Number = GUI.EditGetTextM(Popup_numInput)
		if not Number then
			Number = 1
		end
		BourseUI.popupAmount = tonumber(Number);
		--test("GUI.EditGetTextM(Popup_numInput) = "..tostring(Number))
	end

	BourseUI.UpdatePopupAmount(panelBg);
end

function BourseUI.OnNumMinusBtnDown()
	local fun = function()
		BourseUI.popupAmount = BourseUI.popupAmount - 1;
		BourseUI.UpdatePopupAmount();
	end

	if BourseUI.amountTimer == nil then
		BourseUI.amountTimer = Timer.New(fun, 0.15, -1)
	else
		BourseUI.amountTimer:Stop();
		BourseUI.amountTimer:Reset(fun, 0.15, -1)
	end
	BourseUI.amountTimer:Start();
	fun();
end

function BourseUI.OnNumMinusBtnUp()
	if BourseUI.amountTimer ~= nil then
		BourseUI.amountTimer:Stop()
		BourseUI.amountTimer = nil;
	end
end

function BourseUI.OnNumAddBtnDown()
	local fun = function()
		BourseUI.popupAmount = BourseUI.popupAmount + 1;
		BourseUI.UpdatePopupAmount();
	end
	if BourseUI.amountTimer == nil then
		BourseUI.amountTimer = Timer.New(fun, 0.15, -1)
	else
		BourseUI.amountTimer:Stop();
		BourseUI.amountTimer:Reset(fun, 0.15, -1)
	end
	BourseUI.amountTimer:Start();
	fun();
end

function BourseUI.OnNumAddBtnUp()
	if BourseUI.amountTimer ~= nil then
		BourseUI.amountTimer:Stop()
		BourseUI.amountTimer = nil;
	end
end

function BourseUI.OnItemInfoClick()
	--test("BourseUI.OnItemInfoClick()")
	local popup = BourseUI.GetCurPopup();
	if popup == nil then
		return ;
	end

	if BourseUI.popupState == 1 then
		local itemData = LD.GetItemDataByGuid(BourseUI.popupGuid) or LD.GetItemDataByGuid(BourseUI.popupGuid, item_container_type.item_container_guard_bag);
		Tips.CreateByItemData(itemData, popup, "itemTips", 390, -45)
	elseif BourseUI.popupState == 2 then
		local petData = LD.GetPetData(BourseUI.popupGuid);
		GUI.OpenWnd("PetInfoUI");
		PetInfoUI.SetPetData(petData);
		local SellPopup_petItem = _gt.GetUI("SellPopup_petItem")
		GUI.CheckBoxExSetCheck(SellPopup_petItem, false);
	elseif BourseUI.popupState==3 or BourseUI.popupState==5 or BourseUI.popupState==7 then
		local itemData = LD.GetQueryItemData();
		Tips.CreateByItemData(itemData, popup, "itemTips", 390, -45)
	elseif BourseUI.popupState==4 or BourseUI.popupState==6 or BourseUI.popupState==8 then
		local petData = LD.GetQueryPetData();
		GUI.OpenWnd("PetInfoUI");
		PetInfoUI.SetPetData(petData);
		local BuyPopup_petItem = _gt.GetUI("BuyPopup_petItem")
		GUI.CheckBoxExSetCheck(BuyPopup_petItem, false);
		local SellPopup_petItem = _gt.GetUI("SellPopup_petItem")
		GUI.CheckBoxExSetCheck(SellPopup_petItem, false);
	end

end

function BourseUI.CreatePetItem()
	local petScroll = GUI.GetByGuid(_gt.petScroll);
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(petScroll);
	local petItem = PetItem.Create(petScroll, "petItem" .. curCount, 0, 0)
	GUI.CheckBoxExSetBgImageId(petItem, "1800400360")
	GUI.CheckBoxExSetCheckImageId(petItem, "1800400361")
	GUI.RegisterUIEvent(petItem, UCE.PointerClick, "BourseUI", "OnPetItemClick");
	return petItem;
end

function BourseUI.RefreshPetScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local petItem = GUI.GetByGuid(guid);
	index = index + 1;
	if index <= #BourseUI.canSellPetGuidList then
		local petGuid = BourseUI.canSellPetGuidList[index]
		PetItem.BindPetGuid(petItem, petGuid, pet_container_type.pet_container_panel)
		local nameText = GUI.GetChild(petItem,"nameText");
		local petData = LD.GetPetData(petGuid,pet_container_type.pet_container_panel)
		local a,TB = UIDefine.strnum(petData.name)
		local b = 0
		if TB and next(TB) then
			b = 0.55 * TB[1] + TB[3]
		end
		if b >= 5 and b < 5.5 then
			GUI.StaticSetFontSize(nameText, 22)
		elseif b >= 5.5 and b < 6 then
			GUI.StaticSetFontSize(nameText, 20)
		elseif b == 6 then
			GUI.StaticSetFontSize(nameText, 18)
		elseif b > 6 then
			GUI.StaticSetFontSize(nameText, 16)
		else
			GUI.StaticSetFontSize(nameText, UIDefine.FontSizeM)
		end
	end
end

function BourseUI.CreateItemIcon()
	local itemScroll = _gt.GetUI("itemScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll);
	local itemIcon = ItemIcon.Create(itemScroll, "itemIcon" .. curCount, 0, 0)
	GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "BourseUI", "OnItemClick");
	return itemIcon;
end

function BourseUI.RefreshItemScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]) + 1
	local itemIcon = GUI.GetByGuid(guid);	

	if index <= #BourseUI.canSellItemGuidList then
		local itemGuid = BourseUI.canSellItemGuidList[index]
		local itemData = LD.GetItemDataByGuid(itemGuid) or LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_guard_bag)
		local starsBg = GUI.GetChild(itemIcon,"starsBg")
		GUI.SetVisible(starsBg,false)
		if itemData ~= nil then
			--print("itemData.id = "..tostring(itemData.id))
			ItemIcon.BindItemData(itemIcon, itemData)
		else
			--print("没有itemData")
			ItemIcon.SetEmpty(itemIcon)
		end
		
	else
		ItemIcon.SetEmpty(itemIcon)
	end
end

function BourseUI.OnItemClick(guid)
	local itemIcon = GUI.GetByGuid(guid);
	local index = GUI.ItemCtrlGetIndex(itemIcon);
	index = index + 1;

	if index > #BourseUI.canSellItemGuidList then
		return ;
	end

	local itemGuid = BourseUI.canSellItemGuidList[index];
	local itemData = LD.GetItemDataByGuid(itemGuid) or LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_guard_bag)
	local itemDB = DB.GetOnceItemByKey1(itemData.id)
	BourseUI.popupState = 1;
	BourseUI.popupGuid = itemGuid;
	BourseUI.popupId = itemData.id;
	BourseUI.popupAmount = 1;
	BourseUI.popupTimeIndex = 1;
	BourseUI.popupPrice, BourseUI.popupMinPrice, BourseUI.popupMaxPrice = BourseUI.GetSellItemPrice(itemDB)
	BourseUI.popupPrice = BourseUI.popupMaxPrice
	
	BourseUI.SellItem(itemData, itemDB)
end

function BourseUI.OnPetItemClick(guid)
	--print("BourseUI.OnPetItemClick")
	local petItem = GUI.GetByGuid(guid);
	local index = GUI.CheckBoxExGetIndex(petItem);
	GUI.CheckBoxExSetCheck(petItem, false);
	index = index + 1;
	if index > #BourseUI.canSellPetGuidList then
		return ;
	end

	local petGuid = BourseUI.canSellPetGuidList[index];
	local petData = LD.GetPetData(petGuid);
	local petStar = petData:GetIntCustomAttr("PetStarLevel") or 1
	local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)));
	test(petId)
	local petDB = DB.GetOncePetByKey1(petId)
	BourseUI.popupState = 2;
	BourseUI.popupGuid = petGuid;
	BourseUI.popupId = petId;
	BourseUI.popupAmount = 1;
	BourseUI.popupTimeIndex = 1;
	BourseUI.popupPrice, BourseUI.popupMinPrice, BourseUI.popupMaxPrice = BourseUI.GetSellPetPrice(petDB, petStar)
	BourseUI.popupPrice = BourseUI.popupMaxPrice
	
	BourseUI.SellPet(petData, petDB, BourseUI.popupGuid);
end

function BourseUI.SellPet(petData, petDB, petGuid)
	local sellPopup = _gt.GetUI("sellPopup");
	GUI.SetVisible(sellPopup, true);
	
	local panelBg = _gt.GetUI("SellPopup_panelBg");	
	local SellPopup_petItem = _gt.GetUI("SellPopup_petItem");
	GUI.SetVisible(SellPopup_petItem, true)
	
	local SellPopup_itemInfo = _gt.GetUI("SellPopup_itemInfo")
	GUI.SetVisible(SellPopup_itemInfo, false)

	if petGuid then
		if BourseUI.popupState == 4 then
			local goodsInfo = BourseUI.GetSellGoodsInfo();
			--local inspect = require "inspect"
			--print(inspect(goodsInfo))
			local icon = GUI.GetChild(SellPopup_petItem,"icon");
			ItemIcon.BindPetDB(icon,petDB)
			GUI.ItemCtrlSetIconGray(icon, false)
			GUI.SetVisible(icon,true);
			GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Type])
			local starlevel = goodsInfo.star_lv
			UILayout.SetSmallStars(starlevel, 6, icon)
			
			local nameText = GUI.GetChild(SellPopup_petItem,"nameText");
			GUI.SetVisible(nameText,true);
			GUI.StaticSetText(nameText,petDB.Name);
			local levelText = GUI.GetChild(SellPopup_petItem,"levelText");
			GUI.SetVisible(levelText,true);
			GUI.StaticSetText(levelText,"等级:"..goodsInfo.level);
			local petTypeLabel = GUI.GetChild(SellPopup_petItem,"petTypeLabel");
			GUI.SetVisible(petTypeLabel,true);
			GUI.ImageSetImageID(petTypeLabel,UIDefine.PetType[petDB.Type])
			local lockLabel = GUI.GetChild(SellPopup_petItem,"lockLabel")
			GUI.SetVisible(lockLabel,true);
			local isLock = LD.GetPetState(PetState.Lock, goodsInfo.guid)
			if isLock then
				GUI.ImageSetImageID(lockLabel,"1800707020")
			else
				GUI.ImageSetImageID(lockLabel,"1800707080")
				GUI.SetVisible(lockLabel,false)
			end
			local lockText = GUI.GetChild(SellPopup_petItem,"lockText");
			GUI.SetVisible(lockText,false)
		elseif BourseUI.popupState == 2 then
			--print("petGuid = "..tostring(petGuid))
			PetItem.BindPetGuid(SellPopup_petItem, petGuid, pet_container_type.pet_container_panel)
			if petDB then
				local nameText = GUI.GetChild(SellPopup_petItem,"nameText");
				GUI.StaticSetText(nameText,petDB.Name);
			end
		end
	end
	
	BourseUI.SetPopupPanel(panelBg);
end

function BourseUI.SellItem(itemData, itemDB)
	local sellPopup = _gt.GetUI("sellPopup");
	GUI.SetVisible(sellPopup, true);
	
	local panelBg = _gt.GetUI("SellPopup_panelBg");
	local SellPopup_petItem = _gt.GetUI("SellPopup_petItem");
	GUI.SetVisible(SellPopup_petItem, false)
	local SellPopup_itemIcon = _gt.GetUI("SellPopup_itemIcon");
	
	local SellPopup_itemInfo = _gt.GetUI("SellPopup_itemInfo")
	GUI.SetVisible(SellPopup_itemInfo, true)
	
	ItemIcon.BindItemData(SellPopup_itemIcon, itemData, true)
	if not itemDB then
		itemDB = DB.GetOnceItemByKey1(itemData.id)
	end
	local name = GUI.GetChild(panelBg, "name");
	GUI.StaticSetText(name, itemDB.Name)
	local level = GUI.GetChild(panelBg, "level");
	GUI.StaticSetText(level, "等级：" .. itemDB.Level)
	
	BourseUI.SetPopupPanel(panelBg);
end

function BourseUI.BuyItem(goodsInfo)			--0000
	--print("BourseUI.BuyItem")
	local itemData = LD.GetQueryItemData();
	if itemData == nil then
		return ;
	end
	
	local BuyPopup_petItem = _gt.GetUI("BuyPopup_petItem")
	local BuyPopup_itemInfo = _gt.GetUI("BuyPopup_itemInfo")
	GUI.SetVisible(BuyPopup_petItem, false)
	GUI.SetVisible(BuyPopup_itemInfo, true)
	
	local buyPopup = _gt.GetUI("buyPopup");
	GUI.SetVisible(buyPopup, true);
	local panelBg = _gt.GetUI("panelBg")
	--local itemBg = GUI.GetChild(panelBg, "itemBg");
	--local itemIcon = GUI.GetChild(itemBg, "itemIcon");
	local itemIcon = _gt.GetUI("Popup_itemIcon")
	ItemIcon.BindItemData(itemIcon, itemData, true)
	local itemDB = DB.GetOnceItemByKey1(itemData.id);
	local Popup_name = _gt.GetUI("Popup_name")
	GUI.StaticSetText(Popup_name, itemDB.Name)
	local Popup_level = _gt.GetUI("Popup_level")
	GUI.StaticSetText(Popup_level, "等级：" .. itemDB.Level)
	local Popup_ItemTipsTxt = _gt.GetUI("Popup_ItemTipsTxt")
	GUI.StaticSetText(Popup_ItemTipsTxt, "使用说明："..itemDB.Tips)
	
	local numBg = _gt.GetUI("BuyPopup_numBg");
	local numMinusBtn = _gt.GetUI("BuyPopup_numMinusBtn");
	local numInput = _gt.GetUI("BuyPopup_numInput");
	local numAddBtn = _gt.GetUI("BuyPopup_numAddBtn");
	if BourseUI.tabIndex == 1 then
		GUI.SetVisible(numBg, false);
		GUI.SetVisible(numMinusBtn, true);
		GUI.SetVisible(numInput, true);
		GUI.SetVisible(numAddBtn, true);
	elseif BourseUI.tabIndex == 2 then
		GUI.SetVisible(numBg, true);
		GUI.SetVisible(numMinusBtn, false);
		GUI.SetVisible(numInput, false);
		GUI.SetVisible(numAddBtn, false);
	end
	BourseUI.SetBuyTitle(panelBg, goodsInfo)
	BourseUI.SetPopupPanel(panelBg)
end

function BourseUI.SetBuyTitle(panelBg, goodsInfo, type)			--type是空值，没有转过来
	local title = _gt.GetUI("BuyPopup_title")
	local confirmBtn = _gt.GetUI("BuyPopup_confirmBtn")
	local leftConfirmBtn = _gt.GetUI("BuyPopup_leftConfirmBtn")

	if BourseUI.tabIndex == 1 then
		GUI.StaticSetText(title, "商品信息");
		GUI.ButtonSetText(confirmBtn, "购买");
		GUI.ButtonSetText(leftConfirmBtn, "取消");
	elseif BourseUI.tabIndex == 2 then
		GUI.StaticSetText(title, "下架确认");
		if goodsInfo then
			if goodsInfo.enable == 1 then
				GUI.ButtonSetText(confirmBtn, "下架");
				GUI.ButtonSetText(leftConfirmBtn, "取消");
			elseif goodsInfo.enable == 2 then
				GUI.ButtonSetText(confirmBtn, "重新上架");
				GUI.ButtonSetText(leftConfirmBtn, "取出");
			end
		end
	end
end

function BourseUI.BuyPet(goodsInfo)
	--print("BourseUI.BuyPet")
	local petData = LD.GetQueryPetData();
	if petData == nil then
		return ;
	end

	local buyPopup = _gt.GetUI("buyPopup");
	GUI.SetVisible(buyPopup, true);
	local panelBg = _gt.GetUI("panelBg")
	local petDB = DB.GetOncePetByKey1(goodsInfo.id);
	
	local BuyPopup_petItem = _gt.GetUI("BuyPopup_petItem")
	local BuyPopup_itemInfo = _gt.GetUI("BuyPopup_itemInfo")
	GUI.SetVisible(BuyPopup_petItem, true)
	GUI.SetVisible(BuyPopup_itemInfo, false)
	
	if goodsInfo.guid then
		local icon = GUI.GetChild(BuyPopup_petItem,"icon");
		ItemIcon.BindPetDB(icon,petDB)
		GUI.ItemCtrlSetIconGray(icon, false)
		GUI.SetVisible(icon,true);
		GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Type])
		local starlevel = goodsInfo.star_lv
		UILayout.SetSmallStars(starlevel, 6, icon)
		
		local nameText = GUI.GetChild(BuyPopup_petItem,"nameText");
		GUI.SetVisible(nameText,true);
		GUI.StaticSetText(nameText,petDB.Name);
		local levelText = GUI.GetChild(BuyPopup_petItem,"levelText");
		GUI.SetVisible(levelText,true);
		GUI.StaticSetText(levelText,"等级:"..goodsInfo.level);
		local petTypeLabel = GUI.GetChild(BuyPopup_petItem,"petTypeLabel");
		GUI.SetVisible(petTypeLabel,true);
		GUI.ImageSetImageID(petTypeLabel,UIDefine.PetType[petDB.Type])
		local lockLabel = GUI.GetChild(BuyPopup_petItem,"lockLabel")
		GUI.SetVisible(lockLabel,true);
		local isLock = LD.GetPetState(PetState.Lock, goodsInfo.guid)
		if isLock then
			GUI.ImageSetImageID(lockLabel,"1800707020")
		else
			GUI.ImageSetImageID(lockLabel,"1800707080")
			GUI.SetVisible(lockLabel,false)
		end
		local lockText = GUI.GetChild(BuyPopup_petItem,"lockText");
		GUI.SetVisible(lockText,false)
	end

	local Popup_ItemTipsTxt = _gt.GetUI("Popup_ItemTipsTxt")
	GUI.StaticSetText(Popup_ItemTipsTxt, "宠物说明："..petDB.Info)
	
	local numBg = _gt.GetUI("BuyPopup_numBg");
	local numMinusBtn = _gt.GetUI("BuyPopup_numMinusBtn");
	local numInput = _gt.GetUI("BuyPopup_numInput");
	local numAddBtn = _gt.GetUI("BuyPopup_numAddBtn");
	if BourseUI.tabIndex == 1 then
		GUI.SetVisible(numBg, false);
		GUI.SetVisible(numMinusBtn, true);
		GUI.SetVisible(numInput, true);
		GUI.SetVisible(numAddBtn, true);
	elseif BourseUI.tabIndex == 2 then
		GUI.SetVisible(numBg, true);
		GUI.SetVisible(numMinusBtn, false);
		GUI.SetVisible(numInput, false);
		GUI.SetVisible(numAddBtn, false);
	end

	BourseUI.SetBuyTitle(panelBg, goodsInfo)
	BourseUI.SetPopupPanel(panelBg)
end

function BourseUI.SetPopupPanel(panelBg)
	local timeSelectBtn = GUI.GetChild(panelBg, "timeSelectBtn");
	if timeSelectBtn ~= nil then
		local selectedText = GUI.GetChild(timeSelectBtn, "selectedText");
		GUI.StaticSetText(selectedText, BourseUI.TimeData[BourseUI.popupTimeIndex]);
	end

	local priceBg = GUI.GetChild(panelBg, "priceBg");
	if priceBg then
		local coin = GUI.GetChild(priceBg, "coin");
		BourseUI.SetCoinIcon(coin);
	end

	local priceInput = GUI.GetChild(panelBg, "priceInput");
	if priceInput ~= nil then
		local coin = GUI.GetChild(priceInput, "coin");
		BourseUI.SetCoinIcon(coin);
	end

	local costBg = GUI.GetChild(panelBg, "costBg");
	if costBg ~= nil then
		local coin = GUI.GetChild(costBg, "coin");
		GUI.ImageSetImageID(coin, UIDefine.GetMoneyIcon(BourseUI["FeeBy" .. BourseUI.GetCurMoneyType()]));
	end

	local tradeCostBg = GUI.GetChild(panelBg, "tradeCostBg");
	if tradeCostBg ~= nil then
		local coin = GUI.GetChild(tradeCostBg, "coin");
		BourseUI.SetCoinIcon(coin);
	end

	local totalPriceBg = GUI.GetChild(panelBg, "totalPriceBg");
	local coin = GUI.GetChild(totalPriceBg, "coin");
	BourseUI.SetCoinIcon(coin);
	
	BourseUI.UpdatePopupAmount(panelBg);
end

function BourseUI.UpdatePopupAmount(panelBg)
	--print("BourseUI.popupState = "..tostring(BourseUI.popupState))
	local popup = BourseUI.GetCurPopup();
	if popup == nil then
		return ;
	end
	
	local maxAmount = 1;
	if BourseUI.popupState == 1 then
		maxAmount = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, BourseUI.popupGuid)) or tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, BourseUI.popupGuid, item_container_type.item_container_guard_bag))
		panelBg = _gt.GetUI("SellPopup_panelBg")
	elseif BourseUI.popupState == 3 then
		local goodsInfo = BourseUI.GetSellGoodsInfo();
		maxAmount = goodsInfo.amount;
	elseif BourseUI.popupState == 4 then
		local goodsInfo = BourseUI.GetSellGoodsInfo();
		maxAmount = goodsInfo.amount;
	elseif BourseUI.popupState == 5 then
		local goodsInfo = BourseUI.GetSellGoodsInfo();
		maxAmount = goodsInfo.amount;
	elseif BourseUI.popupState == 7 then
		local goodsInfo = BourseUI.GetBuyGoodsInfo();
		maxAmount = goodsInfo.amount;
	end

	if BourseUI.popupAmount < 1 then
		BourseUI.popupAmount = 1;
	elseif BourseUI.popupAmount > maxAmount then
		BourseUI.popupAmount = maxAmount;
	end
	local numInput = GUI.GetChild(popup, "numInput");
	GUI.EditSetCanEdit(numInput, true)
	if not panelBg then
		--print("not panelBg")
		panelBg = GUI.GetChild(popup, "panelBg");
	end
	local numMinusBtn = GUI.GetChild(panelBg, "numMinusBtn");
	local numAddBtn = GUI.GetChild(panelBg, "numAddBtn");
	GUI.ButtonSetShowDisable(numMinusBtn, true)
	GUI.ButtonSetShowDisable(numAddBtn, true)
	if BourseUI.popupState <= 2 or BourseUI.popupState >= 7 then
		--print("BourseUI.popupState = "..tostring(BourseUI.popupState))
		--print("BourseUI.popupGuid = "..tostring(BourseUI.popupGuid))
		--print("maxAmount = "..tostring(maxAmount))
		GUI.EditSetTextM(numInput, tostring(BourseUI.popupAmount));
		
		if BourseUI.popupAmount == 1 then
			GUI.ButtonSetShowDisable(numMinusBtn, false)
			if BourseUI.amountTimer ~= nil then
				BourseUI.amountTimer:Stop()
			end
		else
			GUI.ButtonSetShowDisable(numMinusBtn, true)
		end

		if BourseUI.popupAmount >= maxAmount then
			GUI.ButtonSetShowDisable(numAddBtn, false)
			if BourseUI.amountTimer ~= nil then
				BourseUI.amountTimer:Stop()
			end
		else
			GUI.ButtonSetShowDisable(numAddBtn, true)
		end
	elseif BourseUI.popupState == 3 then
		--print("maxAmount = "..tostring(maxAmount))
		--print("BourseUI.popupState = "..tostring(BourseUI.popupState))
		--print("BourseUI.popupGuid = "..tostring(BourseUI.popupGuid))
		GUI.EditSetTextM(numInput, tostring(BourseUI.popupAmount));
		GUI.EditSetCanEdit(numInput, false)
		GUI.ButtonSetShowDisable(numMinusBtn, false)
		if BourseUI.amountTimer ~= nil then
			BourseUI.amountTimer:Stop()
		end
		GUI.ButtonSetShowDisable(numAddBtn, false)
		if BourseUI.amountTimer ~= nil then
			BourseUI.amountTimer:Stop()
		end
	elseif BourseUI.popupState == 4 then
		--print("maxAmount = "..tostring(maxAmount))
		--print("BourseUI.popupState = "..tostring(BourseUI.popupState))
		--print("BourseUI.popupGuid = "..tostring(BourseUI.popupGuid))
		GUI.EditSetTextM(numInput, tostring(BourseUI.popupAmount));
		GUI.EditSetCanEdit(numInput, false)
		GUI.ButtonSetShowDisable(numMinusBtn, false)
		if BourseUI.amountTimer ~= nil then
			BourseUI.amountTimer:Stop()
		end
		GUI.ButtonSetShowDisable(numAddBtn, false)
		if BourseUI.amountTimer ~= nil then
			BourseUI.amountTimer:Stop()
		end
	else
		--print("BourseUI.popupState = "..tostring(BourseUI.popupState))
		--print("BourseUI.popupGuid = "..tostring(BourseUI.popupGuid))
		local numBg = GUI.GetChild(popup, "numBg");
		local num = GUI.GetChild(numBg, "num");
		GUI.StaticSetText(num, tostring(BourseUI.popupAmount))
	end

	BourseUI.UpdatePopupPrice();
end

function BourseUI.UpdatePopupPrice()
	--print("BourseUI.UpdatePopupPrice")
	local panelBg = _gt.GetUI("panelBg");
	if BourseUI.popupState <= 4 then
		if BourseUI.popupPrice <= BourseUI.popupMinPrice then
			BourseUI.popupPrice = BourseUI.popupMinPrice;
		end
	
		if BourseUI.popupPrice >= BourseUI.popupMaxPrice then
			BourseUI.popupPrice = BourseUI.popupMaxPrice;
		end
		
		local priceInput = GUI.GetChild(panelBg, "priceInput");
		GUI.EditSetTextM(priceInput, tostring(BourseUI.popupPrice));
	
		local fee = loadstring("local Seconds=" .. BourseUI.Seconds[BourseUI.popupTimeIndex] .. " Num=" .. BourseUI.popupAmount .. " return " .. BourseUI.Fee)();
		local costBg = GUI.GetChild(panelBg, "costBg");
		local num = GUI.GetChild(costBg, "num");
		GUI.StaticSetText(num, tostring(fee));
		local moneyEnum = UIDefine.GetMoneyEnum(BourseUI["FeeBy" .. BourseUI.GetCurMoneyType()]);
		local ownMoney = tonumber(tostring(CL.GetAttr(moneyEnum)));
		if ownMoney < fee then
			GUI.SetColor(num, UIDefine.RedColor);
		else
			GUI.SetColor(num, UIDefine.WhiteColor);
		end

		local tradeCostBg = GUI.GetChild(panelBg, "tradeCostBg");
		local num = GUI.GetChild(tradeCostBg, "num");
		local tax = math.ceil(BourseUI.popupAmount * BourseUI.popupPrice * BourseUI.Tax / 100);
		GUI.StaticSetText(num, tostring(tax));
	else
		local priceBg = GUI.GetChild(panelBg, "priceBg");
		local num = GUI.GetChild(priceBg, "num");
		GUI.StaticSetText(num, tostring(BourseUI.popupPrice));
	end

	local Buy_totalPrice_num = _gt.GetUI("Buy_totalPrice_num")
	GUI.StaticSetText(Buy_totalPrice_num, tostring(BourseUI.popupAmount * BourseUI.popupPrice));
	local Sell_totalPrice_num = _gt.GetUI("Sell_totalPrice_num")
	GUI.StaticSetText(Sell_totalPrice_num, tostring(BourseUI.popupAmount * BourseUI.popupPrice));
end

function BourseUI.SetCoinIcon(coin)
	GUI.ImageSetImageID(coin, UIDefine.GetMoneyIcon(BourseUI.GetCurMoneyType()));
end

function BourseUI.GetCurMoneyType()
	if BourseUI.moneyTypeIndex == 1 then
		return BourseUI.MoneyType1;
	elseif BourseUI.moneyTypeIndex == 2 then
		return BourseUI.moneyType2;
	end
end

function BourseUI.GetSellItemPrice(itemDB)
	local price, minPrice, maxPrice = 0, 0, 0;
	
	price = itemDB[BourseUI.PriceBeta];
	price = loadstring("return " .. price .. BourseUI["Price2_" .. BourseUI.GetCurMoneyType()])();
	price = math.ceil(price)
	local priceBase = math.ceil(price);
	minPrice = math.ceil(loadstring("return " .. price .. BourseUI["PriceMin"])());
	maxPrice = math.floor(loadstring("return " .. price .. BourseUI["PriceMax"])());

	if priceBase <= BourseUI["MinPrice_" .. BourseUI.GetCurMoneyType()] then
		priceBase = BourseUI["MinPrice_" .. BourseUI.GetCurMoneyType()];
	end

	if minPrice <= BourseUI["MinPrice_" .. BourseUI.GetCurMoneyType()] then
		minPrice = BourseUI["MinPrice_" .. BourseUI.GetCurMoneyType()];
	end

	if maxPrice <= BourseUI["MinPrice_" .. BourseUI.GetCurMoneyType()] then
		maxPrice = BourseUI["MinPrice_" .. BourseUI.GetCurMoneyType()];
	end

	return price, minPrice, maxPrice;
end

function BourseUI.GetSellPetPrice(petDB,petStar)
	local price, minPrice, maxPrice = 0, 0, 0;
	local Grade = petDB.Grade
	if not petStar then
		petStar = 1
	end
	if BourseUI.AuctionPetConfig then
		if BourseUI.AuctionPetConfig['Grade'..tostring(Grade)] and BourseUI.AuctionPetConfig['Grade'..tostring(Grade)][petStar] then
			minPrice = BourseUI.AuctionPetConfig['Grade'..tostring(Grade)][petStar].Min
			maxPrice = BourseUI.AuctionPetConfig['Grade'..tostring(Grade)][petStar].Max
		else
			minPrice = BourseUI["MinPrice_" .. BourseUI.GetCurMoneyType()];
			maxPrice = BourseUI.MaxPrice;
		end
	else
		minPrice = BourseUI["MinPrice_" .. BourseUI.GetCurMoneyType()];
		maxPrice = BourseUI.MaxPrice;
	end
	price = minPrice;
	return price, minPrice, maxPrice;
end

function BourseUI.OnItemSubTabBtnClick()
	BourseUI.subTabIndex = 1;
	BourseUI.QueryReq();
end

function BourseUI.OnPetSubTabBtnClick()
	BourseUI.subTabIndex = 2;
	BourseUI.QueryReq();
end

function BourseUI.CreateBuyPage()
	local panelBg = _gt.GetUI("panelBg")
	local buyPage = GUI.GroupCreate(panelBg, "buyPage", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
	_gt.BindName(buyPage, "tabPage1");
	GUI.SetVisible(buyPage, false);
	local dirBg = GUI.ImageCreate(buyPage, "dirBg", "1800400200", -380, 5, false, 270, 450)
	UILayout.SetSameAnchorAndPivot(dirBg, UILayout.Center);
	
	local dirScroll = GUI.LoopScrollRectCreate(dirBg, "dirScroll", 0, 0, 260, 430, "BourseUI", "CreateDirItem", "BourseUI", "RefreshDirScroll", 0, false, Vector2.New(250, 70), 1, UIAroundPivot.Top, UIAnchor.Top);
	GUI.ScrollRectSetChildSpacing(dirScroll, Vector2.New(0, 2));
	_gt.BindName(dirScroll, "dirScroll");
	
	local rightBg = GUI.ImageCreate(buyPage, "rightBg", "1800400200", 140, 5, false, 740, 450)
	UILayout.SetSameAnchorAndPivot(rightBg, UILayout.Center);
	
	local subDirScroll = GUI.LoopScrollRectCreate(rightBg, "subDirScroll", 0, 0, 730, 430, "BourseUI", "CreateSubDirItem", "BourseUI", "RefreshSubDirScroll", 0, false, Vector2.New(360, 105), 2, UIAroundPivot.Top, UIAnchor.Top);
	GUI.ScrollRectSetChildSpacing(subDirScroll, Vector2.New(5, 4));
	_gt.BindName(subDirScroll, "subDirScroll");
	
	local buyGoodsScroll = GUI.LoopScrollRectCreate(rightBg, "buyGoodsScroll", 0, 0, 730, 430, "BourseUI", "CreateBuyGoodsItem", "BourseUI", "RefreshBuyGoodsScroll", 0, false, Vector2.New(360, 105), 2, UIAroundPivot.Top, UIAnchor.Top);
	GUI.ScrollRectSetChildSpacing(buyGoodsScroll, Vector2.New(5, 4));
	_gt.BindName(buyGoodsScroll, "buyGoodsScroll");
	
	local refreshBtn = GUI.ButtonCreate(buyPage, "refreshBtn", "1800402080", 420, 265, Transition.ColorTint, "刷新", 160, 47, false);
	GUI.SetIsOutLine(refreshBtn, true);
	GUI.ButtonSetTextFontSize(refreshBtn, UIDefine.FontSizeXL);
	GUI.ButtonSetTextColor(refreshBtn, UIDefine.WhiteColor);
	GUI.SetOutLine_Color(refreshBtn, UIDefine.OutLine_BrownColor);
	GUI.SetOutLine_Distance(refreshBtn, UIDefine.OutLineDistance);
	GUI.RegisterUIEvent(refreshBtn, UCE.PointerClick, "BourseUI", "OnRefreshBtnClick");
	GUI.SetEventCD(refreshBtn,UCE.PointerClick,1);
	
	
	local backBtn = GUI.ButtonCreate(buyPage, "backBtn", "1800402080", 250, 265, Transition.ColorTint, "返回", 160, 47, false);
	GUI.SetIsOutLine(backBtn, true);
	GUI.ButtonSetTextFontSize(backBtn, UIDefine.FontSizeXL);
	GUI.ButtonSetTextColor(backBtn, UIDefine.WhiteColor);
	GUI.SetOutLine_Color(backBtn, UIDefine.OutLine_BrownColor);
	GUI.SetOutLine_Distance(backBtn, UIDefine.OutLineDistance);
	GUI.RegisterUIEvent(backBtn, UCE.PointerClick, "BourseUI", "OnBackBtnClick");
	_gt.BindName(backBtn, "backBtn");
	
	local pageCtrl = GUI.ImageCreate(buyPage, "pageCtrl", "1800001040", 20, 265, false, 140, 48)
	UILayout.SetSameAnchorAndPivot(pageCtrl, UILayout.Center);
	
	local pageText = GUI.CreateStatic(pageCtrl, "pageText", "1/1", 0, 0, 140, 48);
	GUI.SetColor(pageText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(pageText, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(pageText, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(pageText, UILayout.Center);
	_gt.BindName(pageText, "pageText");
	
	local pageMinusBtn = GUI.ButtonCreate(pageCtrl, "pageMinusBtn", "1801202120", -105, -1, Transition.ColorTint);
	GUI.SetEulerAngles(pageMinusBtn, Vector3.New(0, 0, 90));
	UILayout.SetSameAnchorAndPivot(pageMinusBtn, UILayout.Center);
	GUI.RegisterUIEvent(pageMinusBtn, UCE.PointerClick, "BourseUI", "OnPageMinusBtnClick");
	_gt.BindName(pageMinusBtn, "pageMinusBtn");
	GUI.SetEventCD(pageMinusBtn,UCE.PointerClick,0.5)
	
	local pageAddBtn = GUI.ButtonCreate(pageCtrl, "pageAddBtn", "1801202130", 105, -1, Transition.ColorTint);
	GUI.SetEulerAngles(pageAddBtn, Vector3.New(0, 0, 90));
	UILayout.SetSameAnchorAndPivot(pageAddBtn, UILayout.Center);
	GUI.RegisterUIEvent(pageAddBtn, UCE.PointerClick, "BourseUI", "OnPageAddBtnClick");
	_gt.BindName(pageAddBtn, "pageAddBtn");
	GUI.SetEventCD(pageAddBtn,UCE.PointerClick,0.5)
	
	local searchInput = GUI.EditCreate(buyPage, "searchInput", "1800001040", "请输入要查找的商品", -375, 265, Transition.ColorTint, "system", 280, 48, 20, 8, InputType.Standard)
	UILayout.SetSameAnchorAndPivot(searchInput, UILayout.Center);
	GUI.EditSetLabelAlignment(searchInput, TextAnchor.MiddleLeft)
	GUI.EditSetTextColor(searchInput, UIDefine.BrownColor)
	GUI.EditSetFontSize(searchInput, UIDefine.FontSizeM)
	GUI.SetPlaceholderTxtColor(searchInput, UIDefine.GrayColor)
	GUI.EditSetPlaceholderAlignment(searchInput, TextAnchor.MiddleCenter)
	GUI.EditSetMaxCharNum(searchInput, 20);
	GUI.RegisterUIEvent(searchInput, UCE.EndEdit, "BourseUI", "OnSearchInputEdit")
	_gt.BindName(searchInput, "searchInput");
	
	local clearSearchBtn = GUI.ButtonCreate(searchInput, "clearSearchBtn", "1800408220", -10, 0, Transition.ColorTint);
	UILayout.SetSameAnchorAndPivot(clearSearchBtn, UILayout.Right);
	GUI.RegisterUIEvent(clearSearchBtn, UCE.PointerClick, "BourseUI", "OnClearSearchBtnClick");
	_gt.BindName(clearSearchBtn, "clearSearchBtn");
	GUI.SetVisible(clearSearchBtn, false);
	
	local searchBtn = GUI.ButtonCreate(searchInput, "searchBtn", "1800802010", 50, 1, Transition.ColorTint);
	UILayout.SetSameAnchorAndPivot(searchBtn, UILayout.Right);
	GUI.RegisterUIEvent(searchBtn, UCE.PointerClick, "BourseUI", "OnSearchBtnClick");
	_gt.BindName(searchBtn, "searchBtn");
	
	local priceSortBtn = GUI.ButtonCreate(buyPage, "priceSortBtn", "1801202140", 320, -245, Transition.ColorTint, "", 120, 50, false);
	UILayout.SetSameAnchorAndPivot(priceSortBtn, UILayout.Center);
	GUI.RegisterUIEvent(priceSortBtn, UCE.PointerClick, "BourseUI", "OnPriceSortBtnClick");
	_gt.BindName(priceSortBtn, "priceSortBtn");
	
	local selectedText = GUI.CreateStatic(priceSortBtn, "selectedText", "价格", -10, 0, 100, 50);
	GUI.SetColor(selectedText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(selectedText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(selectedText, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(selectedText, UILayout.Center);
	
	local arrow = GUI.ImageCreate(priceSortBtn, "arrow", "1801208080", 35, -1, false, 17, 20)
	UILayout.SetSameAnchorAndPivot(arrow, UILayout.Center);
	
	local levelSelectBtn = GUI.ButtonCreate(buyPage, "levelSelectBtn", "1801202140", 195, -245, Transition.ColorTint, "", 120, 50, false);
	UILayout.SetSameAnchorAndPivot(levelSelectBtn, UILayout.Center);
	GUI.RegisterUIEvent(levelSelectBtn, UCE.PointerClick, "BourseUI", "OnLevelSelectBtnClick");
	_gt.BindName(levelSelectBtn, "levelSelectBtn");
	
	local selectedText = GUI.CreateStatic(levelSelectBtn, "selectedText", "级别", -10, 0, 100, 50);
	GUI.SetColor(selectedText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(selectedText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(selectedText, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(selectedText, UILayout.Center);
	
	local arrow = GUI.ImageCreate(levelSelectBtn, "arrow", "1801208090", 35, 1)
	UILayout.SetSameAnchorAndPivot(arrow, UILayout.Center);
	
	local sexSelectBtn = GUI.ButtonCreate(buyPage, "sexSelectBtn", "1801202140", 70, -245, Transition.ColorTint, "", 120, 50, false);
	UILayout.SetSameAnchorAndPivot(sexSelectBtn, UILayout.Center);
	GUI.RegisterUIEvent(sexSelectBtn, UCE.PointerClick, "BourseUI", "OnSexSelectBtnClick");
	_gt.BindName(sexSelectBtn, "sexSelectBtn");
	
	local selectedText = GUI.CreateStatic(sexSelectBtn, "selectedText", "性别", -10, 0, 100, 50);
	GUI.SetColor(selectedText, UIDefine.BrownColor);
	GUI.StaticSetFontSize(selectedText, UIDefine.FontSizeM)
	GUI.StaticSetAlignment(selectedText, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(selectedText, UILayout.Center);
	
	local arrow = GUI.ImageCreate(sexSelectBtn, "arrow", "1801208090", 35, 1)
	UILayout.SetSameAnchorAndPivot(arrow, UILayout.Center);
	
	return buyPage
end

function BourseUI.OnRefreshBtnClick()
	BourseUI.QueryReq();
end

function BourseUI.OnPriceSortBtnClick()
	if BourseUI.priceSort == 1 then
		BourseUI.priceSort = 2;
		BourseUI.UpdatePriceSortBtn();
	elseif BourseUI.priceSort == 2 then
		BourseUI.priceSort = 1;
		BourseUI.UpdatePriceSortBtn()
	end
	BourseUI.QueryReq();
end

function BourseUI.UpdatePriceSortBtn()
	local priceSortBtn = _gt.GetUI("priceSortBtn")
	local arrow = GUI.GetChild(priceSortBtn, "arrow");
	if BourseUI.priceSort == 1 then
		GUI.SetEulerAngles(arrow, Vector3.New(0, 0, 0));
	elseif BourseUI.priceSort == 2 then
		GUI.SetEulerAngles(arrow, Vector3.New(0, 0, 180));
	end
end

function BourseUI.CreateBuyGoodsItem()
	local sellGoodsScroll = _gt.GetUI("sellGoodsScroll");
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(sellGoodsScroll);
	local buyGoodsItem = GUI.ButtonCreate(sellGoodsScroll, "buyGoodsItem" .. curCount, "1800400360", 0, 0, Transition.ColorTint);
	GUI.RegisterUIEvent(buyGoodsItem, UCE.PointerClick, "BourseUI", "OnBuyGoodsItemClick");
	local itemIcon = ItemIcon.Create(buyGoodsItem, "itemIcon", -130, 1);
	local name = GUI.CreateStatic(buyGoodsItem, "name", "名称", 100, 15, 250, 35)
	GUI.SetColor(name, UIDefine.BrownColor)
	GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
	UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft);
	GUI.StaticSetAlignment(ownText, TextAnchor.MiddleLeft)
	local coinBg = GUI.ImageCreate(buyGoodsItem, "coinBg", "1800700010", 100, 20, false, 200, 35)
	UILayout.SetSameAnchorAndPivot(coinBg, UILayout.Left);
	local coin = GUI.ImageCreate(coinBg, "coin", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 0, -1, false, 36, 36)
	UILayout.SetSameAnchorAndPivot(coin, UILayout.Left);
	local num = GUI.CreateStatic(coinBg, "num", "100", 15, -1, 160, 30)
	GUI.SetColor(num, UIDefine.WhiteColor)
	GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
	GUI.SetAnchor(num, UIAnchor.Center)
	GUI.SetPivot(num, UIAroundPivot.Center)
	GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
	local collectionBtn = GUI.ButtonCreate(buyGoodsItem, "collectionBtn", "1801302100", 149, -29, Transition.ColorTint, "", 45, 45, false)
	GUI.RegisterUIEvent(collectionBtn, UCE.PointerClick, "BourseUI", "OnCollectionBtnClick");
	local SpecialBuyerIcon = GUI.ImageCreate(buyGoodsItem, "SpecialBuyerIcon", "1800408170", 149, 18, false, 42, 53)
	GUI.SetVisible(SpecialBuyerIcon, false)
	return buyGoodsItem;
end

function BourseUI.OnCollectionBtnClick(guid)
	local collectionBtn = GUI.GetByGuid(guid);
	local index = tonumber(GUI.GetData(collectionBtn, "Index"));
	local goodsInfo = BourseUI.GetBuyGoodsInfoByIndex(index);

	if BourseUI.CheckInCollection(goodsInfo.guid) then
		test("RemoveCollection");
		CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "RemoveCollection",goodsInfo.guid);
	else
		test("SetCollection");
		CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "SetCollection", goodsInfo.guid);
	end

	if BourseUI.GetCurStage()==0 then
		BourseUI.QueryReq();
	else
		BourseUI.checkCollection = true;
		CL.SendNotify(NOTIFY.SubmitForm, "FormAuction", "GetCollection");
	end
end


function BourseUI.RefreshBuyGoodsScroll(parameter)		--出售页右侧循环列表刷新
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local buyGoodsItem = GUI.GetByGuid(guid);
	index = index + 1;	
	local goodsInfo = BourseUI.GetBuyGoodsInfoByIndex(index)
	if goodsInfo == nil then
		GUI.SetVisible(buyGoodsItem, false);
		return ;
	end

	local itemIcon = GUI.GetChild(buyGoodsItem, "itemIcon");
	local name = GUI.GetChild(buyGoodsItem, "name");
	local coinBg = GUI.GetChild(buyGoodsItem, "coinBg");
	local coin = GUI.GetChild(coinBg, "coin");
	local num = GUI.GetChild(coinBg, "num");
	local collectionBtn = GUI.GetChild(buyGoodsItem, "collectionBtn");
	local SpecialBuyerIcon = GUI.GetChild(buyGoodsItem, "SpecialBuyerIcon");
	if goodsInfo.type == 1 then
		local itemDB = DB.GetOnceItemByKey1(goodsInfo.id);
		ItemIcon.BindItemId(itemIcon, goodsInfo.id);
		local starsBg = GUI.GetChild(itemIcon,"starsBg")
		if starsBg then
			GUI.SetVisible(starsBg,false)
		end
		GUI.StaticSetText(name, itemDB.Name);
	elseif goodsInfo.type == 2 then
		local petDB = DB.GetOncePetByKey1(goodsInfo.id);
		ItemIcon.BindPetDB(itemIcon, petDB);
		GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Type])
		GUI.StaticSetText(name, petDB.Name);
		local starsBg = GUI.GetChild(itemIcon,"starsBg")
		if starsBg then
			GUI.SetVisible(starsBg,true)
		end
		local starlevel = goodsInfo.star_lv
		if not starlevel then
			starlevel = 1
		end
		UILayout.SetSmallStars(starlevel, 6, itemIcon)
	end
	if goodsInfo.SpecialBuyer and goodsInfo.SpecialBuyer ~= "" and goodsInfo.SpecialBuyer ~= "无" then
		GUI.SetVisible(SpecialBuyerIcon, true)
	else
		GUI.SetVisible(SpecialBuyerIcon, false)
	end

	GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, goodsInfo.amount)
	GUI.StaticSetText(num, goodsInfo.coin_value);
	GUI.ImageSetImageID(coin, UIDefine.GetAttrIconByAttrId(goodsInfo.coin_type));
	GUI.SetData(collectionBtn, "Index", index);
	if BourseUI.CheckInCollection(goodsInfo.guid) then
		GUI.ButtonSetImageID(collectionBtn, "1801302110");
	else
		GUI.ButtonSetImageID(collectionBtn, "1801302100");
	end

end

function BourseUI.OnSearchInputEdit()
	local searchInput = _gt.GetUI("searchInput");
	local clearSearchBtn = _gt.GetUI("clearSearchBtn");
	local content = GUI.EditGetTextM(searchInput)
	if content == "" then
		GUI.SetVisible(clearSearchBtn, false);
	else
		GUI.SetVisible(clearSearchBtn, true);
	end
end

function BourseUI.OnSearchBtnClick()
	local searchInput = _gt.GetUI("searchInput");
	BourseUI.searchContent = GUI.EditGetTextM(searchInput);
	BourseUI.QueryReq();
end

function BourseUI.OnClearSearchBtnClick(guid)
	BourseUI.SetSearchContent("");
	BourseUI.QueryReq();
end

function BourseUI.SetSearchContent(content)
	BourseUI.searchContent = content
	
	local searchInput = _gt.GetUI("searchInput");
	GUI.EditSetTextM(searchInput, content)
	local clearSearchBtn = _gt.GetUI("clearSearchBtn");
	GUI.SetVisible(clearSearchBtn, content ~= "")
end

function BourseUI.OnBackBtnClick()
	BourseUI.goodsPageIndex = 1
	BourseUI.subDirIndex = 0;
	BourseUI.Refresh();
end

function BourseUI.OnPageMinusBtnClick()
	local curStage = BourseUI.GetCurStage();
	if curStage == 0 then
		if BourseUI.goodsPageIndex > 1 then
			BourseUI.goodsPageIndex = BourseUI.goodsPageIndex - 1;
			BourseUI.Refresh();
		else
			CL.SendNotify(NOTIFY.ShowBBMsg, "第一页了");
		end
	elseif curStage == 1 then
		if BourseUI.subDirPageIndex > 1 then
			BourseUI.subDirPageIndex = BourseUI.subDirPageIndex - 1;
			BourseUI.Refresh();
		else
			CL.SendNotify(NOTIFY.ShowBBMsg, "第一页了");
		end
	elseif curStage == 2 then
		if BourseUI.goodsPageIndex > 1 then
			BourseUI.goodsPageIndex = BourseUI.goodsPageIndex - 1;
			BourseUI.QueryReq();
		else
			CL.SendNotify(NOTIFY.ShowBBMsg, "第一页了");
		end
	end
end

function BourseUI.OnPageAddBtnClick()
	local curStage = BourseUI.GetCurStage();
	if curStage == 0 then
		if BourseUI.goodsPageIndex < BourseUI.GetMaxPage() then
			BourseUI.goodsPageIndex = BourseUI.goodsPageIndex + 1;
			BourseUI.Refresh();
		else
			CL.SendNotify(NOTIFY.ShowBBMsg, "最后一页了");
		end
	elseif curStage == 1 then
		if BourseUI.subDirPageIndex < BourseUI.GetMaxPage() then
			BourseUI.subDirPageIndex = BourseUI.subDirPageIndex + 1;
			BourseUI.Refresh();
		else
			CL.SendNotify(NOTIFY.ShowBBMsg, "最后一页了");
		end
	elseif curStage == 2 then
		if BourseUI.goodsPageIndex < BourseUI.GetMaxPage() then
			BourseUI.goodsPageIndex = BourseUI.goodsPageIndex + 1;
			BourseUI.QueryReq();
		else
			CL.SendNotify(NOTIFY.ShowBBMsg, "最后一页了");
		end
	end
	
end

function BourseUI.CreateSubDirItem()
	local subDirScroll = _gt.GetUI("subDirScroll")
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(subDirScroll);
	local subDirItem = GUI.ButtonCreate(subDirScroll, "subDirItem" .. curCount, "1800400360", 0, 0, Transition.ColorTint);
	GUI.RegisterUIEvent(subDirItem, UCE.PointerClick, "BourseUI", "OnSubDirItemClick");
	
	local itemIcon = ItemIcon.Create(subDirItem, "itemIcon", -120, 2)
	
	local name = GUI.CreateStatic(subDirItem, "name", "子类别", 110, 0, 250, 50);
	GUI.SetColor(name, UIDefine.BrownColor);
	GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(name, TextAnchor.MiddleLeft);
	UILayout.SetSameAnchorAndPivot(name, UILayout.Left);
	
	local count = GUI.CreateStatic(subDirItem, "count", "0", -20, 30, 100, 50);
	GUI.SetColor(count, UIDefine.BrownColor);
	GUI.StaticSetFontSize(count, UIDefine.FontSizeL)
	GUI.StaticSetAlignment(count, TextAnchor.MiddleRight);
	UILayout.SetSameAnchorAndPivot(count, UILayout.Right);
	
	return subDirItem;
end

function BourseUI.OnSubDirItemClick(guid)
	local subDirItem = GUI.GetByGuid(guid);
	local index = GUI.ButtonGetIndex(subDirItem)
	index = index + 1;
	
	BourseUI.subDirIndex = index;
	BourseUI.levelIndex = 0;
	BourseUI.sexIndex = 0;
	BourseUI.SetSearchContent("");
	BourseUI.QueryReq();
end

function BourseUI.RefreshSubDirScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]) + 1;
	local subDirItem = GUI.GetByGuid(guid);
	local itemIcon = GUI.GetChild(subDirItem, "itemIcon")
	local name = GUI.GetChild(subDirItem, "name")
	local count = GUI.GetChild(subDirItem, "count")
	local subDirData = BourseUI.GetSubDirDataByIndex(index);
	--local inspect = require("inspect")
	--print(inspect(subDirData))
	if subDirData == nil then
		GUI.SetVisible(subDirItem, false);
	else
		GUI.SetVisible(subDirItem, true);
		GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, subDirData.Icon);
		if subDirData.Class == 11 then
			GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,70,69);
		end
		GUI.StaticSetText(name, subDirData.Name);
		if BourseUI.subDirGoodsCount[index] ~= nil then
			local curIndex = (BourseUI.subDirPageIndex - 1) * countPerPage + index;
			GUI.StaticSetText(count, BourseUI.subDirGoodsCount[curIndex]);
		end
	end
end

function BourseUI.OnDirItemClick(guid)
	local dirItem = GUI.GetByGuid(guid);
	local index = GUI.CheckBoxExGetIndex(dirItem)
	
	BourseUI.SetDirIndex(index)
end

function BourseUI.SetDirIndex(index)
	BourseUI.dirIndex = index;
	BourseUI.subDirIndex = 0;
	BourseUI.subDirPageIndex = 1;
	BourseUI.goodsPageIndex = 1;
	BourseUI.QueryReq();
end

function BourseUI.CreateDirItem()
	local dirScroll = _gt.GetUI("dirScroll");
	local curCount = GUI.LoopScrollRectGetChildInPoolCount(dirScroll);
	local dirItem = GUI.CheckBoxExCreate(dirScroll, "dirItem" .. curCount, "1800400410", "1800400411", 0, 0, false, 250, 70)
	GUI.RegisterUIEvent(dirItem, UCE.PointerClick, "BourseUI", "OnDirItemClick");
	local name = GUI.CreateStatic(dirItem, "name", "子目录", 0, 2, 250, 50);
	GUI.SetColor(name, UIDefine.BrownColor);
	GUI.StaticSetFontSize(name, UIDefine.FontSizeXL)
	GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter);
	UILayout.SetSameAnchorAndPivot(name, UILayout.Center);
	
	local arrow = GUI.ImageCreate(dirItem, "arrow", "1801208070", -22, 0)
	UILayout.SetSameAnchorAndPivot(arrow, UILayout.Right);
	
	return dirItem;
end

function BourseUI.RefreshDirScroll(parameter)
	parameter = string.split(parameter, "#");
	local guid = parameter[1];
	local index = tonumber(parameter[2]);
	local dirItem = GUI.GetByGuid(guid);

	GUI.CheckBoxExSetCheck(dirItem, index == BourseUI.dirIndex);

	local name = GUI.GetChild(dirItem, "name");

	if index == 0 then
		GUI.StaticSetText(name, "收藏夹");
	else
		GUI.StaticSetText(name, BourseUI.TotalCatalog[index]);
	end
end

function BourseUI.InitAllowList()
	BourseUI.AllowList = {}
	--local inspect = require("inspect")
	--print(inspect(BourseUI.CategoryList))
	for a, b in ipairs(BourseUI.TotalCatalog) do --BourseUI.TotalCatalog = {"装备", "制造书", "打造强化", "特技卷轴", "特效卷轴", "角色培养", "宠物", "宠物秘籍", "宠物装备", "宠物培养", "侍从", "天赋", "杂货"}
		if BourseUI.CategoryList[b] then
			for k, v in pairs(BourseUI.CategoryList[b]) do
				if v.ItemID then
					BourseUI.AllowList["ItemID_" .. v.ItemID] = v
					BourseUI.AllowList["ItemID_" .. v.ItemID]["Class"] = a
					BourseUI.AllowList["ItemID_" .. v.ItemID]["Team"] = k
				elseif v.ItemList then
					for c, d in ipairs(v.ItemList) do
						BourseUI.AllowList["ItemID_" .. d] = v
						BourseUI.AllowList["ItemID_" .. d]["Class"] = a
						BourseUI.AllowList["ItemID_" .. d]["Team"] = k
					end
				elseif v.Item_Type then
					if not BourseUI.AllowList['ItemType_' .. v.Item_Type] then
						BourseUI.AllowList['ItemType_' .. v.Item_Type] = {}
					end
					if v.Item_Type == 1 then
						if v.Sec_Type then
							if not BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type] then
								BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type] = {}
							end
							if v.Sec_SubType then
								if not BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] then
									BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] = {}
								end
								if v.Grade_Type then
									BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type] = v
									BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Class"] = a
									BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Team"] = k
								else
									BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"] = v
									BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Class"] = a
									BourseUI.AllowList['ItemType_1']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Team"] = k
								end
							end
						end
					elseif v.Item_Type == 2 then
						if v.Sec_Type then
							if not BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type] then
								BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type] = {}
							end
							if v.Sec_SubType then
								if not BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] then
									BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] = {}
								end
								if v.Grade_Type then
									BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type] = v
									BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Class"] = a
									BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Team"] = k
								else
									BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"] = v
									BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Class"] = a
									BourseUI.AllowList['ItemType_2']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Team"] = k
								end
							end
						end
					elseif v.Item_Type == 3 then
						if v.Sec_Type then
							if not BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type] then
								BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type] = {}
							end
							if v.Sec_SubType then
								if not BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] then
									BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] = {}
								end
								if v.Grade_Type then
									BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type] = v
									BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Class"] = a
									BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Team"] = k
								else
									BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"] = v
									BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Class"] = a
									BourseUI.AllowList['ItemType_3']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Team"] = k
								end
							end
						end
					elseif v.Item_Type == 6 then
						if v.Sec_Type then
							if not BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type] then
								BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type] = {}
							end
							if v.Sec_SubType then
								if not BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] then
									BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] = {}
								end
								if v.Grade_Type then
									BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type] = v
									BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Class"] = a
									BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Team"] = k
								else
									BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"] = v
									BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Class"] = a
									BourseUI.AllowList['ItemType_6']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Team"] = k
								end
							end
						end
					elseif v.Item_Type == 7 then
						if v.Sec_Type then
							if not BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type] then
								BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type] = {}
							end
							if v.Sec_SubType then
								if not BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] then
									BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType] = {}
								end
								if v.Grade_Type then
									BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type] = v
									BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Class"] = a
									BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_" .. v.Grade_Type]["Team"] = k
								else
									BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"] = v
									BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Class"] = a
									BourseUI.AllowList['ItemType_7']['Sec_Type_' .. v.Sec_Type]['Sec_SubType_' .. v.Sec_SubType]["Grade_0"]["Team"] = k
								end
							end
						end
					end
				elseif v.Pet_Type then
					if type(v.Pet_Type) == "table" then
						for s, d in ipairs(v.Pet_Type) do
							if not BourseUI.AllowList['PetType_' .. d] then
								BourseUI.AllowList['PetType_' .. d] = {}
								BourseUI.AllowList['PetType_' .. d]['Class'] = a
								BourseUI.AllowList['PetType_' .. d]['Team'] = k
							end
							if v.CarryLevel then
								BourseUI.AllowList['PetType_' .. d]['CarryLevel_' .. v.CarryLevel] = v
								BourseUI.AllowList['PetType_' .. d]['CarryLevel_' .. v.CarryLevel]['Class'] = a
								BourseUI.AllowList['PetType_' .. d]['CarryLevel_' .. v.CarryLevel]['Team'] = k
							end
						end
					elseif type(v.Pet_Type) == "number" then
						BourseUI.AllowList['PetType_' .. v.Pet_Type] = v
						BourseUI.AllowList['PetType_' .. v.Pet_Type]['Class'] = a
						BourseUI.AllowList['PetType_' .. v.Pet_Type]['Team'] = k
						if v.CarryLevel then
							BourseUI.AllowList['PetType_' .. v.Pet_Type]['CarryLevel_' .. v.CarryLevel] = v
							BourseUI.AllowList['PetType_' .. v.Pet_Type]['CarryLevel_' .. v.CarryLevel]['Class'] = a
							BourseUI.AllowList['PetType_' .. v.Pet_Type]['CarryLevel_' .. v.CarryLevel]['Team'] = k
						end
					end
				end
			end
		end
	end
end

function BourseUI.CheckItemCanSell(itemId)		--0000
	if BourseUI.ShieldingItemList['Id_' .. itemId] == 1 then
		return false
	end
	local tb_BasicInfo = DB.GetOnceItemByKey1(itemId);
	local itemType = tb_BasicInfo.Type
	local secType = tb_BasicInfo.Subtype
	local secsubType = tb_BasicInfo.Subtype2
	--local TypeInfo = TypeTable['Type_'..itemType]
	local itemGrade = tb_BasicInfo.Grade
	local itemLv = tb_BasicInfo.Itemlevel
	local tb_Screen = BourseUI.AllowList["ItemID_" .. itemId]
	if tb_Screen == nil then
		--local tb_Types = Item
		--local secType = tb_Types[TypeInfo.Sec_Type]
		--local secsubType = tb_Types[TypeInfo.Sec_SubType]
		if BourseUI.AllowList['ItemType_' .. itemType] then
			if BourseUI.AllowList['ItemType_' .. itemType]['Sec_Type_' .. secType] then
				if BourseUI.AllowList['ItemType_' .. itemType]['Sec_Type_' .. secType]['Sec_SubType_' .. secsubType] then
					tb_Screen = BourseUI.AllowList['ItemType_' .. itemType]['Sec_Type_' .. secType]['Sec_SubType_' .. secsubType]['Grade_' .. itemGrade]
					if not tb_Screen then
						tb_Screen = BourseUI.AllowList['ItemType_' .. itemType]['Sec_Type_' .. secType]['Sec_SubType_' .. secsubType]['Grade_0']
					end
				end
			end
		end
	end
	--local inspect = require("inspect")
	if tb_Screen then
		--print(inspect(tb_Screen))
		if type(tb_Screen) == "table" then
			if tb_Screen.minLevel then
				if itemLv < tb_Screen.minLevel then
					return false;
				end
			end
			if tb_Screen.maxLevel then
				if itemLv > tb_Screen.maxLevel then
					return false;
				end
			end
			if tb_Screen.minGrade then
				if itemGrade < tb_Screen.minGrade then
					return false;
				end
			end
			if tb_Screen.maxGrade then
				if itemGrade > tb_Screen.maxGrade then
					return false;
				end
			end
			--print("tb_Screen.Name = "..tb_Screen.Name)
			return true;
		end
	else
		return false
	end
	return false;
end

function BourseUI.CheckPetCanSell(petId)
	local petDB = DB.GetOncePetByKey1(petId)
	local petType = petDB.Type
	if BourseUI.AllowList['PetType_' .. petType] then
		local tb_Screen = BourseUI.AllowList['PetType_' .. petType]
		if tb_Screen then
			return true;
		end
	end
	return false;
end

function BourseUI.OnCommerceUITabBtnClick()
	UILayout.OnTabClick(2, Right_tabList)
	GUI.OpenWnd("CommerceUI");
	BourseUI.OnExit()
end

function BourseUI.OnBourseUITabBtnClick() 
	UILayout.OnTabClick(2, Right_tabList)
end