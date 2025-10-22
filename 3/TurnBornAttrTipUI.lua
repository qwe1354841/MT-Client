local TurnBornAttrTipUI = {}

_G.TurnBornAttrTipUI = TurnBornAttrTipUI
local GuidCacheUtil = nil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local sizeDefault = UIDefine.FontSizeS
local colorDark = UIDefine.BrownColor

local roleAttrList = {}

function TurnBornAttrTipUI.Main(parameter)
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("TurnBornAttrTipUI", "TurnBornAttrTipUI", 0, 0, eCanvasGroup.Normal)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)
    local name = "attributeListBG"
    local attributeListBG = GUI.ImageCreate(panel, name, "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    GuidCacheUtil.BindName(attributeListBG, name)
    SetAnchorAndPivot(attributeListBG, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(attributeListBG, Color.New(0, 0, 0, 0))
    GUI.SetIsRaycastTarget(attributeListBG, true)
    GUI.SetDepth(attributeListBG, 100)
    attributeListBG:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(attributeListBG, UCE.PointerClick, "TurnBornAttrTipUI", "OnCloseAttributeListPanel")
    local panelCover = GUI.ImageCreate(attributeListBG, "panelCover", "1800001200", 0, 17, false, 525, 549)
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    local closeBtn = GUI.ButtonCreate(panelCover, "closeBtn", "1800002050", 232, -248, Transition.ColorTint, "", 30, 30, false)
    TurnBornAttrTipUI.SetButtonBasicInfo(closeBtn, "OnCloseAttributeListPanel", 24, ButtonStairColor_2, UIAnchor.Center, UIAroundPivot.Center)
    local titleBg = GUI.ImageCreate(panelCover, "titleBg", "1800100070", 0, -250, false, 315, 40)
    local title = GUI.CreateStatic(titleBg, "title", "转生修正", 0, 0, 150, 40, "system", true, false)
    TurnBornAttrTipUI.SetTextBasicInfo(title, UIDefine.WhiteColor, TextAnchor.MiddleCenter, UIDefine.FontSizeXL, UIAnchor.Center, UIAroundPivot.Center)
    local attrScroll = GUI.LoopListCreate(panelCover, "attrScroll", 0, -8, 420, 420, "TurnBornAttrTipUI", "CreateAttrItem", "TurnBornAttrTipUI", "OnRefreshAttrScroll", 0, false, Vector2.New(0, 0), 1, UIAroundPivot.Top, UIAnchor.Top)
    GuidCacheUtil.BindName(attrScroll, "attrScroll")

    local msgTxt = GUI.RichEditCreate(panelCover, "msgTxt", "可以在孟婆处更改转生修正（#NPCLINK<STR:点击前往,NPCID:10266>#）", 0, 235, 400, 35)
    GUI.SetSpriteMaxHeight(msgTxt, 25)
    --SetAnchorAndPivot(msgTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(msgTxt, UIDefine.FontSizeM)
    msgTxt:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(msgTxt, UCE.PointerClick, "TurnBornAttrTipUI", "OnClickMoveToNpc")
end

function TurnBornAttrTipUI.OnShow()
    CL.SendNotify(NOTIFY.SubmitForm, "FormReincarnation", "GetData")
    GUI.SetVisible(GUI.GetWnd("TurnBornAttrTipUI"), true)
end

local attrItemWidth = 350
local attrItemHeightL = 40
local attrItemHeightM = 28
function TurnBornAttrTipUI.CreateAttrItem()
    local attrScroll = GuidCacheUtil.GetUI("attrScroll")
    local attrItem = GUI.GroupCreate(attrScroll, "attrItem", 0, 0, 0, 0)
    local attrTypeBG = GUI.ImageCreate(attrItem, "attrTypeBG", "1800200030", 0, 0, false, attrItemWidth, attrItemHeightL)
    local typeNameText = GUI.CreateStatic(attrItem, "typeNameText", "属性分类", 0, 0, attrItemWidth, attrItemHeightL)
    GUI.SetColor(typeNameText, UIDefine.Yellow3Color)
    GUI.StaticSetFontSize(typeNameText, UIDefine.FontSizeXL)
    GUI.StaticSetAlignment(typeNameText, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(typeNameText, UILayout.Center)

    local left = GUI.ImageCreate(typeNameText, "left", "1800800050", -75, 0, false, 120, 10)
    UILayout.SetSameAnchorAndPivot(left, UILayout.Left)
    local right = GUI.ImageCreate(typeNameText, "right", "1800800060", 75, 0, false, 120, 10)
    UILayout.SetSameAnchorAndPivot(right, UILayout.Right)

    local attrNameText = GUI.CreateStatic(attrItem, "attrNameText", "属性名称", 15, 0, attrItemWidth / 2, attrItemHeightM)
    GUI.SetColor(attrNameText, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(attrNameText, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(attrNameText, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(attrNameText, UILayout.Left)
    Tips.RegisterAttrHintEvent(attrNameText,"TurnBornAttrTipUI")

    local attrValueText = GUI.CreateStatic(attrItem, "attrValueText", "0", -15, 0, attrItemWidth / 2, attrItemHeightM)
    GUI.SetColor(attrValueText, UIDefine.Green3Color)
    GUI.StaticSetFontSize(attrValueText, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(attrValueText, TextAnchor.MiddleRight)
    UILayout.SetSameAnchorAndPivot(attrValueText, UILayout.Right)
    return attrItem
end

function TurnBornAttrTipUI.OnRefreshAttrScroll(parameter)
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

    local attrTypeBG = GUI.GetChild(attrItem, "attrTypeBG")
    local typeNameText = GUI.GetChild(attrItem, "typeNameText")
    local attrNameText = GUI.GetChild(attrItem, "attrNameText")
    local attrValueText = GUI.GetChild(attrItem, "attrValueText")

    if not attrData.Name then
        GUI.SetVisible(attrTypeBG, true)
        GUI.SetVisible(typeNameText, true)
        GUI.SetVisible(attrNameText, false)
        GUI.SetVisible(attrValueText, false)

        GUI.StaticSetText(typeNameText, attrData.ChinaName)
        GUI.SetPreferredHeight(attrItem, attrItemHeightL)
    else
        GUI.SetVisible(attrTypeBG, false)
        GUI.SetVisible(typeNameText, false)
        GUI.SetVisible(attrNameText, true)
        GUI.SetVisible(attrValueText, true)

        GUI.StaticSetText(attrNameText, attrData.ChinaName)
        local value = attrData.Value
        if attrData.IsPct == 1 then
            value = tostring(tonumber(value) / 100) .. "%"
        end
        GUI.StaticSetText(attrValueText, value)
        GUI.SetPreferredHeight(attrItem, attrItemHeightM)
    end

    GUI.SetPreferredWidth(attrItem, attrItemWidth)
end

function TurnBornAttrTipUI.RefreshAttrList(t)
    local inspect = require("inspect")
    print(inspect(t))
    local attrScroll = GuidCacheUtil.GetUI("attrScroll")
    GUI.LoopScrollRectSetTotalCount(attrScroll, #t)
    GUI.LoopScrollRectRefreshCells(attrScroll)
end

function TurnBornAttrTipUI.SetTextBasicInfo(txt, color, alignment, txtSize, uiAnchor, pivot)
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

function TurnBornAttrTipUI.SetSliderBasicInfo(Slider, size, uiAnchor, pivot)
    if not Slider then
        return
    end
    GUI.ScrollBarSetFillSize(Slider, size) -- size参数不能为空
    GUI.ScrollBarSetBgSize(Slider, size)
    SetAnchorAndPivot(Slider, uiAnchor or UIAnchor.Center, pivot or UIAroundPivot.Left)
end

function TurnBornAttrTipUI.SetButtonBasicInfo(btn, functionName, fontSize, btnColor, uiAnchor, pivot)
    if not btn then
        return
    end
    SetAnchorAndPivot(btn, uiAnchor or UIAnchor.Center, pivot or UIAroundPivot.Center)
    GUI.ButtonSetTextFontSize(btn, fontSize or sizeDefault)
    GUI.ButtonSetTextColor(btn, btnColor or colorDark)
    if functionName then
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "TurnBornAttrTipUI", functionName)
    end
end

function TurnBornAttrTipUI.OnCloseAttributeListPanel(guid)
    GUI.CloseWnd("TurnBornAttrTipUI")
    --local attributeListBG = GuidCacheUtil.GetUI("attributeListBG")
    --if attributeListBG then
    --    GUI.SetVisible(attributeListBG, false)
    --end
end

function TurnBornAttrTipUI.OnClickMoveToNpc()
    if RoleAttributeUI then
        RoleAttributeUI.StartAutoMove(10266)
    end
    TurnBornAttrTipUI.OnCloseAttributeListPanel()
end

local NumberCN = {"一", "二", "三", "四", "五", "六", "七", "八", "九"}
function TurnBornAttrTipUI.GetData(t)
    if not GUI.GetVisible(GUI.GetWnd("TurnBornAttrTipUI")) then
        return
    end
    local inspect = require("inspect")
    print(inspect(t))
    local count = REINCARNATION_DATA.Reincarnation_Count or 0
    roleAttrList = {}
    for i = 1, count do
        local name = NumberCN[i] .. "转修正"
        local id = t[i]
        if id then
            local roleConfig = DB.GetRole(id)
            roleAttrList[#roleAttrList + 1] = {ChinaName = name .. "（" .. roleConfig.RoleName .. "）"} -- {Name = attrName, ChinaName = attrChinaName, Value = value, IsPct = isPct}
            local attrs = REINCARNATION_DATA["Reincarnation_" .. i]["Role_" .. id]
            for j = 1, #attrs do
                local data = attrs[j]
                local attrDB = DB.GetOnceAttrByKey2(data[1])
                roleAttrList[#roleAttrList + 1] = {Name = attrDB.Name, ChinaName = attrDB.ChinaName, Value = data[2], IsPct = attrDB.IsPct}
            end
        else
            roleAttrList[#roleAttrList + 1] = {ChinaName = name .. "（未转生）"}
            roleAttrList[#roleAttrList + 1] = {Name = " ", ChinaName = " ", Value = " ", IsPct = 0}
        end
    end
    local attrScroll = GuidCacheUtil.GetUI("attrScroll")
    GUI.LoopScrollRectSetTotalCount(attrScroll, #roleAttrList)
    GUI.LoopScrollRectRefreshCells(attrScroll)
end