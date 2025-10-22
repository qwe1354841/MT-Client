require "EquipLogic"
local LogicDefine = {}
_G.LogicDefine = LogicDefine
LogicDefine.BagMaxLimit = 300 --背包最大格子数
LogicDefine.PetMaxLimit = 20 --宠物最大携带数
LogicDefine.WarehousePageMax = 10 --仓库最大页数
LogicDefine.MaxMailCount = 200 --最大邮件数
LogicDefine.MailValidTickCount = 30 * 24 * 60 * 60 --邮件有效时间


LogicDefine.RebuidingAttrNum = "ITEM_RebuidingAttrNum" -- 装备当前有几个没有应用的重铸属性
LogicDefine.RebuidingAttrId = "ITEM_RebuidingAttrId_" --重铸的第几条属性的属性ID..X
LogicDefine.RebuidingAttrVaPlus = "ITEM_RebuidingAttrVaPlus_" --重铸的第几条属性的属性值..X
--重铸界面右边
LogicDefine.ITEM_RebuidingSPAttrNum = "ITEM_RebuidingSPAttrNum" -- 有几个这样的值
LogicDefine.ITEM_RebuidingSPAttrNa = "ITEM_RebuidingSPAttrNa_" --值名字..X
LogicDefine.ITEM_RebuidingSPAttrVa = "ITEM_RebuidingSPAttrVa_" --值数值..X
--装备tips及重铸界面左边
LogicDefine.ITEM_SPAttrNum = "ITEM_SPAttrNum" -- 有几个这样的值
LogicDefine.ITEM_SPAttrNa = "ITEM_SPAttrNa_" --值名字..X
LogicDefine.ITEM_SPAttrVa = "ITEM_SPAttrVa_" --值数值..X
LogicDefine.ITEM_SPAttrSh = "ITEM_SPAttrSh_" --是否显示


--start 宝石--
LogicDefine.ITEM_GemNum="ITEM_GemNum" --装备宝石孔数
LogicDefine.ITEM_GemId_="ITEM_GemId_" --装备镶嵌的宝石ID
LogicDefine.ITEM_GemValue_="ITEM_GemValue_" --装备镶嵌的宝石价值

LogicDefine.ITEM_GemAttrMark={
    [1]=30,
    [2]=31,
    [3]=32,
    [4]=33,
    [5]=34,
}

LogicDefine.GemAttrMark=39;
LogicDefine.GemValue="GemValue";
function LogicDefine.GetEquipGemCount(itemData)

    local siteCount=itemData:GetIntCustomAttr(LogicDefine.ITEM_GemNum);
    local gemCount=0;
    for i = 1, siteCount do
        local gemId=itemData:GetIntCustomAttr(LogicDefine.ITEM_GemId_..i);
        if gemId~=0 then
            gemCount=gemCount+1;
        end
    end

    return gemCount,siteCount;
end

--end 宝石--


LogicDefine.CustomKey = {
    PET_ArtificeTimes = "PET_ArtificeTimes",   --宠物炼妖次数
    PET_ActSkillFields = "PET_ActSkillFields", --宠物技能解锁栏位
    PET_SkillLearned_ = "PET_SkillLearned_", --宠物学习技能Id, 例如：PET_SkillLearned_1
    PET_SkillLearnMax = "PET_SkillLearnMax", --宠物技能栏位总数
    PET_NeidanUnlock = "PET_NeidanUnlock", --宠物内丹解锁栏位
    PET_NeidanMax = "PET_NeidanMax", --宠物内丹栏位总数
    PET_NeidanSkillID_ = "PET_NeidanSkillID_", --宠物内丹技能Id, 例如：PET_NeidanSkillID_1
    PET_NeidanSkillRE_ = "PET_NeidanSkillRE_", --宠物内丹技能转生等级, 例如：PET_NeidanSkillRE_1
    EQUIP_IntensifyLevel = "EQUIP_IntensifyLevel", --武器强化等级
    ITEM_NeidanSkillID = "ITEM_NeidanSkillID", --道具中包含的内丹技能
    ITEM_NeidanSkillLV = "ITEM_NeidanSkillLV", --道具中包含的内丹技能等级
    ITEM_NeidanSkillRE = "ITEM_NeidanSkillRE", --道具中包含的内丹技能转生等级
    ITEM_PetSkill = "ITEM_PetSkill", --道具中包含的提炼技能
}
LogicDefine.ItemType = {
    eqiup = 1
}
LogicDefine.ItemSubType = {
    weapon = 1,
    armor = 2,
    ornaments = 3,
    amulet = 4,
    petEqiup = 7
}
LogicDefine.ArmorSubType2 = {
    hat = 1,
    armor = 2,
    belt = 3,
    hangings = 5
}
LogicDefine.OrnamentsSubType2 = {
    ring = 1,
    necklace = 2,
    wrist = 3,
    shoes = 4
}
LogicDefine.EquipSite = {
    site_weapon = 0, --武器
    site_hat = 1, --帽子
    site_armor = 2, --衣服
    site_belt = 3, --腰带
    site_shoes = 4, --鞋子
    site_wrist = 5, --护腕
    site_ring = 6, --戒指
    site_necklace = 7, --项链
    site_hangings = 8, --挂坠
    site_amulet = 9, --法宝
    site_mount = 10 --坐骑
}

