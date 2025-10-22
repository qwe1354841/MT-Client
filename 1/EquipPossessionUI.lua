local EquipPossessionUI = {}
_G.EquipPossessionUI = EquipPossessionUI

--装备附灵界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local StaticSetFontSizeColorAlignment = UILayout.StaticSetFontSizeColorAlignment
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
local BlackColor = UIDefine.BlackColor
local Purple2Color = UIDefine.Purple2Color
local PinkColor = UIDefine.PinkColor
local OutLineDistance = UIDefine.OutLineDistance
local OutLine_BrownColor = UIDefine.OutLine_BrownColor
----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------

--当前选择的装备的guid
local selectEquipGuid = nil

--上一个选择的装备的guid
local lastSelectEquipGuid = nil

--受益装备
local leftLock = 1

--转移装备
local rightLock = 2

--转移装备Guid
local transferEquipGuid = nil

--选择装备界面装备Guid
local selectBagEquipGuid = nil

--字符长度限制
local txtLengthRestrict = 35

--附灵tips
local inheritTips = nil

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

--收益装备属性表
local beneficiaryEquipmentAttrTable = {}

--转移装备属性表
local transferEquipmentAttrTable = {}

--消耗物品表
local inheritConsumeTable = {}

--当前消耗物品表
local nowInheritConsumeTable = {}

--品质关于颜色表
local qualityOfColorTable = {}

--背包选择装备表数据
local selectBagEquipItemTable = {}

local equipType = {
    [1] = {
        [1] = "1800400530",
        [2] = "1800400530",
        [3] = "1800400530",
        [4] = "1800400530",
        [5] = "1800400530",
        [6] = "1800400530",
        [7] = "1800400530",
        [8] = "1800400530",
        [9] = "1800400530",
        [10] = "1800400530",
        [11] = "1800400530",
        [12] = "1800400530",
    },
    [2] = {
      [1] = "1800400620",
      [2] = "1800400630",
      [3] = "1800400640",
      [5] = "1800400690",
    },
    [3] = {
        [1] = "1800400670",
        [2] = "1800400680",
        [3] = "1800400660",
        [4] = "1800400650",
    },
}

local typeList = {
    {
        "装备中",
        "inEquipBtn",
        "1800402030",
        "1800402032",
        "OnInEquipBtnClick",
        -448,
        -245,
        145,

        50,
        100,
        40,
        item_container_type.item_container_equip
    },
    {
        "背包中",
        "inBagBtn",
        "1800402030",
        "1800402032",
        "OnInBagBtnClick",
        -302,
        -245,
        145,
        50,
        100,
        40,
        item_container_type.item_container_bag
    }
}

--------------------------------------------End 表配置 End------------------------------------

EquipPossessionUI.typeList = typeList

function EquipPossessionUI.InitData()
    return {
        -- 背包中，装备中类型
        type = 1,
        -- 选中的道具下标
        index = 1,
        -- 选中的道具uiGuId
        indexGuid = int64.new(0),
        -- 可用道具
        items = {
            ---@type eqiupItem[]
            [item_container_type.item_container_equip] = {},
            ---@type eqiupItem[]
            [item_container_type.item_container_bag] = {}
        },
        suits = {
            ---@type enhanceDynAttrData[][]
            [item_container_type.item_container_equip] = {},
            ---@type enhanceDynAttrData[][]
            [item_container_type.item_container_bag] = {}
        },
        itemIndex = 1,
        itemIndexGuid = int64.new(0),
        suitdata ={},
        suitgradedata = {},
        showsuitdata ={},
    }
end
local data = EquipPossessionUI.InitData()

data.getBagType = function()
    local type = EquipPossessionUI.typeList[data.type][12]
    return type
end

--显示设置
function EquipPossessionUI.Show(reset,index)
    test("显示设置")

    EquipPossessionUI.GetSelfEquipInfo()
    if reset then
        data.index = 1
        data.type = 1
        data.itemIndex = 1
        data.indexGuid = nil
        EquipPossessionUI.CreateSubPage()
        EquipUI.SelectBagType(data)
    end
    EquipPossessionUI.SetVisible(true,index)

    EquipPossessionUI.ClientRefresh()

    if reset then
        CL.SendNotify(NOTIFY.SubmitForm,"FormEquipSoulReforge","GetInheritData")
    end

end

--服务器回调刷新
function EquipPossessionUI.RefreshAllData()

    --消耗物品表
    inheritConsumeTable = EquipPossessionUI.InheritConsume

    test("inheritConsumeTable",inspect(inheritConsumeTable))

    inheritTips = EquipPossessionUI.InheritTips

    qualityOfColorTable = GlobalProcessing.EquipSoulReforgeColor

    --获得当前选择的装备的guid
    EquipPossessionUI.GetNowSelectEquipGuid()

end

function EquipPossessionUI.OnInEquipBtnClick()
    data.type = 1
    data.index = 1
    EquipPossessionUI.ClientRefresh()
end
function EquipPossessionUI.OnInBagBtnClick()
    data.type = 2
    data.index = 1
    EquipPossessionUI.ClientRefresh()
end

--筛选道具
function EquipPossessionUI.GetSelfEquipInfo()
    for key, value in pairs(data.items) do
        data.items[key] =
        EquipScrollItem.GetItemByType(
                key,
                function(item)
                    if item.subtype ~= 4 then
                        return true
                    else
                        return false
                    end
                end
        )
    end
end

