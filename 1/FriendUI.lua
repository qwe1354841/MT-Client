local FriendUI = {}
_G.FriendUI = FriendUI

local GUI = GUI
local _gt = UILayout.NewGUIDUtilTable() -- UILayout.NewGUIDUtilTable()
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot

local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")

----------------------------------------------------------颜色、字体大小配置 Start-------------------------------------------------------

-- 字体大小
local fontSizeDefault = UIDefine.FontSizeM
local fontSizeSmaller = UIDefine.FontSizeS
local fontSizeBigger = UIDefine.FontSizeL

-- 颜色
local colorDark = UIDefine.BrownColor -- Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorWhite = UIDefine.WhiteColor -- Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorInvisibility = UIDefine.Transparent -- Color.New(1, 1, 1, 0)
local colorBlack = Color.New(0/255, 0/255, 0/255, 00/255)
local colorGray = UIDefine.Gray3Color -- Color.New(192 / 255, 192 / 255, 192 / 255, 255 / 255)
local colorGreen = Color.New(27 / 255, 187 / 255, 0 / 255, 255 / 255)
local colorRed = Color.red --Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255)
local colorBtn = UIDefine.Brown3Color -- Color.New(142 / 255, 75 / 255, 39 / 255, 255 / 255)
local colorOutline = Color.New(162 / 255.0, 75 / 225.0, 21 / 255.0, 1)
local colorType_DarkYellow = UIDefine.BrownColor -- Color.New(102 / 255, 47 / 255, 22 / 255, 1)
local ColorSys = Color.New(158 / 255, 133 / 255, 111 / 255, 1)
local OutLineDistance = UIDefine.OutLineDistance
local OutLine_BrownColor = UIDefine.OutLine_BrownColor
-----------------------------------------------------------颜色、字体大小配置 End----------------------------------------------------------


-----------------------------------------缓存一下常用的全局变量 Start---------------------------
local searchBtnStatus = 0
local FriendRedIsShow = 2
local CurSelectFriendType = 0
local AreaItemStatus = 0
local RoleSelfIcon = tostring(CL.GetRoleHeadIcon())
local searchContent = nil
local AreaItemName = nil
local CurSelectFriendData = nil
local CurSelectPage = nil -- 当前选中的页面
local CurSelectBtn = 1 --当前选中的按钮
local SelectFriendItemGuid = nil
local SelectFriendItemGuid1 = nil
local SelectFriendItemGuid2 = nil
local RedClickNum = nil
local ElfItemGuid = nil
local CurItemQueryGuid = nil
local FriendShipRecommendData = nil
local FriendUITimerValue = 10 --计时器的时间
local LastSelectRedFriendItem = nil --上一个红点选择对象
local ClickFriendTypeList1 = {}
local ClickFriendTypeList2 = {}
local CurFriendList = {}
local AllCurFriendList = {}
local ItemGuid2RoleGuid = {}
local ItemGuid3RoleGuid = {}
local SelectRedItemGuidList = {} --红点控件GUID,1是显示,0是不显示
local FriendRedTable = {}
local ElfContentTable = {}
local ReturnContentTable = {}

------------------------------------------------------------ 缓存一下全局变量  End ---------------------------------------

local messageEventList = {
    { GM.FriendListUpdate, "OnFriendListUpdate"},--请求好友的返回值监听
    { GM.FriendChatUpdate, "OnFriendChatUpdate" },
    { GM.UploadRecordSuccess, "OnUploadRecordSuccess" },
    { GM.RecordPlayStart, "OnRecordPlayStart" },
    { GM.ItemQueryNtf, "OnItemQueryNtf" },
    { GM.PetQueryNtf, "OnPetQueryNtf" },
    { GM.MailUpdate, "OnMailUpdate" }
}

local btnList = {
    { "查看信息", "checkInfo", "OnCheckInfoBtnClick"},
    { "邀请组队", "inviteTeam", "OnInviteTeamBtnClick" },
    { "赠送礼物", "giveGift", "OnGiveGiftBtnClick" },
    { "加为好友", "friend", "OnFriendBtnClick" },
    { "邀请入帮", "inviteGang", "OnInviteGangBtnClick" },
    { "加黑名单", "addBlacklist",    "OnAddBlacklistBtnClick"},
    --{ "比武切磋", "fight", "OnFightBtnClick" },
}

local contactTypeList =
{
    {CONTACT_FRIEND,        "friend",       "我的好友"},
    {CONTACT_STRANGER,      "stranger",     "陌生人"},
    {CONTACT_BLACKLIST,     "blacklist",    "黑名单"},
}


local LabelList = {
    { "好友", "friendPageBtn", "OnFriendPageBtnClick", "recentlyPage" },
    { "邮件", "emailPageBtn", "OnEmailPageBtnClick", "emailPage", },
}

local CONTACT_TYPE = {
    contact_recently = 99, --//最近联系人re
    contact_apply = 1, --//好友申请
    contact_friend = 2, --//好友
    contact_blacklist = 3, --//黑名单
    contact_stranger = 0,--陌生人
    contact_search = 100, --搜索列表
}

local PageEnum = {
    Friend = 1,
    Email = 2,
}

FriendUI.operateAckTick = 0
-- 好友邀请码
local inviteCode = "#ICOD"

FriendUI.toggleGroup = {}
FriendUI.parameter = nil

function FriendUI.Main(parameter)
    GUI.PostEffect()
    require("QuestionsAnswersElf")
    FriendUI.SelectedRoleGuid = parameter or "1" -- 当前选中的GUID
    local panel = GUI.WndCreateWnd("FriendUI", "FriendUI", 0, 0, eCanvasGroup.Normal)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    panel:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(panel, true)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "好    友", "FriendUI", "OnExit", _gt)
    UILayout.CreateRightTab(LabelList, "FriendUI")
    ReturnContentTable = {}
end

function FriendUI.OnShow(parameter)
    local wnd = GUI.GetWnd("FriendUI");
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd,true)
    FriendUI.Init()
    FriendUI.ResetLastSelectPage(PageEnum.Friend)
    if parameter ~= nil then
        parameter = string.split(parameter, "#")
        local guid = parameter[1]
        FriendShipRecommendData = tostring(parameter[2])
        FriendUI.SelectedRoleGuid = tostring(guid)
        local ItemGuid1 = ClickFriendTypeList1[tostring(guid)]
        SelectFriendItemGuid1 = ItemGuid1
        SelectFriendItemGuid2 = ItemGuid1
        local typeList = tonumber(tostring(parameter[3]))
        if typeList ~= nil then
            if typeList == 2 then
                FriendUI.OnFriendPageBtnClick()
            else
                FriendUI.OnRecentlyPageBtnClick()
            end
        end
    end
    UILayout.OnTabClick(1, LabelList)
    FriendUI.RegisterMessage()
    FriendUI.Refresh()
    FriendUI.OnMailUpdate()

    --计时器关闭
    FriendUI.StopRefreshTimer()
    --计时器启动
    FriendUI.StartTimer()
end

function FriendUI.GetFriendRedTable()
    test("服务器设置好友红点")

    if next(FriendUI.FriendRedTable) then
        for k, v in pairs(FriendUI.FriendRedTable) do
            FriendRedTable[k] = v
        end
    else
        test("没有红点表单（FriendUI.FriendRedTable），返回")
    end

    test("FriendUI.FriendRedTable",inspect(FriendUI.FriendRedTable))



    local friendPageBtn = GUI.Get("FriendUI/panelBg/tabList/friendPageBtn")
    GUI.AddRedPoint(friendPageBtn,UIAnchor.TopLeft,25,-35,"1800208080")

    local IsRedValue = 0
    for k, v in pairs(FriendUI.FriendRedTable) do
        --最近设置红点
        test("最近设置红点")

        local IsRed = v

        if v then
            IsRedValue = 1
        end

        local ItemGuid1 = ClickFriendTypeList1[tostring(k)]

        local item1 = GUI.GetByGuid(ItemGuid1)
        if item1 then
            local friendiconBg = GUI.GetChild(item1,"friendiconBg")
            local friendicon = GUI.GetChild(friendiconBg,"friendicon")
            GUI.SetRedPointVisable(friendicon,IsRed)

            SelectRedItemGuidList[tostring(k)] = 1
        end


        test("联系人设置红点")
        --联系人设置红点
        local ItemGuid2 = ClickFriendTypeList2[tostring(k)]
        local item2 = GUI.GetByGuid(ItemGuid2)
        if item2 then
            local friendiconBg = GUI.GetChild(item2,"friendiconBg")
            local friendicon = GUI.GetChild(friendiconBg,"friendicon")
            GUI.SetRedPointVisable(friendicon,IsRed)
            SelectRedItemGuidList[tostring(k)] = 1
        end
    end


    local latelyBtn = _gt.GetUI("latelyBtn")
    local contactsBtn = _gt.GetUI("contactsBtn")

    if IsRedValue == 1 then

        local latelyBtnIs = 0
        for i, v in pairs(ClickFriendTypeList1) do

            if true then
                if FriendUI.FriendRedTable[i] == true then

                    latelyBtnIs= 1

                    SelectRedItemGuidList[tostring(i)] = 1

                end
            end


        end

        GUI.SetRedPointVisable(latelyBtn,latelyBtnIs == 1)


        local contactsBtnIs = 0
        for i2, v in pairs(ClickFriendTypeList2) do

            if true then
                if FriendUI.FriendRedTable[i2] == true then

                    contactsBtnIs= 1

                    SelectRedItemGuidList[tostring(i2)] = 1

                end
            end


        end

        GUI.SetRedPointVisable(contactsBtn,contactsBtnIs == 1)


        GUI.SetRedPointVisable(friendPageBtn,true)

    else

        GUI.SetRedPointVisable(latelyBtn,false)

        GUI.SetRedPointVisable(contactsBtn,false)

        GUI.SetRedPointVisable(friendPageBtn,false)

    end
end

function FriendUI.Init()
    SelectFriendItemGuid1 = nil
    FriendUI.SelectedRoleGuid = "1"
    FriendUI.FriendContactItemMax = 3
    FriendUI.OperateSelectedRoleGuid = "0"
    FriendUI.TempGuid = "0"
    FriendUI.TempName = ""
    FriendUI.QueryName = ""
    FriendUI.QueryId = 0
    FriendUI.SendRecordTargetGuid = nil
    FriendShipRecommendData = nil
    CurSelectPage = nil
    SelectFriendItemGuid = nil
    FriendRedIsShow = 2
    ElfContentTable = {}
end

-- 注册GM消息
function FriendUI.RegisterMessage()
    for k, v in ipairs(messageEventList) do
        CL.UnRegisterMessage(v[1], "FriendUI", v[2])
        CL.RegisterMessage(v[1], "FriendUI", v[2])
    end
end

function FriendUI.CheckMailRedPoint()
    if LD.GetMailTotalRedPointCount() > 0 then
        return true
    else
        return false;
    end
end

--最近按钮点击事件
function FriendUI.OnRecentlyPageBtnClick()
    test("最近按钮点击事件")
    if not FriendUI.ResetLastSelectPage(PageEnum.Friend) then
        return
    end

    CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_recently)
    test("--------------------111111111------------------")

    CurSelectBtn = 1
    --高亮点击设置
    local latelyBtn = _gt.GetUI("latelyBtn")
    local contactsBtn = _gt.GetUI("contactsBtn")
    GUI.ButtonSetImageID(latelyBtn,"1800402032")
    GUI.ButtonSetImageID(contactsBtn,"1800402030")
    GUI.SetVisible(_gt.GetUI("latelyPage"),true)
    GUI.SetVisible(_gt.GetUI("contactTypeListScroll"),false)
    local friendPageBtn = GUI.Get("FriendUI/panelBg/tabList/friendPageBtn")

    local ElfItem = GUI.GetByGuid(ElfItemGuid)
    if SelectFriendItemGuid1 ~= nil then
        if FriendUI.SelectedRoleGuid == "1" then
            GUI.CheckBoxExSetCheck(ElfItem, true)
        else
            GUI.CheckBoxExSetCheck(ElfItem, false)
            local ItemGuid1 = ClickFriendTypeList1[tostring(FriendUI.SelectedRoleGuid)]
            local item1 = GUI.GetByGuid(ItemGuid1)
            GUI.CheckBoxExSetCheck(item1, true)
            SelectRedItemGuidList[tostring(FriendUI.SelectedRoleGuid)] = 0
            local SumRedNum = 0
            for k, v in pairs(SelectRedItemGuidList) do
                SumRedNum = SumRedNum + tonumber(v)
            end
            if SumRedNum == 0 then
                GUI.SetRedPointVisable(latelyBtn,false)
                GUI.SetRedPointVisable(contactsBtn,false)
                GUI.SetRedPointVisable(friendPageBtn,false)
                GlobalProcessing.on_draw_redpoint("friendChatBtn", false)
            end
            SelectFriendItemGuid1 = ItemGuid1
            local ItemGuid2 = ClickFriendTypeList2[tostring(FriendUI.SelectedRoleGuid)]
            local item2 = GUI.GetByGuid(ItemGuid2)
            GUI.CheckBoxExSetCheck(item2, false)
        end
    else
        GUI.CheckBoxExSetCheck(ElfItem, false)
    end
end

--好友按钮点击事件
function FriendUI.OnFriendPageBtnClick()
    test("好友按钮点击事件")
    if not FriendUI.ResetLastSelectPage(PageEnum.Friend) then
        return
    end

    CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_friend)
    CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_stranger)
    CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_blacklist)

    CurSelectBtn = 2
    --高亮点击设置
    local latelyBtn = _gt.GetUI("latelyBtn")
    local contactsBtn = _gt.GetUI("contactsBtn")
    GUI.ButtonSetImageID(contactsBtn,"1800402032")
    GUI.ButtonSetImageID(latelyBtn,"1800402030")
    GUI.SetVisible(_gt.GetUI("latelyPage"),false)
    GUI.SetVisible(_gt.GetUI("contactTypeListScroll"),true)
    local friendPageBtn = GUI.Get("FriendUI/panelBg/tabList/friendPageBtn")
    if SelectFriendItemGuid2 ~= nil then
        if tonumber(FriendUI.SelectedRoleGuid) == 1 then

        else
            local ItemGuid2 = ClickFriendTypeList2[tostring(FriendUI.SelectedRoleGuid)]
            local item2 = GUI.GetByGuid(ItemGuid2)
            GUI.CheckBoxExSetCheck(item2, true)
            SelectFriendItemGuid2 = ItemGuid2
            SelectRedItemGuidList[tostring(FriendUI.SelectedRoleGuid)] = 0
            local SumRedNum = 0
            for k, v in pairs(SelectRedItemGuidList) do
                SumRedNum = SumRedNum + tonumber(v)
            end
            if SumRedNum == 0 then
                GUI.SetRedPointVisable(latelyBtn,false)
                GUI.SetRedPointVisable(contactsBtn,false)
                GUI.SetRedPointVisable(friendPageBtn,false)
                GlobalProcessing.on_draw_redpoint("friendChatBtn", false)
            end

            local ItemGuid1 = ClickFriendTypeList1[tostring(FriendUI.SelectedRoleGuid)]
            local item1 = GUI.GetByGuid(ItemGuid1)
            GUI.CheckBoxExSetCheck(item1, false)
        end
    end
end

function FriendUI.OnEmailPageBtnClick()
    if not FriendUI.ResetLastSelectPage(PageEnum.Email) then
        return
    end
    FriendUI.ShowEmailPage()
end

function FriendUI.ResetLastSelectPage(idx)
    UILayout.OnTabClick(idx, LabelList)
    if CurSelectPage == idx then
        return false
    end
    local titleText = _gt.GetUI("titleText")
    if idx == PageEnum.Email then
        GUI.StaticSetText(titleText, "邮    件")
    else
        GUI.StaticSetText(titleText, "好    友")
    end

    if idx == 2 then
        CurSelectPage = idx
    else
        CurSelectPage = nil
    end
    return true
end


function FriendUI.OnFriendListUpdate(contact_type)
    test("CL返回")
    FriendUI.ShowRecentlyPage(contact_type)
