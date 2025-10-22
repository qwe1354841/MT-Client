MallItem = {}
function MallItem.Create(parent, name)
    local item = GUI.CheckBoxExCreate(parent, name, "1800400360", "1800400361", 0, 0, false, 0, 0)
    local icon = ItemIcon.Create(item, "icon", 55, 1)
    GUI.SetAnchor(icon, UIAnchor.Left)
    GUI.SetPivot(icon,UIAroundPivot.Center)
    GUI.SetIsRaycastTarget(icon, false)
    local name = GUI.CreateStatic(item, "name", "name", 105, -20, 200, 35)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeM)
    UILayout.SetSameAnchorAndPivot(name,UILayout.Left)
    GUI.StaticSetAlignment(name, TextAnchor.MiddleLeft)
    GUI.SetColor(name, UIDefine.BrownColor)
    GUI.StaticSetLabelType(name, LabelType.ConstH)

    local leftUp = GUI.ImageCreate(item, "leftUp", "1801207090", 30, 30)
    GUI.SetPivot(leftUp,UIAroundPivot.Center)
    GUI.SetAnchor(leftUp , UIAnchor.TopLeft)
    local coinBg, coinIcon, price = UILayout.CreateAttrBar(item, "coinBg", 105, 20, 180, UILayout.Left)
    return item
end
---@param guid string
---@param itemInfo Classify_Item
function MallItem.Refresh(guid, itemInfo, moneyType)
    local itemui = GUI.GetByGuid(guid)
    if itemui == nil then
        test("MallItem刷新道具错误")
        return
    end
    local icon = GUI.GetChild(itemui, "icon", false)
    local name = GUI.GetChild(itemui, "name", false)
    -- local nameEx = GUI.GetChild(itemui, "nameEx", false)
    local coinBg = GUI.GetChild(itemui, "coinBg", false)
    local leftUp = GUI.GetChild(itemui, "leftUp", false)
    GUI.SetVisible(leftUp, false)
    -- if nameExStr then
    --     GUI.SetVisible(nameEx, true)
    --     GUI.StaticSetText(nameEx, nameExStr)
    -- else
    --     GUI.SetVisible(nameEx, false)
    -- end
    if itemInfo and itemInfo.info and itemInfo.info.id then
        local tmp = itemInfo.info
        if itemInfo.template_type == 0 then
            ItemIcon.BindItemId(icon, tmp.id)
        elseif itemInfo.template_type == 1 then
            ItemIcon.BindPetId(icon, tmp.id)
			local petDB = DB.GetOncePetByKey1(tmp.id);
			GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Grade])
        end
        --GUI.StaticSetAutoSize(name, true)
        GUI.StaticSetText(name, tmp.name)
        if moneyType then
            UILayout.RefreshAttrBar(coinBg, UIDefine.GetMoneyEnum(moneyType), itemInfo.price * itemInfo.discount / 100)
        else
            UILayout.RefreshAttrBar(coinBg, UIDefine.GetMoneyEnum(1), -0)
        end
        if itemInfo.total_num > 0 or itemInfo.max_num > 0 then
            GUI.SetVisible(leftUp, true)
        else
            GUI.SetVisible(leftUp, false)
        end
		if itemInfo["max_num"] > 0 then		--itemInfo["max_num"]为0代表不限购
			if itemInfo["bought"] >= itemInfo["max_num"] then
				GUI.ItemCtrlSetIconGray(icon, true)			
			else
				GUI.ItemCtrlSetIconGray(icon, false)
			end
		else
			GUI.ItemCtrlSetIconGray(icon, false)
		end
    else
        ItemIcon.BindItemId(icon, 0)
        GUI.StaticSetText(name, " ")
        moneyType = moneyType or 1
        UILayout.RefreshAttrBar(coinBg, UIDefine.GetMoneyEnum(moneyType), -0)
        GUI.SetVisible(leftUp, false)
    end
