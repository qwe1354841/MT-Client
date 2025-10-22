EquipScrollItem = {}
local test = print
local test = function()
end
function EquipScrollItem.CreateItem(parent, name)
    local item = GUI.CheckBoxExCreate(parent, name, "1800700030", "1800700040", 0, 0, false, 280, 100)
    local icon = ItemIcon.Create(item, "icon", -88, 0)
    GUI.SetIsRaycastTarget(icon, false)
    local name = GUI.CreateStatic(item, "name", "name", 102, -20, 170, 30)
    local nameEx = GUI.CreateStatic(item, "nameEx", " ", 202, -20, 75, 30)
    local lv = GUI.CreateStatic(item, "lv", "lv", 102, 20, 170, 30)
    local leftUp = GUI.ImageCreate(item, "leftUp", "1801104010", 0, 0)
    UILayout.SetSameAnchorAndPivot(leftUp, UILayout.TopLeft)
    local t = {name, lv, nameEx}
    for i = 1, #t do
        local txt = t[i]
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
        GUI.SetAnchor(txt, UIAnchor.Left)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
        GUI.SetPivot(txt, UIAroundPivot.Left)
        if t[i] == nameEx then
            GUI.SetColor(txt, UIDefine.EnhanceBlueColor)
        else
            GUI.SetColor(txt, UIDefine.BrownColor)
        end
        GUI.StaticSetLabelType(txt, LabelType.ConstH)
    end

    local gemInfo =GUI.CreateStatic(item, "gemInfo", "gemInfo", 102, 18, 170, 55)
    GUI.StaticSetAutoSize(gemInfo,true);
    GUI.StaticSetAlignment(gemInfo, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(gemInfo, UIDefine.FontSizeS)
    GUI.SetColor(gemInfo, UIDefine.Yellow2Color)
    UILayout.SetSameAnchorAndPivot(gemInfo, UILayout.Left)

    local gemInlay = GUI.CreateStatic(item, "gemInlay", "（可镶嵌）", 132, 20, 170, 30)
    GUI.StaticSetAutoSize(gemInlay,true);
    GUI.StaticSetAlignment(gemInlay, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(gemInlay, UIDefine.FontSizeS)
    GUI.SetColor(gemInlay, UIDefine.GreenColor)
    UILayout.SetSameAnchorAndPivot(gemInlay, UILayout.Left)
    return item
end



function EquipScrollItem.RefreshLeftItemByGemId(guid, gemId)
    local itemui = GUI.GetByGuid(guid)
    if itemui == nil then
        test("EquipScrollItem刷新道具错误")
    end

    local icon = GUI.GetChild(itemui, "icon", false)
    local name = GUI.GetChild(itemui, "name", false)
    local nameEx = GUI.GetChild(itemui, "nameEx", false)
    local lv = GUI.GetChild(itemui, "lv", false)
    local leftUp = GUI.GetChild(itemui, "leftUp", false)
    local gemInfo = GUI.GetChild(itemui, "gemInfo", false)
    local gemInlay = GUI.GetChild(itemui, "gemInlay", false)
    GUI.SetVisible(gemInlay,false);
    GUI.SetVisible(gemInfo,false);
    local itemDB = DB.GetOnceItemByKey1(gemId)
    ItemIcon.BindItemDB(icon, itemDB)
    GUI.StaticSetText(name, itemDB.Name)
    local w = GUI.StaticGetLabelPreferWidth(name)
    GUI.SetWidth(name,w)
    if w > 170 then
        local s = 170 / w
        GUI.SetScale(name, Vector3.New(s, s, s))
    else
        GUI.SetScale(name, UIDefine.Vector3One)
    end
    GUI.StaticSetText(nameEx, " ")
    GUI.StaticSetText(lv, " ")
    GUI.SetVisible(leftUp, false)
end

function EquipScrollItem.RefreshLeftItemByGemIdEx(guid, gemId,attrId,attrValue,attrId_2,attrValue_2)
    local itemui = GUI.GetByGuid(guid)
    if itemui == nil then
        test("EquipScrollItem刷新道具错误")
    end

    local icon = GUI.GetChild(itemui, "icon", false)
    local name = GUI.GetChild(itemui, "name", false)
    local nameEx = GUI.GetChild(itemui, "nameEx", false)
    GUI.StaticSetText(nameEx, " ")
    local lv = GUI.GetChild(itemui, "lv", false)
    GUI.StaticSetText(lv, " ")
    local leftUp = GUI.GetChild(itemui, "leftUp", false)
    GUI.SetVisible(leftUp, false)
    local gemInfo = GUI.GetChild(itemui, "gemInfo", false)
    GUI.SetVisible(gemInfo,true);
    local gemInlay = GUI.GetChild(itemui, "gemInlay", false)
    GUI.SetVisible(gemInlay,false);
    local itemDB = DB.GetOnceItemByKey1(gemId)
    ItemIcon.BindItemDB(icon, itemDB)
    GUI.StaticSetText(name, itemDB.Name)
    local w = GUI.StaticGetLabelPreferWidth(name)
    GUI.SetWidth(name,w)
    if w > 170 then
        local s = 170 / w
        GUI.SetScale(name, Vector3.New(s, s, s))
    else
        GUI.SetScale(name, UIDefine.Vector3One)
    end
	local info = ""
    --local info = UIDefine.GetAttrDesStr(attrId,attrValue).."\n".."价值 "..gemValue;			--大唐版本
	if attrId_2 ~= 0 then
		info = UIDefine.GetAttrDesStr(attrId,attrValue).."\n"..UIDefine.GetAttrDesStr(attrId_2,attrValue_2);
	else
		info = UIDefine.GetAttrDesStr(attrId,attrValue).."\n"
	end
    GUI.StaticSetText(gemInfo,info)
    local w = GUI.StaticGetLabelPreferWidth(gemInfo)
	GUI.SetWidth(gemInfo,w)
    if w > 170 then
        local s = 170 / w
        GUI.SetScale(gemInfo, Vector3.New(s, s, s))
    else
        GUI.SetScale(gemInfo, UIDefine.Vector3One)
    end
    GUI.SetHeight(gemInfo,55);
end

function EquipScrollItem.RefreshLeftItemByItemInfos(guid, index, type, items, nameExStr)
    if items == nil or items[index] == nil then
        return
    end
    EquipScrollItem.RefreshLeftItemByItemInfosEx(guid, type, items[index], nameExStr)
end

function EquipScrollItem.RefreshLeftItem_GemByItemInfo(guid, type, itemInfo)
    local itemui = GUI.GetByGuid(guid)
    if itemui == nil then
        test("EquipScrollItem刷新道具错误")
    end

    local icon = GUI.GetChild(itemui, "icon", false)
    local name = GUI.GetChild(itemui, "name", false)
    local nameEx = GUI.GetChild(itemui, "nameEx", false)
    local lv = GUI.GetChild(itemui, "lv", false)
    local leftUp = GUI.GetChild(itemui, "leftUp", false)
    GUI.SetVisible(leftUp, false)
    GUI.StaticSetText(nameEx, " ")
    local gemInfo = GUI.GetChild(itemui, "gemInfo", false)
    GUI.SetVisible(gemInfo,false);
    local gemInlay = GUI.GetChild(itemui, "gemInlay", false)
    local itemData = EquipUI.GetEquipData(itemInfo.guid, type, itemInfo.site)
    ItemIcon.BindItemData(icon, itemData)
    GUI.StaticSetText(name, itemInfo.name)
    local w = GUI.StaticGetLabelPreferWidth(name)
    GUI.SetWidth(name,w)
    if w > 170 then
        local s = 170 / w
        GUI.SetScale(name, Vector3.New(s, s, s))
    else
        GUI.SetScale(name, UIDefine.Vector3One)
    end

    local gemCount, siteCount = LogicDefine.GetEquipGemCount(itemData)
    GUI.StaticSetText(lv, gemCount .. "/" .. siteCount)
    if gemCount < siteCount then
        GUI.SetVisible(gemInlay,true)
    else
        GUI.SetVisible(gemInlay,false);
    end
end

---@param item eqiupItem
function EquipScrollItem.RefreshLeftItemByItemInfosEx(guid, type, item, nameExStr)
    local itemui = GUI.GetByGuid(guid)
    if itemui == nil then
        test("EquipScrollItem刷新道具错误")
    end

    local icon = GUI.GetChild(itemui, "icon", false)
    local name = GUI.GetChild(itemui, "name", false)
    local nameEx = GUI.GetChild(itemui, "nameEx", false)
    GUI.SetVisible(nameEx, true)
    local lv = GUI.GetChild(itemui, "lv", false)
    local leftUp = GUI.GetChild(itemui, "leftUp", false)
    GUI.SetVisible(leftUp, false)
    local gemInfo = GUI.GetChild(itemui, "gemInfo", false)
    GUI.SetVisible(gemInfo,false);
    local gemInlay = GUI.GetChild(itemui, "gemInlay", false)
    GUI.SetVisible(gemInlay,false);
    if item == nil then
        return
    end
    if type == item_container_type.item_container_equip and EquipUI.curGuardGuid then
        ItemIcon.BindGuardEquip(icon, EquipUI.curGuardGuid, item.site)
    else
        ItemIcon.BindIndexForBag(icon, item.site, type)
    end

    GUI.StaticSetText(name, item.name)
    if nameExStr then
        GUI.StaticSetText(nameEx, nameExStr)
    else
        if item.enhanceLv > 0 then
            local txt = "+" .. item.enhanceLv
            GUI.StaticSetText(nameEx, txt)
        else
            GUI.StaticSetText(nameEx, " ")
        end
    end

    if item.armorLevel == LogicDefine.ArmorLevel.Fairy then
        GUI.StaticSetText(lv, tostring(item.lv) .. "阶仙器")
    else
        local text = ""
        if string.find(item.showType,"无级别") then
            text = item.showType
        else
            text = tostring(item.lv) .. "级  " .. item.showType
        end
        GUI.StaticSetText(lv, text)
    end
    local w = GUI.StaticGetLabelPreferWidth(name)
    GUI.SetWidth(name,w)
    if w > 170 then
        local s = 170 / w
        GUI.SetScale(name, Vector3.New(s, s, s))
    else
        GUI.SetScale(name, UIDefine.Vector3One)
    end
    GUI.SetPositionX(nameEx, GUI.GetPositionX(name) + w + 10)
end
function EquipScrollItem.RefreshLeftItemByItemIdEx(guid, itemId, itemKeyName, nameExStr)
    local itemui = GUI.GetByGuid(guid)
    if itemui == nil then
        test("EquipScrollItem刷新道具错误")
    end

    local icon = GUI.GetChild(itemui, "icon", false)
    local name = GUI.GetChild(itemui, "name", false)
    local nameEx = GUI.GetChild(itemui, "nameEx", false)
    local lv = GUI.GetChild(itemui, "lv", false)
    local leftUp = GUI.GetChild(itemui, "leftUp", false)
    GUI.SetVisible(leftUp, false)
    local gemInfo = GUI.GetChild(itemui, "gemInfo", false)
    GUI.SetVisible(gemInfo,false);
    local gemInlay = GUI.GetChild(itemui, "gemInlay", false)
    GUI.SetVisible(gemInlay,false);
    local iteminfo = DB.GetItem(itemId, itemKeyName)
    if iteminfo == nil then
        return
    end
    ItemIcon.BindItemId(icon, itemId)
    GUI.StaticSetText(name, iteminfo.Name)
    if nameExStr then
        GUI.StaticSetText(nameEx, nameExStr)
    else
        GUI.StaticSetText(nameEx, " ")
    end
    -- if iteminfo.ArmorLevel == 2 then
    --     GUI.StaticSetText(lv, tostring(iteminfo.Itemlevel) .. "阶仙器")
    -- else
    -- GUI.StaticSetText(lv, tostring(iteminfo.Level) .. "级" .. iteminfo.ShowType)
    -- end
	local text = ""
	if string.find(iteminfo.ShowType,"无级别") then
		text = iteminfo.ShowType
	else
		text = tostring(iteminfo.Level) .. "级  " .. iteminfo.ShowType
	end
	GUI.StaticSetText(lv, text)
    local w = GUI.StaticGetLabelPreferWidth(name)
    GUI.SetWidth(name,w)
    if w > 170 then
        local s = 170 / w
        GUI.SetScale(name, Vector3.New(s, s, s))
    else
        GUI.SetScale(name, UIDefine.Vector3One)
    end
    GUI.SetPositionX(nameEx, GUI.GetPositionX(name) + w + 10)
end
local attrT = EquipLogic.attrT
local attrMax = #attrT
EquipScrollItem.attrMax = attrMax
---@public
---@param itemid number
---@param itemKeyName string
---@param h number
---@param eqiupItemTable eqiupItem
---@return number
function EquipScrollItem.RefreshResultInfo(itemid, itemKeyName, eqiupItemTable, maxEnhance)
	test(11111111111111111)
    test("EquipScrollItem.RefreshResultInfo")
    local bg = EquipUI.guidt.GetUI("normalBg")
    if bg == nil then
        test("RefreshResultInfoe刷新道具错误")
    end

    local icon = GUI.GetChild(bg, "itemIcon", false)
    local name = GUI.GetChild(bg, "name", false)
    local enhanceLv = GUI.GetChild(bg, "enhanceLv", false)
    local lv = GUI.GetChild(bg, "lv", false)
    local equipType = GUI.GetChild(bg, "equipType", false)
    local tip = GUI.GetChild(bg, "tip", false)
    GUI.SetVisible(tip, false)
    local uit = {icon, name, lv, equipType}
    for i = 1, #uit do
        GUI.SetVisible(uit[i], true)
    end
    local iteminfo = nil
    local itemattr = nil
    local nameTxt, lvTxt, equipTypeTxt, enhanceLvTxt = " "
    if itemid ~= nil and itemKeyName ~= nil then
        iteminfo = DB.GetItem(itemid, itemKeyName)
        itemattr = DB.GetItem_Att(itemid, itemKeyName)
    end
    if eqiupItemTable then
        if eqiupItemTable.bagtype == item_container_type.item_container_guard_equip and EquipUI.curGuardGuid then
            ItemIcon.BindGuardEquip(icon, EquipUI.curGuardGuid, eqiupItemTable.site)
        else
            ItemIcon.BindIndexForBag(icon, eqiupItemTable.site, eqiupItemTable.bagtype)
        end
        nameTxt = eqiupItemTable.name
        if maxEnhance then
            if eqiupItemTable.enhanceLv and eqiupItemTable.enhanceLv > 0 then
                enhanceLvTxt = "+" .. eqiupItemTable.enhanceLv
            end
            lvTxt = "强化等级:"
            equipTypeTxt = eqiupItemTable.enhanceLv .. "->" .. maxEnhance
        else
            if eqiupItemTable.turnBorn > 0 then
                lvTxt = tostring(eqiupItemTable.turnBorn) .. "转" .. tostring(eqiupItemTable.lv) .. "级"
            else
                lvTxt = tostring(eqiupItemTable.lv) .. "级"
            end
            equipTypeTxt = eqiupItemTable.showType
        end
    elseif iteminfo ~= nil and iteminfo.Id > 0 then
        ItemIcon.BindItemId(icon, iteminfo.Id)
        nameTxt = iteminfo.Name
        print(iteminfo.Level)
        lvTxt = tostring(iteminfo.Level) .. "级"
        equipTypeTxt = iteminfo.ShowType
    else
        ItemIcon.BindItemId(icon, nil)
    end
    GUI.StaticSetText(name, nameTxt)
    local w = GUI.StaticGetLabelPreferWidth(name)
    GUI.SetWidth(name, w)
    GUI.SetPositionX(enhanceLv, GUI.GetPositionX(name) + w + 5)
    GUI.StaticSetText(lv, lvTxt)
    w = GUI.StaticGetLabelPreferWidth(lv)
    GUI.SetWidth(lv, w)
    GUI.SetPositionX(equipType, GUI.GetPositionX(lv) + w + 5)
    GUI.StaticSetText(equipType, equipTypeTxt)
    if string.find(equipTypeTxt,"无级别") then
        GUI.SetVisible(lv,false)
        GUI.SetPositionX(equipType,GUI.GetPositionX(lv))
    end
    GUI.StaticSetText(enhanceLv, enhanceLvTxt)
    local src = GUI.GetChild(bg, "src", false)
    GUI.ScrollRectSetNormalizedPosition(src, UIDefine.Vector2One)
    local y = 30
    for i = 1, attrMax do
        local att = GUI.GetChild(src, "attText" .. i, false)
        local attv = GUI.GetChild(att, "value", false)
        if itemattr ~= nil and itemattr.Id > 0 then
            if attrT[i].IsShow(iteminfo, itemattr) == true then
                GUI.SetVisible(att, true)
                -- GUI.SetPositionY(att, 145 + y)
                y = y + 30
                GUI.StaticSetText(att, attrT[i].name)
                GUI.StaticSetText(attv, attrT[i].GetV(iteminfo, itemattr))
                GUI.SetColor(attv, attrT[i]:GetColor(iteminfo, itemattr, EquipUI.curGuardGuid))
            else
                GUI.SetVisible(att, false)
            end
        else
            GUI.SetVisible(att, false)
        end
    end
    return y
end
---@return eqiupItem[]
function EquipScrollItem.GetItemByType(type, find)
    ---@type eqiupItem[]
    local items = nil
    if type == item_container_type.item_container_bag then
        items = EquipUI.data.bag
    elseif type == item_container_type.item_container_equip then
        items = EquipUI.data.equip
    end
    local t = {}
    if find ~= nil then
        for i = 1, #items do
            if find(items[i]) then
                t[#t + 1] = items[i]
            end
        end
    else
        return items
    end
    return t
end

---@public
---@param MaxArtificeCnt number 最大属性数
---@param guidt table ui容器 命名需统一
---@param dynAttrs DynAttrData[]
---@param lock boolean[]
function EquipScrollItem.RefreshAttrLockInfo(MaxArtificeCnt, _gt, dynAttrs, lock)
    for i = 1, MaxArtificeCnt do
       -- local cb = _gt.GetUI("attrLock" .. i)
        local name = _gt.GetUI("attrname" .. i)
        local attrnum = _gt.GetUI("attrnum" .. i)
     --   if cb == nil then
			if dynAttrs ~= nil and i <= #dynAttrs then
            test(dynAttrs[i].name)
            test(dynAttrs[i].attr)
            test(tostring(dynAttrs[i].value))
          --  GUI.SetVisible(cb, true)
            GUI.SetVisible(name, true)

            GUI.StaticSetText(name, dynAttrs[i].name)
            local w = GUI.StaticGetLabelPreferWidth(name)
            GUI.SetWidth(name,w)
            if w > 100 then
                local s = 100 / w
                GUI.SetScale(name, Vector3.New(s, s, s))
            else
                GUI.SetScale(name, UIDefine.Vector3One)
            end
        --    if lock and lock[i] ~= nil then
        --        GUI.CheckBoxSetCheck(cb, lock[i])
           -- else
      --          GUI.SetVisible(cb, false)
         --       GUI.CheckBoxSetCheck(cb, false)
           -- end
            local tmp = dynAttrs[i].GetStrValue()
            if tmp then
                GUI.SetVisible(attrnum, true)
                if string.sub(tmp, 1, 1) == "-" then
                    GUI.StaticSetText(attrnum, tmp)
                else
                    GUI.StaticSetText(attrnum, "+" .. tmp)
                end
                GUI.SetColor(attrnum, UIDefine.OutLine_GreenColor)
            else
                GUI.SetVisible(attrnum, false)
            end
        else
         --   GUI.SetVisible(cb, false)
            GUI.SetVisible(name, false)
            GUI.SetVisible(attrnum, false)
        end
    end
end
