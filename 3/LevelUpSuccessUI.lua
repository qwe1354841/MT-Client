-- local test =print
local test = function()
end
local LevelUpSuccessUI = {
    ---@type LevelUpSuccessInfo
    ServerData = nil,
    lvUpTimer = nil
}
_G.LevelUpSuccessUI = LevelUpSuccessUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local starImage = "1801202190"
local GrayStarImage = "1801202192"

local guidt = UILayout.NewGUIDUtilTable()
function LevelUpSuccessUI.InitData()
    return {
        ---@type table<number, DynAttrData>
        nowattr = {},
        ---@type table<number, DynAttrData>
        nextattr = {},
        ---@type number[]
        attrId = {}
    }
end
local data = LevelUpSuccessUI.InitData()
function LevelUpSuccessUI.OnExitGame()
    data = LevelUpSuccessUI.InitData()
end
function LevelUpSuccessUI.OnExit()
    guidt = nil
    GUI.DestroyWnd("LevelUpSuccessUI")
end
function LevelUpSuccessUI.Main(parameter)
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("LevelUpSuccessUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("LevelUpSuccessUI", "LevelUpSuccessUI", 0, 0, eCanvasGroup.Normal)
    local w = GUI.GetWidth(panel)
    local h = GUI.GetHeight(panel)
    local panelBg = GUI.ImageCreate(panel, "bg", "1800400220", 0, 0, false, w, h)
    guidt.BindName(panelBg,"panelBg")
    -- panelBg:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(panelBg, true)
    GUI.RegisterUIEvent(panelBg, UCE.PointerClick, "LevelUpSuccessUI", "OnExit")
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)
    local centerBg = GUI.ImageCreate(panelBg, "centerBg", "1801200060", 0, 33, false, w, 482)
    UILayout.SetSameAnchorAndPivot(centerBg, UILayout.Center)
    local iconName = {"item", "skill"}
    local icony = {40, -10}
    local tipy = {80, -48}
    local ap = {UILayout.Top, UILayout.Bottom}
    for k = 1, 2 do
        local icon1 = ItemIcon.Create(centerBg, iconName[k] .. "icon1", -102, icony[k], 120, 120)
        local icon2 = ItemIcon.Create(centerBg, iconName[k] .. "icon2", 102, icony[k], 120, 120)

        local tipTop = GUI.ImageCreate(centerBg, iconName[k] .. "tipTop", "1800707050", 0, tipy[k])
        local tmp = {icon1, icon2, tipTop}
        for i = 1, #tmp do
            UILayout.SetSameAnchorAndPivot(tmp[i], ap[k])
        end
        guidt.BindName(icon1, iconName[k] .. "icon1")
        guidt.BindName(icon2, iconName[k] .. "icon2")
        tmp = {icon1, icon2}
        local onClick = {"OnOldSkillClick", "OnSkillClick"}
        if k == 1 then
            for j = 1, #tmp do
                local star = GUI.ImageCreate(tmp[j], "star", "1801200080", 0, 26, false, 120, 20)
                UILayout.SetSameAnchorAndPivot(star, UILayout.Bottom)
                for i = 1, 6 do
                    local tmp = GUI.ImageCreate(star, i, GrayStarImage, 20 * (i - 1), 0, false, 20, 20)
                    UILayout.SetSameAnchorAndPivot(tmp, UILayout.Left)
                end
            end
        elseif k == 2 then
            for j = 1, #tmp do
                GUI.RegisterUIEvent(tmp[j], UCE.PointerClick, "LevelUpSuccessUI", onClick[j])
            end
        end
    end

    local titleBg1 = GUI.ImageCreate(panelBg, "titleBg1", "1801200050", -211, -22)
    local titleBg2 = GUI.ImageCreate(panelBg, "titleBg1", "1801200050", 211, -22)
    local titleBg3 = GUI.ImageCreate(panelBg, "titleBg1", "1801204050", 0, 58)
    local tmp = {titleBg3, titleBg2, titleBg1}
    for i = 1, #tmp do
        UILayout.SetSameAnchorAndPivot(tmp[i], UILayout.Top)
    end
    GUI.SetScale(titleBg2, Vector3.New(-1, 1, 1))

    local tips = GUI.CreateStatic(panelBg, "tips", "点击任意位置继续游戏", 0, -27, 211, 27)
    UILayout.SetSameAnchorAndPivot(tips, UILayout.Bottom)
    GUI.StaticSetFontSize(tips, UIDefine.FontSizeM)
    GUI.SetColor(tips, UIDefine.WhiteColor)
    GUI.StaticSetAlignment(tips, TextAnchor.MiddleCenter)

    local src =
        GUI.LoopScrollRectCreate(
        panelBg,
        "src",
        0,
        60,
        720,
        150,
        "LevelUpSuccessUI",
        "CreateAttrItem",
        "LevelUpSuccessUI",
        "RefreshAttrItem",
        0,
        false,
        Vector2.New(280, 30),
        1,
        UIAroundPivot.Center,
        UIAnchor.Center
    )
    GUI.ScrollRectSetChildSpacing(src, UIDefine.Vector2One * 2)
    guidt.BindName(src, "src")
