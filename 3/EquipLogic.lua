EquipLogic = {}
local IsGuard = function(guardGuid)
    return guardGuid ~= nil and guardGuid~=0;
end

local SpecialAttr =
{
    [RoleAttr.RoleAttrVit] = RoleAttr.RoleAttrVitPoint,
    [RoleAttr.RoleAttrInt] = RoleAttr.RoleAttrIntPoint,
    [RoleAttr.RoleAttrStr] = RoleAttr.RoleAttrStrPoint,
    [RoleAttr.RoleAttrAgi] = RoleAttr.RoleAttrAgiPoint,
}

local GetUserIntAttr = function(roleAttr, guardGuid)
    local attr = SpecialAttr[roleAttr]
    if IsGuard(guardGuid) then
        local guardData = LD.GetGuardData(guardGuid)
        if not guardData then
            return 0
        end
        local value = tonumber(tostring(LogicDefine.GetAttrFromFreeList(guardData.attrs, roleAttr)))
        if roleAttr == RoleAttr.RoleAttrRole then
            local guardDB = DB.GetOnceGuardByKey1(value)
            return guardDB.Role
        end
        if attr then
            return tonumber(tostring(LogicDefine.GetAttrFromFreeList(guardData.attrs, RoleAttr.RoleAttrLevel))) +
                    tonumber(tostring(LogicDefine.GetAttrFromFreeList(guardData.attrs, attr)))
        end
        return value
    else
        if attr then
            return CL.GetIntAttr(RoleAttr.RoleAttrLevel) + CL.GetIntAttr(attr)
        end
        return CL.GetIntAttr(roleAttr)
    end
end

local GetUserAttr = function(roleAttr, guardGuid)
    local attr = SpecialAttr[roleAttr]
    if IsGuard(guardGuid) then
        local guardData = LD.GetGuardData(guardGuid)
        if not guardData then
            return int64.zero
        end
        local value = LogicDefine.GetAttrFromFreeList(guardData.attrs, roleAttr)
        if roleAttr == RoleAttr.RoleAttrRole then
            local guardDB = DB.GetOnceGuardByKey1(tonumber(tostring(value)))
            return guardDB.Role
        end
        if attr then
            return LogicDefine.GetAttrFromFreeList(guardData.attrs, RoleAttr.RoleAttrLevel) +
                    LogicDefine.GetAttrFromFreeList(guardData.attrs, attr)
        end
        return value
    else
        if attr then
            return CL.GetAttr(RoleAttr.RoleAttrLevel) + CL.GetAttr(attr)
        end
        return CL.GetAttr(roleAttr)
    end
end

