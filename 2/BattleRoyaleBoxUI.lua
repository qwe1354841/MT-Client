BattleRoyaleBoxUI = {}
local _gt = UILayout.NewGUIDUtilTable()

BattleRoyaleBoxUI.ClickItemGuid = ""
function BattleRoyaleBoxUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    local wnd = GUI.WndCreateWnd("BattleRoyaleBoxUI","BattleRoyaleBoxUI",0,0)

    local group = GUI.GroupCreate(wnd,"group", 0, 0, 300, 180)
    UILayout.SetSameAnchorAndPivot(group, UILayout.Center)
    _gt.BindName(group,"BattleRoyaleBox")

    local panelBg = GUI.ImageCreate( group,"center", "1800200010", 0, 0, false, 240, 200)
    GUI.SetIsRaycastTarget(panelBg, true)
    local closeBtn = GUI.ButtonCreate( panelBg,"closeBtn", "1800302120", 4, -4, Transition.ColorTint)
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "BattleRoyaleBoxUI", "OnExit")

    local tipLabel = GUI.CreateStatic( panelBg,"tipLabel", "--物品信息--", 0, 21, 150, 35)
    UILayout.StaticSetFontSizeColorAlignment(tipLabel, UIDefine.FontSizeM, UIDefine.WhiteColor, TextAnchor.MiddleCenter)
    UILayout.SetAnchorAndPivot(tipLabel, UIAnchor.Top, UIAroundPivot.Center)

    local itemSrc = GUI.LoopScrollRectCreate(panelBg,"itemSrc",10,40,220,150,"BattleRoyaleBoxUI","CreateItemIcon",
                        "BattleRoyaleBoxUI","RefreshItemIcon",0,false,Vector2.New(70, 70),3,UIAroundPivot.TopLeft,UIAnchor.TopLeft)
    UILayout.SetSameAnchorAndPivot(itemSrc, UILayout.TopLeft)
    GUI.ScrollRectSetChildSpacing(itemSrc, Vector2.New(3, 3))
    _gt.BindName(itemSrc, "itemSrc")
end

function BattleRoyaleBoxUI.OnExit()
    GUI.CloseWnd("BattleRoyaleBoxUI")
end

function BattleRoyaleBoxUI.OnEnterFight(isInfight)
    isInfight = isInfight or CL.GetFightViewState() or CL.GetFightState()
    if isInfight then
        BattleRoyaleBoxUI.OnExit()
    end
end

function BattleRoyaleBoxUI.OnClose()
    local BattleRoyaleBox = _gt.GetUI("BattleRoyaleBox")
    local itemTips = GUI.GetChild(BattleRoyaleBox,"itemTips")
    GUI.Destroy(itemTips)
    BattleRoyaleBoxUI.ItemInfo = {}
    BattleRoyaleBoxUI.RefreshBoxInfo()
    CL.UnRegisterMessage(GM.MoveStart, "BattleRoyaleBoxUI", "OnExit")
    CL.UnRegisterMessage(GM.FightStateNtf, "BattleRoyaleBoxUI", "OnEnterFight")
end

function BattleRoyaleBoxUI.OnShow()
    local wnd = GUI.GetWnd("BattleRoyaleBoxUI")
    if wnd == nil then
        return
    end
    CL.RegisterMessage(GM.MoveStart, "BattleRoyaleBoxUI", "OnExit")
    CL.RegisterMessage(GM.FightStateNtf, "BattleRoyaleBoxUI", "OnEnterFight")
    BattleRoyaleBoxUI.OnEnterFight()
    BattleRoyaleBoxUI.RefreshBoxInfo()
    GUI.SetVisible(wnd,true)
end

function BattleRoyaleBoxUI.RefreshBoxInfo()
    local scroll = _gt.GetUI("itemSrc")
    GUI.LoopScrollRectSetTotalCount(scroll, 0)
    local bagNum = 6
    if BattleRoyaleBoxUI.ItemMaxIndex then
        if BattleRoyaleBoxUI.ItemMaxIndex % 3 == 0 then
            bagNum = math.max(BattleRoyaleBoxUI.ItemMaxIndex, 6)
        else
            bagNum = math.max((math.floor(BattleRoyaleBoxUI.ItemMaxIndex / 3) +1) *3, 6)
        end
    end
    GUI.LoopScrollRectSetTotalCount(scroll, 0)
    GUI.LoopScrollRectSetTotalCount(scroll, bagNum)
    GUI.LoopScrollRectRefreshCells(scroll)
end

function BattleRoyaleBoxUI.CreateItemIcon()
    local itemSrc = _gt.GetUI("itemSrc")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemSrc) + 1
    local itemicon = ItemIcon.Create(itemSrc, "itemicon" .. curCount, 0, 0,70,70)
    local ItemSelected = GUI.ImageCreate(itemicon,"ItemSelected", "1800400280", -1, -1, false, 72, 72)
    GUI.SetVisible(ItemSelected,false)
    GUI.RegisterUIEvent(itemicon, UCE.PointerClick, "BattleRoyaleBoxUI", "OnItemClick")
    return itemicon
end

