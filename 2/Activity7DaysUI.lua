local Activity7DaysUI = {
    ---@type SevenDaysServerCfg
    ServerData = {}
}
_G.Activity7DaysUI = Activity7DaysUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local lastCheckBoxGuid = nil
local SetRedPointTable = {
    ["ScoreAward"] = {},
    ["SignInAward"] = {},
    ["TaskAward"] = {}
}

------------------------------------ end缓存一下全局变量end --------------------------------
local _gt = UILayout.NewGUIDUtilTable()
--七日按钮列表
local DayBtnNames = {"签到奖励", "第一天", "第二天", "第三天", "第四天", "第五天", "第六天", "第七天"}
local DayBtnPic0 = {"1801402071", "1801402070"}
local DayBtnPic1 = {"1800002030", "1800002031"}
local DefTipsItemId = "ItemId"
local DefSevenDayScore = "SevenDayScore"
local DefSevenDayOvertime = "SevenDay_Over_time"
local RoleLevel = 0
local BtnState = {
    Wait = 2,
    Lock = 3,
    Get = 1,
    Done = 4
}

function Activity7DaysUI.InitData()
    return {
        dayindex = 1,
        ---@type table<number,SevenDaysCfg[]>
        cfg = {},
        ---@type SevenDaysBtnCfg[]
        sign = {},
        ---@type SevenDaysRank
        rank = {
            cur = 0,
            ranks = {}
        },
        overtime = 0,
        dayGuid = nil
    }
end
local data = Activity7DaysUI.InitData()

function Activity7DaysUI.OnExitGame()
    data = Activity7DaysUI.InitData()
end
function Activity7DaysUI.OnExit()
    GUI.CloseWnd("Activity7DaysUI")
    GlobalProcessing.Acitvity7Day_Loading()
end
function Activity7DaysUI.CreateSignItem(parent, name, x, y, w, h, iconW)
    local bg = GUI.ImageCreate(parent, name, "1800601100", x, y, false, w, h)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Center)
    local item = ItemIcon.Create(bg, "icon", 0, 10, iconW, iconW)
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1801100160")
    GUI.ItemCtrlSetElementRect(item, eItemIconElement.Selected, 0, 0, iconW, iconW)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "Activity7DaysUI", "OnClickSign")

    local effect = GUI.SpriteFrameCreate(item, "effect", "", 0, -3, false, 120, 120)
    UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
    GUI.SetFrameId(effect, "3403500000")
    --GUI.SetFrameId(effect, "3403800000")
    GUI.SetVisible(effect,false)
    --GUI.SetScale(effect, Vector3.New(0.4, 1.2, 1))--3403800000
    GUI.SetScale(effect, Vector3.New(1.6, 1.6, 1))--3403500000
    UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)

    local txt = GUI.CreateStatic(bg, "txt", "", 0, -46, 75, 25)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
    GUI.SetColor(txt, UIDefine.YellowStdColor)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    return bg
end
function Activity7DaysUI.RefreshSignItem(guid, index)
    local bg = GUI.GetByGuid(guid)
    local item = GUI.GetChild(bg, "icon", false)
    local txt = GUI.GetChild(bg, "txt", false)
    GUI.StaticSetText(txt, DayBtnNames[index + 1])
    if data.sign[index] then
        local tmp = data.sign[index].items
        local itemId = data.sign[index].isguard
        if tmp and tmp[1] then
            ItemIcon.BindItemId(item, tmp[1].id)
            GUI.ItemCtrlSetElementValue(
                    item,
                    eItemIconElement.RightBottomNum,
                    UIDefine.ExchangeMoneyToStr(tmp[1].count)
            )
            GUI.ItemCtrlSetIndex(item, index)
            GUI.SetData(item, DefTipsItemId, tostring(tmp[1].id))
            GUI.SetData(item,"isguard",tostring(itemId))
            GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,0,66,66)
            if data.sign[index].ButtonState == BtnState.Done then
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Selected, "1800608160")
                GUI.ItemCtrlSelect(item)
            else
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Selected, "")
                GUI.ItemCtrlUnSelect(item)
            end
            return
        end
    end
    ItemIcon.SetEmpty(item, nil)
end
function Activity7DaysUI.CreateItem()
    local scroll = _gt.GetUI("daysrc")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = GUI.GroupCreate(scroll, tostring(curCount), 0, 0, 173, 70)
    local btn = GUI.CheckBoxExCreate(item, "btn", DayBtnPic0[1], DayBtnPic0[2], 0, 0, false)
    UILayout.SetSameAnchorAndPivot(btn, UILayout.Center)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "Activity7DaysUI", "OnDayBtnClick")
    local txt = GUI.CreateStatic(item, "txt", " ", 0, 0, 150, 39)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeXL)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

    return item
end

