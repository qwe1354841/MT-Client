-- 上交侍从信物换取奇遇值
local HandInGuardTokenUI = {}
_G.HandInGuardTokenUI = HandInGuardTokenUI

local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------
-- 选中的速度
-- {最大范围，选中数量}
HandInGuardTokenUI.rangeOfAddItemCount = {
    { m = 20, n = 1 },
    { m = 40, n = 2 },
    { m = "other", n = 3 },
}
-- 过滤属性修改后记得在on_exit关闭界面事件处也修改下
-- 是否开启过滤出满星侍从信物
HandInGuardTokenUI.isOpenFilterByIsMaxStar = false
-- 是否开启过滤出绑定信物
HandInGuardTokenUI.isOpenFilterByIsBind = false
-- 最大星级
local maxStar = 6
-- 选中全部时 是否使用确认框
HandInGuardTokenUI.selectAllIsUseConfirmation = true
-- 是否打开界面就选中满星的全部信物
HandInGuardTokenUI.isSelectMaxStarAllWhenOpen = true

function HandInGuardTokenUI.Main()
    local _Panel = GUI.WndCreateWnd("HandInGuardTokenUI", "HandInGuardTokenUI", 0, 0, eCanvasGroup.Normal)
    local _PanelBack = UILayout.CreateFrame_WndStyle2(_Panel, "上交信物", 560, 435, "HandInGuardTokenUI", "OnExit")

    -- 信物列表背景
    local img_bg = GUI.ImageCreate(_PanelBack, "scroll_img_bg", "1800400010", 0, 15, false, 509, 274)
    SetSameAnchorAndPivot(img_bg, UILayout.Center)
    -- 信物列表
    local enhanceVecSize = Vector2.New(80, 80)
    local scroll = GUI.ScrollRectCreate(img_bg, "guard_token_scroll", 0, 0, 490, 250, 0, false, enhanceVecSize, UIAroundPivot.Center, UIAnchor.Center, 6)
    GUI.ScrollRectSetChildSpacing(scroll, Vector2.New(1, 1))
    SetSameAnchorAndPivot(scroll, UILayout.Center)
    _gt.BindName(scroll, "guard_token_scroll")

    -- 文本
    local txt = GUI.CreateStatic(_PanelBack, "txt", "可获得奇遇值：0", 28, -138, 250, 45)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeM)
    GUI.SetColor(txt, UIDefine.BrownColor)
    SetSameAnchorAndPivot(txt, UILayout.Left)
    _gt.BindName(txt, "happy_encounter_txt")

    -- 多选框
    -- 显示满星
    local msGroup = GUI.GroupCreate(img_bg, "maxStarGroup", 58, -153, 150, 40)
    local showMaxStarCheckBox = GUI.CheckBoxExCreate(msGroup, "showMaxStar", "1800607150", "1800607151", 0, 0, HandInGuardTokenUI.isOpenFilterByIsMaxStar or false)
    _gt.BindName(showMaxStarCheckBox, 'showMaxStarCheckBox')
    UILayout.SetSameAnchorAndPivot(showMaxStarCheckBox, UILayout.Left)
    GUI.RegisterUIEvent(showMaxStarCheckBox, UCE.PointerClick, "HandInGuardTokenUI", "eventOfShowMaxStarCheckBox")
    -- 文本
    local msTxt = GUI.CreateStatic(msGroup, "maxStarTxt", "显示满星", 18, 0, 100, 40, "system", false)
    GUI.StaticSetFontSize(msTxt, UIDefine.FontSizeM)
    GUI.SetColor(msTxt, UIDefine.BrownColor)

    -- 显示绑定
    local bindGroup = GUI.GroupCreate(img_bg, "bindGroup", 196, -153, 150, 40)
    local showBindCheckBox = GUI.CheckBoxExCreate(bindGroup, "showBindCheckBox", "1800607150", "1800607151", 0, 0, HandInGuardTokenUI.isOpenFilterByIsMaxStar or false)
    _gt.BindName(showBindCheckBox, 'showBindCheckBox')
    UILayout.SetSameAnchorAndPivot(showBindCheckBox, UILayout.Left)
    GUI.RegisterUIEvent(showBindCheckBox, UCE.PointerClick, "HandInGuardTokenUI", "eventOfBindCheckBox")
    -- 文本
    local bindTxt = GUI.CreateStatic(bindGroup, "bindTxt", "显示绑定", 18, 0, 100, 40, "system", false)
    GUI.StaticSetFontSize(bindTxt, UIDefine.FontSizeM)
    GUI.SetColor(bindTxt, UIDefine.BrownColor)

    local panelW = GUI.GetWidth(_PanelBack)
    local btnX = panelW / 3
    -- 全部选中按钮
    local equipDonateBtn_x = btnX / 8
    local equipDonateBtn = GUI.ButtonCreate(_PanelBack, "equipDonateBtn", "1800602030", equipDonateBtn_x, 181, Transition.ColorTint, "全部选中")
    SetSameAnchorAndPivot(equipDonateBtn, UILayout.Left)
    GUI.ButtonSetTextFontSize(equipDonateBtn, 26)
    GUI.ButtonSetTextColor(equipDonateBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(equipDonateBtn, true)
    GUI.SetOutLine_Color(equipDonateBtn, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(equipDonateBtn, 1)
    GUI.RegisterUIEvent(equipDonateBtn, UCE.PointerClick, "HandInGuardTokenUI", "OnEquipDonateBtnClick")

    -- 清空选中按钮
    local clearSelectBtn_x = btnX * 1.125
    local clearSelectBtn = GUI.ButtonCreate(_PanelBack, "clearSelectBtn", "1800602030", clearSelectBtn_x, 181, Transition.ColorTint, "清除选中")
    SetSameAnchorAndPivot(clearSelectBtn, UILayout.Left)
    GUI.ButtonSetTextFontSize(clearSelectBtn, 26)
    GUI.ButtonSetTextColor(clearSelectBtn, UIDefine.WhiteColor)
    GUI.SetIsOutLine(clearSelectBtn, true)
    GUI.SetOutLine_Color(clearSelectBtn, UIDefine.Orange2Color)
    GUI.SetOutLine_Distance(clearSelectBtn, 1)
    GUI.RegisterUIEvent(clearSelectBtn, UCE.PointerClick, "HandInGuardTokenUI", "clearSelectBtnEvent")

    -- 上交按钮
    local sub_btn_x = btnX * 2.125
    local sub_btn = GUI.ButtonCreate(_PanelBack, "sub_btn", "1800402080", sub_btn_x, 181, Transition.ColorTint, "", 140, 47, false)
    SetSameAnchorAndPivot(sub_btn, UILayout.Left)
    -- GUI.ButtonSetTextColor(sub_btn, UIDefine.WhiteColor)
    -- GUI.ButtonSetTextFontSize(sub_btn, UIDefine.FontSizeL)
    -- GUI.ButtonSetOutLineArgs(sub_btn, true, UIDefine.Brown3Color, 1)
    GUI.RegisterUIEvent(sub_btn, UCE.PointerClick, "HandInGuardTokenUI", "_submit_change")
    -- button字体没有居中方法，重新创建个字体
    local txt = GUI.CreateStatic(sub_btn, 'sub_guard_item', '上 交', 0, 0, 130, 47, 'system', false)
    GUI.StaticSetAlignment(txt, TextAnchor.MiddleCenter)
    GUI.SetColor(txt, UIDefine.WhiteColor)
    GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
    GUI.SetIsOutLine(txt, true)
    GUI.SetOutLine_Color(txt, UIDefine.Brown3Color)
    GUI.SetOutLine_Distance(txt, 1)

    -- 从限时购复制而来
    -- 当没有信物时显示
    local pnSellout = GUI.ImageCreate(img_bg, "pnSellout", "1801100010", 0, 0, false, 300, 100)
    SetSameAnchorAndPivot(pnSellout, UILayout.Center)
    _gt.BindName(pnSellout, "pnSellout")

    local txtSellout = GUI.CreateStatic(pnSellout, "txtSellout", "没有可上交的信物", 0, 0, 300, 50, "system", true)
    SetAnchorAndPivot(txtSellout, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetColor(txtSellout, Color.New(93 / 255, 50 / 255, 33 / 255, 255 / 255))
    GUI.StaticSetFontSize(txtSellout, UIDefine.FontSizeXL)
    GUI.SetOutLine_Color(txtSellout, Color.New(249 / 255, 71 / 255, 59 / 255, 255 / 255))
    GUI.StaticSetAlignment(txtSellout, TextAnchor.MiddleCenter)
    GUI.SetVisible(pnSellout, false)
end

function HandInGuardTokenUI.OnShow()
    local wnd = GUI.GetWnd("HandInGuardTokenUI")
    GUI.SetVisible(wnd, true)

    -- 注册监听事件
    HandInGuardTokenUI._register()

    HandInGuardTokenUI.refresh()

    if HandInGuardTokenUI._token_HE_num == nil then
        HandInGuardTokenUI._get_token_happy_encounter_num()
    else
        if HandInGuardTokenUI.isSelectMaxStarAllWhenOpen == true then
            HandInGuardTokenUI.useMaxStarFilterAndSelectAll()
        end
    end
end

function HandInGuardTokenUI.OnExit()
    -- 关闭监听事件
    HandInGuardTokenUI._unregister()

    -- 当前能选中的侍从信物数据
    HandInGuardTokenUI._token_item_data = nil
    -- 准备兑换的侍从信物数据
    HandInGuardTokenUI._token_change_data = {}
    -- 上一次选中信物的下标
    HandInGuardTokenUI._pre_select_token = nil
    -- 当前选中侍从信物总共能兑换的奇遇值
    HandInGuardTokenUI._show_HE_value = nil

    -- 重置过滤属性
    HandInGuardTokenUI.isOpenFilterByIsMaxStar = false
    HandInGuardTokenUI.isOpenFilterByIsBind = false

    -- 更新多选框 都关闭
    GUI.CheckBoxExSetCheck(_gt.GetUI('showMaxStarCheckBox'), HandInGuardTokenUI.isOpenFilterByIsMaxStar)
    GUI.CheckBoxExSetCheck(_gt.GetUI('showBindCheckBox'), HandInGuardTokenUI.isOpenFilterByIsBind)

    GUI.CloseWnd("HandInGuardTokenUI")
end

function HandInGuardTokenUI.OnDestroy()
    HandInGuardTokenUI._scroll_max_num = nil
end

-- 注册监听事件
function HandInGuardTokenUI._register()
    CL.RegisterMessage(GM.RefreshBag, "HandInGuardTokenUI", "_sub_refresh")
end

-- 关闭监听事件
function HandInGuardTokenUI._unregister()
    CL.UnRegisterMessage(GM.RefreshBag, "HandInGuardTokenUI", "_sub_refresh")
end

-- 创建界面 --

-- 创建侍从信物节点
function HandInGuardTokenUI._create_scroll_node(num)
    if not num then
        CL.SendNotify(NOTIFY.ShowBBMsg, "系统错误")
        test("HandInGuardTokenUI 界面 HandInGuardTokenUI._create_scroll_node()方法 缺少num参数")
        return ""
    end

    local scroll = _gt.GetUI("guard_token_scroll")

    for i = 1, num do
        -- 获取当前执行的次数
        local count = i
        local _Item = GUI.GetChild(scroll, "Item" .. count)
        if _Item == nil then
            --底板
            _Item = GUI.ImageCreate(scroll, "Item" .. count, "1800600050", 0, 0, false, 78, 78)
            SetAnchorAndPivot(_Item, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetVisible(_Item, true)

            --图标
            local _Icon = GUI.ItemCtrlCreate(_Item, tostring(count), "1800600050", 0, 0, 76, 76, false)
            SetAnchorAndPivot(_Icon, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(_Icon, false)
            GUI.ItemCtrlSetElementRect(_Icon, eItemIconElement.Icon, 0, -2, 67, 67)
            GUI.ItemCtrlSetElementRect(_Icon, eItemIconElement.Border, 0, 1.5, 76, 76)
            GUI.RegisterUIEvent(_Icon, UCE.PointerClick, "HandInGuardTokenUI", "_item_click")
            _Icon:RegisterEvent(UCE.PointerUp)
            _Icon:RegisterEvent(UCE.PointerDown)
            GUI.RegisterUIEvent(_Icon, UCE.PointerDown, "HandInGuardTokenUI", "OnClickItemDown")
            GUI.RegisterUIEvent(_Icon, UCE.PointerUp, "HandInGuardTokenUI", "OnClickItemUp")

            --数量
            local _Num = GUI.CreateStatic(_Item, "Num" .. count, "0/0", -28, -6, 100, 35)
            SetSameAnchorAndPivot(_Num, UILayout.BottomLeft)
            GUI.StaticSetFontSize(_Num, UIDefine.FontSizeSS)
            GUI.SetColor(_Num, UIDefine.WhiteColor)
            GUI.SetIsOutLine(_Num, true)
            GUI.SetOutLine_Distance(_Num, 1)
            GUI.SetOutLine_Color(_Num, UIDefine.BlackColor)
            GUI.StaticSetAlignment(_Num, TextAnchor.LowerRight)
            GUI.SetVisible(_Num, false)

            --选中标记
            local _SelectFlag = GUI.ImageCreate(_Item, "SelectFlag", "1800400280", 0, 0)
            SetAnchorAndPivot(_SelectFlag, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(_SelectFlag, false)

            --减少按钮
            local _DecBtn = GUI.ButtonCreate(_Item, "DecBtn" .. count, "1800702070", 2, 0, Transition.ColorTint, "", 24, 24, false)
            SetAnchorAndPivot(_DecBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.SetVisible(_DecBtn, false)
            GUI.RegisterUIEvent(_DecBtn, UCE.PointerClick, "HandInGuardTokenUI", "_dec_click")
            _DecBtn:RegisterEvent(UCE.PointerUp)
            _DecBtn:RegisterEvent(UCE.PointerDown)
            GUI.RegisterUIEvent(_DecBtn, UCE.PointerDown, "HandInGuardTokenUI", "OnDecDown")
            GUI.RegisterUIEvent(_DecBtn, UCE.PointerUp, "HandInGuardTokenUI", "OnDecUp")
        end
    end
end

-- 刷新界面 --

-- 刷新侍从信物节点
function HandInGuardTokenUI._refresh_scroll_node(num)
    if not HandInGuardTokenUI._token_item_data then
        HandInGuardTokenUI._token_item_data = HandInGuardTokenUI._get_all_token()
    end

    local scroll = _gt.GetUI("guard_token_scroll")

    -- 更新侍从信物框
    for index = 1, num do
        local node_ui = GUI.GetChild(scroll, "Item" .. index)
        if node_ui then
            GUI.SetVisible(node_ui, true)
        end

        -- 在侍从信物数据范围内
        if node_ui and index <= #HandInGuardTokenUI._token_item_data then
            local data = HandInGuardTokenUI._token_item_data[index]
            local item = DB.GetOnceItemByKey1(data.id)

            -- 头像
            local icon = GUI.GetChild(node_ui, tostring(index))
            GUI.SetVisible(icon, true)
            GUI.SetData(icon, "select_index", index)
            GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, item.Icon)

            -- 品质框
            GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Border, UIDefine.ItemIconBg[item.Grade])

            -- 绑定图标
            if tostring(data.is_bind) ~= "0" then
                GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp, "1800707120")
            else
                GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp, "")
            end

            -- 右上碎片图片
            GUI.ItemCtrlSetElementValue(_Icon, eItemIconElement.RightTopSp, "")

            -- 数量
            local num = GUI.GetChild(node_ui, "Num" .. index)
            GUI.SetVisible(num, true)
            local isHave = nil
            if HandInGuardTokenUI._token_change_data and HandInGuardTokenUI._token_change_data[index] then
                local selectCount = HandInGuardTokenUI._token_change_data[index].amount
                if selectCount > 0 then
                    isHave = true
                else
                    selectCount = 0
                end
                GUI.StaticSetText(num, selectCount .. '/' .. data.amount)
            else
                GUI.StaticSetText(num, "0/" .. data.amount)
            end

            --选中标记
            local select = GUI.GetChild(node_ui, "SelectFlag")
            GUI.SetVisible(select, false)

            -- 减少按钮
            local dec_btn = GUI.GetChild(node_ui, "DecBtn" .. index)
            GUI.SetVisible(dec_btn, isHave or false)
            GUI.SetData(dec_btn, "index", index)

            -- 在侍从信物数据范围外
        else
            -- 头像
            local icon = GUI.GetChild(node_ui, tostring(index))
            GUI.SetVisible(icon, false)
            --GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, '')

            -- 品质框
            --GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Border, '')

            -- 绑定图标
            --GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp, '')

            -- 右上碎片图片
            --GUI.ItemCtrlSetElementValue(_Icon, eItemIconElement.RightTopSp, '')

            -- 数量
            local num = GUI.GetChild(node_ui, "Num" .. index)
            GUI.SetVisible(num, false)

            --选中标记
            local select = GUI.GetChild(node_ui, "SelectFlag")
            GUI.SetVisible(select, false)

            -- 减少按钮
            local dec_btn = GUI.GetChild(node_ui, "DecBtn" .. index)
            GUI.SetVisible(dec_btn, false)
        end
    end

    -- 隐藏多出的信物框
    if HandInGuardTokenUI._scroll_max_num ~= nil and HandInGuardTokenUI._scroll_max_num > num then
        for index = num + 1, HandInGuardTokenUI._scroll_max_num do
            local node_ui = GUI.GetChild(scroll, "Item" .. index)
            if node_ui then
                GUI.SetVisible(node_ui, false)
            end
        end
    end
