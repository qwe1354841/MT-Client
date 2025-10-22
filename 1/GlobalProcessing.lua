GlobalProcessing = {}
GlobalProcessing.RedPointList = {}
function GlobalProcessing.Main( parameter )

	--CL:LogToChatWindow("设置等级1");

	--test("再次打开GlobalProcessing")

	require "SMovie_System"
	GUI.OpenWnd("Movie_Edge")

	GlobalProcessing['LoadingState'] = 1
	GlobalProcessing['MovieWaiting'] = ""
	GlobalProcessing['MovieSkiper'] = ""

	GlobalProcessing.MovieLoder = {}

	GlobalProcessing.DiscountSequence = {}

	GlobalProcessing['TalkingState'] = 0
	GlobalProcessing["FIGHT_STATUS"] = 0 -- 非战斗状态

	GlobalProcessing.BeStrong_Skill_Red = 0
	if not RECHARGE_DATA then
		RECHARGE_DATA = {}
	end

	--if WelDaySignGiftUI then
	--	WelDaySignGiftUI.DailySignState_1 = nil
	--	WelDaySignGiftUI.DailySignState_2 = nil
	--	WelDaySignGiftUI.DailySignState_3 = nil
	--	WelDaySignGiftUI.DailySignState_4 = nil
	--	WelDaySignGiftUI.DailySignState_5 = nil
	--	WelDaySignGiftUI.DailySignState_6 = nil
	--	WelDaySignGiftUI.DailySignState_7 = nil
	--end
	-- test("WelDaySignGiftUI Init 00000000000000000000000000000000000000000000000000000000000000000000")

	--
	CL.UnRegisterMessage(GM.PlayerExitGame, "GlobalProcessing", "ResetIntegralPK_SeverData")
	CL.RegisterMessage(GM.PlayerExitGame, "GlobalProcessing", "ResetIntegralPK_SeverData")
	CL.UnRegisterMessage(GM.PetQueryNtf, "GlobalProcessing", "OnPetQueryNtf")
	CL.UnRegisterMessage(GM.AddNewItem, "GlobalProcessing", "GetPetEquip")
	CL.UnRegisterMessage(GM.UpdateItem, "GlobalProcessing", "GetPetEquip")
	CL.UnRegisterMessage(GM.RemoveItem, "GlobalProcessing", "GetPetEquip")
	CL.UnRegisterMessage(GM.PetInfoUpdate, "GlobalProcessing", "PetAddPointRedPoint")

	CL.RegisterMessage(GM.PetQueryNtf, "GlobalProcessing", "OnPetQueryNtf")
	CL.RegisterMessage(GM.AddNewItem, "GlobalProcessing", "GetPetEquip")
	CL.RegisterMessage(GM.UpdateItem, "GlobalProcessing", "GetPetEquip")
	CL.RegisterMessage(GM.RemoveItem, "GlobalProcessing", "GetPetEquip")
	CL.RegisterMessage(GM.PetInfoUpdate, "GlobalProcessing", "PetAddPointRedPoint")

	CL.UnRegisterMessage(GM.AddNewItem, "GlobalProcessing", "Equip_Refresh_ItemList")
	CL.UnRegisterMessage(GM.UpdateItem, "GlobalProcessing", "Equip_Refresh_ItemList")
	CL.UnRegisterMessage(GM.RemoveItem, "GlobalProcessing", "Equip_Refresh_ItemList")

	CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.Equip_BindGold_Change)
	CL.UnRegisterAttr(RoleAttr.RoleAttrVp,GlobalProcessing.Equip_Vitality_Change)
	CL.UnRegisterAttr(RoleAttr.RoleAttrLevel,GlobalProcessing.Equip_Level_Change)

	-- 游戏帮助
	require("GameHelpTipsUI")
	CL.UnRegisterMessage(GM.PlayerEnterGame, "GlobalProcessing", "ShowGameHelpTips") -- 当进入游戏时，刷新并展示游戏帮助
	CL.RegisterMessage(GM.PlayerEnterGame, "GlobalProcessing", "ShowGameHelpTips")
	CL.UnRegisterMessage(GM.PlayerExitGame, "GlobalProcessing", "ResetGameHelpTipsList")  -- 退出游戏时，关闭游戏帮助
	CL.RegisterMessage(GM.PlayerExitGame, "GlobalProcessing", "ResetGameHelpTipsList")
	CL.UnRegisterAttr(RoleAttr.RoleAttrLevel,GlobalProcessing.RefreshGameHelpTipsList) -- 升级时，刷新游戏帮助列表
end

function GlobalProcessing.ResetIntegralPK_SeverData()
	GlobalProcessing.IntegralPK_SeverData = nil
end

function GlobalProcessing.OnPetQueryNtf()
	local petData = LD.GetQueryPetData()
	if petData == nil then
		return
	end
	local BourseWnd = GUI.GetWnd("BourseUI")		--交易所界面不需要直接开宠物信息
	if GUI.GetVisible(BourseWnd) then
		require("PetInfoUI")
	else
		GUI.OpenWnd("PetInfoUI")
	end
	PetInfoUI.SetPetData(petData)
end


--使用通用遮罩的UI，本身main中，遮罩的透明度要设为0，同时使用closewnd关闭界面
--UI全部用奇数top:>15000，normal:1-4000 --
local UIList = {
	["ConfirmBox"] = 18999,
}

function GlobalProcessing.WndOpenCallBack(wndname)
	--test("------------------88888888888888888888888888888-------------" .. wndname)
	if wndname == "NpcDialogBoxUI" or wndname == "NpcDialogMovieUI" then
		GlobalProcessing['TalkingState'] = 1
		--test("NpcDialogBoxUI  OPENING....................")
		if DiscountWnd then
			local panel = GUI.GetWnd('DiscountWnd')
			GUI.SetVisible(panel,false)
			--test("SetDiscountVisible")
			panel = GUI.GetWnd("GlobalShadeTop")
			if GUI.GetVisible(panel) == true then
				GUI.SetVisible(panel, false)
			end
		end
	else
		--指定UI使用通用遮罩
		for k,v in pairs(UIList) do
			if k == wndname then
				test("UI Open ======================== " .. k)

				local panel = GUI.GetWnd(wndname)
				GUI.SetDepth(panel,v)

				if v >= 14000 then

					if GlobalShade then
						GUI.CloseWnd("GlobalShade")
					end

					GUI.OpenWnd("GlobalShadeTop")
					local temp = GUI.GetWnd("GlobalShadeTop")
					GUI.SetDepth(temp,v-1)

					if GUI.GetVisible(GUI.GetWnd(wndname)) == false or GUI.GetWnd(wndname) == nil then
						GUI.CloseWnd("GlobalShadeTop")
					end

				else
					if GUI.GetVisible(GUI.GetWnd("GlobalShadeTop")) == false then
						GUI.OpenWnd("GlobalShade")
						local temp = GUI.GetWnd("GlobalShade")
						GUI.SetDepth(temp,v-1)

						if GUI.GetVisible(GUI.GetWnd(wndname)) == false or GUI.GetWnd(wndname) == nil then
							GUI.CloseWnd("GlobalShade")
						end
					else
						GUI.CloseWnd("GlobalShade")
					end

				end

				break
			end
		end
	end
end

function GlobalProcessing.TalkOver()
	GUI.CloseWnd("NpcDialogBoxUI")
	GUI.CloseWnd("QuickUseUI")
	GUI.OpenWnd("MainUI", nil, false)
end

function GlobalProcessing.WndCloseCallBack(key)
	if key == "NpcDialogBoxUI" or key == "NpcDialogMovieUI" then
		if MoviePlaying ~= 1 and GUI.GetVisible(GUI.GetWnd("NpcDialogBoxUI")) == false and GUI.GetVisible(GUI.GetWnd("NpcDialogMovieUI")) == false then
			GlobalProcessing['TalkingState'] = 0
			--test("NpcDialogBoxUI  CLOSING....................")
			if DiscountWnd then
				local panel = GUI.GetWnd("DiscountWnd")
				if GUI.GetVisible(panel) == false then
					GUI.SetVisible(panel, true)
					GUI.SetDepth(panel, 18997)
					panel = GUI.GetWnd("GlobalShadeTop")
					if GUI.GetVisible(panel) == false then
						GUI.SetVisible(panel, true)
					end
					GUI.SetDepth(panel, 18996)
				end
			end
		end
	else
		--使用通用遮罩的UI，关闭遮罩
		if UIList[key] then
			local flag = 0
			for a,b in pairs(UIList) do
				if GUI.GetVisible(GUI.GetWnd(a)) == true then
					if flag < b then
						flag = b
					end
				end
			end

			if flag == 0 then
				GUI.CloseWnd("GlobalShade")
				GUI.CloseWnd("GlobalShadeTop")
			elseif flag > 15000 then
				GUI.OpenWnd("GlobalShadeTop")
				local GlobalShadeTop = GUI.GetWnd("GlobalShadeTop")
				GUI.SetDepth(GlobalShadeTop, flag - 1)
			elseif flag < 4000 then
				GUI.CloseWnd("GlobalShadeTop")
				GUI.OpenWnd("GlobalShade")
				local GlobalShade = GUI.GetWnd("GlobalShade")
				GUI.SetDepth(GlobalShade, flag - 1)
			end
		end
	end
end

function GlobalProcessing.PlayMovie(movie_name)
	test("LoadingState = " .. GlobalProcessing['LoadingState'])
	if GlobalProcessing['LoadingState'] == 1 then
		GlobalProcessing['MovieWaiting'] = movie_name
	elseif GlobalProcessing['LoadingState'] == 0 then
		test("剧情播放2                         " .. movie_name)
		GlobalProcessing.MovieStart(movie_name)
	end
end

function GlobalProcessing.MovieStart(movie_name)
	if GlobalProcessing.MovieLoder['' .. movie_name] == 1 then
		assert(loadstring("" .. movie_name .. ".main()"))()
	else
		require(""..movie_name)
		GlobalProcessing.MovieLoder['' .. movie_name] = 1
	end
end
GlobalProcessing.Main()


-- 显示侍从信息
function GlobalProcessing.ShowGuardInfo(guardId)
	if not GuardInfoUI then require 'GuardInfoUI' end
	if guardId then
		GUI.OpenWnd("GuardInfoUI",guardId)
	else
		-- 获取侍从属性
		local data = LD.GetQueryGuardData()
		if data then
			-- 将侍从属性插入页面
			GuardInfoUI.set_guard_data(data)
			-- 打开界面
			GUI.OpenWnd('GuardInfoUI')
		else
			test("无法获取离线侍从数据，无法打开页面")
			CL.SendNotify(NOTIFY.ShowBBMsg,'系统错误')
		end
	end
end

-- 暂不处理
function GlobalProcessing.CloseRechargeBtn()

end


-- 充值部分
GlobalProcessing.Recharge_List_Normal = {"RechargeOfDay","RechargeOfAcc","RechargeOfCon","ConsumIngotOfDay","ConsumIngotOfAcc","RMBShopOfOnce"}
function GlobalProcessing.RefreshChargeRedpoint(isOnLogin)
	local redpoint = 0
	--if isOnLogin then
	--	--redpoint = 1
	--	test("GlobalProcessing               RechargeSV_DataLoading            "..type(isOnLogin))
	--else
	--if RechargeWnd.GlobalLoginRedPointBtnList then
	--	for k,v in pairs(RechargeWnd.GlobalLoginRedPointBtnList) do
	--		if v == true then
	--			redpoint = 1
	--			break
	--		end
	--	end
	--end
	if redpoint == 0 then
		for k,v in ipairs(GlobalProcessing.Recharge_List_Normal) do
			redpoint = GlobalProcessing.RechargeSV_DataLoading(v)
			if redpoint == 1 then
				break
			end
		end
	end
	--LuckyWheel部分
	if redpoint == 0 then
		redpoint = GlobalProcessing.RechargeSV_DataLoading("LuckyWheel")
	end
	--BuyOfDay部分
	if redpoint == 0 then
		redpoint = GlobalProcessing.RechargeSV_DataLoading("BuyOfDay")
	end
	--LevelFund部分
	if redpoint == 0 then
		redpoint = GlobalProcessing.RechargeSV_DataLoading("LevelFund")
	end
	if redpoint == 0 then
		redpoint = GlobalProcessing.RechargeSV_DataLoading("MonthCard")
	end
	--end
	if redpoint > 0 then
		--test("GlobalProcessing               RedPointController            GlobalProcessing.RedPointController('superValueBtn', 'All', 1)")
		GlobalProcessing.RedPointController("superValueBtn", "All", 1)
	else
		GlobalProcessing.RedPointController("superValueBtn", "All", 0)
	end
end


function GlobalProcessing.RechargeSV_DataLoading(mode)
	local redpoint = 0
	if not GlobalProcessing.Recharge_List_Normal_Ex then
		GlobalProcessing.Recharge_List_Normal_Ex = {}
		for k,v in ipairs(GlobalProcessing.Recharge_List_Normal) do
			GlobalProcessing.Recharge_List_Normal_Ex[v] = k
		end
	end
	if GlobalProcessing.Recharge_List_Normal_Ex[mode] then
		--local tb_config = assert(loadstring("return RECHARGE_DATA." .. mode .. "_Config"))()
		local counts = assert(loadstring("return RECHARGE_DATA." .. mode .. "_MaxConfig"))()
		if assert(loadstring("return RECHARGE_DATA." .. mode .. "_Switch"))() == "on" then
			if type(counts) == "number" then
				for i = 1,counts do
					if assert(loadstring("return RECHARGE_DATA." .. mode .. "_State_" .. i))() == 1 then
						redpoint = 1
						break
					end
				end
			end
		end
	elseif mode == 'LuckyWheel' then
		if RECHARGE_DATA.LuckyWheel_Switch == "on" then
			if RECHARGE_DATA.LuckyWheel_Counts > 0 then
				redpoint = 1
			end
		end
	elseif mode == 'BuyOfDay' then
		if RECHARGE_DATA.BuyOfDay_Switch == "on" then
			if BuyOfDay_State == 1 then
				redpoint = 1
			end
		end
	elseif mode == 'LevelFund' then
		if RECHARGE_DATA.LevelFund_Switch == "on" then
			if RECHARGE_DATA.LevelFund_MaxConfig then
				for i = 1,RECHARGE_DATA.LevelFund_MaxConfig do
					if assert(loadstring("return RECHARGE_DATA.LevelFund_EveryState_" .. i))() == 1 then
						redpoint = 1
						break
					end
				end
			end
		end
	elseif mode == 'MonthCard' then
		if RECHARGE_DATA.MonthCard_Switch == "on" then
			if GlobalProcessing.monthcardConfig and GlobalProcessing.monthcardstate then
				for i = 1,#GlobalProcessing.monthcardConfig do
					if GlobalProcessing.monthcardstate[i] == 1 then
						redpoint = 1
					end
				end
			end
		end
	end
	if redpoint == 1 then
		--test("GlobalProcessing               RechargeSV_DataLoading            "..mode)
	end
	return redpoint
end

-- 转生调用的加点方案(服务端脚本调用)
function GlobalProcessing.SetAddPoint(role_template_id, school, remainPoint)
	local MaxAutoPointCount = 5
	local roleData = DB.GetRole(role_template_id)
	if not roleData or roleData.Id == 0 then
		return
	end
	local pointSuggest
	if school == roleData.School1 then
		pointSuggest = roleData.PointSuggest1
	elseif school == roleData.School2 then
		pointSuggest = roleData.PointSuggest2
	elseif school == roleData.School3 then
		pointSuggest = roleData.PointSuggest3
	end
	local pointDB = DB.GetOncePointByKey1(pointSuggest);
	local n = math.floor(remainPoint / MaxAutoPointCount);
	local p1 = n * pointDB.Str
	local p2 = n * pointDB.Int
	local p3 = n * pointDB.Vit
	local p4 = n * pointDB.End
	local p5 = n * pointDB.Agi
	CL.SendNotify(NOTIFY.SubmitForm, "FormAddPoint", "Player_AddPoint", p1, p2, p3, p4, p5)
end

function GlobalProcessing.BornAutoPoint(role_type, role_guid)
	local pointSuggest = 1
	if role_type == 1 then --玩家
		local role_id = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrRole)))
		local roleData = DB.GetRole(role_id)
		if not roleData or roleData.Id == 0 then
			print("not roleData")
			return
		end
		pointSuggest = roleData.PointSuggest1
		local job = CL.GetIntAttr(RoleAttr.RoleAttrJob1)
		for i = 1, 3 do
			if roleData["School" .. i] == job then
				pointSuggest = roleData["PointSuggest" .. i]
				break
			end
		end
	elseif role_type == 2 then --宠物
		role_guid = role_guid == nil and  uint64.zero or uint64.new(role_guid)
		local petId = LD.GetPetIntAttr(RoleAttr.RoleAttrRole, role_guid);
		local petDB = DB.GetOncePetByKey1(petId);
		pointSuggest = petDB.PointSuggest
	else
		return
	end
	local pointDB = DB.GetOncePointByKey1(pointSuggest);
	local p1 = pointDB.Str
	local p2 = pointDB.Int
	local p3 = pointDB.Vit
	local p4 = pointDB.End
	local p5 = pointDB.Agi
	CL.SendNotify(NOTIFY.SubmitForm, "FormAddPoint", "BornSetAutoPoint", p1, p2, p3, p4, p5, role_type, role_guid)
end

--七日小红点
function GlobalProcessing.Acitvity7Day_Loading()
	GlobalProcessing.OpenSevenDayIndex = 1
	local SetRedPointTable = GlobalProcessing.RedPointTable
	local SevenDayShow = CL.GetIntCustomData("SevenDaySwitch",0)
	if GlobalProcessing.InSevenDay > 7 then
		GlobalProcessing.InSevenDay = 7
	end
	if GlobalProcessing.FightingValue == nil then
		print("表单不存在，返回")
		return
	end
	if SevenDayShow == 1 then
		for i = 1, GlobalProcessing.InSevenDay do
			for k, v in pairs(GlobalProcessing.FightingValue[i]) do
				if v[2] == 1 then
					SetRedPointTable["TaskAward"][i][k] = true
				end
				if v[2] == 2 then
					if tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrFightValue))) > tonumber(v[1]) then
						SetRedPointTable["TaskAward"][i][k] = true
					end
				end
			end
		end
		local RedSumNumMax = 0
		local indexSum = 0
		for k, v in pairs(SetRedPointTable["ScoreAward"]) do
			if v == true then
				RedSumNumMax = RedSumNumMax + 1
			end
		end
		--主页是否领完
		indexSum = 0
		for i = 1, #SetRedPointTable["SignInAward"] do
			if SetRedPointTable["SignInAward"][i] == true then
				RedSumNumMax = RedSumNumMax + 1
				indexSum = indexSum + 1
			end
		end
		if indexSum > 0 then
			GlobalProcessing.OpenSevenDayIndex = 1
		else
			--当天奖励是否领完
			indexSum = 0

			for k, v in pairs(SetRedPointTable["TaskAward"][tonumber(GlobalProcessing.InSevenDay)]) do

				if v == true then
					indexSum = indexSum + 1
				end
			end
			if indexSum > 0 then
				GlobalProcessing.OpenSevenDayIndex = tonumber(GlobalProcessing.InSevenDay) + 1
			else
				--当天都领完判断最早的一天
				local isBreak = 1
				for i=1, #SetRedPointTable["TaskAward"] do
					indexSum = 0
					for j, h in pairs(SetRedPointTable["TaskAward"][i]) do
						if h == true then
							indexSum = indexSum + 1
						end
					end
					if indexSum > 0 then
						GlobalProcessing.OpenSevenDayIndex = i + 1
						isBreak = 2
						break
					else
						isBreak =1
					end
				end
				if isBreak == 1 then
					indexSum = 0
					for k, v in pairs(SetRedPointTable["ScoreAward"]) do
						if v == true then
							indexSum = indexSum + 1
						end
					end
					if indexSum > 0 then
						GlobalProcessing.OpenSevenDayIndex = 2
					else
						GlobalProcessing.OpenSevenDayIndex = 1
					end
				end
			end
		end


		for i=1, #SetRedPointTable["TaskAward"] do
			for j, h in pairs(SetRedPointTable["TaskAward"][i]) do
				if h == true then
					RedSumNumMax = RedSumNumMax + 1
				end
			end
		end
		if RedSumNumMax == 0 then
			GlobalProcessing.RedPointController("dayBtn", "SevenDay",0)
		else
			GlobalProcessing.RedPointController("dayBtn", "SevenDay",1)
		end

		----是否刷新七日UI界面
		--local wnd = GUI.GetWnd("Activity7DaysUI")
		--if wnd == nil then
		--	return
		--else
		--	local ShowWnd = GUI.GetVisible(wnd)
		--	if ShowWnd then
		--		Activity7DaysUI.RequestRed7dayTable()
		--	end
		--end

	end
end
--变强小红点
function GlobalProcessing.BeStrong_Red_Point()
	if GlobalProcessing.BeStrongData ~= nil then
		GlobalProcessing.RedPointController("BeStrongBtn","Achievement",GlobalProcessing.BeStrongData)
	end