-- 关闭或者打开只属于子页签的东西
function EquipPossessionUI.SetVisible(visible,index)
    test("关闭或者打开只属于子页签的东西")

    test("visible",visible)

    local ui = EquipUI.guidt.GetUI("EquipPossessionUI")
    GUI.SetVisible(ui, visible)
    local EquipTop = EquipUI.guidt.GetUI("EquipTop")
    local bindBtn = GUI.GetChild(EquipTop, "bindBtn", false) --优先使用非绑定材料
    GUI.SetVisible(bindBtn, not visible)

    local equipPage = EquipUI.guidt.GetUI("equipPage")

    local bg = GUI.GetChild(equipPage, "bg", false) --中间底板
    GUI.SetVisible(bg, not visible)

    local EquipBottom = EquipUI.guidt.GetUI("EquipBottom") --右下角强化按钮 和消耗货币
    GUI.SetVisible(EquipBottom, not visible)


    local inEquipBtn = GUI.GetChild(equipPage,"inEquipBtn") --左上角装备中按钮
    local inBagBtn = GUI.GetChild(equipPage,"inBagBtn") --左上角背包中按钮

    GUI.SetVisible(inEquipBtn, not visible)
    GUI.SetVisible(inBagBtn, not visible)

    local panelBg = EquipUI.guidt.GetUI("panelBg")
    local pageTale = {"soulWashingPage","possessionPage","ascendSoulPage"}

    for i = 1, #pageTale do

        local page = GUI.GetChild(panelBg,pageTale[i],false)
        GUI.SetVisible(page,i == index)

    end


    if visible == false then
        if EquipUI.RefreshLeftItemScroll == EquipPossessionUI.RefreshLeftItem then
            EquipUI.RefreshLeftItemScroll = nil
            EquipUI.ClickLeftItemScroll = nil
        end
        UILayout.UnRegisterSubTabUIEvent(typeList, "EquipPossessionUI")
        EquipPossessionUI.ClickItemGuid = ""
    else
        EquipUI.RefreshLeftItemScroll = EquipPossessionUI.RefreshLeftItem
        EquipUI.ClickLeftItemScroll = EquipPossessionUI.OnLeftItemClick
        UILayout.RegisterSubTabUIEvent(typeList, "EquipPossessionUI")
    end

end

function EquipPossessionUI.RefreshLeftItem(guid, index)

    local type = data.getBagType()
    EquipScrollItem.RefreshLeftItemByItemInfosEx(guid, type, data.items[type][index])
    local item = GUI.GetByGuid(guid)
    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end
end

--左边装备checkbox点击事件
function EquipPossessionUI.OnLeftItemClick(guid)
    test("左边装备checkbox点击事件")
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end

    test("data.indexGuid",data.indexGuid)
    EquipPossessionUI.ClientRefresh()
end

function EquipPossessionUI.ClientRefresh()

    if lastSelectEquipGuid ~= data.indexGuid then

        transferEquipGuid = nil

    else

        if transferEquipGuid ~= nil then

            local item_data = LD.GetItemDataByGuid(transferEquipGuid,item_container_type.item_container_bag)

            if item_data == nil then

                transferEquipGuid = nil

            end

        end


    end

    lastSelectEquipGuid = data.indexGuid


    --关闭选择装备按钮
    EquipPossessionUI.OnExitSelectBagEquipPage()

    EquipPossessionUI.RefreshUI()
end

