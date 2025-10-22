TradeUI = {}

require "UILayout"
--#require "Tips"

local panelBgPath = "TradeUI/panelBg"
local leftBgPath = "TradeUI/panelBg/leftBg"
local confirmPopupPath = panelBgPath .. "/confirmPopup"

local labelList_1 = {
    { "", "myLabelBtn", "1800400470", "1800400471", "OnMyLabelBtn", -413, -240, 100, 40, 201, 42 },
    { "", "anotherLabelBtn", "1800400470", "1800400471", "OnAnotherLabelBtn", -185, -240, 100, 40, 255, 42 },
}

local labelList_2 = {
    { "物品", "itemLabelBtn", "1800402010", "1800402011", "OnItemLabelBtnClick", 577, -166, 25, 60, 0, 0 },
    { "宠物", "petLabelBtn", "1800402010", "1800402011", "OnPetLabelBtnClick", 577, -44, 25, 60, 0, 0 },
}

local _gt = UILayout.NewGUIDUtilTable()

function TradeUI.Main(parameter)
    test("TradeUI.Main")
    local panel = GUI.WndCreateWnd("TradeUI", "TradeUI", 0, 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "交    易", "TradeUI", "OnClose", _gt)

    local leftBg = GUI.ImageCreate(panelBg, "leftBg", "1800400200", -265, 10, false, 500, 540)
    local itemImg = GUI.ImageCreate(leftBg, "itemImg", "1800404130", 40, -130)
    GUI.SetAnchor(itemImg, UIAnchor.Left)
    local petImg = GUI.ImageCreate(leftBg, "petImg", "1800404140", 40, 90)
    GUI.SetAnchor(petImg, UIAnchor.Left)

    local itemScr = GUI.ScrollRectCreate(leftBg, "itemScr", 30, -130, 400, 180, 0, false, Vector2.New(82, 82), UIAroundPivot.Top, UIAnchor.Top, 4)
    GUI.ScrollRectSetChildSpacing(itemScr, Vector2.New(20, 10))

    for i = 1, 8 do
        local iconBg = GUI.ItemCtrlCreate(itemScr, "iconBg" .. i, UIDefine.ItemIconBg[1], 0, 0)
        GUI.SetData(iconBg, "Index", i)
        GUI.RegisterUIEvent(iconBg, UCE.PointerClick, "TradeUI", "OnSellItemClick")
    end

    local line1 = GUI.ImageCreate(leftBg, "line1", "1800400370", 0, -35, false, 490, 1)
    local petScr = GUI.ScrollRectCreate(leftBg, "petScr", 30, 90, 420, 240, 0, false, Vector2.New(420, 100), UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(petScr, Vector2.New(1, 1))

    for i = 1, 3 do
        TradeUI.CreateSellPet(i, petScr)
    end

    local line2 = GUI.ImageCreate(leftBg, "line2", "1800400370", 0, 215, false, 490, 1)
    local priceText = GUI.CreateStatic(leftBg, "priceText", "交易金币", -180, 244, 100, 30, "system", true)
    GUI.SetColor(priceText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(priceText, 22)

    local priceInput = GUI.EditCreate(leftBg, "priceInput", "1800700010", "0", -20, 245, Transition.ColorTint, "system", 200, 35, 2, 2, InputType.Standard, ContentType.IntegerNumber)
    _gt.BindName(priceInput, "priceInput")
    GUI.EditSetLabelAlignment(priceInput, TextAnchor.MiddleCenter)
    GUI.EditSetTextColor(priceInput, UIDefine.WhiteColor)
    GUI.EditSetFontSize(priceInput, 22)
    GUI.EditSetMaxCharNum(priceInput, 9)
    GUI.RegisterUIEvent(priceInput, UCE.EndEdit, "TradeUI", "OnPriceInputEndEdit")

    local coin = GUI.ImageCreate(priceInput, "coin", "1800408270", 16, -1, false, 36, 36)
    GUI.SetAnchor(coin, UIAnchor.Left)

    local mask = GUI.ImageCreate(leftBg, "mask", "1800400480", 0, 0, false, 495, 535)
    GUI.SetVisible(mask, false)

    local lockImg = GUI.ImageCreate(leftBg, "lockImg", "1800404110", 165, 244)
    GUI.SetVisible(lockImg, false)

    local rightBg = GUI.ImageCreate(panelBg, "rightBg", "1800400200", 265, -10, false, 500, 480)
    local itemPage = GUI.GroupCreate(rightBg, "itemPage", 0, 0, 500, 480)
    _gt.BindName(itemPage, "itemPage")
    local petPage = GUI.GroupCreate(rightBg, "petPage", 0, 0, 500, 480)
    _gt.BindName(petPage, "petPage")

    for i = 1, #labelList_1 do
        TradeUI.CreateLabel(labelList_1[i], panelBg)
    end

    local myLabelBtn = GUI.GetChild(panelBg, "myLabelBtn")
    local name = GUI.CreateStatic(myLabelBtn, "name", "我的交易", 45, 0, 100, 30, "system", true)
    GUI.SetColor(name, UIDefine.BrownColor)
    GUI.StaticSetFontSize(name, 22)
    UILayout.SetSameAnchorAndPivot(name, UILayout.Left)

    local lockImg = GUI.ImageCreate(myLabelBtn, "lockImg", "1800707080", 26, 0, false, 30, 30)
    GUI.SetAnchor(lockImg, UIAnchor.Left)

    local anotherLabelBtn = GUI.GetChild(panelBg, "anotherLabelBtn")
    local name = GUI.CreateStatic(anotherLabelBtn, "name", "<color=#37A0F8>" .. "对方</color>" .. "<color=#662F16>" .. "的交易</color>", 45, 0, 205, 26, "system", true)
    GUI.StaticSetFontSize(name, 22)
    UILayout.SetSameAnchorAndPivot(name, UILayout.Left)

    local lockImg = GUI.ImageCreate(anotherLabelBtn, "lockImg", "1800707080", 26, 0, false, 30, 30)
    GUI.SetAnchor(lockImg, UIAnchor.Left)

    local anotherInfoBtn = GUI.ButtonCreate(panelBg, "anotherInfoBtn", "1800400470", -37, -240, Transition.ColorTint, "", 42, 42, false)
    GUI.ImageCreate(anotherInfoBtn, "img", "1800408410", 0, 0)
    GUI.RegisterUIEvent(anotherInfoBtn, UCE.PointerClick, "TradeUI", "OnAnotherInfoBtnClick")

    for i = 1, #labelList_2 do
        TradeUI.CreateLabel(labelList_2[i], panelBg)
    end
    TradeUI.SetLabelSelectBtn(labelList_2, labelList_2[1][2])

    local bar = GUI.ImageCreate(panelBg, "bar", "1800700070", 265, -240, false, 496, 42)
    local text = GUI.CreateStatic(bar, "text", "可交易的道具", 30, 0, 150, 30, "system", true)
    GUI.SetColor(text, UIDefine.BrownColor)
    GUI.StaticSetFontSize(text, 22)
    UILayout.SetSameAnchorAndPivot(text, UILayout.Left)

    local clearBtn = GUI.ButtonCreate(panelBg, "clearBtn", "1800402110", 130, 265, Transition.ColorTint, "清空", 105, 50, false)
    GUI.ButtonSetTextFontSize(clearBtn, 24)
    GUI.ButtonSetTextColor(clearBtn, UIDefine.BrownColor)
    GUI.RegisterUIEvent(clearBtn, UCE.PointerClick, "TradeUI", "OnClearBtnClick")

    local lockBtn = GUI.ButtonCreate(panelBg, "lockBtn", "1800402110", 265, 265, Transition.ColorTint, "锁定", 105, 50, false)
    GUI.ButtonSetTextFontSize(lockBtn, 24)
    GUI.ButtonSetTextColor(lockBtn, UIDefine.BrownColor)
    GUI.RegisterUIEvent(lockBtn, UCE.PointerClick, "TradeUI", "OnLockBtnClick")

    local tradeBtn = GUI.ButtonCreate(panelBg, "tradeBtn", "1800402110", 400, 265, Transition.ColorTint, "交易", 105, 50, false)
    GUI.ButtonSetTextFontSize(tradeBtn, 24)
    GUI.ButtonSetTextColor(tradeBtn, UIDefine.BrownColor)
    GUI.RegisterUIEvent(tradeBtn, UCE.PointerClick, "TradeUI", "OnTradeBtnClick")

    TradeUI.CreateConfirmPopup(panelBg, GUI.GetWidth(panel), GUI.GetHeight(panel))

    CL.RegisterMessage(GM.RefreshBag, "TradeUI", "UpdateOwnItemScr")
    --[[
    ###
    CL.RegisterMessage(GM.TradeP2PCloseNtf,"TradeUI","OnTradeP2PCloseNtf")
    CL.RegisterMessage(GM.TradeP2PQueryPlayerNtf,"TradeUI","OpenAnotherPlayerInfo")
    CL.RegisterMessage(GM.PetListUpdate, "TradeUI" , "UpdateOwnPetScr")
    CL.RegisterMessage(GM.TradeP2PArrangeNtf, "TradeUI" , "UpdateTradingInfo")
    CL.RegisterMessage(GM.QueryPetNtf, "TradeUI" , "OnTradeP2PQueryPetNtf")
    CL.RegisterMessage(GM.QueryItemNtf, "TradeUI" , "OnTradeP2PQueryItemNtf")
    CL.RegisterMessage(GM.TradeP2PGoldNtf, "TradeUI" , "OnTradeP2PGoldNtf")
    CL.RegisterMessage(GM.TradeP2PClearNtf, "TradeUI" , "OnTradeP2PClearNtf")
    CL.RegisterMessage(GM.TradeP2PLockNtf, "TradeUI" , "OnTradeP2PLockNtf")
    CL.RegisterMessage(GM.TradeP2PConfirmNtf, "TradeUI" , "OnTradeP2PConfirmNtf")
  --]]
    TradeUI.Init()
    TradeUI.UpdateOwnItemScr()
end

function TradeUI.OnMyLabelBtn()
    TradeUI.SetLabelSelectBtn(labelList_1, labelList_1[1][2])
    TradeUI.labelIndex_1 = 1
    TradeUI.OnUpdateTradeArea()
end

function TradeUI.OnAnotherLabelBtn()
    TradeUI.SetLabelSelectBtn(labelList_1, labelList_1[2][2])
    TradeUI.labelIndex_1 = 2
    TradeUI.OnUpdateTradeArea()
end

function TradeUI.OnUpdateTradeArea()
    TradeUI.UpdateTradingInfo()
    TradeUI.OnTradeP2PGoldNtf()
    TradeUI.OnTradeP2PLockNtf()
    TradeUI.OnTradeP2PConfirmNtf()
end

function TradeUI.OnItemLabelBtnClick()
    TradeUI.SetLabelSelectBtn(labelList_2, labelList_2[1][2])
    TradeUI.labelIndex_2 = 1

    local itemPage = _gt.GetUI("itemPage")
    local petPage = _gt.GetUI("petPage")
    GUI.SetVisible(itemPage, true)
    GUI.SetVisible(petPage, false)

    local bar = GUI.Get(panelBgPath .. "/bar")
    local text = GUI.GetChild(bar, "text")
    GUI.StaticSetText(text, "可交易的道具")
    TradeUI.UpdateOwnItemScr()
end

function TradeUI.OnPetLabelBtnClick()
    TradeUI.SetLabelSelectBtn(labelList_2, labelList_2[2][2])
    TradeUI.labelIndex_2 = 2

    local itemPage = _gt.GetUI("itemPage")
    local petPage = _gt.GetUI("petPage")
    GUI.SetVisible(itemPage, false)
    GUI.SetVisible(petPage, true)

    local bar = GUI.Get(panelBgPath .. "/bar")
    local text = GUI.GetChild(bar, "text")
    GUI.StaticSetText(text, "可交易的宠物")

    TradeUI.UpdateOwnPetScr()
end

function TradeUI.Init()
    TradeUI.labelIndex_1 = 1
    TradeUI.labelIndex_2 = 1
    TradeUI.canSellOwnItemGuids = {}
    TradeUI.canSellOwnPetGuids = {}
    TradeUI.amountTimer = nil
    TradeUI.arrangeGuid = nil
    TradeUI.arrangeAmount = 1
    TradeUI.removeIndex = 0
end

function TradeUI.OnShow(scriptname, parameter)
    local wnd = GUI.GetWnd("TradeUI")
    if wnd == nil or scriptname ~= "TradeUI" then
        return
    end

    local anotherLabelBtn = GUI.Get(panelBgPath .. "/anotherLabelBtn")
    local name = GUI.GetChild(anotherLabelBtn, "name")
    GUI.StaticSetText(name, "<color=#37A0F8>" .. LD.GetAnotherNameInTradeP2P() .. "</color>" .. "<color=#662F16>" .. "的交易</color>")

    TradeUI.UpdateOwnItemScr()
    TradeUI.UpdateOwnPetScr()
    TradeUI.UpdateTradingInfo()
    TradeUI.OnTradeP2PGoldNtf()
    TradeUI.OnTradeP2PLockNtf()

    TradeUI.OnMyLabelBtn()
    TradeUI.OnItemLabelBtnClick()
end

function TradeUI.OnTradeBtnClick()
    CL.SendNotify(NOTIFY.TradeP2PConfirm)
end

function TradeUI.OnTradeP2PConfirmNtf()
    local myConfrimedState = LD.GetMyConfrimedStateInTrading()
    local anotherConfrimedState = LD.GetAnotherConfrimedStateInTrading()

    if myConfrimedState then
        local tradeBtn = GUI.Get(panelBgPath .. "/tradeBtn")
        GUI.ButtonSetShowDisable(tradeBtn, false)
        local lockBtn = GUI.Get(panelBgPath .. "/lockBtn")
        GUI.ButtonSetShowDisable(lockBtn, false)
    end

    local confrimedState = false
    if TradeUI.labelIndex_1 == 1 then
        confrimedState = myConfrimedState
    elseif TradeUI.labelIndex_1 == 2 then
        confrimedState = anotherConfrimedState
    end

    local lockImg = GUI.Get(leftBgPath .. "/lockImg")
    if confrimedState then
        GUI.ImageSetImageID(lockImg, "1800404120")
    end
end

function TradeUI.OnTradeP2PLockNtf()
    local myLockState = LD.GetMyLockStateInTrading()
    local anotherLockState = LD.GetAnotherLockStateInTrading()

    local myLabelBtn = GUI.Get(panelBgPath .. "/myLabelBtn")
    local lockImg = GUI.GetChild(myLabelBtn, "lockImg")
    local clearBtn = GUI.Get(panelBgPath .. "/clearBtn")
    local lockBtn = GUI.Get(panelBgPath .. "/lockBtn")
    GUI.ButtonSetShowDisable(lockBtn, true)
    if myLockState == true then
        GUI.ImageSetImageID(lockImg, "1800707020")
        GUI.ButtonSetShowDisable(clearBtn, false)
        GUI.ButtonSetText(lockBtn, "解锁")
    else
        GUI.ImageSetImageID(lockImg, "1800707080")
        GUI.ButtonSetShowDisable(clearBtn, true)
        GUI.ButtonSetText(lockBtn, "锁定")
    end

    local anotherLabelBtn = GUI.Get(panelBgPath .. "/anotherLabelBtn")
    local lockImg = GUI.GetChild(anotherLabelBtn, "lockImg")
    if anotherLockState == true then
        GUI.ImageSetImageID(lockImg, "1800707020")
    else
        GUI.ImageSetImageID(lockImg, "1800707080")
    end

    local tradeBtn = GUI.Get(panelBgPath .. "/tradeBtn")
    if myLockState == true and anotherLockState == true then
        GUI.ButtonSetShowDisable(tradeBtn, true)
    else
        GUI.ButtonSetShowDisable(tradeBtn, false)
    end

    local lockState = false
    if TradeUI.labelIndex_1 == 1 then
        lockState = myLockState
    elseif TradeUI.labelIndex_1 == 2 then
        lockState = anotherLockState
    end

    local mask = GUI.Get(leftBgPath .. "/mask")
    local lockImg = GUI.Get(leftBgPath .. "/lockImg")
    local priceInput = _gt.GetUI("priceInput")
    if lockState == true then
        GUI.SetVisible(mask, true)
        GUI.ImageSetImageID(lockImg, "1800404110")
        GUI.SetVisible(lockImg, true)
        GUI.ButtonSetShowDisable(priceInput, false)
    else
        GUI.SetVisible(mask, false)
        GUI.SetVisible(lockImg, false)
        if TradeUI.labelIndex_1 == 1 then
            GUI.ButtonSetShowDisable(priceInput, true)
        else
            GUI.ButtonSetShowDisable(priceInput, false)
        end
    end
end

function TradeUI.OnLockBtnClick()
    if not LD.GetMyLockStateInTrading() then
        local anotherItemInfos = LD.GetAnotherItemInfosInTrading()
        local anotherPetInfos = LD.GetAnotherPetInfosInTrading()
        local anotherGold = LD.GetAnotherGoldInTrading()

        if anotherItemInfos.Count == 0 and anotherPetInfos.Count == 0 and tostring(anotherGold) == "0" then
            local msg = "对方交易内容为空，是否锁定？"
            CL.MessageBox(MessageBoxType.DonotNeedSure, "提示", msg, "TradeUI", "OnContinueLockBtnClick", "OnCancelMessageBoxClick", MessageBoxStyle.Opposite, "确定", "取消", "锁定提示")
            return
        end
    end
    CL.SendNotify(NOTIFY.TradeP2PLock)
end

function TradeUI.OnContinueLockBtnClick()
    CL.SendNotify(NOTIFY.TradeP2PLock)
end

function TradeUI.OnCancelMessageBoxClick()
    -- body
end

function TradeUI.OnTradeP2PClearNtf()
    TradeUI.UpdateTradingInfo()
    TradeUI.OnTradeP2PGoldNtf()
end

function TradeUI.OnClearBtnClick()
    CL.SendNotify(NOTIFY.TradeP2PClearReq)
end

function TradeUI.OpenAnotherPlayerInfo()
    local queryPlayerInfo = LD.GetAnotherInfoInTradeP2P()
    if queryPlayerInfo == nil then
        return
    end
    local panelBg = GUI.Get(panelBgPath)
    local anotherInfoBtn = GUI.GetChild(panelBg, "anotherInfoBtn")

    local anotherInfo = GUI.ImageCreate(panelBg, "anotherInfo", "1800400490", -37, -160, false, 295, 110)
    GUI.SetVisible(anotherInfo, false)
    GUI.SetIsRemoveWhenClick(anotherInfo, true)
    GUI.AddWhiteName(anotherInfo, GUI.GetGuid(anotherInfoBtn))
    local iconBg = GUI.ImageCreate(anotherInfo, "iconBg", "1800400500", 55, 2)
    GUI.SetAnchor(iconBg, UIAnchor.Left)

    local role = DB.GetRole(queryPlayerInfo.templateId)
    local icon = GUI.ImageCreate(iconBg, "icon", "1900300010", 0, 0, false, 70, 70)
    GUI.SetAnchor(icon, UIAnchor.Center)
    if role ~= nil then
        GUI.ImageSetImageID(icon, tostring(role.Head))
    end

    if VipLevelPool ~= nil then
        VipLevelPool.QueryVipLevel(queryPlayerInfo.name, 3, VipLevelPool.ShowVipLevel, GUI.GetGuid(vipLevelIcon))
    end

    local num = GUI.CreateStatic(iconBg, "num", tostring(queryPlayerInfo.level), -8, -15, 100, 30, "system", true)
    GUI.StaticSetFontSize(num, 20)
    UILayout.SetAnchorAndPivot(num, UIAnchor.BottomRight, UIAroundPivot.Right)
    GUI.SetIsOutLine(num, true)
    GUI.SetOutLine_Distance(num, 1)
    GUI.SetOutLine_Color(num, UIDefine.BlackColor)

    local job = GUI.ImageCreate(anotherInfo, "job", "1800408020", -26, -24, false, 25, 24)
    GUI.SetAnchor(icon, UIAnchor.Center)
    if DB.Get_role_school(queryPlayerInfo.job) ~= nil then
        local jonIcon = DB.Get_role_school(queryPlayerInfo.job).Icon
        GUI.SetVisible(job, true)
        GUI.ImageSetImageID(job, jonIcon)
    end

    local name = GUI.CreateStatic(anotherInfo, "name", queryPlayerInfo.name, 140, -23, 150, 24, "system", true)
    GUI.StaticSetFontSize(name, 20)
    UILayout.SetSameAnchorAndPivot(name, UILayout.Left)
    --#GUI.LabelSetFontSizeBestFit(name)

    local text = GUI.CreateStatic(anotherInfo, "text", "关系：", -10, 5, 100, 30, "system", true)
    GUI.StaticSetFontSize(text, 20)
    local text = GUI.CreateStatic(anotherInfo, "text", "帮派：", -10, 30, 100, 30, "system", true)
    GUI.StaticSetFontSize(text, 20)

    local relation = GUI.CreateStatic(anotherInfo, "relation", "陌生人", 160, 5, 100, 30, "system", true)
    GUI.SetColor(relation, UIDefine.RedColor)
    GUI.StaticSetFontSize(relation, 20)
    UILayout.SetSameAnchorAndPivot(relation, UILayout.Left)
    if LD.IsMyFriend(tostring(queryPlayerInfo.guid)) then
        GUI.SetColor(relation, UIDefine.Green6Color)
        GUI.StaticSetText(relation, "好友")
    else
        GUI.SetColor(relation, UIDefine.RedColor)
        GUI.StaticSetText(relation, "陌生人")
    end

    local faction = GUI.CreateStatic(anotherInfo, "faction", "你的帮派", 160, 30, 100, 30, "system", true)
    GUI.SetColor(faction, UIDefine.Green6Color)
    GUI.StaticSetFontSize(faction, 20)
    UILayout.SetSameAnchorAndPivot(faction, UILayout.Left)

    local faction = GUI.GetChild(anotherInfo, "faction")
    if queryPlayerInfo.faction == "" then
        GUI.StaticSetText(faction, "无")
    else
        GUI.StaticSetText(faction, queryPlayerInfo.faction)
    end
    GUI.SetVisible(anotherInfo, true)
end

function TradeUI.UpdateTradingInfo()
    local leftBg = GUI.Get(leftBgPath)
    local itemScr = GUI.GetChild(leftBg, "itemScr")
    local petScr = GUI.GetChild(leftBg, "petScr")
    local priceInput = _gt.GetUI("priceInput")

    local itemInfos
    local petInfos
    if TradeUI.labelIndex_1 == 1 then
        itemInfos = LD.GetMyItemInfosInTrading()
        petInfos = LD.GetMyPetInfosInTrading()
        GUI.ButtonSetShowDisable(priceInput, true)
    elseif TradeUI.labelIndex_1 == 2 then
        itemInfos = LD.GetAnotherItemInfosInTrading()
        petInfos = LD.GetAnotherPetInfosInTrading()
        GUI.ButtonSetShowDisable(priceInput, false)
    end

    for i = 1, itemInfos.Count do
        local itemInfo = itemInfos[i - 1]
        local iconBg = GUI.GetChild(itemScr, "iconBg" .. i)

        ItemIcon.BindItemData(iconBg, itemInfo, true)
        GUI.SetItemIconBtnCount(iconBg, itemInfo.amount)

        local count = GUI.ItemCtrlGetLabel_Num(iconBg)
        if count ~= nil then
            GUI.SetPositionX(count, 8)
            GUI.SetPositionY(count, 5)
            GUI.StaticSetFontSize(count, 20)
            GUI.SetIsOutLine(count, true)
            GUI.SetOutLine_Color(count, UIDefine.BlackColor)
            GUI.SetOutLine_Distance(count, 1)
            GUI.SetColor(count, UIDefine.WhiteColor)
        end
    end

    for i = itemInfos.Count + 1, 8 do
        local iconBg = GUI.GetChild(itemScr, "iconBg" .. i)
        ItemIcon.SetEmpty(iconBg)
    end

    for i = 1, petInfos.Count do
        local petInfo = petInfos[i - 1]
        local pet = GUI.GetChild(petScr, "pet" .. i)
        GUI.SetVisible(pet, true)
        local iconBg = GUI.GetChild(pet, "iconBg")
        local icon = GUI.GetChild(iconBg, "icon")
        local name = GUI.GetChild(pet, "name")
        local level = GUI.GetChild(pet, "level")
        local petType = GUI.GetChild(pet, "petType")

        GUI.SetVisible(icon, true)
        GUI.SetVisible(name, true)
        GUI.SetVisible(level, true)
        GUI.SetVisible(petType, true)
        local petConfig = DB.GetOncePetByKey1(petInfo.tid)
        if petConfig ~= nil then
            GUI.ImageSetImageID(icon, tostring(petConfig.Head))
            GUI.ImageSetImageID(petType, UIDefine.PetType[petConfig.Grade])
        end

        GUI.StaticSetText(name, petInfo.name)
        GUI.StaticSetText(level, "等级：" .. petInfo.level)

        --剩余时间
        --#GlobalUtils.CreatePetLifeText(pet, petInfo, -60, 18, 24, UIAnchor.TopRight, UIAroundPivot.TopRight,2)
    end

    for i = petInfos.Count + 1, 3 do
        local pet = GUI.GetChild(petScr, "pet" .. i)
        TradeUI.SetEmptySellPet(pet)
    end
end

function TradeUI.SetEmptySellPet(pet)
    local iconBg = GUI.GetChild(pet, "iconBg")
    local icon = GUI.GetChild(iconBg, "icon")
    local name = GUI.GetChild(pet, "name")
    local level = GUI.GetChild(pet, "level")
    local petType = GUI.GetChild(pet, "petType")

    GUI.SetVisible(icon, false)
    GUI.SetVisible(name, false)
    GUI.SetVisible(level, false)
    GUI.SetVisible(petType, false)

    local lifeTimeLabel = GUI.GetChild(pet, "lifeTimeLabel")
    GUI.Destroy(lifeTimeLabel)
end

function TradeUI.OnTradeP2PGoldNtf()
    local priceInput = _gt.GetUI("priceInput")
    local price = 0
    if TradeUI.labelIndex_1 == 1 then
        price = LD.GetMyGoldInTrading()
    elseif TradeUI.labelIndex_1 == 2 then
        price = LD.GetAnotherGoldInTrading()
    end
    GUI.EditSetTextM(priceInput, tostring(price))
end

function TradeUI.OnOwnItemClick(guid)
    local myLockState = false --#LD.GetMyLockStateInTrading()
    if myLockState == true then
        return
    end

    local ownItem = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(ownItem, "Index"))
    local itemGuid = TradeUI.canSellOwnItemGuids[index]
    if itemGuid == nil then
        return
    end

    TradeUI.PutAwayItem(itemGuid)
end

function TradeUI.PutAwayItem(itemGuid)
    if tostring(itemGuid) == "0" then
        return
    end

    local itemInfo = LD.GetItemDataByGuid(itemGuid)
    if itemInfo == nil then
        return
    end
    local itemConfig = DB.GetOnceItemByKey1(itemInfo.id)
    if itemConfig == nil then
        return
    end

    local confirmPopup = _gt.GetUI("confirmPopup")
    GUI.SetVisible(confirmPopup, true)

    local tips = GUI.GetChild(confirmPopup, "tips")
    if tips ~= nil then
        GUI.Destroy(tips)
    end

    local title = _gt.GetUI("title")
    GUI.StaticSetText(title, "上架确认")

    local itemBg = GUI.GetChild(confirmPopup, "itemBg")
    local iconBg = GUI.GetChild(itemBg, "iconBg")
    ItemIcon.BindItemData(iconBg, itemInfo)

    local name = GUI.GetChild(itemBg, "name")
    GUI.StaticSetText(name, itemConfig.Name)

    local level = GUI.GetChild(itemBg, "level")
    GUI.StaticSetText(level, "等级：" .. itemConfig.Itemlevel)

    local tipsBtn = GUI.GetChild(itemBg, "tipsBtn")
    GUI.SetData(tipsBtn, "Type", 1)
    local introduceScr = GUI.GetChild(confirmPopup, "introduceScr")
    local info1 = GUI.GetChild(introduceScr, "info1")
    if itemConfig.Info == "不显示" then
        GUI.SetVisible(info1, false)
    else
        GUI.SetVisible(info1, true)
        GUI.StaticSetText(info1, "使用效果：" .. itemConfig.Info)
    end
    local info2 = GUI.GetChild(introduceScr, "info2")
    GUI.StaticSetText(info2, "使用说明：" .. itemConfig.Tips)

    local numBg = GUI.GetChild(confirmPopup, "numBg")
    GUI.SetVisible(numBg, false)

    local numMinusBtn = GUI.GetChild(confirmPopup, "numMinusBtn")
    GUI.SetVisible(numMinusBtn, true)

    local numInput = GUI.GetChild(confirmPopup, "numInput")
    GUI.SetVisible(numInput, true)
    GUI.EditSetTextM(numInput, "1")

    local numAddBtn = GUI.GetChild(confirmPopup, "numAddBtn")
    GUI.SetVisible(numAddBtn, true)

    local priceInput = _gt.GetUI("priceInput")
    GUI.SetVisible(priceInput, true)
    GUI.EditSetTextM(priceInput, "请输入单价")

    local priceBg = GUI.GetChild(confirmPopup, "priceBg")
    GUI.SetVisible(priceBg, false)

    local totalPriceBg = GUI.GetChild(confirmPopup, "totalPriceBg")
    local num = GUI.GetChild(totalPriceBg, "num")
    GUI.StaticSetText(num, "0")

    local cancelBtn = GUI.GetChild(confirmPopup, "cancelBtn")
    local confirmBtn = GUI.GetChild(confirmPopup, "confirmBtn")
    GUI.SetVisible(cancelBtn, true)
    GUI.SetVisible(confirmBtn, true)
    GUI.SetData(confirmBtn, "Type", 1)
    GUI.ButtonSetText(confirmBtn, "上架")

    TradeUI.arrangeGuid = itemGuid
    TradeUI.arrangeAmount = 1
    TradeUI.UpdateArrangeAmount()
end

function TradeUI.OnSellItemClick(guid)
    local sellItem = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(sellItem, "Index"))
    TradeUI.removeIndex = index

    local itemInfos
    if TradeUI.labelIndex_1 == 1 then
        if LD.GetMyLockStateInTrading() then
            return
        end
        itemInfos = LD.GetMyItemInfosInTrading()
    elseif TradeUI.labelIndex_1 == 2 then
        itemInfos = LD.GetAnotherItemInfosInTrading()
    end

    if index > itemInfos.Count then
        return
    end

    local itemInfo = itemInfos[index - 1]
    local guid = itemInfo.guid
    local itemData = DB.GetOnceItemByKey1(itemInfo.id)
    if itemData == nil then
        return
    end

    if TradeUI.labelIndex_1 == 2 then
        CL.SendNotify(NOTIFY.QueryByGuid, guid)
        return
    end

    local confirmPopup = _gt.GetUI("confirmPopup")
    GUI.SetVisible(confirmPopup, true)

    local tips = GUI.GetChild(confirmPopup, "tips")
    if tips ~= nil then
        GUI.Destroy(tips)
    end

    local titleBg = GUI.GetChild(confirmPopup, "titleBg")
    local title = GUI.GetChild(titleBg, "title")
    GUI.StaticSetText(title, "下架确认")

    local itemBg = GUI.GetChild(confirmPopup, "itemBg")
    local iconBg = GUI.GetChild(itemBg, "iconBg")
    ItemIcon.BindItemData(iconBg, itemInfo)

    local name = GUI.GetChild(itemBg, "name")
    GUI.StaticSetText(name, itemData.Name)

    local level = GUI.GetChild(itemBg, "level")
    local itemConsumable = DB.Get_item_consumable(itemInfo.id)
    if itemConsumable ~= nil and itemConsumable.Type == 29 then
        GUI.StaticSetText(level, "等级：" .. itemInfo.level)
    else
        GUI.StaticSetText(level, "等级：" .. itemData.Level)
    end

    local tipsBtn = GUI.GetChild(itemBg, "tipsBtn")
    GUI.SetData(tipsBtn, "Type", 2)

    local introduceScr = GUI.GetChild(confirmPopup, "introduceScr")
    local info1 = GUI.GetChild(introduceScr, "info1")
    if itemData.Info == "不显示" then
        GUI.SetVisible(info1, false)
    else
        GUI.SetVisible(info1, true)
        GUI.StaticSetText(info1, "使用效果：" .. itemData.Info)
    end
    local info2 = GUI.GetChild(introduceScr, "info2")
    GUI.StaticSetText(info2, "使用说明：" .. itemData.Tips)

    local numBg = GUI.GetChild(confirmPopup, "numBg")
    GUI.SetVisible(numBg, true)
    local num = GUI.GetChild(numBg, "num")
    GUI.StaticSetText(num, tostring(itemInfo.amount))

    local numMinusBtn = GUI.GetChild(confirmPopup, "numMinusBtn")
    GUI.SetVisible(numMinusBtn, false)

    local numInput = GUI.GetChild(confirmPopup, "numInput")
    GUI.SetVisible(numInput, false)

    local numAddBtn = GUI.GetChild(confirmPopup, "numAddBtn")
    GUI.SetVisible(numAddBtn, false)

    local cancelBtn = GUI.GetChild(confirmPopup, "cancelBtn")

    local confirmBtn = GUI.GetChild(confirmPopup, "confirmBtn")

    GUI.SetData(confirmBtn, "Type", 2)
    GUI.ButtonSetText(confirmBtn, "下架")