end

-- 刷新整个界面
function HandInGuardTokenUI.refresh(isSaveChangeData)
    if not HandInGuardTokenUI._token_item_data then
        -- 将背包内侍从信物存储下来，当其变化时更新，减少运行次数
        HandInGuardTokenUI._token_item_data = HandInGuardTokenUI._get_all_token()
        -- 当是过滤导致的刷新时 对准备上交的信物进行index修正
        if isSaveChangeData == true then
            HandInGuardTokenUI._token_change_data = HandInGuardTokenUI._getIndexTable({ 'keyName', 'is_bind' }, HandInGuardTokenUI._token_item_data, HandInGuardTokenUI._token_change_data)
        end
    end
    local scroll = _gt.GetUI("guard_token_scroll")
    -- 当没有任何一个物品时
    if HandInGuardTokenUI._token_item_data[1] == nil then
        GUI.SetVisible(scroll, false)
        local pns = _gt.GetUI("pnSellout")
        GUI.SetVisible(pns, true)

        -- 修改显示的奇遇值
        local HE_num = _gt.GetUI("happy_encounter_txt")
        GUI.StaticSetText(HE_num, "可获得奇遇值：" .. (HandInGuardTokenUI._show_HE_value or 0))

        return
    else
        local pns = _gt.GetUI("pnSellout")
        GUI.SetVisible(pns, false)
        GUI.SetVisible(scroll, true)
    end

    local num = 18
    if num < #HandInGuardTokenUI._token_item_data then
        num = math.ceil(#HandInGuardTokenUI._token_item_data / 6) * 6
    end

    if HandInGuardTokenUI._scroll_max_num == nil or num > HandInGuardTokenUI._scroll_max_num then
        HandInGuardTokenUI._scroll_max_num = num
    end

    -- 创建节点
    HandInGuardTokenUI._create_scroll_node(num)
    -- 刷新节点
    HandInGuardTokenUI._refresh_scroll_node(num)
    GUI.ScrollRectSetNormalizedPosition(scroll, Vector2.New(0, 1))

    -- 修改显示的奇遇值
    local HE_num = _gt.GetUI("happy_encounter_txt")
    GUI.StaticSetText(HE_num, "可获得奇遇值：" .. (HandInGuardTokenUI._show_HE_value or 0))
end

-- 上交信物后的刷新 也用于其他地方 对数据进行了处理
function HandInGuardTokenUI._sub_refresh(isSaveChangeData)
    HandInGuardTokenUI._token_item_data = nil
    -- 上一次选中信物的下标
    HandInGuardTokenUI._pre_select_token = nil

    -- 是否保存需要交互的上交信物数据
    if isSaveChangeData == true then
    else
        -- 准备兑换的侍从信物数据
        HandInGuardTokenUI._token_change_data = {}
        -- 当前选中侍从信物总共能兑换的奇遇值
        HandInGuardTokenUI._show_HE_value = nil
    end

    HandInGuardTokenUI.refresh(isSaveChangeData)
end

--[[
	============================
	---- 非请求服务器获取数据 ------
	============================
]]

-- 获取包裹内所有的侍从信物
function HandInGuardTokenUI._get_all_token()
    local tokens = {}
    local guardBag_Count = LD.GetItemCount(item_container_type.item_container_guard_bag)
    for i = 0, guardBag_Count - 1 do
        -- 物品guid
        local guardGuid = tostring(LD.GetItemGuidByItemIndex(i, item_container_type.item_container_guard_bag))
        -- 物品id
        local item_id = LD.GetItemAttrByGuid(ItemAttr_Native.Id, guardGuid, item_container_type.item_container_guard_bag)
        -- 物品是否绑定
        local is_bind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, guardGuid, item_container_type.item_container_guard_bag)
        -- 物品拥有数量
        local item_amount = LD.GetItemAttrByGuid(ItemAttr_Native.Amount, guardGuid, item_container_type.item_container_guard_bag)

        -- 物品品质
        local itemDB = DB.GetOnceItemByKey1(item_id)
        local grade = itemDB.Grade
        local name = itemDB.KeyName

        local info = {
            id = tonumber(item_id),
            is_bind = tonumber(is_bind),
            amount = tonumber(item_amount),
            grade = grade,
            keyName = name,
        }

        table.insert(tokens, info)
    end
    tokens = HandInGuardTokenUI._merge(tokens)
    if HandInGuardTokenUI.isOpenFilterByIsMaxStar then
        tokens = HandInGuardTokenUI._filterByIsMaxStar(tokens)
    end
    if HandInGuardTokenUI.isOpenFilterByIsBind then
        tokens = HandInGuardTokenUI._filterByIsBind(tokens)
    end
    -- CDebug.LogError(inspect(tokens))
    table.sort(tokens, HandInGuardTokenUI._sort)
    return tokens
