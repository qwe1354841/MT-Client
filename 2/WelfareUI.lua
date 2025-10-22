local WelfareUI = {
    ServerData = {}
}
_G.WelfareUI = WelfareUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local guidt = UILayout.NewGUIDUtilTable()

local SubTableUI = {}
---@type WelfareUIType[]
local types = {
    {Name = "每日在线", UI = "WelDailyOnLineUI", uiNode = "dailyOnLine", openFlag = "DailyOnline"},
    {Name = "等级礼包", UI = "WelLevelGiftUI", uiNode = "levelGift", openFlag = "LevelPackage"},
    {Name = "每日签到", UI = "WelDaySignGiftUI", uiNode = "dayGift", openFlag = "DailySign"},
    {Name = "限时折扣", UI = "WelDiscountUI", uiNode = "discountUI", openFlag = "Discount"},--, openFunc = "CheckDiscountOpen"
    {Name = "五星连珠", UI = "WelBingoUI", uiNode = "BingoUI", openFlag = "BinGo"},
    {Name = "兑换", UI = "WelExchangeUI", uiNode = "exChangeUI"},
    {Name = "输入邀请码", UI = "WelInputInvitationCodeUI", uiNode = "invitationCode",openFlag = "FriendInvited"},
    {Name = "好友邀请", UI = "WelFriendInvitationUI", uiNode = "friendInvitation",openFlag = "FriendInvitation"},
}
function WelfareUI.InitData()
    return {
        typeguid = "",
        typeIndex = 1,
        typeDataList = {},
        ---@type table<string,number>
        typeName2Index = {},
        indexName = nil
    }
end
local data = WelfareUI.InitData()
function WelfareUI.OnExitGame()
    data = WelfareUI.InitData()
    for key, value in pairs(SubTableUI) do
        if value["OnExitGame"] then
            value["OnExitGame"]()
        end
    end
end
function WelfareUI.OnExit()
    GUI.CloseWnd("WelfareUI")
