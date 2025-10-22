local Tips = {}
_G.Tips = Tips
require("ItemTipsInfo")

local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot

------------------------------------------Start Test Start----------------------------------
local test = function () end --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

function Tips.CreateByItemData(itemData, parent, name, x, y, extHeight, guardGuid, customData, suitInfos)
    if itemData == nil then
        return nil
    end

    if guardGuid == nil then
        guardGuid = 0;
    end

    local itemDB = DB.GetOnceItemByKey1(itemData.id)
    if itemDB.Id == 0 then
        return nil
    end

    if extHeight == nil then
        extHeight = 0
    end

    local itemTips = GUI.ItemTipsCreate(parent, name, x, y, extHeight)
    GUI.SetIsRemoveWhenClick(itemTips, true)
    local itemShowLevel = GUI.GetChild(itemTips, "itemShowLevel")
    local itemIcon = GUI.TipsGetItemIcon(itemTips)
    ItemIcon.BindItemData(itemIcon, itemData, true)

    Tips.SetBaseInfo(itemTips, itemDB, itemData, guardGuid, customData)

    if itemDB.Type == 1 then
        -- if petGuid == nil then
        Tips.AddEquipInfoByItemData(itemTips, itemDB, itemData, guardGuid, suitInfos, customData)
        -- else
        -- Tips.AddEquipInfoByItemData(itemTips, itemDB, itemData,guardGuid,petGuid,customData)
        -- end
    end

    Tips.AddInfoAndTips(itemTips, itemDB, itemData)

    Tips.DeleteItemShowLevel(itemTips) -- 删除等级属性

    return itemTips
end

function Tips.CreateByItemId(itemId, parent, name, x, y, extHeight)
    local itemDB = DB.GetOnceItemByKey1(itemId)
    if itemDB.Id == 0 then
        return nil
    end

    if extHeight == nil then
        extHeight = 0
    end
    local itemTips = GUI.ItemTipsCreate(parent, name, x, y, extHeight)

    --不点击 就不会销毁了
    GUI.SetIsRemoveWhenClick(itemTips, true) --点击其他UI控件时销毁此UI控件 类似TIPS , 当点击此UI控件之外的UI控件时此UI自动销毁(白名单控件除外) 
    local itemIcon = GUI.TipsGetItemIcon(itemTips) --TipsGetItemIcon()获取TIPS控件左上角道具图标 
    ItemIcon.BindItemId(itemIcon, itemId)

    Tips.SetBaseInfo(itemTips, itemDB) --装备名字什么的

    if itemDB.Type == 1 then
        Tips.AddEquipInfoByItemDB(itemTips, itemDB)
    end

    Tips.AddInfoAndTips(itemTips, itemDB)  --按钮上面的简介

    Tips.DeleteItemShowLevel(itemTips) -- 删除等级属性

    return itemTips
end

function Tips.CreateByItemKeyName(keyName, parent, name, x, y, extHeight)
    local ItemExLv = 0
    local GuangConfig = ""
    if string.find(keyName, "#") then
        local value = string.split(keyName, "#")
        keyName = value[1]
        ItemExLv = tonumber(value[2])
        if value[3] then
            GuangConfig = value[3]
        end
    end
    local itemDB = DB.GetOnceItemByKey2(keyName)
    if itemDB.Id == 0 then
        return nil
    end

    if extHeight == nil then
        extHeight = 0
    end

    local itemTips = GUI.ItemTipsCreate(parent, name, x, y, extHeight)
    GUI.SetIsRemoveWhenClick(itemTips, true)
    local itemIcon = GUI.TipsGetItemIcon(itemTips)
    ItemIcon.BindItemKeyName(itemIcon, keyName)

    Tips.SetBaseInfo(itemTips, itemDB)

    if itemDB.Type == 1 then
        Tips.AddEquipInfoByItemDB(itemTips, itemDB, ItemExLv, GuangConfig)
    end


    -- 2021-8-4 为 面板展示-金角大王 物品添加
    if itemDB.Type == 3 and itemDB.Subtype == 14 and itemDB.ShowType == '侍从' then
        -- 侍从头像  调整大小
        local icon = GUI.ItemCtrlGetElement(itemIcon, eItemIconElement.Icon)
        GUI.SetWidth(icon, 71)
        GUI.SetHeight(icon, 70)
    end

    Tips.AddInfoAndTips(itemTips, itemDB)

    Tips.DeleteItemShowLevel(itemTips) -- 删除等级属性

    return itemTips
end

function Tips.CreateByItemKeyNameWithBind(keyName, bind, parent, name, x, y, extHeight)
    local ItemExLv = 0
    local GuangConfig = ""
    if string.find(keyName, "#") then
        local value = string.split(keyName, "#")
        keyName = value[1]
        ItemExLv = tonumber(value[2])
        if value[3] then
            GuangConfig = value[3]
        end
    end
    local itemDB = DB.GetOnceItemByKey2(keyName)
    if itemDB.Id == 0 then
        return nil
    end

    if extHeight == nil then
        extHeight = 0
    end

    local itemTips = GUI.ItemTipsCreate(parent, name, x, y, extHeight)
    GUI.SetIsRemoveWhenClick(itemTips, true)
    local itemIcon = GUI.TipsGetItemIcon(itemTips)
    ItemIcon.BindItemKeyNameWithBind(itemIcon, keyName, bind)

    Tips.SetBaseInfo(itemTips, itemDB)

    if itemDB.Type == 1 then
        Tips.AddEquipInfoByItemDB(itemTips, itemDB, ItemExLv, GuangConfig)
    end

    Tips.AddInfoAndTips(itemTips, itemDB)

    Tips.DeleteItemShowLevel(itemTips) -- 删除等级属性

    return itemTips
end

---@param itemData ItemDataEx
function Tips.SetBaseInfo(itemTips, itemDB, itemData, guardGuid, customData)
    -----------------------------------------2021.6.3  新增东西Start------------------------------------
    --customData是服务端往item绑定的自定义数据
    --例如  item的等级需求
    --大致格式如下
    --customData={“itemRandomLevel”=40,........}

    local itemLevel = itemDB.Level
    --test(itemLevel)
    if customData ~= nil then
        for i, v in pairs(customData) do
            -- 是因为影响到了Tips里的等级需求
            if i == "itemRandomLevel" and tonumber(v) ~= 0 then
                itemLevel = tonumber(v)
                test(itemLevel)
            end
        end
    end
    -----------------------------------------2021.6.3  新增东西End------------------------------------
    GUI.ItemTipsSetItemName(itemTips, itemDB.Name, UIDefine.GradeColor[itemDB.Grade])
    if itemData then
        local ulongVal = itemData:GetIntCustomAttr(LogicDefine.EnhanceLv)
        local enhanceLv, h = int64.longtonum2(ulongVal)
        if enhanceLv > 0 then
            local name = GUI.ItemTipsGetItemName(itemTips)
            local w = GUI.StaticGetLabelPreferWidth(name)
            GUI.SetWidth(name, w)

            local nameex = GUI.CreateStatic(name, "ex", "+" .. enhanceLv, w + 10, 0, 100, 30)
            GUI.StaticSetFontSize(nameex, UIDefine.FontSizeM)
            UILayout.SetSameAnchorAndPivot(nameex, UILayout.TopLeft)
            GUI.SetColor(nameex, UIDefine.EnhanceBlueColor)
        end
    end
    GUI.ItemTipsSetItemType(itemTips, "类型：" .. itemDB.ShowType, UIDefine.YellowColor)
    GUI.ItemTipsSetItemShowLevel(itemTips, "等级：" .. itemDB.Itemlevel .. "级", UIDefine.YellowColor)
    local color = UIDefine.YellowColor

    local levelStr = "等级需求："
    if itemDB.TurnBorn > 0 then
        levelStr = levelStr .. itemDB.TurnBorn .. "转"
    end
    levelStr = levelStr .. itemLevel .. "级"
    if CL.GetIntAttr(RoleAttr.RoleAttrReincarnation) == itemDB.TurnBorn then
        if CL.GetIntAttr(RoleAttr.RoleAttrLevel) < itemLevel then
            color = UIDefine.RedColor
        end
    elseif CL.GetIntAttr(RoleAttr.RoleAttrReincarnation) < itemDB.TurnBorn then
        color = UIDefine.RedColor
    end
    --宠物特殊处理
    if itemDB.Subtype == 7 then
        color = UIDefine.YellowColor
    end

    GUI.ItemTipsSetItemLevel(itemTips, levelStr, color)

    local guardData
    local guardDB
    if guardGuid and guardGuid ~= 0 then
        -- 侍从数据
        guardData = LD.GetGuardData(guardGuid)
        guardDB = DB.GetOnceGuardByKey1(
                tonumber(tostring(LogicDefine.GetAttrFromFreeList(guardData.attrs, RoleAttr.RoleAttrRole)))
        )
    end
    local limitStr = ""
    local isRed = false
    if itemDB.Role ~= 0 then
        limitStr = "所需角色:"
        local roleDB = DB.GetRole(itemDB.Role)
        local role2 = nil
        if itemDB.Role2 ~= 0 then
            role2 = DB.GetRole(itemDB.Role2)
        end
        if roleDB.Id ~= 0 then
            limitStr = limitStr .. " " .. roleDB.RoleName
        end
        if role2 then
            limitStr = limitStr .. " " .. role2.RoleName
        end
        if guardData then
            if guardDB.Role ~= itemDB.Role and guardDB.Role ~= itemDB.Role2 then
                isRed = true
            end
        else
            local roleid = CL.GetRoleTemplateID()
            if roleid ~= itemDB.Role and roleid ~= itemDB.Role2 then
                isRed = true
            end
        end
    elseif itemDB.Job ~= 0 then
        local schoolDB = DB.GetSchool(itemDB.Job)
        if schoolDB.Id ~= 0 then
            limitStr = "所需门派：" .. schoolDB.Name
        end
        if guardData then
            if tonumber(tostring(LogicDefine.GetAttrFromFreeList(guardData.attrs, RoleAttr.RoleAttrJob1))) ~= itemDB.Job then
                isRed = true
            end
        else
            if CL.GetIntAttr(RoleAttr.RoleAttrJob1) ~= itemDB.Job then
                isRed = true
            end
        end
    elseif itemDB.Sex ~= 0 then
        limitStr = "所需性别：" .. UIDefine.GetSexName(itemDB.Sex)
        if guardData then
            if
            tonumber(tostring(LogicDefine.GetAttrFromFreeList(guardData.attrs, RoleAttr.RoleAttrGender))) ~=
                    itemDB.Sex
            then
                isRed = true
            end
        else
            if CL.GetIntAttr(RoleAttr.RoleAttrGender) ~= itemDB.Sex then
                isRed = true
            end
        end
    end

    if isRed then
        GUI.ItemTipsSetItemLimit(itemTips, limitStr, UIDefine.RedColor)
    else
        GUI.ItemTipsSetItemLimit(itemTips, limitStr, UIDefine.YellowColor)
    end

    if itemData ~= nil and itemData.life ~= 0 then
        local unixTime = itemData.life - tonumber(tostring(CL.GetServerTickCount()))
        local day, hour, minute, second = GlobalUtils.Get_DHMS1_BySeconds(unixTime)
        local remain = ""
        if day ~= 0 then
            remain = day .. "天"
        else
            if hour ~= 0 then
                remain = hour .. "小时"
            else
                if minute ~= 0 then
                    remain = minute .. "分钟"
                end
            end
        end
        GUI.TipsAddLabel(itemTips, 115, "剩余时间：" .. remain, UIDefine.GreenColor, false)
        GUI.TipsAddCutLine(itemTips)
    end
end

-- 删除等级属性,并调整提示位置
function Tips.DeleteItemShowLevel(itemTips)
    local itemShowLevel = GUI.GetChild(itemTips, "itemShowLevel")
    GUI.SetVisible(itemShowLevel, false)
    --GUI.Destroy(itemShowLevel)
    local ItemLevel = GUI.GetChild(itemTips, "ItemLevel")
    local ItemLevelPositionY = GUI.GetPositionY(ItemLevel)
    GUI.SetPositionY(ItemLevel, ItemLevelPositionY + 200 - 26)
    local itemLimit = GUI.GetChild(itemTips, "itemLimit")
    local itemLimitPositionY = GUI.GetPositionY(itemLimit)
    GUI.SetPositionY(itemLimit, itemLimitPositionY + 200 + 26)
    local CutLine = GUI.GetChild(itemTips, "CutLine")
    local CutLinePositionY = GUI.GetPositionY(CutLine)
    GUI.SetPositionY(CutLine, CutLinePositionY + 200 + 26 * 3 + 13)
    local InfoScr = GUI.GetChild(itemTips, "InfoScr")
    local InfoScrPositionY = GUI.GetPositionY(InfoScr)
    GUI.SetPositionY(InfoScr, InfoScrPositionY + 200 + 26 * 4)
    --test(GUI.GetPositionY(InfoScr))


    --如果没有角色需求，调整位置
    if GUI.StaticGetText(itemLimit) == "" then
        GUI.SetPositionY(CutLine, CutLinePositionY + 200 + 26 * 2 + 23)
        GUI.SetPositionY(InfoScr, InfoScrPositionY + 200 + 26 * 3 + 10)
    end

    GUI.SetHeight(itemTips, GUI.GetHeight(itemTips) - 36)
end

