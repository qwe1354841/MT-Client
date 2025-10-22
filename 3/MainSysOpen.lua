local MainSysOpen = {
    lvUpTimer = nil
}
_G.MainSysOpen = MainSysOpen
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot

local buttonRightBottomLst = MainUIBtnOpenDef.buttonRightBottomLst
local buttonLeftTopLst = MainUIBtnOpenDef.buttonLeftTopLst
local buttonLeftLst = MainUIBtnOpenDef.buttonLeftLst
local Mainbtns = {buttonRightBottomLst, buttonLeftTopLst, buttonLeftLst}
------------------------------------ end缓存一下全局变量end --------------------------------
local guidt = UILayout.NewGUIDUtilTable()
function MainSysOpen.InitData()
    return {
        lv = nil
    }
end
local data = MainSysOpen.InitData()
-- local test = print
local test = function()
end
function MainSysOpen.RightBtnDoTweenScale(isRight)
    if isRight then
        local bg = GUI.Get("MainUI/rightBg")
        local btn = GUI.Get("MainUI/rightBtn")
        if bg == nil or btn == nil then
            return
        end
        local vis = GUI.GetData(bg, "visiable")
        if vis == "true" then
            GUI.DOTween(bg, 3)
            GUI.DOTween(btn, 5)
            GUI.SetData(bg, "visiable", "false")
            return
        else
            return
        end
    else
        local bg = GUI.Get("MainUI/leftBg/leftBg_Top")
        local btn = GUI.Get("MainUI/leftBtn")
        if bg == nil or btn == nil then
            return
        end
        local vis = GUI.GetData(bg, "visiable")
        test("vis vis vis  : ", vis)
        if vis == "true" then
            GUI.DOTween(bg, 3)
            GUI.SetEulerAngles(btn, Vector3.New(0, 0, 90))
            GUI.SetData(bg, "visiable", "false")
            return
        else
            return
        end
    end
end

function MainSysOpen.SetBtn(type, longlv)
    if type ~= RoleAttr.RoleAttrLevel then
        return
    end
    if MainSysOpen.lvUpTimer == nil then
        MainSysOpen.lvUpTimer = Timer.New(MainSysOpen.SetBtnTimer, 0.5)
        MainSysOpen.lvUpTimer:Start()
    else
        Timer.Reset(MainSysOpen.lvUpTimer, MainSysOpen.SetBtnTimer, 0.5, 1, false)
        MainSysOpen.lvUpTimer:Start()
    end
