local ShowAttrNumber = false --是否显示主界面属性数字
local MainUI = {
    [UIDefine.UIEvent.OnMainEvt] = {},
    [UIDefine.UIEvent.OnShowEvt] = {},
    [UIDefine.UIEvent.OnCloseEvt] = {},
    [UIDefine.UIEvent.OnDestroyEvt] = {}
}
_G.MainUI = MainUI

------------------------------------------Start Test Start----------------------------------
local test = function () end  --要去掉打印就把 print 变为 function () end
local inspect = require("inspect")
--------------------------------------------End Test End------------------------------------

local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local QualityRes = UIDefine.ItemIconBg
local _gt = UILayout.NewGUIDUtilTable()

function MainUI.SendNotifiy(state)
    if MainUI[state] then
        for key, value in pairs(MainUI[state]) do
            if key and value then
                if _G[key] and _G[key][value] then
                    pcall(_G[key][value])
                end
            end
        end
    end
end
local addListen = function(state, Name, FunName)
    if _G[Name] and _G[Name][FunName] then
        if type(_G[Name][FunName]) == "function" then
	    local evtList = MainUI[state]
	    if not evtList then
	    	evtList = {}
		MainUI[state] = evtList
	    end
            evtList[Name] = FunName
        end
    end
end
local removeListen = function(state, Name, FunName)
    if _G[Name] and _G[Name][FunName] then
        if type(_G[Name][FunName]) == "function" then
            MainUI[state][Name] = nil
        end
    end
end
function MainUI.AddMainUIEvt(evtName, uiName, funcName)
    addListen(evtName, uiName, funcName)
end

function MainUI.RemoveMainUIEvt(evtName, uiName, funcName)
    removeListen(evtName, uiName, funcName)
end
function MainUI.AddOnMainEvt(name, funName)
    addListen(UIDefine.UIEvent.OnMainEvt, name, funName)
end
function MainUI.AddOnShowEvt(name, funName)
    addListen(UIDefine.UIEvent.OnShowEvt, name, funName)
end
function MainUI.AddOnCloseEvt(name, funName)
    addListen(UIDefine.UIEvent.OnCloseEvt, name, funName)
end
function MainUI.AddOnDestroyEvt(name, funName)
    addListen(UIDefine.UIEvent.OnDestroyEvt, name, funName)
end
require("NormalBuffUI")
require("MainDynamicUI")
require("MainSysOpen")
require("RoleCustomDataLogic")
require("GuideUICloseWndDef")
require("LoadAllFile")
local isInFight = false -- 是否处于战斗中
local isFightView = false -- 是否处于观战中
local defaultIcon = "1900000000"
test("MainAAA")

local colorDark = UIDefine.BrownColor
local fontSize = UIDefine.FontSizeM
local guidt = UILayout.NewGUIDUtilTable()
local switchRole = {
    -- 1:头像图片名
    {"1900300010"},
    {"1900300020"},
    {"1900300030"},
    {"1900300040"},
    {"1900300050"},
    {"1900300060"},
    {"1900300070"},
    {"1900300080"},
    {"1900300090"},
    {"1900300100"},
    {"1900300110"},
    {"1900300120"}
}

local CONTACT_TYPE = {
    contact_recently = 99, --//最近联系人
    contact_apply = 1, --//好友申请
    contact_friend = 2, --//好友
    contact_blacklist = 3, --//黑名单
    contact_stranger = 0,--陌生人
    contact_search = 100, --搜索列表
}
local RecordRoleGuid = {}

local buttonRightBottomLst = MainUIBtnOpenDef.buttonRightBottomLst
local buttonLeftTopLst = MainUIBtnOpenDef.buttonLeftTopLst
local buttonLeftLst = MainUIBtnOpenDef.buttonLeftLst
local data = {
    mapName = "",
    hostPos = "",
    roleIcon = defaultIcon,
    roleLv = int64.zero,
    roleExp = int64.zero,
    roleExpL = int64.zero,
    roleHp = int64.zero,
    roleHpL = int64.zero,
    roleMp = int64.zero,
    roleMpL = int64.zero,
	roleSp = int64.zero,
    roleSpL = int64.zero,
    roleVp = int64.zero,
    roleVpL = int64.zero,
    petIcon = defaultIcon,
    petLv = int64.zero,
    petHp = int64.zero,
    petHpL = int64.zero,
    petMp = int64.zero,
    petMpL = int64.zero,
    petSp = int64.zero,
    petSpL = int64.zero,
    vip = 0,
    batteryState = "",
    batterySlider = 1,
    time = "",
    roleid = 0
}
local timeCallback = {
    move = nil,
    device = nil
}
local event = {
    {GM.LoadedBaseMap, "MainUI", "BindMapData0"},
    {GM.PlayerEnterGame, "MainUI", "BindRoleData"},
    {GM.FightStateNtf, "MainUI", "InFight"},
    --战斗中的血蓝量变化
    {GM.FightRoleAttrChange, "MainUI", "OnInFightRoleAttrChange"},
    {GM.FightPetAttrChange, "MainUI", "OnInFightPetAttrChange"},
    {GM.FightPetEscape, "MainUI", "OnPetEscape"},
    {GM.MoveStart, "MainUI", "OnMoveStart"},
    {GM.MoveEnd, "MainUI", "OnMoveEnd"},
    {GM.PetInfoUpdate, "MainUI", "BindPetData"},
    {GM.AddNewItem, "MainUI", "OnAddNewItem"},
    {GM.OpenShopWnd, "MainUI", "OnOpenShopWnd"},
    {GM.TeamInviteMsg, "MainUI", "OnTeamInviteMsg"},
    {GM.PlayerDetailQueryNtf, "MainUI", "OnPlayerDetailQueryNtf"},
    {GM.UnloadPreMap, "MainUI", "OnUnloadPreMap"},
    {GM.FriendListUpdate,"MainUI", "OnFriendListUpdate"},
    {GM.GuardQueryNtf,"MainUI", "OnGuardQueryNtf"},
    {GM.LoginWebService, "MainUI", "OnLoginWebService"},
}
if GM.RoleModelCreated ~= nil then
	table.insert(event,{GM.RoleModelCreated, "MainUI", "OnRoleModelCreated"})
end
local attrT = {
    {
        enum = RoleAttr.RoleAttrHp,
        setValue = function(value)
            data.roleHp = value
        end
    },
    {
        enum = RoleAttr.RoleAttrMp,
        setValue = function(value)
            data.roleMp = value
        end
    },
	{
        enum = RoleAttr.RoleAttrSp,
        setValue = function(value)
            data.roleSp = value
        end
    },
    {
        enum = RoleAttr.RoleAttrVp,
        setValue = function(value)
            data.roleVp = value
        end
    },
    {
        enum = RoleAttr.RoleAttrHpLimit,
        setValue = function(value)
            data.roleHpL = value
        end
    },
    {
        enum = RoleAttr.RoleAttrMpLimit,
        setValue = function(value)
            data.roleMpL = value
        end
    },
	{
        enum = RoleAttr.RoleAttrSpLimit,
        setValue = function(value)
            data.roleSpL = value
        end
    },
    {
        enum = RoleAttr.RoleAttrVpLimit,
        setValue = function(value)
            data.roleVpL = value
        end
    },
    {
        enum = RoleAttr.RoleAttrLevel,
        setValue = function(value)
            data.roleLv = value
        end
    },
    {
        enum = RoleAttr.RoleAttrExp,
        setValue = function(value)
            data.roleExp = value
        end
    },
    {
        enum = RoleAttr.RoleAttrExpLimit,
        setValue = function(value)
            data.roleExpL = value
        end
    },
    {
        enum = RoleAttr.RoleAttrVip,
        setValue = function(value)
            data.vip = int64.longtonum2(value)
        end
    },
    {
        enum = RoleAttr.RoleAttrRole,
        setValue = function(value)
            data.roleid = int64.longtonum2(value)
            data.roleIcon = tostring(DB.GetRole(data.roleid).Head)
        end
    }
}
MainUI.IsJindouyunTransfer = true
MainUI.RealNameResultTimer = nil

MainUI.TempGuid = nil
MainUI.PromoteFV = nil
MainUI.IsGuideDuringMovieDialog = false

MainUI.GemRedPointFlag = false
MainUI.GuardRedPointFlag = false

MainUI.OnChangeHideOtherRole = -1
MainUI.OnChangeHideOtherPetGuard = -1


function MainUI.OnAddNewItem(itemGuid,PromoteFV) --PromoteFV：提高的战力数值
	GlobalProcessing.EquipUseState = true 
	if PromoteFV then
		MainUI.TempGuid = itemGuid
		MainUI.PromoteFV = PromoteFV
	else
		local wnd = GUI.GetWnd("AddNewItemUI")
		if GUI.GetVisible(wnd) == false then
			GUI.OpenWnd("AddNewItemUI")
		end

		AddNewItemUI.Add(itemGuid)

        -- 判断是否是侍从信物
        local guard_item_id = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id,itemGuid,item_container_type.item_container_guard_bag))
        if guard_item_id then
            local itemDB = DB.GetOnceItemByKey1(guard_item_id)
            -- 如果是侍从信物
            if itemDB and itemDB.Id ~= 0 and itemDB.Type == 6 then
                -- 判断等级是否足够
                local CurLevel = tonumber(tostring(CL.GetAttr(RoleAttr.RoleAttrLevel)))
                local Level = MainUI.MainUISwitchConfig["侍从"].OpenLevel
                if CurLevel < Level then
                    return
                end
                -- 判断是否已经拥有此侍从，判断碎片数量是否足够
                local itemKeyName = itemDB.KeyName
                local guardKeyName = string.split(itemKeyName,"信物")[1]
                local guardId = DB.GetOnceGuardByKey2(guardKeyName).Id
                if not LD.IsHaveGuard(guardId) then -- 判断此侍从是否拥有
                    if LD.GetItemCountById(guard_item_id,item_container_type.item_container_guard_bag) >= UIDefine.getGuardNeedAmount then
                        -- 物品id_type  type 3 侍从
                        GUI.OpenWnd('SignInAndLevelGiftUI',guard_item_id..'_'..3)
                    end
                end
            end
        else
			
            local window = GUI.GetWnd('SignInAndLevelGiftUI')
			if not CL.GetFightState() then
				if not GUI.GetVisible(window) then
					local wnd = GUI.GetWnd("QuickUseUI")
					if GUI.GetVisible(wnd) == false then
						GUI.OpenWnd("QuickUseUI")
						local type = 4 -- 装备道具界面
						-- 设置将当前打开页面
						UIDefine.prompt_sequence.current_show = UIDefine.prompt_sequence.ui[type].page
						-- 设置当前打开界面的type
						UIDefine.prompt_sequence.current_show_type = type
					end
				end

				if not QuickUseUI then
					require("QuickUseUI")
				end
				
				if MainUI.TempGuid == tostring(itemGuid) then
					QuickUseUI.Add(itemGuid,MainUI.PromoteFV)
				else
					QuickUseUI.Add(itemGuid)
				end
			end
        end
	end
    if not MainUI.GemRedPointFlag then
        local itemGem = LD.GetItemDataByGuid(itemGuid,item_container_type.item_container_gem_bag)
        if itemGem then
            local bagWnd = GUI.GetWnd("BagUI")
            if GUI.GetVisible(bagWnd) and BagUI.tabIndex == 1 and BagUI.subTabIndex == 2 then
            else
                MainUI.GemRedPointFlag = true
                GlobalProcessing.RedPointController('bagBtn', 'add_new_item_gem', 1)
            end
        end
    end
    if not MainUI.GuardRedPointFlag then
        local itemGuard = LD.GetItemDataByGuid(itemGuid,item_container_type.item_container_guard_bag)
        if itemGuard then
            local bagWnd = GUI.GetWnd("BagUI")
            if GUI.GetVisible(bagWnd) and BagUI.tabIndex == 1 and BagUI.subTabIndex == 3 then
            else
                MainUI.GuardRedPointFlag = true
                GlobalProcessing.RedPointController('bagBtn', 'add_new_item_guard', 1)
            end
        end
    end
end

function MainUI.OnOpenShopWnd(type)
    local wndType = type ~= nil and tonumber(type) or 0
    if wndType == 0 then
        GUI.OpenWnd("PetShopUI")
    else
        GUI.OpenWnd("ShopUI", wndType)
    end
end

function MainUI.OnPlayerDetailQueryNtf()
    GUI.OpenWnd("RoleInformationUI")
end
function MainUI.OnTeamInviteMsg(param)
    local vals = string.split(param, "#cutl#")
    if #vals >= 4 then
        local type = vals[1]
        local guid = vals[2]
        local time = tonumber(vals[3])
        local info = vals[4]
        GlobalUtils.ShowBoxMsg(
            "提示",
            info,
            "MainUI",
            "确定",
            "BeInvitedJoinYES",
            "取消",
            "BeInvitedJoinNO",
            false,
            "",
            1,
            time,
            false,
            type .. "," .. guid
        )
    end
end
function MainUI.BindMapData0()
	if WuDaoHuiMapEffect then
		if WuDaoHuiMapEffect ==1 and CL.GetCurrentMapName() == "武道会" then
			CL.ShowMapEffect("3000001445", "85,265", "0,0,0", "0,130,0", "1,1,1", "0")
			CL.ShowMapEffect("3000001445", "285,53", "0,0,0", "0,40,0", "1,1,1", "0")
		end
	end
	MainUI.BindMapData()

    --切换地图
    if MainUI.OnChangeHideOtherRole ~= -1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "SetOtherTeamCanSee", MainUI.OnChangeHideOtherRole)
        MainUI.OnChangeHideOtherRole = -1
    end
    if MainUI.OnChangeHideOtherPetGuard ~= -1 then
        CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "SetOtherPetCanSee", MainUI.OnChangeHideOtherPetGuard)
        CL.SendNotify(NOTIFY.SubmitForm, "FormGuard", "SetOtherGuardCanSee", MainUI.OnChangeHideOtherPetGuard)
        MainUI.OnChangeHideOtherPetGuard = -1
    end
end


function MainUI.BindMapData()
	
    --test("bindMapData")
    data.mapName = CL.GetCurrentMapName()
    local logicX, logicZ = CL.GetHostLogicX(), CL.GetHostLogicZ()
    data.hostPos = logicX .. "," .. logicZ
    MainUI.RefreshMap()
	
end

function MainUI.NotifyRoleData(attrType, value)
    -- value = tonumber(tostring(value))
    test("NotifyRoleData " .. tonumber(tostring(value)))
    for i = 1, #attrT do
        if attrType == attrT[i].enum then
            attrT[i].setValue(value)
        end
    end

    MainUI.RefreshRightTop()
end

