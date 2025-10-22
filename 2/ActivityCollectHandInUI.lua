-- 上交侍从信物换取奇遇值
local ActivityCollectHandInUI = {}
_G.ActivityCollectHandInUI = ActivityCollectHandInUI

local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

local itemId = nil
local itemNum = nil
local flag = 0

function ActivityCollectHandInUI.Main()
    local _Panel = GUI.WndCreateWnd("ActivityCollectHandInUI", "ActivityCollectHandInUI", 0, 0, eCanvasGroup.Normal)
    local _PanelBack = UILayout.CreateFrame_WndStyle2(_Panel,"上交道具",560,435,"ActivityCollectHandInUI","OnExit")
    _gt.BindName(_PanelBack, "_PanelBack")
end


function ActivityCollectHandInUI.OnShow()

    local wnd = GUI.GetWnd('ActivityCollectHandInUI')
    GUI.SetVisible(wnd, true)

    -- 注册监听事件
    ActivityCollectHandInUI._register()

    ActivityCollectHandInUI.refresh()

    itemId = ActivityCollectHandInUI.ItemId     -- 需要上交的物品id 服务器提供
    itemNum = ActivityCollectHandInUI.ItemNum   -- 需要上交的物品数量 服务器提供
    flag = 0                                    -- 玩家已经选中的物品数量

    if itemId == nil then
        return
    end

    local _PanelBack = _gt.GetUI("_PanelBack")
    -- 道具列表背景
    local img_bg = GUI.ImageCreate(_PanelBack, 'scroll_img_bg', "1800400010", -3, -30, false, 509, 274)
    SetSameAnchorAndPivot(img_bg, UILayout.Center)
    -- 道具列表
    local enhanceVecSize = Vector2.New(80,80)
    local scroll = GUI.ScrollRectCreate(img_bg,
            "guard_token_scroll",
            0,
            0,
            490,
            250,
            0,
            false,
            enhanceVecSize,
            UIAroundPivot.Center,
            UIAnchor.Center,
            6)
    GUI.ScrollRectSetChildSpacing(scroll, Vector2.New(1, 1));
    SetSameAnchorAndPivot(scroll, UILayout.Center)
    _gt.BindName(scroll, 'guard_token_scroll')

    -- 上交按钮
    local sub_btn = GUI.ButtonCreate(_PanelBack, 'sub_btn', "1800402080", -5, 172, Transition.ColorTint, '上交', 140, 47,false)
    SetSameAnchorAndPivot(sub_btn, UILayout.Center)
    GUI.ButtonSetTextColor(sub_btn, UIDefine.WhiteColor)
    GUI.ButtonSetTextFontSize(sub_btn, UIDefine.FontSizeL)
    GUI.ButtonSetOutLineArgs(sub_btn, true, UIDefine.Brown3Color, 1)
    GUI.RegisterUIEvent(sub_btn, UCE.PointerClick, 'ActivityCollectHandInUI', '_submit_change')

    ActivityCollectHandInUI._sub_refresh()
end

function ActivityCollectHandInUI.OnExit()
    ActivityCollectHandInUI._unregister()
    GUI.Destroy('ActivityCollectHandInUI')
end

-- 创建界面 --

