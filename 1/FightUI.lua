local FightUI = {
    StuntSkillList = {},
    isInActor = false,
    --延迟刷新的技能
    NeedDelayRefreshRoleSkill = 0,
    NeedDelayRefreshPetSkill = 0,
    -- 玩家是否可以操作
    PlayerCanOperate = true,
}
_G.FightUI = FightUI
local GuidCacheUtil = nil --UILayout.NewGUIDUtilTable()
require "PetItem"

require("jsonUtil")

local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")

local isVoluntarily = false

-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local bagType = item_container_type.item_container_bag
local isPetAction = false
local isInAutoFight = false
local autoDefenseSkillID = 2
local autoAttackSkillID = 1
local petAutoAttackSkillID = 1
local isInFight = false
local isPvpFight = false
local isFriend = false
local CurTurnCount = 0
local cmdType = ""
local target = ""
local parameter = ""
local isFirstTimeEscape = true
local lastUsedRoleSkillId = 1
local lastUsedPetSkillId = 1
local commandTarget = 0   --当前查看战况的角色的ID
local commandList = {}  --用于创建scrolllist
local enemyCommandList = {} -- 敌方指令
local friendCommandList = {} --友方指令
local friendCommandType = 0
local enemyCommandType = 1
local petEscaped = false
local skillIconClickTimer
local CurActionType = ""
local CurSelectSkillId = 0
local PetTotalCount = LogicDefine.PetMaxLimit
local lastSelectPetItemGuid = nil
local petItemGuidToPetGuid = {}
local selectItemGuid = nil -- 当前选中的物品guid
local preSelectItemCtrlGuid = nil

-- button 名字  图片   方法
local ButtonList = {
    { "自动", "autoFightBtn", "1800302070", "OnAutoFightClick" },
    { "防御", "defenseBtn", "1800302060", "OnDefenseClick" },
    --{"法宝" , "amuletBtn"   , "1800302050" , "OnAmuletClick"},
    { "保护", "protectBtn", "1800302040", "OnProtecClick" },
    { "逃跑", "escapeBtn", "1800302020", "OnEscapeClick" },
    { "召唤", "summonBtn", "1800302030", "OnSummonClick" },
    { "捕捉", "catchBtn", "1800302010", "OnCatchClick" },
    { "召回", "recallBtn", "1800202400", "OnRecallClick" },
    { "道具", "propBtn", "1800302080", "OnPropClick" },
    { "攻击", "attackBtn", "1800302090", "OnAttackClick" },
    { "特技", "effectBtn", "1800302100", "OnStuntClick" },
    { "法术", "magicBtn", "1800302110", "OnMagicClick" },
}
local PetButtonList = {
    { "防御", "petDefenseBtn", "1800302060", "OnPetDefenseClick" },
    { "保护", "petProtectBtn", "1800302040", "OnPetProtecClick" },
    { "逃跑", "petEscapeBtn", "1800302020", "OnPetEscapeClick" },
    { "道具", "petPropBtn", "1800302080", "OnPropClick" },
    { "攻击", "petAttackBtn", "1800302090", "OnPetAttackClick" },
    { "法术", "petMagicBtn", "1800302110", "OnPetMagicClick" },
}

local ControlBtnList = {
    { "<color=#ff0000>清除指令</color>", "clearOrder", "OnClearOrderClick" },
    { "<color=#ff0000>清除全部</color>", "clearOrderAll", "OnClearOrderAllClick" },
    { "<color=#ff0000>增加指令</color>", "addOrder", "OnAddOrderClick" },
}

local petInfoList = {
    [1] = { "气血", "PetBlood", RoleAttr.RoleAttrHp },
    [2] = { "物攻", "PetPhyAtk", RoleAttr.RoleAttrPhyAtk },
    [3] = { "法功", "PetMagAtk", RoleAttr.RoleAttrMagAtk },
    [4] = { "物防", "PetPhyDef", RoleAttr.RoleAttrPhyDef },
    [5] = { "法防", "PetMagDef", RoleAttr.RoleAttrMagDef },
    [6] = { "速度", "PetSpeed", RoleAttr.RoleAttrFightSpeed },
}

-- 宠物类型
local petTypeImageID = 1800704040 -- TODO: 获取宠物类型

local itemList = {}

local invisibilityColor = Color.New(0 / 255, 0 / 255, 0 / 255, 0 / 255)
local colorDark = UIDefine.BrownColor
local colorRed = Color.red
local colorLight = Color.New(247 / 255, 232 / 255, 184 / 255, 255 / 255)

local defaultColor = Color.white
local outLineColor = UIDefine.OutLine_BrownColor

local size18 = 18
local size22 = 22
local size24 = 24
local forgotSize = 30

local lastAutoFightState = 2
local skillList = {}
local skillId2SkillData = {}
local guidToSkillId = {}
local petSkillList = {}
local petSkillId2SkillData = {}
local setAutoFightType = "None"
local BuffList = {}

local messageEventList = {
    { "SetIsInActor", GM.FightIsInActor },
    --{ "OnPetListUpdate", GM.PetAttrUpdate },
    --{ "OnPetFightInfoUpdate", GM.PetFightInfoUpdate },
    { "AutoFightStateChange", GM.FightAutoStateChange },
    { "OnClickRole", GM.FightClickRole },
    { "SetPetAction", GM.FightPetOperator },
    --{ "RefreshBuffReport", GM.BuffReportNtf },
    { "OnOperateFinish", GM.FightOperateFinish },
    --{ "OnInstructionEditFinish", GM.InstructionEditFinish }, -- 战斗指令编辑结束
    { "OnPetEscape", GM.FightPetEscape }, -- 宠物逃跑了
    { "OnRoleAutoFightSkillIDChange", GM.FightAutoSkillChange }, -- 自动战斗技能更新
    --{ "OnInFightSkillShow", GM.InFightSkillShow }, -- 技能表演消息
    --{ "OnPlayerCanOperateNotify", GM.PlayerNeedCommand }, -- 是否人物可以操作
    { "InFight", GM.FightStateNtf },
    { "UpdateFightSkill", GM.FightUpdateSkill },
    { "SetTurnCount", GM.FightTurnRefresh },
    { "UpdateFightBuff", GM.FightBuffUpdate },
    { "FightInstructionUpdate", GM.FightInstructionUpdate },
}

local FightActionType = {
    FIGHT_ACTION_NONE = -1,
    FIGHT_ACTION_TYPE_ATTACK = 0, --攻击
    FIGHT_ACTION_TYPE_DEFENSE = 1, --防御
    FIGHT_ACTION_TYPE_ESCAPE = 2, --逃跑
    FIGHT_ACTION_TYPE_SKILL = 3, --技能
    FIGHT_ACTION_TYPE_ITEM = 4, --物品
    FIGHT_ACTION_TYPE_SUMMON = 5, --召唤
    FIGHT_ACTION_TYPE_CATCH = 6, --捕捉
    FIGHT_ACTION_TYPE_PROTECT = 7, --保护
    FIGHT_ACTION_TYPE_FABAO = 8, --法宝
    FIGHT_ACTION_TYPE_AUTO = 9, --自动
    FIGHT_ACTION_TYPE_MAX = 10
}

function FightUI.Main(parameter)
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    FightUI.CreatePanel(parameter)
end

function FightUI.InitData()
    local glo = DB.GetGlobal(1)
    if glo then
        if glo.PetAttack ~= nil then
            petAutoAttackSkillID = glo.PetAttack
        end
        if glo.DefenseId ~= nil then
            autoDefenseSkillID = glo.DefenseId
        end
    end
    local roleconfig = DB.GetRole(CL.GetIntAttr(RoleAttr.RoleAttrRole))
    if roleconfig then
        autoAttackSkillID = roleconfig.GenAttack
    end
    CurTurnCount = 0
end

