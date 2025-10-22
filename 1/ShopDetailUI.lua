ShopDetailUI={}
local _gt = nil
ShopDetailUI.itemMaxNum = 0
ShopDetailUI.numNodify = nil
function ShopDetailUI.ShowDetailInfo(infoTable, parent, typeIndex, _gt0)
    _gt = _gt0
    --初始化状态
    ShopDetailUI.CreateBaseInfoNode(parent)
    ShopDetailUI.ResetDetailArea()

    if infoTable == nil then return end

    --设置基础信息
    ShopDetailUI.SetBaseInfo(infoTable.name, infoTable.grade, infoTable.type, infoTable.level, infoTable.img, infoTable.bind)
    ShopDetailUI.itemMaxNum = infoTable.maxNum

    --设置滚动区域属性信息
    local scrollInfo = _gt.GetUI("detailScrollInfo")
    local item = _gt.GetUI("detailItem")
    local group = _gt.GetUI("detailGroup")
    local basePosY = 93
    local posY = 0
    local ScrollHeight = 282

    --可变基本属性
    if infoTable.job ~= nil then basePosY = basePosY + ShopDetailUI.AddSchool(item, basePosY, infoTable.job) end
    if infoTable.sex ~= nil and infoTable.sex ~= ""  then basePosY = basePosY + ShopDetailUI.AddGender(item, basePosY, infoTable.sex) end
    basePosY = basePosY + ShopDetailUI.SetItemLinePositionY(item, basePosY)

    --样式一(购买页)：滚动属性
    if typeIndex==1 then
        if infoTable.equipTurnBorn ~= 0 or infoTable.equipLevel ~= 0 or infoTable.role ~= 0 or ShopDetailUI.IsEmpptyStrTable(infoTable.attsRequire)==false then posY = posY + ShopDetailUI.AddEquipLimit(group, posY, infoTable.equipTurnBorn, infoTable.equipLevel, infoTable.role, infoTable.attsRequire ) end
        if #infoTable.atts > 0 then posY = posY + ShopDetailUI.AddBasicInfo(group, posY, infoTable.atts ) end
        if infoTable.func ~= nil then posY = posY + ShopDetailUI.AddFunction(group, posY, infoTable.func) end
        if infoTable.itemType == 1 then posY = posY + ShopDetailUI.AddBuyNum(group, posY, "限购数量：无限制") end
        posY = posY + ShopDetailUI.AddDesc(group, posY, infoTable.desc)

    --样式二(出售页)：滚动属性
    elseif typeIndex==2 then
        ScrollHeight = 350-- 405
        -- if infoTable.equipTurnBorn ~= 0 or infoTable.equipLevel ~= 0 or infoTable.role ~= 0 or ShopDetailUI.IsEmpptyStrTable(infoTable.attsRequire)==false then posY = posY + ShopDetailUI.AddEquipLimit(group, posY, infoTable.equipTurnBorn, infoTable.equipLevel, infoTable.role, infoTable.attsRequire ) end
        -- if #infoTable.atts > 0 then posY = posY + ShopDetailUI.AddBasicInfo(group, posY, infoTable.atts ) end
        -- posY = posY + ShopDetailUI.AddPrice(group, posY, infoTable.sellPrice)
        -- posY = posY + ShopDetailUI.AddDesc(group, posY, infoTable.desc)
        ----[[
        posY = posY + ShopDetailUI.AddPrice(group, posY, infoTable.sellPrice)
        if infoTable.atts and #infoTable.atts > 0 then 
            posY = posY + ShopDetailUI.AddBasicInfo(group, posY, infoTable.atts ) 
        end
        if infoTable.intensifyInfo and #infoTable.intensifyInfo > 0 then
            posY = posY + ShopDetailUI.AddIntensifyInfo(group, posY, infoTable.intensifyInfo )--强化信息
        end
        if infoTable.gemInfo and #infoTable.gemInfo > 0 then
            posY = posY + ShopDetailUI.AddGemInfo(group, posY, infoTable.gemInfo )--宝石信息
        end
        if infoTable.suitInfo and #infoTable.suitInfo > 0 then
            posY = posY + ShopDetailUI.AddSuitInfo(group, posY, infoTable.suitInfo )--套装信息
        end
        if infoTable.func ~= nil then posY = posY + ShopDetailUI.AddFunction(group, posY, infoTable.func) end
        --if infoTable.func ~= nil then posY = posY + ShopDetailUI.AddDurability(group, posY, infoTable.func) end
        posY = posY + ShopDetailUI.AddDesc(group, posY, infoTable.desc)
        --]]


    --样式三(赎回页)：滚动属性
    else
        --[[
        if infoTable.equipTurnBorn ~= 0 or infoTable.equipLevel ~= 0 or infoTable.role ~= 0 or ShopDetailUI.IsEmpptyStrTable(infoTable.attsRequire)==false then 
            posY = posY + ShopDetailUI.AddEquipLimit(group, posY, infoTable.equipTurnBorn, infoTable.equipLevel, infoTable.role, infoTable.attsRequire ) 
        end
        ]]
        if infoTable.atts and #infoTable.atts > 0 then 
            posY = posY + ShopDetailUI.AddBasicInfo(group, posY, infoTable.atts ) 
        end
        if infoTable.intensifyInfo and #infoTable.intensifyInfo > 0 then
            posY = posY + ShopDetailUI.AddIntensifyInfo(group, posY, infoTable.intensifyInfo )--强化信息
        end
        if infoTable.gemInfo and #infoTable.gemInfo > 0 then
            posY = posY + ShopDetailUI.AddGemInfo(group, posY, infoTable.gemInfo )--宝石信息
        end
        if infoTable.suitInfo and #infoTable.suitInfo > 0 then
            posY = posY + ShopDetailUI.AddSuitInfo(group, posY, infoTable.suitInfo )--套装信息
        end
        if infoTable.func ~= nil then posY = posY + ShopDetailUI.AddFunction(group, posY, infoTable.func) end
        --if infoTable.func ~= nil then posY = posY + ShopDetailUI.AddDurability(group, posY, infoTable.func) end
        posY = posY + ShopDetailUI.AddDesc(group, posY, infoTable.desc)
    end

    GUI.SetPositionY(scrollInfo, basePosY+84)
    local SizeY = ScrollHeight - basePosY
    if SizeY < 10 then SizeY = 10 end
    GUI.SetHeight(scrollInfo, SizeY)
    GUI.SetHeight(group, posY)
    GUI.ScrollRectSetChildSize(scrollInfo, Vector2.New(315, posY))