end

function TradeUI.CreateConfirmPopup(panelBg, panel_w, panel_h)
    local confirmPopup = GUI.GroupCreate(panelBg, "confirmPopup", 0, 0, 0, 0)
    _gt.BindName(confirmPopup, "confirmPopup")

    local mask = GUI.ImageCreate(confirmPopup, "confirmPopupImg", "1800400220", 0, -30, false, panel_w, panel_h)
    _gt.BindName(mask, "confirmPopupImg")
    mask:RegisterEvent(UCE.PointerClick)
    GUI.SetIsRaycastTarget(mask, true)
    GUI.RegisterUIEvent(mask, UCE.PointerClick, "TradeUI", "OnConfirmPopupClose")

    local bg = GUI.ImageCreate(confirmPopup, "bg", "1800900010", 0, 30, false, 380, 480)
    GUI.SetIsRaycastTarget(bg, true)
    bg:RegisterEvent(UCE.PointerClick)

    local closeBtn = GUI.ButtonCreate(confirmPopup, "closeBtn", "1800302120", 170, -190, Transition.ColorTint)
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "TradeUI", "OnConfirmPopupClose")

    local titleBg = GUI.ImageCreate(confirmPopup, "titleBg", "1800001140", 0, -170, false, 230, 40)
    local title = GUI.CreateStatic(titleBg, "title", "上架确认", 0, 1, 100, 30, "system")
    _gt.BindName(title, "title")
    GUI.SetColor(title, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(title, 24)

    GUI.ImageCreate(confirmPopup, "bg1", "1800400200", 0, -5, false, 345, 260)
    local itemBg = GUI.ImageCreate(confirmPopup, "itemBg", "1800400360", 0, -70, false, 325, 100)

    local iconBg = GUI.ItemCtrlCreate(itemBg, "iconBg", UIDefine.ItemIconBg[1], -105, 1)

    local name = GUI.CreateStatic(itemBg, "name", "名字", 110, -20, 0, 0, "system", true)
    GUI.StaticSetFontSize(name, 22)
    GUI.SetColor(name, UIDefine.BrownColor)
    UILayout.SetSameAnchorAndPivot(name, UILayout.Left)

    local level = GUI.CreateStatic(itemBg, "level", "等级：", 110, 15, 120, 30, "system")
    GUI.StaticSetFontSize(level, 22)
    GUI.SetColor(level, UIDefine.Yellow2Color)
    UILayout.SetSameAnchorAndPivot(level, UILayout.Left)

    local tipsBtn = GUI.ButtonCreate(itemBg, "tipsBtn", "1800702030", 120, 15, Transition.ColorTint, "")
    GUI.RegisterUIEvent(tipsBtn, UCE.PointerClick, "TradeUI", "CreateItemTips")

    local introduceScr = GUI.ScrollRectCreate(confirmPopup, "introduceScr", 0, 50, 310, 130, 0, false, Vector2.New(300, 100), UIAroundPivot.Top, UIAnchor.Top)
    for i = 1, 2 do
        local info = GUI.CreateStatic(introduceScr, "info" .. i, "介绍介绍介绍介绍", 0, 70, 300, 100, "system", true)
        GUI.StaticSetFontSize(info, 24)
        GUI.SetColor(info, UIDefine.BrownColor)
    UILayout.SetSameAnchorAndPivot(info, UILayout.Center)
        GUI.StaticSetAlignment(info, TextAnchor.UpperLeft)
    end

    local numText = GUI.CreateStatic(confirmPopup, "numText", "数量", -101, 165, 100, 30, "system", true)
    GUI.SetColor(numText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(numText, 24)

    local numBg = GUI.ImageCreate(confirmPopup, "numBg", "1800700010", 40, 166, false, 250, 35)
    local num = GUI.CreateStatic(numBg, "num", "100", 0, 0, 100, 30, "system", true)
    GUI.StaticSetFontSize(num, 22)
    UILayout.SetSameAnchorAndPivot(num, UILayout.Center)
    GUI.SetVisible(numBg, false)

    local numMinusBtn = GUI.ButtonCreate(confirmPopup, "numMinusBtn", "1800402140", -60, 165, Transition.ColorTint, "")
    UILayout.SetSameAnchorAndPivot(numMinusBtn, UILayout.Center)
    numMinusBtn:RegisterEvent(UCE.PointerUp)
    numMinusBtn:RegisterEvent(UCE.PointerDown)
    GUI.RegisterUIEvent(numMinusBtn, UCE.PointerDown, "TradeUI", "OnNumMinusBtnDown")
    GUI.RegisterUIEvent(numMinusBtn, UCE.PointerUp, "TradeUI", "OnNumMinusBtnUp")

    local numInput = GUI.EditCreate(confirmPopup, "numInput", "1800400390", "1", 38, 164, Transition.ColorTint, "system", 0, 0, 8, 8, InputType.Standard, ContentType.IntegerNumber)
    GUI.EditStaticSetAlignment(numInput, TextAnchor.MiddleCenter)
    GUI.EditSetTextColor(numInput, UIDefine.BrownColor)
    GUI.EditSetFontSize(numInput, 22)
    GUI.EditSetMaxCharNum(numInput, 3)
    GUI.RegisterUIEvent(numInput, UCE.EndEdit, "TradeUI", "OnNumInputEndEdit")

    -- 数量增加按钮
    local numAddBtn = GUI.ButtonCreate(confirmPopup, "numAddBtn", "1800402150", 135, 165, Transition.ColorTint, "")
    UILayout.SetSameAnchorAndPivot(numAddBtn, UILayout.Center)
    numAddBtn:RegisterEvent(UCE.PointerUp)
    numAddBtn:RegisterEvent(UCE.PointerDown)
    GUI.RegisterUIEvent(numAddBtn, UCE.PointerDown, "TradeUI", "OnNumAddBtnDown")
    GUI.RegisterUIEvent(numAddBtn, UCE.PointerUp, "TradeUI", "OnNumAddBtnUp")

    local confirmBtn = GUI.ButtonCreate(confirmPopup, "confirmBtn", "1800402110", 100, 230, Transition.ColorTint, "上架", 105, 50, false)
    GUI.ButtonSetTextFontSize(confirmBtn, 24)
    GUI.ButtonSetTextColor(confirmBtn, UIDefine.BrownColor)
    GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "TradeUI", "OnItemConfirmBtnClick")

    local cancelBtn = GUI.ButtonCreate(confirmPopup, "cancelBtn", "1800402110", -100, 230, Transition.ColorTint, "取消", 105, 50, false)
    GUI.ButtonSetTextFontSize(cancelBtn, 24)
    GUI.ButtonSetTextColor(cancelBtn, UIDefine.BrownColor)
    GUI.RegisterUIEvent(cancelBtn, UCE.PointerClick, "TradeUI", "OnConfirmPopupClose")
    GUI.SetVisible(confirmPopup, false)
end

function TradeUI.CreateItemTips(guid)
    local tipsBtn = GUI.GetByGuid(guid)
    local itemGuid = nil

    local confirmPopup = _gt.GetUI("confirmPopup")
    local tips = GUI.GetChild(confirmPopup, "tips")
    if tips ~= nil and GUI.GetVisible(tips) then
        GUI.Destroy(tips)
        return
    end

    if GUI.GetData(tipsBtn, "Type") == "1" then
        itemGuid = TradeUI.arrangeGuid
        local itemInfo = LD.GetItemDataByGuid(itemGuid)
        local tips = Tips.CreateByItemData(itemInfo, confirmPopup, "tips", 390, 30)
        GUI.SetIsRemoveWhenClick(tips, false)
        GUI.AddWhiteName(tips, guid)
    elseif GUI.GetData(tipsBtn, "Type") == "2" then
        itemGuid = LD.GetMyItemInfosInTrading()[TradeUI.removeIndex - 1].guid
        CL.SendNotify(NOTIFY.QueryByGuid, itemGuid)
    end
end

function TradeUI.OnTradeP2PQueryItemNtf()
    local itemInfo = LD.GetQueryItemInfo()

    if TradeUI.labelIndex_1 == 1 then
        local confirmPopup = _gt.GetUI("confirmPopup")
        local tips = Tips.CreateByItemData(itemInfo, confirmPopup, "tips", 390, 30)
        GUI.SetIsRemoveWhenClick(tips, false)
        local tipsBtn = GUI.GetChildByPath(confirmPopup, "itemBg/tipsBtn")
        GUI.AddWhiteName(tips, GUI.GetGuid(tipsBtn))
    elseif TradeUI.labelIndex_1 == 2 then
        --#local panelBg =GUI.Get(panelBgPath)
        --#Tips.CreateOtherItem("tips",itemInfo,0,0,panelBg)
    end
end

function TradeUI.OnItemConfirmBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    if GUI.GetData(btn, "Type") == "1" then
        --添加
        CL.SendNotify(NOTIFY.TradeP2PArrange, 0, 0, TradeUI.arrangeGuid, TradeUI.arrangeAmount)

    elseif GUI.GetData(btn, "Type") == "2" then
        --删除
        local itemInfos = LD.GetMyItemInfosInTrading()
        local itemInfo = itemInfos[TradeUI.removeIndex - 1]
        CL.SendNotify(NOTIFY.TradeP2PArrange, 1, 0, itemInfo.guid, itemInfo.amount)
    end
    TradeUI.OnConfirmPopupClose()
end

function TradeUI.OnClickPetConfirmBtn(type)
    if type == 1 then
        CL.SendNotify(NOTIFY.TradeP2PArrange, 0, 1, TradeUI.arrangeGuid, TradeUI.arrangeAmount)
    elseif type == 2 then
        local petInfos = LD.GetMyPetInfosInTrading()
        local petInfo = petInfos[TradeUI.removeIndex - 1]
        CL.SendNotify(NOTIFY.TradeP2PArrange, 1, 1, petInfo.guid, 1)
    end
end

function TradeUI.OnPetConfirmBtnClick(guid)
    local btn = GUI.GetByGuid(guid)

    if GUI.GetData(btn, "Type") == "1" then
        if LD.GetMyPetInfosInTrading().Count >= 3 then
            CL.SendNotify(NOTIFY.ShowMessageBubble, "交易栏中的宠物已满")
            return
        end

        CL.SendNotify(NOTIFY.TradeP2PArrange, 0, 1, TradeUI.arrangeGuid, TradeUI.arrangeAmount)
    elseif GUI.GetData(btn, "Type") == "2" then
        local petInfos = LD.GetMyPetInfosInTrading()
        local petInfo = petInfos[TradeUI.removeIndex - 1]
        CL.SendNotify(NOTIFY.TradeP2PArrange, 1, 1, petInfo.guid, 1)
    end
    if PetInfoUI ~= nil then
        PetInfoUI.OnCloseBtnClick()
    end
end

function TradeUI.OnConfirmPopupClose()
    local confirmPopup = _gt.GetUI("confirmPopup")
    GUI.SetVisible(confirmPopup, false)
end

function TradeUI.OnPriceInputEndEdit(guid)
    if TradeUI.labelIndex_1 == 2 then
        return
    end

    local priceInput = GUI.GetByGuid(guid)

    local price = 0
    if GUI.EditGetTextM(priceInput) == "" or tonumber(GUI.EditGetTextM(priceInput)) < 0 then
        price = 0
    else
        price = tonumber(GUI.EditGetTextM(priceInput))
        if price >= tonumber(CL.GetIAttrEx(RoleAttr.RoleAttrGold)) then
            price = tonumber(CL.GetIAttrEx(RoleAttr.RoleAttrGold))
        end
    end
    CL.SendNotify(NOTIFY.TradeP2PGold, price)
end

function TradeUI.OnNumInputEndEdit()
    local numInput = GUI.Get(confirmPopupPath .. "/numInput")
    if GUI.EditGetTextM(numInput) == "" then
        TradeUI.arrangeAmount = 1
    else
        TradeUI.arrangeAmount = tonumber(GUI.EditGetTextM(numInput))
    end
    TradeUI.UpdateArrangeAmount()
end

function TradeUI.OnNumMinusBtnDown()
    local fun = function()
        TradeUI.arrangeAmount = TradeUI.arrangeAmount - 1
        TradeUI.UpdateArrangeAmount()
    end

    if TradeUI.amountTimer == nil then
        TradeUI.amountTimer = Timer.New(fun, 0.15, -1)
    else
        TradeUI.amountTimer:Stop()
        TradeUI.amountTimer:Reset(fun, 0.15, -1)
    end
    TradeUI.amountTimer:Start()
    fun()
end

function TradeUI.OnNumMinusBtnUp()
    if TradeUI.amountTimer ~= nil then
        TradeUI.amountTimer:Stop()
    end
end

function TradeUI.OnNumAddBtnDown()
    local fun = function()
        TradeUI.arrangeAmount = TradeUI.arrangeAmount + 1
        TradeUI.UpdateArrangeAmount()
    end
    if TradeUI.amountTimer == nil then
        TradeUI.amountTimer = Timer.New(fun, 0.15, -1)
    else
        TradeUI.amountTimer:Stop()
        TradeUI.amountTimer:Reset(fun, 0.15, -1)
    end
    TradeUI.amountTimer:Start()
    fun()
end

function TradeUI.OnNumAddBtnUp()
    if TradeUI.amountTimer ~= nil then
        TradeUI.amountTimer:Stop()
    end
end

function TradeUI.UpdateArrangeAmount()
    if TradeUI.arrangeAmount == nil then
        return
    end

    local numMinusBtn = GUI.Get(confirmPopupPath .. "/numMinusBtn")
    local numAddBtn = GUI.Get(confirmPopupPath .. "/numAddBtn")
    local itemAmount = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Amount, TradeUI.arrangeGuid))
    if TradeUI.arrangeAmount < 1 then
        TradeUI.arrangeAmount = 1
    else
        if TradeUI.arrangeAmount > itemAmount then
            TradeUI.arrangeAmount = itemAmount
        elseif TradeUI.arrangeAmount > 999 then
            TradeUI.arrangeAmount = 999
        end
    end

    if TradeUI.arrangeAmount == 1 then
        GUI.ButtonSetShowDisable(numMinusBtn, false)
        if TradeUI.amountTimer ~= nil then
            TradeUI.amountTimer:Stop()
        end
    else
        GUI.ButtonSetShowDisable(numMinusBtn, true)
    end

    if TradeUI.arrangeAmount == itemAmount or TradeUI.arrangeAmount == 999 then
        GUI.ButtonSetShowDisable(numAddBtn, false)
        if TradeUI.amountTimer ~= nil then
            TradeUI.amountTimer:Stop()
        end
    else
        GUI.ButtonSetShowDisable(numAddBtn, true)
    end

    local numInput = GUI.Get(confirmPopupPath .. "/numInput")
    GUI.EditSetTextM(numInput, tostring(TradeUI.arrangeAmount))
