local ScreenLockUI =
{
    IsPointDown = false,
    IsUnLock = false,
}
_G.ScreenLockUI = ScreenLockUI

-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local colorBG = Color.New(1, 1, 1, 1)
local color = Color.New(255/255, 255/255, 255/255, 255/255)

-- 锁屏界面
function ScreenLockUI.Main(parameter)
    local panel = GUI.WndCreateWnd("ScreenLockUI", "ScreenLockUI", 0, 0, eCanvasGroup.TopMost)
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)

    local panelCover = GUI.ImageCreate(panel, "PanelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    SetAnchorAndPivot(panelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(panelCover, colorBG)
    GUI.SetIsRaycastTarget(panelCover,true)
    panelCover:RegisterEvent(UCE.PointerClick)

    local slicerLock = GUI.SliderLockCreate(panelCover, "SliderLock", "1800208070", "1800208021", "1800208060", 0, 0, 443, 95, true, Transition.None, Direction.LeftToRight, false)
    GUI.SliderLockSetFillSize(slicerLock, Vector2.New(0, 0))
    GUI.SliderLockSetBgSize(slicerLock, Vector2.New(550, 100))
    GUI.SliderLockSetHandleSize(slicerLock, Vector2.New(90, 90))
    GUI.SliderLockSetText(slicerLock, "向右滑动解锁")
    GUI.SliderLockSetFontSize(slicerLock, 26)
    GUI.SliderLockSetLabel_Color(slicerLock, color)
    SetAnchorAndPivot(slicerLock, UIAnchor.Center, UIAroundPivot.Center)
    slicerLock:RegisterEvent(UCE.PointerUp)
    slicerLock:RegisterEvent(UCE.PointerDown)
    GUI.RegisterUIEvent(slicerLock, UCE.PointerDown, "ScreenLockUI", "OnScreenLockUIDown")
    GUI.RegisterUIEvent(slicerLock, UCE.PointerUp, "ScreenLockUI", "OnScreenLockUIUp")
    GUI.RegisterUIEvent(slicerLock, ULE.SliderUnlock, "ScreenLockUI", "OnSliderUnlock")
end

function ScreenLockUI.OnShow(parameter)
    ScreenLockUI.IsPointDown = false
    ScreenLockUI.IsUnLock = false
end

function ScreenLockUI.OnScreenLockUIDown()
    ScreenLockUI.IsPointDown = true
end

function ScreenLockUI.OnScreenLockUIUp()
    ScreenLockUI.IsPointDown = false
    if ScreenLockUI.IsUnLock then
        GUI.DestroyWnd("ScreenLockUI")
    end
end

function ScreenLockUI.OnSliderUnlock()
    ScreenLockUI.IsUnLock = true
    if not ScreenLockUI.IsPointDown then
        GUI.DestroyWnd("ScreenLockUI")
    end
end