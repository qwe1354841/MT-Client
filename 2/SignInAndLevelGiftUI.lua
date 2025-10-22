-- 签到奖励/等级奖励/侍从激活 弹出窗口
local SignInAndLevelGiftUI = {}
_G.SignInAndLevelGiftUI = SignInAndLevelGiftUI

-- 每日登陆和等级礼包 以及侍从信物

local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

-- 每日登陆高度
local sign_in_height = 280
local sign_image = '1801407220'

-- 等级礼包高度
local level_gift_height = 280
local level_gift_image = '1801407210'

-- 侍从信物高度
local guard_height = 280
local guard_image = '1801407230'

function SignInAndLevelGiftUI.Main(parameter)

    -- 如果是第一次打开还没有界面
    local item = nil
    local type = nil
    if UIDefine and UIDefine.prompt_sequence and UIDefine.prompt_sequence.current_show == nil then
        if parameter then
            -- 物品id_type   type 1 每日签到 2 等级礼包 3 侍从
            local temp = string.split(parameter,'_')
            local item_id = tonumber(temp[1])
            type = tonumber(temp[2])
            item = DB.GetOnceItemByKey1(item_id)
            if not type or not item or item.Id == 0 then
                test('SignInAndLevelGiftUI  打开界面时传入的参数parameter错误')
                return
            end
        end

    end

    local wnd = GUI.WndCreateWnd("SignInAndLevelGiftUI", "SignInAndLevelGiftUI", 0, 0,eCanvasGroup.Normal_Extend);

    -- 界面高度
    local border = GUI.ImageCreate(wnd, "border", "1800400290", -220, -130, false, 220, sign_in_height);
    GUI.SetAnchor(border, UIAnchor.BottomRight)
    GUI.SetPivot(border, UIAroundPivot.Bottom)
    --GUI.SetVisible(border, false);
    _gt.BindName(border,"border")
    GUI.SetIsRaycastTarget(border,true);


    local itemIcon = ItemIcon.Create(border,"itemIcon",0,-65);
    GUI.SetAnchor(itemIcon, UIAnchor.Top)
    GUI.SetPivot(itemIcon, UIAroundPivot.Center)
    GUI.RegisterUIEvent(itemIcon, UCE.PointerClick, "SignInAndLevelGiftUI", "OnItemIconClick")

    local nameText = GUI.CreateStatic(border, "nameText", "名字", 0, -130, 220, 35);
    GUI.SetColor(nameText, UIDefine.GradeColor[1]);
    GUI.StaticSetFontSize(nameText, UIDefine.FontSizeL);
    GUI.StaticSetAlignment(nameText, TextAnchor.MiddleCenter);
    GUI.SetPivot(nameText, UIAroundPivot.Center)
    GUI.SetAnchor(nameText, UIAnchor.Top)

    local FightValue = GUI.ImageCreate(border,"FightValue",sign_image,0,-40,false,145,50)
    GUI.SetPivot(FightValue, UIAroundPivot.Center)
    GUI.SetAnchor(FightValue, UIAnchor.Center)

    --local FightValueText = GUI.CreateStatic(border, "FightValueText", "0", 30, -165, 220, 50);
    --GUI.SetColor(FightValueText, UIDefine.Green7Color);
    --GUI.StaticSetFontSize(FightValueText, UIDefine.FontSizeXXL);
    --GUI.StaticSetAlignment(FightValueText, TextAnchor.MiddleCenter);
    --GUI.SetPivot(FightValueText, UIAroundPivot.Center)
    --GUI.SetAnchor(FightValueText, UIAnchor.Top)


    local closeBtn = GUI.ButtonCreate(border, "closeBtn", 1800302120, 2, 2, Transition.ColorTint, "", 50, 50, false);
    UILayout.SetSameAnchorAndPivot(closeBtn, UILayout.TopRight);
    GUI.RegisterUIEvent(closeBtn, UCE.PointerClick, "SignInAndLevelGiftUI", "OnExit")

    local useBtn = GUI.ButtonCreate(border, "useBtn", 1800402110, 0, 15, Transition.ColorTint, "领取", 120, 50, false);
    UILayout.SetSameAnchorAndPivot(useBtn, UILayout.Bottom);
    GUI.ButtonSetTextColor(useBtn, UIDefine.BrownColor);
    GUI.ButtonSetTextFontSize(useBtn, UIDefine.FontSizeL)
    GUI.RegisterUIEvent(useBtn, UCE.PointerClick, "SignInAndLevelGiftUI", "OnUseBtnClick")

    if type and item then
        -- 设置物品图片
        ItemIcon.BindItemDB(itemIcon,item)
        -- 设置字体
        GUI.StaticSetText(nameText,item.Name);
        GUI.SetColor(nameText,UIDefine.GradeColor[item.Grade]);

        if type == 1 then
            -- 设置高度
            GUI.SetHeight(border,sign_in_height)
            -- 设置显示图标
            GUI.ImageSetImageID(FightValue,sign_image)
        elseif type == 2 then
            GUI.SetHeight(border,level_gift_height)
            GUI.ImageSetImageID(FightValue,level_gift_image)
        elseif type == 3 then
            GUI.SetHeight(border,guard_height)
            GUI.ImageSetImageID(FightValue,guard_image)
            GUI.ButtonSetText(useBtn,'点击激活')
        end
    end


    -- 添加 切换角色 / 退出游戏 监听事件， 清空数据
    CL.RegisterMessage(GM.PlayerExitGame, "SignInAndLevelGiftUI", '_clear_data')
    CL.RegisterMessage(GM.PlayerExitLogin, "SignInAndLevelGiftUI", '_clear_data')