end
--变强红点总控
function GlobalProcessing.BeStrongCenter(BtnName)

	if not BeStrongUI then require("BeStrongUI") end
	if BtnName == "WelfareBtn" then
		if GlobalProcessing[BtnName..'_Reds']["LevelPackage"] then
			GlobalProcessing.RedPointController("BeStrongBtn","WelfareEquip",GlobalProcessing[BtnName..'_Reds']["LevelPackage"])
			BeStrongUI.BianQiang_Red_Point("WelfareEquip",GlobalProcessing[BtnName..'_Reds']["LevelPackage"])
		end
	elseif BtnName == "dayBtn" then
		if GlobalProcessing[BtnName..'_Reds']["SevenDay"] then
			if GlobalProcessing.RedPointTable["SignInAward"][7] == true then
				GlobalProcessing.RedPointController("BeStrongBtn","SevenDay",1)
				BeStrongUI.BianQiang_Red_Point("SevenDay",1)
			else
				GlobalProcessing.RedPointController("BeStrongBtn","SevenDay",0)
				BeStrongUI.BianQiang_Red_Point("SevenDay",0)
			end
		end
	elseif BtnName == "skillBtn" then
		if GlobalProcessing[BtnName..'_Reds']["page1"] and GlobalProcessing[BtnName..'_Reds']["page1"] ~= GlobalProcessing.RedPointList[BtnName]["page1"] then
			GlobalProcessing.RedPointController("BeStrongBtn","skillPage1",GlobalProcessing[BtnName..'_Reds']["page1"])
			BeStrongUI.BianQiang_Red_Point("SkillPage1",GlobalProcessing[BtnName..'_Reds']["page1"])
			GlobalProcessing.RedPointList[BtnName]["page1"] = 1
		elseif not GlobalProcessing[BtnName..'_Reds']["page1"] then
			GlobalProcessing.RedPointController("BeStrongBtn","skillPage1",0)
			BeStrongUI.BianQiang_Red_Point("SkillPage1",0)
			GlobalProcessing.RedPointList[BtnName]["page1"] = 0
		end
		if GlobalProcessing[BtnName..'_Reds']["page2"] and GlobalProcessing[BtnName..'_Reds']["page2"] ~= GlobalProcessing.RedPointList[BtnName]["page2"] then
			GlobalProcessing.RedPointController("BeStrongBtn","skillPage2",GlobalProcessing[BtnName..'_Reds']["page2"])
			BeStrongUI.BianQiang_Red_Point("SkillPage2",GlobalProcessing[BtnName..'_Reds']["page2"])
			GlobalProcessing.RedPointList[BtnName]["page2"] = 1
		elseif not GlobalProcessing[BtnName..'_Reds']["page2"] then
			GlobalProcessing.RedPointController("BeStrongBtn","skillPage2",0)
			BeStrongUI.BianQiang_Red_Point("SkillPage2",0)
			GlobalProcessing.RedPointList[BtnName]["page2"] = 0
		end
		if GlobalProcessing[BtnName..'_Reds']["page3"] and GlobalProcessing[BtnName..'_Reds']["page3"] ~= GlobalProcessing.RedPointList[BtnName]["page3"] then
			GlobalProcessing.RedPointController("BeStrongBtn","skillPage3",GlobalProcessing[BtnName..'_Reds']["page3"])
			BeStrongUI.BianQiang_Red_Point("SkillPage3",GlobalProcessing[BtnName..'_Reds']["page3"])
			GlobalProcessing.RedPointList[BtnName]["page3"] = 1
		elseif not GlobalProcessing[BtnName..'_Reds']["page3"] then
			GlobalProcessing.RedPointController("BeStrongBtn","skillPage3",0)
			BeStrongUI.BianQiang_Red_Point("SkillPage3",0)
			GlobalProcessing.RedPointList[BtnName]["page3"] = 0
		end
		if GlobalProcessing[BtnName..'_Reds']["page4"] and GlobalProcessing[BtnName..'_Reds']["page4"] ~= GlobalProcessing.RedPointList[BtnName]["page4"] then
			GlobalProcessing.RedPointController("BeStrongBtn","skillPage4",GlobalProcessing[BtnName..'_Reds']["page4"])
			BeStrongUI.BianQiang_Red_Point("SkillPage4",GlobalProcessing[BtnName..'_Reds']["page4"])
			GlobalProcessing.RedPointList[BtnName]["page4"] = 1
		elseif not GlobalProcessing[BtnName..'_Reds']["page4"] then
			GlobalProcessing.RedPointController("BeStrongBtn","skillPage4",0)
			BeStrongUI.BianQiang_Red_Point("SkillPage4",0)
			GlobalProcessing.RedPointList[BtnName]["page4"] = 0
		end
	elseif BtnName == "equipBtn" then
		if GlobalProcessing[BtnName..'_Reds']["EquipProduce"] and GlobalProcessing[BtnName..'_Reds']["EquipProduce"] ~= GlobalProcessing.RedPointList[BtnName]["EquipProduce"] then
			GlobalProcessing.RedPointController("BeStrongBtn","EquipProduce",GlobalProcessing[BtnName..'_Reds']["EquipProduce"])
			BeStrongUI.BianQiang_Red_Point("EquipProduce",GlobalProcessing[BtnName..'_Reds']["EquipProduce"])
			GlobalProcessing.RedPointList[BtnName]["EquipProduce"] = 1
		end
		if GlobalProcessing[BtnName..'_Reds']["EquipEnhance"] and GlobalProcessing[BtnName..'_Reds']["EquipEnhance"] ~= GlobalProcessing.RedPointList[BtnName]["EquipEnhance"] then
			GlobalProcessing.RedPointController("BeStrongBtn","EquipEnhance",GlobalProcessing[BtnName..'_Reds']["EquipEnhance"])
			BeStrongUI.BianQiang_Red_Point("EquipEnhance",GlobalProcessing[BtnName..'_Reds']["EquipEnhance"])
			GlobalProcessing.RedPointList[BtnName]["EquipEnhance"] = 1
		end
		if GlobalProcessing[BtnName..'_Reds']["GemMerg"] and GlobalProcessing[BtnName..'_Reds']["GemMerg"] ~= GlobalProcessing.RedPointList[BtnName]["GemMerg"] then
			GlobalProcessing.RedPointController("BeStrongBtn","GemMerg",GlobalProcessing[BtnName..'_Reds']["GemMerg"])
			BeStrongUI.BianQiang_Red_Point("GemMerg",GlobalProcessing[BtnName..'_Reds']["GemMerg"])
			GlobalProcessing.RedPointList[BtnName]["GemMerg"] = 1
		end
		if GlobalProcessing[BtnName..'_Reds']["gemInlay"] and GlobalProcessing[BtnName..'_Reds']["gemInlay"] ~= GlobalProcessing.RedPointList[BtnName]["gemInlay"] then
			GlobalProcessing.RedPointController("BeStrongBtn","gemInlay",GlobalProcessing[BtnName..'_Reds']["gemInlay"])
			BeStrongUI.BianQiang_Red_Point("gemInlay",GlobalProcessing[BtnName..'_Reds']["gemInlay"])
			GlobalProcessing.RedPointList[BtnName]["gemInlay"] = 1
		end
	elseif BtnName == "BeStrongBtn" then
		if GlobalProcessing[BtnName..'_Reds']["PetEquip"] and GlobalProcessing[BtnName..'_Reds']["PetEquip"] ~= GlobalProcessing.RedPointList[BtnName]["PetEquip"] then
			BeStrongUI.BianQiang_Red_Point("PetEquip",GlobalProcessing[BtnName..'_Reds']["PetEquip"])
			GlobalProcessing.RedPointList[BtnName]["PetEquip"] = 1
		end
		if GlobalProcessing[BtnName..'_Reds']["PetAddPoint"] and GlobalProcessing[BtnName..'_Reds']["PetAddPoint"] ~= GlobalProcessing.RedPointList[BtnName]["PetAddPoint"] then
			BeStrongUI.BianQiang_Red_Point("PetAddPoint",GlobalProcessing[BtnName..'_Reds']["PetAddPoint"])
			GlobalProcessing.RedPointList[BtnName]["PetAddPoint"] = 1
		end
	elseif BtnName == "teamBtn" then
		if GlobalProcessing[BtnName..'_Reds']["lean"] and GlobalProcessing[BtnName..'_Reds']["lean"] ~= GlobalProcessing.RedPointList[BtnName]["lean"] then
			BeStrongUI.BianQiang_Red_Point("lean_Battle",GlobalProcessing[BtnName..'_Reds']["lean"])
			GlobalProcessing.RedPointList[BtnName]["lean"] = 1
		end
		if GlobalProcessing[BtnName..'_Reds']["level_up"] and GlobalProcessing[BtnName..'_Reds']["level_up"] ~= GlobalProcessing.RedPointList[BtnName]["level_up"] then
			BeStrongUI.BianQiang_Red_Point("level_up_Battle",GlobalProcessing[BtnName..'_Reds']["level_up"])
			GlobalProcessing.RedPointList[BtnName]["level_up"] = 1
		end
	elseif BtnName == "bagBtn" then
		if GlobalProcessing[BtnName..'_Reds']["wing_upgrade"] or GlobalProcessing[BtnName..'_Reds']["wing_level_up"] then
			if GlobalProcessing[BtnName..'_Reds']["wing_upgrade"] == 1 or GlobalProcessing[BtnName..'_Reds']["wing_level_up"] == 1 then
				GlobalProcessing.RedPointController("BeStrongBtn","Wing",1)
				BeStrongUI.BianQiang_Red_Point("Wing",1)
			else
				GlobalProcessing.RedPointController("BeStrongBtn","Wing",0)
				BeStrongUI.BianQiang_Red_Point("Wing",0)
			end
		end
	end
end
-- 福利界面-限时购
function GlobalProcessing.Discount_DataLoading(isOnLogin)
	if not DISCOUNT_CONFIG then
		return
	end

	local DISCOUNT_DATA ={}
	GlobalProcessing.DISCOUNT_CONFIG = {}
	--时间设置
	local serverTime = CL.GetServerTickCount()
	for k, v in pairs(DISCOUNT_CONFIG) do
		local key = k .. "_Overdue"
		if not GlobalProcessing.DiscountData[key] or GlobalProcessing.DiscountData[key] ~= 1 then
			local idx = 1
			local lastTime = v.DiscountTime_1
			local timeKey = k .. "_StartTime"
			for i = 1, 2 do
				local timeV = v["DiscountTime_" .. i]
				if not GlobalProcessing.DiscountData[timeKey] or GlobalProcessing.DiscountData[timeKey] + timeV > serverTime  then
					idx = i
					lastTime = GlobalProcessing.DiscountData[timeKey] and timeV - serverTime + GlobalProcessing.DiscountData[timeKey] or timeV
					break
				end
			end
			DISCOUNT_DATA[#DISCOUNT_DATA + 1] = {k, lastTime, idx}
			v.itemIndex = tostring(k)
			table.insert(GlobalProcessing.DISCOUNT_CONFIG,v)
		end
	end
	table.sort(GlobalProcessing.DISCOUNT_CONFIG,function (a,b)
		if a["TriggerParam"][2] ~= b["TriggerParam"][2] then
			return a["TriggerParam"][2] > b["TriggerParam"][2]
		end
		return false
	end)
	table.sort(DISCOUNT_DATA,function (a,b)
		if a[1] ~= b[1] then
			return a[1] < b[1]
		end
		return false
	end)
	GlobalProcessing.DISCOUNT_DATA = DISCOUNT_DATA
	local min_seconds = 0
	for k,v in ipairs(DISCOUNT_DATA) do
		if v[3] == 1 then
			if min_seconds == 0 then
				min_seconds = v[2]
			elseif min_seconds > v[2] then
				min_seconds = v[2]
			end
		end
	end
	if min_seconds > 0 then
		GlobalProcessing.on_draw_countdown("DiscountBtn", true,min_seconds)
	else
		GlobalProcessing.on_draw_countdown("DiscountBtn", false,0)
	end
	MainSysOpen.SetBtn(RoleAttr.RoleAttrLevel, CL.GetAttr(RoleAttr.RoleAttrLevel))
end
--------------------------------倒计时设置开头------------------------

-- 主界面倒计时时间设置开启/关闭
function GlobalProcessing.on_draw_countdown(BtnName, bool,count_down)
	local obj = MainUI.GetBtn(BtnName)
	if not obj then
		obj = ChatUI.GetBtn(BtnName)
	end
	if obj then
		GlobalProcessing.Min_Seconds = count_down
		GlobalProcessing.SetCountDown(obj, bool)
	end
	CL.UnRegisterMessage(GM.PlayerExitGame, "GlobalProcessing", "StopCountDown")
	CL.UnRegisterMessage(GM.PlayerExitLogin, "GlobalProcessing", "StopCountDown")
	CL.RegisterMessage(GM.PlayerExitGame, "GlobalProcessing", "StopCountDown")
	CL.RegisterMessage(GM.PlayerExitLogin, "GlobalProcessing", "StopCountDown")
end

--设置退出游戏停止时间倒计时
function GlobalProcessing.StopCountDown()
	GlobalProcessing.StopRefreshTimer()
end

-- 给控件显示/隐藏倒计时时间
function GlobalProcessing.SetCountDown(obj, bool,type)
	local CountDownClock = GUI.GetChild(obj, "CountDownClock",false)

	if bool == true then
		if not CountDownClock then
			if type then
				if type == UIDefine.countdown_type.common then
					GlobalProcessing.create_countdown_clock(obj,0,0)
				elseif type == UIDefine.countdown_type.bookmark then
					GlobalProcessing.create_countdown_clock(obj,30,-46,UILayout.TopRight)
				elseif type == UIDefine.countdown_type.icon then
					GlobalProcessing.create_countdown_clock(obj,-15,-15)
				elseif type == UIDefine.countdown_type.plusIcon then
					GlobalProcessing.create_countdown_clock(obj,-7,-7)
				end
			else
				local CountDownClock = GUI.ImageCreate(obj, "CountDownClock", "1801201240", 0, -3, false)
				local CountDownTime = GUI.CreateStatic(CountDownClock,"CountDownTime","06:00:00",0,1,90,32,"system",true)
				GUI.SetVisible(CountDownClock,false)
				GUI.SetColor(CountDownTime,UIDefine.Yellow3Color)
				GUI.StaticSetAlignment(CountDownTime,TextAnchor.MiddleCenter)
				GUI.StaticSetFontSize(CountDownTime,20)
				GlobalProcessing.StartTimer(CountDownClock,CountDownTime)
			end
		else
			GUI.SetVisible(CountDownClock, true)
		end
	else
		GUI.SetVisible(CountDownClock, false)
	end
end

-- 创建时间盘
function GlobalProcessing.create_countdown_clock(obj,x,y,ui_anchor_and_pivot,image_id,width,height)
	if not x then x = 1 end
	if not y then y = 1 end
	if not ui_anchor_and_pivot then ui_anchor_and_pivot = UILayout.TopLeft end
	if not image_id then image_id = "1801201240" end


	local auto_size = true
	local width = width
	local height = height
	if width and height then
		auto_size = false
	else
		width = 0
		height = 0
	end

	local CountDownClock = GUI.ImageCreate(obj, "CountDownClock", image_id, x, y, auto_size,width,height)
	local CountDownTime = GUI.CreateStatic(CountDownClock,"CountDownTime","06:00.:00",0,0,160,32,"system",true)
	GlobalProcessing.StartTimer(CountDownClock,CountDownTime)
	GUI.SetVisible(CountDownClock,false)
	GUI.SetColor(CountDownTime,UIDefine.Yellow3Color)
	GUI.StaticSetFontSize(CountDownTime,20)
	GUI.StaticSetAlignment(CountDownTime,TextAnchor.MiddleCenter)
	UILayout.SetSameAnchorAndPivot(CountDownClock, ui_anchor_and_pivot)
	GUI.SetVisible(CountDownClock, true)
end

function GlobalProcessing.StartTimer(parm1,parm2)
	local fun = function()
		GlobalProcessing.CountDownTimeCallBack(parm1,parm2)
		return nil
	end
	GlobalProcessing.StopRefreshTimer()
	GlobalProcessing.RefreshTimer = Timer.New(fun, 1, -1)
	GlobalProcessing.RefreshTimer:Start()
end

function GlobalProcessing.CountDownTimeCallBack(parm1,parm2)

	if count_down == 0 then
		GlobalProcessing.StopRefreshTimer()
		return
	end
	if GlobalProcessing.Min_Seconds >= 0 then
		local surp = GlobalProcessing.Min_Seconds
		if surp >= 0 then
			local Days = math.floor(surp / (3600 * 24))
			surp = surp - Days * 3600 * 24
			local Hours = math.floor(surp / 3600)
			surp = surp - Hours * 3600
			local Mins = math.floor(surp / 60)
			surp = surp - Mins * 60
			local Secs = surp
			local str = ""
			str = str .. (Hours < 10 and "0" or "") .. Hours .. ":" .. (Mins < 10 and "0" or "") .. Mins .. ":" .. (Secs < 10 and "0" or "") .. Secs

			if parm1 then
				GUI.SetVisible(parm1, true)
				GUI.StaticSetText(parm2, str)
			end
			GlobalProcessing.Min_Seconds = GlobalProcessing.Min_Seconds - 1
			if GlobalProcessing.Min_Seconds < 0 then
				GUI.SetVisible(parm1, false)
			end
		end
	end
end

function GlobalProcessing.StopRefreshTimer()
	if GlobalProcessing.RefreshTimer ~= nil then
		GlobalProcessing.RefreshTimer:Stop()
		GlobalProcessing.RefreshTimer = nil
	end
end

-------------------------------倒计时设置末尾-------------------------

-- 福利界面-每日签到
function GlobalProcessing.DailySign_DataLoading(isOnLogin)
	local WeekDay = CL.GetDayOfWeek()
	--test("GlobalProcessing               DailySign_DataLoading          Start  " .. WeekDay)
	if WeekDay == 0 then
		WeekDay = 7
	end
	local Redpoint = 0
	local IsOpenWnd = 0
	if WelDaySignGiftUI and isOnLogin ~= true then
		if WelDaySignGiftUI.isOpen then
			if WelDaySignGiftUI['DailySignState_'..WeekDay] then
				IsOpenWnd = 1
				GlobalProcessing['DailySignState_'..WeekDay] = WelDaySignGiftUI['DailySignState_'..WeekDay]
				if WelDaySignGiftUI['DailySignState_'..WeekDay] == 1 then
					--test("GlobalProcessing               DailySign_DataLoading          1111111111111  ")
					Redpoint = 0
				else
					--test("GlobalProcessing               DailySign_DataLoading          2222222222222  ")
					Redpoint = 1
				end
			end
		end
	end
	if IsOpenWnd == 0 then
		if GlobalProcessing['DailySignState_'..WeekDay] == 1 then
			--test("GlobalProcessing               DailySign_DataLoading          33333333333333333  " )
			Redpoint = 0
		else
			--test("GlobalProcessing               DailySign_DataLoading          44444444444444444  ")
			Redpoint = 1
		end
	end

	if Redpoint == 1 then
		GlobalProcessing.RedPointController("WelfareBtn", "DailySign", 1)
	else
		GlobalProcessing.RedPointController("WelfareBtn", "DailySign", 0)
	end
	return Redpoint
end

-- 福利界面 - 等级礼包
function GlobalProcessing.LevelPackage_DataLoading(isOnLogin)
	-- local level =
	if isOnLogin == true then
		CL.RegisterAttr(RoleAttr.RoleAttrLevel,GlobalProcessing.LevelPackage_Level_Change)
	end
	local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
	local roleTurn = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
	local Redpoint = 0
	local IsOpenWnd = 0
	if WelLevelGiftUI and isOnLogin ~= true then
		if WelLevelGiftUI.isOpen then
			for level, isGet in pairs(GlobalProcessing.LevelPackageConfig) do
				local levelList = string.split(level,"_")
				if tonumber(levelList[1]) == roleTurn and tonumber(levelList[2]) <= roleLevel then
					if WelLevelGiftUI['State_'..level] then
						IsOpenWnd = 1
						GlobalProcessing.LevelPackageConfig[level] = WelLevelGiftUI['State_'..level]
						if WelLevelGiftUI['State_'..level] == 0 then
							Redpoint = 1
						end
					end
				end
			end
		end
	end
	if IsOpenWnd == 0 then
		for level, isGet in pairs(GlobalProcessing.LevelPackageConfig) do
			local levelList = string.split(level,"_")
			if tonumber(levelList[1]) == roleTurn and tonumber(levelList[2]) <= roleLevel then
				if isGet == 0 then
					Redpoint = 1
				end
			end
		end
	end

	if GlobalProcessing.levelChange then
		GlobalProcessing.levelChange:Stop()
	end
	if Redpoint == 1 then
		GlobalProcessing.RedPointController("WelfareBtn", "LevelPackage", 1)
	else
		GlobalProcessing.RedPointController("WelfareBtn", "LevelPackage", 0)
	end
	return Redpoint
end

function GlobalProcessing.LevelPackage_Level_Change()
	--test("Level_Change")
	if GlobalProcessing.levelChange == nil then
		GlobalProcessing.levelChange = Timer.New(GlobalProcessing.LevelPackage_DataLoading, 0.3, -1)
	else
		GlobalProcessing.levelChange:Stop()
		GlobalProcessing.levelChange:Reset(GlobalProcessing.LevelPackage_DataLoading, 0.3, -1)
	end
	GlobalProcessing.levelChange:Start()
end

-- 福利界面 - 每日在线
function GlobalProcessing.DailyOnline_DataLoading(isOnLogin)
	-- local level =
	local Redpoint = 0
	local IsOpenWnd = 0
	local RedPointCheck = false
	if isOnLogin == true then
		GlobalProcessing.updateTime = Timer.New(GlobalProcessing.UpdateTime, 1, -1)
		GlobalProcessing.ClientSec = CL.GetServerTickCount()
		CL.UnRegisterMessage(GM.PlayerExitGame, "GlobalProcessing", "ResetDailyOnlineRedPointData")
		CL.RegisterMessage(GM.PlayerExitGame, "GlobalProcessing", "ResetDailyOnlineRedPointData")

		GlobalProcessing.DailyOnline_List = {}
		for time, isGet in pairs(GlobalProcessing.WelDailyOnLineConfig) do
			table.insert(GlobalProcessing.DailyOnline_List,tonumber(time))
		end
		table.sort(GlobalProcessing.DailyOnline_List)
		-- local inspect = require("inspect")
		-- test(inspect(GlobalProcessing.DailyOnline_List))
	end

	if isOnLogin == false then
		GlobalProcessing.updateTime:Stop()
		GlobalProcessing.updateTime:Reset(GlobalProcessing.UpdateTime, 1, -1)
	end

	-- if isOnLogin == nil then
	-- 	GlobalProcessing.updateTime:Stop()
	-- 	GlobalProcessing.updateTime:Reset(GlobalProcessing.UpdateTime, 0.1, -1)
	-- end

	-- local inspect = require("inspect")
	-- test(inspect(GlobalProcessing.DailyOnline_List))
	-- test(GlobalProcessing.TodayOnlineSec)
	if WelDailyOnLineUI and isOnLogin ~= true then
		if WelDailyOnLineUI.isOpen then
			for i = 1, #GlobalProcessing.DailyOnline_List, 1 do
				local time = GlobalProcessing.DailyOnline_List[i]
				if GlobalProcessing.TodayOnlineSec >= time then
					if WelDailyOnLineUI["State_" .. i] then
						IsOpenWnd = 1
						GlobalProcessing.WelDailyOnLineConfig[tostring(time)] = WelDailyOnLineUI["State_" .. i]
						if WelDailyOnLineUI["State_" .. i] == 0 then
							Redpoint = 1
						end
					end
				end
			end
		end
	end

	if IsOpenWnd == 0 then
		for time, isGet in pairs(GlobalProcessing.WelDailyOnLineConfig) do
			if GlobalProcessing.TodayOnlineSec >= tonumber(time) then
				if isGet == 0 then
					Redpoint = 1
				end
			end
		end
	end

	if Redpoint == 1 then
		RedPointCheck = true
	end
	if GlobalProcessing.DailyOnlineRedPointFlag == nil then
		GlobalProcessing.DailyOnlineRedPointFlag = false
		GlobalProcessing.RedPointController("WelfareBtn", "DailyOnline", 0)
	end
	if RedPointCheck ~= GlobalProcessing.DailyOnlineRedPointFlag then
		GlobalProcessing.DailyOnlineRedPointFlag = RedPointCheck
		if Redpoint == 1 then
			GlobalProcessing.RedPointController("WelfareBtn", "DailyOnline", 1)
		else
			GlobalProcessing.RedPointController("WelfareBtn", "DailyOnline", 0)
		end
	end
	GlobalProcessing.updateTime:Start()
	-- if GUI.HasWnd("WelfareUI") then
	-- 	WelfareUI.RefreshLeftTypeScroll()
	-- end
	return Redpoint
end

function GlobalProcessing.UpdateTime()
	if GlobalProcessing.TodayOnlineSec then
		GlobalProcessing.TodayOnlineSec = CL.GetServerTickCount() - GlobalProcessing.ClientSec + GlobalProcessing.TodayOnlineSec
		GlobalProcessing.ClientSec = CL.GetServerTickCount()
		GlobalProcessing.DailyOnline_DataLoading(false)
	end
end

function GlobalProcessing.ResetDailyOnlineRedPointData()
	GlobalProcessing.updateTime:Stop()
	GlobalProcessing.updateTime:Reset(GlobalProcessing.UpdateTime, 1, -1)
	GlobalProcessing.TodayOnlineSec = nil
end

--主界面 装备按钮 小红点
function GlobalProcessing.Equip_DataLoading(TB, isOnLogin)
	local parm1 = 0
	local parm2 = 0
	local parm3 = 0
	local parm4 = 0
	if isOnLogin == true then
		GlobalProcessing.EquipProduceUI = {}
		GlobalProcessing.EquipEnhanceUI = {}
		GlobalProcessing.EquipGemInlayUI = {}
		GlobalProcessing.EquipProduceUI.CheckRedPoint_TB = TB[1]
		GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB = TB[2]
		GlobalProcessing.EquipGemInlayUI.CheckRedPoint_TB = TB[3]
		-- local inspect = require("inspect")
		-- parm1 = tostring(GlobalProcessing.EquipProduceUI.CheckRedPoint_TB["WhetherRedPoint"] == "true" or GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB["WhetherRedPoint"] == "true")
		-- parm2 = GlobalProcessing.EquipGemInlayUI.CheckRedPoint_TB["WhetherRedPoint"] == "true"
		parm1 = "false"
		parm2 = "false"
		parm3 = "false"
		parm4 = "false"

		CL.RegisterMessage(GM.AddNewItem, "GlobalProcessing", "Equip_Refresh_ItemList")
		CL.RegisterMessage(GM.UpdateItem, "GlobalProcessing", "Equip_Refresh_ItemList")
		CL.RegisterMessage(GM.RemoveItem, "GlobalProcessing", "Equip_Refresh_ItemList")

		CL.RegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.Equip_BindGold_Change)
		CL.RegisterAttr(RoleAttr.RoleAttrVp,GlobalProcessing.Equip_Vitality_Change)
		CL.RegisterAttr(RoleAttr.RoleAttrLevel,GlobalProcessing.Equip_Level_Change)

		GlobalProcessing.Equip_Create_ItemList()
	else
		parm1 = TB[1]
		parm2 = TB[2]
		parm3 = TB[3]
		parm4 = TB[4]
	end


	if parm1 == "true" then
		GlobalProcessing.RedPointController("equipBtn", "EquipProduce", 1)
	else
		GlobalProcessing.RedPointController("equipBtn", "EquipProduce", 0)
	end
	if parm2 == "true" then
		GlobalProcessing.RedPointController("equipBtn", "EquipEnhance", 1)
	else
		GlobalProcessing.RedPointController("equipBtn", "EquipEnhance", 0)
	end
	if parm3 == "true" then
		GlobalProcessing.RedPointController("equipBtn", "GemMerg", 1)
	else
		GlobalProcessing.RedPointController("equipBtn", "GemMerg", 0)
	end
	if parm4 == "true" then
		GlobalProcessing.RedPointController("equipBtn", "gemInlay", 1)
	else
		GlobalProcessing.RedPointController("equipBtn", "gemInlay", 0)
	end
