local RoleClickPopMenu = {}
_G.RoleClickPopMenu = RoleClickPopMenu
local _gt = UILayout.NewGUIDUtilTable()
require "RoleAttributeUI"

--[[
    想要增加按钮，只需要在下面的list中增加相关数据即可，记住一定要改变以下UI界面中LoopScroll的高度
]]--


RoleClickPopMenu.BtnList = {
    {
        "查看玩家",
        "playerInfo",
        0,
        function()
            CL.SendNotify(NOTIFY.SubmitForm, "FormContact", " QueryOfflinePlayer", RoleClickPopMenu.currentSelectGUID)
        end
    },
    {
        "邀请组队",
        "inviteTeam",
        0,
        function()
            MainUI.OnTeamInviteOpe(RoleClickPopMenu.currentSelectGUID)
            --CL.SendNotify(NOTIFY.ShowBBMsg, "邀请信息已发送")
        end
    },
    {
        "加为好友",
        "friend",
        0,
        function()
            if LD.IsMyFriend(RoleClickPopMenu.currentSelectGUID) then
                local target_name = RoleClickPopMenu.currentSlectTable[2]
                local msg = "您是否要删除您的好友<color=#0000ff>" .. target_name .. "</color>？"
                GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", msg, "RoleClickPopMenu", "确定", "delete_friend", "取消")
                --CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "DeleteFriend", RoleClickPopMenu.currentSelectGUID) -- 删除好友
                test("删除好友")
            else
                CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyFriend", RoleClickPopMenu.currentSelectGUID)
                test("加为好友")
            end
        end
    },
    {
        "邀请入帮",
        "inviteFaction",
        0,
        function()
            if (RoleClickPopMenu.IsQueryPlayerInfo and LD.GetQueryPlayerStrCustomData("__title_guild_name")) or RoleClickPopMenu.GetRoleAttr(RoleAttr.RoleAttrIsGuild, TOOLKIT.Str2uLong(RoleClickPopMenu.currentSelectGUID)) == 1 then
                --对方有帮派无法邀请
                CL.SendNotify(NOTIFY.ShowBBMsg, "对方已有帮派，无法邀请")
            else
                CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 19, RoleClickPopMenu.currentSelectGUID)
            end
            test("邀请入帮")
        end
    },
    {
        "切磋",
        "athleticsOrPk",
        0,
        function()
            local state = RoleClickPopMenu.GetRoleAttr(RoleAttr.RoleAttrIsFight, TOOLKIT.Str2uLong(RoleClickPopMenu.currentSelectGUID))
            local currentMap = CL.GetCurrentMapId()
            if state ~= nil and state == 0 then
                if currentMap ~= nil and currentMap ~= 210 then
                    test("PK")
                    CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "joinFight", RoleClickPopMenu.currentSelectGUID)
                else
                    test("切磋 " .. RoleClickPopMenu.currentSelectGUID)
                    CL.SendNotify(NOTIFY.MakeFight, 0, RoleClickPopMenu.currentSelectGUID)
                end
            else
                test("观战 " .. RoleClickPopMenu.currentSelectGUID)
                CL.SendNotify(NOTIFY.MakeFight, 1, RoleClickPopMenu.currentSelectGUID)
            end
        end
    },
    { "交易", 'to_face_transaction', 0, function()
        -- 判断自己等级是否满足
        if GlobalProcessing.ToFaceTransActionUI_server_data ~= nil and GlobalProcessing.ToFaceTransActionUI_server_data.OpenLevel ~= nil then
            local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
            if CurLevel >= GlobalProcessing.ToFaceTransActionUI_server_data.OpenLevel then
                -- 发送交易请求
                CL.SendNotify(NOTIFY.SubmitForm, "FormFaceDeal", "OpenCountDownWnd", RoleClickPopMenu.currentSelectGUID)
            else
                CL.SendNotify(NOTIFY.ShowBBMsg, "等级达到" .. GlobalProcessing.ToFaceTransActionUI_server_data.OpenLevel .. '级，开启此功能')
            end
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "未开启此功能")
        end
    end },
}

--全屏遮罩响应
RoleClickPopMenu.opeCoverGUID = 0
-- 按钮列表控件GUID
RoleClickPopMenu.opeButtonScrollGUID = 0
RoleClickPopMenu.opeButtonCurrentCount = 0
-- 点击头像控件GUID
RoleClickPopMenu.opeHeadGUID = 0
RoleClickPopMenu.opeHeadIconGUID = 0
-- 点击信息面板控件GUID
RoleClickPopMenu.opeInfoGUID = 0
--信息面板控件GUID一套
RoleClickPopMenu.infoHeadIconGUID = 0
RoleClickPopMenu.infoSchoolGUID = 0
RoleClickPopMenu.infoNameGUID = 0
RoleClickPopMenu.infoSNGUID = 0
RoleClickPopMenu.infoBangpaiGUID = 0
RoleClickPopMenu.infoLevelGUID = 0
--当前选择的GUID
RoleClickPopMenu.currentSelectGUID = 0