end

--是否全部为空
function ShopDetailUI.IsEmpptyStrTable(strs)
    if strs ~= nil then
        local count = #strs
        for i = 1, count do
            if strs[i] ~= nil and strs[i] ~= "" then
                return false
            end
        end
    end
    return true
end

function ShopDetailUI.PackPetBaseInfo(petName)
    local attrTables = {}
    local config = DB.GetOncePetByKey2(petName)
    if config ~= nil then
        attrTables.name = config.Name
        attrTables.itemType = config.Type
        attrTables.type = UIDefine.PetTypeTxt[config.Type]
        attrTables.level = 1
        attrTables.img = tostring(config.Head)
        attrTables.grade = config.Type
        attrTables.sellPrice = 0
        attrTables.desc = config.Info
        attrTables.buyPrice = 0
        --attrTables.func = config.Info
        attrTables.atts = {}
        attrTables.equipTurnBorn = 0
        attrTables.equipLevel = 0
        attrTables.role = 0

        attrTables.job = nil
        attrTables.sex = ""
    end
    return attrTables
end

function ShopDetailUI.PackItemBaseInfo(itemID)
    local attrTables = {}
    local itemConfig = DB.GetOnceItemByKey1(itemID)
    if itemConfig ~= nil then
        attrTables.name = itemConfig.Name
        attrTables.itemType = itemConfig.Type
        attrTables.type = itemConfig.ShowType
        attrTables.level = itemConfig.Level
        attrTables.img = itemConfig.Icon
        attrTables.grade = itemConfig.Grade
        attrTables.sellPrice = itemConfig.SaleGoldBind
        attrTables.desc = itemConfig.Tips
        attrTables.buyPrice = itemConfig.BuyGoldBind
        attrTables.func = itemConfig.Info
        attrTables.atts = {}--基础属性、特效特技
        attrTables.intensifyInfo ={} --强化属性
        attrTables.gemInfo={}--宝石属性
        attrTables.suitInfo={}--套装属性
        attrTables.equipTurnBorn = 0
        attrTables.equipLevel = 0
        attrTables.role = 0

        attrTables.job = nil
        if itemConfig.Job~=0 then
            local schoolConfig = DB.GetSchool(itemConfig.Job)
            if schoolConfig ~= nil then
                attrTables.job = schoolConfig.Name
            end
        end
        attrTables.sex = UIDefine.GetSexName(itemConfig.Sex)
    end
    return attrTables
end

function ShopDetailUI.PackShopPetInfos(petName)
    local attrTables = ShopDetailUI.PackPetBaseInfo(petName)
    return attrTables
end

