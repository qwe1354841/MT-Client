local TradeRoadsUI = {}
_G.TradeRoadsUI = TradeRoadsUI

local _gt = UILayout.NewGUIDUtilTable()
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot

local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
---------------------------------------------------------颜色配置-------------------------------------------------------
local WhiteColor = UIDefine.WhiteColor
local OrangeColor = Color.New(244/255,169/255,96/255,220/255)
local BrownColor = UIDefine.Brown4Color
local OutLineDistance = UIDefine.OutLineDistance
local OutLine_BrownColor = UIDefine.OutLine_BrownColor
local QualityRes = UIDefine.ItemIconBg
-----------------------------------------------------------end----------------------------------------------------------

-------------------------------------------------------全局变量配置-------------------------------------------------------
local AddAttendantsSwitch = 0 --选择护卫是否显示添加图片的开关: 0-关 1-开
local AttendantStar = 6 --侍从星级
local TradeRoadsStatus = 0 --开启贸易状态 0:未开启 1:开启
local TradeRoadsStatusIndex1 = 1
local TradeRoadsStatusIndex2 = 1
local TradeRoadsStatusNowTime = 0
local TradeRoadsStatusStartTime = 0
local TradeRoadsStatusEndTime = 0
local ExtraCompletion = 0
local RefreshPropLoopCount = 4 --选择物品的一行数量
local ShowTipsStatus = 0
local TradeCompletenessNumber = 0
local Version = nil --版本号
local LastCheckBoxGuid = nil
local LastRightCheckBoxGuid = nil
local LastTableItemPlaceName = nil
local TradeCompletenessValues = nil
local LastClickIndex1 = nil --上一个选择的右边页签
local LastClickIndex2 = nil --上一个选择的左边地点
local LastClickIndex3 = nil --上一个选择的贸易任务
local LastAttendantsId = nil
local LastAttendantsItemGuid = nil
local TradeRoadsStatusResidueTime = nil
local LastAddAttendantsIconGuid = nil
local TradeRoadsUITips = nil
local Voucher = nil --贸易兑换物KeyName
local MapId = nil --前往地图的Id
local MapPlaceX = nil --前往地图的X坐标
local MapPlaceY = nil --前往地图的Y坐标
-----------------------------------------------------------end----------------------------------------------------------

--------------------------------------------------------表单配置--------------------------------------------------------
--侍从类型: 物攻、法攻、治疗、控制、辅助
local GuardType = {"1800707170","1800707180","1800707190","1800707210","1800707200"}

--侍从品质: SSR、SR、R、N
local Quality = {"1801205100","1801205110","1801205120","1801205130","1801205130"}

--人物特效表 从二星开始
local RoleEffectTable = {10,11,12,13,14}

local TradeRightTable = {}
local TradeLeftTable = {} --左边滚动框列表
local DestroyRoleEffectTable = {}
local SelectPropTable = {}
local SelectSubmitTableData = {}
local RefreshPropTable = {}
local RefreshShowPropTable = {} --用于刷新右下角选择的物品表单
local RefreshAttendantsTable = {} --用于刷新右下角选择的侍从护卫表单
local SelectPropTableClick = {}
local SelectAttendantsTable = {}
local SelectAttendantsTableClick = {}
local AddAttendantsTable = {}
local SubmitAllDataTable = {} --选择后提交的表单的格式
local TradeRoadsChangeTable = {} --改便数据的表单
local TradeRoadsDataTable = {} --固定数据的表单
local EventStatusTable = {} --事件表单
local SetSubmitSelectDataTable = {} --用于创建客户端的提交内容的表
local SubmitSelectDataTable = {}
local CenterBottomTaskTable = {} --中下任务表单
local RecommendGuardTable = {}
---------------------------------------------------------end------------------------------------------------------------