end

function TradeUI.UpdateOwnItemScr()
    local itemPage = _gt.GetUI("itemPage")
    local ownItemScr = _gt.GetUI("ownItemScr")
    if ownItemScr == nil then
        ownItemScr = GUI.LoopScrollRectCreate(itemPage, "ownItemScr", 0, 15, 480, 430,
                "TradeUI", "CreateNewOwnItem", "TradeUI", "UpdateOwnItem", 0, false, Vector2.New(82, 82), 5, UIAroundPivot.Top, UIAnchor.Top)

        _gt.BindName(ownItemScr, "ownItemScr")
        GUI.ScrollRectSetChildSpacing(ownItemScr, Vector2.New(6, 6))
    else
        GUI.SetVisible(ownItemScr, true)
    end

    TradeUI.canSellOwnItemGuids = {}
    local count = LD.GetBagCapacity()--LD.GetItemCount()
    for i = 0, count - 1 do
        local id = tonumber(LD.GetItemAttrByIndex(ItemAttr_Native.Id, i))
        if id ~= nil then
            local itemConfig = DB.GetOnceItemByKey1(id)
            if itemConfig and itemConfig.Tradable == 1 then
                local guid = LD.GetItemGuidByIndex(i)
                table.insert(TradeUI.canSellOwnItemGuids, guid)
            end
        end
    end

    local itemCount = #TradeUI.canSellOwnItemGuids
    if #TradeUI.canSellOwnItemGuids % 5 > 0 then
        itemCount = math.floor(#TradeUI.canSellOwnItemGuids / 5) * 5 + 5
    end

    if itemCount < 25 then
        itemCount = 25
    end
    GUI.LoopScrollRectSetTotalCount(ownItemScr, itemCount)
    GUI.LoopScrollRectRefreshCells(ownItemScr)
end

function TradeUI.CreateNewOwnItem()
    local ownItemScr = _gt.GetUI("ownItemScr")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(ownItemScr)
    local ownItem = GUI.ItemCtrlCreate(ownItemScr, "ownItem" .. curCount, UIDefine.ItemIconBg[1], 0, 0)
    GUI.RegisterUIEvent(ownItem, UCE.PointerClick, "TradeUI", "OnOwnItemClick")

    local Select = GUI.ImageCreate(ownItem, "Select", "1800600160", 0, -2, false, 80, 80)
    GUI.SetVisible(Select, false)
    local decreaseBtn = GUI.ButtonCreate(Select, "decreaseBtn", "1800702070", 27, -27, Transition.ColorTint, "")

    return ownItem
end

function TradeUI.UpdateOwnItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local ownItem = GUI.GetByGuid(guid)
    GUI.SetData(ownItem, "Index", index)
    if index < #TradeUI.canSellOwnItemGuids then
        local itemGuid = TradeUI.canSellOwnItemGuids[index]
        local itemData = LD.GetItemDataByGuid(itemGuid)
        ItemIcon.BindItemData(ownItem, itemData)
    else
        ItemIcon.SetEmpty(ownItem)
    end
end

function TradeUI.OnTradeP2PQueryPetNtf()
    local petInfo = LD.GetQueryPetInfo()

    local petInfoUIWnd = GUI.GetWnd("PetInfoUI")
    if petInfoUIWnd == nil then
        GUI.OpenWnd("PetInfoUI")
        PetInfoUI.SetPetDetailInfo(petInfo)
    else
        local wnd = GUI.GetWnd("PetInfoUI")
        if wnd ~= nil then
            GUI.SetVisible(wnd, true)
            if PetInfoUI ~= nil then
                PetInfoUI.SetPetDetailInfo(petInfo)
            end
        end
    end

    local confirmBtn = PetInfoUI.SetStallStyle(5)
    if TradeUI.labelIndex_1 == 1 then
        GUI.SetVisible(confirmBtn, true)
    elseif TradeUI.labelIndex_1 == 2 then
        GUI.SetVisible(confirmBtn, false)
    end

    GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "TradeUI", "OnPetConfirmBtnClick")