end

-- 获取侍从信物对应能兑换的奇遇值
-- 参数
-- token_key_name : 侍从信物keyName
-- grade : 侍从品质
-- amount : 兑换数量 可选参数 默认为1
function HandInGuardTokenUI._change_num(token_key_name, grade, amount)
    if not HandInGuardTokenUI._token_HE_num then
        test("HandInGuardTokenUI界面 未获得服务器数据  HandInGuardTokenUI._token_HE_num")
        return ""
    end

    if not (token_key_name and grade) then
        test("HandInGuardTokenUI界面  HandInGuardTokenUI._change_num()方法缺少传入的参数")
        return ""
    end

    amount = amount or 1

    -- 奇遇值
    local happy_encounter_num = HandInGuardTokenUI._token_HE_num.GradeConfig[grade]

    for k, v in pairs(HandInGuardTokenUI._token_HE_num.GradeConfig_item) do
        if k == token_key_name then
            happy_encounter_num = v
        end
    end

    if amount then
        happy_encounter_num = happy_encounter_num * amount
    end

    return happy_encounter_num
end

--[[
	============================
	----- 请求服务器获取数据 ------
	============================
]]

-- 获取每个信物的奇遇值
function HandInGuardTokenUI._get_token_happy_encounter_num()
    -- 获取每个侍从信物对应的奇遇值
    -- 品质区分
    -- 单独配置
    -- 返回值 HandInGuardTokenUI._token_HE_num
    CL.SendNotify(NOTIFY.SubmitForm, "FormYunYouXianNPC", "GetGradeConfig")