end
function GlobalProcessing.Equip_BindGold_Change()
	GlobalProcessing.EquipRefresh_BindGoldFlag = true
	GlobalProcessing.Equip_Refresh_ItemList(nil,nil)
end
function GlobalProcessing.Equip_Vitality_Change()
	GlobalProcessing.EquipRefresh_VpFlag = true
	GlobalProcessing.Equip_Refresh_ItemList(nil,nil)
end
function GlobalProcessing.Equip_Level_Change()
	GlobalProcessing.EquipRefresh_LevelFlag = true
	GlobalProcessing.Equip_Refresh_ItemList(nil,nil)
end

-- 创建材料列表
function GlobalProcessing.Equip_Create_ItemList()
	GlobalProcessing.isEquipProduceShowRedPoint = false
	GlobalProcessing.isEquipEnhanceShowRedPoint = false
	GlobalProcessing.isEquipGemMergShowRedPoint = false
	GlobalProcessing.isEquipGemInlayShowRedPoint = false
	-- 创建打造相关的材料列表
	GlobalProcessing.EquipProduce_ItemList = {}
	GlobalProcessing.EquipProduce_HaveItemList = {}
	for level, items in pairs(GlobalProcessing.EquipProduceUI.CheckRedPoint_TB) do
		if type(items) ~= "string" then
			for key, itemValue in pairs(items) do
				for i = 1, #itemValue.ConsumeItem, 2 do
					local keyname = itemValue.ConsumeItem[i]
					local itemDB = DB.GetOnceItemByKey2(keyname)
					if GlobalProcessing.EquipProduce_ItemList[tostring(itemDB.Id)] == nil then
						local itemCount = LD.GetItemCountById(itemDB.Id)
						GlobalProcessing.EquipProduce_ItemList[tostring(itemDB.Id)] = itemCount
						if itemCount == 0 then
						else
							GlobalProcessing.EquipProduce_HaveItemList[itemDB.KeyName] = itemCount
						end
					end
				end
			end
		end
	end

	-- 创建强化相关的材料列表
	local items = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.ClientCheckItem
	GlobalProcessing.EquipEnhance_ItemList = {}
	GlobalProcessing.EquipEnhance_HaveItemList = {}
	for i = 1, #items, 1 do
		local keyname = items[i]
		local itemDB = DB.GetOnceItemByKey2(keyname)
		local itemCount = LD.GetItemCountById(itemDB.Id)
		GlobalProcessing.EquipEnhance_ItemList[tostring(itemDB.Id)] = itemCount
		if itemCount == 0 then
		else
			GlobalProcessing.EquipEnhance_HaveItemList[itemDB.KeyName] = itemCount
		end
	end

	-- 宝石镶嵌相关的装备位置列表
	GlobalProcessing.GemConfig = GlobalProcessing.EquipGemInlayUI.CheckRedPoint_TB.GemConfig

	-- 宝石合成相关的配置表
	GlobalProcessing.ComposeConfig = GlobalProcessing.EquipGemInlayUI.CheckRedPoint_TB.FormualComposeConfig
	GlobalProcessing.EquipGem_AllGemList = {}
	GlobalProcessing.EquipGem_HaveGemList = {}
	local gemBagType = item_container_type.item_container_gem_bag
	for gemId, gemConfig in pairs(GlobalProcessing.GemConfig) do
		local gemDB = DB.GetOnceItemByKey1(gemId)
		local gemCount = LD.GetItemCountById(gemId,gemBagType)
		GlobalProcessing.EquipGem_AllGemList[tostring(gemId)] = {gemCount = gemCount, level = gemDB.Itemlevel,gemType = gemDB.Subtype2}
		if gemCount > 0 then
			GlobalProcessing.EquipGem_HaveGemList[tostring(gemId)] = {gemCount = gemCount, level = gemDB.Itemlevel,gemType = gemDB.Subtype2}
		end
	end
	-- 设置计时器
	GlobalProcessing.OnEquipItemRefresh(false,false,false,false,false,false,false)
	GlobalProcessing.OnEquipItemRefresh(true,true,true,true,true,true,true)
end
-- 刷新材料列表
function GlobalProcessing.Equip_Refresh_ItemList(itemGuid,itemId)
	-- test("************************************")
	-- test(tostring(itemGuid))
	-- test(tostring(itemId))
	if itemId and tostring(itemId) ~= "" then
		local itemDB = DB.GetOnceItemByKey1(tostring(itemId))
		local itemCount = LD.GetItemCountById(tostring(itemId))
		if GlobalProcessing.EquipProduce_ItemList[tostring(itemId)] then
			GlobalProcessing.EquipProduce_ItemFlag = true
			GlobalProcessing.EquipProduce_ItemList[tostring(itemId)] = itemCount
			if itemCount == 0 then
				GlobalProcessing.EquipProduce_HaveItemList[itemDB.KeyName] = nil
			else
				GlobalProcessing.EquipProduce_HaveItemList[itemDB.KeyName] = itemCount
			end
		elseif GlobalProcessing.EquipEnhance_ItemList[tostring(itemId)] then
			GlobalProcessing.EquipEnhance_ItemFlag = true
			GlobalProcessing.EquipEnhance_ItemList[tostring(itemId)] = itemCount
			if itemCount == 0 then
				GlobalProcessing.EquipEnhance_HaveItemList[itemDB.KeyName] = nil
			else
				GlobalProcessing.EquipEnhance_HaveItemList[itemDB.KeyName] = itemCount
			end
		elseif GlobalProcessing.EquipGem_AllGemList[tostring(itemId)] then
			local gemId = tostring(itemId)
			local gemBagType = item_container_type.item_container_gem_bag
			local gemCount = LD.GetItemCountById(gemId,gemBagType)
			GlobalProcessing.EquipGem_ItemFlag = true
			GlobalProcessing.EquipGem_AllGemList[gemId] = {gemCount = gemCount, level = itemDB.Itemlevel,gemType = itemDB.Subtype2}
			if gemCount == 0 then
				GlobalProcessing.EquipGem_HaveGemList[gemId] = nil
			else
				GlobalProcessing.EquipGem_HaveGemList[gemId] = {gemCount = gemCount, level = itemDB.Itemlevel,gemType = itemDB.Subtype2}
			end
		end
		if itemDB.Type == 1 and itemDB.Subtype <= 3 then
			GlobalProcessing.EquipRefresh_ItemFlag = true
		end
	elseif itemGuid then
		-- 从背包里面
		local itemData = LD.GetItemDataByGuid(tostring(itemGuid))
		if itemData then
			local itemDB = DB.GetOnceItemByKey1(tostring(itemData.id))
			local itemCount = LD.GetItemCountById(tostring(itemData.id))
			if GlobalProcessing.EquipProduce_ItemList[tostring(itemData.id)] then
				GlobalProcessing.EquipProduce_ItemFlag = true
				GlobalProcessing.EquipProduce_ItemList[tostring(itemData.id)] = itemCount
				if itemCount == 0 then
					GlobalProcessing.EquipProduce_HaveItemList[itemDB.KeyName] = nil
				else
					GlobalProcessing.EquipProduce_HaveItemList[itemDB.KeyName] = itemCount
				end
			elseif GlobalProcessing.EquipEnhance_ItemList[tostring(itemData.id)] then
				GlobalProcessing.EquipEnhance_ItemFlag = true
				GlobalProcessing.EquipEnhance_ItemList[tostring(itemData.id)] = itemCount
				if itemCount == 0 then
					GlobalProcessing.EquipEnhance_HaveItemList[itemDB.KeyName] = nil
				else
					GlobalProcessing.EquipEnhance_HaveItemList[itemDB.KeyName] = itemCount
				end
			elseif GlobalProcessing.EquipGem_AllGemList[tostring(itemData.id)] then
				local gemId = tostring(itemData.id)
				local gemBagType = item_container_type.item_container_gem_bag
				local gemCount = LD.GetItemCountById(gemId,gemBagType)
				GlobalProcessing.EquipGem_ItemFlag = true
				GlobalProcessing.EquipGem_AllGemList[gemId] = {gemCount = gemCount, level = itemDB.Itemlevel,gemType = itemDB.Subtype2}
				if gemCount == 0 then
					GlobalProcessing.EquipGem_HaveGemList[gemId] = nil
				else
					GlobalProcessing.EquipGem_HaveGemList[gemId] = {gemCount = gemCount, level = itemDB.Itemlevel,gemType = itemDB.Subtype2}
				end
			end
			if itemDB.Type == 1 and itemDB.Subtype <= 3 then
				GlobalProcessing.EquipRefresh_ItemFlag = true
			end
		else
			itemData = LD.GetItemDataByGuid(tostring(itemGuid),item_container_type.item_container_gem_bag)
			if itemData and GlobalProcessing.EquipGem_AllGemList[tostring(itemData.id)] then
				local gemId = tostring(itemData.id)
				local itemDB = DB.GetOnceItemByKey1(gemId)
				local gemBagType = item_container_type.item_container_gem_bag
				local gemCount = LD.GetItemCountById(gemId,gemBagType)
				GlobalProcessing.EquipGem_ItemFlag = true
				GlobalProcessing.EquipGem_AllGemList[gemId] = {gemCount = gemCount, level = itemDB.Itemlevel,gemType = itemDB.Subtype2}
				if gemCount == 0 then
					GlobalProcessing.EquipGem_HaveGemList[gemId] = nil
				else
					GlobalProcessing.EquipGem_HaveGemList[gemId] = {gemCount = gemCount, level = itemDB.Itemlevel,gemType = itemDB.Subtype2}
				end
			end
			itemData = LD.GetItemDataByGuid(tostring(itemGuid),item_container_type.item_container_equip)
			if itemData then
				local itemDB = DB.GetOnceItemByKey1(tostring(itemData.id))
				if itemDB.Type == 1 and itemDB.Subtype <= 3 then
					GlobalProcessing.EquipRefresh_ItemFlag = true
				end
			end
		end
	end

	local equipFlag = GlobalProcessing.EquipRefresh_ItemFlag
	local produceFlag = GlobalProcessing.EquipProduce_ItemFlag
	local enhanceFlag = GlobalProcessing.EquipEnhance_ItemFlag
	local gemFlag = GlobalProcessing.EquipGem_ItemFlag
	local bindGoldFlag = GlobalProcessing.EquipRefresh_BindGoldFlag
	local vpFlag = GlobalProcessing.EquipRefresh_VpFlag
	local levelFlag = GlobalProcessing.EquipRefresh_LevelFlag
	-- 设置计时器
	-- GlobalProcessing.Equip_RedPoint_Refresh_Method(isProduceItemChange,isEnhanceItemChange)
	GlobalProcessing.OnEquipItemRefresh(false,false,false,false,false,false,false)
	GlobalProcessing.OnEquipItemRefresh(equipFlag,produceFlag,enhanceFlag,gemFlag,bindGoldFlag,vpFlag,levelFlag)
end

-- 长按
local flag1,flag2,flag3,flag4,flag5,flag6,flag7 = false,false,false,false,false,false,false
local EquipItemRefreshFuction = function ()
	if flag1 or flag2 or flag3 or flag4 or flag5 or flag6 or flag7 then
		GlobalProcessing.Equip_RedPoint_Refresh_Method(flag1,flag2,flag3,flag4,flag5,flag6,flag7)
	end
end
GlobalProcessing.EquipItemRefreshTimer = Timer.New(EquipItemRefreshFuction,0.03,-1)
-- 循环执行函数
function GlobalProcessing.OnEquipItemRefresh(f1,f2,f3,f4,f5,f6,f7)
	if GlobalProcessing.EquipItemRefreshTimer ~= nil then
		if f1 or f2 or f3 or f4 or f5 or f6 or f7 then
			flag1,flag2,flag3,flag4,flag5,flag6,flag7 = f1,f2,f3,f4,f5,f6,f7
			GlobalProcessing.EquipItemRefreshTimer:Start()
		else
			flag1,flag2,flag3,flag4,flag5,flag6,flag7 = false,false,false,false,false,false,false
			GlobalProcessing.EquipItemRefreshTimer:Stop()
			GlobalProcessing.EquipItemRefreshTimer:Reset(EquipItemRefreshFuction,0.03,-1)
		end
	end
end

