local SystemSettingUI = {}
_G.SystemSettingUI = SystemSettingUI

local _gt = nil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local tostring = tostring
------------------------------------ end缓存一下全局变量end --------------------------------
local TextColor = UIDefine.Brown4Color
local colorDark = UIDefine.BrownColor

local leftToggleList = {
    {"基础设置", "BasicSettingBtn", "OnClickBasicSetting"},
	{"游戏设置", "GameSettingBtn", "OnClickGameSetting"},
	{"聊天设置", "ChatSettingBtn", "OnClickChatSetting"},
}

local SoundSettingList =
{
    {"战斗音乐", "FightBgm", "OnClickFightBgm", "OnFightBgmValueChange", SystemSettingOption.FightBgm, SystemSettingOption.FightBgmVolume},
    {"背景音乐", "SceneBgm", "OnClickSceneBgm", "OnSceneBgmValueChange", SystemSettingOption.SceneBgm, SystemSettingOption.SceneBgmVolume},
    {"音效", "SoundEffect", "OnClickSoundEffect", "OnSoundEffectValueChange", SystemSettingOption.SoundEffect, SystemSettingOption.SoundEffectVolume},
    {"语音", "Voice", "OnClickVoice", "OnVoiceValueChange", SystemSettingOption.ChatVoice, SystemSettingOption.ChatVoiceVolume},
}
local FrameSettingList = 
{


}

local ScreenPlayerCountFunction = {
	--滚动比例  对应人数
	{position = 0, count = 0},
	{position = 30, count = 10},
	{position = 50, count = 50},
	{position = 80, count = 110},
	{position = 100, count = 300},
}

--屏幕初始人数限制
local InitScreenNum = 50


local GameSettingList =
{	
    {"接受组队", "acceptTeamUp", "OnClickAcceptTeamUp",-264.7,-149.5},
    {"接受切磋", "acceptPK", "OnClickAcceptPK",-264.7, -89},
	{"自动抓宠", "autoCatchPet", "OnClickAutoCatchPet",-264.7,-30.5},
    {"逃跑确认", "Escape", "OnClickEscape",-264.7,30.6},
    {"省电模式（不操作3分钟后会进入省电模式）", "PowerSave", "OnClickPowerSave",-264.7,90},
    {"接受被查看消息", "BeViewInfo", "OnClickBeViewInfo",114.7,-149.5},
    {"接受被加为好友", "acceptMakeFriend", "OnClickAcceptMakeFriend",114.7, -89},
    {"接受陌生人消息", "acceptNews", "OnClickAcceptNews",114.7,-30.5},
    {"自动跳过剧情对话", "autoSkipCheck", "OnClickAutoSkipMovie",114.7,30.6},
	-- {"屏蔽宠物", "OtherPetCanSee", "OnClickOtherPetCanSee",-264.7,80},
	-- {"屏蔽侍从", "OtherGuardCanSee", "OnClickOtherGuardCanSee",114.7,80},
}

local ChatSettingList =
{
	{"当前频道", "CurChannel", "OnClickCurChannel",-338,-100.6,"ChatChannelCurrent"},
    {"帮派频道", "FactionChannel", "OnClickFactionChannel",-338,  -40.7,"ChatChannelGuild"},
    {"世界频道", "WorldChannel", "OnClickWorldChannel",-338,18,"ChatChannelWorld"},
    {"队伍频道", "TeamChannel", "OnClickTeamChannel",-138.4,-100.6,"ChatChannelTeam"},
    {"门派频道", "SchoolChannel", "OnClickSchoolChannel",-138.4, -40.7,"ChatChannelSchool"},
    {"喇叭频道", "HornChannel", "OnClickHornChannel",-138.4 , 18,"ChatChannelSpeaker"},
	{"当前频道", "ShieldCurChannel", "OnClickShieldCurChannel",48.6,-100.6,"ShieldChannelCurrent"},
    {"帮派频道", "ShieldFactionChannel", "OnClickShieldFactionChannel",48.6,-40.7,"ShieldChannelGuild"},
    {"世界频道", "ShieldWorldChannel", "OnClickShieldWorldChannel",48.6,18,"ShieldChannelWorld"},
    {"队伍频道", "ShieldTeamChannel", "OnClickShieldTeamChannel",248.27, -100.6,"ShieldChannelTeam"},
    {"门派频道", "ShieldSchoolChannel", "OnClickShieldSchoolChannel",248.2,-40.7,"ShieldChannelSchool"},
    {"喇叭频道", "ShieldHornChannel", "OnClickShieldHornChannel",248.2, 18,"ShieldChannelSpeaker"},
	-- {"招募频道仅显示与自己等级相符的信息", "Recruit", "OnClickRecruit",48.6,78.1,"ChatChannelCurrent"},--未对接
}

local attributeEventList = {
    [RoleAttr.RoleAttrCanDuel] = "RefreshSelfIsAcceptBattle",
	[RoleAttr.RoleAttrCanQuery] = "RefreshBeViewInfo",
	[RoleAttr.RoleAttrCanMsg] = "RefreshAcceptNews",
	[RoleAttr.RoleAttrCanAutoCatchBaby] = "RefreshAutoCatchPet"
}

local messageEventList = {
    {GM.CustomDataUpdate, "OnCustomDataUpdate"},
    {GM.FightStateNtf, "OnEnterFight"},
}

function SystemSettingUI.Main(parameter)
    test("SystemSettingUI Main")
    _gt = UILayout.NewGUIDUtilTable()
    SystemSettingUI.OnEnterUI()
    SystemSettingUI.RegisterAttributeEvent()
    SystemSettingUI.RegisterMessageEvent()
end

function SystemSettingUI.RegisterMessageEvent()
    for i = 1, #messageEventList do
        CL.UnRegisterMessage(messageEventList[i][1], "SystemSettingUI", messageEventList[i][2])
        CL.RegisterMessage(messageEventList[i][1], "SystemSettingUI", messageEventList[i][2])
    end
end

function SystemSettingUI.OnCustomDataUpdate(type, key, val)
    if key == "TEAM_AutoRefuseApply" then
        SystemSettingUI.RefreshAcceptTeamUp(val)
    elseif key == "CONTACT_AutoRefuseApply" then
        SystemSettingUI.RefreshAcceptMakeFriend(val)
    -- elseif key == "PET_OtherPetCanSee" then
        -- SystemSettingUI.RefreshPetAndGuardCanSee(val)		
    end
end

function SystemSettingUI.OnEnterFight( isInfight )
    if isInfight then
        GUI.CloseWnd("SystemSettingUI")
    end
end