end
function WelfareUI.Main(parameter)
    GUI.PostEffect()
    SubTableUI = {}
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("WelfareUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("WelfareUI", "WelfareUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "福    利", "WelfareUI", "OnExit",guidt)
    local typeScroll =
        GUI.LoopScrollRectCreate(
        panelBg,
        "typeScroll",
        75,
        65,
        200,
        550,
        "WelfareUI",
        "CreateTypeItem",
        "WelfareUI",
        "RefreshTypeScroll",
        0,
        false,
        Vector2.New(200, 60),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    UILayout.SetSameAnchorAndPivot(typeScroll, UILayout.TopLeft)
    GUI.ScrollRectSetChildSpacing(typeScroll, Vector2.New(0, 10))
    guidt.BindName(typeScroll, "typeScroll")
    guidt.BindName(panelBg, "panelBg")
    guidt.BindName(GUI.ImageCreate(panelBg, "rewardBg", "1800400010", 285, 194, false, 838, 415), "rewardBg")
    UILayout.SetSameAnchorAndPivot(guidt.GetUI("rewardBg"), UILayout.TopLeft)
    WelfareUI.GetDate()
end

function WelfareUI.IsWelInputInvitationCodeUIClose()
    for key, value in pairs(types) do
        if value.UI == "WelInputInvitationCodeUI" then
            value.openFlag = ""
        end
    end
    if WelInputInvitationCodeUI then
        data.typeIndex = 1
        WelInputInvitationCodeUI.OnExit()
    end
	WelfareUI.ClientRefresh()
end

function WelfareUI.IsWelInputInvitationCodeUIShow()
    for key, value in pairs(types) do
        if value.UI == "WelInputInvitationCodeUI" then
            value.openFlag = "FriendInvited"
        end
    end
	WelfareUI.ClientRefresh()
end

function WelfareUI.OnShow(parameter)
    local wnd = GUI.GetWnd("WelfareUI")
    if wnd == nil then
        return
    end
    if parameter ~= nil then
        local a, b = UIDefine.GetParameterStr(parameter)
        data.typeIndex = tonumber(a)
    else
        data.typeIndex = 1
    end
    GUI.SetVisible(wnd, true)
    WelfareUI.ClientRefresh()
end
function WelfareUI.OnClose()
    local wnd = GUI.GetWnd("WelfareUI")
    GUI.SetVisible(wnd, false)
    WelfareUI.OnExitGame()
end
function WelfareUI.GetDate()
end
function WelfareUI.Refresh()
	WelfareUI.ClientRefresh()
end
function WelfareUI.ClientRefresh()
    data.typeDataList = {}
    local open = "on"
    for key, value in pairs(types) do
        if UIDefine.FunctionSwitch ~= nil or value.openFlag == nil then
            if value.openFlag == nil or UIDefine.FunctionSwitch[value.openFlag] == open then
                if not value.openFunc or WelfareUI[value.openFunc]() then
                    local index = #data.typeDataList + 1
                    data.typeDataList[index] = value
                    data.typeName2Index[value.Name] = index
                end
            end
        end
    end

    if data.typeIndex < 1 or data.typeIndex > #data.typeDataList then
        data.typeIndex = 1
    end
    WelfareUI.SetTypeIndex(data.typeIndex)
    WelfareUI.RefreshUI()
end

function WelfareUI.IsWndOpen(Key)
	if not WelfareUI.UIName then
		WelfareUI.UIName = {}
		for k,v in ipairs(types) do
			WelfareUI.UIName[v.UI] = v.uiNode
		end
	end
	local UINode = WelfareUI.UIName[Key]
	if UINode then
		if GUI.GetChild(guidt.GetUI("panelBg"), UINode, false) then
			return true
		end
	end
	return false
end

function WelfareUI.RefreshLeftTypeScroll()
    if next(data.typeDataList) ~= nil  then
        if guidt ~= nil then
            local scroll = guidt.GetUI("typeScroll")
            GUI.LoopScrollRectSetTotalCount(scroll, #data.typeDataList)
            GUI.LoopScrollRectRefreshCells(scroll)
        end
    end
end

function WelfareUI.RefreshUI()
    local panelBg = guidt.GetUI("panelBg")
    local typeData = data.typeDataList[data.typeIndex]
    local scroll = guidt.GetUI("typeScroll")
    GUI.LoopScrollRectSetTotalCount(scroll, #data.typeDataList)
    GUI.LoopScrollRectRefreshCells(scroll)
    local subpage = GUI.GetChild(panelBg, typeData.uiNode, false)
    if subpage == nil then
        subpage = GUI.GroupCreate(panelBg, typeData.uiNode, 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
        if SubTableUI[typeData.Name].CreateSubPage then
            SubTableUI[typeData.Name].CreateSubPage(subpage)
        end
    end
    for key, value in pairs(SubTableUI) do
        if key == typeData.Name then

        else
            if data.typeName2Index[key] ~= nil then
                GUI.SetVisible(GUI.GetChild(panelBg, data.typeDataList[data.typeName2Index[key]].uiNode), false)
                if value.OnClose then
                    value.OnClose(guidt)
                end
            end
        end
    end
    GUI.SetVisible(subpage, true)
    if SubTableUI[typeData.Name].OnShow then
        SubTableUI[typeData.Name].OnShow(guidt)
    end
end
function WelfareUI.CreateTypeItem()
    local typeScroll = guidt.GetUI("typeScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(typeScroll)
    local typeItem = GUI.CheckBoxExCreate(typeScroll, "typeItem" .. curCount, "1800002030", "1800002031", 0, 0, false)
    GUI.RegisterUIEvent(typeItem, UCE.PointerClick, "WelfareUI", "OnTypeItemClick")

    local nameText = GUI.CreateStatic(typeItem, "nameText", "", 0, 1, 200, 50)
    GUI.SetColor(nameText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(nameText, UIDefine.FontSizeXL)
    UILayout.SetSameAnchorAndPivot(nameText, UILayout.Center)
    GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter)
    return typeItem
end

function WelfareUI.OnTypeItemClick(guid)
    local typeItem = GUI.GetByGuid(guid)
    local index = GUI.CheckBoxExGetIndex(typeItem)
    index = index + 1
    if data.typeguid ~= guid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.typeguid), false)
    end
    data.typeguid = guid
    GUI.CheckBoxExSetCheck(typeItem, true)
    data.typeIndex = index
    WelfareUI.ClientRefresh()
end

function WelfareUI.RefreshTypeScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local typeItem = GUI.GetByGuid(guid)
    index = index + 1
    if data.typeIndex == index then
        data.typeguid = guid
        GUI.CheckBoxExSetCheck(typeItem, true)
    else
        GUI.CheckBoxExSetCheck(typeItem, false)
    end
    local typeData = data.typeDataList[index]
    local nameText = GUI.GetChild(typeItem, "nameText")
    GUI.StaticSetText(nameText, typeData.Name)
	local typeFlag = typeData.openFlag
	if typeFlag then
		if GlobalProcessing then
			if GlobalProcessing[typeFlag..'_DataLoading'] then
				local RedPoint = GlobalProcessing[typeFlag..'_DataLoading']()
				if RedPoint == 1 then
					GlobalProcessing.SetRetPoint(typeItem, true)
				else
					GlobalProcessing.SetRetPoint(typeItem, false)
				end
			end
		end
	end
end
function WelfareUI.SetTypeIndex(index)
    local typeData = data.typeDataList[data.typeIndex]
    if SubTableUI[typeData.Name] == nil then
        require(typeData.UI)
        SubTableUI[typeData.Name] = _G[typeData.UI]
        if SubTableUI[typeData.Name]["OnExitGame"] then
            SubTableUI[typeData.Name]["OnExitGame"]()
        end
    end
end
function WelfareUI.SendNotify(fromName, ...)
    CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", fromName, ...)
end
