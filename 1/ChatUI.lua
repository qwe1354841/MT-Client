local ChatUI = {
    CurrentSelectChannel = 1, -- 当前默认选中当前频道
    IsLock = false
}
_G.ChatUI = ChatUI
local GuidCacheUtil = UILayout.NewGUIDUtilTable()
local WaitTime = 20

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local UCE = UCE
------------------------------------ end缓存一下全局变量end --------------------------------

local trumpetChatColor = Color.New(251 / 255, 167 / 255, 48 / 255)            --世界聊天
local colorType_DarkYellow = UIDefine.BrownColor --Color.New(102 / 255, 47 / 255, 22 / 255)            --深黄色文字
local colorType_Input = Color.New(135 / 255, 135 / 255, 135 / 255)
local importantInfoColor = Color.New(255 / 255, 242 / 255, 208 / 255, 255 / 255) -- Color HexNumber: fff2d0ff ，基础属性&基础信息
local colorType_Txt = UIDefine.BrownColor

local fontSize_BigOne = UIDefine.FontSizeL -- 24
local fontSize_BigTwo = UIDefine.FontSizeXL -- 26
local fontSize = UIDefine.FontSizeM -- 22
local fontSize_Little = UIDefine.FontSizeSS

local fontColor1 = "AC7527"        --黄颜色文字
local fontColor2 = "662F16"        --深色文字
local fontColor3 = "6D3C18"

local inviteCode="#ICOD"
local TrumpetDeleteTime = 60
local TrumpetTimer = nil
local rollSendTime = nil
local rollCdTime = 5
local CrossServerChat = false  -- 是否支持跨服聊天

local messageEventList = {
    { GM.TalkBubble, "OnRecvChatMessage" },
    { GM.UploadRecordSuccess, "OnUploadRecordSuccess" },
    { GM.RecordPlayStart, "OnRecordPlayStart" },
    { GM.ItemQueryNtf, "OnItemQueryNtf" },
    { GM.PetQueryNtf, "OnPetQueryNtf" },
    { GM.PlayerQueryNtf, "OnPlayerQueryNtf" },
    { GM.MailUpdate, "OnMailUpdate" }
}

local role_HeadList = {
    [1] = "1900300010",
    [2] = "1900300020",
    [3] = "1900300030",
    [4] = "1900300040",
    [5] = "1900300050",
    [6] = "1900300060",
    [7] = "1900300070",
    [8] = "1900300080",
    [9] = "1900300090",
    [10] = "1900300100",
    [11] = "1900300110",
    [12] = "1900300120",
}

local ChannelIDDefine = {
    All = 0,
    Current = 1,
    Team = 2,
    Faction = 3,
    Map = 4,
    Trumpet = 5,
    Recruit = 6,
    School = 7,
    World = 8,
    System = 9,
    CrossServer = 10,
    System_Personal = 101,
    System_System = 102,
}

local btnList = {
    { "全部", "allChatBtn_0", "1800902030", "1800902031", "CheckAllChannel", "OnClickAllChannel", 20, 85, Color.New(255 / 255, 255 / 255, 255 / 255), nil, ChannelIDDefine.All },
    --系统————所有
    { "系统", "systemChatBtn_9", "1800902030", "1800902031", "CheckSystemChannel", "OnClickSystemChannel", 20, 135, Color.New(237 / 255, 65 / 255, 36 / 255), "1800204010", ChannelIDDefine.System },
    { "世界", "worldChatBtn_8", "1800902030", "1800902031", "CheckWorldChannel", "OnClickWorldChannel", 20, 185, Color.New(59 / 255, 255 / 255, 82 / 255), "1800204070", ChannelIDDefine.World },
    { "跨服", "crossServerChatBtn_8", "1800902030", "1800902031", "CheckCrossServerChannel", "OnClickCrossServerChannel", 20, 185, Color.New(59 / 255, 255 / 255, 82 / 255), "1800204070", ChannelIDDefine.CrossServer },
    { "喇叭", "trumpetChatBtn_5", "1800902030", "1800902031", "CheckTrumpetChannel", "OnClickTrumpetChannel", 20, 235, Color.New(255 / 255, 167 / 255, 48 / 255), "1800204080", ChannelIDDefine.Trumpet },
    { "当前", "currentChatBtn_1", "1800902030", "1800902031", "CheckCurrentChannel", "OnClickCurrentChannel", 20, 285, Color.New(255 / 255, 255 / 255, 255 / 255), "1800204060", ChannelIDDefine.Current },
    --{ "门派", "schoolChatBtn_7", "1800902030", "1800902031", "CheckSchoolChannel", "OnClickSchoolChannel", 20, 335, Color.New(3 / 255, 246 / 255, 255 / 255), "1800204050", ChannelIDDefine.School },
    { "帮派", "factionChatBtn_3", "1800902030", "1800902031", "CheckFactionChannel", "OnClickFactionChannel", 20, 385, Color.New(254 / 255, 122 / 255, 117 / 255), "1800204040", ChannelIDDefine.Faction },
    { "队伍", "teamChatBtn_2", "1800902030", "1800902031", "CheckTeamChannel", "OnClickTeamChannel", 20, 435, Color.New(255 / 255, 223 / 255, 41 / 255), "1800204030", ChannelIDDefine.Team },
    { "招募", "recruitChatBtn_6", "1800902030", "1800902031", "CheckRecruitChannel", "OnClickRecruitChannel", 20, 485, Color.New(255 / 255, 72 / 255, 137 / 255), "1800205840", ChannelIDDefine.Recruit },
}
local sysChatBtn = {
    { "所有", "systemChatBtnAll_20", "1800402030", "1800402031", "1800204010", "OnClickSystemAll", 95, 15, Color.New(237 / 255, 65 / 255, 36 / 255), ChannelIDDefine.System },
    --系统————个人
    { "个人", "systemChatBtn_101", "1800402030", "1800402031", "1800205850", "OnClickSystemPersonal", 395, 15, Color.New(105 / 255, 183 / 255, 255 / 255), ChannelIDDefine.System_Personal },
    --系统————系统
    { "系统", "systemChatBtn_102", "1800402030", "1800402031", "1800204010", "OnClickSystemSystem", 245, 15, Color.New(237 / 255, 65 / 255, 36 / 255), ChannelIDDefine.System_System },
}

--{频道Id，频道名，是否能播放语音}
local channelType = {
    { ChannelIDDefine.Current, "当前", true },
    { ChannelIDDefine.Team, "队伍", true },
    { ChannelIDDefine.Faction, "帮派", true },
    { ChannelIDDefine.Trumpet, "喇叭", true },
    { ChannelIDDefine.Recruit, "招募", false },
    --{ ChannelIDDefine.School, "门派", true },
    { ChannelIDDefine.World, "世界", true },
    { ChannelIDDefine.System, "系统", false },
}

local CurRecordChannel = nil
local recordBtnGuid2Channel = {}
local recordName2BtnGuid = {}
local lockIndexTable = {}
local CurItemQueryGuid = nil
local CurQueryPlayerName = nil

------------------------------------Start 随机点数变量 Start----------------------------

local pointRefreshNum = 24 --随即点数刷新数量

local pointRefreshSpeed = 250 --随即点数刷新速度

local pointLoopGuidOfRandom = {} --Loop的Guid与随机数的关联表

local pointLoopChildGuidOfParentGuid = {} --Loop子类的Guid与父类Guid的关联表

local randomOfImgTable = {
    ["0"] = "1800705000",
    ["1"] = "1800705010",
    ["2"] = "1800705020",
    ["3"] = "1800705030",
    ["4"] = "1800705040",
    ["5"] = "1800705050",
    ["6"] = "1800705060",
    ["7"] = "1800705070",
    ["8"] = "1800705080",
    ["9"] = "1800705090",
}

--------------------------------------End 随机点数变量 End------------------------------