--进入界面
function SystemSettingUI.OnEnterUI()
    --创建窗口节点
    local Panel = GUI.WndCreateWnd("SystemSettingUI", "SystemSettingUI", 0, 0)
    SetAnchorAndPivot(Panel, UIAnchor.Center, UIAroundPivot.Center)
	
    local panelBg = UILayout.CreateFrame_WndStyle0(Panel, "系统设置","SystemSettingUI","OnLeaveUI");

    --设置类型选项背景
    local SettingSelectBg = GUI.ImageCreate(panelBg, "SettingSelectBg", "1800400010", -400, -48, false, 243, 433)
    local group = GUI.GroupCreate(SettingSelectBg, "SystemToggleGroup", 0, 0, GUI.GetWidth(SettingSelectBg), GUI.GetHeight(SettingSelectBg))
    GUI.SetIsToggleGroup(group, true)
    for i = 1, #leftToggleList do
        local data = leftToggleList[i]
        local subTab = GUI.CheckBoxCreate(group, data[2], "1800002030","1800002031", 0, 72 * i - 250, Transition.ColorTint, false, 225, 65)
        GUI.SetToggleGroupGuid(subTab, GUI.GetGuid(group))
		_gt.BindName(subTab,data[2])
        local text = GUI.CreateStatic( subTab, "Text", data[1], 0, 0, 225, 65)
        GUI.StaticSetFontSize(text, UIDefine.FontSizeM)
        GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
        GUI.SetColor(text, colorDark)
		GUI.SetIsOutLine(text, false)
		GUI.SetOutLine_Color(text, Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
		GUI.SetOutLine_Distance(text, 1)
        GUI.RegisterUIEvent(subTab, UCE.PointerClick, "SystemSettingUI", data[3])
        if i == 1 then
            GUI.CheckBoxSetCheck(subTab, true)
			GUI.SetIsOutLine(text, true)
			GUI.SetColor(text, UIDefine.WhiteColor)
        end
    end

    --基础设置背景
    local BasicSettingBg = GUI.ImageCreate(panelBg,"BasicSettingBg", "1800400010", 127.4, -48, false, 789, 433)
    _gt.BindName(BasicSettingBg, "BasicSettingBg")

    --声音设置标题
    local VoiceSettingTitle = GUI.CreateStatic( BasicSettingBg, "VoiceSettingTitle", "声音设置", -192.3, -172.1, 150, 50)
    GUI.StaticSetFontSize(VoiceSettingTitle, 24)
    GUI.SetColor(VoiceSettingTitle, TextColor)
	GUI.StaticSetAlignment(VoiceSettingTitle, TextAnchor.MiddleCenter)

    SystemSettingUI.CreateSoundSettingList(BasicSettingBg)
    --分割线
    local Line = GUI.ImageCreate( BasicSettingBg, "Line", "1800208050", 6, 0, false, 2, 422)
	--2021.9.14 功能未对接，暂时隐藏
	
    -- 画面设置标题
	local FrameSettingTitle = GUI.CreateStatic(BasicSettingBg,"FrameSettingTitle", "画面设置", 198.3, -172.1,150,50)
    GUI.StaticSetFontSize(FrameSettingTitle,24)
    GUI.SetColor(FrameSettingTitle, TextColor)
	GUI.StaticSetAlignment(FrameSettingTitle, TextAnchor.MiddleCenter)
	
		SystemSettingUI.CreateFrameSetting(BasicSettingBg)
	-------------------------------------------

	
    -- local FunctionSettingTitle = GUI.CreateStatic( BasicSettingBg, "FunctionSettingTitle", "功能设置", 198, -172, 150, 50)
    -- GUI.StaticSetFontSize(FunctionSettingTitle, UIDefine.FontSizeL)
    -- GUI.SetColor(FunctionSettingTitle, TextColor)

    -- SystemSettingUI.CreateSettingList(BasicSettingBg)

    -- 人物头像背景
    local HeadBg = GUI.ImageCreate(panelBg,"HeadBg", "1800400050",-470, 232,false,100, 100)

    -- 人物头像
    local headRes = tostring(CL.GetRoleHeadIcon())
    local headIcon = HeadIcon.Create(HeadBg, "HeadIcon", headRes,  0, -1, 82, 82)
    SetAnchorAndPivot(headIcon, UIAnchor.Center, UIAroundPivot.Center)
    HeadIcon.BindRoleGuid(headIcon)

    --账号
    local Account = GUI.CreateStatic(panelBg,"Account", "账号：", 233, 210,  75, 50)
    GUI.StaticSetFontSize(Account, 22)
    GUI.SetColor(Account, UIDefine.BrownColor)
    GUI.SetAnchor(Account, UIAnchor.Left)
    --GUI.SetPivot(Account, UIAroundPivot.Left)

    --玩家名称
    local role_Name = CL.GetRoleName()
    local PlayerName = GUI.CreateStatic(panelBg,"PlayerName",role_Name, 258, 210,150, 26)
    _gt.BindName(PlayerName, "PlayerName")
    GUI.StaticSetFontSize(PlayerName,22)
    GUI.SetColor(PlayerName, UIDefine.Yellow2Color)
    GUI.StaticSetFontSizeBestFit(PlayerName)

    SetAnchorAndPivot(PlayerName, UIAnchor.Left, UIAroundPivot.Left)
    GUI.StaticSetAlignment(PlayerName, TextAnchor.MiddleLeft)

    --服务器
    local Server = GUI.CreateStatic(panelBg, "Server", "服务器：", -142, 210, 90, 50)
    GUI.StaticSetFontSize(Server, 22)
    GUI.SetColor(Server, UIDefine.BrownColor)

    --服务器名称
    local ServerName = GUI.CreateStatic(panelBg,"ServerName", SystemSettingUI.GetServerName(), 499, 210,  350, 50)
    GUI.StaticSetFontSize(ServerName, 22)
    GUI.SetColor(ServerName, UIDefine.Yellow2Color)
    SetAnchorAndPivot(ServerName, UIAnchor.Left, UIAroundPivot.Left)
    GUI.StaticSetAlignment(ServerName, TextAnchor.MiddleLeft)

    --切换角色
    local ChangeRoleBtn =  GUI.ButtonCreate(panelBg,"ChangeRoleBtn", "1800402110",-343, 257,Transition.ColorTint,"切换角色",122, 46 ,false)
    GUI.ButtonSetTextFontSize(ChangeRoleBtn, 24)
    GUI.ButtonSetTextColor(ChangeRoleBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(ChangeRoleBtn, UCE.PointerClick, "SystemSettingUI", "OnClickChangeRoleBtn")

    --切换账号
    local ChangeAccountBtn = GUI.ButtonCreate(panelBg,"ChangeAccountBtn", "1800402110", -197, 257,  Transition.ColorTint, "切换服务器", 145, 46,false)
    GUI.ButtonSetTextFontSize(ChangeAccountBtn, 24)
    GUI.ButtonSetTextColor(ChangeAccountBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(ChangeAccountBtn, UCE.PointerClick, "SystemSettingUI", "OnClickChangeAccountBtn")

    --退出
    local QuitLoginBtn = GUI.ButtonCreate(panelBg, "QuitLoginBtn", "1800402110", 22, 257, Transition.ColorTint, "退出游戏", 122, 46,false)
    GUI.ButtonSetTextFontSize(QuitLoginBtn, 24)
    GUI.ButtonSetTextColor(QuitLoginBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(QuitLoginBtn, UCE.PointerClick, "SystemSettingUI", "OnClickQuitLoginBtn")
	
	--客服反馈
    local feedbackBtn = GUI.ButtonCreate(panelBg,"FeedbackBtn", "1801402100", 343, 220,  Transition.ColorTint, "")
    local feedbackLabel = GUI.CreateStatic(feedbackBtn,"FeedbackLabel", "联系客服", 0.79, 51.5, 120, 50)
    GUI.StaticSetFontSize(feedbackLabel, 22)
    GUI.SetColor(feedbackLabel, TextColor)
	GUI.StaticSetAlignment(feedbackLabel, TextAnchor.MiddleCenter)
    GUI.RegisterUIEvent(feedbackBtn, UCE.PointerClick, "SystemSettingUI", "OnClickFeedbackBtn")	
	
	--锁定屏幕139.6,219.6
    local LockScreenBtn = GUI.ButtonCreate(panelBg,"LockScreenBtn", "1800202300", 447, 220, Transition.ColorTint, "")
    local LockScreenLabel = GUI.CreateStatic(LockScreenBtn,"LockScreenLabel", "锁定屏幕", 2.1, 51.9, 120, 50)
    GUI.StaticSetFontSize(LockScreenLabel, 22)
    GUI.SetColor(LockScreenLabel, TextColor)
	GUI.StaticSetAlignment(LockScreenLabel, TextAnchor.MiddleCenter)
    GUI.RegisterUIEvent(LockScreenBtn, UCE.PointerClick, "SystemSettingUI", "OnClickLockScreenBtn")

    --if platformName ~=nil and platformName == "iOS" then
    --    GUI.SetVisible(QuitLoginBtn,false);
    --end
end

--服务器名称
function SystemSettingUI.GetServerName()
    local _ServerName = CL.GetServerName()
    local _strs = string.split(_ServerName,"-")
    if _strs ~= nil and #_strs > 1 then
        _ServerName = _strs[2]
    end

    return _ServerName
end

function SystemSettingUI.OnShow()
    GUI.SetVisible(GUI.GetWnd("SystemSettingUI"), true)
    SystemSettingUI.RefreshUI()
    SystemSettingUI.RefreshSoundSetting()
	SystemSettingUI.RefreshGameSetting()
	SystemSettingUI.RefreshFrameSetting()
end

function SystemSettingUI.RegisterAttributeEvent()
    for k, v in pairs(attributeEventList) do
        CL.UnRegisterAttr(k, SystemSettingUI[v])
        CL.RegisterAttr(k, SystemSettingUI[v])
    end
end



--点击左侧基础设置按钮
function SystemSettingUI.OnClickBasicSetting(guid)
	SystemSettingUI.RefreshSetting(guid)
	local BasicSettingBg = _gt.GetUI("BasicSettingBg")
	local GameSettingBg = _gt.GetUI("GameSettingBg")
	local ChatSettingBg = _gt.GetUI("ChatSettingBg")
	GUI.SetVisible(BasicSettingBg,true)
	GUI.SetVisible(GameSettingBg,false)
	GUI.SetVisible(ChatSettingBg,false)
end

--点击左侧游戏设置按钮
function SystemSettingUI.OnClickGameSetting(guid)
	SystemSettingUI.RefreshSetting(guid)
	
	local BasicSettingBg = _gt.GetUI("BasicSettingBg")
	local ChatSettingBg = _gt.GetUI("ChatSettingBg")
	GUI.SetVisible(BasicSettingBg,false)
	GUI.SetVisible(ChatSettingBg,false)
	
	local GameSettingBg = _gt.GetUI("GameSettingBg")
	if GameSettingBg then
		GUI.SetVisible(GameSettingBg,true)
	else
	local panelBg = GUI.Get("SystemSettingUI/panelBg")
	local GameSettingBg = GUI.ImageCreate(panelBg,"GameSettingBg", "1800400010", 127.4, -48, false, 789, 433)
    _gt.BindName(GameSettingBg, "GameSettingBg")
	
	SystemSettingUI.CreateGameSetting(GameSettingBg)
	SystemSettingUI.RefreshGameSetting()
	end
end

--点击聊天设置按钮
function SystemSettingUI.OnClickChatSetting(guid)
	SystemSettingUI.RefreshSetting(guid)
	
	local BasicSettingBg = _gt.GetUI("BasicSettingBg")
	local GameSettingBg = _gt.GetUI("GameSettingBg")
	GUI.SetVisible(BasicSettingBg,false)
	GUI.SetVisible(GameSettingBg,false)

	local ChatSettingBg = _gt.GetUI("ChatSettingBg")
	if ChatSettingBg then
		GUI.SetVisible(ChatSettingBg,true)
	else
	local panelBg = GUI.Get("SystemSettingUI/panelBg")
	local ChatSettingBg = GUI.ImageCreate(panelBg,"ChatSettingBg", "1800400010", 127.4, -48, false, 789, 433)
    _gt.BindName(ChatSettingBg, "ChatSettingBg")
	
	SystemSettingUI.CreateChatSetting(ChatSettingBg)
	SystemSettingUI.RefreshChatSetting()
	end
	
end

--刷新按钮文本显示效果
function SystemSettingUI.RefreshSetting(guid)
	local curTab = GUI.GetByGuid(guid)
	for i = 1 ,#leftToggleList do
		local data = leftToggleList[i]
		local subTab = _gt.GetUI(data[2])
		local page = _gt.GetUI()
		if subTab == curTab then
			local text = GUI.GetChild(subTab,"Text")
			GUI.SetColor(text,UIDefine.WhiteColor)
			GUI.SetIsOutLine(text, true)	
		else
			local text = GUI.GetChild(subTab,"Text")
			GUI.SetColor(text,UIDefine.BrownColor)
			GUI.SetIsOutLine(text, false)
		end
	end
end

--离开界面
function SystemSettingUI.OnLeaveUI()
    GUI.CloseWnd("SystemSettingUI")
    --GUI.DestroyWnd("SystemSettingUI")
    test("关闭")
end

--切换角色 按钮点击事件
function SystemSettingUI.OnClickChangeRoleBtn(Key)
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法进行此操作")
        return
    end

    test("小退")
    CL.SendNotify(NOTIFY.ExitGame)
    SystemSettingUI.OnLeaveUI()
end

--切换账号 按钮点击事件
function SystemSettingUI.OnClickChangeAccountBtn(Key)
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法进行此操作")
        return
    end

    test("切换账号")
    CL.SendNotify(NOTIFY.ExitServer)
    SystemSettingUI.OnLeaveUI()
end

--退出登录 按钮点击事件
function SystemSettingUI.OnClickQuitLoginBtn(Key)
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法进行此操作")
        return
    end
    test("退出")
    CL.SendNotify(NOTIFY.ExitApplication)
    SystemSettingUI.OnLeaveUI()
end

--联系客服
function SystemSettingUI.OnClickFeedbackBtn()
	local Title = "联系客服"
	local Msg = "亲爱的玩家，如果您对游戏有什么意见或建议请在下方留言，我们收到后会进行处理。"
	GUI.OpenWnd("PlayerMsgFeedBackUI",Title..","..Msg)
end

--锁定屏幕
function SystemSettingUI.OnClickLockScreenBtn()
    GUI.CloseWnd("SystemSettingUI")
    GUI.OpenWnd("ScreenLockUI")
end

function SystemSettingUI.RefreshUI()
    local role_Name = CL.GetRoleName()
    local PlayerName = _gt.GetUI("PlayerName")
    GUI.StaticSetText(PlayerName, role_Name)

    local _ServerName = GUI.Get("SystemSettingUI/panelBg/ServerName")
    GUI.StaticSetText(_ServerName, SystemSettingUI.GetServerName())
    SystemSettingUI.RefreshRoleIcon()
    -- SystemSettingUI.RefreshBaseFunctionSetting()
end

function SystemSettingUI.RefreshRoleIcon()
    local headIcon = GUI.Get("SystemSettingUI/panelBg/HeadBg/HeadIcon")
    if headIcon then
        local headRes = tostring(CL.GetRoleHeadIcon())
        if headRes ~= "0" then
            GUI.ImageSetImageID(headIcon,headRes)
        end
    end
end

--------------------------------------------- start 声音设置 start ------------------------------------------------------
function SystemSettingUI.CreateSoundSettingList(BasicSettingBg)
    BasicSettingBg = BasicSettingBg or _gt.GetUI("BasicSettingBg")
    for i = 1, #SoundSettingList do
        local data = SoundSettingList[i]
        local y = -164 + i * 60
        local checkBox = GUI.CheckBoxCreate( BasicSettingBg, data[2] .. "CheckBox", "1800607150", "1800607151", -336, y, Transition.None, false, 38, 38)
        local checkBoxLabel = GUI.CreateStatic(checkBox, data[2] .. "CheckBoxLabel", data[1], 72, 0, 100, 40)
        GUI.StaticSetFontSize(checkBoxLabel, UIDefine.FontSizeM)
        GUI.SetColor(checkBoxLabel, TextColor)
        GUI.RegisterUIEvent(checkBox, UCE.PointerClick, "SystemSettingUI", data[3])

        local soundSlider = GUI.ScrollBarCreate( BasicSettingBg, data[2] .. "Slider", "1800208030", "1800208021", "1800208020", -119, y, 180, 14, 0, true, Transition.None, 0, 1, Direction.LeftToRight, false)
        local size = Vector2.New(202, 14)
        GUI.ScrollBarSetFillSize(soundSlider, size)
        GUI.ScrollBarSetBgSize(soundSlider, size)
        GUI.ScrollBarSetHandleSize(soundSlider, Vector2.New(32, 32))
        GUI.RegisterUIEvent(soundSlider, ULE.ValueChange, "SystemSettingUI", data[4])
    end
end

function SystemSettingUI.RefreshSoundSetting(BasicSettingBg)
    BasicSettingBg = BasicSettingBg or _gt.GetUI("BasicSettingBg")
    for i = 1, #SoundSettingList do
        local data = SoundSettingList[i]
        local checkBox = GUI.GetChild(BasicSettingBg, data[2] .. "CheckBox")
        if checkBox then
            GUI.CheckBoxSetCheck(checkBox, LD.GetSystemSettingValue(data[5]) == 1)
        end
        local soundSlider = GUI.GetChild(BasicSettingBg, data[2] .. "Slider")
        if soundSlider then
            GUI.ScrollBarSetPos(soundSlider, LD.GetSystemSettingValue(data[6]) / 100)
        end
    end
end

function SystemSettingUI.OnClickFightBgm(guid)
    local value = LD.GetSystemSettingValue(SystemSettingOption.FightBgm)
    LD.SetSystemSettingValue(SystemSettingOption.FightBgm, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickSceneBgm(guid)
    local value = LD.GetSystemSettingValue(SystemSettingOption.SceneBgm)
    LD.SetSystemSettingValue(SystemSettingOption.SceneBgm, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickSoundEffect(guid)
    local value = LD.GetSystemSettingValue(SystemSettingOption.SoundEffect)
    LD.SetSystemSettingValue(SystemSettingOption.SoundEffect, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickVoice(guid)
    local value = LD.GetSystemSettingValue(SystemSettingOption.ChatVoice)
    LD.SetSystemSettingValue(SystemSettingOption.ChatVoice, value == 1 and 0 or 1)
end

function SystemSettingUI.OnFightBgmValueChange(guid, value)
    LD.SetSystemSettingValue(SystemSettingOption.FightBgmVolume, value * 100)
end

function SystemSettingUI.OnSceneBgmValueChange(guid, value)
    LD.SetSystemSettingValue(SystemSettingOption.SceneBgmVolume, value * 100)
end

function SystemSettingUI.OnSoundEffectValueChange(guid, value)
    LD.SetSystemSettingValue(SystemSettingOption.SoundEffectVolume, value * 100)
end

function SystemSettingUI.OnVoiceValueChange(guid, value)
    LD.SetSystemSettingValue(SystemSettingOption.ChatVoiceVolume, value * 100)
end

----------------------------------------------- end 声音设置 end --------------------------------------------------------

---------------------------------------------start 界面设置 start -------------------------------------------------------

function SystemSettingUI.CreateFrameSetting(BasicSettingBg)
    -- local EffectShowTitle = GUI.CreateStatic(BasicSettingBg,"EffectShow", "场景特效展示", 94, -104,150,30)
    -- GUI.StaticSetFontSize(EffectShowTitle, 22)
    -- GUI.SetColor(EffectShowTitle, TextColor)
	-- GUI.StaticSetAlignment(EffectShowTitle, TextAnchor.MiddleCenter)
	
    -- local OpenCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"EffectShowOpenCheckBox", "1800208040", "1800208041", 102.7, -0.7, Transition.None, true)   -- HidePlayerIsOn == "true"
    -- local EffectShowLabel = GUI.CreateStatic(OpenCheckBox,"EffectShowLabel1", "开", 36.8, 0,150,30)
    -- GUI.StaticSetFontSize(EffectShowLabel, 22)
    -- GUI.SetColor(EffectShowLabel, TextColor)
	-- GUI.StaticSetAlignment(EffectShowLabel, TextAnchor.MiddleCenter)	
	-- GUI.RegisterUIEvent(OpenCheckBox, UCE.PointerClick, "SystemSettingUI", "OnEffectShowBtnClick")
	-- _gt.BindName(OpenCheckBox,"EffectShowOpen")
	
    -- local CloseCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"EffectShowCloseCheckBox", "1800208040", "1800208041", 212.7, -0.7, Transition.None, false)   -- HidePlayerIsOn == "true"
    -- local EffectShowLabel = GUI.CreateStatic(CloseCheckBox,"EffectShowLabel2", "关", 36.8, 0,150,30)
    -- GUI.StaticSetFontSize(EffectShowLabel, 22)
    -- GUI.SetColor(EffectShowLabel, TextColor)
	-- GUI.StaticSetAlignment(EffectShowLabel, TextAnchor.MiddleCenter)	
	-- GUI.RegisterUIEvent(CloseCheckBox, UCE.PointerClick, "SystemSettingUI", "OnEffectShowBtnClick")
	-- _gt.BindName(OpenCheckBox,"EffectShowClose")
	
	
    -- local EffectShowTitle = GUI.CreateStatic(BasicSettingBg,"EffectQuality", "画面品质水平", 94, -44.2,150,30)
    -- GUI.StaticSetFontSize(EffectShowTitle, 22)
    -- GUI.SetColor(EffectShowTitle, TextColor)
	-- GUI.StaticSetAlignment(EffectShowTitle, TextAnchor.MiddleCenter)
	
    -- local OpenCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"EffectQualityOpenCheckBox", "1800208040", "1800208041", 102.7, -0.7, Transition.None, true)   -- HidePlayerIsOn == "true"
    -- local EffectQualityLabel = GUI.CreateStatic(OpenCheckBox,"EffectQualityLabel1", "开", 36.8, 0,150,30)
    -- GUI.StaticSetFontSize(EffectQualityLabel, 22)
    -- GUI.SetColor(EffectQualityLabel, TextColor)
	-- GUI.StaticSetAlignment(EffectQualityLabel, TextAnchor.MiddleCenter)	
	
    -- local CloseCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"EffectQualityCloseCheckBox", "1800208040", "1800208041", 212.7, -0.7, Transition.None, false)   -- HidePlayerIsOn == "true"
    -- local EffectQualityLabel = GUI.CreateStatic(CloseCheckBox,"EffectQualityLabel2", "关", 36.8, 0,150,30)
    -- GUI.StaticSetFontSize(EffectQualityLabel, 22)
    -- GUI.SetColor(EffectQualityLabel, TextColor)
	-- GUI.StaticSetAlignment(EffectQualityLabel, TextAnchor.MiddleCenter)
	
    -- local EffectShowTitle = GUI.CreateStatic(BasicSettingBg,"FrameUpdate", "画面刷新频率", 94, 16.1,150,30)
    -- GUI.StaticSetFontSize(EffectShowTitle, 22)
    -- GUI.SetColor(EffectShowTitle, TextColor)
	-- GUI.StaticSetAlignment(EffectShowTitle, TextAnchor.MiddleCenter)
	
    -- local OpenCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"FrameUpdateOpenCheckBox", "1800208040", "1800208041", 102.7, -0.7, Transition.None, true)   -- HidePlayerIsOn == "true"
    -- local FrameUpdateLabel = GUI.CreateStatic(OpenCheckBox,"FrameUpdateLabel1", "开", 36.8, 0,150,30)
    -- GUI.StaticSetFontSize(FrameUpdateLabel, 22)
    -- GUI.SetColor(FrameUpdateLabel, TextColor)
	-- GUI.StaticSetAlignment(FrameUpdateLabel, TextAnchor.MiddleCenter)	
	
    -- local CloseCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"EffectShowCloseCheckBox", "1800208040", "1800208041", 212.7, -0.7, Transition.None, false)   -- HidePlayerIsOn == "true"
    -- local FrameUpdateLabel = GUI.CreateStatic(CloseCheckBox,"FrameUpdateLabel2", "关", 36.8, 0,150,30)
    -- GUI.StaticSetFontSize(FrameUpdateLabel, 22)
    -- GUI.SetColor(FrameUpdateLabel, TextColor)
	-- GUI.StaticSetAlignment(FrameUpdateLabel, TextAnchor.MiddleCenter)
	
    local EffectShowTitle = GUI.CreateStatic(BasicSettingBg,"PlayerCount", "同屏玩家数量", 94, -104,150,30)
    GUI.StaticSetFontSize(EffectShowTitle, 22)
    GUI.SetColor(EffectShowTitle, TextColor)
	GUI.StaticSetAlignment(EffectShowTitle, TextAnchor.MiddleCenter)
	
    -- local OpenCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"PlayerCountOpenCheckBox", "1800208040", "1800208041",  102.7, -0.7, Transition.None, true)   -- HidePlayerIsOn == "true"
    -- local PlayerCountLabel = GUI.CreateStatic(OpenCheckBox,"PlayerCountLabel1", "高", 36.8, 0,150,30)
    -- GUI.StaticSetFontSize(PlayerCountLabel, 22)
    -- GUI.SetColor(PlayerCountLabel, TextColor)
	-- GUI.StaticSetAlignment(PlayerCountLabel, TextAnchor.MiddleCenter)	
	-- GUI.RegisterUIEvent(OpenCheckBox, UCE.PointerClick, "SystemSettingUI", "OnClickPlayerCountCheckBox")
	-- _gt.BindName(OpenCheckBox,"PlayerCountOpenCheckBox")
	-- GUI.SetData(OpenCheckBox, "index", "0")
	
    -- local CloseCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"PlayerCountCloseCheckBox", "1800208040", "1800208041", 212.7, -0.7, Transition.None, false)   -- HidePlayerIsOn == "true"
    -- local PlayerCountLabel = GUI.CreateStatic(CloseCheckBox,"PlayerCountLabel2", "低", 36.8, 0,150,30)
    -- GUI.StaticSetFontSize(PlayerCountLabel, 22)
    -- GUI.SetColor(PlayerCountLabel, TextColor)
	-- GUI.StaticSetAlignment(PlayerCountLabel, TextAnchor.MiddleCenter)
	-- GUI.RegisterUIEvent(CloseCheckBox, UCE.PointerClick, "SystemSettingUI", "OnClickPlayerCountCheckBox")
	-- _gt.BindName(CloseCheckBox,"PlayerCountCloseCheckBox")
	-- GUI.SetData(CloseCheckBox, "index", "1")
	local PlayerCountSlider = GUI.ScrollBarCreate( EffectShowTitle,"PlayerCountSlider", "1800208030", "1800208021", "1800208020", 175, -1, 150, 14, 0, true, Transition.None, 0, 1, Direction.LeftToRight, false)
	local size = Vector2.New(150, 14)
	GUI.ScrollBarSetFillSize(PlayerCountSlider, size)
	GUI.ScrollBarSetBgSize(PlayerCountSlider, size)
	GUI.ScrollBarSetHandleSize(PlayerCountSlider, Vector2.New(32, 32))
	GUI.RegisterUIEvent(PlayerCountSlider, ULE.ValueChange, "SystemSettingUI", "OnScreenPlayerCountChange")
	_gt.BindName(PlayerCountSlider,"PlayerCountSlider")


    local EffectShowTitle = GUI.CreateStatic(BasicSettingBg,"PlayerCount", "屏蔽宠物侍从", 94, -44.2,150,30)
    GUI.StaticSetFontSize(EffectShowTitle, 22)
    GUI.SetColor(EffectShowTitle, TextColor)
	GUI.StaticSetAlignment(EffectShowTitle, TextAnchor.MiddleCenter)
	
    local OpenCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"PetAndGuardOpenCheckBox", "1800208040", "1800208041",  102.7, -0.7, Transition.None, false)   -- HidePlayerIsOn == "true"
    local PetAndGuardLabel = GUI.CreateStatic(OpenCheckBox,"PetAndGuardLabel1", "开", 36.8, 0,150,30)
    GUI.StaticSetFontSize(PetAndGuardLabel, 22)
    GUI.SetColor(PetAndGuardLabel, TextColor)
	GUI.StaticSetAlignment(PetAndGuardLabel, TextAnchor.MiddleCenter)	
	GUI.RegisterUIEvent(OpenCheckBox, UCE.PointerClick, "SystemSettingUI", "OnClickOtherPetAndGuardCanSee")
	_gt.BindName(OpenCheckBox,"PetAndGuardOpenCheckBox")
	GUI.SetData(OpenCheckBox, "index", "1")
	
    local CloseCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"PetAndGuardCloseCheckBox", "1800208040", "1800208041", 212.7, -0.7, Transition.None, true)   -- HidePlayerIsOn == "true"
    local PetAndGuardLabel = GUI.CreateStatic(CloseCheckBox,"PetAndGuardLabel2", "关", 36.8, 0,150,30)
    GUI.StaticSetFontSize(PetAndGuardLabel, 22)
    GUI.SetColor(PetAndGuardLabel, TextColor)
	GUI.StaticSetAlignment(PetAndGuardLabel, TextAnchor.MiddleCenter)
	GUI.RegisterUIEvent(CloseCheckBox, UCE.PointerClick, "SystemSettingUI", "OnClickOtherPetAndGuardCanSee")
	_gt.BindName(CloseCheckBox,"PetAndGuardCloseCheckBox")
	GUI.SetData(CloseCheckBox, "index", "0")


    local EffectShowTitle = GUI.CreateStatic(BasicSettingBg,"FrameRate", "设置刷新帧率", 94, 16.2,150,30)
    GUI.StaticSetFontSize(EffectShowTitle, 22)
    GUI.SetColor(EffectShowTitle, TextColor)
    GUI.StaticSetAlignment(EffectShowTitle, TextAnchor.MiddleCenter)

    local isHighRate = CL.GetUserOperateRecord("GAME_FRAME_RATE")=="1"
    local OpenCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"FrameRateCheckBoxHigh", "1800208040", "1800208041",  102.7, -0.7, Transition.None, isHighRate)   -- HidePlayerIsOn == "true"
    local PetAndGuardLabel = GUI.CreateStatic(OpenCheckBox,"FrameRateLable1", "高", 36.8, 0,150,30)
    GUI.StaticSetFontSize(PetAndGuardLabel, 22)
    GUI.SetColor(PetAndGuardLabel, TextColor)
    GUI.StaticSetAlignment(PetAndGuardLabel, TextAnchor.MiddleCenter)
    GUI.RegisterUIEvent(OpenCheckBox, UCE.PointerClick, "SystemSettingUI", "OnClickFrameRateCheckBox")
    _gt.BindName(OpenCheckBox,"FrameRateCheckBoxHigh")
    GUI.SetData(OpenCheckBox, "index", "1")

    local CloseCheckBox = GUI.CheckBoxCreate(EffectShowTitle,"FrameRateCheckBoxLow", "1800208040", "1800208041", 212.7, -0.7, Transition.None, not isHighRate)   -- HidePlayerIsOn == "true"
    local PetAndGuardLabel = GUI.CreateStatic(CloseCheckBox,"FrameRateLable2", "低", 36.8, 0,150,30)
    GUI.StaticSetFontSize(PetAndGuardLabel, 22)
    GUI.SetColor(PetAndGuardLabel, TextColor)
    GUI.StaticSetAlignment(PetAndGuardLabel, TextAnchor.MiddleCenter)
    GUI.RegisterUIEvent(CloseCheckBox, UCE.PointerClick, "SystemSettingUI", "OnClickFrameRateCheckBox")
    _gt.BindName(CloseCheckBox,"FrameRateCheckBoxLow")
    GUI.SetData(CloseCheckBox, "index", "0")

    --屏蔽玩家宠物
    -- local HidePlayerIsOn = GUI.GetData(UIRoot, BasicSettingOptionDataKeys[13])
    -- local OtherPetAndGuardCanSeeBox = GUI.CheckBoxCreate(BasicSettingBg,"OtherPetAndGuardCanSeeBox", "1800607150", "1800607151", 43.5, 150, Transition.None, false, 38, 38)   -- HidePlayerIsOn == "true"
    -- local OtherPetAndGuardCanSeeLabel = GUI.CreateStatic(OtherPetAndGuardCanSeeBox,"OtherPetAndGuardCanSeeLabel", "屏蔽宠物侍从", 93, -1,150,30)
    -- GUI.StaticSetFontSize(OtherPetAndGuardCanSeeLabel, 22)
    -- GUI.SetColor(OtherPetAndGuardCanSeeLabel, TextColor)
	-- GUI.StaticSetAlignment(OtherPetAndGuardCanSeeLabel, TextAnchor.MiddleCenter)
    -- GUI.RegisterUIEvent(OtherPetAndGuardCanSeeBox, UCE.PointerClick, "SystemSettingUI", "OnClickOtherPetAndGuardCanSee")
	-- _gt.BindName(OtherPetAndGuardCanSeeBox,"OtherPetAndGuardCanSee")

    --屏蔽侍从
    -- local hideOtherPetIsOn = GUI.GetData(UIRoot, BasicSettingOptionDataKeys[14])
    -- local OtherGuardCanSeeCheckBox = GUI.CheckBoxCreate(BasicSettingBg,"OtherGuardCanSeeCheckBox", "1800607150", "1800607151",  43.5, 16, Transition.None,false , 38, 38) --hideOtherPetIsOn == "true"
    -- local OtherGuardCanSeeCheckBoxLabel = GUI.CreateStatic(OtherGuardCanSeeCheckBox,"OtherGuardCanSeeCheckBoxLabel", "屏蔽侍从",68.4, -1, 150,30)
    -- GUI.StaticSetFontSize(OtherGuardCanSeeCheckBoxLabel, 22)
    -- GUI.SetColor(OtherGuardCanSeeCheckBoxLabel, TextColor)
	-- GUI.StaticSetAlignment(OtherGuardCanSeeCheckBoxLabel, TextAnchor.MiddleCenter)
    -- GUI.RegisterUIEvent(OtherGuardCanSeeCheckBox, UCE.PointerClick, "SystemSettingUI", "OnClickOtherGuardCanSee")
	-- _gt.BindName(OtherGuardCanSeeCheckBox,"OtherGuardCanSee")
	-- local checkBox = GUI.CheckBoxCreate( BasicSettingBg, data[2] .. "CheckBox", "1800607150", "1800607151", -336, y, Transition.None, false, 38, 38)
    -- local checkBoxLabel = GUI.CreateStatic(checkBox, data[2] .. "CheckBoxLabel", data[1], 72, 0, 100, 40)
    -- GUI.StaticSetFontSize(checkBoxLabel, UIDefine.FontSizeM)
    -- GUI.SetColor(checkBoxLabel, TextColor)
    -- GUI.RegisterUIEvent(checkBox, UCE.PointerClick, "SystemSettingUI", data[3])

	-- {"屏蔽宠物", "OtherPetCanSee", "OnClickOtherPetCanSee",-264.7,80},
	-- {"屏蔽侍从", "OtherGuardCanSee", "OnClickOtherGuardCanSee",114.7,80},