-- 创建道具节点
function ActivityCollectHandInUI._create_scroll_node(num)

    if not num then
        CL.SendNotify(NOTIFY.ShowBBMsg, "系统错误")
        return ''
    end

    local scroll = _gt.GetUI('guard_token_scroll')

    for i=1, num do
        -- 获取当前执行的次数
        local count = i
        local _Item = GUI.GetChild(scroll, "Item"..count)
        if _Item == nil then
            --底板
            _Item = GUI.ImageCreate( scroll, "Item"..count, "1800600050", 0, 0, false, 78, 78)
            SetAnchorAndPivot(_Item, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.SetVisible(_Item, true)

            --图标
            local _Icon = GUI.ItemCtrlCreate( _Item, tostring(count), "1800600050", 0, 0, 76, 76, false)
            SetAnchorAndPivot(_Icon, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(_Icon, false)
            GUI.ItemCtrlSetElementRect(_Icon,eItemIconElement.Icon,0,-2,67,67)
            GUI.ItemCtrlSetElementRect(_Icon, eItemIconElement.Border, 0 , 1.5, 76, 76)
            GUI.RegisterUIEvent(_Icon , UCE.PointerClick , "ActivityCollectHandInUI", "_item_click" )
            --_Icon:RegisterEvent(UCE.PointerUp)
            --_Icon:RegisterEvent(UCE.PointerDown)
            --GUI.RegisterUIEvent(_Icon, UCE.PointerDown , "WingUI", "OnClickItemDown")
            --GUI.RegisterUIEvent(_Icon, UCE.PointerUp , "WingUI", "OnClickItemUp")

            --数量
            local _Num = GUI.CreateStatic( _Item, "Num"..count, "0/0", -28, -3, 100, 35)
            SetSameAnchorAndPivot(_Num, UILayout.BottomLeft)
            GUI.StaticSetFontSize(_Num, UIDefine.FontSizeS)
            GUI.SetColor(_Num, UIDefine.WhiteColor)
            GUI.SetIsOutLine(_Num, true)
            GUI.SetOutLine_Distance(_Num, 1)
            GUI.SetOutLine_Color(_Num, UIDefine.BlackColor)
            GUI.StaticSetAlignment(_Num,TextAnchor.LowerRight)
            GUI.SetVisible(_Num, false)

            --选中标记
            local _SelectFlag = GUI.ImageCreate( _Item, "SelectFlag", "1800400280", 0, 0)
            SetAnchorAndPivot(_SelectFlag, UIAnchor.Center, UIAroundPivot.Center)
            GUI.SetVisible(_SelectFlag, false)

            --减少按钮
            local _DecBtn = GUI.ButtonCreate(_Item, "DecBtn"..count, "1800702070",2,0, Transition.ColorTint, "", 24,24, false)
            SetAnchorAndPivot(_DecBtn, UIAnchor.TopRight, UIAroundPivot.TopRight)
            GUI.SetVisible(_DecBtn, false)
            GUI.RegisterUIEvent(_DecBtn , UCE.PointerClick , "ActivityCollectHandInUI", "_dec_click" )
            --_DecBtn:RegisterEvent(UCE.PointerUp)
            --_DecBtn:RegisterEvent(UCE.PointerDown)
            --GUI.RegisterUIEvent(_DecBtn, UCE.PointerDown , "WingUI", "OnDecDown")
            --GUI.RegisterUIEvent(_DecBtn, UCE.PointerUp , "WingUI", "OnDecUp")

        end

    end

end


-- 刷新界面 --

-- 刷新道具节点
function ActivityCollectHandInUI._refresh_scroll_node(num)

    --if not ActivityCollectHandInUI._token_item_data then
    ActivityCollectHandInUI._token_item_data = ActivityCollectHandInUI._get_all_token()
    --end
    local dataLen = #ActivityCollectHandInUI._token_item_data + 1
    local scroll = _gt.GetUI('guard_token_scroll')

    if itemId == nil then
        return
    end

    -- 更新道具框
    for index = 1, num do
        local node_ui = GUI.GetChild(scroll, "Item"..index)
        if node_ui then GUI.SetVisible(node_ui, true) end

        -- 在道具数据范围内
        if node_ui and  index <= #ActivityCollectHandInUI._token_item_data then
            local data = ActivityCollectHandInUI._token_item_data[index]
            local item = DB.GetOnceItemByKey1(data.id)

            -- 头像
            local icon = GUI.GetChild(node_ui, tostring(index))
            GUI.SetVisible(icon, true)
            GUI.SetData(icon, 'select_index', index)
            GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, item.Icon)
            GUI.ItemCtrlSetIconGray(icon,false)

            -- 品质框
            GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Border, UIDefine.ItemIconBg[item.Grade])

            -- 绑定图标
            if data.is_bind ~= '0' then
                GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp,"1800707120")
            else
                GUI.ItemCtrlSetElementValue(icon, eItemIconElement.LeftTopSp, '')
            end

            -- 数量
            local num = GUI.GetChild(node_ui, 'Num'..index)
            GUI.StaticSetText(num, '0/'..data.amount)
            GUI.SetVisible(num, true)
            --选中标记
            local select = GUI.GetChild(node_ui, 'SelectFlag')
            GUI.SetVisible(select, false)
            -- 减少按钮
            local dec_btn = GUI.GetChild(node_ui, 'DecBtn'..index)
            GUI.SetVisible(dec_btn, false)
            GUI.SetData(dec_btn, 'index', index)
            -- 在道具数据范围外
        else

            -- 道具icon
            local icon = GUI.GetChild(node_ui, tostring(index))
            GUI.SetVisible(icon, false)
            -- 数量
            local num = GUI.GetChild(node_ui, 'Num'..index)
            GUI.SetVisible(num, false)
            --选中标记
            local select = GUI.GetChild(node_ui, 'SelectFlag')
            GUI.SetVisible(select, false)

            -- 减少按钮
            local dec_btn = GUI.GetChild(node_ui, 'DecBtn'..index)
            GUI.SetVisible(dec_btn, false)
        end

    end

    local node_ui = GUI.GetChild(scroll, "Item"..dataLen)
    local item = DB.GetOnceItemByKey1(itemId)
    -- 最后跟一个灰色的，点击打开获取途径
    local icon = GUI.GetChild(node_ui, tostring(dataLen))
    GUI.SetVisible(icon, true)
    GUI.SetData(icon, 'select_index', dataLen)
    GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Icon, item.Icon)
    GUI.ItemCtrlSetIconGray(icon,true)
    GUI.ItemCtrlSetElementValue(icon, eItemIconElement.Border,"1800608290")
    GUI.RegisterUIEvent(icon,UCE.PointerClick,"ActivityCollectHandInUI","OnItemClick")

    -- 隐藏多出的道具框
    if ActivityCollectHandInUI._scroll_max_num ~= nil and ActivityCollectHandInUI._scroll_max_num > num + 1 then
        for index = num + 2 , ActivityCollectHandInUI._scroll_max_num do
            local node_ui = GUI.GetChild(scroll, "Item"..index)
            if node_ui then GUI.SetVisible(node_ui, false) end
        end
    end

