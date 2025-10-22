FightValueRankUI = {
    showNum = 0,
    RankID = 1,
}
local _gt = UILayout.NewGUIDUtilTable()
FightValueRankUI.rankingIndex = 0
local ranking_image_list = {1801604010,1801604020,1801604030}
local ranking_bg_image_list = {1801601100,1801601110,1801601120}
local sortRankList = function (a,b)
    if a[1] < b[1] then
        return true
    end
    return false
end
function FightValueRankUI.InitData()
    if GlobalProcessing and GlobalProcessing.IntegralPK_SeverData then
        FightValueRankUI.tips = GlobalProcessing.IntegralPK_SeverData[1].Tips
        FightValueRankUI.ShowMinIntegral = GlobalProcessing.IntegralPK_SeverData[1].ShowMinIntegral
        FightValueRankUI.MaxRanking = GlobalProcessing.IntegralPK_SeverData[1].MaxRanking
        local TimeLimit = GlobalProcessing.IntegralPK_SeverData[1].TimeLimit
        FightValueRankUI.ShowPetStar = GlobalProcessing.IntegralPK_SeverData[1].ShowPetStar
        FightValueRankUI.beginTime = UIDefine.GetTimeCountByFormat(TimeLimit[1])
        FightValueRankUI.endTime = UIDefine.GetTimeCountByFormat(TimeLimit[2])
        FightValueRankUI.closeTime = UIDefine.GetTimeCountByFormat(TimeLimit[3])
        FightValueRankUI.rankingRewardList = {}
        FightValueRankUI.Ranking = {}
        for key, value in pairs(GlobalProcessing.IntegralPK_SeverData[1].Reward) do
            local ranking = value.Ranking
            table.insert(FightValueRankUI.Ranking,ranking)
            for index = ranking[1], ranking[2], 1 do
                FightValueRankUI.rankingRewardList[index] = {}
                local PetList = value.PetList
                local ItemList = value.ItemList
                if PetList then
                    for i = 1, #PetList, 3 do
                        table.insert(FightValueRankUI.rankingRewardList[index],{itemName = PetList[i],itemNum = PetList[i+1],isBind = PetList[i+1],isPet = true})
                    end
                end
                if ItemList then
                    for i = 1, #ItemList, 3 do
                        table.insert(FightValueRankUI.rankingRewardList[index],{itemName = ItemList[i],itemNum = ItemList[i+1],isBind = ItemList[i+1],isPet = false})
                    end
                end
            end
        end
        table.sort(FightValueRankUI.Ranking,sortRankList)
    end