end

function SystemSettingUI.RefreshFrameSetting(BasicSettingBg)
	--等待接口
	
	--刷新屏蔽玩家宠物侍从的显示
	SystemSettingUI.RefreshOtherPetAndGuardCanSee()
	-- SystemSettingUI.RefreshOtherGuardCanSee()

	SystemSettingUI.RefreshPlayerCount()
end

--同屏玩家数量点击设置时
function SystemSettingUI.OnClickPlayerCountCheckBox(guid)
    local val = CL.GetIntCustomData("TEAM_OtherTeamCanSee")
	
	local index = GUI.GetData(GUI.GetByGuid(guid), "index")
	
	local OpenBox = _gt.GetUI("PlayerCountOpenCheckBox")
	local CloseBox = _gt.GetUI("PlayerCountCloseCheckBox")
	
    if OpenBox and CloseBox then
        GUI.CheckBoxSetCheck(OpenBox, index == "0")
		GUI.CheckBoxSetCheck(CloseBox,index == "1")
    end 
	
	if index == tostring(val) then
        CL.SendNotify(NOTIFY.ShowBBMsg,"保持目前设置")
		MainUI.OnChangeHideOtherRole = val
		return
	end
	
	val = val == 0 and 1 or 0

    MainUI.OnChangeHideOtherRole = val
    CL.SendNotify(NOTIFY.ShowBBMsg,"已更改玩家显示 （切换地图后生效）")