LogicDefine.PetEquipSite = {
    site_collar = 0, --宠物项圈
    site_armor = 1, --宠物盔甲
    site_amulet = 2, --宠物护符
    site_accessory = 3 --宠物装饰
}

LogicDefine.ArmorEquipSite = {
    [LogicDefine.ArmorSubType2.hat] = LogicDefine.EquipSite.site_hat,
    [LogicDefine.ArmorSubType2.armor] = LogicDefine.EquipSite.site_armor,
    [LogicDefine.ArmorSubType2.belt] = LogicDefine.EquipSite.site_belt,
    [LogicDefine.ArmorSubType2.hangings] = LogicDefine.EquipSite.site_hangings
}
LogicDefine.OrnamentsEquipSite = {
    [LogicDefine.OrnamentsSubType2.ring] = LogicDefine.EquipSite.site_ring,
    [LogicDefine.OrnamentsSubType2.necklace] = LogicDefine.EquipSite.site_necklace,
    [LogicDefine.OrnamentsSubType2.wrist] = LogicDefine.EquipSite.site_wrist,
    [LogicDefine.OrnamentsSubType2.shoes] = LogicDefine.EquipSite.site_shoes
}
function LogicDefine.GetEquipSite(type, subtype, subtype2)
    if type == LogicDefine.ItemType.eqiup then
        if subtype == LogicDefine.ItemSubType.weapon then
            return LogicDefine.EquipSite.site_weapon
        elseif subtype == LogicDefine.ItemSubType.armor then
            local tmp = LogicDefine.ArmorEquipSite[subtype2]
            if tmp then
                return tmp
            end
        elseif subtype == LogicDefine.ItemSubType.ornaments then
            local tmp = LogicDefine.OrnamentsEquipSite[subtype2]
            if tmp then
                return tmp
            end
        elseif subtype == LogicDefine.ItemSubType.amulet then
            return LogicDefine.EquipSite.site_amulet
        end
    end
    return -1
end

LogicDefine.item_type = {
    item_type_null = item_type.item_type_null:GetHashCode(),
    item_type_equip = item_type.item_type_equip:GetHashCode(),
    item_type_consumable = item_type.item_type_consumable:GetHashCode(),
    item_type_material = item_type.item_type_material:GetHashCode(),
    item_type_treasure_map = item_type.item_type_treasure_map:GetHashCode(),
    item_type_quest = item_type.item_type_quest:GetHashCode(),
    item_type_guard_token = item_type.item_type_guard_token:GetHashCode(),
    item_type_pet = item_type.item_type_pet:GetHashCode(),
    item_type_guard = item_type.item_type_guard:GetHashCode(),
    item_type_max = item_type.item_type_max:GetHashCode()
}
---@param site LogicDefine.EquipSite
function LogicDefine.GetEquipBySite(site)
    local eqiup = LD.GetItemDataByIndex(site, item_container_type.item_container_equip)
    if eqiup and eqiup.guid > uint64.zero then
        return eqiup
    else
        return nil
    end
