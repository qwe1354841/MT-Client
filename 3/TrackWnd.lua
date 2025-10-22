local TrackWnd = {}

_G.TrackWnd = TrackWnd
local GuidCacheUtil = nil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local messageEventList = {
    { GM.PlayerExitGame, "CloseTrackWnd" },
    { GM.PlayerExitLogin, "CloseTrackWnd" },
}
local colorWhite = UIDefine.WhiteColor
local colorDark = UIDefine.BrownColor -- Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorP = Color.New(220 / 255, 96 / 255, 247 / 255, 255 / 255)
local QualityRes = UIDefine.ItemIconBg
local IsFirstEnter = true

function TrackWnd.Main(parameter)
    if not TrackWnd.TalkNpc then
        TrackWnd.TalkNpc = ""
    end

    if not TrackWnd.GuaJI_Type then
        TrackWnd.GuaJI_Type = 0
    end
    local _TrackNode = GUI.Get("TrackUI/TrackNode")

    --获取并关闭任务和组队相关界面
    TrackWnd.SetQuestLstBackVisible(false)
    TrackWnd.SetRoleLstBackVisible(false)

    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    --local _TrackWnd = GUI.ImageCreate(_TrackNode, "TrackWnd", "", 0, 0, false, 0, 0)
    local _TrackWnd = GUI.GroupCreate(_TrackNode, "TrackWnd", 0, 0, 0, 0)
    GuidCacheUtil.BindName(_TrackWnd, "TrackWnd")
    SetAnchorAndPivot(_TrackWnd, UIAnchor.Right, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(_TrackWnd, true)
    _TrackWnd:RegisterEvent(UCE.PointerClick)

    --隐藏MAIN界面切换箭头，创建新切换箭头
    TrackWnd.SetTrackArrowVisible(false)
    local _DungeonTrackArrow = GUI.ButtonCreate(_TrackWnd, "DungeonTrackArrow", "1800202270", -1, -18, Transition.ColorTint)
    GuidCacheUtil.BindName(_DungeonTrackArrow, "DungeonTrackArrow")
    SetAnchorAndPivot(_DungeonTrackArrow, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(_DungeonTrackArrow, UCE.PointerClick, "TrackWnd", "OnClickTrackArrow")

    --隐藏MAIN标题框，创建新标题框
    TrackWnd.SetTitleBackVisible(false)
    local _DungeonTitleBack = GUI.ImageCreate(_TrackWnd, "DungeonTitleBack", "1800200020", -2, 0, false, 220, 40)
    GuidCacheUtil.BindName(_DungeonTitleBack, "DungeonTitleBack")
    SetAnchorAndPivot(_DungeonTitleBack, UIAnchor.Left, UIAroundPivot.Right)
    GUI.SetIsRaycastTarget(_DungeonTitleBack, true)
    _DungeonTitleBack:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(_DungeonTitleBack, UCE.PointerClick, "TrackWnd", "OnClickTitleBack")

    --副本按钮
    local _DungeonBtn = GUI.ButtonCreate(_DungeonTitleBack, "DungeonBtn", "1800202260", 55, 0, Transition.ColorTint)
    GuidCacheUtil.BindName(_DungeonBtn, "DungeonBtn")
    SetAnchorAndPivot(_DungeonBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(_DungeonBtn, true)
    GUI.SetIsRaycastTarget(_DungeonBtn, false)

    --标题副本
    local _TitleDungeon = GUI.CreateStatic(_DungeonTitleBack, "TitleDungeon", "副本", 55, 2, 100, 35)
    GuidCacheUtil.BindName(_TitleDungeon, "TitleDungeon")
    SetAnchorAndPivot(_TitleDungeon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(_TitleDungeon, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(_TitleDungeon, 24)
    GUI.SetColor(_TitleDungeon, colorDark)

    --组队按钮
    local _DungeonTeamBtn = GUI.ButtonCreate(_DungeonTitleBack, "DungeonTeamBtn", "1800202260", -55, 0, Transition.ColorTint)
    GuidCacheUtil.BindName(_DungeonTeamBtn, "DungeonTeamBtn")
    SetAnchorAndPivot(_DungeonTeamBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(_DungeonTeamBtn, false)
    GUI.RegisterUIEvent(_DungeonTeamBtn, UCE.PointerClick, "TrackWnd", "OnClickDungeonTeamBtn")

    --标题组队
    local _DungeonTitleTeam = GUI.CreateStatic(_DungeonTitleBack, "DungeonTitleTeam", "组队", -55, 2, 100, 35)
    GuidCacheUtil.BindName(_DungeonTitleTeam, "DungeonTitleTeam")
    SetAnchorAndPivot(_DungeonTitleTeam, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(_DungeonTitleTeam, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(_DungeonTitleTeam, 24)
    GUI.SetColor(_DungeonTitleTeam, colorWhite)

    --副本界面
    local panelCover = GUI.ImageCreate(_TrackWnd, "panelCover", "1800400220", -223, 24, false, 254, 392);
    GuidCacheUtil.BindName(panelCover, "panelCover")
    SetAnchorAndPivot(panelCover, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetIsRaycastTarget(panelCover, true)
    GUI.SetColor(panelCover, UIDefine.Transparent);
    panelCover:RegisterEvent(UCE.PointerClick)

    local _DungeonWnd = GUI.ImageCreate(_TrackWnd, "DungeonWnd", "1800200010", -223, 24, false, 254, 392)
    GuidCacheUtil.BindName(_DungeonWnd, "DungeonWnd")
    SetAnchorAndPivot(_DungeonWnd, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetColor(_DungeonWnd, Color.New(255 / 255, 255 / 255, 255 / 255, 0 / 255));
    GUI.SetVisible(_DungeonWnd, false)

    local _PIC1 = GUI.ImageCreate(_DungeonWnd, "PIC1", "1800200010", 0, 0, false, 254, 79)
    SetAnchorAndPivot(_PIC1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PIC2 = GUI.ImageCreate(_DungeonWnd, "PIC2", "1800200010", 0, 80, false, 254, 119)
    SetAnchorAndPivot(_PIC2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PIC3 = GUI.ImageCreate(_DungeonWnd, "PIC3", "1800200010", 0, 200, false, 254, 198)
    SetAnchorAndPivot(_PIC3, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --进度节点
    --local _ScheduleNode = GUI.ImageCreate(_DungeonWnd, "ScheduleNode", "", 0, 0, false, 0, 0)
    local _ScheduleNode = GUI.GroupCreate(_DungeonWnd, "ScheduleNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_ScheduleNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_ScheduleNode, true)

    local _ScheduleTitle = GUI.CreateStatic(_ScheduleNode, "ScheduleTitle", "副本进度", 10, 10, 200, 30)
    SetAnchorAndPivot(_ScheduleTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_ScheduleTitle, 21)
    GUI.SetColor(_ScheduleTitle, colorP)

    local bg = GUI.ImageCreate(_ScheduleNode, "ScheduleBootstrapBG", "1800608510", 13, 58, false, 0, 0)
    SetAnchorAndPivot(bg, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ImageSetType(bg, SpriteType.Filled)
    GUI.SetImageFillMethod(bg, SpriteFillMethod.Horizontal_Left)
    GUI.SetImageFillAmount(bg, 1)

    local _ScheduleBootstrap = GUI.ImageCreate(_ScheduleNode, "ScheduleBootstrap", "1800608511", 13, 58, false, 0, 0)
    GuidCacheUtil.BindName(_ScheduleBootstrap, "ScheduleBootstrap")
    SetAnchorAndPivot(_ScheduleBootstrap, UIAnchor.Left, UIAroundPivot.Left)
    GUI.ImageSetType(_ScheduleBootstrap, SpriteType.Filled)
    GUI.SetImageFillMethod(_ScheduleBootstrap, SpriteFillMethod.Horizontal_Left)

    local _ScheduleTitleNum = GUI.CreateStatic(_ScheduleNode, "ScheduleTitleNum", "", 254 / 2, 58, 150, 30)
    GuidCacheUtil.BindName(_ScheduleTitleNum, "ScheduleTitleNum")
    SetAnchorAndPivot(_ScheduleTitleNum, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(_ScheduleTitleNum, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(_ScheduleTitleNum, 18)
    GUI.SetColor(_ScheduleTitleNum, colorWhite)

    --信息节点
    --local _InfNode = GUI.ImageCreate(_DungeonWnd, "InfNode", "", 0, 0, false, 0, 0)
    local _InfNode = GUI.GroupCreate(_DungeonWnd, "InfNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_InfNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_InfNode, true)

    local _InfTitle = GUI.CreateStatic(_InfNode, "ScheduleTitle", "追踪信息", 10, 85, 200, 30)
    SetAnchorAndPivot(_InfTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_InfTitle, 21)
    GUI.SetColor(_InfTitle, colorP)

    local _InfTxt = GUI.RichEditCreate(_InfNode, "InfTxt", "", 10, 118, 220, 90)
    GuidCacheUtil.BindName(_InfTxt, "InfTxt")
    SetAnchorAndPivot(_InfTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_InfTxt, 18);
    GUI.SetColor(_InfTxt, colorWhite);
    _InfTxt:RegisterEvent(UCE.PointerClick);
    GUI.StaticSetAlignment(_InfTxt, TextAnchor.UpperLeft)
    GUI.RegisterUIEvent(_InfTxt, UCE.PointerClick, "TrackWnd", "OnClickQuestContent")
    --CL.RegisterMessage(GM.QuestInfoUpdate, "TrackWnd", "OnQuestInfoUpdate");

    --奖励节点
    --local _GiftNode = GUI.ImageCreate(_DungeonWnd, "GiftNode", "", 0, 0, false, 0, 0)
    local _GiftNode = GUI.GroupCreate(_DungeonWnd, "GiftNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_GiftNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_GiftNode, true)

    local _GiftTitle = GUI.CreateStatic(_InfNode, "GiftTitle", "副本奖励", 10, 205, 200, 30)
    SetAnchorAndPivot(_GiftTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_GiftTitle, 21)
    GUI.SetColor(_GiftTitle, colorP)

    --经验
    local _GiftExpBG = GUI.ImageCreate(_GiftNode, "GiftExpBG", "1800600810", 10, 240, false, 0, 0)
    GuidCacheUtil.BindName(_GiftExpBG, "GiftExpBG")
    SetAnchorAndPivot(_GiftExpBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _GiftExpIcon = GUI.ImageCreate(_GiftNode, "GiftExpIcon", "1800408330", 9, 239, false, 28, 28)
    GuidCacheUtil.BindName(_GiftExpIcon, "GiftExpIcon")
    SetAnchorAndPivot(_GiftExpIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _GiftExpFirst = GUI.ImageCreate(_GiftNode, "GiftExpFirst", "1800604400", 5, 230, false, 0, 0)
    GuidCacheUtil.BindName(_GiftExpFirst, "GiftExpFirst")
    SetAnchorAndPivot(_GiftExpFirst, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_GiftExpFirst, false)

    local _GiftExpTxt = GUI.CreateStatic(_GiftNode, "GiftExpTxt", "", 85, 253, 90, 30)
    GuidCacheUtil.BindName(_GiftExpTxt, "GiftExpTxt")
    SetAnchorAndPivot(_GiftExpTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_GiftExpTxt, 18)
    GUI.SetColor(_GiftExpTxt, colorWhite)

    --银币
    local _GiftGoldBG = GUI.ImageCreate(_GiftNode, "GiftGoldBG", "1800600810", 130, 240, false, 0, 0)
    GuidCacheUtil.BindName(_GiftGoldBG, "GiftGoldBG")
    SetAnchorAndPivot(_GiftGoldBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _GiftGoldIcon = GUI.ImageCreate(_GiftNode, "GiftGoldIcon", "1800408280", 130, 239, false, 28, 28)
    GuidCacheUtil.BindName(_GiftGoldIcon, "GiftGoldIcon")
    SetAnchorAndPivot(_GiftGoldIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _GiftGoldFirst = GUI.ImageCreate(_GiftNode, "GiftGoldFirst", "1800604400", 125, 230, false, 0, 0)
    GuidCacheUtil.BindName(_GiftGoldFirst, "GiftGoldFirst")
    SetAnchorAndPivot(_GiftGoldFirst, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_GiftGoldFirst, false)

    local _GiftGoldTxt = GUI.CreateStatic(_GiftNode, "GiftGoldTxt", "", 205, 253, 90, 30)
    GuidCacheUtil.BindName(_GiftGoldTxt, "GiftGoldTxt")
    SetAnchorAndPivot(_GiftGoldTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_GiftGoldTxt, 18)
    GUI.SetColor(_GiftGoldTxt, colorWhite)

    --奖励物品节点
    --local _GiftItemNode = GUI.ImageCreate(_DungeonWnd, "GiftItemNode", "", 0, 35, false, 0, 0)
    local _GiftItemNode = GUI.GroupCreate(_DungeonWnd, "GiftItemNode", 0, 35, 0, 0)
    SetAnchorAndPivot(_GiftItemNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_GiftItemNode, true)

    local RewardScroll = GUI.LoopScrollRectCreate(_GiftItemNode, "RewardScroll", 10, 245, 230, 50,
            "TrackWnd", "CreateRewardItem", "TrackWnd", "RefreshRewardScroll", 0, true, Vector2.New(50, 50), 1, UIAroundPivot.Left, UIAnchor.Left)
    GUI.ScrollRectSetChildSpacing(RewardScroll, Vector2.New(0, 10))
    GuidCacheUtil.BindName(RewardScroll, "RewardScroll")

    --倒计时
    local _Countdown = GUI.CreateStatic(_DungeonWnd, "Countdown", "00:00", 30, -173, 150, 30)
    GuidCacheUtil.BindName(_Countdown, "Countdown")
    SetAnchorAndPivot(_Countdown, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(_Countdown, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(_Countdown, 22)
    GUI.SetColor(_Countdown, colorWhite)
    GUI.SetVisible(_Countdown, false)

    --退出按钮
    local _ExitBtn = GUI.ButtonCreate(_DungeonWnd, "ExitBtn", "1800602020", 65, 345, Transition.ColorTint, "退出")
    SetAnchorAndPivot(_ExitBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_ExitBtn, 26)
    GUI.ButtonSetTextColor(_ExitBtn, colorDark)
    GUI.SetIsOutLine(_ExitBtn, true)
    GUI.RegisterUIEvent(_ExitBtn, UCE.PointerClick, "TrackWnd", "OnClickExitBtn")

    TrackWnd.UpdateTimer = Timer.New(TrackWnd.SurplusTimer, 1, -1, true)

    --以下为挖矿界面组件
    local MiningParent = GUI.ImageCreate(_TrackWnd, "MiningParent", "1800200010", -223, 24, false, 254, 392)
    SetAnchorAndPivot(MiningParent, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(MiningParent, false)

    local img1 = GUI.ImageCreate(MiningParent, "img1", "1800700290", 7, 25, false, 0, 0)
    SetAnchorAndPivot(img1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(img1, true)

    local MiningTitle = GUI.CreateStatic(MiningParent, "MiningTitle", "项目统计", 35, 10, 0, 0)
    SetAnchorAndPivot(MiningTitle, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(MiningTitle, 22)
    GUI.SetColor(MiningTitle, colorWhite)

    local bg1 = GUI.ImageCreate(MiningParent, "bg1", "1800700030", (254 - 200) / 2, 35, false, 210, 220);
    GUI.SetColor(bg1, Color.New(255 / 255, 255 / 255, 255 / 255, 80 / 255));
    SetAnchorAndPivot(bg1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local sum_score = GUI.CreateStatic(MiningParent, "sum_score", "总积分：", 71, 51, 190, 90);
    SetAnchorAndPivot(sum_score, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(sum_score, 20);
    GUI.SetColor(sum_score, colorWhite);
    GUI.StaticSetAlignment(sum_score, TextAnchor.UpperLeft)

    local socre_list = GUI.CreateStatic(MiningParent, "socre_list", "", 71, 82, 190, 100);
    SetAnchorAndPivot(socre_list, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(socre_list, 20);
    GUI.SetColor(socre_list, colorWhite);
    GUI.StaticSetAlignment(socre_list, TextAnchor.UpperLeft)

    local img2 = GUI.ImageCreate(MiningParent, "img2", "1800700290", 7, 288, false, 0, 0)
    SetAnchorAndPivot(img2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(img2, true)

    local MiningTitle2 = GUI.CreateStatic(MiningParent, "MiningTitle2", "剩余时间", 35, 273, 0, 0)
    SetAnchorAndPivot(MiningTitle2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(MiningTitle2, 22)
    GUI.SetColor(MiningTitle2, colorWhite)

    local timerbg = GUI.ImageCreate(MiningParent, "timerbg", "1800700030", 27, 298, false, 210, 40);
    GUI.SetColor(timerbg, Color.New(255 / 255, 255 / 255, 255 / 255, 80 / 255));
    SetAnchorAndPivot(timerbg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local clocltext = GUI.CreateStatic(timerbg, "clocltext", "  :  :  ", 0, 0, 190, 90);
    SetAnchorAndPivot(clocltext, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(clocltext, 20);
    GUI.SetColor(clocltext, colorWhite);
    GUI.StaticSetAlignment(clocltext, TextAnchor.MiddleCenter)

    _ExitBtn = GUI.ButtonCreate(MiningParent, "ExitBtn", "1800202260", (254 - 104) / 2, 345, Transition.ColorTint, "退出")
    SetAnchorAndPivot(_ExitBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_ExitBtn, 26)
    GUI.ButtonSetTextColor(_ExitBtn, colorDark)
    GUI.SetIsOutLine(_ExitBtn, true)
    GUI.RegisterUIEvent(_ExitBtn, UCE.PointerClick, "TrackWnd", "OnClickExitBtn")

    --挂机
    --local _GuaJiNode = GUI.ImageCreate(_DungeonWnd, "GuaJiNode", "", 140, 0, false, 0, 0)
    --SetAnchorAndPivot(_GuaJiNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    --GUI.SetVisible(_GuaJiNode, true)
    --
    --local _GuaJiGroup = GUI.GroupCreate(_GuaJiNode, "GuaJiGroup", -300, 85, 218, 78)
    --SetAnchorAndPivot(_GuaJiGroup, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    --GUI.StartGroupDrag(_GuaJiGroup)
    --
    --local _GuaJiPic = GUI.ButtonCreate(_GuaJiGroup, "GuaJiPic", "1800602270", 0, 0, Transition.ColorTint);
    --SetAnchorAndPivot(_GuaJiPic, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.RegisterUIEvent(_GuaJiPic, UCE.PointerClick, "TrackWnd", "OnClickGuaJi")
    --
    --local Label = GUI.ImageCreate(_GuaJiPic, "Label", "1801504120", 0, -5, true, 0, 0)
    --SetAnchorAndPivot(Label, UIAnchor.Bottom, UIAroundPivot.Center)
    --
    --local _GuaJiPic1 = GUI.ButtonCreate(_GuaJiGroup, "GuaJiPic1", "1800602250", 0, 0, Transition.ColorTint);
    --SetAnchorAndPivot(_GuaJiPic1, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.RegisterUIEvent(_GuaJiPic1, UCE.PointerClick, "TrackWnd", "OnClickGuaJi")
    --GUI.SetVisible(_GuaJiPic1, false)
    --
    --local Label1 = GUI.ImageCreate(_GuaJiPic1, "Label1", "1800604480", 0, -5, true, 0, 0)
    --SetAnchorAndPivot(Label1, UIAnchor.Bottom, UIAroundPivot.Center)

    TrackWnd.RegisterMessage(true)
end

-- 注册GM消息
function TrackWnd.RegisterMessage(isRes)
    for k, v in ipairs(messageEventList) do
        CL.UnRegisterMessage(v[1], "TrackWnd", v[2])
        if isRes then
            CL.RegisterMessage(v[1], "TrackWnd", v[2])
        end
    end
end

function TrackWnd.SetTrackRate(now, all)
    now = tonumber(now)
    all = tonumber(all)
    local _ScheduleTitleNum = GuidCacheUtil.GetUI("ScheduleTitleNum")
    if _ScheduleTitleNum then
        GUI.StaticSetText(_ScheduleTitleNum,  now .. "/" .. all)
    end
    local _ScheduleBootstrap = GuidCacheUtil.GetUI("ScheduleBootstrap")
    if _ScheduleBootstrap then
        GUI.SetImageFillAmount(_ScheduleBootstrap, now / all)
    end
end

function TrackWnd.Refresh()
    local data = TrackWnd.serverData
    TrackWnd.Second = math.floor((data.DeadlineSec - CL.GetServerTickCount()))
    if IsFirstEnter then
        IsFirstEnter = false
        TrackWnd.ShowTheInf(false)
        TrackWnd.TimeStart(TrackWnd.Second)
    end
    TrackWnd.SetTrackRate(data.NowStep, data.MaxStep)
    TrackWnd.SetInf(data.TraceMsg)
    TrackWnd.SetExp(data.RewardExp)
    TrackWnd.SetGold(data.RewardMoney)
    local rewards = data.RewardItem
    local temp = {}
    local count = math.floor(#rewards / 3)
    for i = 1, count do
        local idx = (i - 1) * 3 + 1
        temp[#temp + 1] = {
            rewards[idx],
            rewards[idx + 1],
            rewards[idx + 2],
        }
    end
    TrackWnd.ItemReward = temp
    local scroll = GuidCacheUtil.GetUI("RewardScroll")
    GUI.LoopScrollRectSetTotalCount(scroll, count)
    GUI.LoopScrollRectRefreshCells(scroll)
end

function TrackWnd.TeamInfoUpdate()
    local _RoleNum = LD.GetTeamRoleCount()
    if _RoleNum ~= 0 then
        local isTeamLeader = LD.GetRoleInTeamState(0)
        local btn = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/ExitBtn")
        if isTeamLeader == 2 then
            GUI.SetInteractable(btn, true)
        else
            GUI.SetInteractable(btn, false)
        end
    end
end

function TrackWnd.OnClickTrackArrow(guid)
    local _DungeonTitleBack = GuidCacheUtil.GetUI("DungeonTitleBack") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonTitleBack")
    local _DungeonTrackArrow = GuidCacheUtil.GetUI("DungeonTrackArrow") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonTrackArrow")
    local _DungeonBtn = GuidCacheUtil.GetUI("DungeonBtn")--GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonTitleBack/DungeonBtn")
    local _RoleLstBack = GUI.Get("TrackUI/TrackNode/RoleLstBack")
    local _DungeonWnd = GuidCacheUtil.GetUI("DungeonWnd") --GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd")

    if _DungeonBtn ~= nil and _DungeonTrackArrow ~= nil and _DungeonTitleBack ~= nil then
        local IsShow = GUI.GetVisible(_DungeonTitleBack) == false
        GUI.SetVisible(_DungeonTitleBack, IsShow)
        local IsDungeonShow = GUI.GetVisible(_DungeonBtn)
        GUI.SetVisible(_RoleLstBack, IsDungeonShow == false and IsShow)
        GUI.SetVisible(_DungeonWnd, IsDungeonShow and IsShow)
        if GUI.GetVisible(_DungeonTitleBack) then
            GUI.ButtonSetImageID(_DungeonTrackArrow, 1800202270)
        else
            GUI.ButtonSetImageID(_DungeonTrackArrow, 1800202280)
        end
    end
end

function TrackWnd.OnClickTitleBack(guid)
    local _DungeonBtn = GuidCacheUtil.GetUI("DungeonBtn") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonTitleBack/DungeonBtn")
    if _DungeonBtn then
        local IsDungeonShow = GUI.GetVisible(_DungeonBtn)
        TrackWnd.ShowTheInf(IsDungeonShow)
    end
end

function TrackWnd.ShowTheInf(IsDungeonShow)
    local _DungeonTeamBtn = GuidCacheUtil.GetUI("DungeonTeamBtn") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonTitleBack/DungeonTeamBtn")
    local _DungeonTitleTeam = GuidCacheUtil.GetUI("DungeonTitleTeam") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonTitleBack/DungeonTitleTeam")
    local _DungeonBtn = GuidCacheUtil.GetUI("DungeonBtn") --GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonTitleBack/DungeonBtn")
    local _TitleDungeon = GuidCacheUtil.GetUI("TitleDungeon") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonTitleBack/TitleDungeon")
    local panelCover = GuidCacheUtil.GetUI("panelCover") GUI.Get("TrackUI/TrackNode/TrackWnd/panelCover")

    if _DungeonTeamBtn ~= nil and _DungeonTitleTeam ~= nil and _DungeonBtn ~= nil and _TitleDungeon ~= nil then
        GUI.SetVisible(_DungeonTeamBtn, IsDungeonShow)
        GUI.SetVisible(_DungeonBtn, not IsDungeonShow)
        if IsDungeonShow then
            TrackWnd.SetDungeonWndVisible(false)
            TrackWnd.SetRoleLstBackVisible(true)
            GUI.SetVisible(panelCover, false)
            GUI.SetColor(_DungeonTitleTeam, colorDark)
            GUI.SetColor(_TitleDungeon, colorWhite)
        else
            TrackWnd.SetRoleLstBackVisible(false)
            TrackWnd.SetDungeonWndVisible(true)
            GUI.SetVisible(panelCover, true)
            GUI.SetColor(_TitleDungeon, colorDark)
            GUI.SetColor(_DungeonTitleTeam, colorWhite)
        end
    end
end

function TrackWnd.OnClickDungeonTeamBtn(key)
    local _DungeonTeamBtn = GuidCacheUtil.GetUI("DungeonTeamBtn") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonTitleBack/DungeonTeamBtn")
    if _DungeonTeamBtn ~= nil then
        if GUI.GetVisible(_DungeonTeamBtn) == false then
            --切换到队伍页签
            TrackWnd.ShowTheInf(true)
        else
            --打开组队界面
            -- TODO: 判断是否达到打开组队面板的等级
            GUI.OpenWnd("TeamPanelUI")
        end
    end
end

function TrackWnd.SetType(int)
    local tpye = int
    local _ExitBtn = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/ExitBtn")
    local ExitType = "" .. tpye
    GUI.SetData(_ExitBtn, "GetQuiteType", ExitType)

    local Dungeon = GuidCacheUtil.GetUI("DungeonWnd")
    --将挖矿显示，副本隐藏 9挖矿 1副本 2秘境
    if tonumber(tpye) == 9 then
        GUI.SetVisible(Dungeon, false)
        local Mining = GUI.Get("TrackUI/TrackNode/TrackWnd/MiningParent")
        GUI.SetVisible(Mining, true)
        local _GuaJiNode = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GuaJiNode")
        GUI.SetVisible(_GuaJiNode, false)
    elseif tonumber(tpye) == 1 then
        GUI.SetVisible(Dungeon, true)
        local Mining = GUI.Get("TrackUI/TrackNode/TrackWnd/MiningParent")
        GUI.SetVisible(Mining, false)
        local _GuaJiNode = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GuaJiNode")
        GUI.SetVisible(_GuaJiNode, false)
    elseif tonumber(tpye) == 2 then
        GUI.SetVisible(Dungeon, true)
        local Mining = GUI.Get("TrackUI/TrackNode/TrackWnd/MiningParent")
        GUI.SetVisible(Mining, false)
        local _GuaJiNode = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GuaJiNode")
        GUI.SetVisible(_GuaJiNode, true)

        --进入重置挂机状态
        TrackWnd.GuaJI_Type = 0
        TrackWnd.Set_Guaji_Pic(TrackWnd.GuaJI_Type)

        CL.RegisterMessage(GM.OnRefreshAutoMove, "TrackWnd", "OnRefreshAutoMove");

        local _GuaJiPic = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GuaJiNode/GuaJiGroup/GuaJiPic")
        GUI.SetVisible(_GuaJiPic, true)
        local _GuaJiPic1 = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GuaJiNode/GuaJiGroup/GuaJiPic1")
        GUI.SetVisible(_GuaJiPic1, false)
    end
end

function TrackWnd.Set_Guaji_Pic(int)
    int = tonumber(int)
    local _GuaJiPic = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GuaJiNode/GuaJiGroup/GuaJiPic")
    local _GuaJiPic1 = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GuaJiNode/GuaJiGroup/GuaJiPic1")
    if int == 0 then
        GUI.SetVisible(_GuaJiPic, true)
        GUI.SetVisible(_GuaJiPic1, false)
    elseif int == 1 then
        GUI.SetVisible(_GuaJiPic, false)
        GUI.SetVisible(_GuaJiPic1, true)
    elseif int == 2 then
        GUI.SetVisible(_GuaJiPic, false)
        GUI.SetVisible(_GuaJiPic1, true)
    end
end

function TrackWnd.OnClickExitBtn(key)
    CL.SendNotify(NOTIFY.SubmitForm, "FormDungeon", "ClickQuit")
    --local isTeamLeader = LD.GetRoleInTeamState(0)
    --local _RoleNum = LD.GetTeamRoleCount()
    --if _RoleNum ~= 0 then
    --    if isTeamLeader ~= 2 then
    --        GUI.OpenWnd("ConfirmBox")
    --        ConfirmBox.OnlyConfirm("只有队长才可以操作。")
    --        return
    --    end
    --end
    --print("TrackWnd.ConfirmType = " .. (TrackWnd.ConfirmType or type(TrackWnd.ConfirmType)))
    --
    --local _ExitBtn = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/ExitBtn")
    --local param = tonumber(GUI.GetData(_ExitBtn, "GetQuiteType"))
    ----test("进入OnClickExitBtn，param = "..tostring(param))
    --if param then
    --    if param == 0 then
    --        GUI.OpenWnd("ConfirmBox")
    --        ConfirmBox.SetMode(0, "确认退出PVP战场吗？")
    --    elseif param == 1 then
    --        if TrackWnd.ConfirmType then
    --            GUI.OpenWnd("ConfirmBox")
    --            --test("TrackWnd.ConfirmType = "..tostring(TrackWnd.ConfirmType))
    --            ConfirmBox.SetMode(TrackWnd.ConfirmType, TrackWnd.ConfirmStr or "确认退出当前副本吗？")
    --        end
    --    elseif param == 2 then
    --        if TrackWnd.ConfirmType then
    --            --test("aaaaa")
    --
    --            CL.SendNotify(NOTIFY.SubmitForm, "FormList", "remove_trigger_all_EX")
    --            TrackWnd.GuaJI_Type = 0
    --            TrackWnd.Set_Guaji_Pic(TrackWnd.GuaJI_Type)
    --
    --            GUI.OpenWnd("ConfirmBox")
    --            ConfirmBox.SetMode(TrackWnd.ConfirmType, TrackWnd.ConfirmStr or "确认退出当前秘境吗？")
    --        end
    --    elseif param == 9 then
    --        GUI.OpenWnd("ConfirmBox")
    --        ConfirmBox.SetMode(param, "退出后不可再进入，确认退出秘境吗？")
    --    end
    --end
end

function TrackWnd.SetGold(date_gold, isFirst)
    local _GiftGoldFirst = GuidCacheUtil.GetUI("GiftGoldFirst") --GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GiftNode/GiftGoldFirst")
    local _GiftGoldTxt = GuidCacheUtil.GetUI("GiftGoldTxt") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GiftNode/GiftGoldTxt")
    local _GiftGoldBG = GuidCacheUtil.GetUI("GiftGoldBG") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GiftNode/GiftGoldBG")
    local _GiftGoldIcon = GuidCacheUtil.GetUI("GiftGoldIcon") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GiftNode/GiftGoldIcon")

    if _GiftGoldFirst ~= nil and _GiftGoldTxt ~= nil then
        if tonumber(date_gold) == -1 then
            GUI.SetVisible(_GiftGoldFirst, false)
            GUI.SetVisible(_GiftGoldTxt, false)
            GUI.SetVisible(_GiftGoldBG, false)
            GUI.SetVisible(_GiftGoldIcon, false)
        else
            GUI.SetVisible(_GiftGoldTxt, true)
            GUI.SetVisible(_GiftGoldBG, true)
            GUI.SetVisible(_GiftGoldIcon, true)
            GUI.SetVisible(_GiftGoldFirst, isFirst)
            GUI.StaticSetText(_GiftGoldTxt, date_gold)
        end
    end
end

function TrackWnd.SetExp(date_exp, isFirst)
    local _GiftExpFirst = GuidCacheUtil.GetUI("GiftExpFirst") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GiftNode/GiftExpFirst")
    local _GiftExpTxt = GuidCacheUtil.GetUI("GiftExpTxt") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GiftNode/GiftExpTxt")
    local _GiftExpIcon = GuidCacheUtil.GetUI("GiftExpIcon") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GiftNode/GiftExpIcon")
    local _GiftExpBG = GuidCacheUtil.GetUI("GiftExpBG") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/GiftNode/GiftExpBG")

    if _GiftExpFirst ~= nil and _GiftExpTxt ~= nil then
        if tonumber(date_exp) == -1 then
            GUI.SetVisible(_GiftExpFirst, false)
            GUI.SetVisible(_GiftExpTxt, false)
            GUI.SetVisible(_GiftExpIcon, false)
            GUI.SetVisible(_GiftExpBG, false)
        else
            GUI.SetVisible(_GiftExpTxt, true)
            GUI.SetVisible(_GiftExpIcon, true)
            GUI.SetVisible(_GiftExpBG, true)
            GUI.SetVisible(_GiftExpFirst, isFirst)
            GUI.StaticSetText(_GiftExpTxt, date_exp)
        end
    end
end

function TrackWnd.CreateRewardItem()
    local rewardScroll = GuidCacheUtil.GetUI("RewardScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(rewardScroll)
    local item = GUI.ItemCtrlCreate(rewardScroll, "GiftItemBg" .. curCount, "1800600050", 0, 0, 50, 50, false)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "TrackWnd", "on_item_click")
    local FirstRewardIcon = GUI.ImageCreate(item, "FirstRewardIcon", "1800604400", 0,0, false, 38, 24)
	return item
end

function TrackWnd.RefreshRewardScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local item = GUI.GetByGuid(guid)
    local data = TrackWnd.ItemReward[index + 1]
    local DBItem = DB.GetOnceItemByKey2(data[1])
	local FirstRewardIcon = GUI.GetChild(item, "FirstRewardIcon", false)
    if DBItem.Id == 0 then
        GUI.SetVisible(item, false)
        return
    end
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, DBItem.Icon)
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, data[2])
    local grade = QualityRes[DBItem.Grade]
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, grade)
    GUI.SetData(item, "item", DBItem.Id)
	
	if TrackWnd.serverData["IsFirstReward"] == 1 then
		GUI.SetVisible(FirstRewardIcon, true)
	else
		GUI.SetVisible(FirstRewardIcon, false)
	end
end

function TrackWnd.on_item_click(guid)
    local _Panel = GUI.GetWnd("TrackUI")--GuidCacheUtil.GetUI("TrackUI")
    local panelCover = GUI.ImageCreate( _Panel , "TrackWnd_PanelCover" , "1800400220" , 0 , 0 , false , 1280 , 720);
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover,true)
    GUI.SetColor(panelCover, UIDefine.Transparent)
    GUI.SetVisible(panelCover,true);
    panelCover:RegisterEvent(UCE.PointerClick)
    local item_bg = GUI.GetByGuid(guid)
    local item = tonumber(GUI.GetData(item_bg, "item"))
    local x = 185
    local y = 23
    local itemTips = Tips.CreateByItemId(item, panelCover, "itemTips", x, y)
    GUI.SetIsRemoveWhenClick(panelCover,true)
end

function TrackWnd.SetInf(str)
    local _InfTxt = GuidCacheUtil.GetUI("InfTxt")
    if _InfTxt then
        GUI.StaticSetText(_InfTxt, tostring(str))
    end
end

function TrackWnd.OnQuestInfoUpdate()
    if TrackWnd.isfinish ~= 1 then
        if TrackWnd.QuestID then
            local questInf = LD.GetQuestShowInfo(tonumber(TrackWnd.QuestID))
            local _InfTxt = GuidCacheUtil.GetUI("InfTxt") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/InfNode/InfTxt")
            if questInf then
                if _InfTxt then
                    GUI.StaticSetText(_InfTxt, questInf.TargetInfo)
                end
            end
        end
    end
end

function TrackWnd.SetQuestInf(quest_id)
    TrackWnd.QuestID = quest_id
    local questInf = LD.GetQuestShowInfo(tonumber(quest_id))
    local _InfTxt = GuidCacheUtil.GetUI("InfTxt") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/InfNode/InfTxt")

    if questInf then
        if _InfTxt then
            GUI.StaticSetText(_InfTxt, questInf.TargetInfo)
        end
    end
end

function TrackWnd.OnClickQuestContent(key)
    TrackWnd.XunLu()
end

function TrackWnd.XunLu()
    local data = TrackWnd.serverData.TraceAim
    if not data or not next(data) then
        CL.SendNotify(NOTIFY.ShowBBMsg, "无法寻路到目标")
        return
    end
    CL.StartMove(data[2], CL.ChangeLogicPosZ(data[3])) --,CL.GetCurrentMapId()
    if data[4] ~= 1 then
        local DBconfig = DB.GetOnceNpcByKey2(data[1])
        CL.SetMoveEndAction(MoveEndAction.SelectNpc, DBconfig.Id)
    end
end

function TrackWnd.OnRefreshAutoMove()
    if TrackWnd.GuaJI_Type == 2 then
        TrackWnd.GuaJI_Type = 1
    elseif TrackWnd.GuaJI_Type == 1 or TrackWnd.GuaJI_Type == 3 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormList", "remove_trigger_all")
        TrackWnd.GuaJI_Type = 0
        TrackWnd.Set_Guaji_Pic(TrackWnd.GuaJI_Type)
    end
end

function TrackWnd.IsNpcTalkOpen(open_type)
    open_type = tonumber(open_type)
    if open_type == 1 then
        if not GUI.GetVisible(GUI.GetWnd("NpcDialogBoxUI")) then
            TrackWnd.OnClickGuaJi()
            return
        end
        if TrackWnd.TalkNpc ~= nil and TrackWnd.TalkNpc ~= "" and TrackWnd.TalkNpc ~= "0" then
            CL.SendNotify(NOTIFY.SubmitForm, "FormList", "trigger_npc_fight", 1, TrackWnd.TalkNpc)
        end
    elseif open_type == 2 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormList", "on_click_trackWnd_questcontent")
    end
end

function TrackWnd.TimeStart(second)
    TrackWnd.SetCountdownVisible(1)
    TrackWnd.Second = tonumber(second)
    TrackWnd.UpdateTimer:Start()
end

function TrackWnd.SurplusTimer()
    if not TrackWnd.Second then
        return
    end

    if TrackWnd.Second <= 0 then
        TrackWnd.UpdateTimer:Stop()
    else
        TrackWnd.Second = TrackWnd.Second - 1
    end

    local timeStr = GlobalUtils.GetTimeString(TrackWnd.Second)

    local _Countdown = GuidCacheUtil.GetUI("Countdown") --GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/Countdown")
    local _ExitBtn = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/ExitBtn")
    local data = tonumber(GUI.GetData(_ExitBtn, "GetQuiteType"))

    --如果是挖矿，用挖矿覆盖副本倒计时
    if data == 9 then
        _Countdown = GUI.Get("TrackUI/TrackNode/TrackWnd/MiningParent/timerbg/clocltext")
        GUI.StaticSetText(_Countdown, timeStr)
    elseif _Countdown then
        GUI.StaticSetText(_Countdown, timeStr)
    end
end

function TrackWnd.CloseTrackWnd()
    IsFirstEnter = true
    local _TrackWnd = GuidCacheUtil.GetUI("TrackWnd") -- GUI.Get("TrackUI/TrackNode/TrackWnd")
    GUI.Destroy(_TrackWnd)
    TrackWnd.SetTrackArrowVisible(true)
    TrackWnd.SetTitleBackVisible(true)
    TrackWnd.SetQuestLstBackVisible(true)
    TrackWnd.SetRoleLstBackVisible(false)
    if TrackWnd.UpdateTimer then
        TrackWnd.UpdateTimer:Stop()
    end
	TrackUI.OnSwitchTrackPanel(1)
    TrackWnd.RegisterMessage(false)
end

function TrackWnd.SetCountdownVisible(int)
    local _Countdown = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/Countdown")
    if int == 1 then
        if _Countdown then
            GUI.SetVisible(_Countdown, true)
        end
    elseif int == 0 then
        if _Countdown then
            GUI.SetVisible(_Countdown, false)
        end
    end
end

function TrackWnd.SetDungeonWndVisible(bool)
    local _DungeonWnd = GuidCacheUtil.GetUI("DungeonWnd") -- GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd")
    local _ExitBtn = GUI.Get("TrackUI/TrackNode/TrackWnd/DungeonWnd/ExitBtn")
    local data = tonumber(GUI.GetData(_ExitBtn, "GetQuiteType"))
    --如果是挖矿，用挖矿覆盖副本trackwnd
    if data == 9 then
        _DungeonWnd = GUI.Get("TrackUI/TrackNode/TrackWnd/MiningParent")
    end
    if _DungeonWnd then
        GUI.SetVisible(_DungeonWnd, bool)
    end
end

function TrackWnd.SetRoleLstBackVisible(bool)
    local _RoleLstBack = GUI.Get("TrackUI/TrackNode/RoleLstBack")
    if _RoleLstBack then
        GUI.SetVisible(_RoleLstBack, bool)
    end
end

function TrackWnd.SetQuestLstBackVisible(bool)
    local _QuestLstBack = GUI.Get("TrackUI/TrackNode/QuestLstBack")
    if _QuestLstBack then
        GUI.SetVisible(_QuestLstBack, bool)
        if bool == true then
            local QuestBtn = GUI.Get("TrackUI/TrackNode/TitleBack/QuestBtn")
            local TeamBtn = GUI.Get("TrackUI/TrackNode/TitleBack/TeamBtn")
            local TitleQuest = GUI.Get("TrackUI/TrackNode/TitleBack/TitleQuest")
            local TitleTeam = GUI.Get("TrackUI/TrackNode/TitleBack/TitleTeam")
            GUI.SetVisible(QuestBtn, true)
            GUI.SetVisible(TeamBtn, false)
            GUI.SetColor(TitleQuest, colorDark)
            GUI.SetColor(TitleTeam, colorWhite)
        end
    end

    local _VipInfoPanel = GUI.Get("TrackUI/TrackNode/VipInfoPanel")
    if _VipInfoPanel ~= nil then
        GUI.SetVisible(_VipInfoPanel, bool and MainUI.IsShowVipPanel)
    end
end

function TrackWnd.SetTrackArrowVisible(bool)
    local _TrackArrow = GUI.Get("TrackUI/TrackNode/TrackArrow")
    if _TrackArrow then
        GUI.SetVisible(_TrackArrow, bool)
        if bool then
            GUI.ButtonSetImageID(_TrackArrow, 1800202270)
        end
    end
end

function TrackWnd.SetTitleBackVisible(bool)
    local _TitleBack = GUI.Get("TrackUI/TrackNode/TitleBack")
    if _TitleBack then
        GUI.SetVisible(_TitleBack, bool)
    end
end

function TrackWnd.SetTrackWndVisible(bool)
    local _TrackWnd = GuidCacheUtil.GetUI("TrackWnd") -- GUI.Get("TrackUI/TrackNode/TrackWnd")
    if _TrackWnd then
        GUI.SetVisible(_TrackWnd, bool)
    end
end

--挖矿，内容文本
function TrackWnd.score_create(str1, str2)
    local title = GUI.Get("TrackUI/TrackNode/TrackWnd/MiningParent/sum_score")
    local desc = GUI.Get("TrackUI/TrackNode/TrackWnd/MiningParent/socre_list")
    if str2 then
        GUI.StaticSetText(title, "总积分：" .. str2)
    else
        GUI.StaticSetText(title, "总积分：0")
    end

    local list = loadstring("return " .. str1)()
    local str = ""
    for i = 1, #list do
        str = str .. list[i][3] .. "：" .. list[i][2] .. "\n"
        GUI.StaticSetText(desc, str)
    end
end

function TrackWnd.OnClickGuaJi()
    if TrackWnd.GuaJI_Type == 0 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormList", "on_click_trackWnd_questcontent")
        TrackWnd.GuaJI_Type = 2
        TrackWnd.Set_Guaji_Pic(TrackWnd.GuaJI_Type)
    elseif TrackWnd.GuaJI_Type == 1 or TrackWnd.GuaJI_Type == 3 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormList", "remove_trigger_all_EX")
        TrackWnd.GuaJI_Type = 0
        TrackWnd.Set_Guaji_Pic(TrackWnd.GuaJI_Type)
    end
end
