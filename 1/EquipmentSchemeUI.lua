local EquipmentSchemeUI = {}
_G.EquipmentSchemeUI = EquipmentSchemeUI

--装备配置界面

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
----------------------------------------------End 颜色配置 End--------------------------------



------------------------------------------Start 全局变量 Start--------------------------------

--上一个选中的方案guid
local lastSelectSchemeItemGuid = nil

local lastSelectSchemeItemIndex = 1

--选择类型：0为空，1为方案选择
local selectType = 0

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

--item背景
local schemeEquipItemBg = {"1800400530", "1800400620", "1800400630", "1800400640", "1800400650", "1800400660", "1800400670", "1800400680", "1800400690", "1800400700"}

--所有数据表
local EquipmentSchemeAllDataTable = {}

--战力表
local EquipmentSchemeFightValueTable = {}

--顶部方案表
local EquipmentSchemeNameTable = { "方案1","方案2","方案3"};

local SchemeEquipItemTableX = 50
local SchemeEquipItemTableY = 150

local SchemeEquipItemTableXY = {

    {SchemeEquipItemTableX,SchemeEquipItemTableY},
    {SchemeEquipItemTableX + 120,SchemeEquipItemTableY + 60},
    {SchemeEquipItemTableX,SchemeEquipItemTableY + 120},
    {SchemeEquipItemTableX + 120,SchemeEquipItemTableY + 190},
    {SchemeEquipItemTableX,SchemeEquipItemTableY + 240},



    {SchemeEquipItemTableX + 370,SchemeEquipItemTableY},
    {SchemeEquipItemTableX + 250,SchemeEquipItemTableY  + 60},
    {SchemeEquipItemTableX + 370,SchemeEquipItemTableY + 120},
    {SchemeEquipItemTableX + 250,SchemeEquipItemTableY + 190},
    {SchemeEquipItemTableX + 370,SchemeEquipItemTableY + 240},
}

--------------------------------------------End 表配置 End------------------------------------