end
function FightValueRankUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    FightValueRankUI.InitData()
    -- 界面
    local _panel = GUI.WndCreateWnd("FightValueRankUI","FightValueRankUI",0,0)
    UILayout.SetSameAnchorAndPivot(_panel, UILayout.Center)

    local _panelCover = GUI.ImageCreate(_panel, "panelCover", "1800400220", 0, 0, false, GUI.GetWidth(_panel), GUI.GetHeight(_panel))
    GUI.SetIsRaycastTarget(_panelCover, true)
    _panelCover:RegisterEvent(UCE.PointerClick)

    local _panelBg = GUI.ImageCreate(_panel, "panelBg", "1801601020", 77, 31, false, 1082, 584)
    UILayout.SetSameAnchorAndPivot(_panelBg, UILayout.Center)
    _gt.BindName(_panelBg,"panelBg")

    local _closeBtn = GUI.ButtonCreate(_panel, "closeBtn", "1801502010", 616, -287, Transition.ColorTint, "", 64, 64, false)
    UILayout.SetSameAnchorAndPivot(_closeBtn, UILayout.Center)
    GUI.RegisterUIEvent(_closeBtn, UCE.PointerClick, "FightValueRankUI", "OnCloseBtnClick")

    -- 左侧刑天相关图标
    local _rewardInfo = GUI.GroupCreate(_panelBg,"rewardInfo", 0, 0)
    UILayout.SetSameAnchorAndPivot(_rewardInfo, UILayout.TopLeft)
    local _rewardImg = GUI.ImageCreate(_rewardInfo, "rewardImg", "1801608060", -251, -179, false)
    UILayout.SetSameAnchorAndPivot(_rewardImg, UILayout.TopLeft)

    local _rewardDesImg = GUI.ImageCreate(_rewardInfo, "rewardDesImg", "1801604050", -181, 385, false)
    UILayout.SetSameAnchorAndPivot(_rewardDesImg, UILayout.TopLeft)

    local _titleImg = GUI.ImageCreate(_panelBg, "titleImg", "1801604060", 150, -304, false)
    UILayout.SetSameAnchorAndPivot(_titleImg, UILayout.Center)

    local _rewardNameImg = GUI.ImageCreate(_rewardInfo, "rewardNameImg", "1801604070", 247, 289, false)
    UILayout.SetSameAnchorAndPivot(_rewardNameImg, UILayout.TopLeft)

    local _showPetBtn = GUI.ButtonCreate(_rewardInfo, "showPetBtn", "1801402010", 178, 493, Transition.ColorTint, "", 0, 0, true)
    UILayout.SetSameAnchorAndPivot(_showPetBtn, UILayout.TopLeft)
    local _showPetTxt = GUI.ImageCreate(_showPetBtn, "showPetTxt", "1801604090", 1, -1, false)
    UILayout.SetSameAnchorAndPivot(_showPetTxt, UILayout.Center)
    GUI.RegisterUIEvent(_showPetBtn, UCE.PointerClick, "FightValueRankUI", "OnShowPetBtnClick")
    local _showPetBtnEffect = GUI.RichEditCreate(_showPetTxt, "showPetBtnEffect", "#IMAGE3410100000#", -33, 14, 200, 200)
    GUI.SetIsRaycastTarget(_showPetBtnEffect, false)

    for i = 1, 6, 1 do
        local _star = GUI.ImageCreate(_rewardInfo, "star"..i, "1801202190", 335, 202 + 39 * i, false)
        UILayout.SetSameAnchorAndPivot(_star, UILayout.TopLeft)
    end

    -- 活动规则及时间
    local textColor = Color.New(223/255,175/255,108/255,255/255)
    local textOutLineColor = Color.New(127/255,38/255,22/255)
    local _rewardSystemBg = GUI.ImageCreate(_panelBg, "rewardSystemBg", "1801601030", 491, 48, false, 538, 69)
    UILayout.SetSameAnchorAndPivot(_rewardSystemBg, UILayout.TopLeft)

    local _clockBg = GUI.ImageCreate(_rewardSystemBg, "clockBg", "1801601040", -25, -9, false, 240, 24)
    UILayout.SetSameAnchorAndPivot(_clockBg, UILayout.BottomRight)

    local _rewardSystemDes = GUI.CreateStatic(_rewardSystemBg,"rewardSystemDes",FightValueRankUI.tips,0,0,500, 60, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_rewardSystemDes, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_rewardSystemDes, UIDefine.FontSizeSS, textColor, TextAnchor.MiddleLeft)
	GUI.SetIsOutLine(_rewardSystemDes, true)
	GUI.SetOutLine_Distance(_rewardSystemDes, 1)
	GUI.SetOutLine_Color(_rewardSystemDes, textOutLineColor)

    local _clockDes = GUI.CreateStatic(_clockBg,"clockDes","活动剩余时间", -16, -1, 200, 24, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_clockDes, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(_clockDes, UIDefine.FontSizeSSS, textColor, TextAnchor.MiddleLeft)
	GUI.SetIsOutLine(_clockDes, true)
	GUI.SetOutLine_Distance(_clockDes, 1)
	GUI.SetOutLine_Color(_clockDes, textOutLineColor)
    _gt.BindName(_clockDes,"clockDes")

    local _clockTime = GUI.CreateStatic(_clockBg,"clockTime","", -125, -1, 120, 24, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_clockTime, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(_clockTime, UIDefine.FontSizeSSS, UIDefine.White2Color, TextAnchor.MiddleCenter)
    _gt.BindName(_clockTime,"clockTime")
    -- 排行榜
    local _rankingListBg = GUI.ImageCreate(_panelBg, "rankingListBg", "1801601050", 376, 120, false, 616, 437)
    UILayout.SetSameAnchorAndPivot(_rankingListBg, UILayout.TopLeft)

    -- 标题
    local _rankingListTitle = GUI.GroupCreate(_rankingListBg,"rankingListTitle", 8, 6)
    UILayout.SetSameAnchorAndPivot(_rankingListTitle, UILayout.TopLeft)

    local _rankingBg = GUI.ImageCreate(_rankingListTitle, "rankingBg", "1801601060", 0, 0, false, 98, 32)
    local _rankingText = GUI.CreateStatic(_rankingBg,"rankingText","排名",0,0,98, 35, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_rankingText, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_rankingText, UIDefine.FontSizeM, UIDefine.Brown3Color, TextAnchor.MiddleCenter)

    local _nameBg = GUI.ImageCreate(_rankingListTitle, "nameBg", "1801601070", 98, 0, false, 130, 32)
    local _nameText = GUI.CreateStatic(_nameBg,"nameText","玩家名称",0,0,130, 35, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_nameText, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_nameText, UIDefine.FontSizeM, UIDefine.Brown3Color, TextAnchor.MiddleCenter)

    local _eventDesBg = GUI.ImageCreate(_rankingListTitle, "eventDesBg", "1801601070", 228, 0, false, 112, 32)
    local _eventTips = GUI.ButtonCreate(_eventDesBg, "eventTips", "1800702030", 9, 3, Transition.ColorTint, "", 26, 26, false)
    GUI.RegisterUIEvent(_eventTips, UCE.PointerClick, "FightValueRankUI", "OnEventTipsClick")
    local _eventDesText = GUI.CreateStatic(_eventDesBg,"eventDesText","总战力",18,0,112, 35, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_eventDesText, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_eventDesText, UIDefine.FontSizeM, UIDefine.Brown3Color, TextAnchor.MiddleCenter)

    local _rewardBg = GUI.ImageCreate(_rankingListTitle, "rewardBg", "1801601060", 601, 0, false, 260, 32)
    GUI.SetScale(_rewardBg, Vector3.New(-1,1,1))
    local _rewardText = GUI.CreateStatic(_rewardBg,"rewardText","排名奖励",0,0,260, 35, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_rewardText, UILayout.Center)
    UILayout.StaticSetFontSizeColorAlignment(_rewardText, UIDefine.FontSizeM, UIDefine.Brown3Color, TextAnchor.MiddleCenter)
    GUI.SetScale(_rewardText, Vector3.New(-1,1,1))

    -- 排行榜信息
    local _rankingScroll = GUI.LoopScrollRectCreate(_rankingListBg,"rankingScroll", 8, 38, 600, 270, "FightValueRankUI", "CreateRankingScroll",
                "FightValueRankUI", "RefreshRankingScroll", 0, false, Vector2.New(600,90), 1, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(_rankingScroll,"rankingScroll")

    -- 玩家名次标题
    local _playerRankingTitleBg = GUI.ImageCreate(_rankingListBg, "playerRankingTitleBg", "1800600690", 7, 308, false, 602, 30)
    
    local _titleText = GUI.CreateStatic(_playerRankingTitleBg,"titleText","您的排名",14,0,300, 35, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_titleText, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(_titleText, UIDefine.FontSizeS, UIDefine.White2Color, TextAnchor.MiddleLeft)
    GUI.SetIsOutLine(_titleText, true)
	GUI.SetOutLine_Distance(_titleText, 1)
	GUI.SetOutLine_Color(_titleText, UIDefine.Brown3Color)

    local _rewardDes = GUI.CreateStatic(_playerRankingTitleBg,"rewardDes","",-24,0,300, 35, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_rewardDes, UILayout.Right)
    UILayout.StaticSetFontSizeColorAlignment(_rewardDes, UIDefine.FontSizeS, UIDefine.White2Color, TextAnchor.MiddleRight)
    GUI.SetIsOutLine(_rewardDes, true)
	GUI.SetOutLine_Distance(_rewardDes, 1)
	GUI.SetOutLine_Color(_rewardDes, UIDefine.Brown3Color)
    _gt.BindName(_rewardDes,"rewardDes")

    -- 玩家名次信息
    local playerInfo = FightValueRankUI.CreatePlayerInfo(_rankingListBg,"playerInfo")
    GUI.SetPositionX(playerInfo,8)
    GUI.SetPositionY(playerInfo,339)
    _gt.BindName(playerInfo,"playerInfo")

    CL.RegisterMessage(GM.RankDateUpdate, "FightValueRankUI", "OnRefreshRankDate")
end
function FightValueRankUI.OnRefreshRankDate(type, rankType)
    if type == 1 then
        if rankType == FightValueRankUI.RankID then
            FightValueRankUI.RefreshUI()
        end
    elseif type == 2 then
        if rankType == FightValueRankUI.RankID then
            FightValueRankUI.RefreshUI()
        end
    end
end
function FightValueRankUI.CreateRankingScroll(guid)
    local _rankingScroll = _gt.GetUI("rankingScroll")
    local scrollCount = GUI.LoopScrollRectGetTotalCount(_rankingScroll) + 1
    local playerInfo = FightValueRankUI.CreatePlayerInfo(_rankingScroll,"playerInfoNO"..scrollCount)
    return playerInfo
end
function FightValueRankUI.CreatePlayerInfo(parent,name)
    local _infoBg = GUI.ImageCreate(parent, name, "1801601130", 0, 0, false, 600, 90)

    local _playerRankingBg = GUI.ImageCreate(_infoBg, "playerRankingBg", "1801604040", 29, 20, false)

    local _playerRankingText = GUI.CreateStatic(_infoBg,"playerRankingText","5",-4,0,115, 35, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_playerRankingText, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(_playerRankingText, UIDefine.FontSizeL, UIDefine.White2Color, TextAnchor.MiddleCenter)
    GUI.SetIsOutLine(_playerRankingText, true)
	GUI.SetOutLine_Distance(_playerRankingText, 1)
	GUI.SetOutLine_Color(_playerRankingText, UIDefine.Brown4Color)

    local _dividingLine1 = GUI.ImageCreate(_infoBg, "dividingLine1", "1801601090", 97, 10, false)

    local _playerName = GUI.CreateStatic(_infoBg,"playerName","小行星",50,0,230, 35, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_playerName, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(_playerName, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

    local _dividingLine2 = GUI.ImageCreate(_infoBg, "dividingLine2", "1801601090", 228, 10, false)

    local _playerFightValue = GUI.CreateStatic(_infoBg,"playerFightValue","12345678",195,0,180, 35, "system", true, false)
    UILayout.SetSameAnchorAndPivot(_playerFightValue, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(_playerFightValue, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)

    local _dividingLine3 = GUI.ImageCreate(_infoBg, "dividingLine3", "1801601090", 340, 10, false)

    local _itemScroll = GUI.LoopScrollRectCreate(_infoBg,"itemScroll", 345, 7, 255, 76, "FightValueRankUI", "CreateItemIcon",
        "FightValueRankUI", "RefreshItemIcon", 0, true, Vector2.New(76, 76), 1, UIAroundPivot.Left, UIAnchor.Left)
    return _infoBg
end
function FightValueRankUI.RefreshRankingItem(index,playerInfo)
    GUI.SetData(playerInfo, "index", index)
    local _playerRankingBg = GUI.GetChild(playerInfo,"playerRankingBg",false)
    local _playerRankingText = GUI.GetChild(playerInfo,"playerRankingText",false)
    local _playerName = GUI.GetChild(playerInfo,"playerName",false)
    local _playerFightValue = GUI.GetChild(playerInfo,"playerFightValue",false)
    GUI.StaticSetFontSize(_playerName, UIDefine.FontSizeL)
    GUI.StaticSetFontSize(_playerFightValue, UIDefine.FontSizeL)
    local _itemScroll = GUI.GetChild(playerInfo,"itemScroll",false)
    if ranking_bg_image_list[index] then
        GUI.ImageSetImageID(playerInfo,ranking_bg_image_list[index])
        GUI.ImageSetImageID(_playerRankingBg,ranking_image_list[index])
        GUI.StaticSetText(_playerRankingText,"")
        GUI.SetWidth(_playerRankingBg,81)
        GUI.SetHeight(_playerRankingBg,85)
        GUI.SetPositionX(_playerRankingBg,9)
        GUI.SetPositionY(_playerRankingBg,0)
    else
        GUI.ImageSetImageID(playerInfo,"1801601130")
        GUI.ImageSetImageID(_playerRankingBg,"1801604040")
        GUI.StaticSetText(_playerRankingText,index)
        GUI.SetWidth(_playerRankingBg,50)
        GUI.SetHeight(_playerRankingBg,50)
        GUI.SetPositionX(_playerRankingBg,29)
        GUI.SetPositionY(_playerRankingBg,20)
    end
    if FightValueRankUI.rankData[index] then
        local currentItem = FightValueRankUI.rankData[index]
        GUI.StaticSetText(_playerName,currentItem.name)
        GUI.StaticSetText(_playerFightValue,tostring(currentItem.fightValue))
        GUI.LoopScrollRectSetTotalCount(_itemScroll, 0)
        if FightValueRankUI.rankingRewardList[index] then
            GUI.LoopScrollRectSetTotalCount(_itemScroll, #FightValueRankUI.rankingRewardList[index])
        else
            GUI.LoopScrollRectSetTotalCount(_itemScroll, 4)
        end
    else
        GUI.StaticSetText(_playerRankingText,"未上榜")
        GUI.StaticSetText(_playerName,CL.GetRoleName())
        if FightValueRankUI.nowtime <= FightValueRankUI.endTime then
            local fightValue = CL.GetAttr(RoleAttr.RoleAttrFightValue)
            local petNum = FightValueRankUI.GetPetFightValue()
            local guardNum = FightValueRankUI.GetGuardFightValue()
            local totalNum = fightValue + petNum + guardNum
            GUI.StaticSetText(_playerFightValue,tostring(totalNum))
        else
            local fightValue = CL.GetIntCustomData("IntegralPK_RecordFightValue")
            GUI.StaticSetText(_playerFightValue,tostring(fightValue))
        end
        GUI.LoopScrollRectSetTotalCount(_itemScroll, 0)
        GUI.LoopScrollRectSetTotalCount(_itemScroll, 4)
    end
    GUI.LoopScrollRectRefreshCells(_itemScroll)
    if GUI.StaticGetLabelPreferWidth(_playerName) > 100 then
        GUI.StaticSetFontSize(_playerName, UIDefine.FontSizeS)
    end
    if GUI.StaticGetLabelPreferWidth(_playerFightValue) > 100 then
        GUI.StaticSetFontSize(_playerFightValue, UIDefine.FontSizeS)
    end
end
function FightValueRankUI.RefreshRankingScroll(parameter)
    parameter = string.split(parameter,"#")
    local guid = parameter[1]
    local index = parameter[2] + 1
    local playerInfo = GUI.GetByGuid(guid)
    FightValueRankUI.RefreshRankingItem(index,playerInfo)
end
function FightValueRankUI.CreateItemIcon(guid)
    guid = tostring(guid)
    local _itemScroll = GUI.GetByGuid(guid)
    local curCount = GUI.LoopScrollRectGetTotalCount(_itemScroll) + 1
    local item = ItemIcon.Create(_itemScroll, "item" .. curCount, 0, 0,76,76)
    GUI.SetData(item, "pguid", guid)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "FightValueRankUI", "OnItemIconClick")
    return item
end
function FightValueRankUI.OnItemIconClick(guid)
    local itemIcon = GUI.GetByGuid(guid)
    local _panelBg = _gt.GetUI("panelBg")
    local itemName = GUI.GetData(itemIcon,"itemName")
    local isPet = GUI.GetData(itemIcon,"isPet")
    if string.find(isPet,"true") then
        CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "QueryPetByKeyName", itemName)
    else
        Tips.CreateByItemKeyName(itemName,_panelBg,"itemTips",0,0)
    end
end
function FightValueRankUI.RefreshItemIcon(parameter)
    parameter = string.split(parameter,"#")
    local guid = parameter[1]
    local index = parameter[2] + 1
    local itemIcon = GUI.GetByGuid(guid)
    local effect = GUI.GetChild(itemIcon,"effect",false)
    local pguid = GUI.GetData(itemIcon, "pguid")
    local playerInfo = GUI.GetParentElement(GUI.GetByGuid(pguid))
    local pindex = tonumber(GUI.GetData(playerInfo, "index"))
    if FightValueRankUI.rankingRewardList and FightValueRankUI.rankingRewardList[pindex] then
        local item = FightValueRankUI.rankingRewardList[pindex][index]
        GUI.SetData(itemIcon, "itemName", item.itemName)
        GUI.SetData(itemIcon, "isPet", tostring(item.isPet))
        if item.isPet then
            local petDB = DB.GetOncePetByKey2(item.itemName)
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.PetItemIconBg3[petDB.Grade]);
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, tostring(petDB.Head))
            GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60)
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, item.itemNum)
            if FightValueRankUI.ShowPetStar then
                local petstartlevel = FightValueRankUI.ShowPetStar[item.itemName]
                if petstartlevel then
                    UILayout.SetSmallStars(petstartlevel, 6, itemIcon)
                else
                    UILayout.SetSmallStars(1, 6, itemIcon)
                end
            else
                if string.find(item.itemName,"6星") then
                    UILayout.SetSmallStars(6, 6, itemIcon)
                else
                    UILayout.SetSmallStars(1, 6, itemIcon)
                end
            end
            if effect == nil then
                effect = GUI.RichEditCreate(itemIcon,"effect","#IMAGE3407700000#",0,20,60,60)
                GUI.StaticSetAlignment(effect, TextAnchor.MiddleCenter)
                UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
                GUI.SetWidth(effect,GUI.RichEditGetPreferredWidth(effect))
                GUI.SetHeight(effect,GUI.RichEditGetPreferredHeight(effect))
                GUI.SetIsRaycastTarget(effect, false)
                GUI.SetScale(effect,Vector3.New(0.7,0.7,1))
            else
                GUI.SetVisible(effect,true)
            end
        else
            local itemDB =DB.GetOnceItemByKey2(item.itemName)
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[itemDB.Grade]);
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, itemDB.Icon)
            GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60)
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, item.itemNum)
            UILayout.SetSmallStars(1, -1, itemIcon)
            GUI.SetVisible(effect,false)
        end
    else
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, UIDefine.ItemIconBg[1]);
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "")
        GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,60,60)
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, "")
        UILayout.SetSmallStars(1, -1, itemIcon)
        GUI.SetVisible(effect,false)
    end