--当前选择信息
RoleClickPopMenu.currentSlectTable = {}
--所有响应到的信息
RoleClickPopMenu.currentAllSlectTable = {}
--多选列表控件GUID
RoleClickPopMenu.menuListGUID = 0
RoleClickPopMenu.menuListScrollGUID = 0
RoleClickPopMenu.menuListCurrentCount = 0

RoleClickPopMenu.PosX = 260
RoleClickPopMenu.PosY = 192
-- 当前是否处于表演状态
RoleClickPopMenu.IsPerforming = false
-- 是否处于观战状态
RoleClickPopMenu.IsViewFight = false
-- 是否处于在
RoleClickPopMenu.IsQueryPlayerInfo = false
-- 什么UI事件类型
RoleClickPopMenu.openRoleListUIEvent = UCE.PointerClick

--创建
function RoleClickPopMenu.Main(parameter)
    test("RoleClickPopMenu")
    RoleClickPopMenu.opeButtonScrollGUID = 0
    RoleClickPopMenu.opeButtonCurrentCount = 0
    RoleClickPopMenu.opeHeadGUID = 0
    RoleClickPopMenu.opeInfoGUID = 0
    RoleClickPopMenu.currentSelectGUID = 0

    local panel = GUI.WndCreateWnd("RoleClickPopMenu", "RoleClickPopMenu", 0, 0, eCanvasGroup.Main)
    UILayout.SetAnchorAndPivot(panel, UIAnchor.Right, UIAroundPivot.Right)
    --GUI.CreateSafeArea(panel)

    local w = GUI.GetWidth(panel)
    local h = GUI.GetHeight(panel)
    local fullCover = GUI.ImageCreate(panel, "iconCover", "1800400220", 0, 0, false, w, h)
    GUI.SetAnchor(fullCover, UIAnchor.Center)
    GUI.SetPivot(fullCover, UIAroundPivot.Center)
    GUI.SetColor(fullCover, UIDefine.Transparent)
    GUI.SetIsRaycastTarget(fullCover, true)
    fullCover:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(fullCover, UCE.PointerClick, "RoleClickPopMenu", "OnClick")
    GUI.SetVisible(fullCover, false)
    RoleClickPopMenu.opeCoverGUID = GUI.GetGuid(fullCover)

    RoleClickPopMenu.CreateMenus(panel, w, h)
    RoleClickPopMenu.CreateMenuLists(panel)

    CL.RegisterMessage(GM.ClickObject, "RoleClickPopMenu", "OnMessageHandle")
    CL.RegisterMessage(GM.ClickAllObjects, "RoleClickPopMenu", "OnMessageHandle")
    CL.RegisterMessage(GM.FightIsInActor, "RoleClickPopMenu", "OnFightPerformState")
    CL.RegisterMessage(GM.FightStateNtf, "RoleClickPopMenu", "OnFight")
end