function EquipmentSchemeUI.Main(parameter)
    local panel = GUI.WndCreateWnd("EquipmentSchemeUI" , "EquipmentSchemeUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "装备方案",560,600,"EquipmentSchemeUI","OnExit",_gt)

    local schemeGroup = GUI.GroupCreate(panelBg, "schemeGroup", 0, 0, 560, 600)
    _gt.BindName(schemeGroup, "schemeGroup")
    SetSameAnchorAndPivot(schemeGroup, UILayout.TopLeft)

    local schemeListLoop =
    GUI.LoopScrollRectCreate(
            schemeGroup,
            "schemeListLoop",
            0,
            80,
            480,
            40,
            "EquipmentSchemeUI",
            "CreateSchemeItem",
            "EquipmentSchemeUI",
            "RefreshSchemeItem",
            0,
            true,
            Vector2.New(106, 45),
            1,
            UIAroundPivot.Center,
            UIAnchor.Center,
            false
    )
    SetSameAnchorAndPivot(schemeListLoop, UILayout.Top)
    _gt.BindName(schemeListLoop,"tenRewardListLoop")
    GUI.ScrollRectSetAlignment(schemeListLoop, TextAnchor.UpperLeft)
    GUI.ScrollRectSetChildSpacing(schemeListLoop, Vector2.New(11, 3))

    local fightTxt = GUI.CreateStatic(schemeGroup, "fightTxt", "<i>战力</i>：", 5, 162, 150, 30, "system", true, false);
    SetSameAnchorAndPivot(fightTxt, UILayout.Top)
    GUI.StaticSetAlignment(fightTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(fightTxt, 24);
    GUI.SetIsOutLine(fightTxt, true)
    GUI.SetOutLine_Color(fightTxt, UIDefine.OrangeColor)
    GUI.SetOutLine_Distance(fightTxt, 1)
    GUI.SetColor(fightTxt, WhiteColor);


    local fightValue = GUI.CreateStatic(fightTxt, "fightValue", "26113", 69, 1, 300, 30, "system", true, false);
    SetSameAnchorAndPivot(fightValue, UILayout.Left)
    GUI.StaticSetAlignment(fightValue, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(fightValue, 24);
    GUI.SetColor(fightValue, Brown4Color);


    for i = 1, 10 do

        local name = "schemeEquipItem"..i
        local schemeEquipItem = GUI.ItemCtrlCreate(schemeGroup,name,"1800400050",SchemeEquipItemTableXY[i][1],SchemeEquipItemTableXY[i][2],90,90,false,"system",false)
        SetSameAnchorAndPivot(schemeEquipItem, UILayout.TopLeft)
        GUI.ItemCtrlSetElementRect(schemeEquipItem,eItemIconElement.Icon,0,-1,70,70)
        GUI.ItemCtrlSetElementValue(schemeEquipItem,eItemIconElement.Icon,schemeEquipItemBg[i])
        GUI.ItemCtrlSetIndex(schemeEquipItem, i-1);
        GUI.RegisterUIEvent(schemeEquipItem, UCE.PointerClick, "EquipmentSchemeUI", "OnSchemeEquipItemClick")

    end

    local modOldGroup = GUI.GroupCreate(schemeGroup, "schemeGroup", 0, -65, 560, 120)
    _gt.BindName(modOldGroup, "modOldGroup")
    SetSameAnchorAndPivot(modOldGroup, UILayout.Bottom)

    local channelBtn = GUI.ButtonCreate(modOldGroup, "channelBtn", "1800402080", -123, -35, Transition.ColorTint, "导 入", 140, 55, false);
    GUI.SetIsOutLine(channelBtn, true);
    GUI.ButtonSetTextFontSize(channelBtn, 28);
    GUI.ButtonSetTextColor(channelBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(channelBtn,UIDefine.OutLine_BrownColor);
    GUI.SetOutLine_Distance(channelBtn, UIDefine.OutLineDistance);
    SetSameAnchorAndPivot(channelBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(channelBtn, UCE.PointerClick, "EquipmentSchemeUI", "OnChannelBtnClick");
    _gt.BindName(channelBtn, "channelBtn");


    local saveBtn = GUI.ButtonCreate(modOldGroup, "saveBtn", "1800402090", 123, -35, Transition.ColorTint, "使 用", 140, 55, false);
    GUI.SetIsOutLine(saveBtn, true);
    GUI.ButtonSetTextFontSize(saveBtn, 28);
    GUI.ButtonSetTextColor(saveBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(saveBtn,UIDefine.OutLine_GreenColor);
    GUI.SetOutLine_Distance(saveBtn, UIDefine.OutLineDistance);
    SetSameAnchorAndPivot(saveBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(saveBtn, UCE.PointerClick, "EquipmentSchemeUI", "OnSaveBtnClick");
    GUI.SetEventCD(saveBtn,UCE.PointerClick,1);
    _gt.BindName(saveBtn, "saveBtn");

    local modNewGroup = GUI.GroupCreate(schemeGroup, "modNewGroup", 0, -65, 560, 120)
    _gt.BindName(modNewGroup, "modNewGroup")
    SetSameAnchorAndPivot(modNewGroup, UILayout.Bottom)

    local useBtn = GUI.ButtonCreate(modNewGroup, "useBtn", "1800402090", 0, -35, Transition.ColorTint, "使 用", 180, 55, false);
    GUI.SetIsOutLine(useBtn, true);
    GUI.ButtonSetTextFontSize(useBtn, 28);
    GUI.ButtonSetTextColor(useBtn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(useBtn,UIDefine.OutLine_GreenColor);
    GUI.SetOutLine_Distance(useBtn, UIDefine.OutLineDistance);
    SetSameAnchorAndPivot(useBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "EquipmentSchemeUI", "OnUseBtnClick");

end


function EquipmentSchemeUI.OnShow(parameter)
    local wnd = GUI.GetWnd("EquipmentSchemeUI");
    if wnd == nil then
        return
    end

    if UIDefine.FunctionSwitch["EquipPlan"] and UIDefine.FunctionSwitch["EquipPlan"] == "on" then

        GUI.SetVisible(wnd, true)

    else

        GUI.SetVisible(wnd, false)

    end

    EquipmentSchemeUI.Init()
    CL.SendNotify(NOTIFY.SubmitForm,"FormEquipPlan","GetData")

end

function EquipmentSchemeUI.Init()

    selectType = 0

    EquipmentSchemeAllDataTable = {}


end

--服务器回调刷新
function EquipmentSchemeUI.RefreshAllData()
    test("服务器回调刷新")

    test("EquipmentSchemeUI.Mod",EquipmentSchemeUI.Mod)

    local modOldGroup = _gt.GetUI("modOldGroup")
    local modNewGroup = _gt.GetUI("modNewGroup")

    if EquipmentSchemeUI.Mod ~= nil and EquipmentSchemeUI.Mod == 1 then

        lastSelectSchemeItemIndex = EquipmentSchemeUI.NowPlanIndex

        test("lastSelectSchemeItemIndex",lastSelectSchemeItemIndex)

        GUI.SetVisible(modNewGroup,true)
        GUI.SetVisible(modOldGroup,false)

        --刷新新的配装item数据
        EquipmentSchemeUI.RefreshNewSchemeItemData()

    else

        GUI.SetVisible(modNewGroup,false)
        GUI.SetVisible(modOldGroup,true)

        --所有数据表
        EquipmentSchemeAllDataTable = EquipmentSchemeUI.ALLPlan

        test("EquipmentSchemeAllDataTable",inspect(EquipmentSchemeAllDataTable))

        --战力表
        EquipmentSchemeFightValueTable = EquipmentSchemeUI.FightValue

        test("EquipmentSchemeFightValueTable",inspect(EquipmentSchemeFightValueTable))

        --刷新配装item数据
        EquipmentSchemeUI.RefreshSchemeItemData()

    end

end

--刷新新的配装item数据
function EquipmentSchemeUI.RefreshNewSchemeItemData()
    test("刷新新的配装item数据")

    local  schemeGroup = _gt.GetUI("schemeGroup")

    local modNewGroup = _gt.GetUI("modNewGroup")
    local useBtn = GUI.GetChild(modNewGroup,"useBtn",false)

    local fightTxt = GUI.GetChild(schemeGroup,"fightTxt",false)
    local fightValue = GUI.GetChild(fightTxt,"fightValue",false)
    GUI.SetVisible(fightTxt,false)


    local schemeListLoop = GUI.GetChild(schemeGroup,"schemeListLoop",false)
    GUI.LoopScrollRectSetTotalCount(schemeListLoop, #EquipmentSchemeNameTable)
    GUI.LoopScrollRectRefreshCells(schemeListLoop)

    if lastSelectSchemeItemIndex == EquipmentSchemeUI.NowPlanIndex then

        test("显示当前装备")
        GUI.ButtonSetShowDisable(useBtn,false)
        GUI.ButtonSetText(useBtn,"使用中")

        --显示当前装备
        for i = 1, 10 do

            local schemeEquipItem = GUI.GetChild(schemeGroup,"schemeEquipItem"..i,false)

            local itemData = LD.GetItemDataByIndex(i - 1,item_container_type.item_container_equip)

            test("i",i)
            test("itemData",itemData)

            if itemData ~= nil then

                ItemIcon.BindItemData(schemeEquipItem, itemData)
                GUI.SetData(schemeEquipItem,"itemGuid",itemData.guid)

            else

                GUI.ItemCtrlSetElementValue(schemeEquipItem,eItemIconElement.Icon,schemeEquipItemBg[i])
                GUI.ItemCtrlSetElementValue(schemeEquipItem,eItemIconElement.Border,"1800400050")
                GUI.SetData(schemeEquipItem,"itemGuid","haven't")
                GUI.ItemCtrlSetElementValue(schemeEquipItem, eItemIconElement.LeftTopSp, nil);
                GUI.ItemCtrlSetElementRect(schemeEquipItem, eItemIconElement.LeftTopSp, 0, 0, 44, 45);

            end

        end

    else
        GUI.ButtonSetShowDisable(useBtn,true)
        GUI.ButtonSetText(useBtn,"使用")

        --显示方案装备

        for i = 1, 10 do

            local warehouse_index = CL.GetIntCustomData("EquipPlan_WarehouseIndex")

            test("warehouse_index",warehouse_index)

            local schemeEquipItem = GUI.GetChild(schemeGroup,"schemeEquipItem"..i,false)

            if warehouse_index == 0 then

                GUI.ItemCtrlSetElementValue(schemeEquipItem,eItemIconElement.Icon,schemeEquipItemBg[i])
                GUI.ItemCtrlSetElementValue(schemeEquipItem,eItemIconElement.Border,"1800400050")
                GUI.SetData(schemeEquipItem,"itemGuid","haven't")
                GUI.ItemCtrlSetElementValue(schemeEquipItem, eItemIconElement.LeftTopSp, nil);
                GUI.ItemCtrlSetElementRect(schemeEquipItem, eItemIconElement.LeftTopSp, 0, 0, 44, 45);

            else

                local equipSite = warehouse_index + (lastSelectSchemeItemIndex - 1) * 10 + (i - 1)

                test("equipSite",equipSite)

                local itemData = LD.GetItemDataByIndex(equipSite,item_container_type.item_container_warehouse_items)

                if itemData ~= nil then

                    ItemIcon.BindItemData(schemeEquipItem, itemData)
                    GUI.SetData(schemeEquipItem,"itemGuid",itemData.guid)
                else

                    GUI.ItemCtrlSetElementValue(schemeEquipItem,eItemIconElement.Icon,schemeEquipItemBg[i])
                    GUI.ItemCtrlSetElementValue(schemeEquipItem,eItemIconElement.Border,"1800400050")

                    GUI.ItemCtrlSetElementValue(schemeEquipItem, eItemIconElement.LeftTopSp, nil);
                    GUI.ItemCtrlSetElementRect(schemeEquipItem, eItemIconElement.LeftTopSp, 0, 0, 44, 45);

                end

            end



        end

    end

end

--导入按钮点击事件
function EquipmentSchemeUI.OnChannelBtnClick()
    test("导入按钮点击事件")


    GlobalUtils.ShowBoxMsg2Btn("提示", "是否导入当前装备保存为方案"..lastSelectSchemeItemIndex.."？", "EquipmentSchemeUI", "确认", "SureChannel", "取消")


end


function EquipmentSchemeUI.SureChannel()

    CL.SendNotify(NOTIFY.SubmitForm,"FormEquipPlan","Save",lastSelectSchemeItemIndex)

end


function EquipmentSchemeUI.CreateSchemeItem()

    local tenRewardListLoop = _gt.GetUI("tenRewardListLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(tenRewardListLoop) + 1

    local schemeItem = GUI.CheckBoxExCreate(tenRewardListLoop, "schemeItem"..index, "1800402030", "1800402032", 0, 0, false)
    GUI.RegisterUIEvent(schemeItem, UCE.PointerClick, "EquipmentSchemeUI", "OnSchemeItemClick");

    local txt = GUI.CreateStatic(schemeItem, "txt", "方案几", 0, 0, 120, 40)
    SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.StaticSetAlignment(txt,TextAnchor.MiddleCenter)
    GUI.SetColor(txt, UIDefine.BrownColor)
    GUI.StaticSetFontSize(txt, 24)

    return schemeItem

end

function EquipmentSchemeUI.RefreshSchemeItem(parameter)

    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local txt = GUI.GetChild(item,"txt",false)

    local data = EquipmentSchemeNameTable[index]

    if data then

        if index == lastSelectSchemeItemIndex then

            GUI.CheckBoxExSetCheck(item,true)
            lastSelectSchemeItemGuid = tostring(guid)

            selectType = 1

        else

            GUI.CheckBoxExSetCheck(item,false)


        end

        GUI.StaticSetText(txt,data)

        GUI.SetData(item,"index",index)

    end

end

--配装item点击
function EquipmentSchemeUI.OnSchemeEquipItemClick(guid)
    test("配装item点击")

    local schemeEquipItem = GUI.GetByGuid(guid)
    local index = GUI.ItemCtrlGetIndex(schemeEquipItem);
    local itemGuid = GUI.GetData(schemeEquipItem,"itemGuid")

    local itemData = nil

    if EquipmentSchemeUI.Mod ~= nil and EquipmentSchemeUI.Mod == 1 then

        if itemGuid == "haven't" then

            CL.SendNotify(NOTIFY.ShowBBMsg,"此位置无装备");

        elseif itemGuid ~= nil and itemGuid ~= "" then

            itemData = LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_equip);

            if itemData == nil then

                itemData = LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_warehouse_items);

            end

        end

    else

        if selectType == 1 then

            if itemGuid == "haven't" then

                CL.SendNotify(NOTIFY.ShowBBMsg,"该装备不在包裹里");

            elseif itemGuid ~= nil and itemGuid ~= "" then

                itemData = LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_equip);

                if itemData == nil then

                    itemData = LD.GetItemDataByGuid(itemGuid, item_container_type.item_container_bag);

                end

            end

        end

    end


    if itemData ~= nil then

        local panelBg = GUI.GetByGuid(_gt.panelBg);
        local itemTips = GUI.GetChild(panelBg,"itemTips",false)

        if itemTips == nil then

            local x = 0

            if index <= 4 then

                x = 290

            else

                x = -290

            end

            itemTips = Tips.CreateByItemData(itemData, panelBg, "itemTips", x, 0, 0);
            GUI.AddWhiteName(itemTips,guid);
        end


    end

end

--刷新配装item数据
function EquipmentSchemeUI.RefreshSchemeItemData()
    test("刷新配装item数据")

    local  schemeGroup = _gt.GetUI("schemeGroup")

    local fightTxt = GUI.GetChild(schemeGroup,"fightTxt",false)
    local fightValue = GUI.GetChild(fightTxt,"fightValue",false)
    local fightData = EquipmentSchemeFightValueTable[lastSelectSchemeItemIndex]

    local schemeListLoop = GUI.GetChild(schemeGroup,"schemeListLoop",false)
    GUI.LoopScrollRectSetTotalCount(schemeListLoop, #EquipmentSchemeNameTable)
    GUI.LoopScrollRectRefreshCells(schemeListLoop)

    if fightData == 0 then

        GUI.SetVisible(fightTxt,false)

    else

        GUI.SetVisible(fightTxt,true)
        GUI.StaticSetText(fightValue,fightData)

    end

    local nowData = EquipmentSchemeAllDataTable[lastSelectSchemeItemIndex]

    for i = 1, 10 do

        local schemeEquipItem = GUI.GetChild(schemeGroup,"schemeEquipItem"..i,false)

        local itemData = nil

        if nowData[i] ~= nil then

            itemData = LD.GetItemDataByGuid(nowData[i], item_container_type.item_container_equip);

            if itemData == nil then

                itemData = LD.GetItemDataByGuid(nowData[i], item_container_type.item_container_bag);

            end

        end

        if itemData ~= nil then

            ItemIcon.BindItemData(schemeEquipItem, itemData)
            GUI.SetData(schemeEquipItem,"itemGuid",nowData[i])

        else

            if nowData[i] == 0 or nowData[i] == "0" or nowData[i] == nil then
                GUI.ItemCtrlSetElementValue(schemeEquipItem, eItemIconElement.IconMask, nil);
                GUI.DelData(schemeEquipItem,"itemGuid")
            else
                GUI.ItemCtrlSetElementValue(schemeEquipItem, eItemIconElement.IconMask, 1801300230);
                GUI.SetData(schemeEquipItem,"itemGuid","haven't")
            end
            GUI.ItemCtrlSetElementValue(schemeEquipItem,eItemIconElement.Icon,schemeEquipItemBg[i])
            GUI.ItemCtrlSetElementValue(schemeEquipItem,eItemIconElement.Border,"1800400050")

            GUI.ItemCtrlSetElementValue(schemeEquipItem, eItemIconElement.LeftTopSp, nil);
            GUI.ItemCtrlSetElementRect(schemeEquipItem, eItemIconElement.LeftTopSp, 0, 0, 44, 45);

        end

    end

end

--方案选择点击事件
function EquipmentSchemeUI.OnSchemeItemClick(guid)

    test("方案选择点击事件")

    local guid = tostring(guid)
    local checkBox = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(checkBox,"index"))

    if lastSelectSchemeItemGuid ~= guid then

        if lastSelectSchemeItemGuid ~= nil then

            local lastCheckBox = GUI.GetByGuid(lastSelectSchemeItemGuid)
            GUI.CheckBoxExSetCheck(lastCheckBox,false)

        end
    end

    GUI.CheckBoxExSetCheck(checkBox,true)

    lastSelectSchemeItemGuid = guid

    selectType = 2

    lastSelectSchemeItemIndex = index

    if EquipmentSchemeUI.Mod ~= nil and EquipmentSchemeUI.Mod == 1 then

        --刷新新的配装item数据
        EquipmentSchemeUI.RefreshNewSchemeItemData()

    else

        EquipmentSchemeUI.RefreshSchemeItemData()

    end



end

--使用新的当前方案点击
function EquipmentSchemeUI.OnUseBtnClick()
    test("使用新的当前方案点击")

    CL.SendNotify(NOTIFY.SubmitForm,"FormEquipPlan","Switch",lastSelectSchemeItemIndex)

end

--使用当前方案点击
function EquipmentSchemeUI.OnSaveBtnClick()
    test("使用当前方案点击")

    CL.SendNotify(NOTIFY.SubmitForm,"FormEquipPlan","Use",lastSelectSchemeItemIndex)

end


function EquipmentSchemeUI.OnExit()

    GUI.CloseWnd("EquipmentSchemeUI")

    EquipmentSchemeUI.RefreshAllData()
end