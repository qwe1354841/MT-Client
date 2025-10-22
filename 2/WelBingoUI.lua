-- 五星连珠界面



-- 奖励内侧未点亮图片
-- 空星星
local inside_image_no_lightened = '1801407110' --'1800607220'

-- 奖励内侧点亮图片
-- 亮星星
local inside_image_lightened = '1801407100' --'1800607221'

-- 普通奖励按钮图片
local award_normal_btn_img = '1800002030'
-- 当前被选中的奖励按钮图片
local award_select_btn_img = '1800002031'
-- 是否开启显示进行中字体，左边奖励预览的按钮上
local is_open_show_current_do_txt = false
-- 未开始的星图锁图片
local award_btn_lock_img = '1800408170'

-- 点亮动画每次移动的时间间隔
local lighten_animation_interval_time = 0.1
-- 点亮动画是否在运行
local is_run_lighten_animation = false

-- 界面名称
local page_name = '五星连珠'
-- 左边奖励选项名称
local left_award_name = '星图'
-- 框边的个数
local box_border_num = 7
-- 物品框大小
local box_size = Vector2.New(70, 70)
-- 物品框之间的间隔
local spacing_distance = Vector2.New(2, 2)

local WelBingoUI = {}
_G.WelBingoUI = WelBingoUI
-------------------------------start缓存一下常用的全局变量start---------------------------
local _gt = UILayout.NewGUIDUtilTable()
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------




function WelBingoUI.CreateSubPage(subBg)
    local page = GUI.GroupCreate(subBg, "WelBingoPage", 118, 60, 820, 550)
    SetSameAnchorAndPivot(page, UILayout.Top)
    _gt.BindName(page, 'WelBingoUI_page')

    -- 奖励格部分
    local w = (box_size.x + spacing_distance.x) * box_border_num - spacing_distance.x
    local h = (box_size.y + spacing_distance.y) * box_border_num - spacing_distance.y

    local box_all_group = GUI.GroupCreate(page, 'box_all_group', -158, 2, w + 10, h + 70)
    SetSameAnchorAndPivot(box_all_group, UILayout.Top)

    local img_bg = GUI.ImageCreate(box_all_group, 'scroll_img_bg', "1800400010", 0, 0, false, w + 10, h + 10)
    SetSameAnchorAndPivot(img_bg, UILayout.Top)

    local box_group = GUI.GroupCreate(img_bg, 'box_group', 0, 0, w, h)
    SetSameAnchorAndPivot(box_group, UILayout.Center)
    _gt.BindName(box_group, 'box_group')


    -- 激活次数
    local activate_text = GUI.CreateStatic(box_all_group, 'activate_text', '剩余点亮次数：0', -24, -4, 300, 60)
    SetSameAnchorAndPivot(activate_text, UILayout.Bottom)
    GUI.StaticSetFontSize(activate_text, UIDefine.FontSizeXL)
    --GUI.SetColor(activate_text, Color.New(255/255,251/255,225/255,255/255))
    GUI.SetColor(activate_text, UIDefine.BrownColor)
    GUI.StaticSetAlignment(activate_text, TextAnchor.MiddleLeft)
    _gt.BindName(activate_text, 'activate_text')
    ----设置颜色渐变
    --GUI.StaticSetIsGradientColor(activate_text,true)
    --GUI.StaticSetGradient_ColorTop(activate_text,Color.New(255/255,244/255,139/255,255/255))
    ----设置描边
    --GUI.SetIsOutLine(activate_text,true)
    --GUI.SetOutLine_Distance(activate_text,3)
    --GUI.SetOutLine_Color(activate_text,Color.New(182/255,52/255,40/255,255/255))
    ----设置阴影
    --GUI.SetIsShadow(activate_text,true)
    --GUI.SetShadow_Distance(activate_text,Vector2.New(0,-1))
    --GUI.SetShadow_Color(activate_text,UIDefine.BlackColor)


    -- i 图标
    local scoreHint = GUI.ButtonCreate(page, "scoreHint", "1800702030", -11, 10, Transition.ColorTint, "")
    SetSameAnchorAndPivot(scoreHint, UILayout.BottomRight)
    GUI.RegisterUIEvent(scoreHint, UCE.PointerClick, "WelBingoUI", "hint_event")

    -- 点亮按钮
    local activation_btn = GUI.ButtonCreate(page, 'activation_btn', '1800402090', -87, 16, Transition.ColorTint, "点  亮", 118, 50, false)
    SetSameAnchorAndPivot(activation_btn, UILayout.BottomRight)
    GUI.SetIsOutLine(activation_btn, true);
    GUI.ButtonSetTextFontSize(activation_btn, UIDefine.FontSizeXL);
    GUI.ButtonSetTextColor(activation_btn, UIDefine.WhiteColor);
    GUI.SetOutLine_Color(activation_btn, UIDefine.OutLine_GreenColor);
    GUI.SetOutLine_Distance(activation_btn, UIDefine.OutLineDistance);
    --GUI.SetEventCD(activation_btn, UCE.PointerClick, 1)
    _gt.BindName(activation_btn, 'activation_btn')
    GUI.RegisterUIEvent(activation_btn, UCE.PointerClick, 'WelBingoUI', 'activate_light')

    -- 获取按钮
    local funcBtn = GUI.ButtonCreate(page, "approach_of_achieving_Btn", "1800402110",
            -10, 10, Transition.ColorTint,
            "", 80, 38, false)
    SetSameAnchorAndPivot(funcBtn, UILayout.Bottom)
    GUI.RegisterUIEvent(funcBtn, UCE.PointerClick, 'WelBingoUI', 'approach_of_achieving_btn_event')
    -- 按钮上的文本
    local txt = GUI.CreateStatic(funcBtn, "txt", "获取", 0, 0, 80, 38)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)


    -- 创建界面
    WelBingoUI.create()

    WelBingoUI.register()
