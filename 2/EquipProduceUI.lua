local EquipProduceUI = {
    serverData = {
        Classify_Table = {},
        Classify_Desc = "阶级分类",
        Synthesis = {},
        Version = "0",
        Build_Time = 0
    },
    consumeMax = 0
}
--local test = print
-- local infotxt = "1.打造必定成功；\n2.打造出的装备，属性和数值随机生成；\n3.打造不会影响装备的穿戴要求；\n4.当使用绑定材料打造时，打造出的装备也为绑定"
-- 装备最大属性数
local attrMax = 2
-- 最大道具消耗数
local consumeMax = 4
EquipProduceUI.consumeMax = consumeMax
EquipProduceUI.EquipItemGuid = nil
EquipProduceUI.NewItemGuid = nil
EquipProduceUI.NewItem = nil
-- local test = print
local test = function()
end
_G.EquipProduceUI = EquipProduceUI
function EquipProduceUI.InitData()
    EquipProduceUI.serverData.Version = "0"
    return {
        ---@type string[]
        Classify = {},
        ---@type tabel<string,Synthesis>
        Synthesis = {},
        lv = "无",
        lvIndex = 1,
        index = 1,
        indexGuid = int64.new(0),
        useUnBind = false,
        checkOn = false,
        ---@type table<string,ProduceEquipData>
        des = {}
    }
end
local data = EquipProduceUI.InitData()
function EquipProduceUI.OnExitGame()
    CL.UnRegisterMessage(GM.AddNewItem, "EquipProduceUI", "AddEquipItem")
    data = EquipProduceUI.InitData()
end
local guidt = UILayout.NewGUIDUtilTable()
-- 关闭只属于子页签的东西
function EquipProduceUI.Close(guidt)
    local ui = guidt.GetUI("EquipProduce")
    GUI.SetVisible(ui, false)
end
-- 获取打造相关小红点的内容
-- EquipProduceUI.CheckRedPoint_TB = GlobalProcessing.EquipProduceUI.CheckRedPoint_TB
--强化ui底部name
local uiBKey = {
    -- "vpText",
    -- "vpBg",
    "luckText",
    "luckNum"
}
function EquipProduceUI.GetDesData()
    local e1, e2, e3 = EquipProduceUI.GetNormalEquipsInfo()
    if e1 == nil or e2 == nil or e3 == nil then
        test("打造目标错误")
    else
        if data.des[e2.keyname] == nil or data.des[e3.keyname] == nil then
            test("EquipBuild_GetEquipData ", data.lv, EquipProduceUI.GetNormalInfo().index)
            CL.SendNotify(
                NOTIFY.SubmitForm,
                "FormEquip",
                "EquipBuild_GetEquipData",
                data.lv,
                EquipProduceUI.GetNormalInfo().index
            )
            return
        end
    end
    --test("EquipProduceUI.GetDesData()")
    EquipProduceUI.DesRefresh()
end
function EquipProduceUI.GetLvData(lvStr)
    lvStr = lvStr or data.lv
    test("lvStr: ", lvStr)
    EquipProduceUI.serverData.Synthesis = {}
    if data.Synthesis[lvStr] == nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "GetLevelData", lvStr)
    else
        EquipProduceUI.RefreshLvDes()
    end
end
function EquipProduceUI.GetData()
    CL.SendNotify(NOTIFY.SubmitForm, "FormEquip", "EquipBuild_GetData", EquipProduceUI.serverData.Version)
end
-- 关闭或者打开只属于子页签的东西
function EquipProduceUI.SetVisible(visible)
    local ui = guidt.GetUI("EquipProduce")
    local artificeItem = GUI.GetChild(ui,"artificeItem")
    local normalItem = GUI.GetChild(ui,"normalItem")
    --guidt.GetUI("artificeItem")
    --local normalItem = guidt.GetUI("normalItem")
    local vpText = guidt.GetUI("vpText")
    local vpBg = guidt.GetUI("vpBg")
    --郑
    
    local hintBtn_left = GUI.GetChild(normalItem,"hintBtn")
    local hintBtn_right = GUI.GetChild(artificeItem,"hintBtn")
    GUI.SetVisible(hintBtn_left,visible)
    GUI.SetVisible(hintBtn_right,visible)
    --
    local equipPage = EquipUI.guidt.GetUI("equipPage")
    local inEquipBtn = GUI.GetChild(equipPage,"inEquipBtn")
    local inBagBtn = GUI.GetChild(equipPage,"inBagBtn")
    GUI.SetVisible(inEquipBtn, not visible)
    GUI.SetVisible(inBagBtn, not visible)
    if visible then
        GUI.SetVisible(EquipUI.guidt.GetUI("EquipBottom"),false)
    end
    
    local remainder = EquipUI.guidt.GetUI("emptyIamge")
    local remainder_bg = EquipUI.guidt.GetUI("emptyIamgeTxtBg")
    GUI.SetVisible(remainder,not visible)
    GUI.SetVisible(remainder_bg,not visible)
    local tmpui = {ui, artificeItem, vpBg, vpText}
    for i = 1, #tmpui do
        GUI.SetVisible(tmpui[i], visible)
    end
    local levelSelectCover = guidt.GetUI("levelSelectCover") 
    GUI.SetVisible(levelSelectCover, false)
    for i = 1, #uiBKey do
        local ui = EquipUI.guidt.GetUI(uiBKey[i])
        GUI.SetVisible(ui, false)
    end
    local enhanceBtn = guidt.GetUI("enhanceBtn")
    local unbind = EquipUI.guidt.GetUI("bindBtn")

    if visible == false then
        -- CL.UnRegisterMessage(GM.RefreshBag, "EquipProduceUI", "RefreshItemCheckRedPoint")
        CL.UnRegisterMessage(GM.AddNewItem, "EquipProduceUI", "AddEquipItem")
        for i = 1, consumeMax do
            local item = guidt.GetUI("consumeItem" .. i)
            GUI.UnRegisterUIEvent(item, UCE.PointerClick, "EquipProduceUI", "OnConsumeItemClick")
            local check = GUI.GetChild(item, "check")
            GUI.UnRegisterUIEvent(check, UCE.PointerClick, "EquipProduceUI", "OnCheckItemClick")
        end
        GUI.UnRegisterUIEvent(unbind, UCE.PointerClick, "EquipProduceUI", "OnCheckBind")
        GUI.UnRegisterUIEvent(enhanceBtn, UCE.PointerClick, "EquipProduceUI", "OnProduceBtnClick")
        if EquipUI.RefreshLeftItemScroll == EquipProduceUI.RefreshLeftItem then
            EquipUI.RefreshLeftItemScroll = nil
            EquipUI.ClickLeftItemScroll = nil
        end
        -- local bg = guidt.GetUI("normalItem")
        -- if bg ~= nil then
        --     for i = 1, attrMax do
        --         local att = GUI.GetChild(bg, "attText" .. i, false)
        --         GUI.SetVisible(att, false)
        --     end
        -- end
    else
        -- CL.RegisterMessage(GM.RefreshBag, "EquipProduceUI", "RefreshItemCheckRedPoint")
        CL.RegisterMessage(GM.AddNewItem, "EquipProduceUI", "AddEquipItem")
        for i = 1, consumeMax do
            local item = guidt.GetUI("consumeItem" .. i)
            GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipProduceUI", "OnConsumeItemClick")
            local check = GUI.GetChild(item, "check")
            GUI.RegisterUIEvent(check, UCE.PointerClick, "EquipProduceUI", "OnCheckItemClick")
        end
        --郑
        GUI.RegisterUIEvent(hintBtn_left, UCE.PointerClick, "EquipProduceUI", "OnhintBtn_left")
        GUI.RegisterUIEvent(hintBtn_right, UCE.PointerClick, "EquipProduceUI", "OnhintBtn_right")
        --
        GUI.RegisterUIEvent(unbind, UCE.PointerClick, "EquipProduceUI", "OnCheckBind")
        GUI.RegisterUIEvent(enhanceBtn, UCE.PointerClick, "EquipProduceUI", "OnProduceBtnClick")
        EquipUI.RefreshLeftItemScroll = EquipProduceUI.RefreshLeftItem
        EquipUI.ClickLeftItemScroll = EquipProduceUI.OnLeftItemClick
    end
