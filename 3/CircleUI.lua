CircleUI = {}
local guid = UILayout.NewGUIDUtilTable()
function CircleUI.Main(param)
    local panel = GUI.WndCreateWnd("CircleUI", "CircleUI", 0, 0, eCanvasGroup.TopMost)
    UILayout.SetSameAnchorAndPivot(panel,UILayout.Center)
    local sp = GUI.SpriteFrameCreate(panel, "offline", "", 0, 0)
    GUI.SetFrameId(sp, "3410200000")
    guid.BindName(sp, "sp")
    CL.RegisterMessage(GM.CircleUIRefresh, "CircleUI", "Refresh")
    if param == "1" then
        CircleUI.Show()
    else
        CircleUI.Hide()
    end
end
function CircleUI.OnShow(param)
    if param == "1" then
        CircleUI.Show()
    else
        CircleUI.Hide()
    end
end
function CircleUI.OnDestroy()
    CL.UnRegisterMessage(GM.CircleUIRefresh, "CircleUI", "Refresh")
end
function CircleUI.Refresh(isOffLine)
    if isOffLine == true then
        CircleUI.Show()
    else
        CircleUI.Hide()
    end
end
function CircleUI.Show()
    local sp = guid.GetUI("sp")
    GUI.Play(sp)
    GUI.SetVisible(sp, true)
end
function CircleUI.Hide()
    local sp = guid.GetUI("sp")
    GUI.Stop(sp)
    GUI.SetVisible(sp, false)
end