--创建单人菜单
function RoleClickPopMenu.CreateMenus(panel, w, h)
    -- 点击头像
    local headiconBg = GUI.ImageCreate(panel, "headiconBg", "1800600070", RoleClickPopMenu.PosX, RoleClickPopMenu.PosY, false, 68, 68)
    GUI.SetAnchor(headiconBg, UIAnchor.TopRight)
    GUI.SetPivot(headiconBg, UIAroundPivot.TopRight)

    local headicon = HeadIcon.Create(headiconBg, "headicon", "1900300010", 0, 0, 60, 60)
    GUI.SetAnchor(headicon, UIAnchor.Center)
    GUI.SetPivot(headicon, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(headicon, true)
    headicon:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(headicon, UCE.PointerClick, "RoleClickPopMenu", "OnHeadIconClick")
    RoleClickPopMenu.opeHeadGUID = GUI.GetGuid(headiconBg)
    RoleClickPopMenu.opeHeadIconGUID = GUI.GetGuid(headicon)
    GUI.SetVisible(headiconBg, false)

    -- 点击后的信息
    local menuBg = GUI.ImageCreate(headiconBg, "menuBg", "1800400290", 260, 0, false, 260, 300)
    GUI.SetAnchor(menuBg, UIAnchor.TopLeft)
    GUI.SetPivot(menuBg, UIAroundPivot.TopLeft)

    -- 头像
    local infoHeadiconBg = GUI.ImageCreate(menuBg, "infoHeadiconBg", "1800600070", 10, 57, false, 66, 66)
    GUI.SetAnchor(infoHeadiconBg, UIAnchor.TopLeft)
    GUI.SetPivot(infoHeadiconBg, UIAroundPivot.TopLeft)

    local infoheadicon = HeadIcon.Create(infoHeadiconBg, "infoheadicon", "1900300010", 0, 0, 60, 60)
    GUI.SetAnchor(infoheadicon, UIAnchor.Center)
    GUI.SetPivot(infoheadicon, UIAroundPivot.Center)
    RoleClickPopMenu.infoHeadIconGUID = GUI.GetGuid(infoheadicon)

    local infobottom = GUI.ImageCreate(menuBg, "infobottom", "1800207090", 4, 30, false)
    local infobottom1 = GUI.ImageCreate(menuBg, "infobottom1", "1800207080", 20, 30, false)
    local sizeDefault = 20
    local sizeLittle = 18

    local infoTxt = GUI.CreateStatic(menuBg, "infoTxt", "名字最多六个字", 34, 12, 220, 25)
    RoleClickPopMenu.SetTextBasicInfo(infoTxt, UIDefine.WhiteColor, TextAnchor.MiddleCenter, sizeDefault)
    GUI.StaticSetFontSizeBestFit(infoTxt)
    RoleClickPopMenu.infoNameGUID = GUI.GetGuid(infoTxt)

    local size = GUI.StaticGetLabelPreferWidth(infoTxt) / 2 + 5
    local infojob = GUI.ImageCreate(menuBg, "infojob", "1800903010", -size, 12, false, 25, 24)
    GUI.SetAnchor(infojob, UIAnchor.Top)
    GUI.SetPivot(infojob, UIAroundPivot.Top)
    RoleClickPopMenu.infoSchoolGUID = GUI.GetGuid(infojob)

    local idTip = GUI.CreateStatic(menuBg, "idTip", "ID号：", 86, 55, 220, 25)
    RoleClickPopMenu.SetTextBasicInfo(idTip, UIDefine.WhiteColor, TextAnchor.MiddleLeft, sizeLittle)

    local idTxt = GUI.CreateStatic(idTip, "idTxt", "1000000", 42, -2, 100, 25)
    RoleClickPopMenu.SetTextBasicInfo(idTxt, UIDefine.GreenColor, TextAnchor.MiddleLeft, sizeLittle)
    RoleClickPopMenu.infoSNGUID = GUI.GetGuid(idTxt)

    local levelTip = GUI.CreateStatic(menuBg, "levelTip", "等级：", 83, 79, 110, 25)
    RoleClickPopMenu.SetTextBasicInfo(levelTip, UIDefine.WhiteColor, TextAnchor.MiddleLeft, sizeLittle)

    local levelTxt = GUI.CreateStatic(levelTip, "levelTxt", "0", 45, 0, 220, 25)
    RoleClickPopMenu.SetTextBasicInfo(levelTxt, UIDefine.GreenColor, TextAnchor.MiddleLeft, sizeLittle)
    --GUI.StaticSetFontSizeBestFit(levelTxt)
    RoleClickPopMenu.infoLevelGUID = GUI.GetGuid(levelTxt)

    local factionTip = GUI.CreateStatic(menuBg, "factionTip", "帮派：", 83, 104, 110, 25)
    RoleClickPopMenu.SetTextBasicInfo(factionTip, UIDefine.WhiteColor, TextAnchor.MiddleLeft, sizeLittle)
    local factionTxt = GUI.CreateStatic(factionTip, "factionTxt", "无", 45, 0, 220, 25)
    RoleClickPopMenu.SetTextBasicInfo(factionTxt, UIDefine.GreenColor, TextAnchor.MiddleLeft, sizeLittle)
    --GUI.StaticSetFontSizeBestFit(factionTxt)
    RoleClickPopMenu.infoBangpaiGUID = GUI.GetGuid(factionTxt)



    -- 操作功能
    local opeButtonScroll = GUI.LoopScrollRectCreate(menuBg, "opeButtonScroll",
            10, 140, 240, 150,
            "RoleClickPopMenu",
            "CreateOperateButton",
            "RoleClickPopMenu",
            "OnRefreshOperateButton",
            0, false,
            Vector2.New(120, 45), 2,
            UIAroundPivot.Top,
            UIAnchor.Top)

    GUI.ScrollRectSetChildSpacing(opeButtonScroll, Vector2.New(5, 5))
    RoleClickPopMenu.opeButtonScrollGUID = GUI.GetGuid(opeButtonScroll)
    GUI.LoopScrollRectInit(opeButtonScroll)

    RoleClickPopMenu.opeButtonCurrentCount = 0

    local cnt = #RoleClickPopMenu.BtnList
    GUI.LoopScrollRectSetTotalCount(opeButtonScroll, cnt)

    if cnt > 10 then
        local indicateSp = GUI.ImageCreate(menuBg, "indicateSp", "1800607340", 0, -8)
        GUI.SetAnchor(indicateSp, UIAnchor.Bottom)
        GUI.SetPivot(indicateSp, UIAroundPivot.Center)
    end

    RoleClickPopMenu.opeInfoGUID = GUI.GetGuid(menuBg)
    GUI.SetVisible(menuBg, false)
end

--创建单人菜单中的按钮
function RoleClickPopMenu.CreateOperateButton()
    local opeButtonScroll = GUI.GetByGuid(RoleClickPopMenu.opeButtonScrollGUID)
    local cnt = GUI.LoopScrollRectGetChildInPoolCount(opeButtonScroll) + 1
    --local cnt = RoleClickPopMenu.opeButtonCurrentCount + 1
    --RoleClickPopMenu.opeButtonCurrentCount = cnt
    local opeButton = GUI.ButtonCreate(opeButtonScroll,
            RoleClickPopMenu.BtnList[cnt][2],
            "1800402110", 0, 0, Transition.ColorTint,
            RoleClickPopMenu.BtnList[cnt][1], 120,
            45, false)
    _gt.BindName(opeButton, RoleClickPopMenu.BtnList[cnt][2])
    RoleClickPopMenu.SetButtonBasicInfo(opeButton, 22)
    RoleClickPopMenu.BtnList[cnt][3] = GUI.GetGuid(opeButton)
    return opeButton
end

--刷新单人菜单中的按钮
function RoleClickPopMenu.OnRefreshOperateButton(parameter)
    --parameter = string.split(parameter, "#")
    --local guid = parameter[1]
    --local index = tonumber(parameter[2]) + 1
end

--创建多人选项
function RoleClickPopMenu.CreateMenuLists(panel)
    local menuListBg = GUI.ImageCreate(panel, "menuListBg", "1800400290", RoleClickPopMenu.PosX, RoleClickPopMenu.PosY, false, 210, 210)
    GUI.SetAnchor(menuListBg, UIAnchor.TopRight)
    GUI.SetPivot(menuListBg, UIAroundPivot.TopRight)

    RoleClickPopMenu.menuListGUID = GUI.GetGuid(menuListBg)

    local selectRolesScroll = GUI.LoopScrollRectCreate(menuListBg,
            "selectRolesScroll", -1,
            10, 210, 186,
            "RoleClickPopMenu",
            "CreateMenuListButton",
            "RoleClickPopMenu",
            "OnRefreshMenuListButton",
            0, false,
            Vector2.New(200, 50), 1,
            UIAroundPivot.Top,
            UIAnchor.Top)

    GUI.ScrollRectSetChildSpacing(selectRolesScroll, Vector2.New(0, 5))
    RoleClickPopMenu.menuListScrollGUID = GUI.GetGuid(selectRolesScroll)
    RoleClickPopMenu.menuListCurrentCount = 0
    GUI.LoopScrollRectInit(selectRolesScroll)
    GUI.SetVisible(menuListBg, false)
end

--创建多人选项按钮
function RoleClickPopMenu.CreateMenuListButton()
    RoleClickPopMenu.menuListCurrentCount = RoleClickPopMenu.menuListCurrentCount + 1
    local name = "name"
    local selectRolesScroll = GUI.GetByGuid(RoleClickPopMenu.menuListScrollGUID)
    local btn = GUI.ButtonCreate(selectRolesScroll, RoleClickPopMenu.menuListCurrentCount, "1800302180", 0, 0, Transition.ColorTint, "", 200, 50, false)
    local nameTxt = GUI.CreateStatic(btn, "nameTxt", "", 0, 0, 170, 24, "system", true)
    GUI.SetAnchor(nameTxt, UIAnchor.Center)
    GUI.SetPivot(nameTxt, UIAroundPivot.Center)
    GUI.StaticSetFontSizeBestFit(nameTxt)
    GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleCenter)
    GUI.ButtonSetPressedColor(btn, Color.New(200 / 255, 200 / 255, 200 / 255, 1))
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "RoleClickPopMenu", "OnRoleListClick")
    return btn
