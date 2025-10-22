local SpiritualEquipBrkUI = {}

_G.SpiritualEquipBrkUI = SpiritualEquipBrkUI
local _gt = UILayout.NewGUIDUtilTable()

---------------------------------缓存需要的全局变量Start------------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
---------------------------------缓存需要的全局变量End-------------------------------

local SpiritualEquipDisassembleTB = nil
local GeneralConfig = nil
local EquipAttConfig = nil
local EquipReturn = nil
local ColorType_FontColor1 = Color.New(172 / 255, 117 / 255, 39 / 255)
local ColorType_FontColor2 = Color.New(102 / 255, 47 / 255, 22 / 255)
local TipsConfig = nil
local BrkTable = nil
local index = nil
local Guid = nil

function SpiritualEquipBrkUI.Main()

    local panel = GUI.WndCreateWnd("SpiritualEquipBrkUI", "SpiritualEquipBrkUI", 0, 0, eCanvasGroup.Normal)

    local brokeCover = GUI.ImageCreate(panel, "brokeCover", "1800400220", 0, -32, false, 2000, 2000)
    UILayout.SetAnchorAndPivot(brokeCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(brokeCover, true)
    _gt.BindName(brokeCover, "brokeCover")

    -- 背景
    local brokeBg = GUI.ImageCreate(brokeCover, "brokeBg", "1800600182", 0, 0, false,530, 350)
    UILayout.SetSameAnchorAndPivot(brokeBg, UILayout.Center)
    _gt.BindName(brokeBg, "brokeBg")

    local rightBg = GUI.ImageCreate(brokeBg, "RightBg", "1800600181", 0, -9.5, false, 225, 40)
    SetAnchorAndPivot(rightBg, UIAnchor.TopRight, UIAroundPivot.TopRight)

    local leftBg = GUI.ImageCreate(brokeBg, "LeftBg", "1800600180", 0, -9.5, false, 225, 40)
    SetAnchorAndPivot(leftBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    -- 标题底板
    local titleBg = GUI.ImageCreate(brokeBg, "titleBg", "1800600190", 0, -10, false, 230, 50)
    SetAnchorAndPivot(titleBg, UIAnchor.Top, UIAroundPivot.Top)

    -- 标题
    local titleTxt = GUI.CreateStatic(titleBg, "titleText", "灵宝分解", 0, 0, 200, 35)
    SetAnchorAndPivot(titleTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(titleTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(titleTxt, 26)
    GUI.SetColor(titleTxt, Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255))

    local arrowsImg = GUI.ImageCreate(brokeBg, "arrowsImg","1800607290", 0, -25, false, 60, 40)
    SetAnchorAndPivot(arrowsImg, UIAnchor.Center, UIAroundPivot.Center)

    -- 关闭
    local closeBtn = GUI.ButtonCreate(brokeBg, "closeBtn", "1800302120", 0, -6, Transition.ColorTint)
    SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "SpiritualEquipBrkUI", "OnBrokeClose")

    local tipsTxt = GUI.CreateStatic(brokeBg, "tipsTxt", "", 0, -110,428, 61)
    SpiritualEquipBrkUI.SetFont2(tipsTxt)
    GUI.StaticSetAlignment(tipsTxt, TextAnchor.MiddleCenter)
    _gt.BindName(tipsTxt, "tipsTxt")

    -- icon
    local iconBg = GUI.ImageCreate(brokeBg, "iconBg", QualityRes[1], -140, -25, false, 80, 81)
    SetAnchorAndPivot(iconBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(iconBg, "iconBg")
    local icon = GUI.ImageCreate(iconBg, "icon", "1900000000", 0, -1, false, 70, 70)
    SetAnchorAndPivot(icon, UIAnchor.Center, UIAroundPivot.Center)

    local equipInfo = GUI.CreateStatic(brokeBg, "equipInfo", "", -80, 62, 200, 84)
    SpiritualEquipBrkUI.SetFont2(equipInfo)
    _gt.BindName(equipInfo, "equipInfo")

    -- 这里是后来加的，让玩家能自己输入数量，直接覆盖在了父类的上面
    local brkNum = GUI.EditCreate(equipInfo, "brkNum","1800001040" ,"" , -10, 14, Transition.ColorTint,"system",70,40,0,0, InputType.Standard, ContentType.IntegerNumber)
    UILayout.SetSameAnchorAndPivot(brkNum, UILayout.Center)
    GUI.EditSetLabelAlignment(brkNum, TextAnchor.MiddleCenter)
    GUI.EditSetTextColor(brkNum, UIDefine.BrownColor)
    GUI.EditSetFontSize(brkNum, UIDefine.FontSizeM)
    GUI.EditSetMaxCharNum(brkNum, 15)
    GUI.RegisterUIEvent(brkNum, UCE.EndEdit, "SpiritualEquipBrkUI", "BrkNumValueChange")
    _gt.BindName(brkNum,"brkNum")

    -- 分解可获得的道具
    local brkBg = GUI.ImageCreate(brokeBg, "brkBg", QualityRes[2], 120, -25, false, 80, 81)
    SetAnchorAndPivot(brkBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(brkBg, "brkBg")
    local brk = GUI.ImageCreate(brkBg, "brk", "1900000000", 0, -1, false, 70, 70)
    SetAnchorAndPivot(brk, UIAnchor.Center, UIAroundPivot.Center)

    local brkInfo = GUI.CreateStatic(brokeBg, "brkInfo", "", 180, 50, 200, 53)
    SpiritualEquipBrkUI.SetFont2(brkInfo)
    _gt.BindName(brkInfo, "brkInfo")

    local brkBuy = GUI.ButtonCreate(brokeBg,  "brkBuy", "1800102090",4,134, Transition.ColorTint, "分解")
    SetAnchorAndPivot(brkBuy, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetScale(brkBuy, Vector3.New(0.8,0.8,0.8))
    GUI.SetIsOutLine(brkBuy,true)
    GUI.ButtonSetTextFontSize(brkBuy,32)
    GUI.ButtonSetTextColor(brkBuy,Color.New(1,1,1,1))
    GUI.SetOutLine_Color(brkBuy,Color.New(182/255,92/255,30/255,255/255))
    GUI.SetOutLine_Distance(brkBuy,1)
    _gt.BindName(brkBuy, "brkBuy")

    SpiritualEquipDisassembleTB = GlobalProcessing.SpiritualEquipDisassembleTB
    GeneralConfig = GlobalProcessing.SpiritualEquipGeneralConfig
    EquipAttConfig = GlobalProcessing.SpiritualEquipAttConfig
    EquipReturn = GlobalProcessing.SpiritualEquipReturn
end

function SpiritualEquipBrkUI.OnShow(parameter)
    if SpiritualEquipDisassembleTB == nil or GeneralConfig == nil or EquipAttConfig == nil or EquipReturn == nil then
        SpiritualEquipBrkUI.OnBrokeClose()
        return
    end
    local index1, guid = UIDefine.GetParameterStr(parameter)
    Guid = guid
    index = index1
    local itemDB = nil
    local data = nil
    local str = ""
    local brkDB = nil
    local num = nil
    local tips = nil
    local brkBuy= _gt.GetUI("brkBuy")
    local brkNum = _gt.GetUI("brkNum")
    TipsConfig = nil
    BrkTable = nil
    if index1 == "1" then
        data = LD.GetItemDataByGuid(tostring(guid), item_container_type.item_container_lingbao_bag)
        itemDB = DB.GetOnceItemByKey1(data.id)
        for i, v in ipairs(EquipAttConfig) do
            if v["KeyName"] == itemDB.KeyName then
                TipsConfig = v
                break
            end
        end

        str = itemDB.Name .. "\n等级：" .. data:GetIntCustomAttr("EquipRank") .. "阶" .. data:GetIntCustomAttr("EquipLevel") .. "级\n五行：" .. data:GetIntCustomAttr("WuXingLevel") .. "级"
        brkDB = DB.GetOnceItemByKey2(TipsConfig["ActivateMaterial"][1])
        num = math.floor(TipsConfig["ActivateMaterial"][2] * EquipReturn)
        tips = "分解后灵宝会消失，并返回一部分升级材料"
        GUI.RegisterUIEvent(brkBuy, UCE.PointerClick , "SpiritualEquipBrkUI", "OnBrkBtnClick")
    elseif index1 == "2" then
        data = LD.GetItemDataByGuid(tostring(guid), item_container_type.item_container_bag)
        itemDB = DB.GetOnceItemByKey1(data.id)
        str = itemDB.Name .. "\n数量：" .. tostring(data:GetAttr(ItemAttr_Native.Amount))
        local type = itemDB.ShowType == "灵宝精华" and SpiritualEquipDisassembleTB["Grade"..itemDB.Grade]["Essence"] or SpiritualEquipDisassembleTB["Grade"..itemDB.Grade]["Stone"]
        brkDB = DB.GetOnceItemByKey1(type["ItemId"])
        num = math.floor(tonumber(data:GetAttr(ItemAttr_Native.Amount)) * type["ratio"])
        tips = itemDB.ShowType == "灵宝精华" and "分解灵宝精华，可获得灵宝碎片，用于兑换其他精华。" or "分解灵石，可获得灵宝碎片，用于兑换灵宝精华。"
        BrkTable = {
            num = tonumber(data:GetAttr(ItemAttr_Native.Amount)),
            guid = guid,
            flag = itemDB.ShowType == "灵宝精华" and 1 or 2,
        }
        GUI.EditSetTextM(brkNum,BrkTable["num"])
        GUI.RegisterUIEvent(brkBuy, UCE.PointerClick , "SpiritualEquipBrkUI", "OnBrkBtnClick2")
    end

    local tipsTxt = _gt.GetUI("tipsTxt")
    local iconBg = _gt.GetUI("iconBg")
    local icon = GUI.GetChild(iconBg, "icon", false)
    local equipInfo = _gt.GetUI("equipInfo")
    local brkBg = _gt.GetUI("brkBg")
    local brk = GUI.GetChild(brkBg, "brk", false)
    local brkInfo = _gt.GetUI("brkInfo")
    GUI.SetVisible(_gt.GetUI("brokeCover"), true)

    GUI.SetVisible(brkNum, BrkTable ~= nil)
    GUI.StaticSetText(tipsTxt, tips)
    GUI.ImageSetImageID(iconBg, QualityRes[itemDB.Grade])
    GUI.ImageSetImageID(icon, itemDB.Icon)
    GUI.StaticSetText(equipInfo, str)
    GUI.ImageSetImageID(brkBg, QualityRes[brkDB.Grade])
    GUI.ImageSetImageID(brk, brkDB.Icon)
    GUI.StaticSetText(brkInfo, brkDB.Name .. "\n分解可得碎片:" .. num)
end

function SpiritualEquipBrkUI.OnBrkBtnClick()
    if TipsConfig == nil then
        return
    end
    local guid = TipsConfig["itemData"].guid
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "Disassemble", tostring(guid))
    SpiritualEquipBrkUI.OnBrokeClose()
end

function SpiritualEquipBrkUI.OnBrkBtnClick2()
    if BrkTable == nil then
        return
    end
    local brkNum = _gt.GetUI("brkNum")
    local num = math.floor(tonumber(GUI.EditGetTextM(brkNum)))
    --test("flag : " .. tostring(BrkTable["flag"]) .. " guid : " .. tostring(BrkTable["guid"]) .. " num : " .. tostring(BrkTable["num"]))
    CL.SendNotify(NOTIFY.SubmitForm, "FormSpiritualEquip", "DisassembleEssenceStone", BrkTable["flag"], BrkTable["guid"], num)
    SpiritualEquipBrkUI.OnBrokeClose()
end

function SpiritualEquipBrkUI.SetFont2(font)
    SetAnchorAndPivot(font, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(font, TextAnchor.MiddleLeft)
    GUI.SetColor(font, ColorType_FontColor2)
    GUI.StaticSetFontSize(font, 22)
end

function SpiritualEquipBrkUI.BrkNumValueChange()
    local brkNum = _gt.GetUI("brkNum")
    local num = math.floor(tonumber(GUI.EditGetTextM(brkNum)))
    if BrkTable == nil then
        return
    end

    if num > BrkTable["num"] then
        num = BrkTable["num"]
    end
    GUI.EditSetTextM(brkNum,num)

    local brkInfo = _gt.GetUI("brkInfo")

    local data = LD.GetItemDataByGuid(tostring(Guid), item_container_type.item_container_bag)
    local itemDB = DB.GetOnceItemByKey1(data.id)
    local type = itemDB.ShowType == "灵宝精华" and SpiritualEquipDisassembleTB["Grade"..itemDB.Grade]["Essence"] or SpiritualEquipDisassembleTB["Grade"..itemDB.Grade]["Stone"]
    local brkDB = DB.GetOnceItemByKey1(type["ItemId"])
    local sum = math.floor(tonumber(num * type["ratio"]))
    GUI.StaticSetText(brkInfo, brkDB.Name .. "\n分解可得碎片:" .. sum)
end

function SpiritualEquipBrkUI.OnBrokeClose()
    GUI.SetVisible(_gt.GetUI("brokeCover"), false)
end