-- 侍从命魂界面
-------------------------------start缓存一下常用的全局变量start---------------------------
local _gt = UILayout.NewGUIDUtilTable()
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
local GuardSoulUI = {}
_G.GuardSoulUI = GuardSoulUI

-- 代理可配置
-- tips是否显示颜色 (需要配置GuardSoulUI.scopeColor,没有默认配置)
GuardSoulUI.isShowTipsScopeColor = nil

-- 命魂洗炼属性根据范围显示颜色的配置
GuardSoulUI.scopeColor = {
    -- 当属性不在配置内，或超出配置范围，将显示默认颜色
    -- 如果uidefine中没有合适的颜色 使用Color.New(r / 255, g / 255, b / 255, 1)
    -- 也可以直接使用"#ffffff" 这种
    ["速度"] = {
        { scope = 100, color = UIDefine.WhiteColor },
        { scope = 200, color = UIDefine.WhiteColor },
        { scope = 400, color = UIDefine.WhiteColor }
    },
    ["法术攻击"] = {
        { scope = 100, color = UIDefine.WhiteColor },
        { scope = 200, color = UIDefine.WhiteColor },
        { scope = 400, color = "#E855FF" }
    }
}

-- #global-variable --

local tabList = {
    { "命魂", "soul_tab_btn", "on_soul_tab_btn_click", "soul_page" },
    { "强化", "reinforced_tab_btn", "on_reinforced_tab_btn_click", "reinforced_page" }
}

local guardType = UIDefine.guardTypeImages
-- {
--    { "物攻", "1800707170" },
--    { "法攻", "1800707180" },
--    { "治疗", "1800707190" },
--    { "控制", "1800707210" },
--    { "辅助", "1800707200" },
--    { "全部", "" }
-- }

local quality = UIDefine.guardAndItemQualityImages
-- {
--    { "1801205100", "1800400330" },
--    { "1801205110", "1800400100" },
--    { "1801205120", "1800400110" },
--    { "1801205130", "1800400120" },
--    { "1801205130", "1800400320" }
-- }

local soul_type = UIDefine.guardSoulImages

-- {
--    { "攻击", "1801719180", '1801719130' },
--    { "防御", "1801719150", '1801719100' },
--    { "生存", "1801719140", '1801719090' },
--    { "辅助", "1801719160", '1801719110' },
--    { "特殊", "1801719170", '1801719120' },
--    { "全部", "", '1801719080' }
-- }

-- 右下角数字图片背景
local _IconRightCornerRes = UIDefine.IconLevelBg
-- {
--    "1801407010",
--    "1801407020",
--    "1801407030",
--    "1801407040",
--    "1801407050"
-- }

local mandarin_num = UIDefine.mandarin_num
-- {
--    '1801719011',
--    '1801719012',
--    '1801719013',
--    '1801719014',
--    '1801719015',
--    '1801719016'
-- }

local soul_grade = {
    "普通", "优秀", "精良", "史诗", "传说", "全部", "默认"
}

-- local inspect = require 'inspect'
-- 缺点：变量名太长、函数实现混乱

-- #main --
function GuardSoulUI.Main()
    local panel = GUI.WndCreateWnd("GuardSoulUI", "GuardSoulUI", 0, 0)
    local panelBg = UILayout.CreateFrame_WndStyle0(panel, "侍 从 命 魂", "GuardSoulUI", "OnExit", _gt)
    _gt.BindName(panelBg, "panelBg")
    UILayout.CreateRightTab(tabList, "GuardSoulUI")

    local soul_page = GUI.GroupCreate(panelBg, "soul_page", 0, 0, 1197, 639)
    _gt.BindName(soul_page, "soul_page")

    local reinforced_page = GUI.GroupCreate(panelBg, "reinforced_page", 0, 0, 1197, 639)
    _gt.BindName(reinforced_page, "reinforced_page")
end

function GuardSoulUI.OnShow(parameter)
    GuardSoulUI._register()
    local guard_soul_ui = GUI.GetWnd("GuardSoulUI")
    if guard_soul_ui and GUI.GetVisible(guard_soul_ui) == false then
        GUI.SetVisible(guard_soul_ui, true)
        GuardSoulUI.refresh_model_part()
    end

    GuardSoulUI.request()

    GuardSoulUI.create()
    --GuardSoulUI.refresh()

    if parameter then
        local index1, index2 = UIDefine.GetParameterStr(parameter)
        if index1 then
            if index1 ~= "2" then
                GuardSoulUI.on_soul_tab_btn_click(nil, true)
            else
                if index2 == nil or index2 ~= "2" then
                    GuardSoulUI.on_reinforced_tab_btn_click(nil, true)
                else
                    GuardSoulUI.on_reinforced_tab_btn_click("baptize", true)
                end
            end
        end
        -- 打开界面后就选中的侍从的id
        local guard_id = string.match(parameter, "guard_id:(.+)")
        if guard_id then
            GuardSoulUI.guard_id_when_open_page = tonumber(guard_id)
        end
    else
        -- GuardSoulUI.on_reinforced_tab_btn_click()
        GuardSoulUI.on_soul_tab_btn_click(nil, true)
    end
end

function GuardSoulUI.OnExit()
    GuardSoulUI._unregister()
    GUI.Destroy(_gt.GetUI("RoleLstNodeModel"))
    GUI.CloseWnd("GuardSoulUI")

    local wnd = GUI.GetWnd("GuardUI")
    -- 显示侍从界面
    if wnd and GUI.GetVisible(wnd) ~= true then
        GUI.SetVisible(wnd, true)
        GuardUI.ShowGuardDetailInfo()
    end

    GuardSoulUI.order_type = nil
    GuardSoulUI.soul_items_of_bag = nil
    GuardSoulUI.select_soul_type = nil
    -- 选中为全部
    GuardSoulUI.select_soul_list_type = 0
    GuardSoulUI.select_soul_material_type = 0

    GuardSoulUI.select_deputy_property_data = {}
end

function GuardSoulUI._register()
    -- when item addition/delete/update
    CL.RegisterMessage(GM.AddNewItem, "GuardSoulUI", "trigger_event_of_soul_item")
    CL.RegisterMessage(GM.UpdateItem, "GuardSoulUI", "trigger_event_of_soul_item")
    CL.RegisterMessage(GM.RemoveItem, "GuardSoulUI", "trigger_event_of_soul_item")
end

function GuardSoulUI._unregister()
    CL.UnRegisterMessage(GM.AddNewItem, "GuardSoulUI", "trigger_event_of_soul_item")
    CL.UnRegisterMessage(GM.UpdateItem, "GuardSoulUI", "trigger_event_of_soul_item")
    CL.UnRegisterMessage(GM.RemoveItem, "GuardSoulUI", "trigger_event_of_soul_item")
end

function GuardSoulUI.create()
    -- 每次打开界面后关闭小红点
    GlobalProcessing.have_guard_soul_been_to_be_seen = nil
    GlobalProcessing.guard_soul_red_point()
end

function GuardSoulUI.refresh()
    GuardSoulUI.on_soul_tab_btn_click(nil, true)
end

function GuardSoulUI.request()
    -- FormMingHun.GetPartData(player)
    -- GuardSoulUI.minghun_refining_attr_openlevel
    -- GuardSoulUI.minghun_refining_attr_mark
    -- GuardSoulUI.response()

    CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "GetPartData")
end

function GuardSoulUI.response()
end

--[[
    ========================
    ------------  命魂页签  -------------
    ========================
]]

-- #create-tab1 --

function GuardSoulUI.create_model_part()
    local guard_Bg = _gt.GetUI("soul_page")

    -- 侍从稀有度
    if GUI.GetChild(guard_Bg, "middle_GuardRarity_Sprite") == nil then
        local middle_GuardRarity_Sprite = GUI.ImageCreate(guard_Bg, "middle_GuardRarity_Sprite", "1800714050", 135, 65)
        _gt.BindName(middle_GuardRarity_Sprite, "middle_GuardRarity_Sprite")
        UILayout.SetSameAnchorAndPivot(middle_GuardRarity_Sprite, UILayout.Top)
    else
        return ""
    end

    -- 侍从伤害类型
    if GUI.GetChild(guard_Bg, "middle_GuardType_Sprite") == nil then
        local middle_GuardType_Sprite = GUI.ImageCreate(guard_Bg, "middle_GuardType_Sprite", "1800707170", 135, 95)
        _gt.BindName(middle_GuardType_Sprite, "middle_GuardType_Sprite")
        UILayout.SetSameAnchorAndPivot(middle_GuardType_Sprite, UILayout.Top)
    end

    local model_Bg = GUI.GetChild(guard_Bg, "model_Bg")
    if model_Bg == nil then
        model_Bg = GUI.ImageCreate(guard_Bg, "model_Bg", "1801719030", 0, 125, true, 0, 0, false)
        _gt.BindName(model_Bg, "model_Bg")
        UILayout.SetSameAnchorAndPivot(model_Bg, UILayout.Top)
    end

    if GUI.GetChild(guard_Bg, "bottomShadow") == nil then
        local bottomShadow = GUI.ImageCreate(guard_Bg, "bottomShadow", "1800400240", 0, 45)
        _gt.BindName(bottomShadow, "bottomShadow")
        UILayout.SetSameAnchorAndPivot(bottomShadow, UILayout.BottomLeft)
    end

    -- create six circle
    local x = -158
    local y = 23
    for i = 1, 3 do
        if i == 2 then
            x = -144
            y = -80
        elseif i == 3 then
            x = -73
            y = -157
        end

        local circle1 = GUI.ImageCreate(guard_Bg, "model_soul_circle" .. i, "1801719020", x, y)
        SetSameAnchorAndPivot(circle1, UILayout.Center)
        GUI.SetIsRaycastTarget(circle1, true)
        circle1:RegisterEvent(UCE.PointerClick)

        local mandarin_num_ = GUI.ImageCreate(circle1, "mandarin_num_" .. i, mandarin_num[i], 0, 0)
        SetSameAnchorAndPivot(mandarin_num_, UILayout.Center)

        local num = 6 - (i - 1)
        local circle2 = GUI.ImageCreate(guard_Bg, "model_soul_circle" .. num, "1801719020", -x, y)
        SetSameAnchorAndPivot(circle2, UILayout.Center)
        GUI.SetIsRaycastTarget(circle2, true)
        circle2:RegisterEvent(UCE.PointerClick)

        local mandarin_num_ = GUI.ImageCreate(circle2, "mandarin_num_" .. num, mandarin_num[num], 0, 0)
        SetSameAnchorAndPivot(mandarin_num_, UILayout.Center)
    end
end

function GuardSoulUI.create_special_skill()
    local guard_Bg = _gt.GetUI("soul_page")

    -- special skill
    if GUI.GetChild(guard_Bg, "title_bg") == nil then
        local title_bg = GUI.ImageCreate(guard_Bg, "title_bg", "1801200030", 0, -188, false, 330, 35)
        SetSameAnchorAndPivot(title_bg, UILayout.Bottom)

        local title = GUI.CreateStatic(title_bg, "special_skill_title", "<color=#30aa1dff>已激活特效</color>", 0, 0, GUI.GetWidth(title_bg), GUI.GetHeight(title_bg), "system", true)
        SetSameAnchorAndPivot(title, UILayout.Center)
        GUI.StaticSetAlignment(title, TextAnchor.MiddleCenter)
        GUI.StaticSetFontSize(title, UIDefine.FontSizeM)
    else
        return ""
    end

    if GUI.GetChild(guard_Bg, "special_skill_icon") == nil then
        local skill_icon = GUI.ItemCtrlCreate(guard_Bg, "special_skill_icon", "1800600050", -111, -80, 80, 81, false)
        SetSameAnchorAndPivot(skill_icon, UILayout.Bottom)
        GUI.ItemCtrlSetElementValue(skill_icon, eItemIconElement.Icon, "1900352610")
        GUI.ItemCtrlSetElementRect(skill_icon, eItemIconElement.Icon, 0, 0, 70, 70)
    end

    if GUI.GetChild(guard_Bg, "special_skill_name") == nil then
        local skill_name = GUI.CreateStatic(guard_Bg, "special_skill_name", "四大行者", 61, -125, 255, 50, "system", true)
        SetSameAnchorAndPivot(skill_name, UILayout.Bottom)
        GUI.StaticSetFontSize(skill_name, UIDefine.FontSizeXL)
        GUI.SetColor(skill_name, UIDefine.BrownColor)
        GUI.StaticSetAlignment(skill_name, TextAnchor.MiddleLeft)
    end

    local skill_type = GUI.CreateStatic(guard_Bg, "special_skill_type", "物攻型", 61, -98, 255, 50, "system", true)
    SetSameAnchorAndPivot(skill_type, UILayout.Bottom)
    GUI.StaticSetFontSize(skill_type, UIDefine.FontSizeS)
    GUI.SetColor(skill_type, UIDefine.BrownColor)
    GUI.StaticSetAlignment(skill_type, TextAnchor.MiddleLeft)

    -- 改成滚动显示
    local childSize = Vector2.New(240, 200)
    local descriptionScroll = GUI.ScrollRectCreate(guard_Bg, "descriptionScroll", 53, 246, 240, 75, 0, false, childSize, UIAroundPivot.Top, UIAnchor.Top, 1)

    local description = GUI.CreateStatic(descriptionScroll, "special_skill_description", "造成物品暴击时，会提高下一次攻击的基础数值20%", 53, -34, 240, 75, "system", true)
    SetSameAnchorAndPivot(description, UILayout.Bottom)
    GUI.StaticSetFontSize(description, UIDefine.FontSizeM)
    GUI.SetColor(description, UIDefine.BrownColor)
    GUI.StaticSetAlignment(description, TextAnchor.UpperLeft)
end