end

function WelBingoUI.OnShow(WelfareUIGuid)

    local rewardBg = WelfareUIGuid.GetUI("rewardBg")
    GUI.SetVisible(rewardBg, false)

    if WelBingoUI.box_data == nil then
        -- 向服务器请求数据刷新界面
        WelBingoUI.require_all_data()
    else

        local scroll = _gt.GetUI('task_list_scroll')
        if scroll == nil then
        else
            local task_node = GUI.GetChild(scroll, 'task_node_' .. 1)
            if task_node == nil then
                -- 创建左边查看奖励按钮列表
                WelBingoUI.create_show_award_btn_list(WelBingoUI.award_count or 6)
                -- 刷新左边奖励预览
                WelBingoUI.refresh_advance_award_list(1, WelBingoUI.award_count or 6)

            end
        end

        -- 重新打开界面后显示当前进行中的奖励界面
        if WelBingoUI.current_award_subscript then

            WelBingoUI.show_award_btn_event(nil, WelBingoUI.current_award_subscript)
            -- 调整左边奖励列表滚动位置
            local scroll = _gt.GetUI('task_list_scroll')
            GUI.ScrollRectSetNormalizedPosition(scroll, Vector2.New(0, WelBingoUI.current_award_subscript / WelBingoUI.award_count))

        end

        -- 请求数据，刷新点亮次数
        WelBingoUI.require_lighten_count()
    end

    -- 使点亮按钮可用
    local activation_btn = _gt.GetUI('activation_btn')
    if activation_btn then
        if GUI.ButtonGetShowDisable(activation_btn) == false then
            GUI.ButtonSetShowDisable(activation_btn, true)
        end
    end

end

function WelBingoUI.OnExitGame()
    if is_run_lighten_animation then
        --CL.SendNotify(NOTIFY.ShowBBMsg, '正在点亮中，请稍等')
        WelBingoUI.get_gift_behind_lighted()
        return ''
    end

end




-- 监听器
function WelBingoUI.register()
    CL.RegisterMessage(GM.PlayerExitGame, "WelBingoUI", 'register_event')
    CL.RegisterMessage(GM.PlayerExitLogin, "WelBingoUI", 'register_event')
end

function WelBingoUI.unregister()
    CL.UnRegisterMessage(GM.PlayerExitGame, "WelBingoUI", 'register_event')
    CL.UnRegisterMessage(GM.PlayerExitLogin, "WelBingoUI", 'register_event')
end

function WelBingoUI.register_event()
    WelBingoUI.unregister()
    WelBingoUI.box_data = nil
    WelBingoUI.current_select_award_index = nil
end




------------------------------------------------------------------------------- 创建部分
-- 创建所有
function WelBingoUI.create()
    -- 创建中间部分的所有格子
    WelBingoUI.scroll_cell_create()

    -- 创建奖励预览
    WelBingoUI.create_award_preview_left()

end

-- 创建奖励和点亮格子
function WelBingoUI.scroll_cell_create(n)

    local num = 6

    if box_border_num then
        num = box_border_num
    end

    if n then
        num = n
    end

    local x = 0
    local y = 0

    local box_group = _gt.GetUI('box_group')

    for i = 1, num do

        for j = 1, num do

            local box = GUI.GetChild(box_group, 'box' .. i .. '_' .. j)

            if box == nil then
                box = GUI.ItemCtrlCreate(box_group, 'box' .. i .. '_' .. j, "1800600050", x, y, box_size.x, box_size.y, false)
                SetSameAnchorAndPivot(box, UILayout.TopLeft)
                --GUI.SetVisible(box, false)
                --GUI.ItemCtrlSetElementRect(box, eItemIconElement.Icon, 0, -2, 67, 67)
                --GUI.ItemCtrlSetElementRect(box, eItemIconElement.Border, 0, 1.5, 76, 76)

                if (i == 1 or i == box_border_num) or (j == 1 or j == box_border_num) then
                    ----数量
                    local _Num = GUI.CreateStatic(box, "Num" .. i .. '_' .. j, "1", 16, -4, 50, 35)
                    SetSameAnchorAndPivot(_Num, UILayout.BottomLeft)
                    GUI.StaticSetFontSize(_Num, UIDefine.FontSizeS)
                    GUI.SetColor(_Num, UIDefine.WhiteColor)
                    GUI.SetIsOutLine(_Num, true)
                    GUI.SetOutLine_Distance(_Num, 1)
                    GUI.SetOutLine_Color(_Num, UIDefine.BlackColor)
                    GUI.StaticSetAlignment(_Num, TextAnchor.LowerRight)
                    --GUI.SetVisible(_Num, false)

                    -- 是否已获取图片
                    local is_acquire_img = GUI.ImageCreate(box, 'acquire_img', '1800608160', 0, 0, false, box_size.x, box_size.y)
                    SetSameAnchorAndPivot(is_acquire_img, UILayout.Center)

                    GUI.RegisterUIEvent(box, UCE.PointerClick, "WelBingoUI", "award_click_event")
                else

                end

            end

            x = x + box_size.x + spacing_distance.x

        end
        x = 0
        y = y + box_size.y + spacing_distance.y
    end
end