function Tips.AddEquipInfoByItemDB(itemTips, itemDB, ItemExLv, GuangConfig)
    local itemAttDB = DB.GetOnceItem_AttByKey1(itemDB.Id)
    if itemAttDB.Id == 0 then
        return
    end

    GUI.TipsAddLabel(itemTips, 20, "基础属性：", UIDefine.Yellow3Color, false)

    Tips.AddEquipRequirements(itemTips, itemAttDB)

    for i = 1, 5 do
        local attrDB = DB.GetOnceAttrByKey1(itemAttDB["Att" .. i])
        if attrDB.Id ~= 0 then
            local minV = tostring(itemAttDB["Att" .. i .. "Min"])
            local maxV = tostring(itemAttDB["Att" .. i .. "Max"])
            if attrDB.IsPct == 1 then
                minV = tostring(tonumber(minV) / 100) .. "%"
                maxV = tostring(tonumber(maxV) / 100) .. "%"
            end
            if minV ~= maxV then
                GUI.TipsAddLabel(
                        itemTips,
                        45,
                        attrDB.ChinaName .. "   " .. minV .. " - " .. maxV,
                        UIDefine.WhiteColor,
                        false
                )
            else
                GUI.TipsAddLabel(
                        itemTips,
                        45,
                        attrDB.ChinaName .. "   " .. minV,
                        UIDefine.WhiteColor,
                        false
                )
            end
        end
    end

    GUI.TipsAddCutLine(itemTips)

    if ItemExLv then
        if ItemExLv > 0 then
            local name = GUI.ItemTipsGetItemName(itemTips)
            local w = GUI.StaticGetLabelPreferWidth(name)
            GUI.SetWidth(name, w)

            local nameex = GUI.CreateStatic(name, "ex", "+" .. ItemExLv, w + 10, 0, 100, 30)
            GUI.StaticSetFontSize(nameex, UIDefine.FontSizeM)
            UILayout.SetSameAnchorAndPivot(nameex, UILayout.TopLeft)
            GUI.SetColor(nameex, UIDefine.EnhanceBlueColor)

            --强化
            local config = GlobalProcessing.EquipEnhanceUI.CheckRedPoint_TB.ConsumeConfig[ItemExLv]
            local strtmp = "local formula,GradeCoefficient,AttrCoefficient,PositionCoefficient,GuangCoefficient=...;return "
            local InteRangeFun = assert(loadstring(strtmp .. config.InteRange))

            local formulaFun = {}
            strtmp = "local IntensifLevel=...;return "
            if UIDefine.EquipEnhanceAttrData.formula then
                for key, value in pairs(UIDefine.EquipEnhanceAttrData.formula) do
                    formulaFun[key] = assert(loadstring(strtmp .. value))
                end
            end

            -- config.item = LogicDefine.SeverItems2ClientItems(config.ItemList)
            -- config.safeIndex = #(config.item) + 1
            -- config.item = LogicDefine.SeverItems2ClientItems(config.safeItem, config.item)
            local formula = 0
            local GradeCoefficient = UIDefine.EquipEnhanceAttrData.GradeCoefficient and UIDefine.EquipEnhanceAttrData.GradeCoefficient[itemDB.Grade]
            local PositionCoefficient = UIDefine.EquipEnhanceAttrData.PositionCoefficient and UIDefine.EquipEnhanceAttrData.PositionCoefficient[itemDB.Subtype]
            local GuangCoefficient = UIDefine.EquipEnhanceAttrData.GuangCoefficient and UIDefine.EquipEnhanceAttrData.GuangCoefficient[itemDB.Subtype]
            if formulaFun[itemDB.Itemlevel] ~= nil then
                formula = formulaFun[itemDB.Itemlevel](ItemExLv)
            else
                test("缺少 formula ", itemDB.Itemlevel)
            end
            if GradeCoefficient == nil then
                test("缺少 GradeCoefficient ", itemDB.Grade)
                GradeCoefficient = 0
            end
            if PositionCoefficient then
                if itemDB.Subtype == LogicDefine.ItemSubType.weapon then
                    -- 服务器表单定义，类型是武器的话不用subtype2,全部走0
                    PositionCoefficient = PositionCoefficient[0]
                else
                    PositionCoefficient = PositionCoefficient[itemDB.Subtype2]
                end
            end
            if PositionCoefficient == nil then
                test("缺少 PositionCoefficient subtype = " .. itemDB.Subtype .. " subtype2 " .. itemDB.Subtype2)
                PositionCoefficient = 0
            end
            if GuangCoefficient then
                if GuangConfig == "" then
                    GuangCoefficient = 1
                elseif GuangConfig == "光" then
                    if itemDB.Subtype == LogicDefine.ItemSubType.weapon then
                        GuangCoefficient = GuangCoefficient[0]
                    else
                        GuangCoefficient = GuangCoefficient[itemDB.Subtype2]
                    end
                else
                    GuangCoefficient = 1
                end
            end
            if GuangCoefficient == nil then
                test("缺少 GuangCoefficient subtype = " .. itemDB.Subtype .. " subtype2 " .. itemDB.Subtype2)
                GuangCoefficient = 0
            end

            local exv = "强化等级：   "
            local exMax = UIDefine.MaxIntensifyLevel
            --宠物装备强化等级上限
            if tostring(itemDB.Type) == "1" and tostring(itemDB.Subtype) == "7" then
                exMax = UIDefine.PetMaxIntensifyLevel or 20
            end

            exv = exv .. ItemExLv
            if exMax then
                exv = exv .. "/" .. exMax
            end
            GUI.TipsAddLabel(itemTips, 20, exv, UIDefine.PurpleColor, false)
            local inspect = require("inspect")
            for i = 1, 5 do
                local attrDB = DB.GetOnceAttrByKey1(itemAttDB["Att" .. i])
                if attrDB.Id ~= 0 then
                    local AttrCoefficient = UIDefine.EquipEnhanceAttrData.AttrCoefficient and UIDefine.EquipEnhanceAttrData.AttrCoefficient[attrDB.Id]
                    if AttrCoefficient == nil then
                        test("缺少 AttrCoefficient ", attrDB.Id)
                        AttrCoefficient = 0
                    end
                    local value = InteRangeFun(formula, GradeCoefficient, AttrCoefficient, PositionCoefficient, GuangCoefficient)
                    GUI.TipsAddLabel(itemTips, 45, attrDB.ChinaName .. "   " .. math.floor(value), UIDefine.PurpleColor, false)
                end
            end
            GUI.TipsAddCutLine(itemTips)
            --强化end
        end
    end
end

function Tips.AddEquipRequirements(itemTips, itemAttDB, guardGuid)
    if itemAttDB.Id == 0 then
        return
    end

    local attrs = { ["根骨需求"] = true, ["灵性需求"] = true, ["力量需求"] = true, ["敏捷需求"] = true }
    for i = 1, #EquipLogic.attrT do
        local attrTool = EquipLogic.attrT[i];
        if attrs[attrTool.name] == true then
            if attrTool.IsShow(nil, itemAttDB) then
                local color = UIDefine.WhiteColor
                if not attrTool.CanUse(nil, itemAttDB, guardGuid) then
                    color = UIDefine.RedColor
                end
                GUI.TipsAddLabel(itemTips, 45, attrTool.name .. "   " .. attrTool.GetV(nil, itemAttDB), color, false)
            end
        end
    end


end