end

--同屏玩家数量刷新
function SystemSettingUI.RefreshPlayerCount(value)
	-- if not value then
		-- value = CL.GetIntCustomData("TEAM_OtherTeamCanSee")
	-- end

    -- if MainUI.OnChangeHideOtherRole ~= -1 then
        -- value = MainUI.OnChangeHideOtherRole
    -- end

	-- local OpenBox = _gt.GetUI("PlayerCountOpenCheckBox")
	-- local CloseBox = _gt.GetUI("PlayerCountCloseCheckBox")
	
    -- if OpenBox and CloseBox then
        -- GUI.CheckBoxSetCheck(OpenBox, tostring(value) ~= "1")
		-- GUI.CheckBoxSetCheck(CloseBox, tostring(value) == "1")
    -- end
	local value = tonumber(tostring(CL.GetUserOperateRecord("ClientRoleFilter_PlayerCount")))
	if not value then
		value = InitScreenNum
		if UIDefine.IsFunctionOrVariableExist(CL, "ClientRoleFilter")  then
			CL.ClientRoleFilter(value)
			CL.SetUserOperateRecord("ClientRoleFilter_PlayerCount",value)
		end		
	end
	
	if value == -1 then
		value = ScreenPlayerCountFunction[#ScreenPlayerCountFunction].count
	end
	--改为拉杆
	local a = 0
	local b = 0
	local c = 0
	local d = 0
	for i =1 , #ScreenPlayerCountFunction do
		tb = ScreenPlayerCountFunction[i]
		if value >= tb.count then
			a  = tb.position
			c = tb.count
		elseif value <= tb.count then
			b  = tb.position
			d = tb.count			
			break
		end
	end
	local pos = (value - (b*c-a*d)/(b-a))*(b-a)/(d-c)
	local PlayerCountSlider = _gt.GetUI("PlayerCountSlider")
	-- test("pos: "..pos)
	if PlayerCountSlider then
		GUI.ScrollBarSetPos(PlayerCountSlider,pos / 100)
	end	
end

function SystemSettingUI.OnScreenPlayerCountChange(guid, value)
	local pos = value*100
	local a = 0
	local b = 0
	local c = 0
	local d = 0
	for i =1 , #ScreenPlayerCountFunction do
		tb = ScreenPlayerCountFunction[i]
		if pos >= tb.position then
			a  = tb.position
			c = tb.count
		elseif pos <= tb.position then
			b  = tb.position
			d = tb.count			
			break
		end
	end
	value = math.floor((d-c)/(b-a)*pos + (b*c-a*d)/(b-a))
	if value == ScreenPlayerCountFunction[#ScreenPlayerCountFunction].count then
		value = -1
	end
	-- test("value: "..value)
	if UIDefine.IsFunctionOrVariableExist(CL, "ClientRoleFilter")  then
		CL.ClientRoleFilter(value)
		CL.SetUserOperateRecord("ClientRoleFilter_PlayerCount" , value)
	end
end


--- 设置帧率
function SystemSettingUI.OnClickFrameRateCheckBox(guid)
    if UIDefine.IsFunctionOrVariableExist(CL, "SetFrameRate")  then
        local index = GUI.GetData(GUI.GetByGuid(guid), "index")
        local CheckBoxHigh = _gt.GetUI("FrameRateCheckBoxHigh")
        local CheckBoxLow = _gt.GetUI("FrameRateCheckBoxLow")
        if CheckBoxHigh and CheckBoxLow then
            GUI.CheckBoxSetCheck(CheckBoxHigh, index == "1")
            GUI.CheckBoxSetCheck(CheckBoxLow,index == "0")
        end

        local frame = UIDefine.GetTargetFrameRate(index=="1")
        CL.SetFrameRate(frame)
        CL.SetUserOperateRecord("GAME_FRAME_RATE",index)
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,"暂不可用，请更新游戏版本")
    end
end

--- 宠物侍从屏蔽
function SystemSettingUI.OnClickOtherPetAndGuardCanSee(guid)
	
    local val = CL.GetIntCustomData("PET_OtherPetCanSee")
	
	local index = GUI.GetData(GUI.GetByGuid(guid), "index")

	local OpenBox = _gt.GetUI("PetAndGuardOpenCheckBox")
	local CloseBox = _gt.GetUI("PetAndGuardCloseCheckBox")
	
	
    if OpenBox and CloseBox then
        GUI.CheckBoxSetCheck(OpenBox, index == "1")
		GUI.CheckBoxSetCheck(CloseBox,index == "0")
    end
	

	if index == tostring(val) then
        CL.SendNotify(NOTIFY.ShowBBMsg,"保持目前设置")
		MainUI.OnChangeHideOtherPetGuard = val
		return
	end
	
	val = val == 0 and 1 or 0

    MainUI.OnChangeHideOtherPetGuard = val
    CL.SendNotify(NOTIFY.ShowBBMsg,"已更改宠物侍从显示（切换地图后生效）")
end

--- 宠物屏蔽刷新
function SystemSettingUI.RefreshOtherPetAndGuardCanSee(value)
	if not value then
		value = CL.GetIntCustomData("PET_OtherPetCanSee")
	end
    if MainUI.OnChangeHideOtherPetGuard ~= -1 then
        value = MainUI.OnChangeHideOtherPetGuard
    end
	-- CDebug.LogError(value)
	local OpenBox = _gt.GetUI("PetAndGuardOpenCheckBox")
	local CloseBox = _gt.GetUI("PetAndGuardCloseCheckBox")
	
    if OpenBox and CloseBox then
        GUI.CheckBoxSetCheck(OpenBox, tostring(value) == "1")
		GUI.CheckBoxSetCheck(CloseBox, tostring(value) ~= "1")
    end
end

-- function SystemSettingUI.OnEffectShowBtnClick(guid)
	-- local btn = GUI.GetByGuid(guid)
	-- local openbtn = _gt.GetUI("EffectShowOpen")
	-- local closebtn = _gt.GetUI("EffectShowClose")
	-- test(btn)
	-- GUI.CheckBoxSetCheck(openbtn,openbtn == btn)
	-- GUI.CheckBoxSetCheck(closebtn,closebtn == btn)
	
-- end
----------------------------------------------- end 界面设置 end --------------------------------------------------------

--------------------------------------------- start 游戏设置 start ------------------------------------------------------
function SystemSettingUI.CreateGameSetting(GameSettingBg)
    GameSettingBg = GameSettingBg or _gt.GetUI("GameSettingBg")
    for i = 1, #GameSettingList do
        local data = GameSettingList[i]
        local name = data[2]
        local CheckBox = GUI.CheckBoxCreate(GameSettingBg, name, "1800607150","1800607151", data[4], data[5], Transition.ColorTint, false, 38, 38)
        _gt.BindName(CheckBox, name)
        local text = GUI.CreateStatic(CheckBox, "Text", data[1], 181, 0, 320, 60, "system", true)
        SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(text, UIDefine.BrownColor)
        GUI.StaticSetFontSize(text, UIDefine.FontSizeM)
		GUI.StaticSetAlignment(petNumText, TextAnchor.MiddleLeft)
        -- GUI.SetIsRaycastTarget(text, true)
        GUI.RegisterUIEvent(CheckBox, UCE.PointerClick, "SystemSettingUI", data[3])
    end
end

function SystemSettingUI.RefreshGameSetting()
    SystemSettingUI.RefreshAcceptTeamUp()
    SystemSettingUI.RefreshSelfIsAcceptBattle()
    SystemSettingUI.RefreshAcceptMakeFriend()
	-- SystemSettingUI.RefreshOtherPetCanSee()
	-- SystemSettingUI.RefreshOtherGuardCanSee()
	SystemSettingUI.RefreshAutoSkipMovie()
	SystemSettingUI.RefreshPowerSaveMode()
	SystemSettingUI.RefreshEscape()
	SystemSettingUI.RefreshAutoCatchPet()
	SystemSettingUI.RefreshBeViewInfo()
	SystemSettingUI.RefreshAcceptNews()
end

------ 点击接受组队
function SystemSettingUI.OnClickAcceptTeamUp()
    local val = CL.GetIntCustomData("TEAM_AutoRefuseApply")
    val = val == 0 and 1 or 0
    CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "SetAutoRefuseApply", val)