-- 装备界面 小红点 刷新方法
function GlobalProcessing.Equip_RedPoint_Refresh_Method(f1,f2,f3,f4,f5,f6,f7)
	local isEquipProduceShowRedPoint = false
	local isEquipEnhanceShowRedPoint = false
	local isEquipGemMergShowRedPoint = false
	local isEquipGemInlayShowRedPoint = false
	local EquipBindGold = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
	local EquipVitality = CL.GetIntAttr(RoleAttr.RoleAttrVp)
	if f5 then
		-- 银币相关-打造、强化、合成
		f2,f3,f4 = true,true,true
	end
	if f6 then
		-- 活力相关-打造
		f2 = true
	end
	-- 如果装备有变动更新装备列表
	if f1 then
		-- 更新装备列表后，进行值的设置
		f3 = true
		f4 = true
		-- local equipList1 = LogicDefine.GetEqiupInBag(nil, item_container_type.item_container_bag)
		local equipList2 = LogicDefine.GetEqiupInBag(nil, item_container_type.item_container_equip)
		GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.Bag = {}
		GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.Equip = {}
		-- for index, item in pairs(equipList1) do
		-- 	if item.subtype <= 3 then
		-- 		local config = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.ConsumeConfig[item.enhanceLv + 1]
		-- 		GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.Bag[tostring(item.guid)] = {}
		-- 		local thisItem = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.Bag[tostring(item.guid)]
		-- 		thisItem[1] = {}
		-- 		thisItem[1].CanIntensify = "false"
		-- 		thisItem[1].Consume = {MoneyType = config.MoneyType,MoneyVal =config.MoneyVal}
		-- 		thisItem[1].ConsumeItem = {config.ItemList[1],config.ItemList[2]}
		-- 	end
		-- end
		for index, item in pairs(equipList2) do
			if item.subtype <= 3 then
				-- local config = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.ConsumeConfig[item.enhanceLv + 1]
				GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.Equip[tostring(item.guid)] = {}
				local thisItem = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.Equip[tostring(item.guid)]
				thisItem[1] = {}
				thisItem[1].CanIntensify = "false"
				thisItem[1].enhanceLv = item.enhanceLv
				-- thisItem[1].Consume = {MoneyType = config.MoneyType,MoneyVal =config.MoneyVal}
				-- thisItem[1].ConsumeItem = {config.ItemList[1],config.ItemList[2]}
			end
		end
	end
	if f2 then
		for level, items in pairs(GlobalProcessing.EquipProduceUI.CheckRedPoint_TB) do
			if type(items) ~= "string" then
				for key, itemValue in pairs(items) do
					local isItemEnough = true
					local isMoneyEnough = true
					local isVitalityEnough = true
					for i = 1, #itemValue.ConsumeItem, 2 do
						local keyname = itemValue.ConsumeItem[i]
						local neednum = itemValue.ConsumeItem[i + 1]
						local count = GlobalProcessing.EquipProduce_HaveItemList[keyname]
						if count then
							if neednum > count then
								isItemEnough = false
							end
						else
							isItemEnough = false
						end
					end
					local MoneyType = itemValue.MoneyCost.MoneyType
					local MoneyVal = itemValue.MoneyCost.MoneyVal
					if MoneyVal > EquipBindGold then
						isMoneyEnough = false
					end
					local Vitality = itemValue.Vitality
					if Vitality > EquipVitality then
						isVitalityEnough = false
					end
					local isEnough = isItemEnough and isMoneyEnough and isVitalityEnough
					if isEnough then
						isEquipProduceShowRedPoint = true
					end
					itemValue.Item.isEnough = tostring(isEnough)
				end
			end
		end
	end
	if f3 then
		-- 最大强化等级
		local MaxEnhanceLv = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.MaxIntensifyLevel or 20
		for key, value in pairs(GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB) do
			if key == "Equip" then
				for itemguid, itemvalue in pairs(value) do
					local enhanceLv = itemvalue[1].enhanceLv
					if enhanceLv < MaxEnhanceLv then
						local isItemEnough = true
						local isMoneyEnough = true
						local config = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.ConsumeConfig[enhanceLv + 1]
						local keyname = config.ItemList[1]
						local neednum = config.ItemList[2]
						local count = GlobalProcessing.EquipEnhance_HaveItemList[keyname]
						if count then
							if neednum > count then
								isItemEnough = false
							end
						else
							isItemEnough = false
						end
						local MoneyType = config.MoneyType
						local MoneyVal = config.MoneyVal
						if MoneyVal > EquipBindGold then
							isMoneyEnough = false
						end
						local isEnough = isItemEnough and isMoneyEnough
						if isEnough then
							isEquipEnhanceShowRedPoint = true
						end
						itemvalue[1].CanIntensify = tostring(isEnough)
					end
				end
			end
		end
	end
	if f4 then
		-- 宝石镶嵌
		GlobalProcessing.EquipGem_HaveGemTypeList = {}
		GlobalProcessing.EquipGem_HaveSiteList = {}
		-- 宝石合成
		GlobalProcessing.EquipGem_MergeGemList = {}
		for i = 0, #UIDefine.EquipSite, 1 do
			GlobalProcessing.EquipGem_HaveSiteList[tostring(i)] = {}
		end
		for i = 1, #UIDefine.GemType, 1 do
			GlobalProcessing.EquipGem_HaveGemTypeList[tostring(i)] = {}
		end
		for gemId, gemValue in pairs(GlobalProcessing.EquipGem_HaveGemList) do
			local gemType = gemValue.gemType
			local gemLevel = gemValue.level
			local gemCount = gemValue.gemCount
			local gemConfig = GlobalProcessing.GemConfig[tonumber(gemId)]
			for i = 1, #gemConfig, 1 do
				local site = tostring(gemConfig[i])
				GlobalProcessing.EquipGem_HaveSiteList[site][gemId] = {gemCount = gemCount, level = gemLevel}
			end
			local gemMergConfig = GlobalProcessing.ComposeConfig[tonumber(gemId) + 1]
			if gemMergConfig and gemCount >= gemMergConfig.ItemNumber then
				GlobalProcessing.EquipGem_MergeGemList[gemId] = {gemCount = gemCount, level = gemLevel}
			end
			GlobalProcessing.EquipGem_HaveGemTypeList[tostring(gemType)][gemId] = {gemCount = gemCount, level = gemLevel}
		end
		-- 宝石合成
		GlobalProcessing.EquipGemMergeUI_Check_Redpot_gemID = {}
		GlobalProcessing.EquipGemMergeUI_Check_Redpot_gemLevel = {}
		for id, value in pairs(GlobalProcessing.EquipGem_MergeGemList) do
			local gemConfig = GlobalProcessing.ComposeConfig[id + 1]
			local MoneyType = gemConfig.MoneyType
			local MoneyVal = gemConfig.MoneyVal
			if EquipBindGold >= MoneyVal then
				isEquipGemMergShowRedPoint = true
				table.insert(GlobalProcessing.EquipGemMergeUI_Check_Redpot_gemID, id);
				table.insert(GlobalProcessing.EquipGemMergeUI_Check_Redpot_gemLevel, value.level);
			end
		end

		-- 宝石镶嵌
		local itemType = item_container_type.item_container_equip
		for key, value in pairs(GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB) do
			if key == "Equip" then
				for guid, itemvalue in pairs(value) do
					local itemData = LD.GetItemDataByGuid(guid,itemType)
					local itemDB = DB.GetOnceItemByKey1(itemData.id)
					local site = LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
					-- 当前装备宝石列表
					local itemGemList = {}
					-- 当前装备宝石的等级列表
					local itemGemLevelList = {}
					local gemCount, siteCount = LogicDefine.GetEquipGemCount(itemData)
					for i = 1, siteCount do
						local gemId = itemData:GetIntCustomAttr(LogicDefine.ITEM_GemId_ .. i)
						table.insert(itemGemList,gemId)
						if gemId == 0 then
							table.insert(itemGemLevelList,0)
						else
							local gemDB = DB.GetOnceItemByKey1(gemId)
							table.insert(itemGemLevelList,tonumber(gemDB.Itemlevel))
						end
					end
					-- 可以镶嵌的宝石最大等级
					local maxitemGemBagLevel = 0
					for id, gemvalue in pairs(GlobalProcessing.EquipGem_HaveSiteList[tostring(site)]) do
						if gemvalue.level > maxitemGemBagLevel then
							maxitemGemBagLevel = gemvalue.level
						end
					end
					-- 检查是否可以镶嵌
					for i = 1, #itemGemLevelList, 1 do
						local itemgemLevel = itemGemLevelList[i]
						if maxitemGemBagLevel > itemgemLevel then
							isEquipGemInlayShowRedPoint = true
							goto checkEnd
						end
					end
				end
			end
		end
	end
	::checkEnd::
	GlobalProcessing.EquipRefresh_ItemFlag = false
	GlobalProcessing.EquipProduce_ItemFlag = false
	GlobalProcessing.EquipEnhance_ItemFlag = false
	GlobalProcessing.EquipGem_ItemFlag = false
	GlobalProcessing.EquipRefresh_BindGoldFlag = false
	GlobalProcessing.EquipRefresh_VpFlag = false
	GlobalProcessing.EquipRefresh_LevelFlag = false
	GlobalProcessing.OnEquipItemRefresh(false,false,false,false,false,false,false)

	if f2 then
		GlobalProcessing.isEquipProduceShowRedPoint = isEquipProduceShowRedPoint
	end
	if f3 then
		GlobalProcessing.isEquipEnhanceShowRedPoint = isEquipEnhanceShowRedPoint
	end
	if f4 then
		GlobalProcessing.isEquipGemMergShowRedPoint = isEquipGemMergShowRedPoint
		GlobalProcessing.isEquipGemInlayShowRedPoint = isEquipGemInlayShowRedPoint
	end

	if MainUI and MainUI.MainUISwitchConfig and MainUI.MainUISwitchConfig["装备"] then
		local CurLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
		local EquipSubList = {"打造","强化","合成","镶嵌"}
		local EquipHideList = {"EquipCreat","EquipIntensify","EquipGem","EquipGem"}
		local EquipSubLevelEnough = {false,false,false,false}
		for i = 1, #EquipSubList, 1 do
			local Key = EquipSubList[i]
			local Level = MainUI.MainUISwitchConfig["装备"].Subtab_OpenLevel_2[Key]
			local hide = UIDefine.FunctionSwitch[EquipHideList[i]] == "on"
			if CurLevel >= Level and hide then
				EquipSubLevelEnough[i] = true
			end
		end
		if GUI.GetWnd("EquipUI") and GUI.GetVisible(GUI.GetWnd("EquipUI")) then
			EquipUI.CheckEquipRedPoint()
		else
			local eqiupPoroduceFlag = GlobalProcessing.isEquipProduceShowRedPoint and EquipSubLevelEnough[1]
			local eqiupEnhanceFlag = GlobalProcessing.isEquipEnhanceShowRedPoint and EquipSubLevelEnough[2]
			local gemMergFlag = GlobalProcessing.isEquipGemMergShowRedPoint and EquipSubLevelEnough[3]
			local gemInlayFlag = GlobalProcessing.isEquipGemInlayShowRedPoint and EquipSubLevelEnough[4]
			local TB = {tostring(eqiupPoroduceFlag),tostring(eqiupEnhanceFlag),tostring(gemMergFlag),tostring(gemInlayFlag)}
			GlobalProcessing.Equip_DataLoading(TB, false)
		end
	else
		CL.SendNotify(NOTIFY.SubmitForm,"FormMainUISwitch","GetMainUISwitchData")
		GlobalProcessing.EquipRefresh_LevelFlag = true
		GlobalProcessing.Equip_Refresh_ItemList(nil,nil)
	end
end


--主界面红点总控
function GlobalProcessing.RedPointController(BtnName, Mode, Visible)
	if not GlobalProcessing[BtnName..'_Reds'] then
		GlobalProcessing[BtnName..'_Reds'] = {}
	end
	if not GlobalProcessing.RedPointList[BtnName] then
		GlobalProcessing.RedPointList[BtnName] = {}
	end
	GlobalProcessing[BtnName..'_Reds'][Mode] = Visible
	--if Visible == 1 then
	--	GlobalProcessing.RedPointList[BtnName][Mode] = 1
	--elseif Visible == 0 then
	--	GlobalProcessing.RedPointList[BtnName][Mode] = 0
	--end
	for k,v in pairs(GlobalProcessing[BtnName..'_Reds']) do
		if v == 1 then
			GlobalProcessing.on_draw_redpoint(BtnName, true)
			GlobalProcessing.BeStrongCenter(BtnName)
			return
		end
	end
	GlobalProcessing.on_draw_redpoint(BtnName, false)
	GlobalProcessing.BeStrongCenter(BtnName)
	GlobalProcessing.RedPointList[BtnName][Mode] = 0
end



--好友按钮小红点
function GlobalProcessing.on_FriendUI_Red(BtnName, bool)
	GlobalProcessing.on_draw_redpoint(BtnName, bool)
	local wnd = GUI.GetWnd("MailUI");
	if wnd ~= nil then
		local friendPageBtn = GUI.Get("MailUI/panelBg/tabList/friendPageBtn")
		GUI.AddRedPoint(friendPageBtn,UIAnchor.TopLeft,25,-35,"1800208080")
		GUI.SetRedPointVisable(friendPageBtn,bool)
	end
end


-- 主界面小红点开启/关闭
function GlobalProcessing.on_draw_redpoint(BtnName, bool)
	--test("GlobalProcessing               on_draw_redpoint          " ..BtnName)
	local obj = MainUI.GetBtn(BtnName)
	if not obj then
		obj = ChatUI.GetBtn(BtnName)
	end
	if obj then
		GlobalProcessing.SetRetPoint(obj, bool)
	end
end

-- 给控件显示/隐藏小红点
function GlobalProcessing.SetRetPoint(obj, bool, type)
	local redpoint = GUI.GetChild(obj, "redpoint",false)

	if bool == true then
		if not redpoint then
			if type then
				if type == UIDefine.red_type.common then
					GlobalProcessing.create_red_point(obj,0,0)
				elseif type == UIDefine.red_type.bookmark then
					GlobalProcessing.create_red_point(obj,30,-46,UILayout.TopRight)
				elseif type == UIDefine.red_type.icon then
					GlobalProcessing.create_red_point(obj,-15,-15)
				elseif type == UIDefine.red_type.plusIcon then
					GlobalProcessing.create_red_point(obj,-7,-7)
				end
			else
				local redpoint = GUI.ImageCreate(obj, "redpoint", "1800208080", 1, 1, true, 0, 0)
				UILayout.SetSameAnchorAndPivot(redpoint, UILayout.TopLeft)
				GUI.SetVisible(redpoint, true)
			end
		else
			GUI.SetVisible(redpoint, true)
		end
	else
		GUI.SetVisible(redpoint, false)
	end
end

-- 创建小红点
function GlobalProcessing.create_red_point(obj,x,y,ui_anchor_and_pivot,image_id,width,height)
	if not x then x = 1 end
	if not y then y = 1 end
	if not ui_anchor_and_pivot then ui_anchor_and_pivot = UILayout.TopLeft end
	if not image_id then image_id = "1800208080" end

	local auto_size = true
	local width = width
	local height = height
	if width and height then
		auto_size = false
	else
		width = 0
		height = 0
	end

	local red_point = GUI.ImageCreate(obj, "redpoint", image_id, x, y, auto_size,width,height)
	UILayout.SetSameAnchorAndPivot(red_point, ui_anchor_and_pivot)
	GUI.SetVisible(red_point, true)
end



-- 侍从小红点数据
GlobalProcessing.guard_red_point_data = nil
-- 获取到侍从小红点数据后的刷新方法容器
GlobalProcessing.guard_red_point_refresh_method = nil
-- 获取侍从小红点数据
function GlobalProcessing.get_guard_red_point_data(refresh_methods,key)
	if not GlobalProcessing.guard_red_point_refresh_method then
		GlobalProcessing.guard_red_point_refresh_method = {}
	end
	--GlobalProcessing.guard_red_point_refresh_method = refresh_methods
	if GlobalProcessing.guard_red_point_refresh_method then
		GlobalProcessing.guard_red_point_refresh_method[key] = refresh_methods
	end
	--[[	if not BeStrongUI then require 'BeStrongUI' end
        if BeStrongUI and BeStrongUI.BianQiang_Red_Point then
            GlobalProcessing.guard_red_point_refresh_method = {refresh_methods, BeStrongUI.BianQiang_Red_Point}
        end]]
	CL.SendNotify(NOTIFY.SubmitForm,'FormGuard','get_guard_red_point_data')

	-- 绑定变量
	-- GlobalProcessing.guard_red_point_data
	-- 刷新方法
	-- GlobalProcessing._refresh_guard_red_point()
end

-- 获取到侍从小红点后，执行的刷新方法
function GlobalProcessing._refresh_guard_red_point()
	-- 向服务器请求的数据是否接收到
	if GlobalProcessing.guard_red_point_data then

		local data = GlobalProcessing._change_data(GlobalProcessing.guard_red_point_data)

		-- 设置主界面侍从小红点
		local bool = false
		for k,v in ipairs(data.kind_red_point) do
			-- 有真就显示主界面红点，并跳出循环
			if v then
				bool = v
				break
			end
		end
		--GlobalProcessing.on_draw_redpoint('retinueBtn', bool)
		if bool then
			GlobalProcessing.RedPointController("BeStrongBtn", "retinueBtn", 1)
			GlobalProcessing.RedPointController("retinueBtn", "guard_red_point", 1)
		else
			GlobalProcessing.RedPointController("BeStrongBtn", "retinueBtn", 0)
			GlobalProcessing.RedPointController("retinueBtn", "guard_red_point", 0)
		end
		-- 开启监听 侍从信物数量变化 事件
		GlobalProcessing._when_guard_item_count_update()

		if GlobalProcessing.guard_red_point_refresh_method then
			local methods = GlobalProcessing.guard_red_point_refresh_method
			-- 如果传入的只有一个刷新方法
			if type(methods) == 'function' then
				-- 执行传入的刷新方法
				methods(data)
				-- 如果传入的是一个table，刷新方法集
			elseif type(methods) == 'table' then
				for k,v in pairs(methods) do
					-- 如果遍历到这个数据是一个方法，执行这个方法
					if type(v) == 'function' then
						v(data)
					end
				end
			end
		end
	else
		test("GlobalProcessing  向服务器请求侍从小红点数据后执行回调方法时 请求的数据为空")
	end

end

-- 侍从信物物品数量变化监听器开关
GlobalProcessing._is_open_guard_event = nil
-- 当侍从信物数量增加或更新时，更新侍从小红点数据
function GlobalProcessing._when_guard_item_count_update()

	-- 获取当前角色id/或名称 ，创建一个全局变量，
	local role_id = CL.GetIntAttr(RoleAttr.RoleAttrRole)
	-- 如果这个全局变量为空则启动监听器，如果这个值与当前角色id相同则不执行，如果与当前角色id不同则 注销监听器（防止上一次的监听器还存在），再重新启动监听器
	if GlobalProcessing._is_open_guard_event == nil then
		GlobalProcessing._is_open_guard_event = role_id
		CL.UnRegisterMessage(GM.AddNewItem,'GlobalProcessing','_guard_item_update_f')
		CL.UnRegisterMessage(GM.UpdateItem,'GlobalProcessing','_guard_item_update_f')
		CL.UnRegisterMessage(GM.RemoveItem, "GlobalProcessing", "_guard_item_update_f")

		CL.RegisterMessage(GM.AddNewItem,'GlobalProcessing','_guard_item_update_f')
		CL.RegisterMessage(GM.UpdateItem,'GlobalProcessing','_guard_item_update_f')
		CL.RegisterMessage(GM.RemoveItem, "GlobalProcessing", "_guard_item_update_f")

	elseif GlobalProcessing._is_open_guard_event ~= role_id then
		GlobalProcessing._is_open_guard_event = role_id

		CL.UnRegisterMessage(GM.AddNewItem,'GlobalProcessing','_guard_item_update_f')
		CL.UnRegisterMessage(GM.UpdateItem,'GlobalProcessing','_guard_item_update_f')
		CL.UnRegisterMessage(GM.RemoveItem, "GlobalProcessing", "_guard_item_update_f")

		CL.RegisterMessage(GM.AddNewItem,'GlobalProcessing','_guard_item_update_f')
		CL.RegisterMessage(GM.UpdateItem,'GlobalProcessing','_guard_item_update_f')
		CL.RegisterMessage(GM.RemoveItem, "GlobalProcessing", "_guard_item_update_f")
	end
end

-- 侍从信物数量变化监听器执行的事件
function GlobalProcessing._guard_item_update_f(item_guid,item_id)
	if item_id == nil or item_id == '' then
		item_id = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id, item_guid,item_container_type.item_container_guard_bag))
	else
		item_id = tonumber(item_id)
	end
	local item = nil
	-- 如果查询到物品id,没有就退出
	if item_id then
		item = DB.GetOnceItemByKey1(item_id)
	else
		return ''
	end
	-- 判断是否是侍从信物,如果不是就直接退出
	if item.Type ~= 6 then return '' end
	-- 获取物品数量
	local item_count = LD.GetItemCountById(item_id,item_container_type.item_container_guard_bag)
	-- 如果物品数量小于激活数量
	if UIDefine.getGuardNeedAmount and GlobalProcessing._can_activate_guard_no_repeat_request == nil then
		if item_count < UIDefine.getGuardNeedAmount then return '' end
	end

	local guard_key_name = string.split(item.KeyName,'信物')
	local guard = DB.GetOnceGuardByKey2(guard_key_name[1])
	-- 获取当前物品更新对应的侍从对象，拿到侍从id，判断此侍从是否已拥有，如果未拥有就判断物品数量是否达到激活数量，如果已拥有就获取侍从星级，判断是否可以升星
	if guard and guard.Id ~=0 then
		local is_have_guard = LD.IsHaveGuard(guard.Id)
		-- 如果还未获取侍从
		if not is_have_guard then
			if UIDefine.getGuardNeedAmount then
				-- 加个全局变量，防止重复请求服务器，当请求数据刷新红点后，后面就不发送请求了
				if GlobalProcessing._can_activate_guard_no_repeat_request == nil then GlobalProcessing._can_activate_guard_no_repeat_request = {} end
				if item_count >= UIDefine.getGuardNeedAmount then
					if GlobalProcessing._can_activate_guard_no_repeat_request[guard.Id] == nil or GlobalProcessing._can_activate_guard_no_repeat_request[guard.Id] == false then
						-- 刷新小红点数据
						CL.SendNotify(NOTIFY.SubmitForm,'FormGuard','get_guard_red_point_data')
						GlobalProcessing._can_activate_guard_no_repeat_request[guard.Id]  = true
					end
					-- 当数量不足时
				else
					if GlobalProcessing._can_activate_guard_no_repeat_request[guard.Id] == nil or GlobalProcessing._can_activate_guard_no_repeat_request[guard.Id] == true then
						-- 刷新小红点数据
						CL.SendNotify(NOTIFY.SubmitForm,'FormGuard','get_guard_red_point_data')
						GlobalProcessing._can_activate_guard_no_repeat_request[guard.Id]  = false
					end
				end
			end


			-- 如果已拥有侍从
		else
			-- 将防止重复请求,"激活侍从"全局变量变空
			if GlobalProcessing._can_activate_guard_no_repeat_request then
				GlobalProcessing._can_activate_guard_no_repeat_request[guard.Id]  = nil
			end

			-- 判断升星数据是否接收到
			if not UIDefine.guard_up_star_token_num then
				CL.SendNotify(NOTIFY.SubmitForm,'FormGuard','get_guard_up_star_data')
				return
			end

			if UIDefine.guard_up_star_token_num then
				local data = UIDefine.guard_up_star_token_num
				-- 获取当前侍从的星级
				local guard_star = CL.GetIntCustomData("Guard_Star",TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(guard.Id)))

				if guard_star > 0 and guard_star < 6 then
					-- 防止重复请求，当满足条件，请求一次后，下次不再请求
					if GlobalProcessing._can_up_star_guard_no_repeat_request == nil then GlobalProcessing._can_up_star_guard_no_repeat_request = {} end
					if item_count >= data[guard_star] then
						if GlobalProcessing._can_up_star_guard_no_repeat_request[guard.Id] == nil or GlobalProcessing._can_up_star_guard_no_repeat_request[guard.Id] == false then
							-- 刷新小红点数据
							CL.SendNotify(NOTIFY.SubmitForm,'FormGuard','get_guard_red_point_data')
							GlobalProcessing._can_up_star_guard_no_repeat_request[guard.Id] = true
						end
						-- 当侍从升星信物不足时
					else
						if GlobalProcessing._can_up_star_guard_no_repeat_request[guard.Id] == nil or GlobalProcessing._can_up_star_guard_no_repeat_request[guard.Id] == true then
							-- 刷新小红点数据
							CL.SendNotify(NOTIFY.SubmitForm,'FormGuard','get_guard_red_point_data')
							GlobalProcessing._can_up_star_guard_no_repeat_request[guard.Id] = false
						end
					end
					-- 如果侍从星级>6  （或小于0的异常情况)
				else
					if GlobalProcessing._can_up_star_guard_no_repeat_request then
						GlobalProcessing._can_up_star_guard_no_repeat_request[guard.Id]	= nil
					end
				end
			end

		end
	end