end

-- 获取每个侍从信物对应的奇遇值 回调
function HandInGuardTokenUI._get_token_HE_num_call_back()
    --CDebug.LogError(inspect(HandInGuardTokenUI._token_HE_num))
    if HandInGuardTokenUI.isSelectMaxStarAllWhenOpen == true then
        HandInGuardTokenUI.useMaxStarFilterAndSelectAll()
    end
end


--[[
	============================
	-------- 点击事件部分 --------
	============================
]]

-- 准备兑换的侍从信物数据
HandInGuardTokenUI._token_change_data = {} -- [1] = {is_bind, key_name, amount}
-- 上一次选中信物的下标
HandInGuardTokenUI._pre_select_token = nil
-- 当前选中侍从信物总共能兑换的奇遇值
HandInGuardTokenUI._show_HE_value = nil

-- 选中图片点击事件
function HandInGuardTokenUI._item_click(guid)
    local btn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(btn, "select_index"))

    if not HandInGuardTokenUI._token_item_data then
        HandInGuardTokenUI._token_item_data = HandInGuardTokenUI._get_all_token()
    end

    local guard_item = DB.GetOnceItemByKey1(HandInGuardTokenUI._token_item_data[index].id)

    local item = GUI.GetParentElement(btn)

    -- 显示选中标记框,关闭上一个选中框
    local select = GUI.GetChild(item, "SelectFlag")
    if not HandInGuardTokenUI._pre_select_token then
        GUI.SetVisible(select, true)
    elseif HandInGuardTokenUI._pre_select_token ~= index then
        local scroll = _gt.GetUI("guard_token_scroll")
        local pre_item = GUI.GetChild(scroll, "Item" .. HandInGuardTokenUI._pre_select_token)
        local pre_select = GUI.GetChild(pre_item, "SelectFlag")
        GUI.SetVisible(pre_select, false)
        GUI.SetVisible(select, true)
    end
    HandInGuardTokenUI._pre_select_token = index

    --  此处点击应该选中的数量
    local count = 1
    -- 修改数量
    if not HandInGuardTokenUI._token_change_data[index] then
        local key_name = guard_item.KeyName
        HandInGuardTokenUI._token_change_data[index] = {
            key_name = key_name,
            is_bind = HandInGuardTokenUI._token_item_data[index].is_bind,
            amount = 1,
        }
    else
        -- 选中信物数量不能超过已有数量
        if HandInGuardTokenUI._token_change_data[index].amount >= HandInGuardTokenUI._token_item_data[index].amount then
            HandInGuardTokenUI.OnClickItemUp()
            -- HandInGuardTokenUI.ClickItemTimer:Stop()
            -- HandInGuardTokenUI.ClickItemTimer:Reset(HandInGuardTokenUI.TimerFunction,0.1,-1)
            return ""
        end

        -- 计算出当前计时器时间内应该选中的数量
        for k, v in pairs(HandInGuardTokenUI.rangeOfAddItemCount) do
            if HandInGuardTokenUI.addTimerCount then
                k = v.m
                v = v.n
                if k ~= "other" then
                    if HandInGuardTokenUI.addTimerCount <= k then
                        count = v
                        break
                    end
                else
                    count = v
                    break
                end
            else
                break
            end
        end

        -- 对选中的数量进行修改
        local currentAmount = HandInGuardTokenUI._token_change_data[index].amount
        local maxAmount = HandInGuardTokenUI._token_item_data[index].amount
        if currentAmount + count < maxAmount then
            HandInGuardTokenUI._token_change_data[index].amount = HandInGuardTokenUI._token_change_data[index].amount + count
        elseif currentAmount + count == maxAmount then
            HandInGuardTokenUI._token_change_data[index].amount = HandInGuardTokenUI._token_change_data[index].amount + count
            HandInGuardTokenUI.OnClickItemUp()
        else
            count = maxAmount - currentAmount
            HandInGuardTokenUI._token_change_data[index].amount = HandInGuardTokenUI._token_change_data[index].amount + count
            HandInGuardTokenUI.OnClickItemUp()
        end

        -- HandInGuardTokenUI._token_change_data[index].amount = HandInGuardTokenUI._token_change_data[index].amount + 1
    end

    local num = GUI.GetChild(item, "Num" .. index)
    GUI.StaticSetText(num, HandInGuardTokenUI._token_change_data[index].amount .. "/" .. HandInGuardTokenUI._token_item_data[index].amount)

    -- 显示减少按钮
    local dec_btn = GUI.GetChild(item, "DecBtn" .. index)
    GUI.SetVisible(dec_btn, true)

    -- 修改显示的奇遇值 需要增加的奇遇值 + 原有的奇遇值
    HandInGuardTokenUI._show_HE_value = HandInGuardTokenUI._change_num(guard_item.KeyName, guard_item.Grade, count) + (HandInGuardTokenUI._show_HE_value or 0)

    local HE_num = _gt.GetUI("happy_encounter_txt")
    GUI.StaticSetText(HE_num, "可获得奇遇值：" .. HandInGuardTokenUI._show_HE_value)
