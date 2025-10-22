local TimeDownUI = {}

_G.TimeDownUI = TimeDownUI
local GuidCacheUtil = nil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
-- 负责倒计时和回合数的显示
local waitLableColor = Color.New(248 / 255, 244 / 255, 221 / 255, 255 / 255)
local colorGreen = Color.New(46 / 255, 218 / 255, 0 / 255, 255 / 255)
local colorDefault = Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255)
local colorRed = Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local fontColorGreen = "2EDA00"
local fontColorRed = "FF0000"
local isFightView = false

local InitBoss = function()
    return  {
    guid = 0,head = "", hp = 0,maxHp =0
    }
end
local bossdata = InitBoss()
function TimeDownUI.Main(parameter)
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local parentPanel = GUI.WndCreateWnd("TimeDownUI", "TimeDownUI", 0, 0, eCanvasGroup.FrontOfTheScene)
    SetAnchorAndPivot(parentPanel, UIAnchor.Center, UIAroundPivot.Center)
    TimeDownUI.CreateBossGroup(parentPanel)
    local parentLableBg = GUI.ImageCreate(parentPanel, "parentLableBg", "1800300010", 0, 100)
    GuidCacheUtil.BindName(parentLableBg, "parentLableBg")
    SetAnchorAndPivot(parentLableBg, UIAnchor.Top, UIAroundPivot.Center)
    local parentLable = GUI.CreateStatic(parentLableBg, "parentLable", "", 0, 0)
    GuidCacheUtil.BindName(parentLable, "parentLable")
    GUI.StaticSetFontSize(parentLable, 34)
    SetAnchorAndPivot(parentLable, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(parentLable, TextAnchor.MiddleCenter)
    GUI.SetColor(parentLable, waitLableColor)

    local waitSp = GUI.ImageCreate(parentPanel, "waitSp", "1800304040", 0, 100)
    GuidCacheUtil.BindName(waitSp, "waitSp")
    SetAnchorAndPivot(waitSp, UIAnchor.Top, UIAroundPivot.Center)
    GUI.SetVisible(waitSp, false)

    --回合数显示，最大支持 3 位， 999 回合 
    local turnCountBg = GUI.ImageCreate(parentPanel, "turnCountBg", "1800301010", 0, -GUI.GetHeight(parentPanel) / 2)
    SetAnchorAndPivot(turnCountBg, UIAnchor.Center, UIAroundPivot.Top)
    for i = 0, 2 do
        local tempNumSp = GUI.ImageCreate(turnCountBg, "turnCount" .. i, "1900505011", 0, 0)
        SetAnchorAndPivot(tempNumSp, UIAnchor.Center, UIAroundPivot.Center)
        GUI.SetVisible(tempNumSp, false)
    end
    TimeDownUI.SetTurnCount(1) --初始化回合数

    local timeDownSpriteFrame1 = GUI.SpriteFrameCreate(parentLable, "timeDownSpriteFrame1", "190051", 0, 0)
    local timeDownSpriteFrame2 = GUI.SpriteFrameCreate(parentLable, "timeDownSpriteFrame2", "190051", 0, 0)
    GUI.Stop(timeDownSpriteFrame1)
    GUI.Stop(timeDownSpriteFrame2)
    GUI.SetVisible(timeDownSpriteFrame1, false)
    GUI.SetVisible(timeDownSpriteFrame2, false)

    local enemySeatIcon = GUI.ImageCreate(parentPanel, "enemySeatIcon", "1800302190", -90, 40, false, 70, 70)
    SetAnchorAndPivot(enemySeatIcon, UIAnchor.Top, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(enemySeatIcon, true)
    enemySeatIcon:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(enemySeatIcon, UCE.PointerClick, "TimeDownUI", "OnSeatIconCllick")
    GUI.SetVisible(enemySeatIcon, false)

    local selfSeatIcon = GUI.ImageCreate(parentPanel, "selfSeatIcon", "1800302190", 90, 40, false, 70, 70)
    SetAnchorAndPivot(selfSeatIcon, UIAnchor.Top, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(selfSeatIcon, true)
    selfSeatIcon:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(selfSeatIcon, UCE.PointerClick, "TimeDownUI", "OnSeatIconCllick")
    GUI.SetVisible(selfSeatIcon, false)

    local groupName = "lianXuTiaoZhanGroup"
    local lianXuTiaoZhanGroup = GUI.GroupCreate(parentPanel, groupName, -150, 0, 0, 0)
    GuidCacheUtil.BindName(lianXuTiaoZhanGroup, groupName)
    SetAnchorAndPivot(lianXuTiaoZhanGroup, UIAnchor.Top, UIAroundPivot.Center)

    local lianXuTiaoZhanBg1 = GUI.ImageCreate(lianXuTiaoZhanGroup, "lianXuTiaoZhanBg1", "1801405160", -150, 40)
    SetAnchorAndPivot(lianXuTiaoZhanBg1, UIAnchor.Center, UIAroundPivot.Center)
    local lianXuTiaoZhanBg3 = GUI.ImageCreate(lianXuTiaoZhanGroup, "lianXuTiaoZhanBg3", "1801405210", -55, 40)
    SetAnchorAndPivot(lianXuTiaoZhanBg3, UIAnchor.Center, UIAroundPivot.Center)

    local lianXuTiaoZhanBg2 = GUI.ImageCreate(lianXuTiaoZhanGroup, "lianXuTiaoZhanBg2", "1801405170", -90, 40)
    SetAnchorAndPivot(lianXuTiaoZhanBg2, UIAnchor.Center, UIAroundPivot.Center)

    local lianXuTiaoZhanNum1 = GUI.ImageCreate(lianXuTiaoZhanGroup, "lianXuTiaoZhanNum1", "1900505170", -90, 40)
    SetAnchorAndPivot(lianXuTiaoZhanNum1, UIAnchor.Center, UIAroundPivot.Center)
    local lianXuTiaoZhanNum2 = GUI.ImageCreate(lianXuTiaoZhanGroup, "lianXuTiaoZhanNum2", "1900505170", -90, 40)
    SetAnchorAndPivot(lianXuTiaoZhanNum2, UIAnchor.Center, UIAroundPivot.Center)
    local lianXuTiaoZhanNum3 = GUI.ImageCreate(lianXuTiaoZhanGroup, "lianXuTiaoZhanNum3", "1900505170", -90, 40)
    SetAnchorAndPivot(lianXuTiaoZhanNum3, UIAnchor.Center, UIAroundPivot.Center)

    TimeDownUI.StartTimeDown(0, 30)

    -- 注册事件
    CL.RegisterMessage(GM.FightTurnRefresh, "TimeDownUI", "SetTurnCount")  -- 回合数刷新
    CL.RegisterMessage(GM.FightTimeCountDown, "TimeDownUI", "StartTimeDown")  -- 倒计时刷新
    --CL.RegisterMessage(GM.ShowTimeCountDown,"TimeDownUI" , "SetTimeDownVisible")
    CL.RegisterMessage(GM.FightIsInActor, "TimeDownUI", "SetIsInActor")
    CL.RegisterMessage(GM.FightSeatIdChange,"TimeDownUI" , "SetSeatIcon")
    --CL.RegisterMessage(GM.WorldBossHPChange,"TimeDownUI" , "WorldBossHPChange")
    CL.RegisterMessage(GM.FightStateNtf, "TimeDownUI", "InFight")

    GUI.SetVisible(parentPanel, false)
    TimeDownUI.SetLianXuTiaoZhanVisible(false)
end

function TimeDownUI.OnShow(parameter)
    local inFightState = CL.GetFightState()
    isFightView = CL.GetFightViewState()
    -- if inFightState then
    TimeDownUI.InFight(inFightState or isFightView)
    -- end
end

function TimeDownUI.OnClose()

end

function TimeDownUI.CreateSeatPanel()
    local wnd = GUI.GetWnd("FightUI")
    local preCover = GUI.GetChild(wnd, "seatInfoCoverBg")
    if preCover ~= nil then
        GUI.Destroy(preCover)
    end
    local coverBg = GUI.ImageCreate(wnd, "seatInfoCoverBg", "1800499999", 0, 0, false, GUI.GetWidth(wnd), GUI.GetHeight(wnd))
    SetAnchorAndPivot(coverBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(coverBg, true)
    coverBg:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(coverBg, UCE.PointerClick, "TimeDownUI", "OnCoverCllick")
    GUI.SetDepth(coverBg, 100)

    local seatInfoBg = GUI.ImageCreate(coverBg, "seatInfoBg", "1800400290", 0, -110, false, 400, 350)
    SetAnchorAndPivot(seatInfoBg, UIAnchor.Center, UIAroundPivot.Center)

    local seatName = GUI.CreateStatic(seatInfoBg, "seatName", "", 0, -150, 300, 30, "system", true)
    TimeDownUI.SetTextBasicInfo(seatName, colorGreen, TextAnchor.MiddleLeft, 22)
    local des = GUI.CreateStatic(seatInfoBg, "des", "", 0, -110, 300, 30, "system", true)
    TimeDownUI.SetTextBasicInfo(des, colorGreen, TextAnchor.MiddleCenter, 22)

    local w, h = 100, 30
    local label_1 = GUI.CreateStatic(seatInfoBg, "label_1", "1号位：", -130, -70, w, h)
    TimeDownUI.SetTextBasicInfo(label_1, colorDefault, TextAnchor.MiddleLeft, 22)
    label_1 = GUI.CreateStatic(seatInfoBg, "label_2", "2号位：", -130, -20, w, h)
    TimeDownUI.SetTextBasicInfo(label_1, colorDefault, TextAnchor.MiddleLeft, 22)
    label_1 = GUI.CreateStatic(seatInfoBg, "label_3", "3号位：", -130, 30, w, h)
    TimeDownUI.SetTextBasicInfo(label_1, colorDefault, TextAnchor.MiddleLeft, 22)
    label_1 = GUI.CreateStatic(seatInfoBg, "label_4", "4号位：", -130, 80, w, h)
    TimeDownUI.SetTextBasicInfo(label_1, colorDefault, TextAnchor.MiddleLeft, 22)
    label_1 = GUI.CreateStatic(seatInfoBg, "label_5", "5号位：", -130, 130, w, h)
    TimeDownUI.SetTextBasicInfo(label_1, colorDefault, TextAnchor.MiddleLeft, 22)

    local des_1 = GUI.CreateStatic(seatInfoBg, "des_1", "", 50, -70, 280, 26, "system", true, false)
    TimeDownUI.SetTextBasicInfo(des_1, colorDefault, TextAnchor.MiddleLeft, 22)
    des_1 = GUI.CreateStatic(seatInfoBg, "des_2", "", 50, -20, 280, 26, "system", true, false)
    TimeDownUI.SetTextBasicInfo(des_1, colorDefault, TextAnchor.MiddleLeft, 22)
    des_1 = GUI.CreateStatic(seatInfoBg, "des_3", "", 50, 30, 280, 26, "system", true, false)
    TimeDownUI.SetTextBasicInfo(des_1, colorDefault, TextAnchor.MiddleLeft, 22)
    des_1 = GUI.CreateStatic(seatInfoBg, "des_4", "", 50, 80, 280, 26, "system", true, false)
    TimeDownUI.SetTextBasicInfo(des_1, colorDefault, TextAnchor.MiddleLeft, 22)
    des_1 = GUI.CreateStatic(seatInfoBg, "des_5", "", 50, 130, 280, 26, "system", true, false)
    TimeDownUI.SetTextBasicInfo(des_1, colorDefault, TextAnchor.MiddleLeft, 22)
end

function TimeDownUI.CreateBossGroup(panel)
    local BossGroup = GUI.GroupCreate(panel, "BossGroup", 0, 0, GUI.GetWidth(panel), GUI.GetHeight(panel))
    local hpBar = GUI.ScrollBarCreate(BossGroup, "hpBar", "", "1800601330", "1800601340", -16, 105, 400, 35, 1, false, Transition.None, 0, 1, Direction.RightToLeft, false)
    SetAnchorAndPivot(hpBar, UIAnchor.Top, UIAroundPivot.Center)
    GUI.ScrollBarSetFillSize(hpBar, Vector2.New(400, 35))
    GUI.ScrollBarSetBgSize(hpBar, Vector2.New(400, 35))

    local hpText = GUI.CreateStatic(hpBar, "hpText", "99999/99999", 0, 0, 400, 35, "system", true)
    GUI.StaticSetFontSize(hpText, 20)
    GUI.SetColor(hpText, colorWhite)
    GUI.StaticSetAlignment(hpText, TextAnchor.MiddleCenter)
    SetAnchorAndPivot(hpText, UIAnchor.Center, UIAroundPivot.Center)

    local iconBg = GUI.ImageCreate(BossGroup, "iconBg", "1800201110", 220, 88, false, 80, 80)
    SetAnchorAndPivot(iconBg, UIAnchor.Top, UIAroundPivot.Center)

    local icon = GUI.ImageCreate(iconBg, "icon", "1900351610", 0, 0, false, 70, 70)
    SetAnchorAndPivot(icon, UIAnchor.Center, UIAroundPivot.Center)

    GUI.SetVisible(BossGroup, false)
end

function TimeDownUI.WorldBossHPChange(bossHead, curHp, maxHp)
    local BossGroup = GUI.Get("TimeDownUI/BossGroup")
    local hpBar = GUI.GetChild(BossGroup, "hpBar")
    local hpText = GUI.GetChild(hpBar, "hpText")
    local iconBg = GUI.GetChild(BossGroup, "iconBg")
    local icon = GUI.GetChild(iconBg, "icon")
    test("set bossHead ",bossHead )
    GUI.ImageSetImageID(icon, bossHead)
    GUI.StaticSetText(hpText, (curHp) .. "/" ..(maxHp))
    GUI.ScrollBarSetPos(hpBar,curHp / maxHp)
    if curHp == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg,"活动结束或BOSS已被击杀")
    end
end
function TimeDownUI.NotifyRoleData(attrType, value)
    -- value = tonumber(tostring(value))
    local h = 0
    if attrType == RoleAttr.RoleAttrHp then
		if TimeDownUI.IsBoosGroup then
			TimeDownUI.SetBossGroupHpAttr()
		else
			bossdata.hp,h=int64.longtonum2(value)
		end
        if bossdata.maxHp>0 then
            TimeDownUI.WorldBossHPChange(bossdata.head, bossdata.hp, bossdata.maxHp)
        end
    elseif attrType == RoleAttr.RoleAttrHpLimit then
		if TimeDownUI.IsBoosGroup then
			TimeDownUI.SetBossGroupHpAttr()
		else
			bossdata.maxHp,h=int64.longtonum2(value)
		end
        TimeDownUI.WorldBossHPChange(bossdata.head, bossdata.hp, bossdata.maxHp)
    end

    MainUI.RefreshRightTop()
end
function TimeDownUI.SetBossGuid(bossguid,bosshead,HpLimit)
    test("TimeDownUI.SetBossGuid")
	local BossGroup =  GUI.Get("TimeDownUI/BossGroup")
	bossdata.head= bosshead
	--判断是否为怪物组guid
	local tb = string.split(tostring(bossguid), "_")
	if #tb < 2 then
		bossdata.guid = int64.new(bossguid)
		TimeDownUI.IsBoosGroup = false
		local getfun = rawget(LD,"GetFighterAttr")
		local h
		if getfun then
			bossdata.hp,h=int64.longtonum2(getfun(RoleAttr.RoleAttrHp,bossguid))
			bossdata.maxHp,h=int64.longtonum2(getfun(RoleAttr.RoleAttrHpLimit,bossguid))
		end
		local fun =  rawget(LD,"RegisterFighterAttr")
		if fun then
			fun(RoleAttr.RoleAttrHp,TimeDownUI.NotifyRoleData,bossguid)
			fun(RoleAttr.RoleAttrHpLimit,TimeDownUI.NotifyRoleData,bossguid)
			GUI.SetVisible(BossGroup,true)
			TimeDownUI.WorldBossHPChange(bossdata.head, bossdata.hp, bossdata.maxHp)
		else
		   GUI.SetVisible(BossGroup,false) 
		end
	else
		bossdata.guid = bossguid
		TimeDownUI.IsBoosGroup = true
		TimeDownUI.SetBossGroupHpAttr()
		bossdata.maxHp = HpLimit or 1
		local fun =  rawget(LD,"RegisterFighterAttr")
		if fun then
			for i = 1 ,#tb do
				if tb[i] ~= "" then
					fun(RoleAttr.RoleAttrHp,TimeDownUI.NotifyRoleData,uint64.new(tb[i]))
					-- if not HpLimit then
						-- fun(RoleAttr.RoleAttrHpLimit,TimeDownUI.NotifyRoleData,uint64.new(tb[i]))
					-- end
				end
			end
			GUI.SetVisible(BossGroup,true)
			TimeDownUI.WorldBossHPChange(bossdata.head, bossdata.hp, bossdata.maxHp)
		else
		   GUI.SetVisible(BossGroup,false) 
		end	
	end
end

function TimeDownUI.SetBossGroupHpAttr()
	local tb = string.split(tostring(bossdata.guid), "_")
	local getfun = rawget(LD,"GetFighterAttr")
	local h
	local temp1
	local temp2
	local hp = 0
	-- local maxHp = 0
	if getfun then
		for i = 1 ,#tb do
			if tb[i] ~= "" then
				temp1,h=int64.longtonum2(getfun(RoleAttr.RoleAttrHp,uint64.new(tb[i])))
				-- temp2,h=int64.longtonum2(getfun(RoleAttr.RoleAttrHpLimit,uint64.new(tb[i])))
				
				hp = hp + temp1
				-- maxHp = maxHp + temp2
			end
		end
	end
	bossdata.hp = hp
	-- bossdata.maxHp = maxHp	
end
function TimeDownUI.InFight(isInfight)
    local wnd = GUI.GetWnd("TimeDownUI")
    if wnd == nil then
        return
    end
    if type(isInfight) ~= "boolean" then
        return
    end
    if isInfight then
        bossdata = InitBoss()
    	--if CL.IsWorldBossFight() then
    	--
    	--else
    	--	local BossGroup =  GUI.Get("TimeDownUI/BossGroup")
    	--	GUI.SetVisible(BossGroup,false)
    	--end
    else
    	local BossGroup =  GUI.Get("TimeDownUI/BossGroup")
    	GUI.SetVisible(BossGroup,false)
    	-- TimeDownUI.SetLianXuTiaoZhanVisible(false)
    end

    TimeDownUI.SetTurnCount(1) --初始化回合数
    GUI.SetVisible(wnd, isInfight)
    TimeDownUI.OnCoverCllick()
end


--回合数显示
function TimeDownUI.SetTurnCount(turns)
    local turnCountBg = GUI.Get("TimeDownUI/turnCountBg")
    local values = TOOLKIT.ObjectToString(turns)
    for i = 0, 2 do
        local tempsp = GUI.GetChild(turnCountBg, "turnCount" .. i)
        if tempsp ~= nil then
            GUI.SetVisible(tempsp, false)
        end
    end
    local offsetX = 0
    local len = string.len(values)
    if len == 2 then
        offsetX = 14
    elseif len == 3 then
        offsetX = 28
    end
    for i = 1, len do
        local tempTurn = string.char(string.byte(values, i))
        local tempsp = GUI.GetChild(turnCountBg, "turnCount" .. (i - 1))
        if tempsp ~= nil then
            GUI.ImageSetImageID(tempsp, "190050501" .. tempTurn)
            GUI.SetPositionX(tempsp, -offsetX + 28 * (i - 1))
            GUI.SetVisible(tempsp, true)
        end
    end
end

--倒计时的显示  valueType,0为倒计时，1为其他字符串 ，后面跟字符串的ID
function TimeDownUI.StartTimeDown(valueType, str)
    local parentLableBg = GuidCacheUtil.GetUI("parentLableBg")
    local waitSp = GuidCacheUtil.GetUI("waitSp")
    if isFightView then
        -- 观战中不显示倒计时和请等待
        GUI.SetVisible(parentLableBg, false)
        GUI.SetVisible(waitSp, false)
        return
    end

    local parentLable = GuidCacheUtil.GetUI("parentLable")
    local timeSf1 = GUI.GetChild(parentLable, "timeDownSpriteFrame1")
    local timeSf2 = GUI.GetChild(parentLable, "timeDownSpriteFrame2")
    local values = TOOLKIT.ObjectToString(str)
    if tonumber(valueType) == 0 then
        GUI.SetVisible(parentLableBg, true)
        GUI.SetVisible(waitSp, false)
        if tonumber(str) == 0 then
            TimeDownUI.SetIsInActor(true)
            return
        end
        local offsetX = 0
        local len = string.len(values)
        if len == 2 then
            offsetX = 28
            GUI.SetVisible(timeSf1, true)
            GUI.SetVisible(timeSf2, true)
        else
            GUI.SetVisible(timeSf1, true)
            GUI.SetVisible(timeSf2, false)
        end
        for i = 1, len do
            local tempTime = string.char(string.byte(values, i))
            local timeSf = GUI.GetChild(parentLable, "timeDownSpriteFrame" .. i)
            if timeSf ~= nil then
                GUI.SetFrameId(timeSf, "190050500" .. tempTime)
                GUI.SetPositionX(timeSf, -offsetX + 56 * (i - 1))
            end
        end
    elseif tonumber(valueType) == 1 then
        --这里读表，根据ID显示字符串
        local strs = "请等待"
        --GUI.StaticSetText(waitLable,strs)
        GUI.SetVisible(waitSp, true)
        GUI.SetVisible(parentLableBg, false)
        GUI.SetVisible(timeSf1, false)
        GUI.SetVisible(timeSf2, false)
    end
end
--隐藏倒计时，包括其用于显示“请等待”等的父物体
function TimeDownUI.SetTimeDownVisible(canSee)
    local parentLable = GuidCacheUtil.GetUI("parentLable")
    if parentLable ~= nil then
        GUI.StaticSetText(parentLable, "")
    end
end

-- 是否处于表演状态 
function TimeDownUI.SetIsInActor(isInActor)
    if type(isInActor) ~= "boolean" then
        return
    end
    --表演状态隐藏
    local parentLableBg = GuidCacheUtil.GetUI("parentLableBg")
    if isFightView then
        -- 观战状态不用倒计时
        GUI.SetVisible(parentLableBg, false)
        return
    end
    local waitSp = GuidCacheUtil.GetUI("waitSp")
    GUI.SetVisible(waitSp, false)
    if isInActor then
        local isinAutoFight = CL.OnGetAutoFightState()
        if isinAutoFight then
            TimeDownUI.StartTimeDown(0, 3)
        else
            TimeDownUI.StartTimeDown(0, 30)
        end
    end
    GUI.SetVisible(parentLableBg, not isInActor)
end

--设置阵法图标 
function TimeDownUI.SetSeatIcon(selfSeatId, enemySeatID, ourLineupLv, enemyLineupLv)
    local selfSeatIcon = GUI.Get("TimeDownUI/selfSeatIcon")
    local enemySeatIcon = GUI.Get("TimeDownUI/enemySeatIcon")
    if selfSeatId ~= nil and selfSeatId > 0 then
        local seat = DB.GetOnceSeatByKey1(selfSeatId)--CL.GetSeatByLineUpId(selfSeatId)
        if seat ~= nil then
            GUI.SetData(selfSeatIcon, "SeatId", selfSeatId)
            GUI.SetData(selfSeatIcon, "SeatLevel", tostring(ourLineupLv))
            GUI.ImageSetImageID(selfSeatIcon, tostring(seat.Icon))
            GUI.SetVisible(selfSeatIcon, true)
        else
            GUI.SetData(selfSeatIcon, "SeatId", "0")
            GUI.SetVisible(selfSeatIcon, false)
        end
    end
    if enemySeatID ~= nil and enemySeatID > 0 then
        local seat = DB.GetOnceSeatByKey1(enemySeatID)--CL.GetSeatByLineUpId(enemySeatID)
        if seat ~= nil then
            if seat.Type ~= 1 then
                GUI.SetData(enemySeatIcon, "SeatId", enemySeatID)
                GUI.SetData(enemySeatIcon, "SeatLevel", tostring(enemyLineupLv))
                GUI.ImageSetImageID(enemySeatIcon, tostring(seat.Icon))
                GUI.SetVisible(enemySeatIcon, true)
            else
                GUI.SetData(enemySeatIcon, "SeatId", "0")
                GUI.SetVisible(enemySeatIcon, false)
            end
        end
    end
end

--阵法图标点击  这里用到的 seatID 对应阵法表的 LineupId
function TimeDownUI.OnSeatIconCllick(guid)
    TimeDownUI.CreateSeatPanel()
    local element = GUI.GetByGuid(guid)
    local seatInfoBg = GUI.Get("FightUI/seatInfoCoverBg/seatInfoBg")
    if element == nil then
        return
    end
    local seatId = GUI.GetData(element, "SeatId")
    if seatId == nil or #seatId < 1 then
        return
    end
    local seatLevel = tonumber(GUI.GetData(element, "SeatLevel"))
    if seatLevel == nil then
        seatLevel = 1
    end
    local seatId = tonumber(seatId)
    local otherSeatID = 0
    local seatNameTxt = "我方阵型："
    if GUI.GetName(element) == "enemySeatIcon" then
        seatNameTxt = "敌方阵型："
        local otherIcon = GUI.Get("TimeDownUI/selfSeatIcon")
        otherSeatID = tonumber(GUI.GetData(otherIcon, "SeatId"))
        GUI.SetPositionX(seatInfoBg, -440)
        GUI.SetPositionY(seatInfoBg, -180)
    else
        local otherIcon = GUI.Get("TimeDownUI/enemySeatIcon")
        otherSeatID = tonumber(GUI.GetData(otherIcon, "SeatId"))
        GUI.SetPositionX(seatInfoBg, 440)
        GUI.SetPositionY(seatInfoBg, -180)
    end

    local seatInfo = DB.GetSeat(seatId, seatLevel)
    local seatName = GUI.GetChild(seatInfoBg, "seatName")

    GUI.StaticSetText(seatName, seatNameTxt .. seatInfo.Name .. "    " .. seatLevel .. "级")
    if seatId == 1 then
        for i = 1, 5 do
            local des = GUI.GetChild(seatInfoBg, "des_" .. i)
            GUI.StaticSetText(des, "无效果")
        end
    else
        for i = 1, 5 do
            local des = GUI.GetChild(seatInfoBg, "des_" .. i)
            local Att1Name = "无效果"
            local Att1Value = ""
            local Att2Name = ""
            local Att2Value = ""
            local Att1Color = fontColorGreen
            local Att2Color = fontColorGreen

            local value1 = seatInfo["Site" .. i .. "Value1"]
            if value1 ~= 0 then
                local att1 = seatInfo["Site" .. i .. "Att1"]
                local attDB1 = DB.GetOnceAttrByKey1(att1)
                Att1Name = attDB1.ChinaName
                local temp = ""
                if attDB1.IsPct == 1 then
                    value1 = value1 / 100
                    temp = value1 .. "%"
                else
                    temp = tostring(value1)
                end
                if value1 > 0 then
                    Att1Value = "+" .. temp
                else
                    Att1Value = temp
                    Att1Color = fontColorRed
                end
            end

            local value2 = seatInfo["Site" .. i .. "Value2"]
            if value2 ~= 0 then
                local att2 = seatInfo["Site" .. i .. "Att2"]
                local attDB2 = DB.GetOnceAttrByKey1(att2)
                Att2Name = attDB2.ChinaName
                local temp = ""
                if attDB2.IsPct == 1 then
                    value2 = value2 / 100
                    temp = value2 .. "%"
                else
                    temp = tostring(value2)
                end
                if value2 > 0 then
                    Att2Value = "+" .. temp
                else
                    Att2Value = temp
                    Att2Color = fontColorRed
                end
            end

            GUI.StaticSetText(des, "<color=#" .. Att1Color .. ">" .. Att1Name .. Att1Value .. "</color> " .. " <color=#" .. Att2Color .. ">" .. Att2Name .. Att2Value .. "</color>")
        end
    end

    local des = GUI.GetChild(seatInfoBg, "des")
    if otherSeatID == 0 then
        -- 对方为0 ，表示是没有阵法或者为怪物阵法。
        GUI.StaticSetText(des, "无克制")
    else
        local otherInfo = DB.GetOnceSeatByKey1(otherSeatID)
        -- 找到敌方信息，先遍历是否是被自己克制
        for i = 1, 10 do
            local id = otherInfo["Seat" .. i]
            if id == seatId then
                if otherInfo["Coef" .. i] < 0 then
                    GUI.StaticSetText(des, "<color=#" .. fontColorGreen .. ">" .. "克制" .. otherInfo.Name .. "</color>")
                else
                    GUI.StaticSetText(des, "<color=#" .. fontColorRed .. ">" .. "被" .. otherInfo.Name .. "克制</color>")
                end
                return
            end
        end
        GUI.StaticSetText(des, "无克制")
    end
end

function TimeDownUI.SetTextBasicInfo(txt, color, Anchor, txtSize)
    if txt ~= nil then
        SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(txt, txtSize)
        GUI.SetColor(txt, color)
        GUI.StaticSetAlignment(txt, Anchor)
    end
end

function TimeDownUI.OnCoverCllick(guid)
    local element = GUI.Get("FightUI/seatInfoCoverBg")
    GUI.SetVisible(element, false)
end

--连续爬塔的轮数
function TimeDownUI.SetLianXuTiaoZhanNumber(currentNum)
    test("currentNum: ", currentNum)
    local parentGroup = GuidCacheUtil.GetUI("lianXuTiaoZhanGroup")
    local timeSpList = {}
    local values = TOOLKIT.ObjectToString(currentNum)
    local len = string.len(values)
    for i = 1, 3 do
        local timeSf = GUI.GetChild(parentGroup, "lianXuTiaoZhanNum" .. i)
        GUI.SetVisible(timeSf, i <= len)
        table.insert(timeSpList, timeSf)
    end

    local offsetX = 20

    for i = 1, len do
        local tempNum = string.char(string.byte(values, i))
        local timeSf = timeSpList[i]
        if timeSf ~= nil then
            GUI.ImageSetImageID(timeSf, "190050517" .. tempNum)
            GUI.SetPositionX(timeSf, -offsetX + 28 * (i - 1))
        end
    end
    local lianXuTiaoZhanBg2 = GUI.GetChild(parentGroup, "lianXuTiaoZhanBg2")
    GUI.SetPositionX(lianXuTiaoZhanBg2, len * 28 - 8)

    TimeDownUI.SetLianXuTiaoZhanVisible(true)
end

function TimeDownUI.SetLianXuTiaoZhanVisible(vis)
    local lianXuTiaoZhanGroup = GuidCacheUtil.GetUI("lianXuTiaoZhanGroup") -- GUI.Get("TimeDownUI/lianXuTiaoZhanGroup")
    if lianXuTiaoZhanGroup then
        GUI.SetVisible(lianXuTiaoZhanGroup, vis)
    end
end