function FightUI.CreatePanel(parameter)
    isInAutoFight = CL.OnGetAutoFightState()
    local panel = GUI.WndCreateWnd("FightUI", "FightUI", 0, 0, eCanvasGroup.Main)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.CreateSafeArea(panel)
    FightUI.SetAutoFightSkillCoverVisible(false)

    local name = "scaleBg"
    local scaleBg = GUI.ImageCreate(panel, name, "1800499999", 0, 0, false, 66, 68)
    GuidCacheUtil.BindName(scaleBg, name)
    SetAnchorAndPivot(scaleBg, UIAnchor.BottomRight, UIAroundPivot.Center)
    GUI.SetPositionX(scaleBg, -55)
    GUI.SetPositionY(scaleBg, -65)
    GUI.SetColor(scaleBg, invisibilityColor)

    local scacleBtn = GUI.ButtonCreate(panel, "scacleBtn", "1800302190", 0, 0, Transition.Animation, "", 90, 90, false)
    SetAnchorAndPivot(scacleBtn, UIAnchor.BottomRight, UIAroundPivot.Center)
    GUI.SetPositionX(scacleBtn, -55)
    GUI.SetPositionY(scacleBtn, -65)
    GUI.SetVisible(scacleBtn, false)
    GUI.RegisterUIEvent(scacleBtn, UCE.PointerClick, "FightUI", "OnBackToControl")

    local scacleBtnSp = GUI.ImageCreate(scacleBtn, "scacleBtnSp", "1800302200", 0, 0, false, 90, 90)
    SetAnchorAndPivot(scacleBtnSp, UIAnchor.Center, UIAroundPivot.Center)

    -- 人物相关的按钮
    local rightBg = GUI.ImageCreate(scaleBg, "rightBg", "1800202040", 0, 0, false, 66, 68)
    SetAnchorAndPivot(rightBg, UIAnchor.Center, UIAroundPivot.Center)
    --local intervalX = GUI.GetWidth(rightBg)
    local intervalY = GUI.GetHeight(rightBg)
    GUI.SetColor(rightBg, invisibilityColor)

    local autoFightBtnBg = GUI.ImageCreate(scaleBg, "autoFightBtnBg", "1800302190", 0, 0, false, 90, 90)
    SetAnchorAndPivot(autoFightBtnBg, UIAnchor.Center, UIAroundPivot.Center)

    local autoFightBtn = GUI.ImageCreate(autoFightBtnBg, ButtonList[1][2], ButtonList[1][3], 0, 0, false, 86, 86)
    GUI.SetIsRaycastTarget(autoFightBtn, true)
    autoFightBtn:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(autoFightBtn, UCE.PointerClick, "FightUI", ButtonList[1][4])
    GUI.SetEventCD(autoFightBtn, UCE.PointerClick, 1)

    local tempOutLineColor = Color.New(136 / 255, 66 / 255, 4 / 255, 255 / 255)
    local textColor = Color.New(240 / 255, 230 / 255, 220 / 255, 255 / 255)

    local leftIndex = 7
    for i = 2, #ButtonList do
        local x, y = 0, 0
        if i <= leftIndex then
            x = 102 * (1 - i)
        else
            y = -((intervalY + 36) * (i - leftIndex))
        end
        local subBg = GUI.ImageCreate(rightBg, ButtonList[i][2] .. "Bg", "1800302190", x, y, false, 90, 90)
        SetAnchorAndPivot(subBg, UIAnchor.Center, UIAroundPivot.Center)
        local subBtn = GUI.ButtonCreate(subBg, ButtonList[i][2], ButtonList[i][3], 0, 0, Transition.Animation, "", 86, 86, false)
        FightUI.SetButtonBasicInfo(subBtn, ButtonList[i][4])
        subBtn:RegisterEvent(UCE.PointerUp)
        subBtn:RegisterEvent(UCE.PointerDown)
        GUI.RegisterUIEvent(subBtn, UCE.PointerDown, "FightUI", "BtnPointDown")
        GUI.RegisterUIEvent(subBtn, UCE.PointerUp, "FightUI", "BtnPointUp")
        if i == leftIndex then
            local petActionTxt = GUI.CreateStatic(subBg, "petActionTxt", ButtonList[i][1], 0, 35, 150, 35, "system", true)
            GuidCacheUtil.BindName(petActionTxt, "petActionTxt")
            FightUI.SetTextBasicInfo(petActionTxt, textColor, TextAnchor.MiddleCenter, 26)
            GUI.SetIsOutLine(petActionTxt, true)
            GUI.SetOutLine_Color(petActionTxt, tempOutLineColor)
            GUI.SetOutLine_Distance(petActionTxt, 2)
        end
    end

    local lastUsedSkillBg = GUI.ImageCreate(rightBg, "lastUsedSkillBg", "1800302190", 0, -510, false, 90, 90)
    SetAnchorAndPivot(lastUsedSkillBg, UIAnchor.Center, UIAroundPivot.Center)
    GuidCacheUtil.BindName(lastUsedSkillBg, "lastUsedSkillBg")

    local lastUsedSkillIcon = GUI.ImageCreate(lastUsedSkillBg, "lastUsedSkillIcon", "1900801010", 0, 0, false, 80, 80)
    SetAnchorAndPivot(lastUsedSkillIcon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(lastUsedSkillIcon, true)
    lastUsedSkillIcon:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(lastUsedSkillIcon, UCE.PointerClick, "FightUI", "RoleLastUsedSkillIcon")

    local forgotTxt = GUI.CreateStatic(lastUsedSkillBg, "forgotTxt", "遗忘", 0, 0, 100, 35, "system", true)
    FightUI.SetTextBasicInfo(forgotTxt, colorRed, TextAnchor.MiddleCenter, forgotSize)
    GUI.SetVisible(lastUsedSkillBg, false)

    -- 宠物的一些按钮
    local petRightBg = GUI.ImageCreate(scaleBg, "petRightBg", "1800202040", 0, 0)
    SetAnchorAndPivot(petRightBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(petRightBg, invisibilityColor)
    for i = 1, #PetButtonList do
        local x, y = 0, 0
        if i < 4 then
            x = -102 * i
        else
            y = -102 * (i - 3)
        end
        local subBg = GUI.ImageCreate(petRightBg, PetButtonList[i][2] .. "Bg", "1800302190", x, y, false, 90, 90)
        SetAnchorAndPivot(subBg, UIAnchor.Center, UIAroundPivot.Center)
        local subBtn = GUI.ButtonCreate(subBg, PetButtonList[i][2], PetButtonList[i][3], 0, 0, Transition.Animation, "", 0, 0, true)
        FightUI.SetButtonBasicInfo(subBtn, PetButtonList[i][4])
        subBtn:RegisterEvent(UCE.PointerUp)
        subBtn:RegisterEvent(UCE.PointerDown)
        GUI.RegisterUIEvent(subBtn, UCE.PointerDown, "FightUI", "BtnPointDown")
        GUI.RegisterUIEvent(subBtn, UCE.PointerUp, "FightUI", "BtnPointUp")
    end
    local petLastUsedSkillBg = GUI.ImageCreate(petRightBg, "petLastUsedSkillBg", "1800302190", 0, -408, false, 90, 90)
    SetAnchorAndPivot(petLastUsedSkillBg, UIAnchor.Center, UIAroundPivot.Center)
    GuidCacheUtil.BindName(petLastUsedSkillBg, "petLastUsedSkillBg")

    local petLastUsedSkillIcon = GUI.ImageCreate(petLastUsedSkillBg, "petLastUsedSkillIcon", "1900801013", 0, 0, false, 80, 80)
    SetAnchorAndPivot(petLastUsedSkillIcon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(petLastUsedSkillIcon, true)
    petLastUsedSkillIcon:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(petLastUsedSkillIcon, UCE.PointerClick, "FightUI", "PetLastUsedSkillIcon")
    local forgotTxt = GUI.CreateStatic(petLastUsedSkillBg, "forgotTxt", "遗忘", 0, 0, 100, 35, "system", true)
    FightUI.SetTextBasicInfo(forgotTxt, colorRed, TextAnchor.MiddleCenter, forgotSize)
    --GUI.SetVisible(petLastUsedSkillBg, false)
    GUI.SetVisible(petRightBg, false)
    --自动战斗的几个按钮
    local autoFightBg = GUI.ImageCreate(autoFightBtn, "autoFightBg", "1800202040", 0, 0)
    GUI.SetColor(autoFightBg, invisibilityColor)
    GuidCacheUtil.BindName(autoFightBg, "autoFightBg")

    local roleActionBtnBg = GUI.ImageCreate(autoFightBg, "roleActionBtnBg", "1800302190", -224, 0, false, 90, 90)
    GuidCacheUtil.BindName(roleActionBtnBg, "roleActionBtnBg")
    local roleActionBtn = GUI.ImageCreate(roleActionBtnBg, "roleActionBtn", "1800302250", 0, 0, false, 76, 76)
    GuidCacheUtil.BindName(roleActionBtn, "roleActionBtn")
    GUI.SetIsRaycastTarget(roleActionBtn, true)
    roleActionBtn:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(roleActionBtn, UCE.PointerClick, "FightUI", "OnRoleActionClick")

    local roleActionBtnTipSp = GUI.ImageCreate(roleActionBtnBg, "roleActionBtnTipSp", "1800307060", -15, 15)
    SetAnchorAndPivot(roleActionBtnTipSp, UIAnchor.TopRight, UIAroundPivot.Center)
    local roleActionTxt = GUI.CreateStatic(roleActionBtnBg, "roleActionTxt", "攻击", 0, 35, 150, 35, "system", true)
    GuidCacheUtil.BindName(roleActionTxt, "roleActionTxt")
    FightUI.SetTextBasicInfo(roleActionTxt, textColor, TextAnchor.MiddleCenter, 26)
    GUI.SetIsOutLine(roleActionTxt, true)
    GUI.SetOutLine_Color(roleActionTxt, tempOutLineColor)
    GUI.SetOutLine_Distance(roleActionTxt, 2)
    local forgotTxt = GUI.CreateStatic(roleActionBtn, "forgotTxt", "遗忘", 0, 0, 100, 35, "system", true)
    FightUI.SetTextBasicInfo(forgotTxt, colorRed, TextAnchor.MiddleCenter, forgotSize)
    GUI.SetVisible(forgotTxt, false)

    local petActionBtnBg = GUI.ImageCreate(autoFightBg, "petActionBtnBg", "1800302190", -110, 0, false, 90, 90)
    local petActionBtn = GUI.ImageCreate(petActionBtnBg, "petActionBtn", "1800302250", 0, 0, false, 76, 76)
    GuidCacheUtil.BindName(petActionBtn, "petActionBtn")
    GUI.SetIsRaycastTarget(petActionBtn, true)
    petActionBtn:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(petActionBtn, UCE.PointerClick, "FightUI", "OnPetActionClick")

    local petActionBtnTipSp = GUI.ImageCreate(petActionBtnBg, "petActionBtnTipSp", "1800307050", -15, 15)
    SetAnchorAndPivot(petActionBtnTipSp, UIAnchor.TopRight, UIAroundPivot.Center)
    local petActionTxt = GUI.CreateStatic(petActionBtnBg, "petActionTxt", "攻击", 0, 35, 150, 35, "system", true)
    GuidCacheUtil.BindName(petActionTxt, "petActionTxt")
    FightUI.SetTextBasicInfo(petActionTxt, textColor, TextAnchor.MiddleCenter, 26)
    GUI.SetIsOutLine(petActionTxt, true)
    GUI.SetOutLine_Color(petActionTxt, tempOutLineColor)
    GUI.SetOutLine_Distance(petActionTxt, 2)
    GUI.SetVisible(autoFightBg, false)
    local forgotTxt = GUI.CreateStatic(petActionBtn, "forgotTxt", "遗忘", 0, 0, 100, 35, "system", true)
    FightUI.SetTextBasicInfo(forgotTxt, colorRed, TextAnchor.MiddleCenter, forgotSize)
    GUI.SetVisible(forgotTxt, false)

    local inFightPage = GUI.ImageCreate(scacleBtn, "inFightPage", "1800400290", -200, -40, false, 180, 70)
    local typeTxt = GUI.CreateStatic(inFightPage, "typeTxt", "", 0, -15, 150, 35, "system", true)
    FightUI.SetTextBasicInfo(typeTxt, colorLight, TextAnchor.MiddleCenter, size18)
    local skillTxt = GUI.CreateStatic(inFightPage, "skillTxt", "", 0, 15, 150, 35, "system", true)
    FightUI.SetTextBasicInfo(skillTxt, colorLight, TextAnchor.MiddleCenter, size18)

    -- 一些数据和其他子页的
    FightUI.CreatePropPanel(false)

    --获取一下当前参战的宠物
    FightUI.OnPetFightInfoUpdate()
    FightUI.CreatePetPanel()
    FightUI.PetInfoPanel(scaleBg)
    FightUI.CommandPanel()

    local name = "outViewBtn"
    local outViewBtn = GUI.ButtonCreate(panel, name, "1800302230", 0, 0, Transition.Animation, "", 0, 0, true)
    GuidCacheUtil.BindName(outViewBtn, name)
    SetAnchorAndPivot(outViewBtn, UIAnchor.BottomRight, UIAroundPivot.Center)
    GUI.SetPositionX(outViewBtn, -55)
    GUI.SetPositionY(outViewBtn, -65)
    GUI.RegisterUIEvent(outViewBtn, UCE.PointerClick, "FightUI", "OnOutViewBtn")

    FightUI.AutoFightStateChange()
    FightUI.InItAutoFightActionIcon()
end

function FightUI.OnShow(parameter)
    FightUI.InitData()
    CL.UnRegisterMessage(GM.SkillTipsNtf, "FightUI", "OnSkillTipNtf")
    CL.RegisterMessage(GM.SkillTipsNtf, "FightUI", "OnSkillTipNtf")

    local inFightState = true -- CL.GetFightState() --- 获取战斗状态
    --if inFightState then
    FightUI.InFight(inFightState, isPvpFight)
    -- end
    FightUI.NeedDelayRefreshRoleSkill = 0
    FightUI.NeedDelayRefreshPetSkill = 0

    --创建或刷新新增自动施法功能按钮
    FightUI.CreateOrRefreshAutomaticTypeBtn()

    --刷新判断技能是否更改
    FightUI.RefreshAutoFightSkill()

end

--刷新判断技能是否更改
function FightUI.RefreshAutoFightSkill()


    local roleAction = CL.OnGetAutoFightSkill(false)

    local skillList = LD.GetSelfSkillList()

    local roleDB1 = DB.GetOnceSkillByKey1(roleAction)

    if skillList then
        for i = 0, skillList.Count - 1 do
            local skillData = skillList[i]
            if skillData.enable == 1 then
                local skillId = skillData.id
                local skillDB = DB.GetOnceSkillByKey1(skillId)
                if skillDB.Type == 1 then --普通技能才显示
                    local skillSubType = skillDB.SubType
                    if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then
                        if roleAction ~= nil then

                            if tonumber(roleAction) ~= 0 then

                                local roleDB2 = DB.GetOnceSkillByKey1(skillId)

                                if roleDB1.Name == roleDB2.Name then

                                    CL.OnSetAutoFightSkill(tonumber(skillId), false)

                                end

                            end


                        end


                    end
                end
            end
        end
    end


    local petAction = CL.OnGetAutoFightSkill(true)

    local petGuid = tostring(GlobalUtils.GetMainLineUpPetGuid())

    local nowPetSkillList = GlobalProcessing.GetPetSkillByGuid(petGuid)

    local petDB1 = DB.GetOnceSkillByKey1(petAction)

    if nowPetSkillList then
        for i = 1, #nowPetSkillList do
            local skillData = nowPetSkillList[i]
            if skillData.enable == 1 then
                local skillId = skillData.id
                local skillDB = DB.GetOnceSkillByKey1(skillId)
                if skillDB.Type == 1 then --普通技能才显示
                    local skillSubType = skillDB.SubType
                    if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then

                        if petAction ~= nil then

                            if tonumber(petAction) ~= 0 then

                                local petDB2 = DB.GetOnceSkillByKey1(skillId)

                                if petDB1.Name == petDB2.Name then

                                    CL.OnSetAutoFightSkill(tonumber(skillId), true)

                                end

                            end


                        end



                    end
                end
            end
        end


    end


end

--创建或刷新新增自动施法功能按钮
function FightUI.CreateOrRefreshAutomaticTypeBtn()

    -- 获取角色等级
    local curLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    if GlobalProcessing.AutomaticCasting_OpenLevel and curLevel >= GlobalProcessing.AutomaticCasting_OpenLevel  then

        if UIDefine.FunctionSwitch["AutomaticCasting"] and UIDefine.FunctionSwitch["AutomaticCasting"] == "on" then

            ----------------------------------------------------------自动切换技能图标----------------------------------

            local autoFightBg = GuidCacheUtil.GetUI("autoFightBg")

            local automaticCastingBg = GUI.GetChild(autoFightBg,"automaticCastingBg",false)

            if automaticCastingBg == nil then

                automaticCastingBg = GUI.ImageCreate(autoFightBg, "automaticCastingBg", "1800302190", -31, -75, false, 90, 90)
                SetAnchorAndPivot(automaticCastingBg, UIAnchor.TopRight, UIAroundPivot.Center)

                local AutomaticCastingBtn = GUI.ButtonCreate(automaticCastingBg, "AutomaticCastingBtn", "1801720060", 0, 0, Transition.Animation, "", 101, 105, false)
                GuidCacheUtil.BindName(AutomaticCastingBtn, "AutomaticCastingBtn")
                local sc = 0.9
                GUI.SetScale(AutomaticCastingBtn, Vector3.New(sc, sc, sc))
                SetAnchorAndPivot(AutomaticCastingBtn, UIAnchor.Center, UIAroundPivot.Center)

                AutomaticCastingBtn:RegisterEvent(UCE.PointerUp)
                AutomaticCastingBtn:RegisterEvent(UCE.PointerDown)
                GUI.RegisterUIEvent(AutomaticCastingBtn, UCE.PointerDown, "FightUI", "AutomaticCastingBtnDown")
                GUI.RegisterUIEvent(AutomaticCastingBtn, UCE.PointerUp, "FightUI", "AutomaticCastingBtnUp")
                GUI.RegisterUIEvent(AutomaticCastingBtn, UCE.PointerClick, "FightUI", "OnAutomaticCastingBtnClick")

                local tempOutLineColor = Color.New(136 / 255, 66 / 255, 4 / 255, 255 / 255)
                local textColor = Color.New(240 / 255, 230 / 255, 220 / 255, 255 / 255)

                local AutomaticCastingTxt = GUI.CreateStatic(automaticCastingBg, "AutomaticCastingTxt", "自动施法", 0, 40, 150, 35, "system", true)
                FightUI.SetTextBasicInfo(AutomaticCastingTxt, textColor, TextAnchor.MiddleCenter, 23)
                GUI.SetIsOutLine(AutomaticCastingTxt, true)
                GUI.SetOutLine_Color(AutomaticCastingTxt, tempOutLineColor)
                GUI.SetOutLine_Distance(AutomaticCastingTxt, 2)

                ----------------------------------------------------------自动切换技能图标----------------------------------

            else

                local panel = GUI.GetWnd("FightUI")

                local carTypeGroupCover = GUI.GetChild(panel,"carTypeGroupCover",false)

                if carTypeGroupCover ~= nil then


                    GUI.SetVisible(carTypeGroupCover,false)

                end

            end

            --刷新自动挂机施放技能的技能id
            GlobalProcessing.RefreshAutomaticCastingData()


        end

    end

end


function FightUI.OnClose()
    CL.UnRegisterMessage(GM.SkillTipsNtf, "FightUI", "OnSkillTipNtf")
    test("FightUI.OnClose()")
end

function FightUI.InFight(infight, is_pvp, fightResult)
    fightResult = fightResult or 1
    local wnd = GUI.GetWnd("FightUI")
    if wnd == nil then
        return
    end
    if type(infight) ~= "boolean" then
        return
    end
    isPvpFight = is_pvp
    FightUI.SetInFightState(infight)
    skillId2SkillData = {}
    petSkillId2SkillData = {}

    -- 判断是否处于观战中
    if infight and CL.GetFightViewState() then
        --观战的时候，只开一个观战按钮
        FightUI.InViewState(true)
        return
    end
    FightUI.InViewState(false)
    FightUI.SetCommandPanelBgVisible(true)
    if infight then
        GUI.SetVisible(wnd, true)
    else
        FightUI.ResetAutoActionBtn()
        local petPanel = GuidCacheUtil.GetUI("petBg")
        if petPanel then
            GUI.SetVisible(petPanel, false)
        end
        FightUI.isInActor = false
        GUI.CloseWnd("FightUI")
    end

    if not infight and (fightResult == 1 or fightResult == 3) then
        -- 战斗结束，并且战斗失败，打开战斗欧失败界面
        local value = CL.GetIntCustomData("ACTIVITY_FAILESHEILD")
        if value ~= 1 then
            GUI.OpenWnd("FightResultUI")
        end
    end
end

function FightUI.InViewState(isView)
    -- 是否是观战状态
    local outViewBtn = GuidCacheUtil.GetUI("outViewBtn")
    local scaleBg = GuidCacheUtil.GetUI("scaleBg")
    if isView then
        local wnd = GUI.GetWnd("FightUI")
        if wnd ~= nil then
            GUI.SetVisible(wnd, true)
        end
        GUI.SetVisible(outViewBtn, true)
        GUI.SetVisible(scaleBg, false)
    else
        GUI.SetVisible(outViewBtn, false)
        GUI.SetVisible(scaleBg, true)
    end
end

--- 战斗中技能变化刷新
function FightUI.UpdateFightSkill(ispet, skillId, cd, isforgot)
    if skillId then
        local dic = ispet and petSkillId2SkillData or skillId2SkillData
        if dic then
            local temp = dic[skillId]
            if temp then
                if cd and cd >= 0 then
                    temp.bountCD = cd
                end
                if isforgot ~= nil then
                    temp.IsForgot = isforgot
                end
                FightUI.InItAutoFightActionIcon() -- 刷新一下自动战斗的CD
            end
        end
        -- 刷新一下自动战斗的技能面板
        if lastAutoFightState == 0 then
            FightUI.CreateAutoSkillListScroll(true, lastAutoFightState)
        elseif lastAutoFightState == 1 then
            FightUI.CreateAutoSkillListScroll(false, lastAutoFightState)
        end
    end
end

function FightUI.SetTurnCount(count)
    local refreshBuff = CurTurnCount ~= count -- 防止发两遍回合数
    CurTurnCount = count

    --设置自动战斗技能
    FightUI.SetAutomaticFightSkill()

    FightUI.RefreshSkillTriggerDelay(petSkillId2SkillData)
    FightUI.RefreshSkillTriggerDelay(skillId2SkillData)
    if refreshBuff then
        if BuffList and #BuffList > 0 then
            for i = 1, #BuffList do
                local temp = BuffList[i]
                temp.remain = temp.remain - 1
            end
        end
        FightUI.CreateBuffScroll(commandTarget)
    end
end

--设置自动战斗技能
function FightUI.SetAutomaticFightSkill()
    test("-------------------设置自动战斗技能---------------------------")

    if isVoluntarily then
        if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= nil then

            if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= 0 then

                if GlobalProcessing.AutomaticCastingData ~= nil then

                    if GlobalProcessing.AutomaticCastingData[GlobalProcessing.AutomaticCasting_CurSchemeIndex] ~= nil then

                        if #GlobalProcessing.AutomaticCastingData[GlobalProcessing.AutomaticCasting_CurSchemeIndex].order > 0 then

                            local tempSkillList = skillList

                            local roleFightTable = GlobalProcessing.AutomaticCastingData[GlobalProcessing.AutomaticCasting_CurSchemeIndex].order

                            local skillOneTable = {}
                            for i = 1, #tempSkillList do
                                local skillData = tempSkillList[i]
                                if skillData.skill then
                                    local skill_1 = skillData.skill
                                    skillOneTable[tostring(skill_1.Id)] = tonumber(skillData.bountCD)
                                end
                            end

                            local skillTable = {}

                            test("roleFightTable",inspect(roleFightTable))

                            for i = 1, #roleFightTable do

                                if roleFightTable[i].status == 1 then

                                    local temp = {
                                        id =  roleFightTable[i].skill_id,
                                        priority = i
                                    }

                                    table.insert(skillTable,temp)

                                end

                            end

                            test("skillOneTable",inspect(skillOneTable))

                            for i = 1, #skillTable do
                                local tableData = skillTable[i]
                                test("tableData.id",tostring(tableData.id))

                                local skillCD = skillOneTable[tostring(tableData.id)]
                                if skillCD ~= nil then

                                    if skillCD <= 0 then
                                        CL.OnSetAutoFightSkill(tonumber(tableData.id), false)
                                    end

                                else

                                    CL.OnSetAutoFightSkill(tonumber(tableData.id), false)

                                end

                            end

                        end



                    end
                end

            end

        end
    end

    if isVoluntarily then

        if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= nil then

            if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= 0 then

                local tempSkillList = petSkillList

                local skillOfPetTable = {}
                for i = 1, #tempSkillList do
                    local skillData = tempSkillList[i]
                    if skillData.skill then
                        local skill_1 = skillData.skill
                        skillOfPetTable[tostring(skill_1.Id)] = tonumber(skillData.bountCD)
                    end
                end

                local skillTable = {}

                local petSkillTable = {}

                local petGuid = tostring(GlobalUtils.GetMainLineUpPetGuid())

                local petSkillStr = LD.GetPetStrCustomAttr("AutomaticCasting_PetSkillOrder", petGuid)

                test("petSkillStr",inspect(petSkillStr))

                if #petSkillStr > 0 then

                    local t = jsonUtil.decode(petSkillStr)

                    petSkillTable = t[GlobalProcessing.AutomaticCasting_CurSchemeIndex]

                end

                test("petSkillTable",inspect(petSkillTable))

                if #petSkillTable > 0 then

                    for i = 1, #petSkillTable do

                        if petSkillTable[i].status == 1 then

                            local temp = {
                                id =  petSkillTable[i].skill_id,
                                priority = i
                            }

                            table.insert(skillTable,temp)

                        end

                    end

                end


                for i = 1, #skillTable do
                    local tableData = skillTable[i]

                    test("tableData.id",tostring(tableData.id))

                    local skillCD = skillOfPetTable[tostring(tableData.id)]

                    if skillCD ~= nil then

                        if skillCD <= 0 then
                            CL.OnSetAutoFightSkill(tonumber(tableData.id), true)

                        end

                    else

                        CL.OnSetAutoFightSkill(tonumber(tableData.id), true)

                    end

                end

            end

        end
    end

end

function FightUI.RefreshSkillTriggerDelay(list)
    for k, v in pairs(list) do
        if v.CheckDelayCD then
            local last = v.skill.TriggerDelay - CurTurnCount
            if last >= 0 then
                v.bountCD = last
            else
                v.CheckDelayCD = nil
            end
        end
    end
end

function FightUI.RegisterMessageEvent(boolRegis)
    if boolRegis then
        for i = 1, #messageEventList do
            CL.UnRegisterMessage(messageEventList[i][2], "FightUI", messageEventList[i][1])
            CL.RegisterMessage(messageEventList[i][2], "FightUI", messageEventList[i][1])
        end
    else
        for i = 1, #messageEventList do
            CL.UnRegisterMessage(messageEventList[i][2], "FightUI", messageEventList[i][1])
        end
    end
end

-- 重启UI 清清除之前的数据，设置自动战斗相关，并根据是否是自动战斗，切换UI
function FightUI.RestartUI()
    FightUI.ResetLastUsedSkillId()
    FightUI.ClearDataEveryTurn()
    FightUI.AutoFightStateChange()
    FightUI.InItAutoFightActionIcon(true)

    FightUI.SetLastUsedSkillIcon(0, true)
    FightUI.SetLastUsedSkillIcon(0, false)
    isFirstTimeEscape = true
    petEscaped = false
    FightUI.ForbidPetActionBtn()
end

-- 重进战斗后，刷一下上次使用的技能，避免外面切换天赋
function FightUI.ResetLastUsedSkillId()
    -- 取最新的技能列表
    FightUI.RefreshSkillList()

    local hasLastSkill = false
    for i = 1, #skillList do
        local skill = skillList[i].skill
        if skill then
            if math.floor(tonumber(skill.Id) / 10) == math.floor(tonumber(lastUsedRoleSkillId) / 10) then
                lastUsedRoleSkillId = skill.Id
                hasLastSkill = true
                break
            end
        end
    end
    if not hasLastSkill then
        lastUsedRoleSkillId = 1
    end
end

-- 是否处于战斗状态
function FightUI.SetInFightState(state)
    isInFight = state
    if isInFight then
        FightUI.RestartUI()
        FightUI.RegisterMessageEvent(true)
    else
        FightUI.RegisterMessageEvent(false)
        skillList = {}
        petSkillList = {}
        lastUsedRoleSkillId = 1
        lastUsedPetSkillId = 1
    end
end

local commandBtnGuid2Idx = {}
function FightUI.RefreshCommandList()
    commandList = nil
    enemyCommandList = LD.GetFightInstruction(false)
    friendCommandList = LD.GetFightInstruction(true)
    if friendCommandList and friendCommandList.Count > 0 then
        friendCommandType = friendCommandList[0].type
    else
        friendCommandType = 0
    end
    if enemyCommandList and enemyCommandList.Count > 0 then
        enemyCommandType = enemyCommandList[0].type
    else
        enemyCommandType = 1
    end
    isFriend = CL.CheckIsFriend(tostring(commandTarget)) -- 判断是否是友方
    if isFriend then
        commandList = friendCommandList
    else
        commandList = enemyCommandList
    end
    FightUI.CreateCommandList()
end

function FightUI.CommandPanel()
    local parent = GUI.GetWnd("FightUI")
    local bg = GUI.ImageCreate(parent, "commandPanelBg", "1800499999", 0, 0, false, GUI.GetWidth(parent), GUI.GetHeight(parent))
    GuidCacheUtil.BindName(bg, "commandPanelBg")
    GUI.SetDepth(bg, -10)
    GUI.SetColor(bg, invisibilityColor)
    GUI.SetIsRaycastTarget(bg, true)
    bg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(bg, UCE.PointerClick, "FightUI", "OnCommandPanellBgClick")

    local baseInfoPage = GUI.ImageCreate(bg, "baseInfoPage", "1800400290", -170, -50, false, 318, 264)
    GuidCacheUtil.BindName(baseInfoPage, "baseInfoPage")
    local fighterName = GUI.CreateStatic(baseInfoPage, "fighterName", "", -40, -95, 200, 30, "system", true, false)
    GuidCacheUtil.BindName(fighterName, "fighterName")
    FightUI.SetTextBasicInfo(fighterName, colorRed, TextAnchor.MiddleLeft, size22)
    local controlBtn = GUI.ButtonCreate(baseInfoPage, "controlBtn", "1800302160", 120, -95, Transition.ColorTint, "", 0, 0, true)
    FightUI.SetButtonBasicInfo(controlBtn, "OnControlBtnClick")
    local cutLine = GUI.ImageCreate(baseInfoPage, "cutLine", "1800600030", 0, -60, false)
    local controlPageBg = GUI.ImageCreate(bg, "controlPageBg", "1800400290", 140, -67, false, 270, 230)
    GuidCacheUtil.BindName(controlPageBg, "controlPageBg")
    GUI.SetVisible(controlPageBg, false)
    GUI.SetVisible(bg, false)
end

function FightUI.CreateCommandList()
    local controlPageBg = GuidCacheUtil.GetUI("controlPageBg") -- GUI.Get("FightUI/commandPanelBg/controlPageBg")
    local preScroll = GUI.GetChild(controlPageBg, "commandScroll")
    if preScroll ~= nil then
        GUI.Destroy(preScroll)
    end
    commandBtnGuid2Idx = {}
    local scrollWnd = GUI.ScrollRectCreate(controlPageBg, "commandScroll", 1, 0, 260, 220, 0, false, Vector2.New(130, 54), UIAroundPivot.Top, UIAnchor.Top, 2)
    GUI.ScrollRectSetChildSpacing(scrollWnd, Vector2.New(0, 0))
    for i = 0, commandList.Count - 1 do
        local data = commandList[i]
        local btnStr = "1800302180"
        if data.content == "集火" then
            btnStr = "1801202020"
        end
        local btn = GUI.ButtonCreate(scrollWnd, "ItemBtn", btnStr, 0, 0, Transition.ColorTint, data.content, 130, 54, false)
        commandBtnGuid2Idx[GUI.GetGuid(btn)] = i
        SetAnchorAndPivot(btn, UIAnchor.Center, UIAroundPivot.Center)
        GUI.ButtonSetTextColor(btn, colorDark)
        GUI.ButtonSetTextFontSize(btn, size22)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "FightUI", "OnCommandBtnClick")
    end
    for i = 1, #ControlBtnList do
        local btn = GUI.ButtonCreate(scrollWnd, "ItemBtn", "1800302180", 0, 0, Transition.ColorTint, ControlBtnList[i][1])
        FightUI.SetButtonBasicInfo(btn, ControlBtnList[i][3])
        GUI.ButtonSetTextFontSize(btn, size22)
    end
end

function FightUI.FightInstructionUpdate(id)
    local controlPageBg = GuidCacheUtil.GetUI("controlPageBg")
    if controlPageBg and GUI.GetVisible(controlPageBg) then
        FightUI.RefreshCommandList()
    end
end

function FightUI.UpdateFightBuff(fighterId)
    if tostring(fighterId) ~= tostring(commandTarget) then
        return
    end
    FightUI.RefreshBuffReport()
end

function FightUI.InitBuffData(role_guid)
    local list = CL.GetFightBuffList(role_guid)
    BuffList = {}
    local count = list.Count - 1
    for i = 0, count do
        local data = list[i]
        local buffDB = DB.GetOnceFight_BuffByKey1(data.buff)
        if buffDB.Id ~= 0 and buffDB.Show == 1 then
            local temp = {
                id = data.buff,
                skill = data.skill,
                stack = data.stack,
                remain = data.remain,
                icon = string.sub(tostring(buffDB.Icon), 1, -2) .. "2",
                name = buffDB.Name,
                info = buffDB.Info,
                is_benefit = buffDB.GlobalGroup ~= 2,
            }
            BuffList[#BuffList + 1] = temp
        end
    end
end

--创建刷新buff列表
function FightUI.CreateBuffScroll(role_guid)
    local roleName = CL.GetRoleName(role_guid)
    if not roleName or roleName == "" then -- 如果名字没有说明战斗表演者已经离场了
        FightUI.SetCommandPanelBgVisible(true)
        return
    end
    local fighterName = GuidCacheUtil.GetUI("fighterName")
    if fighterName then
        GUI.StaticSetText(fighterName, roleName .. "的状态")
        GUI.SetColor(fighterName, CL.CheckIsFriend(role_guid) and UIDefine.GreenColor or UIDefine.RedColor)
    end
    local buffScroll = GuidCacheUtil.GetUI("buffScroll")
    if not buffScroll then
        local baseInfoPage = GuidCacheUtil.GetUI("baseInfoPage")
        local childSize = Vector2.New(330, 100)
        buffScroll = GUI.LoopScrollRectCreate(baseInfoPage, "buffScroll", 0, 35, 300, 170,
                "FightUI", "CreateBuffItem", "FightUI", "RefreshBuffScroll", 0, false,
                childSize, 1, UIAroundPivot.Top, UIAnchor.Top)
        GuidCacheUtil.BindName(buffScroll, "buffScroll")
    end
    GUI.LoopScrollRectSetTotalCount(buffScroll, #BuffList)
    GUI.LoopScrollRectRefreshCells(buffScroll)
end

function FightUI.CreateBuffItem()
    local buffScroll = GuidCacheUtil.GetUI("buffScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(buffScroll)
    local bg = GUI.ImageCreate(buffScroll, "buffItemBg" .. curCount, "1800499999", 0, 0, false, 300, 70);
    GUI.SetColor(bg, invisibilityColor);
    local buffIcon = GUI.ImageCreate(bg, "buffIcon", "1800499999", -115, 0);
    local buffStack = GUI.CreateStatic(buffIcon, "buffStack", "", -15, -15, 30, 30, "system", true, false);
    UILayout.SetSameAnchorAndPivot(buffStack, UILayout.BottomRight)
    FightUI.SetTextBasicInfo(buffStack, defaultColor, TextAnchor.MiddleRight, UIDefine.FontSizeSS);
    local buffNameTxt = GUI.CreateStatic(bg, "buffNameTxt", "", -25, -15, 100, 30, "system", true, false);
    local size20 = UIDefine.FontSizeS
    FightUI.SetTextBasicInfo(buffNameTxt, defaultColor, TextAnchor.MiddleLeft, size20);
    local buffContinueTime = GUI.CreateStatic(bg, "buffContinueTime", "0回合", 100, -15, 80, 30, "system", true, false);
    FightUI.SetTextBasicInfo(buffContinueTime, defaultColor, TextAnchor.MiddleLeft, size20);
    local buffEffect = GUI.CreateStatic(bg, "buffEffect", "", 40, 20, 230, 30, "system", true, false);
    FightUI.SetTextBasicInfo(buffEffect, colorRed, TextAnchor.MiddleLeft, size20);
    return bg
end

function FightUI.RefreshBuffScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    index = index + 1
    local data = BuffList[index]
    local item = GUI.GetByGuid(guid)
    local buffIcon = GUI.GetChild(item, "buffIcon")
    local buffStack = GUI.GetChild(buffIcon, "buffStack")
    local buffNameTxt = GUI.GetChild(item, "buffNameTxt")
    local buffContinueTime = GUI.GetChild(item, "buffContinueTime")
    local buffEffect = GUI.GetChild(item, "buffEffect")
    GUI.ImageSetImageID(buffIcon, data.icon)
    if data.stack > 1 then
        GUI.SetVisible(buffStack, true)
        GUI.StaticSetText(buffStack, data.stack)
    else
        GUI.SetVisible(buffStack, false)
    end
    GUI.StaticSetText(buffNameTxt, data.name)
    GUI.StaticSetText(buffContinueTime, data.remain .. "回合")
    GUI.StaticSetText(buffEffect, data.info)
    GUI.SetColor(buffEffect, data.is_benefit and UIDefine.GreenColor or UIDefine.RedColor)
end

function FightUI.OnControlBtnClick()
    --观战者不显示指挥按钮，只可以看战况
    local inVisit = CL.GetFightViewState() -- 判断是否处于观战中
    if inVisit then
        return
    end

    local controlPageBg = GuidCacheUtil.GetUI("controlPageBg") --GUI.Get("FightUI/commandPanelBg/controlPageBg")
    local controlBtn = GUI.Get("FightUI/commandPanelBg/baseInfoPage/controlBtn")
    if controlPageBg ~= nil then
        local isVisible = GUI.GetVisible(controlPageBg)
        GUI.SetVisible(controlPageBg, not isVisible)
        if isVisible then
            GUI.ButtonSetImageID(controlBtn, "1800302160")
        else
            GUI.ButtonSetImageID(controlBtn, "1800302170")
            -- 创建指令列表
            FightUI.RefreshCommandList()
        end
    end
end

function FightUI.OnCommandPanellBgClick(guid, visible)
    local panel = GuidCacheUtil.GetUI("commandPanelBg")
    if panel then
        if visible then
            GUI.SetVisible(panel, true)
        else
            GUI.SetVisible(panel, false)
            local controlBtn = GUI.GetChildByPath(panel, "baseInfoPage/controlBtn")
            GUI.ButtonSetImageID(controlBtn, "1800302160")
            local controlPageBg = GuidCacheUtil.GetUI("controlPageBg")--GUI.GetChild("controlPageBg")
            GUI.SetVisible(controlPageBg, false)
        end
    end
end

function FightUI.CreatePropPanel(canSee)
    local propBgCover = GuidCacheUtil.GetUI("propBgCover")
    if not propBgCover then
        local wnd = GUI.GetWnd("FightUI")
        propBgCover = GUI.ImageCreate(wnd, "propBgCover", "1800499999", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
        GuidCacheUtil.BindName(propBgCover, "propBgCover")
        SetAnchorAndPivot(propBgCover, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(propBgCover, invisibilityColor)
        GUI.SetIsRaycastTarget(propBgCover, true)
        propBgCover:RegisterEvent(UCE.PointerClick)

        local bg = GUI.ImageCreate(propBgCover, "propBg", "1800600182", 0, -30, false, 520, 550)
        SetAnchorAndPivot(bg, UIAnchor.Center, UIAroundPivot.Center)

        local topBarLeft = GUI.ImageCreate(bg, "topBarLeft", "1800600180", 132, 15, false, 264, 54)
        SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

        local topBarRight = GUI.ImageCreate(bg, "topBarRight", "1800600181", -132, 15, false, 264, 54)
        SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

        local propTitleBg = GUI.ImageCreate(bg, "propTitleBg", "1800600190", 0, 17)
        SetAnchorAndPivot(propTitleBg, UIAnchor.Top, UIAroundPivot.Center)

        local propTitleTxt = GUI.CreateStatic(propTitleBg, "propTitleTxt", "使用道具", 0, 0, 150, 35, "system", true)
        FightUI.SetTextBasicInfo(propTitleTxt, colorDark, TextAnchor.MiddleCenter, size24)
        local propCloseBtn = GUI.ButtonCreate(bg, "propCloseBtn", "1800002050", -20, 10, Transition.ColorTint)
        SetAnchorAndPivot(propCloseBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
        GUI.RegisterUIEvent(propCloseBtn, UCE.PointerClick, "FightUI", "OnPropCloseBtnClick")
        FightUI.InitItemList()
        local scrollBg = GUI.ImageCreate(bg, "scrollBg", "1800300040", 0, -10, false, 420, 410)
        local iconCount = #itemList
        if iconCount < 25 then
            iconCount = 25
        end
        local scroll = GUI.LoopScrollRectCreate(bg, "scroll", 0, -10, 407, 400, "FightUI", "CreatIcon4Pool", "FightUI", "OnRefresh", 5, false, Vector2.New(80, 80), 5, UIAroundPivot.Top, UIAnchor.Top)
        GuidCacheUtil.BindName(scroll, "scroll")
        GUI.LoopScrollRectSetTotalCount(scroll, iconCount)
        GUI.LoopScrollRectInit(scroll)

        local useDrug = GUI.ButtonCreate(bg, "useDrug", "1800302130", 0, 235, Transition.ColorTint, "", 200, 48, false, false)
        FightUI.SetButtonBasicInfo(useDrug, "OnUseDrugClick")
        local useDrugLabel = GUI.CreateStatic(useDrug, "useDrugLabel", "使用道具", 0, 0, 150, 35, "system", true)
        FightUI.SetTextBasicInfo(useDrugLabel, defaultColor, TextAnchor.MiddleCenter, 28)
        GUI.SetIsOutLine(useDrugLabel, true)
        GUI.SetOutLine_Color(useDrugLabel, outLineColor)
        GUI.SetOutLine_Distance(useDrugLabel, 1)
    end
    GUI.SetVisible(propBgCover, canSee)
end

function FightUI.CreatIcon4Pool()
    local scroll = GuidCacheUtil.GetUI("scroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local icon = ItemIcon.Create(scroll, "itemIcon" .. curCount, 0, 0)
    GUI.RegisterUIEvent(icon, UCE.PointerClick, "FightUI", "OnClickItemIcon")
    return icon
end

--代码层刷新事件
function FightUI.OnRefresh(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local icon = GUI.GetByGuid(guid)
    local scroll = GuidCacheUtil.GetUI("scroll")
    if icon ~= nil then
        FightUI.CreateIcon("scroll" .. index, index, scroll, bagType, icon)
    end
end

--创建或刷新icon
function FightUI.CreateIcon(key, i, parent, bagType, fightlogo)
    if not fightlogo then
        fightlogo = ItemIcon.Create(parent, key, 0, 0)
        GUI.RegisterUIEvent(fightlogo, UCE.PointerClick, "FightUI", "OnClickItemIcon")
    end

    local max = #itemList
    if max >= i then
        local temp = itemList[i]
        local itemData = LD.GetItemDataByIndex(temp.index, bagType)
        ItemIcon.BindItemData(fightlogo, itemData)
    else
        ItemIcon.SetEmpty(fightlogo)
    end

    return fightlogo
end

--使用道具界面的物品点击
function FightUI.OnClickItemIcon(guid)
    local itemIcon = GUI.GetByGuid(guid);
    local index = GUI.ItemCtrlGetIndex(itemIcon)

    if index < #itemList then
        GUI.ItemCtrlUnSelect(GUI.GetByGuid(preSelectItemCtrlGuid))
        GUI.ItemCtrlSelect(itemIcon)
        local itemData = LD.GetItemDataByIndex(itemList[index + 1].index, bagType)
        -----------------------------------------2021.6.4  新增东西Start------------------------------------
        local itemCustomAttr_Level = LD.GetItemIntCustomAttrByIndex("itemRandomLevel", itemList[index + 1].index, bagType)
        local tmp_itemCustomData = {}
        tmp_itemCustomData.itemRandomLevel = nil
        tmp_itemCustomData.itemRandomLevel = tonumber(itemCustomAttr_Level)
        -----------------------------------------2021.6.4  新增东西End-------------------------------------
        local bg = GuidCacheUtil.GetUI("propBgCover")
        selectItemGuid = itemData:GetAttr(ItemAttr_Native.Guid)
        preSelectItemCtrlGuid = guid
        Tips.CreateByItemData(itemData, bg, "itemTips", -400, -60, 55, nil, tmp_itemCustomData)
    end
end

function FightUI.SaveSelectDrugDate(boolSave, index, icon)
    local bg = GuidCacheUtil.GetUI("propBgCover")
    if boolSave then
        GUI.SetData(bg, "SelectItemIndex", index)
        GUI.SetData(GUI.GetWnd("FightUI"), "selectIcon", GUI.GetGuid(icon))
    else
        GUI.SetData(bg, "SelectItemIndex", -1)
        local preGuid = GUI.GetData(GUI.GetWnd("FightUI"), "selectIcon")
        if preGuid ~= "" then
            GUI.ItemCtrlUnSelect(GUI.GetByGuid(preGuid))
        end
    end
end

function FightUI.SetButtonBasicInfo(btn, func)
    SetAnchorAndPivot(btn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "FightUI", func)
end

function FightUI.SetTextBasicInfo(txt, color, Anchor, fontSize)
    if txt ~= nil then
        SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(txt, fontSize)
        GUI.SetColor(txt, color)
        GUI.StaticSetAlignment(txt, Anchor)
    end
end

function FightUI.CreatePetPanel(parameter)
    local parent = GuidCacheUtil.GetUI("scaleBg")
    local petBg = GUI.ImageCreate(parent, "petBg", "1800600182", -142, -300, false, 360, 675)
    GuidCacheUtil.BindName(petBg, "petBg")
    SetAnchorAndPivot(petBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(petBg, true)

    local topBarRight = GUI.ImageCreate(petBg, "topBarRight", "1800600181", -91, 15, false, 182, 54)
    SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

    local topBarLeft = GUI.ImageCreate(petBg, "topBarLeft", "1800600180", 91, 15, false, 182, 54)
    SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

    -- 标题
    local petTitleBg = GUI.ImageCreate(petBg, "petTitleBg", "1800600190", 0, 16)
    SetAnchorAndPivot(petTitleBg, UIAnchor.Top, UIAroundPivot.Center)
    local petTitleText = GUI.CreateStatic(petTitleBg, "petTitleText", "召唤宠物", 0, 0, 200, 40, "system", true)
    FightUI.SetTextBasicInfo(petTitleText, colorDark, TextAnchor.MiddleCenter, size24)
    local petCloseBtn = GUI.ButtonCreate(petBg, "petCloseBtn", "1800002050", -20, 0, Transition.ColorTint)
    SetAnchorAndPivot(petCloseBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(petCloseBtn, UCE.PointerClick, "FightUI", "OnPetCloseBtnClick")
    local petScrollBg = GUI.ImageCreate(petBg, "petScrollBg", "1800400200", 0, -10, false, 338, 570)
    SetAnchorAndPivot(petScrollBg, UIAnchor.Center, UIAroundPivot.Center)
    local scrollWnd = GUI.ScrollRectCreate(petScrollBg, "petScroll", 1, 5, 336, 560, 0, false, Vector2.New(330, 100))
    SetAnchorAndPivot(scrollWnd, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildAnchor(scrollWnd, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(scrollWnd, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(scrollWnd, Vector2.New(0, 0))
    FightUI.CreatePetList(scrollWnd)

    local callTimes = GUI.CreateStatic(petBg, "callTimes", "召唤次数召唤次数", 20, 300, 360, 30, "system", true, false);
    GuidCacheUtil.BindName(callTimes, "callTimes")
    SetSameAnchorAndPivot(callTimes, UILayout.Left)
    GUI.StaticSetAlignment(callTimes, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(callTimes, 22);
    GUI.SetVisible(callTimes,false)
    GUI.SetColor(callTimes, UIDefine.Brown4Color);

    local callBtn = GUI.ButtonCreate(petBg, "callBtn", "1800302130", 110, 300, Transition.ColorTint, "", 0, 0, true)
    GuidCacheUtil.BindName(callBtn, "callBtn")
    FightUI.SetButtonBasicInfo(callBtn, "OnSummonPetClick")
    local callLable = GUI.CreateStatic(callBtn, "callLable", "召唤", 0, 0, 100, 40, "system", true)
    GuidCacheUtil.BindName(callLable, "callLable")
    FightUI.SetTextBasicInfo(callLable, colorDark, TextAnchor.MiddleCenter, size24)
    GUI.SetVisible(petBg, false)
end

function FightUI.PetInfoPanel(parent)
    local petInfoBg = GUI.ImageCreate(parent, "petInfoBg", "1800600182", -567, -300, false, 486, 675)
    GuidCacheUtil.BindName(petInfoBg, "petInfoBg")
    SetAnchorAndPivot(petInfoBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(petInfoBg, true)
    petInfoBg:RegisterEvent(UCE.PointerClick)

    local topBarLeft = GUI.ImageCreate(petInfoBg, "topBarLeft", "1800600180", 122, 15, false, 244, 54)
    SetAnchorAndPivot(topBarLeft, UIAnchor.TopLeft, UIAroundPivot.Center)

    local topBarRight = GUI.ImageCreate(petInfoBg, "topBarRight", "1800600181", -122, 15, false, 244, 54)
    SetAnchorAndPivot(topBarRight, UIAnchor.TopRight, UIAroundPivot.Center)

    local petInfoTitleBg = GUI.ImageCreate(petInfoBg, "petInfoTitleBg", "1800600190", 0, 16)
    SetAnchorAndPivot(petInfoTitleBg, UIAnchor.Top, UIAroundPivot.Center)
    local petInfoTitleText = GUI.CreateStatic(petInfoTitleBg, "petInfoTitleText", "宠物详情", 0, 0, 200, 50, "system", true)
    FightUI.SetTextBasicInfo(petInfoTitleText, colorDark, TextAnchor.MiddleCenter, size24)
    local petInfoCloseBtn = GUI.ButtonCreate(petInfoBg, "petInfoCloseBtn", "1800002050", -20, 5, Transition.ColorTint)
    SetAnchorAndPivot(petInfoCloseBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(petInfoCloseBtn, UCE.PointerClick, "FightUI", "OnPetInfoCloseBtnClick")
    local petInfoModelBg = GUI.ImageCreate(petInfoBg, "petInfoModelBg", "1800300100", -80, 220)
    SetAnchorAndPivot(petInfoModelBg, UIAnchor.Top, UIAroundPivot.Center)
    GuidCacheUtil.BindName(petInfoModelBg, "petInfoModelBg")

    --宠物阴影
    local shadow = GUI.ImageCreate(petInfoModelBg, "shadow", "1800400240", 15, 160);
    GuidCacheUtil.BindName(shadow, "shadow")
    GUI.SetVisible(shadow, false)

    ----宠物模型
    local model = GUI.RawImageCreate(petInfoModelBg, false, "model", "", 15, 110, 50, false, 360, 360)
    GuidCacheUtil.BindName(model, "model");
    model:RegisterEvent(UCE.Drag)
    GUI.AddToCamera(model);
    GUI.RawImageSetCameraConfig(model, "(1.65,1.3,2),(-0.04464257,0.9316535,-0.1226545,-0.3390941),True,5,0.01,1.25,1E-05");
    model:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(model, UCE.PointerClick, "FightUI", "OnModelClick")
    local petModel = GUI.RawImageChildCreate(model, true, "petModel", "", 0, 0)
    GuidCacheUtil.BindName(petModel, "petModel");
    GUI.BindPrefabWithChild(model, GUI.GetGuid(petModel))
    GUI.RegisterUIEvent(petModel, ULE.AnimationCallBack, "FightUI", "OnAnimationCallBack")

    -- 类型标签
    local petType = GUI.ImageCreate(petInfoModelBg, "petType", petTypeImageID, 5, -15)
    SetAnchorAndPivot(petType, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetVisible(petType, false)

    -- 锁定标签
    local lock = GUI.ImageCreate(petInfoModelBg, "lock", "1800707020", -14, 90)
    SetAnchorAndPivot(lock, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetVisible(lock, false)

    -- 绑定标签
    local bind = GUI.ImageCreate(petInfoModelBg, "bind", "1800704050", 0, 0)
    SetAnchorAndPivot(bind, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(bind, false)

    for i = 1, #petInfoList do
        local tipLble = GUI.CreateStatic(petInfoBg, petInfoList[i][2] .. "Label", petInfoList[i][1], 90, 45 * i - 290, 100, 30, "system", true)
        FightUI.SetTextBasicInfo(tipLble, colorDark, TextAnchor.MiddleCenter, size24)
        local name = petInfoList[i][2] .. "Txt"
        local tipTxt = GUI.CreateStatic(tipLble, name, 100, 80, 0, 70, 30, "system", true, false)
        FightUI.SetTextBasicInfo(tipTxt, colorDark, TextAnchor.MiddleLeft, size24)
        GuidCacheUtil.BindName(tipTxt, name)
    end

    local petSkillListBg = GUI.ImageCreate(petInfoBg, "petSkillListBg", "1800400200", 0, 180, false, 428, 267)
    SetAnchorAndPivot(petSkillListBg, UIAnchor.Center, UIAroundPivot.Center)

    local chileSize = Vector2.New(90, 90)
    local petSkillListScroll = GUI.ScrollRectCreate(petSkillListBg, "petSkillListScroll", 0, 0, 410, 260, 0, false, chileSize, UIAroundPivot.Top, UIAnchor.Top, 4)
    GUI.ScrollRectSetChildSpacing(petSkillListScroll, Vector2.New(15, 15))
    GuidCacheUtil.BindName(petSkillListScroll, "petSkillListScroll")
    for i = 1, 12 do
        local skillIcon = "1800700020"
        local skillItem = GUI.ImageCreate(petSkillListScroll, "skillItem" .. i, "1800700020", 1, 0)
        -- 技能图标
        local icon = GUI.ButtonCreate(skillItem, "skillItem" .. i, skillIcon, 0, -1, Transition.ColorTint, "")
        SetAnchorAndPivot(icon, UIAnchor.Center, UIAroundPivot.Center)
        GUI.RegisterUIEvent(icon, UCE.PointerClick, "FightUI", "OnPetSkillItemClick")
        local highLightSp = GUI.ImageCreate(icon, "highLightSp", "1800600160", 1, 0, false, 90, 90)
        GUI.SetVisible(highLightSp, false)
    end

    GUI.SetVisible(petInfoBg, false)
end

-- 创建宠物列表
function FightUI.CreatePetList(parent)
    if parent == nil then
        return
    end
    -- 普通槽位数量
    local totalPetCount = PetTotalCount -- TODO:获取宠物槽位数量
    for i = 1, totalPetCount do
        local name = "PetItem" .. i
        local petItem = PetItem.Create(parent, name, 330, 100)
        GuidCacheUtil.BindName(petItem, name)
        GUI.RegisterUIEvent(petItem, UCE.PointerClick, "FightUI", "OnPetItemClick")
        --FightUI.CreatePetItem("PetItem" .. i, parent)
    end
end

-- 显示宠物列表
function FightUI.ShowPetItems()
    local petguids = LD.GetPetGuids()
    local count = petguids and petguids.Count or 0
    local capacity = LD.GetPetCapacity()
    local totalPetCount = PetTotalCount -- TODO:获取宠物槽位数量
    petItemGuidToPetGuid = {}
    for i = 1, totalPetCount do
        local name = "PetItem" .. i
        local petItem = GuidCacheUtil.GetUI(name)
        if i <= capacity then
            local petGuid = i <= count and petguids[i - 1] or uint64.zero
            petItemGuidToPetGuid[GuidCacheUtil.GetGuid(name)] = petGuid
            PetItem.BindPetGuid(petItem, petGuid, pet_container_type.pet_container_panel, CL.GetPetFightState(petGuid) == 0)
            local LineupLabel = GUI.GetChild(petItem,"LineupLabel")
            local isLineup = petGuid ~= uint64.zero and LD.GetFighterAttr(RoleAttr.RoleAttrHpLimit, petGuid) > int64.zero
            GUI.SetVisible(LineupLabel, isLineup)
        else
            PetItem.SetLock(petItem)
        end
    end
end

function FightUI.OnPetListUpdate(needInfopage)
    FightUI.ShowPetItems()
    if needInfopage and lastSelectPetItemGuid then
        local lastPetItem = GUI.GetByGuid(lastSelectPetItemGuid)
        if lastPetItem then
            GUI.CheckBoxExSetCheck(lastPetItem, true)
            FightUI.OnPetItemClick(lastSelectPetItemGuid)
        end
    end

    local callTimes = GuidCacheUtil.GetUI("callTimes")
    local callBtn = GuidCacheUtil.GetUI("callBtn")
    local PetLineup_SummonPetNum    = tonumber(CL.GetIntCustomData("PetLineup_SummonPetNum", 0))
    local PetLineup_SummonPetMax   = tonumber(CL.GetIntCustomData("PetLineup_SummonPetMax", 0))

    if PetLineup_SummonPetMax ~= -1 and PetLineup_SummonPetMax ~= 0 then

        GUI.SetVisible(callTimes,true)

        if PetLineup_SummonPetNum < PetLineup_SummonPetMax then

            GUI.ButtonSetShowDisable(callBtn,true)

        else

            GUI.ButtonSetShowDisable(callBtn,false)

        end

        GUI.StaticSetText(callTimes,"宠物召唤次数："..PetLineup_SummonPetNum.."/"..PetLineup_SummonPetMax)

    else

        GUI.SetVisible(callTimes,false)

    end

end

function FightUI.OnPetItemClick(guid)
    local petItem = GUI.GetByGuid(guid)
    local lastPetItem = GUI.GetByGuid(lastSelectPetItemGuid)
    if lastPetItem then
        GUI.CheckBoxExSetCheck(lastPetItem, false)
    end
    if petItem then
        GUI.CheckBoxExSetCheck(petItem, true)
        lastSelectPetItemGuid = guid
    end

    local petGuid = petItemGuidToPetGuid[guid]
    --local itemType = nil --GUI.GetData(currentToggle, "Type")
    local hasDied = nil --GUI.GetData(currentToggle, "HasDied")
    FightUI.CurSelectPet = petGuid
    FightUI.SetSummonPetBtn(petGuid, hasDied)
    FightUI.SetPetInfo(petGuid, itemType)
end

--设置召唤宠物按钮的文字 ，以及点击后的动作
function FightUI.SetSummonPetBtn(petGuid, hasDied)
    local callLable = GuidCacheUtil.GetUI("callLable")
    if callLable == nil then
        return
    end
    local disable = true
    local currentInFightPetGuid = GlobalUtils.GetMainLineUpPetGuid() --获取当前战斗宠物的GUID
    if tostring(petGuid) ~= "0" and tostring(petGuid) == tostring(currentInFightPetGuid) then
        GUI.StaticSetText(callLable, "召回")
        disable = false
    else
        GUI.StaticSetText(callLable, "召唤")
    end
    local state = petGuid and CL.GetPetFightState(petGuid) or 0
    local callBtn = GuidCacheUtil.GetUI("callBtn")
    if callBtn then
        GUI.ButtonSetShowDisable(callBtn, state == 1 or not disable)
    end
end

function FightUI.OnPetInfoCloseBtnClick()
    local petInfoBg = GuidCacheUtil.GetUI("petInfoBg")
    if petInfoBg ~= nil then
        GUI.SetVisible(petInfoBg, false)
    end
end

-- 刷新宠物技能列表
function FightUI.RefreshPetSkillList(petGuid, ignoreEnable)
    petGuid = petGuid or GlobalUtils.GetMainLineUpPetGuid() --CL.GetCurFightPet()
    petSkillList = {}
    local func = function(petSkills)
        if not petSkills or petSkills.Count == 0 then
            return
        end
        for i = 0, petSkills.Count - 1 do
            local petskillData = petSkills[i]
            local skillId = petskillData.id
            local temp = petSkillId2SkillData[skillId] or {}
            local skill = temp.skill or DB.GetOnceSkillByKey1(skillId)
            local check = true
            if not ignoreEnable then
                check = skill.Type == 1
            else
                local subType = skill.SubType
                check = subType ~= 14 and subType ~= 15
            end
            if petskillData.enable == 1 and check then
                local delay = skill.TriggerDelay > 0
                temp.id = skillId
                temp.performance = petskillData.performance
                temp.skill = skill
                temp.bountCD = temp.bountCD or (delay and skill.TriggerDelay - CurTurnCount) or 0
                temp.timeCD = temp.timeCD or 0
                temp.Level = 1
                temp.CheckDelayCD = delay
                temp.IsForgot = temp.IsForgot or false
                temp.ownerGuid = petGuid
                petSkillList[#petSkillList + 1] = temp
                petSkillId2SkillData[skillId] = temp
            else
                petSkillId2SkillData[skillId] = nil
            end
        end
    end
    local petSkills = LD.GetPetSkills(petGuid)
    func(petSkills)
    petSkills = LD.GetFightAdditionSkillList(petGuid)
    func(petSkills)
end

function FightUI.SetPetInfo(petGuid, itemType)
    local petInfoBg = GuidCacheUtil.GetUI("petInfoBg")
    if petGuid and tostring(petGuid) ~= "0" then
        GUI.SetVisible(petInfoBg, true)
        FightUI.CurSelectPet = petGuid
        local petInfo = LD.GetPetData(petGuid)

        local hasData = true
        if petInfo == nil then
            hasData = false
        end

        local pet = nil
        if hasData then
            pet = DB.GetOncePetByKey1(petInfo:GetIntAttr(RoleAttr.RoleAttrRole))
        end
        if not pet or pet.Id == 0 then
            GUI.SetVisible(petInfoBg, false)
            return
        end
        for i = 1, #petInfoList do
            local txt = GuidCacheUtil.GetUI(petInfoList[i][2] .. "Txt")
            GUI.StaticSetText(txt, petInfo:GetIntAttr(petInfoList[i][3]))
        end

        local petSkillListScroll = GuidCacheUtil.GetUI("petSkillListScroll")
        local petInfoBg = GuidCacheUtil.GetUI("petInfoBg")
        GUI.SetVisible(petInfoBg, GUI.GetVisible(GuidCacheUtil.GetUI("petBg")))
        FightUI.RefreshPetSkillList(petGuid, true)
        local petSkills = petSkillList
        local count = #petSkills
        local total = count + 1;
        if count <= 11 then
            total = 12
        end

        for i = 1, total do
            local skillIcon = "1800700020";
            local skillID = 0;
            local skillLevel = 0;
            local name = "skillItem" .. i
            local skillSp = GUI.GetChild(petSkillListScroll, name)
            local skillBtn = GUI.GetChild(skillSp, name)

            if i <= count then
                local petSkill = petSkills[i]
                if petSkill ~= nil then
                    local skill = petSkill.skill or DB.GetOnceSkillByKey1(petSkill.id)
                    if skill.Id ~= 0 then
                        local tempStr = tostring(skill.Icon)
                        skillIcon = tempStr
                        --skillIcon =  tostring(string.sub(tempStr,1,string.len(tempStr)-1).."3")
                        skillID = petSkill.id;
                        skillLevel = petSkill.performance;
                    end
                end
            end

            if skillBtn ~= nil then
                GUI.ButtonSetImageID(skillBtn, skillIcon)
                local highLightSp = GUI.GetChild(skillBtn, "highLightSp")
                GUI.SetVisible(highLightSp, false)
            else
                local skillItem = GUI.ImageCreate(petSkillListScroll, "skillItem" .. i, "1800700020", 1, 0)
                -- 技能图标
                skillBtn = GUI.ButtonCreate(skillItem, "skillItem" .. i, skillIcon, 0, -1, Transition.ColorTint, "")
                SetAnchorAndPivot(skillBtn, UIAnchor.Center, UIAroundPivot.Center)
                GUI.RegisterUIEvent(skillBtn, UCE.PointerClick, "FightUI", "OnPetSkillItemClick")
                local highLightSp = GUI.CreateSprite("highLightSp", "1800600160", 1, 0, skillBtn, false, 90, 90)
                GUI.SetVisible(highLightSp, false)
            end
            GUI.SetData(skillBtn, "SkillGuid", skillID)
            GUI.SetData(skillBtn, "Level", skillLevel)
        end

        local petModel = GuidCacheUtil.GetUI("petModel")
        ModelItem.Bind(petModel, tonumber(pet.Model), petInfo:GetIntAttr(RoleAttr.RoleAttrColor1), 0, eRoleMovement.ATTSTAND_W1)

        local petInfoModelBg = GuidCacheUtil.GetUI("petInfoModelBg")
        if petInfoModelBg ~= nil then
            -- 锁定标签
            local lock = GUI.GetChild(petInfoModelBg, "lock")
            if lock ~= nil then
                if hasData then
                    GUI.SetVisible(lock, LD.GetPetState(PetState.Lock, petGuid))
                else
                    GUI.SetVisible(lock, false)
                end
            end

            -- 绑定标签
            local bind = GUI.GetChild(petInfoModelBg, "bind")
            if bind ~= nil then
                if hasData then
                    GUI.SetVisible(bind, LD.GetPetState(PetState.Bind, petGuid))
                else
                    GUI.SetVisible(bind, false)
                end
            end

            -- 类型标签
            local petType = GUI.GetChild(petInfoModelBg, "petType")
            if petType ~= nil then
                if hasData then
                    GUI.SetVisible(petType, true)
                    local img = UIDefine.PetType[pet.Type] --petTypeInfo[pet.Type][2]
                    GUI.SetVisible(petType, true)
                    GUI.ImageSetImageID(petType, img)
                else
                    GUI.SetVisible(petType, false)
                end
            end
        end
    else
        GUI.SetVisible(petInfoBg, false);
    end
end

function FightUI.OnCreateItemFinish(guid, isFinsh)
    local item = GUI.GetByGuid(guid)
    if item ~= nil then
        GUI.SetLocalPosition(GUI.GetChild(item, "petModel"), 0, 0, 0)
    end
end

function FightUI.OnPetSkillItemClick(currentGuid)
    local wnd = GUI.GetWnd("FightUI")
    local lastSelectPetSkillItem = GUI.GetData(wnd, "LastSelectPetSkillItem")
    if lastSelectPetSkillItem ~= nil and lastSelectPetSkillItem ~= "0" then
        local highLightSp = GUI.GetChild(GUI.GetByGuid(lastSelectPetSkillItem), "highLightSp")
        GUI.SetVisible(highLightSp, false)
    end
    local skillBtn = GUI.GetByGuid(currentGuid)
    local skillId = tonumber(GUI.GetData(skillBtn, "SkillGuid"))
    if skillId ~= 0 then
        FightUI.CreateSkillTips(skillId, "PetSkill", currentGuid)
        local currentHighLightSp = GUI.GetChild(skillBtn, "highLightSp")
        GUI.SetVisible(currentHighLightSp, true)
    end
    GUI.SetData(wnd, "LastSelectPetSkillItem", currentGuid)
end

function FightUI.CreateSkillList(isPetSkill)
    local wnd = GUI.GetWnd("FightUI")
    local name = "skillListBgCover"
    local skillListBgCover = GUI.ImageCreate(wnd, name, "1800400290", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    GuidCacheUtil.BindName(skillListBgCover, name)
    SetAnchorAndPivot(skillListBgCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(skillListBgCover, invisibilityColor)
    GUI.SetIsRaycastTarget(skillListBgCover, true)
    skillListBgCover:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(skillListBgCover, UCE.PointerClick, "FightUI", "OnSkillListBgCoverClick")

    local listBg = GUI.ImageCreate(skillListBgCover, "skillListBg", "1800400290", 280, 0, false, 385, 450)
    GuidCacheUtil.BindName(listBg, "skillListBg")
    SetAnchorAndPivot(listBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(listBg, true)
    listBg:RegisterEvent(UCE.PointerClick)
    FightUI.RefreshSkillScroll(isPetSkill)
end

function FightUI.OnSkillListBgCoverClick()
    local skillListBgCover = GuidCacheUtil.GetUI("skillListBgCover")
    GUI.SetVisible(skillListBgCover, false)

    FightUI.InChooseTarget(false)
    FightUI.SetActionType("")
    CL.SetSelectRoleEffect(FightActionType.FIGHT_ACTION_TYPE_ATTACK, 0)
    --CL.SendNotify(NOTIFY.SetCanSelectEffect, FightActionType.FIGHT_ACTION_TYPE_ATTACK, 0)
end

--出战宠物信息变更
function FightUI.OnPetFightInfoUpdate()

end

function FightUI.RefreshSchoolLabel(schoolId, name, listBg, x, y)
    local school = DB.GetSchool(schoolId)
    if not school or school.Id == 0 then
        return
    end
    local text = school.Info .. ":"
    local school1 = GUI.GetChild(listBg, name)
    if not school1 then
        school1 = GUI.CreateStatic(listBg, name, text, x, y, 80, 40, "system", true)
        GUI.SetColor(school1, UIDefine.White3Color)
        GUI.StaticSetFontSize(school1, UIDefine.FontSizeXXL)
    else
        GUI.SetVisible(school1, true)
        GUI.StaticSetText(school1, text)
    end
end

function FightUI.RefreshSkillScroll(isPetSkill)
    local tempSkillList = nil--{}
    local listBg = GuidCacheUtil.GetUI("skillListBg")

    if isPetSkill then
        FightUI.RefreshPetSkillList()
        tempSkillList = petSkillList
    else
        FightUI.RefreshSkillList()
        tempSkillList = skillList
    end

    local roleListScroll = GuidCacheUtil.GetUI("selectSkillListScroll")
    if not roleListScroll then
        local chileSize = Vector2.New(90, 90)
        roleListScroll = GUI.ScrollRectCreate(listBg, "selectSkillListScroll", 0, 0, 340, 400, 0, false, chileSize, UIAroundPivot.Top, UIAnchor.Top, 3)
        GuidCacheUtil.BindName(roleListScroll, "selectSkillListScroll")
    else
        GUI.SetVisible(roleListScroll, true)
    end
    GUI.ScrollRectSetChildSpacing(roleListScroll, Vector2.New(30, 45))

    local childCount = GUI.GetChildCount(roleListScroll)
    local skillCount = #tempSkillList
    guidToSkillId = {}
    local idx = 0
    for i = 1, skillCount do
        local skill = tempSkillList[i].skill
        if skill then
            local item = GUI.GetChildByIndex(roleListScroll, idx)
            if item then
                GUI.SetVisible(item, true)
            end
            FightUI.RefreshSelectSkillItem(item, idx, roleListScroll, tempSkillList[i], skill, 0, 0, 65, 65, 0, "OnRoleListClickUp", "OnRoleListClickDown", "OnRoleListClickExit")
            idx = idx + 1
        end
    end
    for i = idx, childCount - 1 do
        local item = GUI.GetChildByIndex(roleListScroll, i)
        if item then
            GUI.SetVisible(item, false)
        end
    end
    GUI.SetPaddingVertical(roleListScroll, Vector2.New(0, 30))
end

function FightUI.CreateAutoSkillList(isRole)
    FightUI.RefreshSkillList()
    local parent = GuidCacheUtil.GetUI("scaleBg")
    local name = "autoSkillListBg"
    local preScroll = GuidCacheUtil.GetUI(name)
    if preScroll ~= nil then
        return
    end
    local listBg = GUI.ImageCreate(parent, name, "1800400290", -290, -280, false, 385, 450)
    GuidCacheUtil.BindName(listBg, name)
    SetAnchorAndPivot(listBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(listBg, true)
    listBg:RegisterEvent(UCE.PointerClick)
    local bg1 = GUI.ImageCreate(listBg, "commonAttackBg", "1800302190", -120, 60, false, 90, 90)
    SetAnchorAndPivot(bg1, UIAnchor.Top, UIAroundPivot.Center)
    local tempBtn1 = GUI.ButtonCreate(bg1, "commonAttackBtn", "1800302090", 0, 0, Transition.ColorTint, "", 90, 90, false)
    GUI.RegisterUIEvent(tempBtn1, UCE.PointerClick, "FightUI", "OnAutoCommonAttackClick")
    SetAnchorAndPivot(tempBtn1, UIAnchor.Center, UIAroundPivot.Center)
    local bg2 = GUI.ImageCreate(listBg, "autoDefenseBg", "1800302190", 0, 60, false, 90, 90)
    SetAnchorAndPivot(bg2, UIAnchor.Top, UIAroundPivot.Center)
    local tempBtn2 = GUI.ButtonCreate(bg2, "autoDefenseBtn", "1800302060", 0, 0, Transition.ColorTint, "", 90, 90, false)
    GUI.RegisterUIEvent(tempBtn2, UCE.PointerClick, "FightUI", "OnAutoCommonDefenseClick")
    SetAnchorAndPivot(tempBtn2, UIAnchor.Center, UIAroundPivot.Center)
    local cutline = GUI.ImageCreate(listBg, "autoSkillListCutLine", "1800600030", 0, 125, false, 400, 4)
    SetAnchorAndPivot(cutline, UIAnchor.Top, UIAroundPivot.Center)

    GUI.SetVisible(listBg, false)
end

function FightUI.RefreshSelectSkillItem(item, name, parent, data, skill, x, y, w, h, delayRefreshSkill, onClick, onPointDown, onPointExit)
    local forgotTxt
    if not item then
        onClick = onClick or "OnAutoSkillListClickUp"
        onPointDown = onPointDown or "OnAutoSkillListClickDown"
        onPointExit = onPointExit or "OnAutoSkillListExit"
        item = SkillItemUtil.CreateSkillItem(parent, name, x, -y, w, h, "FightUI", onClick, onPointDown, onPointExit)
        forgotTxt = GUI.CreateStatic(item, "forgotTxt", "遗忘", 0, 0, 100, 35, "system", true)
        FightUI.SetTextBasicInfo(forgotTxt, colorRed, TextAnchor.MiddleCenter, forgotSize)
    else
        GUI.SetPositionX(item, x)
        GUI.SetPositionY(item, -y)
    end
    SkillItemUtil.RefreshSkillItemBySkillDB(item, skill)
    guidToSkillId[GUI.GetGuid(item)] = skill.Id

    local showCD = false
    local needGray = false
    if (not isPvpFight and skill.SkillPvp == 1) or (isPvpFight and skill.SkillPvp == 2) then
        needGray = true
    elseif skill.Id == delayRefreshSkill then
        needGray = false
    elseif data.bountCD ~= nil and data.bountCD > 0 then
        needGray = true
        showCD = true
    end

    if data.IsForgot then
        needGray = true
        GUI.SetVisible(forgotTxt, true)
        SkillItemUtil.RefreshSkillCD(item, 0)
    else
        GUI.SetVisible(forgotTxt, false)
        local cdBount = showCD and data.bountCD or 0
        SkillItemUtil.RefreshSkillCD(item, cdBount)
    end
    local IconSp = GUI.GetChild(item, "IconSp")
    GUI.ImageSetGray(IconSp, needGray)
    return item, needGray
end

function FightUI.CreateAutoSkillListScroll(isRole, state)
    FightUI.AutoFightSkillListVisibel(true)
    local listBg = GuidCacheUtil.GetUI("autoSkillListBg")

    local delayRefreshSkill = 0
    local tempSkillList = {}
    if isRole then
        FightUI.RefreshSkillList()
        tempSkillList = skillList
    else
        FightUI.RefreshPetSkillList()
        tempSkillList = petSkillList
        delayRefreshSkill = FightUI.NeedDelayRefreshPetSkill
    end

    lastAutoFightState = state
    GUI.SetVisible(listBg, true)

    local chileSize = Vector2.New(90, 90)
    local roleListScroll = GuidCacheUtil.GetUI("autoSkillListScroll")
    if not roleListScroll then
        roleListScroll = GUI.ScrollRectCreate(listBg, "autoSkillListScroll", 0, 65, 340, 260, 0, false, chileSize, UIAroundPivot.Top, UIAnchor.Top, 3)
        GuidCacheUtil.BindName(roleListScroll, "autoSkillListScroll")
    else
        GUI.SetVisible(roleListScroll, true)
    end
    GUI.ScrollRectSetChildSpacing(roleListScroll, Vector2.New(30, 45))

    local childCount = GUI.GetChildCount(roleListScroll)
    local skillCount = #tempSkillList
    guidToSkillId = {}
    local idx = 0
    for i = 1, skillCount do
        local skill = tempSkillList[i].skill
        if skill and skill.Id ~= 0 then
            local skillSubType = skill.SubType
            if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then
                local item = GUI.GetChildByIndex(roleListScroll, idx)
                if item then
                    GUI.SetVisible(item, true)
                end
                FightUI.RefreshSelectSkillItem(item, idx, roleListScroll, tempSkillList[i], skill, 0, 0, 65, 65, delayRefreshSkill)
                idx = idx + 1
            end
        end
    end
    for i = idx, childCount - 1 do
        local item = GUI.GetChildByIndex(roleListScroll, i)
        if item then
            GUI.SetVisible(item, false)
        end
    end

    GUI.SetPaddingVertical(roleListScroll, Vector2.New(0, 30))
    local lines = math.ceil(#tempSkillList / 3)
    local listBg = GuidCacheUtil.GetUI("autoSkillListBg")

    if lines < 2 then
        GUI.SetHeight(listBg, 300)
        GUI.SetHeight(roleListScroll, 150)
        GUI.SetPositionY(roleListScroll, 65)
    else
        GUI.SetHeight(roleListScroll, 260)
        GUI.SetPositionY(roleListScroll, 65)
        GUI.SetHeight(listBg, 450)
    end
end

function FightUI.RefreshSkillList()
    skillList = {}
    local stuntSkillList = {}
    local func = function(fightSkillList)
        if not fightSkillList or fightSkillList.Count == 0 then
            return
        end
        for i = 0, fightSkillList.Count - 1 do
            local temp = nil
            local data = fightSkillList[i]
            local skillId = data.id
            if data.performance >= 0 then -- performance是等级
                temp = skillId2SkillData[skillId] or {}
                local skill = temp.skill or DB.GetOnceSkillByKey1(skillId)
                if skill.Id > 0 then
                    if skill.Type == 1 then
                        -- 只显示普通技能
                        local delay = skill.TriggerDelay > 0
                        temp.id = skillId
                        temp.performance = data.performance
                        temp.max_performance = data.max_performance
                        temp.skill = skill
                        temp.bountCD = temp.bountCD or (delay and skill.TriggerDelay - CurTurnCount) or 0
                        temp.timeCD = temp.timeCD or 0
                        temp.Level = 1
                        temp.CheckDelayCD = delay
                        temp.IsForgot = temp.IsForgot or false
                        temp.isSpecial = skill.SubType == 7 -- 是否是特技
                        skillId2SkillData[skillId] = temp
                    else
                        temp = nil
                        skillId2SkillData[skillId] = nil
                    end
                else
                    temp = {}
                    skillId2SkillData[skillId] = nil
                end
            else
                temp = {}
                skillId2SkillData[skillId] = nil
            end
            if temp then
                if temp.isSpecial then
                    stuntSkillList[#stuntSkillList + 1] = temp
                else
                    skillList[#skillList + 1] = temp
                end
            end
        end
    end
    func(LD.GetSelfSkillList())
    func(LD.GetFightAdditionSkillList(LD.GetSelfGUID()))
    FightUI.StuntSkillList = stuntSkillList
end

local showTipSkillData = nil
local offsetX = -160
function FightUI.CreateSkillTips(skillId, skillType, whiteNameGuid)
    --显示技能TIP
    local parent = GUI.GetWnd("FightUI")
    local preTips = GUI.GetChild(parent, "tipsCover")
    if preTips ~= nil then
        GUI.Destroy(preTips)
    end
    local tipsCover = GUI.ImageCreate(parent, "tipsCover", "1800400220", 0, 0, false, GUI.GetWidth(parent), GUI.GetHeight(parent))
    GUI.SetDepth(tipsCover, -10)
    GUI.SetColor(tipsCover, invisibilityColor)
    GUI.SetIsRaycastTarget(tipsCover, true)
    tipsCover:RegisterEvent(UCE.PointerClick)
    GUI.SetDepth(tipsCover, 100)
    GUI.RegisterUIEvent(tipsCover, UCE.PointerClick, "FightUI", "OnTipsClosed")
    local isPetSkill = false
    offsetX = -160
    local tempSkillList = skillList
    if skillType == "PetSkill" then
        offsetX = -425
        tempSkillList = petSkillList
        isPetSkill = true
    elseif skillType == "AutoSkill" then
        offsetX = -100
        if setAutoFightType == "Role" then
            tempSkillList = skillList
        else
            tempSkillList = petSkillList
            isPetSkill = true
        end
    elseif skillType == "ManualSkill" then
        if isPetAction then
            tempSkillList = petSkillList
            isPetSkill = true
        else
            tempSkillList = skillList
        end
    elseif skillType == "特技" then
        tempSkillList = FightUI.StuntSkillList
    end

    local skillLevel = 0
    local skill = DB.GetOnceSkillByKey1(skillId)
    skillLevel = GUI.GetData(GUI.GetByGuid(whiteNameGuid), "Level")
    if skillLevel == nil or #skillLevel == 0 then
        skillLevel = 0
    end
    local skillData = nil
    for i = 1, #tempSkillList do
        if tempSkillList[i].id == skillId then
            skillData = tempSkillList[i]
            break
        end
    end

    if skill.Id ~= 0 then
        --Tips.CreateSkillId(skillId, tipsCover, "skillTips", offsetX, 0, 0, 50, skillData.performance)
        showTipSkillData = skillData
        if isPetSkill then
            CL.SendNotify(NOTIFY.SkillTipsReq, skillId, showTipSkillData.ownerGuid or GlobalUtils.GetMainLineUpPetGuid())
        else
            CL.SendNotify(NOTIFY.SkillTipsReq, skillId)
        end
    end
end

function FightUI.OnSkillTipNtf(skillId, tip, blueCost)
    if not isInFight or not showTipSkillData or showTipSkillData.id ~= skillId then
        return
    end
    showTipSkillData.tips = tip
    showTipSkillData.blueCost = blueCost
    local parent = GUI.GetWnd("FightUI")
    local tipsCover = GUI.GetChild(parent, "tipsCover")
    --Tips.CreateSkillTips(showTipSkillData, tipsCover, "skillTips", offsetX, 0, 0, 50)
    Tips.CreateSkillId(skillId, tipsCover, "skillTips", offsetX, 0, 0, 50, showTipSkillData.performance, showTipSkillData.tips)
end

function FightUI.ChooseTarget(actionType)
    local preTips = GUI.Get("FightUI/tipsCover")
    if preTips ~= nil then
        GUI.Destroy(preTips)
    end
    if actionType == "AutoSkill" then
        return
    end
    local cmdType = FightActionType.FIGHT_ACTION_TYPE_ATTACK
    local parameter = 0
    FightUI.InChooseTarget(true)
    local typeLable = GUI.Get("FightUI/scacleBtn/inFightPage/typeTxt")
    local infoLable = GUI.Get("FightUI/scacleBtn/inFightPage/skillTxt")
    local scaleBg = GuidCacheUtil.GetUI("scaleBg")
    local actionType = CurActionType
    if actionType == "法术" then
        local selectSkill = CurSelectSkillId
        if selectSkill ~= 0 then
            --selectSkill = tonumber(selectSkill)
            local skill = DB.GetOnceSkillByKey1(selectSkill)
            if skill ~= nil then
                GUI.StaticSetText(typeLable, "法术    " .. (skill.Name or ""))
                GUI.StaticSetText(infoLable, "选择攻击目标")
                parameter = selectSkill
                cmdType = FightActionType.FIGHT_ACTION_TYPE_SKILL
            end
        end
    elseif actionType == "特技" then
        GUI.StaticSetText(typeLable, "特技")
        local selectSkill = GUI.GetData(scaleBg, "SelectStuntSkillId")
        if selectSkill ~= nil and #selectSkill ~= 0 then
            selectSkill = tonumber(selectSkill)
            local skill = DB.GetOnceSkillByKey1(selectSkill)
            if skill ~= nil then
                GUI.StaticSetText(typeLable, "特技    " .. (skill.Name or ""))
                GUI.StaticSetText(infoLable, "选择攻击目标")
                parameter = tonumber(selectSkill)
                cmdType = FightActionType.FIGHT_ACTION_TYPE_SKILL
            end
        end
    elseif actionType == "攻击" then
        GUI.StaticSetText(typeLable, "攻击")
        GUI.StaticSetText(infoLable, "选择攻击目标")
    elseif actionType == "保护" then
        GUI.StaticSetText(typeLable, "保护")
        GUI.StaticSetText(infoLable, "选择保护目标")
        cmdType = FightActionType.FIGHT_ACTION_TYPE_PROTECT
    elseif actionType == "使用道具" then
        GUI.StaticSetText(typeLable, "道具")
        local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, selectItemGuid)
        local item = DB.GetOnceItemByKey1(itemId)
        if item ~= nil then
            GUI.StaticSetText(typeLable, "道具    " .. item.Name)
            GUI.StaticSetText(infoLable, "选择道具目标")
            parameter = itemId
            cmdType = FightActionType.FIGHT_ACTION_TYPE_ITEM
        end
    elseif actionType == "捕捉" then
        GUI.StaticSetText(typeLable, "捕捉")
        GUI.StaticSetText(infoLable, "选择捕捉目标")
        cmdType = FightActionType.FIGHT_ACTION_TYPE_CATCH
    end

    CL.SetSelectRoleEffect(cmdType, parameter)
end

--防御和攻击，选择后判断是宠物还是角色的，然后执行相应的数据处理
function FightUI.OnAutoCommonAttackClick()
    if setAutoFightType == "Role" then
        CL.OnSetAutoFightSkill(autoAttackSkillID)
        FightUI.ChangeRoleActionBtnImage("1800302250", "攻击", false, 0, 1)
    elseif setAutoFightType == "Pet" then
        CL.OnSetAutoFightSkill(petAutoAttackSkillID, true)
        FightUI.ChangePetActionBtnImage("1800302250", "攻击", false, 0, 1)
    end
    FightUI.AutoFightSkillListVisibel(false)
end

function FightUI.OnAutoCommonDefenseClick()
    if setAutoFightType == "Role" then
        CL.OnSetAutoFightSkill(autoDefenseSkillID)
        FightUI.ChangeRoleActionBtnImage("1800302240", "防御", false, 0, 2)
    elseif setAutoFightType == "Pet" then
        CL.OnSetAutoFightSkill(autoDefenseSkillID, true)
        FightUI.ChangePetActionBtnImage("1800302240", "防御", false, 0, 2)
    end
    FightUI.AutoFightSkillListVisibel(false)
end

function FightUI.ChangeRoleActionBtnImage(imageString, name, needGray, remainCd, skillId, isforgot)
    local roleActionBtn = GuidCacheUtil.GetUI("roleActionBtn")
    local roleActionTxt = GuidCacheUtil.GetUI("roleActionTxt")
    if roleActionBtn ~= nil then
        GUI.SetData(roleActionBtn, "ActionBtnSkillId", skillId)
        GUI.ImageSetImageID(roleActionBtn, imageString)
    end
    if roleActionTxt ~= nil then
        GUI.StaticSetText(roleActionTxt, name)
    end
    local forgotTxt = GUI.GetChild(roleActionBtn, "forgotTxt")
    if isforgot then
        needGray = true
        GUI.SetVisible(forgotTxt, true)
        SkillItemUtil.RefreshSkillCD(roleActionBtn, 0)
    else
        GUI.SetVisible(forgotTxt, false)
        SkillItemUtil.RefreshSkillCD(roleActionBtn, remainCd)
    end
    GUI.ImageSetGray(roleActionBtn, needGray or false)
end

function FightUI.ChangePetActionBtnImage(imageString, name, needGray, remainCd, skillId, isforgot)
    local petActionBtn = GuidCacheUtil.GetUI("petActionBtn")
    local petActionTxt = GuidCacheUtil.GetUI("petActionTxt")

    if petActionBtn ~= nil then
        GUI.SetData(petActionBtn, "ActionBtnSkillId", skillId)
        GUI.ImageSetImageID(petActionBtn, imageString)
        GUI.SetVisible(petActionBtn, true)
    end
    if petActionTxt ~= nil then
        GUI.StaticSetText(petActionTxt, name)
        GUI.SetVisible(petActionTxt, true)
    end
    local forgotTxt = GUI.GetChild(petActionBtn, "forgotTxt")
    if isforgot then
        needGray = true
        GUI.SetVisible(forgotTxt, true)
        SkillItemUtil.RefreshSkillCD(petActionBtn, 0)
    else
        GUI.SetVisible(forgotTxt, false)
        SkillItemUtil.RefreshSkillCD(petActionBtn, remainCd)
    end
    GUI.ImageSetGray(petActionBtn, needGray or false)
end

function FightUI.OnTipsClosed()
    local tipsCover = GUI.Get("FightUI/tipsCover")
    if tipsCover ~= nil then
        GUI.Destroy(tipsCover)
    end
end
FightUI.SkillLongPress = false
FightUI.SkillLongPressGuid = nil

function FightUI.OnRoleListClickDown(btnGuid)
    FightUI.SkillLongPress = false
    FightUI.SkillLongPressGuid = btnGuid

    --local btn = GUI.GetByGuid(btnGuid)
    --local iconSp = GUI.GetChild(btn, "IconSp")
    --if GUI.ImageGetGray(iconSp) == true then
    --    CL.SendNotify(NOTIFY.ShowBBMsg, "技能冷却中，本回合不可使用")
    --end

    local fun = function()
        FightUI.SkillLongPress = true
        FightUI.OnRoleListClick(nil, true, btnGuid, "ManualSkill")
        return nil
    end
    skillIconClickTimer = Timer.New(fun, 0.4)
    skillIconClickTimer:Start()
end

function FightUI.OnRoleListClickExit(btnGuid)
    if FightUI.SkillLongPressGuid and FightUI.SkillLongPressGuid == btnGuid then
        FightUI.SkillLongPressGuid = nil
        FightUI.StopSkillIconClickTimer()
    end
end

function FightUI.OnRoleListClickUp(btnGuid)
    FightUI.StopSkillIconClickTimer()
    if FightUI.SkillLongPress then
    else
        local skillid = guidToSkillId[btnGuid]
        local skill = DB.GetOnceSkillByKey1(skillid)
        if not isPvpFight then
            if skill.SkillPvp == 1 then
                CL.SendNotify(NOTIFY.ShowBBMsg, "该技能只能在PVP中使用")
                return
            end
        else
            if skill.SkillPvp == 2 then
                CL.SendNotify(NOTIFY.ShowBBMsg, "该技能只能在PVE中使用")
                return
            end
        end
        local skillData = skillId2SkillData[skillid] or petSkillId2SkillData[skillid]
        if skillData then
            if not FightUI.CheckSkillState(skillData) then
                return
            end
            FightUI.SetActionType("法术")
            FightUI.OnRoleListClick(key, false, btnGuid, "ManualSkill")
        else
            test("技能ID出错：", skillid)
        end
    end
end

function FightUI.CheckSkillState(skillData)
    if not skillData then
        return false
    end
    if skillData.IsForgot then
        CL.SendNotify(NOTIFY.ShowBBMsg, "技能遗忘中，不可使用")
        return false
    end
    if skillData.bountCD > 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "技能冷却中，本回合不可使用")
        return false
    end
    local skillid = skillData.id
    local skillDB = skillData.skill
    local cost, isper = GlobalUtils.GetSkillCost(skillid, skillData.performance, skillDB)
    if not isper and cost > int64.zero then
        local attrValue = LD.GetFighterAttr(RoleAttr.IntToEnum(skillDB.Cost1), isPetAction and GlobalUtils.GetMainLineUpPetGuid() or uint64.zero)
        if attrValue < cost then
            local attrDB = DB.GetOnceAttrByKey1(skillDB.Cost1)
            CL.SendNotify(NOTIFY.ShowBBMsg, attrDB.ChinaName .. "不足，请谨慎释放")
        end
    end
    return true
end

function FightUI.OnAutoSkillListClickDown(btnGuid)
    FightUI.SkillLongPress = false
    FightUI.SkillLongPressGuid = btnGuid
    local fun = function()
        FightUI.SkillLongPress = true
        FightUI.OnRoleListClick(nil, true, btnGuid, "AutoSkill")
        return nil
    end
    skillIconClickTimer = Timer.New(fun, 0.4)
    skillIconClickTimer:Start()
end

function FightUI.OnAutoSkillListExit(btnGuid)
    if FightUI.SkillLongPressGuid and FightUI.SkillLongPressGuid == btnGuid then
        FightUI.SkillLongPressGuid = nil
        FightUI.StopSkillIconClickTimer()
    end
end

function FightUI.StopSkillIconClickTimer()
    if skillIconClickTimer ~= nil then
        skillIconClickTimer:Stop()
        skillIconClickTimer = nil
    end
end

--自动战斗技能列表的点击事件
function FightUI.OnAutoSkillListClickUp(btnGuid)
    FightUI.StopSkillIconClickTimer()
    local createTips = false
    if FightUI.SkillLongPress then
        createTips = true
    else
        FightUI.OnRoleListClick(nil, false, btnGuid, "AutoSkill")
    end

    if not createTips then
        lastAutoFightState = 2   --这个是记录当前开的是哪一个 AutoSkillList
        local skillId = guidToSkillId[btnGuid]
        local skill = DB.GetOnceSkillByKey1(skillId)
        if skill then
            local tempStr = tostring(skill.Icon)
            local iconStr = string.sub(tempStr, 1, -2) .. "3"
            if setAutoFightType == "Role" then
                CL.OnSetAutoFightSkill(skill.Id)
                FightUI.ChangeRoleActionBtnImage(iconStr, skill.Name, false, 0, tonumber(skill.Id))
                if skill.SubType ~= 12 then
                    lastUsedRoleSkillId = skill.Id
                end
            elseif setAutoFightType == "Pet" then
                CL.OnSetAutoFightSkill(skill.Id, true)
                FightUI.ChangePetActionBtnImage(iconStr, skill.Name, false, 0, tonumber(skill.Id))
                lastUsedPetSkillId = skill.Id
            end
        end
        FightUI.AutoFightSkillListVisibel(false)
    end
end

--这里的id是skillID
function FightUI.OnRoleListClick(id, createTips, currentGuid, skillType)
    local skillId = guidToSkillId[currentGuid] or id or 0
    local panel = GuidCacheUtil.GetUI("scaleBg")
    local lastSelectKey = GUI.GetData(panel, "LastSelectKey")
    if lastSelectKey ~= nil and #lastSelectKey > 0 then
        local btnSelectImage = GUI.GetChild(GUI.GetByGuid(lastSelectKey), "btnSelectImage")
        if btnSelectImage ~= nil then
            GUI.SetVisible(btnSelectImage, false)
        end
    end
    local btnSelectImage = GUI.GetChild(GUI.GetByGuid(currentGuid), "btnSelectImage")
    if btnSelectImage ~= nil then
        GUI.SetVisible(btnSelectImage, true)
    end
    GUI.SetData(panel, "LastSelectKey", currentGuid)
    CurSelectSkillId = skillId
    if createTips then
        FightUI.CreateSkillTips(skillId, skillType, currentGuid)
        return
    end
    FightUI.ChooseTarget(skillType)
end

--自动按钮切换
function FightUI.OnAutoFightClick(guid)
    test("自动按钮切换", isInAutoFight)
    if isInAutoFight then
        CL.OnAutoFightBtnClick(0)
    else
        CL.OnAutoFightBtnClick(1)
    end
end

-- 页签的收起和打开
function FightUI.RightBtnDoTweenScale(bg, doShrink)
    if bg == nil then
        return
    end
    if doShrink then
        GUI.DOTween(bg, "3")
    else
        GUI.DOTween(bg, "2")
    end
end
function FightUI.BtnPointDown(guid)
    local btn = GUI.GetByGuid(guid)
    if btn ~= nil then
        local parent = GUI.GetParentElement(btn)
        local parentGuid = GUI.GetGuid(parent)
        FightUI.BtnDoTweenScale(parentGuid, true)
    end
end

function FightUI.BtnPointUp(guid)
    local btn = GUI.GetByGuid(guid)
    if btn ~= nil then
        local parent = GUI.GetParentElement(btn)
        local parentGuid = GUI.GetGuid(parent)
        FightUI.BtnDoTweenScale(parentGuid, false)
    end
end

function FightUI.BtnDoTweenScale(guid, bo)
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    if bo then
        GUI.DOTween(element, "6")
    else
        GUI.DOTween(element, "7")
    end
end

function FightUI.OnBackToControl(key)
    FightUI.InChooseTarget(false)
    FightUI.SetActionType("")
    FightUI.SaveSelectDrugDate(false)
    CL.SetSelectRoleEffect(FightActionType.FIGHT_ACTION_TYPE_ATTACK, 0)
end

function FightUI.InChooseTarget(isInChoose)
    local scaleBg = GuidCacheUtil.GetUI("scaleBg")
    local scacleBtn = GUI.Get("FightUI/scacleBtn")
    local skillListBgCover = GuidCacheUtil.GetUI("skillListBgCover")
    local stuntSkillListBgCover = GUI.Get("FightUI/stuntSkillListBgCover")

    GUI.SetVisible(scaleBg, not isInChoose)
    GUI.SetVisible(scacleBtn, isInChoose)
    GUI.SetVisible(skillListBgCover, false)
    GUI.SetVisible(stuntSkillListBgCover, false)
end

--防御按钮点击处理
function FightUI.OnDefenseClick(guid)
    test("防御按钮点击处理")
    FightUI.SetActionType("防御")
    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)
    FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_DEFENSE, 0)
    CL.OnSetAutoFightSkill(autoDefenseSkillID)
end

-- 法宝按钮点击处理
function FightUI.OnAmuletClick(guid)
    test("法宝按钮点击处理")
    FightUI.SetActionType("法宝")
    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)
end

-- 保护按钮点击处理
function FightUI.OnProtecClick(guid)
    test("保护按钮点击处理")
    FightUI.SetActionType("保护")
    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)
    FightUI.ChooseTarget()
end

-- 逃跑按钮点击处理
function FightUI.OnEscapeClick(guid)
    test("逃跑按钮点击处理")
    FightUI.SetActionType("逃跑")
    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)
    if isFirstTimeEscape and LD.GetSystemSettingValue(SystemSettingOption.MakeSureEscape) == 1 then
        isFirstTimeEscape = false
        target = ""
        FightUI.SendMessageBox("是否确认逃跑？", FightActionType.FIGHT_ACTION_TYPE_ESCAPE, "")
    else
        FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_ESCAPE, 0)
    end
end

-- 召唤按钮点击处理
function FightUI.OnSummonClick(guid)
    test("召唤按钮点击处理")
    FightUI.SetActionType("召唤")
    FightUI.SetSkillListVisible(true)

    local petPanel = GuidCacheUtil.GetUI("petBg")
    if petPanel == nil then
        FightUI.CreatePetPanel()
        FightUI.OnPetListUpdate(true)
    else
        GUI.SetVisible(petPanel, true)
        FightUI.OnPetListUpdate(true)
    end
    FightUI.SetCommandPanelBgVisible(true)
end

-- 捕捉按钮点击处理
function FightUI.OnCatchClick(guid)
    test("捕捉按钮点击处理")
    FightUI.SetActionType("捕捉")
    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)
    FightUI.ChooseTarget()
end

--召回
function FightUI.OnRecallClick(guid)
    test("召回按钮点击处理")
    local currentInFightPet = tostring(GlobalUtils.GetMainLineUpPetGuid())
    if currentInFightPet == "0" then
        CL.SendNotify(NOTIFY.ShowBBMsg, "当前没有出战宠物无法召回")
        return
    end
    FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_SUMMON, currentInFightPet)
end

-- 道具按钮点击处理
function FightUI.OnPropClick(guid)
    test("道具按钮点击处理")
    selectItemGuid = nil --先清理一下上次使用的道具guid
    local propBgCover = GuidCacheUtil.GetUI("propBgCover")

    FightUI.SetActionType("使用道具")
    FightUI.SetSkillListVisible(true)

    if propBgCover then
        GUI.SetVisible(propBgCover, true)
        local propBg = GUI.GetChild(propBgCover, "propBg")
        GUI.SetVisible(propBg, true)

        if GUI.GetVisible(propBgCover) then
            FightUI.InitItemList()
            local loopScroll = GuidCacheUtil.GetUI("scroll")
            GUI.LoopScrollRectSetTotalCount(loopScroll, #itemList > 25 and #itemList or 25)
            GUI.LoopScrollRectRefreshCells(loopScroll)
            GUI.ScrollRectSetNormalizedPosition(loopScroll, Vector2.New(0, 0))
        end
    else
        FightUI.CreatePropPanel(true)
    end
    FightUI.SetCommandPanelBgVisible(true)
end

-- 攻击按钮点击处理
function FightUI.OnAttackClick(guid)
    test("攻击按钮点击处理")
    FightUI.SetActionType("攻击")
    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)
    FightUI.ChooseTarget()
    CL.OnSetAutoFightSkill(autoAttackSkillID)
end

-- 特技按钮按下处理
function FightUI.OnStuntClick(guid)
    test("特技按钮按下处理")
    FightUI.SetActionType("特技")
    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)

    FightUI.CreateStuntClick()
    FightUI.CreateStuntSkillList()
end

function FightUI.CreateStuntClick()
    local wnd = GUI.GetWnd("FightUI")
    local pre = GUI.GetChild(wnd, "stuntSkillListBgCover")
    if pre ~= nil then
        GUI.SetVisible(pre, true)
        return
    end
    local stuntSkillListBgCover = GUI.ImageCreate(wnd, "stuntSkillListBgCover", "1800400290", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    SetAnchorAndPivot(stuntSkillListBgCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(stuntSkillListBgCover, invisibilityColor)
    GUI.SetIsRaycastTarget(stuntSkillListBgCover, true)
    stuntSkillListBgCover:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(stuntSkillListBgCover, UCE.PointerClick, "FightUI", "OnStuntSkillListBgCoverClick")

    local stuntListBg = GUI.ImageCreate(stuntSkillListBgCover, "stuntSkillListBg", "1800400290", 280, 0, false, 385, 450)
    SetAnchorAndPivot(stuntListBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(stuntListBg, true)
    stuntListBg:RegisterEvent(UCE.PointerClick)
end

function FightUI.OnStuntSkillListBgCoverClick(guid)
    local stuntSkillListBgCover = GUI.Get("FightUI/stuntSkillListBgCover")
    if stuntSkillListBgCover ~= nil then
        GUI.SetVisible(stuntSkillListBgCover, false)
    end

    FightUI.InChooseTarget(false)
    FightUI.SetActionType("")
    CL.SetSelectRoleEffect(FightActionType.FIGHT_ACTION_TYPE_ATTACK, 0)
end

function FightUI.CreateStuntSkillList()
    local listBg = GUI.Get("FightUI/stuntSkillListBgCover/stuntSkillListBg")
    if listBg == nil then
        FightUI.CreateStuntClick()
    end
    listBg = GUI.Get("FightUI/stuntSkillListBgCover/stuntSkillListBg")
    FightUI.RefreshSkillList()
    local tempSkillList = FightUI.StuntSkillList

    local roleListScroll = GUI.GetChild(listBg, "roleListScroll")
    if not roleListScroll then
        local chileSize = Vector2.New(90, 90)
        roleListScroll = GUI.ScrollRectCreate(listBg, "roleListScroll", 0, 0, 340, 400, 0, false, chileSize, UIAroundPivot.Top, UIAnchor.Top, 3)
        GUI.ScrollRectSetChildSpacing(roleListScroll, Vector2.New(30, 45))
    else
        GUI.SetVisible(roleListScroll, true)
    end

    local childCount = GUI.GetChildCount(roleListScroll)
    local skillCount = #tempSkillList
    guidToSkillId = {}
    local idx = 0
    for i = 1, skillCount do
        local skill = tempSkillList[i].skill
        if skill then
            local item = GUI.GetChildByIndex(roleListScroll, idx)
            if item then
                GUI.SetVisible(item, true)
            end
            FightUI.RefreshSelectSkillItem(item, idx, roleListScroll, tempSkillList[i], skill, 0, 0, 65, 65, 0, "OnRoleStuntListClickUp", "OnRoleStuntListClickDown", "OnRoleStuntListExit")
            idx = idx + 1
        end
    end
    for i = idx, childCount - 1 do
        local item = GUI.GetChildByIndex(roleListScroll, i)
        if item then
            GUI.SetVisible(item, false)
        end
    end

    GUI.SetPaddingVertical(roleListScroll, Vector2.New(0, 30))
end

function FightUI.OnRoleStuntListClickDown(btnGuid)
    FightUI.SkillLongPress = false
    FightUI.SkillLongPressGuid = btnGuid
    --local btn = GUI.GetByGuid(btnGuid)
    --local iconSp = GUI.GetChild(btn, "IconSp")
    --if GUI.ImageGetGray(iconSp) == true then
    --    FightUI.CreateSkillTips(key, "ManualSkill", btnGuid)
    --    CL.SendNotify(NOTIFY.ShowBBMsg, "技能冷却中，本回合不可使用")
    --    return
    --end
    FightUI.SkillLongPress = false
    local fun = function()
        FightUI.SkillLongPress = true
        FightUI.OnRoleStuntListClick(key, true, btnGuid, "特技")
        return nil
    end
    skillIconClickTimer = Timer.New(fun, 0.4)
    skillIconClickTimer:Start()
end

function FightUI.OnRoleStuntListClick(id, createTips, currentGuid, skillType)
    id = guidToSkillId[currentGuid] or id or 0
    local panel = GuidCacheUtil.GetUI("scaleBg")
    local lastSelectKey = GUI.GetData(panel, "LastSelectStuntKey")
    if lastSelectKey ~= nil and #lastSelectKey > 0 then
        local btnSelectImage = GUI.GetChild(GUI.GetByGuid(lastSelectKey), "btnSelectImage")
        if btnSelectImage ~= nil then
            GUI.SetVisible(btnSelectImage, false)
        end
    end
    local btnSelectImage = GUI.GetChild(GUI.GetByGuid(currentGuid), "btnSelectImage")
    if btnSelectImage ~= nil then
        GUI.SetVisible(btnSelectImage, true)
    end
    GUI.SetData(panel, "LastSelectStuntKey", currentGuid)
    GUI.SetData(panel, "SelectStuntSkillId", id)
    CurSelectSkillId = id
    if createTips then
        FightUI.CreateSkillTips(id, skillType, currentGuid)
        return
    end

    FightUI.ChooseTarget(skillType)
end

function FightUI.OnRoleStuntListExit(guid)
    if FightUI.SkillLongPressGuid and FightUI.SkillLongPressGuid == guid then
        FightUI.SkillLongPressGuid = nil
        FightUI.StopSkillIconClickTimer()
    end
end

function FightUI.OnRoleStuntListClickUp(guid)
    FightUI.StopSkillIconClickTimer()
    if FightUI.SkillLongPress then
    else
        local id = guidToSkillId[guid] or 0
        local skill = DB.GetOnceSkillByKey1(id)
        if not isPvpFight then
            if skill.SkillPvp == 1 then
                CL.SendNotify(NOTIFY.ShowBBMsg, "该技能只能在PVP中使用")
                return
            end
        else
            if skill.SkillPvp == 2 then
                CL.SendNotify(NOTIFY.ShowBBMsg, "该技能只能在PVE中使用")
                return
            end
        end
        local skillData = skillId2SkillData[id] or petSkillId2SkillData[id]
        if skillData then
            if not FightUI.CheckSkillState(skillData) then
                return
            end
        end
        FightUI.SetActionType("特技")
        FightUI.OnRoleStuntListClick(nil, false, guid, "ManualSkill")
    end
end

-- 法术按钮点击处理
function FightUI.OnMagicClick(guid)
    test("法术按钮点击处理")
    FightUI.SetActionType("法术")
    FightUI.SetSkillListVisible()
    FightUI.SetCommandPanelBgVisible(true)
end

function FightUI.SetSkillListVisible(hide, isPetSkill)
    local scrollBg = GuidCacheUtil.GetUI("skillListBgCover")
    if scrollBg == nil then
        FightUI.CreateSkillList(isPetSkill)
        if hide then
            scrollBg = GuidCacheUtil.GetUI("skillListBgCover")
            GUI.SetVisible(scrollBg, false)
        end
    elseif hide then
        GUI.SetVisible(scrollBg, false)
    else
        FightUI.RefreshSkillScroll(isPetSkill)
        GUI.SetVisible(scrollBg, not GUI.GetVisible(scrollBg))
    end
end

function FightUI.OnPetCloseBtnClick()
    local petPanel = GuidCacheUtil.GetUI("petBg")
    local petInfoPanel = GuidCacheUtil.GetUI("petInfoBg")
    if petPanel ~= nil then
        GUI.SetVisible(petPanel, false)
    end
    if petInfoPanel ~= nil then
        GUI.SetVisible(petInfoPanel, false)
    end
end

--点击召唤按钮的执行，是休息，还是参战
function FightUI.OnSummonPetClick(guid)
    if FightUI.CurSelectPet ~= nil then
        local currentInFightPet = GlobalUtils.GetMainLineUpPetGuid()
        if currentInFightPet ~= FightUI.CurSelectPet then
            local state = CL.GetPetFightState(FightUI.CurSelectPet)
            if state == 0 then
                CL.SendNotify(NOTIFY.ShowBBMsg, "当前宠物无法召唤")
                return
            end
            local value = 20
            local g = DB.GetGlobal(1)
            if g.Id > 0 then
                value = g.PetClosePointsAbsent
            end
            local loyalty = tonumber(tostring(LD.GetPetAttr(RoleAttr.PetAttrLoyalty, FightUI.CurSelectPet)))
            if loyalty < value then
                CL.SendNotify(NOTIFY.ShowBBMsg, "当前宠物忠诚度低于" .. value .. ", 无法召唤")
                return
            end
        end

        FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_SUMMON, tostring(FightUI.CurSelectPet))
        local petBg = GuidCacheUtil.GetUI("petBg")
        local petInfoBg = GuidCacheUtil.GetUI("petInfoBg")
        GUI.SetVisible(petBg, false)
        GUI.SetVisible(petInfoBg, false)
    end
end

--使用道具
function FightUI.OnUseDrugClick()
    local bg = GuidCacheUtil.GetUI("propBgCover")
    -- TODO： 获取道具
    if not selectItemGuid then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请选择要使用的道具")
        return
    end
    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)
    FightUI.ChooseTarget()
    GUI.SetVisible(bg, false)
end

--使用道具界面关闭，清除上次选择的数据
function FightUI.OnPropCloseBtnClick()
    local propBgCover = GuidCacheUtil.GetUI("propBgCover")
    if propBgCover ~= nil then
        FightUI.SaveSelectDrugDate(false)
        GUI.SetVisible(propBgCover, false)
        CurActionType = ""
    end
end

function FightUI.RefreshBag()
    local scroll = GuidCacheUtil.GetUI("scroll")
    if scroll ~= nil then
        local curCount = FightUI.GetCurCount()
        if curCount < 25 then
            curCount = 25
        end
        GUI.LoopScrollRectSetTotalCount(scroll, curCount)
        GUI.LoopScrollRectRefreshCells(scroll)
    end
end

function FightUI.GetCurCount()
    FightUI.InitItemList()
    local iconCount = #itemList
    return iconCount
end

--- 刷新物品列表
function FightUI.InitItemList()
    itemList = {}
    local count = LD.GetBagCapacity()--LD.GetItemCount()
    local level = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    for i = 0, count - 1 do
        local id = tonumber(LD.GetItemAttrByIndex(ItemAttr_Native.Id, i))
        if id ~= nil then
            local itemConfig = DB.GetOnceItemByKey1(id)
            if itemConfig and itemConfig.Fight < 2 and itemConfig.Level <= level then
                -- 0 和1 可以在战斗中使用
                local temp = { Id = id, index = i }
                itemList[#itemList + 1] = temp
            end
        end
    end
end

function FightUI.AutoFightSkillListVisibel(canSee)
    FightUI.SetAutoFightSkillCoverVisible(canSee)
    local listBg = GuidCacheUtil.GetUI("autoSkillListBg")
    if listBg then
        GUI.SetVisible(listBg, canSee)
    end
    lastAutoFightState = 2
end

function FightUI.OnPetActionClick()

    if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= nil then

        if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= 0 then

            CL.SendNotify(NOTIFY.ShowBBMsg, "自动施法中，无法手动切换技能")
            return

        end

    end

    setAutoFightType = "Pet"
    FightUI.CreateAutoSkillListScroll(false, 1)
    --local parent = GUI.GetWnd("FightUI")
    --SkillItemUtil.CreateSelectSkillPanel(parent, "SelectSkillPanel", 350, 0, CL.GetCurFightPet())
end

function FightUI.OnRoleActionClick()

    if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= nil then

        if GlobalProcessing.AutomaticCasting_CurSchemeIndex ~= 0 then

            CL.SendNotify(NOTIFY.ShowBBMsg, "自动施法中，无法手动切换技能")
            return

        end

    end

    setAutoFightType = "Role"
    FightUI.CreateAutoSkillListScroll(true, 0)
    --local parent = GUI.GetWnd("FightUI")
    --SkillItemUtil.CreateSelectSkillPanel(parent, "SelectSkillPanel", 350, 0)
end

--------------------------------------------------------------指挥界面开始-----------------------------------------------------------------
function FightUI.SetCommandPanelBgVisible(hide)
    local panel = GuidCacheUtil.GetUI("commandPanelBg") --GUI.Get("FightUI/commandPanelBg")
    if panel ~= nil then
        if hide then
            commandTarget = 0
            GUI.SetVisible(panel, false)
        else
            GUI.SetVisible(panel, true)
        end
    end
end

-- 弹指令框
function FightUI.RefreshCommandPanel(roleGuid)
    -- 判断点击的是不是观战者
    local isVisit = CL.GetFightViewState() -- 判断是不是观战
    if isVisit then
        return
    end
    commandTarget = 0
    if roleGuid ~= nil then
        commandTarget = roleGuid
    end
    FightUI.SetCommandPanelBgVisible()
    -- 暂时屏蔽掉指挥按钮
    --local controlBtn = GUI.Get("FightUI/commandPanelBg/baseInfoPage/controlBtn")
    --GUI.SetVisible(controlBtn, false)
    FightUI.OnControlBtnClick()
    FightUI.RefreshBuffReport()
end

function FightUI.RefreshBuffReport()
    local commandPanelBg = GuidCacheUtil.GetUI("commandPanelBg") --GUI.Get("FightUI/commandPanelBg")
    if GUI.GetVisible(commandPanelBg) then
        FightUI.InitBuffData(commandTarget)
        FightUI.CreateBuffScroll(commandTarget)
    end
end

function FightUI.OnCommandBtnClick(guid)
    local idx = commandBtnGuid2Idx[guid]
    if idx then
        local data = commandList[idx]
        if not data then
            return
        end
        CL.SendNotify(NOTIFY.InstructionOpe, 1, tonumber(commandTarget), data.type, idx)
    end
end

function FightUI.OnClearOrderClick()
    CL.SendNotify(NOTIFY.InstructionOpe, 2, tonumber(commandTarget))
end

function FightUI.OnClearOrderAllClick()
    CL.SendNotify(NOTIFY.InstructionOpe, 4, friendCommandType)
    CL.SendNotify(NOTIFY.InstructionOpe, 4, enemyCommandType)
end

function FightUI.OnAddOrderClick()
    local comScroll = GuidCacheUtil.GetUI("controlPageBg") --GUI.Get("FightUI/commandPanelBg/controlPageBg")
    GUI.SetVisible(comScroll, not GUI.GetVisible(comScroll))
    GUI.SetVisible(comScroll, not GUI.GetVisible(comScroll))
    local isFriend = false -- TODO: 判断是否为好友
    if isFriend then
        GUI.OpenWnd("InstructionsUI", "UIindex:2")
    else
        GUI.OpenWnd("InstructionsUI", "UIindex:1")
    end
end
--------------------------------------------------------------指挥界面结束-----------------------------------------------------------------

--------------------------------------------------------------宠物操作开始-----------------------------------------------------------------

-- 宠物防御按钮点击处理
function FightUI.OnPetDefenseClick(guid)
    FightUI.SetActionType("防御")

    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)

    FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_DEFENSE, 0)
    CL.OnSetAutoFightSkill(autoDefenseSkillID, true)
end

-- 宠物保护按钮
function FightUI.OnPetProtecClick(guid)
    FightUI.SetActionType("保护")
    FightUI.ChooseTarget()
end

-- 宠物逃跑按钮点击处理
function FightUI.OnPetEscapeClick(guid)
    FightUI.SetActionType("逃跑")
    FightUI.SetSkillListVisible(true)
    FightUI.SetCommandPanelBgVisible(true)
    FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_ESCAPE, 0)
end

-- 宠物攻击按钮点击处理
function FightUI.OnPetAttackClick(guid)
    CL.OnSetAutoFightSkill(autoAttackSkillID, true)
    FightUI.SetActionType("攻击")
    FightUI.ChooseTarget()
end

--宠物界面的法术按钮点击，首先获取当前的参战宠物，刷新和显示技能面板
function FightUI.OnPetMagicClick(guid)
    FightUI.OnPetFightInfoUpdate()
    FightUI.SetSkillListVisible(false, true)
    FightUI.SetCommandPanelBgVisible(true)
    FightUI.SetActionType("法术")
end

function FightUI.SetActionType(actionType)
    CurActionType = actionType
end
--------------------------------------------------------------宠物操作结束-----------------------------------------------------------------
--------------------------------------------------------------战斗中的数据、操作相关-----------------------------------------------------------------
--操作完成后
function FightUI.OnOperateFinish(isOperateFinish)
    FightUI.SetIsInActor(true)
end

--是否处于表演状态
function FightUI.SetIsInActor(isinActor)
    local isVisit = CL.GetFightViewState() -- 判断是不是观战
    if isVisit then
        --观战的时候，只开一个观战按钮
        FightUI.InViewState(true)
        return
    end
    if type(isinActor) ~= "boolean" then
        return
    end
    if FightUI.isInActor == isinActor then
        return
    end
    FightUI.isInActor = isinActor
    FightUI.StateChange(false)
    FightUI.SaveSelectDrugDate(false)
end

function FightUI.SetPetButtonListVisiable(canSee)
    local parent = GUI.Get("FightUI/scaleBg/petRightBg")
    if parent ~= nil then
        GUI.SetVisible(parent, canSee)
    end
end

function FightUI.SetRoleButtonListVisiable(canSee)
    local parent = GUI.Get("FightUI/scaleBg/rightBg")
    if parent ~= nil then
        GUI.SetVisible(parent, canSee)
    end
end

--开始表演的时候关闭UI，结束表演打开UI
function FightUI.StateChange(isOperate)
    local parent = GUI.GetWnd("FightUI")
    local preTips = GUI.GetChild(parent, "tipsCover")
    if preTips ~= nil then
        GUI.Destroy(preTips)
    end
    local scacleBtn = GUI.Get("FightUI/scacleBtn")
    local scaleBg = GuidCacheUtil.GetUI("scaleBg")
    local propBgCover = GuidCacheUtil.GetUI("propBgCover")
    local petBg = GuidCacheUtil.GetUI("petBg")
    local rightBg = GUI.Get("FightUI/scaleBg/rightBg")
    local autoFightBg = GUI.Get("FightUI/scaleBg/autoFightBtnBg/autoFightBtn/autoFightBg")
    local petRightBg = GUI.Get("FightUI/scaleBg/petRightBg")
    local petInfoBg = GuidCacheUtil.GetUI("petInfoBg")
    --local autoSkillListBg = GuidCacheUtil.GetUI("autoSkillListBg")
    local skillListBgCover = GuidCacheUtil.GetUI("skillListBgCover")
    local stuntSkillListBgCover = GUI.Get("FightUI/stuntSkillListBgCover")
    local itemTips = GUI.Get("FightUI/propBgCover/itemTips")
    FightUI.RefreshSkillList()
    FightUI.RefreshPetSkillList()
    if not isOperate then
        FightUI.InItAutoFightActionIcon()
        FightUI.ForbidPetActionBtn()
    end

    if FightUI.isInActor then
        if itemTips ~= nil then
            GUI.Destroy(itemTips)
        end
        GUI.SetVisible(scaleBg, true)
        if isInAutoFight then
            GUI.SetVisible(autoFightBg, true)
            --GUI.SetVisible(autoSkillListBg, false)
            GUI.SetVisible(skillListBgCover, false)
            GUI.SetVisible(stuntSkillListBgCover, false)
            GUI.SetVisible(petBg, false)
            GUI.SetVisible(petInfoBg, false)
            GUI.SetVisible(petRightBg, false)
            GUI.SetVisible(propBgCover, false)
            FightUI.InChooseTarget(false)
        else
            GUI.SetVisible(scacleBtn, false)
            GUI.SetVisible(petRightBg, false)
            GUI.SetVisible(petInfoBg, false)
            GUI.SetVisible(petBg, false)
            --GUI.SetVisible(autoSkillListBg, false)
            GUI.SetVisible(skillListBgCover, false)
            GUI.SetVisible(rightBg, false)
            GUI.SetVisible(stuntSkillListBgCover, false)
            GUI.SetVisible(propBgCover, false)
            FightUI.InChooseTarget(false)
        end
        --FightUI.RestoreButtonScale()
    else
        -- 出战斗
        if not isInAutoFight then
            GUI.SetVisible(rightBg, true)
        end
        FightUI.ClearDataEveryTurn()

        -- 设置上一回合的技能Icon
        if tonumber(lastUsedRoleSkillId) > 2 then
            FightUI.SetLastUsedSkillIcon(lastUsedRoleSkillId, true)
        end
        if not FightUI.CurrentPetHasThisSkill(lastUsedPetSkillId) then
            FightUI.SetLastUsedSkillIcon(0, false)
        elseif tonumber(lastUsedPetSkillId) > 2 then
            FightUI.SetLastUsedSkillIcon(lastUsedPetSkillId, false)
        end
    end
end

-- 设置为自动战斗的状态，页面切换，动画，其他页面的关闭等
function FightUI.AutoFightStateChange(isAutoFight)
    if isInAutoFight == isAutoFight then
        return
    end

    FightUI.InItAutoFightActionIcon()

    isInAutoFight = CL.OnGetAutoFightState() -- 获取当前是否处于自动战斗状态
    FightUI.CreateAutoSkillList()
    FightUI.AutoFightSkillListVisibel(false)
    local scaleBg = GuidCacheUtil.GetUI("scaleBg")
    local scacleBtn = GUI.Get("FightUI/scacleBtn")
    local propBgCover = GuidCacheUtil.GetUI("propBgCover")
    local rightBg = GUI.GetChild(scaleBg, "rightBg")
    local petRightBg = GUI.Get("FightUI/scaleBg/petRightBg")
    local petInfoBg = GuidCacheUtil.GetUI("petInfoBg")
    local autoSkillListBg = GUI.Get("FightUI/scaleBg/autoSkillListBg")
    local skillListBg = GUI.Get("FightUI/scaleBg/skillListBg")
    local autoFightBtn = GUI.Get("FightUI/scaleBg/autoFightBtnBg/autoFightBtn")
    local autoFightBg = GUI.GetChild(autoFightBtn, "autoFightBg")

    if FightUI.isInActor and not isInAutoFight then
        GUI.SetVisible(autoFightBg, false)
        GUI.SetVisible(rightBg, false)
        GUI.ImageSetImageID(autoFightBtn, "1800302070")
        return
    elseif FightUI.isInActor and isInAutoFight then
        GUI.SetVisible(autoFightBg, true)
        GUI.SetVisible(rightBg, false)
        GUI.ImageSetImageID(autoFightBtn, "1800302220")
        return
    end
    if isInAutoFight then

        local curLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)

        if GlobalProcessing.AutomaticCasting_OpenLevel and curLevel >= GlobalProcessing.AutomaticCasting_OpenLevel  then

            if UIDefine.FunctionSwitch["AutomaticCasting"] and UIDefine.FunctionSwitch["AutomaticCasting"] == "on" then

                isVoluntarily = true

            end

        end

        CurActionType = "自动战斗"
        GUI.ImageSetImageID(autoFightBtn, "1800302220")
        GUI.SetVisible(scacleBtn, false)
        GUI.SetVisible(petRightBg, false)
        GUI.SetVisible(petInfoBg, false)
        GUI.SetVisible(autoSkillListBg, false)
        GUI.SetVisible(skillListBg, false)
        GUI.SetVisible(propBgCover, false)
        GUI.SetVisible(rightBg, false)
        GUI.SetVisible(autoFightBg, true)
    else

        isVoluntarily = false
        GUI.ImageSetImageID(autoFightBtn, "1800302070")
        CurActionType = ""

        GUI.SetVisible(rightBg, true)
        GUI.SetVisible(autoFightBg, false)
        if isPetAction then
            FightUI.SetPetAction(true)
        end
    end
    FightUI.SetSkillListVisible(true)
end

--初始化自动战斗的操作Icon
function FightUI.InItAutoFightActionIcon(isRestartUI)
    local roleAction = CL.OnGetAutoFightSkill(false)
    local petAction = CL.OnGetAutoFightSkill(true)
    local skillIcon = nil
    if roleAction == 0 then
        -- 如果没有设置过技能
        for i = 1, #skillList do
            local skill = skillList[i].skill
            if skill then
                if skill.ClientChoose == 1 then
                    -- 地方活着的全体
                    roleAction = skill.Id
                    break
                end
            end
        end
    end
    if tonumber(roleAction) ~= 0 then
        local skill = DB.GetOnceSkillByKey1(roleAction)
        if skill ~= nil and skill.Id ~= 0 then
            local name = ""
            if tonumber(skill.Id) == 1 then
                skillIcon = "1800302250"
                name = "攻击"
            elseif tonumber(skill.Id) == 2 then
                skillIcon = "1800302240"
                name = "防御"
            else
                local tempStr = tostring(skill.Icon)
                skillIcon = string.sub(tempStr, 1, -2) .. "3"
                name = skill.Name
            end

            local needGray = false
            local remainCd = 0
            local isforgot = false
            local tempSkillList = skillList
            for i = 1, #tempSkillList do
                local skillData = tempSkillList[i]
                if skillData.skill then
                    local skill_1 = skillData.skill
                    if tonumber(skill_1.Id) == tonumber(roleAction) then
                        isforgot = skillData.IsForgot
                        if skillData.bountCD and skillData.bountCD > 0 then
                            needGray = true
                            remainCd = skillData.bountCD
                            break
                        end
                    end
                end
            end

            if skillIcon and skillIcon ~= "0" then
                FightUI.ChangeRoleActionBtnImage(skillIcon, name, needGray, remainCd, tonumber(skill.Id), isforgot)
            else
                test("技能图片配置出错！ID: " .. roleAction)
            end

        end
    end

    if FightUI.ForbidPetActionBtn() then
        return
    end

    if tonumber(petAction) == 0 then
        local currentPet = TOOLKIT.ObjectToString(GlobalUtils.GetMainLineUpPetGuid())
        local petSkills = LD.GetPetSkills(currentPet)
        local count = petSkills and petSkills.Count or 0
        if count > 0 then
            for i = 0, count - 1 do
                local skill = DB.GetOnceSkillByKey1(petSkills[i].id)
                if skill ~= nil and skill.Type == 1 then
                    petAction = skill.Id
                    break
                end
            end
        end
    end

    if tonumber(petAction) ~= 0 then
        local skill = DB.GetOnceSkillByKey1(petAction)
        if skill ~= nil then
            local name = ""
            if tonumber(skill.Id) == 1 then
                skillIcon = "1800302250"
                name = "攻击"
            elseif tonumber(skill.Id) == 2 then
                skillIcon = "1800302240"
                name = "防御"
            else
                if not FightUI.CurrentPetHasThisSkill(tonumber(skill.Id)) then
                    skillIcon = "1800302250"
                    name = ""
                    lastUsedPetSkillId = 1
                else
                    local tempStr = tostring(skill.Icon)
                    skillIcon = string.sub(tempStr, 1, -2) .. "3"
                    name = skill.Name
                    lastUsedPetSkillId = petAction
                end
            end

            local needGray = false
            local remainCd = 0
            local isforgot = false
            local tempSkillList = petSkillList
            for i = 1, #tempSkillList do
                if tempSkillList[i].skill then
                    if tonumber(tempSkillList[i].skill.Id) == tonumber(petAction) then
                        isforgot = tempSkillList[i].IsForgot
                        if tempSkillList[i].bountCD ~= nil and tempSkillList[i].bountCD > 0 then
                            needGray = true
                            remainCd = tempSkillList[i].bountCD
                        end
                        break
                    end
                end
            end

            FightUI.ChangePetActionBtnImage(skillIcon, name, needGray, remainCd, tonumber(skill.Id), isforgot)
        end
        --GUI.SetVisible(petActionIcon,true)
    else
        --GUI.SetVisible(petActionIcon,false)
    end
end

-- 宠物逃跑
function FightUI.OnPetEscape(escape, refreshAll)
    petEscaped = escape
    petSkillId2SkillData = {} -- 清理一下宠物技能
    FightUI.ForbidPetActionBtn()
    FightUI.OnPetListUpdate(false)
end

-- 禁用宠物自动战斗按钮
function FightUI.ForbidPetActionBtn()
    local needForbid = false
    local fightPetGuid = GlobalUtils.GetMainLineUpPetGuid()
    if petEscaped or fightPetGuid == uint64.zero then
        needForbid = true
    end

    local petActionBtn = GuidCacheUtil.GetUI("petActionBtn")
    local petActionTxt = GuidCacheUtil.GetUI("petActionTxt")
    if needForbid then
        GUI.SetVisible(petActionBtn, false)
        GUI.SetVisible(petActionTxt, false)
    else
        GUI.SetVisible(petActionBtn, true)
        GUI.SetVisible(petActionTxt, true)
    end
    return needForbid
end

-- 是否 需要宠物操作，需要的话切换UI
function FightUI.SetPetAction(needPetAction)
    isPetAction = needPetAction
    if not FightUI.isInActor and needPetAction and (not isInAutoFight) then
        FightUI.SetActionType("")
        local scaleBg = GuidCacheUtil.GetUI("scaleBg")
        local scacleBtn = GUI.Get("FightUI/scacleBtn")
        local rightBg = GUI.Get("FightUI/scaleBg/rightBg")
        GUI.SetVisible(scaleBg, true)
        GUI.SetVisible(scacleBtn, false)
        FightUI.SetSkillListVisible(true)
        FightUI.SetPetButtonListVisiable(true)
        GUI.SetVisible(rightBg, false)
    end
end

-- 每一回合开始前，清除一下数据
function FightUI.ClearDataEveryTurn()
    local wnd = GUI.GetWnd("FightUI")
    CurActionType = ""
    GUI.SetData(wnd, "LastSelectPetSkillID", "")
    CurSelectSkillId = 0
    if lastSelectPetItemGuid then
        local lastPetItem = GUI.GetByGuid(lastSelectPetItemGuid)
        if lastPetItem then
            GUI.CheckBoxExSetCheck(lastPetItem, false)
            lastSelectPetItemGuid = nil
        end
    end
    isPetAction = false
    FightUI.CurSelectPet = nil
end

--上一回合的人物技能Icon, 进入战斗的时候刷一下，每回合开始的时候刷一次
function FightUI.SetLastUsedSkillIcon(skillId, isRoleSkill)
    local lastUsedSkillBg
    local lastUsedSkillIcon
    local tempSkillList = {}

    if isRoleSkill then
        lastUsedSkillBg = GuidCacheUtil.GetUI("lastUsedSkillBg")
        lastUsedSkillIcon = GUI.GetChild(lastUsedSkillBg, "lastUsedSkillIcon")
        tempSkillList = skillList
    else
        lastUsedSkillBg = GuidCacheUtil.GetUI("petLastUsedSkillBg")
        lastUsedSkillIcon = GUI.GetChild(lastUsedSkillBg, "petLastUsedSkillIcon")
        if not FightUI.CurrentPetHasThisSkill(skillId) then
            skillId = 0
        end
        tempSkillList = petSkillList
    end

    if lastUsedSkillIcon then
        if tonumber(skillId) ~= 0 then
            local skill = DB.GetOnceSkillByKey1(skillId)
            if skill ~= nil then
                local tempStr = tostring(skill.Icon)
                local skillIcon = string.sub(tempStr, 1, -2) .. "3"
                GUI.ImageSetImageID(lastUsedSkillIcon, skillIcon)
                GUI.SetVisible(lastUsedSkillBg, true)
                local needGray = false
                local remainCd = 0
                local isforgot = false
                for i = 1, #tempSkillList do
                    if tempSkillList[i].skill then
                        if tonumber(tempSkillList[i].skill.Id) == tonumber(skillId) then
                            isforgot = tempSkillList[i].IsForgot
                            if tempSkillList[i].bountCD ~= nil and tempSkillList[i].bountCD > 0 then
                                needGray = true
                                remainCd = tempSkillList[i].bountCD
                                break
                            end
                        end
                    end
                end
                local forgotTxt = GUI.GetChild(lastUsedSkillBg, "forgotTxt")
                if isforgot then
                    needGray = true
                    GUI.SetVisible(forgotTxt, true)
                    SkillItemUtil.RefreshSkillCD(lastUsedSkillIcon, 0)
                else
                    GUI.SetVisible(forgotTxt, false)
                    SkillItemUtil.RefreshSkillCD(lastUsedSkillIcon, remainCd)
                end

                GUI.ImageSetGray(lastUsedSkillIcon, needGray or false)
            end
        else
            GUI.SetVisible(lastUsedSkillBg, false)
        end
    end
end

-- 是否当前宠物有指定的这个技能
function FightUI.CurrentPetHasThisSkill(skillId)
    if petSkillList then
        for i = 1, #petSkillList do
            local data = petSkillList[i]
            if data.id == skillId then
                return true
            end
        end
    end
    return false
end

-- 角色上一回合使用的技能点击
function FightUI.RoleLastUsedSkillIcon()
    FightUI.RefreshSkillList()
    local skillId = lastUsedRoleSkillId
    for i = 1, #skillList do
        local skillData = skillList[i]
        if skillData and skillData.id == skillId then
            if not FightUI.CheckSkillState(skillData) then
                return
            end
            break
        end
    end
    CurActionType = "法术"
    CurSelectSkillId = skillId
    FightUI.OnRoleListClick(skillId, false, "", "ManualSkill")
end

function FightUI.PetLastUsedSkillIcon()
    FightUI.RefreshPetSkillList()
    local skillId = lastUsedPetSkillId
    for i = 1, #petSkillList do
        local skillData = petSkillList[i]
        if skillData and skillData.id == skillId then
            if not FightUI.CheckSkillState(skillData) then
                return
            end
            break
        end
    end
    CurActionType = "法术"
    CurSelectSkillId = skillId
    FightUI.OnRoleListClick(skillId, false, "", "ManualSkill")
end

--选择完成后，发送操作指令 , 还要加判断，是不是队友，以及提示
-- 攻击类，判断是否攻击队友， 保护类，是否保护对方
function FightUI.OnClickRole(role_guid, name, uceType)
    if role_guid == nil then
        test("  Error ! Attention please  : Clicked Role GUID is nil ,need chenck what happened ! ")
    end

    if not CL.CheckIsFightPlayer(role_guid) then
        -- 点的是观战者
        return
    end

    if uceType and UCE.IntToEnum(uceType) == UCE.PointerUp then
        -- 此处是长按处理
        FightUI.RefreshCommandPanel(role_guid)--(int64.new(role_guid))
        return
    end
    --自动战斗下不接受操作指令
    if isInAutoFight or not isInFight or FightUI.isInActor then
        return
    end

    local scaleBg = GuidCacheUtil.GetUI("scaleBg")
    local actionType = CurActionType
    isFriend = CL.CheckIsFriend(role_guid)
    target = role_guid
    --判断类型，同时判断是否是宠物操作，分别取操作的具体内容
    if actionType == "法术" or actionType == "特技" then
        local selectSkill = 0
        if actionType == "特技" then
            selectSkill = tonumber(GUI.GetData(scaleBg, "SelectStuntSkillId"))
        else
            if isPetAction then
                local petSkillId = CurSelectSkillId
                selectSkill = petSkillId
            else
                selectSkill = CurSelectSkillId
            end
        end

        if selectSkill > 0 then
            local skillIcon = 0
            local name = ""
            local skill = DB.GetOnceSkillByKey1(selectSkill)
            if skill.Id == 0 then
                return
            end
            local skillSubType = skill.SubType
            if isPetAction then
                if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then
                    lastUsedPetSkillId = selectSkill
                    CL.OnSetAutoFightSkill(tonumber(lastUsedPetSkillId), true)
                end
                local tempStr = tostring(skill.Icon)
                skillIcon = string.sub(tempStr, 1, -2) .. "3"
                if tonumber(skill.Id) == 1 then
                    skillIcon = "1800302250"
                    name = "攻击"
                elseif tonumber(skill.Id) == 2 then
                    skillIcon = "1800302240"
                    name = "防御"
                else
                    name = skill.Name
                end
                FightUI.ChangeRoleActionBtnImage(skillIcon, name, false, 0, tonumber(skill.Id))
            else
                local tempStr = tostring(skill.Icon)
                skillIcon = string.sub(tempStr, 1, -2) .. "3"
                if tonumber(skill.Id) == 1 then
                    skillIcon = "1800302250"
                    name = "攻击"
                elseif tonumber(skill.Id) == 2 then
                    skillIcon = "1800302240"
                    name = "防御"
                else
                    name = skill.Name
                end
                FightUI.ChangeRoleActionBtnImage(skillIcon, name, false, 0, tonumber(skill.Id))
                if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then
                    lastUsedRoleSkillId = selectSkill
                    CL.OnSetAutoFightSkill(tonumber(lastUsedRoleSkillId), false)
                end
            end
            local temp = CL.CheckSkillTarget(selectSkill, tonumber(tostring(role_guid)))
            if not temp then
                CL.SendNotify(NOTIFY.ShowBBMsg, "请选取正确的目标")
                return
            else
                FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_SKILL, role_guid, selectSkill)
            end
        else
            FightUI.WeatherToAttackFriend()
        end
        CurSelectSkillId = 0
    elseif actionType == "攻击" then
        --攻击为普攻，发普攻协议
        FightUI.WeatherToAttackFriend()
    elseif actionType == "保护" then
        local canPotect = true
        if not isFriend then
            CL.SendNotify(NOTIFY.ShowBBMsg, "请选取正确的目标")
            canPotect = false
        else
            if not isPetAction then
                if TOOLKIT.ObjectToString(role_guid) == TOOLKIT.ObjectToString(CL.GetSelfOrPetFighterId(true)) then
                    CL.SendNotify(NOTIFY.ShowBBMsg, "请选取正确的目标")
                    canPotect = false
                end
            else
                if TOOLKIT.ObjectToString(role_guid) == TOOLKIT.ObjectToString(CL.GetSelfOrPetFighterId(false)) then
                    CL.SendNotify(NOTIFY.ShowBBMsg, "请选取正确的目标")
                    canPotect = false
                end
            end
        end
        if canPotect then
            FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_PROTECT, role_guid)
        end
    elseif actionType == "捕捉" then
        if isFriend then
            CL.SendNotify(NOTIFY.ShowBBMsg, "请选取正确的目标")
        else
            FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_CATCH, role_guid)
        end
    elseif actionType == "使用道具" then
        -- 这里要加入是否是能对自己单位使用
        local itemId = LD.GetItemAttrByGuid(ItemAttr_Native.Id, selectItemGuid)
        local itemConfig = DB.GetOnceItemByKey1(itemId)
        if itemConfig then
            FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_ITEM, role_guid, selectItemGuid)
        end
    elseif actionType == "防御" then
        FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_DEFENSE, role_guid)
    else
        --没有选择任何操作，直接发送普攻协议
        FightUI.WeatherToAttackFriend()
    end
end
--是否确认普攻队友，多处用到，单独报包一层
function FightUI.WeatherToAttackFriend()
    local temp = CL.CheckSkillTarget(autoAttackSkillID, target)
    if not temp then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请选取正确的目标")
        return
    end

    if isFriend then
        local actionType = CurActionType
        if actionType == nil or #actionType == 0 then
            return
        end
        FightUI.SendMessageBox("是否确认攻击队友", FightActionType.FIGHT_ACTION_TYPE_ATTACK, 1)
    else
        FightUI.SendCmd(FightActionType.FIGHT_ACTION_TYPE_ATTACK, target, 1)
        if isPetAction then
            CL.OnSetAutoFightSkill(autoAttackSkillID, true)
        else
            CL.OnSetAutoFightSkill(autoAttackSkillID)
        end
    end
end

function FightUI.SendMessageBox(str, CmdType, Parameter)
    cmdType = CmdType
    parameter = Parameter
    GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", str, "FightUI", "确定", "SureToSendCmd", "取消")
end

--发送CMD指令
function FightUI.SendCmd(cmdType, target, parameter)
    parameter = parameter or 0
    test("SendCmd: ", cmdType, target, parameter)
    CL.SendNotify(NOTIFY.FightCmd, cmdType, target, parameter)
    FightUI.SetActionType("")
end

-- 有些判断后需要玩家确认的事件
function FightUI.SureToSendCmd()
    CL.SendNotify(NOTIFY.FightCmd, cmdType, target, parameter)
    cmdType = ""
    target = ""
    parameter = ""
    FightUI.SetActionType("")
end

--发送指令后，界面的隐藏
function FightUI.AfterSendCmd()
    if isPetAction then
        local petRightBg = GUI.Get("FightUI/scaleBg/rightBg")
        if petRightBg ~= nil then
            GUI.SetVisible(petRightBg, false)
        end
    else
        local rightBg = GUI.Get("FightUI/scaleBg/rightBg")
        if rightBg ~= nil then
            GUI.SetVisible(rightBg, false)
        end
    end
end

-- 退出观战
function FightUI.OnOutViewBtn()
    CL.SendLeaveFightView()
end

--编辑指令后立即刷新指令面板
function FightUI.OnInstructionEditFinish()
    -- 创建指令列表
    if GUI.GetVisible(GuidCacheUtil.GetUI("controlPageBg")) then
        FightUI.RefreshCommandList()
    end
end

function FightUI.OnRoleAutoFightSkillIDChange(skillId)
    FightUI.InItAutoFightActionIcon()
end

function FightUI.RestoreButtonScale()
    local rightBg = GUI.Get("FightUI/scaleBg/rightBg")
    local childCount = GUI.GetChildCount(rightBg)
    for i = 0, childCount - 1 do
        local child = GUI.GetChildByIndex(rightBg, i)
        GUI.StopTween(child, 6)
        GUI.StopTween(child, 7)
        GUI.SetScale(child, Vector3.New(1, 1, 1))
    end
    local petRightBg = GUI.Get("FightUI/scaleBg/petRightBg")
    childCount = GUI.GetChildCount(petRightBg)
    for i = 0, childCount - 1 do
        local child = GUI.GetChildByIndex(petRightBg, i)
        GUI.StopTween(child, 6)
        GUI.StopTween(child, 7)
        GUI.SetScale(child, Vector3.New(1, 1, 1))
    end
end

--出战斗以后把自动战斗的灰色遮罩和CD去掉，避免下次进战斗的时候短暂的
function FightUI.ResetAutoActionBtn()
    local roleActionBtn = GuidCacheUtil.GetUI("roleActionBtn")
    if roleActionBtn ~= nil then
        GUI.ImageSetGray(roleActionBtn, false)
    end

    local petActionBtn = GuidCacheUtil.GetUI("petActionBtn")
    if petActionBtn ~= nil then
        GUI.ImageSetGray(petActionBtn, false)
    end
end

-- 技能表演消息  是否是宠物  技能ID 是回合开始时还是技能表演结束
function FightUI.OnInFightSkillShow(isRole, skillId, isEndShow)
    if isRole then
        FightUI.NeedDelayRefreshRoleSkill = tonumber(skillId)
    else
        FightUI.NeedDelayRefreshPetSkill = tonumber(skillId)
    end
end

function FightUI.OnDestroy()
    FightUI.StopSkillIconClickTimer()
end

function FightUI.OnPlayerCanOperateNotify(whetherCan)
    FightUI.PlayerCanOperate = whetherCan
    local roleActionBtnBg = GuidCacheUtil.GetUI("roleActionBtnBg")
    if roleActionBtnBg then
        GUI.SetVisible(roleActionBtnBg, whetherCan)
    end
end

function FightUI.SetAutoFightSkillCoverVisible(vis)
    local panel = GUI.GetWnd("FightUI")
    local cover = GUI.GetChild(panel, "SkillCover")
    if cover == nil then
        cover = GUI.ImageCreate(panel, "SkillCover", "1800499999", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        SetAnchorAndPivot(cover, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(cover, invisibilityColor)
        GUI.SetIsRaycastTarget(cover, true)
        cover:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(cover, UCE.PointerClick, "FightUI", "OnSkillCoverClick")
    end
    GUI.SetVisible(cover, vis)
end

function FightUI.OnSkillCoverClick(guid)
    GUI.SetVisible(GUI.GetByGuid(guid), false)
    FightUI.AutoFightSkillListVisibel(false)
end

-------------------------------- start新手引导相关接口start ---------------------------------
-- 新手引导专用接口
function FightUI.ClickRoleByPos(pos)
    local fightId = LD.GetFighterIdByPos(pos)
    FightUI.OnClickRole(tostring(fightId))
end

function FightUI.ClickSkillBtnBySkillID(id)
    if not guidToSkillId then
        return
    end
    for k, v in pairs(guidToSkillId) do
        if v == id then
            FightUI.OnRoleListClickUp(k)
            return
        end
    end
end

-------------------------------- end 新手引导相关接口 end ---------------------------------

function FightUI.AutomaticCastingBtnDown(guid)
    FightUI.BtnDoTweenScale(guid, true)
end

function FightUI.AutomaticCastingBtnUp(guid)
    FightUI.BtnDoTweenScale(guid, false)
end

--自动施法按钮点击事件
function FightUI.OnAutomaticCastingBtnClick(guid)

    test("自动施法按钮点击事件")

    local carTypeList = {}

    if GlobalProcessing.AutomaticCastingData ~= nil then

        if #GlobalProcessing.AutomaticCastingData > 0 then

            carTypeList = GlobalProcessing.AutomaticCastingData
            for i = 1, #carTypeList do

                if GlobalProcessing.AutomaticCasting_CurSchemeIndex == 0 then

                    carTypeList[i].isSelect = false

                elseif i == GlobalProcessing.AutomaticCasting_CurSchemeIndex then

                    carTypeList[i].isSelect = true

                else

                    carTypeList[i].isSelect = false

                end

            end

        end

    end


    if #carTypeList > 0 then

        local panel = GUI.GetWnd("FightUI")

        local cover = GUI.GetChild(panel,"carTypeGroupCover",false)

        if cover == nil then

            cover = GUI.ImageCreate(panel, "carTypeGroupCover", "1800499999", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
            GuidCacheUtil.BindName(cover,"carTypeGroupCover")
            SetAnchorAndPivot(cover, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetColor(cover, UIDefine.Transparent)
            GUI.SetIsRaycastTarget(cover, true)
            cover:RegisterEvent(UCE.PointerClick)
            GUI.RegisterUIEvent(cover, UCE.PointerClick, "FightUI", "cardTypeBorderSetVisible")

            --选择背景
            local cardTypeBorder = GUI.ImageCreate(cover, "cardTypeBorder", "1800400290", -110, -120, false, 180, 15 + 50 * #carTypeList,false);
            GuidCacheUtil.BindName(cardTypeBorder,"cardTypeBorder")
            GUI.SetVisible(cardTypeBorder,true)
            SetSameAnchorAndPivot(cardTypeBorder, UILayout.BottomRight)

            --滚动列表
            local carTypeScr = GUI.ScrollRectCreate(cardTypeBorder, "carTypeScr", 0, -10, 180,   50 * #carTypeList - 5, 0, false, Vector2.New(165, 45), UIAroundPivot.Top, UIAnchor.Top, 1);
            SetSameAnchorAndPivot(carTypeScr, UILayout.Top)
            GUI.ScrollRectSetChildSpacing(carTypeScr, Vector2.New(5, 5))

            for i = 1, #carTypeList do

                local carTypeGroup = GUI.GetChild(carTypeScr,"carTypeGroup"..i,false)

                if carTypeGroup == nil then

                    carTypeGroup = GUI.GroupCreate(carTypeScr,"carTypeGroup"..i,0,0,150,40,false)
                    SetSameAnchorAndPivot(carTypeGroup, UILayout.Center)


                    local carTypeSelectBtn = GUI.ButtonCreate(carTypeGroup, "carTypeSelectBtn", "1801102010", 0, 0, Transition.ColorTint, "", 130, 40, false);
                    GUI.ButtonSetTextColor(carTypeSelectBtn, UIDefine.BrownColor);
                    SetSameAnchorAndPivot(carTypeSelectBtn, UILayout.Left)
                    GUI.RegisterUIEvent(carTypeSelectBtn, UCE.PointerClick, "FightUI", "OnAutomaticBtnSelectClick")
                    GUI.SetData(carTypeSelectBtn, "name", carTypeList[i].name)
                    GUI.SetData(carTypeSelectBtn, "index", i)

                    local selectImg = "1800607150"
                    if carTypeList[i].isSelect then
                        selectImg = "1800607151"
                    end

                    local selectBg = GUI.ImageCreate(carTypeSelectBtn, "selectBg", selectImg, 5, 0, false, 30, 30,false)
                    SetSameAnchorAndPivot(selectBg, UILayout.Left)


                    local text = GUI.CreateStatic(carTypeSelectBtn, "text", carTypeList[i].name, 12, 0, 180, 35);
                    GUI.StaticSetFontSize(text, 20)
                    GUI.SetColor(text, UIDefine.BrownColor)
                    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
                    SetSameAnchorAndPivot(text, UILayout.Center)


                    local setBg = GUI.ImageCreate(carTypeGroup, "selectBg", "1801102010", 0, 0, false, 40, 40,false)
                    SetSameAnchorAndPivot(setBg, UILayout.Right)


                    local setBtn = GUI.ButtonCreate(setBg, "setBtn", "1800202240", 0, 0, Transition.ColorTint, "", 25, 25, false);
                    SetSameAnchorAndPivot(setBtn, UILayout.Center)
                    GUI.RegisterUIEvent(setBtn, UCE.PointerClick, "FightUI", "OnAutomaticBtnSetBtnClick")
                    GUI.SetData(setBtn, "index", i)


                end
            end

        else

            GUI.SetVisible(cover,true)

            local cardTypeBorder = GUI.GetChild(cover,"cardTypeBorder",false)

            test("选择页面刷新")

            local carTypeScr = GUI.GetChild(cardTypeBorder,"carTypeScr",false)

            for i = 1, #carTypeList do

                local carTypeGroup = GUI.GetChild(carTypeScr,"carTypeGroup"..i,false)

                local carTypeSelectBtn = GUI.GetChild(carTypeGroup,"carTypeSelectBtn",false)


                local selectImg = "1800607150"
                if carTypeList[i].isSelect then
                    selectImg = "1800607151"
                end

                local selectBg = GUI.GetChild(carTypeSelectBtn,"selectBg",false)

                local text = GUI.GetChild(carTypeSelectBtn,"text",false)


                GUI.StaticSetText(text,carTypeList[i].name)

                GUI.ImageSetImageID(selectBg,selectImg)

            end


        end

    else

        local cardTypeBorder = GUI.GetChild(autoFightBg,"cardTypeBorder",false)

        if cardTypeBorder ~= nil then

            GUI.SetVisible(cardTypeBorder,false)

        end

    end

end

--设置自动释放技能面板隐藏
function FightUI.cardTypeBorderSetVisible()

    local carTypeGroupCover = GuidCacheUtil.GetUI("carTypeGroupCover")

    if carTypeGroupCover ~= nil then

        GUI.SetVisible(carTypeGroupCover,false)

    end

end


function FightUI.OnAutomaticBtnSelectClick(guid)

    test("选择方案按钮点击事件")

    local carTypeSelectBtn = GUI.GetByGuid(guid);
    local index = tonumber(GUI.GetData(carTypeSelectBtn,"index"))

    local carTypeGroupCover = GuidCacheUtil.GetUI("carTypeGroupCover")
    GUI.SetVisible(carTypeGroupCover, false)

    CL.SendNotify(NOTIFY.SubmitForm, "FormAutomaticCasting", "SelectedScheme", index)

end

--设置按钮点击事件
function FightUI.OnAutomaticBtnSetBtnClick(guid)

    test("设置按钮点击事件")

    local setBtn = GUI.GetByGuid(guid)

    local index = tonumber(GUI.GetData(setBtn,"index"))

    local carTypeGroupCover = GuidCacheUtil.GetUI("carTypeGroupCover")
    GUI.SetVisible(carTypeGroupCover, false)

    test("index",index)

    GetWay.Def[1].jump("AutomaticCastingUI", index,1)

end
-------------------------------- end 新手引导相关接口 end --------------------------------->>>>>>> .r13018
