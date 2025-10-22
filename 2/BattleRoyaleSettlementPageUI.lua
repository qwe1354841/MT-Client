BattleRoyaleSettlementPageUI = {}
local _gt = UILayout.NewGUIDUtilTable()

local Width = 0
local Height = 0
local ChickCoinDB = {Id=61024, Name="神鸡之羽", KeyName="面板展示-吃鸡代币", Type=3, Subtype=14, Subtype2=0, ShowType="神鸡之羽", User="1", NumberMax=0, Grade=6, SaleGoldBind=10, BuyGoldBind=5000, Icon=1900120010, Info="可在兑换商店兑换道具", Tips="鸡王争霸赛奖励。", TurnBorn=0, Level=1, Sex=0, Job=0, Fight=2, FightTarget=0, StackMax=1, CarryMax=99, TimeLimit=0, TimeCount=0, BindType=0, BindConfirm=1, Tradable=1, Sale=1, SaleConfirm=0, JustUseIt=0, Ingot=5, FastShop=4, FromItem=0, ActivityId=0, Role=0, ModelMan=0, ModelWoman=0, Itemlevel=0, ArmorLevel=0, Role2=0, ModelRole1=0, ModelRole2=0, DurableLose=0, Repair=0, IconDrop=0}
BattleRoyaleSettlementPageUI.ClickItemGuid = ""
function BattleRoyaleSettlementPageUI.Main()
    _gt = UILayout.NewGUIDUtilTable()
    local panel = GUI.WndCreateWnd("BattleRoyaleSettlementPageUI", "BattleRoyaleSettlementPageUI",0,0)

    UILayout.SetSameAnchorAndPivot(panel, UILayout.Center)
    local panelBg = GUI.ImageCreate(panel, "Back", "", 0, 0, false)
    GUI.RegisterUIEvent(panelBg, ULE.CreateFinsh, "BattleRoyaleSettlementPageUI", "OnCreate")
    _gt.BindName(panelBg,"Back")
    UILayout.SetSameAnchorAndPivot(panelBg, UILayout.Center)
    GUI.SetIsRaycastTarget(panelBg, true)

    local _playerName = GUI.CreateStatic(panelBg,"playerName","名字是六个字",30,30,600,80)
    UILayout.SetSameAnchorAndPivot(_playerName, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_playerName, 50, UIDefine.WhiteColor)
    local _slogan = GUI.CreateStatic(panelBg,"slogan","大吉大利,今晚吃鸡",30,110,600,80,"100")
    UILayout.SetSameAnchorAndPivot(_slogan, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_slogan, 60, UIDefine.YellowColor)

    local _playerRankText = GUI.CreateStatic(panelBg,"playerRankText","玩家排名",30,200,200,80,"100")
    UILayout.SetSameAnchorAndPivot(_playerRankText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_playerRankText, 30, UIDefine.WhiteColor)

    local _playerRank = GUI.CreateStatic(panelBg,"playerRank","第1",170,200,200,80,"100")
    UILayout.SetSameAnchorAndPivot(_playerRank, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_playerRank, 30, UIDefine.WhiteColor)

    local _killCountText = GUI.CreateStatic(panelBg,"killCountText","击败",30,240,200,80,"100")
    UILayout.SetSameAnchorAndPivot(_killCountText, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_killCountText, 30, UIDefine.WhiteColor)

    local _killCount = GUI.CreateStatic(panelBg,"killCount","4名玩家",170,240,200,80,"100")
    UILayout.SetSameAnchorAndPivot(_killCount, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_killCount, 30, UIDefine.WhiteColor)

    local _Text = GUI.CreateStatic(panelBg,"Text","奖励",30,300,200,80,"100")
    UILayout.SetSameAnchorAndPivot(_Text, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_Text, 30, UIDefine.WhiteColor)

    local itemSrc = GUI.LoopScrollRectCreate(panelBg,"itemSrc",30,360,440,80,"BattleRoyaleSettlementPageUI","CreateItemIcon",
                        "BattleRoyaleSettlementPageUI","RefreshItemIcon",0,true,Vector2.New(70, 70),1,UIAroundPivot.TopLeft,UIAnchor.TopLeft)
    UILayout.SetSameAnchorAndPivot(itemSrc, UILayout.TopLeft)
    GUI.ScrollRectSetChildSpacing(itemSrc, Vector2.New(3, 3))
    _gt.BindName(itemSrc, "itemSrc")

    local _battleRank = GUI.CreateStatic(panelBg,"battleRank","第1",1005,40,120,80)
    UILayout.SetSameAnchorAndPivot(_battleRank, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_battleRank, 50, UIDefine.WhiteColor,TextAnchor.MiddleRight)

    local _playerNum = GUI.CreateStatic(panelBg,"playerNum","/15",1130,45,100,80)
    UILayout.SetSameAnchorAndPivot(_playerNum, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_playerNum, 30, UIDefine.WhiteColor)

    local exitBattleBtn = GUI.ButtonCreate(panelBg, "exitBattleBtn", 1800402110, 1050, 600, Transition.ColorTint, "退出战斗", 125, 50, false);
    UILayout.SetSameAnchorAndPivot(exitBattleBtn, UILayout.TopLeft);
    GUI.ButtonSetTextColor(exitBattleBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(exitBattleBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(exitBattleBtn, UCE.PointerClick, "BattleRoyaleSettlementPageUI", "OnExitBattleBtnClick");
end

function BattleRoyaleSettlementPageUI.OnExit()
    GUI.DestroyWnd("BattleRoyaleSettlementPageUI")
end

function BattleRoyaleSettlementPageUI.OnCreate(guid)
end

function BattleRoyaleSettlementPageUI.OnExitBattleBtnClick()
    BattleRoyaleSettlementPageUI.OnExit()
    --
end

function BattleRoyaleSettlementPageUI.OnShow()
    local wnd = GUI.GetWnd("BattleRoyaleSettlementPageUI")
    if wnd == nil then
        return
    end
    GUI.CloseWnd("BattleRoyaleBoxUI")
    local Back = _gt.GetUI("Back")
    GUI.SetWidth(Back,TrackUI.Width)
    GUI.SetHeight(Back,TrackUI.Height)
    if TrackUI.BattleResultList and TrackUI.BattleResultList.index then
        if TrackUI.BattleResultList.index == 1 then
            BattleRoyaleSettlementPageUI.ShowVictoryPage(Back)
        else
            BattleRoyaleSettlementPageUI.ShowFailedPage(Back)
        end
    end
    GUI.SetVisible(wnd,true)
end

function BattleRoyaleSettlementPageUI.ShowVictoryPage(page)
    GUI.ImageSetImageID(page,"1801009010")
    local slogan = GUI.GetChild(page,"slogan")
    GUI.StaticSetText(slogan,"大吉大利,今晚吃鸡")
    BattleRoyaleSettlementPageUI.RefreshPageInfo(page)
end

function BattleRoyaleSettlementPageUI.ShowFailedPage(page)
    GUI.ImageSetImageID(page,"1801009130")
    local slogan = GUI.GetChild(page,"slogan")
    GUI.StaticSetText(slogan,"再接再厉，下次吃鸡")
    BattleRoyaleSettlementPageUI.RefreshPageInfo(page)
end

function BattleRoyaleSettlementPageUI.RefreshPageInfo(page)
    local playerName = GUI.GetChild(page,"playerName")
    local playerRank = GUI.GetChild(page,"playerRank")
    local killCount = GUI.GetChild(page,"killCount")
    local battleRank = GUI.GetChild(page,"battleRank")
    local playerNum = GUI.GetChild(page,"playerNum")
    local roleName = CL.GetRoleName()
    GUI.StaticSetText(playerName,roleName)
    GUI.StaticSetText(playerRank,"第" .. TrackUI.BattleResultList.index)
    GUI.StaticSetText(killCount, TrackUI.BattleResultList.killNum .. "名玩家")
    GUI.StaticSetText(battleRank,"第" .. TrackUI.BattleResultList.index)
    GUI.StaticSetText(playerNum,"/" .. TrackUI.BattleResultList.playerNum)

    BattleRoyaleSettlementPageUI.itemList = {}
    local inspect = require("inspect")
    for i = 1, #TrackUI.BattleResultList.ItemTable, 2 do
        table.insert(BattleRoyaleSettlementPageUI.itemList,{name = TrackUI.BattleResultList.ItemTable[i],num = TrackUI.BattleResultList.ItemTable[i+1]})
    end
    local scroll = _gt.GetUI("itemSrc")
    GUI.LoopScrollRectSetTotalCount(scroll, #BattleRoyaleSettlementPageUI.itemList + 1)
    GUI.LoopScrollRectRefreshCells(scroll)
end

function BattleRoyaleSettlementPageUI.CreateItemIcon()
    local itemSrc = _gt.GetUI("itemSrc")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(itemSrc) + 1
    local itemIcon = ItemIcon.Create(itemSrc, "itemIcon" .. curCount, 0, 0,70,70)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "BattleRoyaleSettlementPageUI", "OnItemClick")
    return itemIcon
end

function BattleRoyaleSettlementPageUI.RefreshItemIcon(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local item = GUI.GetByGuid(guid)
    if index > #BattleRoyaleSettlementPageUI.itemList then
        -- GUI.ItemCtrlSetElementValue(item, eItemIconElement.Border, "1800400320")
        -- GUI.ItemCtrlSetElementValue(item, eItemIconElement.Icon, "1900120010")
        ItemIcon.BindItemDB(item,ChickCoinDB)
        GUI.ItemCtrlSetElementRect(item, eItemIconElement.Icon, 0, -1,50,50)
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, TrackUI.BattleResultList.coinNum)
        GUI.SetData(item,"itemName","面板展示-吃鸡代币")
    else
        local itemName = BattleRoyaleSettlementPageUI.itemList[index].name
        local itemNum = BattleRoyaleSettlementPageUI.itemList[index].num
        ItemIcon.BindItemKeyName(item,itemName)
        GUI.ItemCtrlSetElementValue(item, eItemIconElement.RightBottomNum, itemNum)
        GUI.SetData(item,"itemName",itemName)
    end
end

function BattleRoyaleSettlementPageUI.OnItemClick(guid)
    local Back = _gt.GetUI("Back")
    local item = GUI.GetByGuid(guid)
    local itemName = GUI.GetData(item,"itemName")
    if itemName == "面板展示-吃鸡代币" then
        local itemTips = GUI.ItemTipsCreate(Back, "itemTips", 0, 0)
        GUI.SetIsRemoveWhenClick(itemTips, true)
        local itemIcon = GUI.TipsGetItemIcon(itemTips)
        ItemIcon.BindItemDB(itemIcon,ChickCoinDB)
        Tips.SetBaseInfo(itemTips, ChickCoinDB)
        Tips.AddInfoAndTips(itemTips, ChickCoinDB)
        Tips.DeleteItemShowLevel(itemTips)
    else
        Tips.CreateByItemKeyName(itemName,Back,"itemTips",0,0)
    end
end