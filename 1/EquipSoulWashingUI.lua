local EquipSoulWashingUI = {}
_G.EquipSoulWashingUI = EquipSoulWashingUI

--装备洗灵界面

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
local Blue3Color = UIDefine.Blue3Color
local Blue4Color = UIDefine.Blue4Color
local BlackColor = UIDefine.BlackColor
local Brown4Color = UIDefine.Brown4Color
local Brown6Color = UIDefine.Brown6Color
local GrayColor = UIDefine.GrayColor
local Gray2Color = UIDefine.Gray2Color
local Gray3Color = UIDefine.Gray3Color
local WhiteColor = UIDefine.WhiteColor
local White2Color = UIDefine.White2Color
local White3Color = UIDefine.White3Color
local OrangeColor = UIDefine.OrangeColor
local GreenColor = UIDefine.GreenColor
local Green2Color = UIDefine.Green2Color
local Green3Color = UIDefine.Green3Color
local Purple2Color = UIDefine.Purple2Color
local PinkColor = UIDefine.PinkColor
local Yellow4Color = UIDefine.Yellow4Color

local OutLineDistance = UIDefine.OutLineDistance
local OutLine_BrownColor = UIDefine.OutLine_BrownColor

----------------------------------------------End 颜色配置 End--------------------------------


------------------------------------------Start 全局变量 Start--------------------------------

--原属性
local leftLock = 1

--新属性
local rightLock = 2

--最小词条
local guarantee_Num = 0

--最大词条
local attr_Num = 0

--当前选择的装备的guid
local selectEquipGuid = nil

--高级洗灵
local isSuperiorSpiritualism = false

--洗灵类型
local soulWashingType = 1

--洗灵tips
local tipsTxt = nil

--右边锁定词条关于左边表最大值
local rightRockGlossaryByLeftMax = 0

--字符长度限制
local txtLengthRestrict = 35

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

--配置表
local dispositionTable = {}

--洗灵偏向数值表
local defaultAttrValue = {}

--tips表
local attr_Range = {}

--新属性表
local reforgeChangeAttrTable = {}

--原属性表
local reforgeNowAttrTable = {}

--锁定词条关于index表
local lockGlossaryByIndexTable = {}

--消耗道具表
local costItemTable = {}

--新属性偏向表
local attrValueName = {}

--品质关于颜色表
local qualityOfColorTable = {}

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

EquipSoulWashingUI.typeList = typeList

function EquipSoulWashingUI.InitData()
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
local data = EquipSoulWashingUI.InitData()

--显示设置
function EquipSoulWashingUI.Show(reset,index)
    test("显示设置")
    EquipSoulWashingUI.GetSelfEquipInfo()
    if reset then
        data.index = 1
        data.type = 1
        data.itemIndex = 1
        data.indexGuid = nil
        EquipSoulWashingUI.CreateSubPage()
        EquipUI.SelectBagType(data)

    end
    EquipSoulWashingUI.SetVisible(true,index)

    if reset then
        CL.SendNotify(NOTIFY.SubmitForm,"FormEquipSoulReforge","GetData")
    end

    EquipSoulWashingUI.ClientRefresh()

end

function EquipSoulWashingUI.RefreshLeftItem(guid, index)
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

--筛选道具
function EquipSoulWashingUI.GetSelfEquipInfo()
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
data.getBagType = function()
    local type = EquipSoulWashingUI.typeList[data.type][12]
    return type
end


function EquipSoulWashingUI.ClientRefresh()

    EquipSoulWashingUI.RefreshUI()
end

function EquipSoulWashingUI.GetItem(index)
    if index == nil then
        index = data.index
    end
    local type = data.getBagType()
    return data.items[type][index]
end

--请求服务器和刷新顶部装备中或背包中
function EquipSoulWashingUI.RefreshProduce()
    test("请求服务器和刷新顶部装备中或背包中")

    UILayout.OnSubTabClickEx(data.type, EquipSoulWashingUI.typeList)

    --获得当前选择的装备的guid
   EquipSoulWashingUI.GetNowSelectEquipGuid()

end


--获得当前选择的装备的guid
function EquipSoulWashingUI.GetNowSelectEquipGuid()
    test("获得当前选择的装备的guid")

    selectEquipGuid = nil

    local items = data.items[data.getBagType()]

    if next(items) then

        selectEquipGuid = tostring(items[data.index].guid)

        local selectType = LD.GetItemIntCustomAttrByGuid("EquipSoulReforge_SelectType", selectEquipGuid,data.getBagType())

        local item = LD.GetItemDataByGuid(selectEquipGuid,data.getBagType())

        local itemId = tonumber(item.id)

        local itemDB = DB.GetOnceItemByKey1(itemId)

        if selectType ~= 0 then

            soulWashingType = selectType

        else

            if next(defaultAttrValue) then

                test("defaultAttrValue[itemDB.Subtype][itemDB.Subtype2]",defaultAttrValue[itemDB.Subtype][0])

                soulWashingType = EquipSoulWashingUI.GetRandTb(defaultAttrValue,itemDB.Subtype, itemDB.Subtype2)

            end

        end

        test("soulWashingType",soulWashingType)

        --刷新新属性偏向表
        EquipSoulWashingUI.GetAttrValueNameTableData()

    end
    --获得装备Attr属性
    EquipSoulWashingUI.GetEquipAttr()

end


--ui刷新
function EquipSoulWashingUI.RefreshUI()
    local items = data.items[data.getBagType()]
    if EquipSoulWashingUI.ClickItemGuid ~= "" then
        for i = 1, #items, 1 do
            local item = items[i]
            if EquipSoulWashingUI.ClickItemGuid == tostring(item.guid) then
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

    EquipSoulWashingUI.RefreshProduce()
end


function EquipSoulWashingUI.OnInEquipBtnClick()
    data.type = 1
    data.index = 1
    EquipSoulWashingUI.ClientRefresh()
end
function EquipSoulWashingUI.OnInBagBtnClick()
    data.type = 2
    data.index = 1
    EquipSoulWashingUI.ClientRefresh()
end

