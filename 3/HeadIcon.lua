HeadIcon = {}
function HeadIcon.Create(parent, name, pic, x, y, w, h)
    if w == nil then
        w = 0
    end

    if h == nil then
        h = 0
    end
    local auto = (w == 0 and h == 0)
    local itemIcon = GUI.ImageCreate(parent, name, pic, x, y, auto, w, h)
    w = GUI.GetWidth(itemIcon) / 76
    h = GUI.GetHeight(itemIcon) / 76
    local vipV = GUI.ImageCreate(itemIcon, "vipV", "1801605010", -24, h * 14, false, w * 23, h * 18)
    local vipVNum1 = GUI.ImageCreate(itemIcon, "vipVNum1", "1801605020", 0, 0, false, w * 27, h * 32)
    local vipVNum2 = GUI.ImageCreate(itemIcon, "vipVNum2", "1801605020", 0, 0, false, w * 27, h * 32)
    local tmp = { vipV, vipVNum1, vipVNum2 }
    for i = 1, #tmp do
        GUI.SetVisible(tmp[i], false)
        UILayout.SetSameAnchorAndPivot(tmp[i], UILayout.TopRight)
    end
    return itemIcon
end

function HeadIcon.CreateVip(itemIcon, w, h, offsetX, offsetY)
    w = (w or GUI.GetWidth(itemIcon)) / 76
    h = (h or GUI.GetHeight(itemIcon)) / 76
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local vipV = GUI.ImageCreate(itemIcon, "vipV", "1801605010", offsetX - 24, offsetY + h * 14, false, w * 23, h * 18)
    local vipVNum1 = GUI.ImageCreate(itemIcon, "vipVNum1", "1801605020", offsetX, offsetY, false, w * 27, h * 32)
    local vipVNum2 = GUI.ImageCreate(itemIcon, "vipVNum2", "1801605020", offsetX, offsetY, false, w * 27, h * 32)
    local tmp = { vipV, vipVNum1, vipVNum2 }
    for i = 1, #tmp do
        GUI.SetVisible(tmp[i], false)
        UILayout.SetSameAnchorAndPivot(tmp[i], UILayout.TopRight)
    end
end

function HeadIcon.BindRoleGuid(icon, guid)
    if guid == nil then
        guid = 0
    end
    HeadIcon.BindRoleVipLv(icon, CL.GetIntAttr(RoleAttr.RoleAttrVip, guid))
end

function HeadIcon.BindRoleVipLv(icon, vipLv)
    if icon == nil then
        return
    end
    local vipV = GUI.GetChild(icon, "vipV", false)
    local vipVNum1 = GUI.GetChild(icon, "vipVNum1", false)
    local vipVNum2 = GUI.GetChild(icon, "vipVNum2", false)
    if vipV and vipVNum1 and vipVNum2 then
        local h = math.floor(vipLv / 10)
        if h > 9 then
            test("设置VIP等级出错，当前设置等级：" .. vipLv)
            h = 9
        end
        local l = vipLv % 10
        local tmp = { vipVNum2, vipVNum1, vipV }
        local picNum = { l, h }
        local picbase = { 1801605020, 1801605020, 1801605010 }
        local x = -GUI.GetPositionX(vipVNum2) -- 设置成右上角对齐时，positionX的值会取反，所以加一个负号
        for i = 1, 3 do
            local w = GUI.GetWidth(tmp[i])
            local pic = picbase[i]
            if picNum[i] then
                pic = pic + picNum[i]
            end
            if i == 1 then
                GUI.SetVisible(tmp[i], true)
            elseif i == 2 then
                local b = h > 0
                GUI.SetVisible(tmp[i], b)
                x = x + (b and w or 0)
            else
                GUI.SetVisible(tmp[i], true)
                x = x + w
            end
            GUI.ImageSetImageID(tmp[i], tostring(pic))
            GUI.SetPositionX(tmp[i], x)
        end
    end
end
