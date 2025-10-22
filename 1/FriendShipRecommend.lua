local FriendShipRecommend = {}
_G.FriendShipRecommend = FriendShipRecommend

-- 与服务器约定
-- REGISTER_GOAL_MASTER     = 0  -- 收徒
-- REGISTER_GOAL_APPRENTICE = 1 -- 拜师
-- REGISTER_GOAL_MARRY      = 2 --征婚
-- RECOMMEND_GOAL_FRIEND    = 3  --好友
-- 对应本地 FriendShipRecommend.CurrentType

local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")

local _gt = UILayout.NewGUIDUtilTable()
local npcID = 0
local SelectList = {}
local RecommendList = {}
local MarryBtnType = 0
local MasterOrApprentice = 1 --当前选中师傅还是徒弟按钮
local MasterType = 0 --是获取师父信息还是徒弟信息
local MasterBtnType = 0 --0为没有等级 1为师父登记 2为徒弟登记
local TempGuid = {}
local TempName = {}
local BtnDisable = {}
local CurSelectPage = nil -- 当前选中的页面
local RoleLevel = 0
local GUI = GUI
local SearchType = 0
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local colorDark = Color.New(102/255,47/255,22/255,255/255);
local outColor = Color.New(179/255,92/255,31/255,255/255)
local describeColor = Color.New(151/255,92/255,34/255,255/255)   -- Color HexNumber: 975c22ff ，描述&定量内容
local whiteColor    = Color.New(255/255,255/255,255/255,255/255) -- Color HexNumber: ffffffff , 白色文字
local colorType_DarkYellow = Color.New(102/255,47/255,22/255)
FriendShipRecommend.recommendFriends = {}

local CONTACT_TYPE = {
    contact_apply = 1, --//好友申请
    contact_search = 100, --搜索列表
}

FriendShipRecommend.FriendRefreshRemainTime = 0;
FriendShipRecommend.RefreshTimer = nil;


local TipsInfo =
{
    ["好友"] = {"没有喜欢的好友，点击“换一批”试试吧。"},
    ["相亲"] = {"1、点击“征婚”后，才会被推送给异性哦。","2、好友度达到500可以和异性组队在“红娘”npc处登记结婚。","3、未婚异性组队才可结婚。" },
    ["师徒"] = {"1、点击“登记”后，才会被推送给其他玩家哦","2、师父≥50级，25≤徒弟<50级，双方互为好友，可两人组队前往“拜师NPC”处拜师，结为师徒。","3、每个师父同时最多收2名徒弟，徒弟同时只能拜1位师父。",
              "4、徒弟达到50级，且师徒双方至少组队一起战斗过1场后，可组队前往“拜师NPC”处出师。"},
}


local BtnActionTable =
{
    {"江湖险恶，有一两位知己才能百战百胜。此乃近日风头正盛的侠士，何不结交一番？"} ,
    { "在风雨飘摇的江湖之中寻求一位伴侣相随，更可获得强大的姻缘技能。"},
    {"师徒携手闯荡江湖可以带来很多便利，更能通过积分兑换神秘道具。"},
}


FriendShipRecommend.TabTable =
{
    {"好友","friendPageBtn","OnFriendPageBtnClicked"},
    {"相亲","marryPageBtn","OnMarryPageBtnClicked"},
    {"师徒","masterPageBtn","OnMasterPageBtnClicked"},
}

local PageEnum = {
    Friend = 1,
    Marry = 2,
    Master = 3,
}

FriendShipRecommend.SelectItemGuid = nil;
FriendShipRecommend.CurrentType = 3;
FriendShipRecommend.ShowItemList ={};
FriendShipRecommend.JobSpriteList = nil;
FriendShipRecommend.MarryRegisterState = false;
FriendShipRecommend.MasterRegisterState = false ;
FriendShipRecommend.SelfLevel = 1;
FriendShipRecommend.SelfGuid = 1
FriendShipRecommend.ItemBtnShowText = "发送消息";
FriendShipRecommend.CurrentTypePro = "好友"
FriendShipRecommend.MasterOrApprenticeSubType = 0; -- 0 为师父子页签，1 为徒弟子页签
FriendShipRecommend.FriendSystemOpenLevel = 1;   -- 对应open表index 3
FriendShipRecommend.MasterSystemOpenLevel = 15;  --  function_preview：40拜师 41收徒 ，取最低就可以
FriendShipRecommend.MarrySystemOpenLevel  = 28;  --  function_preview：39夫妻
FriendShipRecommend.MasterRegisterLevel   = 50;  --  师父最小登记登记

local CONTACT_FRIEND = 2  --加好友