end

-- 减少按钮点击事件
function HandInGuardTokenUI._dec_click(guid)
    local btn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(btn, "index"))

    local item = GUI.GetParentElement(btn)

    -- 修改数量
    if HandInGuardTokenUI._token_change_data[index] then
        HandInGuardTokenUI._token_change_data[index].amount = HandInGuardTokenUI._token_change_data[index].amount - 1

        local num = GUI.GetChild(item, "Num" .. index)
        GUI.StaticSetText(num, HandInGuardTokenUI._token_change_data[index].amount .. "/" .. HandInGuardTokenUI._token_item_data[index].amount)
    else
        test(" HandInGuardTokenUI界面 HandInGuardTokenUI._dec_click方法 HandInGuardTokenUI._token_change_data[index]变量为空")
        CL.SendNotify(NOTIFY.ShowBBMsg, "系统错误")
        return ""
    end

    -- 减少按钮
    if HandInGuardTokenUI._token_change_data[index].amount <= 0 then
        local dec_btn = GUI.GetChild(item, "DecBtn" .. index)
        GUI.SetVisible(dec_btn, false)

        HandInGuardTokenUI.DecTimer:Stop()
        HandInGuardTokenUI.DecTimer:Reset(HandInGuardTokenUI.DecTimerFunction, 0.1, -1)
    end

    -- 修改显示的奇遇值
    if HandInGuardTokenUI._show_HE_value then
        local guard_item = DB.GetOnceItemByKey2(HandInGuardTokenUI._token_change_data[index].key_name)
        HandInGuardTokenUI._show_HE_value = HandInGuardTokenUI._show_HE_value - HandInGuardTokenUI._change_num(guard_item.KeyName, guard_item.Grade, 1)

        local HE_num = _gt.GetUI("happy_encounter_txt")
        GUI.StaticSetText(HE_num, "可获得奇遇值：" .. HandInGuardTokenUI._show_HE_value)
    else
        test(" HandInGuardTokenUI界面 HandInGuardTokenUI._dec_click方法 HandInGuardTokenUI._show_HE_value变量为空")
        CL.SendNotify(NOTIFY.ShowBBMsg, "系统错误")
        return ""
    end
