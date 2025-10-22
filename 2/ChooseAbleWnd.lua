ChooseAbleWnd = {}

local _gt = UILayout.NewGUIDUtilTable()

ItemCenterX = 0
ItemCenterY = 95

local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorOutline = Color.New(162 / 255, 75 / 255, 21 / 255)
local tipColor = Color.New(208 / 255, 140 / 255, 15 / 255, 255 / 255)
local contentColor = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)

local QualityRes = 
{
  1800400330,1800400100,1800400110,1800400120,1800400320,1800400320,1801601160
}

local Chindextable = {}
local ChlastNum = {}

function ChooseAbleWnd.OnShow()
	
end

function ChooseAbleWnd.Main()
	test("ChooseAbleWnd.Main")
	ChooseAbleWnd['item'] = {}
	local panel = GUI.WndCreateWnd("ChooseAbleWnd", "ChooseAbleWnd", 0, 0, eCanvasGroup.Normal)
	ChooseAbleWnd['panel'] = panel
	GUI.SetData(panel, "index", 0)
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)
	
	--CL.RegisterMessage(GM.ShowWnd,"ChooseAbleWnd" , "OpenWnd")
	--CL.RegisterMessage(GM.CloseWnd,"ChooseAbleWnd" , "OnCloseWndCallBack")
	
	local panelCover = GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    GUI.SetAnchor(panelCover, UIAnchor.Center)
    GUI.SetPivot(panelCover, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)

    -- 底图
    local panelBg = GUI.ImageCreate(panel, "PanelBg", "1800600182", 0, 20, false, 510, 600)
    GUI.SetAnchor(panelBg, UIAnchor.Center)
    GUI.SetPivot(panelBg, UIAroundPivot.Center)
	
	-- 底图盖子
	local panelBgTit = GUI.ImageCreate(panelBg, "PanelBgTit", "1800600183", 0, -300, false, 510, 70)
    GUI.SetAnchor(panelBgTit, UIAnchor.Center)
    GUI.SetPivot(panelBgTit, UIAroundPivot.Center)
	
	-- 标题底板
    local titleBg = GUI.ImageCreate(panelBg, "TitleBg", "1800600190", 0, -28, false, 220, 49)
    GUI.SetAnchor(titleBg, UIAnchor.Top)
    GUI.SetPivot(titleBg, UIAroundPivot.Top)

    -- 标题
    local titleTxt = GUI.CreateStatic(titleBg, "TitleText", "选择", 88, 0, 230, 35)
    GUI.SetAnchor(titleTxt, UIAnchor.Center)
    GUI.SetPivot(titleTxt, UIAroundPivot.Center)
    GUI.StaticSetFontSize(titleTxt, 26)
    GUI.SetColor(titleTxt, colorDark)
	
	--滑动区域背景
	local bgListArea = GUI.ImageCreate(panelBg,"bgListArea","1800400010",0,-25,false, 430, 420);
	GUI.SetAnchor(bgListArea,UIAnchor.Center);
	GUI.SetPivot(bgListArea,UIAroundPivot.Center);
	
	--选择按钮
    local GoBtn = GUI.ButtonCreate(panelBg, "GoBtn", "1800402080", 0, -50, Transition.ColorTint, "选择", 120, 46, false)
    GUI.SetAnchor(GoBtn, UIAnchor.Bottom)
    GUI.SetPivot(GoBtn, UIAroundPivot.Center)
	GUI.ButtonSetTextFontSize(GoBtn, 26);
	GUI.ButtonSetTextColor(GoBtn, colorWhite);
    GUI.SetIsOutLine(GoBtn, true)
	GUI.SetOutLine_Setting(GoBtn,OutLineSetting.OutLine_Orange2_1)
    GUI.SetOutLine_Color(GoBtn, colorOutline)
    GUI.SetOutLine_Distance(GoBtn, 1)
    GUI.RegisterUIEvent(GoBtn, UCE.PointerClick, "ChooseAbleWnd", "OnClickGoBtn")

    --关闭
    local closeBtn = GUI.ButtonCreate(panelBg, "ClosePanelBtn", "1800302120", -5, -25, Transition.ColorTint)
    GUI.SetAnchor(closeBtn, UIAnchor.TopRight)
    GUI.SetPivot(closeBtn, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "ChooseAbleWnd", "OnClosePanel")
	