end

function FriendUI.OnFriendChatUpdate(guid)
    --小红点设置
    --页签好友按钮
    test("好友GUID",tostring(guid))
    local friendPageBtn = GUI.Get("FriendUI/panelBg/tabList/friendPageBtn")
    GUI.AddRedPoint(friendPageBtn,UIAnchor.TopLeft,25,-35,"1800208080")

    local element1Guid = ClickFriendTypeList1[tostring(guid)]
    local element2Guid = ClickFriendTypeList2[tostring(guid)]
    local ParentItem1 = GUI.GetByGuid(element1Guid)
    local ParentItem2 = GUI.GetByGuid(element2Guid)
    local friendiconBg1 = GUI.GetChild(ParentItem1,"friendiconBg")
    local friendiconBg2 = GUI.GetChild(ParentItem2,"friendiconBg")
    local item1 = GUI.GetChild(friendiconBg1,"friendicon")
    local item2 = GUI.GetChild(friendiconBg2,"friendicon")
    local latelyBtn = _gt.GetUI("latelyBtn")
    local contactsBtn = _gt.GetUI("contactsBtn")
    if LastSelectRedFriendItem == nil then
        if tonumber(FriendUI.SelectedRoleGuid) == 1 then
            FriendRedTable[tostring(guid)] = true
            GUI.SetRedPointVisable(item1,true)
            GUI.SetRedPointVisable(item2,true)

            GUI.SetRedPointVisable(latelyBtn,true)
            GUI.SetRedPointVisable(contactsBtn,true)
            GUI.SetRedPointVisable(friendPageBtn,true)
            GlobalProcessing.on_draw_redpoint("friendChatBtn", true)
        else
            GUI.SetRedPointVisable(item1,false)
            GUI.SetRedPointVisable(item2,false)
            FriendRedTable[tostring(guid)] = false
            SelectRedItemGuidList[tostring(guid)] = 0
            local SumRedNum = 0
            for k, v in pairs(SelectRedItemGuidList) do
                SumRedNum = SumRedNum + tonumber(v)
            end
            if SumRedNum == 0 then
                GUI.SetRedPointVisable(latelyBtn,false)
                GUI.SetRedPointVisable(contactsBtn,false)
                GUI.SetRedPointVisable(friendPageBtn,false)
                FriendRedIsShow = 2
                GlobalProcessing.on_draw_redpoint("friendChatBtn", false)
            end
        end
    else
        if tostring(guid) ~= LastSelectRedFriendItem then
            if tostring(FriendUI.SelectedRoleGuid)  == tostring(guid) then
                GUI.SetRedPointVisable(item1,false)
                GUI.SetRedPointVisable(item2,false)
                FriendRedTable[tostring(guid)] = false
                SelectRedItemGuidList[tostring(guid)] = 0
                local SumRedNum = 0
                for k, v in pairs(SelectRedItemGuidList) do
                    SumRedNum = SumRedNum + tonumber(v)
                end
                if SumRedNum == 0 then
                    GUI.SetRedPointVisable(latelyBtn,false)
                    GUI.SetRedPointVisable(contactsBtn,false)
                    GUI.SetRedPointVisable(friendPageBtn,false)
                    FriendRedIsShow = 2
                    GlobalProcessing.on_draw_redpoint("friendChatBtn", false)
                end
            else
                if item1 then
                    GUI.SetRedPointVisable(item1,true)
                    GUI.SetRedPointVisable(latelyBtn,true)
                    GUI.SetRedPointVisable(friendPageBtn,true)
                    FriendRedIsShow = 1
                end
                if item2 then
                    GUI.SetRedPointVisable(item2,true)
                    GUI.SetRedPointVisable(contactsBtn,true)
                    GUI.SetRedPointVisable(friendPageBtn,true)
                    FriendRedIsShow = 1
                end
                FriendRedTable[tostring(guid)] = true
                GlobalProcessing.on_draw_redpoint("friendChatBtn", true)
                SelectRedItemGuidList[tostring(guid)] = 1
            end

        else
            if tonumber(FriendUI.SelectedRoleGuid) == 1 then
            else
                GUI.SetRedPointVisable(item1,false)
                GUI.SetRedPointVisable(item2,false)
                FriendRedTable[tostring(guid)] = false
                SelectRedItemGuidList[tostring(guid)] = 0
                local SumRedNum = 0
                for k, v in pairs(SelectRedItemGuidList) do
                    SumRedNum = SumRedNum + tonumber(v)
                end
                if SumRedNum == 0 then
                    GUI.SetRedPointVisable(latelyBtn,false)
                    GUI.SetRedPointVisable(contactsBtn,false)
                    GUI.SetRedPointVisable(friendPageBtn,false)
                    FriendRedIsShow = 2
                    GlobalProcessing.on_draw_redpoint("friendChatBtn", false)
                end
            end
        end
    end
    LastSelectRedFriendItem = tostring(guid)

    --消息刷新
    if tostring(FriendUI.SelectedRoleGuid) == tostring(guid) then
        FriendUI.OnContactMessageUpdate(guid)
    end
end

local TableSet = function(a,b)
    if a.priority ~= b.priority then
        return a.priority < b.priority
    elseif a.status ~= b.status then
        return a.status > b.status

    elseif a.friendshipValue ~= b.friendshipValue then
        return a.friendshipValue > b.friendshipValue
    elseif a.last_contact_time ~= b.last_contact_time then
        return a.last_contact_time > b.last_contact_time
    else
        return false
    end
end

