ModelItem = {}
---@param model GUIRawImageChild
---@param act eRoleMovement
---@param wep number
---@param modelid number
---@param sex number
---@param dyn1 number
---@param dyn2 number
function ModelItem.Bind(model, modelid, dyn1, dyn2, act, wep, sex,wepeffect, headid, originalModelID)
    if model == nil or modelid == nil then
        return
    end
    if act == nil then
        act = eRoleMovement.STAND_W1
    end
    if wep == nil then
        wep = 0
    end
    if sex == nil then
        sex = 0
    end
    if dyn1 == nil then
        dyn1 = 1601
    end
    if dyn2 == nil then
        dyn2 = 0
    end
    wepeffect = wepeffect or 0
    if wepeffect<0 then
        wepeffect = 0
    end
    headid = headid or 0
    originalModelID = originalModelID or 0

    GUI.ReplaceWeapon(model, wep, act, sex, modelid, wepeffect, headid, originalModelID)

    if modelid == originalModelID or originalModelID==0 then
        dyn1=DB.GetColor(dyn1).AppearId;
        if dyn2~=0 then
            dyn2=DB.GetColor(dyn2).AppearId;
        end
        GUI.RefreshDyeSkin(model,dyn1, dyn2)
    end
end

function ModelItem.BindRoleWithClothAndWind(model, modelid, dyn1, dyn2, act, wep, sex, wepeffect, roleGUID)
    if model == nil or modelid == nil then
        return
    end
    if act == nil then
        act = eRoleMovement.STAND_W1
    end
    if wep == nil then
        wep = 0
    end
    if sex == nil then
        sex = 0
    end
    if dyn1 == nil then
        dyn1 = 1601
    end
    if dyn2 == nil then
        dyn2 = 0
    end
    wepeffect = wepeffect or 0
    if wepeffect<0 then
        wepeffect = 0
    end
	
	-- test("roleGUID======"..tostring(roleGUID))
    roleGUID = roleGUID or 0

    local defaultModelID = modelid
    local headid = 0
	local wholebody = 0
    --角色的时装信息
    local _ClosthID = CL.GetIntCustomData("Model_Clothes", roleGUID)
    if _ClosthID ~= 0 then
        local config = DB.GetOnceIllusionByKey1(_ClosthID)
        if config.Id ~= 0 then
            --如果是全身时装，则需要替换模型ID
            if config.Type == 0 then
                modelid = tonumber(tostring(config.Model))
				wholebody = 1
            elseif config.Type == 1 then
                headid = tonumber(tostring(config.Model))
            end
        end
    end
    --羽翼信息
    local _WingID = CL.GetIntCustomData("Model_Wing",roleGUID)
    local _WingLevel = 0
    local _WingModelID = 0
    if _WingID ~= 0 then
        _WingLevel = CL.GetIntCustomData("WingGrow_Stage",roleGUID)
        local _Config = DB.GetOnceIllusionByKey1(_WingID)
        _WingModelID = tonumber(tostring(_Config.Model))
    end

    local updateModel = false
    local preModelInfo = GUI.GetData(model, "modelInfo")
    local modelInfo = tostring(wep)..tostring(act)..tostring(sex)..tostring(modelid)..tostring(wepeffect)..tostring(headid)..tostring(defaultModelID)
    if preModelInfo ~= modelInfo then
        updateModel = true
        GUI.ReplaceWeapon(model, wep, act, sex, modelid, wepeffect, headid, defaultModelID)
        GUI.SetData(model, "modelInfo", modelInfo)
    end
    local preModelInfo = GUI.GetData(model, "wingInfo")
    local wingInfo = tostring(_WingModelID)..tostring(_WingLevel)
    if wingInfo ~= preModelInfo or updateModel then
        GUI.ReplaceWing(model, _WingModelID, _WingLevel)
        GUI.SetData(model, "wingInfo", wingInfo)
    end

    if modelid == defaultModelID then
        dyn1=DB.GetColor(dyn1).AppearId;
        if dyn2~=0 then
            dyn2=DB.GetColor(dyn2).AppearId;
        end
        GUI.RefreshDyeSkin(model,dyn1, dyn2)
    end
	
	--最终染色（除全身时装外
	if wholebody ~= 1 then
		if CL.GetStrCustomData("Model_DynJson1",roleGUID) and CL.GetStrCustomData("Model_DynJson1",roleGUID) ~= "" then
			if UIDefine.IsFunctionOrVariableExist(GUI,"RefreshDyeSkinJson") then
				GUI.RefreshDyeSkinJson(model, CL.GetStrCustomData("Model_DynJson1",roleGUID), "")
			end
		end
	end
