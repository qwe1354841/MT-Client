local AttributeChangeTipUI = {
    TipsNum = 7, -- 同时存在的飘字个数
    StartAlpha = 0.1,

    AttrIndex = 0,
    AttrTimer = nil,
    FightValueTimer = nil,
    FightTimer = nil,
    TipsList = {},
    IsPlaying = false,
    FreeTipsList = {},
    FightValueNum = 8,
    StayTime = 0,
    Register = nil,
    IsFightValuePlaying = false
}

_G.AttributeChangeTipUI = AttributeChangeTipUI

local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local colorSub = Color.New(237 / 255, 100 / 255, 107 / 255)
local colorSubOutline = Color.New(0 / 255, 0 / 255, 0 / 255,0.7)
local colorAdd = Color.New(36 / 255, 204 / 255, 22 / 255)
local colorAddOutline = Color.New(0 / 255, 0 / 255, 0 / 255,0.7)
local SHOW_TIME = 0.3
local ROLL_TIMES = 20
local STAY_TIME = 0.5

local ShowTipAttribute = {
    --[RoleAttr.RoleAttrFightValue] = {AttributeChangeTipUI.OnFightValueChange},
    [RoleAttr.RoleAttrHpLimit] = { "OnMaxHpChange", "气血上限   %s" },
    [RoleAttr.RoleAttrMpLimit] = { "OnMaxMpChange", "魔法上限   %s" },
    [RoleAttr.RoleAttrPhyAtk] = { "OnPhyAtkChange", "物理攻击   %s" },
    [RoleAttr.RoleAttrPhyDef] = { "OnPhyDefChange", "物理防御   %s" },
    [RoleAttr.RoleAttrMagAtk] = { "OnMagAtkChange", "法术攻击   %s" },
    [RoleAttr.RoleAttrMagDef] = { "OnMagDefChange", "法术防御   %s" },
    [RoleAttr.RoleAttrFightSpeed] = { "OnSpeedChange", "速    度   %s" },
    [RoleAttr.RoleAttrPhyBurstRate] = {"OnPhyBurstChange","物    暴   %s"},
    [RoleAttr.RoleAttrMagBurstRate] = {"OnMagBurstChange","法    暴   %s"},
    [RoleAttr.RoleAttrSealRate] = {"OnSealRateChange","封    印   %s"},
    [RoleAttr.RoleAttrSealResistRate] = {"OnSealResistChange","封    抗   %s"},
    [RoleAttr.RoleAttrMissRate] = {"OnMissRateChange","闪    避    %s"},
    [RoleAttr.RoleAttrHitRate] = {"OnHitRateChange","命    中   %s"}
}

local PanelBgFromPos = Vector3.New(0, 80, 0)
local PanelBgEndPos = Vector3.New(0, -30, 0)
local FromAlpha = Vector3.New(1, 0, 0)
local EndAlpha = Vector3.New(0.3, 0, 0)

