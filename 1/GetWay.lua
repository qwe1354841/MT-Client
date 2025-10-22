local GetWay = {}
_G.GetWay = GetWay
---@type GetWayInfo[]
local Def = {
    [1] = {
        jump = function(wndName, param1, param2)
            param1 = param1 or "0"
            param2 = param2 or "0"
            if GetWay.CheckOpenWndSwitch(wndName,param1,param2) then
                GUI.OpenWnd(wndName, string.format("index:%s,index2:%s", param1, param2))
            end
        end
    },
    [2] = {
        jump = function(npcId)
            npcId = tonumber(npcId) or 0
            CL.StartMove(npcId)
            MainUI.CloseOtherWnds()
        end
    },
    [3] = {
        jump = function(mapid, x, y)
            mapid = tonumber(mapid) or 0
            x = tonumber(x) or 0
            y = tonumber(y) or 0
            y = CL.ChangeLogicPosZ(y, mapid)
            CL.StartMove(x, y, mapid)
        end
    },
    [4] = {
        jump = function(fromName, param1, param2)
            param2 = param2 or "0"
            CL.SendNotify(NOTIFY.SubmitForm, fromName, param1, param2)
        end
    },
    [5] = {
        jump = function(fromName, functionName, param)
            if _G[fromName] and _G[fromName][functionName] then
                if type(_G[fromName][functionName]) == "function" then
                    _G[fromName][functionName]()
                end
            end
        end
    },
    [6] = {
        jump = function(wndName, param1, param2,itemGuid)
            param1 = param1 or "0"
            param2 = param2 or "0"
			if GetWay.CheckOpenWndSwitch(wndName,param1,param2) then
				local wnd = GUI.GetWnd(wndName)
				if wnd and GUI.GetVisible(wnd) then
					return
				end
				GUI.OpenWnd(wndName, string.format("%s,%s,%s", param1, param2,itemGuid))
			end
        end
    },
    [7] = {
        jump = function(wndName, param1, param2,ItemKeyName)
            param1 = param1 or "1"
            param2 = param2 or "1"
			local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel))) 
			--养成开启等级
			local openlevel1 = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel["养成"] or 30
			--洗炼开启等级
			local openlevel2= MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel["洗炼"] or 46
			--合成开启等级
			local openlevel3 = MainUI.MainUISwitchConfig["宠物"].Subtab_OpenLevel["合成"] or 48

			if param1 == "2" and Level < openlevel1 then
				CL.SendNotify(NOTIFY.ShowBBMsg,"宠物养成"..openlevel1.."级开启。")
				return
			elseif param1 == "3" and Level < openlevel2 then
				CL.SendNotify(NOTIFY.ShowBBMsg,"宠物洗炼"..openlevel2.."级开启。")
				return
			elseif param1 == "4" and Level < openlevel3 then
				CL.SendNotify(NOTIFY.ShowBBMsg,"宠物合成"..openlevel3.."级开启。")
				return
			else
				if GetWay.CheckOpenWndSwitch(wndName,param1,param2) then
					GUI.OpenWnd(wndName, string.format("%s,%s,%s", param1, param2,ItemKeyName))
				end
			end
        end
    },
    [8]={  --帮派更名卡的使用
        jump=function(wndName)
            local Level = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
            if Level<30 then
                CL.SendNotify(NOTIFY.ShowBBMsg,"帮派30级开启。")
                return
            else
                if wndName=="FactionUI" then
                    GUI.OpenWnd("FactionUI")
                    FactionUI.OnChangeNameBtnClick()
                end
            end
        end
    },
    [9] = {
        jump = function(wndName, param1, param2,itemGuid)
            param1 = param1 or "0"
            param2 = param2 or "0"
			local PetCount =  LD.GetPetCount()
			if PetCount == 0 then
				CL.SendNotify(NOTIFY.ShowBBMsg,"您没有宠物，暂时无法装备。")
				return
			else
				if GetWay.CheckOpenWndSwitch(wndName,param1,param2) then
					GUI.OpenWnd(wndName, string.format("%s,%s,%s", param1, param2,itemGuid))
				end
			end
        end
    },
    -- 活动跳转
    [10] = {
        jump = function(wndName, param1, param2,ActivityName)
            param1 = param1 or "1"
            param2 = param2 or "1"
            ActivityName = ActivityName or "nil"
            if GetWay.CheckOpenWndSwitch(wndName,param1,param2) then
                GUI.OpenWnd(wndName, string.format("index:%s,index2:%s,index3:%s", param1, param2,ActivityName))
            end
        end
    },
	--宠物装备相关
    [11] = {
        jump = function(wndName, param1, param2)
            param1 = param1 or "1"
            param2 = param2 or "1"
			if GetWay.CheckOpenWndSwitch(wndName,param1,param2) then
				GUI.OpenWnd(wndName, string.format("%s,%s,%s,%s", param1, "1",nil,param2))
			end
        end
    },
}
GetWay.Def = Def

GetWay.SwitchMap={
  ["PetUI"]={
      [1]={
          Switch="PetEquip"
      },
      [2]={
          Switch="PetEquip"
      },
	  [3]={
          Switch="PetEquip"
      },
	  [4]={
          Switch="PetEquip"
      },
	  [5]={
          Switch="PetEquip"
      },
  },
  ["EquipUI"]={
    [1]={
        [2]={ Switch="EquipCreat"},
        [3]={ Switch="EquipIntensify"},
    },
    [2]={
        [1]={ Switch="EquipGem"},
        [2]={ Switch="EquipGem"},
    },
    [3]={
        Switch="EquipLevelUp"
    },
    [4]={
        [1]={Switch="Suit"}
    },
    [5]={
        [1]={Switch="EquipSoulReforge"},
        [2]={Switch="EquipSoulReforge"},
        [3]={Switch="EquipSoulReforge"}
    },
  },
  ["MythicalAnimalsUI"]={
      Switch="GodAnimal"
  },
  ["FirstRechargeUI"]={
      Switch="FirstRecharge"
  },
  ["VipUI"]={
      Switch="VIP"
  },
   ["PetEquipRepairUI"]={
      [1]={Switch="PetEquipIntensify"
	  },
	  [2]={
	  }
  },
}

function GetWay.CheckOpenWndSwitch(wndName,param1,param2)
    local wnd=GetWay.SwitchMap[wndName]
    if wnd == nil then
        return true
    else
        if wnd.Switch~=nil and UIDefine.FunctionSwitch[wnd.Switch]~="on" then
            return false
        end

        local index1 = wnd[tonumber(param1)]
        if index1 == nil then
            return false
        else
            local index2=index1[tonumber(param2)]
            if index2 == nil then
                return true
            elseif index2.Switch ~= nil and UIDefine.FunctionSwitch[index2.Switch] == "on" then
                return true
            end
        end
    end
    return false
end