function FriendShipRecommend.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("FriendShipRecommend" , "FriendShipRecommend" , 0 , 0 ,eCanvasGroup.Normal)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    panel:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(panel, true)

    local panelBg= UILayout.CreateFrame_WndStyle0(panel, "","FriendShipRecommend","OnCloseWnd", _gt);
    _gt.BindName(panelBg, "panelBg")
    local titleText = _gt.GetUI("titleText")
    GUI.StaticSetText(titleText, "好友推荐")

    --顶部文字
    local tipsLabel = GUI.CreateStatic( panelBg,"tipsLabel",BtnActionTable[1][1],0,-240, 1010,56,"system",false,false);
    FriendShipRecommend.SetTextBasicInfo(tipsLabel,describeColor,TextAnchor.MiddleLeft,22) ;
    _gt.BindName(tipsLabel,"tipsLabel")

    local listBg = GUI.ImageCreate( panelBg,"listBg" , "1800400200" , 0 , 10, false , 1010,430);
    GUI.SetAnchor(listBg,UIAnchor.Center);
    GUI.SetPivot(listBg,UIAroundPivot.Center)

    --提示按钮
    local btn = GUI.ButtonCreate(panelBg, "tipsInfoBtn", "1800702030",480,-235, Transition.ColorTint);
    FriendShipRecommend.SetButtonBasicInfo(btn,24,colorDark,"OnTipsBtnClick");

    UILayout.CreateRightTab(FriendShipRecommend.TabTable, "FriendShipRecommend")
    FriendShipRecommend.Init()

    local btnWidth = 144
    local btnHeight = 44

    local masterSubBtn = GUI.ButtonCreate(panelBg,"masterSubBtn", "1800402030",-420,-230, Transition.ColorTint,"",btnWidth,btnHeight,false);
    FriendShipRecommend.SetButtonBasicInfo(masterSubBtn,24,colorDark,"OnMasterSubBtnClick");
    local masterSubBtnTxt = GUI.CreateStatic(masterSubBtn,"masterSubBtnTxt","师父" ,0,0,50,30,"system",true,false);
    FriendShipRecommend.SetTextBasicInfo(masterSubBtnTxt,colorDark,TextAnchor.MiddleCenter,22) ;
    GUI.SetVisible(masterSubBtn,false)
    _gt.BindName(masterSubBtn,"masterSubBtn")

    local apprenticeSubBtn = GUI.ButtonCreate(panelBg,"apprenticeSubBtn", "1800402032",-260,-230, Transition.ColorTint,"",btnWidth,btnHeight,false);
    FriendShipRecommend.SetButtonBasicInfo(apprenticeSubBtn,24,colorDark,"OnApprenticeSubBtnClick");
    local apprenticeSubBtnTxt = GUI.CreateStatic(apprenticeSubBtn,"apprenticeSubBtnTxt","徒弟" ,0,0,50,30,"system",true,false);
    FriendShipRecommend.SetTextBasicInfo(apprenticeSubBtnTxt,colorDark,TextAnchor.MiddleCenter,22) ;
    GUI.SetVisible(apprenticeSubBtn,false)
    _gt.BindName(apprenticeSubBtn,"apprenticeSubBtn")

    --左下角查找按钮
    local  findFriendOrMoveToNPC = GUI.ButtonCreate(panelBg,"findFriendOrMoveToNPC", "1800402080",-425,260, Transition.ColorTint,"",160,47,false);
    FriendShipRecommend.SetButtonBasicInfo(findFriendOrMoveToNPC,24,colorDark,"OnFindOrMoveBtnClick");
    local btnText = GUI.CreateStatic(findFriendOrMoveToNPC,"btnText","查找" ,0,0,120,30,"system",true,false);
    FriendShipRecommend.SetTextBasicInfo(btnText,whiteColor,TextAnchor.MiddleCenter,22) ;
    _gt.BindName(btnText,"btnText")
    GUI.SetIsOutLine(btnText,true)
    GUI.SetOutLine_Color(btnText,outColor)
    GUI.SetOutLine_Distance(btnText,1)

    local  changeBatchBtn = GUI.ButtonCreate(panelBg,"changeBatchBtn", "1800402080",240,260, Transition.ColorTint,"",160,47,false);
    FriendShipRecommend.SetButtonBasicInfo(changeBatchBtn,24,colorDark,"OnChangeBatchBtnClick");
    local changeBatchBtnTxt = GUI.CreateStatic(changeBatchBtn,"changeBatchBtnTxt","换一批" ,0,0,80,30,"system",true,false);
    FriendShipRecommend.SetTextBasicInfo(changeBatchBtnTxt,whiteColor,TextAnchor.MiddleCenter,22) ;
    GUI.SetIsOutLine(changeBatchBtnTxt,true)
    GUI.SetOutLine_Color(changeBatchBtnTxt,outColor)
    GUI.SetOutLine_Distance(changeBatchBtnTxt,1)

    local  sureActionBtn = GUI.ButtonCreate(panelBg,"sureActionBtn", "1800402080",425,260, Transition.ColorTint,"",160,47,false);
    _gt.BindName(sureActionBtn,"sureActionBtn")
    FriendShipRecommend.SetButtonBasicInfo(sureActionBtn,24,colorDark,"OnSureActionBtnClick")

    local sureActionBtnTxt = GUI.CreateStatic( sureActionBtn,"sureActionBtnTxt","全部添加" ,0,0,160,30,"system",true,false);
    FriendShipRecommend.SetTextBasicInfo(sureActionBtnTxt,whiteColor,TextAnchor.MiddleCenter,22) ;
    GUI.SetIsOutLine(sureActionBtnTxt,true)
    GUI.SetOutLine_Color(sureActionBtnTxt,outColor)
    GUI.SetOutLine_Distance(sureActionBtnTxt,1)
    _gt.BindName(sureActionBtnTxt,"sureActionBtnTxt")

    FriendShipRecommend.CreateLoopScroll()
    FriendShipRecommend.CreateLookupUI()
end

function FriendShipRecommend.OnShow(parameter)
    local wnd = GUI.GetWnd("FriendShipRecommend");
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, false)
    -- 选中第一个
    BtnDisable = {}
    RoleLevel = tostring(CL.GetAttr(RoleAttr.RoleAttrLevel,0))
    local index = tonumber(parameter)
    if index == 1 then
        local CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["好友"].Subtab_OpenLevel["推荐好友"]))
        if tonumber(RoleLevel) < CurLevel then
            CL.SendNotify(NOTIFY.ShowBBMsg,"等级不足,推荐好友"..CurLevel.."级开启")
            return
        end
        FriendShipRecommend.OnFriendPageBtnClicked()
        FriendShipRecommend.RefreshUserItemData()
    elseif index == 2 then
        local CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["好友"].Subtab_OpenLevel_2["相亲"]))
        if tonumber(RoleLevel) < CurLevel then
            CL.SendNotify(NOTIFY.ShowBBMsg,"相亲功能"..CurLevel.."级开启")
            FriendShipRecommend.ResetLastSelectPage(CurSelectPage)
            return
        end
        FriendShipRecommend.OnMarryPageBtnClicked()
        FriendShipRecommend.RefreshMarryItemData()
    elseif index == 3 then
        local CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["好友"].Subtab_OpenLevel_2["师徒"]))
        if tonumber(RoleLevel) < CurLevel then
            CL.SendNotify(NOTIFY.ShowBBMsg,"师徒功能"..CurLevel.."级开启")
            FriendShipRecommend.ResetLastSelectPage(CurSelectPage)
            return
        end
        FriendShipRecommend.OnMasterPageBtnClicked()
    end
    GUI.PostEffect()
    GUI.SetVisible(wnd, true)
    FriendShipRecommend.Register()
end

function FriendShipRecommend.Init()

end

--师父按钮功能
function FriendShipRecommend.OnMasterSubBtnClick()
    local apprenticeSubBtn = _gt.GetUI("apprenticeSubBtn")
    GUI.ButtonSetImageID(apprenticeSubBtn,"1800402030")
    local masterSubBtn = _gt.GetUI("masterSubBtn")
    GUI.ButtonSetImageID(masterSubBtn,"1800402032")
    MasterBtnType = CL.GetIntCustomData("TeacherSystem_Register",0)
    local sureActionBtnTxt = _gt.GetUI("sureActionBtnTxt")
    if tonumber(MasterBtnType) == 1 then
        GUI.StaticSetText(sureActionBtnTxt,"取消登记")
    else
        GUI.StaticSetText(sureActionBtnTxt,"登记")
    end
    MasterType = 1
    MasterOrApprentice = 1
    FriendShipRecommend.RefreshMasterItemData()
end

--徒弟按钮功能
function FriendShipRecommend.OnApprenticeSubBtnClick()
    test("徒弟按钮点击事件")
    local apprenticeSubBtn = _gt.GetUI("apprenticeSubBtn")
    GUI.ButtonSetImageID(apprenticeSubBtn,"1800402032")
    local masterSubBtn = _gt.GetUI("masterSubBtn")
    GUI.ButtonSetImageID(masterSubBtn,"1800402030")
    MasterBtnType = CL.GetIntCustomData("TeacherSystem_Register",0)
    local sureActionBtnTxt = _gt.GetUI("sureActionBtnTxt")
    if tonumber(MasterBtnType) == 2 then
        GUI.StaticSetText(sureActionBtnTxt,"取消登记")
    else
        GUI.StaticSetText(sureActionBtnTxt,"登记")
    end
    MasterType = 2
    MasterOrApprentice = 2
    FriendShipRecommend.RefreshMasterItemData()
end

