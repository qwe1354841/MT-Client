local ShowAttributeUI = {}

_G.ShowAttributeUI = ShowAttributeUI
local GuidCacheUtil = nil -- UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local roleAttrList = {}

function ShowAttributeUI.Main()
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("ShowAttributeUI", "ShowAttributeUI", 0, 0)
end

function ShowAttributeUI.OnShow()
    GUI.SetVisible(GUI.GetWnd("ShowAttributeUI"), true)
end

function ShowAttributeUI.RefreshAttributeUI(attrList, titleTxt)
    titleTxt = titleTxt or "属性列表"
    roleAttrList = attrList or LogicDefine.GetSelfAttrTable()
    local name = "attributeListBG"
    local attributeListBG = GuidCacheUtil.GetUI(name)
    local attrScroll = nil
    if not attributeListBG then
        local page1 = GUI.GetWnd("ShowAttributeUI")
        local attributeListBG =
            GUI.ImageCreate(page1, name, "1800400220", 0, 0, false, GUI.GetWidth(page1), GUI.GetHeight(page1))
        GuidCacheUtil.BindName(attributeListBG, name)
        SetAnchorAndPivot(attributeListBG, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(attributeListBG, Color.New(0, 0, 0, 0))
        GUI.SetIsRaycastTarget(attributeListBG, true)
        GUI.SetDepth(attributeListBG, 100)
        attributeListBG:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(attributeListBG, UCE.PointerClick, "ShowAttributeUI", "OnCloseBtnClick")
        local panelCover = GUI.ImageCreate(attributeListBG, "panelCover", "1800001200", 0, 17, false, 525, 549)
        SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetIsRaycastTarget(panelCover, true)
        local closeBtn =
            GUI.ButtonCreate(panelCover, "closeBtn", "1800002050", 232, -248, Transition.ColorTint, "", 30, 30, false)
        ShowAttributeUI.SetButtonBasicInfo(closeBtn, "OnCloseBtnClick", 24, nil, UIAnchor.Center, UIAroundPivot.Center)
        local titleBg = GUI.ImageCreate(panelCover, "titleBg", "1800100070", 0, -250, false, 315, 40)
        local title = GUI.CreateStatic(titleBg, "title", titleTxt, 0, 0, 200, 40, "system", true, false)
        ShowAttributeUI.SetTextBasicInfo(
            title,
            UIDefine.WhiteColor,
            TextAnchor.MiddleCenter,
            UIDefine.FontSizeXL,
            UIAnchor.Center,
            UIAroundPivot.Center
        )
        attrScroll =
            GUI.LoopListCreate(
            panelCover,
            "attrScroll",
            0,
            15,
            345,
            465,
            "ShowAttributeUI",
            "CreateAttrItem",
            "ShowAttributeUI",
            "OnRefreshAttrScroll",
            0,
            false,
            Vector2.New(0, 0),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top
        )
        GuidCacheUtil.BindName(attrScroll, "attrScroll")
        GuidCacheUtil.BindName(title, "title")
    else
        attrScroll = GuidCacheUtil.GetUI("attrScroll")
        GUI.SetVisible(attributeListBG, true)
        local title = GuidCacheUtil.GetUI("title")
        GUI.StaticSetText(title, titleTxt)
    end
    GUI.LoopScrollRectSetTotalCount(attrScroll, #roleAttrList)
    GUI.LoopScrollRectRefreshCells(attrScroll)
end

function ShowAttributeUI.SetButtonBasicInfo(btn, functionName, fontSize, btnColor, uiAnchor, pivot)
    if not btn then
        return
    end
    SetAnchorAndPivot(btn, uiAnchor or UIAnchor.Center, pivot or UIAroundPivot.Center)
    GUI.ButtonSetTextFontSize(btn, fontSize or UIDefine.FontSizeS)
    GUI.ButtonSetTextColor(btn, btnColor or UIDefine.BrownColor)
    if functionName then
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "ShowAttributeUI", functionName)
    end
end

function ShowAttributeUI.SetTextBasicInfo(txt, color, alignment, txtSize, uiAnchor, pivot)
    if not txt then
        return
    end
    SetAnchorAndPivot(txt, uiAnchor or UIAnchor.Center, pivot or UIAroundPivot.Center)
    GUI.StaticSetFontSize(txt, txtSize or UIDefine.FontSizeS)
    if color then
        GUI.SetColor(txt, color)
    end
    GUI.StaticSetAlignment(txt, alignment or TextAnchor.MiddleLeft)
end

function ShowAttributeUI.OnCloseBtnClick()
    GUI.CloseWnd("ShowAttributeUI")
end

local attrItemWidth = 350
local attrItemHeightL = 40
local attrItemHeightM = 28
function ShowAttributeUI.CreateAttrItem()
    local attrScroll = GuidCacheUtil.GetUI("attrScroll")
    local attrItem = GUI.GroupCreate(attrScroll, "attrItem", 0, 0, 0, 0)
    local typeNameText = GUI.CreateStatic(attrItem, "typeNameText", "属性分类", 0, 0, attrItemWidth, attrItemHeightL)
    GUI.SetColor(typeNameText, UIDefine.Yellow3Color)
    GUI.StaticSetFontSize(typeNameText, UIDefine.FontSizeXL)
    GUI.StaticSetAlignment(typeNameText, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(typeNameText, UILayout.Center)

    local left = GUI.ImageCreate(typeNameText, "left", "1800800050", -10, 0, false, 120, 10)
    UILayout.SetSameAnchorAndPivot(left, UILayout.Left)
    local right = GUI.ImageCreate(typeNameText, "right", "1800800060", 10, 0, false, 120, 10)
    UILayout.SetSameAnchorAndPivot(right, UILayout.Right)

    local attrNameText = GUI.CreateStatic(attrItem, "attrNameText", "属性名称", 15, 0, attrItemWidth / 2, attrItemHeightM)
    GUI.SetColor(attrNameText, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(attrNameText, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(attrNameText, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(attrNameText, UILayout.Left)
    Tips.RegisterAttrHintEvent(attrNameText, "ShowAttributeUI")

    local attrValueText = GUI.CreateStatic(attrItem, "attrValueText", "0", -15, 0, attrItemWidth / 2, attrItemHeightM)
    GUI.SetColor(attrValueText, UIDefine.Green3Color)
    GUI.StaticSetFontSize(attrValueText, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(attrValueText, TextAnchor.MiddleRight)
    UILayout.SetSameAnchorAndPivot(attrValueText, UILayout.Right)
    return attrItem
end

function ShowAttributeUI.OnRefreshAttrScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local attrItem = GUI.GetByGuid(guid)
    index = index + 1

    local attrData = roleAttrList[index]
    if attrData == nil then
        GUI.SetVisible(attrItem, false)
        return
    end

    local typeNameText = GUI.GetChild(attrItem, "typeNameText")
    local attrNameText = GUI.GetChild(attrItem, "attrNameText")
    local attrValueText = GUI.GetChild(attrItem, "attrValueText")

    if not attrData.Name then
        GUI.SetVisible(typeNameText, true)
        GUI.SetVisible(attrNameText, false)
        GUI.SetVisible(attrValueText, false)

        GUI.StaticSetText(typeNameText, attrData.ChinaName)
        GUI.SetPreferredHeight(attrItem, attrItemHeightL)
    else
        GUI.SetVisible(typeNameText, false)
        GUI.SetVisible(attrNameText, true)
        GUI.SetVisible(attrValueText, true)

        GUI.StaticSetText(attrNameText, attrData.ChinaName)
        local value = attrData.Value
        if attrData.IsPct == 1 or attrData.IsPct == true then
            value = tostring(tonumber(value) / 100) .. "%"
        end
        GUI.StaticSetText(attrValueText, value)
        GUI.SetPreferredHeight(attrItem, attrItemHeightM)
    end

    GUI.SetPreferredWidth(attrItem, attrItemWidth)
end
