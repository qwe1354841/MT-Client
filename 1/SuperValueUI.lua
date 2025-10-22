local SuperValueUI = {}
_G.SuperValueUI = SuperValueUI

local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local _gt = UILayout.NewGUIDUtilTable()
local TotalRechargeScrollShow = 1

local QualityRes = UIDefine.ItemIconBg
local RMBShopOfOnceTable = {}

local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")

-------------------------------------------------Start 颜色配置 Start-------------------------------------

local WhiteColor = Color.New(251/255,248/255,234/255)
local BrownColor = Color.New(128/255,85/255,56/255)
---------------------------------------------------End 颜色配置 End---------------------------------------




local turnableSubTabList = {
    { "堆金积玉", "SubTabBtn1", "1800402180", "1800402181", "OnSubTabBtn1Click", -340, -250, 145, 50, 100, 35 },
    { "稀世珍宝", "SubTabBtn2", "1800402180", "1800402181", "OnSubTabBtn2Click", -190, -250, 145, 50, 100, 35 },
}

function SuperValueUI.Main(parameter)
    GUI.PostEffect();
    _gt = UILayout.NewGUIDUtilTable();
    local wnd = GUI.WndCreateWnd("SuperValueUI", "SuperValueUI", 0, 0);

    local panelBg = UILayout.CreateFrame_WndStyle0(wnd, "超    值", "SuperValueUI", "OnExit", _gt);
    _gt.BindName(panelBg,"panelBg")

    local typeScroll = GUI.LoopScrollRectCreate(
            panelBg,
            "typeScroll",
            75,
            65,
            200,
            550,
            "SuperValueUI",
            "CreateTypeItem",
            "SuperValueUI",
            "RefreshTypeScroll",
            0,
            false,
            Vector2.New(200, 60),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    UILayout.SetSameAnchorAndPivot(typeScroll, UILayout.TopLeft);
    GUI.ScrollRectSetChildSpacing(typeScroll, Vector2.New(0, 7));
    _gt.BindName(typeScroll, "typeScroll");
end

function SuperValueUI.InitData()
    SuperValueUI.typeIndex = 1;
    SuperValueUI.subTabIndex = 1;
    SuperValueUI.typeDataList = {}
    SuperValueUI.rechargeAwardItemList = {}
    SuperValueUI.stateList = {}
    SuperValueUI.isTenEven = false;
    SuperValueUI.turntableTargetAngle = 0;
    SuperValueUI.tenRewardInfo = {};
    RMBShopOfOnceTable = {}
end

function SuperValueUI.OnShow(parameter)
    local wnd = GUI.GetWnd("SuperValueUI");
    if wnd == nil then
        return ;
    end
    GUI.SetVisible(wnd, true);
    SuperValueUI.InitData();
    local index1, index2 = 1 ,0
    if parameter ~= nil then
        index1, index2 = UIDefine.GetParameterStr(parameter)
    end
    local tenEvenBtn = _gt.GetUI("tenEvenBtn")
    GUI.CheckBoxExSetCheck(tenEvenBtn, SuperValueUI.isTenEven)
    SuperValueUI.SetTypeDataList()
    SuperValueUI.SetTypeIndex(tonumber(index1))
end

function SuperValueUI.OnSubTabBtn1Click()
    SuperValueUI.subTabIndex = 1;

    local turntablePointer = _gt.GetUI("turntablePointer")
    GUI.SetEulerAngles(turntablePointer, Vector3.New(0, 0, 0));

    SuperValueUI.Refresh();
end

function SuperValueUI.OnSubTabBtn2Click()
    SuperValueUI.subTabIndex = 2;

    local turntablePointer = _gt.GetUI("turntablePointer")
    GUI.SetEulerAngles(turntablePointer, Vector3.New(0, 0, 0));

    SuperValueUI.Refresh();
end

function SuperValueUI.OnExit()
    GUI.CloseWnd("SuperValueUI")
end

function SuperValueUI.RefreshData(mode)
    local wnd = GUI.GetWnd("SuperValueUI")
    if wnd == nil or GUI.GetVisible(wnd) == false then
        return ;
    end

    if CL.GetMode() == 1 then
    end
    --设置是否显示多个神壕至尊礼的子项
    TotalRechargeScrollShow = 2 --1为显示三个，2为显示所有
    SuperValueUI.Refresh()
end

SuperValueUI.TypeIndexTable = {
    ['幸运大转盘'] = 'LuckyWheel',
    ['GO购豪华礼'] = 'RechargeOfDay',
    ['神壕至尊礼'] = 'RechargeOfAcc',
    ['至尊月卡'] = 'MonthCard',
    ['超值1元购'] = 'BuyOfDay',
    ['每日消费送礼'] = 'ConsumIngotOfDay',
    ['等级基金'] = 'LevelFund',
    ['限购大礼包'] = 'RMBShopOfOnce',
    ['连连充福利'] = 'RechargeOfCon',
    ['消费返元宝'] = 'ConsumIngotOfAcc',
}

function SuperValueUI.SetTypeIndex(index)
    SuperValueUI.typeIndex = index
    local typeData = SuperValueUI.typeDataList[SuperValueUI.typeIndex]
    test("typeData",inspect(typeData))
    if typeData.Name == "幸运大转盘" then
        SuperValueUI.subTabIndex = 1
        local turntableCover = _gt.GetUI("turntableCover")
        GUI.SetVisible(turntableCover, false)
    end
    local mode = SuperValueUI.TypeIndexTable[typeData.Name] or ""
    if mode ~= "" then
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "GetConfig", mode)
    end

end

function SuperValueUI.SetTypeDataList()
    SuperValueUI.typeDataList = {}
    if RECHARGE_DATA.LuckyWheel_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "幸运大转盘" })
    end

    if RECHARGE_DATA.RechargeOfDay_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "GO购豪华礼" })
    end

    if RECHARGE_DATA.RechargeOfAcc_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "神壕至尊礼" })
    end

    if RECHARGE_DATA.MonthCard_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "至尊月卡" })
    end

    if RECHARGE_DATA.ConsumIngotOfDay_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "每日消费送礼" })
    end

    if RECHARGE_DATA.BuyOfDay_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "超值1元购" })
    end

    if RECHARGE_DATA.LevelFund_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "等级基金" })
    end

    if RECHARGE_DATA.RMBShopOfOnce_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "限购大礼包" })
    end

    if RECHARGE_DATA.RechargeOfCon_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "连连充福利" })
    end

    if RECHARGE_DATA.ConsumIngotOfAcc_Switch == "on" then
        table.insert(SuperValueUI.typeDataList, { Name = "消费返元宝" })
    end
end

