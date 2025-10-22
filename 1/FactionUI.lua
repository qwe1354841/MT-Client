local FactionUI = {}
_G.FactionUI = FactionUI
local inspect = require("inspect")
local _gt = UILayout.NewGUIDUtilTable()
local ONE_PAGE_NUM = 8
FactionUI.SelectTabIndex = 1
FactionUI.SelectMemberTabSubIndex = 1

FactionUI.SelectMemberItemIndex = -1
FactionUI.SelectMemberItem = nil
FactionUI.SelectMemberPageIndex = 0
FactionUI.SelectMemberTotalPageCount = 1
FactionUI.SelectMemberTotalCount = 0
FactionUI.SelectMemberSearchMode = false
FactionUI.SelectApplyIndex = -1
FactionUI.SelectApplyItem = nil
FactionUI.SelectApplyPageIndex = 0
FactionUI.SelectApplyTotalPageCount = 1
FactionUI.SelectApplyTotalCount = 0
FactionUI.ApplyLeftTimeTimer = nil
FactionUI.FactionMemberList = nil
FactionUI.ApplyList = nil
FactionUI.FactionData = nil
FactionUI.ImpeachmentTimer = nil
FactionUI.RemainingTime = 0

FactionUI.InfoMemberItemListTimer = nil

local Donate_SilverToContribution = 100
local Donate_SilverToFund = 100
FactionUI.SelectBuildingIndex = 1

FactionUI.ProtectionSubIndex = 2
FactionUI.ProtectionPointOpeLst = {}
FactionUI.ProtectionPointOpeLstTotal = 0
--配置性质数据
local FACTION_ANNOUNCE_ENERGY_COST = 10 --帮派通知活力消耗
local FACTION_CHANGE_NAME_COST0 = "50000" --修改帮派名字消耗银币
local FACTION_CHANGE_NAME_COST1 = "50000" --修改帮派名字消耗帮派资金
local FACTION_DONATE_COST0 = "450000" --帮派捐献兑换比例银币
local FACTION_DONATE_COST1 = "1" --帮派捐献兑换比例成就点
local FACTION_DONATE_COST2 = "30" --退出帮派扣除的贡献度（百分比）
local FACTION_ROLE_NUM = {100,120,150,200,250} --不同帮派等级对应帮派人数（1-5级）
local FACTION_GOLD_MAX_SHOW = "15亿" --帮派资金上限
local FACTION_GOLD_MAX = 1000000--帮派资金上限
local faction_menber_list = {}
local Activity = {}

local SchoolIcon = {
    [31] = 1800102020;
    [32] = 1800102030;
    [33] = 1800102040;
    [34] = 1800102050;
    [35] = 1800102060;
    [36] = 1800102070
}

local tabList = {
    { "信息", "infoTabBtn", "OnInfoTabBtnClick", btnGuid = "", hide = false },
    { "成员", "memberTabBtn", "OnMemberTabBtnClick", btnGuid = "", hide = false },
    { "活动","activityBtn","OnProtectionBtnClick", btnGuid = "", hide = false},
    { "建设", "constructTabBtn", "OnFactionConstructBtnClick", btnGuid = "", hide = false },
    --{ "守护", "protectionTabBtn", "OnProtectionBtnClick", btnGuid = "", hide = false },

}

local jobList = {
    { "帮主", "jobBangZhu", "OnBtnSetJob", "8" },
    { "副帮主", "jobFuBangZhu", "OnBtnSetJob", "7" },
    { "青龙堂堂主", "jobYouHuFa", "OnBtnSetJob", "6" },
    { "白虎堂堂主", "jobZuoHuFa", "OnBtnSetJob", "5" },
    { "朱雀堂堂主", "jobWoHuTang", "OnBtnSetJob", "4" },
    { "玄武堂堂主", "jobFeiLongTang", "OnBtnSetJob", "3" },
   -- { "精英成员", "jobWoHuTangM", "OnBtnSetJob", "2" },
    { "精英", "jobFeiLongTangM", "OnBtnSetJob", "1" },
    { "帮众", "jobMember", "OnBtnSetJob", "0"},
}

local JOB_SHOW_NAME = {
    "帮众",
    "精英",
    "卧虎堂成员",
    "玄武堂堂主",
    "朱雀堂堂主",
    "白虎堂堂主",
    "青龙堂堂主",
    "副帮主",
    "帮主",
}

local ConstructTypesName = {
    [1] = {name="忠义堂", btn="faithHallBtn", pic="1800807230", desc="帮派主建筑，忠义堂的等级就是帮派的等级\n忠义堂等级是其他建筑升级的先决条件", effect="帮派等级提升"},
    [2] = {name="帮派厢房", btn="factionAcademyBtn", pic="1800807260", desc="帮派厢房升级后，帮派人数上限会得到提升", effect="帮派人数上限达到%s人%s"},
    [3] = {name="帮派金库", btn="factionWingBtn", pic="1800807250", desc="提升帮派金库等级，可以提高帮派资金储存上限", effect="帮派资金上限增加至%s%s"},
    [4] = {name="帮派书院", btn="factionVaultBtn", pic="1800807270", desc="提升帮派书院等级后，可提高帮派技能等级上限", effect="帮派技能上限增加至%s级%s"},
	[5] = {name="帮派宝阁", btn="factionPharmacyBtn", pic="1800807240", desc="商店开启后，帮派成员可以通过帮派商店购买道具\n帮派商店等级越高，出售道具的种类越多", effect="帮派出售道具品类增加"},
}

local FactionConsumePerDay = {100000,200000,350000,600000,1000000}  --每日资金消耗

