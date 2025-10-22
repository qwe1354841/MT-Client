local WelFriendInvitationUI = {
    State_1 = 0,
    State_2 = 0,
    State_3 = 0,
    State_4 = 0,
    State_5 = 0,
    Config = {
        --{"1",itemList = {"猪八戒信物",1,"装备强化石",1},},
        --{"5",itemList = {"猪八戒信物",5,"还原丹",2},},
        --{"10",itemList = {"猪八戒信物",10,"宝石福袋",3},},
        --{"20",itemList = {"猪八戒信物",10,"高级宝石福袋",2,"还原丹",2},},
        --{"50",itemList = {"猪八戒信物",24,"强化保固石",5,"阵法礼包",1},},
    },
    FriendInviteCode = "11111111111", -- 好友邀请码
    InvitationNum = 0, -- 邀请人数
    
}
local _gt = UILayout.NewGUIDUtilTable()
_G.WelFriendInvitationUI = WelFriendInvitationUI

local itemListIndex = {1,2,3,4,5}

function WelFriendInvitationUI.SetFriendInviteCode()
    local str1 = "#INVCODESTART<STR:"
    local str2 = "(点击复制)>#"
    local str = str1 .. tostring(WelFriendInvitationUI.FriendInviteCode) .. str2
    local invitationCode = _gt.GetUI("invitationCode")
    GUI.StaticSetText(invitationCode,str)
end

function WelFriendInvitationUI.CreateSubPage(subBg)
    _gt = UILayout.NewGUIDUtilTable()
    _gt.BindName(subBg,"subBg")
    local titleBg = GUI.ImageCreate(subBg, "titleBg", "1800601060", 103, -209, false, 828, 124)
    local invitationCodeBg = GUI.ImageCreate(titleBg, "invitationCodeBg", "1800601070", 0, 43, false,350,32)
    local invitationCodeTitle = GUI.CreateStatic(invitationCodeBg,"invitationCodeTitle","我的邀请码",20,0,350,32)
    UILayout.SetAnchorAndPivot(invitationCodeTitle, UIAnchor.Center, UIAroundPivot.Center)
    UILayout.StaticSetFontSizeColorAlignment(invitationCodeTitle, UIDefine.FontSizeSS, UIDefine.BrownColor, TextAnchor.LeftCenter)
    
    local invitationCode = GUI.RichEditCreate(invitationCodeTitle,"invitationCode","#INVCODESTART<STR:abcdefghijklm(点击复制)>#",100,0,300,32)
    _gt.BindName(invitationCode,"invitationCode")
    GUI.StaticSetFontSize(invitationCode, UIDefine.FontSizeSS)
    GUI.SetIsRaycastTarget(invitationCodeTitle, true)
    invitationCodeTitle:RegisterEvent(UCE.PointerClick)
    GUI.RegisterUIEvent(invitationCodeTitle, UCE.PointerClick, "WelFriendInvitationUI", "OnInvitationCodeClick")
    GUI.RegisterUIEvent(invitationCode, UCE.PointerClick, "WelFriendInvitationUI", "OnInvitationCodeClick")
    
    local titleText = GUI.ImageCreate(titleBg, "titleText", "1800604510", 0, 0, false)
    local titleLeftImg = GUI.ImageCreate(titleBg, "titleLeftImg", "1800608700", -315, 0, false)
    local titleRightImg = GUI.ImageCreate(titleBg, "titleRightImg", "1800608710", 315, 0, false)
    
    local src =
    GUI.LoopScrollRectCreate(
            subBg,
            "src",
            103,
            77,
            810,
            383,
            "WelFriendInvitationUI",
            "CreateItem",
            "WelFriendInvitationUI",
            "RefreshItem",
            0,
            false,
            Vector2.New(810, 128),
            1,
            UIAroundPivot.Top,
            UIAnchor.Top
    )
    UILayout.SetSameAnchorAndPivot(src, UILayout.Center)
    GUI.ScrollRectSetChildSpacing(src, Vector2.New(0, 8))
    _gt.BindName(src, "src")
    --WelFriendInvitationUI.RefreshUI()
    WelfareUI.SendNotify("GetFriendInvitationData")
end

