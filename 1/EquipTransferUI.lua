local EquipTransferUI = {}
_G.EquipTransferUI = EquipTransferUI
local _gt = UILayout.NewGUIDUtilTable()
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local EquipTransferTable = {}
local EquipTransferConsume = {}
local EquipTransferIndexTable = {}
local EquipBasicsTable = {}
local BagEquipTable = nil
local SelectCheckBoxEquipKeyName = nil
local SelectCheckBoxEquipItemGuid = nil
local IsShow = false
local EquipIsBound = nil
local TransferRole = {}
local AfterEquipKeyName = nil
local SelectCheckBoxEquipGuid = nil
local EquipTransferFreeNum = nil
local EquipTransferTips = nil
local QualityRes =
{
    "1800400330","1800400100","1800400110","1800400120","1800400320"
}

local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")

local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255);
local outlineWhite = Color.New(186 / 255, 93 / 255, 18 / 255, 255 / 255);
local colorYellow = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255);
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255);
local colorBlue = Color.New(55 / 255, 160 / 255, 248 / 255, 255 / 255);
local colorBrown = Color.New(120 / 255, 65 / 255, 10 / 255, 255 / 255);
local colorGreen = Color.New(25 / 255, 200 / 255, 0 / 255, 255 / 255);
local colorRed = Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255);