end

function ChooseAbleWnd.CreatItem()
	--滑动条
	if not ChooseAbleWnd.RewardRoller then
		test("创建滑动条")
		local bgListArea = GUI.Get("ChooseAbleWnd/PanelBg/bgListArea")
		local long = 1
		if ChooseAbleWnd['ItemList'] then
			long = #ChooseAbleWnd['ItemList']
		end
		local RewardRoller = GUI.LoopScrollRectCreate(bgListArea, "RewardRoller", 0, 0, 450, 400, "ChooseAbleWnd", "CreatItemListS", "ChooseAbleWnd", "RefreshItemList", 0, false, Vector2.New(410, 110), 1, UIAroundPivot.Top, UIAnchor.Top);
		ChooseAbleWnd.RewardRoller = RewardRoller
		GUI.LoopScrollRectSetTotalCount(RewardRoller, long)
		Chindextable = {}
		ChlastNum = {}
		
		local panelBg = GUI.Get("ChooseAbleWnd/PanelBg")
		local promptmsg = GUI.CreateStatic(panelBg, "promptmsg",  "本次使用礼包可选择<color=red>"..ChooseAbleWnd['UseCounts'].."</color>件道具,当前已选择<color=red>0</color>件 ", 70, 207, 550, 50, "system", true)
		GUI.SetAnchor(promptmsg, UIAnchor.Center)
		GUI.SetPivot(promptmsg, UIAroundPivot.Center)
		GUI.StaticSetFontSize(promptmsg, 22)
		GUI.SetColor(promptmsg, colorDark)
		
		local maxUsemsg = GUI.CreateStatic(panelBg, "maxUsemsg",  "该礼包每次最多使用"..ChooseAbleWnd['ItemMaxUseData'].."个 ", 150, -250, 550, 50, "system", true)
		GUI.SetAnchor(maxUsemsg, UIAnchor.Center)
		GUI.SetPivot(maxUsemsg, UIAroundPivot.Center)
		GUI.StaticSetFontSize(maxUsemsg, 22)
		GUI.SetColor(maxUsemsg, colorDark)
		
	end
    --GUI.LoopScrollRectRefreshCells(RewardRoller)
end

--打开界面
function ChooseAbleWnd.OpenWndPanel(key)
	if key == "ChooseAbleWnd" then
		local wnd = GUI.GetWnd("ChooseAbleWnd");
		GUI.SetVisible(wnd ,true)
	end
end

--将数据初始化
function ChooseAbleWnd.init()
	for i = 1, #ChooseAbleWnd['ItemList'] do
		if Chindextable[i] then
			test("Chindextable[i]"..Chindextable[i])	
			Chindextable[i] = 0
		end
		if ChlastNum[i] then
			test("ChlastNum[i]"..ChlastNum[i])
			ChlastNum[i] = 0	
		end
		if ChooseAbleWnd["GoodsNumber"..i] then
			test("ChooseAbleWnd['GoodsNumber'..i]"..ChooseAbleWnd["GoodsNumber"..i])
			ChooseAbleWnd["GoodsNumber"..i] = 0
		end
	end
	ChooseAbleWnd['ItemList'] = nil
	GUI.SetData(ChooseAbleWnd['panel'],"now_counts", 0)
end

--关闭界面
function ChooseAbleWnd.OnClosePanel(key)
	local wnd = GUI.GetWnd("ChooseAbleWnd");
	if wnd~=nil then
		ChooseAbleWnd.init()
		ChooseAbleWnd.RewardRoller = nil
		local wnd = GUI.GetWnd("ChooseAbleWnd/PanelBg");
		GUI.DestroyWnd("PanelBg")
		GUI.DestroyWnd("panelCover")
		GUI.DestroyWnd("ChooseAbleWnd")
	end