end

-- 加工侍从数据
function GlobalProcessing._change_data(data)
	local send = {}
	send.guard_reds = {}
	send.kind_red_point = {}
	-- 获取所有侍从
	local guards = LD.GetGuardList_Have_Sorted()

	-- 是否可以升级加成
	local attr_level = false

	for i=0,guards.Count -1 do
		local guard_id = tonumber(guards[i])
		-- 是否拥有此侍从
		local is_have_guard = LD.IsHaveGuard(guard_id)
		local guard = DB.GetOnceGuardByKey1(guard_id)

		local can_activation = false
		local can_up_star = false
		local can_up_attr_level = false
		local can_up_love_skill = false

		-- 当前角色等级
		local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))

		local tabList = nil
		if not GuardUI then require 'GuardUI' end
		if GuardUI and GuardUI.tab_list then
			tabList = GuardUI.tab_list
		else
			tabList = {
				{"属性",},
				{"升星",},
				{"情缘",},
				{"加成",},
				--{"阵容",},
			}
		end



		if not is_have_guard then
			-- 没有此侍从，是否能够激活
			local item_count = LD.GetItemCountById(guard.CallItemIcon,item_container_type.item_container_guard_bag)
			if UIDefine.getGuardNeedAmount then
				can_activation = item_count >= UIDefine.getGuardNeedAmount
			end
			-- 如果有此侍从
		else

			for k, v in ipairs(tabList) do

				local Key = tostring(v[1])
				local Level = MainUI.MainUISwitchConfig["侍从"].Subtab_OpenLevel[Key]

				-- 如果人物等级 >= 打开当前界面的等级
				if CurLevel >= Level then
					-- 获取当前侍从的星级
					local guard_star = CL.GetIntCustomData("Guard_Star",TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(guard.Id)))

					if v[1] == '属性' then
					elseif v[1] == "升星" then
						-- 判断是否能够升星
						if UIDefine.guard_up_star_token_num then
							local data = UIDefine.guard_up_star_token_num
							local item_count = LD.GetItemCountById(guard.CallItemIcon,item_container_type.item_container_guard_bag)
							if guard_star > 0 and guard_star < 6 then
								can_up_star = item_count >= data[guard_star]
							end
						end
					elseif v[1] == "情缘" then

						local guard_id_s = tostring(guard_id)
						if data and data[guard_id_s] then
							-- 判断侍从是否能够提升情缘等级
							if data[guard_id_s].love_skill then
								local skills = data[guard_id_s].love_skill
								-- 最低等级
								local min_level = nil
								for k,v in ipairs(skills) do
									if k < 4 then
										local love_guard_id = guard['Love'..k..'Id']
										local love_guard_star = CL.GetIntCustomData("Guard_Star",TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(love_guard_id)))
										if v < love_guard_star then
											can_up_love_skill = true
											break
										end
										if not min_level then
											min_level = v
										else
											min_level = min_level < v and min_level or v
										end
									end
								end
								-- 如果三个技能都无法升级，判断最终情缘技能
								if not can_up_love_skill then
									if min_level then
										if min_level > skills[4] then
											can_up_love_skill = true
										end
									end
								end
							end
						end

					elseif v[1] == "加成" then

						local guard_id_s = tostring(guard_id)
						if data and data[guard_id_s] then
							-- 判断侍从加成等级是否能够提升
							if data[guard_id_s].guard_attr_level then
								can_up_attr_level = guard_star > data[guard_id_s].guard_attr_level
							end
						end
						-- 如果已经可以升级加成就不再进行判断，否则继续判断
						if not attr_level then
							attr_level = can_up_attr_level
						end

					end
				end
			end

		end




		local guard_data = nil
		if is_have_guard then

			guard_data = {
				is_activation = is_have_guard,
				can_up_star = can_up_star,
				can_up_skill = can_up_star or can_up_love_skill,
				can_up_love_skill = can_up_love_skill,
				can_up_attr_level = can_up_attr_level
			}
		else
			guard_data = {
				is_activation = is_have_guard,
				can_activation = can_activation
			}

		end
		send.guard_reds[tostring(guard_id)] = guard_data
		-- 此侍从种类
		local kind = guard.Type
		if not send.kind_red_point[kind] then
			if guard_data then
				if guard_data.is_activation then
					send.kind_red_point[kind] = guard_data.can_up_star or guard_data.can_up_love_skill or guard_data.can_up_attr_level
				else
					send.kind_red_point[kind] = can_activation
				end
			end
		end
	end
	-- 将是否可以升级加成的属性放入
	send.attr_level = attr_level
	return send
end


--装备绑定提示
function GlobalProcessing.PutOnEquip(guid, dst)
	if not guid or not dst then return end
	local equipData = LD.GetItemDataByGuid(guid, item_container_type.item_container_bag)
	if not equipData then return end
	local isBound = equipData:GetAttr(ItemAttr_Native.IsBound)
	if isBound == "0" then
		local equipId = equipData:GetAttr(ItemAttr_Native.Id)
		local equipDB = DB.GetOnceItemByKey1(tonumber(equipId))
		local msg = "<color=#" ..UIDefine.GradeColorLabel[equipDB.Grade] .. ">"..equipDB.Name.."</color>装备后将绑定，是否继续？"
		GlobalProcessing.CheckPutOnEquip_guid = guid
		GlobalProcessing.CheckPutOnEquip_dst = dst
		GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", msg, "GlobalProcessing", "确定", "PutOnEquipConfirm", "取消")
	elseif isBound == "1" then
		CL.SendNotify(NOTIFY.MoveItem, guid, dst);
	end
end

function GlobalProcessing.PutOnEquipConfirm()
	if not GlobalProcessing.CheckPutOnEquip_guid or not GlobalProcessing.CheckPutOnEquip_dst then return end
	CL.SendNotify(NOTIFY.MoveItem, GlobalProcessing.CheckPutOnEquip_guid, GlobalProcessing.CheckPutOnEquip_dst)
	GlobalProcessing.CheckPutOnEquip_guid = nil
	GlobalProcessing.CheckPutOnEquip_dst = nil
end

function GlobalProcessing.PutOnEquipCancel()
	GlobalProcessing.CheckPutOnEquip_guid = nil
	GlobalProcessing.CheckPutOnEquip_dst = nil
end

-------------------------------------------------------技能小红点start------------------------------------------
-- 技能小红点数据
GlobalProcessing.role_skill_red_point_data = nil
-- 技能小红点方法
GlobalProcessing.role_skill_red_methods = nil

function GlobalProcessing.set_role_skill_red_methods(methods)
	GlobalProcessing.role_skill_red_methods = methods
	CL.SendNotify(NOTIFY.SubmitForm,"FormPlayerSkill","get_role_skill_red_data")
end

GlobalProcessing.role_first_enter_game=true
function GlobalProcessing._refresh_role_skill_red_point()

	-- 把数据先清空，防止有之前残留的数据导致红点出错
	if GlobalProcessing['skillBtn_Reds'] ~= nil then
		GlobalProcessing['skillBtn_Reds'] = nil
	end

	-- 向服务器请求的数据是否接收到
	if GlobalProcessing.role_skill_red_point_data then
		--CDebug.LogError("技能数据是"..inspect(GlobalProcessing.role_skill_red_point_data))
		-- 设置主界面侍从小红点
		if GlobalProcessing.role_first_enter_game then
			GlobalProcessing.role_first_enter_game=false
			GlobalProcessing.SkillRedPointRegisterFunc()
		end
		--local inspect = require("inspect")
		--CDebug.LogError("修炼技能老数据的是"..inspect(GlobalProcessing.role_skill_red_point_data))
		GlobalProcessing.SkillRedPointRefresh()
		--GlobalProcessing.Skill_DataLoading()

		if GlobalProcessing.role_skill_red_methods then
			local methods = GlobalProcessing.role_skill_red_methods
			-- 如果传入的只有一个刷新方法
			if type(methods) == 'function' then
				-- 执行传入的刷新方法
				methods()
				-- 如果传入的是一个table，刷新方法集
			elseif type(methods) == 'table' then
				for k,v in pairs(methods) do
					-- 如果遍历到这个数据是一个方法，执行这个方法
					if type(v) == 'function' then
						v()
					end
				end
			end
		end
	else
		--GlobalProcessing.Skill_DataLoading()
		test("GlobalProcessing  向服务器请求技能小红点数据后执行回调方法时 请求的数据为空")
	end
end



--初次登陆运行该方法,后续也会来
function GlobalProcessing.SkillRedPointRefresh()
	if GlobalProcessing.SkillRedPointTable==nil then
		GlobalProcessing.SkillRedPointTable={
			school_data = {},
			talent_data = nil,
			practice_data = {
				is_has_item=false
			},
			guild_data = {},
		}
	end
	GlobalProcessing.SchoolSkillRedPoint()
	GlobalProcessing.TalentSkillRedPoint()
	GlobalProcessing.PracticeSkillRedPoint()
	--GlobalProcessing.PracticeSkillItemRedPoint()
	GlobalProcessing.GuildSkillRedPoint()  --ok

	--local inspect = require("inspect")
	--CDebug.LogError("修炼技能的是"..inspect(GlobalProcessing.SkillRedPointTable["practice_data"]))
	--CDebug.LogError("技能数据是========================"..inspect(GlobalProcessing.SkillRedPointTable))
	--[[	CDebug.LogError("sdandiahdagbduiahuiafuayifagi")
        local Point = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrRemainPoint)))
        GlobalProcessing.RemainPoint(RoleAttr.RoleAttrRemainPoint,Point)]]
end

--技能小红点注册方法
function GlobalProcessing.SkillRedPointRegisterFunc()
	CL.UnRegisterMessage(GM.PlayerEnterGame, "GlobalProcessing", "ResetSkillRedPointData")
	CL.UnRegisterMessage(GM.RefreshBag,"GlobalProcessing","TalentSkillRedPoint")
	CL.UnRegisterMessage(GM.RefreshBag,"GlobalProcessing","PracticeSkillRedPoint")
	--CUnL.RegisterMessage(GM.RefreshBag,"GlobalProcessing","Skill_DataLoading")
	CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.SchoolSkillRedPoint)
	CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.PracticeSkillRedPoint)
	CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.GuildSkillRedPoint)
	--CUnL.RegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.Skill_DataLoading)
	CL.UnRegisterAttr(RoleAttr.RoleAttrGuildContribute,GlobalProcessing.GuildSkillRedPoint)

	CL.RegisterMessage(GM.PlayerEnterGame, "GlobalProcessing", "ResetSkillRedPointData")
	CL.RegisterMessage(GM.RefreshBag,"GlobalProcessing","TalentSkillRedPoint")
	CL.RegisterMessage(GM.RefreshBag,"GlobalProcessing","PracticeSkillRedPoint")
	--CL.RegisterMessage(GM.RefreshBag,"GlobalProcessing","Skill_DataLoading")
	CL.RegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.SchoolSkillRedPoint)
	CL.RegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.PracticeSkillRedPoint)
	CL.RegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.GuildSkillRedPoint)
	--CL.RegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.Skill_DataLoading)
	CL.RegisterAttr(RoleAttr.RoleAttrGuildContribute,GlobalProcessing.GuildSkillRedPoint)

end

function GlobalProcessing.ResetSkillRedPointData()
	--CDebug.LogError("ResetSkillRedPointData")
	GlobalProcessing.SkillRedPointTable={
		school_data = {},
		talent_data = nil,
		practice_data = {
			is_has_item=false,
		},
		guild_data = {},
	}
	GlobalProcessing.role_first_enter_game=true
end
--技能小红点注销注册的方法
--function GlobalProcessing.SkillRedPointUnRegisterFunc()
--	CL.UnRegisterMessage(GM.RefreshBag,"GlobalProcessing","TalentSkillRedPoint")
--	CL.UnRegisterMessage(GM.RefreshBag,"GlobalProcessing","PracticeSkillItemRedPoint")
--	CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.SchoolSkillRedPoint)
--	CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.PracticeSkillRedPoint)
--	CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold,GlobalProcessing.GuildSkillRedPoint)
--	CL.UnRegisterAttr(RoleAttr.RoleAttrGuildContribute,GlobalProcessing.GuildSkillRedPoint)
--end
--门派技能的的数据处理
function GlobalProcessing.SchoolSkillRedPoint(attrType, changeValue)
	--CDebug.LogError("门派技能刷新")
	if GlobalProcessing.role_skill_red_point_data==nil then
		return
	end
	local data=GlobalProcessing.role_skill_red_point_data["school_data"]
	local roleLevel=CL.GetIntAttr(RoleAttr.RoleAttrLevel)  --人物等级
	local curMoneyAmount=changeValue~=nil and tonumber(tostring(changeValue)) or tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))  --当前角色银币数
	--local curMoneyAmount=0  --当前角色银币数
	--if changeValue~=nil then
	--	curMoneyAmount=tonumber(tostring(changeValue))
	--else
	--	curMoneyAmount = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
	--end
	if data["major_heart_level"] == nil then
		return
	end
	local majorHeartLevel=data["major_heart_level"]
	local moneyType=data["money_type"]
	local tmp={}
	for index, value in pairs(data) do
		if type(index)=="number" then
			local heartLevel=value["heart_level"]
			local moneyValue=value["money_value"]
			if index==1 then  --index==1 说明是主心法
				if heartLevel>=roleLevel then --说明主心法的等级大于等于角色当前等级
					table.insert(tmp,index,false)
				else --说明主心法的等级小于角色当前等级
					if curMoneyAmount>=moneyValue then  --钱够了
						table.insert(tmp,index,true)
					else --钱不够
						table.insert(tmp,index,false)
					end
				end
			else
				if heartLevel>=majorHeartLevel then
					table.insert(tmp,index,false)
				else  --其他心法等级小于主心法等级
					if curMoneyAmount>=moneyValue then
						table.insert(tmp,index,true)
					else
						table.insert(tmp,index,false)
					end
				end
			end
		end
	end
	GlobalProcessing.SkillRedPointTable["school_data"]=tmp
	local flag=false
	local schoolData={false,false,false,false,false,false}
	for index, value in pairs(tmp) do
		if value then
			schoolData[index]=value
		end
	end
	for i, v in ipairs(schoolData) do
		if v then
			flag=true
			break
		end
	end
	if flag then
		GlobalProcessing.RedPointController("skillBtn", "page1", 1)
		--CDebug.LogError("门派确认")
	else
		GlobalProcessing.RedPointController("skillBtn", "page1", 0)
		--CDebug.LogError("门派取消")
	end
	--return tmp
end
--天赋技能的的数据处理
function GlobalProcessing.TalentSkillRedPoint()
	-- CDebug.LogError("天赋技能刷新")
	if GlobalProcessing.role_skill_red_point_data==nil then
		return
	end

	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	local Key = "天赋"
	local Level = MainUI.MainUISwitchConfig["技能"].Subtab_OpenLevel[Key]
	if CurLevel<Level then
		return
	end
	local roleJob="Job_"..tostring(CL.GetAttr(RoleAttr.RoleAttrJob1))
	if UIDefine.PlayerSkillSpell == nil then return end
	local talentSkillList =UIDefine.PlayerSkillSpell.Spell_Config
	local roleLearnedSKill=UIDefine.PlayerSkillSpell.Player_State
	local roleCurrentSchoolTalentSkillList=talentSkillList[roleJob]
	local roleCurTalentSkill=roleLearnedSKill[roleJob]
	local flag=false
	for i = 1, 10 do
		for j = 1, 3 do
			local Id= roleCurrentSchoolTalentSkillList["TalentGroup_"..i]["TalentColumn_"..j].Id
			local bookId=roleCurrentSchoolTalentSkillList["TalentGroup_"..i]["TalentColumn_"..j].TalentItem
			if roleCurTalentSkill[tonumber(Id)]==nil then
				local talentBookAmount= LD.GetItemCountById(bookId)
				local item = DB.GetOnceItemByKey1(bookId)
				if talentBookAmount>0 and item["Level"] <= CurLevel then
					flag=true
					break
				end
			end
		end
	end
	GlobalProcessing.SkillRedPointTable["talent_data"]=flag

	--天赋数据处理
	if flag==true then
		GlobalProcessing.RedPointController("skillBtn", "page2", 1)
		--CDebug.LogError("天赋确认")
	else
		GlobalProcessing.RedPointController("skillBtn", "page2", 0)
		--CDebug.LogError("天赋取消")
	end
end

--修炼技能的的数据处理
function GlobalProcessing.PracticeSkillRedPoint(attrType, changeValue)
	if GlobalProcessing.role_skill_red_point_data==nil then
		return
	end
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	local Key = "修炼"
	local Level = MainUI.MainUISwitchConfig["技能"].Subtab_OpenLevel[Key]
	if CurLevel < Level then
		return
	end
	--CDebug.LogError("修炼技能刷新")
	local flag1 = false  --这是修炼丹的标志
	local flag2 = false  --这是银币的标志

	--CDebug.LogError("修炼技能老数据的是"..inspect(GlobalProcessing.role_skill_red_point_data["practice_data"]))
	local data=GlobalProcessing.role_skill_red_point_data["practice_data"]
	local curMoneyAmount = changeValue~= nil and tonumber(tostring(changeValue)) or tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))  --玩家当前的金币数
	--CDebug.LogError("修炼curMoneyAmount"..curMoneyAmount)

	local maxLevelConfig=UIDefine.SkillLevelLimit
	local roleLevel=CL.GetIntAttr(RoleAttr.RoleAttrLevel)  --人物等级
	local maxLevel=0
	--从最大等级配置中慢慢比对，如果true 与下一个进行比对，如果false 直接跳出循环
	if maxLevelConfig~=nil and next(maxLevelConfig)~=nil then
		for index, value in ipairs(maxLevelConfig) do
			local CultivationSkillLevel=value["level"]
			local CulSkillMaxLevel=value["CulSkillMaxLevel"]
			if tonumber(CultivationSkillLevel)<=roleLevel then
				maxLevel=CulSkillMaxLevel
			else
				break
			end
		end
	end

	--local maxLevel=data["max_level"]
	local needMoney = data["money_value"]
	local nowLevel = data["now_level"]
	local tmp = {}
	for index, value in ipairs(nowLevel) do
		if value >= maxLevel then  --现在的技能大于等于最大等级
			table.insert(tmp,index,{false})
		else
			local tmpOne = {}
			if curMoneyAmount >= needMoney then
				table.insert(tmpOne,1,true)
			else
				table.insert(tmpOne,1,false)
			end

			if curMoneyAmount >= needMoney * 10 then
				table.insert(tmpOne,2,true)
			else
				table.insert(tmpOne,2,false)
			end
			table.insert(tmp,index,tmpOne)
		end
	end
	GlobalProcessing.SkillRedPointTable["practice_data"]=tmp
	--修炼数据处理
	local practiceData = {false,false,false,false,false,false,false,false}
	for index, value in ipairs(tmp) do
		for i, v in ipairs(value) do
			if v then
				practiceData[index] = v
			end
		end
	end
	for i, v in ipairs(practiceData) do
		if v then
			flag2 = true
			break
		end
	end

	local practiceItemConfig={31401,31402,31403,31404}--有关修炼丹的物品Id
	for i, v in ipairs(practiceItemConfig) do
		local practiceItemAmount = LD.GetItemCountById(v)
		if practiceItemAmount > 0 then
			for m, n in ipairs(nowLevel) do
				if n < maxLevel then
					flag1 = true
					break
				end
			end
		end
	end
	GlobalProcessing.SkillRedPointTable["practice_data"]["is_has_item"] = flag1

	if flag1 or flag2 then
		GlobalProcessing.RedPointController("skillBtn", "page3", 1)
		--CDebug.LogError("修炼确认----flag1="..tostring(flag1).."----------flag2="..tostring(flag2))
	else
		GlobalProcessing.RedPointController("skillBtn", "page3", 0)
		--CDebug.LogError("修炼取消")
	end
