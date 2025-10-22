GinSengTreeUI = {}
require "UILayout";

--设置字体颜色
local colorDark = Color.New(102/255,47/255,22/255,255/255)
local colorWhite = Color.New(255/255, 246/255, 232/255, 255/255)
local colorOutline = Color.New(162 / 255, 75 / 255, 21 / 255)
local button_color = Color.New(133/255,83/255,61/255,255/255);
local sizeTitle = 26
local sizeTitleS = 24
local sizeTxt = 22

local _gt = UILayout.NewGUIDUtilTable()

--品质背景框
local QualityRes = 
{
  "1800400330","1800400100","1800400110","1800400120","1800400320"
}

local tabList = {
	{"金锥", "ItemButton", "OnPageBtnClick_ItemButton"},
	{"元宝", "GoldButton", "OnPageBtnClick_GoldButton"},
	{"银元", "SilverButton", "OnPageBtnClick_SilverButton"},
}

function GinSengTreeUI.Main()
	--test("======================GinSengTreeUI.Main")
	local _Panel = GUI.WndCreateWnd("GinSengTreeUI", "GinSengTreeUI", 0 , 0, eCanvasGroup.Normal);
	GinSengTreeUI["_Panel"] = _Panel
	local _PanelBg = UILayout.CreateFrame_WndStyle0(_Panel, "人参果树", "GinSengTreeUI", "OnClose")
	local Reward_panelCover = GUI.ImageCreate(_Panel, "Reward_panelCover", "1800400480", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
	 _gt.BindName(Reward_panelCover, "Reward_panelCover")
    UILayout.SetAnchorAndPivot(Reward_panelCover, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(Reward_panelCover, UIDefine.Transparent)
    GUI.SetIsRaycastTarget(Reward_panelCover, true)
    Reward_panelCover:RegisterEvent(UCE.PointerClick)
	GUI.SetVisible(Reward_panelCover, false)
	
	if not GUI.GetData(_Panel, "index") then
		GUI.SetData(_Panel, "index", 1)
	end
    -- 底图
    local PanelBg = GUI.ImageCreate(_PanelBg, "PanelBg", "1801701020", 0, 0, false, 1060, 630)
	GinSengTreeUI["panelBg"] = PanelBg
    GUI.SetAnchor(PanelBg, UIAnchor.Center)
    GUI.SetPivot(PanelBg, UIAroundPivot.Center)
	
	--对话气泡文本
	local BubbleText = GUI.CreateStatic(PanelBg, "BubbleText", "已获得的奖励不会重复获得", -390, -60, 180, 80, "system", false, true)
    GUI.SetAnchor(BubbleText, UIAnchor.Center)
    GUI.SetPivot(BubbleText, UIAroundPivot.Center)
    GUI.StaticSetFontSize(BubbleText, 26)
    GUI.SetColor(BubbleText, colorDark)
	
	--底端文本
	local UnderText = GUI.CreateStatic(PanelBg, "UnderText", "每次撞击消耗的道具数量会随撞击次数增加", 29, -33, 550, 50)
    GUI.SetAnchor(UnderText, UIAnchor.Bottom)
    GUI.SetPivot(UnderText, UIAroundPivot.Center)
    GUI.StaticSetFontSize(UnderText, 26)
    GUI.SetColor(UnderText, colorDark)
	
	--撞一下按钮
    local HitBtn = GUI.ButtonCreate(PanelBg, "HitBtn", "1800402110", 390, -79, Transition.ColorTint, "撞一下", 140, 53, false)
    GUI.SetAnchor(HitBtn, UIAnchor.Bottom)
    GUI.SetPivot(HitBtn, UIAroundPivot.Center)
    GUI.ButtonSetTextFontSize(HitBtn, 28)
    GUI.ButtonSetTextColor(HitBtn, colorDark)
    GUI.SetIsOutLine(HitBtn, false)
    GUI.SetOutLine_Color(HitBtn, colorOutline)
    GUI.SetOutLine_Distance(HitBtn, 1)
    GUI.RegisterUIEvent(HitBtn, UCE.PointerClick, "GinSengTreeUI", "OnClickHitBtn")
	
	local timeGroup_1 = GUI.GroupCreate(PanelBg, "timeGroup_1", -200, -315, 0, 0)
    local timeSprite = GUI.ImageCreate(timeGroup_1, "timeSprite", "1800408530", -328, 60)
    UILayout.SetAnchorAndPivot(timeSprite, UIAnchor.Top, UIAroundPivot.Center)
	local timeTips = GUI.CreateStatic(timeGroup_1, "timeTips", "奖池剩余时间:", -250, 60, 150, 30)
    GinSengTreeUI.SetTextBasicInfo(timeTips, colorDark, TextAnchor.MiddleCenter, 22)
    GUI.SetAnchor(timeTips, UIAnchor.Top)
	local timeText = GUI.CreateStatic(timeGroup_1, "timeText", "", -110, 60, 150, 30)
    _gt.BindName(timeText, "timeText")
    GinSengTreeUI.SetTextBasicInfo(timeText, colorDark, TextAnchor.MiddleCenter, 22)
	
	local tap = GUI.GetData(_Panel, "index")
	--test("======================向服务端请求数据："..tap)
	CL.SendNotify(NOTIFY.SubmitForm,"FormGinsengTree","GetGinSengTreeData",tap)
end

function GinSengTreeUI.SetTextBasicInfo(txt, color, TextAnchor, txtSize)
    UILayout.SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txt, txtSize)
    GUI.SetColor(txt, color)
    GUI.StaticSetAlignment(txt, TextAnchor)
end

--刷新时间
function GinSengTreeUI.RefreshTimetext(remainTime)
    test("RefreshTimetext : ", remainTime)
    GinSengTreeUI.StopTimerDown()
    local timeText = _gt.GetUI("timeText")
    if timeText ~= nil then
        local fun = function()
            remainTime = remainTime - 1
            if remainTime < 1 then
				GinSengTreeUI.OnClose()
                local moveGroup = GUI.Get("MainUI/moveGroup")
                if moveGroup ~= nil then
                    GUI.SetVisible(moveGroup, false)
                end
            end
            local day, hour, min, sec = GlobalUtils.Get_DHMS2_BySeconds(remainTime)
            local timeString
            if day == "00" then
                if hour == "00" then
                    timeString = min .. ":" .. sec
                else
                    timeString = hour .. ":" .. min .. ":" .. sec
                end
            else
                timeString = day .. "天" .. hour .. ":" .. min .. ":" .. sec
            end
            GUI.StaticSetText(timeText, timeString)
            return nil
        end
        GinSengTreeUI.RemainTimer = Timer.New(fun, 1, remainTime, true)
        GinSengTreeUI.RemainTimer:Start()
    end
end

function GinSengTreeUI.StopTimerDown()
    if GinSengTreeUI.RemainTimer ~= nil then
        GinSengTreeUI.RemainTimer:Stop()
        GinSengTreeUI.RemainTimer = nil
    end
end


--撞一下
function GinSengTreeUI.OnClickHitBtn()
	--test("==============撞击逻辑，taps为"..tostring(GinSengTreeUI.Taps))
	if GinSengTreeUI.Taps then
		CL.SendNotify(NOTIFY.SubmitForm,"FormGinsengTree","SubConsume",tostring(GinSengTreeUI.Taps))
		GUI.StaticSetText(GinSengTreeUI['ConsumeNumber'..GinSengTreeUI.Taps], "×"..GinSengTreeUI['ConsumeNum_'..GinSengTreeUI.Taps])
	else
		CL.SendNotify(NOTIFY.SubmitForm,"FormGinsengTree","SubConsume","1")
	end
end

function GinSengTreeUI.RollLight(randerList)
	local Reward_panelCover = _gt.GetUI("Reward_panelCover")
	GUI.SetVisible(Reward_panelCover, true)
	if GinSengTreeUI['ItemData_'..GinSengTreeUI.Taps] then
		if GinSengTreeUI["IconFrame_"..GinSengTreeUI.Taps] then
			local index = GinSengTreeUI['LastItemIndex_'..GinSengTreeUI.Taps]
			--test("=================index"..index)
			local rollTable = {}
			for k ,v in ipairs(GinSengTreeUI['ItemData_'..GinSengTreeUI.Taps]) do	
				if v["Draw"] == 1 then
					table.insert(rollTable, k)
				end
				if k ~= tonumber(index) then
					local result = GUI.Get("GinSengTreeUI/panelBg/PanelBg/bg_Info_ItemIcon_"..GinSengTreeUI.Taps.."_"..tostring(k).."/SelectPic_"..GinSengTreeUI.Taps.."_"..tostring(k))
					GUI.SetVisible(result, false)
				end
			end
			
			local rander = 1
			local times = 0.2
			for i = 1 , 2 do
				for k, v in ipairs(randerList) do
					local fun = function()
						GinSengTreeUI.RollTable(rollTable[tonumber(v)])
					end
					GinSengTreeUI.GinSengTreeUI_Timer = Timer.New(fun,tonumber(times)):Start()
					times = times + 0.2
				end
			end
			
			fun = function()
				GinSengTreeUI.RollTable(index)
			end
			GinSengTreeUI.GinSengTreeUI_Timer = Timer.New(fun,tonumber(times)):Start()	
			
			fun = function()
				GinSengTreeUI.Updata()
			end
			--test("================times:"..tonumber(times))
			GinSengTreeUI.GinSengTreeUI_Timer = Timer.New(fun,tonumber(times)):Start()	
		end
	end
end

function GinSengTreeUI.Updata()
	--test("=========================UPData："..GinSengTreeUI.Taps)
	local Reward_panelCover = _gt.GetUI("Reward_panelCover")
	GUI.SetVisible(Reward_panelCover, false)
	CL.SendNotify(NOTIFY.SubmitForm,"FormGinsengTree","GetGinSengTreeData",GinSengTreeUI.Taps)
end

function GinSengTreeUI.RollTable(param)
	for k ,v in ipairs(GinSengTreeUI['ItemData_'..GinSengTreeUI.Taps]) do	
		if k == tonumber(param) then
			local result = GUI.Get("GinSengTreeUI/panelBg/PanelBg/bg_Info_ItemIcon_"..GinSengTreeUI.Taps.."_"..param.."/SelectPic_"..GinSengTreeUI.Taps.."_"..param)
			GUI.SetVisible(result, true)
		else
			local result = GUI.Get("GinSengTreeUI/panelBg/PanelBg/bg_Info_ItemIcon_"..GinSengTreeUI.Taps.."_"..tostring(k).."/SelectPic_"..GinSengTreeUI.Taps.."_"..tostring(k))
			GUI.SetVisible(result, false)
		end
	end
end

function GinSengTreeUI.OnOpen(key)
	if key == "GinSengTreeUI" then
		local _Panel = GUI.GetWnd("GinSengTreeUI");
		GUI.SetVisible(_Panel ,true)
	end
end

--刷新界面
function GinSengTreeUI.Refresh(tap)
	--test("刷新界面1："..tap)
	--判断客户端有没有 GinSengTreeUI.Taps
	if not GinSengTreeUI.Taps then
		GinSengTreeUI.Taps = tap
	end
	--test("刷新界面2："..tap)
	if GinSengTreeUI['ItemData_'..tap] then
		--test("刷新界面3："..tap)
		if not GinSengTreeUI["IconFrame_"..tap] then
		--test("没有GinSengTreeUI[ItemData_"..tap.."]， 创建")
			if tonumber(GinSengTreeUI.Taps) ~= tonumber(tap) then
				--test("将其他Taps隐藏")
				--隐藏GinSengTreeUI.Taps
				--GinSengTreeUI.Taps = tap
				local icon_1 = GinSengTreeUI['ConsumeItemIcon'..GinSengTreeUI.Taps] or GinSengTreeUI['MoneyIcon'..GinSengTreeUI.Taps]
				GUI.SetVisible(GinSengTreeUI['ConsumeNumber'..GinSengTreeUI.Taps], false)
				GUI.SetVisible(icon_1, false)
				for k, v in ipairs(GinSengTreeUI['ItemData_'..GinSengTreeUI.Taps]) do
					if GinSengTreeUI["itmExhibition_"..GinSengTreeUI.Taps] and GinSengTreeUI["IconFrame_"..GinSengTreeUI.Taps] then
						GUI.SetVisible(GinSengTreeUI["itmExhibition_"..GinSengTreeUI.Taps][k] ,false)
						GUI.SetVisible(GinSengTreeUI["IconFrame_"..GinSengTreeUI.Taps][k],false)
					end
				end
			end

			GinSengTreeUI.Taps = tap
			local _Panel = GUI.GetWnd("GinSengTreeUI")
			GUI.SetData(_Panel, "index", tap)
			if not GinSengTreeUI['ConsumeNum_'..tap] then
				GinSengTreeUI['ConsumeNum_'..tap] = 0
			end
			
			--右侧条目
			if GSTGLOBALDATA then
				if UILayout then
					if tabList then
						UILayout.CreateRightTab(tabList, "GinSengTreeUI")
						if tap == 1 then
							UILayout.OnTabClick(tap, tabList)
						end
					end
				end
			end

			--消耗
			GinSengTreeUI['ConsumeNumber'..tap] = GUI.CreateStatic(GinSengTreeUI["panelBg"], "ConsumeNumber"..tap, "×"..GinSengTreeUI['ConsumeNum_'..tap], 450, 190,180, 80, "system", false, true)
			GUI.SetAnchor(GinSengTreeUI['ConsumeNumber'..tap], UIAnchor.Center)
			GUI.SetPivot(GinSengTreeUI['ConsumeNumber'..tap], UIAroundPivot.Center)
			GUI.StaticSetFontSize(GinSengTreeUI['ConsumeNumber'..tap], 26)
			GUI.SetColor(GinSengTreeUI['ConsumeNumber'..tap], colorDark)
			
			--所需道具图片
			if GinSengTreeUI.ConsumeType == "Money" then
				GinSengTreeUI['MoneyIcon'..tap] = GUI.ImageCreate(GinSengTreeUI["panelBg"], "MoneyIcon"..tap, GSTGLOBALDATA[tap]["Consume"]["MoneyType"][2] , 340, 185, false, 50, 50)
				GUI.SetAnchor(GinSengTreeUI['MoneyIcon'..tap], UIAnchor.Center)
				GUI.SetPivot(GinSengTreeUI['MoneyIcon'..tap], UIAroundPivot.Center)
			elseif GinSengTreeUI.ConsumeType == "Item" then
				local Consume_itemData = DB.GetOnceItemByKey1(GSTGLOBALDATA[tap]["Consume"]["UseItem"]["Id"])
				GinSengTreeUI['ConsumeItemIcon'..tap]  = GUI.ImageCreate(GinSengTreeUI["panelBg"], "ConsumeItemIcon"..tap, Consume_itemData.Icon , 340, 185, false, 50, 50)
				GUI.SetAnchor(GinSengTreeUI['ConsumeItemIcon'..tap], UIAnchor.Center)
				GUI.SetPivot(GinSengTreeUI['ConsumeItemIcon'..tap], UIAroundPivot.Center)
			end
			
			GinSengTreeUI["IconFrame_"..tap] = {}
			GinSengTreeUI["itmExhibition_"..tap] = {}
			
			for k, v in ipairs(GinSengTreeUI['ItemData_'..tap]) do
				if type(v) == "table" then
					local itemData = DB.GetOnceItemByKey2(v["ItemKey"])	
					itemID = itemData.Id
					itemName = itemData.Name
					local gray = false
					
					GinSengTreeUI["IconFrame_"..tap][k] = GUI.ItemCtrlCreate(GinSengTreeUI["panelBg"], "bg_Info_ItemIcon_"..tap.."_"..k,"1800600050",v["x"],v["y"],100, 100,false);
					GUI.SetAnchor(GinSengTreeUI["IconFrame_"..tap][k],UIAnchor.TopLeft)
					GUI.SetPivot(GinSengTreeUI["IconFrame_"..tap][k],UIAroundPivot.TopLeft)
					
					GinSengTreeUI['SelectPic_'..tap] = {}
					GinSengTreeUI['SelectPic_'..tap][k] = GUI.ImageCreate(GinSengTreeUI["IconFrame_"..tap][k], "SelectPic_"..tap .."_"..k, "1800400280" , 0 , 0 ,  false, 125, 125);
					GUI.SetAnchor(GinSengTreeUI['SelectPic_'..tap][k],UIAnchor.Center)
					GUI.SetPivot(GinSengTreeUI['SelectPic_'..tap][k],UIAroundPivot.Center)
					GUI.SetVisible(GinSengTreeUI['SelectPic_'..tap][k],false)

					--if GinSengTreeUI['LastItemIndex_'..tap] then
					--	GUI.SetVisible(GinSengTreeUI['SelectPic_'..tap][GinSengTreeUI['LastItemIndex_'..tap]],true)
					--end
					
					GinSengTreeUI["itmExhibition_"..tap][k] = GUI.ItemCtrlCreate(GinSengTreeUI["IconFrame_"..tap][k], "itmExhibition_"..k, "1800600050", 0, 0, 100, 100, false)
					GUI.SetAnchor(GinSengTreeUI["itmExhibition_"..tap][k],UIAnchor.Center)
					GUI.SetPivot(GinSengTreeUI["itmExhibition_"..tap][k],UIAroundPivot.Center)
					GUI.RegisterUIEvent(GinSengTreeUI["itmExhibition_"..tap][k] , UCE.PointerClick , "GinSengTreeUI", "on_item_click" )
					GUI.SetData(GinSengTreeUI["itmExhibition_"..tap][k],"info", itemID)
					
					if v["Draw"] == 2 then
						gray = true
						GUI.SetColor(GinSengTreeUI["itmExhibition_"..tap][k], Color.New(255/255, 255/255, 255/255, 0/255))
					end
					if itemData then
						local grade = QualityRes[itemData.Grade]
						if grade ~= "" then
							GUI.ItemCtrlSetElementValue(GinSengTreeUI["itmExhibition_"..tap][k], eItemIconElement.Border, grade)
						else
							GUI.ItemCtrlSetElementValue(GinSengTreeUI["itmExhibition_"..tap][k], eItemIconElement.Border, "1800400050")
							GUI.ItemCtrlSetElementValue(GinSengTreeUI["itmExhibition_"..tap][k], eItemIconElement.Border, "")
						end
						GUI.ItemCtrlSetElementValue(GinSengTreeUI["itmExhibition_"..tap][k], eItemIconElement.Icon, itemData.Icon)
						GUI.ItemCtrlSetIconGray(GinSengTreeUI["itmExhibition_"..tap][k], gray)
						GUI.GetScale(GinSengTreeUI["itmExhibition_"..tap][k])
					end
				end
			end			
		else
			--test("有GinSengTreeUI[ItemData_"..tap.."]， 验证数据")
			if tonumber(GinSengTreeUI.Taps) == tonumber(tap) then
				--数据是否匹配
				--test("taps相同，验证数据")
				if not GinSengTreeUI.Versions then 
					GinSengTreeUI.Versions = GinSengTreeUI.Version
				end
				if GinSengTreeUI.Versions ~= GinSengTreeUI.Version then
				--	test("=============版本不同，重新获取数据")
					CL.SendNotify(NOTIFY.SubmitForm,"FormGinsengTree","GetGinSengTreeData",tap)
				else
					for k, v in ipairs (GinSengTreeUI['ItemData_'..tap]) do
						if v["Draw"] == 2 then
							--test(v["ItemKey"].."已被抽到，变灰")
							local itemData = DB.GetOnceItemByKey2(v["ItemKey"])	
							GUI.SetColor(GinSengTreeUI["itmExhibition_"..tap][k], Color.New(255/255, 255/255, 255/255, 0/255))
							GUI.ItemCtrlSetElementValue(GinSengTreeUI["itmExhibition_"..tap][k], eItemIconElement.Icon, itemData.Icon)
							GUI.ItemCtrlSetIconGray(GinSengTreeUI["itmExhibition_"..tap][k], true)
						end
						GUI.SetVisible(GinSengTreeUI["itmExhibition_"..tap][k] ,true)
					end
					--test("============消耗为："..GinSengTreeUI['ConsumeNum_'..tap])
					if GinSengTreeUI['ConsumeNumber'..tap] then
						--test(type(GinSengTreeUI['ConsumeNumber'..tap]))
						GUI.StaticSetText(GinSengTreeUI['ConsumeNumber'..tap], "×"..GinSengTreeUI['ConsumeNum_'..tap])
					end
					if GinSengTreeUI['LastItemIndex_'..tap] then
						GUI.SetVisible(GinSengTreeUI['SelectPic_'..tap][GinSengTreeUI['LastItemIndex_'..tap]],true)
					end
				end
				GinSengTreeUI.Taps = tap
				local _Panel = GUI.GetWnd("GinSengTreeUI")
				GUI.SetData(_Panel, "index", tap)
			else 
				--隐藏GinSengTreeUI.Taps
				--显示tap
				--GinSengTreeUI.Taps = tap
				--test("tap不同,隐藏GinSengTreeUI.Taps，显示tap")
				local icon_1 = GinSengTreeUI['ConsumeItemIcon'..GinSengTreeUI.Taps] or GinSengTreeUI['MoneyIcon'..GinSengTreeUI.Taps]
				GUI.SetVisible(GinSengTreeUI['ConsumeNumber'..GinSengTreeUI.Taps], false)
				GUI.SetVisible(icon_1, false)
				for k, v in ipairs(GinSengTreeUI['ItemData_'..GinSengTreeUI.Taps]) do
					GUI.SetVisible(GinSengTreeUI["itmExhibition_"..GinSengTreeUI.Taps][k] ,false)
					GUI.SetVisible(GinSengTreeUI["IconFrame_"..GinSengTreeUI.Taps][k],false)
				end
				for k, v in ipairs(GinSengTreeUI['ItemData_'..tap]) do
					--test("k:"..k.."  vDraw:"..v["Draw"])
					if v["Draw"] == 2 then
						local itemData = DB.GetOnceItemByKey2(v["ItemKey"])	
						GUI.SetColor(GinSengTreeUI["itmExhibition_"..tap][k], Color.New(255/255, 255/255, 255/255, 0/255))
						GUI.ItemCtrlSetElementValue(GinSengTreeUI["itmExhibition_"..tap][k], eItemIconElement.Icon, itemData.Icon)
						GUI.ItemCtrlSetIconGray(GinSengTreeUI["itmExhibition_"..tap][k], true)
					end
					GUI.SetVisible(GinSengTreeUI["IconFrame_"..tap][k],true)
					GUI.SetVisible(GinSengTreeUI["itmExhibition_"..tap][k] ,true)
				end
				local icon_2 = GinSengTreeUI['ConsumeItemIcon'..tap] or GinSengTreeUI['MoneyIcon'..tap]
				GUI.SetVisible(GinSengTreeUI['ConsumeNumber'..tap], true)
				GUI.StaticSetText(GinSengTreeUI['ConsumeNumber'..tap], "×"..GinSengTreeUI['ConsumeNum_'..tap])
				GUI.SetVisible(icon_2, true)
				if GinSengTreeUI['LastItemIndex_'..tap] then
					GUI.SetVisible(GinSengTreeUI['SelectPic_'..tap][GinSengTreeUI['LastItemIndex_'..tap]],true)
				end
				GinSengTreeUI.Taps = tap
				local _Panel = GUI.GetWnd("GinSengTreeUI")
				GUI.SetData(_Panel, "index", tap)
			end
		end
	else 
		test("===============itemData没有数据")
	end
end

function GinSengTreeUI.LabelList()
	--test("=================LabelList")
	if GSTGLOBALDATA then
		if UILayout then
			--local LabelListInfo = {}
			--for k, v in ipairs(GSTGLOBALDATA) do
			--	LabelListInfo[k] = {v["Tap"], tostring(k), "OnPageBtnClick"}
			--end
			if tabList then
				UILayout.CreateRightTab(tabList,"GinSengTreeUI")
			end
		end
	end
end

--物品点击
function GinSengTreeUI.on_item_click(guid)
	--test(guid)
	if GinSengTreeUI.Taps then
		local itemID = 0
		local button = GUI.GetByGuid(guid)
		local itemID = GUI.GetData(button, "info")
		--test("========================itemID:"..itemID)
		if itemID then
			local tips = Tips.CreateByItemId(itemID, GinSengTreeUI["panelBg"], "tipsleft", 0, 0)
			--local tips = Tips.CreateSimpleItem("tipsleft",itemID,0,0,GinSengTreeUI["panelBg"],50,0)
			GUI.SetAnchor(tips, UIAnchor.TopLeft)
			GUI.SetPivot(tips, UIAroundPivot.TopLeft)
			GUI.SetIsRemoveWhenClick(tips,true)
		end
	end
end

function GinSengTreeUI.OnPageBtnClick_ItemButton()
	--test("================界面1")
	if UILayout ~= nil then
		UILayout.OnTabClick(1, tabList)
    end
	local _Panel = GUI.GetWnd("GinSengTreeUI")
	GUI.SetData(_Panel, "index", 1)
	CL.SendNotify(NOTIFY.SubmitForm,"FormGinsengTree","GetGinSengTreeData",1)
	return true
end

function GinSengTreeUI.OnPageBtnClick_GoldButton()
	--test("================界面2")
	if UILayout ~= nil then
		UILayout.OnTabClick(2, tabList)
    end
	local _Panel = GUI.GetWnd("GinSengTreeUI")
	GUI.SetData(_Panel, "index", 2)
	CL.SendNotify(NOTIFY.SubmitForm,"FormGinsengTree","GetGinSengTreeData",2)
	return true
end

function GinSengTreeUI.OnPageBtnClick_SilverButton()
	--test("================界面3")
	if UILayout ~= nil then
		UILayout.OnTabClick(3, tabList)
    end
	local _Panel = GUI.GetWnd("GinSengTreeUI")
	GUI.SetData(_Panel, "index", 3)
	CL.SendNotify(NOTIFY.SubmitForm,"FormGinsengTree","GetGinSengTreeData",3)
	return true
end

function GinSengTreeUI.OnShow()
	local wnd = GUI.GetWnd("GinSengTreeUI")
	if not wnd then
		GUI.OpenWnd("GinSengTreeUI")
	else
		GUI.SetVisible(wnd, true)
	end
end

--关闭
function GinSengTreeUI.OnClose()
	local wnd = GUI.GetWnd("GinSengTreeUI")
	GinSengTreeUI.CleanLight()
	GinSengTreeUI.StopTimerDown()
	--GUI.SetVisible(wnd, false)
	if wnd~=nil then
		for i = 1, #tabList do
			GinSengTreeUI["IconFrame_"..i] = nil
			GinSengTreeUI["itmExhibition_"..i] = nil
		end
		GUI.Destroy("GinSengTreeUI/panelBg")
		GUI.Destroy("panelCover")
		GUI.Destroy("GinSengTreeUI")
	end
end

function GinSengTreeUI.CleanLight()
	if GSTGLOBALDATA then
		for i = 1, #GSTGLOBALDATA do
			if GinSengTreeUI['ItemData_'..i] then
				for k ,v in ipairs(GinSengTreeUI['ItemData_'..i]) do	
					local result = GUI.Get("GinSengTreeUI/panelBg/PanelBg/bg_Info_ItemIcon_"..i.."_"..k.."/SelectPic_"..i.."_"..k)
					if GUI.GetVisible(result) then
						GUI.SetVisible(result, false)
					end
				end
			end
		end
	end
end

function GinSengTreeUI.Init()
	if not GinSengTreeUI.Taps then
		local param = 1
	else
		local param = GinSengTreeUI.Taps
	end
	GinSengTreeUI.OnPageBtnClick_ItemButton(param)
end