--ui刷新
function EquipPossessionUI.RefreshUI()
    local items = data.items[data.getBagType()]
    if EquipPossessionUI.ClickItemGuid ~= "" then
        for i = 1, #items, 1 do
            local item = items[i]
            if EquipPossessionUI.ClickItemGuid == tostring(item.guid) then
                table.remove(items,i)
                table.insert(items,1,item)
            end
        end
    end

    test("items",inspect(items))

    local scroll = EquipUI.guidt.GetUI("itemScroll")
    GUI.LoopScrollRectSetTotalCount(scroll, #items)
    GUI.LoopScrollRectRefreshCells(scroll)
    local remainder = EquipUI.guidt.GetUI("emptyIamge")
    local remainder_bg = EquipUI.guidt.GetUI("emptyIamgeTxtBg")
    if #items == 0 then
        GUI.SetVisible(remainder,true)
        GUI.SetVisible(remainder_bg,true)
    else
        GUI.SetVisible(remainder,false)
        GUI.SetVisible(remainder_bg,false)
    end
    EquipPossessionUI.RefreshProduce()
end

--请求服务器和刷新顶部装备中或背包中
function EquipPossessionUI.RefreshProduce()
    test("请求服务器和刷新顶部装备中或背包中")

    UILayout.OnSubTabClickEx(data.type, EquipPossessionUI.typeList)

    --获得当前选择的装备的guid
    EquipPossessionUI.GetNowSelectEquipGuid()

end

--获得当前选择的装备的guid
function EquipPossessionUI.GetNowSelectEquipGuid()
    test("获得当前选择的装备的guid")

    selectEquipGuid = nil

    local items = data.items[data.getBagType()]

    if next(items) then

        selectEquipGuid = tostring(items[data.index].guid)

    end

    --获得装备Attr属性
    EquipPossessionUI.GetEquipAttr()

end

function EquipPossessionUI.CreateSubPage()
    local panelBg = EquipUI.guidt.GetUI("panelBg")

    local possessionPage = GUI.GetChild(panelBg,"possessionPage",false)

    if possessionPage == nil then

        possessionPage = GUI.GroupCreate(panelBg, "possessionPage", 0, 0, 240, 360)
        _gt.BindName(possessionPage, "possessionPage")

        UILayout.CreateSubTab(typeList, possessionPage, "EquipPossessionUI")

        local bg = GUI.ImageCreate(possessionPage, "possessionBg", "1801100100", 155, 10, false, 740, 460)

        ------------------------------------------------------Start 原属性 Start----------------------------------------
        local leftBg = EquipPossessionUI.CreateEquipSoulWashingItem(bg,"leftBg", -200, 8,"受益装备",leftLock)

        local leftStatsItemLoop =
        GUI.LoopScrollRectCreate(
                leftBg,
                "leftStatsItemLoop",
                6,
                40,
                292,
                250,
                "EquipPossessionUI",
                "CreateLeftStatsItem",
                "EquipPossessionUI",
                "RefreshLeftStatsItem",
                0,
                false,
                Vector2.New(286, 55),
                1,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        SetSameAnchorAndPivot(leftStatsItemLoop, UILayout.TopLeft)
        GUI.ScrollRectSetAlignment(leftStatsItemLoop, TextAnchor.UpperLeft)
        GUI.ScrollRectSetChildSpacing(leftStatsItemLoop, Vector2.New(0, 1))
        _gt.BindName(leftStatsItemLoop,"leftStatsItemLoop")

        ------------------------------------------------------End   原属性   End----------------------------------------


        ------------------------------------------------------Start 新属性 Start----------------------------------------

        local rightBg = EquipPossessionUI.CreateEquipSoulWashingItem(bg,"rightBg", 195, 8,"转移装备",rightLock)

        local rightStatsItemLoop =
        GUI.LoopScrollRectCreate(
                rightBg,
                "rightStatsItemLoop",
                6,
                40,
                292,
                250,
                "EquipPossessionUI",
                "CreateRightStatsItem",
                "EquipPossessionUI",
                "RefreshRightStatsItem",
                0,
                false,
                Vector2.New(286, 55),
                1,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        SetSameAnchorAndPivot(rightStatsItemLoop, UILayout.TopLeft)
        GUI.ScrollRectSetAlignment(rightStatsItemLoop, TextAnchor.UpperLeft)
        GUI.ScrollRectSetChildSpacing(rightStatsItemLoop, Vector2.New(0, 1))
        _gt.BindName(rightStatsItemLoop,"rightStatsItemLoop")

        ------------------------------------------------------End   新属性   End----------------------------------------

        local rightArrow = GUI.ImageCreate(bg,"rightArrow","1801107010", -5, -60)
        SetSameAnchorAndPivot(rightArrow, UILayout.Center)
        GUI.SetEulerAngles(rightArrow,Vector3.New(0,180 , 0)) --重置旋转

        ------------------------------------------------------Start 消耗物品 Start----------------------------------------

        local itemY = 0
        local itemSize = 85
        local itemNameSize = 21

        local consumableItemGroup = GUI.GroupCreate(bg,"consumableItemGroup",0,-10,700,116,false)
        _gt.BindName(consumableItemGroup,"consumableItemGroup")
        GUI.SetVisible(consumableItemGroup,false)
        SetAnchorAndPivot(consumableItemGroup, UIAnchor.Bottom, UIAroundPivot.Bottom)

        local item1 = GUI.ItemCtrlCreate(consumableItemGroup,"item1",QualityRes[1],220,itemY,itemSize,itemSize,false,"system",false)
        SetSameAnchorAndPivot(item1, UILayout.TopLeft)
        GUI.ItemCtrlSetElementRect(item1,eItemIconElement.Icon,0,-1,70,70)
        GUI.RegisterUIEvent(item1, UCE.PointerClick, "EquipPossessionUI", "OnConsumableItemClick")

        local nameTxt = GUI.CreateStatic(item1, "nameTxt", "六个字名字名", 0, -5, 180, 30)
        SetAnchorAndPivot(nameTxt, UIAnchor.Bottom, UIAroundPivot.Top)
        GUI.SetColor(nameTxt, UIDefine.BrownColor)
        GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(nameTxt, itemNameSize)

        local item2 = GUI.ItemCtrlCreate(consumableItemGroup,"item2",QualityRes[1],390,itemY,itemSize,itemSize,false,"system",false)
        SetSameAnchorAndPivot(item2, UILayout.TopLeft)
        GUI.ItemCtrlSetElementRect(item2,eItemIconElement.Icon,0,-1,60,60)
        GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Border,"1800400050")
        GUI.RegisterUIEvent(item2, UCE.PointerClick, "EquipPossessionUI", "OnTransferEquipItemClick")

        --加号添加图片
        local addImage = GUI.ImageCreate(item2,"addImage","1800707060",0,0,false,50,50)
        GUI.SetVisible(addImage,false)
        SetSameAnchorAndPivot(addImage, UILayout.Center)

        local nameTxt = GUI.CreateStatic(item2, "nameTxt", "六个字名字名", 0, -5, 180, 30)
        SetAnchorAndPivot(nameTxt, UIAnchor.Bottom, UIAroundPivot.Top)
        GUI.SetColor(nameTxt, UIDefine.BrownColor)
        GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(nameTxt, itemNameSize)

        local tipsBtn = GUI.ButtonCreate(consumableItemGroup,"TipsBtn", "1800702030", -0, 0,  Transition.ColorTint)
        SetSameAnchorAndPivot(tipsBtn, UILayout.BottomRight)
        GUI.RegisterUIEvent(tipsBtn, UCE.PointerClick, "EquipPossessionUI", "OnSeniorConsumeTipsClick")

        ------------------------------------------------------End   消耗物品   End----------------------------------------


        ------------------------------------------------------Start 底部按钮 Start----------------------------------------

        local bottomBtnGroup = GUI.GroupCreate(bg,"bottomBtnGroup",0,-24,735,75,false)
        SetAnchorAndPivot(bottomBtnGroup, UIAnchor.Bottom, UIAroundPivot.Top)

        local consumeText = GUI.CreateStatic(bottomBtnGroup, "consumeText", "消耗", 0, -5, 80, 30)
        _gt.BindName(consumeText, "consumeText")
        SetAnchorAndPivot(consumeText, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.SetColor(consumeText, UIDefine.BrownColor)
        GUI.StaticSetFontSize(consumeText, UIDefine.FontSizeL)
        GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleCenter)

        local consumeBg = GUI.ImageCreate(consumeText, "consumeBg", "1800700010", 0, 0, false, 180, 35)
        SetAnchorAndPivot(consumeBg, UIAnchor.Right, UIAroundPivot.Left)

        local coin = GUI.ImageCreate(consumeBg, "coin", "1800408280", 0, -1, false, 36, 36)
        SetSameAnchorAndPivot(coin, UILayout.Left)

        local num = GUI.CreateStatic(coin, "num", "1000000", 0, 0, 180, 33)
        GUI.SetColor(num, UIDefine.WhiteColor)
        GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
        GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)
        SetAnchorAndPivot(num, UIAnchor.Left, UIAroundPivot.Left)

        local possessionBtn = GUI.ButtonCreate(bottomBtnGroup, "possessionBtn", "1800402080", 0, 5, Transition.ColorTint, "附 灵", 170, 50, false)
        _gt.BindName(possessionBtn,"possessionBtn")
        GUI.ButtonSetTextFontSize(possessionBtn, 28)
        GUI.SetIsOutLine(possessionBtn, true)
        GUI.ButtonSetTextColor(possessionBtn, WhiteColor)
        GUI.SetOutLine_Color(possessionBtn, OutLine_BrownColor);
        GUI.SetOutLine_Distance(possessionBtn,OutLineDistance)
        SetSameAnchorAndPivot(possessionBtn, UILayout.BottomRight)
        GUI.RegisterUIEvent(possessionBtn, UCE.PointerClick, "EquipPossessionUI", "OnPossessionBtnClick")

        ------------------------------------------------------End   底部按钮   End----------------------------------------

    end

end

function EquipPossessionUI.CreateEquipSoulWashingItem(parent,name,x,y,title,index)

    local bg = GUI.ImageCreate(parent, name, "1801100030", x, y, false, 300, 310)
    SetSameAnchorAndPivot(bg, UILayout.Top)

    local title = GUI.CreateStatic(bg, "title", title, 0, 5, 200, 30)
    SetSameAnchorAndPivot(title, UILayout.Top)
    GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
    GUI.SetColor(title, UIDefine.BrownColor)
    GUI.StaticSetFontSize(title, UIDefine.FontSizeL)

    local pnSellout = GUI.ImageCreate(bg, "pnSellout", "1801100010", 0, 0, false, 260, 80)
    _gt.BindName(pnSellout, "pnSellout"..index)
    SetSameAnchorAndPivot(pnSellout, UILayout.Center)

    local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "该装备未洗灵", 0, 0, 200, 50, "system", true)
    SetAnchorAndPivot(txtSellout, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtSellout, 26)
    GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
    GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleCenter)

    return bg