function FriendUI.InitFriendData(contact_type)
    test("contact_type",tostring(contact_type).."---------最近：99，好友：2，黑名单：3，陌生人：0，搜索：100")
    CurFriendList = {}
    CurSelectFriendType = contact_type
    local list = LD.GetContactDataListByType(contact_type)
    if not list then
        test("客户端没有contact_type的玩家数据，返回")
        if UIDefine.FunctionSwitch["QuestionsAnswersElfSwitch"] == "on" then
            if CONTACT_TYPE.contact_recently == contact_type then
                local temp = {
                    priority = 0,
                    name = QuestionsAnswersElf.ElfName,
                    SystemIcon = QuestionsAnswersElf.ElfIcon,
                    status = 1,
                }
                table.insert(CurFriendList,1,temp)
                table.insert(AllCurFriendList,1,temp)
            end
        end
        return
    end

    test("list.Count",list.Count)
    for i = 1, list.Count do
        local data = list[i - 1]
        local Value = 0
        if contact_type == CONTACT_TYPE.contact_friend then
            if LD.IsMyFriend(tostring(data.guid)) then
                local IsValue = tonumber(tostring(LD.GetContactLongCustomData("LikeabilityValue",tostring(data.guid),CONTACT_TYPE.contact_friend)))
                if IsValue ~= nil then
                    Value = IsValue
                end
            end
        end

        local temp = {
            guid = data.guid,
            contact_type = data.contact_type,
            name = data.name,
            role = data.role,
            level = data.level,
            job = data.job,
            friendship = data.friendship,
            last_contact_time = data.last_contact_time,
            status = data.status,
            vip = data.vip,
            reincarnation = data.reincarnation,
            priority = 1,
            friendshipValue = Value,
        }
        if searchBtnStatus == 3 then
            local str = searchContent
            local IsBoolean = string.find(data.name, str)
            if IsBoolean ~= nil then
                CurFriendList[#CurFriendList + 1] = temp
            end
        else
            CurFriendList[#CurFriendList + 1] = temp
            AllCurFriendList[#AllCurFriendList + 1] = temp
        end
    end

    if contact_type ~= CONTACT_TYPE.contact_recently then
        table.sort(CurFriendList, TableSet)
        table.sort(AllCurFriendList, TableSet)
    else
        if UIDefine.FunctionSwitch["QuestionsAnswersElfSwitch"] == "on" then
            local temp = {
                priority = 0,
                name = QuestionsAnswersElf.ElfName,
                SystemIcon = QuestionsAnswersElf.ElfIcon,
                status = 1,
            }
            table.insert(CurFriendList,1,temp)
            table.insert(AllCurFriendList,1,temp)
        end
    end


    test("CurFriendList",inspect(CurFriendList))

end

-----------------------------  界面创建 start -----------------------------------------
function FriendUI.ShowRecentlyPage(contact_type)
    FriendUI.InitFriendData(contact_type)
    local name = "recentlyPage"
    local recentlyPage = _gt.GetUI(name)
    if not recentlyPage then
        local panelBg = _gt.GetUI("panelBg")
        recentlyPage = GUI.GroupCreate(panelBg, name, 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
        _gt.BindName(recentlyPage, "recentlyPage")
        FriendUI.CreateUI(recentlyPage)
    else
        FriendUI.RefreshFriendItem(contact_type)
        GUI.SetVisible(recentlyPage, true)
    end

end

-- 创建UI
function FriendUI.CreateUI(parent)

    --最近按钮
    local latelyBtn = GUI.ButtonCreate(parent, "latelyBtn","1800402032", 79, 53, Transition.None, "", 145, 44, false)
    SetAnchorAndPivot(latelyBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(latelyBtn,"latelyBtn")
    GUI.AddRedPoint(latelyBtn,UIAnchor.TopLeft,5,5,"1800208080")
    GUI.SetRedPointVisable(latelyBtn,false)
    -- 按钮上的文本
    local LatelyTxt = GUI.CreateStatic(latelyBtn,"LatelyTxt","最近",35,3,80,38)
    GUI.StaticSetAlignment(LatelyTxt,TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(LatelyTxt,24)
    GUI.SetColor(LatelyTxt,colorDark)
    --点击事件
    GUI.RegisterUIEvent(latelyBtn,UCE.PointerClick,"FriendUI","OnRecentlyPageBtnClick")

    --联系人按钮
    local contactsBtn = GUI.ButtonCreate(parent, "contactsBtn","1800402030", 223, 53, Transition.None, "", 145, 44, false)
    SetAnchorAndPivot(contactsBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(contactsBtn,"contactsBtn")
    GUI.AddRedPoint(contactsBtn,UIAnchor.TopLeft,5,5,"1800208080")
    GUI.SetRedPointVisable(contactsBtn,false)
    -- 按钮上的文本
    local ContactsTxt = GUI.CreateStatic(contactsBtn,"ContactsTxt","联系人",35,3,80,38)
    GUI.StaticSetAlignment(ContactsTxt,TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(ContactsTxt,24)
    GUI.SetColor(ContactsTxt,colorDark)

    _gt.BindName(contactsBtn,"contactsBtn")
    --点击事件
    GUI.RegisterUIEvent(contactsBtn,UCE.PointerClick,"FriendUI","OnFriendPageBtnClick")



    -- 背景
    local contactListBg = GUI.ImageCreate(parent, "contactListBg", "1800400200", 80, 92, false, 290, 480)
    SetAnchorAndPivot(contactListBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 最近
    local latelyPage = GUI.GroupCreate(contactListBg,
            "latelyPage",
            5,
            50,
            285,
            500,
            false
    )
    _gt.BindName(latelyPage, "latelyPage")
    GUI.SetAnchor(latelyPage, UIAnchor.TopLeft)
    GUI.SetPivot(latelyPage, UIAroundPivot.TopLeft)
    FriendUI.CreateLatelyPage(latelyPage)
    GUI.SetVisible(latelyPage, true)

    -- 联系人
    local contactPage = GUI.GroupCreate(contactListBg,
            "contactPage",
            0,
            50,
            285,
            500,
            false
    )
    _gt.BindName(contactPage, "contactPage")
    GUI.SetAnchor(contactPage, UIAnchor.TopLeft)
    GUI.SetPivot(contactPage, UIAroundPivot.TopLeft)
    FriendUI.CreateContactPage(contactPage)
    GUI.SetVisible(contactPage, true)

    -- 输入框
    local searchInput = GUI.EditCreate(contactListBg, "searchInput", "1800001040", "搜索名称", 2, 5,  10,5,Transition.ColorTint,"system", 236, 50)
    _gt.BindName(searchInput, "searchInput")
    SetAnchorAndPivot(searchInput, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.EditSetLabelAlignment(searchInput, TextAnchor.MiddleLeft)
    GUI.EditSetTextColor(searchInput, colorDark)
    GUI.EditSetFontSize(searchInput, fontSizeDefault)
    GUI.SetPlaceholderTxtColor(searchInput, colorGray)
    GUI.EditSetPlaceholderAlignment(searchInput, TextAnchor.MiddleLeft)
    GUI.RegisterUIEvent(searchInput, UCE.EndEdit, "FriendUI", "OnSearchInputChange")

    -- 搜索按钮
    local searchBtn = GUI.ButtonCreate(searchInput, "searchBtn", "1800802010", 42, 0, Transition.ColorTint, "")
    SetAnchorAndPivot(searchBtn, UIAnchor.Right, UIAroundPivot.Right)
    GUI.RegisterUIEvent(searchBtn, UCE.PointerClick, "FriendUI", "OnSearchBtnClick")

    local RecBtn = GUI.ButtonCreate( parent, "recBtn", "1800402110", 78, -38, Transition.ColorTint, "",125,45,false)
    SetAnchorAndPivot(RecBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    -- 按钮上的文本
    local RecTxt = GUI.CreateStatic(RecBtn,"rectxt","推荐好友",5,0,120,44)
    GUI.StaticSetAlignment(RecTxt,TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(RecTxt,24)
    GUI.SetColor(RecTxt,colorDark)
    -- 按钮点击事件
    GUI.RegisterUIEvent(RecBtn , UCE.PointerClick , "FriendUI", "OnJumpToBtnClick");

    local SetBtn = GUI.ButtonCreate( parent, "SetBtn", "1800402110", 245, -38, Transition.ColorTint, "",125,45,false)
    SetAnchorAndPivot(SetBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    -- 按钮上的文本
    local SetTxt = GUI.CreateStatic(SetBtn,"rectxt","系统设置",4,0,120,44)
    GUI.StaticSetAlignment(SetTxt,TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(SetTxt,24)
    GUI.SetColor(SetTxt,colorDark)
    -- 按钮点击事件
    GUI.RegisterUIEvent(SetBtn , UCE.PointerClick , "FriendUI", "OnSettingBtnClick");

    -- 帮助精灵
    local helperBg = GUI.ImageCreate(parent, "helperBg", "1800201200", 385, 60, false, 730, 560)
    SetAnchorAndPivot(helperBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local sprite = GUI.ImageCreate(helperBg, "sprite", "1800228220", 110, 180)
    SetAnchorAndPivot(sprite, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local dialogBg = GUI.ImageCreate(helperBg, "dialogBg", "1800201210", 250, 45)
    SetAnchorAndPivot(dialogBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local dialog = GUI.CreateStatic(dialogBg, "dialog", "在左侧点击你要聊天的对象", 0, 0, 300, 30, "system", true, false)
    SetAnchorAndPivot(dialog, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(dialog, fontSizeDefault)
    GUI.StaticSetAlignment(dialog, TextAnchor.MiddleCenter)
    GUI.SetColor(dialog, colorDark)

    -- 好感度
    local friendshipImg = GUI.ImageCreate(parent, "friendshipImg", "1800208180", 390, 585)
    _gt.BindName(friendshipImg, "friendshipImg")
    SetAnchorAndPivot(friendshipImg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(friendshipImg, false)

    local friendshipText = GUI.CreateStatic(parent, "friendshipText", "", 424, 583, 250, 30, "system", true, false)
    _gt.BindName(friendshipText, "friendshipText")
    SetAnchorAndPivot(friendshipText, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(friendshipText, fontSizeDefault)
    GUI.StaticSetAlignment(friendshipText, TextAnchor.MiddleLeft)
    GUI.SetColor(friendshipText, colorDark)
    GUI.SetVisible(friendshipText, false)

    -- 加为好友
    local addFriendBtn = GUI.ButtonCreate(parent, "addFriendBtn", "1800402110", -80, -35, Transition.ColorTint, "加为好友", 130, 44, false)
    _gt.BindName(addFriendBtn, "addFriendBtn")
    SetAnchorAndPivot(addFriendBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.ButtonSetTextFontSize(addFriendBtn, fontSizeBigger)
    GUI.ButtonSetTextColor(addFriendBtn, colorDark)
    GUI.RegisterUIEvent(addFriendBtn, UCE.PointerClick, "FriendUI", "OnAddFriendBtnClick")
    GUI.SetVisible(addFriendBtn, false)

    -- 聊天框
    local chatBg = GUI.ImageCreate(parent, "chatBg", "1800400200", 385, 110, false, 730, 465)
    SetAnchorAndPivot(chatBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(chatBg, false)
    _gt.BindName(chatBg, "chatBg")

    local chatScroll = GUI.LoopListCreate(
            chatBg,
            "chatScroll",
            0,
            0,
            700,
            455,
            "FriendUI",
            "CreateChatBox",
            "FriendUI",
            "OnRefreshChatMsg",
            0,
            false,
            Vector2.New(600, 100),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft
    )
    _gt.BindName(chatScroll, "chatScroll")
    SetAnchorAndPivot(chatScroll, UIAnchor.Center, UIAroundPivot.Center)
    GUI.ScrollRectSetChildSpacing(chatScroll, Vector2.New(0, 5))
    GUI.LoopScrollRectSetSynchRefresh(chatScroll, true)
    GUI.SetVisible(chatScroll,true)
    chatScroll:RegisterEvent(UCE.PointerClick)

    local ElfChatScroll = GUI.LoopListCreate(
            chatBg,
            "ElfChatScroll",
            0,
            0,
            700,
            455,
            "FriendUI",
            "CreateElfChatBox",
            "FriendUI",
            "OnRefreshElfChatMsg",
            0,
            false,
            Vector2.New(600, 100),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft
    )
    _gt.BindName(ElfChatScroll, "ElfChatScroll")
    SetAnchorAndPivot(ElfChatScroll, UIAnchor.Center, UIAroundPivot.Center)
    GUI.ScrollRectSetChildSpacing(ElfChatScroll, Vector2.New(0, 5))
    GUI.LoopScrollRectSetSynchRefresh(ElfChatScroll, true)
    ElfChatScroll:RegisterEvent(UCE.PointerClick)
    GUI.SetVisible(ElfChatScroll,false)

    -- 语音输入按钮
    local voiceInputBtn = GUI.ButtonCreate(parent, "voiceInputBtn", "1800902020", 386, 58, Transition.ColorTint, "", 46, 44, false)
    SetAnchorAndPivot(voiceInputBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(voiceInputBtn,"voiceInputBtn")
    voiceInputBtn:RegisterEvent(UCE.PointerUp)
    voiceInputBtn:RegisterEvent(UCE.PointerEnter)
    voiceInputBtn:RegisterEvent(UCE.PointerExit)
    voiceInputBtn:RegisterEvent(UCE.PointerDown)
    GUI.RegisterUIEvent(voiceInputBtn, UCE.PointerDown, "FriendUI", "OnVoiceInputBtnDown")
    GUI.RegisterUIEvent(voiceInputBtn, UCE.PointerUp, "ChatUI", "OnRecordBtnPointUp")
    GUI.RegisterUIEvent(voiceInputBtn, UCE.PointerEnter, "ChatUI", "OnRecordBtnPointEnter")
    GUI.RegisterUIEvent(voiceInputBtn, UCE.PointerExit, "ChatUI", "OnRecordBtnPointExit")
    GUI.SetVisible(voiceInputBtn, false)

    -- 聊天输入
    local input = GUI.EditCreate(parent, "input", "1800001040", "输入聊天内容", 448, 58,12,8, Transition.ColorTint, "system", 470, 48,  InputType.Standard)
    _gt.BindName(input, "input")
    SetAnchorAndPivot(input, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.EditSetLabelAlignment(input, TextAnchor.MiddleLeft)
    GUI.EditSetTextColor(input, colorDark)
    GUI.EditSetFontSize(input, fontSizeDefault)
    GUI.SetPlaceholderTxtColor(input, colorGray)
    GUI.EditSetPlaceholderAlignment(input, TextAnchor.MiddleLeft)
    GUI.EditSetMaxCharNum(input, 200)
    GUI.SetVisible(input, false)
    GUI.RegisterUIEvent(input, UCE.PointerClick, "FriendUI", "OnInputeClick")

    -- 表情输入
    local emojiInputBtn = GUI.ButtonCreate(parent, "emojiInputBtn", "1800902010", 920, 58, Transition.ColorTint, "")
    SetAnchorAndPivot(emojiInputBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(emojiInputBtn, UCE.PointerClick, "FriendUI", "OnEmojiInputBtnClick")
    GUI.SetVisible(emojiInputBtn, false)

    -- 清空输入
    local clearChatContentBtn = GUI.ButtonCreate(parent,"clearChatContentBtn", "1800202350", 970, 58,  Transition.ColorTint, "")
    SetAnchorAndPivot(clearChatContentBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(clearChatContentBtn, UCE.PointerClick , "FriendUI", "OnClearChatContentBtnClick")
    GUI.SetVisible(clearChatContentBtn, false)

    -- 发送
    local sendBtn = GUI.ButtonCreate(parent, "sendBtn", "1800402110", 1030, 58, Transition.ColorTint, "发送", 84, 46, false)
    SetAnchorAndPivot(sendBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(sendBtn, fontSizeBigger)
    GUI.ButtonSetTextColor(sendBtn, colorDark)
    GUI.RegisterUIEvent(sendBtn, UCE.PointerClick, "FriendUI", "OnSendBtnClick")
    GUI.SetVisible(sendBtn, false)
end

-- 语音聊天被点击
function FriendUI.OnVoiceInputBtnDown(guid)
    if FriendUI.SelectedRoleGuid == "1" then
        CL.SendNotify(NOTIFY.ShowBBMsg,"抱歉，小精灵现在还不支持语音识别哦")
    else
        FriendUI.SendRecordTargetGuid = FriendUI.SelectedRoleGuid
        GlobalUtils.StartRecord()
    end

end

-- 好友聊天系统设置
function FriendUI.OnSettingBtnClick(key, guid)

    local UI = GUI.GetWnd("FriendSystemSettingUI")
    if UI == nil then
        GUI.OpenWnd("FriendSystemSettingUI")
    else
        local wnd = GUI.GetWnd("FriendSystemSettingUI")
        if wnd ~= nil then
            GUI.SetVisible(wnd, true)
        end
    end
end

-- 联系人类型列表
function FriendUI.CreateContactPage(parent)
    local contactTypeListScroll  = GUI.ScrollListCreate(parent,"contactTypeListScroll", 1, 2, 288, 420, false,  UIAroundPivot.Top, UIAnchor.Top)
    GUI.SetAnchor(contactTypeListScroll, UIAnchor.TopLeft)
    GUI.SetPivot(contactTypeListScroll, UIAroundPivot.TopLeft)
    _gt.BindName(contactTypeListScroll,"contactTypeListScroll")
    GUI.SetVisible(contactTypeListScroll,false)
    FriendUI.contactTypeListScroll =contactTypeListScroll
    for i = 1, #contactTypeList do
        local data = contactTypeList[i]
        local typeName = data[3]

        local listTypeBtn = GUI.ButtonCreate(contactTypeListScroll,data[2] .. "Btn", "1800201150", 0, 0,  Transition.ColorTint, typeName, 284, 40, false)
        GUI.SetAnchor(listTypeBtn,UIAnchor.Top)
        GUI.SetPivot(listTypeBtn,UIAroundPivot.Top)
        GUI.ButtonSetTextFontSize(listTypeBtn, fontSizeDefault)
        GUI.SetPreferredHeight(listTypeBtn, 40)
        GUI.ButtonSetTextColor(listTypeBtn, colorDark)
        GUI.RegisterUIEvent(listTypeBtn , UCE.PointerClick , "FriendUI", "OnListTypeBtnClick")
        GUI.SetData(listTypeBtn, "index", i)

        local mark = GUI.ImageCreate(listTypeBtn,"mark", "1800208160", -30, 0 )
        GUI.SetAnchor(mark, UIAnchor.Right)
        GUI.SetPivot(mark, UIAroundPivot.Right)
        if i == 1 then
            GUI.SetEulerAngles(mark, Vector3.New(180, 0, 0))
        end

        -- 子节点列表框
        local listType  = GUI.ListCreate(contactTypeListScroll, data[2], 0, 0, 284, 300, false, false)
        GUI.SetAnchor(listType, UIAnchor.Top)
        GUI.SetPivot(listType, UIAroundPivot.Top)
        GUI.SetVisible(listType, i == 1) --false就能收起好友列表
        _gt.BindName(listType,data[2])
        GUI.SetPaddingHorizontal(listType, Vector2.New(2,0))
        FriendUI.ShowContactItems(2,i)
        FriendUI.RefreshFriendList(listType)
    end
end

-- 显示联系人
function FriendUI.ShowContactItems(listTpye,index)
    if listTpye == 1 then
        FriendUI.ShowRecentlyList()
    elseif listTpye == 2 then
        if index == 1 then
            FriendUI.ShowFriendList()
        elseif index == 2 then
            FriendUI.ShowStrangerList()
        elseif index == 3 then
            FriendUI.ShowBlackList()
        end
    end
    -- 刷新好感度
    FriendUI.ShowFriendship()
end

function FriendUI.OnJumpToBtnClick()
    GUI.OpenWnd("FriendShipRecommend",1)
end

--最近列表
function FriendUI.CreateLatelyPage(parent)
    local latelyScrollWnd = GUI.ScrollRectCreate(parent,"latelyScrollWnd", -4, 1, 284, 420, 0, false, Vector2.New(280, 100))
    GUI.SetAnchor(latelyScrollWnd, UIAnchor.TopLeft)
    GUI.SetPivot(latelyScrollWnd, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildAnchor(latelyScrollWnd, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(latelyScrollWnd, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(latelyScrollWnd, Vector2.New(0, 0))
    _gt.BindName(latelyScrollWnd,"latelyScrollWnd")
    FriendUI.ShowContactItems(1,0)
    FriendUI.RefreshFriendList(latelyScrollWnd)
end

--联系人列表好友，陌生人，黑名单点击事件
function FriendUI.OnListTypeBtnClick(guid)
    test("联系人列表好友，陌生人，黑名单点击事件")
    local listTypeBtn =GUI.GetByGuid(guid)

    if listTypeBtn == nil then
        return
    end
    local mark = GUI.GetChild(listTypeBtn, "mark")
    local contactTypeListScroll = GUI.GetParentElement(listTypeBtn)
    if contactTypeListScroll == nil then
        return
    end

    local index = tonumber(GUI.GetData(listTypeBtn, "index"))


    if index == 1 then
        test("好友请求数据")
        CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_friend)
    elseif index == 2 then
        test("陌生人请求数据")
        CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_stranger)
    elseif index == 3 then
        test("黑名单请求数据")
        CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_blacklist)
    end

    local data = contactTypeList[index]
    local list = GUI.GetChild(contactTypeListScroll, data[2])

    if list ~= nil then
        local isVisible = GUI.GetVisible(list)
        GUI.SetVisible(list, isVisible == false)

        if isVisible then
            GUI.SetEulerAngles(mark, Vector3.New(0, 0, 0))
        else
            GUI.SetEulerAngles(mark, Vector3.New(180, 0, 0))
        end
    end
end

function FriendUI.ShowRecentlyList()
    FriendUI.InitFriendData(CONTACT_TYPE.contact_recently)
end

function FriendUI.ShowFriendList()
    FriendUI.InitFriendData(CONTACT_TYPE.contact_friend)
end

function FriendUI.ShowStrangerList()
    FriendUI.InitFriendData(CONTACT_TYPE.contact_stranger)
end

function FriendUI.ShowBlackList()
    FriendUI.InitFriendData(CONTACT_TYPE.contact_blacklist)
end

--好友列表刷新
function FriendUI.RefreshFriendList(parent)
    test("好友列表刷新")
    if #CurFriendList > 0 then
        for i = 1, #CurFriendList do

            local contactInfo = CurFriendList[i]
            local contactItem = GUI.GetChildByIndex(parent, i - 1)
            if not contactItem then
                contactItem = FriendUI.CreateContactItem(parent,i)
            else
                GUI.SetVisible(contactItem, true)
            end
            local friendicon = GUI.GetChild(contactItem, "friendicon")
            local friendlevel = GUI.GetChild(friendicon, "friendlevel")
            local friendname = GUI.GetChild(contactItem, "friendname")
            local friendschoolMark = GUI.GetChild(contactItem, "friendschoolMark")
            local friendloginInfo = GUI.GetChild(contactItem, "friendloginInfo")
            local friendoperateBtn = GUI.GetChild(contactItem, "friendoperateBtn")
            local guid = GUI.GetGuid(contactItem)
            local priority = tonumber(contactInfo.priority)
            if priority == 0 then
                GUI.ImageSetImageID(friendicon,contactInfo.SystemIcon)
                GUI.SetVisible(friendoperateBtn,false)
                GUI.SetVisible(friendschoolMark,false)
                GUI.SetVisible(friendlevel,false)
                GUI.SetVisible(friendloginInfo,false)
                GUI.StaticSetText(friendname, contactInfo.name)
                GUI.StaticSetFontSize(friendname,QuestionsAnswersElf.ElfNameFontSize)
                GUI.SetPositionX(friendname,QuestionsAnswersElf.ElfNameFontX)
                GUI.SetPositionY(friendname,QuestionsAnswersElf.ElfNameFontY)
                ElfItemGuid = tostring(GUI.GetGuid(contactItem))
                GUI.SetColor(friendname, QuestionsAnswersElf.ElfNameColor)

                local IconBg = GUI.GetChild(contactItem, "friendiconBg",false)
                GUI.ImageSetImageID(IconBg,UIDefine.ItemIconBg[QuestionsAnswersElf.ElfItemIconBg])
                local ElfIdentification = GUI.ImageCreate(friendicon,"ElfIdentification",
                        QuestionsAnswersElf.ElfIdentificationIcon,
                        QuestionsAnswersElf.ElfIdentificationIconX,
                        QuestionsAnswersElf.ElfIdentificationIconY,
                        false,
                        QuestionsAnswersElf.ElfIdentificationIconW,
                        QuestionsAnswersElf.ElfIdentificationIconH,
                        false
                )
                SetAnchorAndPivot(ElfIdentification, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            else
                local roleGuid = tostring(contactInfo.guid)
                local now_time = tonumber(CL.GetServerTickCount())
                local logout_time = tonumber(tostring(LD.GetContactLongCustomData("__last_logout_time", tostring(contactInfo.guid), contactInfo.contact_type)))
                local outline_time = now_time - logout_time
                local time =tostring(GlobalUtils.GetPassTimeDesc(outline_time))

                GUI.SetColor(friendname, colorDark)
                GUI.CheckBoxExSetCheck(contactItem, false)
                if FriendRedTable[roleGuid] == true then
                    GUI.SetRedPointVisable(friendicon,true)
                else
                    GUI.SetRedPointVisable(friendicon,false)
                end

                if CurSelectFriendType == CONTACT_TYPE.contact_recently then
                    ClickFriendTypeList1[tostring(contactInfo.guid)] = tostring(GUI.GetGuid(contactItem))
                else
                    ClickFriendTypeList2[tostring(contactInfo.guid)] = tostring(GUI.GetGuid(contactItem))
                end
                local temp = {
                    name = tostring(contactInfo.name),
                    status = tostring(contactInfo.status),
                }
                GUI.SetData(contactItem,"RoleGuid",tostring(contactInfo.guid))
                ItemGuid2RoleGuid[tostring(GUI.GetGuid(contactItem))] = tostring(contactInfo.guid)
                ItemGuid3RoleGuid[tostring(GUI.GetGuid(friendoperateBtn))] = temp
                GUI.SetData(friendoperateBtn,"friendoperateBtnData",roleGuid)
                local isChecked = roleGuid == FriendUI.SelectedRoleGuid
                GUI.CheckBoxExSetCheck(contactItem, isChecked)
                if isChecked then
                    -- 选中的刷新右边聊天栏
                    FriendUI.SetSelect(FriendUI.SelectedRoleGuid)
                    SelectFriendItemGuid = tostring(guid)
                    if CurSelectBtn == 1 then
                        SelectFriendItemGuid1 = tostring(guid)
                    end
                    if CurSelectBtn == 2 then
                        SelectFriendItemGuid2 = tostring(guid)
                    end
                end

                local role = DB.GetRole(tonumber(contactInfo.role))
                if role ~= nil then
                    GUI.ImageSetImageID(friendicon, tostring(role.Head))
                end
                local status = tonumber(contactInfo.status)
                if  status == 1 then
                    GUI.StaticSetText(friendloginInfo,"在线")
                    GUI.SetColor(friendloginInfo,colorGreen)
                    GUI.CheckBoxExSetBgImageId(contactItem,"1800800030")
                    GUI.ImageSetGray(friendicon, false)
                else
                    GUI.StaticSetText(friendloginInfo,time)
                    GUI.SetColor(friendloginInfo,colorRed)
                    GUI.CheckBoxExSetBgImageId(contactItem,"1800200070")
                    GUI.ImageSetGray(friendicon, true)
                end
                GUI.StaticSetText(friendname, contactInfo.name)
                GUI.SetColor(friendname, colorDark)
                GUI.StaticSetText(friendlevel, contactInfo.level)
                local school = DB.GetSchool(tonumber(contactInfo.job))
                GUI.SetVisible(friendschoolMark, true)
                if school ~= nil then
                    GUI.ImageSetImageID(friendschoolMark, tostring(school.Icon))
                end
                GUI.SetVisible(friendoperateBtn, true)

                HeadIcon.BindRoleVipLv(friendicon, contactInfo.vip or 0)
            end

            local childCount = GUI.GetChildCount(parent)
            for i = #CurFriendList + 1, childCount do
                local item = GUI.GetChildByIndex(parent, i - 1)
                GUI.SetVisible(item, false)
            end

            if CurSelectBtn == 1 then
                if SelectFriendItemGuid1 ~= nil and FriendShipRecommendData ~= nil then
                    local RoleGuid = ItemGuid2RoleGuid[SelectFriendItemGuid1]
                    local ItemGuid1 = ClickFriendTypeList1[tostring(RoleGuid)]
                    FriendUI.OnContactItemClick(ItemGuid1)
                end
            end
            if CurSelectBtn == 2 then
                if SelectFriendItemGuid2 ~= nil and FriendShipRecommendData ~= nil then
                    local RoleGuid = ItemGuid2RoleGuid[SelectFriendItemGuid2]
                    local ItemGuid1 = ClickFriendTypeList2[tostring(RoleGuid)]
                    FriendUI.OnContactItemClick(ItemGuid1)
                end
            end
            GUI.SetData(contactItem,"ItemPriority",priority)
        end
    else
        local ChildCount = GUI.GetChildCount(parent)
        if ChildCount > 0 then
            for i = 1, ChildCount do
                local ChildItem = GUI.GetChild(parent,"ContactItem"..i,false)
                GUI.Destroy(ChildItem)
            end
        end

    end
end

-- 创建操作菜单
function FriendUI.CreateMenu(guid,RoleGuid)
    test("创建操作菜单")
    local AreaItemGuid = ItemGuid3RoleGuid[guid]
    AreaItemName = AreaItemGuid.name --人物名称
    AreaItemStatus = AreaItemGuid.status --人物是否在线
    local name = "operateMenuCover"
    local operateMenuCover = _gt.GetUI(name)
    if operateMenuCover then
        GUI.SetVisible(operateMenuCover, true)
        return
    end
    local panel = GUI.GetWnd("FriendUI")
    -- 整块不透明背景
    operateMenuCover = GUI.ImageCreate(panel, name, "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    _gt.BindName(operateMenuCover, name)
    SetAnchorAndPivot(operateMenuCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(operateMenuCover, colorInvisibility)
    operateMenuCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(operateMenuCover, true)
    GUI.RegisterUIEvent(operateMenuCover, UCE.PointerClick, "FriendUI", "OnOperateMenuCoverClick")

    local infoBg = GUI.ImageCreate(operateMenuCover, "infoBg", "1800400290", -170, 50, false, 130, 312)
    SetAnchorAndPivot(infoBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(infoBg,"mainInfo")
    --infoBg:RegisterEvent(UCE.PointerClick)

    for i = 1, #btnList do
        local posY = 10 + (i - 1) * 50
        local btn = GUI.ButtonCreate(infoBg, btnList[i][2], "1800402110", 0, posY, Transition.ColorTint, "", 120, 45, false)
        SetAnchorAndPivot(btn, UIAnchor.Top, UIAroundPivot.Top)
        GUI.ButtonSetText(btn,btnList[i][1])
        if i == #btnList then
            GUI.ButtonSetTextFontSize(btn, fontSizeDefault)
        else
            GUI.ButtonSetTextFontSize(btn, fontSizeBigger)
        end
        GUI.ButtonSetTextColor(btn, colorBtn)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "FriendUI", btnList[i][3])
    end

end

function FriendUI.OnInputeClick()
    local EmojPanelUI = GUI.GetWnd("EmojPanelUI")
    if EmojPanelUI ~= nil and GUI.GetVisible(EmojPanelUI) then
        GUI.CloseWnd("EmojPanelUI")
    end
end

-- 创建对话
function FriendUI.CreateChatBox()
    local chatScroll = _gt.GetUI("chatScroll") --GUI.Get(pageNames[1][2] .. "/chatBg/chatScroll")
    local chatBoxBg = GUI.LoopListChatCreate(chatScroll, "chatBoxBg", "1800400200", 0, 10)
    SetAnchorAndPivot(chatBoxBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetColor(chatBoxBg, Color.New(1, 1, 1, 0))
    GUI.LoopListChatSetPreferredWidth(chatBoxBg, 700)
    GUI.LoopListChatSetPreferredHeight(chatBoxBg, 78)

    -- 头像
    local icon = GUI.ItemCtrlCreate(chatBoxBg, "icon", "1800400050", 0, 0, 80, 80)
    SetAnchorAndPivot(icon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, "1900300010")
    local iconSprite = GUI.ItemCtrlGetElement(icon, eItemIconElement.Icon)
    GUI.SetPositionX(iconSprite,0)
    GUI.SetPositionY(iconSprite,-1)
    GUI.SetWidth(iconSprite, 69)
    GUI.SetHeight(iconSprite, 69)
    HeadIcon.CreateVip(icon, 60, 60, -5, 5)

    local cutLineLeft = GUI.ImageCreate(chatBoxBg, "cutLineLeft", "1800207080", 40, 0)
    SetAnchorAndPivot(cutLineLeft, UIAnchor.Left, UIAroundPivot.Left)

    local cutLineRight = GUI.ImageCreate(chatBoxBg, "cutLineRight", "1800207090", -40, 0)
    SetAnchorAndPivot(cutLineRight, UIAnchor.Right, UIAroundPivot.Right)

    local sysMsgTxt = GUI.CreateStatic(chatBoxBg, "sysMsgTxt", "", 0, 0, 250, 50)
    SetAnchorAndPivot(sysMsgTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(sysMsgTxt, fontSizeSmaller)
    GUI.SetColor(sysMsgTxt, ColorSys)
    GUI.StaticSetAlignment(sysMsgTxt, TextAnchor.MiddleCenter)

    -- 聊天文字底图
    local msgTxtBg = GUI.ImageCreate(chatBoxBg, "msgTxtBg", "1800900020", 82, 0, false, 500, 60)
    SetAnchorAndPivot(msgTxtBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 聊天内容
    local msgTxt = GUI.RichEditCreate(chatBoxBg, "msgTxt", "", 102, 15, 470, 30)
    SetAnchorAndPivot(msgTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(msgTxt, fontSizeSmaller)
    GUI.SetColor(msgTxt, colorDark)
    local recordGroup = GUI.GroupCreate(chatBoxBg, "recordGroup", 0, 30, 200, 80)
    SetAnchorAndPivot(recordGroup, UIAnchor.Top, UIAroundPivot.Top)

    msgTxt:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(msgTxt, UCE.PointerClick, "FriendUI", "OnUrlClick_RichTxt")
    GUI.SetVisible(chatBoxBg, false)
    return chatBoxBg
end

-- 更新聊天信息
function FriendUI.OnRefreshChatMsg(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])

    local chatBoxBg = GUI.GetByGuid(guid)
    local icon = GUI.GetChild(chatBoxBg, "icon")
    local iconSprite = GUI.ItemCtrlGetElement(icon, eItemIconElement.Icon)
    local msgTxtBg = GUI.GetChild(chatBoxBg, "msgTxtBg")
    local msgTxt = GUI.GetChild(chatBoxBg, "msgTxt")
    local cutLineLeft = GUI.GetChild(chatBoxBg, "cutLineLeft")
    local cutLineRight = GUI.GetChild(chatBoxBg, "cutLineRight")
    local sysMsgTxt = GUI.GetChild(chatBoxBg, "sysMsgTxt")
    local recordGroup = GUI.GetChild(chatBoxBg, "recordGroup")
    local guid = nil
    local message = nil
    local roleType = nil

    local messageInfo = LD.GetFriendMessagesByGuid(FriendUI.SelectedRoleGuid)
    if messageInfo == nil or ((index + 1) > messageInfo.Count) then
        GUI.SetVisible(chatBoxBg, false)
        return
    end

    -- 获取对应的消息
    local msgIndex = messageInfo.Count - index - 1
    if msgIndex < 0 then
        msgIndex = 0
    end
    local msgData = messageInfo[msgIndex]

    if msgData == nil then
        GUI.SetVisible(chatBoxBg, false)
        return
    end

    guid = msgData.send_guid
    local isSelf = (guid == LD.GetSelfGUID())
    message = msgData.message
    roleType = CurSelectFriendData and CurSelectFriendData.role or 1
    local is_show = msgData.is_show

    GUI.LoopListChatSetPreferredWidth(chatBoxBg, 700)
    GUI.SetVisible(icon, not is_show)
    GUI.SetVisible(msgTxtBg, not is_show)
    GUI.SetVisible(msgTxt, not is_show)
    GUI.SetVisible(cutLineLeft, is_show)
    GUI.SetVisible(cutLineRight, is_show)
    GUI.SetVisible(sysMsgTxt, is_show)

    local isRecord = false
    local fileName, time = nil, nil

    isRecord, fileName, time = ChatUI.ExchangeRecordMsg(message)

    -- 显示聊天记录、上次聊天时间等内容
    if is_show then
        GUI.StaticSetText(msgTxt, message)
        GUI.StaticSetText(sysMsgTxt, message)
        local isChatRecord = msgData.send_guid == uint64.zero --"chatRecord"
        GUI.SetVisible(cutLineLeft, isChatRecord)
        GUI.SetVisible(cutLineRight, isChatRecord)

        if isChatRecord then
            GUI.SetColor(sysMsgTxt, ColorSys)
            GUI.StaticSetFontSize(sysMsgTxt, 20)
        else
            GUI.SetColor(sysMsgTxt, colorDark)
            GUI.StaticSetFontSize(sysMsgTxt, fontSizeDefault)
        end
    else
        if not isSelf then
            SetAnchorAndPivot(chatBoxBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetPositionX(chatBoxBg, 80)

            -- 图标设置
            local role = nil
            if roleType ~= 1 then
                role = DB.GetRole(roleType)
            end

            SetAnchorAndPivot(icon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            HeadIcon.BindRoleVipLv(icon, CurSelectFriendData and CurSelectFriendData.vip or 0)
            if role ~= nil then
                GUI.ImageSetImageID(iconSprite, tostring(role.Head))
            else
                GUI.ImageSetImageID(iconSprite, "1800209010")
            end

            -- 聊天背景内容设置
            SetAnchorAndPivot(msgTxtBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetPositionX(msgTxtBg, 82)
            GUI.SetPositionY(msgTxtBg, 5)
            GUI.SetScale(msgTxtBg, Vector3.New(1, 1, 1))

            -- 聊天内容设置
            SetAnchorAndPivot(msgTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetPositionX(msgTxt, 112)
            GUI.SetPositionY(msgTxt, 18)
            GUI.SetWidth(msgTxt, 500)

            if not isRecord then
                GUI.StaticSetText(msgTxt, message)
            end
        else
            -- 图标设置
            local templateId = CL.GetRoleTemplateID()
            local role = DB.GetRole(templateId)
            SetAnchorAndPivot(icon, UIAnchor.TopRight, UIAroundPivot.TopRight)
            HeadIcon.BindRoleVipLv(icon, tostring(CL.GetAttr(RoleAttr.RoleAttrVip)) or 0)
            if role ~= nil then
                GUI.ImageSetImageID(iconSprite, tostring(role.Head))
            else
                GUI.ImageSetImageID(iconSprite, "1800209010")
            end

            -- 聊天背景设置
            SetAnchorAndPivot(msgTxtBg, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.SetScale(msgTxtBg, Vector3.New(-1, 1, 1))

            -- 聊天内容
            SetAnchorAndPivot(msgTxt, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.SetPositionX(msgTxt, 102)
            GUI.SetPositionY(msgTxt, 18)
            GUI.SetWidth(msgTxt, 500)

            if not isRecord then
                GUI.StaticSetText(msgTxt, message)
            end

            local width = GUI.RichEditGetPreferredWidth(msgTxt)
            if width > 500 then
                width = 500
            end
            GUI.SetPositionX(msgTxtBg, 82 + width + 40)
            GUI.SetPositionY(msgTxtBg, 5)
        end

        --test("聊天内容message",tostring(message))
    end
    local width = GUI.RichEditGetPreferredWidth(msgTxt)
    if width > 500 then
        width = 500
    end

    GUI.SetWidth(msgTxt, width)
    GUI.SetWidth(msgTxtBg, width + 40)
    local height = GUI.RichEditGetPreferredHeight(msgTxt)
    GUI.SetHeight(msgTxt, height)
    GUI.SetHeight(msgTxtBg, height + 30)
    if is_show then
        GUI.LoopListChatSetPreferredHeight(chatBoxBg, 35)
    else
        GUI.LoopListChatSetPreferredHeight(chatBoxBg, height + 60)
    end

    --如果是消息内容(即不是"时间"或"以上是聊天记录")
    if not is_show then
        --看它是不是语音.是语音则不显示解析文字.
        GUI.SetVisible(msgTxt, not isRecord)
    end

    if not isRecord then
        GUI.StaticSetText(msgTxt, message)
        if recordGroup ~= nil then
            GUI.SetVisible(recordGroup, false)
        end
        UILayout.SetUrlColor(msgTxt, false)
    else
        if recordGroup ~= nil then
            GUI.SetVisible(recordGroup, true)
            GUI.SetWidth(msgTxtBg, 200)
            GUI.SetHeight(msgTxtBg, 60)
            if isSelf then
                GUI.SetPositionX(recordGroup, 145)
                GUI.SetPositionY(recordGroup, 4)
                GUI.SetPositionX(msgTxtBg, 282)
            else
                GUI.SetPositionX(recordGroup, -183)
                GUI.SetPositionY(recordGroup, 4)
            end
        end
        FriendUI.CreateRecord(true, chatBoxBg, recordGroup, fileName, time, isSelf)
    end
end

function FriendUI.CreateRecord(isShow, parent, recordGroup, fileName, time, isSelf)
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

    local time = math.ceil(tonumber(time))
    if time ~= nil then
        if time > 15 then

        end
        GUI.ButtonSetText(recordBtn, time .. "秒")
        GUI.SetData(recordGroup, "RecordTime", time)
    else
        GUI.ButtonSetText(recordBtn, "0秒")
    end
end

-- 显示邮件页面
function FriendUI.ShowEmailPage()
    FriendUI.OnExit()
    GUI.OpenWnd("MailUI",FriendRedIsShow)
end

-----------------------------  界面创建 end -----------------------------------------

-----------------------------  功能函数 start -----------------------------------------

-- 联系人消息更新
function FriendUI.OnContactMessageUpdate(targetId)
    test("联系人消息更新")
    if tostring(FriendUI.SelectedRoleGuid) == tostring(targetId) then
        local chatScroll = _gt.GetUI("chatScroll")
        local msgData = LD.GetFriendMessagesByGuid(FriendUI.SelectedRoleGuid) -- TODO: 获取聊天信息
        if not msgData then
            GUI.LoopScrollRectSetTotalCount(chatScroll, 0)
        else
            GUI.LoopScrollRectSetTotalCount(chatScroll, msgData.Count)
        end
        GUI.LoopScrollRectRefreshCells(chatScroll)
    end
end

-- 显示好感度
function FriendUI.ShowFriendship(guid)
    local friendshipImg = _gt.GetUI("friendshipImg")
    local friendshipText = _gt.GetUI("friendshipText")
    local RoleGuid = tostring(guid)
    if LD.IsMyFriend(RoleGuid) then
        GUI.SetVisible(friendshipImg, true)
        GUI.ImageSetGray(friendshipImg,false)
        local val = tostring(LD.GetContactLongCustomData("LikeabilityValue",RoleGuid,CONTACT_TYPE.contact_friend))
        GUI.StaticSetText(friendshipText, "好感度  " .. val)
    elseif LD.IsInMyBlackList(RoleGuid) then
        GUI.StaticSetText(friendshipText, "黑名单")
        GUI.ImageSetGray(friendshipImg,true)
    else
        GUI.StaticSetText(friendshipText, "陌生人")
        GUI.ImageSetGray(friendshipImg,true)
    end
end

-- 创建列表子项
function FriendUI.CreateContactItem(parent,index)
    -- 背景
    local contactItem = GUI.CheckBoxExCreate(parent, "ContactItem"..index, "1800800030", "1800800040", 0, 0, false, 280, 100) --GUI.ItemCtrlCreate(parent, name, "1800800030", 0, 0, 280, 100, false)
    GUI.RegisterUIEvent(contactItem, UCE.PointerClick, "FriendUI", "OnContactItemClick")

    local contactItemBg = contactItem
    -- iconBg
    local iconBg = GUI.ImageCreate(contactItemBg, "friendiconBg", "1800400330", 10, 9,false,84,84,false)
    SetAnchorAndPivot(iconBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    --_gt.BindName(iconBg,"iconBg"..typeindex)

    -- icon
    local icon = GUI.ImageCreate(iconBg, "friendicon", "1900000000", 0, -1, false, 72,72, false)
    SetAnchorAndPivot(icon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.AddRedPoint(icon,UIAnchor.TopLeft,0,0,"1800208080")
    GUI.SetRedPointVisable(icon,false)
    HeadIcon.CreateVip(icon, 60, 60)


    -- 玩家等级
    local level = GUI.CreateStatic(icon, "friendlevel", "", -3, 3, 40, 25)
    SetAnchorAndPivot(level, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.StaticSetFontSize(level, fontSizeSmaller)
    GUI.SetColor(level, colorWhite)
    GUI.StaticSetAlignment(level,TextAnchor.MiddleRight)
    GUI.SetIsOutLine(level, true)
    GUI.SetOutLine_Color(level, UIDefine.OutLine_BlackColor )
    GUI.SetOutLine_Distance(level, UIDefine.OutLineDistance)
    -- _gt.BindName(level,"level"..typeindex)

    -- 玩家名字
    local name = GUI.CreateStatic(contactItemBg, "friendname", "", 103, 13, 200, 30, "system", false, false)
    SetAnchorAndPivot(name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetAlignment(name,TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(name, fontSizeDefault)
    GUI.SetColor(name, colorDark)
    --_gt.BindName(name,"name"..typeindex)

    -- 门派标签
    local schoolMark = GUI.ImageCreate(contactItemBg, "friendschoolMark", "1800408030", 98, 55,false,26,26)
    SetAnchorAndPivot(schoolMark, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(schoolMark, false)
    --_gt.BindName(schoolMark,"schoolMark"..typeindex)

    -- 上次在线事件
    local loginInfo = GUI.CreateStatic(contactItemBg, "friendloginInfo", "", 130, 53, 150, 35)
    SetAnchorAndPivot(loginInfo, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(loginInfo, fontSizeDefault)
    GUI.StaticSetAlignment(loginInfo,TextAnchor.MiddleLeft)
    GUI.SetColor(loginInfo, colorRed)

    -- 查看详细信息
    local operateBtn = GUI.ButtonCreate(contactItemBg, "friendoperateBtn", "1800202340", 230, 50, Transition.ColorTint, "")
    SetAnchorAndPivot(operateBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(operateBtn, UCE.PointerClick, "FriendUI", "OnOperateBtnClick")

    return contactItem,iconBg,icon,level,name,schoolMark,loginInfo,operateBtn,addBtn
end


-- 查看信息
function FriendUI.OnCheckInfoBtnClick(guid)

    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法执行该操作")
        return
    end
    if AreaItemStatus == "0" then
        CL.SendNotify(NOTIFY.ShowBBMsg,"对方不在线或不存在，无法查看角色信息")
        return
    end
    if AreaItemName ~= nil then

        CL.SendNotify(NOTIFY.SubmitForm, "FormContact" , "QueryOfflinePlayer" , FriendUI.OperateSelectedRoleGuid)
        return
    end
    FriendUI.OnOperateMenuCoverClick()
end

-- 显示菜单数据
function FriendUI.ShowMenuData()
    test("显示菜单数据")
    local operateMenuCover = _gt.GetUI("operateMenuCover") -- GUI.Get("FriendUI/operateMenuCover")
    if operateMenuCover == nil then
        return
    end

    local infoBg = GUI.GetChild(operateMenuCover, "infoBg")
    local friendBtn = GUI.GetChild(infoBg, btnList[4][2])

    local isFriend = LD.IsMyFriend(FriendUI.OperateSelectedRoleGuid)
    if isFriend then
        GUI.ButtonSetText(friendBtn, "解除好友")
    else
        GUI.ButtonSetText(friendBtn, "加为好友")
    end

    local teamBtn = GUI.GetChild(infoBg, btnList[2][2])
    local giftBtn = GUI.GetChild(infoBg, btnList[3][2])
    local gangBtn = GUI.GetChild(infoBg, btnList[5][2])
    local blackBtn = GUI.GetChild(infoBg, btnList[6][2])
    local mainInfo = _gt.GetUI("mainInfo")
    local isBlack = LD.IsInMyBlackList(FriendUI.OperateSelectedRoleGuid)
    if isBlack then
        GUI.SetHeight(mainInfo,170)
        GUI.SetPositionY(friendBtn,60)
        GUI.SetPositionY(blackBtn,110)
        GUI.SetVisible(teamBtn,false)
        GUI.SetVisible(giftBtn,false)
        GUI.SetVisible(gangBtn,false)
        GUI.ButtonSetText(blackBtn, "移除黑名单")--移除黑名单
    else
        GUI.SetHeight(mainInfo,312)
        GUI.SetPositionY(friendBtn,160)
        GUI.SetPositionY(blackBtn,260)
        GUI.SetVisible(teamBtn,true)
        GUI.SetVisible(giftBtn,true)
        GUI.SetVisible(gangBtn,true)
        GUI.ButtonSetText(blackBtn, "加入黑名单")--加入黑名单
    end

    local inviteTeamBtn = GUI.GetChild(infoBg, btnList[2][2])

    local InTeamState = FriendUI.GetRoleAttr(RoleAttr.RoleAttrTeamStatus, TOOLKIT.Str2uLong(FriendUI.OperateSelectedRoleGuid))
    if InTeamState == 3 then
        GUI.ButtonSetText(inviteTeamBtn, "申请入队")
    else
        GUI.ButtonSetText(inviteTeamBtn, "邀请组队")
    end
end

function FriendUI.GetRoleAttr(attr,roleGUID)
    local chatPlayer = LD.GetQueryPlayerData()
    if chatPlayer and tostring(chatPlayer.guid) == tostring(roleGUID) then
        local Count = chatPlayer.attrs.Length
        for i = 0, Count-1 do
            if chatPlayer.attrs[i].attr == System.Enum.ToInt(attr) then
                return tonumber(tostring(chatPlayer.attrs[i].value))
            end
        end
        return 0
    else
        return CL.GetIntAttr(attr, roleGUID)
    end
end

function FriendUI.GetFriendData(guid)
    for i = 1, #AllCurFriendList do
        local data = AllCurFriendList[i]
        if tostring(data.guid) == guid then
            return data
        end
    end
    return nil
end

-- 设置某个选项被选中
function FriendUI.SetSelect(guid)
    CurSelectFriendData = FriendUI.GetFriendData(guid)
    FriendUI.ShowHelper(guid == "0")
    FriendUI.ShowInputCtrl(guid ~= "1")
    FriendUI.ShowFriendship(guid)

    local chatScroll = _gt.GetUI("chatScroll")
    GUI.SetVisible(chatScroll,guid ~= "1")

    local ElfChatScroll = _gt.GetUI("ElfChatScroll")
    GUI.SetVisible(ElfChatScroll,guid == "1")
end

-- 显示精灵
function FriendUI.ShowHelper(isShow)
    local parent = _gt.GetUI("recentlyPage")
    if parent == nil then
        return
    end

    local helperBg = GUI.GetChild(parent, "helperBg")
    GUI.SetVisible(helperBg, isShow)

    -- 好感度
    local friendshipImg = _gt.GetUI("friendshipImg")
    GUI.SetVisible(friendshipImg, not isShow)

    local friendshipText = _gt.GetUI("friendshipText")
    GUI.SetVisible(friendshipText, not isShow)

    -- 聊天框
    local chatBg = GUI.GetChild(parent, "chatBg")
    GUI.SetVisible(chatBg, not isShow)
end

-- 是否显示输入
function FriendUI.ShowInputCtrl(isShow)
    local parent = _gt.GetUI("recentlyPage")
    if parent == nil then
        return
    end

    -- 语音输入按钮
    local voiceInputBtn = GUI.GetChild(parent, "voiceInputBtn")
    GUI.SetVisible(voiceInputBtn, isShow)
    -- 聊天输入
    local input = GUI.GetChild(parent, "input")
    GUI.SetVisible(input, isShow)

    -- 表情输入
    local emojiInputBtn = GUI.GetChild(parent, "emojiInputBtn")
    GUI.SetVisible(emojiInputBtn, isShow)

    --加为好友
    local addFriendBtn = _gt.GetUI("addFriendBtn")
    if not LD.IsMyFriend(tostring(FriendUI.SelectedRoleGuid)) and tostring(FriendUI.SelectedRoleGuid) ~= "1" then
        GUI.SetVisible(addFriendBtn,isShow)
    else
        GUI.SetVisible(addFriendBtn, false)
    end

    -- 清空输入
    local clearChatContentBtn = GUI.GetChild(parent, "clearChatContentBtn")
    GUI.SetVisible(clearChatContentBtn, isShow)

    -- 发送
    local sendBtn = GUI.GetChild(parent, "sendBtn")
    GUI.SetVisible(sendBtn, isShow)

end
-----------------------------  功能函数 end -----------------------------------------

-----------------------------  事件响应 start -----------------------------------------

-- 关闭按钮
function FriendUI.OnExit()
    local wnd = GUI.GetWnd("FriendUI")
    if wnd ~= nil then
        FriendUI.CheckBoxBeFalse()
        GUI.CloseWnd("FriendUI")
        CL.SendNotify(NOTIFY.SubmitForm,"FormContact","set_control_red_state","true")
    end
    local EmojPanelUI = GUI.GetWnd("EmojPanelUI")
    if EmojPanelUI and GUI.GetVisible(EmojPanelUI) then
        GUI.CloseWnd("EmojPanelUI")
    end
    FriendUI.StopRefreshTimer()

    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "clearSendersGuid") -- 请求删除服务器记录的表
end


function FriendUI.CheckBoxBeFalse()
    test("FriendUI.SelectedRoleGuid",tostring(FriendUI.SelectedRoleGuid))
    if tonumber(FriendUI.SelectedRoleGuid) == 1 then
        FriendUI.ShowHelper(true)
        FriendUI.ShowInputCtrl(false)
        local ItemGuid1 = SelectFriendItemGuid
        local item1 = GUI.GetByGuid(ItemGuid1)
        GUI.CheckBoxExSetCheck(item1, false)
    else
        FriendUI.ShowHelper(true)
        FriendUI.ShowInputCtrl(false)
        local ItemGuid1 = ClickFriendTypeList1[tostring(FriendUI.SelectedRoleGuid)]
        local item1 = GUI.GetByGuid(ItemGuid1)
        GUI.CheckBoxExSetCheck(item1, false)
        local ItemGuid2 = ClickFriendTypeList2[tostring(FriendUI.SelectedRoleGuid)]
        local item2 = GUI.GetByGuid(ItemGuid2)
        GUI.CheckBoxExSetCheck(item2, false)
    end

end

function FriendUI.OnSearchInputChange()
    local searchInput = _gt.GetUI("searchInput")
    if GUI.EditGetTextM(searchInput) == "" then
        FriendUI.OnSearchBtnClick()
    end
end

-- 对好友进行操作
function FriendUI.OnOperateBtnClick(guid)
    local element = GUI.GetByGuid(guid)
    local RoleGuid = GUI.GetData(element,"friendoperateBtnData")
    local contactItem = GUI.GetParentElement(element)

    FriendUI.OperateSelectedRoleGuid = tostring(ItemGuid2RoleGuid[GUI.GetGuid(contactItem)])
    local contactInfo = FriendUI.GetFriendData(FriendUI.OperateSelectedRoleGuid)
    if not contactInfo then
        return
    end
    local ItemGuid = 0
    if CurSelectBtn == 1 then
        ItemGuid = ClickFriendTypeList1[FriendUI.OperateSelectedRoleGuid]
    elseif CurSelectBtn ==2 then
        ItemGuid = ClickFriendTypeList2[FriendUI.OperateSelectedRoleGuid]
    end
    FriendUI.OnContactItemClick(ItemGuid)

    FriendUI.CreateMenu(guid,RoleGuid)
    FriendUI.ShowMenuData()
end

--玩家Item被选中
function FriendUI.OnContactItemClick(guid)
    test("玩家Item被选中")
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    local RoleGuid = tostring(GUI.GetData(element,"RoleGuid"))
    test("RoleGuid",tostring(RoleGuid))
    local ItemPriority = tonumber(GUI.GetData(element,"ItemPriority"))

    RedClickNum = 2
    if CurSelectBtn == 1 then
        if tostring(guid) ~= SelectFriendItemGuid1 then
            local lastItem = GUI.GetByGuid(SelectFriendItemGuid1)
            if lastItem then
                GUI.CheckBoxExSetCheck(lastItem, false)
            end
        end
    end
    if CurSelectBtn == 2 then
        if tostring(guid) ~= SelectFriendItemGuid2 then
            local LastItemGuid = ClickFriendTypeList2[tostring(FriendUI.SelectedRoleGuid)]
            local lastItem = GUI.GetByGuid(LastItemGuid)
            if lastItem then
                GUI.CheckBoxExSetCheck(lastItem, false)
            end
        end
    end


    SelectFriendItemGuid = tostring(guid)
    SelectFriendItemGuid1 = tostring(guid)
    SelectFriendItemGuid2 = tostring(guid)
    GUI.CheckBoxExSetCheck(element, true)

    local voiceInputBtn = _gt.GetUI("voiceInputBtn")
    if ItemPriority == 0 then
        FriendUI.OnClickElfItem("1")

        GUI.UnRegisterUIEvent(voiceInputBtn, UCE.PointerUp, "ChatUI", "OnRecordBtnPointUp")
        GUI.UnRegisterUIEvent(voiceInputBtn, UCE.PointerEnter, "ChatUI", "OnRecordBtnPointEnter")
        GUI.UnRegisterUIEvent(voiceInputBtn, UCE.PointerExit, "ChatUI", "OnRecordBtnPointExit")

    else
        local roleGuid = tostring(ItemGuid2RoleGuid[guid])
        CL.SendNotify(NOTIFY.FriendChatReq, roleGuid)
        FriendUI.SelectedRoleGuid = roleGuid

        local ElfChatScroll = _gt.GetUI("ElfChatScroll")
        GUI.SetVisible(ElfChatScroll,guid == "1")

        -- 刷新聊天消息
        FriendUI.SetSelect(FriendUI.SelectedRoleGuid)

        GUI.RegisterUIEvent(voiceInputBtn, UCE.PointerUp, "ChatUI", "OnRecordBtnPointUp")
        GUI.RegisterUIEvent(voiceInputBtn, UCE.PointerEnter, "ChatUI", "OnRecordBtnPointEnter")
        GUI.RegisterUIEvent(voiceInputBtn, UCE.PointerExit, "ChatUI", "OnRecordBtnPointExit")
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "setOneSenderFalseForGuid", RoleGuid) -- 将玩家设置成false

end

--精灵Item点击事件
function FriendUI.OnClickElfItem(guid)
    test("精灵Item点击事件")
    FriendUI.SelectedRoleGuid = "1"

    local chatScroll = _gt.GetUI("chatScroll")
    GUI.LoopScrollRectSetTotalCount(chatScroll, 0)
    GUI.LoopScrollRectRefreshCells(chatScroll)
    GUI.SetVisible(chatScroll,guid ~= "1")

    local ElfChatScroll = _gt.GetUI("ElfChatScroll")
    GUI.SetVisible(ElfChatScroll,guid == "1")

    FriendUI.ShowInputCtrl(true)
    FriendUI.ShowHelper(false)
    local friendshipImg = _gt.GetUI("friendshipImg")
    local friendshipText = _gt.GetUI("friendshipText")
    GUI.SetVisible(friendshipImg, false)
    GUI.SetVisible(friendshipText, false)

    FriendUI.FirstRequire()

    ElfContentTable = ReturnContentTable
    test("ElfContentTable",inspect(ElfContentTable))

    local ElfChatScroll = _gt.GetUI("ElfChatScroll")
    GUI.LoopScrollRectSetTotalCount(ElfChatScroll, #ElfContentTable)
    GUI.LoopScrollRectRefreshCells(ElfChatScroll)

    LastSelectRedFriendItem = nil
end

function FriendUI.QuestionsAnswersElfReturnRefresh()
    ElfContentTable = ReturnContentTable
    test("ElfContentTable",inspect(ElfContentTable))

    local ElfChatScroll = _gt.GetUI("ElfChatScroll")
    GUI.LoopScrollRectSetTotalCount(ElfChatScroll, #ElfContentTable)
    GUI.LoopScrollRectRefreshCells(ElfChatScroll)
end

-- 清空聊天内容被点击
function FriendUI.OnClearChatContentBtnClick(guid)
    if FriendUI.SelectedRoleGuid == "1" then
        ReturnContentTable = {}
        local ElfChatScroll = _gt.GetUI("ElfChatScroll")
        GUI.LoopScrollRectSetTotalCount(ElfChatScroll, 0)
        GUI.LoopScrollRectRefreshCells(ElfChatScroll)
    else
        LD.ClearFriendChatRecord(FriendUI.SelectedRoleGuid)
        local chatScroll = _gt.GetUI("chatScroll")
        GUI.LoopScrollRectSetTotalCount(chatScroll, 0)
        GUI.LoopScrollRectRefreshCells(chatScroll)
    end
end

-- 发送按钮被点击
function FriendUI.OnSendBtnClick(guid)
    test("发送按钮被点击")
    local input = _gt.GetUI("input")
    local content = GUI.EditGetTextM(input)

    local IsShield = CL.IsHaveForbiddenWord(content) --规范字检测
    if IsShield then
        CL.SendNotify(NOTIFY.ShowBBMsg,"您有不规范的输入内容，请规范用语后发送")
        return
    end
    if FriendUI.SelectedRoleGuid ~= "0" then
        if LD.IsInMyBlackList(FriendUI.SelectedRoleGuid) then
            CL.SendNotify(NOTIFY.ShowBBMsg,"您已将对方加入黑名单，无法进行聊天操作。")
            GUI.EditSetTextM(input, "")
            return
        end
    end
    if content == "" then
        CL.SendNotify(NOTIFY.ShowBBMsg,"请先输入有效的内容")
        return
    end

    test("发送消息的FriendUI.SelectedRoleGuid",tostring(FriendUI.SelectedRoleGuid))

    if FriendUI.SelectedRoleGuid == "1" then --萌途精灵发送
        test("萌途精灵发送")
        FriendUI.SendContent(content)
    else
        content = LD.GetRealSendContent(content)
        if string.find(content, inviteCode) then
            local icod = GlobalProcessing.FriendInviteCode or inviteCode
            content = string.gsub(content, inviteCode, "#INVCODESTART<INVITECODE:好友邀请码,STR:".. icod ..">#",1)
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "SendContactMessage", FriendUI.SelectedRoleGuid, content) -- 发送聊天消息
        FriendUI.OnFriendListUpdate(CONTACT_TYPE.contact_recently)
    end
    -- 清空输入
    GUI.EditSetTextM(input, "")
    FriendUI.OnInputeClick()
end

function FriendUI.OnUploadRecordSuccess(fileName, time)
    if not FriendUI.SendRecordTargetGuid then
        return
    end
    local content = GlobalUtils.MakeUpRecordMsg(fileName, time)
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "SendContactMessage", FriendUI.SendRecordTargetGuid, content) -- 发送聊天消息
    FriendUI.SendRecordTargetGuid = nil
end

function FriendUI.OnRecordPlayStart()
    ChatUI.PlayRecordAnimation()
end

function FriendUI.OnItemQueryNtf(itemGuid)
    if CurItemQueryGuid == itemGuid then
        CurItemQueryGuid = nil
        local itemData = LD.GetQueryItemData()
        if itemData == nil then
            return
        end
        local panelBg = _gt.GetUI("panelBg")
        if not panelBg then
            return
        end
        local itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", 0, 0, 55)
    end
end

function FriendUI.OnPetQueryNtf(petGuid)
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

-- 表情按钮被点击
function FriendUI.OnEmojiInputBtnClick(guid)
    GUI.OpenWnd("EmojPanelUI", "index:" .. _gt.GetGuid("input"))
end

-- 操作菜单被点击
function FriendUI.OnOperateMenuCoverClick()
    local cover = _gt.GetUI("operateMenuCover")
    if cover ~= nil then
        GUI.SetVisible(cover, false)
        FriendUI.OperateSelectedRoleGuid = "0"
    end
end

-- 添加删除好友
function FriendUI.OnFriendBtnClick(guid)
    local operate= GUI.GetByGuid(guid)
    local contactInfo = FriendUI.GetFriendData(FriendUI.OperateSelectedRoleGuid)
    if contactInfo == nil then
        return
    end
    if FriendUI.OperateSelectedRoleGuid then
        if LD.IsMyFriend(FriendUI.OperateSelectedRoleGuid) then
            FriendUI.TempName = contactInfo.name
            FriendUI.TempGuid = FriendUI.OperateSelectedRoleGuid
            local msg = "您是否要删除您的好友<color=#0000ff>" .. contactInfo.name .. "</color>？"
            GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", msg, "FriendUI", "确定", "OnMsgBoxOKBtnClick_RemoveFriend", "取消")
        else
            if LD.IsInMyBlackList(FriendUI.OperateSelectedRoleGuid) then
                CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "RemoveBlackList", tostring(FriendUI.OperateSelectedRoleGuid))
            end
            CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyFriend", tostring(FriendUI.OperateSelectedRoleGuid))
        end
    end
    FriendUI.OnOperateMenuCoverClick()
end

-- 删好友确认
function FriendUI.OnMsgBoxOKBtnClick_RemoveFriend(parameter)
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "DeleteFriend", FriendUI.TempGuid) -- 删除好友
    FriendUI.ShowHelper(true)
    FriendUI.ShowInputCtrl(false)

    local input = _gt.GetUI("input")
    GUI.EditSetTextM(input, "")
end

-- 赠送礼物
function FriendUI.OnGiveGiftBtnClick(guid)
    local RoleGuid = tostring(FriendUI.OperateSelectedRoleGuid)
    if not LD.IsMyFriend(RoleGuid) then
        local RoleName = CL.GetRoleName(RoleGuid)
        local msg = "无法赠送" .. RoleName .. "不是您的好友"
        CL.SendNotify(NOTIFY.ShowBBMsg,msg)
        FriendUI.OnOperateMenuCoverClick()
        return
    end
    CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","is_can_give",tostring(RoleGuid))
end

-- 加为好友
function FriendUI.OnAddFriendBtnClick(guid)
    if not LD.IsMyFriend(FriendUI.SelectedRoleGuid) then
        if LD.IsInMyBlackList(FriendUI.SelectedRoleGuid) then
            CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "RemoveBlackList", tostring(FriendUI.SelectedRoleGuid))
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyFriend", tostring(FriendUI.SelectedRoleGuid))
    end
end

-- 组队邀请
function FriendUI.OnInviteTeamBtnClick(guid)
    test("组队按钮点击事件")
    MainUI.OnTeamInviteOpe(FriendUI.OperateSelectedRoleGuid)
    FriendUI.OnOperateMenuCoverClick()
end

-- 邀请入帮
function FriendUI.OnInviteGangBtnClick(guid)
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法执行该操作")
        return
    end
    if CL.GetIntAttr(RoleAttr.RoleAttrIsGuild, TOOLKIT.Str2uLong(FriendUI.OperateSelectedRoleGuid)) == 1 then
        --对方有帮派无法邀请
        CL.SendNotify(NOTIFY.ShowBBMsg, "对方已有帮派，无法邀请")
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 19, FriendUI.OperateSelectedRoleGuid)
    end
    FriendUI.OnOperateMenuCoverClick()
end

function FriendUI.RefreshFriendItem(contact_type)
    if contact_type == CONTACT_TYPE.contact_recently then
        local scroll = _gt.GetUI("latelyScrollWnd")
        FriendUI.RefreshFriendList(scroll,contact_type)
    elseif contact_type == CONTACT_TYPE.contact_friend then
        local  scroll1 = _gt.GetUI("friend")
        FriendUI.RefreshFriendList(scroll1,contact_type)
    elseif contact_type == CONTACT_TYPE.contact_stranger then
        local  scroll2 = _gt.GetUI("stranger")
        FriendUI.RefreshFriendList(scroll2,contact_type)
    elseif contact_type == CONTACT_TYPE.contact_blacklist then
        local  scroll3 = _gt.GetUI("blacklist")
        FriendUI.RefreshFriendList(scroll3,contact_type)
    end
end

function FriendUI.Refresh()
    if CurSelectBtn == 1 then --最近
        CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_recently)

    elseif CurSelectBtn == 2 then --好友，陌生人，黑名单
        CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_friend)
        CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_stranger)
        CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_blacklist)

    end
end

-- 黑名单
function FriendUI.OnAddBlacklistBtnClick(guid)
    local contactInfo = FriendUI.GetFriendData(FriendUI.OperateSelectedRoleGuid)
    local RoleName = contactInfo.name
    if RoleName == nil then
        return
    end
    if LD.IsInMyBlackList(FriendUI.OperateSelectedRoleGuid) then
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "RemoveBlackList", FriendUI.OperateSelectedRoleGuid)
    else
        FriendUI.TempName = RoleName
        FriendUI.TempGuid = FriendUI.OperateSelectedRoleGuid
        local msg = "您是否将玩家<color=#0000ff>" .. RoleName .. "</color>加入黑名单？"
        GlobalUtils.ShowBoxMsg2Btn("拉黑名单", msg, "FriendUI", "确定", "OnMsgBoxOKBtnClick_AddBlacklist", "取消","")
    end
    FriendUI.OnOperateMenuCoverClick()
end

-- 加入黑名单
function FriendUI.OnMsgBoxOKBtnClick_AddBlacklist(guid)
    local RoleGuid = tostring(FriendUI.TempGuid)
    local RoleName = tostring(FriendUI.TempName)
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "AddBlackList", RoleGuid)
end

function FriendUI.OnMailUpdate()
    local count = LD.GetMailTotalRedPointCount()
    local emailPageBtn = GUI.Get("FriendUI/panelBg/tabList/emailPageBtn")
    GUI.AddRedPoint(emailPageBtn,UIAnchor.TopLeft,25,-35,"1800208080")
    if count > 0 then
        GUI.SetRedPointVisable(emailPageBtn,true)
    else
        GUI.SetRedPointVisable(emailPageBtn,false)
    end
end

-- 搜索按钮
function FriendUI.OnSearchBtnClick(guid)
    local searchInput = _gt.GetUI("searchInput")
    local content = GUI.EditGetTextM(searchInput)
    searchContent = content
    if content ~= nil and content ~= "" then
        searchBtnStatus = 3
        FriendUI.GetSearchData()
    else
        searchBtnStatus = 0
        FriendUI.GetSearchData()
    end
end

function FriendUI.GetSearchData()
    CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_recently)
    CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_friend)
    CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_stranger)
    CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_blacklist)
end

--显示聊天文本链接的内容
function FriendUI.OnUrlClick_RichTxt(guid)
    test("显示聊天文本链接的内容")

    --点击富文本
    local uielement = GUI.GetByGuid(guid)
    local value = GUI.RichEditGetSelectClickString(uielement)
    test("value",tostring(value))
    if value ~= nil and string.len(value) > 0 then
        if string.find(value, "STR:(.+)】,OWERGUID:(%d+),ITEMGUID:(%d+),ITEMGRADE:(%d+)") ~= nil then
            local txt = string.split(value, "STR:")
            local str = string.split(txt[2], ",")
            for i = 1, #str do
                test(str[i])
            end
            local name = str[1]
            local itemGuidStr = string.split(str[3], ":")
            local itemGuid = itemGuidStr[2]
            CurItemQueryGuid = itemGuid
            if CL.IsPetStrGuid(itemGuid) then
                CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "QueryPet", itemGuid)
            else
                CL.SendNotify(NOTIFY.SubmitForm, "FormItem", "QueryItem", itemGuid)
            end
        elseif string.find(value, "WND:申请入队,PARAM:") ~= nil then
            local txt = string.split(value, "PARAM:")
            local txt2 = string.split(txt[2], ",")
            local txt3 = string.split(txt2[1], "")
            local SelfLevel = tonumber(CL.GetAttr(RoleAttr.RoleAttrLevel,0))
            local _FuncOpen = DB.Get_function_open(17)
            if _FuncOpen ~= nil then
                if _FuncOpen.Level > SelfLevel then
                    CL.SendNotify(NOTIFY.ShowBBMsg, _FuncOpen.LockedTips)
                else
                    if SelfLevel >= tonumber(txt3[3]) and SelfLevel <= tonumber(txt3[4]) then
                        CL.SendNotify(NOTIFY.TeamOpeUpdate, 18, txt3[1])
                    else
                        CL.SendNotify(NOTIFY.ShowBBMsg, "等级超过限制，无法申请入队")
                    end
                end
            end
            -------------------------萌途精灵 Start---------------------------------
        elseif string.find(value, "WND:萌途精灵,STR:") ~= nil then--萌途精灵
            test("萌途精灵函数调用")
            local Text1 = string.split(value, "STR:")[2]
            local Text2 = string.split(Text1, ",")[1]
            FriendUI.ReturnContent(Text2)

        elseif string.find(value, "WND:萌途精灵,PARAM:") ~= nil then--萌途精灵操作跳转
            test("萌途精灵操作函数调用")
            local Text = string.split(value, "PARAM:")[2]
            local Text2 = string.split(Text, ",")[1]
            local Data = string.split(Text2, "_")
            if tonumber(Data[1]) == 0 then
                local Text = Data[2]
                FriendUI.ReturnContent(Text)
            else
                if #Data == 2 then
                    GetWay.Def[tonumber(Data[1])].jump(tostring(Data[2]))
                elseif #Data == 3 then
                    GetWay.Def[tonumber(Data[1])].jump(tostring(Data[2]),tostring(Data[3]))
                elseif #Data == 4 then
                    GetWay.Def[tonumber(Data[1])].jump(tostring(Data[2]),tostring(Data[3]),tostring(Data[4]))
                elseif #Data == 5 then
                    GetWay.Def[tonumber(Data[1])].jump(tostring(Data[2]),tostring(Data[3]),tostring(Data[4]),tostring(Data[5]))
                end
            end
            -------------------------萌途精灵 End---------------------------------
        elseif string.find(value, "WND:playerName,STR:") ~= nil then
            local txt = string.split(value, "[")
            local str = string.split(txt[2], "]")
            local roleName = str[1]
            if roleName == nil or string.len(roleName) == 0 then
                return
            end

            local selfName = CL.GetRoleName()
            if roleName == selfName then
                return
            end

            local panel = GUI.GetWnd("FriendUI")
            GUI.SetData(panel, "queryPlayerName", roleName)
            CL.SendNotify(NOTIFY.QueryPlayerInfo, roleName)
        elseif string.find(value, "INVITECODE:好友邀请码") ~= nil then
            local tmpStr = string.split(value, ",")
            for i = 1, #tmpStr do
                if string.find(tmpStr[i], "STR") ~= nil then
                    local tmpArr = string.split(tmpStr[i], ":")
                    TOOLKIT.CopyTextToClipboard(tmpArr[2])
                    CL.SendNotify(NOTIFY.ShowBBMsg, "您已经复制成功了！")
                end
            end
        else
            LD.OnParsePathFinding(value)
        end
    end
end
-----------------------------  事件响应 end -----------------------------------------


--------------------------------------------萌途精灵对话框 Start----------------------------------------

-- 创建对话
function FriendUI.CreateElfChatBox()
    local ElfChatScroll = _gt.GetUI("ElfChatScroll")
    local index = GUI.LoopScrollRectGetChildInPoolCount(ElfChatScroll) + 1
    local chatBoxBg = GUI.LoopListChatCreate(ElfChatScroll, "chatBoxBg"..index, "1800400200", 0, 10)
    SetAnchorAndPivot(chatBoxBg, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetColor(chatBoxBg, Color.New(1, 1, 1, 0))
    GUI.LoopListChatSetPreferredWidth(chatBoxBg, 700)
    GUI.LoopListChatSetPreferredHeight(chatBoxBg, 78)


    ------------------------------------------------Tips组 Start---------------------------------------
    local TopTipsGroup = GUI.GroupCreate(chatBoxBg,"TopTipsGroup",0,0,700,40,false)

    local cutLineLeft = GUI.ImageCreate(TopTipsGroup, "cutLineLeft", "1800207080", 40, 0)
    SetAnchorAndPivot(cutLineLeft, UIAnchor.Left, UIAroundPivot.Left)

    local cutLineRight = GUI.ImageCreate(TopTipsGroup, "cutLineRight", "1800207090", -40, 0)
    SetAnchorAndPivot(cutLineRight, UIAnchor.Right, UIAroundPivot.Right)

    local sysMsgTxt = GUI.CreateStatic(TopTipsGroup, "sysMsgTxt", "", 0, 0, 320, 50)
    SetAnchorAndPivot(sysMsgTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(sysMsgTxt, fontSizeSmaller)
    GUI.SetColor(sysMsgTxt, ColorSys)
    GUI.StaticSetAlignment(sysMsgTxt, TextAnchor.MiddleCenter)
    ------------------------------------------------Tips组 End------------------------------------------------------

    ----------------------------------------------Content组 Start--------------------------------------------------

    -- 头像
    local icon = GUI.ItemCtrlCreate(chatBoxBg, "icon", "1800400050", 0, 0, 80, 80)
    SetAnchorAndPivot(icon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon,RoleSelfIcon)
    local iconSprite = GUI.ItemCtrlGetElement(icon, eItemIconElement.Icon)
    GUI.SetPositionX(iconSprite,0)
    GUI.SetPositionY(iconSprite,-1)
    GUI.SetWidth(iconSprite, 69)
    GUI.SetHeight(iconSprite, 69)
    HeadIcon.CreateVip(icon, 60, 60, -5, 5)

    -- 聊天文字底图
    local msgTxtBg = GUI.ImageCreate(chatBoxBg, "msgTxtBg", "1800900020", 82, 0, false, 500, 60)
    SetAnchorAndPivot(msgTxtBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 聊天内容
    local msgTxt = GUI.RichEditCreate(chatBoxBg, "msgTxt", "", 25, 20, 470, 30,"system",false)
    SetAnchorAndPivot(msgTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(msgTxt, fontSizeSmaller)
    GUI.SetColor(msgTxt, colorDark)

    msgTxt:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(msgTxt, UCE.PointerClick, "FriendUI", "OnUrlClick_RichTxt")



    -------------------------------------------------Content组 的反馈组 Start------------------------------------------------
    local FeedbackGroup = GUI.GroupCreate(chatBoxBg, "FeedbackGroup", 0, 0, 460, 160)
    SetAnchorAndPivot(FeedbackGroup, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local line = GUI.ImageCreate(FeedbackGroup, "line", "1800400370", -20,70 , false, 490, 1)
    SetAnchorAndPivot(line, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local FeedbackTxt = GUI.RichEditCreate(FeedbackGroup, "FeedbackTxt", "如果问题不能解决请联系客服:", -35, 25, 470, 30)
    SetAnchorAndPivot(FeedbackTxt, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.StaticSetFontSize(FeedbackTxt, fontSizeSmaller)
    GUI.SetColor(FeedbackTxt, colorDark)

    local FeedbackBtn = GUI.ButtonCreate(FeedbackGroup, "FeedbackBtn", "1800402080", -20, 10, Transition.ColorTint, "联系客服", 120, 45, false)
    GUI.ButtonSetTextFontSize(FeedbackBtn, 24)
    GUI.SetIsOutLine(FeedbackBtn, true)
    GUI.ButtonSetTextColor(FeedbackBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(FeedbackBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(FeedbackBtn,OutLineDistance)
    SetAnchorAndPivot(FeedbackBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.RegisterUIEvent(FeedbackBtn, UCE.PointerClick, "FriendUI", "OnFeedbackBtnClick")

    -------------------------------------------------Content组 的反馈组 End------------------------------------------------


    ----------------------------------------------Content组 End--------------------------------------------------
    return chatBoxBg
end

-- 更新聊天信息
function FriendUI.OnRefreshElfChatMsg(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1

    local chatBoxBg = GUI.GetByGuid(guid)
    local Icon = GUI.GetChild(chatBoxBg, "icon",false)
    local IconSprite = GUI.ItemCtrlGetElement(Icon, eItemIconElement.Icon)
    local MsgTxtBg = GUI.GetChild(chatBoxBg, "msgTxtBg",false)
    local MsgTxt = GUI.GetChild(chatBoxBg, "msgTxt",false)

    local TopTipsGroup = GUI.GetChild(chatBoxBg, "TopTipsGroup",false)
    local SysMsgTxt = GUI.GetChild(TopTipsGroup, "sysMsgTxt",false)

    local FeedbackGroup = GUI.GetChild(chatBoxBg, "FeedbackGroup",false)

    local TableData = ElfContentTable[index]

    GUI.LoopListChatSetPreferredWidth(chatBoxBg, 700)


    if TableData then
        local Type = TableData.Type
        local Content = TableData.Content
        local TypeTips = TableData.TypeTips
        local Status = TableData.Status

        -- 显示聊天记录、上次聊天时间等内容
        if Type == 1 then
            local vipV = GUI.GetChild(Icon, "vipV",false)
            local vipVNum1 = GUI.GetChild(Icon, "vipVNum1",false)
            local vipVNum2 = GUI.GetChild(Icon, "vipVNum2",false)
            GUI.SetVisible(vipV,false)
            GUI.SetVisible(vipVNum1,false)
            GUI.SetVisible(vipVNum2,false)

            GUI.SetPositionX(chatBoxBg, 80)

            -- 图标设置
            SetAnchorAndPivot(Icon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.ImageSetImageID(IconSprite, QuestionsAnswersElf.ElfIcon)

            -- 聊天背景内容设置
            SetAnchorAndPivot(MsgTxtBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetPositionX(MsgTxtBg, 82)

            -- 聊天内容设置
            SetAnchorAndPivot(MsgTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

            if TypeTips ~= nil then
                GUI.SetVisible(TopTipsGroup,true)
                GUI.StaticSetText(SysMsgTxt,tostring(TableData.TypeTips))
                if Status == 0 then
                    GUI.SetPositionY(Icon,60)
                    GUI.SetPositionX(MsgTxt, 100)
                    GUI.SetPositionY(MsgTxt, 80)
                else
                    GUI.SetPositionX(MsgTxt, 100)
                    GUI.SetPositionY(MsgTxt, 20)
                    GUI.SetPositionY(FeedbackGroup, 120)
                end
                GUI.SetPositionY(MsgTxtBg,60)
            else
                if Status == 0 then
                    GUI.SetPositionY(Icon,10)
                    GUI.SetPositionY(MsgTxtBg, 10)
                    GUI.SetPositionX(MsgTxt, 100)
                    GUI.SetPositionY(MsgTxt, 30)
                else
                    GUI.SetPositionY(Icon,0)
                    GUI.SetPositionX(MsgTxt, 100)
                    GUI.SetPositionY(MsgTxt, 20)
                    GUI.SetPositionY(MsgTxtBg, 5)
                    GUI.SetPositionX(FeedbackGroup, 20)
                    GUI.SetPositionY(FeedbackGroup, 10)
                end
                GUI.SetVisible(TopTipsGroup,false)
            end
            GUI.SetScale(MsgTxtBg, Vector3.New(1, 1, 1))


            GUI.SetWidth(MsgTxt, 510)
            GUI.StaticSetText(MsgTxt, Content)
        else
            -- 图标设置
            SetAnchorAndPivot(Icon, UIAnchor.TopRight, UIAroundPivot.TopRight)
            HeadIcon.BindRoleVipLv(Icon, tostring(CL.GetAttr(RoleAttr.RoleAttrVip)) or 0)
            GUI.ImageSetImageID(IconSprite,RoleSelfIcon)

            -- 聊天背景设置
            SetAnchorAndPivot(MsgTxtBg, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.SetScale(MsgTxtBg, Vector3.New(-1, 1, 1))
            GUI.SetScale(MsgTxt, Vector3.New(1, 1, 1))

            -- 聊天内容
            SetAnchorAndPivot(MsgTxt, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.SetPositionX(MsgTxt, 105)

            if TypeTips ~= nil then
                GUI.SetVisible(TopTipsGroup,true)
                GUI.StaticSetText(SysMsgTxt,tostring(TableData.TypeTips))
                if Status == 0 then
                    GUI.SetPositionY(Icon,60)
                    GUI.SetPositionY(MsgTxtBg,60)
                else

                end
            else
                GUI.SetVisible(TopTipsGroup,false)
                if Status == 0 then
                    GUI.SetPositionY(MsgTxt, 20)
                    GUI.SetPositionY(Icon,0)
                else

                end
            end
            GUI.SetWidth(MsgTxt, 500)

            GUI.StaticSetText(MsgTxt, Content)

            local width = GUI.RichEditGetPreferredWidth(MsgTxt)
            if width > 500 then
                width = 500
            end
            GUI.SetPositionX(MsgTxtBg, 82 + width + 40)
            GUI.SetPositionY(MsgTxtBg, 5)

        end

        local width = GUI.RichEditGetPreferredWidth(MsgTxt)
        if width > 510 then
            width = 510
        end

        GUI.SetWidth(MsgTxt, width)

        local height = GUI.RichEditGetPreferredHeight(MsgTxt)


        if TypeTips ~= nil then
            if Status == 0 then
                GUI.SetHeight(MsgTxt, height)
                GUI.SetHeight(MsgTxtBg, height + 30)
                GUI.SetVisible(FeedbackGroup,false)
                GUI.SetWidth(MsgTxtBg, width + 40)
                GUI.LoopListChatSetPreferredHeight(chatBoxBg, height + 120)
            elseif Status == 1 then
                GUI.SetHeight(MsgTxt, height)
                GUI.SetHeight(MsgTxtBg, height + 20)
                GUI.SetVisible(FeedbackGroup,true)
                GUI.SetWidth(MsgTxtBg,  560)
                GUI.LoopListChatSetPreferredHeight(chatBoxBg, height + 160)
            end
        else
            if Status == 0 then
                GUI.SetHeight(MsgTxt, height)
                GUI.SetHeight(MsgTxtBg, height + 30)
                GUI.SetVisible(FeedbackGroup,false)
                GUI.SetWidth(MsgTxtBg, width + 40)
                GUI.LoopListChatSetPreferredHeight(chatBoxBg, height + 60)
            elseif Status == 1 then
                GUI.SetHeight(MsgTxt, height)
                GUI.SetHeight(MsgTxtBg, height + 80)
                GUI.SetVisible(FeedbackGroup,true)
                GUI.SetWidth(MsgTxtBg,  540)
                GUI.LoopListChatSetPreferredHeight(chatBoxBg, height + 90)
            end
        end
    end
    FriendUI.SetUrlColor(MsgTxt)
end

-------------------------------------------萌途精灵对话框 End-------------------------------------------

--客户端发送输入的内容
function FriendUI.SendContent(Info)
    test("Info",tostring(Info))
    local temp = {
        Content = Info,
        Status = 0,--0是不显示,1是显示
        Type = 2,--1为精灵,2为玩家,3为顶部提示
        Type2 = 2,--1为纯文本,2为富文本
    }
    table.insert(ReturnContentTable,1,temp)

    FriendUI.SelectedContent(Info,QuestionsAnswersElf.ElfOpenSkip)
end

--客户端点击的链接
function FriendUI.ReturnContent(Info)
    test("客户端点击的链接的内容为:",tostring(Info))
    local str = tostring(Info) --要搜索的内容

    local Info = str
    local temp = {
        Content = Info,
        Status = 0,--0是不显示,1是显示
        Type = 2,--1为精灵,2为玩家,3为顶部提示
        Type2 = 2,--1为纯文本,2为富文本
    }
    table.insert(ReturnContentTable,1,temp)

    FriendUI.SelectedContent(str,0)

end

function FriendUI.SelectedContent(str,Status)
    local GetInfo = ""
    local TableLength = tonumber(#ReturnContentTable)
    if tostring(str) == "不显示" then
        goto UnderData
    else
        test("ElfTable.Interaction",inspect(QuestionsAnswersElf.ElfTable.Interaction))
        local TableData = QuestionsAnswersElf.ElfTable.Interaction
        test("进入第一筛选")
        for index1, value1 in pairs(TableData) do
            if FriendUI.SearchTableContent(str,index1) then
                test("查找到的内容为:index1",tostring(index1))
                if QuestionsAnswersElf.ElfTableContent[tostring(index1)] == nil then
                    local Index1Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index1,1)
                    GetInfo = GetInfo.."为你找到以下内容:\n\n"..Index1Info.."\n\n"
                    for i, v in pairs(value1) do
                        if type(i) == type(1) then
                            local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",v,2)
                            GetInfo = GetInfo..Info.."   "
                        else
                            if tostring(i) ~= "不显示" then
                                local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",i,2)
                                GetInfo = GetInfo..Info.."   "
                            end
                        end
                    end
                    GetInfo = GetInfo.."\n"
                    local temp = {
                        Content = GetInfo,
                        Status = Status,--0是不显示,1是显示
                        Type = 1,--1为精灵,2为玩家
                    }
                    table.insert(ReturnContentTable,1,temp)
                    goto UnderData
                else
                    GetInfo = GetInfo.."为你找到以下内容:\n\n"
                    local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index1,1)
                    GetInfo = GetInfo..Info.."\n\n"
                    local TableContent = ""
                    for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(index1)]) do
                        local Text = tostring(v)
                        Text = string.split(Text, "&")
                        if #Text >1 then
                            local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],2)
                            TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                        else
                            TableContent = TableContent..tostring(Text[1]).."\n"
                        end
                    end
                    GetInfo = GetInfo..TableContent
                    local temp = {
                        Content = GetInfo,
                        Status = Status,--0是不显示,1是显示
                        Type = 1,--1为精灵,2为玩家
                    }
                    table.insert(ReturnContentTable,1,temp)
                    goto UnderData
                end
            else
                test("进入第二筛选")
                for index2, value2 in pairs(value1) do
                    if tostring(index2) ~= "不显示" then
                        if FriendUI.SearchTableContent(str,index2) then
                            test("查找到的内容为:index2",tostring(index2))
                            if QuestionsAnswersElf.ElfTableContent[tostring(index2)] == nil then
                                local Index2Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index2,2)
                                GetInfo = GetInfo.."为你找到以下内容:\n\n"..Index2Info.."\n\n"
                                for i, v in pairs(value2) do
                                    if type(i) == type(1) then
                                        local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",v,3)
                                        GetInfo = GetInfo..Info.."   "
                                    else
                                        if tostring(i) ~= "不显示" then
                                            local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",i,3)
                                            GetInfo = GetInfo..Info.."   "
                                        end
                                    end

                                end
                                GetInfo = GetInfo.."\n"
                                local temp = {
                                    Content = GetInfo,
                                    Status = Status,--0是不显示,1是显示
                                    Type = 1,--1为精灵,2为玩家
                                }
                                table.insert(ReturnContentTable,1,temp)
                                goto UnderData
                            else
                                GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index2,2)
                                GetInfo = GetInfo..Info.."\n\n"
                                local TableContent = ""
                                for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(index2)]) do
                                    local Text = tostring(v)
                                    Text = string.split(Text, "&")
                                    if #Text >1 then
                                        local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],5)
                                        TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                    else
                                        TableContent = TableContent..tostring(Text[1]).."\n"
                                    end
                                end
                                GetInfo = GetInfo..TableContent
                                local temp = {
                                    Content = GetInfo,
                                    Status = Status,--0是不显示,1是显示
                                    Type = 1,--1为精灵,2为玩家
                                }
                                table.insert(ReturnContentTable,1,temp)
                                goto UnderData
                            end

                        else
                            test("进入第三筛选")
                            if type(value2) == type(table) then
                                for index3, value3 in pairs(value2) do
                                    if FriendUI.SearchTableContent(str,index3) then
                                        test("查找到的内容为:index2",tostring(index3))
                                        if QuestionsAnswersElf.ElfTableContent[tostring(index3)] == nil then
                                            local Index2Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index3,2)
                                            GetInfo = GetInfo.."为你找到以下内容:\n\n"..Index2Info.."\n\n"
                                            for i, v in pairs(value3) do
                                                if type(i) == type(1) then
                                                    local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",v,3)
                                                    GetInfo = GetInfo..Info.."   "
                                                else
                                                    if tostring(i) ~= "不显示" then
                                                        local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",i,3)
                                                        GetInfo = GetInfo..Info.."   "
                                                    end
                                                end

                                            end
                                            GetInfo = GetInfo.."\n"
                                            local temp = {
                                                Content = GetInfo,
                                                Status = Status,--0是不显示,1是显示
                                                Type = 1,--1为精灵,2为玩家
                                            }
                                            table.insert(ReturnContentTable,1,temp)
                                            goto UnderData
                                        else
                                            GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                            local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index3,4)
                                            GetInfo = GetInfo..Info.."\n\n"
                                            local TableContent = ""
                                            for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(index3)]) do
                                                local Text = tostring(v)
                                                Text = string.split(Text, "&")
                                                if #Text >1 then
                                                    local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],5)
                                                    TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                                else
                                                    TableContent = TableContent..tostring(Text[1]).."\n"
                                                end
                                            end
                                            GetInfo = GetInfo..TableContent
                                            local temp = {
                                                Content = GetInfo,
                                                Status = Status,--0是不显示,1是显示
                                                Type = 1,--1为精灵,2为玩家
                                            }
                                            table.insert(ReturnContentTable,1,temp)
                                            goto UnderData
                                        end
                                    else
                                        test("进入第四筛选")
                                        if tostring(index3) ~= "不显示" then
                                            if FriendUI.SearchTableContent(str,index3) then
                                            else
                                                if type(value3) == type(table) then
                                                    for index4, value4 in pairs(value3) do
                                                        if type(value4) ~= type(table) then
                                                            if FriendUI.SearchTableContent(str,value4) then
                                                                test("查找到的内容为:index4",tostring(index4))
                                                                if QuestionsAnswersElf.ElfTableContent[tostring(index3)] == nil then
                                                                else
                                                                    GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                                                    local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index3,4)
                                                                    GetInfo = GetInfo..Info.."\n\n"
                                                                    local TableContent = ""
                                                                    for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(index3)]) do
                                                                        local Text = tostring(v)
                                                                        Text = string.split(Text, "&")
                                                                        if #Text >1 then
                                                                            local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],5)
                                                                            TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                                                        else
                                                                            TableContent = TableContent..tostring(Text[1]).."\n"
                                                                        end
                                                                    end
                                                                    GetInfo = GetInfo..TableContent
                                                                    local temp = {
                                                                        Content = GetInfo,
                                                                        Status = Status,--0是不显示,1是显示
                                                                        Type = 1,--1为精灵,2为玩家
                                                                    }
                                                                    table.insert(ReturnContentTable,1,temp)
                                                                    goto UnderData
                                                                end
                                                            end

                                                        end
                                                    end
                                                else
                                                    if FriendUI.SearchTableContent(str,value3) then
                                                        test("查找到的内容为:value3",tostring(value3))
                                                        if QuestionsAnswersElf.ElfTableContent[tostring(value3)] == nil then
                                                            if QuestionsAnswersElf.ElfTableContent[tostring(index2)] ~= nil then
                                                                GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                                                local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",str,1)
                                                                GetInfo = GetInfo..Info.."\n\n"
                                                                local TableContent = ""
                                                                for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(index2)]) do
                                                                    local Text = tostring(v)
                                                                    Text = string.split(Text, "&")
                                                                    if #Text >1 then
                                                                        local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],5)
                                                                        TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                                                    else
                                                                        TableContent = TableContent..tostring(Text[1]).."\n"
                                                                    end
                                                                end
                                                                GetInfo = GetInfo..TableContent
                                                                local temp = {
                                                                    Content = GetInfo,
                                                                    Status = Status,--0是不显示,1是显示
                                                                    Type = 1,--1为精灵,2为玩家
                                                                }
                                                                table.insert(ReturnContentTable,1,temp)
                                                                goto UnderData
                                                            end
                                                        else
                                                            GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                                            local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",value3,3)
                                                            GetInfo = GetInfo..Info.."\n\n"
                                                            local TableContent = ""
                                                            for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(value3)]) do
                                                                local Text = tostring(v)
                                                                Text = string.split(Text, "&")
                                                                if #Text >1 then
                                                                    local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],5)
                                                                    TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                                                else
                                                                    TableContent = TableContent..tostring(Text[1]).."\n"
                                                                end
                                                            end
                                                            GetInfo = GetInfo..TableContent
                                                            local temp = {
                                                                Content = GetInfo,
                                                                Status = Status,--0是不显示,1是显示
                                                                Type = 1,--1为精灵,2为玩家
                                                            }
                                                            table.insert(ReturnContentTable,1,temp)
                                                            goto UnderData
                                                        end
                                                    end
                                                end
                                            end
                                        else
                                            for index4, value4 in pairs(value3) do
                                                if FriendUI.SearchTableContent(str,value4) then
                                                    if QuestionsAnswersElf.ElfTableContent[tostring(index2)] == nil then
                                                    else
                                                        GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                                        local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index2,1)
                                                        GetInfo = GetInfo..Info.."\n\n"
                                                        local TableContent = ""
                                                        for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(index2)]) do
                                                            local Text = tostring(v)
                                                            Text = string.split(Text, "&")
                                                            if #Text >1 then
                                                                local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],5)
                                                                TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                                            else
                                                                TableContent = TableContent..tostring(Text[1]).."\n"
                                                            end
                                                        end
                                                        GetInfo = GetInfo..TableContent
                                                        local temp = {
                                                            Content = GetInfo,
                                                            Status = Status,--0是不显示,1是显示
                                                            Type = 1,--1为精灵,2为玩家
                                                        }
                                                        table.insert(ReturnContentTable,1,temp)
                                                        goto UnderData
                                                    end
                                                end
                                            end

                                        end
                                    end
                                end
                            else
                                if QuestionsAnswersElf.ElfTableContent[tostring(value2)] == nil then
                                    if QuestionsAnswersElf.ElfTableContent[tostring(index1)] ~= nil then
                                        GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                        local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",str,1)
                                        GetInfo = GetInfo..Info.."\n\n"
                                        local TableContent = ""
                                        for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(index1)]) do
                                            local Text = tostring(v)
                                            Text = string.split(Text, "&")
                                            if #Text >1 then
                                                local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],5)
                                                TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                            else
                                                TableContent = TableContent..tostring(Text[1]).."\n"
                                            end
                                        end
                                        GetInfo = GetInfo..TableContent
                                        local temp = {
                                            Content = GetInfo,
                                            Status = Status,--0是不显示,1是显示
                                            Type = 1,--1为精灵,2为玩家
                                        }
                                        table.insert(ReturnContentTable,1,temp)
                                        goto UnderData
                                    end
                                else
                                    if FriendUI.SearchTableContent(str,value2) then
                                        GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                        local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",value2,1)
                                        GetInfo = GetInfo..Info.."\n\n"
                                        local TableContent = ""
                                        for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(value2)]) do
                                            local Text = tostring(v)
                                            Text = string.split(Text, "&")
                                            if #Text >1 then
                                                local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],5)
                                                TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                            else
                                                TableContent = TableContent..tostring(Text[1]).."\n"
                                            end
                                        end
                                        GetInfo = GetInfo..TableContent
                                        local temp = {
                                            Content = GetInfo,
                                            Status = Status,--0是不显示,1是显示
                                            Type = 1,--1为精灵,2为玩家
                                        }
                                        table.insert(ReturnContentTable,1,temp)
                                        goto UnderData
                                    end
                                end

                            end
                        end
                    else
                        for index3, value3 in pairs(value2) do
                            if type(index3) == type(1) then
                                if FriendUI.SearchTableContent(str,value3) then
                                    if QuestionsAnswersElf.ElfTableContent[tostring(value3)] == nil then
                                        if QuestionsAnswersElf.ElfTableContent[tostring(index1)] ~= nil then
                                            GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                            local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index1,1)
                                            GetInfo = GetInfo..Info.."\n\n"
                                            local TableContent = ""
                                            for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(index1)]) do
                                                local Text = tostring(v)
                                                Text = string.split(Text, "&")
                                                if #Text >1 then
                                                    local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],2)
                                                    TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                                else
                                                    TableContent = TableContent..tostring(Text[1]).."\n"
                                                end
                                            end
                                            GetInfo = GetInfo..TableContent
                                            local temp = {
                                                Content = GetInfo,
                                                Status = Status,--0是不显示,1是显示
                                                Type = 1,--1为精灵,2为玩家
                                            }
                                            table.insert(ReturnContentTable,1,temp)
                                            goto UnderData
                                        end
                                    else
                                        GetInfo = GetInfo.."为你找到以下内容:\n\n"
                                        local Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",value3,2)
                                        GetInfo = GetInfo..Info.."\n\n"
                                        local TableContent = ""
                                        for i, v in pairs(QuestionsAnswersElf.ElfTableContent[tostring(value3)]) do
                                            local Text = tostring(v)
                                            Text = string.split(Text, "&")
                                            if #Text >1 then
                                                local Info = string.format("#UILINK<WND:%s,PARAM:%s,STR:%s,Grade:%s>#","萌途精灵",Text[3],Text[2],3)
                                                TableContent = TableContent..tostring(Text[1]).."  "..Info.."\n"
                                            else
                                                TableContent = TableContent..tostring(Text[1]).."\n"
                                            end
                                        end
                                        GetInfo = GetInfo..TableContent
                                        local temp = {
                                            Content = GetInfo,
                                            Status = Status,--0是不显示,1是显示
                                            Type = 1,--1为精灵,2为玩家
                                        }
                                        table.insert(ReturnContentTable,1,temp)
                                        goto UnderData
                                    end
                                end
                            else

                            end
                        end
                    end
                end
            end
        end
    end

    ::UnderData::

    if TableLength == #ReturnContentTable then
        local temp = {
            Content = QuestionsAnswersElf.ElfNoFoundTips.."\n",
            Status = Status,--0是不显示,1是显示
            Type = 1,--1为精灵,2为玩家
        }
        table.insert(ReturnContentTable,1,temp)
    end

    FriendUI.QuestionsAnswersElfReturnRefresh()