function TradeRoadsUI.Main(parameter)
    local panel = GUI.WndCreateWnd("TradeRoadsUI" , "TradeRoadsUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "贸    易","TradeRoadsUI","OnExit");
    _gt.BindName(panelBg, "panelBg")

    --积分奖励最终地点Tips按钮
    local PlaceInfoBtn = GUI.ButtonCreate(panelBg,"PlaceInfoBtn", "1800702030",70,-40, Transition.ColorTint);
    SetSameAnchorAndPivot(PlaceInfoBtn, UILayout.BottomLeft)
    GUI.RegisterUIEvent(PlaceInfoBtn, UCE.PointerClick, "TradeRoadsUI", "OnPlaceInfoBtnClick")

    --左边滚动标签
    local TradeLeftLoop =
    GUI.LoopScrollRectCreate(
            panelBg,
            "TradeLeftLoop",
            65,
            65,
            214,
            500,
            "TradeRoadsUI",
            "CreateTradeLeftItem",
            "TradeRoadsUI",
            "RefreshTradeLeftItem",
            0,
            false,
            Vector2.New(214, 65),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(TradeLeftLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(TradeLeftLoop, TextAnchor.UpperCenter)
    _gt.BindName(TradeLeftLoop, "TradeLeftLoop")
    GUI.LoopScrollRectSetTotalCount(TradeLeftLoop, #TradeLeftTable)
    GUI.LoopScrollRectRefreshCells(TradeLeftLoop)
    GUI.ScrollRectSetChildSpacing(TradeLeftLoop, Vector2.New(0, 8))


    --右边页面
    local RightGroup = GUI.GroupCreate(panelBg,"RightGroup",-80, 40,830,GUI.GetHeight(panelBg),false)
    SetSameAnchorAndPivot(RightGroup, UILayout.Right)

    --右上角奖励组
    local TopRightGroup = GUI.GroupCreate(RightGroup,"TopRightGroup",0, 5,GUI.GetWidth(RightGroup),120,false)
    SetSameAnchorAndPivot(TopRightGroup, UILayout.TopRight)

    local TopRightBg = GUI.ImageCreate(TopRightGroup,"TopRightBg","1800201200",0,16,false,GUI.GetWidth(TopRightGroup),GUI.GetHeight(TopRightGroup)+20,false)
    SetSameAnchorAndPivot(TopRightBg, UILayout.Center)

    --进度条组
    local TopRightGroup2 = GUI.GroupCreate(TopRightGroup,"TopRightGroup2",0, 5,720,120,false)
    SetSameAnchorAndPivot(TopRightGroup2, UILayout.Center)

    local LeftNumericalBg = GUI.ImageCreate(TopRightGroup2,"LeftNumericalBg","1801207020",-30,40,false)
    SetSameAnchorAndPivot(LeftNumericalBg, UILayout.TopLeft)

    local LeftNumericalTxt = GUI.CreateStatic(LeftNumericalBg,"LeftNumericalTxt","",70,5,120,30,"system",true,false)
    _gt.BindName(LeftNumericalTxt,"LeftNumericalTxt")
    GUI.StaticSetFontSize(LeftNumericalTxt,UIDefine.FontSizeS)
    GUI.StaticSetAlignment(LeftNumericalTxt,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(LeftNumericalTxt, UILayout.Top)
    GUI.SetColor(LeftNumericalTxt, BrownColor)

    --剩余时间
    local LeftNumericalNum = GUI.CreateStatic(LeftNumericalBg,"LeftNumericalNum","",70,20,120,30,"system",true,false)
    _gt.BindName(LeftNumericalNum,"LeftNumericalNum")
    GUI.StaticSetFontSize(LeftNumericalNum,UIDefine.FontSizeS)
    GUI.StaticSetAlignment(LeftNumericalNum,TextAnchor.MiddleCenter)
    SetSameAnchorAndPivot(LeftNumericalNum, UILayout.Bottom)
    GUI.SetColor(LeftNumericalNum, BrownColor)

    --积分背景进度条
    local sliderBg = GUI.ImageCreate(TopRightGroup2, "sliderBg", "1800607190", 0, 5, false, 580, 18)
    SetSameAnchorAndPivot(sliderBg, UILayout.Right)
    _gt.BindName(sliderBg,"sliderBg")

    --积分奖励最终地点Tips按钮
    local InfoBtn = GUI.ButtonCreate(sliderBg,"infoBtn", "1800602230",-15,30, Transition.ColorTint);
    SetSameAnchorAndPivot(InfoBtn, UILayout.Right)
    GUI.RegisterUIEvent(InfoBtn, UCE.PointerClick, "TradeRoadsUI", "OnInfoBtnClick")

    --积分绿色进度条
    local fill = GUI.ImageCreate(sliderBg, "fill", "1800607200", 0, 0, false, 0, 18)
    SetSameAnchorAndPivot(fill, UILayout.Left)

    local handle = GUI.ImageCreate(fill, "handle", "1800607210", 10, 0,false,20,20,false)
    SetSameAnchorAndPivot(handle, UILayout.Right)


    --摆动动画图标
    local SwingImage = GUI.ImageCreate(handle, "SwingImage", "1801409190", 0, -40,false,76,76,false)
    SetSameAnchorAndPivot(SwingImage, UILayout.Center)
    _gt.BindName(SwingImage,"SwingImage")

    --中下角列表底板
    local _ActLstBack = GUI.ImageCreate(RightGroup, "_ActLstBack", "1800400340", 0,15, false, GUI.GetWidth(RightGroup)/2 -10, 370)
    SetSameAnchorAndPivot(_ActLstBack, UILayout.Left)

    local bar = GUI.ImageCreate(_ActLstBack, "bar", "1800700070", 0, -170, false, GUI.GetWidth(_ActLstBack), 42)
    SetSameAnchorAndPivot(text, UILayout.TopRight)
    local text = GUI.CreateStatic(bar, "text", "可选择的任务", 5, 0, 150, 30, "system", true)
    GUI.SetColor(text, UIDefine.BrownColor)
    GUI.StaticSetFontSize(text, 22)
    SetSameAnchorAndPivot(text, UILayout.Left)

    --中下任务列表
    local TradeRightLoop =
    GUI.LoopScrollRectCreate(
            _ActLstBack,
            "TradeRightLoop",
            -2,
            40,
            400,
            320,
            "TradeRoadsUI",
            "CreateTradeRightItem",
            "TradeRoadsUI",
            "RefreshTradeRightItem",
            0,
            false,
            Vector2.New(400, 100),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(TradeRightLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(TradeRightLoop, TextAnchor.UpperCenter)
    _gt.BindName(TradeRightLoop, "TradeRightLoop")
    GUI.LoopScrollRectSetTotalCount(TradeRightLoop, 0)
    GUI.LoopScrollRectRefreshCells(TradeRightLoop)

    GUI.ScrollRectSetChildSpacing(TradeRightLoop, Vector2.New(0, 3))

    local StartBtn = GUI.ButtonCreate(RightGroup,"StartBtn","1800402090", 0, -77, Transition.ColorTint, "开始贸易", 200, 47, false)
    _gt.BindName(StartBtn,"StartBtn")
    GUI.SetIsOutLine(StartBtn, true)
    GUI.ButtonSetTextFontSize(StartBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(StartBtn, WhiteColor)
    GUI.SetOutLine_Color(StartBtn,UIDefine.OutLine_GreenColor)
    GUI.SetOutLine_Distance(StartBtn,OutLineDistance)
    GUI.RegisterUIEvent(StartBtn, UCE.PointerClick, "TradeRoadsUI", "OnStartBtnClick")
    SetSameAnchorAndPivot(StartBtn, UILayout.BottomRight)

    --右下提交物品列表底板
    local CenterListBack = GUI.ImageCreate(RightGroup, "CenterListBack", "1800400340", 0,15, false, GUI.GetWidth(RightGroup)/2 -10, 370)
    SetSameAnchorAndPivot(CenterListBack, UILayout.Right)

    local bar = GUI.ImageCreate(CenterListBack, "bar", "1800700070", 0, -170, false, GUI.GetWidth(_ActLstBack), 42)

    local text = GUI.CreateStatic(bar, "text", "选择贸易物品", -10, 0, 150, 30, "system", true)
    GUI.SetColor(text, UIDefine.BrownColor)
    GUI.StaticSetFontSize(text, 22)
    SetSameAnchorAndPivot(text, UILayout.Left)

    --右下角贸易物品
    local PropLoopScroll =
    GUI.LoopScrollRectCreate(
            CenterListBack,
            "PropLoopScroll",
            -20,
            50,
            360,
            110,
            "TradeRoadsUI",
            "CreatePropItem",
            "TradeRoadsUI",
            "RefreshPropItem",
            0,
            true,
            Vector2.New(120, 90),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(PropLoopScroll, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(PropLoopScroll, TextAnchor.UpperCenter)
    _gt.BindName(PropLoopScroll, "PropLoopScroll")
    GUI.LoopScrollRectSetTotalCount(PropLoopScroll, 0)
    GUI.LoopScrollRectRefreshCells(PropLoopScroll)

    local bar2 = GUI.ImageCreate(CenterListBack, "bar2", "1800700070", 0, 0, false, GUI.GetWidth(_ActLstBack), 42)
    local text = GUI.CreateStatic(bar2, "text", "选择护送侍从", -10, 5, 180, 30, "system", true)
    GUI.SetColor(text, UIDefine.BrownColor)
    GUI.StaticSetFontSize(text, 22)
    SetSameAnchorAndPivot(text, UILayout.Left)

    --选择侍从提示
    local TipsText = GUI.CreateStatic(bar2,"TipsText","",20, 45,360,70)
    GUI.SetColor(TipsText, UIDefine.BrownColor)
    GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(text, UILayout.TopLeft)
    _gt.BindName(TipsText,"TipsText")
    GUI.StaticSetFontSize(TipsText, 20)

    --右下角侍从护卫
    local AttendantsLoopScroll =
    GUI.LoopScrollRectCreate(
            CenterListBack,
            "AttendantsLoopScroll",
            -20,
            0,
            360,
            120,
            "TradeRoadsUI",
            "CreateAttendantsItem",
            "TradeRoadsUI",
            "RefreshAttendantsItem",
            0,
            true,
            Vector2.New(120, 90),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(AttendantsLoopScroll, UILayout.BottomLeft)
    GUI.ScrollRectSetAlignment(AttendantsLoopScroll, TextAnchor.UpperCenter)
    _gt.BindName(AttendantsLoopScroll, "AttendantsLoopScroll")
    GUI.LoopScrollRectSetTotalCount(AttendantsLoopScroll, 0)
    GUI.LoopScrollRectRefreshCells(AttendantsLoopScroll)

    --贸易品质
    local TradeCompletenessBtn = GUI.ButtonCreate(panelBg, "TradeCompletenessBtn", "1800702030", 80, -40, Transition.ColorTint, "")
    SetSameAnchorAndPivot(TradeCompletenessBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(TradeCompletenessBtn, UCE.PointerClick, "TradeRoadsUI", "OnTradeCompletenessBtnClick")

    local TradeCompletenessImage = GUI.ImageCreate(TradeCompletenessBtn, "TradeCompletenessImage", "1800208200", 40,0, false)
    SetSameAnchorAndPivot(TradeCompletenessImage, UILayout.Right)
    _gt.BindName(TradeCompletenessImage,"TradeCompletenessImage")

    local TradeCompleteness = GUI.CreateStatic(TradeCompletenessImage,"TradeCompleteness","贸易品质:",-165, 0,160,40)
    SetSameAnchorAndPivot(TradeCompleteness, UILayout.Right)
    GUI.StaticSetFontSize(TradeCompleteness,24)
    GUI.StaticSetIsGradientColor(TradeCompleteness,true)
    GUI.StaticSetGradient_ColorTop(TradeCompleteness,Color.New(255/255,253/255,179/255,255/255))
    GUI.StaticSetGradient_ColorBottom(TradeCompleteness,Color.New(255/255,253/255,179/255,255/255))
    --设置描边
    GUI.SetIsOutLine(TradeCompleteness,true)
    GUI.SetOutLine_Distance(TradeCompleteness,2)
    GUI.SetOutLine_Color(TradeCompleteness,Color.New(176/255,77/255,11/255,255/255))

    local TradeCompletenessValue = GUI.CreateStatic(TradeCompleteness,"TradeCompletenessValue","0%",-70, 2,120,40,"system",true,false)
    GUI.SetColor(TradeCompletenessValue, UIDefine.GreenColor)
    GUI.StaticSetAlignment(TradeCompletenessValue, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(TradeCompletenessValue, UIDefine.FontSizeXL)
    SetSameAnchorAndPivot(TradeCompletenessValue, UILayout.Right)

end

function TradeRoadsUI.OnShow(parameter)
    local wnd = GUI.GetWnd("TradeRoadsUI");
    if wnd == nil then
        return
    end
    TradeRoadsUI.Init()
    GUI.SetVisible(wnd, true)
    if parameter ~= nil then
        local index1, index2 = UIDefine.GetParameterStr(parameter)
        LastClickIndex1 = tonumber(index1)
        LastClickIndex2 = tonumber(index2)
    end

    CL.SendNotify(NOTIFY.SubmitForm,"FormTrade","GetData")
    TradeRoadsUI.UnRegisterPropItem()
end

function TradeRoadsUI.Init()
    LastClickIndex1 = 1
    LastClickIndex2 = 1
    LastClickIndex3 = 1
    AddAttendantsSwitch = 0
    ExtraCompletion = 0
    TradeRoadsStatus = 0
    TradeRoadsStatusIndex1 = 1
    TradeRoadsStatusIndex2 = 1
    TradeRoadsStatusNowTime = 0
    TradeRoadsStatusStartTime = 0
    TradeRoadsStatusEndTime = 0
    ShowTipsStatus = 0
    MapId = 0
    MapPlaceX = 0
    MapPlaceY = 0
    TradeCompletenessNumber = 0
    LastCheckBoxGuid = nil
    LastRightCheckBoxGuid = nil
    TradeCompletenessValues = nil
    LastTableItemPlaceName = nil
    LastAttendantsId = nil
    LastAttendantsItemGuid = nil
    LastAddAttendantsIconGuid = nil
    TradeRoadsUITips = nil
    Version = nil
    Voucher = nil
    SelectPropTable = {}
    SelectPropTableClick = {}
    SelectAttendantsTable = {}
    SelectAttendantsTableClick = {}
    AddAttendantsTable = {}
    SubmitAllDataTable = {}
    TradeRoadsChangeTable = {}
    TradeRoadsDataTable = {}
    EventStatusTable = {}
    SetSubmitSelectDataTable = {}
    SubmitSelectDataTable = {}
    CenterBottomTaskTable = {}
    RecommendGuardTable = {}
    TradeRightTable = {}
end


function TradeRoadsUI.RefreshAllItem()
    test("服务器回调的刷新方法")
    TradeRoadsChangeTable = TradeRoadsUI.TradeRoadsChangeTable --改便数据的表单
    TradeRoadsDataTable = TradeRoadsUI.TradeRoadsDataTable --固定数据的表单
    EventStatusTable = TradeRoadsUI.EventStatusTable --奖励事件图标
    test("TradeRoadsChangeTable--改便数据的表单:",inspect(TradeRoadsChangeTable))
    test("TradeRoadsDataTable--固定数据的表单:",inspect(TradeRoadsDataTable))
    test("EventStatusTable--奖励事件图标:",inspect(EventStatusTable))
    TradeRoadsStatus = TradeRoadsUI.Status
    test("TradeRoadsStatus---贸易状态:",tostring(TradeRoadsStatus))
    Voucher = TradeRoadsUI.Voucher
    TradeRoadsUITips = TradeRoadsUI.Tips
    ExtraCompletion = TradeRoadsUI.ExtraCompletion
    test("ExtraCompletion---额外贸易品质:",tostring(ExtraCompletion))
    TradeRoadsStatusIndex1 = TradeRoadsUI.StartTabIndex
    TradeRoadsStatusIndex2 = TradeRoadsUI.StartPlaceIndex
    SubmitSelectDataTable = TradeRoadsUI.SubmitSelectDataTable
    test("SubmitSelectDataTable",inspect(SubmitSelectDataTable))
    TradeRoadsStatusStartTime = tonumber(TradeRoadsUI.StartTime)
    TradeRoadsStatusEndTime = tonumber(TradeRoadsUI.EndTime)


    local StartBtn = _gt.GetUI("StartBtn")
    if TradeRoadsStatus == 1 then
        LastClickIndex1 = TradeRoadsStatusIndex1
        LastClickIndex2 = TradeRoadsStatusIndex2
        ShowTipsStatus = 0
        GUI.ButtonSetText(StartBtn,"贸易中")
        GUI.ButtonSetShowDisable(StartBtn, false)

        if SubmitSelectDataTable[LastClickIndex1] ~= nil then
            if SubmitSelectDataTable[LastClickIndex1][LastClickIndex2] ~= nil then
                local TableData = SubmitSelectDataTable[LastClickIndex1][LastClickIndex2]
                local PlaceName = TradeRoadsDataTable.Main[LastClickIndex1].Place[LastClickIndex2]
                test("TableData",inspect(TableData))
                for k, v in ipairs(TableData) do
                    table.remove(TradeRoadsChangeTable[PlaceName],k)
                    table.insert(TradeRoadsChangeTable[PlaceName],k,v.OrderName)


                    table.remove(CenterBottomTaskTable,k)
                    local TableData = TradeRoadsDataTable.Order[v.OrderName]
                    local temp = {}
                    for i, v in pairs(TableData) do
                        temp[i] = v
                    end
                    table.insert(CenterBottomTaskTable,k,temp)
                end

            end
        end
        test("CenterBottomTaskTable",inspect(CenterBottomTaskTable))
    elseif TradeRoadsStatus == 2 then
        GUI.ButtonSetText(StartBtn,"贸易完成")
        GUI.ButtonSetShowDisable(StartBtn, false)
    else
        local sliderBg = _gt.GetUI("sliderBg")
        local fill = GUI.GetChild(sliderBg,"fill",false)
        GUI.SetWidth(fill,0)
        GUI.ButtonSetText(StartBtn,"开始贸易")
        GUI.ButtonSetShowDisable(StartBtn, true)
    end
    Version = TradeRoadsUI.Version
    local MainTable = TradeRoadsDataTable.Main
    if #TradeRightTable ~= #MainTable then
        test("右边创建页签")
        for i = 1, #MainTable do
            local temp = {MainTable[i].TradeName,"OnRoadPageBtn"..i,"OnRoadPageBtnClick"}
            TradeRightTable[#TradeRightTable + 1] = temp
            TradeLeftTable[#TradeLeftTable + 1] = MainTable[i].Place
        end
        --右边创建页签
        UILayout.CreateRightTab(TradeRightTable, "TradeRoadsUI",true)
    end


    if next(SubmitSelectDataTable) then
        TradeRoadsUI.SetReturnSubmitItemData(SubmitSelectDataTable,"服务器回调的刷新方法")
    else
        test("重置数据")
        if RefreshPropTable[LastClickIndex1] == nil then
            RefreshPropTable[LastClickIndex1] = {}
        end
        RefreshPropTable[LastClickIndex1][LastClickIndex2] = {}

        if RefreshAttendantsTable[LastClickIndex1] == nil then
            RefreshAttendantsTable[LastClickIndex1] = {}
        end
        RefreshAttendantsTable[LastClickIndex1][LastClickIndex2] = {}
    end
    TradeRoadsUI.OnRoadPageBtnClick()
end

--配置表单的编辑
function TradeRoadsUI.SetSubmitSelectDataTable(index1,index2,index3,TableData)
    test("配置表单的编辑:TableData",index1,index2,index3,inspect(TableData))
    local PlaceName = TradeRoadsDataTable.Main[index1].Place[index2]
    test("TableData",inspect(TableData))
    if TableData.OrderName ~= nil then
        table.remove(TradeRoadsChangeTable[PlaceName],index3)
        table.insert(TradeRoadsChangeTable[PlaceName],index3,TableData.OrderName)

        table.remove(CenterBottomTaskTable,index3)
        local TableData2 = TradeRoadsDataTable.Order[TableData.OrderName]
        local temp = {}
        for i, v in pairs(TableData2) do
            temp[i] = v
        end
        table.insert(CenterBottomTaskTable,index3,temp)
    end
    if next(TableData) then
        if SubmitSelectDataTable[index1] == nil then
            SubmitSelectDataTable[index1] = {}
        end
        if SubmitSelectDataTable[index1][index2] == nil then
            SubmitSelectDataTable[index1][index2] = {}
        end
        SubmitSelectDataTable[index1][index2][index3] = {}
        SubmitSelectDataTable[index1][index2][index3] = TableData
    end

    TradeRoadsUI.SetReturnSubmitItemData(SubmitSelectDataTable,"配置表单的编辑")

    TradeRoadsUI.SetCenterLoopData()

    test("CenterBottomTaskTable",inspect(CenterBottomTaskTable))
    --中下任务刷新
    local TradeRightLoop = _gt.GetUI("TradeRightLoop")
    GUI.LoopScrollRectSetTotalCount(TradeRightLoop, #CenterBottomTaskTable)
    GUI.LoopScrollRectRefreshCells(TradeRightLoop)

    --贸易物品刷新
    local RefreshNum = math.floor(#CenterBottomTaskTable[LastClickIndex3].NeedItem / 2)
    if RefreshShowPropTable[LastClickIndex1] ~= nil then
        if RefreshShowPropTable[LastClickIndex1][LastClickIndex2] ~= nil then
            if RefreshShowPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] ~= nil then
                if #RefreshShowPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] > math.floor(#CenterBottomTaskTable[LastClickIndex3].NeedItem / 2) then
                    RefreshNum = #RefreshShowPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3]
                end
            end
        end
    end
    local PropLoopScroll = _gt.GetUI("PropLoopScroll")
    if RefreshShowPropTable[LastClickIndex1] ~= nil then
        if RefreshShowPropTable[LastClickIndex1][LastClickIndex2] ~= nil then
            if RefreshShowPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] ~= nil then
                GUI.LoopScrollRectSetTotalCount(PropLoopScroll,RefreshNum)
            end
        end
    end
    GUI.LoopScrollRectRefreshCells(PropLoopScroll)

    --选择侍从护卫提示
    local TipsText = _gt.GetUI("TipsText")
    local AttendantsLoopScroll = _gt.GetUI("AttendantsLoopScroll")
    if RefreshAttendantsTable[LastClickIndex1] ~= nil then
        if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2] ~= nil then
            GUI.LoopScrollRectSetTotalCount(AttendantsLoopScroll, CenterBottomTaskTable[LastClickIndex3].EscortGuardNum)
        end
    end
    GUI.LoopScrollRectRefreshCells(AttendantsLoopScroll)

end

--设置贸易品质
function TradeRoadsUI.SetCompleteness(Table)
    local panelBg = _gt.GetUI("panelBg")
    local PlaceName = TradeLeftTable[LastClickIndex1][LastClickIndex2]
    local TableData = TradeRoadsDataTable.Place[PlaceName]
    local SumCompletion = TableData.SumCompletion
    local TradeCompletenessImage = _gt.GetUI("TradeCompletenessImage")
    local TradeCompleteness = GUI.GetChild(TradeCompletenessImage,"TradeCompleteness",false)
    local TradeCompletenessValue = GUI.GetChild(TradeCompleteness,"TradeCompletenessValue",false)
    local ItemDB = DB.GetOnceItemByKey2(Voucher)
    GUI.ImageSetImageID(TradeCompletenessImage,ItemDB.Icon)

    local CompletenessValue = 0
    local GoodsCompletion = 0
    local GuardCompletion = 0
    if Table[LastClickIndex1] ~= nil then
        if Table[LastClickIndex1][LastClickIndex2] ~= nil then
            for k, v in pairs(Table[LastClickIndex1][LastClickIndex2]) do
                GoodsCompletion = 0
                GuardCompletion = 0
                if v.GoodsCompletion ~= nil then
                    GoodsCompletion = tonumber(v.GoodsCompletion)
                end
                if v.GuardCompletion ~= nil then
                    GuardCompletion = tonumber(v.GuardCompletion)
                end
                CompletenessValue = CompletenessValue + GuardCompletion + GoodsCompletion
            end
        end
    end
    local voucher_config = TableData.VoucherNum  or 0
    local tmp_str = [[
    local RealCompletion =]]..(CompletenessValue + ExtraCompletion)..[[
    local SumCompletion = ]]..TableData.SumCompletion..[[
    ]]
    local voucher_num = assert(loadstring(tmp_str.." return " .. voucher_config))()
    TradeCompletenessNumber = voucher_num
    TradeCompletenessValues = TradeRoadsUI.TextColorStyleSet(tostring(math.ceil((CompletenessValue + ExtraCompletion)/SumCompletion*100) .."%"))
    GUI.StaticSetText(TradeCompletenessValue,TradeCompletenessValues)
end

--表单配置
function TradeRoadsUI.SetReturnSubmitItemData(SubmitSelectDataTable,Tips)
    test(Tips..": SubmitSelectDataTable",inspect(SubmitSelectDataTable))
    --设置时间
    TradeRoadsUI.SetCompleteness(SubmitSelectDataTable)
    local SwingImage = _gt.GetUI("SwingImage")

    local SwingData = TweenData.New()
    SwingData.Type = GUITweenType.DOLocalRotate
    SwingData.Duration = 0.7
    SwingData.From = Vector3.New(0,0,-30)
    SwingData.To = Vector3.New(0,0,30)

    local Keyframe = ""
    if LastClickIndex1 == 1 then
        Keyframe ="((0,0,136,0,0.03305054),(0.1646124,0.1646124,0,0.2180756,0.1075352),(0.7839383,0.7839383,0,0.5029666,0.208173),(0.6694983,0.6694983,0,0.783727,0.3218762),(0,0,136,1.002756,0.4002224))"
        GUI.SetPositionY(SwingImage,-40)
        SwingData.From = Vector3.New(0,0,-30)
        SwingData.To = Vector3.New(0,0,30)
    elseif LastClickIndex1 == 2 then
        Keyframe ="((0,0,136,-0.09866332,0.1253327),(0.9952712,0.9952712,0,0.4791815,0.3151727),(0,0,136,1.050787,0.553487))"
        GUI.SetPositionY(SwingImage,-45)
        SwingData.From = Vector3.New(0,180,-30)
        SwingData.To = Vector3.New(0,180,30)
    end
    SwingData.Keyframe = TOOLKIT.Str2Curve(Keyframe)
    SwingData.LoopType = UITweenerStyle.PingPong
    if TradeRoadsStatus == 1 then
        if LastClickIndex1 == TradeRoadsStatusIndex1 then
            if LastClickIndex2 == TradeRoadsStatusIndex2 then
                local now_time = tonumber(CL.GetServerTickCount())
                if not TradeRoadsUI.RefreshTimer then
                    if TradeRoadsStatusNowTime < now_time then
                        TradeRoadsStatusNowTime = now_time
                    else
                        TradeRoadsStatusNowTime = TradeRoadsStatusNowTime
                    end
                    TradeRoadsStatusResidueTime = TradeRoadsStatusEndTime - TradeRoadsStatusNowTime
                    TradeRoadsUI.StartTimer()
                    GUI.DOTween(SwingImage,SwingData)
                else
                    GUI.DOTween(SwingImage,SwingData)
                end
            end
        end
    end

    RefreshPropTable = {}
    RefreshAttendantsTable = {}
    for i, v1 in pairs(SubmitSelectDataTable) do
        for j, v2 in pairs(v1) do
            for k, v3 in pairs(v2) do
                local TableData = TradeRoadsDataTable.Order[v3.OrderName].NeedItem
                if RefreshPropTable[i] == nil then
                    RefreshPropTable[i] = {}
                end
                if RefreshPropTable[i][j]== nil then
                    RefreshPropTable[i][j] = {}
                end
                RefreshPropTable[i][j][k] = {}
                if v3.Goods ~= nil and next(v3.Goods) then
                    for index1 = 1, #TableData,2 do
                        if v3.Goods[TableData[index1]] ~= nil then
                            for l, v4 in pairs(v3.Goods[TableData[index1]]) do -- 上交贸易物品处理
                                local NeedNum = 0
                                if v4 > 0 then
                                    local temp = {
                                        KeyName = TableData[index1],
                                        IsBound = tonumber(l),
                                        ClickNum = tonumber(v4),
                                        NeedNum = TableData[index1 + 1],
                                        Status = 1
                                    }
                                    NeedNum = TableData[index1+1] - tonumber(v4)
                                    RefreshPropTable[i][j][k][#RefreshPropTable[i][j][k] + 1] = temp
                                end
                            end
                        else
                            local temp = {
                                KeyName = TableData[index1],
                                IsBound = 0,
                                ClickNum = 0,
                                NeedNum = TableData[index1 +1],
                                Status = 0
                            }
                            RefreshPropTable[i][j][k][#RefreshPropTable[i][j][k] + 1] = temp
                        end
                    end
                else
                    if TableData ~= nil then
                        for l = 1, #TableData , 2 do
                            local temp = {
                                KeyName = tostring(TableData[l]),
                                IsBound = 0,
                                NeedNum = tonumber(TableData[l+1]),
                                ClickNum = 0,
                                Status = 0
                            }
                            RefreshPropTable[i][j][k][#RefreshPropTable[i][j][k] + 1] = temp
                        end
                    end
                end
                if v3.Guard ~= nil then
                    if RefreshAttendantsTable[i] == nil then
                        RefreshAttendantsTable[i] = {}
                    end
                    if RefreshAttendantsTable[i][j] == nil then
                        RefreshAttendantsTable[i][j] = {}
                    end
                    if RefreshAttendantsTable[i][j][k] == nil then
                        RefreshAttendantsTable[i][j][k] = {}
                    end
                    RefreshAttendantsTable[i][j][k] = v3.Guard
                end
                table.sort(RefreshPropTable[i][j][k],function (a,b)
                    if a.Status > b.Status then
                        return a.Status
                    end
                    return false
                end)
            end
        end
    end
    TradeRoadsUI.SetShowPropTable()
end

--设置贸易物品表单
function TradeRoadsUI.SetShowPropTable()
    test("设置贸易物品表单")
    RefreshShowPropTable = {}

    for k1, v1 in pairs(RefreshPropTable) do
        if RefreshShowPropTable[k1] == nil then
            RefreshShowPropTable[k1] = {}
        end
        for k2, v2 in pairs(v1) do
            if RefreshShowPropTable[k1][k2] == nil then
                RefreshShowPropTable[k1][k2] = {}
            end
            for k3, v3 in pairs(v2) do
                RefreshShowPropTable[k1][k2][k3] = {}
                local TableData = v3
                local TemporaryTable = {}
                for i1 = 1, #TableData do
                    if TemporaryTable[TableData[i1].KeyName] == nil then
                        TemporaryTable[TableData[i1].KeyName] = {
                            KeyName = TableData[i1].KeyName,
                            ClickNum = TableData[i1].ClickNum,
                            NeedNum = TableData[i1].NeedNum,
                            Status = TableData[i1].Status
                        }
                    else
                        TemporaryTable[TableData[i1].KeyName].ClickNum = TemporaryTable[TableData[i1].KeyName].ClickNum + TableData[i1].ClickNum
                    end
                end
                for i2, v4 in pairs(TemporaryTable) do
                    RefreshShowPropTable[k1][k2][k3][#RefreshShowPropTable[k1][k2][k3] + 1] = v4
                end
            end
        end
    end
    test("设置贸易物品表单:RefreshShowPropTable",inspect(RefreshShowPropTable))
end

--设置任务表单数据
function TradeRoadsUI.SetCenterLoopData()
    test("设置任务表单数据")
    for index3 = 1, #CenterBottomTaskTable do
        local Status = 1
        local AttendantsStatus = 0
        for index4 = 1, #CenterBottomTaskTable[index3].NeedItem,2 do
            local ItemStatus = 0
            if RefreshShowPropTable[LastClickIndex1] ~= nil then
                if RefreshShowPropTable[LastClickIndex1][LastClickIndex2] ~= nil then
                    if RefreshShowPropTable[LastClickIndex1][LastClickIndex2][index3] ~= nil then
                        for index5 = 1, #RefreshShowPropTable[LastClickIndex1][LastClickIndex2][index3] do
                            local TableData = RefreshShowPropTable[LastClickIndex1][LastClickIndex2][index3][index5]
                            if TableData.ClickNum == TableData.NeedNum then
                                ItemStatus = 1
                            else
                                ItemStatus = 0
                            end
                            Status = Status * ItemStatus
                        end
                    end
                end
            end
        end
        if RefreshAttendantsTable[LastClickIndex1] ~= nil then
            if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2] ~= nil then
                if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][index3] ~= nil then
                    if #RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][index3] == CenterBottomTaskTable[index3].EscortGuardNum then
                        AttendantsStatus = 1
                    end
                end
            end
        end
        Status = Status * AttendantsStatus
        CenterBottomTaskTable[index3].Status = Status
    end
    test("任务表单数据",inspect(CenterBottomTaskTable))
end

--计时器调用函数
function TradeRoadsUI.TimerCallBack()
    local LeftNumericalNum = _gt.GetUI("LeftNumericalNum")
    local LeftNumericalTxt = _gt.GetUI("LeftNumericalTxt")
    local sliderBg = _gt.GetUI("sliderBg")
    local fill = GUI.GetChild(sliderBg,"fill",false)
    local SwingImage = _gt.GetUI("SwingImage")
    local Width = 0
    if TradeRoadsStatusNowTime >  TradeRoadsStatusStartTime then
        Width = ((TradeRoadsStatusNowTime - TradeRoadsStatusStartTime)/(TradeRoadsStatusEndTime - TradeRoadsStatusStartTime) )* GUI.GetWidth(sliderBg)
    end

    if TradeRoadsStatusResidueTime >= 1 then
        GUI.StaticSetText(LeftNumericalTxt,"剩余时间")
        local str, day, hours, minutes, sec = UIDefine.LeftTimeFormatEx2(TradeRoadsStatusResidueTime)
        GUI.StaticSetText(LeftNumericalNum,str)
        TradeRoadsStatusResidueTime = TradeRoadsStatusResidueTime - 1
        TradeRoadsStatusNowTime = TradeRoadsStatusNowTime + 1
        GUI.SetWidth(fill,Width)
    else
        TradeRoadsUI.StopRefreshTimer()
        GUI.StopTween(SwingImage, GUITweenType.DOLocalRotate)
        GUI.SetEulerAngles(SwingImage,Vector3.New(0, 0, 0.01)) --重新生成
        GUI.SetEulerAngles(SwingImage,Vector3.New(0, 0, 0)) --重置旋转
        GUI.SetWidth(fill,0)
        GUI.StaticSetText(LeftNumericalTxt,"今日已完成")
        GUI.StaticSetText(LeftNumericalNum,"")
        test("计时器停止")
    end
end

--设置倒计时文字颜色
function TradeRoadsUI.TextColorStyleSet(Text)
    local StringText = string.split(Text, "%")
    local NumberText = tonumber(StringText[1])
    if NumberText < 10 then
        return "<color=#32CD32>"..Text.."</color>"
    elseif NumberText < 30 then
        return "<color=#FF7F50>"..Text.."</color>"
    else
        return "<color=#FF0000>"..Text.."</color>"
    end
end

function TradeRoadsUI.OnRoadPageBtnClick(guid)
    test("右边页签点击事件")
    if guid == nil then
        LastClickIndex1 = 1
    else
        local Item = GUI.GetByGuid(guid)
        local Index = GUI.GetData(Item,"ItemIndex")
        LastClickIndex1 = tonumber(Index)
    end
    if TradeRoadsStatus == 1 then
        if LastClickIndex1 ~= TradeRoadsStatusIndex1 then
            LastClickIndex1 = TradeRoadsStatusIndex1
            LastClickIndex2 = TradeRoadsStatusIndex2
        else
            ShowTipsStatus = 0
        end
        if ShowTipsStatus == 0 then
            ShowTipsStatus = 1
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "您已开始贸易,无法选择")
            test("您已开始贸易,无法选择")
        end
    else
        LastClickIndex2 = 1
    end

    UILayout.OnTabClick(LastClickIndex1, TradeRightTable)
    LastClickIndex3 = 1
    local TradeLeftLoop = _gt.GetUI("TradeLeftLoop")
    GUI.LoopScrollRectSetTotalCount(TradeLeftLoop,#TradeLeftTable[LastClickIndex1])
    GUI.LoopScrollRectRefreshCells(TradeLeftLoop)
    if LastClickIndex2 > #TradeLeftTable[LastClickIndex1] then
        TradeRoadsUI.RefreshTopRightItem(LastClickIndex1,1)
    else
        TradeRoadsUI.RefreshTopRightItem(LastClickIndex1,LastClickIndex2)
    end

    local SwingImage = _gt.GetUI("SwingImage")
    test("设置顶部奖励事件动画图标")
    if LastClickIndex1 == 1 then
        GUI.SetEulerAngles(SwingImage, Vector3.New(0, 0, 0))
        GUI.ImageSetImageID(SwingImage,"1901201490")
    elseif LastClickIndex1 == 2 then
        GUI.SetEulerAngles(SwingImage, Vector3.New(0, 180, 0))
        GUI.ImageSetImageID(SwingImage,"1901201480")
    end
    TradeRoadsUI.RefreshTradeRightLoop(LastClickIndex2)
end

function TradeRoadsUI.RefreshTopRightItem(index1,index2)
    local PlaceName = TradeLeftTable[index1][index2]
    local TitleTable = TradeRoadsDataTable.Place[PlaceName]
    local IncidentItemGroup = _gt.GetUI("IncidentItemGroup")
    test("右上角的事件奖励销毁")
    GUI.Destroy(IncidentItemGroup)

    test("刷新右上角的事件奖励")
    LastTableItemPlaceName = PlaceName
    local panelBg = _gt.GetUI("panelBg")
    local RightGroup = GUI.GetChild(panelBg,"RightGroup",false)
    local TopRightGroup = GUI.GetChild(RightGroup,"TopRightGroup",false)
    local TopRightGroup2 = GUI.GetChild(TopRightGroup,"TopRightGroup2",false)
    local sliderBg = GUI.GetChild(TopRightGroup2,"sliderBg",false)--积分背景进度条
    local fill = GUI.GetChild(sliderBg,"fill",false)--积分绿色进度条


    test("创建右上角奖励事件的控件")
    local IncidentItemGroup = GUI.GroupCreate(fill,"IncidentItemGroup",0,0,GUI.GetWidth(sliderBg),GUI.GetHeight(TopRightGroup)+40,false)
    _gt.BindName(IncidentItemGroup,"IncidentItemGroup")
    for i = 1, #TitleTable.EventTrigger do
        local IncidentItem = GUI.ItemCtrlCreate(IncidentItemGroup,"IncidentItem"..i,QualityRes[1],GUI.GetWidth(sliderBg)*TitleTable.EventTrigger[i] / 100 -29,90,58,58,false,"system",false)
        SetSameAnchorAndPivot(IncidentItem, UILayout.TopLeft)

        local ScaleImage = GUI.ImageCreate(IncidentItem,"ScaleImage","1801208390",0,-21,false,8,20,false)
        SetSameAnchorAndPivot(ScaleImage, UILayout.Top)
        if TradeRoadsStatus == 0 then
            GUI.ItemCtrlSetElementValue(IncidentItem,eItemIconElement.Icon,"1900000000")
            GUI.ItemCtrlSetElementRect(IncidentItem,eItemIconElement.Icon,0,0,49,49)
            GUI.SetData(IncidentItem,"IncidentItemText","前方迷雾，无法看清")
        elseif TradeRoadsStatus == 1 then
            if next(EventStatusTable) then
                local ItemData = string.split(EventStatusTable[i], ",")
                test("奖励事件表单:EventStatusTable[i]",inspect(EventStatusTable[i]))
                local IconId = ""
                if ItemData[2] == nil then
                    IconId = "1900000000"
                else
                    IconId = ItemData[2]
                end
                local IconText = ""
                local IconStatus = 0
                if ItemData[1] == "nil" or ItemData[1] == nil then
                    IconText = "前方迷雾，无法看清"
                    IconStatus = 0
                else
                    IconText = ItemData[1]
                    GUI.SetData(IncidentItem,"Place",ItemData[4])
                    GUI.SetData(IncidentItem,"PlaceX",ItemData[5])
                    GUI.SetData(IncidentItem,"PlaceY",ItemData[6])
                    GUI.SetData(IncidentItem,"NPCName",ItemData[7])
                    IconStatus = ItemData[3]
                end
                GUI.ItemCtrlSetElementValue(IncidentItem,eItemIconElement.Icon,IconId)
                GUI.ItemCtrlSetElementRect(IncidentItem,eItemIconElement.Icon,0,-1,49,49)
                GUI.SetData(IncidentItem,"IncidentItemStatus",IconStatus)
                if tonumber(ItemData[3]) == 1 then

                elseif tonumber(ItemData[3]) == 2 then
                    GUI.ItemCtrlSetElementValue(IncidentItem,eItemIconElement.LeftTopSp,"1801208640")
                    GUI.ItemCtrlSetElementRect(IncidentItem,eItemIconElement.LeftTopSp,10,15)
                    GUI.SetData(IncidentItem,"IncidentItemText",IconText.."【已完成】")
                elseif tonumber(ItemData[3]) == 3 then
                    GUI.ItemCtrlSetElementRect(IncidentItem,eItemIconElement.LeftTopSp,10,15,42,18)
                    GUI.SetData(IncidentItem,"IncidentItemText",IconText.."【未完成】")
                    GUI.ItemCtrlSetIconGray(IncidentItem,true)
                else
                    GUI.SetData(IncidentItem,"IncidentItemText",IconText)
                end
            else
                GUI.ItemCtrlSetElementValue(IncidentItem,eItemIconElement.Icon,"1900000000")
                GUI.ItemCtrlSetElementRect(IncidentItem,eItemIconElement.Icon,0,0,49,49)
                GUI.SetData(IncidentItem,"IncidentItemText","前方迷雾，无法看清")
                GUI.SetData(IncidentItem,"IncidentItemStatus","0")
            end
        elseif TradeRoadsStatus == 2 then
            GUI.ItemCtrlSetElementValue(IncidentItem,eItemIconElement.Icon,"1900000000")
            GUI.ItemCtrlSetElementRect(IncidentItem,eItemIconElement.Icon,0,0,49,49)
            GUI.SetData(IncidentItem,"IncidentItemText","今日贸易已完成")
            GUI.SetData(IncidentItem,"IncidentItemStatus","0")
        end
        GUI.RegisterUIEvent(IncidentItem, UCE.PointerClick, "TradeRoadsUI", "OnIncidentItemClick")
    end

    --设置时间
    local LeftNumericalNum = _gt.GetUI("LeftNumericalNum")
    local LeftNumericalTxt = _gt.GetUI("LeftNumericalTxt")
    if TradeRoadsStatus == 1 then
        if TradeRoadsStatusEndTime ~= nil and tonumber(TradeRoadsStatusEndTime) > 0 then
            local now_time = tonumber(CL.GetServerTickCount())
            if TradeRoadsStatusNowTime < now_time then
                TradeRoadsStatusNowTime = now_time
            else
                TradeRoadsStatusNowTime = TradeRoadsStatusNowTime
            end
            TradeRoadsStatusResidueTime = TradeRoadsStatusEndTime - TradeRoadsStatusNowTime
            GUI.StaticSetText(LeftNumericalTxt,"剩余时间")
            local str, day, hours, minutes, sec = UIDefine.LeftTimeFormatEx2(TradeRoadsStatusResidueTime)
            GUI.StaticSetText(LeftNumericalNum,str)
            local sliderBg = _gt.GetUI("sliderBg")
            local fill = GUI.GetChild(sliderBg,"fill",false)
            local Width = 0
            if TradeRoadsStatusNowTime > TradeRoadsStatusStartTime then
                Width = ((TradeRoadsStatusNowTime - TradeRoadsStatusStartTime)/(TradeRoadsStatusEndTime - TradeRoadsStatusStartTime) )* GUI.GetWidth(sliderBg)
            end
            GUI.SetWidth(fill,Width)
        end
    elseif TradeRoadsStatus == 2 then
        GUI.StaticSetText(LeftNumericalTxt,"今日已完成")
        GUI.StaticSetText(LeftNumericalNum,"")
    else
        GUI.StaticSetText(LeftNumericalTxt,"所需时间")
        local str, day, hours, minutes, sec = UIDefine.LeftTimeFormatEx2(TitleTable.Time)
        GUI.StaticSetText(LeftNumericalNum,str)
    end
end

function TradeRoadsUI.CreateAttendantsItem()
    local AttendantsLoopScroll = _gt.GetUI("AttendantsLoopScroll")
    local index = GUI.LoopScrollRectGetChildInPoolCount(AttendantsLoopScroll) + 1

    local AttendantsGroup = GUI.GroupCreate(AttendantsLoopScroll,"AttendantsGroup"..index,0,0,120,90,false)

    local Attendants = GUI.ItemCtrlCreate(AttendantsGroup,"Attendants",QualityRes[1],0,0,70,70,false,"system",false)
    SetSameAnchorAndPivot(Attendants, UILayout.Center)

    local AttendantsName = GUI.CreateStatic(Attendants,"AttendantsName","",0,30,180,30,"system",true,false)
    GUI.SetColor(AttendantsName, UIDefine.Brown8Color)
    SetSameAnchorAndPivot(AttendantsName, UILayout.Bottom)
    GUI.StaticSetAlignment(AttendantsName, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(AttendantsName, 22)

    return AttendantsGroup
end

function TradeRoadsUI.RefreshAttendantsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local AttendantsGroup = GUI.GetByGuid(guid)
    local Attendants = GUI.GetChild(AttendantsGroup,"Attendants",false)
    local AttendantsName = GUI.GetChild(Attendants,"AttendantsName",false)

    if RefreshAttendantsTable[LastClickIndex1] ~= nil then
        if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2] ~= nil then
            if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] ~= nil then
                if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][LastClickIndex3][index] ~= nil then
                    local AttendantsData = RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][LastClickIndex3][index]
                    local AttendantsDB = DB.GetOnceGuardByKey2(AttendantsData)
                    GUI.ItemCtrlSetElementValue(Attendants,eItemIconElement.Icon,AttendantsDB.Head)
                    GUI.ItemCtrlSetElementValue(Attendants,eItemIconElement.Border,QualityRes[AttendantsDB.Grade])
                    GUI.ItemCtrlSetElementRect(Attendants,eItemIconElement.Icon,0,-1,60,60)
                    GUI.StaticSetText(AttendantsName,AttendantsDB.Name)
                    GUI.RegisterUIEvent(Attendants, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemClick")
                else
                    ItemIcon.SetEmpty(Attendants)
                    GUI.ItemCtrlSetElementRect(Attendants,eItemIconElement.Icon,0,-2,56,56)
                    if index == #RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] + 1 then
                        GUI.ItemCtrlSetElementValue(Attendants,eItemIconElement.Icon,"1800707060")
                        GUI.RegisterUIEvent(Attendants, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemClick")
                    else
                        GUI.UnRegisterUIEvent(Attendants, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemClick")
                    end
                    GUI.StaticSetText(AttendantsName,"")
                end
            else
                ItemIcon.SetEmpty(Attendants)
                GUI.ItemCtrlSetElementRect(Attendants,eItemIconElement.Icon,0,-2,56,56)
                if index == 1 then
                    GUI.ItemCtrlSetElementValue(Attendants,eItemIconElement.Icon,"1800707060")
                    GUI.RegisterUIEvent(Attendants, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemClick")
                else
                    GUI.UnRegisterUIEvent(Attendants, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemClick")
                end
                GUI.StaticSetText(AttendantsName,"")
            end
        else
            ItemIcon.SetEmpty(Attendants)
            GUI.ItemCtrlSetElementRect(Attendants,eItemIconElement.Icon,0,-2,56,56)
            if index == 1 then
                GUI.ItemCtrlSetElementValue(Attendants,eItemIconElement.Icon,"1800707060")
                GUI.RegisterUIEvent(Attendants, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemClick")
            else
                GUI.UnRegisterUIEvent(Attendants, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemClick")
            end
            GUI.StaticSetText(AttendantsName,"")
        end
    else
        ItemIcon.SetEmpty(Attendants)
        GUI.ItemCtrlSetElementRect(Attendants,eItemIconElement.Icon,0,-2,56,56)
        if index == 1 then
            GUI.ItemCtrlSetElementValue(Attendants,eItemIconElement.Icon,"1800707060")
            GUI.RegisterUIEvent(Attendants, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemClick")
        else
            GUI.UnRegisterUIEvent(Attendants, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemClick")
        end
        GUI.StaticSetText(AttendantsName,"")
    end

end

function TradeRoadsUI.CreatePropItem()
    local PropLoopScroll = _gt.GetUI("PropLoopScroll")
    local index = GUI.LoopScrollRectGetChildInPoolCount(PropLoopScroll) + 1

    local PropItemGroup = GUI.GroupCreate(PropLoopScroll,"PropItemGroup"..index,0,0,120,90,false)

    local PropItem = GUI.ItemCtrlCreate(PropItemGroup,"PropItem",QualityRes[1],0,0,70,70,false,"system",false)
    SetSameAnchorAndPivot(PropItem, UILayout.Center)
    GUI.ItemCtrlSetElementRect(PropItem,eItemIconElement.Icon,0,-2,63,63)
    GUI.ItemCtrlSetElementRect(PropItem,eItemIconElement.RightBottomNum,8,5)

    local PropItemName = GUI.CreateStatic(PropItem,"PropItemName","",0,30,180,30,"system",true,false)
    GUI.SetColor(PropItemName, UIDefine.Brown8Color)
    SetSameAnchorAndPivot(PropItemName, UILayout.Bottom)
    GUI.StaticSetAlignment(PropItemName, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(PropItemName, 22)

    local AddImage = GUI.ImageCreate(PropItem,"AddImage","1800707060",0,0)
    GUI.SetVisible(AddImage,false)
    SetSameAnchorAndPivot(AddImage, UILayout.Center)

    return PropItemGroup
end

function TradeRoadsUI.RefreshPropItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local PropItemGroup = GUI.GetByGuid(guid)
    local PropItem = GUI.GetChild(PropItemGroup,"PropItem",false)
    local AddImage = GUI.GetChild(PropItem,"AddImage",false)
    local PropItemName = GUI.GetChild(PropItem,"PropItemName",false)
    GUI.ItemCtrlSetIconGray(PropItem,false)
    if RefreshShowPropTable[LastClickIndex1] ~= nil then
        if RefreshShowPropTable[LastClickIndex1][LastClickIndex2] ~= nil then
            if RefreshShowPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] ~= nil then
                local TableData = RefreshShowPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3][index]
                local ItemDB = DB.GetOnceItemByKey2(TableData.KeyName)
                if TableData.Status == 1 then
                    GUI.SetVisible(AddImage,false)
                    GUI.ItemCtrlSetElementValue(PropItem,eItemIconElement.Icon,ItemDB.Icon)
                    GUI.ItemCtrlSetElementValue(PropItem,eItemIconElement.Border,QualityRes[ItemDB.Grade])
                    GUI.ItemCtrlSetElementValue(PropItem,eItemIconElement.RightBottomNum,TableData.ClickNum.."/"..TableData.NeedNum)
                    GUI.ItemCtrlSetIconGray(PropItem,false)
                else
                    ItemIcon.SetEmpty(PropItem)
                    GUI.ItemCtrlSetElementValue(PropItem,eItemIconElement.Icon,ItemDB.Icon)
                    GUI.ItemCtrlSetElementValue(PropItem,eItemIconElement.RightBottomNum,TableData.ClickNum.."/"..TableData.NeedNum)
                    GUI.ItemCtrlSetIconGray(PropItem,true)
                    GUI.SetVisible(AddImage,true)
                end
                GUI.RegisterUIEvent(PropItem, UCE.PointerClick, "TradeRoadsUI", "OnPropItemClick")
                GUI.StaticSetText(PropItemName,ItemDB.Name)
            end
        end
    else
        GUI.ItemCtrlSetIconGray(PropItem,true)
        GUI.SetVisible(AddImage,true)
        if index == 1 then
            GUI.RegisterUIEvent(PropItem, UCE.PointerClick, "TradeRoadsUI", "OnPropItemClick")
        else
            GUI.UnRegisterUIEvent(PropItem, UCE.PointerClick, "TradeRoadsUI", "OnPropItemClick")
        end
    end
end

function TradeRoadsUI.CreateTradeLeftItem()
    local TradeLeftLoop = _gt.GetUI("TradeLeftLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(TradeLeftLoop) + 1
    local item = GUI.GroupCreate(TradeLeftLoop,"item"..tostring(index), 0, 0, 173, 70,false)
    local CheckBox = GUI.CheckBoxExCreate(item, "CheckBox", "1800002030", "1800002031", 0, 0, false)
    SetSameAnchorAndPivot(CheckBox, UILayout.Center)
    GUI.RegisterUIEvent(CheckBox, UCE.PointerClick, "TradeRoadsUI", "OnTradeLeftItemClick")
    local txt = GUI.CreateStatic(item, "txt", " ", 0, 0, 150, 39)
    SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeXL)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

    return item
end

function TradeRoadsUI.RefreshTradeLeftItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local CheckBox = GUI.GetChild(item, "CheckBox", false)
    local txt = GUI.GetChild(item, "txt", false)
    GUI.CheckBoxExSetCheck(CheckBox,false)
    if index == LastClickIndex2 then
        GUI.CheckBoxExSetCheck(CheckBox,true)
        LastCheckBoxGuid = tostring(GUI.GetGuid(CheckBox))
    end
    GUI.SetPreferredWidth(item, 190)
    GUI.SetPreferredHeight(item, 65)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeXL)
    GUI.StaticSetText(txt, TradeLeftTable[LastClickIndex1][index])

    GUI.SetData(CheckBox,"index",index)
end

function TradeRoadsUI.CreateTradeRightItem()
    local TradeLeftLoop = _gt.GetUI("TradeLeftLoop")
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(TradeLeftLoop) +1

    local item = GUI.GroupCreate(TradeLeftLoop, "TradeRightItem"..curIndex, 0, 0, 400, 100,false)

    local _ActNode = GUI.CheckBoxExCreate(item, "ActNode", "1801100010", "1801100012",0, 1, false, 400, 100)
    GUI.SetAnchor(_ActNode, UIAnchor.TopLeft)
    GUI.SetPivot(_ActNode, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(_ActNode, UCE.PointerClick, "TradeRoadsUI", "OnTradeRightItemClick")

    --IconBack
    local _IconBack = GUI.ImageCreate(_ActNode, "IconBack", "1801109180", 31, 23, false, 56, 56)
    GUI.SetAnchor(_IconBack, UIAnchor.TopLeft)
    GUI.SetPivot(_IconBack, UIAroundPivot.TopLeft)

    --Icon
    local _Icon = GUI.ImageCreate(_IconBack, "Icon", "1801100170", 0, 0, false, 74, 74)
    GUI.SetAnchor(_Icon, UIAnchor.Center)
    GUI.SetPivot(_Icon, UIAroundPivot.Center)

    --上交物品
    local TaskName = GUI.CreateStatic(_ActNode, "TaskName", "上交物品内容信息", 110, 10, 300, 35)
    GUI.SetAnchor(TaskName, UIAnchor.TopLeft)
    GUI.SetPivot(TaskName, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(TaskName, UIDefine.FontSizeL)
    GUI.SetColor(TaskName, UIDefine.BrownColor)

    local TaskInfo = GUI.CreateStatic(_ActNode, "TaskInfo", "上交宠物内容信息", 110, 32, 220, 70)
    SetSameAnchorAndPivot(TaskInfo, UILayout.TopLeft)
    GUI.StaticSetAlignment(TaskInfo, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(TaskInfo, 20)
    GUI.SetColor(TaskInfo, UIDefine.BrownColor)

    --完成标记
    local FinishFlag = GUI.ImageCreate(_ActNode, "FinishFlag", "1800608400", -10, 0,false)
    GUI.SetAnchor(FinishFlag, UIAnchor.Right)
    GUI.SetPivot(FinishFlag, UIAroundPivot.Right)
    GUI.SetVisible(FinishFlag, false)

    return item
end

function TradeRoadsUI.RefreshTradeRightItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local CheckBox = GUI.GetChild(item,"ActNode",false)
    local IconBack = GUI.GetChild(CheckBox,"IconBack",false)
    local TaskName = GUI.GetChild(CheckBox,"TaskName",false)
    local TaskInfo = GUI.GetChild(CheckBox,"TaskInfo",false)
    local FinishFlag = GUI.GetChild(CheckBox,"FinishFlag",false)
    GUI.CheckBoxExSetCheck(CheckBox,false)
    local TableData = CenterBottomTaskTable[index]
    if TableData ~= nil then
        if index == LastClickIndex3 then
            TradeRoadsUI.SetRecommendGuardTable(index)
            GUI.CheckBoxExSetCheck(CheckBox,true)
            LastRightCheckBoxGuid = GUI.GetGuid(CheckBox)
        end
        GUI.ImageSetImageID(IconBack,TableData.Icon)
        GUI.StaticSetText(TaskName,TableData.Name)
        GUI.StaticSetText(TaskInfo,TableData.Info)
        GUI.SetData(CheckBox,"CheckBoxIndex",index)
        if TableData.Status == 0 then
            GUI.SetVisible(FinishFlag,false)
        else
            GUI.SetVisible(FinishFlag,true)
        end

    end
end

function TradeRoadsUI.OnTradeLeftItemClick(guid)
    local CheckBox = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(CheckBox,"index"))
    if TradeRoadsStatus == 1 then
        if index ~= TradeRoadsStatusIndex2 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "您已开始贸易,无法选择")
            test("您已开始贸易,无法选择")
            GUI.CheckBoxExSetCheck(CheckBox,false)
            return
        end
    end

    if tostring(guid) ~= LastCheckBoxGuid then
        GUI.CheckBoxExSetCheck(CheckBox,true)
        if LastCheckBoxGuid ~= nil then
            local LastCheckBox = GUI.GetByGuid(LastCheckBoxGuid)
            GUI.CheckBoxExSetCheck(LastCheckBox,false)
        end
    else
        GUI.CheckBoxExSetCheck(CheckBox,true)
    end
    LastCheckBoxGuid = tostring(guid)
    LastClickIndex2 = index
    LastClickIndex3 = 1

    test("左边按钮点击事件")

    --刷新右上角的事件奖励
    TradeRoadsUI.RefreshTopRightItem(LastClickIndex1,index)

    --中下任务刷新
    TradeRoadsUI.RefreshTradeRightLoop(LastClickIndex2)

end

--中下任务刷新
function TradeRoadsUI.RefreshTradeRightLoop(index2)
    local TaskName = TradeLeftTable[LastClickIndex1][index2]
    CenterBottomTaskTable = {}
    local OrderTable = TradeRoadsDataTable.Order
    for k, v in pairs(OrderTable) do
        v.Status = 0
    end
    for i = 1, #TradeRoadsChangeTable[TaskName] do
        local TableData = OrderTable[TradeRoadsChangeTable[TaskName][i]]
        local temp = {}
        for i, v in pairs(TableData) do
            temp[i] = v
        end
        CenterBottomTaskTable[#CenterBottomTaskTable + 1] = temp
    end
    test("CenterBottomTaskTable--中下任务表单:",inspect(CenterBottomTaskTable))
    TradeRoadsUI.SetCenterLoopData()
    local TradeRightLoop = _gt.GetUI("TradeRightLoop")
    GUI.LoopScrollRectSetTotalCount(TradeRightLoop, #CenterBottomTaskTable)
    GUI.LoopScrollRectRefreshCells(TradeRightLoop)
    test("中下任务刷新")

    --右下角两个滚动框刷新
    TradeRoadsUI.RefreshRigHTBottomLoop()

    TradeRoadsUI.SetCompleteness(SubmitSelectDataTable)
end

--中下任务按钮点击事件
function TradeRoadsUI.OnTradeRightItemClick(guid)
    test("中下任务按钮点击事件")
    local CheckBox = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(CheckBox,"CheckBoxIndex"))
    if tostring(guid) ~= LastRightCheckBoxGuid then
        GUI.CheckBoxExSetCheck(CheckBox,true)
        if LastRightCheckBoxGuid ~= nil then
            local LastCheckBox = GUI.GetByGuid(LastRightCheckBoxGuid)
            GUI.CheckBoxExSetCheck(LastCheckBox,false)
        end
    else
        GUI.CheckBoxExSetCheck(CheckBox,true)
    end
    LastRightCheckBoxGuid = tostring(guid)
    LastClickIndex3 = index

    TradeRoadsUI.SetRecommendGuardTable(LastClickIndex3)
    TradeRoadsUI.RefreshRigHTBottomLoop()
end

--设置推荐侍从表单
function TradeRoadsUI.SetRecommendGuardTable(index3)
    RecommendGuardTable = {}
    local TaskName = TradeLeftTable[LastClickIndex1][LastClickIndex2]
    local OrderTable = TradeRoadsDataTable.Order
    local TableData = OrderTable[TradeRoadsChangeTable[TaskName][index3]]
    local RecommendGuardList = TableData.RecommendGuardList
    if RecommendGuardList ~= nil and next(RecommendGuardList) then
        RecommendGuardTable = RecommendGuardList
    end
end

--刷新右下角两个滚动框
function TradeRoadsUI.RefreshRigHTBottomLoop()
    test("刷新右下角两个滚动框")
    if RefreshPropTable[LastClickIndex1] == nil then
        RefreshPropTable[LastClickIndex1] = {}
    end
    if RefreshPropTable[LastClickIndex1][LastClickIndex2]== nil then
        RefreshPropTable[LastClickIndex1][LastClickIndex2] = {}
    end
    if RefreshPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] == nil then
        RefreshPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] = {}
        for i = 1, #CenterBottomTaskTable[LastClickIndex3].NeedItem , 2 do
            local TableData = CenterBottomTaskTable[LastClickIndex3].NeedItem
            local temp = {
                KeyName = tostring(TableData[i]),
                IsBound = 0,
                NeedNum = tonumber(TableData[i+1]),
                ClickNum = 0,
                Status = 0
            }
            RefreshPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3][#RefreshPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] + 1] = temp
        end
    elseif #RefreshPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] == 0 then
        RefreshPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] = {}
        for i = 1, #CenterBottomTaskTable[LastClickIndex3].NeedItem , 2 do
            local TableData = CenterBottomTaskTable[LastClickIndex3].NeedItem
            local temp = {
                KeyName = tostring(TableData[i]),
                IsBound = 0,
                NeedNum = tonumber(TableData[i+1]),
                ClickNum = 0,
                Status = 0
            }
            RefreshPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3][#RefreshPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] + 1] = temp
        end
    end
    TradeRoadsUI.SetShowPropTable()
    test("所需材料:",inspect(CenterBottomTaskTable[LastClickIndex3].NeedItem))
    local RefreshNum = math.floor(#CenterBottomTaskTable[LastClickIndex3].NeedItem / 2)
    if RefreshShowPropTable[LastClickIndex1] ~= nil then
        if RefreshShowPropTable[LastClickIndex1][LastClickIndex2] ~= nil then
            if RefreshShowPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] ~= nil then
                if #RefreshShowPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] > math.floor(#CenterBottomTaskTable[LastClickIndex3].NeedItem / 2) then
                    RefreshNum = #RefreshShowPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3]
                end
            end
        end
    end
    --上交贸易物品刷新
    local PropLoopScroll = _gt.GetUI("PropLoopScroll")
    GUI.LoopScrollRectSetTotalCount(PropLoopScroll, RefreshNum)
    GUI.LoopScrollRectRefreshCells(PropLoopScroll)

    --选择护卫侍从刷新
    local AttendantsLoopScroll = _gt.GetUI("AttendantsLoopScroll")
    GUI.LoopScrollRectSetTotalCount(AttendantsLoopScroll, CenterBottomTaskTable[LastClickIndex3].EscortGuardNum)
    GUI.LoopScrollRectRefreshCells(AttendantsLoopScroll)
    --选择侍从护卫提示
    local TipsText = _gt.GetUI("TipsText")
    GUI.StaticSetText(TipsText,CenterBottomTaskTable[LastClickIndex3].RecommendTips)
end

--右上角奖励单击事件
function TradeRoadsUI.OnIncidentItemClick(guid)
    test("右上角奖励单击事件")
    local IncidentItem = GUI.GetByGuid(guid)
    local IncidentItemText = GUI.GetData(IncidentItem,"IncidentItemText")
    local IncidentItemStatus = tonumber(GUI.GetData(IncidentItem,"IncidentItemStatus"))
    if IncidentItemStatus == 1 then
        local Place = GUI.GetData(IncidentItem,"Place")
        local PlaceX = GUI.GetData(IncidentItem,"PlaceX")
        local PlaceY = GUI.GetData(IncidentItem,"PlaceY")
        local NPCName = GUI.GetData(IncidentItem,"NPCName")
        if Place ~= "nil" and PlaceX ~= "nil" and PlaceY ~= "nil" then
            TradeRoadsUI.ShowGotoPlacePage(Place,PlaceX,PlaceY,NPCName)
        else
            local TipsBg = GUI.ImageCreate(IncidentItem,"TipsBg","1800201210",30,-85,false,212,87)
            SetSameAnchorAndPivot(TipsBg, UILayout.Top)
            GUI.SetIsRemoveWhenClick(TipsBg, true)

            local TipsText = GUI.CreateStatic(TipsBg,"TipsText",IncidentItemText,0,-5,200,30,"system",true,false)
            SetSameAnchorAndPivot(TipsText, UILayout.Center)
            GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleCenter)
            GUI.StaticSetFontSize(TipsText, 16)
            GUI.SetColor(TipsText, UIDefine.BrownColor)
        end
    else
        local TipsBg = GUI.ImageCreate(IncidentItem,"TipsBg","1800201210",30,-85,false,212,87)
        SetSameAnchorAndPivot(TipsBg, UILayout.Top)
        GUI.SetIsRemoveWhenClick(TipsBg, true)

        local TipsText = GUI.CreateStatic(TipsBg,"TipsText",IncidentItemText,0,-5,200,30,"system",true,false)
        SetSameAnchorAndPivot(TipsText, UILayout.Center)
        GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(TipsText, 16)
        GUI.SetColor(TipsText, UIDefine.BrownColor)
    end
end

--开始贸易按钮单击事件
function TradeRoadsUI.OnStartBtnClick()
    test("开始贸易按钮单击事件")
    CL.SendNotify(NOTIFY.SubmitForm,"FormTrade","Start",Version,LastClickIndex1,LastClickIndex2)
end

--贸易品质按钮单击事件
function TradeRoadsUI.OnTradeCompletenessBtnClick()
    test("贸易品质按钮单击事件")
    local panelBg = _gt.GetUI("panelBg")

    local Text = "贸易完成时，根据该贸易品质，将获得"..Voucher.."*<color=#FF0000>"..TradeCompletenessNumber.."</color>。"

    local TipsBg = GUI.TipsCreate(panelBg, "Tips", -60, -90, 500, 0)
    SetSameAnchorAndPivot(TipsBg, UILayout.BottomRight)
    GUI.SetIsRemoveWhenClick(TipsBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(TipsBg),false)

    local TipsText = GUI.CreateStatic(TipsBg,"TipsText",Text,0,0,400,25,"system", true)
    GUI.StaticSetFontSize(TipsText,20)
    SetSameAnchorAndPivot(TipsText, UILayout.Center)
    GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
    local desPreferHeight = GUI.StaticGetLabelPreferHeight(TipsText)
    GUI.SetHeight(TipsText,desPreferHeight)
end

--地点介绍Tips按钮
function TradeRoadsUI.OnPlaceInfoBtnClick()
    test("地点介绍Tips按钮")
    local panelBg = _gt.GetUI("panelBg")
    local TipsBg = GUI.TipsCreate(panelBg, "Tips", 60, 160, 500, 20)
    SetSameAnchorAndPivot(TipsBg, UILayout.Left)
    GUI.SetIsRemoveWhenClick(TipsBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(TipsBg),false)

    local TipsText = GUI.CreateStatic(TipsBg,"TipsText",TradeRoadsUITips,0,0,400,30,"system", true)
    GUI.StaticSetFontSize(TipsText,20)
    SetSameAnchorAndPivot(TipsText, UILayout.Center)
    GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
    local desPreferHeight = GUI.StaticGetLabelPreferHeight(TipsText)
    GUI.SetHeight(TipsText,desPreferHeight)
end

--积分奖励最终地点Tips按钮
function TradeRoadsUI.OnInfoBtnClick()
    test("积分奖励最终地点Tips按钮")
    local panelBg = _gt.GetUI("panelBg")
    local TitleTable = TradeRoadsDataTable.Place[TradeLeftTable[LastClickIndex1][LastClickIndex2]]
    local TipsBg = GUI.TipsCreate(panelBg, "Tips", -80, -80, 500, 0)
    SetSameAnchorAndPivot(TipsBg, UILayout.Right)
    GUI.SetIsRemoveWhenClick(TipsBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(TipsBg),false)

    local TipsText = GUI.CreateStatic(TipsBg,"TipsText",TitleTable.Info,0,0,400,30,"system", true)
    GUI.StaticSetFontSize(TipsText,20)
    SetSameAnchorAndPivot(TipsText, UILayout.Center)
    GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
    local desPreferHeight = GUI.StaticGetLabelPreferHeight(TipsText)
    GUI.SetHeight(TipsText,desPreferHeight)
end

--选择护卫侍从点击事件
function TradeRoadsUI.OnAttendantsItemClick()
    test("选择护卫侍从点击事件")
    if TradeRoadsStatus == 1 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "您已开始贸易,无法选择")
        test("您已开始贸易,无法选择")
    elseif TradeRoadsStatus == 2 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "今日贸易已完成,无法选择")
        test("今日贸易已完成,无法选择")
    else
        TradeRoadsUI.CreateAttendantsGroup()
    end
end

--创建选择护卫侍从点击事件
function TradeRoadsUI.CreateAttendantsGroup()
    local wnd = GUI.GetWnd("TradeRoadsUI")
    local AttendantsGroup = GUI.GetChild(wnd,"AttendantsGroup",false)

    --侍从护卫界面数据重置
    TradeRoadsUI.AttendantsGroupInit()

    if not next(SelectAttendantsTable) then
        TradeRoadsUI.ShowGotoGainGuardPage()
        return
    end
    if not AttendantsGroup then
        test("进入选择的护卫侍从界面的创建")
        local AttendantsGroup = GUI.GroupCreate(wnd, "AttendantsGroup", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd),false)
        _gt.BindName(AttendantsGroup,"AttendantsGroup")

        -- 底图
        local AttendantsGroupBg = UILayout.CreateFrame_WndStyle2(AttendantsGroup,"护卫侍从选择",870,560,"TradeRoadsUI","OnAttendantsGroupClose")
        _gt.BindName(AttendantsGroupBg,"AttendantsGroupBg")

        --创建侍从Model
        TradeRoadsUI.SetAttendants(SelectAttendantsTable[1].Id)

        local LeftBg = GUI.ImageCreate(AttendantsGroupBg, "LeftBg", "1800400200", 20, -5, false, 350, 420)
        SetSameAnchorAndPivot(LeftBg, UILayout.Left)

        --左边侍从列表
        local SelectAttendantsLoop =
        GUI.LoopScrollRectCreate(
                LeftBg,
                "SelectAttendantsLoop",
                5,
                7,
                GUI.GetWidth(LeftBg)-6,
                GUI.GetHeight(LeftBg)-16,
                "TradeRoadsUI",
                "CreateAttendantsListItem",
                "TradeRoadsUI",
                "RefreshAttendantsListItem",
                0,
                false,
                Vector2.New(GUI.GetWidth(LeftBg)-10,105),
                1,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        SetSameAnchorAndPivot(SelectAttendantsLoop, UILayout.TopLeft)
        GUI.ScrollRectSetAlignment(SelectAttendantsLoop, TextAnchor.UpperCenter)
        _gt.BindName(SelectAttendantsLoop, "SelectAttendantsLoop")
        GUI.LoopScrollRectSetTotalCount(SelectAttendantsLoop, #SelectAttendantsTable)
        GUI.LoopScrollRectRefreshCells(SelectAttendantsLoop)
        GUI.ScrollRectSetChildSpacing(SelectAttendantsLoop, Vector2.New(3,2 ))

        local confirmBtn = GUI.ButtonCreate(AttendantsGroupBg, "confirmBtn", "1800402080", -180, -20, Transition.ColorTint, "选择", 120, 45, false)
        GUI.ButtonSetTextFontSize(confirmBtn, 24)
        GUI.SetIsOutLine(confirmBtn, true)
        GUI.ButtonSetTextColor(confirmBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(confirmBtn, OutLine_BrownColor);
        GUI.SetOutLine_Distance(confirmBtn,OutLineDistance)
        SetSameAnchorAndPivot(confirmBtn, UILayout.BottomRight)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "TradeRoadsUI", "OnSubmitAttendantsBtnClick")

        local cancelBtn = GUI.ButtonCreate(AttendantsGroupBg, "cancelBtn", "1800402080", 180, -20, Transition.ColorTint, "取消", 120, 45, false)
        GUI.ButtonSetTextFontSize(cancelBtn, 24)
        GUI.SetIsOutLine(cancelBtn, true)
        GUI.ButtonSetTextColor(cancelBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(cancelBtn, OutLine_BrownColor);
        GUI.SetOutLine_Distance(cancelBtn,OutLineDistance)
        SetSameAnchorAndPivot(cancelBtn, UILayout.BottomLeft)
        GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsGroupClose")

        local DetailsGroup = GUI.GroupCreate(AttendantsGroupBg,"DetailsGroup",120,-80,340,80,false)
        SetSameAnchorAndPivot(DetailsGroup, UILayout.Bottom)

        --侍从等级
        local GuardLevel = GUI.CreateStatic(DetailsGroup, "GuardLevel", "等        级", 0, -0, 100, 30)
        SetSameAnchorAndPivot(GuardLevel, UILayout.BottomLeft)
        UILayout.StaticSetFontSizeColorAlignment(GuardLevel, UIDefine.FontSizeM, UIDefine.BrownColor)
        local bg = GUI.ImageCreate(GuardLevel, "bg", "1800700010", 103, 0, false, 235, 33)
        SetSameAnchorAndPivot(bg, UILayout.Left)
        local txt = GUI.CreateStatic(bg, "txt", "", 0, 0, 330, 30, "system", true)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
        SetSameAnchorAndPivot(txt, UILayout.Center)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
        GUI.StaticSetText(txt,SelectAttendantsTable[1].Level)

        --侍从战力
        local GuardPower = GUI.CreateStatic(DetailsGroup, "GuardPower", "战        力", 0, 40, 200, 30)
        SetSameAnchorAndPivot(GuardPower, UILayout.BottomLeft)
        UILayout.StaticSetFontSizeColorAlignment(GuardPower, UIDefine.FontSizeM, UIDefine.BrownColor)

        local bg = GUI.ImageCreate(GuardPower, "bg", "1800700010", 103, 0, false, 235, 33)
        SetSameAnchorAndPivot(bg, UILayout.Left)
        local txt = GUI.CreateStatic(bg, "txt", "", 0, 0, 330, 30, "system", true)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
        SetSameAnchorAndPivot(txt, UILayout.Center)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
        GUI.StaticSetText(txt,SelectAttendantsTable[1].FightValue)

        --选择的侍从护卫
        local AddAttendantsLoop =
        GUI.LoopScrollRectCreate(
                AttendantsGroupBg,
                "AddAttendantsLoop",
                -30,
                80,
                80,
                330,
                "TradeRoadsUI",
                "CreateAddAttendantsItem",
                "TradeRoadsUI",
                "RefreshAddAttendantsItem",
                0,
                false,
                Vector2.New(75,75),
                1,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        SetSameAnchorAndPivot(AddAttendantsLoop, UILayout.TopRight)
        GUI.ScrollRectSetAlignment(AddAttendantsLoop, TextAnchor.UpperCenter)
        _gt.BindName(AddAttendantsLoop, "AddAttendantsLoop")
        GUI.LoopScrollRectSetTotalCount(AddAttendantsLoop, CenterBottomTaskTable[LastClickIndex3].EscortGuardNum)
        GUI.LoopScrollRectRefreshCells(AddAttendantsLoop)
        GUI.ScrollRectSetChildSpacing(AddAttendantsLoop, Vector2.New(0,3))
    else
        test("进入选择的护卫侍从界面的刷新")
        GUI.SetVisible(AttendantsGroup,true)
        if RefreshAttendantsTable[LastClickIndex1] == nil then
            AddAttendantsTable = {}
            for i = 1, #SelectAttendantsTable do
                SelectAttendantsTable[i].Status = 0
            end
        end
        --刷新右边选择侍从
        local AddAttendantsLoop = _gt.GetUI("AddAttendantsLoop")
        GUI.LoopScrollRectSetTotalCount(AddAttendantsLoop, CenterBottomTaskTable[LastClickIndex3].EscortGuardNum)
        GUI.LoopScrollRectRefreshCells(AddAttendantsLoop)

        test("SelectAttendantsTable",inspect(SelectAttendantsTable))

        --刷新左边侍从列表
        local SelectAttendantsLoop =  _gt.GetUI("SelectAttendantsLoop")
        GUI.LoopScrollRectSetTotalCount(SelectAttendantsLoop, #SelectAttendantsTable)
        GUI.LoopScrollRectRefreshCells(SelectAttendantsLoop)
        GUI.LoopScrollRectSrollToCell(SelectAttendantsLoop,0,0)
    end
end

--侍从护卫界面数据重置
function TradeRoadsUI.AttendantsGroupInit()
    test("侍从护卫界面数据重置")
    --获取最新的护卫侍从表单
    TradeRoadsUI.SetSelectAttendantsTable()

    AddAttendantsTable = {}

    --侍从护卫界面左边列表 上一个选择的侍从护卫的Id
    LastAttendantsId = nil

    --侍从护卫界面左边列表 上一个选择的侍从护卫的Guid
    LastAttendantsItemGuid = nil

    --选择护卫是否显示添加图片的开关
    AddAttendantsSwitch = 0

    --侍从护卫界面右边列表 上一个选择的控件的Guid
    LastAddAttendantsIconGuid = nil
    test("SelectAttendantsTable",inspect(SelectAttendantsTable))
    if RefreshAttendantsTable[LastClickIndex1] ~= nil then
        if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2] ~= nil then
            --这里进行左边侍从列表的处理
            for i = 1, #RefreshAttendantsTable[LastClickIndex1][LastClickIndex2] do
                if i ~= LastClickIndex3 then
                    if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][i] ~= nil then
                        for j = 1, #RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][i] do
                            local SelectGuardName = RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][i][j]
                            for k = 1, #SelectAttendantsTable do
                                local GuardName = SelectAttendantsTable[k].Name
                                if GuardName == SelectGuardName then
                                    SelectAttendantsTable[k].Status = 1
                                end
                            end
                        end
                    end

                end
            end

            --这里进行右边侍从列表的处理
            if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] ~= nil then
                local TableData = RefreshAttendantsTable[LastClickIndex1][LastClickIndex2][LastClickIndex3]
                for i = 1, #TableData do
                    local AttendantsDB = DB.GetOnceGuardByKey2(TableData[i])
                    local temp = {
                        Status = 1,
                        AttendantsId = AttendantsDB.Id
                    }
                    AddAttendantsTable[#AddAttendantsTable + 1] = temp
                end
            end
        end
    end
end

function TradeRoadsUI.CreateAddAttendantsItem()
    local SelectAttendantsLoop = _gt.GetUI("SelectAttendantsLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(SelectAttendantsLoop) + 1
    local AddAttendantsIcon = GUI.ItemCtrlCreate(SelectAttendantsLoop,"AddAttendantsIcon"..index,QualityRes[1],10,2,85,85,false,"system",false)

    --加号添加图片
    local AddImage = GUI.ImageCreate(AddAttendantsIcon,"AddImage","1800707060",0,0)
    GUI.SetVisible(AddImage,false)
    SetSameAnchorAndPivot(AddImage, UILayout.Center)

    --金色选择框图片
    local SelectImage = GUI.ImageCreate(AddAttendantsIcon,"SelectImage","1800400280",0,0)
    GUI.SetVisible(SelectImage,false)
    SetSameAnchorAndPivot(SelectImage, UILayout.Center)

    --X删除图片
    local DeleteButton = GUI.ButtonCreate(AddAttendantsIcon,"DeleteButton","1800702100",0,0,Transition.ColorTint)
    GUI.RegisterUIEvent(DeleteButton, UCE.PointerClick, "TradeRoadsUI", "OnDeleteButtonClick")
    GUI.SetVisible(DeleteButton,false)
    SetSameAnchorAndPivot(DeleteButton, UILayout.TopRight)

    return AddAttendantsIcon
end

function TradeRoadsUI.RefreshAddAttendantsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local AddAttendantsIcon = GUI.GetByGuid(guid)
    local AddImage = GUI.GetChild(AddAttendantsIcon,"AddImage",false)
    local SelectImage = GUI.GetChild(AddAttendantsIcon,"SelectImage",false)
    local DeleteButton = GUI.GetChild(AddAttendantsIcon,"DeleteButton",false)
    GUI.SetVisible(DeleteButton,false)
    GUI.SetVisible(SelectImage,false)
    local AttendantsData = AddAttendantsTable[index]
    GUI.SetData(AddAttendantsIcon,"AddAttendantsIconIndex",tostring(index))
    if AttendantsData ~= nil and AttendantsData.Status == 1 then
        local AttendantsId = tostring(AttendantsData.AttendantsId)
        local GuardDB = SelectAttendantsTable[SelectAttendantsTableClick[AttendantsId]]
        GUI.ItemCtrlSetElementValue(AddAttendantsIcon,eItemIconElement.Icon,tostring(GuardDB.Head))
        GUI.ItemCtrlSetElementValue(AddAttendantsIcon,eItemIconElement.Border,QualityRes[GuardDB.Grade])
        SelectAttendantsTable[SelectAttendantsTableClick[AttendantsId]].Status = 1
        test("重新设置侍从选择状态")
        GUI.RegisterUIEvent(AddAttendantsIcon, UCE.PointerClick, "TradeRoadsUI", "OnAddAttendantsIconClick")
        GUI.SetVisible(AddImage,false)
    else
        ItemIcon.SetEmpty(AddAttendantsIcon)
        if AttendantsData ==  nil then
            if index == #AddAttendantsTable + 1 then
                for i = 1, index do
                    if AddAttendantsTable[i] ~= nil then
                        if AddAttendantsTable[i].Status == 0 then
                            GUI.SetVisible(AddImage,false)
                            GUI.UnRegisterUIEvent(AddAttendantsIcon, UCE.PointerClick, "TradeRoadsUI", "OnAddAttendantsIconClick")
                        end
                    else
                        local NextAttendantsData = AddAttendantsTable[index + 1]
                        if NextAttendantsData == nil then
                            if index == 1 then
                                TradeRoadsUI.OnAddAttendantsIconClick(guid)
                                GUI.SetVisible(AddImage,true)
                                GUI.RegisterUIEvent(AddAttendantsIcon, UCE.PointerClick, "TradeRoadsUI", "OnAddAttendantsIconClick")
                            else
                                local LastAttendantsData = AddAttendantsTable[index + -1]
                                if LastAttendantsData ~= nil then
                                    TradeRoadsUI.OnAddAttendantsIconClick(guid)
                                    GUI.SetVisible(AddImage,true)
                                    GUI.RegisterUIEvent(AddAttendantsIcon, UCE.PointerClick, "TradeRoadsUI", "OnAddAttendantsIconClick")
                                end
                            end
                        end
                    end
                end
            else
                GUI.SetVisible(AddImage,false)
                GUI.UnRegisterUIEvent(AddAttendantsIcon, UCE.PointerClick, "TradeRoadsUI", "OnAddAttendantsIconClick")
            end
        end
        GUI.ItemCtrlSetElementValue(AddAttendantsIcon,eItemIconElement.Icon,"")
    end
end

--设置侍从Model
function TradeRoadsUI.SetAttendants(GuardId)
    if GuardId == nil then
        return
    end
    local AttendantsGroupBg = _gt.GetUI("AttendantsGroupBg")
    local GuardDB = DB.GetOnceGuardByKey1(GuardId)
    local ModelBg = GUI.GetChild(AttendantsGroupBg,"ModelBg",false)
    if not ModelBg then
        -- 侍从模型背景
        local ModelBg = GUI.ImageCreate(AttendantsGroupBg, "ModelBg", "1800400230", -180, 105,false,220,220,false)
        SetSameAnchorAndPivot(ModelBg, UILayout.TopRight)

        local ModelBottomImage = GUI.ImageCreate(ModelBg, "ModelBottomImage", "1800608320", 0, 60)
        SetSameAnchorAndPivot(ModelBottomImage, UILayout.Bottom)

        local RoleLstNodeModel=GUI.RawImageCreate(ModelBg,false,"RoleLstNodeModel","",0,0,2,false,420,420)
        RoleLstNodeModel:RegisterEvent(UCE.Drag)
        RoleLstNodeModel:RegisterEvent(UCE.PointerClick)
        GUI.AddToCamera(RoleLstNodeModel)
        SetSameAnchorAndPivot(RoleLstNodeModel, UILayout.Center)
        GUI.RawImageSetCameraConfig(RoleLstNodeModel, "(0,1.41,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,10,0.01,1.2,0")

        local RoleModel = GUI.RawImageChildCreate(RoleLstNodeModel, true, "GuardModel"..GuardId,"", 0, 0)
        _gt.BindName(RoleModel,"RoleModel")
        SetSameAnchorAndPivot(RoleModel, UILayout.Center)
        ModelItem.Bind(RoleModel, GuardDB.Model, GuardDB.ColorID1, GuardDB.ColorID2, eRoleMovement.ATTSTAND_W1)
        GUI.BindPrefabWithChild(RoleLstNodeModel, GUI.GetGuid(RoleModel))
        --设置侍从旋转站位
        GUI.RawImageChildSetModleRotation(RoleModel, Vector3.New(0,-20,0))

        --设置侍从护卫特效
        TradeRoadsUI.addRoleEffect(RoleModel,GuardId)

        --设置侍从护卫点击事件
        GUI.RegisterUIEvent(RoleLstNodeModel, UCE.PointerClick, "TradeRoadsUI", "OnSetAttendantsActionClick")
    else
        local RoleModel = _gt.GetUI("RoleModel")
        ModelItem.Bind(RoleModel, GuardDB.Model, GuardDB.ColorID1, GuardDB.ColorID2, eRoleMovement.ATTSTAND_W1)
        --设置侍从旋转站位
        GUI.RawImageChildSetModleRotation(RoleModel, Vector3.New(0,-40,0))

        --更新侍从护卫特效
        TradeRoadsUI.addRoleEffect(RoleModel,GuardId)
    end
end
--设置侍从护卫点击事件
function TradeRoadsUI.OnSetAttendantsActionClick()
    test("设置侍从护卫点击事件")
    local model = _gt.GetUI("RoleModel")
    if model then
        GUI.ReplaceWeapon(model,0,eRoleMovement.PHYATT_W1,0)
    end
end

--侍从护卫特效
function TradeRoadsUI.addRoleEffect(parent,guardId)

    -- 删除人物特效
    local DestroyRoleEffectID = DestroyRoleEffectTable[tostring(guardId)]
    if DestroyRoleEffectID ~= nil then -- 获取创建特效时得到的特效ID
        GUI.DestroyRoleEffect(parent,DestroyRoleEffectID)
        DestroyRoleEffectTable[tostring(guardId)] = nil
    end
    -- 获取人物当前星级
    local currentSelectedGuardStar = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(guardId)))

    -- 添加人物特效
    if currentSelectedGuardStar > 1 then -- 防止星级为1
        local newDestroyRoleEffectID =  GUI.CreateRoleEffect(parent, RoleEffectTable[currentSelectedGuardStar-1]) -- 添加人物特效
        -- 更新销毁人物特效ID
        DestroyRoleEffectTable[tostring(guardId)] = newDestroyRoleEffectID
    end
end

function TradeRoadsUI.CreateAttendantsListItem()
    local SelectAttendantsLoop = _gt.GetUI("SelectAttendantsLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(SelectAttendantsLoop) + 1

    local CheckBox = GUI.CheckBoxExCreate(SelectAttendantsLoop, "CheckBox"..index, "1800700030", "1800700040", 0, 0, false)
    GUI.RegisterUIEvent(CheckBox, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsListItemClick")

    local AttendantsItem = GUI.ItemCtrlCreate(CheckBox,"AttendantsItem",QualityRes[1],10,2,85,85,false,"system",false)
    GUI.ItemCtrlSetElementRect(AttendantsItem,eItemIconElement.Icon,0,-2,74,74)
    SetSameAnchorAndPivot(AttendantsItem, UILayout.Left)
    GUI.RegisterUIEvent(AttendantsItem, UCE.PointerClick, "TradeRoadsUI", "OnAttendantsItemIconClick")

    local RecommendImage = GUI.ImageCreate(AttendantsItem,"RecommendImage","1800805040",-10,-10,false,50,50)
    SetSameAnchorAndPivot(RecommendImage, UILayout.TopLeft)
    GUI.SetVisible(RecommendImage,true)

    local AddAttendantsImage = GUI.ImageCreate(AttendantsItem,"AddAttendantsImage","1800707350",0,0)
    SetSameAnchorAndPivot(AddAttendantsImage, UILayout.Center)
    GUI.SetVisible(AddAttendantsImage,false)

    local AttendantsName = GUI.CreateStatic(CheckBox,"AttendantsName","默认名字六个",35,15,180,40,"system",true,false)
    SetSameAnchorAndPivot(AttendantsName, UILayout.Top)
    GUI.StaticSetFontSize(AttendantsName, UIDefine.FontSizeL)
    GUI.SetColor(AttendantsName, UIDefine.BrownColor)

    for i = 1, AttendantStar do
        local StarImage = GUI.ImageCreate(CheckBox,"StarImage"..i,"1801202192",(i-1)*25-45,-20,false,25,25)
        SetSameAnchorAndPivot(StarImage, UILayout.Bottom)
    end

    local QualityImage = GUI.ImageCreate(CheckBox,"QualityImage",Quality[1],240,10)
    SetSameAnchorAndPivot(QualityImage, UILayout.TopLeft)

    local GuardTypeImage = GUI.ImageCreate(CheckBox,"GuardTypeImage",GuardType[1],-5,5)
    SetSameAnchorAndPivot(GuardTypeImage, UILayout.TopRight)

    return CheckBox
end

function TradeRoadsUI.RefreshAttendantsListItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local CheckBox = GUI.GetByGuid(guid)
    local AttendantsItem = GUI.GetChild(CheckBox,"AttendantsItem",false)
    local RecommendImage = GUI.GetChild(AttendantsItem,"RecommendImage",false)
    local AddAttendantsImage = GUI.GetChild(AttendantsItem,"AddAttendantsImage",false)
    local AttendantsName = GUI.GetChild(CheckBox,"AttendantsName",false)
    local QualityImage = GUI.GetChild(CheckBox,"QualityImage",false)

    local GuardData = SelectAttendantsTable[index]
    if GuardData ~= nil then
        local GuardId = tostring(GuardData.Id)
        GUI.CheckBoxExSetCheck(CheckBox,false)
        GUI.ItemCtrlSetElementValue(AttendantsItem,eItemIconElement.Icon,GuardData.Head)
        GUI.StaticSetText(AttendantsName,GuardData.Name)

        --进入选择第一个侍从护卫
        if  LastAttendantsId == nil then
            if index == 1 then
                GUI.CheckBoxExSetCheck(CheckBox,true)
                LastAttendantsId = GuardId
                LastAttendantsItemGuid = tostring(guid)
            end
        else
            if GuardId == LastAttendantsId then
                GUI.CheckBoxExSetCheck(CheckBox,true)
            end
        end

        --是否显示添加图片
        if AddAttendantsSwitch == 1 then
            if GuardData.Status == 1 then
                GUI.SetVisible(AddAttendantsImage,false)
            else
                GUI.SetVisible(AddAttendantsImage,true)
            end
        else
            GUI.SetVisible(AddAttendantsImage,false)
        end

        if GuardData.Arrange == 1 then
            GUI.SetVisible(RecommendImage,true)
        else
            GUI.SetVisible(RecommendImage,false)
        end

        if GuardData.Status == 1 then
            GUI.ItemCtrlSetIconGray(AttendantsItem,true)
            GUI.ItemCtrlSetElementValue(AttendantsItem,eItemIconElement.Border,QualityRes[1])
        else
            GUI.ItemCtrlSetIconGray(AttendantsItem,false)
            GUI.ItemCtrlSetElementValue(AttendantsItem,eItemIconElement.Border,QualityRes[GuardData.Grade])
        end
        --设置星级
        for i = 1, AttendantStar do
            local StarImage = GUI.GetChild(CheckBox,"StarImage"..i,false)
            if i <= GuardData.StarValue then
                GUI.ImageSetImageID(StarImage,"1801202190")
            else
                GUI.ImageSetImageID(StarImage,"1801202192")
            end
        end
        --设置侍从品质: SSR
        GUI.ImageSetImageID(QualityImage,Quality[GuardData.Quality])

        --绑定侍从护卫Id数据
        GUI.SetData(CheckBox,"AttendantsId",GuardId)

        --绑定侍从护卫等级数据
        GUI.SetData(CheckBox,"AttendantsLevel",tostring(GuardData.Level))

        --绑定侍从护卫等级战斗力数据
        GUI.SetData(CheckBox,"AttendantsPower",tostring(GuardData.FightValue))
    end
end

--获取最新的护卫侍从表单
function TradeRoadsUI.SetSelectAttendantsTable()
    SelectAttendantsTable = {}
    SelectAttendantsTableClick = {}
    local SelectTableData = {}
    if SubmitAllDataTable[LastClickIndex1] == nil then
        SubmitAllDataTable[LastClickIndex1] = {}
    end
    if SubmitAllDataTable[LastClickIndex1][LastClickIndex2] == nil  then
        SubmitAllDataTable[LastClickIndex1][LastClickIndex2] = {}
    end
    if SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] == nil then
        SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] = {}
    end
    if SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].SubmitAttendants == nil then
        SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].SubmitAttendants = {}
        --清空已经添加的选择的侍从护卫的表单
        AddAttendantsTable = {}
    end

    if RefreshAttendantsTable[LastClickIndex1] ~= nil then
        if RefreshAttendantsTable[LastClickIndex1][LastClickIndex2] ~= nil then
            local TableData = RefreshAttendantsTable[LastClickIndex1][LastClickIndex2]
            for k, v in pairs(TableData) do
                for i = 1, #v do
                    local AddAttendantsDB = DB.GetOnceGuardByKey2(v[i])
                    SelectTableData[tostring(AddAttendantsDB.Id)] = 1
                end
            end
        end
    end
    local GuardList = LD.GetGuardList_Have_Sorted()
    for i = 0, GuardList.Count-1 do
        local IsHave = LD.IsHaveGuard(GuardList[i])
        if IsHave then
            local GuardDB = DB.GetOnceGuardByKey1(GuardList[i])
            local GuardStatus = 0
            if SelectTableData[tostring(GuardDB.Id)] ~= nil then
                GuardStatus = SelectTableData[tostring(GuardDB.Id)]
            end
            local ArrangeStatus = 0
            for i = 1, #RecommendGuardTable do
                local GuardKeyName = RecommendGuardTable[i]
                if GuardDB.KeyName == GuardKeyName then
                    ArrangeStatus = 1
                end
            end
            local temp = {
                Id = GuardDB.Id,
                Guid = tostring(LD.GetGuardGUIDByID(GuardDB.Id)),
                KeyName = GuardDB.KeyName,
                Name = GuardDB.Name,
                Level = tostring(LD.GetGuardAttr(GuardDB.Id,RoleAttr.RoleAttrLevel)),
                StarValue = tonumber(CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardDB.Id)))),
                FightValue = tostring(LD.GetGuardAttr(GuardDB.Id,RoleAttr.RoleAttrFightValue)),
                Head = tostring(GuardDB.Head),
                Grade = GuardDB.Grade,
                Quality = GuardDB.Quality,
                Type = GuardDB.Type,
                Status = GuardStatus,--侍从护卫有没有被选中状态0没被选中,1为被选中
                Arrange = ArrangeStatus
            }
            SelectAttendantsTable[#SelectAttendantsTable + 1] = temp
        end
    end
    table.sort(SelectAttendantsTable,function (a,b)
        if a.Arrange ~= b.Arrange then
            return a.Arrange > b.Arrange
        end
        if a.Status ~= b.Status then
            return a.Status < b.Status
        end
        if a.Grade ~= b.Grade then
            return a.Grade > b.Grade
        end
        if a.StarValue ~= b.StarValue then
            return a.StarValue > b.StarValue
        end
        return false
    end)

    for i = 1, #SelectAttendantsTable do
        local GuardId = tostring(SelectAttendantsTable[i].Id)
        SelectAttendantsTableClick[GuardId] = i
        AddAttendantsTable[SelectAttendantsTableClick[GuardId]] = {}
        AddAttendantsTable[SelectAttendantsTableClick[GuardId]].Status = 1
        AddAttendantsTable[SelectAttendantsTableClick[GuardId]].AttendantsId = tonumber(GuardId)
    end
end

--关闭选择侍从护卫点击事件
function TradeRoadsUI.OnAttendantsGroupClose()
    test("关闭选择侍从护卫点击事件")
    local AttendantsGroup = _gt.GetUI("AttendantsGroup")
    GUI.SetVisible(AttendantsGroup,false)

    --重置侍从护卫界面数据
    TradeRoadsUI.ResetAttendantsGroupData()
end

--重置侍从护卫界面数据
function TradeRoadsUI.ResetAttendantsGroupData()

    --刷新左边侍从护卫列表
    local SelectAttendantsLoop = _gt.GetUI("SelectAttendantsLoop")
    GUI.LoopScrollRectSetTotalCount(SelectAttendantsLoop, #SelectAttendantsTable)
    GUI.LoopScrollRectRefreshCells(SelectAttendantsLoop)
    GUI.LoopScrollRectSrollToCell(SelectAttendantsLoop, 1, 0)

    --刷新右边侍从护卫选择列表
    local AddAttendantsLoop = _gt.GetUI("AddAttendantsLoop")
    GUI.LoopScrollRectSetTotalCount(AddAttendantsLoop, CenterBottomTaskTable[LastClickIndex3].EscortGuardNum)
    GUI.LoopScrollRectRefreshCells(AddAttendantsLoop)
    GUI.LoopScrollRectSrollToCell(AddAttendantsLoop, 1, 0)

    --更新侍从护卫等级、战斗力
    TradeRoadsUI.UpDateAttendantsData(SelectAttendantsTable[1].Level,SelectAttendantsTable[1].FightValue)

    --重置侍从护卫Model
    TradeRoadsUI.SetAttendants(SelectAttendantsTable[1].Id)
end

--选择贸易物品点击事件
function TradeRoadsUI.OnPropItemClick()
    test("选择贸易物品点击事件")
    if TradeRoadsStatus == 1 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "您已开始贸易,无法选择")
        test("您已开始贸易,无法选择")
    elseif TradeRoadsStatus == 2 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "今日贸易已完成,无法选择")
        test("今日贸易已完成,无法选择")
    else
        TradeRoadsUI.UnRegisterPropItem()
        TradeRoadsUI.RegisterPropItem()
        TradeRoadsUI.CreatePropGroup()
    end

end

--创建选择贸易物品点击事件
function TradeRoadsUI.CreatePropGroup()
    local wnd = GUI.GetWnd("TradeRoadsUI")
    local PropGroup = GUI.GetChild(wnd,"PropGroup",false)

    --获取最新的可选择贸易物品表单
    TradeRoadsUI.SetSelectPropTable()

    if not PropGroup then
        test("进入上交选择的贸易物品的创建")
        local PropGroup = GUI.GroupCreate(wnd, "PropGroup", 0, 0, GUI.GetWidth(wnd), GUI.GetHeight(wnd),false)
        _gt.BindName(PropGroup,"PropGroup")

        -- 底图
        local PropGroupBg = UILayout.CreateFrame_WndStyle2(PropGroup,"贸易物品选择",460,500,"TradeRoadsUI","OnPropGroupClose")

        local CenterBg = GUI.ImageCreate(PropGroupBg, "CenterBg", "1800400200", 0, 5, false, 418, 340)

        local pnSellout = GUI.ImageCreate(CenterBg, "pnSellout", "1801100010", 0, 0, false, 340, 100)
        _gt.BindName(pnSellout, "pnSellout")
        SetSameAnchorAndPivot(pnSellout, UILayout.Center)
        GUI.SetVisible(pnSellout, false)

        local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "没有可选择的物品", 0, 0, 260, 50, "system", true)
        SetSameAnchorAndPivot(txtSellout, UILayout.Center)
        GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
        GUI.StaticSetFontSize(txtSellout, 28)
        GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
        GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleCenter)

        local SelectPropLoop =
        GUI.LoopScrollRectCreate(
                CenterBg,
                "SelectPropLoop",
                6,
                -4,
                GUI.GetWidth(CenterBg)-5,
                GUI.GetHeight(CenterBg)-10,
                "TradeRoadsUI",
                "CreatePropListItem",
                "TradeRoadsUI",
                "RefreshPropListItem",
                0,
                false,
                Vector2.New(100,100),
                RefreshPropLoopCount,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        SetSameAnchorAndPivot(SelectPropLoop, UILayout.BottomLeft)
        GUI.ScrollRectSetAlignment(SelectPropLoop, TextAnchor.UpperCenter)
        _gt.BindName(SelectPropLoop, "SelectPropLoop")
        if #SelectPropTable > 0 then
            GUI.LoopScrollRectSetTotalCount(SelectPropLoop, TradeRoadsUI.UpdatePresentList(#SelectPropTable))
            GUI.LoopScrollRectRefreshCells(SelectPropLoop)
            GUI.ScrollRectSetChildSpacing(SelectPropLoop, Vector2.New(2,0 ))
        else
            GUI.SetVisible(pnSellout,true)
        end

        local confirmBtn = GUI.ButtonCreate(PropGroupBg, "confirmBtn", "1800402080", 100, 210, Transition.ColorTint, "选择", 120, 45, false)
        GUI.ButtonSetTextFontSize(confirmBtn, 24)
        GUI.SetIsOutLine(confirmBtn, true)
        GUI.ButtonSetTextFontSize(confirmBtn, UIDefine.FontSizeXL)
        GUI.ButtonSetTextColor(confirmBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(confirmBtn, OutLine_BrownColor);
        GUI.SetOutLine_Distance(confirmBtn,OutLineDistance)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "TradeRoadsUI", "OnItemConfirmBtnClick")

        local cancelBtn = GUI.ButtonCreate(PropGroupBg, "cancelBtn", "1800402080", -100, 210, Transition.ColorTint, "取消", 120, 45, false)
        GUI.ButtonSetTextFontSize(cancelBtn, 24)
        GUI.SetIsOutLine(cancelBtn, true)
        GUI.ButtonSetTextColor(cancelBtn, UIDefine.WhiteColor)
        GUI.SetOutLine_Color(cancelBtn, OutLine_BrownColor);
        GUI.SetOutLine_Distance(cancelBtn,OutLineDistance)
        GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick, "TradeRoadsUI", "OnPropGroupClose")

    else
        test("进入上交选择的贸易物品的刷新")
        GUI.SetVisible(PropGroup,true)
        local pnSellout = _gt.GetUI("pnSellout")
        local SelectPropLoop = _gt.GetUI("SelectPropLoop")
        if #SelectPropTable > 0 then
            GUI.SetVisible(pnSellout,false)
            GUI.LoopScrollRectSetTotalCount(SelectPropLoop, TradeRoadsUI.UpdatePresentList(#SelectPropTable))
            GUI.LoopScrollRectRefreshCells(SelectPropLoop)
            GUI.LoopScrollRectSrollToCell(SelectPropLoop, 1, 0)
        else
            GUI.LoopScrollRectSetTotalCount(SelectPropLoop, 0)
            GUI.LoopScrollRectRefreshCells(SelectPropLoop)
            GUI.SetVisible(pnSellout,true)
        end
    end
end

function TradeRoadsUI.CreatePropListItem()
    local SelectPropLoop = _gt.GetUI("SelectPropLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(SelectPropLoop) + 1

    local SelectItem = GUI.ItemCtrlCreate(SelectPropLoop,"SelectItem"..index,QualityRes[1],0,0,70,70,false,"system",false)
    GUI.ItemCtrlSetElementRect(SelectItem,eItemIconElement.Icon,0,0,80,80)
    GUI.ItemCtrlSetElementRect(SelectItem,eItemIconElement.RightBottomNum,10,7)
    GUI.RegisterUIEvent(SelectItem, UCE.PointerClick, "TradeRoadsUI", "OnSelectItemClick")

    local DecreaseBtn = GUI.ButtonCreate(SelectItem,"DecreaseBtn", "1800702070", -1, 0, Transition.ColorTint)
    GUI.RegisterUIEvent(DecreaseBtn, UCE.PointerClick, "TradeRoadsUI", "OnItemIconReduceBtnClick")
    GUI.SetVisible(DecreaseBtn, false)
    SetSameAnchorAndPivot(DecreaseBtn, UILayout.TopRight)

    return SelectItem
end

function TradeRoadsUI.RefreshPropListItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local SelectItem = GUI.GetByGuid(guid)
    local DecreaseBtn = GUI.GetChild(SelectItem,"DecreaseBtn",false)

    ItemIcon.SetEmpty(SelectItem)
    GUI.SetVisible(DecreaseBtn, false)
    if index <= #SelectPropTable then
        local Data = SelectPropTable[index]
        GUI.ItemCtrlSetElementValue(SelectItem,eItemIconElement.Icon,Data.Icon)
        if tonumber(Data.Amount) > 0 then
            GUI.ItemCtrlSetElementValue(SelectItem,eItemIconElement.Border,QualityRes[Data.Grade])
            GUI.ItemCtrlSetElementValue(SelectItem,eItemIconElement.RightBottomNum,Data.ClickNum.."/"..Data.Amount)
        else
            GUI.ItemCtrlSetIconGray(SelectItem,true)
        end

        if Data.IsBound == 1 then
            GUI.ItemCtrlSetElementValue(SelectItem,eItemIconElement.LeftTopSp,"1800707120")--是否为绑定
        end
        GUI.RegisterUIEvent(SelectItem, UCE.PointerClick, "TradeRoadsUI", "OnSelectItemClick")
        GUI.SetData(SelectItem,"ItemId",Data.Id)
        GUI.SetData(SelectItem,"IsBound",Data.IsBound)
        GUI.SetData(SelectItem,"Amount",Data.Amount)
        if Data.ClickNum > 0 then
            GUI.SetVisible(DecreaseBtn, true)
        else
            GUI.SetVisible(DecreaseBtn, false)
        end
    else
        GUI.UnRegisterUIEvent(SelectItem, UCE.PointerClick, "TradeRoadsUI", "OnSelectItemClick")
    end
end

--配置可上交的物品表单
function TradeRoadsUI.SetSelectPropTable()
    test("配置可上交的物品表单")
    SelectPropTable = {}
    SelectPropTableClick = {}

    local TableData = RefreshPropTable[LastClickIndex1][LastClickIndex2][LastClickIndex3]
    test("TableData",inspect(TableData))
    local ScreenTable1 = {}
    for i = 1, #TableData do
        if ScreenTable1[TableData[i].KeyName] == nil then
            ScreenTable1[TableData[i].KeyName] = {}
        end
        if ScreenTable1[TableData[i].KeyName][TableData[i].IsBound] == nil then
            ScreenTable1[TableData[i].KeyName][TableData[i].IsBound] = {}
        end
        ScreenTable1[TableData[i].KeyName][TableData[i].IsBound].ClickNum = TableData[i].ClickNum
    end

    local ScreenTable2 = {}
    local TableData2 = RefreshPropTable[LastClickIndex1][LastClickIndex2]
    for i, v1 in ipairs(TableData2) do
        for k, v2 in ipairs(TableData2[i]) do
            if i ~=  LastClickIndex3 then
                if ScreenTable2[v2.KeyName] == nil then
                    ScreenTable2[v2.KeyName] = {}
                end
                if ScreenTable2[v2.KeyName][v2.IsBound] == nil then
                    ScreenTable2[v2.KeyName][v2.IsBound] = {}
                end
                if ScreenTable2[v2.KeyName][v2.IsBound].TableAmount == nil then
                    ScreenTable2[v2.KeyName][v2.IsBound].TableAmount = 0
                end
                ScreenTable2[v2.KeyName][v2.IsBound].TableAmount =  ScreenTable2[v2.KeyName][v2.IsBound].TableAmount + v2.ClickNum
            end
        end
    end

    local CombineTable = {}
    local BagItemCount = LD.GetItemCount(item_container_type.item_container_bag,0)
    for i = 0, BagItemCount-1 do
        local itemData = LD.GetItemDataByItemIndex(i,item_container_type.item_container_bag,0)
        local itemDB = DB.GetOnceItemByKey1(itemData.id)
        if ScreenTable1[itemDB.KeyName] ~= nil then
            local TableClickNum = 0
            if ScreenTable1[itemDB.KeyName][itemData.isbound] ~= nil then
                TableClickNum = ScreenTable1[itemDB.KeyName][itemData.isbound].ClickNum
            end

            local TableAmount = 0
            if ScreenTable2[itemDB.KeyName] ~= nil then
                if ScreenTable2[itemDB.KeyName][itemData.isbound] ~= nil  then
                    TableAmount = ScreenTable2[itemDB.KeyName][itemData.isbound].TableAmount
                end
            end

            if CombineTable[itemDB.KeyName] == nil then
                CombineTable[itemDB.KeyName] = {}
            end
            if CombineTable[itemDB.KeyName][itemData.isbound] == nil then
                CombineTable[itemDB.KeyName][itemData.isbound] = {}
                local temp = {
                    Id = itemDB.Id,
                    Name = itemDB.Name,
                    KeyName = itemDB.KeyName,
                    Icon = tostring(itemDB.Icon),
                    Subtype = itemDB.Subtype,
                    Subtype2 = itemDB.Subtype2,
                    IsBound = itemData.isbound,
                    Amount = tonumber(itemData.amount) - TableAmount ,
                    Grade =itemDB.Grade,
                    ClickNum = TableClickNum,
                    Status  = 1
                }
                CombineTable[itemDB.KeyName][itemData.isbound] = temp
            else
                CombineTable[itemDB.KeyName][itemData.isbound].Amount = CombineTable[itemDB.KeyName][itemData.isbound].Amount + itemData.amount
            end
        end
    end

    if next(CombineTable) then
        for i, v1 in pairs(CombineTable) do
            for k, v2 in pairs(CombineTable[i]) do
                SelectPropTable[#SelectPropTable + 1] = v2
                if SelectPropTableClick[tostring(v2.Id)] == nil then
                    SelectPropTableClick[tostring(v2.Id)] = {}
                end
                SelectPropTableClick[tostring(v2.Id)][v2.IsBound] = #SelectPropTable
            end
        end
    end

    for i = 1, #TableData do
        local ItemData = TableData[i]
        local ItemDB = DB.GetOnceItemByKey2(ItemData.KeyName)
        if CombineTable[ItemDB.KeyName] == nil then
            local temp = {
                Id = ItemDB.Id,
                Name = ItemDB.Name,
                KeyName = ItemDB.KeyName,
                Icon = tostring(ItemDB.Icon),
                Subtype = ItemDB.Subtype,
                Subtype2 = ItemDB.Subtype2,
                IsBound = 0,
                Amount = 0,
                Grade =ItemDB.Grade,
                ClickNum = 0,
                Status  = 0
            }
            SelectPropTable[#SelectPropTable + 1] = temp
            if SelectPropTableClick[tostring(ItemDB.Id)] == nil then
                SelectPropTableClick[tostring(ItemDB.Id)] = {}
            end
            SelectPropTableClick[tostring(ItemDB.Id)][0] = #SelectPropTable
        end
    end

    CombineTable = {}
    local BagItemCount = LD.GetItemCount(item_container_type.item_container_gem_bag,0)
    for i = 0, BagItemCount-1 do
        local itemData = LD.GetItemDataByItemIndex(i,item_container_type.item_container_gem_bag,0)
        local itemDB = DB.GetOnceItemByKey1(itemData.id)
        if ScreenTable1[itemDB.KeyName] ~= nil then
            if CombineTable[itemDB.KeyName] == nil then
                CombineTable[itemDB.KeyName] = {}
            end
            local TableAmount = 0
            if ScreenTable2[itemDB.KeyName] ~= nil then
                if ScreenTable2[itemDB.KeyName][itemData.isbound] ~= nil  then
                    TableAmount = ScreenTable2[itemDB.KeyName][itemData.isbound].TableAmount
                end
            end
            if CombineTable[itemDB.KeyName][itemData.isbound] == nil then
                CombineTable[itemDB.KeyName][itemData.isbound] = {}
                local temp = {
                    Id = itemDB.Id,
                    Name = itemDB.Name,
                    KeyName = itemDB.KeyName,
                    Icon = itemDB.Icon,
                    Subtype = itemDB.Subtype,
                    Subtype2 = itemDB.Subtype2,
                    IsBound = itemData.isbound,
                    Amount = tonumber(itemData.amount) - TableAmount,
                    Grade =itemDB.Grade,
                    ClickNum = 0,
                    Status  = 1
                }
                CombineTable[itemDB.KeyName][itemData.isbound] = temp
            else
                CombineTable[itemDB.KeyName][itemData.isbound].Amount = CombineTable[itemDB.KeyName][itemData.isbound].Amount + itemData.amount
            end
        end
    end


    if next(CombineTable) then
        for i, v1 in pairs(CombineTable) do
            for k, v2 in pairs(CombineTable[i]) do
                SelectPropTable[#SelectPropTable + 1] = v2
            end
        end
    end
    table.sort(SelectPropTable,function(a,b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        end
        if a.IsBound ~= b.IsBound then
            return a.IsBound > b.IsBound
        end
        return false
    end )
    for i = 1, #SelectPropTable do
        local TableData = SelectPropTable[i]
        if SelectPropTableClick[tostring(TableData.Id)] == nil then
            SelectPropTableClick[tostring(TableData.Id)] = {}
        end
        SelectPropTableClick[tostring(TableData.Id)][TableData.IsBound] = i
    end
    test("包裹列表的刷新SelectPropTable",inspect(SelectPropTable))
    end

--设置上交选择的贸易物品的刷新的格子数
function TradeRoadsUI.UpdatePresentList(amount)
    local Count = RefreshPropLoopCount * RefreshPropLoopCount
    -- 补足额外的道具格子
    if Count < amount then
        Count = RefreshPropLoopCount * math.ceil(amount / RefreshPropLoopCount)
    end
    return Count
end

--增加选择的贸易物品点击事件
function TradeRoadsUI.OnSelectItemClick(guid)
    local SelectItem = GUI.GetByGuid(guid)
    local DecreaseBtn = GUI.GetChild(SelectItem,"DecreaseBtn",false)
    local ItemId = GUI.GetData(SelectItem,"ItemId")
    local IsBound = tonumber(GUI.GetData(SelectItem,"IsBound"))
    local Amount = tonumber(GUI.GetData(SelectItem,"Amount"))
    if Amount > 0 then
        local index = SelectPropTableClick[ItemId][IsBound]
        if SelectPropTable[index].ClickNum < SelectPropTable[index].Amount then
            SelectPropTable[index].ClickNum = SelectPropTable[index].ClickNum + 1
            GUI.ItemCtrlSetElementValue(SelectItem,eItemIconElement.RightBottomNum,SelectPropTable[index].ClickNum.."/"..SelectPropTable[index].Amount)
            GUI.SetVisible(DecreaseBtn,true)
        end
    else
        local parent = GUI.GetWnd("TradeRoadsUI")
        local tips = Tips.CreateByItemId(ItemId,parent,"AcquireTips",0,0,30)
        SetSameAnchorAndPivot(tips, UILayout.Center)
        GUI.SetData(tips, "ItemId", ItemId)
        _gt.BindName(tips,"AcquireTips")
        local wayBtn = GUI.ButtonCreate(tips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false)
        SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"TradeRoadsUI","OnClickAcquireTipsBtn")
        GUI.AddWhiteName(tips, GUI.GetGuid(wayBtn))
    end
end

--减少选择的贸易物品点击事件
function TradeRoadsUI.OnItemIconReduceBtnClick(guid)
    local DecreaseBtn = GUI.GetByGuid(guid)
    local SelectItem = GUI.GetParentElement(DecreaseBtn)
    local ItemId = GUI.GetData(SelectItem,"ItemId")
    local IsBound = tonumber(GUI.GetData(SelectItem,"IsBound"))
    local index = SelectPropTableClick[ItemId][IsBound]
    if SelectPropTable[index].ClickNum > 0 then
        SelectPropTable[index].ClickNum = SelectPropTable[index].ClickNum - 1
        GUI.ItemCtrlSetElementValue(SelectItem,eItemIconElement.RightBottomNum,SelectPropTable[index].ClickNum.."/"..SelectPropTable[index].Amount)
        if SelectPropTable[index].ClickNum == 0 then
            GUI.SetVisible(DecreaseBtn,false)
        end
    end
end

--上交选择的侍从护卫点击事件
function TradeRoadsUI.OnSubmitAttendantsBtnClick()
    test("上交选择的侍从护卫点击事件")
    local SubmitAttendants = ""
    if #AddAttendantsTable > 0 then
        SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].SubmitAttendants = {}
        for i = 1, #AddAttendantsTable do
            local temp = {
                AttendantsId = AddAttendantsTable[i].AttendantsId,
                Grade = tonumber(SelectAttendantsTable[SelectAttendantsTableClick[tostring(AddAttendantsTable[i].AttendantsId)]].Grade),
                Guid = tostring(SelectAttendantsTable[SelectAttendantsTableClick[tostring(AddAttendantsTable[i].AttendantsId)]].Guid),
                Status = tonumber(SelectAttendantsTable[SelectAttendantsTableClick[tostring(AddAttendantsTable[i].AttendantsId)]].Status)
            }
            SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].SubmitAttendants[#SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].SubmitAttendants + 1] = temp
        end
        table.sort(SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].SubmitAttendants,function (a,b)
            if a.Grade ~= b.Grade then
                return a.Grade > b.Grade
            end
            return false
        end)

        local TableData = SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].SubmitAttendants

        for i = 1, #TableData do
            local AttendantsDB = DB.GetOnceGuardByKey1(tonumber(TableData[i].AttendantsId))
            SubmitAttendants = SubmitAttendants..AttendantsDB.KeyName..","
        end
    end
    test("提交的侍从",tostring(SubmitAttendants))
    CL.SendNotify(NOTIFY.SubmitForm,"FormTrade","SelectGuard",Version,LastClickIndex1,LastClickIndex2,LastClickIndex3,SubmitAttendants)
    TradeRoadsUI.OnAttendantsGroupClose()
end

--上交选择的贸易物品点击事件
function TradeRoadsUI.OnItemConfirmBtnClick()
    test("上交选择的贸易物品点击事件")
    if #SelectPropTable > 0 then
        if SubmitAllDataTable[LastClickIndex1] == nil then
            SubmitAllDataTable[LastClickIndex1] = {}
        end
        if SubmitAllDataTable[LastClickIndex1][LastClickIndex2] == nil then
            SubmitAllDataTable[LastClickIndex1][LastClickIndex2] = {}
        end
        if SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] == nil then
            SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3] = {}
        end
        SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].ItemConfirm = {}
        for i = 1, #SelectPropTable do
            local data = SelectPropTable[i]
            if tonumber(data.ClickNum) > 0 then
                local temp = {
                    Id = tonumber(data.Id),
                    Icon = data.Icon,
                    IsBound = data.IsBound,
                    ClickNum = data.ClickNum,
                    ItemNum = data.ItemNum,
                    Grade = tonumber(data.Grade),
                    Guid = tostring(data.Guid),
                    CanSubmit = tonumber(data.ItemNum) == tonumber(data.ClickNum),
                    KeyName = data.KeyName
                }
                SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].ItemConfirm[#SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].ItemConfirm + 1] = temp
            end
        end
        table.sort(SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].ItemConfirm,function (a,b)
            if a.Grade ~= b.Grade then
                return a.Grade > b.Grade
            end
            if a.Id ~= b.Id then
                return a.Id < b.Id
            end
            return false
        end)
        local SubmitItemData = ""
        if SelectSubmitTableData[LastClickIndex1] == nil then
            SelectSubmitTableData[LastClickIndex1] = {}
        end
        if SelectSubmitTableData[LastClickIndex1][LastClickIndex2] == nil then
            SelectSubmitTableData[LastClickIndex1][LastClickIndex2] = {}
        end
        SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3] = {}
        for i = 1, #SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].ItemConfirm do
            local TableData = SubmitAllDataTable[LastClickIndex1][LastClickIndex2][LastClickIndex3].ItemConfirm[i]
            if SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3][TableData.KeyName] == nil then
                SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3][TableData.KeyName] = {}
            end
            if SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3] [TableData.KeyName][TableData.IsBound] == nil then
                SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3] [TableData.KeyName][TableData.IsBound] = {}
            end
            if SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3] [TableData.KeyName][TableData.IsBound].ClickNum == nil then
                SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3] [TableData.KeyName][TableData.IsBound].ClickNum = 0
            end
            SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3][TableData.KeyName][TableData.IsBound].ClickNum = SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3][TableData.KeyName][TableData.IsBound].ClickNum + TableData.ClickNum
        end
        for i, j in pairs(SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3]) do
            for k, v in pairs(SelectSubmitTableData[LastClickIndex1][LastClickIndex2][LastClickIndex3][i]) do
                test("i-----------",tostring(i))
                test("k-----------",tostring(k))
                SubmitItemData = SubmitItemData..tostring(i)..","..tostring(v.ClickNum)..","..tostring(k)..","
            end
        end
        test("上交选择的贸易物品:",tostring(SubmitItemData))
        CL.SendNotify(NOTIFY.SubmitForm,"FormTrade","SelectGoods",Version,LastClickIndex1,LastClickIndex2,LastClickIndex3,SubmitItemData)
    end
    TradeRoadsUI.OnPropGroupClose()
