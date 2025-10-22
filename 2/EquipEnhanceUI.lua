local EquipEnhanceUI = {
    ---@type EnhanceInfo
    serverData = {}
}
-- local test = print
local test = function()
end
_G.EquipEnhanceUI = EquipEnhanceUI
-- 最大强化属性数量
local MaxArtificeCnt = 2
-- 最大消耗道具个数
local consumeMax = 2
EquipEnhanceUI.consumeMax = consumeMax

EquipEnhanceUI.ClickItemGuid = ""

local guidt = UILayout.NewGUIDUtilTable()
function EquipEnhanceUI.InitData()
    ---@type EnhanceInfo
    EquipEnhanceUI.serverData = {}
    EquipEnhanceUI.serverData.Version = "0"
    return {
        useUnBind = false,
        index = 1,
        indexGuid = int64.new(0),
        Build_Time = 1,
        items = {
            ---@type enhanceEqiupItem[]
            [item_container_type.item_container_equip] = {},
            ---@type enhanceEqiupItem[]
            [item_container_type.item_container_bag] = {}
        },
        -- 动态属性
        attrs = {
            ---@type enhanceDynAttrData[][]
            [item_container_type.item_container_equip] = {},
            ---@type enhanceDynAttrData[][]
            [item_container_type.item_container_bag] = {}
        },
        type = 1,
        checkOn = false
    }
end
local data = EquipEnhanceUI.InitData()
function EquipEnhanceUI.OnExitGame()
    data = EquipEnhanceUI.InitData()
    ---@return item_container_typ
    data.getBagType = function()
        local type = EquipEnhanceUI.typeList[data.type][12]
        return type
    end
end

-- 获取强化相关小红点内容
-- EquipEnhanceUI.CheckRedPoint_TB = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB

---@return item_container_typ
data.getBagType = function()
    local type = EquipEnhanceUI.typeList[data.type][12]
    return type
end
test("EquipEnhanceUI")
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
EquipEnhanceUI.typeList = typeList
function EquipEnhanceUI.OnInEquipBtnClick()
    -- 郑
    local btn_type = 1
    --

    if data.type ~= 1 then
        data.type = 1
        data.index = 1
    end

    --郑   这里做了修改 原本是  EquipEnhanceUI.RefreshType()  type 为哪个按钮触发的
    EquipEnhanceUI.RefreshType(btn_type)
    --
end
function EquipEnhanceUI.OnInBagBtnClick()
    --郑
    local btn_type = 2
    --

    if data.type ~= 2 then
        data.type = 2
        data.index = 1
    end
    EquipEnhanceUI.RefreshType(btn_type)
end
function EquipEnhanceUI.ClickItem(guid)
    EquipEnhanceUI.ClickItemGuid = guid
    EquipEnhanceUI.RefreshUI()
    -- local items = data.items[data.getBagType()]
    -- for index, item in pairs(items) do
    --     if guid == tostring(item.guid) then
    --         data.index = index
    --     end
    -- end
end
local uiHideKey = {
    "vpText",
    "vpBg"
}
--强化ui底部name
local uiBKey = {
    "rateText",
    "rateNum",
    "luckText",
    "luckNum"
}
-- 关闭或者打开只属于子页签的东西
function EquipEnhanceUI.SetVisible(visible)
    --郑
    local ui = guidt.GetUI("EquipEnhance")
    local strengthenItem = GUI.GetChild(ui,"strengthenItem")
    local bg = GUI.GetChild(ui,"currentItem")
    local hintBtn = GUI.GetChild(ui, "hintBtn", false)
    local FossilSynthesisButton = GUI.GetChild(ui, "FossilSynthesisButton", false)
    GUI.SetVisible(FossilSynthesisButton,visible)
    
    GUI.SetVisible(ui,visible)
    GUI.SetVisible(bg,visible)
    if visible then
        GUI.SetVisible(EquipUI.guidt.GetUI("EquipBottom"),false)
    end
    local equipPage = EquipUI.guidt.GetUI("equipPage")
    local inEquipBtn = GUI.GetChild(equipPage,"inEquipBtn")
    local inBagBtn = GUI.GetChild(equipPage,"inBagBtn")
    GUI.SetVisible(inEquipBtn, visible)
    GUI.SetVisible(inBagBtn, visible)
    GUI.SetVisible(strengthenItem,visible)
    local tmpUI = {ui, strengthenItem, hintBtn}
    for i = 1, #tmpUI do
        GUI.SetVisible(tmpUI[i], visible)
    end
    for i = 1, #uiHideKey do
        local ui = EquipUI.guidt.GetUI(uiHideKey[i])
        GUI.SetVisible(ui, false)
    end
    for i = 1, #uiBKey do
        local ui = EquipUI.guidt.GetUI(uiBKey[i])
        GUI.SetVisible(ui, visible)
    end
    local enhanceBtn = guidt.GetUI("enhanceBtn")
    local unbind = EquipUI.guidt.GetUI("bindBtn")

    if visible == false then
        for i = 1, consumeMax do
            local item = guidt.GetUI("consumeItem" .. i)
            GUI.UnRegisterUIEvent(item, UCE.PointerClick, "EquipEnhanceUI", "OnConsumeItemClick")
            local check = GUI.GetChild(item, "check")
            GUI.UnRegisterUIEvent(check, UCE.PointerClick, "EquipEnhanceUI", "OnCheckItemClick")
        end
        GUI.UnRegisterUIEvent(FossilSynthesisButton,UCE.PointerClick,"EquipEnhanceUI","OnSynthesisButtonClick")
        GUI.UnRegisterUIEvent(unbind, UCE.PointerClick, "EquipEnhanceUI", "OnCheckBind")
        GUI.UnRegisterUIEvent(hintBtn, UCE.PointerClick, "EquipEnhanceUI", "OnhintBtn")
        GUI.UnRegisterUIEvent(enhanceBtn, UCE.PointerClick, "EquipEnhanceUI", "OnProduceBtnClick")
        if EquipUI.RefreshLeftItemScroll == EquipEnhanceUI.RefreshLeftItem then
            EquipUI.RefreshLeftItemScroll = nil
            EquipUI.ClickLeftItemScroll = nil
        end
        UILayout.UnRegisterSubTabUIEvent(typeList, "EquipEnhanceUI")
        EquipEnhanceUI.ClickItemGuid = ""
    else
        -- CL.RegisterMessage(GM.RefreshBag, "EquipEnhanceUI", "RefreshItemCheckRedPoint")
        for i = 1, consumeMax do
            local item = guidt.GetUI("consumeItem" .. i)
            GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipEnhanceUI", "OnConsumeItemClick")
            local check = GUI.GetChild(item, "check")
            GUI.RegisterUIEvent(check, UCE.PointerClick, "EquipEnhanceUI", "OnCheckItemClick")
        end
        GUI.RegisterUIEvent(FossilSynthesisButton,UCE.PointerClick,"EquipEnhanceUI","OnSynthesisButtonClick")
        GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "EquipEnhanceUI", "OnhintBtn")
        GUI.RegisterUIEvent(unbind, UCE.PointerClick, "EquipEnhanceUI", "OnCheckBind")
        GUI.RegisterUIEvent(enhanceBtn, UCE.PointerClick, "EquipEnhanceUI", "OnProduceBtnClick")
        EquipUI.RefreshLeftItemScroll = EquipEnhanceUI.RefreshLeftItem
        EquipUI.ClickLeftItemScroll = EquipEnhanceUI.OnLeftItemClick
        UILayout.RegisterSubTabUIEvent(typeList, "EquipEnhanceUI")
    end
