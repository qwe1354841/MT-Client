local EquipSalvageSoulUI = {}
_G.EquipSalvageSoulUI = EquipSalvageSoulUI

--装备拆分器灵界面

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local _gt = UILayout.NewGUIDUtilTable()

require("TestEffectUI")

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

local item_guid = nil

--保固勾选状态
local onIsSafeStatus = false

--锁定数量
local lockNum = 0

----------------------------------------------End 全局变量 End---------------------------------


------------------------------------------Start 表配置 Start----------------------------------

--原属性表
local reforgeNowAttrTable = {}

--配置表
local reforgeDisintegrateTable = {}

--品质关于颜色表
local qualityOfColorTable = {}

--选择了左边词条表
local selectLeftStatsItemTable = {}

--------------------------------------------End 表配置 End------------------------------------

function EquipSalvageSoulUI.Main(parameter)
    local panel = GUI.WndCreateWnd("EquipSalvageSoulUI" , "EquipSalvageSoulUI" , 0 , 0 ,eCanvasGroup.Normal)
    SetSameAnchorAndPivot(panel, UILayout.Center)

    local panelBg = UILayout.CreateFrame_WndStyle2(panel, "拆分器灵",680,560,"EquipSalvageSoulUI","OnExit")
    _gt.BindName(panelBg,"panelBg")

    local centerBg = GUI.ImageCreate(panelBg, "centerBg", "1801100100", 0, -10, false, 640, 420)
    SetSameAnchorAndPivot(centerBg, UILayout.Center)

    local bg_w = 275
    local bg_h = 275
    local itemSize = 90

    ------------------------------------------Start 分解装备 Start----------------------------------------------
    local leftBg = GUI.ImageCreate(centerBg, "leftBg", "1800700050", -165, 15, false, bg_w, bg_h)
    _gt.BindName(leftBg,"leftBg")
    SetSameAnchorAndPivot(leftBg, UILayout.Top)

    local item = GUI.ItemCtrlCreate(leftBg,"item",QualityRes[1],15,15,itemSize,itemSize,false,"system",false)
    SetSameAnchorAndPivot(item, UILayout.TopLeft)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,65,65)

    local nameTxt = GUI.CreateStatic(item, "nameTxt", "六个字名字名", 10, 0, 180, 45)
    SetAnchorAndPivot(nameTxt, UIAnchor.TopRight, UIAroundPivot.TopLeft)
    GUI.SetColor(nameTxt, Brown4Color)
    GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(nameTxt, 26)

    local levelTxt = GUI.CreateStatic(item, "levelTxt", "六个字", 10, 15, 60, 30)
    SetAnchorAndPivot(levelTxt, UIAnchor.Right, UIAroundPivot.Left)
    GUI.SetColor(levelTxt, UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(levelTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(levelTxt, 22)

    local typeTxt = GUI.CreateStatic(levelTxt, "typeTxt", "六个字", 10, 0, 60, 30)
    SetAnchorAndPivot(typeTxt, UIAnchor.Right, UIAroundPivot.Left)
    GUI.SetColor(typeTxt, UIDefine.Yellow2Color)
    GUI.StaticSetAlignment(typeTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(typeTxt, 22)

    local leftStatsItemLoop =
    GUI.LoopScrollRectCreate(
            leftBg,
            "leftStatsItemLoop",
            15,
            110,
            bg_w - 30 ,
            150,
            "EquipSalvageSoulUI",
            "CreateLeftStatsItem",
            "EquipSalvageSoulUI",
            "RefreshLeftStatsItem",
            0,
            false,
            Vector2.New(bg_w - 30, 45),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(leftStatsItemLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(leftStatsItemLoop, TextAnchor.UpperLeft)
    GUI.ScrollRectSetChildSpacing(leftStatsItemLoop, Vector2.New(0, 1))
    _gt.BindName(leftStatsItemLoop,"leftStatsItemLoop")
    GUI.LoopScrollRectSetTotalCount(leftStatsItemLoop, 10)
    GUI.LoopScrollRectRefreshCells(leftStatsItemLoop)

    ------------------------------------------End   分解装备   End----------------------------------------------

    ------------------------------------------Start 获得材料 Start----------------------------------------------
    local rightBg = GUI.ImageCreate(centerBg, "rightBg", "1800700050", 165, 15, false, bg_w, bg_h)
    SetSameAnchorAndPivot(rightBg, UILayout.Top)
    _gt.BindName(rightBg,"rightBg")

    local item = GUI.ItemCtrlCreate(rightBg,"item",QualityRes[1],15,15,itemSize,itemSize,false,"system",false)
    SetSameAnchorAndPivot(item, UILayout.TopLeft)
    GUI.ItemCtrlSetElementRect(item,eItemIconElement.Icon,0,-1,60,60)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "EquipSalvageSoulUI", "OnObtainMaterialShowItemClick")

    local nameTxt = GUI.CreateStatic(item, "nameTxt", "物品名", 10, 0, 180, 45)
    SetAnchorAndPivot(nameTxt, UIAnchor.TopRight, UIAroundPivot.TopLeft)
    GUI.SetColor(nameTxt, Brown4Color)
    GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(nameTxt, 26)

    local acquiredTotalTxt = GUI.CreateStatic(item, "acquiredTotalTxt", "共获得：999", 10, 49, 180, 30)
    SetAnchorAndPivot(acquiredTotalTxt, UIAnchor.TopRight, UIAroundPivot.TopLeft)
    GUI.SetColor(acquiredTotalTxt, OrangeColor)
    GUI.StaticSetAlignment(acquiredTotalTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(acquiredTotalTxt, 24)

    local rightStatsItemLoop =
    GUI.LoopScrollRectCreate(
            rightBg,
            "rightStatsItemLoop",
            15,
            110,
            bg_w - 30 ,
            150,
            "EquipSalvageSoulUI",
            "CreateRightStatsItem",
            "EquipSalvageSoulUI",
            "RefreshRightStatsItem",
            0,
            false,
            Vector2.New(bg_w - 30, 45),
            1,
            UIAroundPivot.TopLeft,
            UIAnchor.TopLeft,
            false
    )
    SetSameAnchorAndPivot(rightStatsItemLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(rightStatsItemLoop, TextAnchor.UpperLeft)
    GUI.ScrollRectSetChildSpacing(rightStatsItemLoop, Vector2.New(0, 1))
    _gt.BindName(rightStatsItemLoop,"rightStatsItemLoop")


    ------------------------------------------End   获得材料   End----------------------------------------------

    local scale = 1.5
    local rightArrow = GUI.ImageCreate(centerBg,"rightArrow","1800607290", 0, -60)
    GUI.SetScale(rightArrow, Vector3.New(scale,scale,scale))--缩放
    SetSameAnchorAndPivot(rightArrow, UILayout.Center)

    --------------------------------------Start 消耗材料 Start------------------------------------------
    local expendItem = GUI.ItemCtrlCreate(centerBg,"expendItem",QualityRes[1],0,-120,80,80,false,"system",false)
    _gt.BindName(expendItem,"expendItem")
    SetAnchorAndPivot(expendItem, UIAnchor.Bottom, UIAroundPivot.Top)
    GUI.ItemCtrlSetElementRect(expendItem,eItemIconElement.Icon,0,-1,60,60)
    GUI.RegisterUIEvent(expendItem, UCE.PointerClick, "EquipSalvageSoulUI", "OnConsumableItemClick")

    local nameTxt = GUI.CreateStatic(expendItem, "nameTxt", "六个字名字名", 0, 0, 180, 30)
    SetAnchorAndPivot(nameTxt, UIAnchor.Bottom, UIAroundPivot.Top)
    GUI.SetColor(nameTxt, Brown4Color)
    GUI.StaticSetAlignment(nameTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(nameTxt, 22)

    --保固石勾选框
    local IsSafeToggle = GUI.CheckBoxCreate (expendItem,"IsSafeToggle", "1800607150", "1800607151", 20, 20,Transition.ColorTint, false)
    SetAnchorAndPivot(IsSafeToggle, UIAnchor.TopRight , UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(IsSafeToggle, UCE.PointerClick , "EquipSalvageSoulUI", "OnIsSafeClick")

    --------------------------------------End   消耗材料   End------------------------------------------

    ------------------------------------------------------Start 底部按钮 Start----------------------------------------
    local bottomBtnGroup = GUI.GroupCreate(centerBg,"bottomBtnGroup",0,10,620,50,false)
    SetAnchorAndPivot(bottomBtnGroup, UIAnchor.Bottom, UIAroundPivot.Top)

    local consumeText = GUI.CreateStatic(bottomBtnGroup, "consumeText", "装备摧毁率:", 0, 0, 145, 45)
    _gt.BindName(consumeText, "consumeText")
    SetSameAnchorAndPivot(consumeText, UILayout.Left)
    GUI.SetColor(consumeText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(consumeText, 26)
    GUI.StaticSetAlignment(consumeText, TextAnchor.MiddleLeft)

    local num = GUI.CreateStatic(consumeText, "num", "100%", 0, 0, 80, 45)
    GUI.SetColor(num, UIDefine.RedColor)
    GUI.StaticSetFontSize(num, 26)
    GUI.StaticSetAlignment(num, TextAnchor.MiddleLeft)
    SetAnchorAndPivot(num, UIAnchor.Right, UIAroundPivot.Left)

    local salvageBtn = GUI.ButtonCreate(bottomBtnGroup, "salvageBtn", "1800402080", 0, 0, Transition.ColorTint, "拆分器灵", 170, 50, false)
    _gt.BindName(salvageBtn,"salvageBtn")
    GUI.ButtonSetTextFontSize(salvageBtn, 28)
    GUI.SetIsOutLine(salvageBtn, true)
    GUI.ButtonSetTextColor(salvageBtn, WhiteColor)
    GUI.SetOutLine_Color(salvageBtn, OutLine_BrownColor);
    GUI.SetOutLine_Distance(salvageBtn,OutLineDistance)
    SetSameAnchorAndPivot(salvageBtn, UILayout.BottomRight)
    GUI.RegisterUIEvent(salvageBtn, UCE.PointerClick, "EquipSalvageSoulUI", "OnSalvageBtnClick")

    ------------------------------------------------------End   底部按钮   End----------------------------------------

end

function EquipSalvageSoulUI.OnShow(parameter)
    local wnd = GUI.GetWnd("EquipSalvageSoulUI");
    if wnd == nil then
        return
    end

    test("parameter",parameter)

    item_guid = tostring(parameter)

    EquipSalvageSoulUI.Init()
    GUI.SetVisible(wnd, true)

    --注销物品数据更新监听
    EquipSalvageSoulUI.UnRegisterMessage()
    --注册物品数据更新监听
    EquipSalvageSoulUI.RegisterMessage()

    EquipSalvageSoulUI.RefreshAllData()

end

function EquipSalvageSoulUI.Init()

    onIsSafeStatus = false

    selectLeftStatsItemTable = {}

end

--刷新所有数据
function EquipSalvageSoulUI.RefreshAllData()
    test("刷新所有数据")

    --配置表
    reforgeDisintegrateTable = GlobalProcessing.EquipSoulReforgeDisintegrate

    --品质关于颜色表
    qualityOfColorTable = GlobalProcessing.EquipSoulReforgeColor

    test("reforgeDisintegrateTable",inspect(reforgeDisintegrateTable))

    test("qualityOfColorTable",inspect(qualityOfColorTable))

    --获得装备Attr属性
    EquipSalvageSoulUI.GetEquipAttr()
    
end

--获得装备Attr属性
function EquipSalvageSoulUI.GetEquipAttr()
    test("获得装备Attr属性")

    --原属性表
    reforgeNowAttrTable = {}

    local salvageBtn = _gt.GetUI("salvageBtn")

    if item_guid ~= nil then

        GUI.ButtonSetShowDisable(salvageBtn,true)

        local itemData = LD.GetItemDataByGuidInAll(item_guid)

        --原属性
        local equipSoulReforgeNowAttrTb = itemData:GetStrCustomAttr("EquipSoulReforge_NowAttrTb")

        test("equipSoulReforgeNowAttrTb",equipSoulReforgeNowAttrTb,type(equipSoulReforgeNowAttrTb))

        local temp = {}

        if #equipSoulReforgeNowAttrTb > 0 then

            temp = loadstring("return " .. equipSoulReforgeNowAttrTb)()

        end

        if next(reforgeDisintegrateTable) then

            for i = 1, #temp do

                if reforgeDisintegrateTable.Item[temp[i][3]] ~= nil then

                    temp[i].originalIndex = i

                    table.insert(reforgeNowAttrTable,temp[i])

                end

            end

        end

        if #reforgeNowAttrTable > 0 then

            test("reforgeNowAttrTable",inspect(reforgeNowAttrTable))

            GUI.ButtonSetShowDisable(salvageBtn,true)

        else

            GUI.ButtonSetShowDisable(salvageBtn,false)

        end

    else

        GUI.ButtonSetShowDisable(salvageBtn,false)

    end

    --刷新左边物品数据
    EquipSalvageSoulUI.RefreshLeftItemData()

end

--刷新左边物品数据
function EquipSalvageSoulUI.RefreshLeftItemData()
    test("刷新左边物品数据")

    local leftBg = _gt.GetUI("leftBg")

    test("item_guid",item_guid)

    if item_guid ~= nil then

        GUI.SetVisible(leftBg,true)
        local itemData = LD.GetItemDataByGuidInAll(item_guid)
        local itemId = tonumber(itemData.id)

        local itemDB = DB.GetOnceItemByKey1(itemId)

        local item = GUI.GetChild(leftBg,"item",false)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,itemDB.Icon)
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[itemDB.Grade])

        local nameTxt = GUI.GetChild(item,"nameTxt",false)
        GUI.StaticSetText(nameTxt,itemDB.Name)

        local levelTxt = GUI.GetChild(item,"levelTxt",false)
        GUI.StaticSetText(levelTxt,itemDB.Level.."级")

        local typeTxt = GUI.GetChild(levelTxt,"typeTxt",false)
        GUI.StaticSetText(typeTxt,itemDB.ShowType)

        --刷新左侧loop数据
        EquipSalvageSoulUI.RefreshLeftStatsItemLoopData()

        --刷新右侧获得材料数据
        EquipSalvageSoulUI.RefreshRightObtainMaterialData()

        --刷新消耗道具数据
        EquipSalvageSoulUI.SetConsumableItemGroupData()

    else

        GUI.SetVisible(leftBg,false)

    end

end

--刷新左侧loop数据
function EquipSalvageSoulUI.RefreshLeftStatsItemLoopData()

    local leftLoop = _gt.GetUI("leftStatsItemLoop")
    local refreshNum = 6
    if #reforgeNowAttrTable > refreshNum then

        refreshNum = #reforgeNowAttrTable

    end

    GUI.LoopScrollRectSetTotalCount(leftLoop, #reforgeNowAttrTable)
    GUI.LoopScrollRectRefreshCells(leftLoop)

end

function EquipSalvageSoulUI.CreateLeftStatsItem(guid)
    local statsItemLoop = GUI.GetByGuid(tostring(guid))
    local index = GUI.LoopScrollRectGetChildInPoolCount(statsItemLoop) + 1

    local checkbox = GUI.CheckBoxExCreate(statsItemLoop,"checkbox"..index, "1800400360", "1800400361",  0, 0, false,75, 40)
    GUI.RegisterUIEvent(checkbox, UCE.PointerClick, "EquipSalvageSoulUI", "OnLeftStatsCheckBoxClick")

    --1801207120 1801207130
    local checkBoxBg = GUI.ImageCreate(checkbox, "checkBoxBg", "1801207120", 10, 0, false)
    SetSameAnchorAndPivot(checkBoxBg, UILayout.Left)

    local glossaryTxt = GUI.CreateStatic(checkbox, "glossaryTxt", "找不到变量Data", 45, 2,  230, 50)
    GUI.StaticSetAlignment(glossaryTxt, TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(glossaryTxt, UILayout.Left)
    GUI.SetColor(glossaryTxt, WhiteColor)
    GUI.StaticSetFontSize(glossaryTxt, 26)

    return checkbox
end

function EquipSalvageSoulUI.RefreshLeftStatsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)

    local data = reforgeNowAttrTable[index]

    if data then

        local data_color = qualityOfColorTable

        local checkBoxBg = GUI.GetChild(item,"checkBoxBg",false)

        if not next(selectLeftStatsItemTable) then

            if index == 1 then

                GUI.CheckBoxExSetCheck(item,true)
                GUI.ImageSetImageID(checkBoxBg,"1801207130")

                selectLeftStatsItemTable[tostring(guid)] = true

                reforgeNowAttrTable[index].isClick = true

                --刷新消耗道具数据
                EquipSalvageSoulUI.SetConsumableItemGroupData()

                --刷新右侧获得材料数据
                EquipSalvageSoulUI.RefreshRightObtainMaterialData()

            else

                GUI.CheckBoxExSetCheck(item,false)
                GUI.ImageSetImageID(checkBoxBg,"1801207120")

                selectLeftStatsItemTable[tostring(guid)] = false

                reforgeNowAttrTable[index].isClick = false

            end

        else

            if selectLeftStatsItemTable[tostring(guid)] then

                GUI.CheckBoxExSetCheck(item,true)
                GUI.ImageSetImageID(checkBoxBg,"1801207130")

            else


                GUI.CheckBoxExSetCheck(item,false)
                GUI.ImageSetImageID(checkBoxBg,"1801207120")

            end


        end

        local glossaryTxt = GUI.GetChild(item,"glossaryTxt",false)

        GUI.StaticSetText(glossaryTxt,data[6])

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

    GUI.SetData(item,"index",index)

end


--左边原属性checkbox点击事件
function EquipSalvageSoulUI.OnLeftStatsCheckBoxClick(guid)
    test("左边原属性checkbox点击事件")

    local item = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(item,"index"))

    test("selectLeftStatsItemTable[tostring(guid)]",inspect(selectLeftStatsItemTable[tostring(guid)]))

    if selectLeftStatsItemTable[tostring(guid)] == nil then

        selectLeftStatsItemTable[tostring(guid)] = true

    else

        if selectLeftStatsItemTable[tostring(guid)] == true then

            selectLeftStatsItemTable[tostring(guid)] = false

        else

            selectLeftStatsItemTable[tostring(guid)] = true

        end

    end

    if reforgeNowAttrTable[index].isClick == nil  then

        reforgeNowAttrTable[index].isClick = true

    else

        if reforgeNowAttrTable[index].isClick == true then

            reforgeNowAttrTable[index].isClick = false

        else

            reforgeNowAttrTable[index].isClick = true

        end

    end

    test("selectLeftStatsItemTable",inspect(selectLeftStatsItemTable))

    --刷新左侧loop数据
    EquipSalvageSoulUI.RefreshLeftStatsItemLoopData()

    --刷新右侧获得材料数据
    EquipSalvageSoulUI.RefreshRightObtainMaterialData()

    --刷新消耗道具数据
    EquipSalvageSoulUI.SetConsumableItemGroupData()

end

--刷新消耗道具数据
function EquipSalvageSoulUI.SetConsumableItemGroupData()
    test("刷新消耗道具数据")

    lockNum = 0

    test("selectLeftStatsItemTable",inspect(selectLeftStatsItemTable))
    for k, v in pairs(selectLeftStatsItemTable) do

        if v then
            lockNum = lockNum + 1
        end

    end

    local expendItem = _gt.GetUI("expendItem")
    local salvageBtn = _gt.GetUI("salvageBtn")

    if lockNum ~= 0 then

        GUI.SetVisible(expendItem,true)

        GUI.ButtonSetShowDisable(salvageBtn,true)

        local expendTemp = reforgeDisintegrateTable.EquipRand[lockNum]

        local bagType = item_container_type.item_container_bag
        local itemDB = DB.GetOnceItemByKey2(expendTemp.RegularItem[1])
        local itemNum = LD.GetItemCountById(itemDB.Id,bagType)

        GUI.ItemCtrlSetElementValue(expendItem,eItemIconElement.Icon,itemDB.Icon)
        GUI.ItemCtrlSetElementValue(expendItem,eItemIconElement.Border,QualityRes[itemDB.Grade])

        GUI.ItemCtrlSetElementValue(expendItem,eItemIconElement.RightBottomNum,itemNum.."/"..expendTemp.RegularItem[2])

        local nameTxt = GUI.GetChild(expendItem,"nameTxt",false)
        GUI.StaticSetText(nameTxt,itemDB.Name)

        GUI.SetData(expendItem,"itemId",itemDB.Id)

        --摧毁率设置
        local IsSafeToggle = GUI.GetChild(expendItem,"IsSafeToggle",false)
        GUI.CheckBoxSetCheck(IsSafeToggle,onIsSafeStatus)

    else

        GUI.SetVisible(expendItem,false)

        GUI.ButtonSetShowDisable(salvageBtn,false)

    end

    --刷新摧毁率数据
    EquipSalvageSoulUI.SetConsumeTextData()

end

--保护checkbox点击事件
function EquipSalvageSoulUI.OnIsSafeClick()
    test("保护checkbox点击事件")

    local expendItem = _gt.GetUI("expendItem")

    if onIsSafeStatus then

        onIsSafeStatus = false

    else

        onIsSafeStatus = true

    end

    --摧毁率设置
    local IsSafeToggle = GUI.GetChild(expendItem,"IsSafeToggle",false)
    GUI.CheckBoxSetCheck(IsSafeToggle,onIsSafeStatus)

    --刷新摧毁率数据
    EquipSalvageSoulUI.SetConsumeTextData()

end

--刷新摧毁率数据
function EquipSalvageSoulUI.SetConsumeTextData()
    test("刷新摧毁率数据")

    --摧毁率
    local consumeText = _gt.GetUI("consumeText")
    local num = GUI.GetChild(consumeText,"num",false)

    if lockNum > 0 then

        local expendTemp = reforgeDisintegrateTable.EquipRand[lockNum]

        if onIsSafeStatus then

            GUI.StaticSetText(num,(expendTemp.RegularSmashRand/100).."%")

        else

            GUI.StaticSetText(num,(expendTemp.BaseSmashRand/100).."%")

        end

    else

        GUI.StaticSetText(num,"0%")

    end


end

--刷新右侧获得材料数据
function EquipSalvageSoulUI.RefreshRightObtainMaterialData()
    test("刷新右侧获得材料数据")

    test("reforgeDisintegrateTable",inspect(reforgeDisintegrateTable))

    local rightBg = _gt.GetUI("rightBg")

    local item = GUI.GetChild(rightBg,"item",false)

    test("reforgeDisintegrateTable.ShowItem",reforgeDisintegrateTable.ShowItem)

    local showItemDB = DB.GetOnceItemByKey2(reforgeDisintegrateTable.ShowItem)

    GUI.SetData(item,"itemId",showItemDB.Id)

    GUI.ItemCtrlSetElementValue(item,eItemIconElement.Icon,showItemDB.Icon)
    GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border,QualityRes[showItemDB.Grade])

    local nameTxt = GUI.GetChild(item,"nameTxt",false)
    GUI.StaticSetText(nameTxt,showItemDB.Name)

    local min_sum = 0
    local max_sum = 0

    test("reforgeNowAttrTable",inspect(reforgeNowAttrTable))
    for i = 1, #reforgeNowAttrTable do

        local data = reforgeNowAttrTable[i]

        if data then

            if data.isClick then

                local obtainedData = reforgeDisintegrateTable.Item[data[3]][data[7] + 1][2]

                test("obtainedData",inspect(obtainedData))

                min_sum = min_sum + obtainedData[1]

                max_sum = max_sum + obtainedData[2]

            end

        end

    end

    local acquiredTotalTxt = GUI.GetChild(item,"acquiredTotalTxt",false)
    GUI.StaticSetText(acquiredTotalTxt,"共获得:"..min_sum.."~"..max_sum)

    local rightLoop = _gt.GetUI("rightStatsItemLoop")
    GUI.LoopScrollRectSetTotalCount(rightLoop, #reforgeNowAttrTable)
    GUI.LoopScrollRectRefreshCells(rightLoop)

end


function EquipSalvageSoulUI.CreateRightStatsItem(guid)
    local statsItemLoop = GUI.GetByGuid(tostring(guid))
    local index = GUI.LoopScrollRectGetChildInPoolCount(statsItemLoop) + 1

    local leftStatsBg = GUI.ImageCreate(statsItemLoop, "leftStatsBg"..index, "1800400360", 0, 0, false, 740, 460)

    local glossaryTxt = GUI.CreateStatic(leftStatsBg, "glossaryTxt", "找不到变量Data", 15, 2,  260, 50)
    GUI.StaticSetAlignment(glossaryTxt, TextAnchor.MiddleLeft)
    SetSameAnchorAndPivot(glossaryTxt, UILayout.Left)
    GUI.SetColor(glossaryTxt, WhiteColor)
    GUI.StaticSetFontSize(glossaryTxt, 26)

    return leftStatsBg
end

function EquipSalvageSoulUI.RefreshRightStatsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)


    local data = reforgeNowAttrTable[index]

    if data then

        test("data",inspect(data))

        local obtainedData = reforgeDisintegrateTable.Item[data[3]][data[7] + 1]

        local obtainedDB = DB.GetOnceItemByKey2(obtainedData[1])

        local glossaryTxt = GUI.GetChild(item,"glossaryTxt",false)

        GUI.StaticSetText(glossaryTxt,obtainedDB.Name.."："..obtainedData[2][1].."~"..obtainedData[2][2])
        GUI.SetColor(glossaryTxt,UIDefine.GradeColor[obtainedDB.Grade])



        if data.isClick then

            GUI.ImageSetImageID(item,"1800400361")

        else

            GUI.ImageSetImageID(item,"1800400360")

        end

        GUI.SetVisible(item,true)

    else

        GUI.SetVisible(item,false)

    end

end

--右边showItem点击事件
function EquipSalvageSoulUI.OnObtainMaterialShowItemClick(guid)
    test("右边showItem点击事件")

    local item = GUI.GetByGuid(guid)
    local itemId = tonumber(GUI.GetData(item,"itemId"))

    local panelBg = _gt.GetUI("panelBg")
    local tip = Tips.CreateByItemId(tonumber(itemId), panelBg, "showItemTips",120,0,20)
    SetSameAnchorAndPivot(tip, UILayout.Center)
    GUI.SetData(tip, "ItemId", itemId)

end

--消耗物品item点击事件
function EquipSalvageSoulUI.OnConsumableItemClick(guid)
    test("消耗物品item点击事件")

    local item = GUI.GetByGuid(guid)
    local itemId = tonumber(GUI.GetData(item,"itemId"))
    test("itemId",itemId)

    local panelBg = _gt.GetUI("panelBg")
    local tip = Tips.CreateByItemId(tonumber(itemId), panelBg, "rightItemTips",0,0,50)
    SetSameAnchorAndPivot(tip, UILayout.Center)
    GUI.SetData(tip, "ItemId", itemId)

    local wayBtn=GUI.ButtonCreate(tip,"wayBtn","1800402110",0,-10,Transition.ColorTint,"获得途径", 150, 50, false)
    SetAnchorAndPivot(wayBtn,UIAnchor.Bottom,UIAroundPivot.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"EquipSoulWashingUI","onClickWayBtn")
    GUI.AddWhiteName(tip, GUI.GetGuid(wayBtn))

end

--拆分器灵按钮点击事件
function EquipSalvageSoulUI.OnSalvageBtnClick()
    test("拆分器灵按钮点击事件")

    local select_str = ""

    for i = 1, #reforgeNowAttrTable do

        local data = reforgeNowAttrTable[i]

        if data then

            if data.isClick then

                select_str = select_str..data.originalIndex..","

            end

        end

    end

    local isSafe = 0

    if onIsSafeStatus then

        isSafe = 1

    end

    test(item_guid,select_str,isSafe)

    CL.SendNotify(NOTIFY.SubmitForm,"FormEquipSoulReforge","Disintegrate",item_guid,select_str,isSafe)

end

--分解成功回调
function EquipSalvageSoulUI.DisintegrateReturn(isDestroy)
    test("分解成功回调")

    selectLeftStatsItemTable = {}

    test("isDestroy",isDestroy,type(isDestroy))

    if isDestroy == 0 then

        EquipSalvageSoulUI.RefreshAllData()

    else

        test("分解了物品")

        local leftBg = _gt.GetUI("leftBg")

        local item = GUI.GetChild(leftBg,"item",false)

        local icon = GUI.ItemCtrlGetElement(item,eItemIconElement.Icon)

        TestEffectUI.SetUIDissolve(item,0.5,0.25,1,RedColor,UIEffects.ColorMode.Fill,false,2,1,false,true)
        TestEffectUI.SetUIDissolve(icon,0.5,0.25,1,RedColor,UIEffects.ColorMode.Fill,false,2,1,false,true)

        EquipSalvageSoulUI.StartTipsTimer()

    end

end

function EquipSalvageSoulUI.StartTipsTimer()
    test("计时器启动")

    EquipSalvageSoulUI.RefreshTime = 0
    local fun = function()
        EquipSalvageSoulUI.ReturnTipsTimer()
    end
    EquipSalvageSoulUI.StopTipsTimer()
    EquipSalvageSoulUI.RefreshTipsTimer = Timer.New(fun, 1, 2)
    EquipSalvageSoulUI.RefreshTipsTimer:Start()
end

function EquipSalvageSoulUI.ReturnTipsTimer()

    EquipSalvageSoulUI.RefreshTime = EquipSalvageSoulUI.RefreshTime + 1

    if EquipSalvageSoulUI.RefreshTime == 2 then
        local leftBg = _gt.GetUI("leftBg")
        local item = GUI.GetChild(leftBg,"item",false)
        local icon = GUI.ItemCtrlGetElement(item,eItemIconElement.Icon)
        TestEffectUI.RemoveUIDissolve(item)
        TestEffectUI.RemoveUIDissolve(icon)
        EquipSalvageSoulUI.OnExit()
    end
end

--计时器停止
function EquipSalvageSoulUI.StopTipsTimer()
    if EquipSalvageSoulUI.RefreshTipsTimer ~= nil then
        EquipSalvageSoulUI.RefreshTime = 0
        EquipSalvageSoulUI.RefreshTipsTimer:Stop()
        EquipSalvageSoulUI.RefreshTipsTimer = nil
    end
end

--注册物品数据更新监听
function EquipSalvageSoulUI.RegisterMessage()
    test("注册物品数据更新监听")

    CL.RegisterMessage(GM.AddNewItem, "EquipSalvageSoulUI", "UpdateItem")
    CL.RegisterMessage(GM.UpdateItem, "EquipSalvageSoulUI", "UpdateItem")
    CL.RegisterMessage(GM.RemoveItem, "EquipSalvageSoulUI", "UpdateItem")

end

--注销物品数据更新监听
function EquipSalvageSoulUI.UnRegisterMessage()
    test("注销物品数据更新监听")

    CL.UnRegisterMessage(GM.AddNewItem, "EquipSalvageSoulUI", "UpdateItem")
    CL.UnRegisterMessage(GM.UpdateItem, "EquipSalvageSoulUI", "UpdateItem")
    CL.UnRegisterMessage(GM.RemoveItem, "EquipSalvageSoulUI", "UpdateItem")

end

--物品数据更新监听回调
function EquipSalvageSoulUI.UpdateItem()
    test("物品数据更新监听回调")

    --刷新消耗道具数据
    EquipSalvageSoulUI.SetConsumableItemGroupData()

end

function EquipSalvageSoulUI.OnExit()

    --注销物品数据更新监听
    EquipSalvageSoulUI.UnRegisterMessage()

    GUI.CloseWnd("EquipSalvageSoulUI")

end