-- 创建左边奖励预览
function WelBingoUI.create_award_preview_left()

    local panelBg = _gt.GetUI('WelBingoUI_page')

    -- 奖励预览背景
    local task_bg = GUI.ImageCreate(panelBg, 'task_bg',
            '1800400010', -6, 2,
            false, 282, 510)
    SetSameAnchorAndPivot(task_bg, UILayout.TopRight)

    -- 名称
    local task_theme_name = GUI.CreateStatic(task_bg, 'task_theme_name', '奖励预览', 0, 0, 268, 80, 'system', true)
    SetSameAnchorAndPivot(task_theme_name, UILayout.Top)
    GUI.StaticSetAlignment(task_theme_name, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(task_theme_name, 40)
    GUI.SetColor(task_theme_name, UIDefine.BrownColor)
    GUI.SetIsOutLine(task_theme_name, true);
    --GUI.SetOutLine_Color(task_theme_name, UIDefine.WhiteColor);
    --GUI.SetOutLine_Distance(task_theme_name, UIDefine.OutLineDistance);

    -- 奖励预览选项
    local task_list_scroll = GUI.ScrollRectCreate(task_bg, 'task_list_scroll',
            0, 80, GUI.GetWidth(task_bg), GUI.GetHeight(task_bg) - 88,
            1, false, Vector2.New(250, 50),
            UIAroundPivot.Top, UIAnchor.Top, 1
    )
    SetSameAnchorAndPivot(task_list_scroll, UILayout.Top)
    GUI.ScrollRectSetChildSpacing(task_list_scroll, Vector2.New(0, 30))
    _gt.BindName(task_list_scroll, 'task_list_scroll')

end

-- 创建左边查看奖励按钮列表
function WelBingoUI.create_show_award_btn_list(count)
    local scroll = _gt.GetUI('task_list_scroll')
    local num = 6

    if count then
        num = count
    end

    for i = 1, num do

        local task_name = '星图一'

        local task_node = GUI.GetChild(scroll, 'task_node_' .. i)

        if task_node == nil then

            task_node = GUI.ButtonCreate(scroll, 'task_node_' .. i, award_normal_btn_img or '1800002030',
                    0, 0, Transition.ColorTint, task_name, 250, 50, false)
            GUI.ButtonSetTextFontSize(task_node, UIDefine.FontSizeL);
            GUI.ButtonSetTextColor(task_node, UIDefine.BrownColor);

            GUI.SetData(task_node, 'show_award_index', i)
            GUI.RegisterUIEvent(task_node, UCE.PointerClick, 'WelBingoUI', 'show_award_btn_event')

        end
    end
end

-- 创建任务列表内的格子
function WelBingoUI.create_task_cell_in_list()
    local task_content_scroll = _gt.GetUI('task_content_scroll')

    if task_content_scroll == nil then
        return ''
    end

    --WelBingoUI.show_task_data = nil
    -- 任务数量
    local count = (WelBingoUI.show_task_data and #WelBingoUI.show_task_data) or 100
    for i = 1, count do

        local data = {}

        if WelBingoUI.show_task_data then
            data = WelBingoUI.show_task_data[i]
        end

        local img = data.img or "1801109480"
        local name = data.name or '师门任务'
        --local finished_num = data.finished_num or 1  --已完成次数
        --local num = data.num or 1  -- 获得奖励需完成次数
        --local get_num = data.get_num or 1  --可获得点亮次数
        local message = data.explain or '任务简介'

        local task_bg = GUI.GetChild(task_content_scroll, 'task_bg_' .. i)

        if task_bg == nil then
            task_bg = GUI.ImageCreate(task_content_scroll, 'task_bg_' .. i, '1801100010', 0, 0)
            SetSameAnchorAndPivot(task_bg, UILayout.Center)

            -- 图标
            local icon = GUI.ItemCtrlCreate(task_bg, 'task_item_ctrl', '1800400050', 13, 0, 60, 60, false)
            SetSameAnchorAndPivot(icon, UILayout.Left)
            GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, img)
            GUI.ItemCtrlSetElementRect(icon, eItemIconElement.Icon, 1, -1, GUI.GetWidth(icon) - 8, GUI.GetHeight(icon) - 10)

            -- 任务标题
            local title = GUI.CreateStatic(task_bg, 'task_title', '', 80, 17, 100, 30)
            SetSameAnchorAndPivot(title, UILayout.TopLeft)
            GUI.StaticSetText(title, name)
            GUI.StaticSetAlignment(title, TextAnchor.MiddleLeft)
            GUI.StaticSetFontSize(title, UIDefine.FontSizeM)
            GUI.SetColor(title, UIDefine.BrownColor)

            local txt = GUI.CreateStatic(task_bg, 'task_content', '',
                    26, -5, 150, 52,
                    "system", false)
            SetSameAnchorAndPivot(txt, UILayout.Bottom)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
            GUI.StaticSetFontSize(txt, UIDefine.FontSizeSSS)
            GUI.SetColor(txt, UIDefine.BrownColor)
            GUI.StaticSetText(txt, message)

        end
    end

    -- 调整滚动位置
    GUI.ScrollRectSetNormalizedPosition(task_content_scroll, Vector2.New(0, 1))
end




------------------------------------------------------------------------------ 刷新部分
-- 刷新所有
function WelBingoUI.refresh()

    -- 创建左边查看奖励按钮列表
    WelBingoUI.create_show_award_btn_list(WelBingoUI.award_count or 6)
    -- 刷新左边奖励预览
    WelBingoUI.refresh_advance_award_list(1, WelBingoUI.award_count or 6)

    -- 刷新中间的格子
    WelBingoUI.scroll_cell_refresh()
    -- 刷新激活次数字体
    WelBingoUI.refresh_activate_txt()

end

-- 刷新奖励格子
function WelBingoUI.scroll_cell_refresh()
    local num = 6
    if box_border_num then
        num = box_border_num
    end

    local box_data = nil

    if WelBingoUI.box_data then
        box_data = WelBingoUI.box_data

    else
        test('WelBingoUI.scroll_cell_refresh() 参数WelBingoUI.box_data 为空')
        return ''
    end

    for i = 1, num do

        for j = 1, num do

            WelBingoUI.refresh_appoint_box(i, j)

        end
    end

    -- 未进行的奖励，用黑布遮盖
    local matrix_box = _gt.GetUI('box_group')
    local black_cloth = GUI.GetChild(matrix_box, 'black_cloth')
    local notice_txt = GUI.GetChild(matrix_box, 'notice_txt')
    if WelBingoUI.current_award_subscript < WelBingoUI.current_select_award_index then
        if black_cloth == nil then
            black_cloth = GUI.ImageCreate(matrix_box, "black_cloth", "1800400290", 0, 0, false, 358, 358, false)
            SetSameAnchorAndPivot(black_cloth, UILayout.Center)
        end

        if notice_txt == nil then
            notice_txt = GUI.CreateStatic(black_cloth, "notice_txt", "请将上一张" .. (left_award_name or '星图') .. '全部点亮', 0, 0, 351, 70, "system", true)
            GUI.StaticSetFontSize(notice_txt, UIDefine.FontSizeXXL)
            GUI.StaticSetAlignment(notice_txt, TextAnchor.MiddleCenter)
            SetSameAnchorAndPivot(notice_txt, UILayout.Center)
        end
        GUI.SetVisible(notice_txt, true)
        GUI.SetVisible(black_cloth, true)
    else
        GUI.SetVisible(black_cloth, false)
        GUI.SetVisible(notice_txt, false)

    end

end

-- 刷新单独的指定的格子
function WelBingoUI.refresh_appoint_box(row, column)
    if WelBingoUI.box_data == nil then
        test('WelBingoUI.refresh_appoint_box(row,column) WelBingoUI.box_data is null')
        return ''
    end

    local data = WelBingoUI.box_data[row][column]

    local matrix_box = _gt.GetUI('box_group')
    local box = GUI.GetChild(matrix_box, 'box' .. row .. '_' .. column)

    if box == nil then
        test('WelBingoUI.refresh_appoint_box(row,column) box' .. row .. '_' .. column .. ' is null')
        return ''
    end

    local item = nil
    local image_id = nil

    local i = row
    local j = column

    if data.key_name then
        item = DB.GetOnceItemByKey2(data.key_name)
        image_id = item.Icon
    elseif data.show_image then
        image_id = data.show_image
    else
        if data.is_activation then
            -- 实星星图片
            image_id = inside_image_lightened
        else
            -- 空星星图片
            image_id = inside_image_no_lightened
        end
    end

    -- 物品图片
    GUI.ItemCtrlSetElementValue(box, eItemIconElement.Icon, image_id)

    -- 奖励框
    if (i == 1 or i == box_border_num) or (j == 1 or j == box_border_num) then

        -- 物品品质背景
        GUI.ItemCtrlSetElementValue(box, eItemIconElement.Border, UIDefine.ItemIconBg[item.Grade])

        -- 奖励物品数量
        local num = GUI.GetChild(box, "Num" .. i .. '_' .. j)
        if data.num and data.num > 1 then
            GUI.SetVisible(num, true)
            GUI.StaticSetText(num, '' .. data.num)
        else
            GUI.SetVisible(num, false)
        end

        -- 用于tips点击事件
        GUI.SetData(box, 'item_id', item.Id)

        -- 激活处理
        local acquire_img = GUI.GetChild(box, 'acquire_img')
        if data.is_activation then
            --GUI.ItemCtrlSetIconGray(box, false)
            GUI.SetVisible(acquire_img, true)
        else
            GUI.SetVisible(acquire_img, false)
            --GUI.ItemCtrlSetIconGray(box, true)
        end

        -- 中间非奖励格
    else
        -- 物品背景
        GUI.ItemCtrlSetElementValue(box, eItemIconElement.Border, '1800400050')

    end

    -- 如果是不是进行中或已完成的奖励图，则显示灰色
    if WelBingoUI.current_award_subscript < WelBingoUI.current_select_award_index then
        GUI.ItemCtrlSetIconGray(box, true)
    else
        GUI.ItemCtrlSetIconGray(box, false)
    end

end

-- 刷新激活次数字体
function WelBingoUI.refresh_activate_txt()
    local num = 0
    if WelBingoUI.activate_count then
        num = WelBingoUI.activate_count
    end
    local txt = _gt.GetUI('activate_text')
    if txt then
        GUI.StaticSetText(txt, '剩余点亮次数：' .. num)
    end
end

-- 刷新左边查看奖励按钮列表
-- n 显示的文本数字从第n个开始,注意map变量，添加转换函数现在最大999
-- count 一共有多少个选项按钮
function WelBingoUI.refresh_advance_award_list(n, count)

    local scroll = _gt.GetUI('task_list_scroll')
    local task_node = nil

    for i = 1, count do
        task_node = GUI.GetChild(scroll, 'task_node_' .. i)
        -- 显示字体
        if task_node then
            if WelBingoUI.award_data and WelBingoUI.award_data[i] then
                GUI.ButtonSetText(task_node, WelBingoUI.award_data[i])
            else
                -- 将数字转换为中文文本
                local mandarin_num = WelBingoUI.num_change_to_mandarin(n + i - 1)
                GUI.ButtonSetText(task_node, (left_award_name or '星图') .. mandarin_num)
            end
        end

        --显示当前进行，判断全局变量是否开启，未开启就不显示
        if is_open_show_current_do_txt then

            local current_do_txt = GUI.GetChild(task_node, 'current_do_txt')
            if WelBingoUI.current_award_subscript and WelBingoUI.current_award_subscript == i then
                --如果没有就创建节点，如果有了就显示节点
                if current_do_txt == nil then
                    local current_do_txt = GUI.CreateStatic(task_node, 'current_do_txt', '进行中', 70, -4, 100, 50)
                    GUI.StaticSetAlignment(current_do_txt, TextAnchor.LowerRight)
                    GUI.SetColor(current_do_txt, UIDefine.BrownColor)
                    GUI.StaticSetFontSize(current_do_txt, UIDefine.FontSizeSSS)
                else
                    GUI.SetVisible(current_do_txt, true)
                end
                -- 另一种方案，修改颜色
                --GUI.ButtonSetTextColor(task_node, UIDefine.RedColor)
                --如果不符合条件则隐藏节点
            else
                -- 另一种方案，修改颜色
                --GUI.ButtonSetTextColor(task_node, UIDefine.BrownColor)
                if current_do_txt and GUI.GetVisible(current_do_txt) then
                    GUI.SetVisible(current_do_txt, false)
                end
            end
        end

        -- 未开始的显示锁图片
        local lock_img = GUI.GetChild(task_node, 'lock_img')
        if i > WelBingoUI.current_award_subscript then
            if lock_img == nil then
                lock_img = GUI.ImageCreate(task_node, "lock_img", award_btn_lock_img or "1800408170", 35, 0, false, 20, 25)
                SetSameAnchorAndPivot(lock_img, UILayout.Left)
            else
                GUI.SetVisible(lock_img, true)
            end
        else
            if lock_img ~= nil then
                GUI.SetVisible(lock_img, false)
            end
        end

        -- 显示当前选中
        if WelBingoUI.current_select_award_index and WelBingoUI.current_select_award_index == i then
            GUI.ButtonSetImageID(task_node, award_select_btn_img or '1800002031')
        elseif WelBingoUI.current_select_award_index == nil and i == 1 then
            GUI.ButtonSetImageID(task_node, award_select_btn_img or '1800002031')
        else
            GUI.ButtonSetImageID(task_node, award_normal_btn_img or '1800002030')
        end

    end

end

-- 刷新右边任务列表
function WelBingoUI.refresh_task_list_right()
    local task_content_scroll = _gt.GetUI('task_content_scroll')

    if task_content_scroll == nil then
        return ''
    end

    -- 任务数量
    local count = (WelBingoUI.show_task_data and #WelBingoUI.show_task_data) or 10
    for i = 1, count do

        local data = {}

        if WelBingoUI.show_task_data then
            data = WelBingoUI.show_task_data[i]
        end

        local img = data.img or "1801109480"
        local name = data.name or '师门任务'
        --local finished_num = data.finished_num or 1  --已完成次数
        --local num = data.num or 1  -- 获得奖励需完成次数
        --local get_num = data.get_num or 1  --可获得点亮次数
        local message = data.explain or '任务简介'

        local task_bg = GUI.GetChild(task_content_scroll, 'task_bg_' .. i)

        if task_bg ~= nil then
            -- 刷新图标
            local icon = GUI.GetChild(task_bg, 'task_item_ctrl')
            if icon then
                GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, img)
            end

            -- 刷新任务标题
            local title = GUI.GetChild(task_bg, 'task_title')
            if title then
                GUI.StaticSetText(title, name)
            end

            local txt = GUI.GetChild(task_bg, 'task_content')
            if txt then
                GUI.StaticSetText(txt, message)
            end


        end
    end

    -- 调整滚动位置
    GUI.ScrollRectSetNormalizedPosition(task_content_scroll, Vector2.New(0, 1))

end




------------------------------------------------------------------------ 点击事件部分
-- 奖励物品点击事件
function WelBingoUI.award_click_event(guid)
    local element = GUI.GetByGuid(guid)
    local item_id = GUI.GetData(element, 'item_id')
    item_id = tonumber(item_id)
    WelBingoUI.create_tips(item_id, 224, 152, false)
end

-- 点亮按钮点击事件
function WelBingoUI.activate_light(guid)

    -- 判断是否正在播放点亮动画
    if is_run_lighten_animation then
        CL.SendNotify(NOTIFY.ShowBBMsg, "正在点亮中，请稍等")
        return ''
    end

    -- 判断是否是进行中的奖励
    if WelBingoUI.current_award_subscript == nil or WelBingoUI.current_select_award_index == nil or WelBingoUI.current_award_subscript ~= WelBingoUI.current_select_award_index then
        CL.SendNotify(NOTIFY.ShowBBMsg, "请先选中" .. (left_award_name or '星图') .. WelBingoUI.num_change_to_mandarin(WelBingoUI.current_award_subscript) .. '')
        return ''
    end

    -- 判断当前拥有的点击次数是否足够
    if WelBingoUI.activate_count == nil or WelBingoUI.activate_count <= 0 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "点亮次数不足")
        return ''
    else
        -- 发送点亮请求
        WelBingoUI.lighten_require()
    end