end


function SystemSettingUI.OnClickAutoSkipMovie()
	local check = _gt.GetUI("autoSkipCheck")
	if check then
		local isCheck = GUI.CheckBoxGetCheck(check)
		if isCheck then
			LD.SetSystemSettingValue(SystemSettingOption.AutoClickSkipNpcDialog,1)
		else
			LD.SetSystemSettingValue(SystemSettingOption.AutoClickSkipNpcDialog,0)
		end
	end
end

--- 接受组队刷新
function SystemSettingUI.RefreshAcceptTeamUp(value)
    if not value then
        value = CL.GetIntCustomData("TEAM_AutoRefuseApply")
    end
    local checkBox = _gt.GetUI("acceptTeamUp")
    if checkBox then
        GUI.CheckBoxSetCheck(checkBox, tostring(value) == "0")
    end
end

function SystemSettingUI.RefreshAutoSkipMovie()
    local checkBox = _gt.GetUI("autoSkipCheck")
    if checkBox then
		local isAutoSkip = LD.GetSystemSettingValue(SystemSettingOption.AutoClickSkipNpcDialog) == 1
		GUI.CheckBoxSetCheck(checkBox, isAutoSkip)
    end
end

--- 点击接受切磋
function SystemSettingUI.OnClickAcceptPK()
    local value = LD.GetSystemSettings(RoleAttr.RoleAttrCanDuel)
    value = value == 0 and 1 or 0
    LD.SetSystemSettings(RoleAttr.RoleAttrCanDuel, value)
