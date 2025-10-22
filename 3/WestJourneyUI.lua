local WestJourneyUI = {
    Branch = 1, ---当前题目的第几题（一道题目可能包含3题）
}

_G.WestJourneyUI = WestJourneyUI
local GuidCacheUtil = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local answerCount = 3

local optionx = 228 --右侧选项x间隔
local optiony = -110 --右侧选项y值
local randIndex = {1, 2, 3} --- 用来随机题目答案坐标
local inspect = require("inspect")

function WestJourneyUI.Main()
    local panel = GUI.WndCreateWnd("WestJourneyUI", "WestJourneyUI", 0, 0, eCanvasGroup.Normal);
    SetAnchorAndPivot(panel, UIAnchor.Center, UIAroundPivot.Center)

    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "西游奇缘", "WestJourneyUI", "on_close_wnd")
    GuidCacheUtil.BindName(panelBg, "panelBg")
    local tipColor = Color.New(93 / 255, 61 / 255, 40 / 255, 255 / 255);


    --左侧界面父级
    --local leftbg = GUI.ImageCreate(panelBg, "leftbg", "", 240, 20);
    local leftbg = GUI.GroupCreate(panelBg, "leftbg", 240, 20,0,0);
    SetAnchorAndPivot(leftbg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --准确率
    local truelabel = GUI.CreateStatic(leftbg, "truelabel", "准确率      0/0", 0, 40, 320, 50, "system", true, false)
    GuidCacheUtil.BindName(truelabel, "truelabel")
    GUI.StaticSetFontSize(truelabel, 24)
    GUI.StaticSetAlignment(truelabel, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(truelabel, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetColor(truelabel, tipColor);

    --倒计时
    local timerbg = GUI.ImageCreate(leftbg, "timerbg", "1800400010", 0, 90, false, 320, 70)
    SetAnchorAndPivot(timerbg, UIAnchor.Top, UIAroundPivot.Top)

    local timerdesc = GUI.CreateStatic(timerbg, "timerdesc", "活动剩余时间", 0, 0, 320, 45, "system", true, false)
    GUI.StaticSetFontSize(timerdesc, 22)
    GUI.StaticSetAlignment(timerdesc, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(timerdesc, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetColor(timerdesc, tipColor);

    local timertext = GUI.CreateStatic(timerbg, "timertext", "  :  :  ", 0, 0, 320, 45, "system", true, false)
    GuidCacheUtil.BindName(timertext, "timertext")
    GUI.StaticSetFontSize(timertext, 22)
    GUI.StaticSetAlignment(timertext, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(timertext, UIAnchor.Bottom, UIAroundPivot.Bottom)
    local timertextColor = Color.New(8 / 255, 172 / 255, 3 / 255, 255 / 255);
    GUI.SetColor(timertext, timertextColor);

    --答对7题可领取奖励
    local rewardbg = GUI.ImageCreate(leftbg, "rewardbg", "1800400420", 0, 186, true)
    SetAnchorAndPivot(rewardbg, UIAnchor.Top, UIAroundPivot.Top)

    local rewarddesc = GUI.CreateStatic(rewardbg, "rewarddesc", "答题奖励", 0, 0, 320, 35, "system", true, false)
    GUI.StaticSetFontSize(rewarddesc, 22)
    GUI.StaticSetAlignment(rewarddesc, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(rewarddesc, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(rewarddesc, tipColor);

    local rewardicon = GUI.ButtonCreate(leftbg, "rewardicon", "1800608100", 0, 466, Transition.ColorTint);
    GuidCacheUtil.BindName(rewardicon, "rewardicon")
    SetAnchorAndPivot(rewardicon, UIAnchor.Top, UIAroundPivot.Bottom)
    rewardicon:RegisterEvent(UCE.PointerUp)
    rewardicon:RegisterEvent(UCE.PointerDown)
    GUI.RegisterUIEvent(rewardicon, UCE.PointerClick, "WestJourneyUI", "on_click_reward7")

    local gettext = GUI.CreateStatic(rewardicon, "gettext", "", 0, 0, 100, 35, "system", true, false)
    GUI.StaticSetFontSize(gettext, 22)
    GUI.StaticSetAlignment(gettext, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(gettext, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.SetColor(gettext, tipColor);

    --经验
    local expbg = GUI.ImageCreate(leftbg, "expbg", "1800900040", -25, 492, false, 172, 36)
    SetAnchorAndPivot(expbg, UIAnchor.Center, UIAroundPivot.TopLeft)

    local exptext = GUI.CreateStatic(expbg, "exptext", "0", 30, 0, 140, 35, "system", true, false)
    GuidCacheUtil.BindName(exptext, "expText")
    GUI.StaticSetFontSize(exptext, 22)
    GUI.StaticSetAlignment(exptext, TextAnchor.MiddleLeft)
    SetAnchorAndPivot(exptext, UIAnchor.Left, UIAroundPivot.Left)

    local addexptext = GUI.CreateStatic(expbg, "addexptext", "+0", -15, 0, 140, 35, "system", true, false)
    GuidCacheUtil.BindName(addexptext, "addexptext")
    GUI.StaticSetFontSize(addexptext, 22)
    GUI.StaticSetAlignment(addexptext, TextAnchor.MiddleRight)
    SetAnchorAndPivot(addexptext, UIAnchor.Right, UIAroundPivot.Right)
    GUI.SetColor(addexptext, tipColor);

    local expicon = GUI.ImageCreate(expbg, "expicon", "1800408330", 3, -2, true)
    SetAnchorAndPivot(expicon, UIAnchor.Left, UIAroundPivot.Center)

    local exptitle = GUI.CreateStatic(expbg, "exptitle", "获得经验", -20, 0, 100, 35, "system", true, false)
    GUI.StaticSetFontSize(exptitle, 22)
    GUI.StaticSetAlignment(exptitle, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(exptitle, UIAnchor.Left, UIAroundPivot.Right)
    GUI.SetColor(exptitle, tipColor);

    --银币
    local coinbg = GUI.ImageCreate(leftbg, "coinbg", "1800900040", -25, 542, false, 172, 36)
    SetAnchorAndPivot(coinbg, UIAnchor.Center, UIAroundPivot.TopLeft)

    local cointext = GUI.CreateStatic(coinbg, "cointext", "0", 30, 0, 140, 35, "system", true, false)
    GuidCacheUtil.BindName(cointext, "cointext")
    GUI.StaticSetFontSize(cointext, 22)
    GUI.StaticSetAlignment(cointext, TextAnchor.MiddleLeft)
    SetAnchorAndPivot(cointext, UIAnchor.Left, UIAroundPivot.Left)

    local addcointext = GUI.CreateStatic(coinbg, "addcointext", "+0", -15, 0, 140, 35, "system", true, false)
    GuidCacheUtil.BindName(addcointext, "addcointext")
    GUI.StaticSetFontSize(addcointext, 22)
    GUI.StaticSetAlignment(addcointext, TextAnchor.MiddleRight)
    SetAnchorAndPivot(addcointext, UIAnchor.Right, UIAroundPivot.Right)
    GUI.SetColor(addcointext, tipColor);

    local coinicon = GUI.ImageCreate(coinbg, "coinicon", "1800408280", 3, -2, true)
    SetAnchorAndPivot(coinicon, UIAnchor.Left, UIAroundPivot.Center)

    local cointitle = GUI.CreateStatic(coinbg, "cointitle", "获得银币", -20, 0, 100, 35, "system", true, false)
    GUI.StaticSetFontSize(cointitle, 22)
    GUI.StaticSetAlignment(cointitle, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(cointitle, UIAnchor.Left, UIAroundPivot.Right)
    GUI.SetColor(cointitle, tipColor);

    --右侧父节点(背景)
    local rightbg = GUI.ImageCreate(panelBg, "rightbg", "1800400010", 415, 100, false, 700, 510)
    SetAnchorAndPivot(rightbg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --题目
    local questiontext = GUI.CreateStatic(rightbg, "questiontext", "第  题：", 70, 5, 635, 45, "system", true, false)
    GuidCacheUtil.BindName(questiontext, "questiontext")
    GUI.StaticSetFontSize(questiontext, 24)
    GUI.StaticSetAlignment(questiontext, TextAnchor.MiddleLeft)
    SetAnchorAndPivot(questiontext, UIAnchor.TopLeft, UIAroundPivot.BottomLeft)
    GUI.SetColor(questiontext, tipColor);

    local questionicon1 = GUI.ImageCreate(questiontext, "questionicon1", "1800600340", 22, 0, true, 0, 0)
    SetAnchorAndPivot(questionicon1, UIAnchor.Left, UIAroundPivot.Center)

    local questionicon2 = GUI.ImageCreate(questionicon1, "questionicon2", "1800607300", 15, -3, true, 0, 0)
    SetAnchorAndPivot(questionicon2, UIAnchor.Left, UIAroundPivot.Center)

    --答案显示
    local answertitlebg = GUI.ImageCreate(rightbg, "answertitlebg", "1800600390", 15, 365, true, 674, 37)
    SetAnchorAndPivot(answertitlebg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local answertitle = GUI.CreateStatic(answertitlebg, "answertitle", "已经找到", 15, 0, 300, 45, "system", true, false)
    GUI.StaticSetFontSize(answertitle, 24)
    GUI.StaticSetAlignment(answertitle, TextAnchor.MiddleLeft)
    SetAnchorAndPivot(answertitle, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(answertitle, tipColor);

    for i = 1, answerCount do
        local name = "answerbg" .. i
        local answerbg = GUI.ImageCreate(rightbg, name, "1800700020", 22 + (i - 1) * 112, 410, true, 0, 0)
        GuidCacheUtil.BindName(answerbg, name)
        SetAnchorAndPivot(answerbg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetVisible(answerbg, true)

        local answerhead = GUI.ImageCreate(answerbg, "answerhead", "1900000000", 0, 0, false, 74, 74)
        SetAnchorAndPivot(answerhead, UIAnchor.Center, UIAroundPivot.Center)

		name = "optionbg" .. i
        local optionbg = GUI.ButtonCreate(rightbg, name, "1800600380", 12 + (i - 1) * optionx, 12, Transition.ColorTint, "", 220, 345, false);
        GuidCacheUtil.BindName(optionbg, name)
		SetAnchorAndPivot(optionbg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetData(optionbg, "status", 0)
		GUI.SetData(optionbg, "index", i)
        GUI.RegisterUIEvent(optionbg, UCE.PointerClick, "WestJourneyUI", "on_click_option")
    end

    local modelparent = GUI.RawImageCreate(rightbg, false, "modelparent", "", -168, -60, 4)
    SetAnchorAndPivot(modelparent, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(modelparent, false)
    GuidCacheUtil.BindName(modelparent, "modelparent")
    GUI.AddToCamera(modelparent)
    GUI.RawImageSetCameraConfig(modelparent, "(0,0,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,10,0.01,7.0,0")

    --------------------------------
    -- local modename = GUI.CreateStatic(modelparent, "modename", "", -40, 120, 150, 40, "system", true)
    -- UILayout.SetSameAnchorAndPivot(modename, UILayout.Center)
    -- UILayout.StaticSetFontSizeColorAlignment(modename, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    -- GUI.SetIsOutLine(modename, true)
    -- GUI.SetOutLine_Color(modename, UIDefine.Brown3Color)
    -- GUI.SetOutLine_Distance(modename, 1)
    --------------------------------

    for i = 1, answerCount do
        local name = "option" .. i
        -- local option = GUI.ImageCreate(rightbg, name, "", (i - 2) * optionx, optiony)
        local option = GUI.GroupCreate(rightbg, name, (i - 2) * optionx, optiony)
        GuidCacheUtil.BindName(option, name)
        SetAnchorAndPivot(option, UIAnchor.Center, UIAroundPivot.Center)

        local optionname = GUI.CreateStatic(option, "optionname", " ", 0, 180, 190, 35, "system", true, false)
        GUI.StaticSetFontSize(optionname, 24)
        GUI.StaticSetAlignment(optionname, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(optionname, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(optionname, tipColor);

        name = "optionheadbg" .. i
        local optionheadbg = GUI.ImageCreate(rightbg, name, "1800700020", 78 + (i - 1) * optionx, 88, true, 0, 0)
        GuidCacheUtil.BindName(optionheadbg, name)
        SetAnchorAndPivot(optionheadbg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetVisible(optionheadbg, false)
        local x = GUI.GetPositionX(optionheadbg)
        local y = GUI.GetPositionY(optionheadbg)
        GUI.SetData(optionheadbg, "x", x)
        GUI.SetData(optionheadbg, "y", y)

        local optionhead = GUI.ImageCreate(optionheadbg, "optionhead", "", 0, 0, false, 74, 74)
        SetAnchorAndPivot(optionhead, UIAnchor.Center, UIAroundPivot.Center)

        local trueicon = GUI.ImageCreate(option, "trueicon", "1800608400", 73, -96, true, 62, 62)
        SetAnchorAndPivot(trueicon, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetGroupAlpha(trueicon, 0)

        local falseicon = GUI.ImageCreate(option, "falseicon", "1800608390", 73, -96, true, 62, 62)
        SetAnchorAndPivot(falseicon, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetGroupAlpha(falseicon, 0)

    end
end

function WestJourneyUI.OnShow(key)
    CL.SendNotify(NOTIFY.SubmitForm, "FormXiYouQiYuan", "main", 0);
    local panel = GUI.GetWnd("WestJourneyUI")
    GUI.SetVisible(panel, true)
end

--关闭界面
function WestJourneyUI.on_close_wnd()
    GUI.CloseWnd("WestJourneyUI")
	if CL.GetIntCustomData("Assist_GoOn") == 1 then
		CL.SendNotify(NOTIFY.SubmitForm, "FormAssist", "XiYouQiYuanStop")
	end
end

function WestJourneyUI.OnClose(key)
    for i = 1, answerCount do
        local model = GuidCacheUtil.GetUI("model" .. i)
        if model then
        	GUI.Destroy(model)
        end
        local optionname = GUI.Get("WestJourneyUI/panelBg/rightbg/option" .. i .. "/optionname")
        GUI.StaticSetText(optionname, "")
    end

    if WestJourneyUI.RefreshTimer then
        WestJourneyUI.RefreshTimer:Stop()
        WestJourneyUI.RefreshTimer = nil
    end

    if WestJourneyUI.RemainTimer then
        WestJourneyUI.RemainTimer:Stop()
    end

    if WestJourneyUI.headmovetimer then
        WestJourneyUI.headmovetimer:Stop()
    end

    if WestJourneyUI.answerheadtimer then
        WestJourneyUI.answerheadtimer:Stop()
    end

    if WestJourneyUI.itemdisappertimner then
        WestJourneyUI.itemdisappertimner:Stop()
    end
end

function WestJourneyUI.RandomAnswerIndex()
    if not randIndex then
        randIndex = {}
        for i = 1, answerCount do
            randIndex[i] = i
        end
    end
    local rand = math.random(1, answerCount)
    local x, y = rand, rand % answerCount + 1
    randIndex[x], randIndex[y] = randIndex[y], randIndex[x]
end

---@param data table
---@param state number 0刷新 1正确 2错误 3刷新奖励按钮状态
function WestJourneyUI.Refresh(data, state)
    if state == 3 then
        WestJourneyUI.RefreshRewardState(data.RewardState)
        return
    end
    WestJourneyUI.RandomAnswerIndex()
    WestJourneyUI.CurrentData = data
    if state == 0 then
        WestJourneyUI.RefreshUI(data)
    elseif state == 1 then
        WestJourneyUI.TrueAnswer(data.AddBindGold, data.AddExp)
    elseif state == 2  then
        WestJourneyUI.FalseAnswer(data.AddBindGold, data.AddExp)
    end
    if state == 1 or state == 2 then
        if not WestJourneyUI.RefreshTimer then
            WestJourneyUI.RefreshTimer = Timer.New(WestJourneyUI.OnRefreshTimer, 1)
        else
            WestJourneyUI.RefreshTimer:Stop()
            WestJourneyUI.RefreshTimer:Reset(WestJourneyUI.OnRefreshTimer, 1)
        end
        WestJourneyUI.RefreshTimer:Start()
    end
end

function WestJourneyUI.OnRefreshTimer()
    WestJourneyUI.RefreshUI(WestJourneyUI.CurrentData)
end

function WestJourneyUI.RefreshUI(data)
    if not data.Question then
        CL.SendNotify(NOTIFY.ShowBBMsg, "西游奇缘活动已完成")
        WestJourneyUI.on_close_wnd()
        return
    end
    local dateStr = string.split(os.date("!%H %M %S", CL.GetServerTickCount()), " ")
    local strs = string.split(data.EndTime, ":")
    local remain_time = (tonumber(strs[1]) * 3600 + tonumber(strs[2]) * 60 + tonumber(strs[3])) - (tonumber(dateStr[1]) * 3600 + tonumber(dateStr[2]) * 60 + tonumber(dateStr[3]))
    WestJourneyUI.ActivityStart(remain_time)

    local cointext = GuidCacheUtil.GetUI("cointext")
    local exptext = GuidCacheUtil.GetUI("expText")
    GUI.StaticSetText(cointext, data.BindGold or 0)
    GUI.StaticSetText(exptext, data.Exp or 0)

    local question = data.Question
    local question_text = question.Ask or "没有问题了"

    local truelabel = GuidCacheUtil.GetUI("truelabel")
    GUI.StaticSetText(truelabel, "准确率      " .. data.TrueCount .. "/" .. data.NowCount)
    local addcointext = GuidCacheUtil.GetUI("addcointext")
    local addexptext = GuidCacheUtil.GetUI("addexptext")
    GUI.StaticSetText(addcointext, "")
    GUI.StaticSetText(addexptext, "")

    WestJourneyUI.RefreshRewardState(data.RewardState)

    local modelparent = GuidCacheUtil.GetUI("modelparent")
    WestJourneyUI.Branch = question.Now
    local num = question.Max
    local answerForShow = data.AnswerForShow
    for i = 1, answerCount do
        local answerbg = GuidCacheUtil.GetUI("answerbg" .. i)
        GUI.SetVisible(answerbg, num >= i)
        local answerhead = GUI.GetChild(answerbg, "answerhead")
        local img = "1900000000"
        if answerForShow and answerForShow[i] then
            img = WestJourneyUI.GetImageID(answerForShow[i])
        end
        GUI.ImageSetImageID(answerhead,  img)

        local optionheadbg = GuidCacheUtil.GetUI("optionheadbg" .. i)
        GUI.SetVisible(optionheadbg, false)
    end
    WestJourneyUI.PlayerChooseId = question.Id
    local page = data.NowCount + 1
    for i = 1, answerCount do
        local idx = randIndex[i]
        local optionbg = GuidCacheUtil.GetUI("optionbg" .. i)
        GUI.ButtonSetShowDisable(optionbg, true)
        GUI.SetData(optionbg, "status", 1)
        local ans = question["Answer" .. idx]
        GUI.SetData(optionbg, "key", ans)

        local option = GuidCacheUtil.GetUI("option" .. i)
        local trueicon = GUI.GetChild(option, "trueicon")
        local falseicon = GUI.GetChild(option, "falseicon")
        GUI.SetVisible(trueicon, false)
        GUI.SetVisible(falseicon, false)

        local optionname = GUI.GetChild(option, "optionname")
        GUI.StaticSetText(optionname, ans)

        local name = "model" .. i
        local model = GuidCacheUtil.GetUI(name)
        if model then
            GUI.SetVisible(model, false)
            GUI.Destroy(model)
        end

        local model_id = question["AnswerModel" .. idx]

        if model_id then
            local model = GUI.RawImageChildCreate(modelparent, true, name, "", 0, 0)
            ModelItem.Bind(model, model_id, 0, 0, eRoleMovement.ATTSTAND_W1)
            GUI.SetLocalPosition(model, 1.95 - 1.55 * i, -1.2, 0)
            GUI.SetEulerAngles(model, 0, 0, 0)
            GuidCacheUtil.BindName(model, name)
        end

        --------------------------------
        -- local ans_name = question["Answer"..idx]
        -- local index = "modelname"..i
        -- local modelname = GuidCacheUtil.GetUI(index)
        -- if modelname then
        --     GUI.SetVisible(modelname, false)
        --     GUI.Destroy(modelname)
        -- end
        -- if ans_name then
        --     local modename = GUI.CreateStatic(modelparent, index, ans_name, i * 225 - 280, 130, 150, 40, "system", true)
        --     UILayout.SetSameAnchorAndPivot(modename, UILayout.Center)
        --     UILayout.StaticSetFontSizeColorAlignment(modename, UIDefine.FontSizeXL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
        --     GuidCacheUtil.BindName(modename, index)
        -- end
        --------------------------------

    end

    local questionText = GuidCacheUtil.GetUI("questiontext")
    if question.Max > 1 then
        GUI.StaticSetText(questionText, "第" .. page .. "题:" .. question_text .. "(" .. question.Now .. "/" .. question.Max .. ")")
    else
        GUI.StaticSetText(questionText, "第" .. page .. "题:" .. question_text)
    end
end

function WestJourneyUI.ActivityStart(remain_time)
    WestJourneyUI.clocktime = remain_time
    if WestJourneyUI.RemainTimer then
        WestJourneyUI.RemainTimer:Stop()
        WestJourneyUI.RemainTimer:Reset(WestJourneyUI.on_remain_time, 1, -1)
    else
        WestJourneyUI.RemainTimer = Timer.New(WestJourneyUI.on_remain_time, 1, -1, true)
    end

    WestJourneyUI.RemainTimer:Start()
end

-- 0不可领 1可领 3已领
function WestJourneyUI.RefreshRewardState(state)
    local rewardicon = GuidCacheUtil.GetUI("rewardicon")
    GUI.ButtonSetShowDisable(rewardicon, state == 1)
end

function WestJourneyUI.on_click_option(guid)
    local optionbg = GUI.GetByGuid(guid)
    if tonumber(GUI.GetData(optionbg, "status")) == 1 then
        WestJourneyUI.answerIndex = tonumber(GUI.GetData(optionbg, "index"))
        WestJourneyUI.imageid = tostring(WestJourneyUI.CurrentData.Question["AnswerPic" .. randIndex[WestJourneyUI.answerIndex]])
        --FormXiYouQiYuan.main(player,type,question_id,answer) type 0刷新 1提交答案
        CL.SendNotify(NOTIFY.SubmitForm, "FormXiYouQiYuan", "main", 1, WestJourneyUI.PlayerChooseId, GUI.GetData(optionbg, "key"))
        GUI.ButtonSetShowDisable(optionbg, false)
        for i = 1, answerCount do
            optionbg = GuidCacheUtil.GetUI("optionbg" .. i)
            GUI.SetData(optionbg, "status", 0)
        end
    end
end

--辅助功能自动选择答案
function WestJourneyUI.RandomAnswer()
    local panel = GUI.GetWnd("WestJourneyUI")
    if panel then
        local visible = GUI.GetVisible(panel)
        if visible == true then
            if not WestJourneyUI["PLUGIN_STATUS"] then
                WestJourneyUI["PLUGIN_STATUS"] = 1
            end

            local i = math.random(3)
            local gui = GuidCacheUtil.GetUI("optionbg" .. i)
            local guid = GUI.GetGuid(gui)
            WestJourneyUI.on_click_option(guid)
        end
    end
end

function WestJourneyUI.GetImageID(imgID)
    local temp = tostring(imgID)
    local temp1 = string.sub(temp, 1, 4)
    local temp2 = tonumber(string.sub(temp, 5, 10))
    local temp3 = tostring(temp2 - 100000)
    return tostring(temp1 .. temp3)
end

function WestJourneyUI.TrueAnswer(Gold, Exp)
    local serial = WestJourneyUI.answerIndex
    local trueicon = GUI.Get("WestJourneyUI/panelBg/rightbg/option" .. serial .. "/trueicon")
    WestJourneyUI.on_trueorfalse_icon(trueicon)

    local optionheadbg = GuidCacheUtil.GetUI("optionheadbg" .. serial)
    local optionhead = GUI.GetChild(optionheadbg, "optionhead")

    WestJourneyUI.imageid = WestJourneyUI.GetImageID(WestJourneyUI.imageid)

    local x = tonumber(GUI.GetData(optionheadbg, "x"))
    local y = tonumber(GUI.GetData(optionheadbg, "y"))
    GUI.SetPositionX(optionheadbg, x)
    GUI.SetPositionY(optionheadbg, -y)
    GUI.ImageSetImageID(optionhead, WestJourneyUI.imageid)
    GUI.SetVisible(optionheadbg, true)

    WestJourneyUI.tempBranch = WestJourneyUI.Branch

    if WestJourneyUI.headmovetimer then
        WestJourneyUI.headmovetimer:Stop()
        WestJourneyUI.headmovetimer:Reset(WestJourneyUI.on_head_move, 0.2, 1)
    else
        WestJourneyUI.headmovetimer = Timer.New(WestJourneyUI.on_head_move, 0.2, 1)
    end
    WestJourneyUI.headmovetimer:Start()

    if WestJourneyUI.answerheadtimer then
        WestJourneyUI.answerheadtimer:Stop()
        WestJourneyUI.answerheadtimer:Reset(WestJourneyUI.on_answer_head, 0.7, 1)
    else
        WestJourneyUI.answerheadtimer = Timer.New(WestJourneyUI.on_answer_head, 0.7, 1, true)
    end
    WestJourneyUI.answerheadtimer:Start()

    WestJourneyUI.CountGoldExp(Gold, Exp)

    --if WestJourneyUI.temp_question[3] == 0 then
    --    WestJourneyUI.CountGoldExp(Gold, Exp)
    --    local truelabel = GuidCacheUtil.GetUI("truelabel")
    --    GUI.StaticSetText(truelabel, "准确率      " .. WestJourneyUI.TotalQuestion .. "/" .. (WestJourneyUI.Page - 1))
    --    WestJourneyUI.Branch = 1
    --    if WestJourneyUI.TotalQuestion == 7 and XiYouQInfo["reward7"] ~= 1 then
    --        CL.SendNotify(NOTIFY.SubmitForm, "XiYouQServer", "SendItem");
    --        local itemDB = DB.GetOnceItemByKey2(WestJourneyUI.reward7)
    --        WestJourneyUI.on_item_move_start(itemDB.Id, "reward7item")
    --    elseif WestJourneyUI.Page == 11 then
    --        --奖励动画移动效果
    --        if WestJourneyUI.reward10 then
    --            local itemDB = DB.GetOnceItemByKey2(WestJourneyUI.reward10)
    --            WestJourneyUI.on_item_move_start(itemDB.Id, "reward10item")
    --        end
    --    end
    --else
    --    WestJourneyUI.Branch = WestJourneyUI.Branch + 1
    --end
end

function WestJourneyUI.on_item_move_start(item, index)
    local panelBg = GuidCacheUtil.GetUI("panelBg")
    local Icon = DB.Get_item(tonumber(item)).Icon
    local item_bg = GUI.ItemCtrlCreate(panelBg, index, "1800700020", 243, 353, 78, 78, false)
    SetAnchorAndPivot(item_bg, UIAnchor.TopLeft, UIAroundPivot.Center)
    GUI.SetData(item_bg, "key", item)
    GUI.ItemCtrlSetElementValue(item_bg, Icon)
    local img = GUI.ItemCtrlGetElementValue(item_bg)
    GUI.ImageSetGray(img, false)
    GUI.SetVisible(img, true)
    GUI.SetItemIconBtnIconScale(item_bg, 0.9)

    WestJourneyUI["global_item_disapper_value"] = item_bg

    if WestJourneyUI.itemdisappertimner then
        WestJourneyUI.itemdisappertimner:Stop()
        WestJourneyUI.itemdisappertimner:Reset(WestJourneyUI.on_item_disapper, 0.7, 1)
    else
        WestJourneyUI.itemdisappertimner = Timer.New(WestJourneyUI.on_item_disapper, 0.7, 1, true)
    end
    WestJourneyUI.itemdisappertimner:Start()

    WestJourneyUI.on_item_move(item_bg)
end

function WestJourneyUI.FalseAnswer(Gold, Exp)
    local serial = WestJourneyUI.answerIndex
    local falseicon = GUI.Get("WestJourneyUI/panelBg/rightbg/option" .. serial .. "/falseicon")
    WestJourneyUI.on_trueorfalse_icon(falseicon)
    WestJourneyUI.CountGoldExp(Gold, Exp)
end

function WestJourneyUI.CountGoldExp(Gold, Exp)
    if not Gold or not Exp then
        return
    end
    local addcointext = GuidCacheUtil.GetUI("addcointext")
    local addexptext = GuidCacheUtil.GetUI("addexptext")
    GUI.SetPositionY(addcointext, 0)
    GUI.SetPositionY(addexptext, 0)

    GUI.StaticSetText(addcointext, "+" .. Gold)
    GUI.StaticSetText(addexptext, "+" .. Exp)

    WestJourneyUI.on_addtext_move(addcointext)
    WestJourneyUI.on_addtext_move(addexptext)
end

function WestJourneyUI.on_addtext_move(obj)
    local times = 1
    local tween = TweenData.New()
    tween.Type = GUITweenType.DOGroupAlpha
    tween.LoopType = UITweenerStyle.Once
    tween.From = Vector3.New(1, 0, 0)
    tween.To = Vector3.New(0, 0, 0)
    tween.Duration = times
    GUI.DOTween(obj, tween)

    tween = TweenData.New()
    tween.Type = GUITweenType.DOLocalMove
    tween.LoopType = UITweenerStyle.Once
    tween.From = Vector3.New(0, 0, 0)
    tween.To = Vector3.New(0, -30, 0)
    tween.Duration = times
    GUI.DOTween(obj, tween)

    GUI.SetVisible(obj, true)
end

function WestJourneyUI.on_trueorfalse_icon(obj)
    local times = 0.2
    local tween = TweenData.New()
    tween.Type = GUITweenType.DOGroupAlpha
    tween.LoopType = UITweenerStyle.Once
    tween.From = Vector3.New(0.01, 0, 0)
    tween.To = Vector3.New(1, 0, 0)
    tween.Duration = times
    GUI.DOTween(obj, tween)

    tween = TweenData.New()
    tween.Type = GUITweenType.DOScale
    tween.LoopType = UITweenerStyle.Once
    tween.From = Vector3.New(8, 8, 8)
    tween.To = Vector3.New(1, 1, 1)
    tween.Duration = times
    GUI.DOTween(obj, tween)
    GUI.SetVisible(obj, true)
    
end

function WestJourneyUI.on_head_move()
    local times = 0.4

    local serial = WestJourneyUI.answerIndex
    local obj = GuidCacheUtil.GetUI("optionheadbg" .. serial)
    local target = GuidCacheUtil.GetUI("answerbg" .. WestJourneyUI.tempBranch)

    local x = GUI.GetPositionX(obj)
    local y = GUI.GetPositionY(obj)

    local x1 = GUI.GetPositionX(target)
    local y1 = GUI.GetPositionY(target)

    local tween = TweenData.New()
    tween.Type = GUITweenType.DOLocalMove
    tween.LoopType = UITweenerStyle.Once
    tween.From = Vector3.New(x, -y, 0)
    tween.To = Vector3.New(x1, -y1, 0)
    tween.Duration = times
    GUI.DOTween(obj, tween)

    WestJourneyUI.headmovetimer:Stop()
end

function WestJourneyUI.on_item_move(obj)
    local x = GUI.GetPositionX(obj)
    local y = GUI.GetPositionY(obj)

    if not WestJourneyUI["global_bag_x"] then
        local panelBg = GuidCacheUtil.GetUI("panelBg")
        local bagbtn = GUI.Get("MainUI/rightBg/bagBtn")
        local v3_bag = GUI.GetPointByScreenPoint(panelBg, GUI.GetScreenPoint(bagbtn))
        local v3_obj = GUI.GetPointByScreenPoint(panelBg, GUI.GetScreenPoint(obj))

        WestJourneyUI["global_bag_x"] = v3_bag.x - v3_obj.x + x
        WestJourneyUI["global_bag_y"] = -(v3_bag.y - v3_obj.y + y)
    end

    local times = 0.7
    local tween = TweenData.New()
    tween.Type = GUITweenType.DOLocalMove
    tween.LoopType = UITweenerStyle.Once
    tween.From = Vector3.New(x, -y, 0)
    tween.To = Vector3.New(WestJourneyUI["global_bag_x"], WestJourneyUI["global_bag_y"], 0)
    tween.Duration = times
    GUI.DOTween(obj, tween)
end

function WestJourneyUI.on_answer_head()
    local answerhead = GUI.Get("WestJourneyUI/panelBg/rightbg/answerbg" .. WestJourneyUI.tempBranch .. "/answerhead")
    GUI.ImageSetImageID(answerhead, WestJourneyUI.imageid)
    WestJourneyUI.answerheadtimer:Stop()
end

function WestJourneyUI.on_remain_time()
    if not WestJourneyUI then
        if WestJourneyUI.RemainTimer then
            WestJourneyUI.RemainTimer:Stop()
        end
    else
        if WestJourneyUI.RemainTimer then
            WestJourneyUI.clocktime = WestJourneyUI.clocktime - 1

            local sec = WestJourneyUI.clocktime % 60
            local hour = math.floor(WestJourneyUI.clocktime / 3600)
            local minutes = math.floor((WestJourneyUI.clocktime - hour * 3600) / 60)

            if hour  < 10 then
                hour = "0" .. hour
            end

            if minutes < 10 then
                minutes = "0" .. minutes
            end

            if sec < 10 then
                sec = "0" .. sec
            end

            local timertext = GuidCacheUtil.GetUI("timertext")
            if timertext then
                GUI.StaticSetText(timertext, hour .. ":" .. minutes .. ":" .. sec)
            end

            if WestJourneyUI.clocktime == 0 then
                GUI.CloseWnd("WestJourneyUI")
                GlobalUtils.ShowBoxMsg1Btn("提示", "活动已结束", "确认")
            end
        end
    end
end

function WestJourneyUI.on_click_reward7(guid)
    CL.SendNotify(NOTIFY.SubmitForm, "FormXiYouQiYuan", "getReward")

    --------------------------------

    --------------------------------
    --local itemDB = DB.GetOnceItemByKey2(WestJourneyUI.reward7)
    --local panelBg = GuidCacheUtil.GetUI("panelBg")
    --local tips = Tips.CreateByItemId(itemDB.Id, panelBg, "itemTips", 0, 111)
end

function WestJourneyUI.on_item_disapper()
    local item = WestJourneyUI["global_item_disapper_value"]

    local times = 0.5
    local tween = TweenData.New()
    tween.Type = GUITweenType.DOGroupAlpha
    tween.LoopType = UITweenerStyle.Once
    tween.From = Vector3.New(1, 0, 0)
    tween.To = Vector3.New(0, 0, 0)
    tween.Duration = times
    GUI.DOTween(item, tween)

    WestJourneyUI.itemdisappertimner:Stop()
end