end

-- I按钮点击事件
function WelBingoUI.hint_event(guid)
    local bg = _gt.GetUI('WelBingoUI_page')
    local hint = GUI.GetChild(bg, 'hint')
    if hint == nil then
        hint = GUI.ImageCreate(bg, "hint", "1800400290", 15, -40, false, 480, 375)
        GUI.SetIsRemoveWhenClick(hint, true)
        SetSameAnchorAndPivot(hint, UILayout.BottomRight)
        GUI.AddWhiteName(hint, guid)
        GUI.SetIsRaycastTarget(hint,true)

        local hintText = GUI.CreateStatic(hint, "hintText", "", 0, 0, 200, 70, "system", true)
        GUI.StaticSetFontSize(hintText, UIDefine.FontSizeM)
        GUI.StaticSetAlignment(hintText, TextAnchor.UpperLeft)
        SetSameAnchorAndPivot(hintText, UILayout.Top)

        local str1 = '2. 点击点亮按钮可随机点亮一个格子'
        local str2 = '3. 当五个点亮的星星连成一条线时可获\n得对应两端的奖励'
        local str3 = '4. 当一张星图的全部奖励被领取后，即\n可开始点亮下一张星图，奖励会随之越\n来越丰厚'
        local str4 = '5. <color=#FF0000ff>注意</color>：周一零点所有的进度以及点亮\n次数都将会重置'
        local str5 = '1. 完成指定次数任务将会获得点亮次数'
        local hintStr = '\n' .. str5 .. '\n\n' .. str1 .. '\n\n' .. str2 .. '\n\n' .. str3 .. '\n\n' .. str4

        GUI.StaticSetText(hintText, hintStr)

        local height = GUI.StaticGetLabelPreferHeight(hintText)
        local width = GUI.StaticGetLabelPreferWidth(hintText)

        GUI.SetHeight(hintText, height)
        GUI.SetWidth(hintText, width)
    else
        GUI.Destroy(hint)
    end