function Activity7DaysUI.RefreshItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local btn = GUI.GetChild(item, "btn", false)
    local txt = GUI.GetChild(item, "txt", false)
    GUI.CheckBoxExSetIndex(btn, index - 1)

    if index == 1 then
        GUI.CheckBoxExSetBgImageId(btn, DayBtnPic0[1])
        GUI.CheckBoxExSetCheckImageId(btn, DayBtnPic0[2])
        GUI.SetPreferredWidth(item, 214)
        GUI.SetPreferredHeight(item, 75)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeXXL)
        GUI.AddRedPoint(btn,UIAnchor.TopLeft,12,12,"1800208080")
        GUI.SetRedPointVisable(btn,false)
        if #SetRedPointTable["SignInAward"] > 0 then
            local RedSumNum = 0
            for i = 1, #SetRedPointTable["SignInAward"] do
                if SetRedPointTable["SignInAward"][i] == true then
                    RedSumNum = RedSumNum + 1
                end
                if RedSumNum == 0 then
                    GUI.SetRedPointVisable(btn,false)
                else
                    GUI.SetRedPointVisable(btn,true)
                end
            end
        end
    else
        GUI.CheckBoxExSetBgImageId(btn, DayBtnPic1[1])
        GUI.CheckBoxExSetCheckImageId(btn, DayBtnPic1[2])
        GUI.SetPreferredWidth(item, 190)
        GUI.SetPreferredHeight(item, 65)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeXL)

        GUI.AddRedPoint(btn,UIAnchor.TopLeft,5,5,"1800208080")
        GUI.SetRedPointVisable(btn,false)

        local RedSumNum = 0
        --左侧按钮的红点
        if SetRedPointTable["TaskAward"][index - 1] then
            for k, v in pairs(SetRedPointTable["TaskAward"][index - 1]) do
                if v == true then
                    RedSumNum = RedSumNum + 1
                end
                if RedSumNum == 0 then
                    GUI.SetRedPointVisable(btn,false)
                else
                    GUI.SetRedPointVisable(btn,true)
                end
            end
        end
    end
    if index == data.dayindex then
        GUI.CheckBoxExSetCheck(btn, true)
        data.dayGuid = GUI.GetGuid(btn)
        GUI.SetIsOutLine(txt, true)
        GUI.SetColor(txt, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(txt, UIDefine.OutLine_YellowColor)
        GUI.SetOutLine_Distance(txt, 1)
    else
        GUI.SetColor(txt, UIDefine.BrownColor)
        GUI.CheckBoxExSetCheck(btn, false)
        GUI.SetIsOutLine(txt, false)
    end
    GUI.StaticSetText(txt, DayBtnNames[index])
end
function Activity7DaysUI.CreateInfoItem(guid)
    local scroll = _gt.GetUI("actSrc")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local item = GUI.GroupCreate(scroll, tostring(curCount), 0, 0, 810, 128)
    local _ActNode = GUI.ImageCreate(item, "ActNode", "1801100010", 0, 1, false, 810, 128)
    GUI.SetAnchor(_ActNode, UIAnchor.TopLeft)
    GUI.SetPivot(_ActNode, UIAroundPivot.TopLeft)

    --IconBack
    local _IconBack = GUI.ImageCreate(_ActNode, "IconBack", "1800400050", 22, 22, false, 84, 84)
    GUI.SetAnchor(_IconBack, UIAnchor.TopLeft)
    GUI.SetPivot(_IconBack, UIAroundPivot.TopLeft)

    --Icon
    local _Icon = GUI.ImageCreate(_IconBack, "Icon", "1800400050", 0, 0, false, 66, 66)
    GUI.SetAnchor(_Icon, UIAnchor.Center)
    GUI.SetPivot(_Icon, UIAroundPivot.Center)

    --名称
    local _Name = GUI.CreateStatic(_ActNode, "Name", "活动名称", 130, 28, 300, 35)
    GUI.SetAnchor(_Name, UIAnchor.TopLeft)
    GUI.SetPivot(_Name, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Name, UIDefine.FontSizeL)
    GUI.SetColor(_Name, UIDefine.BrownColor)
    local rank = GUI.CreateStatic(_ActNode, "rank", " ", 130, -5, 300, 35)
    UILayout.SetSameAnchorAndPivot(rank, UILayout.BottomLeft)
    GUI.StaticSetFontSize(rank, UIDefine.FontSizeL)
    GUI.SetColor(rank, UIDefine.BrownColor)

    --进度条
    local _Process =
    GUI.ScrollBarCreate(
            _ActNode,
            "Process",
            "",
            "1800608130",
            "1800608140",
            126,
            61,
            276,
            28,
            1,
            false,
            Transition.None,
            0,
            1,
            Direction.LeftToRight,
            false
    )
    local _RoleHPValue = Vector2.New(276, 28)
    GUI.ScrollBarSetFillSize(_Process, _RoleHPValue)
    GUI.ScrollBarSetBgSize(_Process, _RoleHPValue)
    GUI.SetAnchor(_Process, UIAnchor.TopLeft)
    GUI.SetPivot(_Process, UIAroundPivot.TopLeft)
    local _ProcessTxt = GUI.CreateStatic(_Process, "ProcessTxt", "10/500", 0, 0, 180, 35)
    GUI.SetAnchor(_ProcessTxt, UIAnchor.Center)
    GUI.SetPivot(_ProcessTxt, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_ProcessTxt, UIDefine.FontSizeM)
    GUI.SetColor(_ProcessTxt, UIDefine.WhiteColor)
    GUI.StaticSetAlignment(_ProcessTxt, TextAnchor.MiddleCenter)

    for j = 1, 2 do
        --奖励
        local _Icon = ItemIcon.Create(_ActNode, "Icon" .. j, 438 + (j - 1) * 92, 23, 78, 78)
        UILayout.SetSameAnchorAndPivot(_Icon, UILayout.TopLeft)
        GUI.RegisterUIEvent(_Icon, UCE.PointerClick, "Activity7DaysUI", "OnClickActItem")
    end

    --领奖按钮
    local _PrizeBtn = GUI.ButtonCreate(_ActNode, "PrizeBtn", "1800602020", 668, 42, Transition.ColorTint, "领取")
    --每天红点奖励领取设置
    GUI.AddRedPoint(_PrizeBtn,UIAnchor.TopLeft,5,5,"1800208080")
    GUI.SetRedPointVisable(_PrizeBtn,false)
    GUI.SetAnchor(_PrizeBtn, UIAnchor.TopLeft)
    GUI.SetPivot(_PrizeBtn, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_PrizeBtn, UIDefine.FontSizeL)
    GUI.ButtonSetTextColor(_PrizeBtn, UIDefine.BrownColor)
    GUI.RegisterUIEvent(_PrizeBtn, UCE.PointerClick, "Activity7DaysUI", "OnClickTask")

    --完成标记
    local _FinishFlag = GUI.ImageCreate(_ActNode, "FinishFlag", "1800404060", 668, 42)
    GUI.SetAnchor(_FinishFlag, UIAnchor.TopLeft)
    GUI.SetPivot(_FinishFlag, UIAroundPivot.TopLeft)
    GUI.SetVisible(_FinishFlag, false)
    return item
end

function Activity7DaysUI.RefreshInfoItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local ActNode = GUI.GetChild(item, "ActNode", false)
    local IconBack = GUI.GetChild(ActNode, "IconBack", false)
    local i = index
    if data.dayindex == 1 then
        return
    end
    local cfg = data.cfg[data.dayindex]
    --图标
    local _Icon = GUI.GetChild(IconBack, "Icon", false)
    GUI.ImageSetImageID(_Icon, cfg[i].Icon)
    --名称
    local _Name = GUI.GetChild(ActNode, "Name", false)
    local rank = GUI.GetChild(ActNode, "rank", false)
    GUI.StaticSetText(_Name, cfg[i].Name)
    local tmpw = GUI.StaticGetLabelPreferWidth(_Name)
    tmpw = math.max(tmpw, 300)
    GUI.SetWidth(_Name, tmpw)
    GUI.SetScale(_Name, UIDefine.Vector3One * (300 / tmpw))

    GUI.StaticSetText(rank, "完成获得" .. cfg[i].Score .. "积分")
    local tmpw = GUI.StaticGetLabelPreferWidth(rank)
    tmpw = math.max(tmpw, 300)
    GUI.SetWidth(rank, tmpw)
    GUI.SetScale(rank, UIDefine.Vector3One * (300 / tmpw))

    --进度
    local _Process = GUI.GetChild(ActNode, "Process", false)
    GUI.ScrollBarSetPos(_Process, cfg[i].Now_Extent / cfg[i].Max_Extent)
    local _ProcessTxt = GUI.GetChild(_Process, "ProcessTxt")
    GUI.StaticSetText(_ProcessTxt, cfg[i].Now_Extent .. "/" .. cfg[i].Max_Extent)
    --状态按钮
    local _PrizeBtn = GUI.GetChild(ActNode, "PrizeBtn")
    GUI.ButtonSetIndex(_PrizeBtn, index)

    --每天领取红点更新
    if cfg[i].ButtonState == BtnState.Get then
        GUI.SetVisible(_PrizeBtn, true)
        GUI.ButtonSetText(_PrizeBtn, "领取")
    elseif cfg[i].ButtonState ~= BtnState.Done then
        GUI.SetVisible(_PrizeBtn, true)
        GUI.ButtonSetText(_PrizeBtn, "前往")
    else
        GUI.SetVisible(_PrizeBtn, false)
    end

    --每天红点奖励领取设置
    GUI.AddRedPoint(_PrizeBtn,UIAnchor.TopLeft,5,5,"1800208080")
    GUI.SetRedPointVisable(_PrizeBtn,SetRedPointTable["TaskAward"][data.dayindex - 1][tostring(cfg[i].Name)])

    local _FinishFlag = GUI.GetChild(ActNode, "FinishFlag")
    if _FinishFlag ~= nil then
        GUI.SetVisible(_FinishFlag, cfg[i].ButtonState == BtnState.Done)
    end

    for j = 1, #cfg[i].items do
        local _Icon = GUI.GetChild(ActNode, "Icon" .. j)
        if _Icon ~= nil then
            ItemIcon.BindItemId(_Icon, tostring(cfg[i].items[j].id))
            GUI.ItemCtrlSetElementValue(
                    _Icon,
                    eItemIconElement.RightBottomNum,
                    UIDefine.ExchangeMoneyToStr(tostring(cfg[i].items[j].count))
            )
            GUI.SetData(_Icon, DefTipsItemId, tostring(cfg[i].items[j].id))
        end
    end
end
function Activity7DaysUI.OnClickTask(guid)
    local btn = GUI.GetByGuid(guid)
    local index = GUI.ButtonGetIndex(btn)
    if index and index > 0 then
        local tmp = data.cfg[data.dayindex][index]
        if tmp then
            if tmp.ButtonState == BtnState.Get then
                Activity7DaysUI.SendNotify("GetTaskAward", data.dayindex - 1, tmp.Index)
                Activity7DaysUI.RequestRed7dayTable()
            else
                if GetWay.Def[tmp.key] ~= nil then
                    GetWay.Def[tmp.key].jump(tmp.param1, tmp.param2, tmp.param3)
                end
            end
        end
    end
end
function Activity7DaysUI.OnClickSign(guid)
    local btn = GUI.GetByGuid(guid)
    local index = GUI.ItemCtrlGetIndex(btn)
    if index and index > 0 and index < 8 then
        if data.sign[index].ButtonState == BtnState.Get or data.sign[index].ButtonState == BtnState.Wait then
            Activity7DaysUI.SendNotify("GetSignInAward", index)
        else
            Activity7DaysUI.OnClickActItem(guid)
        end
    end
    Activity7DaysUI.RequestRed7dayTable()
end
function Activity7DaysUI.OnClickRank(guid)
    local btn = GUI.GetByGuid(guid)
    local index = GUI.ItemCtrlGetIndex(btn)
    if index and index > 0 and index < 5 then
        if data.rank.ranks[index].ButtonState == BtnState.Get then
            Activity7DaysUI.SendNotify("ScoreAwardData", data.rank.ranks[index].rank)
        else
            Activity7DaysUI.OnClickActItem(guid)
        end
    end
    Activity7DaysUI.RequestRed7dayTable()
end
function Activity7DaysUI.OnClickActItem(guid)
    local btn = GUI.GetByGuid(guid)
    local id = tonumber(GUI.GetData(btn, DefTipsItemId))
    local guardId = tonumber(GUI.GetData(btn,"isguard"))
    if id then
        if guardId== nil or guardId == 0 then
            local tips = Tips.CreateByItemId(id, _gt.GetUI("panelBg"), "tips", 0, 0)
        else
            GlobalProcessing.ShowGuardInfo(guardId)
        end

    end
end
function Activity7DaysUI.Main(parameter)
    if CL.GetIntCustomData("SevenDaySwitch") == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "活动未开启")
        return
    elseif CL.GetIntCustomData("SevenDaySwitch") == 2 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "活动已结束")
        return
    end
    GUI.PostEffect()
    GameMain.AddListen("Activity7DaysUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("Activity7DaysUI", "Activity7DaysUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "七日庆典", "Activity7DaysUI", "OnExit",_gt)
    _gt.BindName(panelBg, "panelBg")
    local daysrc =
    GUI.LoopScrollRectCreate(
            panelBg,
            "daysrc",
            65,
            50,
            214,
            560,
            "Activity7DaysUI",
            "CreateItem",
            "Activity7DaysUI",
            "RefreshItem",
            0,
            false,
            Vector2.New(214, 65),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    UILayout.SetSameAnchorAndPivot(daysrc, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(daysrc, TextAnchor.UpperCenter)
    _gt.BindName(daysrc, "daysrc")
    GUI.LoopScrollRectSetTotalCount(daysrc, 8)
    GUI.LoopScrollRectRefreshCells(daysrc)
    GUI.ScrollRectSetChildSpacing(daysrc, Vector2.New(0, 5))

    --首页奖励展示图
    local _ShowPic = GUI.ImageCreate(panelBg, "ShowPic", "1800600660", 285, 210, false, 830, 404)
    _gt.BindName(_ShowPic, "showPic")
    GUI.SetAnchor(_ShowPic, UIAnchor.TopLeft)
    GUI.SetPivot(_ShowPic, UIAroundPivot.TopLeft)
    local tmp = GUI.ImageCreate(_ShowPic, "bg", "1800608670", 0, 0, false, 397, 420)
    GUI.SetAnchor(tmp, UIAnchor.BottomLeft)
    GUI.SetPivot(tmp, UIAroundPivot.BottomLeft)
    --右侧奖励栏
    local back = GUI.ImageCreate(_ShowPic, "back", "1801208160", 0, -150, false, 945, 150)
    UILayout.SetSameAnchorAndPivot(back, UILayout.Top)
    local txt = GUI.CreateStatic(back, "txt", "登录七天送极品侍从", 0, -10, 800, 124,"201")
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetFontSize(txt, 32)

	GUI.StaticSetIsGradientColor(txt,true)
	GUI.StaticSetGradient_ColorTop(txt,Color.New(0.88,0.88,0.88,1))
	GUI.StaticSetGradient_ColorBottom(txt,Color.New(0.94,0.82,0.12,1))
	GUI.SetIsOutLine(txt,true)
	GUI.SetOutLine_Distance(txt,5)
	GUI.SetOutLine_Color(txt,Color.New(0.9,0.4,0,1))
	
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.SetScale(txt, UIDefine.Vector3One * 1.5)
    local w = 86
    local h = 121
    for i = 1, 7 do
        local x = -25 + ((w + 3) * (math.fmod(i - 1, 4)))
        local y = -105 + (h + 10) * (math.floor(i / 5))
        if i == 7 then
            x = (x - 25 + ((w + 3) * (math.fmod(i, 4)))) / 2
            w = 2 * w
        end
        local tmp = Activity7DaysUI.CreateSignItem(_ShowPic, tostring(i), x, y, w, h, 76)
        _gt.BindName(tmp, "Sign" .. i)
    end
    local tip = GUI.CreateStatic(_ShowPic, "tip", "登录七天送极品侍从", -10, 0, 400, 30)
    UILayout.SetSameAnchorAndPivot(tip, UILayout.BottomRight)
    GUI.StaticSetFontSize(tip, UIDefine.FontSizeL)
    GUI.SetColor(tip, UIDefine.Yellow3Color)
    GUI.StaticSetAlignment(tip, TextAnchor.MiddleRight)
    _gt.BindName(tip, "overtime")

    --列表底板
    local _ActLstBack = GUI.ImageCreate(panelBg, "_ActLstBack", "1800400200", 285, 210, false, 830, 404)
    UILayout.SetSameAnchorAndPivot(_ActLstBack, UILayout.TopLeft)
    _gt.BindName(_ActLstBack, "actLstBack")

    --右侧奖励栏
    local _RewardBack = GUI.ImageCreate(_ActLstBack, "RewardBack", "1800600930", 0, -147, false, 828, 124)
    UILayout.SetSameAnchorAndPivot(_RewardBack, UILayout.TopLeft)
    --底纹
    local _RewardBackLight = GUI.ImageCreate(_RewardBack, "RewardBackLight", "1800608760", 4, 4)
    UILayout.SetSameAnchorAndPivot(_RewardBackLight, UILayout.TopLeft)
    --积分
    local slider =
    GUI.ScrollBarCreate(
            _RewardBack,
            "slider",
            "1800607210",
            "1800607200",
            "1800607190",
            20,
            35,
            700,
            18,
            1,
            false,
            Transition.None,
            0,
            1,
            Direction.LeftToRight,
            false
    )
    local tmpsize = Vector2.New(700, 18)
    GUI.ScrollBarSetFillSize(slider, tmpsize)
    GUI.ScrollBarSetBgSize(slider, tmpsize)
    GUI.ScrollBarSetHandleSize(slider, UIDefine.Vector2One * 20)
    _gt.BindName(slider, "rankSlider")
    local value = GUI.CreateStatic(_RewardBack, "txt", "积分:", 25, 25, 120, 60)
    GUI.StaticSetFontSize(value, UIDefine.FontSizeS)
    GUI.SetColor(value, UIDefine.YellowStdColor)
    UILayout.SetSameAnchorAndPivot(value, UILayout.Left)
    GUI.StaticSetAlignment(value, TextAnchor.MiddleCenter)
    _gt.BindName(value, "rankS")

    for i = 1, 4 do

        local itemicon = ItemIcon.Create(_RewardBack, i, (25 * i / 100) * GUI.GetWidth(slider) - 15, 25)

        GUI.ItemCtrlSetElementRect(itemicon, eItemIconElement.Selected, 0, 0)
        GUI.SetScale(itemicon,UIDefine.Vector3One*(66/80))
        UILayout.SetSameAnchorAndPivot(itemicon, UILayout.Left)
        GUI.RegisterUIEvent(itemicon, UCE.PointerClick, "Activity7DaysUI", "OnClickRank")
        local txt = GUI.CreateStatic(_RewardBack, "txt" .. i, i, (25 * i / 100) * GUI.GetWidth(slider) - 15, -40, 66, 50)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
        GUI.SetColor(txt, UIDefine.YellowStdColor)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
        UILayout.SetSameAnchorAndPivot(txt, UILayout.Left)
        _gt.BindName(itemicon, "rankItem" .. i)
        _gt.BindName(txt, "rankTxt" .. i)
        GUI.ItemCtrlSetIndex(itemicon, i)

        if i < 4 then
            local scale = GUI.ImageCreate(txt,"scale","1800208050",30,21,false,5,15,false)
        end

        --积分奖励列表红点设置
        GUI.AddRedPoint(itemicon,UIAnchor.TopLeft,5,5,"1800208080")
        GUI.SetRedPointVisable(itemicon,false)

    end

    --活动详情滚动条
    local _ActScroll =
    GUI.LoopScrollRectCreate(
            _ActLstBack,
            "ActScroll",
            3,
            4,
            824,
            400,
            "Activity7DaysUI",
            "CreateInfoItem",
            "Activity7DaysUI",
            "RefreshInfoItem",
            0,
            false,
            Vector2.New(810, 128),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top,
            false
    )
    GUI.SetAnchor(_ActScroll, UIAnchor.TopLeft)
    GUI.SetPivot(_ActScroll, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(_ActScroll, Vector2.New(0, 12))
    GUI.ScrollRectSetNormalizedPosition(_ActScroll, Vector2.New(0, 0))
    _gt.BindName(_ActScroll, "actSrc")
    _ActScroll:RegisterEvent(UCE.PointerClick)
end

function Activity7DaysUI.OnShow(parameter)
    local wnd = GUI.GetWnd("Activity7DaysUI")
    if wnd == nil then
        return
    end
    if CL.GetIntCustomData("SevenDaySwitch") == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "活动未开启")
        return
    elseif CL.GetIntCustomData("SevenDaySwitch") == 2 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "活动已结束")
        return
    end
    GUI.SetVisible(wnd,true)
    local index1 = 0
    if GlobalProcessing.OpenSevenDayIndex ~= nil then
        index1 = tonumber(GlobalProcessing.OpenSevenDayIndex)
    end
    if index1 > 0 then
        data.dayindex = index1
    else
        data.dayindex = 1
    end
    CL.RegisterMessage(GM.CustomDataUpdate, "Activity7DaysUI", "OnCustomDataUpdate")
    RoleLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel,0)))
    Activity7DaysUI.ClientRefresh()
    Activity7DaysUI.GetDate()
