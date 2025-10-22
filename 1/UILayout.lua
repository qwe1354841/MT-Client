local UILayout = {}
_G.UILayout = UILayout
require "LuaTool"
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local SetAnchor = GUI.SetAnchor
local SetPivot = GUI.SetPivot
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local UIDefine = UIDefine
local Transition = Transition
local UCE = UCE
local ULE = ULE
local TOOLKIT = TOOLKIT
local Vector3 = Vector3
local math = math
local test = print
------------------------------------ end缓存一下全局变量end --------------------------------

--创建通用外框--通用界面样式
---@public
---@param wnd table
---@param title string
---@param scriptName string
---@param closeMethod string
---@param _gt table 记录动态的UIElement，默认可以没有
---@return table
function UILayout.CreateFrame_WndStyle0(wnd, title, scriptName, closeMethod, _gt)
    local panelCover =
        GUI.ImageCreate(wnd, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    -- panelCover:RegisterEvent(UCE.PointerClick)
    if CL.IsInGame() then
        require "MoneyBar"
    end
    MoneyBar.CreateDefault(panelCover, scriptName)
    local panelBg = GUI.GroupCreate(wnd, "panelBg", 0, 33, 1197, 660)
    UILayout.SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)

    local bg = GUI.ImageCreate(panelBg, "bg", "1801300240", 0, -10, false, 1197, 660)
    UILayout.SetAnchorAndPivot(bg, UIAnchor.Center, UIAroundPivot.Center)
    local upBgCoverLeft = GUI.ImageCreate(panelBg, "upBgCoverLeft", "1801300020", -321, -303)
    UILayout.SetAnchorAndPivot(upBgCoverLeft, UIAnchor.Center, UIAroundPivot.Center)
    local upBgCoverRight = GUI.ImageCreate(panelBg, "upBgCoverRight", "1801300020", 321, -303)
    UILayout.SetAnchorAndPivot(upBgCoverRight, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetScale(upBgCoverRight, Vector3.New(-1, 1, 1))

    local titleBg = GUI.ImageCreate(panelBg, "titleBg", "1801300010", 0, 12)
    UILayout.SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Center)

    local pendant = GUI.ImageCreate(panelBg, "pendant", "1801305040", -560, -218)
    UILayout.SetAnchorAndPivot(pendant, UIAnchor.Center, UIAroundPivot.Center)

    local tabList = GUI.GroupCreate(panelBg, "tabList", -36, -5, 1, 1)
    UILayout.SetAnchorAndPivot(tabList, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetVisible(tabList, false)

    local titleText = GUI.CreateStatic(titleBg, "titleText", title, 0, 6, 250, 40, "system", false, false)
    UILayout.SetAnchorAndPivot(titleText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(titleText, UIDefine.FontSizeXXL)
    GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter)
    GUI.SetColor(titleText, UIDefine.BrownColor)

    local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1801302020", 544, -295, Transition.ColorTint)
    UILayout.SetAnchorAndPivot(closeBtn, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.SetDepth(closeBtn, GUI.GetDepth(closeBtn) + 1000)
    if scriptName ~= nil and closeMethod ~= nil then
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, scriptName, closeMethod)
    end
    if _gt then -- 不传默认没有
        _gt.BindName(panelCover, "panelCover")
        _gt.BindName(panelBg, "panelBg")
        _gt.BindName(titleText, "titleText")
    end
    return panelBg
end

function UILayout.CreateFrame_WndStyle0_WithoutCloseBtn(wnd, title, scriptName, _gt)
    local panelCover =
    GUI.ImageCreate(wnd, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    -- panelCover:RegisterEvent(UCE.PointerClick)
    if CL.IsInGame() then
        require "MoneyBar"
    end
    MoneyBar.CreateDefault(panelCover, scriptName)
    local panelBg = GUI.GroupCreate(wnd, "panelBg", 0, 33, 1197, 660)
    UILayout.SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)

    local bg = GUI.ImageCreate(panelBg, "bg", "1801300240", 0, -10, false, 1197, 660)
    UILayout.SetAnchorAndPivot(bg, UIAnchor.Center, UIAroundPivot.Center)
    local upBgCoverLeft = GUI.ImageCreate(panelBg, "upBgCoverLeft", "1801300020", -321, -303)
    UILayout.SetAnchorAndPivot(upBgCoverLeft, UIAnchor.Center, UIAroundPivot.Center)
    local upBgCoverRight = GUI.ImageCreate(panelBg, "upBgCoverRight", "1801300020", 321, -303)
    UILayout.SetAnchorAndPivot(upBgCoverRight, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetScale(upBgCoverRight, Vector3.New(-1, 1, 1))

    local titleBg = GUI.ImageCreate(panelBg, "titleBg", "1801300010", 0, 12)
    UILayout.SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Center)

    local pendant = GUI.ImageCreate(panelBg, "pendant", "1801305040", -560, -218)
    UILayout.SetAnchorAndPivot(pendant, UIAnchor.Center, UIAroundPivot.Center)

    local tabList = GUI.GroupCreate(panelBg, "tabList", -36, -5, 1, 1)
    UILayout.SetAnchorAndPivot(tabList, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetVisible(tabList, false)

    local titleText = GUI.CreateStatic(titleBg, "titleText", title, 0, 6, 250, 40, "system", false, false)
    UILayout.SetAnchorAndPivot(titleText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(titleText, UIDefine.FontSizeXXL)
    GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter)
    GUI.SetColor(titleText, UIDefine.BrownColor)

    --local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1801302020", 544, -295, Transition.ColorTint)
    --UILayout.SetAnchorAndPivot(closeBtn, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.SetDepth(closeBtn, GUI.GetDepth(closeBtn) + 1000)
    --if scriptName ~= nil and closeMethod ~= nil then
    --    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, scriptName, closeMethod)
    --end
    if _gt then -- 不传默认没有
        _gt.BindName(panelCover, "panelCover")
        _gt.BindName(panelBg, "panelBg")
        _gt.BindName(titleText, "titleText")
    end
    return panelBg
end

function UILayout.CreateFrame_WndStyle0_WithoutCover(wnd, title, scriptName, closeMethod, _gt)
    local panelBg = GUI.GroupCreate(wnd, "panelBg", 0, 33, 1197, 660)
    UILayout.SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)

    local bg = GUI.ImageCreate(panelBg, "bg", "1801300240", 0, -10, false, 1197, 660)
    UILayout.SetAnchorAndPivot(bg, UIAnchor.Center, UIAroundPivot.Center)
    local upBgCoverLeft = GUI.ImageCreate(panelBg, "upBgCoverLeft", "1801300020", -321, -303)
    UILayout.SetAnchorAndPivot(upBgCoverLeft, UIAnchor.Center, UIAroundPivot.Center)
    local upBgCoverRight = GUI.ImageCreate(panelBg, "upBgCoverRight", "1801300020", 321, -303)
    UILayout.SetAnchorAndPivot(upBgCoverRight, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetScale(upBgCoverRight, Vector3.New(-1, 1, 1))

    local titleBg = GUI.ImageCreate(panelBg, "titleBg", "1801300010", 0, 12)
    UILayout.SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Center)

    local pendant = GUI.ImageCreate(panelBg, "pendant", "1801305040", -560, -218)
    UILayout.SetAnchorAndPivot(pendant, UIAnchor.Center, UIAroundPivot.Center)

    local tabList = GUI.GroupCreate(panelBg, "tabList", -36, -5, 1, 1)
    UILayout.SetAnchorAndPivot(tabList, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetVisible(tabList, false)

    local titleText = GUI.CreateStatic(titleBg, "titleText", title, 0, 6, 250, 40, "system", false, false)
    UILayout.SetAnchorAndPivot(titleText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(titleText, UIDefine.FontSizeXXL)
    GUI.StaticSetAlignment(titleText, TextAnchor.MiddleCenter)
    GUI.SetColor(titleText, UIDefine.BrownColor)

    local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1801302020", 544, -295, Transition.ColorTint)
    UILayout.SetAnchorAndPivot(closeBtn, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.SetDepth(closeBtn, GUI.GetDepth(closeBtn) + 1000)
    if scriptName ~= nil and closeMethod ~= nil then
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, scriptName, closeMethod)
    end
    if _gt then -- 不传默认没有
        _gt.BindName(panelCover, "panelCover")
        _gt.BindName(panelBg, "panelBg")
        _gt.BindName(titleText, "titleText")
    end
    return panelBg
end

--创建通用外框--通用窗口样式
function UILayout.CreateFrame_WndStyle1(
    Name,
    parent,
    Posx,
    Posy,
    Width,
    Height,
    scriptName,
    method1,
    method2,
    defVisableFalse)
    local group = GUI.GroupCreate(parent, Name, Posx, Posy, Width, Height)
    UILayout.SetAnchorAndPivot(group, UIAnchor.Center, UIAroundPivot.Center)
    -- group:RegisterEvent(UCE.PointerClick)

    if defVisableFalse ~= nil then
        GUI.SetVisible(group, false)
    end

    local upBg = GUI.ImageCreate(group, "upBackgroundImage", "1800400710", Posx, 0, false, Width, Height / 2)
    UILayout.SetAnchorAndPivot(upBg, UIAnchor.Center, UIAroundPivot.Bottom)
    local bottomBg = GUI.ImageCreate(group, "bottomBackgroundImage", "1800400720", Posx, -1, false, Width, Height / 2)
    UILayout.SetAnchorAndPivot(bottomBg, UIAnchor.Center, UIAroundPivot.Top)

    if scriptName ~= nil then
        if method1 ~= nil then
            GUI.RegisterUIEvent(upBg, ULE.CreateFinsh, scriptName, method1)
        end
        if method2 ~= nil then
            GUI.RegisterUIEvent(bottomBg, ULE.CreateFinsh, scriptName, method2)
        end
    end

    -- bottomBg:RegisterEvent(UCE.PointerClick)
    -- upBg:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(bottomBg, true)
    GUI.SetIsRaycastTarget(upBg, true)
    return group
end

--创建通用外框--通用界面样式2
function UILayout.CreateFrame_WndStyle2(panel, title, w, h, scriptName, closeMethod, _gt, withMoneyBar)
    local panelCover =
        GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    -- panelCover:RegisterEvent(UCE.PointerClick)
    if withMoneyBar == true then
        if CL.IsInGame() then
            require "MoneyBar"
        end
        MoneyBar.CreateDefault(panelCover, scriptName)
    end

    local panelBg = UILayout.CreateFrame_WndStyle2_WithoutCover(panel, title, w, h, scriptName, closeMethod, _gt)
    if _gt then -- 不传默认没有
        _gt.BindName(panelCover, "panelCover")
    end
    return panelBg
end

--创建通用外框--通用界面样式2 不带panelCover
function UILayout.CreateFrame_WndStyle2_WithoutCover(panel, title, w, h, scriptName, closeMethod, _gt)
    local panelBg = GUI.GroupCreate(panel, "panelBg", 0, 0, w, h)
    UILayout.SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)

    local center = GUI.ImageCreate(panelBg, "center", "1800600182", 0, 0, false, w, h - 54)
    UILayout.SetAnchorAndPivot(center, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local topBar = GUI.ImageCreate(panelBg, "topBar", "1800600183", 0, 30, false, w, 54)
    UILayout.SetAnchorAndPivot(topBar, UIAnchor.Top, UIAroundPivot.Center)

    local topBarCenter = GUI.ImageCreate(panelBg, "topBarCenter", "1800600190", 0, 30, false, 270, 50)
    UILayout.SetAnchorAndPivot(topBarCenter, UIAnchor.Top, UIAroundPivot.Center)

    local tipLabel = GUI.CreateStatic(topBarCenter, "tipLabel", title, 0, 0, 200, 40)
    GUI.StaticSetAlignment(tipLabel, TextAnchor.MiddleCenter)
    GUI.SetColor(tipLabel, UIDefine.BrownColor)
    UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(tipLabel, UIDefine.FontSizeL)

    local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800302120", 0, 5, Transition.ColorTint)
    UILayout.SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    if scriptName ~= nil and closeMethod ~= nil then
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, scriptName, closeMethod)
    end
    if _gt then -- 不传默认没有
        _gt.BindName(panelBg, "panelBg")
    end
    return panelBg
end

--创建刷新右侧页签
--SetIndexData:默认不传，用于OnTabClick获得控件index进行页签切换使用
function UILayout.CreateRightTab(tabTable, wndName,SetIndexData)
	--增加一个传入wndname不为UI时
	local childPanel = ""
	if wndName then
		temp = string.split(wndName,"/")
		wndName = temp[1] or wndName
		if #temp > 1 then
			for i = 2 ,#temp do
				childPanel = childPanel.."/"..temp[i]
			end
		end
	end
    local parent = GUI.Get(wndName ..childPanel.. "/panelBg")
    local group = GUI.GetChild(parent, "tabList")
    if group == nil then
        test("can`t find tabList")
    end

    GUI.SetVisible(group, true)

    for i = 0, GUI.GetChildCount(group) - 1 do
        GUI.SetVisible(GUI.GetChildByIndex(group, i), false)
    end

    local count = 0
    for i = 1, #tabTable do
        if tabTable[i].hide ~= true then
            count = count + 1
        end
    end

    local bottomBg = GUI.GetChild(group, "bottomBg")
    if count > 0 then
        if bottomBg == nil then
            bottomBg = GUI.ImageCreate(group, "bottomBg", "1801305030", 0, count * 106 - 10)
            UILayout.SetAnchorAndPivot(bottomBg, UIAnchor.Top, UIAroundPivot.Top)
        else
            GUI.SetVisible(bottomBg, true)
            GUI.SetPositionY(bottomBg, count * 106 - 10)
        end
        GUI.SetDepth(bottomBg, 0)
    else
        GUI.SetVisible(bottomBg, false)
    end

    local depth = 1
    for i = #tabTable, 1, -1 do
        local data = tabTable[i]
        local toggle = GUI.GetByGuid(data.btnGuid)
        if data.hide ~= true then
            if toggle == nil then
                toggle =
                    GUI.CheckBoxCreate(
                    group,
                    data[2],
                    "1801302010",
                    "1801302011",
                    0,
                    count * 106 + 24,
                    Transition.ColorTint,
                    false
                )
                UILayout.SetAnchorAndPivot(toggle, UIAnchor.Top, UIAroundPivot.Top)
                if SetIndexData == true then
                    GUI.SetData(toggle,"ItemIndex",i)
                end
                GUI.RegisterUIEvent(toggle, UCE.PointerClick, wndName, data[3])
                tabTable[i].btnGuid = GUI.GetGuid(toggle)
                GUI.SetDepth(toggle, depth)

                local text = GUI.CreateStatic(toggle, "text", data[1], 1, 0, 30, 75, "system", true, false)
                UILayout.SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
                GUI.StaticSetFontSize(text, UIDefine.FontSizeXL)
                GUI.SetColor(text, UIDefine.White4Color)

                GUI.AddRedPoint(toggle, UIAnchor.TopRight, 22, -32)
                GUI.SetRedPointVisable(toggle, false)

                local intervalSp
                if count == 1 then
                    intervalSp = GUI.ImageCreate(toggle, "intervalSp", "1801305010", 0, -130, false, 17, 100)
                else
                    intervalSp = GUI.ImageCreate(toggle, "intervalSp", "1801305020", 0, -168, false, 17, 131)
                end
                UILayout.SetSameAnchorAndPivot(intervalSp, UILayout.Top)
            else
                GUI.SetVisible(toggle, true)
                GUI.SetDepth(toggle, depth)
                GUI.SetPositionY(toggle, count * 106 + 24)
                local intervalSp = GUI.GetChild(toggle, "intervalSp")
                local text = GUI.GetChild(toggle, "text")
                GUI.StaticSetText(text, data[1])
                if count == 1 then
                    GUI.ImageSetImageID(intervalSp, "1801305010")
                    GUI.SetPositionY(intervalSp, -130)
                    GUI.SetHeight(intervalSp, 100)
                else
                    GUI.ImageSetImageID(intervalSp, "1801305020")
                    GUI.SetPositionY(intervalSp, -168)
                    GUI.SetHeight(intervalSp, 131)
                end
            end
            count = count - 1
            depth = depth + 1
            if count == 0 then
                break
            end
        else
            GUI.SetVisible(toggle, false)
        end
    end
end

--点击右侧某个页签
function UILayout.OnTabClick(index, tablTable, isToggleOn)
    local isOn = false
    if isToggleOn == nil then
        isToggleOn = true
    end

    for i = 1, #tablTable do
        local toggle = GUI.GetByGuid(tablTable[i].btnGuid)
        if isToggleOn == false then
            GUI.CheckBoxSetCheck(toggle, false)
        end
        if i == index then
            isOn = true
        else
            isOn = false
        end
        GUI.CheckBoxSetCheck(toggle, isOn)
        local labelText = GUI.GetChild(toggle, "text")
        if labelText ~= nil then
            GUI.SetColor(labelText, isOn and UIDefine.BrownColor or UIDefine.White4Color)
        end
    end
end

--创建二级页签
function UILayout.CreateSubTab(subTabList, group, scriptName)
    GUI.SetIsToggleGroup(group, true)
    for i = 1, #subTabList do
        local data = subTabList[i]
        local subTab = GUI.GetChild(group, data[2], false)
        if subTab then
            local text = GUI.GetChild(subTab, "text", false)
            GUI.StaticSetText(text, data[1])
        else
            subTab = GUI.CheckBoxExCreate(group, data[2], data[3], data[4], data[6], data[7], false, data[8], data[9])
            UILayout.SetAnchorAndPivot(subTab, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetToggleGroupGuid(subTab, GUI.GetGuid(group))
            local text = GUI.CreateStatic(subTab, "text", data[1], 0, 0, data[10], data[11])
            UILayout.SetAnchorAndPivot(text, UIAnchor.Center, UIAroundPivot.Center)
            GUI.StaticSetFontSize(text, UIDefine.FontSizeL)
            GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)
            GUI.SetColor(text, UIDefine.BrownColor)
            if scriptName ~= nil then
                GUI.RegisterUIEvent(subTab, UCE.PointerClick, scriptName, data[5])
            end
            data.btnGuid = GUI.GetGuid(subTab)
        end
        GUI.SetVisible(subTab, data.hide ~= true)
    end
end
--清除二级页签ui事件
function UILayout.UnRegisterSubTabUIEvent(subTabList, scriptName)
    for i = 1, #subTabList do
        local data = subTabList[i]
        local subTab = GUI.GetByGuid(subTabList[i].btnGuid)
        if scriptName ~= nil then
            GUI.UnRegisterUIEvent(subTab, UCE.PointerClick, scriptName, data[5])
        end
    end
end
--注册二级页签
function UILayout.RegisterSubTabUIEvent(subTabList, scriptName)
    for i = 1, #subTabList do
        local data = subTabList[i]
        local subTab = GUI.GetByGuid(subTabList[i].btnGuid)
        if scriptName ~= nil then
            GUI.RegisterUIEvent(subTab, UCE.PointerClick, scriptName, data[5])
        end
    end
end

--点击右侧某个二级页签(父级关闭情况下生效，效率低)
function UILayout.OnSubTabClick(index, subTabList)
    for i = 1, #subTabList do
        local subTab = GUI.GetByGuid(subTabList[i].btnGuid)
        GUI.CheckBoxExSetCheck(subTab, i == index)
    end
end

--点击右侧某个二级页签(父级关闭情况下不生效，效率高)
function UILayout.OnSubTabClickEx(index, subTabList)
    local subTab = GUI.GetByGuid(subTabList[index].btnGuid)
    GUI.CheckBoxExSetCheck(subTab, true)
end

-- 设置UIElement的锚点
function UILayout.SetAnchorAndPivot(uiObj, anchor, aroundPivot)
    SetAnchor(uiObj, anchor)
    SetPivot(uiObj, aroundPivot)
end

UILayout.Bottom = {UIAnchor.Bottom, UIAroundPivot.Bottom}
UILayout.BottomLeft = {UIAnchor.BottomLeft, UIAroundPivot.BottomLeft}
UILayout.BottomRight = {UIAnchor.BottomRight, UIAroundPivot.BottomRight}
UILayout.Center = {UIAnchor.Center, UIAroundPivot.Center}
UILayout.Left = {UIAnchor.Left, UIAroundPivot.Left}
UILayout.Right = {UIAnchor.Right, UIAroundPivot.Right}
UILayout.Top = {UIAnchor.Top, UIAroundPivot.Top}
UILayout.TopLeft = {UIAnchor.TopLeft, UIAroundPivot.TopLeft}
UILayout.TopRight = {UIAnchor.TopRight, UIAroundPivot.TopRight}

---@public
---@param uiObj UIElemet
---@param tableAnchorAndPivot 如果不清楚该参数该传什么请查看函数定义处 @该参数必须是UILayout.Bottom, UILayout.BottomLeft, UILayout.BottomRight, UILayout.Center, UILayout.Left, UILayout.Right, UILayout.Top, UILayout.TopLeft,UILayout.TopRight
---@return UIElement
function UILayout.SetSameAnchorAndPivot(uiObj, tableAnchorAndPivot)
    SetAnchor(uiObj, tableAnchorAndPivot[1])
    SetPivot(uiObj, tableAnchorAndPivot[2])
end

---@class guidTable
---@field BindName function
---@field BindByTable function
---@field GetUI function
---@field GetGuid function

---@public
---@param uitable table
---@return guidTable
function UILayout.NewGUIDUtilTable(uitable)
    uitable = uitable or {}
    function uitable.BindName(uiobj, tagName)
        if uitable[tagName] ~= nil then
        --print("------->> 有相同的Key："..tagName)
        end
        uitable[tagName] = uiobj and GUI.GetGuid(uiobj) or nil
    end
    function uitable.BindByTable(t)
        if not t then
            return
        end
        for k, v in pairs(t) do
            uitable.BindName(v, k)
        end
    end
    function uitable.GetUI(tagName)
        local guid = uitable[tagName]
        return guid and GUI.GetByGuid(guid)
    end
    function uitable.GetGuid(tagName)
        return uitable[tagName]
    end
    return uitable
end

--设置白色字体黑色描边
function UILayout.SetOutLineText1(text)
    GUI.SetColor(text, UIDefine.WhiteColor)
    GUI.SetIsOutLine(text, true)
    GUI.SetOutLine_Color(text, UIDefine.BlackColor)
    GUI.SetOutLine_Distance(text, UIDefine.OutLineDistance)
end

--设置Static字体基本样式
function UILayout.StaticSetFontSizeColorAlignment(txt, size, color, alignment)
    GUI.StaticSetFontSize(txt, size)
    GUI.SetColor(txt, color)
    if alignment ~= nil then
        GUI.StaticSetAlignment(txt, alignment)
    end
end

--获取物品/宠物品质
function UILayout.GetItemGradeType(urlInfo)
    if string.find(urlInfo, "ITEMGUID:") ~= nil then
        local tmpStrGuid = string.split(urlInfo, "ITEMGUID:")
        local itemGuid = string.split(tmpStrGuid[2], ",")[1]
        local tmpStrGrade = string.split(urlInfo, "ITEMGRADE:")
        local grade = tonumber(string.split(tmpStrGrade[2], ">")[1])

        if CL.IsPetStrGuid(itemGuid) then
            return false, tonumber(grade)
        else
            return true, tonumber(grade)
        end
    else
        return nil, nil
    end
end

function UILayout.SetUrlColor(txt, isDarkBG)
    local urlInfo = GUI.GetUrlInfo(txt)
    if not isDarkBG then
        for i = 0, urlInfo.Length - 1 do
            local isItem, grade = UILayout.GetItemGradeType(urlInfo[i])
            if isItem ~= nil then
                local c = nil
                if isItem then
                    c = UIDefine.ItemQualityCorRGB[grade]
                else
                    c = UIDefine.PetQualityCorRGB[grade]
                end
                GUI.SetUrlColor(txt, i, c[1], c[2], c[3], 255)
            else
                --test("isItem == nil")
            end
        end
    else
        for i = 0, urlInfo.Length - 1 do
            local isItem, grade = UILayout.GetItemGradeType(urlInfo[i])
            if isItem ~= nil then
                if isItem then
                    local c = UIDefine.GradeColor[grade]
                    GUI.SetUrlColor(txt, i, c.r * 255, c.g * 255, c.b * 255, 255)
                else
                    local c = UIDefine.PetQualityCorRGB[grade]
                    GUI.SetUrlColor(txt, i, c[1], c[2], c[3], 255)
                end
            else
                --test("isItem == nil")
            end
        end
    end
end

function UILayout.CreateAttrBar(parent, name, x, y, width, uiLayout)
    local attrBar = GUI.ImageCreate(parent, name, "1800700010", x, y, false, width, 35)
    UILayout.SetSameAnchorAndPivot(attrBar, uiLayout)
    local y = -1
    if uiLayout == UILayout.Bottom or uiLayout == UILayout.BottomLeft or uiLayout == UILayout.BottomRight then
        y = 1
    end
    local icon = GUI.ImageCreate(attrBar, "icon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 0, y, false, 36, 36)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Left)
    local numText = GUI.CreateStatic(attrBar, "numText", "0", 5, 0, width, 35)
    GUI.SetColor(numText, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(numText, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(numText, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(numText, UILayout.Center)

    return attrBar, icon, numText
end

function UILayout.RefreshAttrBar(moneyBar, attrId, num)
    if moneyBar == nil then
        return
    end
    UILayout.RefreshAttrBar2(moneyBar, attrId and UIDefine.AttrIcon[attrId] or nil, num)
end

function UILayout.RefreshAttrBar2(moneyBar, iconImgStr, num)
    if moneyBar == nil then
        return
    end
    local icon = GUI.GetChild(moneyBar, "icon")
    local numText = GUI.GetChild(moneyBar, "numText")
    if numText == nil then
        numText = GUI.GetChild(moneyBar, "num")
    end
    if iconImgStr then
        GUI.SetVisible(icon, true)
        GUI.ImageSetImageID(icon, iconImgStr)
        GUI.SetPositionX(numText, 5)
    else
        GUI.SetVisible(icon, false)
        GUI.SetPositionX(numText, 0)
    end
    GUI.StaticSetText(numText, num)
end
---@class UILayout.BtnTween
---@field LeftRight number
---@field UpDown number
---@field Scale  number
UILayout.BtnTween = {
    LeftRight = 1,
    UpDown = 2,
    Scale = 3
}
---@param type UILayout.BtnTween
function UILayout.StopBtnTween(uinode, type)
    if type == UILayout.BtnTween.LeftRight then
        GUI.StopTween(uinode, GUITweenType.DOLocalRotate)
    elseif type == UILayout.BtnTween.UpDown then
        GUI.StopTween(uinode, GUITweenType.DOLocalMove)
    elseif type == UILayout.BtnTween.Scale then
        GUI.StopTween(uinode, GUITweenType.DOScale)
    end
end
function UILayout.DoBtnTween(uinode, type)
    if uinode==nil then
        return
    end
    local tween = nil
    if type == UILayout.BtnTween.LeftRight then
        tween = TweenData.New()
        local Keyframe =
            "((0,0,0,0,0.4773254),(0,0,0,0.03,0.9906387),(-10.25185,-10.25185,0,0.06,0.5081635),(-0.9095669,-0.9095669,0,0.09,0),(0,0,0,0.12,0.5),(-0.008313742,-0.008313742,0,1.000244,0.5))"
        tween.Type = GUITweenType.DOLocalRotate
        tween.Duration = 3
        tween.To = Vector3.New(0, 0, 45)
        tween.From = Vector3.New(0, 0, -45)
        tween.Keyframe = TOOLKIT.Str2Curve(Keyframe)
        tween.LoopType = UITweenerStyle.Loop
    elseif type == UILayout.BtnTween.UpDown then
        tween = TweenData.New()
        local Keyframe =
            "((0,0,0,0,0),(0,0,0,0.03,0.5),(-10.25185,-10.25185,0,0.06,0),(-0.9095669,-0.9095669,0,0.09,-0.5),(0,0,0,0.12,0))"
        tween.Type = GUITweenType.DOLocalMoveY
        tween.Duration = 3
        tween.To = Vector3.New(0,  10, 0)
        tween.Keyframe = TOOLKIT.Str2Curve(Keyframe)
        tween.LoopType = UITweenerStyle.Loop
    elseif type == UILayout.BtnTween.Scale then
        tween = TweenData.New()
        local Keyframe =
            "((0,0,0,0,0.4773254),(0,0,0,0.03,0.9906387),(-10.25185,-10.25185,0,0.06,0.5081635),(-0.9095669,-0.9095669,0,0.09,0),(0,0,0,0.12,0.5),(-0.008313742,-0.008313742,0,1.000244,0.5))"
        tween.Type = GUITweenType.DOScale
        tween.Duration = 3
        tween.To = Vector3.New(1.1, 1.1, 0)
        tween.From = Vector3.New(0.9, 0.9, 0)
        tween.Keyframe = TOOLKIT.Str2Curve(Keyframe)
        tween.LoopType = UITweenerStyle.Loop
    end
    if tween then
        GUI.DOTween(uinode, tween)
    end
end

-- 设置小星星
function UILayout.SetSmallStars(currentNum, maxNum, parent)
    if parent == nil then
        return
    end
	
    -- 小星星背景
    local starsBg = GUI.GetChild(parent, "starsBg")
	
    if starsBg == nil then
        starsBg = GUI.ImageCreate( parent,"starsBg", "1801200080", 0, -4,false,71,14)
        GUI.SetAnchor(starsBg, UIAnchor.Bottom)
        GUI.SetPivot(starsBg, UIAroundPivot.Bottom)
    end

    GUI.SetVisible(starsBg, maxNum > 0)

    if starsBg ~= nil then
        UILayout.SetStars(currentNum, maxNum, starsBg, UIAnchor.Center, UIAroundPivot.Center, -0.5, 0, "1801202190", "1801202192", 14, 13)
    end

end

-- 设置小星星（没有黑影版本）
function UILayout.SetSmallStarsWithout(currentNum, maxNum, parent)
    if parent == nil then
        return
    end
	
    -- 小星星背景
    local starsBg = GUI.GetChild(parent, "starsBg")
	
    if starsBg == nil then
        starsBg = GUI.ImageCreate( parent,"starsBg", "1800201170", 0, 0,false,76,16)
        GUI.SetAnchor(starsBg, UIAnchor.Bottom)
        GUI.SetPivot(starsBg, UIAroundPivot.Bottom)
    end

    GUI.SetVisible(starsBg, maxNum > 0)

    if starsBg ~= nil then
        UILayout.SetStars(currentNum, maxNum, starsBg, UIAnchor.Center, UIAroundPivot.Center, 0, -2, "1801202190", "1801202192", 15, 14)
    end

end


-- 设置星级
function UILayout.SetStars(currentNum, maxNum, parent, anchor, pivot, posX, posY, sprite1, sprite2, width, height)
    if parent == nil then
        return
    end

    for i = maxNum + 1, 10 do
        local starImg = GUI.GetChild(parent, "star" .. i)
        if starImg ~= nil then
            GUI.SetVisible(starImg, false)
        end
    end

    for i = 1, maxNum do
        local starImg = GUI.GetChild(parent, "star" .. i)
        if starImg == nil then
            local imgId = sprite1
            if i > currentNum then
                imgId = sprite2
            end
            starImg = GUI.ImageCreate(parent,"star" .. i, imgId, posX, posY,  false, width, height)
            GUI.SetAnchor(starImg, anchor)
            GUI.SetPivot(starImg, pivot)
        end

        local x = posX + (i - maxNum / 2) * width * 0.85 - width * 0.5 * 0.85

        GUI.SetVisible(starImg, true)
        GUI.SetPositionX(starImg, x)
        GUI.SetPositionY(starImg, posY)

        if i <= currentNum then
            GUI.ImageSetImageID(starImg, sprite1) 
        else
            GUI.ImageSetImageID(starImg, sprite2)
        end

    end
end