end

-- 查看奖励按钮点击事件
function WelBingoUI.show_award_btn_event(guid, i)


    local index = nil

    if guid == nil and i then
        index = i
    else

        if is_run_lighten_animation then
            CL.SendNotify(NOTIFY.ShowBBMsg, '正在点亮中，请稍等')
            return ''
        end

        local btn = GUI.GetByGuid(guid)
        index = tonumber(GUI.GetData(btn, 'show_award_index'))
    end

    -- 防止重复点击
    if index == WelBingoUI.current_select_award_index then
        return ''
    end


    -- 修改按钮颜色
    local scroll = _gt.GetUI('task_list_scroll')
    local node = nil

    -- 恢复上一个按钮颜色
    if WelBingoUI.current_select_award_index then
        node = GUI.GetChild(scroll, 'task_node_' .. WelBingoUI.current_select_award_index)
        if node then
            GUI.ButtonSetImageID(node, award_normal_btn_img or '1800002030')
        end
    elseif WelBingoUI.current_select_award_index == nil and index ~= 1 then
        node = GUI.GetChild(scroll, 'task_node_' .. 1)
        if node then
            GUI.ButtonSetImageID(node, award_normal_btn_img or '1800002030')
        end
    end

    -- 选中按钮颜色
    node = GUI.GetChild(scroll, 'task_node_' .. index)
    if node then
        GUI.ButtonSetImageID(node, award_select_btn_img or '1800002031')
    end

    -- 设置点亮按钮是否可用
    local activation_btn = _gt.GetUI('activation_btn')
    if activation_btn then
        if index ~= WelBingoUI.current_award_subscript then
            GUI.ButtonSetShowDisable(activation_btn, false)
        else
            GUI.ButtonSetShowDisable(activation_btn, true)
        end
    end


    -- 更新当前选中的奖励的下标全局变量
    WelBingoUI.current_select_award_index = index

    -- 发送奖励数据数据请求，后刷新奖励格
    WelBingoUI.other_stage_award_data(index)