end



function Activity7DaysUI.OnCustomDataUpdate(type, key, val)
    if key == DefSevenDayScore then
        data.rank.cur = int64.longtonum2(val)
        Activity7DaysUI.RefreshUI()
    end
end
function Activity7DaysUI.OnClose()
    CL.UnRegisterMessage(GM.CustomDataUpdate, "Activity7DaysUI", "OnCustomDataUpdate")
    -- Activity7DaysUI.UpdateTimer:Stop()
    -- Activity7DaysUI.RefreshTimes = 0
end
function Activity7DaysUI.OnDestroy()
    Activity7DaysUI.OnClose()
end
function Activity7DaysUI.SendNotify(fromName, ...)
    CL.SendNotify(NOTIFY.SubmitForm, "FormSevenDay", fromName, ...)
end
function Activity7DaysUI.GetDate()
    Activity7DaysUI.SendNotify("GetData")
end
function Activity7DaysUI.NotifyData()
    if Activity7DaysUI.ServerData then
        if Activity7DaysUI.ServerData.ScoreAward then
            for i = 1, #data.rank.ranks do
                data.rank.ranks[i].ButtonState =
                Activity7DaysUI.ServerData.ScoreAward[data.rank.ranks[i].rank].ButtonState
            end
        end
        if Activity7DaysUI.ServerData.SignInAward then
            for i = 1, #data.sign do
                data.sign[i].ButtonState = Activity7DaysUI.ServerData.SignInAward[i].ButtonState
            end
        end
        if Activity7DaysUI.ServerData.TaskAward then
            for key, value in pairs(data.cfg) do
                -- body
                for i = 1, #value do
                    value[i].Now_Extent = Activity7DaysUI.ServerData.TaskAward[key - 1][value[i].Index].Now_Extent
                    value[i].ButtonState = Activity7DaysUI.ServerData.TaskAward[key - 1][value[i].Index].ButtonState
                end
            end
        end
    end
    Activity7DaysUI.ClientRefresh()