end

--客户端切换到萌途精灵
function FriendUI.FirstRequire()
    test("客户端切换到萌途精灵")
    local TypeTipsValue = ""
    TypeTipsValue = "以下是历史消息"

    local GetInfo = ""
    local TableData = QuestionsAnswersElf.ElfTable.FirstShowInteraction
    GetInfo = QuestionsAnswersElf.ElfIntroduceContent.."\n".."\n"
    for index1, value1 in pairs(TableData) do
        local Info = ""
        if type(index1) == type(1) then
            Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",value1,1)
        else
            Info = string.format("#UILINK<WND:%s,STR:%s,Grade:%s>#","萌途精灵",index1,1)
        end

        GetInfo = GetInfo..Info.."   "
    end
    GetInfo = GetInfo.."\n"


    local temp = {
        Content = GetInfo,
        Status = 0,--0是不显示,1是显示
        Type = 1,--1为精灵,2为玩家
        TypeTips = TypeTipsValue
    }
    table.insert(ReturnContentTable,1,temp)

end

function FriendUI.SearchTableContent(InputContent,SearchContent)
    if type(SearchContent) == type(table) then
        return false
    end
    local IsBoolean = string.find(SearchContent, InputContent)
    if IsBoolean ~= nil then
        return true
    else
        return false
    end