end

function TradeUI.OnSellPetClick(guid)
    local sellPet = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(sellPet, "Index"))
    TradeUI.removeIndex = index

    local petInfos
    if TradeUI.labelIndex_1 == 1 then
        if LD.GetMyLockStateInTrading() then
            return
        end
        petInfos = LD.GetMyPetInfosInTrading()
    elseif TradeUI.labelIndex_1 == 2 then
        petInfos = LD.GetAnotherPetInfosInTrading()
    end

    if index > petInfos.Count then
        return
    end
    local petInfo = petInfos[index - 1]
    CL.SendNotify(NOTIFY.QueryByGuid, petInfo.guid)
end

function TradeUI.OnOwnPetClick(guid)
    local myLockState = false --#LD.GetMyLockStateInTrading()
    if myLockState == true then
        return
    end

    local ownPet = GUI.GetByGuid(guid)
    local select = GUI.GetChild(ownPet, "Select")
    local visible = GUI.GetVisible(select)
    if visible then
        GUI.SetVisible(select, false)
    else
        if false and LD.GetMyPetInfosInTrading().Count >= 3 then
            CL.SendNotify(NOTIFY.ShowMessageBubble, "交易栏中的宠物已满")
            return
        end
        GUI.SetVisible(select, true)
    end

    local index = tonumber(GUI.GetData(ownPet, "Index"))
    local petGuid = TradeUI.canSellOwnPetGuids[index]
    --[[
    local petInfoUIWnd = GUI.GetWnd("PetInfoUI")
    if petInfoUIWnd == nil then
        GUI.OpenWnd("PetInfoUI", tostring(petGuid))
    else
        local wnd = GUI.GetWnd("PetInfoUI")
        if wnd ~= nil then
            GUI.SetVisible(wnd, true)
            if PetInfoUI ~= nil then
                PetInfoUI.SetPetGUID(tostring(petGuid))
            end
        end
    end

    local confirmBtn = PetInfoUI.SetStallStyle(4)
    GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "TradeUI", "OnPetConfirmBtnClick")
    --]]

    TradeUI.arrangeGuid = petGuid
    TradeUI.arrangeAmount = 1

    TradeUI.OnClickPetConfirmBtn(1)