function Tips.AddEquipInfoByItemData(itemTips, itemDB, itemData, guardGuid, suitInfos, customData)
    if not itemData then
        return
    end
    ---@type enhanceDynAttrData[]
    local showSpCnt = 1

    local basicAttributeTxt = nil

    if itemData:GetIntCustomAttr(LogicDefine.ITEM_SPAttrNum) > 0 and itemData:GetIntCustomAttr(LogicDefine.ITEM_SPAttrSh .. showSpCnt) > 0 then
        local cname = itemData:GetStrCustomAttr(LogicDefine.ITEM_SPAttrNa .. showSpCnt) -- LD.GetItemStrCustomAttrByGuid(LogicDefine.ITEM_SPAttrNa .. showSpCnt, guid, bagtype)
        local val = itemData:GetIntCustomAttr(LogicDefine.ITEM_SPAttrVa .. showSpCnt)
        basicAttributeTxt = GUI.TipsAddLabel(
                itemTips,
                20,
                "基础属性：   <color=#21DDDAB2>" .. cname .. " " .. val .. "</color>",
                UIDefine.Yellow3Color,
                true
        )
    else
        basicAttributeTxt = GUI.TipsAddLabel(itemTips, 20, "基础属性", UIDefine.Yellow3Color, false)
    end


    --强化等级
    local enhanceTxt = GUI.CreateStatic(basicAttributeTxt, "enhanceTxt", "", 110, 0, 240, 30)
    SetAnchorAndPivot(enhanceTxt, UIAnchor.Left, UIAroundPivot.Left)
    GUI.SetColor(enhanceTxt, UIDefine.PurpleColor)
    GUI.StaticSetAlignment(enhanceTxt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(enhanceTxt, 22)

    local txt = "（强化:0/0）"
    local exMax = UIDefine.MaxIntensifyLevel
    local ulongVal = itemData:GetIntCustomAttr(LogicDefine.EnhanceLv)
    local enhanceLv, h = int64.longtonum2(ulongVal)
    if enhanceLv > 0 then

        txt = "（强化:"..enhanceLv .. "/" .. exMax.."）"
        GUI.SetVisible(enhanceTxt,true)
        GUI.StaticSetText(enhanceTxt,txt)

    else

        GUI.SetVisible(enhanceTxt,false)

    end

    local itemAttDB = DB.GetOnceItem_AttByKey1(itemDB.Id)
    Tips.AddEquipRequirements(itemTips, itemAttDB, guardGuid)
    local t = {}
    LogicDefine.GetItemDynAttrDataByMark(itemData, LogicDefine.ItemAttrMark.Base, LogicDefine.ItemAttrMark.Enhance, t)

    local temptable = { [15] = 1, [16] = 2, [17] = 3, [18] = 4, [19] = 5 }
    --属性排序
    table.sort(t, function(a, b)
        if temptable[a.attr] and temptable[b.attr] == nil then
            return false
        elseif temptable[a.attr] == nil and temptable[b.attr] then
            return true
        elseif temptable[a.attr] and temptable[b.attr] then
            return a.attr < b.attr
        else
            return a.attr < b.attr
        end
    end)
    if #t > 0 then
        for i = 1, #t do
            local value = tostring(t[i].value)
            if t[i].Id ~= 0 then
                if t[i].IsPct then
                    value = tostring(tonumber(value) / 100) .. "%"
                    CDebug.LogError(value)
                end
                --t[i].name：基础属性名；value：数值
                local label = GUI.TipsAddLabel(itemTips, 45, "", UIDefine.WhiteColor, false)
                local UpImg = GUI.ImageCreate(label, "UpImg" .. i, "1800407130", -30, 1, true)
                GUI.SetVisible(UpImg, false)

                local statsValue = GUI.CreateStatic(label, "attributeValue", t[i].name .. "  " .. value, 0, 0, 20, 30)
                SetAnchorAndPivot(statsValue, UIAnchor.Left, UIAroundPivot.Left)
                GUI.SetColor(statsValue, UIDefine.WhiteColor)
                GUI.StaticSetAlignment(statsValue, TextAnchor.MiddleLeft)
                GUI.StaticSetFontSize(statsValue, 22)
                local desPreferWidth = GUI.StaticGetLabelPreferWidth(statsValue)
                GUI.SetWidth(statsValue,desPreferWidth)

                local enhanceValue = tostring(t[i].exV)
                if enhanceValue ~= nil then
                    if tonumber(enhanceValue) ~= 0 then

                        local attributeValue = GUI.CreateStatic(statsValue, "attributeValue", "（+"..enhanceValue.."）", 0, 0, 240, 30)
                        SetAnchorAndPivot(attributeValue, UIAnchor.Right, UIAroundPivot.Left)
                        GUI.SetColor(attributeValue, UIDefine.PurpleColor)
                        GUI.StaticSetAlignment(attributeValue, TextAnchor.MiddleLeft)
                        GUI.StaticSetFontSize(attributeValue, 22)

                    end

                end

            end
        end
    end

    --特效
    local Equip_SpecialEffect = itemData:GetIntCustomAttr("Equip_SpecialEffect")
    local SpecialEffect = DB.GetOnceSkillByKey1(Equip_SpecialEffect)
    if SpecialEffect.Name ~= nil then
        local lable = GUI.TipsAddLabel(itemTips, 45, "特效：【" .. tostring(SpecialEffect.Name) .. "】", UIDefine.GradeColor[SpecialEffect.SkillQuality], false)
        GUI.SetData(lable, "SpecialEffect", Equip_SpecialEffect)
        GUI.SetIsRaycastTarget(lable, true)
        lable:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(lable, UCE.PointerClick, "Tips", "OnClickSpecialEffectTipsBtn")
        GUI.AddWhiteName(itemTips, GUI.GetGuid(lable))
    end

    ----特技
    local Equip_Stunt = itemData:GetIntCustomAttr("Equip_Stunt")
    local Stunt = DB.GetOnceSkillByKey1(Equip_Stunt)
    if Stunt.Name ~= nil then
        local lable = GUI.TipsAddLabel(itemTips, 45, "特技：【" .. tostring(Stunt.Name) .. "】", UIDefine.GradeColor[Stunt.SkillQuality], false)
        GUI.SetData(lable, "StuntID", Equip_Stunt)
        GUI.SetIsRaycastTarget(lable, true)
        lable:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(lable, UCE.PointerClick, "Tips", "OnClickStuntTipsBtn")
        GUI.AddWhiteName(itemTips, GUI.GetGuid(lable))
    end

    GUI.TipsAddCutLine(itemTips)
    --
    ----强化
    --local exv = "强化等级：   "
    --local exMax = UIDefine.MaxIntensifyLevel
    ----宠物装备强化等级上限
    --if tostring(itemDB.Type) == "1" and tostring(itemDB.Subtype) == "7" then
    --    exMax = UIDefine.PetMaxIntensifyLevel or 20
    --end
    --local ulongVal = itemData:GetIntCustomAttr(LogicDefine.EnhanceLv)
    --local enhanceLv, h = int64.longtonum2(ulongVal)
    --if enhanceLv > 0 then
    --    exv = exv .. enhanceLv
    --    if exMax then
    --        exv = exv .. "/" .. exMax
    --    end
    --    GUI.TipsAddLabel(itemTips, 20, exv, UIDefine.PurpleColor, false)
    --    if #t > 0 then
    --        for i = 1, #t do
    --            local value = tostring(t[i].exV)
    --            if t[i].Id ~= 0 and tonumber(value) ~= 0 then
    --                if t[i].IsPct then
    --                    value = tostring(tonumber(value) / 100) .. "%"
    --                end
    --                GUI.TipsAddLabel(itemTips, 45, t[i].name .. "   " .. value, UIDefine.PurpleColor, false)
    --            end
    --        end
    --    end
    --    GUI.TipsAddCutLine(itemTips)
    --end
    --强化end
    local dynsAttrType = { LogicDefine.ItemAttrMark.Artifice, LogicDefine.ItemAttrMark.Refiner }
    local str = { "炼化属性: ", "炼器属性: " }
    for j = 1, #dynsAttrType do
        -- body
        -- local dyns11 = itemData:GetStrCustomAttr("PetEquipArtifice_NowAttrTb")
        local dyns11 = itemData:GetDynAttrDataByMark(dynsAttrType[j])
        if dyns11.Count > 0 then
            GUI.TipsAddLabel(itemTips, 20, str[j], UIDefine.Yellow3Color, false)
            if itemDB.Subtype ~= 7 then
                for i = 0, dyns11.Count - 1 do
                    local attrId = dyns11[i].attr
                    local value = tostring(dyns11[i].value)
                    local attrDB = DB.GetOnceAttrByKey1(attrId)
                    if attrDB.Id ~= 0 then
                        if attrDB.IsPct == 1 then
                            value = tostring(tonumber(value) / 100) .. "%"
                        end
                        GUI.TipsAddLabel(itemTips, 45, attrDB.ChinaName .. "   " .. value, UIDefine.GreenColor, false)
                    end
                end
            else
                local TempEquipAttr = {}
                local itemGUID = itemData:GetAttr(ItemAttr_Native.Guid)
                local NowAttrStr = itemData:GetStrCustomAttr("PetEquipArtifice_NowAttrTb")
                -- if petGuid == nil then
                -- NowAttrStr = LD.GetItemStrCustomAttrByGuid ("PetEquipArtifice_NowAttrTb",itemGUID,item_container_type.item_container_bag)
                -- else
                -- NowAttrStr = LD.GetItemStrCustomAttrByGuid ("PetEquipArtifice_NowAttrTb",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid)))
                -- end
                -- itemData:GetStrCustomAttr("PetEquipArtifice_NowAttrTb")
                if NowAttrStr ~= "" then
                    TempEquipAttr = loadstring("return" .. NowAttrStr)()
                end
                for i = 1, #TempEquipAttr do
                    local AttrDB = DB.GetOnceAttrByKey1(TempEquipAttr[i][1])
                    local Grade = TempEquipAttr[i][3]
                    local value = tostring(TempEquipAttr[i][2])
                    if AttrDB.IsPct == 1 then
                        value = tostring(tonumber(value) / 100) .. "%"
                    end
                    GUI.TipsAddLabel(itemTips, 45, AttrDB.ChinaName .. "   " .. value, UIDefine.PetEquipAttrGrade["OnBlack"][Grade], false)
                end
                -- local inspect = require("inspect")
                -- CDebug.LogError(inspect(TempEquipAttr))
            end

            GUI.TipsAddCutLine(itemTips)
        end
    end

    --器灵
    if UIDefine.FunctionSwitch["EquipSoulReforge"] and UIDefine.FunctionSwitch["EquipSoulReforge"] == "on" then

        local equipSoulReforgeNowAttrTb = itemData:GetStrCustomAttr("EquipSoulReforge_NowAttrTb")

        local temp = {}
        if #equipSoulReforgeNowAttrTb > 0 then

            temp = loadstring("return " .. equipSoulReforgeNowAttrTb)()

        end

        if #temp > 0 then

            GUI.TipsAddLabel(itemTips, 20, "洗灵属性：",UIDefine.Yellow3Color, false)

        end

        for i = 1, #temp do

            local data = temp[i]

            if data then

                local data_color = GlobalProcessing.EquipSoulReforgeColor
                local txt = ""
                if #data[6] > 0 then

                    txt = txt..data[6].." "

                end

                local attrDB = DB.GetOnceAttrByKey2(data[1])

                txt = txt..attrDB.ChinaName.." "


                if attrDB.IsPct == 1 then

                    if data[2] > 0 then

                        txt = txt.."+"..(data[2]/100).."%"

                    else

                        txt = txt.."-"..(data[2]/100).."%"

                    end

                else

                    if data[2] > 0 then

                        txt = txt.."+"..data[2]

                    else

                        txt = txt.."-"..data[2]

                    end

                end


                local color = UIDefine.WhiteColor

                if data_color[data[4]] then

                    if data_color[data[4]][data[5]] then

                        if data_color[data[4]][data[5]][2] then

                            local r,g,b,a = GlobalUtils.getRGBDecimal(data_color[data[4]][data[5]][2])

                            color = Color.New(r / 255, g / 255, b / 255, a)

                        end

                    end

                end

                GUI.TipsAddLabel(itemTips, 45, txt,color, false)
            end

        end

        if #temp > 0 then

            GUI.TipsAddCutLine(itemTips)

        end

    end

    --宝石镶嵌
    local gemCount, siteCount = LogicDefine.GetEquipGemCount(itemData)
    if gemCount > 0 then
        GUI.TipsAddLabel(itemTips, 20, "宝石镶嵌：    " .. gemCount .. "/" .. siteCount, UIDefine.Yellow3Color, false)

        for i = 1, siteCount do
            local gemId = itemData:GetIntCustomAttr(LogicDefine.ITEM_GemId_ .. i)
            if gemId ~= 0 then
                local gemDB = DB.GetOnceItemByKey1(gemId)

                local attrDatas = itemData:GetDynAttrDataByMark(LogicDefine.ITEM_GemAttrMark[i])
                local GemAttribute = ""
                for i = 0, attrDatas.Count - 1 do
                    local attrData = attrDatas[i]
                    local attrId = attrData.attr
                    local value = attrData.value
                    GemAttribute = GemAttribute .. UIDefine.GetAttrDesStr(attrId, value)
                    if attrDatas.Count > 1 then
                        if i == 0 then
                            GemAttribute = GemAttribute .. "  "
                        end
                    end
                end
                GUI.TipsAddLabel(itemTips, 20, gemDB.Name .. "："..GemAttribute, UIDefine.BlueColor, false)
                --GUI.TipsAddLabel(itemTips, 45, GemAttribute, UIDefine.BlueColor, false)
            end
        end
        GUI.TipsAddCutLine(itemTips)
    end

    if GlobalUtils.suitConfig then
        local suitName = itemData:GetStrCustomAttr(GlobalUtils.suitConfig.Sign_STR)
        if suitName ~= "" then

            local num = 0;
            if suitInfos then
                --如果有套装信息传入，则直接检索
                local totalCount = #suitInfos
                for i = 1, totalCount do
                    if suitInfos[i] == suitName then
                        num = num + 1
                    end
                end
            else
                --否则就是对比玩家自己的套装数据
                local capacity = LD.GetBagCapacity(item_container_type.item_container_equip)
                for i = 0, capacity - 1 do
                    local suitName2 = LD.GetItemStrCustomAttrByIndex(GlobalUtils.suitConfig.Sign_STR, i, item_container_type.item_container_equip)
                    if suitName2 == suitName then
                        num = num + 1;
                    end
                end
            end

            local config = GlobalUtils.suitConfig[suitName];
            if config then
                GUI.TipsAddLabel(itemTips, 20, "套装属性：" .. config.Suit_Name .. "(" .. num .. "/" .. config.Total .. ")", UIDefine.GreenColor, false)
                for i = 1, config.Total do
                    if config.Size[i] then
                        local state = "(未激活)"
                        if num >= i then
                            state = "(已激活)"
                        end
                        for j = 1, #config.Size[i].Attr do
                            local attrDB = DB.GetOnceAttrByKey2(config.Size[i].Attr[j][1])
                            if attrDB.Id ~= 0 then
                                GUI.TipsAddLabel(itemTips, 20, "[" .. i .. "]" .. UIDefine.GetAttrDesStr(attrDB.Id, config.Size[i].Attr[j][2]) .. state, UIDefine.GreenColor, false)
                            end
                        end
                    end
                end
                GUI.TipsAddCutLine(itemTips)
            end
        end
    end

    -- 武器使用等级改变
    local itemLevel = itemDB.Level
    if customData ~= nil then
        for i, v in pairs(customData) do
            -- 是因为影响到了Tips里的等级需求
            if i == "itemRandomLevel" and tonumber(v) ~= 0 then
                itemLevel = tonumber(v)
            end
        end
    end
    local __equip_use_Level_ = itemData:GetIntCustomAttr("__equip_use_Level_")
    -- 武器使用等级
    local levelStr = "等级需求："
    if itemDB.TurnBorn > 0 then
        levelStr = levelStr .. itemDB.TurnBorn .. "转"
    end
    local equipUseLevel = itemLevel
    if __equip_use_Level_ ~= nil and __equip_use_Level_ ~= 0 and equipUseLevel ~= __equip_use_Level_ then
        levelStr = levelStr .. itemLevel .. "级" .. "  " .. (__equip_use_Level_) .. "级"
        equipUseLevel = __equip_use_Level_
    else
        levelStr = levelStr .. itemLevel .. "级"
    end
    local color = UIDefine.YellowColor
    if CL.GetIntAttr(RoleAttr.RoleAttrReincarnation) == itemDB.TurnBorn then
        if CL.GetIntAttr(RoleAttr.RoleAttrLevel) < equipUseLevel then
            color = UIDefine.RedColor
        end
    elseif CL.GetIntAttr(RoleAttr.RoleAttrReincarnation) < itemDB.TurnBorn then
        color = UIDefine.RedColor
    end
    --宠物特殊处理
    if itemDB.Subtype == 7 then
        color = UIDefine.YellowColor
    end
    -- 删除线单独处理
    if __equip_use_Level_ ~= nil and __equip_use_Level_ ~= 0 and itemLevel ~= __equip_use_Level_ then
        local ItemLevel = GUI.GetChild(itemTips, "ItemLevel")
        local deleteLineStr = "____"
        if itemLevel / 10 < 1 then
            deleteLineStr = "___"
        elseif itemLevel / 10 >= 10 then
            deleteLineStr = "_____"
        end
        local deleteLine = GUI.CreateStatic(ItemLevel, "deleteLine", deleteLineStr, 100, -12, 100, 30)
        GUI.StaticSetFontSize(deleteLine, UIDefine.FontSizeM)
        GUI.SetColor(deleteLine, color)
    end
    GUI.ItemTipsSetItemLevel(itemTips, levelStr, color)
    -- 使用等级增加或减少
    if __equip_use_Level_ ~= nil and __equip_use_Level_ ~= 0 then
        local levelChange = __equip_use_Level_ - itemLevel
        if levelChange > 0 then
            GUI.TipsAddLabel(itemTips, 20, "使用等级增加" .. levelChange .. "级", UIDefine.RedColor, false)
            GUI.TipsAddCutLine(itemTips)
        elseif levelChange < -5 then
            GUI.TipsAddLabel(itemTips, 20, "使用等级减少" .. (levelChange * -1) .. "级", UIDefine.OrangeColor, false)
            GUI.TipsAddCutLine(itemTips)
        elseif levelChange < 0 then
            GUI.TipsAddLabel(itemTips, 20, "使用等级减少" .. (levelChange * -1) .. "级", UIDefine.PurpleColor, false)
            GUI.TipsAddCutLine(itemTips)
        end
    end

    --武器耐久度
    local id = itemData:GetAttr(ItemAttr_Native.Id)
    local ItemDB = DB.GetOnceItemByKey1(id)
    if ItemDB.Type == 1 then
        --宠物特殊处理
        if ItemDB.Subtype == 7 then
            local itemGUID = itemData:GetAttr(ItemAttr_Native.Guid)
            local EquipDurableVal = 0
            local EquipDurableMax = 0
            -- if petGuid == nil then
            -- EquipDurableVal = LD.GetItemIntCustomAttrByGuid("EquipDurableVal",itemGUID,item_container_type.item_container_bag)
            -- EquipDurableMax = LD.GetItemIntCustomAttrByGuid("EquipDurableMax",itemGUID,item_container_type.item_container_bag)
            EquipDurableVal = itemData:GetIntCustomAttr("EquipDurableVal")
            EquipDurableMax = itemData:GetIntCustomAttr("EquipDurableMax")
            -- else
            -- EquipDurableVal = itemData:GetIntCustomAttr("EquipDurableVal")
            -- EquipDurableMax = itemData:GetIntCustomAttr("EquipDurableMax")
            -- EquipDurableVal = LD.GetItemIntCustomAttrByGuid("EquipDurableVal",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid)))
            -- EquipDurableMax = LD.GetItemIntCustomAttrByGuid("EquipDurableMax",itemGUID,item_container_type.item_container_pet_equip,uint64.new(tostring(petGuid)))
            -- end
            if EquipDurableMax ~= nil then
                if EquipDurableMax == 0 then
                    EquipDurableVal = "无限"
                    EquipDurableMax = "无限"
                end
                GUI.TipsAddLabel(itemTips, 20, "耐久度：" .. EquipDurableVal .. "/" .. EquipDurableMax, UIDefine.Yellow3Color, false)
            end
        else
            local DurableNow = itemData:GetIntCustomAttr("DurableNow")
            local DurableMax = itemData:GetIntCustomAttr("DurableMax")
            if DurableMax ~= nil then
                if DurableMax == 0 then
                    DurableNow = "无限"
                    DurableMax = "无限"
                end
                GUI.TipsAddLabel(itemTips, 20, "耐久度：" .. DurableNow .. "/" .. DurableMax, UIDefine.Yellow3Color, false)
            end
        end
    end

    GUI.TipsAddCutLine(itemTips)
end