end
function EquipProduceUI.AddEquipItem(guid)
    test("************************************")
	test(tostring(guid))
    local isProduceEquip = false
    local normal = EquipProduceUI.GetNormalInfo()
    local adderItems = normal.result_adder
    local basicItems = normal.result_basic
    local itemData = LD.GetItemDataByGuid(guid)
    local itemDB = DB.GetOnceItemByKey1(tostring(itemData.id))
    for i = 1, #adderItems, 2 do
        if adderItems[i] == itemDB.KeyName then
            isProduceEquip = true
        end
    end
    for i = 1, #basicItems, 2 do
        if basicItems[i] == itemDB.KeyName then
            isProduceEquip = true
        end
    end
    if isProduceEquip then
        EquipProduceUI.NewItem = guid
        EquipProduceUI.NewItemGuid = tostring(guid)
        local site = LogicDefine.GetEquipSite(itemDB.Type, itemDB.Subtype, itemDB.Subtype2)
        local equip = LogicDefine.GetEquipBySite(site)
        if equip then
            EquipProduceUI.EquipItemGuid = equip.guid
        end
    end
end
function EquipProduceUI.OnCheckBind(guid)
    local check = EquipUI.guidt.GetUI("bindBtn")
    if guid == GUI.GetGuid(check) then
        data.useUnBind = GUI.CheckBoxExGetCheck(check)
    end
end
function EquipProduceUI.OnProduceBtnClick()
    local normal = EquipProduceUI.GetNormalInfo()
    if normal ~= nil then
        CL.SendNotify(
            NOTIFY.SubmitForm,
            "FormEquip",
            "EquipBuild_StartBuilding",
            data.lv,
            normal.index,
            data.checkOn and 1 or 0,
            data.useUnBind and 1 or 0
        )
    end
end

-- 装备打造左侧装备排序(优先级按道具类型武器-装备-饰物排序，在同个类型下按照类型编号由小到大排序)
function EquipProduceUI.EquipProduceLeftNormalSort(Normal)
    Normal = Normal or data.Synthesis[data.lv].Normal

    if not Normal then
        return
    end
    
    table.sort(Normal, function(v1, v2)
        local _v1Id, _v2Id = v1.result_basicItem[1].id, v2.result_basicItem[1].id
        local _v1Subtype, _v2Subtype = DB.GetOnceItemByKey1(_v1Id).Subtype, DB.GetOnceItemByKey1(_v2Id).Subtype

        if _v1Subtype < _v2Subtype then
            return true
        elseif _v1Subtype == _v2Subtype then
            return _v1Id < _v2Id
        end
    end)
end

