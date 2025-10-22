local SpinWinEX = {}

_G.SpinWinEX = SpinWinEX
local GuidCacheUtil = nil ---UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local HOR_TOTAL = 11
local VER_TOTAL = 5
--设置字体颜色
local colorDark = UIDefine.BrownColor --Color.New(102/255,47/255,22/255,255/255)
local colorWhite = UIDefine.WhiteColor -- Color.New(255/255, 246/255, 232/255, 255/255)
local button_color = Color.New(133 / 255, 83 / 255, 61 / 255, 255 / 255)
local sizeTitle = 26
local sizeTitleS = 24
local sizeTxt = 22

local RollWaittingTime = 2.5
local StepTime = 0.25
local CurKeyIndex = 1 --- 当前开宝箱钥匙的索引下标

function SpinWinEX.Main()
    GuidCacheUtil = UILayout.NewGUIDUtilTable()
    local _Panel = GUI.WndCreateWnd("SpinWinEX", "SpinWinEX", 0, 0, eCanvasGroup.Normal)
    local _PanelCover = GUI.ImageCreate(_Panel, "PanelCover", "1800400220", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
    SetAnchorAndPivot(_PanelCover, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(_PanelCover, true)
    _PanelCover:RegisterEvent(UCE.PointerClick)

    --local _PanelBg = GUI.ImageCreate(_Panel, "panelBg", "", 0, 20, false, 0, 0)
    local _PanelBg = GUI.GroupCreate(_Panel, "panelBg", 0, 20, 0, 0)
    GuidCacheUtil.BindName(_PanelBg, "panelBg")
    SetAnchorAndPivot(_PanelBg, UIAnchor.Center, UIAroundPivot.Center)

    local _Bg_Left = GUI.ImageCreate(_PanelBg, "Bg_Left", "1801601010", -290, 10, false, 580, 650)
    SetAnchorAndPivot(_Bg_Left, UIAnchor.Center, UIAroundPivot.Center)

    local _Bg_Right = GUI.ImageCreate(_PanelBg, "Bg_Right", "1801601010", 290, 10, false, 580, 650)
    SetAnchorAndPivot(_Bg_Right, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetScale(_Bg_Right, Vector3.New(-1, 1, 1))

    local _TitleBg = GUI.ImageCreate(_PanelBg, "TitleBg", "1801608020", 0, -309)
    SetAnchorAndPivot(_TitleBg, UIAnchor.Top, UIAroundPivot.Center)

    local _Pic1 = GUI.ImageCreate(_PanelBg, "Pic1", "1801608030", -534, 228)
    SetAnchorAndPivot(_Pic1, UIAnchor.Top, UIAroundPivot.Center)
    local _Pic2 = GUI.ImageCreate(_PanelBg, "Pic2", "1801608070", -484, -266)
    SetAnchorAndPivot(_Pic2, UIAnchor.Top, UIAroundPivot.Center)
    local _Pic3 = GUI.ImageCreate(_PanelBg, "Pic3", "1801608080", 526, 128)
    SetAnchorAndPivot(_Pic3, UIAnchor.Top, UIAroundPivot.Center)

    local _CloseBtn = GUI.ButtonCreate(_PanelBg, "CloseBtn", "1801602010", 561, -240, Transition.ColorTint)
    SetAnchorAndPivot(_CloseBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(_CloseBtn, UCE.PointerClick, "SpinWinEX", "OnCloseWnd")

    local _Bg1 = GUI.ImageCreate(_PanelBg, "Bg1", "1800400010", 0, 5, false, 964, 575)
    SetAnchorAndPivot(_Bg1, UIAnchor.Center, UIAroundPivot.Center)

    local _Bg2 = GUI.ImageCreate(_Bg1, "Bg2", "1800201130", 0, 0, false, 792, 400)
    SetAnchorAndPivot(_Bg2, UIAnchor.Center, UIAroundPivot.Center)

    --local _ItemNode = GUI.ImageCreate(_Bg1, "ItemNode", "", 0, 0)
    local _ItemNode = GUI.GroupCreate(_Bg1, "ItemNode", 0, 0, 0, 0)
    GuidCacheUtil.BindName(_ItemNode, "ItemNode")

    local SelectFlag = GUI.ImageCreate(_Bg1, "SelectFlag", "1800400280", 0, 0, false, 82, 82)
    GuidCacheUtil.BindName(SelectFlag, "SelectFlag")
    UILayout.SetSameAnchorAndPivot(SelectFlag, UILayout.Center)
    GUI.SetVisible(SelectFlag, false)

    local _Pic = GUI.ImageCreate(_Bg2, "Pic", "1801608010", 3, 2)
    SetAnchorAndPivot(_Pic, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _PicTxt = GUI.ImageCreate(_Pic, "PicTxt", "1801608040", 10, 20)
    GuidCacheUtil.BindName(_PicTxt, "PicTxt")
    SetAnchorAndPivot(_PicTxt, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _DiceNote = GUI.GroupCreate(_Bg2, "DiceNote",590, 50, 0, 0)
    SetAnchorAndPivot(_DiceNote, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _DiceName = GUI.CreateStatic(_DiceNote, "DiceName", "", 15, 64.5, 150, 50, "system", true)
    GuidCacheUtil.BindName(_DiceName, "DiceName")
    SetAnchorAndPivot(_DiceName, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_DiceName, sizeTitleS)
    GUI.StaticSetAlignment(_DiceName, TextAnchor.MiddleCenter)
    GUI.SetColor(_DiceName, colorWhite)

    local _DiceNum = GUI.CreateStatic(_DiceNote, "DiceNum", "", 20, 105, 200, 50, "system", true)
    GuidCacheUtil.BindName(_DiceNum, "DiceNum")
    SetAnchorAndPivot(_DiceNum, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_DiceNum, sizeTxt)
    GUI.StaticSetAlignment(_DiceNum, TextAnchor.MiddleCenter)
    GUI.SetColor(_DiceNum, colorDark)

    local _Dice = GUI.ImageCreate(_DiceNote, "Dice", "", 20, 185, false, 100, 100)
    GuidCacheUtil.BindName(_Dice, "Dice")
    SetAnchorAndPivot(_Dice, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(_Dice, false)

    local _DiceInfo = GUI.CreateStatic(_DiceNote, "DiceInfo", "~", 21, 255, 200, 50, "system", true)
    GuidCacheUtil.BindName(_DiceInfo, "DiceInfo")
    SetAnchorAndPivot(_DiceInfo, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_DiceInfo, sizeTxt)
    GUI.StaticSetAlignment(_DiceInfo, TextAnchor.MiddleCenter)
    GUI.SetColor(_DiceInfo, colorDark)

    local _DiceUseBtn = GUI.ButtonCreate(_DiceNote, "DiceUseBtn", "1800102090", 20, 310, Transition.ColorTint)
    GuidCacheUtil.BindName(_DiceUseBtn, "DiceUseBtn")
    SetAnchorAndPivot(_DiceUseBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(_DiceUseBtn, UCE.PointerClick, "SpinWinEX", "BtnRollClick")

    local _DiceLastBtn = GUI.ButtonCreate(_DiceNote, "DiceLastBtn", "1800602190", -90, 175, Transition.ColorTint)
    GuidCacheUtil.BindName(_DiceLastBtn, "DiceLastBtn")
    SetAnchorAndPivot(_DiceLastBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(_DiceLastBtn, UCE.PointerClick, "SpinWinEX", "DiceSwitchSub")

    local _DiceNextBtn = GUI.ButtonCreate(_DiceNote, "DiceNextBtn", "1800602120", 132, 175, Transition.ColorTint)
    GuidCacheUtil.BindName(_DiceNextBtn, "DiceNextBtn")
    SetAnchorAndPivot(_DiceNextBtn, UIAnchor.Center, UIAroundPivot.Center)
    GUI.RegisterUIEvent(_DiceNextBtn, UCE.PointerClick, "SpinWinEX", "DiceSwitchAdd")

    local _DiceBtnTxt = GUI.CreateStatic(_DiceUseBtn, "DiceInfo", "开启宝箱", 0, 0, 200, 50, "system", true)
    SetAnchorAndPivot(_DiceBtnTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_DiceBtnTxt, sizeTitle)
    GUI.StaticSetAlignment(_DiceBtnTxt, TextAnchor.MiddleCenter)
    GUI.SetColor(_DiceBtnTxt, colorWhite)
    GUI.SetIsOutLine(_DiceBtnTxt, true)
    GUI.SetOutLine_Color(_DiceBtnTxt, button_color)
    GUI.SetOutLine_Distance(_DiceBtnTxt, 1)

    --骰子结果
    local _PanelCover = GUI.ImageCreate(_Panel, "PanelCover", "1800400220", 0, 0, false, GUI.GetWidth(_Panel), GUI.GetHeight(_Panel))
    GuidCacheUtil.BindName(_PanelCover, "ResultPanel")
    UILayout.SetSameAnchorAndPivot(_PanelCover, UILayout.Center)
    GUI.SetIsRaycastTarget(_PanelCover, true)
    GUI.SetVisible(_PanelCover, false)

    local _ResultBg = GUI.ImageCreate(_PanelCover, "ResultBg", "1800700180", 0, 0, false, 500, 100)
    UILayout.SetSameAnchorAndPivot(_ResultBg, UILayout.Center)

    local _ResultTxt = GUI.CreateStatic(_ResultBg, "WaittingAniInfo", "投掷结果为", 0, 2, 500, 50, "system", true)
    GuidCacheUtil.BindName(_ResultTxt, "ResultTxt")
    UILayout.SetSameAnchorAndPivot(_ResultTxt, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_ResultTxt, 26, UIDefine.BrownColor, TextAnchor.MiddleCenter)

    CL.RegisterMessage(GM.RefreshBag, "SpinWinEX", "RefreshBag")
end

function SpinWinEX.RefreshBag()
    SpinWinEX.DiceShow()
end

function SpinWinEX.OnShow(key)
    SpinWinEX.Change = 0
    local wnd = GUI.GetWnd("SpinWinEX")
    GUI.SetVisible(wnd, true)
end

function SpinWinEX.OnCloseWnd()
	GUI.CloseWnd("SpinWinEX")
end

function SpinWinEX.OnClose()
    if SpinWinEX.SelectItemTimer then
        SpinWinEX.SelectItemTimer:Stop()
        SpinWinEX.SelectItemTimer = nil
    end
end

---脚本调过来刷新接口
function SpinWinEX.RefreshData()
    CurKeyIndex = 1
    local list = SpinWinEX.DiceList
    if list then
        for i = 1, #list do
            local data = list[i]
            local itemDB = DB.GetOnceItemByKey2(data.Name)
            local num = LD.GetItemCountById(itemDB.Id)
            if num > 0 then
                CurKeyIndex = i
                break
            end
        end
    end
    SpinWinEX.RefreshPage()
end

function SpinWinEX.RefreshPage()
    local diceLastBtn = GuidCacheUtil.GetUI("DiceLastBtn")
    GUI.ButtonSetShowDisable(diceLastBtn, CurKeyIndex > 1)
    local diceNextBtn = GuidCacheUtil.GetUI("DiceNextBtn")
    GUI.ButtonSetShowDisable(diceNextBtn, CurKeyIndex < #SpinWinEX.DiceList)
    SpinWinEX.ShowAllItem()
    SpinWinEX.DiceShow()
end

function SpinWinEX.GetIndexPos(index, count)
    if SpinWinEX.RewardList ~= nil then
        count = count or #SpinWinEX.RewardList[CurKeyIndex]
        index = (index - 1) % count + 1
        if index < 0 then
            index = index + count
        end
        if index >= 1 and index <= count then
            local total = 1
            local IndexX = 0
            local IndexY = 1
            for i = 1, HOR_TOTAL do
                IndexX = IndexX + 1
                if total == index then
                    return SpinWinEX.GetItemPosition(IndexX, IndexY)
                end
                total = total + 1
            end
            IndexY = 1
            for i = 1, VER_TOTAL do
                IndexY = IndexY + 1
                if total == index then
                    return SpinWinEX.GetItemPosition(IndexX, IndexY)
                end
                total = total + 1
            end
            IndexY = IndexY + 1
            for i = 1, HOR_TOTAL do
                if total == index then
                    return SpinWinEX.GetItemPosition(IndexX, IndexY)
                end
                total = total + 1
                IndexX = IndexX - 1
            end
            IndexX = 1
            IndexY = VER_TOTAL + 1
            for i = 1, VER_TOTAL do
                if total == index then
                    return SpinWinEX.GetItemPosition(IndexX, IndexY)
                end
                total = total + 1
                IndexY = IndexY - 1
            end
        end
    end
    return nil
end

function SpinWinEX.GetItemPosition(x, y)
    return (x - 1) * 87 - 435, (y - 1) * 81 - 241
end

function SpinWinEX.ShowAllItem(idx)
    idx = idx or CurKeyIndex
    --显示道具列表
    if SpinWinEX.RewardList then
        local rewardList = SpinWinEX.RewardList[idx]
        local itemCount = #rewardList
        local _ItemNode = GuidCacheUtil.GetUI("ItemNode")
        for i = 1, itemCount do
            local x, y = SpinWinEX.GetIndexPos(i, itemCount)
            if x ~= nil and y ~= nil then
                local name = "itemIcon" .. i
                local item = GuidCacheUtil.GetUI(name)
                if not item then
                    item = ItemIcon.Create(_ItemNode, name, x, y, 82, 82)
                    GUI.SetData(item, "index", tostring(i))
                    GUI.RegisterUIEvent(item, UCE.PointerClick, "SpinWinEX", "OnClickItem")
                    GuidCacheUtil.BindName(item, name)
                end

                if rewardList[i]["Type"] == 0 then
                    local config = DB.GetOnceItemByKey2(rewardList[i]["ItemList"][1])
                    if config then
                        ItemIcon.BindItemId(item, config.Id)
                        if rewardList[i]["ItemList"][2] and rewardList[i]["ItemList"][2] > 1 then
                            GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, tostring(rewardList[i]["ItemList"][2]))
                        end
                    end
                else
                    if SpinWinEX.Effect ~= nil then
                        local typeName = rewardList[i]["Type"]
                        if SpinWinEX.Effect[typeName] ~= nil then
                            GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, tostring(SpinWinEX.Effect[typeName].Icon))
                            GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, 0, 70, 70)
                        end
                    end
                end
            end
        end
    end

    --设置光标位置
    SpinWinEX.nowRollPos = CL.GetIntCustomData("XianShouFuYuanNowPos_" .. CurKeyIndex)
    local selectFlag = GuidCacheUtil.GetUI("SelectFlag")
    local x, y = SpinWinEX.GetIndexPos(SpinWinEX.nowRollPos)
    if x and y then
        GUI.SetPositionX(selectFlag, x)
        GUI.SetPositionY(selectFlag, y)
        GUI.SetVisible(selectFlag, true)
    end

    local PicTxt = GuidCacheUtil.GetUI("PicTxt")
    GUI.ImageSetImageID(PicTxt, tostring(SpinWinEX.DiceList[CurKeyIndex].ShowImg))
end

function SpinWinEX.OnClickItem(guid)
    local item = GUI.GetByGuid(guid)
    local clickIndex = tonumber(GUI.GetData(item, "index"))
    if SpinWinEX.RewardList then
        local data = SpinWinEX.RewardList[CurKeyIndex][clickIndex]
        local typeName = data.Type
        if typeName ~= 0 then
            if SpinWinEX.Effect ~= nil then
                if SpinWinEX.Effect[typeName] ~= nil then
                    local tip = Tips.CreateHint(SpinWinEX.Effect[typeName].Tips, item, 0, -72, UILayout.Center, nil, nil, true)
                end
            end
        else
            local config = DB.GetOnceItemByKey2(data.ItemList[1])
            local panelBg = GuidCacheUtil.GetUI("panelBg")
            local tip = Tips.CreateByItemId(config.Id, panelBg, "itemTips", -177, 0, 0)
        end
    end
end

--- 投掷结果刷新
function SpinWinEX.OnRollResult()
    SpinWinEX.RollResultIndex = 1
    SpinWinEX.RollWaittingIndex = 1
    local cover = GuidCacheUtil.GetUI("ResultPanel")
    GUI.SetVisible(cover, true)
    local info = GuidCacheUtil.GetUI("ResultTxt")
    GUI.StaticSetText(info, "投掷结果为")
    Timer.New(SpinWinEX.OnStartSelectItemAni, RollWaittingTime, 1):Start()
    Timer.New(SpinWinEX.OnWaittingRollResultAni, RollWaittingTime / 4, 4):Start()
end

function SpinWinEX.OnStartSelectItemAni()
    local movePos = SpinWinEX.RollResult[SpinWinEX.RollResultIndex]
    SpinWinEX.targetPos = SpinWinEX.nowRollPos + movePos
    if SpinWinEX.SelectItemTimer then
        SpinWinEX.SelectItemTimer:Stop()
    end
    SpinWinEX.SelectItemTimer = Timer.New(SpinWinEX.SelectItemAni, StepTime, math.abs(movePos) + 1)
    SpinWinEX.SelectItemTimer:Start()
end

function SpinWinEX.OnWaittingRollResultAni()
    if SpinWinEX.RollWaittingIndex >= 4 then
        local cover = GuidCacheUtil.GetUI("ResultPanel")
        GUI.SetVisible(cover, false)
        return
    end
    local info = GuidCacheUtil.GetUI("ResultTxt")
    local txt = ""
    if SpinWinEX.RollWaittingIndex <= 2 then
        txt = GUI.StaticGetText(info) .. "."
    elseif SpinWinEX.RollWaittingIndex <= 3 then
        txt = GUI.StaticGetText(info) .. SpinWinEX.RollResult[SpinWinEX.RollResultIndex]
    end
    GUI.StaticSetText(info, txt)
    SpinWinEX.RollWaittingIndex = SpinWinEX.RollWaittingIndex + 1
end

function SpinWinEX.SelectItemAni()
    if SpinWinEX.nowRollPos == SpinWinEX.targetPos then
        SpinWinEX.ShowNextAni()
        return
    end
    if SpinWinEX.nowRollPos < SpinWinEX.targetPos then
        SpinWinEX.nowRollPos = SpinWinEX.nowRollPos + 1
    elseif SpinWinEX.nowRollPos > SpinWinEX.targetPos then
        SpinWinEX.nowRollPos = SpinWinEX.nowRollPos - 1
    end
    local selectFlag = GuidCacheUtil.GetUI("SelectFlag")
    local x, y = SpinWinEX.GetIndexPos(SpinWinEX.nowRollPos)
    if x and y then
        GUI.SetPositionX(selectFlag, x)
        GUI.SetPositionY(selectFlag, y)
    end
end

function SpinWinEX.ShowNextAni()
    if SpinWinEX.RollResultIndex == #SpinWinEX.RollResult then
        SpinWinEX.Change = 0
        SpinWinEX.RefreshPage()
        return
    end
    SpinWinEX.RollResultIndex = SpinWinEX.RollResultIndex + 1
    SpinWinEX.RollWaittingIndex = 1
    local rewardList = SpinWinEX.RewardList[CurKeyIndex]
    local data = rewardList[(SpinWinEX.nowRollPos - 1) % #rewardList + 1]
    local effect = SpinWinEX.Effect[data.Type]
    local cover = GuidCacheUtil.GetUI("ResultPanel")
    GUI.SetVisible(cover, true)
    local info = GuidCacheUtil.GetUI("ResultTxt")
    GUI.StaticSetText(info, effect.ShowMsg)
    Timer.New(SpinWinEX.OnStartSelectItemAni, RollWaittingTime, 1):Start()
    Timer.New(SpinWinEX.ShowTipAni, RollWaittingTime / 2, 2):Start()
end

function SpinWinEX.ShowTipAni()
    if SpinWinEX.RollWaittingIndex == 1 then
        local movePos = SpinWinEX.RollResult[SpinWinEX.RollResultIndex]
        local txt = (movePos > 0 and "前进" or "后退") .. math.abs(movePos)
        local info = GuidCacheUtil.GetUI("ResultTxt")
        GUI.StaticSetText(info, GUI.StaticGetText(info) .. txt)
        SpinWinEX.RollWaittingIndex = SpinWinEX.RollWaittingIndex + 1
    else
        local cover = GuidCacheUtil.GetUI("ResultPanel")
        GUI.SetVisible(cover, false)
        SpinWinEX.OnStartSelectItemAni()
    end
end

function SpinWinEX.DiceSwitchAdd()
    local count = #SpinWinEX.DiceList
    if CurKeyIndex >= count then
        return
    end
    CurKeyIndex = CurKeyIndex + 1
    SpinWinEX.RefreshPage()
end

function SpinWinEX.DiceSwitchSub()
    if CurKeyIndex <= 1 then
        return
    end
    CurKeyIndex = CurKeyIndex - 1
    SpinWinEX.RefreshPage()
end

function SpinWinEX.DiceShow(idx)
    idx = idx or CurKeyIndex
    local data = SpinWinEX.DiceList[idx]
    local itemDB = DB.GetOnceItemByKey2(data.Name)

    local item_id = itemDB.Id
    local num_min = data.Min
    local num_max = data.Max
    SpinWinEX.item_num = LD.GetItemCountById(item_id)
    SpinWinEX.item_id = item_id
    local BigIcon = itemDB.Icon

    local Name = itemDB.Name
    local _DiceName = GuidCacheUtil.GetUI("DiceName")
    GUI.StaticSetText(_DiceName, Name)

    local _DiceNum = GuidCacheUtil.GetUI("DiceNum")
    GUI.StaticSetText(_DiceNum, "剩余数量：" .. tostring(SpinWinEX.item_num))

    local _DiceInfo = GuidCacheUtil.GetUI("DiceInfo")
    GUI.StaticSetText(_DiceInfo, "将随机前进" .. tostring(num_min) .. "~" .. tostring(num_max) .. "点")

    local _Dice = GuidCacheUtil.GetUI("Dice")
    GUI.ImageSetImageID(_Dice, tostring(BigIcon))

    local _DiceUseBtn = GuidCacheUtil.GetUI("DiceUseBtn")
    if SpinWinEX.Change == 0 then
        GUI.ButtonSetShowDisable(_DiceUseBtn, SpinWinEX.item_num > 0)
    end

    GUI.SetVisible(_Dice, true)
end

function SpinWinEX.BtnRollClick()
    SpinWinEX.Change = 1
    CL.SendNotify(NOTIFY.SubmitForm, "FormXianShouFuYuan", "Roll", SpinWinEX.DiceList[CurKeyIndex].Name)
    local _DiceUseBtn = GuidCacheUtil.GetUI("DiceUseBtn")
    local _DiceLastBtn = GuidCacheUtil.GetUI("DiceLastBtn")
    local _DiceNextBtn = GuidCacheUtil.GetUI("DiceNextBtn")
    if _DiceUseBtn and _DiceLastBtn and _DiceNextBtn then
        GUI.ButtonSetShowDisable(_DiceUseBtn, false)
        GUI.ButtonSetShowDisable(_DiceLastBtn, false)
        GUI.ButtonSetShowDisable(_DiceNextBtn, false)
    end
end