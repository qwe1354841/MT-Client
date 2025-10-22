MonopolyUI = {}
--设置字体颜色
local HOR_TOTAL = 11
local VER_TOTAL = 5
MonopolyUI.ItemsNode = nil
MonopolyUI.NumLimit = 10 --速度不同的临界步数
MonopolyUI.SpeedSlow = 0.25
MonopolyUI.SpeedQuick = 0.25
MonopolyUI.SelectDiceIndex = 1
MonopolyUI.RollResultIndex = 1
MonopolyUI.RollWaittingTime = 2.5 --等待时长
MonopolyUI.RollWaittingIndex = 1
MonopolyUI.RollWaittingFuncIndex = 1
MonopolyUI.WaittingAniInfo = nil
MonopolyUI.WaittingAniInfoNode = nil
MonopolyUI.EffectTypeNode = nil
MonopolyUI.nowRollPos = 0
MonopolyUI.targetRollPos = 0
MonopolyUI.rollRoundNum = 0
MonopolyUI.rollDirtion = 1 --方向1或-1
MonopolyUI.IsDuringAniLoop = false
MonopolyUI.DefaultSelectTouziID = 0
MonopolyUI.Timer1 = nil
MonopolyUI.Timer2 = nil
MonopolyUI.Timer3 = nil
MonopolyUI.Timer4 = nil
MonopolyUI.Timer5 = nil

local _gt = UILayout.NewGUIDUtilTable()