end
--帮派技能的的数据处理
function GlobalProcessing.GuildSkillRedPoint(attrType, changeValue)

	if GlobalProcessing.role_skill_red_point_data==nil then
		return
	end
	local data=GlobalProcessing.role_skill_red_point_data["guild_data"]

	--local inspect = require("inspect")
	--print("-------------"..inspect(data))

	local roleGuildContribute = attrType == RoleAttr.RoleAttrGuildContribute and tonumber(tostring(changeValue)) or CL.GetIntAttr(RoleAttr.RoleAttrGuildContribute)
	--print("roleGuildContribute = "..roleGuildContribute)
	local curMoneyAmount = attrType == RoleAttr.RoleAttrBindGold and tonumber(tostring(changeValue)) or tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
	--print("changeValue = "..tostring(changeValue))
	--print("CL.GetAttr(RoleAttr.RoleAttrBindGold) = "..tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
	--print("curMoneyAmount = "..curMoneyAmount)
	local tmp = {}
	local needMoney = data["money_value"]
	local needContribute = data["guild_contribute"]
	local maxLevel = data["max_level"]
	if maxLevel == 0 then
		return
	end
	--CDebug.LogError("帮派技能刷新")
	--CDebug.LogError("帮派maxLevel"..maxLevel)
	local nowLevel = data["now_level"]
	for index, value in ipairs(nowLevel) do
		if value >= maxLevel then  --现在的技能大于等于最大等级
			table.insert(tmp,index,{false,false})
		else
			local tmpOne={}
			if curMoneyAmount >= needMoney and roleGuildContribute >= needContribute then
				table.insert(tmpOne,1,true)
			else
				table.insert(tmpOne,1,false)
			end

			if curMoneyAmount >= needMoney * 10 and roleGuildContribute >= needContribute * 10 then
				table.insert(tmpOne,2,true)
			else
				table.insert(tmpOne,2,false)
			end
			table.insert(tmp,index,tmpOne)
		end
	end
	GlobalProcessing.SkillRedPointTable["guild_data"] = tmp

	--print("-------------"..inspect(tmp))

	local flag=false
	local guildData={false,false,false,false,false,false} --帮派数据
	for index, value in ipairs(tmp) do
		for i, v in ipairs(value) do
			if v then
				guildData[index]=v
			end
		end
	end
	for i, v in ipairs(guildData) do
		if v then
			flag=true
			break
		end
	end

	if flag then
		GlobalProcessing.RedPointController("skillBtn", "page4", 1)
		--CDebug.LogError("帮派确认")
	else
		GlobalProcessing.RedPointController("skillBtn", "page4", 0)
		--CDebug.LogError("帮派取消")
	end
end
-------------------------------------------------------技能小红点End------------------------------------------

--存储宠物养成相关数据
function GlobalProcessing.SetPetEduData()

	if not GlobalProcessing.ShowItemList and GlobalProcessing.MedicineItem  then
		--获得宠物培养道具列表
		GlobalProcessing.ShowItemList = {}
		GlobalProcessing.ShowItemNumList = {}
		GlobalProcessing.TempShowItemList = {}
		GlobalProcessing.AlreadyHaveList = {}

		for i=1 , #GlobalProcessing.MedicineItem do
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.MedicineItem[i]["ItemKeyName"])
			local itemNum = LD.GetItemCountById(itemDB.Id)
			if itemNum >0 then
				table.insert(GlobalProcessing.ShowItemList,GlobalProcessing.MedicineItem[i])
				table.insert(GlobalProcessing.ShowItemNumList,1)
				GlobalProcessing.AlreadyHaveList[itemDB.Id] = 1
			else
				if GlobalProcessing.MedicineItem[i]["Show"] ==1 then
					table.insert(GlobalProcessing.TempShowItemList,GlobalProcessing.MedicineItem[i])
				end
			end
		end
		if #GlobalProcessing.TempShowItemList >0 then
			for i =1 , #GlobalProcessing.TempShowItemList do
				table.insert(GlobalProcessing.ShowItemList,GlobalProcessing.TempShowItemList[i])
				table.insert(GlobalProcessing.ShowItemNumList,0)
			end
		end
	end


	if not GlobalProcessing.ShowSkillEduList and GlobalProcessing.SkillStudyShowItem  then
		--获得宠物技能学习书列表
		GlobalProcessing.ShowSkillEduList = {}
		GlobalProcessing.SkillEduGuidList={}
		local tempList = {} -- 当前没有的物品ID列表
		for i = 1 , #GlobalProcessing.SkillStudyShowItem do
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.SkillStudyShowItem[i])
			local num = LD.GetItemCountById(itemDB.Id)
			if num ~= 0 then
				local itemGuid = LD.GetItemGuidsById(itemDB.Id)
				local num = LD.GetItemCountById(itemDB.Id)
				for j = 1, itemGuid.Count do
					table.insert(GlobalProcessing.ShowSkillEduList,{ keyname = GlobalProcessing.SkillStudyShowItem[i], num = 1 })
					table.insert(GlobalProcessing.SkillEduGuidList,itemGuid[j - 1])
				end
			else
				if GlobalProcessing.PetEduSkillUnShow(GlobalProcessing.SkillStudyShowItem[i]) then
					table.insert(tempList, GlobalProcessing.SkillStudyShowItem[i])
				end
			end
		end

		for	i = 1, #tempList do
			table.insert(GlobalProcessing.ShowSkillEduList,{ keyname = tempList[i], num = 0 })
			table.insert(GlobalProcessing.SkillEduGuidList,nil)
		end
	end


	--注册监听事件
	CL.RegisterMessage(GM.AddNewItem, "GlobalProcessing", "UpPetEduDataOnAdd")
	-- CL.RegisterMessage(GM.UpdateItem,"GlobalProcessing",'UpPetEduDataOnUpdata')
	CL.RegisterMessage(GM.RemoveItem, "GlobalProcessing", "UpPetEduDataOnRemove")
	CL.RegisterMessage(GM.PlayerEnterGame, "GlobalProcessing", "ResetUpPetEduData")
end

--当物品变化时刷新宠物养成物品表
function GlobalProcessing.UpPetEduDataOnAdd(guid)
	local itemdata = LD.GetItemDataByGuid(guid)
	if not itemdata then
		return
	end
	local itemDB = DB.GetOnceItemByKey1(itemdata.id)
	if itemDB.Type ==3 and itemDB.Subtype == 13 then
		test("宠物养成物品增加")
		if itemDB.Subtype2 ~= 9 then
			if GlobalProcessing.ShowItemList then
				if GlobalProcessing.AlreadyHaveList and GlobalProcessing.AlreadyHaveList[itemDB.Id] and GlobalProcessing.AlreadyHaveList[itemDB.Id] == 1 then
					if PetUI and PetUI.tabIndex == 2 then
						PetUI.RefreshTrainingTab()
					end
				else
					GlobalProcessing.ShowItemList = {}
					GlobalProcessing.ShowItemNumList = {}
					GlobalProcessing.TempShowItemList = {}
					GlobalProcessing.AlreadyHaveList = {}

					for i=1 , #GlobalProcessing.MedicineItem do
						local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.MedicineItem[i]["ItemKeyName"])
						local itemNum = LD.GetItemCountById(itemDB.Id)
						if itemNum >0 then
							table.insert(GlobalProcessing.ShowItemList,GlobalProcessing.MedicineItem[i])
							table.insert(GlobalProcessing.ShowItemNumList,1)

							GlobalProcessing.AlreadyHaveList[itemDB.Id] = 1
						else
							if GlobalProcessing.MedicineItem[i]["Show"] ==1 then
								table.insert(GlobalProcessing.TempShowItemList,GlobalProcessing.MedicineItem[i])
							end
						end
					end
					if #GlobalProcessing.TempShowItemList >0 then
						for i =1 , #GlobalProcessing.TempShowItemList do
							table.insert(GlobalProcessing.ShowItemList,GlobalProcessing.TempShowItemList[i])
							table.insert(GlobalProcessing.ShowItemNumList,0)
						end
					end
					if PetUI and PetUI.tabIndex == 2 then
						PetUI.RefreshTrainingTab()
					end
				end
			end
			-- CDebug.LogError(tostring(guid))
		elseif itemDB.Subtype2 == 9 then
			-- GlobalProcessing.PetSkillBookState = 1
			if  GlobalProcessing.PetSkillBookTimer then
				GlobalProcessing.PetSkillBookTimer:Stop()
				GlobalProcessing.PetSkillBookTimer:Reset(GlobalProcessing.RefreshPetSkillBook,0.3,-1)
			else
				GlobalProcessing.PetSkillBookTimer = Timer.New(GlobalProcessing.RefreshPetSkillBook,0.3,-1)
			end

			GlobalProcessing.PetSkillBookTimer:Start()
		end
	end
end
-- GlobalProcessing.PetEduBookTimer = Timer.New(GlobalProcessing.BookTest,0.3,-1)

--当物品变化时刷新宠物养成物品表
function GlobalProcessing.UpPetEduDataOnRemove(guid,id)
	-- CDebug.LogError(id)
	-- CDebug.LogError(type(id))
	if not id or id == "" then
		return
	end
	local ItemDB = DB.GetOnceItemByKey1(id)
	if ItemDB.Type ==3 and ItemDB.Subtype == 13 then
		test("宠物养成物品移除")
		if ItemDB.Subtype2 ~= 9  then
			if GlobalProcessing.ShowItemList then
				-- if GlobalProcessing.AlreadyHaveList and GlobalProcessing.AlreadyHaveList[id] then
				test("=======================================================")
				local ItemNum = LD.GetItemCountById(id)
				local BreakMask = 0
				if ItemNum == 0 then
					GlobalProcessing.AlreadyHaveList[tonumber(id)] = 0
					for i =1 , #GlobalProcessing.ShowItemList do
						if BreakMask == 0 then
							if GlobalProcessing.ShowItemList[i]["ItemKeyName"] == ItemDB.KeyName  then
								if GlobalProcessing.ShowItemList[i]["Show"] == 0 then
									table.remove(GlobalProcessing.ShowItemList,i)
									table.remove(GlobalProcessing.ShowItemNumList,i)
									BreakMask = 1
								elseif  GlobalProcessing.ShowItemList[i]["Show"] == 1 then
									GlobalProcessing.TempShowItemList = {}
									table.remove(GlobalProcessing.ShowItemList,i)
									table.remove(GlobalProcessing.ShowItemNumList,i)
									for j =1 ,#GlobalProcessing.MedicineItem do
										if GlobalProcessing.MedicineItem[j]["Show"] == 1 then
											local itemdb = DB.GetOnceItemByKey2(GlobalProcessing.MedicineItem[j]["ItemKeyName"])
											local Num = LD.GetItemCountById(itemdb.Id)
											if Num ==0 then
												table.insert(GlobalProcessing.TempShowItemList,GlobalProcessing.MedicineItem[j])
											end
										end
									end
									for m = #GlobalProcessing.ShowItemNumList , 1, -1 do
										if GlobalProcessing.ShowItemNumList[m] == 0 then
											-- CDebug.LogError(m)
											table.remove(GlobalProcessing.ShowItemList,m)
											table.remove(GlobalProcessing.ShowItemNumList,m)
										end
									end
									for k = 1 ,#GlobalProcessing.TempShowItemList do
										table.insert(GlobalProcessing.ShowItemList,GlobalProcessing.TempShowItemList[k])
										table.insert(GlobalProcessing.ShowItemNumList,0)
									end
									BreakMask = 1
								end
							end
						else
							break
						end
					end
				else
					if GlobalProcessing.ShowItemList then
						if GlobalProcessing.AlreadyHaveList and GlobalProcessing.AlreadyHaveList[ItemDB.Id] and GlobalProcessing.AlreadyHaveList[ItemDB.Id] == 1 then
							if PetUI and PetUI.tabIndex == 2 then
								PetUI.RefreshTrainingTab()
							end
						else
							GlobalProcessing.ShowItemList = {}
							GlobalProcessing.ShowItemNumList = {}
							GlobalProcessing.TempShowItemList = {}
							GlobalProcessing.AlreadyHaveList = {}

							for i=1 , #GlobalProcessing.MedicineItem do
								local ItemDB = DB.GetOnceItemByKey2(GlobalProcessing.MedicineItem[i]["ItemKeyName"])
								local itemNum = LD.GetItemCountById(ItemDB.Id)
								if itemNum >0 then
									table.insert(GlobalProcessing.ShowItemList,GlobalProcessing.MedicineItem[i])
									table.insert(GlobalProcessing.ShowItemNumList,1)

									GlobalProcessing.AlreadyHaveList[ItemDB.Id] = 1
								else
									if GlobalProcessing.MedicineItem[i]["Show"] ==1 then
										table.insert(GlobalProcessing.TempShowItemList,GlobalProcessing.MedicineItem[i])
									end
								end
							end
							if #GlobalProcessing.TempShowItemList >0 then
								for i =1 , #GlobalProcessing.TempShowItemList do
									table.insert(GlobalProcessing.ShowItemList,GlobalProcessing.TempShowItemList[i])
									table.insert(GlobalProcessing.ShowItemNumList,0)
								end
							end
						end
					end
				end
				if PetUI and PetUI.tabIndex == 2 then
					PetUI.RefreshTrainingTab()
				end
				-- end
			end
		elseif ItemDB.Subtype2 == 9 then
			-- GlobalProcessing.PetSkillBookState = 2
			if  GlobalProcessing.PetSkillBookTimer then
				GlobalProcessing.PetSkillBookTimer:Stop()
				GlobalProcessing.PetSkillBookTimer:Reset(GlobalProcessing.RefreshPetSkillBook,0.3,-1)
			else
				GlobalProcessing.PetSkillBookTimer = Timer.New(GlobalProcessing.RefreshPetSkillBook,0.3,-1)
			end

			GlobalProcessing.PetSkillBookTimer:Start()
		end

	end
end


function GlobalProcessing.RefreshPetSkillBook()
	-- if GlobalProcessing.PetSkillBookState == 1 then
	-- test("书增加")
	--技能书添加的时候
	-- if GlobalProcessing.ShowSkillEduList then
	-- local BreakMask = 0
	-- for i= 1 , #GlobalProcessing.SkillEduGuidList do
	-- if BreakMask == 0 then
	-- local data = LD.GetItemDataByGuid(guid)
	-- local itemdb = DB.GetOnceItemByKey1(data.id)
	-- if itemdb.KeyName == itemDB.KeyName then
	-- table.insert(GlobalProcessing.ShowSkillEduList,#GlobalProcessing.SkillEduGuidList+1,{ keyname =itemDB.KeyName, num = 1 })
	-- table.insert(GlobalProcessing.SkillEduGuidList,guid)
	-- BreakMask = 1
	-- end
	-- end
	-- end
	-- if BreakMask == 0 then
	-- for i=1 , #GlobalProcessing.ShowSkillEduList do
	-- if BreakMask == 0 then
	-- if  itemDB.KeyName == GlobalProcessing.ShowSkillEduList[i].keyname then
	-- table.remove(GlobalProcessing.ShowSkillEduList,i)
	-- table.insert(GlobalProcessing.SkillEduGuidList,guid)
	-- table.insert(GlobalProcessing.ShowSkillEduList,#GlobalProcessing.SkillEduGuidList,{ keyname =itemDB.KeyName, num = 1 })
	-- BreakMask = 1
	-- end
	-- end
	-- end
	-- end
	-- end
	-- elseif 	GlobalProcessing.PetSkillBookState == 2 then
	--技能书减少的时候
	if GlobalProcessing.ShowSkillEduList then
		test("宠物技能书变化")
		GlobalProcessing.ShowSkillEduList = {}
		GlobalProcessing.SkillEduGuidList={}
		local tempList = {} -- 当前没有的物品ID列表
		for i = 1 , #GlobalProcessing.SkillStudyShowItem do
			local itemDB = DB.GetOnceItemByKey2(GlobalProcessing.SkillStudyShowItem[i])
			local num = LD.GetItemCountById(itemDB.Id)
			if num ~= 0 then
				local itemGuid = LD.GetItemGuidsById(itemDB.Id)
				for j = 1, itemGuid.Count do
					table.insert(GlobalProcessing.ShowSkillEduList,{ keyname = GlobalProcessing.SkillStudyShowItem[i], num = 1 })
					table.insert(GlobalProcessing.SkillEduGuidList,itemGuid[j - 1])
				end
			else
				if GlobalProcessing.PetEduSkillUnShow(GlobalProcessing.SkillStudyShowItem[i]) then
					table.insert(tempList, GlobalProcessing.SkillStudyShowItem[i])
				end
			end
		end

		for	i = 1, #tempList do
			table.insert(GlobalProcessing.ShowSkillEduList,{ keyname = tempList[i], num = 0 })
			table.insert(GlobalProcessing.SkillEduGuidList,nil)
		end

	end
	-- end
	if PetUI and PetUI.tabIndex == 2 then
		PetUI.RefreshLearningTab()
	end

	GlobalProcessing.PetSkillBookTimer:Stop()
end

--当进入游戏（切换角色服务器）时，清空缓存的宠物相关数据
function GlobalProcessing.ResetUpPetEduData()
	GlobalProcessing.ShowItemList = nil
	GlobalProcessing.ShowSkillEduList = nil
	-- CDebug.LogError("进入游戏进入游戏进入游戏进入游戏进入游戏进入游戏进入游戏进入游戏进入游戏进入游戏进入游戏进入游戏")
	--切换角色时清空注册事件
	-- CL.UnRegisterMessage(GM.AddNewItem, "GlobalProcessing", "UpPetEduDataOnAdd")
	-- CL.UnRegisterMessage(GM.RemoveItem, "GlobalProcessing", "UpPetEduDataOnRemove")
	-- CL.UnRegisterMessage(GM.PlayerEnterGame, "GlobalProcessing", "ResetUpPetEduData")
	-- GlobalProcessing.MedicinePetType={}
	-- GlobalProcessing.MedicineItem ={}
	-- GlobalProcessing.SkillStudyPetType={}
	-- GlobalProcessing.SkillStudyShowItem = {}
	-- GlobalProcessing.SkillExtractPetType = {}
	-- GlobalProcessing.SkillExtractShowOrder = {}
	-- GlobalProcessing.SkillBindPetType = {}
	-- GlobalProcessing.SkillBindItem = ""
	-- GlobalProcessing.SkillUnbindItem = ""

end

function GlobalProcessing.Set7dayData()
	CL.UnRegisterAttr(RoleAttr.RoleAttrFightValue,GlobalProcessing["RefreshSevenDayRed"])
	CL.RegisterAttr(RoleAttr.RoleAttrFightValue,GlobalProcessing["RefreshSevenDayRed"])
	CL.UnRegisterAttr(RoleAttr.RoleAttrFightValue,GlobalProcessing["RefreshSevenDayRed"])
end

function GlobalProcessing.StartTimerSevenDayRed()
	local fun = function()
		GlobalProcessing.SevenDayRedTimeCallBack()
		return nil
	end
	GlobalProcessing.StopRefreshSevenDayRedTimer()
	GlobalProcessing.RefreshSevenDayRedTimer = Timer.New(fun, 0.5, 0.5)
	GlobalProcessing.RefreshSevenDayRedTimer:Start()
end

function GlobalProcessing.StopRefreshSevenDayRedTimer()
	if GlobalProcessing.RefreshSevenDayRedTimer ~= nil then
		GlobalProcessing.RefreshSevenDayRedTimer:Stop()
		GlobalProcessing.RefreshSevenDayRedTimer = nil
	end
end

function GlobalProcessing.SevenDayRedTimeCallBack()
	GlobalProcessing.RefreshSevenDayRed()
	GlobalProcessing.StopRefreshSevenDayRedTimer()
end

GlobalProcessing.RoleAttrFightValue = 0
function GlobalProcessing.RefreshSevenDayRed(FightType,FightValue)
	if FightValue ~= nil then
		GlobalProcessing.RoleAttrFightValue = tonumber(tostring(FightValue))
		if not GlobalProcessing.RefreshSevenDayRedTimer then
			GlobalProcessing.StartTimerSevenDayRed()
		end
		return
	end
	local SevenDayShow = CL.GetIntCustomData("SevenDaySwitch",0)
	local ShowRed = 0
	if SevenDayShow == 1 then
		if GlobalProcessing.FightingValue ~= nil then
			for i = 1, GlobalProcessing.InSevenDay do
				for k, v in pairs(GlobalProcessing.FightingValue[i]) do
					if v[2] == 1 then
						ShowRed = 1
						break
					elseif v[2] == 2 then
						if tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrFightValue))) > tonumber(v[1]) then
							ShowRed = 1
							break
						end
					else
						ShowRed = 0
					end
				end
			end
			GlobalProcessing.RedPointController("dayBtn", "SevenDay",ShowRed)
		else
			print("GlobalProcessing.FightingValue不存在")
		end
	end