function FriendShipRecommend.CreateLoopScroll()

    local listBg = GUI.Get("FriendShipRecommend/panelBg/listBg")
    local loopScroll=
    GUI.LoopScrollRectCreate(
            listBg,
            "loopScroll",
            -10,
            7,
            990,
            410,
            "FriendShipRecommend",
            "CreateListPool",
            "FriendShipRecommend",
            "OnRefreshLoopScroll",
            0,
            false,
            Vector2.New(490,110),
            2,
            UIAroundPivot.Top,
            UIAnchor.Top,
            false
    )
    _gt.BindName(loopScroll,"loopScroll")
    FriendShipRecommend.loopScroll = loopScroll
    GUI.SetAnchor(loopScroll,UIAnchor.TopRight)
    GUI.SetPivot(loopScroll,UIAroundPivot.TopRight)
    GUI.LoopScrollRectRefreshCells(loopScroll)
    -- 设置每个框的距离
    GUI.ScrollRectSetChildSpacing(loopScroll, Vector2.New(8, 8))
end


function FriendShipRecommend.ResetLastSelectPage(idx)
    UILayout.OnTabClick(idx, FriendShipRecommend.TabTable)
    if CurSelectPage == idx then
        return false
    end
    if CurSelectPage then
        local name = FriendShipRecommend.TabTable[CurSelectPage][2]
        local lastPage = _gt.GetUI(name)
        if lastPage then
            GUI.SetVisible(lastPage, false)
        end
    end
    local titleText = _gt.GetUI("titleText")
    if idx == PageEnum.Friend then
        GUI.StaticSetText(titleText, "好友推荐")
    elseif idx == PageEnum.Marry then
        GUI.StaticSetText(titleText, "相    亲")
    else
        GUI.StaticSetText(titleText, "师徒推荐")
    end
    CurSelectPage = idx
    return true
end

function FriendShipRecommend.CreateListPool()
    local loopScroll = _gt.GetUI("loopScroll")
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(loopScroll)+1

    --选项框
    local itemList  = GUI.ImageCreate(loopScroll,"itemList"..curIndex,"1801100010",0,0,false,500,110,false);
    GUI.SetAnchor(itemList,UIAnchor.Center);
    GUI.SetPivot(itemList,UIAroundPivot.Center);

    --头像边框
    local headIconBg = GUI.ImageCreate( itemList,"headIconBg" , "1800400200" , -190 , 0, false , 85,85);
    GUI.SetAnchor(headIconBg,UIAnchor.Center);
    GUI.SetPivot(headIconBg,UIAroundPivot.Center);

    --头像图标
    local headIcon = GUI.ImageCreate( itemList,"headIcon" , "1800400200" , -190 , 0, false , 75,75);
    GUI.SetAnchor(headIcon,UIAnchor.Center);
    GUI.SetPivot(headIcon,UIAroundPivot.Center);
    HeadIcon.CreateVip(headIcon, 60, 60, 0, 0)

    --帮派图标
    local jobIcon = GUI.ImageCreate( itemList,"jobIcon" , "1800400200" , -120 , -25);
    GUI.SetAnchor(jobIcon,UIAnchor.Center);
    GUI.SetPivot(jobIcon,UIAroundPivot.Center);

    --战斗力图标
    local fightSp = GUI.ImageCreate( itemList,"fightSp" , "1800407010" ,-120 , 20);
    GUI.SetAnchor(fightSp,UIAnchor.Center);
    GUI.SetPivot(fightSp,UIAroundPivot.Center);

    --角色战力
    local fightTip = GUI.CreateStatic(itemList,"fightTip","角色战力：" ,-35,22,140, 30, "system", false, false);
    GUI.StaticSetFontSize(fightTip,22)
    GUI.StaticSetAlignment(fightTip,TextAnchor.MiddleCenter)
    GUI.SetAnchor(fightTip,UIAnchor.Center)
    GUI.SetPivot(fightTip,UIAroundPivot.Center)
    GUI.SetIsOutLine(fightTip,true)
    GUI.SetOutLine_Color(fightTip,outColor)
    GUI.SetOutLine_Distance(fightTip,1)

    --战力数据
    local RoleData = GUI.CreateStatic(itemList,"RoleData","1234567" ,80,22,140, 30, "system", false, false);
    GUI.StaticSetFontSize(RoleData,22)
    GUI.SetAnchor(RoleData,UIAnchor.Center)
    GUI.SetPivot(RoleData,UIAroundPivot.Center)
    GUI.SetColor(RoleData,colorDark)

    --角色名称
    local RoleName = GUI.CreateStatic(itemList,"RoleName","名字是六个字" ,-15,15,150, 30, "system", false, false);
    GUI.StaticSetFontSize(RoleName,22)
    GUI.SetAnchor(RoleName,UIAnchor.Top)
    GUI.SetPivot(RoleName,UIAroundPivot.Top)
    GUI.SetColor(RoleName,colorDark)

    --角色等级
    local LavelName = GUI.CreateStatic(itemList,"LavelName","等级:" ,90,10,50, 40, "system", false, false);
    GUI.StaticSetFontSize(LavelName,20)
    GUI.SetAnchor(LavelName,UIAnchor.Top)
    GUI.SetPivot(LavelName,UIAroundPivot.Top)
    GUI.SetColor(LavelName,describeColor)

    --等级数据
    local  LevelData = GUI.CreateStatic(itemList,"LevelData","120" ,55,15,180, 30, "system", false, false);
    GUI.StaticSetFontSize(LevelData,22)
    GUI.StaticSetAlignment(LevelData, TextAnchor.MiddleRight)
    GUI.SetAnchor(LevelData,UIAnchor.Top)
    GUI.SetPivot(LevelData,UIAroundPivot.Top)
    GUI.SetColor(LevelData,colorDark)

    --添加按钮
    local AddBtn= GUI.ButtonCreate(itemList, "addInfoBtn", "1800402110",170,20,Transition.ColorTint,"添加好友",120,45,false);
    FriendShipRecommend.SetButtonBasicInfo(AddBtn,24,colorDark,"OnAddInfoClick")

    --tips按钮
    local InfoBtn = GUI.ButtonCreate(itemList,"infoBtn", "1800702030",210,-25, Transition.ColorTint);
    FriendShipRecommend.SetButtonBasicInfo(InfoBtn,24,colorDark,"OnInfoBtnClick");

    return itemList;