end

--刷新多人选项按钮
function RoleClickPopMenu.OnRefreshMenuListButton(par)
    par = string.split(par, "#")
    local ui_guid = par[1]
    local i = tonumber(par[2]) + 1

    local cnt = #RoleClickPopMenu.currentAllSlectTable
    if i > cnt then
        test("right menu error : " .. i .. "<=" .. cnt)
        return
    end

    local _roleinfo = RoleClickPopMenu.currentAllSlectTable[i]
    local guid = _roleinfo[1]
    local name = _roleinfo[2]
    local type = _roleinfo[3]
    local templateID = _roleinfo[4]
    local sn = _roleinfo[5]
    local headIcon = _roleinfo[6]
    local schoolIcon = _roleinfo[7]
    local level = _roleinfo[8]

    if type == "Npc" then
        name = name .. "(NPC)"
    end

    local child = GUI.GetByGuid(ui_guid)
    local txt = GUI.GetChild(child, "nameTxt")
    local displayName = "<color=#8E4B27><size=20>" .. name .. "</size></color>"
    GUI.StaticSetText(txt, displayName)
    GUI.SetData(child, "INFO", RoleClickPopMenu.MergeInfo(_roleinfo))
    --test(displayName)
end

--点击单人头像按钮
function RoleClickPopMenu.OnHeadIconClick(guid)
    local guid = RoleClickPopMenu.currentSlectTable[1]
    local name = RoleClickPopMenu.currentSlectTable[2]
    local type = RoleClickPopMenu.currentSlectTable[3]
    local templateID = RoleClickPopMenu.currentSlectTable[4]
    local sn = RoleClickPopMenu.currentSlectTable[5]
    local headIcon = RoleClickPopMenu.currentSlectTable[6]
    local schoolIcon = RoleClickPopMenu.currentSlectTable[7]
    local level = RoleClickPopMenu.currentSlectTable[8]
    local reincarnation = RoleClickPopMenu.currentSlectTable[9]
    local vip = RoleClickPopMenu.currentSlectTable[10] or RoleClickPopMenu.GetRoleAttr(RoleAttr.RoleAttrVip, uint64.new(guid))

    local ui_head = GUI.GetByGuid(RoleClickPopMenu.infoHeadIconGUID)
    GUI.ImageSetImageID(ui_head, headIcon)
    HeadIcon.BindRoleVipLv(ui_head, vip)
    local ui_name = GUI.GetByGuid(RoleClickPopMenu.infoNameGUID)
    GUI.StaticSetText(ui_name, name)
    local ui_SN = GUI.GetByGuid(RoleClickPopMenu.infoSNGUID)
    GUI.StaticSetText(ui_SN, sn)
    local ui_School = GUI.GetByGuid(RoleClickPopMenu.infoSchoolGUID)
    GUI.ImageSetImageID(ui_School, schoolIcon)
    local ui_Bangpai = GUI.GetByGuid(RoleClickPopMenu.infoBangpaiGUID)
    local factionName = CL.GetStrCustomData("__title_guild_name", TOOLKIT.Str2uLong(RoleClickPopMenu.currentSelectGUID))
    if factionName == nil or string.len(factionName) == 0 then
        local chatPlayer = LD.GetQueryPlayerData()
        if chatPlayer and tostring(chatPlayer.guid) == RoleClickPopMenu.currentSelectGUID then
            factionName = UIDefine.GetCustomData(chatPlayer.customs.strdata, "__title_guild_name")
        end
        if factionName == nil or string.len(factionName) == 0 then
            factionName = "无"
        end
    end
    GUI.StaticSetText(ui_Bangpai, factionName)
    local ui_Level = GUI.GetByGuid(RoleClickPopMenu.infoLevelGUID)
    GUI.StaticSetText(ui_Level, level .. "级")

    local size = GUI.StaticGetLabelPreferWidth(ui_name) / 2 + 5
    GUI.SetPositionX(ui_School, -size)

    local menuBg = GUI.GetByGuid(RoleClickPopMenu.opeInfoGUID)
    GUI.SetVisible(menuBg, true)