function SuperValueUI.Refresh()
    test("跳转刷新页面")
    local typeScroll = _gt.GetUI("typeScroll")
    GUI.LoopScrollRectSetTotalCount(typeScroll, #SuperValueUI.typeDataList);

    GUI.LoopScrollRectRefreshCells(typeScroll);
    GUI.LoopScrollRectSrollToCell(typeScroll,SuperValueUI.typeIndex - 1,2000)


    for i = 1, #SuperValueUI.typeDataList do
        if _gt["tabPage" .. i] ~= nil then
            local page = _gt.GetUI("tabPage" .. i);
            GUI.SetVisible(page, i == SuperValueUI.typeIndex);
        end
    end

    local typeData = SuperValueUI.typeDataList[SuperValueUI.typeIndex]
    if typeData.Name == "幸运大转盘" then
        SuperValueUI.CreatePage(SuperValueUI.CreateTurntable)

        SuperValueUI.RefreshTurntable();
    elseif typeData.Name == "GO购豪华礼" then
        SuperValueUI.CreatePage(SuperValueUI.CreateDailyRecharge)
        SuperValueUI.RefreshDailyRecharge()


    elseif typeData.Name == "神壕至尊礼" then
        SuperValueUI.CreatePage(SuperValueUI.CreateTotalRecharge)
        SuperValueUI.RefreshTotalRecharge()


    elseif typeData.Name == "至尊月卡" then
        SuperValueUI.CreatePage(SuperValueUI.CreateMonthCard)
        SuperValueUI.RefreshMonthCard()


    elseif typeData.Name == "超值1元购" then
        SuperValueUI.CreatePage(SuperValueUI.CreateDailyLimitPurchase)
        SuperValueUI.RefreshDailyLimitPurchase()


    elseif typeData.Name == "每日消费送礼" then
        SuperValueUI.CreatePage(SuperValueUI.CreateDailyConsumeReward)
        SuperValueUI.RefreshDailyConsumeReward()


    elseif typeData.Name == "等级基金" then
        SuperValueUI.CreatePage(SuperValueUI.CreateLevelFundPage)
        SuperValueUI.RefreshLevelFundPage()


    elseif typeData.Name == "限购大礼包" then
        SuperValueUI.CreatePage(SuperValueUI.CreateRMBShopOfOncPage)
        SuperValueUI.RefreshRMBShopOfOncPage()


    elseif typeData.Name == "连连充福利" then
        SuperValueUI.CreatePage(SuperValueUI.CreateDailyRechargeReward)
        SuperValueUI.RefreshDailyRechargeReward()


    elseif typeData.Name == "消费返元宝" then
        SuperValueUI.CreatePage(SuperValueUI.CreateConsumeReturnGold)
        SuperValueUI.RefreshConsumeReturnGold()
    end

end

function SuperValueUI.CreatePage(CreateFun)
    if _gt["tabPage" .. SuperValueUI.typeIndex] ~= nil then
        return ;
    end

    if CreateFun ~= nil then
        local panelBg = _gt.GetUI("panelBg");
        local page = CreateFun(panelBg)
        _gt.BindName(page, "tabPage" .. SuperValueUI.typeIndex);
    end
end

function SuperValueUI.RefreshTotalRecharge()
    local totalRechargePage = _gt.GetUI("totalRechargePage")

    local titleBg = GUI.GetChild(totalRechargePage, "titleBg");
    local timeLimitBg = GUI.GetChild(titleBg, "timeLimitBg");
    local timeLimitText = GUI.GetChild(timeLimitBg, "timeLimitText");
    GUI.StaticSetText(timeLimitText, RECHARGE_DATA.RechargeOfAcc_StartTime .. " 至 " .. RECHARGE_DATA.RechargeOfAcc_EndTime);

    SuperValueUI.rechargeAwardItemList = {};
    SuperValueUI.stateList = {};
    local hasVisible = false
    local count = 3;
    for i = 1, #RECHARGE_DATA.RechargeOfAcc_Config do
        if RECHARGE_DATA.RechargeOfAcc_Config[i].VisibleMoney then
            hasVisible = true
            if RECHARGE_DATA["RechargeOfAcc_State_" .. i] ~= 2 and RECHARGE_DATA.RechargeOfAcc_Value >= RECHARGE_DATA.RechargeOfAcc_Config[i].VisibleMoney then
                table.insert(SuperValueUI.stateList, i);
            end
        else
            if RECHARGE_DATA["RechargeOfAcc_State_" .. i] ~= 2 then
                table.insert(SuperValueUI.stateList, i);
            end
            if RECHARGE_DATA.RechargeOfAcc_Value >= RECHARGE_DATA.RechargeOfAcc_Config[i].Target then
                count = i + 1;
            end
        end
    end

    for i = 1, #RECHARGE_DATA.RechargeOfAcc_Config do
        if RECHARGE_DATA["RechargeOfAcc_State_" .. i] == 2 then
            table.insert(SuperValueUI.stateList, i);
        end
    end
    local totalRechargeScroll = _gt.GetUI("totalRechargeScroll")


    if hasVisible then
        GUI.LoopScrollRectSetTotalCount(totalRechargeScroll, #SuperValueUI.stateList)
    else
        count = count < 3 and 3 or count;
        if TotalRechargeScrollShow ~= 1 then
            count = count < #RECHARGE_DATA.RechargeOfAcc_Config and #RECHARGE_DATA.RechargeOfAcc_Config or count;
            GUI.LoopScrollRectSetTotalCount(totalRechargeScroll, count)
        else
            count = count > #RECHARGE_DATA.RechargeOfAcc_Config and #RECHARGE_DATA.RechargeOfAcc_Config or count;
            GUI.LoopScrollRectSetTotalCount(totalRechargeScroll, count)
        end
    end
    GUI.LoopScrollRectRefreshCells(totalRechargeScroll);
end

function SuperValueUI.CreateTotalRecharge(panelBg)
    local page = GUI.GroupCreate(panelBg, "totalRechargePage", 110, 65, 820, 550)
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top);
    _gt.BindName(page, "totalRechargePage");
    local titleBg = GUI.ImageCreate(page, "titleBg", "1800608600", 0, -205, false, 830, 125)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Center);

    local timeLimitBg = GUI.ImageCreate(titleBg, "timeLimitBg", "1800601070", 0, -1, false, 480, 35);
    UILayout.SetSameAnchorAndPivot(timeLimitBg, UILayout.Bottom);

    local timeLimitText = GUI.CreateStatic(timeLimitBg, "timeLimitText", "2020.1.1  至  2020.1.1", 0, -2, 480, 35);
    GUI.SetColor(timeLimitText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(timeLimitText, UIDefine.FontSizeS);
    UILayout.SetSameAnchorAndPivot(consumeText, UILayout.Center);
    GUI.StaticSetAlignment(timeLimitText, TextAnchor.MiddleCenter);

    local bg = GUI.ImageCreate(page, "bg", "1800400200", 0, 70, false, 830, 410)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Center);

    local totalRechargeScroll = GUI.LoopScrollRectCreate(
            bg,
            "totalRechargeScroll",
            0,
            0,
            820,
            395,
            "SuperValueUI",
            "CreateTotalRechargeItem",
            "SuperValueUI",
            "RefreshTotalRechargeScroll",
            0,
            false,
            Vector2.New(810, 125),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    GUI.ScrollRectSetChildSpacing(totalRechargeScroll, Vector2.New(0, 10));
    _gt.BindName(totalRechargeScroll, "totalRechargeScroll");

    return page
end

function SuperValueUI.CreateTotalRechargeItem()
    local totalRechargeScroll = _gt.GetUI("totalRechargeScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(totalRechargeScroll);
    local totalRechargeItem = GUI.ImageCreate(totalRechargeScroll, "totalRechargeItem" .. curCount, "1801100010", 0, 0);

    local text1 = GUI.CreateStatic(totalRechargeItem, "text1", "累计充值（元）", 20, -20, 200, 35);
    GUI.SetColor(text1, UIDefine.BrownColor);
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeM);
    UILayout.SetSameAnchorAndPivot(text1, UILayout.Left);
    GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter);

    local countBg = GUI.ImageCreate(totalRechargeItem, "countBg", "1800600500", 25, 20, false, 180, 35);
    UILayout.SetSameAnchorAndPivot(countBg, UILayout.Left);

    local countText = GUI.CreateStatic(countBg, "countText", "（0/6）", 0, 0, 250, 35);
    GUI.SetColor(countText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(countText, UIDefine.FontSizeL);
    UILayout.SetSameAnchorAndPivot(countText, UILayout.Center);
    GUI.StaticSetAlignment(countText, TextAnchor.MiddleCenter);

    for i = 1, 5 do
        local itemIcon = ItemIcon.Create(totalRechargeItem, "itemIcon" .. i, -150 + (i - 1) * 90, 1);
        GUI.SetData(itemIcon, "Index", i);
        GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "SuperValueUI", "OnTotalRechargeItemIconClick");
    end

    local getBtn = GUI.ButtonCreate(totalRechargeItem, "getBtn", "1800002110", -20, 0, Transition.ColorTint, "充值", 120, 45, false);
    GUI.SetIsOutLine(getBtn, true);
    GUI.ButtonSetTextFontSize(getBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(getBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(getBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(getBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(getBtn, UCE.PointerClick, "SuperValueUI", "OnTotalRechargeGetBtnClick");
    UILayout.SetSameAnchorAndPivot(getBtn, UILayout.Right);
    GUI.AddRedPoint(getBtn, UIAnchor.TopRight, -5, 5)

    local alreadyGet = GUI.ImageCreate(totalRechargeItem, "alreadyGet", "1800604390", -20, 0);
    UILayout.SetSameAnchorAndPivot(alreadyGet, UILayout.Right);

    return totalRechargeItem;
end

function SuperValueUI.OnTotalRechargeGetBtnClick(guid)
    local getBtn = GUI.GetByGuid(guid);
    local index = tonumber(GUI.GetData(getBtn, "Index"));
    local state = RECHARGE_DATA["RechargeOfAcc_State_" .. index]
    if state == 0 then
        SuperValueUI.OnExit();
        GetWay.Def[1].jump("MallUI", "充值")
    elseif state == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "RechargeOfAcc_Receive", tostring(index));
    elseif state == 2 then

    end
end

function SuperValueUI.OnTotalRechargeItemIconClick(guid)
    local itemIcon = GUI.GetByGuid(guid);
    local itemIndex = tonumber(GUI.GetData(itemIcon, "ItemIndex"));
    local index = tonumber(GUI.GetData(itemIcon, "Index"));
	local keyName = GUI.GetData(itemIcon, "ItemKey")
    local totalRechargePage = _gt.GetUI("totalRechargePage")
    if SuperValueUI.rechargeAwardItemList[itemIndex] ~= nil then
        if index <= #SuperValueUI.rechargeAwardItemList[itemIndex] then
            local data = SuperValueUI.rechargeAwardItemList[itemIndex][index]
            if data.Type == 1 then
                Tips.CreateByItemKeyNameWithBind(keyName, data.Bind, totalRechargePage, "itemTips", -400, 100)
            elseif data.Type == 2 then
            end
        end
    end
end

function SuperValueUI.RefreshTotalRechargeScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local totalRechargeItem = GUI.GetByGuid(guid);
    index = index + 1;

    if index > #RECHARGE_DATA.RechargeOfAcc_Config then
        return ;
    end

    index = SuperValueUI.GetRealIndex(index)
    local data = RECHARGE_DATA.RechargeOfAcc_Config[index];
    local countBg = GUI.GetChild(totalRechargeItem, "countBg")
    local countText = GUI.GetChild(countBg, "countText")
    GUI.StaticSetText(countText, "（" .. RECHARGE_DATA.RechargeOfAcc_Value .. "/" .. data.Target .. "）")
    SuperValueUI.SetItemIconList(totalRechargeItem, index, RECHARGE_DATA.RechargeOfAcc_Config[index], data.PetList)

    local getBtn = GUI.GetChild(totalRechargeItem, "getBtn");
    GUI.SetData(getBtn, "Index", index);
    local alreadyGet = GUI.GetChild(totalRechargeItem, "alreadyGet");
    local state = RECHARGE_DATA["RechargeOfAcc_State_" .. index]
    if state == 0 then
        GUI.ImageSetImageID(totalRechargeItem, "1801100010")
        GUI.SetVisible(getBtn, true);
        GUI.ButtonSetText(getBtn, "充值");
        GUI.SetVisible(alreadyGet, false);
    elseif state == 1 then
        GUI.ImageSetImageID(totalRechargeItem, "1801100010")
        GUI.SetVisible(getBtn, true);
        GUI.ButtonSetText(getBtn, "领取");
        GUI.SetVisible(alreadyGet, false);
    elseif state == 2 then
        GUI.ImageSetImageID(totalRechargeItem, "1801100012")
        GUI.SetVisible(getBtn, false)
        GUI.SetVisible(alreadyGet, true);
    end
    GUI.SetRedPointVisable(getBtn, state == 1)
end

function SuperValueUI.RefreshDailyRecharge()
    local dailyRechargePage = _gt.GetUI("dailyRechargePage");

    local titleBg = GUI.GetChild(dailyRechargePage, "titleBg");
    local timeLimitBg = GUI.GetChild(titleBg, "timeLimitBg");
    local timeLimitText = GUI.GetChild(timeLimitBg, "timeLimitText");
    GUI.StaticSetText(timeLimitText, RECHARGE_DATA.RechargeOfDay_StartTime .. " 至 " .. RECHARGE_DATA.RechargeOfDay_EndTime);

    SuperValueUI.rechargeAwardItemList = {};

    SuperValueUI.stateList = {};
    for i = 1, #RECHARGE_DATA.RechargeOfDay_Config do
        if RECHARGE_DATA["RechargeOfDay_State_" .. i] ~= 2 then
            table.insert(SuperValueUI.stateList, i);
        end
    end

    for i = 1, #RECHARGE_DATA.RechargeOfDay_Config do
        if RECHARGE_DATA["RechargeOfDay_State_" .. i] == 2 then
            table.insert(SuperValueUI.stateList, i);
        end
    end

    local dailyRechargeScroll = GUI.GetByGuid(_gt.dailyRechargeScroll)
    GUI.LoopScrollRectSetTotalCount(dailyRechargeScroll, #RECHARGE_DATA.RechargeOfDay_Config);
    GUI.LoopScrollRectRefreshCells(dailyRechargeScroll);
end

function SuperValueUI.GetRealIndex(index)
    return SuperValueUI.stateList[index];
end

function SuperValueUI.CreateDailyRecharge(panelBg)
    local page = GUI.GroupCreate(panelBg, "dailyRechargePage", 110, 65, 820, 550)
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top);
    _gt.BindName(page, "dailyRechargePage");
    local titleBg = GUI.ImageCreate(page, "titleBg", "1800608610", 0, -205, false, 830, 125)
    UILayout.SetSameAnchorAndPivot(titleBg, UILayout.Center);

    local timeLimitBg = GUI.ImageCreate(titleBg, "timeLimitBg", "1800601070", 0, -1, false, 480, 35);
    UILayout.SetSameAnchorAndPivot(timeLimitBg, UILayout.Bottom);

    local timeLimitText = GUI.CreateStatic(timeLimitBg, "timeLimitText", "2020.1.1  至  2020.1.1", 0, -2, 480, 35);
    GUI.SetColor(timeLimitText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(timeLimitText, UIDefine.FontSizeS);
    UILayout.SetSameAnchorAndPivot(consumeText, UILayout.Center);
    GUI.StaticSetAlignment(timeLimitText, TextAnchor.MiddleCenter);

    --local dailyRechargeHintBtn = GUI.ButtonCreate(titleBg, "hintBtn", "1800602230", -20, 15, Transition.ColorTint);
    --UILayout.SetSameAnchorAndPivot(dailyRechargeHintBtn, UILayout.TopRight);
    --GUI.RegisterUIEvent(dailyRechargeHintBtn, UCE.PointerClick, "SuperValueUI", "OnDailyRechargeHintBtnClick");

    local bg = GUI.ImageCreate(page, "bg", "1800400200", 0, 70, false, 830, 410)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Center);

    local dailyRechargeScroll = GUI.LoopScrollRectCreate(bg, "dailyRechargeScroll", 0, 0, 820, 395,
            "SuperValueUI", "CreateDailyRechargeItem", "SuperValueUI", "RefreshDailyRechargeScroll", 0, false,
            Vector2.New(810, 125), 1, UIAroundPivot.Top, UIAnchor.Top);
    GUI.ScrollRectSetChildSpacing(dailyRechargeScroll, Vector2.New(0, 10));
    _gt.BindName(dailyRechargeScroll, "dailyRechargeScroll");

    return page
end

function SuperValueUI.OnDailyRechargeHintBtnClick()
    local dailyRechargePage = _gt.GetUI("dailyRechargePage");
    local msg = "测试测试测试"
    Tips.CreateHint(msg, dailyRechargePage, 0, 65, UILayout.TopRight)
end

function SuperValueUI.CreateDailyRechargeItem()
    local dailyRechargeScroll = _gt.GetUI("dailyRechargeScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(dailyRechargeScroll);
    local dailyRechargeItem = GUI.ImageCreate(dailyRechargeScroll, "dailyRechargeItem" .. curCount, "1801100010", 0, 0);

    local text1 = GUI.CreateStatic(dailyRechargeItem, "text1", "每日充值（元）", 20, -20, 200, 35);
    GUI.SetColor(text1, UIDefine.BrownColor);
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeM);
    UILayout.SetSameAnchorAndPivot(text1, UILayout.Left);
    GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter);

    local countBg = GUI.ImageCreate(dailyRechargeItem, "countBg", "1800600500", 25, 20, false, 180, 35);
    UILayout.SetSameAnchorAndPivot(countBg, UILayout.Left);

    local countText = GUI.CreateStatic(countBg, "countText", "（0/6）", 0, 0, 250, 35);
    GUI.SetColor(countText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(countText, UIDefine.FontSizeL);
    UILayout.SetSameAnchorAndPivot(countText, UILayout.Center);
    GUI.StaticSetAlignment(countText, TextAnchor.MiddleCenter);

    for i = 1, 5 do
        local itemIcon = ItemIcon.Create(dailyRechargeItem, "itemIcon" .. i, -150 + (i - 1) * 90, 1);
        GUI.SetData(itemIcon, "Index", i);
        GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "SuperValueUI", "OnDailyRechargeItemIconClick");
    end

    local getBtn = GUI.ButtonCreate(dailyRechargeItem, "getBtn", "1800002110", -20, 0, Transition.ColorTint, "充值", 120, 45, false);
    GUI.SetIsOutLine(getBtn, true);
    GUI.ButtonSetTextFontSize(getBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(getBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(getBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(getBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(getBtn, UCE.PointerClick, "SuperValueUI", "OnDailyRechargeGetBtnClick");
    UILayout.SetSameAnchorAndPivot(getBtn, UILayout.Right);
    GUI.AddRedPoint(getBtn, UIAnchor.TopRight, -5, 5)

    local alreadyGet = GUI.ImageCreate(dailyRechargeItem, "alreadyGet", "1800604390", -20, 0);
    UILayout.SetSameAnchorAndPivot(alreadyGet, UILayout.Right);

    return dailyRechargeItem;
end

function SuperValueUI.OnDailyRechargeItemIconClick(guid)
    local itemIcon = GUI.GetByGuid(guid);
    local itemIndex = tonumber(GUI.GetData(itemIcon, "ItemIndex"));
    local index = tonumber(GUI.GetData(itemIcon, "Index"));
	local keyName = GUI.GetData(itemIcon, "ItemKey")
    local dailyRechargePage = _gt.GetUI("dailyRechargePage")
    if SuperValueUI.rechargeAwardItemList[itemIndex] ~= nil then
        if index <= #SuperValueUI.rechargeAwardItemList[itemIndex] then
            local data = SuperValueUI.rechargeAwardItemList[itemIndex][index]
            if data.Type == 1 then
                Tips.CreateByItemKeyNameWithBind(keyName, data.Bind, dailyRechargePage, "itemTips", -400, 20)
            elseif data.Type == 2 then
            end
        end
    end
end

function SuperValueUI.RefreshDailyRechargeScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local dailyRechargeItem = GUI.GetByGuid(guid);
    index = index + 1;
    if index > #RECHARGE_DATA.RechargeOfDay_Config then
        return ;
    end

    index = SuperValueUI.GetRealIndex(index)
    local data = RECHARGE_DATA.RechargeOfDay_Config[index];
    local countBg = GUI.GetChild(dailyRechargeItem, "countBg")
    local countText = GUI.GetChild(countBg, "countText")
    GUI.StaticSetText(countText, "（" .. RECHARGE_DATA.RechargeOfDay_Value .. "/" .. data.Target .. "）")
    SuperValueUI.SetItemIconList(dailyRechargeItem, index, data.ItemList, data.PetList)

    local getBtn = GUI.GetChild(dailyRechargeItem, "getBtn");
    GUI.SetData(getBtn, "Index", index);
    local alreadyGet = GUI.GetChild(dailyRechargeItem, "alreadyGet");
    local state = RECHARGE_DATA["RechargeOfDay_State_" .. index]
    if state == 0 then
        GUI.ImageSetImageID(dailyRechargeItem, "1801100010")
        GUI.SetVisible(getBtn, true);
        GUI.ButtonSetText(getBtn, "充值");
        GUI.SetVisible(alreadyGet, false);
    elseif state == 1 then
        GUI.ImageSetImageID(dailyRechargeItem, "1801100010")
        GUI.SetVisible(getBtn, true);
        GUI.ButtonSetText(getBtn, "领取");
        GUI.SetVisible(alreadyGet, false);
    elseif state == 2 then
        GUI.ImageSetImageID(dailyRechargeItem, "1801100012")
        GUI.SetVisible(getBtn, false);
        GUI.SetVisible(alreadyGet, true);
    end
    GUI.SetRedPointVisable(getBtn, state == 1)
end

function SuperValueUI.OnDailyRechargeGetBtnClick(guid)
    local getBtn = GUI.GetByGuid(guid);
    local index = tonumber(GUI.GetData(getBtn, "Index"));
    local state = RECHARGE_DATA["RechargeOfDay_State_" .. index]
    if state == 0 then
        SuperValueUI.OnExit();
        GetWay.Def[1].jump("MallUI", "充值")
    elseif state == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "RechargeOfDay_Receive", tostring(index));
    elseif state == 2 then

    end
end

function SuperValueUI.SetItemIconList(parent, index, serverItemList, serverPetList)
    local itemList = {}
    local NewServerItemList = {}
    local n = 0;
    test("serverItemList",inspect(serverItemList))
    local RoleID = CL.GetRoleTemplateID()


    if serverItemList ~= nil then
        local temp = {}

        if serverItemList.ItemList ~= nil then
            for i, v in ipairs(serverItemList.ItemList) do
                table.insert(temp,v)
            end
            for i1, v1 in pairs(serverItemList) do
                if tostring(i1) == tostring("ItemList_"..RoleID) then
                    for i3, v3 in ipairs(v1) do
                        table.insert(temp,v3)
                    end
                end
            end

            if #temp > 0 then
                for i4, v4 in ipairs(temp) do
                    table.insert(NewServerItemList,v4)
                end
            end
        else
            NewServerItemList = serverItemList
        end
        

        for i, v in ipairs(NewServerItemList) do
            if type(v) == "string" then
                n = n + 1;
                itemList[n] = { Type = 1, KeyName = v };
                if type(NewServerItemList[i + 1]) == "number" then
                    itemList[n].Num = NewServerItemList[i + 1];
                elseif n then
                    itemList[n].Num = 1;
                end

                if type(NewServerItemList[i + 2]) == "number" then
                    itemList[n].Bind = NewServerItemList[i + 2];
                else
                    itemList[n].Bind = 1;
                end
            end
        end
    end

    if serverPetList ~= nil then
        for i, v in ipairs(serverPetList) do
            if type(v) == "string" then
                n = n + 1;
                itemList[n] = { Type = 2, KeyName = v };
                if type(serverPetList[i + 1]) == "number" then
                    itemList[n].Bind = serverPetList[i + 1];
                else
                    itemList[n].Bind = 1
                end

                if type(serverPetList[i + 2]) == "number" then
                    itemList[n].Level = serverPetList[i + 2];
                else
                    itemList[n].Level = 1;
                end
            end
        end
    end

    SuperValueUI.rechargeAwardItemList[index] = itemList;


    for i = 1, #itemList do
        local itemIcon = GUI.GetChild(parent, "itemIcon" .. i);
        local type = itemList[i].Type;
        local keyName = itemList[i].KeyName;
		if string.find(keyName, "#") then					
			keyName = string.split(keyName, "#")[1]
		end
        local bind = itemList[i].Bind;
        if type == 1 then
            local num = itemList[i].Num;
            ItemIcon.BindItemKeyName(itemIcon, keyName)
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, num)
        elseif type == 2 then
            ItemIcon.BindPetKeyName(itemIcon, keyName)
        end

        if bind == 1 then
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, 1800707120);
            GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
        else
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.LeftTopSp, nil);
        end

        GUI.SetData(itemIcon, "ItemIndex", index);
        GUI.SetData(itemIcon, "ItemKey", itemList[i].KeyName);
    end

    for i = #itemList + 1, 5 do
        local itemIcon = GUI.GetChild(parent, "itemIcon" .. i);
        ItemIcon.SetEmpty(itemIcon);

        GUI.SetData(itemIcon, "ItemIndex", index);
    end
end

function SuperValueUI.SetDailyNum(cardBg, num)
    local preImgId = "180150501"
    local numStr = tostring(num);

    for i = #numStr, 1, -1 do
        local imgId = preImgId .. string.sub(numStr, i, i);
        local dailyNum = GUI.GetChild(cardBg, "dailyNum" .. i)
        if dailyNum == nil then
            dailyNum = GUI.ImageCreate(cardBg, "dailyNum" .. i, imgId, 0, 0)
        end
        GUI.SetPositionX(dailyNum, 80 - (#numStr - i) * 20);
        GUI.SetPositionY(dailyNum, -50);
        GUI.ImageSetImageID(dailyNum, imgId);
        GUI.SetVisible(dailyNum, true);
    end

    for i = #numStr + 1, 10 do
        local dailyNum = GUI.GetChild(cardBg, "dailyNum" .. i)
        GUI.SetVisible(dailyNum, false);
    end

    local dailyNumLight = GUI.GetChild(cardBg, "dailyNumLight")
    if dailyNumLight == nil then
        dailyNumLight = GUI.ImageCreate(cardBg, "dailyNumLight", "1801507160", 0, 0)
    end
    GUI.SetPositionX(dailyNumLight, 80);
    GUI.SetPositionY(dailyNumLight, -41);
end

function SuperValueUI.SetTotalNum(cardBg, num)
    local preImgId = "180150502"
    local numStr = tostring(num);

    for i = #numStr, 1, -1 do
        local imgId = preImgId .. string.sub(numStr, i, i);
        local totalNum = GUI.GetChild(cardBg, "totalNum" .. i)
        if totalNum == nil then
            totalNum = GUI.ImageCreate(cardBg, "totalNum" .. i, imgId, 0, 0)
        end
        GUI.SetPositionX(totalNum, 105 - (#numStr - i) * 28);
        GUI.SetPositionY(totalNum, 30);
        GUI.ImageSetImageID(totalNum, imgId);
        GUI.SetVisible(totalNum, true);
    end

    for i = #numStr + 1, 10 do
        local dailyNum = GUI.GetChild(cardBg, "totalNum" .. i)
        GUI.SetVisible(dailyNum, false);
    end
end

function SuperValueUI.SetImmAndRemainNum(area, num)
    local preImgId = "190050513"
    local numStr = tostring(num);

    for i = 1, #numStr do
        local imgId = preImgId .. string.sub(numStr, i, i);
        local immNum = GUI.GetChild(area, "numImg" .. i)
        if immNum == nil then
            immNum = GUI.ImageCreate(area, "numImg" .. i, imgId, 0, 0)
            GUI.SetAnchor(immNum, UIAnchor.Right)
            GUI.SetScale(immNum, Vector3.New(0.7, 0.7, 0.7))
        end
        GUI.SetPositionX(immNum, 20 + (i - 1) * 20);
        GUI.ImageSetImageID(immNum, imgId);
        GUI.SetVisible(immNum, true);
    end

    for i = #numStr + 1, 10 do
        local dailyNum = GUI.GetChild(area, "numImg" .. i)
        GUI.SetVisible(dailyNum, false);
    end

    local unitImg = GUI.GetChild(area, "unitImg")
    if unitImg ~= nil then
        GUI.SetPositionX(unitImg, 40 + (#numStr - 1) * 20);
    end
end

function SuperValueUI.RefreshMonthCard()
    local monthCardPage = _gt.GetUI("monthCardPage");

    local bg = GUI.GetChild(monthCardPage, "bg");

    local normalCard = GUI.GetChild(bg, "normalCard");
    local superCard = GUI.GetChild(bg, "superCard");

    SuperValueUI.SetDailyNum(normalCard, RECHARGE_DATA.MonthCard_Config[1].BonusOnce)
    SuperValueUI.SetDailyNum(superCard, RECHARGE_DATA.MonthCard_Config[2].BonusOnce)

    SuperValueUI.SetTotalNum(normalCard, RECHARGE_DATA.MonthCard_Config[1].BonusOnce * 30 + RECHARGE_DATA.MonthCard_Config[1].FirstIngot)
    SuperValueUI.SetTotalNum(superCard, RECHARGE_DATA.MonthCard_Config[2].BonusOnce * 30 + RECHARGE_DATA.MonthCard_Config[2].FirstIngot)

    local itemIcon = GUI.GetChild(normalCard, "itemIcon");
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, RECHARGE_DATA.MonthCard_Config[1].BonusOnce);
    local immArea = GUI.GetChild(normalCard, "immArea");
    local remainArea = GUI.GetChild(normalCard, "remainArea");

    local state1 = RECHARGE_DATA.MonthCard_price[1]
    local getNormalMonthCardBtn = GUI.GetChild(remainArea, "getNormalMonthCardBtn");
    if state1 == 0 then
        GUI.SetVisible(immArea, true)
        GUI.SetVisible(remainArea, false)
        local buyNormalMonthCardBtn = GUI.GetChild(immArea, "buyNormalMonthCardBtn");
        GUI.ButtonSetText(buyNormalMonthCardBtn, "￥ " .. RECHARGE_DATA.MonthCard_Config[1].Amount)
        SuperValueUI.SetImmAndRemainNum(immArea, RECHARGE_DATA.MonthCard_Config[1].FirstIngot)
    elseif state1 == 1 then
        GUI.SetVisible(immArea, false)
        GUI.SetVisible(remainArea, true)
        SuperValueUI.SetImmAndRemainNum(remainArea, RECHARGE_DATA.MonthCard_remainingDay[1])
        GUI.ButtonSetText(getNormalMonthCardBtn, "领取");
        GUI.ButtonSetShowDisable(getNormalMonthCardBtn, true);
    elseif state1 == 2 then
        GUI.SetVisible(immArea, false)
        GUI.SetVisible(remainArea, true)
        print("RECHARGE_DATA.MonthCard_remainingDay[1]",tostring(RECHARGE_DATA.MonthCard_remainingDay[1]),inspect(RECHARGE_DATA.MonthCard_remainingDay[1]))
        SuperValueUI.SetImmAndRemainNum(remainArea, RECHARGE_DATA.MonthCard_remainingDay[1])
        GUI.ButtonSetText(getNormalMonthCardBtn, "已领取");
        GUI.ButtonSetShowDisable(getNormalMonthCardBtn, false);
    end
    GUI.SetRedPointVisable(getNormalMonthCardBtn, state1 == 1)

    local itemIcon = GUI.GetChild(superCard, "itemIcon");
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, RECHARGE_DATA.MonthCard_Config[2].BonusOnce);
    local immArea = GUI.GetChild(superCard, "immArea");
    local remainArea = GUI.GetChild(superCard, "remainArea");

    local state2 = RECHARGE_DATA.MonthCard_price[2]
    local getSuperMonthCardBtn = GUI.GetChild(remainArea, "getSuperMonthCardBtn")
    if state2 == 0 then
        GUI.SetVisible(immArea, true)
        GUI.SetVisible(remainArea, false)
        local buySuperMonthCardBtn = GUI.GetChild(immArea, "buySuperMonthCardBtn");
        GUI.ButtonSetText(buySuperMonthCardBtn, "￥ " .. RECHARGE_DATA.MonthCard_Config[2].Amount)
        SuperValueUI.SetImmAndRemainNum(immArea, RECHARGE_DATA.MonthCard_Config[2].FirstIngot)
    elseif state2 == 1 then
        GUI.SetVisible(immArea, false)
        GUI.SetVisible(remainArea, true)
        SuperValueUI.SetImmAndRemainNum(remainArea, RECHARGE_DATA.MonthCard_remainingDay[2])
        GUI.ButtonSetText(getSuperMonthCardBtn, "领取");
        GUI.ButtonSetShowDisable(getSuperMonthCardBtn, true);
    elseif state2 == 2 then
        GUI.SetVisible(immArea, false)
        GUI.SetVisible(remainArea, true)
        SuperValueUI.SetImmAndRemainNum(remainArea, RECHARGE_DATA.MonthCard_remainingDay[2])
        GUI.ButtonSetText(getSuperMonthCardBtn, "已领取");
        GUI.ButtonSetShowDisable(getSuperMonthCardBtn, false);
    end
    GUI.SetRedPointVisable(getSuperMonthCardBtn, state2 == 1)
end

function SuperValueUI.CreateMonthCard(panelBg)
    local page = GUI.GroupCreate(panelBg, "monthCardPage", 110, 65, 820, 550)
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top);
    _gt.BindName(page, "monthCardPage")

    local bg = GUI.ImageCreate(page, "bg", "1800400200", 0, 0, false, 830, 550)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Center);

    local normalCard = GUI.ImageCreate(bg, "normalCard", "1801508130", -205, 1, false, 410, 545)
    UILayout.SetSameAnchorAndPivot(normalCard, UILayout.Center);

    SuperValueUI.SetDailyNum(normalCard, 30)

    local ingotImg = GUI.ImageCreate(normalCard, "ingotImg", "1801504250", 115, -50)

    SuperValueUI.SetTotalNum(normalCard, 1200)

    local ingotImg2 = GUI.ImageCreate(normalCard, "ingotImg2", "1801504190", 150, 30)

    --月惠卡图标
    local itemIcon = GUI.ItemCtrlCreate(normalCard, "itemIcon", UIDefine.ItemIconBg[3], -84, 126, 85, 85)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1800408610");
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1, 80, 70);

    local immArea = GUI.ImageCreate(normalCard, "immArea", "1801504320", -75, 195)

    local unitImg = GUI.ImageCreate(immArea, "unitImg", "1801504250", 0, 0)
    GUI.SetAnchor(unitImg, UIAnchor.Right)
    GUI.SetPivot(unitImg, UIAroundPivot.Left)
    SuperValueUI.SetImmAndRemainNum(immArea, 300)

    local buyNormalMonthCardBtn = GUI.ButtonCreate(immArea, "buyNormalMonthCardBtn", "1800002110", 75, 40, Transition.ColorTint, "30元", 140, 40, false);
    GUI.SetIsOutLine(buyNormalMonthCardBtn, true);
    GUI.ButtonSetTextFontSize(buyNormalMonthCardBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(buyNormalMonthCardBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(buyNormalMonthCardBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(buyNormalMonthCardBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(buyNormalMonthCardBtn, UCE.PointerClick, "SuperValueUI", "OnBuyNormalMonthCardBtnClick");

    local remainArea = GUI.ImageCreate(normalCard, "remainArea", "1801504130", 65, 125)
    local unitImg = GUI.ImageCreate(remainArea, "unitImg", "1801504140", 105, 2)
    GUI.SetAnchor(unitImg, UIAnchor.Right)
    GUI.SetPivot(unitImg, UIAroundPivot.Left)
    SuperValueUI.SetImmAndRemainNum(remainArea, 30)

    local getNormalMonthCardBtn = GUI.ButtonCreate(remainArea, "getNormalMonthCardBtn", "1800002110", -65, 95, Transition.ColorTint, "领取", 140, 50, false);
    GUI.AddRedPoint(getNormalMonthCardBtn, UIAnchor.TopRight, -5, 5)
    GUI.SetIsOutLine(getNormalMonthCardBtn, true)
    GUI.ButtonSetTextFontSize(getNormalMonthCardBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(getNormalMonthCardBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(getNormalMonthCardBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(getNormalMonthCardBtn, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(getNormalMonthCardBtn, UCE.PointerClick, "SuperValueUI", "OnGetNormalMonthCardBtnClick")

    local superCard = GUI.ImageCreate(bg, "superCard", "1801508140", 205, 1, false, 410, 545)
    UILayout.SetSameAnchorAndPivot(superCard, UILayout.Center)

    SuperValueUI.SetDailyNum(superCard, 260)
    local ingotImg = GUI.ImageCreate(superCard, "ingotImg", "1801504170", 115, -50)

    SuperValueUI.SetTotalNum(superCard, 9080)

    local ingotImg2 = GUI.ImageCreate(superCard, "ingotImg2", "1801504190", 150, 30)

    --至尊卡图标
    local itemIcon = GUI.ItemCtrlCreate(superCard, "itemIcon", UIDefine.ItemIconBg[5], -84, 126, 85, 85)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1800408660")
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1, 80, 70)

    local immArea = GUI.ImageCreate(superCard, "immArea", "1801504330", -75, 195)

    local unitImg = GUI.ImageCreate(immArea, "unitImg", "1801504170", 0, 0)
    GUI.SetAnchor(unitImg, UIAnchor.Right)
    GUI.SetPivot(unitImg, UIAroundPivot.Left)
    SuperValueUI.SetImmAndRemainNum(immArea, 1280)

    local buySuperMonthCardBtn = GUI.ButtonCreate(immArea, "buySuperMonthCardBtn", "1800002110", 75, 40, Transition.ColorTint, "128元", 140, 40, false)
    GUI.SetIsOutLine(buySuperMonthCardBtn, true)
    GUI.ButtonSetTextFontSize(buySuperMonthCardBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(buySuperMonthCardBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(buySuperMonthCardBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(buySuperMonthCardBtn, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(buySuperMonthCardBtn, UCE.PointerClick, "SuperValueUI", "OnBuySuperMonthCardBtnClick")

    local remainArea = GUI.ImageCreate(superCard, "remainArea", "1801504150", 65, 125)
    local unitImg = GUI.ImageCreate(remainArea, "unitImg", "1801504160", 105, 2)
    GUI.SetAnchor(unitImg, UIAnchor.Right)
    GUI.SetPivot(unitImg, UIAroundPivot.Left)
    SuperValueUI.SetImmAndRemainNum(remainArea, 30)

    local getSuperMonthCardBtn = GUI.ButtonCreate(remainArea, "getSuperMonthCardBtn", "1800002110", -65, 95, Transition.ColorTint, "领取", 140, 50, false);
    GUI.AddRedPoint(getSuperMonthCardBtn, UIAnchor.TopRight, -5, 5)
    GUI.SetIsOutLine(getSuperMonthCardBtn, true)
    GUI.ButtonSetTextFontSize(getSuperMonthCardBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(getSuperMonthCardBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(getSuperMonthCardBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(getSuperMonthCardBtn, UIDefine.OutLineDistance)
    GUI.RegisterUIEvent(getSuperMonthCardBtn, UCE.PointerClick, "SuperValueUI", "OnGetSuperMonthCardBtnClick")

    return page
end

function SuperValueUI.OnBuyNormalMonthCardBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType", "MonthCard", 1, RECHARGE_DATA.MonthCard_Config[1].Amount)
end

function SuperValueUI.OnBuySuperMonthCardBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType", "MonthCard", 2, RECHARGE_DATA.MonthCard_Config[2].Amount)
end

function SuperValueUI.OnGetNormalMonthCardBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "MonthCard_Receive", "1");
end

function SuperValueUI.OnGetSuperMonthCardBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "MonthCard_Receive", "2");
end

function SuperValueUI.RefreshTurntable()
    UILayout.OnSubTabClickEx(SuperValueUI.subTabIndex, turnableSubTabList);

    local turntablePage = _gt.GetUI("turntablePage");

    local turntableRemainCount = GUI.GetChild(turntablePage, "turntableRemainCount");
    GUI.StaticSetText(turntableRemainCount, "剩余共享抽奖次数：" .. RECHARGE_DATA.LuckyWheel_Counts)

    local turntable = _gt.GetUI("turntable");

    for i = 1, 8 do
        local turntableItem = GUI.GetChild(turntable, "turntableItem" .. i);
        local data = RECHARGE_DATA.LuckyWheel_Config["WheelList_" .. SuperValueUI.subTabIndex][i];
        local itemDB = DB.GetOnceItemByKey2(data.Item);
        ItemIcon.BindItemDB(turntableItem, itemDB)
        GUI.ItemCtrlSetElementValue(turntableItem, eItemIconElement.RightBottomNum, data.Num)
        if data.Bind == 1 then
            GUI.ItemCtrlSetElementValue(turntableItem, eItemIconElement.LeftTopSp, 1800707120);
            GUI.ItemCtrlSetElementRect(turntableItem, eItemIconElement.LeftTopSp, 0, 0, 44, 45);
        else
            GUI.ItemCtrlSetElementValue(turntableItem, eItemIconElement.LeftTopSp, nil);
        end
    end

    local startTurnBtn = GUI.GetChild(turntable, "startTurnBtn");
    if RECHARGE_DATA.LuckyWheel_Counts > 0 then
        GUI.ButtonSetImageID(startTurnBtn, "1800602280")
    else
        GUI.ButtonSetImageID(startTurnBtn, "1800602283")
    end

    local startTurnText = GUI.GetChild(startTurnBtn, "startTurnText");
    GUI.StaticSetText(startTurnText, "剩余" .. RECHARGE_DATA.LuckyWheel_Counts .. "次")

    local bg = GUI.GetChild(turntablePage, "bg");

    local msg = "#COLORCOLOR805538#每次在#COLORCOLOR0000FF#商城#COLORCOLOR805538#消耗" .. RECHARGE_DATA.LuckyWheel_Config.ConsumeToTimes .. UIDefine.AttrName[RoleAttr.RoleAttrIngot] .. "即可获得一次抽奖机会"
    local ruleDes = GUI.GetChild(bg, "ruleDes");
    GUI.StaticSetText(ruleDes, msg);

    local msg = "再消费" .. (RECHARGE_DATA.LuckyWheel_Config.ConsumeToTimes - RECHARGE_DATA.LuckyWheel_RechargeProgress) .. UIDefine.AttrName[RoleAttr.RoleAttrIngot] .. "即可获得一次抽奖机会";
    local consumeText = GUI.GetChild(bg, "consumeText");
    GUI.StaticSetText(consumeText, msg);

    local timeLimitBg = GUI.GetChild(bg, "timeLimitBg");
    local timeLimitText = GUI.GetChild(timeLimitBg, "timeLimitText");
    GUI.StaticSetText(timeLimitText, RECHARGE_DATA.LuckyWheel_StartTime .. " 至 " .. RECHARGE_DATA.LuckyWheel_EndTime)

    local tenEvenBtn = GUI.GetChild(bg, "timeLimitBg");
    if RECHARGE_DATA.LuckyWheel_TenthMode == 1 then
        GUI.SetVisible(tenEvenBtn, true);
    else
        GUI.SetVisible(tenEvenBtn, false);
    end
end

function SuperValueUI.OnTurntableItemClick(guid)
    local turntableItem = GUI.GetByGuid(guid);
    local index = tonumber(GUI.GetData(turntableItem, "Index"));

    local keyName = RECHARGE_DATA.LuckyWheel_Config["WheelList_" .. SuperValueUI.subTabIndex][index].Item;
    local turntablePage = _gt.GetUI("turntablePage");
    Tips.CreateByItemKeyName(keyName, turntablePage, "itemTips", 280, 60);
end

function SuperValueUI.CreateTurntable(panelBg)
    local page = GUI.GroupCreate(panelBg, "turntablePage", 110, 65, 820, 550)
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top);
    _gt.BindName(page, "turntablePage");
    UILayout.CreateSubTab(turnableSubTabList, page, "SuperValueUI");

    local turntableRemainCount = GUI.CreateStatic(page, "turntableRemainCount", "剩余共享抽奖次数：0", -20, 15, 500, 35);
    GUI.SetColor(turntableRemainCount, UIDefine.BrownColor);
    GUI.StaticSetFontSize(turntableRemainCount, UIDefine.FontSizeM);
    UILayout.SetSameAnchorAndPivot(turntableRemainCount, UILayout.TopRight);
    GUI.StaticSetAlignment(turntableRemainCount, TextAnchor.MiddleRight);

    local bg = GUI.ImageCreate(page, "bg", "1800400200", 0, 25, false, 830, 500)
    UILayout.SetSameAnchorAndPivot(bg, UILayout.Center);

    local turntable = GUI.ImageCreate(bg, "turntable", "1800601080", -155, 0);
    _gt.BindName(turntable, "turntable");
    local shor = -67.5
    local radi = 150

    for i = 1, 8 do
        local hor = shor + (i - 1) * 45
        local x = radi * GlobalUtils.GetPreciseDecimal(math.cos(math.rad(hor)), 2)
        local y = radi * GlobalUtils.GetPreciseDecimal(math.sin(math.rad(hor)), 2)

        local turntableItem = ItemIcon.Create(turntable, "turntableItem" .. i, x, y)
        GUI.SetData(turntableItem, "Index", i);
        GUI.RegisterUIEvent(turntableItem, UCE.PointerClick, "SuperValueUI", "OnTurntableItemClick");
    end

    local turntablePointer = GUI.GroupCreate(turntable, "turntablePointer", 0, 0, 0, 0)
    GUI.RegisterUIEvent(turntablePointer, ULE.TweenCallBack, "SuperValueUI", "TurntablePointerDoTweenCallback");
    UILayout.SetAnchorAndPivot(turntablePointer, UIAnchor.Center, UIAroundPivot.Bottom)
    local finger = GUI.ImageCreate(turntablePointer, "finger", "1800601090", 0, 50);
    --GUI.SetEulerAngles(pointer, Vector3.New(0, 0, -22.5));
    _gt.BindName(turntablePointer, "turntablePointer")

    local startTurnBtn = GUI.ButtonCreate(turntable, "startTurnBtn", "1800602280", 3, 0, Transition.ColorTint, "");
    GUI.RegisterUIEvent(startTurnBtn, UCE.PointerClick, "SuperValueUI", "OnStartTurnBtnClick");
    local startTurnText = GUI.CreateStatic(startTurnBtn, "startTurnText", "剩余0次", 0, 28, 200, 35);
    GUI.SetColor(startTurnText, UIDefine.WhiteColor);
    GUI.StaticSetFontSize(startTurnText, UIDefine.FontSizeM);
    UILayout.SetSameAnchorAndPivot(startTurnText, UILayout.Center);
    GUI.StaticSetAlignment(startTurnText, TextAnchor.MiddleCenter);
    GUI.SetIsOutLine(startTurnText, true);
    GUI.SetOutLine_Color(startTurnText, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(startTurnText, UIDefine.OutLineDistance);

    local pic = GUI.ImageCreate(bg, "pic", "1800604520", 240, -135);

    local tenEvenBtn = GUI.CheckBoxExCreate(bg, "tenEvenBtn", "1800007011", "1800007010", 20, -220, false, 45, 45)
    _gt.BindName(tenEvenBtn, "tenEvenBtn")
    GUI.RegisterUIEvent(tenEvenBtn, UCE.PointerClick, "SuperValueUI", "OnTenEvenBtnClick");

    local des = GUI.CreateStatic(tenEvenBtn, "des", "开启十连抽模式", 45, 1, 200, 35);
    GUI.SetColor(des, UIDefine.BrownColor);
    GUI.StaticSetFontSize(des, UIDefine.FontSizeM);
    UILayout.SetSameAnchorAndPivot(des, UILayout.Left);
    GUI.StaticSetAlignment(des, TextAnchor.MiddleLeft);

    local ruleDes = GUI.RichEditCreate(bg, "ruleDes", "", 240, -20, 268, 80);
    GUI.SetColor(ruleDes, UIDefine.BrownColor);
    GUI.StaticSetFontSize(ruleDes, UIDefine.FontSizeM);
    UILayout.SetSameAnchorAndPivot(ruleDes, UILayout.Center);
    GUI.StaticSetAlignment(ruleDes, TextAnchor.UpperCenter);

    local msg = "所有抽奖#COLORCOLOR0000FF#共享抽奖次数"
    local countDes = GUI.RichEditCreate(bg, "countDes", msg, 240, 40, 250, 35);
    GUI.SetColor(countDes, UIDefine.BrownColor);
    GUI.StaticSetFontSize(countDes, UIDefine.FontSizeM);
    UILayout.SetSameAnchorAndPivot(countDes, UILayout.Center);
    GUI.StaticSetAlignment(countDes, TextAnchor.MiddleCenter);

    local consumeBtn = GUI.ButtonCreate(bg, "consumeBtn", "1800402080", 210, 120, Transition.ColorTint, "消费", 110, 47, false);
    GUI.SetIsOutLine(consumeBtn, true);
    GUI.ButtonSetTextFontSize(consumeBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(consumeBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(consumeBtn, UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(consumeBtn, UIDefine.OutLineDistance);
    GUI.RegisterUIEvent(consumeBtn, UCE.PointerClick, "SuperValueUI", "OnConsumeBtnClick");

    local consumeText = GUI.CreateStatic(bg, "consumeText", msg, 210, 180, 232, 70);
    GUI.SetColor(consumeText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(consumeText, UIDefine.FontSizeM);
    UILayout.SetSameAnchorAndPivot(consumeText, UILayout.Center);
    GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleCenter);

    local timeLimitBg = GUI.ImageCreate(bg, "timeLimitBg", "1800601070", 180, -1, false, 460, 35);
    UILayout.SetSameAnchorAndPivot(timeLimitBg, UILayout.Bottom);

    local timeLimitText = GUI.CreateStatic(timeLimitBg, "timeLimitText", "2020.1.1  至  2020.1.1", 0, -2, 460, 35);
    GUI.SetColor(timeLimitText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(timeLimitText, UIDefine.FontSizeS);
    UILayout.SetSameAnchorAndPivot(consumeText, UILayout.Center);
    GUI.StaticSetAlignment(timeLimitText, TextAnchor.MiddleCenter);

    local wnd = GUI.GetWnd("SuperValueUI")
    local turntableCover = GUI.ImageCreate(page, "turntableCover", "1800400220", -110, -43, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd));
    UILayout.SetSameAnchorAndPivot(turntableCover, UILayout.Center);
    GUI.SetColor(turntableCover, UIDefine.Transparent)
    _gt.BindName(turntableCover, "turntableCover")
    GUI.SetIsRaycastTarget(turntableCover, true);
    GUI.SetVisible(turntableCover, false);
    return page;
end

function SuperValueUI.OnConsumeBtnClick()
    SuperValueUI.OnExit();
    --GetWay.Def[1].jump("MallUI",1,1)
    GUI.OpenWnd("MallUI")
end

function SuperValueUI.StartTurnWheel(index)
    local turntablePointer = _gt.GetUI("turntablePointer");
    local src = GUI.GetEulerAngles(turntablePointer)

    local tag = -(22.5 + (index - 1) * 45);
    SuperValueUI.turntableTargetAngle = tag;
    local data = TweenData.New();
    data.Type = GUITweenType.DOLocalRotate;
    data.Duration = 2.5;
    data.From = src;
    data.To = Vector3.New(0, 0, tag - 2 * 720)
    data.LoopType = UITweenerStyle.Once;
    GUI.DOTween(turntablePointer, data);

    local turntableCover = _gt.GetUI("turntableCover");
    GUI.SetVisible(turntableCover, true);
end

function SuperValueUI.TurntablePointerDoTweenCallback(guid, key)
    local turntablePointer = GUI.GetByGuid(guid);
    GUI.SetEulerAngles(turntablePointer, Vector3.New(0, 0, SuperValueUI.turntableTargetAngle))

    local turntableCover = _gt.GetUI("turntableCover");
    GUI.SetVisible(turntableCover, false);

    if SuperValueUI.isTenEven then

        GUI.OpenWnd("GetRewardUI");

        local itemDataList = {};
        for i = 1, #SuperValueUI.tenRewardInfo - 1 do
            local index = tonumber(SuperValueUI.tenRewardInfo[i])
            if index ~= nil then
                local keyName = RECHARGE_DATA.LuckyWheel_Config["WheelList_" .. SuperValueUI.subTabIndex][index].Item;
                local num = RECHARGE_DATA.LuckyWheel_Config["WheelList_" .. SuperValueUI.subTabIndex][index].Num;
                table.insert(itemDataList, { KeyName = keyName, Num = num });
            end
        end
        GetRewardUI.ShowItem(itemDataList, function()
            CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "LuckyWheel_Receive_Tenth");
        end)
        GetRewardUI.SetLeftBtn("再来十次", SuperValueUI.OnStartTurnBtnClick)
        GetRewardUI.SetRightBtn("知道了", nil)
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "LuckyWheel_Receive");
    end
end

function SuperValueUI.GetTenRewardInfo(str)

    SuperValueUI.tenRewardInfo = string.split(str, ",")
    SuperValueUI.StartTurnWheel(tonumber(SuperValueUI.tenRewardInfo[10]))
end

function SuperValueUI.OnStartTurnBtnClick()
    if RECHARGE_DATA.LuckyWheel_Counts < 1 then
        return ;
    end

    if SuperValueUI.isTenEven then
        if RECHARGE_DATA.LuckyWheel_Counts < 10 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "你的次数不足，无法使用十连抽");
            return ;
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "LuckyWheel_Start_Tenth", "WheelList_" .. SuperValueUI.subTabIndex);
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "LuckyWheel_Start", "WheelList_" .. SuperValueUI.subTabIndex);
    end
end

function SuperValueUI.OnTenEvenBtnClick(guid)
    local tenEvenBtn = GUI.GetByGuid(guid)
    if SuperValueUI.isTenEven then
        GUI.CheckBoxExSetCheck(tenEvenBtn, false);
        SuperValueUI.isTenEven = false;
    else
        if RECHARGE_DATA.LuckyWheel_Counts < 10 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "你的次数不足，无法使用十连抽");
            GUI.CheckBoxExSetCheck(tenEvenBtn, false);
        else
            GUI.CheckBoxExSetCheck(tenEvenBtn, true);
            SuperValueUI.isTenEven = true;
        end
    end
end

function SuperValueUI.CreateTypeItem()
    local typeScroll = GUI.GetByGuid(_gt.typeScroll);
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(typeScroll);
    local typeItem = GUI.CheckBoxExCreate(typeScroll, "typeItem" .. curCount, "1800002030", "1800002031", 0, 0, false)
    GUI.RegisterUIEvent(typeItem, UCE.PointerClick, "SuperValueUI", "OnTypeItemClick");

    local nameText = GUI.CreateStatic(typeItem, "nameText", "", 0, 1, 200, 50);
    GUI.SetColor(nameText, UIDefine.BrownColor);
    GUI.StaticSetFontSize(nameText, UIDefine.FontSizeXL);
    UILayout.SetSameAnchorAndPivot(nameText, UILayout.Center);
    GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter);
    return typeItem
end

function SuperValueUI.OnTypeItemClick(guid)
    test("左边列表选择框点击事件")
    local typeItem = GUI.GetByGuid(guid);
    local index = GUI.CheckBoxExGetIndex(typeItem);
    index = index + 1;
    SuperValueUI.SetTypeIndex(index)
end

function SuperValueUI.RefreshTypeScroll(parameter)
    parameter = string.split(parameter, "#");
    local guid = parameter[1];
    local index = tonumber(parameter[2]);
    local typeItem = GUI.GetByGuid(guid);
    index = index + 1;

    GUI.CheckBoxExSetCheck(typeItem, SuperValueUI.typeIndex == index);
    local typeData = SuperValueUI.typeDataList[index]
    local nameText = GUI.GetChild(typeItem, "nameText");
    GUI.StaticSetText(nameText, typeData.Name)

    local typeFlag = SuperValueUI.TypeIndexTable[typeData.Name]
    if typeFlag then
        if GlobalProcessing then
            local RedPoint = GlobalProcessing.RechargeSV_DataLoading(typeFlag)
            if RedPoint == 1 then
                GlobalProcessing.SetRetPoint(typeItem, true)
            else
                GlobalProcessing.SetRetPoint(typeItem, false)
            end
        end
    end
end

----------------------------------------------start 超值1元购 start-------------------------------------
function SuperValueUI.CreateDailyLimitPurchase(panelBg)
    local data = RECHARGE_DATA.BuyOfDay_Config
    local index = RECHARGE_DATA.BuyOfDay_TodayIndex

    local page = GUI.GroupCreate(panelBg, "DailyLimitPurchasePage", 110, 65, 820, 550)
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top);
    _gt.BindName(page, "DailyLimitPurchase")
    local _DailyPurchaseBG = GUI.ImageCreate(page, "DailyPurchaseBG", "1800608630", 0, 0, false, 820, 550)
    _gt.BindName(_DailyPurchaseBG, "DailyLimitPurchase")
    SetAnchorAndPivot(_DailyPurchaseBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PurchaseBg = GUI.ImageCreate(_DailyPurchaseBG, "PurchaseBg", "1800604540", 300, 70, true, 0, 0)
    SetAnchorAndPivot(_PurchaseBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _HintBg = GUI.ImageCreate(_DailyPurchaseBG, "HintBg", "1800608680", 9, -12, false, 500, 500)
    SetAnchorAndPivot(_HintBg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    local itemName = {}
    local itemNum = {}
    for k, v in ipairs(data['Goods'][index].ItemList) do
        if type(v) == "string" then
            table.insert(itemName, v)
            if type(data['Goods'][index].ItemList[k + 1]) == "number" then
                table.insert(itemNum, data['Goods'][index].ItemList[k + 1])
            end
        end
    end
    if data['Goods'][index].MoneyList then
        for k, v in ipairs(data['Goods'][index].MoneyList) do
            if k % 2 == 1 then
                table.insert(itemName, v)
                if type(data['Goods'][index].MoneyList[k + 1]) then
                    table.insert(itemNum, data['Goods'][index].MoneyList[k + 1])
                end
            end
        end
    end
    for i = 1, #itemName do
        local _RewardIcon = GUI.ItemCtrlCreate(_DailyPurchaseBG, "RewardIcon" .. i, "1800400100", (i - 1) * 100 + (200 - #itemName * 50) + 395, 240, 86, 86, false)
        SetAnchorAndPivot(_RewardIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.RegisterUIEvent(_RewardIcon, UCE.PointerClick, "SuperValueUI", "purchase_on_itemIcon_click")
        if type(itemName[i]) == "string" then
			GUI.SetData(_RewardIcon, "itemKey", itemName[i])
			if string.find(itemName[i], "#") then					
				itemName[i] = string.split(itemName[i], "#")[1]
			end
		end
		local item = DB.GetOnceItemByKey2(itemName[i])
        if item then
            local grade = QualityRes[item.Grade]
            GUI.ItemCtrlSetElementValue(_RewardIcon, eItemIconElement.Border, grade)
            GUI.SetData(_RewardIcon, "type", "item")
            GUI.SetData(_RewardIcon, "item", item.Id)
            GUI.ItemCtrlSetElementValue(_RewardIcon, eItemIconElement.Icon, item.Icon)
            GUI.ItemCtrlSetElementValue(_RewardIcon, eItemIconElement.RightBottomNum, itemNum[i])
            GUI.ItemCtrlSetIconGray(_RewardIcon, false)
            local _item_RightBottom = GUI.ItemCtrlGetElement(_RewardIcon, eItemIconElement.RightBottomNum)
            if _item_RightBottom then
                GUI.SetPositionX(_item_RightBottom, 7)
                GUI.SetPositionY(_item_RightBottom, 5)
                GUI.StaticSetFontSize(_item_RightBottom, 20)
                GUI.SetIsOutLine(_item_RightBottom, true)
                GUI.SetOutLine_Color(_item_RightBottom, Color.New(0 / 255, 0 / 255, 0 / 255, 255 / 255))
                GUI.SetOutLine_Distance(_item_RightBottom, 1)
                GUI.SetColor(_item_RightBottom, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
            end
        end
    end
    local _PurchaseBtn = GUI.ButtonCreate(_DailyPurchaseBG, "PurchaseBtn", "1800602130", 510, 400, Transition.ColorTint, "", 160, 50, false)
    SetAnchorAndPivot(_PurchaseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.AddRedPoint(_PurchaseBtn, UIAnchor.TopRight, -5, 5)
    GUI.SetIsOutLine(_PurchaseBtn, true)
    GUI.SetOutLine_Distance(_PurchaseBtn, 1)
    GUI.SetOutLine_Color(_PurchaseBtn, UIDefine.OutLine_BrownColor)
    GUI.RegisterUIEvent(_PurchaseBtn, UCE.PointerClick, "SuperValueUI", "on_purchase_submit")
    GUI.ButtonSetTextFontSize(_PurchaseBtn, 32);
    return page
end

function SuperValueUI.RefreshDailyLimitPurchase()
    local _DailyPurchaseBG = _gt.GetUI("DailyLimitPurchase")
    local btn = GUI.GetChild(_DailyPurchaseBG, "PurchaseBtn")
    local state = RECHARGE_DATA.BuyOfDay_State or 1
    if state == 1 then
        GUI.ButtonSetText(btn, "领 取")
        GUI.ButtonSetTextFontSize(btn, 24)
    elseif state == 0 then
        GUI.ButtonSetText(btn, "￥ 1")
        GUI.ButtonSetShowDisable(btn, true)
    elseif state == 2 then
        GUI.ButtonSetText(btn, "已领取")
        GUI.ButtonSetTextFontSize(btn, 24);
        GUI.ButtonSetShowDisable(btn, false)
        GUI.ButtonSetTextColor(btn, Color.New(192 / 255, 192 / 255, 192 / 255))
    end
    GUI.SetRedPointVisable(btn, state == 1)
end

function SuperValueUI.purchase_on_itemIcon_click(guid)
    local panelBg = _gt.GetUI("panelBg")
    local item_bg = GUI.GetByGuid(guid)
    local itemId = GUI.GetData(item_bg,"item")
    local types = GUI.GetData(item_bg, "type")
    if types == "item" then
        local item = GUI.GetData(item_bg, "itemKey")
        if item then
            --超值一元购Tips
            local tips = Tips.CreateByItemId(itemId,panelBg,"itemTips",-92,0)
        end
    elseif types == "pet" then
        CL.SendNotify(NOTIFY.SubmitForm, "FriendInviteSystem", "InquirePetData_Invitation", GUI.GetData(item_bg, "info"));
    end
end

function SuperValueUI.on_purchase_submit(guid)
    local state = RECHARGE_DATA.BuyOfDay_State or 1
    if state == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "BuyOfDay_Receive", "Receive")
    elseif state == 0 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "BuyOfDay_Receive", "Buy")
    end
end
----------------------------------------------end 超值1元购 end-------------------------------------

----------------------------------------------start 等级基金 start-------------------------------------
function SuperValueUI.CreateLevelFundPage(panelBg)
    local data = RECHARGE_DATA.LevelFund_Config

    local page = GUI.GroupCreate(panelBg, "LevelFundPage", 110, 65, 820, 550)
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top);
    _gt.BindName(page, "LevelFundPage")

    local AdvImage = GUI.ImageCreate(page, "AdvImage", "1800601060", 0, 0, false, 830, 126)
    SetAnchorAndPivot(AdvImage, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetData(AdvImage, "status", 0)
    local temp = GUI.ImageCreate(AdvImage, "temp1", "1800608700", 0, 0, true, 830, 126)
    SetAnchorAndPivot(temp, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    temp = GUI.ImageCreate(AdvImage, "temp2", "1800608710", 0, 0, true, 830, 126)
    SetAnchorAndPivot(temp, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local AdvTextImage = GUI.ImageCreate(AdvImage, "AdvTextImage", "1800604550", 0, -5, true, 0, 0)
    SetAnchorAndPivot(AdvTextImage, UIAnchor.Center, UIAroundPivot.Center)

    local GetBtn = GUI.ButtonCreate(AdvImage, "GetBtn", "1800602020", -20, 0, Transition.ColorTint, "", 120, 45, false);
    SetAnchorAndPivot(GetBtn, UIAnchor.Right, UIAroundPivot.Right)
    GUI.RegisterUIEvent(GetBtn, UCE.PointerClick, "SuperValueUI", "OnBuyLevelGoldBtnClick")

    local BtnText = GUI.CreateStatic(GetBtn, "BtnText", "￥" .. data["RMB_Val"], -30, -1, 100, 50, "system", true, false);
    GUI.StaticSetFontSize(BtnText, 24)
    GUI.SetColor(BtnText, Color.New(128 / 255, 85 / 255, 56 / 255));
    SetAnchorAndPivot(BtnText, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(BtnText, TextAnchor.MiddleLeft)

    local GoldIcon = GUI.ImageCreate(GetBtn, "GoldIcon", UIDefine.GetMoneyIcon(1), 0, 0, true);
    SetAnchorAndPivot(GoldIcon, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetVisible(GoldIcon, false)

    local OverImage = GUI.ImageCreate(AdvImage, "OverImage", "1800604560", -20, 0, true, 150, 63);
    SetAnchorAndPivot(OverImage, UIAnchor.Right, UIAroundPivot.Right)
    GUI.SetVisible(OverImage, false)

    local TextBg = GUI.ImageCreate(AdvImage, "TextBg", "1800601070", 0, 1, false, 600, 32);
    SetAnchorAndPivot(TextBg, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local titleTxt = GUI.CreateStatic(TextBg, "titleTxt", "", 0, 0, 580, 35, "system", true, false);
    GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(titleTxt, 20)
    GUI.SetColor(titleTxt, Color.New(128 / 255, 85 / 255, 56 / 255));
    SetAnchorAndPivot(titleTxt, UIAnchor.Center, UIAroundPivot.Center)
    if not data or not data["Desc"] then
        GUI.StaticSetText(titleTxt, "充值" .. data["RMB_Val"] .. "元，即可花费" .. UIDefine.AttrName[UIDefine.GetMoneyEnum(1)] .. "购买等级基金，3倍返还。")
    else
        GUI.StaticSetText(titleTxt, data["Desc"])
    end

    local RewardBG = GUI.ImageCreate(AdvImage, "RewardBG", "1800400010", -3, 137, false, 837, 407)
    SetAnchorAndPivot(RewardBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local RollVecSize = Vector2.New(162, 192)
    local Roll = GUI.ScrollRectCreate(RewardBG, "Roll", 9, 10, 832, 385, 0, false, RollVecSize, UIAroundPivot.TopLeft, UIAnchor.TopLeft, 5);
    GUI.ScrollRectSetChildSpacing(Roll, Vector2.New(2, 3));

    local count = data and data["Reward"] and #data["Reward"] or 10
    for i = 1, count do
        local bg = GUI.ImageCreate(Roll, "bg" .. i, "1800601100", 0, 0, false, 0, 0)
        SetAnchorAndPivot(bg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetData(bg, "key", i)
        GUI.SetIsRaycastTarget(bg, true)

        local titleTxt = ""
        titleTxt = GUI.CreateStatic(bg, "titleTxt", data["Reward"][i].Level .. "级", 0, 10, 100, 30, "system", true, false);

        GUI.StaticSetFontSize(titleTxt, 22)
        GUI.SetColor(titleTxt, Color.New(255 / 255, 244 / 255, 125 / 255));
        SetAnchorAndPivot(titleTxt, UIAnchor.Top, UIAroundPivot.Top)
        GUI.StaticSetAlignment(titleTxt,TextAnchor.MiddleCenter)
        GUI.SetIsOutLine(titleTxt, true)
        GUI.SetOutLine_Color(titleTxt, Color.New(176 / 255, 37 / 255, 8 / 255))
        GUI.SetOutLine_Distance(titleTxt, 1)

        local RewardIcon = ""
        RewardIcon = GUI.ImageCreate(bg, "RewardIcon", tostring(data["Reward"][i].Icon), 0, 0, false, 158, 128);

        SetAnchorAndPivot(RewardIcon, UIAnchor.Center, UIAroundPivot.Center)

        local PriceBg = GUI.ImageCreate(bg, "PriceBg", "1800600040", 0, -5, false, 140, 30);
        SetAnchorAndPivot(PriceBg, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.SetVisible(PriceBg, true)

        local label = ""
        label = GUI.CreateStatic(PriceBg, "label", data["Reward"][i].Reward_Money, 15, 0, 100, 30, "system", true, false);

        GUI.StaticSetFontSize(label, 24)
        GUI.SetColor(label, Color.New(128 / 255, 85 / 255, 56 / 255))
        SetAnchorAndPivot(label, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter)
		
		local gold_type = data["Reward"][i].Reward_Type or 1
        local GoldIcon = GUI.ImageCreate(PriceBg, "GoldIcon", UIDefine.GetMoneyIcon(gold_type), 0, 0, true);
        SetAnchorAndPivot(GoldIcon, UIAnchor.Left, UIAroundPivot.Left)

        local OverImage = GUI.ImageCreate(bg, "OverImage", "1800604390", 0, -5, true, 140, 30);
        SetAnchorAndPivot(OverImage, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.SetVisible(OverImage, false)

        local GetBtn = GUI.ButtonCreate(bg, "GetBtn", "1800002110", 0, 30, Transition.ColorTint, "领 取", 95, 40, false);
        SetAnchorAndPivot(GetBtn, UIAnchor.Center, UIAroundPivot.Center)
        GUI.AddRedPoint(GetBtn, UIAnchor.TopRight, -5, 5)
        GUI.RegisterUIEvent(GetBtn, UCE.PointerClick, "SuperValueUI", "OnLevelGoldGetBtnClick")

        GUI.ButtonSetTextColor(GetBtn, UIDefine.WhiteColor)
        GUI.ButtonSetTextFontSize(GetBtn, 24);
        GUI.SetVisible(GetBtn, false)
        GUI.SetIsOutLine(GetBtn, true)
        GUI.SetOutLine_Color(GetBtn, Color.New(175 / 255, 96 / 255, 19 / 255, 255 / 255))
        GUI.SetOutLine_Distance(GetBtn, 1)
    end

    return page
end

function SuperValueUI.RefreshLevelFundPage()
    local data = RECHARGE_DATA.LevelFund_Config
    local status_list = RECHARGE_DATA
    local page = _gt.GetUI("LevelFundPage")
    local AdvImage = GUI.GetChild(page, "AdvImage")
    local rewards = data and data.Reward
    if not rewards then
        return
    end
    local status = status_list["LevelFund_TotalState"]
    local btn = GUI.GetChild(AdvImage, "GetBtn")
    local btntext = GUI.GetChild(btn, "BtnText")
    local image = GUI.GetChild(AdvImage, "OverImage")
    local icon = GUI.GetChild(btn, "GoldIcon")
    if status == 1 then
        GUI.SetVisible(btn, true)
        GUI.SetVisible(image, false)
        GUI.StaticSetText(btntext, data["MoneyVal"])
        GUI.StaticSetAlignment(btntext, TextAnchor.MiddleLeft)
        GUI.SetPositionX(btntext, 30)
        GUI.SetVisible(icon, true)
    elseif status == 2 then
        GUI.SetVisible(btn, false)
        GUI.SetVisible(image, true)
    else
        GUI.SetVisible(btn, true)
        GUI.SetVisible(image, false)
        GUI.StaticSetText(btntext, "￥" .. data["RMB_Val"])
        GUI.StaticSetAlignment(btntext, TextAnchor.MiddleCenter)
        GUI.SetPositionX(btntext, 0)
        GUI.SetVisible(icon, false)
    end
    GUI.SetRedPointVisable(btn, status == 1)
    for i = 1, #rewards do
        local obj = GUI.GetChildByPath(AdvImage, "RewardBG/Roll/bg" .. i)
        local status = status_list["LevelFund_EveryState_" .. i]
        local price = GUI.GetChild(obj, "PriceBg")
        local image = GUI.GetChild(obj, "OverImage")
        local btn = GUI.GetChild(obj, "GetBtn")
        if status == 2 then
            GUI.SetVisible(price, false)
            GUI.SetVisible(image, true)
            GUI.SetVisible(btn, false)
        elseif status == 1 then
            GUI.SetVisible(price, true)
            GUI.SetVisible(image, false)
            GUI.SetVisible(btn, true)
        else
            GUI.SetVisible(price, true)
            GUI.SetVisible(image, false)
            GUI.SetVisible(btn, false)
        end
    end
end

function SuperValueUI.OnBuyLevelGoldBtnClick(guid)
    local status = RECHARGE_DATA["LevelFund_TotalState"]
    if status == 0 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType", "LevelFund", 0, RECHARGE_DATA.LevelFund_Config["RMB_Val"])
    elseif status == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "LevelFund_Receive", "0")
    end
end

function SuperValueUI.OnLevelGoldGetBtnClick(guid)
    if RECHARGE_DATA["LevelFund_TotalState"] == 2 then
        local btn = GUI.GetByGuid(guid)
        local bg = GUI.GetParentElement(btn)
        local index = tonumber(GUI.GetData(bg, "key"))
        local roleLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
        if RECHARGE_DATA["LevelFund_Config"]["Reward"][index].Level <= roleLevel then
            CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "LevelFund_Receive", tostring(index))
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "等级不足")
        end
    end
end
----------------------------------------------end 等级基金 end-------------------------------------

----------------------------------------------start 每日消费送礼 start-------------------------------------
local codeColor = Color.New(128 / 255, 85 / 255, 56 / 255, 255 / 255)
function SuperValueUI.CreateDailyConsumeReward(panelBg)
    local data = RECHARGE_DATA.ConsumIngotOfDay_Config
    local num = RECHARGE_DATA.ConsumIngotOfDay_Value

    local page = GUI.GroupCreate(panelBg, "DailyConsumeRewardPage", 110, 65, 820, 550)
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top);
    _gt.BindName(page, "DailyConsumeReward")

    local _AccumulativeConsumptionPIC = GUI.ImageCreate(page, "AccumulativeConsumptionPIC", "1800608590", 0, 0, false, 830, 126)
    SetAnchorAndPivot(_AccumulativeConsumptionPIC, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _RemainTimeBg = GUI.ImageCreate(_AccumulativeConsumptionPIC, "RemainTimeBg", "1800601070", 0, 49, false, 540, 32)
    SetAnchorAndPivot(_RemainTimeBg, UIAnchor.Center, UIAroundPivot.Center)

    local _RemainTimeTxt = GUI.CreateStatic(_RemainTimeBg, "RemainTimeTxt", "", 70, 0, 540, 32, "system", true, false)
    GUI.StaticSetFontSize(_RemainTimeTxt, 20)
    GUI.SetColor(_RemainTimeTxt, codeColor)
    SetAnchorAndPivot(_RemainTimeTxt, UIAnchor.Center, UIAroundPivot.Center)

    local _RewardBG = GUI.ImageCreate(page, "RewardBG", "1800400010", -3, 137, false, 838, 415)
    SetAnchorAndPivot(_RewardBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --创建滚轴
    local _RewardVecSize = Vector2.New(810, 128)
    local _RewardRoller = GUI.ScrollRectCreate(_RewardBG, "RewardRoller", 0, 0, 810, 383, 0, false, _RewardVecSize, UIAroundPivot.Top, UIAnchor.Top);
    SetAnchorAndPivot(_RewardRoller, UIAnchor.Center, UIAroundPivot.Center)
    GUI.ScrollRectSetChildSpacing(_RewardRoller, Vector2.New(0, 8));

    local count = data and #data or 10
    for i = 1, count do
        local rewardBG = GUI.ImageCreate(_RewardRoller, "RewardTabBG" .. i, "1801100010", 0, 0, false, 0, 0)
        SetAnchorAndPivot(rewardBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        local _DailyOnLineKeyName = GUI.CreateStatic(rewardBG, "DailyOnLineKeyName" .. i, "累计消费元宝", 42, 33, 240, 60, "system", true, false);
        GUI.StaticSetFontSize(_DailyOnLineKeyName, 22)
        GUI.StaticSetAlignment(_DailyOnLineKeyName, TextAnchor.UpperLeft)
        SetAnchorAndPivot(_DailyOnLineKeyName, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        local sureColor = Color.New(80 / 255, 27 / 255, 3 / 255, 255 / 255)
        GUI.SetColor(_DailyOnLineKeyName, sureColor);

        local _DailyOnLineNumbg = GUI.ImageCreate(rewardBG, "DailyOnLineNumbg" .. i, "1800600500", 20, 65, false, 170, 30)
        SetAnchorAndPivot(_DailyOnLineNumbg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local _DailyOnLineNum = GUI.CreateStatic(_DailyOnLineNumbg, "DailyOnLineNum" .. i, "(" .. num .. "/" .. data[i].Target .. ")", 0, 0, 170, 30, "system", true, false);
        GUI.StaticSetFontSize(_DailyOnLineNum, 22)
        GUI.StaticSetAlignment(_DailyOnLineNum, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(_DailyOnLineNum, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetColor(_DailyOnLineNum, sureColor);
        local itemName = {}
        local itemNum = {}
        local petID = {}
        for k, v in ipairs(data[i].ItemList) do
            if type(v) == "string" then
                table.insert(itemName, v)
                if type(data[i].ItemList[k + 1]) == "number" then
                    table.insert(itemNum, data[i].ItemList[k + 1])
                end
            end
        end
        if data[i].PetList then
            for k, v in ipairs(data[i].PetList) do
                if type(v) == "string" then
                    table.insert(petID, v)
                end
            end
        end
        for j = 1, 5 do
            local _RewardIcon = GUI.ItemCtrlCreate(rewardBG, "GiftItemBg" .. j, "1800600050", 203 + (j - 1) * (86 + 3), 22, 86, 86, false)
            SetAnchorAndPivot(_RewardIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.RegisterUIEvent(_RewardIcon, UCE.PointerClick, "SuperValueUI", "on_gift_itemicon_click")

            if itemName[j] ~= nil then
				if type(itemName[j]) == "string" then
					GUI.SetData(_RewardIcon, "itemKey", itemName[j])
					if string.find(itemName[j], "#") then					
						itemName[j] = string.split(itemName[j], "#")[1]
					end
				end
                local item = DB.GetOnceItemByKey2(itemName[j])
                if item then
                    local grade = QualityRes[item.Grade]
                    GUI.ItemCtrlSetElementValue(_RewardIcon, eItemIconElement.Border, grade)
                    GUI.SetData(_RewardIcon, "type", "item")
                    GUI.SetData(_RewardIcon, "item", item.Id)
                    GUI.ItemCtrlSetElementValue(_RewardIcon, eItemIconElement.Icon, item.Icon)
                    GUI.ItemCtrlSetElementValue(_RewardIcon, eItemIconElement.RightBottomNum, itemNum[j])
                    GUI.ItemCtrlSetIconGray(_RewardIcon, false)
                    local _item_RightBottom = GUI.ItemCtrlGetElement(_RewardIcon, eItemIconElement.RightBottomNum)
                    if _item_RightBottom then
                        GUI.SetPositionX(_item_RightBottom, 7)
                        GUI.SetPositionY(_item_RightBottom, 5)
                        GUI.StaticSetFontSize(_item_RightBottom, 20)
                        GUI.SetIsOutLine(_item_RightBottom, true)
                        GUI.SetOutLine_Color(_item_RightBottom, Color.New(0 / 255, 0 / 255, 0 / 255, 255 / 255))
                        GUI.SetOutLine_Distance(_item_RightBottom, 1)
                        GUI.SetColor(_item_RightBottom, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
                    end
                end
            elseif petID[j - #itemName] ~= nil then
                local pet = DB.GetOncePetByKey2(petID[j - #itemName])
                if pet then
                    local grade = tonumber(pet.Type)
                    if grade then
                        GUI.ItemCtrlSetElementValue(_RewardIcon, eItemIconElement.Border, QualityRes[grade])
                    end
                    GUI.ItemCtrlSetElementValue(_RewardIcon, eItemIconElement.Icon, tostring(pet.Head))
                    GUI.ItemCtrlSetIconGray(_RewardIcon, false)

                    GUI.SetData(_RewardIcon, "type", "pet")
                    GUI.SetData(_RewardIcon, "info", petID[j - #itemName])
                end
            end
        end
        local _OnLineBtn = GUI.ButtonCreate(rewardBG, "OnLineBtn", "1800002110", 670, 42, Transition.ColorTint, "", 120, 45, false);
        SetAnchorAndPivot(_OnLineBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.AddRedPoint(_OnLineBtn, UIAnchor.TopRight, -5, 5)
        GUI.SetIsOutLine(_OnLineBtn, true)
        GUI.SetOutLine_Distance(_OnLineBtn, 1)
        GUI.SetOutLine_Color(_OnLineBtn, Color.New(133 / 255, 83 / 255, 61 / 255, 255 / 255))
        GUI.ButtonSetTextFontSize(_OnLineBtn, 22);
        GUI.RegisterUIEvent(_OnLineBtn, UCE.PointerClick, "SuperValueUI", "OnClickDailyConsumption")

        local _OnLineImg = GUI.ImageCreate(rewardBG, "OnLineImg", "1800604390", 670, 32, false, 0, 0)
        SetAnchorAndPivot(_OnLineImg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    end

    return page
end

function SuperValueUI.RefreshDailyConsumeReward()
    local data = RECHARGE_DATA.ConsumIngotOfDay_Config
    local num = RECHARGE_DATA.ConsumIngotOfDay_Value
    local StartTime = RECHARGE_DATA.ConsumIngotOfDay_StartTime or "2020-11-01 00:00:00"
    local EndTime = RECHARGE_DATA.ConsumIngotOfDay_EndTime or "2022-01-31 23:59:59"
    local page = _gt.GetUI("DailyConsumeReward")
    local titleTxt = GUI.GetChildByPath(page, "AccumulativeConsumptionPIC/RemainTimeBg/RemainTimeTxt")
    GUI.StaticSetText(titleTxt, StartTime .. " 至 " .. EndTime)

    local roll = GUI.GetChildByPath(page, "RewardBG/RewardRoller")
    local childnum = GUI.GetChildCount(roll)
    for i = 1, #data do
        local index = RECHARGE_DATA['ConsumIngotOfDay_State_' .. i]
        if not index then
            test("向服务器端发送请求失败")
            return
        end
        local obj = GUI.GetChild(page, "RewardTabBG" .. i)
        local Btn = GUI.GetChild(obj, "OnLineBtn")
        local Img = GUI.GetChild(obj, "OnLineImg")
        GUI.SetData(Btn, "index", index)
        GUI.SetData(Btn, "key", i)
        if index == 0 then
            GUI.ButtonSetText(Btn, "消费")
            GUI.ImageSetImageID(obj, "1801100010")
            GUI.ButtonSetShowDisable(Btn, true)
            GUI.SetVisible(Img, false)
        elseif index == 1 then
            GUI.ButtonSetText(Btn, "领取")
            GUI.ImageSetImageID(obj, "1801100010")
            GUI.ButtonSetShowDisable(Btn, true)
            GUI.SetVisible(Img, false)
        elseif index == 2 then
            GUI.SetVisible(Img, true)
            GUI.SetVisible(Btn, false)
            GUI.ImageSetImageID(obj, "1801100012")
            GUI.SetDepth(obj, childnum)
        end
        GUI.SetRedPointVisable(Btn, index == 1)
        local obj_desc = GUI.GetChild(obj, "DailyOnLineNum" .. i)
        GUI.StaticSetText(obj_desc, "(" .. num .. "/" .. data[i].Target .. ")")
    end
end

function SuperValueUI.on_gift_itemicon_click(guid)
    local bgPanel = _gt.GetUI("DailyConsumeReward")
    local item_bg = GUI.GetByGuid(guid)
    local types = GUI.GetData(item_bg, "type")
    local itemId = GUI.GetData(item_bg,"item")
    if types == "item" then
        local item = GUI.GetData(item_bg, "itemKey")
        if item then
            local tips = Tips.CreateByItemId(itemId,bgPanel,"itemTips",-400,20)
        end
    elseif types == "pet" then
        CL.SendNotify(NOTIFY.SubmitForm, "RechargeSystemEx", "InquirePetData", GUI.GetData(item_bg, "info"));
    end
end

function SuperValueUI.OnClickDailyConsumption(guid)
    local btn = GUI.GetByGuid(guid)
    local status = tonumber(GUI.GetData(btn, "index"))
    if status == 0 then
        --GetWay.Def[1].jump("MallUI",1,1)
        GUI.OpenWnd("MallUI")
        SuperValueUI.OnExit()
    elseif status == 1 then
        local key = GUI.GetData(GUI.GetByGuid(guid), "key")
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "ConsumIngotOfDay_Receive", tonumber(key))
    end
end
----------------------------------------------end 每日消费送礼 end-------------------------------------

----------------------------------------------start 连连充福利 start-------------------------------------
function SuperValueUI.CreateDailyRechargeReward(panelBg)
    local page = GUI.GroupCreate(panelBg, "DailyRechargeRewardPage", 110, 65, 820, 550)
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top);
    _gt.BindName(page, "DailyRechargeReward")
    local _RechargeGiftPIC = GUI.ImageCreate(page, "RechargeGiftPIC", "1800601060", 0, 0, false, 830, 126)
    SetAnchorAndPivot(_RechargeGiftPIC, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local temp = GUI.ImageCreate(_RechargeGiftPIC, "temp1", "1800608700", 0, 0, true, 830, 126)
    SetAnchorAndPivot(temp, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    temp = GUI.ImageCreate(_RechargeGiftPIC, "temp2", "1800608710", 0, 0, true, 830, 126)
    SetAnchorAndPivot(temp, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local _RechargeGiftImg = GUI.ImageCreate(_RechargeGiftPIC, "RechargeGiftImg", "1800604580", 165, 40, true, 0, 0)
    SetAnchorAndPivot(_RechargeGiftImg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _LongPeriodOfBg = GUI.ImageCreate(_RechargeGiftPIC, "LongPeriodOfBg", "1800601070", 0, 49, false, 540, 32)
    SetAnchorAndPivot(_LongPeriodOfBg, UIAnchor.Center, UIAroundPivot.Center)

    local _LongPeriodOfTxt = GUI.CreateStatic(_LongPeriodOfBg, "LongPeriodOfTxt", "", 70, 0, 540, 32, "system", true, false)
    GUI.StaticSetFontSize(_LongPeriodOfTxt, 20)
    GUI.SetColor(_LongPeriodOfTxt, codeColor)
    SetAnchorAndPivot(_LongPeriodOfTxt, UIAnchor.Center, UIAroundPivot.Center)

    local _RewardBG = GUI.ImageCreate(page, "RewardBG", "1800400010", -3, 137, false, 837, 415)
    SetAnchorAndPivot(_RewardBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    --创建滚轴
    local RollVecSize = Vector2.New(160, 300)
    local Roll = GUI.ScrollRectCreate(_RewardBG, "Roll", 14, 14, 810, 410, 0, true, RollVecSize, UIAroundPivot.TopLeft, UIAnchor.TopLeft);
    GUI.ScrollRectSetChildSpacing(Roll, Vector2.New(2, 10));

    local _OnLineBtn = GUI.ButtonCreate(page, "OnLineBtn", "1800002110", 660, 470, Transition.ColorTint, "", 120, 45, false);
    SetAnchorAndPivot(_OnLineBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetIsOutLine(_OnLineBtn, true)
    GUI.SetOutLine_Distance(_OnLineBtn, 1)
    GUI.SetOutLine_Color(_OnLineBtn, Color.New(133 / 255, 83 / 255, 61 / 255, 255 / 255))
    GUI.ButtonSetTextFontSize(_OnLineBtn, 22);
    GUI.ButtonSetText(_OnLineBtn, "充值")
    GUI.RegisterUIEvent(_OnLineBtn, UCE.PointerClick, "SuperValueUI", "OnClickDailyRechargeBtn")

    return page
end

function SuperValueUI.RefreshDailyRechargeReward()
    local data = RECHARGE_DATA.RechargeOfCon_Config
    local StartTime = RECHARGE_DATA.RechargeOfCon_StartTime
    local EndTime = RECHARGE_DATA.RechargeOfCon_EndTime
    local Day = RECHARGE_DATA.RechargeOfCon_Dayth
    local page = _gt.GetUI("DailyRechargeReward")
    local Roll_1 = GUI.GetChildByPath(page, "RewardBG/Roll")
    local count = data and #data or 10
    for i = 1, count do
        local name = "RechargeOfConRewardTabBG" .. i
        local rewardBG = GUI.GetChild(Roll_1, name)
        if not rewardBG then
            rewardBG = GUI.ImageCreate(Roll_1, name, "1801100010", 4, 0, false, 142, 260)
            SetAnchorAndPivot(rewardBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

            local _DailyOnLineKeyNamebg = GUI.ImageCreate(rewardBG, "DailyOnLineKeyNamebg" .. i, "1800600500", 21, 43, false, 115, 30)
            SetAnchorAndPivot(_DailyOnLineKeyNamebg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

            local _DailyOnLineKeyName = GUI.CreateStatic(_DailyOnLineKeyNamebg, "DailyOnLineKeyName" .. i, "第" .. i .. "天", 54, 4, 160, 30, "system", true, false);
            GUI.StaticSetFontSize(_DailyOnLineKeyName, 22)
            GUI.StaticSetAlignment(_DailyOnLineKeyName, TextAnchor.UpperLeft)
            SetAnchorAndPivot(_DailyOnLineKeyName, UIAnchor.Center, UIAroundPivot.Center)
            local sureColor = Color.New(80 / 255, 27 / 255, 3 / 255, 255 / 255)
            GUI.SetColor(_DailyOnLineKeyName, sureColor);

            local _RewardIcon = GUI.ItemCtrlCreate(rewardBG, "RewardIcon" .. i, "1801100120", 38, 110, 86, 86, false)

            GUI.ItemCtrlSetElementRect(_RewardIcon,eItemIconElement.Icon,0,-1,75,74)
            SetAnchorAndPivot(_RewardIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.RegisterUIEvent(_RewardIcon, UCE.PointerClick, "SuperValueUI", "on_itembg_click")

            local _ReceiveBtn = GUI.ButtonCreate(rewardBG, "ReceiveBtn" .. i, "1800002110", 20, 220, Transition.ColorTint, "", 120, 45, false);
            SetAnchorAndPivot(_ReceiveBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetIsOutLine(_ReceiveBtn, true)
            GUI.AddRedPoint(_ReceiveBtn, UIAnchor.TopRight, -5, 5)
            GUI.SetOutLine_Distance(_ReceiveBtn, 1)
            GUI.SetOutLine_Color(_ReceiveBtn, Color.New(133 / 255, 83 / 255, 61 / 255, 255 / 255))
            GUI.ButtonSetTextFontSize(_ReceiveBtn, 22);
            GUI.RegisterUIEvent(_ReceiveBtn, UCE.PointerClick, "SuperValueUI", "btnRechargeOfCon_OnClick")

            local button = GUI.ButtonCreate(rewardBG, "obj_btn" .. i, "1800402110", 20, 220, Transition.ColorTint, "", 120, 45, false);
            SetAnchorAndPivot(button, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.AddRedPoint(button, UIAnchor.TopRight, -5, 5)
            GUI.ButtonSetTextColor(button, Color.New(133 / 255, 72 / 255, 27 / 255, 255 / 255))
            GUI.ButtonSetTextFontSize(button, 24);
            GUI.ButtonSetShowDisable(button, false)
            GUI.SetVisible(button, false)

            local _OnLineImg = GUI.ImageCreate(rewardBG, "OnLineImg" .. i, "1800604390", 25, 210, false, 0, 0)
            SetAnchorAndPivot(_OnLineImg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        end
    end
    local Roll_subset_num = GUI.GetChildCount(Roll_1)
    for i = 1, Roll_subset_num do
        local DailyOnLineRewardTabBG_1 = GUI.GetChildByPath(page, "RewardBG/Roll/RechargeOfConRewardTabBG" .. i)
        GUI.SetVisible(DailyOnLineRewardTabBG_1, false)
    end
    for i = 1, #data do
        local RechargeOfConRewardTabBG = GUI.GetChildByPath(page, "RewardBG/Roll/RechargeOfConRewardTabBG" .. i)
        local _RewardIcon_1 = GUI.GetChild(RechargeOfConRewardTabBG, "RewardIcon" .. i)
        GUI.SetVisible(RechargeOfConRewardTabBG, true)
        if data[i].Item then
			if type(data[i].Item) == "string" then
				GUI.SetData(_RewardIcon_1, "itemKey", data[i].Item)
				if string.find(data[i].Item, "#") then					
					data[i].Item = string.split(data[i].Item, "#")[1]
				end
			end
            local item = DB.GetOnceItemByKey2(data[i].Item)
            if item then
                local grade = QualityRes[item.Grade]
                GUI.ItemCtrlSetElementValue(_RewardIcon_1, eItemIconElement.Border, grade)
                GUI.SetData(_RewardIcon_1, "type", "item")
                GUI.SetData(_RewardIcon_1, "item", item.Id)
                GUI.ItemCtrlSetElementValue(_RewardIcon_1, eItemIconElement.Icon, item.Icon)
                GUI.ItemCtrlSetElementValue(_RewardIcon_1, eItemIconElement.RightBottomNum, data[i].Num)
                GUI.ItemCtrlSetIconGray(_RewardIcon_1, false)
                local _item_RightBottom = GUI.ItemCtrlGetElement(_RewardIcon_1, eItemIconElement.RightBottomNum)
                if _item_RightBottom then
                    GUI.SetPositionX(_item_RightBottom, 7)
                    GUI.SetPositionY(_item_RightBottom, 5)
                    GUI.StaticSetFontSize(_item_RightBottom, 20)
                    GUI.SetIsOutLine(_item_RightBottom, true)
                    GUI.SetOutLine_Color(_item_RightBottom, Color.New(0 / 255, 0 / 255, 0 / 255, 255 / 255))
                    GUI.SetOutLine_Distance(_item_RightBottom, 1)
                    GUI.SetColor(_item_RightBottom, Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255))
                end
            end
        end
        if data[i].Pet then
            local pet = DB.GetOncePetByKey2(data[i].Pet)
            if pet then
                local grade = tonumber(pet.Type)
                GUI.ItemCtrlSetElementValue(_RewardIcon_1, eItemIconElement.Border, QualityRes[grade])
                GUI.ItemCtrlSetElementValue(_RewardIcon_1, eItemIconElement.Icon, tostring(pet.Head))

                GUI.ItemCtrlSetElementValue(_RewardIcon_1, eItemIconElement.RightBottomNum, "")
                local wnd = GUI.GetChild(_RewardIcon_1, "item_Icon")
                if wnd ~= 0 then
                    GUI.SetScale(wnd, Vector3.New(0.95, 0.95, 0.95))
                    GUI.SetPositionY(wnd, -1.5)
                end

                local img = GUI.ItemCtrlGetElement(_RewardIcon_1, eItemIconElement.Icon)
                GUI.ImageSetGray(img, false)
                GUI.SetVisible(img, true)
                GUI.SetScale(img, Vector3.New(1, 1, 1))

                GUI.SetData(_RewardIcon_1, "type", "pet")
                GUI.SetData(_RewardIcon_1, "info", data[i].Pet)
            end
        end
    end

    local titleTxt = GUI.GetChildByPath(page, "RechargeGiftPIC/LongPeriodOfBg/LongPeriodOfTxt")
    GUI.StaticSetText(titleTxt, StartTime .. " 至 " .. EndTime)

    for i = 1, #data do
        local index = RECHARGE_DATA['RechargeOfCon_State_' .. i]
        if not index then
            test("访问服务器失败")
            return
        end
        local obj = GUI.GetChildByPath(page, "RewardBG/Roll/RechargeOfConRewardTabBG" .. i)
        local Btn = GUI.GetChild(obj, "ReceiveBtn" .. i)
        local But = GUI.GetChild(obj, "obj_btn" .. i)
        local Img = GUI.GetChild(obj, "OnLineImg" .. i)
        GUI.SetVisible(But, false)
        if index == 0 then
            GUI.SetVisible(Btn, false)
            GUI.SetVisible(Img, false)
            if Day == i then
                GUI.ButtonSetText(But, "未充值")
                GUI.SetVisible(But, true)
            end
            GUI.SetRedPointVisable(But, false)
        elseif index == 1 then
            GUI.ButtonSetText(Btn, "领取")
            GUI.ButtonSetShowDisable(Btn, true)
            GUI.SetVisible(Btn, true)
            GUI.SetVisible(Img, false)
        elseif index == 2 then
            GUI.SetVisible(Img, true)
            GUI.SetVisible(Btn, false)
        end
        GUI.SetRedPointVisable(Btn, index == 1)
        if Day == i then
            GUI.ImageSetImageID(obj, "1801100010")
            if i > 1 and #data > 5 then
                local invariability_num = #data - 4
                if #data - i >= 4 then
                    if not SuperValueUI.RechargeOfConTime then
                        SuperValueUI.RechargeOfConTime = Timer.New(SuperValueUI.RechargeOfConBack, 0.3, 1)
                    end
                    SuperValueUI.RechargeGift_index = i
                    SuperValueUI.RechargeOfConTime:Start()
                else
                    if not SuperValueUI.RechargeOfConTime then
                        SuperValueUI.RechargeOfConTime = Timer.New(SuperValueUI.RechargeOfConBack, 0.3, 1)
                    end
                    SuperValueUI.RechargeGift_index = invariability_num
                    SuperValueUI.RechargeOfConTime:Start()
                end
            end
        else
            GUI.ImageSetImageID(obj, "1801100012")
        end
    end
end

--超值连连充图标点击事件
function SuperValueUI.on_itembg_click(guid)
    local bgPanel = _gt.GetUI("DailyRechargeReward")
    local item_bg = GUI.GetByGuid(guid)
    local types = GUI.GetData(item_bg, "type")
    local itemId = GUI.GetData(item_bg,"item")
    if types == "item" then
        local item = GUI.GetData(item_bg, "itemKey")
        if item then
            local tips = Tips.CreateByItemId(itemId, bgPanel, "itemTips", 0, 120)
        end
    elseif types == "pet" then
        CL.SendNotify(NOTIFY.SubmitForm,"FormPet","QueryPetByKeyName",tostring(GUI.GetData(item_bg, "info")))
    end
end

function SuperValueUI.btnRechargeOfCon_OnClick(guid)
    CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "RechargeOfCon_Receive")
end

function SuperValueUI.RechargeOfConBack()
    local _RechargeGiftParent = _gt.GetUI("DailyRechargeReward")
    local Roll = GUI.GetChildByPath(_RechargeGiftParent, "RewardBG/Roll")
    GUI.ScrollRectSetNormalizedPosition(Roll, Vector2.New(SuperValueUI.RechargeGift_index * 0.1, 0))
    SuperValueUI.RechargeOfConTime = nil
end

function SuperValueUI.OnClickDailyRechargeBtn(guid)
    GetWay.Def[1].jump("MallUI", "充值")
    SuperValueUI.OnExit()
end
----------------------------------------------end 连连充福利 end-------------------------------------

----------------------------------------------start 消费返元宝 start-------------------------------------
function SuperValueUI.CreateConsumeReturnGold(panelBg)
    local page = GUI.GroupCreate(panelBg, "ConsumeReturnGoldPage", 110, 65, 820, 550)
    UILayout.SetSameAnchorAndPivot(page, UILayout.Top)
    _gt.BindName(page, "ConsumeReturnGold")

    local AdvImage = GUI.ImageCreate(page, "AdvImage", "1800601060", 0, 0, false, 830, 126)
    SetAnchorAndPivot(AdvImage, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local temp = GUI.ImageCreate(AdvImage, "temp1", "1800608700", 0, 0, true, 830, 126)
    SetAnchorAndPivot(temp, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    temp = GUI.ImageCreate(AdvImage, "temp2", "1800608710", 0, 0, true, 830, 126)
    SetAnchorAndPivot(temp, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local AdvTextImage = GUI.ImageCreate(AdvImage, "AdvTextImage", "1800604620", 0, -5, true, 0, 0)
    SetAnchorAndPivot(AdvTextImage, UIAnchor.Center, UIAroundPivot.Center)

    local TextBg = GUI.ImageCreate(AdvImage, "TextBg", "1800601070", 0, 1, false, 600, 32);
    SetAnchorAndPivot(TextBg, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local titleTxt = GUI.CreateStatic(TextBg, "titleTxt", "", 0, 0, 550, 35, "system", true, false);
    GUI.StaticSetFontSize(titleTxt, 20)
    GUI.SetColor(titleTxt, Color.New(128 / 255, 85 / 255, 56 / 255));
    SetAnchorAndPivot(titleTxt, UIAnchor.Center, UIAroundPivot.Center)

    local RewardBG = GUI.ImageCreate(page, "RewardBG", "1800400010", -3, 137, false, 837, 407)
    SetAnchorAndPivot(RewardBG, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local RollVecSize = Vector2.New(815, 131)
    local Roll = GUI.ScrollRectCreate(RewardBG, "Roll", 11, 10, 832, 384, 0, false, RollVecSize, UIAroundPivot.TopLeft, UIAnchor.TopLeft);
    GUI.ScrollRectSetChildSpacing(Roll, Vector2.New(0, 8));

    local data = RECHARGE_DATA.ConsumIngotOfAcc_Config
    local count = data and #data or 11
    for i = 1, count do
        local obj = GUI.ImageCreate(Roll, "reward_obj_" .. i, "1801100010", 0, 0);

        local obj_name_bg = GUI.ImageCreate(obj, "obj_name_bg", "1800600500", 48, -22, false, 240, 35)
        SetAnchorAndPivot(obj_name_bg, UIAnchor.Left, UIAroundPivot.Left)

        local Label = GUI.CreateStatic(obj_name_bg, "obj_name", "累计消费元宝", 0, 0, 240, 35, "system", true, false);
        GUI.StaticSetFontSize(Label, 22)
        GUI.StaticSetAlignment(Label, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(Label, UIAnchor.Center, UIAroundPivot.Center)
        local sureColor = Color.New(80 / 255, 27 / 255, 3 / 255, 255 / 255)
        GUI.SetColor(Label, sureColor)

        Label = GUI.CreateStatic(obj, "obj_desc", "0/9999", 0, 22, 333, 35, "system", true, false);
        GUI.StaticSetFontSize(Label, 22)
        GUI.StaticSetAlignment(Label, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(Label, UIAnchor.Left, UIAroundPivot.Left)
        local sureColor = Color.New(163 / 255, 111 / 255, 21 / 255, 255 / 255);
        GUI.SetColor(Label, sureColor)

        local obj_reward_bg = GUI.ImageCreate(obj, "obj_reward_bg", "1800900040", 90, 0, false, 211, 35)
        SetAnchorAndPivot(obj_reward_bg, UIAnchor.Center, UIAroundPivot.Center)

        local obj_reward_icon = GUI.ImageCreate(obj_reward_bg, "obj_reward_icon", UIDefine.GetMoneyIcon(1), -20, -2, false, 50, 50)
        SetAnchorAndPivot(obj_reward_icon, UIAnchor.Left, UIAroundPivot.Left)

        local obj_reward_text = GUI.CreateStatic(obj_reward_bg, "obj_reward_text", 100, 0, 0, 211, 35, "system", true, false);
        GUI.StaticSetFontSize(obj_reward_text, 22)
        GUI.StaticSetAlignment(obj_reward_text, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(obj_reward_text, UIAnchor.Center, UIAroundPivot.Center)
        local sureColor = Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255);
        GUI.SetColor(obj_reward_text, sureColor);

        local button = GUI.ButtonCreate(obj, "obj_btn", "1800402110", -25, 0, Transition.ColorTint, "消费", 124, 48, false);
        SetAnchorAndPivot(button, UIAnchor.Right, UIAroundPivot.Right)
        GUI.AddRedPoint(button, UIAnchor.TopRight, -5, 5)
        GUI.SetRedPointVisable(button,false)
        GUI.SetData(button, "key", i)
        GUI.RegisterUIEvent(button, UCE.PointerClick, "SuperValueUI", "OnReturnGoldBtnClick")
        GUI.ButtonSetTextColor(button, Color.New(133 / 255, 72 / 255, 27 / 255, 255 / 255))
        GUI.ButtonSetTextFontSize(button, 24);

        local over_image = GUI.ImageCreate(obj, "obj_over_image", "1800604390", -25, 0, true, 0, 0)
        SetAnchorAndPivot(over_image, UIAnchor.Right, UIAroundPivot.Right)
        GUI.SetVisible(over_image, false)
    end
    return page
end

function SuperValueUI.RefreshConsumeReturnGold()
    local data = RECHARGE_DATA.ConsumIngotOfAcc_Config
    if data then
        local page = _gt.GetUI("ConsumeReturnGold")
        local titleTxt = GUI.GetChildByPath(page, "AdvImage/TextBg/titleTxt")
        GUI.StaticSetText(titleTxt, RECHARGE_DATA.ConsumIngotOfAcc_StartTime .. " 至 " .. RECHARGE_DATA.ConsumIngotOfAcc_EndTime)

        local roll = GUI.GetChildByPath(page, "RewardBG/Roll")
        for i = 1, #data do
            local obj = GUI.GetChild(roll, "reward_obj_" .. i)
            GUI.SetDepth(obj, i - 1)
            GUI.ImageSetImageID(obj, "1801100010")
        end

        local childnum = GUI.GetChildCount(roll)
        for i = 1, #data do
            local obj = GUI.GetChild(roll, "reward_obj_" .. i)
            local status = RECHARGE_DATA["ConsumIngotOfAcc_State_" .. i]
            local txt = GUI.GetChildByPath(obj, "obj_reward_bg/obj_reward_text")
            GUI.StaticSetText(txt, data[i].RewardVal)

            local btn = GUI.GetChild(obj, "obj_btn")
            local image = GUI.GetChild(obj, "obj_over_image")
            if status == 0 then
                GUI.SetVisible(btn, true)
                GUI.SetVisible(image, false)
                GUI.ButtonSetText(btn, "消费")
            elseif status == 1 then
                GUI.SetVisible(btn, true)
                GUI.SetVisible(image, false)
                GUI.ButtonSetText(btn, "领取")
                GUI.SetDepth(obj, 0)
            elseif status == 2 then
                GUI.SetVisible(btn, false)
                GUI.SetVisible(image, true)
                GUI.ImageSetImageID(obj, "1801100012")
                GUI.SetDepth(obj, childnum)
            end
            GUI.SetRedPointVisable(btn, status == 1)
            local obj_desc = GUI.GetChild(obj, "obj_desc")
            GUI.StaticSetText(obj_desc, "(" .. RECHARGE_DATA.ConsumIngotOfAcc_TotalCon .. "/" .. data[i].Target .. ")")
        end
    else
        test("RECHARGE_DATA.ConsumIngotOfAcc_Config不存在")
    end
end

function SuperValueUI.OnReturnGoldBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local key = GUI.GetData(btn, "key")
    local status = RECHARGE_DATA["ConsumIngotOfAcc_State_" .. key]
    if status == 0 then
        GUI.OpenWnd("MallUI")
        --GetWay.Def[1].jump("MallUI",1,1)
        SuperValueUI.OnExit()
    elseif status == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "ConsumIngotOfAcc_Receive", tonumber(key))
    end
end
----------------------------------------------end 消费返元宝 end-------------------------------------

----------------------------------------------Start 限购大礼包 Start-------------------------------------
function SuperValueUI.CreateRMBShopOfOncPage(panelBg)
    local ShopGroup = GUI.GroupCreate(panelBg,"RMBShopOfOncPage",110, 65, 820, 550)
    SetSameAnchorAndPivot(ShopGroup, UILayout.Top)
    _gt.BindName(ShopGroup,"ShopGroup")

    local AdvImage = GUI.ImageCreate(ShopGroup, "AdvImage", "1800601060", 0, 0, false, 830, 126)
    SetSameAnchorAndPivot(AdvImage, UILayout.TopLeft)

    local temp = GUI.ImageCreate(AdvImage, "temp1", "1800608700", 0, 0, true, 830, 126)
    SetSameAnchorAndPivot(temp, UILayout.TopLeft)

    temp = GUI.ImageCreate(AdvImage, "temp2", "1800608710", 0, 0, true, 830, 126)
    SetSameAnchorAndPivot(temp, UILayout.TopRight)

    local AdvTextImage = GUI.ImageCreate(AdvImage, "AdvTextImage", "1800604590", 0, -5, true, 0, 0)
    SetSameAnchorAndPivot(AdvTextImage, UILayout.Center)

    local TextBg = GUI.ImageCreate(AdvImage, "TextBg", "1800601070", 0, 1, false, 600, 32);
    SetSameAnchorAndPivot(TextBg, UILayout.Bottom)

    local titleTxt = GUI.CreateStatic(TextBg, "TitleTxt", "2019-12-01 00:00:00 至 2023-01-31 09:59:59", 0, 0, 550, 35, "system", true, false);
    GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(titleTxt, 20)
    GUI.SetColor(titleTxt, Color.New(128 / 255, 85 / 255, 56 / 255));
    SetSameAnchorAndPivot(titleTxt, UILayout.Center)

    local RewardBG = GUI.ImageCreate(ShopGroup, "RewardBG", "1800400010", -3, 137, false, 837, 407)
    SetSameAnchorAndPivot(RewardBG, UILayout.TopLeft)

    local ShopLoop = GUI.LoopScrollRectCreate(
            RewardBG,
            "FarmLoop",
            20,
            5,
            GUI.GetWidth(RewardBG)-40,
            GUI.GetHeight(RewardBG)-10,
            "SuperValueUI",
            "CreateShopLoopItem",
            "SuperValueUI",
            "RefreshShopLoopItem",
            0,
            true,
            Vector2.New(240,380),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(ShopLoop, UILayout.BottomLeft)
    GUI.ScrollRectSetAlignment(ShopLoop, TextAnchor.MiddleCenter)
    GUI.ScrollRectSetChildSpacing(ShopLoop, Vector2.New(5, 0))
    GUI.ScrollRectSetVertical(ShopLoop,false)
    _gt.BindName(ShopLoop, "ShopLoop")

    return ShopGroup
end

--限购大礼包刷新事件
function SuperValueUI.RefreshRMBShopOfOncPage()
    test("限购大礼包刷新事件")
    test("RECHARGE_DATA.RMBShopOfOnce_StartTime",inspect(RECHARGE_DATA.RMBShopOfOnce_StartTime))
    test("RECHARGE_DATA.RMBShopOfOnce_EndTime",inspect(RECHARGE_DATA.RMBShopOfOnce_EndTime))
    test("RECHARGE_DATA.RMBShopOfOnce_MaxConfig",inspect(RECHARGE_DATA.RMBShopOfOnce_MaxConfig))
    test("RECHARGE_DATA.RMBShopOfOnce_Config",inspect(RECHARGE_DATA.RMBShopOfOnce_Config))
    test("RECHARGE_DATA.RMBShopOfOnce_State_1",inspect(RECHARGE_DATA.RMBShopOfOnce_State_1))
    RMBShopOfOnceTable = RECHARGE_DATA.RMBShopOfOnce_Config

    local ShopGroup = _gt.GetUI("ShopGroup")
    local AdvImage = GUI.GetChild(ShopGroup,"AdvImage",false)
    local TextBg = GUI.GetChild(AdvImage,"TextBg",false)
    local TitleTxt = GUI.GetChild(TextBg,"TitleTxt",false)
    GUI.StaticSetText(TitleTxt,RECHARGE_DATA.RMBShopOfOnce_StartTime.." 至 "..RECHARGE_DATA.RMBShopOfOnce_EndTime)

    local ShopLoop = _gt.GetUI("ShopLoop")
    GUI.LoopScrollRectSetTotalCount(ShopLoop,#RMBShopOfOnceTable)
    GUI.LoopScrollRectRefreshCells(ShopLoop)
end

function SuperValueUI.CreateShopLoopItem()
    local ShopLoop = _gt.GetUI("ShopLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(ShopLoop) + 1
    local ShopItem = GUI.GroupCreate(ShopLoop,"ShopItem"..index,0,0,240,380,false)

    local ShopBg = GUI.ImageCreate(ShopItem,"ShopBg","1801100010",0,0,false,240,380,false)
    SetSameAnchorAndPivot(ShopBg, UILayout.Center)

    local titleBg = GUI.ImageCreate(ShopBg,"TitleBg" , "1800601110" , 0 , 0 , false, 100, 100);
    SetSameAnchorAndPivot(titleBg, UILayout.TopLeft)

    local titleTxt = GUI.CreateStatic(titleBg,"TitleTxt" , "限购N次" , -12 ,-12,120,30,"system",true,false);
    GUI.StaticSetFontSize(titleTxt,22)
    GUI.SetColor(titleTxt,WhiteColor)
    GUI.SetEulerAngles(titleTxt, Vector3.New(0, 0, 45));
    GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(titleTxt, UILayout.Center)

    local RewardIcon = GUI.ImageCreate(ShopBg,"RewardIcon" , "1801208700" , 0 , 40 , false, 120, 120)
    SetSameAnchorAndPivot(RewardIcon, UILayout.Top)

    local CurrencyBg = GUI.ImageCreate(ShopBg,"CurrencyBg" , "1800600040" , 0 , 0 , false, 160, 35)
    SetSameAnchorAndPivot(CurrencyBg, UILayout.Center)

    local CurrencyImage = GUI.ImageCreate(CurrencyBg,"CurrencyImage" , "1800408270" , 0 , -1)
    SetSameAnchorAndPivot(CurrencyImage, UILayout.Left)

    local CurrencyTxt = GUI.CreateStatic(CurrencyBg,"CurrencyTxt" , "9999" , 40 ,0,110,30,"system",true,false);
    GUI.StaticSetFontSize(CurrencyTxt,25)
    GUI.SetColor(CurrencyTxt,BrownColor)
    GUI.StaticSetAlignment(CurrencyTxt, TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(CurrencyTxt, UILayout.Left)

    for i = 1, 3 do
        local ItemIcon = GUI.ItemCtrlCreate(ShopItem,"ItemIcon"..i,QualityRes[1],10+75*(i-1),90,70,70,false,"system",false)
        SetSameAnchorAndPivot(ItemIcon, UILayout.BottomLeft)
        GUI.ItemCtrlSetElementRect(ItemIcon,eItemIconElement.Icon,-1,-1,65,62)
        GUI.ItemCtrlSetElementRect(ItemIcon,eItemIconElement.RightBottomNum,5,5)
        GUI.RegisterUIEvent(ItemIcon, UCE.PointerClick, "SuperValueUI", "OnItemIconClick")
    end

    local BuyThisShopBtn = GUI.ButtonCreate(ShopItem,"BuyThisShopBtn", "1800602020",0,30, Transition.ColorTint,"￥999",120,45,false);
    GUI.AddRedPoint(BuyThisShopBtn, UIAnchor.TopRight, -5, 5)
    GUI.SetRedPointVisable(BuyThisShopBtn, false)
    GUI.ButtonSetTextColor(BuyThisShopBtn,BrownColor)
    GUI.ButtonSetTextFontSize(BuyThisShopBtn,25)
    SetSameAnchorAndPivot(BuyThisShopBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(BuyThisShopBtn, UCE.PointerClick, "SuperValueUI", "OnBuyThisShopBtnClick")

    return ShopItem
end

--限购大礼包的Loop刷新事件
function SuperValueUI.RefreshShopLoopItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local ShopItem = GUI.GetByGuid(guid)
    local TableData = RMBShopOfOnceTable[index]


    local ShopBg = GUI.GetChild(ShopItem,"ShopBg",false)
    local BuyThisShopBtn = GUI.GetChild(ShopItem,"BuyThisShopBtn",false)

    local CurrencyBg = GUI.GetChild(ShopBg,"CurrencyBg",false)
    local TitleBg = GUI.GetChild(ShopBg,"TitleBg",false)


    local CurrencyTxt = GUI.GetChild(CurrencyBg,"CurrencyTxt",false)
    local CurrencyImage = GUI.GetChild(CurrencyBg,"CurrencyImage",false)
    local TitleTxt = GUI.GetChild(TitleBg,"TitleTxt",false)

    if TableData then
        local ChildTable = TableData.ItemList
        for i = 1, 3 do
            local IconItem = GUI.GetChild(ShopItem,"ItemIcon"..i,false)

            ItemIcon.SetEmpty(IconItem)

            local ItemKeyName = ChildTable[i*3-2]
            local ItemNum = ChildTable[i*3-1]
            local ItemIsBound = ChildTable[i*3]
            if ItemKeyName ~= nil then
                local ItemDB = DB.GetOnceItemByKey2(ItemKeyName)
                GUI.ItemCtrlSetElementValue(IconItem,eItemIconElement.Icon,ItemDB.Icon)
                GUI.ItemCtrlSetElementValue(IconItem,eItemIconElement.Border,QualityRes[ItemDB.Grade])
                GUI.ItemCtrlSetElementValue(IconItem,eItemIconElement.RightBottomNum,ItemNum)
                GUI.SetData(IconItem,"ItemId",ItemDB.Id)
                if ItemIsBound == 1 then
                    GUI.ItemCtrlSetElementValue(IconItem,eItemIconElement.LeftTopSp,"1800707120")--是否为绑定
                else
                    GUI.ItemCtrlSetElementValue(IconItem,eItemIconElement.LeftTopSp,"")--是否为绑定
                end
            end
        end

        local BuyNum =  RECHARGE_DATA["RMBShopOfOnce_SurplusTimes_"..index]
        local BuyStatus =  RECHARGE_DATA["RMBShopOfOnce_State_"..index]
        if BuyNum > 0 or BuyStatus == 1 then
            GUI.ButtonSetShowDisable(BuyThisShopBtn, true)
            if BuyStatus == 1 then
                GUI.ButtonSetText(BuyThisShopBtn,"领 取")
                GUI.SetRedPointVisable(BuyThisShopBtn, true)
            else
                GUI.ButtonSetText(BuyThisShopBtn,"￥"..TableData.Price)
                GUI.SetRedPointVisable(BuyThisShopBtn, false)
            end
        else
            GUI.ButtonSetShowDisable(BuyThisShopBtn, false)
            GUI.SetRedPointVisable(BuyThisShopBtn, false)
            GUI.ButtonSetText(BuyThisShopBtn,"已售罄")
        end
        local MoneyTypes = UIDefine.MoneyTypes[TableData.RewardType]
        local MoneyIcon = UIDefine.AttrIcon[MoneyTypes]

        GUI.ImageSetImageID(CurrencyImage,MoneyIcon)
        GUI.StaticSetText(CurrencyTxt,TableData.RewardVal)
        GUI.StaticSetText(TitleTxt,"限购"..BuyNum.."次")

        GUI.SetData(BuyThisShopBtn,"Status",BuyStatus)
        GUI.SetData(BuyThisShopBtn,"Index",index)
        GUI.SetData(BuyThisShopBtn,"Price",TableData.Price)
    end
end

--限购大礼包购买Item的点击事件
function SuperValueUI.OnItemIconClick(guid)
    test("限购大礼包购买Item的点击事件")
    local panelBg = _gt.GetUI("panelBg")
    local ItemIcon = GUI.GetByGuid(guid)
    local ItemId = GUI.GetData(ItemIcon,"ItemId")
    local tips = Tips.CreateByItemId(ItemId, panelBg, "itemTips", 0, 0)
end

--限购大礼包购买按钮的点击事件
function SuperValueUI.OnBuyThisShopBtnClick(guid)
    test("限购大礼包购买按钮的点击事件")
    local BuyThisShopBtn = GUI.GetByGuid(guid)
    local Index = tonumber(GUI.GetData(BuyThisShopBtn,"Index"))
    local Status = tonumber(GUI.GetData(BuyThisShopBtn,"Status"))
    local Price = GUI.GetData(BuyThisShopBtn,"Price")
    if Status == 1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "RMBShopOfOnce_Receive",Index)
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormRecharge", "SetRechargeType","RMBShopOfOnce",Index,Price)
    end
end
----------------------------------------------End 限购大礼包 End--------------------------------------------