end
function FriendShipRecommend.OnRefreshLoopScroll(parameter)
    parameter = string.split(parameter , "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2])+1;
    local item=GUI.GetByGuid(guid);

    if not item then
        return
    end
    local headIcon = GUI.GetChild(item,"headIcon")
    local RoleName = GUI.GetChild(item,"RoleName")
    local jobIcon = GUI.GetChild(item,"jobIcon")
    local RoleData = GUI.GetChild(item,"RoleData")
    local LevelData = GUI.GetChild(item,"LevelData")
    local addInfoBtn = GUI.GetChild(item,"addInfoBtn")
    local infoBtn = GUI.GetChild(item,"infoBtn")
    GUI.ButtonSetShowDisable(addInfoBtn, true)
    local temp = RecommendList[index]
    GUI.ImageSetImageID(item,"1801100010")
    if temp then
        if temp.roleId == nil then
            return
        end
        local role = DB.GetRole(tonumber(temp.roleId))
        GUI.ImageSetImageID(headIcon, tostring(role.Head))

        if tostring(temp.name) == tostring(CL.GetRoleName(0)) then
            GUI.ImageSetImageID(item,"1801501040")
        end
        GUI.SetData(addInfoBtn,"RoleGuid",temp.guid)
        GUI.SetData(addInfoBtn,"RoleType",temp.type)
        if temp.type == 3 then
            GUI.SetData(infoBtn,"infoBtnRoleGuid",temp.guid)
            GUI.ButtonSetText(addInfoBtn,"发送消息")
        else
            if BtnDisable[tostring(temp.guid)] == 1 then
                GUI.ButtonSetShowDisable(addInfoBtn, false)
            end
            GUI.ButtonSetText(addInfoBtn,"添加好友")
        end
        GUI.StaticSetText(RoleName,temp.name)
        GUI.SetData(infoBtn,"infoBtnRoleName",temp.name)
        GUI.SetData(addInfoBtn,"addInfoBtnRoleName",temp.name)
        local school = DB.GetSchool(tonumber(temp.school))
        if tonumber(school.Icon) == 0 then
            return
        end
        GUI.ImageSetImageID(jobIcon, tostring(school.Icon))
        GUI.StaticSetText(RoleData,temp.combatPower)
        GUI.StaticSetText(LevelData,temp.level)
        if temp.VipLevel then
            HeadIcon.BindRoleVipLv(headIcon, temp.VipLevel)
        else
            HeadIcon.BindRoleVipLv(headIcon, 0)
        end
    end

end

-- 查看信息
function FriendShipRecommend.OnInfoBtnClick(guid)
    local btn = GUI.GetByGuid(guid);
    local RoleName = GUI.GetData(btn,"infoBtnRoleName")
    if tostring(RoleName) == tostring(CL.GetRoleName(0)) then
        CL.SendNotify(NOTIFY.ShowBBMsg,"无法查看自己的信息")
        return
    end
    if RoleName ~= nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact" , "QueryOfflinePlayerByName" , RoleName)
        return
    end
end

--添加好友
function FriendShipRecommend.OnAddInfoClick(guid)
    local btn = GUI.GetByGuid(guid)
    local roleGuid = GUI.GetData(btn,"RoleGuid")
    test("roleGuid",roleGuid)
    local roleType = tonumber(GUI.GetData(btn,"RoleType"))
    local roleName = GUI.GetData(btn,"addInfoBtnRoleName")
    if tostring(roleName) == tostring(CL.GetRoleName(0)) then
        CL.SendNotify(NOTIFY.ShowBBMsg,"无法给自己发送信息")
        return
    end
    if roleType == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "AcceptApply", roleGuid)
        FriendShipRecommend.RefreshUserItemData()
    end
    if roleType == 2 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyFriend", roleGuid)
        BtnDisable[roleGuid] = 1
        GUI.ButtonSetShowDisable(btn, false)
    end
    if roleType == 3 then
        --添加到陌生人
        if LD.IsMyFriend(tostring(roleGuid)) then
            GUI.OpenWnd("FriendUI",tostring(roleGuid).."#FriendShipRecommendData#2")
        else

            CL.SendNotify(NOTIFY.SubmitForm,"FormContact","AddStrangerList",tostring(roleGuid))
            GUI.OpenWnd("FriendUI",tostring(roleGuid).."#FriendShipRecommendData#1")
        end


        --设置红点表单
        CL.SendNotify(NOTIFY.SubmitForm,"FormContact","get_senders_guid")
    end
end

-- 查找玩家
function FriendShipRecommend.CreateLookupUI()

    local panelBg1 = GUI.Get("FriendShipRecommend/panelBg")
    local lookupUI = GUI.ImageCreate(panelBg1,"lookupUI","1800400220",0,-33,false,1360,960)
    GUI.SetAnchor(lookupUI,UIAnchor.Center)
    GUI.SetPivot(lookupUI,UIAroundPivot.Center)
    _gt.BindName(lookupUI,"lookupUI")
    GUI.SetIsRaycastTarget(lookupUI,true)
    GUI.SetVisible(lookupUI,false)



    local panelBg=GUI.ImageCreate(lookupUI,"panelBg","1800001120",0,0,false,460,290)
    GUI.SetAnchor(panelBg,UIAnchor.Center);
    GUI.SetPivot(panelBg,UIAroundPivot.Center);

    local closeBtn=GUI.ButtonCreate(panelBg,"closeBtn","1800302120",0,0,Transition.ColorTint);
    GUI.SetAnchor(closeBtn,UIAnchor.TopRight)
    GUI.SetPivot(closeBtn,UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn,UCE.PointerClick,"FriendShipRecommend","OnCloseBtnClick_LookupUI")

    local titleBg=GUI.ImageCreate(panelBg,"titleBg","1800001140",0,20,false,268,33)
    GUI.SetAnchor(titleBg,UIAnchor.Top);
    GUI.SetPivot(titleBg,UIAroundPivot.Top);

    local title=GUI.CreateStatic(titleBg,"txt","",0,0,174,30)
    GUI.SetAnchor(title,UIAnchor.Center)
    GUI.SetPivot(title,UIAroundPivot.Center)
    GUI.StaticSetFontSize(title,22)
    GUI.SetColor(title,whiteColor)
    GUI.StaticSetText(title,"输入玩家名称或ID")

    local id=GUI.CreateStatic(panelBg,"id","",25,80,100,30,"system",true)
    GUI.SetAnchor(id,UIAnchor.TopLeft);
    GUI.SetPivot(id,UIAroundPivot.TopLeft);
    GUI.StaticSetFontSize(id,24)
    GUI.SetColor(id,colorDark);
    GUI.StaticSetText(id,"输入  ID")

    local inputField=GUI.EditCreate(panelBg,"inputField","1800400390","",52,70,10,10,Transition.ColorTint,"system",315,50)
    GUI.SetAnchor(inputField,UIAnchor.Top);
    GUI.SetPivot(inputField,UIAroundPivot.Top);
    GUI.EditSetLabelAlignment(inputField,TextAnchor.UpperLeft)
    GUI.EditSetFontSize(inputField,24);
    GUI.EditSetTextColor(inputField,colorType_DarkYellow)
    GUI.EditSetBNumber(inputField,true)
    GUI.RegisterUIEvent(inputField,UCE.EndEdit, "FriendShipRecommend", "OnInput1");
    GUI.RegisterUIEvent(inputField,UCE.PointerClick, "FriendShipRecommend", "OnInputClick");

    local name=GUI.CreateStatic(panelBg,"name","",25,150,120,30,"system",true)
    GUI.SetAnchor(name,UIAnchor.TopLeft);
    GUI.SetPivot(name,UIAroundPivot.TopLeft);
    GUI.StaticSetFontSize(name,24);
    GUI.SetColor(name,colorDark);
    GUI.StaticSetText(name,"输入名称")

    local inputField=GUI.EditCreate(panelBg,"inputField2","1800400390","",52,140,10,10,Transition.ColorTint,"system",315,50)
    GUI.SetAnchor(inputField,UIAnchor.Top);
    GUI.SetPivot(inputField,UIAroundPivot.Top);
    GUI.EditSetLabelAlignment(inputField,TextAnchor.UpperLeft);
    GUI.EditSetFontSize(inputField,24);
    GUI.EditSetTextColor(inputField,colorType_DarkYellow)
    GUI.RegisterUIEvent(inputField,UCE.EndEdit, "FriendShipRecommend", "OnInput2");
    GUI.RegisterUIEvent(inputField,UCE.PointerClick, "FriendShipRecommend", "OnInputClick");

    local concelBtn=GUI.ButtonCreate(panelBg,"concelBtn","1800602030",20,-22,Transition.ColorTint);
    GUI.SetAnchor(concelBtn,UIAnchor.BottomLeft)
    GUI.SetPivot(concelBtn,UIAroundPivot.BottomLeft)

    local btnTxt=GUI.CreateStatic(concelBtn,"btnTxt","",0,0,52,38,"system",true)
    GUI.SetAnchor(btnTxt,UIAnchor.Center);
    GUI.SetPivot(btnTxt,UIAroundPivot.Center);
    GUI.StaticSetFontSize(btnTxt,26);
    GUI.SetColor(btnTxt,whiteColor);
    GUI.StaticSetText(btnTxt,"取消")
    GUI.SetOutLine_Color(btnTxt,outColor);
    GUI.SetOutLine_Distance(btnTxt,1);
    GUI.SetIsOutLine(btnTxt,true);
    GUI.RegisterUIEvent(concelBtn,UCE.PointerClick,"FriendShipRecommend","OnCancelBtnClick_LookupUI");

    local confirmBtn=GUI.ButtonCreate(panelBg,"confirmBtn","1800602030",-20,-22,Transition.ColorTint);
    GUI.SetAnchor(confirmBtn,UIAnchor.BottomRight)
    GUI.SetPivot(confirmBtn,UIAroundPivot.BottomRight)

    local btnTxt=GUI.CreateStatic(confirmBtn,"btnTxt","",0,0,52,38,"system",true)
    GUI.SetAnchor(btnTxt,UIAnchor.Center);
    GUI.SetPivot(btnTxt,UIAroundPivot.Center);
    GUI.StaticSetFontSize(btnTxt,26);
    GUI.SetColor(btnTxt,whiteColor);
    GUI.StaticSetText(btnTxt,"确认")
    GUI.SetOutLine_Color(btnTxt,outColor);
    GUI.SetOutLine_Distance(btnTxt,1);
    GUI.SetIsOutLine(btnTxt,true);
    GUI.RegisterUIEvent(confirmBtn,UCE.PointerClick,"FriendShipRecommend","OnConfirmBtnClick_LookupUI");
