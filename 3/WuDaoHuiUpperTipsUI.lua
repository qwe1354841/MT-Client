local WuDaoHuiUpperTipsUI = {
}

-- WuDaoHuiUpperTipsUI.BlueTeamNum = 1
-- WuDaoHuiUpperTipsUI.BlueTeamSurNum = 1
-- WuDaoHuiUpperTipsUI.RedTeamNum = 1
-- WuDaoHuiUpperTipsUI.RedTeamSurNum = 1
WuDaoHuiUpperTipsUI.ActTimer = nil

_G.WuDaoHuiUpperTipsUI = WuDaoHuiUpperTipsUI
local _gt = UILayout.NewGUIDUtilTable()

local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)

function WuDaoHuiUpperTipsUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("WuDaoHuiUpperTipsUI", "WuDaoHuiUpperTipsUI", 0, 0);
	GUI.SetVisible(panel, false)
	
	local panelBg = GUI.GroupCreate(panel, "panelBg", 0, 0, 1280, 660)
    UILayout.SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(panelBg,"Panel_WuDaoHui")
	
	local TeamBg1 = GUI.ImageCreate(panelBg, "TeamBg1", "1800608060", -60, -310, true)
    UILayout.SetAnchorAndPivot(TeamBg1, UIAnchor.Center, UIAroundPivot.Center)	
	
	local TeamName1 = GUI.CreateStatic(TeamBg1, "TeamName1", "朱雀", -10, 0, 150, 30, "system")
	UILayout.SetAnchorAndPivot(TeamName1, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(TeamName1,colorWhite)
	GUI.StaticSetFontSize(TeamName1, 16)
	GUI.StaticSetAlignment(TeamName1, TextAnchor.MiddleCenter)
		
	local TeamBg2 = GUI.ImageCreate(panelBg, "TeamBg2", "1800608070", 60, -310, true)
    UILayout.SetAnchorAndPivot(TeamBg2, UIAnchor.Center, UIAroundPivot.Center)	
	
	local TeamName2 = GUI.CreateStatic(TeamBg2, "TeamName2", "青龙", 10, 0, 150, 30, "system")
	UILayout.SetAnchorAndPivot(TeamName2, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(TeamName2,colorWhite)
	GUI.StaticSetFontSize(TeamName2, 16)
	GUI.StaticSetAlignment(TeamName2, TextAnchor.MiddleCenter)
	
	local TempSliderBg = GUI.ImageCreate(panelBg, "TempSliderBg", "1800608010", 0, -275, true)
    UILayout.SetAnchorAndPivot(TempSliderBg, UIAnchor.Center, UIAroundPivot.Center)		
	
	local SilderFillSize = Vector2.New(290, 20)
	local ZhuQueSlider = GUI.ScrollBarCreate(TempSliderBg, "ZhuQueSlider","","1800608020","", -168, -10, 0, 0,  1, false, Transition.None, 0, 1, Direction.RightToLeft, false)
	UILayout.SetAnchorAndPivot(ZhuQueSlider, UIAnchor.Center, UIAroundPivot.Center)	
    GUI.ScrollBarSetFillSize(ZhuQueSlider, SilderFillSize)
    GUI.ScrollBarSetBgSize(ZhuQueSlider,SilderFillSize)
	_gt.BindName(ZhuQueSlider,"ZhuQueSlider")
	GUI.ScrollBarSetPos(ZhuQueSlider,1/1)
	
	local QingLongSlider = GUI.ScrollBarCreate(TempSliderBg, "QingLongSlider","","1800608020","", 168, -10, 0, 0,  1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
	UILayout.SetAnchorAndPivot(QingLongSlider, UIAnchor.Center, UIAroundPivot.Center)	
    GUI.ScrollBarSetFillSize(QingLongSlider, SilderFillSize)
    GUI.ScrollBarSetBgSize(QingLongSlider,SilderFillSize)
	_gt.BindName(QingLongSlider,"QingLongSlider")
	GUI.ScrollBarSetPos(QingLongSlider,1/1)
	
	local CountDownBg = GUI.ImageCreate(panelBg, "CountDownBg", "1800608050", 0, -300, true)
    UILayout.SetAnchorAndPivot(CountDownBg, UIAnchor.Center, UIAroundPivot.Center)	
	
	local CountDown = GUI.CreateStatic(CountDownBg, "CountDown", "59:15", 0, 0, 150, 30, "system")
	UILayout.SetAnchorAndPivot(CountDown, UIAnchor.Center, UIAroundPivot.Center)
	GUI.SetColor(CountDown,colorWhite)
	GUI.StaticSetFontSize(CountDown, 20)
	GUI.StaticSetAlignment(CountDown, TextAnchor.MiddleCenter) 
	_gt.BindName(CountDown,"CountDown")

	local BroadCast_WuDao = GUI.ImageCreate(panelBg, "BroadCast_WuDao", "1800604330", 0, -240, true)  --1800604340  1800604350
    UILayout.SetAnchorAndPivot(BroadCast_WuDao, UIAnchor.Center, UIAroundPivot.Center)	
	_gt.BindName(BroadCast_WuDao,"BroadCast_WuDao")
	
	local CountDownNum1 = GUI.ImageCreate(panelBg, "CountDownNum1", "1900505000", -30, -180, true)   --倒计时十位
	UILayout.SetAnchorAndPivot(CountDownNum1, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(CountDownNum1,"CountDownNum1")
	GUI.SetVisible(CountDownNum1,false)



	local CountDownNum2 = GUI.ImageCreate(panelBg, "CountDownNum2", "1900505000", 30, -180, true)   --倒计时个位
	UILayout.SetAnchorAndPivot(CountDownNum2, UIAnchor.Center, UIAroundPivot.Center)
	_gt.BindName(CountDownNum2,"CountDownNum2")
	GUI.SetVisible(CountDownNum2,false)
	
end

function WuDaoHuiUpperTipsUI.OnShow(parameter)
	local wnd = GUI.GetWnd("WuDaoHuiUpperTipsUI")
	
	WuDaoHuiUpperTipsUI.Register()
	WuDaoHuiUpperTipsUI.UIManager(true)
	
	if wnd then
		GUI.SetVisible(wnd, true)
	end
end

function WuDaoHuiUpperTipsUI.Register()
	-- CL.RegisterMessage(GM.FightStateNtf, "WuDaoHuiUpperTipsUI", "OnFightStateNtf")
	CL.RegisterMessage(GM.UnloadPreMap, "WuDaoHuiUpperTipsUI", "UnloadPreMap")
end

--打开后关闭左侧的显示
function WuDaoHuiUpperTipsUI.UIManager(state)
    local leftBg = GUI.Get("MainUI/leftBg")
    local leftBtn = GUI.Get("MainUI/leftBtn")
    if leftBg then
        GUI.SetVisible(leftBg, not state)
    end
    if leftBtn then
        GUI.SetVisible(leftBtn, not state)
        -- GUI.SetVisible(leftBtn, false)
    end
end

--当离开当前地图
function WuDaoHuiUpperTipsUI.UnloadPreMap()
	WuDaoHuiUpperTipsUI.UIManager(false)
	TrackUI.SwitchQuestOrFightInfo3Node(true)
	WuDaoHuiUpperTipsUI.OnCloseBtnClick()
end

--当战斗状态改变
-- function WuDaoHuiUpperTipsUI.OnFightStateNtf()
	-- print("战斗状态改变 战斗状态改变战斗状态改变战斗状态改变战斗状态改变战斗状态改变战斗状态改变")
	-- local Panel = _gt.GetUI("Panel_WuDaoHui")
	-- local infight = GUI.GetVisible(Panel)
	-- if infight then
		-- GUI.CloseWnd("TrackUI")
	-- else
		-- GUI.OpenWnd("TrackUI")
	-- end
	-- MainUI.UIManager(not infight)
	-- GUI.SetVisible(Panel,not infight)

-- end

function  WuDaoHuiUpperTipsUI.OnCloseBtnClick()
	GUI.Destroy("WuDaoHuiUpperTipsUI")
end

function WuDaoHuiUpperTipsUI.Refresh()
	local ZhuQueSlider = _gt.GetUI("ZhuQueSlider")
	local QingLongSlider = _gt.GetUI("QingLongSlider")
	local BroadCast_WuDao = _gt.GetUI("BroadCast_WuDao")
	WuDaoHuiUpperTipsUI.ActTimer = Timer.New(WuDaoHuiUpperTipsUI.OnActTime_WuDaoHui,1,-1)
	WuDaoHuiUpperTipsUI.ActTimer:Start()
	if WuDaoHuiUpperTipsUI.State == 1 then  --准备中
	GUI.ScrollBarSetPos(ZhuQueSlider,1)
	GUI.ScrollBarSetPos(QingLongSlider,1)
	GUI.SetVisible(BroadCast_WuDao,true)
	GUI.ImageSetImageID(BroadCast_WuDao,"1800604330")
	elseif WuDaoHuiUpperTipsUI.State == 2 then  --战斗中
	GUI.ScrollBarSetPos(ZhuQueSlider,WuDaoHuiUpperTipsUI.RedTeamSurNum/WuDaoHuiUpperTipsUI.RedTeamNum)
	GUI.ScrollBarSetPos(QingLongSlider,WuDaoHuiUpperTipsUI.BlueTeamSurNum/WuDaoHuiUpperTipsUI.BlueTeamNum)
	GUI.SetVisible(BroadCast_WuDao,false)
	elseif WuDaoHuiUpperTipsUI.State == 3 then  --结束中
	GUI.ScrollBarSetPos(ZhuQueSlider,WuDaoHuiUpperTipsUI.RedTeamSurNum/WuDaoHuiUpperTipsUI.RedTeamNum)
	GUI.ScrollBarSetPos(QingLongSlider,WuDaoHuiUpperTipsUI.BlueTeamSurNum/WuDaoHuiUpperTipsUI.BlueTeamNum)
	GUI.SetVisible(BroadCast_WuDao,true)	
	GUI.ImageSetImageID(BroadCast_WuDao,"1800604340")	
	elseif WuDaoHuiUpperTipsUI.State == 0 then
	WuDaoHuiUpperTipsUI.ActTimer:Reset(WuDaoHuiUpperTipsUI.OnActTime_WuDaoHui,1,-1)
	WuDaoHuiUpperTipsUI.ActTimer:Stop()
	end
end
local CountDown_WuDaoHui = {[0]="1900505000",[1]="1900505001",[2]="1900505002",[3]="1900505003",[4]="1900505004",[5]="1900505005",[6]="1900505006",[7]="1900505007",[8]="1900505008",[9]="1900505009"}
function WuDaoHuiUpperTipsUI.OnActTime_WuDaoHui()
	local CountDown = _gt.GetUI("CountDown")
	local CountDownNum1 = _gt.GetUI("CountDownNum1")
	local CountDownNum2 = _gt.GetUI("CountDownNum2")

	local day,house,minute,second = GlobalUtils.Get_DHMS2_BySeconds(tonumber(WuDaoHuiUpperTipsUI.Timer) - CL.GetServerTickCount())
	local Time = minute..":"..second
	GUI.StaticSetText(CountDown,Time)
	local num = tonumber(second)
	
	if WuDaoHuiUpperTipsUI.State == 1 or WuDaoHuiUpperTipsUI.State == 3  then
		if minute =="00" then
			local num1 = 0
			local num2 = 0
			num1,num2 = math.modf(num/10)
			if num2 ~=0 then
				parameter = tostring(num2)
				parameter = string.split(parameter, ".")
				num2 = tonumber(parameter[2])
			end
			GUI.SetVisible(CountDownNum1,true)
			GUI.SetVisible(CountDownNum2,true)
			GUI.ImageSetImageID(CountDownNum1,CountDown_WuDaoHui[num1])
			GUI.ImageSetImageID(CountDownNum2,CountDown_WuDaoHui[num2])
			if num1 == 0 and num2 == 0 and WuDaoHuiUpperTipsUI.ActTimer then
				WuDaoHuiUpperTipsUI.ActTimer:Reset(WuDaoHuiUpperTipsUI.OnActTime_WuDaoHui,1,-1)
				WuDaoHuiUpperTipsUI.ActTimer:Stop()
				GUI.SetVisible(CountDownNum1,false)
				GUI.SetVisible(CountDownNum2,false)
			end
		else
				GUI.SetVisible(CountDownNum1,false)
				GUI.SetVisible(CountDownNum2,false)	
		end
	else
			GUI.SetVisible(CountDownNum1,false)
			GUI.SetVisible(CountDownNum2,false)	
	end
end