function GuardSoulUI.create_guard_list()
    local guard_Bg = _gt.GetUI("soul_page")

    if GUI.GetChild(guard_Bg, "scr_Bg") then
        return ""
    end

    local scr_Bg = GUI.ImageCreate(guard_Bg, "scr_Bg", "1800400010", 63, 40, false, 345, 575)
    UILayout.SetSameAnchorAndPivot(scr_Bg, UILayout.TopLeft)

    local leftTitle_Bg = GUI.ImageCreate(scr_Bg, "leftTitle_Bg", "1800700250", 4, 4)
    UILayout.SetSameAnchorAndPivot(leftTitle_Bg, UILayout.TopLeft)

    local scr_Name = GUI.CreateStatic(leftTitle_Bg, "scr_Name", "我的侍从", 20, 0, 200, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(scr_Name, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_Name, UIDefine.FontSizeS,
            UIDefine.BrownColor)

    local scr_GuardCount = GUI.CreateStatic(leftTitle_Bg, "haveGuardCount", "0/99", 140, 1, 200, 30)
    _gt.BindName(scr_GuardCount, "haveGuardCount")
    UILayout.SetSameAnchorAndPivot(scr_GuardCount, UILayout.Right)
    UILayout.StaticSetFontSizeColorAlignment(scr_GuardCount, UIDefine.FontSizeS, UIDefine.BrownColor)

    -- 创建侍从列表
    local scr_Guard = GUI.LoopScrollRectCreate(scr_Bg, "scr_Guard", 0, 41, 330,
            525, "GuardSoulUI",
            "CreateGuardItemPool",
            "GuardSoulUI",
            "RefreshGuardScroll", 0, false,
            Vector2.New(330, 100), 1,
            UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(scr_Guard, Vector2.New(6, 6))
    _gt.BindName(scr_Guard, "scr_Guard")
    UILayout.SetSameAnchorAndPivot(scr_Guard, UILayout.Top)

    local rightTitle_Bg = GUI.ButtonCreate(scr_Bg, "rightTitle_Bg", "1800700260", -4, 4, Transition.None)
    UILayout.SetSameAnchorAndPivot(rightTitle_Bg, UILayout.TopRight)
    _gt.BindName(rightTitle_Bg, "rightTitle_Bg")
    GUI.RegisterUIEvent(rightTitle_Bg, UCE.PointerClick, "GuardSoulUI", "guard_type_click")

    local pullListBtn = GUI.ImageCreate(rightTitle_Bg, "pullListBtn", "1800707070", 12, 0)
    UILayout.SetSameAnchorAndPivot(pullListBtn, UILayout.Right)
    GUI.SetIsRaycastTarget(pullListBtn, false)

    local scr_GuardType_Txt = GUI.CreateStatic(rightTitle_Bg, "scr_GuardType_Txt", "全部", -15, 0, 200, 30)
    _gt.BindName(scr_GuardType_Txt, "scr_GuardType_Txt")
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Txt, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_GuardType_Txt, UIDefine.FontSizeS, UIDefine.BrownColor)
end

-- 创建左侧侍从滑动列表Btn
function GuardSoulUI.CreateGuardItemPool()
    local scr_Guard = _gt.GetUI("scr_Guard")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scr_Guard)
    local btn = GUI.ButtonCreate(scr_Guard, "item" .. tostring(curCount), "1800700030", 0, 0, Transition.ColorTint, "", 330, 100, false)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardSoulUI", "OnLeftGuardBtnClick")

    local btnSelectImage = GUI.ImageCreate(btn, "btnSelectImage", "1800700040", 0, 0, false, 330, 100)
    GUI.SetVisible(btnSelectImage, false)
    local icon_Bg = GUI.ImageCreate(btn, "icon_Bg", "1800201110", 10, 0)
    UILayout.SetSameAnchorAndPivot(icon_Bg, UILayout.Left)

    local icon = GUI.ImageCreate(icon_Bg, "icon", "", 0, -1, false, 71, 71)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Center)

    -- 侍从名字
    local guardName = GUI.CreateStatic(btn, "guardName", "", 105, 20, 220, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(guardName, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(guardName, UIDefine.FontSizeL, UIDefine.BrownColor)

    -- 侍从类型图
    local guardType_Sprite = GUI.ImageCreate(btn, "guardType_Sprite", "", -8, 5)
    UILayout.SetSameAnchorAndPivot(guardType_Sprite, UILayout.TopRight)

    -- 侍从稀有度
    local guardQuality_Sprite = GUI.ImageCreate(btn, "guardQuality_Sprite", "", 238, 10)
    UILayout.SetSameAnchorAndPivot(guardQuality_Sprite, UILayout.TopLeft)

    -- create six light
    local x = -50
    for i = 1, 6 do
        local circle = GUI.ImageCreate(btn, "soul_circle_img" .. i, "1801719080", x, -20)
        SetSameAnchorAndPivot(circle, UILayout.Bottom)
        x = x + 25
    end

    return btn
end

function GuardSoulUI.create_soul_item_box()
    local guard_Bg = _gt.GetUI("soul_page")

    if GUI.GetChild(guard_Bg, "soul_item_box_bg") then
        return ""
    end

    local scr_Bg = GUI.ImageCreate(guard_Bg, "soul_item_box_bg", "1800400010", 788, 40, false, 345, 575)
    UILayout.SetSameAnchorAndPivot(scr_Bg, UILayout.TopLeft)

    local leftTitle_Bg = GUI.ImageCreate(scr_Bg, "leftTitle_Bg", "1800700250", 4, 4)
    UILayout.SetSameAnchorAndPivot(leftTitle_Bg, UILayout.TopLeft)

    local scr_Name = GUI.CreateStatic(leftTitle_Bg, "scr_Name", "我的命魂", 20, 0, 200, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(scr_Name, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_Name, UIDefine.FontSizeS, UIDefine.BrownColor)

    local scr_GuardCount = GUI.CreateStatic(leftTitle_Bg, "haveSoulCount", "0/0", -5, 1, 140, 30)
    GUI.StaticSetAlignment(scr_GuardCount, TextAnchor.MiddleRight)
    _gt.BindName(scr_GuardCount, "soul_item_box_txt")
    UILayout.SetSameAnchorAndPivot(scr_GuardCount, UILayout.Right)
    UILayout.StaticSetFontSizeColorAlignment(scr_GuardCount, UIDefine.FontSizeS, UIDefine.BrownColor)

    -- create box
    local soul_item_box = GUI.GroupCreate(scr_Bg, "soul_item_box_group", 0, 41, GUI.GetWidth(scr_Bg), 492)
    SetSameAnchorAndPivot(soul_item_box, UILayout.Top)

    GuardSoulUI.create_matrix_box(soul_item_box, 4, 6, quality[1][2])

    local rightTitle_Bg = GUI.ButtonCreate(scr_Bg, "rightTitle_Bg", "1800700260", -4, 4, Transition.None)
    UILayout.SetSameAnchorAndPivot(rightTitle_Bg, UILayout.TopRight)
    _gt.BindName(rightTitle_Bg, "soul_item_box_right_title_bg")
    GUI.RegisterUIEvent(rightTitle_Bg, UCE.PointerClick, "GuardSoulUI", "soul_item_type_click")

    local pullListBtn = GUI.ImageCreate(rightTitle_Bg, "pullListBtn", "1800707070", 12, 0)
    UILayout.SetSameAnchorAndPivot(pullListBtn, UILayout.Right)
    GUI.SetIsRaycastTarget(pullListBtn, false)

    local scr_GuardType_Txt = GUI.CreateStatic(rightTitle_Bg, "scr_GuardType_Txt", "全部", -15, 0, 200, 30)
    _gt.BindName(scr_GuardType_Txt, "soul_item_box_type_txt")
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Txt, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_GuardType_Txt, UIDefine.FontSizeS, UIDefine.BrownColor)

    local sort_check = GUI.GroupCreate(scr_Bg, "sort_check", 0, 2, 343, 45)
    SetSameAnchorAndPivot(sort_check, UILayout.Bottom)

    local level_sort_check = GUI.CheckBoxCreate(sort_check, "soul_item_box_level_sort_check", "1800607150", "1800607151", 7, 7, Transition.None, true, 32, 32)
    SetSameAnchorAndPivot(level_sort_check, UILayout.BottomLeft)
    GUI.RegisterUIEvent(level_sort_check, UCE.PointerClick, "GuardSoulUI", "soul_item_boxes_order_by_level_check_box_click")

    local level_title = GUI.CreateStatic(level_sort_check, "title", "按等级排序", 32, 0, 140, 30)
    GUI.StaticSetFontSize(level_title, UIDefine.FontSizeM)
    GUI.SetColor(level_title, UIDefine.BrownColor)

    local title_btn = GUI.ButtonCreate(level_title, "order_by_level_title_btn", "1800499999", 0, 0, Transition.ColorTint, "", GUI.GetWidth(level_title), GUI.GetHeight(level_title), false)
    SetSameAnchorAndPivot(title_btn, UILayout.Center)
    GUI.RegisterUIEvent(title_btn, UCE.PointerClick, "GuardSoulUI", "soul_item_boxes_order_by_level_check_box_click")

    local type_sort_check = GUI.CheckBoxCreate(sort_check, "soul_item_box_type_sort_check", "1800607150", "1800607151", -121, 6, Transition.None, true, 32, 32)
    SetSameAnchorAndPivot(type_sort_check, UILayout.BottomRight)
    GUI.RegisterUIEvent(type_sort_check, UCE.PointerClick, "GuardSoulUI", "soul_item_boxes_order_by_type_check_box_click")

    local type_title = GUI.CreateStatic(type_sort_check, "title", "按类型排序", -141, 0, 140, 30)
    GUI.StaticSetFontSize(type_title, UIDefine.FontSizeM)
    GUI.SetColor(type_title, UIDefine.BrownColor)

    local type_btn = GUI.ButtonCreate(type_title, "order_by_type_title_btn", "1800499999", 0, 0, Transition.ColorTint, "", GUI.GetWidth(type_title), GUI.GetHeight(type_title), false)
    SetSameAnchorAndPivot(type_btn, UILayout.Center)
    GUI.RegisterUIEvent(type_btn, UCE.PointerClick, "GuardSoulUI", "soul_item_boxes_order_by_type_check_box_click")
end

-- 添加等级品质背景和等级文本
function GuardSoulUI.AddBtn_LevelSp(btn)
    if btn == nil then
        return
    end

    local levelBg = GUI.GetChild(btn, "levelBg")
    if levelBg == nil then
        levelBg = GUI.ImageCreate(btn, "levelBg", _IconRightCornerRes[1], 0, -2) -- 品质图标
        SetAnchorAndPivot(levelBg, UIAnchor.BottomRight, UIAroundPivot.BottomRight)

        local level = GUI.CreateStatic(levelBg, "txt", "", -5, -2, 24, 26) -- 等级文本 待改大小
        SetAnchorAndPivot(level, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetAlignment(level, TextAnchor.MiddleCenter) -- 设置居中
        GUI.StaticSetFontSize(level, UIDefine.FontSizeM)
        GUI.SetOutLine_Color(level, UIDefine.BlackColor)
        GUI.SetOutLine_Distance(level, 1)
        GUI.SetIsOutLine(level, true)
    else
        GUI.SetVisible(levelBg, true)
    end

    return levelBg
end

-- #创建选择装备命魂位置的选择框
function GuardSoulUI.create_select_position_of_equip_soul(item_guid, guard_id)
    local equips_of_soul = {}
    if guard_id and LD.IsHaveGuard(guard_id) then
        local guard_guid = LD.GetGuardGUIDByID(guard_id)
        -- local count = LD.GetItemCount(item_container_type.item_container_guard_equip, guard_guid)
        for i = 0, 5 do
            local guard_equip_data = LD.GetItemDataByIndex(i, item_container_type.item_container_guard_equip, guard_guid)
            equips_of_soul[i] = guard_equip_data
            -- table.insert(equips_of_soul, guard_equip_data)
        end
    else
        return ""
    end

    local item = LD.GetItemDataByGuid(item_guid,
            item_container_type.item_container_guard_equip)
    if item.id == 0 then
        return ""
    end
    local itemDB = DB.GetOnceItemByKey1(item.id)

    -- position data
    local guard_data = DB.GetOnceGuardByKey1(guard_id)
    local position = nil

    if UIDefine.guardSoulEquipSpecialPosition and guard_data.Id ~= 0 then
        local data = UIDefine.guardSoulEquipSpecialPosition[guard_data.Name]
        if data then
            position = data[itemDB.Subtype]
        else
            position = UIDefine.guardSoulEquipPosition[itemDB.Subtype]
        end
    elseif UIDefine.guardSoulEquipPosition then
        position = UIDefine.guardSoulEquipPosition[itemDB.Subtype]
    end

    if position then
        local _position = {}
        for k, v in ipairs(position) do
            _position[v] = true
        end
        position = _position
    end

    local colorTypeTwo = Color.New(162 / 255, 75 / 255, 21 / 255)
    local fontSize_BigTwo = 26

    local panel = GUI.GetWnd("GuardSoulUI")
    local fightChangeUI_BottomBg = GUI.Get("GuardSoulUI/panelBg/fightChangeUI_BottomBg")

    if fightChangeUI_BottomBg ~= nil then
        GUI.Destroy(fightChangeUI_BottomBg)
        fightChangeUI_BottomBg = nil
    end

    if fightChangeUI_BottomBg == nil then
        local panelBg = GUI.Get("GuardSoulUI/panelBg")
        fightChangeUI_BottomBg = GUI.ImageCreate(panelBg, "fightChangeUI_BottomBg", "1800400220", 0, -42, false, GUI.GetWidth(panel), GUI.GetHeight(panel))
        GUI.SetIsRaycastTarget(fightChangeUI_BottomBg, true) -- 是否响应交互事件
        GUI.SetData(fightChangeUI_BottomBg, "guard_id", guard_id)

        local fightChangeUI_Bg = GUI.ImageCreate(fightChangeUI_BottomBg, "fightChangeUI_Bg", "1800001120", 0, 0, false, 465, 280)

        local leftFlower = GUI.ImageCreate(fightChangeUI_Bg, "leftFlower", "1800007060", -20, -20)
        SetAnchorAndPivot(leftFlower, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        local closeBtn = GUI.ButtonCreate(fightChangeUI_Bg, "closeBtn", "1800002050", -10, 10, Transition.ColorTint)
        SetAnchorAndPivot(closeBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
        GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "GuardSoulUI", "OnFightChange_CloseBtnClick")

        local txt = GUI.CreateStatic(fightChangeUI_Bg, "txt", "请从当前列表中选择装备命魂的位置", 0, 35, 380, 52, "system", false, false)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
        GUI.SetColor(txt, Color.New(162 / 255, 75 / 255, 21 / 255))
        SetAnchorAndPivot(txt, UIAnchor.Top, UIAroundPivot.Top)

        local itemIconBg = GUI.ImageCreate(fightChangeUI_Bg, "itemIconBg", "1800400200", 0, 100, false, 440, 105)
        SetAnchorAndPivot(itemIconBg, UIAnchor.Top, UIAroundPivot.Top)
        _gt.BindName(itemIconBg, "GuardLineUp_ItemIconBg")

        -- 当前侍从星级
        local guard_star = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(
                LD.GetGuardGUIDByID(GuardSoulUI.SelectGuardID))) or 1
        guard_star = tonumber(guard_star)
        -- 当前侍从等级
        local guard_level = -- CL.GetIntAttr(RoleAttr.RoleAttrLevel, TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardSoulUI.SelectGuardID))) or 1
        CL.GetIntAttr(RoleAttr.RoleAttrLevel) or 1
        -- 侍从名称
        local gaurd_name = DB.GetOnceGuardByKey1(GuardSoulUI.SelectGuardID).Name

        for i = 0, 5 do
            local itemBtn = GUI.ItemCtrlCreate(itemIconBg, i, "1801719020", 15 + i * 60 + i * 10, 0)
            SetAnchorAndPivot(itemBtn, UIAnchor.Left, UIAroundPivot.Left)
            GUI.RegisterUIEvent(itemBtn, UCE.PointerClick, "GuardSoulUI", "OnFightChangeUI_ItemClick")
            GUI.SetData(itemBtn, "itemGuid", item_guid)
            GUI.SetData(itemBtn, "select_index", i)
            GUI.SetData(itemBtn, "guardId", guard_id)

            local effect = GUI.GetChild(itemBtn, "effect")

            local img = nil
            if equips_of_soul[i] then
                local data = equips_of_soul[i]
                local db = DB.GetOnceItemByKey1(data.id)
                img = GUI.ImageCreate(itemBtn, "mandarin" .. i, db.Icon, 0, 0,
                        false, 60, 60)
                SetSameAnchorAndPivot(img, UILayout.Center)

                -- GUI.ItemCtrlSetElementValue(itemBtn, eItemIconElement.Border, soul_type[db.Subtype][3])
            end

            GUI.ItemCtrlSetElementValue(itemBtn, eItemIconElement.Icon,
                    mandarin_num[i + 1])

            -- 星级条件
            local starCondition = nil
            -- 等级条件
            local levelCondition = nil
            if UIDefine.guardSoulEquipSpecialLevel and
                    UIDefine.guardSoulEquipSpecialLevel[gaurd_name] and
                    UIDefine.guardSoulEquipSpecialLevel[gaurd_name][i + 1] then
                local d = UIDefine.guardSoulEquipSpecialLevel[gaurd_name][i + 1]
                if guard_star >= d.need_star then
                    starCondition = true
                end
                if guard_level >= d.need_level then
                    levelCondition = true
                end
            elseif UIDefine.guardSoulEquipLevel and
                    UIDefine.guardSoulEquipLevel[i + 1] then
                local d = UIDefine.guardSoulEquipLevel[i + 1]
                if guard_star >= d.need_star then
                    starCondition = true
                end
                if guard_level >= d.need_level then
                    levelCondition = true
                end
            end

            if position then
                if starCondition ~= true or levelCondition ~= true then
                    -- 圆圈变灰
                    GUI.ItemCtrlSetIconGray(itemBtn, true)
                    -- 圆圈种繁体数字取消
                    -- local num = GUI.ItemCtrlGetElement(itemBtn,eItemIconElement.Icon)
                    -- GUI.SetVisible(num,false)
                    -- 命魂图标
                    if img then
                        GUI.ImageSetGray(img, true)
                    end
                    -- 锁图片
                    -- >lockImg
                    local lock = GUI.ImageCreate(itemBtn, "lock", "1800400070",
                            0, 0)
                    UILayout.SetSameAnchorAndPivot(lock, UILayout.Center)
                    -- 取消点击事件
                    GUI.UnRegisterUIEvent(itemBtn, UCE.PointerClick,
                            "GuardSoulUI",
                            "OnFightChangeUI_ItemClick")
                    -- 如果是位置不允许
                elseif position[i + 1] == nil then
                    GUI.ItemCtrlSetIconGray(itemBtn, true)
                    if img then
                        GUI.ImageSetGray(img, true)
                    end
                    GUI.UnRegisterUIEvent(itemBtn, UCE.PointerClick,
                            "GuardSoulUI",
                            "OnFightChangeUI_ItemClick")
                else
                    -- 添加转圈特效
                    local effect = GUI.SpriteFrameCreate(itemBtn, "effect", "",
                            0, 0)
                    GUI.SetFrameId(effect, "3403700000")
                    UILayout.SetSameAnchorAndPivot(effect, UILayout.Center)
                    GUI.SpriteFrameSetIsLoop(effect, true)
                    GUI.Play(effect)
                end
            end
        end

        local confirmBtn = GUI.ButtonCreate(fightChangeUI_Bg, "confirmBtn", "1800002010", -30, -25, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_BigTwo .. ">确认</size></color>", 160, 45, false)
        SetAnchorAndPivot(confirmBtn, UIAnchor.BottomRight,
                UIAroundPivot.BottomRight)
        GUI.SetOutLine_Color(confirmBtn, colorTypeTwo)
        GUI.SetOutLine_Distance(confirmBtn, 1)
        GUI.SetIsOutLine(confirmBtn, true)
        GUI.RegisterUIEvent(confirmBtn, UCE.PointerClick, "GuardSoulUI", "OnFightChange_ConfirmBtnClick")

        local concelBtn = GUI.ButtonCreate(fightChangeUI_Bg, "concelBtn", "1800002010", 30, -25, Transition.ColorTint, "<color=#ffffff><size=" .. fontSize_BigTwo .. ">关闭</size></color>", 160, 45, false)
        SetAnchorAndPivot(concelBtn, UIAnchor.BottomLeft, UIAroundPivot.BottomLeft)
        GUI.SetOutLine_Color(concelBtn, colorTypeTwo)
        GUI.SetOutLine_Distance(concelBtn, 1)
        GUI.SetIsOutLine(concelBtn, true)
        GUI.RegisterUIEvent(concelBtn, UCE.PointerClick, "GuardSoulUI", "OnFightChange_CloseBtnClick")
    else
        GUI.SetVisible(fightChangeUI_BottomBg, true)
    end
end

-- #refresh-tab1 --

function GuardSoulUI.refresh_soul_tab_page()
    GuardSoulUI.UpdateGuardLst()

    GuardSoulUI.refresh_model_part()
    GuardSoulUI.GetSkillData_request()

    GuardSoulUI.when_update_soul_items_of_bag()
end

-- 刷新左边侍从列表
function GuardSoulUI.RefreshGuardScroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2])

    local config = DB.GetOnceGuardByKey1(GuardSoulUI.SortedGuardIDLst[index])
    local btn = GUI.GetByGuid(guid)
    if GuardSoulUI.PreSelectGuardBtn == btn then
        GuardSoulUI.PreSelectGuardBtn = nil
    end
    GUI.SetData(btn, "guardID", tostring(config.Id))
    GUI.SetData(btn, "index", tostring(index))
    local pic = GUI.GetChildByPath(btn, "icon_Bg")
    if pic then
        GUI.ImageSetImageID(pic, quality[config.Grade][2])
    end
    local icon = GUI.GetChildByPath(btn, "icon_Bg/icon")
    if icon then
        GUI.ImageSetImageID(icon, tostring(config.Head))
    end
    local guardName = GUI.GetChildByPath(btn, "guardName")
    if guardName then
        GUI.StaticSetText(guardName, config.Name)
    end

    local guardType_Sprite = GUI.GetChildByPath(btn, "guardType_Sprite")
    if guardType_Sprite then
        GUI.ImageSetImageID(guardType_Sprite, guardType[config.Type][2])
    end
    local guardQuality_Sprite = GUI.GetChildByPath(btn, "guardQuality_Sprite")
    if guardQuality_Sprite then
        GUI.ImageSetImageID(guardQuality_Sprite, quality[config.Quality][1])
    end

    local isHave = LD.IsHaveGuard(config.Id)
    GUI.ImageSetGray(icon, not isHave)
    GUI.ImageSetGray(guardType_Sprite, not isHave)
    GUI.ImageSetGray(guardQuality_Sprite, not isHave)
    if GuardSoulUI.SelectGuardID == config.Id then
        GuardSoulUI.PreSelectGuardBtn = btn
        GUI.ButtonSetImageID(btn, "1800700040")
    else
        GUI.ButtonSetImageID(btn, not isHave and "1800700180" or "1800700030")
    end

    if GuardSoulUI.FirstSelectFlag then
        --   删除判断条件  index == 0 and  理由：当我开始就选中第一个时，滚动，刷新到了第0个，就执行这段代码，导致不合我的逻辑
        GuardSoulUI.FirstSelectFlag = false
        GuardSoulUI.OnLeftGuardBtnClick(guid)
    end

    -- refresh six circle
    if GuardSoulUI.guard_minghun_list and
            GuardSoulUI.guard_minghun_list[config.Id] then
        local data = GuardSoulUI.guard_minghun_list[config.Id]
        for i = 1, 6 do
            local circle = GUI.GetChild(btn, "soul_circle_img" .. i)
            if data[i] and data[i] ~= 0 then
                GUI.ImageSetImageID(circle, soul_type[data[i]][3])
            else
                GUI.ImageSetImageID(circle, soul_type[#soul_type][3])
            end
        end
    else
        for i = 1, 6 do
            local circle = GUI.GetChild(btn, "soul_circle_img" .. i)
            GUI.ImageSetImageID(circle, soul_type[#soul_type][3])
        end
    end
end

-- 刷新左边侍从列表部分
function GuardSoulUI.UpdateGuardLst()
    GuardSoulUI.SortedGuardIDLst = LD.GetGuardList_Have_Sorted()
    -- 过滤手动筛选
    if GuardSoulUI.SelectType ~= 0 then
        local SelectGuardIDs = {}
        local Count0 = GuardSoulUI.SortedGuardIDLst.Count
        local index = 0
        for i = 0, Count0 - 1 do
            local config = DB.GetOnceGuardByKey1(GuardSoulUI.SortedGuardIDLst[i])
            if config and config.Type == GuardSoulUI.SelectType then
                SelectGuardIDs[index] = GuardSoulUI.SortedGuardIDLst[i]
                index = index + 1
            end
        end
        SelectGuardIDs.Count = index
        GuardSoulUI.SortedGuardIDLst = {}
        GuardSoulUI.SortedGuardIDLst = SelectGuardIDs
    else
        local txt = _gt.GetUI("scr_GuardType_Txt")
        GUI.StaticSetText(txt, "全部")
    end

    local Count = GuardSoulUI.SortedGuardIDLst.Count
    local scr_Guard = _gt.GetUI("scr_Guard")
    GUI.LoopScrollRectSetTotalCount(scr_Guard, Count)
    GUI.LoopScrollRectRefreshCells(scr_Guard)

    -- 滚动到打开界面就选中侍从的位置
    if GuardSoulUI.guard_id_when_open_page then
        local guardId = GuardSoulUI.guard_id_when_open_page
        local allList = GuardSoulUI.SortedGuardIDLst -- 获取所有的侍从id
        local selected_Guard_Index = 0 -- 传入侍从在所有侍从中的下标
        for i = 0, allList.Count - 1 do
            if allList[i] == guardId then
                selected_Guard_Index = i -- 这里不要加1，不然显示位置刚好在上一格
                break
            end
        end
        GUI.ScrollRectSetNormalizedPosition(scr_Guard, Vector2.New(0,
                selected_Guard_Index /
                        allList.Count))
        GuardSoulUI.guard_id_when_open_page = nil
    end

    -- 更新显示的数量
    GuardSoulUI.ShowHaveGuardInfo()
end

-- 刷新中间模型部分
function GuardSoulUI.refresh_model_part()
    if GuardSoulUI.SelectGuardID == nil then
        return
    end
    local _RoleLstNodeModel = _gt.GetUI("RoleLstNodeModel")
    if _RoleLstNodeModel == nil then
        local model_Bg = _gt.GetUI("model_Bg")
        _RoleLstNodeModel = GUI.RawImageCreate(model_Bg, false, "RoleLstNodeModel", "", 0, -38, 2, false, 392, 392)
        _gt.BindName(_RoleLstNodeModel, "RoleLstNodeModel")
        _RoleLstNodeModel:RegisterEvent(UCE.Drag)
        _RoleLstNodeModel:RegisterEvent(UCE.PointerClick)
        GUI.AddToCamera(_RoleLstNodeModel)
        GUI.RawImageSetCameraConfig(_RoleLstNodeModel, "(0,1.41,2.6),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,10,0.01,1.2,0")
    end

    -- 模型
    local guardDB = DB.GetOnceGuardByKey1(GuardSoulUI.SelectGuardID)
    local _RoleModel = _gt.GetUI("GuardModel")
    if _RoleModel == nil then
        _RoleModel = GUI.RawImageChildCreate(_RoleLstNodeModel, false, "GuardModel" .. tostring(GuardSoulUI.SelectGuardID), "", 0, 666)
        _gt.BindName(_RoleModel, "GuardModel")
        UILayout.SetSameAnchorAndPivot(_RoleModel, UILayout.Center)
        ModelItem.Bind(_RoleModel, guardDB.Model, guardDB.ColorID1, guardDB.ColorID2, eRoleMovement.ATTSTAND_W1)
        _gt.BindName(_RoleModel, "GuardModel" .. tostring(GuardSoulUI.SelectGuardID))
        GUI.BindPrefabWithChild(_RoleLstNodeModel, GUI.GetGuid(_RoleModel))
        GUI.RawImageChildSetModleRotation(_RoleModel, Vector3.New(0, -45, 0))
        GUI.RegisterUIEvent(_RoleModel, ULE.AnimationCallBack, "GuardSoulUI", "OnAnimationCallBack")
    else
        ModelItem.Bind(_RoleModel, guardDB.Model, guardDB.ColorID1, guardDB.ColorID2, eRoleMovement.ATTSTAND_W1)
        GUI.RawImageChildSetModleRotation(_RoleModel, Vector3.New(0, -45, 0))
    end
    -- 添加人物特效
    GuardSoulUI.addRoleEffect()
    GuardSoulUI.PreSelectGuardID = GuardSoulUI.SelectGuardID

    local _ModelClickPic = _gt.GetUI("ModelClickPic")
    if _ModelClickPic == nil then
        _ModelClickPic = GUI.ImageCreate(_RoleLstNodeModel, "ModelClickPic", "1800499999", 0, 0, false, 392, 392)
        _gt.BindName(_ModelClickPic, "ModelClickPic")
        UILayout.SetSameAnchorAndPivot(_ModelClickPic, UILayout.Center)
        GUI.SetIsRaycastTarget(_ModelClickPic, true)
        _ModelClickPic:RegisterEvent(UCE.PointerClick)
        GUI.RegisterUIEvent(_ModelClickPic, UCE.PointerClick, "GuardSoulUI", "OnClickGuardModel")
    end

    local pic = _gt.GetUI("middle_GuardRarity_Sprite")
    if pic then
        GUI.ImageSetImageID(pic, quality[guardDB.Quality][1])
    end
    local pic = _gt.GetUI("middle_GuardType_Sprite")
    if pic then
        GUI.ImageSetImageID(pic, guardType[guardDB.Type][2])
    end

    -- refresh six circle
    local guard_Bg = _gt.GetUI("soul_page")

    local equips_of_soul = {}
    if GuardSoulUI.SelectGuardID then
        local guard_id = GuardSoulUI.SelectGuardID
        if guard_id and LD.IsHaveGuard(guard_id) then
            local guard_guid = LD.GetGuardGUIDByID(guard_id)
            for i = 0, 5 do
                local guard_equip_data = LD.GetItemDataByIndex(i, item_container_type.item_container_guard_equip, guard_guid)
                equips_of_soul[i] = guard_equip_data
            end
        end
    end

    -- 当前侍从星级
    local guard_star = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardSoulUI.SelectGuardID))) or 1
    guard_star = tonumber(guard_star)
    -- 当前侍从等级
    local guard_level = -- CL.GetIntAttr(RoleAttr.RoleAttrLevel, TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardSoulUI.SelectGuardID))) or 1
    CL.GetIntAttr(RoleAttr.RoleAttrLevel) or 1
    -- 侍从名称
    local gaurd_name = DB.GetOnceGuardByKey1(GuardSoulUI.SelectGuardID).Name

    for i = 0, 5 do
        local circle = GUI.GetChild(guard_Bg, "model_soul_circle" .. i + 1)
        local soul_img = GUI.GetChild(circle, "soul_img" .. i + 1)

        -- 选中标记
        local left_select = GUI.GetChild(circle, "left_select")
        if left_select then
            GUI.SetVisible(left_select, false)
        end
        local right_select = GUI.GetChild(circle, "right_select")
        if right_select then
            GUI.SetVisible(right_select, false)
        end

        -- 锁
        local is_show_lock = nil
        local need_level = nil
        local need_star = nil

        if UIDefine.guardSoulEquipSpecialLevel and UIDefine.guardSoulEquipSpecialLevel[gaurd_name] and UIDefine.guardSoulEquipSpecialLevel[gaurd_name][i + 1] then
            local d = UIDefine.guardSoulEquipSpecialLevel[gaurd_name][i + 1]

            if guard_level < d.need_level then
                need_level = d.need_level
                is_show_lock = true
            elseif guard_star < d.need_star then
                need_star = d.need_star
                is_show_lock = true
            end
        elseif UIDefine.guardSoulEquipLevel and UIDefine.guardSoulEquipLevel[i + 1] then
            local d = UIDefine.guardSoulEquipLevel[i + 1]

            if guard_level < d.need_level then
                need_level = d.need_level
                is_show_lock = true
            elseif guard_star < d.need_star then
                need_star = d.need_star
                is_show_lock = true
            end
        end

        local lock = GUI.GetChild(circle, "lock")
        if is_show_lock then
            if lock == nil then
                lock = GUI.ImageCreate(circle, "lock", "1800400070", 0, 0)
                SetSameAnchorAndPivot(lock, UILayout.Center)
            end
            GUI.SetVisible(lock, true)

            GUI.SetData(circle, "need_level", need_level)
            GUI.SetData(circle, "need_star", need_star)
            GUI.RegisterUIEvent(circle, UCE.PointerClick, "GuardSoulUI", "can_not_equip_circle_click")
        else
            if lock then
                GUI.SetVisible(lock, false)
            end
            GUI.UnRegisterUIEvent(circle, UCE.PointerClick, "GuardSoulUI", "can_not_equip_circle_click")
        end

        if equips_of_soul[i] and equips_of_soul[i].id ~= 0 then
            local item_db = DB.GetOnceItemByKey1(equips_of_soul[i].id)
            if soul_img == nil then
                soul_img = GUI.ImageCreate(circle, "soul_img" .. i + 1, item_db.Icon, 1, 1, false, 66, 66)
                SetSameAnchorAndPivot(soul_img, UILayout.Center)
            end
            GUI.ImageSetImageID(soul_img, item_db.Icon)
            GUI.SetVisible(soul_img, true)

            GUI.RegisterUIEvent(circle, UCE.PointerClick, "GuardSoulUI", "equipped_soul_item_click")
            GUI.SetData(circle, "soul_item_guid", tostring(equips_of_soul[i].guid))
            GUI.SetData(circle, "guard_id", GuardSoulUI.SelectGuardID)
            GUI.SetData(circle, "equipped_position", i)
        else
            if soul_img ~= nil then
                GUI.SetVisible(soul_img, false)
            end
            GUI.UnRegisterUIEvent(circle, UCE.PointerClick, "GuardSoulUI", "equipped_soul_item_click")
        end
    end
end

-- 刷新特技部分
function GuardSoulUI.refresh_special_skill(_data)
    -- is show item ctrl

    -- local data = {
    --     img = { icon = "1900352610", border = "1800400110" },
    --     title = "四大行者",
    --     type = "物攻型",
    --     description = "造成物理暴击时，会提高下一次攻击的基础数值20%"
    -- }
    local data = nil

    local is_have_data = nil
    if _data then
        data = _data
        is_have_data = true
    elseif GuardSoulUI.guard_minghun_skill and GuardSoulUI.guard_minghun_skill ~= 0 then
        local skill_db = DB.GetOnceSkillByKey1(GuardSoulUI.guard_minghun_skill)
        if skill_db.Id ~= 0 then
            data = {
                img = {
                    icon = tostring(skill_db.Icon),
                    border = quality[skill_db.SkillQuality][2]
                },
                title = skill_db.Name,
                type = skill_db.DisplayDamageType,
                description = skill_db.Info
            }
            is_have_data = true
        end
    end

    local guard_Bg = _gt.GetUI("soul_page")

    local title_bg = GUI.GetChild(guard_Bg, "title_bg")
    if title_bg then
        local title = GUI.GetChild(title_bg, "special_skill_title")
        if title then
            if is_have_data then
                GUI.StaticSetText(title, "<color=#30aa1dff>已激活特效</color>")
            else
                GUI.StaticSetText(title, "未激活特效")
            end
        end
    end

    local skill_icon = GUI.GetChild(guard_Bg, "special_skill_icon")
    if skill_icon then
        if is_have_data then
            GUI.ItemCtrlSetElementValue(skill_icon, eItemIconElement.Icon, data.img.icon)
            GUI.ItemCtrlSetElementValue(skill_icon, eItemIconElement.Border, data.img.border)
            GUI.SetVisible(skill_icon, true)
        else
            GUI.SetVisible(skill_icon, false)
        end
    end

    local skill_name = GUI.GetChild(guard_Bg, "special_skill_name")
    if skill_name then
        if is_have_data then
            GUI.StaticSetText(skill_name, data.title)
            GUI.SetVisible(skill_name, true)
        else
            GUI.SetVisible(skill_name, false)
        end
    end

    local skill_type = GUI.GetChild(guard_Bg, "special_skill_type")
    if skill_type then
        if is_have_data then
            GUI.StaticSetText(skill_type, data.type .. "型")
            GUI.SetVisible(skill_type, true)
        else
            GUI.SetVisible(skill_type, false)
        end
    end

    local description = GUI.GetChild(guard_Bg, "special_skill_description")
    if description then
        if is_have_data then
            local info = string.gsub(data.description, "\\n", "\n")
            GUI.StaticSetText(description, info)
            GUI.SetVisible(description, true)
        else
            GUI.SetVisible(description, false)
        end
    end

    -- 当未激活时添加未激活字体
    local no_activation_font = GUI.GetChild(guard_Bg, "no_activation_font")
    local gray_brown_color = Color.New(108 / 255, 56 / 255, 18 / 255, 1)
    if no_activation_font == nil then
        no_activation_font = GUI.CreateStatic(guard_Bg, "no_activation_font", "当前未激活特效", 0, -68, 210, 100)
        SetSameAnchorAndPivot(no_activation_font, UILayout.Bottom)
        GUI.StaticSetFontSize(no_activation_font, UIDefine.FontSizeXXL)
        GUI.SetColor(no_activation_font, gray_brown_color)
    end
    if is_have_data then
        GUI.SetVisible(no_activation_font, false)
    else
        GUI.SetVisible(no_activation_font, true)
    end
end