function BattleRoyaleBoxUI.RefreshItemIcon(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    local ItemSelected = GUI.GetChild(item,"ItemSelected")
    GUI.SetVisible(ItemSelected,false)
    if BattleRoyaleBoxUI.ItemInfo and BattleRoyaleBoxUI.ItemInfo[index] then
        local itemName = BattleRoyaleBoxUI.ItemInfo[index].Name
        local itemType = BattleRoyaleBoxUI.ItemInfo[index].Type
        local itemInfo = TrackUI.Act_Chickings_Config[itemType][itemName]

        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, UIDefine.ItemIconBg[itemInfo.Grade])
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, itemInfo.Icon)
        GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,60,60)
        GUI.SetData(item,"index",index)
    else
        ItemIcon.BindItemId(item)
        GUI.SetData(item,"index",nil)
    end
end

function BattleRoyaleBoxUI.OnItemClick(guid)
    local item = GUI.GetByGuid(guid)
    local ItemSelected = GUI.GetChild(item,"ItemSelected")
    local index = tonumber(GUI.GetData(item,"index"))
    local BattleRoyaleBox = _gt.GetUI("BattleRoyaleBox")
    local haveItem = false
    if index then
        haveItem = true
        local itemName = BattleRoyaleBoxUI.ItemInfo[index].Name
        local itemType = BattleRoyaleBoxUI.ItemInfo[index].Type
        local itemInfo = TrackUI.Act_Chickings_Config[itemType][itemName]
        local itemTips = Tips.CreateChinkingItemTipsByInfo(itemInfo, itemName, BattleRoyaleBox, "itemTips", -400, 0, 300,50)
        local ReceiveItemBtn = GUI.ButtonCreate(itemTips, "ReceiveItemBtn", 1800402110, 0, -10, Transition.ColorTint, "领取物资", 150, 50, false);
        UILayout.SetSameAnchorAndPivot(ReceiveItemBtn, UILayout.Bottom);
        GUI.ButtonSetTextColor(ReceiveItemBtn, UIDefine.BrownColor);
        GUI.ButtonSetTextFontSize(ReceiveItemBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(ReceiveItemBtn, UCE.PointerClick, "BattleRoyaleBoxUI", "OnReceiveItemBtnClick");
    end
    GUI.SetVisible(ItemSelected,haveItem)
    if BattleRoyaleBoxUI.ClickItemGuid ~= guid then
        local LastClickItem = GUI.GetByGuid(BattleRoyaleBoxUI.ClickItemGuid)
        if LastClickItem then
            ItemSelected = GUI.GetChild(LastClickItem,"ItemSelected")
            GUI.SetVisible(ItemSelected,false)
        end
        BattleRoyaleBoxUI.ClickItemGuid = guid
    end
end

function BattleRoyaleBoxUI.OnReceiveItemBtnClick()
    local item = GUI.GetByGuid(BattleRoyaleBoxUI.ClickItemGuid)
    local index = tonumber(GUI.GetData(item,"index"))
    local itemName = BattleRoyaleBoxUI.ItemInfo[index].Name
    local itemType = BattleRoyaleBoxUI.ItemInfo[index].Type
    local FightBuffName = ""
    local haveSameFightBuff = false
    if itemType == "FightBuffs" then
        for i = 1, #TrackUI.UpdateBattleRoyaleItems, 1 do
            local BattleBagItem = TrackUI.UpdateBattleRoyaleItems[i]
            if BattleBagItem and itemType == BattleBagItem.Type then
                local FightBuffsType1 = TrackUI.Act_Chickings_Config[itemType][itemName].Type
                local FightBuffsType2 = TrackUI.Act_Chickings_Config[itemType][BattleBagItem.Name].Type
                if FightBuffsType1 == FightBuffsType2 then
                    haveSameFightBuff = true
                    FightBuffName = BattleBagItem.Name
                    break
                end
            end
        end
    end
    if haveSameFightBuff then
        if FightBuffName == itemName then
            CL.SendNotify(NOTIFY.ShowBBMsg,"您已经拥有当前属性增幅道具了！")
            return
        end
        local FightBuffsGrade1 = TrackUI.Act_Chickings_Config[itemType][itemName].Grade
        local FightBuffsGrade2 = TrackUI.Act_Chickings_Config[itemType][FightBuffName].Grade
        -- test(FightBuffsGrade1,type(FightBuffsGrade1))
        -- test(FightBuffsGrade2,type(FightBuffsGrade2))
        GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("是否替换", "您已有增强属性的<color=#"..UIDefine.GradeColorLabel[FightBuffsGrade2]..">"..FightBuffName.."</color>，是否替换为<color=#"..UIDefine.GradeColorLabel[FightBuffsGrade1]..">"..itemName.."</color>？", "BattleRoyaleBoxUI", "确定", "confirm", "取消")
    else
        BattleRoyaleBoxUI.confirm()
    end
    -- test(itemName,itemType,itemInfo.Type)
end

function BattleRoyaleBoxUI.confirm()
    local item = GUI.GetByGuid(BattleRoyaleBoxUI.ClickItemGuid)
    local index = tonumber(GUI.GetData(item,"index"))
    CL.SendNotify(NOTIFY.SubmitForm,"FormAct_Chikings","GetItem",index)
end

function BattleRoyaleBoxUI.ChestOpen(table)
    BattleRoyaleBoxUI.ItemInfo = table
    BattleRoyaleBoxUI.ItemMaxIndex = 0
    for i = 1, TrackUI.BattleBagSize, 1 do
        if BattleRoyaleBoxUI.ItemInfo[i] ~= nil then
            BattleRoyaleBoxUI.ItemMaxIndex = i
        end
    end
    if BattleRoyaleBoxUI.ItemMaxIndex == 0 then
        BattleRoyaleBoxUI.OnExit()
    end
end