function AttributeChangeTipUI.Main(parameter)

    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("AttributeChangeTipUI", "AttributeChangeTipUI", 0, 0, eCanvasGroup.Top)
    GUI.SetAnchor(panel, UIAnchor.Center)
    GUI.SetPivot(panel, UIAroundPivot.Center)

    for i = 1, AttributeChangeTipUI.TipsNum do
        local groupP = GUI.GroupCreate(panel, "groupParent" .. i, 0, 10, 10, 10)
        _gt.BindName(groupP, "attrGroupP" .. i)
        local group = GUI.GroupCreate(groupP, "group" .. i, 0, 0, 0, 0)
        _gt.BindName(group, "attrGroup" .. i)
        local context = GUI.CreateStatic(group, "Tip", "", 0, 0, 300, 32, "system", true)
        _gt.BindName(context, "attrTip" .. i)
        UILayout.SetSameAnchorAndPivot(context, UILayout.Center)
        UILayout.StaticSetFontSizeColorAlignment(context, 24, "", TextAnchor.MiddleCenter)
        GUI.SetIsOutLine(context, true)
        GUI.SetOutLine_Distance(context, 1)
        GUI.SetIsRaycastTarget(context, false)
        if tween ~= nil and PanelBgFromPos ~= nil then
            GUI.SetPositionY(groupP, 0)
        end
        GUI.SetVisible(group, false)
        GUI.SetGroupAlpha(groupP, AttributeChangeTipUI.StartAlpha)
        AttributeChangeTipUI.FreeTipsList[i] = true
    end

    local high = 150
    local groupFightValue = GUI.GroupCreate(panel, "groupFightValue", 0, 0, 10, 10)

    local bg = GUI.ImageCreate(groupFightValue, "bg", "1800200080", 0, high, false, 500, 50)
    local fightValue = GUI.ImageCreate(groupFightValue, "fightValue", "1801405350", -80, high)
    UILayout.SetSameAnchorAndPivot(context, UILayout.Center)
    for i = 1, AttributeChangeTipUI.FightValueNum do
        local spriteNum = GUI.ImageCreate(groupFightValue, "num" .. i, "190051", 0, high, false, 25, 30)
        GUI.SetPositionX(spriteNum, i * 22-30)
        GUI.SetVisible(spriteNum, false)

        local changeNum = GUI.ImageCreate(groupFightValue, "changeNum" .. i, "190051", 0, high, false, 24, 28)
        GUI.SetPositionX(changeNum, 150 + i * 22)
        GUI.SetVisible(changeNum, false)
    end
    local arrow = GUI.ImageCreate(groupFightValue, "arrow", "190051", 0, high, false, 25, 30)
    UILayout.SetSameAnchorAndPivot(arrow, UILayout.Center)
    GUI.SetVisible(groupFightValue, false)

    --CL.RegisterMessage(GM.FightRoleAttrChange , "AttributeChangeTipUI", "OnSelfAppear")
    if not AttributeChangeTipUI.Register then
        AttributeChangeTipUI.Register = Timer.New(AttributeChangeTipUI.OnSelfAppear,5,1)
        AttributeChangeTipUI.Register:Start()
    end
    --AttributeChangeTipUI.OnSelfAppear()
    --GUI.RegisterUIMessage(UM.OnCloseNpcDialogUI, "AttributeChangeTipUI", "OnCloseNpcDialogUI")
end

function AttributeChangeTipUI.OnSelfAppear()
    if AttributeChangeTipUI.Register then
        AttributeChangeTipUI.Register:Stop()
        AttributeChangeTipUI.Register = nil
    end

    --CL.UnRegisterMessage(GM.FightRoleAttrChange, "AttributeChangeTipUI", "OnSelfAppear")
    --CL.UnRegisterAttributeEvent(role_attr.role_fight_value, selfNickName, "AttributeChangeTipUI", "OnFightValueChange")
    --CL.RegisterAttributeEvent(role_attr.role_fight_value, selfNickName, "AttributeChangeTipUI", "OnFightValueChange")
    for k, v in pairs(ShowTipAttribute) do
        CL.UnRegisterAttr(k, AttributeChangeTipUI.OnAttributeChange)
        CL.RegisterAttr(k, AttributeChangeTipUI.OnAttributeChange)
    end
    CL.UnRegisterAttr(RoleAttr.IntToEnum(314),AttributeChangeTipUI.OnFightValueChange)
    CL.RegisterAttr(RoleAttr.IntToEnum(314),AttributeChangeTipUI.OnFightValueChange)
end

function AttributeChangeTipUI.OnCloseNpcDialogUI()
    AttributeChangeTipUI.Play()
    AttributeChangeTipUI.PlayFightValueChange()
end