-- 刷新右边命魂物品列表
function GuardSoulUI.refresh_soul_item_box(_data)
    local data = {}

    if _data and next(_data) then
        data = _data
    end

    -- clear matrix_box

    local guard_Bg = _gt.GetUI("soul_page")
    local scr_Bg = GUI.GetChild(guard_Bg, "soul_item_box_bg")
    if scr_Bg == nil then
        test("GuardSoulUI.refresh_soul_item_box(_data)" .. "  出错")
        return
    end

    local matrix_box = GUI.GetChild(scr_Bg, "matrix_box")

    GuardSoulUI.empty_matrix_box(matrix_box, quality[1][2])

    matrix_box = GuardSoulUI.create_matrix_box(scr_Bg, 4, math.ceil(#data / 4), quality[1][2])

    for k, v in ipairs(data) do
        local __data = v

        local box = GUI.GetChild(matrix_box, "box_" .. k)
        GUI.ItemCtrlSetElementValue(box, eItemIconElement.Icon, data[k].icon)
        GUI.ItemCtrlSetElementValue(box, eItemIconElement.Border, quality[__data.grade][2] or "1800400330")

        local level_bg = GuardSoulUI.AddBtn_LevelSp(box)
        -- get item quality
        local item_quality = __data.grade
        if item_quality then
            GUI.ImageSetImageID(level_bg, _IconRightCornerRes[item_quality] or _IconRightCornerRes[#_IconRightCornerRes])
        end

        local level_txt = GUI.GetChild(level_bg, "txt")
        GUI.StaticSetText(level_txt, __data.level)

        -- select the box
        local select_the_box = GUI.GetChild(box, "select_the_box" .. k)
        if select_the_box == nil then
            select_the_box = GUI.ImageCreate(box, "select_the_box" .. k, "1800400280", 0, 0)
            SetSameAnchorAndPivot(select_the_box, UILayout.Center)
            GUI.SetVisible(select_the_box, false)
        end

        -- bind img
        if __data.is_bind then
            local bind_img = GUI.GetChild(box, "bind_img" .. k)
            if bind_img == nil then
                bind_img = GUI.ImageCreate(box, "bind_img" .. k, "1800707120", 0, 0)
                SetSameAnchorAndPivot(bind_img, UILayout.TopLeft)
            end
            GUI.SetVisible(bind_img, true)
        end

        -- click event
        GUI.SetData(box, "index", k)
        GUI.SetData(box, "itemGuid", __data.guid)
        GUI.RegisterUIEvent(box, UCE.PointerClick, "GuardSoulUI", "soul_item_box_one_click_of_soul_page")
    end

end

-- #click-tab1 --

-- 展开侍从类型下拉列表
function GuardSoulUI.guard_type_click()
    local rightTitle_Bg = _gt.GetUI("rightTitle_Bg")
    local scr_GuardType_Bg = GUI.GetChild(rightTitle_Bg, "scr_GuardType_Bg")
    if scr_GuardType_Bg ~= nil then
        GUI.Destroy(scr_GuardType_Bg)
    end
    -- 创建侍从类型按钮选择列表
    scr_GuardType_Bg = GUI.ImageCreate(rightTitle_Bg, "scr_GuardType_Bg", "1800400290", 0, 36, false, 115, 215)
    _gt.BindName(scr_GuardType_Bg, "scr_GuardType_Bg")
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Bg, UILayout.Top)
    GUI.SetVisible(scr_GuardType_Bg, true)
    -- 检测到点击就销毁
    GUI.SetIsRemoveWhenClick(scr_GuardType_Bg, true)

    local childSize_GuardType = Vector2.New(105, 34)
    local scr_GuardType = GUI.ScrollRectCreate(scr_GuardType_Bg, "scr_GuardType", 0, 0, 105, 204, 0, false, childSize_GuardType, UIAroundPivot.Top, UIAnchor.Top)
    UILayout.SetSameAnchorAndPivot(scr_GuardType, UILayout.Center)

    for i = 1, #guardType do
        local btnName = ""
        local index = 0
        if i == 1 then
            btnName = guardType[#guardType][1]
        else
            btnName = guardType[i - 1][1]
        end
        index = i - 1
        local btn = GUI.ButtonCreate(scr_GuardType, i - 1, "1800600100", 0, 0, Transition.ColorTint, btnName, 105, 32, false)
        GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeS)

        GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardSoulUI", "guard_select_one_type_click")
        if not GuardSoulUI.kind_select_data then
            GuardSoulUI.kind_select_data = {}
        end
        GuardSoulUI.kind_select_data[GUI.GetGuid(btn)] = index
    end
end

-- 从侍从类型下拉列表中点击某一个侍从类型
function GuardSoulUI.guard_select_one_type_click(guid)
    if next(GuardSoulUI.kind_select_data) == nil then
        test("function GuardSoulUI.guard_select_one_type_click(guid) 出错")
        return ""
    end

    local index = GuardSoulUI.kind_select_data[guid]
    if index == nil then
        test("function GuardSoulUI.guard_select_one_type_click(guid) 缺少GuardUI.kind_select_data[guid]参数")
        return ""
    end

    GuardSoulUI.FirstSelectFlag = true
    GuardSoulUI.SelectType = tonumber(index)
    GuardSoulUI.UpdateGuardLst()
    -- 关闭选择面板显示
    local scr_GuardType_Txt = _gt.GetUI("scr_GuardType_Txt")
    if scr_GuardType_Txt then
        GUI.StaticSetText(scr_GuardType_Txt, GuardSoulUI.SelectType == 0 and guardType[#guardType][1] or guardType[GuardSoulUI.SelectType][1])
    end
end

-- 模型点击事件
function GuardSoulUI.OnClickGuardModel()
    local model = _gt.GetUI("GuardModel")
    if model then
        GUI.ReplaceWeapon(model, 0, eRoleMovement.PHYATT_W1, 0)
    end
end

function GuardSoulUI.OnLeftGuardBtnClick(guid)
    local btn = GUI.GetByGuid(guid)
    GuardSoulUI.SelectGuardID = tonumber(GUI.GetData(btn, "guardID"))

    if GuardSoulUI.PreSelectGuardID ~= GuardSoulUI.SelectGuardID then
        -- 如果前一次选中侍从ID不等于当前选中的侍从ID
        -- 当前选中对象
        if GuardSoulUI.PreSelectGuardBtn then
            local id = tonumber(GUI.GetData(GuardSoulUI.PreSelectGuardBtn, "guardID")) -- 获取当前按钮存储侍从的ID
            if id and LD.IsHaveGuard(id) then
                GUI.ButtonSetImageID(GuardSoulUI.PreSelectGuardBtn, "1800700030") -- 如果拥有此侍从，修改按钮的颜色
            else
                GUI.ButtonSetImageID(GuardSoulUI.PreSelectGuardBtn, "1800700180")
            end
        end

        if btn then
            GUI.ButtonSetImageID(btn, "1800700040")
            GuardSoulUI.PreSelectGuardBtn = btn
        end
    end

    GuardSoulUI.refresh_model_part()

    -- refresh special skill
    -- need _data parameter
    GuardSoulUI.GetSkillData_request()
end
-- 命魂页签中展开命魂种类下拉列表
function GuardSoulUI.soul_item_type_click()
    local rightTitle_Bg = _gt.GetUI("soul_item_box_right_title_bg")
    local scr_GuardType_Bg = GUI.GetChild(rightTitle_Bg, "scr_GuardType_Bg")
    if scr_GuardType_Bg ~= nil then
        GUI.Destroy(scr_GuardType_Bg)
    end
    -- 创建侍从类型按钮选择列表
    scr_GuardType_Bg = GUI.ImageCreate(rightTitle_Bg, "scr_GuardType_Bg", "1800400290", 0, 36, false, 115, 215)
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Bg, UILayout.Top)
    GUI.SetVisible(scr_GuardType_Bg, true)
    -- 检测到点击就销毁
    GUI.SetIsRemoveWhenClick(scr_GuardType_Bg, true)

    local childSize_GuardType = Vector2.New(105, 34)
    local scr_GuardType = GUI.ScrollRectCreate(scr_GuardType_Bg, "scr_GuardType", 0, 0, 105, 204, 0, false, childSize_GuardType, UIAroundPivot.Top, UIAnchor.Top)
    UILayout.SetSameAnchorAndPivot(scr_GuardType, UILayout.Center)

    for i = 1, #soul_type do
        local btnName = ""
        local index = 0
        if i == 1 then
            btnName = soul_type[#soul_type][1]
        else
            btnName = soul_type[i - 1][1]
        end
        index = i - 1
        local btn = GUI.ButtonCreate(scr_GuardType, i - 1, "1800600100", 0, 0, Transition.ColorTint, btnName, 105, 32, false)
        GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeS)

        GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardSoulUI", "soul_item_select_one_type_click")
        if not GuardSoulUI.soul_item_kind_select_data then
            GuardSoulUI.soul_item_kind_select_data = {}
        end
        GuardSoulUI.soul_item_kind_select_data[GUI.GetGuid(btn)] = index
    end
end
-- 命魂页签中从命魂种类下拉列表中点击某个命魂种类
function GuardSoulUI.soul_item_select_one_type_click(guid, select_soul_type)
    if select_soul_type == nil then
        if next(GuardSoulUI.soul_item_kind_select_data) == nil then
            test(" GuardSoulUI.soul_item_select_one_type_click(guid) 出错")
            return ""
        end

        local index = GuardSoulUI.soul_item_kind_select_data[guid]
        if index == nil then
            test("function GuardSoulUI.soul_item_select_one_type_click(guid) 缺少soul_item_select_one_type_click[guid]参数")
            return ""
        end

        GuardSoulUI.select_soul_type = tonumber(index)
    else
        GuardSoulUI.select_soul_type = select_soul_type
    end
    -- 关闭选择面板显示
    local scr_GuardType_Txt = _gt.GetUI("soul_item_box_type_txt")
    if scr_GuardType_Txt then
        GUI.StaticSetText(scr_GuardType_Txt, GuardSoulUI.select_soul_type == 0 and soul_type[#soul_type][1] or soul_type[GuardSoulUI.select_soul_type][1])
    end

    if GuardSoulUI.soul_items_of_bag then
        local count = nil
        if GuardSoulUI.show_soul_items_box_data then
            GuardSoulUI.show_soul_items_box_data, count = GuardSoulUI.filter_soul_by_type(GuardSoulUI.soul_items_of_bag, GuardSoulUI.select_soul_type)

            local soul_item_box_txt = _gt.GetUI("soul_item_box_txt")
            GUI.StaticSetText(soul_item_box_txt, count .. "/" .. #GuardSoulUI.soul_items_of_bag)

            GuardSoulUI.refresh_soul_item_box(GuardSoulUI.show_soul_items_box_data)
        end
    end
end

-- 命魂页签点击事件
function GuardSoulUI.on_soul_tab_btn_click(guid, need_refresh)
    local index = GuardSoulUI.get_index_of_tabList("soul_page")
    -- prevent repeat click
    if need_refresh ~= true then
        if GuardSoulUI.TabIndex == index then
            UILayout.OnTabClick(GuardSoulUI.TabIndex, tabList)
            return ""
        end
    end

    -- 默认显示属性
    -- GuardSoulUI.TabIndex = 1
    GuardSoulUI.change_page(index)
    -- UILayout.OnTabClick(GuardSoulUI.TabIndex, tabList)

    -- create soul page
    GuardSoulUI.create_guard_list()
    GuardSoulUI.create_model_part()
    GuardSoulUI.create_special_skill()
    GuardSoulUI.create_soul_item_box()

    -- refresh soul page

    -- refresh guard list and model
    GuardSoulUI.SelectType = 0
    GuardSoulUI.FirstSelectFlag = true
    GuardSoulUI.GetData_Main_request()
    -- GuardSoulUI.UpdateGuardLst()

    -- UpdateGuardLst include this, it will run clicking one guard event
    -- refresh special skill
    -- GuardSoulUI.refresh_special_skill(_data)

    -- refresh soul items box

    -- 如果界面已存在 刷新数据 然后刷新界面
    local bg = GUI.GetChild(_gt.GetUI("soul_page"), "soul_item_box_bg")
    if bg ~= nil then
        GuardSoulUI.when_update_soul_items_of_bag()
    end

    if GuardSoulUI.soul_items_of_bag == nil then
        GuardSoulUI.get_bag_soul_items()
    end

    if GuardSoulUI.select_soul_type == nil then
        GuardSoulUI.select_soul_type = 0
        GuardSoulUI.show_soul_items_box_data = GuardSoulUI.soul_items_of_bag

        GuardSoulUI.soul_item_select_one_type_click(nil, GuardSoulUI.select_soul_type)
    end

    if GuardSoulUI.order_type == nil then
        -- default click level_sort_check
        local level_check_box = GUI.GetChild(bg, "soul_item_box_level_sort_check")
        GuardSoulUI.soul_item_boxes_order_by_level_check_box_click(GUI.GetGuid(level_check_box), true)
    end
end

-- #按等级排序
function GuardSoulUI.soul_item_boxes_order_by_level_check_box_click(guid, when_refresh)
    local level_check_box = GUI.GetByGuid(guid)
    local bg = GUI.GetChild(_gt.GetUI("soul_page"), "soul_item_box_bg")
    local level_sort_check = GUI.GetChild(bg, "soul_item_box_level_sort_check")

    -- 关闭旁边的多选框
    local type_check_box = GUI.GetChild(bg, "soul_item_box_type_sort_check")
    GUI.CheckBoxSetCheck(type_check_box, false)

    if when_refresh == nil then
        if GUI.GetName(level_check_box) == "soul_item_box_level_sort_check" then
            if GUI.CheckBoxGetCheck(level_check_box) == false then
                GUI.CheckBoxSetCheck(level_check_box, true)
                return ""
            end
        else
            -- 如果点击的是文本
            if level_sort_check and GUI.CheckBoxGetCheck(level_sort_check) == true then
                return ""
            end
        end
    end

    -- 选中当前的多选框
    if level_sort_check then
        GUI.CheckBoxSetCheck(level_sort_check, true)
    end

    GuardSoulUI.order_type = "level"

    if GuardSoulUI.soul_items_of_bag then
        if GuardSoulUI.show_soul_items_box_data and next(GuardSoulUI.show_soul_items_box_data) then
            table.sort(GuardSoulUI.show_soul_items_box_data, GuardSoulUI.sort_by_level)
        end
    end

    GuardSoulUI.refresh_soul_item_box(GuardSoulUI.show_soul_items_box_data)
end

-- #按类型排序
function GuardSoulUI.soul_item_boxes_order_by_type_check_box_click(guid, when_refresh)
    local type_check_box = GUI.GetByGuid(guid)
    local bg = GUI.GetChild(_gt.GetUI("soul_page"), "soul_item_box_bg")
    local type_sort_check = GUI.GetChild(bg, "soul_item_box_type_sort_check")

    if when_refresh == nil then
        if GUI.GetName(type_check_box) == "soul_item_box_type_sort_check" then
            if GUI.CheckBoxGetCheck(type_check_box) == false then
                GUI.CheckBoxSetCheck(type_check_box, true)
                return ""
            end
        end
    else
        if type_sort_check and GUI.CheckBoxGetCheck(type_sort_check) == true then
            return ""
        end
    end

    local level_check_box = GUI.GetChild(bg, "soul_item_box_level_sort_check")
    GUI.CheckBoxSetCheck(level_check_box, false)

    if type_sort_check then
        GUI.CheckBoxSetCheck(type_sort_check, true)
    end

    GuardSoulUI.order_type = "type"

    if GuardSoulUI.soul_items_of_bag then
        if GuardSoulUI.show_soul_items_box_data and next(GuardSoulUI.show_soul_items_box_data) then
            table.sort(GuardSoulUI.show_soul_items_box_data, GuardSoulUI.sort_by_type)
        end
    end
    GuardSoulUI.refresh_soul_item_box(GuardSoulUI.show_soul_items_box_data)
end

-- #命魂页签命魂格子点击 弹出tips
function GuardSoulUI.soul_item_box_one_click_of_soul_page(guid)
    local btn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(btn, "index"))
    local item_guid = GUI.GetData(btn, "itemGuid")

    if GuardSoulUI.pre_select_item_of_soul_item_box_of_soul_page and GuardSoulUI.pre_select_item_of_soul_item_box_of_soul_page ~= index then
        local matrix_box = GUI.GetParentElement(btn)
        local box = GUI.GetChild(matrix_box, "box_" .. GuardSoulUI.pre_select_item_of_soul_item_box_of_soul_page)
        local select_the_box = GUI.GetChild(box, "select_the_box" .. GuardSoulUI.pre_select_item_of_soul_item_box_of_soul_page)
        GUI.SetVisible(select_the_box, false)
    end

    local select_the_box = GUI.GetChild(btn, "select_the_box" .. index)
    GUI.SetVisible(select_the_box, true)
    GuardSoulUI.pre_select_item_of_soul_item_box_of_soul_page = index

    local panelBg = _gt.GetUI("panelBg")
    local tips = Tips.createSoulTipsByItemGuid(item_guid, panelBg, 0, 0, GuardSoulUI.SelectGuardID)
end

-- #选择装备命魂位置界面的关闭按钮点击
function GuardSoulUI.OnFightChange_CloseBtnClick(key, guid)
    local fightChangeUI_BottomBg = GUI.Get("GuardSoulUI/panelBg/fightChangeUI_BottomBg")
    GUI.Destroy(fightChangeUI_BottomBg)
end

-- #选择装备命魂位置界面
function GuardSoulUI.OnFightChangeUI_ItemClick(guid)
    local fightChangeUI_BottomBg = GUI.Get("GuardSoulUI/panelBg/fightChangeUI_BottomBg")
    local lastSelectGuid = GUI.GetData(fightChangeUI_BottomBg, "lastSelectGuid")

    if lastSelectGuid ~= nil and string.len(lastSelectGuid) > 0 then
        local lastItemIcon = GUI.GetByGuid(lastSelectGuid)

        local left_select = GUI.GetChild(lastItemIcon, "left_select")
        local right_select = GUI.GetChild(lastItemIcon, "right_select")
        GUI.SetVisible(left_select, false)
        GUI.SetVisible(right_select, false)

        -- local itemSelect = GUI.ItemCtrlGetElement(lastItemIcon, eItemIconElement.Selected);
        -- if itemSelect ~= nil then
        --     GUI.SetVisible(itemSelect, false);
        -- end
    end

    local btn = GUI.GetByGuid(guid)
    local left_select = GUI.GetChild(btn, "left_select")
    if left_select == nil then
        GUI.ImageCreate(btn, "left_select", "1801508080", -12, 0, false, 60, 85)
    else
        GUI.SetVisible(left_select, true)
    end

    local right_select = GUI.GetChild(btn, "right_select")
    if right_select == nil then
        GUI.ImageCreate(btn, "right_select", "1801508090", 20, 0, false, 60, 85)
    else
        GUI.SetVisible(right_select, true)
    end

    -- local itemSelect = GUI.ItemCtrlGetElement(btn, eItemIconElement.Selected);
    -- if itemSelect == nil then
    --     GUI.ItemCtrlSetElementValue(btn, eItemIconElement.Selected, "1800600160")
    --     itemSelect = GUI.ItemCtrlGetElement(btn, eItemIconElement.Selected);
    --     GUI.SetHeight(itemSelect, 80);
    --     GUI.SetWidth(itemSelect, 81);
    --     GUI.SetVisible(itemSelect, true);
    -- else
    --     GUI.SetHeight(itemSelect, 80);
    --     GUI.SetWidth(itemSelect, 81);
    --     GUI.SetVisible(itemSelect, true);
    -- end

    local itemGuid = GUI.GetData(btn, "itemGuid")
    local select_index = GUI.GetData(btn, "select_index")
    local guardId = GUI.GetData(btn, "guardId")

    local guard_guid = LD.GetGuardGUIDByID(guardId)

    GUI.SetData(fightChangeUI_BottomBg, "lastSelectGuid", tostring(guid))
    GUI.SetData(fightChangeUI_BottomBg, "selectGuardGuid", itemGuid)
    GUI.SetData(fightChangeUI_BottomBg, "select_index", select_index)

    local currentPositionSoulData = LD.GetItemDataByIndex(select_index, item_container_type.item_container_guard_equip, guard_guid)

    if currentPositionSoulData and currentPositionSoulData.guid then
        local panelBg = _gt.GetUI("panelBg")
        local tips1 = Tips.createSoulTipsByItemGuid(tostring(currentPositionSoulData.guid), panelBg, -438, 0, guardId, select_index, false)
        local tips2 = Tips.createSoulTipsByItemGuid(itemGuid, panelBg, 438, 0, guardId, nil, false)
    end
end

-- #确认按钮点击 选择装备命魂位置界面
function GuardSoulUI.OnFightChange_ConfirmBtnClick(key, guid)
    local fightChangeUI_BottomBg = GUI.Get("GuardSoulUI/panelBg/fightChangeUI_BottomBg")
    local selectGuardGuid = GUI.GetData(fightChangeUI_BottomBg, "selectGuardGuid")
    local select_index = GUI.GetData(fightChangeUI_BottomBg, "select_index")
    local guard_id = GUI.GetData(fightChangeUI_BottomBg, "guard_id")

    if selectGuardGuid == nil or string.len(selectGuardGuid) == 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选择装备命魂的位置！")
        return
    end

    -- send equip request
    GuardSoulUI.FitOutMingHun_request(guard_id, select_index, selectGuardGuid)

    GUI.Destroy(fightChangeUI_BottomBg)
end

-- #6个圆中的已装备的命魂点击
function GuardSoulUI.equipped_soul_item_click(guid)
    local circle_btn = GUI.GetByGuid(guid)
    local btn = circle_btn
    local item_guid = GUI.GetData(circle_btn, "soul_item_guid")
    local guard_id = GUI.GetData(circle_btn, "guard_id")
    local position = GUI.GetData(circle_btn, "equipped_position")

    -- 隐藏上一次选中标记
    if GuardSoulUI.pre_six_circle_select_btn_guid then
        local pre_btn = GUI.GetByGuid(GuardSoulUI.pre_six_circle_select_btn_guid)
        if pre_btn then
            local left_select = GUI.GetChild(pre_btn, "left_select")
            if left_select then
                GUI.SetVisible(left_select, false)
            end
            local right_select = GUI.GetChild(pre_btn, "right_select")
            if right_select then
                GUI.SetVisible(right_select, false)
            end
        end
    end

    -- 显示当前选中标记
    local left_select = GUI.GetChild(btn, "left_select")
    if left_select == nil then
        GUI.ImageCreate(btn, "left_select", "1801508080", -18, 0, false, 60, 85)
    else
        GUI.SetVisible(left_select, true)
    end

    local right_select = GUI.GetChild(btn, "right_select")
    if right_select == nil then
        GUI.ImageCreate(btn, "right_select", "1801508090", 19, 0, false, 60, 85)
    else
        GUI.SetVisible(right_select, true)
    end
    GuardSoulUI.pre_six_circle_select_btn_guid = guid

    local panelBg = _gt.GetUI("panelBg")
    local tips = Tips.createSoulTipsByItemGuid(item_guid, panelBg, 391, 0, guard_id, position)
end

-- 无法装备位置点击事件
function GuardSoulUI.can_not_equip_circle_click(guid)
    local btn = GUI.GetByGuid(guid)
    local need_level = GUI.GetData(btn, "need_level")
    local need_star = GUI.GetData(btn, "need_star")

    if need_level and need_level == "" then
        need_level = nil
    end

    if need_star and need_star == "" then
        need_star = nil
    end

    if need_level and need_star then
        CL.SendNotify(NOTIFY.ShowBBMsg, "侍从达到" .. need_level .. "级" .. "，且达到" .. need_star .. "星开启")
    elseif need_level then
        CL.SendNotify(NOTIFY.ShowBBMsg, "侍从达到" .. need_level .. "级" .. "开启")
    elseif need_star then
        CL.SendNotify(NOTIFY.ShowBBMsg, "侍从达到" .. need_star .. "星" .. "开启")
    else
        test("GuardSoulUI.can_not_equip_circle_click(guid)  无法通过getdata获取节点数据 请检查")
        return ""
    end
end

-- #request-tab1 --
-- get guard list show circle color data
function GuardSoulUI.GetData_Main_request()
    -- server function
    -- FormMingHun.GetData_Main(player)

    -- return data
    -- GuardSoulUI.guard_minghun_list

    -- call back function
    -- GuardSoulUI.GetData_Main_response()

    CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "GetData_Main")
end

-- equip soul
function GuardSoulUI.FitOutMingHun_request(guard_id, index, item_guid)
    -- sever function
    -- 装备命魂  FormMingHun.FitOutMingHun(player,guard_id,index,item_guid)

    -- return data
    -- 对应侍从的GuardSoulUI.guard_minghun_list
    -- 侍从身上装备包裹数据
    -- 特殊技能数据

    -- call back
    -- GuardSoulUI.FitOutMingHun_response()

    CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "FitOutMingHun", tostring(guard_id), tostring(index), tostring(item_guid))
end

-- discharge soul
function GuardSoulUI.DemountMingHun_request(guard_id, index, item_guid)
    -- server function
    -- 卸下命魂  FormMingHun.DemountMingHun(player,guard_id,index)

    -- return data

    -- call back
    -- GuardSoulUI.DemountMingHun_response()

    CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "DemountMingHun", tostring(guard_id), tostring(index), tostring(item_guid))
end

-- get special skill id
function GuardSoulUI.GetSkillData_request()
    -- sever function
    -- FormMingHun.GetSkillData(player,guard_id)  --获取侍从已有的特殊技能id
    -- return data
    -- GuardSoulUI.guard_minghun_skill
    -- call back
    -- GuardSoulUI.GetSkillData_response()

    -- 如果侍从不存在,则不显示技能
    if GuardSoulUI.SelectGuardID and LD.IsHaveGuard(GuardSoulUI.SelectGuardID) ~= true then
        GuardSoulUI.guard_minghun_skill = 0
        GuardSoulUI.refresh_special_skill()
    else
        CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "GetSkillData", tostring(GuardSoulUI.SelectGuardID))
    end
end

-- #response-tab1 --

function GuardSoulUI.GetData_Main_response()
    GuardSoulUI.UpdateGuardLst()
end

function GuardSoulUI.FitOutMingHun_response(index, item_id, guard_id)
    index = index + 1

    if GuardSoulUI.guard_minghun_list then
        local item_db = DB.GetOnceItemByKey1(item_id)
        if GuardSoulUI.guard_minghun_list[guard_id] and GuardSoulUI.guard_minghun_list[guard_id][index] then
            GuardSoulUI.guard_minghun_list[guard_id][index] = item_db.Subtype
        end
    end

    GuardSoulUI.refresh_soul_tab_page()
end

function GuardSoulUI.DemountMingHun_response(index, item_id, guard_id)
    index = index + 1

    if GuardSoulUI.guard_minghun_list then
        if GuardSoulUI.guard_minghun_list[guard_id] and GuardSoulUI.guard_minghun_list[guard_id][index] then
            GuardSoulUI.guard_minghun_list[guard_id][index] = 0
        end
    end

    GuardSoulUI.refresh_soul_tab_page()
end

function GuardSoulUI.GetSkillData_response()
    local data = nil
    if GuardSoulUI.guard_minghun_skill and GuardSoulUI.guard_minghun_skill ~= 0 then
        local skill_db = DB.GetOnceSkillByKey1(GuardSoulUI.guard_minghun_skill)
        if skill_db.Id ~= 0 then
            data = {
                img = {
                    icon = tostring(skill_db.Icon),
                    border = quality[skill_db.SkillQuality][2]
                },
                title = skill_db.Name,
                type = skill_db.DisplayDamageType,
                description = skill_db.Info
            }
        end
    end

    GuardSoulUI.refresh_special_skill(data)
end

--[[
    ========================
    ------------  强化页签  -------------
    ========================
]]
-- >create-tab2--

-- reinforced part
-- 创建左边
function GuardSoulUI.create_soul_list()
    local reinforced_page = _gt.GetUI("reinforced_page")

    if GUI.GetChild(reinforced_page, "scr_Bg") then
        return ""
    end

    -- create two button 亮1800402031
    local in_equipment_btn = GUI.ButtonCreate(reinforced_page, "in_equipment_btn", "1800402031", 63, 47, Transition.ColorTint, "", 173, 46, false)
    SetSameAnchorAndPivot(in_equipment_btn, UILayout.TopLeft)
    GUI.RegisterUIEvent(in_equipment_btn, UCE.PointerClick, "GuardSoulUI", "in_equipment_btn_click")

    local txt = GUI.CreateStatic(in_equipment_btn, "txt", "装备中", 0, 0, GUI.GetWidth(in_equipment_btn), GUI.GetHeight(in_equipment_btn))
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)

    local in_knapsack_btn = GUI.ButtonCreate(reinforced_page, "in_knapsack_btn", "1800402030", 235, 47, Transition.ColorTint, "", 173, 46, false)
    SetSameAnchorAndPivot(in_knapsack_btn, UILayout.TopLeft)
    GUI.RegisterUIEvent(in_knapsack_btn, UCE.PointerClick, "GuardSoulUI", "in_knapsack_btn_click")

    local txt = GUI.CreateStatic(in_knapsack_btn, "txt", "背包中", 0, 0, GUI.GetWidth(in_knapsack_btn), GUI.GetHeight(in_knapsack_btn))
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)

    local scr_Bg = GUI.ImageCreate(reinforced_page, "scr_Bg", "1800400010", 63, 90, false, 345, 527)
    UILayout.SetSameAnchorAndPivot(scr_Bg, UILayout.TopLeft)

    local leftTitle_Bg = GUI.ImageCreate(scr_Bg, "leftTitle_Bg", "1800700250", 4, 4)
    UILayout.SetSameAnchorAndPivot(leftTitle_Bg, UILayout.TopLeft)

    local scr_Name = GUI.CreateStatic(leftTitle_Bg, "scr_Name", "筛选类型：", 20, 0, 200, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(scr_Name, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_Name, UIDefine.FontSizeS, UIDefine.BrownColor)

    local scr_GuardCount = GUI.CreateStatic(leftTitle_Bg, "haveGuardCount", "全部", 70, 0, 200, 30)
    _gt.BindName(scr_GuardCount, "reinforced_page_haveGuardCount")
    UILayout.SetSameAnchorAndPivot(scr_GuardCount, UILayout.Right)
    UILayout.StaticSetFontSizeColorAlignment(scr_GuardCount, UIDefine.FontSizeS, UIDefine.BrownColor)

    -- 创建侍从列表
    local scr_Guard = GUI.LoopScrollRectCreate(scr_Bg, "scr_Guard", 0, 41, GUI.GetWidth(scr_Bg) - 15, GUI.GetHeight(scr_Bg) - 50,
            "GuardSoulUI",
            "create_soul_list_scroll",
            "GuardSoulUI",
            "refresh_soul_list_scroll", 0,
            false, Vector2.New(330, 100), 1,
            UIAroundPivot.Top, UIAnchor.Top)
    GUI.ScrollRectSetChildSpacing(scr_Guard, Vector2.New(6, 6))
    _gt.BindName(scr_Guard, "reinforced_page_scr_Guard")
    UILayout.SetSameAnchorAndPivot(scr_Guard, UILayout.Top)

    local rightTitle_Bg = GUI.ButtonCreate(scr_Bg, "rightTitle_Bg", "1800700260", -4, 4, Transition.None)
    UILayout.SetSameAnchorAndPivot(rightTitle_Bg, UILayout.TopRight)
    _gt.BindName(rightTitle_Bg, "reinforced_page_rightTitle_Bg")
    GUI.RegisterUIEvent(rightTitle_Bg, UCE.PointerClick, "GuardSoulUI", "soul_list_type_click")

    local pullListBtn = GUI.ImageCreate(rightTitle_Bg, "pullListBtn", "1800707070", 12, 0)
    UILayout.SetSameAnchorAndPivot(pullListBtn, UILayout.Right)
    GUI.SetIsRaycastTarget(pullListBtn, false)

    local scr_GuardType_Txt = GUI.CreateStatic(rightTitle_Bg, "scr_GuardType_Txt", "全部", -15, 0, 200, 30)
    _gt.BindName(scr_GuardType_Txt, "reinforced_page_scr_GuardType_Txt")
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Txt, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_GuardType_Txt, UIDefine.FontSizeS, UIDefine.BrownColor)
end
-- 中间
function GuardSoulUI.create_soul_up_level_and_detail()
    local reinforced_page = _gt.GetUI("reinforced_page")

    if GUI.GetChild(reinforced_page, "soul_up_level_bg") then
        return ""
    end

    local up_level_bg = GUI.GroupCreate(reinforced_page, "soul_up_level_bg", 0, -22, 390, 570)
    SetSameAnchorAndPivot(up_level_bg, UILayout.Bottom)

    -- up circle
    local itemBg = GUI.ImageCreate(up_level_bg, "itemBg", "1801719040", 0, -20) -- 碎片背景
    SetAnchorAndPivot(itemBg, UIAnchor.Top, UIAroundPivot.Top)

    local unMax = GUI.GroupCreate(itemBg, "unMax", 0, 0, GUI.GetWidth(itemBg), GUI.GetHeight(itemBg))
    _gt.BindName(unMax, "unMax_UpStar")
    SetAnchorAndPivot(unMax, UIAnchor.Center, UIAroundPivot.Center)

    -- local bg = GUI.ImageCreate(unMax, "bg", "1800700020", 0, 0, false, 78, 78) -- 空正方形框
    -- SetAnchorAndPivot(bg, UIAnchor.Center, UIAroundPivot.Center)

    local itemIcon = GUI.ItemCtrlCreate(unMax, "itemIcon", "1800600050", 0, 0, 80, 85, false) -- 空正方形框
    SetAnchorAndPivot(itemIcon, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(itemIcon, "headItemIcon_UpStar")
    GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "1900000000") -- 问号正方形框
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "GuardSoulUI", "willIntensifySoulClick")

    local icon = GUI.ItemCtrlGetElement(itemIcon, eItemIconElement.Icon)
    GUI.SetVisible(icon, false)
    GUI.SetWidth(icon, 71)
    GUI.SetHeight(icon, 70)

    local sliderBg = GUI.ImageCreate(unMax, "sliderBg", "1801719060", 0, 0) -- 空心圈
    SetAnchorAndPivot(sliderBg, UIAnchor.Center, UIAroundPivot.Center)
    _gt.BindName(sliderBg, "sliderBg_UpStar")

    local slider1 = GUI.ImageCreate(sliderBg, "slider", "1801719070", 0, 0) -- 实心圈
    SetAnchorAndPivot(slider1, UIAnchor.Center, UIAroundPivot.Center)
    GUI.ImageSetType(slider1, SpriteType.Filled)
    GUI.SetImageFillMethod(slider1, SpriteFillMethod.Radial360_Bottom)
    GUI.SetImageFillAmount(slider1, 0)
    local color = Color.New(18 / 255, 199 / 255, 54 / 255, 132 / 255)
    GUI.SetColor(slider1, color)

    local slider2 = GUI.ImageCreate(sliderBg, "slider2", "1801719070", 0, 0) -- 实心圈
    SetAnchorAndPivot(slider2, UIAnchor.Center, UIAroundPivot.Center)
    GUI.ImageSetType(slider2, SpriteType.Filled)
    GUI.SetImageFillMethod(slider2, SpriteFillMethod.Radial360_Bottom)
    GUI.SetImageFillAmount(slider2, 0)

    local sliderValue = GUI.CreateStatic(sliderBg, "sliderValue", "111", 0, 57,
            172, 30, "system", true)
    SetAnchorAndPivot(sliderValue, UIAnchor.Bottom, UIAroundPivot.Bottom)
    GUI.StaticSetText(sliderValue, "Lv.66" .. "<color=#05ab4f>(+" .. 1 .. ")</color>")
    GUI.StaticSetAlignment(sliderValue, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(sliderValue, UIDefine.FontSizeL)
    GUI.SetColor(sliderValue, UIDefine.BrownColor)

    -- 经验显示
    local exp_bg = GUI.ImageCreate(sliderBg, "exp_bg", "1800400740", 0, -11, false, 200, 28)
    SetSameAnchorAndPivot(exp_bg, UILayout.Bottom)

    local width = GUI.GetWidth(exp_bg)
    local height = GUI.GetHeight(exp_bg)
    local show_experience = GUI.CreateStatic(exp_bg, "experience", "0/0", 0, 0, width, height, "system", true)
    SetSameAnchorAndPivot(show_experience, UILayout.Center)
    GUI.StaticSetAlignment(show_experience, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(show_experience, UIDefine.FontSizeSS)

    -- up level attribute txt
    local up_attribute_bg = GUI.ImageCreate(up_level_bg, "up_attribute_bg", "1801200030", 0, 150, false, GUI.GetWidth(up_level_bg), 80)
    SetSameAnchorAndPivot(up_attribute_bg, UILayout.Bottom)

    local static_txt = GUI.CreateStatic(up_attribute_bg, "static_txt", "升级预览", 0, 0, 100, 50) -- 基础属性
    SetSameAnchorAndPivot(static_txt, UILayout.Top)
    GUI.StaticSetAlignment(static_txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(static_txt, UIDefine.FontSizeM)
    GUI.SetColor(static_txt, UIDefine.BrownColor)

    local primary_attr = GUI.CreateStatic(up_attribute_bg, "primary_attr", "物攻 <color=#aa7830ff>0</color>", 30, 10, 150, 50, "system", true)
    SetSameAnchorAndPivot(primary_attr, UILayout.BottomLeft)
    GUI.StaticSetAlignment(primary_attr, TextAnchor.LowerLeft)
    GUI.StaticSetFontSize(primary_attr, UIDefine.FontSizeM)
    GUI.SetColor(primary_attr, UIDefine.BrownColor)

    local arrow_img = GUI.ImageCreate(up_attribute_bg, "arrow_img", "1801507230", 0, 40, false, 35, 35)
    SetSameAnchorAndPivot(arrow_img, UILayout.Bottom)
    GUI.SetEulerAngles(arrow_img, Vector3.New(0, 0, 180))

    local up_level_attr = GUI.CreateStatic(up_attribute_bg, "up_level_attr", "物攻 <color=#30aa1dff>0</color>", 0, 10, 150, 50, "system", true)
    SetSameAnchorAndPivot(up_level_attr, UILayout.BottomRight)
    GUI.StaticSetAlignment(up_level_attr, TextAnchor.LowerLeft)
    GUI.StaticSetFontSize(up_level_attr, UIDefine.FontSizeM)
    GUI.SetColor(up_level_attr, UIDefine.BrownColor)

    -- baptized page attribute txt
    local baptized_attribute_bg = GUI.ImageCreate(up_level_bg, "baptized_attribute_bg", "1800400210", 0, -90, false, GUI.GetWidth(up_level_bg), 35)
    SetSameAnchorAndPivot(baptized_attribute_bg, UILayout.Center)

    local static_txt = GUI.CreateStatic(baptized_attribute_bg, "static_txt", "基础属性：", -38, 0, 115, 50)
    SetSameAnchorAndPivot(static_txt, UILayout.Center)
    GUI.StaticSetAlignment(static_txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(static_txt, UIDefine.FontSizeM)
    GUI.SetColor(static_txt, UIDefine.BrownColor)

    local up_level_attr = GUI.CreateStatic(baptized_attribute_bg, "up_level_attr", "物攻 <color=#aa7830ff>0</color>", 90, 0, 150, 50, "system", true)
    SetSameAnchorAndPivot(up_level_attr, UILayout.Center)
    GUI.StaticSetAlignment(up_level_attr, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(up_level_attr, UIDefine.FontSizeM)
    GUI.SetColor(up_level_attr, UIDefine.BrownColor)

    -- additional attribute txt
    local add_attr_group = GUI.GroupCreate(up_level_bg, "add_attr_group", 0, 0, GUI.GetWidth(up_level_bg), 148)
    SetSameAnchorAndPivot(add_attr_group, UILayout.Bottom)

    local leftPartingLine = GUI.ImageCreate(add_attr_group, "leftPartingLine", "1800700150", -15, -10, false, 165, 20)
    SetSameAnchorAndPivot(leftPartingLine, UILayout.TopLeft)

    local additionalStaticTxt = GUI.CreateStatic(add_attr_group, "additionalStaticTxt", "附加属性", 0, 30, 100, 100)
    SetSameAnchorAndPivot(additionalStaticTxt, UILayout.Top)
    GUI.StaticSetFontSize(additionalStaticTxt, UIDefine.FontSizeM)
    GUI.SetColor(additionalStaticTxt, UIDefine.BrownColor)
    GUI.StaticSetAlignment(additionalStaticTxt, TextAnchor.MiddleCenter)

    local rightPartingLine = GUI.ImageCreate(add_attr_group, "rightPartingLine", "1800700290", 15, -10, false, 165, 20)
    SetSameAnchorAndPivot(rightPartingLine, UILayout.TopRight)

    -- 将附加属性改成scrollrect，支持超出六个属性的配置
    local childSize_GuardType = Vector2.New(185, 33) -- y 35
    local bottomScroll = GUI.ScrollRectCreate(add_attr_group, "bottomScroll", 5, 0, 379, 119, 0, false, childSize_GuardType, UIAroundPivot.Top, UIAnchor.Top, 2)
    UILayout.SetSameAnchorAndPivot(bottomScroll, UILayout.Bottom)
    for i = 1, 6 do
        local additionalAttribute = GUI.CreateStatic(bottomScroll, "additionalAttribute" .. i, "气血 " .. "<color=#aa7830ff>+0</color>", 0, 0, 185, 35, "system", true)
        SetSameAnchorAndPivot(additionalAttribute, UILayout.Top)
        GUI.StaticSetFontSize(additionalAttribute, UIDefine.FontSizeSS)
        GUI.SetColor(additionalAttribute, UIDefine.BrownColor)
        GUI.StaticSetAlignment(additionalAttribute, TextAnchor.LowerLeft)
    end

end
-- 右边
function GuardSoulUI.create_soul_reinforce_and_baptize_btn_and_bg()
    local reinforced_page = _gt.GetUI("reinforced_page")

    local reinforced_and_baptized_bg = GUI.GetChild(reinforced_page, "reinforced_and_baptized_bg")
    if reinforced_and_baptized_bg then
        return ""
    end

    -- create two button 亮1800402031
    local reinforced_btn = GUI.ButtonCreate(reinforced_page, "reinforced_btn", "1800402031", -235, 47, Transition.ColorTint, "", 173, 46, false)
    SetSameAnchorAndPivot(reinforced_btn, UILayout.TopRight)
    GUI.RegisterUIEvent(reinforced_btn, UCE.PointerClick, "GuardSoulUI", "reinforced_btn_click")

    local txt = GUI.CreateStatic(reinforced_btn, "txt", "命魂强化", 0, 0, GUI.GetWidth(reinforced_btn), GUI.GetHeight(reinforced_btn))
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)

    local baptized_btn = GUI.ButtonCreate(reinforced_page, "baptized_btn", "1800402030", -63, 47, Transition.ColorTint, "", 173, 46, false)
    SetSameAnchorAndPivot(baptized_btn, UILayout.TopRight)
    GUI.RegisterUIEvent(baptized_btn, UCE.PointerClick, "GuardSoulUI", "baptized_btn_click")

    local txt = GUI.CreateStatic(baptized_btn, "txt", "命魂洗炼", 0, 0, GUI.GetWidth(baptized_btn), GUI.GetHeight(baptized_btn))
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)

    local scr_Bg = GUI.ImageCreate(reinforced_page, "reinforced_and_baptized_bg", "1800400010", -65, 90, false, 345, 527)
    UILayout.SetSameAnchorAndPivot(scr_Bg, UILayout.TopRight)
    _gt.BindName(scr_Bg, "reinforced_and_baptized_bg")
end
-- 命魂强化二级页签页面
function GuardSoulUI.create_reinforced_box()
    local bg = _gt.GetUI("reinforced_and_baptized_bg")

    local group = GUI.GetChild(bg, "reinforced_group")
    if group then
        return ""
    end

    group = GUI.GroupCreate(bg, "reinforced_group", 0, 0, GUI.GetWidth(bg), GUI.GetHeight(bg))

    local img = GUI.ImageCreate(group, "choice_material_txt_bg", "1801401060", -12, 5, false, 200, 36)
    SetSameAnchorAndPivot(img, UILayout.TopLeft)

    local txt = GUI.CreateStatic(img, "txt", "材料选择", 5, 0, 200, 36)
    SetSameAnchorAndPivot(txt, UILayout.Left)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)

    local material_box_group = GUI.GroupCreate(group, "material_box_group", 0, 47, GUI.GetWidth(group), 415)
    SetSameAnchorAndPivot(material_box_group, UILayout.Top)
    GuardSoulUI.create_matrix_box(material_box_group, 4, 6, quality[1][2])

    local filter_and_eat_soul_group = GUI.GroupCreate(group, "filter_and_eat_soul_group", 0, -4, GUI.GetWidth(group), 55)
    SetSameAnchorAndPivot(filter_and_eat_soul_group, UILayout.Bottom)

    local txt = GUI.CreateStatic(filter_and_eat_soul_group, "select_txt", "选中", 15, 10, 100, 40)
    SetSameAnchorAndPivot(txt, UILayout.BottomLeft)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)

    local select_type_btn = GUI.ButtonCreate(filter_and_eat_soul_group, "select_type_btn", "1800201150", -55, 15, Transition.ColorTint, "", 100, 35, false)
    SetSameAnchorAndPivot(select_type_btn, UILayout.Bottom)
    GUI.RegisterUIEvent(select_type_btn, UCE.PointerClick, "GuardSoulUI", "soul_material_type_select_btn_click")

    local txt = GUI.CreateStatic(select_type_btn, "txt", "全部", 5, 0, 100, 40)
    SetSameAnchorAndPivot(txt, UILayout.Left)
    _gt.BindName(txt, "reinforced_page_select_type_btn_txt")
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
    GUI.SetColor(txt, UIDefine.BrownColor)

    local img = GUI.ImageCreate(select_type_btn, "img", "1800707070", -10, 0)
    SetSameAnchorAndPivot(img, UILayout.Right)

    local eat_soul_btn = GUI.ButtonCreate(filter_and_eat_soul_group, "eat_soul_btn", "1800402031", -10, 10, Transition.ColorTint, "吞噬命魂", 150, 46, false)
    SetSameAnchorAndPivot(eat_soul_btn, UILayout.BottomRight)
    GUI.ButtonSetTextFontSize(eat_soul_btn, UIDefine.FontSizeM)
    GUI.ButtonSetTextColor(eat_soul_btn, UIDefine.BrownColor)
    GUI.RegisterUIEvent(eat_soul_btn, UCE.PointerClick, "GuardSoulUI", "eat_soul_btn_click")
    GUI.SetEventCD(eat_soul_btn, UCE.PointerClick, 1)
end

-- #创建洗炼界面
function GuardSoulUI.create_baptized_page()
    local bg = _gt.GetUI("reinforced_and_baptized_bg")

    if GUI.GetChild(bg, "baptized_group") then
        return ""
    end

    local group = GUI.GroupCreate(bg, "baptized_group", 0, 0, GUI.GetWidth(bg), GUI.GetHeight(bg))
    bg = group

    local leftTitle_Bg = GUI.ImageCreate(bg, "leftTitle_Bg", "1800700250", -4, 4)
    UILayout.SetSameAnchorAndPivot(leftTitle_Bg, UILayout.TopLeft)

    local scr_Name = GUI.CreateStatic(leftTitle_Bg, "scr_Name", "副属性类型", 20, 0, 200, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(scr_Name, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_Name, UIDefine.FontSizeS, UIDefine.BrownColor)

    local rightTitle_Bg = GUI.ButtonCreate(bg, "rightTitle_Bg", "1800700260", 4, 4, Transition.None)
    UILayout.SetSameAnchorAndPivot(rightTitle_Bg, UILayout.TopRight)

    local scr_GuardType_Txt = GUI.CreateStatic(rightTitle_Bg, "scr_GuardType_Txt", "锁定", -30, 0, 200, 30)
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Txt, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(scr_GuardType_Txt, UIDefine.FontSizeS, UIDefine.BrownColor)

    local brown_color = Color.New(174 / 255, 120 / 255, 55 / 255, 1)

    local childSize_GuardType = Vector2.New(GUI.GetWidth(bg) - 10, 40)
    local deputy_properties_Scroll = GUI.ScrollRectCreate(bg, "deputy_properties_Scroll", 0, 40, GUI.GetWidth(bg), 270, 0, false, childSize_GuardType, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(deputy_properties_Scroll, "deputy_properties_Scroll")

    for i = 1, 6 do
        local property_bg = GUI.ImageCreate(deputy_properties_Scroll, "deputy_property_bg" .. i, "1801401270", 0, 0, false, GUI.GetWidth(deputy_properties_Scroll) - 10, 40)

        local txt = GUI.CreateStatic(property_bg, "txt", "气血+0(0-0)", -10, 0, 271, GUI.GetHeight(property_bg), "system")
        SetSameAnchorAndPivot(txt, UILayout.Left)
        GUI.StaticSetFontSize(txt, 19) -- UIDefine.FontSizeS -1
        GUI.SetColor(txt, brown_color)
        GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
        _gt.BindName(txt, "deputy_property_" .. i)

        local check_box = GUI.CheckBoxExCreate(property_bg, "check_box", "1800607150", "1800607151", 27, 0, false, 28, 28)
        SetSameAnchorAndPivot(check_box, UILayout.Right)
        GUI.SetData(check_box, "index", i)
        GUI.RegisterUIEvent(check_box, UCE.PointerClick, "GuardSoulUI", "deputy_property_check_box_click")
    end

    local img = GUI.ImageCreate(bg, "choice_material_txt_bg", "1801401060", -8, 68, false, 200, 36)
    SetSameAnchorAndPivot(img, UILayout.Left)

    local txt = GUI.CreateStatic(img, "txt", "材料选择", 5, 0, 200, 36)
    SetSameAnchorAndPivot(txt, UILayout.Left)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)

    -- x 40
    local material_group = GUI.GroupCreate(bg, "material_group", 0, -57, GUI.GetWidth(bg), 115)
    SetSameAnchorAndPivot(material_group, UILayout.Bottom)

    -- create three itemCtrl
    -- x 0
    local x = 64
    for i = 1, 3 do
        local material = GUI.ItemCtrlCreate(material_group, "material" .. i, quality[1][2], x, 0, 80, 80, false)
        SetSameAnchorAndPivot(material, UILayout.TopLeft)
        -- add tips event
        GUI.RegisterUIEvent(material, UCE.PointerClick, "GuardSoulUI", "baptize_material_click")

        local txt = GUI.CreateStatic(material_group, "material_name" .. i, "道具名", x + 9, 0, 100, 40, "system")
        GUI.SetColor(txt, UIDefine.BrownColor)
        GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
        SetSameAnchorAndPivot(txt, UILayout.BottomLeft)

        if i == 2 then
            GUI.SetVisible(material, false)
            GUI.SetVisible(txt, false)
        end
        -- 90
        x = x + 70
    end

    local two_btn_group = GUI.GroupCreate(bg, "two_btn_group", -57, 43, GUI.GetWidth(bg), 50)
    SetSameAnchorAndPivot(two_btn_group, UILayout.Bottom)

    -- create two button
    local reinforced_btn = GUI.ButtonCreate(two_btn_group, "reinforced_btn", "1800402050", -235, 47, Transition.ColorTint, "", 153, 46, false)
    SetSameAnchorAndPivot(reinforced_btn, UILayout.TopRight)
    GUI.RegisterUIEvent(reinforced_btn, UCE.PointerClick, "GuardSoulUI", "keep_deputy_property_btn_click")

    local txt = GUI.CreateStatic(reinforced_btn, "txt", "保存", 0, 0, GUI.GetWidth(reinforced_btn), GUI.GetHeight(reinforced_btn))
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)

    local baptized_btn = GUI.ButtonCreate(two_btn_group, "baptized_btn", "1800402040", -63, 47, Transition.ColorTint, "", 153, 46, false)
    SetSameAnchorAndPivot(baptized_btn, UILayout.TopRight)
    GUI.RegisterUIEvent(baptized_btn, UCE.PointerClick, "GuardSoulUI", "baptized_btn_click_to_change_property")

    local txt = GUI.CreateStatic(baptized_btn, "txt", "洗炼", 0, 0, GUI.GetWidth(baptized_btn), GUI.GetHeight(baptized_btn))
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)
end