end
function Activity7DaysUI.Refresh()
    if Activity7DaysUI.ServerData then
        if Activity7DaysUI.ServerData.ScoreAward then
            ---@type SevenDaysRank
            local tmp = {cur = 0, ranks = {}}
            data.rank = tmp
            for key, value in pairs(Activity7DaysUI.ServerData.ScoreAward) do
                ---@type SevenDaysRankData
                local tmp = {}
                tmp.rank = key
                tmp.items = LogicDefine.SeverItems2ClientItems(value.item)
                if tmp.items then
                    tmp.rankItem = tmp.items[1]
                end
                if #data.rank.ranks == 0 then
                    table.insert(data.rank.ranks, tmp)
                else
                    for i = 1, #data.rank.ranks do
                        if key < data.rank.ranks[i].rank then
                            table.insert(data.rank.ranks, i, tmp)
                            break
                        end
                        if i == #data.rank.ranks then
                            table.insert(data.rank.ranks, tmp)
                        end
                    end
                end
            end
        end
        if Activity7DaysUI.ServerData.SignInAward then
            data.sign = {}
            for i = 1, #Activity7DaysUI.ServerData.SignInAward do
                data.sign[i] = {}
                data.sign[i].items = LogicDefine.SeverItems2ClientItems(Activity7DaysUI.ServerData.SignInAward[i].item)
                data.sign[i].isguard = tostring(Activity7DaysUI.ServerData.SignInAward[i].isguard)
            end

        end
        if Activity7DaysUI.ServerData.TaskAward then
            data.cfg = {}
            for i = 1, #Activity7DaysUI.ServerData.TaskAward do
                data.cfg[i + 1] = LuaTool.DupTable(Activity7DaysUI.ServerData.TaskAward[i])
                for j = 1, #data.cfg[i + 1] do
                    if data.cfg[i + 1][j] then
                        data.cfg[i + 1][j].Index = j
                        data.cfg[i + 1][j].items =
                        LogicDefine.SeverItems2ClientItems(Activity7DaysUI.ServerData.TaskAward[i][j].item)
                    end
                end
            end
        end
    end
    Activity7DaysUI.NotifyData()
