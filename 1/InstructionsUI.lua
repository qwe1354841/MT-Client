local InstructionsUI = {}

_G.InstructionsUI = InstructionsUI
local GuidCacheUtil = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local colorOutline = Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255)
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorDefault = Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255)
local BtnTypeEnum = {
    Enemy = 1,
    Friend = 2,
}

local btnList = {
    { "enemy", "1800402030", "1800402032", "OnEnemyBtnClick", -86, "敌方" },
    { "friend", "1800402030", "1800402032", "OnFriendBtnClick", 86, "我方" },
}

InstructionsUI.commandList = nil  --用于创建scrolllist
InstructionsUI.enemyCommandList = nil -- 敌方指令
InstructionsUI.friendCommandList = nil --友方指令
local clickedItemGuid = ""; -- 点击的Item的GUID
local currentType = "";    -- 当前编辑的指令，是enemy，还是friend
local isAdd = false;     --是否是新增指令
local InstructionsMax = 10

function InstructionsUI.Main(parameter)
	GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local parentPanel = GUI.WndCreateWnd("InstructionsUI", "InstructionsUI", 0, 0, eCanvasGroup.Normal)
    SetAnchorAndPivot(parentPanel, UIAnchor.Center, UIAroundPivot.Center)
    local cover = GUI.ImageCreate(parentPanel, "cover", "1800400220", 0, 0, false, GUI.GetWidth(parentPanel), GUI.GetHeight(parentPanel))
    SetAnchorAndPivot(cover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(cover, true)
    local panelBg = GUI.ImageCreate(parentPanel, "panelBg", "1800900010", 0, 0, false, 370, 470);
    SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)
    local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800302120", -16, 16, Transition.ColorTint);
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.Center)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "InstructionsUI", "OnClosePanelBtnClick");
    local titleBg = GUI.ImageCreate(panelBg, "titleBg", "1800001140", 0, -195, false, 260, 40);
    SetAnchorAndPivot(titleBg, UIAnchor.Center, UIAroundPivot.Center)
    local titleLabel = GUI.CreateStatic(titleBg, "titleLabel", "战斗指令编辑", 0, 0, 160, 40);
    InstructionsUI.SetTextBasicInfo(titleLabel, colorDefault, TextAnchor.MiddleCenter, 24)
    local restoreDefaultBtn = GUI.ButtonCreate(panelBg, "restoreDefaultBtn", "1800402110", 0, 200, Transition.ColorTint, "恢复系统默认", 180, 50, false);
    InstructionsUI.SetButtonBasicInfo(restoreDefaultBtn, 24, "OnRestoreDefaultBtn");
    for i = 1, #btnList do
        local btn = GUI.ButtonCreate(panelBg, btnList[i][1], btnList[i][2], btnList[i][5], -120, Transition.ColorTint, "", 175, 40, false)
        GUI.SetPivot(btn, UIAroundPivot.Bottom);
        local highLightBg = GUI.ImageCreate(btn, "highLightBg", btnList[i][3], 0, 0, false, 175, 40);
        SetAnchorAndPivot(highLightBg, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetVisible(highLightBg, false);
        local btnTxt = GUI.CreateStatic(btn, "btnTxt", btnList[i][6], 0, 0, 150, 40);
        InstructionsUI.SetTextBasicInfo(btnTxt, colorDark, TextAnchor.MiddleCenter, 22)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "InstructionsUI", btnList[i][4]);
    end
    local scrollBg = GUI.ImageCreate(panelBg, "scrollBg", "1800300040", 0, 20, false, 340, 285);
    SetAnchorAndPivot(scrollBg, UIAnchor.Center, UIAroundPivot.Center)

    currentType = BtnTypeEnum.Friend
    InstructionsUI.RefreshCommandList();
    InstructionsUI.SetBtnState(BtnTypeEnum.Friend);
    local globalDB = DB.GetGlobal(1)
    if globalDB and globalDB.Id ~= 0 then
        InstructionsMax = globalDB.InstructionsMax
    end
end

function InstructionsUI.OnShow(parameter)
    CL.UnRegisterMessage(GM.FightInstructionUpdate, "InstructionsUI", "OnFightInstructionUpdate")
    CL.RegisterMessage(GM.FightInstructionUpdate, "InstructionsUI", "OnFightInstructionUpdate")
    InstructionsUI.RefreshCommandList()
    GUI.SetVisible(GUI.GetWnd("InstructionsUI"), true)
    if parameter == nil then
        InstructionsUI.OnFriendBtnClick()
    else
        parameter = UIDefine.GetParameter1(parameter)
        if tonumber(parameter) == 1 then
            InstructionsUI.OnEnemyBtnClick()
        elseif tonumber(parameter) == 2 then
            InstructionsUI.OnFriendBtnClick()
        end
    end
end

function InstructionsUI.OnClose()
    CL.UnRegisterMessage(GM.FightInstructionUpdate, "InstructionsUI", "OnFightInstructionUpdate")
end