-- 创建左边装备中/背包中按钮下的物品列表
function GuardSoulUI.create_soul_list_scroll()
    local scr_Guard = _gt.GetUI("reinforced_page_scr_Guard")
    local curCount = GUI.LoopScrollRectGetChildInPoolCount(scr_Guard)
    local btn = GUI.ButtonCreate(scr_Guard, "item" .. tostring(curCount), "1800700030", 0, 0, Transition.ColorTint, "", 330, 100, false)
    GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardSoulUI", "soul_list_scroll_one_btn_click")

    local btnSelectImage = GUI.ImageCreate(btn, "btnSelectImage", "1800700040", 0, 0, false, 330, 100)
    GUI.SetVisible(btnSelectImage, false)

    local icon_Bg = GUI.ImageCreate(btn, "icon_Bg", "1800201110", 10, 0)
    UILayout.SetSameAnchorAndPivot(icon_Bg, UILayout.Left)

    local icon = GUI.ImageCreate(icon_Bg, "icon", "1900014630", 0, -1, false, 71, 71)
    UILayout.SetSameAnchorAndPivot(icon, UILayout.Center)

    local levelBg = GUI.ImageCreate(icon_Bg, "levelBg", _IconRightCornerRes[1], 0, 0) -- 品质图标
    SetAnchorAndPivot(levelBg, UIAnchor.BottomRight, UIAroundPivot.BottomRight)

    local level = GUI.CreateStatic(levelBg, "txt", "8", -3, 0, 24, 26) -- 等级文本 待改大小
    SetAnchorAndPivot(level, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetAlignment(level, TextAnchor.MiddleCenter) -- 设置居中
    GUI.StaticSetFontSize(level, UIDefine.FontSizeM)
    GUI.SetOutLine_Color(level, UIDefine.BlackColor)
    GUI.SetOutLine_Distance(level, 1)
    GUI.SetIsOutLine(level, true)

    local bind_img = GUI.ImageCreate(icon_Bg, "bind_img", "1800707120", 0, 0)
    SetSameAnchorAndPivot(bind_img, UILayout.TopLeft)

    -- 侍从名字
    local guardName = GUI.CreateStatic(btn, "guardName", "致命猛攻", 105, 20, 220, 30, "system", true)
    UILayout.SetSameAnchorAndPivot(guardName, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(guardName, UIDefine.FontSizeL, UIDefine.BrownColor)

    local add_property = GUI.CreateStatic(btn, "add_property", "+法攻95", 103, 50, 220, 30, "system")
    GUI.SetColor(add_property, Color.New(174 / 255, 120 / 255, 55 / 255, 1))
    GUI.StaticSetFontSize(add_property, UIDefine.FontSizeS)
    SetSameAnchorAndPivot(add_property, UILayout.TopLeft)

    -- 侍从类型图
    -- local guardType_Sprite = GUI.ImageCreate(btn, "guardType_Sprite", '', -8, 5)
    -- UILayout.SetSameAnchorAndPivot(guardType_Sprite, UILayout.TopRight)

    -- 侍从稀有度
    local guardQuality_Sprite = GUI.ImageCreate(btn, "guardQuality_Sprite", soul_type[1][2], 238, 10)
    UILayout.SetSameAnchorAndPivot(guardQuality_Sprite, UILayout.TopLeft)

    local UserIcon = GUI.ImageCreate(btn, "UserIcon", "1900000000", 138, 20, false, 26, 26)
    GUI.SetVisible(UserIcon, true)

    return btn
end

-- >refresh-tab2--
-- 刷新强化页签中左边装备中/背包中按钮下的命魂物品列表
function GuardSoulUI.refresh_soul_list_scroll(parameter)
    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1

    if GuardSoulUI.show_soul_list_data_of_reinforce_page == nil then
        return ""
    end

    local btn = GUI.GetByGuid(guid)
    local data = GuardSoulUI.show_soul_list_data_of_reinforce_page[index]

    if data == nil then
        test("GuardSoulUI.refresh_soul_list_scroll(parameter) GuardSoulUI.show_soul_list_data_of_reinforce_page[index] == nil")
        return ""
    end

    GUI.SetData(btn, "index", index)
    GUI.SetData(btn, "guard_guid", data.guard_guid)
    if data.guard_guid then
        GUI.SetData(btn, "item_guid", data.item_guid)
    else
        GUI.SetData(btn, "item_guid", data.guid)
    end

    local item_obj = nil
    local item_db = nil
    local level_number = nil
    local is_bind = nil
    local add_attribute = 10

    local guard_id = nil
    local guard_db = nil
    if data.guard_guid then
        item_obj = LD.GetItemDataByGuid(data.item_guid,
                item_container_type.item_container_guard_equip,
                data.guard_guid)

        item_db = DB.GetOnceItemByKey1(item_obj.id)
        -- level_number = LD.GetItemIntCustomAttrByGuid("minghun_intensify_level", data.item_guid, item_obj.BagType)
        guard_id = LD.GetGuardIDByGUID(data.guard_guid)
        guard_db = DB.GetOnceGuardByKey1(guard_id)
    else
        -- level_number = LD.GetItemIntCustomAttrByGuid("minghun_intensify_level", data.guid, item_container_type.item_container_guard_equip)
        item_obj = LD.GetItemDataByGuid(data.guid, item_container_type.item_container_guard_equip)
        item_db = DB.GetOnceItemByKey1(item_obj.id)
    end
    is_bind = item_obj.isbound ~= 0
    level_number = item_obj:GetIntCustomAttr("minghun_intensify_level")
    level_number = level_number ~= 0 and level_number or 0

    -- 是否选中
    local btnSelectImage = GUI.GetChild(btn, "btnSelectImage")
    if btnSelectImage then
        local is_show = false
        if GuardSoulUI.select_soul_data_of_reinforce_page and
                GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
            if GuardSoulUI.select_soul_data_of_reinforce_page.item_guid ==
                    tostring(item_obj.guid) then
                is_show = true
            end
        end
        GUI.SetVisible(btnSelectImage, is_show)
    end

    local icon_bg = GUI.GetChild(btn, "icon_Bg")
    if icon_bg then
        GUI.ImageSetImageID(icon_bg, quality[item_db.Grade][2])

        local icon = GUI.GetChild(icon_bg, "icon")
        if icon then
            GUI.ImageSetImageID(icon, item_db.Icon)
        end

        local level_bg = GUI.GetChild(icon_bg, "levelBg")
        if level_bg then
            GUI.ImageSetImageID(level_bg, _IconRightCornerRes[item_db.Grade] or _IconRightCornerRes[#_IconRightCornerRes])

            local level_txt = GUI.GetChild(level_bg, "txt")
            GUI.StaticSetText(level_txt, level_number)
        end

        local bind_img = GUI.GetChild(icon_bg, "bind_img")
        if bind_img then
            if is_bind then
                GUI.SetVisible(bind_img, true)
            else
                GUI.SetVisible(bind_img, false)
            end
        end
    end

    local item_name = GUI.GetChild(btn, "guardName")
    if item_name then
        GUI.StaticSetText(item_name, item_db.Name)
    end

    local add_property = GUI.GetChild(btn, "add_property")
    if add_property then
        local attr_data = item_obj:GetDynAttrDataByMark(0)
        if attr_data.Count > 0 then
            local attrData = attr_data[0]
            local attrId = attrData.attr
            local value = tostring(attrData.value)
            local attrDB = DB.GetOnceAttrByKey1(attrId)
            if attrDB.IsPct == 1 then
                value = tostring(tonumber(value) / 100) .. "%"
            end
            GUI.StaticSetText(add_property, "+" .. attrDB.ChinaName .. value)
        else
            GUI.StaticSetText(add_property, "")
        end
    end

    -- local item_type_sprite = GUI.GetChild(btn,'guardType_Sprite')
    -- if item_type_sprite then
    --    GUI.ImageSetImageID(item_type_sprite,soul_type[item_db.Subtype])
    -- end

    local guard_quality_sprite = GUI.GetChild(btn, "guardQuality_Sprite")
    if guard_quality_sprite then
        GUI.ImageSetImageID(guard_quality_sprite, soul_type[item_db.Subtype][2])
    end

    local user_icon = GUI.GetChild(btn, "UserIcon")
    if user_icon then
        if guard_db and guard_db.Head then
            GUI.ImageSetImageID(user_icon, guard_db.Head)
            GUI.SetVisible(user_icon, true)
        else
            GUI.SetVisible(user_icon, false)
        end
    end

    -- 如果是tips跳转界面过来的时候，需要选中那个tips显示的物品
    if GuardSoulUI.clickTipsSelectASoulItem then
        if tostring(item_obj.guid) ==
                GuardSoulUI.clickTipsSelectASoulItem.item_guid then
            GuardSoulUI.soul_list_scroll_one_btn_click(guid)
            GuardSoulUI.clickTipsSelectASoulItem = nil
            -- 取消首次打开强化页签界面
            GuardSoulUI.FirstSelectFlag_of_reinforce_page = false
        end
        -- 当前五个物品没有选中的物品时,调用下面的函数
        -- 根据选中的类型筛选命魂列表 GuardSoulUI.soul_list_select_one_type_click(guid, type)
        -- 在函数中将会滚动到选中物品的位置
        -- 然后再次执行这个函数，选中该显示选中的物品
    else
        -- 首次打开强化页签界面
        if GuardSoulUI.FirstSelectFlag_of_reinforce_page then
            GuardSoulUI.FirstSelectFlag_of_reinforce_page = false
            GuardSoulUI.soul_list_scroll_one_btn_click(guid)
        end
    end

    -- 吞噬命魂后需要刷新，然后选中被强化的命魂
    if GuardSoulUI.have_eaten_soul_need_refresh_bag_soul_items and
            GuardSoulUI.select_soul_data_of_reinforce_page then
        if tostring(item_obj.guid) ==
                GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
            GuardSoulUI.soul_list_scroll_one_btn_click(guid)
        end
    end
end

-- #刷新命魂升级和详情界面
function GuardSoulUI.refresh_soul_up_level_and_detail(_data)
    local grade_exp = GuardSoulUI.minghun_grade_exp_config
    local level_up_config = GuardSoulUI.minghun_level_up_config
    local loss_percentage = GuardSoulUI.minghun_loss_percentage
    GuardSoulUI.isSoulMaxLevel = nil
    -- 命魂升级经验系数(根据民魂品质)
    local minghun_need_grade_exp_config = GuardSoulUI.minghun_need_grade_exp_config
    if GuardSoulUI.minghun_need_grade_exp_config == nil then
        minghun_need_grade_exp_config = 1
        test("GuardSoulUI.minghun_need_grade_exp_config == nil ")
    end

    local data = nil
    if _data then
        data = _data
    else
        data = GuardSoulUI.select_soul_data_of_reinforce_page
    end

    local reinforced_page = _gt.GetUI("reinforced_page")
    local up_level_bg = GUI.GetChild(reinforced_page, "soul_up_level_bg")

    local item_obj = nil
    local item_db = nil
    local up_level_need_experience = 0
    local current_experience = 0
    local preview_add_experience = 0
    local current_level = 0
    local preview_add_level = 0

    if data ~= nil then
        if data.guard_guid then
            item_obj = LD.GetItemDataByGuid(data.item_guid, item_container_type.item_container_guard_equip, data.guard_guid)
            current_level = LD.GetItemIntCustomAttrByGuid("minghun_intensify_level", data.item_guid, item_container_type.item_container_guard_equip, data.guard_guid)
            current_experience = LD.GetItemIntCustomAttrByGuid("minghun_intensify_have_exp", data.item_guid, item_container_type.item_container_guard_equip, data.guard_guid)
        else
            item_obj = LD.GetItemDataByGuid(data.item_guid, item_container_type.item_container_guard_equip)

            current_level = LD.GetItemIntCustomAttrByGuid("minghun_intensify_level", data.item_guid, item_container_type.item_container_guard_equip)
            current_experience = LD.GetItemIntCustomAttrByGuid("minghun_intensify_have_exp", data.item_guid, item_container_type.item_container_guard_equip)
        end

        if item_obj == nil then
            test("GuardSoulUI.refresh_soul_up_level_and_detail(_data) item_obj==nil")
            return ""
        end

        item_db = DB.GetOnceItemByKey1(item_obj.id)
        -- 根据品质确定升级经验系数
        local expCoefficient = (minghun_need_grade_exp_config == 1 and minghun_need_grade_exp_config or minghun_need_grade_exp_config[item_db.Grade])
        current_level = current_level ~= 0 and current_level or 0
        current_experience = current_experience ~= 0 and current_experience or 0

        up_level_need_experience = (level_up_config[current_level + 1] or 0) * expCoefficient

        -- 计算选中的材料能增加的经验
        if GuardSoulUI.select_materials_data and next(GuardSoulUI.select_materials_data) then
            for k, v in pairs(GuardSoulUI.select_materials_data) do
                local exp = 0
                local material_item_obj = LD.GetItemDataByGuid(v, item_container_type.item_container_guard_equip)
                local level = material_item_obj:GetIntCustomAttr("minghun_intensify_level")
                local material_item_db = DB.GetOnceItemByKey1(material_item_obj.id)
                local add_grade_exp = grade_exp[material_item_db.Grade]
                local material_item_keyName = material_item_db.KeyName
                -- 判断是否是特殊配置的经验命魂
                if GuardSoulUI.minghun_key_exp_config and GuardSoulUI.minghun_key_exp_config[material_item_keyName] then
                    exp = GuardSoulUI.minghun_key_exp_config[material_item_keyName]
                else
                    local add_level_exp = 0
                    -- 经验系数
                    local coefficient = minghun_need_grade_exp_config[material_item_db.Grade]
                    for i = 1, level do
                        if level_up_config[i] then
                            add_level_exp = (level_up_config[i] * coefficient) + add_level_exp
                        end
                    end
                    exp = add_level_exp
                    exp = exp * (loss_percentage / 100)
                    exp = exp + add_grade_exp
                end
                preview_add_experience = preview_add_experience + exp
            end
        else
            preview_add_experience = 0
        end

        -- 计算能提升多少级
        if preview_add_experience + current_experience < up_level_need_experience then
            preview_add_level = 0
        elseif preview_add_experience + current_experience == up_level_need_experience then
            preview_add_level = 1
        else
            local surplus_exp = preview_add_experience + current_experience - up_level_need_experience
            preview_add_level = 1
            for i = 1, #level_up_config do
                local up_level_need_exp = level_up_config[current_level + preview_add_level + 1]
                if up_level_need_exp then
                    -- 不超出上限等级的情况下再乘以系数，不然报乘以nil的错误
                    up_level_need_exp = up_level_need_exp * expCoefficient

                    if surplus_exp > up_level_need_exp then
                        surplus_exp = surplus_exp - up_level_need_exp
                        preview_add_level = preview_add_level + 1
                    else
                        -- 提供的经验无法提升下一级
                        break
                    end
                else
                    -- 已达到最大等级
                    GuardSoulUI.isSoulMaxLevel = true
                    break
                end
            end
        end

        -- 如果已经达到了最大等级
        if current_level == #level_up_config then
            up_level_need_experience = 0
            preview_add_level = 0
            preview_add_experience = 0
            current_experience = 0
        end
    end

    local itemIcon = _gt.GetUI("headItemIcon_UpStar")
    if itemIcon then
        if item_db then
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, quality[item_db.Grade][2])
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, item_db.Icon)
        else
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Border, quality[1][2])
            GUI.ItemCtrlSetElementValue(itemIcon, eItemIconElement.Icon, "")
        end
    end

    local slider_bg = _gt.GetUI("sliderBg_UpStar")
    if slider_bg then
        local slider = GUI.GetChild(slider_bg, "slider")
        if slider then
            if up_level_need_experience > 0 then
                GUI.SetImageFillAmount(slider, (current_experience + preview_add_experience) / up_level_need_experience)
            else
                GUI.SetImageFillAmount(slider, 0)
            end
        end

        local slider2 = GUI.GetChild(slider_bg, "slider2")
        if slider2 then
            if up_level_need_experience > 0 then
                GUI.SetImageFillAmount(slider2, current_experience / up_level_need_experience)
            else
                GUI.SetImageFillAmount(slider2, 0)
            end
        end

        local slider_value = GUI.GetChild(slider_bg, "sliderValue")
        if slider_value then
            if preview_add_level > 0 then
                GUI.StaticSetText(slider_value, "Lv." .. current_level .. "<color=#05ab4f>(+" .. preview_add_level .. ")</color>")
            else
                GUI.StaticSetText(slider_value, "Lv." .. current_level)
            end
        end

        local exp_bg = GUI.GetChild(slider_bg, "exp_bg")
        if exp_bg then
            local show_experience = GUI.GetChild(exp_bg, "experience")
            if show_experience then
                GUI.StaticSetText(show_experience, current_experience + preview_add_experience .. "/" .. up_level_need_experience)
            end
        end
    end

    local up_attribute_bg = GUI.GetChild(up_level_bg, "up_attribute_bg")
    if up_attribute_bg then
        local attr_name = nil
        local attr_value = nil

        local primary_attr = GUI.GetChild(up_attribute_bg, "primary_attr")
        if primary_attr then
            if item_obj then
                local attrDatas = item_obj:GetDynAttrDataByMark(0)
                if attrDatas.Count > 0 then
                    local attrData = attrDatas[0]
                    local attrId = attrData.attr
                    local value = tostring(attrData.value)
                    local attrDB = DB.GetOnceAttrByKey1(attrId)
                    if attrDB.IsPct == 1 then
                        value = tostring(tonumber(value) / 100) .. "%"
                    end
                    GUI.StaticSetText(primary_attr, attrDB.ChinaName .. " <color=#aa7830ff>" .. value .. "</color>")
                    attr_name = attrDB.ChinaName
                    attr_value = value
                else
                    GUI.StaticSetText(primary_attr, "无属性")
                end
            else
                -- .. " <color=#aa7830ff>" .. 0 .. "</color>")
                GUI.StaticSetText(primary_attr, "无属性")
            end
        end

        if preview_add_level > 0 then
            -- send request for refresh this ui element
            GuardSoulUI.Intensify_Attr_Preview_request(tostring(item_obj.guid), preview_add_level)
        else
            if item_obj and item_obj.guid then
                GuardSoulUI.one_level_intensify_attr_preview = true
                GuardSoulUI.Intensify_Attr_Preview_request(tostring(item_obj.guid), 1)
            else
                local up_level_attr = GUI.GetChild(up_attribute_bg, "up_level_attr")
                if up_level_attr then
                    -- 30aa1dff
                    GUI.StaticSetText(up_level_attr, (attr_name or "无属性") .. " <color=#aa7830ff>" .. (attr_value or "") .. "</color>")
                end
            end
        end
    end

    -- 洗炼页签中，中间部分显示的属性
    local baptized_attribute_bg = GUI.GetChild(up_level_bg, "baptized_attribute_bg")
    if baptized_attribute_bg then
        local up_level_attr = GUI.GetChild(baptized_attribute_bg, "up_level_attr")
        if up_level_attr then
            if item_obj then
                local attrDatas = item_obj:GetDynAttrDataByMark(0)
                if attrDatas.Count > 0 then
                    local attrData = attrDatas[0]
                    local attrId = attrData.attr
                    local value = tostring(attrData.value)
                    local attrDB = DB.GetOnceAttrByKey1(attrId)
                    if attrDB.IsPct == 1 then
                        value = tostring(tonumber(value) / 100) .. "%"
                    end
                    GUI.StaticSetText(up_level_attr, attrDB.ChinaName .. " <color=#aa7830ff>" .. value .. "</color>")
                else
                    GUI.StaticSetText(up_level_attr, "无属性")
                end
            else
                GUI.StaticSetText(up_level_attr, "无属性") -- .. " <color=#aa7830ff>" .. 0 .. "</color>")
            end
        end
    end

    -- six attribute
    -- 改为发送请求刷新，原因： 用mark获取的数据与请求拿来的数据顺序不一一对应
    GuardSoulUI.Refining_GetHaveAttrData_request()
