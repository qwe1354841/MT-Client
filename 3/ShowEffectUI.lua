ShowEffectUI = {}

local switchTime = 1
local forceCloseTime = 5
function ShowEffectUI.Main(parameter)
    local panel = GUI.WndCreateWnd("ShowEffectUI", "ShowEffectUI", 0, 0, eCanvasGroup.Normal_Extend)
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)

    local panelCover =
        GUI.ImageCreate(panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    -- GUI.SetColor(panelCover,UIDefine.HalfTransparent)

    GUI.SetAnchor(panelCover, UIAnchor.Center)
    GUI.SetPivot(panelCover, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(panelCover, true)
    -- panelCover:RegisterEvent(UCE.PointerClick)

    ShowEffectUI.DataInit()

end

function ShowEffectUI.DataInit()
    ShowEffectUI.livingTimer = nil
    ShowEffectUI.currentResId = 0
    ShowEffectUI.offTime = 0
    ShowEffectUI.callback = {}
    ShowEffectUI.closeCallback = nil
    ShowEffectUI.offTimer = nil


end

function ShowEffectUI.OnShow( parameter)
    local wnd = GUI.GetWnd("ShowEffectUI")
    if wnd == nil then
        return
    end

    GUI.SetVisible(wnd, true)

    --if ShowEffectUI.currentResId == 0 then
        ShowEffectUI.currentResId = tonumber(parameter)
        ShowEffectUI.Play()
    --end
end

function ShowEffectUI.Play()


    local effect = GUI.Get("ShowEffectUI/effect")
    if effect ~= nil then
        GUI.Destroy(effect)
    end

    local wnd = GUI.GetWnd("ShowEffectUI")
    effect = GUI.RawImageCreate(wnd, false, "effect", ShowEffectUI.currentResId, 0, 0, 2, false, 500, 500)
    local camereData = "(0,0,-1),(0,0,0,1),True,50,-0.01,1.64,81"
    GUI.RawImageSetCameraConfig(effect, camereData)
    GUI.AddToCamera(effect)
    GUI.SetIsRaycastTarget(effect,false);
    if ShowEffectUI.callback[ShowEffectUI.currentResId] ~= nil then
        ShowEffectUI.callback[ShowEffectUI.currentResId]()
    end
end

function ShowEffectUI.SetTimeOff(time)
    print("SetTimeOff "..tostring(time))
    if time == 0 then
        return
    end
    ShowEffectUI.offTime = time
    -- if #ShowEffectUI.waitResIds == 0 and ShowEffectUI.offTime ~= 0 then
    if ShowEffectUI.offTime ~= 0 then
        if ShowEffectUI.offTimer == nil then
            ShowEffectUI.offTimer = Timer.New(ShowEffectUI.OnTimeOff, ShowEffectUI.offTime, 1)
        else
            ShowEffectUI.offTimer:Stop()
            ShowEffectUI.offTimer:Reset(ShowEffectUI.OnTimeOff, ShowEffectUI.offTime, 1)
        end
        ShowEffectUI.offTimer:Start()
    end
end


function ShowEffectUI.AddCallback(resId, callback)
    ShowEffectUI.callback[resId] = callback
end

function ShowEffectUI.AddCloseCallback(callback)
    ShowEffectUI.closeCallback = callback
end

function ShowEffectUI.OnClose()
    if ShowEffectUI.offTimer then
        ShowEffectUI.offTimer:Stop()
        ShowEffectUI.offTimer = nil
    end


    if ShowEffectUI.closeCallback ~= nil then
        ShowEffectUI.closeCallback()
        ShowEffectUI.closeCallback = nil
    end

    ShowEffectUI.DataInit()

    local wnd = GUI.GetWnd("ShowEffectUI")
    GUI.SetVisible(wnd, false)
end

function ShowEffectUI.OnTimeOff()
    local wnd = GUI.GetWnd("ShowEffectUI")
    if wnd ~= nil then
        GUI.CloseWnd("ShowEffectUI")
    end
end