end
-- 装备强化等级自定义变量
local EnhanceLv = "EQUIP_IntensifyLevel"
local EnhanceLuck = "EQUIP_LuckAddition"
LogicDefine.EnhanceLv = EnhanceLv
LogicDefine.EnhanceLuck = EnhanceLuck
LogicDefine.ItemAttrMark = {
    -- 基本属性
    Base = 0,
    -- 强化属性
    Enhance = 10,
    -- 炼化属性
    Artifice = 51,
    -- 炼器属性
    Refiner= 40,
}
---@return eqiupItem
function LogicDefine.NewequipItem()
    ---@type eqiupItem
    local tmp = {}
    tmp.bagtype = item_container_type.item_container_null
    tmp.guid = int64.zero
    tmp.name = ""
    tmp.lv = 0
    tmp.showType = ""
    tmp.site = 0
    tmp.id = 0
    tmp.subtype = 0
    tmp.grade = 0
    tmp.keyname = ""
    tmp.count = 0
    tmp.itemLv = 0
    tmp.subtype2 = 0
    tmp.armorLevel = 0
    tmp.enhanceLv = 0
    tmp.enhanceLuck= 0
    tmp.isbind = 0
    tmp.turnBorn = 0
    tmp.GetUseLv = function(self)
        local lvTxt = ""
        if self.turnBorn > 0 then
            lvTxt = tostring(self.turnBorn) .. "转" .. tostring(self.lv) .. "级"
        else
            lvTxt = tostring(self.lv) .. "级"
        end
        return lvTxt
    end
    return tmp