end
-------------------------------新增原先萌途2版本MallItem接口---------------------------
function MallItem.CreateRightInfo(mallBuyPage)
    local infoBg = GUI.ImageCreate(mallBuyPage, "infoBg", "1800400010", 345, -110, false, 350, 320)
    local itemIcon = ItemIcon.Create(infoBg, "itemIcon", 20, 20)
    UILayout.SetSameAnchorAndPivot(itemIcon, UILayout.TopLeft)

    local name = GUI.CreateStatic(infoBg, "name", "道具名称", 120, 20, 200, 30)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
    GUI.SetColor(name, UIDefine.BrownColor)
    GUI.StaticSetAlignment(name, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)

    local type = GUI.CreateStatic(infoBg, "type", "类型：", 120, 50, 315, 30)
    GUI.StaticSetFontSize(type, UIDefine.FontSizeL)
    GUI.SetColor(type, UIDefine.BrownColor)
    GUI.StaticSetAlignment(type, TextAnchor.MiddleLeft)
    UILayout.SetSameAnchorAndPivot(type, UILayout.TopLeft)

    local level = GUI.CreateStatic(infoBg, "level", "使用等级:", 20, 100, 315, 30)
    GUI.StaticSetFontSize(level, UIDefine.FontSizeL)
    GUI.SetColor(level, UIDefine.BrownColor)
    GUI.StaticSetAlignment(level, TextAnchor.MiddleLeft)
    GUI.SetAnchor(level, UIAnchor.TopLeft)
    GUI.SetPivot(level, UIAroundPivot.TopLeft)

    local descScroll =
        GUI.ScrollRectCreate(
        infoBg,
        "descScroll",
        20,
        200,
        315,
        80,
        0,
        false,
        Vector2.New(300, 220),
        UIAroundPivot.TopLeft,
        UIAnchor.TopLeft,
        1
    )
    GUI.SetAnchor(descScroll, UIAnchor.TopLeft)
    GUI.SetPivot(descScroll, UIAroundPivot.TopLeft)

    local desc = GUI.CreateStatic(descScroll, "desc", "描述", 0, 0, 320, 220)
    GUI.StaticSetFontSize(desc, UIDefine.FontSizeL)
    GUI.SetColor(desc, UIDefine.BrownColor)
    GUI.StaticSetAlignment(desc, TextAnchor.UpperLeft)
    GUI.SetAnchor(desc, UIAnchor.TopLeft)
    GUI.SetPivot(desc, UIAroundPivot.TopLeft)

    local limitNum = GUI.CreateStatic(infoBg, "limitNum", "限购数量：", 20, 140, 315, 30)
    GUI.StaticSetFontSize(limitNum, UIDefine.FontSizeL)
    GUI.SetColor(limitNum, UIDefine.BrownColor)
    GUI.StaticSetAlignment(limitNum, TextAnchor.MiddleLeft)
    GUI.SetAnchor(limitNum, UIAnchor.TopLeft)
    GUI.SetPivot(limitNum, UIAroundPivot.TopLeft)

    local text1 = GUI.CreateStatic(mallBuyPage, "text1", "数量", 205, 90, 100, 30)
    GUI.StaticSetFontSize(text1, UIDefine.FontSizeL)
    GUI.SetColor(text1, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text1, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text1, UIAnchor.Center)
    GUI.SetPivot(text1, UIAroundPivot.Center)

    local text2 = GUI.CreateStatic(mallBuyPage, "text2", "花费", 205, 150, 100, 30)
    GUI.StaticSetFontSize(text2, UIDefine.FontSizeL)
    GUI.SetColor(text2, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text2, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text2, UIAnchor.Center)
    GUI.SetPivot(text2, UIAroundPivot.Center)

    local text3 = GUI.CreateStatic(mallBuyPage, "text3", "拥有", 205, 200, 100, 30)
    GUI.StaticSetFontSize(text3, UIDefine.FontSizeL)
    GUI.SetColor(text3, UIDefine.BrownColor)
    GUI.StaticSetAlignment(text3, TextAnchor.MiddleCenter)
    GUI.SetAnchor(text3, UIAnchor.Center)
    GUI.SetPivot(text3, UIAroundPivot.Center)

    local minusBtn = GUI.ButtonCreate(mallBuyPage, "MinusBtn", "1800402140", 280, 90, Transition.ColorTint, "")
    local plusBtn = GUI.ButtonCreate(mallBuyPage, "PlusBtn", "1800402150", 480, 90, Transition.ColorTint, "")
    local countEdit =
        GUI.EditCreate(
        mallBuyPage,
        "countEdit",
        "1800400390",
        "",
        380,
        90,
        Transition.ColorTint,
        "system",
        0,
        0,
        30,
        8,
        InputType.Standard,
        ContentType.IntegerNumber
    )
    GUI.EditSetFontSize(countEdit, UIDefine.FontSizeM)
    GUI.EditSetTextColor(countEdit, UIDefine.BrownColor)
    GUI.EditSetTextM(countEdit, "1")

    local spendBg = GUI.ImageCreate(mallBuyPage, "spendBg", "1800900040", 380, 152, false, 252, 35)
    local icon = GUI.ImageCreate(spendBg, "icon", "1800408250", -105, -1, false, 35, 35)
    local count = GUI.CreateStatic(spendBg, "count", 666666, 10, -1, 200, 30)
    GUI.StaticSetFontSize(count, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

    local ownBg = GUI.ImageCreate(mallBuyPage, "ownBg", "1800900040", 380, 202, false, 252, 35)
    local icon = GUI.ImageCreate(ownBg, "icon", "1800408250", -105, -1, false, 35, 35)
    local count = GUI.CreateStatic(ownBg, "count", 666666, 10, -1, 200, 30)
    GUI.StaticSetFontSize(count, UIDefine.FontSizeS)
    GUI.StaticSetAlignment(count, TextAnchor.MiddleCenter)

    local buyBtn =
        GUI.ButtonCreate(mallBuyPage, "buyBtn", "1800402080", 425, 260, Transition.ColorTint, "购买", 160, 50, false)
    GUI.SetIsOutLine(buyBtn, true)
    GUI.ButtonSetTextFontSize(buyBtn, UIDefine.FontSizeXL)
    GUI.ButtonSetTextColor(buyBtn, UIDefine.WhiteColor)
    GUI.SetOutLine_Color(buyBtn, UIDefine.OutLine_BrownColor)
    GUI.SetOutLine_Distance(buyBtn, UIDefine.OutLineDistance)
    return infoBg, countEdit, plusBtn, minusBtn, spendBg, ownBg, buyBtn
end

function MallItem.RefreshInfo(infoBg, spendBg, ownBg, countEdit, info, moneyInt, num)
    local itemIcon = GUI.GetChild(infoBg, "itemIcon", false)

    local name = GUI.GetChild(infoBg, "name", false)
    local type = GUI.GetChild(infoBg, "type", false)
    local level = GUI.GetChild(infoBg, "level", false)
    local descScroll = GUI.GetChild(infoBg, "descScroll", false)

    local desc = GUI.GetChild(descScroll, "desc", false)
    local limitNum = GUI.GetChild(infoBg, "limitNum", false)
    local spendicon = GUI.GetChild(spendBg, "icon")
    local spendcount = GUI.GetChild(spendBg, "count")
    local ownicon = GUI.GetChild(ownBg, "icon")
    local owncount = GUI.GetChild(ownBg, "count")
	local petDB = ""
    if info and info.info and info.info.id and info.info.id > 0 then
        if info.template_type == 0 then
            ItemIcon.BindItemId(itemIcon, info.info.id)
        elseif info.template_type == 1 then
            ItemIcon.BindPetId(itemIcon, info.info.id)
			petDB = DB.GetOncePetByKey1(info.info.id)
			GUI.ItemCtrlSetElementValue(itemIcon,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Grade])
        end

		local petPreviewBtn = UILayout.NewGUIDUtilTable().GetUI("petPreviewBtn")
		if petPreviewBtn == nil then
			petPreviewBtn = GUI.ButtonCreate(infoBg,"petPreviewBtn", "1800702060", 130,-120, Transition.ColorTint, "")
			UILayout.NewGUIDUtilTable().BindName(petPreviewBtn, "petPreviewBtn")
			GUI.RegisterUIEvent(petPreviewBtn, UCE.PointerClick, "MallItem", "OnPetPreviewBtn")
		end
		
		if petDB ~= "" then
			--test("==========info.info.keyname:"..petDB.KeyName)
			GUI.SetData(petPreviewBtn, "petName", petDB.KeyName)
		end
		GUI.SetVisible(petPreviewBtn, info.template_type == 1)
		
        GUI.StaticSetText(name, info.info.name)
        GUI.StaticSetText(type, "类型: " .. info.info.showType)
        GUI.StaticSetText(level, "使用等级: " .. info.info:GetUseLv())
        GUI.StaticSetText(desc, "描述: " .. info.info.desc)
        if info.max_num > 0 then
            GUI.StaticSetText(limitNum, "今日限购: " .. info.max_num .. " 今日已购 " .. info.bought)
        elseif info.total_num > 0 then
            local now_total = info.total_num - info.total
			if now_total > 0 then
				GUI.StaticSetText(limitNum, "限量:" .. now_total)
			elseif now_total == 0 then
				GUI.StaticSetText(limitNum, "售罄")
			else
				print("MallItem.RefreshOff err")
			end
        else
            GUI.StaticSetText(limitNum, "不限购")
        end
        if info.discount and info.discount > 0 then
            GUI.StaticSetText(spendcount, info.price * info.discount / 100 * num)
        else
            GUI.StaticSetText(spendcount, info.price * num)
        end
        GUI.StaticSetText(owncount, UIDefine.ExchangeMoneyToStr((CL.GetAttr(UIDefine.GetMoneyEnum(moneyInt)))))
        GUI.ImageSetImageID(spendicon, UIDefine.GetMoneyIcon(moneyInt))
        GUI.ImageSetImageID(ownicon, UIDefine.GetMoneyIcon(moneyInt))
        GUI.EditSetTextM(countEdit, tostring(num))
    else
        ItemIcon.BindItemId(itemIcon, nil)
        GUI.StaticSetText(name, "道具名称")
        GUI.StaticSetText(type, "类型: ")
        GUI.StaticSetText(level, "使用等级:")
        GUI.StaticSetText(desc, "描述: ")
        GUI.StaticSetText(limitNum, "不限购")
        GUI.StaticSetText(spendcount, "0")
        GUI.StaticSetText(owncount, "0")
        GUI.EditSetTextM(countEdit, "0")
    end
    GUI.ScrollRectSetNormalizedPosition(descScroll, UIDefine.Vector2One)