function InstructionsUI.SetButtonBasicInfo(btn, fontSize, functionName)
    if btn ~= nil then
        SetAnchorAndPivot(btn, UIAnchor.Center, UIAroundPivot.Center)
        GUI.ButtonSetTextFontSize(btn, fontSize)
        GUI.ButtonSetTextColor(btn, colorDark)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "InstructionsUI", functionName);
    end
end

function InstructionsUI.SetTextBasicInfo(txt, color, Anchor, txtSize)
    if txt ~= nil then
        SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(txt, txtSize);
        GUI.SetColor(txt, color);
        GUI.StaticSetAlignment(txt, Anchor)
    end
end

-- 恢复默认指令
function InstructionsUI.OnRestoreDefaultBtn(guid)
    if not InstructionsUI.commandList then
        return
    end
    local t = InstructionsUI.commandList.Count > 0 and InstructionsUI.commandList[0].type or (currentType == BtnTypeEnum.Friend and 0 or 1)
    CL.SendNotify(NOTIFY.InstructionOpe, 3, t)
end

function InstructionsUI.OnEnemyBtnClick(guid)
    InstructionsUI.SetBtnState(BtnTypeEnum.Enemy)
end

function InstructionsUI.OnFriendBtnClick(guid)
    InstructionsUI.SetBtnState(BtnTypeEnum.Friend);
end

function InstructionsUI.OnClosePanelBtnClick(guid)
    GUI.CloseWnd("InstructionsUI");
end

function InstructionsUI.SetBtnState(idx)
    for i = 1, #btnList do
        local btn = GUI.Get("InstructionsUI/panelBg/" .. btnList[i][1])
        local highLightBg = GUI.GetChild(btn, "highLightBg")
        GUI.SetVisible(highLightBg, i == idx)
    end
    currentType = idx
    if currentType == BtnTypeEnum.Friend then
        InstructionsUI.commandList = InstructionsUI.friendCommandList
    elseif currentType == BtnTypeEnum.Enemy then
        InstructionsUI.commandList = InstructionsUI.enemyCommandList
    end
    InstructionsUI.CreateCommandScroll()
end

function InstructionsUI.OnFightInstructionUpdate()
    InstructionsUI.CreateCommandScroll()
end

function InstructionsUI.CreateCommandScroll()
    local scrollBg = GUI.Get("InstructionsUI/panelBg/scrollBg")
    local preScroll = GUI.GetChild(scrollBg, "commandScroll");
    if preScroll ~= nil then
        GUI.Destroy(preScroll)
    end
    local scrollWnd = GUI.ScrollRectCreate(scrollBg, "commandScroll", 0, 0, 340, 285, 0, false, Vector2.New(170, 70),  UIAroundPivot.Top, UIAnchor.Top, 2)
    GUI.ScrollRectSetChildSpacing(scrollWnd, Vector2.New(0, 0))
    local count = 0;
    for i = 0, InstructionsUI.commandList.Count - 1 do
        local data = InstructionsUI.commandList[i]
        local btnStr = "1800602040";
        if data.content == "集火" then
            btnStr = "1801202020";
        end
        local btn = GUI.ButtonCreate(scrollWnd, "Item" .. i, btnStr, 0, 0, Transition.ColorTint, data.content, 170, 70, false);
        GUI.SetData(btn, "Index", i);
        InstructionsUI.SetButtonBasicInfo(btn, 24, "OnCommandBtnClick");
        count = count + 1;
    end
    if count < InstructionsMax then
        local btn = GUI.ButtonCreate(scrollWnd, "addCommandBtn", "1800602041", 0, 0, Transition.ColorTint, "增加指令");
        InstructionsUI.SetButtonBasicInfo(btn, 24, "OnAddCommandBtnClick");
    end
end

-- 只每一次打开的是获得一下内存中的数据
function InstructionsUI.RefreshCommandList()
    InstructionsUI.commandList = nil
    InstructionsUI.enemyCommandList = LD.GetFightInstruction(false)
    InstructionsUI.friendCommandList = LD.GetFightInstruction(true)
end

function InstructionsUI.OnAddCommandBtnClick()
    if not InstructionsUI.commandList then
        return
    end
    if InstructionsUI.commandList.Count >= InstructionsMax then
        CL.SendNotify(NOTIFY.ShowBBMsg, "指令数已达上限,无法添加")
        return
    end
    isAdd = true;
    InstructionsUI.CreateChangeCommandPanel();
end

function InstructionsUI.OnCommandBtnClick(guid)
    local txt = GUI.ButtonGetText(GUI.GetByGuid(guid));
    if txt == "集火" then
        CL.SendNotify(NOTIFY.ShowBBMsg, "默认指令无法修改");
        return ;
    end
    clickedItemGuid = guid;
    isAdd = false;
    InstructionsUI.CreateChangeCommandPanel(txt);
end