--点击文本查看特效介绍
function Tips.OnClickSpecialEffectTipsBtn(guid)
    local parent = GUI.GetParentElement(GUI.GetByGuid(guid))
    local SpecialEffect = tonumber(GUI.GetData(GUI.GetByGuid(guid), "SpecialEffect"))
    local SpecialEffectDB = DB.GetOnceSkillByKey1(SpecialEffect)
    local y = GUI.GetPositionY(GUI.GetByGuid(guid))
    if y < 0 then
        y = y * -1
    end
    y = y + 25
    local TipsBg = GUI.ImageCreate(parent, "TipsBg", "1800400290", 0, y, false, 340, 110)
    GUI.SetIsRaycastTarget(TipsBg, true)
    TipsBg:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRemoveWhenClick(TipsBg, true)

    local Text = GUI.CreateStatic(TipsBg, "Text", tostring(SpecialEffectDB.Name), -80, 0, 150, 50, "system", true);
    GUI.SetColor(Text, UIDefine.GradeColor[SpecialEffectDB.SkillQuality])
    GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(Text, TextAnchor.MiddleLeft)

    local Text2 = GUI.CreateStatic(TipsBg, "Text2", tostring(SpecialEffectDB.Info), -5, 38, 300, 220, "system", true);
    GUI.SetColor(Text2, UIDefine.GradeColor[SpecialEffectDB.SkillQuality])
    GUI.StaticSetFontSize(Text2, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(Text2, TextAnchor.UpperLeft)

    local h2 = GUI.StaticGetLabelPreferHeight(Text2)
    GUI.SetHeight(TipsBg, 38 + 8 + h2)
end

--点击文本查看特技介绍
function Tips.OnClickStuntTipsBtn(guid)
    local parent = GUI.GetParentElement(GUI.GetByGuid(guid))
    local StuntID = tonumber(GUI.GetData(GUI.GetByGuid(guid), "StuntID"))
    local StuntDB = DB.GetOnceSkillByKey1(StuntID)
    local y = GUI.GetPositionY(GUI.GetByGuid(guid))
    if y < 0 then
        y = y * -1
    end
    y = y + 25
    local TipsBg = GUI.ImageCreate(parent, "TipsBg", "1800400290", 0, y, false, 340, 110)
    GUI.SetIsRaycastTarget(TipsBg, true)
    TipsBg:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRemoveWhenClick(TipsBg, true)

    local Text = GUI.CreateStatic(TipsBg, "Text", tostring(StuntDB.Name), -80, 0, 150, 50, "system", true);
    GUI.SetColor(Text, UIDefine.GradeColor[StuntDB.SkillQuality])
    GUI.StaticSetFontSize(Text, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(Text, TextAnchor.MiddleLeft)

    local Text2 = GUI.CreateStatic(TipsBg, "Text2", tostring(StuntDB.Info), -5, 38, 300, 220, "system", true);
    GUI.SetColor(Text2, UIDefine.GradeColor[StuntDB.SkillQuality])
    GUI.StaticSetFontSize(Text2, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(Text2, TextAnchor.UpperLeft)

    local h2 = GUI.StaticGetLabelPreferHeight(Text2)
    GUI.SetHeight(TipsBg, 38 + 8 + h2)
end

function Tips.AddInfoAndTips(itemTips, itemDB, itemData)
    if itemData ~= nil then
        if itemData:GetIntCustomAttr(LogicDefine.GemValue) > 0 then
            GUI.TipsAddLabel(
                    itemTips,
                    20,
                    "基础属性：<color=#21DDDAB2>价值 " .. itemData:GetIntCustomAttr(LogicDefine.GemValue) .. "</color>",
                    UIDefine.Yellow3Color,
                    true
            )
            local attrDatas = itemData:GetDynAttrDataByMark(LogicDefine.GemAttrMark)
            if attrDatas.Count > 0 then
                local attrData = attrDatas[0]
                local attrId = attrData.attr
                local value = attrData.value
                GUI.TipsAddLabel(itemTips, 45, UIDefine.GetAttrDesStr(attrId, value), UIDefine.WhiteColor, false)
            end
            GUI.TipsAddCutLine(itemTips)
        end

        if itemDB.Type == 7 and itemDB.Subtype == 2 then
            GUI.TipsAddLabel(itemTips, 20, "炼妖效果：", UIDefine.Yellow3Color, false)

            local dynDatas = itemData:GetDynAttrDatas()
            for i = 0, dynDatas.Count - 1 do
                local dynData = dynDatas[i]
                local attrId = dynData.attr
                local attrDB = DB.GetOnceAttrByKey1(attrId)
                local value = tostring(dynData.value)
                if attrDB.IsPct == 1 then
                    value = tostring(tonumber(value) / 100) .. "%"
                end
                GUI.TipsAddLabel(itemTips, 20, attrDB.ChinaName .. "   +" .. value, UIDefine.WhiteColor, false)
            end
            GUI.TipsAddCutLine(itemTips)
        end

        local itemSkillId = tonumber(tostring(itemData:GetIntCustomAttr(LogicDefine.CustomKey.ITEM_PetSkill)))
        if itemSkillId ~= 0 then
            local skillDB = DB.GetOnceSkillByKey1(itemSkillId)
            GUI.TipsAddLabel(itemTips, 20, "提炼技能：", UIDefine.Yellow3Color, false)

            local str = "    " .. skillDB.Name .. "：<color= #ffffffff>" .. skillDB.Info .. "</color>"
            GUI.TipsAddLabel(itemTips, 20, str, UIDefine.GradeColor[skillDB.SkillQuality], true)
            GUI.TipsAddCutLine(itemTips)
        end

        local danSkillId = tonumber(tostring(itemData:GetIntCustomAttr(LogicDefine.CustomKey.ITEM_NeidanSkillID)))
        if danSkillId ~= 0 then
            local skillDB = DB.GetOnceSkillByKey1(danSkillId)
            GUI.TipsAddLabel(itemTips, 20, "内丹技能：", UIDefine.Yellow3Color, false)
            local str = "    " .. skillDB.Name .. "：<color= #ffffffff>" .. skillDB.Tips .. "</color>"
            GUI.TipsAddLabel(itemTips, 20, str, UIDefine.GradeColor[skillDB.SkillQuality], true)

            local danSkillLv = tonumber(tostring(itemData:GetIntCustomAttr(LogicDefine.CustomKey.ITEM_NeidanSkillLV)))
            local danSkillRe = tonumber(tostring(itemData:GetIntCustomAttr(LogicDefine.CustomKey.ITEM_NeidanSkillRE)))
            local str = "技能等级：<color=#46DC5Fff>" .. danSkillRe .. "</color> 转 <color=#46DC5Fff>" .. danSkillLv .. "</color> 级"
            GUI.TipsAddLabel(itemTips, 45, str, UIDefine.Yellow3Color, false)

            GUI.TipsAddCutLine(itemTips)
        end
    end

    if itemDB.Type ~= 1 and itemDB.Info ~= "不显示" and itemDB.Info ~= "0" then
        GUI.TipsAddLabel(itemTips, 20, "效用：", UIDefine.Yellow3Color, false)
        GUI.TipsAddLabel(itemTips, 20, itemDB.Info, UIDefine.WhiteColor, false)
        GUI.TipsAddCutLine(itemTips)
    end

    GUI.TipsAddLabel(itemTips, 20, itemDB.Tips, UIDefine.Brown2Color, false)
end

function Tips.CreateSkillId(skillId, parent, name, x, y, w, extHeight, level, info)
    if skillId == nil then
        return nil
    end

    extHeight = extHeight + 20 or 0
    --if level then
    --    extHeight = extHeight + 30
    --end
    local skillDB = DB.GetOnceSkillByKey1(skillId)
    local skillTips = GUI.TipsCreate(parent, name, x, y, w, extHeight)
    GUI.SetIsRemoveWhenClick(skillTips, true)
    local itemIcon = GUI.TipsGetItemIcon(skillTips)
    ItemIcon.BindSkillDB(itemIcon, skillDB)
    GUI.TipsAddLabel(skillTips, 20, "<color=#ddd221>【技能效果】：</color>", UIDefine.WhiteColor, true);
    local posX, posY = 120, 50
    if level then
        posX = 100
        posY = 15
        GUI.SetPositionY(itemIcon, 50)
        local CutLine = GUI.GetChild(skillTips, "CutLine")
        GUI.SetPositionY(CutLine, 150)
        local InfoScr = GUI.GetChild(skillTips, "InfoScr")
        GUI.SetPositionY(InfoScr, 158)
        local txtX, txtY = 100, 50
        local typeText = GUI.CreateStatic(itemIcon, "typeText", "<color=#ddd221>类型：" .. GlobalUtils.GetSkillIconTypeTipString(skillId) .. "</color>", txtX, txtY - 50, 200, 35, "system", true)
        GUI.StaticSetFontSize(typeText, UIDefine.FontSizeM)

        --宠物技能不显示等阶（暂时宠物技能不可升级，无意义
        if skillDB.ActorType == 2 then
            local cost = GlobalUtils.GetSkillCostStr(skillId, level, skillDB)
            local costText = GUI.CreateStatic(itemIcon, "costText", "<color=#ddd221>消耗：" .. cost .. "</color>", txtX, txtY - 15, 200, 35, "system", true)
            GUI.StaticSetFontSize(costText, UIDefine.FontSizeM)
        else
            local levelStr = skillDB.UpSkill > 0 and skillDB.UpSkill .. "阶" .. level or tostring(level)
            local levelText = GUI.CreateStatic(itemIcon, "levelText", "<color=#ddd221>等级：" .. levelStr .. "级</color>", txtX, txtY - 25, 200, 35, "system", true)
            GUI.StaticSetFontSize(levelText, UIDefine.FontSizeM)
            local cost = GlobalUtils.GetSkillCostStr(skillId, level, skillDB)
            local costText = GUI.CreateStatic(itemIcon, "costText", "<color=#ddd221>消耗：" .. cost .. "</color>", txtX, txtY, 200, 35, "system", true)
            GUI.StaticSetFontSize(costText, UIDefine.FontSizeM)
        end
    end

    local nameText = GUI.CreateStatic(skillTips, "nameText", skillDB.Name, posX, posY, 200, 35)
    GUI.SetColor(nameText, UIDefine.GradeColor[skillDB.SkillQuality])
    GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter)
    UILayout.SetSameAnchorAndPivot(nameText, UILayout.TopLeft)

    info = string.gsub(info or skillDB.Info, "\\n", "\n")
    GUI.TipsAddLabel(skillTips, 20, "", UIDefine.WhiteColor, true)
    GUI.TipsAddLabel(skillTips, 20, "", UIDefine.WhiteColor, true)
    if skillDB.Tips ~= 0 and skillDB.Tips ~= "0" then
        info = info .. "\n<color=#ffdf72ff>" .. skillDB.Tips .. "</color>"
    end
    local label = GUI.TipsAddLabel(skillTips, 20, info, UIDefine.WhiteColor, true)
    GUI.SetPositionY(label, 40)

    return skillTips
end

function Tips.CreateBreachSkillId(skillId, parent, name, x, y, w, extHeight, grade, star)
    if skillId == nil then
        return nil
    end
    if star >= grade then
        extHeight = extHeight or 0
        local skillDB = DB.GetOnceSkillByKey1(skillId)
        local skillTips = GUI.TipsCreate(parent, name, x, y, w, extHeight)
        GUI.SetIsRemoveWhenClick(skillTips, true)
        local itemIcon = GUI.TipsGetItemIcon(skillTips)
        ItemIcon.BindSkillDB(itemIcon, skillDB)
        local level = GUI.CreateStatic(skillTips, "level", "等级", 120, 65, 200, 35, "system", true)
        GUI.StaticSetText(level, "等级：" .. grade .. "级")
        GUI.StaticSetFontSize(level, UIDefine.FontSizeL)
        GUI.StaticSetAlignment(level, TextAnchor.MiddleLeft)
        GUI.SetColor(level, UIDefine.YellowColor)
        UILayout.SetSameAnchorAndPivot(level, UILayout.TopLeft)

        local nameText = GUI.CreateStatic(skillTips, "nameText", skillDB.Name, 120, 30, 200, 35)
        GUI.SetColor(nameText, UIDefine.GradeColor[skillDB.SkillQuality])
        GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
        GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
        UILayout.SetSameAnchorAndPivot(nameText, UILayout.TopLeft)

        local info = string.gsub(skillDB.Info, "\\n", "\n")
        GUI.TipsAddLabel(skillTips, 20, info, UIDefine.WhiteColor, true)
    elseif star < grade then
        extHeight = 110
        local skillDB = DB.GetOnceSkillByKey1(skillId)
        local skillTips = GUI.TipsCreate(parent, name, x, y, w, extHeight)
        GUI.SetIsRemoveWhenClick(skillTips, true)
        local itemIcon = GUI.TipsGetItemIcon(skillTips)
        ItemIcon.BindSkillDB(itemIcon, skillDB)

        local hengxian = GUI.ImageCreate(skillTips, "hengxian", "1800600030", 0, 35, false, 400, 5)
        local Tips = GUI.CreateStatic(skillTips, "Tips", "", 25, 75, 400, 35, "system", true)
        GUI.StaticSetText(Tips, "宠物提升至" .. "<color=#42B1F0>" .. grade .. "</color>星，可激活此技能")
        GUI.StaticSetFontSize(Tips, UIDefine.FontSizeM)
        GUI.StaticSetAlignment(Tips, TextAnchor.MiddleLeft)
        UILayout.SetSameAnchorAndPivot(Tips, UILayout.Left)

        local nameText = GUI.CreateStatic(skillTips, "nameText", skillDB.Name, 120, 30, 200, 35)
        GUI.SetColor(nameText, UIDefine.GradeColor[skillDB.SkillQuality])
        GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
        GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
        UILayout.SetSameAnchorAndPivot(nameText, UILayout.TopLeft)

        local info = string.gsub(skillDB.Info, "\\n", "\n")
        GUI.TipsAddLabel(skillTips, 20, info, UIDefine.WhiteColor, true)

        local level = GUI.CreateStatic(skillTips, "level", "等级", 120, 65, 200, 35, "system", true)
        GUI.StaticSetText(level, "等级：" .. grade .. "级")
        GUI.StaticSetFontSize(level, UIDefine.FontSizeL)
        GUI.StaticSetAlignment(level, TextAnchor.MiddleLeft)
        GUI.SetColor(level, UIDefine.YellowColor)
        UILayout.SetSameAnchorAndPivot(level, UILayout.TopLeft)
    end

    return skillTips
end

function Tips.CreateSkillTips(skillData, parent, name, x, y, w, extHeight, _gt)
    if skillData == nil then
        return nil
    end
    w = w or 0
    extHeight = extHeight or 0

    local skillTips = GUI.TipsCreate(parent, name, x, y, w, extHeight)
    GUI.SetIsRemoveWhenClick(skillTips, true)
    local itemIcon = GUI.TipsGetItemIcon(skillTips)
    ItemIcon.BindSkill(itemIcon, skillData)

    local skillId = skillData.id
    local skillDB = DB.GetOnceSkillByKey1(skillId)
    if skillDB.Id ~= 0 then
        local nameText = GUI.CreateStatic(skillTips, "nameText", skillDB.Name, 120, 50, 200, 35)
        GUI.SetColor(nameText, UIDefine.GradeColor[skillDB.SkillQuality])
        GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
        GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
        UILayout.SetSameAnchorAndPivot(nameText, UILayout.TopLeft)

        if skillData.performance and skillData.max_performance then
            GUI.TipsAddLabel(
                    skillTips,
                    20,
                    "【熟练度】 " .. skillData.performance .. "/" .. skillData.max_performance,
                    UIDefine.WhiteColor,
                    false
            )
            GUI.TipsAddLabel(
                    skillTips,
                    20,
                    "【消耗MP】 " ..
                            (skillData.blueCost or
                                    tostring(GlobalUtils.GetSkillCost(skillId, skillData.performance, skillDB))),
                    UIDefine.WhiteColor,
                    false
            )
        end

        local tipsText = string.gsub(skillData.tips, "\\n", "\n")
        local skillTipsLabel = GUI.TipsAddLabel(skillTips, 20, tipsText, UIDefine.WhiteColor, true)
        if _gt ~= nil then
            _gt.BindName(skillTipsLabel, "skillTipsLabel")
        end

        if skillData.performance then
            GUI.TipsAddLabel(skillTips, 20, "", UIDefine.Green3Color, false)
            local tip = GlobalUtils.GetSkillTargetNumTips(skillId, skillData.performance, skillDB)
            if tip then
                GUI.TipsAddLabel(skillTips, 20, tip, UIDefine.Green3Color, false)
            end
        end
    end
    return skillTips
end

function Tips.CreateHint(msg, parent, x, y, uiLayout, w, h, isRich)
    isRich = isRich == nil and false or true
    local hintBg = GUI.ImageCreate(parent, "hintBg", "1800400290", x, y, false, 0, 0)
    GUI.SetIsRaycastTarget(hintBg, true)
    hintBg:RegisterEvent(UCE.PointerClick)
    UILayout.SetSameAnchorAndPivot(hintBg, uiLayout)
    GUI.SetIsRemoveWhenClick(hintBg, true)
    local hintText = GUI.CreateStatic(hintBg, "hintText", msg, 0, 0, 200, 0, "system", isRich)
    GUI.SetColor(hintText, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(hintText, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(hintText, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(hintText, UILayout.Center)
    w = w or GUI.StaticGetLabelPreferWidth(hintText)
    GUI.SetWidth(hintText, w)
    h = h or GUI.StaticGetLabelPreferHeight(hintText)
    GUI.SetHeight(hintText, h)
    GUI.SetWidth(hintBg, w + 30)
    GUI.SetHeight(hintBg, h + 30)
    return hintBg
end

function Tips.RegisterAttrHintEvent(text, wndName)
    if text == nil or wndName == nil then
        return
    end
    GUI.SetIsRaycastTarget(text, true)
    text:UnRegisterEvent(UCE.PointerClick)
    text:RegisterEvent(UCE.PointerClick)
    GUI.UnRegisterUIEvent(text, UCE.PointerClick, "Tips", "OnAttrDescHintEvent")
    GUI.RegisterUIEvent(text, UCE.PointerClick, "Tips", "OnAttrDescHintEvent")
    GUI.SetData(text, "WndName", wndName)
end

local attrNameMap = {
    ["亲密"] = "亲密度",
    ["忠诚"] = "宠物忠诚度",
    ["气血"] = "血量上限",
    ["法力"] = "法力上限",
    ["怒气"] = "怒气上限",
    ["活力"] = "活力上限",
    ["物攻"] = "物理攻击",
    ["物防"] = "物理防御",
    ["法攻"] = "法术攻击",
    ["法攻"] = "法术攻击",
    ["法防"] = "法术防御",
    ["法暴"] = "法暴率",
    ["速度"] = "战斗速度",
    ["物暴"] = "物暴率",
}

function Tips.OnAttrDescHintEvent(guid)
    local text = GUI.GetByGuid(guid)

    local name = GUI.StaticGetText(text)
    local temp = attrNameMap[name]
    if temp then
        name = temp
    end
    local attrDescTable = Tips.GetAttrDescTable()
    local info = attrDescTable[name]
    if info ~= nil then
        local parent = GUI.GetWnd(GUI.GetData(text, "WndName"))
        if parent ~= nil then
            local pos1 = GUI.GetScreenPoint(text)
            local pos2 = GUI.GetPointByScreenPoint(parent, Vector3.New(pos1.x, pos1.y, pos1.z))
            if pos2.x < -430 then
                pos2.x = -430
            elseif pos2.x > 430 then
                pos2.x = 430
            end
            Tips.CreateHint(info, parent, pos2.x, -pos2.y - 25, { UIAnchor.Center, UIAroundPivot.Bottom }, 350)
        end
    end
end

function Tips.GetAttrDescTable()
    if Tips.attrDescTable == nil then
        Tips.attrDescTable = {}

        local ids = DB.GetAttrAllKey1s()
        for i = 0, ids.Count - 1 do
            local attrDB = DB.GetOnceAttrByKey1(ids[i])
            Tips.attrDescTable[attrDB.KeyName] = attrDB.Info
        end
    end

    return Tips.attrDescTable
end

function Tips.CreateGuardItemData(guardGuid, itemData, parent, name, x, y, extHeight)
    if itemData == nil then
        return nil
    end

    local itemDB = DB.GetOnceItemByKey1(itemData.id)
    if itemDB.Id == 0 then
        return nil
    end

    if extHeight == nil then
        extHeight = 0
    end

    local itemTips = GUI.ItemTipsCreate(parent, name, x, y, extHeight)
    GUI.SetIsRemoveWhenClick(itemTips, true)
    local itemIcon = GUI.TipsGetItemIcon(itemTips)
    ItemIcon.BindItemData(itemIcon, itemData, true)

    Tips.SetBaseInfo(itemTips, itemDB, itemData, guardGuid)

    if itemDB.Type == 1 then
        Tips.AddEquipInfoByItemData(itemTips, itemDB, itemData, guardGuid)
    end

    Tips.AddInfoAndTips(itemTips, itemDB, itemData)

    return itemTips
end

function Tips.CreatePetTip(petKeyName, parent, name, x, y)

    local petDB = DB.GetOncePetByKey2(petKeyName)
    if petDB.Id == 0 then
        return
    end

    local tips = GUI.ItemTipsCreate(parent, name, x, y, 0)
    GUI.SetIsRemoveWhenClick(tips, true)
    local itemIcon = GUI.TipsGetItemIcon(tips)
    ItemIcon.BindPetKeyName(itemIcon, petKeyName);
    GUI.ItemTipsSetItemName(tips, petDB.Name, UIDefine.GradeColor[petDB.Grade])
    GUI.ItemTipsSetItemType(tips, "类型：宠物", UIDefine.YellowColor)
    GUI.ItemTipsSetItemShowLevel(tips, "等级：1级", UIDefine.YellowColor)
    GUI.ItemTipsSetItemLevel(tips, "所需等级：1级", UIDefine.YellowColor)
    GUI.ItemTipsSetItemLimit(tips, "所需角色：所有角色", UIDefine.YellowColor)
    GUI.TipsAddLabel(tips, 20, "获得宠物：" .. petDB.Name, UIDefine.WhiteColor, false)
    return tips
end

function Tips.CreateGuardTip(guardKeyName, parent, name, x, y)
    local guardDB = DB.GetOnceGuardByKey2(guardKeyName)
    if guardDB.Id == 0 then
        return
    end

    local tips = GUI.ItemTipsCreate(parent, name, x, y, 0)
    GUI.SetIsRemoveWhenClick(tips, true)
    local itemIcon = GUI.TipsGetItemIcon(tips)
    ItemIcon.BindGuardKeyName(itemIcon, guardKeyName)
    GUI.ItemTipsSetItemName(tips, guardDB.Name, UIDefine.GradeColor[guardDB.Grade])
    GUI.ItemTipsSetItemType(tips, "类型：侍从", UIDefine.YellowColor)
    GUI.ItemTipsSetItemShowLevel(tips, "等级：1级", UIDefine.YellowColor)
    GUI.ItemTipsSetItemLevel(tips, "所需等级：1级", UIDefine.YellowColor)
    GUI.ItemTipsSetItemLimit(tips, "所需角色：所有角色", UIDefine.YellowColor)
    GUI.TipsAddLabel(tips, 20, "获得侍从：" .. guardDB.Name, UIDefine.WhiteColor, false)
    return tips
end

function Tips.IsItemGetWayValid_Store()
    if Tips.CurItemConfig then
        -- local fromItem = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        -- if fromItem ~= nil and tostring(tonumber(fromItem.FastShop)) == fromItem.FastShop and fromItem.FastShop == "3" then
        -- return true
        -- end
        -- if tostring(tonumber(Tips.CurItemConfig.FastShop)) == Tips.CurItemConfig.FastShop and Tips.CurItemConfig.FastShop == "3" then
        -- return true
        -- end
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "3" or Tips.CurItemConfig.FastShop == "6" or Tips.CurItemConfig.FastShop == "201" then
            return true
        end
    end
    return false
end

function Tips.IsItemGetWayValid_Commerce()
    if Tips.CurItemConfig then
        -- local exchange = DB.GetOnceExchangeByKey1(Tips.CurItemConfig.Id)
        -- local fromItemExchange = DB.GetOnceExchangeByKey1(Tips.CurItemConfig.FromItem)
        -- if fromItemExchange ~= nil then
        -- return true
        -- end

        -- if exchange ~= nil then
        -- return true
        -- end
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "1" or Tips.CurItemConfig.FastShop == "7" or Tips.CurItemConfig.FastShop == "15" then
            return true
        end
    end
    return false
end

function Tips.IsItemGetWayValid_Shop()
    if Tips.CurItemConfig ~= nil then
        -- and Tips.CurItemConfig.FromItem>= 8 and Tips.CurItemConfig.FromItem <= 12 then
        -- return true
        -- CDebug.LogError(type(Tips.CurItemConfig.FromItem))
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "2" then
            return true
        end
    end
    return false
end
--祈福
function Tips.IsItemGetWayValid_Pray()
    if Tips.CurItemConfig ~= nil then
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "5" or Tips.CurItemConfig.FastShop == "6" or Tips.CurItemConfig.FastShop == "7" then
            return true
        end
    end
    return false
end
--奇遇商店
function Tips.IsItemGetWayValid_QYShop()
    if Tips.CurItemConfig ~= nil then
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "8" then
            return true
        end
    end
    return false
end
--功勋商店
function Tips.IsItemGetWayValid_GXShop()
    if Tips.CurItemConfig ~= nil then
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "9" then
            return true
        end
    end
    return false
end
--战功商店
function Tips.IsItemGetWayValid_ZGShop()
    if Tips.CurItemConfig ~= nil then
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "10" then
            return true
        end
    end
    return false
end
--荣誉商店
function Tips.IsItemGetWayValid_RYShop()
    if Tips.CurItemConfig ~= nil then
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "11" or Tips.CurItemConfig.FastShop == "15" then
            return true
        end
    end
    return false
end
--师徒商店
function Tips.IsItemGetWayValid_STShop()
    if Tips.CurItemConfig ~= nil then
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "12" then
            return true
        end
    end
    return false
end
--宝石合成
function Tips.IsItemGetWayValid_Gem()
    if Tips.CurItemConfig ~= nil then
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.FastShop == "101" or Tips.CurItemConfig.FastShop == "201" then
            return true
        end
    end
    return false
end

--生产
function Tips.IsItemGetWayValid_Produce()
    if Tips.CurItemConfig ~= nil then
        if Tips.CurItemConfig.FromItem ~= 0 then
            Tips.CurItemConfig = DB.GetOnceItemByKey1(Tips.CurItemConfig.FromItem)
        end

        if Tips.CurItemConfig.Type == 2 and Tips.CurItemConfig.Subtype == 29 then
            return true
        end
    end
    return false
end

function Tips.IsItemGetWayValid_ExtUI()
    if Tips.CurItemConfig ~= nil then
        local val = string.split(Tips.CurItemConfig.FastShop, ",")
        if #val == 3 then
            --FormItemGetWayFastShop作为限定的字符名称
            if val[3] ~= "FormItemGetWayFastShop" then
                return true, val
            end
        end
    end
    return false
end

function Tips.IsItemGetWayValid_ExtLua()
    if Tips.CurItemConfig ~= nil then
        local val = string.split(Tips.CurItemConfig.FastShop, ",")
        if #val >= 3 then
            --FormItemGetWayFastShop作为限定的字符名称
            if val[3] == "FormItemGetWayFastShop" then
                return true, val
            end
        end
    end
    return false
end

function Tips.OnItemGetWayOpenWnd_Store(guid)
    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId"))
    test(ItemId)
    if not ItemId and PetUI.TempEquipID then
        ItemId = PetUI.TempEquipID
        PetUI.TempEquipID = nil
    end
    local itemConfig = DB.GetOnceItemByKey1(ItemId)
    local useID = ItemId
    if itemConfig ~= nil and itemConfig.FromItem ~= 0 then
        useID = itemConfig.FromItem
    end
    test("商城")
    GUI.OpenWnd("MallUI", itemConfig.KeyName)
    --GlobalUtils.ItemToMall(itemConfig.KeyName)
    -- Tips.MallItemKey = itemConfig.KeyName
    -- if GlobalUtils.MallItemData then
    -- GlobalUtils.RefreshMallData()
    -- test("已有商城数据")
    -- else
    -- GlobalUtils.GetMallData()
    -- end

end
--点击祈福途径
function Tips.OnItemGetWayOpenWnd_Pray(guid)
    test(guid)
    GUI.OpenWnd("PrayUI")
end

--点击奇遇商店途径
function Tips.OnItemGetWayOpenWnd_QYShop(guid)
    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId"))
    local itemConfig = DB.GetOnceItemByKey1(ItemId)

    GUI.OpenWnd("ShopStoreUI", "3," .. tostring(ItemId))

end
--点击功勋商店途径
function Tips.OnItemGetWayOpenWnd_GXShop(guid)
    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId"))
    local itemConfig = DB.GetOnceItemByKey1(ItemId)

    GUI.OpenWnd("ShopStoreUI", "7," .. tostring(ItemId) .. ",1")

end
--点击战功商店途径
function Tips.OnItemGetWayOpenWnd_ZGShop(guid)
    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId"))
    local itemConfig = DB.GetOnceItemByKey1(ItemId)

    GUI.OpenWnd("ShopStoreUI", "5," .. tostring(ItemId))

end
--点击荣誉商店途径
function Tips.OnItemGetWayOpenWnd_RYShop(guid)
    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId"))
    local itemConfig = DB.GetOnceItemByKey1(ItemId)

    GUI.OpenWnd("ShopStoreUI", "2," .. tostring(ItemId))
end

--点击师徒商店途径
function Tips.OnItemGetWayOpenWnd_STShop(guid)
    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId"))
    local itemConfig = DB.GetOnceItemByKey1(ItemId)

    GUI.OpenWnd("ShopStoreUI", "6," .. tostring(ItemId))
end

--点击宝石合成
function Tips.OnItemGetWayOpenWnd_Gem(guid)
    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId")) - 1

    GUI.OpenWnd("EquipUI", "index:2,index2:1,itemId:" .. tostring(ItemId))

    local tips = GUI.Get("EquipUI/panelBg/gemPage/gemMergeGroup/Merge_Bg/tips")
    if tips then
        GUI.Destroy(tips)
    end
end

function Tips.OnItemGetWayOpenWnd_Produce(guid)
    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId"))
    local item = DB.GetOnceItemByKey1(ItemId)
    local index1 = 1
    if item.ShowType ~= "烹饪" then
        index1 = 2
    end
    GUI.OpenWnd("ProduceUI", "index:" .. index1 .. ",index2:" .. tostring(ItemId))

end

function Tips.OnItemGetWayOpenWnd_Commerce(guid)
    test(guid)
    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId"))
    test(ItemId)
    test("商会")
    if not ItemId and PetUI.TempEquipID then
        ItemId = PetUI.TempEquipID
        PetUI.TempEquipID = nil
    end
    if ItemId == "28107" then
        ItemId = "4001"
    elseif ItemId == "28108" then
        ItemId = "4201"
    elseif ItemId == "28109" then
        ItemId = "4401"
    end
    local itemDB = DB.GetOnceExchangeByKey1(ItemId)
    GUI.OpenWnd("CommerceUI", tostring(itemDB.Type) .. "," .. tostring(itemDB.SubType) .. "," .. tostring(ItemId))
    test(itemDB.Type)
    test(itemDB.SubType)

end

function Tips.OnItemGetWayOpenWnd_Shop(guid)
    -- CDebug.LogError(LD.GetRoleInTeamState())
    if LD.GetRoleInTeamState() == 3 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "您不是队长，无法进行该操作")
        return
    end

    local btn = GUI.GetByGuid(guid)
    local ItemId = tonumber(GUI.GetData(btn, "ItemId"))
    local itemConfig = DB.GetOnceItemByKey1(ItemId)
    if itemConfig == nil then
        return
    end
    local id = ItemId
    if itemConfig.FromItem ~= 0 then
        id = itemConfig.FromItem
    end
    local NPCID = UIDefine.ShopTrack[UIDefine.ItemShopTrack[id]]
    -- CDebug.LogError(NPCID)
    CL.StartMove(NPCID, false)
    CL.SetMoveEndAction(MoveEndAction.OpenShop, id)
end

function Tips.OnItemGetWayOpenWnd_ExtUI(guid)
    if Tips.CurItemConfig ~= nil then
        local val = string.split(Tips.CurItemConfig.FastShop, ",")
        if #val == 3 then
            --FormItemGetWayFastShop作为限定的字符名称
            if val[3] ~= "FormItemGetWayFastShop" then
                GUI.OpenWnd(val[3])
            end
        end
    end
end

function Tips.OnItemGetWayOpenWnd_ExtLua(guid)
    if Tips.CurItemConfig ~= nil then
        local val = string.split(Tips.CurItemConfig.FastShop, ",")
        if #val >= 3 then
            --FormItemGetWayFastShop作为限定的字符名称
            if val[3] == "FormItemGetWayFastShop" then
                local paramInfo = ""
                if #val >= 4 then
                    paramInfo = val[4]
                    for i = 5, #val do
                        paramInfo = paramInfo .. "," .. val[i]
                    end
                end
                print("发出 ： " .. paramInfo)
                CL.SendNotify(NOTIFY.SubmitForm, "FormItemGetWayFastShop", "Main", paramInfo)
            end
        end
    end
end

function Tips.OnActivityWayBtnClick(guid)
    GUI.OpenWnd("ActivityPanelUI")
end

local ItemGetWay = {
    [1] = { [1] = "商会", [2] = "1800408480", [3] = Tips.IsItemGetWayValid_Commerce, [4] = "OnItemGetWayOpenWnd_Commerce" },
    [2] = { [1] = "商店", [2] = "1800408450", [3] = Tips.IsItemGetWayValid_Shop, [4] = "OnItemGetWayOpenWnd_Shop" },
    [3] = { [1] = "商城", [2] = "1800408510", [3] = Tips.IsItemGetWayValid_Store, [4] = "OnItemGetWayOpenWnd_Store" },
    [4] = { [1] = "祈福", [2] = "1800202520", [3] = Tips.IsItemGetWayValid_Pray, [4] = "OnItemGetWayOpenWnd_Pray" }, --以下方法未写
    [5] = { [1] = "奇遇商店", [2] = "1801508170", [3] = Tips.IsItemGetWayValid_QYShop, [4] = "OnItemGetWayOpenWnd_QYShop" },
    [6] = { [1] = "功勋商店", [2] = "1800408450", [3] = Tips.IsItemGetWayValid_GXShop, [4] = "OnItemGetWayOpenWnd_GXShop" },
    [7] = { [1] = "战功商店", [2] = "1800408510", [3] = Tips.IsItemGetWayValid_ZGShop, [4] = "OnItemGetWayOpenWnd_ZGShop" },
    [8] = { [1] = "荣誉商店", [2] = "1800408510", [3] = Tips.IsItemGetWayValid_RYShop, [4] = "OnItemGetWayOpenWnd_RYShop" },
    [9] = { [1] = "师徒商店", [2] = "1800408510", [3] = Tips.IsItemGetWayValid_STShop, [4] = "OnItemGetWayOpenWnd_STShop" },
    [10] = { [1] = "宝石合成", [2] = "1801508240", [3] = Tips.IsItemGetWayValid_Gem, [4] = "OnItemGetWayOpenWnd_Gem" },
    [11] = { [1] = "生产", [2] = "1801508230", [3] = Tips.IsItemGetWayValid_Produce, [4] = "OnItemGetWayOpenWnd_Produce" },
    -- [4] = {[1]="自定义界面XXX", [2]="1800000000", [3]=Tips.IsItemGetWayValid_ExtUI, [4]="OnItemGetWayOpenWnd_ExtUI"},
    -- [5] = {[1]="自定义脚本XXX", [2]="1800000000", [3]=Tips.IsItemGetWayValid_ExtLua, [4]="OnItemGetWayOpenWnd_ExtLua"}
}

Tips.CurItemConfig = nil
function Tips.ShowItemGetWay(tips, leftOffset)
    Tips.CurItemConfig = nil
    if tips == nil then
        return
    end

    if leftOffset == nil then
        leftOffset = 200
    end

    local tipsPosX = GUI.GetPositionX(tips)
    local acquiringWay;
    acquiringWay = GUI.GetChild(tips, "acquiringWay")
    if acquiringWay ~= nil then
        if GUI.GetVisible(acquiringWay) then
            tipsPosX = tipsPosX + leftOffset
            GUI.SetPositionX(tips, tipsPosX)
            GUI.SetVisible(acquiringWay, false)
        else
            tipsPosX = tipsPosX - leftOffset
            GUI.SetPositionX(tips, tipsPosX)
            GUI.SetVisible(acquiringWay, true)
        end
        return
    end

    local itemId = tonumber(GUI.GetData(tips, "ItemId"))
    if not itemId or itemId == 0 then
        return
    end

    tipsPosX = tipsPosX - leftOffset
    GUI.SetPositionX(tips, tipsPosX)

    local acquiringWay = GUI.ImageCreate(tips, "acquiringWay", "1800400290", 0, 0, false, 450, 320)
    UILayout.SetAnchorAndPivot(acquiringWay, UIAnchor.TopRight, UIAroundPivot.TopLeft)

    local title = GUI.CreateStatic(acquiringWay, "title", "获得途径", 20, 20, 100, 30, "system", true);
    UILayout.SetSameAnchorAndPivot(title, UILayout.TopLeft)
    GUI.SetColor(title, UIDefine.Brown2Color)
    GUI.StaticSetFontSize(title, 24);

    local cutline = GUI.ImageCreate(acquiringWay, "cutLine", "1800600030", 0, 60, false, 400, 4);
    UILayout.SetAnchorAndPivot(cutline, UIAnchor.Top, UIAroundPivot.Center)

    local scr = GUI.ScrollRectCreate(acquiringWay, "scr", 0, 30, 430, 230, 0, false, Vector2.New(80, 81), UIAroundPivot.Top, UIAnchor.Top, 4);
    UILayout.SetSameAnchorAndPivot(scr, UILayout.Center)
    GUI.ScrollRectSetChildSpacing(scr, Vector2.New(30, 35));

    local ishasWay = false
    Tips.CurItemConfig = DB.GetOnceItemByKey1(itemId)
    for i = 1, #ItemGetWay do
        local isValid, RetInfo = ItemGetWay[i][3]()
        if isValid then
            local btnClickFuncName = ItemGetWay[i][4]
            local iconName = ItemGetWay[i][2]
            local txtName = ItemGetWay[i][1]
            if RetInfo then
                iconName = RetInfo[2]
                txtName = RetInfo[1]
            end
            local btn = GUI.ButtonCreate(scr, "btn" .. i, "1800400330", 0, 0, Transition.ColorTint, "", 80, 81, false);
            GUI.AddWhiteName(tips, GUI.GetGuid(btn));
            GUI.RegisterUIEvent(btn, UCE.PointerClick, "Tips", btnClickFuncName)
            GUI.SetData(btn, "Index", i);
            GUI.SetData(btn, "ItemId", itemId)
            GUI.ImageCreate(btn, "icon", iconName, 0, 0, false, 70, 70);
            local name = GUI.CreateStatic(btn, "name", txtName, 0, 25, 100, 50, "system", true);
            GUI.SetAnchor(name, UIAnchor.Bottom)
            GUI.StaticSetFontSize(name, UIDefine.FontSizeS)
            GUI.StaticSetAlignment(name, TextAnchor.UpperCenter)
            GUI.SetColor(name, UIDefine.Brown2Color)

            ishasWay = true;
        end
    end

    --活动
    if Tips.CurItemConfig ~= nil and Tips.CurItemConfig.ActivityId ~= "0" then
        local activityIds = string.split(Tips.CurItemConfig.ActivityId, ",")
        local canShowActivityId = {}
        for i = 1, #activityIds do
            local activityId = tonumber(activityIds[i]);
            local activity = DB.GetActivity(activityId);
            local roleJob = CL.GetIntAttr(RoleAttr.RoleAttrJob1);
            if activity ~= nil then
                if activity.School == 0 or activity.School == roleJob then
                    table.insert(canShowActivityId, activityId);
                end
            end
        end

        for i = 1, #canShowActivityId do
            local activityId = canShowActivityId[i];
            local activity = DB.GetActivity(activityId);
            local btn = GUI.ButtonCreate(scr, "activityBtn" .. i, "1800400330", 0, 0, Transition.ColorTint, "", 80, 81, false);
            GUI.AddWhiteName(tips, GUI.GetGuid(btn));
            GUI.RegisterUIEvent(btn, UCE.PointerClick, "Tips", "OnActivityWayBtnClick")
            GUI.SetData(btn, "ActivityId", activityId);
            if activity.Id ~= 0 then
                local icon = GUI.ImageCreate(btn, "icon", tostring(activity.Icon), 0, 0, false, 70, 70);
                local name = GUI.CreateStatic(btn, "name", activity.Name, 0, 25, 100, 50, "system", true);
                GUI.SetAnchor(name, UIAnchor.Bottom)
                GUI.StaticSetFontSize(name, UIDefine.FontSizeS);
                GUI.StaticSetAlignment(name, TextAnchor.UpperCenter);
                GUI.SetColor(name, UIDefine.Brown2Color)
                ishasWay = true;
            else
                CDebug.LogError("此活动ID不存在，请检查配置：" .. tostring(activityId))
            end
        end
    end

    if Tips.CurItemConfig ~= nil and not ishasWay then
        local msg1 = "该道具暂无产出"
        local hint1 = GUI.CreateStatic(acquiringWay, "hint1", msg1, 0, -30, 380, 50, "system", true);
        UILayout.SetSameAnchorAndPivot(hint1, UILayout.Center)
        GUI.StaticSetFontSize(hint1, UIDefine.FontSizeXL);
        GUI.StaticSetAlignment(hint1, TextAnchor.MiddleCenter);
        GUI.SetColor(hint1, UIDefine.Brown2Color)
    end
end
function Tips.CreateTalentTipByInfo(talentInfo, parent, name, x, y, w, extHeight)
    if not talentInfo then
        return nil
    end

    extHeight = extHeight or 0
    local talentTips = GUI.TipsCreate(parent, name, x, y, w, extHeight)
    GUI.SetIsRemoveWhenClick(talentTips, true)
    local itemIcon = GUI.TipsGetItemIcon(talentTips)
    local quality = 1 --TODO:天赋品质
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[quality]);
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, tostring(talentInfo.Icon))
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1, 70, 70);

    local nameText = GUI.CreateStatic(talentTips, "nameText", talentInfo.Name, 120, 30, 200, 35)
    GUI.SetColor(nameText, UIDefine.GradeColor[quality])
    GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(nameText, UILayout.TopLeft)

    local levelText = GUI.CreateStatic(talentTips, "levelText", "等级：" .. talentInfo.TalentLevel .. "级", 120, 70, 200, 35)
    GUI.SetColor(levelText, UIDefine.GradeColor[quality])
    GUI.StaticSetFontSize(levelText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(levelText, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(levelText, UILayout.TopLeft)

    local info = talentInfo.Info -- string.gsub(skillDB.Info, "\\n", "\n")
    GUI.TipsAddLabel(talentTips, 20, info, UIDefine.WhiteColor, true)
    return talentTips
end
function Tips.CreateChinkingItemTipsByInfo(itemInfo, itemName, parent, name, x, y, w, extHeight)
    if not itemInfo then
        return nil
    end
    extHeight = extHeight or 0
    local grade = itemInfo.Grade or 4
    local chinkingItemTips = GUI.TipsCreate(parent, name, x, y, w, extHeight)
    GUI.SetIsRemoveWhenClick(chinkingItemTips, true)

    local itemIcon = GUI.TipsGetItemIcon(chinkingItemTips)
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[grade]);
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, itemInfo.Icon)
    GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1, 70, 70);

    local nameText = GUI.CreateStatic(chinkingItemTips, "nameText", itemName, 120, 30, 200, 35)
    GUI.SetColor(nameText, UIDefine.GradeColor[grade])
    GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL)
    GUI.StaticSetAlignment(nameText, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(nameText, UILayout.TopLeft)

    -- local typeText = GUI.CreateStatic(chinkingItemTips, "typeText", itemInfo.Type, 120, 60, 200, 35)
    -- GUI.SetColor(typeText, UIDefine.YellowColor)
    -- GUI.StaticSetFontSize(typeText, UIDefine.FontSizeS)
    -- GUI.StaticSetAlignment(typeText, TextAnchor.MiddleLeft)
    -- UILayout.SetSameAnchorAndPivot(typeText, UILayout.TopLeft)

    local info = itemInfo.Desc
    GUI.TipsAddLabel(chinkingItemTips, 20, info, UIDefine.WhiteColor, true)
    return chinkingItemTips
end

function Tips.createSoulTipsByItemGuid(guid, parent, x, y, guard_id, _equipped_position, isShowButton)
    if guid == nil then
        return ''
    end

    local item = nil
    if _equipped_position and guard_id then
        item = LD.GetItemDataByGuid(guid, item_container_type.item_container_guard_equip, LD.GetGuardGUIDByID(guard_id))
    else
        item = LD.GetItemDataByGuid(guid, item_container_type.item_container_guard_equip)
    end

    local itemDB = nil
    if item and item.id then
        itemDB = DB.GetOnceItemByKey1(item.id)
    else
        test('Tips.createSoulTipsByItemGuid(guid,parent,x,y,guard_id,_equipped_position) item为空')
        return ''
    end
    if itemDB == nil or itemDB.Id == 0 then
        test('Tips.createSoulTipsByItemGuid(guid,parent,x,y,guard_id,_equipped_position) itemDB为空')
        return ''
    end

    -- suit key name
    local suit_key_name = item:GetStrCustomAttr('minghun_suit_keyname')
    suit_key_name = suit_key_name ~= '' and suit_key_name or nil

    local _level = nil
    if _equipped_position and guard_id then
        _level = LD.GetItemIntCustomAttrByGuid("minghun_intensify_level", guid, item_container_type.item_container_guard_equip, LD.GetGuardGUIDByID(guard_id))
    else
        _level = LD.GetItemIntCustomAttrByGuid("minghun_intensify_level", guid, item.BagType)
    end

    local guard_equipped_bag_type = item_container_type.item_container_guard_equip
    -- 装有多少件套装
    local guard_equipped_count = 0
    -- 是否已经装备
    local is_equipped_of_this_soul = nil
    if guard_id then
        if LD.IsHaveGuard(guard_id) then
            local guard_guid = LD.GetGuardGUIDByID(guard_id)
            for i = 0, 5 do
                local item_data = LD.GetItemDataByIndex(i, guard_equipped_bag_type, guard_guid)
                local _guid = item_data and tostring(item_data.guid) or nil
                if _guid and _guid ~= 0 then

                    -- count suit
                    local _suit_key_name = item_data:GetStrCustomAttr('minghun_suit_keyname')

                    if _suit_key_name and _suit_key_name ~= '' and _suit_key_name == suit_key_name then
                        guard_equipped_count = guard_equipped_count + 1
                    end

                    if tostring(_guid) == tostring(guid) then
                        is_equipped_of_this_soul = true
                    end
                end
            end
        end
    end


    -- position data
    local guard_data = nil
    if guard_id then
        guard_data = DB.GetOnceGuardByKey1(guard_id)
    end
    local position = nil

    if UIDefine.guardSoulEquipSpecialPosition and guard_data and guard_data.Id ~= 0 then
        local data = UIDefine.guardSoulEquipSpecialPosition[guard_data.Name]
        if data then
            position = data[itemDB.Subtype]
        else
            position = UIDefine.guardSoulEquipPosition[itemDB.Subtype]
        end
    elseif UIDefine.guardSoulEquipPosition then
        position = UIDefine.guardSoulEquipPosition[itemDB.Subtype]
    end

    --local bag_type = item.BagType
    local soul_level = _level ~= 0 and _level or 0
    local equip_position_data = position
    local base_attr_data = nil
    local addition_attr_data = nil
    local suit_attr_data = UIDefine.guardSoulSuitListData and UIDefine.guardSoulSuitListData[suit_key_name]  -- and UIDefine.guardSoulSuitListData[itemDB.Grade][suit_key_name]
    local is_equipped = is_equipped_of_this_soul

    local label_color = Color.New(231 / 255, 230 / 255, 28 / 255, 1)
    local attr_color = UIDefine.WhiteColor
    local blue_color = Color.New(30 / 255, 214 / 255, 246 / 255, 1)

    local itemTips = GUI.ItemTipsCreate(parent, 'tips', x, y, 25)
    GUI.SetIsRemoveWhenClick(itemTips, true)

    local itemIcon = GUI.TipsGetItemIcon(itemTips)
    ItemIcon.BindItemData(itemIcon, item, false)

    Tips.SetBaseInfo(itemTips, itemDB, item, 0)

    Tips.DeleteItemShowLevel(itemTips) -- 删除等级属性

    local type_img = GUI.ImageCreate(itemTips, 'type_img', UIDefine.guardSoulImages[itemDB.Subtype][2], -22, 15)
    UILayout.SetSameAnchorAndPivot(type_img, UILayout.TopRight)

    if is_equipped then
        local inEquip = GUI.ImageCreate(itemTips, "inEquip", "1800707290", 0, 0)
        UILayout.SetSameAnchorAndPivot(inEquip, UILayout.TopLeft);
    end

    -- head img
    local head_item_ctrl = GUI.GetChild(itemTips, 'ItemIcon')
    local level_bg = GUI.ImageCreate(head_item_ctrl, 'levelBg', UIDefine.IconLevelBg[itemDB.Grade] or UIDefine.IconLevelBg[#UIDefine.IconLevelBg], 0, 0)
    UILayout.SetSameAnchorAndPivot(level_bg, UILayout.BottomRight)

    local level = GUI.CreateStatic(level_bg, "txt", "1", -5, -2, 24, 26) -- 等级文本 待改大小
    UILayout.SetAnchorAndPivot(level, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(level, TextAnchor.MiddleCenter) -- 设置居中
    GUI.StaticSetFontSize(level, UIDefine.FontSizeM)
    GUI.SetOutLine_Color(level, UIDefine.BlackColor)
    GUI.SetOutLine_Distance(level, 1)
    GUI.SetIsOutLine(level, true)
    GUI.StaticSetText(level, soul_level)

    local equip_condition = GUI.GetChild(itemTips, 'ItemType')
    GUI.StaticSetText(equip_condition, '装备条件：' .. '侍从等级' .. 1)
    GUI.SetColor(equip_condition, UIDefine.WhiteColor)

    local equip_position = GUI.GetChild(itemTips, 'ItemLevel')
    GUI.StaticSetText(equip_position, '装备位置：')
    GUI.SetColor(equip_position, UIDefine.WhiteColor)

    if equip_position_data then
        local x = -166
        for k, v in ipairs(equip_position_data) do
            local position_img = UIDefine.mandarin_num[v]
            if position_img then
                local img = GUI.ImageCreate(itemTips, 'equip_position' .. k, position_img, x, 68, false, 33, 34)
                UILayout.SetSameAnchorAndPivot(img, UILayout.TopRight)
                x = x + 30
            end
        end
    end

    local itemLimit = GUI.GetChild(itemTips, 'itemLimit')
    GUI.Destroy(itemLimit)

    local label_x = 20
    local attr_x = label_x + 20
    local width = GUI.GetWidth(itemTips)

    -- 如果不是是特殊型命魂
    if itemDB.Subtype ~= 5 then

        GUI.TipsAddLabel(itemTips, label_x, "基础属性：", label_color, false)

        local CutLine = GUI.GetChild(itemTips, "CutLine")
        GUI.SetPositionY(CutLine, 120)

        local InfoScr = GUI.GetChild(itemTips, "InfoScr")
        GUI.SetPositionY(InfoScr, 130)

        local attrDatas = item:GetDynAttrDataByMark(0)
        if attrDatas.Count > 0 then
            local attrData = attrDatas[0]
            local attrId = attrData.attr
            local value = tostring(attrData.value)
            local attrDB = DB.GetOnceAttrByKey1(attrId)
            if attrDB.IsPct == 1 then
                value = tostring(tonumber(value) / 100) .. "%"
            end
            GUI.TipsAddLabel(itemTips, attr_x, attrDB.ChinaName .. '  ' .. value, attr_color, false)
        end

        GUI.TipsAddCutLine(itemTips)

        -- 命魂tips 不同范围的属性显示不同的颜色
        local scopeColor = nil
        if GuardSoulUI and GuardSoulUI.isShowTipsScopeColor and GuardSoulUI.scopeColor then
            -- 确保转换颜色值的函数存在
            if GlobalUtils and GlobalUtils.getRGBDecimal then
                scopeColor = GuardSoulUI.scopeColor
            end
        end

        if GuardSoulUI.minghun_refining_attr_openlevel then
            -- 记录激活了多少条属性
            local count = 0
            local all_count = #GuardSoulUI.minghun_refining_attr_openlevel
            for k, v in ipairs(GuardSoulUI.minghun_refining_attr_openlevel) do
                if soul_level >= v then
                    count = count + 1
                end
            end
            GUI.TipsAddLabel(itemTips, label_x, '附加属性（' .. count .. '/' .. all_count .. '）', label_color, false)

            if GuardSoulUI.minghun_refining_attr_mark then
                local accumulation = 1
                -- 显示已激活的属性
                local attrDatas = item:GetDynAttrDataByMark(GuardSoulUI.minghun_refining_attr_mark or 52)
                if attrDatas.Count > 0 then
                    for k = 0, attrDatas.Count - 1 do
                        accumulation = accumulation + 1
                        local attrData = attrDatas[k]
                        local attrId = attrData.attr
                        local value = tostring(attrData.value)
                        local attrDB = DB.GetOnceAttrByKey1(attrId)

                        -- 判断显示什么颜色
                        local showColor = nil
                        if scopeColor then
                            local d = scopeColor[attrDB.KeyName]
                            if d then
                                for k, v in ipairs(d) do
                                    if tonumber(value) <= v.scope then
                                        if v.color then
                                            if type(v.color) == "string" then
                                                local r, g, b = GlobalUtils.getRGBDecimal(v.color)
                                                if r and g and b then
                                                    showColor = Color.New(r / 255, g / 255, b / 255, 1)
                                                end
                                            elseif type(v.color) == "table" then
                                                showColor = v.color
                                            end
                                        end
                                        break
                                    end
                                end
                            end
                        end

                        if attrDB.IsPct == 1 then
                            value = tostring(tonumber(value) / 100) .. "%"
                        end
                        if showColor then
                            GUI.TipsAddLabel(itemTips, attr_x, attrDB.ChinaName .. '+' .. value, showColor, false)
                        else
                            GUI.TipsAddLabel(itemTips, attr_x, attrDB.ChinaName .. '+' .. value, attr_color, false)
                        end
                    end
                end
                -- 显示等级不足
                for i = accumulation, all_count do
                    local d = GuardSoulUI.minghun_refining_attr_openlevel
                    GUI.TipsAddLabel(itemTips, attr_x, '强化到Lv.' .. d[i] .. '解锁', blue_color, false)
                end
            else
                test('GuardSoulUI.minghun_refining_attr_mark == nil')
            end

            GUI.TipsAddCutLine(itemTips)
        else
            test('GuardSoulUI.minghun_refining_attr_openlevel == nil')
        end

    end

    local activated_color = Color.New(7 / 255, 186 / 255, 0, 1)
    if suit_attr_data then

        local equipped_num = guard_equipped_count
        local name = '套装效果'
        name = name .. '<color=#f06701>[' .. suit_attr_data.Suit_Name .. ']' .. '（' .. equipped_num .. '/' .. suit_attr_data.Total .. '）</color>'
        GUI.TipsAddLabel(itemTips, label_x, name, label_color, true)


        -- 属性遍历显示顺序不对  需要修改数据格式
        local d = {}
        for k, v in pairs(suit_attr_data.Size) do
            v.activated_num = k
            table.insert(d, v)
        end

        -- 对其排序
        for k, v in ipairs(d) do
            for i, j in ipairs(d) do
                if v.activated_num < j.activated_num then
                    local temp = d[k]
                    d[k] = d[i]
                    d[i] = temp
                end
            end
        end

        for k, v in ipairs(d) do
            k = v.activated_num
            if equipped_num >= k then
                for an, av in pairs(v.Attr) do
                    local attrDB = DB.GetOnceAttrByKey2(av[1])
                    if attrDB.ChinaName then
                        av[1] = attrDB.ChinaName
                    end
                    local name = '（' .. k .. '）' .. av[1] .. '+' .. av[2] .. '（已激活）'
                    GUI.TipsAddLabel(itemTips, attr_x, name, activated_color, false)
                end
            else
                for an, av in pairs(v.Attr) do
                    local attrDB = DB.GetOnceAttrByKey2(av[1])
                    if attrDB.ChinaName then
                        av[1] = attrDB.ChinaName
                    end
                    local name = '（' .. k .. '）' .. av[1] .. '+' .. av[2] .. '（未激活）'
                    GUI.TipsAddLabel(itemTips, attr_x, name, attr_color, false)
                end
            end

            -- 技能显示
            if v.Skill ~= nil then
                local skillId = v.Skill[1].id
                local skillDB = DB.GetOnceSkillByKey1(skillId)
                if skillDB.Info then
                    local info = '（' .. k .. '）' .. '特效：' .. '【' .. skillDB.Name .. '】' .. ' ' .. skillDB.Info
                    if equipped_num >= k then
                        info = info .. '（已激活）'
                        GUI.TipsAddLabel(itemTips, attr_x, info, activated_color, false)
                    else
                        info = info .. '（未激活）'
                        GUI.TipsAddLabel(itemTips, attr_x, info, attr_color, false)
                    end
                end
            end
        end

        GUI.TipsAddCutLine(itemTips)
    end

    -- 添加道具描述
    GUI.TipsAddLabel(itemTips, label_x, '技能效果：' .. itemDB.Tips, UIDefine.Brown2Color, false)

    if itemDB.Subtype == 5 then
        local cutline = GUI.GetChild(itemTips, 'CutLine')
        GUI.SetPositionY(cutline, 118)
        local InfoScr = GUI.GetChild(itemTips, 'InfoScr')
        GUI.SetPositionY(InfoScr, 127)
    end

    -- btn
    -- 经验命魂不显示按钮
    if itemDB and itemDB.KeyName == "经验命魂" then
        isShowButton = false
    end
    Tips.guardSoulEquipBtnData = nil
    if isShowButton ~= false then
        local btn_group = GUI.GroupCreate(itemTips, 'btn_group', 0, -6, width, 60)
        UILayout.SetSameAnchorAndPivot(btn_group, UILayout.Bottom)

        local more_Btn = GUI.ButtonCreate(btn_group, "more_btn", "1800402040", -100, 0, Transition.ColorTint, "", 140, 47, false)
        GUI.RegisterUIEvent(more_Btn, UCE.PointerClick, 'Tips', 'guardSoulTipsClickEvent')
        --GUI.ButtonSetTextColor(more_Btn,UIDefine.BrownColor)
        --GUI.ButtonSetTextFontSize(more_Btn,UIDefine.FontSizeM)
        -- add to tips white list
        GUI.AddWhiteName(itemTips, GUI.GetGuid(more_Btn))

        local more_btn_txt = GUI.CreateStatic(more_Btn, "more_btn_txt", "更多", -8, 0, GUI.GetWidth(more_Btn), GUI.GetHeight(more_Btn), "system")
        UILayout.SetSameAnchorAndPivot(more_btn_txt, UILayout.Center)
        GUI.StaticSetAlignment(more_btn_txt, TextAnchor.MiddleCenter)
        GUI.SetColor(more_btn_txt, UIDefine.BrownColor)
        GUI.StaticSetFontSize(more_btn_txt, UIDefine.FontSizeM)

        local pullListBtn = GUI.ImageCreate(more_Btn, "pullListBtn", "1800707070", -15, 0)
        UILayout.SetSameAnchorAndPivot(pullListBtn, UILayout.Right)
        GUI.SetIsRaycastTarget(pullListBtn, false)

        local equip_or_demount_btn = GUI.ButtonCreate(btn_group, 'equip_or_demount_btn', '1800402040', 100, 0, Transition.None, '卸下', 140, 47, false)
        GUI.ButtonSetTextColor(equip_or_demount_btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(equip_or_demount_btn, UIDefine.FontSizeM)

        Tips.guardSoulEquipBtnData = {
            item_guid = guid,
            guard_id = guard_id,
            position = _equipped_position,
        }

        if is_equipped then
            GUI.ButtonSetText(equip_or_demount_btn, '卸下')
            GUI.RegisterUIEvent(equip_or_demount_btn, UCE.PointerClick, 'Tips', 'guardSoulDemountBtnClick')
        else
            GUI.ButtonSetText(equip_or_demount_btn, '装备')
            GUI.RegisterUIEvent(equip_or_demount_btn, UCE.PointerClick, 'Tips', 'guardSoulEquipBtnClick')
        end

        local delete_guard_soul_btn = GUI.ButtonCreate(btn_group, 'delete_guard_soul_btn', '1800402040', -100, 0, Transition.None, '销毁', 140, 47, false)
        GUI.ButtonSetTextColor(delete_guard_soul_btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(delete_guard_soul_btn, UIDefine.FontSizeM)
        GUI.RegisterUIEvent(delete_guard_soul_btn, UCE.PointerClick, 'Tips', 'delete_guard_soul_item_event')
        GUI.SetVisible(delete_guard_soul_btn, false)

        -- 特殊命魂只需要装备卸下按钮 以及删除按钮
        if itemDB and itemDB.Type == 8 and itemDB.Subtype == 5 then
            GUI.SetVisible(more_Btn, false)
            if GuardSoulUI.minghun_can_delete ~= 1 then
                -- 将按钮居中
                UILayout.SetSameAnchorAndPivot(equip_or_demount_btn, UILayout.Bottom)
                GUI.SetPositionX(equip_or_demount_btn, 0)
            else
                GUI.SetVisible(delete_guard_soul_btn, true)
            end
        end
    else
        if GuardSoulUI.minghun_can_delete ~= 1 then
            GUI.SetHeight(itemTips, GUI.GetHeight(itemTips) - 45)
        else
            Tips.guardSoulEquipBtnData = { item_guid = guid, }
            local btn_group = GUI.GroupCreate(itemTips, 'btn_group', 0, -6, width, 60)
            UILayout.SetSameAnchorAndPivot(btn_group, UILayout.Bottom)

            local delete_guard_soul_btn = GUI.ButtonCreate(btn_group, 'delete_guard_soul_btn', '1800402040', 0, 0, Transition.None, '销毁', 140, 47, false)
            GUI.ButtonSetTextColor(delete_guard_soul_btn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(delete_guard_soul_btn, UIDefine.FontSizeM)
            UILayout.SetSameAnchorAndPivot(delete_guard_soul_btn, UILayout.Bottom)
            GUI.RegisterUIEvent(delete_guard_soul_btn, UCE.PointerClick, 'Tips', 'delete_guard_soul_item_event')
        end
    end
    return itemTips
end

function Tips.guardSoulTipsClickEvent(guid)

    local btn = GUI.GetByGuid(guid)
    local parent = GUI.GetParentElement(btn)
    local bg = GUI.GetChild(parent, 'more_btn_option_bg')
    if bg == nil then
        --创建侍从类型按钮选择列表
        bg = GUI.ImageCreate(parent, "more_btn_option_bg", "1800400290", -100, 86, false, GUI.GetWidth(btn), 100) -- y -56
        UILayout.SetSameAnchorAndPivot(bg, UILayout.Top)
        GUI.SetVisible(bg, true)
        -- 检测到点击就销毁
        GUI.SetIsRemoveWhenClick(bg, true)

        local childSize_GuardType = Vector2.New(GUI.GetWidth(bg) - 10, GUI.GetHeight(btn))
        local scr_option = GUI.ScrollRectCreate(
                bg,
                "scr_option",
                0,
                0,
                GUI.GetWidth(bg),
                90,
                0,
                false,
                childSize_GuardType,
                UIAroundPivot.Top,
                UIAnchor.Top
        )
        UILayout.SetSameAnchorAndPivot(scr_option, UILayout.Center)

        local btn = GUI.ButtonCreate(scr_option, 'guardSoulTipsReinforceBtn', "1800402040", 0, 0, Transition.ColorTint, '强化', 104, 32, false)
        GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeS)
        -- get function by btn name
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "Tips", "guardSoulReinforceClick")

        local btn = GUI.ButtonCreate(scr_option, 'guardSoulTipsBaptizeBtn', "1800402040", 0, 0, Transition.ColorTint, '炼化', 104, 32, false)
        GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeS)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "Tips", "guardSoulBaptizeClick")

        -- 销毁命魂按钮
        if GuardSoulUI.minghun_can_delete == 1 then
            GUI.SetHeight(bg, 146)
            GUI.SetPositionY(bg, -133)
            GUI.SetHeight(scr_option, 136)

            local delete_guard_soul_btn = GUI.ButtonCreate(scr_option, 'delete_guard_soul_btn', "1800402040", 0, 0, Transition.ColorTint, '销毁', 104, 32, false)
            GUI.ButtonSetTextColor(delete_guard_soul_btn, UIDefine.BrownColor)
            GUI.ButtonSetTextFontSize(delete_guard_soul_btn, UIDefine.FontSizeS)
            GUI.RegisterUIEvent(delete_guard_soul_btn, UCE.PointerClick, "Tips", "delete_guard_soul_item_event")
        end

    end
end


-- #装备命魂事件
function Tips.guardSoulEquipBtnClick(guid)
    if Tips.guardSoulEquipBtnData == nil or next(Tips.guardSoulEquipBtnData) == nil then
        test('Tips.guardSoulEquipBtnClick(guid) Tips.guardSoulEquipBtnData 数据为空')
        CL.SendNotify(NOTIFY.ShowBBMsg, '系统错误')
        return ''
    end

    local item_guid = Tips.guardSoulEquipBtnData.item_guid
    local guard_id = Tips.guardSoulEquipBtnData.guard_id
    if item_guid == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, '请先选中命魂')
        return ''
    end
    if guard_id == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, '请先选中侍从')
        return ''
    else
        if LD.IsHaveGuard(guard_id) ~= true then
            CL.SendNotify(NOTIFY.ShowBBMsg, '请先激活侍从')
            return ''
        end
    end
    GuardSoulUI.create_select_position_of_equip_soul(item_guid, guard_id)
end

-- #卸下命魂事件
function Tips.guardSoulDemountBtnClick(guid)
    if Tips.guardSoulEquipBtnData == nil or next(Tips.guardSoulEquipBtnData) == nil then
        test('Tips.guardSoulEquipBtnClick(guid) Tips.guardSoulEquipBtnData 数据为空')
        CL.SendNotify(NOTIFY.ShowBBMsg, '系统错误')
        return ''
    end

    local item_guid = Tips.guardSoulEquipBtnData.item_guid
    local guard_id = Tips.guardSoulEquipBtnData.guard_id
    local index = Tips.guardSoulEquipBtnData.position

    if item_guid == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, '请先选中命魂')
        return ''
    end

    if guard_id == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, '请先选中侍从')
        return ''
    else
        if LD.IsHaveGuard(guard_id) ~= true then
            CL.SendNotify(NOTIFY.ShowBBMsg, '请先激活侍从')
            return ''
        end
    end

    if index == nil then
        test('Tips.guardSoulDemountBtnClick(guid) 位置为空')
        CL.SendNotify(NOTIFY.ShowBBMsg, '请先选择卸下命魂')
        return ''
    end

    GuardSoulUI.DemountMingHun_request(guard_id, index, item_guid)