end

--获得装备Attr属性
function EquipPossessionUI.GetEquipAttr()
    test("获得装备Attr属性")

    --受益装备属性表
    beneficiaryEquipmentAttrTable = {}

    --转移装备属性表
    transferEquipmentAttrTable = {}

    if selectEquipGuid ~= nil then

        local equipSoulReforgeNowAttrTb = LD.GetItemStrCustomAttrByGuid("EquipSoulReforge_NowAttrTb", selectEquipGuid,data.getBagType())

        test("equipSoulReforgeNowAttrTb",equipSoulReforgeNowAttrTb,type(equipSoulReforgeNowAttrTb))


        if #equipSoulReforgeNowAttrTb > 0 then

            beneficiaryEquipmentAttrTable = loadstring("return " .. equipSoulReforgeNowAttrTb)()

        end

        EquipPossessionUI.SetConsumableItemGroupData(true)

    else

        --刷新消耗道具数据
        EquipPossessionUI.SetConsumableItemGroupData(false)

    end


    --转移装备
    if transferEquipGuid ~= nil then

        local transferEquipNowAttrTb = LD.GetItemStrCustomAttrByGuid("EquipSoulReforge_NowAttrTb", transferEquipGuid,item_container_type.item_container_bag)

        test("transferEquipNowAttrTb",transferEquipNowAttrTb,type(transferEquipNowAttrTb))


        if #transferEquipNowAttrTb > 0 then

            transferEquipmentAttrTable = loadstring("return " .. transferEquipNowAttrTb)()

        end

    end


    --刷新属性loop数据
    EquipPossessionUI.RefreshStatsItemLoopData()

end

--刷新消耗道具数据
function EquipPossessionUI.SetConsumableItemGroupData(boolean)
    test("刷新消耗道具数据")

    local consumableItemGroup = _gt.GetUI("consumableItemGroup")
    GUI.SetVisible(consumableItemGroup,boolean)

    if boolean then

        if inheritConsumeTable ~= nil and next(inheritConsumeTable) then

            GUI.SetVisible(consumableItemGroup,true)

            local item = LD.GetItemDataByGuid(selectEquipGuid,data.getBagType())

            local itemId = tonumber(item.id)

            local itemDB = DB.GetOnceItemByKey1(itemId)

            test("inheritConsumeTable",inspect(inheritConsumeTable))

            --当前消耗物品表
            nowInheritConsumeTable = EquipPossessionUI.GetLevelConfig(itemDB.Itemlevel, inheritConsumeTable)


            local bagType = item_container_type.item_container_bag

            --锁定词条消耗物品
            local item1DB = DB.GetOnceItemByKey2(nowInheritConsumeTable.ConsumeItem[1])
            local item1Num = LD.GetItemCountById(item1DB.Id,bagType)
            local item1 = GUI.GetChild(consumableItemGroup,"item1",false)
            GUI.ItemCtrlSetElementValue(item1,eItemIconElement.Icon,item1DB.Icon)
            GUI.ItemCtrlSetElementValue(item1,eItemIconElement.Border,QualityRes[item1DB.Grade])

            GUI.ItemCtrlSetElementValue(item1,eItemIconElement.RightBottomNum,item1Num.."/"..nowInheritConsumeTable.ConsumeItem[2])

            local rightBottomNumTxt = GUI.ItemCtrlGetElement(item1,eItemIconElement.RightBottomNum)

            GUI.SetData(item1,"itemId",item1DB.Id)

            local nameTxt = GUI.GetChild(item1,"nameTxt",false)
            GUI.StaticSetText(nameTxt,item1DB.Name)

            EquipPossessionUI.SetConsumeTxt(nowInheritConsumeTable.MoneyType,nowInheritConsumeTable.MoneyVal)

            if item1Num < nowInheritConsumeTable.ConsumeItem[2] then

                GUI.SetColor(rightBottomNumTxt,RedColor)

            else

                GUI.SetColor(rightBottomNumTxt,WhiteColor)

            end


            --item2
            --选择装备
            local item2 = GUI.GetChild(consumableItemGroup,"item2",false)
            local addImage = GUI.GetChild(item2,"addImage",false)
            local nameTxt = GUI.GetChild(item2,"nameTxt",false)

            test("transferEquipGuid",transferEquipGuid)
            if transferEquipGuid ~= nil then

                GUI.SetVisible(addImage,false)
                local itemData = LD.GetItemDataByGuid(transferEquipGuid,bagType)
                local itemId = tonumber(itemData.id)
                local item2DB = DB.GetOnceItemByKey1(itemId)
                test("item2DB.Icon",item2DB.Icon)
                GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Icon,item2DB.Icon)
                GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Border,QualityRes[item2DB.Grade])

                GUI.StaticSetText(nameTxt,item2DB.Name)

            else

                GUI.StaticSetText(nameTxt,"选择装备")
                GUI.SetVisible(addImage,true)

                local iconImg = nil

                if equipType[itemDB.Subtype] ~= nil then

                    iconImg = equipType[itemDB.Subtype][itemDB.Subtype2]

                end


                GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Icon,iconImg)
                GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Border,"1800400050")
                --设置选择装备背景
                EquipPossessionUI.SetSelectItemBorderData()

            end

        else

            GUI.SetVisible(consumableItemGroup,false)

        end


    end