end

--选择
function ChooseAbleWnd.OnClickGoBtn(key)
	if not ChooseAbleWnd['ItemList'] then
		return
	end
	for i = 1, #ChooseAbleWnd['ItemList'] do
		--if ChooseAbleWnd["GoodsNumber"..i] and ChooseAbleWnd["GoodsNumber"..i] ~= 0 then
		if Chindextable[i] and Chindextable[i] ~= 0 then
			test("=-----------="..ChooseAbleWnd["GoodsNumber"..i])
			CL.SendNotify(NOTIFY.SubmitForm,"FormOptionalRewardChoose","choose_item", i, ChooseAbleWnd["GoodsNumber"..i], ChooseAbleWnd['UseCounts']);
		end
	end
	ChooseAbleWnd.OnClosePanel()
end

--创建滚动物品列表
function ChooseAbleWnd.CreatItemListS()
	local pnGoods = GUI.ImageCreate(ChooseAbleWnd.RewardRoller, "pnGoods", "1800400460", 0, 0, false, 320, 80)

	local IconFrame = GUI.ItemCtrlCreate(pnGoods, "bg_Info_ItemIcon", "1800600050", 12, 14, 80, 80, false)
	GUI.SetAnchor(IconFrame,UIAnchor.TopLeft);
	GUI.SetPivot(IconFrame,UIAroundPivot.TopLeft);
	
	local ItemName = GUI.CreateStatic(pnGoods, "txt_Info_ItemName", "", 10, -18, 220, 30)
	GUI.StaticSetFontSize(ItemName,24)
	GUI.SetAnchor(ItemName,UIAnchor.Center);
	GUI.SetPivot(ItemName,UIAroundPivot.Center);
	tipColor = Color.New(96/255,48/255,13/255,255/255);
	GUI.SetColor(ItemName,tipColor);
	
	ChooseAbleWnd['txtQuantities'] = GUI.CreateStatic(pnGoods, "txtQuantities","数量" ,105,65,120,30);
	GUI.StaticSetFontSize(ChooseAbleWnd['txtQuantities'],24)
	GUI.SetAnchor(ChooseAbleWnd['txtQuantities'],UIAnchor.TopLeft);
	GUI.SetPivot(ChooseAbleWnd['txtQuantities'],UIAroundPivot.TopLeft);
	tipColor = Color.New(96/255,48/255,13/255,255/255);
	GUI.SetColor(ChooseAbleWnd['txtQuantities'],tipColor);
	
	local btnNumbersSub =GUI.ButtonCreate(pnGoods,  "btnNumbersSub", "1800702080",170,58,Transition.ColorTint, "", 40, 40,false, false);
	GUI.SetAnchor(btnNumbersSub, UIAnchor.TopLeft)
	GUI.SetPivot(btnNumbersSub, UIAroundPivot.TopLeft)
	btnNumbersSub:RegisterEvent(UCE.PointerDown )
	btnNumbersSub:RegisterEvent(UCE.PointerUp )
	GUI.RegisterUIEvent(btnNumbersSub, UCE.PointerDown , "ChooseAbleWnd", "On_NumberSub" )
	GUI.RegisterUIEvent(btnNumbersSub, UCE.PointerUp, "ChooseAbleWnd", "NumberChangingOver" )
	
	local btnNumbersAdd =GUI.ButtonCreate(pnGoods, "btnNumbersAdd", "1800702020",338,58, Transition.ColorTint, "", 40, 40,false, false);
	GUI.SetAnchor(btnNumbersAdd, UIAnchor.TopLeft)
	GUI.SetPivot(btnNumbersAdd, UIAroundPivot.TopLeft)
	btnNumbersAdd:RegisterEvent(UCE.PointerDown )
	btnNumbersAdd:RegisterEvent(UCE.PointerUp )
	GUI.RegisterUIEvent(btnNumbersAdd, UCE.PointerDown, "ChooseAbleWnd", "On_NumberAdd" )
	GUI.RegisterUIEvent(btnNumbersAdd, UCE.PointerUp, "ChooseAbleWnd", "NumberChangingOver" )
	
	local InputBox = GUI.EditCreate(pnGoods, "InputBox", "1800400390", "0", 211, 56, Transition.ColorTint, "system", 0, 0, 8, 8, InputType.Standard, ContentType.IntegerNumber)
	GUI.SetAnchor(InputBox, UIAnchor.TopLeft)
	GUI.SetPivot(InputBox, UIAroundPivot.TopLeft)
	GUI.EditSetLabelAlignment(InputBox, TextAnchor.MiddleCenter)
	GUI.EditSetTextColor(InputBox, tipColor)
	GUI.EditSetFontSize(InputBox, 20);	
	GUI.EditSetMaxCharNum(InputBox, 4)
	GUI.RegisterUIEvent(InputBox, UCE.EndEdit, "ChooseAbleWnd", "OnNumCountChange")
	
	local itmExhibition = GUI.ItemCtrlCreate(IconFrame, "itmExhibition", "1800600050", 0, 0, 90, 90, false)
	GUI.SetAnchor(itmExhibition,UIAnchor.Left)
	GUI.SetPivot(itmExhibition,UIAroundPivot.Left)
	GUI.RegisterUIEvent(itmExhibition , UCE.PointerClick , "ChooseAbleWnd", "on_item_click" )
	
    GUI.RegisterUIEvent(heartSkillBtn, UCE.PointerClick, "RoleSkillUI", "OnSelectHeartSkill");
	return pnGoods;