function WelFriendInvitationUI.OnInvitationCodeClick(guid)
    --点击富文本
    local str = "在福利界面输入我的邀请码：#ICOD，即可获得专属奖励！"
    TOOLKIT.CopyTextToClipboard(str)
    CL.SendNotify(NOTIFY.ShowBBMsg, "您已经复制成功了！")
end

function WelFriendInvitationUI.CreateItem()
    local src = _gt.GetUI("src")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(src) + 1
    local item = GUI.ImageCreate(src, "item" .. curCount, "1801100010", 0, 0, false)
    GUI.SetIsRaycastTarget(item, true)
    local invitationText = GUI.CreateStatic(item, "invitationText", "邀请好友可领取", 47, -20, 150, 35)
    GUI.SetColor(invitationText, UIDefine.BrownColor)
    GUI.StaticSetFontSize(invitationText, UIDefine.FontSizeS)
    UILayout.SetSameAnchorAndPivot(invitationText, UILayout.Left)
    GUI.StaticSetAlignment(invitationText, TextAnchor.MiddleLeft)
    local invitationNumBg = GUI.ImageCreate(item,"invitationNumBg", "1800600500",47, 20 ,false, 140,35)
    UILayout.SetSameAnchorAndPivot(invitationNumBg, UILayout.Left)
    local invitationNum = GUI.CreateStatic(invitationNumBg, "invitationNum", "(0/1)", 0, 0, 140, 35)
    GUI.SetColor(invitationNum, UIDefine.BrownColor)
    GUI.StaticSetFontSize(invitationNum, UIDefine.FontSizeM)
    UILayout.SetSameAnchorAndPivot(invitationNum, UILayout.Left)
    GUI.StaticSetAlignment(invitationNum, TextAnchor.MiddleCenter)
    local getBtn =
    GUI.ButtonCreate(item, "getBtn", "1800402110", -20, 0, Transition.ColorTint, "领取", 120, 45, false)
    GUI.RegisterUIEvent(getBtn, UCE.PointerClick, "WelFriendInvitationUI", "OnGetClick")
    UILayout.SetSameAnchorAndPivot(getBtn, UILayout.Right)
    GUI.ButtonSetTextFontSize(getBtn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(getBtn, UIDefine.BrownColor)
    local itemSrc =
    GUI.LoopScrollRectCreate(
            item,
            "itemSrc",
            203,
            0,
            450,
            86,
            "WelFriendInvitationUI",
            "CreateItemIcon",
            "WelFriendInvitationUI",
            "RefreshItemIcon",
            0,
            true,
            Vector2.New(86, 86),
            1,
            UIAroundPivot.Left,
            UIAnchor.Left
    )
    UILayout.SetSameAnchorAndPivot(itemSrc, UILayout.Left)
    GUI.ScrollRectSetChildSpacing(itemSrc, Vector2.New(3, 0))
    GUI.SetLinkScrollRect(itemSrc, src)
    return item
end

function WelFriendInvitationUI.RefreshItem(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = itemListIndex[tonumber(parameter[2]) + 1]
    local item = GUI.GetByGuid(guid)
    GUI.SetData(item,"index",index)
    --test(index)
    local itemSrc = GUI.GetChild(item,"itemSrc",false)
    
    local invitationNum = tonumber(WelFriendInvitationUI.InvitationNum)
    local limitNum = tonumber(WelFriendInvitationUI.Config[index][1])
    local numBg = GUI.GetChild(item,"invitationNumBg",false)
    local num = GUI.GetChild(numBg,"invitationNum",false)
    GUI.StaticSetText(num,"(" .. invitationNum .. "/".. limitNum ..")")
    
    local isGet = tonumber(WelFriendInvitationUI["State_" .. index]) == 1
    local isReach = invitationNum >= limitNum
    --local isReach = true
    local getBtn = GUI.GetChild(item,"getBtn",false)
    if isGet then
        GUI.ButtonSetText(getBtn,"已领取")
        GUI.ButtonSetShowDisable(getBtn,false)
    elseif isReach then
        GUI.ButtonSetText(getBtn,"领取")
        GUI.ButtonSetShowDisable(getBtn,true)
    else
        GUI.ButtonSetText(getBtn,"未达成")
        GUI.ButtonSetShowDisable(getBtn,false)
    end
    
    GUI.LoopScrollRectSetTotalCount(itemSrc, #WelFriendInvitationUI.Config)
    GUI.LoopScrollRectRefreshCells(itemSrc)
end

function WelFriendInvitationUI.CreateItemIcon(guid)
    guid = tostring(guid)
    local src = GUI.GetByGuid(guid)
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(src)
    local item = ItemIcon.Create(src, "" .. curCount, 0, 0)
    GUI.SetData(item, "pguid", guid)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "WelFriendInvitationUI", "OnItemIconClick")
    return item
end

function WelFriendInvitationUI.RefreshItemIcon(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemIcon = GUI.GetByGuid(guid)
    local pguid = GUI.GetData(itemIcon,"pguid")
    local pitem = GUI.GetParentElement(GUI.GetByGuid(pguid))
    local pindex = tonumber(GUI.GetData(pitem,"index"))
    --test("pindex" .. pindex)
    local data = WelFriendInvitationUI.Config[pindex]
    local itemName = data.itemList[index * 2 - 1]
    local itemCount = data.itemList[index * 2]
    GUI.SetData(itemIcon,"itemName",itemName)
    if itemName then
        ItemIcon.BindItemKeyName(itemIcon,itemName)
        GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.RightBottomNum, itemCount)
        --图标的大小  如果太大就缩小
        GUI.ItemCtrlSetElementRect(itemIcon, eItemIconElement.Icon, 0, -1,75,75);
    else
        ItemIcon.BindItemIdWithNum(itemIcon, nil, nil)
    end
end

function WelFriendInvitationUI.OnItemIconClick(guid)
    local item = GUI.GetByGuid(guid)
    local itemName = GUI.GetData(item,"itemName")
    if itemName then
        Tips.CreateByItemKeyName(itemName, _gt.GetUI("subBg"), "tips", 0, 0)
    end
end

function WelFriendInvitationUI.OnGetClick(guid)
    local btn = GUI.GetByGuid(guid)
    local pitem = GUI.GetParentElement(btn)
    local pindex = tonumber(GUI.GetData(pitem,"index"))
    --FormWelfare.ReceiveFriendInvitationReward(player,index)
    WelfareUI.SendNotify("ReceiveFriendInvitationReward" , pindex)
    --test(pindex)
end


function WelFriendInvitationUI.RefreshItemListIndex()
    local isGetItemListIndex = {}
    itemListIndex = {}
    if #WelFriendInvitationUI.Config > 0 then
        for i = 1 , #WelFriendInvitationUI.Config do
            local isGet = tonumber(WelFriendInvitationUI["State_" .. i]) == 1
            if isGet then
                table.insert(isGetItemListIndex,i)
            else
                table.insert(itemListIndex,i)
            end
        end
        if #isGetItemListIndex > 0 then
            for i = 1 , #isGetItemListIndex do
                table.insert(itemListIndex,isGetItemListIndex[i])
            end
        end
    end
end

function WelFriendInvitationUI.RefreshUI()
    WelFriendInvitationUI.RefreshItemListIndex()
    test(#WelFriendInvitationUI.Config)
    local scroll = _gt.GetUI("src")
    GUI.LoopScrollRectSetTotalCount(scroll, #WelFriendInvitationUI.Config)
    GUI.LoopScrollRectRefreshCells(scroll)
    -- 设置邀请码
    WelFriendInvitationUI.SetFriendInviteCode()
    -- require("EndlessTrialsUI")
    -- test(EndlessTrialsUI.serialize(WelFriendInvitationUI))
end

function WelFriendInvitationUI.OnShow(WelfareUIGuidt)
    local wnd = GUI.GetWnd("WelfareUI")
    if wnd == nil then
        return
    end
    local rewardBg = WelfareUIGuidt.GetUI("rewardBg")
    GUI.SetVisible(rewardBg, true)
    GUI.SetPositionX(rewardBg, 285)
    GUI.SetPositionY(rewardBg, 194)
    GUI.SetWidth(rewardBg, 838)
    GUI.SetHeight(rewardBg, 415)
end



function WelFriendInvitationUI.OnExchangeBtnClick()
end