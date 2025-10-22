ExamUI = {}

local _gt = UILayout.NewGUIDUtilTable()
ExamUI.CanOperation = true
ExamUI.LeftTimeText = nil
ExamUI.RightNum = 0     --答对个数
ExamUI.TotalNum = 0     --总答题数
ExamUI.EndTime = 0      --结束时间戳
ExamUI.LeftTimeTimer = nil
ExamUI.Desc = ""        --描述
ExamUI.RewardCoinType1 = 0      --货币类型1
ExamUI.RewardCoinType2 = 0      --货币类型2
ExamUI.RewardCoin1 = 0          --货币类型1累计值
ExamUI.RewardCoin2 = 0          --货币类型2累计值
ExamUI.QuestionIndex = 1        --当前第几题
ExamUI.RightAnswerIndex = 0     --正确题号索引：从1开始
ExamUI.MyAnswerIndex = 0
ExamUI.HaveQualifications = false
ExamUI.ShowNextQuestionTimer = nil
ExamUI.Question = ""
ExamUI.Answer1 = ""
ExamUI.Answer2 = ""
ExamUI.Answer3 = ""
ExamUI.Answer4 = ""
ExamUI.Func1Num = 0
ExamUI.Func2Num = 0
ExamUI.Func3Num = 0
ExamUI.RemovedAnswer = 0
ExamUI.Type = 1         --1,2,3对应乡试，会试，殿试
ExamUI.TypeAnswerInterface = {"XiangShiReceiveAnswer", "HuiShiReceiveAnswer", "DianShiReceiveAnswer"}
ExamUI.TimeOutCloseNotifyInterface = {"XiangShiCloseWin", "HuiShiCloseWin", "DianShiCloseWin"}
ExamUI.FuncBtnInterface = {
    [1] = { "XiangShiFindRightAnswer", "XiangShiDeleteErrorAnswer", "XiangShiChangeQuestion" },
    [2] = { "HuiShiFindRightAnswer", "HuiShiDeleteErrorAnswer", "HuiShiChangeQuestion" },
    [3] = { "DianShiFindRightAnswer", "DianShiDeleteErrorAnswer", "DianShiChangeQuestion" }
}
ExamUI.WinCloseNotifyInterface = {"0", "HuiShiClickClose", "DianShiClickClose"}
ExamUI.EndFlag = false