end

-- #刷新强化命魂材料框
function GuardSoulUI.refresh_reinforced_soul_material_box(_data)
    local data = nil

    if _data and next(_data) then
        data = _data
    elseif GuardSoulUI.show_material_scroll_data then
        data = GuardSoulUI.show_material_scroll_data
    end

    if data == nil then
        test("GuardSoulUI.refresh_reinforced_soul_material_box(_data) data == nil")
        return ""
    end

    local bg = _gt.GetUI("reinforced_and_baptized_bg")
    local group = GUI.GetChild(bg, "reinforced_group")
    local material_box_group = GUI.GetChild(group, "material_box_group")
    local matrix_box = GUI.GetChild(material_box_group, "matrix_box")

    GuardSoulUI.empty_matrix_box(matrix_box, quality[1][2])

    -- 打开的是背包中时，剔除选中要强化的命魂
    if GuardSoulUI.select_soul_list_position_of_reinforce_page == "knapsack" then
        if GuardSoulUI.select_soul_data_of_reinforce_page and GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
            data = GuardSoulUI.filter_soul_by_guid(_data, GuardSoulUI.select_soul_data_of_reinforce_page .item_guid)
        end

        -- 同时在已选中强化材料中剔除要强化的命魂(被强化)

        -- 因为是根据位置选中的，下面的代码会让选中材料的位置错乱，且会少掉一个
        -- if GuardSoulUI.select_materials_data then
        --     for k, v in pairs(GuardSoulUI.select_materials_data) do
        --         if v == GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
        --             GuardSoulUI.select_materials_data[k] = nil
        --         end
        --     end
        -- end

        -- 所以需要重新计算过滤出来的选中物品
    end
    -- 来回切换都需要刷新选中的材料
    GuardSoulUI.select_materials_data = GuardSoulUI.filter_material_by_grade(data, GuardSoulUI.select_soul_material_type)

    matrix_box = GuardSoulUI.create_matrix_box(material_box_group, 4, math.ceil(#data / 4), quality[1][2])

    for k, v in ipairs(data) do
        local __data = v

        local box = GUI.GetChild(matrix_box, "box_" .. k)
        GUI.ItemCtrlSetElementValue(box, eItemIconElement.Icon, data[k].icon)
        GUI.ItemCtrlSetElementValue(box, eItemIconElement.Border, quality[__data.grade][2] or "1800400330")

        local level_bg = GuardSoulUI.AddBtn_LevelSp(box)
        -- get item quality
        local item_quality = __data.grade
        if item_quality then
            GUI.ImageSetImageID(level_bg, _IconRightCornerRes[item_quality] or _IconRightCornerRes[#_IconRightCornerRes])
        end

        local level_txt = GUI.GetChild(level_bg, "txt")
        GUI.StaticSetText(level_txt, __data.level)

        -- select the box
        -- 创建黄色正方形选中框
        local select_the_box = GUI.GetChild(box, "select_the_box" .. k)
        if select_the_box == nil then
            select_the_box = GUI.ImageCreate(box, "select_the_box" .. k, "1800400280", 0, 0)
            SetSameAnchorAndPivot(select_the_box, UILayout.Center)
            GUI.SetVisible(select_the_box, false)
        end

        -- 创建勾选中图片
        local select_img = GUI.GetChild(box, "select_img")
        if select_img == nil then
            select_img = GUI.ImageCreate(box, "select_img", "1801407090", 0, 0)
            SetSameAnchorAndPivot(select_img, UILayout.Center)
            GUI.SetVisible(select_img, false)
        end

        -- 显示所有选中命魂的勾图片
        if GuardSoulUI.select_materials_data and
                GuardSoulUI.select_materials_data[k] then
            GUI.SetVisible(select_img, true)
        else
            GUI.SetVisible(select_img, false)
        end

        -- 显示所有选中命魂的选中框
        -- if GuardSoulUI.select_materials_data and GuardSoulUI.select_materials_data[(k)] then
        --     GUI.SetVisible(select_the_box, true)
        -- end

        -- bind img
        if __data.is_bind then
            local bind_img = GUI.GetChild(box, "bind_img" .. k)
            if bind_img == nil then
                bind_img = GUI.ImageCreate(box, "bind_img" .. k, "1800707120",
                        0, 0)
                SetSameAnchorAndPivot(bind_img, UILayout.TopLeft)
            end
            GUI.SetVisible(bind_img, true)
        end

        -- click event
        GUI.SetData(box, "index", k)
        GUI.SetData(box, "itemGuid", __data.guid)
        GUI.RegisterUIEvent(box, UCE.PointerClick, "GuardSoulUI", "reinforced_material_box_click")
    end
end

-- #刷新洗炼界面
function GuardSoulUI.refresh_baptized_page(_data)
    local data = nil

    local is_have_baptize_attr = nil
    -- 当有洗炼属性时显示洗炼属性(未保存)
    if GuardSoulUI.minghun_refining_save_attr and next(GuardSoulUI.minghun_refining_save_attr) then
        -- 没有则显示已保存的属性
        data = GuardSoulUI.minghun_refining_save_attr
        is_have_baptize_attr = true
    elseif GuardSoulUI.minghun_refining_have_attr and next(GuardSoulUI.minghun_refining_have_attr) then
        data = GuardSoulUI.minghun_refining_have_attr
    end

    -- if GuardSoulUI.select_soul_data_of_reinforce_page == nil then
    -- test('GuardSoulUI.refresh_baptized_page(_data) GuardSoulUI.select_soul_data_of_reinforce_page == nil')
    -- return ''
    -- end

    local bg = _gt.GetUI("reinforced_and_baptized_bg")
    local group = GUI.GetChild(bg, "baptized_group")

    local item_data = GuardSoulUI.select_soul_data_of_reinforce_page
    local item_obj = nil
    if item_data then
        if item_data.guard_guid then
            item_obj = LD.GetItemDataByGuid(item_data.item_guid, item_container_type.item_container_guard_equip, item_data.guard_guid)
        else
            item_obj = LD.GetItemDataByGuid(item_data.item_guid, item_container_type.item_container_guard_equip)
        end
    end

    local item_level = 0
    if item_obj then
        item_level = item_obj:GetIntCustomAttr("minghun_intensify_level")
    end

    local property_data = {}
    if data then
        for k, v in ipairs(data) do
            local d = {}
            -- 属性名称
            d.name = v.attr
            -- 当前属性值
            d.current = v.value
            d.min = v.minValue
            d.max = v.maxValue
            d.KeyName = v.key
            -- 开启等级
            d.activate_level = GuardSoulUI.minghun_refining_attr_openlevel and GuardSoulUI.minghun_refining_attr_openlevel[k] or 0
            table.insert(property_data, d)
        end
    end

    -- local property_data = {
    --    {
    --        name = '气血',
    --        min = 1,
    --        max = 10,
    --        current = 2,
    --        activate_level = 10,
    --    }
    -- }

    -- 未保存属性颜色
    local green_color = Color.New(48 / 255, 170 / 255, 29 / 255, 1)
    -- 已保存属性颜色
    local brown_color = Color.New(174 / 255, 120 / 255, 55 / 255, 1)
    -- 展示的颜色
    local show_color = nil
    if is_have_baptize_attr then
        show_color = green_color
    else
        show_color = brown_color
    end

    -- refresh attributes
    local gray_color = Color.New(129 / 255, 119 / 255, 115 / 255, 1)
    if GuardSoulUI.minghun_refining_attr_openlevel then
        for k, v in ipairs(GuardSoulUI.minghun_refining_attr_openlevel) do
            local property = _gt.GetUI("deputy_property_" .. k)

            -- 如果是空的（属性超出6条)
            if property == nil then
                local deputy_properties_Scroll = _gt.GetUI("deputy_properties_Scroll")
                local property_bg = GUI.ImageCreate(deputy_properties_Scroll, "deputy_property_bg" .. k, "1801401270", 0, 0, false, GUI.GetWidth(deputy_properties_Scroll) - 10, 40)

                local txt = GUI.CreateStatic(property_bg, "txt", "气血+0(0-0)", -10, 0, 271, GUI.GetHeight(property_bg), "system")
                SetSameAnchorAndPivot(txt, UILayout.Left)
                GUI.StaticSetFontSize(txt, 19) -- UIDefine.FontSizeS -1
                GUI.SetColor(txt, brown_color)
                GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
                _gt.BindName(txt, "deputy_property_" .. k)

                local check_box = GUI.CheckBoxExCreate(property_bg, "check_box", "1800607150", "1800607151", 27, 0, false, 28, 28)
                SetSameAnchorAndPivot(check_box, UILayout.Right)
                GUI.SetData(check_box, "index", k)
                GUI.RegisterUIEvent(check_box, UCE.PointerClick, "GuardSoulUI", "deputy_property_check_box_click")

                property = txt
            end

            local bg = GUI.GetParentElement(property)
            GUI.SetVisible(bg, true)

            local check_box = GUI.GetChild(bg, "check_box")

            if property_data[k] then
                local data = property_data[k]
                if item_level < data.activate_level then
                    GUI.SetColor(property, gray_color)
                    GUI.SetVisible(check_box, false)
                    GUI.StaticSetText(property, "命魂达到" .. data.activate_level .. "级解锁")
                else
                    -- 判断是否锁定，如过是锁定,转换颜色
                    if GuardSoulUI.select_deputy_property_data and GuardSoulUI.select_deputy_property_data[k] == true then
                        GUI.SetColor(property, brown_color)
                        GUI.CheckBoxExSetCheck(check_box, true)
                    else
                        GUI.CheckBoxExSetCheck(check_box, false)

                        -- 命魂tips 不同范围的属性显示不同的颜色
                        local scopeColor = nil
                        if GuardSoulUI and GuardSoulUI.isShowTipsScopeColor and GuardSoulUI.scopeColor then
                            -- 确保转换颜色值的函数存在
                            if GlobalUtils and GlobalUtils.getRGBDecimal then
                                scopeColor = GuardSoulUI.scopeColor
                            end
                        end

                        -- 判断显示什么颜色
                        local showColor = nil
                        if scopeColor then
                            local d = scopeColor[data.KeyName]
                            if d then
                                for k, v in ipairs(d) do
                                    if tonumber(data.current) <= v.scope then
                                        if v.color then
                                            if type(v.color) == "string" then
                                                local r, g, b = GlobalUtils.getRGBDecimal(v.color)
                                                if r and g and b then
                                                    showColor = Color.New(r / 255, g / 255, b / 255, 1)
                                                end
                                            elseif type(v.color) == "table" then
                                                showColor = v.color
                                            end
                                        end
                                        break
                                    end
                                end
                            end
                        end

                        if showColor then
                            GUI.SetColor(property, showColor)
                        else
                            GUI.SetColor(property, show_color)
                        end
                    end

                    GUI.SetVisible(check_box, true)
                    GUI.StaticSetText(property, data.name .. "+" .. data.current .. "(" .. data.min .. "-" .. data.max .. ")")
                end
            else
                GUI.SetColor(property, gray_color)
                GUI.SetVisible(check_box, false)
                GUI.StaticSetText(property, "命魂达到" .. v .. "级解锁")
            end
        end

        -- 隐藏多的属性条
        local count = #GuardSoulUI.minghun_refining_attr_openlevel + 1
        local property = _gt.GetUI("deputy_property_" .. count)
        while (property ~= nil) do
            local bg = GUI.GetParentElement(property)
            GUI.SetVisible(bg, false)
            count = count + 1
            property = _gt.GetUI("deputy_property_" .. count)

            if count > 100 then
                test("GuardSoulUI.refresh_baptized_page(_data)  隐藏多余属性条 进行了过多的循环 请检查 如果正确请删除此判断")
                break
            end
        end
    end

    -- refresh material item ctrl
    if GuardSoulUI.minghun_refining_item_config then
        local d = GuardSoulUI.minghun_refining_item_config

        local two_btn_group = GUI.GetChild(group, "two_btn_group")
        local baptized_btn = GUI.GetChild(two_btn_group, "baptized_btn")
        -- local save_btn = GUI.GetChild(two_btn_group,'reinforced_btn')

        for i = 1, 3 do
            local ctrl = GUI.GetChild(group, "material" .. i)
            local txt = GUI.GetChild(group, "material_name" .. i)

            -- 锁魂令 保存消耗材料
            if i == 1 then
                local item = DB.GetOnceItemByKey2(d.LockItemKeyname)
                if item and item.Id ~= 0 then
                    GUI.ItemCtrlSetElementValue(ctrl, eItemIconElement.Icon, item.Icon)
                    GUI.ItemCtrlSetElementValue(ctrl, eItemIconElement.Border, quality[item.Grade][2])
                    GUI.StaticSetText(txt, item.Name)

                    GUI.SetData(ctrl, "item_id", item.Id)

                    -- 锁定的数量
                    local lock_num = 0
                    -- 计算锁定数量
                    if GuardSoulUI.select_deputy_property_data then
                        local count = 0
                        for k, v in pairs(GuardSoulUI.select_deputy_property_data) do
                            if v == true then
                                count = count + 1
                            end
                        end
                        lock_num = d.LockItemNum[count] or 0
                    end

                    -- 拥有的数量
                    local have_num = LD.GetItemCountById(item.Id)
                    if have_num >= lock_num then
                        GUI.ItemCtrlSetElementValue(ctrl, eItemIconElement.RightBottomNum, have_num .. "/" .. lock_num)
                        local num_ui = GUI.ItemCtrlGetElement(ctrl, eItemIconElement.RightBottomNum)
                        GUI.SetColor(num_ui, UIDefine.WhiteColor)

                        -- 设置data用于洗炼点击事件
                        GUI.SetData(baptized_btn, "is_save_material_ok", "true")
                    else
                        GUI.ItemCtrlSetElementValue(ctrl, eItemIconElement.RightBottomNum, have_num .. "/" .. lock_num)
                        local num_ui = GUI.ItemCtrlGetElement(ctrl, eItemIconElement.RightBottomNum)
                        GUI.SetColor(num_ui, UIDefine.RedColor)

                        -- 设置data用于洗炼点击事件
                        GUI.SetData(baptized_btn, "is_save_material_ok", "false")
                    end
                end
            end

            -- 命魂洗炼消耗材料
            if i == 3 then
                local item = DB.GetOnceItemByKey2(d.RefiningItem[1])
                if item and item.Id ~= 0 then
                    GUI.ItemCtrlSetElementValue(ctrl, eItemIconElement.Icon, item.Icon)
                    GUI.ItemCtrlSetElementValue(ctrl, eItemIconElement.Border, quality[item.Grade][2])
                    GUI.StaticSetText(txt, item.Name)

                    GUI.SetData(ctrl, "item_id", item.Id)

                    -- 消耗的数量
                    local lock_nul = d.RefiningItem[2] or 0
                    -- 拥有的数量
                    local have_num = LD.GetItemCountById(item.Id)
                    if have_num >= lock_nul then
                        GUI.ItemCtrlSetElementValue(ctrl, eItemIconElement.RightBottomNum, have_num .. "/" .. lock_nul)
                        local num_ui = GUI.ItemCtrlGetElement(ctrl, eItemIconElement.RightBottomNum)
                        GUI.SetColor(num_ui, UIDefine.WhiteColor)

                        GUI.SetData(baptized_btn, "is_baptize_material_ok", "true")
                    else
                        GUI.ItemCtrlSetElementValue(ctrl, eItemIconElement.RightBottomNum, have_num .. "/" .. lock_nul)
                        local num_ui = GUI.ItemCtrlGetElement(ctrl, eItemIconElement.RightBottomNum)
                        GUI.SetColor(num_ui, UIDefine.RedColor)

                        GUI.SetData(baptized_btn, "is_baptize_material_ok", "false")
                    end
                end
            end
        end
    end
end

-- #刷新附加属性
function GuardSoulUI.refresh_add_attribute()
    local data = GuardSoulUI.select_soul_data_of_reinforce_page
    local current_level = nil

    if data then
        if data.guard_guid then
            current_level = LD.GetItemIntCustomAttrByGuid("minghun_intensify_level", data.item_guid, item_container_type.item_container_guard_equip, data.guard_guid)
        else
            current_level = LD.GetItemIntCustomAttrByGuid("minghun_intensify_level", data.item_guid, item_container_type.item_container_guard_equip)
        end
    end

    current_level = current_level ~= 0 and current_level or 0

    local reinforced_page = _gt.GetUI("reinforced_page")
    local up_level_bg = GUI.GetChild(reinforced_page, "soul_up_level_bg")

    local add_attr_group = GUI.GetChild(up_level_bg, "add_attr_group")
    local bottomScroll = GUI.GetChild(add_attr_group, "bottomScroll")
    if bottomScroll then
        if GuardSoulUI.minghun_refining_attr_openlevel then
            for i, v in ipairs(GuardSoulUI.minghun_refining_attr_openlevel) do
                local additionalAttribute = GUI.GetChild(bottomScroll, "additionalAttribute" .. i)

                -- 当不存在时创建（超出6个属性添加)
                if additionalAttribute == nil then
                    local additionalAttribute = GUI.CreateStatic(bottomScroll, "additionalAttribute" .. i, "气血 " .. "<color=#aa7830ff>+0</color>", 0, 0, 185, 40, "system", true)

                    GUI.StaticSetFontSize(additionalAttribute, UIDefine.FontSizeSS)
                    GUI.SetColor(additionalAttribute, UIDefine.BrownColor)
                    GUI.StaticSetAlignment(additionalAttribute, TextAnchor.LowerLeft)
                end

                if additionalAttribute then
                    GUI.SetVisible(additionalAttribute, true)
                    -- GUI.StaticSetFontSize(additionalAttribute,UIDefine.FontSizeM)
                    if current_level < v then
                        GUI.StaticSetText(additionalAttribute, "Lv." .. v .. "解锁")
                    else
                        if GuardSoulUI.minghun_refining_have_attr then
                            local d = GuardSoulUI.minghun_refining_have_attr[i]
                            if d then
                                -- local len = string.len(d.attr)
                                -- if len > 12  then
                                -- GUI.StaticSetFontSize(additionalAttribute,UIDefine.FontSizeSS)
                                -- end
                                GUI.StaticSetText(additionalAttribute, d.attr .. "<color=#aa7830ff>" .. d.value .. "</color>")
                            else
                                GUI.StaticSetText(additionalAttribute, "Lv." .. v .. "解锁")
                            end
                        else
                            GUI.StaticSetText(additionalAttribute, "Lv." .. v .. "解锁")
                        end
                    end
                end
            end

            -- 隐藏多出的属性条
            local count = #GuardSoulUI.minghun_refining_attr_openlevel + 1
            local additionalAttribute = GUI.GetChild(bottomScroll, "additionalAttribute" .. count)
            while (additionalAttribute ~= nil) do
                GUI.SetVisible(additionalAttribute, false)
                count = count + 1
                additionalAttribute = GUI.GetChild(bottomScroll, "additionalAttribute" .. count)

                if count > 100 then
                    -- 防止死循环
                    test("GuardSoulUI.refresh_add_attribute()  循环超出上限 请检查，若正常请删除此判断")
                    break
                end
            end
        end
    end
end

-- >click-tab2--

-- 强化页签点击事件
function GuardSoulUI.on_reinforced_tab_btn_click(reinforced_or_baptize)
    local index = GuardSoulUI.get_index_of_tabList("reinforced_page")
    -- prevent repeat click
    if GuardSoulUI.TabIndex == index then
        UILayout.OnTabClick(GuardSoulUI.TabIndex, tabList)
        if reinforced_or_baptize ~= "baptize" and reinforced_or_baptize ~= "reinforced" then
            return ""
        end
    end

    GuardSoulUI.change_page(index)

    GuardSoulUI.create_soul_list()
    GuardSoulUI.create_soul_up_level_and_detail()
    GuardSoulUI.create_soul_reinforce_and_baptize_btn_and_bg()

    -- 从tips这边打开时选择页面
    if reinforced_or_baptize then
        GuardSoulUI.tips_open_reinforced_or_baptize = reinforced_or_baptize
    end

    -- 回调中包含下面两个点击事件
    GuardSoulUI.Intensify_GetData_request()

    -- 强化或者洗炼界面点击事件
    -- GuardSoulUI.in_equipment_btn_click()
    -- GuardSoulUI.reinforced_btn_click()
end

-- 显示所有的命魂种类在命魂列表中
function GuardSoulUI.soul_list_type_click()
    local rightTitle_Bg = _gt.GetUI("reinforced_page_rightTitle_Bg")
    local scr_GuardType_Bg = GUI.GetChild(rightTitle_Bg, "scr_GuardType_Bg")
    if scr_GuardType_Bg ~= nil then
        GUI.Destroy(scr_GuardType_Bg)
    end
    -- 创建侍从类型按钮选择列表
    scr_GuardType_Bg = GUI.ImageCreate(rightTitle_Bg, "scr_GuardType_Bg", "1800400290", 0, 36, false, 115, 181) -- 215)
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Bg, UILayout.Top)
    GUI.SetVisible(scr_GuardType_Bg, true)
    -- 检测到点击就销毁
    GUI.SetIsRemoveWhenClick(scr_GuardType_Bg, true)

    local childSize_GuardType = Vector2.New(105, 34)
    local scr_GuardType = GUI.ScrollRectCreate(scr_GuardType_Bg, "scr_GuardType", 0, 0, 105, 169, 0, false, childSize_GuardType, UIAroundPivot.Top, UIAnchor.Top)
    UILayout.SetSameAnchorAndPivot(scr_GuardType, UILayout.Center)

    local temp_soul_type = {}
    -- 剔除特殊命魂选型
    for k, v in ipairs(soul_type) do
        if v[1] ~= "特殊" then
            table.insert(temp_soul_type, v)
        end
    end
    local soul_type = temp_soul_type

    for i = 1, #soul_type do
        local btnName = ""
        local index = 0
        if i == 1 then
            btnName = soul_type[#soul_type][1]
        else
            btnName = soul_type[i - 1][1]
        end
        index = i - 1
        local btn = GUI.ButtonCreate(scr_GuardType, i - 1, "1800600100", 0, 0, Transition.ColorTint, btnName, 105, 32, false)
        GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeS)

        GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardSoulUI", "soul_list_select_one_type_click")

        if not GuardSoulUI.soul_list_kind_select_data then
            GuardSoulUI.soul_list_kind_select_data = {}
        end

        GuardSoulUI.soul_list_kind_select_data[GUI.GetGuid(btn)] = index
    end