FactionUI.ConstructData = nil
--[[{
    [1]={
        ["BuildingName"]="忠义堂",
        ["BuildingNpc"] = 10124,
        ["BuildingLevels"]={
            [1]={
                ["BuildingLevelRequired"]=0,
                ["Param1"]=100,
                ["BuildingIdRequired"]=0,
                ["BuildDegreeRequired"]=0,
                ["Param2"]=0,
                ["FundRequired"]=0,
            },
--]]

local ContributeGoldInfo =
{
    [1] = {name="累计帮贡", icon="1800408290", desc="<color=yellow>获取方式</color>：完成帮派捐献，完成部分帮派活动的奖励" },
    [2] = {name="帮派成就", icon="1800408300", desc="<color=yellow>获取方式</color>：完成帮派任务，完成部分帮派活动的奖励\n<color=yellow>用于</color>：帮派商店购买，大成守护点兑换" },
    [3] = {name="帮派战功", icon="1801208040", desc="<color=yellow>获取方式</color>：完成帮战活动的奖励\n<color=yellow>用于</color>：帮派大成守护点兑换，赏功堂" }
}

function FactionUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    --test("FactionUI.Main")

    local wnd = GUI.WndCreateWnd("FactionUI", "FactionUI", 0, 0)
    UILayout.CreateFrame_WndStyle0(wnd, "帮    派", "FactionUI", "OnExit", _gt)

    if UIDefine.FunctionSwitch == nil or
            UIDefine.FunctionSwitch.GuildGuardian ~= "on" then
        tabList = {
            { "信息", "infoTabBtn", "OnInfoTabBtnClick", btnGuid = "", hide = false },
            { "成员", "memberTabBtn", "OnMemberTabBtnClick", btnGuid = "", hide = false },
            { "活动", "activityBtn", "OnActivityBtnClick", btnGuid = "", hide = false },
            { "建设", "constructTabBtn", "OnFactionConstructBtnClick", btnGuid = "", hide = false },
        }
    end
    UILayout.CreateRightTab(tabList, "FactionUI")

    --刷新帮派列表申请标志
    CL.RegisterMessage(GM.FactionInfoUpdate,"FactionUI","FactionInfoUpdate")
    --创建成员页签红点
    local TabList = GUI.GetChild(wnd,"tabList")
    local btn = GUI.GetChild(TabList,"memberTabBtn")
    GUI.AddRedPoint(btn,UIAnchor.TopRight,20,-30,"1800208080")
    GUI.SetRedPointVisable(btn,false)

    --默认选中信息页
    FactionUI.FactionData = LD.GetGuildData()
    FactionUI.OnInfoTabBtnClick()

    --获得帮派活动
    CL.SendNotify(NOTIFY.GetActivityList)
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildApplicants")
    --FactionUI.GetFactionActivity()
    CL.RegisterMessage(GM.ActivityListUpdate, "FactionUI", "GetFactionActivity")
end

function FactionUI.FactionInfoUpdate(type, param0, param1)
    --test("FactionUI.FactionInfoUpdate  type: "..type)
    if type == 3 then
        --队员列表（一页）
        FactionUI.SelectMemberTotalCount = LD.GetMemberTotalCount()
        FactionUI.SelectMemberTotalPageCount = FactionUI.SelectMemberTotalCount==0 and 1 or FactionUI.SelectMemberTotalCount%ONE_PAGE_NUM==0 and FactionUI.SelectMemberTotalCount/ONE_PAGE_NUM or math.ceil(FactionUI.SelectMemberTotalCount / ONE_PAGE_NUM)
        FactionUI.FactionMemberList = LD.GetMemberList()
        FactionUI.OnRefreshMemberPageAndBtnState()
        FactionUI.RefreshMemberItem()
        FactionUI.RefreshInfoMemberItem()
    elseif type == 4 then
        --帮派基本信息
        FactionUI.FactionData = LD.GetGuildData()
        if FactionUI.SelectTabIndex == 1 then
            FactionUI.OnSelectFactionInfo()
            FactionUI.RefreshInfoMemberItem()
        end
    elseif type == 5 then
        --申请列表（全部）
        FactionUI.ApplyList = LD.GetApplicantList()
        FactionUI.SelectApplyTotalCount = (FactionUI.ApplyList ~= nil and FactionUI.ApplyList.Count or 0)
        FactionUI.SelectApplyTotalPageCount = FactionUI.SelectApplyTotalCount==0 and 1 or FactionUI.SelectApplyTotalCount%ONE_PAGE_NUM==0 and FactionUI.SelectApplyTotalCount/ONE_PAGE_NUM or math.ceil(FactionUI.SelectApplyTotalCount / ONE_PAGE_NUM)
        FactionUI.UpdateApplyPageAndBtnInfo()
        FactionUI.RefreshApplyListScroll()

        local Btn = GUI.Get("FactionUI/panelBg/tabList/memberTabBtn")
        local factionApplyListBtn = _gt.GetUI("factionApplyListBtn")
        local changeBoardPermission=LD.HavePermission(FactionUI.FactionData.self.permission,guild_permission.guild_permission_apply_aduit)
        if changeBoardPermission then
            if FactionUI.ApplyList.Count > 0 then
                GUI.SetRedPointVisable(factionApplyListBtn,true)
                GUI.SetRedPointVisable(Btn,true)
            else
                GUI.SetRedPointVisable(factionApplyListBtn,false)
                GUI.SetRedPointVisable(Btn,false)
            end
        else
            GUI.SetRedPointVisable(factionApplyListBtn,false)
            GUI.SetRedPointVisable(Btn,false)
        end
    elseif type == 6 then
        --搜索的队员列表（全部）
        FactionUI.SelectMemberTotalCount = LD.GetSearchMemberTotalCount()
        FactionUI.SelectMemberTotalPageCount = FactionUI.SelectMemberTotalCount==0 and 1 or FactionUI.SelectMemberTotalCount%ONE_PAGE_NUM==0 and FactionUI.SelectMemberTotalCount/ONE_PAGE_NUM or math.ceil(FactionUI.SelectMemberTotalCount / ONE_PAGE_NUM)
        FactionUI.FactionMemberList = LD.GetSearchMemberList()
        FactionUI.OnRefreshMemberPageAndBtnState()
        FactionUI.RefreshMemberItem()
    elseif type == 7 then
        --禁言标记更新
        local bForbid = (param0==1 and true or false)
        local roleGUID = param1
        FactionUI.OnUpdateBannedTalkFlag(bForbid, roleGUID)
    elseif type == 8 then
        --退出帮派成功
        FactionUI.OnExit()
    elseif type == 9 then
        --修改名字
        local changeNameCover = _gt.GetUI("changeNameCover")
        if changeNameCover ~= nil then
            GUI.SetVisible(changeNameCover, false)
        end
        local factionNameInputField = _gt.GetUI("factionNameInputField")
        if factionNameInputField then
            GUI.EditSetTextM(factionNameInputField, "")
        end
        local factionNameTxt = _gt.GetUI("factionNameTxt")
        if factionNameTxt then
            GUI.StaticSetText(factionNameTxt, param0)
        end
    elseif type == 10 then
        --修改宣言
        local changeBoardCover = _gt.GetUI("changeBoardCover")
        if changeBoardCover ~= nil then
            GUI.SetVisible(changeBoardCover, false)
        end
        local changeBoardInputField = _gt.GetUI("changeBoardInputField")
        if changeBoardInputField then
            GUI.EditSetTextM(changeBoardInputField, "")
        end
        local boardTxt = _gt.GetUI("boardTxt")
        if boardTxt then
            GUI.StaticSetText(boardTxt, param0)
        end
    elseif type == 13 then
        --更改职位
        local pos = param0
        local roleGUID = param1
        if FactionUI.FactionData ~= nil and  FactionUI.FactionData.self ~= nil and FactionUI.FactionData.self.player_guid == roleGUID then
            --如果自己的职业变更，则重新请求刷新帮派数据
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuild")
        end
        FactionUI.OnUpdatePosotionInfo(pos, roleGUID)
    elseif type == 14 then
        FactionUI.OnCloseBtnClick_SendNotifyBg()
        CL.SendNotify(NOTIFY.ShowBBMsg,"通知发送成功")
    elseif type == 15 then
        FactionUI.OnExit()
    elseif type == 16 then
        --捐献成功后请求刷新帮派信息页面
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuild")
    elseif type == 17 then
        FactionUI.FactionData = LD.GetGuildData()
        if FactionUI.FactionData.guild == nil or tostring(FactionUI.FactionData.guild.guid) == "0" then
            FactionUI.OnExit()
        end
    elseif type == 18 then
        --帮派建筑升级
        if param0 ==  FactionUI.SelectBuildingIndex then
            local buildingLevel = _gt.GetUI("buildingLevel")
            if buildingLevel then
                GUI.StaticSetText(buildingLevel, "建筑等级"..param1.."级")
            end
            FactionUI.ShowBuildingInfo(FactionUI.SelectBuildingIndex)
        end
    end
end

function FactionUI.OnUpdateToFindTargetItem(roleGUID)
    local item = nil
    local member = FactionUI.FactionMemberList ~= nil and LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode) or nil
    if member and member.player_guid == roleGUID then
        --是当前选中项
        item = FactionUI.SelectMemberItem
    else
        --在当前页查询
        for i = 0, ONE_PAGE_NUM-1 do
            local index = i + FactionUI.SelectMemberPageIndex * ONE_PAGE_NUM
            local member = FactionUI.FactionMemberList ~= nil and LD.GetMemberByIndex(index, FactionUI.SelectMemberSearchMode) or nil
            if member and member.player_guid == roleGUID then
                item = _gt.GetUI("memberItem" .. i)
                break
            end
        end
    end
    return item
end

function FactionUI.OnUpdateBannedTalkFlag(bForbid, roleGUID)
    local item = FactionUI.OnUpdateToFindTargetItem(roleGUID)
    if item ~= nil then
        local itemName = GUI.GetName(item)
        local indexI = tonumber(string.sub(itemName, 11))
        local memberBannedTalkSp = _gt.GetUI("memberBannedTalkSp"..indexI)
        GUI.SetVisible(memberBannedTalkSp, bForbid)
    end
end

function FactionUI.OnUpdatePosotionInfo(pos, roleGUID)
    local item = FactionUI.OnUpdateToFindTargetItem(roleGUID)
    if item ~= nil then
        local itemName = GUI.GetName(item)
        local indexI = tonumber(string.sub(itemName, 11))
        local memberPosition = _gt.GetUI("memberPosition"..indexI)
        GUI.StaticSetText(memberPosition, FactionUI.ParseJobShowName(pos))
    end
end

function FactionUI.OnShow(parameter)
    if not parameter then
        FactionUI.GuardianConfig = nil
        FactionUI.SelectMemberPageIndex = 0
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildMembers", 0, ONE_PAGE_NUM)
    end
    local index1,index2 = nil
    index1,index2 = UIDefine.GetParameterStr(parameter)
    index1 = tonumber(index1)
    index2 = tonumber(index2)
    if index1 == 1 then
        if index2 == 101 then
            FactionUI.OnContributeBtnClick()
        end
    end
    if index1 == 2 then
        FactionUI.OnMemberTabBtnClick()
    end
    if index1 == 3 then
        FactionUI.OnProtectionBtnClick()
    end
end

function FactionUI.Init()

end

local TableSet = function(a,b)
    if a.state ~= b.state then
        return a.state < b.state
    end
    if a.level ~= b.level then
        return a.level < b.level
    end
    if a.index ~= b.index then
        return a.index < b.index
    end
    if a.id ~= b.id then
        return a.id < b.id
    end
    return false
end

function FactionUI.GetFactionActivity()
    local list = LD.GetActivityList()
    local time = CL.GetServerTickCount()
    local dateStr = string.split(os.date("!%d %w %H %M %S", time), " ")
    --print(os.date("!%d %w %H %M %S", CL.GetServerTickCount()), "---------------------------------")
    local day = dateStr[1]
    local week = dateStr[2] == "0" and "7" or dateStr[2]
    local hour = dateStr[3]
    local minute = dateStr[4]
    local second = dateStr[5]
    local curTime = tonumber(hour) * 3600 + tonumber(minute) * 60 + tonumber(second)
    --print(week)
    --GlobalUtils.Get_DHMS1_BySeconds(time)
    --print(inspect(list[84].custom))
    --local activity_mode = LD.GetActivityDataByID(104)
    --local sss = string.split(activity_mode.custom, ":")
    --print(tostring(activity_mode.custom))
    Activity = {}
    --local ActivityDB = DB.GetActivityAllKeys()
    --CDebug.LogError(ActivityDB)
    local count = list.Count
    for i = 1, count do
        local Data = list[i-1]
        local OnceActivity = DB.GetActivity(Data.id)
        if OnceActivity.ShowGuild == 1 and Data ~= "" then
            local custom = Data.custom
            if custom ~= "" and custom ~= nil then
                local CustomList = string.split(custom,":")
                local state
                if tonumber(CustomList[1]) >= tonumber(CustomList[2]) then
                    if tonumber(OnceActivity.Id) == 104 then
                        state = 3
                    end
                end
                local weekday = string.split(OnceActivity.Time,",")
                if tonumber(OnceActivity.TimeType) == 1 and state ~= 3 then
                    if LogicDefine.CheckActivityTime(OnceActivity.TimeStart, OnceActivity.TimeEnd, curTime) then
                        state = 1
                    else
                        state = 2
                    end
                elseif tonumber(OnceActivity.TimeType) == 2 and state ~= 3 then
                    for n = 1,#weekday do
                        if tonumber(weekday[n]) == tonumber(week) then
                            state = 1
                            break
                        else
                            state = 2
                        end
                    end
                    if state == 1 and LogicDefine.CheckActivityTime(OnceActivity.TimeStart, OnceActivity.TimeEnd, curTime) then
                        state = 1
                    else
                        state = 2
                    end
                end
                --print(OnceActivity.Id)
                local temp ={
                    id = tonumber(tostring(OnceActivity.Id)),
                    index = tonumber(tostring(OnceActivity.Index)),
                    name = tostring(OnceActivity.Name),
                    pic = tostring(OnceActivity.Icon),
                    level = tonumber(tostring(OnceActivity.LevelMin)),
                    time = tostring(OnceActivity.TimeInfo),
                    introduce = tostring(OnceActivity.DesInfo),
                    state = state
                }
                --if temp.name == "帮派精英战" then
                --    CDebug.LogError("1")
                --end
                --print(temp.state)
                Activity[#Activity + 1] = temp
            end
        end
    end
    table.sort(Activity,TableSet)
end

function FactionUI.OnExit()
    GUI.DestroyWnd("FactionUI")
end

function FactionUI.OnDestroy()
    if FactionUI.ApplyLeftTimeTimer ~= nil then
        FactionUI.ApplyLeftTimeTimer:Stop()
        FactionUI.ApplyLeftTimeTimer = nil
    end
end

function FactionUI.OnInfoTabBtnClick()

    FactionUI.SelectTabIndex = 1
    FactionUI.OnClickTab()
    FactionUI.OnSelectFactionInfo()
    --刷新帮派信息
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuild")
end

function FactionUI.OnMemberTabBtnClick()
    FactionUI.SelectTabIndex = 2
    FactionUI.OnClickTab()
    FactionUI.OnSelectFactionMember()
end

--[[function FactionUI.OnActivityBtnClick()
    FactionUI.SelectTabIndex = 3
    FactionUI.OnClickTab()
    FactionUI.OnSelectFactionActivity()
end]]

function FactionUI.OnFactionConstructBtnClick()
    FactionUI.SelectTabIndex = 4
    FactionUI.OnClickTab()
    FactionUI.OnFactionConstructClick()
    if FactionUI.ConstructData == nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetData")
    end
end


function FactionUI.OnProtectionBtnClick()
    FactionUI.SelectTabIndex = 3
    FactionUI.OnClickTab()
    FactionUI.OnClickProtection()
    --默认点击小成守护
    --FactionUI.OnLitProtectionBtnClick()
end

function FactionUI.OnClickProtection()
    local level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local factionProtectionBg = _gt.GetUI("factionProtectionBg")
    if factionProtectionBg == nil then
        local panelBg = GUI.Get("FactionUI/panelBg")
        factionProtectionBg = GUI.GroupCreate(panelBg, "factionProtectionBg", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
        _gt.BindName(factionProtectionBg, "factionProtectionBg")
        UILayout.SetSameAnchorAndPivot(factionProtectionBg, UILayout.Center)

        local board = GUI.ImageCreate(factionProtectionBg,"board","1800400010",0,10,false,1030,530)

        local ActivityList = GUI.ScrollListCreate(board,"ActivityList",0,0,1000,500,false,UIAroundPivot.Top,UIAnchor.Top)
        local actv = #Activity
        for i=1,actv do
            local act = GUI.ItemCtrlCreate(ActivityList, "act" .. i, "1801100010", -5, 40*i, 1000, 120, false)

            local bg = GUI.ItemCtrlCreate(act,"bg"..i,"1801100120",18,18,81,81,false)
            UILayout.SetSameAnchorAndPivot(bg, UILayout.TopLeft)

            local pic = GUI.ItemCtrlCreate(bg,"pic"..i,Activity[i].pic,5,5,72,72,false)
            UILayout.SetSameAnchorAndPivot(pic, UILayout.TopLeft)

            local nameTxt = GUI.CreateStatic(act,"name"..i,Activity[i].name,125,-15,200,120)
            UILayout.SetSameAnchorAndPivot(nameTxt, UILayout.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(nameTxt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.Left)

            local levelTxt = GUI.CreateStatic(act,"level"..i,"等级需求: "..Activity[i].level,125, 10,200,120)
            UILayout.SetSameAnchorAndPivot(levelTxt, UILayout.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(levelTxt, UIDefine.FontSizeM, UIDefine.Yellow2Color, TextAnchor.Left)

            local timeTxt = GUI.CreateStatic(act,"time_introduce"..i,Activity[i].time.."\n"..Activity[i].introduce,400,0,450,120)
            UILayout.SetSameAnchorAndPivot(timeTxt, UILayout.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(timeTxt, UIDefine.FontSizeS, UIDefine.Yellow2Color, TextAnchor.MiddleLeft)

            local gobtn = GUI.ButtonCreate(act,"gobtn"..i,"1800402110",-20,-40,Transition.ColorTint,nil,110,40,false)
            UILayout.SetSameAnchorAndPivot(gobtn, UILayout.BottomRight)
            GUI.SetData(gobtn,"ActivityId",tostring(Activity[i].id))
            GUI.RegisterUIEvent(gobtn, UCE.PointerClick, "FactionUI", "GotoJoin")
            local btnTxt = GUI.CreateStatic(gobtn, "btnTxt", "前往", 0, 0,70,50)
            UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
            local ButtonBoard = GUI.ImageCreate(act,"ButtonBoard"..i,"1800402113",-20,-40,false,110,40)
            UILayout.SetSameAnchorAndPivot(ButtonBoard, UILayout.BottomRight)
            local BoardTxt = GUI.CreateStatic(ButtonBoard,"BoardTxt"..i,"",0,0,110,40)
            GUI.SetVisible(ButtonBoard,false)
            UILayout.SetSameAnchorAndPivot(BoardTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(BoardTxt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
            local Finished = GUI.ImageCreate(act,"Finished"..i,"1800404060",-20,-40,false,110,40)
            UILayout.SetSameAnchorAndPivot(Finished, UILayout.BottomRight)
            GUI.SetVisible(Finished,false)

            if level < Activity[i].level then
                GUI.SetVisible(gobtn,false)
                GUI.SetVisible(ButtonBoard,true)
                GUI.StaticSetText(BoardTxt,"暂未开启")
                UILayout.StaticSetFontSizeColorAlignment(levelTxt, UIDefine.FontSizeM, UIDefine.RedColor, TextAnchor.Left)
            elseif Activity[i].state == 2 then
                GUI.SetVisible(gobtn,false)
                GUI.SetVisible(ButtonBoard,true)
                GUI.StaticSetText(BoardTxt,"未开始")
            elseif Activity[i].state == 3 then
                GUI.SetVisible(gobtn,false)
                GUI.SetVisible(ButtonBoard,false)
                GUI.SetVisible(Finished,true)
            else
                GUI.SetVisible(ButtonBoard,false)
                GUI.SetVisible(Finished,false)
                GUI.SetVisible(gobtn,true)
            end
        end
    --else
        --GUI.SetVisible(factionActivityBg,true)
        --[[local memberListBg = GUI.ImageCreate(factionProtectionBg, "memberListBg", "1800400010", 78, 100, false, 1045, 435)
        _gt.BindName(memberListBg, "memberListBg")
        UILayout.SetSameAnchorAndPivot(memberListBg, UILayout.TopLeft)

        local bg = GUI.ImageCreate(memberListBg, "bg1", "1801502020", 107, 130)
        UILayout.SetSameAnchorAndPivot(bg, UILayout.TopLeft)
        GUI.SetEulerAngles(bg, Vector3.New(0, 0, -180))
        local bg = GUI.ImageCreate(memberListBg, "bg2", "1801502040", -107, 130)
        UILayout.SetSameAnchorAndPivot(bg, UILayout.TopRight)
        GUI.SetEulerAngles(bg, Vector3.New(0, 0, -180))
        local bg = GUI.ImageCreate(memberListBg, "bg3", "1801502040", 4, -4)
        UILayout.SetSameAnchorAndPivot(bg, UILayout.BottomLeft)
        local bg = GUI.ImageCreate(memberListBg, "bg4", "1801502020", -4, -4)
        UILayout.SetSameAnchorAndPivot(bg, UILayout.BottomRight)
        local bg = GUI.ImageCreate(memberListBg, "bg5", "1801502070", -475, 0)
        UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)
        local bg = GUI.ImageCreate(memberListBg, "bg6", "1801502070", 475, 0)
        UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)
        GUI.SetEulerAngles(bg, Vector3.New(0, 0, -180))

        local protectionScroll = GUI.LoopScrollRectCreate(memberListBg,"protectionScroll", 6, 10, 1031, 415,
                "FactionUI","CreatProtectionItemPool","FactionUI","RefreshProtectionScroll", 0, false, Vector2.New(288, 100), 3,UIAroundPivot.Top, UIAnchor.Top)
        GUI.ScrollRectSetChildSpacing(protectionScroll, Vector2.New(10, 5))
        _gt.BindName(protectionScroll, "protectionScroll")

        local plusBtn = GUI.ButtonCreate(memberListBg, "plusBtn", "1800402150", 208, 64, Transition.SpriteSwap)
        _gt.BindName(plusBtn, "plusBtn")
        UILayout.SetSameAnchorAndPivot(plusBtn, UILayout.BottomLeft)
        GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "FactionUI", "OnExchangeProtectionPoint")

        local resetBtn = GUI.ButtonCreate(memberListBg, "resetBtn", "1800702110", 275, 64, Transition.SpriteSwap, "", 50, 50, false)
        _gt.BindName(resetBtn, "resetBtn")
        UILayout.SetSameAnchorAndPivot(resetBtn, UILayout.BottomLeft)
        GUI.RegisterUIEvent(resetBtn, UCE.PointerClick, "FactionUI", "OnResetProtectionPoint")

        local pointLeftTxt = GUI.CreateStatic(plusBtn, "pointLeftTxt", "可分配点数：0", -202, 0, 300, 45)
        _gt.BindName(pointLeftTxt, "pointLeftTxt")
        UILayout.SetSameAnchorAndPivot(pointLeftTxt, UILayout.Left)
        UILayout.StaticSetFontSizeColorAlignment(pointLeftTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local bigProtection = GUI.ButtonCreate(memberListBg, "bigProtectionBtn", "1800002030", 676, -440, Transition.None, "", 158, 50, false)
        _gt.BindName(bigProtection, "bigProtectionBtn")
        UILayout.SetSameAnchorAndPivot(bigProtection, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(bigProtection, "btnTxt", "大成守护", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        local pic = GUI.ImageCreate( memberListBg,"pic1", "1900100430", 620, -75)
        GUI.SetIsRaycastTarget(pic, true)
        pic:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(pic, UCE.PointerClick, "FactionUI", "OnBigProtectionClick")
        GUI.RegisterUIEvent(bigProtection, UCE.PointerClick, "FactionUI", "OnBigProtectionClick")

        local litProtectionBtn = GUI.ButtonCreate(memberListBg, "litProtectionBtn", "1800002031", 882, -440, Transition.None, "", 158, 50, false)
        _gt.BindName(litProtectionBtn, "litProtectionBtn")
        UILayout.SetSameAnchorAndPivot(litProtectionBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(litProtectionBtn, "btnTxt", "小成守护", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        local pic = GUI.ImageCreate( memberListBg,"pic1", "1900100380", 837, -71)
        GUI.SetIsRaycastTarget(pic, true)
        pic:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(pic, UCE.PointerClick, "FactionUI", "OnLitProtectionBtnClick")
        GUI.RegisterUIEvent(litProtectionBtn, UCE.PointerClick, "FactionUI", "OnLitProtectionBtnClick")

        local saveBtn = GUI.ButtonCreate(memberListBg, "saveBtn", "1800602030", 900, 64, Transition.ColorTint)
        _gt.BindName(saveBtn, "saveBtn")
        UILayout.SetSameAnchorAndPivot(saveBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(saveBtn, "btnTxt", "保存加点", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(saveBtn, UCE.PointerClick, "FactionUI", "OnSaveBtnClick")
    else
        GUI.SetVisible(factionProtectionBg, true)]]
    end
end

function FactionUI.OnResetProtectionPoint(guid)
    FactionUI.OnResetProtectionPointYes()
    --local typeTxt = (FactionUI.ProtectionSubIndex==1 and "大" or "小" )
    --GlobalUtils.ShowBoxMsg2Btn("提示","重置"..typeTxt.."成点数需要消耗["..typeTxt.."成重置册]，是否确认？","FactionUI","确认","OnResetProtectionPointYes","取消")
end

function FactionUI.GotoJoin(guid)
    local btn = GUI.GetByGuid(guid)
    local ActivityId = GUI.GetData(btn,"ActivityId")
    if ActivityId then
        GlobalUtils.JoinActivity(tonumber(ActivityId))
    end
end

function FactionUI.OnResetProtectionPointYes(param)
    CL.SendNotify(NOTIFY.SubmitForm, "FormPlayer", "GuildGuardianResetPoint", FactionUI.ProtectionSubIndex)
end

function FactionUI.OnSaveBtnClick(param)
    if FactionUI.ProtectionPointOpeLstTotal > 0 then
        local Points = ""
        local config = FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Attrs
        local count = #config
        for i = 1, count do
            if FactionUI.ProtectionPointOpeLst[i] ~= nil then
                if string.len(Points) == 0 then
                    Points = tostring(FactionUI.ProtectionPointOpeLst[i])
                else
                    Points = Points.."_"..(FactionUI.ProtectionPointOpeLst[i])
                end
            else
                if string.len(Points) == 0 then
                    Points = "0"
                else
                    Points = Points.."_0"
                end
            end
        end
        --这里发送数据
        CL.SendNotify(NOTIFY.SubmitForm, "FormPlayer", "GuildGuardianAddPoint", FactionUI.ProtectionSubIndex, Points)
        FactionUI.ProtectionPointOpeLst = {}
    end
end

function FactionUI.OnExchangeProtectionPoint(guid)
    local ExchangePPCover = _gt.GetUI("ExchangePPCover")
    if ExchangePPCover == nil then
        local panel = GUI.GetWnd("FactionUI")
        ExchangePPCover = GUI.ImageCreate(panel, "ExchangePPCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        _gt.BindName(ExchangePPCover, "ExchangePPCover")
        UILayout.SetSameAnchorAndPivot(ExchangePPCover, UILayout.Center)
        GUI.SetIsRaycastTarget(ExchangePPCover, true)

        local changeNameBg = GUI.ImageCreate(ExchangePPCover, "changeNameBg", "1800400300", 0, 0, false, 465, 400)
        UILayout.SetSameAnchorAndPivot(changeNameBg, UILayout.Center)

        local closeBtn = GUI.ButtonCreate(changeNameBg, "closeBtn", "1800302120", 0, 0, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_ExchangePP")

        local exchange0 = GUI.CreateStatic(changeNameBg, "exchange0", "已兑换", 45, 72, 150, 31)
        UILayout.SetSameAnchorAndPivot(exchange0, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(exchange0, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        local costCoinBg = GUI.ImageCreate(exchange0, "costCoinBg", "1800700010", 118, 0, false, 250, 33)
        UILayout.SetSameAnchorAndPivot(costCoinBg, UILayout.Left)
        local txt = GUI.CreateStatic(costCoinBg, "txt", "10/30", 0, 0, 250, 30)
        _gt.BindName(txt, "HaveExchangePP")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local exchange1 = GUI.CreateStatic(changeNameBg, "exchange1", "可兑换", 45, 122, 150, 31)
        UILayout.SetSameAnchorAndPivot(exchange1, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(exchange1, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        local costCoinBg = GUI.ImageCreate(exchange1, "costCoinBg", "1800700010", 118, 0, false, 250, 33)
        UILayout.SetSameAnchorAndPivot(costCoinBg, UILayout.Left)
        local txt = GUI.CreateStatic(costCoinBg, "txt", "20", 0, 0, 250, 30)
        _gt.BindName(txt, "LeftExchangePP")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local titleBg = GUI.ImageCreate(changeNameBg, "titleBg", "1800001140", 0, 15, false, 265, 33)
        UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)
        local txt = GUI.CreateStatic(titleBg, "txt", "点数兑换", 0, 0, 150, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local exchangeTxt = GUI.CreateStatic(changeNameBg, "exchangeTxt", "兑换数量", 44, 176, 250, 32)
        UILayout.SetSameAnchorAndPivot(exchangeTxt, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(exchangeTxt, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)

        local exchangeNum = GUI.EditCreate(changeNameBg, "exchangeNum", "1800400390", "0", 233, 170, Transition.ColorTint, "system", 130, 44, 8)
        _gt.BindName(exchangeNum, "exchangePPNum")
        UILayout.SetSameAnchorAndPivot(exchangeNum, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(exchangeNum, TextAnchor.MiddleCenter)
        GUI.EditSetFontSize(exchangeNum, UIDefine.FontSizeL)
        GUI.EditSetTextColor(exchangeNum, UIDefine.BrownColor)
        GUI.SetPlaceholderTxtColor(exchangeNum, UIDefine.GrayColor)
        GUI.EditSetMaxCharNum(exchangeNum, 10)
        GUI.RegisterUIEvent(exchangeNum, UCE.EndEdit, "FactionUI", "OnExchangePPModify")

        local minusBtn = GUI.ButtonCreate(changeNameBg,"MinusBtn", "1800402140", -43,-6, Transition.ColorTint, "")
        _gt.BindName(minusBtn, "ExchangePPMinusBtn")
        GUI.ButtonSetShowDisable(minusBtn, false)
        GUI.RegisterUIEvent(minusBtn, UCE.PointerClick, "FactionUI", "OnFactionExchangeMinusBtnClick")
        local plusBtn = GUI.ButtonCreate(changeNameBg,"PlusBtn", "1800402150", 161, -6, Transition.ColorTint, "")
        _gt.BindName(plusBtn, "ExchangePPPlusBtn")
        GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "FactionUI", "OnFactionExchangePlusBtnClick")

        local costTxt0 = GUI.CreateStatic(changeNameBg, "costTxt0", "消耗战功", 45, 235, 200, 31)
        _gt.BindName(costTxt0, "exchangeNodeCost0")
        UILayout.SetSameAnchorAndPivot(costTxt0, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(costTxt0, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        local costFactionMoneyBg = GUI.ImageCreate(costTxt0, "costFactionMoneyBg", "1800700010", 118, 0, false, 250, 33)
        UILayout.SetSameAnchorAndPivot(costFactionMoneyBg, UILayout.Left)
        local costFactionMoneyIcon = GUI.ImageCreate(costFactionMoneyBg, "costFactionMoneyIcon", "1800408550", 0, 0, false, 33, 33)
        UILayout.SetSameAnchorAndPivot(costFactionMoneyIcon, UILayout.Left)
        local txt = GUI.CreateStatic(costFactionMoneyBg, "txt", "10000", 0, 0, 250, 30)
        _gt.BindName(txt, "exchangePPCostFactionMoney0")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        local infoBtn = GUI.ButtonCreate(costFactionMoneyBg, "infoBtn0", "1800702030", 220, -2, Transition.ColorTint)
        GUI.RegisterUIEvent(infoBtn, UCE.PointerClick, "FactionUI", "OnFactionExchangePPInfo0Click")

        local costTxt2 = GUI.CreateStatic(changeNameBg, "costTxt2", "消耗帮贡", 45, 235, 200, 31)
        _gt.BindName(costTxt2, "exchangeNodeCost2")
        UILayout.SetSameAnchorAndPivot(costTxt2, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(costTxt2, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        local costFactionMoneyBg = GUI.ImageCreate(costTxt2, "costFactionMoneyBg", "1800700010", 118, 0, false, 250, 33)
        UILayout.SetSameAnchorAndPivot(costFactionMoneyBg, UILayout.Left)
        local costFactionMoneyIcon = GUI.ImageCreate(costFactionMoneyBg, "costFactionMoneyIcon", "1800408290", 0, 0, false, 33, 33)
        UILayout.SetSameAnchorAndPivot(costFactionMoneyIcon, UILayout.Left)
        local txt = GUI.CreateStatic(costFactionMoneyBg, "txt", "10000", 0, 0, 250, 30)
        _gt.BindName(txt, "exchangePPCostFactionMoney2")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        local infoBtn = GUI.ButtonCreate(costFactionMoneyBg, "infoBtn0", "1800702030", 220, -2, Transition.ColorTint)
        GUI.RegisterUIEvent(infoBtn, UCE.PointerClick, "FactionUI", "OnFactionExchangePPInfo2Click")

        local costTxt1 = GUI.CreateStatic(changeNameBg, "costTxt1", "消耗成就", 45, 284, 200, 31)
        UILayout.SetSameAnchorAndPivot(costTxt1, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(costTxt1, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        local costFactionMoneyBg = GUI.ImageCreate(costTxt1, "costFactionMoneyBg", "1800700010", 118, 0, false, 250, 33)
        UILayout.SetSameAnchorAndPivot(costFactionMoneyBg, UILayout.Left)
        local costFactionMoneyIcon = GUI.ImageCreate(costFactionMoneyBg, "costFactionMoneyIcon", "1800408300", 0, 0, false, 33, 33)
        UILayout.SetSameAnchorAndPivot(costFactionMoneyIcon, UILayout.Left)
        local txt = GUI.CreateStatic(costFactionMoneyBg, "txt", "20000", 0, 0, 250, 30)
        _gt.BindName(txt, "exchangePPCostFactionMoney1")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        local infoBtn = GUI.ButtonCreate(costFactionMoneyBg, "infoBtn1", "1800702030", 220, -2, Transition.ColorTint)
        GUI.RegisterUIEvent(infoBtn, UCE.PointerClick, "FactionUI", "OnFactionExchangePPInfo1Click")

        local concelBtn = GUI.ButtonCreate(changeNameBg, "concelBtn", "1800602030", 44, -21, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(concelBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(concelBtn, "btnTxt", "取消", 0, 0, 52, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_ExchangePP")

        local confirmBtn = GUI.ButtonCreate(changeNameBg, "confirmBtn", "1800602030", -50, -21, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(confirmBtn, "btnTxt", "兑换", 0, 0, 52, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "FactionUI", "OnConfirmBtnClick_ExchangePP")
    else
        GUI.SetVisible(ExchangePPCover, true)
    end

    local HaveExchangePP = _gt.GetUI("HaveExchangePP")
    if HaveExchangePP then
        GUI.StaticSetText(HaveExchangePP, FactionUI["Guardian_APoint_"..FactionUI.ProtectionSubIndex].."/"..FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Exchange.AllPoint)
    end
    local LeftExchangePP = _gt.GetUI("LeftExchangePP")
    if LeftExchangePP then
        GUI.StaticSetText(LeftExchangePP, FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Exchange.AllPoint-FactionUI["Guardian_APoint_"..FactionUI.ProtectionSubIndex])
    end
    local exchangePPNum = _gt.GetUI("exchangePPNum")
    if exchangePPNum then
        GUI.EditSetTextM(exchangePPNum, "0")
    end
    local exchangeNodeCost0 = _gt.GetUI("exchangeNodeCost0")
    if exchangeNodeCost0 then
        GUI.SetVisible(exchangeNodeCost0, FactionUI.ProtectionSubIndex==1)
    end
    local exchangeNodeCost2 = _gt.GetUI("exchangeNodeCost2")
    if exchangeNodeCost2 then
        GUI.SetVisible(exchangeNodeCost2, FactionUI.ProtectionSubIndex==2)
    end
    local exchangePPCostFactionMoney0 = _gt.GetUI("exchangePPCostFactionMoney0")
    if exchangePPCostFactionMoney0 then
        GUI.StaticSetText(exchangePPCostFactionMoney0, tostring(FactionUI.GuardianConfig[1].Exchange.Val_1))
    end
    local exchangePPCostFactionMoney1 = _gt.GetUI("exchangePPCostFactionMoney1")
    if exchangePPCostFactionMoney1 then
        GUI.StaticSetText(exchangePPCostFactionMoney1, tostring(FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Exchange.Val_2))
    end
    local exchangePPCostFactionMoney2 = _gt.GetUI("exchangePPCostFactionMoney2")
    if exchangePPCostFactionMoney2 then
        GUI.StaticSetText(exchangePPCostFactionMoney2, tostring(FactionUI.GuardianConfig[2].Exchange.Val_1))
    end
    local ExchangePPMinusBtn = _gt.GetUI("ExchangePPMinusBtn")
    if ExchangePPMinusBtn then
        GUI.ButtonSetShowDisable(ExchangePPMinusBtn, false)
    end
    local canExchangePoint = FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Exchange.AllPoint - FactionUI["Guardian_APoint_"..FactionUI.ProtectionSubIndex]
    local ExchangePPPlusBtn = _gt.GetUI("ExchangePPPlusBtn")
    if ExchangePPPlusBtn then
        GUI.ButtonSetShowDisable(ExchangePPPlusBtn, canExchangePoint>0)
    end
    local exchangePPNum = _gt.GetUI("exchangePPNum")
    if exchangePPNum then
        GUI.EditSetCanEdit(exchangePPNum, canExchangePoint>0)
    end
end

function FactionUI.OnFactionExchangePPInfo0Click()
    local ExchangePPCover = _gt.GetUI("ExchangePPCover")
    local tip = Tips.CreateHint("拥有："..UIDefine.ExchangeMoneyToStr(tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrGuildFightScore)))), ExchangePPCover, 286, 68, UILayout.Center, 160, 50, true)
    GUI.SetIsRemoveWhenClick(tip, true)
end

function FactionUI.OnFactionExchangePPInfo1Click()
    local ExchangePPCover = _gt.GetUI("ExchangePPCover")
    local tip = Tips.CreateHint("拥有："..UIDefine.ExchangeMoneyToStr(tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrGuildAchievement)))), ExchangePPCover, 286, 68, UILayout.Center, 160, 50, true)
    GUI.SetIsRemoveWhenClick(tip, true)
end

function FactionUI.OnFactionExchangePPInfo2Click()
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil then
        local ExchangePPCover = _gt.GetUI("ExchangePPCover")
        local tip = Tips.CreateHint("拥有："..UIDefine.ExchangeMoneyToStr((FactionUI.FactionData.self.total_contrb)), ExchangePPCover, 286, 68, UILayout.Center, 160, 50, true)
        GUI.SetIsRemoveWhenClick(tip, true)
    end
end

function FactionUI.OnExchangePPModify()
    local countEdit = _gt.GetUI("exchangePPNum")
    if countEdit ~= nil then
        local inputTxt = GUI.EditGetTextM(countEdit)
        local num = tonumber(inputTxt)
        num = math.max(1, num)
        local canExchangePoint = FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Exchange.AllPoint - FactionUI["Guardian_APoint_"..FactionUI.ProtectionSubIndex]
        num = math.min(canExchangePoint, num)
        GUI.EditSetTextM(countEdit, tostring(num))
        FactionUI.OnFactionExchangeBtnClick_Effect(num)
    end
end

function FactionUI.OnFactionExchangeMinusBtnClick()
    local exchangePPNum = _gt.GetUI("exchangePPNum")
    if exchangePPNum then
        local num = tonumber(GUI.EditGetTextM(exchangePPNum))
        num = math.max(num - 1, 0)
        FactionUI.OnFactionExchangeBtnClick_Effect(num)
    end
end

function FactionUI.OnFactionExchangePlusBtnClick()
    local canExchangePoint = FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Exchange.AllPoint - FactionUI["Guardian_APoint_"..FactionUI.ProtectionSubIndex]
    local exchangePPNum = _gt.GetUI("exchangePPNum")
    if exchangePPNum then
        local num = tonumber(GUI.EditGetTextM(exchangePPNum))
        num = math.min(num + 1, canExchangePoint)
        FactionUI.OnFactionExchangeBtnClick_Effect(num)
    end
end

function FactionUI.OnFactionExchangeBtnClick_Effect(num)
    local exchangePPNum = _gt.GetUI("exchangePPNum")
    if exchangePPNum then
        GUI.EditSetTextM(exchangePPNum, tonumber(num))
    end
    local exchangePPCostFactionMoney0 = _gt.GetUI("exchangePPCostFactionMoney0")
    if exchangePPCostFactionMoney0 then
        GUI.StaticSetText(exchangePPCostFactionMoney0, tostring(FactionUI.GuardianConfig[1].Exchange.Val_1*num))
    end
    local exchangePPCostFactionMoney1 = _gt.GetUI("exchangePPCostFactionMoney1")
    if exchangePPCostFactionMoney1 then
        GUI.StaticSetText(exchangePPCostFactionMoney1, FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Exchange.Val_2*num)
    end
    local exchangePPCostFactionMoney2 = _gt.GetUI("exchangePPCostFactionMoney2")
    if exchangePPCostFactionMoney2 then
        GUI.StaticSetText(exchangePPCostFactionMoney2, tostring(FactionUI.GuardianConfig[2].Exchange.Val_1*num))
    end
    local canExchangePoint = FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Exchange.AllPoint - FactionUI["Guardian_APoint_"..FactionUI.ProtectionSubIndex]
    local ExchangePPPlusBtn = _gt.GetUI("ExchangePPPlusBtn")
    if ExchangePPPlusBtn then
        GUI.ButtonSetShowDisable(ExchangePPPlusBtn, num <  canExchangePoint)
    end
    local ExchangePPMinusBtn = _gt.GetUI("ExchangePPMinusBtn")
    if ExchangePPMinusBtn then
        GUI.ButtonSetShowDisable(ExchangePPMinusBtn, num > 1 and canExchangePoint > 0)
    end
end

function FactionUI.OnCloseBtnClick_ExchangePP()
    local ExchangePPCover = _gt.GetUI("ExchangePPCover")
    if ExchangePPCover then
        GUI.SetVisible(ExchangePPCover, false)
    end
end

function FactionUI.OnConfirmBtnClick_ExchangePP()
    if FactionUI["Guardian_APoint_"..FactionUI.ProtectionSubIndex] >= FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Exchange.AllPoint then
        CL.SendNotify(NOTIFY.ShowBBMsg,"已兑换完所有点数，不可再兑换")
        return
    end

    local exchangePPNum = _gt.GetUI("exchangePPNum")
    if exchangePPNum then
        local num = tonumber(GUI.EditGetTextM(exchangePPNum))
        if num <=0 then
            CL.SendNotify(NOTIFY.ShowBBMsg,"请输入要兑换的点数")
            return
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormPlayer", "GuildGuardianExchangePoint", FactionUI.ProtectionSubIndex, num)
        FactionUI.OnCloseBtnClick_ExchangePP()
    end
end

function FactionUI.OnBigProtectionClick()
    FactionUI.ProtectionSubIndex = 1
    FactionUI.OnChangeProtectionTab(false)
end

function FactionUI.OnLitProtectionBtnClick()
    FactionUI.ProtectionSubIndex = 2
    FactionUI.OnChangeProtectionTab(true)
    if FactionUI.GuardianConfig == nil then
        --请求数据
        CL.SendNotify(NOTIFY.SubmitForm, "FormPlayer", "GetGuildGuardianConfig")
    end
end

function FactionUI.RefreshGuardianData()
    FactionUI.ProtectionPointOpeLst = {}
    FactionUI.ProtectionPointOpeLstTotal = 0
    local pointLeftTxt = _gt.GetUI("pointLeftTxt")
    if pointLeftTxt then
        GUI.StaticSetText(pointLeftTxt, "可分配点数：".. (FactionUI.ProtectionSubIndex == 1 and tostring(FactionUI.Guardian_Remain_1) or tostring(FactionUI.Guardian_Remain_2)))
    end

    FactionUI.ParseProtrctionPointData()
    --刷新数据
    local protectionScroll = _gt.GetUI("protectionScroll")
    if protectionScroll and FactionUI.GuardianConfig ~= nil then
        local count = #FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Attrs
        GUI.LoopScrollRectSetTotalCount(protectionScroll, count)
        GUI.LoopScrollRectRefreshCells(protectionScroll)
    end
end

--建立ID和索引的匹配表
function FactionUI.ParseProtrctionPointData()
    for k = 1, 2 do
        local count = #FactionUI.GuardianConfig[k].Attrs
        for i = 1, count do
            FactionUI.GuardianConfig[k].Attrs[i].NowPoint = FactionUI["Guardian_"..k.."_"..i]
        end
    end
end

function FactionUI.OnChangeProtectionTab(isLit)
    FactionUI.ProtectionPointOpeLst = {}
    FactionUI.ProtectionPointOpeLstTotal = 0
    local bigProtectionBtn = _gt.GetUI("bigProtectionBtn")
    if bigProtectionBtn then
        GUI.ButtonSetImageID(bigProtectionBtn, isLit and "1800002030" or "1800002031")
    end
    local litProtectionBtn = _gt.GetUI("litProtectionBtn")
    if litProtectionBtn then
        GUI.ButtonSetImageID(litProtectionBtn, isLit and "1800002031" or "1800002030")
    end
    local leftPoint = FactionUI["Guardian_Remain_"..FactionUI.ProtectionSubIndex]
    local pointLeftTxt = _gt.GetUI("pointLeftTxt")
    if pointLeftTxt and leftPoint then
        GUI.StaticSetText(pointLeftTxt, "可分配点数："..leftPoint)
    end
    if FactionUI.GuardianConfig ~= nil then
        local protectionScroll = _gt.GetUI("protectionScroll")
        local count = #FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Attrs
        if protectionScroll then
            GUI.LoopScrollRectSetTotalCount(protectionScroll, count)
            GUI.LoopScrollRectRefreshCells(protectionScroll)
        end
    end
end

function FactionUI.CreatProtectionItemPool()
    local protectionScroll =  _gt.GetUI("protectionScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(protectionScroll)
    local ItemIconBg = GUI.ImageCreate( protectionScroll,"item" .. curCount, "1800300060", 0, 0, false, 288, 100)
    GUI.RegisterUIEvent(ItemIconBg, UCE.PointerClick, "FactionUI", "OnProtectionItemClick")

    --物品图标背景
    GUI.ImageCreate( ItemIconBg,"itemGrade", "1800400050", 12, 12, false, 80, 80)
    GUI.ImageCreate( ItemIconBg,"icon", "1900803450", 19, 18, false, 64, 64)

    local plusBtn = GUI.ButtonCreate( ItemIconBg,"plusBtn", "1800707360", -9, 18, Transition.ColorTint)
    GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "FactionUI", "OnClickProtectionPlusBtn")
    UILayout.SetSameAnchorAndPivot(plusBtn, UILayout.TopRight)
    GUI.SetVisible(plusBtn, false)

    --名称
    local name = GUI.CreateStatic( ItemIconBg,"name", "抗13级台风", 9, -15, 280, 35)
    UILayout.SetSameAnchorAndPivot(name, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(name, UIDefine.FontSizeS, UIDefine.BrownColor, TextAnchor.MiddleCenter)

    --赎回数量
    local effect = GUI.CreateStatic( ItemIconBg,"effect", "13.65%", 9, 18, 200, 50)
    UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(effect, UIDefine.FontSizeM, UIDefine.Green7Color, TextAnchor.MiddleCenter)

    --当前数量
    GUI.ImageCreate( ItemIconBg,"back", "1800000020", 15, 66, false, 75, 22)
    local count = GUI.CreateStatic( ItemIconBg,"count", "10/20", -93, 27, 80, 25, "system", true)
    UILayout.SetSameAnchorAndPivot(count, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(count, UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(count, true)
    GUI.SetOutLine_Color(count, Color.New(0/255,0/255,0/255,255/255))
    GUI.SetOutLine_Distance(count, 1)

    local decreaseBtn = GUI.ButtonCreate( ItemIconBg,"decreaseBtn", "1800702070", 4, 72, Transition.ColorTint)
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerClick, "FactionUI", "OnClickProtectionMinusBtn")
    UILayout.SetSameAnchorAndPivot(decreaseBtn, UILayout.TopLeft)
    GUI.SetVisible(decreaseBtn, false)

    return ItemIconBg
end

function FactionUI.OnClickProtectionPlusBtn(guid)
    local btn = GUI.GetByGuid(guid)
    local item = GUI.GetParentElement(btn)
    if item then
        FactionUI.OnOpeProtectionPoint(item, true)
    end
end

function FactionUI.OnClickProtectionMinusBtn(guid)
    local btn = GUI.GetByGuid(guid)
    local item = GUI.GetParentElement(btn)
    if item then
        FactionUI.OnOpeProtectionPoint(item, false)
    end
end

function FactionUI.OnOpeProtectionPoint(item, isAdd)
    local leftPoint = FactionUI.ProtectionSubIndex == 1 and FactionUI.Guardian_Remain_1  or FactionUI.Guardian_Remain_2
    if isAdd and FactionUI.ProtectionPointOpeLstTotal >= leftPoint then
        CL.SendNotify(NOTIFY.ShowBBMsg,"可用点数不足")
        return
    elseif not isAdd and FactionUI.ProtectionPointOpeLstTotal <= 0 then
        test("操作异常了")
        return
    end

    local id = tonumber(GUI.GetData(item, "Id"))
    local config = FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Attrs
    if config then
        local data = config[id]
        if item and data then
            local num = isAdd and 1 or -1
            if FactionUI.ProtectionPointOpeLst[id] == nil then
                FactionUI.ProtectionPointOpeLst[id] = 0
            end
            FactionUI.ProtectionPointOpeLst[id] = FactionUI.ProtectionPointOpeLst[id] + num
            FactionUI.OnSwitchPlusAndDecreaseBtnVisible(item, id, data.NowPoint, data.MaxPoint, leftPoint>0)
            FactionUI.OnUpdateExchangeProtectionPointLeftTxt()
        end
    end
end

function FactionUI.OnUpdateExchangeProtectionPointLeftTxt()
    local total = 0
    for k,v in pairs(FactionUI.ProtectionPointOpeLst) do
        total = total + v
    end
    FactionUI.ProtectionPointOpeLstTotal = total
    local leftPoint = FactionUI["Guardian_Remain_"..FactionUI.ProtectionSubIndex]
    local pointLeftTxt = _gt.GetUI("pointLeftTxt")
    if pointLeftTxt then
        GUI.StaticSetText(pointLeftTxt, "可分配点数："..(leftPoint-total))
    end
end

function FactionUI.OnSwitchPlusAndDecreaseBtnVisible(item, id, now, max, haveLeftPoint)
    local ret = 0
    local append = FactionUI.ProtectionPointOpeLst[id] ~= nil and FactionUI.ProtectionPointOpeLst[id] or 0
    if append <= 0 then
        if FactionUI.ProtectionPointOpeLst[id] ~= nil then
            table.remove(FactionUI.ProtectionPointOpeLst,id)
        end
        ret = -1 --不能再减了
    else
        if now + append >= max then
            FactionUI.ProtectionPointOpeLst[id] = max - now
            append = FactionUI.ProtectionPointOpeLst[id]
            ret = 1 --不能再加了
        end
    end

    local plusBtn = GUI.GetChild(item, "plusBtn")
    if plusBtn then
        if ret ~= 1 and haveLeftPoint and now < max then
            GUI.SetVisible(plusBtn, true)
        else
            GUI.SetVisible(plusBtn, false)
        end
    end
    local decreaseBtn = GUI.GetChild(item, "decreaseBtn")
    if decreaseBtn then
        GUI.SetVisible(decreaseBtn, ret ~= -1 and append > 0)
    end

    local config = FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex].Attrs
    local data = config[id]
    local count = GUI.GetChild(item, "count")
    local effect = GUI.GetChild(item, "effect")
    local sttrConfig = DB.GetOnceAttrByKey2(data.Attr)
    if count and data and effect and sttrConfig then
        if append == 0 then
            if data.NowPoint == data.MaxPoint then
                GUI.StaticSetText(count, "<color=green>"..data.NowPoint.."/"..data.MaxPoint.."</color>")
            else
                GUI.StaticSetText(count, data.NowPoint.."/"..data.MaxPoint)
            end
        elseif append > 0 then
            GUI.StaticSetText(count, "<color=green>"..(data.NowPoint+append).."</color>/"..data.MaxPoint)
        end
        if sttrConfig.IsPct==1 then
            GUI.StaticSetText(effect, tostring((data.NowPoint+append)*data.AttrAdd/100).."%")
        else
            GUI.StaticSetText(effect, tostring((data.NowPoint+append)*data.AttrAdd))
        end
    end
end

function FactionUI.RefreshProtectionScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])

    local config = FactionUI.GuardianConfig[FactionUI.ProtectionSubIndex]
    local leftPoint = FactionUI["Guardian_Remain_"..FactionUI.ProtectionSubIndex]
    if config then
        local data = config.Attrs[index+1]
        local sttrConfig = DB.GetOnceAttrByKey2(data.Attr)
        if data and sttrConfig then
            local item = GUI.GetByGuid(guid)
            GUI.SetData(item, "Id", tostring(index+1))
            local icon = GUI.GetChild(item, "icon")
            GUI.ImageSetImageID(icon, tostring(data.Icon))
            local name = GUI.GetChild(item, "name")
            GUI.StaticSetText(name, sttrConfig.ChinaName)
            local effect = GUI.GetChild(item, "effect")
            if sttrConfig.IsPct==1 then
                GUI.StaticSetText(effect, tostring(data.NowPoint*data.AttrAdd/100).."%")
            else
                GUI.StaticSetText(effect, tostring(data.NowPoint*data.AttrAdd))
            end
            local count =  GUI.GetChild(item, "count")
            GUI.StaticSetText(count, data.NowPoint.."/"..data.MaxPoint)
            FactionUI.OnSwitchPlusAndDecreaseBtnVisible(item, index+1, data.NowPoint, data.MaxPoint, leftPoint>0)
        end
    end
end
function FactionUI.OnClickTab()
    UILayout.OnTabClick(FactionUI.SelectTabIndex, tabList)

    local factionInfoBg = _gt.GetUI("factionInfoBg")
    if factionInfoBg then
        GUI.SetVisible(factionInfoBg, FactionUI.SelectTabIndex == 1)
    end
    local factionMemberBg = _gt.GetUI("factionMemberBg")
    if factionMemberBg then
        GUI.SetVisible(factionMemberBg, FactionUI.SelectTabIndex == 2)
    end
    local factionBuildingBg = _gt.GetUI("factionBuildingBg")
    if factionBuildingBg then
        GUI.SetVisible(factionBuildingBg, FactionUI.SelectTabIndex == 4)
    end
    local factionProtectionBg = _gt.GetUI("factionProtectionBg")
    if factionProtectionBg then
        GUI.SetVisible(factionProtectionBg, FactionUI.SelectTabIndex == 3)
    end
end

--帮派建设
function FactionUI.OnFactionConstructClick( guid )
    local panelBg=GUI.Get("FactionUI/panelBg")
    local factionBuildingBg=GUI.Get("FactionUI/panelBg/factionBuildingBg")
    if factionBuildingBg == nil then
        factionBuildingBg=GUI.GroupCreate(panelBg,"factionBuildingBg",0,0, GUI.GetWidth(panelBg),GUI.GetHeight(panelBg))
        UILayout.SetSameAnchorAndPivot(factionBuildingBg, UILayout.Center)
        _gt.BindName(factionBuildingBg, "factionBuildingBg")

        --左侧榜单类型按钮列表
        local scrollBack = GUI.ImageCreate( factionBuildingBg,"scrollBack", "1800400200", 78, 60, false, 285, 558)
        UILayout.SetSameAnchorAndPivot(scrollBack, UILayout.TopLeft)

        local leftScroll  = GUI.ScrollListCreate(scrollBack, "leftScroll", 0, 10, 270, 540, false, UIAroundPivot.Top,UIAnchor.Top)
        GUI.ScrollRectSetAlignment(leftScroll,TextAnchor.UpperCenter)
        UILayout.SetSameAnchorAndPivot(leftScroll, UILayout.Top)

        local typeCount = #ConstructTypesName
        for i=1,typeCount do
            local btn = GUI.ButtonCreate(leftScroll,ConstructTypesName[i].btn,"1800002030",0,0, Transition.ColorTint,ConstructTypesName[i].name,265,65,false)
            _gt.BindName(btn, "ConstructBtn"..i)
            GUI.SetData(btn,"index", i)
            GUI.SetPreferredHeight(btn,65)
            UILayout.SetSameAnchorAndPivot(btn, UILayout.Center)
            GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeL)
            GUI.ButtonSetTextColor(btn,UIDefine.BrownColor)
            GUI.RegisterUIEvent(btn , UCE.PointerClick , "FactionUI", "OnFactionBuildingBtnClick")
        end

        local pointSp=GUI.ImageCreate(factionBuildingBg,"pointSp","1800800180",380,98)
        UILayout.SetSameAnchorAndPivot(pointSp, UILayout.TopLeft)

        local buildingName=GUI.CreateStatic(factionBuildingBg,"buildingName","",408,87, 250, 30)
        _gt.BindName(buildingName,"buildingName")
        UILayout.SetSameAnchorAndPivot(buildingName, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(buildingName, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local buildingLevel=GUI.CreateStatic(factionBuildingBg,"buildingLevel","",-94,87, 250, 30)
        _gt.BindName(buildingLevel,"buildingLevel")
        UILayout.SetSameAnchorAndPivot(buildingLevel, UILayout.TopRight)
        UILayout.StaticSetFontSizeColorAlignment(buildingLevel, UIDefine.FontSizeL, UIDefine.Green5Color, TextAnchor.MiddleRight)

        local cutLine=GUI.ImageCreate(factionBuildingBg,"cutLine","1800800170",-87,118,false,730,5)
        UILayout.SetSameAnchorAndPivot(cutLine, UILayout.TopRight)

        local buildingUpdateInfoBg=GUI.ImageCreate(factionBuildingBg,"buildingUpdateInfoBg","1800800160",-78,169,false,484,228)
        UILayout.SetSameAnchorAndPivot(buildingUpdateInfoBg, UILayout.TopRight)

        local titleBack=GUI.ImageCreate(buildingUpdateInfoBg,"titleBack","1801401180",0,-4, false, 142, 44)
        UILayout.SetSameAnchorAndPivot(titleBack, UILayout.TopLeft)

        local title=GUI.CreateStatic(titleBack,"title","",8,8, 150, 30)
        UILayout.SetSameAnchorAndPivot(title, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(title, UIDefine.FontSizeL, UIDefine.WhiteColor, nil)
        GUI.StaticSetText(title,"升级条件")

        local buildingLevelUpNodeMaxFlag = GUI.CreateStatic(title,"buildingLevelUpNodeMaxFlag","已满级",15,48, 150, 30)
        _gt.BindName(buildingLevelUpNodeMaxFlag, "buildingLevelUpNodeMaxFlag")
        GUI.SetVisible(buildingLevelUpNodeMaxFlag, false)
        UILayout.SetSameAnchorAndPivot(buildingLevelUpNodeMaxFlag, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(buildingLevelUpNodeMaxFlag, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local node1 = GUI.CreateStatic(title,"node1","建筑要求",15,48, 150, 30)
        _gt.BindName(node1, "buildingLevelUpNode1")
        UILayout.SetSameAnchorAndPivot(node1, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(node1, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local reqBack=GUI.ImageCreate(node1,"reqBack","1800800190",140,-6, false, 260, 38)
        UILayout.SetSameAnchorAndPivot(reqBack, UILayout.TopLeft)
        local level = GUI.CreateStatic(reqBack,"level","忠义堂3级",8,0, 150, 30)
        _gt.BindName(level, "buildingLevelUpLevel")
        UILayout.SetSameAnchorAndPivot(level, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(level, UIDefine.FontSizeL, UIDefine.Green5Color, TextAnchor.MiddleCenter)

        local node2 = GUI.CreateStatic(title,"node2","帮派建设度",15,88, 150, 30)
        _gt.BindName(node2, "buildingLevelUpNode2")
        UILayout.SetSameAnchorAndPivot(node2, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(node2, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local valBg = GUI.ImageCreate(node2, "valBg", "1800700010", 196, 1, false, 260, 30)
        local txt = GUI.CreateStatic(valBg, "txt", "0", 0, 0, 260, 35)
        _gt.BindName(txt, "buildingLevelUpNode2Txt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local node3 = GUI.CreateStatic(title,"node3","帮派资金",15,88, 150, 30)
        _gt.BindName(node3, "buildingLevelUpNode3")
        UILayout.SetSameAnchorAndPivot(node3, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(node3, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local valBg = GUI.ImageCreate(node3, "valBg", "1800700010", 196, 1, false, 260, 30)
        local txt = GUI.CreateStatic(valBg, "txt", "0", 0, 0, 260, 35)
        _gt.BindName(txt, "buildingLevelUpNode3Txt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        GUI.ImageCreate(valBg, "icon", "1800408340", -120, 0)

        local titleBack2=GUI.ImageCreate(buildingUpdateInfoBg,"titleBack2","1801401180",0,135, false, 142, 44)
        UILayout.SetSameAnchorAndPivot(titleBack2, UILayout.TopLeft)

        local title=GUI.CreateStatic(titleBack2,"title","",8,8, 150, 30)
        UILayout.SetSameAnchorAndPivot(title, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(title, UIDefine.FontSizeL, UIDefine.WhiteColor, nil)
        GUI.StaticSetText(title,"升级效果")

        local txt=GUI.CreateStatic(title,"txt","",165,45, 450,60, "system", true)
        _gt.BindName(txt, "buildingLevelUpEffect")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local factionBuildingDesBg=GUI.ImageCreate(factionBuildingBg,"factionBuildingDesBg","1800400010",152,-102,false,746,142)
        UILayout.SetSameAnchorAndPivot(factionBuildingDesBg, UILayout.Bottom)
        local txt=GUI.CreateStatic(factionBuildingDesBg,"txt","",0,0,710,100,"system",true)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.UpperLeft)

        local titleBack=GUI.ImageCreate(factionBuildingDesBg,"titleBack","1801401180",0,0, false, 142, 44)
        UILayout.SetSameAnchorAndPivot(titleBack, UILayout.TopLeft)

        local title=GUI.CreateStatic(titleBack,"title","",8,8, 150, 30)
        UILayout.SetSameAnchorAndPivot(title, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(title, UIDefine.FontSizeL, UIDefine.WhiteColor, nil)
        GUI.StaticSetText(title,"建筑效果")

        local txt=GUI.CreateStatic(title,"txt","",310,80, 685,90, "system", true)
        _gt.BindName(txt, "buildingDesc")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor,TextAnchor.UpperLeft)

        local arrow1=GUI.ImageCreate(factionBuildingDesBg,"arrow1","1801507120",11,-55, false, 29, 32)
        UILayout.SetSameAnchorAndPivot(arrow1, UILayout.TopLeft)

        local arrow2=GUI.ImageCreate(factionBuildingDesBg,"arrow2","1801507120",11,-83, false, 29, 32)
        UILayout.SetSameAnchorAndPivot(arrow2, UILayout.TopLeft)
        _gt.BindName(arrow2, "arrow2")

        local factionBuildIconBg=GUI.ImageCreate(factionBuildingBg,"factionBuildIconBg","1800001150",380,138,false,260,260)
        UILayout.SetSameAnchorAndPivot(factionBuildIconBg, UILayout.TopLeft)
        local icon=GUI.ImageCreate(factionBuildIconBg,"icon","1800807230",0,-20)
        UILayout.SetSameAnchorAndPivot(icon, UILayout.Bottom)
        _gt.BindName(icon, "factionBuildIcon")

        local maxFlag=GUI.ImageCreate(buildingUpdateInfoBg,"maxFlag","1800805020",-62,8, false,180, 133)
        _gt.BindName(maxFlag, "maxFlag")
        UILayout.SetSameAnchorAndPivot(maxFlag, UILayout.Center)
        GUI.SetVisible(maxFlag, false)

        local gotoBtn=GUI.ButtonCreate(factionBuildingBg,"gotoBtn","1800402090",305,264,Transition.ColorTint, "", 142, 48, false)
        _gt.BindName(gotoBtn, "gotoBtn")
        UILayout.SetSameAnchorAndPivot(gotoBtn, UILayout.Center)
        local btnTxt=GUI.CreateStatic(gotoBtn,"btnTxt","",0,0, 60, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        GUI.SetOutLine_Color(btnTxt,UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt,1)
        GUI.SetIsOutLine(btnTxt,true)
        GUI.StaticSetText(btnTxt,"前往")
        GUI.RegisterUIEvent(gotoBtn,UCE.PointerClick,"FactionUI","OnBuildingGotoBtnClick")

        local updateBtn=GUI.ButtonCreate(factionBuildingBg,"updateBtn","1800602030",453,264,Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(updateBtn, UILayout.Center)
        local btnTxt=GUI.CreateStatic(updateBtn,"btnTxt","",0,0, 60, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        GUI.SetOutLine_Color(btnTxt,UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt,1)
        GUI.SetIsOutLine(btnTxt,true)
        GUI.StaticSetText(btnTxt,"升级")
        GUI.RegisterUIEvent(updateBtn,UCE.PointerClick,"FactionUI","OnUpdateBuildingBtnClick")
    else
        GUI.SetVisible(factionBuildingBg,true)
    end

    local factionInfoBg=GUI.Get("FactionUI/panelBg/factionInfoBg")
    local factionActivity=GUI.Get("FactionUI/panelBg/factionActivity")
    local factionMemberBg=GUI.Get("FactionUI/panelBg/factionMemberBg")
    if factionInfoBg ~= nil then
        GUI.SetVisible(factionInfoBg,false)
    end
    if factionActivity ~= nil then
        GUI.SetVisible(factionActivity,false)
    end
    if factionMemberBg ~= nil then
        GUI.SetVisible(factionMemberBg,false)
    end

    --默认选中第一项
    FactionUI.OnFactionBuildingBtnClick(nil, 1)
end

function FactionUI.OnBuildingGotoBtnClick(guid)
    if FactionUI.ConstructData ~= nil then
        if FactionUI.ConstructData[FactionUI.SelectBuildingIndex]["BuildingNpc"] ~= 0 then
            CL.StartMove(FactionUI.ConstructData[FactionUI.SelectBuildingIndex]["BuildingNpc"])
            FactionUI.OnExit()
        else
            CL.SendNotify(NOTIFY.ShowBBMsg,"暂无可寻找的NPC对象")
        end
    end
end

function FactionUI.OnUpdateBuildingBtnClick(guid)
    if FactionUI.ConstructData ~= nil then
        local maxLevel = #FactionUI.ConstructData[FactionUI.SelectBuildingIndex]["BuildingLevels"]
        local level = FactionUI.GetBuildingLevel(FactionUI.SelectBuildingIndex)
        if level >= maxLevel then
            CL.SendNotify(NOTIFY.ShowBBMsg,"此建筑已满级")
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 22, tostring(FactionUI.SelectBuildingIndex))
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuild")
        end
    end
end

function FactionUI.OnFactionBuildingBtnClick(guid, btnIndex)
   local btn = guid ~= nil and GUI.GetByGuid(guid) or _gt.GetUI("ConstructBtn"..btnIndex)
    if btn then
        local index = tonumber(GUI.GetData(btn,"index"))
        FactionUI.ShowBuildingInfo(index)
        local typeCount = #ConstructTypesName
        for i = 1, typeCount do
            local otherBtn = _gt.GetUI("ConstructBtn"..i)
            if otherBtn then
                GUI.ButtonSetImageID(otherBtn,  i==index and "1800002031" or "1800002030")
            end
        end
    end
end

function FactionUI.RefreshConstructData()
    FactionUI.ShowBuildingInfo(FactionUI.SelectBuildingIndex)
end

function FactionUI.GetBuildingLevel(index)
    local level = 1
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.guild ~= nil then
        if index == 1 then
            level = FactionUI.FactionData.guild.base_level
        elseif index == 2 then
            level = FactionUI.FactionData.guild.academy_level
        elseif index == 3 then
            level = FactionUI.FactionData.guild.wing_room_level
        elseif index == 4 then
            level = FactionUI.FactionData.guild.vault_level
		elseif index == 5 then
			level = FactionUI.FactionData.guild.pharmacy_level
        end
    end
    return level
end

function FactionUI.ShowBuildingInfo(index)
    if FactionUI.ConstructData == nil or FactionUI.FactionData == nil or FactionUI.FactionData.guild == nil then
        return
    end
    local typeCount = #ConstructTypesName
    if index >= 1 and index <= typeCount then
        FactionUI.SelectBuildingIndex = index
        local factionBuildIcon = _gt.GetUI("factionBuildIcon")
        if factionBuildIcon then
            GUI.ImageSetImageID(factionBuildIcon, ConstructTypesName[index].pic)
        end
        local buildingName = _gt.GetUI("buildingName")
        if buildingName then
            GUI.StaticSetText(buildingName, ConstructTypesName[index].name)
        end
        local buildingLevel = _gt.GetUI("buildingLevel")
        local level = FactionUI.GetBuildingLevel(index)
        if buildingLevel then
            GUI.StaticSetText(buildingLevel, "建筑等级"..level.."级")
        end
        local buildingDesc = _gt.GetUI("buildingDesc")
        if buildingDesc then
            local s = ConstructTypesName[index].desc
            GUI.StaticSetText(buildingDesc, s)
            --test(s)
            local arrow2 = _gt.GetUI("arrow2")
            if string.find(s, "n") then
                GUI.SetVisible(arrow2, true)
            else
                GUI.SetVisible(arrow2, false)
            end
        end
        local nextLevel = level + 1
        local maxLevel = #FactionUI.ConstructData[index]["BuildingLevels"]

        local buildingLevelUpNodeMaxFlag = _gt.GetUI("buildingLevelUpNodeMaxFlag")
        if buildingLevelUpNodeMaxFlag then
            GUI.SetVisible(buildingLevelUpNodeMaxFlag, nextLevel>maxLevel)
        end
        local validReqCount = 0
        --需要目标建组的等级
        local buildingLevelUpLevel = _gt.GetUI("buildingLevelUpLevel")
        local buildingLevelUpNode1 = _gt.GetUI("buildingLevelUpNode1")
        if buildingLevelUpLevel and buildingLevelUpNode1 then
            if nextLevel <= maxLevel and FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["BuildingIdRequired"] ~= 0 then
                local info = FactionUI.ConstructData[FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["BuildingIdRequired"]]["BuildingName"]..FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["BuildingLevelRequired"].."级  "
                GUI.StaticSetText(buildingLevelUpLevel, info)
                GUI.SetVisible(buildingLevelUpNode1, true)
                GUI.SetColor(buildingLevelUpLevel, FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["BuildingLevelRequired"] <= FactionUI.GetBuildingLevel(FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["BuildingIdRequired"]) and UIDefine.Green5Color or UIDefine.RedColor)
                validReqCount = validReqCount + 1
            else
                GUI.SetVisible(buildingLevelUpNode1, false)
            end
        end

        --帮派建设度
        local buildingLevelUpNode2Txt = _gt.GetUI("buildingLevelUpNode2Txt")
        local buildingLevelUpNode2 = _gt.GetUI("buildingLevelUpNode2")
        if buildingLevelUpNode2Txt and buildingLevelUpNode2 then
            if nextLevel <= maxLevel and FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["BuildDegreeRequired"] ~= 0 then
                local info = tostring(FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["BuildDegreeRequired"])
                GUI.StaticSetText(buildingLevelUpNode2Txt, info)
                GUI.SetVisible(buildingLevelUpNode2, true)
                GUI.SetColor(buildingLevelUpNode2Txt, FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["BuildDegreeRequired"] <= FactionUI.FactionData.guild.build_degree and UIDefine.WhiteColor or UIDefine.RedColor)
                validReqCount = validReqCount + 1
                GUI.SetPositionY(buildingLevelUpNode2, 48 + (validReqCount-1)*40)
            else
                GUI.SetVisible(buildingLevelUpNode2, false)
            end
        end

        --帮派资金
        local buildingLevelUpNode3Txt = _gt.GetUI("buildingLevelUpNode3Txt")
        local buildingLevelUpNode3 = _gt.GetUI("buildingLevelUpNode3")
        if buildingLevelUpNode3Txt and buildingLevelUpNode3 then
            --print(FactionUI.FactionData.guild.fund)
            if nextLevel <= maxLevel and FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["FundRequired"] ~= 0 then
                local info = tostring(FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["FundRequired"])
                GUI.StaticSetText(buildingLevelUpNode3Txt, info)
                GUI.SetVisible(buildingLevelUpNode3, true)
                GUI.SetColor(buildingLevelUpNode3Txt, FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["FundRequired"] <= FactionUI.FactionData.guild.fund and UIDefine.WhiteColor or UIDefine.RedColor)
                validReqCount = validReqCount + 1
                GUI.SetPositionY(buildingLevelUpNode3, 48 + (validReqCount-1)*40)
            else
                GUI.SetVisible(buildingLevelUpNode3, false)
            end
        end

        local buildingLevelUpEffect = _gt.GetUI("buildingLevelUpEffect")
        if buildingLevelUpEffect then
            local info = "已满级"
            if nextLevel <= maxLevel then
                info = string.format(ConstructTypesName[index].effect, FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["Param1"]~=0 and tostring(FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["Param1"]) or "", FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["Param2"]~=0 and tostring(FactionUI.ConstructData[index]["BuildingLevels"][nextLevel]["Param2"]) or "")
            end
            GUI.StaticSetText(buildingLevelUpEffect, info)
        end
        local maxFlag = _gt.GetUI("maxFlag")
        if maxFlag then
            GUI.SetVisible(maxFlag, level>=maxLevel)
        end
        --是否显示前往按钮
        local gotoBtn = _gt.GetUI("gotoBtn")
        if gotoBtn then
            GUI.SetVisible(gotoBtn, FactionUI.ConstructData[index]["BuildingNpc"] ~= 0)
        end
    end
end

--创建帮派信息页签
function FactionUI.OnSelectFactionInfo()
    local panelBg = GUI.Get("FactionUI/panelBg")
    local factionInfoBg = _gt.GetUI("factionInfoBg")
    if factionInfoBg == nil then
        factionInfoBg = GUI.GroupCreate(panelBg, "factionInfoBg", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
        _gt.BindName(factionInfoBg, "factionInfoBg")
        UILayout.SetSameAnchorAndPivot(factionInfoBg, UILayout.Center)

        local leftNarrow = GUI.ImageCreate(factionInfoBg, "leftNarrow", "1800800050", 95, 65)
        UILayout.SetSameAnchorAndPivot(leftNarrow, UILayout.TopLeft)
        local rightNarrow = GUI.ImageCreate(factionInfoBg, "rightNarrow", "1800800060", 395, 65)
        UILayout.SetSameAnchorAndPivot(rightNarrow, UILayout.TopLeft)
        local faction_info = GUI.CreateStatic(factionInfoBg, "faction_info", "帮派信息", 275, 55, 97, 30)
        UILayout.SetSameAnchorAndPivot(faction_info, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(faction_info, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local factionName = GUI.CreateStatic(factionInfoBg, "factionName", "帮派名称", 90, 95, 97, 30)
        UILayout.SetSameAnchorAndPivot(factionName, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionName, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local factionNameBg = GUI.ImageCreate(factionName, "factionNameBg", "1800700010", 135, 0, false, 280, 35)
        local txt = GUI.CreateStatic(factionNameBg, "txt", "萌途一号帮派", 0, 0, 280, 35)
        _gt.BindName(txt, "factionNameTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local changeNameBtn = GUI.ButtonCreate(factionInfoBg, "changeNameBtn", "1800402120", 510, 90, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(changeNameBtn, UILayout.TopLeft)
        GUI.RegisterUIEvent(changeNameBtn, UCE.PointerClick, "FactionUI", "OnChangeNameBtnClick")

        local factionLevel = GUI.CreateStatic(factionInfoBg, "factionLevel", "帮派等级", 90, 145, 97, 30)
        UILayout.SetSameAnchorAndPivot(factionLevel, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionLevel, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local factionLevelBg = GUI.ImageCreate(factionLevel, "factionLevelBg", "1800700010", 135, 0, false, 75, 35)
        local txt = GUI.CreateStatic(factionLevelBg, "txt", "1", 0, 0, 75, 35)
        _gt.BindName(txt, "factionLevelTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local factionID = GUI.CreateStatic(factionInfoBg, "factionID", "帮派ID", 320, 145, 97, 30)
        UILayout.SetSameAnchorAndPivot(factionID, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionID, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local factionIDBg = GUI.ImageCreate(factionID, "factionIDBg", "1800700010", 80, 0, false, 160, 35)
        local txt = GUI.CreateStatic(factionIDBg, "txt", "55551555", 0, 0, 155, 35)
        _gt.BindName(txt, "factionIDTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local factionOwnerName = GUI.CreateStatic(factionInfoBg, "factionOwnerName", "帮主名称", 90, 195, 97, 30)
        UILayout.SetSameAnchorAndPivot(factionOwnerName, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionOwnerName, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local factionOwnerNameBg = GUI.ImageCreate(factionOwnerName, "factionOwnerNameBg", "1800700010", 135, 0, false, 335, 35)
        local txt = GUI.CreateStatic(factionOwnerNameBg, "txt", "萌途帮主", 0, 0, 335, 35)
        _gt.BindName(txt, "factionOwnerNameTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local factionMember = GUI.CreateStatic(factionInfoBg, "factionMember", "帮派成员", 90, 245, 97, 30)
        UILayout.SetSameAnchorAndPivot(factionMember, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionMember, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local Bg = GUI.ImageCreate(factionMember, "Bg", "1800700010", 135, 0, false, 335, 35)
        local txt = GUI.CreateStatic(Bg, "txt", "999/999/999", 0, 0, 335, 35)
        _gt.BindName(txt, "factionMemberTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local leftNarrow = GUI.ImageCreate(factionInfoBg, "leftNarrow", "1800800050", 95, 310)
        UILayout.SetSameAnchorAndPivot(leftNarrow, UILayout.TopLeft)
        local rightNarrow = GUI.ImageCreate(factionInfoBg, "rightNarrow", "1800800060", 395, 310)
        UILayout.SetSameAnchorAndPivot(rightNarrow, UILayout.TopLeft)
        local faction_state = GUI.CreateStatic(factionInfoBg, "faction_state", "帮派状态", 275, 300, 97, 30)
        UILayout.SetSameAnchorAndPivot(faction_state, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(faction_state, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local factionMoney = GUI.CreateStatic(factionInfoBg, "factionMoney", "帮派资金", 90, 340, 97, 30)
        UILayout.SetSameAnchorAndPivot(factionMoney, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionMoney, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local factionMoney_slider = GUI.ScrollBarCreate(factionMoney, "factionMoney_slider", "", "1800408160", "1800408110", 135, 0, 335, 24, 0, false, Transition.None, 0, 1)
        _gt.BindName(factionMoney_slider, "factionMoneySlider")
        GUI.ScrollBarSetBgSize(factionMoney_slider, Vector2.New(335, 24))
        GUI.ScrollBarSetHandlePivot(factionMoney_slider, UIAroundPivot.Right)
        UILayout.SetSameAnchorAndPivot(factionMoney_slider, UILayout.Left)
        GUI.ScrollBarSetPos(factionMoney_slider, 0.6)

        local txt = GUI.CreateStatic(factionMoney_slider, "txt", "0/80901020", 0, 0, 335, 35)
        _gt.BindName(txt, "factionMoneySliderTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local factionMaintenance = GUI.CreateStatic(factionInfoBg, "factionMaintenance", "帮派建设度", 90, 440, 123, 30)
        UILayout.SetSameAnchorAndPivot(factionMaintenance, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionMaintenance, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local factionMaintenanceBg = GUI.ImageCreate(factionMaintenance, "factionMaintenanceBg", "1800700010", 135, 0, false, 335, 35)
        local txt = GUI.CreateStatic(factionMaintenanceBg, "txt", "3000", 0, 0, 335, 35)
        _gt.BindName(txt, "factionMaintenanceTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local infoBtn = GUI.ButtonCreate(factionMaintenance, "infoBtn", "1800702030", 450, -2, Transition.ColorTint)
        GUI.RegisterUIEvent(infoBtn, UCE.PointerClick, "FactionUI", "OnfactionMaintenanceInfoBtnClick")

        --[[local leftNarrow = GUI.ImageCreate(factionInfoBg, "leftNarrow", "1800800050", 95, 484)
        UILayout.SetSameAnchorAndPivot(leftNarrow, UILayout.TopLeft)
        local rightNarrow = GUI.ImageCreate(factionInfoBg, "rightNarrow", "1800800060", 395, 484)
        UILayout.SetSameAnchorAndPivot(rightNarrow, UILayout.TopLeft)
        local faction_state = GUI.CreateStatic(factionInfoBg, "faction_maintain", "维护消耗", 275, 474, 97, 30)
        UILayout.SetSameAnchorAndPivot(faction_state, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(faction_state, UIDefine.FontSizeL, UIDefine.BrownColor, nil)]]

        local factionmMintainCost = GUI.CreateStatic(factionInfoBg, "factionmMintainCost", "每日维护费", 90, 390, 120, 30)
        UILayout.SetSameAnchorAndPivot(factionmMintainCost, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionmMintainCost, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local Bg = GUI.ImageCreate(factionmMintainCost, "Bg", "1800700010", 135, 0, false, 335, 35)
        local txt = GUI.CreateStatic(Bg, "txt", "50000", 0, 0, 335, 35)
        --GUI.ImageCreate(factionmMintainCost, "icon", "1800408340", 125, -4)
        _gt.BindName(txt, "factionmMintainCostTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local infoBtn = GUI.ButtonCreate(factionmMintainCost, "infoBtn", "1800702030", 450, -2, Transition.ColorTint)
        GUI.RegisterUIEvent(infoBtn, UCE.PointerClick, "FactionUI", "OnFactionIngotInfoBtnClick")

        --[[local leftNarrow = GUI.ImageCreate(factionInfoBg, "leftNarrow", "1800800050", 615, -575)
        UILayout.SetSameAnchorAndPivot(leftNarrow, UILayout.BottomLeft)
        local rightNarrow = GUI.ImageCreate(factionInfoBg, "rightNarrow", "1800800060", 915, -575)
        UILayout.SetSameAnchorAndPivot(rightNarrow, UILayout.BottomLeft)
        local faction_achieve = GUI.CreateStatic(factionInfoBg, "faction_achieve", "帮派战绩", 795, -565, 97, 30)
        UILayout.SetSameAnchorAndPivot(faction_achieve, UILayout.BottomLeft)
        UILayout.StaticSetFontSizeColorAlignment(faction_achieve, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        --[[local factionAchieveVal0 = GUI.CreateStatic(factionInfoBg, "factionAchieveVal0", "帮派威望", 610, -525, 97, 30)
        UILayout.SetSameAnchorAndPivot(factionAchieveVal0, UILayout.BottomLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionAchieveVal0, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local Bg = GUI.ImageCreate(factionAchieveVal0, "Bg", "1800700010", 135, -5, false, 335, 35)
        local txt = GUI.CreateStatic(Bg, "txt", "1000", 0, 0, 335, 30)
        _gt.BindName(txt, "factionAchieveVal0Txt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local factionAchieveVal1 = GUI.CreateStatic(factionInfoBg, "factionAchieveVal1", "帮派战绩", 610, -475, 97, 30)
        UILayout.SetSameAnchorAndPivot(factionAchieveVal1, UILayout.BottomLeft)
        UILayout.StaticSetFontSizeColorAlignment(factionAchieveVal1, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local Bg = GUI.ImageCreate(factionAchieveVal1, "Bg", "1800700010", 135, -5, false, 335, 35)
        local txt = GUI.CreateStatic(Bg, "txt", "1000", 0, 0, 335, 30)
        _gt.BindName(txt, "factionAchieveVal1Txt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)]]

        local leftNarrow = GUI.ImageCreate(factionInfoBg, "leftNarrow", "1800800050", 95, 505)
        UILayout.SetSameAnchorAndPivot(leftNarrow, UILayout.TopLeft)
        local rightNarrow = GUI.ImageCreate(factionInfoBg, "rightNarrow", "1800800060", 395, 505)
        UILayout.SetSameAnchorAndPivot(rightNarrow, UILayout.TopLeft)
        local faction_dividend = GUI.CreateStatic(factionInfoBg, "faction_dividend", "帮派分红", 275, 495, 97, 30)
        UILayout.SetSameAnchorAndPivot(faction_dividend, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(faction_dividend, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local contriCount = 1--#ContributeGoldInfo
        for i = 1, contriCount do
            local factionContribution = GUI.CreateStatic(factionInfoBg, "factionContribution"..i, ContributeGoldInfo[i].name, 90, 535--[[-378+(i-1)*48]], 97, 30)
            UILayout.SetSameAnchorAndPivot(factionContribution, UILayout.TopLeft)
            UILayout.StaticSetFontSizeColorAlignment(factionContribution, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
            local factionContributionBg = GUI.ImageCreate(factionContribution, "factionContributionBg", "1800700010", 135, -5, false, 335, 35)
            GUI.SetData(factionContributionBg, "Index", tostring(i))
            GUI.SetIsRaycastTarget(factionContributionBg, true)
            factionContributionBg:RegisterEvent(UCE.PointerClick)
            GUI.RegisterUIEvent(factionContributionBg, UCE.PointerClick, "FactionUI", "OnClickContributionBg")
            local txt = GUI.CreateStatic(factionContributionBg, "txt", "0", 0, 0, 335, 35)
            _gt.BindName(txt, "factionContributionTxt"..i)
            GUI.SetIsRaycastTarget(txt, false)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
            local icon = GUI.ImageCreate(factionContributionBg, "icon", ContributeGoldInfo[i].icon, -10, -5)
            GUI.SetIsRaycastTarget(icon, false)
        end
        local Week_dividend = GUI.CreateStatic(factionInfoBg, "Week_dividend", "下周分红", 90, 575, 97, 30)
        _gt.BindName(Week_dividend, "Week_dividend")
        UILayout.SetSameAnchorAndPivot(Week_dividend, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(Week_dividend, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local Bg = GUI.ImageCreate(Week_dividend, "Bg", "1800700010", 135, 0, false, 240, 35)
        local txt = GUI.CreateStatic(Bg, "dividend", "0", 0, 0, 335, 35)
        _gt.BindName(txt,"dividend")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local ReceiveBtn = GUI.ButtonCreate(factionInfoBg, "ReceiveBtn", "1800402110", 480, 572, Transition.ColorTint,nil,80, 38,false)
        _gt.BindName(ReceiveBtn,"ReceiveBtn")
        UILayout.SetSameAnchorAndPivot(ReceiveBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(ReceiveBtn, "btnTxt", "领取", 0, 0, 70, 35)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.Brown3Color, TextAnchor.MiddleCenter)
--[[        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)]]
        GUI.RegisterUIEvent(ReceiveBtn, UCE.PointerClick, "FactionUI", "OnReceiveBtnClick")
        local ReceiveUnUse = GUI.ImageCreate(factionInfoBg,"ReceiveUnUse","1800402113",480,572,false,80,38)
        UILayout.SetSameAnchorAndPivot(ReceiveUnUse, UILayout.TopLeft)
        local ReceiveUnUseTxt = GUI.CreateStatic(ReceiveUnUse,"btnTxt", "领取", 0, 0, 70, 35)
        UILayout.SetSameAnchorAndPivot(ReceiveUnUseTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(ReceiveUnUseTxt, UIDefine.FontSizeM, UIDefine.Brown3Color, TextAnchor.MiddleCenter)
        GUI.SetVisible(ReceiveUnUse,false)
        _gt.BindName(ReceiveUnUse,"ReceiveUnUse")

        local factionBoardBg = GUI.ImageCreate(factionInfoBg, "factionBoardBg", "1800400010", -75, 70, false, 540, 190)
        UILayout.SetSameAnchorAndPivot(factionBoardBg, UILayout.TopRight)
        local factionBoardBg_TitleBg = GUI.ImageCreate(factionBoardBg, "factionBoardBg_TitleBg", "1800700070", 0, -17, false, 532, 36)
        UILayout.SetSameAnchorAndPivot(factionBoardBg_TitleBg, UILayout.Top)
        local txt = GUI.CreateStatic(factionBoardBg_TitleBg, "txt", "帮派宣言", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local boardTxt = GUI.CreateStatic(factionBoardBg, "boardTxt", "", 0, 25, 510, 100, "system", true)
        UILayout.SetSameAnchorAndPivot(boardTxt, UILayout.Top)
        UILayout.StaticSetFontSizeColorAlignment(boardTxt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.UpperLeft)
        GUI.StaticSetText(boardTxt, "帮派宣言帮派宣言帮派宣言帮派宣言帮派宣言帮派宣言帮派宣言帮派宣言帮派宣言帮派宣言")
        _gt.BindName(boardTxt, "boardTxt")
        local changeBoardBtn = GUI.ButtonCreate(factionBoardBg, "changeBoardBtn", "1800402120", 10, -10, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(changeBoardBtn, UILayout.BottomRight)
        GUI.RegisterUIEvent(changeBoardBtn, UCE.PointerClick, "FactionUI", "OnChangeBoardBtnClick")

        local memberListBg = GUI.ImageCreate(factionBoardBg, "memberListBg", "1800400010", 0, 210, false, 540, 275)
        _gt.BindName(memberListBg, "memberListBg")
        UILayout.SetSameAnchorAndPivot(memberListBg, UILayout.TopLeft)

        local nameBtn = GUI.ImageCreate(memberListBg, "nameBtn", "1800800120", 4, -9, false, 180, 36)
        UILayout.SetSameAnchorAndPivot(nameBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(nameBtn, "btnTxt", "在线成员", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local levelBtn = GUI.ImageCreate(memberListBg, "levelBtn", "1800800130", 184, -9, false, 80, 36)
        UILayout.SetSameAnchorAndPivot(levelBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(levelBtn, "btnTxt", "等级", 0, 0, 50, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local schoolBtn = GUI.ImageCreate(memberListBg, "schoolBtn", "1800800130", 264, -9, false, 132, 36)
        UILayout.SetSameAnchorAndPivot(schoolBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(schoolBtn, "btnTxt", "门派", 0, 0, 50, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local positionBtn = GUI.ImageCreate(memberListBg, "positionBtn", "1800800140", 396, -9, false, 140, 36)
        UILayout.SetSameAnchorAndPivot(positionBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(positionBtn, "btnTxt", "职位", 0, 0, 50, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
    --在线成员
        local InfoMemberList  = GUI.ScrollListCreate(memberListBg, "InfoMemberList", 0, 30, 526, 230, false, UIAroundPivot.Top,UIAnchor.Top)
        --local InfoMemberListScr = GUI.GroupCreate(InfoMemberList, "InfoMemberListScr", 7, 28,0, 400)
        GUI.ScrollRectSetAlignment(InfoMemberList,TextAnchor.UpperCenter)
        UILayout.SetSameAnchorAndPivot(InfoMemberList, UILayout.Top)
        _gt.BindName(InfoMemberList, "InfoMemberListScr")
        FactionUI.CreatInfoMemberItemList()
        FactionUI.RefreshInfoMemberItem()


        local contributeBtn = GUI.ButtonCreate(factionInfoBg, "contributeBtn", "1800602030", -240, -50, Transition.ColorTint)
        GUI.AddRedPoint(contributeBtn,UIAnchor.TopRight,-5,5,"1800208080")
        GUI.SetRedPointVisable(contributeBtn,FactionUI.contributeBtnRedPoint)
        _gt.BindName(contributeBtn,"contributeBtn")
        UILayout.SetSameAnchorAndPivot(contributeBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(contributeBtn, "btnTxt", "帮派捐献", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(contributeBtn, UCE.PointerClick, "FactionUI", "OnContributeBtnClick")

        local sendNotifyBtn = GUI.ButtonCreate(factionInfoBg, "sendNotifyBtn", "1800602030", -85, -50, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(sendNotifyBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(sendNotifyBtn, "btnTxt", "发送通知", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(sendNotifyBtn, UCE.PointerClick, "FactionUI", "OnSendNotifyBtnClick")

        local backToFactionBtn = GUI.ButtonCreate(factionInfoBg, "backToFactionBtn", "1800602030", -395, -50, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(backToFactionBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(backToFactionBtn, "btnTxt", "回到帮派", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(backToFactionBtn, UCE.PointerClick, "FactionUI", "OnBackToFactionBtnClick")
    else
            GUI.SetVisible(factionInfoBg, true)
    end

    if FactionUI.FactionData == nil or FactionUI.FactionData.guild == nil or FactionUI.FactionData.self == nil then
        return
    end

    local txt = _gt.GetUI("factionNameTxt")
    if txt then
        GUI.StaticSetText(txt, FactionUI.FactionData.guild.name)
    end
    txt = _gt.GetUI("factionLevelTxt")--帮派等级
    if txt then
        GUI.StaticSetText(txt, FactionUI.FactionData.guild.level)
    end
    txt = _gt.GetUI("factionIDTxt")
    if txt then
        GUI.StaticSetText(txt, FactionUI.FactionData.guild.guild_id)
    end
    txt = _gt.GetUI("factionOwnerNameTxt")
    if txt then
        GUI.StaticSetText(txt, FactionUI.FactionData.guild.leader_name)
    end
    txt = _gt.GetUI("factionMemberTxt")
    if txt then
        if FactionUI.FactionData then
            if FactionUI.FactionData.guild then
                local maxNum = FactionUI.FactionData.guild.max_member_count
                GUI.StaticSetText(txt, FactionUI.FactionData.guild.online_count.."/"..FactionUI.FactionData.guild.member_count.."/"..maxNum)
            end
        end
    end
    txt = _gt.GetUI("factionMoneySliderTxt")
    local TXT = _gt.GetUI("factionMoneySlider")
    if txt then
        if TXT then
            local level = FactionUI.FactionData.guild.wing_room_level
            if FactionUI.ConstructData then
                if FactionUI.InitialFund then
                    if FactionUI.ConstructData[3]["BuildingLevels"][level] then
                        FACTION_GOLD_MAX_SHOW = FactionUI.ConstructData[3]["BuildingLevels"][level]["Param1"]
                        GUI.StaticSetText(txt, FactionUI.FactionData.guild.fund.."/"..FACTION_GOLD_MAX_SHOW)
                        GUI.ScrollBarSetPos(TXT, FactionUI.FactionData.guild.fund/tonumber(FACTION_GOLD_MAX_SHOW))
                    else
                        FACTION_GOLD_MAX_SHOW = FactionUI.InitialFund
                        GUI.StaticSetText(txt, FactionUI.FactionData.guild.fund.."/"..FACTION_GOLD_MAX_SHOW)
                        GUI.ScrollBarSetPos(TXT, FactionUI.FactionData.guild.fund/tonumber(FACTION_GOLD_MAX_SHOW))
                    end
                end
            end
        end
    end
    txt = _gt.GetUI("factionMaintenanceTxt")
    if txt then
        GUI.StaticSetText(txt, FactionUI.FactionData.guild.build_degree)
    end
    txt = _gt.GetUI("factionmMintainCostTxt")
    if txt then
        if FactionUI.DailyCareFund then
            local consume = FactionUI.DailyCareFund[FactionUI.FactionData.guild.level]--帮派每日资金消耗
            GUI.StaticSetText(txt, tostring(consume))
        end
    end
    txt = _gt.GetUI("factionAchieveVal0Txt")
    if txt then
        GUI.StaticSetText(txt, FactionUI.FactionData.guild.prestige)
    end
    txt = _gt.GetUI("factionAchieveVal1Txt")
    if txt then
        GUI.StaticSetText(txt, FactionUI.FactionData.guild.fight_score)
    end
    txt = _gt.GetUI("factionContributionTxt1")
    if txt then
        GUI.StaticSetText(txt, UIDefine.ExchangeMoneyToStr(FactionUI.FactionData.self.total_contrb))
    end
    txt = _gt.GetUI("factionContributionTxt2")
    if txt then
        GUI.StaticSetText(txt, UIDefine.ExchangeMoneyToStr(tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrGuildAchievement)))))
    end
    txt = _gt.GetUI("factionContributionTxt3")
    if txt then
        GUI.StaticSetText(txt, UIDefine.ExchangeMoneyToStr(tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrGuildFightScore)))))
    end
    txt = _gt.GetUI("nextWeekDivendTxt")
    if txt then
        GUI.StaticSetText(txt, 0)  --功能后续待添加
    end
    txt = _gt.GetUI("boardTxt")
    if txt then
        GUI.StaticSetText(txt, FactionUI.FactionData.guild.declaration)
    end
    local Btn = _gt.GetUI("ReceiveBtn")
    local Pic = _gt.GetUI("ReceiveUnUse")
    local Week_dividend = _gt.GetUI("Week_dividend")
    local dividend = _gt.GetUI("dividend")
    if FactionUI.DividendState == 1 then
        --GUI.ButtonSetImageID(Btn,1800402113)
        GUI.SetVisible(Btn,false)
        GUI.SetVisible(Pic,true)
        GUI.StaticSetText(Week_dividend,"下周分红")
        GUI.StaticSetText(dividend,FactionUI.ThisWeekDividend or 0)
    else
        GUI.SetVisible(Btn,true)
        GUI.SetVisible(Pic,false)
        GUI.StaticSetText(Week_dividend,"本周分红")
        GUI.StaticSetText(dividend,FactionUI.LastWeekDividend or 0)
    end
end

function FactionUI.OnClickContributionBg(guid)
    local bg = GUI.GetByGuid(guid)
    local factionInfoBg = _gt.GetUI("factionInfoBg")
    if bg and factionInfoBg then
        local index = tonumber(GUI.GetData(bg, "Index"))
        local tip = Tips.CreateHint(ContributeGoldInfo[index].desc, factionInfoBg, -200, 400, UILayout.Top, 340, 150, true)
        if tip then
            local txt = GUI.GetChild(tip, "hintText")
            if txt then
                UILayout.SetSameAnchorAndPivot(txt, UILayout.TopLeft)
                GUI.SetPositionX(txt, 19)
                GUI.SetPositionY(txt, 57)
                GUI.StaticSetAlignment(txt, TextAnchor.UpperLeft)
                local height = GUI.StaticGetLabelPreferHeight(txt)
                GUI.SetHeight(tip, height + 72)
            end
            local name = GUI.CreateStatic(tip, "name", ContributeGoldInfo[index].name, -60, 10, 120, 30, "system", false)
            GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
            GUI.ImageCreate(tip, "icon", ContributeGoldInfo[index].icon, -152, 4)
            GUI.ImageCreate(tip, "line", "1800600030", 0, 46, false, 450, 3)

            GUI.SetIsRemoveWhenClick(tip, true)
        end
    end
end

function FactionUI.OnFactionIngotInfoBtnClick()
    local factionInfoBg = _gt.GetUI("factionInfoBg")
    local tip = Tips.CreateHint("             帮派维护需要每日扣除固定的资金\n              ●1级帮派每日扣除"..FactionUI.DailyCareFund[1].."帮派资金\n              ●2级帮派每日扣除"..FactionUI.DailyCareFund[2].."帮派资金\n              ●3级帮派每日扣除"..FactionUI.DailyCareFund[3].."帮派资金\n              ●4级帮派每日扣除"..FactionUI.DailyCareFund[4].."帮派资金\n              ●5级帮派每日扣除"..FactionUI.DailyCareFund[5].."帮派资金\n<color=yellow>        当帮派资金不足时，将会发邮件予以警告</color>", factionInfoBg, -28, 68, UILayout.Center, 490, nil, true)
    GUI.SetIsRemoveWhenClick(tip, true)
end

--帮派成员页
function FactionUI.OnSelectFactionMember()
    local factionMemberBg = GUI.Get("FactionUI/panelBg/factionMemberBg")
    if factionMemberBg == nil then
        local panelBg = GUI.Get("FactionUI/panelBg")
        factionMemberBg = GUI.GroupCreate(panelBg, "factionMemberBg", 0, 20, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
        _gt.BindName(factionMemberBg, "factionMemberBg")
        UILayout.SetSameAnchorAndPivot(factionMemberBg, UILayout.Center)

        local factionMemberListBtn = GUI.CheckBoxCreate(factionMemberBg, "factionMemberListBtn", "1800402030", "1800402031", 78, 45, Transition.ColorTint, true, 115, 37)
        _gt.BindName(factionMemberListBtn, "factionMemberListBtn")
        UILayout.SetSameAnchorAndPivot(factionMemberListBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(factionMemberListBtn, "btnTxt", "成员列表", 0, 0, 88, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
        GUI.RegisterUIEvent(factionMemberListBtn, UCE.PointerClick, "FactionUI", "OnFactionMemberListBtnClick")

        local factionApplyListBtn = GUI.CheckBoxCreate(factionMemberBg, "factionApplyListBtn", "1800402030", "1800402031", 192, 45, Transition.ColorTint, false, 115, 37)
        _gt.BindName(factionApplyListBtn,"factionApplyListBtn")
        GUI.AddRedPoint(factionApplyListBtn,UIAnchor.TopRight,-5,5,"1800208080")
        GUI.SetRedPointVisable(factionApplyListBtn,false)

        local changeBoardPermission=LD.HavePermission(FactionUI.FactionData.self.permission,guild_permission.guild_permission_apply_aduit)
        if changeBoardPermission then
            if FactionUI.ApplyList.Count > 0 then
                GUI.SetRedPointVisable(factionApplyListBtn,true)
            else
                GUI.SetRedPointVisable(factionApplyListBtn,false)
            end
        else
            GUI.SetRedPointVisable(factionApplyListBtn,false)
        end

        UILayout.SetSameAnchorAndPivot(factionApplyListBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(factionApplyListBtn, "btnTxt", "申请列表", 0, 0, 88, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
        GUI.RegisterUIEvent(factionApplyListBtn, UCE.PointerClick, "FactionUI", "OnFactionApplyListBtnClick")

        local memberListBg = GUI.ImageCreate(factionMemberBg, "memberListBg", "1800400010", 78, 100, false, 1045, 435)
        _gt.BindName(memberListBg, "memberListBg")
        UILayout.SetSameAnchorAndPivot(memberListBg, UILayout.TopLeft)

        local memberListScr = GUI.GroupCreate(memberListBg, "memberListScr", 7, 28,1030, 400)
        UILayout.SetSameAnchorAndPivot(memberListScr, UILayout.TopLeft)
        _gt.BindName(memberListScr, "memberListScr")
        FactionUI.CreatMemberItemList()
        FactionUI.RefreshMemberItem()

        local nameBtn = GUI.ImageCreate(memberListBg, "nameBtn", "1800800120", 4, -9, false, 188, 36)
        UILayout.SetSameAnchorAndPivot(nameBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(nameBtn, "btnTxt", "成员名称", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local levelBtn = GUI.ImageCreate(memberListBg, "levelBtn", "1800800130", 192, -9, false, 102, 36)
        UILayout.SetSameAnchorAndPivot(levelBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(levelBtn, "btnTxt", "等级", 0, 0, 50, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local schoolBtn = GUI.ImageCreate(memberListBg, "schoolBtn", "1800800130", 294, -9, false, 132, 36)
        UILayout.SetSameAnchorAndPivot(schoolBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(schoolBtn, "btnTxt", "门派", 0, 0, 50, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local positionBtn = GUI.ImageCreate(memberListBg, "positionBtn", "1800800130", 426, -9, false, 130, 36)
        UILayout.SetSameAnchorAndPivot(positionBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(positionBtn, "btnTxt", "职位", 0, 0, 50, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local contributionBtn = GUI.ImageCreate(memberListBg, "contributionBtn", "1800800130", 556, -9, false, 222, 36)
        UILayout.SetSameAnchorAndPivot(contributionBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(contributionBtn, "btnTxt", "帮派贡献", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local joinTimeBtn = GUI.ImageCreate(memberListBg, "joinTimeBtn", "1800800130", 778, -9, false, 128, 36)
        UILayout.SetSameAnchorAndPivot(joinTimeBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(joinTimeBtn, "btnTxt", "入帮时间", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local outLineTimeBtn = GUI.ImageCreate(memberListBg, "outLineTimeBtn", "1800800140", 906, -9, false, 135, 36)
        UILayout.SetSameAnchorAndPivot(outLineTimeBtn, UILayout.TopLeft)
        local btnTxt = GUI.CreateStatic(outLineTimeBtn, "btnTxt", "离线时间", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local exitFactionBtn = GUI.ButtonCreate(memberListBg, "exitFactionBtn", "1800602030", 0, 67, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(exitFactionBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(exitFactionBtn, "btnTxt", "退出帮派", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(exitFactionBtn, UCE.PointerClick, "FactionUI", "OnExitFactionBtnClick")

        local impeachmentBtn = GUI.ButtonCreate(memberListBg,"impeachmentBtn","1800602030",160,67,Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(impeachmentBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(impeachmentBtn, "btnTxt", "弹劾帮主", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(impeachmentBtn, UCE.PointerClick, "FactionUI", "OnImpeachmentBtnClick")

        local refreshMemberBtn = GUI.ButtonCreate(memberListBg, "refreshMemberBtn", "1800602030", 320, 67, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(refreshMemberBtn, UILayout.BottomLeft)
        GUI.SetEventCD(refreshMemberBtn,UCE.PointerClick,5)
        local btnTxt = GUI.CreateStatic(refreshMemberBtn, "btnTxt", "刷新列表", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(refreshMemberBtn, UCE.PointerClick, "FactionUI", "OnRefreshMemberBtnClick")

        local searchField = GUI.EditCreate(memberListBg, "searchField", "1800400390", "请输入成员名称", -60, -60, Transition.ColorTint, "system", 304, 37, 10)
        _gt.BindName(searchField, "searchField")
        UILayout.SetSameAnchorAndPivot(searchField, UILayout.TopRight)
        GUI.EditSetLabelAlignment(searchField, TextAnchor.MiddleCenter)
        GUI.EditSetFontSize(searchField, UIDefine.FontSizeS)
        GUI.EditSetTextColor(searchField, UIDefine.BrownColor)
        GUI.SetPlaceholderTxtColor(searchField, UIDefine.GrayColor)
        GUI.EditSetMaxCharNum(searchField, 12)

        local previousPageBtn = GUI.ButtonCreate(memberListBg, "previousMemberPageBtn", "1800402110", 730, 64, Transition.SpriteSwap, "", 120, 45, false)
        _gt.BindName(previousPageBtn, "previousMemberPageBtn")
        UILayout.SetSameAnchorAndPivot(previousPageBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(previousPageBtn, "btnTxt", "上一页", 22, 0, 120, 35)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        GUI.SetColor(btnTxt, UIDefine.BrownColor)
        GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(previousPageBtn, UCE.PointerClick, "FactionUI", "OnMemberPreviousPageBtnClick")

        local pageNumBg = GUI.ImageCreate(memberListBg, "memberPageNumBg", "1800400200", 852, 59, false, 70, 35)
        UILayout.SetSameAnchorAndPivot(pageNumBg, UILayout.BottomLeft)
        local txt = GUI.CreateStatic(pageNumBg, "txt", "1/1", 0, 0, 60, 35)
        _gt.BindName(txt, "memberPageNumTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        GUI.SetColor(txt, UIDefine.WhiteColor)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeSS)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

        local nextPageBtn = GUI.ButtonCreate(memberListBg, "nextMemberPageBtn", "1800402110", 922, 64, Transition.SpriteSwap, "", 120, 45, false)
        _gt.BindName(nextPageBtn, "nextMemberPageBtn")
        UILayout.SetSameAnchorAndPivot(nextPageBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(nextPageBtn, "btnTxt", "下一页", 22, 0, 120, 35)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        GUI.SetColor(btnTxt, UIDefine.BrownColor)
        GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(nextPageBtn, UCE.PointerClick, "FactionUI", "OnMemberNextPageBtnClick")

        local searchBtn = GUI.ButtonCreate(searchField, "searchBtn", "1800802010", -53, 0, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(searchBtn, UILayout.Right)
        GUI.RegisterUIEvent(searchBtn, UCE.PointerClick, "FactionUI", "OnSearchBtnClick_MemberList")
    else
        GUI.SetVisible(factionMemberBg, true)
    end

    FactionUI.OnFactionMemberListBtnClick()
end

function FactionUI.OnSearchBtnClick_MemberList()
    local searchField = _gt.GetUI("searchField")
    if searchField then
        if string.len(searchField.Text)>0 then
            FactionUI.SelectMemberSearchMode = true
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "SearchGuildMember", searchField.Text)
        else
            if FactionUI.SelectMemberSearchMode then
                --刷新回到普通列表
                FactionUI.SelectMemberPageIndex = 0
                FactionUI.SelectMemberSearchMode = false
                FactionUI.FactionInfoUpdate(3)
            end
        end
    end
end

function FactionUI.OnExitFactionBtnClick()
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil then
        if FactionUI.FactionData.self.guild_job == LD.GuildJobEnumToInt(guild_job.guild_job_leader) then
            GlobalUtils.ShowBoxMsg2Btn("提示","帮主退出帮派会导致帮派自动解散，同时将会扣取全部的帮派贡献作为惩罚，是否确认退出？","FactionUI","确认","OnExitFactionYes","取消")
        else
            --非帮主
            GlobalUtils.ShowBoxMsg2Btn("提示","退出帮派将会扣取全部的帮派贡献作为惩罚，是否确认退出","FactionUI","确认","OnExitFactionYes","取消")
        end
    end
end

function FactionUI.OnRefreshMemberBtnClick()
    if FactionUI.SelectMemberSearchMode == false then
        FactionUI.SelectMemberPageIndex = 0
        FactionUI.OnRefreshMemberPageAndBtnState()
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildMembers", 0, ONE_PAGE_NUM)
    end
end

function FactionUI.OnExitFactionYes()
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.guild ~= nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 8, tostring(FactionUI.FactionData.guild.guid))
    end
end

function FactionUI.OnMemberPreviousPageBtnClick()
    FactionUI.SelectMemberPageIndex = math.max(FactionUI.SelectMemberPageIndex - 1, 0)
    FactionUI.OnRefreshMemberPageInfo()
end

function FactionUI.OnRefreshMemberPageAndBtnState()
    FactionUI.SelectMemberPageIndex = math.min(FactionUI.SelectMemberPageIndex, FactionUI.SelectMemberTotalPageCount - 1)

    local pageNumTxt = _gt.GetUI("memberPageNumTxt")
    if pageNumTxt then
        GUI.StaticSetText(pageNumTxt, (FactionUI.SelectMemberPageIndex+1).."/"..FactionUI.SelectMemberTotalPageCount)
    end

    local previousMemberPageBtn = _gt.GetUI("previousMemberPageBtn")
    if previousMemberPageBtn then
        GUI.ButtonSetShowDisable(previousMemberPageBtn, FactionUI.SelectMemberPageIndex~=0)
    end

    local nextMemberPageBtn = _gt.GetUI("nextMemberPageBtn")
    if nextMemberPageBtn then
        GUI.ButtonSetShowDisable(nextMemberPageBtn, FactionUI.SelectMemberPageIndex~=FactionUI.SelectMemberTotalPageCount-1)
    end
end

function FactionUI.OnRefreshMemberPageInfo()
    FactionUI.OnRefreshMemberPageAndBtnState()
    local index = FactionUI.SelectMemberPageIndex * ONE_PAGE_NUM
    local oneFraction = FactionUI.FactionMemberList ~= nil and LD.GetMemberByIndex(index, FactionUI.SelectMemberSearchMode) or nil
    --当前页为空，则请求数据
    if oneFraction == nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildMembers", index, ONE_PAGE_NUM)
    end
    FactionUI.RefreshMemberItem()
end

function FactionUI.OnMemberNextPageBtnClick()
    FactionUI.SelectMemberPageIndex = math.min(FactionUI.SelectMemberPageIndex + 1, FactionUI.SelectMemberTotalPageCount-1)
    FactionUI.OnRefreshMemberPageInfo()
end

function FactionUI.OnFactionMemberListBtnClick()
    FactionUI.SelectMemberTabSubIndex = 1
    FactionUI.OnSwitchMemberSubTab()

    --重新获取帮派成员
    FactionUI.SelectMemberPageIndex = 0
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildMembers", 0, ONE_PAGE_NUM)

    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildApplicants")

end

function FactionUI.OnFactionApplyListBtnClick()
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil then
        local changeBoardPermission=LD.HavePermission(FactionUI.FactionData.self.permission,guild_permission.guild_permission_apply_aduit)
        if changeBoardPermission == false then
            --取消选中
            local factionApplyListBtn = _gt.GetUI("factionApplyListBtn")
            if factionApplyListBtn then
                GUI.CheckBoxSetCheck(factionApplyListBtn, false)
            end
            CL.SendNotify(NOTIFY.ShowBBMsg,"您没有成员审核的权限，无法查看申请列表")
            return
        end
    end

    FactionUI.SelectMemberTabSubIndex = 2
    FactionUI.SelectApplyPageIndex = 0
    FactionUI.OnCreateApplyList()
    FactionUI.OnSwitchMemberSubTab()
    if FactionUI.ApplyLeftTimeTimer == nil then
        FactionUI.ApplyLeftTimeTimer = Timer.New(FactionUI.OnUpdateApplyLeftTime, 60, -1)
        FactionUI.ApplyLeftTimeTimer:Start()
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildApplicants")
end

function FactionUI.OnSwitchMemberSubTab()
    local factionMemberListBtn = _gt.GetUI("factionMemberListBtn")
    if factionMemberListBtn then
        GUI.CheckBoxSetCheck(factionMemberListBtn, FactionUI.SelectMemberTabSubIndex == 1)
    end
    local factionApplyListBtn = _gt.GetUI("factionApplyListBtn")
    if factionApplyListBtn then
        GUI.CheckBoxSetCheck(factionApplyListBtn, FactionUI.SelectMemberTabSubIndex == 2)
    end
    local memberListBg = _gt.GetUI("memberListBg")
    if memberListBg then
        GUI.SetVisible(memberListBg, FactionUI.SelectMemberTabSubIndex == 1)
    end
    local applicationListBg = _gt.GetUI("applicationListBg")
    if applicationListBg then
        GUI.SetVisible(applicationListBg, FactionUI.SelectMemberTabSubIndex == 2)
    end
end

function FactionUI.UnSelectItem(item, bSelect)
    if item then
        if bSelect then
            GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800600230")
        else
            GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800600240")
        end
    end
end

function FactionUI.OnMemberListItemClick_FactionMemberBg(guid)
    local item = GUI.GetByGuid(guid)
    if FactionUI.SelectMemberItem then
        local index = tonumber(GUI.GetData(item, "index"))
        if index ~= FactionUI.SelectMemberItemIndex then
            FactionUI.UnSelectItem(FactionUI.SelectMemberItem, math.fmod(index, 2) == 0)
        end
    end
    local index = tonumber(GUI.GetData(item, "index"))
    FactionUI.SelectMemberItemIndex = index
    FactionUI.SelectMemberItem = item
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800600250")

    --弹出小面板
    FactionUI.ShowMemberInfoPanel()
end

function FactionUI.CreatMemberItemList()
    local sellScroll = _gt.GetUI("memberListScr")
    for i = 0, ONE_PAGE_NUM-1 do
        local memberItem = GUI.ItemCtrlCreate(sellScroll, "memberItem" .. i, "1800600230", 0, 50*i, 1030, 48, false)
        _gt.BindName(memberItem, "memberItem" .. i)
        UILayout.SetSameAnchorAndPivot(memberItem, UILayout.Top)
        GUI.RegisterUIEvent(memberItem, UCE.PointerClick, "FactionUI", "OnMemberListItemClick_FactionMemberBg")
        FactionUI.UnSelectItem(memberItem, math.fmod(i, 2) == 0)

        local txt = GUI.CreateStatic(memberItem, "memberName" .. i, "成员名字", -425, 0, 156, 26, "system", false)
        _gt.BindName(txt, "memberName" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(memberItem, "memberLevel" .. i, "11级", -282, 0, 120, 30)
        _gt.BindName(txt, "memberLevel" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(memberItem, "memberSchool" .. i, "男魔", -165, 0, 120, 30)
        _gt.BindName(txt, "memberSchool" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(memberItem, "memberPosition" .. i, "帮派成员", -34, 0, 120, 30)
        _gt.BindName(txt, "memberPosition" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(memberItem, "memberContribution" .. i, "30000", 144, 0, 220, 30)
        _gt.BindName(txt, "memberContribution" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(memberItem, "memberJoinTime" .. i, "7天", 320, 0, 120, 30)
        _gt.BindName(txt, "memberJoinTime" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(memberItem, "memberOutLineTime" .. i, "2020.12.20", 448, 0, 150, 30)
        _gt.BindName(txt, "memberoutLineTime" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local bannedTalkSp = GUI.ImageCreate(memberItem, "memberBannedTalkSp" .. i, "1800805030", 150, 0)
        _gt.BindName(bannedTalkSp, "memberBannedTalkSp" .. i)
        UILayout.SetSameAnchorAndPivot(bannedTalkSp, UILayout.Left)
    end
end

--刷新成员列表
function FactionUI.RefreshMemberItem()
    if FactionUI.SelectTabIndex == 2 then
        for i = 0, ONE_PAGE_NUM-1 do
            local item = _gt.GetUI("memberItem" .. i)
            local index = i + FactionUI.SelectMemberPageIndex * ONE_PAGE_NUM
            if FactionUI.SelectMemberItemIndex == index then
                FactionUI.SelectMemberItem = item
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800600250")
            else
                FactionUI.UnSelectItem(item, math.fmod(i, 2) == 0)
            end
            GUI.SetData(item, "index", index)
            local memberData = FactionUI.FactionMemberList ~= nil and LD.GetMemberByIndex(index, FactionUI.SelectMemberSearchMode) or nil
        --判断在不在线
            GUI.SetVisible(item, memberData ~= nil and true or false)
            if memberData ~= nil then
                local isOnline = LD.IsMemberState(memberData.status, guild_member_status.guild_member_online)
                local txtColor = isOnline and UIDefine.BrownColor or UIDefine.Gray2Color
                --刷新数据
                local name = _gt.GetUI("memberName"..i)
                GUI.StaticSetText(name, memberData.player_name)
                GUI.SetColor(name, txtColor)
                local level = _gt.GetUI("memberLevel"..i)
                GUI.StaticSetText(level, --[[tostring(memberData.reincarnation).."转"..]]tostring(memberData.level).."级")
                GUI.SetColor(level, txtColor)
                local school = _gt.GetUI("memberSchool"..i)
                --print(memberData.job)
                local job = DB.GetSchool(memberData.job)
                --print(memberData.job)
                GUI.StaticSetText(school,job.Name)
                GUI.SetColor(school, txtColor)
                local position = _gt.GetUI("memberPosition"..i)
                GUI.StaticSetText(position, FactionUI.ParseJobShowName(memberData.guild_job))        --职位
                GUI.SetColor(position, txtColor)
                local contribution = _gt.GetUI("memberContribution"..i)
                GUI.StaticSetText(contribution, tostring(memberData.total_contrb)) --帮贡
                GUI.SetColor(contribution, txtColor)
                local joinTime = _gt.GetUI("memberJoinTime"..i)
                GUI.StaticSetText(joinTime, FactionUI.ParseJoinTime(memberData.join_time))                --入帮时间
                GUI.SetColor(joinTime, txtColor)
                local outLineTime = _gt.GetUI("memberoutLineTime"..i)
                GUI.StaticSetText(outLineTime, isOnline and "在线" or os.date("!%Y-%m-%d",memberData.last_logout_time))--离线时间
                --CDebug.LogError(os.date("!%Y-%m-%d , %H:%M:%S",memberData.last_logout_time).."..."..memberData.player_name)
                GUI.SetColor(outLineTime, txtColor)
                local bannedTalkSp = _gt.GetUI("memberBannedTalkSp"..i)
                GUI.SetVisible(bannedTalkSp, LD.IsMemberState(memberData.status, guild_member_status.guild_member_forbid_talk))
            end
        end
    end
end

function FactionUI.ParseJoinTime(time)
    local nowTime = CL.GetServerTickCount()
    local passTime = nowTime - time
    return math.floor(passTime/86400).."天"
end

function FactionUI.ParseJobShowName(index)
    return JOB_SHOW_NAME[index+1]
end

function FactionUI.OnCreateApplyList()
    local applicationListBg = _gt.GetUI("applicationListBg")
    if applicationListBg == nil then
        local factionMemberBg = _gt.GetUI("factionMemberBg")
        local applicationListBg = GUI.ImageCreate(factionMemberBg, "applicationListBg", "1800400200", 78, 100, false, 1045, 435)
        _gt.BindName(applicationListBg, "applicationListBg")
        UILayout.SetSameAnchorAndPivot(applicationListBg, UILayout.TopLeft)

        local applicationIdBg = GUI.ImageCreate(applicationListBg, "applicationIdBg", "1800800120", 2, -9, false, 184, 36)
        UILayout.SetSameAnchorAndPivot(applicationIdBg, UILayout.TopLeft)
        local txt = GUI.CreateStatic(applicationIdBg, "txt", "申请人ID", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local applicationNameBg = GUI.ImageCreate(applicationListBg, "applicationNameBg", "1800800130", 186, -9, false, 200, 36)
        UILayout.SetSameAnchorAndPivot(applicationNameBg, UILayout.TopLeft)
        local txt = GUI.CreateStatic(applicationNameBg, "txt", "申请人名称", 0, 0, 123, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local applicationLevelBg = GUI.ImageCreate(applicationListBg, "applicationLevelBg", "1800800130", 386, -9, false, 132, 36)
        UILayout.SetSameAnchorAndPivot(applicationLevelBg, UILayout.TopLeft)
        local txt = GUI.CreateStatic(applicationLevelBg, "txt", "等级", 0, 0, 50, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local applicationSchoolBg = GUI.ImageCreate(applicationListBg, "applicationSchoolBg", "1800800130", 518, -9, false, 132, 36)
        UILayout.SetSameAnchorAndPivot(applicationSchoolBg, UILayout.TopLeft)
        local txt = GUI.CreateStatic(applicationSchoolBg, "txt", "角色", 0, 0, 50, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local applicationRecommendBg = GUI.ImageCreate(applicationListBg, "applicationRecommendBg", "1800800130", 650, -9, false, 202, 36)
        UILayout.SetSameAnchorAndPivot(applicationRecommendBg, UILayout.TopLeft)
        local txt = GUI.CreateStatic(applicationRecommendBg, "txt", "帮派贡献", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local applicationLastTimeBg = GUI.ImageCreate(applicationListBg, "applicationLastTimeBg", "1800800140", 852, -9, false, 191, 36)
        UILayout.SetSameAnchorAndPivot(applicationLastTimeBg, UILayout.TopLeft)
        local txt = GUI.CreateStatic(applicationLastTimeBg, "txt", "申请剩余时间", 0, 0, 147, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local applicationListScr = GUI.GroupCreate(applicationListBg, "applicationListScr", 7, 30, 1030, 406)
        _gt.BindName(applicationListScr, "applicationListScr")
        UILayout.SetSameAnchorAndPivot(applicationListScr, UILayout.TopLeft)
        FactionUI.CreatApplyListPool()
        FactionUI.RefreshApplyListScroll()

        local clearApplicationListBtn = GUI.ButtonCreate(applicationListBg, "clearApplicationListBtn", "1800602030", 0, 67, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(clearApplicationListBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(clearApplicationListBtn, "btnTxt", "清空列表", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(clearApplicationListBtn, UCE.PointerClick, "FactionUI", "OnClearApplicationListBtnClick")

        local refreshApplicationListBtn = GUI.ButtonCreate(applicationListBg, "refreshApplicationListBtn", "1800602030", 160, 67, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(refreshApplicationListBtn, UILayout.BottomLeft)
        GUI.SetEventCD(refreshApplicationListBtn,UCE.PointerClick,5)
        local btnTxt = GUI.CreateStatic(refreshApplicationListBtn, "btnTxt", "刷新列表", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(refreshApplicationListBtn, UCE.PointerClick, "FactionUI", "OnRefreshApplicationListBtnClick")

        local refuseApplicationBtn = GUI.ButtonCreate(applicationListBg, "refuseApplicationBtn", "1800602030", -582, 67, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(refuseApplicationBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(refuseApplicationBtn, "btnTxt", "拒绝申请", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(refuseApplicationBtn, UCE.PointerClick, "FactionUI", "OnRefuseApplicationBtnClick")

        local agreeJoinBtn = GUI.ButtonCreate(applicationListBg, "agreeJoinBtn", "1800602030", -421, 67, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(agreeJoinBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(agreeJoinBtn, "btnTxt", "加为帮众", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(agreeJoinBtn, UCE.PointerClick, "FactionUI", "OnAgreeJoinBtnClick")

        --入帮验证
        local joinVertifyBtn = GUI.ImageCreate(applicationListBg, "joinVertifyBtn", "1800607150", -147,-52)
        _gt.BindName(joinVertifyBtn, "joinVertifyBtn")
        GUI.SetIsRaycastTarget(joinVertifyBtn, true)
        joinVertifyBtn:RegisterEvent(UCE.PointerClick)
        GUI.ImageSetGray(joinVertifyBtn, true)
        UILayout.SetSameAnchorAndPivot(joinVertifyBtn, UILayout.TopRight)
        local btnTxt = GUI.CreateStatic(joinVertifyBtn, "btnTxt", "入帮无需验证", -45, 0, 150, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Left)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
        GUI.SetIsRaycastTarget(btnTxt, true)
        btnTxt:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(btnTxt, UCE.PointerClick, "FactionUI", "OnVertifyBtnClick_ApplicationList")
        GUI.RegisterUIEvent(joinVertifyBtn, UCE.PointerClick, "FactionUI", "OnVertifyBtnClick_ApplicationList")

        local previousPageBtn = GUI.ButtonCreate(applicationListBg, "previousApplyPageBtn", "1800402110", 730, 64, Transition.SpriteSwap, "", 120, 45, false)
        _gt.BindName(previousPageBtn, "previousApplyPageBtn")
        UILayout.SetSameAnchorAndPivot(previousPageBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(previousPageBtn, "btnTxt", "上一页", 22, 0, 120, 35)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        GUI.SetColor(btnTxt, UIDefine.BrownColor)
        GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(previousPageBtn, UCE.PointerClick, "FactionUI", "OnApplyPreviousPageBtnClick")

        local pageNumBg = GUI.ImageCreate(applicationListBg, "applyPageNumBg", "1800400200", 852, 59, false, 70, 35)
        UILayout.SetSameAnchorAndPivot(pageNumBg, UILayout.BottomLeft)
        local txt = GUI.CreateStatic(pageNumBg, "txt", "1/1", 0, 0, 60, 35)
        _gt.BindName(txt, "applyPageNumTxt")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        GUI.SetColor(txt, UIDefine.WhiteColor)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeSS)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

        local nextPageBtn = GUI.ButtonCreate(applicationListBg, "nextApplyPageBtn", "1800402110", 922, 64, Transition.SpriteSwap, "", 120, 45, false)
        _gt.BindName(nextPageBtn, "nextApplyPageBtn")
        UILayout.SetSameAnchorAndPivot(nextPageBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(nextPageBtn, "btnTxt", "下一页", 22, 0, 120, 35)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        GUI.SetColor(btnTxt, UIDefine.BrownColor)
        GUI.StaticSetFontSize(btnTxt, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(nextPageBtn, UCE.PointerClick, "FactionUI", "OnApplyNextPageBtnClick")
    else
        GUI.SetVisible(applicationListBg, true)
    end

    local joinVertifyBtn = _gt.GetUI("joinVertifyBtn")
    if joinVertifyBtn then
        local isLeader = FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil and FactionUI.FactionData.self.guild_job == LD.GuildJobEnumToInt(guild_job.guild_job_leader)
        GUI.ImageSetGray(joinVertifyBtn, isLeader==false)

        local config =  FactionUI.FactionData ~= nil and  FactionUI.FactionData.guild ~= nil and FactionUI.FactionData.guild.config or 1
        if config == 0 then
            GUI.ImageSetImageID(joinVertifyBtn, "1800607151")
        else
            GUI.ImageSetImageID(joinVertifyBtn, "1800607150")
        end
    end
end

function FactionUI.OnRefreshApplicationListBtnClick(guid)
    FactionUI.SelectApplyPageIndex = 0
    FactionUI.UpdateApplyPageAndBtnInfo()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 18)
end

function FactionUI.OnVertifyBtnClick_ApplicationList(guid)
    local isLeader = FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil and FactionUI.FactionData.self.guild_job == LD.GuildJobEnumToInt(guild_job.guild_job_leader) and true or false
    if isLeader == false then
        return
    end

    local joinVertifyBtn = _gt.GetUI("joinVertifyBtn")
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.guild ~= nil and joinVertifyBtn then
        local config = FactionUI.FactionData.guild.config
        --目前需要验证，则取反
        if config == 1 then
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 16, "0")
            GUI.ImageSetImageID(joinVertifyBtn, "1800607151")
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 16, "1")
            GUI.ImageSetImageID(joinVertifyBtn, "1800607150")
        end
    end
end

function FactionUI.OnClearApplicationListBtnClick(guid)
    if FactionUI.ApplyList ~= nil and FactionUI.ApplyList.Count > 0 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 17)
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "暂无玩家申请")
    end
end

function FactionUI.OnRefuseApplicationBtnClick(guid)
    if FactionUI.SelectApplyIndex ~= -1 and FactionUI.ApplyList ~= nil and FactionUI.ApplyList[FactionUI.SelectApplyIndex] ~= nil then
        local memberData = FactionUI.ApplyList[FactionUI.SelectApplyIndex]
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 20, tostring(memberData.guid))
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "请选中一名玩家")
    end
end

function FactionUI.OnAgreeJoinBtnClick(guid)
    if FactionUI.SelectApplyIndex ~= -1 and FactionUI.ApplyList ~= nil and FactionUI.ApplyList[FactionUI.SelectApplyIndex] ~= nil then
        local memberData = FactionUI.ApplyList[FactionUI.SelectApplyIndex]
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 21, tostring(memberData.guid))
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "请选中一名玩家")
    end
end

function FactionUI.OnApplyPreviousPageBtnClick()
    FactionUI.SelectApplyPageIndex = math.max(FactionUI.SelectApplyPageIndex - 1, 0)
    FactionUI.UpdateApplyPageAndBtnInfo()
    FactionUI.RefreshApplyListScroll()
end

function FactionUI.UpdateApplyPageAndBtnInfo()
    FactionUI.SelectApplyPageIndex = math.min(FactionUI.SelectApplyPageIndex, FactionUI.SelectApplyTotalPageCount -1)

    local pageNumTxt = _gt.GetUI("applyPageNumTxt")
    GUI.StaticSetText(pageNumTxt, (FactionUI.SelectApplyPageIndex+1).."/"..FactionUI.SelectApplyTotalPageCount)

    local previousApplyPageBtn = _gt.GetUI("previousApplyPageBtn")
    if previousApplyPageBtn then
        GUI.ButtonSetShowDisable(previousApplyPageBtn, FactionUI.SelectApplyPageIndex~=0)
    end

    local nextApplyPageBtn = _gt.GetUI("nextApplyPageBtn")
    if nextApplyPageBtn then
        GUI.ButtonSetShowDisable(nextApplyPageBtn, FactionUI.SelectApplyPageIndex~=FactionUI.SelectApplyTotalPageCount-1)
    end
end

function FactionUI.OnApplyNextPageBtnClick()
    FactionUI.SelectApplyPageIndex = math.min(FactionUI.SelectApplyPageIndex + 1, FactionUI.SelectApplyTotalPageCount-1)
    FactionUI.UpdateApplyPageAndBtnInfo()
    FactionUI.RefreshApplyListScroll()
end

function FactionUI.CreatApplyListPool()
    local applicationListScr = _gt.GetUI("applicationListScr")
    for i = 0, ONE_PAGE_NUM-1 do
        local appItem = GUI.ItemCtrlCreate(applicationListScr, "appItem_" .. i, "1800600230", 0, i*50, 1030, 48, false)
        _gt.BindName(appItem, "appItem_" .. i)
        UILayout.SetSameAnchorAndPivot(appItem, UILayout.Top)
        GUI.RegisterUIEvent(appItem, UCE.PointerClick, "FactionUI", "OnApplicationListItemClick")

        local txt = GUI.CreateStatic(appItem, "appId" .. i, "102", -429, 0, 200, 30)
        _gt.BindName(txt, "appId" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(appItem, "appName" .. i, "成员", -238, 0, 156, 30, "system", false)
        _gt.BindName(txt, "appName" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(appItem, "appLevel" .. i, "11级", -72, 0, 97, 30)
        _gt.BindName(txt, "appLevel" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(appItem, "appSchool" .. i, "男魔", 61, 0, 97, 30)
        _gt.BindName(txt, "appSchool" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(appItem, "appContribution" .. i, "180000", 230, 0, 150, 30)
        _gt.BindName(txt, "appContribution" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(appItem, "appLeftTime" .. i, "22小时50分", 425, 0, 150, 30)
        _gt.BindName(txt, "appLeftTime" .. i)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    end
end

function FactionUI.RefreshApplyListScroll()
    for i = 0, ONE_PAGE_NUM-1 do
        local item = _gt.GetUI("appItem_" .. i)

        local index = i + ONE_PAGE_NUM * FactionUI.SelectApplyPageIndex
        if FactionUI.SelectApplyIndex == index then
            FactionUI.SelectApplyItem = item
            GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800600250")
        else
            GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800600230")
        end
        GUI.SetData(item, "index", index)

        local memberData = FactionUI.ApplyList ~= nil and index < FactionUI.ApplyList.Count and FactionUI.ApplyList[index] or nil
        GUI.SetVisible(item, memberData ~= nil and true or false)
        if memberData ~= nil then
            --刷新数据
            local id = _gt.GetUI("appId"..i)
            --print(FactionUI.ApplyList.Count)
            GUI.StaticSetText(id, tostring(tonumber(memberData.sn)+1000000))
            local name = _gt.GetUI("appName"..i)
            GUI.StaticSetText(name, memberData.name)
            local level = _gt.GetUI("appLevel"..i)
            GUI.StaticSetText(level, --[[tostring(memberData.reincarnation).."转"..]]tostring(memberData.level).."级")
            local school = _gt.GetUI("appSchool"..i)
            local Name = DB.GetRole(memberData.role)
            GUI.StaticSetText(school,Name.RoleName)
            local contribution = _gt.GetUI("appContribution"..i)
            GUI.StaticSetText(contribution, tostring(memberData.guild_contrb))
            local lastTime = _gt.GetUI("appLeftTime"..i)
            GUI.StaticSetText(lastTime, UIDefine.LeftTimeFormat(memberData.last_apply_time))
        end
    end
end

function FactionUI.OnUpdateApplyLeftTime()
    if FactionUI.SelectTabIndex == 2 and FactionUI.SelectMemberTabSubIndex == 2 then
        FactionUI.OnUpdateApplyLeftTimePageList()
    else
        FactionUI.ApplyLeftTimeTimer:Stop()
        FactionUI.ApplyLeftTimeTimer = nil
    end
end

--更新当前页的剩余时间数据
function FactionUI.OnUpdateApplyLeftTimePageList()
    for i = 0, ONE_PAGE_NUM-1 do
        local index = i + ONE_PAGE_NUM * FactionUI.SelectApplyPageIndex

        local memberData = FactionUI.ApplyList ~= nil and index < FactionUI.ApplyList.Count and FactionUI.ApplyList[index] or nil
        if memberData ~= nil then
            local lastTime = _gt.GetUI("appLeftTime"..i)
            GUI.StaticSetText(lastTime, UIDefine.LeftTimeFormat(memberData.last_apply_time))
        end
    end
end

function FactionUI.OnApplicationListItemClick(guid)
    if FactionUI.SelectApplyItem then
        local index = tostring(GUI.GetData(FactionUI.SelectApplyItem, "index"))
        if index == FactionUI.SelectApplyItem then
            return
        end
        GUI.ItemCtrlSetElementValue(FactionUI.SelectApplyItem, eItemIconElement.Border, "1800600230")
    end

    local item = GUI.GetByGuid(guid)
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800600250")

    local index = tonumber(GUI.GetData(item, "index"))
    FactionUI.SelectApplyIndex = index
    FactionUI.SelectApplyItem = item
end

function FactionUI.ShowMemberInfoPanel()
    local memberInfo = FactionUI.FactionMemberList ~= nil and LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode) or nil
    if memberInfo == nil then
        return
    end
    --创建Tips
    local headTips = _gt.GetUI("headTips")
    local factionMemberBg = _gt.GetUI("factionMemberBg")
    if headTips == nil then
        --Tip底板
        headTips = GUI.ItemTipsCreate(factionMemberBg, "headTips", 150, 130,100)
        GUI.SetWidth(headTips, 250)
        _gt.BindName(headTips, "headTips")
        UILayout.SetSameAnchorAndPivot(headTips, UILayout.Top)
        GUI.SetIsRemoveWhenClick(headTips, true)
        --名字
        --[[local ItemName = GUI.GetChild(headTips, "ItemName")
        if ItemName then
                _gt.BindName(ItemName, "tipName")
                GUI.SetPositionX(ItemName, 102)
                GUI.StaticSetText(ItemName, memberInfo.player_name)
        end]]

        --隐藏多余项
        local ItemType = GUI.GetChild(headTips, "ItemType")
        if ItemType then
            GUI.SetVisible(ItemType, false)
        end
        local itemShowLevel = GUI.GetChild(headTips, "itemShowLevel")
        if itemShowLevel then
            GUI.SetVisible(itemShowLevel,false)
        end
        local ItemLevel = GUI.GetChild(headTips, "ItemLevel")
        if ItemLevel then
            GUI.SetVisible(ItemLevel, false)
        end
        local itemLimit = GUI.GetChild(headTips, "itemLimit")
        if itemLimit then
            GUI.SetVisible(itemLimit, false)
        end

        local roleConfig = DB.GetRole(memberInfo.role)
        --头像
        local ItemIcon = GUI.TipsGetItemIcon(headTips)
        _gt.BindName(ItemIcon,"tipFaceBack")
        GUI.SetPositionX(ItemIcon, 15)
        GUI.SetPositionY(ItemIcon, 15)
        if roleConfig then
            GUI.ItemCtrlSetElementValue(ItemIcon, eItemIconElement.Icon, "1800499999")
        end
        local _Face = HeadIcon.Create(ItemIcon, "Face", tostring(roleConfig.Head),  0, 0, 70, 70)
        _gt.BindName(_Face, "tipFace")
        UILayout.SetSameAnchorAndPivot(_Face, UILayout.Center)
        HeadIcon.BindRoleGuid(_Face)
        HeadIcon.BindRoleVipLv(_Face, memberInfo.vip)

        local level = GUI.CreateStatic(ItemIcon,"level",memberInfo.level,25,28,50,50)
        UILayout.SetSameAnchorAndPivot(level, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(level, UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        GUI.SetOutLine_Color(level, UIDefine.BlackColor)
        GUI.SetOutLine_Distance(level, 1)
        GUI.SetIsOutLine(level, true)
    
        --门派和图标
        --[[local txt = GUI.CreateStatic(headTips, "tipSchool", UIDefine.GetRoleRace(memberInfo.role), 95, 63, 150, 30)
        _gt.BindName(txt, "tipSchool")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local schoolFlag = GUI.ImageCreate(headTips, "tipSchoolFlag", "1800102060", 0, 56, false, 40, 40)
        _gt.BindName(schoolFlag, "tipSchoolFlag")
        if roleConfig then
            GUI.ImageSetImageID(schoolFlag, tostring(roleConfig.Icon))
        end
        UILayout.SetSameAnchorAndPivot(schoolFlag, UILayout.TopLeft)]]

        local schoolFlag = GUI.ImageCreate(headTips, "tipSchoolFlag", "1800102060", 0, 56, false, 40, 40)

        local ItemName = GUI.GetChild(headTips, "ItemName")
        if ItemName then
            GUI.StaticSetText(ItemName, memberInfo.player_name)
            GUI.SetPositionX(ItemName, 102)
        end
        local tipSchool = _gt.GetUI("tipSchool")
        if tipSchool then
            GUI.StaticSetText(tipSchool, UIDefine.GetRoleRace(memberInfo.role))
        end
        local roleConfig = DB.GetRole(memberInfo.role)
        local School = SchoolIcon[tonumber(memberInfo.job)]
        if roleConfig then
            if schoolFlag then
                GUI.ImageSetImageID(schoolFlag, School)
            end
            local tipFace = _gt.GetUI("tipFace")
            if tipFace then
                --头像
                GUI.ImageSetImageID(tipFace, roleConfig.Head)
                --vip等级
                HeadIcon.BindRoleVipLv(tipFace, memberInfo.vip)
            end
            local tipSchool = _gt.GetUI("tipSchool")
            if tipSchool then
                GUI.StaticSetText(tipSchool, UIDefine.GetRoleRace(memberInfo.role))
            end
        end
    end
    --[[local talk = GUI.CreateStatic(headTips,"talkbtn","聊天",0,100,50,50)
    _gt.BindName(talk,"talkbtn")
    UILayout.SetSameAnchorAndPivot(talk, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(talk, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)]]

    local btnCount = 0
    local baseOffsetY = 103
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil and memberInfo.player_guid ~= FactionUI.FactionData.self.player_guid then


            local chatBtn = GUI.ButtonCreate(headTips, "chatBtn", "1800202360", 0, baseOffsetY + btnCount * 50, Transition.SpriteSwap, "", 232, 50, false)
            local btnTxt = GUI.CreateStatic(chatBtn, "btnTxt", "聊天", 23, 0, 97, 30)
            UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
            UILayout.SetSameAnchorAndPivot(chatBtn, UILayout.Top)
            GUI.RegisterUIEvent(chatBtn, UCE.PointerClick, "FactionUI", "OnChatBtn_HeadTipsClick")
            GUI.AddWhiteName(headTips, GUI.GetGuid(chatBtn))
            btnCount = btnCount + 1

            local friendBtn = GUI.ButtonCreate(headTips, "friendBtn", "1800202360", 0, baseOffsetY + btnCount * 50, Transition.SpriteSwap, "", 232, 50, false)
            local btnTxt = GUI.CreateStatic(friendBtn, "btnTxt", "加为好友", 0, 0, 97, 30)
            UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
            UILayout.SetSameAnchorAndPivot(friendBtn, UILayout.Top)
            GUI.RegisterUIEvent(friendBtn, UCE.PointerClick, "FactionUI", "OnFriendBtn_HeadTipsClick")
            GUI.AddWhiteName(headTips, GUI.GetGuid(friendBtn))
            btnCount = btnCount + 1


        local teamBtn = GUI.ButtonCreate(headTips, "teamBtn", "1800202360", 0, baseOffsetY + btnCount * 50, Transition.SpriteSwap, "", 232, 50, false)
        local btnTxt = GUI.CreateStatic(teamBtn, "btnTxt", "邀请组队", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
        UILayout.SetSameAnchorAndPivot(teamBtn, UILayout.Top)
        GUI.RegisterUIEvent(teamBtn, UCE.PointerClick, "FactionUI", "OnTeamBtn_HeadTipsClick")
        GUI.AddWhiteName(headTips, GUI.GetGuid(teamBtn))
        btnCount = btnCount + 1

        --更改职位
        local permission=LD.HavePermission(FactionUI.FactionData.self.permission,guild_permission.guild_permission_appoint_job)
        if permission then
            local changePosBtn = GUI.ButtonCreate(headTips, "changePosBtn", "1800202360", 0, baseOffsetY + btnCount * 50, Transition.None, "", 232, 50, false)
            _gt.BindName(changePosBtn, "changePosBtn")
            local btnSelectImage = GUI.ImageCreate(changePosBtn, "btnSelectImage", "1800202362", 0, 0, false, 232, 50)
            _gt.BindName(btnSelectImage, "btnSelectImage")
            UILayout.SetSameAnchorAndPivot(btnSelectImage, UILayout.Center)
            GUI.SetVisible(btnSelectImage, false)
            local btnTxt = GUI.CreateStatic(changePosBtn, "btnTxt", "更改职位", 0, 0, 97, 30)
            UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
            UILayout.SetSameAnchorAndPivot(changePosBtn, UILayout.Top)
            GUI.AddWhiteName(headTips, GUI.GetGuid(changePosBtn))
            GUI.RegisterUIEvent(changePosBtn, UCE.PointerClick, "FactionUI", "OnChangePosBtn_HeadTipsClick")
            btnCount = btnCount + 1

            --职位列表背景
            local jobListBack = GUI.ImageCreate(headTips, "jobListBack", "1800400290", 244, 180, false, 163, 50)
            _gt.BindName(jobListBack, "jobListBack")
            UILayout.SetSameAnchorAndPivot(jobListBack, UILayout.TopLeft)
            GUI.SetVisible(jobListBack, false)
        end

        --帮派禁言
        permission=LD.HavePermission(FactionUI.FactionData.self.permission,guild_permission.guild_permission_forbid_talk)
        if permission then
            local member = LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode)
            if member ~= nil and LD.IsMemberState(member.status, guild_member_status.guild_member_forbid_talk) == false then
                local bannedTalkBtn = GUI.ButtonCreate(headTips, "bannedTalkBtn", "1800202360", 0, baseOffsetY + btnCount * 50, Transition.SpriteSwap, "", 232, 50, false)
                local btnTxt = GUI.CreateStatic(bannedTalkBtn, "btnTxt", "帮派禁言", 0, 0, 97, 30)
                UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
                UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
                UILayout.SetSameAnchorAndPivot(bannedTalkBtn, UILayout.Top)
                GUI.RegisterUIEvent(bannedTalkBtn, UCE.PointerClick, "FactionUI", "OnBannedTalkBtn_HeadTipsClick")
                GUI.AddWhiteName(headTips, GUI.GetGuid(bannedTalkBtn))
                btnCount = btnCount + 1
            else
                local removeBannedTalkBtn = GUI.ButtonCreate(headTips, "removeBannedTalkBtn", "1800202360", 0, baseOffsetY + btnCount * 50, Transition.SpriteSwap, "", 232, 50, false)
                local btnTxt = GUI.CreateStatic(removeBannedTalkBtn, "btnTxt", "解除禁言", 0, 0, 97, 30)
                UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
                UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
                UILayout.SetSameAnchorAndPivot(removeBannedTalkBtn, UILayout.Top)
                GUI.RegisterUIEvent(removeBannedTalkBtn, UCE.PointerClick, "FactionUI", "OnRemoveBannedTalkBtn_HeadTipsClick")
                GUI.AddWhiteName(headTips, GUI.GetGuid(removeBannedTalkBtn))
                btnCount = btnCount + 1
            end
        end

        --开除成员
        permission=LD.HavePermission(FactionUI.FactionData.self.permission,guild_permission.guild_permission_expel_member)
        if permission then
            local removePlayerBtn = GUI.ButtonCreate(headTips, "removePlayerBtn", "1800202360", 0, baseOffsetY + btnCount * 50, Transition.SpriteSwap, "", 232, 50, false)
            local btnTxt = GUI.CreateStatic(removePlayerBtn, "btnTxt", "开除成员", 0, 0, 97, 30)
            UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
            UILayout.SetSameAnchorAndPivot(removePlayerBtn, UILayout.Top)
            GUI.RegisterUIEvent(removePlayerBtn, UCE.PointerClick, "FactionUI", "OnRemovePlayerBtn_HeadTipsClick")
            GUI.AddWhiteName(headTips, GUI.GetGuid(removePlayerBtn))
            btnCount = btnCount + 1
        end
    end

    GUI.SetHeight(headTips, baseOffsetY + btnCount * 50 + 5)
end

function FactionUI.EnableShowMemberTip(show)
    local headTips = _gt.GetUI("headTips")
    if headTips then
        GUI.SetVisible(headTips, show)
    end
end

function FactionUI.OnChatBtn_HeadTipsClick(guid)
    FactionUI.ShowJob(false)
    FactionUI.OnExit()
    local member = LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode)
    if member ~= nil then
        CL.SendNotify(NOTIFY.SubmitForm,"FormContact","AddStrangerList",tostring(member.player_guid))
        GUI.OpenWnd("FriendUI",tostring(member.player_guid).."#FriendShipRecommendData")
    end
end

function FactionUI.OnFriendBtn_HeadTipsClick()
    FactionUI.ShowJob(false)
    FactionUI.EnableShowMemberTip(false)
    local member = LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode)
    if member ~= nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyFriend", member.player_guid)
        CL.SendNotify(NOTIFY.ShowBBMsg, "已发送好友请求")
    end
end

function FactionUI.OnTeamBtn_HeadTipsClick()
    FactionUI.ShowJob(false)

    --邀请组队
    local member = LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode)
    if member ~= nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "InviteJoin", member.player_guid)
        --CL.SendNotify(NOTIFY.ShowBBMsg,"邀请信息已发送")
    end

    --关闭头像框
    FactionUI.EnableShowMemberTip(false)
end

function FactionUI.OnChangePosBtn_HeadTipsClick()
    local btnSelectImage = _gt.GetUI("btnSelectImage")
    if btnSelectImage then
        FactionUI.ShowJob(GUI.GetVisible(btnSelectImage) == false)
    end
end

function FactionUI.OnBannedTalkBtn_HeadTipsClick()
    FactionUI.ShowJob(false)
    FactionUI.EnableShowMemberTip(false)
    local member = LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode)
    if member ~= nil then
        --禁言
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 11, "1", tostring(member.player_guid))
    end
end

function FactionUI.OnRemoveBannedTalkBtn_HeadTipsClick()
    FactionUI.ShowJob(false)
    FactionUI.EnableShowMemberTip(false)
    local member = LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode)
    if member ~= nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 11, "0", tostring(member.player_guid))
    end
end

function FactionUI.OnRemovePlayerBtn_HeadTipsClick()
    FactionUI.ShowJob(false)
    FactionUI.EnableShowMemberTip(false)
    local member = LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode)
    if member ~= nil then
        GlobalUtils.ShowBoxMsg2Btn("提示","你是否要将"..tostring(member.player_name).."移出帮派","FactionUI","确认","AgreeRemovePlayer","取消", nil, nil, index)
    end
end

function FactionUI.AgreeRemovePlayer()
    local member = LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode)
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 10, tostring(member.player_guid))
end

function FactionUI.OnChangeJobLeader(param)
    local vals = string.split(param, ",")
    if #vals == 2 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 12, vals[1], vals[2])
    end
end

function FactionUI.OnBtnSetJob(guid)
    local member = LD.GetMemberByIndex(FactionUI.SelectMemberItemIndex, FactionUI.SelectMemberSearchMode)
    local btn = GUI.GetByGuid(guid)
    if btn and member then
        local jobIndex = tonumber(GUI.GetData(btn, "jobIndex"))
        if jobIndex == LD.GuildJobEnumToInt(guild_job.guild_job_leader) then
            --变更帮主：二次确认
            GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", "帮主转以后将变为普通帮众，是否要转移帮主给"..member.player_name.."？", "FactionUI", "确定", "OnChangeJobLeader", "取消", nil, tostring(jobIndex)..","..tostring(member.player_guid))
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 12, tostring(jobIndex), tostring(member.player_guid))
        end
    end
    local headTips = _gt.GetUI("headTips")
    if headTips then
        GUI.Destroy(headTips)
    end
end

function FactionUI.ShowJob(show)
    local btnSelectImage = _gt.GetUI("btnSelectImage")
    if btnSelectImage then
        GUI.SetVisible(btnSelectImage, show)
    end
    local jobListBack = _gt.GetUI("jobListBack")
    if jobListBack then
        GUI.SetVisible(jobListBack, show)
        if show == false then
            return
        end
        local ownJobTypeList = {}
        local count = #jobList

        --取消之前所有项
        for i = 1, count do
            local btn = _gt.GetUI(jobList[i][2])
            if btn then
                GUI.SetVisible(btn, false)
            end
        end

        --根据职位权限动态添加
        local startJobIndex = 1
        if FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil then
            local max = LD.GuildJobEnumToInt(guild_job.guild_job_max)
            startJobIndex = max - FactionUI.FactionData.self.guild_job
        end
        for i = startJobIndex, count do
            table.insert(ownJobTypeList, jobList[i])
        end

        --增加现有项
        local jobTypeCount = #ownJobTypeList
        local headTips = _gt.GetUI("headTips")
        for i = 1, jobTypeCount do
            local btn = _gt.GetUI(ownJobTypeList[i][2])
            if btn then
                GUI.SetVisible(btn, true)
                GUI.SetPositionY(btn, i * 50)
            else
                if headTips then
                    btn = GUI.ButtonCreate(jobListBack, ownJobTypeList[i][2], "1800202360", 0, (i - 1) * 50 + 5, Transition.ColorTint, "", 155, 50, false)
                    GUI.SetData(btn, "jobIndex", ownJobTypeList[i][4])
                    UILayout.SetSameAnchorAndPivot(btn, UILayout.Top)
                    GUI.RegisterUIEvent(btn, UCE.PointerClick, "FactionUI", ownJobTypeList[i][3])
                    GUI.AddWhiteName(headTips, GUI.GetGuid(btn))
                    local btnTxt = GUI.CreateStatic(btn, "btnTxt", ownJobTypeList[i][1], 0, 0, 155, 30)
                    UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
                    UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
                end
            end
        end
        GUI.SetHeight(jobListBack, jobTypeCount * 50 + 10)
        GUI.SetPositionY(jobListBack, -3 + (9 - jobTypeCount) * 25)
    end
end

function FactionUI.OnChangeBoardBtnClick(guid)
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil then
        local changeBoardPermission=LD.HavePermission(FactionUI.FactionData.self.permission,guild_permission.guild_permission_declaration)
        if changeBoardPermission == false then
            CL.SendNotify(NOTIFY.ShowBBMsg,"您没有更改帮派宣言的权限")
            return
        end
    end

    local changeBoardCover = _gt.GetUI("changeBoardCover")
    if changeBoardCover == nil then
        local panel = GUI.GetWnd("FactionUI")
        changeBoardCover = GUI.ImageCreate(panel, "changeBoardCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        _gt.BindName(changeBoardCover, "changeBoardCover")
        UILayout.SetSameAnchorAndPivot(changeBoardCover, UILayout.Center)
        GUI.SetIsRaycastTarget(changeBoardCover, true)

        local changeBoardBg = GUI.ImageCreate(changeBoardCover, "changeBoardBg", "1800400300", 0, 0, false, 465, 360)
        UILayout.SetSameAnchorAndPivot(changeBoardBg, UILayout.Center)

        local closeBtn = GUI.ButtonCreate(changeBoardBg, "closeBtn", "1800302120", 0, 0, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_ChangeBoardBg")

        local titleBg = GUI.ImageCreate(changeBoardBg, "titleBg", "1800001140", 0, 15, false, 265, 33)
        UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)
        local txt = GUI.CreateStatic(titleBg, "txt", "", 0, 0, 97, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.WhiteColor, nil)
        GUI.StaticSetText(txt, "帮派宣言")

        local inputNameTips = GUI.CreateStatic(changeBoardBg, "inputNameTips", "", 25, 75, 210, 32)
        UILayout.SetSameAnchorAndPivot(inputNameTips, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(inputNameTips, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        GUI.StaticSetText(inputNameTips, "请输入帮派宣言")

        local inputField = GUI.EditCreate(changeBoardBg, "inputField", "1800400390", "请输入帮派宣言", 25, 120, Transition.ColorTint, "system", 415, 145, 10, 10)
        _gt.BindName(inputField, "changeBoardInputField")
        UILayout.SetSameAnchorAndPivot(inputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(inputField, TextAnchor.UpperLeft)
        GUI.EditSetFontSize(inputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(inputField, UIDefine.BrownColor)
        GUI.EditSetMultiLineEdit(inputField, LineType.MultiLineSubmit)
        GUI.SetPlaceholderTxtColor(inputField, UIDefine.GrayColor)
        GUI.EditSetMaxCharNum(inputField, 100)

        local concelBtn = GUI.ButtonCreate(changeBoardBg, "concelBtn", "1800602030", 25, -25, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(concelBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(concelBtn, "btnTxt", "取消", 0, 0, 52, 32)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_ChangeBoardBg")

        local confirmBtn = GUI.ButtonCreate(changeBoardBg, "confirmBtn", "1800602030", -25, -25, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(confirmBtn, "btnTxt", "确定", 0, 0, 52, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "FactionUI", "OnConfirmBtnClick_ChangeBoardBg")
    else
        GUI.SetVisible(changeBoardCover, true)
    end
end

function FactionUI.OnConfirmBtnClick_ChangeBoardBg(guid)
    local changeBoardInputField = _gt.GetUI("changeBoardInputField")
    if changeBoardInputField then
        if CL.IsHaveForbiddenWord(changeBoardInputField.Text) then
            CL.SendNotify(NOTIFY.ShowBBMsg, "帮派宣言含有不合法字符，请重新输入")
            return
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 2, changeBoardInputField.Text)
    end
end

function FactionUI.OnCloseBtnClick_ChangeBoardBg(guid)
    local changeBoardInputField = _gt.GetUI("changeBoardInputField")
    if changeBoardInputField then
        GUI.EditSetTextM(changeBoardInputField, "")
    end
    local changeBoardCover = GUI.Get("FactionUI/changeBoardCover")
    GUI.SetVisible(changeBoardCover, false)
end

function FactionUI.OnChangeNameBtnClick(guid)
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil then
        if FactionUI.FactionData.self.guild_job ~= LD.GuildJobEnumToInt(guild_job.guild_job_leader) then
            CL.SendNotify(NOTIFY.ShowBBMsg,"只有帮主才能更改帮派名称")
            return
        end
    end

    local changeNameCover = _gt.GetUI("changeNameCover")
    if changeNameCover == nil then
        local panel = GUI.GetWnd("FactionUI")
        changeNameCover = GUI.ImageCreate(panel, "changeNameCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        _gt.BindName(changeNameCover, "changeNameCover")
        UILayout.SetSameAnchorAndPivot(changeNameCover, UILayout.Center)
        GUI.SetIsRaycastTarget(changeNameCover, true)

        local changeNameBg = GUI.ImageCreate(changeNameCover, "changeNameBg", "1800400300", 0, 0, false, 465, 360)
        UILayout.SetSameAnchorAndPivot(changeNameBg, UILayout.Center)

        local closeBtn = GUI.ButtonCreate(changeNameBg, "closeBtn", "1800302120", 0, 0, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_ChangeNameBg")

        local titleBg = GUI.ImageCreate(changeNameBg, "titleBg", "1800001140", 0, 15, false, 265, 33)
        UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)
        local txt = GUI.CreateStatic(titleBg, "txt", "修改帮派名称", 0, 0, 150, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.WhiteColor, nil)

        local inputNameTips = GUI.CreateStatic(changeNameBg, "inputNameTips", "请输入新的帮派名称", 25, 75, 250, 32)
        UILayout.SetSameAnchorAndPivot(inputNameTips, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(inputNameTips, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)

        local inputField = GUI.EditCreate(changeNameBg, "inputField", "1800400390", "请输入帮派名称", 25, 125, Transition.ColorTint, "system", 415, 44, 10)
        _gt.BindName(inputField, "factionNameInputField")
        UILayout.SetSameAnchorAndPivot(inputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(inputField, TextAnchor.MiddleCenter)
        GUI.EditSetFontSize(inputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(inputField, UIDefine.BrownColor)
        GUI.SetPlaceholderTxtColor(inputField, UIDefine.GrayColor)
        GUI.EditSetMaxCharNum(inputField, 10)

        local costCoinTips = GUI.CreateStatic(changeNameBg, "costCoinTips", "消耗银币", 25, 185, 150, 31)
        UILayout.SetSameAnchorAndPivot(costCoinTips, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(costCoinTips, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        local costCoinBg = GUI.ImageCreate(costCoinTips, "costCoinBg", "1800700010", 165, 0, false, 250, 33)
        UILayout.SetSameAnchorAndPivot(costCoinBg, UILayout.Left)
        local costCoinIcon = GUI.ImageCreate(costCoinBg, "costCoinIcon", "1800408280", 0, 0, false, 33, 33)
        UILayout.SetSameAnchorAndPivot(costCoinIcon, UILayout.Left)
        local txt = GUI.CreateStatic(costCoinBg, "txt", FactionUI.ChangeNameBindGold, 0, 0, 250, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local costFactionMoneyTips = GUI.CreateStatic(changeNameBg, "costFactionMoneyTips", "消耗帮派资金", 25, 235, 200, 31)
        UILayout.SetSameAnchorAndPivot(costFactionMoneyTips, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(costFactionMoneyTips, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        local costFactionMoneyBg = GUI.ImageCreate(costFactionMoneyTips, "costFactionMoneyBg", "1800700010", 165, 0, false, 250, 33)
        UILayout.SetSameAnchorAndPivot(costFactionMoneyBg, UILayout.Left)
        local costFactionMoneyIcon = GUI.ImageCreate(costFactionMoneyBg, "costFactionMoneyIcon", "1800408340", 0, 0, false, 33, 33)
        UILayout.SetSameAnchorAndPivot(costFactionMoneyIcon, UILayout.Left)
        local txt = GUI.CreateStatic(costFactionMoneyBg, "txt", FactionUI.ChangeNameGuildFund, 0, 0, 250, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local concelBtn = GUI.ButtonCreate(changeNameBg, "concelBtn", "1800602030", 25, -25, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(concelBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(concelBtn, "btnTxt", "取消", 0, 0, 52, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_ChangeNameBg")

        local confirmBtn = GUI.ButtonCreate(changeNameBg, "confirmBtn", "1800602030", -25, -25, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(confirmBtn, "btnTxt", "修改名称", 0, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "FactionUI", "OnConfirmBtnClick_ChangeNameBg")
    else
        GUI.SetVisible(changeNameCover, true)
    end
end

function FactionUI.OnConfirmBtnClick_ChangeNameBg(guid)
    local factionNameInputField = _gt.GetUI("factionNameInputField")
    if factionNameInputField then
        if string.len(factionNameInputField.Text) < 4 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "帮派名称最少2个汉字，最多5个汉字")
            return
        end
        if CL.IsHaveForbiddenWord(factionNameInputField.Text) then
            CL.SendNotify(NOTIFY.ShowBBMsg, "帮派名称含有不合法字符，请重新输入")
            return
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 1, factionNameInputField.Text)
    end
end

function FactionUI.OnCloseBtnClick_ChangeNameBg(guid)
    local factionNameInputField = _gt.GetUI("factionNameInputField")
    if factionNameInputField then
        GUI.EditSetTextM(factionNameInputField, "")
    end
    local changeNameCover = GUI.Get("FactionUI/changeNameCover")
    GUI.SetVisible(changeNameCover, false)
end
function FactionUI.CreateSmallMenuBgFree(name, panel, title, w, h)
    local panelCover = GUI.ImageCreate(panel, name, "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    panelCover:RegisterEvent(UCE.PointerClick)

    local panelBg = GUI.ImageCreate(panelCover, "panelBg", "1800600182", 0, 0, false, w, h)
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)
    --panelBg:RegisterEvent(UCE.PointerClick)

    local topBarLeft = GUI.ImageCreate(panelBg, "topBarLeft", "1800600180", w / 4, 21, false, w / 2 + 1, 54)
    UILayout.SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

    local topBarRight = GUI.ImageCreate(panelBg, "topBarRight", "1800600181", -w / 4, 21, false, w / 2 + 1, 54)
    UILayout.SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

    local topBarCenter = GUI.ImageCreate(panelBg, "topBarCenter", "1800600190", 0, 23, false, 267, 50)
    UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

    local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800302120", 0, -3, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    local tipLabel = GUI.CreateStatic(panelBg, "tipLabel", title, 0, 23, 150, 45)
    UILayout.StaticSetFontSizeColorAlignment(tipLabel, UIDefine.FontSizeXL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)

    return panelCover
end

function FactionUI.OnContributeBtnClick(guid)
    local contributeBtn = _gt.GetUI("contributeBtn")
    FactionUI.contributeBtnRedPoint = false
    GUI.SetRedPointVisable(contributeBtn,false)
    GlobalProcessing.on_draw_redpoint("factionBtn", false)
    local factionContributePanel = _gt.GetUI("factionContributePanel")
    if factionContributePanel == nil then
        local panel = GUI.GetWnd("FactionUI")
        factionContributePanel = FactionUI.CreateSmallMenuBgFree("factionContributePanel", panel, "帮派捐献", 725, 620)
        _gt.BindName(factionContributePanel, "factionContributePanel")
        local closeBtn = GUI.Get("FactionUI/factionContributePanel/panelBg/closeBtn")
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_FactionContributePanel")

        local panelBg = GUI.Get("FactionUI/factionContributePanel/panelBg")
        local goldTips = GUI.CreateStatic(panelBg, "goldTips", "我的银元", 22, 60, 97, 30)
        UILayout.SetSameAnchorAndPivot(goldTips, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(goldTips, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local goldBg = GUI.ImageCreate(goldTips, "goldBg", "1800700010", 112, 0, false, 202, 34)
        UILayout.SetSameAnchorAndPivot(goldBg, UILayout.Left)
        local goldIcon = GUI.ImageCreate(goldBg, "goldIcon", UIDefine.AttrIcon[RoleAttr.RoleAttrBindIngot], 0, -1, false, 34, 34)
        UILayout.SetSameAnchorAndPivot(goldIcon, UILayout.Left)
        local txt = GUI.CreateStatic(goldBg, "txt", "5500", 0, 0, 250, 30)
        _gt.BindName(txt, "mySelfBindGold")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local myContributionTips = GUI.CreateStatic(panelBg, "myContributionTips", "我的帮贡", -235, 60, 97, 30)
        UILayout.SetSameAnchorAndPivot(myContributionTips, UILayout.TopRight)
        UILayout.StaticSetFontSizeColorAlignment(myContributionTips, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local contributionBg = GUI.ImageCreate(myContributionTips, "contributionBg", "1800700010", -112, 0, false, 202, 34)
        UILayout.SetSameAnchorAndPivot(contributionBg, UILayout.Left)
        local contributionIcon = GUI.ImageCreate(contributionBg, "contributionIcon", "1800408290", 0, -1, false, 34, 34)
        UILayout.SetSameAnchorAndPivot(contributionIcon, UILayout.Left)
        local txt = GUI.CreateStatic(contributionBg, "txt", "10000", 0, 0, 250, 30)
        _gt.BindName(txt, "mySelfContribute")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

        local strRule =  "1.捐献银元可获得帮贡奖励，同时帮派会获得一定的帮派资金。\n" ..
                         "2.当脱离帮派时，帮贡将被清空。\n" ..
                         "3.在本帮内的历史帮贡和单周帮贡会影响下周分红数额。\n"
                        --"4.帮派贡献每减少<color=#ff3c3c>"..FACTION_DONATE_COST0.."点</color>，将会随机扣除<color=#ff3c3c>"..FACTION_DONATE_COST1.."点</color>小成修炼，所以请及时补充帮派贡献。\n" ..
                         --"4.本周捐献进度："..FactionUI.DonateConfig.WeekValue.."银元/200000银元。\n"
                        --"6.无帮派状态时，小成修炼不再生效，帮派贡献也不会每日扣除。"

        local contributeRuleBg = GUI.ImageCreate(panelBg, "contributeRuleBg", "1800800070", 17, 107, false, 690, 263)
        UILayout.SetSameAnchorAndPivot(contributeRuleBg, UILayout.TopLeft)
        local txt = GUI.CreateStatic(contributeRuleBg, "txt", strRule, 75, -50, 620, 250, "system", true)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
        local txt = GUI.CreateStatic(contributeRuleBg, "txtRule2", "4.本周捐献进度："..FactionUI.DonateConfig.WeekValue.."银元/"..FactionUI.DonateConfig.WeekMax.."银元。\n", 75, -10, 620, 50, "system", true)
        _gt.BindName(txt,"txtRule2")
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, nil)

        local txt2 = GUI.CreateStatic(contributeRuleBg, "txt2", "捐\n\n献\n\n规\n\n则", -302, 0, 50, 237)
        UILayout.SetSameAnchorAndPivot(txt2, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt2, UIDefine.FontSizeXL, UIDefine.Yellow4Color, nil)

        local bottomBg = GUI.ImageCreate(panelBg, "bottomBg", "1800400200", 17, -20, false, 680, 218)
        UILayout.SetSameAnchorAndPivot(bottomBg, UILayout.BottomLeft)

        local cutline2 = GUI.ImageCreate(bottomBg, "cutline2", "1800800090", 0, -106, false, 674, 2)
        UILayout.SetSameAnchorAndPivot(cutline2, UILayout.Top)

        local horizontalTips1 = GUI.CreateStatic(bottomBg, "horizontalTips1", "捐\n献", 17, -32, 30, 56)
        UILayout.SetSameAnchorAndPivot(horizontalTips1, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(horizontalTips1, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local globalConfig = DB.GetGlobal(1)
        if globalConfig then
            Donate_SilverToContribution = globalConfig.SilverToContribution
            Donate_SilverToFund = globalConfig.SilverToFund
            local donateBtn = GUI.ButtonCreate(bottomBg, "donateBtn1", "1800402110", 205, -37, Transition.SpriteSwap, "", 102, 45, false)
            _gt.BindName(donateBtn, "donateBtn1")
            UILayout.SetSameAnchorAndPivot(donateBtn, UILayout.TopLeft)
            local btnTxt = GUI.CreateStatic(donateBtn, "btnTxt", UIDefine.ExchangeMoneyToStr(FactionUI.DonateConfig.Config[1].MoneyValue , 0), 0, 0, 120, 30)
            GUI.StaticSetAlignment(btnTxt, TextAnchor.MiddleCenter)
            UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
            GUI.SetData(donateBtn, "Money", FactionUI.DonateConfig.Config[1].MoneyValue)
            GUI.SetData(donateBtn, "Index", "1")
            GUI.RegisterUIEvent(donateBtn, UCE.PointerClick, "FactionUI", "OnContributeMoneyBtnClick")

            local donateBtn = GUI.ButtonCreate(bottomBg, "donateBtn2", "1800402110", 325, -37, Transition.SpriteSwap, "", 102, 45, false)
            _gt.BindName(donateBtn, "donateBtn2")
            UILayout.SetSameAnchorAndPivot(donateBtn, UILayout.TopLeft)
            local btnTxt = GUI.CreateStatic(donateBtn, "btnTxt", UIDefine.ExchangeMoneyToStr(FactionUI.DonateConfig.Config[2].MoneyValue, 0), 0, 0, 120, 30)
            GUI.StaticSetAlignment(btnTxt, TextAnchor.MiddleCenter)
            UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
            GUI.SetData(donateBtn, "Money", FactionUI.DonateConfig.Config[2].MoneyValue)
            GUI.SetData(donateBtn, "Index", "2")
            GUI.RegisterUIEvent(donateBtn, UCE.PointerClick, "FactionUI", "OnContributeMoneyBtnClick")

            local donateBtn = GUI.ButtonCreate(bottomBg, "donateBtn3", "1800402110", 445, -37, Transition.SpriteSwap, "", 102, 45, false)
            _gt.BindName(donateBtn, "donateBtn3")
            UILayout.SetSameAnchorAndPivot(donateBtn, UILayout.TopLeft)
            local btnTxt = GUI.CreateStatic(donateBtn, "btnTxt", UIDefine.ExchangeMoneyToStr(FactionUI.DonateConfig.Config[3].MoneyValue, 0), 0, 0, 120, 30)
            GUI.StaticSetAlignment(btnTxt, TextAnchor.MiddleCenter)
            UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
            GUI.SetData(donateBtn, "Money", FactionUI.DonateConfig.Config[3].MoneyValue)
            GUI.SetData(donateBtn, "Index", "3")
            GUI.RegisterUIEvent(donateBtn, UCE.PointerClick, "FactionUI", "OnContributeMoneyBtnClick")

            local donateBtn = GUI.ButtonCreate(bottomBg, "donateBtn4", "1800402110", 565, -37, Transition.SpriteSwap, "", 102, 45, false)
            _gt.BindName(donateBtn, "donateBtn4")
            UILayout.SetSameAnchorAndPivot(donateBtn, UILayout.TopLeft)
            local btnTxt = GUI.CreateStatic(donateBtn, "btnTxt", UIDefine.ExchangeMoneyToStr(FactionUI.DonateConfig.Config[4].MoneyValue, 0), 0, 0, 120, 30)
            GUI.StaticSetAlignment(btnTxt, TextAnchor.MiddleCenter)
            UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
            GUI.SetData(donateBtn, "Money", FactionUI.DonateConfig.Config[4].MoneyValue)
            GUI.SetData(donateBtn, "Index", "4")
            GUI.RegisterUIEvent(donateBtn, UCE.PointerClick, "FactionUI", "OnContributeMoneyBtnClick")

            local horizontalTips2 = GUI.CreateStatic(bottomBg, "horizontalTips2", "可\n获\n得", 17, 9, 30, 85)
            UILayout.SetSameAnchorAndPivot(horizontalTips2, UILayout.BottomLeft)
            UILayout.StaticSetFontSizeColorAlignment(horizontalTips2, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

            local horizontalTips3 = GUI.CreateStatic(bottomBg, "horizontalTips3", "帮贡", 105, 58, 50, 30)
            UILayout.SetSameAnchorAndPivot(horizontalTips3, UILayout.BottomLeft)
            UILayout.StaticSetFontSizeColorAlignment(horizontalTips3, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

            local horizontalTips4 = GUI.CreateStatic(bottomBg, "horizontalTips4", "帮派资金", 79, 11, 97, 30)
            UILayout.SetSameAnchorAndPivot(horizontalTips4, UILayout.BottomLeft)
            UILayout.StaticSetFontSizeColorAlignment(horizontalTips4, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

            local factionContributionTips1Bg = GUI.GroupCreate(bottomBg, "factionContributionTips1Bg", 205, 53, 102, 45)
            UILayout.SetSameAnchorAndPivot(factionContributionTips1Bg, UILayout.BottomLeft)
            local txt = GUI.CreateStatic(factionContributionTips1Bg, "txt", tostring(FactionUI.DonateConfig.Config[1].Contribute * Donate_SilverToFund  / 100), 0, 0, 120, 30)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

            local factionCaptialTips1Bg = GUI.GroupCreate(bottomBg, "factionCaptialTips1Bg", 205, 5, 102, 45)
            UILayout.SetSameAnchorAndPivot(factionContributionTips1Bg, UILayout.BottomLeft)
            local txt = GUI.CreateStatic(factionCaptialTips1Bg, "txt", tostring(FactionUI.DonateConfig.Config[1].Fund* Donate_SilverToContribution / 100), 0, 0, 120, 30)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

            local factionContributionTips2Bg = GUI.GroupCreate(bottomBg, "factionContributionTips2Bg", 325, 53, 102, 45)
            UILayout.SetSameAnchorAndPivot(factionContributionTips2Bg, UILayout.BottomLeft)
            local txt = GUI.CreateStatic(factionContributionTips2Bg, "txt", tostring(FactionUI.DonateConfig.Config[2].Contribute * Donate_SilverToFund / 100), 0, 0, 120, 30)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

            local factionCaptialTips2Bg = GUI.GroupCreate(bottomBg, "factionCaptialTips2Bg", 325, 5, 102, 45)
            UILayout.SetSameAnchorAndPivot(factionCaptialTips2Bg, UILayout.BottomLeft)
            local txt = GUI.CreateStatic(factionCaptialTips2Bg, "txt", tostring(FactionUI.DonateConfig.Config[2].Fund * Donate_SilverToContribution / 100), 0, 0, 120, 30)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

            local factionContributionTips3Bg = GUI.GroupCreate(bottomBg, "factionContributionTips3Bg", 445, 53, 102, 45)
            UILayout.SetSameAnchorAndPivot(factionContributionTips1Bg, UILayout.BottomLeft)
            local txt = GUI.CreateStatic(factionContributionTips3Bg, "txt", tostring(FactionUI.DonateConfig.Config[3].Contribute * Donate_SilverToFund  / 100), 0, 0, 120, 30)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

            local factionCaptialTips3Bg = GUI.GroupCreate(bottomBg, "factionCaptialTips3Bg", 445, 5, 102, 45)
            UILayout.SetSameAnchorAndPivot(factionCaptialTips3Bg, UILayout.BottomLeft)
            local txt = GUI.CreateStatic(factionCaptialTips3Bg, "txt", tostring(FactionUI.DonateConfig.Config[3].Fund * Donate_SilverToContribution / 100), 0, 0, 120, 30)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

            local factionContributionTips4Bg = GUI.GroupCreate(bottomBg, "factionContributionTips4Bg", 565, 53, 102, 45)
            UILayout.SetSameAnchorAndPivot(factionContributionTips4Bg, UILayout.BottomLeft)
            local txt = GUI.CreateStatic(factionContributionTips4Bg, "txt", tostring(FactionUI.DonateConfig.Config[4].Contribute * Donate_SilverToFund / 100), 0, 0, 120, 30)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

            local factionCaptialTips4Bg = GUI.GroupCreate(bottomBg, "factionCaptialTips4Bg", 565, 5, 102, 45)
            UILayout.SetSameAnchorAndPivot(factionCaptialTips4Bg, UILayout.BottomLeft)
            local txt = GUI.CreateStatic(factionCaptialTips4Bg, "txt", tostring(FactionUI.DonateConfig.Config[4].Fund * Donate_SilverToContribution / 100), 0, 0, 120, 30)
            UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
        end

        local verCutline1 = GUI.ImageCreate(bottomBg, "verCutline1", "1800800080", 60, 1, false, 2, 214)
        UILayout.SetSameAnchorAndPivot(verCutline1, UILayout.BottomLeft)

        local verCutline2 = GUI.ImageCreate(bottomBg, "verCutline2", "1800800080", 195, 1, false, 2, 214)
        UILayout.SetSameAnchorAndPivot(verCutline2, UILayout.BottomLeft)

        local verCutline3 = GUI.ImageCreate(bottomBg, "verCutline3", "1800800080", 315, 1, false, 2, 214)
        UILayout.SetSameAnchorAndPivot(verCutline3, UILayout.BottomLeft)

        local verCutline4 = GUI.ImageCreate(bottomBg, "verCutline4", "1800800080", 435, 1, false, 2, 214)
        UILayout.SetSameAnchorAndPivot(verCutline4, UILayout.BottomLeft)

        local verCutline5 = GUI.ImageCreate(bottomBg, "verCutline5", "1800800080", 555, 1, false, 2, 214)
        UILayout.SetSameAnchorAndPivot(verCutline5, UILayout.BottomLeft)

        --绑定金币和帮贡的刷新
        CL.RegisterAttr(RoleAttr.RoleAttrBindIngot, FactionUI.UpdateMoneyValue)
        CL.RegisterAttr(RoleAttr.RoleAttrGuildContribute, FactionUI.UpdateMoneyValue)
        CL.RegisterAttr(RoleAttr.RoleAttrGuildAchievement, FactionUI.UpdateMoneyValue)
        CL.RegisterAttr(RoleAttr.RoleAttrGuildFightScore, FactionUI.UpdateMoneyValue)
    else
        GUI.SetVisible(factionContributePanel, true)
    end
    local mySelfBindGold = _gt.GetUI("mySelfBindGold")
    if mySelfBindGold then
        local haveMoney = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindIngot)))
        GUI.StaticSetText(mySelfBindGold, UIDefine.ExchangeMoneyToStr(haveMoney))
    end
    local mySelfContribute = _gt.GetUI("mySelfContribute")
    if mySelfContribute then
        local contribute = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrGuildContribute)))
        GUI.StaticSetText(mySelfContribute, UIDefine.ExchangeMoneyToStr(contribute))
    end
end

function FactionUI.OnContributeMoneyBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local money = tonumber(GUI.GetData(btn, "Money"))
    local index = tonumber(GUI.GetData(btn, "Index"))
    --index = tonumber(tostring(index))
    local haveMoney = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindIngot)))
--[[    if FactionUI.DonateConfig.WeekValue + FactionUI.DonateConfig.Config[tonumber(index)].MoneyValue > FactionUI.DonateConfig.WeekMax then
        CL.SendNotify(NOTIFY.ShowBBMsg,"本次捐献将超过每周捐献上限，无法捐献")
        return
    end]]
--[[    if haveMoney < money then
        GlobalUtils.ShowBoxMsg2Btn("提示","您的银元宝不足，还差"..money-haveMoney.."，是否消耗"..money-haveMoney.."金元宝补充不足？","FactionUI","确认","OnDonateMsgBoxYes","取消", nil, nil, index)
        return
    end]]
    GlobalUtils.ShowBoxMsg2Btn("提示","捐献"..(FactionUI.DonateConfig.Config[index].MoneyValue).."银元会获得"..(FactionUI.DonateConfig.Config[index].Contribute).."点帮派贡献，同时帮会会获得"..(FactionUI.DonateConfig.Config[index].Fund).."点帮派资金，是否确认捐献？","FactionUI","确认","OnDonateMsgBoxYes","取消", nil, nil, tostring(index))
end

function FactionUI.OnDonateMsgBoxYes(index)
    --print(index)
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 5, index)
end

function FactionUI.UpdateMoneyValue(attrType, value)
    if attrType == RoleAttr.RoleAttrBindIngot then
        local mySelfBindGold = _gt.GetUI("mySelfBindGold")
        if mySelfBindGold then
            GUI.StaticSetText(mySelfBindGold, UIDefine.ExchangeMoneyToStr(value))
        end
    elseif attrType == RoleAttr.RoleAttrGuildContribute then
        local mySelfContribute = _gt.GetUI("mySelfContribute")
        if mySelfContribute then
            GUI.StaticSetText(mySelfContribute, UIDefine.ExchangeMoneyToStr(value))
        end
        local factionContributionTxt = _gt.GetUI("factionContributionTxt1")
        if factionContributionTxt then
            GUI.StaticSetText(factionContributionTxt, UIDefine.ExchangeMoneyToStr(value))
        end
    elseif attrType == RoleAttr.RoleAttrGuildAchievement then
        local factionContributionTxt = _gt.GetUI("factionContributionTxt2")
        if factionContributionTxt then
            GUI.StaticSetText(factionContributionTxt, UIDefine.ExchangeMoneyToStr(value))
        end
    elseif attrType == RoleAttr.RoleAttrGuildFightScore then
        local factionContributionTxt = _gt.GetUI("factionContributionTxt3")
        if factionContributionTxt then
            GUI.StaticSetText(factionContributionTxt, UIDefine.ExchangeMoneyToStr(value))
        end
    end
end

function FactionUI.OnCloseBtnClick_FactionContributePanel(guid)
    local factionContributePanel = GUI.Get("FactionUI/factionContributePanel")
    GUI.SetVisible(factionContributePanel, false)
end

function FactionUI.OnBackToFactionBtnClick(guid)
    local RoleAttrIsAutoGame = CL.GetIntAttr(RoleAttr.RoleAttrIsAutoGame)
    if RoleAttrIsAutoGame == 1 then
        return
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 7)
end

function FactionUI.OnSendNotifyBtnClick(guid)
    if FactionUI.FactionData ~= nil and FactionUI.FactionData.self ~= nil then
        local changeBoardPermission=LD.HavePermission(FactionUI.FactionData.self.permission,guild_permission.guild_permission_send_notice)
        if changeBoardPermission == false then
            CL.SendNotify(NOTIFY.ShowBBMsg,"您没有发送帮派通知的权限")
            return
        end
    end

    local sendNotifyCover = _gt.GetUI("sendNotifyCover")
    if sendNotifyCover == nil then
        local panel = GUI.GetWnd("FactionUI")
        sendNotifyCover = GUI.ImageCreate(panel, "sendNotifyCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        _gt.BindName(sendNotifyCover, "sendNotifyCover")
        UILayout.SetSameAnchorAndPivot(sendNotifyCover, UILayout.Center)
        GUI.SetIsRaycastTarget(sendNotifyCover, true)

        local sendNotifyBg = GUI.ImageCreate(sendNotifyCover, "sendNotifyBg", "1800400300", 0, 0, false, 635, 355)
        UILayout.SetSameAnchorAndPivot(sendNotifyBg, UILayout.Center)

        local closeBtn = GUI.ButtonCreate(sendNotifyBg, "closeBtn", "1800302120", 0, 0, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_SendNotifyBg")

        local titleBg = GUI.ImageCreate(sendNotifyBg, "titleBg", "1800001140", 0, 15, false, 265, 33)
        UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Top)
        local txt = GUI.CreateStatic(titleBg, "txt", "帮派通知", 0, 0, 97, 45)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.WhiteColor, nil)

        local inputNameTips = GUI.CreateStatic(sendNotifyBg, "inputNameTips", "请输入发送给帮派全员的通知信息", 25, 75, 400, 32)
        UILayout.SetSameAnchorAndPivot(inputNameTips, UILayout.TopLeft)
        UILayout.StaticSetFontSizeColorAlignment(inputNameTips, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)

        local costEnergyTips = GUI.CreateStatic(sendNotifyBg, "costEnergyTips", "消耗活力：", -40, 75, 142, 32)
        UILayout.SetSameAnchorAndPivot(costEnergyTips, UILayout.TopRight)
        UILayout.StaticSetFontSizeColorAlignment(costEnergyTips, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)

        local txt = GUI.CreateStatic(costEnergyTips, "txt", FACTION_ANNOUNCE_ENERGY_COST, -115, 0, 64, 35)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeXL, UIDefine.RedColor, nil)

        local inputField = GUI.EditCreate(sendNotifyBg, "inputField", "1800400390", "请输入帮派通知", 25, 120, Transition.ColorTint, "system", 585, 155, 10, 10)
        _gt.BindName(inputField, "factionNotify")
        UILayout.SetSameAnchorAndPivot(inputField, UILayout.TopLeft)
        GUI.EditSetLabelAlignment(inputField, TextAnchor.UpperLeft)
        GUI.EditSetFontSize(inputField, UIDefine.FontSizeL)
        GUI.EditSetTextColor(inputField, UIDefine.BrownColor)
        GUI.EditSetMultiLineEdit(inputField, LineType.MultiLineSubmit)
        GUI.SetPlaceholderTxtColor(inputField, UIDefine.GrayColor)
        GUI.EditSetMaxCharNum(inputField, 100)

        local concelBtn = GUI.ButtonCreate(sendNotifyBg, "concelBtn", "1800602030", 90, -25, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(concelBtn, UILayout.BottomLeft)
        local btnTxt = GUI.CreateStatic(concelBtn, "btnTxt", "取消", 0, 0, 52, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_SendNotifyBg")

        local confirmBtn = GUI.ButtonCreate(sendNotifyBg, "confirmBtn", "1800602030", -90, -25, Transition.ColorTint)
        UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight)
        local btnTxt = GUI.CreateStatic(confirmBtn, "btnTxt", "确定", 0, 0, 52, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "FactionUI", "OnConfirmBtnClick_SendNotifyBg")
    else
        GUI.SetVisible(sendNotifyCover, true)
    end
end

function FactionUI.OnCloseBtnClick_SendNotifyBg(guid)
    local factionNotify = _gt.GetUI("factionNotify")
    if factionNotify then
        GUI.EditSetTextM(factionNotify,"")
    end
    local sendNotifyCover = _gt.GetUI("sendNotifyCover")
    GUI.SetVisible(sendNotifyCover, false)
end

function FactionUI.OnConfirmBtnClick_SendNotifyBg(guid)
    local haveVP = CL.GetIntAttr(RoleAttr.RoleAttrVp)
    if haveVP < FACTION_ANNOUNCE_ENERGY_COST then
        CL.SendNotify(NOTIFY.ShowBBMsg,"活力不足，无法发送")
        return
    end

    local factionNotify = _gt.GetUI("factionNotify")
    if factionNotify then
        if string.len(factionNotify.Text) == 0 then
            CL.SendNotify(NOTIFY.ShowBBMsg,"请输入通知内容")
            return
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 6, factionNotify.Text)
    end
end

function FactionUI.CreatInfoMemberItemList()
    --print("CreatInfoMemberItemList")
    local sellScroll = _gt.GetUI("InfoMemberListScr")
    local index = FactionUI.FactionData.guild.member_count
    --print("index"..index)
    for i = 0, index-1 do
        local memberItem = GUI.ItemCtrlCreate(sellScroll, "memberItem" .. i, "1800600230", 0, 40*i, 550, 38, false)
        _gt.BindName(memberItem, "InfoMemberItem" .. i)
        UILayout.SetSameAnchorAndPivot(memberItem, UILayout.Top)
        FactionUI.UnSelectItem(memberItem, math.fmod(i, 2) == 0)
        GUI.SetVisible(memberItem,false)

        local txt = GUI.CreateStatic(memberItem, "memberName", "人", -175, 0, 180, 26, "system", false)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(memberItem, "memberLevel", "1级", -45,  0, 120, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(memberItem, "memberSchool", "花果山", 60, 0, 120, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local txt = GUI.CreateStatic(memberItem, "memberPosition","普通帮众", 200, 0, 120, 30)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)
    end
end

function FactionUI.OnReceiveBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm,"FormGuild","ExecuteOperation",3)
end

function FactionUI.RefreshInfoMemberItem()
    local index = FactionUI.FactionData.guild.online_count
    --CDebug.LogError("index......."..index)
    local Message = LD.GetMemberByIndex(0, FactionUI.SelectMemberSearchMode)
    if Message == nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "GetGuildMembers", 0, ONE_PAGE_NUM)
        return
    end
    local count
    if FactionUI.LastIndex then
        if index < FactionUI.LastIndex then
            count = FactionUI.LastIndex - 1
        else
            count = index - 1
        end
    else
        count = index - 1
    end
    for i = 0, count do
        --CDebug.LogError("index"..i)
        local item = _gt.GetUI("InfoMemberItem" .. i)
        if item == nil then
            FactionUI.CreatInfoMemberItemList()
        end
        local Name = GUI.GetChild(item,"memberName")
        local Level = GUI.GetChild(item,"memberLevel")
        local Job = GUI.GetChild(item,"memberSchool")
        local FactionJob = GUI.GetChild(item,"memberPosition")

        local memberData = LD.GetMemberByIndex(i, FactionUI.SelectMemberSearchMode)

        if memberData ~= nil then
            if memberData ~= nil and i <= index - 1 then
                GUI.SetVisible(item,true)
            else
                GUI.SetVisible(item,false)
            end

            GUI.StaticSetText(Name,memberData.player_name)

            GUI.StaticSetText(Level,memberData.level)

            local MJob = DB.GetSchool(memberData.job)

            GUI.StaticSetText(Job,MJob.Name)
            GUI.StaticSetText(FactionJob,FactionUI.ParseJobShowName(memberData.guild_job))
            --CDebug.LogError("Name......."..memberData.player_name)
        end
    end
    FactionUI.LastIndex = index
end

function FactionUI.ChangeNameProp()
    GUI.OpenWnd("FactionUI")
    FactionUI.OnChangeNameBtnClick()
end

function FactionUI.OnImpeachmentBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm,"FormGuild","GetImpeach")
    local ImpeachmentBg = _gt.GetUI("ImpeachmentBg")
    if ImpeachmentBg == nil then
        local panel = GUI.GetWnd("FactionUI")
        local ImpeachmentBg = FactionUI.CreateSmallMenuBgFree("ImpeachmentBg", panel, "弹劾帮主", 590, 560)
        _gt.BindName(ImpeachmentBg, "ImpeachmentBg")
        local closeBtn = GUI.Get("FactionUI/ImpeachmentBg/panelBg/closeBtn")
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_ImpeachmentBgPanel")

        local ImpeachmentRuleBg = GUI.ImageCreate(ImpeachmentBg,"ImpeachmentRuleBg","1800800150",0,-90,false,550,245)
        local ImpeachmentRuleTitle = GUI.CreateStatic(ImpeachmentRuleBg,"ImpeachmentRuleTitle","弹\n劾\n帮\n主\n规\n则",-240,0,50,245)
        UILayout.StaticSetFontSizeColorAlignment(ImpeachmentRuleTitle, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        local ImpeachmentRule = GUI.CreateStatic(ImpeachmentRuleBg,"ImpeachmentRule","1、帮主<color=#FF0000ff>超过七日</color>未上线，副帮主或者堂主才可以对帮主进行弹劾。\n"..
                                                                                                  "2、发起弹劾后，需要帮派成员投票确认是否赞同。\n"..
                                                                                                  "3、投票的帮派成员到达全部活跃帮派成员的<color=#FF0000ff>50%</color>，且赞同投票大于否决投票，弹劾才会成功。\n"..
                                                                                                  "4、一次弹劾决议，最多持续<color=#FF0000ff>72小时</color>，弹劾结束，宣布结果\n"..
                                                                                                  "5、弹劾成功后副帮主成为帮主，原帮主降为帮众。",25,-10,500,240,"system",true)
        UILayout.StaticSetFontSizeColorAlignment(ImpeachmentRule, UIDefine.FontSizeM, UIDefine.BrownColor, nil)

        local ImpeachmentStateBg = GUI.ImageCreate(ImpeachmentBg,"ImpeachmentStateBg","1800800150",0,120,false,550,160)
        local ImpeachmentStateTitle = GUI.CreateStatic(ImpeachmentStateBg,"ImpeachmentStateTitle","弹\n劾\n状\n态",-240,0,50,160)
        UILayout.StaticSetFontSizeColorAlignment(ImpeachmentStateTitle, UIDefine.FontSizeXL, UIDefine.BrownColor, nil)
        local ImpeachmentState = GUI.CreateStatic(ImpeachmentStateBg,"ImpeachmentState","帮主未超过七日不上线，您无法发起对他的弹劾。",25,0,500,150)
        _gt.BindName(ImpeachmentState,"ImpeachmentState")
        UILayout.StaticSetFontSizeColorAlignment(ImpeachmentState, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
        GUI.SetVisible(ImpeachmentState,false)

        local ExitBtn = GUI.ButtonCreate(ImpeachmentBg,"ExitBtn","1800602030",-200,230,Transition.ColorTint)
        local btnTxt = GUI.CreateStatic(ExitBtn, "btnTxt", "取消", 25, 0, 104, 45)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(ExitBtn, UCE.PointerClick, "FactionUI", "OnCloseBtnClick_ImpeachmentBgPanel")

        local StartImpeachmentBtn = GUI.ButtonCreate(ImpeachmentBg,"StartImpeachmentBtn","1800602030",200,230,Transition.ColorTint)
        local btnTxt = GUI.CreateStatic(StartImpeachmentBtn, "btnTxt", "发起弹劾", 0, 0, 104, 45)
        _gt.BindName(StartImpeachmentBtn,"StartImpeachmentBtn")
        GUI.ButtonSetShowDisable(StartImpeachmentBtn,false)
        UILayout.SetSameAnchorAndPivot(btnTxt, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(btnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, nil)
        GUI.SetOutLine_Color(btnTxt, UIDefine.Orange2Color)
        GUI.SetOutLine_Distance(btnTxt, 1)
        GUI.SetIsOutLine(btnTxt, true)
        GUI.RegisterUIEvent(StartImpeachmentBtn, UCE.PointerClick, "FactionUI", "OnStartImpeachmentBtnClick")

        local Impeachment_ing = GUI.GroupCreate(ImpeachmentStateBg,"Impeachment_ing",0,0,550,160)
        GUI.SetVisible(Impeachment_ing,false)
        _gt.BindName(Impeachment_ing,"Impeachment_ing")
        local Impeachment_ingMsg = GUI.CreateStatic(Impeachment_ing,"Impeachment_ingMsg","xxx发起了对xxx的弹劾。",25,-20,500,80,"system",true)
        UILayout.StaticSetFontSizeColorAlignment(Impeachment_ingMsg, UIDefine.FontSizeM, UIDefine.BrownColor, nil)

        local Remaining_time = GUI.CreateStatic(Impeachment_ing,"Remaining_time","剩余时间：",-125,20,200,40)
        UILayout.StaticSetFontSizeColorAlignment(Remaining_time, UIDefine.FontSizeM, UIDefine.BrownColor, nil)
        local Remaining_time_data = GUI.CreateStatic(Impeachment_ing,"Remaining_time_data","",30,20,300,60)
        UILayout.StaticSetFontSizeColorAlignment(Remaining_time_data, UIDefine.FontSizeM, UIDefine.RedColor, nil)

    else
        GUI.SetVisible(ImpeachmentBg,true)
    end
end
function FactionUI.OnCloseBtnClick_ImpeachmentBgPanel()
    if FactionUI.ImpeachmentTimer then
        FactionUI.ImpeachmentTimer:Stop()
        FactionUI.ImpeachmentTimer = nil
    end
    local Bg = GUI.Get("FactionUI/ImpeachmentBg")
    GUI.SetVisible(Bg,false)
end

function FactionUI.OnStartImpeachmentBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation",9)
end

function FactionUI.refreshImpeachment()
    local ImpeachmentState = _gt.GetUI("ImpeachmentState")
    local StartImpeachmentBtn = _gt.GetUI("StartImpeachmentBtn")
    local Impeachment_ing = _gt.GetUI("Impeachment_ing")
    local Impeachment_ingMsg = GUI.GetChild(Impeachment_ing,"Impeachment_ingMsg",false)
    local Remaining_time_data = GUI.GetChild(Impeachment_ing,"Remaining_time_data",false)
    if FactionUI.ImpeachState == -1 then
        GUI.SetVisible(ImpeachmentState,true)
        GUI.SetVisible(Impeachment_ing,false)
        GUI.StaticSetText(ImpeachmentState,"帮主未超过七日不上线，您无法发起对他的弹劾。")
        GUI.ButtonSetShowDisable(StartImpeachmentBtn,false)
    elseif FactionUI.ImpeachState == 0 then
        GUI.SetVisible(ImpeachmentState,true)
        GUI.SetVisible(Impeachment_ing,false)
        GUI.StaticSetText(ImpeachmentState,"帮主超过七日不上线，您可以发起对他的弹劾。")
        GUI.ButtonSetShowDisable(StartImpeachmentBtn,true)
    elseif FactionUI.ImpeachState == 1 then
        local now_time = tonumber(CL.GetServerTickCount())
        FactionUI.RemainingTime = FactionUI.ImpeachEndTime - now_time
        if FactionUI.ImpeachmentTimer == nil then
            FactionUI.ImpeachmentTimer = Timer.New(FactionUI.reduceTime, 1, -1)
            FactionUI.ImpeachmentTimer:Start()
        end
        GUI.SetVisible(ImpeachmentState,false)
        GUI.SetVisible(Impeachment_ing,true)
        GUI.StaticSetText(Impeachment_ingMsg,"<color=#FF0000ff>"..FactionUI.ImpeachInitiator.."</color>发起了对帮主的弹劾。")
        local now_time = tonumber(CL.GetServerTickCount())
        local day, hour, minute, second = nil
        day, hour, minute, second = GlobalUtils.Get_DHMS1_BySeconds(FactionUI.ImpeachEndTime - now_time)
        --print(day.."天"..hour.."小時"..minute.."分钟"..second.."秒")
        GUI.StaticSetText(Remaining_time_data,day.."天"..hour.."小时"..minute.."分钟"..second.."秒")
        GUI.ButtonSetShowDisable(StartImpeachmentBtn,false)
    end
end

function FactionUI.reduceTime()
    FactionUI.RemainingTime = FactionUI.RemainingTime - 1
    local Impeachment_ing = _gt.GetUI("Impeachment_ing")
    local Remaining_time_data = GUI.GetChild(Impeachment_ing,"Remaining_time_data",false)
    local day, hour, minute, second = nil
    day, hour, minute, second = GlobalUtils.Get_DHMS1_BySeconds(FactionUI.RemainingTime)
    GUI.StaticSetText(Remaining_time_data,day.."天"..hour.."小時"..minute.."分钟"..second.."秒")
    if FactionUI.RemainingTime == 0 then
        FactionUI.OnCloseBtnClick_ImpeachmentBgPanel()
    end
end

function FactionUI.OnfactionMaintenanceInfoBtnClick()
    local factionInfoBg = _gt.GetUI("factionInfoBg")
    local tip = Tips.CreateHint("通过完成帮派任务可以增加帮派建设度", factionInfoBg, -28, 80, UILayout.Center, 300, nil, true)
    GUI.SetIsRemoveWhenClick(tip, true)
end

function FactionUI.RefreshContribute()
    local txt = _gt.GetUI("txtRule2")
    GUI.StaticSetText(txt,"4.本周捐献进度："..FactionUI.DonateConfig.WeekValue.."银元/200000银元。")
end

function FactionUI.SetContributeRedPoint()
    --CDebug.LogError("SetRedPoint")
    FactionUI.contributeBtnRedPoint = true
end