end

function TradeUI.UpdateOwnPetScr()
    local petPage = _gt.GetUI("petPage")
    local ownPetScr = GUI.GetChild(petPage, "ownPetScr")
    if ownPetScr == nil then
        ownPetScr = GUI.ScrollRectCreate(petPage, "ownPetScr", 0, 15, 480, 430, 0, false, Vector2.New(470, 100), UIAroundPivot.Top, UIAnchor.Top)
        GUI.ScrollRectSetChildSpacing(ownPetScr, Vector2.New(1, 1))
    else
        GUI.SetVisible(ownPetScr, true)
    end

    for i = 1, #TradeUI.canSellOwnPetGuids do
        local ownPet = GUI.GetChild(ownPetScr, "pet" .. i)
        GUI.SetVisible(ownPet, false)
    end

    TradeUI.canSellOwnPetGuids = nil
    TradeUI.canSellOwnPetGuids = {}
    local allPetGuids = LD.GetPetGuids()
    for i = 0, allPetGuids.Count - 1 do
        local guid = allPetGuids[i]
        if LD.GetPetState(PetState.Lock, guid) == false and LD.GetPetState(PetState.Show, guid) == false and LD.GetPetState(PetState.Lineup, guid) == false then
            table.insert(TradeUI.canSellOwnPetGuids, guid)
        end
    end

    for i = 1, #TradeUI.canSellOwnPetGuids do
        local ownPet = GUI.GetChild(ownPetScr, "pet" .. i)
        if ownPet == nil then
            ownPet = TradeUI.CreateOwnPet(i, ownPetScr, true)
        end
        local petInfo = LD.GetPetData(TradeUI.canSellOwnPetGuids[i])
        TradeUI.UpdateOwnPet(ownPet, petInfo)
    end