function MainUI.BindRoleData()
    test("BindRoleData")
    data.roleid = CL.GetIntAttr(RoleAttr.RoleAttrRole)
    test("roleid " .. data.roleid)
    if data.roleid ~= 0 then
        data.roleIcon = tostring(DB.GetRole(data.roleid).Head)
        for i = 1, #attrT do
            -- 不考虑丢失精度
            attrT[i].setValue(CL.GetAttr(attrT[i].enum))
        end

        MainUI.RefreshRightTop()
    end
    MainUI.IsJindouyunTransfer = true
    if ChatUI then
        local state = CL.GetRealNameState()
        ChatUI.ShowRealNameBtn(state~=0 and state~=1)
    end
end

function MainUI.BindPetData()
    local petGuid = GlobalUtils.GetMainLineUpPetGuid()
    local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)))
    local petDB = DB.GetOncePetByKey1(petId)
    data.petIcon = petDB.Id ~= 0 and tostring(petDB.Head) or "1900000000"
    data.petHp = LD.GetPetAttr(RoleAttr.RoleAttrHp, petGuid)
    data.petHpL = LD.GetPetAttr(RoleAttr.RoleAttrHpLimit, petGuid)
    data.petMp = LD.GetPetAttr(RoleAttr.RoleAttrMp, petGuid)
    data.petMpL = LD.GetPetAttr(RoleAttr.RoleAttrMpLimit, petGuid)
    data.petLv = LD.GetPetAttr(RoleAttr.RoleAttrLevel, petGuid)
	data.petSp = LD.GetPetAttr(RoleAttr.PetAttrLoyalty, petGuid)
	data.petSpL =int64.new(DB.GetGlobal(1).PetClosePointsMax)
	-- CDebug.LogError(DB.GetGlobal(1).PetClosePointsMax)
    -- data.petSp = LD.GetPetAttr(RoleAttr.PetAttrClosePoint, petGuid)
    -- data.petSpL = int64.new(100)
    if not isInFight then -- 在战斗中不用刷新
        MainUI.RefreshRightTop()
    end
end

function MainUI.BindData()
    MainUI.BindPetData()
    MainUI.BindRoleData()
    MainUI.BindMapData()
end
function MainUI.Main(parameter)
    guidt = UILayout.NewGUIDUtilTable()
    test("MainUI.Main")
    -- //TODO 声音相关
    -- local VolumeOn = { SystemSetting_BasicSetting.openFightMusic, SystemSetting_BasicSetting.openBgMusic, SystemSetting_BasicSetting.openSoundEffect }
    -- local VolumeSetting = { SystemSetting_BasicSetting.fightMusicVolume, SystemSetting_BasicSetting.bgMusicVolume, SystemSetting_BasicSetting.soundEffectVolume }
    -- local audioType = { AudioType.FIGHT_BGM, AudioType.BGM, AudioType.EFFECT }
    -- for i = 1, #VolumeSetting do
    --     local volume = CL.GetSystemSetting(SystemSetting.BasicSetting, VolumeSetting[i])
    --     local isOn = CL.GetSystemSetting(SystemSetting.BasicSetting, VolumeOn[i])
    --     if volume ~= -1 then
    --         CL.SetVolume(audioType[i], volume / 100.0)
    --     end
    --     if isOn == 0 then
    --         CL.SetVolume(audioType[i], 0)
    --     end
    -- end
    local panel = GUI.WndCreateWnd("MainUI", "MainUI", 0, 0, eCanvasGroup.Main)
    guidt.BindName(panel, "panel")
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)
    --GUI.CreateSafeArea(panel)
    GUI.SetIgnoreChild_OnVisible(panel, true)
    MainUI.CreateRightTop(panel)
    MainUI.CreateMiniMap(panel)
    MainUI.CreateRightBottomButton(panel)
    MainDynamicUI.CreateUI(panel)

    -- 检验条
    local safeArea = GUI.GetSafeArea(panel)
    local w = safeArea.x
    local h = safeArea.y
    local ww = w / 10
    local www = ww / 2
    local experienceParent = GUI.ImageCreate(panel, "experienceParent", "1800200020", w / 2, h / 2,false)
    GUI.SetAnchor(experienceParent, UIAnchor.Center)
    GUI.SetPivot(experienceParent, UIAroundPivot.Center)
    GUI.SetHeight(experienceParent, 24)
    GUI.SetColor(experienceParent, UIDefine.Transparent)
    guidt.BindName(experienceParent, "experience")

    for i = 10, 1, -1 do
        local experienceBg = GUI.ImageCreate(experienceParent,"experienceBg" .. (11 - i), "1800200020", 0, -5, false, ww, 12)
        GUI.ImageSetType(experienceBg, SpriteType.Sliced)
        GUI.SetAnchor(experienceBg, UIAnchor.Center)
        GUI.SetPivot(experienceBg, UIAroundPivot.Center)
        GUI.SetPositionX(experienceBg, -i * ww + www)

        local experienceCover = GUI.ImageCreate(experienceBg, "experienceCover", "1800207041", 0, 0,  false, ww, 12)
        GUI.ImageSetType(experienceCover, SpriteType.Sliced)
        GUI.SetAnchor(experienceCover, UIAnchor.Left)
        GUI.SetPivot(experienceCover, UIAroundPivot.Left)
        GUI.SetVisible(experienceCover, false)
    end

    MainUI.CreatePetGrazeNode(panel)
    MainSysOpen.Init()
    RoleCustomDataLogic.Init()
    MainUI.SendNotifiy(UIDefine.UIEvent.OnMainEvt)
end

--[[
if tonumber(nowNum) == 0 then
    sLuaApp:ShowForm(player,"脚本表单","NewAntiWnd_IsBind="..isBind..";NewAntiWnd_noClose="..noClose..";")
    sLuaApp:ShowForm(player,"脚本表单","CL:OnAntiWnd()")

else
    local resNum = tonumber(maxNum) - tonumber(nowNum)
    sLuaApp:ShowForm(player,"脚本表单","AntiBackMsg_resNum="..resNum..";AntiBackMsg_IsBind="..isBind..";AntiBackMsg_noClose="..noClose.."")
    sLuaApp:ShowForm(player,"form文件表单","AntiBackMsg")
end
--]]

function MainUI.ShowRealNameAuthInfo(nowNum, maxNum, isBind, noClose)
    --CDebug.LogError(" .................."..tostring(CL.GetServerTickCount())..".....................nowNum :"..nowNum..", maxNum : "..maxNum..", isBind:"..isBind..", noClose:"..noClose)
    MainUI.DisableShowRealNameTips()
    GUI.OpenWnd("AuthRealNameUI")
end

function MainUI.DisableShowRealNameTips()
    local realNameTip = guidt.GetUI("realNameTipPanel")
    if realNameTip then
        GUI.SetVisible(realNameTip, false)
    end
end