end

-- 持续点击增加信物定时器
local btn_Guid = nil
-- 增加定时器的计数器
HandInGuardTokenUI.addTimerCount = 0
HandInGuardTokenUI.TimerFunction = function()
    if btn_Guid ~= nil then
        HandInGuardTokenUI.addTimerCount = HandInGuardTokenUI.addTimerCount + 1
        HandInGuardTokenUI._item_click(btn_Guid)
    end
end
HandInGuardTokenUI.ClickItemTimer = Timer.New(HandInGuardTokenUI.TimerFunction, 0.1, -1)
-- 按下 开始计时器 循环执行函数
function HandInGuardTokenUI.OnClickItemDown(guid)
    if HandInGuardTokenUI.ClickItemTimer ~= nil then
        btn_Guid = guid
        HandInGuardTokenUI.ClickItemTimer:Start()
    end
end

-- 松开 暂停计时器
function HandInGuardTokenUI.OnClickItemUp()
    HandInGuardTokenUI.addTimerCount = 0
    if HandInGuardTokenUI.ClickItemTimer ~= nil then
        btn_Guid = nil
        HandInGuardTokenUI.ClickItemTimer:Stop()
        HandInGuardTokenUI.ClickItemTimer:Reset(HandInGuardTokenUI.TimerFunction, 0.1, -1)
    end
end

-- 持续点击减少信物定时器
-- 长按
local DecBtn_Guid = nil
HandInGuardTokenUI.DecTimerFunction = function()
    if DecBtn_Guid ~= nil then
        HandInGuardTokenUI._dec_click(DecBtn_Guid)
    end
end

HandInGuardTokenUI.DecTimer = Timer.New(HandInGuardTokenUI.DecTimerFunction, 0.1, -1)

-- 松开
function HandInGuardTokenUI.OnDecUp()
    if HandInGuardTokenUI.DecTimer ~= nil then
        DecBtn_Guid = nil
        HandInGuardTokenUI.DecTimer:Stop()
        HandInGuardTokenUI.DecTimer:Reset(HandInGuardTokenUI.DecTimerFunction, 0.1, -1)
    end
end

-- 按下
function HandInGuardTokenUI.OnDecDown(guid)
    if HandInGuardTokenUI.DecTimer ~= nil then
        DecBtn_Guid = guid
        HandInGuardTokenUI.DecTimer:Start()
    end
end