end

--- 切磋刷新
function SystemSettingUI.RefreshSelfIsAcceptBattle(attrType, value)
    if not value  then
        value = LD.GetSystemSettings(RoleAttr.RoleAttrCanDuel)
    end
    local checkBox = _gt.GetUI("acceptPK")
    if checkBox then
        GUI.CheckBoxSetCheck(checkBox, tostring(value) == "1")
    end
end

--- 接受被加为好友
function SystemSettingUI.OnClickAcceptMakeFriend()
    local val = CL.GetIntCustomData("CONTACT_AutoRefuseApply")
    val = val == 0 and 1 or 0
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "SetAutoRefuseApply", val)
end

--- 接受好友刷新
function SystemSettingUI.RefreshAcceptMakeFriend(value)
    if not value  then
        value = CL.GetIntCustomData("CONTACT_AutoRefuseApply")
    end
    local checkBox = _gt.GetUI("acceptMakeFriend")
    if checkBox then
        GUI.CheckBoxSetCheck(checkBox, tostring(value) == "0")
    end
end



--点击接受被查看消息
function SystemSettingUI.OnClickBeViewInfo()
    local value = LD.GetSystemSettings(RoleAttr.RoleAttrCanQuery)
	test(value)
    value = value == 0 and 1 or 0
    LD.SetSystemSettings(RoleAttr.RoleAttrCanQuery, value)