end

-- 根据选中的类型筛选命魂列表
function GuardSoulUI.soul_list_select_one_type_click(guid, type)
    if type then
        GuardSoulUI.select_soul_list_type = type
    else
        if next(GuardSoulUI.soul_list_kind_select_data) == nil then
            test(" GuardSoulUI.soul_list_select_one_type_click(guid)")
            return ""
        end

        local index = GuardSoulUI.soul_list_kind_select_data[guid]
        if index == nil then
            test("function GuardSoulUI.soul_item_select_one_type_click(guid) 缺少soul_list_kind_select_data[guid]参数")
            return ""
        end
        GuardSoulUI.select_soul_list_type = tonumber(index)
        GuardSoulUI.select_soul_data_of_reinforce_page = nil
    end

    -- 关闭选择面板显示
    local scr_GuardType_Txt = _gt.GetUI("reinforced_page_scr_GuardType_Txt")
    if scr_GuardType_Txt then
        GUI.StaticSetText(scr_GuardType_Txt, GuardSoulUI.select_soul_list_type == 0 and soul_type[#soul_type][1] or soul_type[GuardSoulUI.select_soul_list_type][1])
    end

    local scr_GuardCount = _gt.GetUI("reinforced_page_haveGuardCount")
    if scr_GuardCount then
        GUI.StaticSetText(scr_GuardCount, GuardSoulUI.select_soul_list_type == 0 and soul_type[#soul_type][1] or soul_type[GuardSoulUI.select_soul_list_type][1])
    end

    if GuardSoulUI.select_soul_list_type == 0 then
        GuardSoulUI.show_soul_list_data_of_reinforce_page = GuardSoulUI.all_soul_list_data_of_reinforce_page

        GuardSoulUI.show_soul_list_data_of_reinforce_page = GuardSoulUI.filterEquippedSoulDataByType(GuardSoulUI.show_soul_list_data_of_reinforce_page, 5)
    else
        GuardSoulUI.filter_equipped_soul_data(GuardSoulUI.all_soul_list_data_of_reinforce_page, GuardSoulUI.select_soul_list_type)

        GuardSoulUI.show_soul_list_data_of_reinforce_page = GuardSoulUI.filterEquippedSoulDataByType(GuardSoulUI.show_soul_list_data_of_reinforce_page, 5)
    end

    if GuardSoulUI.have_eaten_soul_need_refresh_bag_soul_items ~= true then
        GuardSoulUI.FirstSelectFlag_of_reinforce_page = true
    end

    local show_count = #GuardSoulUI.show_soul_list_data_of_reinforce_page

    -- 对显示的数据进行排序,装备中默认排好了序，背包中需要按规则排序
    if show_count > 0 and GuardSoulUI.select_soul_list_position_of_reinforce_page == "knapsack" then
        table.sort(GuardSoulUI.show_soul_list_data_of_reinforce_page, GuardSoulUI.equipmentSortOfReinforcePage)
    else
        -- 刷新中间 当显示的数据为0时 不会刷新中间选中物品的显示 需要此处刷新下
        GuardSoulUI.refresh_soul_up_level_and_detail()
    end

    local scr_Guard = _gt.GetUI("reinforced_page_scr_Guard")
    GUI.LoopScrollRectSetTotalCount(scr_Guard, show_count)
    GUI.LoopScrollRectRefreshCells(scr_Guard)

    -- 滚动到选中的命魂
    local item_guid = nil
    -- 被强化的物品
    if GuardSoulUI.select_soul_data_of_reinforce_page then
        item_guid = GuardSoulUI.select_soul_data_of_reinforce_page.item_guid
        -- Tips命魂，点击进来需要选中的
    elseif GuardSoulUI.clickTipsSelectASoulItem then
        item_guid = GuardSoulUI.clickTipsSelectASoulItem.item_guid
    end
    if show_count > 0 then
        local div = nil
        for k, v in ipairs(GuardSoulUI.show_soul_list_data_of_reinforce_page) do
            if v.guid == item_guid or v.item_guid == item_guid then
                div = (k - 1) / show_count
                break
            end
        end

        if div then
            GUI.ScrollRectSetNormalizedPosition(scr_Guard, Vector2.New(0, div))
        end
    end
end

-- #装备中点击
function GuardSoulUI.in_equipment_btn_click(guid, need_refresh)
    if need_refresh == nil then
        if GuardSoulUI.select_soul_list_position_of_reinforce_page == "equipment" then
            return ""
        end
        GuardSoulUI.select_soul_list_position_of_reinforce_page = "equipment"

        GuardSoulUI.select_soul_data_of_reinforce_page = nil

        local reinforced_page = _gt.GetUI("reinforced_page")

        local in_equipment_btn = GUI.GetChild(reinforced_page, "in_equipment_btn")
        GUI.ButtonSetImageID(in_equipment_btn, "1800402031")

        local in_knapsack_btn = GUI.GetChild(reinforced_page, "in_knapsack_btn")
        GUI.ButtonSetImageID(in_knapsack_btn, "1800402030")
    end

    -- 计算出显示的数据，并存入到了全局变量
    local data = GuardSoulUI.get_all_equipped_soul_of_guards()
    if #data == 0 then
        GuardSoulUI.refresh_soul_up_level_and_detail()
        -- 刷新命魂强化或命魂洗炼界面
        if GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn then
            if GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == "reinforced_btn" then
                GuardSoulUI.refresh_reinforced_soul_material_box(GuardSoulUI.show_material_scroll_data)
            elseif GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == "baptized_btn" then
                GuardSoulUI.baptized_btn_click(nil, true)
            end
        end
    end

    if need_refresh then
        GuardSoulUI.soul_list_select_one_type_click(nil, GuardSoulUI.select_soul_list_type)
    else
        GuardSoulUI.soul_list_select_one_type_click(nil, 0)
    end
end

-- #背包中点击
function GuardSoulUI.in_knapsack_btn_click(guid, need_refresh)
    if need_refresh == nil then
        if GuardSoulUI.select_soul_list_position_of_reinforce_page == "knapsack" then
            return ""
        end

        GuardSoulUI.select_soul_list_position_of_reinforce_page = "knapsack"

        GuardSoulUI.select_soul_data_of_reinforce_page = nil

        local reinforced_page = _gt.GetUI("reinforced_page")

        local in_equipment_btn = GUI.GetChild(reinforced_page, "in_equipment_btn")
        GUI.ButtonSetImageID(in_equipment_btn, "1800402030")

        local in_knapsack_btn = GUI.GetChild(reinforced_page, "in_knapsack_btn")
        GUI.ButtonSetImageID(in_knapsack_btn, "1800402031")
    end

    GuardSoulUI.all_soul_list_data_of_reinforce_page = GuardSoulUI.get_bag_soul_items()

    if #GuardSoulUI.all_soul_list_data_of_reinforce_page == 0 then
        GuardSoulUI.refresh_soul_up_level_and_detail()

        -- 刷新命魂强化或命魂洗炼界面
        if GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn then
            if GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == "reinforced_btn" then
                GuardSoulUI.refresh_reinforced_soul_material_box(GuardSoulUI.show_material_scroll_data)
            elseif GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == "baptized_btn" then
                GuardSoulUI.baptized_btn_click(nil, true)
            end
        end
    end

    if need_refresh then
        GuardSoulUI.soul_list_select_one_type_click(nil, GuardSoulUI.select_soul_list_type)
    else
        GuardSoulUI.soul_list_select_one_type_click(nil, 0)
    end
end

-- #命魂强化点击
function GuardSoulUI.reinforced_btn_click(guid, need_refresh)
    if need_refresh == nil then
        if GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == "reinforced_btn" then
            return ""
        end

        GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn = "reinforced_btn"

        local reinforced_page = _gt.GetUI("reinforced_page")

        local reinforced_btn = GUI.GetChild(reinforced_page, "reinforced_btn")
        GUI.ButtonSetImageID(reinforced_btn, "1800402031")

        local baptized_btn = GUI.GetChild(reinforced_page, "baptized_btn")
        GUI.ButtonSetImageID(baptized_btn, "1800402030")

        GuardSoulUI.create_reinforced_box()

        local reinforced_and_baptized_bg = _gt.GetUI("reinforced_and_baptized_bg")
        local reinforced_page = GUI.GetChild(reinforced_and_baptized_bg, "reinforced_group")
        local baptized_page = GUI.GetChild(reinforced_and_baptized_bg, "baptized_group")

        GUI.SetVisible(reinforced_page, true)
        GUI.SetVisible(baptized_page, false)

        local reinforced_page = _gt.GetUI("reinforced_page")
        local soul_up_level_bg = GUI.GetChild(reinforced_page, "soul_up_level_bg")

        local baptized_attribute_bg = GUI.GetChild(soul_up_level_bg, "baptized_attribute_bg")
        GUI.SetVisible(baptized_attribute_bg, false)

        local up_attribute_bg = GUI.GetChild(soul_up_level_bg, "up_attribute_bg")
        GUI.SetVisible(up_attribute_bg, true)
    end

    -- refresh reinforced_page
    if need_refresh then
        GuardSoulUI.soul_material_type_select_one_btn_click(nil, GuardSoulUI.select_soul_material_type)
    else
        GuardSoulUI.soul_material_type_select_one_btn_click(nil, 0)
    end

    -- if GuardSoulUI.select_soul_data_of_reinforce_page
    --        or GuardSoulUI.have_eaten_soul_need_refresh_bag_soul_items then
    -- end
    GuardSoulUI.refresh_soul_up_level_and_detail()
end

-- #命魂洗炼点击
function GuardSoulUI.baptized_btn_click(guid, need_refresh)
    if need_refresh == nil then
        if GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == "baptized_btn" then
            return ""
        end

        GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn = "baptized_btn"

        local reinforced_page = _gt.GetUI("reinforced_page")

        local reinforced_btn = GUI.GetChild(reinforced_page, "reinforced_btn")
        GUI.ButtonSetImageID(reinforced_btn, "1800402030")

        local baptized_btn = GUI.GetChild(reinforced_page, "baptized_btn")
        GUI.ButtonSetImageID(baptized_btn, "1800402031")

        GuardSoulUI.create_baptized_page()

        local reinforced_and_baptized_bg = _gt.GetUI("reinforced_and_baptized_bg")
        local reinforced_page = GUI.GetChild(reinforced_and_baptized_bg, "reinforced_group")
        local baptized_page = GUI.GetChild(reinforced_and_baptized_bg, "baptized_group")

        GUI.SetVisible(reinforced_page, false)
        GUI.SetVisible(baptized_page, true)

        local reinforced_page = _gt.GetUI("reinforced_page")
        local soul_up_level_bg = GUI.GetChild(reinforced_page, "soul_up_level_bg")

        local baptized_attribute_bg = GUI.GetChild(soul_up_level_bg, "baptized_attribute_bg")
        GUI.SetVisible(baptized_attribute_bg, true)

        local up_attribute_bg = GUI.GetChild(soul_up_level_bg, "up_attribute_bg")
        GUI.SetVisible(up_attribute_bg, false)
    end

    -- refresh baptized_page
    -- 请求数据 回调中刷新界面
    GuardSoulUI.Refining_GetAttrData_request()
end

-- #强化材料筛选按钮点击,展开下拉列表
function GuardSoulUI.soul_material_type_select_btn_click()
    local bg = _gt.GetUI("reinforced_and_baptized_bg")
    local rightTitle_Bg = GUI.GetChild(bg, "reinforced_group")

    local scr_GuardType_Bg = GUI.GetChild(rightTitle_Bg, "scr_GuardType_Bg")
    if scr_GuardType_Bg ~= nil then
        GUI.Destroy(scr_GuardType_Bg)
    end
    -- 创建侍从类型按钮选择列表
    scr_GuardType_Bg = GUI.ImageCreate(rightTitle_Bg, "scr_GuardType_Bg", "1800400290", 55, -58, false, 115, 250)
    UILayout.SetSameAnchorAndPivot(scr_GuardType_Bg, UILayout.Bottom)
    GUI.SetVisible(scr_GuardType_Bg, true)
    -- 检测到点击就销毁
    GUI.SetIsRemoveWhenClick(scr_GuardType_Bg, true)

    local childSize_GuardType = Vector2.New(105, 34)
    local scr_GuardType = GUI.ScrollRectCreate(scr_GuardType_Bg, "scr_GuardType", 0, 0, 105, 238, 0, false, childSize_GuardType, UIAroundPivot.Top, UIAnchor.Top)
    UILayout.SetSameAnchorAndPivot(scr_GuardType, UILayout.Center)

    for i = 1, #soul_grade do
        local btnName = ""
        local index = 0
        if i == 1 then
            btnName = soul_grade[#soul_grade] -- soul_type[#soul_type][1]
        else
            btnName = soul_grade[i - 1] -- soul_type[i - 1][1]
        end
        index = i - 1
        local btn = GUI.ButtonCreate(scr_GuardType, i - 1, "1800600100", 0, 0, Transition.ColorTint, btnName, 105, 32, false)
        GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(btn, UIDefine.FontSizeS)

        GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardSoulUI", "soul_material_type_select_one_btn_click")

        if not GuardSoulUI.soul_material_kind_select_data then
            GuardSoulUI.soul_material_kind_select_data = {}
        end

        GuardSoulUI.soul_material_kind_select_data[GUI.GetGuid(btn)] = index
    end
end

-- #强化材料类型按钮点击，选中某个类型进行筛选
function GuardSoulUI.soul_material_type_select_one_btn_click(guid, type)
    if type == nil then
        if next(GuardSoulUI.soul_material_kind_select_data) == nil then
            test(" GuardSoulUI.soul_material_type_select_one_btn_click(guid)")
            return ""
        end

        local index = GuardSoulUI.soul_material_kind_select_data[guid]
        if index == nil then
            test("GuardSoulUI.soul_material_type_select_one_btn_click(guid) 缺少soul_material_kind_select_data[guid]参数")
            return ""
        end
        GuardSoulUI.select_soul_material_type = tonumber(index)
    else
        GuardSoulUI.select_soul_material_type = type
    end

    local txt = _gt.GetUI("reinforced_page_select_type_btn_txt")
    if txt then
        GUI.StaticSetText(txt, GuardSoulUI.select_soul_material_type == 0 and soul_grade[#soul_grade] or soul_grade[GuardSoulUI.select_soul_material_type])
    end

    -- set nil
    GuardSoulUI.select_materials_data = nil

    if GuardSoulUI.soul_items_of_bag == nil or GuardSoulUI.have_eaten_soul_need_refresh_bag_soul_items then
        GuardSoulUI.get_bag_soul_items()
        GuardSoulUI.have_eaten_soul_need_refresh_bag_soul_items = nil
    end

    local data = GuardSoulUI.soul_items_of_bag
    -- 对数据进行排序
    table.sort(data, GuardSoulUI.sort_by_type)
    GuardSoulUI.show_material_scroll_data = data

    -- 刷新强化材料部分
    GuardSoulUI.refresh_reinforced_soul_material_box(data)

    -- 刷新中间升级部分
    GuardSoulUI.refresh_soul_up_level_and_detail()
end

-- #吞噬命魂点击
function GuardSoulUI.eat_soul_btn_click()
    -- 判断是否满级，满级时给个提示
    if GuardSoulUI.isSoulMaxLevel ~= true then
        GuardSoulUI.Intensify_LevelUp_request()
    else
        GlobalUtils.ShowBoxMsg2BtnNoCloseBtn("提示", "所选命魂经验已超出最大等级。", "GuardSoulUI", "确定", "Intensify_LevelUp_request", "取消")
    end

    GuardSoulUI.isSoulMaxLevel = nil
end

-- #锁定洗炼属性多选框 锁定洗炼属性
function GuardSoulUI.deputy_property_check_box_click(guid)
    local check_box = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(check_box, "index"))

    if GuardSoulUI.select_deputy_property_data == nil then
        GuardSoulUI.select_deputy_property_data = {}
    end

    -- 判断是需要锁定还是取消锁定
    if GUI.CheckBoxExGetCheck(check_box) then
        -- 计算已经锁定了多少个
        local deputy_count = 0
        for k, v in pairs(GuardSoulUI.select_deputy_property_data) do
            if v == true then
                deputy_count = deputy_count + 1
            end
        end

        -- 当前选中物品的等级
        local level = 0
        if GuardSoulUI.select_soul_data_of_reinforce_page then
            local item_obj = nil
            if GuardSoulUI.select_soul_data_of_reinforce_page.guard_guid then
                item_obj = LD.GetItemDataByGuid(GuardSoulUI.select_soul_data_of_reinforce_page .item_guid,
                        item_container_type.item_container_guard_equip, GuardSoulUI.select_soul_data_of_reinforce_page .guard_guid)
            else
                item_obj = LD.GetItemDataByGuid(GuardSoulUI.select_soul_data_of_reinforce_page .item_guid, item_container_type.item_container_guard_equip)
            end

            if item_obj then
                level = item_obj:GetIntCustomAttr("minghun_intensify_level")
            end
        end

        -- 当前激活属性的个数
        local attr_count = 0
        if GuardSoulUI.minghun_refining_attr_openlevel then
            for k, v in ipairs(GuardSoulUI.minghun_refining_attr_openlevel) do
                if level < v then
                    attr_count = k - 1
                    break
                end
            end
        end

        if attr_count ~= 0 and deputy_count >= attr_count - 1 then
            CL.SendNotify(NOTIFY.ShowBBMsg, "当前最多锁定" .. deputy_count .. "条附加属性")
            GUI.CheckBoxExSetCheck(check_box, false)
            return ""
        end

        GuardSoulUI.select_deputy_property_data[index] = true
    else
        if GuardSoulUI.select_deputy_property_data[index] then
            GuardSoulUI.select_deputy_property_data[index] = nil
        end
    end

    GuardSoulUI.refresh_baptized_page()
end

-- #保存按钮
function GuardSoulUI.keep_deputy_property_btn_click()
    if GuardSoulUI.select_soul_data_of_reinforce_page == nil or GuardSoulUI.select_soul_data_of_reinforce_page.item_guid == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中一个命魂")
        return ""
    end

    -- 命魂开启等级
    local open_level = 5
    if GuardSoulUI.minghun_refining_attr_openlevel then
        open_level = GuardSoulUI.minghun_refining_attr_openlevel[1]
    end
    -- 注意命魂等级
    local item_level = 0
    local item_obj = nil
    local d = GuardSoulUI.select_soul_data_of_reinforce_page
    if d.guard_guid then
        item_obj = LD.GetItemDataByGuid(d.item_guid, item_container_type.item_container_guard_equip, d.guard_guid)
    else
        item_obj = LD.GetItemDataByGuid(d.item_guid, item_container_type.item_container_guard_equip)
    end
    if item_obj then
        item_level = item_obj:GetIntCustomAttr("minghun_intensify_level")
    end

    if item_level < open_level then
        CL.SendNotify(NOTIFY.ShowBBMsg, "当前选中的命魂等级不足")
        return ""
    end

    GuardSoulUI.Save_Refining_Attt_request()
end

-- #洗炼按钮
function GuardSoulUI.baptized_btn_click_to_change_property(guid)
    local btn = GUI.GetByGuid(guid)
    local is_save_material_ok = GUI.GetData(btn, "is_save_material_ok")
    local is_baptize_material_ok = GUI.GetData(btn, "is_baptize_material_ok")

    if GuardSoulUI.select_soul_data_of_reinforce_page == nil or GuardSoulUI.select_soul_data_of_reinforce_page.item_guid == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中一个命魂")
        return ""
    end

    -- 命魂开启等级
    local open_level = 5
    if GuardSoulUI.minghun_refining_attr_openlevel then
        open_level = GuardSoulUI.minghun_refining_attr_openlevel[1]
    else
        test("GuardSoulUI.baptized_btn_click_to_change_property(guid) GuardSoulUI.minghun_refining_attr_openlevel == nil")
    end
    -- 注意命魂等级
    local item_level = 0
    local item_obj = nil
    local d = GuardSoulUI.select_soul_data_of_reinforce_page
    if d.guard_guid then
        item_obj = LD.GetItemDataByGuid(d.item_guid, item_container_type.item_container_guard_equip, d.guard_guid)
    else
        item_obj = LD.GetItemDataByGuid(d.item_guid, item_container_type.item_container_guard_equip)
    end
    if item_obj then
        item_level = item_obj:GetIntCustomAttr("minghun_intensify_level")
    end

    if item_level < open_level then
        CL.SendNotify(NOTIFY.ShowBBMsg, "当前洗炼的命魂等级不足")
        return ""
    end

    GuardSoulUI.Refining_Attr_Random_request()
end

-- #命魂强化列表中某个命魂点击
function GuardSoulUI.soul_list_scroll_one_btn_click(guid)
    local btn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(btn, "index"))
    local item_guid = GUI.GetData(btn, "item_guid")
    local guard_guid = GUI.GetData(btn, "guard_guid")

    -- 防止重复点击
    if GuardSoulUI.select_soul_data_of_reinforce_page and item_guid == GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
        return ""
    end

    local btnSelectImage = GUI.GetChild(btn, "btnSelectImage")
    GUI.SetVisible(btnSelectImage, true)

    GuardSoulUI.select_soul_data_of_reinforce_page = { item_guid = item_guid, guard_guid = guard_guid, index = index }

    -- 刷新命魂列表
    local scr_Guard = _gt.GetUI("reinforced_page_scr_Guard")
    GUI.LoopScrollRectSetTotalCount(scr_Guard, #GuardSoulUI.show_soul_list_data_of_reinforce_page)
    GUI.LoopScrollRectRefreshCells(scr_Guard)

    GuardSoulUI.refresh_soul_up_level_and_detail(GuardSoulUI.select_soul_data_of_reinforce_page)

    -- 将锁定的附加属性去除
    GuardSoulUI.select_deputy_property_data = nil
    -- 刷新命魂强化材料界面或命魂洗炼界面
    if GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == nil or GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == "reinforced_btn" then
        -- 刷新洗炼界面
        -- 刷新材料界面
        if GuardSoulUI.show_material_scroll_data then
            GuardSoulUI.refresh_reinforced_soul_material_box(GuardSoulUI.show_material_scroll_data)
        else
            -- local data = GuardSoulUI.filter_material_by_grade(GuardSoulUI.soul_items_of_bag, GuardSoulUI.select_soul_material_type)
            -- GuardSoulUI.refresh_reinforced_soul_material_box(data)
            test("GuardSoulUI.soul_list_scroll_one_btn_click(guid)  刷新材料界面  show_material_scroll_data == nil")
        end
    elseif GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == "baptized_btn" then
        GuardSoulUI.baptized_btn_click(nil, true)
    end

end

-- #强化界面中的物品材料点击
function GuardSoulUI.reinforced_material_box_click(guid)
    local btn = GUI.GetByGuid(guid)
    local item_guid = GUI.GetData(btn, "itemGuid")
    local index = GUI.GetData(btn, "index")

    if GuardSoulUI.select_materials_data == nil then
        GuardSoulUI.select_materials_data = {}
    end

    -- 判断限制条件
    local select_soul_data = GuardSoulUI.select_soul_data_of_reinforce_page
    if select_soul_data == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选择强化命魂")
        test("GuardSoulUI.reinforced_material_box_click(guid) GuardSoulUI.select_soul_data_of_reinforce_page == nil")
        return ""
    end

    if item_guid == select_soul_data.item_guid then
        CL.SendNotify(NOTIFY.ShowBBMsg, "无法将当前命魂材料用于强化")
        test("GuardSoulUI.reinforced_material_box_click(guid) 筛选数据出错，命魂本身当作材料强化自身")
        return ""
    end

    local item_obj = nil
    local item_db = nil
    if select_soul_data.guard_guid then
        item_obj = LD.GetItemDataByGuid(select_soul_data.item_guid, item_container_type.item_container_guard_equip, select_soul_data.guard_guid)
    else
        item_obj = LD.GetItemDataByGuid(select_soul_data.item_guid, item_container_type.item_container_guard_equip)
    end

    if item_obj == nil then
        test("GuardSoulUI.reinforced_material_box_click(guid) item_obj 为空")
        return ""
    end

    local current_level = 0
    local current_experience = 0
    current_experience = item_obj:GetIntCustomAttr("minghun_intensify_have_exp")
    current_level = item_obj:GetIntCustomAttr("minghun_intensify_level")
    local item_db = DB.GetOnceItemByKey1(item_obj.id)

    local level_up_config = GuardSoulUI.minghun_level_up_config

    -- 显示当前的选中框，并隐藏上一次的选中框
    if GuardSoulUI.pre_select_material_index_of_reinforce_page then
        local parent = GUI.GetParentElement(btn)
        local pre_btn = GUI.GetChild(parent, "box_" .. GuardSoulUI.pre_select_material_index_of_reinforce_page)
        local pre_select_the_box = GUI.GetChild(pre_btn, "select_the_box" .. GuardSoulUI.pre_select_material_index_of_reinforce_page)
        GUI.SetVisible(pre_select_the_box, false)
    end

    local select_the_box = GUI.GetChild(btn, "select_the_box" .. index)
    if select_the_box then
        GUI.SetVisible(select_the_box, true)
    end
    GuardSoulUI.pre_select_material_index_of_reinforce_page = index

    -- 如果达到最大等级,且不是减少材料
    local select_img = GUI.GetChild(btn, "select_img")
    -- if GUI.GetVisible(select_the_box) == false then
    if GUI.GetVisible(select_img) == false then
        if current_level >= #level_up_config then
            CL.SendNotify(NOTIFY.ShowBBMsg, "已达到最大等级")
            return ""
        end

        -- 判断预使用等级是否达到最大等级
        local grade_exp = GuardSoulUI.minghun_grade_exp_config
        local loss_percentage = GuardSoulUI.minghun_loss_percentage
        local preview_add_experience = 0

        -- 计算选中的材料能增加的经验
        if GuardSoulUI.select_materials_data and next(GuardSoulUI.select_materials_data) then
            for k, v in pairs(GuardSoulUI.select_materials_data) do
                local exp = 0
                local material_item_obj = LD.GetItemDataByGuid(v, item_container_type.item_container_guard_equip)
                local level = material_item_obj:GetIntCustomAttr("minghun_intensify_level")
                local material_item_db = DB.GetOnceItemByKey1(material_item_obj.id)
                local add_grade_exp = grade_exp[material_item_db.Grade]
                local material_item_key = material_item_db.KeyName
                -- 判断是否是特殊配置的经验命魂
                if GuardSoulUI.minghun_key_exp_config and GuardSoulUI.minghun_key_exp_config[material_item_key] then
                    exp = GuardSoulUI.minghun_key_exp_config[material_item_key]
                else
                    local add_level_exp = 0
                    local coefficient = GuardSoulUI.minghun_need_grade_exp_config[material_item_db.Grade]
                    for i = 1, level do
                        if level_up_config[i] then
                            add_level_exp = (level_up_config[i] * coefficient) + add_level_exp
                        end
                    end

                    exp = add_level_exp
                    exp = exp * (loss_percentage / 100)
                    exp = exp + add_grade_exp
                end
                preview_add_experience = preview_add_experience + exp
            end
        else
            preview_add_experience = 0
        end

        local expCoefficient = GuardSoulUI.minghun_need_grade_exp_config[item_db.Grade]
        -- 计算能提升多少级
        local up_level_need_experience = (level_up_config[current_level + 1] or 0) * expCoefficient
        local preview_add_level = 0

        if preview_add_experience + current_experience > up_level_need_experience then
            local surplus_exp = preview_add_experience + current_experience - up_level_need_experience
            preview_add_level = 1
            for i = 1, #level_up_config do
                local up_level_need_exp = (level_up_config[current_level + preview_add_level + 1])
                if up_level_need_exp then
                    -- 不为空时再乘以系数
                    up_level_need_exp = up_level_need_exp * expCoefficient

                    if surplus_exp > up_level_need_exp then
                        surplus_exp = surplus_exp - up_level_need_exp
                        preview_add_level = preview_add_level + 1
                    else
                        break
                    end
                else
                    if preview_add_level + current_level >= #level_up_config then
                        CL.SendNotify(NOTIFY.ShowBBMsg, "已达到最大等级")
                        return ""
                    end
                end
            end
        end
    end

    if GUI.GetVisible(select_img) then
        GuardSoulUI.select_materials_data[tonumber(index)] = nil
    else
        GuardSoulUI.select_materials_data[tonumber(index)] = item_guid
    end
    GUI.SetVisible(select_img, not GUI.GetVisible(select_img))

    -- refresh reinforced review
    GuardSoulUI.refresh_soul_up_level_and_detail(GuardSoulUI.select_soul_data_of_reinforce_page)

    -- 显示tips
    if item_guid and item_guid ~= '' then
        local panelBg = _gt.GetUI('panelBg')
        Tips.createSoulTipsByItemGuid(item_guid, panelBg, -342, 0, nil, nil, false)
    end
end

-- #洗炼材料点击弹出tips
function GuardSoulUI.baptize_material_click(guid)
    local btn = GUI.GetByGuid(guid)
    local itemId = tonumber(GUI.GetData(btn, "item_id"))

    if itemId == nil then
        test("GuardSoulUI.baptize_material_click(guid) item_id == nil")
        return ""
    end

    local parent = _gt.GetUI("reinforced_page")
    local fontColor2 = "662F16"
    if itemId ~= nil then
        local tips = Tips.CreateByItemId(tostring(itemId), parent, "UpStarTips", 0, 0)
        _gt.BindName(tips, "UpStarGetTips")
        -- 290
        GUI.SetHeight(tips, 320)
        local btn = GUI.ButtonCreate(tips, "getWayBtn_" .. itemId, "1800402110", 0, -7, Transition.ColorTint, "<color=#" .. fontColor2 .. "><size=" .. UIDefine.FontSizeM .. ">获取途径</size></color>", 150, 50, false)
        SetAnchorAndPivot(btn, UIAnchor.Bottom, UIAroundPivot.Bottom)
        GUI.SetData(tips, "ItemId", itemId)
        GUI.RegisterUIEvent(btn, UCE.PointerClick, "GuardSoulUI", "OnUpStarGetBtnClick")
        GUI.AddWhiteName(tips, GUI.GetGuid(btn)) -- 添加到对应的点击销毁白名单
    end
end

-- # 被强化的命魂点击tips
function GuardSoulUI.willIntensifySoulClick(guid)
    local panelBg = _gt.GetUI("panelBg")
    local item_guid = nil
    if GuardSoulUI.select_soul_data_of_reinforce_page and GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
        item_guid = GuardSoulUI.select_soul_data_of_reinforce_page.item_guid
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中需要强化的命魂")
        return ""
    end

    -- 如果是装备中
    if GuardSoulUI.select_soul_list_position_of_reinforce_page == "equipment" then
        local guard_guid = GuardSoulUI.select_soul_data_of_reinforce_page.guard_guid
        if guard_guid then
            local guard_id = LD.GetGuardIDByGUID(guard_guid)
            if guard_id then
                -- 写入一个错误的装备位置，因为tips没有点击按钮，不影响功能
                local tips = Tips.createSoulTipsByItemGuid(item_guid, panelBg, -338, 0, guard_id, 0, false)
            end
        end
    else
        local tips = Tips.createSoulTipsByItemGuid(item_guid, panelBg, -338, 0, nil, nil, false)
    end
end

-- 获取途径事件
function GuardSoulUI.OnUpStarGetBtnClick()
    local tip = _gt.GetUI("UpStarGetTips")
    if tip then
        Tips.ShowItemGetWay(tip) -- 显示获取途径页面
    end
end

-- >request-tab2--

-- reinforce soul
function GuardSoulUI.Intensify_LevelUp_request()
    -- server function
    -- FormMingHun.Intensify_LevelUp(player,minghun_guid,itemstr)  --命魂强化
    -- return data
    -- call back
    -- GuardSoulUI.Intensify_LevelUp_response()

    if GuardSoulUI.select_materials_data == nil or next(GuardSoulUI.select_materials_data) == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选择消耗材料")
        return ""
    end

    if GuardSoulUI.select_soul_data_of_reinforce_page == nil or GuardSoulUI.select_soul_data_of_reinforce_page.item_guid == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中强化的命魂物品")
        return ""
    end

    local reinforced_soul_item_guid = GuardSoulUI.select_soul_data_of_reinforce_page.item_guid
    local guard_guid = GuardSoulUI.select_soul_data_of_reinforce_page.guard_guid
    if guard_guid == nil then
        guard_guid = 0
    end
    local material_string = ""
    for k, v in pairs(GuardSoulUI.select_materials_data) do
        material_string = material_string .. "_" .. v
    end

    CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "Intensify_LevelUp", tostring(reinforced_soul_item_guid), material_string, tostring(guard_guid))
end

-- get preview attribute data
function GuardSoulUI.Intensify_Attr_Preview_request(soul_guid, add_level)
    -- server function
    -- FormMingHun.Intensify_Attr_Preview(player,minghun_guid,add_level) 强化属性预览数据
    -- return data
    -- GuardSoulUI.attribute_preview_list
    -- call back
    -- GuardSoulUI.Intensify_Attr_Preview_response()
    CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "Intensify_Attr_Preview", tostring(soul_guid), tostring(add_level))
end

-- get reinforced config
function GuardSoulUI.Intensify_GetData_request()
    -- server function
    -- FormMingHun.Intensify_GetData(player)
    -- return data
    -- GuardSoulUI.minghun_grade_exp_config = nil
    -- GuardSoulUI.minghun_level_up_config = nil
    -- GuardSoulUI.minghun_loss_percentage = nil

    -- GuardSoulUI.minghun_refining_attr_openlevel --命魂洗炼条目开启等级配置
    -- GuardSoulUI.minghun_refining_item_config   --命魂洗炼消耗物品配置
    -- GuardSoulUI.minghun_need_grade_exp_config -- 根据命魂品质命魂升级所需经验倍数
    -- GuardSoulUI.minghun_key_exp_config -- 特殊经验命魂数据

    -- GuardSoulUI.minghun_refining_attr_mark  -- 获取附加属性的mark值

    -- call back
    -- GuardSoulUI.Intensify_GetData_response()
    CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "Intensify_GetData")
end

-- 请求洗炼数据
function GuardSoulUI.Refining_GetAttrData_request()
    -- FormMingHun.Refining_GetAttrData(player,item_guid)   --得到命魂洗炼属性数据

    -- GuardSoulUI.minghun_refining_have_attr  --已拥有的属性
    -- GuardSoulUI.minghun_refining_save_attr  --保存的属性

    if GuardSoulUI.select_soul_data_of_reinforce_page and GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
        CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "Refining_GetAttrData", tostring(GuardSoulUI.select_soul_data_of_reinforce_page .item_guid))
    else
        -- 刷新界面
        GuardSoulUI.refresh_baptized_page(GuardSoulUI.minghun_refining_save_attr)
    end
end

-- 发送命魂洗炼请求
function GuardSoulUI.Refining_Attr_Random_request()
    -- FormMingHun.Refining_Attr_Random(player,item_guid,lock_str)  --命魂洗炼

    if GuardSoulUI.select_soul_data_of_reinforce_page and GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
        local item_guid = GuardSoulUI.select_soul_data_of_reinforce_page.item_guid

        local lock_str = ""
        if GuardSoulUI.select_deputy_property_data then
            for k, v in pairs(GuardSoulUI.select_deputy_property_data) do
                lock_str = lock_str .. "_" .. k
            end
        end

        CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "Refining_Attr_Random", tostring(item_guid), lock_str)
    end
end

-- 发送保存洗炼属性请求
function GuardSoulUI.Save_Refining_Attt_request()
    -- FormMingHun.Save_Refining_Attt(player,item_guid)  --洗炼属性保存
    if GuardSoulUI.select_soul_data_of_reinforce_page and GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
        local item_guid = GuardSoulUI.select_soul_data_of_reinforce_page.item_guid
        local guard_guid = GuardSoulUI.select_soul_data_of_reinforce_page.guard_guid
        if guard_guid == nil then
            guard_guid = 0
        end
        CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "Save_Refining_Attt", tostring(item_guid), tostring(guard_guid))
    else
        test("GuardSoulUI.Save_Refining_Attt_request()  所需要的数据为空 ")
        return ""
    end