-- 关闭或者打开只属于子页签的东西
function EquipSoulWashingUI.SetVisible(visible,index)
    test("关闭或者打开只属于子页签的东西")

    local ui = EquipUI.guidt.GetUI("EquipSoulWashingUI")
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

    EquipUI.RefreshLeftItemScroll = EquipSoulWashingUI.RefreshLeftItem
    EquipUI.ClickLeftItemScroll = EquipSoulWashingUI.OnLeftItemClick
    UILayout.RegisterSubTabUIEvent(typeList, "EquipSoulWashingUI")


end

function EquipSoulWashingUI.RefreshLeftItem(guid, index)

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
function EquipSoulWashingUI.OnLeftItemClick(guid)
    test("左边装备checkbox点击事件")
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end

    test("data.indexGuid",data.indexGuid)
    EquipSoulWashingUI.ClientRefresh()
end

function EquipSoulWashingUI.CreateSubPage()
    local panelBg = EquipUI.guidt.GetUI("panelBg")

    local soulWashingPage = GUI.GetChild(panelBg,"soulWashingPage",false)

    if soulWashingPage == nil then

        soulWashingPage = GUI.GroupCreate(panelBg, "soulWashingPage", 0, 0, 240, 360)
        _gt.BindName(soulWashingPage, "soulWashingPage")

        UILayout.CreateSubTab(typeList, soulWashingPage, "EquipSoulWashingUI")

        local bg = GUI.ImageCreate(soulWashingPage, "soulWashingBg", "1801100100", 155, 10, false, 740, 460)

        ------------------------------------------------------Start 原属性 Start----------------------------------------
        local leftBg = EquipSoulWashingUI.CreateEquipSoulWashingItem(bg,"leftBg", -200, 8,"原属性",leftLock)

        local leftStatsItemLoop =
        GUI.LoopScrollRectCreate(
                leftBg,
                "leftStatsItemLoop",
                6,
                40,
                292,
                250,
                "EquipSoulWashingUI",
                "CreateLeftStatsItem",
                "EquipSoulWashingUI",
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

        local pnSellout = GUI.ImageCreate(leftBg, "pnSellout", "1801100010", 0, 10, false, 260, 80)
        _gt.BindName(pnSellout, "pnSellout"..leftLock)
        SetSameAnchorAndPivot(pnSellout, UILayout.Center)

        local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "该装备未洗灵", 0, 0, 200, 50, "system", true)
        SetAnchorAndPivot(txtSellout, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
        GUI.StaticSetFontSize(txtSellout, 26)
        GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
        GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleCenter)

        ------------------------------------------------------End   原属性   End----------------------------------------


        ------------------------------------------------------Start 新属性 Start----------------------------------------

        local rightBg = EquipSoulWashingUI.CreateEquipSoulWashingItem(bg,"rightBg", 195, 8,"新属性",rightLock)

        local rightStatsItemLoop =
        GUI.LoopScrollRectCreate(
                rightBg,
                "rightStatsItemLoop",
                6,
                40,
                292,
                250,
                "EquipSoulWashingUI",
                "CreateRightStatsItem",
                "EquipSoulWashingUI",
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

        local pnSellout = GUI.ImageCreate(rightBg, "pnSellout", "1801100010", 0, 20, false, 280, 220)
        _gt.BindName(pnSellout, "pnSellout"..rightLock)
        SetSameAnchorAndPivot(pnSellout, UILayout.Center)

        local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "", 0, 0, 280, 220, "system", true)
        SetAnchorAndPivot(txtSellout, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
        GUI.StaticSetFontSize(txtSellout, 20)
        GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
        GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleLeft)
        GUI.StaticSetLineSpacing(txtSellout,1.2)

        local scale = 0.9
        local tipsBtn = GUI.ButtonCreate(rightBg,"TipsBtn", "1800702030", -10, 3,  Transition.ColorTint)
        GUI.SetScale(tipsBtn, Vector3.New(scale,scale,scale))--缩放
        SetSameAnchorAndPivot(tipsBtn, UILayout.TopRight)
        GUI.RegisterUIEvent(tipsBtn, UCE.PointerClick, "EquipSoulWashingUI", "OnReforgeChangeTipsBtnClick")

        local title = GUI.GetChild(rightBg,"title",false)
        _gt.BindName(title,"reforgeChangeTitle")
        local scale2 = 0.8
        local toggleBtn = GUI.ButtonCreate(title,"toggleBtn", "1801607010", 0, 0,  Transition.ColorTint)
        _gt.BindName(toggleBtn,"toggleBtn")
        SetAnchorAndPivot(toggleBtn, UIAnchor.Left, UIAroundPivot.Right)
        GUI.SetScale(toggleBtn, Vector3.New(scale2,scale2,scale2))--缩放
        GUI.RegisterUIEvent(toggleBtn, UCE.PointerClick, "EquipSoulWashingUI", "OnReforgeChangeToggleBtnClick")

        ------------------------------------------------------End   新属性   End----------------------------------------

        local rightArrow = GUI.ImageCreate(bg,"rightArrow","1801107010", -5, -60)
        SetSameAnchorAndPivot(rightArrow, UILayout.Center)
        GUI.SetEulerAngles(rightArrow,Vector3.New(0,180 , 0)) --重置旋转


        ------------------------------------------------------Start 消耗物品 Start----------------------------------------

        local itemY = -20
        local itemSize = 70
        local itemNameSize = 18

        local consumableItemGroup = GUI.GroupCreate(bg,"consumableItemGroup",0,-10,700,116,false)
        _gt.BindName(consumableItemGroup,"consumableItemGroup")
        GUI.SetVisible(consumableItemGroup,false)
        SetAnchorAndPivot(consumableItemGroup, UIAnchor.Bottom, UIAroundPivot.Bottom)

        local ckImg = GUI.ImageCreate(consumableItemGroup,"ckImg","1801207130", 60, 10)
        SetSameAnchorAndPivot(ckImg, UILayout.TopLeft)

        local txt = GUI.CreateStatic(ckImg, "txt", "锁定词条：1/4", 10, 0, 240, 30)
        SetAnchorAndPivot(txt, UIAnchor.Right, UIAroundPivot.Left)
        GUI.SetColor(txt, UIDefine.BrownColor)
        GUI.StaticSetFontSize(txt, 20)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)

        local item1 = GUI.ItemCtrlCreate(consumableItemGroup,"item1",QualityRes[1],100,itemY,itemSize,itemSize,false,"system",false)
        SetSameAnchorAndPivot(item1, UILayout.TopLeft)
        GUI.ItemCtrlSetElementRect(item1,eItemIconElement.Icon,0,-1,60,60)
        GUI.RegisterUIEvent(item1, UCE.PointerClick, "EquipSoulWashingUI", "OnConsumableItemClick")

        local nameTxt = GUI.CreateStatic(item1, "nameTxt", "六个字名字名", 0, -5, 180, 30)
        SetAnchorAndPivot(nameTxt, UIAnchor.Bottom, UIAroundPivot.Top)
        GUI.SetColor(nameTxt, UIDefine.BrownColor)
        GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(nameTxt, itemNameSize)

        local item2 = GUI.ItemCtrlCreate(consumableItemGroup,"item2",QualityRes[1],380,itemY,itemSize,itemSize,false,"system",false)
        SetSameAnchorAndPivot(item2, UILayout.TopLeft)
        GUI.ItemCtrlSetElementRect(item2,eItemIconElement.Icon,0,-1,60,60)
        GUI.RegisterUIEvent(item2, UCE.PointerClick, "EquipSoulWashingUI", "OnConsumableItemClick")

        local nameTxt = GUI.CreateStatic(item2, "nameTxt", "六个字名字名", 0, -5, 180, 30)
        SetAnchorAndPivot(nameTxt, UIAnchor.Bottom, UIAroundPivot.Top)
        GUI.SetColor(nameTxt, UIDefine.BrownColor)
        GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(nameTxt, itemNameSize)

        local item3 = GUI.ItemCtrlCreate(consumableItemGroup,"item3",QualityRes[1],465,itemY,itemSize,itemSize,false,"system",false)
        SetSameAnchorAndPivot(item3, UILayout.TopLeft)
        GUI.ItemCtrlSetElementRect(item3,eItemIconElement.Icon,0,-1,60,60)
        GUI.RegisterUIEvent(item3, UCE.PointerClick, "EquipSoulWashingUI", "OnConsumableItemClick")

        local nameTxt = GUI.CreateStatic(item3, "nameTxt", "六个字名字名", 0, -5, 180, 30)
        SetAnchorAndPivot(nameTxt, UIAnchor.Bottom, UIAroundPivot.Top)
        GUI.SetColor(nameTxt, UIDefine.BrownColor)
        GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(nameTxt, itemNameSize)

        local checkBox = GUI.CheckBoxCreate(item3, "checkBox", "1800607150", "1800607151", 0, 0, Transition.None, false, 38, 38)
        SetAnchorAndPivot(checkBox, UIAnchor.TopRight, UIAroundPivot.TopLeft)
        GUI.RegisterUIEvent(checkBox, UCE.PointerClick, "EquipSoulWashingUI", "OnSeniorConsumeCheckBoxClick")

        local tipsBtn = GUI.ButtonCreate(consumableItemGroup,"TipsBtn", "1800702030", -0, 0,  Transition.ColorTint)
        SetSameAnchorAndPivot(tipsBtn, UILayout.BottomRight)
        GUI.RegisterUIEvent(tipsBtn, UCE.PointerClick, "EquipSoulWashingUI", "OnSeniorConsumeTipsClick")

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

        local replaceBtn = GUI.ButtonCreate(bottomBtnGroup, "replaceBtn", "1800402090", -180, 5, Transition.ColorTint, "替 换", 170, 50, false)
        _gt.BindName(replaceBtn,"replaceBtn")
        GUI.ButtonSetTextFontSize(replaceBtn, 28)
        GUI.SetIsOutLine(replaceBtn, true)
        GUI.ButtonSetTextColor(replaceBtn, WhiteColor)
        GUI.SetOutLine_Color(replaceBtn, OutLine_BrownColor);
        GUI.SetOutLine_Distance(replaceBtn,OutLineDistance)
        SetSameAnchorAndPivot(replaceBtn, UILayout.BottomRight)
        GUI.RegisterUIEvent(replaceBtn, UCE.PointerClick, "EquipSoulWashingUI", "OnReplaceBtnClick")

        local soulWashingBtn = GUI.ButtonCreate(bottomBtnGroup, "soulWashingBtn", "1800402080", 0, 5, Transition.ColorTint, "洗 灵", 170, 50, false)
        _gt.BindName(soulWashingBtn,"soulWashingBtn")
        GUI.ButtonSetTextFontSize(soulWashingBtn, 28)
        GUI.SetIsOutLine(soulWashingBtn, true)
        GUI.ButtonSetTextColor(soulWashingBtn, WhiteColor)
        GUI.SetOutLine_Color(soulWashingBtn, OutLine_BrownColor);
        GUI.SetOutLine_Distance(soulWashingBtn,OutLineDistance)
        SetSameAnchorAndPivot(soulWashingBtn, UILayout.BottomRight)
        GUI.RegisterUIEvent(soulWashingBtn, UCE.PointerClick, "EquipSoulWashingUI", "OnSoulWashingBtnClick")


        ------------------------------------------------------End   底部按钮   End----------------------------------------

    end