-- 满星多选框事件
HandInGuardTokenUI.eventOfShowMaxStarCheckBox = function(guid)
    local cb = GUI.GetByGuid(guid)
    -- 取出来的值是已经取反了的 是一个坑
    local isCheck = GUI.CheckBoxExGetCheck(cb)
    GUI.CheckBoxExSetCheck(cb, isCheck)
    HandInGuardTokenUI.isOpenFilterByIsMaxStar = isCheck
    if HandInGuardTokenUI._token_change_data and isCheck then
        local filterData = HandInGuardTokenUI._filterByIsMaxStar(HandInGuardTokenUI._token_change_data)
        local advenceValue = HandInGuardTokenUI._reduceAdventureV({ 'key_name', 'is_bind' }, HandInGuardTokenUI._token_change_data, filterData)
        -- 将过滤的物品的奇遇值减去
        if HandInGuardTokenUI._show_HE_value then
            HandInGuardTokenUI._show_HE_value = HandInGuardTokenUI._show_HE_value - advenceValue
        end
        -- 将过滤后的选中物品数据设置上
        HandInGuardTokenUI._token_change_data = filterData
    end
    HandInGuardTokenUI._sub_refresh(true)
end
-- 绑定多选框事件
HandInGuardTokenUI.eventOfBindCheckBox = function(guid)
    local cb = GUI.GetByGuid(guid)
    -- 取出来的值是已经取反了的 是一个坑
    local isCheck = GUI.CheckBoxExGetCheck(cb)
    GUI.CheckBoxExSetCheck(cb, isCheck)
    -- 当进行过滤时 对准备上交的信物也进行过滤
    if HandInGuardTokenUI._token_change_data and isCheck then
        local filterData = HandInGuardTokenUI._filterByIsBind(HandInGuardTokenUI._token_change_data)
        local advenceValue = HandInGuardTokenUI._reduceAdventureV({ 'key_name', 'is_bind' }, HandInGuardTokenUI._token_change_data, filterData)
        -- 将过滤的物品的奇遇值减去
        if HandInGuardTokenUI._show_HE_value then
            HandInGuardTokenUI._show_HE_value = HandInGuardTokenUI._show_HE_value - advenceValue
        end
        -- 将过滤后的选中物品数据设置上
        HandInGuardTokenUI._token_change_data = filterData
    end

    HandInGuardTokenUI.isOpenFilterByIsBind = isCheck
    HandInGuardTokenUI._sub_refresh(true)
end

-- 选中全部确认框
function HandInGuardTokenUI.OnEquipDonateBtnClick()
    if HandInGuardTokenUI.selectAllIsUseConfirmation == true then
        GlobalUtils.ShowBoxMsg2Btn("确认选中全部", "确认选中全部吗？", "HandInGuardTokenUI", "确认", "selectAllTokens", "取消")
    else
        HandInGuardTokenUI.selectAllTokens()
    end
end
-- 选中全部
HandInGuardTokenUI.selectAllTokens = function()
    -- 所能增加的奇遇值
    local all_show_HE_value = 0
    -- 小失误，当前能上交的信物列表和选中准备上交的信物列表数据不一样，计算能获得多少奇遇值时需要grade而选中准备上交信物列表中没有这个字段，当时应该是想减少数据所占内存的大小
    for k, v in ipairs(HandInGuardTokenUI._token_item_data) do
        HandInGuardTokenUI._token_change_data[k] = {
            key_name = v.keyName,
            is_bind = v.is_bind,
            amount = v.amount
        }
        all_show_HE_value = all_show_HE_value + HandInGuardTokenUI._change_num(v.keyName, v.grade, v.amount)
    end

    -- 修改界面显示的奇遇值全局变量
    HandInGuardTokenUI._show_HE_value = all_show_HE_value

    --local scroll = _gt.GetUI("guard_token_scroll")
    --local count = HandInGuardTokenUI._scroll_max_num
    --for i=1,count do
    --    local item_node = GUI.GetChild(scroll, "Item" .. i)
    --    if item_node then
    --        if HandInGuardTokenUI._token_change_data[i] and HandInGuardTokenUI._token_item_data then
    --            local num = GUI.GetChild(item_node, "Num" .. i)
    --            GUI.StaticSetText(num, HandInGuardTokenUI._token_change_data[i].amount .. "/" .. HandInGuardTokenUI._token_item_data[i].amount)
    --
    --            -- 显示减少按钮
    --            local dec_btn = GUI.GetChild(item_node, "DecBtn" .. i)
    --            GUI.SetVisible(dec_btn, true)
    --        end
    --    end
    --end
    --
    --local HE_num = _gt.GetUI("happy_encounter_txt")
    --GUI.StaticSetText(HE_num, "可获得奇遇值：" .. HandInGuardTokenUI._show_HE_value)

    -- 修改奇遇值显示 在刷新界面中已经有了
    -- 刷新界面
    HandInGuardTokenUI.refresh()
end
-- 清除选中
HandInGuardTokenUI.clearSelectBtnEvent = function()
    HandInGuardTokenUI._token_change_data = {}
    HandInGuardTokenUI._show_HE_value = 0
    HandInGuardTokenUI.refresh()
end

--[[
	============================
	------ 向服务器发送数据 -------
	============================
]]