end

-- 发送获取附加属性请求
function GuardSoulUI.Refining_GetHaveAttrData_request()
    -- FormMingHun.Refining_GetHaveAttrData(player,item_guid)
    -- GuardSoulUI.minghun_refining_have_attr  --已拥有的属性
    -- GuardSoulUI.Refining_GetHaveAttrData_response

    if GuardSoulUI.select_soul_data_of_reinforce_page and GuardSoulUI.select_soul_data_of_reinforce_page.item_guid then
        CL.SendNotify(NOTIFY.SubmitForm, "FormMingHun", "Refining_GetHaveAttrData", tostring(GuardSoulUI.select_soul_data_of_reinforce_page .item_guid))
    else
        -- 刷新附加属性界面
        GuardSoulUI.refresh_add_attribute()
    end
end

-- >response-tab2--

function GuardSoulUI.Intensify_LevelUp_response()
    GuardSoulUI.select_materials_data = nil

    GuardSoulUI.have_eaten_soul_need_refresh_bag_soul_items = true

    -- refresh page
    if GuardSoulUI.select_soul_list_position_of_reinforce_page == "equipment" then
        GuardSoulUI.in_equipment_btn_click(nil, true)
    elseif GuardSoulUI.select_soul_list_position_of_reinforce_page == "knapsack" then
        GuardSoulUI.in_knapsack_btn_click(nil, true)
    end

    GuardSoulUI.reinforced_btn_click(nil, true)