function MonopolyUI.Main(param)
    if param then
        local str0 = string.split(param, ",")
        if #str0>=2 then
            local str1 = string.split(str0[2], ":")
            if #str1>=2 then
                MonopolyUI.DefaultSelectTouziID = tonumber(str1[2])
            end
        end
    end

    _gt = UILayout.NewGUIDUtilTable()
    local _Panel = GUI.WndCreateWnd("MonopolyUI" , "MonopolyUI" , 0 , 0)
    local _PanelBg = UILayout.CreateFrame_WndStyle0(_Panel, "禅意大富翁","MonopolyUI","OnExit")

    local _Bg1 = GUI.ImageCreate(_PanelBg, "Bg1", "1800400010", 0, 9, false, 938, 580)
    UILayout.SetSameAnchorAndPivot(_Bg1, UILayout.Center)
    MonopolyUI.ItemsNode = _Bg1

    local SelectBg = GUI.ImageCreate(_PanelBg, "SelectBg", "1800499999", 0, 9)
    UILayout.SetSameAnchorAndPivot(SelectBg, UILayout.Center)

    local _Bg2 = GUI.ImageCreate(_Bg1, "Bg2", "1800201130", 0, 1, false, 761, 400)
    UILayout.SetSameAnchorAndPivot(_Bg2, UILayout.Center)

    local _Pic = GUI.ImageCreate(_Bg2, "Pic", "1800608210", 7,7)
    UILayout.SetSameAnchorAndPivot(_Pic, UILayout.TopLeft)

    local _PicTxt = GUI.ImageCreate(_Pic, "PicTxt", "1800604190", 10, 20)
    UILayout.SetSameAnchorAndPivot(_PicTxt, UILayout.TopLeft)

    --local _DiceNote = GUI.ImageCreate(_Bg2, "DiceNote", "", 590, 50, false, 0, 0)
    local _DiceNote = GUI.GroupCreate(_Bg2, "DiceNote", 590, 50, 0, 0)
    UILayout.SetSameAnchorAndPivot(_DiceNote, UILayout.TopLeft)

    local _DiceTitle = GUI.ImageCreate(_DiceNote, "DiceTitle", "1800608220", 0, 0)
    UILayout.SetSameAnchorAndPivot(_DiceTitle, UILayout.Center)

    local _DiceName = GUI.CreateStatic(_DiceTitle, "DiceName", "", 0, 0, 300, 30, "system", true)
    _gt.BindName(_DiceName, "DiceName")
    UILayout.SetSameAnchorAndPivot(_DiceName, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_DiceName, UIDefine.FontSizeL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)

    local _DiceNum = GUI.CreateStatic(_DiceNote, "DiceNum", "", 0, 50, 300, 30, "system", true)
    _gt.BindName(_DiceNum, "DiceNum")
    UILayout.SetSameAnchorAndPivot(_DiceNum, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_DiceNum, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

    local _DiceShadow = GUI.ImageCreate(_DiceNote, "DiceShadow", "1800608290", 0, 184)
    UILayout.SetSameAnchorAndPivot(_DiceShadow, UILayout.Center)

    local _Dice = GUI.ImageCreate(_DiceNote, "Dice", "1800499999", 0, 136, false, 100, 100)
    _gt.BindName(_Dice, "Dice")
    UILayout.SetSameAnchorAndPivot(_Dice, UILayout.Center)

    local _DiceInfo = GUI.CreateStatic(_DiceNote, "DiceInfo", "", 0, 245, 300, 30, "system", true)
    _gt.BindName(_DiceInfo, "DiceInfo")
    UILayout.SetSameAnchorAndPivot(_DiceInfo, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_DiceInfo, UIDefine.FontSizeM, UIDefine.BrownColor, TextAnchor.MiddleCenter)

    local _DiceUseBtn = GUI.ButtonCreate(_DiceNote, "DiceUseBtn", "1800102090", 0, 300, Transition.ColorTint)
    _gt.BindName(_DiceUseBtn, "DiceUseBtn")
    UILayout.SetSameAnchorAndPivot(_DiceUseBtn, UILayout.Center)
    GUI.RegisterUIEvent(_DiceUseBtn, UCE.PointerClick, "MonopolyUI", "BtnRollClick")

    local _DiceLastBtn = GUI.ButtonCreate(_DiceNote, "DiceLastBtn", "1800602190", -110, 149, Transition.ColorTint)
    _gt.BindName(_DiceLastBtn, "DiceLastBtn")
    UILayout.SetSameAnchorAndPivot(_DiceLastBtn, UILayout.Center)
    GUI.RegisterUIEvent(_DiceLastBtn, UCE.PointerClick, "MonopolyUI", "OnClickDiceLastBtn")

    local _DiceNextBtn = GUI.ButtonCreate(_DiceNote, "DiceNextBtn", "1800602120", 112, 149, Transition.ColorTint)
    _gt.BindName(_DiceNextBtn, "DiceNextBtn")
    UILayout.SetSameAnchorAndPivot(_DiceNextBtn, UILayout.Center)
    GUI.RegisterUIEvent(_DiceNextBtn, UCE.PointerClick, "MonopolyUI", "OnClickDiceNextBtn")

    local _DiceBtnTxt = GUI.CreateStatic(_DiceUseBtn, "DiceInfo", "投掷骰子", 0, 0, 150, 40, "system", true)
    UILayout.SetSameAnchorAndPivot(_DiceBtnTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_DiceBtnTxt, UIDefine.FontSizeXL, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(_DiceBtnTxt, true)
    GUI.SetOutLine_Color(_DiceBtnTxt, UIDefine.Brown3Color)
    GUI.SetOutLine_Distance(_DiceBtnTxt, 1)

    local SelectFlag = GUI.ImageCreate(SelectBg, "SelectFlag", "1800400280", 0, 0, false, 82, 82)
    MonopolyUI.SelectFlag = SelectFlag
    UILayout.SetSameAnchorAndPivot(SelectFlag, UILayout.Center)
    GUI.SetVisible(SelectFlag, false)

    --骰子结果
    local _PanelCover = GUI.ImageCreate( _Panel,"PanelCover", "1800400220", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
    MonopolyUI.WaittingAniInfoNode = _PanelCover
    UILayout.SetSameAnchorAndPivot(_PanelCover, UILayout.Center)
    GUI.SetIsRaycastTarget(_PanelCover,true)
    GUI.SetVisible(_PanelCover, false)

    local _ResultBg = GUI.ImageCreate( _PanelCover, "ResultBg" , "1800700180" , 0 , 0 ,false,500,100);
    UILayout.SetSameAnchorAndPivot(_ResultBg, UILayout.Center)

    local _ResultTxt = GUI.CreateStatic( _ResultBg, "WaittingAniInfo","投掷结果为" ,0,2,500,50,"system",true);
    MonopolyUI.WaittingAniInfo = _ResultTxt
    UILayout.SetSameAnchorAndPivot(_ResultTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_ResultTxt, 26, UIDefine.BrownColor, TextAnchor.MiddleCenter)

    CL.RegisterMessage(GM.RefreshBag,"MonopolyUI" , "OnRefreshBag")
end

function MonopolyUI.OnShow(param)
    MonopolyUI.IsDuringAniLoop = false
    CL.SendNotify(NOTIFY.SubmitForm, "FormChanYiLunPan", "GetData")
end

function MonopolyUI.OnRefreshBag()
    MonopolyUI.OnSwitchTouziInfo()
end

function MonopolyUI.RefreshData()
    MonopolyUI.ShowAllItem()
end

function MonopolyUI.OnClickDiceLastBtn()
    MonopolyUI.SelectDiceIndex = MonopolyUI.SelectDiceIndex - 1
    MonopolyUI.SelectDiceIndex = math.max(1, MonopolyUI.SelectDiceIndex)
    MonopolyUI.OnSwitchTouziInfo()
    MonopolyUI.OnSwitchBtnState()
end

function MonopolyUI.OnClickDiceNextBtn()
    if MonopolyUI.ClientDiceList then
        MonopolyUI.SelectDiceIndex = MonopolyUI.SelectDiceIndex + 1
        MonopolyUI.SelectDiceIndex = math.min(#MonopolyUI.ClientDiceList, MonopolyUI.SelectDiceIndex)
        MonopolyUI.OnSwitchTouziInfo()
        MonopolyUI.OnSwitchBtnState()
    end
end

function MonopolyUI.OnSwitchTouziInfo()
    local _Dice = _gt.GetUI("Dice")
    local _DiceInfo = _gt.GetUI("DiceInfo")
    local _DiceNum = _gt.GetUI("DiceNum")
    local _DiceName = _gt.GetUI("DiceName")
    local _DiceUseBtn = _gt.GetUI("DiceUseBtn")
    if _Dice and _DiceInfo and _DiceNum and _DiceName and _DiceUseBtn and MonopolyUI.ClientDiceList and #MonopolyUI.ClientDiceList > 0 then
        local config = DB.GetOnceItemByKey2(MonopolyUI.ClientDiceList[MonopolyUI.SelectDiceIndex].name)
        if config then
            GUI.ImageSetImageID(_Dice, tostring(config.Icon))
            GUI.StaticSetText(_DiceInfo, "将随机掷出"..tostring(MonopolyUI.ClientDiceList[MonopolyUI.SelectDiceIndex].min).."~"..tostring(MonopolyUI.ClientDiceList[MonopolyUI.SelectDiceIndex].max).."点")
            local haveCount = LD.GetItemCountById(config.Id)
            GUI.StaticSetText(_DiceNum, "剩余数量："..tostring(haveCount))
            GUI.StaticSetText(_DiceName, config.Name)
            GUI.ButtonSetShowDisable(_DiceUseBtn, haveCount>0 and not MonopolyUI.IsDuringAniLoop)
        end
    end
end

function MonopolyUI.OnSwitchBtnState()
    if MonopolyUI.ClientDiceList then
        local _DiceLastBtn = _gt.GetUI("DiceLastBtn")
        local _DiceNextBtn = _gt.GetUI("DiceNextBtn")
        if _DiceLastBtn and _DiceNextBtn then
            GUI.ButtonSetShowDisable(_DiceLastBtn, #MonopolyUI.ClientDiceList > 0 and MonopolyUI.SelectDiceIndex>1)
            GUI.ButtonSetShowDisable(_DiceNextBtn, #MonopolyUI.ClientDiceList > 0 and MonopolyUI.SelectDiceIndex < #MonopolyUI.ClientDiceList)
        end
    end
end

function MonopolyUI.BtnRollClick()
    if MonopolyUI.ClientDiceList then
        MonopolyUI.IsDuringAniLoop = true
        MonopolyUI.OnSwitchTouziInfo()
        CL.SendNotify(NOTIFY.SubmitForm, "FormChanYiLunPan", "Roll", tostring(MonopolyUI.ClientDiceList[MonopolyUI.SelectDiceIndex].name))
    end
end

function MonopolyUI.OnRollResult()
    MonopolyUI.RollResultIndex = 1
    MonopolyUI.RollWaittingIndex = 1
    GUI.SetVisible(MonopolyUI.WaittingAniInfoNode, true)
    GUI.StaticSetText(MonopolyUI.WaittingAniInfo, "投掷结果为")
    MonopolyUI.Timer1 = Timer.New(MonopolyUI.OnStartSelectItemAni, MonopolyUI.RollWaittingTime, 1)
    MonopolyUI.Timer1:Start()
    MonopolyUI.Timer2 = Timer.New(MonopolyUI.OnWaittingRollResultAni, MonopolyUI.RollWaittingTime/4, 4)
    MonopolyUI.Timer2:Start()
end

--一次投掷结果
function MonopolyUI.OnWaittingRollResultAni()
    local info = "投掷结果为"
    if MonopolyUI.RollWaittingIndex <=2 then
        for i = 1, MonopolyUI.RollWaittingIndex do
            info = info.."."
        end
    elseif MonopolyUI.RollWaittingIndex <=3 then
        info = info..".. "..tostring(MonopolyUI.RollResult[1])
    else
        info = "投掷结果为"
        GUI.SetVisible(MonopolyUI.WaittingAniInfoNode, false)
    end
    GUI.StaticSetText(MonopolyUI.WaittingAniInfo, info)
    MonopolyUI.RollWaittingIndex = MonopolyUI.RollWaittingIndex + 1
end

--二次功能骰子结果
function MonopolyUI.OnShowWaittingFuncResult()
    if MonopolyUI.RewardList then
        local itemCount = #MonopolyUI.RewardList
        if MonopolyUI.nowRollPos >= 1 and MonopolyUI.nowRollPos <= itemCount then
            --二次投掷的肯定是遇到"功能位"了
            if MonopolyUI.RewardList[MonopolyUI.nowRollPos]["Type"] ~= 0 then
                if MonopolyUI.Effect ~= nil then
                    local typeName = MonopolyUI.RewardList[MonopolyUI.nowRollPos]["Type"]
                    if MonopolyUI.Effect[typeName] ~= nil then
                        MonopolyUI.EffectTypeNode = MonopolyUI.Effect[typeName]
                        MonopolyUI.RollWaittingFuncIndex = 1
                        GUI.SetVisible(MonopolyUI.WaittingAniInfoNode, true)
                        GUI.StaticSetText(MonopolyUI.WaittingAniInfo, MonopolyUI.EffectTypeNode.Tips)
                        MonopolyUI.Timer3 = Timer.New(MonopolyUI.OnShowWaittingFuncResultAni, MonopolyUI.RollWaittingTime/2, 2)
                        MonopolyUI.Timer3:Start()
                    end
                end
            end
        end
    end
end

function MonopolyUI.OnClickItem(guid)
    local item = GUI.GetByGuid(guid)
    local clickIndex = tonumber(GUI.GetData(item, "index"))
    if MonopolyUI.RewardList then
        if MonopolyUI.RewardList[clickIndex]["Type"] ~= 0 then
            if MonopolyUI.Effect ~= nil then
                local typeName = MonopolyUI.RewardList[clickIndex]["Type"]
                if MonopolyUI.Effect[typeName] ~= nil then
                    local tip = Tips.CreateHint(MonopolyUI.Effect[typeName].Tips, item, 0, -72, UILayout.Center, nil, nil, true)
                    GUI.SetIsRemoveWhenClick(tip, true)
                end
            end
        else
            local config = DB.GetOnceItemByKey2(MonopolyUI.RewardList[clickIndex]["ItemList"][1])
            if config then
                local tip = Tips.CreateByItemId(config.Id, MonopolyUI.ItemsNode, "itemTips",-177,0,0)
                GUI.SetIsRemoveWhenClick(tip, true)
            end
        end
    end
end

function MonopolyUI.OnShowWaittingFuncResultAni()
    if MonopolyUI.EffectTypeNode then
        if MonopolyUI.RollWaittingFuncIndex == 1 then
            if MonopolyUI.RollResult then
                local stepInfo = "前进"
                if MonopolyUI.RollResult[MonopolyUI.RollResultIndex] < 0 then
                    stepInfo = "后退"
                end
                stepInfo = MonopolyUI.EffectTypeNode.ShowMsg..stepInfo..tostring(math.abs(MonopolyUI.RollResult[MonopolyUI.RollResultIndex]))
                GUI.StaticSetText(MonopolyUI.WaittingAniInfo, stepInfo)
            end
        else
            GUI.SetVisible(MonopolyUI.WaittingAniInfoNode, false)
        end
        MonopolyUI.RollWaittingFuncIndex = MonopolyUI.RollWaittingFuncIndex + 1
    end
end

function MonopolyUI.OnStartSelectItemAni()
    if MonopolyUI.RollResult ~= nil and #MonopolyUI.RollResult > 0 and MonopolyUI.RewardList then
        local count = #MonopolyUI.RewardList
        local deltaPos = MonopolyUI.RollResult[MonopolyUI.RollResultIndex]
        if deltaPos > 0 then
            MonopolyUI.rollDirtion = 1
        else
            MonopolyUI.rollDirtion = -1
        end
        MonopolyUI.targetRollPos = (MonopolyUI.nowRollPos + deltaPos) % count
        if MonopolyUI.targetRollPos == 0 then
            MonopolyUI.targetRollPos = count
        end
        if deltaPos > count then
            MonopolyUI.rollRoundNum = math.floor(deltaPos / count)
        else
            MonopolyUI.rollRoundNum = 0
        end
        local loopCount = math.abs(deltaPos)
        MonopolyUI.Timer4 = Timer.New(MonopolyUI.OnSelectItemAni, loopCount >= MonopolyUI.NumLimit and MonopolyUI.SpeedQuick or MonopolyUI.SpeedSlow, loopCount+1)
        MonopolyUI.Timer4:Start()
    end
end

function MonopolyUI.OnSelectItemAni()
    if MonopolyUI.RewardList then
        local count = #MonopolyUI.RewardList
        if MonopolyUI.rollDirtion == 1 then
            if MonopolyUI.targetRollPos > MonopolyUI.nowRollPos then
                MonopolyUI.nowRollPos = MonopolyUI.nowRollPos + 1
                MonopolyUI.UpdateSelectPos()
            elseif MonopolyUI.targetRollPos ~= MonopolyUI.nowRollPos then
                if MonopolyUI.nowRollPos < count then
                    MonopolyUI.nowRollPos = MonopolyUI.nowRollPos + 1
                    MonopolyUI.UpdateSelectPos()
                elseif MonopolyUI.nowRollPos >= count then
                    MonopolyUI.nowRollPos = 1
                    MonopolyUI.UpdateSelectPos()
                end
            else
                --走到目标位置了
                if MonopolyUI.rollRoundNum > 0 then
                    MonopolyUI.rollRoundNum = MonopolyUI.rollRoundNum - 1
                    MonopolyUI.nowRollPos = MonopolyUI.nowRollPos + 1
                    if MonopolyUI.nowRollPos > count then
                        MonopolyUI.nowRollPos = 1
                    end
                    MonopolyUI.UpdateSelectPos()
                else
                    if MonopolyUI.RollResultIndex < #MonopolyUI.RollResult then
                        MonopolyUI.RollResultIndex = MonopolyUI.RollResultIndex + 1
                        MonopolyUI.Timer5 = Timer.New(MonopolyUI.OnStartSelectItemAni, MonopolyUI.RollWaittingTime, 1)
                        MonopolyUI.Timer5:Start()
                        MonopolyUI.OnShowWaittingFuncResult()
                    else
                        MonopolyUI.IsDuringAniLoop = false
                        MonopolyUI.OnSwitchTouziInfo()
                    end
                end
            end
        else
            if MonopolyUI.targetRollPos < MonopolyUI.nowRollPos then
                MonopolyUI.nowRollPos = MonopolyUI.nowRollPos - 1
                MonopolyUI.UpdateSelectPos()
            elseif MonopolyUI.targetRollPos ~= MonopolyUI.nowRollPos then
                if MonopolyUI.nowRollPos > 1 then
                    MonopolyUI.nowRollPos = MonopolyUI.nowRollPos - 1
                    MonopolyUI.UpdateSelectPos()
                elseif MonopolyUI.nowRollPos <= 1 then
                    MonopolyUI.nowRollPos = count
                    MonopolyUI.UpdateSelectPos()
                end
            else
                --走到目标位置了
                if MonopolyUI.rollRoundNum > 0 then
                    MonopolyUI.rollRoundNum = MonopolyUI.rollRoundNum - 1
                    MonopolyUI.nowRollPos = MonopolyUI.nowRollPos - 1
                    if MonopolyUI.nowRollPos < 1 then
                        MonopolyUI.nowRollPos = count
                    end
                    MonopolyUI.UpdateSelectPos()
                else
                    if MonopolyUI.RollResultIndex < #MonopolyUI.RollResult then
                        MonopolyUI.RollResultIndex = MonopolyUI.RollResultIndex + 1
                        MonopolyUI.Timer5 = Timer.New(MonopolyUI.OnStartSelectItemAni, MonopolyUI.RollWaittingTime, 1)
                        MonopolyUI.Timer5:Start()
                        MonopolyUI.OnShowWaittingFuncResult()
                    else
                        MonopolyUI.IsDuringAniLoop = false
                        MonopolyUI.OnSwitchTouziInfo()
                    end
                end
            end
        end
    end
end

function MonopolyUI.UpdateSelectPos()
    local x,y = MonopolyUI.GetIndexPos(MonopolyUI.nowRollPos)
    GUI.SetPositionX(MonopolyUI.SelectFlag,x)
    GUI.SetPositionY(MonopolyUI.SelectFlag,y)
end

function MonopolyUI.OnDestroy()
    if MonopolyUI.Timer1 ~= nil then
        MonopolyUI.Timer1:Stop()
    end
    if MonopolyUI.Timer2 ~= nil then
        MonopolyUI.Timer2:Stop()
    end
    if MonopolyUI.Timer3 ~= nil then
        MonopolyUI.Timer3:Stop()
    end
    if MonopolyUI.Timer4 ~= nil then
        MonopolyUI.Timer4:Stop()
    end
    if MonopolyUI.Timer5 ~= nil then
        MonopolyUI.Timer5:Stop()
    end
end

function MonopolyUI.OnExit()
    GUI.DestroyWnd("MonopolyUI")
end

function MonopolyUI.GetIndexPos(index)
    if MonopolyUI.RewardList ~= nil then
        local count = #MonopolyUI.RewardList
        if index >= 1 and index <= count then
            local total = 1
            local IndexX = 0
            local IndexY = 1
            for i = 1, HOR_TOTAL do
                IndexX = IndexX + 1
                if total == index then
                    return MonopolyUI.GetItemPosition(IndexX,IndexY)
                end
                total = total + 1
            end
            IndexY = 1
            for i = 1, VER_TOTAL do
                IndexY = IndexY + 1
                if total == index then
                    return MonopolyUI.GetItemPosition(IndexX,IndexY)
                end
                total = total + 1
            end
            IndexY = IndexY + 1
            for i = 1, HOR_TOTAL do
                if total == index then
                    return MonopolyUI.GetItemPosition(IndexX,IndexY)
                end
                total = total + 1
                IndexX = IndexX - 1
            end
            IndexX = 1
            IndexY = VER_TOTAL+1
            for i = 1, VER_TOTAL do
                if total == index then
                    return MonopolyUI.GetItemPosition(IndexX,IndexY)
                end
                total = total + 1
                IndexY = IndexY - 1
            end
        end
    end
    return nil
end

function MonopolyUI.GetItemPosition(x,y)
    return (x-1)*84-420,(y-1)*81-241
end

function MonopolyUI.ShowAllItem()
    --显示道具列表
    if MonopolyUI.RewardList then
        local itemCount = #MonopolyUI.RewardList
        for i = 1, itemCount do
            local x,y = MonopolyUI.GetIndexPos(i)
            if x ~= nil and y ~= nil then
                local item = ItemIcon.Create(MonopolyUI.ItemsNode,"itemIcon"..i,x,y, 82, 82)
                GUI.SetData(item, "index", tostring(i))
                GUI.RegisterUIEvent(item, UCE.PointerClick, "MonopolyUI", "OnClickItem")
                _gt.BindName(item, "itemIcon"..i)
                if MonopolyUI.RewardList[i]["Type"] == 0 then
                    local config = DB.GetOnceItemByKey2(MonopolyUI.RewardList[i]["ItemList"][1])
                    if config then
                        ItemIcon.BindItemId(item, config.Id)
                        if MonopolyUI.RewardList[i]["ItemList"][2] and MonopolyUI.RewardList[i]["ItemList"][2] > 1 then
                            GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, tostring(MonopolyUI.RewardList[i]["ItemList"][2]))
                        end
                    end
                else
                    if MonopolyUI.Effect ~= nil then
                        local typeName = MonopolyUI.RewardList[i]["Type"]
                        if MonopolyUI.Effect[typeName] ~= nil then
                            GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, tostring(MonopolyUI.Effect[typeName].Icon))
                            GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, 0,70,70)
                        end
                    end
                end
            end
        end
    end

    --显示骰子
    MonopolyUI.SelectDiceIndex = 1
    MonopolyUI.ClientDiceList = {}
    local count = 1
    if MonopolyUI.DiceList ~= nil then
        for i=1, #MonopolyUI.DiceList do
            local diceData = MonopolyUI.DiceList[i]
            table.insert(MonopolyUI.ClientDiceList, count,{name=diceData.Name, min=diceData.Min, max=diceData.Max})
            --需要默认选中
            if MonopolyUI.DefaultSelectTouziID ~= 0 then
                local config = DB.GetOnceItemByKey2(diceData.Name)
                if config and config.Id == MonopolyUI.DefaultSelectTouziID then
                    MonopolyUI.SelectDiceIndex =  count
                end
            end
            count = count + 1
        end
    end
    MonopolyUI.OnSwitchTouziInfo()
    MonopolyUI.OnSwitchBtnState()

    --设置光标位置
    MonopolyUI.nowRollPos = CL.GetIntCustomData("ChanYiLunPanNowPos")
    local x,y = MonopolyUI.GetIndexPos(MonopolyUI.nowRollPos)
    if x and y then
        GUI.SetPositionX(MonopolyUI.SelectFlag,x)
        GUI.SetPositionY(MonopolyUI.SelectFlag,y)
        GUI.SetVisible(MonopolyUI.SelectFlag, true)
    end
end