end

function ModelItem.BindRoleId(model,roleId,act,wep)
    if model == nil then
        return
    end

    local roleDB = DB.GetRole(roleId);
    local modelId = tonumber(roleDB.Model)
    ModelItem.Bind(model, modelId, 0, 0, act, wep, roleDB.Sex)
end


---@param model GUIRawImageChild
---@param act eRoleMovement
function ModelItem.BindSelfRole(model,act,wep,effect)
    if model == nil then
        return
    end
    local roleId = CL.GetRoleTemplateID();
    local roleDB = DB.GetRole(roleId);
    local modelId = tonumber(roleDB.Model)
    wep = wep or CL.GetIntAttr(RoleAttr.RoleAttrWeaponId)
    local sex = CL.GetIntAttr(RoleAttr.RoleAttrGender)
    local dyn1 = CL.GetIntAttr(RoleAttr.RoleAttrColor1)
    local dyn2 = CL.GetIntAttr(RoleAttr.RoleAttrColor2)
    effect = effect or CL.GetIntAttr(RoleAttr.RoleAttrEffect1)
    ModelItem.BindRoleWithClothAndWind(model, modelId, dyn1, dyn2, act, wep, sex,effect)
    ModelItem.BindRoleEquipGemEffect(model)
end

---@param model GUIRawImageChild
---@param act eRoleMovement
---@param modelid number
---@param roleGuid UInt64
function ModelItem.BindRole(model, modelid, roleGuid, act)
    if model == nil or modelid == nil then
        return
    end
    local wep = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId, roleGuid)
    local sex = CL.GetIntAttr(RoleAttr.RoleAttrGender, roleGuid)
    local dyn1 = CL.GetIntAttr(RoleAttr.RoleAttrColor1, roleGuid)
    local dyn2 = CL.GetIntAttr(RoleAttr.RoleAttrColor2, roleGuid)
    local effect = CL.GetIntAttr(RoleAttr.RoleAttrEffect1,roleGuid)
    ModelItem.Bind(model, modelid, dyn1, dyn2, act, wep, sex,effect)
end
---@param model GUIRawImageChild
---@param act eRoleMovement
---@param modelid number
---@param roleData PlayerBrief_Object
function ModelItem.BindRoleData(model, modelid, roleData, act)
    if model == nil or modelid == nil then
        return
    end
    local wep = CL.GetIntAttr(roleData, RoleAttr.RoleAttrWeaponId)
    local sex = CL.GetIntAttr(roleData, RoleAttr.RoleAttrGende)
    local dyn1 = CL.GetIntAttr(roleData, RoleAttr.RoleAttrColor1)
    local dyn2 = CL.GetIntAttr(roleData, RoleAttr.RoleAttrColor2)
    local effect = CL.GetIntAttr(roleData, RoleAttr.RoleAttrEffect1)
    ModelItem.Bind(model, modelid, dyn1, dyn2, act, wep, sex,effect)
end
---@param model GUIRawImageChild
---@param act eRoleMovement
---@param modelid number
---@param petData PetDataEx
function ModelItem.BindPetData(model, modelid, petData, act)
    if model == nil or modelid == nil then
        return
    end
    local wep = 0
    local sex = 0
    local dyn1 = petData:GetIntAttr(RoleAttr.RoleAttrColor1)
    local dyn2 = 0
    ModelItem.Bind(model, modelid, dyn1, dyn2, act, wep, sex)
end

---刷新侍从模型
---@param model GUIRawImageChild
---@param guid UInt64
---@param act eRoleMovement
function ModelItem.BindGuardModel(model, guid, act, wep, effect)
    if model == nil then
        return
    end
    local data = LD.GetGuardData(guid)
    if not data then
        return
    end
    act = act or eRoleMovement.STAND_W1
    local guardId = tonumber(tostring(LogicDefine.GetAttrFromFreeList(data.attrs, RoleAttr.RoleAttrRole)))
    local guardDB = DB.GetOnceGuardByKey1(guardId)
    local modelId = tonumber(guardDB.Model)
    wep = wep or tonumber(tostring(LogicDefine.GetAttrFromFreeList(data.attrs, RoleAttr.RoleAttrWeaponId)))--CL.GetIntAttr(RoleAttr.RoleAttrWeaponId)
    local sex = tonumber(tostring(LogicDefine.GetAttrFromFreeList(data.attrs, RoleAttr.RoleAttrGender))) -- CL.GetIntAttr(RoleAttr.RoleAttrGender)
    local dyn1 = guardDB.ColorID1
    local dyn2 = guardDB.ColorID2
    effect = effect or tonumber(tostring(LogicDefine.GetAttrFromFreeList(data.attrs, RoleAttr.RoleAttrEffect1))) -- CL.GetIntAttr(RoleAttr.RoleAttrEffect1)
    ModelItem.Bind(model, modelId, dyn1, dyn2, act, wep, sex, effect)