function ShopDetailUI.PackShopItemInfos(itemID, bind)
    local attrTables = ShopDetailUI.PackItemBaseInfo(itemID)
    local itemConfig = DB.GetOnceItemByKey1(itemID)
    if itemConfig ~= nil then
        local itemType = itemConfig.Type
        attrTables.bind = bind
        --装备分类
        if itemType == 1 then
            attrTables.func = nil
            attrTables.equipTurnBorn = itemConfig.TurnBorn
            attrTables.equipLevel = itemConfig.Level
			if itemConfig.Role2 ~= 0 then
				attrTables.role = tostring(itemConfig.Role)..","..tostring(itemConfig.Role2)
			else
				attrTables.role = itemConfig.Role
			end
            --属性表
            local itemAttrConfig = DB.GetOnceItem_AttByKey1(itemID)
            if itemAttrConfig ~= nil then
                --装备属性值
                local count = 0
                local ItemAttConfigAtts = {itemAttrConfig.Att1,itemAttrConfig.Att2,itemAttrConfig.Att3,itemAttrConfig.Att4,itemAttrConfig.Att5}
                local ItemAttConfigAttsMin = {itemAttrConfig.Att1Min,itemAttrConfig.Att2Min,itemAttrConfig.Att3Min,itemAttrConfig.Att4Min,itemAttrConfig.Att5Min}
                local ItemAttConfigAttsMax = {itemAttrConfig.Att1Max,itemAttrConfig.Att2Max,itemAttrConfig.Att3Max,itemAttrConfig.Att4Max,itemAttrConfig.Att5Max}
                for i = 1, 5 do
                    if ItemAttConfigAtts[i] ~= 0 then
                        local AttrConfig = DB.GetOnceAttrByKey1(ItemAttConfigAtts[i])
                        if AttrConfig ~= nil then
                            count = count + 1
                            local attDesc = AttrConfig.ChinaName.."  "
                            if AttrConfig.IsPct == 1 then
                                attDesc = attDesc..(ItemAttConfigAttsMin[i]/100).."%~"..(ItemAttConfigAttsMax[i]/100).."%"
                            else
                                attDesc = attDesc..ItemAttConfigAttsMin[i].."~"..ItemAttConfigAttsMax[i]
                            end

                            attrTables.atts[count] = attDesc
                        end
                    end
                end
                --穿戴要求属性达到的值
                attrTables.attsRequire = {"","","",""}
                local EquipNeedAtts = {itemAttrConfig.StrRequire, itemAttrConfig.IntRequire, itemAttrConfig.VitRequire, itemAttrConfig.AgiRequire}
                local SelfAtts = {RoleAttr.RoleAttrStr, RoleAttr.RoleAttrInt, RoleAttr.RoleAttrVit, RoleAttr.RoleAttrAgi}
                local EquipNeedName = {"力量需求","灵性需求", "根骨需求","敏捷需求"}
                for i = 1, 4 do
                    if EquipNeedAtts[i] ~= 0 then
                        local selfVal = CL.GetIntAttr(SelfAtts[i])
                        local bMatch = selfVal >= EquipNeedAtts[i] and true or false
                        attrTables.attsRequire[i] = bMatch and EquipNeedName[i].."  "..EquipNeedAtts[i] or "<color=red>"..EquipNeedName[i].."  "..EquipNeedAtts[i].."</color>"
                    end
                end
            end
        end
    end

    return attrTables
end

function ShopDetailUI.SetBaseInfo(name, grade, type, level, img, bind)
    local icon = _gt.GetUI("detailicon")
    if icon ~= nil then
        GUI.ImageSetImageID(icon, img)
    end
    local item = _gt.GetUI("detailItem")
    if item ~= nil then
        GUI.ItemCtrlSetElementValue(item,eItemIconElement.Border, UIDefine.ItemIconBg[grade]);
        GUI.SetVisible(item, true)
    end

    local nameL = _gt.GetUI("detailname")
    if nameL ~= nil then
        GUI.StaticSetText(nameL, name)
    end
    local typeVal = _gt.GetUI("detailtypeVal")
    if typeVal ~= nil then
        GUI.StaticSetText(typeVal, type)
    end
    local levelVal = _gt.GetUI("detaillevelVal")
    if levelVal ~= nil then
        GUI.StaticSetText(levelVal, level)
    end
    local detailBindFlag = _gt.GetUI("detailBindFlag")
    if detailBindFlag ~= nil then
        GUI.SetVisible(detailBindFlag, bind)
    end
end

function ShopDetailUI.ResetDetailArea()
    local item = _gt.GetUI("detailItem")
    if item ~= nil then
        GUI.SetVisible(item, false)
    end
    local school = _gt.GetUI("school")
    if school ~= nil then
        GUI.SetVisible(school, false)
    end
    local gender = _gt.GetUI("gender")
    if gender ~= nil then
        GUI.SetVisible(gender, false)
    end
    local limit = _gt.GetUI("limit")
    if limit ~= nil then
        GUI.SetVisible(limit, false)
    end
    local equipLimit = _gt.GetUI("equipLimit")
    if equipLimit ~= nil then
        GUI.SetVisible(equipLimit, false)
    end
    local basic = _gt.GetUI("basic")
    if basic ~= nil then
        GUI.SetVisible(basic, false)
    end
    local intensify = _gt.GetUI("intensify")
    if intensify ~= nil then
        GUI.SetVisible(intensify, false)
    end
    local gem = _gt.GetUI("gem")
    if gem ~= nil then
        GUI.SetVisible(gem, false)
    end
    local suit = _gt.GetUI("suit")
    if suit ~= nil then
        GUI.SetVisible(suit, false)
    end
    local durability = _gt.GetUI("durability")
    if durability ~= nil then
        GUI.SetVisible(durability, false)
    end
    local price = _gt.GetUI("price")
    if price ~= nil then
        GUI.SetVisible(price, false)
    end
    local desc = _gt.GetUI("desc")
    if desc ~= nil then
        GUI.SetVisible(desc, false)
    end
    local func = _gt.GetUI("func")
    if func ~= nil then
        GUI.SetVisible(func, false)
    end
    local buyNum = _gt.GetUI("buyNum")
    if buyNum ~= nil then
        GUI.SetVisible(buyNum, false)
    end
    local spendCount = _gt.GetUI("spendCount")
    if spendCount then
        GUI.StaticSetText(spendCount,"0")
    end
    local SellNumNode = _gt.GetUI("SellNumNode")
    if SellNumNode ~= nil then
        GUI.SetVisible(SellNumNode, false)
    end