end

--刷新滚动物品列表
function ChooseAbleWnd.RefreshItemList(parameter)
    local serverData = ChooseAbleWnd['ItemList']
	test("====================进入刷新物品列表")
    if not serverData then
        return
    end
	local saveParam = parameter
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local k = tonumber(parameter[2]) + 1
	Chindextable[k] = Chindextable[k] or 0
	ChlastNum[k] = ChlastNum[k] or 0
	test("ChlastNum[k]"..k.." "..ChlastNum[k])
	test("Chindextable[k]"..k.." "..Chindextable[k])
    local itemID = 0
	local itemName = "未知道具"
	local InputBox = GUI.GetChild(GUI.GetByGuid(guid), "InputBox")
	GUI.EditSetTextM(InputBox,Chindextable[k])
	
	local count = 0 
	for k, v in ipairs(Chindextable) do
		count = count + v
	end
	GUI.SetData(ChooseAbleWnd['panel'],"now_counts", count)
	if serverData[k]["itemkey"] then
		itemID = DB.GetOnceItemByKey2(serverData[k]["itemkey"]).Id
		test("itemID"..itemID)
		itemName = DB.GetItem(itemID,serverData[k]["itemkey"]).Name
		test("itemName"..itemName.."  itemnum"..serverData[k]["num"])
	end
	if serverData[k]["petkey"] then
		serverData[k].PetID = DB.GetOncePetByKey2(serverData[k]["petkey"]).Id
		test("PetID"..serverData[k].PetID)
	end
	if serverData[k].PetID then
		itemName = DB.GetPet(serverData[k].PetID, serverData[k]["petkey"]).Name
	end
	test("itemName:"..itemName)
    local itemBtn = GUI.GetByGuid(guid)
	
    GUI.SetData(itemBtn, "saveParam", saveParam)
	
    local IconFrame = GUI.GetChild(itemBtn, "bg_Info_ItemIcon")
	local txtInfo = GUI.GetChild(itemBtn, "txt_Info_ItemName")
	local itmExhibition = GUI.GetChild(IconFrame, "itmExhibition")
	GUI.StaticSetText(txtInfo, itemName.."*"..serverData[k]["num"])
	
	if itemID ~= 0 then
		GUI.SetData(itmExhibition,"ItemId","" .. itemID)
		local item = DB.GetItem(itemID,serverData[k]["itemkey"])
		if item then
			local grade = UIDefine.ItemIconBg[item.Grade]
			if grade ~= "" then
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Border, grade)
			else
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Border, 1800400050)
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Border, "")
			end
			--GetItemIconBtnSprite_Icon
			GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Icon, item.Icon)
			local icon = GUI.GetChild(itmExhibition, "Icon")
			GUI.SetWidth(icon, 80)
			GUI.SetHeight(icon, 80)
			if serverData and serverData[k]["bind"] == 1 then
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.LeftTopSp, 1800707120)
				GUI.ItemCtrlSetElementRect(itmExhibition, eItemIconElement.LeftTopSp, 0, 0, 44, 45)
			else
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.LeftTopSp, nil)
			end
		end
	elseif serverData[k].PetID ~= 0 then
		GUI.SetData(itmExhibition,"PetId","" .. serverData[k].PetID)
		local pet = DB.GetPet(serverData[k].PetID, serverData[k]["petkey"])
		if pet then
			local grade = tonumber(pet.Type)		
			if grade ~= "" then
				local grade = tonumber(grade)
				local pet_grade = UIDefine.PetItemIconBg3[grade]
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Border, pet_grade)
			else
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Border, 1800400050)
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Border, "")
			end
			GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.Icon, tostring(pet.Head))
			local icon = GUI.GetChild(itmExhibition, "Icon")
			GUI.SetWidth(icon, 80)
			GUI.SetHeight(icon, 80)
			if serverData and serverData[k]["bind"] == 1 then
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.LeftTopSp, 1800707120)
				GUI.ItemCtrlSetElementRect(itmExhibition, eItemIconElement.LeftTopSp, 0, 0, 44, 45)
			else
				GUI.ItemCtrlSetElementValue(itmExhibition, eItemIconElement.LeftTopSp, nil)
			end

			--GUI.GetItemIconBtnSprite_Icon(itmExhibition, eItemIconElement.Selected)
			-- GUI.SetItemIconBtnIconScale(itmExhibition,1)
			-- GUI.SetWidth(img, 78)
			-- GUI.SetHeight(img, 77)
			-- GUI.SetPositionY(img, -2)
			
			--local petUpgradeSwitch = false
			-- if MainSysOpen.IsFunctionOrVariableExist(GlobalUtils, "GetRefineStarSwitch") then
				-- petUpgradeSwitch = GlobalUtils.GetRefineStarSwitch()
			-- end
			-- if petUpgradeSwitch then
				--设置星级
				-- local currentNum, maxNum = GlobalUtils.GetPetInitialStarInfo(pet.Id)
				-- UILayout.SetSmallStars(currentNum, maxNum, img)
			-- end
		end					
	end