end


function ModelItem.Clear()
    ModelItem.EquipEffectConfig = nil
    ModelItem.GemEffectConfig = nil
end

ModelItem.EquipEffectConfig = nil
ModelItem.GemEffectConfig = nil
function ModelItem.InitRoleEquipGemEffectConfig()
    if ModelItem.EquipEffectConfig == nil then
        local config = BasicGameConfig.GetData("EquipRewardLevel")
        if config then
            ModelItem.EquipEffectConfig = {}
            local _Vals = string.split(config, ",")
            local _Count = #_Vals
            for i = 1, _Count do
                local _OneVal = string.split(_Vals[i], "-")
                if #_OneVal == 2 then
                    ModelItem.EquipEffectConfig[_OneVal[1]] = _OneVal[2]
                end
            end
        end
    end
    if ModelItem.GemEffectConfig == nil then
        local config = BasicGameConfig.GetData("GemRewardLevel")
        if config then
            ModelItem.GemEffectConfig = {}
            local _Vals = string.split(config, ",")
            local _Count = #_Vals
            for i = 1, _Count do
                local _OneVal = string.split(_Vals[i], "-")
                if #_OneVal == 2 then
                    ModelItem.GemEffectConfig[_OneVal[1]] = _OneVal[2]
                end
            end
        end
    end
end

function ModelItem.BindRoleEquipGemEffect(model,guid, isTeam)
    ModelItem.InitRoleEquipGemEffectConfig()

    local roleGUID = guid or 0
    local isTeam = isTeam or false
    --获取到装备强化等级和宝石等级
    local equipRewardLevel = not isTeam and CL.GetIntCustomData("EquipRewardLevel", roleGUID) or LD.GetTeamIntCustomData("EquipRewardLevel", roleGUID)
    local gemRewardLevel = not isTeam and CL.GetIntCustomData("GemRewardLevel", roleGUID) or LD.GetTeamIntCustomData("GemRewardLevel", roleGUID)
    ModelItem.BindRoleEquipGemEffectWithLevel(model,equipRewardLevel,gemRewardLevel)
end

function ModelItem.BindRoleEquipGemEffectWithLevel(model,equipLevel,gemLevel)
    ModelItem.InitRoleEquipGemEffectConfig()

    if ModelItem.EquipEffectConfig then
        --local _PreEffectLevel = tonumber(GUI.GetData(model, "EquipRewardLevel")) or 0
        --if _PreEffectLevel ~= equipLevel then
            local _PreEffectID = tonumber(GUI.GetData(model, "equipEffectID")) or 0
            if _PreEffectID ~= 0 then
                GUI.DestroyRoleEffect(model, _PreEffectID)
                GUI.SetData(model, "equipEffectID", "0")
            end
            if ModelItem.EquipEffectConfig[tostring(equipLevel)] then
                local _EffectID = GUI.CreateRoleEffect(model, tonumber(ModelItem.EquipEffectConfig[tostring(equipLevel)]),0,0,0,eModelBoneType.Count)
                GUI.SetData(model, "equipEffectID", _EffectID)
            end
            GUI.SetData(model, "EquipRewardLevel", equipLevel)
        --end
    end
    if ModelItem.GemEffectConfig then
        --local _PreEffectLevel = tonumber(GUI.GetData(model, "GemRewardLevel")) or 0
        --if _PreEffectLevel ~= gemLevel then
            local _PreEffectID = tonumber(GUI.GetData(model, "gemEffectID")) or 0
            if _PreEffectID ~= 0 then
                GUI.DestroyRoleEffect(model, _PreEffectID)
                GUI.SetData(model, "gemEffectID", "0")
            end
            if ModelItem.GemEffectConfig[tostring(gemLevel)] then
                local _EffectID = GUI.CreateRoleEffect(model, tonumber(ModelItem.GemEffectConfig[tostring(gemLevel)]),0,0,0,eModelBoneType.Count)
                GUI.SetData(model, "gemEffectID", _EffectID)
            end
            GUI.SetData(model, "GemRewardLevel", gemLevel)
        --end
    end
end