end

function ActivityCollectHandInUI.OnItemClick()
    ActivityCollectHandInUI.MaterialsTips(itemId)
end

--材料Tips
function ActivityCollectHandInUI.MaterialsTips(itemId)
    local wnd = GUI.GetWnd('ActivityCollectHandInUI')
    local itemTips=Tips.CreateByItemId(itemId,wnd,"MaterialsTips",300,300,50)
    GUI.SetData(itemTips,"ItemId",itemId)
    _gt.BindName(itemTips,"itemTips")
    local wayBtn=GUI.ButtonCreate(itemTips,"wayBtn","1800402110",0,-10,Transition.ColorTint,"获得途径", 150, 50, false)
    SetAnchorAndPivot(wayBtn,UIAnchor.Bottom,UIAroundPivot.Bottom)
    GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
    GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(wayBtn,UCE.PointerClick,"ActivityCollectHandInUI","onClickWayBtn")
    GUI.AddWhiteName(itemTips, GUI.GetGuid(wayBtn))
end
--获得途径按钮点击
function ActivityCollectHandInUI.onClickWayBtn()
    -- test("waybtn点击")
    local itemTips=_gt.GetUI("itemTips")
    if itemTips==nil then
        test("Tips is nil")
    end
    if itemTips then
        Tips.ShowItemGetWay(itemTips)
    end
end