end

function Tips.guardSoulReinforceClick(guid)
    local wnd = GUI.GetWnd('GuardSoulUI')
    -- 将tips显示的物品数据传回侍从命魂界面，让其显示跳转后选中这个命魂物品
    if GuardSoulUI then
        if Tips.guardSoulEquipBtnData then
            GuardSoulUI.clickTipsSelectASoulItem = Tips.guardSoulEquipBtnData
        end
    end
    if GUI.GetVisible(wnd) then
        GuardSoulUI.on_reinforced_tab_btn_click('reinforced')
    else
        GUI.OpenWnd('GuardSoulUI', 'index:2,index2:1')
    end
end

function Tips.guardSoulBaptizeClick(guid)
    local wnd = GUI.GetWnd('GuardSoulUI')
    -- 将tips显示的物品数据传回侍从命魂界面，让其显示跳转后选中这个命魂物品
    if GuardSoulUI then
        if Tips.guardSoulEquipBtnData then
            GuardSoulUI.clickTipsSelectASoulItem = Tips.guardSoulEquipBtnData
        end
    end
    if GUI.GetVisible(wnd) then
        GuardSoulUI.on_reinforced_tab_btn_click('baptize')
    else
        GUI.OpenWnd('GuardSoulUI', 'index:2,index2:2')
    end