end

--联系客服按钮点击事件
function FriendUI.OnFeedbackBtnClick()
    test("联系客服按钮点击事件")
    local Location = QuestionsAnswersElf.SkipLocationType.Location
    if Location ~= "" and Location ~= nil then
        CL.ShowWeb(Location,QuestionsAnswersElf.SkipLocationType.IsWebSite)
    else
        CL.SendNotify(NOTIFY.ShowBBMsg,"抱歉，客服处于离线状态！")
    end

end

function FriendUI.SetUrlColor(txt)
    local urlInfo = GUI.GetUrlInfo(txt)

    for i = 0, urlInfo.Length - 1 do
        local Data = urlInfo[i]
        if string.find(Data, "Grade:") ~= nil then
            local Grade = tonumber(string.split(Data, "Grade:")[2])
            local c= QuestionsAnswersElf.HyperlinkColor[Grade]
            GUI.SetUrlColor(txt, i, c[1], c[2], c[3], 255)
        end
    end
end

--计时器启动
function FriendUI.StartTimer()
    test("计时器启动")
    local fun = function()
        FriendUI.TimerCallBack()
    end
    FriendUI.StopRefreshTimer()
    FriendUI.RefreshTimer = Timer.New(fun, FriendUITimerValue, -1)
    FriendUI.RefreshTimer:Start()
end

--计时器停止
function FriendUI.StopRefreshTimer()
    if FriendUI.RefreshTimer ~= nil then
        test("计时器关闭")
        FriendUI.RefreshTimer:Stop()
        FriendUI.RefreshTimer = nil
    end
end

--计时器调用函数
function FriendUI.TimerCallBack()
    test("计时器回调时间")

    if searchBtnStatus == 0 then
        if CurSelectBtn == 1 then --最近
            test("计时器请求最近列表")
            CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_friend)
            CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_stranger)
            CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_blacklist)
            CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_recently)
        elseif CurSelectBtn == 2 then --好友，陌生人，黑名单
            test("计时器请求好友，陌生人，黑名单列表")
            CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_friend)
            CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_stranger)
            CL.SendNotify(NOTIFY.FriendListReq, CONTACT_TYPE.contact_blacklist)
        end
    end

end