end

--获取宠物的技能数量
function GlobalProcessing.GetPetSkillCountByGuid(guid)
	local skills=LD.GetPetSkills(guid)
	local num = LD.GetPetSkillCount(guid)
	local Count = 0
	if num > 0 then
		for i = 0, num-1 do
			local skillDB = DB.GetOnceSkillByKey1(skills[i].id)
			if skillDB.SubType ~= 14 then
				Count = Count +1
			end
		end
	end
	return Count
end

--获得宠物的技能
function GlobalProcessing.GetPetSkillByGuid(guid)
	local skills=LD.GetPetSkills(guid)
	local num = LD.GetPetSkillCount(guid)
	local t ={}
	local TempSkill = {}
	local TempNum = 0
	if num > 0 then
		for i = 0, num-1 do
			local skillDB = DB.GetOnceSkillByKey1(skills[i].id)
			if skillDB.SubType ~= 14 then
				if TempNum == 0 then
					table.insert(TempSkill,0,skills[i])
				else
					table.insert(TempSkill,skills[i])
				end
				TempNum = TempNum +1
			end
		end
	end
	return TempSkill
end


function GlobalProcessing.GetPetSkillCountByGuidWithoutMounts(guid)
	local skills=LD.GetPetSkills(guid)
	local num = LD.GetPetSkillCount(guid)
	local Count = 0
	if num > 0 then
		for i = 0, num-1 do
			local skillDB = DB.GetOnceSkillByKey1(skills[i].id)
			if skillDB.SubType ~= 14 and skillDB.SubType ~= 15 then
				Count = Count +1
			end
		end
	end
	return Count
end

function GlobalProcessing.GetPetSkillByGuidWithoutMounts(guid)
	local skills=LD.GetPetSkills(guid)
	local num = LD.GetPetSkillCount(guid)
	local t ={}
	local TempSkill = {}
	local TempNum = 0
	if num > 0 then
		for i = 0, num-1 do
			local skillDB = DB.GetOnceSkillByKey1(skills[i].id)
			if skillDB.SubType ~= 14 and skillDB.SubType ~= 15 then
				if TempNum == 0 then
					table.insert(TempSkill,0,skills[i])
				else
					table.insert(TempSkill,skills[i])
				end
				TempNum = TempNum +1
			end
		end
	end
	return TempSkill
end

--- 生产主页面小红点
function GlobalProcessing.ProduceRedPoint()
	CL.UnRegisterMessage(GM.AddNewItem, "GlobalProcessing", "ResetBagProduceRedPoint")
	CL.UnRegisterMessage(GM.UpdateItem, "GlobalProcessing", "ResetBagProduceRedPoint")
	CL.UnRegisterMessage(GM.RemoveItem, "GlobalProcessing", "ResetBagProduceRedPoint")
	CL.UnRegisterAttr(RoleAttr.RoleAttrVp, GlobalProcessing.ResetVPProduceRedPoint)

	-- 监听背包状态
	CL.RegisterMessage(GM.AddNewItem, "GlobalProcessing", "ResetBagProduceRedPoint")
	CL.RegisterMessage(GM.UpdateItem, "GlobalProcessing", "ResetBagProduceRedPoint")
	CL.RegisterMessage(GM.RemoveItem, "GlobalProcessing", "ResetBagProduceRedPoint")
	-- 监听活力变化
	CL.RegisterAttr(RoleAttr.RoleAttrVp, GlobalProcessing.ResetVPProduceRedPoint)
end

-- 活力变化时传值给刷新方法
function GlobalProcessing.ResetVPProduceRedPoint(attrType, value)
	local VP = tonumber(tostring(value))
	GlobalProcessing.ResetProduceRedPoint(VP)
end

-- 背包物品刷新时，根据获得到的id或guid来获得item
function GlobalProcessing.ResetBagProduceRedPoint(guid, id)
	if id and tostring(id) ~= "" then
		local itemDB = DB.GetOnceItemByKey1(tostring(id))
		GlobalProcessing.toResetProduceRedPoint(itemDB["ShowType"])
	elseif guid then
		local itemData = LD.GetItemDataByGuid(tostring(guid))
		if itemData then
			local itemDB = DB.GetOnceItemByKey1(tostring(itemData.id))
			GlobalProcessing.toResetProduceRedPoint(itemDB["ShowType"])
			-- CDebug.LogError(itemDB["ShowType"])
		end
	end
end

-- 根据传入的showType来决定是否需要刷新
function GlobalProcessing.toResetProduceRedPoint(showType)
	if showType == "制药材料" or showType == "烹饪材料" or showType == "烹饪佐料" then
		GlobalProcessing.ResetProduceRedPoint()
	end
end

-- 主要的刷新方法，VP不传值的话代表VP没有改变，直接可以使用默认的VP
function GlobalProcessing.ResetProduceRedPoint(VP)
	-- 先把红点默认给0防止里面没有红点了外面还有红点
	GlobalProcessing.RedPointController("produceBtn", "medicine", 0)
	GlobalProcessing.RedPointController("produceBtn", "food", 0)

	if GlobalProcessing.produce_data == nil then
		return
	end

	local food_data = GlobalProcessing.produce_data["food_data"]
	local medicine_data = GlobalProcessing.produce_data["medicine_data"]
	if food_data == nil or medicine_data == nil then
		return
	end
	local roleVP = 0

	if VP == nil then
		roleVP = CL.GetIntAttr(RoleAttr.RoleAttrVp)
	else
		roleVP = VP
	end

	-- CDebug.LogError("当前VP : " .. roleVP)
	for i, v in pairs(food_data) do
		-- flag = 3 代表三种材料都齐全
		local flag = 0
		for j = 1, 3 do
			local materialsData=DB.GetOnceItemByKey2(v["Item"..j])
			-- 背包物品数据
			local materialsInBagAmount = LD.GetItemCountById(materialsData.Id)
			if v["ItemNumber"..j] <= materialsInBagAmount then
				flag = flag + 1
			end
		end
		if flag == 3 and roleVP >= v["VP"] then
			GlobalProcessing.RedPointController("produceBtn", "food", 1)
			break
		end
	end

	for i, v in pairs(medicine_data) do
		local flag = 0
		for j = 1, 3 do
			local materialsData=DB.GetOnceItemByKey2(v["Item"..j])
			-- 背包物品数据
			local materialsInBagAmount = LD.GetItemCountById(materialsData.Id)
			if v["ItemNumber"..j] <= materialsInBagAmount then
				flag = flag + 1
			end
		end
		if flag == 3 and roleVP >= v["VP"] then
			GlobalProcessing.RedPointController("produceBtn", "medicine", 1)
			break
		end
	end
end

--进入服务器获得宠物养成数据
function GlobalProcessing.GetPetEduData()
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	if MainUI.MainUISwitchConfig then
		local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel["养成"]
		if Level >= OpenLevel and not GlobalProcessing.ShowItemList then
			CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","MedicineGetData")
			CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","SkillStudyGetData")
			CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","RestoreGetData")
			CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","SkillExtractGetData")
			CL.SendNotify(NOTIFY.SubmitForm,"FormPetDevelop","SkillBindGetData")
		else
			CL.RegisterAttr(RoleAttr.RoleAttrLevel,GlobalProcessing.OnRoleLevelChange)
		end
	end
end

function GlobalProcessing.OnRoleLevelChange()
	local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	if MainUI.MainUISwitchConfig then
		local OpenLevel = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel["养成"]
		if Level >= OpenLevel then
			CL.UnRegisterAttr(RoleAttr.RoleAttrLevel,GlobalProcessing.OnRoleLevelChange)
			GlobalProcessing.GetPetEduData()
		end
	end

end

function GlobalProcessing.LineUpPetEquipRedPoint()
	if UIDefine.NowLineupList then
		local mark = 0
		local equipSiteData={
			[1]={site=LogicDefine.PetEquipSite.site_collar,img="1801400030"},
			[2]={site=LogicDefine.PetEquipSite.site_armor,img="1801400040"},
			[3]={site=LogicDefine.PetEquipSite.site_amulet,img="1801400050"},
			[4]={site=LogicDefine.PetEquipSite.site_accessory,img="1801400060"}
		}
		for i =0 , #UIDefine.NowLineupList-1 do
			--获得已穿戴的宠物装备数据
			local Key = UIDefine.NowLineupList[i]
			if tostring(Key) ~= "-1" then
				for j =0 , #equipSiteData-1 do
					if mark == 1 then
						break
					else
						local equipData=LD.GetItemDataByIndex(j,item_container_type.item_container_pet_equip,Key)
						--当宠物穿戴了装备
						if equipData then
							local id = equipData:GetAttr(ItemAttr_Native.Id)
							local CurItemDB = DB.GetOnceItemByKey1(id)
							local CurEquipLv = CurItemDB.Level
							local CurEquipGra = CurItemDB.Grade
							--遍历背包
							local count = LD.GetItemCount()
							for k = 0, count - 1 do
								if mark ~=1 then
									local itemGuid = LD.GetItemGuidByItemIndex(k);
									local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
									local itemDB = DB.GetOnceItemByKey1(itemId);

									if itemDB.Type == 1  and itemDB.Subtype==7 and tonumber(itemDB.Subtype2) == j+1  then
										if CurEquipLv < itemDB.Level then
											local PetLevel = UIDefine.GetPetLevelStrByGuid(Key)
											if PetLevel >= itemDB.Level then
												mark = 1
											end
										elseif CurEquipLv == itemDB.Level then
											if CurEquipGra < itemDB.Grade then
												local PetLevel = UIDefine.GetPetLevelStrByGuid(Key)
												if PetLevel >= itemDB.Level then
													mark = 1
												end
											end
										end
									end
								end
							end
							--若该宠物没有佩戴装备
						else
							local count = LD.GetItemCount()
							for k = 0, count - 1 do
								if mark ~= 1 then
									local itemGuid = LD.GetItemGuidByItemIndex(k)
									local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, itemGuid)
									local itemDB = DB.GetOnceItemByKey1(itemId)
									if itemDB.Type == 1  and itemDB.Subtype==7 and tonumber(itemDB.Subtype2) == j+1  then
										local PetLevel = UIDefine.GetPetLevelStrByGuid(Key)
										if PetLevel >= itemDB.Level then
											mark = 1
										end
									end
								end
							end
						end
					end
				end
			end
		end

		GlobalProcessing.RedPointController("BeStrongBtn", "PetEquip", mark)
	end
end


function GlobalProcessing.PetAddPointRedPoint()
	if UIDefine.NowLineupList then
		local mark = 0
		for i=0 ,#UIDefine.NowLineupList-1 do
			if mark ~= 1 then
				local Key = UIDefine.NowLineupList[i]
				if tostring(Key) ~= "-1" then
					if LD.GetPetIntAttr(RoleAttr.RoleAttrRemainPoint,Key) ~=0 then
						mark = 1
					end
				end
			end
		end
		GlobalProcessing.RedPointController("BeStrongBtn", "PetAddPoint", mark)
	end
end

function GlobalProcessing.GetPetEquip(guid,id)
	if id == nil then
		local Equip = LD.GetItemDataByGuid(guid)
		if Equip ~= nil then
			local EquipDB = DB.GetOnceItemByKey1(Equip.id)
			if EquipDB.Type == 1 and EquipDB.Subtype == 7 then
				GlobalProcessing.LineUpPetEquipRedPoint()
			end
		end
	else
		--CDebug.LogError(id)
		--CDebug.LogError(type(id))
		if tonumber(id) == nil then
			return
		end
		--CDebug.LogError("zzzzzzzzzz")
		local EquipDB = DB.GetOnceItemByKey1(tonumber(id))
		if not EquipDB then return end
		if EquipDB.Type == 1 and EquipDB.Subtype == 7 then
			GlobalProcessing.LineUpPetEquipRedPoint()
		end
	end
end

function GlobalProcessing.RemainPoint(AttrType,Value)
	if not BeStrongUI then require("BeStrongUI") end
	if tonumber(tostring(Value)) > 0 then
		GlobalProcessing.RedPointController("BeStrongBtn","RoleRemainPoint",1)
		BeStrongUI.BianQiang_Red_Point("RoleRemainPoint",1)
	else
		GlobalProcessing.RedPointController("BeStrongBtn","RoleRemainPoint",0)
		BeStrongUI.BianQiang_Red_Point("RoleRemainPoint",0)
	end
end


-- 阵法小红点
-- 是否有未满级的阵法
GlobalProcessing.battle_seat_red = false
-- 已学习阵法列表
GlobalProcessing.learning_seat_list = {}

-- 是否显示阵法主界面小红点
function GlobalProcessing.is_show_battle_seat_red()

	-- 有已学习未满级的阵法，且有升级阵法的材料
	local no_max_level_red = false
	-- 判断是否有未满级的阵法
	if GlobalProcessing.battle_seat_red ~= nil and GlobalProcessing.battle_seat_red == true then
		-- 判断是否有阵法书或阵法书材料，有的话显示小红点
		no_max_level_red = UIDefine.is_have_seat_material()
	end

	-- 有学习阵法的材料，且阵法未学习
	-- 本可放到上面判断的else，但变强需要借用
	local have_lean_seat = false
	if next(GlobalProcessing.learning_seat_list) ~= nil then
		have_lean_seat = UIDefine.have_lean_seat(GlobalProcessing.learning_seat_list)
	end

	if no_max_level_red then
		GlobalProcessing.RedPointController("teamBtn", "level_up", 1)
	else
		GlobalProcessing.RedPointController("teamBtn", "level_up", 0)
	end

	if have_lean_seat then
		GlobalProcessing.RedPointController("teamBtn", "lean", 1)
	else
		GlobalProcessing.RedPointController("teamBtn", "lean", 0)
	end

end

-- 注册阵法监听事件
function GlobalProcessing.seat_register_message()
	-- 注销阵法小红点监听事件
	CL.UnRegisterMessage(GM.AddNewItem,'GlobalProcessing','_when_update_seat_material')
	CL.UnRegisterMessage(GM.RemoveItem,'GlobalProcessing','_when_update_seat_material')
	CL.UnRegisterMessage(GM.UpdateItem,'GlobalProcessing','_when_update_seat_material')

	-- 阵法小红点注册消息
	CL.RegisterMessage(GM.AddNewItem,'GlobalProcessing','_when_update_seat_material')
	CL.RegisterMessage(GM.RemoveItem,'GlobalProcessing','_when_update_seat_material')
	CL.RegisterMessage(GM.UpdateItem,'GlobalProcessing','_when_update_seat_material')
end

-- 当阵法书材料变化时,监听事件调用函数
function GlobalProcessing._when_update_seat_material(item_guid,item_id)
	if not item_id or item_id == '' then
		-- 如果是侍从信物之类的物品,背包不同无法获取到，就直接退出
		local item_data = LD.GetItemDataByGuid(item_guid)
		if item_data and item_data.id then
			item_id = item_data.id
		else
			return ''
		end
	end
	item_id = tonumber(item_id)

	if item_id == nil then
		test('GlobalProcessing._when_update_seat_material item_id == nil')
		return ''
	end

	local material  =  UIDefine._seat_all_material or UIDefine.get_all_seat_material()

	for i=1, #material do
		-- 如果更新的物品是阵法材料, 执行刷新小红点
		if  item_id == material[i] then
			GlobalProcessing.get_battle_seat_red()
			break
		end
	end

end

-- 获取阵法按钮红点数据
function GlobalProcessing.get_battle_seat_red()
	-- 获取是否有未满级的阵法
	-- 返回值 GlobalProcessing.battle_seat_red
	-- 回调方法3 GlobalProcessing.seat_register_message() 注册监听事件
	-- 回调方法2 GlobalProcessing.is_show_battle_seat_red() -- 主界面小红点
	-- 回调方法1 TeamPanelUI.is_show_b_seat_red()
	CL.SendNotify(NOTIFY.SubmitForm, 'FormSeat', 'IsAllSeatMaxLevel')
end

function GlobalProcessing.AchievementListen()
	CL.UnRegisterAttr(RoleAttr.RoleAttrRemainPoint,GlobalProcessing.RemainPoint)
	CL.RegisterAttr(RoleAttr.RoleAttrRemainPoint,GlobalProcessing.RemainPoint)
	CL.UnRegisterMessage(GM.AddNewItem, "GlobalProcessing", "GetPetEquip")
	CL.UnRegisterMessage(GM.UpdateItem, "GlobalProcessing", "GetPetEquip")
	CL.UnRegisterMessage(GM.RemoveItem, "GlobalProcessing", "GetPetEquip")
	CL.RegisterMessage(GM.AddNewItem, "GlobalProcessing", "GetPetEquip")
	CL.RegisterMessage(GM.UpdateItem, "GlobalProcessing", "GetPetEquip")
	CL.RegisterMessage(GM.RemoveItem, "GlobalProcessing", "GetPetEquip")
	GlobalProcessing.RemainPoint(RoleAttr.RoleAttrRemainPoint,CL.GetAttr(RoleAttr.RoleAttrRemainPoint))
end

GlobalProcessing.EquipUseState = true
function GlobalProcessing.EquipAutoUseState(parameter)
	local parameter = tonumber(parameter) or 1
	GlobalProcessing.EquipUseState = (parameter==1)
	if GlobalProcessing.EquipUseState then
		if not QuickUseUI then
			require("QuickUseUI")
		end
		QuickUseUI.SetInfo()
	end
end


-- 羽翼小红点
function GlobalProcessing.wing_red_register()
	CL.UnRegisterMessage(GM.AddNewItem, "GlobalProcessing", "_when_wing_change")
	CL.UnRegisterMessage(GM.UpdateItem, "GlobalProcessing", "_when_wing_change")
	CL.UnRegisterMessage(GM.RemoveItem, "GlobalProcessing", "_when_wing_change")

	-- 如果羽翼已达到最大等级
	if GlobalProcessing.wing_is_max_level == true then return '' end

	CL.RegisterMessage(GM.AddNewItem, "GlobalProcessing", "_when_wing_change")
	CL.RegisterMessage(GM.UpdateItem, "GlobalProcessing", "_when_wing_change")
	CL.RegisterMessage(GM.RemoveItem, "GlobalProcessing", "_when_wing_change")
	GlobalProcessing.set_wing_red()
end

-- 羽翼物品变化时监听事件调用的方法
function GlobalProcessing._when_wing_change(item_guid, item_id)
	-- 判断等级是否足够
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
	local Key = tostring('羽翼')
	local Level = MainUI.MainUISwitchConfig["包裹"].Subtab_OpenLevel[Key]

	if CurLevel < Level then
		return ''
	else
		if not item_id or item_id == "" then
			-- 如果是侍从信物之类的物品,背包不同无法获取到，就直接退出
			local item_data = LD.GetItemDataByGuid(item_guid)
			if item_data and item_data.id then
				item_id = item_data.id
			else
				return ''
			end
		end
		item_id = tonumber(item_id)
		if item_id == nil then
			test("GlobalProcessing._when_wing_change item_id == nil ")
			return ''
		end

		local item = DB.GetOnceItemByKey1(item_id)
		if item.Type == 3 and (item.Subtype == 29 or item.Subtype == 30) then
			-- 发送请求，重新刷新小红点
			--FormClothes.GetNowStageItem(player)
			-- 更新羽翼小红点
			-- 返回值 羽翼升阶材料GlobalProcessing.wing_upgrade_material
			-- 回调方法 GlobalProcessing.set_wing_red()
			CL.SendNotify(NOTIFY.SubmitForm, 'FormClothes', 'GetNowStageItem')
		end

	end

end


-- 羽翼升阶物品
GlobalProcessing.wing_upgrade_material = {}
-- 羽翼是否是最大等级
GlobalProcessing.wing_is_max_level = nil
function GlobalProcessing.set_wing_red()

	-- 如果羽翼已达到最大等级
	if GlobalProcessing.wing_is_max_level == true then

		-- 取消羽翼监听
		CL.UnRegisterMessage(GM.AddNewItem, "GlobalProcessing", "_when_wing_change")
		CL.UnRegisterMessage(GM.UpdateItem, "GlobalProcessing", "_when_wing_change")
		CL.UnRegisterMessage(GM.RemoveItem, "GlobalProcessing", "_when_wing_change")

		GlobalProcessing.wing_upgrade_material = nil

		GlobalProcessing.RedPointController('bagBtn', 'wing_upgrade', 0)
		GlobalProcessing.RedPointController('bagBtn', 'wing_level_up', 0)

		-- 设置羽翼界面小红点
		local bag_wnd = GUI.GetWnd('BagUI')
		if GUI.GetVisible(bag_wnd) then
			BagUI.set_wing_tab_red()
			-- 判断是否是羽翼界面
			if BagUI.tabIndex == 4 then
				WingUI.set_red()
			end
		end

		return ''
	end

	-- 升阶
	local upgrade_red = true
	if next(GlobalProcessing.wing_upgrade_material) then
		for k, v in ipairs(GlobalProcessing.wing_upgrade_material) do
			if v ~= '' then
				local data = string.split(v, '_')
				local need_count = tonumber(data[2])
				local id = DB.GetOnceItemByKey2(data[1]).Id
				local count = LD.GetItemCountById(id)
				if count < need_count then
					upgrade_red = false
				end
			end
		end
	else
		upgrade_red = false
	end

	-- 升级
	local level_up_red = false
	if next(UIDefine.WingItem_Config) then
		for k, v in pairs(UIDefine.WingItem_Config) do
			local id = DB.GetOnceItemByKey2(k).Id
			local count = LD.GetItemCountById(id)
			if count > 0 then
				level_up_red = true
			end
		end
	end

	-- 设置主界面小红点
	-- 升阶和升级不能同时存在
	if next(GlobalProcessing.wing_upgrade_material) then
		GlobalProcessing.RedPointController('bagBtn', 'wing_level_up', 0)
		if upgrade_red then
			GlobalProcessing.RedPointController('bagBtn', 'wing_upgrade', 1)
		else
			GlobalProcessing.RedPointController('bagBtn', 'wing_upgrade', 0)
		end
	else
		-- 如果不是升阶，传入参数值3
		GlobalProcessing.RedPointController('bagBtn', 'wing_upgrade', 3)
		if level_up_red then
			GlobalProcessing.RedPointController('bagBtn', 'wing_level_up', 1)
		else
			GlobalProcessing.RedPointController('bagBtn', 'wing_level_up', 0)
		end
	end

	-- 设置羽翼界面小红点
	local bag_wnd = GUI.GetWnd('BagUI')
	if GUI.GetVisible(bag_wnd) then
		BagUI.set_wing_tab_red()
		-- 判断是否是羽翼界面
		if BagUI.tabIndex == 4 then
			WingUI.set_red()
		end
	end

