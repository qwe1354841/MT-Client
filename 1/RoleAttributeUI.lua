local RoleAttributeUI = {}

_G.RoleAttributeUI = RoleAttributeUI
local GuidCacheUtil = nil -- UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local UCE = UCE
local Transition = Transition
local split = string.split
local tonumber = tonumber
------------------------------------ end缓存一下全局变量end --------------------------------

local currentEpxerience = 0
local maxEpxerience = 0
local itemList = {}
local needTipsTitleChange = false
RoleAttributeUI.IsInfight = false
RoleAttributeUI.SelectTitleId = 0
RoleAttributeUI.TabBtnGroup = {}
RoleAttributeUI.CanAddBloodItems = nil
RoleAttributeUI.CanAddBlueItems = nil
RoleAttributeUI.CurSelectItemId = 0
RoleAttributeUI.CurSelectItemIndex = 0
RoleAttributeUI.CurSelectItemGUID = "0"
RoleAttributeUI.NeedResetItemScrorectPosition = true
RoleAttributeUI.ItemListRealCount = 0
RoleAttributeUI.IsShowWndRefreshData = false
RoleAttributeUI.TabIndex = 1 

-- 官职相关的一些变量
RoleAttributeUI.CurrentOfficePosition = "平头百姓"  -- 当前官职
RoleAttributeUI.CurrentSelectOffice = "平头百姓"   -- 选中的查看的官职
RoleAttributeUI.TotalOfficePositionList = {}        -- 所有官职的列表
RoleAttributeUI.OfficialPosition_ActivityConfig = {}    --获取官职战功活动的信息

-- 增加血量或者蓝量界面点击后
RoleAttributeUI.FirstOpenItemScroll = true
RoleAttributeUI.SelfTemplateID = 0

-- 善恶值变量

local LabelList = {
    { "属性", "attributePageBtn", "OnAttributePageBtnClicked" },
    { "详情", "detailPageBtn", "OnDetailPageBtnClicked" },
}
local attributeList1 = {
    { "气血", "bloodSlider", "1800408120", "1800408110", "410" },
    { "法力", "blueSlider", "1800408130", "1800408110", "410" },
    { "怒气", "yellowSlider", "1800408140", "1800408110", "410" },
    { "活力", "vitalitySlider", "1800408150", "1800408110", "320" },
}
local attributeList2 = {
    { "物攻", "phyAttack", "1800407040" },
    { "物防", "phyDefence", "1800407050" },
    { "物暴", "phyBurstRate", "1800407060" },
    { "封印", "seal", "1801507210" },
    { "闪避", "miss", "1800407100" },
    { "速度", "speed", "1800407120" },

    { "法攻", "magicAttack", "1801507180" },
    { "法防", "magDefence", "1801507190" },
    { "法暴", "magBurstRate", "1801507200" },
    { "封抗", "antiSeal", "1801507220" },
    { "命中", "hit", "1800407110" },
}

local attributeList3 = {
    { "称号", "title", "更换", "OnChangeTitleBtnClick" },
    { "门派", "school", "回门派", "OnBackSchoolClick" },
    { "帮派", "faction", "回帮派", "OnBackFactionClick" },
    { "夫妻", "couple" },
    { "师父", "master" },
    { "徒弟", "apprentice" },
}
-- 标签  组件名  按钮文字   按钮方法   寻路的NPC名称  打开的脚本名称
local attributeList4 = {
    { "善恶值", "beevil", "清空", "OnBeevilBtnClick" },
    { "良师值", "mentor", "兑换", "OnMentorBtnClick" },
    { "荣誉值", "honor", "兑换", "OnHonorBtnClick" },
    { "奇遇值", "adventure", "兑换", "OnAdventureBtnClick" },
    { "战功点", "battleMerit", "兑换", "OnBattleMeritBtnClick" },
    --{ "帮战积分", "integral", "兑换", "OnIntegralBtnClick" },
    { "装备功勋", "equipMerit", "兑换", "OnEquipMeritBtnClick" }, -- ???
    { "宠物功勋", "petMerit", "兑换", "OnPetMeritBtnClick" },
    -- { "战场积分", "battleground", "兑换", "OnBattlegroundBtnClick" }, --???
}

local attributeEventList = {
    -- 回调方法，是否需要初始化
    [RoleAttr.RoleAttrLevel] = { "SelfLevelChange", true },
    [RoleAttr.RoleAttrJob1] = { "SelfSchoolChange", true },
    [RoleAttr.RoleAttrRemainPoint] = { "SelfRemainPointChange", true },
    [RoleAttr.RoleAttrHp] = { "SelfBloodChange", true },
    [RoleAttr.RoleAttrHpLimit] = { "SelfMaxBloodChange", false },
    [RoleAttr.RoleAttrMp] = { "SelfBlueChange", true },
    [RoleAttr.RoleAttrMpLimit] = { "SelfMaxBlueChange", false },
    [RoleAttr.RoleAttrSp] = { "SelfSpChange", true },
    [RoleAttr.RoleAttrSpLimit] = { "SelfMaxSpChange", false },
    [RoleAttr.RoleAttrVp] = { "SelfVitalityChange", true },
    [RoleAttr.RoleAttrVpLimit] = { "SelfMaxVitalityChange", false },
    [RoleAttr.RoleAttrFightValue] = { "SelfFightValueChange", true },
    [RoleAttr.RoleAttrPhyAtk] = { "SelfPhyAttackChange", true },
    [RoleAttr.RoleAttrPhyDef] = { "SelfPhyAttackDefChange", true },
    [RoleAttr.RoleAttrPhyBurstRate] = { "SelfPhyBurstRateChange", true },
    [RoleAttr.RoleAttrMagAtk] = { "SelfMagAttackChange", true },
    [RoleAttr.RoleAttrMagDef] = { "SelfMagAttackDefChange", true },
    [RoleAttr.RoleAttrMagBurstRate] = { "SelfMagBurstRateChange", true },
    [RoleAttr.RoleAttrSealRate] = { "SelfSealRateChange", true },
    [RoleAttr.RoleAttrSealResistRate] = { "SelfSealResistRateChange", true },
    [RoleAttr.RoleAttrMissRate] = { "SelfMissRateChange", true },
    [RoleAttr.RoleAttrHitRate] = { "SelfHitRateChange", true },

    [RoleAttr.RoleAttrFightSpeed] = { "SelfSpeedChange", true },
    [RoleAttr.RoleAttrStr] = { "SelfStrengthPointChange", true },
    [RoleAttr.RoleAttrInt] = { "SelfMagicPointChange", true },
    [RoleAttr.RoleAttrVit] = { "SelfVitalityPointChange", true },
    [RoleAttr.RoleAttrEnd] = { "SelfEndurancePointChange", true },
    [RoleAttr.RoleAttrAgi] = { "SelfAgilityPointChange", true },
    [RoleAttr.RoleAttrPK] = { "SelfBeevilChange", true },
    [RoleAttr.RoleAttrHpPool] = { "SelfBloodStoreChange", true },
    [RoleAttr.RoleAttrMpPool] = { "SelfBlueStoreChange", true },
    [RoleAttr.RoleAttrExp] = { "SelfExperienceChange", true },
    [RoleAttr.RoleAttrTitle] = { "SelfTitleChange", true },
    [RoleAttr.RoleAttrCanPk] = { "SelfPkStateChange", true },

    [RoleAttr.RoleAttrMentor] = {"SelfRoleAttrChange", true, "mentor"}, --良师值
    [RoleAttr.RoleAttrHonor] = {"SelfRoleAttrChange", true, "honor" },  -- 荣誉值
    [RoleAttr.RoleAttrAdv] = {"SelfRoleAttrChange", true, "adventure"}, -- 奇遇值
    [RoleAttr.RoleAttrPvp] = {"SelfRoleAttrChange", true, "battleMerit"}, -- 战功点
}

local messageEventList = {
    --{ "SelfCoupleChange", GM.SpouseNameChange },
    --{ "SelfMasterNameChange", GM.MasterNameChange },
    --{ "SelfGuildNameChange", GM.GuildNameChange },
    --{ "SelfApprenticeNameChange", GM.ApprenticeNameChange },
    --{ "ShowForm", GM.ShowForm },
    --{ "OnBackFactionAck", GM.FactionOperateBack },
    --{ "OnBackSchoolAck", GM.GoBackSchoolSuccess },
    { "OnInFightRoleAttrChange", GM.FightRoleAttrChange }, --战斗中血量蓝量根骨值等变化
    { "OnInFight", GM.FightStateNtf }, --进出战斗事件
    { "OnRoleChangeName", GM.ChangeName },
    {"OnCustomDataUpdate", GM.CustomDataUpdate}
}

local customAttrList = {
    ["EquipExploit"] = "equipMerit",
    ["PetExploit"] = "petMerit"
}