end

function SignInAndLevelGiftUI.OnShow(parameter)

    local wnd = GUI.GetWnd('SignInAndLevelGiftUI')
    if wnd == nil then return end

    if parameter then
        -- 物品id_type   type 1 每日签到 2 等级礼包 3 侍从
        local temp = string.split(parameter,'_')
        local item_id = tonumber(temp[1])
        local type = tonumber(temp[2])
        local item = DB.GetOnceItemByKey1(item_id)

        if type and item and item.Id ~= 0 then
            GUI.SetVisible(wnd,true)
            SignInAndLevelGiftUI._control_show(item,type)
        end
    end

end

function SignInAndLevelGiftUI.OnExit()


    -- 销毁界面开关
    local destroy_page_switch = true

    if UIDefine.prompt_sequence then

        -- 从对应界面的栈中移除这条
        if UIDefine.prompt_sequence.ui[UIDefine.prompt_sequence.current_show_type]~= nil then
            table.remove(UIDefine.prompt_sequence.ui[UIDefine.prompt_sequence.current_show_type].stack)
        end
        ----------------- 防止删除这条数据后，没有其他显示内容数据，导致打开下次打开显示有可能会显示上次的界面 ------------
        -- 设置将当前打开页面
        UIDefine.prompt_sequence.current_show = nil
        -- 设置当前打开界面的type
        UIDefine.prompt_sequence.current_show_type = nil
        ------------------------------------------------------

        -- 显示下一个界面
        for k,v in ipairs(UIDefine.prompt_sequence.ui) do
            -- 如果界面的栈中有数据
            if next(v.stack) then
                -- 如果不是4，显示这个界面
                if k ~= 4 then
                    local item_id = v.stack[#v.stack]
                    local item = DB.GetOnceItemByKey1(item_id)
                    local type = k
                    if type and item and item_id ~= 0 then
                        SignInAndLevelGiftUI._show_by_item(item,type)
                        -- 设置将当前打开页面
                        UIDefine.prompt_sequence.current_show = UIDefine.prompt_sequence.ui[type].page
                        -- 设置当前打开界面的type
                        UIDefine.prompt_sequence.current_show_type = type
                        -- 不销毁这个界面
                        destroy_page_switch = false
                        break
                    end
                    -- 如果是4 显示装备道具弹窗
                else
                    local ui_page = GUI.GetWnd(v.page)
                    if not ui_page then
                        GUI.OpenWnd(v.page)

                        if #v.stack > 0 then
                            -- 复制表中数据
                            local type_4_data = {}
                            for i, j in ipairs(v.stack) do
                                if type(j) == 'table' then
                                    table.insert(type_4_data, j)
                                end
                            end

                            for m, l in ipairs(type_4_data) do
                                if l[2] then
                                    QuickUseUI.Add(l[1], l[2])
                                else
                                    QuickUseUI.Add(l[1])
                                end
                                -- 如果不复制一份数据，这个时候就会有问题，add添加数据，而这又删除数据，可能会导致for循环遍历异常
                                table.remove(UIDefine.prompt_sequence.ui[k].stack, 1)
                            end
                        end

                    else
                        GUI.SetVisible(ui_page, true)
                    end
                    -- 设置将当前打开页面
                    UIDefine.prompt_sequence.current_show = UIDefine.prompt_sequence.ui[k].page
                    -- 设置当前打开界面的type
                    UIDefine.prompt_sequence.current_show_type = k
                    break
                end
            end
        end
    end

    if destroy_page_switch then
        GUI.CloseWnd('SignInAndLevelGiftUI')
        --GUI.DestroyWnd('SignInAndLevelGiftUI')
    end

end

-- 显示界面
function SignInAndLevelGiftUI._show_by_item(item,type)

    -- 设置图片
    local border = _gt.GetUI('border')
    local item_icon = GUI.GetChild(border,'itemIcon')
    ItemIcon.BindItemDB(item_icon,item)

    -- 设置字体
    local name_text = GUI.GetChild(border,'nameText')
    GUI.StaticSetText(name_text,item.Name);
    GUI.SetColor(name_text,UIDefine.GradeColor[item.Grade]);

    local fight_value = GUI.GetChild(border,'FightValue')
    local use_btn = GUI.GetChild(border,'useBtn')
    if type == 1 then
        -- 设置高度
        GUI.SetHeight(border,sign_in_height)
        -- 设置显示图标
        GUI.ImageSetImageID(fight_value,sign_image)
        -- 设置按钮字体
        GUI.ButtonSetText(use_btn,'领取')
    elseif type == 2 then
        GUI.SetHeight(border,level_gift_height)
        GUI.ImageSetImageID(fight_value,level_gift_image)
        GUI.ButtonSetText(use_btn,'领取')
    elseif type == 3 then
        GUI.SetHeight(border,guard_height)
        GUI.ImageSetImageID(fight_value,guard_image)
        GUI.ButtonSetText(use_btn,'点击激活')
    else
        test('SignInAndLevelGiftUI  打开界面时传入的参数错误')
    end

    -- 给按钮传递的数据
    GUI.SetData(use_btn,'item_id',item.Id)
    GUI.SetData(use_btn,'type',type)
    -- 点击头像的数据
    GUI.SetData(item_icon,'item_id',item.Id)
    -- 设置全局变量，用于直接调用模拟点击按钮方法
    SignInAndLevelGiftUI._btn_data = {}
    SignInAndLevelGiftUI._btn_data.item_id = item.Id
    SignInAndLevelGiftUI._btn_data.type = type

    -- 关闭tips
    local itemTips =_gt.GetUI("itemTips");
    if itemTips ~= nil then
        GUI.Destroy(itemTips);
    end


end

-- 每日签到提示>等级礼包提示>侍从激活提示>装备使用>道具使用
-- 控制显示
function SignInAndLevelGiftUI._control_show(item,type)
    if not UIDefine.prompt_sequence then test('UIDefine.prompt_sequence 数据不存在') return end

    local prompt_sequence = UIDefine.prompt_sequence

    --{
    --    ['ui'] = {
    --        [1] = {
    --            ['page'] = 'SignInAndLevelGiftUI', -- 对应的界面UI
    --            ['method'] = 'open_ui:', -- 是打开界面还是使用物品
    --            ['stack'] = {}, -- 栈数据
    --            --['type'] = 1, -- 属于哪个type -- type 与其index下标相等
    --            ['name'] = '每日签到' -- 名称
    --        },
    --        [2] = {
    --            ['page'] = 'SignInAndLevelGiftUI',
    --            ['method'] = 'open_ui:',
    --            ['stack'] = {},
    --            --['type'] = 2,
    --            ['name'] = '等级礼包'
    --        },
    --        [3] = {
    --            ['page'] = 'SignInAndLevelGiftUI',
    --            ['method'] = 'use_item:',
    --            ['stack'] = {},
    --            --['type'] = 3,
    --            ['name'] = '侍从激活'
    --        },
    --        [4] = {
    --            ['page'] = 'QuickUseUI',
    --            ['method'] = 'use_item:',
    --            ['stack'] = {},
    --            --['type'] = 4,
    --            ['name'] = '装备道具'
    --        }
    --    },
    --    current_show = nil, -- 当前打开页面
    --    current_show_type = nil, -- 当前打开界面的type
    --    page_list = {'SignInAndLevelGiftUI','QuickUseUI'} -- 在这个功能内，所有的页面，按优先级排列
    --}

    -- 如果当前没有打开任何相关界面
    --if prompt_sequence.current_show_type == nil then
    --    -- 显示数据
    --    SignInAndLevelGiftUI._show_by_item(item,type)
    --    -- 将数据存入栈
    --    table.insert(prompt_sequence.ui[type].stack,item.Id)
    --    -- 设置将当前打开页面
    --    prompt_sequence.current_show = prompt_sequence.ui[type].page
    --    -- 设置当前打开界面的type
    --    prompt_sequence.current_show_type = type
    --
    --    -- 如果要打开的界面比当前界面小 或者相等
    --else
    -- 如果界面未打开，或要打开界面 <= 当前界面的type
    if prompt_sequence.current_show_type == nil or type <= prompt_sequence.current_show_type then
        -- 如果是装备道具界面
        if prompt_sequence.current_show_type == 4 then
            -- 将当前界面隐藏
            local ui_page = GUI.GetWnd(prompt_sequence.current_show)
            GUI.SetVisible(ui_page,false)
        end
        -- 显示要打开的界面
        SignInAndLevelGiftUI._show_by_item(item,type)
        -- 将数据存入栈
        --table.insert(prompt_sequence.ui[type].stack,item.Id)
        SignInAndLevelGiftUI._insert_id(item.Id, prompt_sequence.ui[type].stack)
        -- 设置将当前打开页面
        prompt_sequence.current_show = prompt_sequence.ui[type].page
        -- 设置当前打开界面的type
        prompt_sequence.current_show_type = type

        -- 如果要打开的界面比当前界面大
    elseif type > prompt_sequence.current_show_type then
        -- 存入它对应的栈
        --table.insert(prompt_sequence.ui[type].stack,item.Id)
        SignInAndLevelGiftUI._insert_id(item.Id, prompt_sequence.ui[type].stack)

    end


end


-- 按钮点击事件
function SignInAndLevelGiftUI.OnUseBtnClick(guid)
    if not UIDefine.prompt_sequence then test('UIDefine.prompt_sequence 数据不存在') return end

    local btn = GUI.GetByGuid(guid)
    local item_id = tonumber(GUI.GetData(btn,'item_id'))
    local type = tonumber(GUI.GetData(btn,'type'))

    local data  = UIDefine.prompt_sequence
    local method = data.ui[type].method
    local temp = string.split(method,':')
    if temp[1] == 'open_ui' then
        GUI.OpenWnd(temp[2],'index:'..temp[3]..',index2:'..temp[4])
    elseif temp[1] == 'use_item' then
        -- 如果只是侍从，随便拿个它的guid，反正只是跳转到侍从界面
        local cell = LD.GetItemGuidsById(item_id,item_container_type.item_container_guard_bag)
        GlobalUtils.UseItem(cell[0])
    else
        test('SignInAndLevelGiftUI.OnUseBtnClick 数据错误')
    end

    SignInAndLevelGiftUI.OnExit()
end


-- tips 事件
function SignInAndLevelGiftUI.OnItemIconClick(guid)

    local itemTips =_gt.GetUI("itemTips");
    if itemTips~=nil then
        GUI.Destroy(itemTips);
        return;
    end

    local btn = GUI.GetByGuid(guid)
    local item_id = GUI.GetData(btn,'item_id')


    local border =_gt.GetUI("border");
    local itemTips=Tips.CreateByItemId(item_id,border,"itemTips",-220,0)
    UILayout.SetSameAnchorAndPivot(itemTips, UILayout.BottomRight)
    GUI.AddWhiteName(itemTips,guid);
    _gt.BindName(itemTips,"itemTips")
end


-- 模拟点击事件
function SignInAndLevelGiftUI.on_click_btn()
    if not (SignInAndLevelGiftUI._btn_data and SignInAndLevelGiftUI._btn_data.item_id and SignInAndLevelGiftUI._btn_data.type) then
        test('SignInAndLevelGiftUI.on_click_btn  传入参数为空')
        return
    end
    local type = SignInAndLevelGiftUI._btn_data.type
    local item_id = SignInAndLevelGiftUI._btn_data.item_id

    local data  = UIDefine.prompt_sequence
    local method = data.ui[type].method
    local temp = string.split(method,':')
    if temp[1] == 'open_ui' then
        GUI.OpenWnd(temp[2],'index:'..temp[3]..',index2:'..temp[4])
    elseif temp[1] == 'use_item' then
        -- 如果只是侍从，随便拿个它的guid，反正只是跳转到侍从界面
        local cell = LD.GetItemGuidsById(item_id,item_container_type.item_container_guard_bag)
        GlobalUtils.UseItem(cell[0])
    else
        test('SignInAndLevelGiftUI.on_click_btn 数据错误')
    end

    SignInAndLevelGiftUI.OnExit()
end


-- 清空数据的函数
function SignInAndLevelGiftUI._clear_data()
    if UIDefine.prompt_sequence then
        UIDefine.prompt_sequence.current_show = nil
        UIDefine.prompt_sequence.current_show_type = nil
        for k, v in ipairs(UIDefine.prompt_sequence.ui) do
            v.stack = {}
        end
    end

    -- 注销监听
    CL.UnRegisterMessage(GM.PlayerExitGame, "SignInAndLevelGiftUI", '_clear_data')
    CL.UnRegisterMessage(GM.PlayerExitLogin, "SignInAndLevelGiftUI", '_clear_data')
end


-- 插入数据到对应栈中的方法
-- 参数： 物品id, table(stack结构)
-- 因为传过来的是个table-stack操作的地址相同，所以可以直接操作
function SignInAndLevelGiftUI._insert_id(id,stack)
    if not stack then return end

    -- 去重  不会好的去重算法，如果做成map会浪费内存和计算 还是用最简单的遍历吧
    for k,v in ipairs(stack) do
        if v == id then
            -- 删除这个重复的数据
            --stack[k] = nil
            table.remove(stack,k)
            break
        end
    end

    -- 因为每次插入进来都会进行去重判断，所以最多只有一个重复
    table.insert(stack, id)

end