function AttributeChangeTipUI.ShowAttributeChangeTip(index, attrType, value, posY)
    if not ShowTipAttribute[attrType] then
        return
    end
    local groupP = _gt.GetUI("attrGroupP" .. index)
    local group = _gt.GetUI("attrGroup" .. index)
    local bubbleText = _gt.GetUI("attrTip" .. index)
    local tweenMove = TweenData.New()
    tweenMove.Type = GUITweenType.DOLocalMove
    tweenMove.Duration = 1
    tweenMove.From = PanelBgFromPos
    tweenMove.LoopType = UITweenerStyle.Once
    tweenMove.To = PanelBgEndPos

    local tweenAlpha = TweenData.New()
    tweenAlpha.Type = GUITweenType.DOGroupAlpha
    tweenAlpha.Duration = 2
    tweenAlpha.From = FromAlpha
    tweenAlpha.LoopType = UITweenerStyle.Once
    tweenAlpha.To = EndAlpha
   
    GUI.SetVisible(group, true)
    --print("==============SetVisible==========true===========AAAAAAAAAAAAAAAAAAAA=="..index)
    GUI.DOTween(groupP, tweenMove, "AttributeChangeTipMove")
    GUI.DOTween(groupP, tweenAlpha, "AttributeChangeTipAlpha")
    local timer = Timer.New(function()
        local grP = _gt.GetUI("attrGroupP" .. index)
        local gr = _gt.GetUI("attrGroup" .. index)
        if gr then
            GUI.StopTween(grP, "AttributeChangeTipAlpha")
            GUI.StopTween(grP, "AttributeChangeTipMove")
            GUI.SetPositionY(grP, PanelBgFromPos.y)
            GUI.SetVisible(gr, false)
            --print("==============SetVisible==========false=============BBBBBBBBBBBBBB=="..index)
        end
        AttributeChangeTipUI.FreeTipsList[index] = true
    end, 1.1, 1)
    timer:Start()
    local temp = ""
    if value > 0 then
        GUI.SetColor(bubbleText, colorAdd)
        GUI.SetOutLine_Color(bubbleText, colorAddOutline)
        temp = "+" .. value
    else
        GUI.SetColor(bubbleText, colorSub)
        GUI.SetOutLine_Color(bubbleText, colorSubOutline)
        temp = tostring(value)
    end
    GUI.StaticSetText(bubbleText, string.format(ShowTipAttribute[attrType][2], temp))
end

function AttributeChangeTipUI.OnAttributeChange(attrType, value)
    local lastValue = CL.GetAttr(attrType)
    if tonumber(tostring(lastValue)) <= 0 then
        return
    end
    local temp = { attrType, tonumber(tostring(value - lastValue)) }
    table.insert(AttributeChangeTipUI.TipsList, temp)
    if #AttributeChangeTipUI.TipsList > 1 then
        local long = #AttributeChangeTipUI.TipsList
        local i = 1
        while i < long do
            local v = i + 1
            while v <= long do
                if AttributeChangeTipUI.TipsList[i] and AttributeChangeTipUI.TipsList[v] ~= nil then
                    if AttributeChangeTipUI.TipsList[i][1] == AttributeChangeTipUI.TipsList[v][1] then
                        AttributeChangeTipUI.TipsList[i][2] = AttributeChangeTipUI.TipsList[i][2] + AttributeChangeTipUI.TipsList[v][2]
                        table.remove(AttributeChangeTipUI.TipsList , v)
                        v = v-1
                        long = long - 1
                    end
                end
                v = v + 1
            end
            i = i + 1
        end
    end
    if AttributeChangeTipUI.IsPlaying then
        return
    end
    AttributeChangeTipUI.Play()
end