local roleSpriteInfo = {
    --烟云客
    [33] = { "1800107030", "600001989", "(0,2.65,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 傲红莲
    [38] = { "1800107080", "600001885", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 谪剑仙
    [31] = { "1800107010", "600001779", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 凤凰仙
    [42] = { "1800107120", "600001959", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 阎魔令
    [35] = { "1800107050", "600001995", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 青丘狐
    [40] = { "1800107100", "3000001490", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 冥河使
    [34] = { "1800107040", "600001982", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 花弄影
    [39] = { "1800107090", "600001837", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 雨师君
    [36] = { "1800107060", "600001880", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
    -- 海鲛灵
    [41] = { "1800107110", "600001956", "(0,2.24,-3),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 飞翼姬
    [32] = { "1800107020", "600001842", "(0,2.24,-3.25),(0,0,0,1),True,5,0.42,4.27,60" },
    -- 神霄卫
    [37] = { "1800107070", "600001921", "(0,2.4,-3),(0,0,0,1),True,5,0.42,4.5,60" },
}

--pk图标
local pkIconPicture = { "1800202380", "1800202381", "1800202383" }

local colorDark = UIDefine.BrownColor
local colorYellow = UIDefine.Yellow2Color
local outLineColor = UIDefine.OutLine_BrownColor
local defaultColor = Color.white

local ImportantInfoColor = UIDefine.BrownColor
local ButtonStairColor_2 = UIDefine.BrownColor
local DescribeColor = UIDefine.BrownColor
local PanelNumberColor = UIDefine.Brown6Color

local sizeDefault = UIDefine.FontSizeS
local sizeBig = UIDefine.FontSizeM

function RoleAttributeUI.Main(parameter)
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("RoleAttributeUI", "RoleAttributeUI", 0, 0, eCanvasGroup.Normal)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "角  色", "RoleAttributeUI", "OnExit", GuidCacheUtil)

    UILayout.CreateRightTab(LabelList, "RoleAttributeUI")

    local page1 = GUI.GroupCreate(panelBg, "page1", 0, -10, 1, 1)
    GuidCacheUtil.BindName(page1, "page1")
    SetAnchorAndPivot(page1, UIAnchor.Center, UIAroundPivot.Center)
    local page2 = GUI.GroupCreate(panelBg, "page2", 0, 0, 1, 1)
    GuidCacheUtil.BindName(page2, "page2")
    SetAnchorAndPivot(page2, UIAnchor.Center, UIAroundPivot.Center)

    RoleAttributeUI.CreateAttributePage(page1)
    RoleAttributeUI.CreateOfficePositionPage(page1)
    RoleAttributeUI.CreateDetailPage(page2)
    RoleAttributeUI.CreateAddBloodOrBluePage(page2)
    RoleAttributeUI.CreatePKBtnTips(page2)
end

function RoleAttributeUI.OnClose()
    RoleAttributeUI.DestroyRoleModel()
end

function RoleAttributeUI.DestroyRoleModel()
    local model = GuidCacheUtil.GetUI("roleModel")
    if model then
        GUI.Destroy(model)
    end
end

function RoleAttributeUI.CreateRoleModel()
    local rolePanelBg = GuidCacheUtil.GetUI("rolePanelBg")
    local animroot = GuidCacheUtil.GetUI("2D")
    if not animroot then
        animroot = GUI.RawImageCreate(rolePanelBg, true, "2D", nil, 0, 0, 3, false, 600, 600)
        GuidCacheUtil.BindName(animroot, "2D")
    end
    RoleAttributeUI.SelfTemplateID = CL.GetRoleTemplateID()
    if not RoleAttributeUI.SelfTemplateID or RoleAttributeUI.SelfTemplateID == 0 then
        return
    end
    local resKey = roleSpriteInfo[RoleAttributeUI.SelfTemplateID][2]
    if resKey then
        local name = "roleModel"
        local anim = GUI.GetChild(animroot, name)
        if anim == nil then
            anim = GUI.RawImageChildCreate(animroot, false, name, resKey, 0, 0)
            GuidCacheUtil.BindName(anim, name)
            GUI.AddToCamera(animroot)
        end
        GUI.RawImageSetCameraConfig(animroot, roleSpriteInfo[RoleAttributeUI.SelfTemplateID][3])
        GUI.BindPrefabWithChild(animroot, GuidCacheUtil.GetGuid(name))
    end
end

function RoleAttributeUI.OnShow(parameter)
    local wnd = GUI.GetWnd("RoleAttributeUI")
    if not wnd then
        return
    end
    GUI.SetVisible(wnd, true)

    RoleAttributeUI.SelfTemplateID = 0
    RoleAttributeUI.CreateRoleModel()

    RoleAttributeUI.IsInfight = CL.GetFightState()

    local idx = UIDefine.GetParameter1(parameter)
    if idx == 2 then
        RoleAttributeUI.OnDetailPageBtnClicked()
    elseif idx == 101 then
        -- 101 是从成就-成长-官职 跳转过来的
        local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
        -- local OfficeOpenLevel = UIDefine.OfficialPosition_OpenLevel
        -- 详情按钮是官职-详情
        local OfficeOpenLevel = MainUI.MainUISwitchConfig["角色"].Subtab_OpenLevel["详情"]
        if OfficeOpenLevel == nil then
            CL.SendNotify(NOTIFY.ShowBBMsg, "官职功能 42 级开启")
            RoleAttributeUI.OnExit()
        elseif roleLevel < OfficeOpenLevel then
            CL.SendNotify(NOTIFY.ShowBBMsg, "官职功能 " .. OfficeOpenLevel .. " 级开启")
            RoleAttributeUI.OnExit()
        else
            RoleAttributeUI.OnAttributePageBtnClicked()
            RoleAttributeUI.OnOfficePositionDetailClick()
        end
    else
        RoleAttributeUI.OnAttributePageBtnClicked() -- 默认打开第一个页面
    end
    RoleAttributeUI.Init()
    RoleAttributeUI.GetNowPositionData() -- 获取官职相关信息
end
--创建属性面板
function RoleAttributeUI.CreateAttributePage(parent)
    if parent == nil then
        test("parent is nil on CreateAttributePage")
        return
    end

    local attributePageBG1 = GUI.ImageCreate(parent, "attributePageBG1", "1800400190", 261, 17, false, 525, 549)
    SetAnchorAndPivot(attributePageBG1, UIAnchor.Center, UIAroundPivot.Center)
    --上部属性
    for i = 1, #attributeList1 do
        local label = GUI.CreateStatic(attributePageBG1, attributeList1[i][2] .. "label", attributeList1[i][1], 50, i * 45 - 15, 100, 35, "system", true)
        RoleAttributeUI.SetTextBasicInfo(label, ImportantInfoColor, TextAnchor.MiddleCenter, 24, UIAnchor.TopLeft, UIAroundPivot.Center)
        Tips.RegisterAttrHintEvent(label, "RoleAttributeUI")

        local name = attributeList1[i][2]
        local tempSlider = GUI.ScrollBarCreate(label, name, "", attributeList1[i][3], attributeList1[i][4], 250, 0, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
        GuidCacheUtil.BindName(tempSlider, name)
        local silderFillSize = Vector2.New(tonumber(attributeList1[i][5]), 24)
        RoleAttributeUI.SetSliderBasicInfo(tempSlider, silderFillSize, UIAnchor.Center, UIAroundPivot.Left)
        name = attributeList1[i][2] .. "Txtlabel"
        local currentTxt = GUI.CreateStatic(tempSlider, name, "3200/3200", 0, 0, 300, 35, "system", true)
        GuidCacheUtil.BindName(currentTxt, name)
        RoleAttributeUI.SetTextBasicInfo(currentTxt, nil, TextAnchor.MiddleCenter, 20, UIAnchor.Center, UIAroundPivot.Center)

        if i == 4 then
            GUI.SetPositionX(tempSlider, 204)
            local useBtn = GUI.ButtonCreate(label, "useBtn", "1800402110", 415, 0, Transition.ColorTint, "使用", 92, 40, false)
            RoleAttributeUI.SetButtonBasicInfo(useBtn, "OnUseBtnClick", 24, ButtonStairColor_2, UIAnchor.Center, UIAroundPivot.Center)
        end
    end
    --下部属性
    local attributePageBG2 = GUI.ImageCreate(parent, "attributePageBG2", "1800400200", 260, 88, false, 506, 310)
    SetAnchorAndPivot(attributePageBG2, UIAnchor.Center, UIAroundPivot.Center)

    local sepIdx = 6
    local distance = 60
    local x, y
    for i = 1, #attributeList2 do
        if i <= sepIdx then
            x = 40
            y = i * 40 - 15
        else
            x = 290
            y = (i - sepIdx) * 40 - 15
        end
        local tempSprite = GUI.ImageCreate(attributePageBG2, attributeList2[i][2] .. "Icon", attributeList2[i][3], x, y)
        SetAnchorAndPivot(tempSprite, UIAnchor.TopLeft, UIAroundPivot.Center)
        local label = GUI.CreateStatic(attributePageBG2, attributeList2[i][2] .. "label", attributeList2[i][1], x + distance, y, 60, 25, "system", true)
        Tips.RegisterAttrHintEvent(label, "RoleAttributeUI")
        RoleAttributeUI.SetTextBasicInfo(label, DescribeColor, TextAnchor.MiddleCenter, 20, UIAnchor.TopLeft, UIAroundPivot.Center)
        local name = attributeList2[i][2] .. "Txtlabel"
        local currentTxt = GUI.CreateStatic(label, name, "0", 90, 0, 110, 25, "system", true)
        GuidCacheUtil.BindName(currentTxt, name)
        RoleAttributeUI.SetTextBasicInfo(currentTxt, PanelNumberColor, TextAnchor.MiddleCenter, 20, UIAnchor.Center, UIAroundPivot.Center)
    end

    local remainPointArea = GUI.CreateStatic(attributePageBG2, "remainPointArea", "可分配点数", 70, 255, 120, 30);
    GUI.SetColor(remainPointArea, UIDefine.BrownColor);
    GUI.StaticSetFontSize(remainPointArea, UIDefine.FontSizeM)
    UILayout.SetSameAnchorAndPivot(remainPointArea, UILayout.TopLeft);

    local bg = GUI.ImageCreate(remainPointArea, "bg", "1800700010", 128, 1, false, 160, 35);
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Left);

    local remainPointText = GUI.CreateStatic(bg, "remainPointText", "0", 0, -1, 160, 30);
    GUI.SetColor(remainPointText, UIDefine.White2Color);
    GUI.StaticSetFontSize(remainPointText, UIDefine.FontSizeM);
    GUI.StaticSetAlignment(remainPointText, TextAnchor.MiddleCenter);
    GuidCacheUtil.BindName(remainPointText, "remainPointText")

    local addPointBtn = GUI.ButtonCreate(bg, "addPointBtn", "1800402110", 165, 0, Transition.ColorTint, "加点", 80, 40, false);
    GUI.ButtonSetTextColor(addPointBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(addPointBtn, UIDefine.FontSizeM)
    GuidCacheUtil.BindName(addPointBtn, "addPointBtn")
    GUI.RegisterUIEvent(addPointBtn, UCE.PointerClick, "RoleAttributeUI", "OnAddPointBtnClick")
    GUI.AddRedPoint(addPointBtn, UIAnchor.TopLeft, 5, 5)
    GUI.SetRedPointVisable(addPointBtn, false)

    --经验相关
    local experienceBg = GUI.ImageCreate(parent, "experienceBg", "1800404010", 43, 259, false, 50, 28)
    SetAnchorAndPivot(experienceBg, UIAnchor.Center, UIAroundPivot.Center)
    local name = "experienceSlider"
    local experienceSlider = GUI.ScrollBarCreate(experienceBg, name, "", "1800408160", "1800408110", 35, 0, 426, 24, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    GuidCacheUtil.BindName(experienceSlider, name)
    local silderFillSize = Vector2.New(426, 24)
    RoleAttributeUI.SetSliderBasicInfo(experienceSlider, silderFillSize, UIAnchor.Center, UIAroundPivot.Left)
    local name = "experienceSliderCurrentTxt"
    local experienceSliderCurrentTxt = GUI.CreateStatic(experienceBg, name, "3200/3200", 248, 0, 426, 25, "system", true)
    GuidCacheUtil.BindName(experienceSliderCurrentTxt, name)
    RoleAttributeUI.SetTextBasicInfo(experienceSliderCurrentTxt, nil, TextAnchor.MiddleCenter, 20, UIAnchor.Center, UIAroundPivot.Center)

    local name = "rolePanelBg"
    local rolePanelBg = GUI.GroupCreate(parent, name, -300, 0, 1, 1)
    GuidCacheUtil.BindName(rolePanelBg, name)
    SetAnchorAndPivot(rolePanelBg, UIAnchor.Center, UIAroundPivot.Center)

    --人物面板中  人物立绘
    RoleAttributeUI.CreateRoleModel()
    --人物面板顶
    local fightBg = GUI.ImageCreate(rolePanelBg, "fightBg", "1801300180", 0, -240, false, 333, 52);
    SetAnchorAndPivot(fightBg, UIAnchor.Center, UIAroundPivot.Center)
    local fightFlower1 = GUI.ImageCreate(fightBg, "fightFlower1", "1800407010", -90, 0);
    SetAnchorAndPivot(fightFlower1, UIAnchor.Center, UIAroundPivot.Center)
    local fightFlower2 = GUI.ImageCreate(fightBg, "fightFlower2", "1801405360", -20, 0);
    SetAnchorAndPivot(fightFlower2, UIAnchor.Center, UIAroundPivot.Center)
    local fightTxt = GUI.CreateStatic(fightBg, "fightTxt", "0", 35, 1, 150, 30, "system", true, false);
    GuidCacheUtil.BindName(fightTxt, "fightTxt")
    GUI.SetPivot(fightTxt, UIAroundPivot.Left);
    GUI.StaticSetAlignment(fightTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(fightTxt, sizeBig);
    GUI.SetColor(fightTxt, colorDark);
    local scoreHint = GUI.ButtonCreate(fightBg, "scoreHint", "1800702030", -127, 0, Transition.ColorTint, "")
    SetAnchorAndPivot(scoreHint, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(scoreHint, UCE.PointerClick, "RoleAttributeUI", "OnScoreHintBtnClick")
    --local fightBg = GUI.ImageCreate(rolePanelBg, "fightBg", "1801300180", 30, -240, false, 300, 52)
    --SetAnchorAndPivot(fightBg, UIAnchor.Center, UIAroundPivot.Center)
    --local titleLabel = GUI.CreateStatic(fightBg, "titleLabel", "称号", -160, 1, 150, 30, "system", true, false)
    --RoleAttributeUI.SetTextBasicInfo(titleLabel, colorDark, TextAnchor.MiddleLeft, sizeBig, UIAnchor.Center, UIAroundPivot.Left)
    --local name = "roleTitleTxt"
    --local roleTitleTxt = GUI.CreateStatic(fightBg, name, "100000", 0, 1, 230, 30, "system", true, false)
    --GuidCacheUtil.BindName(roleTitleTxt, name)
    --RoleAttributeUI.SetTextBasicInfo(roleTitleTxt, colorDark, TextAnchor.MiddleCenter, sizeBig, UIAnchor.Center, UIAroundPivot.Center)
    --
    --local aniSp = GUI.SpriteFrameCreate(fightBg, "aniSp", "", 40, -6)
    --GuidCacheUtil.BindName(aniSp, "aniSp")
    --
    --local titleBtn = GUI.ButtonCreate(fightBg, "titleBtn", "1800202340", 135, 0, Transition.ColorTint, "", 40, 40, false)
    --SetAnchorAndPivot(titleBtn, UIAnchor.Center, UIAroundPivot.Center)
    --local redpoint = GUI.GetChild(titleBtn, "redpoint")
    --GUI.SetPositionX(redpoint, 11)
    --GUI.SetPositionY(redpoint, 12)
    --GUI.RegisterUIEvent(titleBtn, UCE.PointerClick, "RoleAttributeUI", "OnClickTitleBtn")

    -- 人物种族
    local officePosition = GUI.GroupCreate(parent, "officePosition", -300, 192, 1, 1);
    SetAnchorAndPivot(officePosition, UIAnchor.Center, UIAroundPivot.Center)
    local officeSp1 = GUI.ImageCreate(officePosition, "officePositionSp", "1801205240", -140, 0);
    SetAnchorAndPivot(officeSp1, UIAnchor.Center, UIAroundPivot.Center)
    local officeSp2 = GUI.ImageCreate(officePosition, "officePositionBg", "1801201180", 0, 0, false, 200, 38);
    SetAnchorAndPivot(officeSp2, UIAnchor.Center, UIAroundPivot.Center)

    local officePositionText = GUI.CreateStatic(officePosition, "officePositionText", "无名小吏", 0, 1, 200, 30, "system", true, false);
    GuidCacheUtil.BindName(officePositionText, "officePositionText")
    RoleAttributeUI.SetTextBasicInfo(officePositionText, UIDefine.BrownColor, TextAnchor.MiddleCenter, 22)
    local officePositionBtn = GUI.ButtonCreate(officePosition, "officePositionBtn", "1800402110", 160, 1, Transition.ColorTint, "详情", 82, 38, false);
    RoleAttributeUI.SetButtonBasicInfo(officePositionBtn, "OnOfficePositionDetailClick")

    GuidCacheUtil.BindName(officePositionBtn, "officePositionBtn")
    GUI.AddRedPoint(officePositionBtn,UIAnchor.TopLeft,5,5,"1800208080")
    GUI.SetRedPointVisable(officePositionBtn,false)

    --人物面板底
    local infoBg = GUI.ImageCreate(rolePanelBg, "infoBg", "1801300170", 0, 240)
    SetAnchorAndPivot(infoBg, UIAnchor.Center, UIAroundPivot.Center)

    local jobSprite = GUI.ImageCreate(infoBg, "jobSprite", "1800903010", -115, 0)
    GuidCacheUtil.BindName(jobSprite, "jobSprite")
    SetAnchorAndPivot(jobSprite, UIAnchor.Center, UIAroundPivot.Center)

    local name = "levelTxt"
    local levelTxt = GUI.CreateStatic(infoBg, name, "1 级", -50, 1, 70, 25, "system", true)
    GuidCacheUtil.BindName(levelTxt, name)
    RoleAttributeUI.SetTextBasicInfo(levelTxt, nil, TextAnchor.MiddleLeft, 20, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsOutLine(levelTxt, true)
    GUI.SetOutLine_Color(levelTxt, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(levelTxt, UIDefine.OutLineDistance)

    local uiName = "nameTxt"
    local nameTxt = GUI.CreateStatic(infoBg, uiName, "六个字的名字", 60, 1, 140, 25, "system", true, false)
    GuidCacheUtil.BindName(nameTxt, uiName)
    RoleAttributeUI.SetTextBasicInfo(nameTxt, ImportantInfoColor, TextAnchor.MiddleLeft, 20, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSizeBestFit(nameTxt)
    local roleIDTip = GUI.CreateStatic(rolePanelBg, "roleIDTip", "角色ID：", -50, 280, 80, 30, "system", true)
    local ExplainColor = Color.New(168 / 255, 120 / 255, 16 / 255, 255 / 255)
    RoleAttributeUI.SetTextBasicInfo(roleIDTip, ExplainColor, TextAnchor.MiddleLeft, 20, UIAnchor.Center, UIAroundPivot.Center)
    local roleIDTxt = GUI.CreateStatic(roleIDTip, "roleIDTxt", "789456123", 90, 0, 100, 30, "system", true, false)
    GuidCacheUtil.BindName(roleIDTxt, "roleIDTxt")
    RoleAttributeUI.SetTextBasicInfo(roleIDTxt, ExplainColor, TextAnchor.MiddleLeft, 20, UIAnchor.Center, UIAroundPivot.Center)

    local changeName = GUI.ButtonCreate(infoBg, "changeName", "1800402120", 160, 0, Transition.ColorTint, "")
    RoleAttributeUI.SetButtonBasicInfo(changeName, "OnChangeNameBtnClick")

    local guardAddArrTip = GUI.ButtonCreate(parent, "guardAddArrTip", "1801202200", -110, -180, Transition.ColorTint)
    SetAnchorAndPivot(guardAddArrTip, UIAnchor.Center, UIAroundPivot.Center)
    local sp = GUI.ImageCreate(guardAddArrTip, "sp", "1801205140", 0, 6)
    SetAnchorAndPivot(sp, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.SetVisible(guardAddArrTip, false)
    GUI.RegisterUIEvent(guardAddArrTip, UCE.PointerClick, "RoleAttributeUI", "OnGuardAddArrBtnClick")
end

function RoleAttributeUI.OnScoreHintBtnClick()
    --角色战力
    local fightValue = CL.GetAttr(RoleAttr.RoleAttrFightValue)

    --上阵宠物
    local petNum = 0
    --local linup_pet_guid = GlobalUtils.GetMainLineUpPetGuid()
    --test("===linup_pet_guid===="..tostring(linup_pet_guid))
    --petNum = LD.GetPetAttr(RoleAttr.RoleAttrFightValue, linup_pet_guid)
    local petList=LD.GetPetGuids()
    for i = 0, petList.Count-1 do
        local id = petList[i]
        --local state = tostring(LD.GetPetAttr(id, RoleAttr.PetAttrStatus))--获取宠物状态，>宠物状态：bit0:绑定 bit1:锁定 bit2:展示 bit3:上阵
        local isLineup = LD.GetPetState(PetState.Lineup,id)
        if isLineup then
            local zl = LD.GetPetAttr(RoleAttr.RoleAttrFightValue, id)
            petNum = petNum + zl
        end
    end

    --上阵侍从
    local guardNum = 0
    local activeGuardList = LD.GetActivedGuard()
    for i = 0,activeGuardList.Count-1 do
        local id = activeGuardList[i]
        local linup = tostring(LD.GetGuardAttr(id,RoleAttr.GuardAttrIsLinup))
        if linup == "1" then --已上阵的
            local zl = LD.GetGuardAttr(id,RoleAttr.RoleAttrFightValue)
            --test("=========zl======="..tostring(zl))
            guardNum = guardNum + zl
        end
    end

    --总战力
    local totalNum = fightValue + petNum + guardNum

    local parent = GuidCacheUtil.GetUI("rolePanelBg")
    local zongzhanli_desc = "总战力=角色战力+上阵宠物战力+上阵侍从战力"
    local zongzhanli_num = "总战力:".."<color=yellow>"..tostring(totalNum).."</color>"
    local jusezhanli_num = "角色战力:".."<color=yellow>"..tostring(fightValue).."</color>"
    local petzhanli_num = "上阵宠物战力:".."<color=yellow>"..tostring(petNum).."</color>"
    local guardzhanli_num = "上阵侍从战力:".."<color=yellow>"..tostring(guardNum).."</color>"
    local info = string.format("%s\n%s\n%s\n%s\n%s",zongzhanli_desc,zongzhanli_num,jusezhanli_num,petzhanli_num,guardzhanli_num)
    Tips.CreateHint(info, parent, 100, -130, {UIAnchor.Center, UIAroundPivot.Center}, 480,150,true)
    
end

--创建详情面板
function RoleAttributeUI.CreateDetailPage(parent)
    if parent == nil then
        --test("parent is nil on CreateDetailPage")
        return
    end

    local bloodStore = GUI.CreateStatic(parent, "bloodStore", "血量储备", -460, -240, 100, 30, "system", true, false);
    RoleAttributeUI.SetTextBasicInfo(bloodStore, colorDark, TextAnchor.MiddleLeft, 24)
    local bloodStoreSlider = GUI.ScrollBarCreate(bloodStore, "bloodStoreSlider", "", "1800408120", "1800408110", 140, 27, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    local silderFillSize = Vector2.New(380, 24);
    GuidCacheUtil.BindName(bloodStoreSlider, "bloodStoreSlider")
    RoleAttributeUI.SetSliderBasicInfo(bloodStoreSlider, silderFillSize)
    local bloodTxt = GUI.CreateStatic(bloodStoreSlider, "bloodTxt", "3200/3200", 0, 0, 200, 30, "system", true, false);
    RoleAttributeUI.SetTextBasicInfo(bloodTxt, defaultColor, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(bloodTxt, UIDefine.FontSizeS)
    GuidCacheUtil.BindName(bloodTxt, "bloodStoreTxt")
    local bloodSupBtn = GUI.ButtonCreate(bloodStore, "bloodSupBtn", "1800402110", 380, 27, Transition.ColorTint, "补充", 92, 38, false);
    RoleAttributeUI.SetButtonBasicInfo(bloodSupBtn, "OnBloodSupBtnClick")
    GUI.ButtonSetTextFontSize(bloodSupBtn, 22)
    --RoleAttributeUI.SetBloodSliderData("blood")

    local blueStore = GUI.CreateStatic(parent, "blueStore", "魔法储备", -460, -170, 100, 30, "system", true, false);
    RoleAttributeUI.SetTextBasicInfo(blueStore, colorDark, TextAnchor.MiddleLeft, 24)
    local blueStoreSlider = GUI.ScrollBarCreate(blueStore, "blueStoreSlider", "", "1800408130", "1800408110", 140, 27, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    RoleAttributeUI.SetSliderBasicInfo(blueStoreSlider, silderFillSize)
    GuidCacheUtil.BindName(blueStoreSlider, "blueStoreSlider")
    local blueTxt = GUI.CreateStatic(blueStoreSlider, "blueTxt", "3200/3200", 0, 0, 200, 30, "system", true, false);
    RoleAttributeUI.SetTextBasicInfo(blueTxt, defaultColor, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(blueTxt, UIDefine.FontSizeS)
    GuidCacheUtil.BindName(blueTxt, "blueStoreTxt")
    local blueSupBtn = GUI.ButtonCreate(blueStore, "blueSupBtn", "1800402110", 380, 27, Transition.ColorTint, "补充", 92, 38, false);
    RoleAttributeUI.SetButtonBasicInfo(blueSupBtn, "OnBlueSupBtnClick")
    GUI.ButtonSetTextFontSize(blueSupBtn, 22)
    --RoleAttributeUI.SetBloodSliderData("blue")

    local cutOffLine = GUI.ImageCreate(parent, "cutOffLine", "1800400310", -260, -105, false, 500, 3);
    SetAnchorAndPivot(cutOffLine, UIAnchor.Center, UIAroundPivot.Center)

    for i = 1, #attributeList3 do
        local tempLable = GUI.CreateStatic(parent, attributeList3[i][2] .. "Tip", attributeList3[i][1], -485, i * 60 - 120, 50, 35);
        RoleAttributeUI.SetTextBasicInfo(tempLable, colorDark, TextAnchor.MiddleLeft, 24)
        local tempSprite = GUI.ImageCreate(tempLable, attributeList3[i][2] .. "Sprite", "1800700010", 130, 0, false, 190, 35);
        SetAnchorAndPivot(tempSprite, UIAnchor.Center, UIAroundPivot.Center)
        local tempLable2 = GUI.CreateStatic(tempLable, attributeList3[i][2] .. "Txt", "无", 130, 0, 180, 30, "system", true, false);
        GUI.StaticSetFontSizeBestFit(tempLable2);
        RoleAttributeUI.SetTextBasicInfo(tempLable2, defaultColor, TextAnchor.MiddleCenter, 22)
        if i ~= 6 and attributeList3[i][3] ~= nil then
            if i ~= 1 then
                local tempBtn = GUI.ButtonCreate(tempLable, attributeList3[i][2] .. "Btn", "1800402110", 280, 0, Transition.ColorTint, attributeList3[i][3], 92, 38, false);
                RoleAttributeUI.SetButtonBasicInfo(tempBtn, attributeList3[i][4])
                --GUI.ButtonSetShowDisable(tempBtn,false)
            else
                local tempBtn = GUI.ButtonCreate(tempLable, attributeList3[i][2] .. "Btn", "1800402110", 280, 0, Transition.ColorTint, attributeList3[i][3], 92, 38, false);
                RoleAttributeUI.SetButtonBasicInfo(tempBtn, attributeList3[i][4])
            end
        end

        if i == 2 then
            local tempBtn = GUI.ButtonCreate(tempLable, "roleTransferBtn", "1800402110", 380, 0, Transition.ColorTint, "转门派", 92, 38, false);
            RoleAttributeUI.SetButtonBasicInfo(tempBtn, "OnRoleTransferBtnClick")
        end

        if i == 6 then
            local apprenticeSp2 = GUI.ImageCreate(tempLable, attributeList3[i][2] .. "Sprite2", "1800700010", 330, 0, false, 190, 35);
            SetAnchorAndPivot(apprenticeSp2, UIAnchor.Center, UIAroundPivot.Center)
            local apprenticeLable2 = GUI.CreateStatic(tempLable, attributeList3[i][2] .. "Txt2", "无", 330, 0, 180, 30, "system", true, false);
            GUI.StaticSetFontSizeBestFit(apprenticeLable2);
            RoleAttributeUI.SetTextBasicInfo(apprenticeLable2, defaultColor, TextAnchor.MiddleCenter, 22)
        end
    end

    local detailPageBg2 = GUI.ImageCreate(parent, "detailPageBg2", "1800400350", 261, 7, false, 525, 549);
    SetAnchorAndPivot(detailPageBg2, UIAnchor.Center, UIAroundPivot.Center)
    for i = 1, #attributeList4 do
        local name = attributeList4[i][2]
        local tempLable = GUI.CreateStatic(parent, name .. "Tip", attributeList4[i][1], 90, i * 73 - 290, 120, 30, "system", true, false);
        RoleAttributeUI.SetTextBasicInfo(tempLable, colorDark, TextAnchor.MiddleLeft, 24)
        local tempLable2 = GUI.CreateStatic(tempLable, name.."Txt", "0", 140, 0, 120, 30, "system", true, false);
        GuidCacheUtil.BindName(tempLable2, name)
        RoleAttributeUI.SetTextBasicInfo(tempLable2, colorYellow, TextAnchor.MiddleCenter, 24)
        local tempBtn = GUI.ButtonCreate(tempLable, name .. "Btn", "1800402110", 280, 0, Transition.ColorTint, attributeList4[i][3], 92, 38, false);
        RoleAttributeUI.SetButtonBasicInfo(tempBtn, attributeList4[i][4])
        GUI.ButtonSetTextFontSize(tempBtn, 22);
        --GUI.ButtonSetShowDisable(tempBtn,i==1)
        --PK 的 Icon 图标
        if i == 1 then
            local pkIcon = GUI.ImageCreate(tempLable, "pkIcon", "", 380, 0, false, 50, 50)
            GuidCacheUtil.BindName(pkIcon, "pkIcon")
            GUI.SetIsRaycastTarget(pkIcon, true)
            pkIcon:RegisterEvent(UCE.PointerClick)
            GUI.RegisterUIEvent(pkIcon, UCE.PointerClick, "RoleAttributeUI", "OnPKIconClick")
        end
    end
end

function RoleAttributeUI.OnAddPointBtnClick(guid)
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = "加点"
	local Level = MainUI.MainUISwitchConfig["角色"].Subtab_OpenLevel_2[Key]
	if CurLevel >= Level then
		GUI.OpenWnd("AddPointUI")
		AddPointUI.SetPlayer()
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		return
	end
end

function RoleAttributeUI.OnRoleTransferBtnClick()
    --达到70级才能使用该功能
    local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    if roleLevel < 70 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "达到70级才能使用该功能")
        return
    end
	LD.StartAutoMove("20091")
    RoleAttributeUI.OnExit()
end

-- 点击属性列表
function RoleAttributeUI.AttrListBtnClick()
    RoleAttributeUI.RefreshAttributeListPanel()
end

-- 点击转生修正
function RoleAttributeUI.ReincarnateUpdateBtnClick()
    local value = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
    if value <= 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "转生后开启")
        return
    end
    GUI.OpenWnd("TurnBornAttrTipUI")
end

function RoleAttributeUI.OnClickTitleBtn(guid)
    GUI.OpenWnd("TitleUI")
end

function RoleAttributeUI.SetTextBasicInfo(txt, color, alignment, txtSize, uiAnchor, pivot)
    if not txt then
        return
    end
    SetAnchorAndPivot(txt, uiAnchor or UIAnchor.Center, pivot or UIAroundPivot.Center)
    GUI.StaticSetFontSize(txt, txtSize or sizeDefault)
    if color then
        GUI.SetColor(txt, color)
    end
    GUI.StaticSetAlignment(txt, alignment or TextAnchor.MiddleLeft)
end

function RoleAttributeUI.SetSliderBasicInfo(Slider, size, uiAnchor, pivot)
    if not Slider then
        return
    end
    GUI.ScrollBarSetFillSize(Slider, size) -- size参数不能为空
    GUI.ScrollBarSetBgSize(Slider, size)
    SetAnchorAndPivot(Slider, uiAnchor or UIAnchor.Center, pivot or UIAroundPivot.Left)
end

----------------------------------- 官职功能Star ---------------------------------

--点击官职详情按钮
function RoleAttributeUI.OnOfficePositionDetailClick()
    local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    -- local OfficeOpenLevel = UIDefine.OfficialPosition_OpenLevel
    -- 详情按钮是官职-详情
    local OfficeOpenLevel = MainUI.MainUISwitchConfig["角色"].Subtab_OpenLevel["详情"]
    --test("官职功能 " .. OfficeOpenLevel .. " 级开启")
    if OfficeOpenLevel == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "官职功能 42 级开启")
        return ;
    elseif roleLevel < OfficeOpenLevel then
        CL.SendNotify(NOTIFY.ShowBBMsg, "官职功能 " .. OfficeOpenLevel .. " 级开启")
        return ;
    end
    --test("OnOfficePositionDetailClick")
    local officeDetail = GuidCacheUtil.GetUI("officeDetail")
    if officeDetail then
        GUI.SetVisible(officeDetail, true);
        --test("showOfficeDetail")
        RoleAttributeUI.OnOfficeAdvanceClick()
    end
end

-- 获取官职相关数据
function RoleAttributeUI.GetNowPositionData()
    RoleAttributeUI.TotalOfficePositionList = UIDefine.OfficialPositionData
    RoleAttributeUI.OfficialPosition_ActivityConfig = UIDefine.OfficialPosition_ActivityConfig
    CL.SendNotify(NOTIFY.SubmitForm, "FormOfficialPosition", "GetNowPositionData")
    --RoleAttributeUI.TotalOfficePositionList = {
    --    {"无名小吏","无名小吏" ,554,"物防 +1_ 法防+1",0, 50000, 1800408280,5},
    --    {"正九品","九品.兵曹",537,"物防 +3_ 法防+3",75, 100000, 1800408280,5},
    --    {"正八品","八品.校尉",538,"物防 +5_ 法防+5",150, 200000,1800408280 ,5},
    --    {"正七品","七品.武骑尉",539,"物防+7_法防+7" ,300,300000,1800408280,5},
    --    {"正六品","六品.骁骑尉",540, "物防 +9_ 法防+9",600 , 400000 , 1800408280,5},
    --}
    --RoleAttributeUI.OfficialPosition_ActivityConfig = {
    --    {activeid = 20,NPCid = 21074},
    --    {activeid = 22,NPCid = 21075},
    --}
end

-- 设置当前的官职
function RoleAttributeUI.SetCurrentOfficePosition(currentOffice)
    if not GuidCacheUtil then
        return
    end
    local officePositionText = GuidCacheUtil.GetUI("officePositionText")
    if officePositionText then
        GUI.StaticSetText(officePositionText, currentOffice);
    end
    RoleAttributeUI.CurrentOfficePosition = currentOffice;
end

--创建官职详情页面
function RoleAttributeUI.CreateOfficePositionPage(parent)
    if parent == nil then
        test("parent is nil on CreateOfficePositionPage")
        return
    end

    local officeDetail = GUI.GroupCreate(parent, "officeDetail", 0, -23, 1, 1);
    GuidCacheUtil.BindName(officeDetail, "officeDetail")
    local bgSp = UILayout.CreateFrame_WndStyle2(officeDetail, "官 职", 710, 550, "RoleAttributeUI", "OnOfficePositionClose", GuidCacheUtil)
    local coverSp = GUI.GetChild(officeDetail, "panelCover")

    local wnd = GUI.GetWnd("RoleAttributeUI")
    GUI.SetWidth(coverSp, GUI.GetWidth(wnd));
    GUI.SetHeight(coverSp, GUI.GetHeight(wnd));

    local officePositionAdvance = GUI.ButtonCreate(bgSp, "officePositionAdvance", "1800402030", -268, -195, Transition.ColorTint, "官职进阶", 115, 38, false, false);
    GuidCacheUtil.BindName(officePositionAdvance, "officePositionAdvance")
    SetAnchorAndPivot(officePositionAdvance, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(officePositionAdvance, true);
    officePositionAdvance:RegisterEvent(UCE.PointerClick);
    RoleAttributeUI.SetButtonBasicInfo(officePositionAdvance, "OnOfficeAdvanceClick", 22, RoleAttributeUI.ImportantInfoColor)

    local officeTipBtn = GUI.ButtonCreate(bgSp, "officeTipBtn", "1800702030", 300, -190, Transition.ColorTint);
    GuidCacheUtil.BindName(officeTipBtn, "officeTipBtn")
    RoleAttributeUI.SetButtonBasicInfo(officeTipBtn, "OnOfficeTipBtnClick", 24, RoleAttributeUI.ImportantInfoColor)

    local officePositionAll = GUI.ButtonCreate(bgSp, "officePositionAll", "1800402030", -150, -195, Transition.ColorTint, "总 览", 115, 38, false, false);
    GuidCacheUtil.BindName(officePositionAll, "officePositionAll")
    SetAnchorAndPivot(officePositionAll, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(officePositionAll, true);
    officePositionAll:RegisterEvent(UCE.PointerClick);
    RoleAttributeUI.SetButtonBasicInfo(officePositionAll, "OnOfficeAdvanceAllClick", 22, RoleAttributeUI.ImportantInfoColor)

    local infoBg = GUI.ImageCreate(bgSp, "advanceInfoBg", "1800400010", 0, 7, false, 650, 350);
    GuidCacheUtil.BindName(infoBg, "advanceInfoBg")
    GUI.SetAnchor(infoBg, UIAnchor.Center);
    GUI.SetPivot(infoBg, UIAroundPivot.Center);

    local officeNameTipSp = GUI.ImageCreate(infoBg, "officeNameTipSp", "1800001030", 0, -140);
    GUI.SetAnchor(officeNameTipSp, UIAnchor.Center);
    GUI.SetPivot(officeNameTipSp, UIAroundPivot.Center);
    local officeNameTipText = GUI.CreateStatic(officeNameTipSp, "officeNameTipText", "官职名", 0, 0, 200, 30, "system", true, false)
    RoleAttributeUI.SetTextBasicInfo(officeNameTipText, defaultColor, TextAnchor.MiddleCenter, 22)

    local currentOfficeBg = GUI.ImageCreate(infoBg, "currentOfficeBg", "1801202020", -150, -90, false, 210, 55);
    GUI.SetAnchor(currentOfficeBg, UIAnchor.Center);
    GUI.SetPivot(currentOfficeBg, UIAroundPivot.Center);
    local currentOfficeText = GUI.CreateStatic(currentOfficeBg, "currentOfficeText", "", 0, 0, 200, 30, "system", true, false)
    GuidCacheUtil.BindName(currentOfficeText, "currentOfficeText")
    RoleAttributeUI.SetTextBasicInfo(currentOfficeText, ImportantInfoColor, TextAnchor.MiddleCenter, 22)

    local officeNextSp = GUI.ImageCreate(infoBg, "nextSp", "1800707050", 0, -90);
    GUI.SetAnchor(officeNextSp, UIAnchor.Center);
    GUI.SetPivot(officeNextSp, UIAroundPivot.Center);
    local nextOfficeBg = GUI.ImageCreate(infoBg, "nextOfficeBg", "1801202020", 150, -90, false, 210, 55);
    GUI.SetAnchor(nextOfficeBg, UIAnchor.Center);
    GUI.SetPivot(nextOfficeBg, UIAroundPivot.Center);
    local nextOfficeText = GUI.CreateStatic(nextOfficeBg, "nextOfficeText", "", 0, 0, 200, 30, "system", true, false)
    GuidCacheUtil.BindName(nextOfficeText, "nextOfficeText")
    RoleAttributeUI.SetTextBasicInfo(nextOfficeText, ImportantInfoColor, TextAnchor.MiddleCenter, 22)

    local titleBg = GUI.ImageCreate(infoBg, "titleBg", "1800001030", 0, -40);
    GUI.SetAnchor(titleBg, UIAnchor.Center);
    GUI.SetPivot(titleBg, UIAroundPivot.Center);
    local titleText = GUI.CreateStatic(titleBg, "titleText", "称号属性", 0, 0, 200, 30, "system", true, false)
    RoleAttributeUI.SetTextBasicInfo(titleText, defaultColor, TextAnchor.MiddleCenter, 22)

    local getTitleTipBtn = GUI.ButtonCreate(titleBg, "getTitleTipBtn", "1800702030", 70, 0, Transition.ColorTint);
    RoleAttributeUI.SetButtonBasicInfo(getTitleTipBtn, "OnGetTitleTipBtnClick", 24, RoleAttributeUI.ImportantInfoColor)

    local currentTitleBg = GUI.ImageCreate(infoBg, "currentTitleBg", "1801202020", -150, 30, false, 210, 90);
    GUI.SetAnchor(currentTitleBg, UIAnchor.Center);
    GUI.SetPivot(currentTitleBg, UIAroundPivot.Center);

    local currentTitle1 = GUI.CreateStatic(currentTitleBg, "currentTitle1", "", 0, -15, 200, 30, "system", true, false)
    GuidCacheUtil.BindName(currentTitle1, "currentTitle1")
    RoleAttributeUI.SetTextBasicInfo(currentTitle1, ImportantInfoColor, TextAnchor.MiddleCenter, 22)
    local currentTitle2 = GUI.CreateStatic(currentTitleBg, "currentTitle2", "", 0, 15, 200, 30, "system", true, false)
    GuidCacheUtil.BindName(currentTitle2, "currentTitle2")
    RoleAttributeUI.SetTextBasicInfo(currentTitle2, ImportantInfoColor, TextAnchor.MiddleCenter, 22)

    local titleNextSp = GUI.ImageCreate(infoBg, "nextSp", "1800707050", 0, 30);
    GUI.SetAnchor(titleNextSp, UIAnchor.Center);
    GUI.SetPivot(titleNextSp, UIAroundPivot.Center);
    local nextTitleBg = GUI.ImageCreate(infoBg, "nextTitleBg", "1801202020", 150, 30, false, 210, 90);
    GUI.SetAnchor(nextTitleBg, UIAnchor.Center);
    GUI.SetPivot(nextTitleBg, UIAroundPivot.Center);

    local nextTitle1 = GUI.CreateStatic(nextTitleBg, "nextTitle1", "", 0, -15, 200, 30, "system", true, false)
    GuidCacheUtil.BindName(nextTitle1, "nextTitle1")
    RoleAttributeUI.SetTextBasicInfo(nextTitle1, ImportantInfoColor, TextAnchor.MiddleCenter, 22)
    local nextTitle2 = GUI.CreateStatic(nextTitleBg, "nextTitle2", "", 0, 15, 200, 30, "system", true, false)
    GuidCacheUtil.BindName(nextTitle2, "nextTitle2")
    RoleAttributeUI.SetTextBasicInfo(nextTitle2, ImportantInfoColor, TextAnchor.MiddleCenter, 22)
    local upSp1 = GUI.ImageCreate(nextTitleBg, "upSp1", "1801208680", 70, -15);

    GUI.SetAnchor(upSp1, UIAnchor.Center);
    GUI.SetPivot(upSp1, UIAroundPivot.Center);
    GuidCacheUtil.BindName(upSp1, "upSp1")
    local upSp2 = GUI.ImageCreate(nextTitleBg, "upSp2", "1801208680", 70, 15);
    GUI.SetAnchor(upSp2, UIAnchor.Center);
    GUI.SetPivot(upSp2, UIAroundPivot.Center);
    GuidCacheUtil.BindName(upSp2, "upSp2")

    local advanceBg = GUI.ImageCreate(infoBg, "advanceBg", "1800001030", 0, 100);
    GUI.SetAnchor(advanceBg, UIAnchor.Center);
    GUI.SetPivot(advanceBg, UIAroundPivot.Center);
    local advanceText = GUI.CreateStatic(advanceBg, "advanceText", "进阶条件", 0, 0, 200, 30, "system", true, false)
    RoleAttributeUI.SetTextBasicInfo(advanceText, defaultColor, TextAnchor.MiddleCenter, 22)
    local advanceTip = GUI.CreateStatic(advanceBg, "advanceTip", "历史最高战功：", -230, 40, 200, 30, "system", true, false)
    RoleAttributeUI.SetTextBasicInfo(advanceTip, colorDark, TextAnchor.MiddleCenter, 22)

    local advanceOfficeScroll = GUI.ScrollBarCreate(infoBg, "advanceOfficeScroll", "", "1800408160", "1800408110", 0, 140, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    local scrollFillSize = Vector2.New(300, 24)
    GuidCacheUtil.BindName(advanceOfficeScroll, "advanceOfficeScroll")
    RoleAttributeUI.SetSliderBasicInfo(advanceOfficeScroll, scrollFillSize)
    local currentTxt = GUI.CreateStatic(advanceOfficeScroll, "advanceOfficeText", "", 0, 0, 200, 30, "system", true, false)
    GuidCacheUtil.BindName(currentTxt, "advanceOfficeText")
    RoleAttributeUI.SetTextBasicInfo(currentTxt, defaultColor, TextAnchor.MiddleCenter, 22)
    local getAdvance = GUI.ButtonCreate(infoBg, "getAdvance", "1800402110", 210, 140, Transition.ColorTint, "获得", 82, 38, false);
    RoleAttributeUI.SetButtonBasicInfo(getAdvance, "OnGetAdvanceClick", 24, RoleAttributeUI.ImportantInfoColor)

    local advanceTipBtn = GUI.ButtonCreate(getAdvance, "advanceTipBtn", "1800702030", 70, 0, Transition.ColorTint);
    RoleAttributeUI.SetButtonBasicInfo(advanceTipBtn, "OnAdvanceTipBtnClick", 24, RoleAttributeUI.ImportantInfoColor)

    local seeTitleBtn = GUI.ButtonCreate(infoBg, "seeTitleBtn", "1800402110", -262, 220, Transition.ColorTint, "查看称号", 125, 45, false);
    RoleAttributeUI.SetButtonBasicInfo(seeTitleBtn, "OnSeeTitleBtnClick", 24, RoleAttributeUI.ImportantInfoColor)
    local salaryBg = GUI.ImageCreate(infoBg, "salaryBg", "1800700010", 110, 220, false, 140, 30);
    GUI.SetAnchor(salaryBg, UIAnchor.Center);
    GUI.SetPivot(salaryBg, UIAroundPivot.Center);
    local salaryText = GUI.CreateStatic(salaryBg, "salaryText", "100", 0, 0, 200, 30, "system", true, false)
    GuidCacheUtil.BindName(salaryText, "salaryText1")
    RoleAttributeUI.SetTextBasicInfo(salaryText, defaultColor, TextAnchor.MiddleCenter, 22)
    local salarySp = GUI.ImageCreate(infoBg, "salarySp", "1800408280", 40, 218);
    GuidCacheUtil.BindName(salarySp, "salarySp1")
    GUI.SetAnchor(salarySp, UIAnchor.Center);
    GUI.SetPivot(salarySp, UIAroundPivot.Center);
    local getSalaryBtn = GUI.ButtonCreate(infoBg, "getSalaryBtn", "1800402110", 262, 220, Transition.ColorTint, "领取俸禄", 125, 45, false);
    RoleAttributeUI.SetButtonBasicInfo(getSalaryBtn, "OnGetSalaryBtnClick", 24, RoleAttributeUI.ImportantInfoColor)

    GUI.AddRedPoint(getSalaryBtn,UIAnchor.TopLeft,5,5,"1800208080")
    GUI.SetRedPointVisable(getSalaryBtn,true)
    GuidCacheUtil.BindName(getSalaryBtn, "getSalaryBtn")

    local officeDetailAll = GUI.GroupCreate(bgSp, "officeDetailAll", 0, 0, 1, 1)
    GuidCacheUtil.BindName(officeDetailAll, "officeDetailAll")
    local leftBg = GUI.ImageCreate(officeDetailAll, "leftBg", "1800400010", -207, 40, false, 235, 415);
    GuidCacheUtil.BindName(leftBg, "leftBg")
    GUI.SetAnchor(leftBg, UIAnchor.Center);
    GUI.SetPivot(leftBg, UIAroundPivot.Center);

    local rightBg = GUI.ImageCreate(officeDetailAll, "rightBg", "1800400010", 120, 40, false, 415, 415);
    GUI.SetAnchor(rightBg, UIAnchor.Center);
    GUI.SetPivot(rightBg, UIAroundPivot.Center);
    local titleGetBg = GUI.ImageCreate(rightBg, "titleGetBg", "1800001030", 0, -165);
    GUI.SetAnchor(titleGetBg, UIAnchor.Center);
    GUI.SetPivot(titleGetBg, UIAroundPivot.Center);

    local titleGetTips = GUI.CreateStatic(titleGetBg, "titleText", "获得称号", 0, 0, 200, 30, "system", true, false);
    RoleAttributeUI.SetTextBasicInfo(titleGetTips, defaultColor, TextAnchor.MiddleCenter, 22)
    local titleNameBg = GUI.ImageCreate(rightBg, "titleNameBg", "1801202020", 0, -100, false, 390, 80);
    GUI.SetAnchor(titleNameBg, UIAnchor.Center);
    GUI.SetPivot(titleNameBg, UIAroundPivot.Center);
    local titleName = GUI.CreateStatic(titleNameBg, "titleName", "", 0, 0, 390, 80, "system", true, false);
    GuidCacheUtil.BindName(titleName, "titleName")
    RoleAttributeUI.SetTextBasicInfo(titleName, ImportantInfoColor, TextAnchor.MiddleCenter, 22)
    GUI.SetIsRaycastTarget(titleName, false)
    local titleAttributeBg = GUI.ImageCreate(rightBg, "titleAttributeBg", "1800001030", 0, -35);
    GUI.SetAnchor(titleAttributeBg, UIAnchor.Center);
    GUI.SetPivot(titleAttributeBg, UIAroundPivot.Center);

    local titleAttributeText = GUI.CreateStatic(titleAttributeBg, "titleAttributeText", "称号属性", 0, 0, 200, 30, "system", true, false);
    RoleAttributeUI.SetTextBasicInfo(titleAttributeText, defaultColor, TextAnchor.MiddleCenter, 22)
    local titleInfoBg = GUI.ImageCreate(rightBg, "titleInfoBg", "1801202020", 0, 45, false, 210, 90);
    GUI.SetAnchor(titleInfoBg, UIAnchor.Center);
    GUI.SetPivot(titleInfoBg, UIAroundPivot.Center);
    local titleInfo1 = GUI.CreateStatic(titleInfoBg, "titleInfo1", "", 0, -15, 200, 30, "system", true, false);
    GuidCacheUtil.BindName(titleInfo1, "titleInfo1")
    RoleAttributeUI.SetTextBasicInfo(titleInfo1, ImportantInfoColor, TextAnchor.MiddleCenter, 22)
    local titleInfo2 = GUI.CreateStatic(titleInfoBg, "titleInfo2", "", 0, 15, 200, 30, "system", true, false);
    GuidCacheUtil.BindName(titleInfo2, "titleInfo2")
    RoleAttributeUI.SetTextBasicInfo(titleInfo2, ImportantInfoColor, TextAnchor.MiddleCenter, 22)
    local salaryGetBg = GUI.ImageCreate(rightBg, "salaryGetBg", "1800001030", 0, 120);
    GUI.SetAnchor(salaryGetBg, UIAnchor.Center);
    GUI.SetPivot(salaryGetBg, UIAroundPivot.Center);
    local salaryGetTips = GUI.CreateStatic(salaryGetBg, "titleText", "俸  禄", 0, 0, 200, 30, "system", true, false);
    RoleAttributeUI.SetTextBasicInfo(salaryGetTips, defaultColor, TextAnchor.MiddleCenter, 22)
    local salaryBg = GUI.ImageCreate(rightBg, "salaryBg", "1800700010", 0, 175, false, 140, 30);
    GUI.SetAnchor(salaryBg, UIAnchor.Center);
    GUI.SetPivot(salaryBg, UIAroundPivot.Center);
    local salaryText = GUI.CreateStatic(salaryBg, "salaryText", "", 0, 0, 200, 30, "system", true, false);
    GuidCacheUtil.BindName(salaryText, "salaryText2")
    RoleAttributeUI.SetTextBasicInfo(salaryText, defaultColor, TextAnchor.MiddleCenter, 22)
    local salarySp = GUI.ImageCreate(rightBg, "salarySp", "1800408280", -68, 170);
    GuidCacheUtil.BindName(salarySp, "salarySp2")
    GUI.SetAnchor(salarySp, UIAnchor.Center);
    GUI.SetPivot(salarySp, UIAroundPivot.Center);
    GUI.SetVisible(officeDetail, false);
end

-- 当前的官职
function RoleAttributeUI.OnOfficeAdvanceClick()
    --test("OnOfficeAdvanceClick")
    local officePositionAdvance = GuidCacheUtil.GetUI("officePositionAdvance")
    GUI.ButtonSetImageID(officePositionAdvance, "1800402032")
    local officePositionAll = GuidCacheUtil.GetUI("officePositionAll")
    GUI.ButtonSetImageID(officePositionAll, "1800402030")

    local advanceInfoBg = GuidCacheUtil.GetUI("advanceInfoBg")
    if advanceInfoBg then
        GUI.SetVisible(advanceInfoBg, true);
    end
    local officeDetailAll = GuidCacheUtil.GetUI("officeDetailAll")
    if officeDetailAll then
        GUI.SetVisible(officeDetailAll, false);
    end
end

--查看称号
function RoleAttributeUI.OnSeeTitleBtnClick()
    -- test("OnSeeTitleBtnClick")
    RoleAttributeUI.OnOfficePositionClose();
    RoleAttributeUI.OnDetailPageBtnClicked("detailPageBtn")
    RoleAttributeUI.OnChangeTitleBtnClick1()
end

-- 刷新官职信息
function RoleAttributeUI.RefreshOfficeAdvance()
    if RoleAttributeUI.TotalOfficePositionList == nil or #RoleAttributeUI.TotalOfficePositionList == 0 then
        test("RoleAttributeUI.TotalOfficePositionList is nil or length = 0");
        return ;
    end
    local currentOfficeText = GuidCacheUtil.GetUI("currentOfficeText")
    local nextOfficeText = GuidCacheUtil.GetUI("nextOfficeText")
    local currentTitle1 = GuidCacheUtil.GetUI("currentTitle1")
    local currentTitle2 = GuidCacheUtil.GetUI("currentTitle2")
    local nextTitle1 = GuidCacheUtil.GetUI("nextTitle1")
    local nextTitle2 = GuidCacheUtil.GetUI("nextTitle2")

    local advanceOfficeText = GuidCacheUtil.GetUI("advanceOfficeText")
    local advanceOfficeScroll = GuidCacheUtil.GetUI("advanceOfficeScroll")
    local upSp1 = GuidCacheUtil.GetUI("upSp1")
    local upSp2 = GuidCacheUtil.GetUI("upSp2")
    local salaryText1 = GuidCacheUtil.GetUI("salaryText1")
    local salarySp1 = GuidCacheUtil.GetUI("salarySp1")

    local currentOffice = RoleAttributeUI.TotalOfficePositionList[RoleAttributeUI.NowPosition]
    local nextOffice = RoleAttributeUI.TotalOfficePositionList[RoleAttributeUI.NowPosition + 1]
    local currentAdvace = RoleAttributeUI.NowPVP--currentOffice[5]
    local nextAdvace = currentOffice[5]
    local currentsalary = currentOffice[6]
    local currentsalarySpId = currentOffice[7]
    local currentTitle = split(currentOffice[4], '_')

    GUI.StaticSetText(currentOfficeText, currentOffice[2])
    GUI.StaticSetText(currentTitle1, currentTitle[1])
    GUI.StaticSetText(currentTitle2, currentTitle[2])
    GUI.SetVisible(upSp1, true)
    GUI.SetVisible(upSp2, true)
    if nextOffice then
        nextAdvace = nextOffice[5]
        local nextTitle = split(nextOffice[4], '_')
        GUI.StaticSetText(nextOfficeText, nextOffice[2])
        GUI.StaticSetText(nextTitle1, nextTitle[1])
        GUI.StaticSetText(nextTitle2, nextTitle[2])
    else
        GUI.StaticSetText(nextOfficeText, "已达最高官职")
        GUI.StaticSetText(nextTitle1, "")
        GUI.StaticSetText(nextTitle2, "")
        GUI.SetVisible(upSp1, false)
        GUI.SetVisible(upSp2, false)
    end
    GUI.StaticSetText(advanceOfficeText, currentAdvace .. ' / ' .. nextAdvace)
    GUI.ScrollBarSetPos(advanceOfficeScroll, currentAdvace / nextAdvace)

    -- 为详情和领取俸禄按钮添加小红点
    local officePositionBtn = GuidCacheUtil.GetUI("officePositionBtn")
    local getSalaryBtn = GuidCacheUtil.GetUI("getSalaryBtn")
    -- local OfficeOpenLevel = UIDefine.OfficialPosition_OpenLevel
    -- 详情按钮是官职-详情
    local OfficeOpenLevel = MainUI.MainUISwitchConfig["角色"].Subtab_OpenLevel["详情"]
    local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    if RoleAttributeUI.IsGetSalary == 0 and roleLevel >= OfficeOpenLevel then
        -- local officePositionBtn = GUI.Get("RoleAttributeUI/SafeArea/panelBg/page1/officePosition/officePositionBtn/officePositionBtn")
        GUI.SetRedPointVisable(officePositionBtn,true)
        GUI.SetRedPointVisable(getSalaryBtn,true)
    else
        GUI.SetRedPointVisable(officePositionBtn,false)
        GUI.SetRedPointVisable(getSalaryBtn,false)
    end

    GUI.StaticSetText(salaryText1, currentsalary)
    GUI.ImageSetImageID(salarySp1, currentsalarySpId)
    if RoleAttributeUI.IsGetSalary == 1 then
        GUI.StaticSetText(salaryText1, "0")
    end
end

-- 获取俸禄
function RoleAttributeUI.OnGetSalaryBtnClick()
    --test("OnGetSalaryBtnClick")
    CL.SendNotify(NOTIFY.SubmitForm, "FormOfficialPosition", "GetSalary")
end

-- 全部的官职
function RoleAttributeUI.OnOfficeAdvanceAllClick()
    --test("OnOfficeAdvanceAllClick")
    local officePositionAll = GuidCacheUtil.GetUI("officePositionAll")
    GUI.ButtonSetImageID(officePositionAll, "1800402032")
    local officePositionAdvance = GuidCacheUtil.GetUI("officePositionAdvance")
    GUI.ButtonSetImageID(officePositionAdvance, "1800402030")

    local advanceInfoBg = GuidCacheUtil.GetUI("advanceInfoBg")
    if advanceInfoBg then
        GUI.SetVisible(advanceInfoBg, false);
    end
    local officeDetailAll = GuidCacheUtil.GetUI("officeDetailAll")
    if officeDetailAll then
        GUI.SetVisible(officeDetailAll, true);
    end
    RoleAttributeUI.CreateAllOfficeScroll()
end

-- 创建官职列表
function RoleAttributeUI.CreateAllOfficeScroll()
    if RoleAttributeUI.TotalOfficePositionList == nil or #RoleAttributeUI.TotalOfficePositionList == 0 then
        test("RoleAttributeUI.TotalOfficePositionList is nil or length = 0");
        return ;
    end
    local leftBg = GuidCacheUtil.GetUI("leftBg")
    local officeScroll = GuidCacheUtil.GetUI("officeScroll")
    if officeScroll then
        GUI.Destroy(officeScroll);
    end
    local scrollChildSize = Vector2.New(220, 65)
    local scroll = GUI.ScrollRectCreate(leftBg, "officeScroll", 0, 0, 220, 390, 0, false, scrollChildSize, UIAroundPivot.Top, UIAnchor.Top)
    GuidCacheUtil.BindName(scroll, "officeScroll")
    for i = 1, #RoleAttributeUI.TotalOfficePositionList do
        local TotalOfficePosition = RoleAttributeUI.TotalOfficePositionList[i]
        local name = TotalOfficePosition[2]
        local id = TotalOfficePosition[3]
        local item = GUI.ButtonCreate(scroll, "Office" .. i, "1800800030", 20, 0, Transition.ColorTint, name, 250, 65, false);
        GuidCacheUtil.BindName(item, "Office" .. i)
        local tempTitleColor = ImportantInfoColor;
        local titleDB = DB.GetOnceTitleByKey1(id)
        if titleDB ~= nil then
            --Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
            local color = split(tostring(titleDB.Color), ',')
            tempTitleColor = Color.New(color[1] / 255, color[2] / 255, color[3] / 255)
        end
        RoleAttributeUI.SetButtonBasicInfo(item, "OnOfficeScrollItemClick", 22, tempTitleColor)
    end
    RoleAttributeUI.SetTotalOfficeScrollPosition()
end

-- 显示对应官职信息
function RoleAttributeUI.OnOfficeScrollItemClick(guid)
    --test("OnOfficeScrollItemClick" .. guid)
    for i = 1, #RoleAttributeUI.TotalOfficePositionList do
        local item = GuidCacheUtil.GetUI("Office" .. i)
        if GUI.GetGuid(item) == guid then
            GUI.ButtonSetImageID(item, "1800800040")
            --test("OnOfficeScrollItemClick :", guid)
            local TotalOfficePosition = RoleAttributeUI.TotalOfficePositionList[i]
            local titleName = GuidCacheUtil.GetUI("titleName")
            local titleInfo1 = GuidCacheUtil.GetUI("titleInfo1")
            local titleInfo2 = GuidCacheUtil.GetUI("titleInfo2")
            local salaryText2 = GuidCacheUtil.GetUI("salaryText2")
            local salarySp2 = GuidCacheUtil.GetUI("salarySp2")

            local totaltitleName = TotalOfficePosition[2]
            local totalsalary = TotalOfficePosition[6]
            local totalsalarySpId = TotalOfficePosition[7]

            local totalTitleInfo = split(TotalOfficePosition[4], '_')

            GUI.StaticSetText(titleName, totaltitleName)

            GUI.SetColor(titleName, GUI.ButtonGetTextColor(item))
            GUI.StaticSetText(titleInfo1, totalTitleInfo[1])
            GUI.StaticSetText(titleInfo2, totalTitleInfo[2])

            GUI.StaticSetText(salaryText2, totalsalary)
            GUI.ImageSetImageID(salarySp2, totalsalarySpId)
        else
            GUI.ButtonSetImageID(item, "1800800030")
        end
    end
end

-- 设置初始位置和选中
function RoleAttributeUI.SetTotalOfficeScrollPosition()
    local officeScroll = GuidCacheUtil.GetUI("officeScroll")
    if officeScroll == nil or RoleAttributeUI.CurrentOfficePosition == nil or RoleAttributeUI.TotalOfficePositionList == nil then
        --test(officeScroll)
        --test(RoleAttributeUI.CurrentOfficePosition)
        --test(#RoleAttributeUI.TotalOfficePositionList)
        return ;
    end
    local totalCount = #RoleAttributeUI.TotalOfficePositionList;
    totalCount = totalCount > 0 and totalCount or 1;
    local current = 1;
    for i = 1, totalCount do
        if RoleAttributeUI.TotalOfficePositionList[i][2] == RoleAttributeUI.CurrentOfficePosition then
            current = i;
            break ;
        end
    end
    local item = GuidCacheUtil.GetUI("Office" .. current)
    --test(GUI.GetGuid(item))
    RoleAttributeUI.OnOfficeScrollItemClick(GUI.GetGuid(item));
    if current == 1 then
        GUI.ScrollRectSetNormalizedPosition(officeScroll, Vector2.New(0, 1));
    else
        GUI.ScrollRectSetNormalizedPosition(officeScroll, Vector2.New(0, 1 - current / totalCount));
    end
end

-- 获取战功的途径
function RoleAttributeUI.OnGetAdvanceClick()
    local getAdvanceBg = GuidCacheUtil.GetUI("getAdvanceBg")

    if getAdvanceBg then
        GUI.SetVisible(getAdvanceBg, true)
    else
        local parent = GuidCacheUtil.GetUI("page1")
        getAdvanceBg = GUI.ImageCreate(parent, "getAdvanceBg", "1800400290", 0, 0, false, 300, 220);
        GuidCacheUtil.BindName(getAdvanceBg, "getAdvanceBg")
        GUI.SetAnchor(getAdvanceBg, UIAnchor.Center);
        GUI.SetPivot(getAdvanceBg, UIAroundPivot.Center);
        getAdvanceBg:RegisterEvent(UCE.PointerClick);
        GUI.SetIsRaycastTarget(getAdvanceBg, true);
        GUI.SetIsRemoveWhenClick(getAdvanceBg, true)

        local tips1 = GUI.CreateStatic(getAdvanceBg, "tips1", "获得途径", 0, -75, 100, 35, "system", true, false)
        RoleAttributeUI.SetTextBasicInfo(tips1, RoleAttributeUI.TipsBasicInfoColor, TextAnchor.MiddleCenter, 22)
        local cutline = GUI.ImageCreate(getAdvanceBg, "cutline", "1800600030", 0, -45, false, 300, 4)
        GUI.SetAnchor(cutline, UIAnchor.Center);
        GUI.SetPivot(cutline, UIAroundPivot.Center);

        local active1 = RoleAttributeUI.OfficialPosition_ActivityConfig[1]
        local tianXiaHuiWu = DB.GetActivity(tonumber(active1['activeid']))
        if tianXiaHuiWu ~= nil then
            local name = string.split(tianXiaHuiWu.Name,"（")[1]
            local tempBtn = GUI.ButtonCreate(getAdvanceBg, active1['activeid'], tostring(tianXiaHuiWu.Icon), -70, 20, Transition.ColorTint);
            GUI.SetAnchor(tempBtn, UIAnchor.Center);
            GUI.SetPivot(tempBtn, UIAroundPivot.Center);
            GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "RoleAttributeUI", "OnGetOfficeAdvanceBtnClick1");
            local btnText = GUI.CreateStatic(tempBtn, "btnText", name, 0, 30, 100, 35, "system", true, false)
            RoleAttributeUI.SetTextBasicInfo(btnText, RoleAttributeUI.TipsBasicInfoColor, TextAnchor.MiddleCenter, 22)
            GUI.SetAnchor(btnText, UIAnchor.Bottom);
            GUI.SetPivot(btnText, UIAroundPivot.Bottom);
        end
        local active2 = RoleAttributeUI.OfficialPosition_ActivityConfig[2]
        local tianXiaDiYi = DB.GetActivity(tonumber(active2['activeid']))
        if tianXiaDiYi ~= nil then
            local name = string.split(tianXiaDiYi.Name,"（")[1]
            local tempBtn = GUI.ButtonCreate(getAdvanceBg, active2['activeid'], tostring(tianXiaDiYi.Icon), 70, 20, Transition.ColorTint);
            GUI.SetAnchor(tempBtn, UIAnchor.Center);
            GUI.SetPivot(tempBtn, UIAroundPivot.Center);
            GUI.SetData(tempBtn, "ActivityId", "169")
            GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "RoleAttributeUI", "OnGetOfficeAdvanceBtnClick2");
            local btnText = GUI.CreateStatic(tempBtn, "btnText", name, 0, 30, 100, 35, "system", true, false)
            RoleAttributeUI.SetTextBasicInfo(btnText, RoleAttributeUI.TipsBasicInfoColor, TextAnchor.MiddleCenter, 22)
            GUI.SetAnchor(btnText, UIAnchor.Bottom);
            GUI.SetPivot(btnText, UIAroundPivot.Bottom);
        end
    end
end

--点击获取途径后
function RoleAttributeUI.OnGetOfficeAdvanceBtnClick1()
    local active1 = RoleAttributeUI.OfficialPosition_ActivityConfig[1]
    LD.StartAutoMove(tonumber(active1['NPCid']))
    RoleAttributeUI.OnOfficePositionClose();
    RoleAttributeUI.OnExit()
end

function RoleAttributeUI.OnGetOfficeAdvanceBtnClick2()
    local active2 = RoleAttributeUI.OfficialPosition_ActivityConfig[2]
    LD.StartAutoMove(tonumber(active2['NPCid']))
    RoleAttributeUI.OnOfficePositionClose();
    RoleAttributeUI.OnExit()
end

-- 官职提示按钮被点击
function RoleAttributeUI.OnOfficeTipBtnClick()
    local officePanel = GuidCacheUtil.GetUI("page1")
    if officePanel == nil then
        return
    end

    local tips = GUI.ImageCreate(officePanel, "Tip", "1800400290", 50, -130, false, 410, 240)
    GUI.SetIsRaycastTarget(tips, true)
    tips:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRemoveWhenClick(tips, true)

    local msgs = {
        "<color=#ffffff>1、参加天下第一、天下会武可获得战功</color>",
        "<color=#ffffff>2、历史战功可提升官职</color>",
        "<color=#ffffff>3、俸禄每周可领取一次</color>",
        "<color=#ffffff>4、官职越高，俸禄越高</color>",
        "<color=#ffffff>5、各官职享有的俸禄可在总览中查看</color>",
    }
    for i = 1, #msgs do
        local text;
        if i == 1 then
            text = GUI.CreateStatic(tips, "text" .. i, msgs[i], 15, 26 * i + 28, 340, 52, "system", true, false)
        elseif i == 5 then
            text = GUI.CreateStatic(tips, "text" .. i, msgs[i], 15, 26 * i + 54, 340, 52, "system", true, false)
        else
            text = GUI.CreateStatic(tips, "text" .. i, msgs[i], 15, 26 * i + 40, 340, 26, "system", true, false)
        end
        RoleAttributeUI.SetTextBasicInfo(text, colorDark, TextAnchor.MiddleLeft, sizeBig, UIAnchor.Top)
    end
end

function RoleAttributeUI.OnAdvanceTipBtnClick()
    local officePanel = GuidCacheUtil.GetUI("page1")
    if officePanel == nil then
        return
    end
    local msg = "<color=#ffffff>官职按照获得的历史最高战功判定，与当前的实际战功无关；当前的实际战功请到战功商店查看。</color>"
    Tips.CreateHint(msg, officePanel,100, 180,UILayout.Center, 330)
end

function RoleAttributeUI.OnGetTitleTipBtnClick(key)
    local officePanel = GuidCacheUtil.GetUI("page1")
    if officePanel == nil then
        return
    end
    local tips = GUI.ImageCreate(officePanel, "Tip", "1800400290", 230, -60, false, 290, 52)
    GUI.SetIsRaycastTarget(tips, true)
    tips:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRemoveWhenClick(tips, true)
    local msg = "<color=#ffffff>获得官职可获得称号属性</color>"
    local text = GUI.CreateStatic(tips, "text", msg, 60, 28, 370, 52, "system", true, false)
    RoleAttributeUI.SetTextBasicInfo(text, colorDark, TextAnchor.MiddleLeft, sizeBig, UIAnchor.Top)
end
--关闭官职界面
function RoleAttributeUI.OnOfficePositionClose()
    local officeDetail = GuidCacheUtil.GetUI("officeDetail")
    GuidCacheUtil.BindName(officeDetail, "officeDetail")
    if officeDetail then
        GUI.SetVisible(officeDetail, false);
        --test("closeOfficeDetail")
    end
end
---------------------------------------- 官职功能End -----------------------------
--设置血量储备条的数据
--自写方法，无用
--function RoleAttributeUI.SetBloodSliderData(whatStore)
--
--    local currentValue = 0
--    local maxValue = 0
--    local slider=nil
--    local sliderTxt=nil
--    if  whatStore=="blood" then
--        slider=GuidCacheUtil.GetUI("bloodStoreSlider")
--        sliderTxt=GuidCacheUtil.GetUI("bloodTxt")
--        currentValue = CL.GetIntAttr(RoleAttr.RoleAttrHpPool)
--        maxValue = CL.GetIntAttr(RoleAttr.RoleAttrHpPoolLimit)
--    elseif whatStore=="blue" then
--        slider=GuidCacheUtil.GetUI("blueStoreSlider")
--        sliderTxt=GuidCacheUtil.GetUI("blueTxt")
--        currentValue = CL.GetIntAttr(RoleAttr.RoleAttrMpPool)
--        maxValue = CL.GetIntAttr(RoleAttr.RoleAttrMpPoolLimit)
--    end
--
--    if slider==nil and  sliderTxt==nil then
--        return
--    end
--
--    GUI.StaticSetText(sliderTxt,currentValue.."/"..maxValue)
--    local percentValue =currentValue/maxValue
--    if percentValue and  math.abs(percentValue)<=1 then
--
--        GUI.ScrollBarSetPos(slider,percentValue)
--    end
--end


function RoleAttributeUI.SetButtonBasicInfo(btn, functionName, fontSize, btnColor, uiAnchor, pivot)
    if not btn then
        return
    end
    SetAnchorAndPivot(btn, uiAnchor or UIAnchor.Center, pivot or UIAroundPivot.Center)
    GUI.ButtonSetTextFontSize(btn, fontSize or sizeDefault)
    GUI.ButtonSetTextColor(btn, btnColor or colorDark)
    if functionName then
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "RoleAttributeUI", functionName)
    end
end

-----------------------------------血池魔池使用界面Start-------------------------------------------------------------------
--补充血或者蓝的页面
function RoleAttributeUI.CreateAddBloodOrBluePage(parent)
    if parent == nil then
        test("parent is nil on  CreateAddBloodOrBluePage")
        return
    end
    local panelCover = GuidCacheUtil.GetUI("panelCover")

    local cover = GUI.ImageCreate(parent, "addBloodOrBlueCover", "1800400220", 0, -32, false, GUI.GetWidth(panelCover), GUI.GetHeight(panelCover))
    GuidCacheUtil.BindName(cover, "addBloodOrBlueCover")
    SetAnchorAndPivot(cover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(cover, true)
    cover:RegisterEvent(UCE.PointerClick)

    local bgSp = GUI.ImageCreate(cover, "addBloodOrBlueBg", "1800400300", 0, -38, false, 370, 442)
    GuidCacheUtil.BindName(bgSp, "addBloodOrBlueBg")
    SetAnchorAndPivot(bgSp, UIAnchor.Center, UIAroundPivot.Center)
    local bgSp2 = GUI.ImageCreate(bgSp, "addBloodOrBlueBg2", "1800400200", 0, -15, false, 340, 340)
    SetAnchorAndPivot(bgSp2, UIAnchor.Center, UIAroundPivot.Center)

    --local itemScroll=GUI.LoopScrollRectCreate(bgSp2,"itemScroll",0,-15,324,313,"RoleAttributeUI","CreateItemScroll","RoleAttributeUI","RefreshItemScroll",
    --0,false,Vector2.New(78,78),4,UIAnchor.Center, UIAroundPivot.Center)
    --GuidCacheUtil.BindName(itemScroll, "itemScroll")

    local btn = GUI.ButtonCreate(bgSp, "sureAddBtn", "1800402080", 0, 185, Transition.ColorTint, "", 112, 47, false, false)
    GuidCacheUtil.BindName(btn, "sureAddBtn")
    RoleAttributeUI.SetButtonBasicInfo(btn, "OnSureAddBtnClick")

    local sureAddTxt = GUI.CreateStatic(btn, "sureAddTxt", "补充", 0, 1, 80, 35, "system", true)
    RoleAttributeUI.SetTextBasicInfo(sureAddTxt, nil, TextAnchor.MiddleCenter, sizeBig, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsOutLine(sureAddTxt, true)
    GUI.SetOutLine_Color(sureAddTxt, outLineColor)
    GUI.SetOutLine_Distance(sureAddTxt, 1)

    local closeBtn = GUI.ButtonCreate(bgSp, "addBloodOrBlueCloseBtn", "1800302120", -23, 22, Transition.ColorTint)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.Center)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "RoleAttributeUI", "OnAddBloodOrBlueClose")
    GUI.SetVisible(cover, false)
end
------------------------------血池魔池使用界面End--------------------------------------------------------------------------
------------------------------善恶值相关界面Start--------------------------------------------------------------------------
--善恶值清空界面
--独立出专门的UI界面
--function RoleAttributeUI.CreateClearBeevilPage(parent)
--    if parent == nil then
--        test("parent is nil on  CreateClearBeevilPage")
--        return
--    end
--
--   --local  GUI.WndCreateWnd("ExpUpdateUI", "ExpUpdateUI", 0, 0, eCanvasGroup.Normal)
--
--
--    local panelCover = GuidCacheUtil.GetUI("panelCover")
--    local cover = GUI.ImageCreate(parent, "clearBeevilCover", "1800400220", 0, -22, false, GUI.GetWidth(panelCover), GUI.GetHeight(panelCover))
--    SetAnchorAndPivot(cover, UIAnchor.Center, UIAroundPivot.Center)
--    GUI.SetIsRaycastTarget(cover, true)
--    cover:RegisterEvent(UCE.PointerClick)
--
--    local bgSp = GUI.ImageCreate(cover, "clearBeevilBg", "1800001120", 0, 22, false, 480, 350)
--    SetAnchorAndPivot(bgSp, UIAnchor.Center, UIAroundPivot.Center)
--    GuidCacheUtil.BindName(bgSp, "clearBeevilBg")
--    local flower = GUI.ImageCreate(bgSp, "flower", "1800007060", -25, -25, false)
--    SetAnchorAndPivot(flower, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
--    --关闭
--    local closeBtn = GUI.ButtonCreate(bgSp, "closeBeevilBtn", "1800002050", -20, 20, Transition.ColorTint)
--    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
--
--
--    local titleBg=GUI.ImageCreate(bgSp,"titleBg","1800001030",0,25,true)
--    SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Top)
--
--    local titleTxt=GUI.CreateStatic(titleBg,"titleTxt","清除善恶值",0,0,100,50)
--    SetAnchorAndPivot(titleTxt, UIAnchor.Center, UIAroundPivot.Center)
--    GUI.StaticSetFontSize(titleTxt,UIDefine.FontSizeS)
--    GUI.SetColor(titleTxt,UIDefine.WhiteColor)
--
--    local itemIconBg=GUI.ImageCreate(bgSp,"itemIconBg","",0,-40,false,90,90)
--    SetAnchorAndPivot(itemIconBg, UIAnchor.Center, UIAroundPivot.Center)
--    local itemIcon=GUI.ImageCreate(itemIconBg,"itemIcon","",0,0,false,70,70)
--    local itemAmountTxt=GUI.CreateStatic(itemIconBg,"itemAmountTxt","",-10,-5,80,30)
--    GUI.StaticSetFontSize(itemAmountTxt,UIDefine.FontSizeM)
--    SetAnchorAndPivot(itemAmountTxt, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
--    GUI.SetIsOutLine(itemAmountTxt,true);
--    GUI.SetOutLine_Color(itemAmountTxt,UIDefine.BlackColor);
--    GUI.SetOutLine_Distance(itemAmountTxt,1);
--    GUI.StaticSetAlignment(itemAmountTxt, TextAnchor.MiddleRight)
--
--
--    local tipsLabel = GUI.CreateStatic(bgSp, "tipsLabel", "当前善恶值", -20, 40, 200, 50)
--    GUI.SetColor(tipsLabel,UIDefine.BrownColor)
--    GUI.StaticSetFontSize(tipsLabel,UIDefine.FontSizeS)
--    local clearTxtBg = GUI.ImageCreate(bgSp, "clearTxtBg", "1800500070", 60, 40, false, 100, 30)
--    SetAnchorAndPivot(clearTxtBg, UIAnchor.Center, UIAroundPivot.Center)
--    --local pk_value =CL.GetIntAttr(RoleAttr.RoleAttrPK)
--    --local name = "currentBeevilValue"
--    --test("pk_value"..tostring(pk_value))
--    local txt = GUI.CreateStatic(clearTxtBg, "currentBeevilValue","0" , 0, 0, 80, 30)
--    GUI.SetColor(txt,UIDefine.BrownColor)
--    GUI.StaticSetFontSize(txt,UIDefine.FontSizeS)
--    --GuidCacheUtil.BindName(txt, name)
--    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
--
--
--    local costLabel = GUI.RichEditCreate(bgSp, "clearBeevilCostLabel", "", 0, 80, 390, 90)
--    --GuidCacheUtil.BindName(costLabel, "clearBeevilCostLabel")
--    GUI.SetColor(costLabel,UIDefine.BrownColor)
--    GUI.StaticSetFontSize(costLabel,UIDefine.FontSizeS)
--    GUI.StaticSetAlignment(costLabel, TextAnchor.MiddleCenter)
--    GUI.SetIsRaycastTarget(costLabel, false)
--
--
--
--    --使用1个
--    local oneClearButton = GUI.ButtonCreate(bgSp, "oneClearBeevilButton", "1800402080", 130, -20, Transition.ColorTint, "", 160, 46, false)
--    SetAnchorAndPivot(oneClearButton, UIAnchor.Bottom, UIAroundPivot.Bottom)
--    local oneClearLabel = GUI.CreateStatic(oneClearButton, "oneClearBeevilButtonLabel", "使用1个", 0, 0, 160, 46)
--    RoleAttributeUI.SetTextBasicInfo(oneClearLabel, nil, TextAnchor.MiddleCenter, 24, UIAnchor.Center, UIAroundPivot.Center)
--    GUI.SetIsOutLine(oneClearLabel, true)
--    GUI.SetOutLine_Color(oneClearLabel, outLineColor)
--    GUI.SetOutLine_Distance(oneClearLabel, 1)
--
--    --全部清除
--    local allClearButton = GUI.ButtonCreate(bgSp, "allClearBeevilButton", "1800402080", -130, -20, Transition.ColorTint, "", 160, 46, false)
--    SetAnchorAndPivot(allClearButton, UIAnchor.Bottom, UIAroundPivot.Bottom)
--    local allClearLabel = GUI.CreateStatic(allClearButton, "allClearBeevilButtonLabel", "全部清除", 0, 0, 160, 46)
--    RoleAttributeUI.SetTextBasicInfo(allClearLabel, nil, TextAnchor.MiddleCenter, 24, UIAnchor.Center, UIAroundPivot.Center)
--    GUI.SetIsOutLine(allClearLabel, true)
--    GUI.SetOutLine_Color(allClearLabel, outLineColor)
--    GUI.SetOutLine_Distance(allClearLabel, 1)
--
--
--    GUI.RegisterUIEvent(oneClearButton, UCE.PointerClick, "RoleAttributeUI", "OneClearBeevil")
--    GUI.RegisterUIEvent(allClearButton, UCE.PointerClick, "RoleAttributeUI", "AllClearBeevil")
--    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "RoleAttributeUI", "OnCancleClearBeevil")
--    --RoleAttributeUI.GetClearBeevilInfo()
--
--    GUI.SetVisible(cover, false)
--end

--PK图标点击  开启提示
function RoleAttributeUI.CreatePKBtnTips(parent)
    if parent == nil then
        test("parent is nil on  CreateClearBeevilPage")
        return
    end
    local panelCover = GuidCacheUtil.GetUI("panelCover")
    local cover = GUI.ImageCreate(parent, "pkBtnTipsCover", "1800400220", 0, -22, false, GUI.GetWidth(panelCover), GUI.GetHeight(panelCover))
    SetAnchorAndPivot(cover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(cover, true)
    cover:RegisterEvent(UCE.PointerClick)

    local bgSp = GUI.ImageCreate(cover, "PKTipsBg", "1800001120", 0, 22, false, 480, 270)
    SetAnchorAndPivot(bgSp, UIAnchor.Center, UIAroundPivot.Center)
    local flower = GUI.ImageCreate(bgSp, "flower", "1800007060", -25, -25, false)
    SetAnchorAndPivot(flower, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    --关闭
    local closeBtn = GUI.ButtonCreate(bgSp, "closePKTipsBtn", "1800002050", -20, 20, Transition.ColorTint)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local titleBg = GUI.ImageCreate(bgSp, "titleBg", "1800001030", 0, 25, true)
    SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Top)

    local titleTxt = GUI.CreateStatic(titleBg, "titleTxt", "提示", 0, 0, 100, 50)
    SetAnchorAndPivot(titleTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(titleTxt, UIDefine.FontSizeS)
    GUI.SetColor(titleTxt, UIDefine.WhiteColor)
    GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleCenter)

    local str = "无法开启快速对决，请先开启PK开关。是否前往长安城开启PK开关？"
    local tipsLabel = GUI.RichEditCreate(bgSp, "tipsLabel", str, 0, 0, 350, 90)
    SetAnchorAndPivot(tipsLabel, UIAnchor.Center, UIAroundPivot.Center)
    --GuidCacheUtil.BindName(costLabel, "clearBeevilCostLabel")
    GUI.SetColor(tipsLabel, UIDefine.BrownColor)
    GUI.StaticSetFontSize(tipsLabel, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(tipsLabel, TextAnchor.MiddleCenter)
    GUI.SetIsRaycastTarget(tipsLabel, false)



    --确定按钮
    local confirmButton = GUI.ButtonCreate(bgSp, "confirmButton", "1800402080", 130, -20, Transition.ColorTint, "", 160, 46, false)
    SetAnchorAndPivot(confirmButton, UIAnchor.Bottom, UIAroundPivot.Bottom)
    local confirmLabel = GUI.CreateStatic(confirmButton, "confirmLabel", "确定", 0, 0, 160, 46)
    RoleAttributeUI.SetTextBasicInfo(confirmLabel, nil, TextAnchor.MiddleCenter, 24, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsOutLine(confirmLabel, true)
    GUI.SetOutLine_Color(confirmLabel, outLineColor)
    GUI.SetOutLine_Distance(confirmLabel, 1)

    --取消按钮
    local cancelButton = GUI.ButtonCreate(bgSp, "cancelButton", "1800402080", -130, -20, Transition.ColorTint, "", 160, 46, false)
    SetAnchorAndPivot(cancelButton, UIAnchor.Bottom, UIAroundPivot.Bottom)
    local cancelLabel = GUI.CreateStatic(cancelButton, "cancelLabel", "取消", 0, 0, 160, 46)
    RoleAttributeUI.SetTextBasicInfo(cancelLabel, nil, TextAnchor.MiddleCenter, 24, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsOutLine(cancelLabel, true)
    GUI.SetOutLine_Color(cancelLabel, outLineColor)
    GUI.SetOutLine_Distance(cancelLabel, 1)

    GUI.RegisterUIEvent(confirmButton, UCE.PointerClick, "RoleAttributeUI", "OnPKBtnClick")
    GUI.RegisterUIEvent(cancelButton, UCE.PointerClick, "RoleAttributeUI", "OnCancelPKTips")
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "RoleAttributeUI", "OnCancelPKTips")
    --RoleAttributeUI.GetClearBeevilInfo()

    GUI.SetVisible(cover, false)
end
------------------------------善恶值相关界面End--------------------------------------------------------------------------
--------------------------------------血池魔池补充按钮点击方法Start----------------------------------------------------------
--[[因为该移植的方法中大部分脚本接口与现在使用的接口不同，故重构此类方法]]--
--function RoleAttributeUI.OnBloodSupBtnClick(key)
--    do
--        CL.SendNotify(NOTIFY.ShowBBMsg, "功能暂未开放")
--        return
--    end
--    local page = GuidCacheUtil.GetUI("addBloodOrBlueCover")
--    local scroll = GUI.GetChild(page, "scroll")
--    GUI.Destroy(scroll)
--    GUI.SetVisible(page, true)
--
--    RoleAttributeUI.SelectItemIndex = 0
--    RoleAttributeUI.NeedResetItemScrorectPosition = true
--    RoleAttributeUI.FirstOpenItemScroll = true
--
--    RoleAttributeUI.ItemList("血池")
--    --RoleAttributeUI.CreateItemSroll()
--    RoleAttributeUI.CreateOrRefreshItemList()
--
--    local bg = GuidCacheUtil.GetUI("panelBg")
--    GUI.SetData(bg, "CurrentSubType", "血池")
--end
--
--function RoleAttributeUI.OnBlueSupBtnClick(key)
--    do
--        CL.SendNotify(NOTIFY.ShowBBMsg, "功能暂未开放")
--        return
--    end
--    local page = GuidCacheUtil.GetUI("addBloodOrBlueCover")
--    local scroll = GUI.GetChild(page, "scroll")
--    GUI.Destroy(scroll)
--    GUI.SetVisible(page, true)
--
--    RoleAttributeUI.SelectItemIndex = 0
--    RoleAttributeUI.NeedResetItemScrorectPosition = true
--    RoleAttributeUI.FirstOpenItemScroll = true
--
--    RoleAttributeUI.ItemList("魔池")
--    --RoleAttributeUI.CreateItemSroll()
--    RoleAttributeUI.CreateOrRefreshItemList()
--
--    local bg = GuidCacheUtil.GetUI("panelBg")
--    GUI.SetData(bg, "CurrentSubType", "魔池")
--end
--
--function RoleAttributeUI.OnAddBloodOrBlueClose()
--    local bg = GuidCacheUtil.GetUI("panelBg")
--    local preTips = GUI.GetChild(bg, "tipsleft")
--    if preTips ~= nil then
--        GUI.Destroy(preTips)
--    end
--    RoleAttributeUI.ClearSelectInfo()
--    local page = GuidCacheUtil.GetUI("addBloodOrBlueCover")
--    if page ~= nil then
--        GUI.SetVisible(page, false)
--    end
--end
--
--function RoleAttributeUI.OnSureAddBtnClick(key, guid)
--    local bg = GuidCacheUtil.GetUI("panelBg")
--    local index = GUI.GetData(bg, "SelectItemIndex")
--    if RoleAttributeUI.CurSelectItemGUID and RoleAttributeUI.CurSelectItemGUID ~= "0" and tonumber(RoleAttributeUI.CurSelectItemGUID) ~= 0 then
--        local hasFull = false
--        local curType = GUI.GetData(bg, "CurrentSubType")
--        if curType == "血池" then
--            local currentValue = CL.GetAttr(RoleAttr.RoleAttrHpPool)
--            local maxValue = CL.GetAttr(RoleAttr.RoleAttrHpPoolLimit)
--            if currentValue >= maxValue then
--                hasFull = true
--            end
--        elseif curType == "魔池" then
--            local currentValue = CL.GetAttr(RoleAttr.RoleAttrMpPool)
--            local maxValue = CL.GetAttr(RoleAttr.RoleAttrMpPoolLimit)
--            if currentValue >= maxValue then
--                hasFull = true
--            end
--        end
--        if hasFull then
--            CL.SendNotify(NOTIFY.ShowBBMsg, "储备已满")
--            return
--        end
--        --血池或魔池的使用
--        CL.SendNotify(NOTIFY.OnReqUse, RoleAttributeUI.CurSelectItemGUID)
--    elseif RoleAttributeUI.CurSelectItemId ~= nil and RoleAttributeUI.CurSelectItemId ~= "0" and tonumber(RoleAttributeUI.CurSelectItemId) ~= 0 then
--        RoleAttributeUI.FastBuy_Get(tonumber(RoleAttributeUI.CurSelectItemId))
--    else
--        CL.SendNotify(NOTIFY.ShowBBMsg, "未选中任何道具")
--    end
--end
--
---- 快捷购买和获取途径
--function RoleAttributeUI.FastBuy_Get(itemId)
--    test("FastBuy_Get,", itemId)
--    if itemId == 0 then
--        return
--    end
--    local item = DB.Get_item(itemId)
--
--    if item ~= nil then
--        local parent = GuidCacheUtil.GetUI("addBloodOrBlueCover")
--        local tips = Tips.CreateSimpleItem("fastGettips", itemId, 0, 70, parent)
--        GuidCacheUtil.BindName(tips, "fastGettips")
--        local getBtn = GUI.ButtonCreate(tips, "getBtn", "1800402110", 0, -36, Transition.ColorTint, "获得途径", 150, 50, false)
--        GUI.ButtonSetTextFontSize(getBtn, 22)
--        GUI.SetAnchor(getBtn, UIAnchor.Bottom)
--        GUI.ButtonSetTextColor(getBtn, colorDark)
--        GUI.RegisterUIEvent(getBtn, UCE.PointerClick, "RoleAttributeUI", "OnGetBtnClick")
--        GUI.AddWhiteName(tips, GUI.GetGuid(getBtn))
--    end
--end
--
---- 获得途径
--function RoleAttributeUI.OnGetBtnClick()
--    local tips = GuidCacheUtil.GetUI("fastGettips")
--    if tips ~= nil then
--        Tips.OpenAcquiringWay(tips)
--    end
--end
--
--function RoleAttributeUI.ClearSelectInfo()
--    RoleAttributeUI.CurSelectItemId = 0
--    RoleAttributeUI.CurSelectItemGUID = "0"
--end
--
--local NoGainList
--function RoleAttributeUI.ItemList(whatStore)
--    ---暂时屏蔽掉
--    --do
--    --    return
--    --end
--    if whatStore == "血池" then
--        whatStore = 25
--    elseif whatStore == "魔池" then
--        whatStore = 26
--    end
--    itemList = nil
--    itemList = {}
--
--    --local count = LD.GetBagMaxLimit(bagType)
--    local count=LD.GetBagCapacity(bagType)
--    for i = 0, count - 1 do
--        local itemData = LD.GetItemInfoInBag(i, bagType)
--        if itemData ~= nil then
--            local item = DB.Get_item_consumable(itemData.Info.id)
--            if item ~= nil then
--                if item.Type == whatStore then
--                    table.insert(itemList, itemData)
--                end
--            end
--        end
--    end
--
--    NoGainList = nil
--    NoGainList = {}
--    if whatStore == 25 then
--        for k, v in pairs(RoleAttributeUI.CanAddBloodItems) do
--            table.insert(NoGainList, v)
--        end
--    elseif whatStore == 26 then
--        for k, v in pairs(RoleAttributeUI.CanAddBlueItems) do
--            table.insert(NoGainList, v)
--        end
--    end
--
--    for i = 1, #itemList do
--        for j = 1, #NoGainList do
--            if itemList[i].Info.id == NoGainList[j] then
--                table.remove(NoGainList, j)
--                break
--            end
--        end
--    end
--    table.sort(itemList, RoleAttributeUI.SortItemList)
--end
--
--function RoleAttributeUI.SortItemList(a, b)
--    return a.Info.id > b.Info.id
--end
--
--function RoleAttributeUI.CreateOrRefreshItemList()
--    local itemListCount = #itemList
--    if itemListCount ~= RoleAttributeUI.ItemListRealCount then
--        RoleAttributeUI.NeedResetItemScrorectPosition = true
--    end
--    RoleAttributeUI.ItemListRealCount = itemListCount
--    RoleAttributeUI.MaxItemsCount = itemListCount + #NoGainList
--
--    if RoleAttributeUI.MaxItemsCount < 16 then
--        RoleAttributeUI.MaxItemsCount = 16
--    end
--    local parent = GuidCacheUtil.GetUI("addBloodOrBlueBg")
--    local itemScroll = GUI.GetChild(parent, "itemScroll")
--    if itemScroll == nil then
--        -- 滚动窗口
--        itemScroll = GUI.ScrollRectCreate(81), "itemScroll", 0, -15, 324, 313, 0, false, Vector2.New(80, parent, UIAroundPivot.Top, UIAnchor.Top, 4)
--        GuidCacheUtil.BindName(itemScroll, "itemScroll")
--        SetAnchorAndPivot(itemScroll, UIAnchor.Center, UIAroundPivot.Center)
--        GUI.ScrollRectSetChildAnchor(itemScroll, UIAnchor.Top)
--        GUI.ScrollRectSetChildPivot(itemScroll, UIAroundPivot.Top)
--        GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(0, 0))
--    end
--    for i = 1, RoleAttributeUI.MaxItemsCount do
--        RoleAttributeUI.CreateItem(i, itemScroll)
--    end
--    -- 先把多余的隐藏
--    for i = RoleAttributeUI.MaxItemsCount, GUI.GetChildCount(itemScroll) do
--        local itemIcon = GUI.GetChild(itemScroll, "item" .. i)
--        if itemIcon ~= nil then
--            GUI.SetVisible(itemIcon, false)
--            GUI.SetData(itemIcon, "itemId", 0)
--            GUI.SetData(itemIcon, "itemGUID", 0)
--        end
--    end
--    --空格子重置
--    for i = itemListCount + #NoGainList + 1, RoleAttributeUI.MaxItemsCount do
--        local itemIcon = GUI.GetChild(itemScroll, "item" .. i)
--        if itemIcon ~= nil then
--            GUI.SetVisible(itemIcon, true)
--            GUI.SetData(itemIcon, "itemId", 0)
--            GUI.SetData(itemIcon, "itemGUID", 0)
--            local img = GUI.ItemCtrlGetSprite_Icon(itemIcon)
--            GUI.SetVisible(img, false)
--            GUI.SetItemIconBtnLeftTopName(itemIcon, "")
--            --GUI.ItemCtrlSetOutLineName(itemIcon, "")
--            local countLabel = GUI.ItemCtrlGetLabel_Num(itemIcon)
--            if countLabel ~= nil then
--                GUI.SetVisible(countLabel, false)
--            end
--        end
--    end
--
--    for i = 1, itemListCount do
--        local itemIcon = RoleAttributeUI.CreateItem(i, itemScroll)
--        local itemData = itemList[i]
--        local item = DB.Get_item(itemData.Info.id)
--        if item == nil then
--            test("Item表没有找到" .. itemData.Info.id)
--        else
--            GUI.ItemCtrlSetIconName(itemIcon, item.Icon)
--            local img = GUI.ItemCtrlGetSprite_Icon(itemIcon)
--            GUI.ImageSetGray(img, false)
--            GUI.SetVisible(img, true)
--            GUI.ItemCtrlSetCount(itemIcon, itemData.Info.amount)
--            local countLabel = GUI.ItemCtrlGetLabel_Num(itemIcon)
--            if countLabel ~= nil then
--                GUI.SetVisible(countLabel, true)
--                GUI.SetPositionX(countLabel, 7)
--                GUI.SetPositionY(countLabel, 5)
--                GUI.StaticSetFontSize(countLabel, 20)
--                GUI.SetIsOutLine(countLabel, true)
--                GUI.SetOutLine_Color(countLabel, Color.New(0 / 255, 0 / 255, 0 / 255, 255 / 255))
--                GUI.SetOutLine_Distance(countLabel, 1)
--                GUI.SetColor(countLabel, defaultColor)
--            end
--            GUI.SetData(itemIcon, "itemId", item.Id)
--            GUI.SetData(itemIcon, "itemGUID", itemData.guid)
--            -- 是否绑定
--            if itemData.Info.is_bound == 1 then
--                GUI.SetItemIconBtnLeftTopName(itemIcon, "1800707120")
--            else
--                GUI.SetItemIconBtnLeftTopName(itemIcon, "")
--            end
--        end
--    end
--
--    --显示剪影
--    for i = 1, #NoGainList do
--        local itemIcon = RoleAttributeUI.CreateItem(i + itemListCount, itemScroll)
--        GUI.SetVisible(itemIcon, true)
--
--        local item = DB.Get_item(NoGainList[i])
--        if item == nil then
--            test("Item表没有找到" .. NoGainList[i])
--        else
--            GUI.ItemCtrlSetIconName(itemIcon, item.Icon)
--            local img = GUI.ItemCtrlGetSprite_Icon(itemIcon)
--            GUI.ImageSetGray(img, true)
--            GUI.SetVisible(img, true)
--            local countLabel = GUI.ItemCtrlGetLabel_Num(itemIcon)
--            GUI.SetVisible(countLabel, false)
--            GUI.SetData(itemIcon, "itemId", item.Id)
--            GUI.SetData(itemIcon, "itemGUID", 0)
--            GUI.SetItemIconBtnLeftTopName(itemIcon, "")
--        end
--    end
--
--    if RoleAttributeUI.NeedResetItemScrorectPosition then
--        RoleAttributeUI.NeedResetItemScrorectPosition = false
--        GUI.SetScrollRectNormalizedPosition(itemScroll, Vector2.New(0, 1))
--        if RoleAttributeUI.FirstOpenItemScroll then
--            --没有这个item，只是为了清掉选中
--            RoleAttributeUI.OnItemClick("itemAA")
--            RoleAttributeUI.FirstOpenItemScroll = false
--        else
--            RoleAttributeUI.OnItemClick("item1")
--        end
--    end
--end
--
---- 创建Item项
--function RoleAttributeUI.CreateItem(index, parent)
--    if parent == nil then
--        return
--    end
--
--    local name = "item" .. index
--    local item = GUI.GetChild(parent, name)
--    if item ~= nil then
--        return item
--    end
--
--    item = GUI.ItemCtrlCreate(parent, name, "1800400050", 0, 0, 0, 0, false)
--    GUI.SetData(item, "index", index)
--    GUI.SetItemCtrlSelectName(item, "1800400280")
--    item.Visible = true
--    GUI.RegisterUIEvent(item, UCE.PointerClick, "RoleAttributeUI", "OnItemClick")
--    GUI.SetData(item, "itemId", 0)
--    GUI.SetData(item, "itemGUID", 0)
--    return item
--end
--
---- 道具被点击
--function RoleAttributeUI.OnItemClick(key, guid)
--    RoleAttributeUI.ClearSelectInfo()
--
--    local scroll = GuidCacheUtil.GetUI("itemScroll")
--    -- 显示当前选中
--    local currentSelect = 1
--    for i = 1, RoleAttributeUI.MaxItemsCount do
--        local itemName = "item" .. i
--        local itemCtrl = GUI.GetChild(scroll, itemName)
--        if itemName == key then
--            currentSelect = i
--            GUI.ItemCtrlSelect(itemCtrl)
--        else
--            GUI.ItemCtrlUnSelect(itemCtrl)
--        end
--    end
--
--    local itemIcon = GUI.GetChild(scroll, key)
--    if itemIcon == nil then
--        return
--    end
--    local itemId = GUI.GetData(itemIcon, "itemId")
--    local itemGUID = GUI.GetData(itemIcon, "itemGUID")
--    -- 道具剪影点击信息快捷购买
--    -- 显示点击效果
--    RoleAttributeUI.CurSelectItemId = tonumber(itemId)
--    if itemGUID ~= nil and tonumber(itemGUID) ~= 0 then
--        RoleAttributeUI.CreateTips(itemGUID, itemIcon)
--        RoleAttributeUI.CurSelectItemGUID = itemGUID
--    else
--        RoleAttributeUI.CurSelectItemGUID = "0"
--        RoleAttributeUI.FastBuy_Get(tonumber(RoleAttributeUI.CurSelectItemId))
--    end
--end
--
--function RoleAttributeUI.CreateTips(itemGuid, icon)
--    local bg = GuidCacheUtil.GetUI("panelBg")
--
--    local preTips = GUI.GetChild(bg, "tipsleft")
--    if preTips ~= nil then
--        GUI.Destroy(preTips)
--    end
--
--    local tips = Tips.CreateItem("tipsleft", itemGuid, -380, -93, bg)
--    SetAnchorAndPivot(tips, UIAnchor.Center, UIAroundPivot.Center)
--    -- RoleAttributeUI.SaveSelect(tips,icon)
--    local sureAddBtn = GuidCacheUtil.GetUI("sureAddBtn")
--    local guid = GuidCacheUtil.GetGuid("sureAddBtn")
--    local guid2 = GUI.GetGuid(icon)
--    GUI.AddWhiteName(tips, guid)
--    GUI.AddWhiteName(tips, guid2)
--end
--------------------------------------血池魔池补充按钮点击方法End------------------------------------------------------------
--标签页点击事件
function RoleAttributeUI.OnAttributePageBtnClicked(key)
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(LabelList[1][1])
	local Level = MainUI.MainUISwitchConfig["角色"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		RoleAttributeUI.TabIndex = 1
		UILayout.OnTabClick(1, LabelList)
		RoleAttributeUI.SetPage(1)
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(CurSelectPage,LabelList)
		return
	end
	
end

function RoleAttributeUI.OnDetailPageBtnClicked(key)
	local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
	local Key = tostring(LabelList[2][1])
	local Level = MainUI.MainUISwitchConfig["角色"].Subtab_OpenLevel[Key]
	if CurLevel >= Level then
		RoleAttributeUI.TabIndex = 2
		UILayout.OnTabClick(2, LabelList)
		RoleAttributeUI.SetPage(2)
	else
		CL.SendNotify(NOTIFY.ShowBBMsg,tostring(Level).."级开启"..Key.."功能")
		UILayout.OnTabClick(CurSelectPage,LabelList)
		return
	end

end

function RoleAttributeUI.SetPage(page)
    local pageList = {}
    pageList[1] = GuidCacheUtil.GetUI("page1")
    pageList[2] = GuidCacheUtil.GetUI("page2")

    for i = 1, #pageList do
        GUI.SetVisible(pageList[i], i == page)
    end
    if page == 1 then
        GUI.SetVisible(GuidCacheUtil.GetUI("roleModel"), true)
    end
end

function RoleAttributeUI.OnUseBtnClick(key)

    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法执行该操作")
        return
    end
    local panel = GUI.GetWnd("RoleAttributeUI")
    if panel and GUI.GetVisible(panel) then
        GUI.OpenWnd("VitalityUI")
    end
end

function RoleAttributeUI.OnRecvActivityInfo(param)
    --test("获取根骨活动数据")
    --if param == "0" then
    --	local panel = GUI.GetWnd("RoleAttributeUI")
    --	if panel and GUI.GetVisible(panel) then
    --		test("OnRecvActivityInfo")
    --		GUI.OpenWnd("VitalityUI")
    --		CL.UnRegisterMessage(GM.RefreshActivityInfo, "RoleAttributeUI", "OnRecvActivityInfo")
    --		RoleAttributeUI.OnExit()
    --	end
    --end
end

--经验大于升级需要的经验，同时至少 4个心法包的等级差小于5
function RoleAttributeUI.OnUpLevelBtnClick(key, guid)
    -- TODO: 暂时屏蔽
    do
        return
    end
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法执行该操作")
        return
    end
    if UILayout.ButtonClickCD(guid, 1) ~= nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "点击过于频繁，请稍后再试")
        return
    end
    if currentEpxerience < math.ceil(MainUI.RateOfLevelUpCost * maxEpxerience) then
        CL.SendNotify(NOTIFY.ShowBBMsg, "经验值不足，无法升级")
        return
    end

    local selfLevel = CL.GetAttr(role_attr.role_level)
    --local global = DB.Get_global(1)
    --
    --if global and selfLevel >= global.PlayTopLevel then
    --    CL.SendNotify(NOTIFY.ShowBBMsg, "您已满级")
    --    return
    --end

    local levelTxt = GuidCacheUtil.GetUI("levelTxt")
    local judgeLevel = tonumber(GUI.GetData(levelTxt, "RoleLevelup"))

    if selfLevel >= judgeLevel then
        local count = LD.GetHeartSkillCount()
        local heartSkill = LD.GetHeartSkill()
        local sum = 0
        local page = GuidCacheUtil.GetUI("page1")
        local spellLvRoleLevelup = GUI.GetData(page, "SpellLvRoleLevelup")
        if spellLvRoleLevelup ~= nil and #spellLvRoleLevelup ~= 0 then
            spellLvRoleLevelup = tonumber(spellLvRoleLevelup)
        else
            spellLvRoleLevelup = 5
        end
        for i = 0, count - 1 do
            local skill = heartSkill[i]
            local skill_Level = LD.GetMainSkillLevel_ById(skill.Id)
            if selfLevel - skill_Level <= spellLvRoleLevelup then
                sum = sum + 1
            end
        end
        if sum < 4 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "心法等级不足，请先升级心法")
            return
        end
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormList", "Player_AskForLevelUpEx")
    --CL.SendNotify(NOTIFY.UpLevelReq)
end

-- 与服务器等级差值，消耗经验比例
function RoleAttributeUI.WhetherUpLevel(dif, rate)
    local cost = math.ceil(rate / 10000 * maxEpxerience)
    --local str = "您升级后等级将高于服务器等级 " .. dif .." 级，继续升级将消耗 " ..  cost  .. "("..math.floor(rate/100).."%) 的经验。"
    local str = "您升级后等级将高于服务器等级 " .. dif .. " 级，继续升级将额外消耗 " .. (cost - maxEpxerience) .. " 的经验。是否确定升级？"
    if currentEpxerience < cost then
        --str = str .. "您的经验不足，无法升级。"
        str = "您的经验不足，无法升级。"
        CL.MessageBox(MessageBoxType.DonotNeedSure, "WhetherUpLevel", str)
    else
        --str = str .. "是否继续升级？"
        CL.MessageBox(MessageBoxType.DonotNeedSure, "WhetherUpLevel", str, "RoleAttributeUI", "OnSureUpLevel", "", MessageBoxStyle.Opposite, "继续升级", "取消")
        --CL.SendNotify(NOTIFY.UpLevelReq)
    end
end

-- 6.11 又=改成需要提示了，哈哈哈
-- 5.20 改为：经验够了直接升级，不用提示
function RoleAttributeUI.OnSureUpLevel()
    CL.SendNotify(NOTIFY.UpLevelReq)
end

function RoleAttributeUI.OnChangeNameBtnClick(key)

    GUI.OpenWnd("RoleRenameUI")
    RoleRenameUI.SetSelfRole();
end

function RoleAttributeUI.OnChangeTitleBtnClick(key)
    GUI.OpenWnd("TitleUI")
end

function RoleAttributeUI.OnChangeTitleBtnClick1(key)
    GUI.OpenWnd("TitleUI", 9)
end

--回门派
function RoleAttributeUI.OnBackSchoolClick(key)
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法执行该操作")
        return
    end
    -- do
    --     CL.SendNotify(NOTIFY.ShowBBMsg, "功能暂未开放")
    --     return
    -- end
    --LD.TransferReq(TransferType.kTransferToSchool)

    local menpai = CL.GetIntAttr(RoleAttr.RoleAttrJob1)
    local school = DB.GetSchool(menpai)
    local mapID = school.Map 
    local x = school.X
    local y = CL.ChangeLogicPosZ(school.Y, mapID) 
    CL.StartMove(x, y,mapID)
    RoleAttributeUI.OnExit()
end

function RoleAttributeUI.OnBackFactionClick(key)
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法执行该操作")
        return
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormGuild", "ExecuteOperation", 7)
    GUI.CloseWnd("RoleAttributeUI")
end

function RoleAttributeUI.OnBeevilBtnClick(key)
    --local PkValue=CL.GetIntAttr(RoleAttr.RoleAttrPK)
    --test("PkValue"..PkValue)
    --if PkValue >= 0 then
    --    CL.SendNotify(NOTIFY.ShowBBMsg, "无需清空善恶值")
    --    return
    --end
    --CL.RegisterMessage(GM.RefreshBag, "RoleAttributeUI", "SetClearBeevilInfo")
    --RoleAttributeUI.GetClearBeevilInfo()
    --RoleAttributeUI.GetClearBeevilInfo()
    --local page = GUI.Get("RoleAttributeUI/panelBg/page2/clearBeevilCover")
    --if page~= nil then
    --	GUI.SetVisible(page,true)
    --end

    --test("点击OnBeevilBtnClick")
    local ClearGoodAndEvilValuesUI = GUI.GetWnd("ClearGoodAndEvilValuesUI");
    GUI.OpenWnd("ClearGoodAndEvilValuesUI");

end
--PK Icon点击方法
function RoleAttributeUI.OnPKIconClick()
    --test("点击icon图标")

    --local a=CL.GetIntAttr(RoleAttr.RoleAttrCanPk)
    --test("a========="..tostring(a))

    local roleCanPK = CL.GetIntAttr(RoleAttr.RoleAttrCanPk)
    local page = GUI.Get("RoleAttributeUI/panelBg/page2/pkBtnTipsCover")
    local pkIcon = GuidCacheUtil.GetUI("pkIcon")
    if roleCanPK == 0 then
        if page ~= nil then
            --test("PK功能关闭中")
            GUI.SetVisible(page, true)
        end
    elseif roleCanPK >= 1 then
        GlobalProcessing.IsQuicklyPK = not GlobalProcessing.IsQuicklyPK
        if GlobalProcessing.IsQuicklyPK then
            --test("快速PK功能开启中")
            --CL.SendNotify(NOTIFY.ShowBBMsg, "您已开启快速对决")
            GUI.ImageSetImageID(pkIcon, pkIconPicture[2])
             CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "setIsFastPk","1")
        else
            --test("快速PK功能关闭中，PK功能开启中")
            --CL.SendNotify(NOTIFY.ShowBBMsg, "您已关闭快速对决")
            GUI.ImageSetImageID(pkIcon, pkIconPicture[3])
            CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "setIsFastPk","0")
        end
        --CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "NegateIsCanPkValue")
    end

end

--良师值
function RoleAttributeUI.OnMentorBtnClick(key)
    -- local Mentor = 10311
    -- local mentor = CFG.Get_GameGlobalConfig("Mentor")
    -- if mentor ~= nil then
    --     Mentor = mentor.Value
    -- end
    -- RoleAttributeUI.StartAutoMove(tonumber(Mentor))

    --GUI.OpenWnd("ShopStoreUI","index:6")
    GUI.OpenWnd("ShopStoreUI","6")
end

--荣誉值
function RoleAttributeUI.OnHonorBtnClick(key)
    -- local Honor = 10220
    -- local honor = CFG.Get_GameGlobalConfig("Honor")
    -- if honor ~= nil then
    --     Honor = honor.Value
    -- end
    -- RoleAttributeUI.StartAutoMove(tonumber(Honor))

    --GUI.OpenWnd("ShopStoreUI","index:2")
    GUI.OpenWnd("ShopStoreUI","2")
end

--奇遇值
function RoleAttributeUI.OnAdventureBtnClick(key)
    -- local Adventure = 20066
    -- local adventure = CFG.Get_GameGlobalConfig("Adventure")
    -- if adventure ~= nil then
    --     Adventure = adventure.Value
    -- end
    -- RoleAttributeUI.StartAutoMove(tonumber(Adventure))
    -- --GUI.OpenWnd("CommitItemUI")

    --GUI.OpenWnd("ShopStoreUI","index:3")
    GUI.OpenWnd("ShopStoreUI","3")
end

--装备功勋
function RoleAttributeUI.OnEquipMeritBtnClick(key)
    -- local Donate = 20200
    -- local donate = CFG.Get_GameGlobalConfig("Merit")
    -- if donate ~= nil then
    --     Donate = donate.Value
    -- end
    -- RoleAttributeUI.StartAutoMove(tonumber(Donate))

    --GUI.OpenWnd("ShopStoreUI","index:7,index2:-1,1")
    GUI.OpenWnd("ShopStoreUI","7,-1,1")
end

--宠物功勋
function RoleAttributeUI.OnPetMeritBtnClick(key)
    -- local Donate = 20200
    -- local donate = CFG.Get_GameGlobalConfig("Merit")
    -- if donate ~= nil then
    --     Donate = donate.Value
    -- end
    -- RoleAttributeUI.StartAutoMove(tonumber(Donate))

    --GUI.OpenWnd("ShopStoreUI","index:7,index2:-1,2")
    GUI.OpenWnd("ShopStoreUI","7,-1,2")
end

-- --帮战积分
-- function RoleAttributeUI.OnIntegralBtnClick(key)
--     if CL.GetFightState() then
--         CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法执行该操作")
--         return
--     end
--     if not RoleAttributeUI.WhetherCanStartAutoMove() then
--         CL.SendNotify(NOTIFY.ShowBBMsg, "操作失败，您不是队长无法进行该操作。")
--         return
--     end
--     CL.SendNotify(NOTIFY.ShowBBMsg, "该系统尚未开启，敬请期待")
-- end

--战功点
function RoleAttributeUI.OnBattleMeritBtnClick(guid)
    -- test("OnBattleMeritBtnClick")
    -- RoleAttributeUI.StartAutoMove(21074)

    --GUI.OpenWnd("ShopStoreUI","index:5")
    GUI.OpenWnd("ShopStoreUI","5")
end

-- function RoleAttributeUI.OnBattlegroundBtnClick(key)
--     if CL.GetFightState() then
--         CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法执行该操作")
--         return
--     end
--     if not RoleAttributeUI.WhetherCanStartAutoMove() then
--         CL.SendNotify(NOTIFY.ShowBBMsg, "操作失败，您不是队长无法进行该操作。")
--         return
--     end
--     CL.SendNotify(NOTIFY.ShowBBMsg, "该系统尚未开启，敬请期待")
-- end

function RoleAttributeUI.SelfLevelChange(attrType, value)
    RoleAttributeUI.SetSelfLevel(value)
end

function RoleAttributeUI.SetSelfLevel(value)
    local levelTxt = GuidCacheUtil.GetUI("levelTxt")

    if levelTxt ~= nil then
        GUI.StaticSetText(levelTxt, tostring(value) .. " 级")
    end
end

function RoleAttributeUI.SelfMaxBloodChange(attrType, value)
    RoleAttributeUI.SelfBloodChange(attrType, value)
end

function RoleAttributeUI.SelfMaxBlueChange(attrType, value)
    RoleAttributeUI.SelfBlueChange(attrType, value)
end

function RoleAttributeUI.SelfMaxSpChange(attrType, value)
    RoleAttributeUI.SelfSpChange(attrType, value)
end

function RoleAttributeUI.SelfMaxVitalityChange(attrType, value)
    RoleAttributeUI.SelfVitalityChange(attrType, value)
end

function RoleAttributeUI.SelfFightValueChange(attrType, value)
    RoleAttributeUI.SetFightValue(value)
end

function RoleAttributeUI.SetFightValue(value)
    local fightTxt = GuidCacheUtil.GetUI("fightTxt")
    if fightTxt ~= nil then
        GUI.StaticSetText(fightTxt, tostring(value))
        --GUI.SetVisible(fightTxt,false)
    end
    --UILayout_table.GetFightValuePictureNum(value,fightFlower2,10,0)
end

function RoleAttributeUI.SelfBloodChange(attrType, value)
    --if CL.GetFightViewState() then
    --    return
    --end
    local currentHp = 0
    local maxHp = 1

    if RoleAttributeUI.IsInfight then
        currentHp = CL.GetInfightRoleHp()
        maxHp = CL.GetInfightRoleHpMax()
    else
        attrType = attrType or RoleAttr.RoleAttrHpLimit
        value = value or CL.GetAttr(attrType)
        currentHp = attrType == RoleAttr.RoleAttrHp and value or CL.GetAttr(RoleAttr.RoleAttrHp)
        maxHp = attrType == RoleAttr.RoleAttrHpLimit and value or CL.GetAttr(RoleAttr.RoleAttrHpLimit)
    end
    if maxHp ~= 0 then
        RoleAttributeUI.SetSelfSliderValue("blood", currentHp, maxHp)
    end
    RoleAttributeUI.SelfHpChange(attrType, maxHp)
end

function RoleAttributeUI.SelfBlueChange(attrType, value)
    --if CL.GetFightViewState() then
    --    return
    --end

    local currentMp = 0
    local maxMp = 1

    if RoleAttributeUI.IsInfight then
        currentMp = CL.GetInfightRoleMp()
        maxMp = CL.GetInfightRoleMpMax()
    else
        attrType = attrType or RoleAttr.RoleAttrMpLimit
        value = value or CL.GetAttr(attrType)
        currentMp = attrType == RoleAttr.RoleAttrMp and value or CL.GetAttr(RoleAttr.RoleAttrMp)
        maxMp = attrType == RoleAttr.RoleAttrMpLimit and value or CL.GetAttr(RoleAttr.RoleAttrMpLimit)
    end

    if maxMp ~= int64.zero then
        RoleAttributeUI.SetSelfSliderValue("blue", currentMp, maxMp)
    end
    RoleAttributeUI.SelfMpChange(attrType, maxMp)
end

function RoleAttributeUI.SelfSpChange(attrType, value)
    --if CL.GetFightViewState() then
    --    return
    --end

    local currentSp = 0
    local maxSp = 1

    if RoleAttributeUI.IsInfight then
        currentSp = LD.GetFighterAttr(RoleAttr.RoleAttrSp)
        maxSp = LD.GetFighterAttr(RoleAttr.RoleAttrSpLimit)
    else
        attrType = attrType or RoleAttr.RoleAttrSpLimit
        value = value or CL.GetAttr(attrType)
        currentSp = attrType == RoleAttr.RoleAttrSp and value or CL.GetAttr(RoleAttr.RoleAttrSp)
        maxSp = attrType == RoleAttr.RoleAttrSpLimit and value or CL.GetAttr(RoleAttr.RoleAttrSpLimit)
    end

    if maxSp ~= int64.zero then
        RoleAttributeUI.SetSelfSliderValue("yellow", currentSp, maxSp)
    end
end

function RoleAttributeUI.SelfVitalityChange(attrType, value)
    attrType = attrType or RoleAttr.RoleAttrVpLimit
    value = value or CL.GetAttr(attrType)
    local vp = attrType == RoleAttr.RoleAttrVp and value or CL.GetAttr(RoleAttr.RoleAttrVp)
    local maxVp = attrType == RoleAttr.RoleAttrVpLimit and value or CL.GetAttr(RoleAttr.RoleAttrVpLimit)
    if maxVp ~= int64.zero then
        RoleAttributeUI.SetSelfSliderValue("vitality", vp, maxVp)
    end
end

function RoleAttributeUI.SelfBloodStoreChange(attrType, value)
    local maxHpStore = CL.GetAttr(RoleAttr.RoleAttrHpPoolLimit)
    if maxHpStore == int64.zero then
        maxHpStore = 1
    end
    RoleAttributeUI.SetSelfStoreValue("blood", value, maxHpStore, true)
end

function RoleAttributeUI.SelfBlueStoreChange(attrType, value)
    local maxMpStore = CL.GetAttr(RoleAttr.RoleAttrMpPoolLimit)
    if maxMpStore == int64.zero then
        maxMpStore = 1
    end
    RoleAttributeUI.SetSelfStoreValue("blue", value, maxMpStore, true)
end

function RoleAttributeUI.SetSelfSliderValue(where, currentValue, MaxValue)
    local selfSliderInfo = GuidCacheUtil.GetUI(where .. "Slider")
    local selfSliderInfoTxt = GuidCacheUtil.GetUI(where .. "SliderTxtlabel")
    local pointPageTxt = GuidCacheUtil.GetUI(where .. "StrongPageTxt")
    MaxValue = tonumber(tostring(MaxValue))
    if MaxValue == 0 then
        MaxValue = 1
    end
    if selfSliderInfo ~= nil then
        GUI.ScrollBarSetPos(selfSliderInfo, tonumber(tostring(currentValue)) / MaxValue)
    end

    if selfSliderInfoTxt ~= nil then
        GUI.StaticSetText(selfSliderInfoTxt, tostring(currentValue) .. "/" .. MaxValue)
    end
    if pointPageTxt ~= nil then
        GUI.StaticSetText(pointPageTxt, MaxValue)
    end
end

function RoleAttributeUI.SetSelfStoreValue(where, currentValue, MaxValue)
    local selfSliderInfo2 = GuidCacheUtil.GetUI(where .. "StoreSlider")
    local selfSliderInfoTxt2 = GuidCacheUtil.GetUI(where .. "StoreTxt")
    if selfSliderInfo2 ~= nil then
        GUI.ScrollBarSetPos(selfSliderInfo2, tonumber(tostring(currentValue)) / tonumber(tostring(MaxValue)))
    end
    MaxValue = tostring(MaxValue)
    if selfSliderInfoTxt2 ~= nil then
        GUI.StaticSetText(selfSliderInfoTxt2, tostring(currentValue) .. "/" .. MaxValue)
    end
end

function RoleAttributeUI.SelfHpChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("Hp", tostring(value))
end

function RoleAttributeUI.SelfMpChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("Mp", tostring(value))
end

function RoleAttributeUI.SelfPhyAttackChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("phyAttack", tostring(value))
end

function RoleAttributeUI.SelfPhyAttackDefChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("phyDefence", tostring(value))
end

function RoleAttributeUI.SelfPhyBurstRateChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("phyBurstRate", tostring(value))
end

function RoleAttributeUI.SelfMagAttackChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("magicAttack", tostring(value))
end

function RoleAttributeUI.SelfMagAttackDefChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("magDefence", tostring(value))
end

function RoleAttributeUI.SelfMagBurstRateChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("magBurstRate", tostring(value))
end

function RoleAttributeUI.SelfSealRateChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("seal", tostring(value))
end

function RoleAttributeUI.SelfSealResistRateChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("antiSeal", tostring(value))
end

function RoleAttributeUI.SelfMissRateChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("miss", tostring(value))
end

function RoleAttributeUI.SelfHitRateChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("hit", tostring(value))
end

function RoleAttributeUI.SelfSpeedChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("speed", tostring(value))
end

function RoleAttributeUI.SetSelfDetailValue(where, currentValue)
    local detailPageTxt = GuidCacheUtil.GetUI(where .. "Txtlabel")
    local pointPageTxt = GuidCacheUtil.GetUI(where .. "StrongPageTxt")
    if detailPageTxt ~= nil then
        GUI.StaticSetText(detailPageTxt, tostring(currentValue))
    end
    if pointPageTxt ~= nil then
        GUI.StaticSetText(pointPageTxt, tostring(currentValue))
    end
end

function RoleAttributeUI.SelfStrengthPointChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("StrValue", value)
    RoleAttributeUI.SetSelfPointValue("strength", tostring(value))
end

function RoleAttributeUI.SelfMagicPointChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("IntValue", value)
    RoleAttributeUI.SetSelfPointValue("magic", tostring(value))
end

function RoleAttributeUI.SelfVitalityPointChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("VitValue", value)
    RoleAttributeUI.SetSelfPointValue("vitality", tostring(value))
end

function RoleAttributeUI.SelfEndurancePointChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("EndValue", value)
    RoleAttributeUI.SetSelfPointValue("endurance", tostring(value))
end

function RoleAttributeUI.SelfAgilityPointChange(attrType, value)
    RoleAttributeUI.SetSelfDetailValue("AgiValue", value)
    RoleAttributeUI.SetSelfPointValue("agility", tostring(value))
end

function RoleAttributeUI.SetSelfPointValue(where, currentValue)
    local pointPageTxt = GuidCacheUtil.GetUI(where .. "PointTxt")
    if pointPageTxt ~= nil then
        GUI.StaticSetText(pointPageTxt, currentValue)
    end
end

-- 经验变化： parameter = "oldValue_newvalue"
function RoleAttributeUI.SelfExperienceChange(attrType, value)
    local maxValue = CL.GetAttr(RoleAttr.RoleAttrExpLimit)
    RoleAttributeUI.SetExperience(value, maxValue)
end

function RoleAttributeUI.SetExperience(currentValue, maxValue)
    --local upLevelBtn = GuidCacheUtil.GetUI("upLevelBtn")
	currentValue = CL.GetIntCustomData("ServerLevel_SaveExp") ~= 0 and CL.GetIntCustomData("ServerLevel_SaveExp") or currentValue
    local experienceSlider = GuidCacheUtil.GetUI("experienceSlider")
    local experienceTxt = GuidCacheUtil.GetUI("experienceSliderCurrentTxt")
    if maxValue == int64.zero then
        maxValue = 1
    end
    if experienceSlider ~= nil and maxValue ~= 0 then
        GUI.ScrollBarSetPos(experienceSlider, tonumber(tostring(currentValue)) / tonumber(tostring(maxValue)))
    end
    if experienceTxt ~= nil then
        currentEpxerience = currentValue
        maxEpxerience = maxValue
        GUI.StaticSetText(experienceTxt, tostring(currentValue) .. "/" .. tostring(maxValue))
    end

    --local currentLevel = tonumber(CL.GetAttr(RoleAttr.RoleAttrLevel))
    --if currentLevel < RoleAttributeUI.RoleLevelMax then
    --    if currentValue >= maxValue then
    --        GUI.SetRedPointVisable(upLevelBtn, true)
    --    else
    --        GUI.SetRedPointVisable(upLevelBtn, false)
    --    end
    --else
    --    GUI.SetRedPointVisable(upLevelBtn, false)
    --end
end

function RoleAttributeUI.SelfBeevilChange(attrType, value)
    value = tostring(value)
    RoleAttributeUI.SelfDetailInfoValue("beevil", value)
    local subBeevilPage = GuidCacheUtil.GetUI("currentBeevilValue")
    if subBeevilPage ~= nil then
        GUI.StaticSetText(subBeevilPage, value)
    end
end
--------------------------------------------------PK的Icon图标状态改变Start-----------------------------------------
function RoleAttributeUI.SelfPkStateChange(attrType, value)
    --test("PKStatevalue"..tostring(value))
    --test("SelfPkStateChange")
    attrType = attrType or RoleAttr.RoleAttrCanPk
    value = value or CL.GetIntAttr(attrType)
    --local pkState=CL.GetIntAttr(RoleAttr.RoleAttrACanPk)


    local pkIcon = GuidCacheUtil.GetUI("pkIcon")
    if tonumber(tostring(value)) == 0 then
        --test("关闭状态" .. tostring(value))
        GUI.ImageSetImageID(pkIcon, pkIconPicture[1])
    else
        --test("开启状态" .. tostring(value))
        if GlobalProcessing.IsQuicklyPK then
            GUI.ImageSetImageID(pkIcon, pkIconPicture[2])
        else
            GUI.ImageSetImageID(pkIcon, pkIconPicture[3])
        end
    end
end
--------------------------------------------------PK的Icon图标状态改变End-----------------------------------------

function RoleAttributeUI.SelfAchievementChange(parameter)
    local values = split(parameter, "_")
    if values ~= nil and values[2] ~= nil then
        RoleAttributeUI.SelfDetailInfoValue("achievement", values[2])
    end
end

function RoleAttributeUI.SelfSchoolChange(attrType, value)
    local schoolName = "无"
    local school = DB.GetSchool(tonumber(tostring(value)))
    if school then
        schoolName = school.Name
    end
    RoleAttributeUI.SelfDetailInfoValue2("school", schoolName)
end

function RoleAttributeUI.SelfRemainPointChange(attrType, value)
    local remainPointText = GuidCacheUtil.GetUI("remainPointText")
    if remainPointText then
        GUI.StaticSetText(remainPointText, tostring(value))
        local addPointBtn = GuidCacheUtil.GetUI("addPointBtn")
        if tonumber(tostring(value)) > 0 then
            GUI.SetRedPointVisable(addPointBtn, true)
        else
            GUI.SetRedPointVisable(addPointBtn, false)
        end
    end
end

function RoleAttributeUI.SelfTitleChange(attrType, value)
    local titleConfig = nil
    if value then
        value = type(value) == "userdata" and tonumber(tostring(value)) or value
        titleConfig = DB.GetOnceTitleByKey1(value)
    end
    local aniSp = GuidCacheUtil.GetUI("aniSp")
    local roleTitleTxt = GuidCacheUtil.GetUI("roleTitleTxt")
    local titleTxt = "无称号"
    local isPic = false
    if titleConfig and titleConfig.Id ~= 0 then
        isPic = titleConfig.Pic ~= uint64.zero
        titleTxt = LD.GetCurTitle(value)--isPic and tostring(titleConfig.Pic) or titleConfig.Name
        RoleAttributeUI.SelfDetailInfoValue2("title", isPic and titleConfig.Name or titleTxt)
    else
        RoleAttributeUI.SelfDetailInfoValue2("title", "无称号")
    end
    GUI.SetVisible(aniSp, isPic)
    GUI.SetVisible(roleTitleTxt, not isPic)
    if isPic then
        GUI.SetFrameId(aniSp, titleTxt)
    else
        GUI.StaticSetText(roleTitleTxt, titleTxt)
    end

    if needTipsTitleChange then
        needTipsTitleChange = false
        CL.SendNotify(NOTIFY.ShowBBMsg, "更换成功")
    end
end

function RoleAttributeUI.SelfRoleAttrChange(attrType, value)
    local data = attributeEventList[attrType]
    if data then
        local txt = GuidCacheUtil.GetUI(data[3])
        GUI.StaticSetText(txt, tostring(value))
    end
end

function RoleAttributeUI.SelfNameChange(newName)
    if newName ~= nil and #newName ~= 0 then
        local nameTxt = GuidCacheUtil.GetUI("nameTxt")
        if nameTxt ~= nil then
            GUI.StaticSetText(nameTxt, newName)
        end
    end
end

function RoleAttributeUI.SelfMasterNameChange(parameter)
    local values = split(parameter, "_")
    if values ~= nil and values[2] ~= nil and #values[2] ~= 0 then
        RoleAttributeUI.SelfDetailInfoValue2("master", values[2])
    else
        RoleAttributeUI.SelfDetailInfoValue2("master", "无")
    end
end

-- 刷新帮派名称
function RoleAttributeUI.RefreshGuildName()
    local guildData = LD.GetGuildData()
    local name = "无"
    if guildData and guildData.guild and guildData.guild.guid ~= uint64.zero then
        name = guildData.guild.name
    end
    RoleAttributeUI.SelfDetailInfoValue2("faction", name)
end

--刷新夫妻名字

function RoleAttributeUI.RefreshCoupleName()
	local name = tostring(CL.GetStrCustomData("Marry_SpouseName") )
	if name == "nil"  then
		name = "无"
	end
    RoleAttributeUI.SelfDetailInfoValue2("couple", name)
end

-- 刷新师傅名称
function RoleAttributeUI.RefreshTeacherName()
	local name = tostring(CL.GetStrCustomData("TeacherName")) 
	if name == "nil"  then
		name = "无"
	end
    RoleAttributeUI.SelfDetailInfoValue2("master", name)
end
-- 刷新徒弟1名称
function RoleAttributeUI.RefreshStudent1Name()
	local name = tostring(CL.GetStrCustomData("PupilName_1")) 
	if name == "nil"  then
		name = "无"
	end
    RoleAttributeUI.SelfDetailInfoValue2("apprentice", name)
end
-- 刷新徒弟2名称
function RoleAttributeUI.RefreshStudent2Name()
	local name = tostring(CL.GetStrCustomData("PupilName_2") )
	if name == "nil"  then
		name = "无"
	end
	local txtLable = GUI.Get("RoleAttributeUI/panelBg/page2/apprenticeTip/apprenticeTxt2")
    if txtLable ~= nil then
        GUI.StaticSetText(txtLable, name)
    end
end

function RoleAttributeUI.SelfApprenticeNameChange(parameter)
    local values = split(parameter, "_")
    if values ~= nil and values[2] ~= nil and #values[2] ~= 0 then
        RoleAttributeUI.SelfDetailInfoValue2("apprentice", values[2])
        if values[3] ~= nil and #values[3] ~= 0 then
            RoleAttributeUI.SetApprenticeTxt2(values[3])
        else
            RoleAttributeUI.SetApprenticeTxt2("无")
        end
    else
        RoleAttributeUI.SelfDetailInfoValue2("apprentice", "无")
        RoleAttributeUI.SetApprenticeTxt2("无")
    end
end

function RoleAttributeUI.SetApprenticeTxt2(Txt)
    --local nameTxt = GUI.Get("RoleAttributeUI/panelBg/page2/apprenticeTip/apprenticeTxt2")
    --if nameTxt ~= nil then
    --    GUI.StaticSetText(nameTxt, Txt)
    --end
end

function RoleAttributeUI.SelfCoupleChange(parameter)
    local values = split(parameter, "_")
    if values ~= nil and values[2] ~= nil and #values[2] ~= 0 then
        RoleAttributeUI.SelfDetailInfoValue2("couple", values[2])
    else
        RoleAttributeUI.SelfDetailInfoValue2("couple", "未婚")
    end
end

function RoleAttributeUI.SelfIntegralChange(parameter)
    local values = split(parameter, "_")
    if values ~= nil and values[2] ~= nil then
        RoleAttributeUI.SelfDetailInfoValue("integral", 0)
        --RoleAttributeUI.SelfDetailInfoValue("integral",values[2])
    end
end

function RoleAttributeUI.SelfMentorChange(parameter)
    local values = split(parameter, "_")
    if values ~= nil and values[2] ~= nil then
        RoleAttributeUI.SelfDetailInfoValue("mentor", values[2])
    end
end

function RoleAttributeUI.SelfHonorChange(parameter)
    local values = split(parameter, "_")
    if values ~= nil and values[2] ~= nil then
        RoleAttributeUI.SelfDetailInfoValue("honor", values[2])
    end
end

function RoleAttributeUI.SelfAdventureChange(parameter)
    local values = split(parameter, "_")
    if values ~= nil and values[2] ~= nil then
        RoleAttributeUI.SelfDetailInfoValue("adventure", values[2])
    end
end

function RoleAttributeUI.SelfDetailInfoValue(where, value)
    local txtLable = GUI.Get("RoleAttributeUI/panelBg/page2/" .. where .. "Tip/" .. where .. "Txt")
    if txtLable ~= nil then
        GUI.StaticSetText(txtLable, value)
    end
end

function RoleAttributeUI.SelfDetailInfoValue2(where, value)
    local txtLable = GUI.Get("RoleAttributeUI/panelBg/page2/" .. where .. "Tip/" .. where .. "Txt")
    if txtLable ~= nil then
        GUI.StaticSetText(txtLable, value)
    end
end

function RoleAttributeUI.Init()
    --test("Init")
    local selfNickName = CL.GetRoleName()
    if selfNickName ~= nil and #selfNickName > 0 then
        RoleAttributeUI.RegisterAttributeEvent()
        RoleAttributeUI.RegisterMessageEvent(selfNickName)
    else
        --延时后注册。
        selfNickName = CL.GetRoleName()
        RoleAttributeUI.RegisterAttributeEvent()
        RoleAttributeUI.RegisterMessageEvent(selfNickName)
    end
    RoleAttributeUI.InitValue(selfNickName)
end

function RoleAttributeUI.RegisterAttributeEvent()
    for k, v in pairs(attributeEventList) do
        CL.UnRegisterAttr(k, RoleAttributeUI[v[1]])
        CL.RegisterAttr(k, RoleAttributeUI[v[1]])
    end
end

function RoleAttributeUI.RegisterMessageEvent(selfNickName)
    for i = 1, #messageEventList do
        CL.UnRegisterMessage(messageEventList[i][2], "RoleAttributeUI", messageEventList[i][1])
        CL.RegisterMessage(messageEventList[i][2], "RoleAttributeUI", messageEventList[i][1])
    end
end

function RoleAttributeUI.OnCustomDataUpdate(customType, key, value)
    local name = customAttrList[key]
    if not name then
        return
    end
    local txt = GuidCacheUtil.GetUI(name)
    if customType == 1 then -- 1是string类型
        GUI.StaticSetText(txt, value)
    else
        GUI.StaticSetText(txt, tostring(value))
    end
end

function RoleAttributeUI.OnExit(key)
    local wnd = GUI.GetWnd("RoleAttributeUI")
    if wnd ~= nil then
        if RoleAttributeUI.addPointTimer ~= nil then
            RoleAttributeUI.addPointTimer:Stop()
            RoleAttributeUI.addPointTimer = nil
        end
        RoleAttributeUI.DestroyRoleModel()
        RoleAttributeUI.ClearSelectInfo()
        GUI.CloseWnd("RoleAttributeUI")
    end
end

-- 定义一个最大值的表，放所有的最大值？最大值变化时刷新 local values = {}
function RoleAttributeUI.InitValue(selfNickName)
    --test("InitValue")
    if selfNickName == nil or #selfNickName == 0 then
        --test("么有名字")
        return
    end
    local nameTxt = GuidCacheUtil.GetUI("nameTxt")
    if nameTxt ~= nil then
        GUI.StaticSetText(nameTxt, selfNickName)
    end
    local roleIDTxt = GuidCacheUtil.GetUI("roleIDTxt")
    if roleIDTxt ~= nil then
        GUI.StaticSetText(roleIDTxt, tostring(CL.GetAttr(RoleAttr.RoleAttrSN)))
    end

    RoleAttributeUI.RefreshData()
end

function RoleAttributeUI.ModelSetVisibel(canSee)
    local page1 = GuidCacheUtil.GetUI("page1")
    if page1 ~= nil then
        GUI.SetVisible(page1, canSee)
    end
end

function RoleAttributeUI.RefreshData()
    RoleAttributeUI.IsShowWndRefreshData = true
    RoleAttributeUI.SetSelfLevel(CL.GetAttr(RoleAttr.RoleAttrLevel))
    RoleAttributeUI.SetFightValue(CL.GetAttr(RoleAttr.RoleAttrFightValue))
    for k, v in pairs(attributeEventList) do
        if v[2] then
            local func = RoleAttributeUI[v[1]]
            if func then
                func(k, CL.GetAttr(k))
            end
        end
    end

    -- 设置自定义属性的值
    for k, v in pairs(customAttrList) do
        local txt = GuidCacheUtil.GetUI(v)
        GUI.StaticSetText(txt, tostring(CL.GetIntCustomData(k)))
    end

    local school = DB.GetSchool(tonumber(CL.GetIntAttr(RoleAttr.RoleAttrJob1)))
    RoleAttributeUI.RefreshGuildName()
    RoleAttributeUI.SelfNameChange(CL.GetRoleName())
	RoleAttributeUI.RefreshCoupleName()
	RoleAttributeUI.RefreshTeacherName()
	RoleAttributeUI.RefreshStudent1Name()
	RoleAttributeUI.RefreshStudent2Name()
    local roleconfig = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole))
    if not roleconfig then
        return
    end
    local jobSprite = GuidCacheUtil.GetUI("jobSprite")
    if jobSprite ~= nil then
        GUI.ImageSetImageID(jobSprite, tostring(school.Icon))
    end
    local raceTxt = GuidCacheUtil.GetUI("raceTxt")
    if raceTxt then
        GUI.StaticSetText(raceTxt, UIDefine.GetRaceName(CL.GetIntAttr(RoleAttr.RoleAttrRace)) .. "   " .. roleconfig.RoleName)
    end
end

-- 刷新属性列表面板
function RoleAttributeUI.RefreshAttributeListPanel()
    GUI.OpenWnd("ShowAttributeUI")
    ShowAttributeUI.RefreshAttributeUI()
end

function RoleAttributeUI.SetUpLevelInteractable()
    local upLevelBtn = GUI.Get("RoleAttributeUI/panelBg/page1/experienceBg/upLevelBtn")
    if upLevelBtn == nil then
        return
    end
    if tonumber(currentEpxerience) >= tonumber(maxEpxerience) then
        GUI.SetInteractable(upLevelBtn, true)
    else
        GUI.SetInteractable(upLevelBtn, false)
    end
end
function RoleAttributeUI.SetUpLevelInteractableEx(inc)
    local upLevelBtn = GUI.Get("RoleAttributeUI/panelBg/page1/experienceBg/upLevelBtn")
    if upLevelBtn == nil then
        return
    end
    GUI.SetInteractable(upLevelBtn, inc)
end
----------------------------------血池蓝池使用后刷新背包Start---------------------------------------------------------------
--function RoleAttributeUI.RefreshBag()
--    local addpage = GuidCacheUtil.GetUI("addBloodOrBlueCover")
--    if not GUI.GetVisible(addpage) then
--        return
--    end
--    local bg = GuidCacheUtil.GetUI("panelBg")
--    local curType = GUI.GetData(bg, "CurrentSubType")
--    RoleAttributeUI.ItemList(curType)
--    RoleAttributeUI.CreateOrRefreshItemList()
--    local curCount = #itemList
--    --GUI.LoopScrollRectSetTotalCount(scroll,curCount)
--    --GUI.LoopScrollRectRefreshCells(scroll)
--    if curCount == 0 then
--        --setSelect = false
--        local tips = GUI.GetChild(bg, "tipsleft")
--        if tips ~= nil then
--            GUI.Destroy(tips)
--        end
--    end
--end
----------------------------------血池蓝池使用后刷新背包End-----------------------------------------------------------------
function RoleAttributeUI.ShowForm(formName, info)
    if formName == "BeevilInfo" then
        assert(loadstring(info))()
    elseif formName == "Guard_GetAllAddAttr" then
        RoleAttributeUI.CreateGuardAddAttrTips(info)
    end
end
----------------------------------------------------------------------善恶值   start------------------------------------------------------
--像服务器端发送请求  获取能够清除善恶值的物品数据
--function RoleAttributeUI.GetClearBeevilInfo()
--    --test("GetClearBeevilInfo")
--    CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "getReduceEvilItemId")
--    --test("GetClearBeevilInfo----------over")
--end
local itemGradeImage = {
    1801100120, 1801100130, 1801100140, 1801100150, 1801100160
}
local itemGradeColor = {
    "#66310eff", "#46DC5Fff", "#42B1F0ff", "#E855FFff", "#FF8700ff"
}
--服务器回调方法
--function RoleAttributeUI.SetClearBeevilInfo(itemId)
--    local page = GUI.Get("RoleAttributeUI/panelBg/page2/clearBeevilCover")
--    local rolePKValue=CL.GetIntAttr(RoleAttr.RoleAttrPK)
--    if rolePKValue>=0 and page~= nil then
--        GUI.SetVisible(page,false)
--    end
--
--
--    local itemId=RoleAttributeUI.ReduceEvilItemId
--    --test("data is "..tonumber(itemId))
--    test("SetClearBeevilInfo")
--    --itemId=itemId or RoleAttributeUI.ReduceEvilItemId
--    test("itemId"..itemId)
--    local itemDB=DB.GetOnceItemByKey1(itemId)
--    local itemAmountInBag=LD.GetItemCountById(itemId)
--
--    local clearBeevilBg=GuidCacheUtil.GetUI("clearBeevilBg")
--    local itemIconBg=GUI.GetChild(clearBeevilBg,"itemIconBg")
--    local itemIcon=GUI.GetChild(itemIconBg,"itemIcon")
--    local itemAmountTxt=GUI.GetChild(itemIconBg,"itemAmountTxt")
--    local clearTxtBg=GUI.GetChild(clearBeevilBg,"clearTxtBg")
--    local currentBeevilValue=GUI.GetChild(clearTxtBg,"currentBeevilValue")
--    local costLabel=GUI.GetChild(clearBeevilBg,"clearBeevilCostLabel")
--
--    GUI.ImageSetImageID(itemIconBg,itemGradeImage[itemDB.Grade])
--    GUI.ImageSetImageID(itemIcon,itemDB.Icon)
--    local amountTxt=itemAmountInBag.."/1"
--    GUI.StaticSetText(itemAmountTxt,amountTxt)
--    if itemAmountInBag>=1 then
--        GUI.SetColor(itemAmountTxt,UIDefine.WhiteColor)
--    else
--        GUI.SetColor(itemAmountTxt,UIDefine.RedColor)
--    end
--    GUI.StaticSetText(currentBeevilValue,rolePKValue)
--    local strUseful=string.split(itemDB.Info,"，")
--    local infoTxt="是否消耗 <color="..itemGradeColor[itemDB.Grade]..">"..itemDB.Name.."</color> 清除善恶值("..strUseful[2]..")"
--    GUI.StaticSetText(costLabel,infoTxt)
--    --GUI.SetColor(costLabel,UIDefine.PurpleColor)
--    test("SetClearBeevilInfo-------Over")
--end

--function RoleAttributeUI.OneClearBeevil(key)
--    test("点击了使用一个按钮"..RoleAttributeUI.ReduceEvilItemId)
--
--    CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "useReduceEvilItem","1",tostring(RoleAttributeUI.ReduceEvilItemId))
--    --RoleAttributeUI.OnCancleClearBeevil(key)
--end
--
--function RoleAttributeUI.AllClearBeevil(key)
--    test("点击了清除全部按钮"..RoleAttributeUI.ReduceEvilItemId)
--    CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "useReduceEvilItem","2",tostring(RoleAttributeUI.ReduceEvilItemId))
--end
--
--function RoleAttributeUI.OnCancleClearBeevil(key)
--    CL.UnRegisterMessage(GM.RefreshBag, "RoleAttributeUI", "SetClearBeevilInfo")
--    local page = GUI.Get("RoleAttributeUI/panelBg/page2/clearBeevilCover")
--    if page ~= nil then
--        GUI.SetVisible(page, false)
--    end
--end

--[[以下是pK按钮的相关方法]]--
--确定按钮点击方法
function RoleAttributeUI.OnPKBtnClick()
    --去寻找PK NPC的方法
    local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    local openLevel = MainUI.MainUISwitchConfig["PK"].OpenLevel
    if roleLevel < openLevel then
        -- "您需要达到20级才能开启PK功能"
        CL.SendNotify(NOTIFY.ShowBBMsg,"您需要达到"..tostring(openLevel).."级才能开启PK功能")
        local page = GUI.Get("RoleAttributeUI/panelBg/page2/pkBtnTipsCover")
        GUI.SetVisible(page, false)
        return
    end
    local page = GUI.Get("RoleAttributeUI/panelBg/page2/pkBtnTipsCover")
    GUI.SetVisible(page, false)
    RoleAttributeUI.OnExit()
    CL.SendNotify(NOTIFY.SubmitForm, "FormPkRule", "gotoNegatePkSwitchNpc")

end
--取消点击方法
function RoleAttributeUI.OnCancelPKTips()
    local page = GUI.Get("RoleAttributeUI/panelBg/page2/pkBtnTipsCover")
    if page ~= nil then
        GUI.SetVisible(page, false)
    end
end
----------------------------------------------------------------------善恶值   end------------------------------------------------------

----------------------------------------------------------------------预览加点效果   start------------------------------------------------------
function RoleAttributeUI.UpdataPrePointState()
    local data = {}
    for i = 1, #attributeList6 do
        local tempTxt = RoleAttributeUI.GetPointPutTxt(attributeList6[i][2])
        if tempTxt ~= nil then
            local currentValue = GUI.GetData(tempTxt, "CurrentPoint")
            if currentValue == nil or #currentValue == 0 then
                currentValue = 0
            else
                currentValue = tonumber(currentValue)
            end
            data[i] = currentValue
        end
    end
end
--刷新捐献货币
function RoleAttributeUI.GetConvertPoints(equipPoint, petPoint)
    --	test("刷新捐献货币")
    if equipPoint ~= nil then
        RoleAttributeUI.SelfDetailInfoValue("equipMerit", equipPoint)
    end
    if petPoint ~= nil then
        RoleAttributeUI.SelfDetailInfoValue("petMerit", petPoint)
    end
end

--function RoleAttributeUI.GetIncreaseSprite(where)
--    local increaseSprite = GUI.Get("RoleAttributeUI/panelBg/page3/" .. where .. "Sprite")
--    return increaseSprite
--end

function RoleAttributeUI.ResetIncreaseSprite()
    --for i = 1, #attributeList5 do
    --    local increaseSprite = RoleAttributeUI.GetIncreaseSprite(attributeList5[i][2])
    --    local pointTxt = RoleAttributeUI.GetPointTxt(attributeList5[i][2])
    --    GUI.SetVisible(increaseSprite, false)
    --    GUI.SetColor(pointTxt, colorYellow)
    --end
end

function RoleAttributeUI.GetPointTxt(where)
    local pointTxt = GUI.Get("RoleAttributeUI/panelBg/page3/" .. where .. "StrongPageTip/" .. where .. "StrongPageTxt")
    if pointTxt ~= nil then
        return pointTxt
    end
end
----------------------------------------------------------------------预览加点效果 end ------------------------------------------------------
-- 回帮派成功
function RoleAttributeUI.OnBackFactionAck(parameter)
    local str = split(parameter, "#cutline#")
    local operateType = guild_operate_type.IntToEnum(tonumber(str[1]))
    if operateType == guild_operate_type.guild_operate_go_back then
        RoleAttributeUI.OnExit()
    end
end
-- 回门派成功
function RoleAttributeUI.OnBackSchoolAck()
    RoleAttributeUI.OnExit()
end

function RoleAttributeUI.OnInFightRoleAttrChange()
    --if CL.GetFightViewState() then
    --    return
    --end
    RoleAttributeUI.SelfMaxBloodChange()
    RoleAttributeUI.SelfMaxBlueChange()
end

function RoleAttributeUI.OnInFightPetAttrChange()
    --if CL.GetFightViewState() then
    --    return
    --end
end

function RoleAttributeUI.OnInFight(isInFight)
    RoleAttributeUI.IsInfight = isInFight
    RoleAttributeUI.OnInFightRoleAttrChange()
    if isInFight then
        RoleAttributeUI.OnExit()
    end
end

function RoleAttributeUI.WhetherCanStartAutoMove()
    if LD.GetRoleInTeamState() == 3 then
        return false
    end
    return true
end

function RoleAttributeUI.ShowTitleRemainTime(titleId, remainTime)
    --test("收到限时称号反馈： ", titleId, remainTime)
    titleId = tonumber(titleId)
    if titleId == nil or titleId ~= RoleAttributeUI.SelectTitleId then
        --test("已经选择其他的称号了，信息返回延迟 ： ", titleId, remainTime)
        return
    end
    local timeText = GuidCacheUtil.GetUI("remainTimeText")
    if timeText == nil then
        return
    end
    GUI.StaticSetText(timeText, "")

    if remainTime == nil then
        return
    end
    remainTime = tonumber(remainTime)
    if remainTime > 0 then
        local day, hour, min, sec = GlobalUtils.Get_DHMS1_BySeconds(remainTime)
        local timeString
        if day == 0 then
            if hour == 0 then
                if min == 0 then
                    min = 1
                end
                timeString = min .. "分钟"
            else
                timeString = hour .. "小时" .. min .. "分钟"
            end
        else
            timeString = day .. "天" .. hour .. "小时" .. min .. "分钟"
        end
        GUI.SetVisible(timeText, true)
        GUI.StaticSetText(timeText, "<color=#662F16>剩余时间：</color>" .. timeString)
    else
        GUI.SetVisible(timeText, false)
    end
end

function RoleAttributeUI.JudgeLevelUpState(rate)
    local cost = math.ceil(rate * maxEpxerience)
    RoleAttributeUI.SelfExperienceChange(RoleAttr.RoleAttrExp, CL.GetIAttr(RoleAttr.RoleAttrExp))
    RoleAttributeUI.SetUpLevelInteractableEx(currentEpxerience >= cost)
end
-----------------------------------------能够增加血池与魔池的物品Start-------------------------------------------------------
-- 加入剪影的列表
--function RoleAttributeUI.GenCanAddAttributeItems()
--    local allItems = DB.Getitem_consumableAllKeys()
--    if allItems == nil or allItems.Count < 1 then
--        test("获取Item表失败")
--        return
--    end
--
--    RoleAttributeUI.CanAddBlueItems = nil
--    RoleAttributeUI.CanAddBlueItems = {}
--    RoleAttributeUI.CanAddBloodItems = nil
--    RoleAttributeUI.CanAddBloodItems = {}
--    for i = 0, allItems.Count - 1 do
--        local id = allItems[i]
--        local item = DB.Get_item_consumable(id)
--        if item ~= nil then
--            if tonumber(item.Type) == 25 then
--                if item.Id ~= 20404 and item.Id ~= 20405 and item.Id ~= 20406 then
--                    table.insert(RoleAttributeUI.CanAddBloodItems, item.Id)
--                end
--            elseif tonumber(item.Type) == 26 then
--                if item.Id ~= 20506 then
--                    table.insert(RoleAttributeUI.CanAddBlueItems, item.Id)
--                end
--            end
--        end
--    end
--    test(#RoleAttributeUI.CanAddBloodItems)
--    test(#RoleAttributeUI.CanAddBlueItems)
--end
-----------------------------------------能够增加血池与魔池的物品End-------------------------------------------------------
function RoleAttributeUI.OnGuardAddArrBtnClick(guid)
    CL.SendNotify(NOTIFY.SubmitForm, "FormList", "Guard_GetAllAddAttr")
end

local arrSort = {
    [1] = 72,
    [2] = 74,
    [3] = 79,
    [4] = 81,
    [5] = 80,
    [6] = 82,
    [7] = 95,
    [8] = 98,
    [9] = 84,
    [10] = 83,
    [11] = 85,
}

function RoleAttributeUI.CreateGuardAddAttrTips(value)
    local attr = {}
    attr = assert(loadstring('return ' .. value))()
    if attr ~= nil then
        local count = 0
        local tmpArr = {}
        local extraArr = {}
        local extraCount = 0

        for k, v in pairs(attr) do
            local tmp = true
            for i = 1, #arrSort do
                if tmp then
                    if tonumber(k) == arrSort[i] then
                        count = count + 1
                        tmpArr[count] = {}
                        tmpArr[count]["k"] = k
                        tmpArr[count]["v"] = v
                        tmpArr[count]["index"] = i
                        tmp = false
                    end
                end
            end

            if tmp then
                extraCount = extraCount + 1
                extraArr[extraCount] = {}
                extraArr[extraCount]["k"] = k
                extraArr[extraCount]["v"] = v
            end
        end

        for i = 1, #extraArr do
            count = count + 1
            tmpArr[count] = {}
            tmpArr[count]["k"] = extraArr[i]["k"]
            tmpArr[count]["v"] = extraArr[i]["v"]
            tmpArr[count]["index"] = #arrSort + i
        end

        table.sort(tmpArr, function(a, b)
            return a.index < b.index
        end)

        local addArrTip = GUI.Get("RoleAttributeUI/panelBg/addArrTip")
        if addArrTip ~= nil and GUI.GetVisible(addArrTip) then
            GUI.Destroy(addArrTip)
            return
        end

        local guardAddArrTip = GUI.Get("RoleAttributeUI/panelBg/page1/guardAddArrTip")
        if guardAddArrTip == nil then
            --test("未找到侍从加成属性按钮")
            return
        end
        local panelBg = GuidCacheUtil.GetUI("panelBg")
        local sameSize = 22
        if count > 0 then
            local extraHeight = 40
            local width = count > 1 and 340 or 200
            local height = math.ceil(count / 2) * 30

            addArrTip = GUI.ImageCreate(panelBg, "addArrTip", "1800400290", 95, -130, false, width, height + extraHeight + 10)
            SetAnchorAndPivot(addArrTip, UIAnchor.Center, UIAroundPivot.Center)

            local tip = GUI.CreateStatic(addArrTip, "tip", "侍从加成总属性", 15, 10)
            SetAnchorAndPivot(tip, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(tip, sameSize)

            local tmpIndex = 1
            for i = 1, #tmpArr do
                local tmp = tmpIndex - math.floor(tmpIndex / 2) * 2
                local tmpX = tmp == 1 and 15 or 180
                local tmpY = (math.ceil(tmpIndex / 2) - 1) * 30 + extraHeight
                local label = GUI.CreateStatic(addArrTip, "label", "", tmpX, tmpY)
                SetAnchorAndPivot(label, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                GUI.StaticSetFontSize(label, sameSize)
                tmpIndex = tmpIndex + 1
                if tonumber(tmpArr[i]["k"]) ~= nil then
                    local basicData = DB.Get_basic(tonumber((tmpArr[i]["k"])))
                    if basicData ~= nil then
                        GUI.StaticSetText(label, basicData.Name .. "+" .. (tmpArr[i]["v"]))
                    end
                end
            end

            GUI.SetIsRemoveWhenClick(addArrTip, true)
            GUI.AddWhiteName(addArrTip, GUI.GetGuid(guardAddArrTip))
        else
            addArrTip = GUI.ImageCreate(panelBg, "addArrTip", "1800400290", 50, -130, false, 250, 50)
            SetAnchorAndPivot(addArrTip, UIAnchor.Center, UIAroundPivot.Center)

            local tip = GUI.CreateStatic(addArrTip, "tip", "", 15, 10)
            SetAnchorAndPivot(tip, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(tip, sameSize)

            GUI.StaticSetText(tip, "侍从加成总属性：无")

            GUI.SetIsRemoveWhenClick(addArrTip, true)
            GUI.AddWhiteName(addArrTip, GUI.GetGuid(guardAddArrTip))
        end
    end
end



function RoleAttributeUI.StartAutoMove(npcId)
    --test("RoleAttributeUI.StartAutoMove(npcId) : ", npcId)
    if CL.GetFightState() then
        CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法执行该操作")
        return
    end

    if not RoleAttributeUI.WhetherCanStartAutoMove() then
        CL.SendNotify(NOTIFY.ShowBBMsg, "操作失败，您不是队长无法进行该操作。")
        return
    end
    if npcId then
        CL.StartMove(npcId)
        RoleAttributeUI.OnExit()
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "该系统尚未开启，敬请期待")
    end
end

function RoleAttributeUI.OnRoleChangeName(guid, name)
    if guid == LD.GetSelfGUID() then
        RoleAttributeUI.SelfNameChange(name)
    end
end

--------------------------------------------补充血池蓝池重构方法Start-------------------------------------------------------

--血池补充方法点击
function RoleAttributeUI.OnBloodSupBtnClick(key)
    local page = GuidCacheUtil.GetUI("addBloodOrBlueCover")
    --local scroll = GUI.GetChild(page, "scroll")
    --GUI.Destroy(scroll)
    GUI.SetVisible(page, true)

    CL.RegisterMessage(GM.RefreshBag, "RoleAttributeUI", "ItemList")
    CL.RegisterMessage(GM.RefreshBag, "RoleAttributeUI", "CreateOrRefreshItemList")
    --RoleAttributeUI.SelectItemIndex = 0
    --RoleAttributeUI.NeedResetItemScrorectPosition = true
    RoleAttributeUI.FirstOpenItemScroll = true

    local bg = GuidCacheUtil.GetUI("panelBg")
    GUI.SetData(bg, "CurrentSubType", "血池")

    RoleAttributeUI.CanAddAttributeItems()
    RoleAttributeUI.ItemList()
    RoleAttributeUI.CreateOrRefreshItemList()
end

--魔池补充方法点击
function RoleAttributeUI.OnBlueSupBtnClick(key)

    local page = GuidCacheUtil.GetUI("addBloodOrBlueCover")
    --local scroll = GUI.GetChild(page, "scroll")
    --GUI.Destroy(scroll)
    GUI.SetVisible(page, true)
    CL.RegisterMessage(GM.RefreshBag, "RoleAttributeUI", "ItemList")
    CL.RegisterMessage(GM.RefreshBag, "RoleAttributeUI", "CreateOrRefreshItemList")
    --RoleAttributeUI.SelectItemIndex = 0
    --RoleAttributeUI.NeedResetItemScrorectPosition = true
    RoleAttributeUI.FirstOpenItemScroll = true
    local bg = GuidCacheUtil.GetUI("panelBg")
    GUI.SetData(bg, "CurrentSubType", "魔池")

    RoleAttributeUI.CanAddAttributeItems()
    RoleAttributeUI.ItemList()
    RoleAttributeUI.CreateOrRefreshItemList()
end
--补充页面关闭方法
function RoleAttributeUI.OnAddBloodOrBlueClose()
    local page = GuidCacheUtil.GetUI("addBloodOrBlueCover")
    if page ~= nil then
        GUI.SetVisible(page, false)
        RoleAttributeUI.ClearSelectInfo()
        CL.UnRegisterMessage(GM.RefreshBag, "RoleAttributeUI", "CreateOrRefreshItemList")
        CL.UnRegisterMessage(GM.RefreshBag, "RoleAttributeUI", "ItemList")
    end
end

--确定补充按钮方法
function RoleAttributeUI.OnSureAddBtnClick(key, guid)
    local bg = GuidCacheUtil.GetUI("panelBg")
    local addBloodOrBlueCover = GuidCacheUtil.GetUI("addBloodOrBlueCover")
    if RoleAttributeUI.CurSelectItemGUID and RoleAttributeUI.CurSelectItemGUID ~= "0" and tonumber(RoleAttributeUI.CurSelectItemGUID) ~= 0 then
        local hasFull = false
        local curType = GUI.GetData(bg, "CurrentSubType")
        local whatStore = nil
        if curType == "血池" then
            local currentValue = CL.GetIntAttr(RoleAttr.RoleAttrHpPool)
            local maxValue = CL.GetIntAttr(RoleAttr.RoleAttrHpPoolLimit)
            whatStore = "blood"
            --test("currentValue" .. currentValue .. "maxValue" .. maxValue)
            if currentValue >= maxValue then
                hasFull = true
            end
        elseif curType == "魔池" then
            local currentValue = CL.GetIntAttr(RoleAttr.RoleAttrMpPool)
            local maxValue = CL.GetIntAttr(RoleAttr.RoleAttrMpPoolLimit)
            whatStore = "blue"
            --test("currentValue" .. currentValue .. "maxValue" .. maxValue)
            if currentValue >= maxValue then
                hasFull = true
            end
        end
        if hasFull then
            CL.SendNotify(NOTIFY.ShowBBMsg, "储备已满")
            return
            --else
            --    test("储存未满")
        end
        local item = DB.GetOnceItemByKey1(RoleAttributeUI.CurSelectItemId)
        --CDebug.LogError(inspect(item.Info))
        --以下两行代码是从info信息中获取到数字
        local info = item.Info
        local infoNum = info:gsub("%D+", "")
        --test(item.Info)
        RoleAttributeUI.FirstOpenItemScroll = false
        --血池或魔池的使用
        GlobalUtils.UseItem(RoleAttributeUI.CurSelectItemGUID)

        --CL.SendNotify(NOTIFY.ShowBBMsg, "您的血量储备增加了" .. infoNum .. "点")
        --if whatStore~=nil then
        --    test("刷新新的数据")
        --    RoleAttributeUI.SetBloodSliderData(whatStore)
        --end

        --RoleAttributeUI.ItemList(curType)
        --RoleAttributeUI.CreateOrRefreshItemList()
        --CL.SendNotify(NOTIFY.UseItem, RoleAttributeUI.CurSelectItemGUID)
        --CL.RegisterMessage(GM.RefreshBag, "RoleAttributeUI", "CreateOrRefreshItemList")
        --RoleAttributeUI.CreateOrRefreshItemList()
        --test("执行到此处就代表了刷新了页面")
    elseif RoleAttributeUI.CurSelectItemId ~= nil and RoleAttributeUI.CurSelectItemId ~= "0" and tonumber(RoleAttributeUI.CurSelectItemId) ~= 0 then
        RoleAttributeUI.CreateItemTipsWithFastBuy(tonumber(RoleAttributeUI.CurSelectItemId), addBloodOrBlueCover, 0, 100)
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "未选中任何道具")
    end
end
--清空选择的item信息
function RoleAttributeUI.ClearSelectInfo()
    RoleAttributeUI.CurSelectItemId = 0
    RoleAttributeUI.CurSelectItemGUID = "0"
    RoleAttributeUI.CurSelectItemIndex = 0
end

local NoGainList
function RoleAttributeUI.ItemList()

    local bg = GuidCacheUtil.GetUI("panelBg")
    local whatStore = GUI.GetData(bg, "CurrentSubType")
    if whatStore == "血池" then
        whatStore = 25
    elseif whatStore == "魔池" then
        whatStore = 26
    end
    itemList = nil
    itemList = {}

    local count = LD.GetItemCount()
    --test("count"..count)
    for i = 0, count - 1 do
        local itemData = LD.GetItemDataByItemIndex(i)
        if itemData ~= nil then
            local item = DB.GetOnceItemByKey1(itemData.id)
            if item ~= nil then
                --test("item"..item.Id)
                if tonumber(item.Type) == 2 and tonumber(item.Subtype) == whatStore then
                    table.insert(itemList, itemData)
                    --test("itemData.id"..itemData.id)
                end
            end
        end
    end
    --CDebug.LogError(inspect(itemList))
    NoGainList = nil
    NoGainList = {}
    if whatStore == 25 then
        for k, v in pairs(RoleAttributeUI.CanAddBloodItems) do
            table.insert(NoGainList, v)
        end
    elseif whatStore == 26 then
        for k, v in pairs(RoleAttributeUI.CanAddBlueItems) do
            table.insert(NoGainList, v)
        end
    end
    --CDebug.LogError(inspect(NoGainList))
    for i = 1, #itemList do
        for j = 1, #NoGainList do
            if itemList[i].id == NoGainList[j] then
                table.remove(NoGainList, j)
                break
            end
        end
    end

    table.sort(itemList, RoleAttributeUI.SortItemList)
    --CDebug.LogError(inspect(itemList))
end

function RoleAttributeUI.SortItemList(a, b)
    return a.id > b.id
end

function RoleAttributeUI.CreateOrRefreshItemList()
    --test("第三步")
    local itemListCount = #itemList
    --if itemListCount ~= RoleAttributeUI.ItemListRealCount then
    --    RoleAttributeUI.NeedResetItemScrorectPosition = true
    --end
    RoleAttributeUI.ItemListRealCount = 0
    RoleAttributeUI.MaxItemsCount = 0
    RoleAttributeUI.ItemListRealCount = itemListCount
    RoleAttributeUI.MaxItemsCount = itemListCount + #NoGainList

    if RoleAttributeUI.MaxItemsCount < 16 then
        RoleAttributeUI.MaxItemsCount = 16
    end
    --test("MaxItemsCount"..RoleAttributeUI.MaxItemsCount)
    local parent = GuidCacheUtil.GetUI("addBloodOrBlueBg")
    local itemScroll = GUI.GetChild(parent, "itemScroll")

    if itemScroll == nil then
        -- 滚动窗口
        itemScroll = GUI.ScrollRectCreate(parent, "itemScroll", 0, -15, 324, 324, 0, false, Vector2.New(80, 81), UIAroundPivot.Top, UIAnchor.Top, 4)
        GuidCacheUtil.BindName(itemScroll, "itemScroll")
        SetAnchorAndPivot(itemScroll, UIAnchor.Center, UIAroundPivot.Center)
        GUI.ScrollRectSetChildAnchor(itemScroll, UIAnchor.Top)
        GUI.ScrollRectSetChildPivot(itemScroll, UIAroundPivot.Top)
        GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(0, 0))
    end

    if RoleAttributeUI.FirstOpenItemScroll then
        --创建Item项
        --使用ItemIcon进行快速创建
        for i = 1, RoleAttributeUI.MaxItemsCount do
            local item = GUI.GetChild(parent, "item" .. i)
            if item == nil then
                local item = ItemIcon.Create(itemScroll, "item" .. i, 0, 0)
                GUI.RegisterUIEvent(item, UCE.PointerClick, "RoleAttributeUI", "OnItemClick")
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Selected, 1800400280);
                GUI.ItemCtrlSetElementRect(item, eItemIconElement.Selected, 0, 0, 88, 88);
                GUI.SetData(item, "itemId", 0)
                GUI.SetData(item, "itemGUID", 0)
                GUI.SetData(item, "itemIndex", i)
            end
        end
    end

    --先把多余的隐藏
    for i = RoleAttributeUI.MaxItemsCount, GUI.GetChildCount(itemScroll) do
        local itemIcon = GUI.GetChild(itemScroll, "item" .. i)
        if itemIcon ~= nil then
            GUI.SetVisible(itemIcon, false)
            GUI.SetData(itemIcon, "itemId", 0)
            GUI.SetData(itemIcon, "itemGUID", 0)
        end
    end
    --空格子重置
    for i = itemListCount + #NoGainList + 1, RoleAttributeUI.MaxItemsCount do
        local itemIcon = GUI.GetChild(itemScroll, "item" .. i)
        if itemIcon ~= nil then
            GUI.SetVisible(itemIcon, true)
            GUI.SetData(itemIcon, "itemId", 0)
            GUI.SetData(itemIcon, "itemGUID", 0)
            ItemIcon.SetEmpty(itemIcon)
        end
    end
    --ItemIcon绑定数据
    for i = 1, itemListCount do
        local itemIcon = GUI.GetChild(itemScroll, "item" .. i)
        local itemData = itemList[i]
        --test(itemData.amount)
        if itemData == nil then
            --test("Item表没有找到" .. itemData.id)
        else
            ItemIcon.BindItemData(itemIcon, itemData)
            GUI.SetData(itemIcon, "itemId", itemData.id)
            GUI.SetData(itemIcon, "itemGUID", itemData.guid)
        end
    end
    --显示剪影
    for i = 1, #NoGainList do

        local itemIcon = GUI.GetChild(itemScroll, "item" .. i + itemListCount)
        GUI.SetVisible(itemIcon, true)

        local itemId = tonumber(NoGainList[i])
        if item == nil then
            --test("Item表没有找到" .. NoGainList[i])
        else
            ItemIcon.BindItemId(itemIcon, itemId)
            GUI.ItemCtrlSetIconGray(itemIcon, true)
            GUI.SetData(itemIcon, "itemId", itemId)
            GUI.SetData(itemIcon, "itemGUID", 0)
        end
    end
    --test("RoleAttributeUI.CurSelectItemGUID是" .. RoleAttributeUI.CurSelectItemGUID)

    --选择框的设置
    for i = 1, RoleAttributeUI.MaxItemsCount do
        local itemName = "item" .. i
        local itemCtrl = GUI.GetChild(itemScroll, itemName)
        local itemCtrlIndex = GUI.GetData(itemCtrl, "itemIndex")
        local itemCtrlId = GUI.GetData(itemCtrl, "itemId")
        local itemCtrlGUID = GUI.GetData(itemCtrl, "itemGUID")

        if itemCtrlIndex == RoleAttributeUI.CurSelectItemIndex then
            GUI.ItemCtrlSelect(itemCtrl)
            RoleAttributeUI.CurSelectItemId = tonumber(itemCtrlId)
            RoleAttributeUI.CurSelectItemGUID = itemCtrlGUID
            --test("itemCtrlGUID=="..itemCtrlGUID.."---itemCtrlId=="..itemCtrlId)
            if itemCtrlGUID ~= nil and itemCtrlId~=nil and tonumber(itemCtrlId)~=0 then
                if tonumber(itemCtrlGUID) ~= 0 then
                    local itemTips = Tips.CreateByItemId(itemCtrlId, parent, "tips", -383, -82)
                else
                    local itemTips = RoleAttributeUI.CreateItemTipsWithFastBuy(itemCtrlId, parent, 0, 100)
                end
            end
        else
            GUI.ItemCtrlUnSelect(itemCtrl)
        end
    end
end
--物品点击方法
function RoleAttributeUI.OnItemClick(guid)
    RoleAttributeUI.ClearSelectInfo()

    local parent = GuidCacheUtil.GetUI("addBloodOrBlueCover")
    local scroll = GuidCacheUtil.GetUI("itemScroll")
    --local currentSelect = 1
    --test("guid  is"..guid)
    local itemIcon = GUI.GetByGuid(guid)
    local itemId = GUI.GetData(itemIcon, "itemId")
    local itemGUID = GUI.GetData(itemIcon, "itemGUID")
    local itemIndex = GUI.GetData(itemIcon, "itemIndex")
    --test("当前的icon的 id是"..itemId)
    --test("当前的icon的 guid是"..itemGUID)
    --test("当前的icon的 itemIndex是"..itemIndex)
    RoleAttributeUI.CurSelectItemIndex = itemIndex
    --RoleAttributeUI.CurSelectItemId = tonumber(itemId)
    --RoleAttributeUI.CurSelectItemGUID = itemGUID


    --if itemGUID~=nil and tonumber(itemGUID)~=0 then
    --    local itemTips=Tips.CreateByItemId(itemId,parent,"tips",-383,-82)
    --    RoleAttributeUI.CurSelectItemGUID = itemGUID
    --
    --else
    --    RoleAttributeUI.CurSelectItemGUID = "0"
    --    local itemTips=RoleAttributeUI.CreateItemTipsWithFastBuy(itemId,parent,0,100)
    --end
    RoleAttributeUI.FirstOpenItemScroll = false
    RoleAttributeUI.CreateOrRefreshItemList()
end
--物品点击后显示该物品的tips
function RoleAttributeUI.CreateItemTipsWithFastBuy(itemId, parent, x, y, extHeight)
    if x == nil then
        x = 0
    end
    if y == nil then
        y = 0
    end
    if extHeight == nil then
        extHeight = 50
    end
    local itemTips = Tips.CreateByItemId(itemId, parent, "tips", x, y, extHeight)
    GuidCacheUtil.BindName(itemTips, "itemTips")
    GUI.SetData(itemTips, "ItemId", itemId)
    local wayBtn = GUI.ButtonCreate(itemTips, "wayBtn", "1800402110", 0, -10, Transition.ColorTint, "获得途径", 150, 50, false)
    SetAnchorAndPivot(wayBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn, UCE.PointerClick, "RoleAttributeUI", "onClickWayBtn")
    GUI.AddWhiteName(itemTips, GUI.GetGuid(wayBtn))
end

--获得途径按钮点击方法
function RoleAttributeUI.onClickWayBtn()
    local tips = GuidCacheUtil.GetUI("itemTips")
    if tips == nil then
        test("tips is nil")
    end
    if tips then

        Tips.ShowItemGetWay(tips)
    end
end
--从数据源中获取到可以增加玩家属性（血池和蓝池）的item
function RoleAttributeUI.CanAddAttributeItems()
    local allItems = DB.GetItemAllKey1s()
    local allItemsCount = DB.GetItemTotalCount()
    if allItems == nil or allItemsCount < 1 then
        test("获取Item表失败")
        return
    end

    RoleAttributeUI.CanAddBlueItems = nil
    RoleAttributeUI.CanAddBlueItems = { 20501, 20502, 20503 }
    RoleAttributeUI.CanAddBloodItems = nil
    RoleAttributeUI.CanAddBloodItems = { 20401, 20402, 20403 }


    --RoleAttributeUI.CanAddBlueItems = nil
    --RoleAttributeUI.CanAddBlueItems = {}
    --RoleAttributeUI.CanAddBloodItems = nil
    --RoleAttributeUI.CanAddBloodItems = {}
    --
    --for i=0,allItemsCount-1 do
    --    local id =allItems[i]
    --    local item=DB.GetOnceItemByKey1(id)
    --    if item~=nil then
    --        if tonumber(item.Type)==2 and tonumber(item.Subtype)==25 then
    --            if tonumber(item.Id)~=20404 and tonumber(item.Id)~=20405 and tonumber(item.Id)~=20406  then
    --                table.insert(RoleAttributeUI.CanAddBloodItems, item.Id)
    --            end
    --        elseif tonumber(item.Type)==2 and tonumber(item.Subtype)==26 then
    --            if tonumber(item.Id)~=20506 then
    --                table.insert(RoleAttributeUI.CanAddBlueItems, item.Id)
    --            end
    --
    --        end
    --    end
    --end
end

--------------------------------------------补充血池蓝池重构方法End---------------------------------------------------------