end

function FriendShipRecommend.OnCloseBtnClick_LookupUI()
    local lookupUI=_gt.GetUI("lookupUI")
    local inputField1 = GUI.GetChildByPath(lookupUI,"panelBg/inputField")
    local inputField2 = GUI.GetChildByPath(lookupUI,"panelBg/inputField2")
    if inputField1 ~= nil and inputField2 ~= nil then
        GUI.EditSetMaxCharNum(inputField1,50)
        GUI.EditSetMaxCharNum(inputField2,50)
    end
    GUI.SetVisible(lookupUI,false)
end
function FriendShipRecommend.OnInput1(guid)
    local input=GUI.GetByGuid(guid)
    local lookupUI=_gt.GetUI("lookupUI")
    local inputField2 = GUI.GetChildByPath(lookupUI,"panelBg/inputField2")
    local txt=GUI.EditGetTextM(input)
    if txt ~= nil and #txt > 0 then
        GUI.EditSetMaxCharNum(inputField2,0)
    else
        GUI.EditSetMaxCharNum(inputField2,50)
    end
end

function FriendShipRecommend.OnInput2(guid )
    local input=GUI.GetByGuid(guid)
    local lookupUI=_gt.GetUI("lookupUI")
    local inputField1 = GUI.GetChildByPath(lookupUI,"panelBg/inputField")
    local txt=GUI.EditGetTextM(input)
    if txt ~= nil and #txt > 0 then
        GUI.EditSetMaxCharNum(inputField1,0)
    else
        GUI.EditSetMaxCharNum(inputField1,50)
    end
end

function FriendShipRecommend.OnInputClick(guid)
    local lookupUI=_gt.GetUI("lookupUI")
    local inputField1 = GUI.GetChildByPath(lookupUI,"panelBg/inputField")
    local inputField2 = GUI.GetChildByPath(lookupUI,"panelBg/inputField2")
    local key =GUI.GetByGuid(guid)
    local length = 0
    if key == inputField2 then
        length = GUI.EditGetTextM(inputField1)
    elseif key == inputField1 then
        length = GUI.EditGetTextM(inputField2)
    end
    if #length > 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg,"玩家名字或ID只能输入一个")
    end
end
function FriendShipRecommend.OnCancelBtnClick_LookupUI(guid)
    FriendShipRecommend.OnCloseBtnClick_LookupUI(guid)
end

function FriendShipRecommend.OnConfirmBtnClick_LookupUI()
    local lookupUI=_gt.GetUI("lookupUI")
    local inputField = GUI.GetChildByPath(lookupUI,"panelBg/inputField")
    local inputTxt = GUI.EditGetTextM(inputField)
    if inputTxt == nil or #inputTxt == 0 then
        local inputField2 = GUI.GetChildByPath(lookupUI,"panelBg/inputField2")
        inputTxt = nil
        inputTxt = GUI.EditGetTextM(inputField2)
        if inputTxt == nil or #inputTxt == 0 then
            GlobalUtils.ShowBoxMsg2Btn("提示","请输入玩家名字或者ID","FriendShipRecommend","确认","inputEnsure","取消")
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormContact","NotifyContactInfoByName",inputTxt)
            SearchType = 1
            GUI.EditSetTextM(inputField2,"")
        end
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact","NotifyContactInfoBySN",inputTxt)
        SearchType = 1
        GUI.EditSetTextM(inputField,"")
    end
    FriendShipRecommend.OnCloseBtnClick_LookupUI()
end

function FriendShipRecommend.inputEnsure()
end

local TableSet = function(a,b)
    if a.status ~= b.status then
        return a.status > b.status
    end
    if a.last_contact_time ~= b.last_contact_time then
        return a.last_contact_time > b.last_contact_time
    end
    return false
end

