local AchievementPopupUI = {}
_G.AchievementPopupUI = AchievementPopupUI

--成就弹窗界面

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

------------------------------------------Start 颜色配置 Start----------------------------------
local RedColor = UIDefine.RedColor
local Brown4Color = UIDefine.Brown4Color
local Brown6Color = UIDefine.Brown6Color
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
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------


----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

--------------------------------------------End 表配置 End------------------------------------

function AchievementPopupUI.Main(parameter)
    
    local panel = GUI.WndCreateWnd("AchievementPopupUI" , "AchievementPopupUI" , 0 , 0 ,eCanvasGroup.Top)
    SetSameAnchorAndPivot(panel, UILayout.Center)


    local achievementPopupBg = GUI.ImageCreate(panel, "achievementPopupBg", "1801100010", 0, -18,false,440,130,false)
    _gt.BindName(achievementPopupBg,"achievementPopupBg")
    SetAnchorAndPivot(achievementPopupBg, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local friendshipTxt = GUI.CreateStatic(achievementPopupBg, "friendshipTxt", "成 就 完 成", 0, -5, 140, 40, "system", true, false);
    SetAnchorAndPivot(friendshipTxt, UIAnchor.Top, UIAroundPivot.Top)
    GUI.StaticSetFontSize(friendshipTxt, 22);
    GUI.StaticSetAlignment(friendshipTxt, TextAnchor.MiddleCenter);
    GUI.SetColor(friendshipTxt, colorDark);

    local leftNarrow = GUI.ImageCreate(friendshipTxt, "leftNarrow2", "1800800050", 0, 0)
    SetAnchorAndPivot(leftNarrow, UIAnchor.Left, UIAroundPivot.Right)

    local rightNarrow = GUI.ImageCreate(friendshipTxt, "rightNarrow2", "1800800060", 0, 0)
    SetAnchorAndPivot(rightNarrow, UIAnchor.Right, UIAroundPivot.Left)

    local achievementIcon = GUI.ItemCtrlCreate(achievementPopupBg,"achievementIcon",QualityRes[1],30,-10,65,65,false,"system",false)
    GUI.ItemCtrlSetElementRect(achievementIcon,eItemIconElement.Icon,0,-1,45,45)
    SetAnchorAndPivot(achievementIcon, UIAnchor.Left, UIAroundPivot.Left)
    GUI.RegisterUIEvent(achievementIcon, UCE.PointerClick, "AchievementPopupUI", "OnAchievementIconClick")

    -- 添加转圈特效
    local effect = GUI.SpriteFrameCreate(achievementIcon, "effect", "", 0, 0)
    GUI.SetFrameId(effect, "3404200000")
    SetAnchorAndPivot(effect, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SpriteFrameSetIsLoop(effect, true)
    local scale = 1.2
    GUI.SetScale(effect, Vector3.New(scale,scale,scale))--缩放
    GUI.Play(effect)

    -- 添加转圈特效
    local effect2 = GUI.SpriteFrameCreate(achievementIcon, "effect2", "", 0, 0)
    GUI.SetFrameId(effect2, "3404200000")
    SetAnchorAndPivot(effect2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SpriteFrameSetIsLoop(effect2, true)
    local scale = 1.2
    GUI.SetScale(effect2, Vector3.New(scale,scale,scale))--缩放
    GUI.Play(effect2)

    local achievementContent = GUI.CreateStatic(achievementIcon, "achievementContent", "aaaaaaaaaaaaaaaaaaaaaaa", 10, -5, 295, 110)
    SetAnchorAndPivot(achievementContent, UIAnchor.Right, UIAroundPivot.Left)
    GUI.SetColor(achievementContent, UIDefine.BrownColor)
    GUI.StaticSetAlignment(friendshipTxt, TextAnchor.MiddleLeft);
    GUI.StaticSetFontSize(achievementContent, 22)

    --local goBtn = GUI.ButtonCreate(achievementPopupBg, "goBtn", "1800402110", -30, -5, Transition.ColorTint, "前 往", 110, 45, false)
    --_gt.BindName(goBtn,"goBtn")
    --GUI.ButtonSetTextFontSize(goBtn, 22)
    --GUI.ButtonSetTextColor(goBtn, UIDefine.Brown3Color)
    --SetAnchorAndPivot(goBtn, UIAnchor.Right, UIAroundPivot.Right)
    --GUI.SetEventCD(goBtn,UCE.PointerClick, 1)
    --GUI.RegisterUIEvent(goBtn, UCE.PointerClick, "AchievementPopupUI", "OnRefreshBtnClick")

    local closeBtn = GUI.ButtonCreate(achievementPopupBg, "closeBtn", "1800502040", 0, 0, Transition.ColorTint,"")
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.SetEventCD(closeBtn,UCE.PointerClick, 1)
    local scale = 0.6
    GUI.SetScale(closeBtn, Vector3.New(scale,scale,scale))--缩放
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "AchievementPopupUI", "OnExit")


end


function AchievementPopupUI.OnShow(parameter)
    local wnd = GUI.GetWnd("AchievementPopupUI");
    if wnd == nil then
        return
    end
    AchievementPopupUI.Init()
    GUI.SetVisible(wnd, true)

end

function AchievementPopupUI.Init()

end

function AchievementPopupUI.RefreshAllData()
    test("服务器器调用")

    AchievementPopupUI.RefreshTipsTimer = nil
    AchievementPopupUI.RefreshTipsTimer1 = nil

    local achievementIconId = AchievementPopupUI.Icon
    local achievementContentTxt = AchievementPopupUI.Info

    AchievementPopupUI.SetTime = AchievementPopupUI.Duration

    test("AchievementPopupUI.Icon===========================",AchievementPopupUI.Icon)
    test("AchievementPopupUI.Info===========================",AchievementPopupUI.Info)
    test("AchievementPopupUI.Duration===========================",AchievementPopupUI.Duration)

    local achievementPopupBg = _gt.GetUI("achievementPopupBg")

    local achievementIcon = GUI.GetChild(achievementPopupBg,"achievementIcon",false)
    GUI.ItemCtrlSetElementValue(achievementIcon,eItemIconElement.Icon,achievementIconId)

    local achievementContent = GUI.GetChild(achievementIcon,"achievementContent",false)
    GUI.StaticSetText(achievementContent,achievementContentTxt)

    AchievementPopupUI.StartTipsTimer()

end


function AchievementPopupUI.StartTipsTimer()
    test("计时器启动")
    local fun = function()
        AchievementPopupUI.ReturnTipsTimer()
    end
    AchievementPopupUI.StopTipsTimer()
    AchievementPopupUI.RefreshTipsTimer = Timer.New(fun, 1, AchievementPopupUI.SetTime +2)
    AchievementPopupUI.time = os.time()
    AchievementPopupUI.RefreshTipsTimer:Start()
end

function AchievementPopupUI.ReturnTipsTimer()

    test("os.time()",os.time())
    test("AchievementPopupUI.time + AchievementPopupUI.SetTime",(AchievementPopupUI.time + AchievementPopupUI.SetTime))
    if os.time() >= AchievementPopupUI.time + AchievementPopupUI.SetTime then

        AchievementPopupUI.StopTipsTimer()

    end

end

--计时器停止
function AchievementPopupUI.StopTipsTimer()

    if AchievementPopupUI.RefreshTipsTimer ~= nil then
        test("计时器停止")

        AchievementPopupUI.RefreshTipsTimer:Stop()
        AchievementPopupUI.RefreshTipsTimer = nil

        local achievementPopupBg = _gt.GetUI("achievementPopupBg")
        local times = 2
        local tween = TweenData.New()
        tween.Type = GUITweenType.DOGroupAlpha
        tween.LoopType = UITweenerStyle.Once
        tween.From = Vector3.New(1, 0, 0)
        tween.To = Vector3.New(0, 0, 0)
        tween.Duration = times
        GUI.DOTween(achievementPopupBg, tween)

        AchievementPopupUI.StartTipsTimer1()

    end

end

function AchievementPopupUI.StartTipsTimer1()
    test("计时器1启动")
    local fun = function()
        AchievementPopupUI.ReturnTipsTimer1()
    end
    AchievementPopupUI.StopTipsTimer1()
    AchievementPopupUI.RefreshTipsTimer1 = Timer.New(fun, 1, 5)
    AchievementPopupUI.time1 = os.time()
    AchievementPopupUI.RefreshTipsTimer1:Start()
end

function AchievementPopupUI.ReturnTipsTimer1()

    if os.time() >= AchievementPopupUI.time1 + 2 then

        AchievementPopupUI.StopTipsTimer1()

    end

end

--计时器停止
function AchievementPopupUI.StopTipsTimer1()


    if AchievementPopupUI.RefreshTipsTimer1 ~= nil then
        test("计时器1停止")

        AchievementPopupUI.RefreshTipsTimer1:Stop()
        AchievementPopupUI.RefreshTipsTimer1 = nil

        AchievementPopupUI.OnExit()

    end

end

function AchievementPopupUI.OnExit()
    test("===============================")
    GUI.DestroyWnd("AchievementPopupUI")
    
end