end
function MainSysOpen.SetBtnTimer()
    local curlv, h, turnBron
    curlv, h = int64.longtonum2(CL.GetAttr(RoleAttr.RoleAttrLevel))
    turnBron = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
    test("LvUp " .. curlv)
    test("LvUp " .. h)
    local leftBg_Top = guidt.GetUI("leftBg_Top")
    local rightBg = guidt.GetUI("rightBg")
    local openBtn = {}

    local tmpp = {rightBg, leftBg_Top, leftBg_Top}
    for key, value in pairs(Mainbtns) do
        local index = 1
        for i = 1, #value do
            local cfg = MainUIBtnOpenDef.Data[value[i][6]]
            local btn = GUI.GetChild(tmpp[key], value[i][2], false)
            if btn then
                local visnum = cfg:VisFun(curlv, data.lv, turnBron)
                if visnum == -1 then
                    -- if cfg.Lv > curlv and turnBron<1 then
                    test("关闭" .. value[i][1])
                    GUI.SetVisible(btn, false)
                else
                    if visnum == 0 then
                        -- if data.lv and cfg.Lv > data.lv then
                        test("等待开启" .. value[i][1])
                        GUI.SetVisible(btn, false)
                        openBtn[#openBtn + 1] = {key = key, index = i}
                    else
                        test("开启" .. value[i][1])
                        GUI.SetVisible(btn, true)
                    end
                    local px, py = value.GetPos(index)
                    if value[i].posx then
                        px = value[i].posx
                    end
                    if value[i].posy then
                        py = value[i].posy
                    end
                    if value[i].posx == nil and value[i].posy == nil then
                        index = index + 1
                    end
                    test("x " .. px)
                    test("y " .. py)
                    GUI.SetPositionX(btn, px)
                    GUI.SetPositionY(btn, py)
                end
            end
        end
    end

    if #openBtn > 0 then
        MainSysOpen.StartIconTween(openBtn, 1)
    end
    if curlv ~= 0 then
        data.lv = curlv
    end
end
MainSysOpen.waitShowBtn = {}
function MainSysOpen.StartIconTween(openBtn, i)
    if i > #openBtn then
        return
    end
    local index = openBtn[i].index
    local key = openBtn[i].key
    local panel = GUI.GetWnd("MainUI")
    if panel == nil then
        return
    end
    local parent = nil
    local isLeft = true
    local buttonLst = Mainbtns[key]
    if key == 1 then
        parent = guidt.GetUI("rightBg")
    else
        parent = guidt.GetUI("leftBg_Top")
        isLeft = false
    end

    local bg = GUI.Get("MainUI/Openbg")
    if bg == nil then
        bg = GUI.ImageCreate(panel, "Openbg", "1800201100", 0, -85)
        local titile = GUI.ImageCreate(bg, "OpenTitle", "1800204440", -30, 40)
        GUI.SetAnchor(titile, UIAnchor.Top)
        local light = GUI.ImageCreate(bg, "OpenLight", "1800201090", -20, -20)
        local tw = TweenData.New()
        tw.Type = GUITweenType.DOLocalRotate
        tw.Duration = 1
        tw.From = Vector3.New(0, 0, 0)
        tw.To = Vector3.New(0, 0, 180)
        tw.LoopType = UITweenerStyle.Loop
        GUI.DOTween(light, tw)
    end
    local btn = GUI.GetChild(parent, buttonLst[index][2])

    local icon = GUI.ImageCreate(panel, "OpenIcon" .. key .. i, buttonLst[index][3], 0, 0)
    -- local showIcon = GUI.ImageCreate(icon, "OpenIconText", buttonLst[index][5], 0, 0, false)
    -- GUI.SetAnchor(showIcon, UIAnchor.Bottom)
    -- GUI.SetPivot(showIcon, UIAroundPivot.Bottom)
    local tween = TweenData.New()
    tween.Type = GUITweenType.DOLocalMove
    tween.Duration = 1
    tween.From = Vector3.New(-20, -105, 0)
    tween.LoopType = UITweenerStyle.Once

    local screenPoint = GUI.GetScreenPoint(GUI.GetChild(parent, buttonLst[index][2]))
    local endP = GUI.GetPointByScreenPoint(icon, screenPoint)
    endP.y = -endP.y

    tween.To = endP
    GUI.DOTween(icon, tween)

    openBtn[i] = ""
    GUI.SetData(icon, "guid", GUI.GetGuid(btn))

    -- slot(MainSysOpen.RemoveBg, nil)
    test(Mainbtns[key][index][1])
    test(Vector3.Distance(tween.From, tween.To))
    Timer.New(slot(MainSysOpen.RemoveBg, openBtn), Vector3.Distance(tween.From, tween.To) / 800):Start()
    Timer.New(slot(MainSysOpen.RemoveIcon, icon), 1):Start()
end
function MainSysOpen.RemoveBg(openBtn)
    for i = 1, #openBtn do
        if openBtn[i] ~= "" then
            MainSysOpen.StartIconTween(openBtn, i)
            return
        end
    end
    local bg = GUI.Get("MainUI/Openbg")
    --GUI.DOTween(bg,"SysBgClose");
    local fun = function()
        GUI.Destroy("MainUI/Openbg")
    end
    Timer.New(fun, 0.5):Start()
end
function MainSysOpen.RemoveIcon(openBtn)
    local var = openBtn
    if var ~= nil then
        GUI.SetVisible(GUI.GetByGuid(GUI.GetData(var, "guid")), true)
        GUI.Destroy(var)
        return
    end
end
function MainSysOpen.OnMain()
    guidt = UILayout.NewGUIDUtilTable()
    local leftBg_Top = GUI.Get("MainUI/leftBg/leftBg_Top")
    local leftBg_Left = GUI.Get("MainUI/leftBg/leftBg_Left")
    local leftBg_NoScale = GUI.Get("MainUI/leftBg/leftBg_NoScale")
    local rightBg = GUI.Get("MainUI/rightBg")
    guidt.BindName(rightBg, "rightBg")
    guidt.BindName(leftBg_Top, "leftBg_Top")
    MainSysOpen.waitShowBtn = {}
    CL.RegisterMessage(GM.CustomDataUpdate, "MainSysOpen", "OnCustomDataUpdate")
    CL.RegisterAttr(RoleAttr.RoleAttrLevel, MainSysOpen.SetBtn)
    MainSysOpen.SetBtn(RoleAttr.RoleAttrLevel, CL.GetAttr(RoleAttr.RoleAttrLevel))
end

function MainSysOpen.OnCustomDataUpdate(type, key, val)
    if key == "GotFirstRecharge" then
        MainSysOpen.SetBtn(RoleAttr.RoleAttrLevel, CL.GetAttr(RoleAttr.RoleAttrLevel))
    end
end

function MainSysOpen.OnShow(parameter)
end
function MainSysOpen.OnDestroy()
    MainSysOpen.OnClose()
end
function MainSysOpen.OnClose()
    guidt = nil
    data = MainSysOpen.InitData()
    if MainSysOpen.lvUpTimer ~= nil then
        MainSysOpen.lvUpTimer:Stop()
        MainSysOpen.lvUpTimer = nil
    end
    CL.UnRegisterAttr(RoleAttr.RoleAttrLevel, MainSysOpen.SetBtn)
    CL.UnRegisterMessage(GM.CustomDataUpdate, "MainSysOpen", "OnCustomDataUpdate")
end
function MainSysOpen.Init()
    MainUI.AddOnMainEvt("MainSysOpen", "OnMain")
    MainUI.AddOnCloseEvt("MainSysOpen", "OnClose")
    MainUI.AddOnShowEvt("MainSysOpen", "OnShow")
    MainUI.AddOnDestroyEvt("MainSysOpen", "OnDestroy")
end