end

function TradeUI.CreateSellPet(index, ownPetScr)
    local ownPet = GUI.ButtonCreate(ownPetScr, "pet" .. index, "1800700030", 0, 0, Transition.ColorTint, "", 420, 100, false)
    GUI.SetData(ownPet, "Index", index)
    GUI.RegisterUIEvent(ownPet, UCE.PointerClick, "TradeUI", "OnSellPetClick")

    local iconBg = GUI.ImageCreate(ownPet, "iconBg", "1800201110", -155, 0)
    local icon = GUI.ImageCreate(iconBg, "icon", "1900000000", 0, 0)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Center)
    GUI.SetVisible(icon, false)

    local name = GUI.CreateStatic(ownPet, "name", "宠物名字", 110, -20, 0, 0, "system", true)
    GUI.StaticSetFontSize(name, 24)
    GUI.SetColor(name, UIDefine.BrownColor)
    UILayout.SetSameAnchorAndPivot(name, UILayout.Left)
    GUI.SetVisible(name, false)

    local level = GUI.CreateStatic(ownPet, "level", "等级：", 110, 20, 120, 30, "system")
    GUI.StaticSetFontSize(level, 24)
    GUI.SetColor(level, UIDefine.Yellow2Color)
    UILayout.SetSameAnchorAndPivot(level, UILayout.Left)
    GUI.SetVisible(level, false)

    local petType = GUI.ImageCreate(ownPet, "petType", UIDefine.PetType[1], 180, 0)
    GUI.SetVisible(petType, false)
    return ownPet