-- 刷新整个界面
function ActivityCollectHandInUI.refresh()

    if not ActivityCollectHandInUI._token_item_data then
        -- 将背包内道具存储下来，当其变化时更新，减少运行次数
        ActivityCollectHandInUI._token_item_data = ActivityCollectHandInUI._get_all_token()
    end

    local num = 18
    if num < #ActivityCollectHandInUI._token_item_data then
        num = math.ceil(#ActivityCollectHandInUI._token_item_data / 6) * 6
    end

    if ActivityCollectHandInUI._scroll_max_num == nil or num > ActivityCollectHandInUI._scroll_max_num then
        ActivityCollectHandInUI._scroll_max_num = num
    end

    -- 创建节点
    ActivityCollectHandInUI._create_scroll_node(num)
    -- 刷新节点
    ActivityCollectHandInUI._refresh_scroll_node(num)

    local scroll = _gt.GetUI('guard_token_scroll')
    GUI.ScrollRectSetNormalizedPosition(scroll, Vector2.New(0, 1))

end

-- 上交道具后的刷新
function ActivityCollectHandInUI._sub_refresh()
    ActivityCollectHandInUI._token_item_data = nil
    -- 准备道具数据
    ActivityCollectHandInUI._token_change_data = {}
    -- 上一次选中道具的下标
    ActivityCollectHandInUI._pre_select_token = nil

    ActivityCollectHandInUI.refresh()

end


-- 非请求服务器获取数据 --

-- 获取包裹内所有的侍从信物
function ActivityCollectHandInUI._get_all_token()

    local tokens = {}
    if itemId == nil then
        return tokens
    end

    -- 这里是循环了整个背包找到道具guid
    local guardBag_Count = LD.GetItemCount(item_container_type.item_container_bag)
    for i = 0, guardBag_Count - 1 do
        -- 物品guid
        local guardGuid = tostring(LD.GetItemGuidByItemIndex(i, item_container_type.item_container_bag))
        -- 物品id
        local item_id = LD.GetItemAttrByGuid(ItemAttr_Native.Id, guardGuid, item_container_type.item_container_bag)
        if item_id == tostring(itemId) then
            -- 物品是否绑定
            local is_bind = LD.GetItemAttrByGuid(ItemAttr_Native.IsBound, guardGuid, item_container_type.item_container_bag)
            -- 物品拥有数量
            local item_amount = LD.GetItemAttrByGuid(ItemAttr_Native.Amount, guardGuid, item_container_type.item_container_bag)

            local info = {
                id = item_id,
                is_bind = is_bind,
                amount = tonumber(item_amount)
            }

            table.insert(tokens, info)
        end
    end
    return tokens
end

-- 点击事件 --

-- 准备兑换的道具数据
ActivityCollectHandInUI._token_change_data = {} -- [1] = {is_bind, key_name, amount}
-- 上一次选中道具的下标
ActivityCollectHandInUI._pre_select_token = nil

-- 图片点击事件
function ActivityCollectHandInUI._item_click(guid)
    local btn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(btn, 'select_index'))

    if not ActivityCollectHandInUI._token_item_data then
        ActivityCollectHandInUI._token_item_data = ActivityCollectHandInUI._get_all_token()
    end

    if ActivityCollectHandInUI._token_item_data[index] == nil then
        return
    end

    local guard_item = DB.GetOnceItemByKey1(ActivityCollectHandInUI._token_item_data[index].id)

    if itemNum <= flag then
        CL.SendNotify(NOTIFY.ShowBBMsg, "数量已经足够！只需要"..tostring(itemNum).."个")
        return
    end

    flag = flag + 1

    local item = GUI.GetParentElement(btn)

    -- 显示选中标记框,关闭上一个选中框
    local select = GUI.GetChild(item, 'SelectFlag')
    if not ActivityCollectHandInUI._pre_select_token then
        GUI.SetVisible(select, true)
    elseif ActivityCollectHandInUI._pre_select_token ~= index then
        local scroll = _gt.GetUI('guard_token_scroll')
        local pre_item = GUI.GetChild(scroll, 'Item'..ActivityCollectHandInUI._pre_select_token)
        local pre_select = GUI.GetChild(pre_item, 'SelectFlag')
        GUI.SetVisible(pre_select, false)
        GUI.SetVisible(select, true)
    end
    ActivityCollectHandInUI._pre_select_token = index

    -- 修改数量
    if not ActivityCollectHandInUI._token_change_data[index] then
        local key_name = guard_item.KeyName
        ActivityCollectHandInUI._token_change_data[index] = {
            key_name = key_name,
            --is_bind = ActivityCollectHandInUI._token_item_data[index].is_bind,
            amount = 1
        }
    else
        -- 选中信物数量不能超过已有数量
        if ActivityCollectHandInUI._token_change_data[index].amount >= ActivityCollectHandInUI._token_item_data[index].amount then
            return ''
        end
        ActivityCollectHandInUI._token_change_data[index].amount = ActivityCollectHandInUI._token_change_data[index].amount + 1
    end

    local num = GUI.GetChild(item, 'Num'..index)
    GUI.StaticSetText(num, ActivityCollectHandInUI._token_change_data[index].amount..'/'..ActivityCollectHandInUI._token_item_data[index].amount)

    -- 显示减少按钮
    local dec_btn = GUI.GetChild(item, 'DecBtn'..index)
    GUI.SetVisible(dec_btn, true)