function EquipTransferUI.Main(parameter)

    local panel = GUI.WndCreateWnd("EquipTransferUI", "EquipTransferUI", 0, 0)
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)

    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "装备转换", "EquipTransferUI", "OnExit", _gt)
    _gt.BindName(panelBg,"EquipTransferUIPanelBg")

    local equipScrollBg = GUI.ImageCreate(panelBg,"equipScrollBg", "1800400200", -371, 10,  false, 290, 550)

    local equipScroll = GUI.LoopScrollRectCreate(
            panelBg,
            "equipScroll",
            -371,
            10,
            285,
            540,
            "EquipTransferUI",
            "CreateEquip",
            "EquipTransferUI",
            "RefreshEquip",
            0,
            false,
            Vector2.New(280, 108),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top,
            false
    )
    _gt.BindName(equipScroll,"equipScroll")
    GUI.ScrollRectSetNormalizedPosition(equipScroll, Vector2.New(0, 0))


    local emptyText = GUI.CreateStatic(panelBg,"emptyText", "背包中没有可转换的武器", -371, -205,  250, 30, "system", true)
    GUI.SetColor(emptyText, colorDark);
    GUI.StaticSetFontSize(emptyText, 22)
    GUI.SetAnchor(emptyText, UIAnchor.Center)
    GUI.SetPivot(emptyText, UIAroundPivot.Center)
    _gt.BindName(emptyText,"emptyText")

    GUI.ImageCreate(panelBg,"upBg", "1801200100", 150, -160,  false, 720, 200,false)
    GUI.ImageCreate(panelBg,"downBg", "1801200110", 150, 60,  false, 720, 240,false)

    local currentBg = GUI.ImageCreate(panelBg, "currentBg", "1801100030", -45, -160, false, 300, 160)

    local title = GUI.CreateStatic(currentBg, "title", "当前", -85, -60, 100, 30, "system", true)
    GUI.SetColor(title, colorDark)
    GUI.StaticSetFontSize(title, 24)

    local BeforeEquipIcon=ItemIcon.Create(panelBg,"BeforeEquipIcon",-135,140,90,90)
    GUI.SetAnchor(BeforeEquipIcon, UIAnchor.Top)
    GUI.SetPivot(BeforeEquipIcon, UIAroundPivot.Top)
    GUI.RegisterUIEvent(BeforeEquipIcon, UCE.PointerClick, "EquipTransferUI", "OnBeforeEquipIconClick")

    local BeforeName = GUI.CreateStatic(currentBg,"BeforeName", "名字", 115, -5,  200, 30, "system", true);
    GUI.SetColor(BeforeName, colorDark);
    GUI.StaticSetFontSize(BeforeName, 24);
    GUI.SetAnchor(BeforeName, UIAnchor.Left);
    GUI.SetPivot(BeforeName, UIAroundPivot.Left)
    GUI.SetVisible(BeforeName,IsShow)

    local BeforeLevel = GUI.CreateStatic(currentBg,"BeforeLevel", "1级", 115, 30,  200, 30, "system", true)
    GUI.StaticSetFontSize(BeforeLevel, 22)
    GUI.SetColor(BeforeLevel, colorYellow)
    GUI.SetAnchor(BeforeLevel, UIAnchor.Left)
    GUI.SetPivot(BeforeLevel, UIAroundPivot.Left)
    GUI.SetVisible(BeforeLevel,IsShow)


    GUI.ImageCreate(panelBg,"arrow", "1801107010", 155, -159)

    --转换后背景
    local afterBg = GUI.ButtonCreate(panelBg,"afterBg", "1801100030", 345, -160,  Transition.ColorTint, "", 300, 160, false)
    GUI.RegisterUIEvent(afterBg, UCE.PointerClick, "EquipTransferUI", "OnAfterBgClick")

    local title = GUI.CreateStatic(afterBg, "title", "转换后", -85, -60, 100, 30, "system", true)
    GUI.SetColor(title, colorDark)
    GUI.StaticSetFontSize(title, 24)

    local AfterEquipIconBg=GUI.ImageCreate(afterBg,"AfterEquipIconBg",QualityRes[1],-90,20,false,90,90)

    local AfterEquipIcon=GUI.ImageCreate(AfterEquipIconBg,"AfterEquipIcon","1800707060",0,0)
    GUI.SetVisible(AfterEquipIcon,false)

    local IsBound = GUI.ImageCreate(AfterEquipIcon,"IsBound","1800707120",-22,-22)
    GUI.SetVisible(IsBound,false)


    local AfterName = GUI.CreateStatic(afterBg,"AfterName", "名字", 115, -5,  200, 30, "system", true)
    GUI.SetColor(AfterName, colorDark)
    GUI.StaticSetFontSize(AfterName, 24)
    GUI.SetAnchor(AfterName, UIAnchor.Left)
    GUI.SetPivot(AfterName, UIAroundPivot.Left)
    GUI.SetVisible(AfterName, false)

    local AfterLevel = GUI.CreateStatic(afterBg, "AfterLevel", "1级", 115, 30, 200, 30, "system", true)
    GUI.StaticSetFontSize(AfterLevel, 22)
    GUI.SetColor(AfterLevel, colorYellow)
    GUI.SetAnchor(AfterLevel, UIAnchor.Left)
    GUI.SetPivot(AfterLevel, UIAroundPivot.Left)
    GUI.SetVisible(AfterLevel, false)

    local addText = GUI.CreateStatic(afterBg,"addText", "点击添加", 115, 12,  120, 30, "system", true)
    GUI.StaticSetFontSize(addText, 22)
    GUI.SetColor(addText, colorYellow)
    GUI.SetAnchor(addText, UIAnchor.Left)
    GUI.SetPivot(addText, UIAroundPivot.Left)

    local infoGroup = GUI.GroupCreate(panelBg,"infoGroup", 150, 60,  720, 240)
    local text = GUI.CreateStatic(infoGroup,"text", "转换后，以下属性全部继承", 0, -95,  300, 30, "system", true)
    GUI.StaticSetFontSize(text, 22);
    GUI.SetColor(text, colorYellow);
    GUI.SetAnchor(text, UIAnchor.Center);
    GUI.SetPivot(text, UIAroundPivot.Center);
    GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)

    local BaseAttackText = GUI.CreateStatic(infoGroup, "BaseAttackText", "基础攻击：", 25, -65, 120, 30, "system", true)
    GUI.StaticSetFontSize(BaseAttackText, 24)
    GUI.SetColor(BaseAttackText, colorDark)
    GUI.SetAnchor(BaseAttackText, UIAnchor.Left)
    GUI.SetPivot(BaseAttackText, UIAroundPivot.Left)

    local EquipBasicsLoop =
    GUI.LoopScrollRectCreate(
            infoGroup,
            "EquipBasicsLoop",
            50,
            70,
            190,
            93,
            "EquipTransferUI",
            "CreateEquipBasicsItem",
            "EquipTransferUI",
            "RefreshEquipBasicsItem",
            0,
            false,
            Vector2.New(190,30),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top,
            false
    )
    UILayout.SetSameAnchorAndPivot(EquipBasicsLoop, UILayout.TopLeft)
    GUI.ScrollRectSetAlignment(EquipBasicsLoop, TextAnchor.UpperCenter)
    _gt.BindName(EquipBasicsLoop, "EquipBasicsLoop")
    GUI.ScrollRectSetChildSpacing(EquipBasicsLoop, Vector2.New(0, 2))


    local text = GUI.CreateStatic(infoGroup,"text", "强化等级：", 25, 65,  120, 30, "system", true);
    GUI.StaticSetFontSize(text, 24);
    GUI.SetColor(text, colorDark);
    GUI.SetAnchor(text, UIAnchor.Left);
    GUI.SetPivot(text, UIAroundPivot.Left)

    local enhanceLevel = GUI.CreateStatic(infoGroup,"enhanceLevel", "+10", 240, 65,  120, 30, "system", true);
    GUI.StaticSetFontSize(enhanceLevel, 22);
    GUI.SetColor(enhanceLevel, colorBlue);
    GUI.SetAnchor(enhanceLevel, UIAnchor.Left);
    GUI.SetPivot(enhanceLevel, UIAroundPivot.Right);
    GUI.StaticSetAlignment(enhanceLevel, TextAnchor.MiddleRight)

    local text = GUI.CreateStatic(infoGroup,"text", "耐久度：", 25, 95,  160, 30, "system", true);
    GUI.StaticSetFontSize(text, 24);
    GUI.SetColor(text, colorDark);
    GUI.SetAnchor(text, UIAnchor.Left);
    GUI.SetPivot(text, UIAroundPivot.Left)

    local durable = GUI.CreateStatic(infoGroup,"durable", "99/99", 240, 95,  120, 30, "system", true);
    GUI.StaticSetFontSize(durable, 22);
    GUI.SetColor(durable, colorGreen);
    GUI.SetAnchor(durable, UIAnchor.Left);
    GUI.SetPivot(durable, UIAroundPivot.Right);
    GUI.StaticSetAlignment(durable, TextAnchor.MiddleRight)

    local text = GUI.CreateStatic(infoGroup,"text", "宝石镶嵌：", 350, -65,  120, 30, "system", true);
    GUI.StaticSetFontSize(text, 24);
    GUI.SetColor(text, colorDark);
    GUI.SetAnchor(text, UIAnchor.Left);
    GUI.SetPivot(text, UIAroundPivot.Left)

    local gemCount = GUI.CreateStatic(infoGroup,"gemCount", "（3/3）", 465, -65,  150, 30, "system", true);
    GUI.StaticSetFontSize(gemCount, 24);
    GUI.SetColor(gemCount, colorDark);
    GUI.SetAnchor(gemCount, UIAnchor.Left);
    GUI.SetPivot(gemCount, UIAroundPivot.Left)

    local GemLoop =
    GUI.LoopScrollRectCreate(
            infoGroup,
            "GemLoop",
            -31,
            70,
            315,
            93,
            "EquipTransferUI",
            "CreateGemLoopItem",
            "EquipTransferUI",
            "RefreshGemLoopItem",
            0,
            false,
            Vector2.New(315,35),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top,
            false
    )
    UILayout.SetSameAnchorAndPivot(GemLoop, UILayout.TopRight)
    GUI.ScrollRectSetAlignment(GemLoop, TextAnchor.UpperCenter)
    _gt.BindName(GemLoop, "GemLoop")
    GUI.ScrollRectSetChildSpacing(GemLoop, Vector2.New(0, 2))

    local text = GUI.CreateStatic(infoGroup,"text", "特效：", 350, 65,  120, 30, "system", true);
    GUI.StaticSetFontSize(text, 24);
    GUI.SetColor(text, colorDark);
    GUI.SetAnchor(text, UIAnchor.Left);
    GUI.SetPivot(text, UIAroundPivot.Left)

    local text = GUI.CreateStatic(infoGroup,"text", "特技：", 350, 95,  120, 30, "system", true);
    GUI.StaticSetFontSize(text, 24);
    GUI.SetColor(text, colorDark);
    GUI.SetAnchor(text, UIAnchor.Left);
    GUI.SetPivot(text, UIAroundPivot.Left)

    local skill1 = GUI.CreateStatic(infoGroup,"skill1", "无", 530, 65,  150, 30, "system");
    GUI.StaticSetFontSize(skill1, 22);
    GUI.SetColor(skill1, colorRed);
    GUI.SetAnchor(skill1, UIAnchor.Left);
    GUI.SetPivot(skill1, UIAroundPivot.Center);
    GUI.StaticSetAlignment(skill1, TextAnchor.MiddleCenter)

    local skill2 = GUI.CreateStatic(infoGroup,"skill2", "无", 530, 95,  150, 30, "system");
    GUI.StaticSetFontSize(skill2, 22);
    GUI.SetColor(skill2, colorRed);
    GUI.SetAnchor(skill2, UIAnchor.Left);
    GUI.SetPivot(skill2, UIAroundPivot.Center);
    GUI.StaticSetAlignment(skill2, TextAnchor.MiddleCenter)

    local TipsBtn = GUI.ButtonCreate(panelBg,"TipsBtn", "1800702030", 480, -30,  Transition.ColorTint)
    GUI.RegisterUIEvent(TipsBtn, UCE.PointerClick, "EquipTransferUI", "OnTipsBtnClick")

    local MaterialsIcon=ItemIcon.Create(panelBg,"MaterialsIcon",0,-60,80,80)
    GUI.SetAnchor(MaterialsIcon, UIAnchor.Bottom)
    GUI.SetPivot(MaterialsIcon, UIAroundPivot.Bottom)
    GUI.RegisterUIEvent(MaterialsIcon, UCE.PointerClick, "EquipTransferUI", "OnMaterialsIconClick")
    GUI.SetVisible(MaterialsIcon,IsShow)

    local MaterialName = GUI.CreateStatic(MaterialsIcon,"MaterialName", "四字材料", 0, -52,  100, 30, "system", true)
    GUI.SetColor(MaterialName, colorDark);
    GUI.StaticSetFontSize(MaterialName, 20);
    GUI.SetAnchor(MaterialName, UIAnchor.Center);
    GUI.SetPivot(MaterialName, UIAroundPivot.Center)
    GUI.StaticSetAlignment(MaterialName, TextAnchor.MiddleCenter)


    local MaterialText = GUI.CreateStatic(MaterialsIcon,"MaterialText", "转换所需材料：", -155, 30,  160, 30, "system", true);
    GUI.StaticSetFontSize(MaterialText, 22);
    GUI.SetColor(MaterialText, colorBrown)
    GUI.SetAnchor(MaterialText, UIAnchor.Left)
    GUI.SetPivot(MaterialText, UIAroundPivot.Left)

    local freeText = GUI.CreateStatic(panelBg,"freeText", "免费转换次数：", 920, 205,  180, 30, "system", true);
    GUI.StaticSetFontSize(freeText, 22);
    GUI.SetColor(freeText, colorBrown);
    GUI.SetAnchor(freeText, UIAnchor.Left);
    GUI.SetPivot(freeText, UIAroundPivot.Left)

    local freeCount = GUI.CreateStatic(panelBg,"freeCount", "0", 1075, 205,  30, 30, "system", true);
    GUI.StaticSetFontSize(freeCount, 22);
    GUI.SetColor(freeCount, colorRed);
    GUI.SetAnchor(freeCount, UIAnchor.Left);
    GUI.SetPivot(freeCount, UIAroundPivot.Left);

    local tranferBtn = GUI.ButtonCreate(panelBg,"tranferBtn", "1800002060", 410, 255,  Transition.ColorTint, "", 180, 60, false);
    GUI.RegisterUIEvent(tranferBtn, UCE.PointerClick, "EquipTransferUI", "OnTranferBtnClick")
    GUI.ButtonSetShowDisable(tranferBtn, true)
    _gt.BindName(tranferBtn,"tranferBtn")

    local text = GUI.CreateStatic( tranferBtn,"text", "转换", 0, 0, 100, 36, "system", true);
    GUI.SetColor(text, colorWhite);
    GUI.StaticSetFontSize(text, 28);
    GUI.SetAnchor(text, UIAnchor.Center);
    GUI.SetPivot(text, UIAroundPivot.Center);
    GUI.SetIsOutLine(text, true);
    GUI.SetOutLine_Distance(text, 1)
    GUI.StaticSetAlignment(text,TextAnchor.MiddleCenter)
    GUI.SetOutLine_Color(text, outlineWhite);