end

function TradeUI.CreateOwnPet(index, ownPetScr)
    local ownPet = GUI.ButtonCreate(ownPetScr, "pet" .. index, "1800700030", 0, 0, Transition.ColorTint, "", 470, 100, false)
    GUI.SetData(ownPet, "Index", index)
    GUI.RegisterUIEvent(ownPet, UCE.PointerClick, "TradeUI", "OnOwnPetClick")

    local iconBg = GUI.ImageCreate(ownPet, "iconBg", "1800201110", -180, 0)
    local icon = GUI.ImageCreate(iconBg, "icon", "1900000000", 0, 0)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Center)

    local name = GUI.CreateStatic(ownPet, "name", "宠物名字", 110, -20, 200, 30, "system", true)
    GUI.StaticSetFontSize(name, 24)
    GUI.SetColor(name, UIDefine.BrownColor)
    UILayout.SetSameAnchorAndPivot(name, UILayout.Left)

    local level = GUI.CreateStatic(ownPet, "level", "等级：", 110, 20, 120, 30, "system")
    GUI.StaticSetFontSize(level, 24)
    GUI.SetColor(level, UIDefine.Yellow2Color)
    UILayout.SetSameAnchorAndPivot(level, UILayout.Left)

    local petType = GUI.ImageCreate(ownPet, "petType", UIDefine.PetType[1], 200, 0)

    local Select = GUI.ImageCreate(ownPet, "Select", "1800600160", 0, 0, false, 470, 100)
    GUI.SetVisible(Select, false)
    local decreaseBtn = GUI.ButtonCreate(Select, "decreaseBtn", "1800702070", 224, -38, Transition.ColorTint, "")

    return ownPet
