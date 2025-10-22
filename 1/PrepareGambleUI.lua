local PrepareGambleUI = {}
_G.PrepareGambleUI = PrepareGambleUI

local _gt = UILayout.NewGUIDUtilTable()

--孤注一掷活动倒计时提示界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local _gt = UILayout.NewGUIDUtilTable()

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

------------------------------------------Start 颜色配置 Start----------------------------------
local RedColor = UIDefine.RedColor
local Brown4Color = UIDefine.Brown4Color
local Brown6Color = UIDefine.Brown6Color
local Yellow3Color = UIDefine.Yellow3Color
local Yellow2Color = UIDefine.Yellow2Color
local Yellow4Color = UIDefine.Yellow4Color
local Yellow5Color = UIDefine.Yellow5Color
local YellowStdColor = UIDefine.YellowStdColor
local YellowColor = UIDefine.YellowColor
local WhiteColor = UIDefine.WhiteColor
local White2Color = UIDefine.White2Color
local White3Color = UIDefine.White3Color
local GrayColor = UIDefine.GrayColor
local Gray2Color = UIDefine.Gray2Color
local Gray3Color = UIDefine.Gray3Color
local OrangeColor = UIDefine.OrangeColor
local GreenColor = UIDefine.GreenColor
local Green2Color = UIDefine.Green2Color
local Green3Color = UIDefine.Green3Color
local Blue3Color = UIDefine.Blue3Color
local Purple2Color = UIDefine.Purple2Color
local PinkColor = UIDefine.PinkColor
local OutLineDistance = UIDefine.OutLineDistance
local OutLine_BrownColor = UIDefine.OutLine_BrownColor
----------------------------------------------End 颜色配置 End-----------------------------------


------------------------------------------Start 全局变量 Start----------------------------------

local selfStatus = nil

local residueTime = 0

local enemyGUID = nil

local npcId = nil

----------------------------------------------End 全局变量 End-----------------------------------


------------------------------------------Start 表配置 Start----------------------------------


--------------------------------------------End 表配置 End------------------------------------


function PrepareGambleUI.Main()

    local wnd = GUI.WndCreateWnd("PrepareGambleUI", "PrepareGambleUI", 0, 0, eCanvasGroup.Normal)
    UILayout.SetSameAnchorAndPivot(wnd, UILayout.Center)

    local plugBarGroup = GUI.GroupCreate(wnd, "plugBarGroup", 12, -280, 218, 78)
    UILayout.SetSameAnchorAndPivot(plugBarGroup, UILayout.BottomLeft)
    GUI.StartGroupDrag(plugBarGroup)

    _gt.BindName(plugBarGroup, "plugBarGroup")

    local plugBg = GUI.ImageCreate(plugBarGroup, "plugBg", "1800600010", 5, 60, false, 240, 120,false)
    UILayout.SetSameAnchorAndPivot(plugBg, UILayout.Center)
    GUI.SetIsRaycastTarget(plugBg, true)

    _gt.BindName(plugBg, "plugBg")

    --提示信息
    local messageTxt = GUI.CreateStatic(plugBg,"messageTxt","" ,0,10,220, 60, "system", true, false)
    _gt.BindName(messageTxt,"messageTxt")
    GUI.StaticSetFontSize(messageTxt,20)
    GUI.StaticSetAlignment(messageTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(messageTxt, UILayout.Top)
    GUI.SetColor(messageTxt,Yellow3Color)


    local leaveForBtn = GUI.ButtonCreate(plugBg, "leaveForBtn", "1800602090", 25, -10, Transition.ColorTint, "前 往", 90, 40, false)
    _gt.BindName(leaveForBtn,"leaveForBtn")
    GUI.ButtonSetTextFontSize(leaveForBtn, 24)
    GUI.SetIsOutLine(leaveForBtn, true)
    GUI.ButtonSetTextColor(leaveForBtn, WhiteColor)
    GUI.SetOutLine_Color(leaveForBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(leaveForBtn,OutLineDistance)
    SetSameAnchorAndPivot(leaveForBtn, UILayout.BottomLeft)
    GUI.RegisterUIEvent(leaveForBtn, UCE.PointerClick, "PrepareGambleUI", "OnLeaveForBtnClick")

    local checkBtn = GUI.ButtonCreate(plugBg, "checkBtn", "1800602100", -25, -10, Transition.ColorTint, "查 看", 90, 40, false)
    _gt.BindName(checkBtn,"checkBtn")
    GUI.ButtonSetTextFontSize(checkBtn, 24)
    GUI.SetIsOutLine(checkBtn, true)
    GUI.ButtonSetTextColor(checkBtn, WhiteColor)
    GUI.SetOutLine_Color(checkBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(checkBtn,OutLineDistance)
    SetSameAnchorAndPivot(checkBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(checkBtn, UCE.PointerClick, "PrepareGambleUI", "OnCheckBtnClick")
end

function PrepareGambleUI.OnShow()
    local wnd = GUI.GetWnd("PrepareGambleUI")
    if not wnd then return end

    GUI.SetVisible(wnd, true)
    PrepareGambleUI.Init()

    PrepareGambleUI.StopTipsTimer()
end

function PrepareGambleUI.Init()

    selfStatus = nil

    enemyGUID = nil

    npcId = nil
end

function PrepareGambleUI.RefreshAllData()

    npcId = PrepareGambleUI.NpcId

    local now_time = tonumber(CL.GetServerTickCount())
    residueTime = PrepareGambleUI.Time - now_time

    selfStatus = PrepareGambleUI.State

    enemyGUID = PrepareGambleUI.EnemyGUID

    PrepareGambleUI.StartTipsTimer()
end

function PrepareGambleUI.StartTipsTimer()
    test("计时器启动")
    local fun = function()
        PrepareGambleUI.ReturnTipsTimer()
    end
    PrepareGambleUI.StopTipsTimer()
    PrepareGambleUI.RefreshTipsTimer = Timer.New(fun, 1, -1)
    PrepareGambleUI.RefreshTipsTimer:Start()
end

function PrepareGambleUI.ReturnTipsTimer()

    local messageTxt = _gt.GetUI("messageTxt")

    local txt = ""
    if selfStatus == 0 then
        txt = "您有一个挑战信息: ".."<color=#ff0000>" .. residueTime.. "</color>秒"
    elseif selfStatus == 1 then
        txt = "比赛开始剩余:".. "<color=#ff0000>"..residueTime.."</color>秒"
    end
    GUI.StaticSetText(messageTxt,txt)

    residueTime = residueTime - 1
    if residueTime <= 0 then
        PrepareGambleUI.StopTipsTimer()
    end
end

--计时器停止
function PrepareGambleUI.StopTipsTimer()
    if PrepareGambleUI.RefreshTipsTimer ~= nil then
        PrepareGambleUI.RefreshTipsTimer:Stop()
        PrepareGambleUI.RefreshTipsTimer = nil
    end

end

function PrepareGambleUI.OnLeaveForBtnClick()

    if npcId ~= nil then
        test("npcId",tostring(npcId))
        CL.StartMove(npcId)
    end


end

function PrepareGambleUI.OnCheckBtnClick()

    CL.SendNotify(NOTIFY.SubmitForm,"FormGamble","CheckFightMessage",enemyGUID)

end

function PrepareGambleUI.OnExit()
    PrepareGambleUI.StopTipsTimer()
    GUI.Destroy("PrepareGambleUI")
end