end

--物品点击
function ChooseAbleWnd.on_item_click(key)
	--test(key)
	local itmExhibition = GUI.GetByGuid(key)
	local itemID = GUI.GetData(itmExhibition, "ItemId")
	local petID =  GUI.GetData(itmExhibition, "PetId")
	--test(itemID)

	if itemID ~= "" then
		local tips = Tips.CreateByItemId(tonumber(itemID), GUI.GetWnd("ChooseAbleWnd"), "tipsleft",0,0)
		GUI.SetAnchor(tips, UIAnchor.Left)
		GUI.SetPivot(tips, UIAroundPivot.Left)
		GUI.SetIsRemoveWhenClick(tips,true)
	elseif petID ~= "" then
		--GUI.OpenWnd("PetStaticInfoUI", petID)
	end
end

--数量框按钮, 减少
function ChooseAbleWnd.On_NumberSub(key)
	test("减少按钮"..key)
	local saveParam = GUI.GetData(GUI.GetParentElement(GUI.GetByGuid(key)), "saveParam")
	saveParam = string.split(saveParam, "#")
	local guid = saveParam[1]
	local k = tonumber(saveParam[2]) + 1
	ChlastNum[k] = ChlastNum[k] or 0
	Chindextable[k] = Chindextable[k] or 0
	test("index"..k)
	test("ChlastNum[k]"..k.." "..ChlastNum[k])
	test("Chindextable[k]"..k.." "..Chindextable[k])
	ChooseAbleWnd.NumberChangeMode = -1
	ChooseAbleWnd.StartNumberChanging(k, guid)
