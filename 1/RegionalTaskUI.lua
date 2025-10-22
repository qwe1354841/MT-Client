local RegionalTaskUI = {}
_G.RegionalTaskUI = RegionalTaskUI

--区域活动界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local _gt = UILayout.NewGUIDUtilTable()

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------ 

function RegionalTaskUI.Main()

    local wnd = GUI.WndCreateWnd("RegionalTaskUI", "RegionalTaskUI", 0, 0, eCanvasGroup.Normal)
    SetSameAnchorAndPivot(wnd, UILayout.Center)

    local regionalTaskGroup = GUI.GroupCreate(wnd, "regionalTaskGroup", 25, -10, 218, 78)
    SetSameAnchorAndPivot(regionalTaskGroup, UILayout.Left)
    GUI.StartGroupDrag(regionalTaskGroup)--开启拖拽

    local regionalTaskBg = GUI.ImageCreate(regionalTaskGroup, "regionalTaskBg", "1800600020", 5, 60, false, 240, 120,false)
    _gt.BindName(regionalTaskBg,"regionalTaskBg")
    SetSameAnchorAndPivot(regionalTaskBg, UILayout.Center)
    GUI.SetIsRaycastTarget(regionalTaskBg, true)
    regionalTaskBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(regionalTaskBg, UCE.PointerClick, "RegionalTaskUI", "OnRegionalTaskBgClick")

    local titleTxt = GUI.CreateStatic(regionalTaskBg, "titleTxt", "活动信息，活动信息", 10, -5, 300, 50,"system");
    SetSameAnchorAndPivot(titleTxt, UILayout.TopLeft)
    GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleLeft);
    GUI.SetIsOutLine(titleTxt, true)
    GUI.SetColor(titleTxt, UIDefine.White4Color)
    GUI.StaticSetFontSize(titleTxt, 20);

    local contextTxt = GUI.CreateStatic(regionalTaskBg, "contextTxt", "活动信息", 10, 55, 220, 80,"system",true,false);
    SetSameAnchorAndPivot(contextTxt, UILayout.TopLeft)
    GUI.StaticSetAlignment(contextTxt, TextAnchor.UpperLeft);
    GUI.SetIsOutLine(contextTxt, true)
    GUI.SetColor(contextTxt, UIDefine.GreenColor)
    GUI.StaticSetFontSize(contextTxt, 18);

    local titleTxt1 = GUI.CreateStatic(regionalTaskBg, "titleTxt1", "任务进度：", 10, 18, 90, 50,"system");
    SetSameAnchorAndPivot(titleTxt1, UILayout.TopLeft)
    GUI.StaticSetAlignment(titleTxt1, TextAnchor.MiddleLeft);
    GUI.SetIsOutLine(titleTxt1, true)
    GUI.SetColor(titleTxt1, UIDefine.YellowColor)
    GUI.StaticSetFontSize(titleTxt1, 18);

    --当前完成度进度条
    local width = 135
    local height = 25
    local endTimeBg = GUI.ScrollBarCreate(
            titleTxt1,
            "endTimeBg",
            "",
            "1801201070",
            "1801201080",
            -5,
            0,
            width,
            height,
            0,
            false,
            Transition.None,
            0,
            1,
            Direction.LeftToRight,
            false,
            false
    )
    GUI.ScrollBarSetFillSize(endTimeBg, Vector2.New(width, height))
    GUI.ScrollBarSetBgSize(endTimeBg, Vector2.New(width, height))
    SetAnchorAndPivot(endTimeBg, UIAnchor.Right, UIAroundPivot.Left)
    _gt.BindName(endTimeBg,"endTimeBg")

    local _Num = GUI.CreateStatic(titleTxt1,"Num", "", -5, 0, 140, 60, "system", true)
    _gt.BindName(_Num,"_Num")
    SetAnchorAndPivot(_Num, UIAnchor.Right, UIAroundPivot.Left)
    GUI.StaticSetFontSize(_Num, 18)
    GUI.StaticSetAlignment(_Num, TextAnchor.MiddleCenter)
    GUI.SetIsRaycastTarget(_Num, true)
    _Num:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(_Num , UCE.PointerClick , "RegionalTaskUI", "OnRegionalTaskBgClick")

    local closeBtn = GUI.ButtonCreate(regionalTaskBg,"GoToBtn", "1800602110",6,-6, Transition.ColorTint, "")
    SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.ButtonSetTextFontSize(closeBtn, 26)
    GUI.ButtonSetTextColor(closeBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(closeBtn,true)
    GUI.SetOutLine_Color(closeBtn,UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(closeBtn,1)
    GUI.RegisterUIEvent(closeBtn , UCE.PointerClick , "RegionalTaskUI", "OnCloseBtnClick")

end

function RegionalTaskUI.OnShow()
    local wnd = GUI.GetWnd("RegionalTaskUI")

    if not wnd then

        return

    end

    GUI.SetVisible(wnd, true)
    RegionalTaskUI.Init()

end

function RegionalTaskUI.Init()

end

--服务器回调刷新
function RegionalTaskUI.RefreshAllData(title)
    test("服务器回调刷新")

    local regionalTaskBg = _gt.GetUI("regionalTaskBg")

    test("title",title)


    test("RegionalTaskUI.TaskTitle",RegionalTaskUI.TaskTitle)
    test("RegionalTaskUI.Info",RegionalTaskUI.Info)

    local titleTxt = GUI.GetChild(regionalTaskBg,"titleTxt",false)
    GUI.StaticSetText(titleTxt,RegionalTaskUI.TaskTitle)

    local contextTxt = GUI.GetChild(regionalTaskBg,"contextTxt",false)
    GUI.StaticSetText(contextTxt,RegionalTaskUI.Info)

    local desPreferHeight = GUI.StaticGetLabelPreferHeight(contextTxt)
    GUI.SetHeight(contextTxt,desPreferHeight)

    local h = desPreferHeight + 65

    if h > 120 then

        GUI.SetHeight(regionalTaskBg,h)

    else

        GUI.SetHeight(regionalTaskBg,120)

    end


end

function RegionalTaskUI.RefreshEndTimeBgData()

    local endTimeBg = _gt.GetUI("endTimeBg")

    test("RegionalTaskUI.NowProgress",RegionalTaskUI.NowProgress)
    test("RegionalTaskUI.MaxProgress",RegionalTaskUI.MaxProgress)

    test("(RegionalTaskUI.NowProgress/RegionalTaskUI.MaxProgress)",(RegionalTaskUI.NowProgress/RegionalTaskUI.MaxProgress))
    local num = tonumber(string.format("%.2f", (RegionalTaskUI.NowProgress/RegionalTaskUI.MaxProgress)))
    test("num",num)
    if num > 1 then

        num = 1

    end
    GUI.ScrollBarSetPos(endTimeBg,num)

    local _Num = _gt.GetUI("_Num")

    GUI.StaticSetText(_Num,RegionalTaskUI.NowProgress.."/"..RegionalTaskUI.MaxProgress)


end

--请求活动详情数据
function RegionalTaskUI.OnRegionalTaskBgClick()
    test("请求活动详情数据")

    CL.SendNotify(NOTIFY.SubmitForm,"FormRegionTask","GetData",2)

end

function RegionalTaskUI.OnCloseBtnClick()
    
    GUI.CloseWnd("RegionalTaskUI")

end

