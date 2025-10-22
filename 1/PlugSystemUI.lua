PlugSystemUI = {}
local _gt = UILayout.NewGUIDUtilTable()

---------------------------------缓存需要的全局变量Start------------------------------
local GUI = GUI
local UILayout = UILayout
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local UIDefine = UIDefine
local UCE = UCE
local inspect = require("inspect")

---------------------------------缓存需要的全局变量End-------------------------------

-- 辅助进行状态(1：进行中；0：未开始)
PlugSystemUI.IsGoOn = 0

-- 活动列表配置
PlugSystemUI.ActivityDataConfig = {}

-- 各活动侠义值配置
PlugSystemUI.ActivityPointConfig = {}

-- 设置列表配置
PlugSystemUI.AssistSettingConfig = {}

-- 已选中设置列表配置
PlugSystemUI.SelectedSettingConfig = {}

-- 活动状态图片
PlugSystemUI.ActivityStatusImgConfig = {
    "", "1800604440", "1800604460", "1800604450",
}

PlugSystemUI.SelectImgConfig = { Selected = "1800607151", Unselected = "1800607150" }

PlugSystemUI.LogTxt = {}

-- 当前角色的Guid
PlugSystemUI.CurrPlayerGuid = nil

-- 侠义值
PlugSystemUI.XiaYiNum = nil

-- 已选择活动字符串
local select_tb_str = ""

--local test = function()  end
local test = print