end

-- 减少按钮点击事件
function ActivityCollectHandInUI._dec_click(guid)
    local btn = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(btn, 'index'))

    local item = GUI.GetParentElement(btn)

    if flag >= 1 then
        flag = flag - 1
    end

    -- 修改数量
    if ActivityCollectHandInUI._token_change_data[index] then
        ActivityCollectHandInUI._token_change_data[index].amount = ActivityCollectHandInUI._token_change_data[index].amount - 1

        local num = GUI.GetChild(item, 'Num'..index)
        GUI.StaticSetText(num, ActivityCollectHandInUI._token_change_data[index].amount..'/'..ActivityCollectHandInUI._token_item_data[index].amount)
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, '系统错误')
        return ''
    end


    -- 减少按钮
    if ActivityCollectHandInUI._token_change_data[index].amount <= 0 then
        local dec_btn = GUI.GetChild(item, 'DecBtn'..index)
        GUI.SetVisible(dec_btn, false)
    end
end


--  向服务器发送数据 --

-- 兑换事件
function ActivityCollectHandInUI._submit_change()
    if not ActivityCollectHandInUI._token_change_data or next(ActivityCollectHandInUI._token_change_data ) == nil then
        CL.SendNotify(NOTIFY.ShowBBMsg, '未选中任何道具')
        return ''
    end

    --local inspect  = require 'inspect'
    -- 对数据汇总下
    local data = {}
    for k, v in pairs(ActivityCollectHandInUI._token_change_data) do
        if data[v.key_name] then
            data[v.key_name] = v.amount + data[v.key_name]
        else
            data[v.key_name] = v.amount
        end
    end

    --CDebug.LogError(inspect(data))

    local str = ''
    for k, v in pairs(data) do
        str = str..k..'_'..v..'_'
    end

    --CDebug.LogError(str)

    if str ~= '' then
        -- 上交信物
        -- 有物品变化监听事件 无需执行回调刷新
        --CL.SendNotify(NOTIFY.SubmitForm, 'FormYunYouXianNPC', 'ExchangeAdv',str)
        if flag < itemNum then
            CL.SendNotify(NOTIFY.ShowBBMsg, "数量不足，需要"..tostring(itemNum).."个！")
        else
            CL.SendNotify(NOTIFY.SubmitForm, "FormCollect", "HandItem", str)
        end
        -- 对页面进行刷新
        --ActivityCollectHandInUI._sub_refresh()
    else
        CL.SendNotify(NOTIFY.ShowBBMsg, '未选中任何道具')
    end
end

-- 注册监听事件
function ActivityCollectHandInUI._register()
    CL.RegisterMessage(GM.RefreshBag,'ActivityCollectHandInUI','_sub_refresh')
end

-- 关闭监听事件
function ActivityCollectHandInUI._unregister()
    CL.UnRegisterMessage(GM.RefreshBag,'ActivityCollectHandInUI','_sub_refresh')
end