end
function MallItem.CreateOff(parent, name)
    local item = GUI.CheckBoxExCreate(parent, name, "1800400460", "1800400461", 0, 0, false, 0, 0)
    local icon = ItemIcon.Create(item, "icon", 12, 10)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.TopLeft)
    GUI.SetIsRaycastTarget(icon, false)
    local name = GUI.CreateStatic(item, "name", "name", 96, 12, 200, 30)
    GUI.StaticSetFontSize(name, UIDefine.FontSizeL)
    UILayout.SetSameAnchorAndPivot(name, UILayout.TopLeft)
    GUI.StaticSetAlignment(name, TextAnchor.MiddleLeft)
    GUI.SetColor(name, UIDefine.BrownColor)
    -- GUI.StaticSetLabelType(name, LabelType.ConstH)
    local cnt = GUI.CreateStatic(item, "cnt", "cnt", 100, 50, 120, 30)
    GUI.StaticSetFontSize(cnt, UIDefine.FontSizeL)
    UILayout.SetSameAnchorAndPivot(cnt, UILayout.TopLeft)
    GUI.StaticSetAlignment(cnt, TextAnchor.MiddleLeft)
    GUI.SetColor(cnt, UIDefine.Yellow2Color)

    local off = GUI.ImageCreate(item, "off", "1800408350", 0, 0)
    local offcnt = GUI.CreateStatic(off, "offcnt", "offcnt", 10, -10, 100, 30)
    GUI.StaticSetFontSize(offcnt, UIDefine.FontSizeS)
    UILayout.SetSameAnchorAndPivot(offcnt, UILayout.Center)
    GUI.StaticSetAlignment(offcnt, TextAnchor.MiddleCenter)
    GUI.SetColor(offcnt, UIDefine.WhiteColor)
    GUI.SetEulerAngles(offcnt, UIDefine.Vector3Z * -45)
    UILayout.SetSameAnchorAndPivot(off, UILayout.TopRight)
    local bgName = {"offbg", "curbg"}
    local info = {"原价:", "现价:"}
    local y = {95, 131}
    for i = 1, 2 do
        local offbg = GUI.ImageCreate(item, bgName[i], "1800400450", 12, y[i], false, 300, 38)
        UILayout.SetSameAnchorAndPivot(offbg, UILayout.TopLeft)
        local infoUI = GUI.CreateStatic(offbg, "info", info[i], 20, 8, 100, 30)
        UILayout.SetSameAnchorAndPivot(infoUI, UILayout.TopLeft)
        GUI.SetColor(infoUI, UIDefine.BrownColor)
        GUI.StaticSetFontSize(infoUI, UIDefine.FontSizeS)
        GUI.StaticSetAlignment(infoUI, TextAnchor.MiddleLeft)

        local icon = GUI.ImageCreate(offbg, "icon", UIDefine.AttrIcon[RoleAttr.RoleAttrIngot], 86, 2, false, 40, 40)
        UILayout.SetSameAnchorAndPivot(icon, UILayout.TopLeft)
        local numText = GUI.CreateStatic(offbg, "numText", "0", 134, 5, 140, 30)
        UILayout.SetSameAnchorAndPivot(numText, UILayout.TopLeft)
        GUI.SetColor(numText, UIDefine.BrownColor)
        GUI.StaticSetFontSize(numText, UIDefine.FontSizeS)
        GUI.StaticSetAlignment(numText, TextAnchor.MiddleCenter)
        if i == 1 then
            local line = GUI.CreateStatic(offbg, "line", "________", 134, -5, 140, 30)
            UILayout.SetSameAnchorAndPivot(line, UILayout.TopLeft)
            GUI.SetColor(line, UIDefine.BrownColor)
            GUI.StaticSetFontSize(line, UIDefine.FontSizeS)
            GUI.StaticSetAlignment(line, TextAnchor.MiddleCenter)
        end
    end
    local sellout = GUI.ImageCreate(item, "sellout", "1800404070", 0, 0, false, 80, 54)
    UILayout.SetSameAnchorAndPivot(sellout, UILayout.Right)

    return item