end

function TradeUI.UpdateOwnPet(ownPet, petInfo)
    GUI.SetVisible(ownPet, true)
    local iconBg = GUI.GetChild(ownPet, "iconBg")
    local icon = GUI.GetChild(iconBg, "icon")
    local name = GUI.GetChild(ownPet, "name")
    local level = GUI.GetChild(ownPet, "level")
    local petType = GUI.GetChild(ownPet, "petType")
    local petConfig = DB.GetOncePetByKey1(LD.GetPetIntAttr(RoleAttr.RoleAttrRole, petInfo.guid))
    if petConfig ~= nil then
        GUI.ImageSetImageID(icon, tostring(petConfig.Head))
        GUI.ImageSetImageID(petType, UIDefine.PetType[petConfig.Grade])
    end

    GUI.StaticSetText(name, petInfo.name)
    GUI.StaticSetText(level, "等级：" .. LD.GetPetIntAttr(RoleAttr.RoleAttrLevel, petInfo.guid))
    --#GUI.StaticSetText(fight,"战力："..petInfo.fight_value)

    --剩余时间
    --#GlobalUtils.CreatePetLifeText(ownPet, petInfo, -60, 18, 24, UIAnchor.TopRight, UIAroundPivot.TopRight,2)
end

function TradeUI.OnAnotherInfoBtnClick()
    local anotherInfo = GUI.Get(panelBgPath .. "/anotherInfo")
    if anotherInfo == nil then
        CL.SendNotify(NOTIFY.QueryPlayerInfo, LD.GetAnotherNameInTradeP2P())
        return
    end

    if GUI.GetVisible(anotherInfo) then
        GUI.Destroy(anotherInfo)
    else
        CL.SendNotify(NOTIFY.QueryPlayerInfo, LD.GetAnotherNameInTradeP2P())
    end
end

function TradeUI.OnTradeP2PCloseNtf()
    GUI.DestroyWnd("TradeUI")
end

function TradeUI.OnClose(key)
    GUI.Destroy("TradeUI")
    --#	CL.SendNotify(NOTIFY.TradeP2PClose)
end

function TradeUI.CreateLabel(PageList, panelBg)
    local LabelListArgs = PageList
    local tempBtn = GUI.ButtonCreate(panelBg, LabelListArgs[2], LabelListArgs[3], LabelListArgs[6], LabelListArgs[7], Transition.SpriteSwap, "", LabelListArgs[10], LabelListArgs[11], false)
    UILayout.SetSameAnchorAndPivot(tempBtn, UILayout.Center)
    local btnSprite = GUI.ImageCreate(tempBtn, "btnSprite", LabelListArgs[4], 0, 0, false, LabelListArgs[10], LabelListArgs[11])
    UILayout.SetSameAnchorAndPivot(btnSprite, UILayout.Center)
    GUI.SetVisible(btnSprite, false)
    local labelText = GUI.CreateStatic(tempBtn, "labelText", LabelListArgs[1], -3, 0, LabelListArgs[8], LabelListArgs[9], "system", true)
    UILayout.SetSameAnchorAndPivot(labelText, UILayout.Center)

    GUI.StaticSetFontSize(labelText, 22)
    GUI.StaticSetAlignment(labelText, TextAnchor.MiddleCenter)
    GUI.SetColor(labelText, UIDefine.BrownColor)
    GUI.RegisterUIEvent(tempBtn, UCE.PointerClick, "TradeUI", LabelListArgs[5])
end

function TradeUI.SetLabelSelectBtn(list, key)
    local spriteList = {}
    for i = 1, #list do
        spriteList[list[i][2]] = GUI.Get(panelBgPath .. "/" .. list[i][2] .. "/btnSprite")
    end
    for k, v in pairs(spriteList) do
        if v ~= nil then
            GUI.SetVisible(v, k == key)
        end
    end
end