end
function LevelUpSuccessUI.OnShow(parameter)
    local wnd = GUI.GetWnd("LevelUpSuccessUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
    if LevelUpSuccessUI.lvUpTimer == nil then
        LevelUpSuccessUI.lvUpTimer = Timer.New(LevelUpSuccessUI.GetDate, 0.1, 1)
        LevelUpSuccessUI.lvUpTimer:Start()
    else
        LevelUpSuccessUI.lvUpTimer:Reset(LevelUpSuccessUI.GetDate, 0.1, 1, false)
        LevelUpSuccessUI.lvUpTimer:Start()
    end
end
function LevelUpSuccessUI.OnDestroy()
    LevelUpSuccessUI.OnClose()
end
function LevelUpSuccessUI.OnClose()
    local wnd = GUI.GetWnd("LevelUpSuccessUI")
    GUI.SetVisible(wnd, false)
    LevelUpSuccessUI.ServerData = {}
end
function LevelUpSuccessUI.GetDate()
    LevelUpSuccessUI.ClientRefresh()
end
function LevelUpSuccessUI.Refresh()
    LevelUpSuccessUI.ClientRefresh()
end
function LevelUpSuccessUI.ClientRefresh()
    LevelUpSuccessUI.ServerData.NextMaxLevel =
        LevelUpSuccessUI.ServerData.NextMaxLevel or LevelUpSuccessUI.ServerData.MaxLevel
    data.nowattr, data.nextattr, data.attrId =
        LogicDefine.LvUpAttrChangeServer2Client(
        LevelUpSuccessUI.ServerData.NowBuff,
        LevelUpSuccessUI.ServerData.NextBuff
    )
    LevelUpSuccessUI.RefreshUI()
end
function LevelUpSuccessUI.RefreshUI()
    local icon1 = guidt.GetUI("itemicon1")
    local icon2 = guidt.GetUI("itemicon2")
    local star1 = GUI.GetChild(icon1, "star", false)
    local star2 = GUI.GetChild(icon2, "star", false)
    local skill1 = guidt.GetUI("skillicon1")
    local skill2 = guidt.GetUI("skillicon2")

    ItemIcon.BindItemKeyName(icon1, LevelUpSuccessUI.ServerData.NowItem)
    ItemIcon.BindItemKeyName(icon2, LevelUpSuccessUI.ServerData.NextItem)
    GUI.ItemCtrlSetElementRect(icon1, eItemIconElement.Icon, 0, 0, 100, 100)
    GUI.ItemCtrlSetElementRect(icon2, eItemIconElement.Icon, 0, 0, 100, 100)
    local tmpCurLv = {LevelUpSuccessUI.ServerData.NowLevel, LevelUpSuccessUI.ServerData.NextLevel}
    local tmpMaxLv = {LevelUpSuccessUI.ServerData.MaxLevel, LevelUpSuccessUI.ServerData.NextMaxLevel}
    local tmpstar = {star1, star2}
    for i = 1, #tmpCurLv do
        if tmpCurLv[i] then
            GUI.SetVisible(tmpstar[i], true)
            for k = 1, 6 do
                local tmp = GUI.GetChild(tmpstar[i], k, false)
                if k <= tmpMaxLv[i] then
                    GUI.SetVisible(tmp, true)
                else
                    GUI.SetVisible(tmp, false)
                end
                if k <= tmpCurLv[i] then
                    GUI.ImageSetImageID(tmp, starImage)
                else
                    GUI.ImageSetImageID(tmp, GrayStarImage)
                end
            end
        else
            GUI.SetVisible(tmpstar[i], false)
        end
    end

    ItemIcon.BindSkillKeyName(skill1, LevelUpSuccessUI.ServerData.NowSkill)
    ItemIcon.BindSkillKeyName(skill2, LevelUpSuccessUI.ServerData.NextSkill)
    if LevelUpSuccessUI.ServerData.NowSkill and LevelUpSuccessUI.ServerData.NowSkill ~= nil and LevelUpSuccessUI.ServerData.NowSkill ~= "" then
        GUI.ItemCtrlSetElementValue(skill1, eItemIconElement.RightBottomNum, LevelUpSuccessUI.ServerData.NowLevel)
        GUI.ItemCtrlSetElementRect(skill1, eItemIconElement.RightBottomNum, 5, 5, 100, 50)
        local txt = GUI.ItemCtrlGetElement(skill1, eItemIconElement.RightBottomNum)
        GUI.SetVisible(txt, true)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeXL)
    end
    if LevelUpSuccessUI.ServerData.NextSkill and LevelUpSuccessUI.ServerData.NextSkill ~= nil and LevelUpSuccessUI.ServerData.NextSkill ~= "" then
        GUI.ItemCtrlSetElementValue(skill2, eItemIconElement.RightBottomNum, LevelUpSuccessUI.ServerData.NextLevel)
        GUI.ItemCtrlSetElementRect(skill2, eItemIconElement.RightBottomNum, 5, 5, 100, 50)
        local txt = GUI.ItemCtrlGetElement(skill2, eItemIconElement.RightBottomNum)
        GUI.SetVisible(txt, true)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeXL)
    end
    GUI.ItemCtrlSetElementRect(skill1, eItemIconElement.Icon, 0, 0, 100, 100)
    GUI.ItemCtrlSetElementRect(skill2, eItemIconElement.Icon, 0, 0, 100, 100)
    local src = guidt.GetUI("src")
    GUI.LoopScrollRectSetTotalCount(src, #data.attrId)
    GUI.LoopScrollRectRefreshCells(src)
end
function LevelUpSuccessUI.CreateAttrItem()
    local scroll = guidt.GetUI("src")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)

    local item = GUI.GroupCreate(scroll, curCount, 0, 0, 0, 0)
    local attr = GUI.CreateStatic(item, "attr", "属性", 0, 0, 100, 30)
    local v = GUI.CreateStatic(item, "value", "属性", 102, 0, 200, 30, "system", true)
    Tips.RegisterAttrHintEvent(attr, "LevelUpSuccessUI")

    local tmp = {attr, v}
    for i = 1, #tmp do
        GUI.StaticSetFontSize(tmp[i], UIDefine.FontSizeL)
        GUI.SetColor(tmp[i], UIDefine.WhiteColor)
        GUI.StaticSetAlignment(tmp[i], TextAnchor.MiddleLeft)
        UILayout.SetSameAnchorAndPivot(tmp[i], UILayout.Left)
    end
    return item
