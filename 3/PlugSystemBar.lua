PlugSystemBar = {}

local _gt = UILayout.NewGUIDUtilTable()

---------------------------------缓存需要的全局变量Start------------------------------
local GUI = GUI
local UILayout = UILayout
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local UCE = UCE
---------------------------------缓存需要的全局变量End-------------------------------

local test = print

PlugSystemBar.GoOn = 0
PlugSystemBar.Pause = 1

-- 主界面相关按钮UI配置(开始按钮和暂停按钮的Name不要改动)
PlugSystemBar.MainPlugUIConfig = {
    { Name = "plugBtn", ImgId = "1800602240", TextImgId = "1800604490", Method = "OnPlugBtnClick", PosX = 8, PosY = -10, IsVisible = true },
    { Name = "startBtn", ImgId = "1800602270", TextImgId = "1800604500", Method = "OnStartBtnClick", PosX = 78, PosY = -10, IsVisible = true },
    { Name = "pauseBtn", ImgId = "1800602250", TextImgId = "1800604480", Method = "OnPauseBtnClick", PosX = 78, PosY = -10, IsVisible = false },
    { Name = "exitBtn", ImgId = "1800602260", TextImgId = "1800604470", Method = "OnExitBtnClick", PosX = 148, PosY = -10, IsVisible = true },
}

function PlugSystemBar.Main()
    _gt = UILayout.NewGUIDUtilTable()

    local wnd = GUI.WndCreateWnd("PlugSystemBar", "PlugSystemBar", 0, 0, eCanvasGroup.Normal)
    --GUI.CreateSafeArea(wnd)
    UILayout.SetSameAnchorAndPivot(wnd, UILayout.Center)

    local plugBarGroup = GUI.GroupCreate(wnd, "plugBarGroup", 12, -280, 218, 78)
    UILayout.SetSameAnchorAndPivot(plugBarGroup, UILayout.BottomLeft)
    GUI.StartGroupDrag(plugBarGroup)

    _gt.BindName(plugBarGroup, "plugBarGroup")
    PlugSystemBar.CreateMainPlugUI(plugBarGroup)
end

function PlugSystemBar.OnShow()
    local wnd = GUI.GetWnd("PlugSystemBar")
    if not wnd then return end

    GUI.SetVisible(wnd, true)
    PlugSystemBar.InitBarUI()
end

function PlugSystemBar.OnExit()
    GUI.Destroy("PlugSystemBar")
end

-- 创建Main界面辅助UI(辅助、开始/暂停、停止按钮)
function PlugSystemBar.CreateMainPlugUI(parent)
    local plugBg = GUI.ImageCreate(parent, "plugBg", "1800600890", 0, 0, false, 0, 0)
    UILayout.SetSameAnchorAndPivot(plugBg, UILayout.Center)
    GUI.SetIsRaycastTarget(plugBg, true)

    _gt.BindName(plugBg, "plugBg")

    local mpcfg = PlugSystemBar.MainPlugUIConfig
    for i = 1, #mpcfg do
        PlugSystemBar.CreateMainPlugBtnUI(plugBg, mpcfg[i].Name, mpcfg[i].ImgId, mpcfg[i].PosX, mpcfg[i].PosY, mpcfg[i].TextImgId, mpcfg[i].Method, mpcfg[i].IsVisible)
    end

    GUI.SetVisible(plugBg, false)
end

function PlugSystemBar.CreateMainPlugBtnUI(parent, name, imgId, x, y, textImgId, method, isVisible)
    name = tostring(name)
    imgId = tostring(imgId)
    textImgId = tostring(textImgId)
    method = tostring(method)

    local btn = GUI.ButtonCreate(parent, name, imgId, x, y, Transition.ColorTint, "")
    UILayout.SetSameAnchorAndPivot(btn, UILayout.BottomLeft)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "PlugSystemBar", method)

    local label = GUI.ImageCreate(btn, "label", textImgId, 0, 5, false, 0, 0)
    UILayout.SetAnchorAndPivot(label, UIAnchor.Bottom, UIAroundPivot.Center)

    GUI.SetVisible(btn, isVisible)

    _gt.BindName(btn, name)
end

-- 主界面辅助按钮点击事件
function PlugSystemBar.OnPlugBtnClick()
    local isShow = GUI.GetVisible(GUI.GetWnd("PlugSystemUI"))
    if PlugSystemUI and not isShow then
        GUI.OpenWnd("PlugSystemUI")
    end
end

-- 主界面开始按钮点击事件
function PlugSystemBar.OnStartBtnClick(guid)
    if not PlugSystemUI then return end

    local fightState = CL.GetFightState()

    local state_tb = PlugSystemUI.GetActivityKeys()
    if state_tb and state_tb.State == 0 then
        local startBtn = GUI.GetByGuid(tostring(guid))
        local pauseBtn = _gt.GetUI("pauseBtn")
        if #state_tb.ActivityKeys > 0 then
            if not fightState then
                CL.SendNotify(NOTIFY.SubmitForm, "FormAssist", "Start", state_tb.ActivityKeys)
                GUI.SetVisible(startBtn, false)
                GUI.SetVisible(pauseBtn, true)
            else
                CL.SendNotify(NOTIFY.ShowBBMsg, "战斗中无法进行辅助！")
            end
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "没有符合辅助条件的任务")
        end
    end
end

-- 主界面暂停按钮点击事件
function PlugSystemBar.OnPauseBtnClick(guid)
    if not PlugSystemUI then return end

    local state_tb = PlugSystemUI.GetActivityKeys()
    if state_tb and state_tb.State == 1 then
        local pauseBtn = GUI.GetByGuid(tostring(guid))
        local startBtn = _gt.GetUI("startBtn")
        GUI.SetVisible(pauseBtn, false)
        GUI.SetVisible(startBtn, true)

        CL.SendNotify(NOTIFY.SubmitForm, "FormAssist", "End")
    end
end

-- 主界面退出按钮点击事件
function PlugSystemBar.OnExitBtnClick()
    if not PlugSystemUI then return end

    local state_tb = PlugSystemUI.GetActivityKeys()
    if state_tb and state_tb.State == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormAssist", "End")
    end

    PlugSystemBar.OnExit()
end

-- 初始化界面
function PlugSystemBar.InitBarUI()
    local plugBg = _gt.GetUI("plugBg")
    GUI.SetVisible(plugBg, true)

    local plugBarGroup = _gt.GetUI("plugBarGroup")
    --GUI.SetPositionX(plugBarGroup, 12)
    --GUI.SetPositionY(plugBarGroup, 240)
    UILayout.SetSameAnchorAndPivot(plugBarGroup, UILayout.BottomLeft)

    PlugSystemBar.StateBtnUpdate(PlugSystemBar.Pause)
end

function PlugSystemBar.StateBtnUpdate(state)
    if not state then return end

    local pauseBtn = _gt.GetUI("pauseBtn")
    local startBtn = _gt.GetUI("startBtn")

    state = tonumber(state)

    if state == 1 then
        GUI.SetVisible(pauseBtn, true)
        GUI.SetVisible(startBtn, false)
    else
        GUI.SetVisible(pauseBtn, false)
        GUI.SetVisible(startBtn, true)
    end

end