--显示踢人提示UI
function MainUI.ShowRealNameTips(tipMsg)
    --CDebug.LogError("................................."..tostring(CL.GetServerTickCount()).."....................................ShowRealNameTips .. tipMsg : "..tostring(tipMsg))
    local realNameTipPanel = guidt.GetUI("realNameTipPanel")
    if realNameTipPanel == nil then
        local panel = guidt.GetUI("panel")
        if panel then
            local tipPanel=GUI.ImageCreate(panel,"tipPanel","1800001120",0,0,false ,460,260)
            UILayout.SetSameAnchorAndPivot(tipPanel,UILayout.Top)
            guidt.BindName(tipPanel, "realNameTipPanel")

            local titleBg =GUI.ImageCreate(tipPanel,"panelBg","1800400220",0,-100,false ,460,50)
            UILayout.SetSameAnchorAndPivot(titleBg,UILayout.Center)

            local titleBgTxt = GUI.CreateStatic(titleBg, "titleBgTxt", "实名认证提示", 0, 0, 430, 260,"system",true)
            UILayout.StaticSetFontSizeColorAlignment(titleBgTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

            local realNameTip = GUI.CreateStatic(tipPanel, "realNameTip", tostring(tipMsg), 0, 20, 430, 260,"system",true)
            guidt.BindName(realNameTip, "realNameTip")
            UILayout.SetSameAnchorAndPivot(realNameTip, UILayout.Center)
            UILayout.StaticSetFontSizeColorAlignment(realNameTip, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleLeft)
        end
    else
        local realNameTip = guidt.GetUI("realNameTip")
        if realNameTip then
            GUI.StaticSetText(realNameTip, tostring(tipMsg))
        end
        GUI.SetVisible(realNameTipPanel, true)
    end
end

function MainUI.CreatePetGrazeNode(panel)
    --天河牧场节点
    local tianHeMuChangNode = GUI.ImageCreate(panel, "tianHeMuChangNode", "1800200010", 0, 158, false, 222, 70)
    guidt.BindName(tianHeMuChangNode, "tianHeMuChangNode")
    UILayout.SetSameAnchorAndPivot(tianHeMuChangNode, UILayout.Top)
    GUI.SetVisible(tianHeMuChangNode, false)
    local txt = GUI.CreateStatic(tianHeMuChangNode, "txt", "当前牧场宠物数量", 0, -9, 200, 30)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    --数量背景
    local numBar = GUI.ImageCreate(tianHeMuChangNode, "numBar", "1800208020", 0, 18, false, 198, 16)
    UILayout.SetSameAnchorAndPivot(numBar, UILayout.Center)
    GUI.SetColor(numBar, UIDefine.BlackColor)
    local numBarFront = GUI.ImageCreate(tianHeMuChangNode, "numBarFront", "1800208021", 12, 18, false, 198, 16)
    UILayout.SetSameAnchorAndPivot(numBarFront, UILayout.Left)
    GUI.ImageSetType(numBarFront, SpriteType.Sliced)
    guidt.BindName(numBarFront, "tianHeMuChangNumBarFront")
    local txt = GUI.CreateStatic(tianHeMuChangNode, "txt", "0/40", 0, 18, 150, 30)
    guidt.BindName(txt, "tianHeMuChangNumTxt")
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeSS, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    --开始放牧
    local fangmuBtn = GUI.ButtonCreate(tianHeMuChangNode,"fangmuBtn", "1800001151",152,0, Transition.ColorTint, "", 74,74, false)
    UILayout.SetSameAnchorAndPivot(fangmuBtn, UILayout.Center)
    GUI.RegisterUIEvent(fangmuBtn , UCE.PointerClick , "MainUI", "OnClickFangMuBtn" )
    local txt = GUI.CreateStatic(fangmuBtn, "txt", "开始\n放牧", 1, 1, 80, 80)
    UILayout.SetSameAnchorAndPivot(txt, UILayout.Center)
    GUI.SetIsOutLine(txt,true)
    GUI.SetOutLine_Color(txt,UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(txt,1)
    UILayout.StaticSetFontSizeColorAlignment(txt, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
end

MainUI.IsOnPetGrazeState = false
function MainUI.OnSwitchPetGrazeNode(bShow)
    if MainUI.IsOnPetGrazeState then
        local tianHeMuChangNode = guidt.GetUI("tianHeMuChangNode")
        if tianHeMuChangNode then
            GUI.SetVisible(tianHeMuChangNode, bShow)
        end
    end
end

function MainUI.OnShowPetGrazeInfoUI(curNum, maxNum)
    local tianHeMuChangNode = guidt.GetUI("tianHeMuChangNode")
    if tianHeMuChangNode and not GUI.GetVisible(tianHeMuChangNode) then
        GUI.SetVisible(tianHeMuChangNode, true)
        MainUI.IsOnPetGrazeState = true
    end
    MainUI.OnUpdateTianHeMuChangPetNum(curNum, maxNum)
end

function MainUI.OnClickFangMuBtn()
    CL.SendNotify(NOTIFY.SubmitForm, "FormTianHeMuChang", "StartGrazeData")
end

function MainUI.OnUpdateTianHeMuChangPetNum(now, total)
    local tianHeMuChangNumBarFront = guidt.GetUI("tianHeMuChangNumBarFront")
    if tianHeMuChangNumBarFront and total ~= 0 then
        GUI.SetWidth(tianHeMuChangNumBarFront, 198 * now/total)
    end
    local tianHeMuChangNumTxt = guidt.GetUI("tianHeMuChangNumTxt")
    if tianHeMuChangNumTxt then
        GUI.StaticSetText(tianHeMuChangNumTxt, tostring(now) .."/".. tostring(total))
    end
end

function MainUI.OnUnloadPreMap()
    --关闭天河牧场节点
    local tianHeMuChangNode = guidt.GetUI("tianHeMuChangNode")
    if tianHeMuChangNode and GUI.GetVisible(tianHeMuChangNode) then
        GUI.SetVisible(tianHeMuChangNode, false)
        MainUI.IsOnPetGrazeState = false
    end
end

-- 创建右上角血条等
function MainUI.CreateRightTop(panelBg)
    local selfInfo = GUI.ImageCreate(panelBg, "selfInfo", "1800201020", 0, 0, true)
    UILayout.SetSameAnchorAndPivot(selfInfo, UILayout.TopRight)
    NormalBuffUI.CreateNormalBuff(panelBg, selfInfo) -- 创建查看buff按钮
    local selfInfoIcon = HeadIcon.Create(selfInfo, "selfInfoIcon", "1900000000", -40, -2, 92, 92)
    guidt.BindName(selfInfoIcon, "roleIcon")
    GUI.SetAnchor(selfInfoIcon, UIAnchor.Center)
    GUI.SetPivot(selfInfoIcon, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(selfInfoIcon, true)
    selfInfoIcon:RegisterEvent(UCE.PointerClick)
    selfInfoIcon:RegisterEvent(UCE.PointerDown)
    selfInfoIcon:RegisterEvent(UCE.PointerUp)
    GUI.RegisterUIEvent(selfInfoIcon, UCE.PointerClick, "MainUI", "OnSelfInfoClick")
    GUI.RegisterUIEvent(selfInfoIcon, UCE.PointerDown, "MainUI", "BtnPointDown")
    GUI.RegisterUIEvent(selfInfoIcon, UCE.PointerUp, "MainUI", "BtnPointUp")

    local selfInfoCover = GUI.ImageCreate(selfInfo, "selfInfoCover", "1800201010", 0, 0, false)
    GUI.SetAnchor(selfInfoCover, UIAnchor.TopRight)
    GUI.SetPivot(selfInfoCover, UIAroundPivot.TopRight)

    local selfLevel = GUI.CreateStatic(selfInfoCover, "selfLevel", "1", -17, -14, 40, 40)
    GUI.SetAnchor(selfLevel, UIAnchor.BottomLeft)
    GUI.SetPivot(selfLevel, UIAroundPivot.Center)
    GUI.StaticSetAlignment(selfLevel, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(selfLevel, 18)
    guidt.BindName(selfLevel, "roleLv")

    local silderFillSize = Vector2.New(74, 14)
    local selfBloodSlider = GUI.ImageCreate(selfInfo, "selfBloodSlider", "1800207010", 47, -41)
    guidt.BindName(selfBloodSlider, "roleHp")
    MainUI.SetSliderBasicInfo(selfBloodSlider, silderFillSize)
    local selfBlueSlider = GUI.ImageCreate(selfInfo, "selfBlueSlider", "1800207020", 47, -22)
    guidt.BindName(selfBlueSlider, "roleMp")
    MainUI.SetSliderBasicInfo(selfBlueSlider, silderFillSize)
    local selfYellowSlider = GUI.ImageCreate(selfInfo, "selfYellowSlider", "1800207030", 47, -3)
    guidt.BindName(selfYellowSlider, "roleSp")
    MainUI.SetSliderBasicInfo(selfYellowSlider, silderFillSize)

    if ShowAttrNumber then
        local bloodTxt = GUI.CreateStatic(selfBloodSlider, "bloodTxt", "3200/3200", 0, 0, 200, 30, "system", true, false);
        UILayout.SetAnchorAndPivot(bloodTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(bloodTxt, UIDefine.WhiteColor)
        GUI.StaticSetAlignment(bloodTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(bloodTxt, UIDefine.FontSizeSSS)
        guidt.BindName(bloodTxt, "bloodTxt")
        local blueTxt = GUI.CreateStatic(selfBlueSlider, "blueTxt", "3200/3200", 0, 0, 200, 30, "system", true, false);
        UILayout.SetAnchorAndPivot(blueTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(blueTxt, UIDefine.WhiteColor)
        GUI.StaticSetAlignment(blueTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(blueTxt, UIDefine.FontSizeSSS)
        guidt.BindName(blueTxt, "blueTxt")
        local spTxt = GUI.CreateStatic(selfYellowSlider, "spTxt", "3200/3200", 0, 0, 200, 30, "system", true, false);
        UILayout.SetAnchorAndPivot(spTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(spTxt, UIDefine.WhiteColor)
        GUI.StaticSetAlignment(spTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(spTxt, UIDefine.FontSizeSSS)
        guidt.BindName(spTxt, "spTxt")
    end

    local petInfo = GUI.ImageCreate(panelBg, "petInfo", "1800201040", 0, 0, true)
    local gapX = GUI.GetWidth(selfInfo)
    GUI.SetPositionX(petInfo, -gapX)
    GUI.SetPositionY(petInfo, 0)
    UILayout.SetSameAnchorAndPivot(petInfo, UILayout.TopRight)

    local petInfoIcon = GUI.ImageCreate(petInfo, "petInfoIcon", "1900000000", -40, -2, false)
    guidt.BindName(petInfoIcon, "petIcon")
    GUI.SetWidth(petInfoIcon, 70)
    GUI.SetHeight(petInfoIcon, 70)
    GUI.SetAnchor(petInfoIcon, UIAnchor.Center)
    GUI.SetPivot(petInfoIcon, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(petInfoIcon, true)
    petInfoIcon:RegisterEvent(UCE.PointerClick)
    petInfoIcon:RegisterEvent(UCE.PointerDown)
    petInfoIcon:RegisterEvent(UCE.PointerUp)
    GUI.RegisterUIEvent(petInfoIcon, UCE.PointerClick, "MainUI", "OnPetInfoClick")
    GUI.RegisterUIEvent(petInfoIcon, UCE.PointerDown, "MainUI", "BtnPointDown")
    GUI.RegisterUIEvent(petInfoIcon, UCE.PointerUp, "MainUI", "BtnPointUp")

    local petInfoCover = GUI.ImageCreate(petInfo, "petInfoCover", "1800201030", 0, 0, false,82,80)
    GUI.SetAnchor(petInfoCover, UIAnchor.TopRight)
    GUI.SetPivot(petInfoCover, UIAroundPivot.TopRight)

    local petLevel = GUI.CreateStatic(petInfoCover, "petLevel", "1", -16, -14, 40, 40)
    guidt.BindName(petLevel, "petLv")
    GUI.SetAnchor(petLevel, UIAnchor.BottomLeft)
    GUI.SetPivot(petLevel, UIAroundPivot.Center)
    GUI.StaticSetAlignment(petLevel, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(petLevel, 18)

    local petBloodSlider = GUI.ImageCreate(petInfo, "petBloodSlider", "1800207010", 37, -31)
    guidt.BindName(petBloodSlider, "petHp")
    MainUI.SetSliderBasicInfo(petBloodSlider, silderFillSize)
    local petBlueSlider = GUI.ImageCreate(petInfo, "petBlueSlider", "1800207020", 37, -14)
    guidt.BindName(petBlueSlider, "petMp")
    MainUI.SetSliderBasicInfo(petBlueSlider, silderFillSize)
    local petYellowSlider = GUI.ImageCreate(petInfo, "petYellowSlider", "1800207030", 37, 3)
    guidt.BindName(petYellowSlider, "petSp")
    MainUI.SetSliderBasicInfo(petYellowSlider, silderFillSize)
    if ShowAttrNumber then
        local petBloodTxt = GUI.CreateStatic(petBloodSlider, "petBloodTxt", "3200/3200", 0, 0, 200, 30, "system", true, false);
        UILayout.SetAnchorAndPivot(petBloodTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(petBloodTxt, UIDefine.WhiteColor)
        GUI.StaticSetAlignment(petBloodTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(petBloodTxt, UIDefine.FontSizeSSS)
        guidt.BindName(petBloodTxt, "petBloodTxt")
        local petBlueTxt = GUI.CreateStatic(petBlueSlider, "petBlueTxt", "3200/3200", 0, 0, 200, 30, "system", true, false);
        UILayout.SetAnchorAndPivot(petBlueTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(petBlueTxt, UIDefine.WhiteColor)
        GUI.StaticSetAlignment(petBlueTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(petBlueTxt, UIDefine.FontSizeSSS)
        guidt.BindName(petBlueTxt, "petBlueTxt")
        local petSpTxt = GUI.CreateStatic(petYellowSlider, "petSpTxt", "3200/3200", 0, 0, 200, 30, "system", true, false);
        UILayout.SetAnchorAndPivot(petSpTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetColor(petSpTxt, UIDefine.WhiteColor)
        GUI.StaticSetAlignment(petSpTxt, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(petSpTxt, UIDefine.FontSizeSSS)
        guidt.BindName(petSpTxt, "petSpTxt")
    end
    MainUI.SendNotifiy()
end
function MainUI.SetSliderBasicInfo(Slider, size)
    if Slider ~= nil then
        GUI.ImageSetType(Slider, SpriteType.Filled)
        GUI.SetImageFillMethod(Slider, SpriteFillMethod.Horizontal_Left)
        GUI.SetImageFillAmount(Slider, 0.5)
        UILayout.SetSameAnchorAndPivot(Slider, UILayout.Center)
    end
end
function MainUI.RefreshRightTop()
    local roleIcon = guidt.GetUI("roleIcon")
    local petIcon = guidt.GetUI("petIcon")
    local petLv = guidt.GetUI("petLv")
    local roleLv = guidt.GetUI("roleLv")
    local roleHp = guidt.GetUI("roleHp")
    local petHp = guidt.GetUI("petHp")
    local roleMp = guidt.GetUI("roleMp")
    local petMp = guidt.GetUI("petMp")
    local roleSp = guidt.GetUI("roleSp")
    local petSp = guidt.GetUI("petSp")
    local experience = guidt.GetUI("experience")
    GUI.ImageSetImageID(roleIcon, data.roleIcon)
    HeadIcon.BindRoleVipLv(roleIcon, data.vip)
    GUI.ImageSetImageID(petIcon, data.petIcon)
    GUI.StaticSetText(roleLv, tostring(data.roleLv))
    GUI.StaticSetText(petLv, tostring(data.petLv))
    local t = {
        {ui = roleHp, min = data.roleHp, max = (data.roleHpL), def = 0},
        {ui = petHp, min = (data.petHp), max = (data.petHpL), def = 0},
        {ui = petMp, min = (data.petMp), max = (data.petMpL), def = 0},
        {ui = roleSp, min = (data.roleSp), max = (data.roleSpL), def = 0},
        {ui = roleMp, min = (data.roleMp), max = (data.roleMpL), def = 0},
        {ui = petSp, min = (data.petSp), max = (data.petSpL), def = 0}
    }
    for i = 1, #t do
        if t[i].max > int64.zero then
            local l, h = int64.longtonum2(t[i].min * 100 / t[i].max)
            GUI.SetImageFillAmount(t[i].ui, l / 100)
        else
            GUI.SetImageFillAmount(t[i].ui, t[i].def)
        end
    end
    if ShowAttrNumber then
        local bloodTxt = guidt.GetUI("bloodTxt")
        GUI.StaticSetText(bloodTxt, tostring(data.roleHp))
        local blueTxt = guidt.GetUI("blueTxt")
        GUI.StaticSetText(blueTxt, tostring(data.roleMp))
        local spTxt = guidt.GetUI("spTxt")
        GUI.StaticSetText(spTxt, tostring(data.roleSp))
        GUI.StaticSetText(guidt.GetUI("petBloodTxt"), tostring(data.petHp))
        GUI.StaticSetText(guidt.GetUI("petBlueTxt"), tostring(data.petMp))
        GUI.StaticSetText(guidt.GetUI("petSpTxt"), tostring(data.petSp))
    end
    if data.roleExpL > int64.zero then
        local l, h = int64.longtonum2(data.roleExp * 100 / data.roleExpL)
        local n = math.floor(l / 10)
        local m = l - n * 10
        local w = GUI.GetWidth(GUI.GetChild(experience, "experienceBg1"))
        for i = 1, n do
            local item = GUI.GetChildByPath(experience, "experienceBg"..i .. "/experienceCover")
            if item then
                GUI.SetVisible(item, true)
                GUI.SetWidth(item, w)
            end
        end
        local item = GUI.GetChildByPath(experience, "experienceBg".. (n + 1).. "/experienceCover")
        if item then
            GUI.SetVisible(item, true)
            GUI.SetWidth(item, m / 10 * w)
        end
        for i = n + 2, 11 do
            local item = GUI.GetChildByPath(experience, "experienceBg"..i.. "/experienceCover")
            if item then
                GUI.SetVisible(item, false)
            end
        end
    end
end
--创建小地图面板
function MainUI.CreateMiniMap(panel)
    local map = GUI.GroupCreate(panel, "map", 0, 0, 0, 0)
    GUI.SetAnchor(map, UIAnchor.TopLeft)
    local miniMap = GUI.ButtonCreate(map, "miniMap", "1800201050", 75, 50, Transition.ColorTint, "")
    GUI.SetAnchor(miniMap, UIAnchor.TopLeft)
    GUI.SetPivot(miniMap, UIAroundPivot.Left)
    miniMap:RegisterEvent(UCE.PointerDown)
    miniMap:RegisterEvent(UCE.PointerUp)
    GUI.RegisterUIEvent(miniMap, UCE.PointerClick, "MainUI", "OnMiniMapClick")
    local worldMap = GUI.ButtonCreate(map, "worldMap", "1800201160", 40, 40, Transition.ColorTint, "")
    GUI.SetAnchor(worldMap, UIAnchor.TopLeft)
    GUI.SetPivot(worldMap, UIAroundPivot.Center)
    worldMap:RegisterEvent(UCE.PointerDown)
    worldMap:RegisterEvent(UCE.PointerUp)
    GUI.RegisterUIEvent(worldMap, UCE.PointerClick, "MainUI", "OnWorldMapClick")

    local mapName = GUI.CreateStatic(miniMap, "mapName", "", -5, -12, 150, 30)
    GUI.SetAnchor(mapName, UIAnchor.Center)
    GUI.SetPivot(mapName, UIAroundPivot.Center)
    GUI.StaticSetFontSize(mapName, fontSize)
    GUI.StaticSetAlignment(mapName, TextAnchor.MiddleCenter)
    GUI.SetColor(mapName, colorDark)
    guidt.BindName(mapName, "mapName")

    local hostPos = GUI.CreateStatic(miniMap, "hostPos", "（0，0）", -5, 18, 150, 30)
    GUI.SetAnchor(hostPos, UIAnchor.Center)
    GUI.SetPivot(hostPos, UIAroundPivot.Center)
    GUI.StaticSetAlignment(hostPos, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(hostPos, UIDefine.FontSizeS)
    guidt.BindName(hostPos, "hostPos")
    MainUI.CreateDevice(map)
end

function MainUI.OnMiniMapClick()
    GUI.OpenWnd("MapUI", "1")
end

function MainUI.OnWorldMapClick()
    GUI.OpenWnd("MapUI", "2")
end

function MainUI.Refresh()
    MainUI.RefreshMap()
    MainUI.RefreshRightTop()
end
function MainUI.RefreshMap()
    local mapName = guidt.GetUI("mapName")
    local hostPos = guidt.GetUI("hostPos")
    GUI.StaticSetText(mapName, data.mapName)
    GUI.StaticSetText(hostPos, data.hostPos)
end
function MainUI.CreateDevice(bg)
    -- 电量，
    local batteryBg = GUI.ImageCreate(bg, "batteryBg", "1800208130", 165, 9)
    GUI.SetAnchor(batteryBg, UIAnchor.TopLeft)
    GUI.SetPivot(batteryBg, UIAroundPivot.Center)
    local battery = GUI.ImageCreate(batteryBg, "battery", "1800208131", 0, 0)
    guidt.BindName(battery, "battery")
    UILayout.SetSameAnchorAndPivot(battery, UILayout.Center)
    GUI.ImageSetType(battery, SpriteType.Filled)
    GUI.SetImageFillMethod(battery, SpriteFillMethod.Horizontal_Left)

    --时间，网络
    local timeTxt = GUI.CreateStatic(bg, "timeTxt", TOOLKIT.GetNowTime("HH:mm"), 110, 10, 60, 25)
    GUI.SetAnchor(timeTxt, UIAnchor.TopLeft)
    GUI.SetPivot(timeTxt, UIAroundPivot.Center)
    GUI.StaticSetAlignment(timeTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(timeTxt, 20)
    guidt.BindName(timeTxt, "timeTxt")

    local netSp = GUI.ImageCreate(bg, "netSp", "1800208150", 200, 10)
    GUI.SetAnchor(netSp, UIAnchor.TopLeft)
    GUI.SetPivot(netSp, UIAroundPivot.Center)
    guidt.BindName(netSp, "netSp")
end
function MainUI.RefreshDeviceInfo()
    MainUI.RefreshTime()
    MainUI.RefreshBattery()
    MainUI.RefreshNetSp()
end
function MainUI.RefreshTime()
    local timeTxt = guidt.GetUI("timeTxt")
    data.timeTxt = TOOLKIT.GetNowTime("HH:mm")
    GUI.StaticSetText(timeTxt, data.timeTxt)
end
--目前要求，只显示电量，不用根据电量改颜色
function MainUI.RefreshBattery()
    local battery = guidt.GetUI("battery")
    local level = TOOLKIT.GetBatteryLevel()
    if level == nil or tonumber(level) <= 0 then
        level = 1
    end
    if TOOLKIT.GetBatteryState() == 1 then
        data.batteryState = "1800208132"
        data.batterySlider = 1
    else
        data.batteryState = "1800208131"
        data.batterySlider = level
    end

    GUI.SetImageFillAmount(battery, level)
    GUI.ImageSetImageID(battery, data.batteryState)
end
function MainUI.RefreshNetSp()
    local netSp = guidt.GetUI("netSp")
    --//TODO 获取网络状态
    if true then
        GUI.ImageSetImageID(netSp, "1800208140")
    else
        GUI.ImageSetImageID(netSp, "1800208150")
    end
end

--右下角按钮
function MainUI.CreateRightBottomButton(panel)
    local rightBg = GUI.GroupCreate(panel, "rightBg", -34, -60, 0, 0)
    GUI.SetAnchor(rightBg, UIAnchor.BottomRight)
    GUI.SetPivot(rightBg, UIAroundPivot.Center)
    GUI.SetData(rightBg, "visiable", "false")
    --左侧收放按钮
    local leftBtn = GUI.ImageCreate(panel, "leftBtn", "1800202470", 280, 34, true)
    GUI.SetAnchor(leftBtn, UIAnchor.TopLeft)
    GUI.SetPivot(leftBtn, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(leftBtn, true)
    GUI.RegisterUIEvent(leftBtn, UCE.PointerClick, "MainUI", "RightBtnDoTweenScale")
    GUI.SetEulerAngles(leftBtn, Vector3.New(0, 0, 90))
    GUI.SetVisible(leftBtn, true)

    --GUI.SetColor(rightBg,invisibilityColor)
    local rightBtnBg = GUI.ImageCreate(panel, "rightBtnBg", "1800208260", -40, -60)
    GUI.SetAnchor(rightBtnBg, UIAnchor.BottomRight)
    GUI.SetPivot(rightBtnBg, UIAroundPivot.Center)
    local rightBtn = GUI.ButtonCreate(panel, "rightBtn", "1800208270", -40, -60, Transition.Animation, "", 0, 0, true)
    GUI.SetAnchor(rightBtn, UIAnchor.BottomRight)
    GUI.SetPivot(rightBtn, UIAroundPivot.Center)
    GUI.RegisterUIEvent(rightBtn, UCE.PointerClick, "MainUI", "RightBtnDoTweenScale")

    --左侧按钮背景

    local leftBg = GUI.GroupCreate(panel, "leftBg", 22, 0, 0, 0)
    GUI.SetAnchor(leftBg, UIAnchor.TopLeft)
    GUI.SetPivot(leftBg, UIAroundPivot.Center)

    local leftBg_2 = GUI.ImageCreate(leftBg, "leftBg_Top", "1800499999", 280, 35, true)
    GUI.SetAnchor(leftBg_2, UIAnchor.Center)
    GUI.SetPivot(leftBg_2, UIAroundPivot.Center)

    local leftBg_3 = GUI.ImageCreate(leftBg, "leftBg_NoScale", "1800499999", 280, 114, true)
    GUI.SetAnchor(leftBg_3, UIAnchor.Center)
    GUI.SetPivot(leftBg_3, UIAroundPivot.Center)
    local tmpbtn = {buttonRightBottomLst, buttonLeftTopLst, buttonLeftLst}
    local tmpp = {rightBg, leftBg_2, leftBg_2}
    for key, value in pairs(tmpbtn) do
        local index = 1
        for i = 1, #value do
            local btn =
                GUI.ButtonCreate(tmpp[key], value[i][2], value[i][3], 0, 0, Transition.Animation, "", 0, 0, true)
			guidt.BindName(btn, value[i][2])
            GUI.SetAnchor(btn, UIAnchor.Center)
            GUI.SetPivot(btn, UIAroundPivot.Center)
            btn:RegisterEvent(UCE.PointerUp)
            btn:RegisterEvent(UCE.PointerDown)
            if value[i].OnClick then
                GUI.RegisterUIEvent(btn, UCE.PointerClick, "MainUI", value[i].OnClick)
            else
                GUI.RegisterUIEvent(btn, UCE.PointerClick, "MainUI", "OnBtnClick")
            end
            GUI.RegisterUIEvent(btn, UCE.PointerDown, "MainUI", "BtnPointDown")
            GUI.RegisterUIEvent(btn, UCE.PointerUp, "MainUI", "BtnPointUp")

            if value[i][5] == "0" then
                local txt = GUI.CreateStatic(btn, value[i][2] .. "Txt", value[i][1], 0, 15, 100, 50)
                GUI.StaticSetFontSize(txt, UIDefine.FontSizeS)
                UILayout.SetSameAnchorAndPivot(txt, UILayout.Bottom)
                GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
                GUI.SetIsOutLine(txt, true)
				GUI.SetOutLine_Setting(txt,OutLineSetting.OUTLINE_BROWN6_1)
                GUI.SetOutLine_Color(txt, UIDefine.Brown6Color)
                GUI.SetOutLine_Distance(txt, 1)
                GUI.SetColor(txt, UIDefine.WhiteColor)
            else
                local showIcon = GUI.ImageCreate(btn, value[i][2] .. "Icon", value[i][5], 0, 0, false)
                GUI.SetAnchor(showIcon, UIAnchor.Bottom)
                GUI.SetPivot(showIcon, UIAroundPivot.Bottom)
            end
            if value[i].effect then
                local effect = GUI.SpriteFrameCreate(btn, "effect", "", 0, 0)
                GUI.SetFrameId(effect, value[i].effect)
                UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
                GUI.SpriteFrameSetIsLoop(effect, true)
                GUI.Play(effect)
            end
        end
    end
end
--右下角点击后：收起，btn旋转
function MainUI.RightBtnDoTweenScale(guid, forceClose)
    local bg
    local bg2
    local bg3
    local btn
    local isRight = true
    test("RightBtnDoTweenScale ")
    local keyUI = GUI.GetByGuid(guid)
    local key = GUI.GetName(keyUI)

    if key == "rightBtn" then
        isRight = true
        bg = GUI.Get("MainUI/rightBg")
        btn = GUI.Get("MainUI/rightBtn")
    else
        isRight = false
        bg = GUI.Get("MainUI/leftBg/leftBg_Top")
        -- bg2 = GUI.Get("MainUI/leftBg/leftBg_Top")
        -- bg3 = GUI.Get("MainUI/leftBg/leftBg_NoScale")
        btn = GUI.Get("MainUI/leftBtn")
    end
    if bg == nil or btn == nil then
        return
    end
    local vis = GUI.GetData(bg, "visiable")

    if forceClose then
        if vis ~= "true" then
            if isRight then
                GUI.DOTween(bg, 2)
                GUI.DOTween(btn, 4)
            else
                GUI.DOTween(bg, 2)
                -- GUI.DOTween(bg2, 2)

                -- local tween = CFG.Get_GUITweenInfo("MainUI_LeftBtn")
                -- tween.Tween[0].To = Vector3.New(40, 120, 0)
                -- tween.Tween[0].From = Vector3.New(40, 370, 0)
                -- GUI.DOTween(btn, "MainUI_LeftBtn")

                -- tween = CFG.Get_GUITweenInfo("MainUI_LeftBg3")
                -- tween.Tween[0].From = Vector3.New(280, 114, 0)
                -- tween.Tween[0].To = Vector3.New(280, 35, 0)
                -- GUI.DOTween(bg3, "MainUI_LeftBg3")

                GUI.SetEulerAngles(btn, Vector3.New(0, 0, 270))
            end
            GUI.SetData(bg, "visiable", "true")
        end
        return
    end

    if vis == "true" then
        if isRight then
            GUI.DOTween(bg, "3")
            GUI.DOTween(btn, "5")
        else
            GUI.DOTween(bg, "3")
            -- GUI.DOTween(bg2, "3")

            -- local tween = CFG.Get_GUITweenInfo("MainUI_LeftBtn")
            -- tween.Tween[0].From = Vector3.New(40, 120, 0)
            -- tween.Tween[0].To = Vector3.New(40, MainSysOpen.LeftBtnPositionY, 0)
            -- GUI.DOTween(btn, "MainUI_LeftBtn")

            -- tween = CFG.Get_GUITweenInfo("MainUI_LeftBg3")
            -- tween.Tween[0].From = Vector3.New(280, 35, 0)
            -- tween.Tween[0].To = Vector3.New(280, 114, 0)
            -- GUI.DOTween(bg3, "MainUI_LeftBg3")

            GUI.SetEulerAngles(btn, Vector3.New(0, 0, 90))
        end
        GUI.SetData(bg, "visiable", "false")
    else
        if isRight then
            GUI.DOTween(bg, "2")
            GUI.DOTween(btn, "4")
        else
            GUI.DOTween(bg, "2")
            -- GUI.DOTween(bg2, "2")

            -- local tween = CFG.Get_GUITweenInfo("MainUI_LeftBtn")
            -- local a = tween.Tween[0]
            -- a.To = Vector3.New(40, 120, 0)
            -- a.From = Vector3.New(40, MainSysOpen.LeftBtnPositionY, 0)
            -- tween.Tween[0] = a
            -- GUI.DOTween(btn, tween)

            -- tween = CFG.Get_GUITweenInfo("MainUI_LeftBg3")
            -- local b = tween.Tween[0]
            -- b.From = Vector3.New(280, 114, 0)
            -- b.To = Vector3.New(280, 35, 0)
            -- tween.Tween[0] = b
            -- GUI.DOTween(bg3, tween)

            GUI.SetEulerAngles(btn, Vector3.New(0, 0, 270))
        end
        GUI.SetData(bg, "visiable", "true")
    end
end
function MainUI.OnPromoteClick(guid)
    GUI.OpenWnd("PromoteUI",guid)
end
function MainUI.OnFactionClick()
    local FactionData = LD.GetGuildData()
    if FactionData.guild ~= nil and tostring(FactionData.guild.guid) ~= "0" then
        GUI.OpenWnd("FactionUI")
    else
        GUI.OpenWnd("FactionCreateUI")
    end
end

function MainUI.OnPetInfoClick()
    GUI.OpenWnd("PetUI")
end

function MainUI.OnSelfInfoClick()
    GUI.OpenWnd("RoleAttributeUI")
end

function MainUI.BtnPointDown(guid)
    local btn = GUI.GetByGuid(guid)
    if btn ~= nil then
        MainUI.BtnDoTweenScale(btn, true)
    end
end
function MainUI.BtnPointUp(guid)
    local btn = GUI.GetByGuid(guid)
    if btn ~= nil then
        MainUI.BtnDoTweenScale(btn, false)
    end
end
function MainUI.BtnDoTweenScale(btn, bo)
    if bo then
        GUI.DOTween(btn, "6")
    else
        GUI.DOTween(btn, "7")
    end
end
function MainUI.OnShow(parameter)
    if GUI.GetWnd("MainUI") == nil then
        return
    end
    test("OnShow")

    MainUI.DuringMovieDialog = false
    for i = 1, #event do
        CL.RegisterMessage(event[i][1], event[i][2], event[i][3])
    end
	MainUI.AddMainUIEvt(UIDefine.UIEvent.OnPetLineUpEvt, "MainUI","BindPetData")
	
    GUI.SetVisible(GUI.GetWnd("MainUI"), true)
    for i = 1, #attrT do
        CL.RegisterAttr(attrT[i].enum, MainUI.NotifyRoleData)
    end
    timeCallback.device =
        coroutine.start(
        function()
            while true do
                coroutine.wait(60)
                MainUI.RefreshDeviceInfo()
            end
        end
    )
    MainUI.BindData()
    MainUI.SendNotifiy(UIDefine.UIEvent.OnShowEvt)
end
function MainUI.Exit()
    for i = 1, #attrT do
        CL.UnRegisterAttr(attrT[i].enum, MainUI.NotifyRoleData)
    end
    for i = 1, #event do
        CL.UnRegisterMessage(event[i][1], event[i][2], event[i][3])
    end
	MainUI.RemoveMainUIEvt(UIDefine.UIEvent.OnPetLineUpEvt, "MainUI","BindPetData")
	
    for index, value in ipairs(timeCallback) do
        if value ~= nil then
            coroutine.stop(value)
            timeCallback[index] = nil
        end
    end
    for key, value in pairs(UIDefine.UIEvent) do
        MainUI[value] = {}
    end
end
function MainUI.OnDestroy()
    MainUI.DisableShowRealNameTips()
    MainUI.SendNotifiy(UIDefine.UIEvent.OnDestroyEvt)
    MainUI.Exit()
    MainUI.GemRedPointFlag = false
    MainUI.GuardRedPointFlag = false
end
function MainUI.OnClose()
    MainUI.DisableShowRealNameTips()
    MainUI.SendNotifiy(UIDefine.UIEvent.OnCloseEvt)
    MainUI.Exit()
end
function MainUI.OnMoveEnd()
    if timeCallback.move ~= nil then
        coroutine.stop(timeCallback.move)
        timeCallback.move = nil
    end
    MainUI.BindMapData()
end
function MainUI.GetMapPos()
    while true do
        MainUI.BindMapData()
        --test("GetMapPos")
        coroutine.wait(0.5)
    end
end
function MainUI.OnMoveStart()
    if timeCallback.move == nil then
        timeCallback.move = coroutine.start(MainUI.GetMapPos)
    end
end

function MainUI.BeInvitedJoinYES(param)
    local _sType = string.split(param, ",")
    if #_sType == 2 then
        local _Type = tonumber(_sType[1])
        CL.SendNotify(NOTIFY.TeamOpeUpdate, 1, _Type, 1, _sType[2])
    end
end

function MainUI.BeInvitedJoinNO(param)
    local _sType = string.split(param, ",")
    if #_sType == 2 then
        local _Type = tonumber(_sType[1])
        test("BeInvitedJoinNO : 0")
        CL.SendNotify(NOTIFY.TeamOpeUpdate, 1, _Type, 0, _sType[2])
    end
end

function MainUI.OnTeamInviteOpe(guid)
    local chatPlayer = LD.GetQueryPlayerData()
    local InTeamState = -1
    if chatPlayer and tostring(chatPlayer.guid) == tostring(guid) then
        InTeamState = tonumber(tostring(CL.GetAttribute(chatPlayer.attrs, RoleAttr.RoleAttrTeamStatus)))
    else
        InTeamState = CL.GetIntAttr(RoleAttr.RoleAttrTeamStatus, TOOLKIT.Str2uLong(guid))
    end
    if InTeamState == 3 then
        MainUI.OnApplyJoin(guid)
    else
        MainUI.OnInviteJoin(guid)
    end
end

function MainUI.OnInviteJoin(guid)
    CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "InviteJoin", guid)
end

function MainUI.OnApplyJoin(guid)
    CL.SendNotify(NOTIFY.SubmitForm, "FormTeam", "ApplyJoin", guid)
end

function MainUI.InFight(infight)
    if type(infight) ~= "boolean" then
        return
    end
    local wnd = GUI.GetWnd("MainUI")
    if wnd == nil or GUI.GetVisible(wnd) == false then
        GUI.OpenWnd("MainUI", nil, false)
    end
    isInFight = infight
    isFightView = CL.GetFightViewState()
    MainUI.OnInFightRoleAttrChange()
    test(" MainUI.InFight infight : ", infight)
    if isInFight then
        MainUI.OnPetEscape(CL.GetInfightRoleHp(true) <= 0)
        MainUI.UIManager(true)
        CL.PlayFightBgm("Battle_yewai")
    else
        MainUI.RefreshRightTop()
        local petIcon = guidt.GetUI("petIcon")
        if petIcon then
            GUI.ImageSetGray(petIcon, false)
        end
        MainUI.UIManager(false)
        GlobalUtils.PlayMapBgm()
    end
    MainUI.OnSwitchPetGrazeNode(not isInFight)
end

--负责进出界面的时候UI的显示和隐藏 true 为进战斗  ，false为出战斗
function MainUI.UIManager(needHide)
    local miniMap = GUI.Get("MainUI/miniMap")
    local trackNode = GUI.Get("MainUI/TrackNode")
    local rightBg = GUI.Get("MainUI/rightBg")
    local leftBg = GUI.Get("MainUI/leftBg")
    local leftBtn = GUI.Get("MainUI/leftBtn")
    local rightBtn = GUI.Get("MainUI/rightBtn")
    local rightBtnBg = GUI.Get("MainUI/rightBtnBg")

    local fastPkCover = GUI.Get("MainUI/fastPkTipsCover")
    local fastPKBtnLeft = GUI.Get("MainUI/selfInfo/petInfo/fastPKBtnLeft")
    local moveGroup = GUI.Get("MainUI/moveGroup")
	
    if miniMap then
        GUI.SetVisible(miniMap, not needHide)
    end
    if trackNode then
        GUI.SetVisible(trackNode, not needHide)
    end
    if rightBg then
        GUI.SetVisible(rightBg, not needHide)
    end
    if leftBg then
        GUI.SetVisible(leftBg, not needHide)
    end
    if leftBtn then
        GUI.SetVisible(leftBtn, not needHide)
        --GUI.SetVisible(leftBtn, false)
    end
    if rightBtn then
        GUI.SetVisible(rightBtn, not needHide)
    end
    if rightBtnBg then
        GUI.SetVisible(rightBtnBg, not needHide)
    end
    if fastPkCover then
        GUI.Destroy(fastPkCover)
    end
    if fastPKBtnLeft then
        GUI.SetVisible(fastPKBtnLeft, not needHide)
    end
    if moveGroup then
        GUI.SetVisible(moveGroup, not needHide)
    end
    if needHide then
        GUI.CloseWnd("TrackUI")
    else
        GUI.OpenWnd("TrackUI")
    end
	if CL.GetCurrentMapName() == "武道会" then
		if needHide then
			GUI.CloseWnd("WuDaoHuiUpperTipsUI")
		else
			GUI.OpenWnd("WuDaoHuiUpperTipsUI")
		end 
	end
end


function MainUI.OnInFightRoleAttrChange()
    MainUI.SelfBloodChange()
    MainUI.SelfBlueChange()
    MainUI.SelfSpChange()
end

function MainUI.SelfBloodChange(parameter)
    local currentHp = 0
    local maxHp = 1
    if isInFight and not isFightView then
        currentHp = CL.GetInfightRoleHp()
        maxHp = CL.GetInfightRoleHpMax()
    else
        currentHp = CL.GetIntAttr(RoleAttr.RoleAttrHp)
        maxHp = CL.GetIntAttr(RoleAttr.RoleAttrHpLimit)
    end

    if maxHp ~= 0 then
        GUI.SetImageFillAmount(guidt.GetUI("roleHp"), currentHp / maxHp)
    end
    if ShowAttrNumber then
        local bloodTxt = guidt.GetUI("bloodTxt")
        GUI.StaticSetText(bloodTxt, tostring(currentHp))
    end
end

function MainUI.SelfBlueChange(parameter)
    local currentMp = 0
    local maxMp = 1

    if isInFight and not isFightView then
        currentMp = CL.GetInfightRoleMp()
        maxMp = CL.GetInfightRoleMpMax()
    else
        currentMp = CL.GetIntAttr(RoleAttr.RoleAttrMp)
        maxMp = CL.GetIntAttr(RoleAttr.RoleAttrMpLimit)
    end

    if maxMp ~= 0 then
        GUI.SetImageFillAmount(guidt.GetUI("roleMp"), currentMp / maxMp)
    end
    if ShowAttrNumber then
        local blueTxt = guidt.GetUI("blueTxt")
        GUI.StaticSetText(blueTxt, tostring(currentMp))
    end
end

function MainUI.SelfSpChange(parameter)
    local currentSp = 0
    local maxSp = 1

    if isInFight and not isFightView then
        currentSp = tonumber(tostring(LD.GetFighterAttr(RoleAttr.RoleAttrSp)))
        maxSp = tonumber(tostring(LD.GetFighterAttr(RoleAttr.RoleAttrSpLimit)))
    else
        currentSp = CL.GetIntAttr(RoleAttr.RoleAttrSp)
        maxSp = CL.GetIntAttr(RoleAttr.RoleAttrSpLimit)
    end

    if maxSp ~= 0 then
        GUI.SetImageFillAmount(guidt.GetUI("roleSp"), currentSp / maxSp)
    end
    if ShowAttrNumber then
        local spTxt = guidt.GetUI("spTxt")
        GUI.StaticSetText(spTxt, tostring(currentSp))
    end
end

function MainUI.OnInFightPetAttrChange(isEscaped)
    MainUI.SetPetHP(isEscaped)
    MainUI.SetPetMP(isEscaped)
    MainUI.SetPetSP(isEscaped)
end

function MainUI.SetPetHP(isEscaped)
    local currentHp = 0
    local maxHp = 1
    if isInFight and not isFightView then
		if UIDefine.NowLineupList and UIDefine.NowLineupList[0] ~= "-1" then
			currentHp = CL.GetInfightRoleHp(true)
			maxHp = CL.GetInfightRoleHpMax(true)
		else
			currentHp = tonumber(tostring(data.petHp))
			maxHp = tonumber(tostring(data.petHpL))		
		end
    else
        currentHp = tonumber(tostring(data.petHp))
        maxHp = tonumber(tostring(data.petHpL))
    end

    if maxHp ~= 0 then
        GUI.SetImageFillAmount(guidt.GetUI("petHp"), currentHp / maxHp)
    end
    if ShowAttrNumber then
        GUI.StaticSetText(guidt.GetUI("petBloodTxt"), tostring(currentHp))
    end
end

function MainUI.SetPetMP(isEscaped)
    local currentMp = 0
    local maxMp = 1
    if isInFight and not isFightView then
		if UIDefine.NowLineupList and UIDefine.NowLineupList[0] ~= "-1" then
			currentMp = CL.GetInfightRoleMp(true)
			maxMp = CL.GetInfightRoleMpMax(true)
		else
			currentMp = tonumber(tostring(data.petMp)) 
			maxMp = tonumber(tostring(data.petMpL))
		end
    else
        currentMp = tonumber(tostring(data.petMp)) 
        maxMp = tonumber(tostring(data.petMpL))
    end

    if maxMp ~= 0 then
        GUI.SetImageFillAmount(guidt.GetUI("petMp"), currentMp / maxMp)
    end
    if ShowAttrNumber then
        GUI.StaticSetText(guidt.GetUI("petBlueTxt"), tostring(currentMp))
    end
end

function MainUI.SetPetSP(isEscaped)
    local currentSp = 0
    local maxSp = 1
    if data.petSp == int64.zero then
		if UIDefine.NowLineupList and UIDefine.NowLineupList[0] ~= "-1" then
			local petGuid = GlobalUtils.GetMainLineUpPetGuid()
			currentSp = LD.GetPetIntAttr(RoleAttr.PetAttrClosePoint, petGuid)
			maxSp = 100
		end	
    else
        currentSp = tonumber(tostring(data.petSp))
        maxSp = tonumber(tostring(data.petSpL))
    end

    if maxSp ~= 0 then
        GUI.SetImageFillAmount(guidt.GetUI("petSp"), currentSp / maxSp)
    end
    if ShowAttrNumber then
        GUI.StaticSetText(guidt.GetUI("petSpTxt"), tostring(currentSp))
    end
end

function MainUI.OnPetEscape(isEscaped)
    MainUI.OnInFightPetAttrChange(isEscaped)
    local petIcon = guidt.GetUI("petIcon")
    if petIcon then
        local icon = defaultIcon
        if not isInFight or isFightView then
            if data.petIcon == defaultIcon then
                local petGuid = GlobalUtils.GetMainLineUpPetGuid()
                local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)))
                local petDB = DB.GetOncePetByKey1(petId)
                data.petIcon = petDB.Id ~= 0 and tostring(petDB.Head) or defaultIcon
            end
            icon = data.petIcon
        elseif isInFight then
			local petGuid = CL.GetCurFightPet()
			--判断是否会返回值
			if UIDefine.NowLineupList then
				if UIDefine.NowLineupList[0] ~= "-1" then
					if tostring(petGuid) ~= UIDefine.NowLineupList[0] then
						petGuid = UIDefine.NowLineupList[0]
						isEscaped = true
					else
						isEscaped = false
					end
				else
					petGuid = uint64.zero
				end
			else
				MainUI.PetLineupTimer = Timer.New(MainUI.WaitPetLineup,0.2,-1)
				MainUI.PetLineupTimer:Start()
				MainUI.IsEscaped = isEscaped
			end
            if petGuid == uint64.zero then -- 如果宠物已参战，但是未出场也显示参战宠物头像
                petGuid = GlobalUtils.GetMainLineUpPetGuid()
            end
            local petId = tonumber(tostring(LD.GetPetAttr(RoleAttr.RoleAttrRole, petGuid)))
            local petDB = DB.GetOncePetByKey1(petId)
            icon = petDB.Id ~= 0 and tostring(petDB.Head) or defaultIcon
        end
        GUI.ImageSetImageID(petIcon, icon)
        GUI.ImageSetGray(petIcon, icon ~= defaultIcon and not isFightView and isInFight and isEscaped)
    end
    local petLv = guidt.GetUI("petLv")
    if petLv then
        if data.petLv == int64.zero then
            data.petLv = LD.GetPetAttr(RoleAttr.RoleAttrLevel, GlobalUtils.GetMainLineUpPetGuid())
        end
        GUI.StaticSetText(petLv, tostring(data.petLv))
    end
end

function MainUI.WaitPetLineup()
	if UIDefine.NowLineupList then
		MainUI.PetLineupTimer:Stop()
		MainUI.OnPetEscape(MainUI.IsEscaped)
	end
end

function MainUI.OnBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    local name = GUI.GetName(btn)
    local tmp = {buttonLeftLst, buttonRightBottomLst, buttonLeftTopLst}
    for key, value in pairs(tmp) do
        for i = 1, #value do
            if value[i][2] == name and value[i].index then
                GUI.OpenWnd(value[i][4],value[i].index)
                break
            end
            if value[i][2] == name then
                GUI.OpenWnd(value[i][4])
                break
            end
        end
    end
end

function MainUI.ShowTreasureTip(itemGUID)
    GlobalUtils.ShowBoxMsg("发现宝藏","哇，此地很可能有宝藏...","MainUI","立刻挖","OnTreasureYesBtn","我不要","OnTreasureNoBtn",true,"OnTreasureNoBtn",2,3, false, tostring(itemGUID))
end

function MainUI.OnTreasureYesBtn(itemGUID)
    --中断挖宝
    local func = function()
        CL.SendNotify(NOTIFY.SubmitForm, "FormTreasureMap", "stop_use_TreasureMap", tostring(itemGUID))
    end
    --点击挖宝按钮后，请求开始倒计时读秒
    CL.SendNotify(NOTIFY.SubmitForm, "FormTreasureMap", "use_TreasureMap", tostring(itemGUID))
    GUI.OpenWnd("LoadingTipUI", "3000#宝藏挖掘中...")
    LoadingTipUI.SetInterruptFunc(func)
end

function MainUI.OnMoveToFactionFightingRolePos(param)
    local selfPos = CL.GetRoleClientPos()
    local otherRoleGUID = TOOLKIT.Str2uLong(param)
    local otherPos = CL.GetRoleClientPos(otherRoleGUID)
    if selfPos[0] ~= 0 and selfPos[1] ~= 0 and otherPos[0] ~= 0 and otherPos[1] ~= 0 then
        local distance = math.max(math.abs(selfPos[0]-otherPos[0]), math.abs(selfPos[1]-otherPos[1]))
        if distance <= 8 then
            CL.SendNotify(NOTIFY.SubmitForm, "FormDuel", "GuildBattle_Attack", otherRoleGUID)
        end
    end
end

function MainUI.OnSynTeamSeatInfo()
    if TeamPanelUI then
        TeamPanelUI.UpdateCurSeatInfo()
    end
end

--	Jinken获取按钮
function MainUI.GetBtn(key)
	return guidt.GetUI(key)
end


--从服务器获得按钮开启的等级数据	
function MainUI.RefreshBtnOpenDef()
	for i=1 , #MainUIBtnOpenDef.Data do 
		if MainUI.MainUISwitchConfig[MainUIBtnOpenDef.Data[i].Name] then
			MainUIBtnOpenDef.Data[i].Lv = MainUI.MainUISwitchConfig[MainUIBtnOpenDef.Data[i].Name].OpenLevel
		end
	end
	
	--获得宠物数据
	GlobalProcessing.GetPetEduData()
end

function MainUI.OnLoginWebService(type, status, statusMsg, errMsg, retrySecords)
    --实名认证结果
    if type == 13 then
        --[[
        认证结果v1.44
        1：实名认证中 (需定时调用实名查询接口)
        4:请求账号未被授权
        5：游戏授权异常
        7:该身份证绑定账号数量超限
        9：不存在该用户实名认证记录
        10：签名异常
        11：时间戳过期
        90010:通行证id不能为空
        90011:已通过或在验证中，禁止再次提交
        90012:已通过认证，禁止再次提交
        90013:5分钟内已提交过认证，禁止再次提交
        90020:时间戳不能为空
        90021:上报时间应该与发生时间间隔小于{30}秒
        90030:签名不能为空
        90040:真实姓名不能为空
        90050:身份证号码不能为空
        90041:姓名不能包含数字或字母等特殊字符
        90042:输入的姓名不正确
        90051:身份证不正确
        90052:身份证位数不正确
        ]]--
        local isValid = false
        local validStateLst = {1,90011,90012,90013,90021}
        for i = 1, #validStateLst do
            if validStateLst[i] == status then
                isValid = true
                break
            end
        end
        if isValid then
            local func = function()
                CL.RequestRNAGetAuthResult()
            end
            --延迟1秒查询结果
            Timer.New(func, 1, 1):Start()
        end
    elseif type==12 then
        --[[
        认证查询结果v1.44
        0：已实名认证
        1：实名认证中
        2：实名认证失败
        3：未实名认证
        4:请求账号未被授权
        5：游戏授权异常
        9：不存在该用户实名认证记录
        10：签名异常
        11：时间戳过期
        90010:通行证id不能为空
        90020:时间戳不能为空
        90021:上报时间应该与发生时间间隔小于{30}秒
        90030:签名不能为空
        ]]--
        --1实名认证中，则需要继续查询结果
        if status == 1 then
            --查询结果
            if MainUI.RealNameResultTimer == nil then
                MainUI.RealNameResultTimer = Timer.New(MainUI.RealNameResultListener, 3, 5)
                MainUI.RealNameResultTimer:Start()
            end
        else
            if MainUI.RealNameResultTimer ~= nil then
                MainUI.RealNameResultTimer:Stop()
                MainUI.RealNameResultTimer = nil
            end
        end
        --实名认证成功，则隐藏主按钮
        if status == 0 then
            --这里隐藏按钮
            if AuthRealNameUI then
                GUI.DestroyWnd("AuthRealNameUI")
            end
            if ChatUI then
                ChatUI.ShowRealNameBtn(false)
            end
            MainUI.DisableShowRealNameTips()
            CL.SendNotify(NOTIFY.ShowBBMsg,"恭喜，实名认证成功！")
            LD.SendLocalChatMsg("恭喜，已完成实名认证！")
        else
            if AuthRealNameUI then
                AuthRealNameUI.OnAuthResult(status, statusMsg, errMsg)
            end
        end
    end
end

function MainUI.RealNameResultListener()
    CL.RequestRNAGetAuthResult()
end

function MainUI.OnGuardQueryNtf()
    if not GuardInfoUI then require 'GuardInfoUI' end
    local data = LD.GetQueryGuardData()
    if data then
        -- 将侍从属性插入页面
        GuardInfoUI.set_guard_data(data)
        -- 打开界面
        GUI.OpenWnd('GuardInfoUI')
    end
end

function MainUI.OnFriendListUpdate(contact_type,IsNew,RoleGuid)
    MainUI.FriendListRoleGuid = tostring(RoleGuid)
    if contact_type == CONTACT_TYPE.contact_apply then
        if IsNew == true then
            MainUI.ShowApplyPage()
        end
    end
end

-- 显示请求页面
function MainUI.ShowApplyPage()
    MainUI.InitFriendData(CONTACT_TYPE.contact_apply)
    if #MainUI.CurFriendList == 0 then
        return
    end
    for k, v in pairs(MainUI.CurFriendList) do
        if MainUI.FriendListRoleGuid == tostring(v.guid) then
            local name = tostring(v.name)
            local msg = "玩家<color=#07E8EC>" .. name .. "</color>将加您为好友，您是否也加他为好友？"
            GlobalUtils.ShowBoxMsg(
                    "提示",
                    msg,
                    "MainUI",
                    "接受",
                    "OnClickAgreeBtn",
                    "拒绝",
                    "OnClickRefuseBtn",
                    true,
                    "closeMsg",
                    1,
                    30
            )
            table.insert(RecordRoleGuid,1,tostring(MainUI.FriendListRoleGuid))
        end
    end
end

function MainUI.OnClickAgreeBtn(guid)
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "AcceptApply", tostring(RecordRoleGuid[1])) -- 接受请求
    table.remove(RecordRoleGuid,1)
end

function MainUI.OnClickRefuseBtn()
    CL.SendNotify(NOTIFY.SubmitForm, "FormContact", "RefuseApply", tostring(RecordRoleGuid[1])) -- 拒绝请求
    table.remove(RecordRoleGuid,1)
end

function MainUI.InitFriendData(contact_type)
    MainUI.CurFriendList = {}
    local list = LD.GetContactDataListByType(contact_type)
    if not list then
        return
    end
    for i = 1, list.Count do
        local data = list[i - 1]
        local temp = {
            guid = data.guid,
            contact_type = data.contact_type,
            name = data.name,
            role = data.role,
            level = data.level,
            job = data.job,
            friendship = data.friendship,
            last_contact_time = data.last_contact_time,
            status = data.status,
            vip = data.vip,
            reincarnation = data.reincarnation,
        }
        MainUI.CurFriendList[#MainUI.CurFriendList + 1] = temp
    end
end

function MainUI.OnCloseOtherWndsBesides(wnd)
    if GuideUICloseWndDef.Closed_Other_Wnds_Besides then
        local Count = #GuideUICloseWndDef.Closed_Other_Wnds_Besides
        for i = 1, Count do
            if GuideUICloseWndDef.Closed_Other_Wnds_Besides[i] == wnd then
                --白名单则忽略
                return false
            end
        end
    end
    return true
end

function MainUI.CloseOtherWnds(exceptWnds)
    local openedWndNames = GUI.GetWndNames()
    for i = 0, openedWndNames.Count-1 do
        local find = false
        if exceptWnds then
            for k = 1, #exceptWnds do
                if openedWndNames[i] == exceptWnds[k] then
                    find = true
                    break
                end
            end
        end
        if not find then
            if MainUI.OnCloseOtherWndsBesides(openedWndNames[i]) then
                if openedWndNames[i] == "ChatUI" then
                    --聊天UI只关闭内容面板，而不是整体移除
                    ChatUI.OnCloseBtnClick_ChatBg()
                else
                    GUI.DestroyWnd(openedWndNames[i])
                end
            end
        end
    end
end

--活动开启预告
function MainUI.OpenActivityCheck(param)
    local activityDB=DB.GetActivity(tonumber(param))
    local roleLevel=tonumber(CL.GetIntAttr(RoleAttr.RoleAttrLevel))
    local activityMinLevel=activityDB.LevelMin
    --test("activityMinLevel"..activityMinLevel)
    if roleLevel<activityMinLevel then
        test("等级不足!")
        return
    else
        GUI.OpenWnd("ActivityPreview",param)
    end
end

function MainUI.OnTryDestroyGuideUI()
    local Guide = GUI.GetWnd("GuideUI")
    if Guide and GUI.GetVisible(Guide) then
        MainUI.IsGuideDuringMovieDialog = true
        GUI.DestroyWnd("GuideUI")
    end
end

function MainUI.OnTryOpenGuideUI()
    if MainUI.IsDuringMovieOrDialog() then
        MainUI.IsGuideDuringMovieDialog = true
        --等待剧情或者任务对白结束后再播放
    else
        --直接播放引导
        GUI.OpenWnd("GuideUI")
    end
end

function MainUI.OnMovieDialogFinish(forceShow)
    forceShow = forceShow or false
    if forceShow or not MainUI.IsDuringMovieOrDialog() then
        if MainUI.IsGuideDuringMovieDialog then
            MainUI.IsGuideDuringMovieDialog = false
            GUI.OpenWnd("GuideUI")
        end
    end
end

--是否在剧情中或者在任务对白中
function MainUI.IsDuringMovieOrDialog()
    local npcDialogFullWnd = GUI.GetWnd("NpcDialogFullUI")
    if npcDialogFullWnd and GUI.GetVisible(npcDialogFullWnd) then
        return true
    elseif CL.IsStoryMode() then
        return true
    end
    return false
end

function MainUI.OnRoleModelCreated(roleGuid, roleType)
    if not roleGuid then return end
    if roleGuid == LD.GetSelfGUID() then roleGuid = 0 end
	
	if not UIDefine.IsFunctionOrVariableExist(CL,"CreateOrGetRoleCustomName") or not UIDefine.IsFunctionOrVariableExist(CL,"SetRoleNameVisible") or not UIDefine.IsFunctionOrVariableExist(CL,"RoleGetModelHeight") then
		return
	end
	
	test(tostring(roleType))
    if roleType == tostring(eRoleType.Npc) then
        MainUI.CreateNpcCustomName(roleGuid)

        --区域活动NPC头顶时间
        MainUI.CreateRegionalTaskNpcTime(roleGuid)

    elseif roleType == tostring(eRoleType.Player) then
        MainUI.CreatePlayerCustomName(roleGuid)
		--刷新头顶文字
		MainUI.RefreshStallSigns(roleGuid)
		--刷新摆摊招牌相关
		MainUI.SetStallSignboards(roleGuid)
    end
end

--区域活动NPC头顶时间
function MainUI.CreateRegionalTaskNpcTime(roleGuid)

    MainUI.CreateRegionalTaskNpcTimeItem(roleGuid)

    CL.UnRegisterMessage(GM.CustomDataUpdateReg, "MainUI", "OnRegionalTaskNpcUpdate")

    CL.AddNotifyRoleCustomKey("RegionTask_EscortEndTime")
    CL.AddNotifyRoleCustomKey("RegionTask_TaskProgress")

    CL.RegisterMessage(GM.CustomDataUpdateReg, "MainUI", "OnRegionalTaskNpcUpdate")

end

function MainUI.OnRegionalTaskNpcUpdate(type, k, v, roleGuid)

    if k == "RegionTask_EscortEndTime" then

        MainUI.CreateRegionalTaskNpcTimeItem(roleGuid)

    end

end


--区域活动NPC头顶时间控件
function MainUI.CreateRegionalTaskNpcTimeItem(roleGuid)

    local parent = CL.CreateOrGetRoleCustomName("regionalTask_npc",roleGuid)

    local endTimeBg = GUI.GetChild(parent, "endTimeBg", false)

    local endTime = CL.GetIntCustomData("RegionTask_EscortEndTime",roleGuid)

    local severTime = CL.GetServerTickCount()

    -- 获取角色的ui高度
    local modelHeight = CL.RoleGetModelHeight(roleGuid);
    if modelHeight == 0 then
        test("模型高度获取失败 Todo")
        modelHeight = 200
    end
    local y = -modelHeight - 10

    if MainUI.RegionalTaskNpcTimeConfig == nil then

        MainUI.RegionalTaskNpcTimeConfig = {}

    end

    if endTimeBg == nil then

        if endTime ~= 0 and endTime >= severTime then

            local modelHeight = CL.RoleGetModelHeight(roleGuid);
            if modelHeight == 0 then
                modelHeight = 200
            end

            endTimeBg = GUI.ImageCreate(parent, "endTimeBg", "1801400080", -1, y)
            GUI.SetVisible(endTimeBg,false)
            SetSameAnchorAndPivot(endTimeBg, UILayout.Top)
            local scale = 1.5
            GUI.SetScale(endTimeBg, Vector3.New(scale,scale,scale))--缩放

            local txt = GUI.CreateStatic(endTimeBg, "txt", "00:00", 0, 0, 210, 30)
            SetSameAnchorAndPivot(txt, UILayout.Center)
            GUI.StaticSetFontSize(txt, 22)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)

            MainUI.RegionalTaskNpcTimeConfig[roleGuid] = true

        end


    else

        if endTime == 0 or endTime < severTime then

            MainUI.RegionalTaskNpcTimeConfig[roleGuid] = nil

            GUI.Destroy(endTimeBg)

        else

            MainUI.RegionalTaskNpcTimeConfig[roleGuid] = true
            GUI.SetVisible(endTimeBg,true)

        end

    end


    test("endTime2===============",endTime)

    if MainUI.RegionalTaskNpcTimeConfig ~= nil then

        MainUI.StartRegionalTaskNpcTimer()

    end


end

function MainUI.StartRegionalTaskNpcTimer()
    test("计时器启动")
    local fun = function()
        MainUI.ReturnRegionalTaskNpcTimer()
    end
    MainUI.StopRegionalTaskNpcTimer()
    MainUI.RefreshRegionalTaskNpcTimer = Timer.New(fun, 1, -1)
    MainUI.RefreshRegionalTaskNpcTimer:Start()
end

function MainUI.ReturnRegionalTaskNpcTimer()

    local num = 0

    for k, v in pairs(MainUI.RegionalTaskNpcTimeConfig) do

        local roleGuid = k

        local parent = CL.CreateOrGetRoleCustomName("regionalTask_npc",roleGuid)

        local endTimeBg = GUI.GetChild(parent, "endTimeBg", false)

        if v then

            num = num + 1

            if endTimeBg then

                local endTime = CL.GetIntCustomData("RegionTask_EscortEndTime",roleGuid)

                local severTime = CL.GetServerTickCount()

                local txt = GUI.GetChild(endTimeBg,"txt",false)

                if severTime <= endTime then

                    local remainingTime = endTime - severTime

                    local s_time, day, hour, minute, s = UIDefine.LeftTimeFormatEx(tonumber(endTime))

                    if minute < 10 then
                        minute = "0"..minute
                    end

                    if s < 10 then
                        s = "0"..s
                    end

                    GUI.StaticSetText(txt,minute..":"..s)

                    if remainingTime > 60 then

                        GUI.SetColor(txt,UIDefine.WhiteColor)

                        GUI.SetVisible(endTimeBg,true)

                    elseif remainingTime <= 60 and remainingTime > 0 then

                        GUI.SetColor(txt,UIDefine.RedColor)

                        GUI.SetVisible(endTimeBg,true)

                    else

                        MainUI.RegionalTaskNpcTimeConfig[k] = nil

                        GUI.SetVisible(endTimeBg,false)

                    end

                else

                    MainUI.RegionalTaskNpcTimeConfig[k] = nil

                    GUI.SetVisible(endTimeBg,false)

                end


            end

        end

    end

    if num == 0 then

        MainUI.StopRegionalTaskNpcTimer()

    end

end

--计时器停止
function MainUI.StopRegionalTaskNpcTimer()
    if MainUI.RefreshRegionalTaskNpcTimer ~= nil then
        MainUI.RefreshRegionalTaskNpcTimer:Stop()
        MainUI.RefreshRegionalTaskNpcTimer = nil
    end
end






--跨服战
function MainUI.CreateCrossServerWarfareNpcTop(roleGuid)

    for k, v in pairs(MainUI.LandData) do

        local parent = CL.CreateOrGetRoleCustomName("npcPool_1_1_"..k,k)

        if parent then

            MainUI.SetOrRefreshCrossServerWarfareNpc(parent, k,1)

        end

    end

end

--获得数据
function MainUI.GetCrossServerWarfareNpcData(npcGuid)

    MainUI.OccupyPlanLoopDataTable = {}

    local type = MainUI.LandData[npcGuid].type
    local index = MainUI.LandData[npcGuid].index
    local needP = MainUI.Act_CrossServerData.LandConfig[type][index].NeedP

    for i, v in pairs(MainUI.LandData[npcGuid].rate) do

        local temp = {
            Icon = MainUI.Act_CrossServerData.CampBuff[i].Icon,
            Name = MainUI.Act_CrossServerData.CampBuff[i].Name,
            Rate = v.rate,
            Gear = v.gear,
            Add = v.add,
            npcGuid = tostring(npcGuid),
            NeedP = needP,
        }

        table.insert(MainUI.OccupyPlanLoopDataTable,temp)
    end

end

function MainUI.SetOrRefreshCrossServerWarfareNpc(parent, npcGuid, position)

    local y = 190
    --在上面
    if position == 1 then
        -- 获取角色的ui高度
        local modelHeight = CL.RoleGetModelHeight(npcGuid);
        if modelHeight == 0 then
            test("模型高度获取失败 Todo")
            modelHeight = 200
        end
        y = -modelHeight - 10
        --在下面 --需要重写npc名字
    elseif position == 2 then
        y = 0

        CL.SetRoleNameVisible(false, "GameRoleName", npcGuid);
        local name = CL.GetRoleName(npcGuid)
        local label = GUI.GetChild(parent, "Name",false)

        if label == nil then

            -- 重写npc名字
            label = GUI.CreateStatic(parent, "Name", name, 0, 40, 300, 100)
            GUI.SetEulerAngles(label, Vector3.New(30, 0, 0))
            GUI.SetAnchor(label, UIAnchor.Center)
            GUI.SetPivot(label,  UIAroundPivot.Center)
            GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter);
            GUI.StaticSetFontSize(label, 32);
            GUI.SetColor(label, Color.New(217 / 255, 254 / 255, 35 / 255, 1));
            GUI.SetIsOutLine(label, true);
            GUI.SetOutLine_Color(label, UIDefine.BlackColor);
            GUI.SetOutLine_Distance(label, 1);


        else

            GUI.StaticSetText(label,name)

        end

    end

    local bg = GUI.GetChild(parent, "bg",false)

    MainUI.GetCrossServerWarfareNpcData(npcGuid)

    if bg == nil then


        bg = GUI.ImageCreate(parent, "bg", "1800001200", 0, y, false, 340, 260)
        SetSameAnchorAndPivot(bg, UILayout.Top)

        --local hintBg = GUI.GetChild(bg,"hintBg",false)
        --if hintBg == nil then
        --
        --    hintBg = GUI.ImageCreate(bg, "hintBg", "1800601250", 100, -120)
        --    GUI.SetEulerAngles(hintBg, Vector3.New(0, 180, 0))
        --    SetSameAnchorAndPivot(hintBg, UILayout.Top)
        --
        --end


        local x = 0
        local y = 0
        local width = 160
        local height = 70

        local bgWidth = width * 2
        local bgHeight = math.ceil(#MainUI.OccupyPlanLoopDataTable / 2) * height
        for i = 1, #MainUI.OccupyPlanLoopDataTable do

            local data = MainUI.OccupyPlanLoopDataTable[i]

            local skew = (i - 1) % 2;
            local deep = math.floor((i - 1) / 2);

            x = skew * width + 10
            if (i%2) == 0 then
                x = x + 5
            end

            y = deep * (height + 5) + 10

            local groupBg = GUI.GetChild(bg,"groupBg"..i,false)

            if groupBg == nil then
                groupBg = GUI.ImageCreate(bg, "groupBg"..i, "1800001150", x, y , false, width, height)
                SetSameAnchorAndPivot(groupBg, UILayout.TopLeft)

                local battleArrayIcon = GUI.ItemCtrlCreate(groupBg,"battleArrayIcon","1800700020",5,5,60,60,false,"system",false)
                SetSameAnchorAndPivot(battleArrayIcon, UILayout.TopLeft)
                GUI.ItemCtrlSetElementRect(battleArrayIcon,eItemIconElement.Icon,0,-1,55,55)
                GUI.ItemCtrlSetElementValue(battleArrayIcon,eItemIconElement.Icon,nil)
                GUI.RegisterUIEvent(battleArrayIcon, UCE.PointerClick, "MainUI", "OnBattleArrayIconClick")

                local shelterImg = GUI.ImageCreate(battleArrayIcon, "shelterImg", "1800001240", 0, 1,false,55,55)
                SetSameAnchorAndPivot(shelterImg, UILayout.Top)

                local battleArrayName = GUI.CreateStatic(battleArrayIcon,"battleArrayName","" ,5,-5,240, 40, "101", false, false)
                GUI.StaticSetAlignment(battleArrayName,TextAnchor.MiddleLeft)
                GUI.StaticSetFontSize(battleArrayName,20)
                SetAnchorAndPivot(battleArrayName, UIAnchor.TopRight, UIAroundPivot.TopLeft)
                GUI.SetColor(battleArrayName,UIDefine.Brown4Color)


                local scheduleGroup = GUI.ImageCreate(battleArrayIcon, "scheduleGroup", "1800001060", 5, 25,false,40,40,false)
                GUI.SetVisible(scheduleGroup,false)
                SetAnchorAndPivot(scheduleGroup, UIAnchor.TopRight, UIAroundPivot.TopLeft)

                local scheduleTxt = GUI.CreateStatic(scheduleGroup,"scheduleTxt","???%" ,0,0,120, 30, "101", false, false)
                GUI.StaticSetAlignment(scheduleTxt,TextAnchor.MiddleLeft)
                GUI.StaticSetFontSize(scheduleTxt,20)
                SetAnchorAndPivot(scheduleTxt, UIAnchor.Left, UIAroundPivot.Left)
                GUI.SetColor(scheduleTxt,UIDefine.Brown4Color)


                local addScheduleTxt = GUI.CreateStatic(scheduleTxt,"addScheduleTxt","+???%" ,0,0,120, 30, "101", false, false)
                GUI.StaticSetAlignment(addScheduleTxt,TextAnchor.MiddleLeft)
                GUI.SetVisible(addScheduleTxt,false)
                GUI.StaticSetFontSize(addScheduleTxt,18)
                SetAnchorAndPivot(addScheduleTxt, UIAnchor.Right, UIAroundPivot.Left)
                GUI.SetColor(addScheduleTxt,UIDefine.GreenColor)


                local addY = 0
                for j = 1, 3 do

                    addY = (j - 1) * 7 + 15

                    local scaleValue = 0.5
                    local addImg = GUI.ImageCreate(scheduleGroup, "addImg"..j, "1800607340", 40, addY)
                    GUI.SetEulerAngles(addImg, Vector3.New(0, 0, 180))
                    GUI.SetScale(addImg, Vector3.New(scaleValue, scaleValue, scaleValue))
                    SetAnchorAndPivot(addImg, UIAnchor.TopRight, UIAroundPivot.TopLeft)


                end

                local accomplishTxt = GUI.CreateStatic(battleArrayIcon,"accomplishTxt","已完成" ,5,25,100, 30, "101", false, false)
                GUI.StaticSetAlignment(accomplishTxt,TextAnchor.MiddleLeft)
                GUI.StaticSetFontSize(accomplishTxt,22)
                SetAnchorAndPivot(accomplishTxt, UIAnchor.TopRight, UIAroundPivot.TopLeft)
                GUI.SetColor(accomplishTxt,UIDefine.RedColor)
                GUI.SetVisible(accomplishTxt,false)


            end


        end



        GUI.SetHeight(bg,bgHeight + (math.ceil(#MainUI.OccupyPlanLoopDataTable / 2) +1 ) * 8)
        GUI.SetWidth(bg,bgWidth + 25)

        GUI.SetEulerAngles(bg, Vector3.New(30, 0, 0))
    end

    MainUI.RefreshCrossServerWarfareNpcData(bg)




end

function MainUI.RefreshCrossServerWarfareNpcData(parent)

    local guid = tostring(GUI.GetGuid(parent))
    MainUI.StartCrossServerWarfareTimer(guid)

end

--计时器启动
function MainUI.StartCrossServerWarfareTimer(guid)

    local Guid = guid
    local fun = function()

        MainUI.CrossServerWarfareTimerCallBack(Guid)

    end

    if MainUI.RefreshCrossServerWarfareTimer == nil then

        MainUI.RefreshCrossServerWarfareTimer = {}

    end

    if MainUI.RefreshCrossServerWarfareTimer[guid] == nil then

        MainUI.RefreshCrossServerWarfareTimer[guid] = Timer.New(fun, 0.5, -1)
        MainUI.RefreshCrossServerWarfareTimer[guid]:Start()

    end

end


--计时器调用函数
function MainUI.CrossServerWarfareTimerCallBack(guid)

    local bg = GUI.GetByGuid(guid)

    for i = 1, #MainUI.OccupyPlanLoopDataTable do

        local data = MainUI.OccupyPlanLoopDataTable[i]

        if MainUI.OccupyPlanLoopDataTable[i].Status == nil then

            MainUI.OccupyPlanLoopDataTable[i].Status = 0

        end
        MainUI.OccupyPlanLoopDataTable[i].Status = MainUI.OccupyPlanLoopDataTable[i].Status + 1


        local groupBg = GUI.GetChild(bg,"groupBg"..i,false)

        local battleArrayIcon = GUI.GetChild(groupBg,"battleArrayIcon",false)


        GUI.ItemCtrlSetElementValue(battleArrayIcon,eItemIconElement.Icon,data.Icon)

        local battleArrayName = GUI.GetChild(battleArrayIcon,"battleArrayName",false)
        GUI.StaticSetText(battleArrayName,data.Name)

        local shelterImg = GUI.GetChild(battleArrayIcon,"shelterImg",false)

        if data.Rate < data.NeedP then

            GUI.SetHeight(shelterImg,55*(1 - (data.Rate/data.NeedP)))

        else

            GUI.SetHeight(shelterImg,0)

        end


        local scheduleGroup = GUI.GetChild(battleArrayIcon,"scheduleGroup",false)

        local accomplishTxt = GUI.GetChild(battleArrayIcon,"accomplishTxt",false)



        if data.Rate >= data.NeedP then

            GUI.SetVisible(accomplishTxt,true)
            GUI.SetVisible(scheduleGroup,false)

        else

            GUI.SetVisible(accomplishTxt,false)
            GUI.SetVisible(scheduleGroup,true)

            local scheduleTxt = GUI.GetChild(scheduleGroup,"scheduleTxt",false)

            if data.Add == 0 then

                GUI.StaticSetText(scheduleTxt,(data.Rate/data.NeedP*100).."%")

                for i = 1, 3 do

                    local addImg = GUI.GetChild(scheduleGroup,"addImg"..i,false)


                    GUI.SetVisible(addImg,i <= data.Gear)
                end


            else


                local addScheduleTxt = GUI.GetChild(scheduleTxt,"addScheduleTxt",false)


                if data.Status == 6 then

                    if data.Rate < data.NeedP then

                        GUI.StaticSetText(scheduleTxt,(data.Rate/data.NeedP*100).."%")

                    else

                        GUI.StaticSetText(scheduleTxt,"100%")

                    end


                    MainUI.OccupyPlanLoopDataTable[i].Status = 0


                    for i = 1, 3 do

                        local addImg = GUI.GetChild(scheduleGroup,"addImg"..i,false)


                        GUI.SetVisible(addImg,i <= data.Gear)
                    end

                    MainUI.StopCrossServerWarfareTimer(guid)

                else

                    GUI.StaticSetText(scheduleTxt,((data.Rate-data.Add)/data.NeedP*100).."%")

                    GUI.StaticSetText(addScheduleTxt,"+"..(data.Add/data.NeedP*100).."%")

                    for i = 1, 3 do

                        local addImg = GUI.GetChild(scheduleGroup,"addImg"..i,false)


                        GUI.SetVisible(addImg,false)
                    end


                end

                local desPreferHeight = GUI.StaticGetLabelPreferWidth(scheduleTxt)
                GUI.SetWidth(scheduleTxt,desPreferHeight)

                GUI.SetVisible(addScheduleTxt,data.Status%2 == 1)


            end


        end

    end

end


function MainUI.StopCrossServerWarfareTimer(guid)

    if MainUI.RefreshCrossServerWarfareTimer[guid]~=nil then
        MainUI.RefreshCrossServerWarfareTimer[guid]:Stop()
        MainUI.RefreshCrossServerWarfareTimer[guid] = nil

    end
end


function MainUI.CreateNpcCustomName(roleGuid)
    -- 从特定模板的对象池中获取, 空内容需要重新填充, 存在内容需要修改值
    local params = CL.GetStrCustomData("NPCCustomName",roleGuid)
    if params and params ~= "" then
        local params_tb = string.split(params, "#")
        local position = tonumber(params_tb[1])
        local types = tonumber(params_tb[2])
        local content = tostring(params_tb[3])
    
        local parent = CL.CreateOrGetRoleCustomName("npcPool_"..position.."_"..types.."_"..content,roleGuid)
        if not parent then return end
        if GUI.GetChildCount(parent) > 0 then
            MainUI.RefreshNPCCustomName(parent, roleGuid, position, types, content)
        else
            MainUI.SetNPCCustomName(parent, roleGuid, position, types, content)
        end
    end
        
    -- local name = CL.GetRoleName(roleGuid)
    -- -- local str_test = CL.GetIntCustomData("testint",roleGuid)
    -- -- local str_test = CL.GetStrCustomData("teststring",roleGuid)
    -- -- test("type str_test "..type(str_test))
    -- -- test("str_test "..str_test)
    -- -- if tonumber(str_test) ~= 1 then return end
    -- -- 隐藏npc脚底默认名字
    -- CL.SetRoleNameVisible(false, "GameRoleName", roleGuid);
    -- if GUI.GetChildCount(parent) > 0 then
    --     -- 存在ui, 但可能是别人的, 替换模板中对应的文字和图片
    --     local label = GUI.GetChild(parent, "Name", false)
    --     GUI.StaticSetText(label, "@"..name.."@")
    --     local sprite = GUI.GetChild(parent, "Sprite", false)
    --     GUI.SetFrameId(sprite, "3401300000");
    --     GUI.Play(sprite);
    -- else
    --     -- 重写npc名字
    --     local label = GUI.CreateStatic(parent, "Name","@"..name.."@", 0, 40, 300, 100)
    --     GUI.SetEulerAngles(label, Vector3.New(30, 0, 0))
    --     GUI.SetAnchor(label, UIAnchor.Center)
    --     GUI.SetPivot(label,  UIAroundPivot.Center)
    --     GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter);
    --     GUI.StaticSetFontSize(label, 32);
    --     GUI.SetColor(label, Color.red);
    --     GUI.SetIsOutLine(label, true);
    --     GUI.SetOutLine_Color(label, UIDefine.BlackColor);
    --     GUI.SetOutLine_Distance(label, 1);
    --     -- npc名字上方图片
    --     local sprite = GUI.SpriteFrameCreate(parent, "Sprite", "", 0, 0);
    --     GUI.SetEulerAngles(sprite, Vector3.New(30, 0, 0));
    --     GUI.SetFrameId(sprite, "3401300000");
    --     GUI.Play(sprite);

    -- end
end
function MainUI.CreatePlayerCustomName(roleGuid)    
    -- -- 从特定模板的对象池中获取, 空内容需要重新填充, 存在内容需要修改值
    -- local parent = CL.CreateOrGetRoleCustomName("playerPool",roleGuid)
    -- if not parent then return end
    -- local name = CL.GetRoleName(roleGuid)
    -- -- local str_test = CL.GetIntCustomData("testint",0)
    -- -- test("str_test "..str_test)
    -- if GUI.GetChildCount(parent) > 0 then
    --     -- 存在ui, 但可能是别人的, 替换模板中对应的文字和图片, 重置高度
    --     local modelHeight = CL.RoleGetModelHeight(roleGuid);
    --     local y = -modelHeight - 10
    --     local topImage = GUI.GetChild(parent, "topImage", false)
    --     GUI.SetPositionY(topImage, y);
    --     local topLable = GUI.GetChild(parent, "topLable", false)
    --     GUI.StaticSetText(topLable, name.."的摊位")
    --     GUI.SetPositionY(topLable, y);
    -- else 
    --     -- 获取角色的ui高度
    --     local modelHeight = CL.RoleGetModelHeight(roleGuid);
    --     if modelHeight == 0 then
    --         test("模型高度获取失败 Todo")
    --         modelHeight = 200
    --     end
    --     local y = -modelHeight - 10
    --      -- 创建头顶图片和文字
    --     local topImage = GUI.ImageCreate(parent, "topImage", "1800600010", 0, y, false, 250, 40);
    --     GUI.SetEulerAngles(topImage, Vector3.New(30, 0, 0));

    --     local topLable = GUI.CreateStatic(parent, "topLable", name.."的摊位", 0, y, 250, 40);
    --     GUI.SetEulerAngles(topLable, Vector3.New(30, 0, 0));
    --     GUI.SetAnchor(topLable, UIAnchor.Center);
    --     GUI.SetPivot(topLable, UIAroundPivot.Center);
    --     GUI.StaticSetAlignment(topLable, TextAnchor.MiddleCenter);
    -- end
end

--刷新NPCCustomName
function MainUI.RefreshNPCCustomName(parent, roleGuid, position, types, content)
    if position == 2 then
        -- 隐藏npc脚底默认名字
        CL.SetRoleNameVisible(false, "GameRoleName", roleGuid);
        --刷新重写的名字
        local name = CL.GetRoleName(roleGuid)
        local label = GUI.GetChild(parent, "Name", false)
        GUI.StaticSetText(label, name)
    end
    --文字
    if tyeps == 1 then
        local content_tb = string.split(content, "$")
        local text = content_tb[1]
        local color = content_tb[2]
        local label_color = Color.New(255/255,0/255,0/255,255/255)
        if color then
            local c = string.split(color, ",")
            label_color = Color.New(tonumber(c[1])/255,tonumber(c[2])/255,tonumber(c[3])/255,tonumber(c[4] or 255)/255)
        end

        local label = GUI.GetChild(parent, "CustomName", false)
        GUI.StaticSetText(label, text)
        GUI.SetColor(label, label_color);
    --图片  
    elseif types == 2 then
        local sprite = GUI.GetChild(parent, "Sprite", false)
        GUI.SetFrameId(sprite, content);
        GUI.Play(sprite);
    end
end
--设置NPCCustomName
function MainUI.SetNPCCustomName(parent, roleGuid, position, types, content)
    local y = 190
    --在上面
    if position == 1 then
        -- 获取角色的ui高度
        local modelHeight = CL.RoleGetModelHeight(roleGuid);
        if modelHeight == 0 then
            test("模型高度获取失败 Todo")
            modelHeight = 200
        end
        y = -modelHeight - 10
    --在下面 --需要重写npc名字
    elseif position == 2 then
        y = 0

        CL.SetRoleNameVisible(false, "GameRoleName", roleGuid);
        local name = CL.GetRoleName(roleGuid)
        -- 重写npc名字
        local label = GUI.CreateStatic(parent, "Name", name, 0, 40, 300, 100)
        GUI.SetEulerAngles(label, Vector3.New(30, 0, 0))
        GUI.SetAnchor(label, UIAnchor.Center)
        GUI.SetPivot(label,  UIAroundPivot.Center)
        GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter);
        GUI.StaticSetFontSize(label, 32);
        GUI.SetColor(label, Color.New(217 / 255, 254 / 255, 35 / 255, 1));
        GUI.SetIsOutLine(label, true);
        GUI.SetOutLine_Color(label, UIDefine.BlackColor);
        GUI.SetOutLine_Distance(label, 1);
    end

    --文字
    if types == 1 then
        local content_tb = string.split(content, "$")
        local text = content_tb[1]
        local color = content_tb[2]
        local label_color = Color.New(255/255,0/255,0/255,255/255)
        if color then
            local c = string.split(color, ",")
            label_color = Color.New(tonumber(c[1])/255,tonumber(c[2])/255,tonumber(c[3])/255,tonumber(c[4] or 255)/255)
        end

        local label = GUI.CreateStatic(parent, "CustomName", text, 0, y, 300, 100)
        GUI.SetEulerAngles(label, Vector3.New(30, 0, 0))
        GUI.SetAnchor(label, UIAnchor.Center)
        GUI.SetPivot(label,  UIAroundPivot.Center)
        GUI.StaticSetAlignment(label, TextAnchor.MiddleCenter);
        GUI.StaticSetFontSize(label, 32);
        GUI.SetColor(label, label_color);
        GUI.SetIsOutLine(label, true);
        GUI.SetOutLine_Color(label, UIDefine.BlackColor);
        GUI.SetOutLine_Distance(label, 1);
    --图片
    elseif types == 2 then
        local sprite = GUI.SpriteFrameCreate(parent, "Sprite", "", 0, y);
        test(GUI.GetWidth(sprite))
        GUI.SetEulerAngles(sprite, Vector3.New(30, 0, 0));
        GUI.SetFrameId(sprite, content);
        GUI.Play(sprite);
    end
    return

end

--摆摊相关招牌简介显示
function MainUI.SetStallSignboards(roleGuid)
    local params = CL.GetStrCustomData("Stall_ShopIntroduce",roleGuid)
	-- test(tostring(params).."params")
    if params and params ~= "" then
		print(params)
		local tb = loadstring("return "..params)()
		local parent = CL.CreateOrGetRoleCustomName("playerPool",roleGuid)
		if not parent then return end
		
		GUI.SetIsRaycastTarget(parent, true)
		--隐藏头顶其它内容
		CL.SetRoleNameVisible(false, "GameRoleTop", roleGuid)
		local name = tb[2]
		local introduce = tb[3]
		
		--判断是否准备中
		local status = CL.GetIntCustomData("Stall_Status",roleGuid)
		if status == 1 then
			name = "准备摆摊"
		end
		-- local text_color = Color.New(255/255,0/255,0/255,255/255)
		local modelHeight = CL.RoleGetModelHeight(roleGuid);
		if modelHeight == 0 then
			modelHeight = 200
		end
		if GUI.GetChild(parent, "Boards") then				
			local y = -modelHeight - 10
				
			local Boards = GUI.GetChild(parent, "Boards", false)
			GUI.SetPositionY(Boards, y)
			GUI.RegisterUIEvent(Boards, UCE.PointerClick, "MainUI", "OnStallsBoardClick")
			GUI.SetData(Boards,"RoleGuid",roleGuid)
			GUI.SetData(Boards,"Name",name)
			GUI.ButtonSetText(Boards, name)
			
			--简介
			local IntroduceBg = GUI.GetChild(parent, "IntroduceBg", false)
			GUI.SetPositionY(IntroduceBg, y+80)
			local Introduce = GUI.GetChild(IntroduceBg, "Introduce", false)
			GUI.SetEulerAngles(Introduce, Vector3.New(45, 0, 0))
			GUI.StaticSetText(Introduce,introduce)

			if StallsUI and StallsUI.BrowsedShopList and StallsUI.BrowsedShopList[roleGuid] then
				if StallsUI and StallsUI.AttentionList and StallsUI.AttentionList[roleGuid] then
					-- GUI.ButtonSetTextColor(Boards, UIDefine.BlueColor)
					-- GUI.ButtonSetImageID(Boards, "1800002031")
					GUI.SetColor(Boards,Color.New(253/255,253/255,71/255,255/255))
					GUI.ButtonSetTextColor(Boards, UIDefine.WhiteColor)
				else
					GUI.SetColor(Boards,Color.New(129/255,136/255,132/255,255/255))
					-- GUI.ButtonSetImageID(Boards, "1800002033")
					GUI.ButtonSetTextColor(Boards, UIDefine.BrownColor)
				end
			else
				-- GUI.ButtonSetImageID(Boards, "1800002030")
				GUI.SetColor(Boards,Color.New(255/255,255/255,255/255,255/255))
				GUI.ButtonSetTextColor(Boards, UIDefine.BrownColor)
			end				
			
			GUI.SetVisible(Boards,true)
			GUI.SetVisible(IntroduceBg,true)
		else 
			-- 获取角色的ui高度
			local modelHeight = CL.RoleGetModelHeight(roleGuid);
			local y = -modelHeight - 10
			 -- 创建头顶图片和文字
			local Boards = GUI.ButtonCreate(parent, "Boards", "1800400420", 0, y, Transition.ColorTint, name, 140, 40, false);
			GUI.ButtonSetTextColor(Boards, UIDefine.BrownColor);
			GUI.ButtonSetTextFontSize(Boards, UIDefine.FontSizeM)
			GUI.SetEulerAngles(Boards, Vector3.New(30, 0, 0))
			GUI.RegisterUIEvent(Boards, UCE.PointerClick, "MainUI", "OnStallsBoardClick")
			GUI.SetData(Boards,"RoleGuid",roleGuid)
			GUI.SetData(Boards,"Name",name)
			
			local IntroduceBg = GUI.ImageCreate(parent, "IntroduceBg", "1800200010", 0, y+80, false, 250, 120);
			local Introduce = GUI.CreateStatic(IntroduceBg, "Introduce", introduce, 0, 0, 200, 80)
			GUI.SetColor(Introduce, UIDefine.WhiteColor)
			GUI.StaticSetFontSize(Introduce, UIDefine.FontSizeM)
			UILayout.SetSameAnchorAndPivot(Introduce, UILayout.Center)
			GUI.StaticSetAlignment(Introduce, TextAnchor.UpperLeft)
			GUI.SetEulerAngles(Introduce, Vector3.New(45, 0, 0))

			if StallsUI and StallsUI.BrowsedShopList and StallsUI.BrowsedShopList[roleGuid] then
				if StallsUI and StallsUI.AttentionList and StallsUI.AttentionList[roleGuid] then
					-- GUI.ButtonSetTextColor(Boards, UIDefine.BlueColor)
					-- GUI.ButtonSetImageID(Boards, "1800002031")
					GUI.ButtonSetTextColor(Boards, UIDefine.WhiteColor)
					GUI.SetColor(Boards,Color.New(253/255,253/255,71/255,255/255))
				else
					GUI.SetColor(Boards,Color.New(129/255,136/255,132/255,255/255))
					-- GUI.ButtonSetImageID(Boards, "1800002033")
					GUI.ButtonSetTextColor(Boards, UIDefine.BrownColor)
				end
			else
				-- GUI.ButtonSetImageID(Boards, "1800002030")
				GUI.SetColor(Boards,Color.New(255/255,255/255,255/255,255/255))
				GUI.ButtonSetTextColor(Boards, UIDefine.BrownColor)
			end				
			-- local w = GUI.StaticGetLabelPreferWidth(BoardsLable)
		end
	else
		local parent = CL.CreateOrGetRoleCustomName("playerPool",roleGuid)
		if not parent then return end
		local Boards = GUI.GetChild(parent, "Boards", false)
		local IntroduceBg = GUI.GetChild(parent, "IntroduceBg", false)
		if Boards then
			GUI.SetVisible(Boards,false)
			GUI.SetVisible(IntroduceBg,false)
		end
		CL.SetRoleNameVisible(true, "GameRoleTop", roleGuid)
	end
end


function MainUI.OnStallsBoardClick(guid)
	local RoleGuid = GUI.GetData(GUI.GetByGuid(guid),"RoleGuid")
	if RoleGuid and RoleGuid ~= "" then
		local Name = GUI.GetData(GUI.GetByGuid(guid),"Name")
		MainUI.ShopName = Name
		GUI.OpenWnd("StallsUI",RoleGuid)
	end
end





function MainUI.RefreshStallSigns(roleGuid)
    local params = CL.GetStrCustomData("PlayerStallSigns",roleGuid)
    if params and params ~= "" then
		local parent = CL.CreateOrGetRoleCustomName("playerPool",roleGuid)
		if not parent then return end
		--隐藏头顶其它内容
		CL.SetRoleNameVisible(false, "GameRoleTop", roleGuid)
		local text = params
		local text_color = Color.New(255/255,0/255,0/255,255/255)
		local modelHeight = CL.RoleGetModelHeight(roleGuid);
		if modelHeight == 0 then
			modelHeight = 200
		end
		if GUI.GetChildCount(parent) > 0 then
			--隐藏头顶的
			CL.SetRoleNameVisible(false, "GameRoleTop", roleGuid)
				
			local y = -modelHeight - 10
				
				--头顶文字
			local topLable = GUI.GetChild(parent, "topLable", false)
			GUI.StaticSetText(topLable, text)
			GUI.SetPositionY(topLable, y)
			GUI.SetColor(topLable, text_color)
				
			local w = GUI.StaticGetLabelPreferWidth(topLable)
				
			GUI.SetWidth(topLable,w)
			--文字背景图片（暂客户端写死）
			local topImage = GUI.GetChild(parent, "topImage", false)
			GUI.SetPositionY(topImage, y)
			GUI.SetWidth(topImage,w+40)
				
			GUI.SetVisible(topImage,true)
			GUI.SetVisible(topLable,true)
		else 
			-- 获取角色的ui高度
			local modelHeight = CL.RoleGetModelHeight(roleGuid);
			local y = -modelHeight - 10
			 -- 创建头顶图片和文字
			local topImage = GUI.ImageCreate(parent, "topImage", "1800600010", 0, y, false, 250, 40);
			GUI.SetEulerAngles(topImage, Vector3.New(30, 0, 0))

			local topLable = GUI.RichEditCreate(parent, "topLable", text, 0, y, 250, 40);
			GUI.SetEulerAngles(topLable, Vector3.New(30, 0, 0));
			GUI.SetAnchor(topLable, UIAnchor.Center);
			GUI.SetPivot(topLable, UIAroundPivot.Center);
			GUI.StaticSetAlignment(topLable, TextAnchor.MiddleCenter)
			GUI.StaticSetFontSize(topLable,22)
			GUI.SetColor(topLable, text_color)
				
			local w = GUI.StaticGetLabelPreferWidth(topLable)
			GUI.SetWidth(topLable,w)
				
			GUI.SetWidth(topImage,w+40)
		end
	else
		local parent = CL.CreateOrGetRoleCustomName("playerPool",roleGuid)
		if not parent then return end
		local topLable = GUI.GetChild(parent, "topLable", false)
		if topLable then
			GUI.SetVisible(topLable,false)
		end
		local topImage = GUI.GetChild(parent, "topImage", false)
		if topImage then
			GUI.SetVisible(topImage,false)
		end
		CL.SetRoleNameVisible(true, "GameRoleTop", roleGuid)
	end
end


--连线特效注册
function MainUI.LinkEffectRegiste(effect_table)
    CL.InitRoleLineStyleTable(jsonUtil.encode(effect_table))
end