end

--数量框按钮, 增加
function ChooseAbleWnd.On_NumberAdd(key)
	test("增加按钮"..key)
	local saveParam = GUI.GetData(GUI.GetParentElement(GUI.GetByGuid(key)), "saveParam")
	saveParam = string.split(saveParam, "#")
	local guid = saveParam[1]
	local k =  tonumber(saveParam[2]) + 1
	ChlastNum[k] = ChlastNum[k] or 0
	Chindextable[k] = Chindextable[k] or 0
	test("index"..k)
	test("ChlastNum[k]"..ChlastNum[k])
	test("Chindextable[k]"..Chindextable[k])
	ChooseAbleWnd.NumberChangeMode = 1
	ChooseAbleWnd.StartNumberChanging(k, guid)
	

	
end

--数量框限制
function ChooseAbleWnd.StartNumberChanging(k, guid)
	ChooseAbleWnd.NumberChangings = 0
	ChooseAbleWnd.NumberChangTimes = 0
	ChooseAbleWnd.NumberSpeeder = 1
	ChooseAbleWnd.NumberBtnStarting = 0
	
	if not ChooseAbleWnd['NumberChangingTimer'..k] then
		ChooseAbleWnd.NowIndex = k
		ChooseAbleWnd.NowGuid = guid
		ChooseAbleWnd['NumberChangingTimer'..k] = Timer.New(ChooseAbleWnd.NumberChangingCallBack,0.1,-1)
		ChooseAbleWnd['NumberChangingTimer'..k]:Start()
	end
end

ChooseAbleWnd.NumberChangeSpeeder = {
	{8,2},
	{5,4},
	{2,6},
	{1,6},
}

function ChooseAbleWnd.NumberChangingCallBack()
	ChooseAbleWnd.NumberChangings = ChooseAbleWnd.NumberChangings + 1
	if ChooseAbleWnd.NumberChangings%(ChooseAbleWnd.NumberChangeSpeeder[ChooseAbleWnd.NumberSpeeder][1]) == 0 then
		ChooseAbleWnd.NumberBtnStarting = 1
		ChooseAbleWnd.NumberChangTimes = ChooseAbleWnd.NumberChangTimes + 1
		ChooseAbleWnd.NumberChangings = 0
		ChooseAbleWnd.InputBox_Checking(ChooseAbleWnd["GoodsNumber"..ChooseAbleWnd.NowIndex], ChooseAbleWnd.NumberChangeMode, ChooseAbleWnd.NowIndex, ChooseAbleWnd.NowGuid)
	end
	if ChooseAbleWnd.NumberChangTimes == ChooseAbleWnd.NumberChangeSpeeder[ChooseAbleWnd.NumberSpeeder][2] then
		if ChooseAbleWnd.NumberChangeSpeeder[ChooseAbleWnd.NumberSpeeder+1] then
			ChooseAbleWnd.NumberChangTimes = 0
			ChooseAbleWnd.NumberSpeeder = ChooseAbleWnd.NumberSpeeder + 1
		end
	end
end