end

--第一次进入游戏时，设置系统设置功能开启状态
function GlobalProcessing.SetSystemSettingState()
	--1为开启，0为关闭
	--省电模式
	LD.SetSystemSettingValue(SystemSettingOption.SavePowerMode, 0)
	--是否接受陌生人消息
	LD.SetSystemSettings(RoleAttr.RoleAttrCanMsg, 1)
	--是否接受被查看消息
	LD.SetSystemSettings(RoleAttr.RoleAttrCanQuery, 1)
	--是否接受切磋
	LD.SetSystemSettings(RoleAttr.RoleAttrCanDuel, 0)
	--是否自动跳过剧情对话
	LD.SetSystemSettingValue(SystemSettingOption.AutoClickSkipNpcDialog,0)
	--逃跑确认
	LD.SetSystemSettingValue(SystemSettingOption.MakeSureEscape, 0)
	--自动抓宠
	LD.SetSystemSettings(RoleAttr.RoleAttrCanAutoCatchBaby, 1)

	--组队和好友相反 0为开启，1为关闭
	--是否接受组队
	CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "SetAutoRefuseApply", 0)
	--是否接受被加好友
	CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "SetAutoRefuseApply", 0)
end

function GlobalProcessing.FactionRedPoint()
	if not FactionUI then require("FactionUI") end
	GlobalProcessing.on_draw_redpoint("factionBtn", true)
	FactionUI.SetContributeRedPoint()
end

--开服冲榜
function GlobalProcessing.ServerRushRankData(data)
	local tick = tonumber(tostring(CL.GetServerTickCount()))
	-- local inspect = require("inspect")
	-- CDebug.LogError(inspect(data["RankList"]))
	local list = data.RankList
	for i = 1, #list do
		local temp = list[i]
		-- 1开启 2 保留 3 未开启 4 结束
		if temp.Retain_Time < tick then
			temp.State = 4
		elseif temp.End_Time < tick then
			temp.State = 2
		elseif temp.Start_Time < tick then
			temp.State = 1
		else
			temp.State = 3
		end
	end
	table.sort(data.RankList,function(a, b)
		if a.State == b.State then
			return a.Start_Time < b.Start_Time
		end
		return a.State < b.State
	end)
	GlobalProcessing.RushRankData = data
end

--密藏小红点刷新
function GlobalProcessing.SeasonPassRedPointRefresh()
	if GlobalProcessing.SeasonPassRedPoint and next(GlobalProcessing.SeasonPassRedPoint) then
		local redpoint = 0
		if GlobalProcessing.SeasonPassRedPoint.RewardRemain and next(GlobalProcessing.SeasonPassRedPoint.RewardRemain) then
			redpoint = redpoint + 1
		end
		if GlobalProcessing.SeasonPassRedPoint.LevelMax == "false" and GlobalProcessing.SeasonPassRedPoint.QuestCanFinish and next(GlobalProcessing.SeasonPassRedPoint.QuestCanFinish) then
			redpoint = redpoint + 1
		end
		if redpoint > 0 then
			GlobalProcessing.RedPointController("SeasonPassUIBtn", "All", 1)
		else
			GlobalProcessing.RedPointController("SeasonPassUIBtn", "All", 0)
		end
	end
end

-- 福利界面-五星连珠 主界面小红点
GlobalProcessing.is_show_WelBingoUI_red = nil
function GlobalProcessing.BinGo_DataLoading()
	local is_show = (GlobalProcessing.is_show_WelBingoUI_red==true and 1 or 0)
	GlobalProcessing.RedPointController("WelfareBtn", "is_show_WelBingoUI", is_show)
	return is_show
end

--七日结束后变强七日相关红点重置
function GlobalProcessing.SevenDayBeStrongOver()
	if CL.GetIntCustomData("SevenDaySwitch") ~= 1 then
		GlobalProcessing.RedPointController("BeStrongBtn","SevenDay",0)
		BeStrongUI.BianQiang_Red_Point("SevenDay",0)
	end
end

-- 侍从宠物 显示上排除技能
function GlobalProcessing.filter_skill_of_guard_or_pet(skill_db)
	--接受参数为Id或db

	if skill_db == nil then
		test('GlobalProcessing.filter_skill_of_guard_or_pet(skill_db) 参数 skill_db == nil')
		return ''
	end

	if skill_db and skill_db.Id and skill_db.Id == 0 then
		skill_db = DB.GetOnceSkillByKey1(skill_db)
	end

	if skill_db.Id ~= 0 then
		if skill_db.SubType == 14 then
			return false
		else
			return true
		end
	else
		test('GlobalProcessing.filter_skill_of_guard_or_pet(skill_db) 参数 skill_db 错误')
		return ''
	end
end

GlobalProcessing.have_guard_soul_been_to_be_seen  = nil
-- 侍从命魂小红点
function GlobalProcessing.guard_soul_red_point()
	local is_show = (GlobalProcessing.have_guard_soul_been_to_be_seen == true and 1 or 0)
	GlobalProcessing.RedPointController("retinueBtn", "guard_soul_have_been_to_see", is_show)
	if GuardUI and GuardUI.guardScore_red_point then
		GuardUI.guardScore_red_point(is_show == 1 and true or false)
	end
	return is_show
end

function GlobalProcessing.guard_soul_register_event_for_red_point()
	-- 当增加命魂时显示小红点，打开后消失
	CL.UnRegisterMessage(GM.AddNewItem,'GlobalProcessing','guard_soul_red_event_f')

	CL.RegisterMessage(GM.AddNewItem,'GlobalProcessing','guard_soul_red_event_f')
end

function GlobalProcessing.guard_soul_red_event_f(item_guid,item_id)
	if not item_id or item_id == '' then
		-- 人物身上的侍从命魂背包
		local item_data = LD.GetItemDataByGuid(item_guid,item_container_type.item_container_guard_equip)
		if item_data and item_data.id then
			item_id = item_data.id
		else
			return ''
		end
	end
	item_id = tonumber(item_id)

	local is_show = nil
	if item_id then
		local item_db = DB.GetOnceItemByKey1(item_id)
		if item_db and item_db.Id ~= 0 and item_db.Type == 8 then
			is_show = true
		end
	end

	GlobalProcessing.have_guard_soul_been_to_be_seen  = is_show
	GlobalProcessing.guard_soul_red_point()
end


function GlobalProcessing.PetEduSkillUnShow(parameter)
	if parameter and GlobalProcessing.PetEduSkillUnShowList and #GlobalProcessing.PetEduSkillUnShowList > 0 then
		for k,v in pairs(GlobalProcessing.PetEduSkillUnShowList) do
			if v == parameter then
				return false
			end
		end
		return true
	else
		return true
	end
end

--填入想要屏蔽的技能书的keyname
GlobalProcessing.PetEduSkillUnShowList = {
	--"迟钝秘籍",
	-- "追击秘籍",
	-- "隐身秘籍"
}

-- 刷新并展示游戏帮助
function GlobalProcessing.ShowGameHelpTips()
	CL.RegisterAttr(RoleAttr.RoleAttrLevel,GlobalProcessing.RefreshGameHelpTipsList)
	GameHelpTipsUI.RefreshHelpTipsList()
	GameHelpTipsUI.ShowHelpTips()
end

-- 刷新游戏帮助列表
function GlobalProcessing.RefreshGameHelpTipsList(attrType, value)
	GameHelpTipsUI.RefreshHelpTipsList(attrType, value)
end

-- 关闭游戏帮助
function GlobalProcessing.ResetGameHelpTipsList()
	GameHelpTipsUI.UnShowHelpTips()
end


--刷新自动挂机施放技能的技能id
function GlobalProcessing.RefreshAutomaticCastingData()

	if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= nil then

		if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= 0 then

			------------------------------------------Start 玩家技能处理 Start---------------------------------------
			local temp = GlobalProcessing.AutomaticCastingData[GlobalProcessing.AutomaticCasting_CurSchemeIndex].order

			local sureSkillTable = {}
			local petSureSkillTable = {}

			for i = 1, #temp do

				local skillDB = DB.GetOnceSkillByKey1(temp[i].skill_id)
				sureSkillTable[skillDB.Name] = {
					status = temp[i].status,
					index = i
				}

			end

			local skillList = LD.GetSelfSkillList()

			if skillList then
				for i = 0, skillList.Count - 1 do
					local skillData = skillList[i]
					if skillData.enable == 1 then
						local skillId = skillData.id
						local skillDB = DB.GetOnceSkillByKey1(skillId)
						if skillDB.Type == 1 then --普通技能才显示
							local skillSubType = skillDB.SubType
							if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then

								if sureSkillTable[skillDB.Name] ~= nil then

									if sureSkillTable[skillDB.Name].status == 1 then

										GlobalProcessing.AutomaticCastingData[GlobalProcessing.AutomaticCasting_CurSchemeIndex].order[sureSkillTable[skillDB.Name].index].skill_id = skillId

									end

								end


							end
						end
					end
				end
			end

			local json=jsonUtil.encode(GlobalProcessing.AutomaticCastingData[GlobalProcessing.AutomaticCasting_CurSchemeIndex].order)


			CL.SendNotify(NOTIFY.SubmitForm, "FormAutomaticCasting", "SetRoleScheme", GlobalProcessing.AutomaticCasting_CurSchemeIndex, json)

			------------------------------------------End 玩家技能处理 End---------------------------------------


			------------------------------------------Start 宠物技能处理 Start---------------------------------------


			local petGuid = tostring(GlobalUtils.GetMainLineUpPetGuid())

			local petSkillList = GlobalProcessing.GetPetSkillByGuid(petGuid)

			local petSkillStr = LD.GetPetStrCustomAttr("AutomaticCasting_PetSkillOrder", petGuid)

			if #petSkillStr > 10 then

				local petSkillTableList = jsonUtil.decode(petSkillStr)

				local temp = petSkillTableList[GlobalProcessing.AutomaticCasting_CurSchemeIndex]

				for i = 1, #temp do

					local skillDB = DB.GetOnceSkillByKey1(temp[i].skill_id)
					petSureSkillTable[skillDB.Name] = {
						status = temp[i].status,
						index = i
					}

				end

				if petSkillList then
					for i = 1, #petSkillList do
						local skillData = petSkillList[i]
						if skillData.enable == 1 then
							local skillId = skillData.id
							local skillDB = DB.GetOnceSkillByKey1(skillId)
							if skillDB.Type == 1 then --普通技能才显示
								local skillSubType = skillDB.SubType
								if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then


									if petSureSkillTable[skillDB.Name] ~= nil then

										if petSureSkillTable[skillDB.Name].status == 1 then

											petSkillTableList[GlobalProcessing.AutomaticCasting_CurSchemeIndex][petSureSkillTable[skillDB.Name].index].skill_id = skillId

										end

									end


								end
							end
						end
					end


				end

				local json=jsonUtil.encode(petSkillTableList)

				CL.SendNotify(NOTIFY.SubmitForm, "FormAutomaticCasting", "SetPetScheme", petGuid, json)
			end

			------------------------------------------End 宠物技能处理 End---------------------------------------

		end

	end

end


--坐骑模型创建（需传入Model）,RoleModel,,Script,Method需传入注册监听事件（事件内容参考GlobalProcessing.ModelCreate()）
function GlobalProcessing.Mount_ModelCreate_WithModel(Model,RoleModel,Script,Method)
	if not Model then
		return
	end
	
	if RoleModel then
		if ULE.ModelCreate then
			GUI.RegisterUIEvent(RoleModel, ULE.ModelCreate, Script, Method)
		end
	end
	
	--给模型注册点击事件（///在原脚本传入模型点击内容）
	-- GUI.RegisterUIEvent(Model, UCE.PointerClick, "GlobalProcessing", "OnModelClick")
	
	local MountModel = GUI.RawImageChildCreate(Model, false, "MountModel", "", 0, 0)
	-- _gt.BindName(mountModel, "mountModel")
    GUI.BindPrefabWithChild(Model, GUI.GetGuid(MountModel))
    if ULE.ModelCreate then
	    GUI.RegisterUIEvent(MountModel, ULE.ModelCreate, Script, Method)
    end
	
	
	return MountModel


end

--在原脚本写或传入
function GlobalProcessing.Mount_ModelCreate(RoleModel,MountModel)
    -- local mountId = CL.GetIntAttr(RoleAttr.RoleAttrMountId)
	if RoleModel and MountModel then
		if UIDefine.IsFunctionOrVariableExist(GUI, "Mount") then
			GUI.Mount(RoleModel, MountModel)
		end
	end
end

function GlobalProcessing.Mount_OnModelClick(RoleModel,MountModel)
	if RoleModel then
		local ModelID = tonumber(GUI.GetData(RoleModel,"ModelID"))
		local RoleMovement = eRoleMovement.HORSEWALK1
		if ModelID then
			local MountType = 0
			local hookadapter = SETTING.GetBonehookadapter(ModelID)
			if UIDefine.IsFunctionOrVariableExist(hookadapter, "MountType") then
			  MountType  = hookadapter.MountType or 0 
			end			
			if MountType == 1 then
				RoleMovement = eRoleMovement.ATTSTAND_W1
			end
		end
		ModelItem.BindSelfRole(RoleModel,RoleMovement)
	end
	if MountModel then
		GUI.ReplaceWeapon(MountModel, 0, eRoleMovement.WALK_W1, 0)
	end	
end

--坐骑相关模型刷新
function GlobalProcessing.Mount_RefreshModel(RoleModel,MountModel,MountId)
	if RoleModel and MountModel then
		local mountId = MountId or CL.GetIntAttr(RoleAttr.RoleAttrMountId)
		local RoleMovement = eRoleMovement.HORSESTAND
		local MountType = 0
		local hookadapter = SETTING.GetBonehookadapter(mountId)
		if UIDefine.IsFunctionOrVariableExist(hookadapter , "MountType") then
			MountType  = hookadapter.MountType or 0 
		end	
		if MountType == 1 then
			RoleMovement = eRoleMovement.STAND_W1
		end		
		ModelItem.BindSelfRole(RoleModel,RoleMovement)
		GUI.SetData(RoleModel,"ModelID",mountId)
		if UIDefine.IsFunctionOrVariableExist(GUI, "DisMount")  and UIDefine.IsFunctionOrVariableExist(GUI, "Mount") then
			GUI.DisMount(RoleModel)
			GUI.RawImageChildSetModelID(MountModel, mountId)
			GUI.Mount(RoleModel, MountModel)
		end
		GUI.ReplaceWeapon(MountModel, 0, eRoleMovement.STAND_W1, 0)
	end
end

function GlobalProcessing.JumpToCrossServerWarfareServer(ewsedada)

	if UIDefine.IsFunctionOrVariableExist(CL, "UpdateOem") and UIDefine.IsFunctionOrVariableExist(CL, "JumpServer") and UIDefine.IsFunctionOrVariableExist(CL, "GetServerListDatasIncludeTest") then
		CDebug.LogError("GM.UpdateOem  "..tostring(GM.UpdateOem))
		CL.RegisterMessage(GM.UpdateOem, "GlobalProcessing", "OnUpdateOem")
		local res = CL.UpdateOem()
		if not res then
			CL.SendNotify(NOTIFY.ShowBBMsg, "正在处理中,请勿连续操作");
		end
		CDebug.LogError("CL.UpdateOem() res "..tostring(res))
	else
		CDebug.LogError("IsFunctionOrVariableExist false ")
	end

end

function GlobalProcessing.OnUpdateOem()

	CL.UnRegisterMessage(GM.UpdateOem, "GlobalProcessing", "OnUpdateOem")
	local _GroupLst = CL.GetServerListAllKeys()
	local _GroupCount = _GroupLst.Count
	local _GroupLst2 = {}
	for i = 0, _GroupCount - 1 do
		local groupID = tonumber(tostring(_GroupLst[i]))
		local serverDatas = CL.GetServerListDatasIncludeTest(groupID)
		local _ServerCount = serverDatas.Count
		for j = 0,_ServerCount - 1 do
			local sevname = serverDatas[j].ServerName
			local areaID = tonumber(serverDatas[j].AreaID)

			if GlobalProcessing.Act_CrossServer_AreaID  ~= nil then
				if areaID == tonumber(GlobalProcessing.Act_CrossServer_AreaID ) then
					CL.JumpServer(groupID, areaID, j, "")
					return
				end
			end

		end
	end
end

function GlobalProcessing.JumpTabIndexMountUI(item_id)
	if not item_id then
		return
	end
	GlobalProcessing.MountTabIndex = nil
	local itemDB = DB.GetOnceItemByKey1(item_id)
	if itemDB.Type == 2 and itemDB.Subtype == 48 and itemDB.Subtype2 == 1 then --驯养道具
		GlobalProcessing.MountTabIndex = 3
	elseif itemDB.Type == 2 and itemDB.Subtype == 48 and itemDB.Subtype2 == 2 then --升阶
		GlobalProcessing.MountTabIndex = 1
	elseif itemDB.Type == 2 and itemDB.Subtype == 48 and itemDB.Subtype2 == 3 then  --好感度
		GlobalProcessing.MountTabIndex = 1
	elseif itemDB.Type == 2 and itemDB.Subtype == 48 and itemDB.Subtype2 == 5 then	--统御
		GlobalProcessing.MountTabIndex = 2
	end
end

function GlobalProcessing.StallSendReport(report)
	if not GlobalProcessing.StallReport then
		GlobalProcessing.StallReport = {}
	end
	
	local PlayeGuid = tostring(LD.GetSelfGUID())
	
	if not GlobalProcessing.StallReport[tostring(LD.GetSelfGUID())] then
		GlobalProcessing.StallReport[PlayeGuid] = {}
	end
	
	table.insert(GlobalProcessing.StallReport[PlayeGuid],report)

end

--登陆时打开离线摆摊交易记录
function GlobalProcessing.StallOfflineReportOnLogin(report)
	local parent = GUI.GetWnd("MainUI")
	local panel = UILayout.CreateFrame_WndStyle2_WithoutCover(parent, "交易记录", 640, 460, "GlobalProcessing", "OnOfflineReportClose")
	GlobalProcessing.OfflineReportPanel = panel
	-- _gt.BindName(panel,"OfflineReportPanel")
	local Bg = GUI.ImageCreate(panel, "Bg", "1800400200", 0, 15, false, 600, 375)
	UILayout.SetSameAnchorAndPivot(Bg, UILayout.Center)	

    local reportScrollWnd = GUI.ScrollRectCreate(Bg,"reportScrollWnd", 0, 0, 580, 360, 0, false, Vector2.New(580, 60),  UIAroundPivot.Top, UIAnchor.Top, 1)
    GUI.SetAnchor(reportScrollWnd, UIAnchor.Center)
    GUI.SetPivot(reportScrollWnd, UIAroundPivot.Center)
	
	local report_tb = string.split(report,"$")
	for i = 1 ,#report_tb do
		local Text = GUI.CreateStatic(reportScrollWnd, "reportText"..i, report_tb[i], 10, -1, 580, 60,"system",true)
		GUI.SetColor(Text, UIDefine.BrownColor)
		GUI.StaticSetFontSize(Text, UIDefine.FontSizeL)
		UILayout.SetSameAnchorAndPivot(Text, UILayout.Center)
		GUI.StaticSetAlignment(Text, TextAnchor.MiddleLeft)	
	end
end

function GlobalProcessing.OnOfflineReportClose()
	if GlobalProcessing.OfflineReportPanel then
		GUI.Destroy(GlobalProcessing.OfflineReportPanel)
	end
end

--客户端更新
function GlobalProcessing.ClientUpdateNotice(AkgUrl, ForceUpdate)
	if not ClientUpdateNotice then
		require("ClientUpdateNotice")
	end
	GUI.OpenWnd("ClientUpdateNotice", jsonUtil.encode({["AkgUrl"] = AkgUrl, ["ForceUpdate"] = ForceUpdate}))
end