function FriendShipRecommend.SelectFriendData(contact_type)
    SelectList = {}
    local list = LD.GetContactDataListByType(contact_type)
    if not list then
        return
    end
    for i = 1, list.Count do
        local data = list[i - 1]
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
        }
        SelectList[#SelectList + 1] = temp
    end
    table.sort(SelectList, TableSet)
end

function FriendShipRecommend.OnCloseWnd()
    GUI.CloseWnd("FriendShipRecommend")
    FriendShipRecommend.OnFriendPageBtnClicked()
end

function FriendShipRecommend.OnPlayerBaseInfoNotify()

    if CONTACT_TYPE.contact_search then

        if #SelectList == 0 then
            return
        end
        local temp = SelectList[1]
        if temp == nil then
            return
        end
        local name = temp.name
        local RoleGuid = temp.guid
        if LD.IsMyFriend(tostring(RoleGuid)) then
            local msg = "玩家" .. name .. "已经是您的好友"
            CL.SendNotify(NOTIFY.ShowBBMsg,msg)
        else
            TempGuid = RoleGuid
            TempName = name
            local msg = "找到名为<color=#ff0000>" .. name .. "</color>的玩家，您是否加他为好友？"
            GlobalUtils.ShowBoxMsg(
                    "提示",
                    msg,
                    "FriendShipRecommend",
                    "确认",
                    "OnMsgBoxOKBtnClick_BeAddedFriend",
                    "取消",
                    "OnClickRefuseBtn",
                    true,
                    "closseMsg",
                    1,
                    30
            )
        end
        SearchType = 2
    else
        SearchType = 2
        return
    end
end
-- 主动添加好友
function FriendShipRecommend.OnMsgBoxOKBtnClick_BeAddedFriend()
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyFriend",TempGuid)
end

-- MsgBox取消
function FriendShipRecommend.OnMsgBoxCancelBtnClick(parameter)
    CL.MessageBoxRemove(parameter)
end

function  FriendShipRecommend.SetTextBasicInfo(txt,color,Anchor,txtSize)
    GUI.SetAnchor(txt,UIAnchor.Center);
    GUI.SetPivot(txt,UIAroundPivot.Center);
    GUI.StaticSetFontSize(txt,txtSize);
    GUI.SetColor(txt,color);
    GUI.StaticSetAlignment(txt,Anchor)
end

function FriendShipRecommend.SetButtonBasicInfo(btn,fontSize,fontColor,functionName)
    GUI.SetPivot(btn,UIAroundPivot.Center)
    GUI.SetAnchor(btn,UIAnchor.Center);
    GUI.ButtonSetTextFontSize(btn,fontSize)
    GUI.ButtonSetTextColor(btn,fontColor)
    GUI.RegisterUIEvent(btn , UCE.PointerClick , "FriendShipRecommend", functionName)
end
function FriendShipRecommend.GenJobSpriteList()
    FriendShipRecommend.JobSpriteList = nil;
    FriendShipRecommend.JobSpriteList = {};

end
function FriendShipRecommend.OnTipsBtnClick()
    if CurSelectPage == 1 then
        local panelBg = GUI.TipsCreate(GUI.Get("FriendShipRecommend/panelBg"), "Tips", 0, 0, 460, 0)
        GUI.SetAnchor(panelBg,UIAnchor.Center)
        GUI.SetPivot(panelBg,UIAroundPivot.Center)
        GUI.SetIsRemoveWhenClick(panelBg, true)
        GUI.SetVisible(GUI.TipsGetItemIcon(panelBg),false)
        local tipstext = GUI.CreateStatic(panelBg,"tipstext",TipsInfo["好友"][1],20,0,400,30,"system", true)
        GUI.StaticSetFontSize(tipstext,20)
        GUI.SetHeight(panelBg,80)
    elseif CurSelectPage == 2 then
        local panelBg = GUI.TipsCreate(GUI.Get("FriendShipRecommend/panelBg"), "Tips", 0, 0, 520, 0)
        GUI.SetAnchor(panelBg,UIAnchor.Center)
        GUI.SetPivot(panelBg,UIAroundPivot.Center)
        GUI.SetIsRemoveWhenClick(panelBg, true)
        GUI.SetVisible(GUI.TipsGetItemIcon(panelBg),false)
        local tipstext = GUI.CreateStatic(panelBg,"tipstext",TipsInfo["相亲"][1],0,-40,480,120,"system", true)
        GUI.StaticSetFontSize(tipstext,20)
        local tipstext1 = GUI.CreateStatic(panelBg,"tipstext",TipsInfo["相亲"][2],0,0,480,120,"system", true)
        GUI.StaticSetFontSize(tipstext1,20)
        local tipstext2 = GUI.CreateStatic(panelBg,"tipstext",TipsInfo["相亲"][3],0,40,480,120,"system", true)
        GUI.StaticSetFontSize(tipstext2,20)
        GUI.SetHeight(panelBg,160)

    elseif CurSelectPage == 3 then
        local panelBg = GUI.TipsCreate(GUI.Get("FriendShipRecommend/panelBg"), "Tips", 0, 0, 520, 86)
        GUI.SetAnchor(panelBg,UIAnchor.Center)
        GUI.SetPivot(panelBg,UIAroundPivot.Center)
        GUI.SetIsRemoveWhenClick(panelBg, true)
        GUI.SetVisible(GUI.TipsGetItemIcon(panelBg),false)
        local tipstext = GUI.CreateStatic(panelBg,"tipstext",TipsInfo["师徒"][1],0,-74,480,120,"system", true)
        GUI.StaticSetFontSize(tipstext,20)
        local tipstext1 = GUI.CreateStatic(panelBg,"tipstext",TipsInfo["师徒"][2],0,-34,480,120,"system", true)
        GUI.StaticSetFontSize(tipstext1,20)
        local tipstext2 = GUI.CreateStatic(panelBg,"tipstext",TipsInfo["师徒"][3],0,16,480,120,"system", true)
        GUI.StaticSetFontSize(tipstext2,20)
        local tipstext3 = GUI.CreateStatic(panelBg,"tipstext",TipsInfo["师徒"][4],0,66,480,120,"system", true)
        GUI.StaticSetFontSize(tipstext3,20)
    end
end
function FriendShipRecommend.OnExit()
    local wnd = GUI.GetWnd("FriendShipRecommend")
    if wnd ~= nil then
        FriendShipRecommend.UnRegister()
        GUI.DestroyWnd("FriendShipRecommend");
    end
end

--好友推荐
function FriendShipRecommend.OnFriendPageBtnClicked(key)
    local CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["好友"].Subtab_OpenLevel["推荐好友"]))
    if tonumber(RoleLevel) < CurLevel then
        CL.SendNotify(NOTIFY.ShowBBMsg,"等级不足,推荐好友"..CurLevel.."级开启")
    end
    if not FriendShipRecommend.ResetLastSelectPage(PageEnum.Friend) then
        return
    end
    if FriendShipRecommend.FriendRefreshRemainTime > 0 then
        local sureActionBtn = _gt.GetUI("sureActionBtn")
        GUI.ButtonSetShowDisable(sureActionBtn, false)
    end

    CurSelectPage = 1
    SearchType = 2
    local btnText = _gt.GetUI("btnText")
    GUI.StaticSetText(btnText,"查  找")
    local sureActionBtnTxt = _gt.GetUI("sureActionBtnTxt")
    GUI.StaticSetText(sureActionBtnTxt,"全部添加")

    local tipsLabel = _gt.GetUI("tipsLabel")
    GUI.SetVisible(tipsLabel,true)
    GUI.StaticSetText(tipsLabel,BtnActionTable[1][1])

    local masterSubBtn = _gt.GetUI("masterSubBtn")
    GUI.SetVisible(masterSubBtn,false)
    local apprenticeSubBtn = _gt.GetUI("apprenticeSubBtn")
    GUI.SetVisible(apprenticeSubBtn,false)

    FriendShipRecommend.RefreshUserItemData()--发送列表数据
end