end

--点击单人选项
function RoleClickPopMenu.OnClickMenuButton(guid)
    local cnt = #RoleClickPopMenu.BtnList
    for i = 1, cnt do
        if RoleClickPopMenu.BtnList[i][3] == guid then
            RoleClickPopMenu.BtnList[i][4]()
            RoleClickPopMenu.OnClick()
            return
        end
    end

end

--点击多人选项
function RoleClickPopMenu.OnRoleListClick(guid)
    local child = GUI.GetByGuid(guid)
    local info = GUI.GetData(child, "INFO")
    local _roleinfo = string.split(info, ",")
    local name = _roleinfo[2]
    local type = _roleinfo[3]
    RoleClickPopMenu.OnClick(0)

    if type == "Player" then
        RoleClickPopMenu.OpenMenu(_roleinfo)
    elseif type == "Actor" then
        test(_roleinfo[1], RoleClickPopMenu.openRoleListUIEvent)
        CL.SendNotify(NOTIFY.SelectFightActor, _roleinfo[1], RoleClickPopMenu.openRoleListUIEvent)
    else
        local guid = _roleinfo[1]
        CL.SendNotify(NOTIFY.SelectNpc, guid)
    end
end

--点击遮罩以响应关闭
function RoleClickPopMenu.OnClick(guid)
    local head = GUI.GetByGuid(RoleClickPopMenu.opeHeadGUID)
    GUI.SetVisible(head, false)
    local fullCover = GUI.GetByGuid(RoleClickPopMenu.opeCoverGUID)
    GUI.SetVisible(fullCover, false)
    local menuBg = GUI.GetByGuid(RoleClickPopMenu.opeInfoGUID)
    GUI.SetVisible(menuBg, false)
    local menulistBg = GUI.GetByGuid(RoleClickPopMenu.menuListGUID)
    GUI.SetVisible(menulistBg, false)
    RoleClickPopMenu.IsQueryPlayerInfo = false
end

function RoleClickPopMenu.OnFight(inFight)
    RoleClickPopMenu.IsViewFight = CL.GetFightViewState()
    RoleClickPopMenu.OnFightPerformState(false)
end

function RoleClickPopMenu.OnFightPerformState(isPerform)
    RoleClickPopMenu.IsPerforming = isPerform
    if isPerform then
        -- 如果进入表演状态，关闭界面
        RoleClickPopMenu.OnClick()
    end
end