end

--刷新消耗货币
function EquipPossessionUI.SetConsumeTxt(money_type,num)
    test("刷新消耗货币")
    local consumeText = _gt.GetUI("consumeText")
    local consumeBg = GUI.GetChild(consumeText,"consumeBg",false)
    local coin = GUI.GetChild(consumeBg,"coin",false)
    local moneyNum = GUI.GetChild(coin,"num",false)


    GUI.ImageSetImageID(coin, UIDefine.AttrIcon[UIDefine.MoneyTypes[money_type]])
    GUI.StaticSetText(moneyNum,num)

end

--设置选择装备背景
function EquipPossessionUI.SetSelectItemBorderData()

    if selectEquipGuid ~= nil then

        local consumableItemGroup = _gt.GetUI("consumableItemGroup")

        local item2 = GUI.GetChild(consumableItemGroup,"item2",false)

        local itemData = LD.GetItemDataByGuid(selectEquipGuid,data.getBagType())

        local itemId = tonumber(itemData.id)

        local itemDB = DB.GetOnceItemByKey1(itemId)

        local iconImg = nil

        if equipType[itemDB.Subtype] ~= nil then

            iconImg = equipType[itemDB.Subtype][itemDB.Subtype2]

        end


        GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Icon,iconImg)

    end

end

--附灵按钮点击事件
function EquipPossessionUI.OnPossessionBtnClick()
    test("附灵按钮点击事件")

    if transferEquipGuid ~= nil and selectEquipGuid ~= nil then

        CL.SendNotify(NOTIFY.SubmitForm,"FormEquipSoulReforge","Inherit",transferEquipGuid,selectEquipGuid)

    end

end

