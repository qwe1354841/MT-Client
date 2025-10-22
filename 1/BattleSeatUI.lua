BattleSeatUI = {}

local _gt = UILayout.NewGUIDUtilTable()
-------------------------------start缓存一下常用的全局变量start---------------------------
local GUI = GUI
local UIAnchor = UIAnchor
local UIAroundPivot = UIAroundPivot
local TextAnchor = TextAnchor
local SetAnchorAndPivot = UILayout.SetAnchorAndPivot
local SetSameAnchorAndPivot = UILayout.SetSameAnchorAndPivot
------------------------------------ end缓存一下全局变量end --------------------------------

-------------------------------start定义全局变量start---------------------------
-- 颜色
local colorDark = Color.New(102 / 255, 47 / 255, 22 / 255, 255 / 255)
local colorYellow = Color.New(172 / 255, 117 / 255, 39 / 255, 255 / 255)
local colorWhite = Color.New(255 / 255, 246 / 255, 232 / 255, 255 / 255)
local colorRed = Color.New(255 / 255, 0 / 255, 0 / 255, 255 / 255)
local colorGreen = Color.New(46 / 255, 218 / 255, 0 / 255, 255 / 255)
local colorOutline = Color.New(162 / 255, 75 / 255, 21 / 255)


--选中项的阵型信息
BattleSeatUI.SelectSeatInfo = nil

-- 数字图片
local _EffectLstNumPic = { "1800605060", "1800605070", "1800605080", "1800605090", "1800605100" }

-- 数字图片
local SeatOrderNum = { "1800605060", "1800605070", "1800605080", "1800605090", "1800605100" }

-- 三个阵容
local tabList = {
    { "阵容一", "battleArray1_Btn", "battleArrayOne_BtnClick", "battleArrayOne_Page" },
    { "阵容二", "battleArray2_Btn", "battleArrayTwo_BtnClick", "battleArrayTwo_Page" },
    { "阵容三", "battleArray3_Btn", "battleArrayThree_BtnClick", "battleArrayThree_Page" },
}

local _battle_array_list = {
    '阵容一',
    '阵容二',
    '阵容三',
}