--帮派竞赛点击人的处理
function RoleClickPopMenu.OnClickRoleInFactionFightingArea(roles_infos, count, pos)
    --帮派竞赛点击人的处理：1225365720606664553,屈紫珍,Player,1,2026473,1900300030,1800102020,1,0,#
    --1225365720606664543,巫马瑛忻,Player,5,2026463,1900300050,1800102050,1,0,#
    --288616998113575609,仓库金大娘,Npc,20016,0,1900352050,0,0,0,#
    local selfFFID = CL.GetIntCustomData("ACTIVITY_GuildBattle_Camp")
    if selfFFID ~= 0 then
        --表示处于帮派竞赛中，点击人物会发送点击事件
        local targetRoleGUID = 0
        for i = 1, count do
            if roles_infos[i][3] == "Player" then
                local isFight = RoleClickPopMenu.GetRoleAttr(RoleAttr.RoleAttrIsFight, TOOLKIT.Str2uLong(roles_infos[i][1]))
                if isFight == nil or isFight == 0 then
                    local targetRoleGUID0 = TOOLKIT.Str2uLong(roles_infos[i][1])
                    local otherFFID = CL.GetIntCustomData("ACTIVITY_GuildBattle_Camp", targetRoleGUID0)
                    if otherFFID ~= selfFFID then
                        targetRoleGUID = targetRoleGUID0
                        break
                    end
                end
            end
        end
        if targetRoleGUID ~= 0 then
            local selfPos = CL.GetRoleClientPos()
            local otherRoleGUID = targetRoleGUID
            local otherPos = CL.GetRoleClientPos(otherRoleGUID)
            if selfPos[0] ~= 0 and selfPos[1] ~= 0 and otherPos[0] ~= 0 and otherPos[1] ~= 0 then
                local distance = math.max(math.abs(selfPos[0] - otherPos[0]), math.abs(selfPos[1] - otherPos[1]))
                if distance <= 8 then
                    CL.SendNotify(NOTIFY.SubmitForm, "FormDuel", "GuildBattle_Attack", otherRoleGUID)
                else
                    CL.StartMove(otherPos[0], otherPos[1])
                    CL.SetMoveEndAction(MoveEndAction.LuaDefine, "MainUI", "OnMoveToFactionFightingRolePos", tostring(targetRoleGUID))
                end
            end
        end
    end
end

--接受并处理分派消息,单人或多人都从此入
function RoleClickPopMenu.OnMessageHandle(clickInfo, position, uceType)

    test(clickInfo, position, uceType)
    -- 处于表演状态或者观战状态不打开界面
    uceType = uceType and UCE.IntToEnum(uceType) or UCE.PointerClick
    if uceType == UCE.PointerClick and RoleClickPopMenu.IsPerforming or RoleClickPopMenu.IsViewFight or clickInfo == nil or clickInfo == "" then
        return
    end

    RoleClickPopMenu.openRoleListUIEvent = uceType
    local clicks = string.split(clickInfo, "#")
    if clicks == nil then
        return
    end

    local size = #clicks
    local realCount = 0
    local _roles_info = {}

    for i = 1, size do
        local info = clicks[i]
        if info ~= nil and info ~= "" then
            local _role_info = string.split(info, ",")
            -- test(info)
            if _role_info ~= nil then
                realCount = realCount + 1
                _roles_info[realCount] = _role_info
            end
        end
    end

    if realCount == 1 then
        RoleClickPopMenu.OpenMenu(_roles_info[realCount])
    else
        RoleClickPopMenu.OpenList(_roles_info, realCount)
    end

    RoleClickPopMenu.OnClickRoleInFactionFightingArea(_roles_info, realCount, position)
end
--是否是快速PK
function RoleClickPopMenu.IsFastPK()
    local roleCamPKValue = RoleClickPopMenu.GetRoleAttr(RoleAttr.RoleAttrCanPk, 0)
    local IsQuicklyPK = GlobalProcessing.IsQuicklyPK or false
    if roleCamPKValue ~= 0 and IsQuicklyPK then
        test("快速PK开启" .. tostring(RoleClickPopMenu.currentSelectGUID))
        --CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "joinFight", RoleClickPopMenu.currentSelectGUID)
        return true
    end
    test("快速PK没有开启" .. tostring(RoleClickPopMenu.currentSelectGUID))
    return false
end