-- 兑换事件
function HandInGuardTokenUI._submit_change()
    if not HandInGuardTokenUI._token_change_data or next(HandInGuardTokenUI._token_change_data) == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, "未选中任何道具")
        return ""
    end

    -- CDebug.LogError(inspect(HandInGuardTokenUI._token_change_data))
    -- 对数据汇总下
    local data = {}
    for _, v in pairs(HandInGuardTokenUI._token_change_data) do
        if v.amount > 0 then
            if data[v.key_name .. "_" .. v.is_bind] then
                data[v.key_name .. "_" .. v.is_bind] = v.amount + data[v.key_name .. "_" .. v.is_bind]
            else
                data[v.key_name .. "_" .. v.is_bind] = v.amount
            end
        end
    end

    -- CDebug.LogError(inspect(data))

    local str = ""
    for k, v in pairs(data) do
        local tmp = string.split(k, "_")
        -- 将0非绑定1绑定改成 服务端需要的1非绑定2绑定
        if tmp[2] == "0" then
            tmp[2] = 1
        else
            tmp[2] = 2
        end
        str = str .. tmp[1] .. "_" .. v .. "_" .. tmp[2] .. "_"
    end

    -- CDebug.LogError(str)
    -- if true then return end

    if str ~= "" then
        -- 上交信物
        -- 有物品变化监听事件 无需执行回调刷新
        CL.SendNotify(NOTIFY.SubmitForm, "FormYunYouXianNPC", "ExchangeAdv", str)

        -- 对页面进行刷新
        --HandInGuardTokenUI._sub_refresh()
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, "未选中任何道具")
    end
end

--[[
	============================
	--------- 其他方法 ----------
	============================
]]
-- 合并成绑定和非绑定
HandInGuardTokenUI._merge = function(tab)
    -- 将所有相同id及是否绑定的数量合并
    local tmp = {}
    for _, v in ipairs(tab) do
        local t = tmp[v.id .. "-" .. v.is_bind]
        if t then
            t.amount = t.amount + v.amount
            v = nil
        else
            tmp[v.id .. "-" .. v.is_bind] = v
        end
    end

    -- 将数据还原成数组
    local results = {}
    for _, v in pairs(tmp) do
        -- 对最大数量进行限制 因为显示上越界了
        if v.amount > 999 then
            v.amount = 999
        end
        table.insert(results, v)
    end
    return results
end
-- 排序方法 品质-id-相同id(是否绑定)
HandInGuardTokenUI._sort = function(t1, t2)
    if t1.grade > t2.grade then
        return true
    elseif t1.grade < t2.grade then
        return false
    elseif t1.grade == t2.grade then
        if t1.id < t2.id then
            return true
        elseif t1.id > t2.id then
            return false
        elseif t1.id == t2.id then
            if t1.is_bind > t2.is_bind then
                return true
            else
                return false
            end
        end
    end
    return true
end
-- 根据是否绑定进行过滤
HandInGuardTokenUI._filterByIsBind = function(tab)
    local tmp = {}
    for _, v in pairs(tab) do
        -- 1 为绑定
        if v.is_bind == 1 then
            table.insert(tmp, v)
        end
    end
    return tmp
end

-- 根据侍从是否满星进行过滤
HandInGuardTokenUI._filterByIsMaxStar = function(tab)
    local tmp = {}
    for _, v in pairs(tab) do
        local guardName = string.split((v.keyName or v.key_name), "信物")[1]
        local guardDB = DB.GetOnceGuardByKey2(guardName)
        local guardId = guardDB.Id
        local isHaveGuard = LD.IsHaveGuard(guardId) -- 侍从是否拥有
        if isHaveGuard then
            local starLevel = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(guardId)))
            if starLevel >= maxStar then
                table.insert(tmp, v)
            end
        end
    end
    return tmp
end

---@param  condition table
---@param t1 table
---@param t2 table
---将t2(map表)根据condition(条件字段)匹配t1(index表)返回一个符合条件的index表
HandInGuardTokenUI._getIndexTable = function(condition, t1, t2)
    local tmp = {}

    for _, v1 in pairs(t2) do
        for k, v in ipairs(t1) do
            -- 遍历判断所有条件
            for _, v2 in ipairs(condition) do
                local value = v1[v2]
                if v2 == 'keyName' and value == nil then
                    value = v1['key_name']
                end
                if (value ~= v[v2]) then
                    -- 如果条件不满足直接进行下一个
                    goto continue
                end
            end
            tmp[k] = v1
            :: continue ::
        end
    end
    return tmp
end

-- 存储待上交信物数据过滤时，过滤掉的信物数据需要减去他们所增加的奇遇值
-- 表1是未过滤前的数据 表2是过滤后的数据
-- 返回值为应该减少的奇遇值
HandInGuardTokenUI._reduceAdventureV = function(conditions, tab1, tab2)
    local advanceValue = 0
    if #tab2 <= 0 then
        return advanceValue
    end

    for _, v in pairs(tab1) do
        local isReduce = true
        for _, v1 in pairs(tab2) do
            --if v['key_name'] == v1['key_name'] and v['is_bind'] == v1['is_bind'] then
            --    isReduce = false
            --    break
            --end

            -- 正 正 -> isReduce false
            -- 正 负 -> isReduce true
            -- 负 负 -> isReduce true
            local is = true
            for _, condition in ipairs(conditions) do
                if v[condition] == v1[condition] then
                else
                    is = false
                    break
                end
            end

            if is then
                isReduce = false
                break
            end

        end

        if isReduce then
            local guardItem = DB.GetOnceItemByKey2(v.key_name)
            advanceValue = advanceValue + HandInGuardTokenUI._change_num(guardItem.KeyName, guardItem.Grade, v.amount)
            -- CDebug.LogError('减少的奇遇值 ： '..advenceValue)
        end
    end
    return advanceValue
end

-- 使用满星过滤 并选中所有
HandInGuardTokenUI.useMaxStarFilterAndSelectAll = function()
    local fun = function()
        local showMaxStarCheckBox = _gt.GetUI('showMaxStarCheckBox')
        GUI.CheckBoxExSetCheck(showMaxStarCheckBox, true)
        local guid = GUI.GetGuid(showMaxStarCheckBox)
        HandInGuardTokenUI.eventOfShowMaxStarCheckBox(guid)
        HandInGuardTokenUI.selectAllTokens()
    end
    --local timer =   Timer.New(fun,1,1)
    --timer:Start()
    fun()
end