end

-- 获取按钮点击事件
function WelBingoUI.approach_of_achieving_btn_event(guid)

    local bg = _gt.GetUI('WelBingoUI_page')
    local hint = GUI.GetChild(bg, 'approach_of_achieving_show_bg')
    if hint == nil then
        hint = GUI.ImageCreate(bg, "approach_of_achieving_show_bg", "1800400290", -10, -40, false, 273, 505)
        GUI.SetIsRemoveWhenClick(hint, true)
        GUI.RegisterUIEvent(hint, UCE.PointerClick, "", "")
        SetSameAnchorAndPivot(hint, UILayout.BottomRight)
        GUI.AddWhiteName(hint, guid)

        -- 任务内容
        -- 内容可以滚动
        local task_content_scroll = GUI.ScrollRectCreate(hint, 'task_content_scroll',
                0, -5, 260, 495,
                0, false, Vector2.New(260, 100),
                UIAroundPivot.Center, UIAnchor.Center)
        SetSameAnchorAndPivot(task_content_scroll, UILayout.Top)
        _gt.BindName(task_content_scroll, 'task_content_scroll')
        GUI.AddWhiteName(hint, GUI.GetGuid(task_content_scroll))

        WelBingoUI.create_task_cell_in_list()
        WelBingoUI.refresh_task_list_right()

    end

end





-------------------------------------------------------------------   发送请求部分
-- 向服务器请求所有数据
function WelBingoUI.require_all_data()
    -- 服务器端方法
    -- FormWelfare.GetData(player,index)
    -- 返回所有界面需要的数据
    --WelBingoUI.activate_count ：激活次数
    --WelBingoUI.box_data : 奖励格的数据
    --WelBingoUI.award_count : 奖励预览显示的选项数量
    --WelBingoUI.current_award_subscript : 当前进行中的奖励(宝图)的下标
    -- WelBingoUI.show_task_data : 展示的任务数据
    -- 执行回调方法
    --WelBingoUI.require_all_data_callback()
    CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "BinGo_GetData")
end

-- 向服务器发送点亮请求
function WelBingoUI.lighten_require()
    -- 服务器方法
    --FormWelfare.Lighten(player)
    -- 返回数据
    -- WelBingoUI.box_data
    -- WelBingoUI.activate_count 点亮次数-1
    -- 执行回调
    --WelBingoUI.lighten_require_call_back()

    CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "BinGo_Lighten")

end

-- 向服务器发送其他阶段奖励请求
function WelBingoUI.other_stage_award_data(index)
    -- 服务器方法
    -- FormWelfare.RefreshAwardList(player,index)
    -- 返回值
    -- WelBingoUI.box_data
    -- 执行回调
    --WelBingoUI.WelBingoUI.other_stage_award_data_callback()
    CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "BinGo_RefreshAwardList", tostring(index))
end

-- 向服务器发送获取奖励请求,当点亮完成后
function WelBingoUI.get_gift_behind_lighted()
    -- 服务器方法
    --FormWelfare.GetAward(player)
    -- 返回值
    -- 回调方法
    --WelBingoUI.get_gift_behind_lighted_callback()
    CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "BinGo_GetAward", tostring(WelBingoUI.lighten_result.row), tostring(WelBingoUI.lighten_result.column))
end

-- 向服务器请求点亮次数数据
function WelBingoUI.require_lighten_count()
    -- 服务器方法
    --FormWelfare.RefreshLightNum(player)
    -- 返回值
    --WelBingoUI.activate_count  点亮次数
    -- 回调方法
    --WelBingoUI.require_lighten_count_callback()
    CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "BinGo_RefreshLightNum")