end

--关闭选择贸易物品点击事件
function TradeRoadsUI.OnPropGroupClose()
    test("关闭选择贸易物品点击事件")
    TradeRoadsUI.UnRegisterPropItem()
    local PropGroup = _gt.GetUI("PropGroup")
    GUI.SetVisible(PropGroup,false)
end

--侍从护卫左边选择列表Icon点击事件
function TradeRoadsUI.OnAttendantsItemIconClick(guid)
    local AttendantsItem = GUI.GetByGuid(guid)
    local CheckBox = GUI.GetParentElement(AttendantsItem)
    local CheckBoxGuid = GUI.GetGuid(CheckBox)
    TradeRoadsUI.OnAttendantsListItemClick(CheckBoxGuid)
end


--侍从护卫左边选择列表点击事件
function TradeRoadsUI.OnAttendantsListItemClick(guid)
    test("侍从护卫左边选择列表点击事件")
    local CheckBox = GUI.GetByGuid(guid)
    local AttendantsId =  GUI.GetData(CheckBox,"AttendantsId")
    local SelectAttendantsTableIndex = SelectAttendantsTableClick[AttendantsId]
    local AttendantsLevel =  GUI.GetData(CheckBox,"AttendantsLevel")
    local AttendantsPower =  GUI.GetData(CheckBox,"AttendantsPower")
    if AttendantsId ~= LastAttendantsId then
        GUI.CheckBoxExSetCheck(CheckBox,true)
        if LastAttendantsId ~= nil then
            local LastCheckBox = GUI.GetByGuid(LastAttendantsItemGuid)
            GUI.CheckBoxExSetCheck(LastCheckBox,false)
        end
    end
    TradeRoadsUI.SetAttendants(AttendantsId)

    if AddAttendantsSwitch == 1 then
        local LastCheckBox = GUI.GetByGuid(LastAddAttendantsIconGuid)
        local LastAddAttendantsIconIndex = tonumber(GUI.GetData(LastCheckBox,"AddAttendantsIconIndex"))
        if AddAttendantsTable[LastAddAttendantsIconIndex] ~= nil then
            local LastAttendantsId = tostring(AddAttendantsTable[LastAddAttendantsIconIndex].AttendantsId)
            local LastSelectAttendantsTableIndex = SelectAttendantsTableClick[LastAttendantsId]
            SelectAttendantsTable[LastSelectAttendantsTableIndex].Status = 0
        end
        TradeRoadsUI.OnAddAttendantsIconClick(LastAddAttendantsIconGuid)
        if SelectAttendantsTable[SelectAttendantsTableIndex].Status == 0 then
            AddAttendantsTable[tonumber(LastAddAttendantsIconIndex)] = {}
            AddAttendantsTable[tonumber(LastAddAttendantsIconIndex)].Status = 1
            AddAttendantsTable[tonumber(LastAddAttendantsIconIndex)].AttendantsId = AttendantsId
            SelectAttendantsTable[SelectAttendantsTableIndex].Status = 1
        end
        --刷新右边侍从护卫选择列表
        local AddAttendantsLoop = _gt.GetUI("AddAttendantsLoop")
        GUI.LoopScrollRectSetTotalCount(AddAttendantsLoop, CenterBottomTaskTable[LastClickIndex3].EscortGuardNum)
        GUI.LoopScrollRectRefreshCells(AddAttendantsLoop)
    end

    LastAttendantsId = AttendantsId
    LastAttendantsItemGuid = tostring(guid)

    --更新侍从护卫等级、战斗力
    TradeRoadsUI.UpDateAttendantsData(AttendantsLevel,AttendantsPower)

    AddAttendantsSwitch = 0

    --刷新左边侍从护卫列表
    local SelectAttendantsLoop = _gt.GetUI("SelectAttendantsLoop")
    GUI.LoopScrollRectSetTotalCount(SelectAttendantsLoop, #SelectAttendantsTable)
    GUI.LoopScrollRectRefreshCells(SelectAttendantsLoop)

    if LastAddAttendantsIconGuid ~= nil then
        local LastAddAttendantsIcon = GUI.GetByGuid(LastAddAttendantsIconGuid)
        local LastSelectImage = GUI.GetChild(LastAddAttendantsIcon,"SelectImage",false)
        GUI.SetVisible(LastSelectImage,false)
    end
end

--更新侍从护卫等级、战斗力
function TradeRoadsUI.UpDateAttendantsData(AttendantsLevel,AttendantsPower)
    --更新侍从护卫等级、战斗力
    local AttendantsGroupBg = _gt.GetUI("AttendantsGroupBg")
    local DetailsGroup = GUI.GetChild(AttendantsGroupBg,"DetailsGroup",false)

    --侍从护卫等级
    local GuardLevel = GUI.GetChild(DetailsGroup,"GuardLevel",false)
    local bg = GUI.GetChild(GuardLevel,"bg",false)
    local txt = GUI.GetChild(bg,"txt",false)
    GUI.StaticSetText(txt,AttendantsLevel)

    --侍从护卫战斗力
    local GuardPower = GUI.GetChild(DetailsGroup,"GuardPower",false)
    local bg = GUI.GetChild(GuardPower,"bg",false)
    local txt = GUI.GetChild(bg,"txt",false)
    GUI.StaticSetText(txt,AttendantsPower)
end

--删除侍从护卫界面右边选择Icon点击事件
function TradeRoadsUI.OnDeleteButtonClick(guid)
    test("删除侍从护卫界面右边选择Icon点击事件")
    local DeleteButton = GUI.GetByGuid(guid)
    local AddAttendantsIcon = GUI.GetParentElement(DeleteButton)
    local AddAttendantsIconIndex = tonumber(GUI.GetData(AddAttendantsIcon,"AddAttendantsIconIndex"))
    local AttendantsId = tostring(AddAttendantsTable[AddAttendantsIconIndex].AttendantsId)
    local SelectAttendantsTableIndex = SelectAttendantsTableClick[AttendantsId]
    SelectAttendantsTable[SelectAttendantsTableIndex].Status = 0
    table.remove(AddAttendantsTable,AddAttendantsIconIndex)
    GUI.SetVisible(DeleteButton,false)
    TradeRoadsUI.OnAddAttendantsIconClick(LastAddAttendantsIconGuid)

    AddAttendantsSwitch = 0
    --刷新右边侍从护卫选择列表
    local AddAttendantsLoop = _gt.GetUI("AddAttendantsLoop")
    GUI.LoopScrollRectSetTotalCount(AddAttendantsLoop, CenterBottomTaskTable[LastClickIndex3].EscortGuardNum)
    GUI.LoopScrollRectRefreshCells(AddAttendantsLoop)
end

--选择侍从护卫界面右边选择Icon点击事件
function TradeRoadsUI.OnAddAttendantsIconClick(guid)
    test("选择侍从护卫界面右边选择Icon点击事件")
    local AddAttendantsIcon = GUI.GetByGuid(guid)
    local SelectImage = GUI.GetChild(AddAttendantsIcon,"SelectImage",false)
    local AddAttendantsIndex = tonumber(GUI.GetData(AddAttendantsIcon,"AddAttendantsIconIndex"))
    local DeleteButton = GUI.GetChild(AddAttendantsIcon,"DeleteButton",false)

    if tostring(guid) ~= LastAddAttendantsIconGuid then
        GUI.SetVisible(SelectImage,true)
        if LastAddAttendantsIconGuid ~= nil then
            local LastAddAttendantsIcon = GUI.GetByGuid(LastAddAttendantsIconGuid)
            local LastSelectImage = GUI.GetChild(LastAddAttendantsIcon,"SelectImage",false)
            local LastDeleteButton = GUI.GetChild(LastAddAttendantsIcon,"DeleteButton",false)
            GUI.SetVisible(LastSelectImage,false)
            GUI.SetVisible(LastDeleteButton,false)
        end
        LastAddAttendantsIconGuid = tostring(guid)
        AddAttendantsSwitch = 1
        if AddAttendantsTable[AddAttendantsIndex] ~= nil then
            if AddAttendantsTable[AddAttendantsIndex].Status == 1 then
                GUI.SetVisible(DeleteButton,true)
            end
        end
    else
        if AddAttendantsSwitch == 1 then
            AddAttendantsSwitch = 0
            GUI.SetVisible(SelectImage,false)
            if AddAttendantsTable[AddAttendantsIndex] ~= nil then
                GUI.SetVisible(DeleteButton,false)
            end
        else
            GUI.SetVisible(SelectImage,true)
            if AddAttendantsTable[AddAttendantsIndex] ~= nil then
                GUI.SetVisible(DeleteButton,true)
            end
            AddAttendantsSwitch = 1
        end
    end

    --刷新左边侍从护卫列表
    local SelectAttendantsLoop = _gt.GetUI("SelectAttendantsLoop")
    GUI.LoopScrollRectSetTotalCount(SelectAttendantsLoop, #SelectAttendantsTable)
    GUI.LoopScrollRectRefreshCells(SelectAttendantsLoop)
end

function TradeRoadsUI.OnExit()
    GUI.CloseWnd("TradeRoadsUI")
    TradeRoadsUI.StopRefreshTimer()
    TradeRoadsUI.ResetUIData()
end

--计时器启动
function TradeRoadsUI.StartTimer()
    test("计时器启动")
    local fun = function()
        TradeRoadsUI.TimerCallBack()
    end
    TradeRoadsUI.StopRefreshTimer()
    TradeRoadsUI.RefreshTimer = Timer.New(fun, 1, -1)
    TradeRoadsUI.RefreshTimer:Start()
end

--计时器停止
function TradeRoadsUI.StopRefreshTimer()
    if TradeRoadsUI.RefreshTimer ~= nil then
        TradeRoadsUI.RefreshTimer:Stop()
        TradeRoadsUI.RefreshTimer = nil
    end
end

--重置UI界面
function TradeRoadsUI.ResetUIData()
    TradeRoadsUI.ResetUIDataInit()

    TradeRoadsUI.OnRoadPageBtnClick()

    local TradeRightLoop = _gt.GetUI("TradeRightLoop")
    GUI.LoopScrollRectSetTotalCount(TradeRightLoop, #CenterBottomTaskTable)
    GUI.LoopScrollRectRefreshCells(TradeRightLoop)

    local PropLoopScroll = _gt.GetUI("PropLoopScroll")
    GUI.LoopScrollRectSetTotalCount(PropLoopScroll, 0)
    GUI.LoopScrollRectRefreshCells(PropLoopScroll)

    local AttendantsLoopScroll = _gt.GetUI("AttendantsLoopScroll")
    GUI.LoopScrollRectSetTotalCount(AttendantsLoopScroll, 0)
    GUI.LoopScrollRectRefreshCells(AttendantsLoopScroll)
    --选择侍从护卫提示
    local TipsText = _gt.GetUI("TipsText")
    GUI.StaticSetText(TipsText,"")
end

--重置界面数据
function TradeRoadsUI.ResetUIDataInit()
    test("重置界面数据")
    ShowTipsStatus = 0
end

-- 显示奖励事件前往地址页面
function TradeRoadsUI.ShowGotoPlacePage(Place,PlaceX,PlaceY,NPCName)
    MapId = 0
    MapPlaceX = 0
    MapPlaceY = 0
    local MapDB = DB.GetOnceMapByKey2(Place)
    local msg = "是否前往<color=#FF0000>" .. MapDB.Name.."("..PlaceX..","..PlaceY..")" .. "</color>附近寻找<color=#FF0000>"..NPCName.."</color>?"
    local PlaceShowBoxMsg = GlobalUtils.ShowBoxMsg2Btn(
            "提示",
            msg,
            "TradeRoadsUI",
            "前往",
            "OnLeaveForBtn",
            "取消",
            "OnCancelBtn",
            "closeMsg",
            ""
    )
    MapId = MapDB.Id
    MapPlaceX = PlaceX
    MapPlaceY = PlaceY
end

--奖励事件前往按钮
function TradeRoadsUI.OnLeaveForBtn()
    test("前往按钮点击事件")
    if MapId ~= 0 then
        MainUI.CloseOtherWnds()
        GetWay.Def[3].jump(MapId,MapPlaceX,MapPlaceY)
    end
end

--奖励事件取消按钮
function TradeRoadsUI.OnCancelBtn()
    test("取消按钮点击事件")
end

-- 获取途径
function TradeRoadsUI.OnClickAcquireTipsBtn()
    local tip = _gt.GetUI("AcquireTips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end

-- 显示侍从护卫获取前往地址页面
function TradeRoadsUI.ShowGotoGainGuardPage()
    local msg = "您还未拥有侍从，是否前往获取?"
    local PlaceShowBoxMsg = GlobalUtils.ShowBoxMsg2Btn(
            "提示",
            msg,
            "TradeRoadsUI",
            "确认",
            "OnGainGuardBtn",
            "取消",
            "OnCancelGainGuardBtn",
            "closeMsg",
            ""
    )
end

--侍从护卫获取前往按钮
function TradeRoadsUI.OnGainGuardBtn()
    test("侍从护卫获取前往按钮")
    GUI.OpenWnd("GuardUI")
end

--侍从护卫获取取消按钮
function TradeRoadsUI.OnCancelGainGuardBtn()
    test("侍从护卫获取取消按钮")
end

--注册背包物品监听事件
function TradeRoadsUI.RegisterPropItem()
    test("注册背包物品监听事件")
    CL.RegisterMessage(GM.AddNewItem, "TradeRoadsUI", "CreatePropGroup")
    CL.RegisterMessage(GM.UpdateItem, "TradeRoadsUI", "CreatePropGroup")
    CL.RegisterMessage(GM.RemoveItem, "TradeRoadsUI", "CreatePropGroup")
end

--注销背包物品监听事件
function TradeRoadsUI.UnRegisterPropItem()
    test("注销背包物品监听事件")
    CL.UnRegisterMessage(GM.AddNewItem, "TradeRoadsUI", "CreatePropGroup")
    CL.UnRegisterMessage(GM.UpdateItem, "TradeRoadsUI", "CreatePropGroup")
    CL.UnRegisterMessage(GM.RemoveItem, "TradeRoadsUI", "CreatePropGroup")
end