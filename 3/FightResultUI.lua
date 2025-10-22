local FightResultUI = {}

_G.FightResultUI = FightResultUI
local GuidCacheUtil = nil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local colorWhite = UIDefine.WhiteColor

local BeStrongList = {
    -- 显示文字      图标        图片字     打开界面   扩展参数 关联功能开启
    { "侍从提升", "1900050060", "1801404190", "GuardUI", nil, 6 },
    { "技能提升", "1900050050", "1801404180", "RoleSkillUI", nil, 5 },
    { "装备强化", "1900015890", "1801404170", "EquipUI", nil, 30 }, -- "index:1"
    { "萌宠提升", "1801409020", "1801404160", "PetUI", nil, 0 },
}
local btnGuid2Idx = {}

function FightResultUI.Main()
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("FightResultUI", "FightResultUI", 0, 0, eCanvasGroup.TopMost)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local coverSp = FightResultUI.ImageCreate(panel, "coverSp", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    GUI.SetIsRaycastTarget(coverSp, true)
    coverSp:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(coverSp, UCE.PointerClick, "FightResultUI", "OnCancelClick")
    local titleSp = FightResultUI.ImageCreate(coverSp, "titleSp", "1801408050", 0, -105, true)

    local panelBg = FightResultUI.ImageCreate(panel, "panelBg", "1801401130", 0, 60, false, 860, 200)
    local panelBgGuangXiao = FightResultUI.ImageCreate(panelBg, "panelBgGuangXiao", "1801401120", 0, -1, false, 740, 238)
    local txt = GUI.CreateStatic(panelBg, "tipsText1", "胜败乃兵家常事，让自己变强后再来挑战", 0, -64, 200, 40)
    FightResultUI.SetLabelBasicInfo(txt, 24, colorWhite)
    txt = GUI.CreateStatic(panelBg, "tipsText2", "点击空白处关闭界面", 0, 125, 200, 40)
    FightResultUI.SetLabelBasicInfo(txt, 22, colorWhite)

    FightResultUI.CreateFightResult(panelBg)
    CL.RegisterMessage(GM.FightStateNtf, "FightResultUI", "OnInFight")
end

FightResultUI.BeStrongListCount = 0
function FightResultUI.CreateFightResult(parent)
    FightResultUI.BeStrongListCount = #BeStrongList
    local offset = 0
    local index = 0
    if FightResultUI.BeStrongListCount > 1 then
        offset = (FightResultUI.BeStrongListCount - 1) * 86
    end
    btnGuid2Idx = {}
    for i = 1, FightResultUI.BeStrongListCount do
        local item = GUI.ButtonCreate(parent, i, BeStrongList[i][2], -offset + index * 172, 0, Transition.ColorTint, "", 0, 0, true)
        btnGuid2Idx[GUI.GetGuid(item)] = i
        FightResultUI.SetButtonBasicInfo(item, "OnResultActionClick")
        local spText = GUI.ImageCreate(item, i, BeStrongList[i][3], -1, 15)
        SetAnchorAndPivot(spText, UIAnchor.Bottom, UIAroundPivot.Bottom)
        local txt = GUI.CreateStatic(item, i .. "Text", BeStrongList[i][1], 0, 70, 100, 30)
        FightResultUI.SetLabelBasicInfo(txt, 20, colorWhite)
        index = index + 1
    end
end

function FightResultUI.SetButtonBasicInfo(btn, func)
    SetAnchorAndPivot(btn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "FightResultUI", func)
end

function FightResultUI.ImageCreate(parent, key, spriteString, x, y, autoSize, w, h)
    local sp
    if autoSize then
        sp = GUI.ImageCreate(parent, key, spriteString, x, y, autoSize)
    else
        sp = GUI.ImageCreate(parent, key, spriteString, x, y, autoSize, w, h)
    end
    SetAnchorAndPivot(sp, UIAnchor.Center, UIAroundPivot.Center)
    return sp
end

function FightResultUI.SetLabelBasicInfo(txt, fontSize, textColor)
    SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(txt, fontSize)
    GUI.SetColor(txt, textColor)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
end

function FightResultUI.OnShow(parameter)
    local wnd = GUI.GetWnd("FightResultUI")
    if wnd then
        GUI.SetVisible(wnd, true)
    end
end

function FightResultUI.OnResultActionClick(guid)
    local idx = btnGuid2Idx[guid]
    local item = BeStrongList[idx]
    if not item then
        return
    end
    if item[5] then
        GUI.OpenWnd(item[4], item[5])
    else
        GUI.OpenWnd(item[4])
    end
    FightResultUI.OnCancelClick()
end

function FightResultUI.OnCancelClick()
    GUI.CloseWnd("FightResultUI")
end

function FightResultUI.OnInFight(inFight, resultType)
    if inFight then
        FightResultUI.OnCancelClick()
    end
end