end
function EquipEnhanceUI.Show(reset)
    test("EquipEnhanceUI.Show")
    if reset then
        data.type = 1
        data.index = 1
        data.indexGuid = nil
        data.checkOn = false
        data.useUnBind = false
        EquipEnhanceUI.GetData()
    end
    EquipEnhanceUI.SetVisible(true)
    EquipEnhanceUI.ClientRefresh()
end

--ui刷新
function EquipEnhanceUI.RefreshType(btn_type)
    UILayout.OnSubTabClickEx(data.type, typeList)
    ---@type eqiupItem[]
    local items = data.items[data.getBagType()]
    if EquipEnhanceUI.ClickItemGuid ~= "" then
        for i = 1, #items, 1 do
            local item = items[i]
            if EquipEnhanceUI.ClickItemGuid == tostring(item.guid) then
                table.remove(items,i)
                table.insert(items,1,item)
            end
        end
    end
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
    EquipEnhanceUI.RefreshMain()
    EquipEnhanceUI.RefreshConsumeItem()
end

function EquipEnhanceUI.CreateEquipEnhanceItem(parent,name,x,y,title)
    local itemBg = GUI.ImageCreate(parent, name, "1801100030", x, y, false, 300, 260)
    UILayout.SetSameAnchorAndPivot(itemBg, UILayout.TopLeft)

    local title = GUI.CreateStatic(itemBg, "title", title, 20, 5, 200, 30)
    GUI.SetColor(title, UIDefine.BrownColor)
    GUI.StaticSetFontSize(title, UIDefine.FontSizeL)

    local itemIcon = GUI.ItemCtrlCreate(itemBg, "itemIcon", UIDefine.ItemIconBg2[1], 18, 53)
    local name = GUI.CreateStatic(itemBg, "name", "名字", 115, 60, 150, 30)
    GUI.SetColor(name, UIDefine.BrownColor)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)

    local enhanceLv = GUI.CreateStatic(itemBg, "enhanceLv", "强化等级：", 115, 100, 150, 30)
    GUI.SetColor(enhanceLv, UIDefine.EnhanceBlueColor)
    GUI.StaticSetFontSize(enhanceLv, UIDefine.FontSizeM)
    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)

    local level = GUI.CreateStatic(enhanceLv, "lv", "10", 115, 0, 100, 30)
    GUI.SetColor(level, UIDefine.EnhanceBlueColor)
    GUI.StaticSetFontSize(level, UIDefine.FontSizeM)

    local rulebg = GUI.ImageCreate(itemBg, "rulebg", "1801100040", 15, 145)
    local rule = GUI.CreateStatic(rulebg, "rule", "属性加成", 2, 0, 280, 30)
    GUI.SetColor(rule, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(rule, UIDefine.FontSizeM)

    local src = GUI.ScrollRectCreate(itemBg, "src", 15, 175, 300, 60,0,false,Vector2.New(300,30))
    -- local src = GUI.CreateStatic(itemBg, "src", "", 15, 170, 300, 70)
    -- for i = 1, MaxArtificeCnt, 1 do
    --     local attText = GUI.CreateStatic(src, "attText" .. i, "物攻", 17, 5, 100, 30)
    --     GUI.SetColor(attText, UIDefine.BrownColor)
    --     GUI.StaticSetFontSize(attText, UIDefine.FontSizeM)
    --     UILayout.SetSameAnchorAndPivot(attText, UILayout.TopLeft)
    --     local value = GUI.CreateStatic(attText, "value", "10", 112, 0, 166, 30)
    --     GUI.SetColor(value, UIDefine.Green8Color)
    --     GUI.StaticSetFontSize(value, UIDefine.FontSizeM)
    -- end

    -- local att1Text = GUI.CreateStatic(src, "attText1", "物攻", 17, 5, 100, 30)
    -- GUI.SetColor(att1Text, UIDefine.BrownColor)
    -- GUI.StaticSetFontSize(att1Text, UIDefine.FontSizeM)
    -- UILayout.SetSameAnchorAndPivot(att1Text, UILayout.TopLeft)
    -- local value = GUI.CreateStatic(att1Text, "value", "10", 112, 0, 166, 30)
    -- GUI.SetColor(value, UIDefine.Green8Color)
    -- GUI.StaticSetFontSize(value, UIDefine.FontSizeM)
    return itemBg
end

function EquipEnhanceUI.CreateSubPage(equipPage)
    -- test(TOOLKIT.GetScreenHeight())
    -- test(TOOLKIT.GetScreenWidth())
    GameMain.AddListen("EquipEnhanceUI", "OnExitGame")
    guidt = UILayout.NewGUIDUtilTable()
    UILayout.CreateSubTab(typeList, equipPage, "EquipEnhanceUI")
    local EquipEnhance = GUI.GroupCreate(equipPage, "EquipEnhance", 0, 0, 0, 0)
    guidt.BindName(EquipEnhance, "EquipEnhance")

    local currentItem = EquipEnhanceUI.CreateEquipEnhanceItem(EquipEnhance,"currentItem", -190, -190,"当前")
    guidt.BindName(currentItem,"currentItem")

    local strengthenItem = EquipEnhanceUI.CreateEquipEnhanceItem(EquipEnhance,"strengthenItem", 200, -190,"强化后")
    guidt.BindName(strengthenItem,"strengthenItem")
    
    --author 郑  2021/5/12 修改后
    local rightArrow = GUI.ImageCreate(EquipEnhance,"rightArrow","1801107010", 158, -60)
    --

    local posX = {
        80,
        250,
    }

    local FossilSynthesisButton = GUI.ButtonCreate(EquipEnhance,"FossilSynthesisButton","1800402060",140,155,Transition.ColorTint,"",35,35,false,false)
    UILayout.SetSameAnchorAndPivot(FossilSynthesisButton, UILayout.Bottom)
    guidt.BindName(FossilSynthesisButton, "FossilSynthesisButton")



    for i = 1, consumeMax do
        local consumeItem = ItemIcon.Create(EquipEnhance, "consumeItem" .. i, posX[i], 155)
        GUI.SetData(consumeItem, "ItemIndex", i)
        local name = GUI.CreateStatic(consumeItem, "name", "材料", 0, 55, 150, 30)
        GUI.SetColor(name, UIDefine.BrownColor)
        GUI.StaticSetFontSize(name, UIDefine.FontSizeS)
        GUI.SetAnchor(name, UIAnchor.Center)
        GUI.SetPivot(name, UIAroundPivot.Center)
        GUI.StaticSetAlignment(name, TextAnchor.MiddleCenter)
        guidt.BindName(consumeItem, "consumeItem" .. i)
        local check = GUI.CheckBoxExCreate(consumeItem, "check", "1800607150", "1800607151", 100, -16)
        GUI.SetVisible(check, false)
        GUI.CheckBoxExSetCheck(check, false)
    end
    
    local hintBtn = GUI.ImageCreate(EquipEnhance, "hintBtn", "1800702030", 480, 200)
    GUI.SetIsRaycastTarget(hintBtn,true)

    local consumeText = GUI.CreateStatic(EquipEnhance, "consumeText", "消耗", -180, 265, 100, 30)
    GUI.SetColor(consumeText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(consumeText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleCenter)
    guidt.BindName(consumeText, "consumeText")

    local consumeBg = GUI.ImageCreate(EquipEnhance, "consumeBg", "1800700010", -50, 266, false, 180, 35)
    local coin = GUI.ImageCreate(consumeBg, "coin", "1800408280", -74, -1, false, 36, 36)
    guidt.BindName(consumeBg, "consumeBg")
    local num = GUI.CreateStatic(consumeBg, "num", "100", 0, 0, 160, 30)
    GUI.SetColor(num, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
    GUI.SetAnchor(num, UIAnchor.Center)
    GUI.SetPivot(num, UIAroundPivot.Center)
    GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)

    local rateText = GUI.CreateStatic(EquipEnhance, "rateText", "成功率", 105, 265, 100, 30)
    GUI.SetColor(rateText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(rateText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(rateText, TextAnchor.MiddleCenter)
    guidt.BindName(rateText, "rateText")

    local rateNum = GUI.CreateStatic(EquipEnhance, "rateNum", "100%", 145, 265, 100, 30)
    GUI.SetColor(rateNum, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(rateNum, UIDefine.FontSizeL)
    GUI.SetPivot(rateNum, UIAroundPivot.Left)
    guidt.BindName(rateNum, "rateNum")

    local luckText = GUI.CreateStatic(EquipEnhance, "luckText", "幸运", 250, 265, 100, 30)
    GUI.SetColor(luckText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(luckText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(luckText, TextAnchor.MiddleCenter)
    guidt.BindName(luckText, "luckText")

    local luckNum = GUI.CreateStatic(EquipEnhance, "luckNum", "100%", 278, 265, 100, 30)
    GUI.SetColor(luckNum, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(luckNum, UIDefine.FontSizeL)
    GUI.SetPivot(luckNum, UIAroundPivot.Left)
    guidt.BindName(luckNum, "luckNum")

    local enhanceBtn = GUI.ButtonCreate(EquipEnhance, "enhanceBtn", "1800002060", 436 , 265, Transition.ColorTint, "强化", 160, 50, false)
    guidt.BindName(enhanceBtn, "enhanceBtn")
    GUI.SetEventCD(enhanceBtn, UCE.PointerClick, 0.5)
    GUI.ButtonSetTextColor(enhanceBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(enhanceBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetOutLineArgs(enhanceBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
end

function EquipEnhanceUI.RefreshLeftItem(guid, index)
    local type = data.getBagType()
    ---@type enhanceEqiupItem
    local item = data.items[type][index]
    local itemguid = tostring(item.guid)
    -- local enhanceMaxLv = item.enhanceMaxLv
    -- local enhanceLv = item.enhanceLv
    EquipScrollItem.RefreshLeftItemByItemInfosEx(guid, type, item)
    local item = GUI.GetByGuid(guid)

    if index == data.index then
        data.indexGuid = guid
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end

    -- 小红点
    local label = "Equip"
    local isShowRedPoint = false
    -- if type == item_container_type.item_container_bag then
    --     label = "Bag"
    -- else
    --     label = "Equip"
    -- end
    if GlobalProcessing.EquipEnhanceUI then
        if GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB[label][itemguid] then
            isShowRedPoint = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB[label][itemguid][1].CanIntensify == "true"
        end
    end
    GlobalProcessing.SetRetPoint(item,isShowRedPoint)
end

function EquipEnhanceUI.GetData()
    -- test("EquipEnhanceUI.GetData")
    CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipEnhance_GetData", EquipEnhanceUI.serverData.Version)
end

-- 确定按钮点击
function EquipEnhanceUI.OnProduceBtnClick()
    local item = EquipEnhanceUI.GetItem()
    if item ~= nil then
        local config = EquipEnhanceUI.serverData.Config[item.enhanceLv + 1]
        if not data.checkOn and config.FailReduce ~= 0 then
            GlobalUtils.ShowBoxMsg2Btn("强化提示","使用"..config.safeItem[1].."可以避免强化失败带来的强化等级降低，是否开启"..config.safeItem[1].."开关？","EquipEnhanceUI","是","confirm1","否","confirm2")
            print("弹提示")
        else
            EquipEnhanceUI.confirm2()
        end
        -- local safe = data.checkOn and 1 or 0
        -- test(
        --     "SendNotify OnProduceBtnClick " ..
        --         tostring(item.guid) ..
        --             " : " .. safe .. ":" .. (data.useUnBind and 1 or 0) .. " : " .. tostring(item.ownerGuid)
        -- )
        -- EquipUI.SendNotify("EquipEnhance_Start", item.guid, safe, data.useUnBind and 1 or 0, item.ownerGuid)
    end
end
function EquipEnhanceUI.confirm1()
    data.checkOn = true
    EquipEnhanceUI.RefreshConsumeItem()
end
function EquipEnhanceUI.confirm2()
    local item = EquipEnhanceUI.GetItem()
    local safe = data.checkOn and 1 or 0
    EquipUI.SendNotify("EquipEnhance_Start", item.guid, safe, data.useUnBind and 1 or 0, item.ownerGuid)
end
-- 刷新ui
function EquipEnhanceUI.RefreshUI()
    EquipEnhanceUI.RefreshType()
end

function EquipEnhanceUI.ClientRefresh()
    -- EquipUI.CheckEquipRedPoint()
    for key, value in pairs(data.items) do
        
        data.attrs[key] = {}
        data.items[key] =
            EquipScrollItem.GetItemByType(
            key,
            ---@return bool
            ---@param item eqiupItem
            function(item)
                if EquipEnhanceUI.serverData.AllowList == nil then
                    return false
                end
                return EquipEnhanceUI.serverData.AllowList[item.subtype] == 1
            end
        )
        for i = 1, #data.items[key] do
            ---@type enhanceEqiupItem
            local item = data.items[key][i]
            -- local subName = "Normal"
            -- local t = {"Weapon", "Armor", "Access"}
            -- subName = t[item.subtype] or subName
            item.enhanceMaxLv = EquipEnhanceUI.serverData.MaxIntensifyLevel or 0
            -- EquipEnhanceUI.serverData.InteTimes["ALevel_" .. item.armorLevel][subName][item.itemLv] or 0
        end
    end
    EquipUI.SelectBagType(data)
    if data.index > #data.items[data.getBagType()] then
        data.index = 1
        data.checkOn = false
    end

    EquipEnhanceUI.RefreshUI()
end

function EquipEnhanceUI.OnLeftItemClick(guid)
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    -- data.checkOn = false
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
    end
    EquipEnhanceUI.RefreshMain()
    EquipEnhanceUI.RefreshConsumeItem()
end
---强化公式 异常情况返回0
---@param equipItem eqiupItem
---@param equipAttr enhanceDynAttrData
function EquipEnhanceUI.GetInteRange(nextlv, equipItem, equipAttr)
    -- test(equipItem.itemLv)
    -- test(equipItem.lv)
    local type = data.getBagType()
    local dyn = EquipUI.GetEquipData(equipItem.guid, type, equipItem.site)
    local GuangConfig = dyn:GetStrCustomAttr("EquipCreateRule")
    if
        EquipEnhanceUI.serverData ~= nil and EquipEnhanceUI.serverData.Config and
            EquipEnhanceUI.serverData.Config[nextlv] and
            EquipEnhanceUI.serverData.Config[nextlv].InteRangeFun
     then
        local serverData = EquipEnhanceUI.serverData
        local formula = 0
        local GradeCoefficient = serverData.GradeCoefficient and serverData.GradeCoefficient[equipItem.grade]
        local AttrCoefficient = serverData.AttrCoefficient and serverData.AttrCoefficient[(equipAttr.attr)]
        local PositionCoefficient = serverData.PositionCoefficient and serverData.PositionCoefficient[equipItem.subtype]
        local GuangCoefficient = serverData.GuangCoefficient and serverData.GuangCoefficient[equipItem.subtype]
        -- if serverData.formulaFun[equipItem.lv] ~= nil then
        --     formula = serverData.formulaFun[equipItem.lv](nextlv)
        -- else
        --     test("缺少 formula ", equipItem.lv)
        -- end
        if serverData.formulaFun[equipItem.itemLv] ~= nil then
            formula = serverData.formulaFun[equipItem.itemLv](nextlv)
        else
            test("缺少 formula ", equipItem.itemLv)
        end
        if GradeCoefficient == nil then
            test("缺少 GradeCoefficient ", equipItem.grade)
            GradeCoefficient = 0
        end
        if AttrCoefficient == nil then
            test("缺少 AttrCoefficient ", equipAttr.attr)
            return 0
        end
        if PositionCoefficient then
            if equipItem.subtype == LogicDefine.ItemSubType.weapon then
                -- 服务器表单定义，类型是武器的话不用subtype2,全部走0
                PositionCoefficient = PositionCoefficient[0]
            else
                PositionCoefficient = PositionCoefficient[equipItem.subtype2]
            end
        end
        if PositionCoefficient == nil then
            test("缺少 PositionCoefficient subtype = " .. equipItem.subtype .. " subtype2 " .. equipItem.subtype2)
            PositionCoefficient = 0
        end
        if GuangCoefficient then
            if GuangConfig == "" then
                GuangCoefficient = 1
            elseif equipItem.subtype == LogicDefine.ItemSubType.weapon then
                -- 服务器表单定义，类型是武器的话不用subtype2,全部走0
                GuangCoefficient = GuangCoefficient[0]
            else
                GuangCoefficient = GuangCoefficient[equipItem.subtype2]
            end
        end
        if GuangCoefficient == nil then
            test("缺少 GuangCoefficient subtype = " .. equipItem.subtype .. " subtype2 " .. equipItem.subtype2)
            GuangCoefficient = 0
        end
        return serverData.Config[nextlv].InteRangeFun(formula, GradeCoefficient, AttrCoefficient, PositionCoefficient, GuangCoefficient)
    else
        return 0
    end
end

---@public
---@param itemid number
---@param itemKeyName string
---@param h number
---@param eqiupItemTable eqiupItem
---@param eqiupItemAttrTable  enhanceDynAttrData[]
---@param showExValue number[]
---@return number
function EquipEnhanceUI.RefreshResultInfo(
    bg,
    itemid,
    itemKeyName,
    eqiupItemTable,
    eqiupItemAttrTable,
    showExValue,
    maxEnhance)
    test("EquipEnhanceUI.RefreshResultInfo")
    local bg = bg or guidt.GetUI("currentItem")
    if bg == nil then
        test("RefreshResultInfoe刷新道具错误")
    end
    local icon = GUI.GetChild(bg, "itemIcon", false)
    local name = GUI.GetChild(bg, "name", false)
    local enhanceLv = GUI.GetChild(bg, "enhanceLv", false)
    local lv = GUI.GetChild(enhanceLv, "lv", false)
    local src = GUI.GetChild(bg, "src", false)
    --local equipType = GUI.GetChild(bg, "equipType", false)
    local iteminfo = nil
    local nameTxt, lvTxt, lvNum = " "
    -- local enhanceLvTxt = 0
    if itemid ~= nil and itemKeyName ~= nil then
        iteminfo = DB.GetItem(itemid, itemKeyName)
    end
    if eqiupItemTable then
        if eqiupItemTable.bagtype == item_container_type.item_container_guard_equip and EquipUI.curGuardGuid then
            ItemIcon.BindGuardEquip(icon, EquipUI.curGuardGuid, eqiupItemTable.site)
        else
            ItemIcon.BindIndexForBag(icon, eqiupItemTable.site, eqiupItemTable.bagtype)
        end
        nameTxt = eqiupItemTable.name
        if maxEnhance then
            lvTxt = "强化等级:"
            lvNum = maxEnhance
        end
        --if maxEnhance then
            -- if enhanceLvTxt > 0 then
            --     enhanceLvTxt = " +" .. enhanceLvTxt
            -- else
            --     enhanceLvTxt = " "
            -- end
            --if eqiupItemTable.enhanceLv and eqiupItemTable.enhanceLv > 0 then
                -- enhanceLvTxt = eqiupItemTable.enhanceLv
            --end
            --lvTxt = "强化等级:"
            --lvNum = maxEnhance
            --if maxEnhance then
            --    -- enhanceLvTxt = enhanceLvTxt + maxEnhance
            --    lvNum = maxEnhance
            --end
        --else
        --    if eqiupItemTable.turnBorn > 0 then
        --        lvTxt = tostring(eqiupItemTable.turnBorn) .. "转" .. tostring(eqiupItemTable.lv) .. "级"
        --    else
        --        lvTxt = tostring(eqiupItemTable.lv) .. "级"
        --    end
        --    equipEnhanceLvTxt = eqiupItemTable.showType
        --end
    --elseif iteminfo ~= nil and iteminfo.Id > 0 then
    --    ItemIcon.BindItemId(icon, iteminfo.Id)
    --    nameTxt = iteminfo.Name
    --    test(iteminfo.Level)
    --    lvTxt = tostring(iteminfo.Level) .. "级"
    --    lvNum = iteminfo.ShowType
    else
        ItemIcon.BindItemId(icon, nil)
    end
    GUI.StaticSetText(name, nameTxt)
    local w = GUI.StaticGetLabelPreferWidth(name)
    GUI.SetWidth(name, w)
    --GUI.SetPositionX(enhanceLv, GUI.GetPositionX(name) + w + 5)
    GUI.StaticSetText(enhanceLv , lvTxt)
    GUI.StaticSetText(lv, lvNum)
    --GUI.SetColor(lv, UIDefine.EnhanceBlueColor)
    w = GUI.StaticGetLabelPreferWidth(lv)
    GUI.SetWidth(lv, w)
    --GUI.SetPositionX(equipType, GUI.GetPositionX(lv) + w + 5)
    --GUI.StaticSetText(equipType, equipTypeTxt)
    --if maxEnhance then
    --    GUI.SetColor(equipType, UIDefine.EnhanceBlueColor)
    --else
    --    GUI.SetColor(equipType, UIDefine.Yellow2Color)
    --end
    --GUI.SetVisible(enhanceLv, false)
    --GUI.StaticSetText(enhanceLv, enhanceLvTxt)
    --GUI.SetVisible(tip, false)
    local index = 1
    local y = 30
    if eqiupItemAttrTable and #eqiupItemAttrTable > MaxArtificeCnt then
        MaxArtificeCnt = #eqiupItemAttrTable
    end
    for i = 1, MaxArtificeCnt, 1 do
        local att = GUI.GetChild(src, "attText" .. i, false)
        local attv = GUI.GetChild(att, "value", false)
        if att == nil then
            local attText = GUI.CreateStatic(src, "attText" .. i, "物攻", 17, 5, 100, 30)
            GUI.SetColor(attText, UIDefine.BrownColor)
            GUI.StaticSetFontSize(attText, UIDefine.FontSizeM)
            UILayout.SetSameAnchorAndPivot(attText, UILayout.TopLeft)
            local value = GUI.CreateStatic(attText, "value", "10", 112, 0, 166, 30)
            GUI.SetColor(value, UIDefine.Green8Color)
            GUI.StaticSetFontSize(value, UIDefine.FontSizeM)
            att = attText
            attv = value
        end
        if showExValue ~= nil and showExValue[i] then
            index = showExValue[i].index
        else
            index = 0
        end
        if eqiupItemAttrTable and eqiupItemAttrTable[index] then
            GUI.SetVisible(att, true)
            y = y + 30
            GUI.StaticSetText(att, eqiupItemAttrTable[index].name)
            local cur, next = nil
            if eqiupItemAttrTable[index].IsPct then
                local getPct = function(longNum)
                    local l, h = int64.longtonum2(longNum)
                    local pct = 0
                    if h > 0 then
                        test("数据长度超限")
                    else
                        pct = l
                    end
                    return pct
                end
                local pct = getPct(eqiupItemAttrTable[index].value)
                cur = pct
                local pct = getPct(showExValue[i].value or 0)
                next = pct
                GUI.StaticSetText(attv, cur / 100.0 .. "% + " .. next / 100.0 .. "%")
            else
                cur = tostring(eqiupItemAttrTable[index].value)
                next = showExValue[i].value or 0
                GUI.StaticSetText(attv, cur .. " + " .. next)
            end

            GUI.SetColor(attv, UIDefine.Green8Color)
        else
            GUI.SetVisible(att, false)
        end
    end
    -- for i = 1, MaxArtificeCnt do
    --     if showExValue ~= nil and showExValue[i] then
    --         index = showExValue[i].index
    --     else
    --         index = 0
    --     end
    --     if eqiupItemAttrTable and eqiupItemAttrTable[index] then
    --         GUI.SetVisible(att, true)
    --         y = y + 30
    --         GUI.StaticSetText(att, eqiupItemAttrTable[index].name)
    --         local cur, next = nil
    --         if eqiupItemAttrTable[index].IsPct then
    --             local getPct = function(longNum)
    --                 local l, h = int64.longtonum2(longNum)
    --                 local pct = 0
    --                 if h > 0 then
    --                     test("数据长度超限")
    --                 else
    --                     pct = l
    --                 end
    --                 return pct
    --             end
    --             local pct = getPct(eqiupItemAttrTable[index].value)
    --             cur = pct
    --             local pct = getPct(showExValue[i].value or 0)
    --             next = pct
    --             GUI.StaticSetText(attv, cur / 100.0 .. "% + " .. next / 100.0 .. "%")
    --         else
    --             cur = tostring(eqiupItemAttrTable[index].value)
    --             next = showExValue[i].value or 0
    --             GUI.StaticSetText(attv, cur .. " + " .. next)
    --         end

    --         GUI.SetColor(attv, UIDefine.Green8Color)
    --     else
    --         GUI.SetVisible(att, false)
    --     end
    -- end
    return y
end

-- 刷新结果
function EquipEnhanceUI.RefreshMain()
    local normal = EquipEnhanceUI.GetItem()
    local nextlv = nil
    test("EquipEnhanceUI.RefreshMain")
    local rateNum = guidt.GetUI("rateNum")
    local luckNum = guidt.GetUI("luckNum")
    if normal == nil then
        local bg = guidt.GetUI("strengthenItem")
        EquipEnhanceUI.RefreshResultInfo(nil, nil, nil)
        EquipEnhanceUI.RefreshResultInfo(bg, nil, nil)
        GUI.StaticSetText(rateNum, "100%")
        GUI.StaticSetText(luckNum, "0%")
        local rulebg = GUI.GetChild(bg, "rulebg", false)
        local rule = GUI.GetChild(rulebg, "rule", false)
        GUI.StaticSetText(rule,"属性加成")
        GUI.StaticSetAlignment(rule, TextAnchor.MiddleLeft)
        return
    else
        if normal.enhanceLv < normal.enhanceMaxLv then
            local bg = guidt.GetUI("strengthenItem")
            local src = GUI.GetChild(bg, "src", false)
            local rulebg = GUI.GetChild(bg, "rulebg", false)
            local rule = GUI.GetChild(rulebg, "rule", false)
            GUI.StaticSetText(rule,"属性加成")
            GUI.StaticSetAlignment(rule, TextAnchor.MiddleLeft)
            GUI.SetVisible(src,true)
            GUI.StaticSetText(rateNum, (EquipEnhanceUI.serverData.Config[normal.enhanceLv + 1].Success / 100) .. "%")
        else
            local bg = guidt.GetUI("strengthenItem")
            local src = GUI.GetChild(bg, "src", false)
            local rulebg = GUI.GetChild(bg, "rulebg", false)
            local rule = GUI.GetChild(rulebg, "rule", false)
            GUI.StaticSetText(rule,"已达到强化上限")
            GUI.StaticSetAlignment(rule, TextAnchor.MiddleCenter)
            GUI.SetVisible(src,false)
            GUI.StaticSetText(rateNum, "Max")
        end
        GUI.StaticSetText(luckNum, tostring(normal.enhanceLuck / 100.0) .. "%")
        nextlv = math.min(normal.enhanceMaxLv, normal.enhanceLv + 1)
    end
    -- 获取强化属性
    local type = data.getBagType()
    if data.attrs[type][data.index] == nil and normal ~= nil then
        local dyn = EquipUI.GetEquipData(normal.guid, type, normal.site)
        --LD.GetItemDataByGuid(normal.guid, type)
        data.attrs[type][data.index] = {}
        LogicDefine.GetItemDynAttrDataByMark(
            dyn,
            LogicDefine.ItemAttrMark.Base,
            LogicDefine.ItemAttrMark.Enhance,
            data.attrs[type][data.index]
        )
    end
    ---@type enhanceDynAttrData[]
    local dynAttrs = data.attrs[type][data.index]
    local nextExStr = {}
    local curExStr = {}
    if dynAttrs ~= nil and nextlv ~= nil then
        for i = 1, #dynAttrs, 1 do
            local cur, next = 0
            if dynAttrs[i].IsPct then
                local getPct = function(longNum)
                    local l, h = int64.longtonum2(longNum)
                    local pct = 0
                    if h > 0 then
                        test("数据长度超限")
                    else
                        pct = l
                    end
                    return pct
                end
                local pct = getPct(dynAttrs[i].exV)
                cur = pct
                next = math.floor(EquipEnhanceUI.GetInteRange(nextlv, normal, dynAttrs[i]))
            else
                local l, h = int64.longtonum2(dynAttrs[i].value)
                cur, h = int64.longtonum2(dynAttrs[i].exV)
                next = math.floor(EquipEnhanceUI.GetInteRange(nextlv, normal, dynAttrs[i]))
            end
            nextExStr[i] = {index = i , value = next}
            curExStr[i] = {index = i , value = cur}
        end
    end
    -- for i = 1, MaxArtificeCnt do
    --     -- test("EquipEnhanceUI.RefreshMain" .. i)
    --     -- -- local cb = guidt.GetUI("attrLock" .. i)
    --     -- local name = guidt.GetUI("attrname" .. i)
    --     -- local attrnum = guidt.GetUI("attrnum" .. i)
    --     if dynAttrs ~= nil and i <= #dynAttrs and nextlv ~= nil then
    --         local cur, next = 0
    --         if dynAttrs[i].IsPct then
    --             local getPct = function(longNum)
    --                 local l, h = int64.longtonum2(longNum)
    --                 local pct = 0
    --                 if h > 0 then
    --                     test("数据长度超限")
    --                 else
    --                     pct = l
    --                 end
    --                 return pct
    --             end
    --             local pct = getPct(dynAttrs[i].exV)
    --             cur = pct
    --             next = math.floor(EquipEnhanceUI.GetInteRange(nextlv, normal, dynAttrs[i]))
    --         else
    --             local l, h = int64.longtonum2(dynAttrs[i].value)
    --             cur, h = int64.longtonum2(dynAttrs[i].exV)
    --             next = math.floor(EquipEnhanceUI.GetInteRange(nextlv, normal, dynAttrs[i]))
    --         end
    --         nextExStr[i] = {index = i , value = next}
    --         curExStr[i] = {index = i , value = cur}
    --         -- data.lock[i] = false
    --         -- GUI.SetColor(attrnum, UIDefine.OutLine_GreenColor)
    --     else
    --         -- GUI.SetVisible(name, false)
    --         -- GUI.SetVisible(attrnum, false)
    --     end
    --     -- GUI.SetVisible(cb, false)
    -- end
    EquipEnhanceUI.SortAttrsValue(curExStr,nextExStr,normal)
    EquipEnhanceUI.RefreshResultInfo(nil, normal.id, normal.keyname, normal, dynAttrs, curExStr, normal.enhanceLv)
    EquipEnhanceUI.RefreshResultInfo(
        guidt.GetUI("strengthenItem"),
        normal.id,
        normal.keyname,
        normal,
        dynAttrs,
        nextExStr,
        nextlv
    )
end
local sortAttrsFun = function (a,b)
    if a.value ~= b.value then
        return a.value > b.value
    else
        return a.index < b.index
    end
    return false
end
function EquipEnhanceUI.SortAttrsValue(list1,list2,item)
    table.sort(list1,sortAttrsFun)
    table.sort(list2,sortAttrsFun)
    for i = #list2, 1, -1 do
        if list2[i].value == 0 then
            local index = list2[i].index
            for j = #list1, 1, -1 do
                if list1[j].index == index then
                    table.remove(list1,j)
                    table.remove(list2,i)
                    break
                end
            end
        end
    end
end
function EquipEnhanceUI.OnhintBtn(guid)
    local txt = ""
    if Language and Language.EquipEnhancUTips then
        txt = Language.EquipEnhancUTips
    end
    local ui = guidt.GetUI("EquipEnhance")
    Tips.CreateHint(
        txt,
        ui,
        280,
        110,
        UILayout.Center,
        450,
        220
    )
end
function EquipEnhanceUI.OnCheckBind(guid)
    local check = EquipUI.guidt.GetUI("bindBtn")
    if guid == GUI.GetGuid(check) then
        data.useUnBind = GUI.CheckBoxExGetCheck(check)
    end
end
function EquipEnhanceUI.OnCheckItemClick(guid)
    for i = 1, consumeMax do
        local item = guidt.GetUI("consumeItem" .. i)
        local check = GUI.GetChild(item, "check")
        if guid == GUI.GetGuid(check) then
            local normal = EquipEnhanceUI.GetItem()
            local config = EquipEnhanceUI.serverData.Config[normal.enhanceLv + 1]
            if config ~= nil and normal then
                data.checkOn = GUI.CheckBoxExGetCheck(check)
            else
                GUI.CheckBoxExSetCheck(check, false)
            end
        end
    end
end
function EquipEnhanceUI.OnConsumeItemClick(guid)
    for i = 1, consumeMax do
        local item = guidt.GetUI("consumeItem" .. i)
        if guid == GUI.GetGuid(item) then
            local normal = EquipEnhanceUI.GetItem()
            local config = EquipEnhanceUI.serverData.Config[normal.enhanceLv + 1]
            if config ~= nil then
                local id = config.item[i].id
                if normal ~= nil then
                    local itemtips =  Tips.CreateByItemId(id, EquipUI.guidt.GetUI("equipPage"), "tips", 0, 0, 50)
                    GUI.SetData(itemtips, "ItemId", tostring(id))
                    guidt.BindName(itemtips,"tips")

                    local ItemData = DB.GetOnceItemByKey1(id)
                    local WidthX = 0
                    if tonumber(ItemData.Subtype2) == 23 then
                        WidthX = -90

                        local SynthesisButton = GUI.ButtonCreate(itemtips, "SynthesisButton", 1800402110, 90, -15, Transition.ColorTint, "合成", 150, 50, false);
                        UILayout.SetSameAnchorAndPivot(SynthesisButton, UILayout.Bottom)
                        GUI.ButtonSetTextColor(SynthesisButton, UIDefine.BrownColor)
                        GUI.ButtonSetTextFontSize(SynthesisButton, UIDefine.FontSizeL)
                        GUI.RegisterUIEvent(SynthesisButton,UCE.PointerClick,"EquipEnhanceUI","OnSynthesisButtonClick")
                    else
                        WidthX = 0
                    end

                    local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, WidthX, -15, Transition.ColorTint, "获取途径", 150, 50, false);
                    UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
                    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
                    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
                    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"EquipEnhanceUI","onClickEquilWayBtn")
                    GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
                end
            end
        end
    end
end
function EquipEnhanceUI.onClickEquilWayBtn()
    local tip = guidt.GetUI("tips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end
-- 刷新消耗道具
function EquipEnhanceUI.RefreshConsumeItem()
    local normal = EquipEnhanceUI.GetItem()
    if normal == nil then
        EquipEnhanceUI.RefreshConsumeItemEx(EquipEnhanceUI.consumeMax, {})
        EquipEnhanceUI.RefreshConsumeCoin(RoleAttr.RoleAttrBindGold, 0)
        return
    end

    if EquipEnhanceUI.serverData.Config ~= nil then
        local config = EquipEnhanceUI.serverData.Config[normal.enhanceLv + 1]
        if config ~= nil then
            EquipEnhanceUI.RefreshConsumeItemEx(
                EquipEnhanceUI.consumeMax,
                config.item,
                config.safeIndex,
                data.checkOn
            )
            EquipEnhanceUI.RefreshConsumeCoin(UIDefine.GetMoneyEnum(config.MoneyType), config.MoneyVal)
        else
            EquipEnhanceUI.RefreshConsumeItemEx(EquipEnhanceUI.consumeMax, {})
            EquipEnhanceUI.RefreshConsumeCoin(RoleAttr.RoleAttrBindGold, 0)
        end
    end
    local check = EquipUI.guidt.GetUI("bindBtn")
    GUI.CheckBoxExSetCheck(check, data.useUnBind)
end

---@param consumeMax number @comment 消耗道具数量
---@param items eqiupItem[] @comment 道具数组
---@param consumeXPos table[] @comment uiX坐标
---@param checkBoxIndex number @comment 从第几个元素开始出现选择框
---@param checkIsOn bool[] @comment 选择框开关
function EquipEnhanceUI.RefreshConsumeItemEx(consumeMax, items, checkBoxIndex, checkIsOn)
    local consumeNum = 0
    local notnil = (items ~= nil)
    local FossilSynthesisButton = guidt.GetUI("FossilSynthesisButton")
    for i = 1, consumeMax do
        local item = guidt.GetUI("consumeItem" .. i)
        local info = items
        if notnil and i <= #info then
            consumeNum = consumeNum + 1
            GUI.SetVisible(item, true)
            GUI.SetVisible(FossilSynthesisButton, true)
            -- test(info[i].id)
            -- test(info[i].count)
            ItemIcon.BindItemIdWithNum(item, info[i].id, info[i].count)
            local name = GUI.GetChild(item, "name", false)
            local check = GUI.GetChild(item, "check", false)
            if checkBoxIndex and i >= checkBoxIndex then
                GUI.SetVisible(check, true)
                if checkIsOn then
                    GUI.CheckBoxExSetCheck(check, true)
                else
                    GUI.CheckBoxExSetCheck(check, false)
                end
            else
                GUI.SetVisible(check, false)
            end
            local iteminfo = DB.GetItem(info[i].id, info[i].keyname)
            if iteminfo ~= nil and iteminfo.Id > 0 then
                GUI.StaticSetText(name, iteminfo.Name)
            end
        else
            GUI.SetVisible(item, false)
            GUI.SetVisible(FossilSynthesisButton, false)
        end
    end
end

function EquipEnhanceUI.RefreshConsumeCoin(coin_type, coin_count)
    local bg = guidt.GetUI("consumeBg")
    local consumeText = guidt.GetUI("consumeText")
    GUI.SetVisible(bg, true)
    GUI.SetVisible(consumeText, true)

    local coin = GUI.GetChild(bg, "coin", false)
    local num = GUI.GetChild(bg, "num", false)
    -- test(tostring(CL.GetAttr(coin_type)))
    -- test(coin_count)
    local l, h = int64.longtonum2(CL.GetAttr(coin_type))
    local curnum = l
    if curnum < coin_count then
        GUI.SetColor(num, UIDefine.RedColor)
    else
        GUI.SetColor(num, UIDefine.WhiteColor)
    end
    GUI.ImageSetImageID(coin, UIDefine.AttrIcon[coin_type])
    GUI.StaticSetText(num, tostring(coin_count))
end

---@return enhanceEqiupItem
function EquipEnhanceUI.GetItem(index)
    if index == nil then
        index = data.index
    end
    return data.items[data.getBagType()][index]
end
-- 打造成功
function EquipEnhanceUI.OnBuildSucces()
    test("EquipEnhanceUI OnBuildSucces " .. data.Build_Time)
    GUI.OpenWnd("ShowEffectUI", 3000001406)
    ShowEffectUI.SetTimeOff(data.Build_Time)
end
-- 打造失败
function EquipEnhanceUI.OnBuildFail()
    test("EquipEnhanceUI OnBuildFail " .. data.Build_Time)
    GUI.OpenWnd("ShowEffectUI", 3000001426)
    ShowEffectUI.SetTimeOff(data.Build_Time)
end
function EquipEnhanceUI.RefreshCfgNoChange()
    EquipEnhanceUI.ClientRefresh()
end
-- 服务器通知刷新
function EquipEnhanceUI.Refresh()
    local strtmp = "local formula,GradeCoefficient,AttrCoefficient,PositionCoefficient,GuangCoefficient=...;return "
    for i = 1, #EquipEnhanceUI.serverData.Config do
        local item = EquipEnhanceUI.serverData.Config[i]
        item.InteRangeFun = assert(loadstring(strtmp .. item.InteRange))
        item.item = LogicDefine.SeverItems2ClientItems(item.ItemList)
        item.safeIndex = #(item.item) + 1
        item.item = LogicDefine.SeverItems2ClientItems(item.safeItem, item.item)
    end
    test("EquipEnhanceUI.Refresh")
    EquipEnhanceUI.serverData.formulaFun = {}
    strtmp = "local IntensifLevel=...;return "
    if EquipEnhanceUI.serverData.formula then
        for key, value in pairs(EquipEnhanceUI.serverData.formula) do
            EquipEnhanceUI.serverData.formulaFun[key] = assert(loadstring(strtmp .. value))
        end
    end
    EquipEnhanceUI.ClientRefresh()
end

-- function EquipEnhanceUI.RefreshItemCheckRedPoint()
--     local eqiupType = {
--         {
--             bagtype = item_container_type.item_container_equip,
--             label = "Equip"
--         },{
--             bagtype = item_container_type.item_container_bag,
--             label = "Bag"
--         }
--     }
--     local enhanceItemList = {}
--     local moneyInfo = {}
--     GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB[eqiupType[1].label] = {}
--     GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB[eqiupType[2].label] = {}
--     for i = 1, #eqiupType, 1 do
--         local eqiupItems = data.items[eqiupType[i].bagtype]
--         for index, item in pairs(eqiupItems) do
--             local isShowRedPoint = false
--             local itemguid = tostring(item.guid)
--             local config = EquipEnhanceUI.serverData.Config[item.enhanceLv + 1]
--             local MoneyType = config.MoneyType
--             local MoneyVal = config.MoneyVal
--             local itemList = config.ItemList
--             local itemCount = 0
--             if enhanceItemList[itemList[1]] == nil then
--                 local itemDB = DB.GetOnceItemByKey2(itemList[1]);
--                 itemCount = LD.GetItemCountById(itemDB.Id)
--                 enhanceItemList[itemList[1]] = itemCount
--             else
--                 itemCount = enhanceItemList[itemList[1]]
--             end
--             -- local itemDB = DB.GetOnceItemByKey2(itemList[1]);
--             -- local itemCount = LD.GetItemCountById(itemDB.Id)
--             if itemCount >= itemList[2] then
--                 isShowRedPoint = true
--             end
--             if moneyInfo["MoneyType" .. MoneyType] == nil then
--                 moneyInfo["MoneyType" .. MoneyType] = {}
--                 local l, h = int64.longtonum2(CL.GetAttr(UIDefine.GetMoneyEnum(MoneyType)))
--                 moneyInfo["MoneyType" .. MoneyType][MoneyType] = l
--             end
--             local curnum = moneyInfo["MoneyType" .. MoneyType][MoneyType]

--             if curnum < MoneyVal then
--                 isShowRedPoint = false
--             end

--             local thisItem = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB[eqiupType[i].label][itemguid]
--             if thisItem == nil then
--                 GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB[eqiupType[i].label][itemguid] = {}
--                 thisItem = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB[eqiupType[i].label][itemguid]
--                 thisItem[1] = {}
--             end
--             thisItem[1].Consume = {MoneyType = MoneyType,MoneyVal = MoneyVal}
--             thisItem[1].ConsumeItem = {itemList[1],itemList[2]}
--             thisItem[1].CanIntensify = tostring(isShowRedPoint)
--         end
--     end
-- end

function EquipEnhanceUI.CheckRedPoint()
    -- EquipEnhanceUI.CheckRedPoint_TB = {
    -- Bag = {
    -- ["360676108458000448"] = {
    --   CanIntensify = "true",
    --   Consume = {
    --     MoneyType = 5,
    --     MoneyVal = 20000
    --   },
    --   ConsumeItem = { "装备强化石", 2 }
    -- },
    -- ["360676116654784534"] = {
    --   CanIntensify = "false",
    --   Consume = {
    --     MoneyType = 5,
    --     MoneyVal = 50000
    --   },
    --   ConsumeItem = { "装备强化石", 5 }
    -- },
    -- test("EquipEnhanceUI.CheckRedPoint")
    -- test("-------------------------")
    -- local inspect = require("inspect")
    -- test(inspect(GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB))
    local equipPage = EquipUI.guidt.GetUI("equipPage")
    local inEquipBtn = GUI.GetChild(equipPage,"inEquipBtn")
    local isEquipShowRedPoint = false
    if GlobalProcessing and GlobalProcessing.EquipEnhanceUI then
        if GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB then
            for itemguid, itemvalue in pairs(GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB["Equip"]) do
                isEquipShowRedPoint = itemvalue[1].CanIntensify == "true"
                if isEquipShowRedPoint then
                    break
                end
            end
        end
    end

    if EquipUI.tabIndex == 1 and EquipUI.tabSubIndex == 1 then
        GlobalProcessing.SetRetPoint(inEquipBtn,isEquipShowRedPoint)
        EquipEnhanceUI.ClientRefresh()
    else
        GlobalProcessing.SetRetPoint(inEquipBtn,false)
    end
end

function EquipEnhanceUI.OnSynthesisButtonClick()
    GUI.OpenWnd("EquipFossilSynthesisUI")
end