-- 相亲
function FriendShipRecommend.OnMarryPageBtnClicked()
    local CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["好友"].Subtab_OpenLevel_2["相亲"]))
    if tonumber(RoleLevel) < CurLevel then
        CL.SendNotify(NOTIFY.ShowBBMsg,"相亲功能"..CurLevel.."级开启")
        FriendShipRecommend.ResetLastSelectPage(CurSelectPage)
        return
    end
    if not FriendShipRecommend.ResetLastSelectPage(PageEnum.Marry) then
        return
    end

    local sureActionBtn = _gt.GetUI("sureActionBtn")
    GUI.ButtonSetShowDisable(sureActionBtn, true)

    CurSelectPage = 2
    FriendShipRecommend.RefreshMarryItemData()
    MarryBtnType= CL.GetIntCustomData("is_register_blind_date",0)


    local btnText = _gt.GetUI("btnText")
    local sureActionBtnTxt = _gt.GetUI("sureActionBtnTxt")

    GUI.StaticSetText(btnText,"前往结婚")

    if MarryBtnType == 0 then
        GUI.StaticSetText(sureActionBtnTxt,"征婚")
    elseif MarryBtnType == 1 then
        GUI.StaticSetText(sureActionBtnTxt,"取消征婚")
    end

    local tipsLabel = _gt.GetUI("tipsLabel")
    GUI.SetVisible(tipsLabel,true)
    GUI.StaticSetText(tipsLabel,BtnActionTable[2][1])
    local masterSubBtn = _gt.GetUI("masterSubBtn")
    GUI.SetVisible(masterSubBtn,false)
    local apprenticeSubBtn = _gt.GetUI("apprenticeSubBtn")
    GUI.SetVisible(apprenticeSubBtn,false)
end
-- 师徒
function FriendShipRecommend.OnMasterPageBtnClicked()
    local CurLevel = tonumber(tostring(MainUI.MainUISwitchConfig["好友"].Subtab_OpenLevel_2["师徒"]))
    if tonumber(RoleLevel) < CurLevel then
        CL.SendNotify(NOTIFY.ShowBBMsg,"师徒功能"..CurLevel.."级开启")
        FriendShipRecommend.ResetLastSelectPage(CurSelectPage)
        return
    end
    if not FriendShipRecommend.ResetLastSelectPage(PageEnum.Master) then
        return
    end

    local sureActionBtn = _gt.GetUI("sureActionBtn")
    GUI.ButtonSetShowDisable(sureActionBtn, true)

    CurSelectPage = 3
    local btnText = _gt.GetUI("btnText")
    local sureActionBtnTxt = _gt.GetUI("sureActionBtnTxt")
    GUI.StaticSetText(btnText,"前往收徒")
    MasterBtnType = CL.GetIntCustomData("TeacherSystem_Register",0)

    if tonumber(MasterBtnType) == 0 then
        GUI.StaticSetText(sureActionBtnTxt,"登记")
    else
        GUI.StaticSetText(sureActionBtnTxt,"取消登记")
    end
    if tonumber(RoleLevel) < 50 then
        FriendShipRecommend.OnApprenticeSubBtnClick()
    else
        FriendShipRecommend.OnMasterSubBtnClick()
    end

    local tipsLabel = _gt.GetUI("tipsLabel")
    GUI.SetVisible(tipsLabel,false)
    local masterSubBtn = _gt.GetUI("masterSubBtn")
    GUI.SetVisible(masterSubBtn,true)
    local apprenticeSubBtn = _gt.GetUI("apprenticeSubBtn")
    GUI.SetVisible(apprenticeSubBtn,true)

end

function FriendShipRecommend.OnFindOrMoveBtnClick(key)
    if CurSelectPage == 1  then
        local lookupUI = _gt.GetUI("lookupUI")
        local inputField = GUI.GetChildByPath(lookupUI,"panelBg/inputField")
        local inputField2 = GUI.GetChildByPath(lookupUI,"panelBg/inputField2")
        GUI.EditSetTextM(inputField,"")
        GUI.EditSetTextM(inputField2,"")
        GUI.SetVisible(lookupUI,true)
        return
    elseif CurSelectPage == 2 then-- 结婚
        npcID = 20041
        LD.StartAutoMove(npcID)
    elseif CurSelectPage == 3 then-- 拜师收徒
        npcID = 20039
        LD.StartAutoMove(npcID)
    end
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法执行该操作")
        return
    end
    FriendShipRecommend.OnExit()
end

function FriendShipRecommend.OnChangeBatchBtnClick(guid)
    local  item = GUI.GetByGuid(guid)
    GUI.SetEventCD(item,UCE.PointerClick,1.5)
    if CurSelectPage == 1 then
        FriendShipRecommend.RefreshUserItemData()
    elseif CurSelectPage == 2 then
        FriendShipRecommend.RefreshMarryItemData()
    elseif CurSelectPage == 3 then
        FriendShipRecommend.RefreshMasterItemData()
    end
    CL.SendNotify(NOTIFY.ShowBBMsg,"刷新成功")
end

function FriendShipRecommend.OnSureActionBtnClick(guid)
    if CurSelectPage == 1 then   -- 好友推荐界面为添加所有好友
        local guidList = ""
        for i=1 , #RecommendList do
            local item = RecommendList[i]
            if tostring(CL.GetRoleName(0)) ~= tostring(item.name)  then
                guidList = guidList..tostring(item.guid).."_"
                BtnDisable[tostring(item.guid)] = 1
            end
        end
        guidList = string.sub(guidList, 1, -2)
        CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "ApplyAll", guidList)
        FriendShipRecommend.RefreshUseItems()
        FriendShipRecommend.StartTimer()


    elseif CurSelectPage == 2 then  -- 相亲界面为登记到列表中
        if MarryBtnType == 0 then
            local sureActionBtnTxt = _gt.GetUI("sureActionBtnTxt")
            GUI.StaticSetText(sureActionBtnTxt,"取消征婚")
            CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","blind_date_register")
            MarryBtnType = 1
        elseif MarryBtnType == 1 then
            local sureActionBtnTxt = _gt.GetUI("sureActionBtnTxt")
            GUI.StaticSetText(sureActionBtnTxt,"征婚")
            CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","blind_date_unregister")
            MarryBtnType = 0
        end
        FriendShipRecommend.RefreshMarryItemData()

    elseif CurSelectPage == 3 then  -- 师徒界面为登记到列表中
        -- 判断是登记到师父还是徒弟
        MasterBtnType = CL.GetIntCustomData("TeacherSystem_Register",0)
        --在师父的分页上
        if MasterOrApprentice == 1 then
            if tonumber(RoleLevel) < 50 then
                CL.SendNotify(NOTIFY.ShowBBMsg,"您的等级不足，请继续努力吧")
                return
            end
            if MasterBtnType == 0 then
                CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","teacher_register")
            end
            if MasterBtnType == 1 then
                CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","remove_register")
            end
            --在徒弟的分页上
        elseif MasterOrApprentice == 2 then
            if tonumber(RoleLevel) >= 50 then
                CL.SendNotify(NOTIFY.ShowBBMsg,"您的等级过高，请登记师父名册")
                return
            end
            if tonumber(MasterBtnType) == 0 then
                CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","pupil_register")
            end
            if tonumber(MasterBtnType) == 2 then
                CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","remove_register")
            end
        end
    end