end

-- 向服务器请求任务数据
function WelBingoUI.request_task_data()
    -- 服务器方法
    --FormWelfare.RefreshQuestData(player)
    -- 返回值
    --WelBingoUI.WelBingoUI.show_task_data 任务数据
    -- 回调方法
    --WelBingoUI.request_task_data_callback()
    CL.SendNotify(NOTIFY.SubmitForm, "FormWelfare", "BinGo_RefreshQuestData")
end




------------------------------------------------------------------- 请求回调部分
-- 向服务器请求所有数据的回调方法
function WelBingoUI.require_all_data_callback()

    -- 如果当前进行中的奖励的下标存在,则设置当前选中奖励的下标默认为它
    if WelBingoUI.current_award_subscript and WelBingoUI.current_select_award_index == nil then
        WelBingoUI.current_select_award_index = WelBingoUI.current_award_subscript
    end

    WelBingoUI.refresh()
end

-- 点亮请求回调
function WelBingoUI.lighten_require_call_back()

    -- 执行点亮动画
    WelBingoUI.play_animation()

    -- 刷新点亮次数
    WelBingoUI.refresh_activate_txt()

    -- 使点亮按钮不可用
    local activation_btn = _gt.GetUI('activation_btn')
    if activation_btn then
        GUI.ButtonSetShowDisable(activation_btn, false)
    end

end

-- 请求其他阶段奖励数据的回调方法
function WelBingoUI.other_stage_award_data_callback()
    -- 刷新矩阵格子
    WelBingoUI.scroll_cell_refresh()
end

-- 当点亮完成后，发送获取奖励请求的回调
function WelBingoUI.get_gift_behind_lighted_callback()

    -- 判断是否点亮全部
    local is_all_star_lighted = true
    for k, v in ipairs(WelBingoUI.box_data) do
        for i, j in ipairs(v) do
            if j.is_activation ~= true then
                is_all_star_lighted = false
                break
            end
        end
        if is_all_star_lighted == false then
            break
        end
    end

    -- 如果全部点亮，刷新左边的奖励显示，跳转到下一个奖励
    if is_all_star_lighted then
        -- 判断当前进行的奖励+1是否超过上限
        if WelBingoUI.current_award_subscript + 1 <= WelBingoUI.award_count then
            WelBingoUI.current_award_subscript = WelBingoUI.current_award_subscript + 1
            -- 执行查看奖励按钮点击事件,让其选中下个奖励且刷新奖励格
            --WelBingoUI.show_award_btn_event(nil, WelBingoUI.current_award_subscript)

            -- 刷新左边奖励预览
            WelBingoUI.refresh_advance_award_list(1, WelBingoUI.award_count or 6)

        end
    end
    -- 刷新奖励格子
    WelBingoUI.scroll_cell_refresh()

    -- 关闭点亮选择框
    WelBingoUI.lighten_or_turnoff_star(WelBingoUI.lighten_result.row, WelBingoUI.lighten_result.column, false, true)


    -- 点亮结束标志
    is_run_lighten_animation = false

    -- 使点亮按钮可用
    local activation_btn = _gt.GetUI('activation_btn')
    if activation_btn then
        GUI.ButtonSetShowDisable(activation_btn, true)
    end

end

-- 请求点亮次数后的回调
function WelBingoUI.require_lighten_count_callback()
    --刷新激活次数
    WelBingoUI.refresh_activate_txt()
end

-- 请求任务数据后的回调
function WelBingoUI.request_task_data_callback()
    -- 刷新右边任务列表
    WelBingoUI.refresh_task_list_right()
end




----------------------------------------------------------------------------- 点亮动画部分
-- 点亮动画
-- 当前显示位置的行
local timer_row = nil
-- 当前显示位置的列
local timer_column = nil
-- 总共随机次数
local random_count = 0
function WelBingoUI.play_animation()
    timer_row = 2
    timer_column = 1

    random_count = math.random(5, 10)

    is_run_lighten_animation = true
    Timer.New(WelBingoUI.animation_run_timer, lighten_animation_interval_time or 0.2, 1):Start()
end

-- 点亮动画所使用的定时器所调用的函数
function WelBingoUI.animation_run_timer()
    -- 清空上一次的星星选择框
    if timer_row and timer_column then
        WelBingoUI.lighten_or_turnoff_star(timer_row, timer_column, false, true)
    end

    -- 确定这次亮的星星的位置
    timer_row, timer_column = WelBingoUI.lighten_animation_random_position(random_count)
    random_count = random_count - 1
    --WelBingoUI.lighten_animation_next_position(false)


    -- 判断是否是点亮的结果
    if timer_row == WelBingoUI.lighten_result.row and timer_column == WelBingoUI.lighten_result.column then

        -- 显示点亮星星和选中框
        WelBingoUI.lighten_or_turnoff_star(timer_row, timer_column, true, false)

        --CL.SendNotify(NOTIFY.ShowBBMsg, "第" .. timer_row - 1 .. '排' .. '第' .. timer_column - 1 .. '个星星被点亮')
        timer_row = nil
        timer_column = nil
        -- 添加定时器延迟一段时间，再发送获取奖励请求,让选中框显示一段时间
        Timer.New(WelBingoUI.get_gift_behind_lighted, lighten_animation_interval_time + 0.2 or 0.2, 1):Start()

        return ''
    end

    -- 如果不是则显示星星选中框
    WelBingoUI.lighten_or_turnoff_star(timer_row, timer_column, true, true)

    -- 添加定时器显示下次亮的星星
    Timer.New(WelBingoUI.animation_run_timer, lighten_animation_interval_time or 0.2, 1):Start()
end

