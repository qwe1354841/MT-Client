-- 这是灵宝系统的UI
local SpiritualEquipUI = {}

_G.SpiritualEquipUI = SpiritualEquipUI
local _gt = UILayout.NewGUIDUtilTable()

---------------------------------缓存需要的全局变量Start------------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
---------------------------------缓存需要的全局变量End-------------------------------

-- 颜色
local colorDark = Color.New(102/255, 47/255, 22/255, 255/255)
local colorOutline = Color.New(175/255, 96/255, 19/255, 255/255)
local ColorType_FontColor1 = Color.New(172 / 255, 117 / 255, 39 / 255)
local ColorType_FontColor2 = Color.New(102 / 255, 47 / 255, 22 / 255)
local ColorType_Red = Color.New(255 / 255, 0 / 255, 0 / 255, 1)
local ColorType_Green = Color.New(0 / 255, 118 / 255, 51 / 255, 1)
local ColorType_White = Color.New(255 / 255, 255 / 255, 255 / 255)
local colorTextGray = Color.New(146 / 255, 146 / 255, 146 / 255)

local LabelList={
    {"佩戴","wearPageTog","OnWearClick","wearPage","CreateWearPage"},
    {"修炼","practicePageTog","OnPracticeClick","practicePage","CreatePracticePage"},
    {"五行","fiveElementsPageTog","OnFiveElementsClick","fiveElementsPage","CreateFiveElementsPage"},
    {"炼化","artificePageTog","OnArtificeClick","artificePage","CreateArtificePage"},
}

local pageNum = {
    wearPage = 1,
    practicePage = 2,
    fiveElementsPage = 3,
    artificePage = 4,
}
local nowPage = 4
local practiceAddExpBtnClick = 0
--@newinter SpiritualEquip.Reset(player)
local SelectList = nil
local SelectListGuid = nil
local BagSelectIndex = nil
local Bag = item_container_type.item_container_lingbao_bag  -- 灵宝背包
local EquipBag = item_container_type.item_container_lingbag_equip   -- 玩家身上装备的灵宝
local BagSubType = 1
local BagData = {
    [1] = {},
    [2] = {},
}
local wuXin = {
    [1] = {"Jin" , "金", "亢金位", "1900000740"},
    [2] = {"Mu"  , "木", "灵木位", "1900000710"},
    [3] = {"Shui", "水", "玄水位", "1900000720"},
    [4] = {"Huo" , "火", "烈火位", "1900000730"},
    [5] = {"Tu"  , "土", "黄土位", "1900000750"},
    [6] = {"WuXing", "五行", "五行阵", "1900000670"},
}
local yinYangIcon = {
    ["yinIcon"] = "1901101030",
    ["yangIcon"] = "1901101020",
}
local yinYangFF = {
    [5] = {"太阳",  1, "1901101040"},
    [3] = {"阳明",  2, "1901101050"},
    [1] = {"少阳",  3, "1901101060"},
    [-1] = {"少阴", 4, "1901101070"},
    [-3] = {"厥阴", 5, "1901101080"},
    [-5] = {"太阴", 6, "1901101090"},
}
local OwnLinQi = {} -- 拥有的灵气数据
local LastSelectLinQi = nil -- 上一个选中的灵气光标
local CultivationConfig = nil   -- 灵气修炼数据
local nowExp = 0    -- 当前拥有的经验
local Exp = 0       -- 点击灵气后使用会增加多少经验
local LingBaoTB = nil -- 灵宝数据
local LingBaoData = nil
local POrA = 2 -- 被动2主动1
local MaxRank = 10   -- 灵宝最大星级，再多摆不下了
local materialCost = nil -- 灵宝升级消耗材料

local nowEquipData = nil    -- 当前灵宝数据
local nowConfig = nil   -- 当前灵宝配置
local nowEquipAttConfig = nil -- 当前灵宝属性配置

local GeneralConfig = nil -- 两个配置文件
local EquipAttConfig = nil -- 两个配置文件
local sectConfig = nil  -- 玩家对应的门派灵宝
local ShopEquipAttConfig = nil  -- 炼化页面重新整理过的数据
local EquipLevelMax = nil   -- 灵宝最大等级
--local EquipReturn = nil     -- 灵宝分解返还比例
--local SpiritualEquipDisassembleTB = nil     -- 分解灵宝精华比例
local EquipSchoolEquipActivateLevel = {}    -- 激活门派灵宝所需的四个灵宝的等级 // 改为了星级
local TipsConfig = nil
local SelectItemGuid = nil
local SelectEquipGuid = nil
local Parameter = nil

local SelectFiveIndex = nil -- 五行页面选中的五行index
local NowPart = 1 -- 五行页面当前处在哪个位置 1：升灵 2：逆转

local SelectArtificeIconGuid = nil  -- 炼化页面选中的icon guid
local SelectArtificeIconIndex = nil -- 炼化页面选中的icon index
function SpiritualEquipUI.Main()

    local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
    local Level = GlobalProcessing.SpiritualEquipOpenLevel ~= nil and GlobalProcessing.SpiritualEquipOpenLevel or 40
    if CurLevel < Level then
        CL.SendNotify(NOTIFY.ShowBBMsg, "灵宝功能需要" .. tostring(Level) .. "级开启")
        return
    end

    _gt = UILayout.NewGUIDUtilTable()
    GameMain.AddListen("SpiritualEquipUI", "OnExitGame")
    local panel = GUI.WndCreateWnd("SpiritualEquipUI", "SpiritualEquipUI", 0, 0, eCanvasGroup.Normal)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "灵     宝", "SpiritualEquipUI", "OnExit")
    _gt.BindName(panelBg, "panelBg")

    --CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "GetInitializedData")
    nowPage = nil
    UILayout.CreateRightTab(LabelList,"SpiritualEquipUI")

    GeneralConfig = GlobalProcessing.SpiritualEquipGeneralConfig
    EquipAttConfig = GlobalProcessing.SpiritualEquipAttConfig
    EquipLevelMax = GlobalProcessing.SpiritualEquipLevelMax
    --EquipReturn = GlobalProcessing.SpiritualEquipReturn
    EquipSchoolEquipActivateLevel[1] = GlobalProcessing.SpiritualEquipSchoolEquipActivateLevel1
    EquipSchoolEquipActivateLevel[2] = GlobalProcessing.SpiritualEquipSchoolEquipActivateLevel2
    EquipSchoolEquipActivateLevel[3] = GlobalProcessing.SpiritualEquipSchoolEquipActivateLevel3
    EquipSchoolEquipActivateLevel[4] = GlobalProcessing.SpiritualEquipSchoolEquipActivateLevel4
    CultivationConfig = GlobalProcessing.SpiritualEquipCultivationConfig
    NowPart = 1
    --SpiritualEquipDisassembleTB = GlobalProcessing.SpiritualEquipDisassembleTB
    if GeneralConfig == nil or EquipAttConfig == nil then
        GUI.Destroy("SpiritualEquipUI")
        test("SpiritualEquipUI 数据为空")
        return
    end
    SelectFiveIndex = nil
    SpiritualEquipUI.ShopEquipAttConfigData()
end

function SpiritualEquipUI.OnShow(parameter)
    local wnd = GUI.GetWnd("SpiritualEquipUI")
    GUI.SetVisible(wnd,true)

    -- 先取消再监听
    CL.UnRegisterMessage(GM.AddNewItem, "SpiritualEquipUI", "ResetBag")
    CL.UnRegisterMessage(GM.UpdateItem, "SpiritualEquipUI", "ResetBag")
    CL.UnRegisterMessage(GM.RemoveItem, "SpiritualEquipUI", "ResetBag")
    CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold, SpiritualEquipUI.ResetAttrBindGold)
    -- 监听五行升级灵气
    CL.RegisterMessage(GM.AddNewItem, "SpiritualEquipUI", "ResetBag")
    CL.RegisterMessage(GM.UpdateItem, "SpiritualEquipUI", "ResetBag")
    CL.RegisterMessage(GM.RemoveItem, "SpiritualEquipUI", "ResetBag")
    CL.RegisterMessage(GM.RemoveItem, "SpiritualEquipUI", "ResetBag")
    -- 监听银币
    CL.RegisterAttr(RoleAttr.RoleAttrBindGold, SpiritualEquipUI.ResetAttrBindGold)

    Parameter = parameter

    local school = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrJob1)))
    for i, v in ipairs(EquipAttConfig) do
        if v["School"] == school then
            sectConfig = v
            break
        end
    end
    SelectList = nil
    SelectListGuid = nil

    if GeneralConfig == nil or EquipAttConfig == nil or EquipLevelMax == nil or EquipSchoolEquipActivateLevel == nil or CultivationConfig == nil then
        test("Config为空，重新加载")
        CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "ReLogin")
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "GetData")
end

function SpiritualEquipUI.DataRefresh()
    if Parameter ~= nil then
        local index1, index2 = UIDefine.GetParameterStr(Parameter)
        if index1 == "2" then
            SpiritualEquipUI.OnPracticeClick()
            return
        elseif index1 == "3" then
            SpiritualEquipUI.OnFiveElementsClick()
            if index2 == "1" then
                SpiritualEquipUI.OnCLevelUpBtnBtn()
            elseif index2 == "2" then
                SpiritualEquipUI.OnReverseBtnBtn()
            end
            return
        elseif index1 == "4" then
            SpiritualEquipUI.OnArtificeClick()
            return
        end
    else
        SpiritualEquipUI.OnWearClick()
    end
end

function SpiritualEquipUI.ResetLastSelectPage(index)
    UILayout.OnTabClick(index, LabelList)
    if nowPage == index then
        return false
    end
    SpiritualEquipUI.SetLastPageInvisible()
    nowPage = index
    return true
end

function SpiritualEquipUI.SetLastPageInvisible()
    if nowPage then
        local name = LabelList[nowPage][4]
        local lastPage = _gt.GetUI(name)
        if lastPage then
            GUI.SetVisible(lastPage,false)
        end
        nowPage = nil
    end
end

--- 穿戴页面点击
function SpiritualEquipUI.OnWearClick()
    --if not SpiritualEquipUI.ResetLastSelectPage(pageNum.wearPage) then
    --    return
    --end
    SpiritualEquipUI.ResetLastSelectPage(pageNum.wearPage)
    SpiritualEquipUI.InitData()
end

-- 初始化数据
function SpiritualEquipUI.InitData()
    SpiritualEquipUI.WearRefresh()
end

-- 穿戴页面刷新
function SpiritualEquipUI.WearRefresh()
    SpiritualEquipUI.RefreshBagData()
    SpiritualEquipUI.RefreshLinBaoData()
    local pageName = LabelList[pageNum.wearPage][4]
    local pageBg = _gt.GetUI(pageName)

    -- 其他页面的东西关一下
    local practicePageLeft = _gt.GetUI("practicePageLeft")
    if practicePageLeft then
        GUI.SetVisible(practicePageLeft, false)
    end
    if not pageBg then
        pageBg = SpiritualEquipUI.CreateWearPage(pageName)
    else
        GUI.SetVisible(pageBg,true)
    end
    SpiritualEquipUI.RefreshWearPage()
end