end

function EquipTransferUI.OnShow()
    local wnd = GUI.GetWnd("EquipTransferUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd,true)

    local PanelBg = _gt.GetUI("EquipTransferUIPanelBg")
    local MaterialsIcon = GUI.GetChild(PanelBg,"MaterialsIcon")
    --免费次数
    EquipTransferFreeNum = tostring(CL.GetIntCustomData("EquipChange_FreeChangeNum_Weapon",0))
    if tonumber(EquipTransferFreeNum) > 0 then
        GUI.SetVisible(MaterialsIcon,true)
    else
        GUI.SetVisible(MaterialsIcon,false)
    end


    IsShow = false
    EquipTransferUI.Register()
    AfterEquipKeyName = nil
    EquipTransferUI.Init()
end

function EquipTransferUI.Init()
    SelectCheckBoxEquipGuid = nil
    EquipBasicsTable = {}
end

function EquipTransferUI.CreateEquipBasicsItem()
    local EquipBasicsLoop = _gt.GetUI("EquipBasicsLoop")
    local Index = GUI.LoopScrollRectGetChildInPoolCount(EquipBasicsLoop) + 1
    local EquipItemGroup = GUI.GroupCreate(EquipBasicsLoop,"EquipItemGroup"..Index,0,0,190,40)
    UILayout.SetSameAnchorAndPivot(EquipItemGroup, UILayout.TopLeft)

    local attName = GUI.CreateStatic(EquipItemGroup,"attName", "基础攻击", 0, 0,  120, 30, "system", true)
    GUI.StaticSetFontSize(attName, 22)
    GUI.SetColor(attName, colorBrown)
    GUI.SetAnchor(attName, UIAnchor.Left)
    GUI.SetPivot(attName, UIAroundPivot.Left)

    local attValue = GUI.CreateStatic(EquipItemGroup, "attValue", "100", 0, 0, 120, 30, "system", true);
    GUI.StaticSetFontSize(attValue, 22);
    GUI.SetColor(attValue, colorGreen);
    GUI.SetAnchor(attValue, UIAnchor.Right);
    GUI.SetPivot(attValue, UIAroundPivot.Right);
    GUI.StaticSetAlignment(attValue, TextAnchor.MiddleRight)

    return EquipItemGroup
end

function EquipTransferUI.RefreshEquipBasicsItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local EquipItemGroup = GUI.GetByGuid(guid)

    local attName = GUI.GetChild(EquipItemGroup,"attName",false)
    local attValue = GUI.GetChild(EquipItemGroup,"attValue",false)

    local value = tostring(EquipBasicsTable[index].value)
    if EquipBasicsTable[index].Id ~= 0 then
        if EquipBasicsTable[index].IsPct then
            value = tostring(tonumber(value) / 100) .. "%"
        end
        GUI.StaticSetText(attName,EquipBasicsTable[index].name)
        GUI.StaticSetText(attValue,value)
    end

end

function EquipTransferUI.CreateGemLoopItem()
    local GemLoop = _gt.GetUI("GemLoop")
    local Index = GUI.LoopScrollRectGetChildInPoolCount(GemLoop) + 1
    local ItemGroup = GUI.GroupCreate(GemLoop,"ItemGroup"..Index,0,0,315,40)

    local gemName = GUI.CreateStatic(ItemGroup,"gemName", "3级红宝石", 0, 0,  120, 30, "system", true);
    GUI.StaticSetFontSize(gemName, 22);
    GUI.SetColor(gemName, colorBrown);
    GUI.SetAnchor(gemName, UIAnchor.Left);
    GUI.SetPivot(gemName, UIAroundPivot.Left)
    GUI.StaticSetAlignment(gemName, TextAnchor.MiddleLeft)

    local gemAtt = GUI.CreateStatic(ItemGroup,"gemAtt", "物爆+6 法爆+6", 0,0 ,  180, 30, "system", true);
    GUI.StaticSetFontSize(gemAtt, 22);
    GUI.SetColor(gemAtt, colorBlue);
    GUI.SetAnchor(gemAtt, UIAnchor.Right);
    GUI.SetPivot(gemAtt, UIAroundPivot.Right);
    GUI.StaticSetAlignment(gemAtt, TextAnchor.MiddleRight)

    return ItemGroup
end

function EquipTransferUI.RefreshGemLoopItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local ItemGroup = GUI.GetByGuid(guid)
    local EquipData = LD.GetItemDataByGuid(SelectCheckBoxEquipGuid,item_container_type.item_container_bag,0)
    --宝石镶嵌
    local gemCount, siteCount = LogicDefine.GetEquipGemCount(EquipData)
    local GemName = GUI.GetChild(ItemGroup,"gemName",false)
    local GemAtt = GUI.GetChild(ItemGroup,"gemAtt",false)
    local gemId = EquipData:GetIntCustomAttr(LogicDefine.ITEM_GemId_ .. index)
    if gemId ~= 0 then
        local gemDB = DB.GetOnceItemByKey1(gemId)
        GUI.StaticSetText(GemName,gemDB.Name)
        local attrDatas = EquipData:GetDynAttrDataByMark(LogicDefine.ITEM_GemAttrMark[index])
        local GemAttribute = ""
        for i = 0, attrDatas.Count - 1 do
            local attrData = attrDatas[i]
            local attrId = attrData.attr
            local value = attrData.value
            GemAttribute = GemAttribute..UIDefine.GetAttrDesStr(attrId, value)
            if attrDatas.Count > 1 then
                if i == 0 then
                    GemAttribute = GemAttribute.." "
                end
            end
        end
        GUI.StaticSetText(GemAtt,GemAttribute)
    end
end

function EquipTransferUI.Refresh()
    --免费次数
    EquipTransferFreeNum = tostring(CL.GetIntCustomData("EquipChange_FreeChangeNum_Weapon",0))

    --获取装备表单数据
    EquipTransferTable = EquipTransferUI.EquipTransferTable
    --转换武器材料表
    if not next(EquipTransferConsume) then
        EquipTransferConsume = EquipTransferUI.EquipTransferConsume
    end

    --Tip内容
    if EquipTransferTips == nil then
        EquipTransferTips = EquipTransferUI.EquipTransferTips
    end
    if SelectCheckBoxEquipGuid == nil then
        --遍历背包表单数据
        EquipTransferUI.GetBagEquip()
        --重新设置装备列表内容
        EquipTransferUI.UpdatePresentList()
    end
    --人物转换记录表
    EquipTransferUI.TransferTable()
    --重新设置是否显示
    EquipTransferUI.UpdateAfterEquipItem()
end

function EquipTransferUI.UpdateAfterEquipItem()
    --一级分栏
    local EquipTransferUIPanelBg = _gt.GetUI("EquipTransferUIPanelBg")
    --二级分栏
    local AfterBg = GUI.GetChild(EquipTransferUIPanelBg,"afterBg")
    local FreeCount = GUI.GetChild(EquipTransferUIPanelBg,"freeCount")
    local MaterialsIcon = GUI.GetChild(EquipTransferUIPanelBg,"MaterialsIcon")
    --三级分栏
    local AfterEquipIconBg = GUI.GetChild(AfterBg,"AfterEquipIconBg")
    local AddText = GUI.GetChild(AfterBg,"addText")
    local AfterName = GUI.GetChild(AfterBg,"AfterName")
    local AfterLevel = GUI.GetChild(AfterBg,"AfterLevel")

    --四级分栏
    local AfterEquipIcon = GUI.GetChild(AfterEquipIconBg,"AfterEquipIcon")
    --五级分栏
    local IsBound = GUI.GetChild(AfterEquipIcon,"IsBound")
    if AfterEquipKeyName ~= nil then
        GUI.ImageSetImageID(AfterEquipIconBg,QualityRes[1])
        GUI.SetVisible(AfterName,false)
        GUI.SetVisible(AfterLevel,false)
        GUI.ImageSetImageID(AfterEquipIcon,"1800707060")
        GUI.SetVisible(IsBound,false)
        GUI.SetVisible(MaterialsIcon,false)
    else
        if tonumber(EquipTransferFreeNum) > 0 then
            GUI.SetVisible(MaterialsIcon,true)
        end
    end
    GUI.StaticSetText(FreeCount,tonumber(EquipTransferFreeNum))

end

function EquipTransferUI.TransferTable()
    local RoleIds = DB.GetRoleAllKeys()
    for i = 0, RoleIds.Count-1 do
        local RoleDB = DB.GetRole(RoleIds[i])
        local RoleConsume = nil
        local RoleConsumeNum = nil
        local TransferStatus = tonumber(CL.GetIntCustomData("ChangeOccu_UsedRole_"..tostring(RoleDB.Id)))
        if TransferStatus == 0 then
            RoleConsume = EquipTransferUI.EquipTransferConsume["Base"][1]
            RoleConsumeNum = EquipTransferUI.EquipTransferConsume["Base"][2]
        else
            RoleConsume = EquipTransferUI.EquipTransferConsume["CheckRole"][1]
            RoleConsumeNum = EquipTransferUI.EquipTransferConsume["CheckRole"][2]
        end
        local RoleTable = {
            RoleConsume = RoleConsume,
            RoleConsumeNum = RoleConsumeNum
        }
        TransferRole[tonumber(RoleDB.Id)] = RoleTable
    end
end

function EquipTransferUI.CreateEquip()
    local equipScroll = _gt.GetUI("equipScroll")
    local curIndex = GUI.LoopScrollRectGetChildInPoolCount(equipScroll)+1
    local name = "EquipListItem" .. curIndex

    -- 背景
    local EquipContactItem = GUI.CheckBoxExCreate(equipScroll,name, "1800700030", "1800700040", 1, 0,  false, 300, 140)
    GUI.SetAnchor(EquipContactItem, UIAnchor.Top)
    GUI.SetPivot(EquipContactItem, UIAroundPivot.Top)
    GUI.RegisterUIEvent(EquipContactItem, UCE.PointerClick , "EquipTransferUI", "OnEquipContactItemClick")

    --装备图标
    local ItemIconBg = GUI.ItemCtrlCreate(EquipContactItem,"ItemIconBg",QualityRes[1],-85,10,90,90)

    --装备名字
    local EquipName = GUI.CreateStatic(EquipContactItem,"EquipName", "装备名字", 60, -20, 180, 36, "system", true)
    GUI.SetColor(EquipName, colorDark)
    GUI.StaticSetFontSize(EquipName, 26)
    GUI.SetAnchor(EquipName, UIAnchor.Center)
    GUI.SetPivot(EquipName, UIAroundPivot.Center)
    GUI.StaticSetAlignment(EquipName,TextAnchor.MiddleLeft)

    --装备等级
    local EquipLevel = GUI.CreateStatic(EquipContactItem,"EquipLevel", "120级", 20, -20, 100, 36, "system", true)
    GUI.SetColor(EquipLevel, colorYellow)
    GUI.StaticSetFontSize(EquipLevel, 24)
    GUI.SetAnchor(EquipLevel, UIAnchor.Bottom)
    GUI.SetPivot(EquipLevel, UIAroundPivot.Bottom)
    GUI.StaticSetAlignment(EquipLevel,TextAnchor.MiddleLeft)

    --装备类型
    local EquipType = GUI.CreateStatic(EquipContactItem,"EquipType", "★三个字★", 0, -20, 130, 36, "system", true)
    GUI.SetColor(EquipType, colorYellow)
    GUI.StaticSetFontSize(EquipType, 24)
    GUI.SetAnchor(EquipType, UIAnchor.BottomRight)
    GUI.SetPivot(EquipType, UIAroundPivot.BottomRight)
    GUI.StaticSetAlignment(EquipType,TextAnchor.MiddleCenter)

    return EquipContactItem
end

function EquipTransferUI.RefreshEquip(parameter)
    parameter = string.split(parameter , "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])+1
    local item=GUI.GetByGuid(guid)
    if not item then
        return
    end

    GUI.SetData(item,"CheckBoxEquipIndex",index)

    local ItemIconBg = GUI.GetChild(item,"ItemIconBg")
    local EquipName = GUI.GetChild(item,"EquipName")
    local EquipLevel = GUI.GetChild(item,"EquipLevel")
    local EquipType = GUI.GetChild(item,"EquipType")
    local temp = BagEquipTable[index]
    EquipTransferIndexTable[tostring(temp.Guid)] = tonumber(index)
    if temp then
        if SelectCheckBoxEquipGuid == nil then
            if index == 1 then
                GUI.CheckBoxExSetCheck(item, true)
                SelectCheckBoxEquipItemGuid = guid
                EquipTransferUI.RefreshEquipTransferItem(tostring(temp.Id),tostring(index),tostring(temp.Guid))
                SelectCheckBoxEquipKeyName = tostring(temp.KeyName)
                SelectCheckBoxEquipGuid = tostring(temp.Guid)
            else
                GUI.CheckBoxExSetCheck(item, false)
            end
        else
            if AfterEquipKeyName == nil then
                if index == 1 then
                    GUI.CheckBoxExSetCheck(item, true)
                    SelectCheckBoxEquipItemGuid = guid
                    EquipTransferUI.RefreshEquipTransferItem(tostring(temp.Id),tostring(index),tostring(temp.Guid))
                    SelectCheckBoxEquipKeyName = tostring(temp.KeyName)
                    SelectCheckBoxEquipGuid = tostring(temp.Guid)
                else
                    GUI.CheckBoxExSetCheck(item, false)
                end
            else
                local NowClickIndex = EquipTransferIndexTable[SelectCheckBoxEquipGuid]
                if tonumber(NowClickIndex) == tonumber(index) then
                    GUI.CheckBoxExSetCheck(item, true)
                    SelectCheckBoxEquipItemGuid = guid
                    EquipTransferUI.RefreshEquipTransferItem(tostring(temp.Id),tostring(index),tostring(temp.Guid))
                    SelectCheckBoxEquipKeyName = tostring(temp.KeyName)
                    SelectCheckBoxEquipGuid = tostring(temp.Guid)
                else
                    GUI.CheckBoxExSetCheck(item, false)
                end
            end

        end


        IsShow = true
        EquipTransferUI.ShowItem(IsShow)

        GUI.SetData(item,"CheckBoxEquipKeyName",temp.KeyName)
        GUI.SetData(item,"CheckBoxEquipId",temp.Id)
        GUI.SetData(item,"CheckBoxEquipGuid",temp.Guid)

        local itemData = DB.GetOnceItemByKey1(temp.Id)
        GUI.ItemCtrlSetElementValue(ItemIconBg,eItemIconElement.Icon,itemData.Icon)
        GUI.ItemCtrlSetElementValue(ItemIconBg,eItemIconElement.Border,QualityRes[temp.Grade])
        if tonumber(temp.IsBound)  == 1 then
            GUI.ItemCtrlSetElementValue(ItemIconBg,eItemIconElement.LeftTopSp,"1800707120")--是否为绑定
        else
            GUI.ItemCtrlSetElementValue(ItemIconBg,eItemIconElement.LeftTopSp,nil)--是否为绑定
        end
        GUI.StaticSetText(EquipName,temp.Name)

        if tostring(temp.ShowType) == "★无级别★" then
            GUI.SetVisible(EquipLevel,false)
        else
            GUI.SetVisible(EquipLevel,true)
            GUI.StaticSetText(EquipLevel,temp.Level.."级")
        end
        GUI.StaticSetText(EquipType,temp.ShowType)
    end
end

function EquipTransferUI.OnEquipContactItemClick(guid)
    local element = GUI.GetByGuid(guid)
    if element == nil then
        return
    end
    local EquipKeyName = tostring(GUI.GetData(element, "CheckBoxEquipKeyName"))
    local EquipId = tostring(GUI.GetData(element, "CheckBoxEquipId"))
    local EquipIndex = tostring(GUI.GetData(element, "CheckBoxEquipIndex"))
    local EquipGuid = tostring(GUI.GetData(element, "CheckBoxEquipGuid"))

    --一级分栏
    local PanelBg = _gt.GetUI("EquipTransferUIPanelBg")
    --二级分栏
    local AfterBg = GUI.GetChild(PanelBg,"afterBg")
    local MaterialsIcon = GUI.GetChild(PanelBg,"MaterialsIcon")
    local tranferBtn =  GUI.GetChild(PanelBg,"tranferBtn")
    --三级分栏
    local AfterEquipIconBg = GUI.GetChild(AfterBg,"AfterEquipIconBg")
    local AfterEquipIcon = GUI.GetChild(AfterBg,"AfterEquipIcon")
    local AfterName = GUI.GetChild(AfterBg,"AfterName")
    local AfterLevel = GUI.GetChild(AfterBg,"AfterLevel")
    local AddText = GUI.GetChild(AfterBg,"addText")
    local IsBound = GUI.GetChild(AfterEquipIcon,"IsBound")
    GUI.ImageSetImageID(AfterEquipIconBg,QualityRes[1])
    GUI.ImageSetImageID(AfterEquipIcon,"1800707060")
    GUI.SetVisible(AddText,true)
    GUI.SetVisible(AfterName,false)
    GUI.SetVisible(AfterLevel,false)
    GUI.SetVisible(IsBound,false)
    GUI.SetVisible(MaterialsIcon,false)
    GUI.ButtonSetShowDisable(tranferBtn, false)
    if guid ~= SelectCheckBoxEquipItemGuid then
        local item = GUI.GetByGuid(SelectCheckBoxEquipItemGuid)
        GUI.CheckBoxExSetCheck(item, false)
    end
    GUI.CheckBoxExSetCheck(element, true)
    SelectCheckBoxEquipItemGuid = guid
    SelectCheckBoxEquipGuid = EquipGuid
    SelectCheckBoxEquipKeyName= tostring(EquipKeyName)

    EquipTransferUI.RefreshEquipTransferItem(EquipId,EquipIndex,EquipGuid)
end

function EquipTransferUI.RefreshEquipTransferItem(EquipId,EquipIndex,EquipGuid)
    --一级分栏
    local EquipTransferUIPanelBg = _gt.GetUI("EquipTransferUIPanelBg")
    local currentBg = GUI.GetChild(EquipTransferUIPanelBg,"currentBg")
    local BeforeEquipIcon = GUI.GetChild(EquipTransferUIPanelBg,"BeforeEquipIcon")
    local afterBg = GUI.GetChild(EquipTransferUIPanelBg,"afterBg")
    local infoGroup = GUI.GetChild(EquipTransferUIPanelBg,"infoGroup")

    --二级分栏
    local BeforeName = GUI.GetChild(currentBg,"BeforeName")
    local BeforeLevel = GUI.GetChild(currentBg,"BeforeLevel")
    local AfterEquipIconBg = GUI.GetChild(afterBg,"AfterEquipIconBg")
    local EnhanceLevel = GUI.GetChild(infoGroup,"enhanceLevel")
    local Durable = GUI.GetChild(infoGroup,"durable")
    local GemCount = GUI.GetChild(infoGroup,"gemCount")
    local Skill1 = GUI.GetChild(infoGroup,"skill1")
    local Skill2 = GUI.GetChild(infoGroup,"skill2")

    --三级分栏
    local AfterEquipIcon = GUI.GetChild(AfterEquipIconBg,"AfterEquipIcon")

    --数据请求
    local itemData = DB.GetOnceItemByKey1(tonumber(EquipId))

    --左边转换前装备图标设置
    GUI.ItemCtrlSetElementValue(BeforeEquipIcon,eItemIconElement.Border,QualityRes[BagEquipTable[tonumber(EquipIndex)].Grade])--背景设置
    GUI.ItemCtrlSetElementValue(BeforeEquipIcon,eItemIconElement.Icon,itemData.Icon)--物品图片设置
    if tonumber(BagEquipTable[tonumber(EquipIndex)].IsBound) == 1 then
        GUI.ItemCtrlSetElementValue(BeforeEquipIcon,eItemIconElement.LeftTopSp,"1800707120")--是否为绑定
        EquipIsBound = true
    else
        GUI.ItemCtrlSetElementValue(BeforeEquipIcon,eItemIconElement.LeftTopSp,"")--是否为绑定
        EquipIsBound = false
    end

    --右边转换前装备图标设置
    GUI.SetVisible(AfterEquipIcon,true)
    GUI.StaticSetText(BeforeName,BagEquipTable[tonumber(EquipIndex)].Name)
    if tostring(BagEquipTable[tonumber(EquipIndex)].ShowType) == "★无级别★" then
        GUI.StaticSetText(BeforeLevel,BagEquipTable[tonumber(EquipIndex)].ShowType)
    else
        GUI.StaticSetText(BeforeLevel,BagEquipTable[tonumber(EquipIndex)].Level.."级")
    end

    local EquipData = LD.GetItemDataByGuid(EquipGuid,item_container_type.item_container_bag,0)

    --基础攻击
    local temptable = {[15]=1,[16]=2,[17]=3,[18]=4,[19]=5}
    EquipBasicsTable = {}
    LogicDefine.GetItemDynAttrDataByMark(EquipData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, EquipBasicsTable)
    table.sort(EquipBasicsTable,function (a,b)
        if temptable[a.attr] and temptable[b.attr] == nil  then
            return false
        elseif temptable[a.attr] == nil  and temptable[b.attr] then
            return true
        elseif temptable[a.attr] and temptable[b.attr] then
            return a.attr < b.attr
        else
            return a.attr < b.attr
        end
    end)
    local EquipBasicsLoop = _gt.GetUI("EquipBasicsLoop")
    GUI.LoopScrollRectSetTotalCount(EquipBasicsLoop,#EquipBasicsTable)
    GUI.LoopScrollRectRefreshCells(EquipBasicsLoop)


    --装备强化等级
    local StrengthenLevel = EquipData:GetIntCustomAttr(LogicDefine.EnhanceLv)
    --武器耐久度
    local DurableNow = EquipData:GetIntCustomAttr("DurableNow")
    local DurableMax = EquipData:GetIntCustomAttr("DurableMax")
    if DurableMax ~= nil then
        if DurableMax == 0 then
            DurableNow = "无限"
            DurableMax = "无限"
        end
    end

    --宝石镶嵌
    local gemCount, siteCount = LogicDefine.GetEquipGemCount(EquipData)
    local GemLoop = _gt.GetUI("GemLoop")
    if gemCount > 0 then
        GUI.StaticSetText(GemCount,gemCount .. "/" .. siteCount)
    else
        GUI.StaticSetText(GemCount,0 .. "/" .. siteCount)
    end
    GUI.LoopScrollRectSetTotalCount(GemLoop,gemCount)
    GUI.LoopScrollRectRefreshCells(GemLoop)


    --特效
    local Equip_SpecialEffect =  EquipData:GetIntCustomAttr("Equip_SpecialEffect")
    local SpecialEffect = DB.GetOnceSkillByKey1(Equip_SpecialEffect)
    if SpecialEffect.Name == nil then
        GUI.StaticSetText(Skill1,"无")
        GUI.SetColor(Skill1,colorRed)
    else
        GUI.StaticSetText(Skill1,"【"..tostring(SpecialEffect.Name).."】")
        GUI.SetColor(Skill1, UIDefine.GradeColor[SpecialEffect.SkillQuality])
    end

    --特技
    local Equip_Stunt =  EquipData:GetIntCustomAttr("Equip_Stunt")
    local Stunt = DB.GetOnceSkillByKey1(Equip_Stunt)
    if Stunt.Name == nil then
        GUI.StaticSetText(Skill2,"无")
        GUI.SetColor(Skill2,colorRed)
    else
        GUI.StaticSetText(Skill2,"【"..tostring(Stunt.Name).."】")
        GUI.SetColor(Skill2, UIDefine.GradeColor[Stunt.SkillQuality])
    end

    GUI.StaticSetText(EnhanceLevel,"+"..StrengthenLevel)
    GUI.StaticSetText(Durable,  DurableNow .. "/" .. DurableMax)
end

function EquipTransferUI.ShowItem(IsShow)
    --一级分栏
    local EquipTransferUIPanelBg = _gt.GetUI("EquipTransferUIPanelBg")
    --二级分栏
    local currentBg = GUI.GetChild(EquipTransferUIPanelBg,"currentBg")
    local BeforeEquipIcon = GUI.GetChild(EquipTransferUIPanelBg,"BeforeEquipIcon")
    local afterBg = GUI.GetChild(EquipTransferUIPanelBg,"afterBg")
    local infoGroup = GUI.GetChild(EquipTransferUIPanelBg,"infoGroup")
    local MaterialsIcon = GUI.GetChild(EquipTransferUIPanelBg,"MaterialsIcon")
    local emptyText = GUI.GetChild(EquipTransferUIPanelBg,"emptyText")
    local tranferBtn = GUI.GetChild(EquipTransferUIPanelBg,"tranferBtn")
    --三级分栏
    local AfterEquipIconBg = GUI.GetChild(afterBg,"AfterEquipIconBg")
    local AfterName = GUI.GetChild(afterBg,"AfterName")
    local AfterLevel = GUI.GetChild(afterBg,"AfterLevel")
    --四级分栏
    local AfterEquipIcon = GUI.GetChild(AfterEquipIconBg,"AfterEquipIcon")
    --五级分栏
    local IsBound = GUI.GetChild(AfterEquipIcon,"IsBound")

    if IsShow == false then
        --左边转换前装备图标设置
        GUI.ItemCtrlSetElementValue(BeforeEquipIcon,eItemIconElement.Border,QualityRes[1])--背景设置
        GUI.ItemCtrlSetElementValue(BeforeEquipIcon,eItemIconElement.Icon,"")--物品图片设置
        GUI.ItemCtrlSetElementValue(BeforeEquipIcon,eItemIconElement.LeftTopSp,"")--是否为绑定
        GUI.SetVisible(MaterialsIcon,false)
        GUI.SetVisible(AfterEquipIcon,IsShow)
    else
        if AfterEquipKeyName == nil then
            GUI.SetVisible(MaterialsIcon,false)
            GUI.ButtonSetShowDisable(tranferBtn, false)

            --右边转换前装备图标设置
            GUI.ImageSetImageID(AfterEquipIconBg,QualityRes[1])
            GUI.ImageSetImageID(AfterEquipIcon,"1800707060")
            GUI.SetVisible(IsBound,false)
            GUI.SetVisible(AfterName,false)
            GUI.SetVisible(AfterLevel,false)
            GUI.SetVisible(AfterEquipIcon,IsShow)
        else
            GUI.SetVisible(MaterialsIcon,true)
        end

    end


    GUI.SetVisible(infoGroup,IsShow)

    GUI.SetVisible(emptyText, not IsShow)
    --三级分栏
    local BeforeName = GUI.GetChild(currentBg,"BeforeName")
    local BeforeLevel = GUI.GetChild(currentBg,"BeforeLevel")
    local addText = GUI.GetChild(afterBg,"addText")
    GUI.SetVisible(BeforeName,IsShow)
    GUI.SetVisible(BeforeLevel,IsShow)
    GUI.SetVisible(addText,IsShow)
end

local TableSet = function(a,b)
    if a.Level ~= b.Level then
        return a.Level < b.Level
    end
    if a.Grade ~= b.Grade then
        return a.Grade < b.Grade
    end
    return false
end

function EquipTransferUI.GetBagEquip()
    local BagEquipData = LogicDefine.GetEqiupInBag(nil, item_container_type.item_container_bag)
    BagEquipTable = {}
    if not BagEquipData then
        return
    end
    for k, v in pairs(BagEquipData) do
        local temp = {
            Guid = tostring(v.guid),
            Id = v.id,
            Grade = v.grade,
            KeyName = v.keyname,
            Level = v.lv,
            Name = v.name,
            ShowType = v.showType,
            SubType = tonumber(v.subtype),
            IsBound = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.IsBound,tostring(v.guid)))
        }
        for i = 1, #EquipTransferTable do
            if tostring(v.guid) == tostring(EquipTransferTable[i]) then
                BagEquipTable[#BagEquipTable + 1] = temp
            end
        end
    end
    table.sort(BagEquipTable, TableSet)
end

function EquipTransferUI.UpdatePresentList()
    local equipScroll = _gt.GetUI("equipScroll")
    if  #BagEquipTable > 0 then
        GUI.LoopScrollRectSetTotalCount(equipScroll, #BagEquipTable);
        GUI.LoopScrollRectRefreshCells(equipScroll)
        GUI.ScrollRectSetNormalizedPosition(equipScroll, Vector2.New(0, 0))
    else
        GUI.LoopScrollRectSetTotalCount(equipScroll,0)
        IsShow = false
        EquipTransferUI.ShowItem(IsShow)
    end
end

function EquipTransferUI.OnTipsBtnClick()
    local panelBg = GUI.TipsCreate(GUI.Get("EquipTransferUI/panelBg"), "Tips", 0, 0, 660, 150)
    GUI.SetIsRemoveWhenClick(panelBg, true)
    GUI.SetVisible(GUI.TipsGetItemIcon(panelBg),false)
    local TipsText = GUI.CreateStatic(panelBg,"TipsText",EquipTransferTips,0,0,620,420,"system", true)
    GUI.StaticSetFontSize(TipsText,22)


end

function EquipTransferUI.OnAfterBgClick()
    if #BagEquipTable > 0 then
        local EquipBeforeKeyName = tostring(SelectCheckBoxEquipKeyName)
        CL.SendNotify(NOTIFY.SubmitForm,"FormEquipChange","GetChangeData",tostring(EquipBeforeKeyName))
    end
end

function EquipTransferUI.SetAfterEquipId(EquipKeyName)
    AfterEquipKeyName = EquipKeyName
    if tostring(AfterEquipKeyName) ~= nil then
        --一级分栏
        local PanelBg = _gt.GetUI("EquipTransferUIPanelBg")
        --二级分栏
        local AfterBg = GUI.GetChild(PanelBg,"afterBg")
        local MaterialsIcon = GUI.GetChild(PanelBg,"MaterialsIcon")
        local TransferBtn = GUI.GetChild(PanelBg,"tranferBtn")
        --三级
        local MaterialName = GUI.GetChild(MaterialsIcon,"MaterialName")
        local AfterEquipIconBg = GUI.GetChild(AfterBg,"AfterEquipIconBg")
        local AfterName = GUI.GetChild(AfterBg,"AfterName")
        local AfterLevel = GUI.GetChild(AfterBg,"AfterLevel")
        local AddText = GUI.GetChild(AfterBg,"addText")
        --四级分栏
        local AfterEquipIcon = GUI.GetChild(AfterEquipIconBg,"AfterEquipIcon")

        --五级分栏
        local IsBound = GUI.GetChild(AfterEquipIcon,"IsBound")
        local AfterEquipDB = DB.GetOnceItemByKey2(tostring(AfterEquipKeyName))
        local ConsumDB = DB.GetOnceItemByKey2(tostring(EquipTransferConsume["Base"][1]))

        GUI.ImageSetImageID(AfterEquipIconBg,QualityRes[tonumber(AfterEquipDB.Grade)])
        GUI.ImageSetImageID(AfterEquipIcon,tostring(AfterEquipDB.Icon))
        GUI.SetVisible(AddText,false)
        GUI.StaticSetText(AfterName,AfterEquipDB.Name)
        GUI.SetVisible(AfterName,true)
        if tostring(AfterEquipDB.ShowType) == "★无级别★" then
            GUI.StaticSetText(AfterLevel,AfterEquipDB.ShowType)
        else
            GUI.StaticSetText(AfterLevel,AfterEquipDB.Itemlevel.."级")
        end

        GUI.SetVisible(AfterLevel,true)
        GUI.SetVisible(IsBound,EquipIsBound)
        GUI.ButtonSetShowDisable(TransferBtn, true)
        if tonumber(EquipTransferFreeNum) > 0 then
            GUI.SetVisible(MaterialsIcon,false)
        else
            GUI.SetVisible(MaterialsIcon,true)
        end
        GUI.StaticSetText(MaterialName,TransferRole[tonumber(AfterEquipDB.Role)].RoleConsume)
        if TransferRole[tonumber(AfterEquipDB.Role)].RoleConsumeNum == 2 and TransferRole[tonumber(AfterEquipDB.Role2)].RoleConsumeNum == 2 then
            ItemIcon.BindItemIdWithNum(MaterialsIcon,ConsumDB.Id, 2)
            GUI.ItemCtrlSetElementRect(MaterialsIcon, eItemIconElement.RightBottomNum, 5,6)
            GUI.ItemCtrlSetElementValue(MaterialsIcon,eItemIconElement.Border,QualityRes[1])--背景设置

        else
            ItemIcon.BindItemIdWithNum(MaterialsIcon,ConsumDB.Id, 1)
            GUI.ItemCtrlSetElementRect(MaterialsIcon, eItemIconElement.RightBottomNum, 5,6)
            GUI.ItemCtrlSetElementValue(MaterialsIcon,eItemIconElement.Border,QualityRes[1])--背景设置
        end
    end
end

function EquipTransferUI.OnRefreshBag(ReturnId)
    if ReturnId == 2 then
        --一级分栏
        local PanelBg = _gt.GetUI("EquipTransferUIPanelBg")
        --二级分栏
        local MaterialsIcon = GUI.GetChild(PanelBg,"MaterialsIcon")
        local ConsumDB = DB.GetOnceItemByKey2(tostring(EquipTransferConsume["Base"][1]))
        if AfterEquipKeyName ~= nil then
            local AfterEquipDB = DB.GetOnceItemByKey2(tostring(AfterEquipKeyName))

            if TransferRole[tonumber(AfterEquipDB.Role)].RoleConsumeNum == 2 and TransferRole[tonumber(AfterEquipDB.Role2)].RoleConsumeNum == 2 then
                ItemIcon.BindItemIdWithNum(MaterialsIcon,ConsumDB.Id, 2)
                GUI.ItemCtrlSetElementRect(MaterialsIcon, eItemIconElement.RightBottomNum, 5,6)
                GUI.ItemCtrlSetElementValue(MaterialsIcon,eItemIconElement.Border,QualityRes[1])--背景设置
            else
                ItemIcon.BindItemIdWithNum(MaterialsIcon,ConsumDB.Id, 1)
                GUI.ItemCtrlSetElementRect(MaterialsIcon, eItemIconElement.RightBottomNum, 5,6)
                GUI.ItemCtrlSetElementValue(MaterialsIcon,eItemIconElement.Border,QualityRes[1])--背景设置
            end
        else
            GUI.SetVisible(MaterialsIcon,false)
        end
    else
        --一级分栏
        local PanelBg = _gt.GetUI("EquipTransferUIPanelBg")
        --二级分栏
        local MaterialsIcon = GUI.GetChild(PanelBg,"MaterialsIcon")
        local ConsumDB = DB.GetOnceItemByKey2(tostring(EquipTransferConsume["Base"][1]))
        if AfterEquipKeyName ~= nil then
            --熔炉刷新
            local AfterEquipDB = DB.GetOnceItemByKey2(tostring(AfterEquipKeyName))
            if TransferRole[tonumber(AfterEquipDB.Role)].RoleConsumeNum == 2 and TransferRole[tonumber(AfterEquipDB.Role2)].RoleConsumeNum == 2 then
                ItemIcon.BindItemIdWithNum(MaterialsIcon,ConsumDB.Id, 2)
                GUI.ItemCtrlSetElementRect(MaterialsIcon, eItemIconElement.RightBottomNum, 5,6)
                GUI.ItemCtrlSetElementValue(MaterialsIcon,eItemIconElement.Border,QualityRes[1])--背景设置
            else
                ItemIcon.BindItemIdWithNum(MaterialsIcon,ConsumDB.Id, 1)
                GUI.ItemCtrlSetElementRect(MaterialsIcon, eItemIconElement.RightBottomNum, 5,6)
                GUI.ItemCtrlSetElementValue(MaterialsIcon,eItemIconElement.Border,QualityRes[1])--背景设置
            end
        else
            GUI.SetVisible(MaterialsIcon,false)
        end

        --遍历背包表单数据
        EquipTransferUI.GetBagEquip()
        --重新设置装备列表内容
        EquipTransferUI.UpdatePresentList()
    end

end

function EquipTransferUI.OnMaterialsIconClick()
    local parent = GUI.GetWnd("EquipTransferUI")
    local ConsumeItem = DB.GetOnceItemByKey2(EquipTransferConsume["Base"][1])

    local MaterialsIconTips = Tips.CreateByItemId(ConsumeItem.Id,parent,"MaterialsIconTips",0,0,50)
    _gt.BindName(MaterialsIconTips,"MaterialsIconTips")
    GUI.SetData(MaterialsIconTips, "ItemId", ConsumeItem.Id)
    UILayout.SetSameAnchorAndPivot(MaterialsIconTips, UILayout.Center)

    local wayBtn = GUI.ButtonCreate(MaterialsIconTips, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false)
    UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"EquipTransferUI","OnClickTipsBtn")
    GUI.AddWhiteName(MaterialsIconTips, GUI.GetGuid(wayBtn))
end

function EquipTransferUI.OnClickTipsBtn()
    local tip = _gt.GetUI("MaterialsIconTips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end

function EquipTransferUI.OnTranferBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm,"FormEquipChange","Start",tostring(SelectCheckBoxEquipGuid),tostring(AfterEquipKeyName))
end

function EquipTransferUI.TransferSuccess()
    AfterEquipKeyName = nil
end

function EquipTransferUI.Register()
    CL.RegisterMessage(GM.RefreshBag,"EquipTransferUI","OnRefreshBag")
end

function EquipTransferUI.UnRegister()
    CL.UnRegisterMessage(GM.RefreshBag,"EquipTransferUI","OnRefreshBag")
end

function EquipTransferUI.OnExit()
    GUI.CloseWnd("EquipTransferUI")
    EquipTransferUI.UnRegister()
end