end

function EquipSoulWashingUI.CreateEquipSoulWashingItem(parent,name,x,y,title,index)

    local bg = GUI.ImageCreate(parent, name, "1801100030", x, y, false, 300, 310)
    SetSameAnchorAndPivot(bg, UILayout.Top)

    local title = GUI.CreateStatic(bg, "title", title, 0, 5, 200, 30,"system",true,false)
    SetSameAnchorAndPivot(title, UILayout.Top)
    GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
    GUI.SetColor(title, UIDefine.BrownColor)
    GUI.StaticSetFontSize(title, UIDefine.FontSizeL)

    return bg

end

function EquipSoulWashingUI.CreateLeftStatsItem(guid)
    local statsItemLoop = GUI.GetByGuid(tostring(guid))
    local index = GUI.LoopScrollRectGetChildInPoolCount(statsItemLoop) + 1

    local checkbox = GUI.CheckBoxExCreate(statsItemLoop,"checkbox"..index, "1800400360", "1800400361",  0, 0, false,75, 40)
    GUI.RegisterUIEvent(checkbox, UCE.PointerClick, "EquipSoulWashingUI", "OnLeftStatsCheckBoxClick")

    --1801207120 1801207130
    local checkBoxBg = GUI.ImageCreate(checkbox, "checkBoxBg", "1801207120", 10, 0, false)
    SetSameAnchorAndPivot(checkBoxBg, UILayout.Left)


    local glossaryTxt = GUI.CreateStatic(checkbox, "glossaryTxt", "找不到变量Data", 45, 2,  230, 50)
    GUI.StaticSetAlignment(glossaryTxt, TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(glossaryTxt, UILayout.Left)
    GUI.SetColor(glossaryTxt, WhiteColor)
    GUI.StaticSetFontSize(glossaryTxt, 20)

    return checkbox
end

function EquipSoulWashingUI.RefreshLeftStatsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = reforgeNowAttrTable[index]

    if data then

        local data_color = qualityOfColorTable

        local checkBoxBg = GUI.GetChild(item,"checkBoxBg",false)

        if data[8] ~= nil then

            if data[8] == 1 then

                lockGlossaryByIndexTable[tostring(index)] = true
                GUI.CheckBoxExSetCheck(item,true)
                GUI.ImageSetImageID(checkBoxBg,"1801207130")

            else

                lockGlossaryByIndexTable[tostring(index)] = false
                GUI.CheckBoxExSetCheck(item,false)
                GUI.ImageSetImageID(checkBoxBg,"1801207120")

            end

        else

            GUI.CheckBoxExSetCheck(item,false)
            GUI.ImageSetImageID(checkBoxBg,"1801207120")

        end

        GUI.SetData(item,"index",index)

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

--左边原属性checkbox点击事件
function EquipSoulWashingUI.OnLeftStatsCheckBoxClick(guid)
    test("左边原属性checkbox点击事件")
    local checkbox = GUI.GetByGuid(guid)

    local index = tonumber(GUI.GetData(checkbox,"index"))

    local lockNum = LD.GetItemIntCustomAttrByGuid("EquipSoulReforge_LockNum", selectEquipGuid,data.getBagType())

    if lockNum < #costItemTable.LockNum  then

        if lockGlossaryByIndexTable[tostring(index)] == nil then

            lockGlossaryByIndexTable[tostring(index)] = true

        else

            if lockGlossaryByIndexTable[tostring(index)] then

                lockGlossaryByIndexTable[tostring(index)] = false

            else

                lockGlossaryByIndexTable[tostring(index)] = true

            end

        end

    else

        if lockGlossaryByIndexTable[tostring(index)] ~= true then

            CL.SendNotify(NOTIFY.ShowBBMsg, "锁定词条已达上限")

        else

            lockGlossaryByIndexTable[tostring(index)] = false

        end

    end

    local temp = {}

    local str = ""

    for k, v in pairs(lockGlossaryByIndexTable) do

        if v == true then

            table.insert(temp,k)

        end

    end
    table.sort(temp)

    for i = 1, #temp do

        str = str..temp[i]..","

    end

    test("str",str)

    CL.SendNotify(NOTIFY.SubmitForm,"FormEquipSoulReforge","SetLock",selectEquipGuid,str)

end

function EquipSoulWashingUI.CreateRightStatsItem()
    local rightStatsItemLoop = _gt.GetUI("rightStatsItemLoop")
    local index = GUI.LoopScrollRectGetChildInPoolCount(rightStatsItemLoop) + 1

    local glossaryBg = GUI.ImageCreate(rightStatsItemLoop,"glossaryBg"..index, "1800400360",  25, 0, false)

    local checkBoxBg = GUI.ImageCreate(glossaryBg, "checkBoxBg", "1801207130", 10, 0, false)
    SetSameAnchorAndPivot(checkBoxBg, UILayout.Left)

    local glossaryTxt = GUI.CreateStatic(glossaryBg, "glossaryTxt", "找不到变量Data", 45, 2,  230, 50)
    GUI.StaticSetAlignment(glossaryTxt, TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(glossaryTxt, UILayout.Left)
    GUI.SetColor(glossaryTxt, WhiteColor)
    GUI.StaticSetFontSize(glossaryTxt, 20)

    return glossaryBg
end

function EquipSoulWashingUI.RefreshRightStatsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = reforgeChangeAttrTable[index]

    if data then

        local data_color = qualityOfColorTable

        local checkBoxBg = GUI.GetChild(item,"checkBoxBg",false)

        if data[8] ~= nil then

            if data[8] == 1 then

                GUI.SetVisible(checkBoxBg,true)

            else

                GUI.SetVisible(checkBoxBg,false)

            end

        else

            GUI.SetVisible(checkBoxBg,false)

        end

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


--服务器回调刷新
function EquipSoulWashingUI.RefreshAllData()
    test("服务器回调刷新")

    --配置表
    dispositionTable = EquipSoulWashingUI.SoulWashingDisposition

    test("dispositionTable",inspect(dispositionTable))

    qualityOfColorTable = GlobalProcessing.EquipSoulReforgeColor

    --洗灵偏向数值表
    defaultAttrValue = EquipSoulWashingUI.DefaultAttrValue

    --洗灵tips
    tipsTxt = EquipSoulWashingUI.Tips

    test("qualityOfColorTable",inspect(qualityOfColorTable))
    test("tipsTxt",tipsTxt)
    test("defaultAttrValue",inspect(defaultAttrValue))

    --获得当前选择的装备的guid
    EquipSoulWashingUI.GetNowSelectEquipGuid()

end

--洗灵tips按钮点击事件
function EquipSoulWashingUI.OnSeniorConsumeTipsClick()
    test("洗灵tips按钮点击事件")

    local soulWashingPage = _gt.GetUI("soulWashingPage")

    local Text = tipsTxt

    local TipsBg = GUI.TipsCreate(soulWashingPage, "SeniorConsumeTips", 270, 0, 500, 0)
    SetSameAnchorAndPivot(TipsBg, UILayout.Center)
    GUI.SetIsRemoveWhenClick(TipsBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(TipsBg),false)

    local TipsText = GUI.CreateStatic(TipsBg,"TipsText",Text,0,20,460,25,"system", true,false)
    GUI.StaticSetFontSize(TipsText,20)
    SetSameAnchorAndPivot(TipsText, UILayout.Top)
    GUI.StaticSetAlignment(TipsText, TextAnchor.MiddleLeft)
    local desPreferHeight = GUI.StaticGetLabelPreferHeight(TipsText)
    GUI.SetHeight(TipsText,desPreferHeight)
    GUI.SetHeight(TipsBg,desPreferHeight+20)

end

--刷新新属性偏向表
function EquipSoulWashingUI.GetAttrValueNameTableData()
    test("刷新新属性偏向表")

    if next(dispositionTable) then

        local item = LD.GetItemDataByGuid(selectEquipGuid,data.getBagType())

        local itemId = tonumber(item.id)

        local itemDB = DB.GetOnceItemByKey1(itemId)

        attrValueName = EquipSoulWashingUI.GetRandTb(dispositionTable.AttrValueName,itemDB.Subtype, itemDB.Subtype2)

        test("attrValueName",inspect(attrValueName))

    end

    local toggleBtn = _gt.GetUI("toggleBtn")

    if #attrValueName <= 1 then

        GUI.SetVisible(toggleBtn,false)

    else

        GUI.SetVisible(toggleBtn,true)

    end

end

--服务器回调刷新装备属性Data
function EquipSoulWashingUI.RefreshSoulWashingPageData()
    test("服务器回调刷新装备属性Data")

end

--服务器回调装备tips刷新
function EquipSoulWashingUI.RefreshOneEquipTipsData()
    test("服务器回调装备tips刷新")

    --最小词条
    guarantee_Num = EquipSoulWashingUI.SoulWashingGuarantee_Num

    --最大词条
    attr_Num = EquipSoulWashingUI.SoulWashingAttr_Num

    --tips表
    attr_Range = EquipSoulWashingUI.SoulWashingAttr_Range

    test("guarantee_Num",guarantee_Num)
    test("attr_Num",attr_Num)
    test("attr_Range",inspect(attr_Range))

    local item = LD.GetItemDataByGuid(selectEquipGuid,data.getBagType())

    local itemId = tonumber(item.id)

    local itemDB = DB.GetOnceItemByKey1(itemId)

    local soulWashingPage = _gt.GetUI("soulWashingPage")

    local tipsListBg = GUI.GetChild(soulWashingPage,"tipsListBg",false)

    if tipsListBg == nil then

        local width = 400

        tipsListBg = GUI.ImageCreate(soulWashingPage, "tipsListBg", "1800400290", 220, -200, false,width, 600)
        SetSameAnchorAndPivot(tipsListBg, UILayout.Top)
        GUI.SetIsRemoveWhenClick(tipsListBg,true)
        tipsListBg:RegisterEvent(UCE.PointerClick)
        GUI.SetIsRaycastTarget(tipsListBg, true)

        local title = GUI.CreateStatic(tipsListBg, "title", "洗灵详情", 0, 20, 240, 34)
        SetSameAnchorAndPivot(title, UILayout.Top)
        GUI.SetColor(title, UIDefine.OrangeColor)
        GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(title, 28)

        local itemIcon = GUI.ItemCtrlCreate(tipsListBg, "itemIcon", QualityRes[1], 25, 65,85,85,false,"system",false)
        GUI.ItemCtrlSetElementRect(itemIcon,eItemIconElement.Icon,0,-1,65,65)
        GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Icon,tostring(itemDB.Icon))
        GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,QualityRes[itemDB.Grade])
        SetSameAnchorAndPivot(itemIcon, UILayout.TopLeft)

        local nameTxt = GUI.CreateStatic(itemIcon, "nameTxt", itemDB.Name, 10, 5, 160, 30)
        SetAnchorAndPivot(nameTxt, UIAnchor.TopRight, UIAroundPivot.TopLeft)
        GUI.SetColor(nameTxt, UIDefine.GradeColor[itemDB.Grade])
        GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleLeft)
        GUI.StaticSetFontSize(nameTxt, 24)

        local levelTxt = GUI.CreateStatic(itemIcon, "levelTxt", itemDB.Level.."级", 10, -5, 80, 30)
        SetAnchorAndPivot(levelTxt, UIAnchor.BottomRight, UIAroundPivot.BottomLeft)
        GUI.SetColor(levelTxt, Yellow4Color)
        GUI.StaticSetAlignment(levelTxt, TextAnchor.MiddleLeft)
        GUI.StaticSetFontSize(levelTxt, 24)
        local desPreferWeight = GUI.StaticGetLabelPreferHeight(levelTxt)
        GUI.SetWidth(levelTxt,desPreferWeight +30)

        local typeTxt = GUI.CreateStatic(levelTxt, "typeTxt", itemDB.ShowType, 0, 0, 160, 30)
        SetAnchorAndPivot(typeTxt, UIAnchor.Right, UIAroundPivot.Left)
        GUI.SetColor(typeTxt, Yellow4Color)
        GUI.StaticSetAlignment(typeTxt, TextAnchor.MiddleLeft)
        GUI.StaticSetFontSize(typeTxt, 24)

        local canSelectNum = GUI.CreateStatic(tipsListBg, "canSelectNum", "可洗词条数："..guarantee_Num.."~"..attr_Num, 25, 160, 240, 34)
        SetSameAnchorAndPivot(canSelectNum, UILayout.TopLeft)
        GUI.SetColor(canSelectNum, UIDefine.OrangeColor)
        GUI.StaticSetAlignment(canSelectNum, TextAnchor.MiddleLeft)
        GUI.StaticSetFontSize(canSelectNum, 27)

        local termScopeTxt = GUI.CreateStatic(tipsListBg, "termScopeTxt", "词条范围：", 25, 195, 240, 34)
        SetSameAnchorAndPivot(termScopeTxt, UILayout.TopLeft)
        GUI.SetColor(termScopeTxt, UIDefine.OrangeColor)
        GUI.StaticSetAlignment(termScopeTxt, TextAnchor.MiddleLeft)
        GUI.StaticSetFontSize(termScopeTxt, 27)

        local tipsGlossaryItemLoop =
        GUI.LoopScrollRectCreate(
                tipsListBg,
                "tipsGlossaryItemLoop",
                25,
                235,
                width - 50,
                340,
                "EquipSoulWashingUI",
                "CreateTipsGlossaryItem",
                "EquipSoulWashingUI",
                "RefreshTipsGlossaryItem",
                0,
                false,
                Vector2.New(width - 50, 50),
                1,
                UIAroundPivot.TopLeft,
                UIAnchor.TopLeft,
                false
        )
        SetSameAnchorAndPivot(tipsGlossaryItemLoop, UILayout.TopLeft)
        GUI.ScrollRectSetAlignment(tipsGlossaryItemLoop, TextAnchor.UpperLeft)
        GUI.ScrollRectSetChildSpacing(tipsGlossaryItemLoop, Vector2.New(0, 1))
        GUI.LoopScrollRectSetTotalCount(tipsGlossaryItemLoop, #attr_Range)
        GUI.LoopScrollRectRefreshCells(tipsGlossaryItemLoop)
        tipsGlossaryItemLoop:RegisterEvent(UCE.PointerClick)
        GUI.SetIsRaycastTarget(tipsGlossaryItemLoop, true)
        GUI.AddWhiteName(tipsListBg,GUI.GetGuid(tipsGlossaryItemLoop))

    end


end

function EquipSoulWashingUI.CreateTipsGlossaryItem(guid)
    local tipsGlossaryItemLoop = GUI.GetByGuid(tostring(guid))
    local index = GUI.LoopScrollRectGetChildInPoolCount(tipsGlossaryItemLoop) + 1

    local glossaryBg = GUI.ImageCreate(tipsGlossaryItemLoop,"glossaryBg"..index, "1800001060",  25, 0, false)

    local glossaryTxt = GUI.CreateStatic(glossaryBg, "glossaryTxt", "获取attr失败", 0, 2,  350, 60)
    GUI.StaticSetAlignment(glossaryTxt, TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(glossaryTxt, UILayout.Left)
    GUI.SetColor(glossaryTxt, Blue4Color)
    GUI.StaticSetFontSize(glossaryTxt, 24)

    return glossaryBg

end

function EquipSoulWashingUI.RefreshTipsGlossaryItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = attr_Range[index]
    local data_color = qualityOfColorTable


    if data then
        local glossaryTxt = GUI.GetChild(item,"glossaryTxt",false)
        local txt = ""
        if #data[4] > 0 then

            txt = txt..data[4].." "

        end

        test("data[1]",data[1])

        local attrDB = DB.GetOnceAttrByKey2(data[1])

        txt = txt..attrDB.ChinaName.." "


        if attrDB.IsPct == 1 then

            if data[2] > 0 then

                txt = txt.."+"..(data[2]/100).."% ~ "

            else

                txt = txt.."-"..(data[2]/100).."% ~ "

            end

            txt = txt..(data[3]/100).."%"

        else

            if data[2] > 0 then

                txt = txt.."+"..data[2].."~"

            else

                txt = txt.."-"..data[2].."~"

            end

            if data[3] > 0 then

                txt = txt..data[3]

            else

                txt = txt..data[3]

            end

        end

        GUI.StaticSetText(glossaryTxt,txt)

        local color = WhiteColor

        if data_color[data[5]] then

            if data_color[data[5]][3] then

                if data_color[data[5]][3][2] then

                    local r,g,b,a = GlobalUtils.getRGBDecimal(data_color[data[5]][3][2])

                    color = Color.New(r / 255, g / 255, b / 255, a)


                end

            else

                if data_color[data[5]][1][2] then

                    local r,g,b,a = GlobalUtils.getRGBDecimal(data_color[data[5]][1][2])

                    color = Color.New(r / 255, g / 255, b / 255, a)

                end

            end

        end

        GUI.SetColor(glossaryTxt,color)

    end

end


--回调刷新lock数据
function EquipSoulWashingUI.ReturnRefreshLockData()
    test("回调刷新lock数据")

    --获得装备Attr属性
    EquipSoulWashingUI.GetEquipAttr()

end

--获得装备Attr属性
function EquipSoulWashingUI.GetEquipAttr()

    test("获得装备Attr属性")

    --新属性表
    reforgeChangeAttrTable = {}

    --原属性表
    reforgeNowAttrTable = {}


    --锁定词条关于index表
    lockGlossaryByIndexTable = {}

    local replaceBtn = _gt.GetUI("replaceBtn")
    local soulWashingBtn = _gt.GetUI("soulWashingBtn")

    if selectEquipGuid ~= nil then

        GUI.ButtonSetShowDisable(soulWashingBtn,true)

        --新属性
        local equipSoulReforgeChangeAttrTb = LD.GetItemStrCustomAttrByGuid("EquipSoulReforge_ChangeAttrTb", selectEquipGuid,data.getBagType())

        test("新属性equipSoulReforgeChangeAttrTb",equipSoulReforgeChangeAttrTb,type(equipSoulReforgeChangeAttrTb))

        if #equipSoulReforgeChangeAttrTb > 0 then

            reforgeChangeAttrTable = loadstring("return " .. equipSoulReforgeChangeAttrTb)()

        end

        if #reforgeChangeAttrTable > 0 then

            test("reforgeChangeAttrTable",inspect(reforgeChangeAttrTable))

            GUI.ButtonSetShowDisable(replaceBtn,true)

        else

            GUI.ButtonSetShowDisable(replaceBtn,false)

        end


        --原属性
        local equipSoulReforgeNowAttrTb = LD.GetItemStrCustomAttrByGuid("EquipSoulReforge_NowAttrTb", selectEquipGuid,data.getBagType())

        test("equipSoulReforgeNowAttrTb",equipSoulReforgeNowAttrTb,type(equipSoulReforgeNowAttrTb))


        if #equipSoulReforgeNowAttrTb > 0 then

            reforgeNowAttrTable = loadstring("return " .. equipSoulReforgeNowAttrTb)()

        end

        --刷新消耗道具数据
        EquipSoulWashingUI.SetConsumableItemGroupData(true)

    else

        GUI.ButtonSetShowDisable(soulWashingBtn,false)

        GUI.ButtonSetShowDisable(replaceBtn,false)

        --刷新消耗道具数据
        EquipSoulWashingUI.SetConsumableItemGroupData(false)

    end

    --刷新属性loop数据
    EquipSoulWashingUI.RefreshStatsItemLoopData()

end

--刷新属性loop数据
function EquipSoulWashingUI.RefreshStatsItemLoopData()
    test("刷新属性loop数据")

    lockGlossaryByIndexTable = {}

    local leftLoop = _gt.GetUI("leftStatsItemLoop")
    local leftPnSellout = _gt.GetUI("pnSellout"..leftLock)

    if #reforgeNowAttrTable == 0 then

        GUI.SetVisible(leftLoop,false)
        GUI.SetVisible(leftPnSellout,true)

    else

        GUI.SetVisible(leftPnSellout,false)
        GUI.SetVisible(leftLoop,true)

        local refreshNum = 6
        if #reforgeNowAttrTable > refreshNum then

            refreshNum = #reforgeNowAttrTable

        end
        GUI.LoopScrollRectSetTotalCount(leftLoop, #reforgeNowAttrTable)
        GUI.LoopScrollRectRefreshCells(leftLoop)

    end

    local rightLoop = _gt.GetUI("rightStatsItemLoop")
    local rightPnSellout = _gt.GetUI("pnSellout"..rightLock)
    local txtSellout = GUI.GetChild(rightPnSellout,"txtSellout",false )

    if #reforgeChangeAttrTable == 0 then

        GUI.SetVisible(rightLoop,false)
        GUI.SetVisible(rightPnSellout,true)

        local item = LD.GetItemDataByGuid(selectEquipGuid,data.getBagType())

        local itemId = tonumber(item.id)

        local itemDB = DB.GetOnceItemByKey1(itemId)

        if next(dispositionTable) then

            local levenTempTable = EquipSoulWashingUI.GetLevelConfig(itemDB.Level, dispositionTable.LevelConfig)

            local minTxt = tonumber(levenTempTable.GuaranteeNum[itemDB.Grade])
            local addTxt1 = dispositionTable.GradeConfig[tostring(itemDB.Grade)]
            local addTxt2 = dispositionTable.GradeConfig[tostring(itemDB.Grade).."_Senior"]

            local numTxt1 = tostring(minTxt+addTxt1[1].."~"..minTxt+addTxt1[2])
            local numTxt2 = tostring(minTxt+addTxt2[1].."~"..minTxt+addTxt2[2])

            local briefTips = dispositionTable.BriefTips

            local txt = string.gsub(briefTips, "num1", numTxt1)

            txt = string.gsub(txt, "num2", numTxt2)

            GUI.StaticSetText(txtSellout,txt)

        end


    else

        GUI.SetVisible(rightPnSellout,false)
        GUI.SetVisible(rightLoop,true)

        local refreshNum = 6
        if #reforgeChangeAttrTable > refreshNum then

            refreshNum = #reforgeChangeAttrTable

        end

        GUI.LoopScrollRectSetTotalCount(rightLoop, refreshNum)
        GUI.LoopScrollRectRefreshCells(rightLoop)

    end

    --设置新属性文字
    EquipSoulWashingUI.SetReforgeChangeTitleTxt()

end

--新属性转换按钮点击事件
function EquipSoulWashingUI.OnReforgeChangeToggleBtnClick()
    test("新属性转换按钮点击事件")

    if next(attrValueName) then

        if soulWashingType < #attrValueName then

            soulWashingType = soulWashingType + 1

        else

            soulWashingType = 1

        end

    end

    --设置新属性文字
    EquipSoulWashingUI.SetReforgeChangeTitleTxt()

end

--设置新属性文字
function EquipSoulWashingUI.SetReforgeChangeTitleTxt()
    test("设置新属性文字")
    test("attrValueName",inspect(attrValueName))

    local title = _gt.GetUI("reforgeChangeTitle")

    if attrValueName ~= nil then

        GUI.StaticSetText(title,attrValueName[soulWashingType])

    else

        GUI.StaticSetText(title,"新属性")

    end

end

--刷新消耗道具数据
function EquipSoulWashingUI.SetConsumableItemGroupData(boolean)
    test("刷新消耗道具数据")

    test("boolean=============================",boolean)

    local consumableItemGroup = _gt.GetUI("consumableItemGroup")
    GUI.SetVisible(consumableItemGroup,boolean)

    test("dispositionTable",inspect(dispositionTable))

    if boolean and next(dispositionTable) then

        local item = LD.GetItemDataByGuid(selectEquipGuid,data.getBagType())

        local itemId = tonumber(item.id)

        local itemDB = DB.GetOnceItemByKey1(itemId)

        costItemTable = EquipSoulWashingUI.GetLevelConfig(itemDB.Itemlevel, dispositionTable.LevelConfig)

        test("dispositionTable.LevelConfig",inspect(dispositionTable.LevelConfig))

        test("costItemTable",inspect(costItemTable))

        local lockNum = LD.GetItemIntCustomAttrByGuid("EquipSoulReforge_LockNum", selectEquipGuid,data.getBagType())

        local ckImg = GUI.GetChild(consumableItemGroup,"ckImg",false)

        local txt = GUI.GetChild(ckImg,"txt",false)

        GUI.StaticSetText(txt,"锁定词条："..lockNum.."/"..#costItemTable.LockNum)

        local bagType = item_container_type.item_container_bag

        --锁定词条消耗物品
        local item1DB = DB.GetOnceItemByKey2(costItemTable.LockItem)
        local item1Num = LD.GetItemCountById(item1DB.Id,bagType)
        local item1 = GUI.GetChild(consumableItemGroup,"item1",false)
        GUI.ItemCtrlSetElementValue(item1,eItemIconElement.Icon,item1DB.Icon)
        GUI.ItemCtrlSetElementValue(item1,eItemIconElement.Border,QualityRes[item1DB.Grade])

        local rightBottomNum = GUI.ItemCtrlGetElement(item1,eItemIconElement.RightBottomNum)

        GUI.SetData(item1,"itemId",item1DB.Id)

        local nameTxt = GUI.GetChild(item1,"nameTxt",false)
        GUI.StaticSetText(nameTxt,item1DB.Name)

        if lockNum == 0 then

            GUI.ItemCtrlSetElementValue(item1,eItemIconElement.RightBottomNum,item1Num.."/0")

        else

            if item1Num < costItemTable.LockNum[lockNum] then

                GUI.SetColor(rightBottomNum,RedColor)

            else

                GUI.SetColor(rightBottomNum,WhiteColor)

            end

            GUI.ItemCtrlSetElementValue(item1,eItemIconElement.RightBottomNum,item1Num.."/"..costItemTable.LockNum[lockNum])

        end


        --洗灵消耗物品
        local item2DB = DB.GetOnceItemByKey2(costItemTable.ConsumeItem[1])
        local item2Num = LD.GetItemCountById(item2DB.Id,bagType)
        local item2 = GUI.GetChild(consumableItemGroup,"item2",false)
        GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Icon,item2DB.Icon)
        GUI.ItemCtrlSetElementValue(item2,eItemIconElement.Border,QualityRes[item2DB.Grade])
        GUI.ItemCtrlSetElementValue(item2,eItemIconElement.RightBottomNum,item2Num.."/"..costItemTable.ConsumeItem[2])

        local rightBottomNum = GUI.ItemCtrlGetElement(item2,eItemIconElement.RightBottomNum)

        GUI.SetData(item2,"itemId",item2DB.Id)

        local nameTxt = GUI.GetChild(item2,"nameTxt",false)
        GUI.StaticSetText(nameTxt,item2DB.Name)

        if item2Num < costItemTable.ConsumeItem[2] then

            GUI.SetColor(rightBottomNum,RedColor)

        else

            GUI.SetColor(rightBottomNum,WhiteColor)

        end


        --高级洗灵消耗物品
        local item3DB = DB.GetOnceItemByKey2(costItemTable.SeniorConsumeItem[1])
        local item3Num = LD.GetItemCountById(item3DB.Id,bagType)
        local item3 = GUI.GetChild(consumableItemGroup,"item3",false)
        GUI.ItemCtrlSetElementValue(item3,eItemIconElement.Icon,item3DB.Icon)
        GUI.ItemCtrlSetElementValue(item3,eItemIconElement.Border,QualityRes[item3DB.Grade])
        GUI.ItemCtrlSetElementValue(item3,eItemIconElement.RightBottomNum,item3Num.."/"..costItemTable.SeniorConsumeItem[2])

        local rightBottomNum = GUI.ItemCtrlGetElement(item3,eItemIconElement.RightBottomNum)

        GUI.SetData(item3,"itemId",item3DB.Id)

        if item3Num < costItemTable.SeniorConsumeItem[2] then

            GUI.SetColor(rightBottomNum,RedColor)

        else
            GUI.SetColor(rightBottomNum,WhiteColor)

        end

        local nameTxt = GUI.GetChild(item3,"nameTxt",false)
        GUI.StaticSetText(nameTxt,item3DB.Name)


        --是否高级洗炼
        local checkBox = GUI.GetChild(item3,"checkBox",false)
        GUI.CheckBoxSetCheck(checkBox,isSuperiorSpiritualism)


        if next(costItemTable) then

            GUI.SetVisible(consumableItemGroup,true)


            EquipSoulWashingUI.SetConsumeTxt(costItemTable.MoneyType,costItemTable.MoneyVal)

        else

            GUI.SetVisible(consumableItemGroup,false)

            EquipSoulWashingUI.SetConsumeTxt(3,0)

        end

    else

        EquipSoulWashingUI.SetConsumeTxt(3,0)

    end

end

--刷新消耗货币
function EquipSoulWashingUI.SetConsumeTxt(money_type,num)
    test("刷新消耗货币")
    local consumeText = _gt.GetUI("consumeText")
    local consumeBg = GUI.GetChild(consumeText,"consumeBg",false)
    local coin = GUI.GetChild(consumeBg,"coin",false)
    local moneyNum = GUI.GetChild(coin,"num",false)


    GUI.ImageSetImageID(coin, UIDefine.AttrIcon[UIDefine.MoneyTypes[money_type]])
    GUI.StaticSetText(moneyNum,num)

end

--替换按钮点击事件
function EquipSoulWashingUI.OnReplaceBtnClick()
    test("替换按钮点击事件")

    test("selectEquipGuid",selectEquipGuid)

    if selectEquipGuid ~= nil then

        CL.SendNotify(NOTIFY.SubmitForm,"FormEquipSoulReforge","SaveAttr",selectEquipGuid)

    else

        CL.SendNotify(NOTIFY.ShowBBMsg, "没有可替换的装备")

    end

end

--新属性tips按钮点击事件
function EquipSoulWashingUI.OnReforgeChangeTipsBtnClick()
    test("新属性tips按钮点击事件")

    if selectEquipGuid ~= nil then

        CL.SendNotify(NOTIFY.SubmitForm,"FormEquipSoulReforge","GetAttrRange",selectEquipGuid,soulWashingType)

    end


end

--洗灵按钮点击事件
function EquipSoulWashingUI.OnSoulWashingBtnClick()
    test("洗灵按钮点击事件")

    test("selectEquipGuid",selectEquipGuid)

    if selectEquipGuid ~= nil then

        local superiorSpiritualismType = 0

        if isSuperiorSpiritualism then

            superiorSpiritualismType = 1

        end
        test(selectEquipGuid,soulWashingType,superiorSpiritualismType)

        CL.SendNotify(NOTIFY.SubmitForm,"FormEquipSoulReforge","Reforging",selectEquipGuid,soulWashingType,superiorSpiritualismType)

    else

        CL.SendNotify(NOTIFY.ShowBBMsg, "没有可洗灵的装备")

    end


end

--高级洗灵checkbox点击事件
function EquipSoulWashingUI.OnSeniorConsumeCheckBoxClick(guid)
    test("高级洗灵checkbox点击事件")

    local checkbox = GUI.GetByGuid(guid)

    if isSuperiorSpiritualism then

        isSuperiorSpiritualism = false

    else

        isSuperiorSpiritualism = true

    end

    GUI.CheckBoxSetCheck(checkbox,isSuperiorSpiritualism)

end

--消耗物品item点击事件
function EquipSoulWashingUI.OnConsumableItemClick(guid)
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
function EquipSoulWashingUI.onClickWayBtn(guid)
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
function EquipSoulWashingUI.GetLevelConfig(item_level, Config)
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

--获得装备洗灵类型表
function EquipSoulWashingUI.GetRandTb(tb,item_subtype, item_subtype_2)
    local config = tb[item_subtype]
    if not config then
        return nil
    end
    local config_2 = config[item_subtype_2] or config[0]
    if config_2 then
        return config_2
    else
        return nil
    end
end
