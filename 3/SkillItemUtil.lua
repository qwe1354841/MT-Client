local SkillItemUtil = {}
_G.SkillItemUtil = SkillItemUtil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local DefaultSkillIcon = "1800302210"

function SkillItemUtil.CreateSkillItem(parent, name, x, y, w, h, wndName, onClick, onPointDown, onPointExit)
    x = x or 0
    y = y or 0
    w = w or 65
    h = h or 65
    local item = GUI.ButtonCreate(parent, name, "1800302190", x, -y, Transition.ColorTint, "", w, h, false)
    GUI.ButtonSetPressedColor(item, Color.New(1, 1, 1, 1))
    if wndName then
        if onClick then
            GUI.RegisterUIEvent(item, UCE.PointerClick, wndName, onClick)
        end
        if onPointDown then
            item:RegisterEvent(UCE.PointerDown)
            GUI.RegisterUIEvent(item, UCE.PointerDown, wndName, onPointDown)
        end
        if onPointExit then
            item:RegisterEvent(UCE.PointerExit)
            GUI.RegisterUIEvent(item, UCE.PointerExit, wndName, onPointExit)
        end
    end
    local btnSelectImage = GUI.ImageCreate(item, "btnSelectImage", "1800300110", 0, 0, false, 93, 93)
    local IconSp = GUI.ImageCreate(item, "IconSp", DefaultSkillIcon, 0, 0, false, 76, 76)
    local nameTxt = GUI.CreateStatic(item, "nameTxt", "", 0, 60, 150, 35, "system", true)
    SetAnchorAndPivot(nameTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(nameTxt, 24)
    GUI.SetColor(nameTxt, Color.New(247 / 255, 232 / 255, 184 / 255, 255 / 255))
    GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleCenter)
    return item
end

function SkillItemUtil.RefreshSkillItemBySkillDB(skillItem, skillDB)
    local btnSelectImage = GUI.GetChild(skillItem, "btnSelectImage")
    local IconSp = GUI.GetChild(skillItem, "IconSp")
    local nameTxt = GUI.GetChild(skillItem, "nameTxt")
    if skillDB and skillDB.Id ~= 0 then
		local skillId = skillDB.Id
        local tempStr = tostring(skillDB.Icon)
		-- 普通攻击和防御这两个Icon特殊处理
        local iconStr = (skillId == 1 or skillId == 2) and tempStr or string.sub(tempStr, 1, -2) .. "3"
        GUI.ImageSetImageID(IconSp, iconStr)
        GUI.StaticSetText(nameTxt, skillDB.Name)
    else
        GUI.ImageSetImageID(IconSp, DefaultSkillIcon)
        GUI.StaticSetText(nameTxt, "")
    end
    GlobalUtils.AddSkillIconTypeTipSp(skillItem ,skillDB.Id)
    GUI.SetVisible(btnSelectImage, false)
end

function SkillItemUtil.RefreshSkillItemBySkillId(skillItem, skillId)
    local skillDB = DB.GetOnceSkillByKey1(skillId)
    SkillItemUtil.RefreshSkillItemBySkillDB(skillItem, skillDB)
end

function SkillItemUtil.RefreshSkillItemByKeyName(skillItem, keyName)
    local skillDB = DB.GetOnceSkillByKey2(keyName)
    SkillItemUtil.RefreshSkillItemBySkillDB(skillItem, skillDB)
end