end

function FightValueRankUI.OnCloseBtnClick()
    GUI.CloseWnd("FightValueRankUI")
    FightValueRankUI.RankTimer:Stop()
end

function FightValueRankUI.OnShow()
    local wnd = GUI.GetWnd("FightValueRankUI")
    if wnd == nil then
        return
    end
    GUI.SetVisible(wnd, true)
    FightValueRankUI.RefreshRankTime()
    FightValueRankUI.RefreshUI()
end

function FightValueRankUI.RefreshRankTime()
    FightValueRankUI.CountRankTime()
    if not FightValueRankUI.RankTimer then
        FightValueRankUI.RankTimer = Timer.New(FightValueRankUI.CountRankTime, 1, -1)
    end
    FightValueRankUI.RankTimer:Stop()
    FightValueRankUI.RankTimer:Start()
end

function FightValueRankUI.RefreshUI()
    FightValueRankUI.RankID = GlobalProcessing.IntegralPK_SeverData[1].RankID
    local nowTime = os.date("!%Y-%m-%d %H:%M:%S",CL.GetServerTickCount())
    FightValueRankUI.nowtime = UIDefine.GetTimeCountByFormat(nowTime)
    if FightValueRankUI.nowtime >= FightValueRankUI.endTime and FightValueRankUI.nowtime <= FightValueRankUI.closeTime then
        FightValueRankUI.RankID = GlobalProcessing.IntegralPK_SeverData[1].SaveRankID
    end
    local rankData = LD.GetRankData(FightValueRankUI.RankID)
    FightValueRankUI.rankData = {}
    if rankData == nil or rankData.Count == 0 then
        CL.SendNotify(NOTIFY.RankOpe, 1, FightValueRankUI.RankID, FightValueRankUI.MaxRanking)
    else
        local selfRank = LD.GetSelfRankData(FightValueRankUI.RankID)
        if selfRank == nil then
            CL.SendNotify(NOTIFY.RankOpe, 2, FightValueRankUI.RankID)
            return ""
        else
            local selfFightValue = tonumber(tostring(selfRank.rank_data1))
            if selfRank.rank == 0 or selfFightValue < FightValueRankUI.ShowMinIntegral then
                FightValueRankUI.rankingIndex = 0
            else
                FightValueRankUI.rankingIndex = tonumber(tostring(selfRank.rank))
            end
        end
        for i = 1, rankData.Count, 1 do
            local curRankData = rankData[i - 1]
            local name = curRankData.name
            local fightValue = tonumber(tostring(curRankData.rank_data1))
            if fightValue >= FightValueRankUI.ShowMinIntegral then
                table.insert(FightValueRankUI.rankData,{name = name,fightValue = fightValue})
            end
        end
        FightValueRankUI.showNum = math.min(GlobalProcessing.IntegralPK_SeverData[1].ShowNum,#FightValueRankUI.rankData)
        local scroll = _gt.GetUI("rankingScroll")
        GUI.LoopScrollRectSetTotalCount(scroll, 0)
        GUI.LoopScrollRectSetTotalCount(scroll, FightValueRankUI.showNum)
        GUI.LoopScrollRectRefreshCells(scroll)
        local playerInfo = _gt.GetUI("playerInfo")
        local _rewardDes = _gt.GetUI("rewardDes")
        FightValueRankUI.RefreshRankingItem(FightValueRankUI.rankingIndex,playerInfo)
        if FightValueRankUI.rankingIndex == 1 then
            GUI.StaticSetText(_rewardDes,"已达到最高名次")
        else
            local index = 1
            if FightValueRankUI.rankingIndex == 0 or FightValueRankUI.rankingIndex > FightValueRankUI.Ranking[#FightValueRankUI.Ranking][2] then
                index = FightValueRankUI.Ranking[#FightValueRankUI.Ranking][2]
            else
                for i = 1, #FightValueRankUI.Ranking, 1 do
                    local ranking = FightValueRankUI.Ranking[i]
                    if FightValueRankUI.rankingIndex >= ranking[1] and FightValueRankUI.rankingIndex <= ranking[2] then
                        index = FightValueRankUI.Ranking[i-1][2]
                    end
                end
            end
            GUI.StaticSetText(_rewardDes,"达到第"..index.."名，可领取更好奖品")
        end
        FightValueRankUI.CountRankTime()
    end
    -- local inspect = require("inspect")
    -- test(inspect(GlobalProcessing.IntegralPK_SeverData))
end

function FightValueRankUI.CountRankTime()
    local nowTime = os.date("!%Y-%m-%d %H:%M:%S",CL.GetServerTickCount())
    FightValueRankUI.nowtime = UIDefine.GetTimeCountByFormat(nowTime)
    local now = FightValueRankUI.endTime - FightValueRankUI.nowtime
    local _clockDes = _gt.GetUI("clockDes")
    local _clockTime = _gt.GetUI("clockTime")
    if _clockDes then
        if now < 0 then
            if GUI.GetData(_clockTime,"time") ~= "-1" then
                if FightValueRankUI.rankingIndex ~= 0 and FightValueRankUI.rankingIndex <= FightValueRankUI.Ranking[#FightValueRankUI.Ranking][2] then
                    CL.SendNotify(NOTIFY.ShowBBMsg,"活动已结束 奖励已发至邮箱")
                    GUI.StaticSetText(_clockDes,"活动已结束 奖励已发至邮箱")
                    GUI.SetPositionX(_clockDes, 24)
                else
                    CL.SendNotify(NOTIFY.ShowBBMsg,"活动已结束")
                    GUI.StaticSetText(_clockDes,"活动已结束")
                    GUI.SetPositionX(_clockDes, 81)
                end
                GUI.SetData(_clockTime,"time","-1")
                GUI.StaticSetText(_clockTime,"")
            end
            if FightValueRankUI.RankTimer then
                FightValueRankUI.RankTimer:Stop()
            end
        else
            GUI.StaticSetText(_clockDes,"活动剩余时间")
            GUI.SetPositionX(_clockDes, 16)
            local str = {}
            str[1] = math.floor(now / 86400) -- 天
            str[2] = math.floor(now % 86400 / 3600)
            str[3] = math.floor(now % 3600 / 60)
            str[4] = now % 60

            for i = 3, 4, 1 do
                if str[i] < 10 then
                    str[i] = "0" .. str[i]
                end
            end
            if str[1] == 0 then
                GUI.StaticSetText(_clockTime,str[2]..":"..str[3]..":"..str[4])
                if str[2] < 12 then
                    GUI.SetColor(_clockTime,Color.New(203/255,22/255,28/255,255/255))
                else
                    GUI.SetColor(_clockTime,UIDefine.White2Color)
                end
            else
                GUI.StaticSetText(_clockTime,str[1].."天"..str[2]..":"..str[3]..":"..str[4])
            end
        end
    end
end

function FightValueRankUI.OnShowPetBtnClick()
    CL.SendNotify(NOTIFY.SubmitForm, "FormPet", "QueryPetByKeyName", "6星魔兽刑天")
end

function FightValueRankUI.GetPetFightValue()
    --上阵宠物
    local petNum = 0
    local petList=LD.GetPetGuids()
    for i = 0, petList.Count-1 do
        local id = petList[i]
        --local state = tostring(LD.GetPetAttr(id, RoleAttr.PetAttrStatus))--获取宠物状态，>宠物状态：bit0:绑定 bit1:锁定 bit2:展示 bit3:上阵
        local isLineup = LD.GetPetState(PetState.Lineup,id)
        if isLineup then
            local zl = LD.GetPetAttr(RoleAttr.RoleAttrFightValue, id)
            petNum = petNum + zl
        end
    end
    return petNum
end

function FightValueRankUI.GetGuardFightValue()
    --上阵侍从
    local guardNum = 0
    local activeGuardList = LD.GetActivedGuard()
    for i = 0,activeGuardList.Count-1 do
        local id = activeGuardList[i]
        local linup = tostring(LD.GetGuardAttr(id,RoleAttr.GuardAttrIsLinup))
        if linup == "1" then --已上阵的
            local zl = LD.GetGuardAttr(id,RoleAttr.RoleAttrFightValue)
            --test("=========zl======="..tostring(zl))
            guardNum = guardNum + zl
        end
    end
    return guardNum
end

function FightValueRankUI.OnEventTipsClick()
    --角色战力
    local fightValue = CL.GetAttr(RoleAttr.RoleAttrFightValue)

    --上阵宠物
    local petNum = FightValueRankUI.GetPetFightValue()

    --上阵侍从
    local guardNum = FightValueRankUI.GetGuardFightValue()

    --总战力
    local totalNum = fightValue + petNum + guardNum

    local _panelBg = _gt.GetUI("panelBg")
    local zongzhanli_desc = "总战力=角色战力+上阵宠物战力+上阵侍从战力"
    local zongzhanli_num = "总战力:".."<color=yellow>"..tostring(totalNum).."</color>"
    local jusezhanli_num = "角色战力:".."<color=yellow>"..tostring(fightValue).."</color>"
    local petzhanli_num = "上阵宠物战力:".."<color=yellow>"..tostring(petNum).."</color>"
    local guardzhanli_num = "上阵侍从战力:".."<color=yellow>"..tostring(guardNum).."</color>"
    local info = string.format("%s\n%s\n%s\n%s\n%s",zongzhanli_desc,zongzhanli_num,jusezhanli_num,petzhanli_num,guardzhanli_num)
    Tips.CreateHint(info, _panelBg, -180, -250, {UIAnchor.Center, UIAroundPivot.Center}, 480,150,true)
end