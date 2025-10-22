local WorldQuestionUI = {}

_G.WorldQuestionUI = WorldQuestionUI

---------------------------------缓存需要的全局变量Start------------------------------
local GUI = GUI
local UILayout = UILayout
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local UIDefine = UIDefine
---------------------------------缓存需要的全局变量End-------------------------------

local _gt = UILayout.NewGUIDUtilTable()

--local test = print
local test = function()  end

local isJoin = false

function WorldQuestionUI.Main(para)
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("WorldQuestionUI", "WorldQuestionUI", 0, 0, eCanvasGroup.Normal)
    UILayout.SetSameAnchorAndPivot(wnd, UILayout.Center)

    local panelBg = GUI.Get("ChatUI/chatBg/worldQuestionBg")
    if not panelBg then
        local chatBg = GUI.Get("ChatUI/chatBg")
        if chatBg then
            panelBg = GUI.ImageCreate(chatBg, "worldQuestionBg", "1801300060", 105, 85, false, 455, 135)
            UILayout.SetSameAnchorAndPivot(panelBg, UILayout.TopLeft)
            GUI.SetIsRaycastTarget(panelBg, true)

            -- 创建题目内容UI
            local contentTxt = GUI.CreateStatic(panelBg, "contentTxt", "", 25, 20, 400, 100, "system", true)
            UILayout.SetSameAnchorAndPivot(contentTxt, UILayout.TopLeft)
            GUI.StaticSetAlignment(contentTxt, TextAnchor.UpperLeft)
            GUI.StaticSetFontSize(contentTxt, UIDefine.FontSizeL)
            GUI.SetColor(contentTxt, UIDefine.Brown3Color)

            -- 创建答案文字UI
            local answerTxt = GUI.CreateStatic(panelBg, "answerTxt", "答案：", 50, 30, 300, 30, "system", true)
            UILayout.SetSameAnchorAndPivot(answerTxt, UILayout.Center)
            GUI.StaticSetAlignment(answerTxt, TextAnchor.MiddleRight)
            GUI.StaticSetFontSize(answerTxt, UIDefine.FontSizeL)
            GUI.SetColor(answerTxt, UIDefine.GreenColor)
            GUI.SetVisible(answerTxt, false)

            -- 创建答案图片UI
            local answerImg = GUI.ImageCreate(panelBg, "answerImg", "1801407250", 325, 80, true, 0, 0)
            UILayout.SetSameAnchorAndPivot(answerImg, UILayout.TopLeft)
            GUI.SetVisible(answerImg, false)

            -- 创建底部描述背景UI
            local descBg = GUI.ImageCreate(panelBg, "descBg", "1801401130", -15, 0, true, 0, 0)
            UILayout.SetAnchorAndPivot(descBg, UIAnchor.Bottom, UIAroundPivot.Top)

            -- 创建描述文字UI
            local descTxt = GUI.CreateStatic(descBg, "descTxt", "答题期间发言不消耗活力且冷却时间为20s", 0, 0, 400, 30, "system", true)
            UILayout.SetSameAnchorAndPivot(descTxt, UILayout.Center)
            GUI.StaticSetAlignment(descTxt, TextAnchor.MiddleCenter)
            GUI.StaticSetFontSize(descTxt, UIDefine.FontSizeSSS)
            GUI.SetColor(descTxt, UIDefine.WhiteColor)

            -- 创建标题背景UI
            local titleBg = GUI.ImageCreate(panelBg, "titleBg", "1801408230", -12, 0, true, 0, 0)
            UILayout.SetAnchorAndPivot(titleBg, UIAnchor.Right, UIAroundPivot.Left)

            -- 创建标题文字UI
            local titleTxt = GUI.CreateStatic(titleBg, "titleTxt", "世界答题", 0, -15, 30, 120, "system", true)
            UILayout.SetSameAnchorAndPivot(titleTxt, UILayout.Center)
            GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleCenter)
            GUI.StaticSetFontSize(titleTxt, UIDefine.FontSizeS)
            GUI.SetColor(titleTxt, UIDefine.WhiteColor)

            -- 创建计时器TimerUI
            local timerTxt = GUI.CreateStatic(titleBg, "timerTxt", "20s", 0, 55, 120, 30, "system", true)
            UILayout.SetSameAnchorAndPivot(timerTxt, UILayout.Center)
            GUI.StaticSetAlignment(timerTxt, TextAnchor.MiddleCenter)
            GUI.StaticSetFontSize(titleTxt, UIDefine.FontSizeS)
            GUI.SetColor(titleTxt, UIDefine.WhiteColor)

            GUI.SetVisible(panelBg, false)
        end
    end