end
function LogicDefine.GetEqiupInBag(t, type)
    if t == nil then
        t = {}
    end
    local ownerGuid = LD.GetSelfGUID()
    local size = LD.GetBagCapacity(type)
    for i = 0, size - 1 do
        local id = tonumber(LD.GetItemAttrByIndex(ItemAttr_Native.Id, i, type))
        if id ~= nil then
            local item = DB.GetOnceItemByKey1(tonumber(id))
            if item.Type == LogicDefine.item_type.item_type_equip and item.Subtype<=4  then
                local guid =uint64.new(LD.GetItemAttrByIndex(ItemAttr_Native.Guid, i, type))

                ---@type eqiupItem
                local tmp = LogicDefine.NewequipItem()
                tmp.ownerGuid = ownerGuid
                tmp.bagtype = type
                tmp.guid = guid
                tmp.id = id
                tmp.name = item.Name
                tmp.lv = item.Level
                tmp.turnBorn = item.TurnBorn
                tmp.itemLv = item.Itemlevel
                tmp.showType = item.ShowType
                tmp.grade= item.Grade
                tmp.subtype = item.Subtype
                tmp.keyname = item.KeyName
                tmp.subtype2 = item.Subtype2
                if tmp.subtype == LogicDefine.ItemSubType.weapon or tmp.subtype == LogicDefine.ItemSubType.armor then
                    tmp.armorLevel = item.ArmorLevel
                else
                    tmp.armorLevel = LogicDefine.ArmorLevel.Start
                end
                tmp.site = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Site, guid, type))
                tmp.enhanceLv = LD.GetItemIntCustomAttrByGuid(EnhanceLv, tmp.guid, type)
                tmp.enhanceLuck = LD.GetItemIntCustomAttrByGuid(EnhanceLuck, tmp.guid, type)
                t[#t + 1] = tmp
            end
        end
    end
    return t
end

function LogicDefine.GetGuardEquipInBag(t, ownerGuid)
    if t == nil then
        t = {}
    end
    local size = LogicDefine.EquipSite.site_amulet
    local type = item_container_type.item_container_guard_equip
    for i = 0, size do
        local equipData = LD.GetItemDataByIndex(i, type, ownerGuid)
        if equipData then
            local id = equipData.id
            local item = DB.GetOnceItemByKey1(tonumber(id))
            local guid = equipData.guid

            ---@type eqiupItem
            local tmp = LogicDefine.NewequipItem()
            tmp.ownerGuid = ownerGuid
            tmp.bagtype = type
            tmp.guid = guid
            tmp.id = id
            tmp.name = item.Name
            tmp.lv = item.Level
            tmp.turnBorn = item.TurnBorn
            tmp.itemLv = item.Itemlevel
            tmp.grade = item.Grade
            tmp.showType = item.ShowType
            tmp.subtype = item.Subtype
            tmp.keyname = item.KeyName
            tmp.subtype2 = item.Subtype2
            if tmp.subtype == LogicDefine.ItemSubType.weapon or tmp.subtype == LogicDefine.ItemSubType.armor then
                tmp.armorLevel = item.ArmorLevel
            else
                tmp.armorLevel = LogicDefine.ArmorLevel.Start
            end
            tmp.site = equipData.site
            tmp.enhanceLv = equipData:GetIntCustomAttr(EnhanceLv)--LD.GetItemIntCustomAttrByGuid(EnhanceLv, tmp.guid, type)
            tmp.enhanceLuck = equipData:GetIntCustomAttr(EnhanceLuck)
            t[#t + 1] = tmp
        end
    end
    return t
end

LogicDefine.AttrType = {
    [1] = "宠物资质",
    [2] = "物理属性",
    [3] = "法术属性",
    [4] = "法术抗性",
    [5] = "五行属性",
    [6] = "其他"
}

function LogicDefine.GetAttrTypeTable()
    if LogicDefine.attrTypeTable == nil then
        LogicDefine.attrTypeTable = {}

        local ids = DB.GetAttrAllKey1s()
        for i = 0, ids.Count - 1 do
            local attrDB = DB.GetOnceAttrByKey1(ids[i])
            if attrDB.Type ~= 0 then
                if LogicDefine.attrTypeTable[attrDB.Type] == nil then
                    LogicDefine.attrTypeTable[attrDB.Type] = {}
                end
                table.insert(
                    LogicDefine.attrTypeTable[attrDB.Type],
                    {Name = attrDB.Name, ChinaName = attrDB.ChinaName, IsPct = attrDB.IsPct}
                )
            end
        end
    end

    return LogicDefine.attrTypeTable
end

LogicDefine.PetFixAttr = {
    [1] = {Name = "PetAttrGrowthrate", ChinaName = "成长率", Max = "GrowthRateMax", Value = "0", MaxValue = "0"},
    [2] = {Name = "PetAttrHpTalent", ChinaName = "血量资质", Max = "MaxHp", Value = "0", MaxValue = "0"},
    [3] = {Name = "PetAttrMpTalent", ChinaName = "法力资质", Max = "MaxMp", Value = "0", MaxValue = "0"},
    [4] = {Name = "PetAttrPhyAtkTalent", ChinaName = "物攻资质", Max = "MaxAp", Value = "0", MaxValue = "0"},
    [5] = {Name = "PetAttrSpeedTalent", ChinaName = "速度资质", Max = "MaxSp", Value = "0", MaxValue = "0"}
}

function LogicDefine.GetPetAttrTable(petData)
    local attrTypeTable = LogicDefine.GetAttrTypeTable()
    local temp = {}
    for k, v in pairs(attrTypeTable) do
        for j = 1, #v do
            local attrName = v[j].Name
            local attrChinaName = v[j].ChinaName
            local isPct = v[j].IsPct
            if RoleAttr[attrName] ~= nil then
                local value = tostring(petData:GetAllAttr(RoleAttr[attrName]))
                if tonumber(value) ~= 0 then
                    if temp[k] == nil then
                        temp[k] = {}
                    end
                    table.insert(temp[k], {Name = attrName, ChinaName = attrChinaName, Value = value, IsPct = isPct})
                end
            else
                print(attrName .. " is Error!!!")
            end
        end
    end

    local petAttrTable = {}
    local petId = tonumber(tostring(petData:GetAttr(RoleAttr.RoleAttrRole)))
    local petDB = DB.GetOncePetByKey1(petId)
    table.insert(petAttrTable, {TypeName = LogicDefine.AttrType[1]})
    for i = 1, #LogicDefine.PetFixAttr do
        LogicDefine.PetFixAttr[i].MaxValue = tostring(petDB[LogicDefine.PetFixAttr[i].Max])
        LogicDefine.PetFixAttr[i].Value = "0"
        if temp[1] ~= nil then
            for j = #temp[1], 1, -1 do
                if temp[1][j].Name == LogicDefine.PetFixAttr[i].Name then
                    LogicDefine.PetFixAttr[i].Value = temp[1][j].Value
                    table.remove(temp[1], j)
                end
            end
        end

        if LogicDefine.PetFixAttr[i].ChinaName == "成长率" then
            LogicDefine.PetFixAttr[i].MaxValue = tostring(tonumber(LogicDefine.PetFixAttr[i].MaxValue) / 10000)
            LogicDefine.PetFixAttr[i].Value = tostring(tonumber(LogicDefine.PetFixAttr[i].Value) / 10000)
        end

        table.insert(petAttrTable, LogicDefine.PetFixAttr[i])
    end

    for i = 1, #LogicDefine.AttrType do
        if i > 0 and temp[i] ~= nil and #temp[i] > 0 then
            table.insert(petAttrTable, {TypeName = LogicDefine.AttrType[i]})
        end

        if temp[i] ~= nil then
            for j = 1, #temp[i] do
                table.insert(petAttrTable, temp[i][j])
            end
        end
    end
    return petAttrTable
end

local PetOnlyAttrType = 1 -- 宠物专有属性类型
function LogicDefine.GetSelfAttrTable()
    local attrTypeTable = LogicDefine.GetAttrTypeTable()
    local attrTable = {}
    local lastType = 0
    for k, v in pairs(attrTypeTable) do
        if k ~= PetOnlyAttrType then
            for j = 1, #v do
                local attrName = v[j].Name
                local attrChinaName = v[j].ChinaName
                local isPct = v[j].IsPct
                --print(tostring(RoleAttr[attrName]), attrName, attrChinaName)
                local roleAttr = RoleAttr[attrName]
                if roleAttr then
                    local value = tostring(CL.GetAttr(roleAttr))
                    if tonumber(value) ~= 0 then
                        if lastType ~= k then
                            table.insert(attrTable, {ChinaName = LogicDefine.AttrType[k]})
                            lastType = k
                        end
                        table.insert(
                            attrTable,
                            {Name = attrName, ChinaName = attrChinaName, Value = value, IsPct = isPct}
                        )
                    end
                else
                    test("没有这条属性：", attrChinaName, attrName)
                end
            end
        end
    end

    return attrTable
end

function LogicDefine.GetGuardAttrTable(attrs)
    local attrTypeTable = LogicDefine.GetAttrTypeTable()
    local attrTable = {}
    local lastType = 0
    for k, v in pairs(attrTypeTable) do
        if k ~= PetOnlyAttrType then
            for j = 1, #v do
                local attrName = v[j].Name
                local attrChinaName = v[j].ChinaName
                local isPct = v[j].IsPct
                local value = tostring(LogicDefine.GetAttrFromFreeList(attrs, RoleAttr[attrName]))
                if tonumber(value) ~= 0 then
                    if lastType ~= k then
                        table.insert(attrTable, {ChinaName = LogicDefine.AttrType[k]})
                        lastType = k
                    end
                    table.insert(attrTable, {Name = attrName, ChinaName = attrChinaName, Value = value, IsPct = isPct})
                end
            end
        end
    end

    return attrTable
end

function LogicDefine.GetPetSkill(petData)
    if petData == nil then
        return nil
    end

    local skillDatas = petData.skills
    local studySkillCount = tonumber(tostring(petData:GetIntCustomAttr(LogicDefine.CustomKey.PET_ActSkillFields)))

    local studySkills = {}
    for i = 1, studySkillCount do
        local studySkillId = tonumber(tostring(petData:GetIntCustomAttr(LogicDefine.CustomKey.PET_SkillLearned_ .. i)))

        if studySkillId ~= 0 then
            table.insert(studySkills, {SkillId = studySkillId, Type = 2, SkillData = nil, Index = i})
        else
            break
        end
    end

    local studyEmptyCount = studySkillCount - #studySkills

    local danSkills, danEmptyCount = LogicDefine.GetPetDanSkill(petData)

    local inbornSkills = {}
    local idx = 0
    for i = 0, skillDatas.Count - 1 do
        local skillData = skillDatas[i]
        local isInborn = true
        for j = 1, #studySkills do
            if studySkills[j].SkillId == skillData.id then
                studySkills[j].SkillData = skillData
                isInborn = false
                break
            end
        end

        for j = 1, #danSkills do
            if danSkills[j].SkillId == skillData.id then
                isInborn = false
                break
            end
        end

        if isInborn == true then
            idx = idx + 1
            table.insert(inbornSkills, {SkillId = skillData.id, Type = 1, SkillData = skillData, Index = idx ,performance = skillData.performance })
        end
    end

    local skillDatas = {}
    for i = 1, #inbornSkills do
		print("出生技能")
        table.insert(skillDatas, inbornSkills[i])
    end

    for i = 1, #danSkills do
        table.insert(skillDatas, danSkills[i])
    end

    for i = 1, #studySkills do
		print("学习技能")
        table.insert(skillDatas, studySkills[i])
    end
	
	local Datas = {}
	for i =1 , #skillDatas do
		local skillDB = DB.GetOnceSkillByKey1(skillDatas[i].SkillId)
		if skillDB.SubType ~= 14 and skillDB.SubType ~= "14" and skillDB.SubType ~= "15" and skillDB.SubType ~= 15 then
			table.insert(Datas,skillDatas[i])
		end
	end
	
    local allSkillCount = 0
    local studySkillMax = tonumber(tostring(petData:GetIntCustomAttr(LogicDefine.CustomKey.PET_SkillLearnMax)))
	allSkillCount = #Datas
    -- allSkillCount = #inbornSkills + studySkillMax + #danSkills

    return Datas, studyEmptyCount, allSkillCount, danSkills, danEmptyCount
end

function LogicDefine.GetPetDanSkill(petData)
    local danSkillCount = tonumber(tostring(petData:GetIntCustomAttr(LogicDefine.CustomKey.PET_NeidanUnlock)))
    local danSkills = {}
    for i = 1, danSkillCount do
        local danSkillId = tonumber(tostring(petData:GetIntCustomAttr(LogicDefine.CustomKey.PET_NeidanSkillID_ .. i)))
        if danSkillId ~= 0 then
            table.insert(danSkills, {SkillId = danSkillId, Type = 3, SkillData = nil, Index = i})
        else
            break
        end
    end

    local danEmptyCount = danSkillCount - #danSkills

    local skillDatas = petData.skills
    for i = 0, skillDatas.Count - 1 do
        local skillData = skillDatas[i]
        for j = 1, #danSkills do
            if danSkills[j].SkillId == skillData.id then
                danSkills[j].SkillData = skillData
                break
            end
        end
    end

    return danSkills, danEmptyCount
end

---@param itemList SealedBookReward
---@return eqiupItem[]
function LogicDefine.SeverReward2ClientItems(itemList, items)
    ---@type eqiupItem[]
    local tmp = items
    if tmp == nil then
        tmp = {}
    end
    if itemList then
        tmp = LogicDefine.SeverItems2ClientItems(itemList.ItemList, tmp)
        if itemList.Exp and itemList.Exp ~= 0 then
            table.insert(
                    tmp,
                    {
                        id = 61025,
                        count = itemList.Exp
                    }
            )
        end
        if itemList.MoneyVal and itemList.MoneyType and itemList.MoneyVal ~= 0 then
            table.insert(
                    tmp,
                    {
                        id = UIDefine.AttrItemId[UIDefine.GetMoneyEnum(itemList.MoneyType)],
                        count = itemList.MoneyVal
                    }
            )
        end
        return tmp
    end
    return tmp
end

---@return eqiupItem[]
function LogicDefine.SeverItems2ClientItems(itemList, items)
    if items == nil then
        items = {}
    end
    if itemList then
        for k, v in ipairs(itemList) do
            ---@type eqiupItem
            if type(v) == "string" then
                local item = LogicDefine.NewequipItem()
                items[#items + 1] = item
                item.keyname = v
                item.count = 1
                item.id = DB.GetOnceItemByKey2(item.keyname).Id
                if item ~= "" then
                    if itemList[k + 1] then
                        if type(itemList[k + 1]) == "number" then
                            item.count = itemList[k + 1]
                        end
                        if type(itemList[k + 2]) == "number" then
                            item.isbind = itemList[k + 2]
                        end
                    end
                end
            end
        end
        return items
    end
    return items
end
---@param dyn ItemDataEx
---@param mark1 number
---@param mark2 number
---@param t enhanceDynAttrData[]
function LogicDefine.GetItemDynAttrDataByMark(dyn, mark1, mark2, t)
    local dynAttrs = dyn:GetDynAttrDataByMark(mark1)
    if t == nil then
        return
    end
    local dynAttrs = dyn:GetDynAttrDataByMark(mark1)
    local dynExAttrs = dyn:GetDynAttrDataByMark(mark2)
    local attr2Index = {}
    local attsIndex = 1
    ---@return enhanceDynAttrData
    local GetDynAttrData = function(item)
        if item.attr > 0 then
            local dynAttr = LogicDefine.NewAttrTable()
            local attridStr = tostring(item.attr)
            dynAttr.mark = item.mark
            dynAttr.attr = item.attr
            dynAttr.value = item.value
            dynAttr.exV = int64.zero
            local attr_DB = DB.GetOnceAttrByKey1(dynAttr.attr)
            dynAttr.name = attr_DB.ChinaName
			dynAttr.keyname = attr_DB.KeyName
            dynAttr.IsPct = (attr_DB.IsPct == 1)
            return dynAttr
        end
        return nil
    end
    for i = 0, dynAttrs.Count - 1 do
        ---@type enhanceDynAttrData
        local dynAttr = GetDynAttrData(dynAttrs[i])
        if dynAttr ~= nil then
            t[attsIndex] = dynAttr
            attr2Index[dynAttr.attr] = attsIndex
            attsIndex = attsIndex + 1
        end
    end
    for i = 0, dynExAttrs.Count - 1 do
        ---@type DynAttrData
        local dynAttr = GetDynAttrData(dynExAttrs[i])
        if dynAttr ~= nil then
            ---@type enhanceDynAttrData
            local baseattr = t[attr2Index[dynAttr.attr]]
            if baseattr ~= nil and baseattr.attr == dynAttr.attr then
                baseattr.exV = dynAttr.value
            else
                print("附加属性错误")
            end
        end
    end
end


LogicDefine.ArmorLevel = {
    Start = 0,
    Fairy = 2 --仙器
}
---@return enhanceDynAttrData
function LogicDefine.NewAttrTable(t)
    ---@type enhanceDynAttrData
    if t == nil then
        t = {}
        t.exV = int64.zero
    end
    if type(t) ~= "table" then
        return
    end
    function t.GetStrValue(plusPct, enhanceLv)
        local attrTxt = ""
        local pct = 0
        local vl, vh = int64.longtonum2(t.value)
        if vh > 0 then
            print("属性数据大于int32范围")
        end
        if not plusPct then
            pct = vl
        else
            pct = math.floor(vl * (plusPct) / 10000)
        end
        local exl, exh = int64.longtonum2(t.exV)
        if exh > 0 then
            print("强化属性数据大于int32范围")
        end
        if not enhanceLv or enhanceLv == 0 then
            if not plusPct then
                pct = pct + exl
            end
        elseif UIDefine.EquipEnhanceData and UIDefine.EquipEnhanceData[enhanceLv] then
            -- body
            pct = pct * (10000 + UIDefine.EquipEnhanceData[enhanceLv]) / 10000
        else
            print("强化表丢失")
            return "NaN"
        end
        pct = math.floor(pct)
        if t.IsPct then
            attrTxt = (pct / 100) .. "%"
        else
            attrTxt = tostring(pct)
        end
        return attrTxt
    end
    return t
end
---@return enhanceDynAttrData
---@param serverAttr ServerAttr
function LogicDefine.ServerAttr2Client(serverAttr, t)
    t = LogicDefine.NewAttrTable(t)
    local dbattr = DB.GetOnceAttrByKey2(serverAttr.AttrName)
    if dbattr.Id == 0 then
        print("属性数据错误")
    end
    t.attr = dbattr.Id
    t.value = serverAttr.AttrVal
    t.IsPct = dbattr.IsPct == 1
    t.name = dbattr.ChinaName
    t.keyname = serverAttr.AttrName
    return t
end
---@return enhanceDynAttrData
---@param serverAttr DynAttrData_Object
function LogicDefine.ServerIdAttr2Client(serverAttr, t)
    t = LogicDefine.NewAttrTable(t)
    local dbattr = DB.GetOnceAttrByKey1(serverAttr.attr)
    if dbattr.Id == 0 then
        print("属性数据错误")
    end
    t.attr = serverAttr.attr
    t.value = serverAttr.value
    t.IsPct = dbattr.IsPct == 1
    t.name = dbattr.ChinaName
    t.keyname = dbattr.Name
    t.mark = serverAttr.mark
    return t
end
---@return int64
function LogicDefine.GetAttrFromFreeList(attrs, roleAttr, defaultValue)
    defaultValue = defaultValue or int64.zero
    if attrs and roleAttr then
        for i = 1, attrs.Count do
            local data = attrs[i - 1]
            if roleAttr == RoleAttr.IntToEnum(data.attr) then
                return data.value
            end
        end
    end
    return defaultValue
end

function LogicDefine.CheckActivityDay(timeStr, d)
    local strs = string.split(timeStr, ",")
    if strs then
        for i, v in ipairs(strs) do
            if v == d then
                return true
            end
        end
    end
    return false
end

function LogicDefine.CheckActivityDate(dateStart, dateEnd, curTime)

    local temp1 = string.split(dateStart, " ")
    local temp2 = string.split(dateEnd, " ")
    if #temp1 ~= 2 or #temp2 ~= 2 then
        test("活动日期配置错误！")
        return false
    end
    local startStr = string.split(temp1[1], "-")
    local endStr = string.split(temp2[1], "-")
    if #startStr ~= 3 or #endStr ~= 3 then
        test("活动日期配置错误！")
        return false
    end
    local t1 = string.split(temp1[2], ":")
    local t2 = string.split(temp2[2], ":")
    local startTime =
        os.time(
        {
            year = tonumber(startStr[1]),
            month = tonumber(startStr[2]),
            day = tonumber(startStr[3]),
            hour = tonumber(t1[1]),
            min = tonumber(t1[2]),
            sec = tonumber(t1[3]),
            isdst = false
        }
    )
    local endTime =
        os.time(
        {
            year = tonumber(endStr[1]),
            month = tonumber(endStr[2]),
            day = tonumber(endStr[3]),
            hour = tonumber(t2[1]),
            min = tonumber(t2[2]),
            sec = tonumber(t2[3]),
            isdst = false
        }
    )
    local nowDate = os.difftime(curTime, os.time(os.date("!*t", curTime)))
    curTime = curTime - nowDate
    return startTime <= curTime and curTime <= endTime
end

function LogicDefine.CheckActivityTime(timestart, timeend, curTime)
    local startStr = string.split(timestart, ":")
    local endstr = string.split(timeend, ":")
    local s = tonumber(startStr[1]) * 3600 + tonumber(startStr[2]) * 60 + tonumber(startStr[3])
    local e = tonumber(endstr[1]) * 3600 + tonumber(endstr[2]) * 60 + tonumber(endstr[3])
    return s <= curTime and curTime <= e
end

function LogicDefine.CheckActivityDate2(dateStart, dateEnd, curTime)

    local temp1 = string.split(dateStart, " ")
    local temp2 = string.split(dateEnd, " ")
    if #temp1 ~= 2 or #temp2 ~= 2 then
        test("活动日期配置错误！")
        return false
    end
    local startStr = string.split(temp1[1], "-")
    local endStr = string.split(temp2[1], "-")
    if #startStr ~= 3 or #endStr ~= 3 then
        test("活动日期配置错误！")
        return false
    end
    local t1 = string.split(temp1[2], ":")
    local t2 = string.split(temp2[2], ":")
    local startTime =
    os.time(
            {
                year = tonumber(startStr[1]),
                month = tonumber(startStr[2]),
                day = tonumber(startStr[3]),
                hour = tonumber(t1[1]),
                minute = tonumber(t1[2]),
                seconds = tonumber(t1[3]),
                isdst = false
            }
    )
    local endTime =
    os.time(
            {
                year = tonumber(endStr[1]),
                month = tonumber(endStr[2]),
                day = tonumber(endStr[3]),
                hour = tonumber(t2[1]),
                minute = tonumber(t2[2]),
                seconds = tonumber(t2[3]),
                isdst = false
            }
    )
    local nowDate = os.difftime(curTime, os.time(os.date("!*t", curTime)))
    curTime = curTime - nowDate
    return startTime <= curTime , curTime <= endTime
end

function LogicDefine.CheckActivityTime2(timestart, timeend, curTime)
    local startStr = string.split(timestart, ":")
    local endstr = string.split(timeend, ":")
    local s = tonumber(startStr[1]) * 3600 + tonumber(startStr[2]) * 60 + tonumber(startStr[3])
    local e = tonumber(endstr[1]) * 3600 + tonumber(endstr[2]) * 60 + tonumber(endstr[3])
    return s <= curTime , curTime <= e
end
---@return enhanceDynAttrData[],enhanceDynAttrData[],number[]
---@param serverNowAttr ServerAttr
---@param serverNextAttr ServerAttr
function LogicDefine.LvUpAttrChangeServer2Client(serverNowAttr, serverNextAttr)
    local nowattr = {}
    local nextattr = {}
    local attrId = {}
    if serverNowAttr then
        for i = 1, #serverNowAttr do
            local tmpattr = LogicDefine.ServerAttr2Client(serverNowAttr[i])
            nowattr[tmpattr.attr] = tmpattr
            attrId[#attrId + 1] = tmpattr.attr
        end
    end
    if serverNextAttr then
        for i = 1, #serverNextAttr do
            local tmpattr = LogicDefine.ServerAttr2Client(serverNextAttr[i])
            nextattr[tmpattr.attr] = tmpattr
            if nowattr[tmpattr.attr] == nil then
                local emptyAttr = LogicDefine.ServerAttr2Client(serverNextAttr[i])
                emptyAttr.value = 0
                nowattr[tmpattr.attr] = emptyAttr
                attrId[#attrId + 1] = tmpattr.attr
            end
        end
    end
    return nowattr, nextattr, attrId
end