-------------------------------end定义全局变量end---------------------------
-- main -> onshow -> Refresh_SelectedBattleArray_Page阵容页签 -> BattleSeatUI.GetServerData请求 -> BattleSeatUI.ShowSeatInfos() 刷新阵法列表
-- -> initData -> 刷新所有页面
local openWindow = true -- 是否是刚打开页面
-- 开始执行   创建最开始静态页面
function BattleSeatUI.Main()
    local _Panel = GUI.WndCreateWnd("BattleSeatUI", "BattleSeatUI", 0, 0, eCanvasGroup.Normal)
    local _PanelBG = UILayout.CreateFrame_WndStyle0(_Panel, "阵    法", "BattleSeatUI", "OnExit", _gt)

    UILayout.CreateRightTab(tabList, "BattleSeatUI")
    -- 调整页签图标和字体大小
    local tabListPage = GUI.GetChild(_PanelBG, "tabList")
    for i = 1, 3 do
        local battleArray_Btn_i = GUI.GetChild(tabListPage, "battleArray" .. i .. "_Btn")
        -- 调整图标大小
        --local bg = GUI.GetChild(battleArrayi_Btn,"bg")
        --GUI.SetHeight(bg,120)
        -- 调整字体大小
        local text = GUI.GetChild(battleArray_Btn_i, "text")
        GUI.SetHeight(text, 85)
        GUI.StaticSetFontSize(text, 23)
        GUI.StaticSetAlignment(text, TextAnchor.MiddleCenter)

        -- 添加绿点
        local GreenPointImage = GUI.ImageCreate(battleArray_Btn_i, "GreenPointImage_" .. i, "1800408520", 30, -37.5, false, 16, 16)
        SetAnchorAndPivot(GreenPointImage, UIAnchor.TopRight, UIAroundPivot.TopRight)
        GUI.SetVisible(GreenPointImage, false)
        _gt.BindName(GreenPointImage, "GreenPointImage_" .. i)

        -- 隐藏页签
        GUI.SetVisible(battleArray_Btn_i, false)
    end

    --左侧阵法列表
    local _SeatLstBack = GUI.ImageCreate(_PanelBG, "SeatLstBack", "1800400200", 65, 111, false, 293, 517)
    SetAnchorAndPivot(_SeatLstBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    local _SeatScroll = GUI.LoopScrollRectCreate(_SeatLstBack, "SeatScroll", 4, 7, 285, 502,
            "BattleSeatUI", "Create_SeatScroll", "BattleSeatUI", "Refresh_SeatScroll",
            0, false, Vector2.New(282, 100), 1, UIAroundPivot.Top, UIAnchor.Top)
    _gt.BindName(_SeatScroll, "SeatScroll")

    SetAnchorAndPivot(_SeatScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ScrollRectSetChildSpacing(_SeatScroll, Vector2.New(4, 0))
    GUI.ScrollRectSetNormalizedPosition(_SeatScroll, Vector2.New(0, 0))

    -- 左侧阵容选项
    local _battle_array_group = GUI.GroupCreate(_PanelBG, '_left_battle_array_group', 64, 49, 293, 62)
    SetSameAnchorAndPivot(_battle_array_group, UILayout.TopLeft)

    local _txt = GUI.CreateStatic(_battle_array_group, '_battle_array_txt', '阵容配置', 9, 8, 111, 45)
    UILayout.SetSameAnchorAndPivot(_txt, UILayout.TopLeft)
    UILayout.StaticSetFontSizeColorAlignment(_txt, UIDefine.FontSizeXL, UIDefine.BrownColor)

    local _bg = GUI.ImageCreate(_battle_array_group, "_battle_array_bg", "1800499999", -11, 11, false, 160, 40)
    UILayout.SetSameAnchorAndPivot(_bg, UILayout.TopRight)
    _gt.BindName(_bg, 'rightTitle_Bg')

    local _array_btn = GUI.ButtonCreate(_bg, '_array_btn', '1801102010', 0, 0, Transition.ColorTint, '', 160, 40, false)
    GUI.RegisterUIEvent(_array_btn, UCE.PointerClick, "BattleSeatUI", "_show_battle_array")


    -- 下拉列表箭头
    local pullListBtn = GUI.ImageCreate(_bg, "pullListBtn", "1800707070", 12, 0)
    UILayout.SetSameAnchorAndPivot(pullListBtn, UILayout.Right)
    GUI.SetIsRaycastTarget(pullListBtn, false)

    local battle_array_Txt = GUI.CreateStatic(_bg, "battle_array_Txt", "阵容一", -15, 0, 100, 40, "system", true)
    _gt.BindName(battle_array_Txt, "battle_array_Txt")
    UILayout.SetSameAnchorAndPivot(battle_array_Txt, UILayout.Left)
    UILayout.StaticSetFontSizeColorAlignment(battle_array_Txt, UIDefine.FontSizeXL, UIDefine.BrownColor, TextAnchor.MiddleCenter)



    --显示阵法列表
    --BattleSeatUI.ShowSeatInfos()

    --中间阵法布局
    local _SeatPanelBack = GUI.ImageCreate(_PanelBG, "SeatPanelBack", "1800400200", 362, 111, false, 437, 517)
    SetAnchorAndPivot(_SeatPanelBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(_SeatPanelBack, "SeatPanelBack")

    --底板
    local _BattleSeatInfoBack = GUI.ImageCreate(_SeatPanelBack, "BattleSeatInfoBack", "1800600100", 6, 8, false, 426, 103)
    SetAnchorAndPivot(_BattleSeatInfoBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --背景框
    local _BattleSeatInfoIconBack = GUI.ImageCreate(_SeatPanelBack, "BattleSeatInfoIconBack", "1800700050", 17, 20, false, 76, 76)
    SetAnchorAndPivot(_BattleSeatInfoIconBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --阵法图标
    local _BattleSeatInfoIcon = GUI.ImageCreate(_SeatPanelBack, "BattleSeatInfoIcon", "1800903190", 25, 28, false, 60, 60)
    SetAnchorAndPivot(_BattleSeatInfoIcon, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --阵法名称
    local _BattleSeatName = GUI.CreateStatic(_SeatPanelBack, "BattleSeatName", "1级鹰啸阵", 110, 32, 200, 35)
    SetAnchorAndPivot(_BattleSeatName, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_BattleSeatName, 24)
    GUI.SetColor(_BattleSeatName, colorDark)

    --经验条
    local _BattleSeatExp = GUI.ScrollBarCreate(_SeatPanelBack, "BattleSeatExp", "", "1800408160", "1800408110", 215, 77, 0, 0, 1, false, Transition.None, 0, 1, Direction.LeftToRight, false)
    local _BattleSeatExpValue = Vector2.New(214, 24)
    GUI.ScrollBarSetFillSize(_BattleSeatExp, _BattleSeatExpValue)
    GUI.ScrollBarSetBgSize(_BattleSeatExp, _BattleSeatExpValue)
    SetAnchorAndPivot(_BattleSeatExp, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    local _BattleSeatExpTxt = GUI.CreateStatic(_BattleSeatExp, "Value", "100/400", 0, 1, 210, 26)
    SetAnchorAndPivot(_BattleSeatExpTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_BattleSeatExpTxt, 20)
    GUI.SetColor(_BattleSeatExpTxt, colorWhite)
    GUI.StaticSetAlignment(_BattleSeatExpTxt, TextAnchor.MiddleCenter)


    --提示文字
    local _ChangeTip = GUI.CreateStatic(_SeatPanelBack, "ChangeTip", "点击右侧队员头像可交换位置", 7, 115, 290, 26)
    SetAnchorAndPivot(_ChangeTip, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_ChangeTip, 22)
    GUI.SetColor(_ChangeTip, colorDark)


    --未习得文字
    local _HaveNtLearnTip = GUI.CreateStatic(_SeatPanelBack, "HaveNtLearnTip", "未习得", 333, 65, 70, 26)
    SetAnchorAndPivot(_HaveNtLearnTip, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_HaveNtLearnTip, 22)
    GUI.SetColor(_HaveNtLearnTip, colorRed)


    --右侧详情区域
    local _SeatDetailBack = GUI.ImageCreate(_PanelBG, "SeatDetailBack", "1800400200", 802, 91, false, 325, 534)
    SetAnchorAndPivot(_SeatDetailBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(_SeatDetailBack, "SeatDetailBack")

    -- 按钮组 管理两个按钮，以进行之间的切换
    local _attr_Right_Group = GUI.GroupCreate(_SeatDetailBack, "attr_Right_Group", 0, 0, 325, 532)
    SetAnchorAndPivot(_attr_Right_Group, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(_attr_Right_Group, "attr_Right_Group")
    GUI.SetIsToggleGroup(_attr_Right_Group, true)

    --阵法效果按钮
    local _EffectPage = GUI.CheckBoxCreate(_attr_Right_Group, "EffectPage", "1800402030", "1800402031", 2, -39, Transition.ColorTint, true, 162, 44)
    SetAnchorAndPivot(_EffectPage, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetToggleGroupGuid(_EffectPage, GUI.GetGuid(_attr_Right_Group)) -- 添加到按钮组管理
    local _EffectPageTxt = GUI.CreateStatic(_EffectPage, "EffectPageTxt", "阵法效果", 0, 0, 90, 26)
    SetAnchorAndPivot(_EffectPageTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_EffectPageTxt, 22)
    GUI.SetColor(_EffectPageTxt, colorDark)
    GUI.RegisterUIEvent(_EffectPage, UCE.PointerClick, "BattleSeatUI", "OnEffectPage")

    --阵法克制按钮
    local _AgainstPage = GUI.CheckBoxCreate(_attr_Right_Group, "AgainstPage", "1800402030", "1800402031", 162, -39, Transition.ColorTint, false, 162, 44)
    SetAnchorAndPivot(_AgainstPage, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetToggleGroupGuid(_AgainstPage, GUI.GetGuid(_attr_Right_Group)) -- 添加到按钮组管理
    local _AgainstPageTxt = GUI.CreateStatic(_AgainstPage, "AgainstPageTxt", "阵法克制", 0, 0, 90, 26)
    SetAnchorAndPivot(_AgainstPageTxt, UIAnchor.Center, UIAroundPivot.Center)
    GUI.StaticSetFontSize(_AgainstPageTxt, 22)
    GUI.SetColor(_AgainstPageTxt, colorDark)
    GUI.RegisterUIEvent(_AgainstPage, UCE.PointerClick, "BattleSeatUI", "OnAgainstPage")

    --阵法效果节点
    --local _EffectNode = GUI.ImageCreate( _SeatDetailBack, "EffectNode", "", 0, 0, false, 0, 0)
    local _EffectNode = GUI.GroupCreate(_SeatDetailBack, "EffectNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_EffectNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_EffectNode, true)

    --阵法克制节点
    --local _AgainstNode = GUI.ImageCreate( _SeatDetailBack, "AgainstNode", "", 0, 0, false, 0, 0)
    local _AgainstNode = GUI.GroupCreate(_SeatDetailBack, "AgainstNode", 0, 0, 0, 0)
    SetAnchorAndPivot(_AgainstNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.SetVisible(_AgainstNode, false)

    --阵法等级选择
    --背景条
    local _LevelChooseBack = GUI.ImageCreate(_EffectNode, "LevelChooseBack", "1800600100", 7, 12, false, 303, 32)
    SetAnchorAndPivot(_LevelChooseBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    _gt.BindName(_LevelChooseBack, "LevelChooseBack")
    --左按钮
    local _SeatLevelLeftBtn = GUI.ButtonCreate(_LevelChooseBack, "SeatLevelLeftBtn", "1800602050", -1, 0, Transition.ColorTint, "")
    SetAnchorAndPivot(_SeatLevelLeftBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(_SeatLevelLeftBtn, UCE.PointerClick, "BattleSeatUI", "OnSeatLevelLeftBtn")
    --右按钮
    local _SeatLevelRightBtn = GUI.ButtonCreate(_LevelChooseBack, "SeatLevelRightBtn", "1800602060", 270, 0, Transition.ColorTint, "")
    SetAnchorAndPivot(_SeatLevelRightBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(_SeatLevelRightBtn, UCE.PointerClick, "BattleSeatUI", "OnSeatLevelRightBtn")

    --提升按钮
    local _BattleSeatUpdateBtn = GUI.ButtonCreate(_SeatPanelBack, "BattleSeatUpdateBtn", "1800402110", 333, 40, Transition.ColorTint, "提升", 82, 46, false)
    SetAnchorAndPivot(_BattleSeatUpdateBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.ButtonSetTextFontSize(_BattleSeatUpdateBtn, 24)
    GUI.ButtonSetTextColor(_BattleSeatUpdateBtn, colorDark)
    GUI.AddRedPoint(_BattleSeatUpdateBtn, UIAnchor.TopLeft)
    GUI.RegisterUIEvent(_BattleSeatUpdateBtn, UCE.PointerClick, "BattleSeatUI", "OnBattleSeatUpgradeBtn")

    --学习阵法/激活阵法/取消激活
    local _LearnBattleSeat = GUI.ButtonCreate(_SeatPanelBack, "LearnBattleSeat", "1800602030", 0, 250, Transition.ColorTint, "学习阵法")
    SetAnchorAndPivot(_LearnBattleSeat, UIAnchor.Center, UIAroundPivot.Bottom)
    GUI.ButtonSetTextFontSize(_LearnBattleSeat, 26)
    GUI.ButtonSetTextColor(_LearnBattleSeat, colorWhite)
    GUI.SetIsOutLine(_LearnBattleSeat, true)
    GUI.SetOutLine_Setting(_LearnBattleSeat, OutLineSetting.OutLine_Orange2_1)
    GUI.SetOutLine_Color(_LearnBattleSeat, colorOutline)
    GUI.SetOutLine_Distance(_LearnBattleSeat, 1)
    GUI.AddRedPoint(_LearnBattleSeat, UIAnchor.TopLeft)
    GUI.RegisterUIEvent(_LearnBattleSeat, UCE.PointerClick, "BattleSeatUI", "OnLearnBattleSeat")
    --激活阵法
    local _ActiveBattleSeat = GUI.ButtonCreate(_SeatPanelBack, "ActiveBattleSeat", "1800602030", 0, 250, Transition.ColorTint, "激活阵法")
    SetAnchorAndPivot(_ActiveBattleSeat, UIAnchor.Center, UIAroundPivot.Bottom)
    GUI.ButtonSetTextFontSize(_ActiveBattleSeat, 26)
    GUI.ButtonSetTextColor(_ActiveBattleSeat, colorWhite)
    GUI.SetIsOutLine(_ActiveBattleSeat, true)
    GUI.SetOutLine_Setting(_ActiveBattleSeat, OutLineSetting.OutLine_Orange2_1)
    GUI.SetOutLine_Color(_ActiveBattleSeat, colorOutline)
    GUI.SetOutLine_Distance(_ActiveBattleSeat, 1)
    GUI.RegisterUIEvent(_ActiveBattleSeat, UCE.PointerClick, "BattleSeatUI", "OnActiveBattleSeat")
    --取消阵法
    --local _DisActBattleSeat = GUI.ButtonCreate(_SeatPanelBack, "DisActBattleSeat", "1800602030",118,273, Transition.ColorTint, "取消阵法")
    --SetAnchorAndPivot(_DisActBattleSeat, UIAnchor.Left, UIAroundPivot.Bottom)
    --GUI.ButtonSetTextFontSize(_DisActBattleSeat, 26)
    --GUI.ButtonSetTextColor(_DisActBattleSeat, colorWhite)
    --GUI.SetIsOutLine(_DisActBattleSeat,true)
    --GUI.SetOutLine_Color(_DisActBattleSeat,colorOutline)
    --GUI.SetOutLine_Distance(_DisActBattleSeat,1)
    --GUI.RegisterUIEvent(_DisActBattleSeat , UCE.PointerClick , "BattleSeatUI", "OnDisActBattleSeat")
    --GUI.SetVisible(_DisActBattleSeat, false)

    -- 启用阵容
    --local _ActiveBattleArray = GUI.ButtonCreate(_SeatPanelBack, "ActiveBattleArray", "1800602030",-105,273, Transition.ColorTint, "启用阵容")
    --SetAnchorAndPivot(_ActiveBattleArray, UIAnchor.Right, UIAroundPivot.Bottom)
    --GUI.ButtonSetTextFontSize(_ActiveBattleArray, 26)
    --GUI.ButtonSetTextColor(_ActiveBattleArray, colorWhite)
    --GUI.SetIsOutLine(_ActiveBattleArray,true)
    --GUI.SetOutLine_Color(_ActiveBattleArray,colorOutline)
    --GUI.SetOutLine_Distance(_ActiveBattleArray,1)
    --GUI.RegisterUIEvent(_ActiveBattleArray, UCE.PointerClick , "BattleSeatUI", "OnActiveFormation")
    --GUI.SetVisible(_ActiveBattleArray, false)

    -- 启用阵容多选框
    local _ActiveBattleSeatCheckBox = GUI.CheckBoxCreate(_SeatPanelBack, "ActiveBattleSeatCheckBox", "1800607150", "1800607151", -179, -267, Transition.None, false, 40, 40)
    SetAnchorAndPivot(_ActiveBattleSeatCheckBox, UIAnchor.Center, UIAroundPivot.Bottom)
    GUI.RegisterUIEvent(_ActiveBattleSeatCheckBox, UCE.PointerClick, "BattleSeatUI", "OnActiveFormation")
    -- 创建文本
    local _checkBoxTxt = GUI.CreateStatic(_ActiveBattleSeatCheckBox, "_CheckBoxTxt", "设置为出战阵容", 100, -13, 165, 30)
    GUI.StaticSetAlignment(_checkBoxTxt, TextAnchor.MiddleCenter)
    GUI.StaticSetFontSize(_checkBoxTxt, 22)
    GUI.SetColor(_checkBoxTxt, colorDark)

    --旋转阵型按钮
    local _RotateModelBtn = GUI.ButtonCreate(_SeatPanelBack, "RotateModelBtn", "1800702110", 383, 118, Transition.ColorTint)
    SetAnchorAndPivot(_RotateModelBtn, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
    GUI.RegisterUIEvent(_RotateModelBtn, UCE.PointerClick, "BattleSeatUI", "OnRotateModelBtn")

end
local TeamSeatId = nil -- 组队时 队长使用的阵法ID
function BattleSeatUI.OnShow(index)

    if BattleSeatUI.pre_parameter then
        if BattleSeatUI.pre_parameter == index then
            BattleSeatUI.parameter_is_equality = true
        else
            BattleSeatUI.parameter_is_equality = false
            BattleSeatUI.pre_parameter = index
        end
    else
        BattleSeatUI.pre_parameter = index
        BattleSeatUI.parameter_is_equality = false
    end

    local wnd = GUI.GetWnd('BattleSeatUI')
    GUI.SetVisible(wnd, true)

    -- 关闭方式改成close后，下面的变量表示是否打开过界面，被destroy后这个变量才会销毁，不然再界面存活期间其值一直不变
    -- 解决重新打开界面后，阵法效果界面被阵法克制界面覆盖
    if BattleSeatUI.open_wnd ~= false then
        BattleSeatUI.CreateEffectInfos_Page()
        BattleSeatUI.CreateAgainstSeatLst()
        BattleSeatUI.open_wnd = false
    end

    openWindow = true
    local special = false
    local data = nil -- 切割传入的数据的 容器
    -- 设置阵容页签
    if index then
        data = string.split(index, "-")
        if #data > 0 then
            local battleArray_Index = tonumber(data[1]) -- 阵容下标
            if battleArray_Index then
                --如果转换数字失败，返回nil 则不执行下面代码
                BattleSeatUI.Refresh_SelectedBattleArray_Page(battleArray_Index)
                special = true
            end
        end
    end
    if not special then
        BattleSeatUI.Refresh_SelectedBattleArray_Page(1)
    end

    -- 将组队时队长使用的阵法ID 赋值给全局变量
    TeamSeatId = nil
    if data and data[2] ~= nil then
        TeamSeatId = tonumber(data[2])
    end

    BattleSeatUI.Register()
end

--退出界面
function BattleSeatUI.OnExit()
    GUI.CloseWnd('BattleSeatUI')
    --GUI.DestroyWnd("BattleSeatUI")
    BattleSeatUI._DestroyRoleEffectTable = {} -- 手动清空侍从气势特效销毁列表，防止关闭窗口后没有销毁此值
    BattleSeatUI.SelectedSeatId = nil
    BattleSeatUI.SelectedListNodeIndex = nil -- 选中的阵法节点下标，销毁，防止下一次打开还是这个节点

    BattleSeatUI.teamInfo = nil -- 组队队伍信息
    BattleSeatUI.teamNumber = nil  -- 组队人数


    openWindow = nil -- 将刚打开页面时状态销毁
    BattleSeatUI.UnRegister()

    -- 关闭界面时调整左边阵法列表的显示位置，滚动到合适位置，重新打开时显示正确
    if BattleSeatUI.select_node_percent then
        local _SeatScroll = _gt.GetUI("SeatScroll")
        GUI.ScrollRectSetNormalizedPosition(_SeatScroll, Vector2.New(0, BattleSeatUI.select_node_percent)) -- 滚动到到选中阵法的位置
    end


    -- 关闭阵法升级界面
    if ExpUpdateUI then
        ExpUpdateUI.OnExit()
    end

    -- 消除右边阵法效果页面替换位置的选中
    BattleSeatUI.SelectedFlagIndex = nil -- 阵法效果页 选中的节点 销毁
    for i = 2, 5 do
        -- 隐藏所有的切换标记
        local _ExchangeFlag = _gt.GetUI("ExchangeFlag" .. i) -- 切换标记
        GUI.SetVisible(_ExchangeFlag, false)
        -- 隐藏所有的选中框
        local _SelectFlag = _gt.GetUI('SelectFlag' .. i)
        GUI.SetVisible(_SelectFlag, false)
    end

end

-- 销毁界面调用
function BattleSeatUI.OnDestroy()
    BattleSeatUI.open_wnd = nil
end

-- 监听背包内物品变化，从而监听阵法书物品的变化
function BattleSeatUI.Register()
    CL.RegisterMessage(GM.RefreshBag, "BattleSeatUI", "itemsChangeUpdate");
    CL.RegisterMessage(GM.TeamInfoUpdate, "BattleSeatUI", "OnTeamInfoUpdate")
end
function BattleSeatUI.UnRegister()
    CL.UnRegisterMessage(GM.RefreshBag, "BattleSeatUI", "itemsChangeUpdate");
    CL.UnRegisterMessage(GM.TeamInfoUpdate, "BattleSeatUI", "OnTeamInfoUpdate")
end

------------------------左边列表界面开始--------------------------------------
-- 创建阵法列表静态页面
BattleSeatUI._SeatScroll_Count = 1 -- 当前SeatScroll总数
function BattleSeatUI.Create_SeatScroll()
    local _SeatScroll = _gt.GetUI("SeatScroll")
    --local count = GUI.LoopScrollRectGetTotalCount(_SeatScroll) -- 获取当前执行的次数
    --local isOne = BattleSeatUI._SeatScroll_Count == 1

    --底板
    local _SeatLstNode = GUI.CheckBoxExCreate(_SeatScroll, "_SeatScroll_" .. BattleSeatUI._SeatScroll_Count, "1800700030", "1800700040", 0, 0, false, 282, 100)
    SetAnchorAndPivot(_SeatLstNode, UIAnchor.TopRight, UIAroundPivot.TopRight)
    GUI.RegisterUIEvent(_SeatLstNode, UCE.PointerClick, "BattleSeatUI", "OnClickSeatLst")
    GUI.CheckBoxExSetIndex(_SeatLstNode, BattleSeatUI._SeatScroll_Count)



    --背景框
    local _FaceBack = GUI.ImageCreate(_SeatLstNode, "FaceBack", "1800700020", -11, 12)
    SetAnchorAndPivot(_FaceBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

    --图标
    local _Icon = GUI.ImageCreate(_FaceBack, "Icon", "1800903100", 0, 0, false, 76, 76)
    SetAnchorAndPivot(_Icon, UIAnchor.Center, UIAroundPivot.Center)
    GUI.AddRedPoint(_Icon, UIAnchor.TopLeft)

    --使用中标记
    local _UsingFlag = GUI.ImageCreate(_SeatLstNode, "UsingFlag", "1800707040", 0, 1) -- ”已装备“图片
    SetAnchorAndPivot(_UsingFlag, UIAnchor.TopRight, UIAroundPivot.TopRight)

    --锁
    local _Lock = GUI.ImageCreate(_FaceBack, "Lock", "1800408170", 0, 0)
    SetAnchorAndPivot(_Lock, UIAnchor.Center, UIAroundPivot.Center)
    GUI.SetVisible(_Lock, false)


    --名称
    local _Name = GUI.CreateStatic(_FaceBack, "Name", "普通阵", 12, 15, 200, 35)
    SetAnchorAndPivot(_Name, UIAnchor.TopRight, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Name, 24)
    GUI.SetColor(_Name, colorDark)

    --等级
    --local LevelInfos = tostring(BattleSeatUI.Infos[i-1].Level).."级"
    --if BattleSeatUI.Infos[i-1].Level == 0 then
    --    LevelInfos = "未习得"
    --end
    local _Level = GUI.CreateStatic(_FaceBack, "Level", "未习得", 12, 45, 200, 35)
    SetAnchorAndPivot(_Level, UIAnchor.TopRight, UIAroundPivot.TopLeft)
    GUI.StaticSetFontSize(_Level, 22)
    --if BattleSeatUI.Infos[i-1].Level == 0 then
    GUI.SetColor(_Level, colorRed)
    --else
    --GUI.SetColor(_Level, colorYellow)
    --end
    BattleSeatUI._SeatScroll_Count = BattleSeatUI._SeatScroll_Count + 1 -- SeatScroll总数自增
    return _SeatLstNode
end
-- 阵法列表节点击事件
BattleSeatUI.SelectedSeatId = nil -- 当前选中的阵法ID
BattleSeatUI.PreSelectedSeatId = nil -- 上一次选中的阵法ID
BattleSeatUI.SelectedListNodeIndex = nil -- 当前选中的阵法节点的index
function BattleSeatUI.OnClickSeatLst(guid)
    local _SeatLstNode = GUI.GetByGuid(guid) -- 阵法节点
    -- 激活阵法点击事件才改变这些
    local SeatId = tonumber(GUI.GetData(_SeatLstNode, "SelectedSeatId")) -- 选中阵法列表节点的阵容ID
    if BattleSeatUI.SelectedSeatId ~= SeatId then
        -- 如果记录的阵法ID 不等于 选中阵容列表节点的阵法ID
        BattleSeatUI.PreSelectedSeatId = BattleSeatUI.SelectedSeatId -- 设为上一个阵法的ID
        BattleSeatUI.SelectedSeatId = SeatId
    end

    local index = GUI.CheckBoxExGetIndex(_SeatLstNode)
    -- 如果选中的是本身，啥都不做，退出函数
    if BattleSeatUI.SelectedListNodeIndex and BattleSeatUI.SelectedListNodeIndex == index then
        GUI.CheckBoxExSetCheck(_SeatLstNode, true) -- 因为checkbox点击后会切换亮暗，亮点击后还得亮，所以设为true一下
        return
    end

    BattleSeatUI.SelectedListNodeIndex = index

    -- 重新刷新左边阵法列表
    BattleSeatUI.ShowSeatInfos()

    -- 联动中间页面
    --BattleSeatUI.ShowSeatDetail()
end
-- 获取数据函数
local AllBattleSeatID = {} -- 所有阵法数据
local SeatLevelConfig = {} -- 阵法的最大等级和最小等级
local LearnSeatInfoList = {} -- 已学习阵法
local CanLearnSeatList = {} -- 可学习阵法
local sort_Function = function(a, b)
    local info1 = LearnSeatInfoList[a]
    local info2 = LearnSeatInfoList[b]
    -- 已学习排序
    if not info1 and info2 then
        return false
    elseif info1 and not info2 then
        return true
    end

    -- 可学习排序
    local info3 = CanLearnSeatList[a]
    local info4 = CanLearnSeatList[b]
    if info3 and not info4 then
        return true
    elseif not info3 and info4 then
        return false
    end

    return a < b
end

function BattleSeatUI.InitData()
    AllBattleSeatID = {}
    local temp = {}
    local allSeatID = DB.GetSeatAllKey1s()
    for i = 0, allSeatID.Count - 1 do
        local idx = 1
        local seatId = allSeatID[i]
        while idx < 100 do
            -- 最大等级不可能超过100 ，防止死循环
            local b, config
            b, config = DB.TryGetSeat(seatId, idx, config)
            if not b or not config or config.Id == 0 then
                break
            end
            local lineupID = config.LineupId
            local lineupConfig = SeatLevelConfig[seatId]
            if not lineupConfig then
                lineupConfig = { maxLevel = config.Level, minLevel = config.Level }
                SeatLevelConfig[seatId] = lineupConfig
            else
                lineupConfig.maxLevel = lineupConfig.maxLevel < config.Level and config.Level or lineupConfig.maxLevel
                lineupConfig.minLevel = lineupConfig.minLevel > config.Level and config.Level or lineupConfig.minLevel
            end
            -- 判断这个阵法是否已激活，获取对应等级，根据等级得到配置数据
            if config.Type == 0 and not temp[lineupID] then
                -- 只有Type是0的阵法才显示
                AllBattleSeatID[#AllBattleSeatID + 1] = allSeatID[i]
                temp[lineupID] = true
            end
            idx = idx + 1
        end
    end

    -- 已学习阵法
    LearnSeatInfoList = {}
    if BattleSeatUI.SeatListData then
        -- 如果请求服务器来的数据存在
        for k, v in pairs(BattleSeatUI.SeatListData) do
            LearnSeatInfoList[v.Id] = v
        end
    end

    -- 可学习阵法
    CanLearnSeatList = {}
    if BattleSeatUI.CanLearnSeatList then
        for k, v in ipairs(BattleSeatUI.CanLearnSeatList) do
            CanLearnSeatList[v] = true
        end
    end

    table.sort(AllBattleSeatID, sort_Function)

end
-- 刷新阵法列表静态页面
function BattleSeatUI.Refresh_SeatScroll(parameter)

    parameter = string.split(parameter, "#")
    local guid = parameter[1]
    local index = tonumber(parameter[2]) + 1 -- 从零开始 所以加1

    local BattleSeat = nil -- 阵法对象
    if AllBattleSeatID[index] ~= nil then
        BattleSeat = DB.GetOnceSeatByKey1(AllBattleSeatID[index])
    end


    -- 服务器数据
    local formation_Icon = BattleSeat.Icon -- 阵法图片
    local formation_Level = 0 -- 阵法等级
    local CurSeatID = BattleSeat.Id -- 当前节点阵法的ID
    local formation_Name = BattleSeat.Name -- 阵法名称
    local IsCanLearnSeat = false -- 是否可学习阵法
    local SelectSeat_MaxExp_Length = 5 -- 选中阵法的最大等级
    local EquippedCurSeatID = BattleSeatUI.EquippedCurSeatID or 1 -- 当前装备阵法的ID
    -- 本文件数据

    local have_Material = false -- 是否有阵法升级物品
    if BattleSeatUI.is_have_item then
        have_Material = BattleSeatUI.is_have_item
    else
        have_Material = BattleSeatUI.seat_can_up()
    end

    local CommonSeatID = 1 -- 默认阵法ID


    if BattleSeatUI.SeatListData and BattleSeatUI.LineupUsingSeat and AllBattleSeatID[index] then
        -- 如果请求服务器来的数据存在
        for k, v in pairs(BattleSeatUI.SeatListData) do
            -- 判断是否学习了此节点阵法
            if AllBattleSeatID[index] == v.Id then
                formation_Level = v.Level -- 设置阵法等级
            end
        end
        --EquippedCurSeatID = BattleSeatUI.LineupUsingSeat -- 设置装备阵法ID
    end

    -- 判断是否可学习阵法
    if BattleSeatUI.CanLearnSeatList then
        for k, v in pairs(BattleSeatUI.CanLearnSeatList) do
            if CurSeatID == tonumber(v) then
                IsCanLearnSeat = true
                break
            end
        end
    end

    -- 如果ID==1 为普通阵法
    if AllBattleSeatID[index] and AllBattleSeatID[index] == 1 then
        formation_Level = 1
        SelectSeat_MaxExp_Length = 1
        IsCanLearnSeat = false -- 不可学习
        have_Material = false -- 不可升级
    end


    -- UI父节点
    local _SeatLstNode = GUI.GetByGuid(guid)  -- 获取当前单个节点，为节点的地板
    GUI.SetData(_SeatLstNode, "SelectedSeatId", CurSeatID)
    local index = GUI.CheckBoxExGetIndex(_SeatLstNode)
    GUI.CheckBoxExSetCheck(_SeatLstNode, BattleSeatUI.SelectedListNodeIndex == index)

    -- 背景框
    local _FaceBack = GUI.GetChild(_SeatLstNode, "FaceBack") -- 获取阵法图片背景框


    -- 图标
    local _Icon = GUI.GetChild(_FaceBack, "Icon")
    GUI.ImageSetImageID(_Icon, formation_Icon) -- 设置阵法图片

    -- 显示小红点
    if CurSeatID == CommonSeatID then
        -- 如果当前节点阵法ID 等于 默认阵法ID，默认阵法无法升级就没有小红点
        GUI.SetRedPointVisable(_Icon, false)
    else
        --如果有可升级道具且等级少于阵法最大等级则显示红点
        local CanUpLevel = (have_Material and formation_Level >= 1 and formation_Level < SelectSeat_MaxExp_Length)
        GUI.SetRedPointVisable(_Icon, IsCanLearnSeat or CanUpLevel)
    end

    --使用中标记 -- 显示已装备图片
    local _UsingFlag = GUI.GetChild(_SeatLstNode, "UsingFlag")
    local isUsed = formation_Level > 0 and EquippedCurSeatID == CurSeatID
    GUI.SetVisible(_UsingFlag, isUsed)

    --锁
    local _Lock = GUI.GetChild(_FaceBack, "Lock")
    GUI.SetVisible(_Lock, formation_Level == 0)

    --名称
    local _Name = GUI.GetChild(_FaceBack, "Name")
    GUI.StaticSetText(_Name, formation_Name)

    --等级
    local _Level = GUI.GetChild(_FaceBack, "Level")

    local LevelInfos = tostring(formation_Level) .. "级"

    if formation_Level == 0 then
        -- 等级为0
        if IsCanLearnSeat then
            -- 是否可学习阵法
            LevelInfos = "可学习"
            GUI.SetColor(_Level, colorGreen)
        else
            LevelInfos = "未习得"
            GUI.SetColor(_Level, colorRed)
        end
    elseif formation_Level > 0 then
        -- 如果技能等级大于0
        GUI.SetColor(_Level, colorYellow)
    end

    GUI.StaticSetText(_Level, LevelInfos) -- 设置阵法等级

end
-- 刷新阵法信息
function BattleSeatUI.ShowSeatInfos()
    -- 初始化阵法信息数据
    if BattleSeatUI.SeatListData ~= nil then
        BattleSeatUI.InitData()
    end

    if BattleSeatUI.LineupUsingSeat then
        -- 初始化当前选中的阵法ID
        if BattleSeatUI.SelectedSeatId == nil then
            if TeamSeatId ~= nil then
                BattleSeatUI.SelectedSeatId = TeamSeatId   -- 如果是在队伍中，选中队长使用的阵法
            else
                BattleSeatUI.SelectedSeatId = BattleSeatUI.LineupUsingSeat
            end
        end
        -- 初始化当前选中的阵法节点下标
        if BattleSeatUI.SelectedListNodeIndex == nil then
            for k, v in pairs(AllBattleSeatID) do
                if v == BattleSeatUI.SelectedSeatId then
                    BattleSeatUI.SelectedListNodeIndex = k - 1
                end
            end
        end
        -- 初始化当前装备的阵法ID
        if BattleSeatUI.EquippedCurSeatID == nil then
            BattleSeatUI.EquippedCurSeatID = BattleSeatUI.LineupUsingSeat
        end
    end

    local _SeatScroll = _gt.GetUI("SeatScroll")
    local AllBattleSeatID_Count = #AllBattleSeatID
    GUI.LoopScrollRectSetTotalCount(_SeatScroll, AllBattleSeatID_Count) -- 执行创建多少次ScrollRect
    GUI.LoopScrollRectRefreshCells(_SeatScroll) -- 刷新ScrollRect


    if openWindow then
        -- 只有在打开页面时才滚动
        if BattleSeatUI.parameter_is_equality == false then
            GUI.ScrollRectSetNormalizedPosition(_SeatScroll, Vector2.New(0, BattleSeatUI.SelectedListNodeIndex / AllBattleSeatID_Count)) -- 滚动到到选中阵法的位置
            BattleSeatUI.select_node_percent = BattleSeatUI.SelectedListNodeIndex / AllBattleSeatID_Count
            openWindow = false
        end
    end

    BattleSeatUI.ShowSeatDetail() -- 刷新中上，因为需要确保收到服务器数据，所以在此执行

    -- 初始化阵法效果等级
    if LearnSeatInfoList[BattleSeatUI.SelectedSeatId] ~= nil then
        BattleSeatUI.Show_Formation_Level = LearnSeatInfoList[BattleSeatUI.SelectedSeatId].Level
    else
        BattleSeatUI.Show_Formation_Level = 1
    end
    --BattleSeatUI.Show_Formation_Level = LearnSeatInfoList[BattleSeatUI.SelectedSeatId].Level or 1
    -- 将两按钮变可使用 防止点击普通阵后两按钮全部变黑
    local LevelChooseBack = _gt.GetUI("LevelChooseBack") -- 父类
    local SeatLevelLeftBtn = GUI.GetChild(LevelChooseBack, "SeatLevelLeftBtn") -- 左按钮
    local SeatLevelRightBtn = GUI.GetChild(LevelChooseBack, "SeatLevelRightBtn") -- 右按钮
    if BattleSeatUI.SelectedSeatId == 1 then
        GUI.ButtonSetShowDisable(SeatLevelLeftBtn, false)
        GUI.ButtonSetShowDisable(SeatLevelRightBtn, false)
    else
        GUI.ButtonSetShowDisable(SeatLevelLeftBtn, false)
        GUI.ButtonSetShowDisable(SeatLevelRightBtn, true)
    end
    BattleSeatUI.GetEffectInfos_Page_Data() -- 同上,刷新阵法效果页面

    --BattleSeatUI.RefreshSeatPosition() -- 刷新侍从站位展示

    BattleSeatUI.ShowAgainstSeatLst() -- 刷新阵法克制页面

    -- 显示当前使用阵容的绿点
    --if BattleSeatUI.CurArrayID ~= nil then
    --    local GreenPointImage = _gt.GetUI("GreenPointImage_"..BattleSeatUI.CurArrayID)
    --    if GreenPointImage then
    --        GUI.SetVisible(GreenPointImage,true)
    --    end
    --end

    -- 如果选中的是当前装备的阵容，加粗字体
    --if BattleSeatUI.CurArrayID and BattleSeatUI.TabIndex then
    --    if BattleSeatUI.CurArrayID == BattleSeatUI.TabIndex then
    --        local txt = _gt.GetUI( "battle_array_Txt" )
    --        local array_name = _battle_array_list[BattleSeatUI.TabIndex]
    --        GUI.StaticSetText(txt,"<b>"..array_name.."</b>")
    --    end
    --end

end
-- 向服务器请求数据
function BattleSeatUI.GetServerData()
    if BattleSeatUI.TabIndex then
        CL.SendNotify(NOTIFY.SubmitForm, "FormSeat", "GetSeatData", BattleSeatUI.TabIndex)
        -- LineupUsingSeat 当前使用的阵法ID 、 SeatListData 包括已学习的ID、等级、经验 、CanLearnSeatList 可学习的阵法列表
    end
    -- 是否有升级物品
    BattleSeatUI.is_have_item = BattleSeatUI.seat_can_up()
end

-- 物品变化更新事件
BattleSeatUI.itemsChangeUpdate = function()
    -- 将选中阵法下标变为空，让其重新计算
    BattleSeatUI.SelectedListNodeIndex = nil
    -- 借用下这个变量，让其loopScrollRect可以滚动到选中的位置
    openWindow = true
    BattleSeatUI.GetServerData()
end


-- 显示阵容选项
function BattleSeatUI._show_battle_array(guid)

    local bg = _gt.GetUI("battle_array_Bg")
    if bg ~= nil then
        GUI.Destroy(bg)
        bg = nil
    end

    if bg == nil then

        local _bg = _gt.GetUI("rightTitle_Bg")
        --创建阵容类型按钮选择列表
        bg = GUI.ImageCreate(_bg, "battle_array_Bg", "1800400290", 0, 39, false, 160, 145)
        _gt.BindName(bg, "battle_array_Bg")
        UILayout.SetSameAnchorAndPivot(bg, UILayout.Top)
        GUI.SetIsRemoveWhenClick(bg, true) -- 是否检测到点击就销毁

        local childSize_GuardType = Vector2.New(150, 45)
        local scr_GuardType = GUI.ScrollRectCreate(bg, "battle_array", 0, 5, 160, 145, 0, false, childSize_GuardType, UIAroundPivot.Top, UIAnchor.Top)
        UILayout.SetSameAnchorAndPivot(scr_GuardType, UILayout.Center)

        for k, v in ipairs(_battle_array_list) do
            local btn = GUI.ButtonCreate(scr_GuardType, "addAttrKind_" .. k, "1800600100",
                    0, 0, Transition.ColorTint,
                    '', 150, 40, false);
            SetAnchorAndPivot(btn, UIAnchor.Top, UIAroundPivot.Top)

            local txt = GUI.CreateStatic(btn, 'btn_txt' .. k, v, -5, 0, 100, 45)
            GUI.StaticSetFontSize(txt, UIDefine.FontSizeL)
            GUI.SetColor(txt, UIDefine.BrownColor)
            GUI.StaticSetAlignment(txt, TextAnchor.MiddleLeft)
            --GUI.ButtonSetTextFontSize(btn,UIDefine.FontSizeL)

            -- 如果是当前使用的阵容，变粗字体
            --if BattleSeatUI.CurArrayID and k == BattleSeatUI.CurArrayID then
            --    local txt = GUI.ButtonGetText(btn)
            --    GUI.ButtonSetText(btn,"<b>"..txt.."</b>")
            --else
            --    local txt = GUI.ButtonGetText(btn)
            --    GUI.ButtonSetText(btn, txt)
            --end
            --GUI.ButtonSetTextColor(btn, UIDefine.BrownColor)
            GUI.RegisterUIEvent(btn, UCE.PointerClick, "BattleSeatUI", "_array_on_click")

            if BattleSeatUI.CurArrayID and k == BattleSeatUI.CurArrayID then
                -- 当前选中阵容v图标的显示
                local v_img = GUI.ImageCreate(btn, 'cur_array_img', '1800307030', -5, 0, false, 30, 23)
                UILayout.SetSameAnchorAndPivot(v_img, UILayout.Right)
            end

            -- 传输给点击阵容选项方法的数据
            if not BattleSeatUI._array_by_guid then
                BattleSeatUI._array_by_guid = {}
            end
            local guid = GUI.GetGuid(btn)
            BattleSeatUI._array_by_guid[guid] = k
        end

    end

end

-- 点击阵容选项
function BattleSeatUI._array_on_click(guid)
    if not BattleSeatUI._array_by_guid then
        return
    end
    local index = BattleSeatUI._array_by_guid[guid]
    local array_name = _battle_array_list[index]
    local txt = _gt.GetUI("battle_array_Txt")
    --if BattleSeatUI.CurArrayID and index == BattleSeatUI.CurArrayID then
    --    GUI.StaticSetText(txt,"<b>"..array_name.."</b>")
    --else
    --end
    GUI.StaticSetText(txt, array_name)

    BattleSeatUI.TabIndex = index
    CL.SendNotify(NOTIFY.SubmitForm, "FormSeat", "GetLineUpSeat", tostring(index))
    -- BattleSeatUI.EquippedCurSeatID = 当前装备阵法的ID
    -- BattleSeatUI.CurArrayID = 当前使用的阵容ID
    -- 执行 BattleSeatUI.GetServerData() 和 Switch_ActiveArrayBtn 方法
    -- BattleSeatUI.Switch_ActiveArrayBtn(page_Id) -- 设置启用阵容按钮是否可用  为确保BattleSeatUI.CurArrayID数据存在，放到服务器执行

end
------------------------左边列表界面结束--------------------------------------

------------------------中间阵容开始-----------------------------------------
-- 判断物品是否可以提升
function BattleSeatUI.seat_can_up()
    return UIDefine.is_have_seat_material()
end

-- 中间上面阵法经验提升部分 刷新方法
function BattleSeatUI.ShowSeatDetail()

    -- 当前选中的阵法对象
    local BattleSeat = nil
    if BattleSeatUI.SelectedSeatId then
        BattleSeat = DB.GetOnceSeatByKey1(BattleSeatUI.SelectedSeatId)
    else
        BattleSeat = DB.GetOnceSeatByKey1(1) -- 如果不存在设为普通阵法
    end
    local SelectSeat_Icon = BattleSeat.Icon -- 选中阵法的图片
    local SelectSeat_Name = BattleSeat.Name -- 选中阵法的名字
    local SelectSeat_Level = 0 -- 选中阵法的等级
    local SelectSeat_MaxExp_Length = 5 -- 选中阵法的最大等级
    local SelectSeat_MaxExp = BattleSeat.UpExp -- 选中阵法此等级升级所需经验
    local SelectSeat_Exp = 0 -- 选中阵法当前经验
    local SelectSeat_MaxExp_1 = 1000 -- 选中阵法此等级升级第一级所需经验
    local CommonSeatID = 1 -- 默认阵法ID
    local SelectSeat_ID = BattleSeat.Id -- 选中阵法ID
    local haveUpItem = false -- 是否拥有阵法升级道具

    -- 如果请求到服务器数据，使用服务器的数据
    if BattleSeatUI.LineupUsingSeat and BattleSeatUI.SeatListData then
        for k, v in pairs(BattleSeatUI.SeatListData) do
            if BattleSeatUI.SelectedSeatId and BattleSeatUI.SelectedSeatId == v.Id then
                SelectSeat_Level = v.Level
                SelectSeat_Exp = v.Score
                SelectSeat_MaxExp_Length = SeatLevelConfig[v.Id].maxLevel

                SelectSeat_MaxExp = DB.GetSeat(v.Id, v.Level).UpExp -- 根据id和等级获取到阵法对象

                SelectSeat_MaxExp_1 = DB.GetSeat(v.Id, 1).UpExp -- 一级升级所需经验
            end
        end
    end

    if BattleSeatUI.SelectedSeatId == 1 then
        -- 如果是普通阵法
        SelectSeat_Level = 1
        SelectSeat_MaxExp_Length = 1
    end

    -- 判断是否可提升 用于显示小红点
    if BattleSeatUI.is_have_item then
        haveUpItem = BattleSeatUI.is_have_item
    else
        haveUpItem = BattleSeatUI.seat_can_up()
    end

    local SeatPanelBack = _gt.GetUI("SeatPanelBack") -- 父类

    --阵法图标
    local _BattleSeatInfoIcon = GUI.GetChild(SeatPanelBack, "BattleSeatInfoIcon")
    GUI.ImageSetImageID(_BattleSeatInfoIcon, SelectSeat_Icon)


    --名称
    local _BattleSeatName = GUI.GetChild(SeatPanelBack, "BattleSeatName")
    local Name = SelectSeat_Name
    if SelectSeat_Level > 0 then
        Name = SelectSeat_Level .. "级" .. Name
    end
    GUI.StaticSetText(_BattleSeatName, Name)


    --经验
    local MaxExpValue = 1
    local ExpValue = 1
    if SelectSeat_Level > 0 then
        if SelectSeat_Level < SelectSeat_MaxExp_Length then
            MaxExpValue = SelectSeat_MaxExp
            ExpValue = SelectSeat_Exp
            -- 发送请求需修改
            --CL.SendNotify(NOTIFY.BattleSeatUpgrade, 7, BattleSeatUI.SelectSeatInfo.IDs[BattleSeatUI.SelectSeatInfo.Level-1])
        end
    else
        -- 当阵法等级为为0时
        ExpValue = 0
        MaxExpValue = SelectSeat_MaxExp_1
        -- 发送请求需修改
        --CL.SendNotify(NOTIFY.BattleSeatUpgrade, 7, BattleSeatUI.SelectSeatInfo.IDs[0])
    end
    local _BattleSeatExp = GUI.GetChild(SeatPanelBack, "BattleSeatExp")
    GUI.ScrollBarSetPos(_BattleSeatExp, ExpValue / MaxExpValue)


    --经验Txt
    local _BattleSeatExpValue = GUI.GetChild(_BattleSeatExp, "Value")
    if SelectSeat_Level < SelectSeat_MaxExp_Length then
        GUI.StaticSetText(_BattleSeatExpValue, ExpValue .. "/" .. MaxExpValue)
    else
        GUI.StaticSetText(_BattleSeatExpValue, "Max")
    end

    -- 未习得文字
    local HaveNtLearnTip = GUI.GetChild(SeatPanelBack, "HaveNtLearnTip")
    -- 提升按钮
    local BattleSeatUpdateBtn = GUI.GetChild(SeatPanelBack, "BattleSeatUpdateBtn")

    GUI.SetVisible(BattleSeatUpdateBtn, SelectSeat_Level ~= 0)
    GUI.SetVisible(HaveNtLearnTip, SelectSeat_Level == 0)

    if SelectSeat_ID == CommonSeatID then
        -- 如果选中阵法ID 为 默认普通阵  则无法提升
        GUI.SetRedPointVisable(BattleSeatUpdateBtn, false)
    else
        --如果有可升级道具且等级少于阵法最大等级则显示红点
        local CanUpLevel = (haveUpItem and SelectSeat_Level >= 1 and SelectSeat_Level < SelectSeat_MaxExp_Length)
        GUI.SetRedPointVisable(BattleSeatUpdateBtn, CanUpLevel)
    end

    --切换按钮状态
    BattleSeatUI.SwitchBtnState()
end

-- 切换 学习阵法/激活阵法
function BattleSeatUI.SwitchBtnState()

    local CurSeatID = BattleSeatUI.EquippedCurSeatID or 1 -- 已装备阵法ID
    local SelectSeat_ID = BattleSeatUI.SelectedSeatId or 1 -- 此节点阵法ID

    local SelectSeat_Level = 0 -- 选中阵法等级
    local IsCanLearn = false -- 判断是否可激活此阵法

    if BattleSeatUI.SeatListData and BattleSeatUI.CanLearnSeatList then
        -- 设置阵法等级
        for k, v in pairs(BattleSeatUI.SeatListData) do
            if v.Id == SelectSeat_ID then
                SelectSeat_Level = v.Level
            end
        end
        -- 设置阵法是否可学习
        for k, v in pairs(BattleSeatUI.CanLearnSeatList) do
            if tonumber(v) == SelectSeat_ID then
                IsCanLearn = true
            end
        end
    end

    local SeatPanelBack = _gt.GetUI("SeatPanelBack") -- 父类

    --学习阵法/激活阵法
    local _LearnBattleSeat = GUI.GetChild(SeatPanelBack, "LearnBattleSeat")
    local _ActiveBattleSeat = GUI.GetChild(SeatPanelBack, "ActiveBattleSeat")

    GUI.SetVisible(_LearnBattleSeat, SelectSeat_Level == 0)

    GUI.SetRedPointVisable(_LearnBattleSeat, IsCanLearn)

    -- 激活阵法按钮是否可用
    if SelectSeat_Level > 0 then
        GUI.SetVisible(_ActiveBattleSeat, true)
        GUI.ButtonSetShowDisable(_ActiveBattleSeat, SelectSeat_ID ~= CurSeatID)
    else
        GUI.SetVisible(_ActiveBattleSeat, false)
    end

end
-- 激活阵法点击事件
BattleSeatUI.EquippedCurSeatID = nil -- 当前装备阵法的ID
function BattleSeatUI.OnActiveBattleSeat()

    -- 如果自己是队员 无法操控  0无队伍，1暂离，2队长，3队员
    if LD.GetRoleInTeamState() == 3 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "队员状态无法变更阵型")
        return
    end

    -- 如果已经在战斗中
    --if CL.GetFightState() then
    --    CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法激活阵法")
    --    return
    --end

    -- 如果获取到了当前选中的阵法ID
    if BattleSeatUI.SelectedSeatId and BattleSeatUI.TabIndex then
        -- 将当前装备的阵法ID 赋值为当前选中的阵法ID
        BattleSeatUI.EquippedCurSeatID = BattleSeatUI.SelectedSeatId
        -- 发送请求到服务器
        CL.SendNotify(NOTIFY.SubmitForm, "FormSeat", "SetLineUpSeat", tostring(BattleSeatUI.TabIndex), tostring(BattleSeatUI.SelectedSeatId))
        -- 刷新左边列表
        BattleSeatUI.ShowSeatInfos()
    end


    -- 点击后按钮变灰
    --local btn = GUI.GetByGuid(guid)
    --GUI.ButtonSetShowDisable(btn,true)

end
-- 学习阵法点击事件
function BattleSeatUI.OnLearnBattleSeat()
    local BattleSeat = nil -- 阵法对象
    local IsCanLearn = false -- 是否可学习阵法
    -- 判断是否可用学习
    if BattleSeatUI.CanLearnSeatList and BattleSeatUI.SelectedSeatId then
        BattleSeat = DB.GetOnceSeatByKey1(BattleSeatUI.SelectedSeatId) -- 赋值阵法对象
        -- 设置阵法是否可学习
        for k, v in pairs(BattleSeatUI.CanLearnSeatList) do
            if tonumber(v) == BattleSeatUI.SelectedSeatId then
                IsCanLearn = true
            end
        end
    else
        test("学习阵法点击事件  数据为空 学习失败")
        return
    end

    if IsCanLearn then
        -- 如果可以学习
        BattleSeatUI.SelectedListNodeIndex = nil   -- 将选中节点设为空，使学习后 选中已学习的阵法节点
        CL.SendNotify(NOTIFY.SubmitForm, "FormSeat", "LearnSeat", tostring(BattleSeat.Id))
    else
        -- 如果不可以学习
        local SeatDetailBack = _gt.GetUI("SeatDetailBack")
        local tip = Tips.CreateByItemId(tonumber(BattleSeat.UpItem), SeatDetailBack, "BattleSeatTips", -450, 60)
        GUI.SetData(tip, "ItemId", tostring(BattleSeat.UpItem))
        GUI.SetHeight(tip, GUI.GetHeight(tip) + 40)
        _gt.BindName(tip, "BattleSeatTips")
        local wayBtn = GUI.ButtonCreate(tip, "wayBtn", 1800402110, 0, -10, Transition.ColorTint, "获取途径", 150, 50, false);
        UILayout.SetSameAnchorAndPivot(wayBtn, UILayout.Bottom)
        GUI.ButtonSetTextColor(wayBtn, UIDefine.BrownColor)
        GUI.ButtonSetTextFontSize(wayBtn, UIDefine.FontSizeL)
        GUI.RegisterUIEvent(wayBtn, UCE.PointerClick, "BattleSeatUI", "OnClickFormationWayBtn")
        GUI.AddWhiteName(tip, GUI.GetGuid(wayBtn))
    end
end
-- 获取途径点击事件
function BattleSeatUI.OnClickFormationWayBtn()
    local tip = _gt.GetUI("BattleSeatTips")
    if tip then
        Tips.ShowItemGetWay(tip)
    end
end
-- 提升按钮点击事件
function BattleSeatUI.OnBattleSeatUpgradeBtn()

    if BattleSeatUI.SelectedSeatId and BattleSeatUI.SeatListData then

        if BattleSeatUI.SelectedSeatId == 1 then
            -- 如果是普通阵法
            CL.SendNotify(NOTIFY.ShowBBMsg, "已是最大等级")
            return
        end

        local isLearned = false -- 是否学习到了选中的阵法
        for k, v in pairs(BattleSeatUI.SeatListData) do

            if BattleSeatUI.SelectedSeatId == v.Id then
                isLearned = true
                -- 判断是否是最大等级
                if SeatLevelConfig[v.Id].maxLevel == v.Level then
                    CL.SendNotify(NOTIFY.ShowBBMsg, "已是最大等级")
                    break
                else
                    -- 如果不是最大对等级
                    -- 打开升级阵法窗口
                    local _ExpUpdateUI = GUI.GetWnd("ExpUpdateUI");
                    if _ExpUpdateUI == nil then
                        local string = v.Id .. "-" .. v.Level .. "-" .. v.Score
                        GUI.OpenWnd("ExpUpdateUI", string);
                    else
                        GUI.SetVisible(_ExpUpdateUI, true);
                    end
                end

                --break
            end
        end
        -- 如果循环后没有学习此阵法
        if not isLearned then
            CL.SendNotify(NOTIFY.ShowBBMsg, "请先学习此阵法")
        end
    end
end
-- 启用阵容点击事件
function BattleSeatUI.OnActiveFormation()

    local SeatPanelBack = _gt.GetUI("SeatPanelBack")
    --local ActiveBattleArray = GUI.GetChild(SeatPanelBack,"ActiveBattleArray")
    local ActiveBattleSeatCheckBox = GUI.GetChild(SeatPanelBack, "ActiveBattleSeatCheckBox") -- 启用阵容多选框

    -- 如果已经在战斗中
    --if CL.GetFightState() then
    --    CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法切换阵容")
    --    GUI.CheckBoxSetCheck(ActiveBattleSeatCheckBox,false)
    --    return
    --end

    -- 如果自己是队员 无法操控  0无队伍，1暂离，2队长，3队员
    if LD.GetRoleInTeamState() == 3 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "队员状态无法变更阵容")
        GUI.CheckBoxSetCheck(ActiveBattleSeatCheckBox, false)
        return
    end

    if ActiveBattleSeatCheckBox ~= nil then
        -- 如果多选框存在，且打勾时点击
        if GUI.CheckBoxGetCheck(ActiveBattleSeatCheckBox) == false then
            CL.SendNotify(NOTIFY.ShowBBMsg, "已经设置为出战阵容")
            GUI.CheckBoxSetCheck(ActiveBattleSeatCheckBox, true)
            return
        end
    end

    -- 发送启用阵容请求
    if BattleSeatUI.TabIndex then

        -- 关闭当前使用的阵容页签上的小绿点
        if BattleSeatUI.CurArrayID then
            local GreenPointImage = _gt.GetUI("GreenPointImage_" .. BattleSeatUI.CurArrayID) -- 绿点
            if GreenPointImage then
                GUI.SetVisible(GreenPointImage, false)
            end
        end

        CL.SendNotify(NOTIFY.SubmitForm, "FormSeat", "SetUsingLineUp", tostring(BattleSeatUI.TabIndex))   -- FormSeat.GetLineUpSeat(player) 切换各个页签中的那个请求方法
    end
end
------------------------中间阵容结束-----------------------------------------

------------------------右边阵容页签开始--------------------------------------
BattleSeatUI.TabIndex = 1 -- 当前使用的页签
-- 切换各个页签的方法
function BattleSeatUI.Refresh_SelectedBattleArray_Page(page_Id)

    local array_name = _battle_array_list[page_Id]
    local txt = _gt.GetUI("battle_array_Txt")
    GUI.StaticSetText(txt, array_name)

    UILayout.OnTabClick(page_Id, tabList) -- 切换页签
    BattleSeatUI.TabIndex = page_Id
    CL.SendNotify(NOTIFY.SubmitForm, "FormSeat", "GetLineUpSeat", tostring(page_Id))
    -- BattleSeatUI.EquippedCurSeatID = 当前装备阵法的ID
    -- BattleSeatUI.CurArrayID = 当前使用的阵容ID
    -- 执行 BattleSeatUI.GetServerData() 和 Switch_ActiveArrayBtn 方法
    -- BattleSeatUI.Switch_ActiveArrayBtn(page_Id) -- 设置启用阵容按钮是否可用  为确保BattleSeatUI.CurArrayID数据存在，放到服务器执行
end
-- 阵容一页签点击事件
function BattleSeatUI.battleArrayOne_BtnClick()
    BattleSeatUI.Refresh_SelectedBattleArray_Page(1)
end
-- 阵容二页签点击事件
function BattleSeatUI.battleArrayTwo_BtnClick()
    BattleSeatUI.Refresh_SelectedBattleArray_Page(2)
end
-- 阵容三页签点击事件
function BattleSeatUI.battleArrayThree_BtnClick()
    BattleSeatUI.Refresh_SelectedBattleArray_Page(3)
end
-- 控制是否可用 启用阵容
BattleSeatUI.CurArrayID = nil -- 当前使用的阵容ID
function BattleSeatUI.Switch_ActiveArrayBtn(page_Id)
    if BattleSeatUI.CurArrayID == nil then
        return
    end
    local CurArrayID = BattleSeatUI.CurArrayID  -- 当前使用的阵容ID
    local SelectedArrayID = page_Id -- 此节点的阵容ID
    local SeatPanelBack = _gt.GetUI("SeatPanelBack") -- 父类
    --local ActiveBattleArray = GUI.GetChild(SeatPanelBack,"ActiveBattleArray") -- 启用阵容按钮
    --GUI.ButtonSetShowDisable(ActiveBattleArray,SelectedArrayID ~= CurArrayID) -- 是否可用


    -- 启用多选框
    local ActiveBattleSeatCheckBox = GUI.GetChild(SeatPanelBack, "ActiveBattleSeatCheckBox") -- 启用阵容多选框
    GUI.CheckBoxSetCheck(ActiveBattleSeatCheckBox, SelectedArrayID == CurArrayID)

end

------------------------右边阵容页签结束--------------------------------------

------------------------右边阵法效果和克制开始---------------------------------
-- 队伍信息
BattleSeatUI.teamInfo = LD.GetTeamInfo()
BattleSeatUI.teamNumber = 0 -- 队伍人数
if tostring(BattleSeatUI.teamInfo.team_guid) ~= "0" and BattleSeatUI.teamInfo.members ~= nil then
    BattleSeatUI.teamNumber = BattleSeatUI.teamInfo.members.Length
end

-- 创建阵法效果页面
function BattleSeatUI.CreateEffectInfos_Page()

    local SeatDetailBack = _gt.GetUI("SeatDetailBack") -- 父父类
    local _EffectNode = GUI.GetChild(SeatDetailBack, "EffectNode") -- 父类
    local _LevelChooseTxt = GUI.GetChild(_EffectNode, "LevelChooseTxt") -- 本页面的一个节点
    if _LevelChooseTxt == nil then
        --等级文字
        _LevelChooseTxt = GUI.CreateStatic(_EffectNode, "LevelChooseTxt", "1级阵法效果", 162, 29, 250, 26)
        SetAnchorAndPivot(_LevelChooseTxt, UIAnchor.Center, UIAroundPivot.Center)
        GUI.StaticSetFontSize(_LevelChooseTxt, 22)
        GUI.SetColor(_LevelChooseTxt, colorDark)
        GUI.StaticSetAlignment(_LevelChooseTxt, TextAnchor.MiddleCenter)

        --阵法效果列表
        for i = 1, 5 do
            --底板
            local _EffectLstNode = GUI.ImageCreate(_EffectNode, "EffectLstNode" .. i, "1800600100", 6, 51 + (i - 1) * 96, false, 313, 96)
            SetAnchorAndPivot(_EffectLstNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            _EffectLstNode:RegisterEvent(UCE.PointerClick)
            GUI.SetIsRaycastTarget(_EffectLstNode, true)
            GUI.RegisterUIEvent(_EffectLstNode, UCE.PointerClick, "BattleSeatUI", "OnClickLstBack") -- 事件待写
            GUI.SetData(_EffectLstNode, "EffectLstNode_index", i)

            --背景框
            local _FaceBack = GUI.ImageCreate(_EffectLstNode, "FaceBack" .. i, "1800400050", 48, 10)
            SetAnchorAndPivot(_FaceBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            _FaceBack:RegisterEvent(UCE.PointerClick)
            GUI.SetIsRaycastTarget(_FaceBack, true)
            --GUI.RegisterUIEvent(_FaceBack, UCE.PointerClick , "BattleSeatUI", "OnClickFaceBack")

            --Icon头像
            local _Face = GUI.ImageCreate(_FaceBack, "Face" .. i, "1800499999", 5, 4, false, 70, 70)
            SetAnchorAndPivot(_Face, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            _Face:RegisterEvent(UCE.PointerClick)
            GUI.SetIsRaycastTarget(_Face, true)
            GUI.RegisterUIEvent(_Face, UCE.PointerClick, "BattleSeatUI", "OnClickFace")
            GUI.SetData(_Face, "Face_index", i)

            --换位:选中框
            local _SelectFlag = GUI.ImageCreate(_FaceBack, "SelectFlag" .. i, "1800600160", -48, -10, false, 313, 96)
            SetAnchorAndPivot(_SelectFlag, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            _SelectFlag:RegisterEvent(UCE.PointerClick)
            GUI.SetIsRaycastTarget(_SelectFlag, true)
            GUI.RegisterUIEvent(_SelectFlag, UCE.PointerClick, "BattleSeatUI", "OnClickSelectFlag")
            GUI.SetVisible(_SelectFlag, false)
            GUI.SetData(_SelectFlag, "index", i)
            _gt.BindName(_SelectFlag, "SelectFlag" .. i)


            --换位:切换标记
            local _ExchangeFlag = GUI.ImageCreate(_FaceBack, "ExchangeFlag" .. i, "1800707340", 0, -2)
            SetAnchorAndPivot(_ExchangeFlag, UIAnchor.Center, UIAroundPivot.Center)
            _ExchangeFlag:RegisterEvent(UCE.PointerClick)
            GUI.SetIsRaycastTarget(_ExchangeFlag, true)
            GUI.RegisterUIEvent(_ExchangeFlag, UCE.PointerClick, "BattleSeatUI", "OnClickExchangeFlag")
            GUI.SetVisible(_ExchangeFlag, false)
            GUI.SetData(_ExchangeFlag, "ExchangeFlag_index", i)
            _gt.BindName(_ExchangeFlag, "ExchangeFlag" .. i)
            --点击区域
            local _ExchangeFlagClickArea = GUI.ImageCreate(_ExchangeFlag, "ExchangeFlagClickArea" .. i, "1800499999", -48, -8, false, 313, 96)
            SetAnchorAndPivot(_ExchangeFlagClickArea, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            _ExchangeFlagClickArea:RegisterEvent(UCE.PointerClick)
            GUI.SetIsRaycastTarget(_ExchangeFlagClickArea, true)
            GUI.RegisterUIEvent(_ExchangeFlagClickArea, UCE.PointerClick, "BattleSeatUI", "OnClickExchangeFlagClickArea") -- 事件待写
            GUI.SetData(_ExchangeFlagClickArea, "ExchangeFlagClickArea_index", i)

            --数字
            local _Num = GUI.ImageCreate(_EffectLstNode, "Num", _EffectLstNumPic[i], 19, 37)
            SetAnchorAndPivot(_Num, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

            --阵法效果类型1
            local _EffectName1 = GUI.CreateStatic(_FaceBack, "EffectName1", "受到伤害", 89, 12, 200, 35)
            SetAnchorAndPivot(_EffectName1, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(_EffectName1, 22)
            GUI.SetColor(_EffectName1, colorDark)

            --阵法效果类型2
            local _EffectName2 = GUI.CreateStatic(_FaceBack, "EffectName2", "速度", 89, 45, 200, 35)
            SetAnchorAndPivot(_EffectName2, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(_EffectName2, 22)
            GUI.SetColor(_EffectName2, colorDark)

            --阵法效果类型1值
            local _EffectValue1 = GUI.CreateStatic(_FaceBack, "EffectValue1", "+10%", 120, 12, 200, 35)
            SetAnchorAndPivot(_EffectValue1, UIAnchor.TopRight, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(_EffectValue1, 22)
            GUI.SetColor(_EffectValue1, colorDark)

            --阵法效果类型2值
            local _EffectValue2 = GUI.CreateStatic(_FaceBack, "EffectValue2", "-15%", 120, 45, 200, 35)
            SetAnchorAndPivot(_EffectValue2, UIAnchor.TopRight, UIAroundPivot.TopLeft)
            GUI.StaticSetFontSize(_EffectValue2, 22)
            GUI.SetColor(_EffectValue2, colorDark)
        end
    else
        GUI.SetVisible(_EffectNode, true) -- 显示本页面
    end
    --BattleSeatUI.GetEffectInfos_Page_Data()
end
-- 刷新阵法效果页面
function BattleSeatUI.ShowEffectInfos(is_refresh_position)
    -- 显示侍从站位
    if BattleSeatUI.SelectedSeatId ~= nil and BattleSeatUI.GuardListData ~= nil then
        if is_refresh_position ~= false then
            BattleSeatUI.RefreshSeatPosition()
        end
    end

    local SelectEffectIndex = 0 -- 选择阵法等级效果的下标
    local BattleSeat = nil -- 阵法对象
    local BattleSeat_Level = BattleSeatUI.Show_Formation_Level or 1 -- 阵法等级

    -- 获取阵法对象
    if BattleSeatUI.SelectedSeatId then
        BattleSeat = DB.GetSeat(BattleSeatUI.SelectedSeatId, BattleSeat_Level)
    end

    local SeatDetailBack = _gt.GetUI("SeatDetailBack") -- 父父类
    local _EffectNode = GUI.GetChild(SeatDetailBack, "EffectNode") -- 父类

    --等级
    local _LevelChooseTxt = GUI.GetChild(_EffectNode, "LevelChooseTxt")
    if _LevelChooseTxt ~= nil then
        GUI.StaticSetText(_LevelChooseTxt, (BattleSeat_Level) .. "级阵法效果")
    end

    for i = 1, 5 do

        -- 准备插入数据
        local FaceID = "1800903120" --  阵法图片
        local Att1Name = "造成伤害" -- 阵法效果类型1
        local Att1Value = "10%" -- 阵法效果值1
        local Att2Name = "速度" -- 阵法效果类型2
        local Att2Value = "5%" -- 阵法效果值2

        -- 设置侍从头像图片
        if BattleSeatUI.GuardListData then
            -- 如果请求服务器数据存在
            if BattleSeatUI.GuardListData[i] == "0" then
                -- 如果此位置未上阵侍从
                FaceID = "1800499999"
            else

                local roleId = nil -- 角色ID
                -- 如果没队伍时
                if i == 1 and BattleSeatUI.teamNumber == 0 then
                    roleId = CL.GetIntAttr(RoleAttr.RoleAttrRole)
                    if roleId ~= nil then
                        -- 当前角色头像
                        FaceID = tostring(DB.GetRole(roleId).Head)
                    end
                elseif i <= BattleSeatUI.teamNumber then
                    -- 如果有队伍 判断当前循环是否在队伍人数内
                    roleId = BattleSeatUI.teamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrRole) -- 角色Id
                    if roleId ~= nil then
                        -- 当前角色头像
                        FaceID = tostring(DB.GetRole(roleId).Head)
                    end
                else
                    -- 如果没在队伍人数内，则说明是侍从位
                    local guardId = LD.GetGuardIDByGUID(BattleSeatUI.GuardListData[i]) -- 侍从ID
                    if guardId ~= 0 then
                        -- 通过侍从GUID转换未ID 后获取侍从对象，后获取其头像图片
                        FaceID = tostring(DB.GetOnceGuardByKey1(guardId).Head)
                    else
                        -- 如果还是获取不到，既不是侍从，也不是角色
                        FaceID = "1800499999"
                    end
                end
            end
        end

        -- 设置阵法效果
        -- 是否显示百分比
        local attr1_isPct = nil
        local attr2_isPct = nil
        if BattleSeat then
            -- 阵法效果1
            if BattleSeat["Site" .. i .. "Att1"] ~= 1 then
                local attr = DB.GetOnceAttrByKey1(BattleSeat["Site" .. i .. "Att1"])
                Att1Name = attr.ChinaName
                attr1_isPct = attr.IsPct
            else
                Att1Name = "无效果"
            end

            if BattleSeat["Site" .. i .. "Value1"] ~= 0 then
                if 0 == attr1_isPct then
                    Att1Value = BattleSeat["Site" .. i .. "Value1"]
                else
                    Att1Value = BattleSeat["Site" .. i .. "Value1"] / 100
                end
            else
                Att1Value = nil
            end

            -- 阵法效果2
            if BattleSeat["Site" .. i .. "Att2"] ~= 1 then
                local attr = DB.GetOnceAttrByKey1(BattleSeat["Site" .. i .. "Att2"])
                Att2Name = attr.ChinaName
                attr2_isPct = attr.IsPct
            else
                Att2Name = ""
            end

            if BattleSeat["Site" .. i .. "Value2"] ~= 0 then
                if 0 == attr2_isPct then
                    Att2Value = BattleSeat["Site" .. i .. "Value2"]
                else
                    Att2Value = BattleSeat["Site" .. i .. "Value2"] / 100
                end
            else
                Att2Value = nil
            end

        end

        -- 颜色为colorGreen 或者 colorRed
        local Att1Color = colorGreen
        local Att2Color = colorRed

        -- 设置阵法图片
        local _Face = GUI.Get("BattleSeatUI/panelBg/SeatDetailBack/EffectNode/EffectLstNode" .. i .. "/FaceBack" .. i .. "/Face" .. i)
        if _Face ~= nil then
            --if FaceID == "" then -- 因为插入空数据时，不清空图片 使用空图片1800499999 清空
            --    GUI.SetVisible(_Face,false)
            --else
            --    GUI.SetVisible(_Face,true)
            --end
            if FaceID ~= nil and FaceID ~= "0" then
                GUI.ImageSetImageID(_Face, FaceID)
            else
                GUI.ImageSetImageID(_Face, "1800499999")
            end
        end
        -- 设置阵法效果类型1
        local _EffectName1 = GUI.Get("BattleSeatUI/panelBg/SeatDetailBack/EffectNode/EffectLstNode" .. i .. "/FaceBack" .. i .. "/EffectName1")
        if _EffectName1 ~= nil then
            GUI.StaticSetText(_EffectName1, Att1Name)
        end
        -- 设置阵法效果类型1值
        local _EffectValue1 = GUI.Get("BattleSeatUI/panelBg/SeatDetailBack/EffectNode/EffectLstNode" .. i .. "/FaceBack" .. i .. "/EffectValue1")
        if _EffectValue1 ~= nil then
            if Att1Value then

                local str = Att1Value
                -- 控制是否显示百分比
                if 0 == attr1_isPct then
                    str = Att1Value
                else
                    str = Att1Value .. '%'
                end

                if Att1Value > 0 then
                    GUI.StaticSetText(_EffectValue1, "+" .. str)
                    GUI.SetColor(_EffectValue1, Att1Color)
                else
                    GUI.StaticSetText(_EffectValue1, str)
                    GUI.SetColor(_EffectValue1, Att2Color)
                end

            else
                GUI.StaticSetText(_EffectValue1, "")
            end
        end
        -- 设置阵法效果类型2
        local _EffectName2 = GUI.Get("BattleSeatUI/panelBg/SeatDetailBack/EffectNode/EffectLstNode" .. i .. "/FaceBack" .. i .. "/EffectName2")
        if _EffectName2 ~= nil then
            GUI.StaticSetText(_EffectName2, Att2Name)
        end
        -- 设置阵法效果类型2值
        local _EffectValue2 = GUI.Get("BattleSeatUI/panelBg/SeatDetailBack/EffectNode/EffectLstNode" .. i .. "/FaceBack" .. i .. "/EffectValue2")
        if _EffectValue2 ~= nil then
            if Att2Value then

                local str = Att2Value
                if 0 == attr2_isPct then
                    str = Att2Value
                else
                    str = Att2Value .. '%'
                end

                if Att2Value > 0 then
                    GUI.StaticSetText(_EffectValue2, "+" .. str)
                    GUI.SetColor(_EffectValue2, Att1Color)
                else
                    GUI.StaticSetText(_EffectValue2, str)
                    GUI.SetColor(_EffectValue2, Att2Color)
                end

            else
                GUI.StaticSetText(_EffectValue2, "")
            end
        end
    end

end
-- 阵法左右等级按钮点击事件
BattleSeatUI.Show_Formation_Level = 1 -- 显示阵法效果页面的阵法等级
function BattleSeatUI.OnSeatLevelLeftBtn()

    local LevelChooseBack = _gt.GetUI("LevelChooseBack") -- 父类
    local SeatLevelLeftBtn = GUI.GetChild(LevelChooseBack, "SeatLevelLeftBtn") -- 左按钮
    local SeatLevelRightBtn = GUI.GetChild(LevelChooseBack, "SeatLevelRightBtn") -- 右按钮

    if BattleSeatUI.SelectedSeatId and BattleSeatUI.Show_Formation_Level then
        -- 如果不比此阵法最小阵法等级小
        if SeatLevelConfig[BattleSeatUI.SelectedSeatId].minLevel < BattleSeatUI.Show_Formation_Level then
            -- 显示减少一级的阵法
            GUI.ButtonSetShowDisable(SeatLevelLeftBtn, true)
            GUI.ButtonSetShowDisable(SeatLevelRightBtn, true)

            BattleSeatUI.Show_Formation_Level = BattleSeatUI.Show_Formation_Level - 1

            if BattleSeatUI.Show_Formation_Level == SeatLevelConfig[BattleSeatUI.SelectedSeatId].minLevel then
                GUI.ButtonSetShowDisable(SeatLevelLeftBtn, false)
            end

            BattleSeatUI.ShowEffectInfos(false)
        else
            GUI.ButtonSetShowDisable(SeatLevelLeftBtn, false)
        end

    end

end
function BattleSeatUI.OnSeatLevelRightBtn()

    local LevelChooseBack = _gt.GetUI("LevelChooseBack") -- 父类
    local SeatLevelRightBtn = GUI.GetChild(LevelChooseBack, "SeatLevelRightBtn") -- 右按钮
    local SeatLevelLeftBtn = GUI.GetChild(LevelChooseBack, "SeatLevelLeftBtn") -- 左按钮

    if BattleSeatUI.SelectedSeatId and BattleSeatUI.Show_Formation_Level then
        if SeatLevelConfig[BattleSeatUI.SelectedSeatId].maxLevel > BattleSeatUI.Show_Formation_Level then

            GUI.ButtonSetShowDisable(SeatLevelRightBtn, true)
            GUI.ButtonSetShowDisable(SeatLevelLeftBtn, true)

            BattleSeatUI.Show_Formation_Level = BattleSeatUI.Show_Formation_Level + 1
            -- 如果 此时阵法等级 等于 阵法等级极值
            if BattleSeatUI.Show_Formation_Level == SeatLevelConfig[BattleSeatUI.SelectedSeatId].maxLevel then
                GUI.ButtonSetShowDisable(SeatLevelRightBtn, false)
            end
            BattleSeatUI.ShowEffectInfos(false)
        else
            GUI.ButtonSetShowDisable(SeatLevelRightBtn, false)
        end
    end

end
-- 切换上阵侍从位置的事件
-- 阵法效果 底板 点击事件
BattleSeatUI.SelectedFlagIndex = nil -- 选中的交换侍从站位节点下标
function BattleSeatUI.OnClickLstBack(guid)

    -- 如果已经在战斗中
    --if CL.GetFightState() then
    --    CL.SendNotify(NOTIFY.ShowBBMsg,"战斗中无法交换上阵位置")
    --    return
    --end

    local EffectLstNode_index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "EffectLstNode_index")) -- 阵法效果，侍从节点下标
    -- 如果自己是队员 无法操控  0无队伍，1暂离，2队长，3队员
    if LD.GetRoleInTeamState() == 3 then
        CL.SendNotify(NOTIFY.ShowBBMsg, "只有队长或者非组队状态下才能设置位置")
        return
    end
    -- 如果是1号位 或此位置没侍从 则啥都不执行
    if EffectLstNode_index == nil or EffectLstNode_index == 1 or BattleSeatUI.GuardListData == nil or BattleSeatUI.GuardListData[EffectLstNode_index] == "0" then
        return
    end
    if BattleSeatUI.SelectedFlagIndex ~= nil then
        -- 如果已经选中了某个侍从图片节点 退出
        ---- 如果当选中的是角色，而交换的是侍从时，提示 玩家不能和侍从交换位置
        --if BattleSeatUI.teamNumber and BattleSeatUI.teamNumber ~= 0 and BattleSeatUI.SelectedFlagIndex <= BattleSeatUI.teamNumber then
        --    if EffectLstNode_index > BattleSeatUI.teamNumber then -- 交换的 是侍从
        --        CL.SendNotify(NOTIFY.ShowBBMsg,"玩家不能和侍从交换位置")
        --    end
        --end
        --
        ---- 选中侍从 交换角色
        --if BattleSeatUI.teamNumber and BattleSeatUI.teamNumber ~= 0 and BattleSeatUI.SelectedFlagIndex > BattleSeatUI.teamNumber then
        --    if EffectLstNode_index < BattleSeatUI.teamNumber then -- 交换的 是侍从
        --        CL.SendNotify(NOTIFY.ShowBBMsg,"侍从不能和玩家交换位置")
        --    end
        --end
        CL.SendNotify(NOTIFY.ShowBBMsg, "玩家不能和侍从交换位置")

        return
    end

    BattleSeatUI.SelectedFlagIndex = EffectLstNode_index
    -- 显示 选中框
    GUI.SetVisible(_gt.GetUI("SelectFlag" .. EffectLstNode_index), true)

    -- 显示其他切换标记

    local count = 5 -- 切换标记总数量
    -- 判断选中的是否是角色，如果是角色就显示其他角色的切换标记，角色只能与角色之间交换
    if EffectLstNode_index <= BattleSeatUI.teamNumber then
        count = BattleSeatUI.teamNumber
    end

    -- 遍历从2开始的侍从占位节点,因为1号位固定为玩家角色
    local startIndex = 2
    if BattleSeatUI.teamNumber ~= 0 and EffectLstNode_index > BattleSeatUI.teamNumber then
        -- 如果 组了队 有角色玩家时 并且选中的是侍从
        startIndex = BattleSeatUI.teamNumber + 1
    end

    for i = startIndex, count do
        local _ExchangeFlag = _gt.GetUI("ExchangeFlag" .. i) -- 切换标记
        if i ~= EffectLstNode_index and BattleSeatUI.GuardListData[i] ~= "0" then
            -- 排除当前节点 和没侍从的节点
            GUI.SetVisible(_ExchangeFlag, true) -- 显示切换标记
        else
            GUI.SetVisible(_ExchangeFlag, false)
        end
    end
end
-- 头像点击事件 转到底板点击事件
function BattleSeatUI.OnClickFace(guid)
    local Face_index = tonumber(GUI.GetData(GUI.GetByGuid(guid), "Face_index"))
    -- 获取底板
    local SeatDetailBack = _gt.GetUI("SeatDetailBack") -- 父父类
    local _EffectNode = GUI.GetChild(SeatDetailBack, "EffectNode") -- 父类
    local _EffectLstNode = GUI.GetChild(_EffectNode, "EffectLstNode" .. Face_index) -- 底板
    -- 执行底板点击事件
    BattleSeatUI.OnClickLstBack(GUI.GetGuid(_EffectLstNode))
end

-- 选中框点击事件,当点击一次底板后，显示选中框，不能触发底板事件了，所以需要添加选中框事件， 移除选中
function BattleSeatUI.OnClickSelectFlag(guid)
    local selectFlag = GUI.GetByGuid(guid)
    local isSelected = GUI.GetVisible(selectFlag)
    -- 隐藏选中框
    if isSelected == true then
        GUI.SetVisible(selectFlag, false)
        BattleSeatUI.SelectedFlagIndex = nil -- 选中的交换侍从站位节点下标 设为nil
        -- 隐藏所有的切换标记
        for i = 2, 5 do
            local _ExchangeFlag = _gt.GetUI("ExchangeFlag" .. i) -- 切换标记
            GUI.SetVisible(_ExchangeFlag, false)
        end
    end
end

-- 换位:切换标记 点击事件
function BattleSeatUI.OnClickExchangeFlag(guid)
    if BattleSeatUI.SelectedFlagIndex == nil or BattleSeatUI.TabIndex == nil or BattleSeatUI.GuardListData == nil then
        test("BattleSeatUI界面 换位:切换标记 点击事件 所需参数为空")
        return
    end

    -- 获取此节点对象
    local _ExchangeFlag = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(_ExchangeFlag, "ExchangeFlag_index"))

    -- 切换两节点的头像
    local SeatDetailBack = _gt.GetUI("SeatDetailBack") -- 父父类
    local _EffectNode = GUI.GetChild(SeatDetailBack, "EffectNode") -- 父类
    -- 被选中节点
    local _EffectLstNode_Selected = GUI.GetChild(_EffectNode, "EffectLstNode" .. BattleSeatUI.SelectedFlagIndex) -- 底板
    local _FaceBack_Selected = GUI.GetChild(_EffectLstNode_Selected, "FaceBack" .. BattleSeatUI.SelectedFlagIndex) -- 背景框
    local _Face_Selected = GUI.GetChild(_FaceBack_Selected, "Face" .. BattleSeatUI.SelectedFlagIndex) -- 头像

    -- 需要切换的节点
    local _EffectLstNode = GUI.GetChild(_EffectNode, "EffectLstNode" .. index) -- 底板
    local _FaceBack = GUI.GetChild(_EffectLstNode, "FaceBack" .. index) -- 背景框
    local _Face = GUI.GetChild(_FaceBack, "Face" .. index) -- 头像

    -- 交换 头像
    local temp = GUI.ImageGetImageID(_Face_Selected) -- 交换时中间变量，不确定^异或是否可用
    GUI.ImageSetImageID(_Face_Selected, GUI.ImageGetImageID(_Face))
    GUI.ImageSetImageID(_Face, temp)

    -- 将数据也交换
    -- 交换侍从
    local temp_Variable = nil
    if BattleSeatUI.GuardListData then
        temp_Variable = BattleSeatUI.GuardListData[index]
        BattleSeatUI.GuardListData[index] = BattleSeatUI.GuardListData[BattleSeatUI.SelectedFlagIndex]
        BattleSeatUI.GuardListData[BattleSeatUI.SelectedFlagIndex] = temp_Variable
    end


    -- 交换角色 注释掉，影响角色交互位置数据
    --if BattleSeatUI.teamInfo and BattleSeatUI.teamInfo.members then
    --    if (BattleSeatUI.teamNumber >= (index -1)) and (BattleSeatUI.teamNumber >= (BattleSeatUI.SelectedFlagIndex -1)) then
    --        temp_Variable = BattleSeatUI.teamInfo.members[index - 1]
    --        BattleSeatUI.teamInfo.members[index - 1] = BattleSeatUI.teamInfo.members[BattleSeatUI.SelectedFlagIndex -1]
    --        BattleSeatUI.teamInfo.members[BattleSeatUI.SelectedFlagIndex -1]  = temp_Variable
    --    end
    --end

    -- 刷新2D模型
    --BattleSeatUI.RefreshSeatPosition()

    -- 发送切换侍从站位的请求给服务器
    -- 参数：当前阵容下标 需要交换的两个侍从位置
    -- 更新 也能交互角色位置
    -- 添加回调方法：BattleSeatUI.lineupExchangeCallBack
    CL.SendNotify(NOTIFY.SubmitForm, "FormSeat", "LineupExchange", tostring(BattleSeatUI.TabIndex), tostring(BattleSeatUI.SelectedFlagIndex), tostring(index))

    -- 将选中的节点设为空
    --BattleSeatUI.SelectedFlagIndex = nil
    -- 将全部的选中框和切换标记隐藏
    --for i=2,5 do
    --    local _EffectLstNode = GUI.GetChild(_EffectNode,"EffectLstNode"..i) -- 底板
    --    local _SelectFlag = GUI.GetChild(_EffectLstNode,"SelectFlag"..i) -- 选中框
    --    GUI.SetVisible(_SelectFlag,false)
    --
    --    local _ExchangeFlag = GUI.GetChild(_EffectLstNode,"ExchangeFlag"..i) --切换标记
    --    GUI.SetVisible(_ExchangeFlag,false)
    --end
end
-- 交互位置请求的回调方法
BattleSeatUI.lineupExchangeCallBack = function()
    -- 刷新2D模型
    BattleSeatUI.RefreshSeatPosition()
    -- 将选中的节点设为空
    BattleSeatUI.SelectedFlagIndex = nil
    -- 将全部的选中框和切换标记隐藏
    local SeatDetailBack = _gt.GetUI("SeatDetailBack") -- 父父类
    local _EffectNode = GUI.GetChild(SeatDetailBack, "EffectNode") -- 父类
    for i = 2, 5 do
        local _EffectLstNode = GUI.GetChild(_EffectNode, "EffectLstNode" .. i) -- 底板
        local _SelectFlag = GUI.GetChild(_EffectLstNode, "SelectFlag" .. i) -- 选中框
        GUI.SetVisible(_SelectFlag, false)

        local _ExchangeFlag = GUI.GetChild(_EffectLstNode, "ExchangeFlag" .. i) --切换标记
        GUI.SetVisible(_ExchangeFlag, false)
    end
end
-- 点击区域 扩大范围 转到切换标记点击事件
function BattleSeatUI.OnClickExchangeFlagClickArea(guid)
    -- 获取节点对象
    local OnClickExchangeFlagClickArea = GUI.GetByGuid(guid)
    local index = tonumber(GUI.GetData(OnClickExchangeFlagClickArea, "ExchangeFlagClickArea_index"))

    local ExchangeFlag = _gt.GetUI("ExchangeFlag" .. index) -- 切换标记

    BattleSeatUI.OnClickExchangeFlag(GUI.GetGuid(ExchangeFlag)) -- 执行切换标记的点击事件
end

-- 创建阵法克制效果页面
function BattleSeatUI.CreateAgainstSeatLst()

    local SeatDetailBack = _gt.GetUI("SeatDetailBack") -- 父父类
    local _AgainstNode = GUI.GetChild(SeatDetailBack, "AgainstNode") -- 父类

    local _SeatAdvScrollBack = GUI.GetChild(_AgainstNode, "SeatAdvScrollBack") -- 本页面的一个节点

    if _SeatAdvScrollBack == nil then
        --底板
        _SeatAdvScrollBack = GUI.ImageCreate(_AgainstNode, "SeatAdvScrollBack", "1800600100", 6, 6, false, 314, 260)
        SetAnchorAndPivot(_SeatAdvScrollBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        --滚动面板
        local _OnePanelSize = Vector2.New(0, 0)
        local _SeatAdvScroll = GUI.ScrollRectCreate(_SeatAdvScrollBack, "SeatAdvScroll", 0, 4, 312, 252, 0, false, _OnePanelSize, UIAroundPivot.Top, UIAnchor.Top, 2)
        SetAnchorAndPivot(_SeatAdvScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        _gt.BindName(_SeatAdvScroll, "SeatAdvScroll")
        GUI.ScrollRectSetChildSpacing(_SeatAdvScroll, Vector2.New(28, 10))
        GUI.ScrollRectSetNormalizedPosition(_SeatAdvScroll, Vector2.New(0, 0))

        local _SeatAdvScrollLst = GUI.ImageCreate(_SeatAdvScroll, "SeatAdvScrollLst", "1800499999", 0, 0)
        SetAnchorAndPivot(_SeatAdvScrollLst, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        _gt.BindName(_SeatAdvScrollLst, "SeatAdvScrollLst")

        --底板
        local _SeatDisadvScrollBack = GUI.ImageCreate(_AgainstNode, "SeatDisadvScrollBack", "1800600100", 6, 269, false, 314, 260)
        SetAnchorAndPivot(_SeatDisadvScrollBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

        --滚动面板
        local _SeatDisadvScroll = GUI.ScrollRectCreate(_SeatDisadvScrollBack, "SeatDisadvScroll", 0, 4, 312, 252, 0, false, _OnePanelSize, UIAroundPivot.Top, UIAnchor.Top, 2)
        SetAnchorAndPivot(_SeatDisadvScroll, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        _gt.BindName(_SeatDisadvScroll, "SeatDisadvScroll")
        GUI.ScrollRectSetChildSpacing(_SeatDisadvScroll, Vector2.New(28, 10))
        GUI.ScrollRectSetNormalizedPosition(_SeatDisadvScroll, Vector2.New(0, 0))

        local _SeatDisadvScrollLst = GUI.ImageCreate(_SeatDisadvScroll, "SeatDisadvScrollLst", "1800499999", 0, 0)
        SetAnchorAndPivot(_SeatDisadvScrollLst, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
        _gt.BindName(_SeatDisadvScrollLst, "SeatDisadvScrollLst")

    else
        GUI.SetVisible(_AgainstNode, true) -- 显示本页面
    end

    --BattleSeatUI.ShowAgainstSeatLst() -- 刷新方法
end
-- 刷新阵法克制效果页面
function BattleSeatUI.ShowAgainstSeatLst()
    local SeatDetailBack = _gt.GetUI("SeatDetailBack") -- 父父类
    local _AgainstNode = GUI.GetChild(SeatDetailBack, "AgainstNode") -- 父类

    local AgainstPage_Data = BattleSeatUI.Arrange_AgainstPage_Data()
    if not AgainstPage_Data then
        test("执行 整理阵法克制界面所需要的数据函数  获取结果时为空")
        return
    end

    -- 克制其他阵法部分
    local SeatAdvScroll = _gt.GetUI("SeatAdvScroll")
    local _SeatAdvScrollLst = GUI.GetChild(SeatAdvScroll, "SeatAdvScrollLst")

    BattleSeatUI.Refresh_Against_Part(SeatAdvScroll, _SeatAdvScrollLst, AgainstPage_Data["Adv"])

    -- 被其他阵法克制
    local SeatDisadvScroll = _gt.GetUI("SeatDisadvScroll")
    local SeatDisadvScrollLst = _gt.GetUI("SeatDisadvScrollLst")

    BattleSeatUI.Refresh_Against_Part(SeatDisadvScroll, SeatDisadvScrollLst, AgainstPage_Data["DisAdv"])

end
-- 刷新阵法克制界面上部分或下部分
function BattleSeatUI.Refresh_Against_Part(Seat_AdvOrDisAdv_Scroll, _Seat_AdvOrDisAdv_ScrollLst, AgainstPage_Data)

    local positionY = 10 -- Y轴变量
    --local positionX = 30 -- X轴变量
    -- x轴全部+160
    local positionX = 190
    local TotalPosY = 500 -- 滚动区域Y轴大小
    -- 下面部分待传入参数写入
    local TextCount = #AgainstPage_Data -- 克制字体的种类
    local BattleSeatCount = 5 -- 克制阵法的种类
    local percentage = 5 -- 克制百分比
    local BattleSeat_Icons = "1800903120" -- 阵法图片
    local BattleSeat_Names = "玄武阵" -- 阵法名称
    local TextColor = colorGreen -- 字体颜色

    for i = 1, TextCount do
        -- 初始化数据
        BattleSeatCount = #AgainstPage_Data[i]
        percentage = AgainstPage_Data[i][1][2] / 100

        local TextContent = "克制" .. percentage .. "%"  -- 字体文本

        if percentage < 0 then
            TextContent = "被克" .. -percentage .. "%"
            TextColor = colorRed
        end

        -- 显示克制字体
        local _TypeBack = GUI.GetChild(_Seat_AdvOrDisAdv_ScrollLst, "TypeBack" .. i)
        local _AdvTypeTxt = GUI.GetChild(_TypeBack, "AdvTypeTxt" .. i)

        if _AdvTypeTxt == nil then
            _TypeBack = GUI.ImageCreate(_Seat_AdvOrDisAdv_ScrollLst, "TypeBack" .. i, "1800607180", 175, positionY) -- x 15
            SetAnchorAndPivot(_TypeBack, UIAnchor.TopLeft, UIAroundPivot.TopLeft)

            _AdvTypeTxt = GUI.CreateStatic(_TypeBack, "AdvTypeTxt" .. i, "", 10, 0, 100, 26) --x 10
            SetAnchorAndPivot(_AdvTypeTxt, UIAnchor.Left, UIAroundPivot.Left)
            GUI.StaticSetFontSize(_AdvTypeTxt, 22)
            GUI.SetColor(_AdvTypeTxt, TextColor)
        end

        -- 插入克制字体
        if _AdvTypeTxt and _TypeBack then
            GUI.SetPositionY(_TypeBack, positionY)
            GUI.StaticSetText(_AdvTypeTxt, TextContent)
            positionY = positionY + GUI.GetHeight(_TypeBack) + 10
        end

        -- 创建阵法
        for j = 1, BattleSeatCount do
            -- 初始化数据
            local BattleSeat = DB.GetOnceSeatByKey1(AgainstPage_Data[i][j][1])
            BattleSeat_Icons = BattleSeat.Icon
            BattleSeat_Names = BattleSeat.Name

            --底框
            local _Back = GUI.GetChild(_Seat_AdvOrDisAdv_ScrollLst, "Back" .. i .. j)
            if _Back == nil then
                _Back = GUI.ImageCreate(_Seat_AdvOrDisAdv_ScrollLst, "Back" .. i .. j, "1800700020", positionX, positionY, false, 52, 52)
                SetAnchorAndPivot(_Back, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                GUI.SetVisible(_Back, true)
            end
            -- 显示底板
            if _Back ~= nil then
                GUI.SetVisible(_Back, true)
            end

            --图标
            local _Icon = GUI.GetChild(_Back, "Icon")
            if _Icon == nil then
                _Icon = GUI.ImageCreate(_Back, "Icon", "1800903100", 0, -1, false, 48, 48)
                SetAnchorAndPivot(_Icon, UIAnchor.Center, UIAroundPivot.Center)
                GUI.SetVisible(_Icon, true)
            end

            -- 插入阵法图片
            if _Icon ~= nil then
                GUI.SetPositionY(_Back, positionY)
                --GUI.SetPositionY(_Icon,positionY)
                GUI.ImageSetImageID(_Icon, BattleSeat_Icons) --待修改
                GUI.SetVisible(_Icon, true)
            end

            positionX = positionX + GUI.GetWidth(_Icon)

            --名称
            local _Name = GUI.GetChild(_Back, "Name")
            if _Name == nil then
                _Name = GUI.CreateStatic(_Back, "Name", "", 61, 16, 100, 26) -- 61
                SetAnchorAndPivot(_Name, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                GUI.StaticSetFontSize(_Name, 22)
                GUI.SetColor(_Name, colorDark)
                GUI.SetVisible(_Name, true)
            end
            -- 插入名称
            if _Name ~= nil then
                GUI.StaticSetText(_Name, BattleSeat_Names)
                GUI.SetVisible(_Name, true)
                positionX = positionX + GUI.GetWidth(_Name)
            end

            if BattleSeatCount > j and j % 2 == 0 then
                -- 当一行放了两个图标且不止两个图片时，需要换到下一行
                positionY = positionY + 52 + 10
                --positionX = 30
                positionX = 190
            end

        end

        -- 下一个百分比的效果，重置x，换行Y
        --positionX = 30
        positionX = 190
        positionY = 52 + positionY + 10


        -- 将多的部分隐藏
        for n = 1, 4 do
            local _Back = GUI.GetChild(_Seat_AdvOrDisAdv_ScrollLst, "Back" .. i .. BattleSeatCount + n)
            if _Back then
                GUI.SetVisible(_Back, false)
            end
        end

    end

    TotalPosY = positionY -- 滚动区域Y轴大小
    --设置滚动区大小
    if Seat_AdvOrDisAdv_Scroll ~= nil then
        GUI.ScrollRectSetChildSize(Seat_AdvOrDisAdv_Scroll, Vector2.New(310, TotalPosY))
    end
end
-- 整理阵法克制界面所需要的数据
function BattleSeatUI.Arrange_AgainstPage_Data()
    local AgainstPage_Data = {}
    AgainstPage_Data["Adv"] = { [1] = {}, [2] = {} } --{["5%"]={},["10%"]={}}
    AgainstPage_Data["DisAdv"] = { [1] = {}, [2] = {} } -- {["5%"]={},["10%"]={}}


    if BattleSeatUI.SelectedSeatId then
        local BattleSeat = DB.GetOnceSeatByKey1(BattleSeatUI.SelectedSeatId)
        for i = 1, 10 do
            -- 不存入不存在的阵法
            if BattleSeat["Seat" .. i] ~= 0 and DB.GetOnceSeatByKey1(BattleSeat["Seat" .. i]).Id ~= 0 then
                if BattleSeat["Coef" .. i] > 0 then
                    if BattleSeat["Coef" .. i] == 500 then
                        table.insert(AgainstPage_Data["Adv"][1], { BattleSeat["Seat" .. i], BattleSeat["Coef" .. i] }) -- 5%
                    else
                        table.insert(AgainstPage_Data["Adv"][2], { BattleSeat["Seat" .. i], BattleSeat["Coef" .. i] }) -- 10%
                    end
                else
                    if BattleSeat["Coef" .. i] < -500 then
                        table.insert(AgainstPage_Data["DisAdv"][1], { BattleSeat["Seat" .. i], BattleSeat["Coef" .. i] }) -- 10%
                    else
                        table.insert(AgainstPage_Data["DisAdv"][2], { BattleSeat["Seat" .. i], BattleSeat["Coef" .. i] }) -- 5%
                    end
                end
            end
        end
        return AgainstPage_Data
    end

end

-- 阵法效果按钮 触发事件
function BattleSeatUI.OnEffectPage()
    local SeatDetailBack = _gt.GetUI("SeatDetailBack") -- 父父类

    local _AgainstNode = GUI.GetChild(SeatDetailBack, "AgainstNode") -- 阵法克制页面

    local _EffectNode = GUI.GetChild(SeatDetailBack, "EffectNode") --阵法效果页面

    -- 将阵法克制页面隐藏
    if _AgainstNode ~= nil then
        GUI.SetVisible(_AgainstNode, false)
    end

    if not _EffectNode then
        BattleSeatUI.CreateEffectInfos_Page()
        _EffectNode = GUI.GetChild(SeatDetailBack, "EffectNode")
    end

    -- 显示阵法效果页面
    GUI.SetVisible(_EffectNode, true)
    --BattleSeatUI.GetEffectInfos_Page_Data()

end
-- 阵法克制按钮 触发事件
function BattleSeatUI.OnAgainstPage()
    local SeatDetailBack = _gt.GetUI("SeatDetailBack") -- 父父类

    local _AgainstNode = GUI.GetChild(SeatDetailBack, "AgainstNode") -- 阵法克制页面

    local _EffectNode = GUI.GetChild(SeatDetailBack, "EffectNode") -- 阵法效果页面

    -- 将阵法效果页面隐藏
    if _EffectNode ~= nil then
        GUI.SetVisible(_EffectNode, false)
    end

    if not _AgainstNode then
        BattleSeatUI.CreateAgainstSeatLst()
        _AgainstNode = GUI.GetChild(SeatDetailBack, "AgainstNode")
    end

    -- 显示阵法克制页面
    GUI.SetVisible(_AgainstNode, true)
    --BattleSeatUI.ShowAgainstSeatLst()

end

-- 向服务器请求阵法效果页面数据
function BattleSeatUI.GetEffectInfos_Page_Data()
    -- 返回变量
    -- BattleSeatUI.GuardListData
    -- 执行方法
    -- BattleSeatUI.ShowEffectInfos()
    if BattleSeatUI.TabIndex then
        CL.SendNotify(NOTIFY.SubmitForm, "FormSeat", "GetGuardList", tostring(BattleSeatUI.TabIndex))
    end
end
------------------------右边阵法效果和克制结束---------------------------------

------------------------中间阵法站位开始---------------------------------
local SeatNum = 5
local SeatPositionData = {}
function BattleSeatUI.GetSeatRowCol(seatId)
    local data = SeatPositionData[seatId]
    if not data then
        local seatDB = DB.GetOnceSeatByKey1(seatId)
        if not seatDB or seatDB.Id == 0 then
            test("找不到阵法ID为：" .. seatId .. "的阵法")
            return nil
        end
        local infoDB = SETTING.GetLineup(seatDB.LineupId)
        if infoDB.ID == 0 then
            test("找不到站位配置：" .. seatDB.LineupId)
            return nil
        end
        data = {}
        for i = 0, SeatNum - 1 do
            local site = infoDB.Sites[0].Site[i]
            data[#data + 1] = (site.Row - 1) * 5 + site.Col - 1
        end
        SeatPositionData[seatId] = data
    end
    return data
end

function BattleSeatUI.RefreshSeatPosition()
    local DisX = 53
    local DisY = 22
    local StartX = 57
    local StartY = 363

    local modelNode = _gt.GetUI("SeatModelNode")
    if not modelNode then
        local seatPanelBack = _gt.GetUI("SeatPanelBack")
        --站位底板
        for j = 1, 3 do
            for i = 1, 5 do
                --底板
                local PX = StartX + (i - 1) * DisX + (j - 1) * 55
                local PY = StartY - (i - 1) * DisY + (j - 1) * 31
                local name = "ModelLstNode" .. ((j - 1) * 5 + i - 1)
                local _ModelLstNode = GUI.CheckBoxCreate(seatPanelBack, name, "1800600111", "1800600110", PX, PY, Transition.ColorTint, false)
                SetAnchorAndPivot(_ModelLstNode, UIAnchor.TopLeft, UIAroundPivot.TopLeft)
                GUI.SetInteractable(_ModelLstNode, false)
                _ModelLstNode:UnRegisterEvent(UCE.PointerClick)
                _gt.BindName(_ModelLstNode, name)
            end
        end
        modelNode = GUI.RawImageCreate(seatPanelBack, false, "SeatModelNode", "", 0, 0, 3, false, 440, 440)
        GUI.SetIsRaycastTarget(modelNode, false)
        _gt.BindName(modelNode, "SeatModelNode")
        GUI.AddToCamera(modelNode)
        GUI.RawImageSetCameraConfig(modelNode, "(0.09119999,1.336,2.56),(-5.705484E-09,0.9914449,-0.1305263,-4.333743E-08),True,4.79,-1,3.33,37")
        --数字
        for i = 1, SeatNum do
            local name = "Num" .. i
            local _Num = GUI.ImageCreate(modelNode, name, SeatOrderNum[i], 6, 34)
            SetAnchorAndPivot(_Num, UIAnchor.Center, UIAroundPivot.Center)
            _gt.BindName(_Num, name)
        end
    end

    --刷新底板
    for i = 0, 14 do
        local _ModelLstNode = _gt.GetUI("ModelLstNode" .. i)
        GUI.CheckBoxSetCheck(_ModelLstNode, false)
    end

    local siteInfo = BattleSeatUI.GetSeatRowCol(BattleSeatUI.SelectedSeatId or 1)
    local guardGuidList = BattleSeatUI.GuardListData or {}
    for i = 1, SeatNum do
        local guid = guardGuidList[i]
        local posIdx = siteInfo[i]
        local X = posIdx % 5
        local Y = (posIdx - X) / 5
        local name = "SeatModel" .. i
        local model = _gt.GetUI(name)
        if i ~= 1 and (not guid or guid == "0" or guid == 0) then
            if model then
                GUI.SetVisible(model, false)
            end
        else
            if not model then
                model = GUI.RawImageChildCreate(modelNode, true, name, "", 0, 0)
                _gt.BindName(model, name)
            else
                GUI.SetVisible(model, true)
            end

            -- 更新队伍信息
            BattleSeatUI.teamInfo = LD.GetTeamInfo()
            BattleSeatUI.teamNumber = 0 -- 队伍人数
            if tostring(BattleSeatUI.teamInfo.team_guid) ~= "0" and BattleSeatUI.teamInfo.members ~= nil then
                BattleSeatUI.teamNumber = BattleSeatUI.teamInfo.members.Length
            end


            -- 判断是否组队
            if i == 1 and BattleSeatUI.teamNumber == 0 then
                -- 当未组队时 显示角色时
                local wep = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId)
                local effect = CL.GetIntAttr(RoleAttr.RoleAttrWeaponId)
                ModelItem.BindSelfRole(model, eRoleMovement.STAND_W1, wep, effect)

                -- 绑定装备和宝石强化的特效
                --ModelItem.BindRoleEquipGemEffect(model)

            elseif i <= BattleSeatUI.teamNumber then
                -- 当组队时 显示角色时
                local role_MOD = DB.GetRole(BattleSeatUI.teamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrRole)).Model
                local ColorID1 = BattleSeatUI.teamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrColor1)
                local ColorID2 = BattleSeatUI.teamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrColor2)
                local Gender = BattleSeatUI.teamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrGender)
                local WeaponEffect = BattleSeatUI.teamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrEffect1)
                local RoleGUID = tostring(BattleSeatUI.teamInfo.members[i - 1].guid)

                local itemID = BattleSeatUI.teamInfo:GetMemberAttr(i - 1, RoleAttr.RoleAttrWeaponId)
                local config = DB.GetOnceItemByKey1(itemID)
                local WeaponID = 0

                if config.Id ~= 0 then
                    WeaponID = tonumber(tostring(config.ModelRole1))
                else
                    WeaponID = itemID
                end

                ModelItem.BindRoleWithClothAndWind(model, role_MOD, ColorID1, ColorID2, eRoleMovement.STAND_W1, WeaponID, Gender, WeaponEffect, TOOLKIT.Str2uLong(RoleGUID))
                --ModelItem.Bind(model, role_MOD, ColorID1, ColorID2, eRoleMovement.STAND_W1,WeaponID)

                -- 绑定装备和宝石强化的特效
                local guid = BattleSeatUI.teamInfo.members[i - 1].guid
                ModelItem.BindRoleEquipGemEffect(model, guid, true)

            else
                -- 当显示侍从时
                local id = LD.GetGuardIDByGUID(guid)
                local guardDB = DB.GetOnceGuardByKey1(id)
                ModelItem.Bind(model, guardDB.Model, guardDB.ColorID1, guardDB.ColorID2, eRoleMovement.STAND_W1)
                BattleSeatUI.addRoleEffect(model, id) -- 添加侍从气势特效
            end

            local PX = -Y * (0.82) - X * (0.79) + 2.46
            local PY = -Y * (0.30) + X * (0.33) - 1.73
            GUI.SetLocalPosition(model, PX, PY, -0.4 + 0.8 * Y)
            GUI.SetEulerAngles(model, 0, -45, 0)
        end
        --设置底板
        local _ModelLstNode = _gt.GetUI("ModelLstNode" .. posIdx)
        GUI.CheckBoxSetCheck(_ModelLstNode, true)

        --刷新数字
        local _Num = _gt.GetUI("Num" .. i)
        if BattleSeatUI.IsShowNum(X, Y, siteInfo, guardGuidList) then
            GUI.SetVisible(_Num, true)
            local PX = StartX + X * DisX + Y * 55 - 217
            local PY = StartY - X * DisY + Y * 31 - 217
            GUI.SetPositionX(_Num, PX)
            GUI.SetPositionY(_Num, PY + 6)
        else
            GUI.SetVisible(_Num, false)
        end
    end
end

function BattleSeatUI.IsShowNum(X, Y, seatInfo, guidList)
    if Y == 2 then
        return true
    else
        local ValX = Y * 5 + X
        local FrontX = ValX + 4
        for i = 1, #seatInfo do
            local TmpX = seatInfo[i] % 5
            local TmpY = (seatInfo[i] - TmpX) / 5
            if TmpY ~= Y and seatInfo[i] == FrontX then
                if guidList[i] and guidList[i] ~= 0 and guidList[i] ~= "0" then
                    return false
                end
            end
        end
        return true
    end
end

-- 模型旋转
local isTurn = false
function BattleSeatUI.OnRotateModelBtn()
    for i = 1, SeatNum do
        local model = _gt.GetUI("SeatModel" .. i) -- 获取模型对象

        -- 取反模型旋转的y轴
        GUI.SetEulerAngles(model, 0, isTurn and -45 or -225, 0)
    end
    isTurn = not isTurn
end

-- 侍从特效表 从二星开始
local _RoleEffectTable = {
    10, 11, 12, 13, 14
}
-- 销毁人物特效ID列表
BattleSeatUI._DestroyRoleEffectTable = {}

function BattleSeatUI.addRoleEffect(_RoleModel, GuardID)

    if _RoleModel == nil then
        test("添加人物气势特效时，获取人物模型为空")
        return
    end

    if GuardID == nil then
        test("添加人物气势特效时，获取侍从ID为空")
        return
    end

    -- 删除人物特效
    local DestroyRoleEffectID = BattleSeatUI._DestroyRoleEffectTable[tostring(GuardID)]
    if DestroyRoleEffectID ~= nil then
        -- 获取创建特效时得到的特效ID
        GUI.DestroyRoleEffect(_RoleModel, DestroyRoleEffectID)
        BattleSeatUI._DestroyRoleEffectTable[tostring(GuardID)] = nil
    end
    -- 获取人物当前星级
    local currentSelectedGuardStar = CL.GetIntCustomData("Guard_Star", TOOLKIT.Str2uLong(LD.GetGuardGUIDByID(GuardID)))

    -- 添加人物特效
    if currentSelectedGuardStar > 1 then
        -- 防止星级为1
        local newDestroyRoleEffectID = GUI.CreateRoleEffect(_RoleModel, _RoleEffectTable[currentSelectedGuardStar - 1]) -- 添加人物特效
        -- 更新销毁人物特效ID
        BattleSeatUI._DestroyRoleEffectTable[tostring(GuardID)] = newDestroyRoleEffectID
    end
end
------------------------中间阵法站位结束---------------------------------


-- 当队伍数据变化时 执行的监听事件
function BattleSeatUI.OnTeamInfoUpdate(Type, p0, p1, p2)
    --这个监听事件每次都会执行两次。 创建一个全局变量让他只执行一次
    if BattleSeatUI.team_info_change == nil then
        BattleSeatUI.team_info_change = 1
        return ''
    elseif BattleSeatUI.team_info_change == 1 then
        if Type == 0 or Type == 7 then
            -- 更新一下队伍数据
            BattleSeatUI.teamInfo = LD.GetTeamInfo()
            BattleSeatUI.teamNumber = 0 -- 队伍人数
            if tostring(BattleSeatUI.teamInfo.team_guid) ~= "0" and BattleSeatUI.teamInfo.members ~= nil then
                BattleSeatUI.teamNumber = BattleSeatUI.teamInfo.members.Length
            end
            -- 向服务器请求阵法效果页面数据
            -- 刷新阵法效果页面和站位
            BattleSeatUI.GetEffectInfos_Page_Data()
        end
        --重置数据
        BattleSeatUI.team_info_change = nil
    end
end