end

--刷新接受被查看消息
function SystemSettingUI.RefreshBeViewInfo(attrType, value)
    if not value  then
        value = LD.GetSystemSettings(RoleAttr.RoleAttrCanQuery)
    end
    local checkBox = _gt.GetUI("BeViewInfo")
    if checkBox then
		test("存在")
		test(value)
        GUI.CheckBoxSetCheck(checkBox, tostring(value) == "1")
    end
end

--点击接受陌生人消息
function SystemSettingUI.OnClickAcceptNews()
    local value = LD.GetSystemSettings(RoleAttr.RoleAttrCanMsg)
	test(value)
    value = value == 0 and 1 or 0
    LD.SetSystemSettings(RoleAttr.RoleAttrCanMsg, value)
end

--刷新接受陌生人消息
function SystemSettingUI.RefreshAcceptNews(attrType, value)
    if not value  then
        value = LD.GetSystemSettings(RoleAttr.RoleAttrCanMsg)
    end
    local checkBox = _gt.GetUI("acceptNews")
    if checkBox then
		test("存在")
		test(value)
        GUI.CheckBoxSetCheck(checkBox, tostring(value) == "1")
    end
end

--点击省电模式
function SystemSettingUI.OnClickPowerSave()	
	local value = LD.GetSystemSettingValue(SystemSettingOption.SavePowerMode)
    LD.SetSystemSettingValue(SystemSettingOption.SavePowerMode, value == 1 and 0 or 1)
	test(LD.GetSystemSettingValue(SystemSettingOption.SavePowerMode))
