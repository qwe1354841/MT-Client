local EquipFossilSynthesisUI = {}
_G.EquipFossilSynthesisUI = EquipFossilSynthesisUI
-- 强化石合成界面

local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")


--------------------------------------Start 定义 Start---------------------------------
local _gt = UILayout.NewGUIDUtilTable()
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local GradeColor = UIDefine.GradeColor
local QualityRes = UIDefine.ItemIconBg

local WhiteText = UIDefine.WhiteColor
local RedText = UIDefine.RedColor
local BlackText = UIDefine.BlackColor
local Yellow2Text = UIDefine.Yellow2Color
local Yellow4Text = UIDefine.Yellow4Color
---------------------------------------End 定义 End------------------------------------


--------------------------------------Start 全局变量 Start---------------------------------

local BagFossilTable = {}
local LastCheckBoxGuid = nil
local LastCheckBoxIndex = 0
local LuckValue = 0
local NowCheckStoneId = 0
local IsOnShowOpen = true
local TipsContent = ""
---------------------------------------End 全局变量 End------------------------------------



function EquipFossilSynthesisUI.Main()
    local wnd = GUI.WndCreateWnd("EquipFossilSynthesisUI", "EquipFossilSynthesisUI", 0, 0);

    local panelBg = UILayout.CreateFrame_WndStyle2(wnd, "强化石合成", 950, 620, "EquipFossilSynthesisUI", "OnExit", _gt,true)
    SetSameAnchorAndPivot(panelBg, UILayout.Center)

    local LeftFossilBg = GUI.ImageCreate(panelBg, "LeftFossilBg", "1800400010", 30,80, false, 248, 445)
    SetSameAnchorAndPivot(LeftFossilBg, UILayout.TopLeft)

    --左边强化石列表
    local LeftFossilLoop =
    GUI.LoopScrollRectCreate(
            LeftFossilBg,
            "LeftFossilLoop",
            5,
            5,
            400,
            432,
            "EquipFossilSynthesisUI",
            "CreateLeftFossilItem",
            "EquipFossilSynthesisUI",
            "RefreshLeftFossilItem",
            0,
            false,
            Vector2.New(238, 112),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(LeftFossilLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(LeftFossilLoop, TextAnchor.UpperCenter)
    _gt.BindName(LeftFossilLoop, "LeftFossilLoop")

    local RightSynthesisBg = GUI.ImageCreate(panelBg, "RightSynthesisBg", "1801100100", 125,80, false, 640, 450)
    SetSameAnchorAndPivot(RightSynthesisBg, UILayout.Top)
    _gt.BindName(RightSynthesisBg, "RightSynthesisBg")

    local CheckBindBtn = GUI.CheckBoxExCreate(RightSynthesisBg, "CheckBindBtn", "1800607150", "1800607151", 10, 10, false, 40, 40)
    _gt.BindName(CheckBindBtn, "CheckBindBtn")
    SetSameAnchorAndPivot(CheckBindBtn, UILayout.TopLeft)
    local txt = GUI.CreateStatic(CheckBindBtn, "bindText", "优先使用非绑材料", 40, 0, 200, 35)
    SetSameAnchorAndPivot(txt, UILayout.Left)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
    GUI.SetColor(txt, UIDefine.BrownColor)

    local CurrentItem = EquipFossilSynthesisUI.CreateFossilSynthesisItem(RightSynthesisBg,"CurrentItem", 10, 50,"当前")
    SetSameAnchorAndPivot(CurrentItem, UILayout.TopLeft)
    _gt.BindName(CurrentItem,"CurrentItem")

    local RightArrow = GUI.ImageCreate(RightSynthesisBg,"RightArrow","1801107010", 0, 100)
    SetSameAnchorAndPivot(RightArrow, UILayout.Top)

    local StrengthenItem = EquipFossilSynthesisUI.CreateFossilSynthesisItem(RightSynthesisBg,"StrengthenItem", 360, 50,"强化后")
    SetSameAnchorAndPivot(StrengthenItem, UILayout.TopLeft)
    _gt.BindName(StrengthenItem,"StrengthenItem")

    local consumeText = GUI.CreateStatic(RightSynthesisBg, "consumeText", "消耗", 0, -20, 100, 30)
    GUI.SetColor(consumeText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(consumeText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(consumeText, UILayout.BottomLeft)

    local consumeBg = GUI.ImageCreate(RightSynthesisBg, "consumeBg", "1800700010", 80, -19, false, 180, 35)
    SetSameAnchorAndPivot(consumeBg, UILayout.BottomLeft)

    local coin = GUI.ImageCreate(consumeBg, "coin", "1800408280", 0, 0, false, 36, 36)
    local num = GUI.CreateStatic(consumeBg, "num", "100", 0, 0, 160, 30)
    GUI.SetColor(num, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
    GUI.SetAnchor(num, UIAnchor.Center)
    GUI.SetPivot(num, UIAroundPivot.Center)
    GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)

    local rateText = GUI.CreateStatic(RightSynthesisBg, "rateText", "成功率", -120, -20, 100, 30)
    GUI.SetColor(rateText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(rateText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(rateText, TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(rateText, UILayout.BottomRight)

    local rateNum = GUI.CreateStatic(rateText, "rateNum", "100%", 5, 16, 100, 30)
    GUI.SetColor(rateNum, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(rateNum, UIDefine.FontSizeL)
    GUI.SetPivot(rateNum, UIAroundPivot.Left)

    local LuckyTxt = GUI.CreateStatic(RightSynthesisBg, "LuckyTxt", "幸运值", -250, -20, 100, 30)
    GUI.SetColor(LuckyTxt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(LuckyTxt, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(LuckyTxt, TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(LuckyTxt, UILayout.BottomRight)

    local LuckyValue = GUI.CreateStatic(LuckyTxt, "LuckyValue", "100%", 5, 16, 100, 30)
    GUI.SetColor(LuckyValue, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(LuckyValue, UIDefine.FontSizeL)
    GUI.SetPivot(LuckyValue, UIAroundPivot.Left)

    local TipsBtn = GUI.ImageCreate(RightSynthesisBg, "TipsBtn", "1800702030", -20, -20)
    GUI.SetIsRaycastTarget(TipsBtn,true)
    SetSameAnchorAndPivot(TipsBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(TipsBtn, UCE.PointerClick, "EquipFossilSynthesisUI", "OnTipsBtnClick")

    local SynthesisBtn = GUI.ButtonCreate(RightSynthesisBg, "SynthesisBtn", "1800002060", -5 , 65, Transition.ColorTint, "合成", 160, 50, false)
    GUI.SetEventCD(SynthesisBtn, UCE.PointerClick, 0.5)
    GUI.ButtonSetTextColor(SynthesisBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(SynthesisBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetOutLineArgs(SynthesisBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
    SetSameAnchorAndPivot(SynthesisBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(SynthesisBtn, UCE.PointerClick, "EquipFossilSynthesisUI", "OnSynthesisBtnClick")

    local AllSynthesisBtn = GUI.ButtonCreate(RightSynthesisBg, "AllSynthesisBtn", "1800002060", -205 , 65, Transition.ColorTint, "全部合成", 160, 50, false)
    GUI.SetEventCD(AllSynthesisBtn, UCE.PointerClick, 0.5)
    GUI.ButtonSetTextColor(AllSynthesisBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(AllSynthesisBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetOutLineArgs(AllSynthesisBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
    SetSameAnchorAndPivot(AllSynthesisBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(AllSynthesisBtn, UCE.PointerClick, "EquipFossilSynthesisUI", "OnAllSynthesisBtnClick")
end

function EquipFossilSynthesisUI.OnShow(parameter)
    local wnd = GUI.GetWnd("EquipFossilSynthesisUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, false)
    CL.SendNotify(NOTIFY.SubmitForm, "FormStrengSton", "GetComposeData")
end

function EquipFossilSynthesisUI.ReturnRefreshData()
    test("回调的刷新")
    local wnd = GUI.GetWnd("EquipFossilSynthesisUI")
    GUI.SetVisible(wnd, true)

    --注册监听事件
    EquipFossilSynthesisUI.Register()

    local CheckBindBtn = _gt.GetUI("CheckBindBtn")
    GUI.CheckBoxExSetCheck(CheckBindBtn, false)
    EquipFossilSynthesisUI.Init()

    test("EquipFossilSynthesisUI.ComposeData",inspect(EquipFossilSynthesisUI.ComposeData))
    --LuckValue = tonumber(EquipFossilSynthesisUI.ComposeData.LuckNum)
    LuckValue = tonumber(CL.GetIntCustomData("StrengStonLuck"))
    test("回调的刷新的LuckValue:",tostring(LuckValue))
    TipsContent = EquipFossilSynthesisUI.ComposeData.TipsInfo
    if next(EquipFossilSynthesisUI.ComposeData) then
        if next(EquipFossilSynthesisUI.ComposeData.ComposeConfig) then
            EquipFossilSynthesisUI.SetBagFossilTableData()
        end
    end
end

function EquipFossilSynthesisUI.Init()
    BagFossilTable = {}
    TipsContent = ""
    LastCheckBoxGuid = nil
    LastCheckBoxIndex = 0
    LuckValue = 0
    NowCheckStoneId = 0
    IsOnShowOpen = true
end

function EquipFossilSynthesisUI.SetBagFossilTableData()
    
    local ComposeConfig =EquipFossilSynthesisUI.ComposeData.ComposeConfig

    test("ComposeConfig",inspect(ComposeConfig))
    BagFossilTable = {}

    for k, v in pairs(ComposeConfig) do

        local NeedItemDB = DB.GetOnceItemByKey2(v.ItemName)

        local temp = {
            Id = 0,
            ItemName = k,
            NeedItem = v.ItemName,
            NeedItemName = NeedItemDB.Name,
            NeedItemId = NeedItemDB.Id,
            NeedItemIcon = NeedItemDB.Icon,
            NeedItemGrade = NeedItemDB.Grade,
            NeedItemShowType = NeedItemDB.ShowType,
            NeedItemLevel = NeedItemDB.Level,
            NeedItemInfo = NeedItemDB.Info,
            NeedItemAmount = 0,
            Icon = "",
            Name = "",
            Amount = 0,
            Grade = "",
            Info = "", --使用提示
            Tips = "", -- 物品介绍
            FailLoseNum = v.FailLoseNum,
            ItemNum = v.ItemNum,
            MoneyType = v.MoneyType,
            MoneyVal = v.MoneyVal,
            Success = v.Success,
            ShowType = "",
            Level = "",
        }
        local data = DB.GetOnceItemByKey2(k)
        local itemGuid = LD.GetItemGuidsById(data.Id) -- 获取物品所有的格子guid


        temp.Id = tonumber(data.Id)
        temp.Name = data.Name
        temp.Icon = data.Icon
        temp.Grade = data.Grade
        temp.Info = data.Info --使用提示
        temp.Tips = data.Tips -- 物品介绍
        temp.ShowType = data.ShowType
        temp.Level = data.Level
        if itemGuid ~= nil and itemGuid.Count > 0 then
            for i=0,itemGuid.Count-1 do -- 遍历所有的格子
                local amount= tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, itemGuid[i])) -- 此格子内的物品数量
                temp.Amount = temp.Amount + amount
            end
        else
            temp.Amount = 0
        end

        local NeedItemGuid = LD.GetItemGuidsById(NeedItemDB.Id) -- 获取物品所有的格子guid
        if NeedItemGuid ~= nil and  NeedItemGuid.Count >= 0 then
            for i=0,NeedItemGuid.Count-1 do -- 遍历所有的格子
                local amount= tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, NeedItemGuid[i])) -- 此格子内的物品数量
                temp.NeedItemAmount = temp.NeedItemAmount + amount
            end
        else
            temp.NeedItemAmount = 0
        end


        BagFossilTable[#BagFossilTable + 1] = temp
    end

    table.sort(BagFossilTable,function (a,b)
        if a.Id ~= b.Id then
            return a.Id < b.Id
        end
        if a.Grade ~= b.Grade then
            return a.Grade < b.Grade
        end
        return false
    end)

    test("BagFossilTable",inspect(BagFossilTable))


    local LeftFossilLoop = _gt.GetUI("LeftFossilLoop")
    GUI.LoopScrollRectSetTotalCount(LeftFossilLoop, #BagFossilTable)
    GUI.LoopScrollRectRefreshCells(LeftFossilLoop)
end

function EquipFossilSynthesisUI.CreateLeftFossilItem()
    local LeftFossilLoop = _gt.GetUI("LeftFossilLoop")
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(LeftFossilLoop) +1

    local FossilItem = GUI.CheckBoxExCreate(LeftFossilLoop, "FossilItem"..curIndex, "1800700030", "1800700040",0, 1, false, 400, 100)
    GUI.SetAnchor(FossilItem, UIAnchor.TopLeft)
    GUI.SetPivot(FossilItem, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(FossilItem, UCE.PointerClick, "EquipFossilSynthesisUI", "OnFossilItemClick")

    --IconBack
    local IconBack = GUI.ImageCreate(FossilItem, "IconBack", "1800400330", 10, 15, false, 80, 80)
    GUI.SetAnchor(IconBack, UIAnchor.TopLeft)
    GUI.SetPivot(IconBack, UIAroundPivot.TopLeft)

    --Icon
    local Icon = GUI.ImageCreate(IconBack, "Icon", "1900000000", 0, -1, false, 66, 66)
    GUI.SetAnchor(Icon, UIAnchor.Center)
    GUI.SetPivot(Icon, UIAroundPivot.Center)

    local AmountText = GUI.CreateStatic(Icon, "AmountText", "9999", 0, 18, 200, 50,"system",true,false)
    GUI.SetColor(AmountText, WhiteText)
    GUI.StaticSetFontSize(AmountText, 18)
    UILayout.SetSameAnchorAndPivot(AmountText, UILayout.BottomRight)
    GUI.StaticSetAlignment(AmountText, TextAnchor.MiddleRight)
    GUI.SetIsOutLine(AmountText,true)
    GUI.SetOutLine_Distance(AmountText,1)
    GUI.SetOutLine_Color(AmountText,BlackText)

    local FossilName = GUI.CreateStatic(FossilItem, "FossilName", "六个字的名字", 100, 5, 200, 50,"system",true,false)
    GUI.SetColor(FossilName, BlackText)
    GUI.StaticSetFontSize(FossilName, 20)
    UILayout.SetSameAnchorAndPivot(FossilName, UILayout.TopLeft)
    GUI.StaticSetAlignment(FossilName, TextAnchor.MiddleLeft)

    local TypeText = GUI.CreateStatic(FossilItem, "TypeText", "宝石类型信息", 100, 30, 200, 50,"system",true,false)
    GUI.SetColor(TypeText, BlackText)
    GUI.StaticSetFontSize(TypeText, 18)
    UILayout.SetSameAnchorAndPivot(TypeText, UILayout.TopLeft)
    GUI.StaticSetAlignment(TypeText, TextAnchor.MiddleLeft)

    local LevelText = GUI.CreateStatic(FossilItem, "LevelText", "宝石等级信息", 100, 55, 200, 50,"system",true,false)
    GUI.SetColor(LevelText, BlackText)
    GUI.StaticSetFontSize(LevelText, 18)
    UILayout.SetSameAnchorAndPivot(LevelText, UILayout.TopLeft)
    GUI.StaticSetAlignment(LevelText, TextAnchor.MiddleLeft)

    return FossilItem
end

function EquipFossilSynthesisUI.RefreshLeftFossilItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local TableData = BagFossilTable[index]

    if next(TableData) then
        --一级子类
        local IconBack = GUI.GetChild(item,"IconBack",false)
        local FossilName = GUI.GetChild(item,"FossilName",false)
        local TypeText = GUI.GetChild(item,"TypeText",false)
        local LevelText = GUI.GetChild(item,"LevelText",false)

        --二级子类
        local Icon = GUI.GetChild(IconBack,"Icon",false)

        --三级子类
        local AmountText = GUI.GetChild(Icon,"AmountText",false)

        GUI.ImageSetImageID(IconBack,QualityRes[TableData.Grade])
        GUI.ImageSetImageID(Icon,TableData.Icon)
        GUI.StaticSetText(AmountText,TableData.Amount)
        if TableData.Amount > 0  then
            GUI.SetColor(AmountText, WhiteText)
        else
            GUI.SetColor(AmountText, RedText)
        end
        GUI.StaticSetText(FossilName,TableData.Name)
        GUI.SetColor(FossilName, GradeColor[TableData.Grade])

        GUI.StaticSetText(TypeText,"类型：" .. TableData.ShowType)
        GUI.SetColor(TypeText,Yellow2Text)

        GUI.StaticSetText(LevelText,"等级需求：" .. TableData.Level .. "级")
        GUI.SetColor(LevelText,Yellow2Text)

        if IsOnShowOpen then
            GUI.CheckBoxExSetCheck(item, false)
            if index == 1 then
                EquipFossilSynthesisUI.RefreshCenterData(TableData)
                GUI.CheckBoxExSetCheck(item, true)
                LastCheckBoxGuid = tostring(guid)
                LastCheckBoxIndex = 1
                NowCheckStoneId = tonumber(TableData.Id)
            end
        end

        GUI.SetData(item,"Index",index)
    end
end

--刷新中间的数据
function EquipFossilSynthesisUI.RefreshCenterData(Table)
    test("刷新中间的数据")
    test("Table",inspect(Table))
    local TableData = Table
    --------------------------------------Start 左边信息 Start-------------------------------------
    local CurrentItem = _gt.GetUI("CurrentItem")
    local ItemIcon = GUI.GetChild(CurrentItem,"itemIcon",false)
    local ItemName = GUI.GetChild(CurrentItem,"Name",false)
    local TypeText = GUI.GetChild(CurrentItem,"TypeText",false)
    local NeedLevel = GUI.GetChild(CurrentItem,"NeedLevel",false)
    local AvailTxt = GUI.GetChild(CurrentItem,"AvailTxt",false)

    local NeedItemNum = GUI.GetChild(ItemIcon,"ItemNum",false)


    GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Icon,TableData.NeedItemIcon)
    GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Border,QualityRes[TableData.NeedItemGrade])

    GUI.StaticSetText(ItemName,TableData.NeedItemName)
    GUI.SetColor(ItemName, GradeColor[TableData.NeedItemGrade])

    GUI.StaticSetText(TypeText,"类型：" .. TableData.NeedItemShowType)
    GUI.SetColor(TypeText,Yellow2Text)

    GUI.StaticSetText(NeedLevel,"等级需求：" .. TableData.NeedItemLevel .. "级")
    GUI.SetColor(NeedLevel,Yellow2Text)


    GUI.StaticSetText(AvailTxt,TableData.NeedItemInfo)
    local TextWidth = GUI.StaticGetLabelPreferHeight(AvailTxt)
    GUI.SetHeight(AvailTxt,TextWidth)

    GUI.StaticSetText(NeedItemNum,TableData.NeedItemAmount.."/"..TableData.ItemNum)
    if TableData.NeedItemAmount >= TableData.ItemNum  then
        GUI.SetColor(NeedItemNum, WhiteText)
    else
        GUI.SetColor(NeedItemNum, RedText)
    end
    --------------------------------------End 左边信息 End-----------------------------------------


    --------------------------------------Start 右边信息 Start-------------------------------------
    local StrengthenItem = _gt.GetUI("StrengthenItem")
    local ItemIcon = GUI.GetChild(StrengthenItem,"itemIcon",false)
    local ItemName = GUI.GetChild(StrengthenItem,"Name",false)
    local TypeText = GUI.GetChild(StrengthenItem,"TypeText",false)
    local NeedLevel = GUI.GetChild(StrengthenItem,"NeedLevel",false)
    local AvailTxt = GUI.GetChild(StrengthenItem,"AvailTxt",false)

    local ItemNum = GUI.GetChild(ItemIcon,"ItemNum",false)


    GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Icon,TableData.Icon)
    GUI.ItemCtrlSetElementValue(ItemIcon,eItemIconElement.Border,QualityRes[TableData.Grade])

    GUI.StaticSetText(ItemName,TableData.Name)
    GUI.SetColor(ItemName, GradeColor[TableData.Grade])

    GUI.StaticSetText(TypeText,"类型：" .. TableData.ShowType)
    GUI.SetColor(TypeText,Yellow2Text)

    GUI.StaticSetText(NeedLevel,"等级需求：" .. TableData.Level .. "级")
    GUI.SetColor(NeedLevel,Yellow2Text)

    GUI.StaticSetText(AvailTxt,TableData.Info)
    local TextWidth = GUI.StaticGetLabelPreferHeight(AvailTxt)
    GUI.SetHeight(AvailTxt,TextWidth)

    --------------------------------------End 右边信息 End-------------------------------------


    --------------------------------------Start 底部成功率和消耗 Start-----------------------------------
    local RightSynthesisBg = _gt.GetUI("RightSynthesisBg")

    --一级子类
    local consumeBg = GUI.GetChild(RightSynthesisBg,"consumeBg",false)
    local RateText = GUI.GetChild(RightSynthesisBg,"rateText",false)
    local LuckyTxt = GUI.GetChild(RightSynthesisBg,"LuckyTxt",false)

    --二级子类
    local CoinIcon = GUI.GetChild(consumeBg,"coin",false)
    local CoinNum = GUI.GetChild(consumeBg,"num",false)
    local RateNum = GUI.GetChild(RateText,"rateNum",false)
    local LuckyValue = GUI.GetChild(LuckyTxt,"LuckyValue",false)

    local MoneyTypes = UIDefine.MoneyTypes[TableData.MoneyType]
    local MoneyNum = tonumber(tostring(CL.GetAttr(MoneyTypes)))

    GUI.StaticSetText(CoinNum,TableData.MoneyVal)
    if MoneyNum >= tonumber(TableData.MoneyVal) then
        GUI.SetColor(CoinNum,WhiteText)
    else
        GUI.SetColor(CoinNum,RedText)
    end
    local MoneyIcon = UIDefine.AttrIcon[MoneyTypes]
    GUI.ImageSetImageID(CoinIcon,MoneyIcon)

    GUI.StaticSetText(RateNum,(TableData.Success/100).."%")
    GUI.StaticSetText(LuckyValue,(LuckValue/100).."%")

    ----------------------------------------End 底部成功率和消耗 End-------------------------------------


end

function EquipFossilSynthesisUI.CreateFossilSynthesisItem(parent,name,x,y,title)
    local itemBg = GUI.ImageCreate(parent, name, "1801100030", x, y, false, 270, 250)
    UILayout.SetSameAnchorAndPivot(itemBg, UILayout.TopLeft)

    local title = GUI.CreateStatic(itemBg, "title", title, 10, 5, 200, 30)
    GUI.SetColor(title, UIDefine.BrownColor)
    GUI.StaticSetFontSize(title, 22)

    local ItemIcon = GUI.ItemCtrlCreate(itemBg, "itemIcon", UIDefine.ItemIconBg2[1], 10, 45,80,80)
    local ItemNum = GUI.CreateStatic(ItemIcon, "ItemNum", "", -8, 8, 200, 50,"system",true,false)
    GUI.SetColor(ItemNum, WhiteText)
    GUI.StaticSetFontSize(ItemNum, 19)
    UILayout.SetSameAnchorAndPivot(ItemNum, UILayout.BottomRight)
    GUI.StaticSetAlignment(ItemNum, TextAnchor.MiddleRight)
    GUI.SetIsOutLine(ItemNum,true)
    GUI.SetOutLine_Distance(ItemNum,1)
    GUI.SetOutLine_Color(ItemNum,BlackText)


    local Name = GUI.CreateStatic(itemBg, "Name", "名字", 100, 45, 150, 30,"system",true,false)
    GUI.SetColor(Name, UIDefine.BrownColor)
    GUI.StaticSetFontSize(Name, 22)
    UILayout.SetSameAnchorAndPivot(Name, UILayout.TopLeft)

    local TypeText = GUI.CreateStatic(itemBg, "TypeText", "类型信息", 100, 75, 150, 30,"system",true,false)
    GUI.SetColor(TypeText, Yellow2Text)
    GUI.StaticSetFontSize(TypeText, 20)
    UILayout.SetSameAnchorAndPivot(TypeText, UILayout.TopLeft)


    local NeedLevel = GUI.CreateStatic(itemBg, "NeedLevel", "等级需求信息", 100, 105, 150, 30,"system",true,false)
    GUI.SetColor(NeedLevel, Yellow2Text)
    GUI.StaticSetFontSize(NeedLevel, 20)
    UILayout.SetSameAnchorAndPivot(NeedLevel, UILayout.TopLeft)

    local RuleBg = GUI.ImageCreate(itemBg, "RuleBg", "1801100040", 15, 145)
    local rule = GUI.CreateStatic(RuleBg, "rule", "效用", 2, 0, 280, 30)
    GUI.SetColor(rule, Yellow4Text)
    GUI.StaticSetFontSize(rule, 20)

    local AvailTxt = GUI.CreateStatic(itemBg, "AvailTxt", "效用信息", 18, 180, 250, 40,"system",true,false)
    GUI.SetColor(AvailTxt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(AvailTxt, UIDefine.FontSizeM)
    UILayout.SetSameAnchorAndPivot(AvailTxt, UILayout.TopLeft)
    return itemBg
end

--选择Item点击事件
function EquipFossilSynthesisUI.OnFossilItemClick(guid)
    local FossilItem = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(FossilItem,"Index"))
    local LeftFossilLoop = _gt.GetUI("LeftFossilLoop")
    GUI.LoopScrollRectSrollToCell(LeftFossilLoop,index-1,100)
    if LastCheckBoxGuid ~= tostring(guid) then
        if LastCheckBoxGuid ~= nil then
            local LastCheckBox = GUI.GetByGuid(LastCheckBoxGuid)
            GUI.CheckBoxExSetCheck(LastCheckBox, false)
        end
    end
    GUI.CheckBoxExSetCheck(FossilItem, true)
    LastCheckBoxGuid = tostring(guid)
    LastCheckBoxIndex = index
    NowCheckStoneId = tonumber(BagFossilTable[index].Id)

    --刷新中间数据
    EquipFossilSynthesisUI.RefreshCenterData(BagFossilTable[index])
end

--单个合成
function EquipFossilSynthesisUI.OnSynthesisBtnClick()
    local CheckBindBtn = _gt.GetUI("CheckBindBtn")
    local IsCheck = GUI.CheckBoxExGetCheck(CheckBindBtn)
    local BindMode = 0
    if IsCheck then
        BindMode = 1
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormStrengSton", "Compose",NowCheckStoneId,BindMode)
end

--全部合成
function EquipFossilSynthesisUI.OnAllSynthesisBtnClick()
    local CheckBindBtn = _gt.GetUI("CheckBindBtn")
    local IsCheck = GUI.CheckBoxExGetCheck(CheckBindBtn)
    local BindMode = 0
    if IsCheck then
        BindMode = 1
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormStrengSton", "ComposeAll",NowCheckStoneId,BindMode)
end

function EquipFossilSynthesisUI.OnTipsBtnClick()
    local RightSynthesisBg = _gt.GetUI("RightSynthesisBg")
    local TipsBtn = GUI.GetChild(RightSynthesisBg,"TipsBtn",false)

    local TipsBg = GUI.TipsCreate(TipsBtn, "Tips", 20, 150, 500, 20)
    SetSameAnchorAndPivot(TipsBg, UILayout.TopRight)
    GUI.SetIsRemoveWhenClick(TipsBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(TipsBg),false)

    local TipsText = GUI.CreateStatic(TipsBg,"TipsText",TipsContent,0,0,460,30,"system", true)
    GUI.StaticSetFontSize(TipsText,20)
    SetSameAnchorAndPivot(TipsText, UILayout.Center)
    GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
    local desPreferHeight = GUI.StaticGetLabelPreferHeight(TipsText)
    GUI.SetHeight(TipsText,desPreferHeight)
end


--合成后回调的刷新
function EquipFossilSynthesisUI.AfterReturnRefresh()
    test("合成后回调的刷新")
    LuckValue = tonumber(CL.GetIntCustomData("StrengStonLuck"))
    test("合成后回调的刷新的LuckValue:",tostring(LuckValue))
    IsOnShowOpen = false
    EquipFossilSynthesisUI.SetBagFossilTableData()
    EquipFossilSynthesisUI.RefreshCenterData(BagFossilTable[LastCheckBoxIndex])
end

function EquipFossilSynthesisUI.OnExit()
    GUI.CloseWnd("EquipFossilSynthesisUI")
    EquipFossilSynthesisUI.UnRegister()
    local LeftFossilLoop = _gt.GetUI("LeftFossilLoop")
    GUI.LoopScrollRectSrollToCell(LeftFossilLoop,0,2000)
end

function EquipFossilSynthesisUI.Register()
    CL.RegisterMessage(GM.RefreshBag,"EquipFossilSynthesisUI","AfterReturnRefresh")
end

function EquipFossilSynthesisUI.UnRegister()
    CL.UnRegisterMessage(GM.RefreshBag,"EquipFossilSynthesisUI","AfterReturnRefresh")
end