end
-- 设置登记状态  showType 类型 ； state：状态 0 为否 1为是
function FriendShipRecommend.SetRegisterState(showType,state)
    showType = tonumber(showType)
    if showType ==nil then
        return;
    end
    state = tonumber(state)
    state = state == 1 or false;
    if showType ==2 then
        FriendShipRecommend.MarryRegisterState = state;
        if state then
            FriendShipRecommend.SetSureActionBtnTxt("取消征婚")
        else
            FriendShipRecommend.SetSureActionBtnTxt("征  婚")
        end
    elseif showType == 0 or showType == 1 then
        FriendShipRecommend.MasterRegisterState = state ;
        if state then
            FriendShipRecommend.SetSureActionBtnTxt("取消登记")
        else
            FriendShipRecommend.SetSureActionBtnTxt("登  记")
        end
    elseif showType == 3 then
        FriendShipRecommend.SetSureActionBtnTxt("全部添加")
    end

end


function FriendShipRecommend.StartTimer()
    local fun = function()
        FriendShipRecommend.RefreshBtnTime()
        return nil;
    end
    FriendShipRecommend.FriendRefreshRemainTime = 30
    FriendShipRecommend.StopRefreshTimer()
    FriendShipRecommend.RefreshTimer = Timer.New(fun, 1, -1)
    FriendShipRecommend.RefreshTimer:Start()

end
-- 刷新按钮上的时间
function FriendShipRecommend.RefreshBtnTime()
    local sureActionBtnTxt = _gt.GetUI("sureActionBtnTxt")
    local sureActionBtn = _gt.GetUI("sureActionBtn")
    if  FriendShipRecommend.FriendRefreshRemainTime > 0 then
        FriendShipRecommend.FriendRefreshRemainTime  =  FriendShipRecommend.FriendRefreshRemainTime - 1
    end
    if FriendShipRecommend.FriendRefreshRemainTime < 1  then
        FriendShipRecommend.StopRefreshTimer();
    end
    if CurSelectPage == 1 then
        GUI.StaticSetText(sureActionBtnTxt,"全部添加"..( FriendShipRecommend.FriendRefreshRemainTime > 0 and "(" ..FriendShipRecommend.FriendRefreshRemainTime..")" or "" ))
    end
    if CurSelectPage ~= 1 or FriendShipRecommend.FriendRefreshRemainTime <1  then
        GUI.ButtonSetShowDisable(sureActionBtn, true)
    else
        GUI.ButtonSetShowDisable(sureActionBtn, false)
    end
end

function FriendShipRecommend.StopRefreshTimer()
    if FriendShipRecommend.RefreshTimer ~= nil then
        FriendShipRecommend.RefreshTimer:Stop();
        FriendShipRecommend.RefreshTimer = nil;
    end
end

function FriendShipRecommend.OnDestroy()
    FriendShipRecommend.StopRefreshTimer()
end

function FriendShipRecommend.Contains(guid, tb)
    if not guid or not tb then return end
    guid = tostring(guid)
    for i = 1, #tb do
        if guid == tostring(tb[i].guid) then
            return true
        end
    end
    return false
end

function FriendShipRecommend.RefreshUseApply()
    if CurSelectPage == 1 then
    end
    RecommendList = {}

    for k,v in pairs(FriendShipRecommend.recommendFriends) do
        local t = {}
        if not FriendShipRecommend.Contains(tostring(k), RecommendList) then
            t.guid = tostring(k)
            t.level = v.level
            t.combatPower = v.combatPower
            t.roleId = v.roleId
            t.kind = tostring(v.kind)
            t.name = v.name
            t.school = v.school
            t.type = 2
            t.VipLevel = v.vip_level
            table.insert(RecommendList, t)
        end
    end
    FriendShipRecommend.RefreshUseItems()
end


function FriendShipRecommend.RefreshMarryRole()
    RecommendList = {}
    local SelfRole = CL.GetRoleName(0)
    for k,v in pairs(FriendShipRecommend.MarryRecommend) do
        local t = {}
        t.guid = v.guid
        t.name = v.name
        t.level = v.level
        t.combatPower = v.combatPower
        t.roleId = v.roleId
        t.school = v.school
        t.type = 3
        t.VipLevel = v.vip_level
        if v.name == SelfRole then
            table.insert(RecommendList,1,t)
        else
            table.insert(RecommendList, t)
        end

    end
    FriendShipRecommend.RefreshUseItems()
end

function FriendShipRecommend.RefreshMasterButton()
    MasterBtnType = CL.GetIntCustomData("TeacherSystem_Register",0)
    local sureActionBtnTxt = _gt.GetUI("sureActionBtnTxt")
    if tonumber(MasterBtnType) == 0 then
        GUI.StaticSetText(sureActionBtnTxt,"登记")
    else
        GUI.StaticSetText(sureActionBtnTxt,"取消登记")
    end
    FriendShipRecommend.RefreshMasterItemData()
end

function FriendShipRecommend.RefreshMasterRole()
    RecommendList = {}
    local SelfRole = CL.GetRoleName(0)
    for k,v in pairs(FriendShipRecommend.MasterRecommend) do
        local t = {}
        t.guid = v.guid
        t.name = v.name
        t.level = v.level
        t.combatPower = v.fight_value
        t.roleId = v.role_id
        t.school = v.school
        t.VipLevel = v.vip
        t.type = 3
        if v.name == SelfRole then
            table.insert(RecommendList,1, t)
        else
            table.insert(RecommendList, t)
        end
    end
    FriendShipRecommend.RefreshUseItems()
end

function FriendShipRecommend.RefreshUserItemData()
    CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","GetRecommendFriend")
end

function FriendShipRecommend.RefreshMarryItemData()
    CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","get_blind_date_data")
end

function FriendShipRecommend.RefreshMasterItemData()
    test("师徒请求发送")
    CL.SendNotify(NOTIFY.SubmitForm,"FormFriend","get_mentoring_data",MasterType)
end

function FriendShipRecommend.FriendType(contact_type)

    if CONTACT_TYPE.contact_search == contact_type and SearchType == 1 then
        FriendShipRecommend.SelectFriendData(CONTACT_TYPE.contact_search)
        FriendShipRecommend.OnPlayerBaseInfoNotify()
    end

end

function FriendShipRecommend.Register()
    CL.RegisterMessage(GM.FriendListUpdate, "FriendShipRecommend", "FriendType")
end

function FriendShipRecommend.UnRegister()
    CL.UnRegisterMessage(GM.FriendListUpdate, "FriendShipRecommend", "FriendType")
end

function FriendShipRecommend.RefreshUseItems()
    local wnd = GUI.GetWnd("FriendShipRecommend")
    if wnd == nil then
        return
    end
    if  #RecommendList > 0 then
        GUI.LoopScrollRectSetTotalCount(FriendShipRecommend.loopScroll, #RecommendList);
        GUI.LoopScrollRectRefreshCells(FriendShipRecommend.loopScroll)
    else
        GUI.LoopScrollRectSetTotalCount(FriendShipRecommend.loopScroll ,0)
    end
end
