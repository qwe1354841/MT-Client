RoleCustomDataLogic = {}
RoleCustomDataLogic.Activity_Effect = {}
function RoleCustomDataLogic.OnCustomDataUpdate(type, k, v, roleid)
    if type == 1 and k == "ACTIVITY_TITLE" then
        roleid = roleid or 0
        if v == "" or v == nil then
            v = "0"
        end
        CL.SetRoleTopName(uint64.new(v), roleid)
    elseif string.find(k,"Activity_Effect_") then
        local playerGuid = LD.GetSelfGUID()
        roleid = roleid or 0
        v = tostring(v)
        if v == "" or v == nil then
            v = "0"
        end
        if playerGuid == roleid then
            roleid = 0
        end
        test(type, k, v, roleid)
        if v == "0" then
            if RoleCustomDataLogic.Activity_Effect[tostring(roleid)] == nil then
                RoleCustomDataLogic.Activity_Effect[tostring(roleid)] = {}
            end
            local effectID = RoleCustomDataLogic.Activity_Effect[tostring(roleid)][k]
            if effectID ~= nil then
                CL.DestroyRoleEffect(effectID,roleid)
                RoleCustomDataLogic.Activity_Effect[tostring(roleid)][k] = nil
            end
        else
            if RoleCustomDataLogic.Activity_Effect[tostring(roleid)] == nil then
                RoleCustomDataLogic.Activity_Effect[tostring(roleid)] = {}
            end
            local x,y,z,rx,ry,rz = 0,0,0,0,0,0
            if v == "3000" then
                rz = 90
            elseif v == "3001" or v == "3002" then
                x = 1
                rz = 90
            end
            if RoleCustomDataLogic.Activity_Effect[tostring(roleid)][k] == nil then
                local effectID = CL.CreateRoleEffect(v,roleid,x,y,z,eModelBoneType.Spine1,rx,ry,rz)
                -- local effectID = CL.CreateRoleEffect(v,roleid)
                RoleCustomDataLogic.Activity_Effect[tostring(roleid)][k] = effectID
            end
        end
	elseif k == "PlayerStallSigns" then
		local playerGuid = LD.GetSelfGUID()
        if playerGuid == roleid then
            roleid = 0
        end
		MainUI.RefreshStallSigns(roleid)
	elseif k == "ServerLevel_SaveExp" then
		local value = CL.GetIntCustomData("ServerLevel_SaveExp") ~= 0 and CL.GetIntCustomData("ServerLevel_SaveExp") or CL.GetAttr(RoleAttr.RoleAttrExp) 
		MainUI.NotifyRoleData(RoleAttr.RoleAttrExp, value)
		if GUI.HasWnd("RoleAttributeUI") then
			RoleAttributeUI.SelfExperienceChange(RoleAttr.RoleAttrExp, value)
		end
	elseif k == "Stall_ShopIntroduce" then
		local playerGuid = LD.GetSelfGUID()
        if playerGuid == roleid then
            roleid = 0
        end
		MainUI.SetStallSignboards(roleid)
    end
end
function RoleCustomDataLogic.OnMain()
    CL.AddNotifyRoleCustomKey("ACTIVITY_TITLE")
    CL.AddNotifyRoleCustomKey("Activity_Effect_1")
    CL.AddNotifyRoleCustomKey("Activity_Effect_2")
    CL.AddNotifyRoleCustomKey("Activity_Effect_3")
    CL.AddNotifyRoleCustomKey("Activity_Effect_4")
    CL.AddNotifyRoleCustomKey("Activity_Effect_5")
	CL.AddNotifyRoleCustomKey("PlayerStallSigns")
	CL.AddNotifyRoleCustomKey("Stall_ShopIntroduce")
	CL.AddNotifyRoleCustomKey("ServerLevel_SaveExp")
    CL.RegisterMessage(GM.CustomDataUpdateReg, "RoleCustomDataLogic", "OnCustomDataUpdate")
end
function RoleCustomDataLogic.OnShow(parameter)
end
function RoleCustomDataLogic.OnDestroy()
    MainSysOpen.OnClose()
end
function RoleCustomDataLogic.OnClose()
    CL.UnRegisterMessage(GM.CustomDataUpdateReg, "RoleCustomDataLogic", "OnCustomDataUpdate")
end
function RoleCustomDataLogic.Init()
    MainUI.AddOnMainEvt("RoleCustomDataLogic", "OnMain")
    MainUI.AddOnCloseEvt("RoleCustomDataLogic", "OnClose")
    MainUI.AddOnShowEvt("RoleCustomDataLogic", "OnShow")
    MainUI.AddOnDestroyEvt("RoleCustomDataLogic", "OnDestroy")
end