end
function Activity7DaysUI.ClientRefresh()
    data.rank.cur = CL.GetIntCustomData(DefSevenDayScore)
    data.overtime = CL.GetIntCustomData(DefSevenDayOvertime)
    for i = 2, #data.cfg do
        if data.cfg[i] then
            table.sort(
                    data.cfg[i],
                    function(a, b)
                        ---@type SevenDaysCfg
                        local a = a
                        ---@type SevenDaysCfg
                        local b = b
                        if a.ButtonState ~= b.ButtonState then
                            return a.ButtonState < b.ButtonState
                        else
                            return a.Index < b.Index
                        end
                    end
            )
        end
    end
    for i = 1, #data.rank.ranks do
        if data.rank.ranks[i].ButtonState == BtnState.Wait and data.rank.cur > data.rank.ranks[i].rank then
            data.rank.ranks[i].ButtonState = BtnState.Get
        end
    end
    Activity7DaysUI.RefreshUI()
end
function Activity7DaysUI.RefreshUI()
    local wnd = GUI.GetWnd("Activity7DaysUI")
    if wnd == nil or GUI.GetVisible(wnd) == false then
        return
    end
    local DaySrc = _gt.GetUI("daysrc")
    GUI.LoopScrollRectRefreshCells(DaySrc)

    local showPic = _gt.GetUI("showPic")
    local actLstBack = _gt.GetUI("actLstBack")
    local show = data.dayindex == 1
    GUI.SetVisible(showPic, show)
    GUI.SetVisible(actLstBack, not show)
    if not show then
        local cnt = data.cfg[data.dayindex] and #data.cfg[data.dayindex] or 0
        --更新按钮是否可领取
        GUI.LoopScrollRectSetTotalCount(_gt.GetUI("actSrc"), cnt)
        GUI.LoopScrollRectRefreshCells(_gt.GetUI("actSrc"))
        local rankSlider = _gt.GetUI("rankSlider")
        local rankS = _gt.GetUI("rankS")
        GUI.StaticSetText(rankS, "积分:" .. data.rank.cur)
        for i = 1, 4 do
            local rankItem = _gt.GetUI("rankItem" .. i)
            local txt = _gt.GetUI("rankTxt" .. i)
            local tmp = data.rank.ranks[i]
            if tmp then
                ItemIcon.BindItemId(rankItem, tmp.rankItem.id)
                GUI.ItemCtrlSetElementValue(
                        rankItem,
                        eItemIconElement.RightBottomNum,
                        UIDefine.ExchangeMoneyToStr(tmp.rankItem.count)
                )
                GUI.SetData(rankItem, DefTipsItemId, tmp.rankItem.id)
                GUI.StaticSetText(txt, tmp.rank)
                if tmp.ButtonState == BtnState.Done then
                    GUI.ItemCtrlSetElementValue(rankItem, eItemIconElement.Selected, "1800608160")
                    GUI.ItemCtrlSetElementRect(rankItem, eItemIconElement.Selected, 0,0,70,70)
                    GUI.ItemCtrlSelect(rankItem)
                else
                    GUI.ItemCtrlSetElementValue(rankItem, eItemIconElement.Selected, "")
                    GUI.ItemCtrlUnSelect(rankItem)
                end
                if tmp.ButtonState == BtnState.Lock then
                    GUI.ItemCtrlSetIconGray(rankItem, true)
                else
                    GUI.ItemCtrlSetIconGray(rankItem, false)
                end
            else
                ItemIcon.SetEmpty(rankItem)
                GUI.StaticSetText(txt, 0)
            end

        end
        if data.rank.ranks and data.rank.ranks[4] then
            GUI.ScrollBarSetPos(rankSlider, data.rank.cur / data.rank.ranks[4].rank)
        else
            GUI.ScrollBarSetPos(rankSlider, 0)
        end
    else
        for i = 1, 7 do
            Activity7DaysUI.RefreshSignItem(_gt.GetGuid("Sign" .. i), i)
        end
    end
    GUI.StaticSetText(_gt.GetUI("overtime"), "剩余时间:  "..UIDefine.LeftTimeFormat(data.overtime))
