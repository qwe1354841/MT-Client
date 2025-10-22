local WelInputInvitationCodeUI = {
    Config = {
        --"10金元",1,"N礼包",1,"还原丹",1,"装备强化石",1
    }
}
_G.WelInputInvitationCodeUI = WelInputInvitationCodeUI
local itemList = {"10金元","N礼包","还原丹","装备强化石"}
local _gt = UILayout.NewGUIDUtilTable()

function WelInputInvitationCodeUI.CreateSubPage(subBg)
    _gt = UILayout.NewGUIDUtilTable()
    _gt.BindName(subBg,"subBg")
    local invitationAwardBg = GUI.ImageCreate(subBg, "invitationAwardBg", "1800608630", 100, 10, false, 830, 560)
    _gt.BindName(invitationAwardBg,"invitationAwardBg")
    UILayout.SetSameAnchorAndPivot(invitationAwardBg, UILayout.Center)
    
    local image = GUI.ImageCreate(invitationAwardBg, "image", "1800608500", -160, 20,false,510,410)
    
    local image2 = GUI.ImageCreate(invitationAwardBg, "image2", "1800604630", 160, -160)

    local itemBg = GUI.ImageCreate(invitationAwardBg, "itemBg", "1801100010", 160, -20, false,390,110)

    local itemSrc =
    GUI.LoopScrollRectCreate(
            itemBg,
            "itemSrc",
            20,
            0,
            360,
            86,
            "WelInputInvitationCodeUI",
            "CreateItemIcon",
            "WelInputInvitationCodeUI",
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
    _gt.BindName(itemSrc,"itemSrc")

    local Input = GUI.EditCreate(invitationAwardBg, "Input","1800001040", "请输入邀请码", 160, 80, Transition.ColorTint, "system", 300, 50, 25, 10)
    GUI.EditSetProp(Input, UIDefine.FontSizeM, 50)
    GUI.EditSetMultiLineEdit(Input, LineType.SingleLine)
    GUI.EditSetTextColor(Input, UIDefine.BrownColor)
    GUI.SetPlaceholderTxtColor(Input, UIDefine.GrayColor)
    _gt.BindName(Input,"Input")

    local confirmBtn = GUI.ButtonCreate(invitationAwardBg, "confirmBtn", "1800402080", 170, 160, Transition.ColorTint, "确认", 160, 47, false)
    --UILayout.SetSameAnchorAndPivot(confirmBtn, UILayout.TopLeft)
    GUI.ButtonSetTextFontSize(confirmBtn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(confirmBtn, UIDefine.WhiteColor);
    GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "WelInputInvitationCodeUI", "OnConfirmBtnClick")

    WelfareUI.SendNotify("invitation_code")
end

function WelInputInvitationCodeUI.CreateItemIcon()
    guid = tostring(guid)
    local src = _gt.GetUI("itemSrc")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(src)
    local item = ItemIcon.Create(src, "" .. curCount, 0, 0)
    GUI.RegisterUIEvent(item, UCE.PointerClick, "WelInputInvitationCodeUI", "OnItemIconClick")
    return item
end

function WelInputInvitationCodeUI.RefreshItemIcon(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1
    local itemIcon = GUI.GetByGuid(guid)
    local itemName = WelInputInvitationCodeUI.Config[index * 2 - 1]
    GUI.SetData(itemIcon,"itemName",itemName)
    if itemName then
        ItemIcon.BindItemKeyName(itemIcon,itemName)
    else
        ItemIcon.BindItemIdWithNum(itemIcon, nil, nil)
    end
end

function WelInputInvitationCodeUI.OnItemIconClick(guid)
    local itemIcon = GUI.GetByGuid(guid)
    local itemName = GUI.GetData(itemIcon,"itemName")
    if itemName then
        Tips.CreateByItemKeyName(itemName, _gt.GetUI("subBg"), "tips", 0, 0)
    end
end

function WelInputInvitationCodeUI.OnConfirmBtnClick()
    local Input = _gt.GetUI("Input")
    local invitationCode = tostring(GUI.EditGetTextM(Input))
    test(invitationCode)
	if invitationCode == "" then
		CL.SendNotify(NOTIFY.ShowBBMsg, "邀请码不能为空哦！")
	else
		WelfareUI.SendNotify("BeInvited_code",invitationCode)
	end
end

function WelInputInvitationCodeUI.RefreshUI()
    local itemCount = #WelInputInvitationCodeUI.Config / 2
    local scroll = _gt.GetUI("itemSrc")
    GUI.LoopScrollRectSetTotalCount(scroll, itemCount)
    GUI.LoopScrollRectRefreshCells(scroll)
end


function WelInputInvitationCodeUI.OnShow(WelfareUIGuidt)
    local wnd = GUI.GetWnd("WelfareUI")
    if wnd == nil then
        return
    end
    local rewardBg = WelfareUIGuidt.GetUI("rewardBg")
    GUI.SetVisible(rewardBg, false)
end

function WelInputInvitationCodeUI.OnExit()
    local wnd = GUI.GetWnd("WelfareUI")
    if wnd == nil then
        return
    end
    local bg = _gt.GetUI("invitationAwardBg")
    GUI.Destroy(bg)
end