end

function WorldQuestionUI.OnShow()

end

function WorldQuestionUI.IsShowPanelBg()
    return WorldQuestionUI.GlobalTimeTxt and WorldQuestionUI.GlobalTimeTxt ~= 0
end

function WorldQuestionUI.SetPanelBgVisible(visible)
    local panelBg = GUI.Get("ChatUI/chatBg/worldQuestionBg")
    if panelBg then
        GUI.SetVisible(panelBg, visible)
    end
end

--function WorldQuestionUI.OnClose()
--
--end

-- 答题开始时显示提示窗口
function WorldQuestionUI.ShowBoxMsg(times)
    times = tonumber(times) or 60
    isJoin = false

    GlobalUtils.ShowBoxMsg("提示",
            "世界答题开始了，有奖励哦~",
            "WorldQuestionUI",
            "参加", "OnJoinBtnClick",
            "忽略", "OnIgnoreBtnClick",
            true, "OnBoxMsgCloseBtnClick",
            1, times, false)
end

-- 忽略按钮
function WorldQuestionUI.OnIgnoreBtnClick()
    return
end

-- 参加按钮
function WorldQuestionUI.OnJoinBtnClick()
    isJoin = true

    GUI.OpenWnd("ChatUI", "index:8")
end

-- 关闭按钮
function WorldQuestionUI.OnBoxMsgCloseBtnClick()
    return
end

-- 刷新函数
function WorldQuestionUI.Refresh(question, answer, times)
    question = tostring(question) or ""

    local panelBg = GUI.Get("ChatUI/chatBg/worldQuestionBg")
    if panelBg then
        WorldQuestionUI.ShowBoxMsg(times)

        local contentTxt = GUI.GetChild(panelBg, "contentTxt", false)
        local timerTxt = GUI.Get("ChatUI/chatBg/worldQuestionBg/titleBg/timerTxt")
        local answerTxt = GUI.GetChild(panelBg, "answerTxt", false)
        local answerImg = GUI.GetChild(panelBg, "answerImg", false)
        GUI.StaticSetText(contentTxt, question)
        GUI.StaticSetText(answerTxt, "答案："..answer)
        GUI.SetVisible(answerTxt, false)
        GUI.SetVisible(answerImg, false)
        GUI.StaticSetText(timerTxt, times.."s")

        WorldQuestionUI.GlobalTimeTxt = times

        if WorldQuestionUI.RemainTimer then
            WorldQuestionUI.RemainTimer:Stop()
            WorldQuestionUI.RemainTimer:Reset(WorldQuestionUI.RefreshTimer, 1, -1)
        else
            WorldQuestionUI.RemainTimer = Timer.New(WorldQuestionUI.RefreshTimer, 1, -1)
        end
        WorldQuestionUI.RemainTimer:Start()

        GUI.SetVisible(panelBg, false)
    end

end

function WorldQuestionUI.RefreshTimer()
    WorldQuestionUI.GlobalTimeTxt = WorldQuestionUI.GlobalTimeTxt - 1
    local panelBg = GUI.Get("ChatUI/chatBg/worldQuestionBg")
    if panelBg then
        local timerTxt = GUI.Get("ChatUI/chatBg/worldQuestionBg/titleBg/timerTxt")
        GUI.StaticSetText(timerTxt, WorldQuestionUI.GlobalTimeTxt.."s")
        if WorldQuestionUI.GlobalTimeTxt == 0 then
            WorldQuestionUI.RemainTimer:Stop()
            local answerTxt = GUI.GetChild(panelBg, "answerTxt", false)
            local answerImg = GUI.GetChild(panelBg, "answerImg", false)
            if not GUI.GetVisible(answerImg) then
                GUI.SetVisible(answerTxt, true)
            end
        end
    end
end

function WorldQuestionUI.ShowAnswerImg()
    local panelBg = GUI.Get("ChatUI/chatBg/worldQuestionBg")
    if panelBg then
        local answerImg = GUI.GetChild(panelBg, "answerImg", false)
        GUI.SetVisible(answerImg, true)
        local answerTxt = GUI.GetChild(panelBg, "answerTxt", false)
        GUI.SetVisible(answerTxt, false)
    end
end