--打开单人菜单
function RoleClickPopMenu.OpenMenu(_role_info, x, y)
    if _role_info == nil or _role_info == "" then
        return
    end

    RoleClickPopMenu.currentSlectTable = RoleClickPopMenu.SplitInfo(_role_info)
    RoleClickPopMenu.currentSelectGUID = RoleClickPopMenu.currentSlectTable[1]

    --点击角色直接开启PK
    local isFastPK = RoleClickPopMenu.IsFastPK()
    local state = RoleClickPopMenu.GetRoleAttr(RoleAttr.RoleAttrIsFight, TOOLKIT.Str2uLong(RoleClickPopMenu.currentSelectGUID))
    local currentMap = CL.GetCurrentMapId()
    --test("State"..tostring(state))

    if isFastPK and state ~= nil and state == 0 then
        if currentMap ~= 210 then
            CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "joinFight", RoleClickPopMenu.currentSelectGUID)
        else
            CL.SendNotify(NOTIFY.MakeFight, 0, RoleClickPopMenu.currentSelectGUID)
        end
    end

    local head = GUI.GetByGuid(RoleClickPopMenu.opeHeadGUID)

    if x ~= nil and y ~= nil then
        GUI.SetPositionX(head, x)
        GUI.SetPositionY(head, y)
    else
        GUI.SetPositionX(head, RoleClickPopMenu.PosX)
        GUI.SetPositionY(head, RoleClickPopMenu.PosY)
    end

    local headIco = GUI.GetByGuid(RoleClickPopMenu.opeHeadIconGUID)
    local headIcon = RoleClickPopMenu.currentSlectTable[6]
    GUI.ImageSetImageID(headIco, headIcon)
    HeadIcon.BindRoleGuid(headIco, uint64.new(RoleClickPopMenu.currentSelectGUID))
    GUI.SetVisible(head, true)
    local fullCover = GUI.GetByGuid(RoleClickPopMenu.opeCoverGUID)
    GUI.SetVisible(fullCover, true)
    --RoleClickPopMenu.OnRevisionInfo()
    test("执行到此处111111111111111111111")
    CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "getIsCanPKMap")
end

function RoleClickPopMenu.GetRoleAttr(attr, roleGUID)
    local chatPlayer = LD.GetQueryPlayerData()
    if chatPlayer and tostring(chatPlayer.guid) == tostring(roleGUID) then
        local Count = chatPlayer.attrs.Length
        for i = 0, Count - 1 do
            if chatPlayer.attrs[i].attr == System.Enum.ToInt(attr) then
                return tonumber(tostring(chatPlayer.attrs[i].value))
            end
        end
        return 0
    else
        return CL.GetIntAttr(attr, roleGUID)
    end
end

function RoleClickPopMenu.OnRevisionInfo()
    test("执行到RoleClickPopMenu.OnRevisionInfo")
    local inviteTeamBtn = _gt.GetUI("inviteTeam")
    if inviteTeamBtn ~= nil then
        local InTeamState = RoleClickPopMenu.GetRoleAttr(RoleAttr.RoleAttrTeamStatus, TOOLKIT.Str2uLong(RoleClickPopMenu.currentSlectTable[1]))
        if InTeamState == 3 then
            GUI.ButtonSetText(inviteTeamBtn, "申请入队")
        else
            GUI.ButtonSetText(inviteTeamBtn, "邀请组队")
        end
    end

    local athleticsOrPkBtn = _gt.GetUI("athleticsOrPk")
    if athleticsOrPkBtn ~= nil then
        local state = RoleClickPopMenu.GetRoleAttr(RoleAttr.RoleAttrIsFight, TOOLKIT.Str2uLong(RoleClickPopMenu.currentSelectGUID))
        --获取的是地图的id
        local currentMap = CL.GetCurrentMapId()
        test("当前的地图ID====" .. currentMap)
        test("当前的state====" .. state)
        --test("State"..tostring(state))
        if state ~= nil and state == 0 then
            if currentMap ~= nil and currentMap ~= 210 then
                test("显示PK")
                GUI.ButtonSetText(athleticsOrPkBtn, "PK")
            else
                test("显示切磋")
                GUI.ButtonSetText(athleticsOrPkBtn, "切磋")
            end
        else
            test("观战")
            GUI.ButtonSetText(athleticsOrPkBtn, "观战")
        end
    end
    local friendBtn = _gt.GetUI("friend")
    if friendBtn then
        GUI.ButtonSetText(friendBtn, LD.IsMyFriend(RoleClickPopMenu.currentSelectGUID) and "删除好友" or "加为好友")
    end

    -- 面对面交易  特别注意：因为前人使用loopScrollRect不把刷新写到刷新方法内，导致一堆问题，我试图修改而导致其他错误。没办法最后我选择easy模式，不管后面增加的按钮。
    local to_face_transaction_btn = _gt.GetUI('to_face_transaction')
    if to_face_transaction_btn then
        if UIDefine.FunctionSwitch.FaceDeal ~= 'on' then
            GUI.SetVisible(to_face_transaction_btn, false)
            -- 如果不显示这个按钮，增加新的按钮时，可能会导致显示上这里为空白
            -- 也可能应loopScrollRect的复用特性，导致其他显示问题
        end
    end
end