function AttributeChangeTipUI.Play()
    local wnd = GUI.GetWnd("NpcDialogMovieUI")
    if MoviePlaying and MoviePlaying == 1 or wnd and GUI.GetVisible(wnd) then
        return
    end
    if #AttributeChangeTipUI.TipsList <= 0 then
        return
    end
    AttributeChangeTipUI.IsPlaying = true
    if not AttributeChangeTipUI.AttrTimer then
        AttributeChangeTipUI.AttrTimer = Timer.New(AttributeChangeTipUI.OnTimer, SHOW_TIME, -1)
        AttributeChangeTipUI.AttrTimer:Start()
    else
        local index = AttributeChangeTipUI.AttrIndex + 1
        if not AttributeChangeTipUI.FreeTipsList[index] then
            return
        end
        AttributeChangeTipUI.FreeTipsList[index] = false
        local temp = AttributeChangeTipUI.TipsList[1]
        --test("value: "..AttributeChangeTipUI.Map[temp[1]])

        table.remove(AttributeChangeTipUI.TipsList, 1)
        --print(temp[2])
        if temp[2] == 0 then
            AttributeChangeTipUI.FreeTipsList[index] = true
            return
        end
        AttributeChangeTipUI.ShowAttributeChangeTip(index, temp[1], temp[2])
        AttributeChangeTipUI.AttrIndex = (AttributeChangeTipUI.AttrIndex + 1) % AttributeChangeTipUI.TipsNum
    end
end

function AttributeChangeTipUI.OnTimer()
    local wnd = GUI.GetWnd("NpcDialogMovieUI")
    if #AttributeChangeTipUI.TipsList <= 0 or MoviePlaying and MoviePlaying == 1 or wnd and GUI.GetVisible(wnd) then
        AttributeChangeTipUI.IsPlaying = false
        if AttributeChangeTipUI.AttrTimer then
            AttributeChangeTipUI.AttrTimer:Stop()
            AttributeChangeTipUI.AttrTimer = nil
        end
        return
    end
    AttributeChangeTipUI.Play()
end