function ChatUI.Main(parameter)

    ChatUI.CurrentSelectChannel = ChannelIDDefine.Current
    lockIndexTable = {}
    recordBtnGuid2Channel = {}
    recordName2BtnGuid = {}
    CrossServerChat = UIDefine.IsFunctionOrVariableExist(LD, "IsSupportCrossServerChat") and LD.IsSupportCrossServerChat()
    local panel = GUI.WndCreateWnd("ChatUI", "ChatUI", 0, 0, eCanvasGroup.Main)
    GuidCacheUtil.BindName(panel, "panelBg")
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.CreateSafeArea(panel)

    local name = "chatBg_LeftBottm"
    local chatBg_LeftBottm = GUI.ImageCreate(panel, name, "1800200010", 4, -18, false, 430, 135)
    GuidCacheUtil.BindName(chatBg_LeftBottm, name)
    SetAnchorAndPivot(chatBg_LeftBottm, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)

    --好友聊天按钮
    local friendChatBtn = GUI.ButtonCreate(chatBg_LeftBottm, "friendChatBtn", "1800202210", 15, 80, Transition.ColorTint)
    GuidCacheUtil.BindName(friendChatBtn, "friendChatBtn")
    SetAnchorAndPivot(friendChatBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(friendChatBtn, UCE.PointerClick, "ChatUI", "OnFriendChatBtnClick")

    -- 未读邮件数量
    local unreadMailCountBg = GUI.ImageCreate(friendChatBtn, "unreadMailCountBg", "1800207280", 20, -29)
    SetAnchorAndPivot(unreadMailCountBg, UIAnchor.Center, UIAroundPivot.Center)
    GuidCacheUtil.BindName(unreadMailCountBg, "unreadMailCountBg")
    GUI.SetVisible(unreadMailCountBg, false)

    local unreadMailCount = GUI.CreateStatic(unreadMailCountBg, "unreadMailCount", "99", 0, 0, 50, 25)
    SetAnchorAndPivot(unreadMailCount, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(unreadMailCount, UIDefine.WhiteColor)
    GUI.StaticSetAlignment(unreadMailCount, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(unreadMailCount, true)
    GUI.StaticSetFontSize(unreadMailCount, UIDefine.FontSizeSS)
    GUI.SetOutLine_Color(unreadMailCount, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(unreadMailCount, 1)

    --聊天按钮
    local chatBtn = GUI.ButtonCreate(chatBg_LeftBottm, "chatBtn", "1800202220", 85, 80, Transition.ColorTint)
    SetAnchorAndPivot(chatBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --队伍语音按钮
    local teamVoiceBtn = GUI.ButtonCreate(chatBg_LeftBottm, "teamVoiceBtn", "1800202200", 155, 80, Transition.ColorTint)
    SetAnchorAndPivot(teamVoiceBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    ChatUI.RegisterRecordEvent(teamVoiceBtn, ChannelIDDefine.Team)

    --世界语音按钮
    local worldVoiceBtn = GUI.ButtonCreate(chatBg_LeftBottm, "worldVoiceBtn", "1800202190", 225, 80, Transition.ColorTint)
    SetAnchorAndPivot(worldVoiceBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    ChatUI.RegisterRecordEvent(worldVoiceBtn, ChannelIDDefine.World)

    --实名认证按钮
    local realNameBtn = GUI.ButtonCreate(chatBg_LeftBottm, "realNameBtn", "1800302190", 375, 80, Transition.ColorTint,"",58,58,false)
    GuidCacheUtil.BindName(realNameBtn, "realNameBtn")
    SetAnchorAndPivot(realNameBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(realNameBtn, UCE.PointerClick, "ChatUI", "OnRealNameBtn")
    local realNameImg = GUI.ImageCreate(realNameBtn, "realNameImg", "1800307060", 1, 0)
    UILayout.SetSameAnchorAndPivot(realNameImg, UILayout.Center)
    GUI.SetScale(realNameImg, Vector3.New(1.4,1.6,1.4))

    local realNameTxt =GUI.CreateStatic(realNameBtn, "realNameTxt", "实名", 0,40,70,50,"fzcy")
    UILayout.SetSameAnchorAndPivot(realNameTxt, UILayout.Center)
    GUI.StaticSetAlignment(realNameTxt, TextAnchor.UpperCenter)
    GUI.StaticSetFontSize(realNameTxt,UIDefine.FontSizeSS)
    GUI.StaticSetIsGradientColor(realNameTxt,true)
    GUI.StaticSetGradient_ColorTop(realNameTxt,Color.New(341/255,238/255,249/255,255/255))
    GUI.StaticSetGradient_ColorBottom(realNameTxt,Color.New(213/255,196/255,128/255,255/255))
    GUI.SetIsOutLine(realNameTxt,true)
    GUI.SetOutLine_Setting(realNameTxt,OutLineSetting.OutLine_NpcDialogFullTip)
    GUI.SetOutLine_Distance(realNameTxt,1)
    GUI.SetOutLine_Color(realNameTxt,Color.New(113/255,86/255,70/255,255/255))
    realNameTxt:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(realNameTxt, true)

    local state = CL.GetRealNameState()
    ChatUI.ShowRealNameBtn(state~=0 and state~=1)


	--客服按钮
    local CustomerServiceBtn = GUI.ButtonCreate(chatBg_LeftBottm, "CustomerServiceBtn", "1800902060", 295, 80, Transition.ColorTint,"",58,58,false)
    GuidCacheUtil.BindName(CustomerServiceBtn, "CustomerServiceBtn")
    SetAnchorAndPivot(CustomerServiceBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(CustomerServiceBtn, UCE.PointerClick, "ChatUI", "OnCustomerServiceBtnClick")
	GUI.SetVisible(CustomerServiceBtn,false)

    local CustomerServiceTxt =GUI.CreateStatic(CustomerServiceBtn, "CustomerServiceTxt", "客服", 0,40,70,50,"101")
    UILayout.SetSameAnchorAndPivot(CustomerServiceTxt, UILayout.Center)
    GUI.StaticSetAlignment(CustomerServiceTxt, TextAnchor.UpperCenter)
    GUI.StaticSetFontSize(CustomerServiceTxt,UIDefine.FontSizeSS)
    GUI.StaticSetIsGradientColor(CustomerServiceTxt,true)
    GUI.StaticSetGradient_ColorTop(CustomerServiceTxt,Color.New(341/255,238/255,249/255,255/255))
    GUI.StaticSetGradient_ColorBottom(CustomerServiceTxt,Color.New(213/255,196/255,128/255,255/255))
    GUI.SetIsOutLine(CustomerServiceTxt,true)
    GUI.SetOutLine_Setting(CustomerServiceTxt,OutLineSetting.OutLine_NpcDialogFullTip)
    GUI.SetOutLine_Distance(CustomerServiceTxt,1)
    GUI.SetOutLine_Color(CustomerServiceTxt,Color.New(113/255,86/255,70/255,255/255))
    CustomerServiceTxt:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(CustomerServiceTxt, true)
	
    --拉伸按钮
    local flexBtn = GUI.ButtonCreate(chatBg_LeftBottm, "flexBtn", "1800202250", -25, -25, Transition.ColorTint)
    SetAnchorAndPivot(flexBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetEulerAngles(flexBtn, Vector3.New(0, 0, 180))

    --设置按钮
    local setBtn = GUI.ButtonCreate(chatBg_LeftBottm, "setBtn", "1800202240", -5, 5, Transition.ColorTint)
    SetAnchorAndPivot(setBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)

    GUI.RegisterUIEvent(flexBtn, UCE.PointerClick, "ChatUI", "OnflexBtnClick")
    GUI.RegisterUIEvent(setBtn, UCE.PointerClick, "ChatUI", "OnSetBtnClick")
    GUI.RegisterUIEvent(chatBtn, UCE.PointerClick, "ChatUI", "OnChatBtnClick")

    ChatUI.CreateChatScroll_LefftBottm()

    local operateMenuCover = GUI.ImageCreate(panel, "operateMenuCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    GuidCacheUtil.BindName(operateMenuCover, "operateMenuCover")
    operateMenuCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(operateMenuCover, true)
    GUI.RegisterUIEvent(operateMenuCover, UCE.PointerClick, "ChatUI", "OnOperateMenuCoverClick")
    GUI.SetVisible(operateMenuCover, false)
    SetAnchorAndPivot(operateMenuCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(operateMenuCover, UIDefine.Transparent)

    ChatUI.CreateChatBg()

    ChatUI.RegisterMessage()
end

function ChatUI.ShowRealNameBtn(show)
    local realNameBtn = GuidCacheUtil.GetUI("realNameBtn")
    if realNameBtn then
        GUI.SetVisible(realNameBtn, show)
    end
end

function ChatUI.OnMailUpdate()
    local unreadMailCountBg = GuidCacheUtil.GetUI("unreadMailCountBg")
    local count = LD.GetMailTotalRedPointCount()
    if count > 0 then
        GUI.SetVisible(unreadMailCountBg, true)

        local data = TweenData.New()
        data.Type = GUITweenType.DOScale
        data.Duration = 1.5
        data.From = Vector3.New(1, 1, 1)
        data.To = Vector3.New(1.2, 1.2, 1.2)
        data.LoopType = UITweenerStyle.Loop
        GUI.DOTween(unreadMailCountBg, data)

        local unreadMailCount = GUI.GetChild(unreadMailCountBg, "unreadMailCount")
        GUI.StaticSetText(unreadMailCount, count)
    else
        GUI.SetVisible(unreadMailCountBg, false)
        GUI.StopTween(unreadMailCountBg, GUITweenType.DOScale)
    end
end

function ChatUI.RegisterRecordEvent(btn, channelId)
    if not btn then
        return
    end
    if channelId then
        recordBtnGuid2Channel[GUI.GetGuid(btn)] = channelId
    end
    btn:RegisterEvent(UCE.PointerDown)
    btn:RegisterEvent(UCE.PointerUp)
    btn:RegisterEvent(UCE.PointerEnter)
    btn:RegisterEvent(UCE.PointerExit)

    GUI.RegisterUIEvent(btn, UCE.PointerDown, "ChatUI", "OnRecordBtnDown")
    GUI.RegisterUIEvent(btn, UCE.PointerUp, "ChatUI", "OnRecordBtnPointUp")
    GUI.RegisterUIEvent(btn, UCE.PointerEnter, "ChatUI", "OnRecordBtnPointEnter")
    GUI.RegisterUIEvent(btn, UCE.PointerExit, "ChatUI", "OnRecordBtnPointExit")
end

-- 注册GM消息
function ChatUI.RegisterMessage()
    for k, v in ipairs(messageEventList) do
        CL.UnRegisterMessage(v[1], "ChatUI", v[2])
        CL.RegisterMessage(v[1], "ChatUI", v[2])
    end
end

-- 窗口OnShow事件的处理
function ChatUI.OnShow(parameter)
    if GUI.GetWnd("ChatUI") == nil then
        return
    end

    local chatBg_LeftBottm = GuidCacheUtil.GetUI("chatBg_LeftBottm")
    if chatBg_LeftBottm ~= nil then
        GUI.SetVisible(chatBg_LeftBottm, true)
    end

    ChatUI.OnCloseBtnClick_ChatBg()
    GUI.SetVisible(GUI.GetWnd("ChatUI"), true)
    if parameter then
        ChatUI.OnChatBtnClick()
        local selectChannelID = UIDefine.GetParameter1(parameter)
        local chatBg = GuidCacheUtil.GetUI("chatBg")
        for i = 1, #btnList do
            if selectChannelID == btnList[i][11] then
                local channelBtn = GUI.GetChild(chatBg, btnList[i][2])
                GUI.CheckBoxSetCheck(channelBtn, true)
            end
        end
        ChatUI.OnClickChannelHandle(nil, selectChannelID)
        return
    end

    ChatUI.OnRecvChatMessage(nil, "openChatUI")
    ChatUI.OnRefreshGuildNoticeFlag()
end

function ChatUI.ShowTrumpetChat(parameter)
    local chatBg_LeftBottm = GuidCacheUtil.GetUI("chatBg_LeftBottm")
    if chatBg_LeftBottm == nil then
        return
    end

    local friendChatBtn = GUI.GetChild(chatBg_LeftBottm, "friendChatBtn")
    local teamVoiceBtn = GUI.GetChild(chatBg_LeftBottm, "teamVoiceBtn")
    local worldVoiceBtn = GUI.GetChild(chatBg_LeftBottm, "worldVoiceBtn")
    local chatBtn = GUI.GetChild(chatBg_LeftBottm, "chatBtn")
    local trumpetChatBg = GUI.GetChild(chatBg_LeftBottm, "trumpetChatBg")

    if parameter then
        local msgData = CL.GetChannelMsgByIndex(ChannelIDDefine.Trumpet, 0, true)
        if msgData == nil then
            return
        end

        if trumpetChatBg == nil then
            trumpetChatBg = GUI.ImageCreate(chatBg_LeftBottm, "trumpetChatBg", "1800200010", 0, 0, false, 430, 0)
            SetAnchorAndPivot(trumpetChatBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

            local channelLabel = GUI.ImageCreate(trumpetChatBg, "channelLabel", "1800204080", 5, 5)
            local txt = GUI.RichEditCreate(trumpetChatBg,"txt", "", 5, 5,  420, 22)
            SetAnchorAndPivot(channelLabel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(txt, fontSize_Little)
            GUI.SetColor(txt, trumpetChatColor)
            txt:RegisterEvent(UCE.PointerClick)
            GUI.RegisterUIEvent(txt, UCE.PointerClick, "ChatUI", "OnUrlClick_RichTxt_LeftBottom")

            local recordGroup = GUI.GroupCreate(trumpetChatBg, "recordGroup", 0, 0, 200, 28)
            SetAnchorAndPivot(recordGroup, UIAnchor.Left, UIAroundPivot.Left)
            GUI.SetVisible(recordGroup, false)
            local tipsBtn = GUI.ButtonCreate(recordGroup, "tipsBtn", "1800900100", 0, 0, Transition.None)
            SetAnchorAndPivot(tipsBtn, UIAnchor.Left, UIAroundPivot.Left)
            local tips2 = GUI.ImageCreate(tipsBtn, "tips2", "1800900110", 0, 0)
            SetAnchorAndPivot(tips2, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(tips2, false)

            local recordBtn = GUI.ButtonCreate(recordGroup, "recordBtn", "1800900090", 30, 0, Transition.ColorTint, "", 140, 23, false)
            SetAnchorAndPivot(recordBtn, UIAnchor.Left, UIAroundPivot.Left)
            GUI.ButtonSetTextColor(recordBtn, colorType_DarkYellow)
            GUI.RegisterUIEvent(recordBtn, UCE.PointerClick, "ChatUI", "OnPlayRecordBtnClick")
        else
            GUI.SetVisible(trumpetChatBg, true)
        end


        local txt = GUI.GetChild(trumpetChatBg, "txt")
        local channelLabel = GUI.GetChild(trumpetChatBg, "channelLabel")
        --获取表情所在的位置，如果在第一行，改变频道标签的位置

        local faceIndex = ChatUI.GetFaceIndex(msgData.message)
        if faceIndex ~= nil then
            if faceIndex < 48 then
                GUI.SetPositionY(channelLabel, 16)
            else
                GUI.SetPositionY(channelLabel, 5)
            end
        else
            GUI.SetPositionY(channelLabel, 5)
        end
        ChatUI.CreateTrumpetRecord(trumpetChatBg, msgData)
        local height = GUI.RichEditGetPreferredHeight(txt)
        GUI.SetHeight(txt, height)
        GUI.SetHeight(trumpetChatBg, height + 10)

        GUI.SetPositionY(friendChatBtn, -(height + 15 + 80))
        GUI.SetPositionY(teamVoiceBtn, -(height + 15 + 80))
        GUI.SetPositionY(worldVoiceBtn, -(height + 15 + 80))
        GUI.SetPositionY(chatBtn, -(height + 15 + 80))
        GUI.SetPositionY(trumpetChatBg, -(height + 15))
        UILayout.SetUrlColor(txt, true)
        if TrumpetTimer then
            TrumpetTimer:Stop()
            TrumpetTimer:Reset(ChatUI.ShowTrumpetChat, TrumpetDeleteTime, 1)
        else
            TrumpetTimer = Timer.New(ChatUI.ShowTrumpetChat, TrumpetDeleteTime, 1)
        end
        TrumpetTimer:Start()
    else
        if trumpetChatBg ~= nil then
            GUI.SetVisible(trumpetChatBg, false)
        end
        GUI.SetPositionY(friendChatBtn, -80)
        GUI.SetPositionY(teamVoiceBtn, -80)
        GUI.SetPositionY(worldVoiceBtn, -80)
        GUI.SetPositionY(chatBtn, -80)
        if TrumpetTimer then
            TrumpetTimer:Stop()
            TrumpetTimer = nil
        end
    end
end

function ChatUI.CreateTrumpetRecord(parent, msgData)
    local tmpName = "#UILINK<WND:playerName,STR:[" .. msgData.role_name .. "]>#"
    local recordGroup = GUI.GetChild(parent, "recordGroup")
    local txt = GUI.GetChild(parent, "txt")

    local fileName, time = GlobalUtils.GetRecordInfo(msgData.message)
    if fileName == nil or time == nil then
        GUI.SetVisible(recordGroup, false)
        GUI.StaticSetText(txt, "<color=#ffffff00>占位  </color>" .. tmpName .. msgData.message)

        GUI.SetData(recordGroup, "RecordChannel", nil)
        GUI.SetData(recordGroup, "RecordFileName", nil)
    else
        GUI.StaticSetText(txt, "<color=#ffffff00>占位  </color>" .. tmpName)
        local nameLen = string.len(msgData.role_name)
        local recordBtn = GUI.GetChild(recordGroup, "recordBtn")

        GUI.ButtonSetText(recordBtn, time .. "秒")
        GUI.SetPositionX(recordGroup, 50 + nameLen / 2 * 20 + 15)
        GUI.SetVisible(recordGroup, true)

        GUI.SetData(recordGroup, "RecordChannel", tostring(channelType[4][1]))
        GUI.SetData(recordGroup, "RecordFileName", fileName)
        GUI.SetData(recordGroup, "RecordTime", time)

        --ChatUI.AddPlayRecordBtnGuid(nil, channelType[4][1], GUI.GetGuid(recordBtn), fileName)
    end
end

-- 点击聊天按钮的处理，打开左侧聊天界面
function ChatUI.OnChatBtnClick(guid)
    local chatBg_LeftBottm = GuidCacheUtil.GetUI("chatBg_LeftBottm")
    GUI.SetVisible(chatBg_LeftBottm, false)

    ChatUI.SetChatScroll(false)

    local chatBg = GuidCacheUtil.GetUI("chatBg")
    if not chatBg then
        ChatUI.CreateChatBg()
    end
    GUI.SetVisible(chatBg, true)

    ChatUI.ShowWorldQuestionUI(ChatUI.CurrentSelectChannel)
	
    --初始化锁屏状态
    ChatUI.OnInitLockState()
    --初始化锁屏index
    ChatUI.InitLockIndex()
    --刷新消息
    ChatUI.OnRefreshChatMsg()
    --刷新帮派消息图标
    ChatUI.OnRefreshGuildNoticeFlag()
end

function ChatUI.OnRefreshGuildNoticeFlag()
    local notice = LD.HaveNewGuildNotice()
    ChatUI.OnShowGuildNoticeFlag(ChatUI.CurrentSelectChannel == ChannelIDDefine.Faction and notice)
    local guildBtn = GuidCacheUtil.GetUI("factionChatBtn_3")
    if guildBtn then
        GUI.SetRedPointVisable(guildBtn, notice)
    end
end

function ChatUI.SetChatScroll(needPullDown)
    local height
    local posY
    if needPullDown then
        height = 435
        posY = 175
    else
        height = 610
        posY = 2
    end
    local chatScroll = GuidCacheUtil.GetUI("chatScroll")
    if chatScroll ~= nil then
        GUI.SetHeight(chatScroll, height)
        GUI.SetPositionY(chatScroll, posY)
    end
end

-- 点击输入框
function ChatUI.OnInputFieldClick(guid)
    ChatUI.CloseEmojPanel()
end

function ChatUI.OnInputFieldEndEdit(guid)
    local input = GUI.GetByGuid(guid)
    local txt = GUI.GetInputText(input)
    local value = string.find(txt, "#INVCODESTART<(.+)>#")
    if value ~= nil then
        test(value)
    end
end

function ChatUI.CreateChatBg()
    local name = "chatBg"
    local chatBg = GuidCacheUtil.GetUI(name)
    if chatBg == nil then
        local panel = GUI.GetWnd("ChatUI")
        local panelHeight = GUI.GetHeight(panel)
        chatBg = GUI.ImageCreate(panel, name, "1800900010", -8, -7, false, 555, 720)
        GuidCacheUtil.BindName(chatBg, name)
        SetAnchorAndPivot(chatBg, UIAnchor.Left, UIAroundPivot.Left)
        GUI.SetIsRaycastTarget(chatBg, true)

        local closeBtn = GUI.ButtonCreate(chatBg, "closeBtn", "1800902040", 37, 0, Transition.None)
        SetAnchorAndPivot(closeBtn, UIAnchor.Right, UIAroundPivot.Right)

        local name = "recordBtn"
        local recordBtn = GUI.ButtonCreate(chatBg, name, "1800902020", 20, 14, Transition.ColorTint, "", 60, 60, false)
        GuidCacheUtil.BindName(recordBtn, name)
        SetAnchorAndPivot(recordBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        ChatUI.RegisterRecordEvent(recordBtn)

        local name = "inputField"
        local inputField = GUI.EditCreate(chatBg, name, "1800001040", "请输入文字", 90, 16, Transition.ColorTint, "system", 280, 48, 10)
        GuidCacheUtil.BindName(inputField, name)
        SetAnchorAndPivot(inputField, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.EditSetLabelAlignment(inputField, TextAnchor.MiddleCenter)
        GUI.EditSetFontSize(inputField, fontSize_BigOne)
        GUI.EditSetTextColor(inputField, colorType_DarkYellow)
        GUI.SetPlaceholderTxtColor(inputField, colorType_Input)
        GUI.RegisterUIEvent(inputField, UCE.PointerClick, "ChatUI", "OnInputFieldClick")
        --表情按钮
        local name = "emojBtn"
        local emojBtn = GUI.ButtonCreate(chatBg, name, "1800902010", -135, 18, Transition.ColorTint)
        GuidCacheUtil.BindName(emojBtn, name)
        SetAnchorAndPivot(emojBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)

        --发送消息按钮
        local name = "sendMsgBtn"
        local sendMsgBtn = GUI.ButtonCreate(chatBg, name, "1800902031", -15, 12, Transition.ColorTint, "<color=#" .. fontColor2 .. "><size=" .. fontSize .. ">" .. "发送" .. "</size></color>", 110, 55, false)
        GuidCacheUtil.BindName(sendMsgBtn, name)
        SetAnchorAndPivot(sendMsgBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)

        --聊天显示区域大背景
        local name = "chatContentBg"
        local chatContentBg = GUI.ImageCreate(chatBg, name, "1800400200", -15, 75, false, 440, 620)
        GuidCacheUtil.BindName(chatContentBg, name)
        SetAnchorAndPivot(chatContentBg, UIAnchor.TopRight, UIAroundPivot.TopRight)

        local group = GUI.GroupCreate(chatBg, "channelToggleGroup", 0, 0, GUI.GetWidth(chatBg), GUI.GetHeight(chatBg))
        GUI.SetIsToggleGroup(group, true)
        for i = 1, #btnList do
            local data = btnList[i]
            local subTab = GUI.CheckBoxCreate(chatBg, data[2], data[3], data[4], 18, 35 + i * 50, Transition.ColorTint, false, 75, 40)
            SetAnchorAndPivot(subTab, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GuidCacheUtil.BindName(subTab, data[2])
            GUI.SetToggleGroupGuid(subTab, GUI.GetGuid(group))
            local text = GUI.CreateStatic(subTab, "Text", string.format("<color=#%s><size=%s>%s</size></color>", fontColor2, fontSize, data[1]), 0, 1, 75, 40, "system", true)
            SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
            GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
            GUI.SetColor(text, UIDefine.BrownColor)
            GUI.AddRedPoint(subTab, UIAnchor.TopLeft)
            GUI.SetRedPointVisable(subTab, false)
            --GUI.RegisterUIEvent(subTab, UCE.PointerClick, "ChatUI", data[6])
            GUI.RegisterUIEvent(subTab, UCE.BeforeClick, "ChatUI", data[5])
            if data[11] == ChatUI.CurrentSelectChannel then
                GUI.CheckBoxSetCheck(subTab, true)
            end
        end

        local lockTxt = GUI.CreateStatic(chatBg, "lockTxt", "锁屏", 20, -90, 50, 30, "system", true)
        SetAnchorAndPivot(lockTxt, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.StaticSetFontSize(lockTxt, fontSize_BigOne)
        GUI.SetColor(lockTxt, colorType_DarkYellow)

        --帮派通知图标
        local guildFlagNoticeIcon = GUI.ImageCreate(chatBg, "guildFlagNoticeIcon", "1800202360", 201, 91, false, 273, 38)
        GuidCacheUtil.BindName(guildFlagNoticeIcon, "guildFlagNoticeIcon")
        SetAnchorAndPivot(guildFlagNoticeIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetIsRaycastTarget(guildFlagNoticeIcon, true)
        guildFlagNoticeIcon:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(guildFlagNoticeIcon, UCE.PointerClick, "ChatUI", "OnClickGuildFlagNoticeIcon")
        local icon = GUI.ImageCreate(guildFlagNoticeIcon, "icon", "1900000390", -155, -18)
        SetAnchorAndPivot(icon, UIAnchor.Top, UIAroundPivot.Top)
        GUI.SetIsRaycastTarget(icon, true)
        icon:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(icon, UCE.PointerClick, "ChatUI", "OnClickGuildFlagNoticeIcon")
        local txt = GUI.CreateStatic(guildFlagNoticeIcon, "txt", "有新的帮派通知，点击查看", 82, 1, 400, 30, "system", true)
        SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        GUI.SetColor(txt, UIDefine.BrownColor)
        GUI.SetVisible(guildFlagNoticeIcon, false)

        --锁屏按钮
        local name = "lockBtn"
        local lockBtn = GUI.ButtonCreate(chatBg, name, "1800702090", 10, -45, Transition.None)
        GuidCacheUtil.BindName(lockBtn, name)
        SetAnchorAndPivot(lockBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)

        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "ChatUI", "OnCloseBtnClick_ChatBg")
        GUI.RegisterUIEvent(lockBtn, UCE.PointerClick, "ChatUI", "OnLockBtnClick")
        GUI.RegisterUIEvent(sendMsgBtn, UCE.PointerClick, "ChatUI", "OnSendMsgBtnClick")
        GUI.RegisterUIEvent(emojBtn, UCE.PointerClick, "ChatUI", "OnEmojBtnClick_ChatBg")
        ChatUI.CreateChatScroll()

        GUI.SetVisible(chatBg, false)

        --if not WorldQuestionUI then
        --    require "WorldQuestionUI"
        --end

    end
end

function ChatUI.OnClickGuildFlagNoticeIcon(guid)
    ChatUI.OnShowGuildNoticeFlag(false)
    local guildBtn = GuidCacheUtil.GetUI("factionChatBtn_3")
    if guildBtn then
        GUI.SetRedPointVisable(guildBtn, false)
    end
    local info = LD.GetGuildNotice()
    LD.ClearGuildNoticeFlag()
    GlobalUtils.ShowBoxMsg1Btn("帮派通知", info, "ChatUI", "确定")
    --同步已读状态
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ReadNotice")
end

function ChatUI.CheckAllChannel(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.All)
end

function ChatUI.CheckSystemChannel(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.System)
end

function ChatUI.CheckCrossServerChannel(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.CrossServer)
end

function ChatUI.CheckWorldChannel(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.World)
end

function ChatUI.CheckTrumpetChannel(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.Trumpet)
end

function ChatUI.CheckCurrentChannel(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.Current)
end

function ChatUI.CheckSchoolChannel(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.School)
end

function ChatUI.CheckFactionChannel(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.Faction)
end

function ChatUI.CheckTeamChannel(guid)
    --print("当前没有队伍" .. guid)
    --local temp = GUI.GetByGuid(guid)
    --GUI.SetCanBeChecked(temp, false)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.Team)
end

function ChatUI.CheckRecruitChannel(guid)
    --print("没有招募的队伍" .. guid)
    --local temp = GUI.GetByGuid(guid)
    --GUI.SetCanBeChecked(temp, false)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.Recruit)
end

function ChatUI.OnClickSystemAll(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.System)
end

function ChatUI.OnClickSystemPersonal(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.System_Personal)
end

function ChatUI.OnClickSystemSystem(guid)
    ChatUI.OnClickChannelHandle(guid, ChannelIDDefine.System_System)
end

----------------------------------------------------start 点击各个频道的相应事件 start---------------------------------------------------

function ChatUI.OnShowGuildNoticeFlag(show)
    local guildFlagNoticeIcon = GuidCacheUtil.GetUI("guildFlagNoticeIcon")
    if guildFlagNoticeIcon then
        GUI.SetVisible(guildFlagNoticeIcon, show)
    end
end

function ChatUI.OnClickChannelHandle(guid, channelId)
    ChatUI.SetChatScroll(false)
    ChatUI.ShowWorldQuestionUI(channelId)

    local lastSelectChannel = ChatUI.CurrentSelectChannel
    if lastSelectChannel == channelId then
        -- 相同的频道
        return
    end
    recordName2BtnGuid = {}
    ChatUI.CurrentSelectChannel = channelId
    ChatUI.OnRefreshGuildNoticeFlag()
    local chatScroll = GuidCacheUtil.GetUI("chatScroll")
    if chatScroll ~= nil then
        local curCount = CL.GetMsgCountByChannel(ChatUI.CurrentSelectChannel)
        GUI.LoopScrollRectSetTotalCount(chatScroll, curCount)
        GUI.LoopScrollRectRefreshCells(chatScroll)
    end

    local chatBg = GuidCacheUtil.GetUI("chatBg")
    --local btn = GUI.GetByGuid(guid)
    --local btnSelectImage = GUI.GetChild(btn, "btnSelectImage")
    --GUI.SetVisible(btnSelectImage, true)

    --全部频道上方，屏蔽频道按钮
    local shieldChatBtn = GuidCacheUtil.GetUI("shieldChatBtn")
    local teamPanelBtn = GuidCacheUtil.GetUI("teamPanelBtn")

    --初始化锁屏标记
    ChatUI.InitLockIndex()
    local name = "SystemToggleGroup"
    local group = GuidCacheUtil.GetUI(name)
    local currentState = channelId == ChannelIDDefine.System_Personal or channelId == ChannelIDDefine.System_System or channelId == ChannelIDDefine.System
    if currentState then
        if not group then
            group = GUI.GroupCreate(chatBg, "SystemToggleGroup", 0, 0, GUI.GetWidth(chatBg), GUI.GetHeight(chatBg))
            GuidCacheUtil.BindName(group, name)
            GUI.SetIsToggleGroup(group, true)
            for i = 1, #sysChatBtn do
                local data = sysChatBtn[i]
                local subTab = GUI.CheckBoxCreate(group, data[2], data[3], data[4], data[7], data[8], Transition.ColorTint, false, 145, 50)
                GuidCacheUtil.BindName(subTab, data[2])
                SetAnchorAndPivot(subTab, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                GUI.SetToggleGroupGuid(subTab, GUI.GetGuid(group))
                local text = GUI.CreateStatic(subTab, "Text", string.format("<color=#%s><size=%s>%s</size></color>", fontColor2, fontSize, data[1]), 0, 0, 145, 45, "system", true)
                SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
                GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
                GUI.SetColor(text, UIDefine.BrownColor)
                GUI.RegisterUIEvent(subTab, UCE.BeforeClick, "ChatUI", data[6])
                if i == 1 then
                    -- 默认选中当前频道
                    GUI.CheckBoxSetCheck(subTab, true)
                end
            end
        else
            GUI.SetVisible(group, true)
            GUI.CheckBoxSetCheck(GuidCacheUtil.GetUI(sysChatBtn[1][2]), true)
        end
    else
        if group then
            GUI.SetVisible(group, false)
        end
    end

    if ChatUI.CurrentSelectChannel == ChannelIDDefine.All then
        if shieldChatBtn == nil then
            local name = "shieldChatBtn"
            shieldChatBtn = GUI.ButtonCreate(chatBg, name, "1800402030", 40, 15, Transition.ColorTint, "<color=#" .. fontColor3 .. "><size=" .. fontSize_BigTwo .. ">" .. "频道信息屏蔽" .. "</size></color>", 200, 50, false)
            GuidCacheUtil.BindName(shieldChatBtn, name)
            UILayout.SetSameAnchorAndPivot(shieldChatBtn, UILayout.Top)
            GUI.RegisterUIEvent(shieldChatBtn, UCE.PointerClick, "ChatUI", "OnSetBtnClick")

        else
            GUI.SetVisible(shieldChatBtn, true)
        end
    else
        if shieldChatBtn then
            GUI.SetVisible(shieldChatBtn, false)
        end
    end

    --招募频道
    if ChatUI.CurrentSelectChannel == ChannelIDDefine.Recruit then
        if teamPanelBtn == nil then
            local name = "teamPanelBtn"
            teamPanelBtn = GUI.ButtonCreate(chatBg, name, "1800402030", 40, 15, Transition.ColorTint, "<color=#" .. fontColor3 .. "><size=" .. fontSize_BigTwo .. ">" .. "组队平台" .. "</size></color>", 200, 50, false)
            GuidCacheUtil.BindName(teamPanelBtn, name)
            UILayout.SetSameAnchorAndPivot(teamPanelBtn, UILayout.Top)
            --local btnSelectImage = GUI.ImageCreate(teamPanelBtn, "btnSelectImage", "1800402032", 0, 0, false, 180, 45)
            --SetAnchorAndPivot(btnSelectImage, UIAnchor.Center, UIAroundPivot.Center)
            --GUI.SetDepth(btnSelectImage, 0)
            GUI.RegisterUIEvent(teamPanelBtn, UCE.PointerClick, "ChatUI", "OnTeamPanelBtnClick")
        else
            GUI.SetVisible(teamPanelBtn, true)
        end
    else
        if teamPanelBtn then
            GUI.SetVisible(teamPanelBtn, false)
        end
    end

    --if str[2] == "10" then
    --    CL.SendNotify(NOTIFY.SubmitForm, "消息跳转", "WorldQuestionServer")
    --end
    local inputField = GuidCacheUtil.GetUI("inputField")
    local sendMsgBtn = GuidCacheUtil.GetUI("sendMsgBtn")
    local emojBtn = GuidCacheUtil.GetUI("emojBtn")
    local recordBtn = GuidCacheUtil.GetUI("recordBtn")
    local state = ChatUI.CurrentSelectChannel == ChannelIDDefine.All or ChatUI.CurrentSelectChannel == ChannelIDDefine.Recruit
            or ChatUI.CurrentSelectChannel == ChannelIDDefine.System or ChatUI.CurrentSelectChannel == ChannelIDDefine.System_Personal
            or ChatUI.CurrentSelectChannel == ChannelIDDefine.System_System
    GUI.SetVisible(inputField, not state)
    GUI.SetVisible(sendMsgBtn, not state)
    GUI.SetVisible(emojBtn, not state)
    GUI.SetVisible(recordBtn, not state)

end
------------------------------------------------------end 点击各个频道的相应事件 end-----------------------------------------------------

function ChatUI.OnchatBg_LeftBottm_Click(guid)
    ChatUI.OnChatBtnClick(nil, nil)
    --ChatUI.CreateChatBg()
end

local CurPressBtnGuid = nil
-- 按下录音按钮
function ChatUI.OnRecordBtnDown(guid)
    local channelId = recordBtnGuid2Channel[guid] or ChatUI.CurrentSelectChannel
    if channelId == ChannelIDDefine.Team then
        local teamState = LD.GetRoleInTeamState()
        if teamState == 0 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "您没有加入队伍，不能使用队伍频道")
            ChatUI.IsRecordBtnExit = true
            return
        end
    end

    if GlobalUtils.StartRecord() then
        CurPressBtnGuid = guid
        CurRecordChannel = channelId
        ChatUI.IsRecordBtnExit = false
    else
        ChatUI.IsRecordBtnExit = true
    end
end

ChatUI.IsRecordBtnExit = false
function ChatUI.OnRecordBtnPointEnter(guid)
    if CurPressBtnGuid ~= guid then
        return
    end
    GlobalUtils.RecordBtnPointerHandle(true)
    ChatUI.IsRecordBtnExit = false
end

function ChatUI.OnRecordBtnPointExit(guid)
    if CurPressBtnGuid ~= guid then
        return
    end
    GlobalUtils.RecordBtnPointerHandle(false)
    ChatUI.IsRecordBtnExit = true
end

-- 录音按钮抬起
function ChatUI.OnRecordBtnPointUp(guid)
    CurPressBtnGuid = nil
    GlobalUtils.RecordFinishHandle(ChatUI.IsRecordBtnExit)
    if ChatUI.IsRecordBtnExit then
        CurRecordChannel = nil
    end
end

function ChatUI.OnUploadRecordSuccess(fileName, time)
    ChatUI.SendRecordMsg(fileName, time)
end

function ChatUI.SendRecordMsg(fileName, time)
    if CurRecordChannel then
        local tmpMsg = GlobalUtils.MakeUpRecordMsg(fileName, time)
        CL.SendChatMsg(CurRecordChannel, tmpMsg, false)
        CurRecordChannel = nil
    end
end

function ChatUI.OnRecordPlayStart(fileName)
    ChatUI.PlayRecordAnimation(fileName)
end

function ChatUI.OnItemQueryNtf(itemGuid)
    if CurItemQueryGuid == itemGuid then
        CurItemQueryGuid = nil
        local itemData = LD.GetQueryItemData()
        if itemData == nil then
            return
        end
        local panelBg = GuidCacheUtil.GetUI("panelBg")
        if not panelBg then
            return
        end
        GUI.SetVisible(GuidCacheUtil.GetUI("operateMenuCover"), true)
        local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", 0, 0, 55)
        GuidCacheUtil.BindName(itemTips, "itemTips")
    end
end

function ChatUI.OnPetQueryNtf(petGuid)
    if CurItemQueryGuid == petGuid then
        CurItemQueryGuid = nil
        local petData = LD.GetQueryPetData()
        if petData == nil then
            return
        end
        GUI.OpenWnd("PetInfoUI")
        PetInfoUI.SetPetData(petData)
    end
end

function ChatUI.OnPlayerQueryNtf(playerName)
    --print("查看：", playerName)
    if not CurQueryPlayerName or playerName ~= CurQueryPlayerName then
        return
    end
    CurQueryPlayerName = nil
    local playerData = LD.GetQueryPlayerData()
    if not playerData then
        return
    end
    if RoleClickPopMenu then
        local type = 0
        local templateID = tonumber(tostring(CL.GetAttribute(playerData.attrs, RoleAttr.RoleAttrRole, 1)))
        local sn = tostring( tonumber(tostring(CL.GetAttribute(playerData.attrs, RoleAttr.RoleAttrSN, 0))) + 1000000)
        local roleConfig = DB.GetRole(templateID)
        local headIcon = tostring(roleConfig.Head)
        local schoolConfig = DB.GetSchool(tonumber(tostring(CL.GetAttribute(playerData.attrs, RoleAttr.RoleAttrJob1, 1))))
        local schoolIcon = tostring(schoolConfig.Icon)
        local level = tostring(CL.GetAttribute(playerData.attrs, RoleAttr.RoleAttrLevel, 0))
        local reincarnation = tostring(CL.GetAttribute(playerData.attrs, RoleAttr.RoleAttrReincarnation, 0))
        local vip = tostring(CL.GetAttribute(playerData.attrs, RoleAttr.RoleAttrVip, 0))
        --{guid, name, type, templateID, sn, headIcon, schoolIcon, level,reincarnation}
        RoleClickPopMenu.ShowPlayerOperate({ tostring(playerData.guid), playerData.name, type, templateID, sn, headIcon, schoolIcon, level, reincarnation, vip })
    end
end

-- 操作菜单被点击
function ChatUI.OnOperateMenuCoverClick()
    local cover = GuidCacheUtil.GetUI("operateMenuCover")
    if cover then
        GUI.SetVisible(cover, false)
    end
end

--初始化未读消息提醒
function ChatUI.InitNewMsg()
    local newMsgBtn = GuidCacheUtil.GetUI("newMsgBtn")
    if newMsgBtn ~= nil then
        GUI.SetVisible(newMsgBtn, false)
    end
end

-- 点击未读消息
function ChatUI.OnNewMsgBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    GUI.SetVisible(btn, false)

    --初始化锁屏状态
    ChatUI.OnInitLockState()
    --初始化锁屏index
    ChatUI.InitLockIndex()
    --刷新消息
    ChatUI.OnRefreshChatMsg()
end

--初始化锁屏按钮状态
function ChatUI.OnInitLockState()
    local lockBtn = GuidCacheUtil.GetUI("lockBtn")
    ChatUI.IsLock = false
    GUI.ButtonSetImageID(lockBtn, "1800702090")
    ChatUI.InitNewMsg()
end

--开始刷新消息
function ChatUI.OnRefreshChatMsg()
    local chatBg = GuidCacheUtil.GetUI("chatBg")
    if chatBg ~= nil then
        local chatScroll = GuidCacheUtil.GetUI("chatScroll")
        local curCount = CL.GetMsgCountByChannel(ChatUI.CurrentSelectChannel)
        --if str[2] == "10" then
        --    CL.SendNotify(NOTIFY.SubmitForm, "消息跳转", "WorldQuestionServer")
        --end
        GUI.LoopScrollRectInit(chatScroll)
        GUI.LoopScrollRectSetTotalCount(chatScroll, curCount)
        GUI.LoopScrollRectRefreshCells(chatScroll)
    end
end

--创建序左下角底部滑动列表
function ChatUI.CreateChatScroll_LefftBottm()
    local chatBg_LeftBottm = GuidCacheUtil.GetUI("chatBg_LeftBottm")
    local name = "scroll_LeftBottm"
    local chatScroll = GUI.LoopListCreate(chatBg_LeftBottm, name, 5, -10, 400, 120, "ChatUI", "CreateChatBox_LeftBottom", "ChatUI", "OnRefresh_BottomChatMsg", 0, false, Vector2.New(400, 26), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
    GuidCacheUtil.BindName(chatScroll, name)
    GUI.LoopScrollRectSetSynchRefresh(chatScroll, true)
    SetAnchorAndPivot(chatScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local curCount = CL.GetMsgCountByChannel(ChannelIDDefine.All) --LD.GetAllChannelCount(100)
    GUI.ScrollRectSetChildSpacing(chatScroll, Vector2.New(0, 5))
    curCount = math.max(curCount, 25)
    GUI.LoopScrollRectSetTotalCount(chatScroll, curCount)
    GUI.LoopScrollRectRefreshCells(chatScroll)
    chatScroll:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(chatScroll, UCE.PointerClick, "ChatUI", "OnchatBg_LeftBottm_Click")
end

--创建底部聊天框
function ChatUI.CreateChatBox_LeftBottom()
    local chatScroll = GuidCacheUtil.GetUI("scroll_LeftBottm")
    local chatBox_Bg = GUI.LoopListChatCreate(chatScroll, "chatBox_Bg", "1800400200", 0, 10)
    GUI.SetColor(chatBox_Bg, Color.New(1, 1, 1, 0))
    GUI.LoopListChatSetPreferredWidth(chatBox_Bg, 400)
    GUI.LoopListChatSetPreferredHeight(chatBox_Bg, 26)
    SetAnchorAndPivot(chatBox_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local channelLabel = GUI.ImageCreate(chatBox_Bg, "channelLabel", btnList[5][10], 0, 0)
    SetAnchorAndPivot(channelLabel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local msgTxt = GUI.RichEditCreate(chatBox_Bg, "msgTxt", "", 0, 0, 400, 22)
    GUI.SetSpriteMaxHeight(msgTxt, 25)
    SetAnchorAndPivot(msgTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(msgTxt, fontSize_Little)
    GUI.SetColor(msgTxt, colorType_DarkYellow)

    msgTxt:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(msgTxt, UCE.PointerClick, "ChatUI", "OnUrlClick_RichTxt_LeftBottom")

    GUI.SetVisible(chatBox_Bg, false)
    chatBox_Bg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(chatBox_Bg, UCE.PointerClick, "ChatUI", "OnChatBottomItemClick")
    return chatBox_Bg
end

function ChatUI.OnUrlClick_RichTxt_LeftBottom(guid)
    ChatUI.OnUrlClick_RichTxt(guid, true)
end

function ChatUI.OnUrlClick_RichTxt(guid, isLeftBottom)
    --点击富文本
    local uielement = GUI.GetByGuid(guid)
    local value = GUI.RichEditGetSelectClickString(uielement)
    if value ~= nil and string.len(value) > 0 then
        test("url被点击!!" .. " ：" .. value)
        --STR:【折扇】,OWERGUID:491197701544562714,ITEMGUID:6255805224578850995,ITEMGRADE:1
        if string.find(value, "STR:(.+)】,OWERGUID:(%d+),ITEMGUID:(%d+),ITEMGRADE:(%d+)") ~= nil then
            local txt = string.split(value, "STR:")
            local str = string.split(txt[2], ",")
            local itemGuidStr = string.split(str[3], ":")
            local itemGuid = itemGuidStr[2]
            test(itemGuid)
            CurItemQueryGuid = itemGuid
            if CL.IsPetStrGuid(itemGuid) then
                CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "QueryPet", itemGuid)
            else
                CL.SendNotify(NOTIFY.SubmitForm, "FormItem", "QueryItem", itemGuid)
            end
        elseif string.find(value, "UIWndName:") ~= nil then
            test("点击跳ui")
            local txt = string.split(value, ",")
            local wnd = ""
            local index1 = nil
            local index2 = nil
            for i = 1, #txt do
                if string.find(txt[i],"UIWndName:") then
                    wnd = string.split(txt[i], ":")[2]
                end
                if string.find(txt[i],"UIIndex:") then
                    index1 = string.split(txt[i], ":")[2]
                end
                if string.find(txt[i],"UIIndex2:") then
                    index2 = string.split(txt[i], ":")[2]
                end
            end
            GetWay.Def[1].jump(wnd,index1,index2)
        elseif string.find(value, "WND:申请入队,PARAM:") ~= nil then
            test("点击申请入伍了")
            local txt = string.split(value, "PARAM:")
            local txt2 = string.split(txt[2], ",")
            local txt3 = string.split(txt2[1], ";")
            local SelfLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
            local TargetMin = tonumber(txt3[3])
            local TargetMax = tonumber(txt3[4])
            if SelfLevel >= TargetMin and SelfLevel <= TargetMax then
                CL.SendNotify(NOTIFY.TeamOpeUpdate, 19, txt3[5], -1)
            else
                CL.SendNotify(NOTIFY.ShowBBMsg, "不符合队伍的等级需求")
            end
        elseif string.find(value, "WND:playerName,STR:") ~= nil then
            local txt = string.split(value, "[")
            local str = string.split(txt[2], "]")
            --"#UILINK<WND:playerName,STR:["..role_name[1].."]>#"
            local roleName = str[1]
            if roleName == nil or string.len(roleName) == 0 then
                test("return")
                return
            end

            local selfName = CL.GetRoleName()
            if roleName == selfName then
                test("return")
                return
            end

            --local panel = GUI.GetWnd("ChatUI")
            CurQueryPlayerName = roleName
            CL.SendNotify(NOTIFY.SubmitForm, "FormPlayer", "QueryPlayer", roleName)
        elseif string.find(value, "NPCID:") ~= nil then
            LD.OnParsePathFinding(value)
        elseif string.find(value, "SKILLID:") ~= nil then
            --显示技能Tips
            --ChatUI.ShowSkillTips(value)
        elseif string.find(value, "Name:(.+),FunctionName:(.+),Para:(.+),STR:(.+)") ~= nil then
            --脚本方法
            --GlobalProcessing.ActivityQuickLink(value)
        elseif string.find(value, "INVITECODE:好友邀请码") ~= nil then
            local tmpStr = string.split(value, ",")
            test(value)
            for i = 1, #tmpStr do
                if string.find(tmpStr[i], "STR") ~= nil then
                    local tmpArr = string.split(tmpStr[i], ":")
                    TOOLKIT.CopyTextToClipboard(tmpArr[2])
                    CL.SendNotify(NOTIFY.ShowBBMsg, "您已经复制成功了！")
                end
            end

        end
    else
        if isLeftBottom then
            ChatUI.OnChatBtnClick(nil, nil)
        end
    end
end

--更新底部消息
function ChatUI.OnRefresh_BottomChatMsg(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local chatBox_Bg = GUI.GetByGuid(guid)
    local chatMsgData = CL.GetChannelMsgByIndex(ChannelIDDefine.All, index, true)
    if not chatMsgData or not chatMsgData.isShow then
        GUI.SetVisible(chatBox_Bg, false)
        return
    end
    local name = nil
    local message = nil
    local channelLabel = GUI.GetChild(chatBox_Bg, "channelLabel")
    local nameTxt = GUI.GetChild(chatBox_Bg, "name")
    local msgTxt = GUI.GetChild(chatBox_Bg, "msgTxt")
    local chatType = chatMsgData.channel
    name = chatMsgData.role_name

    message = ChatUI.ExchangeBottomRecordMsg(chatMsgData.message)
    GUI.LoopListChatSetPreferredWidth(chatBox_Bg, 400)

    local isSystem = chatType == ChannelIDDefine.System or chatType == ChannelIDDefine.System_Personal or chatType == ChannelIDDefine.System_System
    if name ~= "系统" and name ~= "GM_#define个人" and name ~= "帮助" then
        if CrossServerChat then
            local serverName = chatMsgData.server_name
            if serverName and serverName ~= "" then
                name = name .. "(" .. serverName .. ")"
            end
        end
        --当前登录的角色名
        local tmpName = "#UILINK<WND:playerName,STR:[" .. name .. "]>#"
        if string.find(message, "%#ROLL<VALUE:(%d+),TIME:(%d+)>%#") ~= nil  then

            GUI.StaticSetText(msgTxt, "<color=#ffffff00>占位  </color>" .. tmpName .. "发送了一个随机数")

        else

            GUI.StaticSetText(msgTxt, "<color=#ffffff00>占位  </color>" .. tmpName .. message)
        end

    else
        if isSystem then
            if name == "GM_#define个人" or name == "帮助" then
                chatType = ChannelIDDefine.System_Personal
            else
                chatType = ChannelIDDefine.System_System
            end
        end
        GUI.SetVisible(nameTxt, false)
        message = UIDefine.ReplaceSpecialRichText(message)
        GUI.StaticSetText(msgTxt, "<color=#ffffff00>占位  </color>" .. message)
        local h = GUI.StaticGetLabelPreferHeight(msgTxt)
        while h>240 do
            message = string.sub(message,1,string.len(message)/2)
            message = UIDefine.ReplaceSpecialRichText(message)
            GUI.StaticSetText(msgTxt, "<color=#ffffff00>占位  </color>" .. message)
            h = GUI.StaticGetLabelPreferHeight(msgTxt)
        end
    end

    if isSystem then
        if name == "帮助" then
            GUI.ImageSetImageID(channelLabel, "1800229260")
            GUI.SetColor(msgTxt, sysChatBtn[2][9]) -- 显示系统个人频道的颜色
        else
            for i = 1, #sysChatBtn do
                if chatType == sysChatBtn[i][10] then
                    --频道标签
                    GUI.ImageSetImageID(channelLabel, sysChatBtn[i][5])
                    GUI.SetColor(msgTxt, sysChatBtn[i][9])
                    break
                end
            end
        end
    else
        for i = 1, #btnList do
            if chatType == btnList[i][11] then
                --频道标签
                GUI.ImageSetImageID(channelLabel, btnList[i][10])
                GUI.SetColor(msgTxt, btnList[i][9])
                break
            end
        end
    end

    local height = GUI.RichEditGetPreferredHeight(msgTxt)
    GUI.SetHeight(msgTxt, height)
    if height < 22 then
        height = 22
    end
    --------------设置频道标记位置
    if channelLabel ~= nil then
        if height > 35 then
            GUI.SetPositionY(channelLabel, 0)
        else
            GUI.SetPositionY(channelLabel, (height - 22) / 2)
        end
    end
    -----
    UILayout.SetUrlColor(msgTxt, true)
    GUI.LoopListChatSetPreferredHeight(chatBox_Bg, height)
    --if LD.isShield_Channel(chatType,message)  then
    --    GUI.SetVisible(chatBox_Bg,false)
    --end


end

function ChatUI.ExchangeBottomRecordMsg(msg)
    if msg ~= nil then
        if string.find(msg, "#RECORDLINK<RecordName:") then
            msg = "发送了一条语音消息"
            return msg
        end
    end
    return msg
end

-- 点击左下角聊天信息
function ChatUI.OnChatBottomItemClick()
    ChatUI.OnChatBtnClick(nil, nil)
end

function ChatUI.CreateChatScroll()
    local name = "chatScroll"
    local chatScroll = GuidCacheUtil.GetUI(name)
    if chatScroll then
        return
    end
    local chatContentBg = GuidCacheUtil.GetUI("chatContentBg")
    local panel = GUI.GetWnd("ChatUI")
    chatScroll = GUI.LoopListCreate(chatContentBg, name, 0, 10, 420, 600 * GUI.GetHeight(panel) / 720, "ChatUI", "CreateChatBox", "ChatUI", "OnRefresh", 0, false, Vector2.New(415, 81), 2, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
    GuidCacheUtil.BindName(chatScroll, name)
    SetAnchorAndPivot(chatScroll, UIAnchor.Top, UIAroundPivot.Top)
    GUI.LoopScrollRectSetSynchRefresh(chatScroll, true)
    chatScroll:RegisterEvent(UCE.PointerClick)
    local curCount = CL.GetMsgCountByChannel(ChatUI.CurrentSelectChannel)
    curCount = math.max(curCount, 20)
    GUI.ScrollRectSetChildSpacing(chatScroll, Vector2.New(0, 10))
    GUI.LoopScrollRectSetTotalCount(chatScroll, curCount)
    GUI.SetPaddingVertical(chatScroll, Vector2.New(10, 25))
    GUI.LoopScrollRectRefreshCells(chatScroll)
    chatScroll:RegisterEvent(UCE.Drag)
    GUI.RegisterUIEvent(chatScroll, UCE.Drag, "ChatUI", "OnChatScrDrag_ChatChannel")
end

--设置锁屏位置
function ChatUI.SetLockIndex()
    local channelId = ChatUI.CurrentSelectChannel
    local curCount = CL.GetMsgCountByChannel(channelId)
    if not lockIndexTable[channelId] or lockIndexTable[channelId] == 0 then
        lockIndexTable[channelId] = curCount
    end
end

--初始化锁屏位置
function ChatUI.InitLockIndex()
    lockIndexTable[ChatUI.CurrentSelectChannel] = 0
end

local dragScrPos = 40
function ChatUI.OnChatScrDrag_ChatChannel(guid)
    local chatScroll = GUI.GetByGuid(guid)
    local height = GUI.GetPreferredHeight(chatScroll)
    local lockBtn = GuidCacheUtil.GetUI("lockBtn")
    local pos = GUI.LoopScrollRectGetGridLayoutPosY(chatScroll)
    if height < 600 then
        GUI.ButtonSetImageID(lockBtn, "1800702090")
        ChatUI.IsLock = false
    else
        local curCount = CL.GetMsgCountByChannel(ChatUI.CurrentSelectChannel)
        if pos > dragScrPos then
            GUI.ButtonSetImageID(lockBtn, "1800702091")
            ChatUI.IsLock = true
            ChatUI.SetLockIndex()
			return
        else
            GUI.ButtonSetImageID(lockBtn, "1800702090")
            ChatUI.IsLock = false
			local name = "newMsgBtn"
			local newMsgBtn = GuidCacheUtil.GetUI(name)
			if newMsgBtn ~= nil then
				local guid = GUI.GetGuid(newMsgBtn)
				ChatUI.OnNewMsgBtnClick(guid)
			end
        end
		GUI.LoopScrollRectSetTotalCount(chatScroll, curCount)
		GUI.LoopScrollRectRefreshCells(chatScroll)
    end
end

-- 创建一条聊天信息
function ChatUI.CreateChatBox()
    local chatScroll = GuidCacheUtil.GetUI("chatScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(chatScroll);
    local chatBox_Bg = GUI.LoopListChatCreate(chatScroll, "chatBox_Bg" .. curCount, "1800400200", 0, 10)
    GUI.SetColor(chatBox_Bg, Color.New(1, 1, 1, 0))
    GUI.LoopListChatSetPreferredWidth(chatBox_Bg, 420)
    GUI.LoopListChatSetPreferredHeight(chatBox_Bg, 90)
    SetAnchorAndPivot(chatBox_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local icon = GUI.ItemCtrlCreate(chatBox_Bg, "icon", "1800400050", 0, 0)
    SetAnchorAndPivot(icon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, role_HeadList[1])
    local iconSprite = GUI.ItemCtrlGetElement(icon, eItemIconElement.Icon)
    GUI.SetWidth(iconSprite, 70)
    GUI.SetHeight(iconSprite, 70)
    GUI.RegisterUIEvent(icon, UCE.PointerClick, "ChatUI", "OnRoleHeadClick")
    HeadIcon.CreateVip(icon, 60, 60, -5, 5)

    local channelLabel = GUI.ImageCreate(chatBox_Bg, "channelLabel", btnList[5][10], 90, 2, true)
    SetAnchorAndPivot(channelLabel, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local name = GUI.CreateStatic(chatBox_Bg, "name", "", 135, 0, 286, 30, "system", true)
    SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(name, fontSize)
    GUI.SetColor(name, colorType_DarkYellow)

    local msgTxt_Bg = GUI.ImageCreate(chatBox_Bg, "msgTxt_Bg", "1800900020", 82, 30, false, 335, 60)
    SetAnchorAndPivot(msgTxt_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local msgTxt = GUI.RichEditCreate(chatBox_Bg, "msgTxt", "", 100, 47, 290, 50)
    GUI.SetSpriteMaxHeight(msgTxt, 30)
    SetAnchorAndPivot(msgTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(msgTxt, 22)
    GUI.SetColor(msgTxt, colorType_DarkYellow)

    --------------------------------------Start 创建随机数loop Start--------------------------------------

    local GambleLoop =
    GUI.LoopScrollRectCreate(
            chatBox_Bg,
            "GambleLoop",
            0,
            0,
            120,
            45,
            "ChatUI",
            "CreateGambleItem",
            "ChatUI",
            "RefreshGambleItem",
            0,
            false,
            Vector2.New(40, 45),
            3,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(GambleLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(GambleLoop, TextAnchor.UpperLeft)
    GUI.LoopScrollRectSetSynchRefresh(GambleLoop, true)
    GUI.ScrollRectSetChildSpacing(GambleLoop, Vector2.New(-1, 0))
    GUI.SetVisible(GambleLoop,false)


    local maskingBg = GUI.ImageCreate(chatBox_Bg, "maskingBg", "1800001060", 0, 0,false,GUI.GetWidth(GambleLoop),GUI.GetHeight(GambleLoop)+10,false)
    maskingBg:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(maskingBg, true)
    SetSameAnchorAndPivot(maskingBg, UILayout.TopRight)


    ----------------------------------------End 创建随机数loop End---------------------------------------

    local recordGroup = GUI.GroupCreate(chatBox_Bg, "recordGroup", 0, 30, 200, 80)
    GUI.SetVisible(recordGroup,false)
    SetAnchorAndPivot(recordGroup, UIAnchor.Top, UIAroundPivot.Top)

    msgTxt:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(msgTxt, UCE.PointerClick, "ChatUI", "OnUrlClick_RichTxt")

    GUI.SetVisible(chatBox_Bg, false)
    return chatBox_Bg
end

--聊天频道消息刷新
function ChatUI.OnRefresh(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local channelId = ChatUI.CurrentSelectChannel -- 频道ID
    local chatBox_Bg = GUI.GetByGuid(guid)

    local chatMsg = nil
    local name = nil
    local message = nil
    local roleType = nil

    local icon = GUI.GetChild(chatBox_Bg, "icon")
    local iconSprite = GUI.ItemCtrlGetElement(icon, eItemIconElement.Icon)
    GUI.SetWidth(iconSprite, 70)
    GUI.SetHeight(iconSprite, 70)
    local channelLabel = GUI.GetChild(chatBox_Bg, "channelLabel")
    local nameTxt = GUI.GetChild(chatBox_Bg, "name")
    local msgTxt_Bg = GUI.GetChild(chatBox_Bg, "msgTxt_Bg")
    local msgTxt = GUI.GetChild(chatBox_Bg, "msgTxt")
    local recordGroup = GUI.GetChild(chatBox_Bg, "recordGroup")

    local GambleLoop = GUI.GetChild(chatBox_Bg,"GambleLoop",false)
    local maskingBg = GUI.GetChild(chatBox_Bg,"maskingBg",false)


    local isRecord = false
    GUI.SetData(chatBox_Bg, "RecordFileName", nil)
    chatMsg = CL.GetChannelMsgByIndex(channelId, index, true)
    if not chatMsg then
        GUI.SetVisible(chatBox_Bg, false)
        return
    end
    channelId = chatMsg.channel
    name = chatMsg.role_name
    message = chatMsg.message
    roleType = chatMsg.role_id
    --end

    GUI.LoopListChatSetPreferredWidth(chatBox_Bg, 420)
    local roleName = CL.GetRoleName()
    if name ~= "系统" and name ~= "GM_#define个人" and name ~= "帮助" then
        --当前登录的角色名
        GUI.SetData(icon, "playerName", name)
        GUI.SetVisible(icon, true)
        GUI.SetVisible(nameTxt, true)
        GUI.SetPositionY(msgTxt_Bg, 30)
        GUI.SetPositionY(msgTxt, 47)
        GUI.SetColor(msgTxt_Bg, Color.New(1, 1, 1, 1))
        local role = DB.GetRole(roleType)
        if role ~= nil then
            GUI.ImageSetImageID(iconSprite, tostring(role.Head))
        end
        HeadIcon.BindRoleVipLv(icon, chatMsg.vip or 0)
        local showName = name
        if CrossServerChat then
            local serverName = chatMsg.server_name
            if serverName and serverName ~= "" then
                showName = showName .. "[" .. serverName .. "]"
            end
        end
        local isSelf = true
        if name ~= roleName then
            isSelf = false
            SetAnchorAndPivot(chatBox_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetPositionX(chatBox_Bg, 0)
            GUI.SetPositionX(channelLabel, 90)
            GUI.SetPositionX(icon, 0)

            GUI.SetPositionY(iconSprite, -1)
            GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleLeft)
            SetAnchorAndPivot(nameTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetPositionX(nameTxt, 135)
            SetAnchorAndPivot(msgTxt_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetPositionX(msgTxt_Bg, 82)
            GUI.SetPositionY(msgTxt_Bg, 30)
            GUI.SetScale(msgTxt_Bg, Vector3.New(1, 1, 1))
            GUI.StaticSetText(nameTxt, showName)
            SetAnchorAndPivot(msgTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetPositionX(msgTxt, 106)
            GUI.SetPositionY(msgTxt, 47)
            GUI.SetWidth(msgTxt, 290)
        else
            GUI.SetPositionX(channelLabel, 295)
            SetAnchorAndPivot(nameTxt, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleRight)
            GUI.SetPositionX(nameTxt, 135)
            GUI.SetScale(msgTxt_Bg, Vector3.New(-1, 1, 1))
            SetAnchorAndPivot(msgTxt_Bg, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.SetPositionX(msgTxt_Bg, 82 + GUI.GetWidth(msgTxt_Bg))
            GUI.SetPositionY(msgTxt_Bg, 30)

            GUI.SetPositionY(iconSprite, -1)
            GUI.SetPositionX(icon, 340)
            SetAnchorAndPivot(msgTxt, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.SetPositionX(msgTxt, 106)
            GUI.SetPositionY(msgTxt, 47)
            GUI.StaticSetText(nameTxt, showName)
            GUI.SetWidth(msgTxt, 290)
        end
        local fileName, time = nil, nil
        isRecord, fileName, time = ChatUI.ExchangeRecordMsg(message)

        if not isRecord then

            GUI.SetVisible(recordGroup, false)
            local txt = tostring(GlobalProcessing.FilterStr)

            if string.find(message, "%#ROLL<VALUE:(%d+),TIME:(%d+)>%#"..txt) ~= nil  then

                ----------------------这里设置背景的宽度-----------------

                GUI.SetVisible(GambleLoop,true)
                GUI.SetVisible(msgTxt_Bg,false)
                GUI.SetVisible(msgTxt, false)
                GUI.SetVisible(maskingBg,true)

                if name ~= roleName then

                    SetSameAnchorAndPivot(GambleLoop, UILayout.TopLeft)
                    GUI.SetPositionX(GambleLoop, 90)
                    GUI.SetPositionY(GambleLoop, 35)

                    SetSameAnchorAndPivot(maskingBg, UILayout.TopLeft)
                    GUI.SetPositionX(maskingBg, 90)
                    GUI.SetPositionY(maskingBg, 30)


                else

                    SetSameAnchorAndPivot(GambleLoop, UILayout.TopRight)
                    GUI.SetPositionX(GambleLoop, 90)
                    GUI.SetPositionY(GambleLoop, 35)

                    SetSameAnchorAndPivot(maskingBg, UILayout.TopRight)
                    GUI.SetPositionX(maskingBg, 90)
                    GUI.SetPositionY(maskingBg, 30)

                end


                local randomNum = string.match(message, "VALUE:(%d+)")

                local sendTime = tonumber(string.match(message, "TIME:(%d+)"))


                local nowTime = tonumber(CL.GetServerTickCount())

                pointLoopGuidOfRandom[tostring(GUI.GetGuid(GambleLoop))] = {
                    num  = randomNum,
                    time = sendTime
                }

                if nowTime > sendTime + 1 then
                    GUI.LoopScrollRectSetTotalCount(GambleLoop, 3)
                    GUI.LoopScrollRectRefreshCells(GambleLoop)
                    GUI.LoopScrollRectSrollToCell(GambleLoop,1,pointRefreshSpeed)
                else

                    GUI.LoopScrollRectSetTotalCount(GambleLoop, pointRefreshNum)
                    GUI.LoopScrollRectRefreshCells(GambleLoop)
                    GUI.LoopScrollRectSrollToCell(GambleLoop,pointRefreshNum - 3,pointRefreshSpeed)
                end



            else

                GUI.SetVisible(GambleLoop,false)
                SetSameAnchorAndPivot(GambleLoop, UILayout.TopLeft)
                GUI.SetVisible(GambleLoop,false)
                GUI.SetVisible(msgTxt_Bg,true)
                GUI.SetVisible(maskingBg,false)


                GUI.StaticSetText(msgTxt, message)
                GUI.SetVisible(msgTxt, true)

                local width = GUI.RichEditGetPreferredWidth(msgTxt)
                if width < 300 then

                else
                    width = 300
                end
                GUI.SetWidth(msgTxt, width)
                GUI.SetWidth(msgTxt_Bg, width + 40)

            end

        else

            GUI.SetVisible(GambleLoop,false)
            local recordGuid = nil
            if recordGroup ~= nil then
                GUI.SetVisible(recordGroup, true)
                recordGuid = GUI.GetGuid(recordGroup)
                if isSelf then
                    GUI.SetPositionX(recordGroup, 10)
                else
                    GUI.SetPositionX(recordGroup, -40)
                end
            end
            ChatUI.CreateRecord(true, chatBox_Bg, recordGroup, fileName, time, index, channelId)
            GUI.SetVisible(msgTxt, false)


            local width = GUI.RichEditGetPreferredWidth(msgTxt)
            if width < 300 then

            else
                width = 300
            end
            GUI.SetWidth(msgTxt, width)
            GUI.SetWidth(msgTxt_Bg, width + 40)

        end

    else

        GUI.SetVisible(GambleLoop,false)
        if name == "GM_#define个人" then
            message = UIDefine.ReplaceSpecialRichText(message)
        end
        if recordGroup ~= nil then
            GUI.SetVisible(recordGroup, false)
        end
        GUI.SetVisible(msgTxt, true)
        GUI.SetVisible(icon, false)
        GUI.SetVisible(nameTxt, false)
        GUI.SetPositionX(channelLabel, 0)
        GUI.SetScale(msgTxt_Bg, Vector3.New(1, 1, 1))
        GUI.SetPositionY(msgTxt_Bg, 0)
        GUI.SetPositionX(msgTxt_Bg, -10)
        GUI.SetColor(msgTxt_Bg, Color.New(1, 1, 1, 0))
        SetAnchorAndPivot(msgTxt_Bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetPositionX(msgTxt_Bg, 0)
        GUI.SetPositionY(msgTxt_Bg, 0)
        SetAnchorAndPivot(msgTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetWidth(msgTxt, 420)
        GUI.SetPositionX(msgTxt, 0)
        GUI.SetPositionY(msgTxt, 0)

        --------------设置频道标记位置

        local tmpPar1, tmpPar2, value = string.find(message, "%#FACE<X:(%d+),Y:(%d+)>%#")
        if tmpPar1 ~= nil then
            local faceIndex = ChatUI.GetFaceIndex(message)
            if faceIndex ~= nil then
                if faceIndex < 48 then
                    GUI.SetPositionY(channelLabel, 3)
                else
                    GUI.SetPositionY(channelLabel, 0)
                end
            else
                GUI.SetPositionY(channelLabel, 0)
            end

        elseif string.find(message, "%#IMAGE(%d+)%#") ~= nil then
            local tmpPar1 = string.find(message, "%#IMAGE(%d+)%#")
            if tmpPar1 < 48 then
                GUI.SetPositionY(channelLabel, 5)
            else
                GUI.SetPositionY(channelLabel, 0)
            end
        elseif string.find(message, "%#IMAGE%<ID%:(%d+)%>%#") ~= nil then
            local tmpPar1 = string.find(message, "%#IMAGE<ID%:(%d+)%>%#")
            if tmpPar1 < 48 then
                GUI.SetPositionY(channelLabel, 3)
            else
                GUI.SetPositionY(channelLabel, 0)
            end
        else
            GUI.SetPositionY(channelLabel, 0)
        end
        GUI.StaticSetText(msgTxt, "<color=#ffffff00>占位 </color>" .. message)
    end
    if channelId == ChannelIDDefine.System or channelId == ChannelIDDefine.System_Personal or channelId == ChannelIDDefine.System_System then
        if name == "帮助" then
            GUI.ImageSetImageID(channelLabel, "1800229260")
        else
            for i = 1, #sysChatBtn do
                if channelId == sysChatBtn[i][10] then
                    --频道标签
                    GUI.ImageSetImageID(channelLabel, sysChatBtn[i][5])
                    break
                end
            end
        end
    else
        for i = 1, #btnList do
            if btnList[i][11] == channelId then
                --频道标签
                GUI.ImageSetImageID(channelLabel, btnList[i][10])
                break
            end
        end
    end
    local recordBgHeight = 60
    local height = 0
    if isRecord == false then

        height = GUI.RichEditGetPreferredHeight(msgTxt)
        GUI.SetHeight(msgTxt, height)
        GUI.SetHeight(msgTxt_Bg, height + 30)


    else
        height = 30
        GUI.SetWidth(msgTxt_Bg, 200)
        GUI.SetHeight(msgTxt_Bg, recordBgHeight)
    end

    if name ~= "系统" and name ~= "GM_#define个人" and name ~= "帮助" then
        if name == roleName then
            GUI.SetPositionX(msgTxt_Bg, 82 + GUI.GetWidth(msgTxt_Bg))
        else
            GUI.SetPositionX(msgTxt_Bg, 82)
        end

        local txt = tostring(GlobalProcessing.FilterStr)

        if string.find(message, "%#ROLL<VALUE:(%d+),TIME:(%d+)>%#"..txt) ~= nil  then

            ---------------------------------这里设置随机数的间距-------------------------------------
            GUI.SetVisible(recordGroup, false)
            GUI.SetHeight(recordGroup,10)
            GUI.LoopListChatSetPreferredHeight(chatBox_Bg, 85)

        else
            GUI.LoopListChatSetPreferredHeight(chatBox_Bg, height + 60)

        end


    else
        GUI.SetPositionX(msgTxt_Bg, 0)
        GUI.LoopListChatSetPreferredHeight(chatBox_Bg, height)
    end
    UILayout.SetUrlColor(msgTxt, false)

    --if channelId ~= nil and channelId == 8 then
    --    if LD.isShield_Channel(8, message) then
    --        GUI.SetVisible(chatBox_Bg, false)
    --    end
    --end
end

function ChatUI.ExchangeRecordMsg(msg)
    local fileName, time = GlobalUtils.GetRecordInfo(msg)
    if fileName and time then
        return true, fileName, time
    else
        return false
    end
end

function ChatUI.CreateRecord(isShow, parent, recordGroup, fileName, time, index, channelId)
    GUI.SetData(recordGroup, "RecordFileName", fileName)
    local recordBtn = GUI.GetChild(recordGroup, "recordBtn")
    if recordBtn == nil then
        local tipsBtn = GUI.ButtonCreate(recordGroup, "tipsBtn", "1800900100", 30, 15, Transition.None)
        GUI.SetAnchor(tipsBtn, UIAnchor.TopLeft)
        GUI.SetPivot(tipsBtn, UIAroundPivot.TopLeft)
        local tips2 = GUI.ImageCreate(tipsBtn, "tips2", "1800900110", 0, 0)
        GUI.SetAnchor(tips2, UIAnchor.Center)
        GUI.SetPivot(tips2, UIAroundPivot.Center)
        GUI.SetVisible(tips2, false)

        recordBtn = GUI.ButtonCreate(recordGroup, "recordBtn", "1800900090", 60, 12, Transition.ColorTint, "", 140, 33, false)
        GUI.SetAnchor(recordBtn, UIAnchor.TopLeft)
        GUI.SetPivot(recordBtn, UIAroundPivot.TopLeft)
        GUI.ButtonSetTextColor(recordBtn, colorType_DarkYellow)
        GUI.RegisterUIEvent(recordBtn, UCE.PointerClick, "ChatUI", "OnPlayRecordBtnClick")
    else
        recordBtn = GUI.GetChild(recordGroup, "recordBtn")
        GUI.SetVisible(recordGroup, true)
    end

    GUI.SetData(recordGroup, "MsgIndex", index)
    local time = math.ceil(tonumber(time))
    if time ~= nil then
        if time > 15 then

        end
        GUI.ButtonSetText(recordBtn, time .. "秒")
        GUI.SetData(recordGroup, "RecordTime", time)
    else
        GUI.ButtonSetText(recordBtn, "0秒")
    end

    GUI.SetData(recordGroup, "RecordChannel", tostring(channelId))
    local recordBtn = GUI.GetChild(recordGroup, "recordBtn")
    local recordGuid = GUI.GetGuid(recordBtn)
    recordName2BtnGuid[fileName] = recordGuid
    if ChatUI.lastRecordTipsBtnGuid ~= nil then
        if ChatUI.lastRecordAnimFileName == fileName and ChatUI.lastRecordTipsBtnGuid ~= recordGuid then
            local lastTipsBtn = GUI.GetByGuid(ChatUI.lastRecordTipsBtnGuid)
            if lastTipsBtn ~= nil and GUI.GetVisible(lastTipsBtn) then
                local lastParent = GUI.GetParentElement(lastTipsBtn)
                local lastTipsBtn = GUI.GetChild(lastParent, "tipsBtn")
                if lastTipsBtn ~= nil then
                    local lastTips = GUI.GetChild(lastTipsBtn, "tips2")
                    if lastTips ~= nil then
                        GUI.SetVisible(lastTips, false)
                    end
                end
            end
            ChatUI.lastRecordTipsBtnGuid = recordGuid
        end
    end
    --ChatUI.AddPlayRecordBtnGuid( index,channelId,recordGuid,fileName )
end

--- 重置一下上一次播放语音动画
function ChatUI.ResetLastRecord()
    if ChatUI.RecordAnimTimer then
        ChatUI.RecordAnimTimer:Stop()
        ChatUI.RecordAnimTimer = nil
    end
    if ChatUI.lastRecordTipsBtnGuid ~= nil then
        local lastTipsBtn = GUI.GetByGuid(ChatUI.lastRecordTipsBtnGuid)
        if lastTipsBtn ~= nil and GUI.GetVisible(lastTipsBtn) then
            local lastParent = GUI.GetParentElement(lastTipsBtn)
            local lastTipsBtn = GUI.GetChild(lastParent, "tipsBtn")
            if lastTipsBtn ~= nil then
                local lastTips = GUI.GetChild(lastTipsBtn, "tips2")
                if lastTips ~= nil then
                    GUI.SetVisible(lastTips, false)
                end
            end
        end
        ChatUI.lastRecordTipsBtnGuid = nil
        ChatUI.lastRecordAnimFileName = nil
    end
end

function ChatUI.OnPlayRecordBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local parent = GUI.GetParentElement(btn)
    local fileName = GUI.GetData(parent, "RecordFileName")
    if fileName and string.len(fileName) > 0 then
        --ChatUI.lastRecordTipsBtnGuid = guid
        --ChatUI.lastRecordAnimFileName = fileName
        CL.PlayRecord(fileName)
    end
end

function ChatUI.PlayRecordAnimation(fileName)
    ChatUI.ResetLastRecord()
    ChatUI.lastRecordTipsBtnGuid = fileName and recordName2BtnGuid[fileName]
    ChatUI.lastRecordAnimFileName = fileName
    local parent = GUI.GetParentElement(GUI.GetByGuid(ChatUI.lastRecordTipsBtnGuid))
    local time = tonumber(GUI.GetData(parent, "RecordTime"))
    time = time and tonumber(time) or 1
    if ChatUI.RecordAnimTimer then
        ChatUI.RecordAnimTimer:Stop()
        ChatUI.RecordAnimTimer:Reset(ChatUI.OnRecordAnimTimer, 1, time)
    else
        ChatUI.RecordAnimTimer = Timer.New(ChatUI.OnRecordAnimTimer, 1, time)
    end
    ChatUI.RecordAnimTimer:Start()
end

function ChatUI.OnRecordAnimTimer()
    if not ChatUI.lastRecordTipsBtnGuid then
        return
    end
    local uielement = GUI.GetByGuid(ChatUI.lastRecordTipsBtnGuid)
    if uielement and GUI.GetVisible(uielement) then
        local recordGroup = GUI.GetParentElement(uielement)
        local fileName = GUI.GetData(recordGroup, "RecordFileName")
        if fileName and string.len(fileName) > 0 and GUI.GetVisible(recordGroup) and fileName == ChatUI.lastRecordAnimFileName then
            local tipsBtn = GUI.GetChild(recordGroup, "tipsBtn")
            local tips = GUI.GetChild(tipsBtn, "tips2")
            if tips then
                if ChatUI.RecordAnimTimer.loop <= 1 then
                    GUI.SetVisible(tips, false)
                else
                    GUI.SetVisible(tips, not GUI.GetVisible(tips))
                end
            end
        end
    end
end

function ChatUI.OnRoleHeadClick(guid)
    local btn = GUI.GetByGuid(guid)
    local roleName = GUI.GetData(btn, "playerName")
    if roleName == nil or string.len(roleName) == 0 then
        return
    end

    local selfName = CL.GetRoleName()
    if roleName == selfName then
        return
    end

    --local panel = GUI.GetWnd("ChatUI")
    --GUI.SetData(panel, "queryPlayerName", roleName)
    CurQueryPlayerName = roleName
    CL.SendNotify(NOTIFY.SubmitForm, "FormPlayer", "QueryPlayer", roleName)
end

-- 关闭聊天窗口
function ChatUI.OnCloseBtnClick_ChatBg()
    --初始化锁屏按钮状态
    local chatBg = GuidCacheUtil.GetUI("chatBg")
    if chatBg ~= nil then
        local lockBtn = GuidCacheUtil.GetUI("lockBtn")
        GUI.ButtonSetImageID(lockBtn, "1800702090")
        ChatUI.IsLock = false
    end

    --初始化锁屏标记
    --ChatUI.InitLockIndex()

    GUI.SetVisible(chatBg, false)
    local emojPanel = GUI.GetWnd("EmojPanelUI")
    if emojPanel ~= nil then
        GUI.CloseWnd("EmojPanelUI")
    end
    --显示底部聊天界面
    local chatBg_LeftBottm = GuidCacheUtil.GetUI("chatBg_LeftBottm")
    GUI.SetVisible(chatBg_LeftBottm, true)
    ChatUI.SetChatScroll(false)
end

function ChatUI.OnRealNameBtn()
    GUI.OpenWnd("AuthRealNameUI")
end

-- 点击拉伸按钮的处理
function ChatUI.OnflexBtnClick(guid)
    local chatBg_LeftBottm = GuidCacheUtil.GetUI("chatBg_LeftBottm")
    local uielement = GUI.GetByGuid(guid)
    local vec = GUI.GetEulerAngles(uielement)
    local scroll_LeftBottm = GUI.GetChild(chatBg_LeftBottm, "scroll_LeftBottm")
    if vec == Vector3.New(0, 0, 180) then
        GUI.SetHeight(chatBg_LeftBottm, Vector3.Lerp(Vector3.New(135, 0, 0), Vector3.New(270, 0, 0), 1).x)
        GUI.SetHeight(scroll_LeftBottm, 255)
        GUI.SetEulerAngles(uielement, Vector3.New(0, 0, 0))
        GUI.SetPositionY(uielement, 5)
        GUI.SetPositionX(uielement, 5)
		ChatUI.RefreshButtonOnflex(true)
    else
        GUI.SetHeight(chatBg_LeftBottm, Vector3.Lerp(Vector3.New(270, 0, 0), Vector3.New(135, 0, 0), 1).x)
        GUI.SetHeight(scroll_LeftBottm, 120)
        GUI.SetEulerAngles(uielement, Vector3.New(0, 0, 180))
        GUI.SetPositionY(uielement, 25)
        GUI.SetPositionX(uielement, 25)
		ChatUI.RefreshButtonOnflex(false)
    end
    local allChannelCount = CL.GetMsgCountByChannel(ChannelIDDefine.All) or 0
    GUI.LoopScrollRectSetTotalCount(scroll_LeftBottm, allChannelCount)
    GUI.LoopScrollRectRefreshCells(scroll_LeftBottm)
    GUI.ScrollRectSetNormalizedPosition(scroll_LeftBottm, Vector2.New(0, 0))
end

--点击拉伸时，上方按钮的变化
function ChatUI.RefreshButtonOnflex(Isflex)
	local leftBottom_Bg = GUI.Get("MainUI/leftBg/leftBottom_Bg")
	if Isflex then
		GUI.SetVisible(leftBottom_Bg,false)
	else
		GUI.SetVisible(leftBottom_Bg,true)
	end
end

function ChatUI.CloseEmojPanel()
    GUI.CloseWnd("EmojPanelUI")
end

function ChatUI.OnRecvChatMessage(channelId, msg, roleName)

    --后面需要加一个频道是否屏蔽的判断
    local allChannelCount = CL.GetMsgCountByChannel(ChannelIDDefine.All)
    if allChannelCount == nil then
        allChannelCount = 0
    end
    --ChatUI.AddRecordByIndex(allChannelCount, msg, channelId)
    local chatBg_LeftBottm = GuidCacheUtil.GetUI("chatBg_LeftBottm")
    if chatBg_LeftBottm == nil then
        return
    end
    local chatScroll_LeftBottom = GuidCacheUtil.GetUI("scroll_LeftBottm")
    GUI.LoopScrollRectSetTotalCount(chatScroll_LeftBottom, allChannelCount)
    GUI.LoopScrollRectRefreshCells(chatScroll_LeftBottom)

    ----喇叭频道消息
    if channelId == ChannelIDDefine.Trumpet then
        ChatUI.ShowTrumpetChat(true)
    elseif allChannelCount == 0 then
        ChatUI.ShowTrumpetChat(false)
    end

    --刷新聊天左边频道消息
    local chatBg = GuidCacheUtil.GetUI("chatBg")
    --if chatBg == nil or GUI.GetVisible(chatBg) == false then
    --    if #ChatUI.RecordArr == 1 and strPar[1] ~= "7" then
    --        ChatUI.AutoPlayNextRecord()
    --    end
    --end
    if chatBg and GUI.GetVisible(chatBg) then
        local chatScroll = GuidCacheUtil.GetUI("chatScroll")
        local curCount = CL.GetMsgCountByChannel(ChatUI.CurrentSelectChannel)
        local height = GUI.GetPreferredHeight(chatScroll)
        local name = "newMsgBtn"
        local newMsgBtn = GuidCacheUtil.GetUI(name)
        if ChatUI.IsLock then
            if height > 600 then
                --开始锁定index
                ChatUI.SetLockIndex()
                local lockIndex = lockIndexTable[ChatUI.CurrentSelectChannel]
                if lockIndex < curCount then
                    if newMsgBtn ~= nil then
                        GUI.SetVisible(newMsgBtn, true)
                    else
                        local chatContentBg = GuidCacheUtil.GetUI("chatContentBg")
                        newMsgBtn = GUI.ButtonCreate(chatContentBg, name, "1800900050", 0, 0, Transition.ColorTint, "", 440, 46, false)
                        GuidCacheUtil.BindName(newMsgBtn, name)
                        SetAnchorAndPivot(newMsgBtn, UIAnchor.Top, UIAroundPivot.Top)
                        GUI.RegisterUIEvent(newMsgBtn, UCE.PointerClick, "ChatUI", "OnNewMsgBtnClick")
                        local msgTxt = GUI.CreateStatic(newMsgBtn, "msgTxt", "", 0, 0, 200, 40, "system", true)
                        GUI.StaticSetAlignment(msgTxt, TextAnchor.MiddleCenter)
                        SetAnchorAndPivot(msgTxt, UIAnchor.Center, UIAroundPivot.Center)
                        GUI.StaticSetFontSize(msgTxt, fontSize_BigOne)
                        GUI.SetColor(msgTxt, colorType_Txt)
                    end
                    local msgTxt = GUI.GetChild(newMsgBtn, "msgTxt")
                    GUI.StaticSetText(msgTxt, "未读消息" .. (curCount - lockIndex) .. "条")
                else

                end

                return
            end
        else

        end
        if newMsgBtn ~= nil then
            GUI.SetVisible(newMsgBtn, false)
        end
        ChatUI.InitLockIndex()

        GUI.LoopScrollRectSetTotalCount(chatScroll, curCount)
        GUI.LoopScrollRectRefreshCells(chatScroll)
    end
end

--发送消息按钮事件
--TODO:检测玩家等级与频道等级要求
function ChatUI.OnSendMsgBtnClick(guid)

    ChatUI.CloseEmojPanel()
    local inputField = GuidCacheUtil.GetUI("inputField")
    if not inputField then
        return
    end
    --判断当前频道是否可以发送聊天
    local send = true
    if ChatUI.CurrentSelectChannel == ChannelIDDefine.Team then
        local teamInfo = LD.GetTeamInfo()
        if tostring(teamInfo.team_guid) == "0" then
            CL.SendNotify(NOTIFY.ShowBBMsg, "你还未在队伍中")
            send = false
        end
    elseif ChatUI.CurrentSelectChannel == ChannelIDDefine.Faction then
        local guildData = LD.GetGuildData()
        if not guildData or not guildData.guild or tostring(guildData.guild.guid) == "0" then
            CL.SendNotify(NOTIFY.ShowBBMsg, "你还未加入帮派")
            send = false
        end
    end

    local text = GUI.EditGetTextM(inputField)


    if rollSendTime ~= nil then

        local time = tonumber(CL.GetServerTickCount())

        if rollSendTime + rollCdTime > time then
            if text == "#ROLL" then

                CL.SendNotify(NOTIFY.ShowBBMsg, "短时间内无法重复使用")

                return

            end

        end

    end


    if string.find(text, inviteCode) then
        local icod = GlobalProcessing.FriendInviteCode or inviteCode
        text = string.gsub(text, inviteCode, "#INVCODESTART<INVITECODE:好友邀请码,STR:".. icod ..">#",1)
        CL.SendChatMsg(ChatUI.CurrentSelectChannel, text)
        send = false
    end

    if send then

        if string.find(text, "#ROLL") ~= nil  then

            local time = tonumber(CL.GetServerTickCount())
            CL.SendNotify(NOTIFY.SubmitForm, "FormChatRoll", "GetRollNum",ChatUI.CurrentSelectChannel,text,time)

            rollSendTime = time
            GUI.EditSetTextM(inputField, "") -- 输入框置空
            return
        end



        if text == "" then
            CL.SendNotify(NOTIFY.ShowBBMsg, "请输入文字")
        elseif ChatUI.CurrentSelectChannel==ChannelIDDefine.Trumpet then
            if string.sub(text, 1, 1) ~= "@" then -- 过滤掉GM指令
                if string.len( text ) > 150  then
                    CL.SendNotify(NOTIFY.ShowBBMsg, "输入的内容超出限制")
                    return
                end
                text = LD.GetRealSendContent(text)
                LD.SaveChatHistoryMsg(text)
                CL.SendNotify(NOTIFY.SubmitForm, "FormTrumpet", "sendMessageInTrumpet",text,ChatUI.CurrentSelectChannel)
            end
        else
            if string.len( text ) > 200  then
                CL.SendNotify(NOTIFY.ShowBBMsg, "输入的内容超出限制")
                return
            end
            if ChatUI.CurrentSelectChannel == ChannelIDDefine.World then
                if not WorldQuestionUI then require("WorldQuestionUI") end
                if WorldQuestionUI.IsShowPanelBg() then
                    if not ChatUI.SpeakSecondTimer then
                        ChatUI.SpeakSecondTimer = Timer.New(ChatUI.ChatCDTime,1,-1)
                        ChatUI.SpeakSecondTimer:Start()
                        CL.SendChatMsg(ChatUI.CurrentSelectChannel, text)
                        GUI.EditSetTextM(inputField, "")
                        return
                    else
                        CL.SendNotify(NOTIFY.ShowBBMsg, "发言冷却，剩余"..WaitTime.."秒")
                        return
                    end
                else

                end
            end
            CL.SendChatMsg(ChatUI.CurrentSelectChannel, text)
        end
    end

    GUI.EditSetTextM(inputField, "") -- 输入框置空
end

--招募频道组队平台按钮点击
function ChatUI.OnTeamPanelBtnClick(guid)
    if not CanSystemOpen(2) then
        CL.SendNotify(NOTIFY.ShowBBMsg, "等级不满足，暂无法开启组队平台")
        return
    end
    GUI.OpenWnd("TeamPlatformPersonalUI")
end

--锁屏按钮点击
function ChatUI.OnLockBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    if not ChatUI.IsLock then
        --当前未处于锁屏状态
        GUI.ButtonSetImageID(btn, "1800702091")
        ChatUI.IsLock = true
    else
        --表示处于锁屏状态
        GUI.ButtonSetImageID(btn, "1800702090")
        ChatUI.IsLock = false
    end
end

--聊天频道的笑脸按钮点击
function ChatUI.OnEmojBtnClick_ChatBg(guid)
    GUI.OpenWnd("EmojPanelUI", "index:" .. tostring(GuidCacheUtil.GetGuid("inputField")))
end

-- 点击设置按钮
function ChatUI.OnSetBtnClick(guid)
    GUI.OpenWnd("SystemSettingUI")
end

-- 好友按钮被点击
function ChatUI.OnFriendChatBtnClick(guid)
    local count = LD.GetMailTotalRedPointCount()
    if count > 0 then
        GUI.OpenWnd("MailUI")
        CL.SendNotify(NOTIFY.SubmitForm,"FormContact","get_mail_senders_guid")
    else
        GUI.OpenWnd("FriendUI")
        CL.SendNotify(NOTIFY.SubmitForm,"FormContact","get_senders_guid")
    end
end

function ChatUI.OnDestroy()
    if TrumpetTimer then
        TrumpetTimer:Stop()
        TrumpetTimer = nil
    end
end

--获取表情在富文本中的位置
function ChatUI.GetFaceIndex(str)
    local tmpPar1, tmpPar2, value = string.find(str, "%#FACE<X:(%d+),Y:(%d+)>%#")
    if tmpPar1 ~= nil then
        local tmpStr = string.sub(str, 1, tmpPar1 - 1)
        local length, value = ChatUI.GetItemLength(tmpStr)
        return length
    else
        return nil
    end
end

function ChatUI.GetTextWithoutColor(value)
    local tm1, tm2, tmValue, tmValue2 = string.find(value, "<color='#(%w-)'>(.-)</color>")

    if tm1 == nil then
        tm1, tm2, tmValue, tmValue2 = string.find(value, "<color=#(%w-)>(.-)</color>")
    end

    if tm1 ~= nil and tmValue ~= nil and tmValue2 ~= nil then
        if string.len(tmValue) == 6 or string.len(tmValue) == 8 then
            local firstStr = string.sub(value, 1, tm1 - 1)
            local endStr = string.sub(value, tm2 + 1, string.len(value))
            value = firstStr .. tmValue2 .. endStr
        end
    end
    return tm1, value
end

function ChatUI.GetItemLength(value)
    local tmp = nil
    local tmpLock = true
    for i = 1, 48 do
        if tmpLock then
            tmp, value = ChatUI.GetTextWithoutColor(value)
            if tmp == nil then
                tmpLock = false
            end
        end
    end

    local realLength = string.len(value)
    local tmp1, tmp2, tmpValue, tmpValue2, tmpValue3, tmpValue4 = string.find(value, "#ITEMLINK<STR:【(.-)】,OWERGUID:(%d+),ITEMGUID:(%d+),ITEMGRADE:(%d+)>#")
    if tmp1 ~= nil then
        local cutValue1 = string.sub(value, 1, tmp1 - 1)

        local itemStr = "#ITEMLINK<STR:【" .. tmpValue .. "】,OWERGUID:" .. tmpValue2 .. ",ITEMGUID:" .. tmpValue3 .. ",ITEMGRADE:" .. tmpValue4 .. ">#"
        local cutValue2 = string.sub(value, tmp1 + string.len(itemStr), string.len(value))
        value = cutValue1 .. "【" .. tmpValue .. "】" .. cutValue2
        realLength = string.len(value) + string.len("【" .. tmpValue .. "】")
        if string.find(value, "#ITEMLINK<STR:【(.-)】,OWERGUID:(%d+),ITEMGUID:(%d+),ITEMGRADE:(%d+)>#") ~= nil then
            realLength, value = ChatUI.GetItemLength(value)
        else
            realLength = string.len(value)
        end
    end

    return realLength, value
end

-- 展示世界答题UI
function ChatUI.ShowWorldQuestionUI(channelId)
    if WorldQuestionUI then
        if channelId == ChannelIDDefine.World then
            if WorldQuestionUI.IsShowPanelBg() then
                WorldQuestionUI.SetPanelBgVisible(true)
                ChatUI.SetChatScroll(true)
            else
                WorldQuestionUI.SetPanelBgVisible(false)
            end
        else
            WorldQuestionUI.SetPanelBgVisible(false)
        end
    end
end

function ChatUI.CreateGambleItem(guid)
    local GambleLoop = GUI.GetByGuid(tostring(guid))
    local index = GUI.LoopScrollRectGetChildInPoolCount(GambleLoop) + 1

    local groupBg = GUI.ImageCreate(GambleLoop, "groupBg"..index, "1800600320", 0, 0, false, 60, 70)
    SetSameAnchorAndPivot(groupBg, UILayout.TopLeft)

    pointLoopChildGuidOfParentGuid[tostring(GUI.GetGuid(groupBg))] = tostring(guid)


    local numBg = GUI.ImageCreate(groupBg, "numBg", "1800705000", 0, 0, false, 30, 35)
    SetSameAnchorAndPivot(numBg, UILayout.Center)

    return groupBg

end


function ChatUI.RefreshGambleItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local parentGuid = pointLoopChildGuidOfParentGuid[tostring(guid)]

    if parentGuid ~= nil then

        local randomNum = pointLoopGuidOfRandom[parentGuid].num

        local time = pointLoopGuidOfRandom[parentGuid].time


        if randomNum ~= nil then


            local numBg = GUI.GetChild(item,"numBg",false)

            if tonumber(CL.GetServerTickCount()) > time + 2 then

                local num = string.sub(tostring(randomNum), index, index)

                GUI.ImageSetImageID(numBg,randomOfImgTable[num])

            else

                if index <= pointRefreshNum - 3 then

                    local num = math.random(0,9)

                    GUI.ImageSetImageID(numBg,randomOfImgTable[tostring(num)])
                else

                    local powerNum = 3 + (index - pointRefreshNum)

                    local num = string.sub(tostring(randomNum), powerNum, powerNum)

                    GUI.ImageSetImageID(numBg,randomOfImgTable[num])

                end

            end

        end

    end

end

function ChatUI.OnMaskingBgClick()
    test("=====================")
end


--- 世界答题接口，服务端脚本调用
function ChatUI.WorldQuestion(questionTxt)
    questionTxt = questionTxt or ""
    LD.SendLocalChatMsg(questionTxt, ChannelIDDefine.System)
end

--- NPC喊话接口，服务端脚本调用
function ChatUI.WorldNPCMessage(word, name,guidStr)
    LD.SendLocalChatMsg(string.format("<color='#19c800'>[%s]</color>%s", name, word), ChannelIDDefine.Current)
    if NOTIFY.TalkBubble~=nil then
        local guid = guidStr==nil and  uint64.zero or uint64.new(guidStr)
        CL.SendNotify(NOTIFY.TalkBubble, ChannelIDDefine.Current,word,name,guid)
    end
end

--- 在某个频道发一句话
function ChatUI.ShowMsgInChannel(channelId, msg)
    LD.SendLocalChatMsg(msg, channelId)
end

--	Jinken获取按钮
function ChatUI.GetBtn(key)
    return GuidCacheUtil.GetUI(key)
end

function ChatUI.ChatCDTime()
    if WaitTime ~= 0 then
        WaitTime = WaitTime - 1
    else
        ChatUI.SpeakSecondTimer:Stop()
        ChatUI.SpeakSecondTimer = nil
        WaitTime = 20
    end
end


function ChatUI.OnCustomerServiceBtnClick()
	local url = ""  --网址
	CL.ShowWeb(url,true)
end
