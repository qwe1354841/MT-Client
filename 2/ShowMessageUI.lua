ShowMessageUI = {}
ShowMessageUI.Sec = nil
local _gt = UILayout.NewGUIDUtilTable()

function ShowMessageUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("ShowMessageUI", "ShowMessageUI", 0, 0, eCanvasGroup.Normal_Extend)
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)

    local Message = GUI.CreateStatic(panel, "Message", "展示信息，展示信息", 0, -180, 800, 50,"100");
    UILayout.SetSameAnchorAndPivot(Message, UILayout.Center)
    GUI.StaticSetAlignment(Message, TextAnchor.MiddleCenter);
    GUI.SetIsOutLine(Message, true)
    GUI.SetOutLine_Distance(Message, UIDefine.OutLineDistance)
    GUI.SetColor(Message, UIDefine.White4Color)
    GUI.SetOutLine_Color(Message, Color.New(236/255,129/255,119/255,255/255))

    GUI.StaticSetFontSize(Message, 40);
    GUI.SetVisible(Message,false)
    _gt.BindName(Message,"Message")
end

function ShowMessageUI.OnShow(parameter)
    local wnd = GUI.GetWnd("ShowMessageUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
    if parameter then
        parameter = string.split(parameter,"#")
        local text = parameter[1]
        local sec = parameter[2]
        if sec and type(tonumber(sec)) == "number" then
            sec = tonumber(sec)
            ShowMessageUI.ShowMessage(text,sec)
        end
    end
end

function ShowMessageUI.OnClose()
    ShowMessageUI.CloseMessage()
    local wnd = GUI.GetWnd("ShowMessageUI")
    GUI.SetVisible(wnd, false)
end

function ShowMessageUI.ShowMessage(text,sec)
    ShowMessageUI.Sec = sec
    local Message = _gt.GetUI("Message")
    GUI.SetVisible(Message,true)
    GUI.StaticSetText(Message,text)
    if ShowMessageUI.Timer then
        ShowMessageUI.Timer:Stop()
        ShowMessageUI.Timer:Reset(ShowMessageUI.CheckShowMessage,1,-1)
    else
        ShowMessageUI.Timer = Timer.New(ShowMessageUI.CheckShowMessage,1,-1)
    end
    ShowMessageUI.Timer:Start()
    ShowMessageUI.CheckShowMessage()
end


function ShowMessageUI.CloseMessage()
    if ShowMessageUI.Timer then
        ShowMessageUI.Timer:Stop()
        ShowMessageUI.Timer = nil
    end
    local Message = _gt.GetUI("Message")
    GUI.SetVisible(Message,false)
end

function ShowMessageUI.CheckShowMessage()
    if ShowMessageUI.Sec and type(ShowMessageUI.Sec) == "number" then
        ShowMessageUI.Sec = ShowMessageUI.Sec - 1
        if ShowMessageUI.Sec <= 0 then
            ShowMessageUI.CloseMessage()
        end
    else
        ShowMessageUI.CloseMessage()
    end
end