local CDPosX = {
    { 0 },
    { 17, -17 },
    { 30, 0, -30 },
}
local CDNumSize = { 40, 35, 30 }
-- 刷新技能CD
function SkillItemUtil.RefreshSkillCD(skillIcon, cd)
    local cdGroup = GUI.GetChild(skillIcon, "cdGroup")
    if cdGroup then
        if cd <= 0 then
            GUI.SetVisible(cdGroup, false)
            return
        end
        GUI.SetVisible(cdGroup, true)
    else
        if cd <= 0 then
            return
        end
        cdGroup = GUI.GroupCreate(skillIcon, "cdGroup", 0, 0)
    end
    local t = {}
    local maxNum = 3
    for i = 1, maxNum do
        if cd == 0 then
            break
        end
        t[#t + 1] = cd % 10
        cd = math.floor(cd / 10)
    end
    if cd > 0 then
        test("CD配置值出错！")
        GUI.SetVisible(cdGroup, false)
        return
    end
    local num = #t
    local posT = CDPosX[num]
    for i = 1, maxNum do
        local name = "cdImg" .. i
        local img = GUI.GetChild(cdGroup, name)
        if i <= num then
            img = img or GUI.ImageCreate(cdGroup, name, "1900505011", 0, 0, false, 30, 30)
            GUI.ImageSetImageID(img, "190050501" .. t[i])
            GUI.SetWidth(img, CDNumSize[num])
            GUI.SetHeight(img, CDNumSize[num])
            GUI.SetPositionX(img, posT[i])
            GUI.SetVisible(img, true)
        else
            GUI.SetVisible(img, false)
        end
    end
end

local SelectSkillTipParentGuid = nil
local CurSelectSkillPanelGuid = nil
local SkillItem2ID = nil
local SkillID2Level = nil
local CurPetGuid = nil
local LastSelectSkillItemGuid = nil
local TipPos = Vector2.New(0, 0)
--使用的时候一定要挂在wnd的节点下
function SkillItemUtil.CreateSelectSkillPanel(parent, name, x, y, petGuid)
    LastSelectSkillItemGuid = nil
    SkillItem2ID = {}
    SkillID2Level = {}
    x = x or 0
    y = y or 0
    TipPos = Vector2.New(x, y)
    local panel = GUI.GetWnd("MainUI")
    local cover = GUI.ImageCreate(parent, name, "1800499999", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    CurSelectSkillPanelGuid = GUI.GetGuid(cover)
    SelectSkillTipParentGuid = GUI.GetGuid(parent)
    SetAnchorAndPivot(cover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(cover, UIDefine.Transparent)
    GUI.SetIsRaycastTarget(cover, true)
    cover:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(cover, UCE.PointerClick, "SkillItemUtil", "OnSkillCoverClick")
    --GUI.SetIsRemoveWhenClick(cover, true)
    local listBg = GUI.ImageCreate(cover, "bg", "1800400290", x, y, false, 385, 450)
    SetAnchorAndPivot(listBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(listBg, true)
    listBg:RegisterEvent(UCE.PointerClick)
    local bg1 = GUI.ImageCreate(listBg, "commonAttackBg", "1800302190", -120, 60, false, 90, 90)
    SetAnchorAndPivot(bg1, UIAnchor.Top, UIAroundPivot.Center)
    local tempBtn1 = GUI.ButtonCreate(bg1, "commonAttackBtn", "1800302090", 0, 0, Transition.ColorTint, "", 90, 90, false)
    GUI.RegisterUIEvent(tempBtn1, UCE.PointerClick, "SkillItemUtil", "OnCommonAttackClick")
    SetAnchorAndPivot(tempBtn1, UIAnchor.Center, UIAroundPivot.Center)
    local bg2 = GUI.ImageCreate(listBg, "autoDefenseBg", "1800302190", 0, 60, false, 90, 90)
    SetAnchorAndPivot(bg2, UIAnchor.Top, UIAroundPivot.Center)
    local tempBtn2 = GUI.ButtonCreate(bg2, "autoDefenseBtn", "1800302060", 0, 0, Transition.ColorTint, "", 90, 90, false)
    GUI.RegisterUIEvent(tempBtn2, UCE.PointerClick, "SkillItemUtil", "OnCommonDefenseClick")
    SetAnchorAndPivot(tempBtn2, UIAnchor.Center, UIAroundPivot.Center)
    local cutline = GUI.ImageCreate(listBg, "autoSkillListCutLine", "1800600030", 0, 125, false, 400, 4)
    SetAnchorAndPivot(cutline, UIAnchor.Top, UIAroundPivot.Center)
    local chileSize = Vector2.New(90, 90)
    local  roleListScroll = GUI.ScrollRectCreate(listBg, "autoSkillListScroll", 0, 65, 340, 260, 0, false, chileSize, UIAroundPivot.Top, UIAnchor.Top, 3)
    GUI.ScrollRectSetChildSpacing(roleListScroll, Vector2.New(30, 45))
    local skillList
    CurPetGuid = petGuid
    if petGuid and petGuid ~= 0 then
        skillList = LD.GetPetSkills(petGuid)
    else
        skillList = LD.GetSelfSkillList()
    end
    if skillList then
        for i = 0, skillList.Count - 1 do
            local skillData = skillList[i]
            if skillData.enable == 1 then
                local skillId = skillData.id
                local skillDB = DB.GetOnceSkillByKey1(skillId)
                if skillDB.Type == 1 then --普通技能才显示
                    local skillSubType = skillDB.SubType
                    if (skillSubType >= 0 and skillSubType <= 6) or skillSubType == 12 then
                        local skillItem = SkillItemUtil.CreateSkillItem(roleListScroll, "skill" .. i, 0, 0, 65, 65, "SkillItemUtil", "OnClickSkillClick", "OnSkillItemPointerDown", "OnSkillItemPointerExit")
                        SkillItemUtil.RefreshSkillItemBySkillDB(skillItem, skillDB)
                        SkillItem2ID[GUI.GetGuid(skillItem)] = skillId
                        SkillID2Level[skillId] = skillData.performance
                    end
                end
            end
        end
    end

    return cover
end

local autoAttackSkillID = 1
function SkillItemUtil.OnCommonAttackClick(guid)
    SkillItemUtil.StopLongPressTimer()
    --CL.OnSetAutoFightSkill(autoAttackSkillID, CurPetGuid and CurPetGuid ~= 0 or false)
    LD.SetAutoFightSkill(autoAttackSkillID, CurPetGuid or uint64.zero)
    SkillItemUtil.OnSkillCoverClick(CurSelectSkillPanelGuid)
end

local autoDefenseSkillID = 2
function SkillItemUtil.OnCommonDefenseClick(guid)
    SkillItemUtil.StopLongPressTimer()
    --CL.OnSetAutoFightSkill(autoDefenseSkillID, CurPetGuid and CurPetGuid ~= 0 or false)
    LD.SetAutoFightSkill(autoDefenseSkillID, CurPetGuid or uint64.zero)
    SkillItemUtil.OnSkillCoverClick(CurSelectSkillPanelGuid)
end

local longPressTimer = nil
local longPressItemGuid = nil
function SkillItemUtil.OnSkillItemPointerDown(guid)
    longPressItemGuid = nil
    local func = function()
        if LastSelectSkillItemGuid ~= guid then
            if LastSelectSkillItemGuid then
                local lastItem = GUI.GetByGuid(LastSelectSkillItemGuid)
                GUI.SetVisible(GUI.GetChild(lastItem, "btnSelectImage"), false)
            end
        end
        LastSelectSkillItemGuid = guid
        GUI.SetVisible(GUI.GetChild(GUI.GetByGuid(guid), "btnSelectImage"), true)
        longPressItemGuid = guid
        local skillId = SkillItem2ID[guid]
        local parent = GUI.GetByGuid(SelectSkillTipParentGuid)
        local cover = GUI.ImageCreate(parent, "SkillTipCover", "1800499999", 0, 0, false, GUI.GetWidth(parent), GUI.GetHeight(parent))
        GUI.SetDepth(cover, -10)
        GUI.SetColor(cover, UIDefine.Transparent)
        local x = TipPos.x > 0 and TipPos.x - 395 or TipPos.x + 395
        local tip = Tips.CreateSkillId(skillId, cover, "SkillTip", x, TipPos.y, 0, 0, SkillID2Level[skillId])
        GUI.SetIsRemoveWhenClick(tip, false)
        GUI.SetIsRaycastTarget(cover, true)
        cover:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(cover, UCE.PointerClick, "SkillItemUtil", "OnSkillCoverClick")
        longPressTimer = nil
    end
    SkillItemUtil.StopLongPressTimer()
    longPressTimer = Timer.New(func, 0.4)
    longPressTimer:Start()
end

function SkillItemUtil.OnSkillItemPointerExit(guid)
    SkillItemUtil.StopLongPressTimer()
    longPressItemGuid = nil
end

function SkillItemUtil.OnClickSkillClick(guid)
    SkillItemUtil.StopLongPressTimer()
    if not longPressItemGuid then
        local skillId = SkillItem2ID[guid]
        --CL.OnSetAutoFightSkill(skillId, CurPetGuid and CurPetGuid ~= 0 or false)
        LD.SetAutoFightSkill(skillId, CurPetGuid or 0)
        longPressItemGuid = nil
        SkillItemUtil.OnSkillCoverClick(CurSelectSkillPanelGuid)
    else
        longPressItemGuid = nil
    end
end

function SkillItemUtil.StopLongPressTimer()
    if longPressTimer then
        longPressTimer:Stop()
        longPressTimer = nil
    end
end

function SkillItemUtil.OnSkillCoverClick(guid)
    local cover = GUI.GetByGuid(guid)
    GUI.Destroy(cover)
    if LastSelectSkillItemGuid then
        local lastItem = GUI.GetByGuid(LastSelectSkillItemGuid)
        GUI.SetVisible(GUI.GetChild(lastItem, "btnSelectImage"), false)
        LastSelectSkillItemGuid = nil
    end
end