--刷新属性loop数据
function EquipPossessionUI.RefreshStatsItemLoopData()
    test("刷新属性loop数据")

    local possessionBtn = _gt.GetUI("possessionBtn")

    if transferEquipmentAttrTable == nil then

        GUI.ButtonSetShowDisable(possessionBtn,false)

    else
        if #transferEquipmentAttrTable > 0 then

            GUI.ButtonSetShowDisable(possessionBtn,true)

        else

            GUI.ButtonSetShowDisable(possessionBtn,false)

        end

    end

    local leftLoop = _gt.GetUI("leftStatsItemLoop")
    local leftPnSellout = _gt.GetUI("pnSellout"..leftLock)

    if #beneficiaryEquipmentAttrTable == 0 then

        GUI.SetVisible(leftLoop,false)
        GUI.SetVisible(leftPnSellout,true)

    else

        GUI.SetVisible(leftPnSellout,false)
        GUI.SetVisible(leftLoop,true)
        GUI.LoopScrollRectSetTotalCount(leftLoop, #beneficiaryEquipmentAttrTable)
        GUI.LoopScrollRectRefreshCells(leftLoop)

    end

    local rightLoop = _gt.GetUI("rightStatsItemLoop")
    local rightPnSellout = _gt.GetUI("pnSellout"..rightLock)
    local txtSellout = GUI.GetChild(rightPnSellout,"txtSellout",false)

    if transferEquipGuid == nil then

        GUI.SetVisible(rightLoop,false)
        GUI.SetVisible(rightPnSellout,true)
        GUI.StaticSetText(txtSellout,"未选择装备")

    else

        if #transferEquipmentAttrTable == 0 then

            GUI.SetVisible(rightLoop,false)
            GUI.SetVisible(rightPnSellout,true)
            GUI.StaticSetText(txtSellout,"该装备未洗灵")

        else

            GUI.SetVisible(rightPnSellout,false)
            GUI.SetVisible(rightLoop,true)
            GUI.LoopScrollRectSetTotalCount(rightLoop, #transferEquipmentAttrTable)
            GUI.LoopScrollRectRefreshCells(rightLoop)

        end


    end

end

function EquipPossessionUI.CreateLeftStatsItem(guid)
    local statsItemLoop = GUI.GetByGuid(tostring(guid))
    local index = GUI.LoopScrollRectGetChildInPoolCount(statsItemLoop) + 1

    local leftStatsBg = GUI.ImageCreate(statsItemLoop, "leftStatsBg"..index, "1800400360", 0, 0, false, 740, 460)

    local glossaryTxt = GUI.CreateStatic(leftStatsBg, "glossaryTxt", "找不到变量Data", 15, 2,  260, 50)
    GUI.StaticSetAlignment(glossaryTxt, TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(glossaryTxt, UILayout.Left)
    GUI.SetColor(glossaryTxt, WhiteColor)
    GUI.StaticSetFontSize(glossaryTxt, 20)

    return leftStatsBg
end

function EquipPossessionUI.RefreshLeftStatsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = beneficiaryEquipmentAttrTable[index]
    if data then

        local data_color = qualityOfColorTable
        local glossaryTxt = GUI.GetChild(item,"glossaryTxt",false)
        local txt = ""
        local txt2 = ""
        if #data[6] > 0 then

            txt = txt..data[6].." "

        end

        local attrDB = DB.GetOnceAttrByKey2(data[1])

        txt = txt..attrDB.ChinaName.." "


        if attrDB.IsPct == 1 then

            if data[2] > 0 then

                txt2 = txt2.."+"..(data[2]/100).."%"

            else

                txt2 = txt2.."-"..(data[2]/100).."%"

            end

        else

            if data[2] > 0 then

                txt2 = txt2.."+"..data[2]

            else

                txt2 = txt2.."-"..data[2]

            end

        end

        if string.len(txt..txt2) > txtLengthRestrict then

            if string.len(txt) > txtLengthRestrict  then

                GUI.StaticSetText(glossaryTxt,txt..txt2)

            else

                GUI.StaticSetText(glossaryTxt,txt.."\n"..txt2)

            end


        else

            GUI.StaticSetText(glossaryTxt,txt..txt2)

        end

        local color = WhiteColor

        if data_color[data[4]] then

            if data_color[data[4]][data[5]] then

                if data_color[data[4]][data[5]][2] then

                    local r,g,b,a = GlobalUtils.getRGBDecimal(data_color[data[4]][data[5]][2])

                    color = Color.New(r / 255, g / 255, b / 255, a)

                end

            end

        end

        GUI.SetColor(glossaryTxt,color)

        GUI.SetVisible(item,true)

    else

        GUI.SetVisible(item,false)

    end

end

function EquipPossessionUI.CreateRightStatsItem(guid)
    local statsItemLoop = GUI.GetByGuid(tostring(guid))
    local index = GUI.LoopScrollRectGetChildInPoolCount(statsItemLoop) + 1

    local leftStatsBg = GUI.ImageCreate(statsItemLoop, "leftStatsBg"..index, "1800400360", 0, 0, false, 740, 460)

    local glossaryTxt = GUI.CreateStatic(leftStatsBg, "glossaryTxt", "找不到变量Data", 15, 2,  260, 50)
    GUI.StaticSetAlignment(glossaryTxt, TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(glossaryTxt, UILayout.Left)
    GUI.SetColor(glossaryTxt, WhiteColor)
    GUI.StaticSetFontSize(glossaryTxt, 20)

    return leftStatsBg
end

function EquipPossessionUI.RefreshRightStatsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = transferEquipmentAttrTable[index]

    if data then
        local data_color = qualityOfColorTable
        local glossaryTxt = GUI.GetChild(item,"glossaryTxt",false)
        local txt = ""
        local txt2 = ""
        if #data[6] > 0 then

            txt = txt..data[6].." "

        end

        local attrDB = DB.GetOnceAttrByKey2(data[1])

        txt = txt..attrDB.ChinaName.." "


        if attrDB.IsPct == 1 then

            if data[2] > 0 then

                txt2 = txt2.."+"..(data[2]/100).."%"

            else

                txt2 = txt2.."-"..(data[2]/100).."%"

            end

        else

            if data[2] > 0 then

                txt2 = txt2.."+"..data[2]

            else

                txt2 = txt2.."-"..data[2]

            end

        end

        if string.len(txt..txt2) > txtLengthRestrict then

            if string.len(txt) > txtLengthRestrict  then

                GUI.StaticSetText(glossaryTxt,txt..txt2)

            else

                GUI.StaticSetText(glossaryTxt,txt.."\n"..txt2)

            end


        else

            GUI.StaticSetText(glossaryTxt,txt..txt2)

        end

        local color = WhiteColor

        if data_color[data[4]] then

            if data_color[data[4]][data[5]] then

                if data_color[data[4]][data[5]][2] then

                    local r,g,b,a = GlobalUtils.getRGBDecimal(data_color[data[4]][data[5]][2])

                    color = Color.New(r / 255, g / 255, b / 255, a)

                end

            end

        end

        GUI.SetColor(glossaryTxt,color)

        GUI.SetVisible(item,true)

    else

        GUI.SetVisible(item,false)

    end

end

--选择装备icon点击事件
function EquipPossessionUI.OnTransferEquipItemClick()
    test("选择装备icon点击事件")

    local possessionPage = _gt.GetUI("possessionPage")

    local selectBagEquipGroup = GUI.GetChild(possessionPage,"selectBagEquipGroup",false)

    if selectBagEquipGroup == nil then

        selectBagEquipGroup = GUI.GroupCreate(possessionPage,"selectBagEquipGroup",0,-20,400,520,false)
        SetAnchorAndPivot(selectBagEquipGroup, UIAnchor.Right, UIAroundPivot.Left)
        _gt.BindName(selectBagEquipGroup,"selectBagEquipGroup")

        local selectBagEquipPage = UILayout.CreateFrame_WndStyle2_WithoutCover(selectBagEquipGroup, "选择装备",400,510,"EquipPossessionUI","OnExitSelectBagEquipPage")
        SetSameAnchorAndPivot(selectBagEquipPage, UILayout.Center)
        _gt.BindName(selectBagEquipPage,"selectBagEquipPage")

        local centerBg = GUI.ImageCreate(selectBagEquipPage, "centerBg", "1800400200", 0, 60, false, 360, 365)
        SetSameAnchorAndPivot(centerBg, UILayout.Top)

        local selectBagEquipLoop =
        GUI.LoopScrollRectCreate(
                centerBg,
                "selectBagEquipLoop",
                3,
                10,
                350,
                345,
                "EquipPossessionUI",
                "CreateSelectBagEquipItem",
                "EquipPossessionUI",
                "RefreshSelectBagEquipItem",
                0,
                false,
                Vector2.New(82, 82),
                4,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        SetSameAnchorAndPivot(selectBagEquipLoop, UILayout.Top)
        GUI.ScrollRectSetAlignment(selectBagEquipLoop, TextAnchor.UpperLeft)
        _gt.BindName(selectBagEquipLoop, "selectBagEquipLoop")
        GUI.ScrollRectSetChildSpacing(selectBagEquipLoop, Vector2.New(5, 5))

        local confirmBtn = GUI.ButtonCreate(selectBagEquipPage, "confirmBtn", "1800402080", 0, -20, Transition.ColorTint, "确 定", 140, 55, false)
        GUI.ButtonSetTextFontSize(confirmBtn, 28)
        GUI.SetIsOutLine(confirmBtn, true)
        GUI.ButtonSetTextColor(confirmBtn, WhiteColor)
        GUI.SetOutLine_Color(confirmBtn, OutLine_BrownColor);
        GUI.SetOutLine_Distance(confirmBtn,OutLineDistance)
        SetAnchorAndPivot(confirmBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.SetEventCD(confirmBtn,UCE.PointerClick, 1)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "EquipPossessionUI", "OnSelectBagEquipConfirmBtnClick")

    else

        GUI.SetVisible(selectBagEquipGroup,true)

    end

    selectBagEquipGuid = transferEquipGuid

    --获取背包选择装备表数据
    EquipPossessionUI.GetSelectBagEquipItemTableData()

end

--获取背包选择装备表数据
function EquipPossessionUI.GetSelectBagEquipItemTableData()
    test("获取背包附加材料表数据")

    selectBagEquipItemTable = {}

    local bagTypeData = item_container_type.item_container_bag

    local BagItemCount = LD.GetItemCount(bagTypeData,0)
    for i = 0, BagItemCount-1 do
        local itemData = LD.GetItemDataByItemIndex(i,bagTypeData,0)
        local itemDB = DB.GetOnceItemByKey1(itemData.id)

        if itemDB.Type == 1 then


            if selectEquipGuid ~= nil and tostring(itemData.guid) ~= selectEquipGuid then

                local selectItemData = LD.GetItemDataByGuid(selectEquipGuid,data.getBagType())

                local selectItemId = tonumber(selectItemData.id)

                local selectItemDB = DB.GetOnceItemByKey1(selectItemId)

                if selectItemDB.Type == 1 and selectItemDB.Subtype == itemDB.Subtype then

                    local temp = {
                        Id = itemDB.Id,
                        Guid = tostring(itemData.guid),
                        Name = itemDB.Name,
                        KeyName = itemDB.KeyName,
                        Icon = tostring(itemDB.Icon),
                        Type = itemDB.Type,
                        Level = itemDB.Itemlevel,
                        Sex = itemDB.Sex,
                        Subtype = itemDB.Subtype,
                        Subtype2 = itemDB.Subtype2,
                        IsBound = tonumber(itemData.isbound),
                        Amount = tonumber(itemData.amount),
                        Grade = tonumber(itemDB.Grade),
                    }


                    table.insert(selectBagEquipItemTable,temp)


                elseif selectItemDB.Subtype == itemDB.Subtype and selectItemDB.Subtype2 == itemDB.Subtype2 then

                    local temp = {
                        Id = itemDB.Id,
                        Guid = tostring(itemData.guid),
                        Name = itemDB.Name,
                        KeyName = itemDB.KeyName,
                        Icon = tostring(itemDB.Icon),
                        Type = itemDB.Type,
                        Level = itemDB.Itemlevel,
                        Sex = itemDB.Sex,
                        Subtype = itemDB.Subtype,
                        Subtype2 = itemDB.Subtype2,
                        IsBound = tonumber(itemData.isbound),
                        Amount = tonumber(itemData.amount),
                        Grade = tonumber(itemDB.Grade),
                    }


                    table.insert(selectBagEquipItemTable,temp)

                end

            end

        end



    end

    test("selectBagEquipItemTable",inspect(selectBagEquipItemTable))

    --刷新附加材料Loop数据
    EquipPossessionUI.RefreshSelectBagEquipLoopData()

end

--刷新附加材料Loop数据
function EquipPossessionUI.RefreshSelectBagEquipLoopData()

    local selectBagEquipGroup = _gt.GetUI("selectBagEquipGroup")

    local isVisible = GUI.GetVisible(selectBagEquipGroup)

    if isVisible then

        local refreshNum = 16
        if #selectBagEquipItemTable > refreshNum then
            refreshNum = math.ceil(#selectBagEquipItemTable / 4) * 4
        end

        local selectBagEquipLoop = _gt.GetUI("selectBagEquipLoop")
        GUI.LoopScrollRectSetTotalCount(selectBagEquipLoop, refreshNum)
        GUI.LoopScrollRectRefreshCells(selectBagEquipLoop)

    end

end

function EquipPossessionUI.CreateSelectBagEquipItem()
    local selectBagEquipLoop = _gt.GetUI("selectBagEquipLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(selectBagEquipLoop) + 1

    local item = GUI.ItemCtrlCreate(selectBagEquipLoop,"selectMaterialItem"..index,QualityRes[1],0,0,50,50,false,"system",false)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,0,65,65)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipPossessionUI", "OnSelectBagEquipItemClick")

    --金色选择框图片
    local SelectImage = GUI.ImageCreate(item,"SelectImage","1800400280",0,-2,false,89,89)
    GUI.SetVisible(SelectImage,false)
    SetSameAnchorAndPivot(SelectImage, UILayout.Center)

    return item
end

function EquipPossessionUI.RefreshSelectBagEquipItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)


    local data = selectBagEquipItemTable[index]


    local SelectImage = GUI.GetChild(item,"SelectImage",false)
    local decreaseButton = GUI.GetChild(item,"decreaseButton",false)

    if data then
        GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,0,50,50)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,data.Icon)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[data.Grade])

        if data.IsBound == 1 then

            GUI.ItemCtrlSetElementValue(item,eItemIconElement.LeftTopSp,"1800707120")

        else

            GUI.ItemCtrlSetElementValue(item,eItemIconElement.LeftTopSp,nil)

        end

        if data.Guid == selectBagEquipGuid then

            GUI.SetVisible(SelectImage,true)
            GUI.SetVisible(decreaseButton,true)

        else

            GUI.SetVisible(SelectImage,false)
            GUI.SetVisible(decreaseButton,false)

        end


        GUI.SetData(item,"itemGuid",data.Guid)

        GUI.SetData(item,"itemId",data.Id)

        GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipPossessionUI", "OnSelectBagEquipItemClick")

    else
        GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,0,55,55)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,nil)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[1])
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.LeftTopSp,nil)
        GUI.SetVisible(SelectImage,false)
        GUI.SetVisible(decreaseButton,false)

        GUI.UnRegisterUIEvent(item, UCE.PointerClick, "EquipPossessionUI", "OnSelectBagEquipItemClick")
    end