end

-- 销毁命魂物品事件
function Tips.delete_guard_soul_item_event(guid)
    if Tips.guardSoulEquipBtnData == nil or next(Tips.guardSoulEquipBtnData) == nil then
        test('Tips.guardSoulEquipBtnClick(guid) Tips.guardSoulEquipBtnData 数据为空')
        CL.SendNotify(NOTIFY.ShowBBMsg, '系统错误，无法获取此命魂数据')
        return ''
    end
    local item_guid = Tips.guardSoulEquipBtnData.item_guid
    if item_guid == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, '请先选中命魂')
        return ''
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "MingHunDelete", tostring(item_guid))
end


--背包特殊配置物品tips
function Tips.CreateSpecilaItemTips(itemData, parent, name, x, y, extHeight, guardGuid, customData, suitInfos)
    local itemTips
    local itemDB = DB.GetOnceItemByKey1(itemData.id)
    if not ItemTipsInfo or not ItemTipsInfo.InfoConfig[itemDB.KeyName] then
        local child = GUI.GetChild(parent, name, false) 
        if child then
            return
        else
            itemTips = Tips.CreateByItemData(itemData, parent, name, x, y, extHeight, guardGuid, customData, suitInfos)
            return itemTips
        end

    end

    if itemData == nil then
        return nil
    end

    if guardGuid == nil then
        guardGuid = 0;
    end

    local itemDB = DB.GetOnceItemByKey1(itemData.id)
    if itemDB.Id == 0 then
        return nil
    end

    if extHeight == nil then
        extHeight = 0
    end

    local itemTips = GUI.ItemTipsCreate(parent, name, x, y, extHeight)
    GUI.SetIsRemoveWhenClick(itemTips, true)
    local itemShowLevel = GUI.GetChild(itemTips, "itemShowLevel")
    local itemIcon = GUI.TipsGetItemIcon(itemTips)
    ItemIcon.BindItemData(itemIcon, itemData, true)

    Tips.SetBaseInfo(itemTips, itemDB, itemData, guardGuid, customData)

    GUI.TipsAddLabel(itemTips, 20, "效用：", UIDefine.Yellow3Color, false)

    local itemDB = DB.GetOnceItemByKey1(itemData.id)
    local ItemInfoConfig = ItemTipsInfo.InfoConfig[itemDB.KeyName]
    for k,v in ipairs(ItemInfoConfig) do
        if v.type == "info" then
            GUI.TipsAddLabel(itemTips, 20, v.msg, v.color, false)
        elseif v.type == "line" then
            GUI.TipsAddCutLine(itemTips)
        end
    end
    Tips.DeleteItemShowLevel(itemTips) -- 删除等级属性
    return itemTips
end