end

function Activity7DaysUI.OnDayBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local index = GUI.CheckBoxExGetIndex(btn)
    if lastCheckBoxGuid ~= nil then
        if tostring(guid) ~= tostring(lastCheckBoxGuid) then
            local lastBtn = GUI.GetByGuid(lastCheckBoxGuid)
            GUI.CheckBoxExSetCheck(lastBtn,false)
        end
    end
    GUI.CheckBoxExSetCheck(btn,true)
    lastCheckBoxGuid = guid
    data.dayindex = index + 1
    data.dayGuid = guid
    Activity7DaysUI.RefreshUI()
    GUI.ScrollRectSetNormalizedPosition(_gt.GetUI("actSrc"), UIDefine.Vector2One * 0)
end

function Activity7DaysUI.RequestRed7dayTable()
    CL.SendNotify(NOTIFY.SubmitForm,"FormSevenDay","RedPointRefresh")
end

function Activity7DaysUI.RefreshRed7day()
    SetRedPointTable = Activity7DaysUI.RedPointTable
    if SetRedPointTable ~= nil then
        --首页七天签到奖励
        if _gt ~= nil then
            local loopScroll = _gt.GetUI("daysrc")
            GUI.LoopScrollRectSetTotalCount(loopScroll, 8)
            GUI.LoopScrollRectRefreshCells(loopScroll)
        end

        for i = 1, #SetRedPointTable["SignInAward"] do
            local icon = GUI.Get("Activity7DaysUI/panelBg/ShowPic/"..i.."/icon")
            local effect = GUI.GetChild(icon,"effect")
            if icon then
                GUI.AddRedPoint(icon,UIAnchor.TopLeft,5,5,"1800208080")
                GUI.SetRedPointVisable(icon,SetRedPointTable["SignInAward"][i])
                GUI.SetVisible(effect,SetRedPointTable["SignInAward"][i])
                GUI.SpriteFrameSetIsLoop(effect, SetRedPointTable["SignInAward"][i])
                GUI.Play(effect)
            end
        end

        for k, v in pairs(SetRedPointTable["ScoreAward"]) do
            local index = k/25
            if _gt ~= nil then
                local rankItem = _gt.GetUI("rankItem" .. index)
                if rankItem then
                    GUI.SetRedPointVisable(rankItem,v)
                end
            end
        end

        local RedSumNumMax = 0
        for k, v in pairs(SetRedPointTable["ScoreAward"]) do
            if v == true then
                RedSumNumMax = RedSumNumMax + 1
            end
        end
        for i = 1, #SetRedPointTable["SignInAward"] do
            if SetRedPointTable["SignInAward"][i] == true then
                RedSumNumMax = RedSumNumMax + 1
            end
        end
        for i=1, #SetRedPointTable["TaskAward"] do
            for j, h in pairs(SetRedPointTable["TaskAward"][i]) do
                if h == true then
                    RedSumNumMax = RedSumNumMax + 1
                end
            end
        end

        if RedSumNumMax == 0 then
            Activity7DaysUI.AddRed7day(false)
        else
            Activity7DaysUI.AddRed7day(true)
        end
    end
end

function Activity7DaysUI.AddRed7day(isShow)
    if isShow then
        GlobalProcessing.RedPointController("dayBtn", "SevenDay",1)
    else
        GlobalProcessing.RedPointController("dayBtn", "SevenDay",0)
    end
end
