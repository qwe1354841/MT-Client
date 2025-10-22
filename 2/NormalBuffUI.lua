local NormalBuffUI = {}

_G.NormalBuffUI = NormalBuffUI
local GuidCacheUtil = nil
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local colorYellow = UIDefine.YellowColor
local colorRed = UIDefine.RedColor
local colorGreen = UIDefine.GreenColor
local normalBuffRemainBuffTimer = nil
local GuidToBuffId = {}
local CurBuffData = {}
local CurRemoveBuffId = nil

local messageEventList = {
    { GM.NormalBuffUpdate, "OnNormalBuffUpdate" },
    { GM.CustomDataUpdate, "OnCustomDataUpdate"},
}

local attributeEventList = {
    { RoleAttr.RoleAttrLevel, "OnSelfLevelChange" },
}

local CustomBuffList = {
    [4] = { 4, "DoubleExpPoint" },
}

local SpecialBuffList = {
    [8] = { 8, RoleAttr.RoleAttrHpPool },
    [9] = { 9, RoleAttr.RoleAttrMpPool },
}
local RoleAttrTempValue = {}

function NormalBuffUI.Main()
    local panel = GUI.WndCreateWnd("NormalBuffUI", "NormalBuffUI", 0, 0, eCanvasGroup.Normal)
    GUI.SetDepth(panel, 100)
    GUI.SetAnchor(panel, UIAnchor.Right)
    GUI.SetPivot(panel, UIAroundPivot.Center)
    --GUI.CreateSafeArea(panel)
    local coverBtn = GUI.ButtonCreate(panel, "NormalBuffCoverBtn", "1800400290", 0, 0, Transition.ColorTint, "", GUI.GetWidth(panel), GUI.GetHeight(panel), false)
    GuidCacheUtil.BindName(coverBtn, "NormalBuffCoverBtn")
    SetAnchorAndPivot(coverBtn, UIAnchor.Center, UIAroundPivot.Center)
    local alpha0 = Color.New(0, 0, 0, 0)
    GUI.SetColor(coverBtn, alpha0)
    GUI.RegisterUIEvent(coverBtn, UCE.PointerClick, "NormalBuffUI", "OnNormalBuffClose")

    local normalBuffBg = GUI.ImageCreate(coverBtn, "normalBuffBg", "1800400290", 440, -80, false, 320, 350)
    GuidCacheUtil.BindName(normalBuffBg, "normalBuffBg")
    SetAnchorAndPivot(normalBuffBg, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(normalBuffBg, true)
    normalBuffBg:RegisterEvent(UCE.PointerClick)
end

function NormalBuffUI.CreateNormalBuff(panel, parent)
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local normalBuffBtn = GUI.ButtonCreate(parent, "normalBuffBtn", "1800201180", -20, -20, Transition.ColorTint, "", 40, 40, false)
    GuidCacheUtil.BindName(normalBuffBtn, "normalBuffBtn")
    SetAnchorAndPivot(normalBuffBtn, UIAnchor.BottomLeft, UIAroundPivot.Center)
    GUI.RegisterUIEvent(normalBuffBtn, UCE.PointerClick, "NormalBuffUI", "OnNormalBuffOpen")
    GUI.SetVisible(normalBuffBtn, false)

    --local antiAddictionBtn = GUI.ButtonCreate( parent, "antiAddictionBtn", "1801208340", -56, -17, Transition.ColorTint)
    --GuidCacheUtil.BindName(antiAddictionBtn, "antiAddictionBtn")
    --SetAnchorAndPivot(antiAddictionBtn, UIAnchor.BottomLeft, UIAroundPivot.Center)
    --GUI.RegisterUIEvent(antiAddictionBtn, UCE.PointerClick, "NormalBuffUI", "OnAddictionOpen")
    --NormalBuffUI.SetAntiBtnSate(antiAddictionBtn)

    NormalBuffUI.RegisterMessage()
end

function NormalBuffUI.OnShow()
    local wnd = GUI.GetWnd("NormalBuffUI")
    if not wnd then
        return
    end
    GUI.SetVisible(wnd, true)
    NormalBuffUI.InitBuffData()
    NormalBuffUI.RefreshNormalBuff()
    CL.SendNotify(NOTIFY.SubmitForm, "FormServerLevel", "get_level_by_client")
end

local NormalBuffHandler = {}
_G.NormalBuffHandler = NormalBuffHandler
-- normal buff 更新，没有buff隐藏图标，有buff显示图标，且为第一个buff；战斗中不显示
function NormalBuffHandler.OnNormalBuffUpdate(buffId)
    NormalBuffUI.InitBuffData()
    local count = #CurBuffData
    local normalBuffBtn = GuidCacheUtil.GetUI("normalBuffBtn")
    if count == 0 then
        NormalBuffUI.SetIfCanseeServerLevel()
    else
        local hasShowBuff = false
        for i = 1, count do
            local buffData = CurBuffData[i]
            if buffData then
                GUI.ButtonSetImageID(normalBuffBtn, buffData.Icon)
                GUI.SetVisible(normalBuffBtn, true)
                hasShowBuff = true
                break
            end
        end
        if hasShowBuff then
            local NormalBuffCoverBtn = GuidCacheUtil.GetUI("NormalBuffCoverBtn")
            if GUI.GetVisible(NormalBuffCoverBtn) then
                NormalBuffUI.OnNormalBuffOpen()
            end
        else
            NormalBuffUI.SetIfCanseeServerLevel()
        end
    end
end

function NormalBuffHandler.OnCustomDataUpdate()
    NormalBuffHandler.OnNormalBuffUpdate()
end

function NormalBuffHandler.OnSelfAttrChange(attrType, value)
    RoleAttrTempValue[attrType] = value
    NormalBuffHandler.OnNormalBuffUpdate()
end

function NormalBuffUI.RegisterMessage()
    for k, v in ipairs(messageEventList) do
        CL.UnRegisterMessage(v[1], "NormalBuffHandler", v[2])
        CL.RegisterMessage(v[1], "NormalBuffHandler", v[2])
    end
    for k, v in pairs(SpecialBuffList) do
        CL.UnRegisterAttr(v[2], NormalBuffHandler.OnSelfAttrChange)
        CL.RegisterAttr(v[2], NormalBuffHandler.OnSelfAttrChange)
    end
    for k, v in ipairs(attributeEventList) do
        CL.UnRegisterAttr(v[1], NormalBuffUI[v[2]])
        CL.RegisterAttr(v[1], NormalBuffUI[v[2]])
    end
    CL.SendNotify(NOTIFY.SubmitForm, "FormServerLevel", "get_function_switch")
end

function NormalBuffUI.SetIfCanseeServerLevel()
    local normalBuffBtn = GuidCacheUtil.GetUI("normalBuffBtn")
    if NormalBuffUI.CanSeeServerLevelBuff and NormalBuffUI.ServerLevel ~= nil and NormalBuffUI.ServerLevel > 0 then
        GUI.ButtonSetImageID(normalBuffBtn, "1900817232")
        GUI.SetVisible(normalBuffBtn, true)
        local NormalBuffCoverBtn = GuidCacheUtil.GetUI("NormalBuffCoverBtn")
        if GUI.GetVisible(NormalBuffCoverBtn) then
            NormalBuffUI.OnNormalBuffOpen()
        end
        return
    end
    NormalBuffUI.OnNormalBuffClose()
    GUI.SetVisible(normalBuffBtn, false)
end

function NormalBuffUI.OnNormalBuffClose()
    local cover = GuidCacheUtil.GetUI("NormalBuffCoverBtn")
    if cover then
        GUI.SetVisible(cover, false)
    end
    if normalBuffRemainBuffTimer ~= nil then
        normalBuffRemainBuffTimer:Stop()
        normalBuffRemainBuffTimer = nil
    end
    GUI.CloseWnd("NormalBuffUI")
end

function NormalBuffUI.OnNormalBuffOpen()
    local cover = GuidCacheUtil.GetUI("NormalBuffCoverBtn")
    if cover ~= nil then
        GUI.SetVisible(cover, true)
    end
    --NormalBuffUI.RefreshNormalBuff()
    GUI.OpenWnd("NormalBuffUI")
end

-- 防沉迷按钮是否显示
function NormalBuffUI.SetAntiBtnSate(btn)

end

function NormalBuffUI.OnAddictionOpen()
    --GUI.OpenWnd("AntiAddictionUI")
end

function NormalBuffUI.InitBuffData()
    local buffInfo = LD.GetBuffList()
    CurBuffData = {}
    if not buffInfo then
        return
    end
    for i = 1, buffInfo.Count do
        local buff = buffInfo[i - 1]
        NormalBuffUI.AddBuffData(buff.buff_id, buff.start_times, buff.duration)
    end
    for k, v in pairs(SpecialBuffList) do
        local value = RoleAttrTempValue[v[2]] or CL.GetAttr(v[2])
        if value > int64.zero then
            NormalBuffUI.AddBuffData(k, 0, 0)
        end
    end
    for k, v in pairs(CustomBuffList) do
        local value = CL.GetIntCustomData(v[2])
        if value > 0 then
            NormalBuffUI.AddBuffData(k, 0, 0)
        end
    end
    table.sort(CurBuffData, function(a, b)
        return a.ShowPriority > b.ShowPriority
    end)
end

function NormalBuffUI.AddBuffData(buffID, start_times, duration)
    local buffData = DB.GetOnceBuffByKey1(buffID)
    if buffData.Id ~= 0 and tonumber(buffData.Show) == 1 then
        local icon = string.sub(tostring(buffData.Icon), 1, -2) .. "2"
        local data = {
            id = buffID,
            Name = buffData.Name,
            ShowPriority = buffData.ShowPriority,
            start_times = start_times,
            duration = duration,
            Type = buffData.Type,
            Info = buffData.Info,
            Icon = icon,
            Stop = buffData.Stop,
        }
        CurBuffData[#CurBuffData + 1] = data
    end
end

function NormalBuffUI.RefreshNormalBuff()
    local normalBuffBg = GuidCacheUtil.GetUI("normalBuffBg")
    local scrollWnd = GUI.GetChild(normalBuffBg, "normalBuffScroll")
    local buffItemsBg = GuidCacheUtil.GetUI("buffItemsBg")
    local invisibilityColor = Color.New(1, 1, 1, 0)
    if not scrollWnd then
        scrollWnd = GUI.ScrollRectCreate(normalBuffBg, "normalBuffScroll", 0, 10, 300, 330, 0, false, Vector2.New(300, 135), UIAroundPivot.Top, UIAnchor.Top, 1)
        SetAnchorAndPivot(scrollWnd, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.ScrollRectSetChildSpacing(scrollWnd, Vector2.New(0, 10))
        buffItemsBg = GUI.ImageCreate(scrollWnd, "buffItemsBg", "1800201180", 0, 0, false, 300, 70)
        GuidCacheUtil.BindName(buffItemsBg, "buffItemsBg")
        SetAnchorAndPivot(buffItemsBg, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        GUI.SetColor(buffItemsBg, invisibilityColor)
    end

    local buffCount = 0
    local ListHeight = 0
    local count = #CurBuffData
    local num = math.max(count, GUI.GetChildCount(buffItemsBg))
    GuidToBuffId = {}
    for i = 1, num do
        local curItem = GUI.GetChild(buffItemsBg, "buffItemBg" .. i)
        if curItem then
            GUI.SetVisible(curItem, false)
        end
        if count >= i then
            local buffData = CurBuffData[i]
            if buffData then
                buffCount = buffCount + 1
                local iconStr = buffData.Icon
                local name = "buffItemBg" .. buffCount
                local buffItemBg = GUI.GetChild(buffItemsBg, name)
                local deleteNormalBuff = nil
                local buffEffect = nil
                local buffContinueTime = nil
                local buffContinueTimeText = nil
                if not buffItemBg then
                    buffItemBg = GUI.ImageCreate(buffItemsBg, name, "1800201180", 10, ListHeight, false, 300, 70)
                    GUI.SetColor(buffItemBg, invisibilityColor)
                    GUI.ImageCreate(buffItemBg, "buffIcon", iconStr, 16, 5, false, 40, 40)
                    local buffNameTxt = GUI.CreateStatic(buffItemBg, "buffNameTxt", buffData.Name, 30, -10, 240, 24, "system", false, false)
                    NormalBuffUI.SetTextBasicInfo(buffNameTxt, colorYellow, TextAnchor.MiddleLeft, 20)
                    deleteNormalBuff = GUI.ButtonCreate(buffItemBg, "btnRemove", "1800202480", -40, 25, Transition.ColorTint)
                    SetAnchorAndPivot(deleteNormalBuff, UIAnchor.TopRight, UIAroundPivot.Center)
                    GUI.ButtonSetTextFontSize(deleteNormalBuff, 24)
                    GUI.ButtonSetTextColor(deleteNormalBuff, colorRed)
                    GUI.RegisterUIEvent(deleteNormalBuff, UCE.PointerClick, "NormalBuffUI", "OnRemoveNormalBuffClick")
                    GUI.ImageCreate(buffItemBg, "cutLine", "1800600030", 0, 45, false, 310, 5)
                    buffEffect = GUI.RichEditCreate(buffItemBg, "buffEffect", "", 18, 55, 270, 48)
                    SetAnchorAndPivot(buffEffect, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                    GUI.StaticSetFontSize(buffEffect, 20)
                    GUI.StaticSetAlignment(buffEffect, TextAnchor.UpperLeft)
                    buffContinueTime = GUI.CreateStatic(buffItemBg, "buffContinueTime", "剩余时间 : ", -72, 0, 120, 24, "system", true, false)
                    NormalBuffUI.SetTextBasicInfo(buffContinueTime, colorGreen, TextAnchor.MiddleLeft, 20)
                    buffContinueTimeText = GUI.CreateStatic(buffItemBg, "buffContinueTimeText", "", 55, 0, 170, 24, "system", true, false)
                    NormalBuffUI.SetTextBasicInfo(buffContinueTimeText, colorGreen, TextAnchor.MiddleLeft, 20)
                else
                    GUI.SetVisible(buffItemBg, true)
                    GUI.SetPositionY(buffItemBg, ListHeight)
                    local buffIcon = GUI.GetChild(buffItemBg, "buffIcon")
                    GUI.ImageSetImageID(buffIcon, iconStr)
                    local buffNameTxt = GUI.GetChild(buffItemBg, "buffNameTxt")
                    GUI.StaticSetText(buffNameTxt, buffData.Name)
                    deleteNormalBuff = GUI.GetChild(buffItemBg, "btnRemove")
                    buffEffect = GUI.GetChild(buffItemBg, "buffEffect")
                    buffContinueTime = GUI.GetChild(buffItemBg, "buffContinueTime")
                    buffContinueTimeText = GUI.GetChild(buffItemBg, "buffContinueTimeText")
                end
                if tonumber(buffData.Stop) == 1 then
                    GUI.SetVisible(deleteNormalBuff, true)
                    GuidToBuffId[GUI.GetGuid(deleteNormalBuff)] = buffData.id
                else
                    GUI.SetVisible(deleteNormalBuff, false)
                end

                local specialBuffData = SpecialBuffList[buffData.id]
                local customBuffData = CustomBuffList[buffData.id]
                local showText = buffData.Info
                if specialBuffData then
                    local attr = specialBuffData[2]
                    local value = RoleAttrTempValue[attr]
                    if not value then
                        value = CL.GetAttr(attr)
                    else
                        RoleAttrTempValue[attr] = nil -- 读出完了就清除
                    end
                    showText = string.format(showText, tonumber(tostring(value)))
                    GUI.SetVisible(buffContinueTime, false)
                    GUI.SetVisible(buffContinueTimeText, false)
                elseif customBuffData then
                    showText = string.format(showText, tonumber(tostring(CL.GetIntCustomData(customBuffData[2]))))
                    GUI.SetVisible(buffContinueTime, false)
                    GUI.SetVisible(buffContinueTimeText, false)
                else
                    GUI.SetVisible(buffContinueTime, true)
                    GUI.SetVisible(buffContinueTimeText, true)
                end
                GUI.StaticSetText(buffEffect, showText)
                local RealHeight = GUI.RichEditGetPreferredHeight(buffEffect)
                GUI.SetHeight(buffEffect, RealHeight)

                if buffData.Type == 1 or buffData.Type == 2 then
                    if not specialBuffData and not customBuffData then
                        ListHeight = ListHeight + 100 + RealHeight
                        GUI.SetPositionY(buffContinueTime, 40 + RealHeight)
                        GUI.StaticSetText(buffContinueTime, "剩余时间 : ")
                        local targetTime = buffData.start_times + buffData.duration
                        local day, hour, min, sec = GlobalUtils.Get_DHMS2_BySeconds(targetTime - CL.GetServerTickCount())
                        local timeString
                        if day == "00" then
                            if hour == "00" then
                                timeString = min .. ":" .. sec
                            else
                                timeString = hour .. ":" .. min .. ":" .. sec
                            end
                        else
                            timeString = day .. "天" .. hour .. ":" .. min .. ":" .. sec
                        end
                        GUI.SetPositionY(buffContinueTimeText, 40 + RealHeight)
                        GUI.StaticSetText(buffContinueTimeText, timeString)

                        CurBuffData[buffCount].targetTime = targetTime
                    else
                        ListHeight = ListHeight + 60 + RealHeight
                    end
                elseif buffData.Type == 3 then
                    GUI.SetPositionY(buffContinueTime, 40 + RealHeight)
                    GUI.StaticSetText(buffContinueTime, "剩余场次 : ")
                    GUI.SetPositionY(buffContinueTimeText, 40 + RealHeight)
                    GUI.StaticSetText(buffContinueTimeText, buffData.duration)
                    ListHeight = ListHeight + 100 + RealHeight
                else
                    ListHeight = ListHeight + 60 + RealHeight
                end
            end
        end
    end

    local currentLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    local buffItemBg = GuidCacheUtil.GetUI("offlineMinLevel")
    local serverLevelData = NormalBuffUI.ServerLevelData
    if NormalBuffUI.CanSeeServerLevelBuff and serverLevelData then
        local buffNameTxt, buffEffect_1, buffEffect
        if not buffItemBg then
            buffItemBg = GUI.ImageCreate(buffItemsBg,"offlineMinLevel", "1800201180", 10, ListHeight, false, 300, 70)
            GuidCacheUtil.BindName(buffItemBg, "offlineMinLevel")
            GUI.SetColor(buffItemBg, invisibilityColor)
            local buffIcon = GUI.ImageCreate(buffItemBg, "buffIcon", "1900817232", 16, 5, false, 40, 40)
            buffNameTxt = GUI.CreateStatic(buffItemBg, "buffNameTxt", "服务器等级  30级", 30, -10, 240, 24, "system", false, false)
            NormalBuffUI.SetTextBasicInfo(buffNameTxt, colorYellow, TextAnchor.MiddleLeft, 20)
            local cutLine = GUI.ImageCreate(buffItemBg, "cutLine", "1800600030", 0, 45, false, 310, 5)
            buffEffect_1 = GUI.RichEditCreate(buffItemBg,"buffEffect_1", "", 18, 55,  290, 48)
            SetAnchorAndPivot(buffEffect_1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(buffEffect_1, 20)
            GUI.StaticSetAlignment(buffEffect_1, TextAnchor.UpperLeft)

            buffEffect = GUI.RichEditCreate(buffItemBg, "buffEffect", "", 18, 80, 290, 48)
            SetAnchorAndPivot(buffEffect, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(buffEffect, 20)
            GUI.StaticSetAlignment(buffEffect, TextAnchor.UpperLeft)
        else
            GUI.SetVisible(buffItemBg, true)
            GUI.SetPositionY(buffItemBg, ListHeight)
            buffNameTxt = GUI.GetChild(buffItemBg, "buffNameTxt")
            buffEffect_1 = GUI.GetChild(buffItemBg, "buffEffect_1")
            buffEffect = GUI.GetChild(buffItemBg, "buffEffect")
        end
        local serverLevel = serverLevelData.server_lv or 0
        GUI.StaticSetText(buffNameTxt, string.format("服务器等级  %d级",  serverLevel))
        local showText = "您当前等级低于服务器等级"
        if currentLevel > serverLevel then
            showText = "您当前等级高于服务器等级"
        elseif currentLevel == serverLevel then
            showText = "您当前等级与服务器等级相同"
        end
        local showText_1 = "服务器已达到最高等级"
        local nextLevel = serverLevelData.next_server_lv or 0
        if nextLevel == 0 then
        else
            local day, hour, min, sec = GlobalUtils.Get_DHMS2_BySeconds(serverLevelData.next_server_sec or 10000)
            day = tonumber(day)
            hour = tonumber(hour)
            min = tonumber(min)
            sec = tonumber(sec)
            if day >= 1 then
                showText_1 = day .. "天后服务器将升至"  .. nextLevel .. "级"
            elseif hour >= 1 then
                showText_1 = hour .. "小时后服务器将升至" .. nextLevel .. "级"
            elseif min >= 1 then
                showText_1 = min .. "分钟后服务器将升至" .. nextLevel .. "级"
            elseif sec >= 1 then
                showText_1 = sec .. "秒后服务器将升至" .. nextLevel .. "级"
            else
                showText_1 = "服务器升至" .. nextLevel .. "级"
            end
        end
        GUI.StaticSetText(buffEffect_1, showText_1)
        local RealHeight = GUI.RichEditGetPreferredHeight(buffEffect_1)
        GUI.SetHeight(buffEffect_1, RealHeight)
        ListHeight = ListHeight + RealHeight
        GUI.StaticSetText(buffEffect, showText)
        local RealHeight = GUI.RichEditGetPreferredHeight(buffEffect)
        GUI.SetHeight(buffEffect, RealHeight)
        ListHeight = ListHeight + 60 + RealHeight
    else
        if buffItemBg then
            GUI.SetVisible(buffItemBg, false)
        end
    end
    GUI.ScrollRectSetChildSize(scrollWnd, Vector2.New(300, ListHeight))

    if normalBuffRemainBuffTimer == nil then
        local nowTime = CL.GetServerTickCount()
        local fun = function()
            nowTime = nowTime + 1
            NormalBuffUI.UpdateNormalBuffRemainTime(nowTime)
        end
        normalBuffRemainBuffTimer = Timer.New(fun, 1, -1)
        normalBuffRemainBuffTimer:Start()
    end
end

--刷新时间显示
function NormalBuffUI.UpdateNormalBuffRemainTime(nowTime)
    local buffItemsBg = GuidCacheUtil.GetUI("buffItemsBg")
    local count = #CurBuffData
    for i = 1, count do
        local buffItemBg = GUI.GetChild(buffItemsBg, "buffItemBg" .. i)
        local targetTime = CurBuffData[i].targetTime
        if not targetTime then

        elseif tonumber(tostring(targetTime - nowTime)) < 0 then
            NormalBuffUI.RefreshNormalBuff()
        else
            local day, hour, min, sec = GlobalUtils.Get_DHMS2_BySeconds(targetTime - nowTime)
            local timeString
            if day == "00" then
                if hour == "00" then
                    timeString = min .. ":" .. sec
                else
                    timeString = hour .. ":" .. min .. ":" .. sec
                end
            else
                timeString = day .. "天" .. hour .. ":" .. min .. ":" .. sec
            end

            local timeTxt = GUI.GetChild(buffItemBg, "buffContinueTimeText")
            GUI.StaticSetText(timeTxt, timeString)
        end
    end
end

--手动删除NormalBuff
function NormalBuffUI.OnRemoveNormalBuffClick(guid)
    CurRemoveBuffId = GuidToBuffId[guid]
    if not CurRemoveBuffId then
        return
    end
    GlobalUtils.ShowBoxMsg2Btn("提示", "清除该BUFF?", "NormalBuffUI", "确定", "SureToRemoveNormalBuff", "取消")
end

function NormalBuffUI.SureToRemoveNormalBuff()
    local wnd = GUI.GetWnd("MainUI")
    if wnd == nil then
        return
    end

    LD.SendStopBuff(CurRemoveBuffId)
    CurRemoveBuffId = nil
end

function NormalBuffUI.SetTextBasicInfo(txt, color, Anchor, fontSize)
    if txt ~= nil then
        SetAnchorAndPivot(txt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(txt, fontSize)
        GUI.SetColor(txt, color)
        GUI.StaticSetAlignment(txt, Anchor)
    end
end

--- 刷新服务器等级
function NormalBuffUI.ServerLevelFunctionState(state, canSeeLevel, serverLevel)
    NormalBuffUI.CanSeeServerLevelRoleLevel = canSeeLevel
    local currentLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
    NormalBuffUI.ServerLevel = serverLevel
    if currentLevel < canSeeLevel then
        NormalBuffUI.CanSeeServerLevelBuff = false
        return
    end
    NormalBuffUI.CanSeeServerLevelBuff = true
    NormalBuffHandler.OnNormalBuffUpdate()
end

function NormalBuffUI.RefreshServerLevelData(data)
    NormalBuffUI.ServerLevelData = data
    local wnd = GUI.GetWnd("NormalBuffUI")
    if GUI.GetVisible(wnd) then
        NormalBuffUI.RefreshNormalBuff()
    end
end

function NormalBuffUI.OnSelfLevelChange(attrType, value)
    if NormalBuffUI.CanSeeServerLevelBuff or not NormalBuffUI.ServerLevelData then
        return
    end
    local serverLevel = NormalBuffUI.ServerLevelData.server_lv or 0
    local currentRein = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
    if currentRein <= 0 and tonumber(tostring(value)) < serverLevel then
        return
    end
    NormalBuffUI.CanSeeServerLevelBuff = true
    NormalBuffHandler.OnNormalBuffUpdate()
end