end

function ShopDetailUI.CreateBaseInfoNode(parent)
    local detailNode = _gt.GetUI("detailNode")
    if detailNode == nil then
        detailNode = GUI.GroupCreate(parent,"detailNode", 0, 0, 0, 0)
        _gt.BindName(detailNode, "detailNode")
    	UILayout.SetSameAnchorAndPivot(detailNode, UILayout.TopLeft)

        --顶部统一物品栏
        local item = GUI.ItemCtrlCreate(detailNode,"detailItem", "1800400050", 793, 80)
        _gt.BindName(item, "detailItem")
        --物品图标背景\图标\绑定标记
        local pic = GUI.ImageCreate( item,"detailpic", "1800400060", 0, 0, false, 80, 80)
        local icon = GUI.ImageCreate( item,"detailicon", "1900107020", 6, 6, false, 68, 68)
        _gt.BindName(icon, "detailicon")
        local bindFlag = GUI.ImageCreate( item,"detailBindFlag", "1800707120", 2, 0)
        _gt.BindName(bindFlag, "detailBindFlag")
        GUI.SetAnchor(bindFlag, UIAnchor.TopLeft)

        local name = GUI.CreateStatic(item,"detailname", "50级烈云", 95, 0, 225, 30)
        _gt.BindName(name, "detailname")
        UILayout.StaticSetFontSizeColorAlignment(name, UIDefine.FontSizeL, UIDefine.BrownColor, nil)

        local type = GUI.CreateStatic(item,"detailtype", "类型：", 95, 31, 100, 30)
        _gt.BindName(type, "detailtype")
        UILayout.StaticSetFontSizeColorAlignment(type, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local typeVal = GUI.CreateStatic(type,"detailtypeVal", "无级别", 66, 0, 150, 30)
        _gt.BindName(typeVal, "detailtypeVal")
        UILayout.StaticSetFontSizeColorAlignment(typeVal, UIDefine.FontSizeL, UIDefine.Yellow2Color, nil)

        local level = GUI.CreateStatic(item,"detaillevel", "等级：", 95, 62, 100, 30)
        _gt.BindName(level, "detaillevel")
        UILayout.StaticSetFontSizeColorAlignment(level, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        local levelVal = GUI.CreateStatic(level,"detaillevelVal", "0", 66, 0, 100, 30)
        _gt.BindName(levelVal, "detaillevelVal")
        UILayout.StaticSetFontSizeColorAlignment(levelVal, UIDefine.FontSizeL, UIDefine.Yellow2Color, nil)

        --滚动区大小 192与315
        local scrollInfo = GUI.ScrollRectCreate( detailNode, "detailScrollInfo", 793, 248, 315, 315, 0, false, Vector2.New(315,350), UIAroundPivot.Top, UIAnchor.Top)
        _gt.BindName(scrollInfo, "detailScrollInfo")
        local group = GUI.GroupCreate(scrollInfo, "detailGroup", 0, 0, 315, 1)
        _gt.BindName(group, "detailGroup")

        local numNode = GUI.CreateStatic(detailNode,"numNode", "数量", 812, 462, 100, 30)
        _gt.BindName(numNode, "SellNumNode")
        UILayout.StaticSetFontSizeColorAlignment(numNode, UIDefine.FontSizeL, UIDefine.BrownColor, TextAnchor.MiddleCenter)
        UILayout.SetSameAnchorAndPivot(numNode, UILayout.Center)
        GUI.SetVisible(numNode, false)

        local minusBtn = GUI.ButtonCreate(numNode,"SellMinusBtn", "1800402140", 65,0, Transition.ColorTint, "")
        _gt.BindName(minusBtn, "SellMinusBtn")
        local plusBtn = GUI.ButtonCreate(numNode,"SellPlusBtn", "1800402150", 265, 0, Transition.ColorTint, "")
        _gt.BindName(plusBtn, "SellPlusBtn")
        local countEdit = GUI.EditCreate(numNode,"SellCountEdit", "1800400390", "", 165, 0, Transition.ColorTint, "system", 0, 0, 30, 8, InputType.Standard, ContentType.IntegerNumber)
        _gt.BindName(countEdit, "SellCountEdit")
        GUI.EditSetFontSize(countEdit, UIDefine.FontSizeM)
        GUI.EditSetTextColor(countEdit, UIDefine.BrownColor)
        GUI.EditSetTextM(countEdit, "1")
        GUI.RegisterUIEvent(countEdit, UCE.EndEdit, "ShopDetailUI", "OnSellCountModify")
        GUI.RegisterUIEvent(plusBtn, UCE.PointerClick, "ShopDetailUI", "OnSellPlusBtnClick")
        GUI.RegisterUIEvent(minusBtn, UCE.PointerClick, "ShopDetailUI", "OnSellMinusBtnClick")

        local extNode = GUI.GroupCreate(detailNode,"extNode", 208, 148, 0, 0)
        _gt.BindName(extNode, "detailExtNode")
        UILayout.SetSameAnchorAndPivot(extNode, UILayout.Center)
    end
end

function ShopDetailUI.OnSellCountModify(guid)
    local SellCountEdit = _gt.GetUI("SellCountEdit")
    if SellCountEdit then
        local count = tonumber(GUI.EditGetTextM(SellCountEdit))
        ShopDetailUI.OnChangeItemNum(count)
    end
end

function ShopDetailUI.OnSellPlusBtnClick(guid)
    -- local SellCountEdit = _gt.GetUI("SellCountEdit")
    -- if SellCountEdit then
    --     local count = tonumber(GUI.EditGetTextM(SellCountEdit)) + 1
    --     ShopDetailUI.OnChangeItemNum(count)
    -- end
    ShopUI.OnSellItemClick(ShopUI.PressedItemGuid)
end

function ShopDetailUI.OnSellMinusBtnClick(guid)
    -- local SellCountEdit = _gt.GetUI("SellCountEdit")
    -- if SellCountEdit then
    --     local count = tonumber(GUI.EditGetTextM(SellCountEdit)) - 1
    --     ShopDetailUI.OnChangeItemNum(count)
    -- end
    --local ItemIconBg = GUI.GetByGuid(ShopUI.PressedItemGuid)
    --local btn = GUI.GetChild(ItemIconBg, "decreaseBtn")
    --local guid = GUI.GetGuid(btn)
    ShopUI.OnClickMinusBtn(ShopUI.PressedItemGuid)
end

function ShopDetailUI.OnChangeItemNum(count)
    if count == nil then
        count = 0
    end
    local SellCountEdit = _gt.GetUI("SellCountEdit")
    if SellCountEdit then
        count = math.max(1, count)
        count = math.min(ShopDetailUI.itemMaxNum, count)
        GUI.EditSetTextM(SellCountEdit, tostring(count))
        if ShopDetailUI.numNodify ~= nil then
            ShopDetailUI.numNodify(count)
        end
    end
end

function ShopDetailUI.AddSchool(parent, posY, schoolInfo)
    local school = _gt.GetUI("school")
    local schoolVal = _gt.GetUI("schoolVal")
    if school == nil or schoolVal == nil then
        school = GUI.CreateStatic(parent,"school", "门派：", 95, posY, 100, 30)
        _gt.BindName(school, "school")
        UILayout.StaticSetFontSizeColorAlignment(school, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        schoolVal = GUI.CreateStatic(school,"schoolVal", "无限制", 66, 0, 150, 30)
        _gt.BindName(schoolVal, "schoolVal")
        UILayout.StaticSetFontSizeColorAlignment(schoolVal, UIDefine.FontSizeL, UIDefine.Yellow2Color, nil)
    end
    GUI.SetVisible(school, true)
    GUI.SetPositionY(school, posY)

    if schoolVal ~= nil then
        GUI.StaticSetText(schoolVal, schoolInfo)
    end
    return 31
end

function ShopDetailUI.AddGender(parent, posY, genderInfo)
    local gender = _gt.GetUI("gender")
    local genderVal = _gt.GetUI("genderVal")
    if gender == nil or genderVal == nil then
        gender = GUI.CreateStatic(parent,"gender", "性别：", 95, posY, 100, 30)
        _gt.BindName(gender, "gender")
        UILayout.StaticSetFontSizeColorAlignment(gender, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        genderVal = GUI.CreateStatic(gender,"genderVal", "女", 66, 0, 150, 30)
        _gt.BindName(genderVal, "genderVal")
        UILayout.StaticSetFontSizeColorAlignment(genderVal, UIDefine.FontSizeL, UIDefine.Yellow2Color, nil)
    end
    GUI.SetVisible(gender, true)
    GUI.SetPositionY(gender, posY)

    if genderVal ~= nil then
        GUI.StaticSetText(genderVal, genderInfo)
    end
    return 31
end

function ShopDetailUI.AddLimit(parent, posY, limitInfo)
    local limit = _gt.GetUI("limit")
    if limit == nil then
        limit = GUI.CreateStatic(parent,"limit", "穿着限制：嫡剑仙 阎魔令", 5, posY, 400, 30)
        _gt.BindName(limit, "limit")
        UILayout.StaticSetFontSizeColorAlignment(limit, UIDefine.FontSizeL, UIDefine.RedColor, nil)
    end
    GUI.SetVisible(limit, true)
    GUI.SetPositionY(limit, posY)

    GUI.StaticSetText(limit, limitInfo)
    return 31
end

function ShopDetailUI.SetItemLinePositionY(parent, posY)
    local line = _gt.GetUI("detailLine")
    if line == nil then
        line = GUI.ImageCreate(parent,"detailLine", "1800600030", 0, posY)
        _gt.BindName(line, "detailLine")
    else
        GUI.SetPositionY(line, posY)
    end

    return 6
end

function ShopDetailUI.AddEquipLimit(parent, posY, TurnBorn, Level, Role, attsRequire)
    local equipLimit = _gt.GetUI("equipLimit")
    if equipLimit == nil then
        --穿戴限制
        equipLimit = GUI.ImageCreate(parent, "equipLimit", "1801100040", 5, posY)
        _gt.BindName(equipLimit, "equipLimit")
        local title = GUI.CreateStatic(equipLimit,"title", "穿戴需求", 0, 0, 200, 30)
        UILayout.StaticSetFontSizeColorAlignment(title, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        for i = 0, 5 do
            local basicVal = GUI.CreateStatic(equipLimit,"val"..i, "穿戴等级：100", 48, (33*(i+1)), 300, 30, "system", true)
            _gt.BindName(basicVal, "val"..i)
            UILayout.StaticSetFontSizeColorAlignment(basicVal, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        end
        GUI.ImageCreate(equipLimit,"line", "1800600030", 0, 104)
    end
    GUI.SetVisible(equipLimit, true)
    GUI.SetPositionY(equipLimit, posY)

    for i = 0, 5 do
        local basicVal = _gt.GetUI("val"..i)
        if basicVal ~= nil then
            GUI.SetVisible(basicVal, false)
        end
    end
    local attCount = 0
    local infos = {}
    local levelNeedInfo = "穿戴等级  "
    if TurnBorn ~= nil and TurnBorn ~= 0 or Level ~= nil and Level ~= 0 then
        if TurnBorn ~= nil and TurnBorn ~= 0 then
            levelNeedInfo = levelNeedInfo..tostring(TurnBorn).."转"
        end
        if Level ~= nil and Level ~= 0 then
            levelNeedInfo = levelNeedInfo..tostring(Level).."级"
        end
        local selfRein = CL.GetIntAttr(RoleAttr.RoleAttrReincarnation)
        local selfLevel = CL.GetIntAttr(RoleAttr.RoleAttrLevel)
        local bMatch = false
        if selfRein > TurnBorn or selfRein == TurnBorn and selfLevel>=Level then
            bMatch = true
        end
        table.insert(infos, bMatch and levelNeedInfo or "<color=red>"..levelNeedInfo.."</color>")
        attCount = attCount + 1
    end
    for i = 1, 4 do
        if attsRequire ~= nil and attsRequire[i] ~= "" then
            table.insert(infos, attsRequire[i])
            attCount = attCount + 1
        end
    end
    if Role ~= nil and Role ~= 0 then
        local selfRole = CL.GetIntAttr(RoleAttr.RoleAttrRole)
		if type(Role) == "number" then
			local bMatch = selfRole == Role and true or false
			table.insert(infos, bMatch and "所需角色  "..UIDefine.GetRoleRace(Role) or "<color=red>所需角色  "..UIDefine.GetRoleRace(Role).."</color>" )
		elseif type(Role) == "string" then
			Val = string.split(Role,",")
			local role1 = tonumber(Val[1])
			local role2 = tonumber(Val[2])
			local RoleName1 = DB.GetRole(role1).RoleName
			local RoleName2 = DB.GetRole(role2).RoleName
			local bMatch = selfRole == role1 and true or false
			if bMatch then
				table.insert(infos, bMatch and "所需角色  "..RoleName1.." "..RoleName2)
			else
				bMatch = selfRole == role2 and true or false
				table.insert(infos, bMatch and "所需角色  "..RoleName1..""..RoleName2 or "<color=red>所需角色  "..RoleName1.." "..RoleName2.."</color>")
			end
		end
			attCount = attCount + 1
    end

    for i = 0, attCount-1 do
        local basicVal = _gt.GetUI("val"..i)
        if basicVal ~= nil then
            GUI.SetVisible(basicVal, true)
            GUI.StaticSetText(basicVal, infos[i+1])
        end
    end
    local line = GUI.GetChild(equipLimit, "line")
    GUI.SetPositionY(line, (attCount+1)*33)

    return 49 + attCount * 33
end

--套装属性
function ShopDetailUI.AddSuitInfo(parent, posY, suitAttrs)
    test(" ========ShopDetailUI.AddSuitInfo=========")
    test(suitAttrs[1])
    local attsT = suitAttrs[2]
    for i = 1, #attsT do
        test(attsT[i])
    end

    local DefaultAttsCount = 20
    local suit = _gt.GetUI("suit")
    if suit == nil then
        --基础属性
        suit = GUI.ImageCreate(parent, "suit", "1801100040", 5, posY)
        _gt.BindName(suit, "suit")
        local title = GUI.CreateStatic(suit,"title",suitAttrs[1], 0, 0, 200, 30)
        UILayout.StaticSetFontSizeColorAlignment(title, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        for i = 0, DefaultAttsCount do
            local suitVal = GUI.CreateStatic(suit,"suitVal"..i, "", 48, (33*(i+1)), 300, 30)
            _gt.BindName(suitVal, "suitVal"..i)
            UILayout.StaticSetFontSizeColorAlignment(suitVal, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        end
        GUI.ImageCreate(suit,"line", "1800600030", 0, 104)
    end
    GUI.SetVisible(suit, true)
    GUI.SetPositionY(suit, posY)

    for i = 0, DefaultAttsCount do
        local suitVal = _gt.GetUI("suitVal"..i)
        if suitVal ~= nil then
            GUI.SetVisible(suitVal, false)
        end
    end

    local attCount = 1
    if suitAttrs[2] ~= nil then attCount = #suitAttrs[2] end
    for i = 0, attCount-1 do
        local suitVal = _gt.GetUI("suitVal"..i)
        if suitVal ~= nil then
            GUI.SetVisible(suitVal, true)
            --test("套装 Atts =>".. suitAttrs[2][i+1])
            GUI.StaticSetText(suitVal, suitAttrs[2][i+1])
        end
    end

    local line = GUI.GetChild(suit, "line")
    GUI.SetPositionY(line, (attCount+1)*33)

    return 49 + attCount * 33
end

--宝石属性
function ShopDetailUI.AddGemInfo(parent, posY, gemAttrs)
    test(" ========ShopDetailUI.AddGemInfo=========")
    test(gemAttrs[1])
    local attsT = gemAttrs[2]
    for i = 1, #attsT do
        test(attsT[i])
    end

    local DefaultAttsCount = 20
    local gem = _gt.GetUI("gem")
    if gem == nil then
        --基础属性
        gem = GUI.ImageCreate(parent, "gem", "1801100040", 5, posY)
        _gt.BindName(gem, "gem")
        local title = GUI.CreateStatic(gem,"title",gemAttrs[1], 0, 0, 200, 30)
        UILayout.StaticSetFontSizeColorAlignment(title, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        for i = 0, DefaultAttsCount do
            local gemVal = GUI.CreateStatic(gem,"gemVal"..i, "", 48, (33*(i+1)), 300, 30)
            _gt.BindName(gemVal, "gemVal"..i)
            UILayout.StaticSetFontSizeColorAlignment(gemVal, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        end
        GUI.ImageCreate(gem,"line", "1800600030", 0, 104)
    end
    GUI.SetVisible(gem, true)
    GUI.SetPositionY(gem, posY)

    for i = 0, DefaultAttsCount do
        local gemVal = _gt.GetUI("gemVal"..i)
        if gemVal ~= nil then
            GUI.SetVisible(gemVal, false)
        end
    end

    local attCount = 1
    if gemAttrs[2] ~= nil then attCount = #gemAttrs[2] end
    for i = 0, attCount-1 do
        local gemVal = _gt.GetUI("gemVal"..i)
        if gemVal ~= nil then
            GUI.SetVisible(gemVal, true)
            --test("宝石 Atts =>".. gemAttrs[2][i+1])
            GUI.StaticSetText(gemVal, gemAttrs[2][i+1])
        end
    end

    local line = GUI.GetChild(gem, "line")
    GUI.SetPositionY(line, (attCount+1)*33)

    return 49 + attCount * 33
end



--强化属性
function ShopDetailUI.AddIntensifyInfo(parent, posY, intensifyAtts)
    test(" ========ShopDetailUI.AddIntensifyInfo=========")
    test(intensifyAtts[1])
    local attsT = intensifyAtts[2]
    for i = 1, #attsT do
        test(attsT[i])
    end

    local DefaultAttsCount = 20
    local intensify = _gt.GetUI("intensify")
    if intensify == nil then
        --基础属性
        intensify = GUI.ImageCreate(parent, "intensify", "1801100040", 5, posY)
        _gt.BindName(intensify, "intensify")
        local title = GUI.CreateStatic(intensify,"title",intensifyAtts[1], 0, 0, 200, 30)
        UILayout.StaticSetFontSizeColorAlignment(title, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        for i = 0, DefaultAttsCount do
            local intensifyVal = GUI.CreateStatic(intensify,"intensifyVal"..i, "", 48, (33*(i+1)), 300, 30)
            _gt.BindName(intensifyVal, "intensifyVal"..i)
            UILayout.StaticSetFontSizeColorAlignment(intensifyVal, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        end
        GUI.ImageCreate(intensify,"line", "1800600030", 0, 104)
    end
    GUI.SetVisible(intensify, true)
    GUI.SetPositionY(intensify, posY)

    for i = 0, DefaultAttsCount do
        local intensifyVal = _gt.GetUI("intensifyVal"..i)
        if intensifyVal ~= nil then
            GUI.SetVisible(intensifyVal, false)
        end
    end

    local attCount = 1
    if intensifyAtts[2] ~= nil then attCount = #intensifyAtts[2] end
    for i = 0, attCount-1 do
        local intensifyVal = _gt.GetUI("intensifyVal"..i)
        if intensifyVal ~= nil then
            GUI.SetVisible(intensifyVal, true)
            --test("强化Atts =>".. intensifyAtts[2][i+1])
            GUI.StaticSetText(intensifyVal, intensifyAtts[2][i+1])
        end
    end

    local line = GUI.GetChild(intensify, "line")
    GUI.SetPositionY(line, (attCount+1)*33)

    return 49 + attCount * 33
end

--基础属性
function ShopDetailUI.AddBasicInfo(parent, posY, basicAtts)
    local DefaultAttsCount = 20
    local basic = _gt.GetUI("basic")
    if basic == nil then
        --基础属性
        basic = GUI.ImageCreate(parent, "basic", "1801100040", 5, posY)
        _gt.BindName(basic, "basic")
        local title = GUI.CreateStatic(basic,"title", "基础属性", 0, 0, 200, 30)
        UILayout.StaticSetFontSizeColorAlignment(title, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        for i = 0, DefaultAttsCount do
            local basicVal = GUI.CreateStatic(basic,"basicVal"..i, "物理攻击：100", 48, (33*(i+1)), 300, 30)
            _gt.BindName(basicVal, "basicVal"..i)
            UILayout.StaticSetFontSizeColorAlignment(basicVal, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        end
        GUI.ImageCreate(basic,"line", "1800600030", 0, 104)
    end
    GUI.SetVisible(basic, true)
    GUI.SetPositionY(basic, posY)

    for i = 0, DefaultAttsCount do
        local basicVal = _gt.GetUI("basicVal"..i)
        if basicVal ~= nil then
            GUI.SetVisible(basicVal, false)
        end
    end
    local attCount = 1
    if basicAtts ~= nil then attCount = #basicAtts end

    for i = 0, attCount-1 do
        local basicVal = _gt.GetUI("basicVal"..i)
        if basicVal ~= nil then
            GUI.SetVisible(basicVal, true)
            print("basicAtts =>".. basicAtts[i+1])
            GUI.StaticSetText(basicVal, basicAtts[i+1])
        end
    end

    local line = GUI.GetChild(basic, "line")
    GUI.SetPositionY(line, (attCount+1)*33)

    return 49 + attCount * 33
end

--耐久度
function ShopDetailUI.AddDurability(parent, posY, durabilityInfo)
    local durability = _gt.GetUI("durability")
    if durability == nil then
        --耐久度
        durability = GUI.CreateStatic(parent,"durability", "耐久度：100/201", 5, posY, 200, 30)
        _gt.BindName(durability, "durability")
        UILayout.StaticSetFontSizeColorAlignment(durability, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
    end
    GUI.SetVisible(durability, true)
    GUI.SetPositionY(durability, posY)

    GUI.StaticSetText(durability, durabilityInfo)
    return 33
end

--购买数量
function ShopDetailUI.AddBuyNum(parent, posY, buyNumInfo)
    local buyNum = _gt.GetUI("buyNum")
    if buyNum == nil then
        --购买数量
        buyNum = GUI.CreateStatic(parent,"buyNum", "", 5, posY, 200, 30)
        _gt.BindName(buyNum, "buyNum")
        UILayout.StaticSetFontSizeColorAlignment(buyNum, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        GUI.ImageCreate(buyNum,"line", "1800600030", 0, 34)
    end
    GUI.SetVisible(buyNum, true)
    GUI.SetPositionY(buyNum, posY)

    GUI.StaticSetText(buyNum, buyNumInfo)

    local line = GUI.GetChild(buyNum,"line")
    if line ~= nil then
        GUI.SetPositionY(line, 34)
    end
    return 43
end

--出售价
function ShopDetailUI.AddPrice(parent, posY, priceInfo)
    local price = _gt.GetUI("price")
    local priceVal = _gt.GetUI("priceVal")
    if price == nil or priceVal==nil then
        --售价
         price = GUI.CreateStatic(parent,"price", "出售价：", 5, posY, 200, 30)
        _gt.BindName(price, "price")
        UILayout.StaticSetFontSizeColorAlignment(price, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        GUI.ImageCreate(price,"icon", UIDefine.AttrIcon[RoleAttr.RoleAttrBindGold], 96, -3, false, 35, 35)
        priceVal = GUI.CreateStatic(price,"priceVal", "10", 130, 0, 200, 30)
        _gt.BindName(priceVal, "priceVal")
        UILayout.StaticSetFontSizeColorAlignment(priceVal, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        GUI.ImageCreate(price,"line", "1800600030", 0, 36)
    end
    GUI.SetVisible(price, true)
    GUI.SetPositionY(price, posY)
    if priceVal ~= nil then
        GUI.StaticSetText(priceVal, priceInfo)
    end
    return 48
end

--商品描述
function ShopDetailUI.AddDesc(parent, posY, descInfo)
    local desc = _gt.GetUI("desc")
    if desc == nil then
        --商品描述
        desc = GUI.RichEditCreate(parent,"desc", "", 5, posY, 300, 22)
        _gt.BindName(desc, "desc")
        UILayout.StaticSetFontSizeColorAlignment(desc, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
    end
    GUI.SetVisible(desc, true)
    GUI.SetPositionY(desc, posY)

    GUI.StaticSetText(desc, descInfo)
    local height = GUI.RichEditGetPreferredHeight(desc)
    GUI.SetHeight(desc, height)
    return height+11
end

--物品效用
function ShopDetailUI.AddFunction(parent, posY, funcInfo)
    local func = _gt.GetUI("func")
    if func == nil then
        --物品效用
        func = GUI.RichEditCreate(parent,"func", "", 5, posY, 300, 22)
        _gt.BindName(func, "func")
        UILayout.StaticSetFontSizeColorAlignment(func, UIDefine.FontSizeL, UIDefine.BrownColor, nil)
        GUI.ImageCreate(func,"line", "1800600030", 0, 36)
    end
    GUI.SetVisible(func, true)
    GUI.SetPositionY(func, posY)

    funcInfo = "效用:\n"..funcInfo
    GUI.StaticSetText(func, funcInfo)
    local height = GUI.RichEditGetPreferredHeight(func)
    GUI.SetHeight(func, height)

    local line = GUI.GetChild(func,"line")
    if line ~= nil then
        GUI.SetPositionY(line, height + 5)
    end
    return height+16
end