end

--附灵tips按钮点击事件
function EquipPossessionUI.OnSeniorConsumeTipsClick()
    test("附灵tips按钮点击事件")

    local possessionPage = _gt.GetUI("possessionPage")

    local Text = inheritTips

    local TipsBg = GUI.TipsCreate(possessionPage, "SeniorConsumeTips", 270, 0, 500, 0)
    SetSameAnchorAndPivot(TipsBg, UILayout.Center)
    GUI.SetIsRemoveWhenClick(TipsBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(TipsBg),false)

    local TipsText = GUI.CreateStatic(TipsBg,"TipsText",Text,0,20,460,25,"system", true)
    GUI.StaticSetFontSize(TipsText,20)
    SetSameAnchorAndPivot(TipsText, UILayout.Top)
    GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
    local desPreferHeight = GUI.StaticGetLabelPreferHeight(TipsText)
    GUI.SetHeight(TipsText,desPreferHeight)
    GUI.SetHeight(TipsBg,desPreferHeight+20)

end

--选择装备item点击事件
function EquipPossessionUI.OnSelectBagEquipItemClick(guid)
    test("选择装备item点击事件")

    local item = GUI.GetByGuid(guid)
    local itemGuid = GUI.GetData(item,"itemGuid")
    local itemId = tonumber(GUI.GetData(item,"itemId"))

    selectBagEquipGuid = itemGuid

    --刷新附加材料Loop数据
    EquipPossessionUI.RefreshSelectBagEquipLoopData()

    local panelBg = EquipUI.guidt.GetUI("panelBg")
    local tip = Tips.CreateByItemId(tonumber(itemId), panelBg, "selectItemTips",-100,0,50)
    SetSameAnchorAndPivot(tip, UILayout.Center)
    GUI.SetData(tip, "ItemId", itemId)