end
function LevelUpSuccessUI.RefreshAttrItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local id = data.attrId[index]
    local tmp1 = data.nowattr[id].GetStrValue()
    local tmp2 = data.nextattr[id].GetStrValue()
    local tmp = {tmp1, tmp2}
    for i = 1, #tmp do
        if string.sub(tmp[i], 1, 1) == "-" then
        else
            tmp[i] = "+" .. tmp[i]
        end
    end

    local text = tmp[1] .. "<color=#ffdf72>-></color><color=#08af00>" .. tmp[2] .. "</color>"
    local group = GUI.GetByGuid(guid)
    local attr = GUI.GetChild(group, "attr", false)
    local v = GUI.GetChild(group, "value", false)
    GUI.StaticSetText(attr, data.nowattr[id].name)
    GUI.StaticSetText(v, text)
    local w = GUI.StaticGetLabelPreferWidth(attr)
    GUI.SetWidth(attr,w)
    if w > 170 then
        local s = 170 / w
        GUI.SetScale(attr, Vector3.New(s, s, s))
    else
        GUI.SetScale(attr, UIDefine.Vector3One)
    end
end
function LevelUpSuccessUI.OnOldSkillClick()
    local detailinfo = LevelUpSuccessUI.ServerData
    if detailinfo ~= nil and detailinfo.NowSkill ~= nil and detailinfo.NowSkill ~= "" then
        local skillDB = DB.GetOnceSkillByKey2(detailinfo.NowSkill)
        if skillDB.Id > 0 then
            Tips.CreateSkillId(skillDB.Id, guidt.GetUI("panelBg"), "tip", 0, 0, 350)
        end
    end
end
function LevelUpSuccessUI.OnSkillClick()
    local detailinfo = LevelUpSuccessUI.ServerData
    if detailinfo ~= nil and detailinfo.NextSkill ~= nil and detailinfo.NextSkill ~= "" then
        local skillDB = DB.GetOnceSkillByKey2(detailinfo.NextSkill)
        if skillDB.Id > 0 then
            Tips.CreateSkillId(skillDB.Id, guidt.GetUI("panelBg"), "tip", 0, 0, 350)
        end
    end
end