function ChooseAbleWnd.NumberChangingOver(key)
	local saveParam = GUI.GetData(GUI.GetParentElement(GUI.GetByGuid(key)), "saveParam")
	saveParam = string.split(saveParam, "#")
	local guid = saveParam[1]
	local k =  tonumber(saveParam[2]) + 1
	if ChooseAbleWnd['NumberChangingTimer'..k] then
		ChooseAbleWnd['NumberChangingTimer'..k]:Stop()
	end
	ChooseAbleWnd['NumberChangingTimer'..k] = nil
	if ChooseAbleWnd.NumberBtnStarting == 0 then
		if not ChooseAbleWnd["GoodsNumber"..ChooseAbleWnd.NowIndex] then
			ChooseAbleWnd["GoodsNumber"..ChooseAbleWnd.NowIndex] = 0
		end
		ChooseAbleWnd.InputBox_Checking(ChooseAbleWnd["GoodsNumber"..ChooseAbleWnd.NowIndex], ChooseAbleWnd.NumberChangeMode, k, guid)
	end
end

--数量框修改后
function ChooseAbleWnd.OnNumCountChange(key)
	local saveParam = GUI.GetData(GUI.GetParentElement(GUI.GetByGuid(key)), "saveParam")
	saveParam = string.split(saveParam, "#")
	local guid = saveParam[1]
	local k =  tonumber(saveParam[2]) + 1
	local InputBox = GUI.GetByGuid(key)
	local number = tonumber(GUI.EditGetTextM(InputBox))
	test(number)
	if number then
		ChooseAbleWnd.InputBox_Checking(number, 0, k, guid)
	else
		GUI.EditSetTextM(InputBox,0)
	end
end

--输入框数值验证
function ChooseAbleWnd.InputBox_Checking(number, changer, k, guid)
	--test("=======================数值验证")
	if not number then
		number = 0
	end
	local InputBox = GUI.GetChild(GUI.GetByGuid(guid), "InputBox")
	local usecounts = ChooseAbleWnd['UseCounts']
	local last_number = number
	if GUI.GetData(ChooseAbleWnd['panel'], "now_counts") == "" then
		GUI.SetData(ChooseAbleWnd['panel'],"now_counts", "" .. 0)
	end
	local now_counts = tonumber(GUI.GetData(ChooseAbleWnd['panel'], "now_counts"))
	
	number = number + changer
	
	number = math.floor(number)
	if number < 0 then
		number = 0
	end
	--test("=============number:"..number)
	--test("============usecounts"..usecounts)
	if changer < 0 then
		test("===========	changer<0,减号进入")
		if last_number == 0 then
			return
		else
			if now_counts ~= 0 then
				GUI.SetData(ChooseAbleWnd['panel'],"now_counts", "" .. (now_counts - 1))
			else
				return
			end
		end
	elseif changer > 0 then
		--test("============= changer>0,加号进入")
		if now_counts == 0 then
			--test("=================== 参数："..GUI.GetData(ChooseAbleWnd['panel'],"now_counts"))
			if number > usecounts then
				return
			else
				GUI.SetData(ChooseAbleWnd['panel'],"now_counts", "" .. number)
			end
		else
			if (usecounts - now_counts) < 0 then
				--test("================  usecounts-已选择值"..usecounts - tonumber(GUI.GetData(ChooseAbleWnd['panel'],"now_counts")))
				--GUI.SetData(InputBox, "last_inpTex", number-1)
				ChlastNum[k] = number-1
				ChooseAbleWnd["GoodsNumber"..k] = number
				return
			elseif (usecounts - now_counts) == 0 then
				ChooseAbleWnd["GoodsNumber"..k] = last_number
				--GUI.SetData(InputBox, "last_inpTex", last_number)
				ChlastNum[k] = last_number
				return
			elseif (usecounts -now_counts) > 0 then
				GUI.SetData(ChooseAbleWnd['panel'],"now_counts", "" .. (now_counts + changer))
			end
		end
	elseif changer == 0 then
		if GUI.GetData(ChooseAbleWnd['panel'], "now_counts") == "" then
			GUI.SetData(ChooseAbleWnd['panel'],"now_counts", "" .. 0)
		end
		number = ChooseAbleWnd.checkInputText(number, k, usecounts, guid)
		--test("===============返回的num值"..number)
	end
	
	--GUI.SetData(InputBox, "last_inpTex", number)
	ChlastNum[k] = number
	test("================已选择值："..GUI.GetData(ChooseAbleWnd['panel'], "now_counts"))
	ChooseAbleWnd["GoodsNumber"..k] = number
	-- local count = 0 
	-- for k, v in ipairs(Chindextable) do
		-- count = count + v
	-- end
	--GUI.SetData(ChooseAbleWnd['panel'], "now_counts", count)
	Chindextable[k] = number
	GUI.EditSetTextM(InputBox,number)
	
	local promptmsg = GUI.Get("ChooseAbleWnd/PanelBg/promptmsg")
	GUI.StaticSetText(promptmsg,  "本次使用礼包可选择<color=red>"..ChooseAbleWnd['UseCounts'].."</color>件道具,当前已选择<color=red>"..GUI.GetData(ChooseAbleWnd['panel'],"now_counts").."</color>件 ")	