end
function MallItem.RefreshOff(guid, itemInfo, moneyType)
    local itemui = GUI.GetByGuid(guid)
    if itemui == nil then
        test("MallItem刷新道具错误")
        return
    end
    local icon = GUI.GetChild(itemui, "icon", false)
    local sellout = GUI.GetChild(itemui, "sellout", false)
    local name = GUI.GetChild(itemui, "name", false)
    local cnt = GUI.GetChild(itemui, "cnt", false)
    local off = GUI.GetChild(itemui, "off", false)
    local offcnt = GUI.GetChild(off, "offcnt", false)
    local offbg = GUI.GetChild(itemui, "offbg", false)
    local curbg = GUI.GetChild(itemui, "curbg", false)
    local offIcon = GUI.GetChild(offbg, "icon", false)
    local curIcon = GUI.GetChild(curbg, "icon", false)
    local offnumText = GUI.GetChild(offbg, "numText", false)
    local curnumText = GUI.GetChild(curbg, "numText", false)

    moneyType = moneyType or 1
    if itemInfo and itemInfo.info and itemInfo.info.id then
        local tmp = itemInfo.info
        if itemInfo.template_type == 0 then
            ItemIcon.BindItemId(icon, tmp.id)
        elseif itemInfo.template_type == 1 then
            ItemIcon.BindPetId(icon, tmp.id)
			local petDB = DB.GetOncePetByKey1(tmp.id);
			GUI.ItemCtrlSetElementValue(icon,eItemIconElement.Border,UIDefine.PetItemIconBg3[petDB.Grade])
        end
        GUI.StaticSetAutoSize(name, true)
        GUI.StaticSetText(name, tmp.name)
        GUI.StaticSetText(offnumText, itemInfo.price)
        GUI.StaticSetText(curnumText, itemInfo.price * itemInfo.discount / 100)
        if itemInfo.total_num > 0 then
            if itemInfo.total_num > 0 and itemInfo.total >= itemInfo.total_num then
                GUI.SetVisible(sellout, true)
            else
                GUI.SetVisible(sellout, false)
            end
			local now_total = itemInfo.total_num - itemInfo.total
			if now_total > 0 then
				GUI.StaticSetText(cnt, "限量:" .. now_total)
			elseif now_total == 0 then
				GUI.StaticSetText(cnt, "售罄")
			else
				print("MallItem.RefreshOff err")
			end
        else
            GUI.SetVisible(sellout, false)
            GUI.StaticSetText(cnt, "限量:")
        end
        if itemInfo.discount > 0 then
            GUI.SetVisible(off, true)
            local discount = itemInfo.discount
            if discount % 10 == 0 then
                discount = discount / 10
            end
            GUI.StaticSetText(offcnt, discount .. "折")
        else
            GUI.StaticSetText(off, false)
        end
    else
        GUI.StaticSetText(cnt, "限量:")
        GUI.SetVisible(off, false)
        ItemIcon.BindItemId(icon, 0)
        GUI.StaticSetText(name, " ")
        GUI.StaticSetText(offnumText, " ")
        GUI.StaticSetText(curnumText, " ")
    end
    GUI.ImageSetImageID(offIcon, UIDefine.GetMoneyIcon(moneyType))
    GUI.ImageSetImageID(curIcon, UIDefine.GetMoneyIcon(moneyType))
end

function MallItem.OnPetPreviewBtn(guid)
    local btn = GUI.GetByGuid(guid)
    local petName = GUI.GetData(btn, "petName")
	if petName then
		GUI.OpenWnd("PetInfoUI","1,"..petName)
	end
end