end

--刷新省电模式状态
function SystemSettingUI.RefreshPowerSaveMode(value)
    if not value  then
        value = LD.GetSystemSettingValue(SystemSettingOption.SavePowerMode)
    end
    local checkBox = _gt.GetUI("PowerSave")
    if checkBox then
        GUI.CheckBoxSetCheck(checkBox, tostring(value) == "1")
    end
end

--点击自动抓宠
function SystemSettingUI.OnClickAutoCatchPet()
    local value = LD.GetSystemSettings(RoleAttr.RoleAttrCanAutoCatchBaby)
	test(value)
    value = value == 0 and 1 or 0
    LD.SetSystemSettings(RoleAttr.RoleAttrCanAutoCatchBaby, value)
end

--刷新自动抓宠
function SystemSettingUI.RefreshAutoCatchPet(attrType, value)
    if not value  then
        value = LD.GetSystemSettings(RoleAttr.RoleAttrCanAutoCatchBaby)
    end
    local checkBox = _gt.GetUI("autoCatchPet")
    if checkBox then
		test("存在")
		test(tostring(value))
        GUI.CheckBoxSetCheck(checkBox, tostring(value) == "1")
    end
end

--点击逃跑确认
function SystemSettingUI.OnClickEscape()	
	local value = LD.GetSystemSettingValue(SystemSettingOption.MakeSureEscape)
    LD.SetSystemSettingValue(SystemSettingOption.MakeSureEscape, value == 1 and 0 or 1)
	test(LD.GetSystemSettingValue(SystemSettingOption.MakeSureEscape))
end

--刷新逃跑确认
function SystemSettingUI.RefreshEscape(value)
    if not value  then
        value = LD.GetSystemSettingValue(SystemSettingOption.MakeSureEscape)
    end
    local checkBox = _gt.GetUI("Escape")
    if checkBox then
        GUI.CheckBoxSetCheck(checkBox, tostring(value) == "1")
    end
end

----------------------------------------------- end 功能设置 end --------------------------------------------------------

--------------------------------------------- start 聊天设置 start ------------------------------------------------------
function SystemSettingUI.CreateChatSetting(ChatSettingBg)
	ChatSettingBg = ChatSettingBg or _gt.GetUI("ChatSettingBg")
	
    --自动播放标题
    local AutoPlayVoiceTitle = GUI.CreateStatic(ChatSettingBg , "AutoPlayVoiceTitle", "自动播放频道语音", -196.3, -172.1,200,50)
    GUI.StaticSetFontSize(AutoPlayVoiceTitle, 24)
    GUI.SetColor(AutoPlayVoiceTitle, TextColor)
	GUI.StaticSetAlignment(AutoPlayVoiceTitle, TextAnchor.MiddleCenter)
	
	--分割线
    local Line = GUI.ImageCreate(ChatSettingBg,"Line", "1800208050", -1.3, 0, false, 2, 422.48)
	
	--屏蔽频道发言标题
    local ShieldSpeechTitle = GUI.CreateStatic(ChatSettingBg , "ShieldSpeechTitle", "屏蔽频道发言", 194.9, -172.1, 150,50)
    GUI.StaticSetFontSize(ShieldSpeechTitle, 24)
    GUI.SetColor(ShieldSpeechTitle, TextColor)
	GUI.StaticSetAlignment(ShieldSpeechTitle, TextAnchor.MiddleCenter)
	
    for i = 1, #ChatSettingList do
        local data = ChatSettingList[i]
        local name = data[2]
        local CheckBox = GUI.CheckBoxCreate(ChatSettingBg, name, "1800607150","1800607151", data[4], data[5], Transition.ColorTint, false, 38, 38)
        _gt.BindName(CheckBox, name)
        local text = GUI.CreateStatic(CheckBox, "Text", data[1], 181, 0, 320, 60, "system", true)
        SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(text, UIDefine.BrownColor)
        GUI.StaticSetFontSize(text, UIDefine.FontSizeM)
		GUI.StaticSetAlignment(petNumText, TextAnchor.MiddleLeft)
        -- GUI.SetIsRaycastTarget(text, true)
        GUI.RegisterUIEvent(CheckBox, UCE.PointerClick, "SystemSettingUI", data[3])
    end	

	--解除屏蔽
    local UnblockBtn = GUI.ButtonCreate(ChatSettingBg, "UnblockBtn", "1800402110", 90, 145, Transition.ColorTint, "解除屏蔽", 122, 46, false)
    GUI.ButtonSetTextFontSize(UnblockBtn, 24)
    GUI.ButtonSetTextColor(UnblockBtn,Color.New(144 / 255, 84 / 255, 56 / 255, 255 / 255))
    GUI.RegisterUIEvent(UnblockBtn, UCE.PointerClick, "SystemSettingUI", "OnClickUnblock")

end

function SystemSettingUI.RefreshChatSetting()
	for i = 1, #ChatSettingList do
        local data = ChatSettingList[i]
        local name = data[2]
		local CheckBox = _gt.GetUI(name)
		local value = LD.GetSystemSettingValue(SystemSettingOption[data[6]])
		GUI.CheckBoxSetCheck(CheckBox,tostring(value) == "1")
	end
end

function SystemSettingUI.OnClickCurChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ChatChannelCurrent)
    LD.SetSystemSettingValue(SystemSettingOption.ChatChannelCurrent, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickFactionChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ChatChannelGuild)
    LD.SetSystemSettingValue(SystemSettingOption.ChatChannelGuild, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickWorldChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ChatChannelWorld)
    LD.SetSystemSettingValue(SystemSettingOption.ChatChannelWorld, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickTeamChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ChatChannelTeam)
    LD.SetSystemSettingValue(SystemSettingOption.ChatChannelTeam, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickSchoolChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ChatChannelSchool)
    LD.SetSystemSettingValue(SystemSettingOption.ChatChannelSchool, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickHornChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ChatChannelSpeaker)
    LD.SetSystemSettingValue(SystemSettingOption.ChatChannelSpeaker, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickShieldCurChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ShieldChannelCurrent)
    LD.SetSystemSettingValue(SystemSettingOption.ShieldChannelCurrent, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickShieldFactionChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ShieldChannelGuild)
    LD.SetSystemSettingValue(SystemSettingOption.ShieldChannelGuild, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickShieldWorldChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ShieldChannelWorld)
    LD.SetSystemSettingValue(SystemSettingOption.ShieldChannelWorld, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickShieldTeamChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ShieldChannelTeam)
    LD.SetSystemSettingValue(SystemSettingOption.ShieldChannelTeam, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickShieldSchoolChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ShieldChannelSchool)
    LD.SetSystemSettingValue(SystemSettingOption.ShieldChannelSchool, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickShieldHornChannel()
	local value = LD.GetSystemSettingValue(SystemSettingOption.ShieldChannelSpeaker)
    LD.SetSystemSettingValue(SystemSettingOption.ShieldChannelSpeaker, value == 1 and 0 or 1)
end

function SystemSettingUI.OnClickRecruit() --未对接
	local value = LD.GetSystemSettingValue(SystemSettingOption.ChatChannelCurrent)
    LD.SetSystemSettingValue(SystemSettingOption.ChatChannelCurrent, value == 1 and 0 or 1)
end

--取消屏蔽
function SystemSettingUI.OnClickUnblock()
	for i =7 , #ChatSettingList do
		local tb = ChatSettingList[i]
		LD.SetSystemSettingValue(SystemSettingOption[tb[6]], 0)		
	end
	SystemSettingUI.RefreshChatSetting()

end


--------------------------------------------- end 聊天设置 end ------------------------------------------------------