end

function GuardSoulUI.Intensify_Attr_Preview_response()
    if GuardSoulUI.attribute_preview_list then
        local reinforced_page = _gt.GetUI("reinforced_page")
        local up_level_bg = GUI.GetChild(reinforced_page, "soul_up_level_bg")
        local up_attribute_bg = GUI.GetChild(up_level_bg, "up_attribute_bg")
        local up_level_attr = GUI.GetChild(up_attribute_bg, "up_level_attr")
        if up_level_attr then
            local attr_id = nil
            local value = nil
            for k, v in pairs(GuardSoulUI.attribute_preview_list) do
                attr_id = k
                value = v
                break
            end
            if attr_id then
                local attr_db = DB.GetOnceAttrByKey1(attr_id)

                if attr_db.IsPct == 1 then
                    value = tostring(tonumber(value) / 100) .. "%"
                end

                if GuardSoulUI.one_level_intensify_attr_preview == true then
                    GUI.StaticSetText(up_level_attr, (attr_db.ChinaName or "无属性") .. " <color=#aa7830ff>" .. (value or 0) .. "</color>")
                    GuardSoulUI.one_level_intensify_attr_preview = nil
                else
                    GUI.StaticSetText(up_level_attr, (attr_db.ChinaName or "无属性") .. " <color=#30aa1dff>" .. (value or 0) .. "</color>")
                end
            end
        end
    end
end

function GuardSoulUI.Intensify_GetData_response()
    -- 如果是tips跳转过来的，并且携带了tips显示物品的数据
    if GuardSoulUI.clickTipsSelectASoulItem then
        local d = GuardSoulUI.clickTipsSelectASoulItem
        -- 如果有装备位置数据，是装备中的命魂
        if d.position then
            -- 点击装备中按钮
            GuardSoulUI.in_equipment_btn_click()
        else
            -- 如果没有装备位置数据，是背包中的命魂
            GuardSoulUI.in_knapsack_btn_click()
        end

        -- 如果不是tips跳转过来的默认未装备中按钮
    else
        -- 点击装备中按钮
        GuardSoulUI.in_equipment_btn_click()
    end

    if GuardSoulUI.tips_open_reinforced_or_baptize == nil or GuardSoulUI.tips_open_reinforced_or_baptize == "reinforced" or GuardSoulUI.tips_open_reinforced_or_baptize ~= "baptize" then
        GuardSoulUI.reinforced_btn_click()
    else
        GuardSoulUI.baptized_btn_click()
    end
end

function GuardSoulUI.Refining_GetAttrData_response()
    -- GuardSoulUI.minghun_refining_have_attr  --已拥有的属性
    -- GuardSoulUI.minghun_refining_save_attr  --保存的属性

    if GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn == "baptized_btn" then
        GuardSoulUI.refresh_baptized_page(GuardSoulUI.minghun_refining_save_attr)
    end
end

function GuardSoulUI.Refining_Attr_Random_response()
    -- 刷新洗炼界面
    GuardSoulUI.refresh_baptized_page(GuardSoulUI.minghun_refining_save_attr)
end

function GuardSoulUI.Save_Refining_Attt_response()
    -- 刷新中间部分 命魂升级和附加属性界面
    GuardSoulUI.refresh_soul_up_level_and_detail(GuardSoulUI.select_soul_data_of_reinforce_page)
    -- 刷新洗炼界面
    GuardSoulUI.refresh_baptized_page()
end

function GuardSoulUI.Refining_GetHaveAttrData_response()
    -- 刷新附加属性
    GuardSoulUI.refresh_add_attribute()
end

-- #other-function --

-- 显示侍从拥有数量/总数量
function GuardSoulUI.ShowHaveGuardInfo()
    local haveLst = LD.GetActivedGuard()
    local haveCount = haveLst and haveLst.Count or 0

    local allCount = nil
    -- 如果侍从种类不是全部
    if GuardSoulUI.SortedGuardIDLst and GuardSoulUI.SortedGuardIDLst.Count ~= 0 and GuardSoulUI.SelectType ~= 0 then
        allCount = GuardSoulUI.SortedGuardIDLst.Count

        -- 计算此种类侍从拥有的数量
        local count = 0
        for i = 0, haveCount - 1 do
            local guard = DB.GetOnceGuardByKey1(haveLst[i])
            if guard.Id ~= 0 and guard.Type and guard.Type == GuardSoulUI.SelectType then
                count = count + 1
            end
        end
        haveCount = count
    else
        local allLst = LD.GetGuardList_Have_Sorted()
        allCount = allLst and allLst.Count or 0
    end
    local haveGuardCount = _gt.GetUI("haveGuardCount")
    if haveGuardCount then
        GUI.StaticSetText(haveGuardCount, tostring(haveCount) .. "/" .. tostring(allCount))
    end
end

-- 人物特效表 从二星开始
local _RoleEffectTable = { 10, 11, 12, 13, 14 }
-- 销毁人物特效ID列表
GuardSoulUI._DestroyRoleEffectTable = {}

function GuardSoulUI.addRoleEffect()
    local _RoleModel = _gt.GetUI("GuardModel") -- 获取人物模型
    if _RoleModel == nil then
        test("添加人物气势特效时，获取人物模型为空")
        return
    end

    if GuardSoulUI.SelectGuardID == nil then
        test("添加人物气势特效时，获取选中侍从ID为空")
        return
    end

    -- 删除人物特效
    local DestroyRoleEffectID = GuardSoulUI._DestroyRoleEffectTable[tostring(GuardSoulUI.SelectGuardID)]
    if DestroyRoleEffectID ~= nil then
        -- 获取创建特效时得到的特效ID
        GUI.DestroyRoleEffect(_RoleModel, DestroyRoleEffectID)
        GuardSoulUI._DestroyRoleEffectTable[tostring(GuardSoulUI.SelectGuardID)] = nil
    end
    -- 获取人物当前星级
    local currentSelectedGuardStar = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardSoulUI.SelectGuardID)))

    -- 添加人物特效
    if currentSelectedGuardStar > 1 then
        -- 防止星级为1
        local newDestroyRoleEffectID = GUI.CreateRoleEffect(_RoleModel, _RoleEffectTable[currentSelectedGuardStar - 1]) -- 添加人物特效
        -- 更新销毁人物特效ID
        GuardSoulUI._DestroyRoleEffectTable[tostring(GuardSoulUI.SelectGuardID)] = newDestroyRoleEffectID
    end
end

-- 创建格子矩阵
function GuardSoulUI.create_matrix_box(father_ui, _row, _column, _background_img, _size, _spacing, _is_scroll)
    if father_ui == nil then
        test("GuardSoulUI.create_matrix_box(father_ui, _row, _column, _background_img, _size, _spacing, _is_scroll) 无父节点参数")
        return ""
    end

    -- 多少行
    local row = 6
    -- 多少列
    local column = 6

    if _row then
        row = _row
    end

    if _column then
        if _column > 6 then
            column = _column
        end
    end

    -- 物品框大小
    local box_size = Vector2.New(80, 81)
    if _size then
        box_size = _size
    end
    -- 物品框之间的间隔
    local spacing_distance = Vector2.New(2, 2)
    if _spacing then
        spacing_distance = _spacing
    end

    -- 奖励格部分
    -- local w = (box_size.x + spacing_distance.x) * row - spacing_distance.x
    -- local h = (box_size.y + spacing_distance.y) * column - spacing_distance.y

    local w = GUI.GetWidth(father_ui)
    local h = GUI.GetHeight(father_ui)

    local matrix_box = GUI.GetChild(father_ui, "matrix_box")
    if matrix_box == nil then
        matrix_box = GUI.ScrollRectCreate(father_ui, "matrix_box", 0, 0, w, h, 0, false, box_size, UIAroundPivot.Center, UIAnchor.Center, _row)
    end

    UILayout.SetSameAnchorAndPivot(matrix_box, UILayout.Center)
    GUI.ScrollRectSetChildSpacing(matrix_box, spacing_distance)

    if _is_scroll ~= nil then
        GUI.ScrollRectSetVertical(matrix_box, _is_scroll and true or false)
    end

    if _gt then
        _gt.BindName(matrix_box, GUI.GetName(father_ui) .. "matrix_box")
    end

    -- 开始创建格子
    local box_group = matrix_box

    local num = row * column
    for i = 1, num do
        local box = GUI.GetChild(box_group, "box_" .. i)
        if box == nil then
            box = GUI.ItemCtrlCreate(box_group, "box_" .. i, _background_img or "1800600050", 0, 0, box_size.x, box_size.y, false)
        end
    end

    GUI.ScrollRectSetNormalizedPosition(matrix_box, Vector2.New(0, 1))

    return matrix_box
end

-- empty matrix_box
function GuardSoulUI.empty_matrix_box(_matrix_box, _background_img)
    local matrix_box = nil

    if _matrix_box == nil then
        -- test('GuardSoulUI.empty_matrix_box(_matrix_box, _background_img) matrix_box 参数为空')
        return ""
    else
        matrix_box = _matrix_box
    end

    local i = 1
    local box = GUI.GetChild(matrix_box, "box_" .. i)
    while box ~= nil do
        GUI.ItemCtrlSetElementValue(box, eItemIconElement.Icon, "")
        GUI.ItemCtrlSetElementValue(box, eItemIconElement.Border,
                _background_img or "1800600050")

        local level_bg = GUI.GetChild(box, "levelBg")
        if level_bg ~= nil then
            GUI.SetVisible(level_bg, false)
        end

        local bind_img = GUI.GetChild(box, "bind_img" .. i)
        if bind_img ~= nil then
            GUI.SetVisible(bind_img, false)
        end

        local select_the_box = GUI.GetChild(box, "select_the_box" .. i)
        if select_the_box then
            GUI.SetVisible(select_the_box, false)
        end

        local select_img = GUI.GetChild(box, "select_img")
        if select_img then
            GUI.SetVisible(select_img, false)
        end

        -- 命魂强化界面 取消监听事件
        GUI.UnRegisterUIEvent(box, UCE.PointerClick, "GuardSoulUI", "reinforced_material_box_click")
        GUI.UnRegisterUIEvent(box, UCE.PointerClick, "GuardSoulUI", "soul_item_box_one_click_of_soul_page")
        -- if have other , please add

        i = i + 1
        box = GUI.GetChild(matrix_box, "box_" .. i)
    end
end

-- change page 切换页签
function GuardSoulUI.change_page(page_id)
    local tab_index = nil
    if page_id then
        tab_index = page_id
        GuardSoulUI.TabIndex = tab_index
    else
        tab_index = GuardSoulUI.TabIndex
    end

    UILayout.OnTabClick(page_id, tabList)

    local panelBg = _gt.GetUI("panelBg")
    local title_bg = GUI.GetChild(panelBg, "titleBg")
    local title_txt = GUI.GetChild(title_bg, "titleText")

    local soul_page = _gt.GetUI("soul_page")
    if soul_page then
        local boolean = page_id == GuardSoulUI.get_index_of_tabList("soul_page")
        GUI.SetVisible(soul_page, boolean)
        if boolean then
            GUI.StaticSetText(title_txt, "侍 从 命 魂")

            -- 将强化页签的全局变量清空
            GuardSoulUI.current_select_is_reinforced_btn_or_baptized_btn = nil
            GuardSoulUI.select_soul_list_position_of_reinforce_page = nil
            GuardSoulUI.select_soul_data_of_reinforce_page = nil
            GuardSoulUI.select_materials_data = nil
        end
    end

    local reinforced_page = _gt.GetUI("reinforced_page")
    if reinforced_page then
        local boolean = page_id == GuardSoulUI.get_index_of_tabList("reinforced_page")
        GUI.SetVisible(reinforced_page, boolean)
        if boolean then
            GUI.StaticSetText(title_txt, "命 魂 强 化")
        end
    end
end

-- get index of tabList
function GuardSoulUI.get_index_of_tabList(_page_name, _tab_list, _name_index)
    if _page_name == nil then
        return ""
    end

    local page_name = nil
    local tab_list = nil
    local name_index = nil

    page_name = _page_name

    if _tab_list and type(_tab_list) == "table" then
        tab_list = _tab_list
    else
        tab_list = tabList
    end

    if _name_index then
        name_index = _name_index
    else
        name_index = 4
    end

    for k, v in ipairs(tab_list) do
        if v[name_index] == page_name then
            return k
        end
    end

    return ""
end

-- 模型点击回调
function GuardSoulUI.OnAnimationCallBack(guid, action)
    if action == System.Enum.ToInt(eRoleMovement.ATTSTAND_W1) then
        return
    end
    local model = _gt.GetUI("GuardModel")
    if model then
        GUI.ReplaceWeapon(model, 0, eRoleMovement.ATTSTAND_W1, 0)
    end
end

-- #获取背包中的所有命魂物品
function GuardSoulUI.get_bag_soul_items()
    GuardSoulUI.soul_items_of_bag = {}
    local data = {}
    local bag_items_count = LD.GetItemCount(item_container_type.item_container_guard_equip)

    for i = 0, bag_items_count - 1 do
        local item_guid = tostring(LD.GetItemGuidByItemIndex(i, item_container_type.item_container_guard_equip))

        -- 物品id
        local item_id = LD.GetItemAttrByGuid(ItemAttr_Native.Id, item_guid, item_container_type.item_container_guard_equip)

        local item_obj = DB.GetOnceItemByKey1(item_id)
        if item_obj.Type == 8 then
            -- 物品是否绑定
            local is_bind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, item_guid, item_container_type.item_container_guard_equip)
            is_bind = (is_bind ~= "0")
            -- 物品类型v
            -- 物品等级
            local level = LD.GetItemIntCustomAttrByGuid("minghun_intensify_level", item_guid, item_container_type.item_container_guard_equip)
            -- 物品图标v
            -- 物品品质v

            data = {
                id = item_id,
                guid = item_guid,
                icon = item_obj.Icon,
                grade = item_obj.Grade,
                type = item_obj.Subtype,
                level = level ~= 0 and level or 0,
                is_bind = is_bind
            }
            table.insert(GuardSoulUI.soul_items_of_bag, data)
        end
    end

    return GuardSoulUI.soul_items_of_bag
end

function GuardSoulUI.sort_by_type(a, b)
    local A, B = nil, nil

    if a.type == nil or b.type == nil then
        A = {}
        B = {}
        if a.guid or a.item_guid then
            local item_guid = a.guid or a.item_guid
            local item_obj = nil
            if a.guard_guid then
                item_obj = LD.GetItemDataByGuid(item_guid, item_container_type.item_container_guard_equip, a.guard_guid)
            else
                item_obj = LD.GetItemDataByGuid(item_guid, item_container_type.item_container_guard_equip)
            end
            local item_db = nil
            if item_obj then
                item_db = DB.GetOnceItemByKey1(item_obj.id)
                A.type = item_db.Subtype
                A.grade = item_db.Grade
                A.id = item_db.Id
                A.level = item_obj:GetIntCustomAttr("minghun_intensify_level")
                A.guid = item_guid
                a = A
            else
                test("GuardSoulUI.sort_by_type(a, b) 排序时错误")
                return true
            end
        end

        if b.guid or b.item_guid then
            local item_guid = b.guid or b.item_guid
            local item_obj = nil
            if b.guard_guid then
                item_obj = LD.GetItemDataByGuid(item_guid, item_container_type.item_container_guard_equip, b.guard_guid)
            else
                item_obj = LD.GetItemDataByGuid(item_guid, item_container_type.item_container_guard_equip)
            end
            local item_db = nil
            if item_obj then
                item_db = DB.GetOnceItemByKey1(item_obj.id)
                B.type = item_db.Subtype
                B.grade = item_db.Grade
                B.id = item_db.Id
                B.level = item_obj:GetIntCustomAttr("minghun_intensify_level")
                B.guid = item_guid
                b = B
            else
                test("GuardSoulUI.sort_by_type(a, b) 排序时错误")
                return true
            end
        end
    end

    -- type
    if a.type == 5 and b.type < 5 then
        return true
    elseif a.type < 5 and b.type == 5 then
        return false
    elseif a.type ~= b.type then
        return a.type < b.type
    else
        -- grade
        if a.grade ~= b.grade then
            return a.grade > b.grade
        else
            -- level
            if a.level ~= b.level then
                -- id
                return a.level > b.level
            else
                if a.id ~= b.id then
                    return a.id > b.id
                else
                    return a.guid > b.guid
                end
            end
        end
    end
end

function GuardSoulUI.equipmentSortOfReinforcePage(a, b)
    local A, B = nil, nil

    if a.type == nil or b.type == nil then
        A = {}
        B = {}
        if a.guid or a.item_guid then
            local item_guid = a.guid or a.item_guid
            local item_obj = nil
            if a.guard_guid then
                item_obj = LD.GetItemDataByGuid(item_guid, item_container_type.item_container_guard_equip, a.guard_guid)
            else
                item_obj = LD.GetItemDataByGuid(item_guid, item_container_type.item_container_guard_equip)
            end
            local item_db = nil
            if item_obj then
                item_db = DB.GetOnceItemByKey1(item_obj.id)
                A.type = item_db.Subtype
                A.grade = item_db.Grade
                A.id = item_db.Id
                A.level = item_obj:GetIntCustomAttr("minghun_intensify_level")
                A.guid = item_guid
                a = A
            else
                test("GuardSoulUI.sort_by_type(a, b) 排序时错误")
                return true
            end
        end

        if b.guid or b.item_guid then
            local item_guid = b.guid or b.item_guid
            local item_obj = nil
            if b.guard_guid then
                item_obj = LD.GetItemDataByGuid(item_guid, item_container_type.item_container_guard_equip, b.guard_guid)
            else
                item_obj = LD.GetItemDataByGuid(item_guid, item_container_type.item_container_guard_equip)
            end
            local item_db = nil
            if item_obj then
                item_db = DB.GetOnceItemByKey1(item_obj.id)
                B.type = item_db.Subtype
                B.grade = item_db.Grade
                B.id = item_db.Id
                B.level = item_obj:GetIntCustomAttr("minghun_intensify_level")
                B.guid = item_guid
                b = B
            else
                test("GuardSoulUI.sort_by_type(a, b) 排序时错误")
                return true
            end
        end
    end

    -- 特殊型排在最前面
    if a.type == 5 and b.type < 5 then
        return true
    elseif a.type < 5 and b.type == 5 then
        return false
    else
        -- grade
        if a.grade ~= b.grade then
            return a.grade > b.grade
        else
            -- level
            if a.level ~= b.level then
                -- type
                return a.level > b.level
            elseif a.type ~= b.type then
                return a.type < b.type
            else
                -- id
                if a.id ~= b.id then
                    return a.id > b.id
                else
                    return a.guid > b.guid
                end
            end
        end
    end
end

function GuardSoulUI.sort_by_level(a, b)
    -- level
    if a.level ~= b.level then
        return a.level > b.level
    else
        -- grade
        if a.grade ~= b.grade then
            return a.grade > b.grade
        else
            -- type
            if a.type ~= b.type then
                if a.type == 5 then
                    return true
                elseif b.type == 5 then
                    return false
                end
                return a.type < b.type
            else
                -- id
                return a.id > b.id
            end
        end
    end
end

function GuardSoulUI.filter_soul_by_type(_data, type)
    if type == 0 then
        return _data, #_data
    end

    local data = {}
    local type_count = 0
    for k, v in ipairs(_data) do
        if v.type == type then
            table.insert(data, v)
            type_count = type_count + 1
        end
    end
    return data, type_count
end

function GuardSoulUI.filter_soul_by_guid(_data, guid)
    if guid == nil or _data == nil then
        return ""
    end

    local data = {}
    for k, v in ipairs(_data) do
        if v.guid ~= guid then
            table.insert(data, v)
        end
    end

    return data
end

-- #物品变化监听事件
function GuardSoulUI.trigger_event_of_soul_item(item_guid, item_id)
    if item_id == nil then
        if GuardSoulUI.select_soul_data_of_reinforce_page and GuardSoulUI.select_soul_data_of_reinforce_page.guard_guid then
            local guard_guid = GuardSoulUI.select_soul_data_of_reinforce_page .guard_guid
            item_id = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id, item_guid, item_container_type.item_container_guard_equip, guard_guid))
        end
        if item_id == nil then
            item_id = tonumber(LD.GetItemAttrByGuid(ItemAttr_Native.Id, item_guid))
        end
    else
        item_id = tonumber(item_id)
    end
    local item = nil
    -- 如果查询到物品id,没有就退出
    if item_id then
        item = DB.GetOnceItemByKey1(item_id)
    else
        return ""
    end

    if item and item.Id ~= 0 then
        -- 判断是否是侍从命魂物品
        if item.Type == 8 then
            if GuardSoulUI.TabIndex == GuardSoulUI.get_index_of_tabList("soul_page") then
            elseif GuardSoulUI.TabIndex == GuardSoulUI.get_index_of_tabList("reinforced_page") then
            end
        end

        -- 判断是否是命魂洗炼材料
        if item.Type == 3 and item.Subtype == 17 then
            if item.KeyName == "命魂洗练锁" or item.KeyName == "命魂洗练" then
                -- 刷新洗炼页面
                local bg = _gt.GetUI("reinforced_and_baptized_bg")
                local group = GUI.GetChild(bg, "baptized_group")
                if GUI.GetVisible(group) then
                    GuardSoulUI.refresh_baptized_page()
                end
            end
        end
    end
end

function GuardSoulUI.when_update_soul_items_of_bag()
    GuardSoulUI.get_bag_soul_items()

    if GuardSoulUI.select_soul_type then
        GuardSoulUI.soul_item_select_one_type_click(nil, GuardSoulUI.select_soul_type)
    end

    if GuardSoulUI.order_type then
        if GuardSoulUI.order_type == "level" then
            local bg = GUI.GetChild(_gt.GetUI("soul_page"), "soul_item_box_bg")
            local level_check_box = GUI.GetChild(bg, "soul_item_box_level_sort_check")
            local guid = GUI.GetGuid(level_check_box)
            GuardSoulUI.soul_item_boxes_order_by_level_check_box_click(guid, true)
        elseif GuardSoulUI.order_type == "type" then
            local bg = GUI.GetChild(_gt.GetUI("soul_page"), "soul_item_box_bg")
            local type_check_box = GUI.GetChild(bg, "soul_item_box_type_sort_check")
            local guid = GUI.GetGuid(type_check_box)
            GuardSoulUI.soul_item_boxes_order_by_type_check_box_click(guid, true)
        end
    end
end

function GuardSoulUI.get_all_equipped_soul_of_guards()
    local data = {}
    local count = 0
    local all_guard_id = LD.GetGuardList_Have_Sorted()
    local Count = all_guard_id.Count
    for i = 0, Count - 1 do
        if LD.IsHaveGuard(all_guard_id[i]) then
            local guard_id = all_guard_id[i]
            local guard_guid = LD.GetGuardGUIDByID(guard_id)

            for i = 0, 5 do
                local item_guid = LD.GetItemGuidByItemIndex(i, item_container_type.item_container_guard_equip, guard_guid)
                item_guid = tostring(item_guid)
                if item_guid and item_guid ~= "0" then
                    local _data = {}
                    _data.guard_guid = guard_guid
                    _data.item_guid = item_guid
                    table.insert(data, _data)
                    count = count + 1
                else
                    break
                end
            end
        end
    end

    GuardSoulUI.all_soul_list_data_of_reinforce_page = data

    return GuardSoulUI.all_soul_list_data_of_reinforce_page, count
end

function GuardSoulUI.filter_equipped_soul_data(_data, _type)
    if _type == 0 then
        return _data
    end

    local data = nil
    if _data then
        data = _data
    else
        data = GuardSoulUI.all_soul_list_data_of_reinforce_page
    end

    local type = nil
    if _type then
        type = _type
    else
        type = GuardSoulUI.select_soul_list_type
    end

    local return_data = {}

    for k, v in ipairs(data) do
        if v.guard_guid then
            -- in knapsack
            local item_id = LD.GetItemAttrByGuid(ItemAttr_Native.Id, v.item_guid, item_container_type.item_container_guard_equip, v.guard_guid)
            local item_db = DB.GetOnceItemByKey1(item_id)
            if item_db.Subtype == _type then
                local _data = {}
                _data.guard_guid = v.guard_guid
                _data.item_guid = v.item_guid
                table.insert(return_data, _data)
            end
        else
            local item_id = LD.GetItemAttrByGuid(ItemAttr_Native.Id, v.guid, item_container_type.item_container_guard_equip)
            local item_db = DB.GetOnceItemByKey1(item_id)
            if item_db.Subtype == _type then
                local _data = {}
                _data.guid = v.guid
                table.insert(return_data, _data)
            end
        end
    end

    GuardSoulUI.show_soul_list_data_of_reinforce_page = return_data

    return GuardSoulUI.show_soul_list_data_of_reinforce_page
end

-- #根据品质筛选数据
function GuardSoulUI.filter_material_by_grade(data, grade)
    if grade == 0 then
        return nil, 0
    end

    if grade == 6 then
        local _data = {}
        for k, v in ipairs(data) do
            _data[k] = v.guid
        end
        return _data, #data
    end

    local _data = {}
    local grade_count = 0
    for k, v in ipairs(data) do
        if v.grade == grade then
            _data[k] = v.guid
            grade_count = grade_count + 1
        end
    end
    return _data, grade_count
end

-- 剔除某类型的数据
function GuardSoulUI.filterEquippedSoulDataByType(_data, _type)
    local data = _data
    local return_data = {}

    for k, v in ipairs(data) do
        if v.guard_guid then
            -- in knapsack
            local item_id = LD.GetItemAttrByGuid(ItemAttr_Native.Id,
                    v.item_guid,
                    item_container_type.item_container_guard_equip,
                    v.guard_guid)
            local item_db = DB.GetOnceItemByKey1(item_id)
            if item_db.Subtype ~= _type then
                local _data = {}
                _data.guard_guid = v.guard_guid
                _data.item_guid = v.item_guid
                table.insert(return_data, _data)
            end
        else
            local item_id = LD.GetItemAttrByGuid(ItemAttr_Native.Id, v.guid,
                    item_container_type.item_container_guard_equip)
            local item_db = DB.GetOnceItemByKey1(item_id)
            if item_db.Subtype ~= _type then
                local _data = {}
                _data.guid = v.guid
                table.insert(return_data, _data)
            end
        end
    end

    return return_data
end