function SpiritualEquipUI.CreateWearPage(pageName)
    local panelBg = _gt.GetUI("panelBg")
    local mainPage = GUI.GroupCreate(panelBg, pageName,0,0,1197,639)
    _gt.BindName(mainPage, pageName)

    local scrBg = GUI.ImageCreate(mainPage, "scrBg", "1801720120", 110, 15, true)
    SetAnchorAndPivot(scrBg, UIAnchor.Left, UIAroundPivot.Left)
    _gt.BindName(scrBg, "scrBg")

    -- 中间门派灵宝
    local sectItem = GUI.ItemCtrlCreate(scrBg, "SpiritualEquipSect", "1800400330", 0, 0, 0, 0, true)
    SetAnchorAndPivot(sectItem, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(sectItem, "sectItem")
    GUI.ItemCtrlSetIndex(sectItem, 5)
    GUI.RegisterUIEvent(sectItem, UCE.PointerClick, "SpiritualEquipUI", "OnSectItemClick")
    local levelTxt = GUI.CreateStatic(sectItem, "levelTxt", "+30", -6, -7, 37, 40)
    SetAnchorAndPivot(levelTxt, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.StaticSetAlignment(levelTxt, TextAnchor.MiddleRight)
    GUI.StaticSetFontSize(levelTxt, 20)
    GUI.SetIsOutLine(levelTxt, true)
    GUI.SetOutLine_Color(levelTxt, colorOutline)
    GUI.SetOutLine_Distance(levelTxt,1)

    -- 五个被动灵宝
    local itemXY = {{0, -180}, {-170, -50}, {170, -50}, {-110, 140}, {110, 140}}
    for i = 0, 4 do
        local equipBg = GUI.ImageCreate(scrBg, "equipBg"..i, "1801720150", itemXY[i+1][1], itemXY[i+1][2], true)
        SetAnchorAndPivot(equipBg, UIAnchor.Center, UIAroundPivot.Center)
        local SpiritualEquip = GUI.ItemCtrlCreate(scrBg, "SpiritualEquip"..i, "1800400330", itemXY[i+1][1], itemXY[i+1][2], 0, 0, true)
        SetAnchorAndPivot(SpiritualEquip, UIAnchor.Center, UIAroundPivot.Center)
        _gt.BindName(SpiritualEquip, "SpiritualEquip"..i)
        GUI.ItemCtrlSetIndex(SpiritualEquip, i)
        GUI.RegisterUIEvent(SpiritualEquip, UCE.PointerClick, "SpiritualEquipUI", "OnSpiritualEquipItemClick")
        local levelTxt = GUI.CreateStatic(SpiritualEquip, "levelTxt", "+30", -6, -7, 37, 40)
        SetAnchorAndPivot(levelTxt, UIAnchor.TopRight, UIAroundPivot.TopRight)
        GUI.StaticSetAlignment(levelTxt, TextAnchor.MiddleRight)
        GUI.StaticSetFontSize(levelTxt, 20)
        GUI.SetIsOutLine(levelTxt, true)
        GUI.SetOutLine_Color(levelTxt, colorOutline)
        GUI.SetOutLine_Distance(levelTxt,1)
    end

    -- 灵宝加成字体上的图片
    local spiritualEquipAddArrTip = GUI.ButtonCreate(scrBg, "spiritualEquipAddArrTip", "1801720290", 200, 40, Transition.ColorTint);
    SetAnchorAndPivot(spiritualEquipAddArrTip, UIAnchor.Bottom, UIAroundPivot.Bottom)

    -- 灵宝加成字体图片
    local sp = GUI.ImageCreate(spiritualEquipAddArrTip, "sp", "1801720310", 0, -12)
    SetAnchorAndPivot(sp, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.RegisterUIEvent(spiritualEquipAddArrTip, UCE.PointerClick, "SpiritualEquipUI", "OnSpAddArrBtnClick")

    -- 右边背景
    local itemBg = GUI.ImageCreate(mainPage, "itemBg", "1800400010", -70, 20, false, 530, 500)
    SetAnchorAndPivot(itemBg, UIAnchor.Right, UIAroundPivot.Right)
    _gt.BindName(itemBg, "itemBg")

    -- 被动按钮
    local passiveBtn = GUI.CheckBoxExCreate(itemBg, "passiveBtn", "1800402030", "1800402032", 0, -40, true, 160, 40, false);
    SetAnchorAndPivot(passiveBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(passiveBtn, UCE.PointerClick, "SpiritualEquipUI", "OnPassiveBtn")
    _gt.BindName(passiveBtn, "passiveBtn")

    -- 按钮上的字
    local passiveTxt = GUI.CreateStatic(passiveBtn, "passiveTxt", "被动", 0, 0, 160, 40)
    SpiritualEquipUI.SetFont(passiveTxt)

    -- 主动按钮
    local activeBtn = GUI.CheckBoxExCreate(itemBg, "activeBtn", "1800402030", "1800402032", -160, -40, false, 160, 40, false);
    SetAnchorAndPivot(activeBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(activeBtn, UCE.PointerClick, "SpiritualEquipUI", "OnActiveBtn")
    _gt.BindName(activeBtn, "activeBtn")

    -- 按钮上的字
    local activeTxt = GUI.CreateStatic(activeBtn, "activeTxt", "主动", 0, 0, 160, 40)
    SpiritualEquipUI.SetFont(activeTxt)

    -- 穿戴灵宝页面右边物品框
    local itemScroll = GUI.LoopScrollRectCreate(
            itemBg,
            "itemScroll",
            10,
            0,
            510,
            480,
            "SpiritualEquipUI",
            "CreatItemScroll",
            "SpiritualEquipUI",
            "RefreshItemScroll",
            0,
            false,
            Vector2.New(80, 80),
            6,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    GUI.ScrollRectSetChildSpacing(itemScroll, Vector2.New(5, 5))
    _gt.BindName(itemScroll, "itemScroll")
end

function SpiritualEquipUI.CreatItemScroll()
    local itemScroll =  _gt.GetUI("itemScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemScroll)
    local ItemIconBg = ItemIcon.Create(itemScroll,"itemIcon" .. curCount,0,0)
    _gt.BindName(ItemIconBg,"ItemIconBg"..curCount)
    GUI.RegisterUIEvent(ItemIconBg, UCE.PointerClick, "SpiritualEquipUI", "OnWearItemClick")

    local levelTxt = GUI.CreateStatic(ItemIconBg, "levelTxt", "+30", 6, -7, 37, 40)
    SetAnchorAndPivot(levelTxt, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.StaticSetAlignment(levelTxt, TextAnchor.MiddleRight)
    GUI.StaticSetFontSize(levelTxt, 20)
    GUI.SetIsOutLine(levelTxt, true)
    GUI.SetOutLine_Color(levelTxt, colorOutline)
    GUI.SetOutLine_Distance(levelTxt,1)
    return ItemIconBg
end

function SpiritualEquipUI.RefreshItemScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])
    local itemIcon = GUI.GetByGuid(guid)
    local BagIndex = BagData[BagSubType][index+1]
    local levelTxt = GUI.GetChild(itemIcon, "levelTxt", false)
    --ItemIcon.BindIndexForBag(itemIcon, index, Bag)
    --GUI.SetData(itemIcon, "index", index)
    if BagIndex ~= nil then
        ItemIcon.BindIndexForBag(itemIcon, BagIndex, Bag)
        GUI.SetData(itemIcon, "index", BagIndex)
        local itemData = LD.GetItemDataByIndex(BagIndex, Bag)
        local level = itemData:GetIntCustomAttr("EquipLevel") ~= 0 and "+" .. itemData:GetIntCustomAttr("EquipLevel") or ""
        GUI.StaticSetText(levelTxt, level)
    else
        ItemIcon.SetEmpty(itemIcon)
        GUI.SetData(itemIcon, "index", "")
        GUI.StaticSetText(levelTxt, "")
    end
end

function SpiritualEquipUI.RefreshBagData()
    BagData = {
        [1] = {},
        [2] = {},
    }
    for i = 0, 71 do
        local itemData = LD.GetItemDataByIndex(i, Bag)
        if itemData then
            local showType = DB.GetOnceItemByKey1(itemData.id).ShowType
            if showType == "被动灵宝" then
                table.insert(BagData[1], i)
            elseif showType == "主动灵宝" then
                table.insert(BagData[2], i)
            end
        end
    end
end

function SpiritualEquipUI.RefreshWearPage()
    SpiritualEquipUI.UnSelect()
    SpiritualEquipUI.RefreshBagData()
    local itemScroll = _gt.GetUI("itemScroll")
    local capacity = LD.GetBagCapacity(Bag)
    GUI.LoopScrollRectSetTotalCount(itemScroll, capacity)
    GUI.LoopScrollRectRefreshCells(itemScroll)
    for i = 0, 5 do
        local equipItem = i ~= 5 and GUI.GetByGuid(_gt["SpiritualEquip" .. i]) or _gt.GetUI("sectItem")
        ItemIcon.BindIndexForBag(equipItem, i, EquipBag)
        local levelTxt = GUI.GetChild(equipItem, "levelTxt", false)
        local itemData = LD.GetItemDataByIndex(i, EquipBag)
        if itemData ~= nil then
            local level = itemData:GetIntCustomAttr("EquipLevel") ~= 0 and "+" .. itemData:GetIntCustomAttr("EquipLevel") or ""
            GUI.StaticSetText(levelTxt, level)
            GUI.ItemCtrlSetIconGray(equipItem, false)
        else
            GUI.StaticSetText(levelTxt, "")
            if i == 5 and sectConfig ~= nil then
                if sectConfig["Available"] ~= false then
                    GUI.ItemCtrlSetElementValue(equipItem, eItemIconElement.Icon, DB.GetOnceItemByKey1(sectConfig["Id"]).Icon)
                    GUI.ItemCtrlSetIconGray(equipItem, true)
                end
            end
        end
    end
end

-- 点击右边背包事件
function SpiritualEquipUI.OnWearItemClick(guid)
    local itemIcon = GUI.GetByGuid(guid)
    local index = GUI.GetData(itemIcon, "index")

    -- 点了空格子就不再继续了
    if index == nil or index == "" then
        SpiritualEquipUI.UnSelect()
        return
    end
    local itemData = LD.GetItemDataByIndex(index, Bag)
    if SelectItemGuid ~= nil then
        GUI.ItemCtrlUnSelect(GUI.GetByGuid(SelectItemGuid))
    end

    -- 重复点击了同一个item
    if SelectItemGuid == guid then
        SpiritualEquipUI.OnEquipBtnClick()
        SpiritualEquipUI.UnSelect()
        return
    end
    SelectItemGuid = guid
    BagSelectIndex = index
    GUI.ItemCtrlSelect(itemIcon);

    -- 创建tips
    local panelBg = _gt.GetUI("panelBg")
    SpiritualEquipUI.CreateItemTips(itemData, DB.GetOnceItemByKey1(itemData.id), panelBg, 2)
end

-- 点击装备中的灵宝
function SpiritualEquipUI.OnSpiritualEquipItemClick(guid)
    local equipItem = GUI.GetByGuid(guid)
    local index = GUI.ItemCtrlGetIndex(equipItem)
    local itemData = LD.GetItemDataByIndex(index, EquipBag)

    -- 点了空格子就不再继续了
    if itemData == nil then
        SpiritualEquipUI.UnSelect()
        return
    end

    -- 取消上一个的选中
    if SelectItemGuid ~= nil then
        GUI.ItemCtrlUnSelect(GUI.GetByGuid(SelectItemGuid))
    end
    -- 重复点击就卸下灵宝
    if SelectItemGuid == guid and index ~= 5 then
        SpiritualEquipUI.RemoveEquipItem()
        SpiritualEquipUI.UnSelect()
        return
    end

    -- 选中item
    GUI.ItemCtrlSelect(equipItem)
    SelectItemGuid = guid
    BagSelectIndex = index

    -- 创建tips
    local panelBg = _gt.GetUI("panelBg")
    local state = index == 5 and 3 or 1 -- 1是普通装备的灵宝，3是门派灵宝不能被卸下
    SpiritualEquipUI.CreateItemTips(itemData, DB.GetOnceItemByKey1(itemData.id), panelBg, state)
end

function SpiritualEquipUI.CreateItemTips(itemData, itemDB, panelBg, state)
    TipsConfig = nil
    for i, v in ipairs(EquipAttConfig) do
        if v["KeyName"] == itemDB.KeyName then
            TipsConfig = v
            break
        end
    end
    TipsConfig["itemData"] = itemData
    local tipsX = -170

    if state == 1 or state == 3 then
        tipsX = 150
    end
    local itemTips = GUI.ItemTipsCreate(panelBg, "itemTips", tipsX, 20,70)
    SetAnchorAndPivot(itemTips, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRemoveWhenClick(itemTips, true)

    --隐藏多余项
    local itemShowLevel = GUI.GetChild(itemTips, "itemShowLevel")
    if itemShowLevel then
        GUI.SetVisible(itemShowLevel,false)
    end
    local itemLimit = GUI.GetChild(itemTips, "itemLimit")
    if itemLimit then
        GUI.SetVisible(itemLimit, false)
    end

    -- icon与背景
    local itemIcon = GUI.TipsGetItemIcon(itemTips)
    --ItemIcon.BindItemData(itemIcon, itemData, true)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, itemDB.Icon)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, QualityRes[itemDB.Grade])
    -- 名字
    GUI.ItemTipsSetItemName(itemTips, itemDB.Name, UIDefine.GradeColor[itemDB.Grade])
    local name = GUI.ItemTipsGetItemName(itemTips)
    local w = GUI.StaticGetLabelPreferWidth(name)
    GUI.SetWidth(name, w)
    local level = itemData == nil and 0 or itemData:GetIntCustomAttr("Level")
    if level > 0 then
        local nameex = GUI.CreateStatic(name, "ex", "+" .. level, w + 10, 0, 100, 30)
        GUI.StaticSetFontSize(nameex, UIDefine.FontSizeM)
        UILayout.SetSameAnchorAndPivot(nameex, UILayout.TopLeft)
        GUI.SetColor(nameex, UIDefine.EnhanceBlueColor)
    end

    -- 类型
    GUI.ItemTipsSetItemType(itemTips, "类型：" .. itemDB.ShowType, UIDefine.YellowColor)

    local rank = itemData == nil and 1 or itemData:GetIntCustomAttr("EquipRank")
    local equipLevel = itemData == nil and 0 or itemData:GetIntCustomAttr("EquipLevel")
    -- 等级
    GUI.ItemTipsSetItemLevel(itemTips, "等级：" .. rank .. "阶" .. equipLevel  .. "级", UIDefine.YellowColor)
    Tips.DeleteItemShowLevel(itemTips)

    local rankMax = TipsConfig["RankMax"]
    for i = 0, rankMax - 1 do
        if i < rank then
            local star = GUI.ImageCreate(itemTips, "star"..i, "1801202190", i*31 + 26, 110, false, 30, 30)
            SetAnchorAndPivot(star, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        else
            local star = GUI.ImageCreate(itemTips, "star"..i, "1801202192", i*31 + 26, 110, false, 30, 30)
            SetAnchorAndPivot(star, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        end
    end
    -- 特效
    local str = SpiritualEquipUI.OnSkillTipNtf(TipsConfig, equipLevel)
    str = itemDB.ShowType == "被动灵宝" and "特效：<color=#fff2d0ff>" ..str or "特技：<color=#fff2d0ff>" ..str
    GUI.TipsAddLabel(itemTips, 20, str .. "</color>", UIDefine.Yellow3Color, true)
    GUI.TipsAddCutLine(itemTips)
    -- 基础属性
    local baseAtt = ""
    for i = 1, 6 do
        local five = wuXin[i][1]
        --local nowAttrId = TipsConfig["Att"][five.."Att"]
        --local type = TipsConfig["Att"][five.."Type"]
        local fiveUnLock = itemData == nil and 1 or itemData:GetIntCustomAttr(five.."Unlock")
        if i ~= 1 then
            baseAtt = baseAtt .. "\n"
        end
        if fiveUnLock == 0 then
            baseAtt = baseAtt .. "<color=#08AF00FF>" .. wuXin[i][3] .. "：</color>"
            baseAtt = baseAtt .. "<color=#FF0000ff>未激活</color>"
        else
            local fiveLevel = itemData == nil and 0 or itemData:GetIntCustomAttr(five.."Level")
            baseAtt = baseAtt .. "<color=#08AF00FF>" .. fiveLevel .. "级" .. wuXin[i][3] .. "：</color>"
            baseAtt = baseAtt .. SpiritualEquipUI.GetAtt(TipsConfig, fiveLevel, five)
        end
    end

    GUI.TipsAddLabel(itemTips, 20, "阵位基础属性：\n<color=#fff2d0ff>" .. baseAtt .. "</color>", UIDefine.Yellow3Color, true)
    GUI.TipsAddCutLine(itemTips)
    -- 两仪属性
    -- 阳两仪
    local actualInfo = ""
    actualInfo = actualInfo .. "<color=#08AF00FF>阳：</color>"
    local totalYangAtt = 0  -- 两仪属性 阳
    local totalYinAtt = 0   -- 两仪属性 阴
    for i = 1, 5 do -- 遍历五行属性，加起来为两仪属性
        local five = wuXin[i][1]
        local fiveUnLock = itemData == nil and 0 or itemData:GetIntCustomAttr(five.."Unlock")
        if fiveUnLock ~= 0 then
            local yY = itemData:GetIntCustomAttr(five .. "YinYang")
            if yY == 2 then
                totalYinAtt = totalYinAtt + math.abs(itemData:GetIntCustomAttr(five .. "YinYangAtt"))
            elseif yY == 1 then
                totalYangAtt = totalYangAtt + math.abs(itemData:GetIntCustomAttr(five .. "YinYangAtt"))
            end
        end
    end
    local yinAttIsPct = TipsConfig["YinAttIsPct"] == 1 and tostring(totalYinAtt / 100) .. "%" or totalYinAtt
    local yangAttIsPct = TipsConfig["YangAttIsPct"] == 1 and tostring(totalYangAtt / 100) .. "%" or totalYangAtt
    for i = 1, 3 do
        if TipsConfig["YangActualInfo"][i] == "param" then
            if totalYangAtt ~= 0 then
                actualInfo = actualInfo .. yangAttIsPct
            else    -- 如果属性为0的话就显示模糊的
                local coef1 = TipsConfig["YangAttCoef1"] < 0 and -TipsConfig["YangAttCoef1"] or TipsConfig["YangAttCoef1"]
                local coef2 = TipsConfig["YangAttCoef2"] < 0 and -TipsConfig["YangAttCoef2"] or TipsConfig["YangAttCoef2"]
                if TipsConfig["YangAttIsPct"] == 1 then
                    actualInfo = actualInfo .. tostring(coef1 / 100) .. "% ~ " .. tostring(coef2 * 5 / 100) .. "%"
                else
                    actualInfo = actualInfo .. coef1 .. " ~ " .. (coef2 * 5)
                end
            end
        else
            actualInfo = actualInfo .. TipsConfig["YangActualInfo"][i]
        end
    end

    -- 阴两仪
    actualInfo = actualInfo .. "\n"
    actualInfo = actualInfo .. "<color=#08AF00FF>阴：</color>"
    for i = 1, 3 do
        if TipsConfig["YangActualInfo"][i] == "param" then
            if totalYinAtt ~= 0 then
                actualInfo = actualInfo .. yinAttIsPct
            else
                local coef1 = math.abs(TipsConfig["YinAttCoef1"])
                local coef2 = math.abs(TipsConfig["YinAttCoef2"])
                if TipsConfig["YinAttIsPct"] == 1 then
                    actualInfo = actualInfo .. tostring(coef1 / 100) .. "% ~ " .. tostring(coef2 * 5 / 100) .. "%"
                else
                    actualInfo = actualInfo .. coef1 .. " ~ " .. (coef2 * 5)
                end
            end
        else
            actualInfo = actualInfo .. TipsConfig["YinActualInfo"][i]
        end
    end

    GUI.TipsAddLabel(itemTips, 20, "两仪属性：\n<color=#fff2d0ff>" .. actualInfo .. "</color>", UIDefine.Yellow3Color, true)

    -- 五行效果
    local yinYang = 0
    local flag = 1
    if itemData ~= nil then
        flag = 0
        for i = 1, 5 do
            if itemData:GetIntCustomAttr(wuXin[i][1].."YinYang") == 2 then
                yinYang = yinYang - 1
            elseif itemData:GetIntCustomAttr(wuXin[i][1].."YinYang") == 1 then
                yinYang = yinYang + 1
            else
                flag = 1
                break
            end
        end
    end
    local nowStr = ""
    if flag == 0 then
        nowStr = nowStr .. "\n<color=#08AF00FF>"..yinYangFF[yinYang][1] .. "：</color>"
        nowStr = nowStr .. string.sub(TipsConfig["Skill"..yinYangFF[yinYang][2].."Info"], 10), string.len(TipsConfig["Skill"..yinYangFF[yinYang][2].."Info"])
    else
        for i = 1, 6 do
            local skillInfo = TipsConfig["Skill"..i.."Info"]
            nowStr = nowStr .. "\n<color=#08AF00FF>"..string.sub(skillInfo, 0, 6).."</color><color=#FF0000ff>".."（未激活）</color>"..string.sub(skillInfo, 7, string.len(skillInfo))
        end
    end
    GUI.TipsAddCutLine(itemTips)
    GUI.TipsAddLabel(itemTips, 20, "五行效果：<color=#fff2d0ff>" .. nowStr .. "</color>", UIDefine.Yellow3Color, true)

    if state == 1 then  -- 装备在身上的显示卸下
        local handleBtn = GUI.ButtonCreate(itemTips, "handleBtn", 1800402110, 0, -10, Transition.ColorTint, "卸下", 150, 50, false)
        UILayout.SetSameAnchorAndPivot(handleBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(handleBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(handleBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(handleBtn, UCE.PointerClick, "SpiritualEquipUI", "RemoveEquipItem")
        local inEquip = GUI.ImageCreate(itemTips, "inEquip", "1800707290", 0, 0)
        UILayout.SetSameAnchorAndPivot(inEquip, UILayout.TopLeft)
    elseif state == 2 then    -- 背包里的显示分解和装备
        local handleBtn = GUI.ButtonCreate(itemTips, "handleBtn", 1800402110, -20, -10, Transition.ColorTint, "装备", 150, 50, false)
        UILayout.SetSameAnchorAndPivot(handleBtn, UILayout.BottomRight)
        GUI.ButtonSetTextColor(handleBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(handleBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(handleBtn, UCE.PointerClick, "SpiritualEquipUI", "OnEquipBtnClick")

        local brokeBtn = GUI.ButtonCreate(itemTips, "brokeBtn", 1800402110, 20, -10, Transition.ColorTint, "分解", 150, 50, false)
        UILayout.SetSameAnchorAndPivot(brokeBtn, UILayout.BottomLeft)
        GUI.ButtonSetTextColor(brokeBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(brokeBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(brokeBtn, UCE.PointerClick, "SpiritualEquipUI", "OnBrokeBtnClick")
    end
end

-- 脱下灵宝方法
function SpiritualEquipUI.RemoveEquipItem()
    local guid = LD.GetItemGuidByIndex(BagSelectIndex, EquipBag)
    local dst = System.Enum.ToInt(Bag)
    CL.SendNotify(NOTIFY.MoveItem, guid, dst)
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "GetData")
end

-- 装备灵宝方法
function SpiritualEquipUI.OnEquipBtnClick()
    if BagSubType == 2 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "主动灵宝无需装备")
        return
    end

    local flag = 0
    for i = 0, 4 do
        local data = LD.GetItemDataByIndex(i, EquipBag)
        if data == nil then
            flag = flag + 1
        end
    end

    if flag ~= 0 then
        local guid = LD.GetItemGuidByIndex(BagSelectIndex, Bag)
        local dst = System.Enum.ToInt(EquipBag)
        CL.SendNotify(NOTIFY.MoveItem, guid, dst)
        CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "GetData")
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "没有灵宝空位了，请先卸下一个灵宝")
    end
end

-- 取消选中
function SpiritualEquipUI.UnSelect()
    if SelectItemGuid ~= nil then
        GUI.ItemCtrlUnSelect(GUI.GetByGuid(SelectItemGuid))
        SelectItemGuid = nil
        BagSelectIndex = nil
    end
end

-- 统一按钮字体式样
function SpiritualEquipUI.SetFont(font)
    UILayout.SetAnchorAndPivot(font, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(font,UIDefine.BrownColor)
    GUI.StaticSetFontSize(font, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(font, TextAnchor.MiddleCenter)
end

-- 统一普通文字字体式样
function SpiritualEquipUI.SetFont2(font)
    SetAnchorAndPivot(font, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(font, TextAnchor.MiddleLeft)
    GUI.SetColor(font, ColorType_FontColor2)
    GUI.StaticSetFontSize(font, 22)
end

-- 被动按钮点击
function SpiritualEquipUI.OnPassiveBtn()
    local passiveBtn = _gt.GetUI("passiveBtn")
    local activeBtn = _gt.GetUI("activeBtn")

    if passiveBtn and activeBtn then
        BagSubType = 1
        GUI.CheckBoxExSetCheck(passiveBtn, true)
        GUI.CheckBoxExSetCheck(activeBtn, false)

        SpiritualEquipUI.RefreshWearPage()
    end
end

-- 主动按钮点击
function SpiritualEquipUI.OnActiveBtn()
    local passiveBtn = _gt.GetUI("passiveBtn")
    local activeBtn = _gt.GetUI("activeBtn")

    if passiveBtn and activeBtn then
        BagSubType = 2
        GUI.CheckBoxExSetCheck(passiveBtn, false)
        GUI.CheckBoxExSetCheck(activeBtn, true)

        SpiritualEquipUI.RefreshWearPage()
    end
end

local colorYellow1 = Color.New(252 / 255, 243 / 255, 38 / 255, 255 / 255)
local colorYellow2 = Color.New(255 / 255, 242 / 255, 208 / 255, 255 / 255)
-- 灵宝加成Tips
function SpiritualEquipUI.OnSpAddArrBtnClick()
    test("灵宝加成tips")
    local SpiritualEquipSortTypeArr = {}
    local SpecialEquipAttr = LingBaoTB.SpecialEquipAttr
    for i = 0, 5 do
        local itemData = LD.GetItemDataByIndex(i, EquipBag)
        if itemData ~= nil then
            local config = nil
            for i, v in ipairs(EquipAttConfig) do
                if v["KeyName"] == DB.GetOnceItemByKey1(itemData.id).KeyName then
                    config = v
                    break
                end
            end
            for i = 1, 6 do
                local five = wuXin[i][1]
                --local nowAttrId = config["Att"][five.."Att"]
                local type = config["Att"][five.."Type"]
                local fiveLevel = itemData:GetIntCustomAttr(five.."Level")
                if type == 1 then   -- 人物角色属性
                    for i = 1, #config["Att"][five.."Att"] do
                        local attData = DB.GetOnceAttrByKey1(config["Att"][five.."Att"][i])
                        local chinaName = config["Att"][five.."IsPct"] == 1 and  "万分比" .. attData.ChinaName or attData.ChinaName
                        if SpiritualEquipSortTypeArr[chinaName] ~= nil then -- 有就在原来的基础上加
                            SpiritualEquipSortTypeArr[chinaName] = SpiritualEquipSortTypeArr[chinaName] + config["Att"][five.."LvDiff"] * fiveLevel
                        else    -- 没有就新加一个字段
                            SpiritualEquipSortTypeArr[chinaName] = config["Att"][five.."LvDiff"] * fiveLevel
                        end
                    end
                    --table.insert(SpiritualEquipSortTypeArr,{[attData.ChinaName] = tostring(config["Att"][five.."LvDiff"]) * fiveLevel})
                end -- {["AttrName"]= attData.ChinaName, ["Value"]= tostring(config["Att"][five.."LvDiff"]) * fiveLevel}
            end
        end
    end

    for i = 1, #BagData[2] do
        local itemData = LD.GetItemDataByIndex(BagData[2][i], Bag)
        if itemData ~= nil then
            local config = nil
            for i, v in ipairs(EquipAttConfig) do
                if v["KeyName"] == DB.GetOnceItemByKey1(itemData.id).KeyName then
                    config = v
                    break
                end
            end
            for i = 1, 6 do
                local five = wuXin[i][1]
                --local nowAttrId = config["Att"][five.."Att"]
                local type = config["Att"][five.."Type"]
                local fiveLevel = itemData:GetIntCustomAttr(five.."Level")
                if type == 1 then   -- 人物角色属性
                    for i = 1, #config["Att"][five.."Att"] do
                        local attData = DB.GetOnceAttrByKey1(config["Att"][five.."Att"][i])
                        local chinaName = config["Att"][five.."IsPct"] == 1 and "万分比" .. attData.ChinaName or attData.ChinaName
                        if SpiritualEquipSortTypeArr[chinaName] ~= nil then -- 有就在原来的基础上加
                            SpiritualEquipSortTypeArr[chinaName] = SpiritualEquipSortTypeArr[chinaName] + config["Att"][five.."LvDiff"] * fiveLevel
                        else    -- 没有就新加一个字段
                            SpiritualEquipSortTypeArr[chinaName] = config["Att"][five.."LvDiff"] * fiveLevel
                        end
                    end
                    --table.insert(SpiritualEquipSortTypeArr,{[attData.ChinaName] = tostring(config["Att"][five.."LvDiff"]) * fiveLevel})
                end -- {["AttrName"]= attData.ChinaName, ["Value"]= tostring(config["Att"][five.."LvDiff"]) * fiveLevel}
            end
        end
    end

    for i, v in pairs(SpecialEquipAttr) do
        local name = v[2] == 1 and "万分比"..i or i
        if SpiritualEquipSortTypeArr[name] ~= nil then -- 有就在原来的基础上加
            SpiritualEquipSortTypeArr[name] = SpiritualEquipSortTypeArr[name] + v[1]
        else    -- 没有就新加一个字段
            SpiritualEquipSortTypeArr[name] = v[1]
        end
    end

    local panelBg = _gt.GetUI("panelBg")
    local addArrTip = GUI.ImageCreate( panelBg, "addArrTip", "1800400290", -140, -115, false, 460, 400)
    SetAnchorAndPivot(addArrTip, UIAnchor.Bottom, UIAroundPivot.Bottom)

    local tipBg = GUI.ImageCreate( addArrTip, "tipBg", "1800001140", 0, -15,false,215,33)
    SetAnchorAndPivot(tipBg, UIAnchor.Top, UIAroundPivot.Top)

    local tip = GUI.CreateStatic( tipBg, "tip", "灵宝五行阵加成", 0, 0,155,26)
    SetAnchorAndPivot(tip, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(tip, 22)
    GUI.SetIsRemoveWhenClick(addArrTip, true) -- 是否检测到点击就销毁

    local txt1 = GUI.CreateStatic(addArrTip, "txt1", "基础属性", -85, -57,100,26)
    SetAnchorAndPivot(txt1, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetColor(txt1,colorYellow1)
    GUI.StaticSetFontSize(txt1, 22)
    GUI.StaticSetAlignment(txt1,TextAnchor.MiddleCenter)

    local txt2 = GUI.CreateStatic(addArrTip, "txt2", "属性加成", 145, -57,100,26);
    SetAnchorAndPivot(txt2, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetColor(txt2,colorYellow1)
    GUI.StaticSetFontSize(txt2, 22)
    GUI.StaticSetAlignment(txt2,TextAnchor.MiddleCenter)

    local index = 1
    local textScr = GUI.ScrollRectCreate(addArrTip, "textScr", 40, -80, 460, 290, 0, false, Vector2.New(0, 0), UIAroundPivot.Top, UIAnchor.Top, 2)
    SetAnchorAndPivot(textScr, UIAnchor.Top, UIAroundPivot.Top)
    for i, v in pairs(SpiritualEquipSortTypeArr) do
        if i ~= nil and v ~= 0 then
            -- 属性名称
            local name = GUI.CreateStatic(textScr, "name_"..index, "", 0, 0,270,26); -- -(85+(index-1)*30)
            SetAnchorAndPivot(name, UIAnchor.Top, UIAroundPivot.Top)
            GUI.SetColor(name,colorYellow2)
            GUI.StaticSetFontSize(name, 22)
            GUI.StaticSetAlignment(name,TextAnchor.MiddleCenter)

            -- 属性值
            local value=GUI.CreateStatic(textScr, "value"..index, "", 0, 0,100,26);
            SetAnchorAndPivot(value, UIAnchor.Top, UIAroundPivot.Top)
            GUI.SetColor(value,colorYellow2)
            GUI.StaticSetFontSize(value, 22)
            GUI.StaticSetAlignment(value,TextAnchor.MiddleCenter)

            -- 插入属性
            local n = i
            local va = tonumber(v)
            if string.sub(i, 1, 9) == "万分比" then   -- 万分比的话转换一下显示效果
                n = string.sub(i, 10, string.len(n))
                va = tostring(va / 100) .. "%"
            end
            GUI.StaticSetText(name, n)
            GUI.StaticSetText(value, va)
            --GUI.SetHeight(addArrTip,GUI.GetHeight(addArrTip)+30)
            index = index+1
        end
    end
    --if index > 5 then
    --    index = 5
    --end
    --GUI.SetHeight(addArrTip, index * 55 + 70)
    --GUI.SetHeight(textScr, index * 47)
    GUI.ScrollRectSetChildSpacing(textScr, Vector2.New(0,-6))
    GUI.ScrollRectSetChildSize(textScr, Vector2.New(230, 60))
    GUI.ScrollRectSetVertical(textScr, true)
end

--- 修炼页面点击
function SpiritualEquipUI.OnPracticeClick()
    Parameter = nil
    if not SpiritualEquipUI.ResetLastSelectPage(pageNum.practicePage) then
        return
    end

    SpiritualEquipUI.InitSpiritualData()
end

function SpiritualEquipUI.InitSpiritualData()
    --SelectList = nil
    --SelectListGuid = nil
    SpiritualEquipUI.RefreshLinBaoData()
    SpiritualEquipUI.SpiritualRefresh()
end

-- 修炼页面刷新
function SpiritualEquipUI.SpiritualRefresh()

    if #LingBaoTB["Bag"] == 0 and #LingBaoTB["Equip"] == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得灵宝")
        SpiritualEquipUI.OnArtificeClick()
        return
    end
    if #LingBaoData[2] == 0 then
        POrA = 1
    elseif #LingBaoData[1] == 0 then
        POrA = 2
    end
    --local practiceScroll = _gt.GetUI("practiceScroll")
    --GUI.ScrollRectSetNormalizedPosition(practiceScroll,Vector2.New(0,0))    -- 滚动框归位
    local pageName = LabelList[pageNum.practicePage][4]
    local pageBg = _gt.GetUI(pageName)
    if not pageBg then
        pageBg = SpiritualEquipUI.CreatePracticePage(pageName)
    else
        GUI.SetVisible(pageBg,true)
    end
    SpiritualEquipUI.RefreshPracticeRight()
end

-- 刷新灵宝数据LingBaoData排序整理
function SpiritualEquipUI.RefreshLinBaoData()
    LingBaoTB = SpiritualEquipUI.LingBaoTB    -- 灵宝数据（身上的+背包里的）
    --local inspect = require("inspect")
    --CDebug.LogError("LingBaoTB------"..inspect(LingBaoTB))
    if LingBaoTB == nil then
        return
    end
    LingBaoData = {
        [1] = {},   -- 主动
        [2] = {},   -- 被动
    }
    local LingBaoP = {} -- 放在背包里的被动灵宝
    local LingBaoE = {} -- 主动灵宝
    for k, j in ipairs(LingBaoTB["Equip"]) do
        if string.find(j.KeyName, "门派灵宝") then  -- 要让门派灵宝一定在第一个
            table.insert(LingBaoData[1], j)
            table.insert(LingBaoData[2], j)
        end
    end
    for k, j in ipairs(LingBaoTB["Bag"]) do
        if string.find(j.KeyName, "主动灵宝") then
            table.insert(LingBaoE, j)
        else
            table.insert(LingBaoP, j)
        end
    end

    table.sort(LingBaoE, SpiritualEquipUI.LingBaoTBSort)
    table.sort(LingBaoP, SpiritualEquipUI.LingBaoTBSort)

    -- 先放身上的再放背包里的
    --for k, j in ipairs(LingBaoTB["Equip"]) do
    --    table.insert(LingBaoData[2], j)
    --end
    --table.insert(LingBaoData[2], LingBaoTB["Equip"][5])
    for i = 1, 5 do
        if LingBaoTB["Equip"][i] ~= nil and not string.find(LingBaoTB["Equip"][i]["KeyName"], "门派灵宝") then
            table.insert(LingBaoData[2], LingBaoTB["Equip"][i])
        end
    end
    for k, j in ipairs(LingBaoP) do
        table.insert(LingBaoData[2], j)
    end
    for k, j in ipairs(LingBaoE) do
        table.insert(LingBaoData[1], j)
    end
end

function SpiritualEquipUI.LingBaoTBSort(a, b)
    local db1 = DB.GetOnceItemByKey1(a["Id"])
    local db2 = DB.GetOnceItemByKey1(b["Id"])
    if a["EquipLevel"] ~= b["EquipLevel"] then
        return a["EquipLevel"] > b["EquipLevel"]
    end

    if db1.Grade ~= db2.Grade then
        return db1.Grade > db2.Grade
    end
    return a["Id"] > b["Id"]
end

function SpiritualEquipUI.RefreshPracticeRight()
    local pageName = LabelList[pageNum.practicePage][4]
    local rightBg1 = _gt.GetUI(pageName.."1")
    local rightBg2 = _gt.GetUI(pageName.."2")

    if SelectList == nil then
        SelectList = LingBaoData[POrA][1].Id
    end
    local equip = LD.GetItemGuidsById(tonumber(SelectList), EquipBag)
    if equip == nil or equip.Count == 0 then
        equip = LD.GetItemGuidsById(tonumber(SelectList), Bag)
    end
    SelectEquipGuid = equip[0]
    SpiritualEquipUI.RefreshNowEquipData()

    local equipRank = tonumber(nowEquipData["EquipRank"])
    local maxLevel = nowConfig["RankConfig"][nowEquipData["EquipRank"]]["MaxLv"]
    local nowLevel = nowEquipData["EquipLevel"]
    SpiritualEquipUI.CreatePracticeStr()
    -- 根据灵宝当前状态决定显示哪个半边
    if nowLevel < maxLevel or nowConfig["RankConfig"][equipRank+1] == nil then    -- 没到上限或满级
        GUI.SetVisible(rightBg1, true)
        GUI.SetVisible(rightBg2, false)
        SpiritualEquipUI.RefreshPracticeRight1(rightBg1)
    else
        GUI.SetVisible(rightBg2, true)
        GUI.SetVisible(rightBg1, false)
        SpiritualEquipUI.RefreshPracticeRight2(rightBg2)
    end
end

function SpiritualEquipUI.RefreshNowEquipData()
    LingBaoTB = SpiritualEquipUI.LingBaoTB
    if SelectList == nil then
        SelectList = LingBaoData[POrA][1].Id
    end
    nowEquipData = nil
    for i, v in pairs(LingBaoTB) do
        for k, j in ipairs(v) do
            if j.Id == tonumber(SelectList) then
                nowEquipData = j
                break
            end
        end
        if nowEquipData ~= nil then break end
    end
    nowConfig = GeneralConfig["Grade"..tostring(DB.GetOnceItemByKey1(tonumber(SelectList)).Grade)]

    for i, v in ipairs(EquipAttConfig) do
        if v["KeyName"] == DB.GetOnceItemByKey1(tonumber(SelectList)).KeyName then
            nowEquipAttConfig = v
            break
        end
    end
end

-- 修炼页面
function SpiritualEquipUI.CreatePracticePage(pageName)
    local panelBg = _gt.GetUI("panelBg")

    -- 同五行，如果五行页面已经创建过这个滚动列表，就直接用，否则创建一个
    SpiritualEquipUI.CreatePracticeStr()
    ---- 修炼->灵宝升级
    -- 大的当父类，小的根据不同情况显示
    local mainBg = GUI.GroupCreate(panelBg, pageName, 0, -2, 892, 639)
    _gt.BindName(mainBg, pageName)
    local rightBg = GUI.GroupCreate(mainBg, pageName.."1", 0, -2, 892, 639)
    _gt.BindName(rightBg, pageName.."1")

    -- 标题背景
    local practiceTitle = GUI.ImageCreate(rightBg, "practiceTitle", "1800700080", 130, 60, false, 245, 36);
    SetAnchorAndPivot(practiceTitle, UIAnchor.Top, UIAroundPivot.Top)

    -- 标题文字
    local practiceTxt = GUI.CreateStatic(practiceTitle, "practiceTxt", "", 0, 0, 225, 50);
    _gt.BindName(practiceTxt, "practiceTxt")
    SpiritualEquipUI.SetFont2(practiceTxt)
    GUI.StaticSetAlignment(practiceTxt, TextAnchor.MiddleCenter)

    -- 灵宝图片
    local iconBg = GUI.ImageCreate(rightBg, "iconBg", "1800400050", -157, 110, false, 80, 81);
    SetAnchorAndPivot(iconBg, UIAnchor.Top, UIAroundPivot.Top)
    _gt.BindName(iconBg, "practiceIconBg")
    local icon = GUI.ImageCreate(iconBg, "icon", "1900000000", 0, -1, false, 70, 70);
    SetAnchorAndPivot(icon, UIAnchor.Center, UIAroundPivot.Center)

    -- 【等级】
    local practicePreviewCur = GUI.CreateStatic(iconBg, "practicePreviewCur", "【等级】", 110, -22, 150, 50);
    SpiritualEquipUI.SetFont2(practicePreviewCur)

    -- 等级
    local practiceLevel = GUI.CreateStatic(iconBg, "practiceLevel", "", 200, -22, 150, 50);
    SpiritualEquipUI.SetFont2(practiceLevel)

    for i = 0, MaxRank - 1 do
        local star = GUI.ImageCreate(iconBg, "star"..i, "1801202190", 200 + i*31, 3, false, 30, 30)
        SetAnchorAndPivot(star, UIAnchor.TopRight, UIAroundPivot.TopRight)
    end

    -- 【经验】
    local practicePreviewExp = GUI.CreateStatic(iconBg, "practicePreviewCur", "【经验】", 110, 22, 150, 50);
    SpiritualEquipUI.SetFont2(practicePreviewExp)

    -- 经验条
    local practiceExpBar = GUI.ScrollBarCreate(rightBg, "practiceExpBar", "", "1800408160", "1800408110",404,159,440,28,1,false,Transition.None, 0, 1, Direction.LeftToRight, false)
    SetAnchorAndPivot(practiceExpBar, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(practiceExpBar, "practiceExpBar")
    local silderFillSize = Vector2.New(435, 28)
    GUI.ScrollBarSetFillSize(practiceExpBar, silderFillSize)
    GUI.ScrollBarSetBgSize(practiceExpBar, silderFillSize)
    GUI.ScrollBarSetPos(practiceExpBar, 0/1)
    local practiceExpTxt = GUI.CreateStatic(practiceExpBar, "practiceExpTxt", "", 120,2,200,25, "system", true)
    UILayout.StaticSetFontSizeColorAlignment(practiceExpTxt, 21, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    _gt.BindName(practiceExpTxt, "practiceExpTxt")
    local AddExpBtn = GUI.ButtonCreate(rightBg, "AddExpBtn", "1800402060", 410,-145,Transition.ColorTint, "", 34,33, false)
    -- 添加经验方法
    GUI.RegisterUIEvent(AddExpBtn, UCE.PointerClick, "SpiritualEquipUI", "OnPracticeAddExpBtnClick")
    _gt.BindName(AddExpBtn, "AddExpBtn")
    --local TB = {"当前级别"}--, "下一级别"
    for i = 1, 1 do
        local practiceInfo = GUI.ImageCreate(rightBg, "practiceInfo"..i, "1800700050", 150 ,-20, false, 697, 174)
        -- 提升大文字（暂时没用但还是留着）
        --local particlePromoteTxt = GUI.CreateStatic(practiceInfo, "particlePromoteTxt"..i, "", 0, -10, 670, 70)
        --SetAnchorAndPivot(particlePromoteTxt, UIAnchor.Center, UIAroundPivot.Center)
        --GUI.StaticSetAlignment(particlePromoteTxt, TextAnchor.MiddleLeft)
        --GUI.SetColor(particlePromoteTxt, ColorType_FontColor1)
        --GUI.StaticSetFontSize(particlePromoteTxt, 22)
        --_gt.BindName(particlePromoteTxt, "particlePromoteTxt"..i)
        -- 提升小文字
        local practiceInfoTxt = GUI.CreateStatic(practiceInfo, "practiceInfoTxt"..i, "", 0,15,670,174, "system", true)
        SpiritualEquipUI.SetFont2(practiceInfoTxt)
        GUI.StaticSetAlignment(practiceInfoTxt, TextAnchor.UpperLeft)
        _gt.BindName(practiceInfoTxt, "practiceInfoTxt"..i)
    end

    -- 切线
    local practiceCutLine = GUI.ImageCreate(rightBg, "practiceCutLine", "1800700060", 155, 100, false, 715, 3);
    SetAnchorAndPivot(practiceCutLine, UIAnchor.Center, UIAroundPivot.Center)

    --创建左边滑动列表
    local materialCostBg = GUI.ImageCreate(rightBg, "materialCostBg", "1800400200", 70, -100, false, 326, 100);
    SetAnchorAndPivot(materialCostBg, UIAnchor.Bottom, UIAroundPivot.Bottom)
    _gt.BindName(materialCostBg, "materialCostBg")

    local materialCostTxt = GUI.CreateStatic(materialCostBg, "materialCostTxt", "材料消耗：", -215, 0, 120, 27);
    SpiritualEquipUI.SetFont2(materialCostTxt)

    local materialCostScroll = GUI.LoopScrollRectCreate(
            materialCostBg,
            "materialCostScroll",
            0,
            -5,
            320,
            100,
            "SpiritualEquipUI",
            "CreateMaterialCostScroll",
            "SpiritualEquipUI",
            "RefreshMaterialCostScroll",
            0,
            true,
            Vector2.New(90, 90),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    _gt.BindName(materialCostScroll, "materialCostScroll")
    GUI.ScrollRectSetChildSpacing(materialCostScroll, Vector2.New(15, 0))

    local practiceCoinCost = GUI.CreateStatic(rightBg, "practiceCoinCost", "", -160, -50, 90, 27);
    SpiritualEquipUI.SetFont2(practiceCoinCost)
    SetAnchorAndPivot(practiceCoinCost, UIAnchor.Bottom, UIAroundPivot.Bottom)
    _gt.BindName(practiceCoinCost, "practiceCoinCost")

    local coinCostBg = GUI.ImageCreate(practiceCoinCost, "coinCostBg", "1800700010", 190, -2, false, 240, 30);
    -- 银币icon
    local coinIconCost = GUI.ImageCreate(coinCostBg, "coinIconCost", "1800408280", -4, 2);
    SetAnchorAndPivot(coinIconCost, UIAnchor.Left, UIAroundPivot.Left)
    _gt.BindName(coinIconCost, "coinIconCost")

    -- 银币花费
    local practiceCoinCountCost = GUI.CreateStatic(coinCostBg, "practiceCoinCountCost", "", 0, 0, 200, 40, "system", true);		--银币消耗
    GUI.StaticSetFontSize(practiceCoinCountCost, 22)
    SetAnchorAndPivot(practiceCoinCountCost, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(practiceCoinCountCost, TextAnchor.MiddleCenter)
    _gt.BindName(practiceCoinCountCost, "practiceCoinCountCost")

    -- 修炼一次
    local practiceBtnOnce = GUI.ButtonCreate(rightBg, "practiceBtnOnce", "1800102090", 70, -99, Transition.ColorTint, "<color=#ffffff><size=26>修炼一次</size></color>", 160, 45, false);
    SetAnchorAndPivot(practiceBtnOnce, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.ButtonSetOutLineArgs(practiceBtnOnce, true, colorOutline, 1)
    GUI.SetIsOutLine(practiceBtnOnce,true)
    GUI.SetOutLine_Distance(practiceBtnOnce,1)
    GUI.RegisterUIEvent(practiceBtnOnce, UCE.PointerClick, "SpiritualEquipUI", "OnPracticeBtnOnceClick")
    _gt.BindName(practiceBtnOnce, "practiceBtnOnce")
    -- 点击再次点击间隔时间
    GUI.SetEventCD(practiceBtnOnce,UCE.PointerClick,1)

    -- 修炼十次
    local practiceBtnTenTimes = GUI.ButtonCreate(rightBg, "practiceBtnTenTimes", "1800102090", 70, -39, Transition.ColorTint, "<color=#ffffff><size=26>修炼十次</size></color>", 160, 45, false);
    SetAnchorAndPivot(practiceBtnTenTimes, UIAnchor.BottomRight, UIAroundPivot.BottomRight)
    GUI.ButtonSetOutLineArgs(practiceBtnTenTimes, true, colorOutline, 1)
    GUI.SetIsOutLine(practiceBtnTenTimes,true);
    GUI.SetOutLine_Distance(practiceBtnTenTimes,1);
    GUI.RegisterUIEvent(practiceBtnTenTimes, UCE.PointerClick, "SpiritualEquipUI", "OnPracticeBtnTenTimesClick")
    _gt.BindName(practiceBtnTenTimes, "practiceBtnTenTimes")
    -- 点击再次点击间隔时间
    GUI.SetEventCD(practiceBtnTenTimes,UCE.PointerClick,1)

    ----修炼->灵宝进阶
    local rightBg2 = GUI.GroupCreate(mainBg, pageName.."2", 0, -2, 892, 639)
    _gt.BindName(rightBg2, pageName.."2")

    -- 标题背景
    local practiceTitle = GUI.ImageCreate(rightBg2, "practiceTitle", "1800700080", 130, 60, false, 245, 36);
    SetAnchorAndPivot(practiceTitle, UIAnchor.Top, UIAroundPivot.Top)
    -- 标题文字
    local practiceTxt = GUI.CreateStatic(practiceTitle, "practiceTxt2", "", 0, 0, 255, 50);
    _gt.BindName(practiceTxt, "practiceTxt2")
    SpiritualEquipUI.SetFont2(practiceTxt)
    GUI.StaticSetAlignment(practiceTxt, TextAnchor.MiddleCenter)

    -- 灵宝图片
    local iconBg = GUI.ImageCreate(rightBg2, "iconBg", "1800400050", -120, 110, false, 80, 81)
    SetAnchorAndPivot(iconBg, UIAnchor.Top, UIAroundPivot.Top)
    _gt.BindName(iconBg, "practiceIconBg2")
    local icon = GUI.ImageCreate(iconBg, "icon", "1900000000", 0, -1, false, 70, 70)
    SetAnchorAndPivot(icon, UIAnchor.Center, UIAroundPivot.Center)

    -- 【等级】
    local advancedPreviewCur = GUI.CreateStatic(iconBg, "practicePreviewCur", "【等级】", 110, -22, 150, 50)
    SpiritualEquipUI.SetFont2(advancedPreviewCur)
    -- 等级
    local advancedLevel = GUI.CreateStatic(iconBg, "practiceLevel", "", 200, -22, 150, 50)
    SpiritualEquipUI.SetFont2(advancedLevel)

    for i = 0, MaxRank - 1 do
        local star = GUI.ImageCreate(iconBg, "star"..i, "1801202190", 200 + i*31, 3, false, 30, 30)
        SetAnchorAndPivot(star, UIAnchor.TopRight, UIAroundPivot.TopRight)
    end

    -- 【经验】
    local advancedPreviewExp = GUI.CreateStatic(iconBg, "practicePreviewCur", "【经验】", 110, 22, 150, 50)
    SpiritualEquipUI.SetFont2(advancedPreviewExp)

    -- 经验后的红色提示文字
    local advancedRedTxt = GUI.CreateStatic(iconBg, "advancedRedTxt", "灵宝进阶后，可以提升灵宝修炼等级", 305, 22, 356, 50)
    SpiritualEquipUI.SetFont2(advancedRedTxt)
    GUI.SetColor(advancedRedTxt, ColorType_Red)

    -- 左边切线
    local advancedCutLine1 = GUI.ImageCreate(rightBg2, "practiceCutLine", "1800800050", -75, 230, false, 300, 10)
    SetAnchorAndPivot(advancedCutLine1, UIAnchor.Top, UIAroundPivot.Top)

    -- 灵宝进阶文字
    local advancedTitleTxt = GUI.CreateStatic(advancedCutLine1, "advancedTitleTxt", "灵宝进阶", 210, 0, 97, 50)
    SpiritualEquipUI.SetFont2(advancedTitleTxt)
    GUI.StaticSetFontSize(advancedTitleTxt, 24)

    -- 右边切线
    local advancedCutLine2 = GUI.ImageCreate(advancedCutLine1, "practiceCutLine", "1800800060", 420, 0, false, 300, 10)
    SetAnchorAndPivot(advancedCutLine2, UIAnchor.Left, UIAroundPivot.Left)

    -- 进阶图片
    local advancedIconBg = GUI.ImageCreate(rightBg2, "advancedIconBg", "1800400050", -120, 0, false, 80, 81)
    SetAnchorAndPivot(advancedIconBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(advancedIconBg, "advancedIconBg")
    local advancedIcon = GUI.ImageCreate(advancedIconBg, "advancedIcon", "1900000000", 0, -1, false, 70, 70)
    SetAnchorAndPivot(advancedIcon, UIAnchor.Center, UIAroundPivot.Center)

    -- 进阶名字
    local advancedName = GUI.CreateStatic(advancedIconBg, "advancedName", "", 12, 58, 128, 50);
    SpiritualEquipUI.SetFont2(advancedName)
    GUI.SetColor(advancedName, ColorType_Red)

    local advancedInfoTxt = GUI.CreateStatic(rightBg2, "advancedInfoTxt", "灵宝五行阵灵，随机获得一条两仪属性：", 210, -30, 525, 30, "system", true);
    SpiritualEquipUI.SetFont2(advancedInfoTxt)
    _gt.BindName(advancedInfoTxt, "advancedInfoTxt")
    -- 进阶效果文字
    local advancedTxt = GUI.CreateStatic(rightBg2, "advancedTxt", "", 210, 30, 525, 120, "system", true);
    SpiritualEquipUI.SetFont2(advancedTxt)
    GUI.SetColor(advancedTxt, ColorType_FontColor1)
    _gt.BindName(advancedTxt, "advancedTxt")

    -- 等级上限提升文字
    local advancedLevelUp = GUI.CreateStatic(rightBg2, "advancedLevelUp", "灵宝修炼等级上限：", -46, 100, 225, 50);
    SpiritualEquipUI.SetFont2(advancedLevelUp)

    -- 当前等级上限
    local advancedNowLevel = GUI.CreateStatic(advancedLevelUp, "advancedNowLevel", "", 140, 0, 79, 50);
    SpiritualEquipUI.SetFont2(advancedNowLevel)
    _gt.BindName(advancedNowLevel, "advancedNowLevel")

    -- 提升等级上限
    local advancedUpLevel = GUI.CreateStatic(advancedLevelUp, "advancedUpLevel", "", 210, 0, 85, 50);
    SpiritualEquipUI.SetFont2(advancedUpLevel)
    GUI.SetColor(advancedUpLevel, ColorType_Green)
    _gt.BindName(advancedUpLevel, "advancedUpLevel")

    -- 切线3号👌
    local advancedCutLine3 = GUI.ImageCreate(rightBg2, "advancedCutLine3", "1800700060", 155, -140, false, 715, 3)
    SetAnchorAndPivot(advancedCutLine3, UIAnchor.Bottom, UIAroundPivot.Bottom)

    -- 需要消耗的材料图片
    local materialIconBg = GUI.ImageCreate(rightBg2, "materialIconBg", "1800400050", -120, -40, false, 80, 81)
    SetAnchorAndPivot(materialIconBg, UIAnchor.Bottom, UIAroundPivot.Bottom)
    _gt.BindName(materialIconBg, "materialIconBg")
    local materialIcon = GUI.ImageCreate(materialIconBg, "materialIcon", "1900000000", 0, -1, false, 70, 70)
    SetAnchorAndPivot(materialIcon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(materialIcon, true)
    GUI.RegisterUIEvent(materialIcon, UCE.PointerClick, "SpiritualEquipUI", "MaterialsTips")

    -- 材料名字
    local materialName = GUI.CreateStatic(materialIconBg, "materialName", "", 200, 25, 300, 50)
    SpiritualEquipUI.SetFont2(materialName)

    -- 需要材料以及拥有材料
    local materialNeedAndHave = GUI.CreateStatic(materialIconBg, "materialNeedAndHave", "", 124, -40, 150, 50)
    SpiritualEquipUI.SetFont2(materialNeedAndHave)
    GUI.StaticSetAlignment(materialNeedAndHave, TextAnchor.UpperLeft)

    -- 灵宝进阶按钮
    local spiritualEquipLevelUp = GUI.ButtonCreate(rightBg2, "spiritualEquipLevelUp", "1800102090", 300, -50, Transition.ColorTint, "<color=#ffffff><size=26>灵宝进阶</size></color>", 160, 45, false);
    SetAnchorAndPivot(spiritualEquipLevelUp, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ButtonSetOutLineArgs(spiritualEquipLevelUp, true, colorOutline, 1)
    GUI.SetIsOutLine(spiritualEquipLevelUp,true);
    GUI.SetOutLine_Distance(spiritualEquipLevelUp,1);
    GUI.RegisterUIEvent(spiritualEquipLevelUp, UCE.PointerClick, "SpiritualEquipUI", "OnSpiritualEquipLevelUpClick")
    _gt.BindName(spiritualEquipLevelUp, "spiritualEquipLevelUp")
    GUI.SetEventCD(spiritualEquipLevelUp, UCE.PointerClick, 1)
end

function SpiritualEquipUI.CreateMaterialCostScroll()
    local materialCostScroll =  _gt.GetUI("materialCostScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(materialCostScroll)
    local materialCostBg = ItemIcon.Create(materialCostScroll,"materialCostBg" .. curCount,0,0)
    _gt.BindName(materialCostBg,"materialCostBg"..curCount)

    local materialCostNum = GUI.CreateStatic(materialCostBg,"materialCostNum","",-5,-7,90,50)
    GUI.StaticSetFontSize(materialCostNum, UIDefine.FontSizeM)
    SetAnchorAndPivot(materialCostNum, UIAnchor.BottomRight,UIAroundPivot.BottomRight)
    GUI.StaticSetAlignment(materialCostNum, TextAnchor.MiddleRight)
    GUI.SetIsOutLine(materialCostNum, true);
    GUI.SetOutLine_Color(materialCostNum, UIDefine.BlackColor);
    GUI.RegisterUIEvent(materialCostBg, UCE.PointerClick, "SpiritualEquipUI", "OnMaterialCostScrollClick");
    return materialCostBg
end

function SpiritualEquipUI.RefreshMaterialCostScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local info = DB.GetOnceItemByKey2(materialCost[index][1])   -- 1是keyName，2是数量
    local materialItem = GUI.GetByGuid(guid)
    GUI.SetData(materialItem, "id", info.Id)
    ItemIcon.BindItemDB(materialItem, info)
    local haveNum = LD.GetItemCountById(info.Id)
    local needNum = materialCost[index][2]
    local materialCostNum = GUI.GetChild(materialItem, "materialCostNum", false)
    GUI.StaticSetText(materialCostNum, haveNum .. "/" .. needNum)
    if haveNum >= needNum then
        GUI.SetColor(materialCostNum, ColorType_White)
    else
        GUI.SetColor(materialCostNum, ColorType_Red)
    end
end

-- 点击升级消耗材料tips
function SpiritualEquipUI.OnMaterialCostScrollClick(guid)
    local materialCost = GUI.GetByGuid(guid)
    local id = GUI.GetData(materialCost, "id")
    local materialCostBg = _gt.GetUI("materialCostBg")
    Tips.CreateByItemId(id, materialCostBg, "itemTips", 0, 0)
end

-- 灵气加经验窗口
function SpiritualEquipUI.OnPracticeAddExpBtnClick()
    local PracticeCover = _gt.GetUI("PracticeCover")
    practiceAddExpBtnClick = 1
    local level = nowEquipData["EquipLevel"]
    if EquipLevelMax <= level then
        CL.SendNotify(NOTIFY.ShowBBMsg, "经验已满")
        return
    end
    -- 获取灵气数据
    SpiritualEquipUI.RefreshLinQiData()

    if PracticeCover == nil then
        local panelBg = _gt.GetUI("panelBg")
        --- 增加经验弹窗
        PracticeCover = GUI.ImageCreate(panelBg, "PracticeCover", "1800400220", 0, -32, false, 2000, 2000)
        UILayout.SetAnchorAndPivot(PracticeCover, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetIsRaycastTarget(PracticeCover, true)
        _gt.BindName(PracticeCover, "PracticeCover")

        local AddBtn_PanelBack = UILayout.CreateFrame_WndStyle2_WithoutCover(PracticeCover,"提升修炼",580,435,"SpiritualEquipUI","PracticeAddBtnOnExit")
        _gt.BindName(AddBtn_PanelBack, "AddBtn_PanelBack")

        --道具列表
        local itemListBg = GUI.ImageCreate(AddBtn_PanelBack, "itemListBg", "1800400200", 0, -26, false, 506, 268)
        SetAnchorAndPivot(itemListBg, UIAnchor.Center, UIAroundPivot.Center)

        local itemListScr = GUI.LoopScrollRectCreate(
                itemListBg,
                "itemListScr",
                0,
                8,
                505,
                253,
                "SpiritualEquipUI",
                "CreateItemListScr",
                "SpiritualEquipUI",
                "RefreshItemListScr",
                0,
                false,
                Vector2.New(78,78),
                6,
                UIAroundPivot.Top,
                UIAnchor.Top
        )
        SetAnchorAndPivot(itemListScr, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.ScrollRectSetChildSpacing(itemListScr,Vector2.New(3,8))
        _gt.BindName(itemListScr, "itemListScr")
        GUI.LoopScrollRectSetTotalCount(itemListScr, 18)
        GUI.LoopScrollRectRefreshCells(itemListScr)

        --底部信息背景框
        local addBtnBg = GUI.ImageCreate(AddBtn_PanelBack, "addBtnBg", "1800700020", 26, -19)
        SetAnchorAndPivot(addBtnBg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        _gt.BindName(addBtnBg,"addBtnBg")

        --图标
        local addBtnEquipIcon = GUI.ImageCreate(addBtnBg, "addBtnEquipIcon", "1900815010", 0, 0, false, 76, 76)
        SetAnchorAndPivot(addBtnEquipIcon, UIAnchor.Center, UIAroundPivot.Center)
        _gt.BindName(addBtnEquipIcon, "addBtnEquipIcon")

        --灵宝名字
        local addBtnEquipName = GUI.CreateStatic(addBtnBg, "addBtnEquipName", "", 90, -5, 200, 35)
        SetAnchorAndPivot(addBtnEquipName, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(addBtnEquipName, 22)
        GUI.SetColor(addBtnEquipName, UIDefine.BrownColor)
        _gt.BindName(addBtnEquipName,"addBtnEquipName")

        --灵宝等级
        local practiceSkillText = GUI.CreateStatic(addBtnBg,"practiceSkillText","",215,19,100,35)
        SpiritualEquipUI.SetFont2(practiceSkillText)
        _gt.BindName(practiceSkillText, "practiceSkillText")

        --灵宝升级字体
        local practiceSkillUpText = GUI.CreateStatic(addBtnBg,"practiceSkillUpText","",255,-3,130,35)
        SetAnchorAndPivot(practiceSkillUpText,UIAnchor.TopLeft,UIAroundPivot.TopLeft)
        GUI.StaticSetFontSize(practiceSkillUpText,22)
        GUI.SetColor(practiceSkillUpText,Color.New(0 / 255, 202 / 255, 0 / 255, 1))
        _gt.BindName(practiceSkillUpText,"practiceSkillUpText")
        GUI.SetVisible(practiceSkillUpText, false)

        --经验条ExpPreView
        local addBtnSkillExpPreView = GUI.ScrollBarCreate(addBtnBg, "addBtnSkillExpPreView","","1800408130","1800408110",253,-66,0,0,1,false,Transition.None,0,1,Direction.LeftToRight,false)
        GUI.ScrollBarSetFillSize(addBtnSkillExpPreView,Vector2.New(327,26))
        GUI.ScrollBarSetBgSize(addBtnSkillExpPreView, Vector2.New(327,26))
        GUI.ScrollBarSetPos(addBtnSkillExpPreView, 0/1)
        SetAnchorAndPivot(addBtnSkillExpPreView, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        _gt.BindName(addBtnSkillExpPreView,"addBtnSkillExpPreView")

        --经验条
        local addBtnSkillExp = GUI.ScrollBarCreate(addBtnBg, "addBtnSkillExp","","1800408160","1800499999",253,-66,0,0,1,false,Transition.None,0,1,Direction.LeftToRight,false)
        GUI.ScrollBarSetFillSize(addBtnSkillExp,Vector2.New(327,26))
        GUI.ScrollBarSetBgSize(addBtnSkillExp, Vector2.New(327,26))
        GUI.ScrollBarSetPos(addBtnSkillExp, 0/1)
        SetAnchorAndPivot(addBtnSkillExp, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        _gt.BindName(addBtnSkillExp,"addBtnSkillExp")

        -- 经验条文本
        local addBtnSkillExpTxt = GUI.CreateStatic(addBtnSkillExp, "addBtnSkillExpTxt", "0/300", 0, 1,327,26)
        SetAnchorAndPivot(addBtnSkillExpTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(addBtnSkillExpTxt, 20)
        GUI.SetColor(addBtnSkillExpTxt, UIDefine.WhiteColor)
        GUI.StaticSetAlignment(addBtnSkillExpTxt,TextAnchor.MiddleCenter)
        _gt.BindName(addBtnSkillExpTxt,"addBtnSkillExpTxt")

        --使用按钮
        local UseBtn = GUI.ButtonCreate(addBtnBg, "UseBtn", "1800402110",440,-31, Transition.ColorTint, "使用", 80, 44, false)
        SetAnchorAndPivot(UseBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.ButtonSetTextFontSize(UseBtn, 22)
        GUI.ButtonSetTextColor(UseBtn, UIDefine.BrownColor)
        GUI.RegisterUIEvent(UseBtn , UCE.PointerClick , "SpiritualEquipUI", "OnUseBtn" )

        --选中最大可用
        local chooseUsefulCheckBox = GUI.CheckBoxCreate(addBtnBg, "chooseUsefulCheckBox", "1800607150", "1800607151", 323, 50, Transition.None, true, 35, 35) -- ExpUpdateUI.GetChooseUseful()
        _gt.BindName(chooseUsefulCheckBox, "chooseUsefulCheckBox")
        local ChooseUsefulLabel = GUI.CreateStatic(chooseUsefulCheckBox, "ChooseUsefulLabel", "选中最大可使用", 40, 4, 160, 30)
        GUI.StaticSetFontSize(ChooseUsefulLabel, 22)
        GUI.SetColor(ChooseUsefulLabel, UIDefine.BrownColor)
        GUI.RegisterUIEvent(chooseUsefulCheckBox, UCE.PointerClick, "SpiritualEquipUI", "OnChooseUsefulCheckBoxClick")
    end

    local addBtnSkillExp = _gt.GetUI("addBtnSkillExp")
    local addBtnSkillExpPreView = _gt.GetUI("addBtnSkillExpPreView")
    local addBtnSkillExpTxt = _gt.GetUI("addBtnSkillExpTxt")
    local practiceSkillUpText = _gt.GetUI("practiceSkillUpText")
    local addBtnEquipName = _gt.GetUI("addBtnEquipName")
    local addBtnBg = _gt.GetUI("addBtnBg")
    local addBtnEquipIcon = _gt.GetUI("addBtnEquipIcon")

    local level = nowEquipData["EquipLevel"]
    nowExp = nowEquipData["EquipExp"] - nowConfig["LvConfig"]["Lv"][level]
    local nextLevelExp = nowConfig["LvConfig"]["Lv"][level+1] - nowConfig["LvConfig"]["Lv"][level]

    GUI.StaticSetText(addBtnEquipName, nowEquipData["Name"])
    GUI.StaticSetText(addBtnSkillExpTxt, tostring(nowExp) .. "/" .. tostring(nextLevelExp))
    GUI.ScrollBarSetPos(addBtnSkillExpPreView, nowExp / nextLevelExp)
    GUI.ScrollBarSetPos(addBtnSkillExp, nowExp / nextLevelExp)
    GUI.SetVisible(practiceSkillUpText, false)
    GUI.SetVisible(PracticeCover, true)

    local dbData = DB.GetOnceItemByKey1(tonumber(SelectList))
    GUI.ImageSetImageID(addBtnBg, QualityRes[dbData.Grade])
    GUI.ImageSetImageID(addBtnEquipIcon, dbData.Icon)
    SpiritualEquipUI.OnChooseUsefulCheckBoxClick()
end

-- 灵气升级界面物品生成
function SpiritualEquipUI.CreateItemListScr()
    local itemListScr = _gt.GetUI("itemListScr")
    if itemListScr == nil then
        return
    end
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(itemListScr) + 1

    local itemIconBg = ItemIcon.Create(itemListScr, "itemIconBg"..curIndex, 0, 0)

    itemIconBg:RegisterEvent(UCE.PointerDown)
    itemIconBg:RegisterEvent(UCE.PointerUp)
    itemIconBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(itemIconBg, UCE.PointerDown , "SpiritualEquipUI", "OnLinQiIconClickDown")
    GUI.RegisterUIEvent(itemIconBg, UCE.PointerUp , "SpiritualEquipUI", "OnLinQiIconClickUp")
    GUI.RegisterUIEvent(itemIconBg, UCE.PointerClick , "SpiritualEquipUI", "OnLinQiIconClick")

    -- 选中光标
    local selectIcon = GUI.ImageCreate(itemIconBg, "selectIcon", "1800400280", 0,1, false, 84,84)
    SetAnchorAndPivot(selectIcon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(selectIcon, false)

    -- ➖按钮
    local decreaseBtn = GUI.ButtonCreate(itemIconBg, "decreaseBtn", "1800702070", 0, 0, Transition.ColorTint)
    GUI.SetVisible(decreaseBtn, false)
    GUI.SetData(decreaseBtn, "itemIconGuid", GUI.GetGuid(itemIconBg))
    UILayout.SetSameAnchorAndPivot(decreaseBtn, UILayout.TopRight)

    decreaseBtn:RegisterEvent(UCE.PointerDown)
    decreaseBtn:RegisterEvent(UCE.PointerUp)
    decreaseBtn:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerDown , "SpiritualEquipUI", "OnLinQiDecreaseBtnClickDown" );
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerUp , "SpiritualEquipUI", "OnLinQiDecreaseBtnClickUp" );
    GUI.RegisterUIEvent(decreaseBtn, UCE.PointerClick , "SpiritualEquipUI", "OnLinQiDecreaseBtnClick" );

    return itemIconBg
end

-- 灵气升级界面物品刷新
function SpiritualEquipUI.RefreshItemListScr(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item =  GUI.GetByGuid(guid)
    local decreaseBtn= GUI.GetChild(item,"decreaseBtn")
    local temp = OwnLinQi[index]    -- 背包灵气数据
    ItemIcon.SetEmpty(item)
    if temp == nil or item == nil then
        return
    end

    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, QualityRes[temp["grade"]]) --背景设置
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, temp["icon"])   --物品图片设置
    -- 如果拥有的数量是0的话，就变灰色，且不显示下标
    if temp["num"] == 0 then
        GUI.ItemCtrlSetIconGray(item, true)
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, "")
    else
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, tostring(temp["chooseNum"]).."/"..tostring(temp["num"]))--右下角数字
        GUI.ItemCtrlSetIconGray(item,false)
    end

    local selectIcon = GUI.GetChild(item, "selectIcon", false)
    -- 没有选中任何数量就不显示➖图标，顺便把光标也取消了
    if temp["chooseNum"] == 0 then
        GUI.SetVisible(decreaseBtn, false)
        GUI.SetVisible(selectIcon, false)
    else
        GUI.SetVisible(decreaseBtn, true)
    end

    GUI.SetData(item, "keyName", temp["keyName"])
    GUI.SetData(item, "index", index)
    GUI.SetData(item, "id", temp["id"])
end

-- 刷新灵气数据
function SpiritualEquipUI.RefreshLinQiData()
    OwnLinQi = {}
    Exp = 0
    if CultivationConfig ~= nil then
        for i, v in pairs(CultivationConfig) do
            local item = DB.GetOnceItemByKey2(i)
            local count = LD.GetItemCountById(item.Id)
            if count > 0 then
                local linQiGuids = LD.GetItemGuidsById(item.Id, item_container_type.item_container_bag)
                for j = 0, linQiGuids.Count - 1 do
                    local data = LD.GetItemDataByGuid(tostring(linQiGuids[j]), item_container_type.item_container_bag)
                    -- 这个temp是背包里有的灵气的数据
                    local temp = {["keyName"] = i,
                                  ["num"] = tonumber(data:GetAttr(ItemAttr_Native.Amount)),
                                  ["icon"] = item.Icon,
                                  ["grade"] = tonumber(item.Grade),
                                  ["chooseNum"] = 0,
                                  ["id"] = item.Id,
                                  ["guid"] = tostring(linQiGuids[j]),
                    } -- 物品 -> {keyName, Id, Icon, Grade, 选中的数量, guid}
                    table.insert(OwnLinQi, temp)
                end
            else    -- 否则的话就是没有的默认数据
                local temp = {["keyName"] = i,
                              ["num"] = 0,
                              ["icon"] = item.Icon,
                              ["grade"] = tonumber(item.Grade),
                              ["chooseNum"] = 0,
                              ["id"] = item.Id,
                              ["guid"] = "",
                } -- 物品 -> {keyName, Id, Icon, Grade, 选中的数量, guid}
                table.insert(OwnLinQi, temp)
            end
        end
    end

    table.sort(OwnLinQi, function (a, b)
        local pri1 = a["grade"]
        local pri2 = b["grade"]
        local pri3 = a["num"]
        local pri4 = b["num"]
        if pri3 == 0 then
            return false
        end
        if pri4 == 0 then
            return true
        end
        if pri1 == pri2 then
            return pri3 < pri4
        end
        return pri1 > pri2
    end)

    local PracticeCover = _gt.GetUI("PracticeCover")
    if PracticeCover ~= nil then
        local itemListScr = _gt.GetUI("itemListScr")
        local count = #OwnLinQi
        if count > 18 then
            count = (math.floor(count / 6) + 1) * 6
        else
            count = 18
        end
        GUI.LoopScrollRectSetTotalCount(itemListScr, count)
        GUI.LoopScrollRectRefreshCells(itemListScr)
    end
end

-- 长按连点
function SpiritualEquipUI.OnLinQiIconClickDown(guid)

    local func = function()
        SpiritualEquipUI.OnLinQiIconClick(guid)
    end

    if SpiritualEquipUI.Timer == nil then
        SpiritualEquipUI.Timer = Timer.New(func, 0.15, -1)
    else
        SpiritualEquipUI.Timer:Stop()
        SpiritualEquipUI.Timer:Reset(func, 0.15, 1)
    end

    SpiritualEquipUI.Timer:Start()
end

-- 松开
function SpiritualEquipUI.OnLinQiIconClickUp(guid)
    if SpiritualEquipUI.Timer ~= nil then
        SpiritualEquipUI.Timer:Stop()
        SpiritualEquipUI.Timer = nil
    end
end

-- 点击灵气icon
function SpiritualEquipUI.OnLinQiIconClick(guid)
    local iconBg = GUI.GetByGuid(guid)
    local keyName = GUI.GetData(iconBg, "keyName")

    if keyName == nil or keyName == "" then
        return
    end

    local index = GUI.GetData(iconBg, "index")
    local data = OwnLinQi[tonumber(index)]
    local num = data["num"]
    local chooseNum = data["chooseNum"]

    local selectIcon = GUI.GetChild(iconBg, "selectIcon", false)
    if LastSelectLinQi == nil then
        GUI.SetVisible(selectIcon, true)
    else
        GUI.SetVisible(GUI.GetByGuid(LastSelectLinQi), false)
        GUI.SetVisible(selectIcon, true)
    end
    LastSelectLinQi = GUI.GetGuid(selectIcon)

    if num > 0  then
        if num > chooseNum then
            GUI.ItemCtrlSelect(iconBg)
            SpiritualEquipUI.OnAddLinQi(index)
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "已到上限")
        end
    else
        SpiritualEquipUI.MaterialsTips(guid)
    end
end

-- 加灵气与判断
function SpiritualEquipUI.OnAddLinQi(index)
    local data = OwnLinQi[tonumber(index)]
    local chooseNum = data["chooseNum"]

    local maxLevel = nowConfig["RankConfig"][nowEquipData["EquipRank"]]["MaxLv"]
    local maxExp = nowConfig["LvConfig"]["Lv"][maxLevel] - nowEquipData["EquipExp"]
    if maxExp <= Exp then
        CL.SendNotify(NOTIFY.ShowBBMsg, "已到当前星级最大经验")
        return
    end

    OwnLinQi[tonumber(index)]["chooseNum"] = chooseNum + 1

    local itemListScr = _gt.GetUI("itemListScr")
    GUI.LoopScrollRectRefreshCells(itemListScr)

    SpiritualEquipUI.RefreshAddBtnSkillExp()
end

--获得途径按钮点击
function SpiritualEquipUI.OnClickWayBtn()
    -- test("waybtn点击")
    local itemTips=_gt.GetUI("itemTips")
    if itemTips==nil then
        test("Tips is nil")
    end
    if itemTips then
        Tips.ShowItemGetWay(itemTips)
    end
end

-- 减灵气长按
function SpiritualEquipUI.OnLinQiDecreaseBtnClickDown(guid)
    local func = function()
        SpiritualEquipUI.OnLinQiDecreaseBtnClick(guid)
    end
    if SpiritualEquipUI.Timer == nil then
        SpiritualEquipUI.Timer = Timer.New(func, 0.15, -1)
    else
        SpiritualEquipUI.Timer:Stop()
        SpiritualEquipUI.Timer:Reset(func, 0.15, 1)
    end

    SpiritualEquipUI.Timer:Start()
end

-- 减灵气长按结束
function SpiritualEquipUI.OnLinQiDecreaseBtnClickUp(guid)
    if SpiritualEquipUI.Timer ~= nil then
        SpiritualEquipUI.Timer:Stop()
        SpiritualEquipUI.Timer = nil
    end
end

-- 减灵气按钮方法
function SpiritualEquipUI.OnLinQiDecreaseBtnClick(guid)
    local itemIconGuid = GUI.GetData(GUI.GetByGuid(guid), "itemIconGuid")
    local iconBg = GUI.GetByGuid(itemIconGuid)
    local keyName = GUI.GetData(iconBg, "keyName")

    if keyName == nil or keyName == "" then
        return
    end

    local index = GUI.GetData(iconBg, "index")
    local data = OwnLinQi[tonumber(index)]
    local num = data["num"]
    local chooseNum = data["chooseNum"]

    if chooseNum <= 0 then
        GUI.SetVisible(GUI.GetByGuid(guid), false)
        return
    end

    if num > 0  then
        if num >= chooseNum then
            GUI.ItemCtrlSelect(iconBg)
            OwnLinQi[tonumber(index)]["chooseNum"] = chooseNum - 1

            local itemListScr = _gt.GetUI("itemListScr")
            GUI.LoopScrollRectRefreshCells(itemListScr)

            SpiritualEquipUI.RefreshAddBtnSkillExp()
        end
    end
end

-- 刷新经验条
function SpiritualEquipUI.RefreshAddBtnSkillExp()
    if CultivationConfig == nil then
        return
    end

    local addBtnSkillExpPreView = _gt.GetUI("addBtnSkillExpPreView")
    local addBtnSkillExpTxt = _gt.GetUI("addBtnSkillExpTxt")
    local practiceSkillUpText = _gt.GetUI("practiceSkillUpText")
    local practiceSkillText = _gt.GetUI("practiceSkillText")

    local level = nowEquipData["EquipLevel"]
    nowExp = nowEquipData["EquipExp"] - nowConfig["LvConfig"]["Lv"][level]
    Exp = 0
    for i, v in pairs(OwnLinQi) do
        Exp = Exp + CultivationConfig[v["keyName"]] * v["chooseNum"]
    end

    local maxLevel = nowConfig["RankConfig"][nowEquipData["EquipRank"]]["MaxLv"]
    local lvConfig = nowConfig["LvConfig"]["Lv"]

    local nextLevelExp = lvConfig[level+1] - lvConfig[level]
    GUI.ScrollBarSetPos(addBtnSkillExpPreView, (nowExp + Exp) / nextLevelExp)
    GUI.StaticSetText(addBtnSkillExpTxt, tostring(nowExp) .. "(+".. tostring(Exp) ..")/" .. nextLevelExp)   -- 刷新经验条
    GUI.StaticSetText(practiceSkillText, tostring(level) .. "级")    -- 刷新等级
    -- 加的经验足够到下一级，就显示绿色的等级数字
    if nowExp + Exp >= nextLevelExp then
        for i = level, #lvConfig do
            if lvConfig[i] > Exp + nowEquipData["EquipExp"] then
                GUI.SetVisible(practiceSkillUpText, true)
                GUI.StaticSetText(practiceSkillUpText, "(+"..tostring(i - level - 1) .. ")")
                break
            end
            if i == maxLevel then
                GUI.SetVisible(practiceSkillUpText, true)
                GUI.StaticSetText(practiceSkillUpText, "(+"..tostring(i - level) .. ")")
                break
            end
        end

    else
        GUI.SetVisible(practiceSkillUpText, false)
    end
end

-- 关闭提升修炼页面
function SpiritualEquipUI.PracticeAddBtnOnExit()
    local PracticeCover = _gt.GetUI("PracticeCover")
    practiceAddExpBtnClick = 0
    GUI.Destroy(PracticeCover)
end

-- 修炼一次按钮
function SpiritualEquipUI.OnPracticeBtnOnceClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "AddExp", SelectEquipGuid, "once")
end

-- 修炼十次按钮
function SpiritualEquipUI.OnPracticeBtnTenTimesClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "AddExp", SelectEquipGuid, "tentimes")
end

-- 使用灵气修炼
function SpiritualEquipUI.UseLinQi()
    local param = ""
    for i, v in pairs(OwnLinQi) do
        if v["chooseNum"] ~= 0 then
            param = param..v["guid"].."-"..v["chooseNum"]..","
        end
    end
    if param == "" then
        CL.SendNotify(NOTIFY.ShowBBMsg, "您没有选中任何灵气")
        return
    end
    --test(param)
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "AddExp", SelectEquipGuid, param)
    SpiritualEquipUI.PracticeAddBtnOnExit()
end

-- 使用灵气按钮点击
function SpiritualEquipUI.OnUseBtn()
    --local maxLevel = nowConfig["RankConfig"][nowEquipData["EquipRank"]]["MaxLv"]
    --local maxExp = nowConfig["LvConfig"]["Lv"][maxLevel]

    -- 这个提示有需要再加
    --if nowExp > maxExp then
    --    local str = "本次升级会溢出 ".. tostring(nowExp - maxExp) .. " 经验，确认要继续吗？"
    --    GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", str, "SpiritualEquipUI", "确认", "UseLinQi", "取消")
    --else
    SpiritualEquipUI.UseLinQi()
    --end
end

-- 选中最大可使用
function SpiritualEquipUI.OnChooseUsefulCheckBoxClick()
    local chooseUsefulCheckBox = _gt.GetUI("chooseUsefulCheckBox")

    if GUI.CheckBoxGetCheck(chooseUsefulCheckBox) then
        local maxLevel = nowConfig["RankConfig"][nowEquipData["EquipRank"]]["MaxLv"]
        local maxExp = nowConfig["LvConfig"]["Lv"][maxLevel] - nowEquipData["EquipExp"]
        local exp = 0
        for i, v in pairs(OwnLinQi) do
            if v["num"] > 0 then
                if maxExp <= 0 then
                    break
                end
                if v["num"] * CultivationConfig[v["keyName"]] <= maxExp then    -- 全选上也不够
                    v["chooseNum"] = v["num"]
                    Exp = Exp + v["chooseNum"] * CultivationConfig[v["keyName"]]
                    maxExp = maxExp - v["chooseNum"] * CultivationConfig[v["keyName"]]
                else
                    if maxExp % CultivationConfig[v["keyName"]] ~= 0 then
                        v["chooseNum"] = math.floor(maxExp / CultivationConfig[v["keyName"]]) + 1
                    else
                        v["chooseNum"] = math.floor(maxExp / CultivationConfig[v["keyName"]])
                    end
                    Exp = Exp + v["chooseNum"] * CultivationConfig[v["keyName"]]
                    exp = nowExp + Exp
                    if exp < maxExp then
                        v["chooseNum"] = v["chooseNum"] + 1
                        Exp = Exp + CultivationConfig[v["keyName"]]
                    end
                    maxExp = maxExp - Exp
                    break
                end
            end
        end
    else
        -- 全部取消
        for i, v in pairs(OwnLinQi) do
            if v["chooseNum"] > 0 then
                Exp = Exp - v["chooseNum"] * CultivationConfig[v["keyName"]]
                v["chooseNum"] = 0
            end
        end
        if SpiritualEquipUI.Timer ~= nil then
            SpiritualEquipUI.Timer:Stop()
            SpiritualEquipUI.Timer = nil
        end
    end
    local itemListScr = _gt.GetUI("itemListScr")
    GUI.LoopScrollRectRefreshCells(itemListScr)
    SpiritualEquipUI.RefreshAddBtnSkillExp()
end

-- 灵宝升级页面刷新
function SpiritualEquipUI.RefreshPracticeRight1(rightBg)

    local practiceTxt = _gt.GetUI("practiceTxt")    -- 灵宝名字标题
    local practiceIconBg = _gt.GetUI("practiceIconBg")  -- 灵宝iconBg
    local icon = GUI.GetChild(practiceIconBg, "icon", false)    -- 灵宝icon
    local practiceLevel = GUI.GetChild(practiceIconBg, "practiceLevel", false)      -- 灵宝等级
    local practiceExpBar = _gt.GetUI("practiceExpBar")  -- 经验条
    local practiceExpTxt = _gt.GetUI("practiceExpTxt")  -- 经验条上的字

    GUI.StaticSetText(practiceTxt, nowEquipData["Name"])

    local dbData = DB.GetOnceItemByKey1(tonumber(SelectList))
    GUI.ImageSetImageID(practiceIconBg, QualityRes[dbData.Grade])
    GUI.ImageSetImageID(icon, dbData.Icon)

    local level = nowEquipData["EquipLevel"]
    GUI.StaticSetText(practiceLevel, nowEquipData["EquipRank"].."阶"..level.."级")

    if EquipLevelMax <= level then
        GUI.ScrollBarSetPos(practiceExpBar, 1)
        GUI.StaticSetText(practiceExpTxt, "0/0")
    else
        local equipExp = nowEquipData["EquipExp"] - nowConfig["LvConfig"]["Lv"][level]  -- 灵宝的当前经验
        local needExp = nowConfig["LvConfig"]["Lv"][level+1] - nowConfig["LvConfig"]["Lv"][level]   -- 灵宝的下一级经验
        GUI.ScrollBarSetPos(practiceExpBar, equipExp / needExp)
        GUI.StaticSetText(practiceExpTxt, equipExp.."/"..needExp)
    end

    local rank = nowEquipData["EquipRank"] -- 获取灵宝的当前等级
    local maxRank = 0
    for i, v in pairs(EquipAttConfig) do
        if v.Id == tonumber(dbData.Id) then
            maxRank = v.RankMax
            break
        end
    end
    for i = 0, maxRank - 1 do
        local star = GUI.GetChild(practiceIconBg, "star"..i, false)
        if i < rank then
            GUI.ImageSetImageID(star, "1801202190")
        else
            GUI.ImageSetImageID(star, "1801202192")
        end
        GUI.SetVisible(star, true)
    end
    for i = maxRank, MaxRank - 1 do
        local star = GUI.GetChild(practiceIconBg, "star"..i, false)
        GUI.SetVisible(star, false)
    end

    local str = SpiritualEquipUI.OnSkillTipNtf(nowEquipAttConfig, level)

    local str1 = EquipLevelMax > level and SpiritualEquipUI.OnSkillTipNtf(nowEquipAttConfig, level+1) or "灵宝等级已达上限，无法再提升"
    local practiceInfoTxt = _gt.GetUI("practiceInfoTxt1")
    GUI.StaticSetText(practiceInfoTxt, "<color=#08AF00FF>当前效果：</color>" .. str .. "\n<color=#08AF00FF>下级效果：</color>" .. str1)

    local moneyType = nowConfig["LvConfig"]["MoneyType"] -- 消耗金钱种类(1.金元宝 2.银元宝 5.银币)
    if moneyType == nil then
        moneyType = 5
    end
    local practiceCoinCost = _gt.GetUI("practiceCoinCost")
    local coinIconCost = _gt.GetUI("coinIconCost")
    local money = nil
    if moneyType == 1 then
        GUI.StaticSetText(practiceCoinCost, "消耗金元宝")
        GUI.ImageSetImageID(coinIconCost, "1800408250")
        money = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrIngot)))
    elseif moneyType == 2 then
        GUI.StaticSetText(practiceCoinCost, "消耗银元宝")
        GUI.ImageSetImageID(coinIconCost, "1800408260")
        money = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindIngot)))
    elseif moneyType == 5 then
        GUI.StaticSetText(practiceCoinCost, "消耗银币")
        GUI.ImageSetImageID(coinIconCost, "1800408280")
        money = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrBindGold)))
    end

    local practiceCoinCountCost = _gt.GetUI("practiceCoinCountCost")    -- 需要花费的银币数量

    local needMoney = nowConfig["LvConfig"]["MoneyVal"]
    GUI.StaticSetText(practiceCoinCountCost, tostring(needMoney))

    -- 角色身上的钱少于需要的钱，就变红
    if money < needMoney then
        GUI.SetColor(practiceCoinCountCost, ColorType_Red)
    else
        GUI.SetColor(practiceCoinCountCost, ColorType_White)
    end

    materialCost = nowConfig["LvConfig"]["Item"]
    local material = #materialCost
    local materialCostBg = _gt.GetUI("materialCostBg")
    if material > 0 then
        GUI.SetVisible(materialCostBg, true)
        local materialCostScroll = _gt.GetUI("materialCostScroll")
        GUI.LoopScrollRectSetTotalCount(materialCostScroll, material)
        GUI.LoopScrollRectRefreshCells(materialCostScroll)
    else
        GUI.SetVisible(materialCostBg, false)
    end
end

function SpiritualEquipUI.RefreshPracticeRight2(rightBg)
    local practiceTxt = _gt.GetUI("practiceTxt2")    -- 灵宝名字标题
    local practiceIconBg = _gt.GetUI("practiceIconBg2")  -- 灵宝iconBg
    local icon = GUI.GetChild(practiceIconBg, "icon", false)    -- 灵宝icon
    local practiceLevel = GUI.GetChild(practiceIconBg, "practiceLevel", false)      -- 灵宝等级

    GUI.StaticSetText(practiceTxt, nowEquipData["Name"])    -- 设置名字
    local dbData = DB.GetOnceItemByKey1(tonumber(SelectList))
    GUI.ImageSetImageID(practiceIconBg, QualityRes[dbData.Grade])   -- 设置图片背景
    GUI.ImageSetImageID(icon, dbData.Icon)                          -- 设置图标icon

    local level = nowEquipData["EquipLevel"]
    GUI.StaticSetText(practiceLevel, nowEquipData["EquipRank"].."阶"..level.."级")       -- 等级和阶级
    local rank = nowEquipData["EquipRank"] -- 获取灵宝的当前等级
    local maxRank = 0
    for i, v in pairs(EquipAttConfig) do
        if v.Id == tonumber(dbData.Id) then
            maxRank = v.RankMax
            break
        end
    end
    for i = 0, maxRank - 1 do
        local star = GUI.GetChild(practiceIconBg, "star"..i, false)
        if i < rank then
            GUI.ImageSetImageID(star, "1801202190")
        else
            GUI.ImageSetImageID(star, "1801202192")
        end
        GUI.SetVisible(star, true)
    end
    for i = maxRank, MaxRank - 1 do
        local star = GUI.GetChild(practiceIconBg, "star"..i, false)
        GUI.SetVisible(star, false)
    end

    local advancedInfoTxt = _gt.GetUI("advancedInfoTxt")
    local advancedIconBg = _gt.GetUI("advancedIconBg")                          -- 进阶图片背景
    local advancedIcon = GUI.GetChild(advancedIconBg, "advancedIcon", false)    -- 进阶图片
    local advancedName = GUI.GetChild(advancedIconBg, "advancedName", false)    -- 进阶名字

    GUI.StaticSetText(advancedInfoTxt, "激活灵宝五行-" .. wuXin[nowEquipData["EquipRank"]][3] .. "阵灵，随机获得一条两仪属性")
    GUI.ImageSetImageID(advancedIcon, wuXin[nowEquipData["EquipRank"]][4])
    GUI.StaticSetText(advancedName, wuXin[nowEquipData["EquipRank"]][3] .. "阵灵")

    local advancedTxt = _gt.GetUI("advancedTxt")    -- 灵宝进阶描述
    local showString = "阳："..nowEquipAttConfig["YangInfo"].."\n阴："..nowEquipAttConfig["YinInfo"]
    GUI.StaticSetText(advancedTxt, showString)

    local advancedNowLevel = _gt.GetUI("advancedNowLevel")  -- 当前等级
    local advancedUpLevel = _gt.GetUI("advancedUpLevel")    -- 提升后的等级
    local equipRank = tonumber(nowEquipData["EquipRank"])
    local nowLv = nowConfig["RankConfig"][equipRank]["MaxLv"]
    local nextLv = nowConfig["RankConfig"][equipRank+1]["MaxLv"]
    GUI.StaticSetText(advancedNowLevel, nowLv)
    GUI.StaticSetText(advancedUpLevel, "+"..tostring(nextLv-nowLv))

    local materialIconBg = GUI.GetChild(rightBg, "materialIconBg", false)                           -- 材料背景
    local materialIcon = GUI.GetChild(materialIconBg, "materialIcon", false)                        -- 材料icon
    local materialName = GUI.GetChild(materialIconBg, "materialName", false)                        -- 材料名字
    local materialNeedAndHave = GUI.GetChild(materialIconBg, "materialNeedAndHave", false)          -- 拥有材料数量/需求材料数量

    local essenceData = DB.GetOnceItemByKey1(nowEquipAttConfig["EssenceId"])
    GUI.ImageSetImageID(materialIconBg, QualityRes[essenceData.Grade])
    GUI.ImageSetImageID(materialIcon, essenceData.Icon)
    GUI.SetData(materialIcon, "id", essenceData.Id)
    GUI.StaticSetText(materialName, essenceData.Name)

    local need = nowConfig["RankConfig"][nowEquipData["EquipRank"]]["ItemNum"]
    local have = LD.GetItemCountById(essenceData.Id)

    if need <= have then
        GUI.SetColor(materialNeedAndHave, ColorType_FontColor2)
    else
        GUI.SetColor(materialNeedAndHave, ColorType_Red)
    end
    GUI.StaticSetText(materialNeedAndHave, tostring(have) .. "/" .. tostring(need))
end

-- 灵宝进阶按钮
function SpiritualEquipUI.OnSpiritualEquipLevelUpClick()
    --local essenceData = DB.GetOnceItemByKey1(nowEquipAttConfig["EssenceId"])
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "RankUp", SelectEquipGuid)
end

-- 升星页面
function SpiritualEquipUI.SpiritualEquipStarUp()

    SpiritualEquipUI.RefreshNowEquipData()

    local panel = GUI.GetWnd("SpiritualEquipUI")
    local parent = GUI.Get("SpiritualEquipUI/panelBg")
    local upStarSuccessBg = GUI.ButtonCreate(parent, "upStarSuccessBg","1800400220",-GUI.GetPositionX(parent), GUI.GetPositionY(parent), Transition.None,"", GUI.GetWidth(panel), GUI.GetHeight(panel),false)
    SetAnchorAndPivot(upStarSuccessBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(upStarSuccessBg, "upStarSuccessBg")

    local centerBg = GUI.ImageCreate(upStarSuccessBg, "centerBg","1801200060",0,0,false,GUI.GetWidth(upStarSuccessBg),482) -- 黑色背景
    SetAnchorAndPivot(centerBg, UIAnchor.Center, UIAroundPivot.Center)

    local titleBg1 = GUI.ImageCreate(upStarSuccessBg, "titleBg1","1801200050",-211,-50) -- 升星成功左边翅膀
    SetAnchorAndPivot(titleBg1, UIAnchor.Top, UIAroundPivot.Top)

    local titleBg2 = GUI.ImageCreate(upStarSuccessBg, "titleBg2","1801200050",211,-50) -- 升星成功右边翅膀
    SetAnchorAndPivot(titleBg2, UIAnchor.Top, UIAroundPivot.Top)
    GUI.SetScale(titleBg2,Vector3.New(-1,1,1));

    local titleBg3 = GUI.ImageCreate(upStarSuccessBg, "titleBg3","1801204050",0,25) -- 升星成功字样
    SetAnchorAndPivot(titleBg3, UIAnchor.Top, UIAroundPivot.Top)

    local centerGroup = GUI.GroupCreate(centerBg, "centerGroup",0,0,1280,482) -- 技能图标 属性等组
    SetAnchorAndPivot(centerGroup, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(centerGroup,"centerGroup_UpStar")

    local equipDB = DB.GetOnceItemByKey1(nowEquipData["Id"])
    for i = 1, 2 do -- 人物星级提升
        local iconBg = GUI.ImageCreate(centerGroup, "icon_"..i,QualityRes[equipDB.Grade],(i-1.5)*204,30) -- 头像+星级框
        SetAnchorAndPivot(iconBg, UIAnchor.Top, UIAroundPivot.Top)

        local icon = GUI.ImageCreate(iconBg, "icon",equipDB.Icon,0,6,false,72,72)
        SetAnchorAndPivot(icon, UIAnchor.Top, UIAroundPivot.Top)

        for j = 0, MaxRank - 1 do -- 星星
            local star=GUI.ImageCreate(iconBg, "star"..j,"1801208420",-30+j*12,-4, false, 14, 14) -- 星背景
            SetAnchorAndPivot(star, UIAnchor.Bottom, UIAroundPivot.Bottom)
        end
        local rank = nowEquipData["EquipRank"] -- 获取灵宝的当前等级
        local maxRank = 0
        for i, v in pairs(EquipAttConfig) do
            if v.Id == tonumber(equipDB.Id) then
                maxRank = v.RankMax
                break
            end
        end
        rank = i == 1 and rank - 1 or rank
        for i = 0, maxRank - 1 do
            local star = GUI.GetChild(iconBg, "star"..i, false)
            if i < rank then
                GUI.ImageSetImageID(star, "1801202190")
            else
                GUI.ImageSetImageID(star, "1801202192")
            end
            GUI.SetVisible(star, true)
        end
        for i = maxRank, MaxRank - 1 do
            local star = GUI.GetChild(iconBg, "star"..i, false)
            GUI.SetVisible(star, false)
        end
    end

    local tipTop = GUI.ImageCreate(centerGroup, "tipTop","1800707050",0,50) -- 向右箭头
    SetAnchorAndPivot(tipTop, UIAnchor.Top, UIAroundPivot.Top)

    local starIconBg = GUI.ImageCreate(centerGroup, "levelIconBg","1800400050",-160,-30)
    SetAnchorAndPivot(starIconBg, UIAnchor.Center, UIAroundPivot.Center)

    local starIcon = GUI.ImageCreate(starIconBg, "levelIcon",yinYangIcon["yangIcon"],0,6,false,72,72) -- 问号图标
    SetAnchorAndPivot(starIcon, UIAnchor.Top, UIAroundPivot.Top)

    local five = wuXin[nowEquipData["EquipRank"] - 1]
    local equipRank = nowEquipData["Att"][five[1].."Level"]
    local starName = GUI.CreateStatic(starIconBg, "starName", five[3].."阵灵", 130, -20, 150, 50)
    SpiritualEquipUI.SetFont2(starName)
    GUI.SetColor(starName, ColorType_Red)

    local yinYang = ""
    if nowEquipData["Att"][five[1].."YinYang"] == 1 then
        yinYang = "Yang"
        GUI.ImageSetImageID(starIcon, yinYangIcon["yangIcon"])
    elseif nowEquipData["Att"][five[1].."YinYang"] == 2 then
        yinYang = "Yin"
        GUI.ImageSetImageID(starIcon, yinYangIcon["yinIcon"])
    end
    local str = yinYang == "Yang" and "阳属性：" or "阴属性："
    local attIsPct = nowEquipAttConfig[yinYang.."AttIsPct"] == 1 and math.abs(nowEquipData["Att"][five[1].."YinYangAtt"]) / 100 .. "%" or math.abs(nowEquipData["Att"][five[1].."YinYangAtt"])
    for i = 1, 3 do
        if nowEquipAttConfig[yinYang.."ActualInfo"][i] == "param" then
            str = str .. attIsPct
        else
            str = str .. nowEquipAttConfig[yinYang.."ActualInfo"][i]
        end
    end
    local describe = GUI.CreateStatic(starIconBg, "describe", str, 250, 45, 393, 81)
    SpiritualEquipUI.SetFont2(describe)
    GUI.StaticSetAlignment(describe, TextAnchor.UpperLeft)
    GUI.SetColor(describe, ColorType_White)

    local practiceLevel = GUI.CreateStatic(centerGroup, "practiceLevel", "修炼等级上限", -130, 70, 150, 50)
    SpiritualEquipUI.SetFont2(practiceLevel)
    GUI.SetColor(practiceLevel, ColorType_White)

    -- 旧的修炼等级
    local oldPracticeLevel = GUI.CreateStatic(practiceLevel, "oldPracticeLevel", nowConfig["RankConfig"][nowEquipData["EquipRank"]-1]["MaxLv"], 140, 0, 150, 50)
    SpiritualEquipUI.SetFont2(oldPracticeLevel)
    GUI.SetColor(oldPracticeLevel, ColorType_White)

    -- 向右箭头
    local narrow = GUI.ImageCreate(practiceLevel, "narrow", "1801208370", 215, 0)
    SetAnchorAndPivot(narrow, UIAnchor.Left, UIAroundPivot.Left)

    -- 提升后的修炼等级
    local newPracticeLevel = GUI.CreateStatic(practiceLevel, "PracticeLevel", nowConfig["RankConfig"][nowEquipData["EquipRank"]]["MaxLv"], 300, 0, 150, 50)
    SpiritualEquipUI.SetFont2(newPracticeLevel)
    GUI.SetColor(newPracticeLevel, ColorType_Green)

    local tip = GUI.CreateStatic(upStarSuccessBg, "tip","点击任意位置继续游戏",0,-60,250,50)
    SetAnchorAndPivot(tip, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.StaticSetFontSize(tip,22)

    GUI.RegisterUIEvent(upStarSuccessBg, UCE.PointerClick, "SpiritualEquipUI", "OnUpStarBgClick") -- 关闭事件
end

-- 关闭升星成功时弹出页面的事件
function SpiritualEquipUI.OnUpStarBgClick()
    GUI.Destroy("SpiritualEquipUI/panelBg/upStarSuccessBg") -- 这里销毁，防止同一窗口覆盖问题
    SpiritualEquipUI.SpiritualRefresh()
end

--创建左边修炼和五行共用的滑动列表
function SpiritualEquipUI.CreatePracticeStr()
    SpiritualEquipUI.RefreshLinBaoData()
    local practicePageLeft = _gt.GetUI("practicePageLeft")
    local scrollPassive = _gt.GetUI("scrollPassive")
    local scrollActiveBtn = _gt.GetUI("scrollActiveBtn")
    if practicePageLeft then
        if POrA == 1 then
            GUI.CheckBoxExSetCheck(scrollPassive, false)
            GUI.CheckBoxExSetCheck(scrollActiveBtn, true)
        elseif POrA == 2 then
            GUI.CheckBoxExSetCheck(scrollPassive, true)
            GUI.CheckBoxExSetCheck(scrollActiveBtn, false)
        end
        GUI.SetVisible(practicePageLeft, true)
        local practiceScroll = _gt.GetUI("practiceScroll")
        GUI.LoopScrollRectSetTotalCount(practiceScroll, #LingBaoData[POrA])
        GUI.LoopScrollRectRefreshCells(practiceScroll)
        return
    end
    local panelBg = _gt.GetUI("panelBg")
    local practicePageLeft = GUI.GroupCreate(panelBg, "practicePageLeft", 7, -2, 1197, 639);
    _gt.BindName(practicePageLeft, "practicePageLeft")

    --创建左边滑动列表
    local practiceScrBg = GUI.ImageCreate(practicePageLeft, "practiceScrBg", "1800400200", 72, 100, false, 295, 510);
    SetAnchorAndPivot(practiceScrBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local practiceScroll = GUI.LoopScrollRectCreate(
            practiceScrBg,
            "practiceSkillScroll",
            6,
            6,
            285,
            500,
            "SpiritualEquipUI",
            "CreatePracticeItem",
            "SpiritualEquipUI",
            "RefreshPracticeItem",
            0,
            false,
            Vector2.New(280, 100),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    _gt.BindName(practiceScroll, "practiceScroll")
    GUI.LoopScrollRectSetTotalCount(practiceScroll, #LingBaoData[POrA])
    GUI.LoopScrollRectRefreshCells(practiceScroll)
    -- 被动按钮
    local scrollPassive = GUI.CheckBoxExCreate(practiceScrBg, "scrollPassive", "1800402030", "1800402032", -70, -50, true, 142, 50, false);
    SetAnchorAndPivot(scrollPassive, UIAnchor.Top, UIAroundPivot.Top)
    GUI.RegisterUIEvent(scrollPassive, UCE.PointerClick, "SpiritualEquipUI", "OnScrollPassiveBtn")
    _gt.BindName(scrollPassive, "scrollPassive")

    -- 按钮上的字
    local passiveTxt = GUI.CreateStatic(scrollPassive, "passiveTxt", "被动", 0, 0, 160, 40)
    SpiritualEquipUI.SetFont(passiveTxt)

    -- 主动按钮
    local scrollActiveBtn = GUI.CheckBoxExCreate(practiceScrBg, "scrollActiveBtn", "1800402030", "1800402032", 70, -50, false, 142, 50, false);
    SetAnchorAndPivot(scrollActiveBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.RegisterUIEvent(scrollActiveBtn, UCE.PointerClick, "SpiritualEquipUI", "OnScrollActiveBtn")
    _gt.BindName(scrollActiveBtn, "scrollActiveBtn")

    -- 按钮上的字
    local activeTxt = GUI.CreateStatic(scrollActiveBtn, "activeTxt", "主动", 0, 0, 160, 40)
    SpiritualEquipUI.SetFont(activeTxt)
end

-- 列表上面的被动按钮点击
function SpiritualEquipUI.OnScrollPassiveBtn()

    local scrollPassive = _gt.GetUI("scrollPassive")
    local scrollActiveBtn = _gt.GetUI("scrollActiveBtn")

    GUI.CheckBoxExSetCheck(scrollPassive, true)
    GUI.CheckBoxExSetCheck(scrollActiveBtn, false)
    if LingBaoData[2][1] == nil then
        GUI.CheckBoxExSetCheck(scrollPassive, false)
        GUI.CheckBoxExSetCheck(scrollActiveBtn, true)
        CL.SendNotify(NOTIFY.ShowBBMsg, "您没有该类型的灵宝")
        return
    end
    if POrA == 2 then
        return
    end

    if scrollPassive and scrollActiveBtn then
        POrA = 2
        SelectList = nil
        SelectItemGuid = nil
        if nowPage == 2 then
            SpiritualEquipUI.RefreshPracticeRight()
        elseif nowPage == 3 then
            SpiritualEquipUI.RefreshRightFiveElements()
        end
    end
end

-- 列表上面的主动按钮点击
function SpiritualEquipUI.OnScrollActiveBtn()

    local scrollPassive = _gt.GetUI("scrollPassive")
    local scrollActiveBtn = _gt.GetUI("scrollActiveBtn")

    GUI.CheckBoxExSetCheck(scrollPassive, false)
    GUI.CheckBoxExSetCheck(scrollActiveBtn, true)

    if LingBaoData[1][1] == nil then
        GUI.CheckBoxExSetCheck(scrollPassive, true)
        GUI.CheckBoxExSetCheck(scrollActiveBtn, false)
        CL.SendNotify(NOTIFY.ShowBBMsg, "您没有该类型的灵宝")
        return
    end

    if POrA == 1 then
        return
    end
    if scrollPassive and scrollActiveBtn then
        POrA = 1
        SelectList = nil
        SelectItemGuid = nil
        if nowPage == 2 then
            SpiritualEquipUI.RefreshPracticeRight()
        elseif nowPage == 3 then
            SpiritualEquipUI.RefreshRightFiveElements()
        end
    end
end

function SpiritualEquipUI.CreatePracticeItem()
    local practiceScroll = _gt.GetUI("practiceScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(practiceScroll)
    local Index = tonumber(curCount) + 1
    local practiceItem = GUI.CheckBoxExCreate(practiceScroll, "practiceItem"..Index, "1800700030", "1800700040", 0, 0, false, 0, 0)
    GUI.RegisterUIEvent(practiceItem, UCE.PointerClick , "SpiritualEquipUI", "OnPracticeItemClick")
    _gt.BindName(practiceItem, "practiceItem"..Index)

    -- 灵宝图片
    local practiceIconBg = GUI.ImageCreate(practiceItem, "practiceIconBg", "1800400050", 10, 10, false, 80, 81);
    local practiceIcon = GUI.ImageCreate(practiceIconBg, "practiceIcon", "1900000000", 0, -1, false, 70, 70);
    SetAnchorAndPivot(practiceIcon, UIAnchor.Center, UIAroundPivot.Center)
    local inEquip = GUI.ImageCreate(practiceIconBg, "inEquip", "1800707290", 0, 0, false, 50, 50)
    UILayout.SetSameAnchorAndPivot(inEquip, UILayout.TopLeft)

    for i = 0, MaxRank - 1 do
        local star = GUI.ImageCreate(practiceItem, "star"..i, "1801202192", -37 + i * 17, -9, false, 20, 20)
        SetAnchorAndPivot(star, UIAnchor.Bottom, UIAroundPivot.Bottom)
    end

    -- 灵宝名字
    local particleName = GUI.CreateStatic(practiceItem, "particleName", "", 30, -20, 151, 40)
    SpiritualEquipUI.SetFont2(particleName)

    -- 灵宝等级
    local particleLevel = GUI.CreateStatic(practiceItem, "particleLevel", "", 0, 5, 88, 40)
    SpiritualEquipUI.SetFont2(particleLevel)

    return practiceItem
end

-- 左边滚动列表刷新
function SpiritualEquipUI.RefreshPracticeItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local info = LingBaoData[POrA][index]
    local dbData = DB.GetOnceItemByKey1(info.Id)
    GUI.SetData(item, "id", info.Id)
    local particleLevel = GUI.GetChild(item, "particleLevel", false)
    -- parduorupaduoru
    local equipRank = info["EquipRank"]

    -- 当前等级/最大等级
    GUI.StaticSetText(particleLevel, tostring(info["EquipLevel"]).."/" .. tostring(GeneralConfig["Grade"..tostring(dbData.Grade)]["RankConfig"][info.EquipRank]["MaxLv"]))

    if SelectList == nil or SelectListGuid == nil then
        SelectList = info.Id
        SelectListGuid = guid
        local equip = nil
        equip = LD.GetItemGuidsById(tonumber(SelectList), Bag)
        if equip == nil or equip.Count == 0 then
            equip = LD.GetItemGuidsById(tonumber(SelectList), EquipBag)
        end
        SelectEquipGuid = equip[0]
    end

    if tostring(SelectList) == tostring(info.Id) then
        GUI.CheckBoxExSetCheck(item, true)
    else
        GUI.CheckBoxExSetCheck(item, false)
    end

    -- 刷新icon和背景
    local practiceIconBg = GUI.GetChild(item, "practiceIconBg", false)
    local practiceIcon = GUI.GetChild(practiceIconBg, "practiceIcon", false)
    local inEquip = GUI.GetChild(practiceIconBg, "inEquip", false)
    GUI.ImageSetImageID(practiceIconBg, QualityRes[dbData.Grade])
    GUI.ImageSetImageID(practiceIcon, dbData.Icon)
    GUI.SetVisible(inEquip, false)
    for i, v in ipairs(LingBaoTB["Equip"]) do
        if v["Name"] == info.Name then
            GUI.SetVisible(inEquip, true)
            break
        end
    end
    -- 刷新名字
    local particleName = GUI.GetChild(item, "particleName", false)
    GUI.StaticSetText(particleName, info.Name)

    local rank = 0
    for i, v in pairs(EquipAttConfig) do
        if v.Id == tonumber(info.Id) then
            rank = v.RankMax
            break
        end
    end
    -- 刷新星级
    for i = 0, rank - 1 do
        local star = GUI.GetChild(item, "star"..i, false)
        if i < equipRank then
            GUI.ImageSetImageID(star, "1801202190")
        else
            GUI.ImageSetImageID(star, "1801202192")
        end
        GUI.SetVisible(star, true)
    end
    for i = rank, MaxRank - 1 do
        local star = GUI.GetChild(item, "star"..i, false)
        GUI.SetVisible(star, false)
    end
end

function SpiritualEquipUI.OnPracticeItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local id = GUI.GetData(item, "id")
    if SelectList ~= id or SelectListGuid ~= tostring(guid) then
        if id == "" or id == nil then
            id = LingBaoData[POrA].Id
        end

        GUI.CheckBoxExSetCheck(GUI.GetByGuid(SelectListGuid), false)
        GUI.CheckBoxExSetCheck(item, true)

        SelectList = id
        SelectListGuid = tostring(guid)

        local equip = LD.GetItemGuidsById(tonumber(SelectList), EquipBag)
        if equip == nil or equip.Count == 0 then
            equip = LD.GetItemGuidsById(tonumber(SelectList), Bag)
        end
        SelectEquipGuid = equip[0]
        SpiritualEquipUI.RefreshNowEquipData()

        if nowPage == 2 then
            SpiritualEquipUI.RefreshPracticeRight()
        elseif nowPage == 3 then
            SpiritualEquipUI.RefreshRightFiveElements()
        end
    else
        GUI.CheckBoxExSetCheck(item, true)
    end
end

--- 五行页面点击
function SpiritualEquipUI.OnFiveElementsClick()
    Parameter = nil
    if not SpiritualEquipUI.ResetLastSelectPage(pageNum.fiveElementsPage) then
        return
    end

    SpiritualEquipUI.InitFiveElementsData()
end

-- 五行数据刷新
function SpiritualEquipUI.InitFiveElementsData()
    --SelectList = nil
    --SelectListGuid = nil
    SpiritualEquipUI.FiveElementsRefresh()
end

-- 五行页面刷新
function SpiritualEquipUI.FiveElementsRefresh()

    SpiritualEquipUI.RefreshLinBaoData()

    if #LingBaoTB["Bag"] == 0 and #LingBaoTB["Equip"] == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先获得灵宝")
        SpiritualEquipUI.OnArtificeClick()
        return
    end
    if #LingBaoData[2] == 0 then
        POrA = 1
    elseif #LingBaoData[1] == 0 then
        POrA = 2
    end
    --local practiceScroll = _gt.GetUI("practiceScroll")
    --GUI.ScrollRectSetNormalizedPosition(practiceScroll,Vector2.New(0,0))    -- 滚动框归位
    local pageName = LabelList[pageNum.fiveElementsPage][4]
    local pageBg = _gt.GetUI(pageName)
    NowPart = NowPart == nil and 1 or NowPart
    if not pageBg then
        pageBg = SpiritualEquipUI.CreateFiveElementsPage(pageName)
    else
        GUI.SetVisible(pageBg,true)
    end
    SpiritualEquipUI.CreatePracticeStr()    -- 刷新滚动列表
    SpiritualEquipUI.RefreshRightFiveElements()
end

-- 五行页面
function SpiritualEquipUI.CreateFiveElementsPage(pageName)
    SpiritualEquipUI.CreatePracticeStr()    -- 刷新滚动列表
    local panelBg = _gt.GetUI("panelBg")
    local fiveElementsBg = GUI.GroupCreate(panelBg, pageName, 7, -2, 1197, 639);
    _gt.BindName(fiveElementsBg, pageName)

    ---- 中间逆转阴阳背景
    local reverseBg = GUI.GroupCreate(fiveElementsBg, "reverseBg", -20, 45, 392, 563)
    SetAnchorAndPivot(reverseBg, UIAnchor.Top, UIAroundPivot.Top)
    _gt.BindName(reverseBg, "reverseBg")
    GUI.SetVisible(reverseBg, false)

    GUI.ImageCreate(reverseBg, "iconBgBg", "1801720140", 0, 7, true)    -- 背景的背景

    -- 逆转阴阳图片
    local reverseIconBg = GUI.ImageCreate(reverseBg, "reverseIconBg", "1800400320", 0, 21, false, 80, 81);
    local reverseIcon = GUI.ImageCreate(reverseIconBg, "reverseIcon", "1900000000", 0, -1, false, 70, 70);
    SetAnchorAndPivot(reverseIcon, UIAnchor.Center, UIAroundPivot.Center)

    -- 逆转灵宝名字
    local reverseName = GUI.CreateStatic(reverseBg, "reverseName", "", 0, -145, 300, 50);
    SpiritualEquipUI.SetFont2(reverseName)
    GUI.StaticSetFontSize(reverseName, 24)
    GUI.StaticSetAlignment(reverseName, TextAnchor.MiddleCenter)
    GUI.SetColor(reverseName, ColorType_FontColor2)

    -- 逆转阴阳
    local reverseTitle = GUI.CreateStatic(reverseBg, "reverseTitle", "逆转两仪", 0, -50, 107, 50)
    SpiritualEquipUI.SetFont2(reverseTitle)
    GUI.StaticSetAlignment(reverseTitle, TextAnchor.MiddleCenter)
    GUI.ImageCreate(reverseTitle, "cutLine1", "1800700150", -130, 0, false, 150, 17)    -- 切线1
    GUI.ImageCreate(reverseTitle, "cutLine2", "1800700290", 130, 0, false, 150, 17)     -- 切线2

    -- 当前属性Icon
    local nowIconBg = GUI.ImageCreate(reverseBg, "nowIconBg", "1800400050", -140, 250, false, 70, 71);
    local nowIcon = GUI.ImageCreate(nowIconBg, "nowIcon", "1900000000", 0, -1, false, 60, 60);
    SetAnchorAndPivot(nowIcon, UIAnchor.Center, UIAroundPivot.Center)

    -- 当前属性文本
    local nowAttributeTxt = GUI.CreateStatic(reverseBg, "nowAttributeTxt", "", 38, 7, 280, 100, "system", true)
    SpiritualEquipUI.SetFont2(nowAttributeTxt)
    GUI.StaticSetFontSize(nowAttributeTxt, 20)

    local Arrow = GUI.ImageCreate(nowIconBg, "Arrow", "1801502120", 0,33,false, 45, 42)
    SetAnchorAndPivot(Arrow, UIAnchor.Bottom, UIAroundPivot.Bottom)

    -- 逆转属性Icon
    local reverseAttributeIconBg = GUI.ImageCreate(reverseBg, "reverseAttributeIconBg", "1800400050", -140, 350, false, 70, 71);
    local reverseAttributeIcon = GUI.ImageCreate(reverseAttributeIconBg, "reverseAttributeIcon", "1900000000", 0, -1, false, 60, 60);
    SetAnchorAndPivot(reverseAttributeIcon, UIAnchor.Center, UIAroundPivot.Center)

    -- 逆转属性文本
    local reverseAttributeTxt = GUI.CreateStatic(reverseBg, "reverseAttributeTxt", "", 39, 97, 280, 100, "system", true)
    SpiritualEquipUI.SetFont2(reverseAttributeTxt)
    GUI.StaticSetFontSize(reverseAttributeTxt, 20)

    GUI.ImageCreate(reverseBg, "cutLine", "1801401070", 0, 440, false, 360, 4)

    local maxShowTxt = GUI.CreateStatic(reverseBg, "maxShowTxt", "", 0, -10, 270, 100, "101")
    SpiritualEquipUI.SetFont2(maxShowTxt)
    GUI.StaticSetFontSize(maxShowTxt, 24)
    SetAnchorAndPivot(maxShowTxt, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.StaticSetAlignment(maxShowTxt, TextAnchor.MiddleCenter)
    GUI.SetVisible(maxShowTxt, false)
    -- 需要消耗的材料图片
    local materialIconBg = GUI.ImageCreate(reverseBg, "materialIconBg", "1800400050", 10, -10, false, 70, 71);
    SetAnchorAndPivot(materialIconBg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    local materialIcon = GUI.ImageCreate(materialIconBg, "materialIcon", "1900000000", 0, -1, false, 60, 60);
    SetAnchorAndPivot(materialIcon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(materialIcon, true)
    GUI.RegisterUIEvent(materialIcon, UCE.PointerClick, "SpiritualEquipUI", "MaterialsTips")

    -- 材料名字
    local materialName = GUI.CreateStatic(materialIconBg, "materialName", "", 185, 20, 300, 50);
    SpiritualEquipUI.SetFont2(materialName)

    -- 需要材料以及拥有材料
    local materialNeedAndHave = GUI.CreateStatic(materialIconBg, "materialNeedAndHave", "", 97, -23, 120, 50);
    SpiritualEquipUI.SetFont2(materialNeedAndHave)

    -- 灵宝逆转按钮
    local reverseBtn = GUI.ButtonCreate(reverseBg, "reverseBtn", "1800102090", 90, 0, Transition.ColorTint, "<color=#ffffff><size=26>逆转</size></color>", 140, 45, false);
    SetAnchorAndPivot(reverseBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ButtonSetOutLineArgs(reverseBtn, true, colorOutline, 1)
    GUI.SetIsOutLine(reverseBtn,true);
    GUI.SetOutLine_Distance(reverseBtn,1);
    GUI.RegisterUIEvent(reverseBtn, UCE.PointerClick, "SpiritualEquipUI", "OnReverseBtnClick")
    _gt.BindName(reverseBtn, "reverseBtn")

    ---- 五行逆转专门写一个
    local fiveRevereTxt = GUI.CreateStatic(reverseBg, "fiveRevereTxt", "", 0, -100, 355, 150, "101", true)
    SpiritualEquipUI.SetFont2(fiveRevereTxt)
    GUI.StaticSetAlignment(fiveRevereTxt, TextAnchor.MiddleLeft)
    GUI.SetVisible(fiveRevereTxt, false)
    GUI.StaticSetFontSize(fiveRevereTxt, 24)
    GUI.SetColor(fiveRevereTxt, ColorType_FontColor2)

    local fiveRevereTipsScr = GUI.ScrollRectCreate(reverseBg, "fiveRevereTipsScr", 0, 125, 355, 320, 0, false, Vector2.New(285, 26))
    SetAnchorAndPivot(fiveRevereTipsScr, UIAnchor.Center, UIAroundPivot.Center)

    local fiveRevereTips = GUI.CreateStatic(fiveRevereTipsScr, "fiveRevereTips", "", 0, 0, 355, 320, "101", true)
    SpiritualEquipUI.SetFont2(fiveRevereTips)
    GUI.StaticSetAlignment(fiveRevereTips, TextAnchor.UpperLeft)
    GUI.SetVisible(fiveRevereTips, false)
    ---- 中间升灵背景
    local levelUpBg = GUI.GroupCreate(fiveElementsBg, "levelUpBg", -20, 45, 392, 563)
    SetAnchorAndPivot(levelUpBg, UIAnchor.Top, UIAroundPivot.Top)
    _gt.BindName(levelUpBg, "levelUpBg")

    GUI.ImageCreate(levelUpBg, "iconBgBg", "1801720140", 0, 7, true)    -- 背景的背景

    -- 灵宝图片
    local levelUpIconBg = GUI.ImageCreate(levelUpBg, "levelUpIconBg", "1800400050", 0, 21, false, 80, 81)
    local levelUpIcon = GUI.ImageCreate(levelUpIconBg, "levelUpIcon", "1900000000", 0, -1, false, 70, 70)
    SetAnchorAndPivot(levelUpIcon, UIAnchor.Center, UIAroundPivot.Center)

    -- 灵宝名字
    local levelUpName = GUI.CreateStatic(levelUpBg, "levelUpName", "", 0, -148, 140, 50);
    SpiritualEquipUI.SetFont2(levelUpName)
    GUI.StaticSetAlignment(levelUpName, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(levelUpName, 24)
    GUI.SetColor(levelUpName, ColorType_FontColor2)

    -- 升级阵法
    local midLevelUpTxt = GUI.CreateStatic(levelUpBg, "midLevelUpTxt", "升级阵法", 0, -50, 107, 50);
    SpiritualEquipUI.SetFont2(midLevelUpTxt)
    GUI.StaticSetAlignment(midLevelUpTxt, TextAnchor.MiddleCenter)
    GUI.ImageCreate(midLevelUpTxt, "cutLine1", "1800700150", -130, 0, false, 150, 17)    -- 切线1
    GUI.ImageCreate(midLevelUpTxt, "cutLine2", "1800700290", 130, 0, false, 150, 17)     -- 切线2

    -- 属性1：
    local fiveElementsAttribute1 = GUI.CreateStatic(levelUpBg, "fiveElementsAttribute1", "", -50, 50, 240, 120)
    SpiritualEquipUI.SetFont2(fiveElementsAttribute1)
    GUI.StaticSetAlignment(fiveElementsAttribute1, TextAnchor.UpperLeft)

    -- 升级属性1绿字
    local fiveElementsAttribute1UpLevel = GUI.CreateStatic(fiveElementsAttribute1, "fiveElementsAttribute1UpLevel", "", 170, 0, 65, 120)
    SpiritualEquipUI.SetFont2(fiveElementsAttribute1UpLevel)
    GUI.SetColor(fiveElementsAttribute1UpLevel, ColorType_Green)
    GUI.StaticSetAlignment(fiveElementsAttribute1UpLevel, TextAnchor.UpperLeft)

    GUI.ImageCreate(levelUpBg, "cutLine", "1801401070", 0, 440, false, 360, 4)

    local maxShowTxt = GUI.CreateStatic(levelUpBg, "maxShowTxt", "", 0, -10, 270, 100, "101")
    SpiritualEquipUI.SetFont2(maxShowTxt)
    GUI.StaticSetFontSize(maxShowTxt, 24)
    SetAnchorAndPivot(maxShowTxt, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.StaticSetAlignment(maxShowTxt, TextAnchor.MiddleCenter)
    GUI.SetVisible(maxShowTxt, false)

    -- 需要消耗的材料图片
    local materialLevelUpIconBg = GUI.ImageCreate(levelUpBg, "materialLevelUpIconBg", "1800400050", 10, -10, false, 70, 71);
    SetAnchorAndPivot(materialLevelUpIconBg, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
    local materialLevelUpIcon = GUI.ImageCreate(materialLevelUpIconBg, "materialLevelUpIcon", "1900000000", 0, -1, false, 60, 60);
    SetAnchorAndPivot(materialLevelUpIcon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(materialLevelUpIcon, true)
    GUI.RegisterUIEvent(materialLevelUpIcon, UCE.PointerClick, "SpiritualEquipUI", "MaterialsTips")

    -- 材料名字
    local materialLevelUpName = GUI.CreateStatic(materialLevelUpIconBg, "materialLevelUpName", "", 110, 20, 142, 50);
    SpiritualEquipUI.SetFont2(materialLevelUpName)

    -- 需要材料以及拥有材料
    local levelUpNeedAndHave = GUI.CreateStatic(materialLevelUpIconBg, "levelUpNeedAndHave", "", 97, -23, 120, 50);
    SpiritualEquipUI.SetFont2(levelUpNeedAndHave)

    -- 灵宝升灵按钮
    local levelUpBtn = GUI.ButtonCreate(levelUpBg, "levelUpBtn", "1800102090", 90, -10, Transition.ColorTint, "<color=#ffffff><size=26>升级</size></color>", 140, 45, false);
    SetAnchorAndPivot(levelUpBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ButtonSetOutLineArgs(levelUpBtn, true, colorOutline, 1)
    GUI.SetIsOutLine(levelUpBtn,true);
    GUI.SetOutLine_Distance(levelUpBtn,1)
    GUI.RegisterUIEvent(levelUpBtn, UCE.PointerClick, "SpiritualEquipUI", "OnLevelUpBtnClick")
    _gt.BindName(levelUpBtn, "levelUpBtn")

    ---- 右边效果背景
    local rightFiveElementsBg = GUI.ImageCreate(fiveElementsBg, "rightFiveElementsBg", "1800400200", -80, 100, false, 330, 510);
    SetAnchorAndPivot(rightFiveElementsBg, UIAnchor.TopRight, UIAroundPivot.TopRight)
    _gt.BindName(rightFiveElementsBg, "rightFiveElementsBg")

    -- 升灵按钮
    local cLevelUpBtn = GUI.CheckBoxExCreate(rightFiveElementsBg, "cLevelUpBtn", "1800402030", "1800402032", 70, -50, true, 142, 50, false);
    SetAnchorAndPivot(cLevelUpBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.RegisterUIEvent(cLevelUpBtn, UCE.PointerClick, "SpiritualEquipUI", "OnCLevelUpBtnBtn")
    _gt.BindName(cLevelUpBtn, "cLevelUpBtn")

    -- 按钮上的字
    local levelUpTxt = GUI.CreateStatic(cLevelUpBtn, "levelUpTxt", "升级", 0, 0, 160, 40)
    SpiritualEquipUI.SetFont(levelUpTxt)

    -- 逆转按钮
    local cReverseBtn = GUI.CheckBoxExCreate(rightFiveElementsBg, "cReverseBtn", "1800402030", "1800402032", -70, -50, false, 142, 50, false);
    SetAnchorAndPivot(cReverseBtn, UIAnchor.Top, UIAroundPivot.Top)
    GUI.RegisterUIEvent(cReverseBtn, UCE.PointerClick, "SpiritualEquipUI", "OnReverseBtnBtn")
    _gt.BindName(cReverseBtn, "cReverseBtn")

    -- 按钮上的字
    local reverseTxt = GUI.CreateStatic(cReverseBtn, "reverseTxt", "逆转", 0, 0, 160, 40)
    SpiritualEquipUI.SetFont(reverseTxt)

    -- 灵宝效果文字
    local spiritualEffectStr = GUI.ScrollRectCreate(rightFiveElementsBg, "spiritualEffectStr", 0, 20, 320, 80, 0, false, Vector2.New(320, 300), UIAroundPivot.Top, UIAnchor.Top)
    SetAnchorAndPivot(spiritualEffectStr, UIAnchor.Top, UIAroundPivot.Top)
    local spiritualEffect = GUI.CreateStatic(spiritualEffectStr, "spiritualEffect", "", 0, 0, 320, 110, "system", true)
    SpiritualEquipUI.SetFont2(spiritualEffect)
    GUI.StaticSetAlignment(spiritualEffect, TextAnchor.UpperLeft)

    -- 五行阵的背景
    local fiveElementsBgBg = GUI.ImageCreate(rightFiveElementsBg, "fiveElementsBgBg", "1801720130", 0, 5, true)
    SetAnchorAndPivot(fiveElementsBgBg, UIAnchor.Center, UIAroundPivot.Center)

    -- 灵宝五行阵
    local itemXY = {{0, -120}, {-110, -30}, {-60, 100}, {60, 100}, {110, -30}, {0, 0}}
    local itemBg = {"1801720180", "1801720190", "1801720200", "1801720210", "1801720220", "1800400320"}
    for i = 1, 6 do
        local fiveElements = GUI.ItemCtrlCreate(fiveElementsBgBg, "fiveElements"..i, itemBg[i], itemXY[i][1], itemXY[i][2], 0, 0, true)
        SetAnchorAndPivot(fiveElements, UIAnchor.Center, UIAroundPivot.Center)
        GUI.RegisterUIEvent(fiveElements, UCE.PointerClick, "SpiritualEquipUI", "OnFiveElementsPartClick")
        _gt.BindName(fiveElements, "fiveElements"..i)
        GUI.SetData(fiveElements, "index", i)

        local fiveElementsIcon = GUI.ImageCreate(fiveElements, "fiveElementsIcon", "1800400070", 0, 0, false, 70, 70)
        SetAnchorAndPivot(fiveElementsIcon, UIAnchor.Center, UIAroundPivot.Center)

        local fiveElementsLevel = GUI.CreateStatic(fiveElementsIcon, "fiveElementsLevel", "10", 44, 34, 34, 36)
        SpiritualEquipUI.SetFont2(fiveElementsLevel)

        local fiveSelect = GUI.ImageCreate(fiveElements, "fiveSelect", i~=6 and"1800300110"or"1800400280", 0, 0, false, 85, 85)
        SetAnchorAndPivot(fiveSelect, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetVisible(fiveSelect, false)
    end

    -- ?按钮，点击打开tips
    local hintBtn = GUI.ButtonCreate(rightFiveElementsBg, "hintBtn", "1800702030", -140, -110, Transition.ColorTint);
    UILayout.SetSameAnchorAndPivot(hintBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(hintBtn, UCE.PointerClick, "SpiritualEquipUI", "OnHintBtnClick")

    -- 底下规则背景
    local ruleBg = GUI.ImageCreate(rightFiveElementsBg, "ruleBg", "1801720320", 0, 0, false, 320, 91)
    SetAnchorAndPivot(ruleBg, UIAnchor.Bottom, UIAroundPivot.Bottom)

    -- 规则描述文字
    local ruleTxt = GUI.CreateStatic(ruleBg, "ruleTxt", "", 5, 0, 300, 86, "system", true)
    GUI.SetColor(ruleTxt, ColorType_FontColor2)
    GUI.StaticSetFontSize(ruleTxt, 20)
    GUI.StaticSetAlignment(ruleTxt, TextAnchor.MiddleLeft)
    _gt.BindName(ruleTxt, "ruleTxt")
end

-- 右边五行页面刷新
function SpiritualEquipUI.RefreshRightFiveElements()
    --test(NowPart)
    SpiritualEquipUI.RefreshNowEquipData()
    SpiritualEquipUI.CreatePracticeStr()
    local rightFiveElementsBg = _gt.GetUI("rightFiveElementsBg")
    local spiritualEffectStr = GUI.GetChild(rightFiveElementsBg, "spiritualEffectStr", false)
    local spiritualEffect = GUI.GetChild(spiritualEffectStr, "spiritualEffect", false)

    --GUI.StaticSetText(spiritualEffect, "<color=#08AF00FF>灵宝效果：</color>"..nowEquipAttConfig["Tips"])
    GUI.StaticSetText(spiritualEffect, "<color=#08AF00FF>灵宝效果：</color>"..SpiritualEquipUI.OnSkillTipNtf(nowEquipAttConfig, nowEquipData["EquipLevel"]))

    local ruleTxt = _gt.GetUI("ruleTxt")

    if SelectFiveIndex == nil and nowPage == 3 then
        SelectFiveIndex = 1
        SpiritualEquipUI.OnFiveElementsPartClick(GUI.GetGuid(_gt.GetUI("fiveElements1")))
    end

    for i = 1, 6 do
        local fiveElements = _gt.GetUI("fiveElements"..i)
        local fiveElementsIcon = GUI.GetChild(fiveElements, "fiveElementsIcon", false)
        local fiveElementsLevel = GUI.GetChild(fiveElementsIcon, "fiveElementsLevel", false)
        if NowPart == 1 then
            GUI.ImageSetImageID(fiveElementsIcon, wuXin[i][4])
            GUI.SetVisible(fiveElementsLevel, true)
            GUI.StaticSetText(fiveElementsLevel, nowEquipData["Att"][wuXin[i][1].."Level"])
        else
            if nowEquipData["Att"][wuXin[i][1].."YinYang"] == 1 then
                GUI.ImageSetImageID(fiveElementsIcon, yinYangIcon["yangIcon"])
            elseif nowEquipData["Att"][wuXin[i][1].."YinYang"] == 2 then
                GUI.ImageSetImageID(fiveElementsIcon, yinYangIcon["yinIcon"])
            else
                GUI.ImageSetImageID(fiveElementsIcon, "1800400070")
            end
            GUI.SetVisible(fiveElementsLevel, false)
            if i == 6 then
                local yinYang = 0
                local flag = 0
                for i = 1, 5 do
                    --if nowEquipData["Att"][wuXin[i][1].."Unlock"] == 0 then
                    --    flag = 1
                    --    break
                    --end
                    if nowEquipData["Att"][wuXin[i][1].."YinYang"] == 2 then
                        yinYang = yinYang - 1
                    elseif nowEquipData["Att"][wuXin[i][1].."YinYang"] == 1 then
                        yinYang = yinYang + 1
                    else
                        flag = 1
                        break
                    end
                end
                if flag == 0 then
                    GUI.ImageSetImageID(fiveElementsIcon, yinYangFF[yinYang][3])
                else
                    GUI.ImageSetImageID(fiveElementsIcon, "1800400070")
                end
            end
        end
    end
    --local hintBtn = GUI.GetChild(rightFiveElementsBg, "hintBtn" ,false)
    if NowPart == 1 then
        local nowStr = nowEquipData["Att"]["WuXingLevel"] .. "级五行阵加成："
        if nowEquipData["Att"]["WuXingLevel"] == 0 then
            nowStr = nowStr .. "<color=#FF0000ff>未激活</color>"
        else
            nowStr = nowStr .. SpiritualEquipUI.GetAtt(nowEquipAttConfig, nowEquipData["Att"]["WuXingLevel"], "WuXing")
        end
        GUI.StaticSetText(ruleTxt, nowStr.."（升级所有阵位，可以提升五行阵等级）")
        --GUI.SetVisible(hintBtn, false)
        SpiritualEquipUI.RefreshLevelUp()
    else
        local yinYang = 0
        local flag = 0
        for i = 1, 5 do
            if nowEquipData["Att"][wuXin[i][1].."YinYang"] == 2 then
                yinYang = yinYang - 1
            elseif nowEquipData["Att"][wuXin[i][1].."YinYang"] == 1 then
                yinYang = yinYang + 1
            else
                flag = 1
                break
            end
        end
        local nowStr = ""
        if flag == 0 then
            nowStr = nowStr .. "<color=#08AF00FF>"..yinYangFF[yinYang][1] .. "：</color>"
            nowStr = nowStr .. string.sub(nowEquipAttConfig["Skill"..yinYangFF[yinYang][2].."Info"], 10), string.len(nowEquipAttConfig["Skill"..yinYangFF[yinYang][2].."Info"])
        else
            nowStr = "灵宝每次进阶可以激活<color=#FF0000ff>1个方位的阵灵，并随机获得1条两仪属性</color>激活所有阵灵后可以获得五行效果"
        end
        GUI.StaticSetText(ruleTxt, nowStr)
        --GUI.SetVisible(hintBtn, true)
        SpiritualEquipUI.RefreshReverse()
    end
end

-- 点击灵宝升阶事件
function SpiritualEquipUI.OnLevelUpBtnClick()
    -- 交给服务器了，要是以后需要再把注释取消掉
    --local five = wuXin[tonumber(SelectFiveIndex)][1]
    --local costItem = DB.GetOnceItemByKey2(nowConfig["AttConfig"]["Item"][five.."CostItem"])
    --local need = nowConfig["AttConfig"]["CostNum"][nowEquipData["Att"][five.."Level"] + 1] - nowConfig["AttConfig"]["CostNum"][nowEquipData["Att"][five.."Level"]]
    --local have = LD.GetItemCountById(costItem.Id)
    --if need <= have then
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "AttLevelUp", SelectEquipGuid, SelectFiveIndex)
    --else
    --    CL.SendNotify(NOTIFY.ShowBBMsg, "材料不足，无法升阶")
    --end
end

function SpiritualEquipUI.OnReverseBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "ConvertYinYang", SelectEquipGuid, SelectFiveIndex)
end

-- 点击五行阵的某一个阵眼
function SpiritualEquipUI.OnFiveElementsPartClick(guid)
    local clickFiveElements = GUI.GetByGuid(guid)
    local index = GUI.GetData(clickFiveElements, "index")

    if SelectFiveIndex ~= nil and SelectFiveIndex ~= index then
        local fiveElements = _gt.GetUI("fiveElements"..SelectFiveIndex)
        GUI.SetVisible(GUI.GetChild(fiveElements, "fiveSelect", false), false)

        GUI.SetVisible(GUI.GetChild(clickFiveElements, "fiveSelect", false), true)
        SelectFiveIndex = index

        -- 根据当前页面刷新
        if NowPart == 1 then
            SpiritualEquipUI.RefreshLevelUp()
        else
            SpiritualEquipUI.RefreshReverse()
        end
    end
end

-- 点击中间的五行阵（暂时不用）
--function SpiritualEquipUI.OnSectFiveElementsClick(guid)
--
--    SpiritualEquipUI.OnFiveElementsPartClick(guid)
--    if NowPart == 1 then
--        return
--    end
--    local panelBg = _gt.GetUI("panelBg")
--    local fiveElementsTips = GUI.ItemTipsCreate(panelBg, "fiveElementsTips", 0, 0,0)
--    SetAnchorAndPivot(fiveElementsTips, UIAnchor.Center, UIAroundPivot.Center)
--    GUI.SetIsRemoveWhenClick(fiveElementsTips, true)
--
--    --隐藏多余项
--    local ItemName = GUI.GetChild(fiveElementsTips, "ItemName")
--    if ItemName then
--        GUI.SetVisible(ItemName, false)
--    end
--    local ItemType = GUI.GetChild(fiveElementsTips, "ItemType")
--    if ItemType then
--        GUI.SetVisible(ItemType, false)
--    end
--    local itemShowLevel = GUI.GetChild(fiveElementsTips, "itemShowLevel")
--    if itemShowLevel then
--        GUI.SetVisible(itemShowLevel,false)
--    end
--    local ItemLevel = GUI.GetChild(fiveElementsTips, "ItemLevel")
--    if ItemLevel then
--        GUI.SetVisible(ItemLevel, false)
--    end
--    local itemLimit = GUI.GetChild(fiveElementsTips, "itemLimit")
--    if itemLimit then
--        GUI.SetVisible(itemLimit, false)
--    end
--
--    -- 五行阵icon
--    local fiveElementIconBg = GUI.TipsGetItemIcon(fiveElementsTips)
--    GUI.ItemCtrlSetElementValue(fiveElementIconBg, eItemIconElement.Icon, "1900000000")
--
--    -- XX的五行效果
--    local fiveElementName = GUI.CreateStatic(fiveElementIconBg, "fiveElementName", nowEquipData["Name"].."的五行效果", 190, -25, 270, 30)
--    SpiritualEquipUI.SetFont2(fiveElementName)
--    GUI.SetColor(fiveElementName, colorYellow2)
--
--    -- 已激活/未激活
--    local isLock = GUI.CreateStatic(fiveElementIconBg, "isLock", "未激活", 190, 22, 270, 40)
--    SpiritualEquipUI.SetFont2(isLock)
--    GUI.StaticSetFontSize(isLock, 24)
--    GUI.SetColor(isLock, ColorType_Red)
--
--    local yinYang = 0
--    local flag = 0
--    for i = 1, 5 do
--        if nowEquipData["Att"][wuXin[i][1].."Unlock"] == 0 then
--            flag = 1
--            break
--        end
--        if nowEquipData["Att"][wuXin[i][1].."YinYang"] == 2 then
--            yinYang = yinYang - 1
--        else
--            yinYang = yinYang + 1
--        end
--    end
--    if flag == 0 then
--        local nowStr = ""
--        nowStr = nowStr .. "<color=#FF0000ff>".. yinYangFF[yinYang][1] .. "</color>\n"
--        nowStr = nowStr .. string.sub(nowEquipAttConfig["Skill"..yinYangFF[yinYang][2].."Info"], 10, string.len(nowEquipAttConfig["Skill"..yinYangFF[yinYang][2].."Info"]))
--        GUI.StaticSetText(isLock ,yinYangFF[yinYang][1])
--        GUI.TipsAddLabel(fiveElementsTips, 20, nowStr, colorYellow2, true)
--    end
--    local str = ""
--    for i = 1, 6 do
--        local skillInfo = nowEquipAttConfig["Skill"..i.."Info"]
--        str = str .. "\n<color=#08AF00FF>"..string.sub(skillInfo, 0, 6).."</color>"..string.sub(skillInfo, 7, string.len(skillInfo))
--    end
--    GUI.TipsAddLabel(fiveElementsTips, 20, str, colorYellow2, true)
--end

-- 五行页面->中间升灵刷新
function SpiritualEquipUI.RefreshLevelUp()

    local levelUpBg = _gt.GetUI("levelUpBg")                                                        -- 大背景
    local levelUpIconBg = GUI.GetChild(levelUpBg, "levelUpIconBg", false)                           -- icon背景
    local levelUpIcon = GUI.GetChild(levelUpIconBg, "levelUpIcon", false)                           -- icon
    local levelUpName = GUI.GetChild(levelUpBg, "levelUpName", false)                               -- icon下面名字
    local fiveElementsAttribute1 = GUI.GetChild(levelUpBg, "fiveElementsAttribute1", false)         -- 属性1
    local fiveElementsAttribute1UpLevel = GUI.GetChild(fiveElementsAttribute1, "fiveElementsAttribute1UpLevel", false)

    if SelectFiveIndex == nil and nowPage == 3 then
        SelectFiveIndex = 1
        SpiritualEquipUI.OnFiveElementsPartClick(GUI.GetGuid(_gt.GetUI("fiveElements1")))
        return
    end

    local five = wuXin[tonumber(SelectFiveIndex)][1]
    GUI.ImageSetImageID(levelUpIcon, wuXin[tonumber(SelectFiveIndex)][4])
    GUI.StaticSetText(levelUpName,  tostring(nowEquipData["Att"][five.."Level"]).."级"..wuXin[tonumber(SelectFiveIndex)][3])

    local type = nowEquipAttConfig["Att"][five.."Type"]
    local levelMax = nowConfig["AttConfig"]["LevelMax"]
    if type == 1 then   -- 人物角色属性
        local showStr = ""
        local showStrGreen = ""
        for i = 1, #nowEquipAttConfig["Att"][five.."Att"] do
            local nowAttrId = nowEquipAttConfig["Att"][five.."Att"][i]
            local attData = DB.GetOnceAttrByKey1(nowAttrId)
            local att = nowEquipAttConfig["Att"][five.."IsPct"] == 1 and (tostring(nowEquipAttConfig["Att"][five.."LvDiff"]) * nowEquipData["Att"][five.."Level"] / 100) .. "%" or tostring(nowEquipAttConfig["Att"][five.."LvDiff"]) * nowEquipData["Att"][five.."Level"]
            showStr = showStr .. attData.ChinaName .. "：" .. att .. "\n"
            if nowEquipData["Att"][five.."Level"] == levelMax then -- 满级显示+0
                showStrGreen = showStrGreen .. "+0\n"
            else    -- 显示到下一级提升
                local upAtt = nowEquipAttConfig["Att"][five.."IsPct"] == 1 and (tostring(nowEquipAttConfig["Att"][five.."LvDiff"]) / 100) .. "%" or tostring(nowEquipAttConfig["Att"][five.."LvDiff"])
                showStrGreen = showStrGreen .. "+".. upAtt .. "\n"
            end
            GUI.StaticSetText(fiveElementsAttribute1, showStr)
            GUI.StaticSetText(fiveElementsAttribute1UpLevel, showStrGreen)
        end
    elseif type == 2 then   -- 技能表属性
        --local attData = DB.GetOnceSkillByKey1(nowAttrId)
        GUI.StaticSetText(fiveElementsAttribute1, "")
        GUI.StaticSetText(fiveElementsAttribute1UpLevel, "")
    elseif type == 3 then   -- buff表属性
        --local attData = DB.GetOnceBuffByKey1(nowAttrId)
        GUI.StaticSetText(fiveElementsAttribute1, "")
        GUI.StaticSetText(fiveElementsAttribute1UpLevel, "")
    else
        return
    end

    local materialLevelUpIconBg = GUI.GetChild(levelUpBg, "materialLevelUpIconBg", false)
    local materialLevelUpIcon = GUI.GetChild(materialLevelUpIconBg, "materialLevelUpIcon", false)
    local materialLevelUpName = GUI.GetChild(materialLevelUpIconBg, "materialLevelUpName", false)
    local levelUpNeedAndHave = GUI.GetChild(materialLevelUpIconBg, "levelUpNeedAndHave", false)
    local levelUpBtn = _gt.GetUI("levelUpBtn")
    local maxShowTxt = GUI.GetChild(levelUpBg, "maxShowTxt", false)
    if nowEquipData["Att"][five.."Level"] == levelMax then -- 已达到最高等级，最下面按钮与icon不显示
        GUI.SetVisible(materialLevelUpIconBg, false)
        GUI.SetVisible(levelUpBtn, false)
        GUI.SetVisible(maxShowTxt, true)
        GUI.StaticSetText(maxShowTxt, "该方位已提升到最高等级")
    elseif SelectFiveIndex == "6" then
        GUI.SetVisible(materialLevelUpIconBg, false)
        GUI.SetVisible(levelUpBtn, false)
        GUI.SetVisible(maxShowTxt, true)
        GUI.StaticSetText(maxShowTxt, "升级所有阵位，可以提升五行阵等级")
    else
        GUI.SetVisible(materialLevelUpIconBg, true)
        GUI.SetVisible(levelUpBtn, true)
        GUI.SetVisible(maxShowTxt, false)

        local costItem = DB.GetOnceItemByKey2(nowConfig["AttConfig"]["Item"][five.."CostItem"])
        GUI.ImageSetImageID(materialLevelUpIconBg, QualityRes[costItem.Grade])
        GUI.ImageSetImageID(materialLevelUpIcon, costItem.Icon)
        GUI.SetData(materialLevelUpIcon, "id", costItem.Id)
        GUI.StaticSetText(materialLevelUpName, costItem.Name)

        local need = nowConfig["AttConfig"]["CostNum"][nowEquipData["Att"][five.."Level"] + 1] - nowConfig["AttConfig"]["CostNum"][nowEquipData["Att"][five.."Level"]]
        local have = LD.GetItemCountById(costItem.Id)

        if need > have then
            GUI.SetColor(levelUpNeedAndHave, ColorType_Red)
        else
            GUI.SetColor(levelUpNeedAndHave, ColorType_FontColor2)
        end
        GUI.StaticSetText(levelUpNeedAndHave, tostring(have) .. "/" .. tostring(need))
    end
end

-- 五行页面->中间逆转刷新
function SpiritualEquipUI.RefreshReverse()

    if SelectFiveIndex == nil then
        return
    end

    -- 五行阵逆转
    if SelectFiveIndex == "6" then
        SpiritualEquipUI.RefreshFiveReverse()
        return
    end

    local reverseBg = _gt.GetUI("reverseBg")
    local reverseIconBg = GUI.GetChild(reverseBg, "reverseIconBg", false)                           -- icon背景
    local reverseIcon = GUI.GetChild(reverseIconBg, "reverseIcon", false)                           -- icon
    local reverseName = GUI.GetChild(reverseBg, "reverseName", false)                               -- icon下面名字

    local five = wuXin[tonumber(SelectFiveIndex)][1]

    if NowPart == 1 then
        GUI.ImageSetImageID(reverseIcon, wuXin[tonumber(SelectFiveIndex)][4])
    else
        if nowEquipData["Att"][wuXin[tonumber(SelectFiveIndex)][1].."YinYang"] == 1 then
            GUI.ImageSetImageID(reverseIcon, yinYangIcon["yangIcon"])
        elseif nowEquipData["Att"][wuXin[tonumber(SelectFiveIndex)][1].."YinYang"] == 2 then
            GUI.ImageSetImageID(reverseIcon, yinYangIcon["yinIcon"])
        else
            GUI.ImageSetImageID(reverseIcon, "1800400070")
        end
    end

    -- 隐藏一下奇怪的东西
    local fiveRevereTxt = GUI.GetChild(reverseBg, "fiveRevereTxt", false)   -- 当前五行效果
    local fiveRevereTipsScr = GUI.GetChild(reverseBg, "fiveRevereTipsScr", false)
    GUI.SetVisible(fiveRevereTxt, false)
    GUI.SetVisible(fiveRevereTipsScr, false)

    local cutLine = GUI.GetChild(reverseBg, "cutLine", false)
    GUI.SetVisible(cutLine, true)

    local reverseTitle = GUI.GetChild(reverseBg, "reverseTitle", false)
    GUI.StaticSetText(reverseTitle, "逆转两仪")

    -- 烫烫烫锟斤拷
    local materialIconBg = GUI.GetChild(reverseBg, "materialIconBg", false)
    local materialIcon = GUI.GetChild(materialIconBg, "materialIcon", false)
    local materialName = GUI.GetChild(materialIconBg, "materialName", false)
    local materialNeedAndHave = GUI.GetChild(materialIconBg, "materialNeedAndHave", false)
    local maxShowTxt = GUI.GetChild(reverseBg, "maxShowTxt", false)
    local reverseBtn = _gt.GetUI("reverseBtn")

    local nowIconBg = GUI.GetChild(reverseBg, "nowIconBg", false)
    local nowIcon = GUI.GetChild(nowIconBg, "nowIcon", false)
    local nowAttributeTxt = GUI.GetChild(reverseBg, "nowAttributeTxt", false)
    local reverseAttributeIconBg = GUI.GetChild(reverseBg, "reverseAttributeIconBg", false)
    local reverseAttributeIcon = GUI.GetChild(reverseAttributeIconBg, "reverseAttributeIcon", false)
    local reverseAttributeTxt = GUI.GetChild(reverseBg, "reverseAttributeTxt", false)

    local yinYang = nowEquipData["Att"][five.."YinYang"]
    if yinYang ~= 0 then
        GUI.SetVisible(nowIconBg, true)
        GUI.SetVisible(reverseAttributeIconBg, true)
        GUI.SetVisible(nowAttributeTxt, true)
        GUI.SetVisible(reverseAttributeTxt, true)

        local str = "<color=#66310eff>当前阵灵属性 "
        if yinYang == 1 then
            yinYang = "Yang"
            str = str .. "阳"
            GUI.ImageSetImageID(nowIcon, yinYangIcon["yangIcon"])
            GUI.StaticSetText(reverseName,  wuXin[tonumber(SelectFiveIndex)][3] .. "阵灵（阳）")
        elseif yinYang == 2 then
            yinYang = "Yin"
            str = str .. "阴"
            GUI.ImageSetImageID(nowIcon, yinYangIcon["yinIcon"])
            GUI.StaticSetText(reverseName,  wuXin[tonumber(SelectFiveIndex)][3] .. "阵灵（阴）")
        end
        local coef1 = math.abs(nowEquipAttConfig[yinYang.."AttCoef1"])
        local coef2 = math.abs(nowEquipAttConfig[yinYang.."AttCoef2"])
        if coef1 > coef2 then
            local ccc = coef1
            coef1 = coef2
            coef2 = ccc
        end
        local str2 = nowEquipAttConfig[yinYang.."AttIsPct"] == 1 and tostring(coef1 / 100) .. "%~" .. tostring(coef2 / 100) .. "%" or tostring(coef1) .. "~" .. tostring(coef2)
        str = str .. "</color><color=#08AF00FF>(" .. str2 .. ")</color>\n<color=#66310eff>"
        local attIsPct = nowEquipAttConfig[yinYang.."AttIsPct"] == 1 and tostring(math.abs(nowEquipData["Att"][five.."YinYangAtt"]) / 100) .. "%" or math.abs(nowEquipData["Att"][five.."YinYangAtt"])
        for i = 1, 3 do
            if nowEquipAttConfig[yinYang.."ActualInfo"][i] == "param" then
                str = str .. attIsPct
            else
                str = str .. nowEquipAttConfig[yinYang.."ActualInfo"][i]
            end
        end
        str = str .. "</color>"
        GUI.StaticSetText(nowAttributeTxt, str)

        yinYang = nowEquipData["Att"][five.."YinYang"]
        str = "<color=#08AF00FF>逆转阵灵属性 "
        if yinYang == 2 then
            str = str .. "阳\n"
            yinYang = "Yang"
            GUI.ImageSetImageID(reverseAttributeIcon, yinYangIcon["yangIcon"])
        else
            str = str .. "阴\n"
            yinYang = "Yin"
            GUI.ImageSetImageID(reverseAttributeIcon, yinYangIcon["yinIcon"])
        end
        str = str .. "</color><color=#ac7529ff>"
        local coef1 = math.abs(nowEquipAttConfig[yinYang.."AttCoef1"])
        local coef2 = math.abs(nowEquipAttConfig[yinYang.."AttCoef2"])
        if coef1 > coef2 then
            local ccc = coef1
            coef1 = coef2
            coef2 = ccc
        end
        local attIsPct = nowEquipAttConfig[yinYang.."AttIsPct"] == 1 and tostring(coef1 / 100) .. "%~" .. tostring(coef2 / 100) .. "%" or tostring(coef1) .. "~" .. tostring(coef2)
        for i = 1, 3 do
            if nowEquipAttConfig[yinYang.."ActualInfo"][i] == "param" then
                str = str .. attIsPct
            else
                str = str .. nowEquipAttConfig[yinYang.."ActualInfo"][i]
            end
        end
        str = str .. "</color>"
        GUI.StaticSetText(reverseAttributeTxt, str)

        GUI.SetVisible(maxShowTxt, false)
        GUI.SetVisible(materialIconBg, true)
        GUI.SetVisible(reverseBtn, true)
        local essenceData = DB.GetOnceItemByKey1(nowEquipAttConfig["EssenceId"])
        local need = nowConfig["ConvertConfig"]["CostNum"]
        local have = LD.GetItemCountById(essenceData.Id)

        GUI.ImageSetImageID(materialIconBg, QualityRes[essenceData.Grade])
        GUI.ImageSetImageID(materialIcon, essenceData.Icon)
        GUI.SetData(materialIcon, "id", essenceData.Id)
        GUI.StaticSetText(materialName, essenceData.Name)

        if need > have then
            GUI.SetColor(materialNeedAndHave, ColorType_Red)
        else
            GUI.SetColor(materialNeedAndHave, ColorType_FontColor2)
        end
        GUI.StaticSetText(materialNeedAndHave, tostring(have) .. "/" .. tostring(need))
    else
        GUI.StaticSetText(reverseName,  wuXin[tonumber(SelectFiveIndex)][3] .. "阵灵（未激活）")
        GUI.SetVisible(maxShowTxt, true)
        GUI.StaticSetText(maxShowTxt, "灵宝提升到"..(SelectFiveIndex+1).."阶，可以激活该方位的阵灵")
        GUI.SetVisible(materialIconBg, false)
        GUI.SetVisible(reverseBtn, false)
        GUI.SetVisible(nowIconBg, false)
        GUI.SetVisible(reverseAttributeIconBg, false)
        GUI.SetVisible(nowAttributeTxt, false)
        GUI.SetVisible(reverseAttributeTxt, false)
    end
end

function SpiritualEquipUI.RefreshFiveReverse()
    local reverseBg = _gt.GetUI("reverseBg")

    local materialIconBg = GUI.GetChild(reverseBg, "materialIconBg", false)
    local nowIconBg = GUI.GetChild(reverseBg, "nowIconBg", false)
    local reverseAttributeIconBg = GUI.GetChild(reverseBg, "reverseAttributeIconBg", false)
    local nowAttributeTxt = GUI.GetChild(reverseBg, "nowAttributeTxt", false)
    local reverseAttributeTxt = GUI.GetChild(reverseBg, "reverseAttributeTxt", false)
    local reverseBtn = _gt.GetUI("reverseBtn")
    local cutLine = GUI.GetChild(reverseBg, "cutLine", false)
    local maxShowTxt = GUI.GetChild(reverseBg, "maxShowTxt", false)
    GUI.SetVisible(materialIconBg, false)
    GUI.SetVisible(nowIconBg, false)
    GUI.SetVisible(reverseAttributeIconBg, false)
    GUI.SetVisible(nowAttributeTxt, false)
    GUI.SetVisible(reverseAttributeTxt, false)
    GUI.SetVisible(reverseBtn, false)
    GUI.SetVisible(cutLine, false)
    GUI.SetVisible(maxShowTxt, false)

    local reverseTitle = GUI.GetChild(reverseBg, "reverseTitle", false)
    GUI.StaticSetText(reverseTitle, "全部效果")

    local reverseIconBg = GUI.GetChild(reverseBg, "reverseIconBg", false)                           -- icon背景
    local reverseIcon = GUI.GetChild(reverseIconBg, "reverseIcon", false)                           -- icon
    local reverseName = GUI.GetChild(reverseBg, "reverseName", false)                               -- icon下面名字
    GUI.StaticSetText(reverseName,  nowEquipData["Name"].."的五行效果")

    local fiveRevereTxt = GUI.GetChild(reverseBg, "fiveRevereTxt", false)   -- 当前五行效果
    local fiveRevereTipsScr = GUI.GetChild(reverseBg, "fiveRevereTipsScr", false)
    local fiveRevereTips = GUI.GetChild(fiveRevereTipsScr, "fiveRevereTips", false) -- 五行效果详细信息
    GUI.SetVisible(fiveRevereTxt, true)
    GUI.SetVisible(fiveRevereTipsScr, true)
    GUI.SetVisible(fiveRevereTips, true)

    local yinYang = 0
    local flag = 0
    for i = 1, 5 do
        --if nowEquipData["Att"][wuXin[i][1].."Unlock"] == 0 then
        --    flag = 1
        --    break
        --end
        if nowEquipData["Att"][wuXin[i][1].."YinYang"] == 2 then
            yinYang = yinYang - 1
        elseif nowEquipData["Att"][wuXin[i][1].."YinYang"] == 1 then
            yinYang = yinYang + 1
        else
            flag = 1
            break
        end
    end
    local color1 = "#08AF00FF"
    local color2 = "#929292ff"
    if flag == 0 then
        local nowStr = ""
        nowStr = nowStr .. "<color=#08AF00FF>".. yinYangFF[yinYang][1] .. "</color>  "
        nowStr = nowStr .. string.sub(nowEquipAttConfig["Skill"..yinYangFF[yinYang][2].."Info"], 10, string.len(nowEquipAttConfig["Skill"..yinYangFF[yinYang][2].."Info"]))
        GUI.StaticSetText(fiveRevereTxt, nowStr)
        GUI.ImageSetImageID(reverseIcon, yinYangFF[yinYang][3])
    else
        GUI.StaticSetText(fiveRevereTxt, "<color=#ff0000>未激活</color>\n灵宝提升到6星可激活五行效果")
        GUI.ImageSetImageID(reverseIcon, "1800400070")
    end
    local str = ""
    for i = 1, 6 do
        local skillInfo = nowEquipAttConfig["Skill"..i.."Info"]
        local color = (flag == 0 and i==yinYangFF[yinYang][2]) and color1 or color2
        str = str .. "\n<color=" .. color ..">"..string.sub(skillInfo, 0, 6).."</color>"..string.sub(skillInfo, 7, string.len(skillInfo))
    end
    GUI.ScrollRectSetChildSize(fiveRevereTipsScr, Vector2.New(355, 360))
    GUI.ScrollRectSetVertical(fiveRevereTipsScr, true)
    GUI.StaticSetText(fiveRevereTips, str)
end

-- 升灵按钮点击
function SpiritualEquipUI.OnCLevelUpBtnBtn()
    local levelUpBtn = _gt.GetUI("cLevelUpBtn")
    local reverseBtn = _gt.GetUI("cReverseBtn")
    local reverseBg = _gt.GetUI("reverseBg")
    local levelUpBg = _gt.GetUI("levelUpBg")

    if levelUpBtn and reverseBtn then
        NowPart = 1
        GUI.CheckBoxExSetCheck(levelUpBtn, true)
        GUI.CheckBoxExSetCheck(reverseBtn, false)
        GUI.SetVisible(reverseBg, false)
        GUI.SetVisible(levelUpBg, true)
        SpiritualEquipUI.RefreshRightFiveElements()
    end
end

-- 逆转按钮点击
function SpiritualEquipUI.OnReverseBtnBtn()
    local levelUpBtn = _gt.GetUI("cLevelUpBtn")
    local reverseBtn = _gt.GetUI("cReverseBtn")
    local reverseBg = _gt.GetUI("reverseBg")
    local levelUpBg = _gt.GetUI("levelUpBg")

    if levelUpBtn and reverseBtn then
        NowPart = 2
        GUI.CheckBoxExSetCheck(levelUpBtn, false)
        GUI.CheckBoxExSetCheck(reverseBtn, true)
        GUI.SetVisible(reverseBg, true)
        GUI.SetVisible(levelUpBg, false)
        SpiritualEquipUI.RefreshRightFiveElements()
    end
end

function SpiritualEquipUI.OnHintBtnClick()
    local rightFiveElementsBg = _gt.GetUI("rightFiveElementsBg")
    local color = "<color=#08AF00FF>"
    local colorEnd = "</color>"
    local msg = "灵宝每次进阶升星，激活1个阵位阵灵的阴阳属性；\n6星灵宝会获得最终的五行效果；\n五行效果分为以下6种：\n"..color.."太阳"..colorEnd.."：五行阵灵5个均为阳\n"..color.."阳明"..colorEnd.."：五行阵灵4个为阳,1个为阴\n"..color.."少阳"..colorEnd.."：五行阵灵3个为阳,2个为阴\n"..color.."少阴"..colorEnd.."：五行阵灵2个为阳,3个为阴\n"..color.."厥阴"..colorEnd.."：五行阵灵1个为阳,4个为阴\n"..color.."太阴"..colorEnd.."：五行阵灵5个均为阴"
    local tips = GUI.TipsCreate(rightFiveElementsBg, "msg", 0, 0, 0, NowPart == 1 and 20 or 270, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(tips),false)
    GUI.SetIsRemoveWhenClick(tips, true)

    if NowPart == 1 then
        msg = "升级所有阵位，可以提升五行阵等级。\n被动灵宝，五行阵基础属性，需佩带后生效。\n主动灵宝，五行阵基础属性，不需要佩带，即可生效。"
        local tipsText = GUI.CreateStatic(tips, "tipsText", msg, 0, 0, 380, 179, "system", true)
        SpiritualEquipUI.SetFont2(tipsText)
        GUI.SetColor(tipsText, UIDefine.WhiteColor)
    else
        local tipsTitle = GUI.CreateStatic(tips, "tipsTitle", "阴阳五行阵", 0, -160, 152, 32)
        SpiritualEquipUI.SetFont2(tipsTitle)
        GUI.SetColor(tipsTitle, ColorType_FontColor1)
        GUI.StaticSetFontSize(tipsTitle, 26)
        GUI.StaticSetAlignment(tipsTitle, TextAnchor.MiddleCenter)
        local tipsText = GUI.CreateStatic(tips, "tipsText", msg, 0, 20, 368, 322, "system", true)
        SpiritualEquipUI.SetFont2(tipsText)
        GUI.SetColor(tipsText, UIDefine.WhiteColor)
    end
end

--- 炼化页面点击
function SpiritualEquipUI.OnArtificeClick()
    Parameter = nil
    if not SpiritualEquipUI.ResetLastSelectPage(pageNum.artificePage) then
        return
    end
    SelectList = nil
    SelectListGuid = nil
    SpiritualEquipUI.InitArtificeData()
end

function SpiritualEquipUI.ShopEquipAttConfigData()
    ShopEquipAttConfig = {}
    for i = 1, #EquipAttConfig do
        --dbData = DB.GetOnceItemByKey1(equipAttConfig["Id"])
        if EquipAttConfig[i]["Available"] then -- DB.GetOnceItemByKey1(EquipAttConfig[i]["Id"]).ShowType ~= "门派灵宝" and
            table.insert(ShopEquipAttConfig, i)
        end
    end
end

-- 炼化数据刷新
function SpiritualEquipUI.InitArtificeData()
    SpiritualEquipUI.ArtificeRefresh()
end

-- 炼化页面刷新
function SpiritualEquipUI.ArtificeRefresh()

    SpiritualEquipUI.RefreshLinBaoData()

    local pageName = LabelList[pageNum.artificePage][4]
    local pageBg = _gt.GetUI(pageName)

    -- 其他页面的东西关一下
    local practicePageLeft = _gt.GetUI("practicePageLeft")
    if practicePageLeft then
        GUI.SetVisible(practicePageLeft, false)
    end

    if not pageBg then
        SelectArtificeIconGuid = nil
        SelectArtificeIconIndex = nil
        pageBg = SpiritualEquipUI.CreateArtificePage(pageName)
    end
    local artificeScroll = _gt.GetUI("artificeScroll")
    GUI.LoopScrollRectSetTotalCount(artificeScroll, #ShopEquipAttConfig)
    GUI.LoopScrollRectRefreshCells(artificeScroll)
    GUI.SetVisible(pageBg,true)
end

-- 炼化页面
function SpiritualEquipUI.CreateArtificePage(pageName)

    local panelBg = _gt.GetUI("panelBg")
    local artificePage = GUI.GroupCreate(panelBg, pageName,0,0,1197,639)
    _gt.BindName(artificePage, pageName)

    local artificeBg = GUI.ImageCreate(artificePage, "artificeBg", "1800400010", 60, 15, false, 683, 564)
    SetAnchorAndPivot(artificeBg, UIAnchor.Left, UIAroundPivot.Left)
    _gt.BindName(artificeBg, "artificeBg")

    -- 炼化页面右边物品框
    local artificeScroll = GUI.LoopScrollRectCreate(
            artificeBg,
            "artificeScroll",
            -5,
            0,
            693,
            544,
            "SpiritualEquipUI",
            "CreateArtificeScroll",
            "SpiritualEquipUI",
            "RefreshArtificeScroll",
            0,
            false,
            Vector2.New(85, 85),
            7,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    GUI.ScrollRectSetChildSpacing(artificeScroll, Vector2.New(10, 10))
    _gt.BindName(artificeScroll, "artificeScroll")

    GUI.LoopScrollRectSetTotalCount(artificeScroll, #ShopEquipAttConfig)
    GUI.LoopScrollRectRefreshCells(artificeScroll)

    -- 详细信息背景
    local infoBg = GUI.ImageCreate(artificePage, "infoBg", "1800400010", -80, 54, false, 367, 339)
    SetAnchorAndPivot(infoBg, UIAnchor.TopRight, UIAroundPivot.TopRight)
    _gt.BindName(infoBg, "infoBg")

    -- 灵宝图片
    local artificeIconBg = GUI.ImageCreate(infoBg, "artificeIconBg", "1800400050", 110, 30, false, 80, 81);
    SetAnchorAndPivot(artificeIconBg, UIAnchor.Top, UIAroundPivot.Top)
    local artificeIcon = GUI.ImageCreate(artificeIconBg, "artificeIcon", "1900000000", 0, -1, false, 70, 70);
    SetAnchorAndPivot(artificeIcon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(artificeIcon, true)
    GUI.RegisterUIEvent(artificeIcon, UCE.PointerClick, "SpiritualEquipUI", "ArtificeIconClick")

    local have = GUI.ImageCreate(artificeIconBg, "have", "1801720250", 0, 0, false, 50, 47)
    SetAnchorAndPivot(have, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local haveTxt = GUI.CreateStatic(have,"haveTxt","", -17, 17,50, 47,"system",false)
    GUI.StaticSetAlignment(haveTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(haveTxt, 16)
    GUI.SetColor(haveTxt, ColorType_White)
    GUI.SetEulerAngles(haveTxt, Vector3.New(0, 0, 45))

    -- 灵宝名字
    local artificeName = GUI.CreateStatic(artificeIconBg, "artificeName", "", 110, -20, 120, 50);
    SpiritualEquipUI.SetFont2(artificeName)
    GUI.StaticSetFontSize(artificeName, 24)

    -- 主动灵宝/被动灵宝
    local artificeState = GUI.CreateStatic(artificeIconBg, "artificeState", "", 110, 20, 120, 50, "system", true)
    SpiritualEquipUI.SetFont2(artificeState)

    -- 分割线
    local cutLine = GUI.ImageCreate(infoBg, "cutLine", "1801401070", 0, -45, false, 360, 4);
    SetAnchorAndPivot(cutLine, UIAnchor.Center, UIAroundPivot.Center)

    -- 技能效果描述
    local artificeInfoTxtStr = GUI.ScrollRectCreate(infoBg, "artificeInfoTxtStr", 0, 130, 321, 148, 0, false, Vector2.New(321, 300), UIAroundPivot.Top, UIAnchor.Top)
    SetAnchorAndPivot(artificeInfoTxtStr, UIAnchor.Top, UIAroundPivot.Top)

    local artificeInfoTxt = GUI.CreateStatic(artificeInfoTxtStr, "artificeInfoTxt", "", 0, 35, 312, 148);
    SpiritualEquipUI.SetFont2(artificeInfoTxt)
    GUI.StaticSetAlignment(artificeInfoTxt, TextAnchor.UpperLeft)

    -- 花费文字
    local spendCostTxt = GUI.CreateStatic(artificePage, "spendCostTxt", "花费", 220, -180, 90, 27);
    SpiritualEquipUI.SetFont2(spendCostTxt)
    SetAnchorAndPivot(spendCostTxt, UIAnchor.Bottom, UIAroundPivot.Bottom)
    _gt.BindName(spendCostTxt, "spendCostTxt")

    local spendBg = GUI.ImageCreate(spendCostTxt, "spendBg", "1800700010", 140, -2, false, 240, 30);
    _gt.BindName(spendBg, "spendBg")
    -- 消耗的货币icon
    local spendCost = GUI.ImageCreate(spendBg, "spendCost", "1800408280", -4, 2, false, 37, 37);
    SetAnchorAndPivot(spendCost, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetIsRaycastTarget(spendCost, true)
    GUI.RegisterUIEvent(spendCost, UCE.PointerClick, "SpiritualEquipUI", "OnSpendCostClick")

    -- 花费的货币数量
    local spendNum = GUI.CreateStatic(spendBg, "spendNum", "", 0, 0, 200, 40, "system", true);		--银币消耗
    GUI.StaticSetFontSize(spendNum, 22)
    SetAnchorAndPivot(spendNum, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(spendNum, TextAnchor.MiddleCenter)
    _gt.BindName(spendNum, "spendNum")

    -- 拥有文字
    local haveCostTxt = GUI.CreateStatic(artificePage, "haveCostTxt", "拥有", 220, -140, 90, 27);
    SpiritualEquipUI.SetFont2(haveCostTxt)
    SetAnchorAndPivot(haveCostTxt, UIAnchor.Bottom, UIAroundPivot.Bottom)
    _gt.BindName(haveCostTxt, "haveCostTxt")

    -- 拥有背景
    local haveBg = GUI.ImageCreate(haveCostTxt, "haveBg", "1800700010", 140, -2, false, 240, 30);
    _gt.BindName(haveBg, "haveBg")
    -- 拥有的货币icon
    local haveCost = GUI.ImageCreate(haveBg, "haveCost", "1800408280", -4, 2, false, 37, 37);
    SetAnchorAndPivot(haveCost, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetIsRaycastTarget(haveCost, true)
    GUI.RegisterUIEvent(haveCost, UCE.PointerClick, "SpiritualEquipUI", "OnSpendCostClick")

    -- 拥有的货币数量
    local haveNum = GUI.CreateStatic(haveBg, "haveNum", "", 0, 0, 200, 40, "system", true);		--银币消耗
    GUI.StaticSetFontSize(haveNum, 22)
    SetAnchorAndPivot(haveNum, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(haveNum, TextAnchor.MiddleCenter)
    _gt.BindName(haveNum, "haveNum")

    -- 货币获取路径
    local moreHave = GUI.ButtonCreate(haveBg, "moreHave", "1800402060", 105,0,Transition.ColorTint, "", 34,33, false)
    -- 获取路径点击
    GUI.RegisterUIEvent(moreHave, UCE.PointerClick, "SpiritualEquipUI", "OnMoreHaveClick")

    -- 限时兑换按钮
    local exchangeBtn = GUI.ButtonCreate(artificePage, "exchangeBtn", "1800102090", 240, -50, Transition.ColorTint, "<color=#ffffff><size=26>特惠商店</size></color>", 160, 45, false);
    SetAnchorAndPivot(exchangeBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ButtonSetOutLineArgs(exchangeBtn, true, colorOutline, 1)
    GUI.SetIsOutLine(exchangeBtn,true)
    GUI.SetOutLine_Distance(exchangeBtn,1)
    GUI.RegisterUIEvent(exchangeBtn, UCE.PointerClick, "SpiritualEquipUI", "OnExchangeBtnClick")
    _gt.BindName(exchangeBtn, "exchangeBtn")

    -- 炼化按钮
    local artificeBtn = GUI.ButtonCreate(artificePage, "artificeBtn", "1800102090", 440, -50, Transition.ColorTint, "<color=#ffffff><size=26>炼化</size></color>", 160, 45, false);
    SetAnchorAndPivot(artificeBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ButtonSetOutLineArgs(artificeBtn, true, colorOutline, 1)
    GUI.SetIsOutLine(artificeBtn,true)
    GUI.SetOutLine_Distance(artificeBtn,1)
    GUI.RegisterUIEvent(artificeBtn, UCE.PointerClick, "SpiritualEquipUI", "OnArtificeBtnClick")
    _gt.BindName(artificeBtn, "artificeBtn")
end

function SpiritualEquipUI.CreateArtificeScroll()
    local artificeScroll =  _gt.GetUI("artificeScroll")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(artificeScroll) + 1

    local artificeIconBg = ItemIcon.Create(artificeScroll, "artificeIconBg"..curCount, 10, 10, 90,90)
    SetAnchorAndPivot(artificeIconBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(artificeIconBg, UCE.PointerClick , "SpiritualEquipUI", "OnArtificeIconClick")

    -- 拥有角标
    local have = GUI.ImageCreate(artificeIconBg, "have", "1801720250", 0, 0, false, 50, 47)
    SetAnchorAndPivot(have, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local haveTxt = GUI.CreateStatic(have,"haveTxt","拥有", -17, 17,50, 47,"system",false)
    GUI.StaticSetAlignment(haveTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(haveTxt, 16)
    GUI.SetColor(haveTxt, ColorType_White)
    GUI.SetEulerAngles(haveTxt, Vector3.New(0, 0, 45))

    -- 选中光标
    local selected = GUI.ImageCreate(artificeIconBg, "selected", "1800400280", 0, 0, false, 90, 90)
    SetAnchorAndPivot(selected, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(selected, false)

    return artificeIconBg
end

function SpiritualEquipUI.RefreshArtificeScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local equipAttConfig = EquipAttConfig[ShopEquipAttConfig[index]]

    local dbData = DB.GetOnceItemByKey1(equipAttConfig["Id"])
    GUI.SetData(item, "index", index)
    ItemIcon.SetEmpty(item)
    -- 刷新icon和背景
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, QualityRes[1])
    GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, dbData.Icon)

    -- 是否显示新品角标
    local have = GUI.GetChild(item, "have", false)
    local haveTxt = GUI.GetChild(have, "haveTxt", false)

    GUI.SetVisible(have, false)
    if equipAttConfig["NewArrival"] == 1 then
        GUI.SetVisible(have, false)
        GUI.ImageSetImageID(have, "1801720250")
        GUI.StaticSetText(haveTxt, "新品")
    end
    GUI.ItemCtrlSetIconGray(item, true)
    for i, v in pairs(LingBaoTB) do
        for k, j in ipairs(v) do
            if j.Id == equipAttConfig["Id"] then
                GUI.SetVisible(have, true)
                GUI.ImageSetImageID(have, "1801720240")
                GUI.StaticSetText(haveTxt, "拥有")
                GUI.ItemCtrlSetIconGray(item, false)
                GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, QualityRes[dbData.Grade])    -- 有的话再显示真正的品质背景
                break
            end
        end
    end
    if SelectArtificeIconGuid == guid then
        SpiritualEquipUI.RefreshInfoBg()
    end
    if SelectArtificeIconGuid == nil or SelectArtificeIconIndex == nil then
        SelectArtificeIconGuid = guid
        SelectArtificeIconIndex = index
        local selected = GUI.GetChild(item, "selected", false)
        GUI.SetVisible(selected, true)
        SpiritualEquipUI.RefreshInfoBg()
    end
end

function SpiritualEquipUI.ArtificeIconClick(guid)
    local artificeIcon = GUI.GetByGuid(guid)
    local id = GUI.GetData(artificeIcon, "id")
    SpiritualEquipUI.CreateItemTips(nil, DB.GetOnceItemByKey1(id), _gt.GetUI("panelBg"), 3)
end

-- 炼化右边点击事件
function SpiritualEquipUI.OnArtificeIconClick(guid)
    local item = GUI.GetByGuid(guid)
    local index = GUI.GetData(item, "index")
    if SelectArtificeIconIndex ~= index then
        local selected = GUI.GetChild(item, "selected", false)
        local lastSelected = GUI.GetChild(GUI.GetByGuid(SelectArtificeIconGuid), "selected", false)
        GUI.SetVisible(selected, true)
        GUI.SetVisible(lastSelected, false)
        SelectArtificeIconIndex = index
        SelectArtificeIconGuid = guid
        SpiritualEquipUI.RefreshInfoBg()
    end
end

-- 详细信息刷新
function SpiritualEquipUI.RefreshInfoBg()
    local equipAttConfig = EquipAttConfig[ShopEquipAttConfig[tonumber(SelectArtificeIconIndex)]]
    local dbData = DB.GetOnceItemByKey1(equipAttConfig["Id"])

    local infoBg = _gt.GetUI("infoBg")
    local artificeIconBg = GUI.GetChild(infoBg, "artificeIconBg", false)
    local artificeIcon = GUI.GetChild(artificeIconBg, "artificeIcon", false)
    local artificeName = GUI.GetChild(artificeIconBg, "artificeName", false)
    local artificeState = GUI.GetChild(artificeIconBg, "artificeState", false)
    local artificeInfoTxtStr = GUI.GetChild(infoBg, "artificeInfoTxtStr", false)
    local artificeInfoTxt = GUI.GetChild(artificeInfoTxtStr, "artificeInfoTxt", false)

    GUI.ImageSetImageID(artificeIcon, dbData.Icon)
    GUI.SetData(artificeIcon, "id", dbData.Id)
    GUI.ImageSetImageID(artificeIconBg, QualityRes[dbData.Grade])

    -- 是否显示新品角标
    local have = GUI.GetChild(artificeIconBg, "have", false)
    local haveTxt = GUI.GetChild(have, "haveTxt", false)

    GUI.SetVisible(have, false)
    if equipAttConfig["NewArrival"] == 1 then
        GUI.SetVisible(have, false)
        GUI.ImageSetImageID(have, "1801720250")
        GUI.StaticSetText(haveTxt, "新品")
    end
    for i, v in pairs(LingBaoTB) do
        for k, j in ipairs(v) do
            if j.Id == equipAttConfig["Id"] then
                GUI.SetVisible(have, true)
                GUI.ImageSetImageID(have, "1801720240")
                GUI.StaticSetText(haveTxt, "拥有")
                break
            end
        end
    end

    GUI.StaticSetText(artificeName, dbData.Name)
    GUI.StaticSetText(artificeState, "<color=#08AF00FF>" .. dbData.ShowType .. "</color>")
    local str = "技能效果：" .. equipAttConfig["Tips"]
    GUI.StaticSetText(artificeInfoTxt, str)

    local costData = DB.GetOnceItemByKey2(equipAttConfig["ActivateMaterial"][1])
    -- 花费
    local spend = equipAttConfig["ActivateMaterial"][2]
    local spendBg = _gt.GetUI("spendBg")
    local spendCost = GUI.GetChild(spendBg, "spendCost", false)
    local spendNum = GUI.GetChild(spendBg, "spendNum", false)
    GUI.ImageSetImageID(spendCost, costData.Icon)
    GUI.StaticSetText(spendNum, spend)

    -- 拥有
    local haveSum = LD.GetItemCountById(costData.Id)
    local haveBg = _gt.GetUI("haveBg")
    local haveCost = GUI.GetChild(haveBg, "haveCost", false)
    local haveNum = GUI.GetChild(haveBg, "haveNum", false)

    GUI.ImageSetImageID(haveCost, costData.Icon)
    GUI.StaticSetText(haveNum, haveSum)

    local spendCostTxt = _gt.GetUI("spendCostTxt")
    local haveCostTxt = _gt.GetUI("haveCostTxt")
    if type(spend) == "string" then
        GUI.SetVisible(spendCostTxt, false)
        GUI.SetVisible(haveCostTxt, false)
    else
        GUI.SetVisible(spendCostTxt, true)
        GUI.SetVisible(haveCostTxt, true)
        if haveSum < spend then
            GUI.SetColor(spendNum, ColorType_Red)
        else
            GUI.SetColor(spendNum, ColorType_White)
        end
    end
end

function SpiritualEquipUI.OnSpendCostClick(guid)
    --local panelBg = _gt.GetUI("panelBg")
    local icon = GUI.GetByGuid(guid)
    Tips.CreateHint("可通过商城、兑换商店、折扣商店获得", icon, 0,-60, UILayout.Top,450)
end
-- 获取途径按钮
function SpiritualEquipUI.OnMoreHaveClick()
    --local equipAttConfig = EquipAttConfig[ShopEquipAttConfig[tonumber(SelectArtificeIconIndex)]]
    --local costData = DB.GetOnceItemByKey2(equipAttConfig["ActivateMaterial"][1])
    GUI.OpenWnd("MallUI", "灵宝碎片包")   -- 往商城跳转
end

-- 限时兑换按钮
function SpiritualEquipUI.OnExchangeBtnClick()
    GUI.OpenWnd("DiscountMallUI")
end

-- 炼化按钮
function SpiritualEquipUI.OnArtificeBtnClick()
    local equipAttConfig = EquipAttConfig[ShopEquipAttConfig[tonumber(SelectArtificeIconIndex)]]
    for i, v in pairs(LingBaoTB) do
        for k, j in ipairs(v) do
            if j.Id == equipAttConfig["Id"] then
                CL.SendNotify(NOTIFY.ShowBBMsg, "你已经拥有这个灵宝了")
                return
            end
        end
    end
    if string.find(equipAttConfig["KeyName"], "门派灵宝") then
        if sectConfig ~= nil and sectConfig["KeyName"] == equipAttConfig["KeyName"] then
            SpiritualEquipUI.OnSectItemClick()
        else
            CL.SendNotify(NOTIFY.ShowBBMsg, "该灵宝不属于本门派灵宝，无法炼化")
        end
        return
    end
    --local costData = DB.GetOnceItemByKey2(equipAttConfig["ActivateMaterial"][1])
    --local haveSum = LD.GetItemCountById(costData.Id)
    --local spend = equipAttConfig["ActivateMaterial"][2]
    --if haveSum < spend then
    --    CL.SendNotify(NOTIFY.ShowBBMsg, costData.Name.."数量不足")
    --    SpiritualEquipUI.MaterialsTips(costData.Id)
    --else
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "Activate", equipAttConfig["KeyName"])
    --end
end

function SpiritualEquipUI.MaterialsTips(guid)
    local itemId = GUI.GetData(GUI.GetByGuid(guid), "id")
    local panelBg = _gt.GetUI("panelBg")
    local itemTips = Tips.CreateByItemId(itemId, panelBg, "MaterialsTips",60,10,50)
    GUI.SetData(itemTips,"ItemId",itemId)
    _gt.BindName(itemTips,"itemTips")

    local wayBtn=GUI.ButtonCreate(itemTips,"wayBtn","1800402110",0,-10,Transition.ColorTint,"获得途径", 150, 50, false)
    SetAnchorAndPivot(wayBtn,UIAnchor.Bottom,UIAroundPivot.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"SpiritualEquipUI","OnClickWayBtn")
    GUI.AddWhiteName(itemTips, GUI.GetGuid(wayBtn))
end
---- 门派灵宝页面
-- 点击门派灵宝事件
function SpiritualEquipUI.OnSectItemClick(guid)
    local itemData = LD.GetItemDataByIndex(5, EquipBag)
    if itemData ~= nil and guid ~= nil then
        SpiritualEquipUI.OnSpiritualEquipItemClick(guid)
        return
    end
    if sectConfig["Available"] == false then    -- 如果门派灵宝不可获取的话就这么显示
        CL.SendNotify(NOTIFY.ShowBBMsg, "门派灵宝暂未开启")
        return
    end
    local sectItemC = _gt.GetUI("sectItemC")
    if sectItemC == nil then
        SpiritualEquipUI.CreateSectItem()
    else
        GUI.SetVisible(sectItemC, true)
    end

    SpiritualEquipUI.RefreshSectItem()
end

function SpiritualEquipUI.CreateSectItem()
    local panelBg = _gt.GetUI("panelBg")

    local sectItemPage = GUI.GroupCreate(panelBg, "sectItemC", 0, -24, 1197, 639)
    _gt.BindName(sectItemPage, "sectItemC")
    GUI.SetVisible(sectItemPage, true)
    local sectItemCover = GUI.ImageCreate(sectItemPage, "sectItemCover", "1800400220", 0, 0, false, 2000, 2000)
    UILayout.SetAnchorAndPivot(sectItemCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(sectItemCover, true)
    _gt.BindName(sectItemCover, "sectItemCover")

    -- 背景
    local sectItemBg = GUI.ImageCreate(sectItemCover, "sectItemBg", "1801720110", 0, -70)
    UILayout.SetSameAnchorAndPivot(sectItemBg, UILayout.Center)
    _gt.BindName(sectItemBg, "sectItemBg")

    -- 关闭按钮
    local closeBtn = GUI.ButtonCreate(sectItemBg, "closeBtn", "1800807030", -40, 60, Transition.ColorTint, "", 0, 0, true)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "SpiritualEquipUI", "OnSectItemExit")

    local itemXY = {{0, -180}, {-170, 0}, {170, 0}, {0, 170}}
    for i = 1, 4 do
        local sectPart = GUI.ImageCreate(sectItemBg, "sectPart"..i, "1801720220", itemXY[i][1], itemXY[i][2], false, 106, 106)
        SetAnchorAndPivot(sectPart, UIAnchor.Center, UIAroundPivot.Center)
        local sectPartIcon = GUI.ImageCreate(sectPart, "sectPartIcon"..i, "1801720220",0, 0, false, 103, 103)
        SetAnchorAndPivot(sectPartIcon, UIAnchor.Center, UIAroundPivot.Center)

        -- 角标背景
        local mark = GUI.ImageCreate(sectPart, "mark"..i, "1801720260", 2, 2, false, 65, 65)
        SetAnchorAndPivot(mark, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        -- 角标文字
        local markTxt = GUI.CreateStatic(mark, "markTxt", "", -10, 24,50, 47,"101", false)
        GUI.StaticSetAlignment(markTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(markTxt, 16)
        GUI.SetColor(markTxt, ColorType_White)
        GUI.SetEulerAngles(markTxt, Vector3.New(0, 0, 45))
        GUI.SetIsOutLine(markTxt, true)
        GUI.SetOutLine_Distance(markTxt, 2)
        GUI.SetOutLine_Color(markTxt, colorDark)

        -- 名字背景
        local sectPartNameBg = GUI.ImageCreate(sectPart, "sectPartNameBg"..i, "1801401130", 0, 0, false, 123, 50)
        SetAnchorAndPivot(sectPartNameBg, UIAnchor.Bottom, UIAroundPivot.Center)

        -- 名字
        local sectPartName = GUI.CreateStatic(sectPartNameBg, "sectPartName"..i, "", 0, 0, 140, 50, "system", false)
        SpiritualEquipUI.SetFont2(sectPartName)
        GUI.StaticSetAlignment(sectPartName, TextAnchor.MiddleCenter)
        GUI.SetColor(sectPartName, ColorType_White)
    end

    -- 门派灵宝名字背景
    local sectNameBg = GUI.ImageCreate(sectItemBg, "sectNameBg", "1801720230", 0, 60, false, 134, 40)
    SetAnchorAndPivot(sectNameBg, UIAnchor.Center, UIAroundPivot.Center)

    -- 门派灵宝名字
    local sectName = GUI.CreateStatic(sectNameBg, "sectName", "", 0, 0, 140, 50, "system", false)
    SpiritualEquipUI.SetFont2(sectName)
    GUI.StaticSetFontSize(sectName, 24)
    GUI.StaticSetAlignment(sectName, TextAnchor.MiddleCenter)

    local sectIconBg = GUI.ImageCreate(sectItemBg, "sectIconBg", "1801720220", 0, 0, false, 94, 94)
    SetAnchorAndPivot(sectIconBg, UIAnchor.Center, UIAroundPivot.Center)
    local sectIcon = GUI.ImageCreate(sectIconBg, "sectIcon", "1801720220",0, 0, false, 91, 91)
    SetAnchorAndPivot(sectIcon, UIAnchor.Center, UIAroundPivot.Center)

    local str = "需以上灵宝提升到6星，方可探寻门派灵宝"
    local tipsTxt = GUI.CreateStatic(sectItemBg, "tipsTxt", str, 0, 40, 600, 50, "101", true)
    SpiritualEquipUI.SetFont(tipsTxt)
    GUI.SetColor(tipsTxt,ColorType_White)
    SetAnchorAndPivot(tipsTxt, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.SetVisible(tipsTxt, false)
    _gt.BindName(tipsTxt, "tipsTxt")

    local tipsIcon = GUI.ImageCreate(tipsTxt, "tipsIcon", "1800607040", 40, 0, true)
    SetAnchorAndPivot(tipsIcon, UIAnchor.Left, UIAroundPivot.Center)

    local activationBtn = GUI.ButtonCreate(sectItemBg, "activationBtn", "1800102090", 0, 50, Transition.ColorTint, "<color=#ffffff><size=26>激活</size></color>", 160, 45, false);
    SetAnchorAndPivot(activationBtn, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.ButtonSetOutLineArgs(activationBtn, true, colorOutline, 1)
    GUI.SetIsOutLine(activationBtn,true)
    GUI.SetOutLine_Distance(activationBtn,1)
    GUI.RegisterUIEvent(activationBtn, UCE.PointerClick, "SpiritualEquipUI", "OnActivationBtnClick")
    _gt.BindName(activationBtn, "activationBtn")
end

function SpiritualEquipUI.RefreshSectItem()
    local sectItemBg = _gt.GetUI("sectItemBg")
    local flag = 0  -- 判断是否满足全部条件
    for i = 1, #sectConfig["ActivateMaterial"] do
        if type(sectConfig["ActivateMaterial"][i]) ~= "string" then
            break
        end
        local sectPartDB = DB.GetOnceItemByKey2(sectConfig["ActivateMaterial"][i])
        -- 设置图片icon
        local sectPart = GUI.GetChild(sectItemBg, "sectPart"..i, false)
        local sectPartIcon = GUI.GetChild(sectPart, "sectPartIcon"..i, false)
        GUI.ImageSetImageID(sectPartIcon, sectPartDB.Icon)

        -- 设置灵宝名字
        local sectPartNameBg = GUI.GetChild(sectPart, "sectPartNameBg"..i, false)
        local sectPartName = GUI.GetChild(sectPartNameBg, "sectPartName"..i, false)
        GUI.StaticSetText(sectPartName, sectPartDB.Name)

        local mark = GUI.GetChild(sectPart, "mark"..i, false)
        local markTxt = GUI.GetChild(mark, "markTxt", false)
        local num = LD.GetItemCountById(sectPartDB.Id, Bag) + LD.GetItemCountById(sectPartDB.Id, EquipBag)
        if num > 0 then
            local equipData = LD.GetItemGuidsById(sectPartDB.Id, Bag)
            local itemData = nil
            if equipData == nil or equipData.Count == 0 then
                equipData = LD.GetItemGuidsById(sectPartDB.Id, EquipBag)
                itemData = LD.GetItemDataByGuid(tostring(equipData[0]), EquipBag)
            else
                itemData = LD.GetItemDataByGuid(tostring(equipData[0]), Bag)
            end
            local EquipRank = itemData:GetIntCustomAttr("EquipRank")
            if EquipRank >= EquipSchoolEquipActivateLevel[i] then
                GUI.StaticSetText(markTxt, "已达成")
                GUI.ImageSetImageID(mark, "1801720260")
                GUI.SetVisible(mark, true)
                flag = flag + 1
            else
                GUI.SetVisible(mark, false)
            end
        else
            GUI.StaticSetText(markTxt, "未拥有")
            GUI.ImageSetImageID(mark, "1801720270")
            GUI.SetVisible(mark, true)
        end
    end

    local sectNameBg = GUI.GetChild(sectItemBg, "sectNameBg", false)
    local sectName = GUI.GetChild(sectNameBg, "sectName", false)
    local sectDB = DB.GetOnceItemByKey1(sectConfig["Id"])
    GUI.StaticSetText(sectName, sectDB.Name)

    local sectIconBg = GUI.GetChild(sectItemBg, "sectIconBg", false)
    local sectIcon = GUI.GetChild(sectIconBg, "sectIcon", false)
    GUI.ImageSetImageID(sectIcon, sectDB.Icon)

    local tipsTxt = _gt.GetUI("tipsTxt")
    local activationBtn = _gt.GetUI("activationBtn")
    if flag == 4 then
        GUI.SetVisible(tipsTxt, false)
        GUI.SetVisible(activationBtn, true)
    else
        GUI.SetVisible(tipsTxt, true)
        GUI.SetVisible(activationBtn, false)
    end
end

function SpiritualEquipUI.OnActivationBtnClick()
    local guids = {}
    for i = 1, 4 do
        local sectPartDB = DB.GetOnceItemByKey2(sectConfig["ActivateMaterial"][i])
        local equipData = LD.GetItemGuidsById(sectPartDB.Id, Bag)
        if equipData.Count == 0 then
            equipData = LD.GetItemGuidsById(sectPartDB.Id, EquipBag)
        end
        guids[i] = tostring(equipData[0])
    end

    if sectConfig ~= nil then
        CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "Activate", sectConfig["KeyName"], guids[1], guids[2], guids[3], guids[4])
    end
    SpiritualEquipUI.OnSectItemExit()
end

function SpiritualEquipUI.OnSectItemExit()
    local sectItemC = _gt.GetUI("sectItemC")
    GUI.Destroy(sectItemC)
end

--- 分解页面（改到了一个新的UI中）
function SpiritualEquipUI.OnBrokeBtnClick(guid, f)
    guid = f == nil and TipsConfig["itemData"].guid or guid
    GetWay.Def[1].jump("SpiritualEquipBrkUI", 1, guid)
    --if f == nil and TipsConfig == nil then
    --    test("分解页面数据为空！")
    --    return
    --end
    --
    --local panelBg = _gt.GetUI("panelBg")
    --
    --local brokeCover = GUI.ImageCreate(panelBg, "brokeCover", "1800400220", 0, -32, false, 2000, 2000)
    --UILayout.SetAnchorAndPivot(brokeCover, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.SetIsRaycastTarget(brokeCover, true)
    --_gt.BindName(brokeCover, "brokeCover")
    --
    ---- 背景
    --local brokeBg = GUI.ImageCreate(brokeCover, "brokeBg", "1800600182", 0, 0, false,530, 350)
    --UILayout.SetSameAnchorAndPivot(brokeBg, UILayout.Center)
    --_gt.BindName(brokeBg, "brokeBg")
    --
    --local rightBg = GUI.ImageCreate(brokeBg, "RightBg", "1800600181", 0, -9.5, false, 225, 40)
    --SetAnchorAndPivot(rightBg, UIAnchor.TopRight, UIAroundPivot.TopRight)
    --
    --local leftBg = GUI.ImageCreate(brokeBg, "LeftBg", "1800600180", 0, -9.5, false, 225, 40)
    --SetAnchorAndPivot(leftBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    --
    ---- 标题底板
    --local titleBg = GUI.ImageCreate(brokeBg, "titleBg", "1800600190", 0, -10, false, 230, 50)
    --SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Top)
    --
    ---- 标题
    --local titleTxt = GUI.CreateStatic(titleBg, "titleText", "灵宝分解", 0, 0, 200, 35)
    --SetAnchorAndPivot(titleTxt, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleCenter)
    --GUI.StaticSetFontSize(titleTxt, 26)
    --GUI.SetColor(titleTxt, Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255))
    --
    --local arrowsImg = GUI.ImageCreate(brokeBg, "arrowsImg","1800607290", 0, -25, false, 60, 40)
    --SetAnchorAndPivot(arrowsImg, UIAnchor.Center, UIAroundPivot.Center)
    --
    ---- 关闭
    --local closeBtn = GUI.ButtonCreate(brokeBg, "closeBtn", "1800302120", 0, -6, Transition.ColorTint)
    --SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    --GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "SpiritualEquipUI", "OnBrokeClose")
    --
    --local tipsStr = f and "分解灵宝精华，可获得灵宝碎片。\n分解灵石，可获得灵宝碎片。" or "分解后灵宝会消失，并返回一部分升级材料"
    --local tipsTxt = GUI.CreateStatic(brokeBg, "tipsTxt", tipsStr, 0, -110,428, 61)
    --SpiritualEquipUI.SetFont2(tipsTxt)
    --GUI.StaticSetAlignment(tipsTxt, TextAnchor.MiddleCenter)
    --
    --local itemDB = nil
    --local itemData = nil
    --local data = nil
    --local str = ""
    --local brkDB = nil
    --local num = nil
    --if f then
    --    data = LD.GetItemDataByGuid(tostring(guid), item_container_type.item_container_bag)
    --    itemDB = DB.GetOnceItemByKey1(data.id)
    --    str = itemDB.Name .. "\n数量：" .. tostring(data:GetAttr(ItemAttr_Native.Amount))
    --    local type = itemDB.ShowType == "灵宝精华" and SpiritualEquipDisassembleTB["Grade"..itemDB.Grade]["Essence"] or SpiritualEquipDisassembleTB["Grade"..itemDB.Grade]["Stone"]
    --    brkDB = DB.GetOnceItemByKey1(type["ItemId"])
    --    num = math.floor(tonumber(data:GetAttr(ItemAttr_Native.Amount)) * type["ratio"])
    --    BrkTable = {
    --        num = tonumber(data:GetAttr(ItemAttr_Native.Amount)),
    --        guid = guid,
    --        flag = itemDB.ShowType == "灵宝精华" and 1 or 2,
    --        --id = itemDB.Id,
    --    }
    --else    -- 灵宝分解
    --
    --    itemDB = DB.GetOnceItemByKey1(TipsConfig["Id"])
    --    itemData = TipsConfig["itemData"]
    --    str = itemDB.Name .. "\n等级：" .. itemData:GetIntCustomAttr("EquipRank") .. "阶" .. itemData:GetIntCustomAttr("EquipLevel") .. "级\n五行：" .. itemData:GetIntCustomAttr("WuXingLevel") .. "级"
    --    brkDB = DB.GetOnceItemByKey2(TipsConfig["ActivateMaterial"][1])
    --    num = math.floor(TipsConfig["ActivateMaterial"][2] * EquipReturn)
    --end
    ---- icon
    --local iconBg = GUI.ImageCreate(brokeBg, "iconBg", QualityRes[itemDB.Grade], -140, -25, false, 80, 81)
    --SetAnchorAndPivot(iconBg, UIAnchor.Center, UIAroundPivot.Center)
    --local icon = GUI.ImageCreate(iconBg, "icon", itemDB.Icon, 0, -1, false, 70, 70)
    --SetAnchorAndPivot(icon, UIAnchor.Center, UIAroundPivot.Center)
    --
    --local equipInfo = GUI.CreateStatic(brokeBg, "equipInfo", str, -80, 62, 200, 84)
    --SpiritualEquipUI.SetFont2(equipInfo)
    --
    ---- 分解可获得的道具
    --local brkBg = GUI.ImageCreate(brokeBg, "brkBg", QualityRes[brkDB.Grade], 120, -25, false, 80, 81)
    --SetAnchorAndPivot(brkBg, UIAnchor.Center, UIAroundPivot.Center)
    --local brk = GUI.ImageCreate(brkBg, "brk", brkDB.Icon, 0, -1, false, 70, 70)
    --SetAnchorAndPivot(brk, UIAnchor.Center, UIAroundPivot.Center)
    --
    --local str2 = brkDB.Name .. "\n分解可得碎片:" .. num
    --local brkInfo = GUI.CreateStatic(brokeBg, "brkInfo", str2, 180, 50, 200, 53)
    --SpiritualEquipUI.SetFont2(brkInfo)
    --
    --local brkBuy = GUI.ButtonCreate(brokeBg,  "brkBuy", "1800102090",4,134, Transition.ColorTint, "分解")
    --SetAnchorAndPivot(brkBuy, UIAnchor.Center, UIAroundPivot.Center)
    --GUI.SetScale(brkBuy, Vector3.New(0.8,0.8,0.8))
    --if f then
    --    GUI.RegisterUIEvent(brkBuy, UCE.PointerClick , "SpiritualEquipUI", "OnBrkBtnClick2")
    --else
    --    GUI.RegisterUIEvent(brkBuy, UCE.PointerClick , "SpiritualEquipUI", "OnBrkBtnClick")
    --end
    --GUI.SetIsOutLine(brkBuy,true)
    --GUI.ButtonSetTextFontSize(brkBuy,32)
    --GUI.ButtonSetTextColor(brkBuy,Color.New(1,1,1,1))
    --GUI.SetOutLine_Color(brkBuy,Color.New(182/255,92/255,30/255,255/255))
    --GUI.SetOutLine_Distance(brkBuy,1)
end

--function SpiritualEquipUI.OnBrkBtnClick()
--    if TipsConfig == nil then
--        test("数据为空！")
--        return
--    end
--    local guid = TipsConfig["itemData"].guid
--    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "Disassemble", tostring(guid))
--    SpiritualEquipUI.OnBrokeClose()
--end
--
--function SpiritualEquipUI.OnBrkBtnClick2()
--    if BrkTable == nil then
--        return
--    end
--    --test("flag : " .. tostring(BrkTable["flag"]) .. " guid : " .. tostring(BrkTable["guid"]) .. " num : " .. tostring(BrkTable["num"]))
--    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "DisassembleEssenceStone", BrkTable["flag"], BrkTable["guid"], BrkTable["num"])
--    SpiritualEquipUI.OnBrokeClose()
--end

--function SpiritualEquipUI.OnBrokeClose()
--    Parameter = nil
--    GUI.Destroy(_gt.GetUI("brokeCover"))
--end


--- 监听方法
function SpiritualEquipUI.ResetBag(guid, id)
    if id and tostring(id) ~= "" then
        local itemDB = DB.GetOnceItemByKey1(tostring(id))
        SpiritualEquipUI.toResetBagMaterial(itemDB["ShowType"], itemDB["Type"], itemDB["Subtype"])
    elseif guid then
        local itemData = LD.GetItemDataByGuid(tostring(guid))
        if itemData then
            local itemDB = DB.GetOnceItemByKey1(tostring(itemData.id))
            SpiritualEquipUI.toResetBagMaterial(itemDB["ShowType"], itemDB["Type"], itemDB["Subtype"])
        end
    end
end

function SpiritualEquipUI.toResetBagMaterial(showType, type, subType)
    if (showType == "灵宝五行" or showType == "灵宝精华") and nowPage == 3 then
        SpiritualEquipUI.RefreshRightFiveElements()
        return
    end

    if showType == "灵宝精华" then
        if nowPage == 2 then
            SpiritualEquipUI.RefreshPracticeRight()
            return
        end
    end

    if showType == "灵宝碎片" then
        if nowPage == 4 then
            SpiritualEquipUI.RefreshInfoBg()
            return
        end
    end

    if type == 3 and subType == 33 and practiceAddExpBtnClick == 1 then -- 灵气刷新
        SpiritualEquipUI.OnPracticeAddExpBtnClick()
        return
    end
end

-- 修炼页面当前级别效果tips
function SpiritualEquipUI.OnSkillTipNtf(config, level)
    local dbSkill = DB.GetOnceSkillByKey1(config["BaseSkill"])
    local index = 1
    local id = config["Id"]
    for i, v in ipairs(EquipAttConfig) do
        if v["Id"] == tonumber(id) then
            break
        end
        index = index + 1
    end
    local str = [[
        local Inti = ]] .. GlobalProcessing.SpiritualEquipAttConfig[index].Client_SkillNum.Inti..[[
        local Coef = ]] .. GlobalProcessing.SpiritualEquipAttConfig[index].Client_SkillNum.Coef..[[
        local EquipLevel = ]] .. level .. [[
    ]]
    local param = assert(load(str.." return "..GlobalProcessing.SpiritualEquipFormula))()    -- 获取到属性值
    if config["Client_SkillNum"]["IsPct"] == 1 then
        param = tostring(tonumber(param) / 100) .. "%%"
    end
    param = "<color=#08AF00FF>".. param  .. "</color>"

    local str = (string.gsub(dbSkill.LockInfo, "prane", param))   -- 把属性值嵌进Info里，多这个括号有用

    return str
end

function SpiritualEquipUI.GetAtt(attConfig, fiveLevel, five)
    if attConfig == nil then
        attConfig = nowEquipAttConfig
    end
    local nowStr = ""
    local type = attConfig["Att"][five .. "Type"]
    if type == 1 then   -- 人物角色属性
        local isPct = attConfig["Att"][five .. "IsPct"]

        for i = 1, #attConfig["Att"][five .. "Att"] do
            local attData = DB.GetOnceAttrByKey1(attConfig["Att"][five .. "Att"][i])
            local att = attConfig["Att"][five .. "LvDiff"] * fiveLevel
            att = isPct == 1 and tostring(att / 100) .. "%" or att
            nowStr = nowStr .. attData.ChinaName .. att
        end
    elseif type == 2 then   -- 技能表属性
        local attData = DB.GetOnceSkillByKey1(attConfig["BaseSkill"])
        nowStr = nowStr .. attData.Info
    elseif type == 3 then   -- buff表属性
        local attData = DB.GetOnceBuffByKey1(attConfig["BaseSkill"])
        nowStr = nowStr .. attData.Info
    end
    return nowStr
end

function SpiritualEquipUI.OnExit()
    CL.UnRegisterMessage(GM.AddNewItem, "SpiritualEquipUI", "ResetBag")
    CL.UnRegisterMessage(GM.UpdateItem, "SpiritualEquipUI", "ResetBag")
    CL.UnRegisterMessage(GM.RemoveItem, "SpiritualEquipUI", "ResetBag")
    CL.UnRegisterAttr(RoleAttr.RoleAttrBindGold, SpiritualEquipUI.ResetAttrBindGold)

    GUI.CloseWnd("SpiritualEquipUI")
    SpiritualEquipUI.OnWearClick()
end