end

--判断输入框数字
function ChooseAbleWnd.checkInputText(num, k, usecounts, guid)
	local now_counts = tonumber(GUI.GetData(ChooseAbleWnd['panel'], "now_counts"))
	local InputBox = GUI.GetChild(GUI.GetByGuid(guid), "InputBox")
	--local now_InpTex = tonumber(GUI.GetData(InputBox, "last_inpTex"))
	local now_InpTex = tonumber(ChlastNum[k])
	test("================修改前now_InpTex"..now_InpTex)
	test("================now_counts"..now_counts)
	
	if num < 0 then
		num = 0
	end
	if now_counts < 0 then
		now_counts = 0
	end
	if now_InpTex < 0 then
		now_InpTex = 0
	end
	
	if now_counts == 0 then
		if num == 0 then
			test("=======================情况1")
			return num
		elseif num > 0 then
			if num > usecounts then
				num = usecounts
				GUI.SetData(ChooseAbleWnd['panel'], "now_counts", num)
				test("=======================情况2")
				return num
			elseif num <= usecounts then
				GUI.SetData(ChooseAbleWnd['panel'], "now_counts", num)
				test("=======================情况3")
				return num
			end
		end
	elseif now_counts > 0 then
		if now_InpTex == 0 then
			if num == 0 then
				test("=======================情况4")
				return num
			elseif num > 0 then
				if (num + now_counts) > usecounts then
					num = usecounts - now_counts
					GUI.SetData(ChooseAbleWnd['panel'], "now_counts", (now_counts + num))
					test("=======================情况5")
					return num
				elseif (num + now_counts) <= usecounts then
					GUI.SetData(ChooseAbleWnd['panel'], "now_counts", (now_counts + num))
					test("=======================情况6")
					return num
				end
			end
		elseif now_InpTex > 0 then
			if num == now_InpTex then
				test("=======================情况7")
				return num
			end
			if now_InpTex < now_counts then
				if num == 0 then
					GUI.SetData(ChooseAbleWnd['panel'], "now_counts", (now_counts - now_InpTex))
					test("=======================情况8")
					return num
				elseif num > 0 then
					if (num + now_counts - now_InpTex) > usecounts then
						num = usecounts - now_counts + now_InpTex
						GUI.SetData(ChooseAbleWnd['panel'], "now_counts", usecounts)
						test("=======================情况9")
						return num 
					elseif (num + now_counts - now_InpTex) <= usecounts then
						GUI.SetData(ChooseAbleWnd['panel'], "now_counts", (now_counts - now_InpTex + num))
						test("=======================情况1")
						return num
					end
				end
			else
				if num == 0 then
					GUI.SetData(ChooseAbleWnd['panel'], "now_counts", (now_counts - now_InpTex))
					test("=======================情况10")
					return num
				elseif num > 0 then
					if num > usecounts then
						num = usecounts
						GUI.SetData(ChooseAbleWnd['panel'], "now_counts", num)
						test("=======================情况11")
						return num 
					elseif num  <= usecounts then
						GUI.SetData(ChooseAbleWnd['panel'], "now_counts",  num)
						test("=======================情况12")
						return num
					end
				end
			end
		end
	end
end
