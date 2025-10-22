ActivityMatchBar = {}
local _gt = UILayout.NewGUIDUtilTable()

function ActivityMatchBar.Main()
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("ActivityMatchBar","ActivityMatchBar",0,0)
    UILayout.SetSameAnchorAndPivot(wnd, UILayout.Center)

    local battleRoyaleBarGroup = GUI.GroupCreate(wnd, "battleRoyaleBarGroup", 12, -450)
    UILayout.SetSameAnchorAndPivot(battleRoyaleBarGroup, UILayout.BottomLeft)
    GUI.StartGroupDrag(battleRoyaleBarGroup)

    _gt.BindName(battleRoyaleBarGroup, "battleRoyaleBarGroup")
    ActivityMatchBar.CreateBattleMainUI(battleRoyaleBarGroup)
end

function ActivityMatchBar.CreateBattleMainUI(parent)
    local plugBg = GUI.ImageCreate(parent, "plugBg", "1800600080", 0, 0, false, 288, 158)
    UILayout.SetSameAnchorAndPivot(plugBg, UILayout.TopLeft)
    local ActText = GUI.CreateStatic(plugBg, "ActText", "吃鸡争霸赛正在匹配中", 16, 10, 260, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(ActText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(ActText,"ActText")
    local waitCharChangText = GUI.CreateStatic(plugBg, "waitCharChangText", "...", 250, 10, 50, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(waitCharChangText, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(waitCharChangText,"waitCharChangText")
    local ActText2 = GUI.CreateStatic(plugBg, "ActText2", "当前匹配时间：", 16, 40, 200, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(ActText2, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    local ActMatchTime = GUI.CreateStatic(plugBg, "ActMatchTime", "10", 160, 40, 100, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(ActMatchTime, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(ActMatchTime,"ActMatchTime")

    local ActText3 = GUI.CreateStatic(plugBg, "ActText3", "开启活动还差：", 16, 70, 200, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(ActText3, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    local diffPlayerNum = GUI.CreateStatic(plugBg, "diffPlayerNum", "10", 160, 70, 100, 30, "system", false)
    UILayout.StaticSetFontSizeColorAlignment(diffPlayerNum, UIDefine.FontSizeM, UIDefine.WhiteColor,TextAnchor.TopLeft)
    _gt.BindName(ActText3,"ActText3")
    _gt.BindName(diffPlayerNum,"diffPlayerNum")

    local cancelMatchBtn = GUI.ButtonCreate(plugBg, "cancelMatchBtn", "1800602090", 0, -5, Transition.ColorTint, "取消匹配", 150, 50, false)
    GUI.RegisterUIEvent(cancelMatchBtn, UCE.PointerClick, "ActivityMatchBar", "OnCancelMatchBtnClick")
    UILayout.SetSameAnchorAndPivot(cancelMatchBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(cancelMatchBtn,UIDefine.White2Color)
    GUI.ButtonSetTextFontSize(cancelMatchBtn,UIDefine.FontSizeM)
    GUI.ButtonSetOutLineArgs(cancelMatchBtn, true, UIDefine.Orange2Color, 1)
    _gt.BindName(cancelMatchBtn, "cancelMatchBtn")

    GUI.SetIsRaycastTarget(plugBg, true)
    _gt.BindName(plugBg, "plugBg")
end
local charNum = {3,2,1,0,1,2}
local waitActOpenFun = function ()
    local index = ActivityMatchBar.waitTime % 6 + 1
    ActivityMatchBar.waitTime = ActivityMatchBar.waitTime + 1
    local curcharNum = charNum[index]
    local str = ""
    while curcharNum > 0 do
        str = str .. "."
        curcharNum = curcharNum - 1
    end
    local waitCharChangText = _gt.GetUI("waitCharChangText")
    GUI.StaticSetText(waitCharChangText, str)
    if ActivityMatchBar.waitActOpen then
        local diffPlayerNum = _gt.GetUI("diffPlayerNum")
        GUI.StaticSetText(diffPlayerNum, str)
    end
    local ActMatchTime = _gt.GetUI("ActMatchTime")
    local timer = CL.GetServerTickCount() - TrackUI.StarMatchTime
    local str = UIDefine.LeftTimeFormatEx2(timer,1)
    GUI.StaticSetText(ActMatchTime,str)
end

function ActivityMatchBar.Refresh()
    local ActMatchTime = _gt.GetUI("ActMatchTime")
    local diffPlayerNum = _gt.GetUI("diffPlayerNum")
    local ActText3 = _gt.GetUI("ActText3")
    local ActText = _gt.GetUI("ActText")
    local waitCharChangText = _gt.GetUI("waitCharChangText")
    if TrackUI and TrackUI.PersonsActMatchData then
        local act_id = TrackUI.PersonsActMatchData["act_id"]
        local min_player_num = TrackUI.PersonsActMatchData["min_player_num"]
        local now_player_num = TrackUI.PersonsActMatchData["now_player_num"]
        local diff_player_num = min_player_num - now_player_num
        local actDB = DB.GetActivity(act_id)
        if actDB and actDB.Id and actDB.Id ~= 0 then
            GUI.StaticSetText(ActText,actDB.Name .. "正在匹配中")
            GUI.SetPositionX(waitCharChangText,GUI.GetPositionX(ActText) + GUI.StaticGetLabelPreferWidth(ActText) + 10)
        end
        local timer = CL.GetServerTickCount() - TrackUI.StarMatchTime
        local str = UIDefine.LeftTimeFormatEx2(timer,1)
        GUI.StaticSetText(ActMatchTime,str)
        if diff_player_num <= 0 then
            GUI.StaticSetText(ActText3,"活动即将开启")
            GUI.StaticSetText(diffPlayerNum, "...")
            ActivityMatchBar.waitActOpen = true
        else
            GUI.StaticSetText(ActText3,"开启活动还差：")
            GUI.StaticSetText(diffPlayerNum,diff_player_num .. "人")
            ActivityMatchBar.waitActOpen = false
        end
    end
end

function ActivityMatchBar.OnExit()
    GUI.CloseWnd("ActivityMatchBar")
end

function ActivityMatchBar.OnShow()
    local wnd = GUI.GetWnd("ActivityMatchBar")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd,true)
    ActivityMatchBar.waitTime = 1
    if ActivityMatchBar.waitActTimer ~= nil then
        ActivityMatchBar.waitActTimer:Stop()
        ActivityMatchBar.waitActTimer:Reset(waitActOpenFun,0.5,-1)
    else
        ActivityMatchBar.waitActTimer = Timer.New(waitActOpenFun,0.5,-1)
    end
    ActivityMatchBar.Refresh()
    ActivityMatchBar.waitActTimer:Start()
end

function ActivityMatchBar.OnCancelMatchBtnClick()
    local act_id = TrackUI.PersonsActMatchData["act_id"]
    CL.SendNotify(NOTIFY.SubmitForm,"FormPersonsActMatch","EndMatch",act_id)
    GUI.CloseWnd("ActivityMatchBar")
end

function ActivityMatchBar.OnClose()
    ActivityMatchBar.waitActTimer:Stop()
end