function PlugSystemUI.Main()
    require("PlugSystemBar")

    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("PlugSystemUI", "PlugSystemUI", 0, 0, eCanvasGroup.Normal)
    --GUI.CreateSafeArea(wnd)
    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "辅助助手", "PlugSystemUI", "OnExit")
    local panelCover = GUI.GetChild(wnd, "panelCover", false)
    _gt.BindName(panelCover, "panelCover")
    _gt.BindName(panelBg, "panelBg")
    local group = GUI.GetChild(panelBg, "tabList")
    GUI.SetVisible(group, true)
    local intervalSp = GUI.ImageCreate(group, "intervalSp", "1801305010", 0, 0, false, 17, 100)
    UILayout.SetSameAnchorAndPivot(intervalSp, UILayout.Top)

    local bottomBg = GUI.GetChild(group, "bottomBg")
    bottomBg = GUI.ImageCreate(group, "bottomBg", "1801305030", 0, 0)
    UILayout.SetAnchorAndPivot(bottomBg, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetDepth(bottomBg, 0)
    -- 创建顶部(设置、辅助日志)按钮
    PlugSystemUI.CreateTopModuleUI(wnd, panelBg)
    -- 创建中间辅助模块背景UI
    PlugSystemUI.CreateMiddleModuleUI(panelBg)
    -- 创建底部(购买、开始辅助等)按钮及背景UI
    PlugSystemUI.CreateBottomModuleUI(panelBg)

    GUI.SetVisible(wnd, false)
end

function PlugSystemUI.OnShow()
    local wnd = GUI.GetWnd("PlugSystemUI")
    if wnd then
        GUI.SetVisible(wnd,true)
        -- 初始化活动数据
        PlugSystemUI.InitActivityData()
        -- 注册消息
        PlugSystemUI.RegisterMsg()
    end
end

function PlugSystemUI.OnExit()
    if PlugSystemBar then
        local isShow = GUI.GetVisible(GUI.GetWnd("PlugSystemBar"))
        if isShow and PlugSystemUI.IsGoOn == 0 then
            PlugSystemBar.OnExit()
        end
    end
    GUI.CloseWnd("PlugSystemUI")
end

function PlugSystemUI.InitActivityData()
    CL.SendNotify(NOTIFY.SubmitForm, "FormAssist", "GetData")

    local playerGuid = LD.GetSelfGUID()
    if PlugSystemUI.CurrPlayerGuid then
        if playerGuid ~= PlugSystemUI.CurrPlayerGuid then
            PlugSystemUI.LogTxt = {}
        end
    end
    PlugSystemUI.CurrPlayerGuid = playerGuid
end

function PlugSystemUI.RegisterMsg()
    CL.RegisterMessage(GM.CustomDataUpdate, "PlugSystemUI", "OnCustomDataUpdate")
end

function PlugSystemUI.UnRegisterMsg()
    CL.UnRegisterMessage(GM.CustomDataUpdate, "PlugSystemUI", "OnCustomDataUpdate")
end

function PlugSystemUI.OnClose()
    PlugSystemUI.UnRegisterMsg()
end

----------------------------------------
-- 创建界面顶部模块相关UI
function PlugSystemUI.CreateTopModuleUI(wnd, panelBg)
    local topGroup = GUI.GroupCreate(panelBg, "topGroup", 0, 60, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
    local settingBtn = GUI.ButtonCreate(topGroup, "settingBtn", "1800402110", 75, 0, Transition.ColorTint, "设置", 120, 45, false)
    UILayout.SetSameAnchorAndPivot(settingBtn, UILayout.TopLeft)
    GUI.ButtonSetTextFontSize(settingBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(settingBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(settingBtn, UCE.PointerClick, "PlugSystemUI", "OnSettingBtnClick")

    local logBtn = GUI.ButtonCreate(topGroup, "logBtn", "1800402110", -75, 0, Transition.ColorTint, "辅助日志", 120, 45, false)
    UILayout.SetSameAnchorAndPivot(logBtn, UILayout.TopRight)
    GUI.ButtonSetTextFontSize(logBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(logBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(logBtn, UCE.PointerClick, "PlugSystemUI", "OnLogBtnClick")

    -- 创建设置窗口界面UI
    PlugSystemUI.CreateSettingBtnWnd(wnd)

    -- 创建辅助日志窗口界面UI
    PlugSystemUI.CreateLogBtnWnd(wnd)
end

-- 创建界面中间模块相关UI
function PlugSystemUI.CreateMiddleModuleUI(panelBg)
    local middleGroup = GUI.GroupCreate(panelBg, "middleGroup", 0, 0, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
    local activityListBg = GUI.ImageCreate(middleGroup,"activityListBg", "1800600040", 0, 0, false, 1040, 430)
    UILayout.SetSameAnchorAndPivot(activityListBg, UILayout.Center)
    _gt.BindName(activityListBg, "activityListBg")

    local activityLoopScroll = GUI.LoopScrollRectCreate(activityListBg, "activityLoopScroll", 0, 0, 980, 395,
            "PlugSystemUI", "CreateActivityItemPool", "PlugSystemUI", "RefreshActivityItemPool",
            0, false, Vector2.New(305, 65), 3, UIAroundPivot.TopLeft, UIAnchor.TopLeft)

    GUI.ScrollRectSetChildSpacing(activityLoopScroll, Vector2.New(35, 20))
    _gt.BindName(activityLoopScroll, "activityLoopScroll")
end

-- 创建界面底部模块相关UI
function PlugSystemUI.CreateBottomModuleUI(panelBg)
    local bottomGroup = GUI.GroupCreate(panelBg, "bottomGroup", 0, -55, GUI.GetWidth(panelBg), GUI.GetHeight(panelBg))
    local xiaYiBg = GUI.ImageCreate(bottomGroup,"xiaYiBg", "1800600040", 75, 0, false, 200, 45)
    UILayout.SetSameAnchorAndPivot(xiaYiBg, UILayout.BottomLeft)

    local xiaYiTxt = GUI.CreateStatic(xiaYiBg, "xiaYiTxt", "侠义值：", 10, 0, 491, 40)
    UILayout.SetSameAnchorAndPivot(xiaYiTxt, UILayout.Left)
    GUI.StaticSetFontSize(xiaYiTxt, UIDefine.FontSizeM)
    GUI.SetColor(xiaYiTxt, UIDefine.Brown3Color)
    GUI.SetIsRaycastTarget(xiaYiTxt, true)

    local xiaYiNumTxt = GUI.CreateStatic(xiaYiBg, "xiaYiNumTxt", "", 85, -1.5, 491, 40)
    UILayout.SetSameAnchorAndPivot(xiaYiNumTxt, UILayout.Left)
    GUI.StaticSetFontSize(xiaYiNumTxt, UIDefine.FontSizeM)
    GUI.SetColor(xiaYiNumTxt, UIDefine.Brown3Color)
    GUI.SetIsRaycastTarget(xiaYiNumTxt, true)
    _gt.BindName(xiaYiNumTxt, "xiaYiNumTxt")

    -- 购买按钮
    local purchaseBtn = GUI.ButtonCreate(bottomGroup, "purchaseBtn", "1800402110", 265, 0, Transition.ColorTint, "购买", 120, 45, false)
    UILayout.SetSameAnchorAndPivot(purchaseBtn, UILayout.BottomLeft)
    GUI.ButtonSetTextFontSize(purchaseBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(purchaseBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(purchaseBtn, UCE.PointerClick, "PlugSystemUI", "OnPurchaseBtnClick")

    -- 侠义值Tips
    local xiaYiTips = GUI.ButtonCreate(bottomGroup, "xiaYiTips", "1800602230", 395, -3, Transition.ColorTint, "")
    UILayout.SetSameAnchorAndPivot(xiaYiTips, UILayout.BottomLeft)
    GUI.RegisterUIEvent(xiaYiTips, UCE.PointerClick, "PlugSystemUI", "OnXiaYiTipsBtnClick")

    -- 开启辅助按钮
    local enableBtn = GUI.ButtonCreate(bottomGroup, "enableBtn", "1800602030", -130, 0, Transition.ColorTint, "开始辅助")
    UILayout.SetSameAnchorAndPivot(enableBtn, UILayout.BottomRight)
    GUI.ButtonSetTextFontSize(enableBtn, 26)
    GUI.ButtonSetTextColor(enableBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(enableBtn, true)
    GUI.SetOutLine_Color(enableBtn, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(enableBtn, 1)
    GUI.RegisterUIEvent(enableBtn, UCE.PointerClick, "PlugSystemUI", "OnEnableBtnClick")

    _gt.BindName(enableBtn, "enableBtn")

    -- 开始辅助Tips
    local enableTips = GUI.ButtonCreate(bottomGroup, "enableTips", "1800602230", -80, -4, Transition.ColorTint, "")
    UILayout.SetSameAnchorAndPivot(enableTips, UILayout.BottomRight)
    GUI.RegisterUIEvent(enableTips, UCE.PointerClick, "PlugSystemUI", "OnEnableTipsBtnClick")

end

-- 创建左上角设置按钮窗口界面UI
function PlugSystemUI.CreateSettingBtnWnd(wnd)
    local settingPanelCover = GUI.ImageCreate(wnd, "settingPanelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetAnchorAndPivot(settingPanelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(settingPanelCover, true)
    _gt.BindName(settingPanelCover, "settingPanelCover")
    local settingPanelBg = UILayout.CreateFrame_WndStyle2_WithoutCover(settingPanelCover, "辅助设置", 500, 255, "PlugSystemUI")
    local closeBtn = GUI.GetChild(settingPanelBg, "closeBtn", false)
    GUI.SetVisible(closeBtn, false)
    GUI.SetVisible(settingPanelCover, false)

    -- 创建底部按钮
    local y = -15
    local settingCloseBtn = GUI.ButtonCreate(settingPanelBg, "settingCloseBtn", "1800402110", 65, y, Transition.ColorTint, "关闭", 120, 45, false)
    UILayout.SetSameAnchorAndPivot(settingCloseBtn, UILayout.BottomLeft)
    GUI.ButtonSetTextFontSize(settingCloseBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(settingCloseBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(settingCloseBtn, UCE.PointerClick, "PlugSystemUI", "OnSettingCloseBtnClick")

    local ensureBtn = GUI.ButtonCreate(settingPanelBg, "ensureBtn", "1800402110", -65, y, Transition.ColorTint, "确定", 120, 45, false)
    UILayout.SetSameAnchorAndPivot(ensureBtn, UILayout.BottomRight)
    GUI.ButtonSetTextFontSize(ensureBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(ensureBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(ensureBtn, UCE.PointerClick, "PlugSystemUI", "OnEnsureBtnClick")

    -- 创建复选框
    local settingLoopScroll = GUI.LoopScrollRectCreate(settingPanelBg, "settingLoopScroll", 0, -5, 480, 130,
            "PlugSystemUI", "CreateSettingLoopScroll", "PlugSystemUI", "RefreshSettingLoopScroll",
            0, false, Vector2.New(450, 35), 1, UIAroundPivot.Top, UIAnchor.Top)

    GUI.ScrollRectSetChildSpacing(settingLoopScroll, Vector2.New(0, 3))
    _gt.BindName(settingLoopScroll, "settingLoopScroll")
end

-- 创建辅助日志窗口界面UI
function PlugSystemUI.CreateLogBtnWnd(wnd)
    local logPanelCover = GUI.ImageCreate(wnd, "logPanelCover", "1800400220", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    UILayout.SetAnchorAndPivot(logPanelCover, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(logPanelCover, "logPanelCover")
    local logPanelBg = UILayout.CreateFrame_WndStyle2_WithoutCover(logPanelCover, "辅助日志", 700, 570, "PlugSystemUI")
    local closeBtn = GUI.GetChild(logPanelBg, "closeBtn", false)
    GUI.SetVisible(closeBtn, false)
    GUI.SetVisible(logPanelCover, false)
    GUI.SetIsRaycastTarget(logPanelCover, true)

    -- 创建日志滚动列表
    local logLoopScrollBg = GUI.ImageCreate(logPanelBg, "logLoopScrollBg", "1800600040", 0, 55, false, 660, 450)
    UILayout.SetSameAnchorAndPivot(logLoopScrollBg, UILayout.Top)

    local logLoopScroll = GUI.LoopListCreate(logLoopScrollBg, "logLoopScroll", 0, 15, 600, 420,
            "PlugSystemUI", "CreateLogTxtPool", "PlugSystemUI", "RefreshLogTxtPool",
            0, false, Vector2.New(600, 30), 1, UIAroundPivot.TopLeft, UIAnchor.TopLeft)

    GUI.ScrollRectSetChildSpacing(logLoopScroll, Vector2.New(0, 3))
    _gt.BindName(logLoopScroll, "logLoopScroll")

    -- 创建底部关闭按钮
    local logCloseBtn = GUI.ButtonCreate(logPanelBg, "logCloseBtn", "1800402110", 0, -20, Transition.ColorTint, "关闭日志", 120, 45, false)
    UILayout.SetSameAnchorAndPivot(logCloseBtn, UILayout.Bottom)
    GUI.ButtonSetTextFontSize(logCloseBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(logCloseBtn, UIDefine.Brown3Color)
    GUI.RegisterUIEvent(logCloseBtn, UCE.PointerClick, "PlugSystemUI", "OnLogCloseBtnClick")

end

----------------------------------------
-- 创建循环任务列表
function PlugSystemUI.CreateActivityItemPool()
    local activityLoopScroll = _gt.GetUI("activityLoopScroll")
    local index = tonumber(GUI.LoopScrollRectGetChildInPoolCount(activityLoopScroll)) + 1
    local activityBg = GUI.ImageCreate(activityLoopScroll, "activityBg"..index, "1800600880", 0, 0)
    UILayout.SetSameAnchorAndPivot(activityBg, UILayout.TopLeft)
    GUI.SetIsRaycastTarget(activityBg, true)
    activityBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(activityBg, UCE.PointerClick, "PlugSystemUI", "OnActivityBgClick")
    GUI.SetVisible(activityBg, false)

    local selectedIcon = GUI.ImageCreate(activityBg, "selectedIcon", "1800607150", 15, 0)
    UILayout.SetSameAnchorAndPivot(selectedIcon, UILayout.Left)

    local activityTxt = GUI.CreateStatic(activityBg, "activityTxt", "", 90, 0, 305, 65)
    GUI.StaticSetFontSize(activityTxt, UIDefine.FontSizeL)
    UILayout.SetSameAnchorAndPivot(activityTxt, UILayout.TopLeft)
    GUI.SetColor(activityTxt, UIDefine.BrownColor)

    local statusIcon = GUI.ImageCreate(activityBg, "statusIcon", "", -15, 0)
    UILayout.SetSameAnchorAndPivot(statusIcon, UILayout.Right)

    return activityBg
end

-- 刷新循环任务列表
function PlugSystemUI.RefreshActivityItemPool(para)
    para = string.split(para, "#")
    local guid = para[1]
    local index = tonumber(para[2]) + 1
    local activityBg = GUI.GetByGuid(guid)

    local actDataCfg = PlugSystemUI.ActivityDataConfig
    if not actDataCfg or not next(actDataCfg) then
        GUI.SetVisible(activityBg, false)
        return
    end

    GUI.SetVisible(activityBg, true)

    local activityTxt = GUI.GetChild(activityBg, "activityTxt", false)
    GUI.StaticSetText(activityTxt, actDataCfg[index].Key)
    local selectedIcon = GUI.GetChild(activityBg, "selectedIcon", false)
    PlugSystemUI.SetSelectedImgId(selectedIcon, tonumber(actDataCfg[index].IsSelect) == 1)

    local statusIcon = GUI.GetChild(activityBg, "statusIcon", false)
    local statusImgCfg = PlugSystemUI.ActivityStatusImgConfig
    GUI.SetVisible(statusIcon, true)

    local stateIndex = tonumber(actDataCfg[index].SelectionStatus)
    if stateIndex == 1 then
        GUI.SetVisible(statusIcon, false)
    else
        GUI.ImageSetImageID(statusIcon, statusImgCfg[tonumber(actDataCfg[index].SelectionStatus)])
    end

    GUI.SetData(activityBg, "index", index)

end

-- 创建日志循环列表
function PlugSystemUI.CreateLogTxtPool()
    local logLoopScroll = _gt.GetUI("logLoopScroll")
    local index = tonumber(GUI.LoopScrollRectGetChildInPoolCount(logLoopScroll)) + 1
    local chatImg = GUI.LoopListChatCreate(logLoopScroll, "chatImg"..tonumber(index), "1800400200", 0, 0)
    GUI.SetColor(chatImg, Color.New(1, 1, 1, 0))
    GUI.LoopListChatSetPreferredWidth(chatImg, 600)
    GUI.LoopListChatSetPreferredHeight(chatImg, 30)
    UILayout.SetSameAnchorAndPivot(chatImg, UILayout.TopLeft)
    GUI.SetVisible(chatImg, false)
    GUI.SetIsRaycastTarget(chatImg, false)

    local logTxt = GUI.CreateStatic(chatImg, "logTxt", "", 0, 0, 600, 30, "system", true)
    GUI.StaticSetFontSize(logTxt, UIDefine.FontSizeL)
    UILayout.SetSameAnchorAndPivot(logTxt, UILayout.TopLeft)
    GUI.SetColor(logTxt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(logTxt, TextAnchor.MiddleLeft)
    GUI.SetIsRaycastTarget(logTxt, false)

    GUI.SetVisible(chatImg, false)

    return chatImg
end

-- 刷新日志循环列表
function PlugSystemUI.RefreshLogTxtPool(para)
    para = string.split(para, "#")
    local guid = para[1]
    local index = tonumber(para[2]) + 1
    local chatImg = GUI.GetByGuid(guid)


    local logTxtList = PlugSystemUI.LogTxt
    if not logTxtList or not next(logTxtList) then
        GUI.SetVisible(chatImg, false)
        return
    end

    GUI.SetVisible(chatImg, true)

    local logTxt = GUI.GetChild(chatImg, "logTxt")
    GUI.StaticSetText(logTxt, logTxtList[index])

    if #logTxtList[index] > 96 then
        GUI.SetHeight(logTxt, 65)
        GUI.LoopListChatSetPreferredHeight(chatImg, 65)
    else
        GUI.SetHeight(logTxt, 30)
        GUI.LoopListChatSetPreferredHeight(chatImg, 30)
    end
end

-- 创建设置项UI
function PlugSystemUI.CreateSettingLoopScroll()
    local settingLoopScroll = _gt.GetUI("settingLoopScroll")
    local index = GUI.LoopScrollRectGetChildInPoolCount(settingLoopScroll) + 1
    local settingItemBg = GUI.ImageCreate(settingLoopScroll, "settingItemBg"..tonumber(index), "1800600040", 0, 0)
    GUI.SetIsRaycastTarget(settingItemBg, true)
    settingItemBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(settingItemBg, UCE.PointerClick, "PlugSystemUI", "OnSettingItemClick")

    local selectedIcon = GUI.ImageCreate(settingItemBg, "selectedIcon", "1800607150", 15, 0)
    UILayout.SetSameAnchorAndPivot(selectedIcon, UILayout.Left)
    local settingTxt = GUI.CreateStatic(settingItemBg, "settingTxt", "", 60, 0, 450, 35)
    UILayout.SetSameAnchorAndPivot(settingTxt, UILayout.Left)
    GUI.StaticSetFontSize(settingTxt, UIDefine.FontSizeM)
    GUI.SetColor(settingTxt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(settingTxt, TextAnchor.MiddleLeft)

    GUI.SetVisible(settingItemBg, false)

    return settingItemBg
end

-- 刷新设置项UI
function PlugSystemUI.RefreshSettingLoopScroll(para)

    --CDebug.LogError("-------------"..inspect(PlugSystemUI.AssistSettingConfig))
    para = string.split(para, "#")
    local guid = para[1]
    local index = tonumber(para[2]) + 1
    local settingItemBg = GUI.GetByGuid(guid)

    local cfgList = PlugSystemUI.AssistSettingConfig
    if not cfgList or not next(cfgList) then
        GUI.SetVisible(settingItemBg, false)
        return
    end

    GUI.SetVisible(settingItemBg, true)
    local settingTxt = GUI.GetChild(settingItemBg, "settingTxt", false)
    GUI.StaticSetText(settingTxt, cfgList[tonumber(index)].Tips)

    local selectedIcon = GUI.GetChild(settingItemBg, "selectedIcon", false)

    GUI.SetData(settingItemBg, "index", index)

    PlugSystemUI.SetSelectedImgId(selectedIcon, false)
    GUI.SetData(settingItemBg, "key", "")

    local ss_cfg = PlugSystemUI.SelectedSettingConfig
    CDebug.LogError("ss_cfg-------------"..inspect(ss_cfg))
    for i = 1, #ss_cfg do
        if ss_cfg[i] and ss_cfg[i] == cfgList[index].Key then
            GUI.SetData(settingItemBg, "key", ss_cfg[i])
            PlugSystemUI.SetSelectedImgId(selectedIcon, true)
        end
    end
    --if cfgList[index].Key == "UseCloud" then
    --    if MainUI.IsJindouyunTransfer == true then
    --        GUI.SetData(settingItemBg, "key", "UseCloud")
    --        PlugSystemUI.SetSelectedImgId(selectedIcon, true)
    --    else
    --        PlugSystemUI.SetSelectedImgId(selectedIcon, false)
    --        GUI.SetData(settingItemBg, "key", "")
    --    end
    --end

end

----------------------------------------

--------------------点击事件--------------------
-- 设置按钮点击事件
function PlugSystemUI.OnSettingBtnClick()
    local settingPanelCover = _gt.GetUI("settingPanelCover")
    if settingPanelCover then
        GUI.SetVisible(settingPanelCover, true)
        -- 获取设置相关数据
        CL.SendNotify(NOTIFY.SubmitForm, "FormAssist", "GetAssistSetting")
    end
end

-- 辅助日志按钮点击事件
function PlugSystemUI.OnLogBtnClick()
    local logPanelCover = _gt.GetUI("logPanelCover")
    if logPanelCover then
        GUI.SetVisible(logPanelCover, true)
        local logTxtList = PlugSystemUI.LogTxt
        if not logTxtList or not next(logTxtList) then return end

        local logLoopScroll = _gt.GetUI("logLoopScroll")
        GUI.LoopScrollRectSetTotalCount(logLoopScroll, #logTxtList)
        GUI.LoopScrollRectRefreshCells(logLoopScroll)
    end
end

-- 购买按钮点击事件
function PlugSystemUI.OnPurchaseBtnClick()
    GUI.OpenWnd("MallUI","20377")
end

-- 侠义值tips按钮点击事件
function PlugSystemUI.OnXiaYiTipsBtnClick()
    local actDataCfg = PlugSystemUI.ActivityDataConfig
    local actPointCfg = PlugSystemUI.ActivityPointConfig
    local panelBg = _gt.GetUI("panelBg")
    if not next(actDataCfg) and not next(actPointCfg) and not panelBg then return end

    local n = 0
    local msg = string.format("各类活动的侠义值消耗（每环）：\n")
    for i = 1, #actDataCfg do
        n = n + 1
        msg = msg .. "\t" .. actDataCfg[i].ShowName .. "：" .. actDataCfg[i].ConsumePoint .. "点\n"
    end

    msg = msg .. "作为队长参与以下活动可获得侠义值\n"
    for k, v in pairs(actPointCfg) do
        n = n + 1
        msg = msg .. "\t" .. k .. "：" .. v .. "点\n"
    end

    local hintBg = Tips.CreateHint(msg, panelBg, 55, -105, UILayout.Top, 385, 40 + 26 * n)
    UILayout.SetSameAnchorAndPivot(hintBg, UILayout.BottomLeft)
    local hintText = GUI.GetChild(hintBg, "hintText", false)
    GUI.SetPositionX(hintText, 20)
    GUI.SetPositionY(hintText, 20)
    UILayout.SetSameAnchorAndPivot(hintText, UILayout.TopLeft)
    GUI.StaticSetAlignment(hintText, TextAnchor.UpperLeft)
end

-- 开启辅助按钮点击事件
function PlugSystemUI.OnEnableBtnClick()
    local actDataCfg = PlugSystemUI.ActivityDataConfig
    if not next(actDataCfg) then return end

    local fightState = CL.GetFightState()

    select_tb_str = ""
    for i = 1, #actDataCfg do
        local isSelect = tonumber(actDataCfg[i].IsSelect)
        if isSelect == 1 and actDataCfg[i].SelectionStatus ~= 2 then
            select_tb_str = select_tb_str .. tostring(actDataCfg[i].Key) .. ","
        end
    end

    if #select_tb_str > 0 and PlugSystemUI.IsGoOn == 0 then
        if not fightState then
            CL.SendNotify(NOTIFY.SubmitForm, "FormAssist", "Start", select_tb_str)
            PlugSystemUI.IsGoOn = tonumber(CL.GetIntCustomData("Assist_GoOn"))
            PlugSystemUI.OnExit()
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法进行辅助！")
        end
    else
        if PlugSystemUI.IsGoOn == 1 then
            CL.SendNotify(NOTIFY.SubmitForm, "FormAssist", "End")
            PlugSystemUI.IsGoOn = tonumber(CL.GetIntCustomData("Assist_GoOn"))
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "没有符合辅助条件的任务")
        end
    end
    --CDebug.LogError(select_tb_str)
end

-- 开始辅助Tips按钮点击事件
function PlugSystemUI.OnEnableTipsBtnClick()
    local panelBg = _gt.GetUI("panelBg")
    if panelBg then
        local msg = string.format("1.在辅助过程中变更队伍，中止所有辅助；\n2.当以下情况出现时，辅助将会停止，并切换到下一玩法的辅助：\n\t-战斗失败\n\t-银币不足\n\t-无法获得任务物品")
        local hintBg = Tips.CreateHint(msg, panelBg, -55, -105, UILayout.Top, 415, 200)
        UILayout.SetSameAnchorAndPivot(hintBg, UILayout.BottomRight)
        local hintText = GUI.GetChild(hintBg, "hintText", false)
        GUI.SetPositionX(hintText, 20)
        GUI.SetPositionY(hintText, 20)
        UILayout.SetSameAnchorAndPivot(hintText, UILayout.TopLeft)
        GUI.StaticSetAlignment(hintText, TextAnchor.UpperLeft)
    end
end

-- 辅助设置关闭按钮点击事件
function PlugSystemUI.OnSettingCloseBtnClick()
    local settingPanelCover = _gt.GetUI("settingPanelCover")
    if settingPanelCover then
        GUI.SetVisible(settingPanelCover, false)
    end
end

-- 辅助日志关闭按钮点击事件
function PlugSystemUI.OnLogCloseBtnClick()
    local logPanelCover = _gt.GetUI("logPanelCover")
    if logPanelCover then
        GUI.SetVisible(logPanelCover, false)
    end
end

-- 辅助设置确定按钮点击事件
function PlugSystemUI.OnEnsureBtnClick()
    local settingCfg = PlugSystemUI.AssistSettingConfig
    if not next(settingCfg) then return end

    local setting_str = ""

    local settingLoopScroll = _gt.GetUI("settingLoopScroll")
    for i = 1, #settingCfg do
        local settingItemBg = GUI.LoopScrollRectGetChildInPool (settingLoopScroll, "settingItemBg"..i)
        local key = GUI.GetData(settingItemBg, "key")
        if #key > 0 then
            setting_str = setting_str .. key .. ","
        end
        --if i == 1 then
        --    if #key > 0 then
        --        MainUI.IsJindouyunTransfer = true
        --        TrackUI.EnableShowJindouyunBtn(true)
        --    else
        --        MainUI.IsJindouyunTransfer = false
        --        TrackUI.EnableShowJindouyunBtn(false)
        --    end
        --end
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormAssist", "SetAssistSetting", setting_str)

    local settingPanelCover = _gt.GetUI("settingPanelCover")
    if settingPanelCover then
        GUI.SetVisible(settingPanelCover, false)
    end
end

-- 设置项点击事件
function PlugSystemUI.OnSettingItemClick(guid)
    local settingCfg = PlugSystemUI.AssistSettingConfig
    if not next(settingCfg) then return end

    local settingItemBg = GUI.GetByGuid(tostring(guid))
    local index = tonumber(GUI.GetData(settingItemBg, "index"))
    local selectedIcon = GUI.GetChild(settingItemBg, "selectedIcon", false)

    local key = GUI.GetData(settingItemBg, "key")
    if #key < 1 then
        GUI.SetData(settingItemBg, "key", settingCfg[index].Key)
        PlugSystemUI.SetSelectedImgId(selectedIcon, true)
    else
        GUI.SetData(settingItemBg, "key", "")
        PlugSystemUI.SetSelectedImgId(selectedIcon, false)
    end

end

-- 活动项点击事件
function PlugSystemUI.OnActivityBgClick(guid)
    local actDataCfg = PlugSystemUI.ActivityDataConfig
    if not next(actDataCfg) then return end

    if PlugSystemUI.IsGoOn == 1 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "正在挂机中，无法修改选项")
        return
    end

    local activityBg = GUI.GetByGuid(tostring(guid))
    local index = tonumber(GUI.GetData(activityBg, "index"))
    local isSelect = tonumber(actDataCfg[index].IsSelect)
    local selectedIcon = GUI.GetChild(activityBg, "selectedIcon", false)
    actDataCfg[index].IsSelect = 1 - isSelect
    PlugSystemUI.SetSelectedImgId(selectedIcon, (1 - isSelect) == 1)

end

----------------------------------------

----------------------------------------
-- 刷新活动数据回调
function PlugSystemUI.RefreshActivityData()

    local actDataCfg = PlugSystemUI.ActivityDataConfig
    local actPointCfg = PlugSystemUI.ActivityPointConfig

    if not next(actDataCfg) and not next(actPointCfg) then
        test("服务端发送的数据不能为空")
        return
    end

    PlugSystemUI.IsGoOn = tonumber(CL.GetIntCustomData("Assist_GoOn"))
    PlugSystemUI.XiaYiNum = tonumber(CL.GetIntCustomData("Assist_AssistPoint"))

    local activityLoopScroll = _gt.GetUI("activityLoopScroll")
    GUI.LoopScrollRectSetTotalCount(activityLoopScroll, #actDataCfg)
    GUI.LoopScrollRectRefreshCells(activityLoopScroll)

    PlugSystemUI.XiaYiNumUpdate()

    local enableBtn = _gt.GetUI("enableBtn")

    if PlugSystemUI.IsGoOn == 0 then
        GUI.ButtonSetText(enableBtn, "开始辅助")
    else
        GUI.ButtonSetText(enableBtn, "停止挂机")
        if PlugSystemBar then
            GUI.OpenWnd("PlugSystemBar")
        end
    end

    if PlugSystemBar then
        PlugSystemBar.StateBtnUpdate(PlugSystemUI.IsGoOn)
    end
end

-- 刷新设置数据回调
function PlugSystemUI.RefreshSettingData()
    if not next(PlugSystemUI.AssistSettingConfig) then
        test("服务端发送的设置数据不能为空")
        return
    end
    local settingLoopScroll = _gt.GetUI("settingLoopScroll")
    GUI.LoopScrollRectSetTotalCount(settingLoopScroll, #PlugSystemUI.AssistSettingConfig)
    GUI.LoopScrollRectRefreshCells(settingLoopScroll)
end

----------------------------------------
-- 获取日志
function PlugSystemUI.GetLogTxt(logStr)
    logStr = "【 "..os.date("%H:%M:%S").." 】"..tostring(logStr)
    table.insert(PlugSystemUI.LogTxt, logStr)
end

-- 设置选中图片ID
-- selected: true or false
function PlugSystemUI.SetSelectedImgId(obj, selected)
    if not obj then return end

    if selected then
        GUI.ImageSetImageID(obj, PlugSystemUI.SelectImgConfig.Selected)
        return
    end

    GUI.ImageSetImageID(obj, PlugSystemUI.SelectImgConfig.Unselected)
end

-- 获取活动状态
function PlugSystemUI.GetActivityKeys()
    local actDataCfg = PlugSystemUI.ActivityDataConfig
    if not next(actDataCfg) then return end

    PlugSystemUI.IsGoOn = tonumber(CL.GetIntCustomData("Assist_GoOn"))

    select_tb_str = ""
    for i = 1, #actDataCfg do
        local isSelect = tonumber(actDataCfg[i].IsSelect)
        if isSelect == 1 and actDataCfg[i].SelectionStatus ~= 2 then
            select_tb_str = select_tb_str .. tostring(actDataCfg[i].Key) .. ","
        end
    end

    return { State = PlugSystemUI.IsGoOn, ActivityKeys = select_tb_str }
end

-- 更新侠义值数据
function PlugSystemUI.XiaYiNumUpdate()
    local xiaYiNumTxt = _gt.GetUI("xiaYiNumTxt")
    local xiaYiNum = tonumber(PlugSystemUI.XiaYiNum) or 0
    GUI.StaticSetText(xiaYiNumTxt, xiaYiNum)
end

-- 服务端自定义变量更新消息通知
function PlugSystemUI.OnCustomDataUpdate(type, key, value)
    local val = int64.longtonum2(value)
    if type == 2 then
        if key == "Assist_AssistPoint" then
            PlugSystemUI.XiaYiNum = val
            PlugSystemUI.XiaYiNumUpdate()
        --elseif key == "Assist_GoOn" then
        --    if PlugSystemBar then
        --        PlugSystemBar.StateBtnUpdate(val)
        --    end
        end
    end
end

--刷新表单单个数据
function PlugSystemUI.RefreshOnceStatus(name,SelectionStatus)
    if name and SelectionStatus then
        for k,v in pairs(PlugSystemUI.ActivityDataConfig) do
            if v.Key == name then
                v.SelectionStatus = SelectionStatus
                break
            end
        end
        PlugSystemUI.RefreshActivityData()
    end
end