function AttributeChangeTipUI.OnFightValueChange(attrType, value)

    --print(tonumber(tostring(value)))
    local startValue = tonumber(tostring(CL.GetAttr(attrType)))
    --print(startValue)
    if startValue <= 0 then
        return
    end
    local endValue = tonumber(tostring(value))
    if not startValue or not endValue then
        return
    end
    --if endValue <= startValue then -- 战斗力下降不用表演
    --    return
    --end
    --AttributeChangeTipUI.FightValueParameter = string.format("%d_%d", startValue, endValue)
    AttributeChangeTipUI.FightValueParameter = AttributeChangeTipUI.FightValueParameter or {}
    table.insert(AttributeChangeTipUI.FightValueParameter, string.format("%d_%d", startValue, endValue))
    if #AttributeChangeTipUI.FightValueParameter > 1 then
        local Value = string.split(AttributeChangeTipUI.FightValueParameter[1], "_")
        local StartV = Value[1]
        Value = string.split(AttributeChangeTipUI.FightValueParameter[#AttributeChangeTipUI.FightValueParameter], "_")
        local endV = Value[2]
        table.insert(AttributeChangeTipUI.FightValueParameter, string.format("%d_%d", StartV, endV))
        local long = #AttributeChangeTipUI.FightValueParameter
        for i = 1, long - 1 do
            table.remove(AttributeChangeTipUI.FightValueParameter,1)
        end
    end
    --CDebug.LogError(AttributeChangeTipUI.IsFightValuePlaying)
    if not AttributeChangeTipUI.IsFightValuePlaying then
        AttributeChangeTipUI.PlayFightValueChange()
    end
end

function AttributeChangeTipUI.OnFightTimer()
    --print(#AttributeChangeTipUI.FightValueParameter)
    if #AttributeChangeTipUI.FightValueParameter <= 0 then
        --print("表为空，结束")
        --AttributeChangeTipUI.IsFightValuePlaying = false
        if AttributeChangeTipUI.FightTimer then
            AttributeChangeTipUI.FightTimer:Stop()
            AttributeChangeTipUI.FightTimer = nil
        end
        return
    else
        AttributeChangeTipUI.PlayFightValueChange()
    end
    --AttributeChangeTipUI.IsFightValuePlaying = false

end

function AttributeChangeTipUI.PlayFightValueChange()
    if AttributeChangeTipUI.IsFightValuePlaying or not AttributeChangeTipUI.FightValueParameter or #AttributeChangeTipUI.FightValueParameter <= 0 then
        --("条件不足，返回")
        return
    end
    if not AttributeChangeTipUI.FightTimer then
        --print("创建FightTimer")
        AttributeChangeTipUI.FightTimer = Timer.New(AttributeChangeTipUI.OnFightTimer,0.5,-1)
        AttributeChangeTipUI.FightTimer:Start()
    else
        local wnd = GUI.GetWnd("NpcDialogMovieUI")
        if MoviePlaying and MoviePlaying == 1 or wnd and GUI.GetVisible(wnd) then
            return
        end
        local group = GUI.Get("AttributeChangeTipUI/groupFightValue")
--[[        if not group then
            return
        end]]
        local valueStr = AttributeChangeTipUI.FightValueParameter[1]
        local values = string.split(valueStr, "_")
        table.remove(AttributeChangeTipUI.FightValueParameter, 1)
        --print("移除服务器传入的数据（1）")
        AttributeChangeTipUI.StartList = {}
        AttributeChangeTipUI.EndList = {}
        AttributeChangeTipUI.ChangeList = {}
        if tonumber(values[1]) == tonumber(values[2]) then
            return
        end
        GUI.SetVisible(group, true)
        local startValue = tonumber(values[1])
        local endValue = tonumber(values[2])
        AttributeChangeTipUI.StartValue = startValue
        AttributeChangeTipUI.EndValue = endValue
        AttributeChangeTipUI.CurValue = startValue
        AttributeChangeTipUI.CurList = AttributeChangeTipUI.StartList
        local change = endValue - startValue
        AttributeChangeTipUI.Step = math.floor(change / ROLL_TIMES)
        local arrowSprite = change > 0 and "1800607060" or "1800607070"
        local offValue = change > 0 and 5110 or 5090
        change = change > 0 and change or -change
        table.insert(AttributeChangeTipUI.ChangeList, offValue + 10)
        --print("生成数据变化表")
        while (startValue ~= 0 or endValue ~= 0 or change ~= 0) do
            if startValue ~= 0 then
                local temp = startValue % 10
                table.insert(AttributeChangeTipUI.StartList, 1, temp)
                startValue = math.floor(startValue / 10)
            end
            if endValue ~= 0 then
                local temp = endValue % 10
                table.insert(AttributeChangeTipUI.EndList, 1, temp)
                endValue = math.floor(endValue / 10)
            end
            if change ~= 0 then
                local temp = offValue + change % 10
                table.insert(AttributeChangeTipUI.ChangeList, 2, temp)
                change = math.floor(change / 10)
            end
        end
        local startNum = #AttributeChangeTipUI.StartList

        local chaNum = #AttributeChangeTipUI.ChangeList
        local offX = 0
        for i = 1, AttributeChangeTipUI.FightValueNum do
            local spriteNum = GUI.Get("AttributeChangeTipUI/groupFightValue/num" .. i)
            if spriteNum then
                if startNum >= i then
                    GUI.SetVisible(spriteNum, true)
                    GUI.ImageSetImageID(spriteNum, "190050508" .. AttributeChangeTipUI.StartList[i])
                else
                    GUI.SetVisible(spriteNum, false)
                end
            end
            local changeNum = GUI.Get("AttributeChangeTipUI/groupFightValue/changeNum" .. i)
            if changeNum then
                if chaNum >= i then
                    GUI.SetVisible(changeNum, true)
                    GUI.ImageSetImageID(changeNum, "190050" .. AttributeChangeTipUI.ChangeList[i])
                    GUI.SetPositionX(changeNum,-2 + 22 * startNum + i * 22 + 22)
                    if chaNum == i then
                        offX = GUI.GetPositionX(changeNum)
                    end
                else
                    GUI.SetVisible(changeNum, false)
                end
            end
        end
        local arrow = GUI.Get("AttributeChangeTipUI/groupFightValue/arrow")
        if arrow then
            GUI.SetPositionX(arrow, offX + 30)
            GUI.ImageSetImageID(arrow, arrowSprite)
        end
        AttributeChangeTipUI.State = 1
        AttributeChangeTipUI.CurRollTimes = 0
        AttributeChangeTipUI.StayTime = 0
        if AttributeChangeTipUI.RollTimer then
            AttributeChangeTipUI.RollTimer:Stop()
            AttributeChangeTipUI.RollTimer = nil
        end
        if AttributeChangeTipUI.FightValueTimer then
            AttributeChangeTipUI.FightValueTimer:Stop()
            AttributeChangeTipUI.FightValueTimer:Reset(AttributeChangeTipUI.OnFightValueTimer, 0.2, -1)
        else
            AttributeChangeTipUI.FightValueTimer = Timer.New(AttributeChangeTipUI.OnFightValueTimer, 0.2, -1)
        end
        AttributeChangeTipUI.FightValueTimer:Start()
        AttributeChangeTipUI.IsFightValuePlaying = true
    end
end

function AttributeChangeTipUI.OnFightValueTimer()
    if AttributeChangeTipUI.State == 1 then
        AttributeChangeTipUI.State = 2
    elseif AttributeChangeTipUI.State == 2 then
        if AttributeChangeTipUI.RollTimer then
            AttributeChangeTipUI.RollTimer:Stop()
            AttributeChangeTipUI.RollTimer:Reset(AttributeChangeTipUI.OnRoll, 0.05, -1)
        else
            AttributeChangeTipUI.RollTimer = Timer.New(AttributeChangeTipUI.OnRoll, 0.05, -1)
        end
        AttributeChangeTipUI.RollTimer:Start()
        AttributeChangeTipUI.State = 3
    elseif AttributeChangeTipUI.State == 4 then
        AttributeChangeTipUI.StayTime = AttributeChangeTipUI.StayTime + 0.2
        if AttributeChangeTipUI.StayTime < STAY_TIME then
            return
        end
        AttributeChangeTipUI.FightValueTimer:Stop()
        AttributeChangeTipUI.FightValueTimer = nil
        local group = GUI.Get("AttributeChangeTipUI/groupFightValue")
        if group then
            GUI.SetVisible(group, false)
        end
        AttributeChangeTipUI.IsFightValuePlaying = false
        AttributeChangeTipUI.PlayFightValueChange()
    end
end

function AttributeChangeTipUI.OnRoll()
    if AttributeChangeTipUI.CurRollTimes >= ROLL_TIMES then
        AttributeChangeTipUI.State = 4
        AttributeChangeTipUI.RefreshNum(AttributeChangeTipUI.EndList)
        AttributeChangeTipUI.RollTimer:Stop()
        AttributeChangeTipUI.RollTimer = nil
        return
    end
    AttributeChangeTipUI.CurRollTimes = AttributeChangeTipUI.CurRollTimes + 1
    AttributeChangeTipUI.CurValue = AttributeChangeTipUI.CurValue + AttributeChangeTipUI.Step
    local value = AttributeChangeTipUI.CurValue
    local valueList = {}
    while (value ~= 0) do
        local temp = value % 10
        table.insert(valueList, 1, temp)
        value = math.floor(value / 10)
    end
    AttributeChangeTipUI.RefreshNum(valueList)
end

function AttributeChangeTipUI.RefreshNum(valueList)
    local maxNum = math.max(#valueList, #AttributeChangeTipUI.CurList)
    for i = 1, maxNum do
        if valueList[i] ~= AttributeChangeTipUI.CurList[i] then
            local spriteNum = GUI.Get("AttributeChangeTipUI/groupFightValue/num" .. i)
            if spriteNum then
                if not valueList[i] then
                    GUI.SetVisible(spriteNum, false)
                else
                    GUI.SetVisible(spriteNum, true)
                    GUI.ImageSetImageID(spriteNum, "190050508" .. valueList[i])
                end
            end
        end
    end
    AttributeChangeTipUI.CurList = valueList
end

function AttributeChangeTipUI.OnShow()

end

function AttributeChangeTipUI.OnDestroy()
    for k, v in pairs(ShowTipAttribute) do
        CL.UnRegisterAttr(k, AttributeChangeTipUI.OnAttributeChange)
    end
end