function ExamUI.Main(parameter)
    _gt = UILayout.NewGUIDUtilTable()

    local panel = GUI.WndCreateWnd("ExamUI", "ExamUI", 0, 0, eCanvasGroup.Normal)
    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)
    panel:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(panel, true)

    local panelCover = GUI.ImageCreate( panel,"panelCover", "1800400220", 0, 0, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
    UILayout.SetSameAnchorAndPivot(panelCover, UILayout.Center)
    panelCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(panelCover, true)

    -- 底图
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "科举考试","ExamUI","OnClose",_gt)

    -- 答对题数信息
    local correctness = GUI.CreateStatic( panelBg,"correctness", "答对题数    0/0", 155, 55, 250, 30, "system", true)
    _gt.BindName(correctness, "correctness")
    UILayout.SetSameAnchorAndPivot(correctness, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(correctness, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleLeft)

    -- 活动剩余时间
    local leftTimeBg = GUI.ImageCreate( panelBg,"leftTimeBg", "1800400200", 76, 88, false, 320, 72)
    UILayout.SetSameAnchorAndPivot(leftTimeBg, UILayout.TopLeft)

    local leftTimeLabel = GUI.CreateStatic( leftTimeBg,"leftTimeLabel", "活动剩余时间", 0, 6, 250, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(leftTimeLabel, UILayout.Top)
    UILayout.StaticSetFontSizeColorAlignment(leftTimeLabel, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

    local leftTimeText = GUI.CreateStatic( leftTimeBg,"leftTimeText", "", 0, -6, 250, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(leftTimeText, UILayout.Bottom)
    UILayout.StaticSetFontSizeColorAlignment(leftTimeText, UIDefine.FontSizeM, UIDefine.Green7Color, TextAnchor.MiddleCenter)
    ExamUI.LeftTimeText = leftTimeText

    -- 玩法说明
    local howToPlayBg = GUI.ImageCreate( panelBg,"howToPlayBg", "1800400200", 76, 176, false, 320, 270)
    UILayout.SetSameAnchorAndPivot(howToPlayBg, UILayout.TopLeft)

    local howToPlayDescScroll = GUI.ScrollRectCreate(howToPlayBg, "howToPlayDescScroll", 0, 0, 300, 246, 0, false, Vector2.New(300,500), UIAroundPivot.TopLeft, UIAnchor.TopLeft, 1)
    UILayout.SetSameAnchorAndPivot(howToPlayDescScroll, UILayout.Center)
    GUI.ScrollRectSetChildAnchor(howToPlayDescScroll, UIAnchor.Top)
    GUI.ScrollRectSetChildPivot(howToPlayDescScroll, UIAroundPivot.Top)
    GUI.ScrollRectSetChildSpacing(howToPlayDescScroll, Vector2.New(0, 0))

    --科举介绍
    local howToPlayLabel = GUI.CreateStatic( howToPlayDescScroll,"howToPlayLabel", "", 0, 0, 300, 500, "system", true)
    _gt.BindName(howToPlayLabel, "howToPlayLabel")
    UILayout.SetSameAnchorAndPivot(howToPlayLabel, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(howToPlayLabel, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.UpperLeft)

    local qualifications = GUI.ImageCreate( panelBg,"qualifications", "1800604430", 140, 450)
    _gt.BindName(qualifications, "qualifications")
    UILayout.SetSameAnchorAndPivot(qualifications, UILayout.TopLeft)
    GUI.SetVisible(qualifications, false)

    -- 获得经验
    local getExpTextTip = GUI.CreateStatic( panelBg,"getExpTextTip", "获得经验", 100, 496, 100, 30, "system", true)
    _gt.BindName(getExpTextTip, "RewardCoinType1")
    UILayout.SetSameAnchorAndPivot(getExpTextTip, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(getExpTextTip, UIDefine.FontSizeM, UIDefine.BrownColor, nil)

    local getExpTextBg = GUI.ImageCreate( panelBg,"getExpTextBg", "1800900040", 200, 497, false, 150, 30)
    UILayout.SetSameAnchorAndPivot(getExpTextBg, UILayout.TopLeft)

    local expIcon = GUI.ImageCreate( getExpTextBg,"expIcon", "1800408330", -6, -2)
    _gt.BindName(expIcon, "RewardCoinPic1")
    UILayout.SetSameAnchorAndPivot(expIcon, UILayout.Left)

    local getExpText = GUI.CreateStatic( getExpTextBg,"getExpText", "", 14, 0, 150, 30, "system", true)
    _gt.BindName(getExpText, "RewardCoinTxt1")
    UILayout.SetSameAnchorAndPivot(getExpText, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(getExpText, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

    -- 获得银币
    local getBindGoldTextTip = GUI.CreateStatic( panelBg,"getBindGoldTextTip", "获得银币", 100, 544, 100, 30, "system", true)
    _gt.BindName(getBindGoldTextTip, "RewardCoinType2")
    UILayout.SetSameAnchorAndPivot(getBindGoldTextTip, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(getBindGoldTextTip, UIDefine.FontSizeM, UIDefine.BrownColor, nil)

    local getBindGoldTextBg = GUI.ImageCreate( panelBg,"getBindGoldTextBg", "1800900040", 200, 545, false, 150, 30)
    UILayout.SetSameAnchorAndPivot(getBindGoldTextBg, UILayout.TopLeft)

    local bindGoldIcon = GUI.ImageCreate( getBindGoldTextBg,"bindGoldIcon", "1800408280", -6, -2)
    _gt.BindName(bindGoldIcon, "RewardCoinPic2")
    UILayout.SetSameAnchorAndPivot(bindGoldIcon, UILayout.Left)

    local getBindGoldText = GUI.CreateStatic( getBindGoldTextBg,"getBindGoldText", "", 14, 0, 150, 30, "system", true)
    _gt.BindName(getBindGoldText, "RewardCoinTxt2")
    UILayout.SetSameAnchorAndPivot(getBindGoldText, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(getBindGoldText, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

    -- 第几题
    local writingBrush = GUI.ImageCreate( panelBg,"writingBrush", "1800607300", 430, 47)
    UILayout.SetSameAnchorAndPivot(writingBrush, UILayout.TopLeft)
    GUI.SetVisible(writingBrush, true)

    local writingBrushBg = GUI.ImageCreate( panelBg,"writingBrushBg", "1800600340", 455, 50)
    UILayout.SetSameAnchorAndPivot(writingBrushBg, UILayout.TopLeft)
    GUI.SetVisible(writingBrushBg, true)

    local questionNum = GUI.CreateStatic( panelBg,"questionNum", "", 485, 50, 250, 40, "system", true)
    _gt.BindName(questionNum, "questionNum")
    UILayout.SetSameAnchorAndPivot(questionNum, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(questionNum, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

    -- 此题剩余时间
    local thisQuestionLeftTime = GUI.CreateStatic( panelBg,"thisQuestionLeftTime", "", 1036, 62, 100, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(thisQuestionLeftTime, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(thisQuestionLeftTime, UIDefine.FontSizeL, UIDefine.Green7Color, TextAnchor.MiddleLeft)

    -- 题目背景
    local questionBg = GUI.ImageCreate( panelBg,"questionBg", "1800400200", 412, 88, false, 700, 512)
    UILayout.SetSameAnchorAndPivot(questionBg, UILayout.TopLeft)

    -- 等待题目刷新
    local waitTipBg = GUI.ImageCreate( questionBg,"waitTipBg", "1800600840", 0, 86)
    UILayout.SetSameAnchorAndPivot(waitTipBg, UILayout.Top)
    GUI.SetVisible(waitTipBg, false)

    local waitTip = GUI.CreateStatic( waitTipBg,"waitTip", "题目刷新中...", 0, 0, 180, 40, "system", true)
    UILayout.SetSameAnchorAndPivot(waitTip, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(waitTip, 26, Color.New(103/255, 61/255, 30/255, 1, TextAnchor.MiddleCenter))

    local loadingBg = GUI.ImageCreate( waitTipBg,"loadingBg", "1800600830", -144, 0)
    UILayout.SetSameAnchorAndPivot(loadingBg, UILayout.Left)

    local loading = GUI.ImageCreate( loadingBg,"loading", "1800600831", 0, 0)
    UILayout.SetSameAnchorAndPivot(loading, UILayout.Center)

    local question = GUI.CreateStatic( questionBg,"question", "", 0, 10, 630, 60, "system", true)
    _gt.BindName(question, "question")
    UILayout.SetSameAnchorAndPivot(question, UILayout.Top)
    UILayout.StaticSetFontSizeColorAlignment(question, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

    -- 四个答案
    for i = 1, 4 do
        local posX = 12 + ((i - 1) % 2) * 340
        local posY = 80 + math.floor((i - 1) / 2) * 103
        local answerBtn = GUI.ButtonCreate( questionBg,"answerBtn" .. i, "1800602080", posX, posY, Transition.ColorTint, "")
        UILayout.SetSameAnchorAndPivot(answerBtn, UILayout.TopLeft)
        _gt.BindName(answerBtn, "answerBtn"..i)
        GUI.SetData(answerBtn, "index", tostring(i))
        GUI.RegisterUIEvent(answerBtn, UCE.PointerClick , "ExamUI", "OnAnswerBtnClick")
        GUI.SetVisible(answerBtn, true)
        --GUI.ButtonSetShowDisable(answerBtn, true)

        local answerText = GUI.CreateStatic( answerBtn,"answerText", "", 0, 0, 334, 96, "system", true)
        _gt.BindName(answerText, "answerText"..i)
        UILayout.SetSameAnchorAndPivot(answerText, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(answerText, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local answerMarkRight = GUI.ImageCreate( answerBtn,"answerMarkRight", "1800608400", -5, 0)
        _gt.BindName(answerMarkRight, "answerMarkRight"..i)
        UILayout.SetSameAnchorAndPivot(answerMarkRight, UILayout.Right)
        GUI.SetVisible(answerMarkRight, false)

        local answerMarkWrong = GUI.ImageCreate( answerBtn,"answerMarkWrong", "1800608390", -5, 0)
        _gt.BindName(answerMarkWrong, "answerMarkWrong"..i)
        UILayout.SetSameAnchorAndPivot(answerMarkWrong, UILayout.Right)
        GUI.SetVisible(answerMarkWrong, false)
    end

    --三种过关方式
    local getAnswerLabelList = {"1800604100", "1800604110", "1800604120"}
    local getAnswerWayList = {"系统作答", "系统提示", "切换试题"}
    local getAnswerWayRateList = {"直接选择正确答案", "去掉一个错误答案", "换成一道全新试题"}
    for i = 1, 3 do
        local getAnswerBg = GUI.ImageCreate( questionBg,"getAnswerBg" .. i, "1800600320", 12 + (i - 1) * 225, 287, false, 224, 215, false)
        UILayout.SetSameAnchorAndPivot(getAnswerBg, UILayout.TopLeft)

        local getAnswerBtn = GUI.ButtonCreate( getAnswerBg,"getAnswerBtn" .. i, "1800600330", 0, 5, Transition.ColorTint)
        _gt.BindName(getAnswerBtn, "getAnswerBtn"..i)
        GUI.SetData(getAnswerBtn, "index", i)
        UILayout.SetSameAnchorAndPivot(getAnswerBtn, UILayout.Top)
        GUI.RegisterUIEvent(getAnswerBtn, UCE.PointerClick , "ExamUI", "OnGetAnswerBtnClick")
        GUI.ButtonSetShowDisable(getAnswerBtn, false)

        local foo = GUI.ImageCreate( getAnswerBtn,"foo", getAnswerLabelList[i], 0, 0)
        UILayout.SetSameAnchorAndPivot(foo, UILayout.Center)

        local getAnswerWayItemNum = GUI.CreateStatic( getAnswerBg,"getAnswerWayItemNum", "0", 0, 3, 100, 30, "system", true)
        _gt.BindName(getAnswerWayItemNum, "getAnswerWayItemNum"..i)
        UILayout.SetSameAnchorAndPivot(getAnswerWayItemNum, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(getAnswerWayItemNum, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
        GUI.StaticSetText(getAnswerWayItemNum, 0)

        local getAnswerWay = GUI.CreateStatic( getAnswerBg,"getAnswerWay" .. i, getAnswerWayList[i], 0, 145, 170, 30, "system", true)
        UILayout.SetSameAnchorAndPivot(getAnswerWay, UILayout.Top)
        UILayout.StaticSetFontSizeColorAlignment(getAnswerWay, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

        local getAnswerWayRate = GUI.CreateStatic( getAnswerBg,"getAnswerWayRate" .. i, getAnswerWayRateList[i], 0, 175, 220, 30, "system", true)
        UILayout.SetSameAnchorAndPivot(getAnswerWayRate, UILayout.Top)
        UILayout.StaticSetFontSizeColorAlignment(getAnswerWayRate, UIDefine.FontSizeM, UIDefine.Green7Color, TextAnchor.MiddleCenter)
    end
end

function ExamUI.OnGetAnswerBtnClick(guid)
    if not ExamUI.CanOperation then
        return
    end
    local btn = GUI.GetByGuid(guid)
    if btn then
        local index = tonumber(GUI.GetData(btn, "index"))
        ExamUI.MyAnswerIndex = 0
        if index == 1 then
            ExamUI.CanOperation = false
        elseif index == 3 then
            ExamUI.RightAnswerIndex = 0
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormKeJu", ExamUI.FuncBtnInterface[ExamUI.Type][index])
    end
end

function ExamUI.OnAnswerBtnClick(guid)
    --点击后，不能再继续操控
    if ExamUI.CanOperation and not ExamUI.EndFlag then
        ExamUI.CanOperation = false

        local btn = GUI.GetByGuid(guid)
        local index = GUI.GetData(btn, "index")
        GUI.ButtonSetShowDisable(btn, false)
        ExamUI.MyAnswerIndex = tonumber(index)
        --向服务器发送选择答案
        CL.SendNotify(NOTIFY.SubmitForm, "FormKeJu", ExamUI.TypeAnswerInterface[ExamUI.Type], tostring(index))
    end
end

function ExamUI.OnClose()
    if ExamUI.Type ~= 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormKeJu", ExamUI.WinCloseNotifyInterface[ExamUI.Type], tostring(ExamUI.TotalNum))
    end
    GUI.DestroyWnd("ExamUI")
end

function ExamUI.OnShow()
end

function ExamUI.OnDestroy()
    if ExamUI.ShowNextQuestionTimer ~= nil then
        ExamUI.ShowNextQuestionTimer:Stop()
        ExamUI.ShowNextQuestionTimer = nil
    end
    if ExamUI.LeftTimeTimer ~= nil then
        ExamUI.LeftTimeTimer:Stop()
        ExamUI.LeftTimeTimer = nil
    end
end

--初始化界面刷新
function ExamUI.InitPanel()
    local txt = _gt.GetUI("howToPlayLabel")
    if txt then
        GUI.StaticSetText(txt, ExamUI.Desc)
    end

    ExamUI.LeftTimeTimer = Timer.New(ExamUI.LeftTimer, 1, -1)
    ExamUI.LeftTimeTimer:Start()

    txt = _gt.GetUI("RewardCoinType1")
    if txt then
        GUI.StaticSetText(txt, "获得"..UIDefine.AttrName[CL.ConvertAttr(ExamUI.RewardCoinType1)])
    end
    txt = _gt.GetUI("RewardCoinType2")
    if txt then
        GUI.StaticSetText(txt, "获得"..UIDefine.AttrName[CL.ConvertAttr(ExamUI.RewardCoinType2)])
    end
    local pic = _gt.GetUI("RewardCoinPic1")
    if pic then
        GUI.ImageSetImageID(pic, UIDefine.AttrIcon[CL.ConvertAttr(ExamUI.RewardCoinType1)])
    end
    pic = _gt.GetUI("RewardCoinPic2")
    if pic then
        GUI.ImageSetImageID(pic, UIDefine.AttrIcon[CL.ConvertAttr(ExamUI.RewardCoinType2)])
    end

    ExamUI.RightAnswerIndex = 0
    ExamUI.CanOperation = true
end

function ExamUI.LeftTimer()
    if ExamUI.LeftTimeTimer ~= nil then
        local str, day, hour, minute, second = UIDefine.LeftTimeFormatEx(ExamUI.EndTime)
        GUI.StaticSetText(ExamUI.LeftTimeText, string.format("%02d:%02d:%02d", hour, minute, second ))
        if day == 0 and hour == 0 and minute == 0 and second == 0 then
            CL.SendNotify(NOTIFY.SubmitForm, "FormKeJu", ExamUI.TimeOutCloseNotifyInterface[ExamUI.Type])
        end
    end
end

function ExamUI.RemoveOneAnswer()
    local funNums = {ExamUI.Func1Num,ExamUI.Func2Num,ExamUI.Func3Num}
    for i = 1, 3 do
        local btn = _gt.GetUI("getAnswerBtn"..i)
        if btn then
            GUI.ButtonSetShowDisable(btn, funNums[i]>0)
        end
        local txt = _gt.GetUI("getAnswerWayItemNum"..i)
        if txt then
            GUI.StaticSetText(txt, tostring(funNums[i]))
        end
    end
    local btn = _gt.GetUI("answerBtn"..ExamUI.RemovedAnswer)
    if btn then
        GUI.ButtonSetShowDisable(btn, false)
    end
end

--答题刷新
function ExamUI.RefreshPanel()
    local txt = _gt.GetUI("correctness")
    if txt then
        GUI.StaticSetText(txt, "答对题数    "..ExamUI.RightNum.."/"..ExamUI.TotalNum)
    end
    txt = _gt.GetUI("RewardCoinTxt1")
    if txt then
        GUI.StaticSetText(txt, tostring(ExamUI.RewardCoin1))
    end
    txt = _gt.GetUI("RewardCoinTxt2")
    if txt then
        GUI.StaticSetText(txt, tostring(ExamUI.RewardCoin2))
    end
    local pic = _gt.GetUI("qualifications")
    if pic then
        GUI.SetVisible(pic, ExamUI.HaveQualifications)
    end
    local funNums = {ExamUI.Func1Num,ExamUI.Func2Num,ExamUI.Func3Num}
    for i = 1, 3 do
        local btn = _gt.GetUI("getAnswerBtn"..i)
        if btn then
            GUI.ButtonSetShowDisable(btn, funNums[i]>0)
        end
        txt = _gt.GetUI("getAnswerWayItemNum"..i)
        if txt then
            GUI.StaticSetText(txt, tostring(funNums[i]))
        end
    end

    --显示正确或者错误的标记
    if ExamUI.RightAnswerIndex ~= 0 then
        for i = 1, 4 do
            local flagR = _gt.GetUI("answerMarkRight"..i)
            if flagR then
                GUI.SetVisible(flagR, ExamUI.RightAnswerIndex==i)
            end
            local flagW = _gt.GetUI("answerMarkWrong"..i)
            if flagW then
                GUI.SetVisible(flagW, ExamUI.MyAnswerIndex ~= ExamUI.RightAnswerIndex and ExamUI.MyAnswerIndex==i)
            end
        end
        --复位为0
        ExamUI.MyAnswerIndex = 0
        --结果展示0.5秒钟
        if ExamUI.EndFlag ~= true then
            if ExamUI.ShowNextQuestionTimer == nil then
                ExamUI.ShowNextQuestionTimer = Timer.New(ExamUI.OnShowNextQuestion, 0.5, 1)
            end
            ExamUI.ShowNextQuestionTimer:Start()
        else
            ExamUI.CanOperation = true
        end
    else
        ExamUI.OnShowNextQuestion()
    end
end

function ExamUI.OnShowNextQuestion()
    if ExamUI.ShowNextQuestionTimer ~= nil then
        ExamUI.ShowNextQuestionTimer:Stop()
        ExamUI.ShowNextQuestionTimer:Reset(ExamUI.OnShowNextQuestion, 0.5, 1)
    end

    --状态恢复
    for i = 1, 4 do
        local flagR = _gt.GetUI("answerMarkRight"..i)
        if flagR then
            GUI.SetVisible(flagR, false)
        end
        local flagW = _gt.GetUI("answerMarkWrong"..i)
        if flagW then
            GUI.SetVisible(flagW, false)
        end
        local btn = _gt.GetUI("answerBtn"..i)
        if btn then
            GUI.ButtonSetShowDisable(btn, true)
        end
    end

    --恢复操作权限
    ExamUI.CanOperation = true

    --显示下一题
    if ExamUI.Question ~= nil and string.len(ExamUI.Question) > 0 then
        local txt = _gt.GetUI("questionNum")
        if txt then
            GUI.StaticSetText(txt, "第"..ExamUI.QuestionIndex.."题")
        end
        txt = _gt.GetUI("question")
        if txt then
            GUI.StaticSetText(txt, ExamUI.Question)
        end
        local answers = {ExamUI.Answer1, ExamUI.Answer2, ExamUI.Answer3, ExamUI.Answer4}
        for i = 1, 4 do
            txt = _gt.GetUI("answerText"..i)
            if txt then
                GUI.StaticSetText(txt, answers[i])
            end
        end
    end
end