function InstructionsUI.CreateChangeCommandPanel(preCommandStr)
    local panel = GUI.GetWnd("InstructionsUI")
    local panelCover = GUI.ImageCreate(panel, "changeCommand", "1800400220", 0, 0, false,  GUI.GetWidth(panel), GUI.GetHeight(panel))
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)

    -- 底图
    local panelBg = GUI.ImageCreate(panelCover, "panelBg", "1800001120", 0, 0, false, 464, 280)
    SetAnchorAndPivot(panelBg, UIAnchor.Center, UIAroundPivot.Center)
    -- 左边装饰
    local pendant = GUI.ImageCreate(panelBg, "pendant", "1800007060", -20, -20)
    SetAnchorAndPivot(pendant, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    -- 右侧关闭按钮
    local closeBtn = GUI.ButtonCreate(panelBg, "closeBtn", "1800002050", -10, 10, Transition.ColorTint)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "InstructionsUI", "OnCloseBtnClick")
    -- 标题
    local titleBg = GUI.ImageCreate(panelBg, "titleBg", "1800001030", 0, 35)
    SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Center)
    local titleLabel = GUI.CreateStatic(titleBg, "titleLabel", "指    令", 0, 0, 150, 35, "system", true, false)
    InstructionsUI.SetTextBasicInfo(titleLabel, colorDefault, TextAnchor.MiddleCenter, 24)
    -- 输入框底图
    local inputAreaBg = GUI.ImageCreate(panelBg, "inputAreaBg", "1800400200", 0, 0, false, 412, 136)
    SetAnchorAndPivot(inputAreaBg, UIAnchor.Center, UIAroundPivot.Center)
    -- 确认
    local OKBtn = GUI.ButtonCreate(panelBg, "OKBtn", "1800402080", -26, -18, Transition.ColorTint, "")
    SetAnchorAndPivot(OKBtn, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.RegisterUIEvent(OKBtn, UCE.PointerClick, "InstructionsUI", "OnOKBtnClick")
    local OKBtnText = GUI.CreateStatic(OKBtn, "OKBtnText", "确认", 0, 0, 160, 47, "system", true)
    InstructionsUI.SetTextBasicInfo(OKBtnText, colorDefault, TextAnchor.MiddleCenter, 26)
    GUI.SetIsOutLine(OKBtnText, true)
    GUI.SetOutLine_Color(OKBtnText, colorOutline)
    GUI.SetOutLine_Distance(OKBtnText, 1)
    -- 关闭
    local cancelBtn = GUI.ButtonCreate(panelBg, "cancelBtn", "1800402080", 26, -18, Transition.ColorTint, "")
    SetAnchorAndPivot(cancelBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick, "InstructionsUI", "OnCloseBtnClick")
    local cancelBtnText = GUI.CreateStatic(cancelBtn, "joinBattleBtnText", "关闭", 0, 0, 160, 47, "system", true)
    InstructionsUI.SetTextBasicInfo(cancelBtnText, colorDefault, TextAnchor.MiddleCenter, 26)
    GUI.SetIsOutLine(cancelBtnText, true)
    GUI.SetOutLine_Color(cancelBtnText, colorOutline)
    GUI.SetOutLine_Distance(cancelBtnText, 1)
    -- 输入框
    local input = GUI.EditCreate(panelBg, "input", "1800001040", "点击这里输入", 0, 0, Transition.ColorTint, "system", 0, 0, 40, 8)
    GUI.EditSetLabelAlignment(input, TextAnchor.MiddleCenter)
    GUI.EditSetTextColor(input, colorDark)
    GUI.EditSetFontSize(input, 22)
    if preCommandStr ~= nil and #preCommandStr > 0 then
        GUI.EditSetTextM(input, preCommandStr);
    end
end

-- 关闭按钮被点击
function InstructionsUI.OnCloseBtnClick(key)
    local changeCommand = GUI.Get("InstructionsUI/changeCommand");
    if changeCommand ~= nil then
        GUI.Destroy(changeCommand);
    end
end

-- 确认按钮被点击
function InstructionsUI.OnOKBtnClick(key)
    local input = GUI.Get("InstructionsUI/changeCommand/panelBg/input");
    if input == nil then
        return
    end
    local newCmd = GUI.EditGetTextM(input);
    if newCmd == "集火" then
        if currentType == BtnTypeEnum.Enemy then
            CL.SendNotify(NOTIFY.ShowBBMsg, "已经包含此战斗指令");
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "集火为默认敌方指令,无法添加");
        end
        return ;
    end

    --TODO:检查屏蔽字
    if not isAdd then
        local currentIndex = tonumber(GUI.GetData(GUI.GetByGuid(clickedItemGuid), "Index"))
        local t = InstructionsUI.commandList[currentIndex].type

        if string.len(newCmd) <= 0 then
            CL.SendNotify(NOTIFY.InstructionOpe, 6, currentIndex, t) -- 删除指令
        else
            CL.SendNotify(NOTIFY.InstructionOpe, 5, currentIndex, t, newCmd)
        end
    else
        local t = InstructionsUI.commandList.Count > 0 and InstructionsUI.commandList[0].type or (currentType == BtnTypeEnum.Friend and 0 or 1)
        CL.SendNotify(NOTIFY.InstructionOpe, 7, t, newCmd)
    end

    InstructionsUI.OnCloseBtnClick()
end