EquipLogic.attrT = {
    [1] = {
        name = "穿戴等级",
        GetV = function(itemdata, itemattr)
            local txt = ""
            --[[local turnBorn = itemdata.TurnBorn
            if turnBorn > 0 then
                txt = turnBorn .. "转"
            end--]]
            local lv = itemdata.Level
            if lv > 0 then
                txt = txt .. lv .. "级"
            end

            return txt
        end,
        IsShow = function(itemdata, itemattr)
            --[[local turnBorn = itemdata.TurnBorn
            if turnBorn > 0 then
                return true
            end--]]
            local lv = itemdata.Level
            if lv > 0 then
                return true
            end
            return false
        end,
        CanUse = function(itemdata, itemattr, guardGuid)
            local re = GetUserIntAttr(RoleAttr.RoleAttrReincarnation, guardGuid)
            --[[if re < itemdata.TurnBorn then
                return false
            elseif re > itemdata.TurnBorn then
                return true
            end--]]
            if GetUserIntAttr(RoleAttr.RoleAttrLevel, guardGuid) >= itemdata.Level then
                return true
            else
                return false
            end
            return true
        end,
        GetColor = function(self, itemdata, itemattr, guardGuid)
            if self.CanUse(itemdata, itemattr, guardGuid) then
                return UIDefine.BrownColor
            else
                return UIDefine.RedColor
            end
        end
    },
    [2] = {
        name = "力量需求",
        GetV = function(itemdata, itemattr)
            return tostring(itemattr.StrRequire)
        end,
        IsShow = function(itemdata, itemattr)
            if itemattr.StrRequire > 0 then
                return true
            end
            return false
        end,
        CanUse = function(itemdata, itemattr, guardGuid)
            if GetUserAttr(RoleAttr.RoleAttrStr, guardGuid) >= int64.new(itemattr.StrRequire) then
                return true
            else
                return false
            end
        end,
        GetColor = function(self, itemdata, itemattr, guardGuid)
            if self.CanUse(itemdata, itemattr, guardGuid) then
                return UIDefine.BrownColor
            else
                return UIDefine.RedColor
            end
        end
    },
    [3] = {
        name = "根骨需求",
        GetV = function(itemdata, itemattr)
            return tostring(itemattr.VitRequire)
        end,
        IsShow = function(itemdata, itemattr)
            if itemattr.VitRequire > 0 then
                return true
            end
            return false
        end,
        CanUse = function(itemdata, itemattr, guardGuid)
            if GetUserAttr(RoleAttr.RoleAttrVit, guardGuid) >= int64.new(itemattr.VitRequire) then
                return true
            else
                return false
            end
        end,
        GetColor = function(self, itemdata, itemattr, guardGuid)
            if self.CanUse(itemdata, itemattr, guardGuid) then
                return UIDefine.BrownColor
            else
                return UIDefine.RedColor
            end
        end
    },
    [4] = {
        name = "灵性需求",
        GetV = function(itemdata, itemattr)
            return tostring(itemattr.IntRequire)
        end,
        IsShow = function(itemdata, itemattr)
            if itemattr.IntRequire > 0 then
                return true
            end
            return false
        end,
        CanUse = function(itemdata, itemattr, guardGuid)
            if GetUserAttr(RoleAttr.RoleAttrInt, guardGuid) >= int64.new(itemattr.IntRequire) then
                return true
            else
                return false
            end
        end,
        GetColor = function(self, itemdata, itemattr, guardGuid)
            if self.CanUse(itemdata, itemattr, guardGuid) then
                return UIDefine.BrownColor
            else
                return UIDefine.RedColor
            end
        end,
    },
    [5] = {
        name = "敏捷需求",
        GetV = function(itemdata, itemattr)
            return tostring(itemattr.AgiRequire)
        end,
        IsShow = function(itemdata, itemattr)
            if itemattr.AgiRequire > 0 then
                return true
            end
            return false
        end,
        CanUse = function(itemdata, itemattr, guardGuid)
            if GetUserAttr(RoleAttr.RoleAttrAgi, guardGuid) >= int64.new(itemattr.AgiRequire) then
                return true
            else
                return false
            end
        end,
        GetColor = function(self, itemdata, itemattr, guardGuid)
            if self.CanUse(itemdata, itemattr, guardGuid) then
                return UIDefine.BrownColor
            else
                return UIDefine.RedColor
            end
        end
    },
    [6] = {
        name = "角色需求",
        GetV = function(itemdata, itemattr)
            local txt = ""
            if itemdata.Role > 0 then
                return DB.GetRole(itemdata.Role).RoleName
            end
            if itemdata.Job > 0 then
                return DB.GetSchool(itemdata.Job).Name
            end
            if itemdata.Sex > 0 then
                return UIDefine.GetSexName(itemdata.Sex)
            end
            return txt
        end,
        IsShow = function(itemdata, itemattr)
            if itemdata.Role > 0 or itemdata.Sex > 0 or itemdata.Job > 0 then
                return true
            end
            return false
        end,
        CanUse = function(itemdata, itemattr, guardGuid)
            if itemdata.Role > 0 then
                if GetUserIntAttr(RoleAttr.RoleAttrRole, guardGuid) == itemdata.Role or GetUserIntAttr(RoleAttr.RoleAttrRole, guardGuid) == itemdata.Role2 then
                    return true
                else
                    return false
                end
            end
            if itemdata.Job > 0 then
                for i = 1, 3 do
                    if GetUserIntAttr(RoleAttr["RoleAttrJob" .. i], guardGuid) == itemdata.Job then
                        return true
                    end
                end
                return false
            end
            if itemdata.Sex > 0 then
                if GetUserIntAttr(RoleAttr.RoleAttrGender, guardGuid) == itemdata.Sex then
                    return true
                else
                    return false
                end
            end
            return true
        end,
        GetColor = function(self, itemdata, itemattr, guardGuid)
            if self.CanUse(itemdata, itemattr, guardGuid) then
                return UIDefine.BrownColor
            else
                return UIDefine.RedColor
            end
        end
    },
    [7] = {
        name = "特效",
        GetV = function(itemdata, itemattr)
            local txt = ""

            if itemattr.SkillShow > 0 and itemattr.Skill > 0 then
                local skill = DB.GetOnceSkillByKey1(itemattr.Skill)
                if skill ~= nil and skill.Id > 0 then
                    txt = skill.Name
                end
            end
            if itemattr.SkillExtShow1 > 0 and itemattr.SkillExt1 > 0 then
                local skill = DB.GetOnceSkillByKey1(itemattr.SkillExt1)
                if skill ~= nil and skill.Id > 0 then
                    txt = txt .. " " .. skill.Name
                end
            end
            if itemattr.SkillExtShow2 > 0 and itemattr.SkillExt2 > 0 then
                local skill = DB.GetOnceSkillByKey1(itemattr.SkillExt2)
                if skill ~= nil and skill.Id > 0 then
                    txt = txt .. " " .. skill.Name
                end
            end
            return txt
        end,
        IsShow = function(itemdata, itemattr)
            if itemattr.SkillShow > 0 and itemattr.Skill > 0 then
                return true
            end
            if itemattr.SkillExtShow1 > 0 and itemattr.SkillExt2 > 0 then
                return true
            end
            if itemattr.SkillExtShow2 > 0 and itemattr.SkillExt2 > 0 then
                return true
            end
            return false
        end,
        CanUse = function(itemdata, itemattr, guardGuid)
            return true
        end,
        GetColor = function(self, itemdata, itemattr, guardGuid)
            return UIDefine.BrownColor
        end
    }
}
