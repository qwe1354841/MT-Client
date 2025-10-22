-- local test =print
local test = function()
end
local MythicalAnimalsLvUpUI = {
    ServerData = {}
}
_G.MythicalAnimalsLvUpUI = MythicalAnimalsLvUpUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local starImage = "1801202190"
local GrayStarImage = "1801202191"

local guidt = UILayout.NewGUIDUtilTable()
function MythicalAnimalsLvUpUI.InitData()
    return {
        animal_name = "",
        ---@type table<number, DynAttrData>
        nowattr = {},
        ---@type table<number, DynAttrData>
        nextattr = {},
        ---@type number[]
        attrId = {}
    }
end
local data = MythicalAnimalsLvUpUI.InitData()
function MythicalAnimalsLvUpUI.OnExitGame()
    data = MythicalAnimalsLvUpUI.InitData()
end
function MythicalAnimalsLvUpUI.OnExit()
    GUI.CloseWnd("MythicalAnimalsLvUpUI")
end
function MythicalAnimalsLvUpUI.Main(parameter)
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("MythicalAnimalsLvUpUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("MythicalAnimalsLvUpUI", "MythicalAnimalsLvUpUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle2(panel, parameter, 800, 650, "MythicalAnimalsLvUpUI", "OnExit")
    local modelBg = GUI.ImageCreate(panelBg, "modelBg", "1800400230", -200, 0)
    local title = GUI.GetChild(GUI.GetChild(panelBg, "topBarCenter", false), "tipLabel", false)
    guidt.BindName(title, "title")
    guidt.BindName(panelBg, "panelBg")
    local pedestal = GUI.ImageCreate(modelBg, "pedestal", "1800600210", 0, 150)
    UILayout.SetSameAnchorAndPivot(pedestal, UILayout.Center)

    local shadow = GUI.ImageCreate(pedestal, "shadow", "1800400240", 0, -16)
    UILayout.SetSameAnchorAndPivot(shadow, UILayout.Center)

    local model = GUI.RawImageCreate(modelBg, false, "model", "", 0, -20, 3, false, 600, 600)
    guidt.BindName(model, "model")
    guidt.BindName(modelBg, "modelbg")

    GUI.RawImageSetCameraConfig(
        model,
        "(1.65,1.3,2),(-0.04464257,0.9316535,-0.1226545,-0.3390941),True,5,0.01,1.25,1E-05"
    )

    model:RegisterEvent(UCE.Drag)
    model:RegisterEvent(UCE.PointerClick)
    local rolemodel = GUI.RawImageChildCreate(model, false, "roleModel", "", 100, 90)
    guidt.BindName(rolemodel, "rolemodel")
    GUI.BindPrefabWithChild(model, guidt.GetGuid("rolemodel"))

    local hintBtn = GUI.ButtonCreate(panelBg, "hintBtn", "1800702030", 50, 100, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(hintBtn, UILayout.TopLeft)
    GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "MythicalAnimalsLvUpUI", "OnHintBtnClick")

    local flag = GUI.ImageCreate(panelBg, "flag", UIDefine.ItemSSR[2], -421, 100)
    UILayout.SetSameAnchorAndPivot(flag, UILayout.TopRight)
    guidt.BindName(flag, "flag")

    local txt = GUI.CreateStatic(panelBg, "rank", "评分", 0, -50, 100, 50)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.BottomLeft)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(txt, TextAnchor.LowerCenter)

    local rankBar = UILayout.CreateAttrBar(panelBg, "rankBar", 123, -50, 235, UILayout.BottomLeft)
    guidt.BindName(rankBar, "rankBar")

    local infobg = GUI.ImageCreate(panelBg, "infobg", "1800400010", 215, 20, false, 344, 575)
    local starBg = GUI.ImageCreate(infobg, "starBg", "1801200040", 0, 27, false, 336, 40)
    for i = 1, 6 do
        local star = GUI.ImageCreate(starBg, i, starImage, 25 + (49 * (i - 1)), 0)
        UILayout.SetSameAnchorAndPivot(star, UILayout.Left)
    end
    UILayout.SetSameAnchorAndPivot(starBg, UILayout.Top)
    guidt.BindName(starBg, "starBg")

    local itemBg = GUI.ImageCreate(infobg, "itemBg", "1800700220", 0, 70)
    UILayout.SetSameAnchorAndPivot(itemBg, UILayout.Top)
    local unMax = GUI.GroupCreate(itemBg, "unMax", 0, 0, 266, 190)
    UILayout.SetSameAnchorAndPivot(unMax, UILayout.Center)
    local itemicon = ItemIcon.Create(unMax, "itemicon", 0, 0)
    guidt.BindName(itemicon, "itemicon")
    local sliderBg = GUI.ImageCreate(unMax, "sliderBg", "1801201090", 0, 0)
    local slider = GUI.ImageCreate(sliderBg, "slider", "1801201100", 0, 0)
    GUI.ImageSetType(slider, SpriteType.Filled)
    GUI.SetImageFillMethod(slider, SpriteFillMethod.Radial360_Bottom)
    guidt.BindName(slider, "slider")

    local sliderValue = GUI.CreateStatic(sliderBg, "sliderValue", "0/100", 0, 0, 100, 27)
    UILayout.SetSameAnchorAndPivot(sliderValue, UILayout.Bottom)
    GUI.StaticSetFontSize(sliderValue, UIDefine.FontSizeM)
    GUI.SetColor(sliderValue, UIDefine.WhiteColor)
    GUI.StaticSetAlignment(sliderValue, TextAnchor.MiddleCenter)
    guidt.BindName(sliderValue, "sliderValue")

    local max = GUI.ImageCreate(unMax, "max", "1800700300", 0, 0)
    guidt.BindName(max, "max")

    local oldSkill = ItemIcon.Create(infobg, "oldSkill", -83, -67, 80, 81)
    guidt.BindName(oldSkill, "oldSkill")
    GUI.RegisterUIEvent(oldSkill, UCE.PointerClick, "MythicalAnimalsLvUpUI", "OnOldSkillClick")
    local tmpSp = GUI.ImageCreate(infobg, "tmpSp", "1800707050", 0, -84)
    local skill = ItemIcon.Create(infobg, "skill", 83, -67, 80, 81)
    guidt.BindName(skill, "skill")
    GUI.RegisterUIEvent(skill, UCE.PointerClick, "MythicalAnimalsLvUpUI", "OnSkillClick")

    local updateBtn = GUI.ButtonCreate(infobg, "updateBtn", "1800402080", 0, -10, Transition.ColorTint, "升星", 133, 47)
    GUI.ButtonSetTextColor(updateBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(updateBtn, UIDefine.FontSizeL)
    local tmpB = {oldSkill, tmpSp, skill, updateBtn}
    for i = 1, #tmpB do
        UILayout.SetSameAnchorAndPivot(tmpB[i], UILayout.Bottom)
    end
    GUI.RegisterUIEvent(updateBtn, UCE.PointerClick, "MythicalAnimalsLvUpUI", "OnUpdateBtnClick")

    local src =
        GUI.LoopScrollRectCreate(
        infobg,
        "src",
        0,
        70,
        300,
        100,
        "MythicalAnimalsLvUpUI",
        "CreateAttrItem",
        "MythicalAnimalsLvUpUI",
        "RefreshAttrItem",
        0,
        false,
        Vector2.New(250, 30),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    GUI.ScrollRectSetChildSpacing(src, UIDefine.Vector2One * 2)
    guidt.BindName(src, "src")

    local attrTitleBg = GUI.ImageCreate(infobg, "attrTitleBg", "1800001140", 0, 0, false, 217, 35)
    UILayout.SetSameAnchorAndPivot(attrTitleBg, UILayout.Center)
    local attrTitleText = GUI.CreateStatic(attrTitleBg, "attrTitleText", "加成人物属性", 0, 0, 133, 30)
    GUI.StaticSetFontSize(attrTitleText, UIDefine.FontSizeM)
    UILayout.SetSameAnchorAndPivot(attrTitleText, UILayout.Center)

    local nextPageBtn = GUI.ButtonCreate(panelBg, "nextPageBtn", "1800602120", 500, 0, Transition.ColorTint)
    local upPageBtn = GUI.ButtonCreate(panelBg, "upPageBtn", "1800602120", -500, 0, Transition.ColorTint)
    guidt.BindName(nextPageBtn, "nextPageBtn")
    guidt.BindName(upPageBtn, "upPageBtn")
    GUI.SetScale(upPageBtn, Vector3.New(-1, 1, 1))
    -- GUI.SetVisible(upPageBtn, false)
    -- GUI.SetVisible(nextPageBtn, false)

    GUI.RegisterUIEvent(nextPageBtn, UCE.PointerClick, "MythicalAnimalsLvUpUI", "OnArrowClick")
    GUI.RegisterUIEvent(upPageBtn, UCE.PointerClick, "MythicalAnimalsLvUpUI", "OnArrowClick")
end
function MythicalAnimalsLvUpUI.OnOldSkillClick()
    local detailinfo = MythicalAnimalsUI.GetDetailsData(data.animal_name)
    if detailinfo ~= nil and detailinfo.NowSkill ~= nil and detailinfo.NowSkill ~= "" then
        local skillDB = DB.GetOnceSkillByKey2(detailinfo.NowSkill)
        if skillDB.Id > 0 then
            Tips.CreateSkillId(skillDB.Id, guidt.GetUI("panelBg"), "tip", 0, 0, 350)
        end
    end
end
function MythicalAnimalsLvUpUI.OnSkillClick()
    local detailinfo = MythicalAnimalsUI.GetDetailsData(data.animal_name)
    if detailinfo ~= nil and detailinfo.NextSkill ~= nil and detailinfo.NextSkill ~= "" then
        local skillDB = DB.GetOnceSkillByKey2(detailinfo.NextSkill)
        if skillDB.Id > 0 then
            Tips.CreateSkillId(skillDB.Id, guidt.GetUI("panelBg"), "tip", 0, 0, 350)
        end
    end
end
function MythicalAnimalsLvUpUI.OnUpdateBtnClick()
    local info = MythicalAnimalsUI.GetInfo(MythicalAnimalsUI.GetIndex(data.animal_name))
    if info.Level == info.MaxLevel then
        CL.SendNotify(NOTIFY.ShowBBMsg, "已升至最高等级")
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormGodAnimal", "LevelUp", data.animal_name)
    end
end
function MythicalAnimalsLvUpUI.CreateAttrItem()
    local scroll = guidt.GetUI("src")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)

    local item = GUI.GroupCreate(scroll, curCount, 0, 0, 0, 0)
    local attr = GUI.CreateStatic(item, "attr", "属性", 12, 0, 250, 30, "system", true)

    GUI.StaticSetFontSize(attr, UIDefine.FontSizeS)
    GUI.SetColor(attr, UIDefine.BrownColor)
    GUI.StaticSetAlignment(attr, TextAnchor.MiddleLeft)
    return item
end
function MythicalAnimalsLvUpUI.RefreshAttrItem(parameter)
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

    local text =
        "<color=#975c22>" ..
        data.nowattr[id].name .. "</color> <color=#08af00>" .. tmp[1] .. "->" .. tmp[2] .. "</color>"
    local group = GUI.GetByGuid(guid)
    local attr = GUI.GetChild(group, "attr", false)
    GUI.StaticSetText(attr, text)
    -- Tips.RegisterAttrHintEvent(label,"MythicalAnimalsLvUpUI")
end
function MythicalAnimalsLvUpUI.OnHintBtnClick()
    Tips.CreateHint(
        MythicalAnimalsUI.GetDetailsData(data.animal_name).Tips,
        guidt.GetUI("panelBg"),
        0,
        0,
        UILayout.Center
    )
end
function MythicalAnimalsLvUpUI.OnShow(parameter)
    local wnd = GUI.GetWnd("MythicalAnimalsLvUpUI")
    if wnd == nil then
        return
    end

    GUI.SetVisible(wnd, true)
    MythicalAnimalsLvUpUI.GetDate(parameter)
end
function MythicalAnimalsLvUpUI.OnDestroy()
    MythicalAnimalsLvUpUI.OnClose()
end
function MythicalAnimalsLvUpUI.OnClose()
    local wnd = GUI.GetWnd("MythicalAnimalsLvUpUI")
    GUI.SetVisible(wnd, false)
end
function MythicalAnimalsLvUpUI.GetDate(parameter)
    if MythicalAnimalsUI == nil then
        print("not found MythicalAnimalsUI")
        return
    end
    local wnd = GUI.GetWnd("MythicalAnimalsLvUpUI")
    if wnd == nil or GUI.GetVisible(wnd) == false then
        return
    end
    if parameter then
        data.animal_name = parameter
    end
    local detailinfo = MythicalAnimalsUI.GetDetailsData(data.animal_name)
    if detailinfo == nil then
        print("MythicalAnimalsLvUpUI not found Details " .. data.animal_name)
        return
    end
    detailinfo.NowBuff = detailinfo.NowBuff or {}
    detailinfo.NextBuff = detailinfo.NextBuff or detailinfo.NowBuff
    detailinfo.NowSkill = detailinfo.NowSkill or ""
    detailinfo.NextSkill = detailinfo.NextSkill or detailinfo.NowSkill
    data.nowattr, data.nextattr, data.attrId =
        LogicDefine.LvUpAttrChangeServer2Client(detailinfo.NowBuff, detailinfo.NextBuff)
    MythicalAnimalsLvUpUI.ClientRefresh()
end
function MythicalAnimalsLvUpUI.Refresh()
    MythicalAnimalsLvUpUI.ClientRefresh()
end
function MythicalAnimalsLvUpUI.ClientRefresh()
    MythicalAnimalsLvUpUI.RefreshUI()
end
function MythicalAnimalsLvUpUI.RefreshUI()
    local detailinfo = MythicalAnimalsUI.GetDetailsData(data.animal_name)
    local info = MythicalAnimalsUI.GetInfo(MythicalAnimalsUI.GetIndex(data.animal_name))
    GUI.StaticSetText(guidt.GetUI("title"), data.animal_name)
    ModelItem.Bind(guidt.GetUI("rolemodel"), detailinfo.Model, nil, nil, eRoleMovement.STAND_W1)
    GUI.ImageSetImageID(guidt.GetUI("flag"), UIDefine.ItemSSR[info.Grade])
    GUI.AddToCamera(guidt.GetUI("model"))

    UILayout.RefreshAttrBar(guidt.GetUI("rankBar"), nil, detailinfo.Score)

    local starBg = guidt.GetUI("starBg")
    for i = 1, 6 do
        local tmp = GUI.GetChild(starBg, i, false)
        if i <= info.MaxLevel then
            GUI.SetVisible(tmp, true)
        else
            GUI.SetVisible(tmp, false)
        end
        if i <= info.Level then
            GUI.ImageSetImageID(tmp, starImage)
        else
            GUI.ImageSetImageID(tmp, GrayStarImage)
        end
    end
    local max = guidt.GetUI("max")
    local slider = guidt.GetUI("slider")
    local sliderValue = guidt.GetUI("sliderValue")
    if info.Level == info.MaxLevel then
        GUI.SetVisible(max, true)
        GUI.SetImageFillAmount(slider, 1)
        GUI.SetVisible(sliderValue, false)
    else
        GUI.SetVisible(max, false)
        GUI.SetVisible(sliderValue, true)
        GUI.SetImageFillAmount(slider, info.HasItemNum / info.NeedItemNum)
        GUI.StaticSetText(sliderValue, info.HasItemNum .. "/" .. info.NeedItemNum)
    end

    ItemIcon.BindItemId(guidt.GetUI("itemicon"), info.NeedItemId)
    ItemIcon.BindSkillKeyName(guidt.GetUI("oldSkill"), detailinfo.NowSkill)
    if detailinfo.NowSkill and detailinfo.NowSkill ~= nil and detailinfo.NowSkill ~= "" then
        GUI.ItemCtrlSetElementValue(guidt.GetUI("oldSkill"), eItemIconElement.RightBottomNum, info.Level)
        GUI.ItemCtrlSetElementRect(guidt.GetUI("oldSkill"), eItemIconElement.RightBottomNum, 5, 5, 100, 25)
        GUI.SetVisible(GUI.ItemCtrlGetElement(guidt.GetUI("oldSkill"), eItemIconElement.RightBottomNum), true)
    end
    ItemIcon.BindSkillKeyName(guidt.GetUI("skill"), detailinfo.NextSkill)
    if detailinfo.NextSkill and detailinfo.NextSkill ~= nil and detailinfo.NextSkill ~= "" then
        GUI.ItemCtrlSetElementValue(
            guidt.GetUI("skill"),
            eItemIconElement.RightBottomNum,
            math.min(info.Level + 1, info.MaxLevel)
        )
        GUI.ItemCtrlSetElementRect(guidt.GetUI("skill"), eItemIconElement.RightBottomNum, 5, 5, 100, 25)
        GUI.SetVisible(GUI.ItemCtrlGetElement(guidt.GetUI("skill"), eItemIconElement.RightBottomNum), true)
    end

    local src = guidt.GetUI("src")
    GUI.LoopScrollRectSetTotalCount(src, #data.attrId)
    GUI.LoopScrollRectRefreshCells(src)
    local left = guidt.GetUI("upPageBtn")
    local right= guidt.GetUI("nextPageBtn")
    local index = MythicalAnimalsUI.GetDataIndex(data.animal_name)
    if index<=1 then
        GUI.ButtonSetShowDisable(left,false)
    else
        GUI.ButtonSetShowDisable(left, true)
    end
    if index>=MythicalAnimalsUI.GetDataCnt() then
        GUI.ButtonSetShowDisable(right,false)
    else
        GUI.ButtonSetShowDisable(right,true)
    end
end
function MythicalAnimalsLvUpUI.OnArrowClick(guid)
    local parameter = nil
    local index = 1
    if guid == guidt.GetGuid("nextPageBtn") then
        index = MythicalAnimalsUI.GetDataIndex(data.animal_name) + 1
    elseif guid == guidt.GetGuid("upPageBtn") then
        index = MythicalAnimalsUI.GetDataIndex(data.animal_name) - 1
    end
    parameter = MythicalAnimalsUI.GetDataName(index)
    MythicalAnimalsUI.RequestDetailsData(parameter)
end