-- 点亮或关闭星星,或移动选中框
function WelBingoUI.lighten_or_turnoff_star(row, column, light_or_turnoff, is_select)
    -- 奖励格不进行处理
    if (row == 1 or row == box_border_num) or (column == 1 or column == box_border_num) then
        return ''
    end

    local matrix_box = _gt.GetUI('box_group')
    local box = GUI.GetChild(matrix_box, 'box' .. row .. '_' .. column)

    if box == nil then
        return ''
    end

    -- 如果使用选择框
    if is_select then

        local select_ui_node = GUI.GetChild(box, 'select_box')
        if light_or_turnoff then
            if select_ui_node == nil then
                select_ui_node = GUI.ImageCreate(box, 'select_box', '1800400280', 0, 0)
                SetSameAnchorAndPivot(select_ui_node, UILayout.Center)
            else
                GUI.SetVisible(select_ui_node, true)
            end
        else
            if select_ui_node and GUI.GetVisible(select_ui_node) then
                GUI.SetVisible(select_ui_node, false)
            end

        end

        -- 如果未使用选择框，而是点亮星星
        -- 增加点亮星星也得显示选择框
    else

        local select_ui_node = GUI.GetChild(box, 'select_box')
        if select_ui_node == nil then
            select_ui_node = GUI.ImageCreate(box, 'select_box', '1800400280', 0, 0)
            SetSameAnchorAndPivot(select_ui_node, UILayout.Center)
        else
            GUI.SetVisible(select_ui_node, true)
        end

        local data = WelBingoUI.box_data[row][column]

        local image_id = nil

        -- 如果已点亮，判断星星是否亮了
        if data.is_activation then
            if inside_image_lightened ~= GUI.ItemCtrlGetElementValue(box, eItemIconElement.Icon) then
                GUI.ItemCtrlSetElementValue(box, eItemIconElement.Icon, inside_image_lightened)
            end
            -- 如果未点亮
        else
            if light_or_turnoff then
                -- 实星星图片
                image_id = inside_image_lightened
            else
                -- 空星星图片
                image_id = inside_image_no_lightened
            end
            -- 物品图片
            GUI.ItemCtrlSetElementValue(box, eItemIconElement.Icon, image_id)
        end
    end

    return true

end

-- 点亮动画-随机闪烁
-- count: 控制随机次数
function WelBingoUI.lighten_animation_random_position(count)
    if count > 0 then

        -- 随机行
        local r_row = math.random(2, box_border_num - 1)

        -- 随机列
        local r_column = math.random(2, box_border_num - 1)

        return r_row, r_column

        -- 如果随机次数为0则显示服务器给出的点亮位置
    else
        return WelBingoUI.lighten_result.row, WelBingoUI.lighten_result.column
    end

end




---------------------------------------------------------------------  创建tips部分
-- 创建tips
function WelBingoUI.create_tips(item_id, X, Y, isBind)

    local item_id = item_id
    local X = X
    local Y = Y

    local tip = _gt.GetUI('BingoTips')
    if tip then
        GUI.Destroy(tip)
    end


    -- 如果没有就弹出tips 以及获取方式
    local WelBingoUI_page = _gt.GetUI("WelBingoUI_page")

    tip = Tips.CreateByItemId(item_id, WelBingoUI_page, "WingPageTips", X, Y)
    GUI.SetData(tip, "ItemId", item_id)
    GUI.SetHeight(tip, GUI.GetHeight(tip) + 40)
    _gt.BindName(tip, "BingoTips")

    local wayBtn = GUI.ButtonCreate(tip, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
    SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn, UCE.PointerClick, "WelBingoUI", "OnClickFormationWayBtn")
    GUI.AddWhiteName(tip, GUI.GetGuid(wayBtn))

    if isBind then
        -- 添加绑定图标
        local tipsIcon = GUI.TipsGetItemIcon(tip)
        GUI.ItemCtrlSetElementValue(tipsIcon, eItemIconElement.LeftTopSp, "1800707120")
    end
end

-- 获取途径
function WelBingoUI.OnClickFormationWayBtn()
    local tip = _gt.GetUI("BingoTips")
    if tip then
        if GUI.GetPositionX(tip) == 224 then
            GUI.SetPositionX(tip, -26)
        end
        Tips.ShowItemGetWay(tip)
    end
end




--------------------------------------------------------------------  功能性函数部分
-- 将数字转换为中文文本
function WelBingoUI.num_change_to_mandarin(num)
    num = tonumber(num)
    if num == nil then
        return ''
    end

    if num >= 1000 then
        test(' WelBingoUI.num_change_to_mandarin(num) 无法将数字转换为中文')
        return ''
    end

    local map = {
        [0] = '零',
        [1] = '一',
        [2] = '二',
        [3] = '三',
        [4] = '四',
        [5] = '五',
        [6] = '六',
        [7] = '七',
        [8] = '八',
        [9] = '九',
        [10] = '十',
    }

    if num <= 10 and num > 0 then
        return map[num]
    elseif num > 10 and num <= 19 then
        return '十' .. map[num % 10]
    elseif num > 19 and num < 100 then
        local seat = num % 10
        if seat == 0 then
            seat = ''
        else
            seat = map[num % 10]
        end
        return map[math.floor(num / 10)] .. '十' .. seat
    elseif num >= 100 and num < 1000 then

        local seat = num % 10
        if seat == 0 then
            seat = ''
        else
            seat = map[seat]
        end

        local ten_seat = (math.floor(num / 10)) % 10
        if seat == '' then
            if ten_seat == 0 then
                ten_seat = ''
            else
                ten_seat = map[ten_seat] .. '十'
            end
        else
            if ten_seat == 0 then
                ten_seat = map[ten_seat]
            else
                ten_seat = map[ten_seat] .. '十'
            end
        end

        local hundred_seat = math.floor(num / 100)
        if hundred_seat == 0 then
            hundred_seat = '一百'
        else
            hundred_seat = map[math.floor(num / 100)] .. '百'
        end

        return hundred_seat .. ten_seat .. seat
    end

end