function EquipProduceUI.RefreshUI()
    local scroll = EquipUI.guidt.GetUI("itemScroll")
    if data.Synthesis[data.lv] ~= nil and data.Synthesis[data.lv].Normal then
        -- local max = #data.Synthesis[data.lv].Normal
        -- if max > 0 then
        --     local min = Mathf.Min(data.index, max - 4)
        --     min = Mathf.Max(min, 1)
        --     GUI.ScrollRectSetNormalizedPosition(scroll, Vector2.New(0, (min - 1) / max))
        -- end
        GUI.LoopScrollRectSetTotalCount(scroll, 0)
        GUI.LoopScrollRectSetTotalCount(scroll, #data.Synthesis[data.lv].Normal) --创建有多少个 + 左侧装备的节点数量
        -- 打造页面左侧装备排序
        EquipProduceUI.EquipProduceLeftNormalSort()
    else
        GUI.LoopScrollRectSetTotalCount(scroll, 0)
    end
    GUI.LoopScrollRectRefreshCells(scroll)
    local txt = guidt.GetUI("currentLevel")
    --设置选择框的 文字等级
    GUI.StaticSetText(txt, data.lv)
    EquipProduceUI.RefreshConsumeItem()
    local check = EquipUI.guidt.GetUI("bindBtn")
    GUI.CheckBoxExSetCheck(check, data.useUnBind)
    EquipProduceUI.GetDesData()
    -- EquipUI.CheckEquipRedPoint()
  end
function EquipProduceUI.RefreshInfoUI()
    EquipProduceUI.RefreshNormalProduce()
end
function EquipProduceUI.Show(reset)
    test("EquipProduceUI.Show")
    if reset then
        EquipProduceUI.GetData()
        data.lv = "无"
        data.index = 0
        data.lvIndex = 0
        data.checkOn = false
        data.useUnBind = false
        EquipProduceUI.CheckDataFormat(reset)
        EquipProduceUI.GetLvData()
    end
    EquipProduceUI.SetVisible(true)
    EquipProduceUI.ClientRefresh()
end
function EquipProduceUI.OnCheckItemClick(guid)
    for i = 1, consumeMax do
        local item = guidt.GetUI("consumeItem" .. i)
        local check = GUI.GetChild(item, "check")
        if guid == GUI.GetGuid(check) then
            local normal = EquipProduceUI.GetNormalInfo()
            if normal then
                data.checkOn = GUI.CheckBoxExGetCheck(check)
            else
                GUI.CheckBoxExSetCheck(check, false)
            end
        end
    end
end
function EquipProduceUI.CheckDataFormat(reset)
    test(data.lvIndex)
    if reset then
        if #data.Classify > 0 then
            local index = 0
            local lv = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
            for i = 1, #data.Classify do
                -- body
                local tmp = tonumber(string.sub(data.Classify[i], string.find(data.Classify[i], "%d+")))
                -- test("str ", tmp)
                if tmp and lv < tmp then
                    -- test(tmp)
                    break
                end
                index = i
            end
            data.lv = data.Classify[index]
            data.index = 1
            data.lvIndex = index
        else
            data.lv = "无"
            data.index = 0
            data.lvIndex = 0
        end
    end
    if #data.Classify > 0 and (data.lvIndex == 0 or data.lvIndex > #data.Classify) then
        data.lv = data.Classify[1]
        data.index = 1
        data.lvIndex = 1
        data.checkOn = false
    end
    test(data.lvIndex)
end

function EquipProduceUI.ClientRefresh()
    EquipProduceUI.RefreshUI()
end

---@param tableSynthesis tabel<string,Synthesis>
function EquipProduceUI.RefreshLvDes(tableSynthesis)
    if tableSynthesis then
        for key, value in pairs(tableSynthesis) do
            data.Synthesis[key] = value
            if value.Normal == nil then
                value.Normal = {}
            end
            for key1, value1 in pairs(value) do
                if key1 == "Normal" then
                else
                    local cnt = #value.Normal
                    for i = 1, #value1 do
                        value.Normal[cnt + i] = value1[i]
                    end
                end
            end
            for i = 1, #value.Normal do
                value.Normal[i].vitality = value.Normal[i].vitality or 0
                value.Normal[i].result_basic_itemId = {}
                value.Normal[i].formula_adderItem = LogicDefine.SeverItems2ClientItems(value.Normal[i].formula_adder)
                value.Normal[i].result_adderItem = LogicDefine.SeverItems2ClientItems(value.Normal[i].result_adder)
                value.Normal[i].formula_basicItem = LogicDefine.SeverItems2ClientItems(value.Normal[i].formula_basic)
                value.Normal[i].result_basicItem = LogicDefine.SeverItems2ClientItems(value.Normal[i].result_basic)
            end
        end
    end
    EquipProduceUI.ClientRefresh()
end
function EquipProduceUI.Refresh()
    test("EquipProduceUI.Refresh")
    if EquipProduceUI.serverData.Classify_Table ~= nil then
        data.Classify = EquipProduceUI.serverData.Classify_Table
        data.Synthesis = {}
    end
    EquipProduceUI.CheckDataFormat(true)
    EquipProduceUI.GetLvData()
end
---@param desData table<string,ProduceEquipData>
function EquipProduceUI.DesRefresh(desData)
    if desData then
        for key, value in pairs(desData) do
            if key == "VP" then
            else
                local t = value
                for i = 1, #t.attr do
                    t.attr[i].ChinaName = DB.GetOnceAttrByKey1(t.attr[i].Name).ChinaName
                end
                data.des[key] = t
            end
        end
    end
    EquipProduceUI.RefreshInfoUI()
end

function EquipProduceUI.CreateEquipItem(parent,name,x,y,title)
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
    local enhanceLv = GUI.CreateStatic(itemBg, "enhanceLv", " ", 115, 60, 150, 30)
    GUI.SetColor(enhanceLv, UIDefine.EnhanceBlueColor)
    GUI.StaticSetFontSize(enhanceLv, UIDefine.FontSizeL)
    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)
    local level = GUI.CreateStatic(itemBg, "lv", "10级", 115, 100, 100, 30)
    GUI.SetColor(level, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(level, UIDefine.FontSizeM)
    local equipType = GUI.CreateStatic(itemBg, "equipType", "武器", 175, 100, 200, 30)
    GUI.SetColor(equipType, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(equipType, UIDefine.FontSizeM)
    local rulebg = GUI.ImageCreate(itemBg, "rulebg", "1801100040", 15, 145)
    local rule = GUI.CreateStatic(rulebg, "rule", "属性加成", 2, 0, 100, 30)
    GUI.SetColor(rule, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(rule, UIDefine.FontSizeM)
    local src = GUI.ScrollListCreate(itemBg, "src", 15, 175, 300, 70, false, UIAroundPivot.TopLeft, UIAnchor.TopLeft)

    --郑
    local hintBtn = GUI.ButtonCreate(itemBg, "hintBtn", "1800702030", 250, 5, Transition.ColorTint, "", 30, 30, false)
    --

    -- for i = 1, attrMax do
    --     local att1Text = GUI.CreateStatic(src, "attText" .. i, "属性1", 17, 0, 100, 30)
    --     GUI.SetColor(att1Text, UIDefine.BrownColor)
    --     GUI.StaticSetFontSize(att1Text, UIDefine.FontSizeM)
    --     UILayout.SetSameAnchorAndPivot(att1Text, UILayout.TopLeft)
    --     local value = GUI.CreateStatic(att1Text, "value", "10", 112, 0, 166, 30)
    --     GUI.SetColor(value, UIDefine.Green8Color)
    --     GUI.StaticSetFontSize(value, UIDefine.FontSizeM)
    -- end
    -- local tip = GUI.CreateStatic(src, "tip", "", 15, 0, 250, 30)
    -- GUI.SetColor(tip, UIDefine.Yellow2Color)
    -- GUI.StaticSetFontSize(tip, UIDefine.FontSizeM)
    -- UILayout.SetSameAnchorAndPivot(tip, UILayout.TopLeft)
end

function EquipProduceUI.CreateSubPage(equipPage)
    guidt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("EquipProduceUI", "OnExitGame")
    --local EquipProduceUI = GUI.GroupCreate(equipPage, "EquipProduceUI", 0, 0, 0, 0)
    --EquipUI.guidt.BindName(EquipProduceUI, "EquipProduceUI")
    local EquipProduce = GUI.GroupCreate(equipPage, "EquipProduce", 0, 0, 0, 0)
    guidt.BindName(EquipProduce, "EquipProduce")

    local normalItem = EquipProduceUI.CreateEquipItem(EquipProduce,"normalItem",-190,-190,"普通打造极品预览")
    guidt.BindName(normalItem, "normalItem")
    local artificeItem = EquipProduceUI.CreateEquipItem(EquipProduce,"artificeItem",200,-190,"强化打造极品预览")
    guidt.BindName(artificeItem, "artificeItem")
    
    
    --local normalBg = GUI.ImageCreate(equipPage, "normalBg", "1801100030", -150, -190, false, 300, 260)
    --UILayout.SetSameAnchorAndPivot(normalBg, UILayout.TopLeft)
    --EquipUI.guidt.BindName(normalBg, "normalBg")
    --local title = GUI.CreateStatic(normalBg, "title", "打造预览", 20, 5, 200, 30)
    --GUI.SetColor(title, UIDefine.BrownColor)
    --GUI.StaticSetFontSize(title, UIDefine.FontSizeL)
    --local itemIcon = GUI.ItemCtrlCreate(normalBg, "itemIcon", UIDefine.ItemIconBg2[1], 18, 53)
    --local name = GUI.CreateStatic(normalBg, "name", "名字", 115, 60, 150, 30)
    --GUI.SetColor(name, UIDefine.BrownColor)
    --GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
    --UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)
    --local enhanceLv = GUI.CreateStatic(normalBg, "enhanceLv", " ", 115, 60, 150, 30)
    --GUI.SetColor(enhanceLv, UIDefine.EnhanceBlueColor)
    --GUI.StaticSetFontSize(enhanceLv, UIDefine.FontSizeL)
    --UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)
    --local level = GUI.CreateStatic(normalBg, "lv", "10级", 115, 100, 100, 30)
    --GUI.SetColor(level, UIDefine.Yellow2Color)
    --GUI.StaticSetFontSize(level, UIDefine.FontSizeM)
    --local equipType = GUI.CreateStatic(normalBg, "equipType", "武器", 175, 100, 100, 30)
    --GUI.SetColor(equipType, UIDefine.Yellow2Color)
    --GUI.StaticSetFontSize(equipType, UIDefine.FontSizeM)
    --local rulebg = GUI.ImageCreate(normalBg, "rulebg", "1801100040", 15, 145)
    --local rule = GUI.CreateStatic(rulebg, "rule", "属性加成", 2, 0, 100, 30)
    --GUI.SetColor(rule, UIDefine.WhiteColor)
    --GUI.StaticSetFontSize(rule, UIDefine.FontSizeM)
    --local src = GUI.ScrollListCreate(normalBg, "src", 15, 175, 300, 70, false, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
    --
    ----郑
    --local hintBtn_left = GUI.ButtonCreate(normalBg, "hintBtn_left", "1800702030", 250, 5, Transition.ColorTint, "", 30, 30, false)
    ----
    --
    --for i = 1, attrMax do
    --    local att1Text = GUI.CreateStatic(src, "attText" .. i, "属性1", 17, 0, 100, 30)
    --    GUI.SetColor(att1Text, UIDefine.BrownColor)
    --    GUI.StaticSetFontSize(att1Text, UIDefine.FontSizeM)
    --    UILayout.SetSameAnchorAndPivot(att1Text, UILayout.TopLeft)
    --    local value = GUI.CreateStatic(att1Text, "value", "10", 112, 0, 166, 30)
    --    GUI.SetColor(value, UIDefine.Green8Color)
    --    GUI.StaticSetFontSize(value, UIDefine.FontSizeM)
    --end
    --local tip = GUI.CreateStatic(src, "tip", "", 15, 0, 250, 30)
    --GUI.SetColor(tip, UIDefine.Yellow2Color)
    --GUI.StaticSetFontSize(tip, UIDefine.FontSizeM)
    --UILayout.SetSameAnchorAndPivot(tip, UILayout.TopLeft)
    --local t = {
    --    "ArtificeAttr"
    --    -- "RecastAttr"
    --}
    --local px = {
    --    ArtificeAttr = 190,
    --    RecastAttr = -150
    --}
    --
    --for j = 1, #t do
    --    local bg = GUI.ImageCreate(equipPage, t[j], "1801100030", px[t[j]], -190, false, 300, 260)
    --    EquipUI.guidt.BindName(bg, t[j])
    --    UILayout.SetSameAnchorAndPivot(bg, UILayout.TopLeft)
    --    local src = GUI.ScrollListCreate(bg, "src", 15, 175, 300, 70, false, UIAroundPivot.TopLeft, UIAnchor.TopLeft)
    --    local itemIcon = GUI.ItemCtrlCreate(bg, "itemIcon", UIDefine.ItemIconBg2[1], 18, 53)
    --    local name = GUI.CreateStatic(bg, "name", "名字", 115, 60, 150, 30)
    --    GUI.SetColor(name, UIDefine.BrownColor)
    --    GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
    --    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)
    --    local enhanceLv = GUI.CreateStatic(bg, "enhanceLv", " ", 115, 60, 150, 30)
    --    GUI.SetColor(enhanceLv, UIDefine.EnhanceBlueColor)
    --    GUI.StaticSetFontSize(enhanceLv, UIDefine.FontSizeL)
    --    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)
    --    local level = GUI.CreateStatic(bg, "lv", "10级", 115, 100, 100, 30)
    --    GUI.SetColor(level, UIDefine.Yellow2Color)
    --    GUI.StaticSetFontSize(level, UIDefine.FontSizeM)
    --    local equipType = GUI.CreateStatic(bg, "equipType", "武器", 175, 100, 100, 30)
    --    GUI.SetColor(equipType, UIDefine.Yellow2Color)
    --    GUI.StaticSetFontSize(equipType, UIDefine.FontSizeM)
    --    local rulebg = GUI.ImageCreate(bg, "rulebg", "1801100040", 15, 145)
    --    local rule = GUI.CreateStatic(rulebg, "rule", "属性加成", 2, 0, 100, 30)
    --    GUI.SetColor(rule, UIDefine.WhiteColor)
    --    GUI.StaticSetFontSize(rule, UIDefine.FontSizeM)
    --
    --    --郑
    --    local hintBtn_right = GUI.ButtonCreate(bg, "hintBtn_right", "1800702030", 250, 5, Transition.ColorTint, "", 30, 30, false)
    --    --
    --
    --    UILayout.SetSameAnchorAndPivot(src, UILayout.Top)
    --    if t[j] == "RecastAttr" then
    --        GUI.SetVisible(bg, false)
    --    end
    --    --郑 2021/5/12
    --    local title = GUI.CreateStatic(bg, "title", "强化打造极品预览", 20, 5, 210, 30)
    --    --
    --    local num = nil
    --    if t[j] == "ArtificeAttr" then
    --        -- num = GUI.CreateStatic(bg, "lock", "锁定", 115, -110, 50, 30)
    --        guidt.BindName(bg, "attrbg")
    --        -- guidt.BindName(num, "num")
    --        guidt.BindName(title, "title")
    --    end
    --    local txtt = {title, num}
    --    for j = 1, #txtt do
    --        GUI.SetColor(txtt[j], UIDefine.BrownColor)
    --        GUI.StaticSetFontSize(txtt[j], UIDefine.FontSizeL)
    --    end
    --    for i = 1, attrMax do
    --        local txt = GUI.CreateStatic(src, "attText" .. i, "属性1", 17, 0, 100, 30)
    --        GUI.SetColor(txt, UIDefine.BrownColor)
    --        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    --        UILayout.SetSameAnchorAndPivot(txt, UILayout.TopLeft)
    --        local num = GUI.CreateStatic(txt, "value", "10", 112, 0, 166, 30)
    --        GUI.SetColor(num, UIDefine.Green8Color)
    --        GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
    --        if j == 1 then
    --            -- local cb =
    --            --     GUI.CheckBoxCreate(
    --            --     tmpbg,
    --            --     "attr",
    --            --     "1801207120",
    --            --     "1801207130",
    --            --     122,
    --            --     0,
    --            --     Transition.ColorTint,
    --            --     false,
    --            --     22,
    --            --     22
    --            -- )
    --            -- guidt.BindName(cb, "attrLock" .. i)
    --            guidt.BindName(txt, "attrname" .. i)
    --            guidt.BindName(num, "attrnum" .. i)
    --        end
    --    end
    --    local tip = GUI.CreateStatic(src, "tip", "", 15, 0, 250, 30)
    --    GUI.SetColor(tip, UIDefine.Yellow2Color)
    --    GUI.StaticSetFontSize(tip, UIDefine.FontSizeM)
    --    UILayout.SetSameAnchorAndPivot(tip, UILayout.TopLeft)
    --
    --end

    -- local effectText = GUI.CreateStatic(normalBg, "effectText", "特效：", 15, 95, 270, 60)
    -- GUI.SetColor(effectText, UIDefine.BrownColor)
    -- GUI.StaticSetFontSize(effectText, UIDefine.FontSizeM)
    -- GUI.SetAnchor(effectText, UIAnchor.Left)
    -- GUI.SetPivot(effectText, UIAroundPivot.Left)
    -- GUI.StaticSetAlignment(effectText, TextAnchor.UpperLeft)

    -- local hintBtn =
    --     GUI.ButtonCreate(normalBg, "hintBtn", "1800702030", 115, -108, Transition.ColorTint, "", 30, 30, false)
    -- GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "EquipProduceUI", "OnNormalHintBtnClick")

    -- local posX = {-50, 60, 170, 340}
    --
    --[[
    local intensifyBg = GUI.ImageCreate(EquipProduceUI, "intensifyBg", "1801100030", 340, -60, false, 300, 260)
    local title = GUI.CreateStatic(intensifyBg, "title", "强化打造极品预览", -40, -108, 200, 30)
    GUI.SetColor(title, UIDefine.BrownColor)
    GUI.StaticSetFontSize(title, UIDefine.FontSizeL)
    local itemIcon = GUI.ItemCtrlCreate(intensifyBg, "itemIcon", UIDefine.ItemIconBg2[1], -90, -35)

    local name = GUI.CreateStatic(intensifyBg, "name", "名字", 115, -55, 150, 30)
    GUI.SetColor(name, UIDefine.BrownColor)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
    GUI.SetAnchor(name, UIAnchor.Left)
    GUI.SetPivot(name, UIAroundPivot.Left)
    local level = GUI.CreateStatic(intensifyBg, "level", "10级", 115, -20, 100, 30)
    GUI.SetColor(level, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(level, UIDefine.FontSizeM)
    GUI.SetAnchor(level, UIAnchor.Left)
    GUI.SetPivot(level, UIAroundPivot.Left)
    local equipType = GUI.CreateStatic(intensifyBg, "equipType", "武器", 175, -20, 100, 30)
    GUI.SetColor(equipType, UIDefine.Yellow2Color)
    GUI.StaticSetFontSize(equipType, UIDefine.FontSizeM)
    GUI.SetAnchor(equipType, UIAnchor.Left)
    GUI.SetPivot(equipType, UIAroundPivot.Left)
    local att1Text = GUI.CreateStatic(intensifyBg, "att1Text", "属性1", 15, 25, 100, 30)
    GUI.SetColor(att1Text, UIDefine.BrownColor)
    GUI.StaticSetFontSize(att1Text, UIDefine.FontSizeM)
    GUI.SetAnchor(att1Text, UIAnchor.Left)
    GUI.SetPivot(att1Text, UIAroundPivot.Left)
    local value = GUI.CreateStatic(att1Text, "value", "10", 20, 0, 100, 30)
    GUI.SetColor(value, UIDefine.GreenColor)
    GUI.StaticSetFontSize(value, 22)
    GUI.SetAnchor(value, UIAnchor.Right)
    GUI.SetPivot(value, UIAroundPivot.Left)
    local att2Text = GUI.CreateStatic(intensifyBg, "att2Text", "属性2", 15, 50, 100, 30)
    GUI.SetColor(att2Text, UIDefine.BrownColor)
    GUI.StaticSetFontSize(att2Text, UIDefine.FontSizeM)
    GUI.SetAnchor(att2Text, UIAnchor.Left)
    GUI.SetPivot(att2Text, UIAroundPivot.Left)
    local value = GUI.CreateStatic(att2Text, "value", "10", 20, 0, 100, 30)
    GUI.SetColor(value, UIDefine.GreenColor)
    GUI.StaticSetFontSize(value, UIDefine.FontSizeM)
    GUI.SetAnchor(value, UIAnchor.Right)
    GUI.SetPivot(value, UIAroundPivot.Left)
    local effectText = GUI.CreateStatic(intensifyBg, "effectText", "特效：", 15, 95, 270, 60)
    GUI.SetColor(effectText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(effectText, UIDefine.FontSizeM)
    GUI.SetAnchor(effectText, UIAnchor.Left)
    GUI.SetPivot(effectText, UIAroundPivot.Left)
    GUI.StaticSetAlignment(effectText, TextAnchor.UpperLeft)

    local hintBtn =
        GUI.ButtonCreate(intensifyBg, "hintBtn", "1800702030", 115, -108, Transition.ColorTint, "", 30, 30, false)
    GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "EquipProduceUI", "OnIntensifyHintBtnClick")
]]
    local posX = {
        -245,
        -50,
        145,
        340
    }
    for i = 1, consumeMax do
        local consumeItem = ItemIcon.Create(EquipProduce, "consumeItem" .. i, posX[i], 155)
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
    --[[
    local isIntensifyBtn =
        GUI.ButtonCreate(
        EquipProduceUI,
        "isIntensifyBtn",
        "1800607151",
        410,
        130,
        Transition.ColorTint,
        "",
        40,
        40,
        false
    )
    GUI.RegisterUIEvent(isIntensifyBtn, UCE.PointerClick, "EquipProduceUI", "OnIsIntensifyBtnClick")
]]
    local levelText = GUI.CreateStatic(EquipProduce, "levelText", "装备等级", -465, -245, 100, 30)
    GUI.SetColor(levelText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(levelText, UIDefine.FontSizeL)

    local levelSelectBtn =
        GUI.ButtonCreate(
        EquipProduce,
        "levelSelectBtn",
        "1801102010",
        -315,
        -245,
        Transition.ColorTint,
        "",
        175,
        40,
        false
    )
    local arrow = GUI.ImageCreate(levelSelectBtn, "arrow", "1800707070", 60, 0)

    GUI.RegisterUIEvent(levelSelectBtn, UCE.PointerClick, "EquipProduceUI", "OnlevelSelectBtnClick")

    local currentLevel = GUI.CreateStatic(levelSelectBtn, "currentLevel", "1级", -10, 0, 100, 30)
    GUI.SetColor(currentLevel, UIDefine.BrownColor)
    GUI.StaticSetFontSize(currentLevel, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(currentLevel, TextAnchor.MiddleCenter)
    guidt.BindName(currentLevel, "currentLevel")
    local equipUI = GUI.GetWnd("EquipUI")
    local levelSelectCover =
        GUI.ImageCreate(
        EquipUI.guidt.GetUI("panelBg"),
        "levelSelectCover",
        "1800400220",
        0,
        -66,
        false,
        GUI.GetWidth(equipUI),
        GUI.GetHeight(equipUI)
    )
    UILayout.SetSameAnchorAndPivot(levelSelectCover, UILayout.Top)
    levelSelectCover:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(levelSelectCover, true)
    GUI.RegisterUIEvent(levelSelectCover, UCE.PointerClick, "EquipProduceUI", "OnlevelSelectCoverClick")
    guidt.BindName(levelSelectCover, "levelSelectCover")
    local border = GUI.ImageCreate(levelSelectCover, "border", "1800400290", -315, 110 + 66, false, 188, 40 * 8 + 10)
    UILayout.SetSameAnchorAndPivot(border, UILayout.Top)

    local levelScr =
        GUI.LoopScrollRectCreate(
        levelSelectCover,
        "levelScr",
        -315,
        110 + 71,
        188,
        40 * 8,
        "EquipProduceUI",
        "CreatLevelItemPool",
        "EquipProduceUI",
        "RefreshLevelScr",
        0,
        false,
        Vector2.New(175, 40),
        1,
        UIAroundPivot.Top,
        UIAnchor.Top
    )
    guidt.BindName(levelScr, "levelScr")
    GUI.SetAnchor(levelScr, UIAnchor.Top)
    GUI.SetPivot(levelScr, UIAroundPivot.Top)

    GUI.SetVisible(levelSelectCover, false)

    local consumeText = GUI.CreateStatic(EquipProduce, "consumeText", "消耗", -180, 265, 100, 30)
    GUI.SetColor(consumeText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(consumeText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleCenter)
    guidt.BindName(consumeText, "consumeText")

    local consumeBg = GUI.ImageCreate(EquipProduce, "consumeBg", "1800700010", -50, 266, false, 180, 35)
    local coin = GUI.ImageCreate(consumeBg, "coin", "1800408280", -74, -1, false, 36, 36)
    guidt.BindName(consumeBg, "consumeBg")
    local num = GUI.CreateStatic(consumeBg, "num", "100", 0, 0, 160, 30)
    GUI.SetColor(num, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(num, UIDefine.FontSizeM)
    GUI.SetAnchor(num, UIAnchor.Center)
    GUI.SetPivot(num, UIAroundPivot.Center)
    GUI.StaticSetAlignment(num, TextAnchor.MiddleCenter)

    local vpText = GUI.CreateStatic(EquipProduce, "vpText", "活力", 110, 265, 100, 30)
    GUI.SetColor(vpText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(vpText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(vpText, TextAnchor.MiddleCenter)
    guidt.BindName(vpText, "vpText")
    local vpBg = GUI.ImageCreate(EquipProduce, "vpBg", "1800700010", 240, 266, false, 180, 35)
    local vpNum = GUI.CreateStatic(vpBg, "vpNum", "10/1000", 0, -2, 160, 30)
    GUI.SetColor(vpNum, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(vpNum, UIDefine.FontSizeM)
    GUI.SetAnchor(vpNum, UIAnchor.Center)
    GUI.SetPivot(vpNum, UIAroundPivot.Center)
    GUI.StaticSetAlignment(vpNum, TextAnchor.MiddleCenter)
    guidt.BindName(vpBg, "vpBg")
    guidt.BindName(vpNum, "vpNum")

    local enhanceBtn = GUI.ButtonCreate(EquipProduce, "enhanceBtn", "1800002060", 436 , 265, Transition.ColorTint, "打造", 160, 50, false)
    guidt.BindName(enhanceBtn, "enhanceBtn")
    GUI.SetEventCD(enhanceBtn, UCE.PointerClick, 0.5)
    GUI.ButtonSetTextColor(enhanceBtn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(enhanceBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetOutLineArgs(enhanceBtn, true, UIDefine.OutLine_BrownColor, UIDefine.OutLineDistance)
end
function EquipProduceUI.OnlevelSelectBtnClick()
    local levelScr = guidt.GetUI("levelScr")
    local levelSelectCover = guidt.GetUI("levelSelectCover")
    if levelSelectCover ~= nil then
        GUI.SetVisible(levelSelectCover, true)
    end
    local cnt = #data.Classify
    local tCntLen = math.min(480, 40 * cnt)
    if levelScr ~= nil then
        GUI.SetHeight(levelScr, tCntLen)
        GUI.SetHeight(GUI.GetChild(levelSelectCover, "border"), tCntLen + 10)
        GUI.LoopScrollRectSetTotalCount(levelScr, 0)
        GUI.LoopScrollRectSetTotalCount(levelScr, cnt)
        GUI.LoopScrollRectRefreshCells(levelScr)
    end
end
function EquipProduceUI.OnlevelSelectCoverClick()
    local levelSelectCover = guidt.GetUI("levelSelectCover")
    if levelSelectCover ~= nil then
        GUI.SetVisible(levelSelectCover, false)
    end
end
function EquipProduceUI.CreatLevelItemPool()
    local scroll = guidt.GetUI("levelScr")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scroll)
    local level =
        GUI.ButtonCreate(scroll, tostring(curCount), "1801102010", 0, 0, Transition.ColorTint, "级", 175, 40, false)
    GUI.ButtonSetTextColor(level, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(level, UIDefine.FontSizeM)
    GUI.SetAnchor(level, UIAnchor.Top)
    GUI.RegisterUIEvent(level, UCE.PointerClick, "EquipProduceUI", "OnLevelItemClick")

    local selected = GUI.ImageCreate(level, "selected", "1800600160", 0, 0, false, 180, 42)
    return level
end
function EquipProduceUI.OnLevelItemClick(guid)
    local item = GUI.GetByGuid(guid)
    -- 打造切换等级时重新选中第一项武器
    data.index = 1
    data.lvIndex = GUI.ButtonGetIndex(item) + 1
    data.lv = data.Classify[data.lvIndex]
    EquipProduceUI.OnlevelSelectCoverClick()
    EquipProduceUI.GetLvData()
end

function EquipProduceUI.RefreshLevelScr(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local lv = GUI.GetByGuid(guid)
    if lv == nil then
        return
    end
    GUI.ButtonSetText(lv, data.Classify[index + 1])

    local selected = GUI.GetChild(lv, "selected", false)
    if selected ~= nil then
        if data.lvIndex == index + 1 then
            test(data.lvIndex)
            GUI.SetVisible(selected, true)
        else
            GUI.SetVisible(selected, false)
        end
    end
    -- 小红点
    local isShowRedPoint = false
    if GlobalProcessing.EquipProduceUI then
        local levelRedPoint = GlobalProcessing.EquipProduceUI.CheckRedPoint_TB[data.Classify[index + 1]]
        for key, itemValue in pairs(levelRedPoint) do
            if itemValue.Item.isEnough == "true" then
                isShowRedPoint = true
            end
        end
    end
    GlobalProcessing.SetRetPoint(lv,isShowRedPoint)
end
--和左侧装备栏index绑定
function EquipProduceUI.RefreshLeftItem(guid, index)
    test("EquipProduceUI.RefreshLeftItem")
    local item = GUI.GetByGuid(guid)
    if item == nil then
        test("EquipScrollItem刷新道具错误")
    end
    local normal = EquipProduceUI.GetNormalInfo(index)
    if normal == nil then
        test("数据错误")
        return
    end
    --test("AAAA", normal.result_basicItem[1].id, normal.result_basicItem[1].keyname)

    EquipScrollItem.RefreshLeftItemByItemIdEx(guid, normal.result_basicItem[1].id, normal.result_basicItem[1].keyname)
    
    if index == data.index then
        GUI.CheckBoxExSetCheck(item, true)
        data.indexGuid = guid
    else
        GUI.CheckBoxExSetCheck(item, false)
    end

    -- 小红点
    local thisNormal = EquipProduceUI.GetNormalInfo(index)
    local isShowRedPoint = false
    if GlobalProcessing.EquipProduceUI then
        local thisLevelItem = GlobalProcessing.EquipProduceUI.CheckRedPoint_TB[data.lv]
        for key, itemvalue in pairs(thisLevelItem) do
            if itemvalue.Item.Index == thisNormal.index then
                isShowRedPoint = itemvalue.Item.isEnough == "true"
            end
        end
    end
    GlobalProcessing.SetRetPoint(item,isShowRedPoint)
end
function EquipProduceUI.OnLeftItemClick(guid)
    local item = GUI.GetByGuid(guid)
    GUI.CheckBoxExSetCheck(item, true)
    data.index = GUI.CheckBoxExGetIndex(item) + 1
    if guid ~= data.indexGuid then
        GUI.CheckBoxExSetCheck(GUI.GetByGuid(data.indexGuid), false)
        data.indexGuid = guid
        -- data.checkOn = false
    end
    EquipProduceUI.GetDesData()
    -- EquipProduceUI.RefreshNormalProduce()
    EquipProduceUI.RefreshConsumeItem()
end

---@public
---@param itemid number
---@param itemKeyName string
---@param eqiupItemTable eqiupItem
---@return number
function EquipProduceUI.RefreshResultInfo(bg, itemid, itemKeyName, eqiupItemTable)
    test("EquipProduceUI.RefreshResultInfo")
    local ui = guidt.GetUI("EquipProduce")
    local normalItem = GUI.GetChild(ui,"normalItem")
    local bg = bg or normalItem
    if bg == nil then
        test("RefreshResultInfoe刷新道具错误")
    end
    --这个是预览页面的内容
    local icon = GUI.GetChild(bg, "itemIcon", false)
    local name = GUI.GetChild(bg, "name", false)
    local enhanceLv = GUI.GetChild(bg, "enhanceLv", false)
    local lv = GUI.GetChild(bg, "lv", false)
    local equipType = GUI.GetChild(bg, "equipType", false)
    local rulebg = GUI.GetChild(bg, "rulebg")
    local rule = GUI.GetChild(rulebg, "rule")
    GUI.StaticSetText(rule, "属性加成")
    local uit = {icon, name, lv, equipType}
    for i = 1, #uit do
        GUI.SetVisible(uit[i], true)
    end
    local iteminfo = nil
    local nameTxt, lvTxt, equipTypeTxt = " "
    local enhanceLvTxt = " "
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

        if eqiupItemTable.turnBorn > 0 then
            lvTxt = tostring(eqiupItemTable.turnBorn) .. "转" .. tostring(eqiupItemTable.lv) .. "级"
        else
            lvTxt = tostring(eqiupItemTable.lv) .. "级"
        end
        equipTypeTxt = eqiupItemTable.showType
    elseif iteminfo ~= nil and iteminfo.Id > 0 then
        ItemIcon.BindItemId(icon, iteminfo.Id)
        nameTxt = iteminfo.Name
        lvTxt = tostring(iteminfo.Level) .. "级"
        equipTypeTxt = iteminfo.ShowType
    else
        ItemIcon.BindItemId(icon, nil)
    end
    GUI.StaticSetText(name, nameTxt)
    local w = GUI.StaticGetLabelPreferWidth(name)
    GUI.SetWidth(name, w)
    GUI.SetPositionX(enhanceLv, GUI.GetPositionX(name) + w + 5)
    GUI.StaticSetText(lv, lvTxt)
    GUI.SetColor(lv, UIDefine.EnhanceBlueColor)
    w = GUI.StaticGetLabelPreferWidth(lv)
    GUI.SetWidth(lv, w)
    GUI.SetPositionX(equipType, GUI.GetPositionX(lv) + w + 5)
    GUI.StaticSetText(equipType, equipTypeTxt)
    if maxEnhance then
        GUI.SetColor(equipType, UIDefine.EnhanceBlueColor)
    else
        GUI.SetColor(equipType, UIDefine.Yellow2Color)
    end
    if equipTypeTxt ~= nil and string.find(equipTypeTxt,"无级别") then
        GUI.SetVisible(lv,false)
        GUI.SetPositionX(equipType,GUI.GetPositionX(lv))
    end
    GUI.StaticSetText(enhanceLv, enhanceLvTxt)
    local src = GUI.GetChild(bg, "src", false)
    GUI.ScrollRectSetNormalizedPosition(src, UIDefine.Vector2One)
    local y = 30
    local previewItem = nil
    previewItem = itemKeyName ~= nil and data.des[itemKeyName] or nil
    if previewItem and previewItem.attr and #previewItem.attr > attrMax then
        attrMax = #previewItem.attr
    end
    for i = 1, attrMax do
        local att = GUI.GetChild(src, "attText" .. i, false)
        local attv = GUI.GetChild(att, "value", false)
        if att == nil then
            local tip = GUI.GetChild(src, "tip", false)
            GUI.Destroy(tip)
            local attText = GUI.CreateStatic(src, "attText" .. i, "属性1", 17, 0, 100, 30)
            GUI.SetColor(attText, UIDefine.BrownColor)
            GUI.StaticSetFontSize(attText, UIDefine.FontSizeM)
            UILayout.SetSameAnchorAndPivot(attText, UILayout.TopLeft)
            local value = GUI.CreateStatic(attText, "value", "10", 112, 0, 166, 30)
            GUI.SetColor(value, UIDefine.Green8Color)
            GUI.StaticSetFontSize(value, UIDefine.FontSizeM)
            att = attText
            attv = value
        end
        if previewItem == nil or previewItem.attr[i] == nil then
            GUI.SetVisible(att, false)
        else
            local tmp = previewItem.attr[i]
            GUI.SetVisible(att, true)
            GUI.StaticSetText(att, tmp.ChinaName)
            GUI.StaticSetText(attv, tmp.PreviewMin .. " - " .. tmp.PreviewMax)
        end
    end
    local tip = GUI.GetChild(src, "tip", false)
    if tip == nil then
        tip = GUI.CreateStatic(src, "tip", "", 15, 0, 250, 30)
        GUI.SetColor(tip, UIDefine.Yellow2Color)
        GUI.StaticSetFontSize(tip, UIDefine.FontSizeM)
        UILayout.SetSameAnchorAndPivot(tip, UILayout.TopLeft)
    end
    if previewItem then
        GUI.SetVisible(tip, true)
        GUI.StaticSetText(tip, previewItem.tips)
        GUI.StaticSetLabelType(tip, LabelType.ConstW)
        GUI.StaticSetAutoSize(tip, true)
        GUI.SetPositionY(tip, 146 + y)
    else
        GUI.SetVisible(tip, false)
    end
    return y
end

-- 刷新普通打造结果
function EquipProduceUI.RefreshNormalProduce()
    test("EquipProduceUI.RefreshNormalProduce")
    local y = 0
    local e1, e2, e3 = EquipProduceUI.GetNormalEquipsInfo()
    local ui = guidt.GetUI("EquipProduce")
    local artificeItem = GUI.GetChild(ui,"artificeItem")
    if e1 ~= nil and e2 ~= nil and e3 ~= nil then
        y = EquipProduceUI.RefreshResultInfo(nil, e2.id, e2.keyname)
        y = EquipProduceUI.RefreshResultInfo(artificeItem, e3.id, e3.keyname)
    else
        y = EquipProduceUI.RefreshResultInfo(nil, nil, nil)
        y = EquipProduceUI.RefreshResultInfo(artificeItem, nil, nil)
    end
end
local _gt  = UILayout.NewGUIDUtilTable()
function EquipProduceUI.OnConsumeItemClick(guid)
    ---@type eqiupItem[]
    local normal = EquipProduceUI.GetNormalInfo()
    local itemTable = {}
    local exIndex = 0
    if normal then
        for i = 1, #normal.formula_basicItem do
            itemTable[i] = normal.formula_basicItem[i]
            exIndex = i + 1
        end
        if normal.formula_adderItem and normal.formula_adderItem[1] then
            itemTable[exIndex] = normal.formula_adderItem[1]
        end
    end
    for i = 1, consumeMax do
        local item = guidt.GetUI("consumeItem" .. i)
        if guid == GUI.GetGuid(item) then
            if itemTable[i] ~= nil then
               local itemtips =  Tips.CreateByItemId(itemTable[i].id, EquipUI.guidt.GetUI("equipPage"), "tips", 0, 0, 50)  --创造提示
               GUI.SetData(itemtips, "ItemId", tostring(itemTable[i].id))
               _gt.BindName(itemtips,"tips")
               local wayBtn = GUI.ButtonCreate(itemtips, "wayBtn", 1800402110, 0, -15, Transition.ColorTint, "获取途径", 150, 50, false);
                UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
                GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
                GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
                GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"EquipProduceUI","onClickEquilWayBtn")
                GUI.AddWhiteName(itemtips, GUI.GetGuid(wayBtn))
            end
        end
    end
end

--郑 2021\5\13
function EquipProduceUI.onClickEquilWayBtn()
    local tip = _gt.GetUI("tips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end
--

-- 刷新消耗道具
function EquipProduceUI.RefreshConsumeItem()
    local normal = EquipProduceUI.GetNormalInfo()
    local names = {
        "consumeBg",
        "consumeText"
    }
    local consumeBg = guidt.GetUI("consumeBg")
    local consumeText = guidt.GetUI("consumeText")
    local vpBg = guidt.GetUI("vpBg")
    local vp = GUI.GetChild(vpBg, "vpNum", false)
    if normal == nil then
        for i = 1, consumeMax do
            local item = guidt.GetUI("consumeItem" .. i)
            GUI.SetVisible(item, false)
        end
        GUI.StaticSetText(vp, "无道具")
        return
    end
    local vitality = normal.vitality
    local curVp = tostring(CL.GetAttr(RoleAttr.RoleAttrVp))
    GUI.StaticSetText(vp, curVp .. "/" .. vitality)
    if tonumber(curVp) < tonumber(vitality) then
        GUI.SetColor(vp, UIDefine.RedColor)
    else
        GUI.SetColor(vp, UIDefine.WhiteColor)
    end
    local consumeXPos = {
        {150},
        {
            50,
            250
        },
        {
            -55,
            45,
            300
        },
        {
            -105,
            -5,
            95,
            300
        }
    }
    ---@type eqiupItem[]
    local item = {}
    local exIndex = 0
    for i = 1, #normal.formula_basicItem do
        item[i] = normal.formula_basicItem[i]
        exIndex = i + 1
    end
    if normal.formula_adderItem and normal.formula_adderItem[1] then
        item[exIndex] = normal.formula_adderItem[1]
    end
    EquipProduceUI.RefreshConsumeItemEx(4, item, consumeXPos, exIndex, data.checkOn)
    if normal.consume.MoneyType ~= nil and normal.consume.MoneyVal ~= nil then
        test(" normal.consume." .. normal.consume.MoneyType .. ":" .. normal.consume.MoneyVal)
        GUI.SetVisible(consumeBg, true)
        GUI.SetVisible(consumeText, true)
        EquipProduceUI.RefreshConsumeCoin(UIDefine.GetMoneyEnum(normal.consume.MoneyType), normal.consume.MoneyVal)
    else
        EquipProduceUI.RefreshConsumeCoin(RoleAttr.RoleAttrIngot, 0)
    end
end
function EquipProduceUI.RefreshConsumeItemEx(consumeMax, items, consumeXPos, checkBoxIndex, checkIsOn)
    local consumeNum = 0
    local notnil = (items ~= nil)
    for i = 1, consumeMax do
        local item = guidt.GetUI("consumeItem" .. i)
        local info = items
        if notnil and i <= #info then
            consumeNum = consumeNum + 1
            GUI.SetVisible(item, true)
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
        end
    end
    for i = 1, consumeNum do
        local item = guidt.GetUI("consumeItem" .. i)
        --郑  修改前
        --GUI.SetPositionX(item, consumeXPos[consumeNum][i])
        --
        --郑  修改后
        if consumeNum == i then
            GUI.SetPositionX(item, consumeXPos[consumeNum][i])
        else
            GUI.SetPositionX(item, consumeXPos[consumeNum][i]+30)
        end
        --
    end
end

function EquipProduceUI.RefreshConsumeCoin(coin_type, coin_count)
    local bg = guidt.GetUI("consumeBg")
    local consumeText = guidt.GetUI("consumeText")
    GUI.SetVisible(bg, true)
    GUI.SetVisible(consumeText, true)

    local coin = GUI.GetChild(bg, "coin", false)
    local num = GUI.GetChild(bg, "num", false)
    test(tostring(CL.GetAttr(coin_type)))
    test(coin_count)
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

---@return  eqiupItem,eqiupItem,eqiupItem
function EquipProduceUI.GetNormalEquipsInfo(index)
    local normal = EquipProduceUI.GetNormalInfo(index)
    if normal then
        local e1 = normal.result_basicItem[1]
        local e2 = normal.result_basicItem[#normal.result_basicItem]
        local e3 = normal.result_adderItem[#normal.result_adderItem]
        return e1, e2, e3
    else
        return nil, nil, nil
    end
end
---@return  Normal
function EquipProduceUI.GetNormalInfo(index)
    if data.lv == nil or data.lv == "无" then
        return nil
    end
    if index == nil then
        index = data.index
    end
    -- test(data.lv)
    -- test(index)
    if data.Synthesis[data.lv] == nil then
        test("无数据", data.lv)
        return nil
    end
    return data.Synthesis[data.lv].Normal[index]
end
-- 打造成功
function EquipProduceUI.OnBuildSucces()
    GUI.OpenWnd("ShowEffectUI", 3000001739)
    -- ShowEffectUI.AddCloseCallback(EnhanceUI.OpenProduceEquipTips)
    ShowEffectUI.SetTimeOff(EquipProduceUI.serverData.Build_Time)
    EquipProduceUI.EquipContrast()
end

function EquipProduceUI.EquipContrast()
    EquipProduceUI.waitTime = EquipProduceUI.serverData.Build_Time
    if EquipProduceUI.waitTime ~= 0 then
        if EquipProduceUI.waitTimer == nil then
            EquipProduceUI.waitTimer = Timer.New(EquipProduceUI.CheckEquipAttr, EquipProduceUI.waitTime, -1)
        else
            EquipProduceUI.waitTimer:Stop()
            EquipProduceUI.waitTimer:Reset(EquipProduceUI.CheckEquipAttr, EquipProduceUI.waitTime, -1)
        end
        EquipProduceUI.waitTimer:Start()
    end
end

function EquipProduceUI.CheckEquipAttr()
    EquipProduceUI.waitTimer:Stop()
    local panelBg = EquipUI.guidt.GetUI("panelBg")
    local newData = LD.GetItemDataByGuid(EquipProduceUI.NewItemGuid)
    local newtips = Tips.CreateByItemData(newData, panelBg, "newtips", 500, 100, 50)
    UILayout.SetSameAnchorAndPivot(newtips, UILayout.TopLeft)
    local equipbtn = GUI.ButtonCreate(newtips, "equipbtn", "1800402110", 0 , -15, Transition.ColorTint, "装备", 160, 50, false)
    UILayout.SetSameAnchorAndPivot(equipbtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(equipbtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(equipbtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(equipbtn,UCE.PointerClick,"EquipProduceUI","OnEquilBtnClick")

    if EquipProduceUI.EquipItemGuid then
        local equipData = LD.GetItemDataByGuid(EquipProduceUI.EquipItemGuid,item_container_type.item_container_equip)
        local itemtips =  Tips.CreateByItemData(equipData, panelBg, "itemtips", 100, 100)
        UILayout.SetSameAnchorAndPivot(itemtips, UILayout.TopLeft)
        -- 添加特技特效相关到白名单
        local itemInfoScr = GUI.GetChildByPath(newtips,"InfoScr/InfoGroup")
        local itemInfoScr2 = GUI.GetChildByPath(itemtips,"InfoScr/InfoGroup")
        local itemInfoCount = GUI.GetChildCount(itemInfoScr)
        local itemInfoCount2 = GUI.GetChildCount(itemInfoScr2)
        for i = 0, itemInfoCount - 1, 1 do
            local label = GUI.GetChildByIndex(itemInfoScr,i)
            if GUI.GetData(label,"SpecialEffect") or GUI.GetData(label,"StuntID") then
                GUI.AddWhiteName(itemtips,GUI.GetGuid(label))
            end
        end
        for i = 0, itemInfoCount2 - 1, 1 do
            local label = GUI.GetChildByIndex(itemInfoScr2,i)
            if GUI.GetData(label,"SpecialEffect") or GUI.GetData(label,"StuntID") then
                GUI.AddWhiteName(newtips,GUI.GetGuid(label))
            end
        end
        -- 1800707290
        local LeftTopImg = GUI.ImageCreate(itemtips,"LeftTopImg","1800707290",0,0,true)
        local t = {}
        local T = {}
        LogicDefine.GetItemDynAttrDataByMark(newData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)
        LogicDefine.GetItemDynAttrDataByMark(equipData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, T)
        local InfoScr = GUI.GetChild(newtips,"InfoScr")
        if #t > 0 and #T > 0 then
            for i = 1, #t, 1 do
                --获得提升的图片
                local attrName = t[i].name
                local UpImg = nil
                for j = 1, #t, 1 do
                    local curUpImg = GUI.GetChild(InfoScr,"UpImg"..j)
                    local label = GUI.GetParentElement(curUpImg)
                    if string.find(GUI.StaticGetText(label),attrName) then
                        UpImg = curUpImg
                    end
                end
                local attrIndex = 0
                for j = 1, #T, 1 do
                    if t[i].name == T[j].name then
                        attrIndex = j
                    end
                end
                if attrIndex == 0 then
                    local value = tonumber(tostring(t[i].value))
                    if value > 0 then
                        GUI.ImageSetImageID(UpImg,"1800607060")
                        GUI.SetVisible(UpImg,true)
                    elseif value < 0 then
                        GUI.ImageSetImageID(UpImg,"1800607070")
                        GUI.SetVisible(UpImg,true)
                    else
                        GUI.SetVisible(UpImg,false)
                    end
                else
                    local value1 = tonumber(tostring(t[i].value))
                    local value2 = tonumber(tostring(T[attrIndex].value))
                    if value1 > value2 then
                        GUI.ImageSetImageID(UpImg,"1800607060")
                        GUI.SetVisible(UpImg,true)
                    elseif  value1 < value2 then
                        GUI.ImageSetImageID(UpImg,"1800607070")
                        GUI.SetVisible(UpImg,true)
                    elseif value1 == value2 then
                        GUI.SetVisible(UpImg,false)
                    end
                end
            end
        end
    else
        local t = {}
        LogicDefine.GetItemDynAttrDataByMark(newData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)
        local InfoScr = GUI.GetChild(newtips,"InfoScr")
        if #t > 0 then
            for i = 1, #t do
                --获得提升的图片
                local attrName = t[i].name
                local UpImg = nil
                for j = 1, #t, 1 do
                    local curUpImg = GUI.GetChild(InfoScr,"UpImg"..j)
                    local label = GUI.GetParentElement(curUpImg)
                    if string.find(GUI.StaticGetText(label),attrName) then
                        UpImg = curUpImg
                    end
                end
                local value = tonumber(tostring(t[i].value))
                if value > 0 then
                    GUI.ImageSetImageID(UpImg,"1800607060")
                    GUI.SetVisible(UpImg,true)
                elseif value < 0 then
                    GUI.ImageSetImageID(UpImg,"1800607070")
                    GUI.SetVisible(UpImg,true)
                else
                    GUI.SetVisible(UpImg,false)
                end
            end
        end
    end
    EquipProduceUI.EquipItemGuid = nil
    EquipProduceUI.NewItemGuid = nil
end
function EquipProduceUI.OnEquilBtnClick()
    local guid = EquipProduceUI.NewItem
    if QuickUseUI and QuickUseUI.itemGuidList and guid == QuickUseUI.itemGuidList[#QuickUseUI.itemGuidList] then
        QuickUseUI.OnUseBtnClick()
    else
        local dst = System.Enum.ToInt(item_container_type.item_container_equip)
        GlobalProcessing.PutOnEquip(guid, dst)
    end
end
--郑
function EquipProduceUI.OnhintBtn_left(guid)
    test("OnhintBtn_leftOnhintBtn_leftOnhintBtn_left")
    local txt = ""
    if Language and Language.EquipEnhancUTips_left then
        txt = Language.EquipEnhancUTips_left
    end
    test("txt"..txt)
    local ui = guidt.GetUI("EquipProduce")
    Tips.CreateHint(
        txt,
        ui,
        200,
        -100,
        UILayout.Center,
        500,
        70
    )
end
function EquipProduceUI.OnhintBtn_right(guid)
    test("OnhintBtn_rightOnhintBtn_rightOnhintBtn_right")
    local txt = ""
    if Language and Language.EquipEnhancUTips_right then
        txt = Language.EquipEnhancUTips_right
    end
    test("txt"..txt)
    local ui = guidt.GetUI("EquipProduce")
    Tips.CreateHint(
        txt,
        ui,
        350,
        -100,
        UILayout.Center,
        500,
        70
    )
end

-- function EquipProduceUI.RefreshItemCheckRedPoint()
--     test("EquipProduceUI.RefreshItemCheckRedPoint")
--     test("9999999999999999999999999999999999999999")
--     local produceItemList = {}
--     local moneyInfo = {}
--     local roleVP = CL.GetIntAttr(RoleAttr.RoleAttrVp)
--     if GlobalProcessing.EquipProduceUI.CheckRedPoint_TB then
--         for level, items in pairs(GlobalProcessing.EquipProduceUI.CheckRedPoint_TB) do
--             if type(items) ~= "string" then
--                 for key, itemValue in pairs(items) do
--                     local isShowRedPoint = true
--                     local MoneyType = itemValue.MoneyCost.MoneyType
--                     local MoneyVal = itemValue.MoneyCost.MoneyVal
--                     local Vitality = itemValue.Vitality
--                     for i = 1, #itemValue.ConsumeItem, 2 do
--                         local keyname = itemValue.ConsumeItem[i]
--                         local count = itemValue.ConsumeItem[i + 1]
--                         local itemCount = 0
--                         if produceItemList[keyname] == nil then
--                             local itemDB = DB.GetOnceItemByKey2(keyname);
--                             itemCount = LD.GetItemCountById(itemDB.Id)
--                             produceItemList[keyname] = itemCount
--                         else
--                             itemCount = produceItemList[keyname]
--                         end
--                         -- local itemDB = DB.GetOnceItemByKey2(keyname);
--                         -- local itemCount = LD.GetItemCountById(itemDB.Id)
--                         if count > itemCount then
--                             isShowRedPoint = false
--                             break
--                         end
--                     end
--                     if moneyInfo["MoneyType" .. MoneyType] == nil then
--                         moneyInfo["MoneyType" .. MoneyType] = {}
--                         local l, h = int64.longtonum2(CL.GetAttr(UIDefine.GetMoneyEnum(MoneyType)))
--                         moneyInfo["MoneyType" .. MoneyType][MoneyType] = l
--                     end
--                     local curnum = moneyInfo["MoneyType" .. MoneyType][MoneyType]
        
--                     if curnum < MoneyVal then
--                         isShowRedPoint = false
--                     end

--                     if roleVP < Vitality then
--                         isShowRedPoint = false
--                     end
--                     itemValue.Item.isEnough = tostring(isShowRedPoint)
--                 end
--             end
--         end
--     end
-- end

function EquipProduceUI.CheckRedPoint()
    -- test("EquipProduceUI.CheckRedPoint")
    -- test("-------------------------")
    -- local inspect = require("inspect")
    -- print(inspect(GlobalProcessing.EquipProduceUI.CheckRedPoint_TB))
    local EquipProduce = guidt.GetUI("EquipProduce")
    local levelSelectBtn = GUI.GetChild(EquipProduce,"levelSelectBtn",false)
    -- local scroll = EquipUI.guidt.GetUI("itemScroll")
    -- local isShowRedPoint = false
    -- if GlobalProcessing.EquipProduceUI.CheckRedPoint_TB then
    --     for level, items in pairs(GlobalProcessing.EquipProduceUI.CheckRedPoint_TB) do
    --         if type(items) ~= "string" then
    --             for key, itemValue in pairs(items) do
    --                 if itemValue.Item.isEnough == "true" then
    --                     isShowRedPoint = true
    --                     break
    --                 end
    --             end
    --         end
    --         if isShowRedPoint then
    --             break
    --         end
    --     end
    -- end
    if EquipUI.tabIndex == 1 and EquipUI.tabSubIndex == 2 then
        -- EquipProduceUI.RefreshUI()
        GlobalProcessing.SetRetPoint(levelSelectBtn,GlobalProcessing.isEquipProduceShowRedPoint)
        EquipProduceUI.RefreshUI()
    end
end