--打开多人菜单
function RoleClickPopMenu.OpenList(_roles_info, count)
    RoleClickPopMenu.currentAllSlectTable = {}
    for i = 1, count do
        local info = _roles_info[i]
        local tableData = RoleClickPopMenu.SplitInfo(info)
        table.insert(RoleClickPopMenu.currentAllSlectTable, i, tableData)
    end

    local cnt = #RoleClickPopMenu.currentAllSlectTable
    RoleClickPopMenu.menuListCurrentCount = 0

    local selectRolesScroll = GUI.GetByGuid(RoleClickPopMenu.menuListScrollGUID)
    GUI.LoopScrollRectSetTotalCount(selectRolesScroll, cnt)

    --test(cnt)
    -- for i = 1, cnt do
    --     local _roleinfo = RoleClickPopMenu.currentAllSlectTable[i]
    --     local guid = _roleinfo[1]
    --     local name = _roleinfo[2]
    --     local type = _roleinfo[3]
    --     local templateID = _roleinfo[4]
    --     local sn = _roleinfo[5]
    --     local headIcon = _roleinfo[6]
    --     local schoolIcon = _roleinfo[7]
    --     local level = _roleinfo[8]

    --     if type == "Npc" then name = name .. "(NPC)" end

    --     local key = "" .. i
    --     local child = GUI.LoopScrollRectGetChildInPool(selectRolesScroll, key)
    --     local txt = GUI.GetChild(child, "nameTxt")
    --     local displayName = "<color=#8E4B27><size=20>" .. name .."</size></color>"
    --     GUI.StaticSetText(txt, displayName)
    --     GUI.SetData(child, "INFO", RoleClickPopMenu.MergeInfo(_roleinfo))
    --     --test(displayName)
    -- end

    local menulistBg = GUI.GetByGuid(RoleClickPopMenu.menuListGUID)
    GUI.SetVisible(menulistBg, true)

    local fullCover = GUI.GetByGuid(RoleClickPopMenu.opeCoverGUID)
    GUI.SetVisible(fullCover, true)

    GUI.LoopScrollRectRefreshCells(selectRolesScroll)
end

--信息处理,要加工原始信息在此,默认不处理
function RoleClickPopMenu.SplitInfo(_role_info)
    local guid = _role_info[1]
    local name = _role_info[2]
    local type = _role_info[3]
    local templateID = _role_info[4]
    local sn = _role_info[5]
    local headIcon = _role_info[6]
    local schoolIcon = _role_info[7]
    local level = _role_info[8]
    local reincarnation = _role_info[9]
    return { guid, name, type, templateID, sn, headIcon, schoolIcon, level, reincarnation }
end

--合并信息
function RoleClickPopMenu.MergeInfo(_role_info)
    local guid = _role_info[1]
    local name = _role_info[2]
    local type = _role_info[3]
    local templateID = _role_info[4]
    local sn = _role_info[5]
    local headIcon = _role_info[6]
    local schoolIcon = _role_info[7]
    local level = _role_info[8]
    local reincarnation = _role_info[9]
    return guid .. "," .. name .. "," .. type .. "," .. templateID .. "," .. sn .. "," .. headIcon .. "," .. schoolIcon .. "," .. level .. "," .. reincarnation
end

function RoleClickPopMenu.SetTextBasicInfo(txt, color, Anchor, fontsize)
    if txt ~= nil then
        GUI.SetAnchor(txt, UIAnchor.TopLeft)
        GUI.SetPivot(txt, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(txt, fontsize)
        GUI.SetColor(txt, color)
        GUI.StaticSetAlignment(txt, Anchor)
    end
end

function RoleClickPopMenu.SetButtonBasicInfo(btn, fontsize)
    if btn ~= nil then
        GUI.SetPivot(btn, UIAroundPivot.Center)
        GUI.SetAnchor(btn, UIAnchor.Center)
        GUI.ButtonSetTextFontSize(btn, fontsize)
        GUI.ButtonSetTextColor(btn, UIDefine.Orange2Color)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "RoleClickPopMenu", "OnClickMenuButton")
    end
end

--{guid, name, type, templateID, sn, headIcon, schoolIcon, level, reincarnation, vip}
function RoleClickPopMenu.ShowPlayerOperate(role_info, x, y)
    RoleClickPopMenu.IsQueryPlayerInfo = true
    RoleClickPopMenu.currentSlectTable = role_info
    RoleClickPopMenu.currentSelectGUID = RoleClickPopMenu.currentSlectTable[1]
    local headIco = GUI.GetByGuid(RoleClickPopMenu.opeHeadIconGUID)
    local headIcon = RoleClickPopMenu.currentSlectTable[6]
    GUI.ImageSetImageID(headIco, headIcon)
    HeadIcon.BindRoleVipLv(headIco, role_info[10] or 0)
    local head = GUI.GetByGuid(RoleClickPopMenu.opeHeadGUID)
    if x then
        GUI.SetPositionX(head, x)
    end
    if y then
        GUI.SetPositionY(head, y)
    end
    GUI.SetVisible(head, true)
    local fullCover = GUI.GetByGuid(RoleClickPopMenu.opeCoverGUID)
    GUI.SetVisible(fullCover, true)
    RoleClickPopMenu.OnRevisionInfo()
    RoleClickPopMenu.OnHeadIconClick()
end

-- 删除好友请求
function RoleClickPopMenu.delete_friend()
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "DeleteFriend", RoleClickPopMenu.currentSelectGUID) -- 删除好友
end