end

--选择装备确认按钮点击事件
function EquipPossessionUI.OnSelectBagEquipConfirmBtnClick()
    test("选择装备确认按钮点击事件")

    transferEquipGuid = selectBagEquipGuid

    --关闭选择装备按钮
    EquipPossessionUI.OnExitSelectBagEquipPage()

    --获得装备Attr属性
    EquipPossessionUI.GetEquipAttr()
end

--关闭选择装备按钮
function EquipPossessionUI.OnExitSelectBagEquipPage()
    test("关闭选择装备按钮")

    local selectBagEquipGroup = _gt.GetUI("selectBagEquipGroup")

    GUI.SetVisible(selectBagEquipGroup,false)

end

--消耗物品item点击事件
function EquipPossessionUI.OnConsumableItemClick(guid)
    test("消耗物品item点击事件")

    local item = GUI.GetByGuid(guid)
    local itemId = tonumber(GUI.GetData(item,"itemId"))
    test("itemId",itemId)

    local panelBg = EquipUI.guidt.GetUI("panelBg")
    local tip = Tips.CreateByItemId(tonumber(itemId), panelBg, "rightItemTips",120,0,50)
    SetSameAnchorAndPivot(tip, UILayout.Center)
    GUI.SetData(tip, "ItemId", itemId)

    local wayBtn=GUI.ButtonCreate(tip,"wayBtn","1800402110",0,-10,Transition.ColorTint,"获得途径", 150, 50, false)
    SetAnchorAndPivot(wayBtn,UIAnchor.Bottom,UIAroundPivot.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"EquipSoulWashingUI","onClickWayBtn")
    GUI.AddWhiteName(tip, GUI.GetGuid(wayBtn))

end

--获得途径按钮点击
function EquipPossessionUI.onClickWayBtn(guid)
    local wayBtn = GUI.GetByGuid(guid)
    local itemTips= GUI.GetParentElement(wayBtn)
    if itemTips==nil then
        test("Tips is nil")
    end
    if itemTips then
        Tips.ShowItemGetWay(itemTips)
    end
end

--没有配置的level向下取
function EquipPossessionUI.GetLevelConfig(item_level, Config)
    test("获得装备等级消耗物品表")

    if Config ~= nil then
        if Config[item_level] then
            return Config[item_level]
        end
        for i = item_level, 0, -1 do
            if Config[i] then
                return Config[i]
            end
        end

    end

    return {}
end
